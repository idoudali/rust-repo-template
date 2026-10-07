// README.md here is a symlink to the workspace README, so the same path
// works in the workspace and in the packaged crate.
#![doc = include_str!("../README.md")]

use std::fmt;

pub mod guide;

/// Version of this crate, taken from `Cargo.toml` at build time.
///
/// # Examples
///
/// ```
/// assert!(!rust_repo_template::VERSION.is_empty());
/// ```
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Builds the greeting for `name`, in capitals when `shout` is set.
///
/// # Examples
///
/// ```
/// use rust_repo_template::greeting;
///
/// assert_eq!(greeting("Ada", false), "Hello, Ada!");
/// assert_eq!(greeting("Ada", true), "HELLO, ADA!");
/// ```
#[must_use]
pub fn greeting(name: &str, shout: bool) -> String {
    let text = format!("Hello, {name}!");
    if shout { text.to_uppercase() } else { text }
}

/// Facts about the running binary, printed by the `info` command.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Info {
    /// Crate version.
    pub version: &'static str,
    /// Operating system, as in [`std::env::consts::OS`].
    pub os: &'static str,
    /// CPU architecture, as in [`std::env::consts::ARCH`].
    pub arch: &'static str,
}

impl Info {
    /// Returns the facts for the platform this binary was built for.
    ///
    /// # Examples
    ///
    /// ```
    /// let info = rust_repo_template::Info::current();
    /// assert_eq!(info.os, std::env::consts::OS);
    /// ```
    #[must_use]
    pub fn current() -> Self {
        Self {
            version: VERSION,
            os: std::env::consts::OS,
            arch: std::env::consts::ARCH,
        }
    }

    /// Renders the facts as a single-line JSON object.
    ///
    /// The values are fixed identifiers without quotes or backslashes, so no
    /// escaping is needed.
    ///
    /// # Examples
    ///
    /// ```
    /// use rust_repo_template::Info;
    ///
    /// let info = Info { version: "1.2.3", os: "linux", arch: "x86_64" };
    /// assert_eq!(
    ///     info.to_json(),
    ///     r#"{"version":"1.2.3","os":"linux","arch":"x86_64"}"#,
    /// );
    /// ```
    #[must_use]
    pub fn to_json(&self) -> String {
        format!(
            r#"{{"version":"{}","os":"{}","arch":"{}"}}"#,
            self.version, self.os, self.arch
        )
    }
}

impl fmt::Display for Info {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "version: {}", self.version)?;
        writeln!(f, "os:      {}", self.os)?;
        write!(f, "arch:    {}", self.arch)
    }
}

#[cfg(test)]
mod tests {
    use super::{Info, VERSION, greeting};

    #[test]
    fn version_matches_manifest() {
        assert_eq!(VERSION, env!("CARGO_PKG_VERSION"));
    }

    #[test]
    fn greeting_cases() {
        let cases = [
            ("Ada", false, "Hello, Ada!"),
            ("Ada", true, "HELLO, ADA!"),
            ("", false, "Hello, !"),
            ("Zoë", true, "HELLO, ZOË!"),
        ];
        for (name, shout, expected) in cases {
            assert_eq!(greeting(name, shout), expected, "{name} {shout}");
        }
    }

    #[test]
    fn info_current_uses_build_platform() {
        let info = Info::current();
        assert_eq!(info.version, VERSION);
        assert_eq!(info.os, std::env::consts::OS);
        assert_eq!(info.arch, std::env::consts::ARCH);
    }

    #[test]
    fn info_renders_text_and_json() {
        let info = Info {
            version: "1.2.3",
            os: "linux",
            arch: "aarch64",
        };
        assert_eq!(
            info.to_string(),
            "version: 1.2.3\nos:      linux\narch:    aarch64"
        );
        assert_eq!(
            info.to_json(),
            r#"{"version":"1.2.3","os":"linux","arch":"aarch64"}"#
        );
    }
}
