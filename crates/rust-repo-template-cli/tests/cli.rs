//! End-to-end tests that run the compiled `rust-repo-template` binary.

use assert_cmd::cargo::cargo_bin_cmd;
use predicates::str::contains;

#[test]
fn version_flag_prints_name_and_version() {
    cargo_bin_cmd!("rust-repo-template")
        .arg("--version")
        .assert()
        .success()
        .stdout(format!(
            "rust-repo-template {}\n",
            rust_repo_template::VERSION
        ));
}

#[test]
fn help_flag_succeeds() {
    cargo_bin_cmd!("rust-repo-template")
        .arg("--help")
        .assert()
        .success()
        .stdout(contains("Usage: rust-repo-template"));
}

#[test]
fn no_arguments_succeeds() {
    cargo_bin_cmd!("rust-repo-template").assert().success();
}

#[test]
fn unknown_flag_fails() {
    cargo_bin_cmd!("rust-repo-template")
        .arg("--no-such-flag")
        .assert()
        .failure()
        .code(2);
}
