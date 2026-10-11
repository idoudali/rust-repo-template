#!/usr/bin/env bash
# Checks that every non-merge commit in BASE..HEAD has a conventional commit
# message. `cog check A..B` also checks A itself, so each commit is verified
# on its own.
#
# Usage: check-commits.sh [BASE]   (default: origin/main)
set -euo pipefail
base=${1:-origin/main}
# Inside a repository cog reads the git identity and aborts when it is unset,
# as on a CI checkout; developers' own identity is left alone.
git config user.name > /dev/null || git config user.name ci
git config user.email > /dev/null || git config user.email ci@localhost
# A separate assignment so a bad BASE fails here instead of checking nothing.
commits=$(git rev-list --no-merges "${base}..HEAD")
for commit in $commits; do
  git log -1 --format='%h %s' "$commit"
  cog verify "$(git log -1 --format=%B "$commit")" > /dev/null
done
