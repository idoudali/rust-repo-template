// README.md here is a symlink to the workspace README, so the same path
// works in the workspace and in the packaged crate.
#![doc = include_str!("../README.md")]

pub mod guide;

/// Version of this crate, taken from `Cargo.toml` at build time.
///
/// # Examples
///
/// ```
/// assert!(!rust_repo_template::VERSION.is_empty());
/// ```
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

#[cfg(test)]
mod tests {
    use super::VERSION;

    #[test]
    fn version_matches_manifest() {
        assert_eq!(VERSION, env!("CARGO_PKG_VERSION"));
    }
}
