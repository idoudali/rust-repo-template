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
| `verify`               | fmt, clippy, deny, typos, Markdown, tests, coverage, docs   |
| `hooks`                | Every git hook on all files (prek)                          |
| `package`              | Package the library and install the CLI                     |
| `rename-check`         | Run `cargo xtask rename` on a copy and build it (slow)      |

`MISE_ENV=msrv mise run check` type-checks on the minimum supported Rust version.

CI runs `hooks`, `test`, `coverage`, `docs`, `package`, `rename-check` and the MSRV check in one `checks (linux)` job, plus the conventional commit check on pull requests.

## Toolchain image

`docker/toolchain.Dockerfile` builds an Ubuntu image with every tool from `mise.toml` and the distro's default gcc. CI runs its Linux jobs inside it, and the dev container uses it. `mise run toolchain-build` and `mise run toolchain-shell` build and enter it locally, and `mise run toolchain-smoke` runs the image's smoke test.

CI tags the image with a hash of its inputs (`mise run toolchain-tag`) and builds it only when that tag is missing from GHCR (`mise run toolchain-resolve`). The workflow's shell steps are scripts in `tools/ci/`, so they run the same way locally.

## Git hooks and commits

`mise run hooks-install` installs the pre-commit hooks (formatting, clippy, deny, typos, Markdown, workflow linters) and a commit-msg hook that accepts only conventional commits.

## Coding agents

`AGENTS.md` is the source of truth for agents. Claude Code also runs rustfmt and clippy after each edit through `.claude/hooks/rust-after-edit.sh`.

## Documentation

Every public item needs a `///` doc comment; `missing_docs` and `rustdoc -D warnings` enforce it. Guides like this one live in `crates/rust-repo-template/docs/` and are included as doc-only modules under `guide`.
