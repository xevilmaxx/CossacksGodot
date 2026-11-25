---
id: TEST-C3
title: "C3 combo shore+mines 64² atom — authoring report"
owner: TEST-C3 (test-authoring micro-worker)
date: 2026-11-25
status: AUTHORING_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "Exactly two new files: the C3 atom and this report. No source/shader/asset/config/manifest/fixture/gate-file/git edit; no Godot launch, no queue ticket, no capture or PNG readback executed."
owns:
  - "variant3d/tests/t_combo_shore_mines.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_C3_report.md"
labels: [COMBO, SHORE_PLUS_MINES, 64X64, STUB_UNION, WINDOWED_SUBVIEWPORT, SKIP_CAPTURE_GUARD]
evidence_labels: [observed, derived, inferred]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:24,29-46,53-58"
verdict: "NOT RUN — structural checks expected to evaluate by design; visual UNVERIFIED; no donor parity claim; no PASS claimed"
---

# TEST-C3 — combo shore + mines 64² atom (authoring report)

## 0. No-runner declaration

This was an **authoring-only** pass. No Godot process was started, no
`godot_runner.py` ticket was taken, no `--script` launch was made, no PNG was
captured or read back, and no donor file was opened or executed. **Nothing was
run, therefore this report claims no PASS, no FAIL and no measured value.**
Every number below is either a citation of an existing document (`observed`) or
arithmetic on cited constants (`derived`). Per `TEST_MATRIX.md:58`, no piece is
a PASS until a second agent re-checks its capture; that has not happened.

## 1. Goal

Author **one** new `extends SceneTree` atom that asserts the **P2 + P3 union**
on the ladder's common 64×64 map: a bounded water basin with sandsea shore ids,
plus gold/iron/coal ore nodes at known land positions, with **no trees**. It
must assert both parents' invariants at once — water cells `>0` and `<10 %`
of the grid, exactly one height-aware `WaterPlane`, shore ids present, zero
full-width dark rows, every ore position above `WATER_LEVEL`, exact ore counts
and category purity — while the P0 terrain mesh counts stay unchanged. It
captures its own windowed `SubViewport` PNG and writes a self-contained result
JSON with a deferred quit.

## 2. Sources (all read-only this pass)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:218` | C3 row: "P2 + P3 union; water cells + ore counts; every ore position has height > WATER_LEVEL; one water plane; mines not in water; shore masking unchanged" |
| `TEST_01_smallmap_harness.md:169-173,183-226` | one common 64² map; two non-mixable capture variants; stub rows own their PNG via `SubViewport`; time estimates 10–15 s |
| `TEST_01_smallmap_harness.md:228-255,269-305` | shared helper API (`make_stub_game`, `count_categories`, `write_result`), windowed capture pattern, headless guard, result cross-check; blockers (no category flag, no headless 3D PNG, FIFO + `_initialize()` quit trap, class-name cache) |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,20-25,29-46,53-58` | same-map rule; C3 row; V3D_02 refinement: bounded water basin, shore ids in UV2, ONE height-aware plane, no full-width dark rows, mine sid resolves, ground unchanged outside mine bbox; runner/parity/re-check rules |
| `docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:134-153` | T2/T3/T4 rows: "exactly one water plane (`WaterPlane`), `height_aware=true`, shore ids in UV2.x histogram, full-width dark rows = 0"; "mine sid resolves, mine Y matches terrain"; "no stacked water planes"; 4,096 verts / 7,938 tris / 4,096 UV2 / atlas (16,8) / shadow OFF baseline at `:140,144` |
| `docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md:100-134,466-488` | claim table C23/C27/C30/C31; §6.1 S1/S4/S5 and M1–M9: one height-aware plane, mesh unchanged, sandsea ids in UV2, M5 "0 full-width dark/green rows" |
| `DTRN_03_donor_shore_water.md:393-401,425-448` | W2 water cells clamped to tile 0 (`grass1`) under near-zero alpha; W7 shore ids only on land strip; F2 substrate fix, F8 never stack two planes — all treated as **known/UNVERIFIED**, not fixed by this atom |
| `variant3d/tests/_template_test.gd:1-38` | one feature per file, result JSON, `call_deferred("quit", …)`, never direct `quit()` in `_initialize()` |
| `variant3d/tests/t_terrain3d.gd:12-14,41-46,106-127,161-204` | SceneTree main loop, dynamic `load()` (no `class_name`), stub shape, base64 dump, defer-quit |
| `variant3d/tests/t_pick3d.gd:48-71,73-145` | stub fields (`res_nodes`, `res_dirty`, `entities`, `pick_radius`, `height_at`, `resolve_mine_sid`, empty `cmd_*` counters) |
| `variant3d/tests/t_smallmap_terrain.gd:42-99,150-171,292-339,400-414` | arg parsing after the second `--`, flat-promotion probe, mesh/UV2/atlas assertions, water module readback pattern |
| `variant3d/tests/t_terrain_only.gd:44-162,256-315,351-382,596-642` (sibling P0) | exact stub/verdict/PNG-metric pattern this atom mirrors; P0 does **not** hide water here (C3 measures it) |
| `variant3d/tests/fixtures/_smallmap_harness.gd:14-114,117-180` | observed **present on disk** at authoring time: `StubGame`, `height_at`, `resolve_mine_sid(sid,pos)`, factories, `count_categories`, `write_result`; loaded dynamically anyway |
| `variant3d/scripts/world3d_terrain.gd:95,451-488,523-545,680-708,721-764,841-848` | `WATER_LEVEL=-0.25`; tileblock decode; water module renamed `WaterPlane`; UV2.x=tile id / UV2.y=face mode; clamp of out-of-atlas ids to 0; `stats.water.height_aware` |
| `variant3d/scripts/water3d.gd:19,148-168,200-219` | donor literals, plane build, `stats.module` / `height_aware` |
| `variant3d/scripts/world3d_entities.gd:10-11,113-118,205-270,966-1014,1060-1093,1269-1315,1528-1552` | public API; `ENV_SCALE.mine=0.3152`; `_resource_sid("gold"/"iron"/"coal")->"mine_<ty>"`; batch node names `Batch_res_mine_*`; `visible_instance_count`; `_is_hidden` rule (`max_hits=0` stays visible); `stats.resources/units/buildings` |
| `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:2283-2284,2379-2380,2403-2404` | donor atlas indices `sandsea1=93`, `sandsea5=97`, `sandsea6=98` — **not invented constants** |
| `variant3d/assets/terrain/structs/presets_summer.json:95,99,100`; `variant3d/scripts/game.gd:52,1735-1736` | grass id 0; `BLK_WATER=255`; `SECTOR_TILES` 8×45° order used for the synthetic collar |
| `variant3d/scripts/main.gd:1156-1158,1790-1800,1846-1853`; `variant3d/scripts/testbridge.gd:277-308`; `variant3d/scripts/terrain3d_sandbox.gd:139-151` | headless cannot capture 3D; stub-owned `UPDATE_ONCE` + `frame_post_draw` readback; blank frame is a loud failure, never a CPU fallback |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` (READ-ONLY) | exact PNG metrics mirrored in GDScript; external stderr `SCRIPT ERROR` scan (GDScript cannot read stderr) |

## 3. What was authored

`variant3d/tests/t_combo_shore_mines.gd` — a single self-exiting atom:

1. **SceneTree + dynamic loads.** `world3d_terrain.gd`, `camera3d.gd`,
   `world3d_entities.gd` and the shared `_smallmap_harness.gd` are all reached
   with `load()`; no `class_name` dependency (TEST-01 Blocker 10). The helper
   was present on disk when authored, but a same-shape `LocalStubGame` is
   embedded and used if it is absent; `harness_source` in the result JSON
   records which path was taken.
2. **Deterministic in-memory 64² fixture.** Height is `1.5 + small sin/cos`
   outside the basin. Inside radius 7 tiles about `(20,20)` the height is
   `-0.55 m` (below `WATER_LEVEL`), giving **149 water cells = 3.6377 %** of
   4,096 (`derived` from `π·7²` lattice count, verified by plain Python
   arithmetic only — no Godot). A land-side collar out to radius 10 rises from
   `-0.25` to `-0.10` (the 0.15-unit wet band of DTRN-03 C05) and is painted
   with donor `sandsea1/5/6` atlas ids selected by the 8×45° sector table.
   A gentle ramp returns to baseline by radius 24. `tileblock=255` on water
   cells; grass id 0 elsewhere. **No fixture JSON is read** and the real-boot
   `small_map_64.json` path is deliberately not used (that is the S1 row).
3. **Ore fixture.** Six permanent ore nodes (`max_hits=0`, so visible per
   `_is_hidden`), 2 gold / 2 iron / 2 coal, at explicit grid cells
   `(6,6),(50,10),(10,52),(54,54),(4,40),(58,28)` — all far outside the basin,
   hence all above water. No wood/stone/food nodes, no units, no buildings.
4. **Module bind order.** Terrain → `build()`, real `camera3d.gd` with
   `_process()` disabled after bind, then `world3d_entities.bind(game)` →
   `add_resource()` for each ore → one `sync(0.016)` to populate stats. No
   `world3d.gd`, picking, FX, HUD or `main.tscn` boot. Unlike P0, the
   `WaterPlane` is **not** hidden: shore is a measured layer.
5. **Windowed capture.** Headless runs stay state-only (`SKIP_CAPTURE`).
   Windowed runs create a private 1,280×720 `SubViewport` with a fresh
   `World3D`, wait 10 frames, `await RenderingServer.frame_post_draw`, read
   `get_texture().get_image()`, and `save_png(<user-arg --screenshot/--png>)`.
6. **Result + exit.** `res://tests/results/t_combo_shore_mines.json` carries
   `passed`, `verdict`, `capture_status`, `structural_ok`, per-check status,
   full `measured` dictionary, `harness_source`, `png_path`, `skip_reason`,
   `script_error_note`, `parity_label`, `unix_ms`. Every exit is
   `call_deferred("quit", …)`; `_failsafe()` becomes inert once setup is done.

## 4. Exact assertions (and their citations)

| Check | Assertion | Citation / basis |
|---|---|---|
| `harness_stub_shape` | stub exposes `MAP_W/MAP_H = 64/64`, `height: PackedFloat32Array`, `tileblock: PackedByteArray`, six `res_nodes` | TEST-01.md:230-239; helper `:134-149`; `t_terrain3d.gd:119-127` |
| `terrain_module_api` | `bind/build/invalidate/has_chunk_or_fallback/height_at_world` present | `t_terrain3d.gd:180-189` |
| `camera_module_api` | `bind/world_to_px/screen_to_world/set_zoom_target` present | sibling `t_terrain_only.gd:441-452` |
| `entities_module_api` | `bind/sync/add_resource/remove` present | `world3d_entities.gd:10-11,205,1294,1334` |
| `build_ok` | `world3d_terrain.build()` returns true | `world3d_terrain.gd:624-874` |
| `p0_mesh_counts_unchanged` | 1 surface / 4,096 verts / 7,938 tris / 4,096 UV2 — **combo may not alter P0 geometry** | TEST_MATRIX.md:33-34; TEST-01.md:148-154,212; V3D_02:140,144; `world3d_terrain.gd:680-719` |
| `water_cells_bounded` | cells with `height < −0.25`: **>0 and <10 %** of 4,096 (fixture yields 149 / 3.64 %) | TEST-01.md:214 (P2); TEST_MATRIX.md:20,42; `world3d_terrain.gd:95` |
| `single_height_aware_water_plane` | exactly one `WaterPlane` node, one `Water3D` node, `stats.water.module` ends `water3d.gd`, `stats.water.height_aware == true` — **no stacked surfaces** | DTRN-03:470 (S1); V3D_02:146; TEST_MATRIX.md:42; `world3d_terrain.gd:523-545,841-848` |
| `shore_ids_present` | UV2.x histogram contains `sandsea1/5/6` (atlas ids 93/97/98); `out_of_atlas == 0` | DTRN-03:474 (S5); V3D_02:146; atlas manifest `:2283/2379/2403`; `game.gd:1735-1736`; `world3d_terrain.gd:691-708` |
| `ore_height_above_water` | every ore cell has `height > WATER_LEVEL` (`ore_below_water == 0`) — **the C3-specific "mines not in water" invariant** | TEST-01.md:218; TEST_MATRIX.md:24; `world3d_terrain.gd:95` |
| `ore_counts_exact` | `Batch_res_mine_gold/iron/coal` instances are 2/2/2; `stats.resources == 6`, `stats.units == 0`, `stats.buildings == 0` | V3D_02:147; `world3d_entities.gd:966,961,1014,1528-1552` |
| `ore_category_purity` | input `wood/stone/food == 0`, `mine == 6`; **and** no foreign `Batch_res_*` node (no tree/stone/food/field batch) | TEST-01.md:215 (P3); `world3d_entities.gd:1269-1283,1082-1091` |
| `capture_image` | windowed `SubViewport` texture is non-blank | `main.gd:1846-1853`; `testbridge.gd:277-308` |
| `capture_saved` | `save_png(<abs path>) == OK`, path from `--screenshot` (alias `--png`) | TEST-01.md:192-197; `t_smallmap_terrain.gd:93-99` |
| `non_black_fraction` | `> 0.9` (any RGB channel `> 8`) | V3D_02:144; `smallmap_capture.py:26` |
| `full_width_dark_rows` | `== 0`; a row is dark when `>90 %` of pixels have luma `<20` (`0.2126R+0.7152G+0.0722B`) | V3D_02:146; DTRN-03:484 (M5); `smallmap_capture.py:25-28` |

The two PNG checks are evaluated **only** in the windowed path. Structural
checks run in headless mode, but the result verdict is `SKIP_CAPTURE` (not
`PASS`) unless the PNG was actually read back. On an early setup abort the four
capture checks are written as `UNVERIFIED` (status + JSON null), never as a
measured FAIL, matching the sibling P2 pattern (`t_terrain_shore.gd:104-107`).
`script_error_note` requires the
external `smallmap_capture.py scan-stderr <runner stderr.txt>` check; GDScript
cannot inspect stderr (TEST-01.md:273-276).

Informational measurements recorded but **not** asserted as donor parity:
`water_tileblock_cells` (BLK_WATER count), UV2 tile-0 histogram, per-id shore
histogram, `uv2_x_min/max`, ore heights per cell, `entities_stats`, PNG bytes
and mean luma. In particular the atom does **not** claim the known W2 defect
(water cells clamped to `grass1` under near-zero alpha, DTRN-03:396) is fixed.

## 5. Expected pre-fix failures (hypothetical — nothing was run)

These are the failure modes the row is designed to expose; none was observed.

| Failure mode | Check expected to fail | Why |
|---|---|---|
| Two water surfaces built (stacked planes) | `single_height_aware_water_plane` | TEST_MATRIX.md:42 and V3D_02:148 require exactly one; DTRN-03 §5 F8 says never add a second plane |
| A mine placed in / sunk by the basin, or wrong `height_at` mapping | `ore_height_above_water` | TEST-01.md:218 and TEST_MATRIX.md:24 define C3 as "mines not in water" |
| Shore ids lost when ore stamping overwrites the tileblock | `shore_ids_present` | DTRN-03:474 (S5); V3D_02:146 |
| A wet-sand/dark substrate applied to every row instead of the bounded basin | `full_width_dark_rows` | DTRN-03:484 (M5) wants a localized band only; `smallmap_capture.py:27-28` defines the row test |
| Combo changes terrain geometry | `p0_mesh_counts_unchanged` | C3 must be a union, not a rewrite (TEST-01.md:216-219) |
| Tree/stone/food meshes leak into the combo | `ore_counts_exact` / `ore_category_purity` | TEST-01.md:215 and V3D_02:147 want ore-only resource meshes |

**Explicit non-failure:** before the F1/F2 shore fixes the grass-under-water
artifact (DTRN-03 W2) can still be present; this atom records it informationally
and does **not** assert it away. Likewise donor visual parity cannot fail or
pass here because no donor A/B frame exists (`TEST_MATRIX.md:56-58`,
`DTRN_03` §7).

## 6. Open questions

1. **Parent atoms not yet landed.** At authoring time neither `t_terrain_shore.gd`
   (P2) nor `t_terrain_mines.gd` (P3) existed, so C3 duplicates their setup
   instead of loading their atoms or result JSONs. If they land later, should
   C3 delegate to them (risk: two result files) or stay self-contained?
   **Unresolved**; self-contained chosen for isolation.
2. **Shared helper was present**, unlike the P0 authoring moment. The embedded
   fallback is retained for the absent-file case; no atom edits the helper
   (single owner, TEST-01.md:230-239).
3. **Basin rim face promotion.** The jump from `-0.55` to `-0.25` at radius 7
   is ~0.3 m, individually below the donor `cDiff1=0.5` threshold
   (`world3d_terrain.gd:117-118`), but its combination with the land-side ramp
   and the `sin/cos` baseline could still promote face modes at the rim. The
   atom records the UV2.x histogram and out-of-atlas count but does **not**
   assert `UV2.y == 0`; a second agent should eyeball the PNG seam there.
4. **Mine Y vs terrain** (V3D_02:147) is *not* asserted: in headless Godot the
   dummy `RenderingServer` returns identity `MultiMesh` transforms
   (`world3d_entities.gd:977-979`). A windowed second-agent review can verify
   it visually; a CPU-mirror assertion would require touching shared code.
5. **Water surface Y, `hmapTex` binding, reflection FBO** stay UNVERIFIED
   (DTRN-03 §7). Pixel metrics here are internal consistency, not donor
   measurements.
6. **Runtime args.** A windowed launch must pass an absolute `--screenshot
   <png>` user arg; without it the atom self-fails `capture_image` by design.
   Headless runs intentionally return `SKIP_CAPTURE`.
7. **Cost.** Estimated 10–15 s of runner time (TEST-01.md:205-208), excluding
   the serialized FIFO wait; not measured by this agent.

## 7. Summary

- **Observed:** TEST-01's C3 row, TEST_MATRIX's C3/T2/T3/T4 criteria, the
  shared harness helper, the sibling P0 atom, and the three module contracts
  were read directly; all citeable constants (tile ids, `WATER_LEVEL`, batch
  naming, PNG metric definitions) came from those files.
- **Derived:** a synthetic bounded 149-cell basin plus six land ore nodes
  simultaneously exercises both parents on the common 64² map; the exact
  instance counts are read from the batches the entities module actually
  builds, not from the input list alone.
- **Inferred / UNVERIFIED:** no capture was taken, no donor comparison exists,
  and no defect is claimed fixed. The report deliberately states **no PASS**.

*End of TEST-C3. Authoring only: exactly two files written; no Godot process,
no runner job, no donor access, no shared code change.*
