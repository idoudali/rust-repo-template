//! Command-line entry point of the Rust repository template.
//!
//! Parsing and printing only; the logic lives in the `rust_repo_template`
//! library crate.

use clap::{Parser, Subcommand};
use rust_repo_template::{Info, greeting};

/// Example CLI built from the Rust repository template.
#[derive(Debug, Parser)]
#[command(name = "rust-repo-template", version = rust_repo_template::VERSION, about)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Debug, Subcommand)]
enum Command {
    /// Greet someone.
    Greet {
        /// Who to greet.
        name: String,
        /// How many times to print the greeting.
        #[arg(
            short,
            long,
            default_value_t = 1,
            value_parser = clap::value_parser!(u8).range(1..)
        )]
        count: u8,
        /// Print the greeting in capitals.
        #[arg(long)]
        shout: bool,
    },
    /// Show version and platform information.
    Info {
        /// Print the information as JSON.
        #[arg(long)]
        json: bool,
    },
}

/// Turns a parsed command into the text to print.
fn run(command: &Command) -> String {
    match command {
        Command::Greet { name, count, shout } => {
            vec![greeting(name, *shout); usize::from(*count)].join("\n")
        }
        Command::Info { json } => {
            let info = Info::current();
            if *json {
                info.to_json()
            } else {
                info.to_string()
            }
        }
    }
}

fn main() {
    let cli = Cli::parse();
    println!("{}", run(&cli.command));
}
