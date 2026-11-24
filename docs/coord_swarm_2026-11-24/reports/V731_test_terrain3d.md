---
title: "V7-31 — atomic headless test: t_terrain3d.gd"
agent: V7-31
date: 2026-11-24
status: DELIVERED__ALL_CHECKS_PASS
claim_under_test: "variant3d/scripts/world3d_terrain.gd exposes the V73 atomic API and builds ONE full-grid ArrayMesh from a base64 height grid"
owner_files:
  - variant3d/tests/t_terrain3d.gd
  - docs/coord_swarm_2026-11-24/reports/V731_test_terrain3d.md
module_under_test: variant3d/scripts/world3d_terrain.gd (NOT owned; written by V7-13 while this test was being authored)
runner: variant3d/tools/godot_runner.py
scope: singleplayer skirmish 3D terrain; no donor binaries executed or copied
---

# V7-31 — `t_terrain3d.gd`

## 1. Test design

`variant3d/tests/t_terrain3d.gd` is one file, one feature, headless, self-exiting.
It is a `SceneTree` harness because Godot 4.7.2 rejects a `Node3D` `--script`
(G32 ticket 1312); the module under test is loaded with
`load("res://scripts/world3d_terrain.gd")` and instantiated dynamically — **no
`class_name` dependency**. All exits go through `call_deferred("quit", code)`
from `finish()`; a deferred `_failsafe()` also reports and quits if the body
aborts. Tabs throughout, per the V73 contract.

**Stub game.** `class StubGame extends C3Game` (the real game class, so a typed
`bind(game: C3Game)` also works) carries a **base64 little-endian float32 height
grid** in three forms — `dump["height"]`, `height_b64`, and the decoded
`PackedFloat32Array` in the inherited `height` — plus `MAP_W/MAP_H` and
`map_w/map_h`. The grid is 320×320 (102,400 cells), row-major `idx = z*w + x`,
with deterministic `sin/cos/mod` values; bytes are encoded with
`PackedByteArray.encode_float()` and `Marshalls.raw_to_base64()`, matching
`main.gd:694-701` / `game.gd:5564`.

**Checks (none weakened, no silent skips):**

| # | Check | Exact assertion |
|---|---|---|
| 1 | `module_load_and_api` | module file exists, `load()` non-null, `can_instantiate()`, `.new()` is a `Node`, and all five contract methods exist (`bind`, `build`, `invalidate`, `has_chunk_or_fallback`, `height_at_world`) |
| 2 | `build_ok` | `build()` returns `true`; if false, checks 3–6 are marked FAIL, not skipped |
| 3 | `surface_count` | the resident full-grid `ArrayMesh` has **exactly 1** surface |
| 4 | `vertex_count` | `surface_get_arrays(0)[ARRAY_VERTEX].size() == w*h` (**102,400** at 320²); 203,522 triangles printed as information, not a substitute assertion |
| 5 | `has_chunk_or_fallback` | returns `true` (no chunks / fallback) |
| 6 | `height_at_world_samples` | at three cell centres — (3,5), (160,160), (317,312) — `abs(height_at_world(p) - grid[idx]) <= 1e-4`; world point uses the G32 recipe `((x+0.5-w/2)*TILE_M, (z+0.5-h/2)*TILE_M)`, `TILE_M=2.0` |

The terrain mesh is found by walking the module's children and taking the
largest indexed `ArrayMesh` (the water quad has 4 vertices), so the test does
not depend on a node name or an unpromised `stats` dictionary. One `PASS`/`FAIL`
line is printed per check plus a `T_TERRAIN3D RESULT:` summary, and the same
records are written to `variant3d/tests/results/t_terrain3d.json`.

**Missing-module path (required by the task).** If `world3d_terrain.gd` is not on
disk, the test prints `T_TERRAIN3D MODULE_MISSING: ... not on disk`, marks every
check FAIL with a `MODULE_MISSING:` detail, writes the result JSON and exits 1.
The module *did* land (as V7-13) during authoring, before verification, so this
branch was exercised by inspection rather than by a runner job; the strict
assertions were left unchanged.

## 2. Runner jobs and results

All jobs used the mandated command form:

```
python variant3d\tools\godot_runner.py run --id <id> --timeout 90 -- --headless --path variant3d --script res://tests/t_terrain3d.gd
```

| Ticket | Job id | Result |
|---|---|---|
| 11 | `v731-terrain3d-missing` | runner `END ok`, run 7.17 s; **test 6/6 PASS** (stdout below). First stdout check line proves the module had landed by then. Note: stderr contained three `String formatting error: unsupported format character` lines from the detail-only `%.2e` specifier — the checks themselves were unaffected; fixed and re-run as `v731-terrain3d-final`. |
| 25 | `v731-terrain3d-final` | runner `END ok`, waited 228.18 s, run 8.91 s; **test 6/6 PASS, stderr empty**. Formatting fix verified: all three sample details now print real expected/got/err values (err = 0.0 for each). |

Ticket 11 stdout (verbatim, module already present):

```
T_TERRAIN3D PASS module_load_and_api - loaded res://scripts/world3d_terrain.gd; missing_methods=[]
T_TERRAIN3D PASS build_ok - build() returned true
T_TERRAIN3D PASS surface_count - terrain_mesh=HeightmapTerrain surfaces=1 (expected 1)
T_TERRAIN3D PASS vertex_count - vertices=102400 expected=102400 triangles=203522 (informational)
T_TERRAIN3D PASS has_chunk_or_fallback - returned true (expected true, no chunks)
T_TERRAIN3D PASS height_at_world_samples - eps=0.0001 ... (detail string unformatted in this run)
T_TERRAIN3D RESULT: PASS 6/6
```

Ticket 25 final stdout check line (verbatim, after the formatting fix):

```
T_TERRAIN3D PASS height_at_world_samples - eps=0.0001 (3,5) expected=1.29160225391388 got=1.29160225391388 err=0.0 ok | (160,160) expected=-1.5742666721344 got=-1.5742666721344 err=0.0 ok | (317,312) expected=-1.27049291133881 got=-1.27049291133881 err=0.0 ok
```

Ticket 25 stderr was **empty**; `variant3d/tests/results/t_terrain3d.json` records
`passed: true`, `passes: 6`, `total: 6`. This matches G32 §6 (102,400 verts /
203,522 tris / 1 surface at 320²) exactly.
No parse/load error: the loaded module's `build()` returned true and its API was
complete. The module's `stats` was not used as evidence for any assertion.

## 3. Open questions

1. **Stub shape.** The landed module's `_dump_from_game()` accepts a `dump`
   dictionary first, else a `PackedFloat32Array` `height` (`world3d_terrain.gd:112-145`). The stub supplies both, so the base64 grid is consumed through `dump["height"]`. If a later module revision reads only `game.height` as a base64 **String**, this stub would need a field-shape change; no assertion would be relaxed.
2. **Height convention.** `height_at_world()` is bilinear over cell-centre vertices (`world3d_terrain.gd:332-348`); sampling exactly at cell centres therefore returns the source value. Non-centre interpolation, `HEIGHT_SCALE != 1`, or a corner-based lattice would be a real mismatch and should stay a FAIL.
3. **Texture availability.** `variant3d/assets/terrain/heightmap/splat_albedo.png` is absent; the module degrades to a plain material without failing `build()`. This test deliberately does not gate on albedo — G32's geometry claim is the claim under test.
4. **Timing variance.** Build time is not asserted (shared machine; G32 §6 measured 129–549 ms across jobs).
5. **No open verification debt.** The first run's detail-only format error was fixed; ticket 25 (`v731-terrain3d-final`) re-ran clean (6/6 PASS, stderr empty). No assertion was changed between runs.
