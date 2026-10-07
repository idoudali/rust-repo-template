# Command-line interface

The `rust-repo-template` binary has two commands. Run any command with `--help` for the full option list.

## `greet`

```text
rust-repo-template greet <NAME> [--count <N>] [--shout]
```

Prints `Hello, <NAME>!`, `--count` times (1 to 255, default 1), in capitals with `--shout`.

```text
$ rust-repo-template greet Ada --count 2 --shout
HELLO, ADA!
HELLO, ADA!
```

The library function behind it:

```rust
assert_eq!(rust_repo_template::greeting("Ada", true), "HELLO, ADA!");
```

## `info`

```text
rust-repo-template info [--json]
```

Prints the version, operating system, and architecture of the binary, as text or as one line of JSON.

```text
$ rust-repo-template info --json
{"version":"0.1.0","os":"linux","arch":"x86_64"}
```

```rust
let info = rust_repo_template::Info::current();
assert!(info.to_json().starts_with(r#"{"version":""#));
```

## Exit codes

| Code | Meaning                                    |
| ---- | ------------------------------------------ |
| 0    | Success                                    |
| 2    | Invalid arguments (printed usage on stderr) |
