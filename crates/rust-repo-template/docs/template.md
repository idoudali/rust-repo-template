# Starting a project from the template

## 1. Create the repo

On GitHub, choose **Use this template**, then clone the new repo. The button appears only while the template repo has **Settings → General → Template repository** checked.

## 2. Rename

```bash
cargo xtask rename my-tool --owner my-github-user --dry-run   # preview
cargo xtask rename my-tool --owner my-github-user
```

This replaces `rust-repo-template` and `rust_repo_template` in every file, moves `crates/rust-repo-template*` to `crates/my-tool*`, and with `--owner` points GitHub, GHCR and Pages links at the new owner. It skips `.git`, `target`, and the `xtask` crate itself. Then update `authors` in `Cargo.toml`, the README description, and `CHANGELOG.md`, run `mise run verify`, and commit.

`mise run rename-check` does the same on a scratch copy of the repo and builds the result; CI runs it on every pull request, so the rename keeps working as the template changes.

## 3. Repository settings

| Setting                             | Where                                                   | Why                                                                                               |
| ----------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Toolchain image visibility: public  | Your profile → Packages → `<name>-toolchain` → Settings | The first CI run publishes it private. Forks, the dev container, and `docker pull` need it public |
| Actions can create PRs              | Settings → Actions → General → Workflow permissions     | release-plz and the toolchain bump open PRs                                                       |
| Pages source: GitHub Actions        | Settings → Pages                                        | `pages.yml` deploys the rustdoc site                                                              |
| Ruleset on `main`                   | Settings → Rules → Rulesets                             | Require a PR, the status checks below, and no force pushes                                        |
| Release App (optional, recommended) | Settings → Secrets and variables → Actions              | `RELEASE_APP_ID` variable and `RELEASE_APP_PRIVATE_KEY` secret; see below                         |

Required status checks for the ruleset: `hooks (prek)`, `test and coverage (linux)`, `rustdoc`, `package and install`, `cargo deny`, `msrv (Rust 1.85)`, `zizmor (workflow audit)`, `conventional commits`, and the three `test (<os>)` jobs.

## 4. Release token

PRs opened with the default `GITHUB_TOKEN` do not trigger other workflows, so the release-plz Release PR would sit without CI. Create a GitHub App owned by you with **Contents** and **Pull requests** set to read and write, install it on the repo, then save its id as the `RELEASE_APP_ID` variable and a private key as the `RELEASE_APP_PRIVATE_KEY` secret. `release-plz.yml` uses the App token when the variable is set and falls back to `GITHUB_TOKEN` otherwise.

## 5. Optional cleanup

- Delete the example commands in the CLI crate and their tests once the real ones exist; the coverage gate stays at 100%.
- Keep `xtask`: it is not built into releases, and future maintenance tasks belong there.
