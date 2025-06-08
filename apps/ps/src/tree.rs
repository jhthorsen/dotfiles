use crate::process::Process;
use comfy_table::{Attribute, Cell, CellAlignment, Color, Row};
use pager::Pager;
use std::collections::HashMap;
use std::env;
use std::process::{self, Command};

fn capture_stdout(cmd: &mut Command) -> String {
    let output = cmd.output();

    if output.is_err() {
        log::error!("Unable to run ps: {}", output.unwrap_err().to_string());
        process::exit(1);
    }

    let output = output.unwrap();
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        log::error!("{}", stderr);
        process::exit(output.status.code().unwrap_or(1));
    }

    String::from_utf8_lossy(&output.stdout).to_string()
}

fn make_process_tree(
    table: &mut comfy_table::Table,
    cli: &crate::cli::Cli,
    lookup: &HashMap<u32, Process>,
    pids: &Vec<u32>,
    indent: &str,
) {
    for (i, pid) in pids.iter().enumerate() {
        let Some(node) = lookup.get(&pid) else {
            log::error!("Internal structure is invalid: No node for {}", pid);
            continue;
        };

        let mut row = Row::new();
        row.add_cell(match node.last.is_empty() {
            true => rcell(&node.pid.to_string()).add_attribute(Attribute::Dim),
            false => rcell(&node.pid.to_string()),
        });

        let last = i == pids.len() - 1;
        let arrow = if last { "└─" } else { "├─" };
        let mut headers = table.header().unwrap().cell_iter();
        headers.next(); // Skip the first header (PID)
        for (i, val) in node.columns.iter().enumerate() {
            let h = headers.next().unwrap();
            let mut val = val.clone();
            if ["rss", "rsz", "size", "sz", "trs", "vsz"]
                .contains(&h.content().to_lowercase().as_str())
            {
                val = crate::util::format_with_suffix(val.parse::<usize>().unwrap_or(0));
            }

            row.add_cell(match i {
                i if i % 2 == 1 => rcell(&val),
                _ => rcell(&val).add_attribute(Attribute::Dim),
            });
        }

        let command = match cli.wide {
            false => crate::util::short_command(&node.last),
            true => node.last.clone(),
        };

        row.add_cell(Cell::new(format!("{}{} {}", indent, arrow, command)).fg(Color::DarkYellow));

        table.add_row(row);

        let indent = match last {
            true => format!("{}  ", indent),
            false => format!("{}│ ", indent),
        };

        make_process_tree(table, &cli, lookup, &node.children, &indent);
    }
}

fn ps_flags(cli: &crate::cli::Cli) -> Vec<String> {
    let mut flags = cli.flags.clone();
    let mut output_format = "pid,ppid".to_string();

    let mut special: Vec<char> = vec![];
    for c in cli.special.iter() {
        match c {
            'u' => output_format = "pid,ppid,user".to_string(),
            'v' => output_format = "pid,ppid,time,%cpu,%mem,rss,vsz".to_string(),
            c => special.push(*c),
        };
    }

    if !special.is_empty() {
        flags.insert(0, special.iter().collect::<String>());
    }

    if cli.output_format.is_empty() {
        output_format.push_str(",command");
    } else {
        output_format.push_str(",");
        output_format.push_str(cli.output_format.as_str());
    }

    flags.push("-o".to_string());
    flags.push(output_format.to_string());
    flags
}

fn rcell(v: &str) -> Cell {
    Cell::new(v).set_alignment(CellAlignment::Right)
}

pub fn run(cli: crate::cli::Cli) {
    let flags = ps_flags(&cli);
    log::debug!("ps {}", flags.join(" "));

    let headers = flags.last().unwrap().split(",").collect::<Vec<&str>>();
    let pid = std::process::id();
    let mut lookup: HashMap<u32, Process> = HashMap::new();
    for line in capture_stdout(cli.ps_command().args(&flags)).split('\n') {
        if line.is_empty() || line.contains(" PPID ") {
            continue;
        }
        let Some(child) = Process::from_line(&line, &headers) else {
            log::warn!("Unable to parse \"{}\"", line);
            continue;
        };

        if child.pid == pid || child.ppid == pid {
            continue;
        }

        let parent = lookup.entry(child.ppid).or_insert(Process {
            pid: child.ppid,
            ppid: 1,
            last: "".to_string(),
            columns: child.columns.iter().map(|_| "-".to_string()).collect(),
            children: vec![],
        });

        parent.children.push(child.pid);

        // Make sure we have the correct information, in case a parent
        // was inserted before the child.
        let entry = lookup.entry(child.pid).or_insert(child.clone());
        entry.ppid = child.ppid;
        entry.columns = child.columns.clone();
    }

    log::trace!("{:#?}", lookup);

    let mut root_pids = lookup
        .iter()
        .filter(|(_, node)| node.ppid == 1 && node.pid > 1)
        .map(|(pid, _)| *pid)
        .collect::<Vec<u32>>();

    root_pids.sort_unstable();

    let mut table = comfy_table::Table::new();

    table.load_preset(comfy_table::presets::NOTHING);
    if table.is_tty() {
        table.enforce_styling();
    }

    table.set_header(table_headers(&headers));
    make_process_tree(&mut table, &cli, &lookup, &root_pids, "");

    if table.is_tty() {
        let pager = env::var("PS_PAGER").unwrap_or("less -SX".to_string());
        Pager::with_pager(&pager).setup();
        println!("{}", table);
    } else {
        for (i, line) in table.to_string().lines().enumerate() {
            if i == 0 && cli.no_header {
                continue;
            }
            println!("{}", line.trim_end());
        }
    }
}

fn table_headers(headers: &[&str]) -> Vec<Cell> {
    headers
        .iter()
        .enumerate()
        .filter_map(|(i, h)| match i {
            0 => None,
            n if n == headers.len() - 1 => Some(
                Cell::new(*h)
                    .add_attributes(vec![Attribute::Bold])
                    .fg(Color::DarkYellow),
            ),
            n if n % 2 == 1 => Some(
                Cell::new(*h)
                    .add_attributes(vec![Attribute::Bold])
                    .set_alignment(CellAlignment::Right),
            ),
            _ => Some(
                Cell::new(*h)
                    .add_attributes(vec![Attribute::Bold, Attribute::Dim])
                    .set_alignment(CellAlignment::Right),
            ),
        })
        .collect::<Vec<Cell>>()
}
