#!/usr/bin/env bash
# Publishes the multi-arch toolchain image: joins the per-arch images pushed by
# digest into one manifest list tagged $TAG, optionally points extra tags at
# it, then prints its digest reference as image=name@sha256:digest (appended to
# $GITHUB_OUTPUT when set).
#
# Usage: TAG=name:hash toolchain-publish.sh DIGEST_DIR [EXTRA_TAG...]
#   DIGEST_DIR holds one empty file per per-arch digest, named by its hex
#   digits. When it is empty, $TAG must already exist and only the extra tags
#   are set. EXTRA_TAG is a bare tag such as `main`; empty ones are ignored.
set -euo pipefail
: "${TAG:?set TAG to the image tag (name:hash)}"
digest_dir=${1:?usage: toolchain-publish.sh DIGEST_DIR [EXTRA_TAG...]}
shift
repo=${TAG%:*}

shopt -s nullglob
sources=()
for file in "$digest_dir"/*; do
  sources+=("${repo}@sha256:$(basename "$file")")
done
if [ ${#sources[@]} -gt 0 ]; then
  docker buildx imagetools create -t "$TAG" "${sources[@]}"
fi
for extra in "$@"; do
  [ -n "$extra" ] || continue
  docker buildx imagetools create -t "${repo}:${extra}" "$TAG"
done
docker buildx imagetools inspect "$TAG" >&2
# Fails the job if the tag cannot be read back, rather than output no image.
digest=$(docker buildx imagetools inspect "$TAG" --format '{{json .Manifest}}' | jq -er .digest)
echo "image=${repo}@${digest}" >> "${GITHUB_OUTPUT:-/dev/stdout}"
