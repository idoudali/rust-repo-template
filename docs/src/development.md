# Development

## Tasks

All commands are mise tasks; `mise tasks` lists them.

| Task                   | What it does                                                |
| ---------------------- | ----------------------------------------------------------- |
| `fmt` / `fmt-check`    | Format, or check formatting                                 |
| `lint`                 | Clippy with the pedantic and cargo groups, warnings denied  |
| `test`                 | nextest plus doctests (quick loop, no coverage)             |
| `coverage`             | llvm-cov with a 100% line gate; HTML in `target/llvm-cov`   |
| `doctest`              | Doc tests only                                              |
| `test-xtask`           | xtask unit tests, which the coverage gate excludes          |
| `deny`                 | Advisories, licenses, bans and sources                      |
| `docs`                 | Book plus rustdoc in `target/site`, warnings denied         |
| `book`                 | Only the book, in `target/book`                             |
| `docs-serve`           | Serve the full site, rebuilding it when sources change      |
| `hooks`                | Every git hook on all files (prek): fmt, clippy, deny, typos, Markdown, workflow and shell linters |
| `verify`               | `hooks`, `coverage`, `doctest`, `test-xtask` and `docs`     |
| `package`              | Package the library and install the CLI                     |
| `rename-check`         | Run `cargo xtask rename` on a copy and build it (slow)      |
| `msrv`                 | Type-check on the minimum supported Rust version            |
| `ci`                   | `verify`, `package`, `rename-check` and `msrv`: what CI runs |
| `toolchain-bump`       | Open a PR moving the pinned Rust to the latest stable       |

The git hooks call the `fmt-check`, `lint` and `deny` tasks, so each command is defined once, in `mise.toml`.

CI's `checks (linux)` job runs `mise run ci`, so a green `mise run ci` locally predicts a green job. The job also runs the online zizmor audit and, on pull requests, the conventional commit check, and uploads the coverage report.

## Toolchain image

`docker/toolchain.Dockerfile` builds an Ubuntu image with every tool from `mise.toml` and the distro's default gcc. CI runs its Linux jobs inside it, and the dev container uses it. `mise run toolchain-build` and `mise run toolchain-shell` build and enter it locally, and `mise run toolchain-smoke` runs the image's smoke test.

CI tags the image with a hash of its inputs (`mise run toolchain-tag`) and builds it only when that tag is missing from GHCR (`mise run toolchain-resolve`). The workflow's shell steps are scripts in `tools/ci/`, so they run the same way locally.

## Git hooks and commits

`mise run hooks-install` installs the pre-commit hooks (formatting, clippy, deny, typos, Markdown, workflow linters) and a commit-msg hook that accepts only conventional commits.

## Coding agents

`AGENTS.md` is the source of truth for agents. Claude Code also runs rustfmt and clippy after each edit through `.claude/hooks/rust-after-edit.sh`.

## Documentation

Every public item needs a `///` doc comment; `missing_docs` and `rustdoc -D warnings` enforce it. Guides like this one live in `docs/src/` and build with `mise run book`.

`mise run docs-serve` builds the full site (book and API reference), serves it at <http://127.0.0.1:3000>, and rebuilds it whenever `docs/src`, `docs/book.toml`, the crates or the README change; reload the browser to see the result. A rebuild that fails, for example on a rustdoc warning, prints the error and keeps the last good site. `PORT` and `HOST` change where it listens, for example `PORT=8080 mise run docs-serve`.

Inside the dev container, `127.0.0.1` is not reachable from the host; run `HOST=0.0.0.0 mise run docs-serve` instead.
