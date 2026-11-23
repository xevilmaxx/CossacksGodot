//! Cossacks 3 - pure-Rust port library root (scaffold).
//!
//! The engine is split into the modules below. Each is currently a stub and is
//! filled in by a dedicated micro-ticket (see ARCHITECTURE.md):
//!
//! * `platform` - raw windowing/input/framebuffer-present FFI (T6-R02/R03/R04)
//! * `raster`   - software framebuffer + triangle/terrain-tile renderer (T6-R06)
//! * `assets`   - DXT DDS + `.oss`/`.osm`/`.aaf` readers (T6-R05)
//! * `sim`      - economy/AI driven by `app/mechanics.json` (T6-R08)
//! * `gui`      - minimal widgets drawn into the framebuffer (later ticket)
//!
//! Design rule: std only, no third-party crates, raw platform FFI only.

pub mod assets;
pub mod gui;
pub mod platform;
pub mod raster;
pub mod sim;
