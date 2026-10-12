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
3. Run `mise run verify` for the main checks (it includes the git hooks, so the workflow and shell linters too). `mise run ci` runs exactly what CI runs, adding packaging, the MSRV and the template rename check (`mise run rename-check`); CI also checks the commit messages.
4. Commit with [conventional commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `build:`, `ci:`, `test:`, `refactor:`, `chore:`). release-plz builds the changelog and the next version from them.
5. Open a PR against `main`. CI skips draft PRs; it runs once the PR is marked ready for review.

## Code style

The coding standard is in [`AGENTS.md`](./AGENTS.md), for people and coding agents alike.

## Releases

Maintainers cut releases with `mise run release` and `mise run release-tag`; see the [releasing guide](./docs/src/releasing.md).
