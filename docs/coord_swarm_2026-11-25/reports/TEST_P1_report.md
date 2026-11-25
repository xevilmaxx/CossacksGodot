---
id: TEST-P1
title: "Author the ISOLATED terrain+trees 64² atom (ONE new file) — authoring only"
owner: TEST-P1
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: AUTHORED__NO_GODOT_RUN__NO_RUNNER_JOB__NO_OTHER_EDITS
owns:
  - "variant3d/tests/t_terrain_trees.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_P1_report.md"
labels: [ISOLATED_TEST, P1, TERRAIN_TREES, SMALL_MAP_64, WINDOWED_CAPTURE]
evidence_labels: [observed, derived, inferred]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,19,29-46"
---

# TEST-P1 — isolated terrain + trees 64² atom

## 1. Goal

Author exactly one new Godot atom, `variant3d/tests/t_terrain_trees.gd`, that
reproduces the **P0 stub baseline byte-for-byte** (64×64, all-grass tileblock,
no water cells, no units/buildings/FX) and adds **one and only one delta**:
`N = 20` wood resource nodes at known cells, fed through
`world3d_entities.add_resource()` / `POOL_TREE`. It must assert that the P0 mesh
invariants are unchanged, that the tree instance count and category purity are
exact, that every tree is snapped to the terrain height, and that a windowed PNG
differs from the P0 PNG only in the tree footprints. Donor-grounded scale/yaw
criteria are **recorded as known gaps, never asserted as donor parity**.

No Godot process was launched, no runner ticket was taken, and no manifest,
config, fixture, gate-file or source file was edited.

## 2. Sources (all read-only this pass)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:213` | P1 row: setup, capture path, measures, pass/fail, 10–15 s estimate |
| same, `:228-255` | scaffolding: shared helper API (`make_stub_game`, `count_categories`, `write_result`), windowed stub-owned capture, dynamic `load()`, no `class_name` |
| same, `:269-301` | integration blockers: no generator flags, headless cannot capture 3D PNG, registry stale, class-name cache |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,19,29-46,54-58` | same-map rule, P1 contents, V3D_02 T1 refinement, runner/Windows rules |
| `docs/coord_swarm_2026-11-25/reports/DTRN_04_donor_trees.md:304-324` | **10 precise P1 criteria T1–T10** and the pass rule (T1–T9 must be true, T10 is a second-agent judgement) |
| same, `:53-72` (claims C1–C20), `:247-266`, `:188-201` | donor tree truth: family scale ladder, ±15 % jitter, authored yaw, height snap; variant3d's 6-sid pool, single `ENV_SCALE["tree"]=0.5`, yaw 0, no forest bake |
| `docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:134-153` | T1: trees via `add_resource`/`POOL_TREE`, Y vs `height_at_world()`, draw calls + frame time; parity guard `:14` |
| `variant3d/tests/t_terrain_only.gd:44-86,93-143,248-316,331-349,385-594,597-643` | **P0 baseline** read-only: exact fixture, stub shape, camera, SubViewport capture, PNG metrics, verdict/skip convention |
| `variant3d/tests/fixtures/_smallmap_harness.gd:14-70,117-180` | shared helper API actually loaded dynamically (StubGame shape, `make_stub_game`, `count_categories`, `write_result`) |
| `variant3d/scripts/world3d_terrain.gd:93-95,166-167,408-488,624-903` | mesh recipe, `dump` decoding, `build()` stats, `height_at_world()` |
| `variant3d/scripts/world3d_entities.gd:106-118,711-757,944-1015,1060-1121,1269-1315,1334-1564` | `POOL_TREE`, `_resource_sid`, `_acquire`, `_xf`/`_world_pos`, batch names, CPU `xforms` mirror, `sync()` stats |
| `variant3d/scripts/camera3d.gd:148-197,282-303` | fixed-camera bind, null-safe height sampler, frame-freeze rationale |
| `variant3d/tests/t_terrain3d.gd:12-14,41-46,106-127,130-151,161-255` | dynamic `load()`, deferred quit, largest-mesh finder, stub precedent |
| `variant3d/tests/_template_test.gd:1-38`; `t_pick3d.gd:48-71` | one-feature/file, result JSON, `cmd_*` counters |
| `terrain3d_sandbox.gd:139-151`; `testbridge.gd:277-308`; `main.gd:1846-1853` | `SubViewport` → `frame_post_draw` → `save_png`, loud blank-frame failure |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` | non-black / full-width dark row metric mirror and external stderr scan |

## 3. Baseline reuse (the only delta is trees)

Everything in `t_terrain_trees.gd` that is not tree-related is copied from P0
(`t_terrain_only.gd`):

- 64×64 grid, `TILE_M = 2.0`, `CELLS = 4096`, `GRASS_TILE = 0`, `BLK_WATER = 255`,
  `WATER_LEVEL = -0.25` (`world3d_terrain.gd:93-95`, `game.gd:16,52`).
- Mild relief `1.5 + 0.03·sin(0.11x) + 0.02·cos(0.09z)` — max neighbour delta
  ≪ donor `cDiff1 = 0.5` (`world3d_terrain.gd:117-118`), so **0 faces promoted**
  and **0 cells below water** (`t_terrain_only.gd:257-266`).
- Stub game built by dynamic `load()` of the shared helper; the helper appeared
  during the session, so the normal path uses it. A shape-compatible embedded
  `LocalStubGame` remains as fallback and `harness_source` in the JSON says which
  path ran (TEST-01 `:299-301`).
- Same `camera3d.gd` bind, `_process(false)`, `make_current()`, same
  `SubViewport` (1280×720, `UPDATE_ONCE`, capture at frame 10), same
  `WaterPlane`/`Water3D` hiding, same non-black / dark-row metric.
- The tree nodes use `kind = "res"`, `type = "wood"`, `hits/max_hits = 1`,
  `dead/hidden = false` so `_is_hidden()` is false (`world3d_entities.gd:1082-1091`)
  and `_resource_sid("wood", pos)` resolves through `POOL_TREE` (`:1269-1272`).
- The 20 cell pairs are fixed constants (`TREE_CELLS`, all distinct, central band
  cells x,z ∈ [24,39]); SIM position = `(cell+0.5)·TILE_M`.

No `main.tscn` boot, no real generator, no `--dump-map` (DTRN_04 `:323-324`).

## 4. Exact assertions (with citations)

All checks are emitted as `{name, passed, status, detail}`; `passed = null` plus
an explicit status records a KNOWN_GAP / SKIP and never flips the atom's
`structural_ok` (convention from `t_terrain_only.gd:165-174`).

| # / check name | Assertion | Source / tag |
|---|---|---|
| `harness_stub_shape` | game exposes `MAP_W/MAP_H = 64`, `PackedFloat32Array height`, `PackedByteArray tileblock`, `res_nodes` of length 20 | TEST-01 `:230-239`; helper `:14-70`; **observed** API |
| `terrain_module_api` / `entities_module_api` / `camera_module_api` | `load()` succeeds and `bind/build/invalidate/has_chunk_or_fallback/height_at_world`, `bind/sync/add_unit/add_building/add_resource/remove`, `bind/world_to_px/screen_to_world/set_zoom_target` exist | `t_terrain3d.gd:180-189`; TEST-01 Blockers 10; **observed** |
| `build_ok` | `world3d_terrain.build()` returns true | `world3d_terrain.gd:624` |
| `surface_count` | resident terrain mesh has exactly **1** surface | DTRN_04 T1; V3D_02 `:139-144`; **observed** |
| `vertex_count` | **4096** vertices | same; `(w-1)(h-1)·2` formula `:664-667` |
| `triangle_count` | **7938** triangles = 63·63·2 | same |
| `uv2_count` | **4096** UV2 entries | same; `:691-708` |
| `uv2_y_face_modes` | every UV2.y ∈ {0,1,2} and integral | V3D_02 `:144`; `world3d_terrain.gd:703-708` |
| `flat_grid_promoted` | a perfectly flat 64² grid promotes **0** faces | `t_smallmap_terrain.gd:150-171`; DTRN_04 T1 |
| `no_water_cells` / `no_water_tileblock` | 0 cells with `height < -0.25`; 0 `BLK_WATER` tile ids | TEST-01 P0 `:212`; `:331-349` precedent |
| `water_plane_hidden` | all module-owned `WaterPlane`/`Water3D` nodes hidden, not deleted | `terrain3d_sandbox.gd:120-124`; isolation requirement |
| `tree_nodes_bound` | `game.res_nodes.size() == 20` | DTRN_04 T2 (N=20 = labelled stress case) |
| `tree_instance_count` | sum of `MultiMeshInstance3D.visible_instance_count` over `Batch_res_*` nodes == **20** | TEST-01 `:213`; DTRN_04 T2; node names from `world3d_entities.gd:966`; `_acquire` `:1014` |
| `category_purity` | every batch sid ∈ `POOL_TREE` (`tree_spruce1/pine/fir/oak/spruce2/pinedry1`); zero stone/ore/stump/food/proxy sids | `world3d_entities.gd:113-118,1269-1283`; DTRN_04 T2; **observed** |
| `no_non_tree_batches` | no `Batch_unit_*` / `Batch_building_*` nodes (P1 has no units/buildings) | TEST-01 `:213` |
| `tree_height_snap` | for each CPU-mirror instance: `max(|Y − game.height_at(simPos)|, |Y − terrain.height_at_world(worldPos)|) ≤ 1e-3 m` | DTRN_04 T5 (`world3d_entities.gd:1077-1079`); V3D_02 T1/`:145`; `t_terrain3d.gd:235-253`. Mirror necessity: `world3d_entities.gd:977-979` (headless dummy returns identity) |
| `trees_above_water` | 0 trees with `Y ≤ -0.25` | DTRN_04 T5 |
| `capture_image` / `capture_saved` | windowed `SubViewport.get_texture().get_image()` non-empty and `save_png(userArg)` == OK; blank frame is a hard FAIL | TEST-01 `:196-198`; `main.gd:1846-1853`; headless guarded |
| `png_differs_from_p0` | changed pixels (any RGB channel delta > 8/255) between P1 PNG and the P0 PNG > 0 | TEST-01 `:213`; V3D_02 T1; DTRN_04 T7 |
| `diff_confined_to_tree_footprints` | P0 ground-only mask = complement of dilated (160 px) circles at projected tree positions; `changed_in_mask > 0` **and** `changed_outside/total ≤ 0.10` | DTRN_04 T7 (difference confined to tree footprints + shadows, ground mean unchanged); `camera3d.gd:255-259` `unproject_position`. **derived / PORT APPROX** — circle radius is a generous proxy, not a rendered silhouette raster |
| `no_new_black_blocks` | P1 pixels newly < 8 luma where P0 ≥ 8 are ≤ 0.5 % of frame | DTRN_04 T7 "no opaque black rectangles" |
| `no_full_width_dark_rows` | 0 rows with > 90 % of pixels luma < 20 | DTRN_04 T1; `smallmap_capture.py:27-28` |
| `draw_calls_recorded` / `frame_time_recorded` | ≥1 `Performance` sample; record `RENDER_TOTAL_DRAW_CALLS_IN_FRAME`, `TIME_PROCESS` and real frame delta averages in JSON | V3D_02 T1/`:145`; `terrain3d_sandbox.gd:127-133` |
| `donor_scale_ladder` → **KNOWN_GAP** | *Not asserted.* `ENV_SCALE["tree"]=0.5` collapses all species; donor 0.341–0.76 + ±15 % jitter is recorded only | DTRN_04 `:251-254`, C3/C4, F1 `:275-280`; `world3d_entities.gd:113,326-333` |
| `donor_yaw_bins` → **KNOWN_GAP** | *Not asserted.* res-node yaw is always 0 (1 bin); donor ≥6 distinct 30° bins is recorded only | DTRN_04 T4/F2 `:281-285`; `world3d_entities.gd:1094-1121` |
| `donor_passability` → **NOT_ASSERTED** | stub has no `is_blocked()`; reserved for a real-game row | DTRN_04 T6 `:316` |
| `donor_visual_review` → **SECOND_AGENT_REQUIRED** | silhouette/canopy/shadow review; no numeric 3-D gate; no donor GPU A/B | DTRN_04 T10 `:320`; V3D_02 parity_guard `:14`; TEST_MATRIX `:58` |
| `script_error_scan_external` → **EXTERNAL** | GDScript cannot read stderr; `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>` must report 0 `SCRIPT ERROR` | DTRN_04 T9; TEST-01 `:92` |
| verdict | `PASS` only when `structural_ok` **and** PNG diff evaluated; otherwise `SKIP_CAPTURE` — headless/no-P0-baseline is never presented as a visual PASS | `t_terrain_only.gd:182-185,234-237` |

### Runner form (NOT executed)

```
python variant3d\tools\godot_runner.py run --id TEST-P1-p1 --timeout 120 -- --path variant3d --script res://tests/t_terrain_trees.gd -- --screenshot <abs>\smallmap64_terrain_trees.png --p0-png <abs>\smallmap64_terrain_only.png
```

Headless form drops `--screenshot` and uses `--headless`: structural checks only,
verdict `SKIP_CAPTURE`. User args after the second `--` follow
`TERRAIN_SMALL_maps.md:57-66`; Windows `python`, never `python3`
(`TEST_MATRIX.md:55`).

## 5. Expected pre-fix result (prediction, NOT an observation)

The atom exercises the **current** (pre-F1/F2/F3) port. From source reading:

- **Expected to hold:** all P0 invariants (the tree module adds only
  `MultiMeshInstance3D` siblings and never touches the terrain mesh),
  `tree_instance_count == 20`, `category_purity`, `trees_above_water`, and
  `tree_height_snap ≈ 0 m` (both samplers reduce to the same grid cell at the
  chosen cell-centre positions; `world3d_entities.gd:1094-1121`,
  `world3d_entities.gd:1074-1079`).
- **Expected to hold if the windowed capture works:** P1 PNG differs from P0 in
  the tree footprints; no new full-width dark rows. This is the first run of
  this pair, so the exact changed-pixel fraction is **UNVERIFIED**.
- **Expected to be recorded, not pass:** `donor_scale_ladder` (one 0.5 size for
  all six species) and `donor_yaw_bins` (yaw 0). Per DTRN_04 T3/T4 these are
  **FAIL against the donor** if they were asserted, which is why this atom
  deliberately labels them KNOWN_GAP instead of asserting parity
  (`DTRN_04:312-314`; TEST_MATRIX `:56` "metrics never override visual A/B").
- **Expected overall:** structural PASS; `verdict = PASS` only on a windowed run
  with a comparable P0 PNG, otherwise `SKIP_CAPTURE`. No donor parity claim.

Nothing above was measured. The atom has **not been run**; these are derived
expectations from cited source, not results.

## 6. Open questions / risks

1. **P0 baseline PNG must exist and be comparable.** P1 defaults the P0 path by
   replacing the `_terrain_trees` / `_trees` suffix of the P1 path with
   `_terrain_only` / `_only`; `--p0-png` overrides it. If absent, the four diff
   checks are recorded `SKIPPED_NO_BASELINE` and the verdict is `SKIP_CAPTURE`.
   The P0 owner must have captured with the *same* fixture, camera, 1280×720
   size and frame count; otherwise changed-pixel attribution is invalid.
2. **Footprint mask is a 160 px circle proxy**, not a rendered silhouette
   raster; it is deliberately generous. If projection (`unproject_position`)
   disagrees with the SubViewport, `changed_in_tree_footprint` can read 0 and
   the localization check fails even though trees rendered. This needs a real
   windowed run to calibrate; the radius/cap are exposed as constants.
3. **Tree visibility under the fixed camera.** The 20 cells are central, but
   `camera3d` framing at default zoom (height ≈ √(20·58) m, `camera3d.gd:203-209`)
   may place some trees outside the frame. No donor camera A/B exists
   (V3D_02 `:185`).
4. **`_batches` CPU mirror access.** The Y assertion reads the private
   `world3d_entities._batches` mirror via `Object.get()` (same mechanism as
   `world3d_terrain.gd:780` reading `_water3d.get("stats")`). If a future
   refactor renames it, `tree_height_snap` fails loudly rather than silently.
5. **Determinism (DTRN_04 T8)** is *not* asserted here: it needs two identical
   runs and a SHA-256 comparison. Left for a follow-up owner.
6. **Passability (T6)** and season material (DTRN_04 §6 #5) need real-game state
   and are out of scope for this stub atom.
7. **Registry/manifest** registration and `test_all.py` 2D-path fix remain an
   integration ticket (TEST-01 `:257-267`); this atom is launchable only by a
   manual `godot_runner.py` invocation.

## 7. No-runner declaration

- **One new file authored:** `variant3d/tests/t_terrain_trees.gd`.
- **One report authored:** this file.
- **No Godot process launched; no `godot_runner.py` ticket taken; no screenshot
  or JSON result produced by execution.**
- **No edits** to `world3d_terrain.gd`, `world3d_entities.gd`, `camera3d.gd`,
  `main.gd`, any shader, asset, config, `manifest.json`, fixture, gate file or
  git state. The shared helper and P0 atom were **read only** (they appeared
  from sibling owners during this session and were not modified).
- **No PASS claimed.** Every pass/fail value in this report is either a source
  citation, a derived expectation, or an explicit label; the atom itself has
  never emitted a result.
