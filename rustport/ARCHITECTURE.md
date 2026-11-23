# ARCHITECTURE - pure-Rust Cossacks 3 port (`rustport/`)

**Status:** planned module architecture for a scaffold-only crate (T6-R01).
The files exist as stubs; behaviour is added by later micro-tickets.

## 0. Non-negotiable design rules

1. **std-only target.** `Cargo.toml` declares **zero dependencies** - no crates at
   all, not even for windowing, image decoding, math or GUI. Only the Rust
   standard library is used.
2. **Raw platform FFI only.** OS services (window, input, framebuffer present,
   later audio) are reached with hand-written `extern "system"` / `extern "C"`
   declarations selected by `#[cfg(...)]`. **No third-party GUI libraries** and
   no bindings crates.
3. **Natively multiplatform.** One source tree, three platform backends. Compile
   on any host; runtime verification is labelled honestly per host (Win32 is
   testable on this machine; X11/Wayland and Cocoa are compile-checked only until
   run on those hosts - see T6-R03/R04).
4. **Donor is runtime data, never repo data.** Assets are read at runtime from
   `C:\Games\Cossacks 3` (private use; **never copied, uploaded or published**).
   The repo holds only source, docs and self-generated test fixtures.

## 1. Crate layout

```
rustport/
  Cargo.toml          package cossacks3-rust, edition 2021, [[bin]] + [lib], no deps
  src/
    main.rs           binary entry point (banner / --help) - T6-R01
    lib.rs            library root, declares the engine modules
    platform.rs       window/input/present FFI facade      - T6-R02/R03/R04
    raster.rs         framebuffer + triangle/tile renderer  - T6-R06
    assets.rs         DDS + OSS/OSM/AAF readers             - T6-R05
    sim.rs            economy/AI from mechanics.json        - T6-R08
    gui.rs            minimal widgets in the framebuffer    - later ticket
  ARCHITECTURE.md     this document
  README.md           build / run / test / donor-path notes
  .gitignore          target/ + editor cruft
```

`main.rs` is intentionally independent of `lib.rs` at scaffold stage; later
tickets will have the binary call into the `cossacks3_rust` library.

## 2. Modules

### 2.1 `platform` - raw OS backend (T6-R02 / R03 / R04)

A single facade module whose concrete implementation is chosen with `cfg`:

| Target | Backend | Ticket | Runtime status on this host |
|---|---|---|---|
| `target_os = "windows"` | Win32 (`CreateWindowExW`, `PeekMessageW`, `StretchDIBits`/`BitBlt`) | T6-R02 | testable |
| `target_os = "linux"` / `android` | X11 + Wayland (`libX11` / `libwayland-client` via `extern "C"`) | T6-R03 | compile-checked only |
| `target_os = "macos"` | Cocoa / AppKit (`objc_msgSend` via `extern "C"`) | T6-R04 | compile-checked only |

Responsibilities: create/destroy a window, poll raw input (keyboard/mouse), own
the swap/present surface, and expose the mutable pixel buffer to `raster`.
No SDL/GLFW/winit; FFI structs are defined locally to match the platform ABI.

### 2.2 `raster` - software renderer (T6-R06, gate T6-R07)

- Owns a CPU-side RGBA8 **software framebuffer** (width × height × 4 bytes).
- Triangle rasterizer (barycentric/edge-function fill, perspective-correct UVs).
- Terrain-tile renderer: donor 124-slot TileBlock coverage and height shading.
- Blits sprites from decoded `assets` textures with alpha test / blend.
- Produces pixels only; never talks to the OS. Presentation is `platform`'s job.

### 2.3 `assets` - donor readers at runtime (T6-R05)

Reads **from the donor install path at runtime**; decodes into owned Rust data
(no borrowed slices into donor mmaps kept past the read):

- **DDS**: standard `DDS ` header, DXT1/3/5 block decompression to RGBA8.
- **`.oss`** (skinned animation): 24-byte header of six `int32`
  (`k, fps, b, v, fc, t`), then `v` vertices (`3f`), `fc` face indices (`3i`),
  `t` UVs (`2f`), `fc` UV-index triples, `v` weight lists (`count`, then
  `<i f>` pairs), then `b × k × 7f` bone tracks (xyz + quaternion xyzw).
  Exact-size closure is the validation test.
- **`.osm`** (static mesh): `IDP2` magic; offsets at header longs **12/13/14**
  (`ou`, `ot`, `of`); UVs `nu × 2f`, triangles `nt × 6i` with winding swap
  `(0,2,1)`, vertices `16` bytes past `of` then `nv × (3f, u32)`.
- **`.aaf`** (actions): text `AAF`, count, then `"name",start,end,morph` with
  inclusive frame bounds.

### 2.4 `sim` - economy / AI (T6-R08)

Ports the donor-documented numbers in `app/mechanics.json` (182 values: damage
formula, 1.664/s mines, /625 upkeep, famine, capture, market drift, formations,
morale) into plain Rust data and headless-testable tick functions. No rendering
or FFI dependencies; deterministic input → deterministic output.

### 2.5 `gui` - minimal widgets (later ticket)

Buttons, panels, labels and minimap drawn **into the software framebuffer** via
`raster`. No third-party GUI toolkit; text metrics/glyphs come from decoded
donor textures or a small built-in bitmap font authored in-repo.

## 3. Data flow (one frame)

```
main
  -> platform: create window, obtain mutable framebuffer surface
  -> assets:   load/decode donor DDS + meshes needed this frame (runtime)
  -> sim:      advance economy/AI tick (deterministic, headless)
  -> raster:   clear framebuffer -> draw terrain tiles -> sprites/meshes -> gui widgets
  -> platform: present(framebuffer) to the OS window
  -> repeat until quit
```

Ownership rule: `platform` owns the surface, `raster` borrows it mutably for the
frame, `platform` presents it after `raster` returns. No module reaches across to
the OS except `platform`; no module decodes donor bytes except `assets`.

## 4. Verification ladder (per SWARM_OPS §7.6)

`cargo build`/`cargo test` green at scaffold (R01) → Win32 window + present
(R02) → readers byte-compare (R05) → terrain tile raster (R06) → 16×16-tile M0
A/B capture vs donor reference with owner review (R07) → only then expand to
R03/R04/R08. No whole-system test before the piece gates pass.
