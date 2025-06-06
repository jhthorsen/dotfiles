use crate::process::Process;
use colored::*;
use pager::Pager;
use std::collections::HashMap;
use std::env;
use std::path::Path;
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

fn print_process_tree(
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

        let last = i == pids.len() - 1;
        let arrow = if last { "└─" } else { "├─" };
        if let Some(columns) = &node.columns {
            let mut columns = columns.clone();
            if cli.wide == false {
                if let Some(last) = columns.last_mut() {
                    *last = short_command(last)
                }
            }

            println!(
                "{}{} {}{} {}",
                " ".repeat(8 - node.pid.to_string().len()),
                node.pid,
                indent,
                arrow.dimmed().green(),
                columns.join(" "),
            );
        } else {
            println!(
                "{}{} {}{} {}",
                " ".repeat(8 - node.pid.to_string().len()),
                node.pid.to_string().dimmed(),
                indent,
                arrow.dimmed().green(),
                "",
            );
        }

        let indent = match last {
            true => format!("{}  ", indent),
            false => format!("{}│ ", indent).dimmed().green().to_string(),
        };

        print_process_tree(&cli, lookup, &node.children, &indent);
    }
}

fn ps_flags(cli: &crate::cli::Cli) -> Vec<String> {
    let mut flags = cli.flags.clone();
    let mut output_format = "pid,ppid".to_string();

    let mut special: Vec<char> = vec![];
    for c in cli.special.iter() {
        log::debug!("special={}", c);
        match c {
            'u' => output_format = "pid,ppid,user".to_string(),
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

pub fn run(cli: crate::cli::Cli) {
    let flags = ps_flags(&cli);
    log::debug!("tree={:?}", flags);

    let columns = flags.last().unwrap().split(",").collect::<Vec<&str>>();
    let pid = std::process::id();
    let mut lookup: HashMap<u32, Process> = HashMap::new();
    for line in capture_stdout(cli.ps_command().args(&flags)).split('\n') {
        let Some(child) = Process::from_line(&line, &columns) else {
            log::warn!("Unable to parse \"{}\"", line);
            continue;
        };

        if child.pid == pid || child.ppid == pid {
            continue;
        }

        let parent = lookup.entry(child.ppid).or_insert(Process {
            pid: child.ppid,
            ppid: 1,
            columns: None,
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

    let pager = env::var("PS_PAGER").unwrap_or("less -SX".to_string());
    if pager.starts_with("less") {
        colored::control::set_override(true);
    }

    Pager::with_pager(&pager).setup();
    print_process_tree(&cli, &lookup, &root_pids, "");
}

fn short_command(command: &mut String) -> String {
    let mut found_name = false;
    let mut path: Vec<String> = vec![];
    for part in command.split(" ") {
        if found_name {
            path.push(part.to_string());
        } else {
            path.push(part.to_string());
            if Path::new(&path.join(" ")).is_file() {
                path.clear();
                path.push(part.split("/").last().unwrap().to_string());
                found_name = true;
            }
        }
    }

    path.join(" ").to_string()
}
