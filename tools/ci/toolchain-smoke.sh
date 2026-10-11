#!/usr/bin/env bash
# Runs tests/CI-infra/toolchain-smoke.sh inside a toolchain image.
#
# Usage: toolchain-smoke.sh [IMAGE_REF]   (default: $IMAGE:local)
set -euo pipefail
cd "$(dirname "$0")/../.."
image=${1:-${IMAGE:?pass an image reference or set IMAGE}:local}
docker run --rm -v "${PWD}/tests/CI-infra:/ci:ro" "$image" bash /ci/toolchain-smoke.sh
