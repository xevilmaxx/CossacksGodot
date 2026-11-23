# cossacks3-rust - pure-Rust Cossacks 3 clone (scaffold)

A from-scratch, **std-only** Rust port of Cossacks 3. No third-party crates:
windowing/input/presentation use raw platform FFI (Win32, X11/Wayland, Cocoa),
and rendering is a software framebuffer. The crate is intentionally
multiplatform - one source tree, platform backend chosen with `#[cfg(...)]`.

> **Honest current status: SCAFFOLD ONLY (ticket T6-R01).**
> The binary prints a banner and handles `--help`; it does **not** yet open a
> window, read assets, render, or simulate anything. The engine modules
> (`platform`, `raster`, `assets`, `sim`, `gui`) exist as stubs and are filled in
> by later tickets. See `ARCHITECTURE.md` for the plan and ticket mapping.

## Requirements

- Rust toolchain (developed with `rustc`/`cargo` 1.99.1; edition 2021).
- No network access needed to build: there are **zero dependencies**.

## Build / run / test

Run all commands from this `rustport/` directory:

```powershell
# Debug build
cargo build

# Optimised build
cargo build --release

# Run (prints the banner and exits, or use `cargo run -- --help`)
cargo run
cargo run -- --help

# Tests (zero tests at scaffold stage - this is expected and passes)
cargo test
```

## Donor path requirement (runtime, planned)

The finished port reads its art and data **at runtime** from the donor install:

```
C:\Games\Cossacks 3
```

Formats consumed: DXT1/3/5 `.dds` textures, `.oss` skinned meshes, `.osm`
static meshes, `.aaf` action ranges, plus numeric truth from
`app/mechanics.json`. The donor is **private use only**: never copy donor files
into this repository, never redistribute or publish them. No donor bytes are
present in `rustport/` now, and none will be committed.

## Multiplatform intent

| OS | Backend | Status |
|---|---|---|
| Windows | Win32 (raw FFI) | targeted first; testable on this host (T6-R02) |
| Linux | X11 / Wayland (raw FFI) | compile-checked; runtime UNVERIFIED on this host (T6-R03) |
| macOS | Cocoa / AppKit (raw FFI) | compile-checked; runtime UNVERIFIED on this host (T6-R04) |

Non-Windows runtime claims stay labelled `UNVERIFIED` until run on real hosts.

## Design constraints

- **Zero crates** in `Cargo.toml`; std only.
- **No third-party GUI libraries** - raw platform FFI and a software framebuffer.
- Donor assets are runtime input, never repo content.

See `ARCHITECTURE.md` for module responsibilities and the per-frame data flow
`main -> platform window -> framebuffer -> raster -> present`.
