# Getting started

## Install the toolchain

Every tool version is pinned in `mise.toml`. Either open the repo in the dev container (it uses the toolchain image), or install [mise](https://mise.jdx.dev) and run:

```bash
mise trust
mise install
mise run hooks-install
```

## Build and run

```bash
cargo run -p rust-repo-template-cli -- --help
```

## Use the library

```rust
println!("rust-repo-template {}", rust_repo_template::VERSION);
```
