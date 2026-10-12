# Contributing

## Setup

Open the repo in the dev container, or install [mise](https://mise.jdx.dev) and run:

```bash
mise trust
mise install
mise run hooks-install
```

The hooks run formatting, lints, spelling, workflow audits, and a conventional-commit check on every commit. Do not skip them with `--no-verify`; CI runs the same checks.

## Making a change

1. Branch from `main`.
2. Make the change with tests. Line coverage must stay at 100% (`mise run coverage`).
3. Run `mise run verify` for the main checks, and `mise run hooks` for the workflow and shell linters. CI also checks packaging, the MSRV, the template rename (`mise run rename-check`), and the commit messages.
4. Commit with [conventional commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `build:`, `ci:`, `test:`, `refactor:`, `chore:`). release-plz builds the changelog and the next version from them.
5. Open a PR against `main`. CI skips draft PRs; it runs once the PR is marked ready for review.

## Code style

[`AGENTS.md`](./AGENTS.md) is the full set of rules, for people and coding agents alike. The short version: rustfmt at 80 columns, clippy pedantic with warnings denied, no `unsafe`, docs on every public item, and logic in the library crate with the CLI as a thin layer.

## Releases

Maintainers merge the Release PR that release-plz keeps open; see the [releasing guide](./crates/rust-repo-template/docs/releasing.md).
