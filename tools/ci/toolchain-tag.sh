#!/usr/bin/env bash
# Prints the toolchain image tag, $IMAGE:<hash>. <hash> is the first 16 hex
# digits of a SHA-256 over every file that goes into the image and its smoke
# test, so any change to one of them gives a new tag.
#
# Usage: IMAGE=ghcr.io/<owner>/rust-repo-template-toolchain toolchain-tag.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
: "${IMAGE:?set IMAGE to the image name without a tag}"

inputs=(
  docker/toolchain.Dockerfile
  .dockerignore
  mise.toml
  mise.lock
  mise.msrv.toml
  rust-toolchain.toml
  docker/toolchain-smoke.sh
)
if command -v sha256sum > /dev/null; then
  hash=$(cat "${inputs[@]}" | sha256sum | cut -c1-16)
else
  hash=$(cat "${inputs[@]}" | shasum -a 256 | cut -c1-16)
fi
# GHCR names must be lowercase, and the owner part may not be.
echo "$(printf '%s' "$IMAGE" | tr '[:upper:]' '[:lower:]'):${hash}"
