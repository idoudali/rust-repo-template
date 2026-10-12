#!/usr/bin/env bash
# Runs docker/toolchain-smoke.sh inside a toolchain image.
#
# Usage: toolchain-smoke.sh [IMAGE_REF]   (default: $IMAGE:local)
set -euo pipefail
cd "$(dirname "$0")/../.."
image=${1:-${IMAGE:?pass an image reference or set IMAGE}:local}
docker run --rm -v "${PWD}/docker/toolchain-smoke.sh:/ci/toolchain-smoke.sh:ro" "$image" bash /ci/toolchain-smoke.sh
