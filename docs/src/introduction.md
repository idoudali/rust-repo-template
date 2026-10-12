# Introduction

A template for Rust command-line projects: a Cargo workspace with a library crate and a CLI crate, strict lints, a coverage gate, git hooks, agent support, CI, rustdoc, and per-platform release binaries.

## Layout

| Path                            | What it is                                     |
| ------------------------------- | ---------------------------------------------- |
| `crates/rust-repo-template`     | Library crate `rust_repo_template`: the logic  |
| `crates/rust-repo-template-cli` | Binary `rust-repo-template`: the clap CLI      |
| `xtask`                         | Repo tasks: `cargo xtask rename`               |
| `rust-toolchain.toml`           | Pinned Rust toolchain                          |
| `mise.toml`                     | Tool versions and tasks                        |
| `mise.lock`                     | Tool checksums and download URLs per platform  |
| `docker/`                       | Toolchain image                                |
| `tests/CI-infra/`               | Tests for the CI setup (image smoke test)      |
| `tools/ci/`                     | Shell scripts CI runs, also wrapped as tasks   |

For the library API, see the [API reference](api/rust_repo_template/index.html).
