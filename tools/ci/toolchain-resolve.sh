#!/usr/bin/env bash
# Looks up the toolchain image tag in the registry and prints, as key=value
# lines (appended to $GITHUB_OUTPUT when set):
#   tag     name:hash
#   repo    name without the tag
#   exists  true if the tag is already in the registry
#   image   name@sha256:digest, only when it exists
#
# Usage: IMAGE=... toolchain-resolve.sh   (computes the tag)
#        TAG=name:hash toolchain-resolve.sh
set -euo pipefail
tag=${TAG:-$("$(dirname "$0")/toolchain-tag.sh")}
out=${GITHUB_OUTPUT:-/dev/stdout}

{
  echo "tag=${tag}"
  echo "repo=${tag%:*}"
} >> "$out"
if digest=$(docker buildx imagetools inspect "$tag" --format '{{json .Manifest}}' 2> /dev/null | jq -er .digest); then
  {
    echo "exists=true"
    echo "image=${tag%:*}@${digest}"
  } >> "$out"
  echo "Found ${tag} (${digest})" >&2
else
  echo "exists=false" >> "$out"
  echo "Not in the registry: ${tag}" >&2
fi
