//! Command-line entry point of the Rust repository template.

use clap::Parser;

/// Command-line arguments.
#[derive(Debug, Parser)]
#[command(name = "rust-repo-template", version = rust_repo_template::VERSION, about)]
struct Cli {}

fn main() {
    let _cli = Cli::parse();
}
