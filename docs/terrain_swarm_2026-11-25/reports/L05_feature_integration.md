---
id: L05-FEATURE-INTEGRATION
ticket: "INTEGRATION wave — L05 — one ordered, conflict-free integration plan for the owner's feature requests"
owner: L05 (read-only integration subagent)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_CODE_EDIT__NO_BACKUP_TAKEN
scope: "Exactly one repo file written: this report. No .gd/.gdshader/config/test/fixture/tool/result/queue/asset edit; no Godot process or runner job; no git write; no backup created. All state read from the on-disk tree at HEAD 8e9de1bf."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
inputs: [WAVE_G_CHARTER.md, CHARTER.md, M01_mill_rotor_audit.md, M02_donor_mill.md, M03_mill_fix_proposal.md, M04_mill_qa.md, F2_01_mill_fields_audit.md, F2_02_donor_fields_mines.md, F2_03_fields_fix.md, F2_04_mine_snap.md, F2_05_qa.md, S01_speed_audit.md, S02_speed_fix.md, L01_spot_grass.md, L02_chessboard_review.md, H06_pass_order.md, H07_2d_reuse.md, G26_water_shore.md, G04_gate_log.md, L04_perf_integration.md, L07_reverify_batch.md, G09_footprint.md]
parity_guard: "No donor GPU A/B frame exists anywhere in this swarm. Every donor claim below carries a path:line citation and its own label; every non-donor choice is explicitly PORT APPROX. Nothing in this plan is a PASS verdict."
---

# L05 — ordered, conflict-free feature integration plan

## 0. Reading rules and current state

**Labels (binding, `CHARTER.md:55-58`):** `OBSERVED` = read directly from a cited file/byte;
`DERIVED` = arithmetic/control-flow consequence of observed code; `INFERRED` = reasoned but
unproven; `UNVERIFIED` = needs a real run; `DONOR-GROUNDED` = donor byte/text citation exists
(never a GPU parity claim); **`PORT APPROX` = port/owner choice with no donor citation**.

**Operator rules:** only **G04** submits runner jobs (`WAVE_G_CHARTER.md:31,67-70`); Windows
`python`, PowerShell `;` not `&&` (`CHARTER.md:69`); one exclusive owner per file at a time
(`CHARTER.md:67-68`); fresh `inbox/backup/<file>.bak-<TICKET>` **at handover**, before the
first edit (`CHARTER.md:66`); no threshold/assertion/`expected_pre_fix_failure` weakening
(`CHARTER.md:59-61`). This plan submits zero jobs and takes zero backups.

### On-disk state (OBSERVED, `git status --short` + `inbox/backup/` at HEAD `8e9de1bf`)

| Fact | Evidence | Label |
|---|---|---|
| Only Wave-B source edits plus two result JSONs are modified: `game.gd`, `input_controller.gd`, `tile_atlas_loader.gd`, `world3d_fx.gd`, `terrain_tileindex.gdshader`, `water3d.gdshader`, `t_select_rect.gd`, 2 result JSONs; two new atoms `t_ghost_final_stage.gd`, `t_select_rect_capture.gd` are untracked. | `git status --short` this ticket | OBSERVED |
| `water3d.gdshader` is **already modified** (+21/−3: `fract` drop, gated early dry discard, gated foam band, annotated `T-WATER-FAST`), but **no `water3d.gdshader.bak-P13` exists** in `inbox/backup/`. | `git diff -- variant3d/shaders/water3d.gdshader`; backup listing | OBSERVED — governance gap; flag to COORD |
| No `.bak-M03`, `.bak-F2-03`, `.bak-F204`, `.bak-S02`, `.bak-L01`, `.bak-H07`, `.bak-G09` exists; all six features below are **proposals only** on disk. | backup listing | OBSERVED |
| `uitest` 17/17 is **stale**: on-disk JSON predates both G04 jobs; job 585 timed out, job 587 hit the 138 s watchdog with engine resource-leak errors. No HUD/speed acceptance is credible until a fresh run. | `L04_perf_integration.md:62-70`; `G04_gate_log.md:197-211`; `L07_reverify_batch.md:138-145` | OBSERVED |
| `S03_speed_qa.md` was never authored (WAVE_G_CHARTER.md:152 references it); no dedicated QA atom exists for L01/H07 or for G26b. Those rows below therefore use the L07/C01 protocol, **not** a missing atom. | reports directory + charter | OBSERVED (absence) |
| Reports that were still landing during this ticket (`F2_03_fields_fix.md`, `M02_donor_mill.md`, `L01_spot_grass.md`, `L02_chessboard_review.md`, `L04_perf_integration.md`, `L07_reverify_batch.md`) are now on disk and were read in full. | report timestamps + reads | OBSERVED |

---

## 1. Feature register — owner file, prerequisite, acceptance atom, risk, rollback

Each row is one self-contained integration card. **No card may be executed before its
prerequisites are filed in writing by COORD.** Donor claims are cited; everything else is
`PORT APPROX`.

### 1.1 M03 — mill rotor at the donor axle tip, camera billboard removed

| Field | Content |
|---|---|
| **Exclusive owner file** | `variant3d/scripts/world3d_entities.gd` **only** (`M03:16,141-155,348-352`). Co-author (new file, no backup needed): `variant3d/tests/t_mill_rotor_probe.gd` from `M04:4` **co-updated** per `M03:326-344`. |
| **Prerequisite** | (1) P11 released `world3d_entities.gd` (`L04 §3.1 / T3 step 8`); (2) G04 gates accounted + stale-uitest decision filed; (3) fresh `.bak-M03` at handover; (4) **M04 atom co-updated before authoring** (`M03 §7`), else correct code goes RED by design; (5) `M02` donor geometry accepted (now landed). |
| **Exact acceptance atom** | Windowed `t_mill_rotor_probe.gd`, runner id `m04-mill-rotor-probe` (`M04:859-894`, refresh if id used); **all 14 criteria** (`M04:898-920`) with `M03 §7` deltas: hub `(−0.176,+5.626,+1.895) ±0.02 m`, `p.z>1.5 && p.z<2.3`, `mill_yaw_rad==0`, `to_camera.z>0.8` (**not** the billboard-era 0.95), `rotor_rotation_axis_stable` pure local-Z, two 1280×720 PNGs, `SCRIPT ERROR=0`. Plus fresh `l07-p0cap`/`l07-realmap` (`L07:122-125`). |
| **Risk** | **HIGH visual** (`M03:348-371,390-393`; `L04:110`): no mill capture exists (`M01 E24`); fixed axle occluded from behind; old M04 checks 7/8/9 fail unless co-updated; F2-03's rotor clearance `3.35 m` was derived from the *old* billboard projection (`F2-03:141`) and must be re-derived; sail stand-in/spin sign remain PORT APPROX; `mill_rotor.png` `.ctex` debt stays open (`M03:171`). |
| **Rollback** | Full-file restore `inbox/backup/world3d_entities.gd.bak-M03`; re-run M04 atom (pre-fix expectation) + gates. Do **not** hand-patch hunks to force green. |
| **Donor claim / label** | **`DONOR-GROUNDED` geometry:** `M02:101-115` decodes `eurmilanim.oss` (spin axis donor Y → local Z, 251 keys/30 fps = 8.367 s → 0.751 rad/s, axle solve `(0,5.628)`); `M03:93-130` byte probe D1–D5 (`eurmilanim.oss` bbox `x[-2.996,2.996] y[-1.898,-1.041] z[2.627,8.620]`, axle tip donor `y=-1.897957` → local `(−0.176,5.626,+1.895)`, tower face at hub height `∼+1.781`). **`PORT APPROX` / `UNVERIFIED`:** sail is the 2D donor PNG on a quad, spin *sign*, pixels, and all donor parity (`M03:17,132-136`; no A/B). |

### 1.2 F2-03 — bigger touching mill fields, four-patch quad, skip-on-overlap

| Field | Content |
|---|---|
| **Exclusive owner files** | `variant3d/scripts/game.gd` (sow function + `_field_quad_clear()`, `F2-03:200-356`) **and** `variant3d/scripts/world3d_entities.gd` (constants `:266-273`, field pass `:2190-2253`, `F2-03:358-413`). The two `FIELD_QUAD_*` constant sets must stay in sync; `FIELD_SPAN_M` kept as alias for P11's `color` consumer (`F2-03:63-64,415-420`). |
| **Prerequisite** | (1) M03 released `world3d_entities.gd` and P11 released it earlier; (2) F2-04 not holding `game.gd`; (3) **re-derive rotor clearance** `3.35 m` against M03's fixed axle at local `+Z 1.895` (`L04:141-144`); (4) F2-05 Atom A **deltas authored** per `F2-03 §7.3` (`MIN_FIELDS 4`, `EPS_EDGE 0.15`, span range `[9.5,11.0]`, house trap at quad centre, two new RNG/field-count checks); (5) fresh `.bak-F2-03` for **both** files; (6) F2-02 donor truth reconciled: donor is a **49-node rotated 7×7 cluster**, not a four-patch quad — the quad is an owner-directed `PORT APPROX`, never donor parity (`F2-02:98,214-220` vs `WAVE_G_CHARTER.md:128-137`). |
| **Exact acceptance atom** | Windowed `t_f2_mill_fields.gd` with §7.3 deltas, id `f2-05-millfields-cap1` (`F2-05:593-635`): criteria 1–10; decisive = `adjacent_fields_touch` (signed gap `−0.141 m`, ≤0.15), `fields_clear_of_buildings` (0 violations incl. house/stone/road/water/shore), `field_count_is_four`, `rng_state_unchanged_by_sow`; 1280×720 PNG; `SCRIPT ERROR=0`. Plus `t_mill_logic` 6/6, `resow` step, `t_forest_bake`, `assert_clean`. |
| **Risk** | **HIGH**: two files; `t_mill_logic` indexes `fields[0..2]`; cross-variant sim-hash divergence **by design** (3-D-only, `F2-03:472,548-549`); gold cost drops from ~24×5 to 4×5; 2-D mill `block_rect` exclusion of the south patch is UNVERIFIED visually (`F2-03:539-543`); road rejection only active when `test1/test2/test3` resolve; no capture exists. |
| **Rollback** | Restore `game.gd.bak-F2-03` **and** `world3d_entities.gd.bak-F2-03` in one pass; revert Atom A deltas only if COORD rules the test spec itself invalid (they are spec updates, not weakening). |
| **Donor claim / label** | **`DONOR-GROUNDED`** (`F2-02:95-105,170-220`): `decals.lib:37-43` 2×2 template; `misc.script:4284-4306` `texscalefix=1.3`, `scale=60`; `unit.script:6475-6548` `cRow=7`, `cCount=49`, `size=1.6981` cells, 45° rotation, snap `2.4017`, food clearance `1.528`; contiguous rotated rectangle + square mill clearing (`field_crops.md:74-103`). **`PORT APPROX`:** quad offsets `7.2 m`, span `7.3 m`, margin `0.3`, rotor-clear `3.35`, four-patch decomposition and the skip rule (`F2-03:134-145,530-536`); donor 3-D placement and all pixels UNVERIFIED. |

### 1.3 F2-04 — mine ghost magnetic snap (preview follows the sim snap)

| Field | Content |
|---|---|
| **Exclusive owner files** | `variant3d/scripts/game.gd` (read-only `snap_mine_pos()` helper after `resolve_mine_sid`, `F2-04:144-180`) **and** `variant3d/scripts/world3d.gd` (one guarded insertion in `_sync_build_ghost()` between `:488-490` and `:491`, `F2-04:183-206`). **Explicitly NOT owned:** `world3d_fx.gd` (B06 ghost mesh), `input_controller.gd` (B05 quad), `can_place()`, `place_building()`, tests, `app/` (`F2-04:30-35,126-134`). |
| **Prerequisite** | (1) F2-03 released `game.gd`; (2) P15 released `world3d.gd` (`L04:203`); (3) COORD decision on the radius mismatch: donor **`1.5` map cells = 3.0 m** (`F2-02:262`, `dmscript.global:206`; 2 m/cell at `dmscript.global:171`) vs port `MINE_SITE_RADIUS = 4.0 m` (`game.gd:19`) — **recommendation: keep 4.0 m for this tranche** (ghost-only, no sim/test change) and file a separate radius-alignment ticket; (4) fresh `.bak-F204` for both files + SHA-256 recorded (`F2-04:213-232`); (5) F2-02 re-check completed. |
| **Exact acceptance atom** | Windowed `t_f2_mine_snap.gd`, id `f2-05-minesnap-cap1` (`F2-05:1118-1156`): criteria 1–10; decisive = `ghost_snaps_to_deposit` (≤0.05 m) **and** `ghost_not_at_cursor` (>0.20 m) **plus** `mine_snaps_to_deposit`/`mine_not_at_cursor`; two PNGs hover/placed; `t_ghost_final_stage.gd` still PASS (B06 node `GhostBuildingFinished`), `t_mine_build.gd`, `unified_mine_test.gd`, `SCRIPT ERROR=0`. If offset constant is kept, atom's `cursor_dist<4.0` remains valid; if radius is changed to 3.0, update the atom's spec constant **before** running, not its assertions. |
| **Risk** | **MED**: green/red verdict moves to snapped point (must match `can_place(0,sid,dep.pos)`); hand-edited maps with two same-type deposits in one radius are untested (nearest vs first); per-frame spatial query cost UNVERIFIED; `world3d_fx.gd` and B05 must stay byte-identical (`F2-04:279-289`). |
| **Rollback** | Restore `game.gd.bak-F204` + `world3d.gd.bak-F204`; no other file involved, so B05/B06 work cannot be disturbed (`F2-04:229-230`). |
| **Donor claim / label** | **`DONOR-GROUNDED` mechanism** (`F2-02:258-323`): finder `unit.script:6629-6672` returns the exact deposit centre; ghost snap `miscext2.script:1098-1132`; commit `onmousedown.inc:209-254` re-runs the finder and derives sid from ore; radius `dmscript.global:206`. Activation of `;`-prefixed `.inc` callers **UNVERIFIED**. **`PORT APPROX`:** the port's 4.0 m radius and reuse of `place_building`'s rule (`game.gd:4107-4111`), not donor parity. |

### 1.4 S02 — speed options x8 / x16 / x32 / x64

| Field | Content |
|---|---|
| **Exclusive owner files** | `hud.gd` (`:439-447`), `main.gd` (`:360-362`, `:721-724`), `variant3d/tests/t_hud_layout.gd` (`:59-62`) — **one coordinated owner** for all three (`S02:87-137,213-231`). `hud3d_adapter.gd` stays P12's; `config.gd`, `data.gd`, `app/scripts/hud.gd`, `uitest.gd` untouched (`S02:166-171`). |
| **Prerequisite** | (1) P12 released `hud.gd` — apply **P12 first**, then re-derive S02's hunk from post-P12 bytes; fresh `.bak-S02` **after** P12 (`L04 §3.2`, `S02:195-196`); (2) P15 released `main.gd`; (3) **fresh uitest** with fresh JSON mtime (`L04:65-70`, `L07:138-145`) — do not accept stale 17/17; (4) separate grant for `t_hud_layout.gd`; (5) COORD chooses S02 §3.1 (with x8 bridge) **or** §3.2 (without) — never mix; (6) three fresh backups. |
| **Exact acceptance atom** | No S03 atom exists (MISSING). Use S02 §6 gate set: **`t_hud_layout` 62/62** at 1024×576 / 1280×720 / 1920×1080 with updated `SPEED_LABELS`/`SPEED_META` (exact-equality checks intact), **fresh `uitest` 17/17** (`speed_pause` detail "game speed set to 2x: yes"), selftest **29/29**, `t_render_mode`, `t_menu_roster` (`main.speed==2.0`), `config.defaults`, `t_hud_fidelity`, three non-blank windowed PNGs with `top_panel_right_in_viewport_*` green (`S02:233-245`). Optional accumulator saturation `main.gd:1616` is **not** in the primary patch (`S02 §7`). |
| **Risk** | **MED-HIGH**: hard cap 8→64; `x16/x32/x64` are target rates — the `steps<64` cap truncates at <8/16/32 fps and undrained `acc` can grow (`S01:114-142`); `_anim_t` is wall-clock so measured speed inflates at high multipliers (`S01:176-185`); 6 `t_hud_layout` checks fail if spec constants are not updated; UI overflow at 3 widths UNVERIFIED; stale-uitest invalidates acceptance. |
| **Rollback** | Restore all three `.bak-S02` files in one pass (`S02:206-211`). |
| **Donor claim / label** | **No donor citation for x16/x32/x64** — owner-directive **`PORT APPROX`** (`S02:74-79,269-272`). The dropdown in fact tops out at **x4**, not x8 (`S01 E1`, `hud.gd:444`); x8 exists only as `--fast` (`main.gd:1351`) and the old clamp. Donor-documented controls are hotkeys `Shift ×5` / `Ctrl unlimited` (`CHARTER.md:112`), not dropdown labels. |

### 1.5 L01 (+ H07) — spot-based light/dark grass from tile IDs

| Field | Content |
|---|---|
| **Exclusive owner file** | `variant3d/scripts/game.gd` **only** for both: **L01** adds `_stamp_grass_spots()` + two helpers, call site immediately after B03's `tls_*` loop at `:2064` and **before** `_smooth_tilemap(brng,3)` at `:2067` (`L01:225-231`); **H07-a** moves `_apply_detail_pass(brng)` from `:2039` to after `:2067` (`H07:95-135`). Never touch shader/atlas/mesh/`pattern_gen.gd`/tests/`app/` (`L01:72,231`). |
| **Prerequisite** | (1) F2-03 and F2-04 released `game.gd`; (2) B01's mirror removal verified on a **fresh** P0 frame — the chessboard defect was the per-cell mirror, already removed (`L02:89-151`); (3) fresh `.bak-L01`, and a **separate** `.bak-H07` if H07 is accepted; (4) pinned seed `20261113`, identical camera/zoom/crop on both arms (`L01 §8.1`, `H07:137-147`, `L07:147-154`); (5) **H07 is a separate A/B, not part of the minimal tranche** — run it with L01 already applied as the constant base (arm A = L01 only, arm B = L01 + H07) so attribution stays honest. |
| **Exact acceptance atom** | No dedicated atom authored; use the L07/C01 protocol: `l07-realmap` windowed capture (pinned seed/camera) + `terrain_ab_metric.py <PNG> --crop 120,60,1040,580 --json` and the three-baseline comparisons (`L07:193-218`); A04 component scan on `stats.tile_index_hist` (`world3d_terrain.gd:1570,1641`): largest uniform 4-component **<800 cells**, ≥100-cell components **<15%**, distinct ids ≥35, top-5 <58.52%, `grass5`/`grass9` present; `t_map_variety` 5/5 incl. `same_seed_byte_identical`; selftest 29/29; C04 R1 visual scan (no checker mosaic). **H07 ships only if BV32 n640 moves toward ≈150–270 and all hard gates stay green; else revert from `.bak-H07`** (`H07:143`). The 64² P0 fixture is all tile id 0 and **cannot** show spots (`L02:163-165`). |
| **Risk** | **HIGH visual** (`L01 §9`): false-positive chessboard if implemented from raw sparse `st.cells` (`*..*..*`) instead of the *filled* core disc (R1); synthetic-field regression forbidden by S-25-09 (R2); ~3% coverage may not move BV32 (R3); 1-id-per-role spot repetition (R4); `grass5` bottom edge (R5); smoother erosion (R6); `brng` stream shift (R7); `grad n640` may rise (R8); season alias (R9); H07 additionally changes `tileblock` bytes and RNG order (`H06 §4.2`, `H07 R1-R3`). |
| **Rollback** | Restore `inbox/backup/game.gd.bak-L01`; for H07 restore `.bak-H07` (which already contains L01) — never partially re-apply either patch. |
| **Donor claim / label** | **`DONOR-GROUNDED` inputs:** donor ids `grass9` (`cfg:359`, Item 3 J=5) and `grass5` (`cfg:762`, Item 7 J=1) with **verbatim** weights `cfg:67` (.16×5/.20), `cfg:798` (.36/.28/.36), `cfg:846` (.4/.6) (`L01 §4, E06`); stamp masks/geometry from `pattern_gen.gd:110-128` and the port's filled disc `game.gd:765-801` (`L01 E02/E03`); A03 cell class/luma (`L01 E08`). **`PORT APPROX`:** repurposing rock/transition lists into run length/polarity/eligibility, id substitution, role of `grass5` as meadow colour; donor `.inc` runtime is `;`-commented and **UNVERIFIED** (`L01 E12`). For H07: donor **call-site order** `generatemap.inc:776 → 786 → 795` = TextureMap → SmoothTiles → detail bitmap (`H06 §0a, OBSERVED text`); "donor-faithful" is **order-only**, B03's P1/P2/P3 substitutions remain PORT APPROX, visual effect UNVERIFIED (`H06 §4.3-4.4`). |

### 1.6 G26 — shore / water gaps

| Field | Content |
|---|---|
| **Exclusive owner files** | **G26b**: none (one new read-only report). **G27**: `variant3d/shaders/water3d.gdshader` only, backup `.bak-G27`. **G28**: `variant3d/scripts/world3d_terrain.gd` only, backup `.bak-G28`. G27 and G28 are **mutually exclusive** and both require COORD integration (`G26:120-137`). |
| **Prerequisite** | (1) **G26b first** — no port water frame exists (`G26:34`, `G04_gate_log.md:25-102`); (2) G04 must produce a water-containing fixed-camera capture; (3) G27 blocked until the current `water3d.gdshader` owner releases it — the file already carries `T-WATER-FAST` edits with **no `.bak-P13` on disk** (§0, governance gap); (4) G28 only if a donor-readable bed binding is actually found; otherwise leave the `sandsea1` fallback as declared PORT APPROX (`G26:136-137`); (5) P15/P16 released `world3d_terrain.gd`; (6) reflection FBO and exact donor surface Y stay UNVERIFIED and untouched (`G26 §6`). |
| **Exact acceptance atom** | G26b is a **read-only** five-number record (`foam_peak_sRGB` vs donor peak depth 0.535 m, `water_body_mean_sRGB` vs `(184,190,177)`, `beach_band_screen_px` + sandsea cell count, `alpha_at_waterline`/half-alpha depth, `animation_delta` from two frames 1 s apart); **no donor-parity PASS is defined** (`G26:124-132`). After any implementation: G04 fixed-camera two-frame windowed capture + `smallmap_capture.py stats`/`scan-stderr` (`G26 §5`), `t_terrain_shore` unweakened, selftest 29/29, uitest fresh 17/17, `full_width_dark_rows==0`. |
| **Risk** | **MED-HIGH**: `water_cell` hard alpha cut is a non-donor PORT GUARD (`shader:182,246`, `G26-3`); zero coarse swell under shipped constants (`G26-4`); 8-bit height terracing; ~1-cell collar and unreadable donor `mask.b` gate (`G26-5`); reference values come from **one 512×288 JPEG + one thin strip**, not donor GPU pixels (`G26 §2.3`); current shader already modified; do **not** widen the strip by inventing a height threshold or re-import 2D `FOAM_GAIN` glints (`G26:96,117`). |
| **Rollback** | Delete the G26b report if rejected; restore `water3d.gdshader.bak-G27` or `world3d_terrain.gd.bak-G28`, then re-run `t_terrain_shore` and the water capture. |
| **Donor claim / label** | **`DONOR-GROUNDED` inputs** (`G26:85-118`): `water.dev.frag:45-47` shallow/deep colours, `:207-226` specular/reflection composite, `:227` foam peak at 0.535 m, `:175-183` `height>level` coverage, `:77-81` bed colour; shore ids `sandsea1/5/6` (`world3d_terrain.gd:1452-1453`, `texturemap.inc:29-31,463-511`). **OBSERVED screenshot pixels** (not donor GPU truth): foam peak `(224,241,235)`, water body `(184,190,177)` from `maxresdefault_1.jpg` (`G26 §2.2`). **`PORT APPROX`:** port `water_cell` gate, `map_size.x/128` noise scale, 8-bit height grid, sandsea flat-water fallback; all visual gaps `INFERRED`/**UNVERIFIED** until a capture. |

---

## 2. Conflict resolution — one owner per file, in this order

### 2.1 `world3d_entities.gd` — P11 vs M03 vs F2-03

All unapplied; `L04:125-144` is the authority. **Resolution: P11 → M03 → F2-03, serial.**

1. **P11** first (perf; no visual change). Its stats hunk is additive. M03/F2-03 must
   **re-derive** (`git apply --recount --3way` or re-read), never hand-force; fresh `.bak-M03`
   at handover.
2. **M03** second, only after the M04 atom is co-updated (`M03 §7`). M03 explicitly protects
   the field region as byte-identical (`M03:147-148`), so F2-03 follows.
3. **F2-03** last on this file: it overlaps M03's MILLFIX constant comment at `:266-273` and
   must **re-derive `FIELD_QUAD_ROTOR_CLEAR_M = 3.35`** from M03's fixed axle at local
   `+Z 1.8947` (the old value came from the billboarded sail's ground projection). Keep
   `FIELD_SPAN_M` as an alias so P11's `_field_visual["color"]` consumer survives
   (`F2-03:63-64,376,415-420`).

### 2.2 `game.gd` — B03 (landed) → F2-03 → F2-04 → L01 → H07

`L04:178-191` plus L01. **Treat as a serial queue; at no time may two owners hold it.**

- B03 released; its detail call, P1 draws and P2 `tls_*` stamps are already in the file.
- **F2-03** `:2492-2541` (sow + helper); **F2-04** `:3094-3098` (read-only helper) — disjoint
  text but serial grants.
- **L01** call site `:2064` (before smooth) and helpers near `_stamp_forest_borders` `:2272-2284`;
  it consumes `brng` and writes `tileblock`, so it must come **after** the field/mine sim hunks
  are filed and hashed.
- **H07** last, and **only** as a pinned-seed A/B on top of L01 (arm A = L01 only). H07 moves
  `:2039` detail to after `:2067` smooth; L01's spot ids (`grass9`/`grass5`) are not `grass1`,
  so the moved detail pass cannot overwrite them — but BV32 attribution requires L01 held
  constant in both arms. Revert H07 if BV32 does not move.
- Fresh backup **at every handover**: `.bak-F2-03`, `.bak-F204`, `.bak-L01`, `.bak-H07`.
  Note `game.gd.bak-B03-relief` already exists, so cite the *handover* hash, not an older baseline.

### 2.3 `hud.gd` — P12 vs S02

`L04:146-158`: P12 ranges `:89-94,174,218,273,1445-1523,1611,1667-1695`; S02 range
`:439-447`. **No textual overlap, but one owner per file.** Resolution: **one owner holds
`hud.gd` for the whole HUD window**, applies P12 first, then re-derives S02's hunk from the
post-P12 bytes (S02's two comment lines shift later hunks by +2). `.bak-P12` before P12;
**fresh `.bak-S02` after P12**. `hud3d_adapter.gd` stays P12's alone. No HUD/speed acceptance
without a fresh uitest (§0).

### 2.4 `world3d_fx.gd` — B06 / G09 / F2-04 "ghost handoff" / P02-A2 / M??

There is **no mill-wave (M??) claimant** on this file: M03 §4 explicitly excludes the ghost
and leaves `world3d_fx.gd:269-288,448-450,518,579-600…` byte-identical; M01/M02 make no FX
claim. The actual claimants are:

| Claimant | Scope | State / resolution |
|---|---|---|
| **B06** | finished-stage ghost mesh, node `GhostBuildingFinished` | **Landed** (`WAVE_G_CHARTER.md:23`); released after gate. |
| **F2-04** | none in this file | F2-04's "ghost handoff" is a **single insertion in `world3d.gd:_sync_build_ghost()`** that only changes the `Vector2` passed to the unchanged `fx.draw_ghost(sid, wp, ok)` (`F2-04:30-35,99-104,126-134`). `world3d_fx.gd` must stay byte-identical during F2-04. |
| **G09** | footprint honesty: radius source + overlay visibility (`G09:107-145`) | **Follow-up after B06**, backup `.bak-G09`; gate = `t_ghost_final_stage.gd` check 7 flips to PASS with visibility/BoxMesh/scale operands unchanged and `expected_pre_fix_failure` kept as provenance (`G09:155-182`). **Not part of the six requested features** — schedule after them. |
| **P02-A2** | selection-ring batching (`L04:108`) | **No landed proposal** — needs a new ticket; must not be smuggled into G09's grant. |

**Resolution:** `world3d_fx.gd` is **frozen** for the entire six-feature integration. F2-04
snaps in `world3d.gd`; G09 and P02-A2 are separate later grants. If a capture shows a ghost
defect during F2-04, fix the *point* in `world3d.gd`, never the mesh in `world3d_fx.gd`.

### 2.5 Other contested files (summary lock table)

| File | Owner order | Note |
|---|---|---|
| `main.gd` | P15 → S02 | `L04:202`; two cap hunks `:360,:721`, no overlap but serial. |
| `world3d.gd` | P15 (handoff) → F2-04 | `L04:203`; F2-04 insertion at `:484-493`. |
| `world3d_terrain.gd` | B04 reverted → P15 → (P16 optional) → G28 | `L04:160-176,280`; G28 gated on G26b + donor binding. |
| `water3d.gdshader` | current `T-WATER-FAST` owner (release needed) → G27 | §0 governance gap: no `.bak-P13` on disk. |
| `t_hud_layout.gd` | S02 (separate spec grant) | Exact-equality spec update, not weakening. |
| atom files (4 new) | implementation owner authors; **only G04 runs** | `t_mill_rotor_probe.gd`, `t_f2_mill_fields.gd`, `t_f2_mine_snap.gd` verbatim/deltas; G26b is a report. |

---

## 3. Ordered integration sequence

"B0" = the L07 re-verification batch is accepted and COORD has ruled on stale uitest. Each
step ends with filed hashes of file + handover backup; the next grant is issued only after
that. All runner commands are **specifications for G04**, never executed by L05.

### T0 — prerequisites, zero source edits
1. `python variant3d\tools\godot_runner.py status`; PASS needs `pending=0`, `godot.lock=free`,
   `now_serving==next_ticket`, no live Godot (`L07:57-69`).
2. Run `l07-selftest`, **fresh `l07-uitest`** with `--timeout 600` and verify JSON mtime,
   `l07-rendermode`, `l07-p0cap`, `l07-realmap` (`L07:87-125`); keep the three baselines intact.
   Confirm the B01 chessboard removal on the fresh P0 (`L02:146-151`) — this is the owner's
   *most recent* visual complaint and is currently only statically confirmed.
3. Decide stale-uitest remedy; issue written grants and record the lock table §2.5.

### T1 — **MINIMAL FIRST TRANCHE** (owner's most recent visual complaints, gate-safe)

> Owner's newest visual directives are *"not like chessboard — mix light-colour grass with
> darker in spots"* (`L01:34`, `L02:54-55`) and the mill looking wrong (`WAVE_G_CHARTER.md:91-93,
> 128-130`). The smallest set that answers them without touching UI, shader, atlas, config,
> audio or 2D is **L01 + M03**, on two **disjoint** source files. F2-03 is deliberately held to
> T2 because it needs *both* files released and a re-derived rotor clearance.

| Step | Fix | Locked file | Gates before release |
|---|---|---|---|
| 1 | **L01** spots (filled-disc row-runs, `grass9`/`grass5`, donor weights) | `game.gd` only | Fresh `l07-realmap` + C01 `--crop 120,60,1040,580`; component scan (<800 / <15% / ≥35 ids / grass5+grass9 in histogram); `t_map_variety` 5/5; selftest 29/29; C04 R1 no checker. Revert `.bak-L01` if metrics do not move. |
| 2 | **M03** rotor to axle tip, billboard removed | `world3d_entities.gd` only | M04 atom co-updated first; `m04-mill-rotor-probe` windowed 14/14; fresh P0/real-map; `t_mill_rotor`/`t_mill_logic`/`t_render_mode`/`assert_clean`. Revert `.bak-M03` on any RED. |

Both steps run under the one-Godot lock, one at a time; neither edits `app/`, `hud.gd`,
`main.gd`, the shaders or any test threshold. If T1 is green, the owner's newest visual
complaints have an honest, measured answer; if either fails, stop before T2.

### T2 — remaining mill visuals (serialised, two contested files)
3. **F2-03** takes `game.gd` + `world3d_entities.gd` (fresh `.bak-F2-03` both); re-derive
   rotor clearance; F2-05 Atom A deltas authored; gate = `f2-05-millfields-cap1` 10/10,
   `t_mill_logic` 6/6, resow, RNG state, `assert_clean`.
4. **F2-04** takes `game.gd` + `world3d.gd` (fresh `.bak-F204` both); radius decision filed;
   gate = `f2-05-minesnap-cap1` 10/10, `t_ghost_final_stage.gd` unchanged PASS,
   `t_mine_build`/`unified_mine_test`.

### T3 — UI feature (after perf/HUD releases and fresh uitest)
5. **S02** takes `hud.gd` (re-derived after P12), `main.gd` (after P15) and
   `t_hud_layout.gd` as one owner; choose §3.1 or §3.2; gate = 62/62 layout checks at 3
   widths, **fresh** uitest 17/17, selftest 29/29, `t_render_mode`, `config.defaults`,
   3 non-blank PNGs. Optional `acc` saturation is a **separate** decision with its own run.

### T4 — visual A/B and measurement (not gate work)
6. **H07-a** takes `game.gd` last as a pinned-seed A/B on top of L01; ship only if BV32
   moves; else restore `.bak-H07`.
7. **G26b** (read-only, no runner) records the five shore numbers; then, only with a
   water-containing capture and released owners, at most **one** of **G27** (`water3d.gdshader`)
   or **G28** (`world3d_terrain.gd`), each backed up and gated by `t_terrain_shore` + capture.
   No donor-parity PASS is defined for either.

### Lock table (no step violates it)

| File | T0 | T1 | T2 | T3 | T4 |
|---|---|---|---|---|---|
| `game.gd` | — | L01 (step 1) | F2-03 → F2-04 | — | H07 |
| `world3d_entities.gd` | — | M03 (step 2) | F2-03 | — | — |
| `world3d.gd` | — | — | F2-04 | — | — |
| `hud.gd` / `hud3d_adapter.gd` | — | — | — | S02 (after P12) | — |
| `main.gd` | — | — | — | S02 (after P15) | — |
| `t_hud_layout.gd` | — | — | — | S02 | — |
| `world3d_fx.gd` | frozen | frozen | frozen | frozen | G09 (later ticket) |
| `world3d_terrain.gd` | — | — | — | — | G28 (after G26b) |
| `water3d.gdshader` | current owner | current owner | current owner | current owner | G27 (after release) |

---

## 4. Acceptance and stop rules

- Re-run the full gate set **after each tranche**: selftest 29/29, **fresh** uitest 17/17,
  `t_render_mode` PASS / `seam_missing=false`, `assert_clean CLEAN`, 2D `app/` byte-identical,
  windowed P0 + real-map non-blank, `full_width_dark_rows==0`, `SCRIPT ERROR=0`
  (`CHARTER.md:122-130`, `L04 §5`).
- A missing/blank PNG is `UNVERIFIED (NO PNG)`, never a visual PASS (`M04:917-920`,
  `F2-05:627-635,1145-1151`). Headless runs are `SKIPPED_HEADLESS`/`passed=false`/exit 1.
- **Stop the whole integration** on any failing gate, `SCRIPT ERROR`, new seam/dark row,
  flipped `expected_pre_fix_failure`, donor-parity claim, or a restored backup that does not
  match its recorded handover hash. Revert the **whole tranche** from handover backups.
- Every new atom must keep its decisive checks; M04's 14 criteria, Atom A's 8/9 and Atom B's
  5/6 are provenance-bearing and may not be deleted or rescoped.

---

## 5. UNVERIFIED / open register for COORD

1. No fresh uitest exists; 17/17 is stale (`L04:65-70`). This blocks S02 acceptance and
   weakens every tranche sign-off until T0 step 2 completes.
2. `water3d.gdshader` carries landed-looking `T-WATER-FAST` edits with **no `.bak-P13`** —
   governance gap; get a hash/baseline before granting G27.
3. F2-02 donor field truth (49-node 7×7 cluster, 1.3× decal) **conflicts** with the owner's
   four-patch quad request; the quad is an owner-directed PORT APPROX, and no donor 3-D frame
   adjudicates it (`F2-02:214-220`, `F2-03:91-94`).
4. F2-02 donor mine snap radius 1.5 cells (3.0 m) vs port 4.0 m is unresolved; this plan
   keeps 4.0 m for the ghost-only tranche (`F2-04:298-302`).
5. M04 atom is still a proposal; M03 cannot be accepted until it is authored **and**
   co-updated (`M03:326-344`). S03 never landed; L01/H07/G26 have no dedicated atom.
6. F2-03's `3.35 m` rotor clearance and M01/M03's sail half-span are pre-/post-M03 dependent;
   re-derive, do not reuse blindly (`L04:319-321`).
7. L01 coverage (~3% by derivation) may not move BV32; H07's BV32 response and G26's visual
   gaps are all **INFERRED/UNVERIFIED** until real G04 captures (`L01 R3`, `H07 §8`, `G26 §6`).
8. Donor `.inc` call sites for field sowing and mine snap are `[*] = ;`-commented; donor
   runtime activation is UNVERIFIED everywhere (`F2-02:31-33,317-323`, `H06 §1.2`).
9. No donor GPU A/B frame exists. Every "looks like donor" statement in M03/F2-03/L01/H07/G26
   stays INFERRED/UNVERIFIED regardless of green gates (`CHARTER.md:57-58,124-130`).

*End of L05 report. Read-only: one report written; no Godot process, no runner job, no code,
asset, config, test, fixture, result, queue or git mutation; no donor-parity claim.*
