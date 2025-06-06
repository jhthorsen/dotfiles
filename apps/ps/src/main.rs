mod cli;
mod process;
mod tree;
mod vanilla;

fn main() {
    env_logger::try_init().expect("Failed to initialize logger");
    let cli = cli::Cli::parse_command_line_args();

    if cli.tree {
        tree::run(cli);
    } else {
        vanilla::run(cli);
    }
}
