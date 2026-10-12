#!/usr/bin/env bash
# Smoke test for the toolchain image: every tool in mise.toml runs and
# reports its version, and the default Rust is the one in mise.toml.
#
# toolchain-image.yml runs it inside each freshly built image:
#   docker run --rm -v "$PWD/docker/toolchain-smoke.sh:/ci/toolchain-smoke.sh:ro" \
#     toolchain:smoke bash /ci/toolchain-smoke.sh
# or `mise run toolchain-smoke`.
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
mdbook --version
miniserve --version
zizmor --version
actionlint --version
shellcheck --version
# The MSRV toolchain (mise.msrv.toml) is installed beside the default and
# nothing else is: exactly two toolchains, and both run. The repo is not in the
# image, so this avoids repeating the MSRV number; `mise run toolchain-check`
# keeps the number itself consistent in the repo.
toolchains=$(rustup toolchain list | cut -d " " -f 1)
test "$(echo "$toolchains" | wc -l)" -eq 2
for toolchain in $toolchains; do
  rustup run "$toolchain" rustc --version
done
