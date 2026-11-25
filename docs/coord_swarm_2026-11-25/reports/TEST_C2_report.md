---
id: TEST-C2
title: "C2 combo terrain+trees+mines 64² atom — authoring report"
owner: TEST-C2 (test-authoring micro-worker)
date: 2026-11-25
status: AUTHORING_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "Exactly two new files: the atom and this report. No source/shader/asset/config/manifest/fixture/gate-file/git edit; no Godot launch, no queue ticket, no capture or result JSON produced."
owns:
  - "variant3d/tests/t_combo_trees_mines.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_C2_report.md"
labels: [COMBO_LADDER, P1_PLUS_P3, ISOLATED_STUB, 64X64, WINDOWED_SUBVIEWPORT, SKIP_CAPTURE_GUARD]
evidence_labels: [observed, derived, inferred, unverified]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,19,21,23,29-46,53-58"
verdict: "NOT RUN — 32 checks authored; structural result expected by design; visual UNVERIFIED; no PASS and no donor-parity claim"
---

# TEST-C2 — combo terrain+trees+mines 64² atom (authoring report)

## Goal

Author **one** new `extends SceneTree` atom that asserts the P1 and P3
invariants *at the same time* on the ladder's common 64×64 synthetic map:
a P0-identical all-grass mild-relief terrain mesh, 20 donor-sid tree resource
nodes and 3 each of gold/iron/coal mine nodes at known, clearance-separated
positions, no water height/tile cells and no visible water plane, no units and
no buildings. It writes `res://tests/results/t_combo_trees_mines.json`, supports
a stub-owned windowed PNG readback, guards headless mode with a never-PASS
`SKIP_CAPTURE` verdict, and quits only via `call_deferred("quit", …)`.
**No test was run by this worker** — this is an authoring hand-off only.

## Sources (all read-only this pass)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:183-226` | §"Test ladder": C2 row (`:217`) = P1+P3 union, tree+ore counts, no water, ore/tree separation; P1 row (`:213`) and P3 row (`:215`) invariants; same-map ordering rule (`:223-226`) |
| `TEST_01_smallmap_harness.md:228-255` | §"Scaffolding needed": shared helper API, windowed stub-owned capture, headless guard, external stderr/PNG cross-check |
| `TEST_01_smallmap_harness.md:269-305,307-324` | Blockers 2/4/10 (headless cannot capture 3D; FIFO + `_initialize()` quit trap; dynamic `load()`), atom ownership table |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,19,21,23,29-46,53-58` | same-smallest-map rule; C2 row "no overlap/placement bugs"; V3D_02 T1 tree Y and T3 mine Y/sid; 4,096/7,938/4,096/atlas(16,8)/shadow-OFF baseline; "no piece PASS until second agent re-checks" |
| `reports/V3D_02_terrain_render_audit.md:134-153` | T1/T3/T4 rows: instance counts, "Y within tolerance of `height_at_world()`", mine sid resolves, all T0–T3 at once; `scan-stderr` requirement `:151-153` |
| `reports/DTRN_04_donor_trees.md:304-325` | P1 criteria T1/T2/T5: mesh non-regression, `Batch_*_res` count, N=20 as a **labelled stress case**, base-Y tolerance 1e-3 m |
| `SWARM_BOARD.md:23,66-79` | DTRN-04 port gaps (6 sids, scale 0.5, yaw 0); C2 ownership slot; AUTHORING-ONLY batch charter |
| `variant3d/tests/_template_test.gd:1-38` | one feature per file, result JSON shape, deferred quit, no direct quit in `_initialize()` |
| `variant3d/tests/t_terrain3d.gd:12-14,37-46,104-127,161-255` | `SceneTree` + dynamic `load()`, stub shape, base64 `dump`, defer-quit pattern |
| `variant3d/tests/t_pick3d.gd:48-71` | stub fields (`res_nodes`, `res_dirty`, `entities`, `height_at`, `resolve_mine_sid`) |
| `variant3d/tests/t_terrain_only.gd:1-42,44-143,256-294,384-642` (P0 atom, read-only) | P0 baseline checks copied unchanged; windowed SubViewport capture; headless `SKIP_CAPTURE`; result JSON fields |
| `reports/TEST_P0_report.md:74-107,109-141,176-190` | P0 assertion/verdict style and the harness-absence fallback precedent |
| `variant3d/tests/fixtures/_smallmap_harness.gd:5,12-78,108-161` (read-only, landed by the parallel owner during this pass) | actual shared-helper API: `make_stub_game(w,h,height,res_nodes,tileblock)`, `count_categories()`, `StubGame` shape incl. `resolve_mine_sid(sid,pos)` |
| `variant3d/scripts/world3d_entities.gd:113-118,164-165,205-309,966,986-1015,1060-1079,1085-1090,1094-1121,1269-1315,1529-1551` | donor sid pools, batch naming `Batch_<key>_<tag>`, CPU-mirror transform, `_resource_sid` `mine_<ty>`, visibility rule, `stats.resources` |
| `variant3d/scripts/world3d.gd:322-410` | real resource feed filter (`hits<=0 && max_hits!=0` skipped) mirrored when feeding the module |
| `variant3d/scripts/world3d_terrain.gd:93-95,117-118,664-719,762-764,883-903` | `WATER_LEVEL=-0.25`, `cDiff1`, mesh recipe, unconditional `WaterPlane`, `height_at_world()` contract |
| `variant3d/scripts/game.gd:16,19,52,61,149,508-520,1893-1907,2337-2358,2685-2702` | `TILE=2`, `MINE_SITE_RADIUS=4`, `BLK_WATER=255`, `res_nodes` shape, bilinear `height_at`, 10.5 m ore/wood ring, `resolve_mine_sid` |
| `variant3d/scripts/camera3d.gd:148-198,232-252,484-581` | real camera bind/framing; `_process()` edge-scroll disabled for a fixed frame |
| `variant3d/scripts/main.gd:1156-1193,1801-1862`; `scripts/terrain3d_sandbox.gd:139-151`; `scripts/testbridge.gd:277-308` | proven windowed `SubViewport` readback, no CPU fallback, `UPDATE_ONCE` + `frame_post_draw` |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` (READ-ONLY) | PNG metric definitions mirrored in GDScript; external `SCRIPT ERROR` scan |
| `variant3d/scripts/data.gd:23,113-115` | `TILE_M=2`, 1,280×720 window — no screenshot-resolution CLI flag |

## What was authored

`variant3d/tests/t_combo_trees_mines.gd` — one self-exiting atom, 32 named
checks (`CHECK_NAMES`, atom `:74-108`):

1. **SceneTree main loop**, all three game modules loaded dynamically with
   `load()` — terrain, entities, camera (`:44-46`, `:511-...`) — and the shared
   helper dynamically probed at `res://tests/fixtures/_smallmap_harness.gd`
   (`:50`, `:300-328`). No `class_name` reference (TEST-01 Blocker 10).
2. **In-memory 64² all-grass fixture** (`:259-273`): `height[i] = 1.5 +
   0.03·sin(0.11x) + 0.02·cos(0.09z)` (max axis delta ≈0.005 m ≪ `cDiff1=0.5`),
   `tileblock[i] = 0` (grass1), `terrain[]` all zero → no water cells. No
   `small_map_64.json` boot: this is a **stub row**, not the S1 real-boot row.
3. **Known positions** (`:275-298`): 20 wood nodes on a 5×4 lattice
   `x=12+28c (c=0..4), z=12+28r (r=0..3)`; 9 permanent ore nodes on a 3×3
   interstitial lattice `x=26+28c (c=0..2), z=26+28r (r=0..2)`, typed
   gold/iron/coal cyclically. Wood is finite (`hits=max_hits=3`, visible);
   ore is permanent (`hits=max_hits=0`, visible per
   `world3d_entities.gd:1085-1090` and `world3d.gd:399-401`). Nearest tree–ore
   distance is √14²+14² ≈ **19.8 m**, comfortably beyond the 10.5 m generator
   ring (`game.gd:2350-2351,2355-2356`). All coordinates are inside the 128 m
   map extent.
4. **Only terrain + real camera + entities module bound**: no `game.gd` setup,
   no `world3d.gd`, no FX/picking, no `main.tscn`. Camera `_process()` is
   disabled after `bind()` to prevent mouse edge-scroll. `WaterPlane`/
   `Water3D` nodes created by the terrain module are **hidden, not deleted**
   (`:364-381`), exactly as in P0 (`terrain3d_sandbox.gd:120-124`).
5. **Resource feed** mirrors the real feed's visibility filter
   (`world3d.gd:390-405`) before `add_resource()`; one `sync(0.0)` refreshes
   `stats.resources` (`world3d_entities.gd:1529-1551`).
6. **Windowed capture**: 1,280×720 private `SubViewport` with a fresh
   `World3D`, `UPDATE_ONCE`, 10 frames, `await RenderingServer.frame_post_draw`,
   `get_texture().get_image()`, `save_png(<--screenshot user arg>)`, no
   `.raw.png` and no main-owned saver (`:807-855`). Blank texture is a loud
   failure, never a CPU fallback.
7. **Result**: `res://tests/results/t_combo_trees_mines.json` with `id`,
   `passed`, `verdict`, `capture_status`, `structural_ok`, per-check `status`,
   full `measured` telemetry (mesh counts, UV2 hist, promotion count, water
   counts, node/instance type histograms, worst Y error, minimum separation,
   PNG metrics), `harness_source`, `png_path`, `skip_reason`,
   `script_error_note`, `parity_label`, `unix_ms`. Every exit is
   `call_deferred("quit", 0 or 1)` from `finish()` (`:197-241`); a `_failsafe()`
   deferred at setup start goes inert once setup completes (`:243-248`).

## Exact assertions (and their citations)

| Check (atom `:74-108`) | Assertion | Citation / basis |
|---|---|---|
| `harness_stub_shape` | stub exposes `MAP_W/MAP_H=64/64`, `height: PackedFloat32Array`, `tileblock: PackedByteArray`, `res_nodes.size()==29` | TEST-01.md:230-239; `t_terrain3d.gd:119-127`; `t_pick3d.gd:53-62` |
| `terrain_module_api` | `bind/build/invalidate/has_chunk_or_fallback/height_at_world` present | `t_terrain3d.gd:180-189` |
| `entities_module_api` | `bind/sync/add_resource/remove` present | `world3d_entities.gd:255-256` |
| `camera_module_api` | `bind/world_to_px/screen_to_world/set_zoom_target` present | `camera3d.gd:6-10,148,258,266,606` |
| `build_ok` | `world3d_terrain.build()` returns `true` | `world3d_terrain.gd:624-874`; `t_terrain3d.gd:197-204` |
| `entities_bind_ok` | all 29 visible nodes reach `add_resource()` under the real feed filter | `world3d.gd:390-405`; `world3d_entities.gd:1294-1315` |
| `surface_count` | terrain mesh has exactly 1 surface | TEST-01.md:212; V3D_02 T0:144; `world3d_terrain.gd:728-729` |
| `vertex_count` | 4,096 vertices (`64²`) | TEST-01.md:148-154; `world3d_terrain.gd:666,685-687` |
| `triangle_count` | 7,938 triangles (`(64−1)²·2`) | TEST-01.md:151; `world3d_terrain.gd:667,710-719` |
| `uv2_count` | 4,096 UV2 entries | TEST-01.md:151; `world3d_terrain.gd:671,726` |
| `uv2_y_face_modes` | every `UV2.y ∈ {0,1,2}` and integral; histogram recorded | V3D_02 T0:144; `world3d_terrain.gd:691-708` |
| `uv2_x_ground_only` | every `UV2.x == 0` (grass tile id) — ground unchanged vs P0 | `world3d_terrain.gd:697-708`; all-grass stub `t_terrain_only.gd:259-265` |
| `flat_grid_promoted` | perfectly flat 64² grid promotes **0** cells | TEST-01.md:212; V3D_02 T0:144; `t_smallmap_terrain.gd:150-171` |
| `atlas_grid_manifest` | `stats.atlas.grid == [16,8]` and shader `atlas_grid == (16,8)` | TEST_01.md:151; V3D_02 T0:144; `t_smallmap_terrain.gd:353-379` |
| `shader_shadow_disabled` | shader `shadow_enabled == 0` | TEST_01.md:151; `world3d_terrain.gd:314-315` |
| `no_water_cells` | cells with `height < −0.25 m` = 0 | TEST-01 C2:217; `world3d_terrain.gd:95`; grid min ≈1.45 m |
| `no_water_tileblock` | cells with `BLK_WATER=255` = 0 | `game.gd:52`; C2 "no water" |
| `no_water_plane_present` | **zero visible** `WaterPlane`/`Water3D` nodes (module always builds one; hidden, not deleted) + the two water-cell checks above | TEST-01 P0:212 "optionally hide WaterPlane"; `world3d_terrain.gd:762-764`; `terrain3d_sandbox.gd:120-124` — see "Expected pre-fix failures" |
| `tree_node_count` | `wood` resource nodes == 20 | TEST-01 P1:213; TEST_MATRIX.md:19; DTRN_04 §8 T2 `:312` (N=20 = labelled stress case) |
| `ore_node_counts` | gold == 3, iron == 3, coal == 3 | TEST-01 P3:215; V3D_02 T3:147 |
| `category_purity` | wood=20, gold/iron/coal=3 each, stone/food/bush/stump = 0 | TEST-01 P1/P3:213,215; `world3d_entities.gd:1269-1283` |
| `harness_category_crosscheck` | helper `count_categories()` reports wood=20, mine=9, stone=0, food=0 — evaluated **only** when the shared helper loaded | `_smallmap_harness.gd:134-144`; TEST-01.md:230-239 |
| `tree_instance_count` | sum of `Batch_res_tree_*` `visible_instance_count` == 20 | TEST-01 P1:213; `world3d_entities.gd:966,986-1015` |
| `ore_instance_counts` | `Batch_res_mine_gold/iron/coal` instances == 3 each | TEST-01 P3:215; `world3d_entities.gd:1275-1276` |
| `non_tree_ore_instance_purity` | stone/rock, bush, stump, field and unknown batch instances all == 0 | TEST-01 P1/P3:213,215; `world3d_entities.gd:114-118,1269-1283` |
| `entity_stats_total` | `entities.stats.resources == 29` | `world3d_entities.gd:1529-1551` |
| `y_matches_terrain` | every instance origin Y equals `terrain.height_at_world(origin.xz)` within 1e-3 m; worst error recorded | V3D_02 T1:145, T3:147; DTRN_04 §8 T5:315; `world3d_entities.gd:1060-1079,1094-1121`; `world3d_terrain.gd:883-903` |
| `tree_ore_separation` | minimum tree↔ore SIM distance > 10.5 m (stub layout ≈19.8 m) | TEST-01 C2:217; `game.gd:2337-2358` |
| `capture_image` | SubViewport texture non-blank | `main.gd:1815-1853`; `testbridge.gd:284-291` |
| `capture_saved` | `save_png()` == OK at absolute `--screenshot` (alias `--png`) path | TEST-01.md:192-197; `t_smallmap_terrain.gd:93-99` |
| `non_black_fraction` | > 0.9 (any RGB channel > 8) | V3D_02 T0:144; `smallmap_capture.py:26` |
| `full_width_dark_rows` | == 0; row dark when >90 % of pixels have luma <20 | V3D_02 F6:129, T0:144; `smallmap_capture.py:25-28` |

Only the last four checks depend on a PNG. The other 28 are evaluated in
headless mode too. No check is conditional on a donor binary or asset beyond
what the shipped `world3d_entities.gd` already resolves (a missing donor mesh
falls back to `donor_bbox_proxy`, `world3d_entities.gd:711-757`).

## Consumption of the shared harness

- `HARNESS_PATH` is probed with `ResourceLoader.exists()` and `load()`ed
  dynamically — no `class_name`. The atom calls the helper's
  `make_stub_game(w, h, height, res_nodes, tileblock)` positionally and, when
  available, `count_categories()` for an independent cross-check.
  **Observed:** the helper was absent when this pass began
  (`variant3d/tests/fixtures/` then held only the two map fixtures) and landed
  from the parallel owner during the pass; its signature at
  `_smallmap_harness.gd:121-131` matches the atom's positional call.
- **Fallback (noted, not hidden):** if the helper is missing, unloadable, or
  lacks `make_stub_game`, the atom uses `LocalStubGame extends C3Game`
  (`:114-168`) with the same field/height/mine-sid shape. Base-class fields
  are inherited, never redeclared (`game.gd:35-61,82,149`). The active path is
  recorded in the JSON as `"harness_source"` = `shared:res://tests/fixtures/_smallmap_harness.gd`
  or `embedded_local_stub`. No assertion is weakened on the fallback path;
  only `harness_category_crosscheck` is omitted (the helper is not there to
  call).
- **UNVERIFIED:** whether static methods on a dynamically `load()`ed GDScript
  are reachable via `Script.call()` in Godot 4.7. P0's report records the same
  open question (`TEST_P0_report.md:135-140`). If they are not, the embedded
  stub takes over and the cross-check is omitted; the first runner job should
  read `harness_source` to confirm which path executed.

## Isolation boundary and capture mechanics

- Bound: `world3d_terrain.gd` (which internally creates its own
  `WorldEnvironment`, sun, `HeightmapTerrain` and one water module), a real
  `camera3d.gd`, and `world3d_entities.gd`. No `game.setup()` — the generator
  has no per-category disable flags (`TEST_01.md:114-121`), so the stub is the
  only clean isolation route.
- Not bound: `world3d.gd`, `world3d_fx.gd`, `picking3d.gd`, `main.tscn`, any
  units/buildings, any real generator RNG. No donor constant is invented: all
  numeric anchors are cited above, and the 20/3-per-type counts plus the
  lattice coordinates are explicitly **stub choices**.
- Water is hidden, not deleted, so mesh stats stay comparable to P0/C1/C3/C4.
- Headless guard: `DisplayServer.get_name() == "headless"` → no `SubViewport`,
  no PNG, no visual checks. Result `verdict`/`capture_status` =
  `SKIP_CAPTURE`, `passed = false`, while the 28 structural checks still run.
  Exit 0 when no evaluated check failed; the console prints
  `RESULT: SKIP_CAPTURE`, never `RESULT: PASS`, on that path.
- External cross-check (later owner, not run here):
  `python variant3d\tools\smallmap_capture.py stats <png>` and
  `scan-stderr <runner stderr.txt>` (`SCRIPT ERROR == 0`; TEST-01.md:255,
  V3D_02:151-153). GDScript cannot read its own stderr.

## Expected pre-fix failures (do not treat as regressions)

1. `no_water_plane_present` under a **literal** "zero `WaterPlane` nodes"
   reading — **EXPECTED_FAILURE on the current port**: the terrain module
   unconditionally builds one `WaterPlane` (`world3d_terrain.gd:762-764`).
   The atom deliberately scopes the assertion to **zero visible planes plus
   zero water cells/tile cells**, which is the C2 "no water" intent and the
   P0 precedent (`TEST-01.md:212`). This is a definition, not a weakened
   predicate: if a future fix leaves an active water layer visible, the check
   still fails loudly.
2. Tree scale/rotation fidelity (DTRN_04 §8 T3 ≥3 height buckets, T4 ≥6 yaw
   bins) — **EXPECTED_FAILURE under the current port** (DTRN-04 summary at
   `SWARM_BOARD.md:23`: live pool of 6 sids, all scale 0.5, yaw 0, no stand
   pass). These criteria are **out of C2's scope** and are owned by P1; their
   absence from this atom must not be read as a pass for them.
3. Mine donor scale/jitter fidelity — **UNVERIFIED**: DTRN-05 is still RUNNING
   (`SWARM_BOARD.md:24`) and no DTRN-05 report was on disk this pass. C2 checks
   sid/count/Y/separation only, not donor asset scale.
4. Visual checks (`capture_image`, `capture_saved`, `non_black_fraction`,
   `full_width_dark_rows`) — **UNVERIFIED until a windowed run plus the
   mandatory second-agent re-check** (`TEST_MATRIX.md:58`). They are plausible
   given water is hidden, but no PNG exists and no donor A/B frame exists
   (`TEST_MATRIX.md:31-34,46`); a full-width dark row from the active P6 water
   band would be real evidence, not something to suppress.
5. Instance-count checks would fail if the `Batch_<key>_<tag>` naming at
   `world3d_entities.gd:966` changes; that is a genuine regression signal and
   is retained, not relaxed.
6. If the static-call concern above materialises, `harness_source` will read
   `embedded_local_stub` and `harness_category_crosscheck` will be absent.
   That is a harness-plumbing observation, not a pass for the invariants.

**No pass claim:** nothing in this report asserts the atom runs green. It is
an authored, unexecuted test.

## PORT APPROX vs donor truth

| Item | Status in this atom |
|---|---|
| 64² all-grass grid, mild height, 20/3/3/3 node lattice, 10.5 m ring | **Synthetic stub fixture**, not donor map data. Counts are labelled stress values, not donor density measurements. |
| `TILE_M=2`, `WATER_LEVEL=−0.25`, `BLK_WATER=255`, UV2.x=tile id | **PORT APPROX / observed port values** (`world3d_terrain.gd:93-95,697-708`; `game.gd:16,52`); donor literals UNVERIFIED. |
| Tree/mine sids, `mine_<ty>`, batch naming, `ENV_SCALE` | **Observed port path** (`world3d_entities.gd:113-118,966,1269-1283`). Consuming it proves plumbing, not donor rendering fidelity. |
| Instance Y | **Structural**: port `height_at` ↔ `height_at_world` agreement at 1e-3 m; the donor's authored stand/offset pass is UNVERIFIED (DTRN-04 F5/C10). |
| PNG non-black / dark-row metrics | **Internal consistency only**. No donor reference frame; visual A/B is blocked by F0 (`TEST_MATRIX.md:46,58`). |

## Open questions

1. Will the first runner job confirm the shared helper's static methods are
   callable via `load()`ed script, or will `embedded_local_stub` be used?
2. Is the 10-frame wait enough for a stable atlas/mesh load with entities
   present under `UPDATE_ONCE`? `TEST_MATRIX.md:32` says ~10 frames; if a
   blank frame appears, raise `CAPTURE_FRAMES` — never add a CPU fallback.
3. Does the 64² stub viewport framing reproduce the proven V7-70 capture once
   billboard trees/mines are added? No stub-with-entities PNG exists yet.
4. Should C2 also assert the port's scale/yaw/stand gaps (DTRN-04 T3/T4), or
   keep those strictly with P1? Current choice: keep C2 structural-only.
5. Is the 19.8 m stub separation representative of the donor's cell-mask
   no-overlap rule (DTRN-04 reports no explicit min-distance constant)? The
   10.5 m gate is port-side (`game.gd:2350-2351`), not a donor literal.
6. Who performs the mandatory second-agent capture re-check, and where would
   a 64² donor frame come from (F0 still blocked)?
7. Registration is intentionally absent: `manifest.json` / `test_all.py`
   fixes are a separate integration ticket (`TEST_01.md:257-267`).

## No-runner declaration

No Godot process was launched, no `godot_runner.py` ticket was requested,
no queue lock was touched, no PNG or result JSON was produced, no donor file
was read or executed, and no file other than the two listed in `owns:` was
written by this worker. In particular, `t_terrain_trees.gd`, `t_terrain_mines.gd`,
`_smallmap_harness.gd`, `manifest.json` and all source/shader files were only
read, never edited.

Proposed (NOT executed) launch form for a future owner, windowed, through the
serialized runner (`TEST-01.md:188,192-197`; Windows `python`, never `python3`):

```
python variant3d\tools\godot_runner.py run --id <ticket>-C2 --timeout 20 -- \
  --path variant3d --script res://tests/t_combo_trees_mines.gd -- \
  --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/smallmap64_combo_trees_mines.png
```

Then, externally and read-only:
`python variant3d\tools\smallmap_capture.py stats <png>` and
`python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>`.

---

*End of TEST-C2. Authoring only: no Godot run, no runner job, no donor access, no PASS claim.*
