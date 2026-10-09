# Agent instructions

This file is the source of truth for every coding agent (Claude Code, Cursor, Codex, Copilot, and others). `CLAUDE.md`, `.cursor/rules/`, and `.github/copilot-instructions.md` only point here. Keep it short; details live in `Cargo.toml`, `mise.toml`, and the lint configs.

## Environment

- Every tool and its version comes from `mise.toml`. Run commands through mise tasks (`mise run <task>`) or inside the toolchain image (`docker/toolchain.Dockerfile`, also the dev container). Never install tools ad hoc with `cargo install`, `apt`, or `brew`.
- Rust is pinned in `rust-toolchain.toml`. The minimum supported version is `rust-version` in `Cargo.toml`; `MISE_ENV=msrv mise run <task>` runs a task on it.
- Add a dependency to `[workspace.dependencies]` in the root `Cargo.toml`, then reference it with `.workspace = true` from the crate. Never edit `Cargo.lock` by hand; commit it.

## Layout

| Path                            | What goes there                                       |
| ------------------------------- | ----------------------------------------------------- |
| `crates/rust-repo-template`     | Library crate: all logic, pure and unit-tested        |
| `crates/rust-repo-template-cli` | Binary: argument parsing and output only              |
| `crates/*/tests/`               | Integration tests (`assert_cmd` for the CLI)          |
| `mise.toml`                     | Tool versions and tasks; `mise tasks` lists them      |

## Coding standard

- Edition 2024, `rustfmt` with `max_width = 80`. Clippy `pedantic` and `cargo` groups are on; CI denies every warning.
- `unsafe_code` is forbidden. Every public item needs a `///` doc comment (`missing_docs`); it becomes the rustdoc API reference.
- Public functions get an `# Examples` section that compiles as a doctest.
- Return `Result` for recoverable errors; no `unwrap()` or `expect()` outside tests and `main`.
- Do not reformat files the task did not change.

## Verify loop (run after every Rust edit)

```bash
mise run fmt        # format
mise run verify     # everything CI checks: fmt-check, clippy, deny, typos, Markdown lint, tests, coverage
```

Faster inner loop: `mise run lint test`. A change is not done while any check fails. Fix the code rather than adding `#[allow(...)]`; if an allow is truly needed, put it on the smallest item and add a comment saying why.

Coverage is gated at 100% of lines. New code needs tests in the same change.

## Commits

- Conventional commits (`feat:`, `fix:`, `docs:`, `build:`, `ci:`, `test:`, `refactor:`, `chore:`). The commit-msg hook (`cog verify`) rejects anything else, and release-plz builds the changelog from them.
- Install hooks once per clone: `mise run hooks-install`.

## Safety

- Do not commit `target/`, secrets, or `.claude/settings.local.json`.
- Do not force-push `main`.
