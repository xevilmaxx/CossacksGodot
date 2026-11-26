---
id: V33
ticket: "TERRAIN-SWARM-2026-11-26 / V33 — machine-checkable DO NOT DO review checklist for the fresh terrain implementation"
owner: V33 (read-only verification subagent)
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER__NO_CODE_EDIT__NO_DONOR_ACCESS
created: 2026-11-26
owner_file: "docs/terrain_swarm_2026-11-26/reports/V33_do_not_do_checklist.md"
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
scope: "Read CHARTER.md, SWARM_BOARD.md, reports/P06_prior_wave_distill.md, spec/13_PRIOR_WAVE_MEMORY.md, spec/10_STAGE_ORDER.md §3, plus landed reports named in §1. Read-only inspection of variant3d/scripts/terrain_donor_*.gd, variant3d/shaders/terrain_donor*.gdshader, variant3d/tools/decode_donor_*.py and the cited legacy files. One PowerShell read-only scan was run. No source/shader/config/asset/test/git edit; no Godot job; no donor binary opened or executed."
parity_guard: "NO DONOR GPU A/B FRAME EXISTS (CHARTER §2/§5/§6.5). Every donor statement is a structural citation of landed evidence; every port statement is PORT APPROXIMATION or UNVERIFIED. NO DONOR PARITY CLAIM, no PASS/gate claim."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V33 — DO NOT DO review checklist (implementation files)

## Executive summary

1. **[O]** 19 rejected approaches are converted below into exact forbidden patterns, a reviewer-run static check, the donor-grounded replacement with a landed citation, and a severity. Sources are limited to landed reports plus read-only legacy/new-file observation. **No donor parity claim is made.**
2. **[O]** A read-only scan of the 9 current `terrain_donor_*` / `decode_donor_*` files found **6 hits** for the top-8 patterns: four are benign telemetry/docstring/field-name text (`terrain_donor_gen.gd:641`, `terrain_donor_props.gd:552`, `decode_donor_cfg.py:23`, `decode_donor_masks.py:14`), and **two are live executable hits in `terrain_donor_props.gd` (`:76`, `:608` at final scan; line numbers drift because the file is being concurrently edited)** — `const DONOR_UNITS: float = 160.0` and `cell_scale = float(dim.x) / DONOR_UNITS`. That is exactly the high-risk pattern in `V08_coordinate_scale.md` R1 (`:441`) and contradicts the fresh-path rule at `V08:324` (donor numbers 1:1, `scale=1.0`). **[U]** Whether I09 intends this as a labelled PORT APPROX port-fallback transform is an owner/COORD adjudication, not something this checklist can close.
3. **[D]** The other 18 patterns have **no executable hit** in the scanned new files at this ticket's scan. This is a static observation only: it does not prove runtime ordering, deterministic replay, or visual behaviour, and it is not a gate PASS.
4. **[O]** `reports/V28_code_review_r1.md` **has not landed** (path glob and whole-tree grep for `V28` returned no file at this ticket). This report is therefore input to a future V28/code review, not a response to it.
5. **[D]** Contradictions were re-checked with multiple instruments before inclusion (§3): `mix64`, `DONOR_UNITS=160`, `B>58`, `6` vs `3` smoothing passes, `3×3` kernel, food rects, `rgb*a` albedo, `HEIGHT_SCALE`/face promotion.

---

## 1. Evidence table (landed sources only)

| Ev | Label | Source path:line | What it licenses in this checklist |
|---|---|---|---|
| E01 | [O] | `docs/terrain_swarm_2026-11-26/CHARTER.md:43-44,84,§6.5` | Labels mandatory; no invention, no synthetic noise/dither, no lowered gate, no fake A/B, no donor parity claim without GPU A/B. |
| E02 | [O] | `docs/terrain_swarm_2026-11-26/reports/P06_prior_wave_distill.md:107-129` (`§2` 18 rejected approaches), `:227-240` (`§6`) | Primary rejection ledger: B04, HEIGHT_SCALE, S-25-09, tile-art relief, forced cliff art, heightmap-as-albedo, spot/guard tweaks, parity-as-gate. |
| E03 | [O] | `docs/terrain_swarm_2026-11-26/spec/13_PRIOR_WAVE_MEMORY.md:17-21` | The 12 ranked forbidden hacks are integrated spec memory. |
| E04 | [O] | `docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md:58-63` | §3 explicitly forbids dither/noise, face promotion, HEIGHT_SCALE fudge, tile-art relief, uniform scatter, post-collision height writes, forced cliff art, heightmap-as-albedo, shadow/AO fakery, synthetic mottling, lowered gates, invented constants. |
| E05 | [O] | `docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md:25-50,55-83,97-98` | Face promotion (`_relief_face_at()`, `span*0.03`, floor `0.05`, `|h|>2.4/>2.7`) produced dense rings and was fully reverted. |
| E06 | [O] | `docs/terrain_swarm_2026-11-26/reports/P01_pipeline_audit.md:316-331,340-352,356-377,414-416` | Current pipeline, RNG/scatter ledger, documented divergences, "do not weaken gates"; shader `:427`/`:475`, cliff art `:1332/:1340-1354`. |
| E07 | [O] | `docs/terrain_swarm_2026-11-26/reports/V01_unverified_resolution.md:145,154,158,454` | `mix64` refuted (identity re-seeds); no donor `160`; stage-7/9 food-rect claim contradicted. |
| E08 | [O] | `docs/terrain_swarm_2026-11-26/SWARM_BOARD.md:73-74` (C8/C9) and `V03_open_items_resolution.md:138-139,161-162` (C-G/C-F) | Multi-pass adjudication: identity re-seeds, no `mix64`, no food rects in `SetupStartingResources`. |
| E09 | [O] | `docs/terrain_swarm_2026-11-26/reports/V08_coordinate_scale.md:247-255,324,441` | `DONOR_UNITS=160` is PORT APPROX with no donor literal; fresh path must use donor numbers 1:1 / `scale=1.0`; R1 risk = high. |
| E10 | [O] | `docs/terrain_swarm_2026-11-26/reports/X19_mask_decoder_gap.md:98,189-194,297,328,371,410` | `B>58` off-by-one: `B=58` → `h=-0.250196`; `h<-0.25` fraction `0.213857` vs `(B>58)` `0.213643`; starts counted as water. Use `B>=58`, exclude starts. |
| E11 | [O] | `docs/terrain_swarm_2026-11-26/reports/V20_smoothing_reconciliation.md:18-50,93-104` | Four-pass verdict: skirmish path = 3 passes (`smoothtiles.inc:237`); `TileSmoothPasses=6` is editor-facing, no consumer; atomic op is one adjacent pair, never a 3×3 kernel. |
| E12 | [O] | `docs/terrain_swarm_2026-11-26/reports/X08_tile_smooth_engine.md:37` | F03 phrase "fires on a 3×3 tile neighbourhood" is not literal. |
| E13 | [O] | `docs/terrain_swarm_2026-11-26/reports/X22_field_sowing_translation.md:53,66,99,524,585` + `reports/D07_resources_bin.md:375,398` + `reports/V12_resource_spec.md:82,371` | Three-pass refutation: no food rects in `SetupStartingResources`; fields are a mill runtime object/decal effect; spec/10 rows 50/53 are stale. |
| E14 | [O] | `docs/terrain_swarm_2026-11-26/reports/V21_gate_register.md:85,95,179` | GR-A13 (food rects ⇒ FAIL, red), GR-A23 (lowered threshold/deleted assertion/invented constant/parity wording ⇒ FAIL, red). |
| E15 | [O] | `docs/terrain_swarm_2026-11-26/reports/V04_tree_conflicts.md:63,140,161` | Stale Z07 atom: keep `expected_pre_fix_failure: true`; do not lower `SCALE_WANT`/`BBOX_TOL`/count. |
| E16 | [O] | `variant3d/scripts/game.gd:651-676,680-708,847-861,1254-1274,1297-1310,2542-2547,2729-2740` | Read-only legacy examples for scatter, tile-art relief, dither cap, collision-only pass, mottle hash, half-cell field step. |
| E17 | [O] | `variant3d/scripts/world3d_terrain.gd:131,179-180,805-813,1332,1340-1354` + `variant3d/shaders/terrain_tileindex.gdshader:424-427,475` | Read-only legacy examples for HEIGHT_SCALE, cliff gates, cliff art, `rgb * mix(...)` albedo fold. |
| E18 | [O] | `variant3d/scripts/mapgen.gd:218-235` + `variant3d/tools/import_donor_masks.py:98` + `variant3d/tools/donor_gen.py:59` + `variant3d/scripts/pattern_gen.gd:9,92` + `variant3d/scripts/world3d_relief.gd:48,137` | Read-only legacy examples for smoothed kernel/pass lowering, B>58, DONOR_UNITS. |
| E19 | [O] | Read-only scan of `variant3d/scripts/terrain_donor_*.gd`, `variant3d/shaders/terrain_donor*.gdshader`, `variant3d/tools/decode_donor_*.py` (9 files) at write time | No executable hits except `terrain_donor_props.gd:76,608` for D14; benign doc/telemetry hits listed in §5. Line numbers are observed-at-scan and may drift. |

### 1.1 Files checked by the scan (E19)

`terrain_donor_data.gd`, `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, `terrain_donor_props.gd`, `terrain_donor.gdshader`, `decode_donor_cfg.py`, `decode_donor_masks.py`, `decode_donor_pattern.py`, plus any other file matching the two globs under `variant3d/`. `inbox/backup/**` and `docs/**` were excluded so backup and audit prose cannot be mistaken for implementation.

---

## 2. Checklist table (19 patterns)

Severity key: **CRITICAL** = red gate / rollback trigger (`V21:95,179`); **HIGH** = must be fixed or explicitly adjudicated by COORD before integration; **MEDIUM** = advisory/needs second pass. Severity applies **if found in a new `terrain_donor_*` / `decode_donor_*` implementation file**.

| ID | Forbidden pattern (exact) | Legacy file:line example (read-only) | Reviewer static check | Correct donor-grounded behaviour + citation | Severity if found |
|---|---|---|---|---|---|
| D01 | **Dither/noise field**: any synthetic `_noise2`/hash/fbm/value-noise/beauty field, or extension of the existing `0.03` dither cap. | `game.gd:1267-1274` (`_noise2(...)` + `RELIEF_PLATEAU - 0.03`); `game.gd:2542-2547` (`_hash2`, "meadow/mottle"); `variant3d/MECHANICS.md:651` ("Meadow mottling strengthened to ±9%"). | `Select-String -Path <new> -Pattern '_noise2','fbm','value_noise','_hash2','dither'` on non-comment lines; also assert no new `0.03` cap literal. | Height comes only from donor mask R codes and decoded `.pattern` float grids; no synthetic field (S-25-09). `CHARTER.md:84`; `P06 §2 item 3`, `P06 §6 item 3`; `spec/10:41-42,60`. | **CRITICAL** |
| D02 | **Face promotion**: `_relief_face_at()`, span-scaled `cDiff`, absolute `|h|` promoters, or any relief-driven face/tile promotion. | `B04_relief_impl.md:45-50` (reverted `_relief_face_at()`, `span*0.03`, floor `0.05`, `|h|>2.4/>2.7`); live legacy cliff art remains at `world3d_terrain.gd:1332,1340-1354` (`P01 §6 item 8`). | `Select-String -Pattern '_relief_face_at','_relief_promoted','b04_relief_promotion','DONOR_ROCK8_H','DONOR_ROCK4_H'`; verify `_face_mode_at` writes UV2.y only (`terrain_donor_mesh.gd:336-355,745-752`). | Donor promotion path is ENGINE/UNVERIFIED; relief cells must force face 0, never change UV2.x or art. `P06 §2 item 1`, `P06 §6 item 1`; `P01 §6 item 8`; `spec/01 §3:51-53` via `terrain_donor_mesh.gd:28-31`. | **CRITICAL** |
| D03 | **HEIGHT_SCALE multiplier fudge**: any multiplier other than the labelled contract `1.0`, or amplitude exaggeration presented as a fix. | `world3d_terrain.gd:131` (`const HEIGHT_SCALE := 1.0`), `:1311` (`height[i]*HEIGHT_SCALE`); rejected as primary in `P06 §2 item 2`. | Regex `HEIGHT_SCALE\s*(?::\s*float\s*)?=\s*(?!1\.0\b)[0-9]` and `\*\s*[2-9]` near a height write. Current new file is clean: `terrain_donor_mesh.gd:42,150,734`. | Stored float stays raw; no vertical multiplier. `V08:332` ("keep raw float; never multiply"); `P06 §6 item 4`; `CHARTER.md:84`. | **CRITICAL** |
| D04 | **Tile-art relief**: relief passes writing `terrain=5`/rock ids, or using rock/cliff tile colours as the relief cue. | `game.gd:847-852` (stone scar `terrain[ii]=5`); `game.gd:853-861` (hill branch now `pass` after removing the paint); collision-only pass `game.gd:1297-1310`. | `Select-String -Pattern 'terrain\[[^\]]+\]\s*=\s*5','_paint_terrain','rock[0-9]'`; assert relief producers touch only `height`/`_height`. | Relief writes height only; collision is separate from art; donor rock art comes from collision tags (`texturemap.inc:557-591`). `P06 §2 item 4`, `P06 §6 item 5`; `B03 §11` via `P06 §5.2`. | **HIGH** |
| D05 | **Forced cliff art**: lowering a global height/threshold to fire `rock8/rock4` or `vf/vs` art on port relief terraces. | `world3d_terrain.gd:179-180` (`DONOR_ROCK8_H=2.7`, `DONOR_ROCK4_H=2.4`), `:805-813` (`_donor_cliff_name`); `B04 §3:71-74`. | `Select-String -Pattern 'DONOR_ROCK8_H','DONOR_ROCK4_H','_apply_shore_cliffs','_cliff_tile_for','absf\([^)]*\)\s*>\s*2\.[47]'`. | Z04-style guard is the safe direction: return face 0 on producer-stamped cells; donor literals remain citations, not a new promoter. `P06 §2 item 5`, `P06 §6 item 1`; `Z02 §3`/`L03 §3` via P06. | **CRITICAL** |
| D06 | **Heightmap-as-albedo**: routing mask/detail/alpha/atlas/height into `height[]`, or claiming the height layer is drawn as albedo. | `terrain_tileindex.gdshader:424-427` (`rgb = rgb * mix(1,a,mask_to_alpha) * v_packed + v_specular`), `:475` (`ALPHA=1.0`); refuted in `P06 §2 item 6`. | `Select-String -Pattern 'rgb\s*\*\s*mix\([^)]*a','mask.*height\[','albedo.*height\[','height.*albedo'`. | Mask is a `bmTransparency` crossfade weight, `.a` only, never a height input; tile identity and mesh invariants stay intact. `P06 §1B`, `P06 §3` alpha row; `H03/H05/H04` via `P06 §2 item 6`. | **HIGH** |
| D07 | **Uniform scatter**: uniform random tree/stone/bush scatter instead of donor budget/grid/keep-clear placement. | `game.gd:651-676` (`_scatter_forest`), `game.gd:680-708` (`_scatter_bushes`); `P01:345` RNG ledger. | `Select-String -Pattern 'randf_range\(-?spread','for attempt in 40','randf\(\) < 0\.[0-9]+'` plus manual check that `needed=floor(W*H*freq)` and `trycount=256*(320²)/(W*H)` exist. | Use donor placement budget, 25-cell grid, 3 starts × 3 keep-clear ellipses (5×7,12×15,22×18). `spec/10:46-48`; `D07` via `P06 §1E`. | **HIGH** |
| D08 | **Post-collision height writes**: any `height[i] = ...` after `collision`/`blocked` has consumed height in the same build path; feedback from collision into height. | No live example after B03/L03; defect named at `spec/10:33-34`; pre-collision example `game.gd:1254-1274` then collision `:1278-1310`; invariants `P06:217-218`. | Static stage-order check: list functions writing `height`/`_height` and functions writing `collision`/`blocked`/`set_collision`; flag any height write ordered after a collision write in `build()`. | Relief stamps feed height before collision; collision consumes height; no write-back. `spec/10 §1 items 5,8`; `P06 §3` relief/smoothing rows. | **HIGH** |
| D09 | **Synthetic mottling**: invented luminance/gain/mottle field used as terrain variation or relief cue. | `game.gd:2542-2547` (`_hash2` "meadow/mottle"); `variant3d/MECHANICS.md:651` ("±9%"); 2D-only tools `variant3d/tools/terrain_blend_test.py:318-328` (`dither`, quantised gain) are out of scope for the new 3D module. | `Select-String -Pattern 'mottle','gain_amp','_smooth1d','value_noise'` restricted to new files; classify `mask_...` scratch keys as benign. | Large-scale variation must come from donor tile ids, relief/decal/prop data, never a luminance field. `P06 §6 item 6`; `P06 §2 item 3` (S-25-09). | **HIGH** |
| D10 | **Lowered gates**: threshold/assertion relaxed, `expected_pre_fix_failure` flipped, advisory FAIL silently promoted. | `variant3d/tests/t_relief_props_qa.gd:41-42` (`BBOX_TOL=0.05`, `SCALE_WANT=1.0`), `:158` (`expected_pre_fix_failure: true`); `V04:63,140,161`. | `Select-String -Pattern 'expected_pre_fix_failure\s*=\s*false','expected\s*=\s*0','SCALE_WANT\s*=\s*0?\.[0-9]\|[2-9]','passed\s*=\s*true'` on files the new module owns/touches; diff-check no assertion deleted. | Strengthen stale atoms; keep red gates; no threshold lowered. `V21 GR-A23:95`; `V04 C10:161`; `CHARTER.md:84`. | **CRITICAL** |
| D11 | **Invented donor constants**: any new numeric donor constant without a donor `path:line` citation. | `variant3d/tools/donor_gen.py:59` (`DONOR_UNITS=160.0`); `variant3d/scripts/pattern_gen.gd:9` (same); `game.gd:1273` (`-0.03` cap); `A02_algorithm.md:207-209` (`mix64` placeholder). | Enumerate numeric literals in new files (`Select-String -Pattern '=\s*[0-9]+\.[0-9]+'`) and require a same-line/nearby donor citation; every reported donor number must appear in a landed report. | No invention; undecodable fields stay `null` + `UNVERIFIED`. `CHARTER.md:43-44,84`; `A03 §78` via `A03_asset_pipeline.md:78`. | **HIGH** |
| D12 | **Parity claims**: `visual_parity_claim=true`, "donor parity confirmed/achieved/PASS", or a green gate/metric presented as parity. | No live code claim found; guards exist at `world3d_terrain.gd:57,1647`, `terrain_donor_mesh.gd:13,89,666`; rejection ledger `P06 §2 item 18`. | `Select-String -Pattern 'visual_parity_claim\s*(?::=|=)\s*true','parity.*(PASS\|confirmed\|achieved)','PASS.*parity'`. | Parity stays UNVERIFIED until a real matched donor GPU A/B frame exists. `CHARTER.md:43-44,§5,§6.5`; `P06` frontmatter `:9`; `V21:179`. | **CRITICAL** |
| D13 | **mix64 key derivation**: per-stage independent streams, `mix64(randkey1,randkey2,stable_hash(sid))`, stage hashing. | `A02_algorithm.md:207-209` (label-only placeholder); `P01:346` (`gen_rng` dead). | `Select-String -Pattern 'mix64','stable_hash','hash\([^)]*sid','stage_key'`; require verbatim `SetRandomKey(randkey1)` identity re-seeds. | Donor re-seeds the same 64-bit key pair verbatim: 11 `SetRandomKey(randkey1)` + 3 `SetRandomExtKey64(randkey0,randkey1)`; key-mixing internals `[U]`. `V01:145`; `SWARM_BOARD C8:73`; `V03 C-G:139`; `spec/02_SEED_AND_RNG.md:68,77`. | **HIGH** |
| D14 | **DONOR_UNITS=160 doubling**: `DONOR_UNITS`, `s = W/160`, or any radius/offset scaled by `W/160` in the fresh path. | `donor_gen.py:59,147-158,193`; `pattern_gen.gd:9,92`; `world3d_relief.gd:48,137`; **LIVE HIT in new file** `terrain_donor_props.gd:76` (`:608` scaling) at final scan. | `Select-String -Pattern 'DONOR_UNITS','/\s*160\b','cell_scale'`; re-check with `V08_coordinate_scale.md:324,441` before excusing any hit. | Generator distance unit = 1 map cell; use donor numbers 1:1 and `scale=1.0`; keep `s` only in the legacy path. `V08:324,441` (R1 high); `V01:154` (no donor `160`). | **HIGH** |
| D15 | **B>58 off-by-one**: water classification `B > 58` (integer ≥59) or counting white start pixels as water. | `variant3d/tools/import_donor_masks.py:98` (`rgb[:, :, 2] > 58`); `X19:410`. | `Select-String -Pattern '>\s*58','>=\s*59'`; assert `B>=58` and pure-white starts excluded. | `B=58` → `h=-0.250196`; use continuous `h<-0.25` / `B>=58`; `V2` vector gives `0.213857` vs buggy `0.213643`. `X19:98,189-194,297,328,371`; `spec/11_ASSET_CONVERSION.md:83`. | **HIGH** |
| D16 | **rgb*alpha albedo multiply**: mask folded into RGB (`rgb * a`, `rgb * mix(...,a,...)`) or `mask_to_alpha` used as a fix rather than the sanctioned diagnostic. | `terrain_tileindex.gdshader:427,475`; `P06 §2 item 9` (A/B diagnostic only). | `Select-String -Pattern 'rgb\s*\*\s*a','rgb\s*\*\s*mix\([^)]*a','ALBEDO\s*=\s*rgb\s*\*'`; verify new shader keeps mask in ALPHA (`terrain_donor.gdshader:297,305-306`). | Donor mask is framebuffer alpha via `bmTransparency`; `mask_to_alpha=0` is a partition experiment, not a shipped fix. `terrain_donor.gdshader:36-37,297-306`; `P06 §3` alpha row; `A02 Q3/P3` via `P06 §2 item 9`. | **HIGH** |
| D17 | **6-pass smoothing**: implementing `TileSmoothPasses=6` or any 6-call/6-iteration tile smooth. | Donor `data/gen/globalparams.cfg:9` (`TileSmoothPasses=6`), preserved contradiction in `decode_donor_cfg.py:23-24`; port quality lowering `mapgen.gd:220-224`. | `Select-String -Pattern 'TileSmoothPasses\s*=\s*6','passes\s*=\s*6','SmoothTileMap\([^)]*,\s*6'`. | Skirmish path uses exactly 3 passes (`smoothtiles.inc:237`); preserve cfg contradiction, do not "fix" it. `V20:18-25,93-104`; `D06 P22`; `SWARM_BOARD C2:67`. | **HIGH** |
| D18 | **3×3 smoothing kernel**: double-buffered 3×3/neighbourhood average instead of donor adjacent-pair sweeps. | `mapgen.gd:228-235` (four-diagonal `i±w±1` average, 3 quality passes); `game.gd:2571,2586` comment about the old 3×3 road stamp; `X08:37` corrects F03's phrase. | `Select-String -Pattern '3\s*[xX]\s*3','i-w-1','i+w+1','kernel','neighbou?rhood'`; manual: snapshot once → 3×(horizontal then vertical adjacent-pair sweep) → one write-back, in place. | Atomic op is a single axis-aligned adjacent pair; double-buffer changes results. `V20 §0.3/E09:38,64`; `X08 §0:37`. | **HIGH** |
| D19 | **Food rects in SetupStartingResources**: guaranteed food/field rectangles attributed to start-resource setup; half-cell field lattice. | Stale claim `spec/10_STAGE_ORDER.md:50,53` and `A02_algorithm.md:637,643`; port field bug `game.gd:2729-2740` (`step = 1.6981*TILE*0.5`). | `Select-String -Pattern 'SetupStartingResources','food_rect','guarantee.*food'` in new files; benign notes at `terrain_donor_gen.gd:1405,1446` are triage-only. Reject any food creation inside a start-resource function. | Zero food rects in that procedure; fields are mill-seeded 49 nodes @ `1.6981` cells, 45° + `sqrt(2)*size` snap, `1.3×` decals. `X22 X-C6:53`; `D07:375,398`; `V12 C-V4:82`; `V21 GR-A13:85`. | **HIGH** |

### 2.1 Patterns deliberately not converted into a regex

- **D08 (post-collision height writes)** and **D19 (stage attribution)** are order/semantics checks; a regex alone cannot prove them. The reviewer must inspect the function sequence in the new generator/mesh file, not just grep.
- **D11 (invented constants)** is a citation audit, not a pure pattern match; a literal with a donor `path:line` is allowed, a literal without one is not.
- **D10 (lowered gates)** also requires a `git diff` review of any test file the new module causes to be edited; new implementation workers must not edit tests at all (`CHARTER.md:74`).

---

## 3. Multi-pass verification of contradictions (owner directive, `CHARTER.md:85-93`)

| Contradiction | Pass 1 | Pass 2 | Pass 3 | Accepted verdict / label |
|---|---|---|---|---|
| `mix64` per-stage keys (`D13`) | `A02:207-209` proposes placeholder | `V01:145` enumerates literal `SetRandomKey(randkey1)` sites, no mix64 | `SWARM_BOARD C8:73` + `V03 C-G:139` + `spec/02:68,77` agree | **[O] REFUTED**. Identity re-seeds; internals `[U]`. No mix64 in checklist. |
| `DONOR_UNITS=160` (`D14`) | `donor_gen.py:59`, `pattern_gen.gd:9` present it as scale | `V01:154` whole-script grep: no donor map-scale `160` | `V08:324,441` sets fresh rule 1:1 / `scale=1.0`, risk high | **[D] PORT APPROX**, must not enter fresh path. Live new-file hit flagged, not excused. |
| `B>58` (`D15`) | `import_donor_masks.py:98` literal `>58` | `X19 E20` fresh decode: 22 px at `B=58`, delta `0.000214` | `X19:297,328,371` + `spec/11:83` prescribe `B>=58` excluding starts | **[O] BUG**. Use `h<-0.25`/`B>=58`. |
| `TileSmoothPasses=6` vs `3` (`D17`) | `globalparams.cfg:9` literal 6 | `smoothtiles.inc:237` literal 3 | `V20:93-104` four instruments: 0 script consumers of cfg key; `D06 P22` agrees | **[D] 3 passes** for skirmish; 6 preserved as editor-facing contradiction (C2). |
| 3×3 kernel (`D18`) | F03 phrase "3×3 neighbourhood" (`X08:37`) | `X08 §0` says not literal | `V20 §0.3/E09` reads adjacent-pair sweeps | **[O] No 3×3 kernel**. Port `mapgen.gd:228-235` is a PORT APPROX. |
| Food rects (`D19`) | `spec/10:50,53` + `A02:637,643` assert them | `D07:375,398` direct donor read: none | `V12 C-V4` + `X22 X-C6` third instrument: full `dogenerate.inc:720-980` grep zero hits | **[O] REFUTED**. Spec rows stale; fields are mill runtime effect. |
| `rgb*a` albedo (`D16`) | shipped shader `:427` folds mask into RGB | `P06 §1B/§2 item 6`: H03/H05/H04 refute heightmap-as-albedo | `terrain_donor.gdshader:36-37,297-306` implements `.a`-only crossfade | **[D] Legacy pattern rejected**; `mask_to_alpha=0` remains diagnostic only. |
| HEIGHT_SCALE / face promotion (`D03`/`D05`) | `world3d_terrain.gd:131,179-180,805-813` literals | `B04 §2-5` reverted after owner capture showed rings | `P06 §2 items 1,2,5`, `Z02 §2`, `V08:332` agree | **[O] REJECTED**. Raw float, no promoter, no multiplier. |

---

## 4. Ready-to-run PowerShell scan (top 8 patterns)

Run from repo root. It scans only new implementation files, skips `#`/`//` comment lines, and prints `file:line: [pattern] source`. It is a **triage tool**, not a gate: docstring lines and telemetry strings can hit and must be classified by a human. Expected benign hits at write time are listed after the snippet.

```powershell
$ErrorActionPreference = 'Stop'

# Only fresh implementation files; no backups, no docs prose.
$files = Get-ChildItem -Path 'variant3d' -Recurse -File | Where-Object {
  $_.Extension -in '.gd', '.gdshader', '.py' -and
  ($_.Name -like 'terrain_donor*' -or $_.Name -like 'decode_donor*') -and
  $_.FullName -notmatch '\\(inbox|backup)\\'
}

# Top 8 = D01, D02, D03, D14, D15, D16, D17+D18, D12.
$patterns = [ordered]@{
  'P1_noise_dither'  = '(_noise2|fbm|value_noise|_hash2)\s*\(|\bdither\b'
  'P2_face_terrain5' = '_relief_face_at|_relief_promoted|DONOR_ROCK[48]_H|terrain\[[^\]]+\]\s*=\s*5|_cliff_tile_for'
  'P3_height_scale'  = 'HEIGHT_SCALE\s*(?::\s*float\s*)?=\s*(?!1\.0\b)[0-9]|(HEIGHT_SCALE|height_scale)\s*\*\s*(?!1\.0\b)[0-9]'
  'P4_donor_units'   = 'DONOR_UNITS|\b(MAP_W|map_w|W|w)\s*/\s*160\b'
  'P5_B_gt_58'       = '(B|mask_b|rgb\[:,\s*:,\s*2\])\s*>\s*58\b'
  'P6_rgb_alpha'     = 'rgb\s*\*\s*(mix\([^)]*\ba\b|\ba\b)|ALBEDO\s*=\s*rgb\s*\*'
  'P7_smooth_6_3x3'  = 'TileSmoothPasses\s*=\s*6|SmoothTileMap\([^)]*,\s*6\s*\)|\bpasses\s*(?::=|=)\s*6\b|\b3\s*[xX]\s*3\b'
  'P8_parity_claim'  = '(?i)(visual_parity_claim|parity_claim)\s*(?::=|=)\s*true|(?i)donor\s+(gpu\s+)?parity\s+(is|=|:)\s*(true|passed|confirmed|achieved)'
}

$hits = 0
foreach ($f in $files) {
  $lines = Get-Content -LiteralPath $f.FullName
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*(#|//)') { continue }   # prose/comment guard
    foreach ($k in $patterns.Keys) {
      if ($line -match $patterns[$k]) {
        $hits++
        '{0}:{1}: [{2}] {3}' -f $f.FullName, ($i + 1), $k, $line.Trim()
      }
    }
  }
}
"FILES=$($files.Count) HITS=$hits"
```

### 4.1 Observed output at write time (E19) and triage

```
variant3d/scripts/terrain_donor_gen.gd:641: [P4_donor_units] _tel["mine_band_units"] = "MAP CELLS 1:1 (V08:155-190) — no DONOR_UNITS scaling"
variant3d/scripts/terrain_donor_props.gd:76:  [P4_donor_units] const DONOR_UNITS: float = 160.0   # port pattern_gen.gd:9 ...
variant3d/scripts/terrain_donor_props.gd:552: [P4_donor_units] "pattern_index", "note", "donor_units"]:
variant3d/scripts/terrain_donor_props.gd:608: [P4_donor_units] var cell_scale: float = float(dim.x) / DONOR_UNITS if dim.x > 0 else 1.0
variant3d/tools/decode_donor_cfg.py:23:      [P7_smooth_6_3x3] ... TileSmoothPasses=6 vs script SmoothTileMap(...,3), and
variant3d/tools/decode_donor_masks.py:14:   [P5_B_gt_58] ... (B>58 off-by-one; starts ...
FILES=9 HITS=6
```

- **Benign / triage-only:** `terrain_donor_gen.gd:641` (telemetry string asserting *no* scaling), `terrain_donor_props.gd:552` (field-name list), `decode_donor_cfg.py:23` and `decode_donor_masks.py:14` (Python docstrings describing the legacy contradictions; the snippet skips `#`/`//` but not triple-quoted docstrings).
- **Live hit requiring adjudication:** `terrain_donor_props.gd:76` + `:608` — see D14 / E19. [U] Intent as labelled PORT APPROX fallback vs V08 R1 violation.
- **No hits:** P1, P2, P3, P6, P8. This is a static observation only; no gate PASS and no donor parity claim.
- **Line drift warning [O]:** line numbers in `terrain_donor_gen.gd` and `terrain_donor_props.gd` moved during this ticket (e.g. scaling line observed at `:590`, then `:602`, then `:608`). Re-run the snippet immediately before acting; cite the fresh output.

---

## 5. Implications for V28 / code review

1. **[O]** `reports/V28_code_review_r1.md` is **not landed** (glob `**/V28*` and tree-wide grep `V28` returned no file at this ticket). Attach this checklist to V28 when it lands; do not infer V28's verdicts.
2. **[D]** Static cleanliness is necessary but insufficient. A reviewer must still verify stage order (D08), 11+3 identity re-seeds (D13), no sim write-back, and the four-method composition contract (`P01:395-397`) by reading code, not by trusting the scan.
3. **[D]** The one live D14 hit is the highest-value review item. `V08:441` rates a fresh-path `W/160` copy **high**; `V08:324` requires 1:1 donor cell numbers. If I09's feed is the committed Z08 port fallback (`terrain_donor_props.gd:49`), COORD must decide whether to (a) keep it behind an explicit `PORT APPROX` switch with `scale=1.0` for donor feeds, or (b) remove it from the fresh path. This checklist does not make that decision.
4. **[D]** Docstring hits are not defects: `decode_donor_cfg.py:22-24` deliberately preserves C2, and `decode_donor_masks.py:12-15` documents X19's bug without repeating it. A reviewer who "fixes" those strings would destroy the contradiction record.
5. **[D]** No donor parity claim may enter the V28 review from static output: `CHARTER §5/§6.5`, `P06 V-01`. Green scan = "no forbidden token on non-comment lines", nothing more.

---

## 6. Risks

| Risk | Label | Mitigation |
|---|---|---|
| Comment/docstring/telemetry false positives (observed: 4 of 6 hits) | [O] | Classify each hit; do not delete contradiction-preserving docstrings. |
| Concurrent edits shift line numbers mid-review (observed) | [O] | Re-run §4 snippet at action time; cite fresh output, not this table's line numbers. |
| Regex cannot prove stage order, RNG identity, sim write-back or visual result | [D] | Manual code review of D08/D13/D19; no gate PASS from this report. |
| Over-blocking legitimate donor literals | [I] | D11 requires a donor `path:line`, not a ban on numbers; `TILE_M=2.0` is donor-cited (`V08:331`). |
| Mistaking a labelled A/B diagnostic for a fix (`mask_to_alpha=0`) | [I] | `P06 §2 item 9`: diagnostic only; requires real binding + config key and matched-camera frames. |
| Fresh module stacked with legacy mesh/water (two nodes) | [D] | `P01:417-420`; integration owner must keep the switch exclusive. |
| No donor parity | [O] | All findings are structural/static; parity stays UNVERIFIED (`CHARTER §2/§5/§6.5`). |

---

## 7. Open questions

1. **[U] / COORD + I09:** Is `terrain_donor_props.gd:76,608` (`DONOR_UNITS`, `cell_scale = dim.x / DONOR_UNITS`) an intentional, labelled PORT APPROX transform for the *port fallback* feed only, or a V08 R1 violation in the fresh path? Landed evidence (`V08:324,441`, `V01:154`) says the fresh donor path must be 1:1; the file header says "NOT donor metres". Needs a named adjudication, not a silent edit.
2. **[U] / owner:** Should the §4 snippet be promoted into a red gate? Not done here: gates are COORD-only (`V21`, `CHARTER §4`), and a token scan alone is not an acceptance test.
3. **[U] / V28 owner:** When V28 lands, does it review the same 9 files, or has the file set grown? Re-scope §1.1 before cross-checking.
4. **[U]:** Does the fresh generator's `field_sowing_hook` (`terrain_donor_gen.gd:520-545`) satisfy the X22 runtime-trigger contract with no RNG draw, and is the hook actually bound by the composer? Static read says the hook is inert until supplied; runtime binding UNVERIFIED.
5. **[U]:** Are any of the 18 currently-clean patterns violated by files added after this ticket's scan? Re-run §4 and re-read `E19` before sign-off.

---

*End of V33 report. No donor binary was run or copied; no source, shader, config, asset, test, git state or Godot job was touched. NO DONOR PARITY CLAIM.*
