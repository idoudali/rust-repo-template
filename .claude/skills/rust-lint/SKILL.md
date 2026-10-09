---
name: rust-lint
description: Run rustfmt, clippy, cargo-deny, the tests and the coverage gate the project way. Use after Rust edits, before a commit or PR, or when the user mentions lint, format, clippy, deny, or failing checks.
---

# Rust lint and checks

Run from the repo root. Use the mise tasks so the pinned tool versions are used.

```bash
mise run fmt          # rewrite formatting
mise run lint         # clippy, pedantic + cargo groups, -D warnings
mise run test         # nextest + doctests
mise run verify       # everything CI runs, including deny and the 100% coverage gate
```

On a small change, `mise run fmt lint test` is enough before handing back; run `verify` before a commit.

## Rules

- A non-zero exit means the task is not finished. Fix the code; do not remove the check.
- Do not install tools with `cargo install`; they come from `mise.toml`.
- Do not add `#[allow(...)]` without a comment saying why, on the smallest item possible.
- If coverage drops below 100%, add tests for the uncovered lines (`target/llvm-cov/html` shows them).

## Output

Report which tasks ran and whether each passed. Quote the first failing lint name (for example `clippy::needless_pass_by_value`) when asking the user about a waiver.
