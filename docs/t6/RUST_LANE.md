# T6 RUST LANE — pure-Rust rebuild (parallel experimental branch)

**Lane parent:** T6-RUST (agent `general`, model `opencode/hy4-flash-free#high`),
session `ses_df83996f2ffeR7UWC6RR73aACk`, parent coordinator
`ses_df83f967bffep0THVm6I0UqN2E`.

**Ownership boundary (STRICT):** `rustport/**`, `docs/t6/RUST_LANE.md`,
`docs/t6/reports/T6-R*.md` ONLY. Never touch `app/**`, `SWARM_BOARD.md`,
`SWARM_OPS.md`, `AGENT_PROTOCOL.md`, other lanes' docs, or the Godot app.

**Donor (private use, NEVER redistribute / copy into repo):**
`C:\Games\Cossacks 3`. The Rust build reads donor assets at RUNTIME from this
install path; no donor bytes are ever committed.

**Reference image for M0:** `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg`.

**Constraints:** zero third-party crates for GUI/windowing; raw platform FFI
(Win32 user32/gdi32/kernel32, X11/Wayland, Cocoa). std-only target. If a
non-GUI crate ever seems unavoidable, record justification here and WAIT for
coordinator approval — do not add it.

**Protocol:** SWARM_OPS.md §7 (recursive tree, piece-before-whole, supervision),
§5b-QUALITY (observed/derived/inferred labels, UNVERIFIED honesty),
app/tools/AGENT_PROTOCOL.md (backup rule; Godot runner rule does NOT apply —
this lane never runs Godot).

## Gate order

`R01 → R02 → R05 / R06 → R07 (M0 visual gate) → owner/coordinator review → R03 / R04 / R08`

R03 and R04 are compile-checked only on this Windows host; runtime is
**UNVERIFIED** and must be labelled honestly.

### M0 GATE RESULT (2026-11-23) — verdict PARTIAL, expansion HELD for owner review

- **Worker verdict (T6-R07):** **PARTIAL** — recognisably the same texture art
  direction (real donor DDS grass/rock pixels, earthy palette) but a hard
  64 px tile checkerboard, synthetic periodic diagonal shading, and a darker,
  less-saturated tile mix. Reported as `observed` from the A/B, not PASS.
- **Parent independent visual check:** viewed
  `rustport/shots/m0/ab_side_by_side.png` and the raw donor JPG myself.
  Observed: left panel = a regular checkerboard of grass/rock/sand crops with
  strong diagonal shade bands; right panel = smooth, low-contrast donor grass
  with fine mottling, a faint path and vegetation. My independent read is
  **closer to FAIL than PARTIAL** for full donor-similarity; PARTIAL is only
  defensible when scoped narrowly to "same source texture art direction".
  Recording both honestly; **owner review decides**. Do NOT treat as PASS.
- **Metrics (observed, `rustport/shots/m0/stats.json`):** mean luminance Rust
  69.23 vs donor 91.87 (Δ −22.63); mean RGB Δ [−21.28, −25.05, −2.64];
  block-gradient ratio Rust/donor 1.4666; block-luminance-std ratio 1.6709.
  Crop = donor JPG `[620,380,860,620]` (240² native → 1024² LANCZOS), chosen
  as the cleanest terrain-only square (documented in stats.json).
- **Evidence:** `rustport/shots/m0/{rust_terrain.png,donor_crop.png,ab_side_by_side.png,ab_luminance.png,stats.json,rust_terrain.raw}`;
  SHA-256 (parent `Get-FileHash`): rust_terrain `1985fbed…`, donor_crop
  `badca290…`, ab_side_by_side `0d3838cd…`.
- **Top-3 deficits (worker, ranked):** (1) hard 64 px tile checkerboard,
  no seam blending → use donor 124-slot TileBlock + 6-pass tilesmooth chain
  and feather borders; (2) synthetic periodic diagonal shading → replace the
  arbitrary height function with donor relief/height truth; (3) dark,
  low-saturation tile mix → calibrate against donor patch luminance/saturation.
- **Consequence:** R03 / R04 / R08 stay **BLOCKED** until the coordinator/owner
  reviews this verdict. No expansion was started.

## Ticket table (kept current by lane parent)

| ID | Micro-task | sessionID | State | Owned files | Build / test evidence |
|---|---|---|---|---|---|
| T6-R01 | Scaffold cargo project (no deps), ARCHITECTURE.md, build/run docs, .gitignore | `ses_df83462d5ffe559T1dGSqOyGgB` | DONE | `rustport/Cargo.toml`, `rustport/src/main.rs`, `rustport/src/lib.rs`, 5 stubs, `rustport/ARCHITECTURE.md`, `rustport/README.md`, `rustport/.gitignore` | child report `docs/t6/reports/T6-R01.md` (9/9 PASS); parent re-ran cargo build/run/test 2026-11-23 — all ok |
| T6-R02 | Win32 platform layer: window + input + software framebuffer present (raw FFI) | `ses_df828d2aeffePcftKmhjMQlSAD` | DONE | `rustport/src/platform/win32.rs`, `rustport/src/bin/win32_demo.rs`, `rustport/tests/win32_piece.rs`, report | child report T6-R02.md; parent ran `cargo run --bin win32_demo` — window OK, gradient samples printed, auto-closed (PASS) |
| T6-R05-DDS | DDS DXT1/3/5 decoder + byte-compare vs Pillow golden | `ses_df828cf93ffeicb34twZofR16H` | DONE | `rustport/src/assets/dds.rs`, `rustport/tests/assets_dds.rs`, `rustport/tests/tools/dds_golden.py`, report | child report T6-R05-DDS.md: 7/7, 4 donor textures / 5,521,408 B vs Pillow, 0 mismatches; parent ran `cargo test --test assets_dds` → 7/7 incl. `donor_golden_bytes_match` |
| T6-R05-OSS | .oss skinned-mesh reader + donor size-closure tests | `ses_df828d44fffelQsuMotvGV5AJ9` | DONE | `rustport/src/assets/oss.rs`, `rustport/tests/assets_oss.rs`, report | child report T6-R05-OSS.md (335 donor files close exactly); parent ran `cargo test --test assets_oss` → 5/5 incl. `donor_yacht_oss`, `donor_peaukr_oss` |
| T6-R05-OSM | .osm static-mesh reader + donor offset-closure tests | `ses_df828d2a0ffeZcw4ybX3vOoo29` | DONE | `rustport/src/assets/osm.rs`, `rustport/tests/assets_osm.rs`, report | child report T6-R05-OSM.md (15/15 PASS, 12/13/14 offsets); parent ran `cargo test --test assets_osm` → 4/4 PASS |
| T6-R05-AAF | .aaf action-range reader + donor yacht.aaf test | `ses_df828d10dffeXyoGOSQy1i4ewE` | DONE | `rustport/src/assets/aaf.rs`, `rustport/tests/assets_aaf.rs`, report | child report T6-R05-AAF.md; parent ran `cargo test --test assets_aaf` → 3/3 PASS |
| T6-R06 | Software rasterizer + terrain tile renderer (donor blocks, height shading) | `ses_df81927bcffe1FChzwxJTr9ul3` | DONE | `rustport/src/raster/*.rs`, `rustport/src/bin/raster_piece.rs`, `rustport/tests/raster_piece.rs`, `rustport/shots/raster_piece.{raw,png}`, report | child report T6-R06.md (4/4 PASS); parent ran `cargo test --test raster_piece` → 4/4, verified SHA-256 `0c583777…7ae2ec`, viewed PNG (donor grass/rock texture, synthetic diagonal height shading) |
| T6-R07 | M0 visual gate: 16×16-tile terrain A/B vs donor reference; honest verdict | `ses_df8112a08ffeqtE5YoEqStiqL7` | DONE | `rustport/src/bin/m0_capture.rs`, `rustport/shots/m0/**`, `rustport/tests/tools/m0_compare.py`, report | child report T6-R07.md verdict **PARTIAL**; parent rebuilt `m0_capture`, re-ran `python tests/tools/m0_compare.py` (exit 0), re-hashed all PNGs, viewed A/B directly |
| T6-R03 | X11/Wayland platform layer (compile-checked, runtime UNVERIFIED) | — | BLOCKED on M0 | `rustport/src/platform/x11.rs`, report | pending |
| T6-R04 | Cocoa platform layer (compile-checked, runtime UNVERIFIED) | — | BLOCKED on M0 | `rustport/src/platform/cocoa.rs`, report | pending |
| T6-R08 | Sim core skeleton from mechanics.json + headless tests | — | BLOCKED on M0 | `rustport/src/sim/**`, `rustport/tests/sim_*`, report | pending |

## Supervision log (lane parent)

- 2026-11-23: read SWARM_OPS §7, T6_WAVE_PLAN LANE RUST, AGENT_PROTOCOL,
  DC_FORMATS, TERRAIN_DONOR_ASSETS. Confirmed `rustc/cargo 1.99.1`, Python 3.14,
  donor DDS paths and reference JPG on disk. Spawned R01 via OpenCode session
  API (parentID wired to coordinator tree); children report to
  `docs/t6/reports/T6-R*.md`.
- 2026-11-23 **COORDINATOR DIRECTIVE ACKNOWLEDGED**: re-read SWARM_OPS §7.2.
  All NEW/replacement children use **`opencode-go/hy4-flash-free`** (the
  `opencode/` pool is quota-blocked); escalation after 2 failures or >20 min
  silence = `opencode-go/muse-spark-1.3-contributor#high`. Host facts injected
  into every prompt by `rustport/.lane/spawn.js`: Python is `python` (3.14),
  NEVER `python3`; Blender at `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`
  (not on PATH); never run Godot. R01 was spawned on `opencode/hy4-flash-free`
  BEFORE the directive but its session log shows normal tool progress and
  completion with **no quota error** → no re-spawn needed (documented, not
  hidden). New spawns use the opencode-go pool.
- 2026-11-23 **R01 VERIFIED by parent**: read `docs/t6/reports/T6-R01.md`;
  independently ran `cargo build`, `cargo run` (banner printed), `cargo test`
  (3 test binaries, 0 tests, all ok) from `rustport/`. Scaffold is clean,
  zero-dependency. State → DONE.
- 2026-11-23 **all 5 parallel pieces landed on `opencode-go/hy4-flash-free`**
  (R02, R05-DDS/OSS/OSM/AAF). Parent verified by running EVERY piece test
  suite and recording the test names: `assets_aaf` 3/3 (`donor_yacht_aaf_has_
  four_full_range_actions`, `synthetic_crlf_escapes_and_trailing_blank_lines`,
  `malformed_inputs_are_rejected`); `assets_dds` 7/7 (`donor_golden_bytes_match`
  + 6 synthetic); `assets_oss` 5/5 (`donor_yacht_oss`, `donor_peaukr_oss`,
  `parse_file_api_reads_donor_yacht` + 2 synthetic); `assets_osm` 4/4
  (`yacht_osm_real_donor`, `algcen_osm_real_donor` + 2 synthetic);
  `win32_piece` 3/3. Parent also ran `cargo run --bin win32_demo` — real
  640×400 window, gradient samples `TL=0xFF000080 TR=0xFFFF0080
  CENTER=0xFF7F7F80 BL=0xFF00FF80 BR=0xFFFFFF80`, timer auto-close, exit 0.
  Total 22/22 piece tests PASS. Per §7.3 "check outputs, not promises".
- 2026-11-23 **R05-OSS FAIL / A10 attribution escalation (coordinator)
  ACKNOWLEDGED and RESOLVED as STALE**: coordinator routed a FAIL on
  `tests/assets_dds.rs::synthetic_partial_edge_block` to R05-DDS (correctly
  noting it is external to OSS, §5d.5). That failure was real at the moment
  the OSS worker ran its repo-wide suite, but the DDS worker fixed the edge
  case afterwards. Parent re-verified on 2026-11-23:
  `cargo test --test assets_dds` run 3 consecutive times → `synthetic_partial_edge_block ... ok`
  and `7 passed; 0 failed` each time; full `cargo test` → all 22 piece tests
  green; DDS report §acceptance A2/A4 PASS, C7 records the hand-computed
  clipped 5×3 edge block. No re-spawn or follow-up needed (would duplicate a
  fixed piece); recording the stale-attribution correction here.
  Coordinator also asked for a non-multiple-of-4 donor DDS golden: parent
  scanned ALL 1,469 donor DDS headers with
  `rustport/.lane/scan_dds_dims.py` → `non_multiple_of_4: 0`, so such a
  donor golden cannot exist. The synthetic 5×3 clipped-block test is the
  only possible (and present) coverage for that edge case.
  Ticket-id mapping was already added for all FOUR R05 reports (coordinator
  mentioned three; there are four disjoint micro-tickets).
- 2026-11-23 **QA REGISTRY ESCALATION (coordinator) ACKNOWLEDGED**: the QA
  parser reads `docs/t6/reports/T6-R05-AAF.md` as `T6-R05` while the lane table
  uses `T6-R05-AAF`. Checked the report itself: its title (line 1), Worker
  field (line 3) and footer ALL already say the full `T6-R05-AAF`; the
  truncation is in the registry's regex, not the child's report — so no
  child re-edit is warranted. Added the explicit mapping below so the
  registry can match. Re-verified the AAF evidence myself (donor yacht.aaf
  test named and PASS above); note `.aaf` is ASCII so it has no binary
  "size-closure" test — the report's 92-byte file length is an `observed`
  fact, and the donor assertion checks 4 actions with exact ranges.
  Same output check applied to DDS/OSS/OSM above.

- 2026-11-23 **R06 DONE and parent-verified**: `cargo test --test raster_piece`
  → 4/4 (`sha256_self_check`, `geometry_triangle_count_and_depth`,
  `determinism_same_seed_byte_identical`, `terrain_grid_shaded_vs_flat_and_shot`);
  `Get-FileHash` on `rustport/shots/raster_piece.raw` =
  `0C5837772D3A94D70F5A3F84E87E835DA22BCF231ABD1FFEC649B0F15F7AE2EC`.
  Parent viewed `raster_piece.png`: real donor grass/rock pixels, but a
  synthetic diagonal height-shade pattern and a repeating 16×16 tile grid —
  useful as a rasterizer proof, NOT yet donor-composed terrain.
- 2026-11-23 **R07 DONE and parent-verified**: read `docs/t6/reports/T6-R07.md`
  (verdict PARTIAL), rebuilt `cargo build --bin m0_capture` (exit 0), re-ran
  `python tests/tools/m0_compare.py` (exit 0, printed delta line), confirmed
  all six `shots/m0/**` outputs, recomputed SHA-256 of the three key PNGs,
  viewed `ab_side_by_side.png` independently. Parent assessment recorded in
  the M0 GATE RESULT section above — naked-eye read is closer to FAIL, owner
  review required; expansion held.
- 2026-11-23 **R07 spawned** (`ses_df8112a08ffeqtE5YoEqStiqL7`). Parent also
  viewed the donor reference JPG independently: a full isometric-ish RTS
  battle scene with grass, ravines, conifers, towers, massed units and soft
  natural lighting. Parent will challenge any R07 verdict that claims visual
  PASS at this scope without evidence.

## Integration actions needed from coordinator (do NOT edit outside our boundary)

- Root `.gitignore:18` contains `bin/`, which ignores
  `rustport/src/bin/*.rs` (R02 demo, R06 shot driver, R07 capture driver).
  Verified with `git status --short --untracked-files=all -- rustport/`: none
  of the four `src/bin/*.rs` files appear. Coordinator must add
  `!rustport/src/bin/` (or force-add) so these owned sources are committed.
  This lane cannot edit the root `.gitignore`.
- **Donor-pixel compliance decision needed:** `rustport/shots/m0/donor_crop.png`
  and `ab_side_by_side.png` embed pixels from the donor reference screenshot
  (a comparison crop, NOT a donor-install asset binary). They are diagnostic
  outputs, but if the owner's "never copy donor pixels into the repo" rule is
  read strictly, these two PNGs (plus `ab_luminance.png`) should be added to
  `.gitignore` and regenerated by `m0_compare.py` on demand. Parent has NOT
  deleted them — owner/coordinator decides. No donor-install asset bytes are
  in the repo: all DDS textures are read at runtime from `C:\Games\Cossacks 3`.
- `rustport/src/platform.rs` / `rustport/src/assets.rs` / `rustport/src/raster.rs`
  are scaffold stubs owned by integration; this lane must wire the new
  `src/platform/*.rs`, `src/assets/*.rs`, `src/raster/*.rs` modules into them
  after all piece workers finish.

## QA registry ticket-id mapping (explicit — coordinator request)

The QA dashboard regex truncates hyphenated sub-ids at `T6-R05`. Canonical
mapping for `T6-R05*` (all four reports use the FULL id in their own headers):

| Report file | Canonical ticket id | Format |
|---|---|---|
| `docs/t6/reports/T6-R05-DDS.md` | `T6-R05-DDS` | DDS DXT1/3/5 |
| `docs/t6/reports/T6-R05-OSS.md` | `T6-R05-OSS` | skinned mesh |
| `docs/t6/reports/T6-R05-OSM.md` | `T6-R05-OSM` | static mesh |
| `docs/t6/reports/T6-R05-AAF.md` | `T6-R05-AAF` | action ranges |

Do NOT fold these into a single `T6-R05` row — they are four disjoint
micro-tickets with four owners/sessions. Parent ticket label `T6-R05` is a
grouping only, never a report id.

## Notes / open questions

- Spawn mechanism: this harness exposes no direct `subagent`/`task` tool; the
  lane parent uses the OpenCode HTTP API (`POST /api/session` with `parentID`,
  then `POST /api/session/{id}/prompt`) which is the same durable subagent
  mechanism (child reports land in the parent inbox). Children may spawn
  helpers the same way (recursive tree) — API recipe is included in each
  child prompt.
- Donor asset paths for M0 terrain blocks:
  `C:\Games\Cossacks 3\data\terrain\tiles\textures\*.dds` (112 DDS,
  110 × 1024² + `sand1`/`sand2` 256²; families grass/ground/rock/sand/
  sandsea/desert/winter/test — see TERRAIN_DONOR_ASSETS.md §3.2).
- Port-side reference PNGs (read-only, never edited by this lane):
  `app/assets/terrain/blocks/*.png` (112 RGB PNG) and `structs/*.json`.
