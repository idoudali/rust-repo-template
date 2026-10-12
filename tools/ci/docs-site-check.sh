#!/usr/bin/env bash
# Checks the assembled docs site in target/site: the book is the home page,
# the crate's rustdoc sits under api/, and every api/ link in the book pages
# resolves. The book links into api/ by relative path, and mdBook cannot
# verify those, so this is the only place a broken one is caught.
#
# Usage: docs-site-check.sh   (run from the repo root, after docs-site.sh)
set -euo pipefail
site=target/site
lib=$(cargo metadata --no-deps --format-version 1 |
  jq -r '.packages[].targets[] | select(.kind[] == "lib") | .name')
fail() {
  echo "docs-site-check: $1" >&2
  exit 1
}
[ -n "$lib" ] && [ "$(printf '%s\n' "$lib" | wc -l)" -eq 1 ] ||
  fail "expected exactly one lib target, got: '$lib'"
[ -f "$site/index.html" ] || fail "$site/index.html is missing"
grep -q '<title>' "$site/index.html" ||
  fail "$site/index.html has no <title>; it is not the book"
[ -f "$site/api/$lib/index.html" ] || fail "$site/api/$lib/index.html is missing"
for page in "$site"/*.html; do
  # grep exits 1 when a page has no api/ links, which is fine.
  for href in $(grep -o 'href="api/[^"]*"' "$page" || true); do
    path=${href#href=\"}
    path=${path%\"}
    path=${path%%#*}
    [ -f "$site/$path" ] || fail "$(basename "$page") links to missing $path"
  done
done
echo "docs site OK: book at $site/index.html, API at $site/api/$lib/"
