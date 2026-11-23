//! Cossacks 3 - pure-Rust port.
//!
//! Scaffold entry point for ticket T6-R01. At this stage the binary only prints
//! a banner (or `--help`) and exits. The engine modules described in
//! `ARCHITECTURE.md` are wired in by later tickets.

use std::env;
use std::process::ExitCode;

const BANNER: &str = r#"
================================================================
  Cossacks 3 - Pure-Rust Port  (scaffold, T6-R01)
  Language : Rust 2021, standard library only, ZERO crates
  GUI      : raw platform FFI (Win32 / X11-Wayland / Cocoa)
  Status   : SCAFFOLD - no engine, assets, sim or renderer yet
================================================================
"#;

const HELP: &str = r#"
cossacks3-rust - pure-Rust Cossacks 3 clone (scaffold)

USAGE:
    cossacks3-rust [OPTIONS]

OPTIONS:
    -h, --help    Print this help and exit
    (no args)     Print the startup banner and exit

RUNTIME (planned, not yet implemented):
    The finished port will read donor assets at runtime from
    C:\Games\Cossacks 3 (private use only - never redistributed).

Build from the rustport/ directory:
    cargo build --release
    cargo run
    cargo test
"#;

fn main() -> ExitCode {
    match env::args().nth(1).as_deref() {
        Some("-h") | Some("--help") => {
            print!("{HELP}");
        }
        Some(other) => {
            eprintln!("cossacks3-rust: unrecognized argument `{other}`");
            eprintln!("Try `--help` for usage.");
            return ExitCode::from(2);
        }
        None => {
            print!("{BANNER}");
        }
    }
    ExitCode::SUCCESS
}
