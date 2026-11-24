---
title: "V7-13 — world3d_terrain.gd (full-grid heightmap terrain for the 3D variant)"
agent: V7-13
date: 2026-11-24
status: DELIVERED__PARSE_CLEAN__BUILD_PROBE_MEASURED
verdict: API_MATCHES_V73_CONTRACT__DONOR_FIDELITY_NOT_CLAIMED
owner_files:
  - variant3d/scripts/world3d_terrain.gd
  - docs/coord_swarm_2026-11-24/reports/V713_world3d_terrain.md
scope: singleplayer skirmish terrain mesh only; no donor binaries, no app/ edits
---

# V7-13 — `world3d_terrain.gd`

## 1. What landed

One new file, `variant3d/scripts/world3d_terrain.gd` (`extends Node3D`), a direct
port of the G3-2 full-grid mesh proof (`app/scripts/heightmap_world3d.gd`,
READ-ONLY reference — not edited). No other repo file was touched.

The module owns exactly one indexed `ArrayMesh` with one surface for the whole
`height[]` grid: one shared vertex per cell, central-difference normals,
cell-centre UVs over the full 0..1 map, and one translucent water quad at donor
`WATER_LEVEL`. There are **no per-chunk dictionaries, no 2-chunk/frame cap,
no imported sprite sheets and no RNG**. Lighting/environment is deliberately
NOT created here (V7-9 owns scene/env), so integration cannot double up lights.

## 2. Exact API (V7-13 atomic contract)

| Method | Behaviour |
|---|---|
| `bind(game)` | Stores the bound game (`C3Game` object or a dictionary test double). No build side effect. |
| `build() -> bool` | Resolves a dump dict with `map_w`/`map_h`/base64 `height` (explicit `game.dump`/`map_dump`/`self_base` if present; otherwise `game.height` re-encoded with the `game.gd:5564` Marshalls recipe), decodes every float32, builds ONE full-grid `ArrayMesh`, attaches splat material + water quad, fills `stats`, returns `true`. Returns `false` on a missing/malformed grid. |
| `invalidate()` | Frees every child created by `build()` (terrain mesh + water), clears the cached grid, `_built` and `stats`. Idempotent; `build()` calls it first. |
| `has_chunk_or_fallback() -> bool` | Always `true` — one mesh spans the whole map, so there are no chunks and no chunk fallback. |
| `height_at_world(p: Vector2) -> float` | Bilinear read of the same cached `height[]` grid the mesh was built from; `p` is centred world (x,z) metres, matching `(x+0.5-w/2)*TILE_M`. Same interpolation recipe as `game.height_at()` (`game.gd:1893-1907`). Returns `0.0` before a successful build. |

Public helper state: `stats: Dictionary` (grid, vertex/triangle counts, height
range, albedo path, timing breakdown, donor citations). All other helpers are
underscore-prefixed private methods; no additional public API is exposed.

## 3. Mesh recipe (G3-2 proof reproduced in the variant)

- `TILE_M = 2.0`, `HEIGHT_SCALE = 1.0`, `WATER_LEVEL = -0.25`.
- Vertex `i = z*w + x` at `Vector3((x+0.5-w/2)*TILE_M, height[i], (z+0.5-h/2)*TILE_M)`.
- Normal from central differences over `2*TILE_M`, one-sided at borders.
- UV `((x+0.5)/w, (z+0.5)/h)` — 0..1 over the full map, cell-centre aligned to
  the G3-4 splat texels; splat alpha is normalised height DATA, so blending is
  explicitly disabled (`TRANSPARENCY_DISABLED`).
- Winding `i00,i01,i10 / i10,i01,i11` (+Y facing), `ARRAY_VERTEX/NORMAL/TEX_UV/INDEX`.
- Splat loaded with runtime `Image.load(ProjectSettings.globalize_path(...))`
  because a Python-generated PNG has no Godot `.import` sidecar in a `--script`
  run (G32 ticket 1322). Order: `res://assets/terrain/heightmap/splat_albedo.png`
  (PRESENT in variant3d — verified), then `res://assets/terrain/blocks/grass1.png`
  (PRESENT), then plain material.
- No `WorldEnvironment`, no `DirectionalLight3D` in this module (V7-9).

## 4. Donor / port citations (read-only text, singleplayer skirmish)

| Decision | Source (path:line) | Port value / status |
|---|---|---|
| Height source | `C:\Games\Cossacks 3\data\scripts\generatemap.inc:537-577` (bitmap → engine grid → smoothing); corroborated `G31_donor_3d_truth.md:73,:230` | dump `height[]` grid, full map, no decimation invented |
| Dump schema + base64 grid | `variant3d/scripts/main.gd:694-701`; `variant3d/scripts/game.gd:44`, `:5564`, `:1893-1907` | `map_w`/`map_h`/`height` base64 float32; live grid cached from game |
| Water level | `variant3d/scripts/mapgen.gd:29` `C3MapGen.WATER_DEEP = -0.25` (port comment cites donor `data\scripts\texturemap.inc:30`) | `-0.25` m; donor literal **UNVERIFIED** (G32 §3) |
| Camera framing | `data\cameras\camera.cfg:32-35` (tilt −32°), `:44-45` (focal 400), `:6-10` (height 20..58) | cited only; camera is V7-5's `camera3d.gd`, no constant copied here |
| Cell size | `variant3d/scripts/data.gd:23` `C3Data.TILE_M = 2.0` | `2.0` m; donor absolute cell size **UNVERIFIED** |
| Heightfield shading model | donor `shaders.lib:16-19` → `hf.pvl.sm.vert` (via G32 §3) | finite-difference normals + Godot material (approximation, not a donor copy) |

## 5. Verification (variant runner only)

All jobs via `python variant3d\tools\godot_runner.py`:

| Ticket | id | Command | Result |
|---|---|---|---|
| 6 | `v713-terrain-parse` | `--headless --path variant3d --script res://scripts/world3d_terrain.gd --check-only` | **ok**, exit 0, run 8.07 s, stderr empty (Godot 4.7.2.stable) |
| 12 | `v713-terrain-build` | scratch `SceneTree` probe, synthetic 160×160 base64 dump (no dump file exists under `variant3d`) | first run exposed a typing bug: `bind()` rejected a dictionary test double (`_game: Object`); fixed to untyped Variant |
| 22 | `v713-terrain-build2` | same probe after fix | **ok**, run 4.43 s, stderr empty; `build()=true`, all API assertions pass |

The build probe is a scratch harness under the approved temp directory; it does
not add or edit any repo file. No height dump exists under `variant3d` (checked),
so the probe uses a deterministic synthetic grid (no RNG), not the G3-2
`app/shots/g32_dump.json`.

## 6. Measured stats

From ticket 22 (`v713-terrain-build2`, scratch harness, synthetic deterministic
160×160 base64 dump — **not** the G3-2 320² dump; no dump file exists under
`variant3d`). All values are MEASURED from `stats` printed by the probe.

| Metric | MEASURED |
|---|---|
| `build()` result | `true` |
| Grid / cells | 160 × 160 / 25,600 |
| Mesh vertices | **25,600** (shared, one per height cell) |
| Mesh triangles | **50,562** (`159*159*2`) |
| Mesh surfaces | **1** (one terrain draw; water quad is a second MeshInstance3D) |
| Height min / max / span | −1.9999688864 / +1.9998981953 / 3.9998670816 m (synthetic input) |
| `parse_dump` | 2.876 ms |
| `decode_heights` | 2.900 ms |
| `mesh_build` | **75.619 ms** |
| `total_build` | **82.245 ms** |
| Albedo | `res://assets/terrain/heightmap/splat_albedo.png`, 320×320 RGBA, runtime `Image.load` (PRESENT path exercised); alpha-as-transparency `false` |
| `has_chunk_or_fallback()` | `true` |
| `height_at_world(Vector2.ZERO)` | −0.9897650033 m (bilinear read of the built grid) |
| `height_at_world(Vector2(-160,-160))` | 0.0 m (clamped to grid corner, synthetic height 0) |
| `invalidate()` | child count 0 after call |
| Parse/load | clean — ticket 6 and 22 stderr both empty, exit 0 |

Timing variance on the shared machine is real; these are single-run numbers,
not averages, and they are for a 160² synthetic grid. G3-2's 102,400 verts /
203,522 tris / 129.168 ms at 320² are `app/` reference numbers, not this
module's measurements.

## 7. Open questions

1. No real dump under `variant3d`: the build probe used a synthetic 160×160 grid.
   A probe against a real `--dump-map` output (320², seed 20261113) would confirm
   vertex/triangle counts at donor default size; G3-2 measured 102,400 verts /
   203,522 tris / 129.168 ms mesh build in `app/`, **not** in this module.
2. Donor height-grid → mesh LOD connector is UNVERIFIED (G31); this port uses
   one vertex per cell with no decimation, explicitly not claimed as donor parity.
3. Donor absolute cell size in metres and the water-height literal are
   UNVERIFIED (port values only).
4. Splat alpha (normalised height data) is currently unused; a height-driven
   wetness/rock blend is a future G3-4/V7-9 decision.
5. V7-9 must supply the world environment / sun; this module supplies only
   geometry + water so integration does not duplicate lighting.
6. `bind()` accepts a dump dictionary OR a live `C3Game`; if the integrating
   `world3d.gd` exposes the dump under a different key, `_dump_from_game()` needs
   that key added.
