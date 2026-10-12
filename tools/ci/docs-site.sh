#!/usr/bin/env bash
# Assembles the docs site in target/site: the mdBook output (target/book) is
# the site root and the rustdoc output (target/doc) goes under api/, so one
# Pages artifact serves both. Run `mdbook build docs` and `cargo doc` first.
#
# Usage: docs-site.sh   (run from the repo root)
set -euo pipefail
rm -rf target/site
cp -R target/book target/site
cp -R target/doc target/site/api
# Make /api/ land on the crate page, as the rustdoc-only site did at its root.
lib=$(cargo metadata --no-deps --format-version 1 |
  jq -r '.packages[].targets[] | select(.kind[] == "lib") | .name')
echo "<meta http-equiv=\"refresh\" content=\"0; url=$lib/index.html\">" \
  > target/site/api/index.html
