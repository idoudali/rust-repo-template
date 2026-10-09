#!/usr/bin/env bash
# Claude Code hook: format and lint Rust with the project's own toolchain.
#
#   PostToolUse (Write|Edit)  -> rustfmt on the edited .rs file, then clippy;
#                               exits 2 with findings on stderr.
#   Stop (--all-check)        -> fmt-check and clippy on the whole workspace;
#                               exits 2 to keep the turn going until clean.
#
# Exit 2 is deliberate: on PostToolUse and Stop it is the only exit code whose
# stderr Claude reads. See https://code.claude.com/docs/en/hooks-guide

set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-.}"
cd "$ROOT" || exit 0

if ! command -v cargo >/dev/null 2>&1; then
  # No toolchain: stay silent rather than breaking the session.
  exit 0
fi
if ! command -v jq >/dev/null 2>&1; then
  # jq comes from mise.toml like every other tool; without it the hook cannot
  # read its input, so say so once and step aside.
  echo "rust-after-edit: jq not found; run 'mise install' to enable this hook" >&2
  exit 0
fi

stdin_json="$(cat 2>/dev/null || true)"

json_field() {
  # json_field <json> <jq path>; prints the value, or nothing when it is
  # missing, null or false.
  printf '%s' "$1" | jq -r "$2 // empty" 2>/dev/null
}

clippy() {
  cargo clippy --workspace --all-targets --all-features --locked \
    --message-format short -- -D warnings 2>&1 | grep -E '(^|: )(error|warning)' || true
}

# ---------------------------------------------------------------- Stop event
if [[ "${1:-}" == "--all-check" ]]; then
  # Bail out on a repeated Stop so an unfixable finding cannot loop forever.
  if [[ "$(json_field "$stdin_json" .stop_hook_active)" == "true" ]]; then
    exit 0
  fi
  fmt="$(cargo fmt --all --check 2>&1)" && fmt_ok=1 || fmt_ok=0
  findings="$(clippy)"
  if [[ "$fmt_ok" == 1 && -z "$findings" ]]; then
    exit 0
  fi
  {
    echo "Rust checks are not clean. Fix these before finishing:"
    [[ "$fmt_ok" == 1 ]] || printf '%s\n' "$fmt"
    [[ -z "$findings" ]] || printf '%s\n' "$findings"
    echo "Run: mise run fmt && mise run lint"
  } >&2
  exit 2
fi

# ---------------------------------------------------------- PostToolUse event
path="$(json_field "$stdin_json" .tool_input.file_path)"
case "${path:-}" in
  *.rs) ;;
  *) exit 0 ;;
esac
[[ -f "$path" ]] || exit 0

rustfmt --edition 2024 "$path" >/dev/null 2>&1 || true

findings="$(clippy)"
if [[ -z "$findings" ]]; then
  exit 0
fi
{
  echo "clippy reports issues after editing $path:"
  printf '%s\n' "$findings"
} >&2
exit 2
