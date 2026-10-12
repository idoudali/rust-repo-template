# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html). release-plz writes new entries from conventional commits.

## [Unreleased]
## [0.1.1](https://github.com/idoudali/rust-repo-template/compare/v0.1.0...v0.1.1) - 2026-10-12

### Features

- add cargo xtask rename and template setup docs ([#13](https://github.com/idoudali/rust-repo-template/pull/13))
- add greet and info commands to the CLI ([#12](https://github.com/idoudali/rust-repo-template/pull/12))
- add Cargo workspace skeleton with --version stub ([#1](https://github.com/idoudali/rust-repo-template/pull/1))

### Documentation

- give the library crate its own README ([#23](https://github.com/idoudali/rust-repo-template/pull/23))
- move repo guides from rustdoc into an mdBook ([#22](https://github.com/idoudali/rust-repo-template/pull/22))
- publish rustdoc with the README front page and guides to Pages ([#8](https://github.com/idoudali/rust-repo-template/pull/8))

### Tests

- add unit, CLI and doc tests with a 100% line coverage gate

### Build

- version and tag releases with release-plz ([#11](https://github.com/idoudali/rust-repo-template/pull/11))
- add rustfmt, clippy pedantic, cargo-deny, typos and rumdl checks ([#3](https://github.com/idoudali/rust-repo-template/pull/3))

### CI

- publish the repo book and API reference as one Pages site ([#24](https://github.com/idoudali/rust-repo-template/pull/24))
- move workflow shell logic into tools/ci scripts ([#21](https://github.com/idoudali/rust-repo-template/pull/21))
