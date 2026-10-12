//! `cargo xtask rename`: turn a copy of the template into a new project.

use std::fmt;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

/// The template's project name, as it appears in paths and manifests.
const OLD_NAME: &str = "rust-repo-template";
/// The template's library crate name, as it appears in Rust code.
const OLD_CRATE: &str = "rust_repo_template";
/// The GitHub owner the template links to.
const OLD_OWNER: &str = "idoudali";

/// Directories never rewritten: VCS data, build output, caches, and this
/// crate (it must keep the old name to know what to replace).
const SKIP_DIRS: &[&str] = &[".git", "target", "xtask", "vendor", "site"];

/// A rename request.
pub(crate) struct Rename<'a> {
    pub(crate) name: &'a str,
    pub(crate) owner: Option<&'a str>,
    pub(crate) dry_run: bool,
}

/// What a rename changed (or would change, on a dry run).
#[derive(Debug, Default)]
pub(crate) struct Report {
    dry_run: bool,
    files: Vec<PathBuf>,
    dirs: Vec<(PathBuf, PathBuf)>,
}

/// Why a rename was refused or failed.
#[derive(Debug)]
pub(crate) enum Error {
    InvalidName(String),
    InvalidOwner(String),
    Exists(PathBuf),
    Io(PathBuf, io::Error),
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidName(name) => write!(
                f,
                "`{name}` is not a valid name: use lowercase letters, digits \
                 and single hyphens, starting with a letter, and not \
                 `{OLD_NAME}`"
            ),
            Self::InvalidOwner(owner) => write!(
                f,
                "`{owner}` is not a valid GitHub owner: use letters, digits \
                 and hyphens"
            ),
            Self::Exists(path) => {
                write!(f, "`{}` already exists", path.display())
            }
            Self::Io(path, err) => write!(f, "{}: {err}", path.display()),
        }
    }
}

impl Rename<'_> {
    /// Rewrites every text file under `root`, then renames the crate
    /// directories.
    pub(crate) fn run(&self, root: &Path) -> Result<Report, Error> {
        if !is_valid_name(self.name) {
            return Err(Error::InvalidName(self.name.to_owned()));
        }
        if let Some(owner) = self.owner {
            if !is_valid_owner(owner) {
                return Err(Error::InvalidOwner(owner.to_owned()));
            }
        }

        let dirs = self.dir_renames(root);
        for (_, to) in &dirs {
            if to.exists() {
                return Err(Error::Exists(to.clone()));
            }
        }

        let mut report = Report {
            dry_run: self.dry_run,
            ..Report::default()
        };
        self.rewrite_tree(root, root, &mut report)?;
        for (from, to) in dirs {
            if from.is_dir() {
                if !self.dry_run {
                    fs::rename(&from, &to)
                        .map_err(|err| Error::Io(from.clone(), err))?;
                }
                report.dirs.push((
                    relative(root, &from).to_path_buf(),
                    relative(root, &to).to_path_buf(),
                ));
            }
        }
        Ok(report)
    }

    /// The crate directories to rename, CLI first.
    fn dir_renames(&self, root: &Path) -> Vec<(PathBuf, PathBuf)> {
        let crates = root.join("crates");
        vec![
            (
                crates.join(format!("{OLD_NAME}-cli")),
                crates.join(format!("{}-cli", self.name)),
            ),
            (crates.join(OLD_NAME), crates.join(self.name)),
        ]
    }

    /// Applies every replacement to one file's text.
    fn replace(&self, text: &str) -> String {
        let crate_name = self.name.replace('-', "_");
        let mut out = text
            .replace(OLD_NAME, self.name)
            .replace(OLD_CRATE, &crate_name);
        if let Some(owner) = self.owner {
            out = out.replace(OLD_OWNER, owner);
        }
        out
    }

    fn rewrite_tree(
        &self,
        root: &Path,
        dir: &Path,
        report: &mut Report,
    ) -> Result<(), Error> {
        let entries =
            fs::read_dir(dir).map_err(|err| Error::Io(dir.into(), err))?;
        let mut paths = entries
            .map(|entry| entry.map(|e| e.path()))
            .collect::<Result<Vec<_>, _>>()
            .map_err(|err| Error::Io(dir.into(), err))?;
        paths.sort();

        for path in paths {
            let meta = fs::symlink_metadata(&path)
                .map_err(|err| Error::Io(path.clone(), err))?;
            if meta.is_dir() {
                if dir == root && is_skipped(&path) {
                    continue;
                }
                self.rewrite_tree(root, &path, report)?;
            } else if meta.is_file() {
                self.rewrite_file(root, &path, report)?;
            }
            // Symlinks are left alone: their targets are rewritten in place.
        }
        Ok(())
    }

    fn rewrite_file(
        &self,
        root: &Path,
        path: &Path,
        report: &mut Report,
    ) -> Result<(), Error> {
        let bytes =
            fs::read(path).map_err(|err| Error::Io(path.into(), err))?;
        let Ok(text) = String::from_utf8(bytes) else {
            // Binary file: nothing to rename.
            return Ok(());
        };
        let new = self.replace(&text);
        if new != text {
            if !self.dry_run {
                fs::write(path, new)
                    .map_err(|err| Error::Io(path.into(), err))?;
            }
            report.files.push(relative(root, path).to_path_buf());
        }
        Ok(())
    }
}

impl fmt::Display for Report {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let verb = if self.dry_run {
            "would update"
        } else {
            "updated"
        };
        for file in &self.files {
            writeln!(f, "{verb} {}", file.display())?;
        }
        let verb = if self.dry_run { "would move" } else { "moved" };
        for (from, to) in &self.dirs {
            writeln!(f, "{verb} {} -> {}", from.display(), to.display())?;
        }
        writeln!(
            f,
            "{} files, {} directories",
            self.files.len(),
            self.dirs.len()
        )?;
        if !self.dry_run {
            writeln!(
                f,
                "next: review `git diff`, update `authors` in Cargo.toml and \
                 the description in README.md, then run `mise run verify`"
            )?;
        }
        Ok(())
    }
}

fn is_skipped(path: &Path) -> bool {
    path.file_name()
        .and_then(|name| name.to_str())
        .is_some_and(|name| {
            SKIP_DIRS.contains(&name) || name.ends_with("_cache")
        })
}

fn relative<'p>(root: &Path, path: &'p Path) -> &'p Path {
    path.strip_prefix(root).unwrap_or(path)
}

/// Kebab case: a lowercase letter, then lowercase letters and digits, with
/// single hyphens between groups.
fn is_valid_name(name: &str) -> bool {
    name != OLD_NAME
        && name.starts_with(|c: char| c.is_ascii_lowercase())
        && !name.ends_with('-')
        && !name.contains("--")
        && name
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
}

/// GitHub logins: letters, digits and single inner hyphens.
fn is_valid_owner(owner: &str) -> bool {
    !owner.is_empty()
        && !owner.starts_with('-')
        && !owner.ends_with('-')
        && owner.chars().all(|c| c.is_ascii_alphanumeric() || c == '-')
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicUsize, Ordering};

    /// A scratch copy of the parts of the template a rename touches.
    struct Fixture {
        root: PathBuf,
    }

    impl Fixture {
        fn new() -> Self {
            static NEXT: AtomicUsize = AtomicUsize::new(0);
            let root = std::env::temp_dir().join(format!(
                "xtask-rename-{}-{}",
                std::process::id(),
                NEXT.fetch_add(1, Ordering::Relaxed)
            ));
            let _ = fs::remove_dir_all(&root);
            let fixture = Self { root };
            fixture.write(
                "Cargo.toml",
                "repository = \"https://github.com/idoudali/rust-repo-template\"\n\
                 rust-repo-template = { path = \"crates/rust-repo-template\" }\n",
            );
            fixture.write(
                "crates/rust-repo-template/src/lib.rs",
                "//! rust_repo_template\n",
            );
            fixture.write(
                "crates/rust-repo-template-cli/src/main.rs",
                "use rust_repo_template::VERSION;\n",
            );
            fixture.write("README.md", "# rust-repo-template\n");
            fixture.write("target/debug/rust-repo-template", "binary\n");
            fixture.write("xtask/src/rename.rs", "rust-repo-template\n");
            fixture.write_bytes("logo.png", &[0xff, 0xfe, 0x00]);
            fixture
        }

        fn write(&self, rel: &str, text: &str) {
            self.write_bytes(rel, text.as_bytes());
        }

        fn write_bytes(&self, rel: &str, bytes: &[u8]) {
            let path = self.root.join(rel);
            fs::create_dir_all(path.parent().unwrap()).unwrap();
            fs::write(path, bytes).unwrap();
        }

        fn read(&self, rel: &str) -> String {
            fs::read_to_string(self.root.join(rel)).unwrap()
        }
    }

    impl Drop for Fixture {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    fn rename<'a>(name: &'a str, owner: Option<&'a str>) -> Rename<'a> {
        Rename {
            name,
            owner,
            dry_run: false,
        }
    }

    #[test]
    fn renames_files_and_directories() {
        let fx = Fixture::new();
        let report = rename("my-tool", None).run(&fx.root).unwrap();

        assert_eq!(
            fx.read("Cargo.toml"),
            "repository = \"https://github.com/idoudali/my-tool\"\n\
             my-tool = { path = \"crates/my-tool\" }\n"
        );
        assert_eq!(fx.read("crates/my-tool/src/lib.rs"), "//! my_tool\n");
        assert_eq!(
            fx.read("crates/my-tool-cli/src/main.rs"),
            "use my_tool::VERSION;\n"
        );
        assert!(!fx.root.join("crates/rust-repo-template").exists());
        assert_eq!(report.files.len(), 4);
        assert_eq!(report.dirs.len(), 2);

        // Skipped directories keep the old name.
        assert_eq!(fx.read("xtask/src/rename.rs"), "rust-repo-template\n");
        assert_eq!(fx.read("target/debug/rust-repo-template"), "binary\n");
        let text = report.to_string();
        assert!(text.contains("updated README.md"), "{text}");
        assert!(text.contains("4 files, 2 directories"), "{text}");
        assert!(text.contains("next:"), "{text}");
    }

    #[test]
    fn owner_flag_rewrites_links() {
        let fx = Fixture::new();
        rename("my-tool", Some("acme")).run(&fx.root).unwrap();
        assert!(
            fx.read("Cargo.toml")
                .contains("https://github.com/acme/my-tool")
        );
    }

    #[test]
    fn dry_run_changes_nothing() {
        let fx = Fixture::new();
        let plan = Rename {
            name: "my-tool",
            owner: None,
            dry_run: true,
        };
        let report = plan.run(&fx.root).unwrap();
        assert_eq!(fx.read("README.md"), "# rust-repo-template\n");
        assert!(fx.root.join("crates/rust-repo-template").is_dir());
        let text = report.to_string();
        assert!(text.contains("would update README.md"), "{text}");
        assert!(text.contains("would move"), "{text}");
        assert!(!text.contains("next:"), "{text}");
    }

    #[test]
    fn refuses_existing_target() {
        let fx = Fixture::new();
        fx.write("crates/my-tool/keep.txt", "keep\n");
        let err = rename("my-tool", None).run(&fx.root).unwrap_err();
        assert!(matches!(err, Error::Exists(_)));
        assert!(err.to_string().contains("already exists"));
        assert_eq!(fx.read("README.md"), "# rust-repo-template\n");
    }

    #[test]
    fn missing_root_is_an_io_error() {
        let fx = Fixture::new();
        let err = rename("my-tool", None)
            .run(&fx.root.join("missing"))
            .unwrap_err();
        assert!(matches!(err, Error::Io(..)));
        assert!(err.to_string().contains("missing"));
    }

    #[test]
    fn validates_name() {
        for bad in [
            "", "My-Tool", "1tool", "tool-", "my--tool", "my_tool", OLD_NAME,
        ] {
            let err = rename(bad, None).run(Path::new(".")).unwrap_err();
            assert!(matches!(err, Error::InvalidName(_)), "{bad}");
            assert!(err.to_string().contains("not a valid name"));
        }
        assert!(is_valid_name("my-tool2"));
    }

    #[test]
    fn validates_owner() {
        for bad in ["", "-acme", "acme-", "ac/me"] {
            let err = rename("my-tool", Some(bad))
                .run(Path::new("."))
                .unwrap_err();
            assert!(matches!(err, Error::InvalidOwner(_)), "{bad}");
            assert!(err.to_string().contains("not a valid GitHub owner"));
        }
        assert!(is_valid_owner("Acme-42"));
    }
}
