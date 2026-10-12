# rust-repo-template

The library behind the `rust-repo-template` command-line tool. It holds the greeting logic (`greeting`), the platform facts the `info` command prints (`Info`), and the crate `VERSION`. The CLI crate only parses arguments and prints what this crate returns.

```rust
use rust_repo_template::{Info, greeting};

assert_eq!(greeting("Ada", false), "Hello, Ada!");

let info = Info::current();
assert_eq!(info.version, rust_repo_template::VERSION);
```

The guides (getting started, CLI reference, development, releasing) are in the book at <https://idoudali.github.io/rust-repo-template/>.
