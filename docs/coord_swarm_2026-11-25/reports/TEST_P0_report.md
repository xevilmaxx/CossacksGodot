---
id: TEST-P0
title: "P0 isolated terrain-only 64² atom — authoring report"
owner: TEST-P0 (test-authoring micro-worker)
date: 2026-11-25
status: AUTHORING_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "One new file plus this report. No source/shader/asset/config/manifest/fixture/gate-file/git edit; no Godot launch, no queue ticket, no capture executed."
owns:
  - "variant3d/tests/t_terrain_only.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md"
labels: [TERRAIN_ONLY, ISOLATED_STUB, 64X64, WINDOWED_SUBVIEWPORT, SKIP_CAPTURE_GUARD]
evidence_labels: [observed, derived, inferred]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:18,29-46"
verdict: "NOT RUN — structural PASS expected by design; visual UNVERIFIED; no donor parity claim"
---

# TEST-P0 — isolated terrain-only 64² atom (authoring report)

## Goal

Author **one** new `extends SceneTree` atom that renders *terrain and nothing else*
on the ladder's common 64×64 map: a synthetic flat/mild all-grass height grid,
empty `res_nodes`, no water cells, `world3d_terrain.gd` bound together with a
**real** `camera3d.gd`, any `WaterPlane` hidden, a stub-owned windowed
`SubViewport` readback, and a `res://tests/results/t_terrain_only.json` verdict.
No test was run; this is an authoring hand-off only.

## Sources (all read-only this pass)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:183-212` | P0 row of "Test ladder": stub setup, capture path, all structural measures, "visual parity not claimed" |
| `TEST_01_smallmap_harness.md:228-255` | §"Scaffolding needed" item 1: shared stub helper API (`make_stub_game(w,h,height,res_nodes,tileblock)`, `count_categories()`, `write_result()`), windowed capture pattern, headless guard, result cross-check |
| `TEST_01_smallmap_harness.md:269-305` | Blockers: no category flag, headless cannot capture 3D, no screenshot-resolution flag, serialized FIFO + `_initialize()` quit trap, class-name cache |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,18,29-46,53-58` | same-map rule; T0 criteria; 4,096/7,938/4,096/UV2.x∈[0,85]/face_hist/atlas(16,8)/shadow OFF baseline; "no piece PASS until second agent re-checks" |
| `reports/V3D_02_terrain_render_audit.md:134-153` | T0 row of "Piece-test ladder proposal": 1 surface, 4,096 verts, 7,938 tris, 4,096 UV2, flat-fixture → 0 promoted, atlas (16,8), 3 samplers, `shadow_enabled=0`, non-black >0.9, 0 full-width dark rows |
| `variant3d/tests/_template_test.gd:1-38` | one feature per file, result JSON shape, `call_deferred("quit", …)`, no direct quit in `_initialize()` |
| `variant3d/tests/t_terrain3d.gd:12-14,37-46,106-127,161-255` | `extends SceneTree`, dynamic `load()` (no `class_name`), `StubGame extends C3Game`, base64 `dump`, `_find_terrain_mesh`, defer-quit |
| `variant3d/tests/t_smallmap_terrain.gd:42-85,93-99,150-171,271-339,353-384` | arg parsing, `_flat_face_check`, mesh/UV2/face/atlas/shader assertions, result JSON |
| `variant3d/tests/t_pick3d.gd:48-71` | stub shape (`res_nodes`, `res_dirty`, `entities`, `pick_radius`, `height_at`, `resolve_mine_sid`, empty `cmd_*` counters) |
| `variant3d/tests/fixtures/_smallmap_harness.gd:5,11-24,106-128` (read-only, landed by the parallel owner during this pass) | actual shared-helper API: `RefCounted` + static `make_stub_game(w,h,height,res_nodes,tileblock) -> Object`, StubGame shape, `dump` mirroring `main.gd:737-741` |
| `variant3d/scripts/world3d_terrain.gd:93-95,117-118,303-325,624-874` | `WATER_LEVEL=-0.25`, `cDiff1/cDiff2`, `shadow_enabled=0`, one indexed mesh, UV2.x/y contract, WaterPlane creation at `:762-764` |
| `variant3d/scripts/camera3d.gd:148-198,232-252,484-581` | real camera `bind()` sets `make_current()` + centred transform; `_process()` edge-scrolls (disabled after bind for a fixed frame) |
| `variant3d/scripts/main.gd:1156-1193,1801-1862` | proven `Screenshot3DViewport` + `UPDATE_ONCE` + `frame_post_draw` + blank-frame loud failure (no CPU fallback) |
| `variant3d/scripts/terrain3d_sandbox.gd:50-58,110-124,139-151`; `testbridge.gd:277-308` | window size before boot, hide `WaterPlane`, stub-owned PNG readback |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` (READ-ONLY) | exact PNG metric definitions mirrored in GDScript; external stderr `SCRIPT ERROR` scan |
| `variant3d/scripts/data.gd:23,113-117,165-172`; `game.gd:4,35,52-61,1893-1907` | `TILE_M=2`, 1280×720, camera pitch/height bounds, `BLK_WATER=255`, `res_nodes`, bilinear `height_at` |

## What was authored

`variant3d/tests/t_terrain_only.gd` — a single self-exiting atom. Structure:

1. SceneTree main loop; dynamic `load()` for both game modules and the shared
   fixture helper (no `class_name` dependency; TEST-01 Blocker 10).
2. In-memory 64×64 grid built in `_initialize()`: `height[i] = 1.5 +
   0.03·sin(0.11x) + 0.02·cos(0.09z)` (max axis delta ≈ 0.005 m, far below
   `cDiff1=0.5`), `tileblock[i] = 0` (grass1), `res_nodes = []`. No fixture
   file is read; `small_map_64.json` is **not** booted (this is a stub row, not
   the S1 real-boot row).
3. `world3d_terrain.gd` + real `camera3d.gd` are the only game modules bound.
   The camera's `_process()` is disabled after `bind()` so mouse edge-scroll
   cannot pan the fixed frame (`camera3d.gd:484-581`). All `WaterPlane` and
   `Water3D` nodes created by the terrain module are set invisible (not
   deleted) — `terrain3d_sandbox.gd:120-124` precedent.
4. Windowed mode: root window set to 1280×720, private `SubViewport` with a
   fresh `World3D`, `UPDATE_ONCE`, camera made current inside it, 10 frames,
   `await RenderingServer.frame_post_draw`, `get_texture().get_image()`,
   `save_png(<user-arg path>)`. No `.raw.png` and no main-owned saver.
5. Result at `res://tests/results/t_terrain_only.json`; every exit is
   `call_deferred("quit", 0 or 1)` from `finish()`, never a direct quit in
   `_initialize()`. A `_failsafe()` deferred at setup start becomes inert once
   `_setup_done = true`, so it cannot abort the async capture path.

## Exact assertions (and their citations)

| Check name | Assertion | Citation / basis |
|---|---|---|
| `harness_stub_shape` | stub exposes `MAP_W/MAP_H = 64/64`, `height: PackedFloat32Array`, `tileblock: PackedByteArray`, empty `res_nodes: Array` | TEST-01.md:230-239; `t_terrain3d.gd:119-127`; `t_pick3d.gd:53-62` |
| `terrain_module_api` | `bind/build/invalidate/has_chunk_or_fallback/height_at_world` all present | `t_terrain3d.gd:180-189` |
| `camera_module_api` | `bind/world_to_px/screen_to_world/set_zoom_target` all present | `camera3d.gd:6-10,148,258,266,606` |
| `build_ok` | `world3d_terrain.build()` returns `true` | `world3d_terrain.gd:624-874`; `t_terrain3d.gd:197-204` |
| `surface_count` | `mesh.get_surface_count() == 1` | P0/TEST-01.md:212; V3D_02 T0:144; `world3d_terrain.gd:728-729` |
| `vertex_count` | `vertices == 4096` (`64²`) | TEST-01.md:148-154 baseline; `world3d_terrain.gd:666,685-687` |
| `triangle_count` | `triangles == 7938` (`(64−1)²·2`) | TEST-01.md:151; `world3d_terrain.gd:667,710-719` |
| `uv2_count` | `UV2 entries == 4096` | TEST-01.md:151; `world3d_terrain.gd:671,726` |
| `uv2_y_face_modes` | every `UV2.y ∈ {0,1,2}` and integral; histogram recorded; `UV2.x` range/out-of-atlas recorded against `named_cells=124` | V3D_02 T0:144; `TEST_MATRIX.md:34`; `world3d_terrain.gd:691-708`; `t_smallmap_terrain.gd:292-318` |
| `flat_grid_promoted` | `_face_mode_at()` over a perfectly flat 64² grid promotes **0** cells | TEST-01.md:212 ("flat-grid promoted=0"); V3D_02 T0:144; `t_smallmap_terrain.gd:147-171,339` |
| `res_nodes_empty` | `game.res_nodes.size() == 0` | TEST-01.md:212; `game.gd:61`; P0 = "no trees, no shore, no mines" (`TEST_MATRIX.md:18`) |
| `no_water_cells` | cells with `height < WATER_LEVEL (−0.25)` = **0** | TEST-01.md:212; `world3d_terrain.gd:95`; mild grid min ≈ 1.45 m |
| `no_water_tileblock` | cells with `BLK_WATER (255)` = **0** (all grass id 0) | `game.gd:52`; P0 "no water cells" |
| `atlas_grid_manifest` | `stats.atlas.grid == [16,8]` **and** shader `atlas_grid == Vector2(16,8)` | TEST-01.md:151; V3D_02 T0:144; `t_smallmap_terrain.gd:353-379`; `world3d_terrain.gd:250,313,832` |
| `atlas_material_bound` | surface material is `ShaderMaterial` with `tile_atlas`, `alpha_atlas`, `alphavert_atlas` bound | V3D_02 T0:144 ("3 samplers bound"); `world3d_terrain.gd:310-312`; `t_smallmap_terrain.gd:369-371` |
| `shader_shadow_disabled` | shader parameter `shadow_enabled == 0` | TEST-01.md:151; V3D_02 T0:144; `world3d_terrain.gd:314-315`; `t_smallmap_terrain.gd:383-384` |
| `water_plane_hidden` | every `WaterPlane` (and `Water3D`) node is invisible | TEST-01.md:212 ("optionally hide WaterPlane"); `terrain3d_sandbox.gd:120-124`; module always builds one at `world3d_terrain.gd:762-764` |
| `capture_image` | SubViewport texture non-blank | `main.gd:1815-1853` ("no CPU fallback"); `testbridge.gd:284-291` |
| `capture_saved` | `save_png(<user-arg path>) == OK`, absolute path from `--screenshot` (alias `--png`) | TEST-01.md:192-197; `t_smallmap_terrain.gd:93-99` |
| `non_black_fraction` | `> 0.9`, fraction of pixels with any RGB channel `> 8` | V3D_02 T0:144; `smallmap_capture.py:26` |
| `full_width_dark_rows` | `== 0`; a row is dark when `>90 %` of its pixels have luma `<20` (`0.2126R+0.7152G+0.0722B`) | V3D_02 F6:129, T0:144; `smallmap_capture.py:25-28` |

The two PNG checks are evaluated **only** in the windowed path. Structural
checks are independent of capture and still run in headless mode.

Result JSON carries `id`, `passed`, `verdict`, `capture_status`,
`structural_ok`, per-check `status`, full `measured` dictionary (mesh counts,
UV2 histogram/x-range, flat-promotion count, water-cell counts, atlas params,
PNG metrics), `harness_source`, `png_path`, `skip_reason`, `script_error_note`,
`parity_label`, `unix_ms`.

## Consumption of the shared harness

- `HARNESS_PATH = "res://tests/fixtures/_smallmap_harness.gd"` is probed with
  `ResourceLoader.exists()` and `load()`ed dynamically — **no** `class_name`
  reference (TEST-01.md:299-301). The atom calls the proposed
  `make_stub_game(w, h, height, res_nodes, tileblock)` positionally (TEST-01.md:230-231)
  and consumes only that method. It then validates the returned object's shape
  before binding. The helper's `count_categories()` / `write_result()` are not
  used: this atom writes its own id-specific result per `_template_test.gd:17-31`.
- **Observed:** when this atom was first drafted, `_smallmap_harness.gd` was
  not yet on disk (`variant3d/tests/fixtures/` held only `small_map_64.json`
  and `small_map_128.json`). The parallel owner landed it during this pass;
  its `static func make_stub_game(w: int, h: int, height: PackedFloat32Array,
  res_nodes: Array, tileblock: PackedByteArray) -> Object`
  (`_smallmap_harness.gd:118-128`) **matches** the positional call in this
  atom, and its `StubGame` (`:11-24`) exposes every field the atom checks.
  The atom calls static methods on the loaded script object, with an instance
  fallback if the helper changes shape.
- Consequently the atom embeds `LocalStubGame extends C3Game` **only as a
  fallback** with the same field/helper shape (`MAP_W/MAP_H`, `height`,
  `tileblock`, `dump`/`height_b64`, `res_nodes`/`res_dirty`, `entities`,
  `pick_radius`, `height_at`, `resolve_mine_sid`, empty `cmd_*` counters)
  (`t_terrain3d.gd:41-46`; `t_pick3d.gd:53-71`). It is used if the shared
  file is absent or its call yields nothing. The active source is recorded in
  the result JSON as `"harness_source"` (`shared:res://tests/fixtures/_smallmap_harness.gd`
  expected on a current tree; `embedded_local_stub` on a tree without it).
- **Open question:** static methods on a dynamically `load()`ed GDScript
  resource are expected to be reachable with `.call()`, but no Godot run was
  performed to confirm it. If not, the instance fallback and then the embedded
  stub keep the atom functional; no assertion is weakened and `harness_source`
  shows which path ran. This is a verification item for the first runner job,
  not an edit by this worker.

## Isolation boundary and capture mechanics

- Bound: `world3d_terrain.gd` (which internally creates its own
  `WorldEnvironment`/`DonorSun`/`HeightmapTerrain`/water module — module-owned,
  not separately bound) and real `camera3d.gd`.
- Not bound: `game.gd` runtime, `world3d.gd`, `world3d_entities.gd`,
  `world3d_fx.gd`, `picking3d.gd`, `water3d.gd` (only via the terrain module),
  `main.tscn`. No generator (`game.setup()` has no category flags:
  TEST-01.md:114-121), so no trees/shore/mines/units can appear.
- Water is *hidden*, not deleted, so mesh/module stats remain comparable with
  other ladder rows.
- Headless guard: `DisplayServer.get_name() == "headless"` → no `SubViewport`,
  no PNG, no visual checks. Result `verdict`/`capture_status` =
  `SKIP_CAPTURE`, `passed = false` (no full PASS is claimed), `structural_ok`
  reflects the structural checks, exit `0` when no evaluated check failed.
  The console prints `T_TERRAIN_ONLY RESULT: SKIP_CAPTURE …`, never
  `RESULT: PASS` on that path. This is deliberate: a skipped visual test must
  not be harvested as a pass by an aggregator.
- External cross-check (later owner, not run here):
  `python variant3d\tools\smallmap_capture.py stats <png>` and
  `scan-stderr <runner stderr.txt>` (`SCRIPT ERROR == 0`, TEST-01.md:255,
  V3D_02:151-153). GDScript cannot read its own stderr.

## PORT APPROX vs donor truth

| Item | Status in this atom |
|---|---|
| 64² grid, all-grass tile id, mild height, empty `res_nodes` | **Synthetic test fixture**, not donor map data. It exists to isolate the render module, not to reproduce a donor skirmish map. |
| `TILE_M = 2.0`, `WATER_LEVEL = −0.25`, `UV2.x = tile id`, `UV2.y ∈{0,1,2}`, atlas (16,8) | **PORT APPROX / observed port values**: `world3d_terrain.gd:93-95,691-708`; donor cell size and literal are UNVERIFIED (`V3D_02` P14, P5). |
| Face-mode promotion (`_face_mode_at`) | **PORT APPROX** using donor-readable `cDiff1/cDiff2` thresholds; exact donor vf/vs promotion is ENGINE/UNVERIFIED (`V3D_02` P5, `world3d_terrain.gd:347-382`). Zero on a flat grid is a regression guard, not donor proof. |
| Eye-plane UVs, headlight lighting, mask-to-alpha, water band, sky/fog | **PORT APPROX / active gaps** (`V3D_02` P2/P3/P6/P7/P9). The atom reads no donor values and does not change them. |
| PNG non-black / dark-row metrics | **Internal consistency only**. No donor reference frame exists; `V3D_02 parity_guard` and `TEST_MATRIX.md:34` forbid a donor-parity claim. "No checkerboard/seam/art band" requires a second-agent visual re-check, which is not part of this task. |
| Donor ground colour / placement bands (`TEST_MATRIX.md:18`) | **UNVERIFIED** here: the all-grass synthetic tileblock deliberately removes the donor's transition-heavy histogram (`V3D_02` P1). This atom cannot establish donor colour fidelity. |

## Expected pre-fix result (NOT observed)

- **Structural:** expected PASS — 4,096 verts / 7,938 tris / 1 surface /
  4,096 UV2 / UV2.y all 0 / flat-promoted 0 / `res_nodes` 0 / below-water 0 /
  atlas (16,8) / shadow 0. These are direct consequences of the synthetic
  fixture and the current `world3d_terrain.gd` mesh recipe
  (`world3d_terrain.gd:664-747`), mirroring the measured 64² baseline
  (`TEST_01.md:148-154`). **Expected, not run — do not report as a pass.**
- **Visual:** **UNVERIFIED**. With the water plane hidden and an all-grass
  tileblock, non-black >0.9 and zero full-width dark rows are plausible, but
  no PNG was captured by this worker, no second-agent re-check occurred, and
  no donor A/B frame exists (`TEST_MATRIX.md:31-34`, `TEST_01.md:294-296`).
  The atom's own visual verdict can only be produced by a later windowed run.
- **Headless run:** expected `SKIP_CAPTURE` with structural checks still
  evaluated; not a PASS.
- If a later run fails a structural check, that is evidence against the
  current port code, not a reason to weaken the predicate (`TEST_MATRIX.md:56`,
  `T01_selftest_taxonomy.md:148-172` cited by TEST-01.md:221).

## Open questions

1. The helper landed with the exact expected `make_stub_game(w,h,height,res_nodes,tileblock)`
   signature (`_smallmap_harness.gd:118`), so no reconciliation is currently
   needed. Open item: confirm at run time that its static factory is callable
   through the dynamically `load()`ed script object; otherwise the embedded
   stub takes over and `harness_source` records which path ran.
2. Is the atom's 10-frame wait sufficient for a stable 180 MB single-PNG atlas
   load under `UPDATE_ONCE`? `TEST_MATRIX.md:32` says ~10 frames and main's
   `--screenshot-frames` is clamped ≥10 (`main.gd:1206-1209`), but this atom
   builds the atlas before the first frame; if a blank frame appears, raise
   `CAPTURE_FRAMES` or force an update — do not add a CPU fallback.
3. Does `get_root().size = 1280×720` before adding the `SubViewport` reproduce
   the proven V7-70 framing without `main.tscn`? No capture exists for this
   stub path yet (`TEST-01.md:192-197`).
4. Who performs the mandatory second-agent visual re-check and where would a
   64² donor frame come from (F0 is still blocked: `TEST_MATRIX.md:46,58`)?
5. Should `res_nodes_empty` remain a hard check when later ladder rows add
   resource nodes? It is intentionally P0-specific; P1/P3 must use their own
   atoms, not edit this one (`TEST_01.md:307-324`).
6. Registration is intentionally absent: `manifest.json` / `test_all.py`
   changes are a separate integration ticket (`TEST_01.md:257-267`). This atom
   is launched by hand through the runner until that ticket lands.

## No-runner declaration

No Godot process was launched, no `godot_runner.py` ticket was requested, no
queue lock was touched, no capture PNG or result JSON was produced, no donor
file was read or executed, and no other file was edited by this worker. Only
`variant3d/tests/t_terrain_only.gd` and this report were written.

Proposed (NOT executed) launch form for a future owner, windowed, through the
serialized runner (`TEST-01.md:188,192-197`; Windows `python`, never `python3`):

```
python variant3d\tools\godot_runner.py run --id TEST-P0-p0 --timeout 20 -- \
  --path variant3d --script res://tests/t_terrain_only.gd -- \
  --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/smallmap64_terrain_only.png
```

Then, externally and read-only:
`python variant3d\tools\smallmap_capture.py stats <png>` and
`python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>`.

---

*End of TEST-P0. Authoring only: no Godot run, no runner job, no donor access, no PASS claim.*
