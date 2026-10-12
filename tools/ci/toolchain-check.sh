#!/usr/bin/env bash
# Fails when a version pinned in more than one place disagrees:
#   - Rust: rust-toolchain.toml and mise.toml.
#   - MSRV: Cargo.toml rust-version (major.minor) and both lines of
#     mise.msrv.toml.
#   - mise: MISE_VERSION in docker/toolchain.Dockerfile and every `version:`
#     given to jdx/mise-action under .github (the generated release.yml is
#     covered by `dist generate --check`).
# The pre-commit hook of the same name lists these files in its `files:`.
set -euo pipefail
cd "$(dirname "$0")/../.."
status=0
fail() {
  echo "$*" >&2
  status=1
}

# --- Rust
file=$(sed -n 's/^channel = "\(.*\)"/\1/p' rust-toolchain.toml)
mise_rust=$(sed -n 's/^rust = .*version = "\([^"]*\)".*/\1/p' mise.toml)
[ "$file" = "$mise_rust" ] ||
  fail "rust-toolchain.toml pins $file but mise.toml pins $mise_rust"

# --- MSRV
cargo_msrv=$(sed -n 's/^rust-version = "\(.*\)"/\1/p' Cargo.toml)
msrv_tool=$(sed -n 's/^rust = .*version = "\([^"]*\)".*/\1/p' mise.msrv.toml)
msrv_env=$(sed -n 's/^RUSTUP_TOOLCHAIN = "\(.*\)"/\1/p' mise.msrv.toml)
[ -n "$cargo_msrv" ] && [ -n "$msrv_tool" ] && [ -n "$msrv_env" ] ||
  fail "could not read the MSRV from Cargo.toml and mise.msrv.toml"
[ "$msrv_tool" = "$msrv_env" ] ||
  fail "mise.msrv.toml: rust is $msrv_tool but RUSTUP_TOOLCHAIN is $msrv_env"
[ "${msrv_tool%.*}" = "$cargo_msrv" ] ||
  fail "Cargo.toml rust-version is $cargo_msrv but mise.msrv.toml pins $msrv_tool"

# --- mise
image_mise=$(sed -n 's/^ARG MISE_VERSION=v\(.*\)/\1/p' docker/toolchain.Dockerfile)
[ -n "$image_mise" ] || fail "no ARG MISE_VERSION=v... in docker/toolchain.Dockerfile"
found=0
while read -r where version; do
  found=$((found + 1))
  [ "$version" = "$image_mise" ] ||
    fail "$where gives jdx/mise-action version $version but the Dockerfile pins $image_mise"
done < <(
  find .github -name '*.yml' ! -name release.yml -exec awk '
    FNR == 1 { armed = 0 }
    /uses: *jdx\/mise-action@/ { armed = 1; next }
    armed && /^ *version: / {
      print FILENAME ":" FNR, $2; armed = 0
    }' {} +
)
[ "$found" -gt 0 ] || fail "found no jdx/mise-action version under .github"

[ "$status" -eq 0 ] ||
  exit "$status"
echo "Rust $file, MSRV $msrv_tool and mise $image_mise pinned consistently"
