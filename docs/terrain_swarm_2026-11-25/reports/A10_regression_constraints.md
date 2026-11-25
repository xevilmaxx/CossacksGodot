---
id: A10-REGRESSION-CONSTRAINTS
title: "A10 — exactly what a terrain fix must not break (read-only constraint inventory)"
owner: A10 (diagnosis wave, read-only)
date: 2026-11-25
status: READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "Reads only: CHARTER.md, variant3d/tests/{t_terrain_only,t_combo_all,t_render_mode,t_season_overlay,t_view_rect_rv,t_select_rect}.gd, variant3d/scripts/{selftest,uitest}.gd, variant3d/tools/assert_clean.py, docs/coord_swarm_2026-11-25/{TEST_MATRIX.md,FINAL_CHECKLIST.md,reports/P0_GATE_01.md}, plus one targeted read of variant3d/shaders/terrain_tileindex.gdshader to ground the risk column. No test, shader, config, fixture, gate, result JSON or app/** file was edited. No runner job submitted."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — no donor GPU A/B exists (CHARTER §3; V3D_02 parity_guard; TEST_MATRIX.md:32-34,73-74). No donor parity is claimed or implied by any entry below."
---

# A10 — what a terrain fix must not break

## 0. Reading rules (binding)

- **CHARTER §3** governs: no threshold lowered, no assertion deleted, no
  `expected_pre_fix_failure` flipped without a landed fix; no synthetic
  dither/noise field (S-25-09); no invented donor constants — every substitute
  stays labelled PORT APPROX; one Godot at a time via the runner only;
  backups before edits; disjoint ownership; Windows `python`.
- **Labels used in the tables:** `S` = structural assertion (mesh/UV/data/API/
  topology/hygiene — fails loudly on a broken invariant); `V` = visual or
  PORT APPROX gate (PNG-derived luma/coverage/dark-band metric — not donor
  truth); `C` = capture mechanics (PNG exists / saved, not a quality claim);
  `M` = measured/diagnostic only (recorded, no pass/fail); `H` = hygiene or
  governance rule (no shader/mesh/data predicate).
- **Risk-axis codes:** `U` = UV repeat (`uv_repeat`, `v_alpha_uv`,
  `fract(v_st*uv_repeat)`); `A` = alpha modulation (`mask_to_alpha`,
  `alpha_patch_uv`, alpha sampler binding); `T` = tile ids (UV2.x, tileblock,
  atlas cell index, manifest/preset index order); `R` = relief (height field,
  `_face_mode_at`, `WATER_LEVEL`, vertex Y, water/shore masks); `F` = atlas
  filter (`filter_nearest_mipmap` / `filter_nearest` sampler hints, mipmap).
  `—` means the axis has no direct predicate on this check.
- Observations are literal file facts (`:line`); risks are **derived** from
  those predicates; donor-equivalence of any changed pixel is **UNVERIFIED**.

---

## 1. Master table — check → file:line → constraint → risk per axis

### 1.1 `variant3d/tests/t_terrain_only.gd` (P0, isolated grass-only 64² atom)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `CHECK_NAMES` roster (21 rows) | :67-93 | S | Defines the P0 contract; must not lose a row. | all axes: row deletion is weakening (CHARTER §3). |
| `harness_stub_shape` | :429 | S | Stub must expose `MAP_W/H`, `height` as `PackedFloat32Array`, `tileblock` as `PackedByteArray`, `res_nodes=[]`. | `T/R`: keep the byte-array tile/height interface; a fix that changes data type breaks it. |
| `terrain_module_api` | :462 | S | `world3d_terrain.gd` must keep `bind`, `build`, `invalidate`, `has_chunk_or_fallback`, **`height_at_world`**. | `R`: do not rename/remove `height_at_world` (height sampling is part of the contract). |
| `camera_module_api` | :474 | S | `camera3d.gd` keeps `bind`, `world_to_px`, `screen_to_world`, `set_zoom_target`. | — (camera is not a terrain surface; keep it out of the terrain fix). |
| `build_ok` | :489 | S | `build()` returns `true`. | all axes: a renamed shader uniform/sampler that breaks material binding fails here. |
| `surface_count` | :522 | S | Exactly **1** mesh surface. | `T`: do not split the mesh by tile id or material to vary texture. |
| `vertex_count` | :523 | S | Vertices == `CELLS` == **4096**. | `R`: no vertex subdivision/addition for relief. |
| `triangle_count` | :524 | S | Triangles == (64-1)²·2 == **7938**. | `R`: no triangulation change. |
| `uv2_count` | :526 | S | UV2 entries == 4096. | `T`: do not drop/replace the UV2 channel (it carries tile id + face mode). |
| `uv2_y_face_modes` | :551-552 | S | Every UV2.y is integral and in `{0,1,2}`; histogram recorded in `_m["uv2_y_hist"]`. | `R`: face-mode vocabulary must stay exactly 0/1/2; relief promotion must emit no new value. |
| `flat_grid_promoted` (via `_probe_flat_promotions` :316-332) | :556-558 | S | A perfectly flat 64² grid yields **0** promoted faces (FIX-TERRAIN §8 regression guard). | `R`: **DO NOT TOUCH** `_face_mode_at` thresholds — this is the hard flat-grid regression. |
| `res_nodes_empty` | :563 | S | No trees/mines/units in P0. | — (isolation scope, not a terrain predicate). |
| `no_water_cells` | :574-575 | S | 0 cells below `WATER_LEVEL=-0.25`. | `R`: keep the water-level literal and height semantics. |
| `no_water_tileblock` | :582-583 | S | 0 cells with `BLK_WATER=255`; all grass id 0. | `T/R`: preserve water tile id 255 and grass index 0. |
| `atlas_grid_manifest` | :607-610 | S | `stats.atlas.grid == [16,8]` **and** shader param `atlas_grid == Vector2(16,8)`. | `T/F`: atlas dimensions are fixed; do not repack grid or change the param spelling. |
| `atlas_material_bound` | :611-613 | S | Material is `ShaderMaterial`; `tile_atlas`, `alpha_atlas`, `alphavert_atlas` all non-null. | `A/F`: do not remove/rename the three sampler uniforms; filter hints are free to change on the existing samplers. |
| `shader_shadow_disabled` | :615-616 | S | Shader `shadow_enabled` stringifies to `0`/`0.0`. | — (do not repurpose this uniform for a terrain fix). |
| `water_plane_hidden` | :363-365 | S | Module-created `WaterPlane`/`Water3D` nodes exist and are hidden, not deleted. | `R`: keep the module-owned plane creation contract. |
| `capture_image` / `capture_saved` | :660 / :668 | C | Windowed SubViewport texture non-blank; PNG written. | all visual axes affect content, not existence. |
| `non_black_fraction` | :677-678 | V | Whole-frame fraction > 0.9 (mirror of `smallmap_capture.py:26`). | `U/A/F`: atlas-cell choice, alpha fold or filter can push coverage below 0.9. |
| `full_width_dark_rows` | :687-689 | M (known gap) | `passed:null`, `status=RECORDED_NOT_APPLICABLE`; value still recorded in `_m["png_metrics"]`. | `A/F`: value changes with brightness, but it is **not** a pass/fail gate in P0 — do not flip it back to a hard assert or delete it. |
| `ground_mean_luma` | :704-705 | V (PORT APPROX) | `mean_luma >= 40` — deliberately chosen to FAIL the 13.271 defect. | `U/A/F`: **high risk** — all three alter sampled RGB; must stay above the floor. |
| `ground_max_luma` | :706-707 | V (PORT APPROX) | `max_luma >= 100` — deliberately chosen to FAIL the 27.413/28.4 defect peak. | `U/A/F`: **high risk** — need real tonal range, not a uniform field. |
| `uv2_x` range/out-of-atlas | :541-550 | M | `min_x`, `max_x`, `out_of_atlas` computed and recorded, **not asserted in P0**. | `T`: still auditable; the strict version is `mesh_uv2_count`/`uv2_x_in_atlas` in C4 and season atoms. |

### 1.2 `variant3d/tests/t_combo_all.gd` (C4, last combo row)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `headless_guard` | :558-563 | S | Windowed mandatory; headless is `SKIPPED_HEADLESS`, never a PASS. | — (run protocol; no visual claim from a skipped run). |
| `terrain_module_load` / `entities_module_load` | :570 / :576 | S | Both scripts load and instantiate. | all axes: keep module/script names stable. |
| `atlas_manifest_read` | :588-589 | S | Manifest parsed, `atlas.grid` size 2; `named_cells` from manifest (fallback 124). | `T`: manifest shape and named-cell count are read here. |
| `stub_game_valid` / `build_ok` | :602 / :613 | S | Stub shape valid; `build()` true. | all axes. |
| `single_terrain_mesh` / `mesh_single_surface` | :634-635 / :645 | S | Exactly 1 full-grid `MeshInstance3D` with 1 surface. | `T`: no per-tile mesh split. |
| `mesh_vertex_count` / `mesh_triangle_count` / `mesh_uv2_count` | :670-673 | S | 4096 / 7938 / 4096. | `R/T`: no topology change; UV2 channel mandatory. |
| `uv2_x_in_atlas` | :688-689 | S | Every UV2.x integral in `[0,named_cells-1]` (0..123). | `T`: **high risk** — new tile ids beyond 123 or fractional ids fail. |
| `uv2_y_face_modes` | :690 | S | UV2.y integral 0/1/2. | `R`: face-mode vocabulary fixed. |
| `face_hist_sum` / `tile_index_cells` | :702-703 / :704-706 | S | Face histogram sums to 4096; `tile_index.cells == 4096`. | `T/R`: tile index must cover every cell once. |
| `flat_face_zero` | :718 | S | Flat 64² grid → 0 promotions. | `R`: **DO NOT TOUCH** — same hard guard as P0. |
| `atlas_grid_manifest` | :746-747 | S | `stats.grid == shader atlas_grid == manifest.grid`. | `T/F`: three-way equality; do not desync any side. |
| `atlas_samplers_bound` | :748-749 | S | Three samplers non-null. | `A/F`: keep `tile_atlas`/`alpha_atlas`/`alphavert_atlas`. |
| `shader_shadow_disabled` / `sun_shadow_off` / `terrain_cast_shadow_off` | :750-763 | S | Shader shadow param 0; `DonorSun.shadow_enabled=false`; `mi.cast_shadow=OFF`. | — (do not enable shadows to fake relief). |
| `height_at_world_samples` | :776 | S | 3 sample points match stub heights within 0.001 m. | `R`: **high risk** — any height/relief change must keep the public sampler exact. |
| `water_cells_bounded` | :779-782 | S | With shore: water cells >0 and <10% of 4096; without shore: 0. | `R`: relief must not flood or drain the bounded basin. |
| `shore_ids_in_hist` | :794-795 | S | `sandsea`/`sandrock` preset indices appear in UV2.x histogram. | `T/R`: shore tile ids and face modes must keep appearing together. |
| `water_module_height_aware` / `single_water_plane` | :803-811 | S | Module ends with `water3d.gd`, `height_aware=true`; exactly 1 `WaterPlane` + 1 `Water3D`. | `R`: do not add stacked water layers for relief/shore. |
| `resource_y_matches_terrain` | :915-916 | S | Each tree/mine transform Y == `height_at_world` within `EPS_M=0.02`. | `R`: **high risk** — relief changes move entities; must stay within 2 cm. |
| `resources_above_water` | :917-918 | S | Every stub tree/mine cell height > water level. | `R`: relief must not sink resource cells below -0.25. |
| `mine_tree_separation`, `no_cmd_calls`, `single_environment_rig` | :928 / :936 / :946 | S | Fixture distance >0; zero `cmd_*`; 1 `WorldEnvironment` + 1 sun. | — (isolation/rig scope; no terrain predicate). |
| `png_captured` / `png_saved` | :980 / :1033 | C | SubViewport PNG non-empty and saved with bytes >0. | all axes affect content, not existence. |
| `nonblack_over_090` | :1000-1001 | V | >0.9 sampled non-black. | `U/A/F`: coverage risk. |
| `full_width_dark_rows_zero` | :1002-1003 | V (**strict here**) | `dark_rows == 0` — this row **has** a water-bearing shore, so the P0 record-only treatment does **not** apply. | `U/A/F`: dark bands must not appear; see FINAL_CHECKLIST E-C2 (do not relax). |
| `ground_mean_luma` / `ground_max_luma` | :1007-1010 | V (PORT APPROX) | >=40 / >=100, same thresholds as P0. | `U/A/F`: high risk. |
| `no_full_height_dark_cols` | :1011-1012 | V | `dark_cols == 0` (vertical seam guard). | `U/F`: atlas repeat/filter can produce column banding. |
| `mean_luma_recorded` / `draw_calls_recorded` | :1013-1017 | M | Finite mean luma recorded; draw samples >0. | — (recorded, not compared). |
| `no_new_seam_class` | :1018-1022 | S+V | 1 mesh + 1 plane + 1 rig, 0 dark rows, 0 dark cols, non-black >0.9. | `U/A/F/R`: composite guard — relief seams or filter banding fail it. |

### 1.3 `variant3d/tests/t_render_mode.gd` (2D-default hard gate)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `main_source_readable` / `main_script_loads` | :69 / :72 | S | `main.gd` readable and light-loads. | — (do not put terrain-specific boot logic in `main.gd`). |
| `render_mode_exposed` / `render_mode_default_2d` / `runtime_default_2d` | :77 / :80 / :118 | S | `render_mode` declared; source fallback `"2d"`; bare instance reads `"2d"`. Header :5: "Do NOT weaken this test: the 2D default is a hard gate." | — **DO NOT TOUCH** the 2D default to force a 3D terrain path. |
| `make_world3d_exposed` / `make_camera3d_exposed` / `three_d_branch_present` / `three_d_helpers_wired` | :84 / :85 / :91 / :93 | S | `func make_world3d(...)`, `func make_camera3d(...)` present, called ≥2 times each, gated on `render_mode`. | — (keep the 3D seam intact; a fix must not bypass it). |
| `two_d_path_preserved` | :100 | S | Legacy `C3WorldScript.new()`, `C3CameraScript.new()`, `world.bind(game)`, `camera.bind(world)` still present. | — **DO NOT TOUCH**; terrain fix must not replace the 2D world/camera constructors. |

### 1.4 `variant3d/tests/t_season_overlay.gd` (index-preservation gate)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `summer_dictionary` | :1019/1024 | S | `presets_summer.json` parses to the name array (124 entries expected). | `T`: preset index order is the canonical id space; do not renumber. |
| `harness_stub_shape` / `sp5_manifest_override_api` / `terrain_camera_scripts` | :1034 / :1046 / :1055 | S | Dump shape; loader `manifest_path`/`single_atlas_path` overrides; terrain+camera scripts. | `A/F`: keep manifest override API (season atlas swaps depend on it). |
| `summer/winter/desert_dependency_state` | :422-431 | S | Summer baseline missing = real FAIL; winter/desert may be `PENDING_DEP` (null). | `T`: keep the asset paths/hooks these probe. |
| `{id}_build_ok` / `{id}_manifest_resolves` / `{id}_manifest_grid` | :630 / :648 / :657-658 | S | Each season builds; manifest parses; grid == `[16,8]`. | `T/F`: manifest grid fixed for all three seasons. |
| `{id}_atlas_selection` | :665-666 | S | `stats.atlas_path`/`atlas.manifest` contains the expected season manifest. | `A/F`: do not hard-code a single atlas path in the shader/module. |
| `{id}_uv2_entry_count` / `{id}_uv2_x_in_range` | :680-681 / :699-701 | S | 1 surface, UV2 count == w·h; UV2.x integral in `[0,named-1]`. | `T`: **high risk** across all three seasons. |
| `winter_dict_124_entries` / `winter_entries_index_and_names` / `winter_names_resolve` | :482-483 / :508-510 / :514-515 | S | 124 contiguous indices, names == `presets_summer` order, alias == name+"_winter", all `source_png` exist. | `T`: **DO NOT TOUCH** the summer→winter index mapping; a tile-id reorder breaks three checks. |
| `desert_remap_parsed` / `desert_remap_targets_resolve` | :598-606 | S | 38 direct + 1 height-gated pairs; src/target names resolve to packed indices. | `T`: **DO NOT TOUCH** the 38/1 remap counts or index targets. |
| `{id}_capture_image` / `{id}_capture_saved` / `{id}_non_black_fraction` / `{id}_full_width_dark_rows` | :766-803 | C+V | Each variant captures; non-black >0.9; `full_width_dark_rows == 0` **strict per season**. | `U/A/F`: a filter/alpha/repeat change must keep every season bright and band-free. |
| `tileblock_index_preserved` | :884-885 | S | Stub dump tileblock **byte-identical** after all three variant builds. | `T`: **DO NOT TOUCH** — no season hook (or terrain fix) may mutate the tile id bytes. |
| `uv2_x_summer_winter_identical` | :892-893 | S | Summer and winter UV2.x arrays element-for-element equal. | `T/A`: winter is a texture-only swap; changing tile-id decoding per season fails this. |
| `uv2_x_desert_remap_consistent` | :911-912 | S | Every desert UV2.x == `remap(summer UV2.x)` at the same cell (0 mismatches). | `T`: **high risk** — deterministic 1:1 index remap must survive any fix. |
| `no_script_errors_internal` / `script_error_scan_external` | :920-924 | S+M | No internal error paths; external stderr scan stays `PENDING_EXTERNAL_SCAN`. | — (do not turn the pending external scan into a fake PASS). |

### 1.5 `variant3d/tests/t_view_rect_rv.gd` and `t_select_rect.gd` (selection/view atoms)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `boot_real_64_3d_game` | t_view_rect_rv.gd:207 / t_select_rect.gd:353 | S | Real `main.tscn` boot, `render_mode=3d`, 64×64. | all axes: a terrain change that breaks module build can abort the boot these need. |
| `corners_from_live_camera`, `expected_rect_non_degenerate`, `expected_rect_not_full_map_fallback`, `camera_active_in_viewport`, `view_rect_equals_expected` | t_view_rect_rv.gd:255,290,294,304,312 | S | `world.view_rect` equals rect derived from live camera corners + half-map shift. | — `U/A/T/F`: **none** — derived from camera projection, not terrain pixels. `R`: camera target is independent of terrain height; keep `camera3d` edits out of scope. |
| `minimap_box_consistent_with_view_rect`, `minimap_box_stable_after_clicks`, `camera_pose_stable` | t_view_rect_rv.gd:372,436,441 | S | Adapter minimap box and camera pose stay consistent/stable. | — (no terrain predicate). |
| `double_click_selected_exact`, `outside_*_not_selected`, `other_sid_not_selected` | t_view_rect_rv.gd:420-430 | S | Select-all-of-type respects the view rect. | — (no terrain predicate). |
| `ground_endpoints_finite`, `drag_crosses_donor_0.005m_epsilon`, `building_inside_rect_but_excluded_by_kind` | t_select_rect.gd:454-466, :562-563 | S | `picking3d.ground_point()` returns finite ground points; drag world delta > 0.005 m; building inside ground rect but excluded by kind. | `R`: **indirect but real** — ground-point raycast uses terrain height; large relief changes can move `_g0/_g1` and the ground rect, flipping these. `U/A/T/F`: none. |
| `world_sel_active_during_drag`, `overlay_rect_during_drag`, `overlay_hidden_after_release` | t_select_rect.gd:602, :611-612 | S (known gap) | Marquee overlay must exist during drag and hide after release. `check()` carries `expected_pre_fix_failure=true` (:178-188, :539). | — **DO NOT FLIP** the `expected_pre_fix_failure` markers (TEST_MATRIX.md:67-68); the missing marquee is Wave-D work, not terrain. |
| `selected_ids_exact`, `unit10_selected`, `unit11_selected`, `unit12_not_selected`, `building_not_selected`, `cmd_counter_zero_after_drag` | t_select_rect.gd:553-564 | S | Real drag selects [10,11] only, no `cmd_*` side effects. | `R`: only via ground-point geometry above. |
| `short_click_selects_single_unit`, `cmd_counter_zero_after_click` | t_select_rect.gd:569-571 | S | Short click still picks one unit. | — (click-pick regression guard; no terrain predicate). |

### 1.6 `variant3d/scripts/selftest.gd` and `uitest.gd` (functional 29/29 + 17/17)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `STEPS` roster (29) | selftest.gd:10-14 | S | Authoritative 29-step order; FINAL requires 29/29. | `R/T`: **indirect** — steps use `game.blocked`, `is_blocked`, `set_blocked_tile`, `_snap_free_point`, `_nav_line_clear`, `in_bounds`, `can_place`. Changing map-gen tile/height data can flip `build`, `wall`, `farm_cap`, `flee`, `peasant_capture`, `nav_detour`, `no_overlap`. No step asserts any shader/uniform/mesh fact — a pure shader/UV/filter change cannot break selftest. |
| `GROUPS` union == STEPS; `run_groups`/`run_only` | selftest.gd:17-26, :116-132, :201-228 | S | Subsets restore a post-setup baseline; canonical `run()` never restores (byte-stable). | — (harness behaviour; leave untouched). |
| Individual step predicates | selftest.gd:234-818 | S | Gameplay outcomes only (`moved>=3`, `gain>=10`, `foe.dead`, `house.finished`, `gold_gain>5`, `bonus==2/hold==7`, `cap1==cap0+25`, `nav_ok`, etc.). | `R`: height/tileblock smoothing affects walkability and build slots; re-run 29/29 after any data change. `U/A/F`: **none**. |
| `SCENES` roster (17) | uitest.gd:32-35 | S | FINAL requires 17/17. | — (UI journeys; no terrain shader/mesh/data assertion). |
| `_s_select_box` | uitest.gd:115-123 | S | Calls `_set_selection` directly — **not** the real drag path. | — (do not mistake this for the marquee gate; that is `t_select_rect`). |
| `_s_minimap_frustum` | uitest.gd:304-309 | S | Minimap bottom-right 240×240, `anchor_left==1.0`. | — (no terrain predicate). |
| Other 15 scenes | uitest.gd:128-334 | S | Keys, build/train/squad/market/research/speed/cursor/groups/garrison/save-load outcomes. | `R`: same indirect map-data caveat as selftest; re-run 17/17 after data changes. |

### 1.7 `variant3d/tools/assert_clean.py` (runner hygiene, not a shader gate)

| Check name | file:line | Class | Constraint on terrain shader / mesh / data | Risk if we change U / A / T / R / F |
|---|---|---|---|---|
| `FAILURE_STATUSES` | :42 | H | `{timed-out, error, skipped}` are dirty signals; `failed` (clean non-zero exit) is deliberately not. | — no shader predicate; but rerunning failing terrain rows hoping for green creates unacked failures → DIRTY (TEST_MATRIX.md:60-61). |
| `check_processes` | :48-112 | H | 0 live Godot processes (self-PID excluded). | — a terrain fix must not leave orphan jobs; use the FIFO runner only. |
| `check_lock` | :118-148 | H | `godot.lock` free, or held < `DEFAULT_MAX_LOCK_AGE=300s`. | — |
| `check_history` | :154-188 | H | No unacked failure-status jobs; `acknowledged` entries exempt. | — |
| `verdict` / `main` exit | :199-218, :288 | H | `CLEAN`/exit 0 only when all three signals clean; 1 dirty, 2 bad invocation. | — FINAL requires CLEAN/exit 0 (FINAL_CHECKLIST D-3). |

---

## 2. Which checks are structural vs visual/PORT APPROX

**Structural (fail loudly on an invariant break):**
- Mesh topology everywhere: `surface_count`, `vertex_count`, `triangle_count`,
  `uv2_count`, `single_terrain_mesh`, `mesh_single_surface`,
  `mesh_vertex_count/triangle_count/uv2_count` (P0 :522-526; C4 :634-673;
  season `{id}_uv2_entry_count` :680).
- UV contract: `uv2_y_face_modes` (P0 :551, C4 :690), `uv2_x_in_atlas`
  (C4 :688), `{id}_uv2_x_in_range` (season :699), `face_hist_sum`,
  `tile_index_cells` (C4 :702-706).
- Hard flat-grid regression: `flat_grid_promoted` (P0 :556), `flat_face_zero`
  (C4 :718).
- Atlas/data binding: `atlas_grid_manifest` (P0 :607, C4 :746, season :657),
  `atlas_material_bound` (:611), `atlas_samplers_bound` (:748),
  `shader_shadow_disabled` (P0 :615, C4 :750), `sun_shadow_off`,
  `terrain_cast_shadow_off` (C4 :757-763).
- Height/water: `no_water_cells`, `no_water_tileblock` (P0 :574/:582),
  `height_at_world_samples` (C4 :776), `water_cells_bounded` (:779),
  `shore_ids_in_hist` (:794), `water_module_height_aware`, `single_water_plane`
  (:803/:810), `resource_y_matches_terrain` (:915), `resources_above_water`
  (:917).
- Season index preservation: `tileblock_index_preserved` (:884),
  `uv2_x_summer_winter_identical` (:892),
  `uv2_x_desert_remap_consistent` (:911), `winter_dict_*` (:482-515),
  `desert_remap_*` (:598-606).
- Render-mode 2D hard gate: all of `t_render_mode.gd` (especially
  `render_mode_default_2d` :80, `runtime_default_2d` :118,
  `two_d_path_preserved` :100).
- Gameplay/UI: all 29 selftest steps and 17 uitest scenes; selection atoms'
  `selected_ids_exact`, `double_click_selected_exact`, cmd-counter guards.
- Runner hygiene: all three `assert_clean.py` signals.

**Visual / PORT APPROX (never donor truth):**
- `non_black_fraction` (P0 :677, season `{id}_non_black_fraction` :800,
  C4 `nonblack_over_090` :1000).
- `ground_mean_luma >= 40` and `ground_max_luma >= 100`
  (P0 :704/:706; C4 :1007/:1009) — thresholds chosen to fail the dark defect,
  explicitly PORT APPROX (P0_GATE_01 §2/:94-112).
- `full_width_dark_rows == 0` **strict** in C4 (:1002) and season (:802) —
  water-bearing rows; `dark_cols == 0` (C4 :1011).
- `mean_luma_recorded`, `draw_calls_recorded` (C4 :1013/:1016) — measured only.
- `no_new_seam_class` (C4 :1018) — composite structural + visual.
- `capture_image`/`capture_saved`/`png_captured`/`png_saved` are **capture
  mechanics** (`C`), not quality claims.
- `full_width_dark_rows` in P0 (:687) is **recorded-only** (`M`), neither
  structural nor a hard visual gate.

**Donor parity:** every visual statement is PORT APPROX / internal consistency;
no donor GPU A/B frame exists (CHARTER §3; TEST_MATRIX.md:32-34,73-74;
FINAL_CHECKLIST H-2 :414-419). A terrain fix that makes these gates green does
**not** establish donor parity.

---

## 3. Known-gap markers already noted in existing reports — must not flip

| Marker | Source | Why it must stay as-is |
|---|---|---|
| P0 `full_width_dark_rows` → `passed:null`, `status=RECORDED_NOT_APPLICABLE` | `t_terrain_only.gd:687-689`; `P0_GATE_01.md` §2/:74-77, §5/:176-186, §7/:217-220 | It was replaced by two *stricter applicable* gates, not deleted. Flipping it back to a hard assert, or deleting it, is weakening. Its 720-row value stays auditable in `_m["png_metrics"]`. |
| `ground_mean_luma >= 40` / `ground_max_luma >= 100` | `P0_GATE_01.md` §2/:84-85, :94-112; §6/:203-206 | Thresholds were deliberately set above the 13.271 / 27.413 defect. §6 open question 5: "if a future healthy ground frame has a peak below 100 … this gate would need a separate evidence-backed ticket — it must not be relaxed here." |
| `expected_pre_fix_failure=true` on the marquee overlay checks | `t_select_rect.gd:178-188`, :539, :611-612; `TEST_MATRIX.md:67-68`; `FINAL_CHECKLIST.md` §0/:65, A-2/:91 | Deliberate known gap (missing selection-rect draw consumer, V3D-01 break point 1). QA-AUDIT confirmed "no deleted `expected_pre_fix_failure` markers". Wave-D work may land the fix; terrain work must not flip or delete the marker. |
| E-C2 water-free dark-row applicability | `FINAL_CHECKLIST.md:312` | "Water-free row hard-asserts `full_width_dark_rows==0`; if inapplicable, open a separate evidence-backed ticket — do not relax." C4 has a shore, so the strict assert stands there. |
| E-P3 "false green" headless result | `FINAL_CHECKLIST.md:310` | `t_terrain_mines` JSON `passed:true` comes from headless skip rows with 0-byte PNG — must not be read as structural+visual PASS. A terrain fix must not manufacture a similar skip-based PASS. |
| E-P0 CONFIRMED_PASS but PNG predates the 11:57:42 shader edit | `FINAL_CHECKLIST.md:307`, derived roll-up :502-504; `P0_GATE_01.md` §4/:134-174 (job 421 expected FAIL) | Do not treat the earlier gate result as proof that a *new* terrain shader is green; the ladder row is COORD-only and still PARTIAL. |
| Donor parity `UNVERIFIED` | `FINAL_CHECKLIST.md` H-2/:414-419; `TEST_MATRIX.md:46` (F0), :73-74; P0_GATE_01 frontmatter `parity_guard` | A green gate never converts parity to PASS; no donor GPU A/B exists. |
| H-6 white marks / relief not visible | `FINAL_CHECKLIST.md:436-449` | White marks were *reproduced* in a real frame (job 532) and relief was not visible; `SCRIPT ERROR == 0` and the runner's failed/exit-1 were diagnostic. A relief fix must not flip this OPEN/PARTIAL record to PASS without fresh evidence. |
| C-4 TRN-DATA selftest 28/29 (missing `mill_rotor.png` `.ctex`) | `FINAL_CHECKLIST.md:222-226`, B-8/:170-173 | OPEN asset gap; a terrain change must not silently close it by weakening the `build` step. |
| T5 controlled A/B protocol | `TEST_MATRIX.md:45` | The sanctioned way to flip `eye_plane_s/t`, `light_position_eye`, **`uv_repeat`**, **`mask_to_alpha`** is one uniform at a time with pixel-aligned changed-pixel count + luma delta, labelled PORT APPROX until F0. Do not change several axes at once and claim a measured A/B. |
| No synthetic dither/noise field (S-25-09) | `CHARTER.md:55-62` | A fix that adds a procedural noise/dither texture to hide the pattern recreates the 2D checkerboard regression. |
| `app/**` untouched; 2D tooling is not a 3D gate | `FINAL_CHECKLIST.md` §0/:70, I-1/:453-456, I-3/:470-473; `TEST_MATRIX.md:48-51,66` | A terrain fix may not edit 2D `app/` harnesses (`t_shore_smoke.gd`, `t_water.gd`, `visual_tuning_test.gd`, `terrain_piece_render.py`, `tools/pieces/t6_*`) to obtain green. |

---

## 4. Verdict list — safe to change / needs care / do not touch

### SAFE TO CHANGE (low structural risk; visual re-check still required)
- **Atlas sampler filter hints** (`filter_nearest_mipmap` / `filter_nearest` on
  the three existing samplers, shader :60/:66/:72): no structural check reads
  the hint; keep the three sampler *names* bound and re-run the visual gates
  (non-black, dark rows/cols, luma floors). This is the least invasive way to
  attack the nearest-fract banding suspect (CHARTER §2 item 3).
- **Internal shader colour math that leaves every declared uniform, sampler,
  `atlas_grid`, `shadow_enabled`, tile-id decoding and face-mode logic intact**
  and keeps RGB coverage/tonal range above the gates — e.g. changing how a
  *within-cell* colour is computed without changing which cell is sampled.
- **Adding diagnostic/stat fields** to module `stats` (the atoms read only the
  named keys `atlas.grid`, `atlas_path`, `tile_index`, `water`, `material_model`;
  extra keys are ignored). Derived, not observed-safe-by-test — re-run atoms.

### NEEDS CARE (structural predicates survive, but visual gates are strict)
- **UV repeat** (`uv_repeat` :214, `v_alpha_uv` :316, `tile_rgb(...fract(v_st*uv_repeat))`
  :392): no atom asserts its value, so structural checks are safe; **but** it is
  one of the two T5 A/B uniforms (TEST_MATRIX.md:45), it changes both sampled
  RGB and alpha-patch phase, and the `>=40`/`>=100` luma floors and
  `dark_rows/dark_cols == 0` gates can flip. Change one uniform at a time,
  record changed-pixel count + luma delta, keep PORT APPROX label. Also honour
  T1 "ground texgen unchanged vs T0" and T3 "ground unchanged outside mine
  bbox" (TEST_MATRIX.md:41,43).
- **Alpha modulation** (`mask_to_alpha` :235, `rgb*mix(1.0,a,mask_to_alpha)`
  :427, `alpha_patch_uv` :365-378): folding mask into RGB is the likely source
  of repeated dark blotches (CHARTER §2 item 2). Keep `alpha_atlas` and
  `alphavert_atlas` bound; keep the tile→patch rule labelled PORT APPROX
  (DALPHA-01/02 engine rule CONFIRMED_UNVERIFIED). Re-check `non_black_fraction`,
  `ground_mean_luma`, `ground_max_luma`, `full_width_dark_rows` in P0/C4/season.
- **Relief amplitude** (height field values, `height_at_world` samples, entity
  Y placement, water/shore cell counts): C4 asserts sample equality within
  0.001 m and entity Y within 0.02 m; P0 asserts 0 cells below -0.25; C4 bounds
  water cells to <10%; t_select_rect ground-point raycast moves drag geometry.
  Any relief change must re-run C4, S1/selftest and the season atom.
- **Tile-id *appearance*** (which atlas cell a given id reads): you may change
  the artwork inside a cell, but not the id→index mapping. Winter requires
  identical UV2.x arrays; desert requires a strict 1:1 remap; shore requires
  `sandsea`/`sandrock` indices to appear in the UV2.x histogram.
- **Season atlas swaps**: keep the `manifest_path` override and per-season
  manifest selection; only the atlas *content* may change, not the index
  dictionary or the 38+1 desert remap.

### DO NOT TOUCH (hard invariant / governance)
- Mesh topology: **1 surface, 4096 vertices, 7938 triangles, 4096 UV2 entries**
  in P0 and C4 (and 1 surface per season variant).
- UV2 semantics: `UV2.x` integral in `[0,123]` and equal to the tile id;
  `UV2.y` integral in `{0,1,2}`; `face_hist_sum == 4096`;
  `tile_index.cells == 4096`.
- `flat_grid_promoted == 0` / `flat_face_zero == 0` — the FIX-TERRAIN §8
  flat-grid regression guard. Do not alter `_face_mode_at` thresholds.
- `atlas_grid == [16,8]` in stats, shader param and manifest; the three-sampler
  binding; `named_cells = 124`; `presets_summer.json` index order; 124-entry
  winter dictionary (contiguous, name order, `name+"_winter"` alias); 38 direct
  + 1 height-gated desert remap with packed-index targets.
- `tileblock` dump bytes byte-identical across all season variants;
  summer/winter UV2.x identical; desert UV2.x == remap(summer) at every cell.
- `shadow_enabled == 0`, `DonorSun.shadow_enabled == false`,
  `mi.cast_shadow == OFF` — do not enable shadows/cast to fake relief.
- `WATER_LEVEL = -0.25`, `BLK_WATER = 255`, single height-aware `WaterPlane` +
  `Water3D`, WaterPlane hidden in P0 — do not add water layers or change the
  water literal.
- `main.gd`: `render_mode` default `"2d"`, `make_world3d`/`make_camera3d`
  wiring, legacy 2D constructors — the `t_render_mode` hard gate (header :5).
- `assert_clean.py` verdict logic and runner hygiene; no orphan Godot jobs, no
  stale lock, no rerunning a failing row hoping for green.
- All markers/thresholds in §3: P0 `RECORDED_NOT_APPLICABLE`, P0 luma floors,
  `expected_pre_fix_failure`, donor-parity `UNVERIFIED`, H-6/C-4 OPEN statuses.
- No threshold lowered, no assertion deleted (TEST_MATRIX.md:67-68;
  CHARTER §3); no synthetic dither/noise field (S-25-09); no invented donor
  constants; `app/**` untouched.

---

## 5. Observed / derived / UNVERIFIED

- **Observed:** every `file:line` citation in §1-§3; the literal thresholds,
  rosters, sampler names and status strings.
- **Derived:** the axis-risk assessments in §1 (which predicate reads which
  shader/mesh/data fact) and the safe/care/do-not-touch grouping in §4.
- **UNVERIFIED:** whether any candidate terrain change actually improves the
  donor-visual gap. No donor GPU A/B frame exists; no second-agent re-check of
  a post-fix capture exists; the ladder has not advanced past P0 as a row
  (FINAL_CHECKLIST E-P0/E-FINAL). A terrain fix is proven only by re-running
  the named atoms and gates on the changed tree — not by this inventory.

*End of A10. Read-only; one report; no code edit, no Godot job, no donor-parity claim.*
