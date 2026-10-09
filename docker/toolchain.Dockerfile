# syntax=docker/dockerfile:1
#
# Toolchain image: the Linux build environment for CI, the devcontainer and
# agents. Rust and every tool come from mise.toml and mise.lock; the C
# compiler is the default gcc of the Ubuntu base. Bumping the base digest
# bumps gcc.

# ubuntu:26.04 (the LTS that ubuntu:latest points to), pinned by digest.
FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7 AS base

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        pkg-config \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV MISE_DATA_DIR=/opt/mise \
    MISE_CACHE_DIR=/opt/mise/cache \
    MISE_CONFIG_DIR=/opt/mise/config \
    MISE_YES=1 \
    RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    MISE_TRUSTED_CONFIG_PATHS=/src:/workspaces:/__w

# ---------------------------------------------------------------- tools stage
# Installs mise and every tool. Only the install trees are copied out, so
# downloads, caches and the scratch manifests never reach the final image.
FROM base AS tools

# mise itself is the one tool pinned here rather than in mise.toml: the
# release binary, checked against these SHA-256 sums (from the release's
# SHASUMS256.txt). Bump the version and both sums together.
ARG MISE_VERSION=v2026.10.4
ARG MISE_SHA256_AMD64=2b8ce21f550872807bcaabf45b6bc5c64bfbd6dc3bf49dd4e67de700ef3ceb75
ARG MISE_SHA256_ARM64=9013ce1d7d9bbbf65254cda178562f5450c474a705907c18b77e6b678bb10041
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
        amd64) arch=x64 sum="${MISE_SHA256_AMD64}" ;; \
        arm64) arch=arm64 sum="${MISE_SHA256_ARM64}" ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /usr/local/bin/mise \
        "https://github.com/jdx/mise/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-linux-${arch}" \
    && echo "${sum}  /usr/local/bin/mise" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/mise \
    && mise --version

# Install from a scratch project so mise.lock pins every version
# (`--locked` fails instead of resolving anything new). Tools downloaded as
# release assets are also pinned by URL and checksum; Rust comes from rustup
# and the cargo: tools from crates.io (prebuilt via cargo-binstall), which the
# lock pins by version only.
COPY mise.toml mise.lock /tmp/tools/
RUN cd /tmp/tools \
    && export MISE_TRUSTED_CONFIG_PATHS=/tmp/tools \
    && mise install --locked cargo-binstall \
    && mise install --locked

# The MSRV toolchain comes from mise.msrv.toml, installed from its own
# scratch directory so it never becomes the image's default Rust.
COPY mise.msrv.toml /tmp/msrv/mise.toml
RUN cd /tmp/msrv && MISE_TRUSTED_CONFIG_PATHS=/tmp/msrv mise install rust

# The repo manifest becomes the image's global config, so the shims resolve
# the same versions anywhere in the container.
COPY mise.toml /opt/mise/config/config.toml
# The registry is emptied, not removed: the dev containers mount a named
# volume there, and Docker only seeds a volume's ownership and mode from a
# directory that exists in the image.
RUN mise reshim \
    && rm -rf /opt/mise/cache /opt/cargo/registry \
    && mkdir -m 1777 /opt/cargo/registry

# ---------------------------------------------------------------- final image
FROM base

COPY --from=tools /usr/local/bin/mise /usr/local/bin/mise
# Owned by the image user, so cargo and rustup can write their caches without
# making the toolchain world-writable. CI jobs run as root and are unaffected.
COPY --from=tools --chown=ubuntu:ubuntu /opt/mise /opt/mise
COPY --from=tools --chown=ubuntu:ubuntu /opt/rustup /opt/rustup
COPY --from=tools --chown=ubuntu:ubuntu /opt/cargo /opt/cargo

ENV PATH=/opt/mise/shims:/opt/cargo/bin:${PATH}

# Checkouts are bind-mounted with the host's (or runner's) uid, which git and
# libgit2 reject as "dubious ownership". This is a throwaway build container,
# so trust every path.
RUN git config --system --add safe.directory '*'

# ubuntu images ship a non-root `ubuntu` user (uid 1000).
USER ubuntu
WORKDIR /src
CMD ["bash"]
