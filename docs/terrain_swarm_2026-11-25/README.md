---
id: TERRAIN-SWARM-README
title: "Cold-readable consolidation — terrain visual-quality swarm (Wave A–F) + Wave G"
owner: G10 (consolidation; NEW file only)
created: 2026-11-25
status: CONSOLIDATION__READ_ONLY__NO_RUNNER_JOB__NO_GATE_CLAIM__NO_PARITY_CLAIM
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
reports_root: docs/terrain_swarm_2026-11-25/reports/
labels: [observed, derived, inferred, UNVERIFIED]
---

# Terrain swarm README — start here (cold read)

## 0. Stance — read this before any number or verdict

This file consolidates **all 38 Wave A–F reports** (A01–A12, B01–B06, C01–C04, D01–D06,
E01–E05, F01–F05) and the landed **Wave G** reports. It is written to be read cold, in order,
with no prior session context.

Label key used by every report and by this README:

- **[O] OBSERVED** — literal code line, import flag, config value, result-JSON value, or a
  measurement made with Pillow/NumPy on a named file.
- **[D] DERIVED** — arithmetic or control-flow consequence of cited [O] facts.
- **[I] INFERRED** — visual attribution with no pixel-aligned donor frame.
- **[U] UNVERIFIED** — cannot be proved from readable data. Above all, **donor parity is
  UNVERIFIED everywhere**: no donor GPU A/B frame exists (CHARTER §3, §5; every report's
  parity guard). No report, and this README, claims donor parity.

Two hard honesty gates for the reader:

1. **The gates are NOT green.** The first integrated selftest (ticket 583) failed on B05's two
   parse errors; those were fixed by COORD, but no fresh integrated gate has run since. G04,
   the sole Wave G runner owner, failed pre-flight and submitted **zero** jobs (G04).
   Every "29/29 / 17/17 / t_render_mode / assert_clean CLEAN / captures clean" line is a
   *target* from CHARTER §5 and C02's plan — not a measured result on the landed tree.
2. **No donor-parity claim is made or implied.** Structural donor facts are quoted as
   OBSERVED from donor text; every port substitute is labelled **PORT APPROXIMATION**. A green
   metric or gate would not convert parity to PASS.

## 1. Standing rules (binding on all waves; restated for Wave G)

From CHARTER §3 and WAVE_G_CHARTER.md:

- **Only G04 runs Godot / submits runner jobs.** All other Wave G agents MUST NOT launch
  Godot, nor submit/cancel/unwedge/ack/reset runner jobs. This protects the FIFO and the
  one-Godot-at-a-time rule. (WAVE_G_CHARTER.md:31; G02, G04 honoured it.)
- One Godot at a time, via `python variant3d\tools\godot_runner.py run --id <UNIQUE>` only;
  query `status` before submitting; never call `godot` directly. Windows: `python`, not
  `python3`; PowerShell `;` not `&&`.
- No test weakening: no threshold lowered, no assertion deleted, no
  `expected_pre_fix_failure` flipped without a landed fix; no synthetic dither/noise/hash
  field (decision S-25-09); no invented donor constants — label every substitute PORT APPROX.
- **Backups before edits**: `inbox/backup/<file>.bak-<TICKET>`.
- **Disjoint ownership**: analysis agents edit only their own report; each B owner edits only
  its one exclusive source file (B02 also one atlas `.import` pair); COORD integrates.
- Second-agent visual review: a capture's builder never self-certifies; metrics never
  override the image read (C04).
- When a report lands, COORD may send a follow-up via the same session; stay available.

## 2. Resume order (what to read, in what sequence)

1. **Rules and board** — [CHARTER.md](CHARTER.md), [WAVE_G_CHARTER.md](WAVE_G_CHARTER.md),
   [SWARM_BOARD.md](SWARM_BOARD.md). Note that C03's ownership audit was a *moment-in-time*
   snapshot taken before the B edits landed.
2. **Root causes first** — A01, A06 (pixel-measured texgen/filter defect), A02 (mask),
   A03/A04 (tile art and diversity), A05 (relief), A07/A11 (colour and reference targets),
   A08 (donor truth). Section 4 below summarises the six measured root causes.
3. **The landed fixes** — B01–B06 (Section 5), with their exact before/after and backups.
4. **QA/protocol and constraints** — C01 (metric tool), C02 (gate plan), C03 (ownership),
   C04 (visual-review protocol); A09 (capture plan), A10 (regression constraints),
   A12 (config knobs).
5. **Feature areas** — D01–D06 (selection quad/UI), E01–E05 (ghost final stage),
   F01–F05 (online donor research).
6. **Wave G status** — G04 gate log (blocked at pre-flight) and G02 (new ghost atom), then
   any other G reports that have landed. Section 6 gives honest gate status; Section 7 the
   ownership discipline; Section 8 the failure register.
7. **Report index** — Section 9, topic-grouped with links to every report.

## 3. Folder / file map

```
docs/terrain_swarm_2026-11-25/            <- this swarm's docs
  CHARTER.md                              rules, suspects, definition of good
  WAVE_G_CHARTER.md                       Wave G assignments; only-G04-runs-Godot rule
  SWARM_BOARD.md                          38-agent ownership map (A/B/C/D/E/F)
  README.md                               THIS FILE (G10)
  reports/                                one report per agent (38 A–F + landed G)
    A01..A12, B01..B06, C01..C04,
    D01..D06, E01..E05, F01..F05, G02, G04   (other G* land during the wave)

variant3d/                                the 3D port under repair
  shaders/terrain_tileindex.gdshader      B01 (mirror/warp, mip hint, sentinel guard, textureGrad)
  scripts/tile_atlas_loader.gd            B02 (runtime mip chain)
  assets/terrain/atlas/tile_index_atlas.png.import          B02 (mipmaps=true)
  assets/terrain/atlas/tile_index_atlas_winter.png.import   B02 (mipmaps=true)
  scripts/game.gd                         B03 (tile diversity; detail-pass re-roll, redirects)
  scripts/world3d_terrain.gd              B04 (relief-aware face promotion)
  scripts/input_controller.gd             B05 (Rect2 fix, drag teardown, viewport mapping, click UX)
  scripts/world3d_fx.gd                   B06 (ghost = finished mesh first); NOTE: board named
                                          world3d_entities.gd, COORD corrected to world3d_fx.gd
  scripts/world3d_entities.gd             left byte-identical by B06 (construction selector)
  tools/terrain_ab_metric.py              C01 (new smoke metric tool; NOT a fidelity gate)
  tools/godot_runner.py                   the only legal Godot door (FIFO, one at a time)
  tools/smallmap_capture.py               read-only stats / scan-stderr inspectors
  tests/t_select_rect.gd                  COORD fixed :525 expectation (wrong Rect2)
  tests/t_select_rect_capture.gd          G01 (NEW test atom, from D03 proposal)
  tests/t_ghost_final_stage.gd            G02 (NEW test atom, from E04 proposal)
  tests/results/*.json                    gate result envelopes (t_select_rect.json 23/23, etc.)
  config.json                             shipped map = 240² (not 320²), seed 20261113,
                                          camera.start_zoom 0.3448276

inbox/backup/                             *.bak-B01 .. *.bak-B06 (one per implementation owner)
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\   scratch/captures/metrics — NEVER in the repo
```

Key distinction: **the reports directory is read-only evidence**; the only source edits are
the six B-owned files (plus COORD's two test fixes) and the new G01/G02 test atoms.

## 4. Measured root causes (why the ground looked synthetic)

All figures are [O]/[D] from the named reports, measured on the **pre-fix** tree unless noted.
The fixes in Section 5 mostly target the *mechanism*; their visual effect is [I]/[U] because no
post-fix capture has been evaluated.

### RC-1 — Hard 2 m world-XZ `fract` grating (A01 Rank 1; A06 Rank 2)

- Shader `:311` `st = (dot(worldpos,X), dot(worldpos,Z))`, `:214` `uv_repeat=(0.5,0.5)`,
  `:392` `tile_rgb(v_tile, fract(v_st*uv_repeat))` = one verbatim 1024² atlas cell per 2 m,
  one global phase (A01 §1).
- A01 measured a horizontal ACF peak at **76 px**, matching the predicted **73.7 px** for a 2 m
  cell at the P0 camera within 3 %; the lag grows monotonically **60→91 px** down the frame —
  the perspective signature of a fixed world grid sheared into the "faint diagonal streaks".
- A06 measured FFT peaks at **fx = ±16 cycles/1280 px (80 px)**, `fy≈0`, and a σ=22 chevron
  pattern. The cell is minified ~14× horizontally, ~26× vertically at frame centre.
- Donor eye-plane values are CONFIRMED_UNVERIFIED, so the 2 m repeat is **donor-grounded
  2 m grid geometry** (A08/F05 row 1), not a verified donor UV-repeat literal.
- B01's mirror/warp (RC-6/§5) reduces coherence; it does **not** remove the 2 m repeat.

### RC-2 — No mipmaps on the shader-facing atlas (A01 Rank 2; A06 Rank 1 — "highest-leverage fix")

- Shader `:60` asked for `filter_nearest_mipmap`, but `tile_index_atlas.png.import:26` was
  `mipmaps/generate=false`, and the loader built its texture with `ImageTexture.create_from_image`
  from `Image.load()` (no `generate_mipmaps()`), so the runtime texture had **level 0 only**
  (A02/A06/B02 [O]). The `.import` flag alone could not fix that path.
- ~10.4–14.4 atlas texels per screen pixel at mid-screen (A06); Nyquist requires ~3.7 mip levels.
  Level-0 nearest minification folded the 2 m grating into coherent moiré and destroyed the
  vertical ACF period.
- B01 changed the sampler hint and B02 generated a real mip chain at runtime (Section 5).

### RC-3 — Sentinel black cells from constant-0 mask patches (A02 Rank 1)

- `alpha_patch_uv()` (`:365-378`) decomposes the tile id into `dir/variant/half/opposite`;
  `(3,3)` and `(7,3)` are donor-authored **constant-0 sentinels** (DALPHA-01 §6.4; A02-E4
  patch mean 0/255).
- **8 of 124 ids** select those sentinels (incl. `grass_ground2`, `sand6`, `rock6vf/rock6vs`),
  so `:427` `rgb = rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular` wrote
  `rgb = v_specular = 0` → **pure black cells / black cliff faces** (A02 §2 [O]+[D]).
- B01 added an inline sentinel guard (Section 5). The structurally correct fix (mask only
  where neighbouring ids differ, A02-P5) needs a data handoff and was **not** landed.

### RC-4 — Dominant bad tile art + too few tile ids (A03, A04, A07, A11)

- A03 measured the actual block art: `grass_ground1/2/3` (idx 14/15/16) are the worst repeating
  diagonal-vein lattices (FFT-aniso; `grass_ground2` highest coarse-structure fraction 0.39);
  `grass2` is a directional outlier (FFT-aniso **5.16**, Sy 1.81); `ground1` is off-palette;
  `grass3/grass4` carry authored horizontal seams (+8.5/+7.6 luma). Best isotropic/seamless:
  **grass9, test9, test8**. `test0/10/11` are exact pixel copies of other cells (A03 E03).
- A04 measured real 320² dumps: pre-TRN-DATA top-5 **73 %**, and **29.93 %** of cells lie in
  uniform ≥100-cell components (largest **2,036 cells** ≈ 8,144 m² of one atlas cell). Post
  TRN-DATA offline replay: top-5 **58.52 %**, distinct 32, `test7+8` 14.89 % — still a live
  histogram is UNVERIFIED (A04 §8).
- A07/A11 measured the P0 fixture as `UV2.x ≡ 0` (all `grass1`, face 0): luma 91.4 sits inside
  the donor range, so the gap is chromatic/textural, not brightness. `B/G=0.326`, `b*=35.44`
  (yellow/blue-deficient), saturation 0.675 (highest of 13 ROIs); `BV32 n640` **8.7 vs donor
  median 247.6 (~28.6× deficit)**, `grad n640` 5.00 vs 1.30 (≈3.9× too much fine grain),
  luma std 10.6 vs 20.1. Energy must move from high to low spatial frequency — **not** by
  adding dither (A11 §5; A07 F1).
- B03 re-rolled `test7/test8` and redirected `grass_ground*` to clean ids (Section 5); the
  A11 low-frequency deficit is not claimed closed without a live render.

### RC-5 — `Rect2(position, end_pixel)` size bug in selection quad (D01-1; D06; F03)

- Old `input_controller.gd:1369` `_show_selection_rect(Rect2(drag_start, cur).abs())` treated
  the release pixel as a **size**. With the proven drag `p0=(395,274)`, `p1=(917,458)`
  the box ended at **(1312,732) — outside a 1280×720 viewport**; correct end is at the
  cursor with size `p1−p0 = (521.8,184.3)` (D01-1 [O]+[D]).
- The 23/23 atom encoded the same wrong expectation (`Rect2(_p0,_p1).abs()`) and was green
  (D01-2), and no PNG of the quad existed on disk (D06) — logic green, pixels absent.
- Fixed by B05 in game code; COORD corrected the test expectation to
  `Rect2(_p0, _p1 - _p0).abs()`. The **visual** half of "quad not ok" remains UNVERIFIED until
  a D03-style three-capture probe is reviewed (D03, D06, C04 G-Q0/G-Q1).

### RC-6 — Ghost shows stage "1" (foundation), not the finished structure (E01, E02, F02)

- Old `world3d_fx.gd:645` hard-called `_stage_mesh_info(sid, "1", false)` and `:662` loaded
  `<sid>1.obj`; node named `GhostBuildingStage0`. Suffix `"1"` = `floor(progress*4)==0` =
  first foundation; the **finished** building wears the base mesh `<sid>.obj`, and `"4"` is
  the last *construction* stage (E01 §3.2; E05 §2; F02 §1-2).
- Donor stage chain `<sid>1..4.osm` + base `<sid>.osm` is donor-observed; that the donor's
  *placement ghost* itself shows finished art is **UNVERIFIED** — "show the finished stage"
  is the OWNER requirement (CHARTER §1b.3), not a proven donor behaviour (F02 §3.1; F05 row 4).
- 12/19 buildable sids have base + stages 1..4; the other 7 (`wal`, `gat`, 3 mines, `bar18`,
  `dock`) have base-only or no OBJ (E02). B06 made the ghost base-first (Section 5).

**Explicitly ruled out / not a cause** (do not re-litigate): non-identity `texture_matrix`
(A01), 25° face tilt for the P0 frame (A01), camera swim (A01), **smooth normals as the cause
of flat relief — REFUTED (A05 §3.3)**; camera/sun are CONTRIBUTING but not actionable (A05).

## 5. The six landed fixes (B01–B06) — before / after

Shared properties: each B owner edited **one exclusive source file** (B02 also two atlas
`.import` files), took a backup under `inbox/backup/*.bak-B0X` **before** the first edit, ran
**no Godot and no runner job**, and made **no donor-parity claim**. All visual effects below
are predictions [I]/[U] until G04's re-run and a second-agent capture review.

### B01 — `variant3d/shaders/terrain_tileindex.gdshader` (backup `.bak-B01`)

| Location | Before | After |
|---|---|---|
| `:60` sampler hint | `filter_nearest_mipmap, repeat_enable` | `filter_linear_mipmap, repeat_enable` (with B02's mips, removes level-0 nearest minification) |
| `tile_rgb()` `:328-338` | plain `(cell+local_uv)/atlas_grid` cell lookup | deterministic 4-way **mirror** from `floor(v_st*uv_repeat)` cell key + low-frequency **UV warp** (`0.125*sin/cos`, ~48–90 m period). Continuous UV transform, **no noise/dither field** |
| flat mask branch `~:419` | `a` straight from constant-0 sentinel → black cells | **A02-P1 sentinel guard**: `(3,3)/(7,3)` ids get `a=1` (no black cells/cliff faces) |
| flat mask branch `~:419` | full-range `a` | **A02-P4 contrast compression**: `a = mix(mix(1.0, clamp(a,0.35,1.0), 0.5), 1.0, sentinel)` → non-sentinel factor ∈ [0.675,1.0] |
| A06 follow-up `:315-316`, `:331-337`, `:337`, `:419` | vertex-stage `fract(v_st*uv_repeat)` for mask; implicit-derivative LOD spike at 2 m seams; risk of cross-cell bleed | pass **unwrapped** phase; half-texel inset from `textureSize(tile_atlas,0)/atlas_grid`; `textureGrad(...)` with unwrapped derivatives; `fract(v_alpha_uv)` moved to fragment (restores intra-cell mask variation). `:392`/`:427` kept byte-identical |

Invariants verified by B01: **502 lines before/after**, 31 uniforms unchanged (only the `:60`
hint differs), all cited anchors (`:235`, `:365-378`, `:392`, `:427`, `:475`, `:476`,
`:478-502`) byte-identical, three sampler names and `mask_to_alpha` A/B contract intact.
Residual risks [U]: mirror seams if art is not edge-continuous; P4 tonal shift; the 2 m repeat
remains and is only disguised. No border-band mask (A02 Q4 warns of a dark-grid regression).

### B02 — `variant3d/scripts/tile_atlas_loader.gd` + two atlas `.import` files (backup `.bak-B02`)

| Surface | Before | After |
|---|---|---|
| runtime `ImageTexture` (effective fix) | level 0 only (`Image.load` + `create_from_image`) | `_prepare_atlas_image()` at `:335-356`: `has_mipmaps()` guard + `generate_mipmaps(false)`; called at `:285` (single) and `:413` (split). Level-0 pixels byte-identical |
| `tile_index_atlas.png.import:26` | `mipmaps/generate=false` | `true` |
| `tile_index_atlas_winter.png.import:26` | `false` | `true` |

No `flags/*` keys added; anisotropy deliberately **not** enabled (donor `tfIsotropic`, A08 §7
#4); mask samplers stay `filter_nearest`. Cost [U]: ~33 % extra VRAM (~512 MB → ~683 MB base).
Residual (A06 Fix 1, not landed): the `array` fallback path `_load_array()` still builds a
`Texture2DArray` **without** mips; possible thin seam bands at 2 m boundaries.

### B03 — `variant3d/scripts/game.gd` (backup `.bak-B03`)

| Hunk | Before | After |
|---|---|---|
| P1 `:1936-1950` | detail-pass ids `test7`/`test8` written verbatim from donor bitmap (~15 % of map dark) | re-roll **only** those two through their own donor lists via existing `_tb_pick(2,5)` / `_tb_pick(1,4)`; `_apply_detail_pass(brng)` signature |
| P2 `:2039-2063` | stored `kind=="tile"` stamps (real donor `d_tls_1..4` footprints) discarded at `:838-839` | paint their exact mask cells as `ground1` (nearest donor worked-ground id) before smoothing; **no new RNG draw** |
| P3 `:2182-2196` | `_tb_pick()` could return `grass_ground1/2/3` (worst lattice art) | redirect to `grass9` / `test8` / `test7`; donor roulette lists and `0.64/0.0028/0.36` anomaly left untouched |

Diff totals: **57 lines added, 3 removed, 4 hunks**; static bracket/quote balance clean.
`brng` is tile-only and re-seeded per call, so mapgen/gameplay output stays byte-identical;
**tileblock bytes change for a given seed** (accepted TRN-DATA precedent), `same_seed_byte_
identical` holds by construction. **Explicitly NOT done:** A04 P3 (full 25-unit stamp grid,
different owner file) and A05 Fix #1 (donor relief grids — deferred; DPATTERN-01's 8×10
tables are debug aids, full float32 windows are not in the port).

### B04 — `variant3d/scripts/world3d_terrain.gd` (backup `.bak-B04`)

| Aspect | Before | After |
|---|---|---|
| face promotion | only `_face_mode_at()` with verbatim donor `cDiff1=0.5`/`cDiff2=0.55`; on A05's 1–4° slopes `face` stays 0, no grey `rockNvf/rockNvs` art | `_face_mode_at()` left **byte-identical** (flat-grid regression probe); new `_relief_face_at(height,w,h,x,z,relief_span)` applied only from `build()` on non-degenerate fields |
| gate | — | `gate = clampf(relief_span * 0.03, 0.05, donor literal)`: span-scaled, upper-bounded by donor constants, labelled PORT APPROX; returns 0 on any flat/uniformly-elevated grid |
| downstream | — | existing `_donor_cliff_name()` sector table, vf/vs art, `_tilt_face_normal()`, face vocabulary 0/1/2, water/shore-first ordering all unchanged; new `stats["b04_relief_promotion"]` ledger |

Invariant argument (B04 §4): 1 surface / 4096 verts / 7938 tris / 4096 UV2 preserved;
`flat_grid_promoted==0` holds both because the probed function is untouched and because
`span<=0` early-returns. Verification was source reading + a **Python numeric replica only**
(flat 64² at 1.5 m → 0 promotions); no Godot. Risk [U]: synthetic low-amplitude fixtures may
now select rock art; re-run all visual gates.

### B05 — `variant3d/scripts/input_controller.gd` (backup `.bak-B05`)

| Location | Before | After |
|---|---|---|
| `:1527` overlay | `Rect2(drag_start, cur).abs()` (end pixel used as size) | `Rect2(drag_start, _drag_cur_px - drag_start).abs()` |
| `:234-240`, five teardown sites | world drag released over minimap returned early → stuck quad | one `_cancel_drag()` called from minimap release, minimap drag release, normal LMB-up, motion onto minimap, ghost armed mid-drag |
| `:595-610`, `:205-222` | raw event pixels to `ground_point()` / `draw_rect()` | `_event_px_to_cam_px()` maps event→camera viewport using live sizes; `_show_selection_rect()` inverts the live canvas transform; identity at 1280×720 |
| `:838-841`, `:1504` | anchor re-unprojected every frame | `_rect_ground_anchor` captured once on press; `_drag_cur_px`/`_drag_rect_sim` drive mirror, outline and live selection |
| click branch `:875-930` | no Ctrl/Shift-empty/Shift-double-click semantics | low-risk D05 items: Ctrl+click remove / same-type, Shift+empty keeps selection, Shift+double-click unions |

Diff: **216 insertions, 50 deletions** (mostly citation comments). Not changed: painter style
(yellow 1 px, no fill), `_set_selection`, hotkeys/groups, double-click 0.5 s, cmd calls, all
test markers; D05 #5/#6/#7 left as owner decisions; camera-follows-drag (F03 G1) explicitly
out of file grant. **Known consequence handled outside B05**: the test's wrong `Rect2`
expectation (D01-2) was corrected by COORD at `t_select_rect.gd:529` to
`Rect2(_p0, _p1 - _p0).abs()`; COORD also fixed two parse errors B05 introduced
(`:621` typed `dst: Viewport`, `:876` `KEY_CTRL`). Both current-tree fixes verified by G10.

### B06 — `variant3d/scripts/world3d_fx.gd` (backup `.bak-B06`)

| Location | Before | After |
|---|---|---|
| `_ghost_resolve_mesh()` primary | `_stage_mesh_info(sid, "1", false)` → foundation `<sid>1.obj` | `_mesh_info(sid, "building")` → finished/base `<sid>.obj` first (`finished_base|…` telemetry) |
| fallback | stage "1", then base | `_stage_mesh_info(sid, "4", false)` (`last_stage_4|…`) only if no base art; **no stage "1" request remains** |
| standalone fallback | `<sid>1.obj` → `<sid>.obj` → `<sid>.glb` | `<sid>.obj` → `<sid>.glb` → `<sid>4.obj` |
| `_ensure_roots() :~922` | node `GhostBuildingStage0` | node `GhostBuildingFinished` |

`world3d_entities.gd` left byte-identical (its construction selector already matches the
donor progress→stage rule). Green/red validity, tint/alpha/pulse, footprint `BoxMesh` fallback,
cancel/place cleanup, cache/node lifetime all byte-identical. **Residual, not fixed:** the
footprint overlay is hidden whenever a mesh resolves, so E04/G02's strict check 7
(`footprint_matches_donor_mask`) is expected to stay **RED** (E04 §7 open question); it is kept
strict, not re-scoped, in G02. Donor ghost appearance stays UNVERIFIED.

### COORD integration fixes (not B-owner edits)

- `variant3d/tests/t_select_rect.gd:529` — corrected expectation (see B05).
- `variant3d/scripts/input_controller.gd:621` and `:876` — the two parse errors that made
  ticket 583's selftest fail; fixed, re-run still pending (WAVE_G_CHARTER.md:22-27; G04).

## 6. Gate status — honest, UNVERIFIED, not green

- **Definition of good (target only)** — CHARTER §5: fresh windowed 64² and real-map captures
  with no streaks/grid/blotches, organic multi-scale variation and relief/shore, no new seams,
  and existing gates green: variant selftest **29/29**, uitest **17/17**, `t_render_mode`,
  `assert_clean` **CLEAN**, 2D `app/` untouched; every change donor-cited or PORT APPROX.
- **No fresh integrated gate exists.** The charter records the first selftest (ticket 583)
  failed on B05's two parse errors (now fixed); the re-run is the first thing G04 is meant to
  do. No capture has been reviewed on the landed tree; C04's sign-off block is a **blank
  template** — no visual PASS/GOOD was recorded.
- **G04 (sole runner) is BLOCKED at pre-flight** (G04): `pending=1` (stale, already-terminal
  ticket **582** whose job file remains in the spool), `godot.lock` free, `now_serving ==
  next_ticket == 584`, 0 live Godot processes. One criterion fails → **zero jobs submitted**;
  no `cancel`/`unwedge`/`ack`/`reset`/`doctor` and no process kill by name. Five `g04-`
  jobs (selftest, uitest, t_render_mode, windowed P0, windowed real-map) are prepared but
  **NOT SUBMITTED**. COORD must clear ticket 582 and re-run status, then unblock G04.
- Earlier runner churn: 2000 bogus `skipped` result JSONs were deleted and COORD reset
  `now_serving=583` (WAVE_G_CHARTER.md:27); G04 confirms the counter is now aligned — the
  remaining issue is the single stale job file, not a desync.
- C02 prepared the full gate ladder G0–G9 plus four mandatory rows **G-Q0** (capture path
  must include `input_ctl`, not main's saver), **G-Q1** (no blank/root-texture readback),
  **G-A0** (`uv_repeat`/`mask_to_alpha` have no config bridge — no overlay-only A/B), and
  **G-G0** (ghost final stage must come from the code/atom, not an overlay key). None executed.
- Fresh coverage from G02: `variant3d/tests/t_ghost_final_stage.gd` was authored (12 decisive
  checks + guards, from E04 §3.2) but **not run**; parse/runtime behaviour UNVERIFIED.
- **Donor parity: UNVERIFIED in every case.** No donor GPU A/B frame exists; a green gate, a
  green smoke metric, or a reference-band z-score cannot establish it. Do not write "gates
  green", "donor parity", or "result is good" anywhere until G04's evidence and a second-agent
  C04 sign-off land.

## 7. Ownership discipline (what to preserve when resuming)

- Each A/C/D/E/F worker wrote exactly **one report**; C01 additionally owns exactly one new
  tool file (`terrain_ab_metric.py`), G01/G02 own exactly one new test atom each. No agent
  edited another's file (C03 found no cross-touch at its cut-off; **G13** is the updated
  read-only audit of all B backups + COORD's test fix — not yet landed at this write).
- The six B owners each took a backup before editing; backups exist as
  `*.bak-B01` … `*.bak-B06`. A modified file with no matching backup is a hard violation
  (C03 §7 integration criteria).
- B06 is the documented COORD correction: the board listed `world3d_entities.gd`, but the
  defect and fix are in `world3d_fx.gd`; only the latter was edited (E01/A12/F02 located it).
- **Only G04 touches the runner** in Wave G. G10 (this README), and every other G agent, are
  READ-ONLY with respect to source/tests/config/queue; this file is the only write.
- Windows toolchain: `python` (never `python3`), PowerShell `;` (never `&&`); never kill Godot
  by name; `app/` (2D port) is untouched by this swarm.

## 8. Failure register (defects, debt and UNVERIFIED items — status honest)

| # | Failure / gap | Evidence | Status |
|---|---|---|---|
| F-01 | First integrated selftest (ticket 583) failed on B05 parse errors `:621`/`:876` | WAVE_G_CHARTER.md:27; G04 | **Fixed** by COORD; re-run UNVERIFIED, G04 blocked |
| F-02 | Stale ticket 582 — terminal `skipped` but job file still in spool → `pending=1`, G0 FAIL | G04 §1.2 | **Open** — COORD to clear; no job submitted |
| F-03 | `t_select_rect.gd:529` encoded the same `Rect2` size bug as the game | D01-2; B05 §4.3; COORD fix verified | **Fixed** by COORD at `:529`; visual quad still UNVERIFIED |
| F-04 | No on-disk PNG of the selection quad; `t_select_rect.json` is node-state only, 23/23 | D06 §1-2, §4 | **Open** — D03 probe + G01 atom authored, not run |
| F-05 | Ghost footprint overlay hidden when a mesh resolves; strict check 7 expected RED | E04 §7; G02 §1/§6 | **Open** — preserved strict, not weakened |
| F-06 | Donor ghost appearance / finished-hologram claim | F02 §3.1, F05 row 4 | **UNVERIFIED** — owner directive, not donor fact |
| F-07 | Relief amplitude/footprint + only 2/26 donor grids; `ravine_big` has no port grid; `k_ravine_1` BLOCKED | A05 §3.2/§4; B03 §6 | **Partially addressed** (B04 makes cliff art reachable, B03 deferred grid work) |
| F-08 | A11 low-frequency/BV32 deficit (~28.6×), no donor-matching mottling | A07, A11, B03 §5 | **Open/UNVERIFIED** — no live histogram/capture post-fix |
| F-09 | Mipmap `array` fallback path still lacks mips; possible 2 m seam LOD spikes | A06 Fix 1, B02 §6 | **Open/UNVERIFIED** |
| F-10 | Config overlay cannot drive `uv_repeat`/`mask_to_alpha` (no binding line) — false A/B arms | A12, C04 G-A0, C02 | **Open** — K1/K2 proposals only, not landed |
| F-11 | Camera-follows-drag (donor's 2016-11 headline) not implemented; native inside-box predicate unknown | F03 G1/O1/G2; D02; D04 | **Open/PORT APPROX** — G08 proposal pending |
| F-12 | Donor bug "box select fails after selecting a wall" must NOT be copied | CHARTER §1b.2; F03 Finding 5; D05 §3 | **Not reproduced** by inspection; live A/B UNVERIFIED |
| F-13 | Selection UI decisions open: hover HUD hit-test (#5), top-strip `MOUSE_FILTER_IGNORE` (#6), empty/building selection sounds (#7) | D05 §2/§4 | **Open / decision** — B05 did low-risk #1-#4 only |
| F-14 | On-disk config is 240², not the 320² some older reports assume | A09 §1, G04 §2 | **Known config drift** — pin/override per A09 before A/B |
| F-15 | Real-map blank-detector false positive can reject a valid frame (use `.raw.png` + diag) | A09 §2.2; C04 G-Q1 | **Known instrument defect** — do not edit detector |
| F-16 | Prior open gate debt: C4 selftest 28/29 missing `mill_rotor.png` `.ctex`; H-6 relief invisible / white marks | A10 §3 (FINAL_CHECKLIST refs) | **Open** — must not be silently closed by weakening |
| F-17 | Donor parity in all 38 reports | every parity guard; CHARTER §3 | **UNVERIFIED** — no donor GPU A/B frame exists |

## 9. Topic-grouped report index (all 38 A–F reports + landed Wave G)

Report links are relative to this README (`reports/`). Source paths are workspace-relative
from the repo root.

### Charters, board, consolidation
- [CHARTER.md](CHARTER.md) — rules, suspects, §5 definition of good.
- [WAVE_G_CHARTER.md](WAVE_G_CHARTER.md) — Wave G assignments; only-G04-runs-Godot rule; known state at launch.
- [SWARM_BOARD.md](SWARM_BOARD.md) — 38-agent ownership map (A01–F05).

### A — diagnosis (read-only)
Terrain texgen / filtering / mask:
- **A01** [shader tiling / diagonal streaks](reports/A01_shader_tiling.md) — Rank 1 2 m grating; Rank 2 no mips; FFT/ACF measurements; recommends mip fix (landed B01/B02).
- **A02** [alpha pattern / mask-to-RGB](reports/A02_alpha_pattern.md) — 8/124 sentinel black ids; id→patch aliasing; proposals P1/P2/P4/P5.
- **A06** [filtering / aliasing](reports/A06_filtering_aliasing.md) — 10–14 texels/px, LOD spike at `fract` seam, vertex-stage mask collapse; Fix 2 landed in B01's follow-up.
Tile art / data / colour:
- **A03** [atlas cells](reports/A03_atlas_cells.md) — per-cell metrics; best grass9/test9/test8; worst grass_ground*/grass2/ground1; contact sheet `A03_atlas_cells_contact.png`.
- **A04** [tile diversity](reports/A04_tile_diversity.md) — top-5 73 %→58.5 % offline; 2,036-cell uniform patch; P1/P2/P3 proposals.
- **A07** [colour / lighting](reports/A07_color_lighting.md) — olive = atlas blue deficit, not exposure; options 1–3 (color correction pending).
- **A11** [reference metrics](reports/A11_reference_metrics.md) — 12 donor images; BV32 n640 8.7 vs 247.6; three target metrics; illustrations `A11_*.jpg/.png`.
Relief / donor truth:
- **A05** [relief visibility](reports/A05_relief_visibility.md) — amplitude/footprint primary; normals REFUTED; ravine_big gap; Fix 1 deferred, Fix 2 → B04.
- **A08** [local donor truth](reports/A08_donor_truth_local.md) — 14-item copy checklist; binding negatives; UNVERIFIED register.
Capture / constraints / knobs:
- **A09** [capture plan](reports/A09_capture_plan.md) — windowed 64² + real-map commands, metric spec, ARI, one-Godot rule.
- **A10** [regression constraints](reports/A10_regression_constraints.md) — SAFE / NEEDS CARE / DO NOT TOUCH; known-gap markers not to flip.
- **A12** [config knobs](reports/A12_config_knobs.md) — 16 feature getters; no `uv_repeat`/`mask_to_alpha` bridge; K1–K9 additive proposals (incl. ghost K8 → not landed; B06 changed code instead).

### B — implementation (six landed fixes; see §5)
- **B01** [shader implementation](reports/B01_shader_impl.md) — `variant3d/shaders/terrain_tileindex.gdshader`.
- **B02** [atlas mipmaps](reports/B02_atlas_impl.md) — `variant3d/scripts/tile_atlas_loader.gd` + atlas `.import`.
- **B03** [tile diversity](reports/B03_diversity_impl.md) — `variant3d/scripts/game.gd`.
- **B04** [relief face promotion](reports/B04_relief_impl.md) — `variant3d/scripts/world3d_terrain.gd`.
- **B05** [selection quad](reports/B05_selection_impl.md) — `variant3d/scripts/input_controller.gd`.
- **B06** [ghost final stage](reports/B06_ghost_impl.md) — `variant3d/scripts/world3d_fx.gd` (COORD-corrected file).

### C — verification tooling / QA
- **C01** [metric tool](reports/C01_metric_tool.md) — `variant3d/tools/terrain_ab_metric.py`; smoke metrics, not a fidelity gate; reconciled with A09/A11.
- **C02** [gate plan](reports/C02_gate_plan.md) — G0–G9 plus G-Q0/G-Q1/G-A0/G-G0; plan only, not executed.
- **C03** [ownership/backup audit](reports/C03_ownership_audit.md) — moment-in-time (pre-B-edits); re-check criteria in §7.
- **C04** [visual-review protocol](reports/C04_visual_review.md) — three capture sets, 11 sign-off rows, blank template, four hand-off rows.

### D — selection quad / UI
- **D01** [quad end-to-end audit](reports/D01_selection_quad_audit.md) — D01-1 Rect2 root cause; D01-2 tautological test; D01-3 stuck quad.
- **D02** [donor ground truth](reports/D02_selection_quad_donor.md) — 41-row spec table; byte-decomp authoritative; wall bug do-not-copy.
- **D03** [capture probe proposal](reports/D03_selection_probe.md) — before/during/after atom with overlay reparent (Trap A/B/C/D); authored as G01's atom.
- **D04** [projection geometry](reports/D04_selection_projection.md) — terrain raycast corners, two missing transforms, hunks 1–8 → B05.
- **D05** [selection UX](reports/D05_selection_ui.md) — Ctrl/Shift gaps #1–#4 → B05; #5–#7 decisions open; checks already correct.
- **D06** [capture inventory](reports/D06_selection_captures.md) — no quad PNG exists; 23/23 is node state; markers not flipped.

### E — building ghost final stage
- **E01** [ghost audit](reports/E01_ghost_audit.md) — root cause suffix `"1"` at `world3d_fx.gd:645`/`:662`.
- **E02** [final-stage assets](reports/E02_final_stage_assets.md) — 12/19 full stage families; 7 blocked; no death meshes.
- **E03** [fix proposal](reports/E03_ghost_fix_proposal.md) — base-first/4-fallback diff; notes B06 landed concurrently.
- **E04** [QA atom design](reports/E04_ghost_qa.md) — 12 checks incl. strict footprint check 7; authored as G02's atom.
- **E05** [donor mesh naming](reports/E05_ghost_mesh_naming.md) — base = finished; resolves base-first path for B06.

### F — online donor research
- **F01** [almanac terrain](reports/F01_almanac_terrain.md) — five stages, relief tiers, SetupTiledPatterns, smoothing; C1–C12 copy list.
- **F02** [almanac building/ghost](reports/F02_almanac_building_ghost.md) — stage chain, `.prop` mask vs AABB; "finished ghost" = owner directive.
- **F03** [selection online](reports/F03_selection_online.md) — 2016-11 drag-frame + camera-follow; nine gaps G1–G9; donor bugs not to copy.
- **F04** [quality reviews](reports/F04_quality_reviews.md) — vanilla vs NTM; P0-1..4/P1-5..8/P2-9..11 checklist; AA is not a fix.
- **F05** [online vs local](reports/F05_online_vs_local.md) — reconciliation table; corrections rows 1–7; "online silent ≠ online refutes".

### Wave G (only landed reports linked; other assignments in [WAVE_G_CHARTER.md](WAVE_G_CHARTER.md))
- **G02** [ghost atom authored](reports/G02_ghost_atom.md) — `variant3d/tests/t_ghost_final_stage.gd` created; strict check 7 kept; no runner job.
- **G04** [gate log](reports/G04_gate_log.md) — pre-flight FAIL (stale ticket 582); zero jobs submitted; unblock requested.
- Other G agents (G01, G03, G05–G20: capture atom, test audit, visual review, colour eval, relief plan, camera-follow, footprint, runner/backup/static/measure/season/perf/donor-bug/hotkey/triage monitors) deliver into the same `reports/` folder as they land; G10 is this README. **Only G04 may run Godot.**

## 10. Resume checklist for COORD / next session

1. Clear stale ticket 582 by COORD authority; re-run `python variant3d\tools\godot_runner.py status` → require `pending=0`.
2. Unblock G04; have it submit the five `g04-` jobs sequentially (selftest → uitest → t_render_mode → windowed P0 → windowed real-map), re-checking `status` between each.
3. Confirm selftest **29/29**, uitest **17/17**, `t_render_mode` PASS/`seam_missing=false`, `SCRIPT ERROR == 0`, `assert_clean` CLEAN, `app/` untouched. Any failure is routed to the owning ticket — **never** fixed by weakening a check.
4. Have a second agent open the fresh captures and execute C04's §7 sign-off; inspect `stats["b04_relief_promotion"]`, `tile_index_hist`, `ghost_mesh_source`, and the D03/G01 quad frames.
5. Keep the failure register (§8) open items explicit; A07 colour option, A05 relief grids, F03 G1 camera-follow, and B02's array-mip fallback are the next tickets — none are done.
6. Reaffirm in every future report: **donor parity UNVERIFIED; no green-gate claim without G04's evidence and C04's sign-off.**

*End of G10 consolidation. This file is the only write; no source, test, config, queue or Godot job was touched.*
