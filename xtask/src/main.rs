//! Maintenance tasks for this repository, run with `cargo xtask <command>`.

mod rename;

use std::path::PathBuf;
use std::process::ExitCode;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Rename the project after creating a repo from the template.
    ///
    /// Replaces the template's name in every file, renames the crate
    /// directories, and with `--owner` points GitHub and GHCR links at the
    /// new owner.
    Rename {
        /// New project name, in kebab case (for example `my-tool`).
        name: String,
        /// New GitHub user or organization that owns the repo.
        #[arg(long)]
        owner: Option<String>,
        /// Print what would change without writing anything.
        #[arg(long)]
        dry_run: bool,
    },
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    match cli.command {
        Command::Rename {
            name,
            owner,
            dry_run,
        } => {
            let root = workspace_root();
            let plan = rename::Rename {
                name: &name,
                owner: owner.as_deref(),
                dry_run,
            };
            match plan.run(&root) {
                Ok(report) => {
                    print!("{report}");
                    ExitCode::SUCCESS
                }
                Err(err) => {
                    eprintln!("error: {err}");
                    ExitCode::FAILURE
                }
            }
        }
    }
}

/// The workspace root: the parent of this crate's manifest directory.
fn workspace_root() -> PathBuf {
    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    manifest_dir
        .parent()
        .map_or(manifest_dir.clone(), PathBuf::from)
}
