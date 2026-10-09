# rust-repo-template

A template for Rust command-line projects: a Cargo workspace with a library crate and a CLI crate, strict lints, a coverage gate, git hooks, agent support, CI, rustdoc, and per-platform release binaries.

## Quick start

```bash
cargo run --locked -p rust-repo-template-cli -- --version
```

The toolchain version comes from `rust-toolchain.toml`; `rustup` installs it on first use.

## Layout

| Path                            | What it is                                     |
| ------------------------------- | ---------------------------------------------- |
| `crates/rust-repo-template`     | Library crate `rust_repo_template`: the logic  |
| `crates/rust-repo-template-cli` | Binary `rust-repo-template`: the clap CLI      |
| `rust-toolchain.toml`           | Pinned Rust toolchain                          |

## License

Apache-2.0. See [`LICENSE`](./LICENSE).
