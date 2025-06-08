use std::env;
use std::path::Path;
use std::process;

#[derive(Debug, Default)]
pub struct Cli {
    pub name: String,
    pub flags: Vec<String>,
    pub output_format: String,
    pub special: Vec<char>,
    pub no_header: bool,
    pub tree: bool,
    pub wide: bool,
}

impl Cli {
    pub fn parse_command_line_args() -> Self {
        let mut cli = Cli::default();
        let mut input = env::args();
        cli.name = input.next().unwrap();

        while input.len() > 0 {
            let arg = input.next().unwrap();
            log::trace!("arg={}", arg);

            if arg.starts_with("-o") {
                cli.output_format = input.next().unwrap_or_else(|| {
                    log::error!("Missing argument for -o option");
                    process::exit(1);
                });
            } else if arg.starts_with("-") {
                cli.flags.push(arg);
                if let Some(val) = input.next() {
                    cli.flags.push(val);
                }
            } else {
                for c in arg.chars() {
                    // a: Not only yourself.
                    // g: Really all, even session leaders.
                    // T: Select all processes associated with this terminal.
                    // r: Restrict the selection to only running processes.
                    // x: Not only must have a tty.
                    // j: BSD job control format.
                    // l: Display BSD long format.
                    // s: Display signal format.
                    // u: Display user-oriented format.
                    // v: Display virtual memory format.
                    // X: Register format.
                    // Z: Add a column of security data.
                    // c: Show the true command name.
                    // e: Show the environment after the command.
                    // f: ASCII art process hierarchy.
                    // h: No header.
                    // n: Numeric output for WCHAN and USER.
                    // S: Sum up some information, such as CPU usage
                    // w: Wide output.
                    // H: Show threads as if they were processes.
                    // m: Show threads after processes.
                    // L: List all format specifiers.
                    // V: Print the procps-ng version.

                    if c == 'f' {
                        cli.tree = true;
                    } else if c == 'h' {
                        cli.no_header = true;
                        cli.special.push(c);
                    } else if c == 'w' {
                        cli.wide = true;
                        cli.special.push(c);
                    } else {
                        cli.special.push(c);
                    }
                }
            }
        }

        cli
    }

    pub fn ps_command(&self) -> process::Command {
        let mut alternatives: Vec<String> = vec!["/bin/ps".into(), "/usr/bin/ps".into()];
        if let Ok(alt) = env::var("RUST_REAL_PS") {
            alternatives.insert(0, alt);
        }

        for ps in alternatives {
            if Path::new(ps.as_str()).is_file() {
                return process::Command::new(ps);
            }
        }

        panic!("Unable to find the real ps command");
    }
}
