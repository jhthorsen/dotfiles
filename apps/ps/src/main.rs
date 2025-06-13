mod cli;
mod process;
mod tree;
mod util;
mod vanilla;

use std::env;

fn main() {
    env_logger::try_init().expect("Failed to initialize logger");

    let mut args = env::args().into_iter();
    let cli = cli::Cli::parse_command_line_args(&mut args);

    if cli.tree {
        tree::run(cli);
    } else {
        vanilla::run(cli);
    }
}
