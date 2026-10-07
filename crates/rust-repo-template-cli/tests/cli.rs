//! End-to-end tests that run the compiled `rust-repo-template` binary.

use assert_cmd::cargo::cargo_bin_cmd;
use predicates::str::contains;

fn bin() -> assert_cmd::Command {
    cargo_bin_cmd!("rust-repo-template")
}

#[test]
fn version_flag_prints_name_and_version() {
    bin().arg("--version").assert().success().stdout(format!(
        "rust-repo-template {}\n",
        rust_repo_template::VERSION
    ));
}

#[test]
fn help_lists_commands() {
    bin()
        .arg("--help")
        .assert()
        .success()
        .stdout(contains("greet"))
        .stdout(contains("info"));
}

#[test]
fn no_command_prints_usage_and_fails() {
    bin()
        .assert()
        .failure()
        .code(2)
        .stderr(contains("Usage: rust-repo-template"));
}

#[test]
fn unknown_flag_fails() {
    bin().arg("--no-such-flag").assert().failure().code(2);
}

#[test]
fn greet_once() {
    bin()
        .args(["greet", "Ada"])
        .assert()
        .success()
        .stdout("Hello, Ada!\n");
}

#[test]
fn greet_count_and_shout() {
    bin()
        .args(["greet", "Ada", "--count", "3", "--shout"])
        .assert()
        .success()
        .stdout("HELLO, ADA!\nHELLO, ADA!\nHELLO, ADA!\n");
}

#[test]
fn greet_rejects_zero_count() {
    bin()
        .args(["greet", "Ada", "-c", "0"])
        .assert()
        .failure()
        .code(2)
        .stderr(contains("--count"));
}

#[test]
fn greet_requires_a_name() {
    bin().arg("greet").assert().failure().code(2);
}

#[test]
fn info_prints_text() {
    bin()
        .arg("info")
        .assert()
        .success()
        .stdout(contains(format!(
            "version: {}",
            rust_repo_template::VERSION
        )))
        .stdout(contains(format!("os:      {}", std::env::consts::OS)));
}

#[test]
fn info_prints_json() {
    let expected =
        format!("{}\n", rust_repo_template::Info::current().to_json());
    bin()
        .args(["info", "--json"])
        .assert()
        .success()
        .stdout(expected);
}
