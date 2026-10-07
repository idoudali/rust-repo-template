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
3. Run `mise run verify`, which is everything CI runs.
4. Commit with [conventional commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `build:`, `ci:`, `test:`, `refactor:`, `chore:`). release-plz builds the changelog and the next version from them.
5. Open a PR against `main`.

## Code style

[`AGENTS.md`](./AGENTS.md) is the full set of rules, for people and coding agents alike. The short version: rustfmt at 80 columns, clippy pedantic with warnings denied, no `unsafe`, docs on every public item, and logic in the library crate with the CLI as a thin layer.

## Releases

Maintainers merge the Release PR that release-plz keeps open; see the [releasing guide](./crates/rust-repo-template/docs/releasing.md).
