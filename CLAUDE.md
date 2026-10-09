# Claude Code

Read and follow [`AGENTS.md`](./AGENTS.md); it is the source of truth for commands, layout, and standards in this repo.

- A `PostToolUse` hook runs `rustfmt` on each edited `.rs` file and reports remaining clippy findings. Treat that output as work to do.
- Before finishing, run `mise run verify`. The `Stop` hook runs the fast part of it (`fmt-check` and clippy) and blocks until it passes.
- Skills: `rust-lint` (run the checks) and `rust-style` (write code that already passes them).
