# Starting a project from the template

## 1. Create the repo

On GitHub, choose **Use this template**, then clone the new repo. The button appears only while the template repo has **Settings → General → Template repository** checked.

## 2. Rename

```bash
cargo xtask rename my-tool --owner my-github-user --dry-run   # preview
cargo xtask rename my-tool --owner my-github-user
```

This replaces `rust-repo-template` and `rust_repo_template` in every file, moves `crates/rust-repo-template*` to `crates/my-tool*`, and with `--owner` points the GitHub, GHCR and Pages links at the new owner. It skips `.git`, `target`, `vendor`, `site`, and the `xtask` crate itself.

Pass `--owner` unless the new repo stays under the template's owner. The dev container pulls the toolchain image from the owner's GHCR, so without it the dev container uses the template's image.

Then update `authors` in `Cargo.toml`, the README description, and `CHANGELOG.md`, run `mise run verify`, and commit.

`mise run rename-check` does the same on a scratch copy of the repo and builds the result. CI runs it in the `checks (linux)` job on every pull request, so the rename keeps working as the template changes.

## 3. Repository settings

| Setting                             | Where                                                   | Why                                                                                               |
| ----------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Toolchain image visibility: public  | Your profile → Packages → `<name>-toolchain` → Settings | The first CI run publishes it private. Forks, the dev container, and `docker pull` need it public |
| Pages source: GitHub Actions        | Settings → Pages                                        | `pages.yml` deploys the docs site (repo book and API reference)                                   |
| Ruleset on `main`                   | Settings → Rules → Rulesets                             | Require a PR, the status checks below, and no force pushes                                        |

Required status check for the ruleset: `checks (linux)`. It is one job that runs `mise run ci` (hooks, tests with the coverage gate, docs, packaging, the rename check, MSRV), the online zizmor audit, and conventional commits. CI skips draft pull requests, so the check starts once a PR is marked ready for review. macOS, Windows, and Linux arm64 are tested only on release tags, by `release-checks.yml`, which blocks the release if they fail.

## 4. Optional cleanup

- Delete the example commands in the CLI crate and their tests once the real ones exist; the coverage gate stays at 100%.
- Keep `xtask`: it is not built into releases, and future maintenance tasks belong there.
