use std::os::unix::process::CommandExt;

pub fn ps_flags(cli: &crate::cli::Cli) -> Vec<String> {
    let mut flags = cli.flags.clone();
    if !cli.output_format.is_empty() {
        flags.push("-o".to_string());
        flags.push(cli.output_format.clone());
    }

    if !cli.special.is_empty() {
        flags.insert(0, cli.special.iter().collect::<String>());
    }

    flags
}

pub fn run(cli: crate::cli::Cli) {
    let flags = ps_flags(&cli);
    log::debug!("ps {}", flags.join(" "));
    let err = cli.ps_command().args(flags).exec();
    log::error!("Unable to exec ps: {}", err.to_string());
    std::process::exit(1); // Should not come to this
}
