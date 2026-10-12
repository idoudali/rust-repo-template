---
name: rust-style
description: Write Rust that already matches this repo's standard (edition 2024, 80 columns, clippy pedantic, documented public API). Use when writing or reviewing Rust, naming items, structuring modules, or when the user mentions style.
---

# Rust style

1. Read the "Coding standard" section of `AGENTS.md`, then `[workspace.lints]` in `Cargo.toml` and `rustfmt.toml`. Together they are the standard.
2. Write code that already matches it. Beyond what those say:
   - Logic in the library crate, thin `main` in the CLI crate.
   - Prefer borrowing (`&str`, `&[T]`) in parameters; take ownership only when stored.
3. After edits, use the `rust-lint` skill (or the commands in `AGENTS.md`).
4. If a requested style conflicts with clippy or rustfmt, keep the tools and tell the user.
