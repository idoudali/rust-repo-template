#!/usr/bin/env bash
# Smoke test for the toolchain image: every tool in mise.toml runs and
# reports its version, and the default Rust is the one in mise.toml.
#
# toolchain-image.yml runs it inside each freshly built image:
#   docker run --rm -v "$PWD/tests/CI-infra:/ci:ro" toolchain:smoke \
#     bash /ci/toolchain-smoke.sh
set -euo pipefail
mise ls --current
gcc --version | head -n 1
rustc --version
# The default Rust must be the one in mise.toml, not the MSRV.
test "$(rustc --version | cut -d " " -f 2)" = "$(mise current rust)"
cargo clippy --version
cargo fmt --version
cargo nextest --version
cargo llvm-cov --version
cargo deny --version
cargo hack --version
dist --version
cargo cyclonedx --version
release-plz --version
cog --version
prek --version
typos --version
rumdl --version
zizmor --version
actionlint --version
shellcheck --version
rustup run 1.85.0 rustc --version
