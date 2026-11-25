---
id: TEST-C4
title: "C4 — author t_combo_all.gd (last combination row: terrain + trees + shore + mines)"
owner: TEST-C4
date: 2026-11-25
status: AUTHORED__DESIGN_ONLY__NO_GODOT_RUN__NO_RUNNER_TICKET__NO_PASS_CLAIM
scope: "Two files only: variant3d/tests/t_combo_all.gd (new) and this report. No Godot launch, no runner job, no manifest/config/shared-code/gate-file/git edit, no donor access."
owns:
  - "variant3d/tests/t_combo_all.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_C4_report.md"
labels: [COMBO_LADDER, LAST_COMBO, STUB_HARNESS, WINDOWED_CAPTURE, NO_DONOR_PARITY]
evidence_labels: [observed, derived, inferred]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:25,44"
---

# TEST-C4 — `t_combo_all.gd` authoring report

## Goal

Author the **last combination row** (C4 / T4) of the smallest-map piece→combo
ladder: one 64×64 **stub** scene that holds P0 terrain, P1 trees, P2 shore and
P3 mines at once, asserts **all** parent invariants simultaneously plus the
combo-only guards (no stacked water planes, no new seam class, non-black > 0.9,
mean luma recorded), and produces one windowed PNG. The run itself is **not**
performed here; this is authoring only. No PASS is claimed.

Position in the ladder: `P0→P1→P2→P3→C1→C2→C3→C4→S1→FINAL`, one runner
ticket at a time, stopping at the first failing row
(`TEST_01_smallmap_harness.md:223-226`). C4 is the **only** combo row allowed to
feed the final visual review, and even then only after a second-agent capture
re-check (`TEST_MATRIX.md:25,44,58`).

## Sources

| Source | Used for |
|---|---|
| `variant3d/tests/fixtures/_smallmap_harness.gd:5,11-103,118-128` | Parallel-owner helper: `RefCounted`, static `make_stub_game(w,h,height,res_nodes,tileblock)` returning a Node stub with `height_at`, `cmd_*` counters, `dump` |
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:183-226` | Stub-row capture rule, ladder table C4 row (`:219`), ordering/stop rule (`:223-226`) |
| same, `:228-239` | proposed shared helper `fixtures/_smallmap_harness.gd` + embedded-copy alternative |
| same, `:269-305` | blockers: no category flag, windowed-only 3D capture, queue serialisation, dynamic `load()` cache rule |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,25,29-46,53-58` | same-map rule, C4/T4 row, 64² reuse, per-row rules, "no piece PASS until second agent re-checks" |
| `…/reports/V3D_02_terrain_render_audit.md:134-153` | T0–T4 exact assertion list; stderr scan; 128² READY_NOT_RUN |
| same, frontmatter `:14` (parity_guard) and `:80-100` (P1–P15 problem table) | no donor A/B exists; expected pre-fix symptom attribution |
| `variant3d/tests/_template_test.gd:1-38`, `variant3d/tests/README.md:3-33,67-80` | result JSON shape, one-feature-per-file, deferred `quit` (never from `_initialize()`) |
| `variant3d/tests/t_terrain3d.gd:12-16,41-46,106-127,161-253` | dynamic `load()`, `StubGame extends C3Game`, geometry/UV2/face checks |
| `variant3d/tests/t_pick3d.gd:53-146,181-239` | stub game with `cmd_*` counters; no-side-effects assertion |
| `variant3d/tests/t_smallmap_terrain.gd:147-171,252-414` | flat-grid face regression, 21 structural 64² checks |
| `variant3d/tests/t_forest_bake_render.gd:35-41` | `DisplayServer.get_name() == "headless"` guard before any GPU readback |
| `variant3d/scripts/terrain3d_sandbox.gd:139-151`, `variant3d/scripts/testbridge.gd:277-308` (cited via TEST_01) | windowed `frame_post_draw` + `get_texture().get_image()` + `save_png()` |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` | authoritative PNG metrics (non-black `>8`, dark row `luma<20` on `>90%` of row) and `scan-stderr` |
| `variant3d/scripts/world3d_terrain.gd:93-95,408-488,528-545,624-874,879-903` | `TILE_M`, `WATER_LEVEL`, dump/tile-index path, water module, mesh/atlas/stats, `height_at_world` |
| `variant3d/scripts/world3d_entities.gd:113,1060-1079,1269-1316,1530-1551` | `ENV_SCALE`, SIM→world conversion, `_resource_sid`, `add_resource`, batch stats |
| `variant3d/scripts/game.gd:52-53,61,1893-1907,2152-4239` | `BLK_WATER=255`, `tileblock`, `res_nodes`, bilinear `height_at`, exact `cmd_*` signatures |
| `variant3d/scripts/data.gd:23,113-115` | `TILE_M`, window size default 1280×720 |
| `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:23-29,41-45` | atlas grid `(16,8)`, `named_cells=124`, index dictionary path |
| `variant3d/assets/terrain/structs/presets_summer.json:1-125` (sandrock `:89-94`, sandsea `:95-100`) | tile ids resolved **by name**, never invented |
| `variant3d/tests/fixtures/small_map_64.json:10-15` | 64² map size / seed 20261113 (C4 uses the same ladder map, stub-built rather than game-booted) |
| `docs/COMMANDS.md:11-41,123-124` | FIFO runner, hard timeout, no mid-run resize |

## Implementation (what was authored)

`variant3d/tests/t_combo_all.gd` is a **new** `extends SceneTree` atom.

1. **Dynamic harness load with embedded fallback.** It attempts
   `load("res://tests/fixtures/_smallmap_harness.gd")` and calls
   `make_stub_game(w, h, height, res_nodes, tileblock)`
   (`TEST_01_smallmap_harness.md:230-239`). When this atom was designed the
   helper was absent; a **parallel owner landed it during authoring** as
   `extends RefCounted` with a **static** factory returning a Node stub that
   already provides `height_at`, `cmd_*` counters and the `dump` shape
   (`_smallmap_harness.gd:5,11-103,118-128`). The atom therefore calls the
   factory on the Script object first (same pattern as
   `t_terrain_only.gd:271-286`), tolerates an instance-method shape, and keeps
   an embedded `StubGame extends C3Game` builder for the absent/incompatible
   case. The chosen path is recorded in `"harness.mode"` and in a
   `T_COMBO_ALL NOTE:` line. No shared helper file was created or edited by
   this worker.
2. **64² stub construction.** One deterministic height grid (4,096 cells,
   `TILE_M=2.0`, no RNG), a bounded water disc at tile `(16,44)`, `r=7` tiles
   (~3.8% of the grid, inside the P2 `<10%` bound), a sand/rock collar out to
   `r=9`, `BLK_WATER=255` for water cells, and grass elsewhere. Shore tile ids
   are **resolved at runtime by name** from `presets_summer.json`
   (`sandsea1`, `sandrock1`); if the file or name is missing, the atom records
   `manifest_ok=false` and the corresponding assertion fails loudly instead of
   substituting a guessed id.
3. **Layer union, no units/buildings.** 20 `wood` nodes, 3 each of
   `gold`/`iron`/`coal` (9 mines), all with unique ids, `kind="res"`,
   `max_hits=0`. Fed to `world3d_entities.add_resource()` exactly as the P1/P3
   rows specify (`TEST_01_smallmap_harness.md:213-215`), followed by one
   `sync(0.0)`. The embedded stub overrides all 24 `cmd_*` methods with
   matching signatures (`game.gd:2152-4239`) and counts calls.
4. **Independently toggleable layers via user args.** `--no-trees`,
   `--no-shore`, `--no-mines` control stub construction; `--png`, `--frames`,
   `--width`, `--height` control capture. Toggles are recorded in the result
   JSON. If a runner cannot pass user args, the same effect is obtained by
   editing `_with_trees` / `_with_shore` / `_with_mines` and the spot tables in
   the atom (documented in its header). `--no-shore` flattens the basin and
   drops shore tile ids but **cannot** remove the water plane: the terrain
   module always builds it (`world3d_terrain.gd:760-765`); this is stated rather
   than hidden.
5. **Windowed capture with headless guard.** Before any GPU work,
   `DisplayServer.get_name() == "headless"` writes a `SKIPPED_HEADLESS`
   result (`passed:false`, exit 0 — deliberately *not* a PASS) and returns.
   Otherwise the atom reparents stub/terrain/entities/camera into a
   `SubViewport`, waits `N` (default 10) `RenderingServer.frame_post_draw`
   ticks, samples draw calls, reads `get_texture().get_image()`, records
   in-atom non-black / mean luma / dark-row / dark-column metrics, and saves the
   PNG to `--png` (default `user://t_combo_all.png`). It prints the
   `STDERR_SCAN_REQUIRED` marker because GDScript cannot read its own stderr
   (`TEST_01` fact 5, `smallmap_capture.py:50-58`).
6. **Result JSON + deferred quit.** `res://tests/results/t_combo_all.json`
   holds `id`, `passed`, `status`, per-check `{name,passed,detail}`, `measured`
   counts/metrics, harness mode, toggle state, ladder position and the
   UNVERIFIED parity note. The only exit is `call_deferred("quit", …)` from
   `_finish()` — never a bare `quit()` in `_initialize()`
   (`README.md:3-33`, `_template_test.gd:38`).

## Assertions (all in the single C4 run)

Every check name below exists verbatim in the atom. Citations give the
requirement source, not a claimed measurement — **nothing here has been run**.

| Check (layer) | What it asserts | Source |
|---|---|---|
| `atlas_manifest_read`, `atlas_grid_manifest`, `atlas_samplers_bound`, `shader_shadow_disabled`, `sun_shadow_off`, `terrain_cast_shadow_off` (P0) | manifest grid/shader param agree; 3 samplers bound; `shadow_enabled=0`; DonorSun shadow off; terrain cast shadow off | V3D_02 T0 `:144`; `t_smallmap_terrain.gd:353-398`; `world3d_terrain.gd:731-756` |
| `single_terrain_mesh`, `mesh_single_surface`, `mesh_vertex_count`, `mesh_triangle_count`, `mesh_uv2_count` (P0) | exactly one full-grid `MeshInstance3D`; 1 surface; 4,096 verts / 7,938 tris / 4,096 UV2 at 64² | TEST_01 P0 `:212`; `t_terrain3d.gd:21-23,224-226`; `world3d_terrain.gd:664-729` |
| `uv2_x_in_atlas`, `uv2_y_face_modes`, `face_hist_sum`, `tile_index_cells`, `flat_face_zero` (P0) | UV2.x ∈ `[0,named_cells-1]`; UV2.y ∈ {0,1,2}; face histogram sums to grid; tile-index cells == grid; flat fixture → 0 promoted faces | `t_smallmap_terrain.gd:292-339,147-171`; V3D_02 F5 `:128` |
| `height_at_world_samples` (P0) | module height sampling matches the stub grid at 3 cell centres | `world3d_terrain.gd:887-903`; `t_terrain3d.gd:235-253` |
| `tree_instances`, `resource_y_matches_terrain`, `category_purity` (P1) | 20 tree instances; every resource transform Y equals terrain height; no stone/food/stump or unexpected sid | TEST_01 P1 `:213`; V3D_02 T1 `:145`; `world3d_entities.gd:1269-1316,1060-1079` |
| `water_cells_bounded`, `shore_ids_in_hist`, `water_module_height_aware`, `single_water_plane` (P2) | 0 < water cells < 10% of grid; `sandsea*`/`sandrock*` ids present in UV2.x histogram; **one** height-aware `Water3D`/`WaterPlane`; donor literals recorded, not asserted against a donor frame | TEST_01 P2 `:214`; V3D_02 T2 `:146`; `world3d_terrain.gd:528-545,760-765`; `water3d.gd:248-264` (via V3D_02 `:76`) |
| `mine_instances`, `mine_sid_resolves`, `resources_above_water`, `mine_tree_separation` (P3) | 9 mine instances; `_resource_sid` → `mine_<ty>`; every resource cell above water level; positive tree↔mine separation (stub geometry, not a donor constant) | TEST_01 P3 `:215`; V3D_02 T3 `:147`; `world3d_entities.gd:1269-1277`; C2 row `:217` |
| `no_units_or_buildings`, `no_cmd_calls` (C4 scope) | `stats.units == stats.buildings == 0`; zero instrumented `cmd_*` calls | C4 row `:219` ("still no units/buildings"); `t_pick3d.gd:234-236` |
| `single_environment_rig`, `no_new_seam_class` (T4-only) | one `WorldEnvironment` + one `DirectionalLight3D`; no duplicate terrain/water rig; zero full-width dark **rows** and zero full-height dark **columns**; non-black > 0.9 | V3D_02 T4 `:148`; T0 `:144`; `smallmap_capture.py:26-28` |
| `png_captured`, `png_saved`, `nonblack_over_090`, `full_width_dark_rows_zero`, `no_full_height_dark_cols`, `mean_luma_recorded`, `draw_calls_recorded` (T4-only) | real SubViewport PNG written; sampled non-black fraction, mean luma (0..1 **and** 0..255), dark rows/cols and mean draw calls all recorded in JSON | V3D_02 T4 `:148`; `smallmap_capture.py:21-39`; `terrain3d_sandbox.gd:130,139-151` |

Notes on assertion scope, kept explicit to avoid overclaiming:

- P0's isolated "`res_nodes=0`" condition (`TEST_01:212`) is a property of the
  **P0 row**, not of C4. C4 instead asserts the stronger combo form: the P0 mesh
  counts/atlas/shadow invariants are unchanged **while** trees/shore/mines are
  present.
- "No new seam class" is operationalised structurally (single mesh, single
  water plane, single rig) and by zero dark row/column bands. It is **not** a
  donor-pixel comparison; the mandatory second-agent visual re-check still
  applies (`TEST_MATRIX.md:58`).
- In-atom image metrics sample every 4th pixel and are recorded for cross-check
  only; `python variant3d\tools\smallmap_capture.py stats <png>` remains
  authoritative (`smallmap_capture.py:21-39`).

## Expected pre-fix failures (predictions, not observations)

All items below are **derived/inferred** from cited sources; none was observed
in this authoring pass because no job was run.

1. **Dark water bands.** If the current height-aware water shading still tints
   low land (`V3D_02` P6 `:91`), the C4 PNG may show dark rows →
   `full_width_dark_rows_zero` and `no_new_seam_class` fail. Fix F6 (`:129`) is
   the owner of that change; C4 is the row that would expose it.
2. **Luma/blend.** If `mask_to_alpha` remains as measured (P7 `:92`), mean luma
   is recorded but may be lower than a future port-tuned value; C4 deliberately
   makes **no** donor-luma claim (labels `UNVERIFIED`).
3. **Atlas/face regression.** Reintroducing a non-flat face promotion or
   breaking a sampler/atlas-grid binding fails `flat_face_zero` /
   `atlas_grid_manifest` / `atlas_samplers_bound` (`FIX-TERRAIN §8`, V3D_02 F5
   `:128`, T0 `:144`).
4. **Water stacking.** Any second plane (e.g. both `Water3D` and the constant
   fallback) fails `single_water_plane`; the module is supposed to build exactly
   one (`world3d_terrain.gd:760-765`).
5. **Shore id plumbing.** If the donor-derived `presets_summer.json` is absent
   or renamed, `sandsea1`/`sandrock1` cannot resolve and `shore_ids_in_hist`
   fails; the atom does **not** substitute an invented id.
6. **Entity feed changes.** A sid-resolution or batching change fails
   `tree_instances` / `mine_instances` / `category_purity` /
   `resource_y_matches_terrain`.
7. **Operational failures.** Launching with `--headless` yields
   `SKIPPED_HEADLESS` with no PNG; any `SCRIPT ERROR` in the runner stderr fails
   the external `scan-stderr` check (`V3D_02:151-153`, `smallmap_capture.py:50-58`).
   If the landed helper's factory ever changes signature or returns a stub that
   fails the shape check, the atom is expected to fall back to its embedded
   stub and record that — not to skip silently.

## Open questions

1. Will the parallel-owner's `_smallmap_harness.gd` keep its current static
   `make_stub_game` signature (`_smallmap_harness.gd:118`)? The atom prefers it
   and falls back to its embedded stub if that contract changes
   (`TEST_01:228-239`).
2. Will the fixed stub camera (position `(0,95,105)`, `fov=50`) actually frame
   the basin, trees and mines well enough for `non_black > 0.9` in a windowed
   run? This is a **visual** question; only a real capture can answer it.
3. Do the in-atom sampled metrics agree with `smallmap_capture.py stats` at
   full resolution? If not, the external tool wins and the atom's stride may
   need tuning.
4. Is a real-boot 64² cross-check at C4 wanted (TEST_01 open question #1:
   stub isolation vs donor tileblock), or does the stub row suffice before S1?
5. Should a module-level `--no-shore` switch be added so the water plane itself
   can be removed, or is flattening the basin sufficient for the ladder?
6. Who performs the mandatory second-agent re-check, and where do 64² donor
   reference frames come from (none exist per `TEST_MATRIX.md:32-34,56-57`)?
7. Is the 128² rung (`READY_NOT_RUN`, `V3D_02:152`) to be added after 64² is
   green?
8. Should C4's `min_mine_tree_distance_m` become a stricter threshold once the
   donor clear-ring rule is recovered, instead of the current ">0" guard?

## No-runner declaration

- **No Godot process was launched; no runner ticket was created; no queue slot
  was taken.** This file was authored by reading source only.
- **No shared file was edited**: only the two files listed in `owns:` above.
  No `manifest.json`, `config.gd`, generator, shader, `test_all.py`, gate file
  or git state was touched.
- **No donor binary or donor asset was executed, copied or decoded.** The
  donor-derived `presets_summer.json` / atlas manifest in this repo are read at
  *runtime by the atom*, not by this authoring pass.
- **No result is claimed.** There is no measured PASS/FAIL, no PNG and no
  `t_combo_all.json` produced here. Any future verdict must come from the
  serialized windowed runner job plus `smallmap_capture.py scan-stderr` and a
  second-agent visual re-check.
- **No donor parity claim.** Per `TEST_MATRIX.md:32-34,56-57` and
  `V3D_02` frontmatter `:14`, all visual statements remain UNVERIFIED until a
  donor GPU A/B frame exists.
