use std::env;
use std::path::Path;
use std::process;

#[derive(Debug, Default)]
pub struct Cli {
    pub name: String,
    pub flags: Vec<String>,
    pub special: Vec<char>,
    pub no_header: bool,
    pub tree: bool,
    pub wide: bool,
}

impl Cli {
    pub fn parse_command_line_args<I>(input: &mut I) -> Self
    where
        I: ExactSizeIterator<Item = String>,
        <I as Iterator>::Item: std::fmt::Display,
    {
        let mut cli = Cli::default();
        cli.name = input.next().unwrap();

        while input.len() > 0 {
            let arg = input.next().unwrap();
            log::trace!("arg={}", arg);

            if arg.starts_with("-") {
                cli.flags.push(arg);
                if let Some(val) = input.next() {
                    cli.flags.push(val);
                }
            } else if let Ok(_) = arg.parse::<usize>() {
                cli.flags.push(arg);
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

#[cfg(test)]
mod tests {
    use super::Cli;

    #[test]
    fn empty() {
        let args: Vec<String> = "foo".split_whitespace().map(|s| s.to_string()).collect();
        let cli = Cli::parse_command_line_args(&mut args.into_iter());
        assert_eq!(cli.name, "foo".to_string());
        assert_eq!(cli.flags, Vec::<String>::new());
        assert_eq!(cli.special, Vec::<char>::new());
        assert_eq!(cli.no_header, false);
        assert_eq!(cli.tree, false);
        assert_eq!(cli.wide, false);
    }

    #[test]
    fn vanilla() {
        let args: Vec<String> = "foo xa".split_whitespace().map(|s| s.to_string()).collect();
        let cli = Cli::parse_command_line_args(&mut args.into_iter());
        assert_eq!(cli.name, "foo".to_string());
        assert_eq!(cli.flags, Vec::<String>::new());
        assert_eq!(cli.special, vec!['x', 'a']);
        assert_eq!(cli.no_header, false);
        assert_eq!(cli.tree, false);
        assert_eq!(cli.wide, false);
    }

    #[test]
    fn many_options() {
        let args: Vec<String> = "foo fvxhw -o ppid= 4242".split_whitespace().map(|s| s.to_string()).collect();
        let cli = Cli::parse_command_line_args(&mut args.into_iter());
        assert_eq!(cli.name, "foo".to_string());
        assert_eq!(cli.flags, Vec::<String>::from(vec!["-o".into(), "ppid=".into(), "4242".into()]));
        assert_eq!(cli.special, vec!['v', 'x', 'h', 'w']);
        assert_eq!(cli.no_header, true);
        assert_eq!(cli.tree, true);
        assert_eq!(cli.wide, true);
    }
}
