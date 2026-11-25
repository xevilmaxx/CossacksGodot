---
id: TEST-C1
title: "C1 combo atom t_combo_trees_shore.gd — authoring report (not run)"
owner: TEST-03a (C1 micro-worker)
date: 2026-11-25
status: AUTHORED__NOT_RUN__NO_GODOT__NO_RUNNER__NO_SHARED_CODE_EDITS
owns:
  - "variant3d/tests/t_combo_trees_shore.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_C1_report.md"
labels: [COMBO, TREES, SHORE, SMALLMAP_64, STUB, WINDOWED_CAPTURE, NO_PARITY_CLAIM]
evidence_labels: [observed, derived, inferred]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:22,29-46"
harness: "docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:183-226"
---

# TEST-C1 — authoring report for `t_combo_trees_shore.gd`

## 1. Goal / scope

Author exactly two files — the new atom `variant3d/tests/t_combo_trees_shore.gd`
and this report — implementing the **C1** row of the smallest-map ladder: one
64×64 stub scene that contains P0 terrain **plus** the P1 tree layer **plus**
the P2 shore/water layer, with **no mines**, and asserts the P1 and P2 invariant
sets at the same time. `TEST-01` defines C1 as "P1 + P2 union … tree count,
water-cell count, single surface, both P1/P2 invariants simultaneously", with
"No regression vs either parent; trees never below water level"
(`reports/TEST_01_smallmap_harness.md:216`); `TEST_MATRIX.md:22` adds "no
interaction regressions" and `TEST_MATRIX.md:41-42` adds the T1/T2 refinements
(tree Y on terrain; exactly one height-aware water plane; shore ids in the UV2
histogram; zero full-width dark rows).

**Declaration (observed):** this agent submitted **no Godot process, no runner
ticket, and no job of any kind**. No source, shader, asset, config, manifest,
fixture, gate-file, result JSON or git change was made. The atom has **never
been executed**; no PASS, no green result and no measured runtime value is
claimed here. All numbers below are either *observed from existing files* or
*derived from the cited code*; none is a test outcome.

Out of scope by construction: manifest registration, `test_all.py` roots,
`.uid` generation (Godot-owned), real-game 64² boot, donor GPU A/B capture, and
any edit to the shared helper or to the still-landing P1/P2 atom files.

## 2. Authoritative sources

| Source | Use in this atom |
|---|---|
| `reports/TEST_01_smallmap_harness.md:212-216` | P0/P1/P2/C1 row specs — exact counts, water bound, no-mine isolation, "trees never below water level" |
| `reports/TEST_01_smallmap_harness.md:183-226` | one runner job per row, stub-owned windowed PNG, headless-only variant writes state JSON, 10–15 s estimate |
| `reports/TEST_01_smallmap_harness.md:228-255` | shared helper ownership, dynamic `load()`, per-atom result JSON, read-only `smallmap_capture.py` cross-check |
| `TEST_MATRIX.md:22,29-46` | C1 "no interaction regressions"; T1/T2 extra assertions; no donor parity before F0 |
| `reports/V3D_02_terrain_render_audit.md:134-153` | T1 (tree Y on terrain), T2 (single height-aware plane, shore ids, dark rows), T4 (all-at-once combos) |
| `variant3d/tests/t_terrain_only.gd:42-86,144-236,256-315,384-642` | landed P0 atom: stub shape, result shape, `check()`/`_verdict()`, windowed SubViewport readback, PNG metrics, deferred quit |
| `variant3d/tests/t_terrain3d.gd:12-14,37-46,161-204` | `extends SceneTree`, dynamic `load()`, no `class_name`, `call_deferred("quit", …)` |
| `variant3d/tests/fixtures/_smallmap_harness.gd:14-40,117-180` | observed present at authoring time: `make_stub_game`/`count_categories`/`write_result`, `height_at`, `resolve_mine_sid`, `cmd_*` counters |
| `variant3d/tests/t_entities3d.gd:135-140,171-203` | resource-node dictionary shape and `bind`/`add_resource`/`sync` call order |
| `variant3d/scripts/world3d_entities.gd:114-118,1269-1315,164-166,986-1015,1060-1079,1334-1427` | donor sid pools, `POOL_TREE` resolution, `Batch_res_*` naming, CPU xform mirror, `height_at` for Y |
| `variant3d/scripts/world3d_terrain.gd:93-95,623-874,528-544,887-903` | 1 mesh / 4,096 verts / 7,938 tris / 4,096 UV2, `WATER_LEVEL=-0.25`, `stats.water.height_aware`, one renamed `WaterPlane`, `height_at_world` |
| `variant3d/scripts/water3d.gd:248-264` | `bind_height_grid()` sets `stats.height_aware=true` (called by terrain module at `world3d_terrain.gd:538`) |
| `variant3d/tests/t_terrain_shore.gd:303-350,812-831` + `reports/TEST_P2_report.md:55-66` | landed P2 fixture recipe and shore-id assertion, mirrored by C1 |
| `variant3d/tests/t_terrain_trees.gd` + `reports/TEST_P1_report.md:71-75` | landed P1 tree shape and its central-band cell choice (C1 relocates trees outside the basin — see §6) |
| `variant3d/assets/terrain/structs/tileblocks.json:87-98,29,32,33` | real tileblock indices: sandrock1..6=87..92, sandsea1/5/6=93/97/98, rock4/7/8=29/32/33 (no invented id) |
| `variant3d/scripts/game.gd:16,52,1735,1893-1907` | `TILE=2.0`, `BLK_WATER=255`, 8×45° sector rule, SIM-metre `height_at` recipe |
| `variant3d/scripts/main.gd:1144,1156-1158,1790-1800,1846-1853` | terrain=3 is water; headless has no 3D capture; blank capture is a loud failure |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` | non-black / dark-row metric mirror; stderr scan is external-only |
| `variant3d/tests/README.md:3-33` | deferred-quit rule |
| `docs/COMMANDS.md:11-41,53-58,123-124` | FIFO runner monopoly, one Godot at a time, no mid-run resize |

**P1/P2 status (observed):** `SWARM_BOARD.md:72-76` initially listed
`t_terrain_trees.gd` / `t_terrain_shore.gd` as RUNNING; both atoms and their
reports (`TEST_P1_report.md`, `TEST_P2_report.md`) landed while this task was
in progress. Per the task instruction the **TEST-01 row specs (`:212-214`)**
remain authoritative; the landed P2 fixture recipe was adopted verbatim for
C1's shore layer, but this atom does not import, load or depend on those files.
Their reports describe designs, not executed results — no parent verdict is
inherited by this atom.

## 3. What the atom builds (derived, not executed)

- `extends SceneTree` (`t_terrain3d.gd:12-14`); all exits via
  `call_deferred("quit", 0 if _ok else 1)` (`tests/README.md:3-33`); a deferred
  `_failsafe()` reports a clean FAIL instead of hanging if `_initialize()` aborts.
- **64×64 / 4,096-cell** synthetic in-memory fixture (`TEST-01:169-173`), no
  `small_map_64.json` real boot, no `main.tscn`, no `world3d.gd`, no FX, no
  picking. Three modules only: `world3d_terrain.gd`, `world3d_entities.gd`,
  `camera3d.gd`, all via `load()` (Blocker 10 at `TEST-01:299-301`).
- **P0 base:** mild relief (`1.5 ± 0.05 m`, neighbour delta ≪ donor `cDiff1=0.5`
  at `world3d_terrain.gd:117-118`) and all-grass tileblock id 0. The flat-grid
  promotion regression is re-probed with `_face_mode_at()` exactly as in
  `t_smallmap_terrain.gd:150-171` / P0.
- **P2 shore (mirrors the landed P2 atom):** basin centred on cell (31.5,31.5)
  with `r<3` cells at height −0.55 m and tile id `BLK_WATER=255` (≈28 cells,
  well below the 10 % bound); wet sandsea band `3≤r<3.8` at −0.18 m with
  `sandsea1/5/6 = 93/97/98` chosen by the 8×45° sector table
  (`game.gd:1735`; `t_terrain_shore.gd:74,308-337`); `sandrock1..6 = 87..92`
  band `3.8≤r<4.7`; a `rock4=29` sector at `4.7≤r<5.4`; dry grass elsewhere.
  Tile indices come from `tileblocks.json:87-98,29,32,33`, **not invented**.
  Basin cells are also tagged `terrain=3` (`main.gd:1144`). These dimensions
  are **synthetic fixture geometry shared with P2, not recovered donor
  literals**; the port literals actually asserted (`WATER_LEVEL=-0.25`, atlas
  `(16,8)`, `BLK_WATER=255`) are cited in-file.
- **P1 trees:** exactly `TREE_COUNT=20` wood resource dictionaries on two
  deterministic rows (`z=20` and `z=44`, `x=18…45`) — at least 12.5 tiles from
  the basin centre, outside the radius-5.4 collar. Each uses the visible
  resource shape of `t_entities3d.gd:135-140` (`hits=max_hits=60`), is fed
  through `world3d_entities.add_resource()` (`world3d_entities.gd:1294-1315`)
  and gets its transform from one `sync(0.0)` pass (`:1334-1427`). C1
  **deliberately relocates** these trees relative to P1's central band
  (`TEST_P1_report.md:74-75`, cells x,z∈[24,39]) because that band overlaps the
  basin and would violate C1's "trees never below water level" assertion.
- **Shared helper with embedded fallback:** `_smallmap_harness.gd` is loaded
  dynamically when present (it was present at authoring time); if absent, a
  local `LocalStubGame extends C3Game` with the same surface is used. The active
  source is recorded as `harness_source` in the result JSON (`"shared:…"` vs
  `"embedded_local_stub"`), so no fallback is silent. `count_categories()` uses
  the helper when available, otherwise a local mirror of
  `_smallmap_harness.gd:151-163`.
- **P0 baseline:** P0's exact expected mesh counts are asserted
  unconditionally. If `res://tests/results/t_terrain_only.json` exists, its
  `measured` counts are copied into `measured.p0_baseline` as **informational
  evidence only** — the verdict never depends on a parallel row's result file,
  so this atom can be run first without a false failure.

## 4. Assertions and their citations

All 28 checks are emitted in a fixed order (`CHECK_NAMES`) with
`name/status/detail` entries and are written to
`res://tests/results/t_combo_trees_shore.json`. Only an explicit `false` flips
the structural verdict; `null` means SKIPPED (headless capture).

| Check | Expected | Source / rationale |
|---|---|---|
| `harness_stub_shape` | MAP=64×64, `height`/`tileblock` arrays, 20 `res_nodes` | `_smallmap_harness.gd:134-149`; `t_terrain3d.gd:41-46` |
| `terrain_module_api`, `entities_module_api`, `camera_module_api` | required methods present | `t_terrain3d.gd:180`; `t_entities3d.gd:171`; `t_terrain_only.gd:429-452` |
| `build_ok` | `world3d_terrain.build()` returns true | `world3d_terrain.gd:624-637` |
| `surface_count`, `vertex_count`, `triangle_count`, `uv2_count` | 1 / 4,096 / 7,938 / 4,096 | TEST-01 P0 `:212`; `world3d_terrain.gd:664-729`; `TERRAIN_SMALL_maps.md:101-121` |
| `uv2_y_face_modes`, `flat_grid_promoted` | y∈{0,1,2}; flat-grid promotions=0 | `world3d_terrain.gd:691-708`; `t_smallmap_terrain.gd:150-171,292-318` |
| `atlas_grid_manifest`, `atlas_material_bound`, `shader_shadow_disabled` | (16,8); 3 samplers; `shadow_enabled=0` | V3D_02 T0 `:144`; `t_smallmap_terrain.gd:353-384` |
| `p0_mesh_counts_unchanged` | composite of the four mesh counts above vs P0 | TEST-01 C1/P1 `:213,216`; optional baseline at P0 result JSON (informational) |
| `tree_res_nodes_exact`, `tree_category_purity` | 20 wood; stone/mine/food = 0 | TEST-01 P1 `:213` "tree count and category purity exact"; `_smallmap_harness.gd:151-163` |
| `tree_batch_instances_exact` | sum of `Batch_res_*` instances = 20; every res sid ∈ `POOL_TREE` | `world3d_entities.gd:114-115,966,986-1015`; V3D_02 T1 `:145` |
| `tree_y_on_terrain` | max abs(instance.y − `game.height_at(pos)`) ≤ 1e-4 m | V3D_02 T1 `:145`; `world3d_entities.gd:1060-1079,1413-1427`; CPU mirror at `:977-981` |
| `trees_not_below_water` | min tree y > −0.25 m (fixture rows also outside collar) | TEST-01 C1 `:216`; `world3d_terrain.gd:95` |
| `no_mines_added` | zero ore res nodes and zero non-tree res sids | task "NO mines"; TEST-01 P3/P2 isolation `:214-215`; `world3d_entities.gd:1275-1278` |
| `water_cells_bounded` | 0 < cells with height < −0.25 < 409 (=10 % of 4,096) | TEST-01 P2 `:214`; `world3d_terrain.gd:95` |
| `water_plane_single_height_aware` | exactly 1 `WaterPlane` + 1 `Water3D`; `stats.water.height_aware=true`; module `water3d.gd` | TEST-01 P2 `:214`; `t_smallmap_terrain.gd:400-414`; `world3d_terrain.gd:528-544,841-848` |
| `shore_ids_in_uv2_hist` | UV2.x histogram contains at least one sandsea id (93/97/98) and at least one sandrock/rock id (87–92 or 29/32/33) | V3D_02 T2 `:146`; `t_terrain_shore.gd:812-831`; `tileblocks.json:87-98,29,32,33` |
| `capture_image`, `capture_saved` | windowed `SubViewport` texture non-blank; `save_png()` OK | TEST-01 `:193-197,247-253`; `terrain3d_sandbox.gd:139-151`; `testbridge.gd:277-308` |
| `non_black_fraction` | >0.9 | P0 `:212`; `smallmap_capture.py:21-26` |
| `full_width_dark_rows` | 0 | TEST-01 P2 `:214`; V3D_02 T2/F6 `:146,129`; `smallmap_capture.py:27-28` |

**Headless guard:** `DisplayServer.get_name() == "headless"` switches the atom
to state-only mode; the last four capture checks are emitted as `SKIPPED`
(JSON `null`) and the verdict is `SKIP_CAPTURE`, never PASS
(`t_forest_bake_render.gd:35-41`, `main.gd:1156-1158,1790-1800`). A blank GPU
texture is a hard failure with no CPU fallback (`main.gd:1846-1853`).
**Result JSON:** id, `passed`, `verdict`, `capture_status`, `structural_ok`,
pass/fail/skip totals, all checks, `measured` (counts, histograms, tree Y error,
water stats, PNG metrics), `harness_source`, `png_path`, `skip_reason`,
`script_error_note`, `parity_label`, `unix_ms` — mirroring
`_template_test.gd:6,17-31` and P0 `t_terrain_only.gd:203-236`.

## 5. Expected pre-fix failure modes (derived — not observed, no runs)

These are the defects each assertion is designed to expose; none is claimed to
be present or absent in the current tree.

1. **Missing/incorrect height-aware water binding** — if
   `bind_height_grid()` is not called (`water3d.gd:248-264`,
   `world3d_terrain.gd:538`) or a second/constant water quad is stacked,
   `water_plane_single_height_aware` fails (plane count ≠ 1 or
   `height_aware=false`). This is the classic pre-F6 regression (V3D_02 `:129`).
2. **Full-width dark band** — a neutral height texture or wrong `coast_fade`
   renders a dark stripe across the whole viewport; `full_width_dark_rows`
   fails, exactly the V3D_02 P6/F6 symptom (`:129,146`) and TEST-01 P2's
   "localized band only" requirement (`:214`).
3. **Tree Y detached from terrain** — if `world3d_entities._world_pos()`
   (`world3d_entities.gd:1060-1079`) stops consulting `game.height_at()`, or the
   stub lacks that method, `tree_y_on_terrain` fails with a non-zero error;
   if a tree lands in the basin, `trees_not_below_water` fails too.
4. **Category leakage / wrong batch key** — if `add_resource()` resolves a
   stone/ore/stump/field sid, `tree_batch_instances_exact` (sid filter) and
   `no_mines_added` fail even when `res_nodes` still looks "wood-only".
5. **Tile-index loss** — if `tileblock` decoding is skipped or ids are clamped
   to 0 (V7-86 PORT GUARD at `world3d_terrain.gd:697-702`), the sandsea/sandrock
   ids disappear from UV2.x and `shore_ids_in_uv2_hist` fails.
6. **Water-cell miscount** — if the basin height is overwritten or the
   water-level literal drifts, `water_cells_bounded` fails (0 cells or ≥10 %).
7. **P0 regression from the union** — adding entities or water must not change
   the single terrain mesh; a second surface, chunk fallback or re-meshing
   fails `surface_count`/`vertex_count`/`triangle_count`/`uv2_count` and
   `p0_mesh_counts_unchanged`.
8. **Headless false green** — without the headless guard a headless run would
   capture nothing; this atom reports `SKIP_CAPTURE` instead.

## 6. Open questions

1. The P1/P2 atoms and reports landed mid-task. C1 now reuses P2's basin
   recipe exactly but **not** P1's tree cells (P1's central band overlaps the
   basin). Both parent atoms remain single-layer by design, so "no regression
   vs either parent" cannot be a byte-for-byte image comparison — it is a
   structural-count comparison on a common map. The ladder still needs one
   agreed fixture recipe (TEST-01 §"Scaffolding" item 1, `:230-239`).
2. Should the two frame-differenced water-animation check from V3D_02 T2
   (`V3D_02:146`, "two frames 1 s apart show a non-zero water-only pixel
   delta") be added to C1? It is deliberately **not** implemented here: this
   atom captures once after ~10 frames, and a 1 s second frame would change the
   harness timing for every combo row.
3. `height_at_world()` (`world3d_terrain.gd:887-903`) is asserted only for API
   presence in this atom; tree Y is checked against the **stub game's**
   `height_at()` because that is what `world3d_entities._world_pos()` actually
   consumes. Whether those two samplers agree at every tree cell is not yet
   measured.
4. The shared helper's `StubGame extends Node` while the embedded fallback
   `extends C3Game`; typed `bind()` calls work either way, but a future helper
   change may make the two stubs diverge. `harness_source` makes that visible
   in the result JSON.
5. `full_width_dark_rows=0` is a pixel proxy, not a visual verdict. The second
   agent re-check required by `TEST_MATRIX.md:58` has not happened.
6. No donor GPU A/B frame exists (`V3D_02:14`, `TEST_MATRIX.md:56`); all visual
   statements remain `PORT APPROX` / `UNVERIFIED` and donor parity is not
   claimed.

## 7. How this atom is meant to be run (NOT run by this agent)

Per `TEST-01:188-197` and `docs/COMMANDS.md:53-58`, a **different owner** would
take one FIFO ticket and launch, from the repo root with Windows `python`
(never `python3`):

```
python variant3d\tools\godot_runner.py run --id <ticket>-C1 --timeout 60 -- --path variant3d --script res://tests/t_combo_trees_shore.gd -- --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/smallmap64_combo_trees_shore.png
```

Omit `--screenshot` and add `--headless` for the state-only variant. Then, and
only then, read
`variant3d/tests/results/t_combo_trees_shore.json` and run the **read-only**
`python variant3d\tools\smallmap_capture.py stats <png>` and `scan-stderr
<runner stderr.txt>` (`smallmap_capture.py:21-39,50-58`). Registration in
`manifest.json` and the final-gate ladder remain separate integration work
(`TEST-01:257-267`); this report changes neither.

## 8. Summary

- **Observed:** the C1 row spec, the landed P0 atom, the shared helper, the
  three module APIs, the atlas preset indices and the capture/metric tools were
  all read; exactly two new files were written.
- **Derived:** one 64² stub can assert tree exactness/purity/Y, bounded water,
  a single height-aware plane, shore ids in UV2, unchanged P0 mesh counts and
  zero full-width dark rows in a single atom.
- **Unverified / not claimed:** no Godot job was submitted, no capture exists,
  no check has executed, and no PASS verdict is asserted by this report.
