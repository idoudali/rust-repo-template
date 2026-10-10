# rust-repo-template

A template for Rust command-line projects: a Cargo workspace with a library crate and a CLI crate, strict lints, a coverage gate, git hooks, agent support, CI, rustdoc, and per-platform release binaries.

## Quick start

```bash
cargo run --locked -p rust-repo-template-cli -- --version
```

The toolchain version comes from `rust-toolchain.toml`; `rustup` installs it on first use.

## Toolchain

Every tool version lives in [`mise.toml`](./mise.toml). Pick one of:

- **Dev container or Docker:** the image in [`docker/toolchain.Dockerfile`](./docker/toolchain.Dockerfile) has everything installed. CI publishes it as `ghcr.io/idoudali/rust-repo-template-toolchain`, and the dev container uses the published `:main` tag. To build the image yourself instead, pick the "local build" dev container configuration, or run `mise run toolchain-build` then `mise run toolchain-shell`.
- **Host:** install [mise](https://mise.jdx.dev), then `mise trust && mise install` in the repo.

[`mise.lock`](./mise.lock) pins every tool's version. For tools downloaded as release assets (actionlint, shellcheck, cargo-binstall) it also pins the download URL and checksum for Linux, macOS, and Windows; Rust and the `cargo:` tools are pinned by version only. After changing `[tools]` in `mise.toml`, run `mise run lock` and commit both files.

`mise tasks` lists the available tasks. `MISE_ENV=msrv mise run <task>` runs a task on the minimum supported Rust version.

## Layout

| Path                            | What it is                                     |
| ------------------------------- | ---------------------------------------------- |
| `crates/rust-repo-template`     | Library crate `rust_repo_template`: the logic  |
| `crates/rust-repo-template-cli` | Binary `rust-repo-template`: the clap CLI      |
| `rust-toolchain.toml`           | Pinned Rust toolchain                          |
| `mise.toml`                     | Tool versions and tasks                        |
| `mise.lock`                     | Tool checksums and download URLs per platform  |
| `docker/`                       | Toolchain image                                |
| `tests/CI-infra/`               | Tests for the CI setup (image smoke test)      |

## Coding agents

[`AGENTS.md`](./AGENTS.md) holds the instructions every agent follows. Claude Code, Cursor, and Copilot each get a thin pointer to it, plus Claude hooks that run rustfmt and clippy after edits.

## License

Apache-2.0. See [`LICENSE`](./LICENSE).
