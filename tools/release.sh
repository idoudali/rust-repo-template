#!/usr/bin/env bash
# Cuts a release in two steps, both run from an up-to-date main:
#
#   release.sh prepare [VERSION]  bump the workspace version, Cargo.lock and
#                                 CHANGELOG.md with release-plz, push the
#                                 release/v<version> branch and open its PR
#   release.sh tag                after that PR merges: tag main with
#                                 v<version> from Cargo.toml and push the tag
#
# release-plz picks the next version from the conventional commits since the
# last v* tag; pass VERSION (say 0.2.0 or 0.2.0-rc.1) to choose it instead.
# The tag starts dist's release.yml, which builds and publishes the GitHub
# Release. The tag is pushed with your own credentials, so, unlike a tag
# pushed with a workflow's GITHUB_TOKEN, it does start release.yml.
set -euo pipefail
cd "$(dirname "$0")/.."

die() {
  echo "release: $*" >&2
  exit 1
}

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# The workspace version, which every released crate inherits.
workspace_version() {
  sed -n '/^\[workspace\.package\]/,/^\[/s/^version = "\(.*\)"/\1/p' Cargo.toml
}

# Fails unless the tree is clean and HEAD is main at origin/main.
require_synced_main() {
  [[ -z "$(git status --porcelain)" ]] || die "the working tree is not clean"
  [[ "$(git branch --show-current)" == main ]] || die "check out main first"
  git fetch --quiet --tags origin main
  [[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] ||
    die "main is not at origin/main; run git pull --ff-only"
}

# Prints the CHANGELOG.md section of version $1, without its heading.
changelog_section() {
  awk -v v="$1" '
    index($0, "## [" v "]") == 1 { on = 1; next }
    on && /^## \[/ { exit }
    on
  ' CHANGELOG.md
}

prepare() {
  local requested="${1:-}"
  if [[ -n "$requested" ]]; then
    [[ "$requested" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] ||
      die "$requested is not a semver version"
  fi
  require_synced_main
  local current
  current=$(workspace_version)

  release-plz update
  local version
  version=$(workspace_version)
  [[ "$version" != "$current" ]] ||
    die "release-plz found nothing to release since the last tag"

  # release-plz set-version expects a CHANGELOG.md per crate, so a chosen
  # version replaces the computed one by hand.
  if [[ -n "$requested" && "$requested" != "$version" ]]; then
    # Only the workspace version and the library's workspace dependency.
    sed -i.bak -E "/^(version|rust-repo-template) = /s/\"$version\"/\"$requested\"/" \
      Cargo.toml
    rm Cargo.toml.bak
    # The new entry's heading and its compare link.
    awk -v old="$version" -v new="$requested" '
      !done && index($0, "## [" old "]") == 1 {
        sub("\\[" old "\\]", "[" new "]")
        sub("\\.\\.\\.v" old "\\)", "...v" new ")")
        done = 1
      }
      { print }
    ' CHANGELOG.md > CHANGELOG.md.tmp
    mv CHANGELOG.md.tmp CHANGELOG.md
    cargo update --workspace --offline --quiet
    version=$requested
  fi
  [[ -n "$(changelog_section "$version")" ]] ||
    die "CHANGELOG.md has no entry for $version"

  local branch="release/v$version"
  git switch --quiet --create "$branch"
  git commit --quiet --all --message "chore(release): v$version"
  git push --quiet --set-upstream origin "$branch"
  # The backticks in the body are Markdown, not a command substitution.
  # shellcheck disable=SC2016
  gh pr create --base main --head "$branch" \
    --title "chore(release): v$version" \
    --body "$(printf 'Merging this PR releases v%s. Then run `mise run release-tag` on main.\n\n%s\n' \
      "$version" "$(changelog_section "$version")")"
  git switch --quiet main
}

tag() {
  require_synced_main
  local version
  version=$(workspace_version)
  local tag="v$version"
  if git rev-parse --quiet --verify "refs/tags/$tag" > /dev/null; then
    die "$tag already exists; run mise run release first"
  fi
  [[ -n "$(changelog_section "$version")" ]] ||
    die "CHANGELOG.md has no entry for $version; merge the release PR first"
  git tag --annotate "$tag" --message "$tag"
  git push --quiet origin "$tag"
  echo "Pushed $tag; release.yml now builds the release:"
  echo "  gh run list --workflow release.yml --limit 1"
}

case "${1:-}" in
  prepare) shift && prepare "$@" ;;
  tag) tag ;;
  -h | --help) usage ;;
  *) usage 1 >&2 ;;
esac
