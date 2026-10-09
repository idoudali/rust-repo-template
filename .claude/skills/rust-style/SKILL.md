---
name: rust-style
description: Write Rust that already matches this repo's standard (edition 2024, 80 columns, clippy pedantic, documented public API). Use when writing or reviewing Rust, naming items, structuring modules, or when the user mentions style.
---

# Rust style

1. Read `[workspace.lints]` in `Cargo.toml` and `rustfmt.toml`. That config is the standard.
2. Write code that already matches it:
   - Logic in the library crate, thin `main` in the CLI crate.
   - `///` docs on every public item, with an `# Examples` doctest on public functions.
   - `Result` for recoverable errors; no `unwrap()` outside tests and `main`.
   - No `unsafe`; it is forbidden workspace-wide.
   - Prefer borrowing (`&str`, `&[T]`) in parameters; take ownership only when stored.
3. After edits, use the `rust-lint` skill (or the commands in `AGENTS.md`).
4. If a requested style conflicts with clippy or rustfmt, keep the tools and tell the user.
