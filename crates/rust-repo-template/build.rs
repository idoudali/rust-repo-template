//! Records the target triple the crate is compiled for, so `Info` can report
//! it. Cargo only gives `TARGET` to build scripts.

fn main() {
    let target = std::env::var("TARGET").unwrap_or_default();
    println!("cargo::rustc-env=BUILD_TARGET={target}");
    println!("cargo::rerun-if-changed=build.rs");
}
