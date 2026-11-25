---
id: G25
ticket: WAVE G follow-up / G25 — authoritative UNVERIFIED register
title: "What is still UNVERIFIED after the terrain swarm — evidence to close, owner, priority"
owner: G25 (read-only register)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_SOURCE_EDIT__NO_GATE_CLAIM__NO_PARITY_CLAIM
scope: "Exactly one file written — this report. No Godot launch, no runner job (submit/cancel/unwedge/ack/reset), no .gd/.gdshader/config/test/fixture/tool/result/asset edit."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
reports_root: docs/terrain_swarm_2026-11-25/reports/
inputs: "All 38 Wave A–F reports (A01–A12, B01–B06, C01–C04, D01–D06, E01–E05, F01–F05), all 10 landed Wave G reports (G02, G04, G06, G07, G08, G09, G11, G17, G18, G20), CHARTER.md, WAVE_G_CHARTER.md, SWARM_BOARD.md, README.md (G10)."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "No donor GPU A/B frame exists. Donor parity is UNVERIFIED everywhere and cannot be promoted by any gate, metric, citation or capture of our own build."
---

# G25 — authoritative UNVERIFIED register

## 0. Purpose and hard rule

This register is the single anti-upgrade record for the terrain swarm. It consolidates every
material **UNVERIFIED** item in the 38 Wave A–F reports and the 10 landed Wave G reports. Its
job is to stop a later agent from silently rewriting `UNVERIFIED → PASS`.

> **HARD RULE:** an item below may be marked PASS/closed **only** by producing the exact
> evidence in the "Evidence that closes it" column, reviewed by a second agent where stated.
> None of the following closes anything: a green node-state JSON, a green smoke metric, a
> donor text citation, an offline replay, a static source read, a "no defect by inspection"
> finding, a capture from the wrong path, a blank/missing PNG, or a target band in a plan.

**Labels:** [O] observed, [D] derived, [I] inferred, [U] UNVERIFIED. Status of the swarm as a
whole: **no fresh integrated gate, no reviewed post-fix capture, no donor A/B.** G04's first
selftest (ticket 583) failed on B05's two parse errors; COORD fixed them statically but no
re-run has happened (G04 blocked at pre-flight by stale ticket 582; G20 §2/§5). Therefore every
gate/capture line in CHARTER §5 and C02 is a **target**, not a measurement.

**Coverage:** all 38 A–F reports scanned (grep + targeted reads) plus all 10 landed G reports.
Nine assigned G reports had **not landed** at this write: G01, G03, G05, G12, G13, G14, G15,
G16, G19 (see §8); their assignments remain undelivered, not PASS.

**Priority key:** **P0** = required by CHARTER §5 "result is good"; blocks any GO/gate/PASS
claim. **P1** = owner complaint or post-capture decision; next ticket. **P2** = true-parity /
mechanism debt, structurally hard to close in-repo. **P3** = cosmetic/context debt; never close
by weakening a check.

---

## 1. Global epistemic + gate blockers (P0 first)

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-01 | **Donor GPU parity (all visual/audible/live claims)** | No donor GPU A/B frame exists anywhere; all references are third-party JPEG/WEBP stills of unknown seed/camera/zoom (A11 §6, F04 §9, every report's parity guard). | A **real donor GPU frame** from the donor build on the same GPU, matched seed/camera/scene, pixel-aligned against our frame, on disk, with a C04 second-agent sign-off. No gate, metric, z-score or donor citation substitutes. | COORD / donor owner (donor binary not in repo) | P0-epistemic — unclosable in-repo |
| U-02 | **All integrated gates: selftest 29/29, uitest 17/17, `t_render_mode` PASS, `assert_clean` CLEAN, `SCRIPT ERROR == 0`** | No gate has run on the landed tree. Ticket 583 failed; fixes confirmed only by static read (G20 §2/§5). G04 submitted **zero** jobs (G04 §1–2). | COORD clears stale ticket 582 → `status` shows `pending=0`, lock free, `now_serving==next_ticket`, 0 live Godot. G04 runs `g04-selftest`, `g04-uitest`, `g04-rendermode`, `g04-p0cap`, `g04-realmap` with unique ids; result JSONs `ok`/`exit=0`, all 29 + all 17 steps `passed=true`, `scan-stderr script_error_lines: 0` on every job, `t_render_mode result=PASS`/`seam_missing=false`. No threshold lowered, no `expected_pre_fix_failure` flipped. | COORD (unblock) → G04 (runner) → G05 (review) | **P0** |
| U-03 | **Fresh windowed 64² P0 + real-map captures reviewed** | No post-fix PNG on disk; G06 was written with "no G*.md and no new P0 PNG" (G06 §0); C04 §7 sign-off block is blank. | Two 1280×720 non-blank windowed PNGs (`non_black_fraction>=0.9`, `mean_luma>=40`, `max_luma>=100`, no new seams/black rows), seed 20261113 pinned, plus a completed C04 §7 11-row table signed by a second agent (G05). | G04 (capture) → G05 (second-agent sign-off) | **P0** |
| U-04 | **G01/G02 test atoms parse + runtime behaviour** | Both atoms authored but never run; no result JSON, no PNG (G02 §0/§6, G20 §6). G01's report has not landed either (§8). | `t_select_rect_capture.gd` and `t_ghost_final_stage.gd` each submitted by G04 under unique ids, with result JSON verdicts and PNGs; `SCRIPT ERROR == 0`. Atom files existing on disk is not a run. | COORD → G04 | **P0** |
| U-05 | **"Result is good" / GO decision** | Conditional on U-02, U-03 and every C04 §7 row PASS; none recorded. | C04 §7: all 11 rows ticked PASS, overall "RESULT IS GOOD — all PASS", no required UNVERIFIED, no parity certification. | COORD only (C04 §5 ladder owner) | **P0** |

---

## 2. Selection quad / UI pixels (owner's "quad still not OK")

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-06 | **Real selection-quad pixels (during drag)** | `t_select_rect.json` 23/23 is **node state only**; `capture_path: "no PNG assertion"`, sole PNG path `bselrect_probe.png` absent; colour never asserted; no quad PNG on disk (D06 §1-2/§4, D01-2). | D03 three PNGs `before/during/after.png` from an **input_ctl-inclusive** path: result JSON proves `ov.get_parent()==capture_view3d`, `run_mode=windowed_real_input`, `event_coord_scale=[1,1]`; pixel checks ≥3/4 edge midpoints + ≥2/4 corners marquee-coloured, interior unfilled vs before within 8/255, hidden in after; `frames.json`; `SCRIPT ERROR == 0`. | G04 (capture) → G05 (C04 R7 review) | **P0** |
| U-07 | **Quad capture-path integrity (D03 Trap A)** | `Screenshot3DViewport` reparents only `world`+`camera`; a saver-style frame contains no quad. A quad-less frame is ambiguous between game defect and capture defect (D03:72-83, C04 §2 item 6). | `ov.get_parent()==capture_view3d` + real windowed input in JSON. Without it the item is `UNVERIFIED (WRONG CAPTURE PATH)` — never "quad broken", never PASS. | G04 / G05 | **P0** |
| U-08 | **Readback integrity (D03 Trap B)** | Root-window texture reads blank under `gl_compatibility`; headless `SKIP_CAPTURE` writes no PNG. | Non-null, non-empty, 1280×720, non-transparent first pixel from `capture_view3d`; raw `.raw.png` sidecar only with `camera_current=true` diag. Otherwise `UNVERIFIED (NO/BLANK PNG)` and required-item FAIL (C04 G-Q1). | G04 / G05 | **P0** |
| U-09 | **Wall-selected → subsequent drag still produces quad (donor bug NOT to copy)** | "No defect by inspection" from control flow (D05 §3, G18 row 1); live A/B never captured. | A CAP-3 frame where a wall is selected first, then a drag produces a quad and selects units; if that scenario was not captured, the sub-check stays UNVERIFIED (C04 R7). | G04 / G05 | P1 |
| U-10 | **Marquee colour/width live rasterisation** | Painter draws yellow 1 px no-fill by code; donor `selection.cfg:3-14` values cited; live rasterisation UNVERIFIED (D05 #9, B05 §8, F03 G3). | One-frame quad capture sampling outline RGB/width, or a pure `_draw()` argument probe; label PORT APPROX (no donor A/B). | G04 / UI follow-up | P2 |
| U-11 | **Native inside-box predicate** | Exact native test (centre vs AABB vs frustum vs `GetGameObjectSelectionSizeByHandle`) unrecoverable; EXE body unread (D02 item 15, DSEL-01 claim 24, F05 row 5). | Donor engine decode/trace of the predicate, or donor GPU A/B. Port `Rect2.has_point(e.pos)` stays PORT APPROX. | donor-decode ticket | P2 |
| U-12 | **Donor quad raster / brush line-step / faint fill** | Donor `menu.cfg` begin/end hooks empty; brush is intent-only (D02 item 21, F03 §... "UNVERIFIED rasterisation"). | Donor GPU frame or donor engine decode of brush begin/end hooks. | donor-decode ticket | P2 |
| U-13 | **Camera-follow-drag mechanism ("map moves with you")** | Official 2016-11 RU/UA prose OBSERVED; no donor script ties pan speed/band to drag state; `SetClipCursor` secondary only; no A/B frame (F03 G1/O2, D02 item 14/§8, G08 §1, B05 :226). P6 discrepancy: a generic edge-scroll already fires during LMB drag; static reading cannot tell whether a runtime reason suppresses it. | (a) A windowed no-code probe by G04 settling Q2 (is pan suppressed during LMB drag?); (b) donor engine decode of band/speed/clamp for Q1; then implement G08's gate-not-second-pan in `camera3d.gd` and pass its §6 acceptance: CAM-RV-01 `t_view_rect_rv.gd` byte-identical **20/20**, jump APIs byte-identical, opt-in ON moves `_target` and selects an initially off-screen unit, minimap drag contributes no follow, wall-bug regression green. No invented speed/band. | camera owner (`camera3d.gd`) + COORD/G04 probe | P1 |
| U-14 | **Live hotkeys / Ctrl+A / Z combos / Shift-click empty** | Code implemented; live key test UNVERIFIED (D05 :77-80, G18 "WIRING FIXED; EDGE CASES/AUDIBLE UNVERIFIED"). | Real windowed key/click capture naming each combo in `t_select_rect`/`t_load_usability` or a new atom; uitest `hotkeys_live` must name Ctrl+A. | UI follow-up + G04 | P2 |
| U-15 | **Selection sounds audible parity + empty/building edge cases** | `play_selection()` wired once per `_set_selection()`; donor cues/timing UNVERIFIED; cleared-panel behaviour UNVERIFIED (D05 #7/#8, G18). | Audio probe/capture of the cue per selection type + donor A/B; guard `not arr.is_empty()` decided. | audio/UI follow-up | P3 |
| U-16 | **Hover cursor over HUD; top-strip click-through (#5/#6)** | OPEN owner decisions; live cursor capture UNVERIFIED (D05 :58-59, G18). | Windowed cursor/click capture over top bar/minimap + owner decision recorded with citation or PORT APPROX. | UI follow-up + COORD decision | P2 |
| U-17 | **Flat-root morph / procedural selection aura appearance** | PORT APPROX warning expected to persist; no live occlusion capture (G18 rows 44-45/242, D05 §2). | Live A/B capture; no donor `selection.friend`-style material mapping exists in port. | UI follow-up | P3 |

---

## 3. Ghost final stage / footprint

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-18 | **Ghost final-stage runtime pixels** | B06 changed mesh resolution in code; G02 atom authored, never run; no during/cancel PNG; no finished-hologram visual check (B06 §6, G02 §1/§6, E04). | Run `t_ghost_final_stage.gd` windowed → result JSON with checks 4/5/6/9/10/11/12 PASS, `ghost_mesh_is_final_finished` identity = `_mesh_info("hou","building")`, no foundation, two GPU PNGs; then C04 R8 frames D/E (`ghost_valid|ghost_invalid.png`) reviewed by G05 for translucent last-stage silhouette, green/red, alpha ≈0.4, cleared on cancel. | G04 → G05 | **P0** |
| U-19 | **Footprint honesty (E04/G02 strict check 7)** | `world3d_fx.gd:632` hides `_ghost_mesh` (thus `Footprint`) when a mesh resolves → check 7 expected **RED**; kept strict, not re-scoped (E04 §7, B06 §6, G02 §1). | G09 follow-up in `world3d_fx.gd` shows the overlay alongside the finished mesh **and** scales it with `can_place()`'s radius (`bld_rm(0,sid)` else `def.radius`); atom check 7 flips to PASS with visibility + `BoxMesh(1,0.05,1)` + scale operands unchanged; `expected_pre_fix_failure` stays as provenance only. | G09 follow-up owner (`world3d_fx.gd`) → G04 | P1 |
| U-20 | **Port footprint radius divergence (internal honesty gap)** | OBSERVED: gate uses `bld_rm("hou")≈4.113 m` (`:4022-4023`) while ghost draws `_building_radius("hou")=1.5 m`; F02/B06 "one shared radius" is stale (G09 §1.3/§4). | Atom check-7 PASS with `stats.ghost_footprint_source` matching the gate branch; no edit to `can_place()`/`game.gd`. | G09 follow-up owner | P1 |
| U-21 | **Donor `.prop` collision-mask footprint / donor ghost appearance** | No `.prop` file or decoded mask in repo (`DC_FORMATS.md:23` "Not inspected"); donor ghost mesh/colour/size UNVERIFIED; "finished hologram" is an **owner directive**, not a donor-proven behaviour (F02 §3.1, F05 row 4, E05 §5, G09 §4). | Decode donor `<sid>.prop` `collisionmaskproperty.Mask` (1 cell = 0.5 map cells) + donor GPU ghost frame. Until then every mask/scale is PORT APPROX; do **not** upgrade the charter sentence to donor fact. | donor-decode ticket | P2 |
| U-22 | **Stage-art inventory residual (7/19 sids, `<sid>a` scaffolds, `wal`/`gat`, per-stage band masks)** | `wal`/`gat` mapping ambiguous, 10 base scaffolds are 8-vertex degenerate with UNVERIFIED visual role, stage-specific tint masks UNVERIFIED, resources not re-verified pixel-by-resource (E02 B4–B10). | Donor decode + runtime resource probe + visual capture per sid. No fabrication from guesswork. | asset/data follow-up | P2 |

---

## 4. Terrain pixels: relief, colour, tiling, alpha

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-23 | **Relief / cliff / ravine appearance (owner's visual complaint)** | B04 promoter is PORT APPROX; visual effect UNVERIFIED, Python numeric replica only, no Godot (B04 §7). A05 Fix #1 deferred; `ravine_big` has no port grid; `k_ravine_1` BLOCKED/donor-disabled; donor blend math and row-flip UNVERIFIED (A05 §7, B03 §6, G07 §7). H-6 must not be flipped. | G07 two-ticket plan: R-DATA derives `k_ravine_big_stone_1` 8×10 table (bit-exact min/max vs `pattern.lib:730045-730046`); R-CODE adds Tier 1 + Tier 2 `hil1`/`g_hil4` in `game.gd`; runtime `--dump-map` shows `meta.relief_grid.candidates>0`, `applied_cells>0`, changed height/tileblock hashes; `t_map_variety` 5/5, `scan_map.py` all green; fresh G04 capture reviewed by G05 for steeper silhouettes + no seams. Visual parity with donor stays UNVERIFIED. | R-DATA + R-CODE (`game.gd`) → COORD/G04/G05 | P1 |
| U-24 | **Colour B/G band / b\* deficit** | Measured pre-fix P0 `B/G=0.326`, `b*=35.44`, S 0.675 vs donor `B/G 0.410–0.615`, `b* 14.9–27.1`, S 0.457–0.591 (A07-E2). G06 recommends conservative `vec3(1,1,1.5)` tint but **did not apply it**; no G04 frame existed, so its band predictions [D] are conditional (G06 §3/§5 open Q1-3). | COORD applies the 502-line-neutral one-line tint after G04 baseline; re-capture; G05/C01 re-measure P0 **and** real-map: `B/G 0.41–0.53`, `b* 25–29`, `S 0.50–0.59`, luma 64–94; check sand/rock for cold tint. Hitting bands is **not** donor parity (U-01). | COORD (apply) → G04 → G05 | P1 |
| U-25 | **A11 low-frequency / BV32 deficit (~28.6×), live tile histogram** | Pre-fix `BV32 n640 8.7 vs donor median 247.6`, `grad 5.00 vs 1.30`, luma std 10.6 vs 20.1; energy must move high→low frequency, not by dither (S-25-09). A04 top-5 73%→58.5% is **offline replay**; live histogram UNVERIFIED (A04 §8; A11 §6 confounds). B03 redirect cannot be claimed to move BV32 (G06 §5 item 5). | Live `tile_index_hist` from a fresh dump/capture + C01/A11 metrics on the reviewed frame showing the named numbers moving in the stated direction on A11's ROI, camera/zoom confound stated. Do not invent numbers; never substitute a matched-scene ratio for parity. | COORD/G04 → G05; B03-data follow-up | P1 |
| U-26 | **2 m `fract` repeat still present after B01** | Mirror/warp reduces coherence but does **not** remove the 2 m world-XZ repeat (README §4 RC-1; B01 §6 residual). 2 m is donor grid geometry, not a verified donor UV-repeat literal (F05 row 1). | Fresh frame showing no visible diagonal streaks/moiré under C04 R1–R6; a donor A/B would be needed for any "donor-shaped texgen" claim. | G04/G05; B01-follow-up | P1 |
| U-27 | **Sentinel black cells / mask→RGB fold residual** | B01 guard bypasses `(3,3)/(7,3)` sentinels and compresses `a`; no post-fix capture confirms absence of black cells/cliffs, and the structurally correct A02-P5 (mask only where ids differ) was not landed (A02, README RC-3/B01). | C04 R5 scan of fresh P0 + real-map: `non_black_fraction>0.9`, no black cliff faces/rows, no dark-grid regression; tile→patch rule still PORT APPROX (U-31). | G04/G05 | P1 |
| U-28 | **`MODE_ARRAY` atlas fallback has no mips / seam LOD spikes** | A06 Fix 1 not landed; `_load_array()` still builds `Texture2DArray` without mips; possible 2 m seam bands (B02 §6, G17 §7 item 6). | Runtime proof of which load path is used on target + a capture with no seam bands; if array mode is active, a fix ticket. | loader owner + G04/G05 | P2 |
| U-29 | **Mirror seams / P4 tonal shift (B01 residual risks)** | Art may not be edge-continuous after 4-way mirror/UV warp; no A/B (B01 §6). | Fresh frame with no new seams/dark bands under C04 R5; donor A/B for parity. | G04/G05 | P2 |
| U-30 | **`textureGrad` LOD validity / `textureSize` translator behaviour** | Gradient taken before mirror/warp is INFERRED/DERIVED, not an A/B result; whether the Compatibility GLSL translator folds `textureSize()` to a constant needs disassembly (G17 §2 item 3, §7 item 4). | Driver profiler/shader disassembly + post-fix capture; no silent removal of `textureGrad` (would reintroduce A06 cause #5). | perf/shader follow-up | P2 |

---

## 5. Donor engine internals (CONFIRMED_UNVERIFIED — do not guess)

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-31 | **Tile→alpha patch rule (tile id + boundary → patch index)** | 8×4×64² geometry RESOLVED; the selection arithmetic (`reftile.lib:10-12`, `reftile.mat`, `tile_id+dir+variant+half+opposite`, `tsDouble`/`ttExtended`/`TileXOffset/YOffset`, exact complement pairs) CONFIRMED_UNVERIFIED; almanac does not parse `.bmp`/`.actor`/`.tlf` (A08 §8 item 3, DALPHA-01/02, F05 row 2, A01 §1). | Donor decode of `alpha.bmp` @1070 + `reftile.lib`/`.mat` arithmetic, ideally a donor GPU frame of the seam transitions. Until then `alpha_patch_uv()` and `mask_to_alpha=1` stay PORT APPROX. | donor-decode ticket | P2 |
| U-32 | **Engine eye planes / `gl_EyePlaneS/T[0]` + `gl_TextureMatrix[0]`** | Ground texgen plane values CONFIRMED_UNVERIFIED — packed `.bind`, entropy 7.96; UV *method* OBSERVED but numeric values unrecoverable (A08 §8 item 2, RV-TRN-01 verdict A, F05 row 7, A01 §1). | Donor shader/program binary decode or donor GPU trace. Do **not** invent plane values or a `bmTransparency` pass count. | donor-decode ticket | P2 |
| U-33 | **Face-promotion rule / 25° `AngleX/AngleZ` entry** | Literals OBSERVED; the rule that promotes a base tile to `vf/vs` and how 25° enters geometry/texgen UNVERIFIED; port `_relief_face_at()` is span-scaled PORT APPROX (A08 §8 item 4, A05 §4, B04 §7). | Donor engine decode + fresh capture with `stats["b04_relief_promotion"]` on real slopes; normal-tilt lighting effect UNVERIFIED for real maps (A01 :109). | donor-decode + G04/G05 | P2 |
| U-34 | **`bmTransparency` pass count / blend equation** | CONFIRMED_UNVERIFIED (A08 §8 item 5, DTRN-01 §8). | Donor engine decode. No invented pass count. | donor-decode ticket | P2 |
| U-35 | **Height-grid→mesh topology / LOD / chunking / exact normal formula** | UNVERIFIED (A08 §8 item 6); mountains live in `terrainmesh*` props, separate ticket (F05 row 6, G07 §2.2). | Donor decode + runtime topology probe. | donor-decode ticket | P3 |
| U-36 | **Donor metres-per-cell literal** | Local `gc_meters_to_tile=2` CONFIRMED from `dmscript.global:171`; the **literal is not published online** → online UNVERIFIED (F05 row 1). Keep `TILE_M=2.0` donor-grounded; do not re-derive from collision half-cell. | Online source publishing the literal, or donor binary decode. | research/donor-decode | P3 |
| U-37 | **Runtime activity of `;`-commented `.inc` scripts (generator/smoothing/detail)** | Authoritative *intent*, not proven activity (A08 §8 item 7; smoothing lists, base fill, aspect/rock selection rows 2/4/5/8 in §7). | Donor runtime trace. Port reproductions stay PORT APPROX. | donor-decode ticket | P2 |
| U-38 | **Water `hmapTex`/`hmapW/H/Min/Max` binding; fogMode uniform bridge** | `heightmapwaves0.tga` is **not** the binding; scene-fog ACTIVE vs "off by default" conflict preserved (A08 §8 items 8-9). | Donor runtime uniform trace. | donor-decode ticket | P3 |
| U-39 | **Season/biome donor runtime activity** | Enum 0/2/3 and winter art exist; donor activity UNVERIFIED — label every comparison PORT APPROX (A12 §2/§5-6). | Donor runtime trace + donor GPU season frames. | donor-decode ticket | P3 |
| U-40 | **Exact donor selection-epsilon / `spmFrame` / `spmRunTime` / FOV / `ArcTan` / double-click 0.5 s semantics** | Byte recon OBSERVED, native producer/meaning UNVERIFIED (D02 items 4/12/13/39/41, F03 O1/G8, B05 §18). Port uses PORT APPROX. | Donor engine decode of the native calls + donor GPU timing A/B. | donor-decode ticket | P3 |
| U-41 | **Config-overlay A/B validity for `uv_repeat` / `mask_to_alpha` (G-A0)** | Both are shader uniforms with **no config bridge**; `--config` keys are unread. An overlay-only "arm" has UNVERIFIED attribution (A12 :120-121, C04 §10 item 3, C02 G-A0). | An additive key **and** one `set_shader_parameter(...)` binding line confirmed present, with seed/camera/`start_zoom` pinned and `--dump-config` logged per arm; otherwise record attribution UNVERIFIED and FAIL the arm. | COORD / A12 K1-K2 follow-up | P1 |
| U-42 | **Config drift: shipped map 240² not 320²; blank-detector false positive** | A09 §1/§2.2 and G04 §2; detector can reject a valid real-map frame. Do not edit the detector. | Pin/override per A09 before A/B; use `.raw.png` + `camera_current=true` diag for blank checks. | COORD/G04 | P1 |

---

## 6. Performance / loading (measured only by analysis)

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-43 | **Loading stall S3/S4 (window freezes at "Loading art..."; work after overlay hides)** | G17 call chain OBSERVED: B02's synchronous ~683 MiB mip build + upload runs on the main thread inside the already-synchronous 0.90 stage; "worsened in probability" is INFERRED — **windowed drag UNVERIFIED**, never profiled. S4 first-draw upload hitch UNVERIFIED (G17 §3.2/§6, UX_LOADING). | Windowed drag of the title bar at **every** progress stage, specifically 0.90 after B02 (UX_LOADING R3 acceptance); a `WorkerThreadPool` move of mip gen with before/after drag evidence; a frame-time/profile trace and `nvidia-smi` VRAM reading. Do not weaken R3. | UX_LOADING owner + COORD/G04 | P1 |
| U-44 | **All G17 cost ratios (8× texel fetches, ~29 MB/frame, ~1.8 GB/s, +171 MiB/33% VRAM)** | Analytical order-of-magnitude only; no GPU A/B, frame time, bandwidth measurement, exact board VRAM/clock, or cache-hit rate (G17 §7 items 1-5). | Benchmark on the actual MX130 + `nvidia-smi` + driver profiler/disassembly; restate only measured numbers. | perf follow-up + G04 | P2 |
| U-45 | **Godot `generate_mipmaps(false)` single-threaded / exact cost** | INFERRED from knowledge, implementation not inspected; editor `.import mipmaps=true` timing UNVERIFIED (G17 §3.2/§7 item 3, B02). | Engine source read + timing profile. | perf follow-up | P2 |

---

## 7. Live-by-inspection items (G18 / D05 — no live A/B)

All rows in this section are **"NO-DEFECT BY INSPECTION / GUARD PRESENT IN CODE; LIVE UNVERIFIED"**.
Code reading proves no known reproducing path; it does not prove runtime equivalence. Close each
with a live windowed real-map A/B of the named behaviour; never by weakening a guard.

| ID | Item | Source | Owner | Pri |
|---|---|---|---|---|
| U-46 | Ships-on-land / naval clipping / fire-cancel | G18 :91 (`_is_water` guard) | naval follow-up + G04 | P3 |
| U-47 | Relief/shore traversability, bridge entities, unit stranding | G18 :100 (no bridge entity in port) | gameplay follow-up + G04 | P3 |
| U-48 | Artillery crew deployment animation fidelity | G18 :109 | cosmetics follow-up | P3 |
| U-49 | Fog/monitor brightness/gamma/exposure (fixed port alpha ladder; donor depth fog off) | G18 :118 | rendering follow-up | P3 |
| U-50 | Desert/arctic NTM biome, black-spot/border regressions | G18 :136 | asset/QA follow-up | P3 |
| U-51 | Exhaustive config combination matrix (`_donor_id()` validation only) | G18 :154 | config/QA follow-up | P3 |
| U-52 | MSAA/AA as a "fix" — explicitly NOT copied; anisotropy inert for this sampler | G18 :163, G17 §4 | none (do-not-copy) | P3 |
| U-53 | Drag/selection state persistence across restart paths | G18 :224 | QA follow-up | P3 |
| U-54 | Command obedience for selected own units (`cmd_*`/`_nav_repath`) | G18 :269 | gameplay follow-up | P3 |

---

## 8. Undelivered Wave G assignments (not PASS by default)

| ID | Item | Why UNVERIFIED | Evidence that closes it | Owner | Pri |
|---|---|---|---|---|---|
| U-55 | **G03 test audit** (other stale wrong expectations in `t_select_rect.gd` after COORD's :525 fix) | No `G03_test_audit.md` landed. | Report lands with cited audit of remaining expectations; no test weakening. | G03 / COORD dispatch | P1 |
| U-56 | **G05 visual review of new captures** (C04 protocol + C01 metric) | No `G05_visual_review.md` landed; with no G04 capture, there is nothing to review. U-03/U-06/U-18 reviews are blocked on it. | G04's captures exist → G05 report with completed C04 §7 table and second-agent verdict. | G05 (after G04) | **P0** |
| U-57 | **G12 runner hygiene / G13 backup audit / G14 static audit / G15 tile measure / G16 season check / G19 hotkeys** | None of these reports landed; runner counter alignment, backup byte-identity, static parse of the six edited files, live tile histogram, season atlas consistency and hotkey gaps have only their pre-fix/planning statements. | Each report lands with its named evidence; G13 must re-check backups exist for every modified B file (C03 was a pre-B-edits snapshot); G14 must not be replaced by "G20 saw no parse cause". | G12–G16, G19 / COORD dispatch | P1–P2 |
| U-58 | **G01 report** (`G01_select_capture_atom.md`) | The atom file `variant3d/tests/t_select_rect_capture.gd` exists on disk (observed this pass) and G20 §6 cites it, but no G01 report landed; authorship/provenance is undocumented and the atom is unrun (U-04). | G01 report lands documenting the atom and no-run status; G04 runs it. | G01 / COORD dispatch | P1 |

---

## 9. Anti-upgrade checklist (read before writing any PASS)

1. **Never** write "gates green", "donor parity", "result is good", or convert a required UNVERIFIED
   into PASS without U-01 (donor A/B) / U-02 (G04 result JSONs) / U-03 (reviewed captures) as applicable.
2. A **green JSON** for `t_select_rect` (23/23) proves node state only — not pixels (U-06).
3. A **green smoke metric** (C01) is "heuristic only, NOT a fidelity gate or donor proof" — not parity.
4. A **donor text citation** proves donor *intent/structure*, never donor *appearance* (U-01/U-21/U-31/U-32).
5. A **saver-style frame with no quad** is `UNVERIFIED (WRONG CAPTURE PATH)` — neither "quad broken" nor PASS (U-07).
6. A **blank/null/missing/root-texture readback** is `UNVERIFIED (NO/BLANK PNG)` and a required-item FAIL (U-08).
7. An **offline replay** (A04 top-5 58.52%) is not a live histogram (U-25).
8. A **static parse read** (G20 §2) is not a runtime gate (U-02/U-04).
9. A **`--config`-only arm** for `uv_repeat`/`mask_to_alpha` is not an A/B (U-41).
10. **No test weakening**: no threshold lowered, no assertion deleted, no `expected_pre_fix_failure`
    flipped (E04/G02 check 7 stays strict until U-19 actually closes it).
11. **No donor parity from matched bands**: hitting A07/A11 numeric bands is PORT APPROX internal consistency (U-01).
12. **No synthetic dither/noise** (decision S-25-09) and no invented donor constants; every substitute labelled PORT APPROX.
13. **One Godot at a time**, only via the runner, only G04 in Wave G; this register's writer ran nothing.

---

## 10. Bottom line

After the swarm: **zero** fresh integrated gates, **zero** reviewed post-fix captures, **zero**
donor GPU A/B frames, **zero** run quad/ghost atoms. The landed changes are structurally
verified by source reading only; every visual, audible, live-key and parity claim in A01–F05 and
G02–G20 remains UNVERIFIED per the table above. The most urgent closes are U-02 (unblock COORD
ticket 582 → G04 gates), U-03/U-06/U-18 (G04 captures + G05 review), U-23/U-24/U-25 (relief,
colour, tile-data on the fresh frame), and U-43 (loading stall). Donor-internal items (U-31…U-40)
and donor parity itself (U-01) require donor access and cannot be closed by this swarm.

*End of G25 register. One report written; no runner job, no Godot process, no code, test, config,
asset, result or queue edit; no gate claim and no donor-parity claim.*
