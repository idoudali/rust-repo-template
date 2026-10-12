#!/usr/bin/env bash
# Moves the pinned Rust to the latest stable release and opens a PR for it.
# Run from an up-to-date main:
#
#   toolchain-bump.sh
#
# Updates channel in rust-toolchain.toml and the rust version in mise.toml,
# refreshes mise.lock, checks the two pins agree, then pushes a
# build/rust-<version> branch and opens its PR. Does nothing when the pin is
# already the latest stable. Dependabot does not track the toolchain, so run
# this when a new stable Rust ships. The PR is opened with your own
# credentials, so CI starts on it.
set -euo pipefail
cd "$(dirname "$0")/.."

die() {
  echo "toolchain-bump: $*" >&2
  exit 1
}

usage() {
  sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# Fails unless the tree is clean and HEAD is main at origin/main.
require_synced_main() {
  [[ -z "$(git status --porcelain)" ]] || die "the working tree is not clean"
  [[ "$(git branch --show-current)" == main ]] || die "check out main first"
  git fetch --quiet --tags origin main
  [[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] ||
    die "main is not at origin/main; run git pull --ff-only"
}

# Prints the latest stable Rust version, installing that toolchain if needed.
latest_stable() {
  rustup toolchain install stable --profile minimal --no-self-update > /dev/null
  rustc +stable --version | cut -d' ' -f2
}

bump() {
  require_synced_main
  local current version
  current=$(sed -n 's/^channel = "\(.*\)"/\1/p' rust-toolchain.toml)
  version=$(latest_stable)
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
    die "unexpected stable version: $version"
  if [[ "$current" == "$version" ]]; then
    echo "Already on Rust $version"
    exit 0
  fi
  local branch="build/rust-$version"
  if git ls-remote --exit-code --heads origin "$branch" > /dev/null; then
    die "$branch already exists on origin"
  fi

  # Portable in-place edits: BSD sed needs a backup suffix.
  sed -i.bak "s/^channel = \".*\"/channel = \"$version\"/" rust-toolchain.toml
  sed -i.bak "/^rust = /s/version = \"[^\"]*\"/version = \"$version\"/" mise.toml
  rm rust-toolchain.toml.bak mise.toml.bak
  mise lock rust
  mise run toolchain-check

  git switch --quiet --create "$branch"
  git commit --quiet --all --message "build: bump Rust toolchain to $version"
  git push --quiet --set-upstream origin "$branch"
  gh pr create --base main --head "$branch" \
    --title "build: bump Rust toolchain to $version" \
    --body "Moves rust-toolchain.toml, mise.toml and mise.lock from $current to $version. The toolchain image rebuilds in CI."
  git switch --quiet main
}

case "${1:-}" in
  "") bump ;;
  -h | --help) usage ;;
  *) usage 1 >&2 ;;
esac
