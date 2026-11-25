---
id: CAPTURE-RECHECK-01
title: "Second-agent capture re-check protocol for the 64² piece→combo ladder"
area: coordination / testing (variant3d)
owner: COORD (protocol owner); re-check executed by a SECOND AGENT, never the executing builder
date: 2026-11-25
status: PROTOCOL__READ_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT
scope: "One new file only: docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md. No .gd/.gdshader/config/fixture/result-JSON edit, no Godot submission, no donor access, no ladder advance."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only; no donor GPU A/B frame exists (TEST_MATRIX.md:32-34,73-74; V3D_02 parity_guard). A re-check verifies capture integrity and the atom's stated criteria; it never certifies donor parity."
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:14-27,53-75"
ladder: "P0 -> P1 -> P2 -> P3 -> C1 -> C2 -> C3 -> C4 -> S1 (FINAL is COORD-only and last)"
governing_sources:
  - docs/coord_swarm_2026-11-25/TEST_MATRIX.md
  - docs/coord_swarm_2026-11-25/reports/TEST_RUN_01_ladder_log.md
  - docs/coord_swarm_2026-11-25/reports/TEST_RUN_02_ladder_log.md
  - docs/coord_swarm_2026-11-25/reports/PIXEL_01_p0_capture_review.md
  - docs/coord_swarm_2026-11-25/reports/METRIC_01_dark_rows.md
  - docs/coord_swarm_2026-11-25/reports/P0_GATE_01.md
  - docs/coord_swarm_2026-11-25/VIDEO_QA_PROTOCOL.md
  - docs/coord_swarm_2026-11-24/reports/W55_visual_ab.md
  - docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md
supporting_sources:
  - variant3d/tools/smallmap_capture.py
  - docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md
  - docs/coord_swarm_2026-11-25/reports/S1_INPUT_FIX.md
  - variant3d/tests/t_terrain_only.gd / t_terrain_trees.gd / t_terrain_shore.gd / t_terrain_mines.gd / t_combo_*.gd / t_select_rect.gd
---

# CAPTURE-RECHECK-01 — second-agent capture re-check protocol

## 0. Why this protocol exists, and what "re-check" means

- The matrix requires that the next ladder row be submitted **only after** the previous row's result JSON exists **and** its PNG/stderr were re-checked by a **second agent**; the owner never self-certifies visual review (`TEST_MATRIX.md:58-59`, `:75`; **observed**). Both prior ladder logs explicitly state that no visual PASS was claimed because this role was not performed (`TEST_RUN_02_ladder_log.md:231-233`; `TEST_RUN_01_ladder_log.md:165-167`; **observed**). This document is that missing role, written as an executable protocol.
- **Boundary of the role:** no donor GPU A/B frame exists in the project (`TEST_MATRIX.md:32-34,73-74`; `PIXEL_01_p0_capture_review.md:22,83,106`, `:110`; `METRIC_01_dark_rows.md:321-325`; `FINAL_GATE_PLAN_01.md:208-214`; **observed**). Donor GPU A/B is unavailable. Therefore "re-check" means **verifying capture integrity and the atom's own stated criteria against the captured artifacts** — it does **not** mean donor parity. Every finding stays `PORT APPROX — internal consistency only` (`TEST_RUN_02_ladder_log.md:99`; **observed**).
- **Two independent failure modes must both be respected.** PIXEL-01 judged the P0 frame a `GENUINE_VISUAL_DEFECT` from the pixels (`PIXEL_01:11,73-83`); METRIC-01 judged the specific `full_width_dark_rows` predicate inapplicable to a water-free frame (`METRIC_01:13,228-268`); P0-GATE-01 reconciled them by keeping the observation and replacing the instrument with stricter applicable gates (`P0_GATE_01.md:31-59,74-90`; **observed**). The re-checker must report **what the image shows** and **whether the atom's current assertion set is satisfied** as separate fields; one cannot be used to erase the other.
- **Labels used throughout this document** (`FINAL_GATE_PLAN_01.md:30-35`; **observed**): `observed` = literal doc/code/PNG fact; `derived` = arithmetic or control-flow consequence of observed facts; `inferred` = plausible reading with caveat; `UNVERIFIED` = cannot be proven from the available material (above all donor parity). Every rule below carries a source citation and a label.

---

## 1. What the second agent must open for each row, and the exact commands

### 1.1 Mandatory artifact set (per row)

For **every** submitted row the second agent opens these four artifacts. Row PNG/JSON/stderr conventions are observed from `TEST_RUN_02_ladder_log.md:53,62,87-99,129-131,149-156`, `FINAL_GATE_PLAN_01.md:105-146` and `TEST_MATRIX.md:18-26`:

| Artifact | Path pattern | Source / label |
|---|---|---|
| Captured PNG | `<TEMP>\smallmap64_<row>.png` — e.g. `smallmap64_terrain_only.png`, `smallmap64_terrain_trees.png`, `smallmap64_terrain_shore.png`, `smallmap64_terrain_mines.png`, combo PNGs. Temp root used so far: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\` (row 1 used `...\test01_ladder\`). | `TEST_MATRIX.md:18-25`; `TEST_RUN_01_ladder_log.md:46`; `TEST_RUN_02_ladder_log.md:15,52-54,98`; **observed** |
| Result JSON | `variant3d\tests\results\<atom>.json`, e.g. `t_terrain_only.json`, `t_terrain_trees.json`, `t_terrain_shore.json`, `t_terrain_mines.json`, `t_combo_*.json`, `t_select_rect.json`, written by the atom. | `TEST_RUN_02_ladder_log.md:87-99`; `FINAL_GATE_PLAN_01.md:138`; **observed** |
| Runner stderr | `variant3d\.godot_queue\results\<ticket>_<job-id>\stderr.txt` (and `stdout.txt` for the `RESULT:` line). | `TEST_RUN_01_ladder_log.md:81-82,129-131`; `TEST_RUN_02_ladder_log.md:149-156,223-227`; **observed** |
| Frame sidecar `frames.json` | **Only when motion is claimed/captured.** Per-frame metadata (sim time, pose id, azimuth) sidecar; open it beside the PNG/contact sheet. Motion rows on this ladder: **P2 / C1 / C3 / C4 where a water plane is present** (water animation is an atom assertion: `TEST_MATRIX.md:42`; `t_terrain_shore.gd:651-654`), and any row run under the frame-sequence protocol. | `VIDEO_QA_PROTOCOL.md:11-15,31-37,39-46`; `TEST_MATRIX.md:42`; **observed** |

- **S1 exception (observed):** the S1 atom does **not** assert a PNG; its authoritative re-check surface is the result JSON + stdout (`S1_INPUT_FIX.md:222-224`; `FINAL_GATE_PLAN_01.md:202-205,256-258`). The matrix nevertheless lists "PNG + selection list" for S1 (`TEST_MATRIX.md:26`) and a proven launch can produce `s1inputfix_smallmap64.png` (`FINAL_GATE_PLAN_01.md:131-134`). Rule: open that PNG **if it exists**, but base the selection/overlay verdict on the JSON assertions; record the PNG as `UNVERIFIED` if it is absent — never manufacture a visual claim from a missing file.

**Capture-integrity prerequisites before any criterion is judged (all observed):**
1. The row was launched **windowed** (no `--headless`) with the PNG path passed as a user arg after the second `--`; headless yields `SKIP_CAPTURE` / `passed=false` and is **not** PASS — record FAIL, do not harvest (`TEST_MATRIX.md:62-64`; `TEST_RUN_02_ladder_log.md:49-51`; `FINAL_GATE_PLAN_01.md:123-125`).
2. The PNG exists, is 1280×720, and is non-blank; `capture_image` / `capture_saved` in the JSON must hold (`TEST_MATRIX.md:32`; `smallmap_capture.py:31-38`; `TEST_RUN_02_ladder_log.md:110-137`; `PIXEL_01:19`).
3. `scan-stderr` returns `script_error_lines: 0` — a hard prerequisite for any row verdict (`TEST_RUN_02_ladder_log.md:144-163,163,305-306`; `FINAL_GATE_PLAN_01.md:200-201`). Non-`SCRIPT ERROR` runtime messages are recorded as observations, not silently ignored (`TEST_RUN_02_ladder_log.md:163-186`).
4. The fixed 64² harness, seed 20261113, fixed camera, 1280×720 and ~10-frame capture were reused; no new harness was built (`TEST_MATRIX.md:29-36`; `FINAL_GATE_PLAN_01.md:142-144`). A different harness invalidates cross-row attribution — record as `UNVERIFIED`.

### 1.2 Exact commands (read-only; Windows `python`, not `python3`)

Run from the repo root, one Godot at a time, through the FIFO runner only for captures — **this protocol runs no runner job at all** (`TEST_MATRIX.md:70-72`; **observed**). The two inspection commands are defined at `smallmap_capture.py:7-9,42-58` (**observed**):

```
REM Measure the PNG (reports byte size, width/height, non_black_fraction,
REM mean_rgb, mean_luma, full_width_dark_rows, full_width_dark_row_fraction).
python variant3d\tools\smallmap_capture.py stats "<TEMP>\smallmap64_<row>.png"

REM Scan the runner stderr for SCRIPT ERROR lines (must be 0).
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_<job-id>\stderr.txt
```

Worked examples, copied from the executed P0 rows (observed — `TEST_RUN_02_ladder_log.md:115,149`; `P0_GATE_01.md:152-154,160-162`):

```
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000404_TESTRUN02-P0\stderr.txt
```

- `stats` is a **qualitative inspector only** — it prints `NOTE: qualitative comparison only. No donor parity is claimed.` (`smallmap_capture.py:42-48`; **observed**). Do not treat its numbers as a substitute for opening the image (§3).
- For a motion row, `stats` each captured frame (or the contact-sheet PNG) and open `frames.json` for the per-frame metadata; assemble/use the contact sheet and MP4 per `VIDEO_QA_PROTOCOL.md:34-37` (**observed**). Never infer donor parity from motion smoothness (`VIDEO_QA_PROTOCOL.md:39-46`; **observed**).

---

## 2. Per-row criterion checklist (mirrors each atom's own assertions)

**Legend (fill in `reports/RECHECK_<ROW>.md`):** for each criterion tick **exactly one** of `PASS | FAIL | N/A`. `PASS` = the atom's own assertion is satisfied **and** the image inspection (§3) does not contradict it; `FAIL` = a named assertion is false, capture integrity is broken, or the image shows a defect; `N/A` = the check is recorded-only / deliberately not asserted / not applicable to this row's composition (state the reason in the notes column). Blank rows must be filled — a missing mark is `UNVERIFIED`, not PASS (**derived** from `FINAL_GATE_PLAN_01.md:202-205` and `TEST_MATRIX.md:75`).

**Row verdict = the atom's JSON `verdict` + the second agent's independent image verdict, recorded separately.** A green JSON never overrides what the agent sees in the PNG (`TEST_MATRIX.md:73-74`; `PIXEL_01:73-83`; **observed**).

### P0 — `t_terrain_only.gd` (terrain only: no trees, shore, mines)

Source of check names: `t_terrain_only.gd:67` (`CHECK_NAMES`), `:363-707`; assertion table `TEST_P0_report.md:74-101`. **Use the current atom file, not the authoring report alone**: P0-GATE-01 replaced the hard `full_width_dark_rows==0` with a recorded diagnostic and added two strict luma gates (`P0_GATE_01.md:74-90`; `t_terrain_only.gd:687,704-707`), so the old `TEST_P0_report.md:98` row is superseded (**observed/derived**).

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `harness_stub_shape`, `terrain_module_api`, `camera_module_api`, `build_ok` | ☐ | ☐ | ☐ | `t_terrain_only.gd:429,462,474,489`; `TEST_P0_report.md:78-81` |
| Structural counts: `surface_count==1`, `vertex_count==4096`, `triangle_count==7938`, `uv2_count==4096` | ☐ | ☐ | ☐ | `t_terrain_only.gd:522-526`; `TEST_MATRIX.md:33-34` |
| `uv2_y_face_modes` (histogram recorded; values ∈{0,1,2}) | ☐ | ☐ | ☐ | `t_terrain_only.gd:551`; `TEST_P0_report.md:86` |
| `flat_grid_promoted == 0` | ☐ | ☐ | ☐ | `t_terrain_only.gd:556`; `TEST_MATRIX.md:40` |
| `res_nodes_empty`, `no_water_cells == 0`, `no_water_tileblock == 0` | ☐ | ☐ | ☐ | `t_terrain_only.gd:563,574,582`; `TEST_MATRIX.md:18` |
| `atlas_grid_manifest [16,8]`, `atlas_material_bound` (3 samplers), `shader_shadow_disabled` | ☐ | ☐ | ☐ | `t_terrain_only.gd:607-615`; `TEST_MATRIX.md:34,40` |
| `water_plane_hidden` (water hidden, not deleted) | ☐ | ☐ | ☐ | `t_terrain_only.gd:363`; `TEST_P0_report.md:94` |
| `capture_image`, `capture_saved` | ☐ | ☐ | ☐ | `t_terrain_only.gd:660,668`; §1.1 prerequisites |
| `non_black_fraction > 0.9` | ☐ | ☐ | ☐ | `t_terrain_only.gd:677`; `smallmap_capture.py:26` |
| Luma gates: `ground_mean_luma >= 40`, `ground_max_luma >= 100` | ☐ | ☐ | ☐ | `t_terrain_only.gd:704-707`; `P0_GATE_01.md:81-105` (PORT APPROX) |
| `full_width_dark_rows` = **recorded diagnostic** (`RECORDED_NOT_APPLICABLE`) | ☐ | ☐ | ☐ | Mark N/A for pass/fail; still record value 720 and describe it under §3. `P0_GATE_01.md:74-77,143-145`; `t_terrain_only.gd:687` |
| `SCRIPT ERROR == 0`, windowed, JSON `verdict=PASS` | ☐ | ☐ | ☐ | `TEST_RUN_02_ladder_log.md:163,305-306`; `TEST_MATRIX.md:62-64` |

### P1 — `t_terrain_trees.gd` (P0 + donor trees)

Source: `t_terrain_trees.gd:76-111` (`CHECK_NAMES`), `:858-898`; `TEST_MATRIX.md:19,41`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| Structural baseline: `surface_count`, `vertex_count`, `triangle_count`, `uv2_count`, `uv2_y_face_modes`, `flat_grid_promoted==0`, `build_ok` | ☐ | ☐ | ☐ | `t_terrain_trees.gd:823-842`; `TEST_MATRIX.md:33-40` |
| `no_water_cells==0`, `no_water_tileblock==0`, `water_plane_hidden` | ☐ | ☐ | ☐ | `t_terrain_trees.gd:849,855,487` |
| `tree_nodes_bound == TREE_N`, `tree_instance_count == TREE_N` | ☐ | ☐ | ☐ | `t_terrain_trees.gd:858-867` |
| **Category purity:** `category_purity` (no non-POOL_TREE sids), `no_non_tree_batches` (no unit/building batches) | ☐ | ☐ | ☐ | `t_terrain_trees.gd:868-873` — stone/ore/stump/food/proxy forbidden |
| `tree_height_snap` (tree Y matches `height_at_world()` within epsilon) | ☐ | ☐ | ☐ | `t_terrain_trees.gd:876-881`; `TEST_MATRIX.md:41` |
| `trees_above_water` (0 trees below `WATER_LEVEL`) | ☐ | ☐ | ☐ | `t_terrain_trees.gd:882-883` |
| `draw_calls_recorded`, `frame_time_recorded` | ☐ | ☐ | ☐ | `t_terrain_trees.gd:276-279`; `TEST_MATRIX.md:41` |
| Capture diff: `png_differs_from_p0`, `diff_confined_to_tree_footprints`, `no_new_black_blocks`, `no_full_width_dark_rows` | ☐ | ☐ | ☐ | `t_terrain_trees.gd:684-694`; ground texgen unchanged vs T0 (`TEST_MATRIX.md:41`) |
| `capture_image`, `capture_saved`, `SCRIPT ERROR == 0` | ☐ | ☐ | ☐ | `t_terrain_trees.gd:953-959`; §1.1 |
| `donor_scale_ladder`, `donor_yaw_bins`, `donor_passability`, `donor_visual_review`, `script_error_scan_external` | ☐ | ☐ | ☐ | **Mark N/A** for parity: deliberately `KNOWN_GAP`/`NOT_ASSERTED`/`SECOND_AGENT_REQUIRED`/`EXTERNAL` (`t_terrain_trees.gd:886-898`); §3 still requires describing tree silhouette/density in the PNG |

### P2 — `t_terrain_shore.gd` (P0 + shore/water)

Source: `t_terrain_shore.gd:76-108` (`CHECK_NAMES`, `CAPTURE_CHECK_NAMES`), `:604-654`; `TEST_MATRIX.md:20,42`. **This is where the water-band gate applies** (`METRIC_01:86-89,99-104`; `P0_GATE_01.md:207-208`; **observed**).

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `exactly_one_water_plane` + `height_aware_true` | ☐ | ☐ | ☐ | `t_terrain_shore.gd:755,771`; no stacked planes (`TEST_MATRIX.md:42`) |
| `water_cell_count` (>0 and <10 % of cells) | ☐ | ☐ | ☐ | `t_terrain_shore.gd:780` |
| `mesh_surface_count/vertex_count/triangle_count`, `uv2_count` | ☐ | ☐ | ☐ | `t_terrain_shore.gd:807-812` |
| `shore_ids_in_uv2_histogram`, `no_water_cell_tile0_clamp` | ☐ | ☐ | ☐ | `t_terrain_shore.gd:831,837`; no water pixel showing `grass1` (`METRIC_01:90-94`) |
| **Water-band gate** `png_full_width_dark_rows == 0` | ☐ | ☐ | ☐ | `t_terrain_shore.gd:604-605`; applicable here (`V3D_02 F6/T2`, `METRIC_01:86-89,104`) |
| `sample_coverage`, `water_alpha_confined_to_cells` (land changed 0, water changed >0) | ☐ | ☐ | ☐ | `t_terrain_shore.gd:608,626-630`; land above water not tinted (`TEST_MATRIX.md:42`) |
| **Motion** `water_animation_delta` (two frames 1 s apart) | ☐ | ☐ | ☐ | `t_terrain_shore.gd:632-654`; open both frames + `frames.json` (§1.1); absent delta is `UNVERIFIED`, not a faked PASS (`:649-654`) |
| `donor_literals_exact`, `wave_texture_diffusewaves0`, `foam_not_added_by_test`, `no_trees_no_mines`, `donor_coarse_swell_present`, `no_port_art_shore_prox` | ☐ | ☐ | ☐ | `t_terrain_shore.gd:873-916` |
| `windowed_capture_available`, `capture_image`, `capture_saved`, `SCRIPT ERROR == 0` | ☐ | ☐ | ☐ | `t_terrain_shore.gd:923-931`; §1.1 |

### P3 — `t_terrain_mines.gd` (P0 + mines)

Source: `t_terrain_mines.gd:588-852`; `TEST_MATRIX.md:21,43`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `module_load_and_api`, `build_ok`, `atom_completed` | ☐ | ☐ | ☐ | `t_terrain_mines.gd:646,678,845` |
| `p0_mesh_invariants`, `no_water_cells` | ☐ | ☐ | ☐ | `t_terrain_mines.gd:736,748` — ground unchanged outside mine bbox (`TEST_MATRIX.md:43`) |
| `ore_instance_counts`, `category_purity` (src_wood/stone/food == 0) | ☐ | ☐ | ☐ | `t_terrain_mines.gd:757,769` |
| `mine_sid_resolution` (sid resolves and is unchanged) | ☐ | ☐ | ☐ | `t_terrain_mines.gd:791` |
| `mine_y_matches_terrain`, `env_scale_mine_from_code` | ☐ | ☐ | ☐ | `t_terrain_mines.gd:823,842`; mine Y matches terrain (`TEST_MATRIX.md:43`) |
| `png_capture_windowed` (capture non-blank, nb > 0.9) | ☐ | ☐ | ☐ | `t_terrain_mines.gd:588` |
| `ground_luma_variance_outside_mine_bbox`, `no_z_fighting_seam_visual` | ☐ | ☐ | ☐ | `t_terrain_mines.gd:596-608,850-852` |
| `SCRIPT ERROR == 0` | ☐ | ☐ | ☐ | §1.1 — `TEST_RUN_02_ladder_log.md:163` |

### C1 — `t_combo_trees_shore.gd` (trees + shore; no interaction regressions)

Source: `t_combo_trees_shore.gd:97-126`; `TEST_MATRIX.md:22`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `p0_mesh_counts_unchanged` + structural counts | ☐ | ☐ | ☐ | `t_combo_trees_shore.gd:103-112` |
| `tree_res_nodes_exact`, `tree_category_purity`, `tree_batch_instances_exact`, `tree_y_on_terrain`, `trees_not_below_water` | ☐ | ☐ | ☐ | `t_combo_trees_shore.gd:113-117` |
| `no_mines_added` | ☐ | ☐ | ☐ | `t_combo_trees_shore.gd:118` |
| `water_cells_bounded`, `water_plane_single_height_aware`, `shore_ids_in_uv2_hist` | ☐ | ☐ | ☐ | `t_combo_trees_shore.gd:119-121` |
| `non_black_fraction`, `full_width_dark_rows == 0` | ☐ | ☐ | ☐ | `t_combo_trees_shore.gd:124-125` — water-bearing row: gate applicable |
| `capture_image`, `capture_saved`, `SCRIPT ERROR == 0` | ☐ | ☐ | ☐ | `t_combo_trees_shore.gd:122-123`; §1.1 |

### C2 — `t_combo_trees_mines.gd` (trees + mines; no overlap/placement bugs)

Source: `t_combo_trees_mines.gd:74-107`; `TEST_MATRIX.md:23`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `uv2_x_ground_only`, structural counts, `flat_grid_promoted`, `atlas_grid_manifest`, `shader_shadow_disabled` | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:81-89` |
| `no_water_cells`, `no_water_tileblock`, `no_water_plane_present` | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:90-92` |
| `tree_node_count`, `tree_instance_count`, `ore_node_counts`, `ore_instance_counts` | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:93,97-98` |
| **Category purity** `category_purity`, `harness_category_crosscheck`, `non_tree_ore_instance_purity`, `entity_stats_total` | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:95-100` |
| `y_matches_terrain`, `tree_ore_separation` (no overlap) | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:101-102`; `TEST_MATRIX.md:23` |
| `non_black_fraction`, `full_width_dark_rows` | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:105-106`. **Caveat:** water-free row hard-asserts `==0`; if it fails for inapplicability, open a separate evidence-backed ticket — do not relax it here (`FINAL_GATE_PLAN_01.md:242-248`; **inferred**) |
| `capture_image`, `capture_saved`, `SCRIPT ERROR == 0` | ☐ | ☐ | ☐ | `t_combo_trees_mines.gd:103-104`; §1.1 |

### C3 — `t_combo_shore_mines.gd` (shore + mines; mines not in water)

Source: `t_combo_shore_mines.gd:107-130`; `TEST_MATRIX.md:24`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `p0_mesh_counts_unchanged`, `water_cells_bounded`, `single_height_aware_water_plane`, `shore_ids_present` | ☐ | ☐ | ☐ | `t_combo_shore_mines.gd:113-116` |
| `ore_height_above_water` (mines not in water), `ore_counts_exact`, `ore_category_purity` | ☐ | ☐ | ☐ | `t_combo_shore_mines.gd:117-119`; `TEST_MATRIX.md:24` |
| `non_black_fraction`, `full_width_dark_rows == 0` | ☐ | ☐ | ☐ | `t_combo_shore_mines.gd:122-123` — water-bearing: applicable |
| `capture_image`, `capture_saved`, `SCRIPT ERROR == 0` | ☐ | ☐ | ☐ | `t_combo_shore_mines.gd:120-121`; §1.1 |

### C4 — `t_combo_all.gd` (all layers; toggleable; no stacked water)

Source: `t_combo_all.gd:554-1019`; `TEST_MATRIX.md:25,44`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `single_terrain_mesh`, `mesh_single_surface`, `mesh_vertex_count`, `mesh_triangle_count`, `mesh_uv2_count`, `uv2_x_in_atlas`, `uv2_y_face_modes`, `face_hist_sum`, `tile_index_cells`, `flat_face_zero` | ☐ | ☐ | ☐ | `t_combo_all.gd:628-712` |
| `atlas_grid_manifest`, `atlas_samplers_bound`, `shader_shadow_disabled`, `sun_shadow_off`, `terrain_cast_shadow_off`, `single_environment_rig` | ☐ | ☐ | ☐ | `t_combo_all.gd:740-755,940` |
| `height_at_world_samples`, `water_cells_bounded`, `shore_ids_in_hist`, `water_module_height_aware`, `single_water_plane` | ☐ | ☐ | ☐ | `t_combo_all.gd:770-804`; no stacked planes |
| `no_units_or_buildings`, `tree_instances`, `mine_instances`, `category_purity`, `mine_sid_resolves`, `resource_y_matches_terrain`, `resources_above_water`, `mine_tree_separation`, `no_cmd_calls` | ☐ | ☐ | ☐ | `t_combo_all.gd:816-932` |
| `png_captured`, `nonblack_over_090`, `full_width_dark_rows_zero`, `no_full_height_dark_cols`, `mean_luma_recorded`, `draw_calls_recorded`, `no_new_seam_class`, `png_saved` | ☐ | ☐ | ☐ | `t_combo_all.gd:974-1019`; `TEST_MATRIX.md:44` |
| `SCRIPT ERROR == 0`, windowed | ☐ | ☐ | ☐ | §1.1 |

### S1 — `t_select_rect.gd` (selection rectangle / overlay; real 64² boot)

Source: `t_select_rect.gd:353-602`; `TEST_MATRIX.md:26,64`; `FINAL_GATE_PLAN_01.md:115,256-258`.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `boot_real_64_3d_game`, `hud_visible` | ☐ | ☐ | ☐ | `t_select_rect.gd:353,361`; HUD re-shown by atom (`TEST_MATRIX.md:64`) |
| `test_entities_exact == [10,11,12,13]`, `cmd_spy_installed`, `picking3d_bound` | ☐ | ☐ | ☐ | `t_select_rect.gd:401-425` |
| `projected_pixels_in_viewport`, `unproject_matches_world_to_px`, `ground_endpoints_finite` | ☐ | ☐ | ☐ | `t_select_rect.gd:440-454` |
| `drag_crosses_port_6px_threshold`, `drag_crosses_donor_0.005m_epsilon` | ☐ | ☐ | ☐ | `t_select_rect.gd:450,465` |
| **Overlay:** `_assert_overlay` labels (node found, has API, visible and rect ≈ expected during drag; hidden/empty after) | ☐ | ☐ | ☐ | `t_select_rect.gd:524-539`; `expected_pre_fix_failure` markers retained, never flipped for green (`S1_INPUT_FIX.md:217-219`) |
| **Selection:** `selected_ids_exact == [10,11]`, `unit10_selected`, `unit11_selected`, `unit12_not_selected`, `building_not_selected`, `building_inside_rect_but_excluded_by_kind` | ☐ | ☐ | ☐ | `t_select_rect.gd:553-564` |
| `cmd_counter_zero_after_drag`, `short_click_selects_single_unit == [10]`, `cmd_counter_zero_after_click` | ☐ | ☐ | ☐ | `t_select_rect.gd:564,569,571`; no click-pick regression (`TEST_MATRIX.md:26`) |
| Real-event path: `drag_start_from_real_event`, `world_sel_active_during_drag` | ☐ | ☐ | ☐ | `t_select_rect.gd:591,602` |
| `SCRIPT ERROR == 0`, windowed (headless = `SKIP_CAPTURE`, not PASS) | ☐ | ☐ | ☐ | `S1_INPUT_FIX.md:230-238`; `TEST_MATRIX.md:63` |
| PNG of overlay/selection | ☐ | ☐ | ☐ | Open `s1inputfix_smallmap64.png` **if produced**; if absent mark N/A/UNVERIFIED and use JSON/stdout as the surface (`S1_INPUT_FIX.md:222-224`; `FINAL_GATE_PLAN_01.md:256-258`) |

---

## 3. Rules for image inspection (the visual half of the re-check)

These rules govern every row with a PNG and every frame-sequence row.

1. **Open the PNG itself** — do not judge from `stats` alone. PIXEL-01's independent read found region-level features (faint diagonal strokes at ≈x 200–720/y 200–480, a curved band lower-left, a smeared patch lower-middle) that the four summary numbers do not describe (`PIXEL_01:19,24-38,54-56`; **observed**). The atom's structural PASS values "are not themselves visual evidence" (`PIXEL_01:59-64`; **observed**).
2. **Describe regions in words** before any verdict: frame fill and corners; sky/horizon/ground boundary; tiles/checkerboard/seams/banding; recognisable structures (trees, mines, units, water, shoreline); tonal range and colour signature (`PIXEL_01:24-38`; **observed**). For motion rows, report per-frame observations with frame numbers/timestamps from `frames.json` (`VIDEO_QA_PROTOCOL.md:39-46`; **observed**).
3. **Keep claims separated** into `observed` (what the pixels show), `derived` (arithmetic consequences), `inferred` (possible causes — explicitly caveated), and `UNVERIFIED` (donor parity, causal attribution) (`PIXEL_01:50-71`; `METRIC_01:228-268`; `FINAL_GATE_PLAN_01.md:30-35`; **observed**). A missing structure in frame is an observation; *why* it is missing is an inference.
4. **Never infer donor parity.** No donor GPU A/B frame exists (`TEST_MATRIX.md:32-34,73-74`; `PIXEL_01:22,83,106`; `METRIC_01:321-325`; `FINAL_GATE_PLAN_01.md:208-214`; **observed**). A visually smooth motion sequence does not prove donor AABB/ACL fidelity (`VIDEO_QA_PROTOCOL.md:42-46`; **observed**). W55 is the precedent: zoom was closed visually with measured pixel change, but the selection aura stayed **UNVERIFIED** because the selected building was off-screen — a capture that never showed the target is not a PASS (`W55_visual_ab.md:21-27,124-138,168-170`; **observed**).
5. **Never override visual judgement with metrics alone.** `stats` reports only luma/non-black/dark-row counts (`smallmap_capture.py:21-39`) and prints "qualitative comparison only" (`smallmap_capture.py:47`; **observed**). Metrics never override donor visual comparison (`TEST_MATRIX.md:73-74`; **observed**); if the PNG shows a defect, record it even when the JSON is green, and if a metric fails on a composition where its predicate is inapplicable (P0 water-band case), record both the metric value and the visual reading instead of discarding either (`PIXEL_01:73-83`; `METRIC_01:99-104,228-268`; `P0_GATE_01.md:31-59`; **observed**).
6. **Do not change the instrument during a re-check.** No threshold lowering, no assertion deletion, no rerun hoping for green (`TEST_MATRIX.md:60-68`; `P0_GATE_01.md:176-186`; **observed**). If a predicate is genuinely inapplicable, that is a separate evidence-backed ticket using the P0_GATE-01 precedent (equally strict replacement + old value kept recorded) (`FINAL_GATE_PLAN_01.md:189-198`; **observed**).
7. **Read-only.** The re-check writes only its own `RECHECK_<ROW>.md`; it edits no PNG, JSON, stderr, atom, shader, fixture or config (`TEST_RUN_02_ladder_log.md:7,55-56`; `PIXEL_01:7`; **observed**). Keep raw frames/contact sheet until the verdict is recorded (`VIDEO_QA_PROTOCOL.md:37`; **observed**).

---

## 4. Where to record, and who may advance the ladder

- **Record location and naming:** one new report per checked row at
  `docs/coord_swarm_2026-11-25/reports/RECHECK_<ROW>.md`, where `<ROW>` is exactly `P0`, `P1`, `P2`, `P3`, `C1`, `C2`, `C3`, `C4`, `S1` (e.g. `reports/RECHECK_P0.md`, `reports/RECHECK_S1.md`). Naming follows the sibling report convention (`reports/TEST_P0_report.md`, `reports/PIXEL_01_p0_capture_review.md`, `reports/METRIC_01_dark_rows.md`, `reports/FINAL_GATE_PLAN_01.md`) and the task's explicit `RECHECK_<ROW>.md` rule (**observed** from the report directory; **derived** from the task naming).
- **Required contents of each `RECHECK_<ROW>.md`:** frontmatter (id `RECHECK-<ROW>`, owner = second agent, date, `labels`, `parity_guard`), the four opened artifact paths and the two command outputs verbatim (§1.2), the filled §2 checklist with one of PASS/FAIL/N/A per criterion, the region description (§3), a separate "atom JSON verdict" field and "second-agent image verdict" field, explicit `PORT APPROX` / donor parity `UNVERIFIED` statement, and any exact failed assertion detail (**derived** from `TEST_RUN_02_ladder_log.md:87-108,202-229`; `PIXEL_01:50-83`).
- **Who advances the ladder: COORD only.** The second agent *records findings*; it does not submit the next row, rerun a failing row, or declare a row PASS. The executing builder never self-certifies visual review (`TEST_MATRIX.md:4,58-59,75`; `FINAL_GATE_PLAN_01.md:98-103,202-207`; **observed**). After reading `RECHECK_<ROW>.md`, COORD alone decides to authorise the next row in the strict order `P0 → P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1 → FINAL`, one ticket per row (`TEST_MATRIX.md:57`; **observed**).
- **FINAL is never advanced by a re-check.** FINAL is reserved for COORD, runs last, and requires fresh selftest 29/29 + uitest 17/17 + `assert_clean.py --json` CLEAN/exit 0 + `pending = 0`; a green ladder row is not a final-gate certificate (`TEST_MATRIX.md:27,65-66`; `FINAL_GATE_PLAN_01.md:148-178,206-207`; **observed**).

---

## 5. Failure attribution policy

1. **Stop at the first failing row.** The failing row is evidence, not a nuisance: record the exact failed assertion and route it to the owning fix ticket; do not submit the next row and do not rerun hoping for green (`TEST_MATRIX.md:60-61`; `TEST_RUN_01_ladder_log.md:71-75`; `TEST_RUN_02_ladder_log.md:195-200,249`; `FINAL_GATE_PLAN_01.md:180-188`; **observed**). A rerun is permitted only after the owning builder lands an actual fix and COORD re-opens the row (`FINAL_GATE_PLAN_01.md:186-188`; **observed**).
2. **Attribute by owning file, not by symptom** (`FINAL_GATE_PLAN_01.md:191-198`; **observed**):
   - Capture never loaded / four GDScript parse errors at `GDScript::reload` → atom load ticket, not a visual defect (`TEST_RUN_01_ladder_log.md:77-95,123-131,181-182`). Missing PNG/JSON is a load failure, not a "dark image".
   - `SCRIPT ERROR != 0` → the script/stderr owner, before any visual verdict (`TEST_RUN_02_ladder_log.md:163`).
   - Structural count mismatch (verts/tris/UV2/atlas/shadow) → terrain mesh/module owner (`TEST_MATRIX.md:33-40`; `TEST_P0_report.md:82-94`).
   - Category-purity or instance-count mismatch → the entity/resource owner (`t_terrain_trees.gd:868-873`; `t_terrain_mines.gd:769`; `t_combo_trees_mines.gd:95-100`).
   - Luma/visual defect → the terrain render/lighting owner: P0's darkness was attributed to the terrain shader's donor-sun conversion, not to camera framing, atlas or mask (`FINAL_GATE_PLAN_01.md:195-198`; `TERRAIN_DARK_01.md:182-197,130-143` as cited there; **observed**). The camera bind-time `!is_inside_tree()` errors and ObjectDB leak are separate UNVERIFIED harness concerns, **not** the failing check (`TEST_RUN_02_ladder_log.md:172-183,278-287`; `METRIC_01:154-164`; **observed**).
   - Water-band / `water_animation_delta` failure on a water-bearing row → shore/water owner; on a water-free row, open a **separate** ticket for predicate applicability (P1/C2/C3/C4 hard-assert `full_width_dark_rows==0`), never silently relax it (`FINAL_GATE_PLAN_01.md:242-248`; **inferred**).
   - S1 selection/overlay failure → input/selection owner; the two retained `expected_pre_fix_failure` markers stay until their fix lands (`S1_INPUT_FIX.md:217-219`; **observed**).
3. **No weakening, no green-washing.** `expected_pre_fix_failure` fields stay until the fix lands; no threshold is lowered and no assertion deleted (`TEST_MATRIX.md:67-68`; `P0_GATE_01.md:176-186`). An inapplicable predicate is replaced by an equally strict applicable one with the old value kept recorded — the P0_GATE-01 precedent — in an evidence-backed ticket, not inside the failing atom by the re-checker (`FINAL_GATE_PLAN_01.md:189-198`; **observed**).
4. **UNVERIFIED stays UNVERIFIED.** Absence of a donor frame, an off-screen subject, a headless run, or a missing PNG is never converted into PASS (`W55_visual_ab.md:21-27,134-138`; `TEST_MATRIX.md:62-64`; `S1_INPUT_FIX.md:222-224`; **observed**). A metric value is reported, not used to manufacture a verdict where its predicate does not apply (`METRIC_01:99-104,264-267`; **observed**).
5. **No donor-parity claim from a re-check.** Every finding is `PORT APPROX — internal consistency only`; donor GPU A/B remains a separate blocked capability (`TEST_MATRIX.md:73-74`; `FINAL_GATE_PLAN_01.md:208-214`; `PIXEL_01:83`; **observed**).

---

## 6. Summary

- This document operationalises the matrix's missing second-agent role: open the row's PNG, result JSON, stderr.txt and `frames.json` (motion only); run `smallmap_capture.py stats <png>` and `scan-stderr <stderr.txt>`; require a windowed capture and `SCRIPT ERROR == 0` (`TEST_MATRIX.md:58-59,62-64,75`; `smallmap_capture.py:7-9,42-58`; **observed**).
- The §2 checklist mirrors each atom's **current** assertions — structural counts, category purity, luma gates, the water-band gate only where water is present, tree-height/placement checks, and S1 overlay/selection — with a PASS/FAIL/N/A field per row; the P0 dark-row check is recorded N/A under the P0_GATE-01 instrument (`t_terrain_only.gd:687,704-707`; `t_terrain_trees.gd:76-111`; `t_terrain_shore.gd:76-108`; `t_combo_*.gd`; `t_select_rect.gd:524-602`; `P0_GATE_01.md:74-90`; **observed**).
- Image inspection is mandatory and independent: open the PNG, describe regions, keep `observed/derived/inferred/UNVERIFIED` separate, never infer donor parity, never let metrics override the visual reading (`PIXEL_01:24-83`; `METRIC_01:228-268`; `TEST_MATRIX.md:73-74`; **observed**). W55 shows the cost of skipping it — a claimed feature stayed UNVERIFIED because the target was never on screen (`W55_visual_ab.md:21-27,134-138`; **observed**).
- Findings go to `reports/RECHECK_<ROW>.md`; **COORD alone** advances the ladder after reading them, and FINAL stays COORD-only and last (`TEST_MATRIX.md:57-59,75`; `FINAL_GATE_PLAN_01.md:98-103,148-178,202-207`; **observed/derived**).
- Failures stop the ladder, are attributed to the owning file, and are never rerun or weakened to force green; donor parity stays UNVERIFIED throughout (`TEST_MATRIX.md:60-68,73-74`; `FINAL_GATE_PLAN_01.md:180-214`; **observed**).

---

*End of CAPTURE-RECHECK-01. Protocol only: no Godot job, no code/fixture/result edit, no donor access, no row called PASS, no ladder advance by this worker.*
