//! End-to-end check of `cargo xtask rename`: copy the repository, rename the
//! copy, and build it. Two cold builds make it slow, so it is ignored by
//! default; `mise run rename-check` (and CI) runs it.

#![cfg(unix)]

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Top-level entries that are never part of a fresh clone.
const SKIP: &[&str] = &[".git", "target"];

/// Copies `from` into `to`, keeping symlinks as symlinks.
fn copy_tree(from: &Path, to: &Path) {
    fs::create_dir_all(to).unwrap();
    for entry in fs::read_dir(from).unwrap() {
        let entry = entry.unwrap();
        let name = entry.file_name();
        let name_str = name.to_string_lossy();
        if SKIP.contains(&name_str.as_ref()) || name_str.ends_with("_cache") {
            continue;
        }
        let kind = entry.file_type().unwrap();
        let dest = to.join(&name);
        if kind.is_symlink() {
            let target = fs::read_link(entry.path()).unwrap();
            std::os::unix::fs::symlink(target, dest).unwrap();
        } else if kind.is_dir() {
            copy_tree(&entry.path(), &dest);
        } else {
            fs::copy(entry.path(), dest).unwrap();
        }
    }
}

/// Every file under `dir` (outside the skipped directories) that still
/// mentions one of `needles`.
fn leftovers(dir: &Path, needles: &[&str], found: &mut Vec<PathBuf>) {
    for entry in fs::read_dir(dir).unwrap() {
        let path = entry.unwrap().path();
        let name = path.file_name().unwrap().to_string_lossy().into_owned();
        if ["target", "xtask"].contains(&name.as_str()) || path.is_symlink() {
            continue;
        }
        if path.is_dir() {
            leftovers(&path, needles, found);
        } else if fs::read_to_string(&path).is_ok_and(|text| {
            needles.iter().any(|needle| text.contains(needle))
        }) {
            found.push(path);
        }
    }
}

fn run(dir: &Path, program: &str, args: &[&str]) {
    let status = Command::new(program)
        .args(args)
        .current_dir(dir)
        .env("CARGO_TARGET_DIR", dir.join("target"))
        .status()
        .unwrap();
    assert!(
        status.success(),
        "{program} {args:?} failed in {}",
        dir.display()
    );
}

#[test]
#[ignore = "slow: builds a renamed copy of the workspace twice"]
fn renamed_copy_builds() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).parent().unwrap();
    let copy = std::env::temp_dir()
        .join(format!("xtask-rename-build-{}", std::process::id()));
    let _ = fs::remove_dir_all(&copy);
    copy_tree(root, &copy);

    let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".into());
    run(
        &copy,
        &cargo,
        &["xtask", "rename", "my-tool", "--owner", "someone-else"],
    );
    assert!(copy.join("crates/my-tool/Cargo.toml").is_file());
    assert!(copy.join("crates/my-tool-cli/Cargo.toml").is_file());

    let mut found = Vec::new();
    leftovers(
        &copy,
        &["rust-repo-template", "rust_repo_template", "idoudali"],
        &mut found,
    );
    assert!(found.is_empty(), "old names left in {found:?}");

    run(&copy, &cargo, &["build", "--workspace", "--locked"]);
    run(
        &copy,
        &cargo,
        &[
            "run",
            "--locked",
            "-q",
            "-p",
            "my-tool-cli",
            "--",
            "--version",
        ],
    );

    fs::remove_dir_all(&copy).unwrap();
}
