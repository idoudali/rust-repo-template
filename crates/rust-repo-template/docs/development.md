# Development

## Tasks

All commands are mise tasks; `mise tasks` lists them.

| Task                   | What it does                                                |
| ---------------------- | ----------------------------------------------------------- |
| `fmt` / `fmt-check`    | Format, or check formatting                                 |
| `lint`                 | Clippy with the pedantic and cargo groups, warnings denied  |
| `test`                 | nextest plus doctests                                       |
| `coverage`             | llvm-cov with a 100% line gate; HTML in `target/llvm-cov`   |
| `deny`                 | Advisories, licenses, bans and sources                      |
| `docs`                 | This documentation, with rustdoc warnings denied            |
| `verify`               | Everything CI runs                                          |
| `hooks`                | Every git hook on all files (prek)                          |

`MISE_ENV=msrv mise run check` type-checks on the minimum supported Rust version.

## Toolchain image

`docker/toolchain.Dockerfile` builds an Ubuntu image with every tool from `mise.toml` and the distro's default gcc. CI runs its Linux jobs inside it, and the dev container uses it. `mise run toolchain-build` and `mise run toolchain-shell` build and enter it locally.

## Git hooks and commits

`mise run hooks-install` installs the pre-commit hooks (formatting, clippy, deny, typos, Markdown, workflow linters) and a commit-msg hook that accepts only conventional commits.

## Coding agents

`AGENTS.md` is the source of truth for agents. Claude Code also runs rustfmt and clippy after each edit through `.claude/hooks/rust-after-edit.sh`.

## Documentation

Every public item needs a `///` doc comment; `missing_docs` and `rustdoc -D warnings` enforce it. Guides like this one live in `crates/rust-repo-template/docs/` and are included as doc-only modules under `guide`.
