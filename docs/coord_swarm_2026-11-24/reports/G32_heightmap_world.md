---
title: "G3-2 — Full-map heightmap ArrayMesh 3D terrain experiment"
agent: G3-2
date: 2026-11-24
status: DELIVERED__CAPTURED__VISUAL_STILL_FLAT
verdict: GEOMETRY_FIX_VERIFIED__DONOR_FIDELITY_NOT_CLAIMED
claim_under_test: "one ArrayMesh from the entire dump height[] grid (not per-chunk reasoning) can replace M0.6's per-tile quads in a Godot 3D skirmish variant"
owner_files:
  - app/scripts/heightmap_world3d.gd
  - app/scripts/heightmap3d_sandbox.gd
  - docs/coord_swarm_2026-11-24/reports/G32_heightmap_world.md
artifacts:
  - app/shots/g32_dump.json
  - app/shots/hm3d_full.png
  - app/shots/hm3d_full.json
  - app/assets/terrain/heightmap/splat_albedo.png (regenerated via G3-4 tool on G3-2 dump)
scope: singleplayer skirmish terrain only; no donor binaries copied
---

# G3-2 — Heightmap-based 3D terrain (one mesh, one draw)

## 1. Verdict in one paragraph

A single indexed `ArrayMesh` now covers the **entire** 320×320 dump grid:
**102,400 shared vertices / 203,522 triangles / 1 surface**, built in
**129.168 ms** (mesh section; 148.633 ms including dump parse + height decode).
It replaces M0.6's 32×32 tile window, 1,024 flat quads, per-step walls and
32×32/frame cap. A real 1280×720 windowed capture was saved
(`app/shots/hm3d_full.png`, 148 KB, non-blank gate PASS with luminance span
0.0800). **Honest visual verdict: still flat and near-uniform dark olive at
donor-valid framing; at overview it shows the whole map as a dark trapezoid
with a few lighter patches and thin water-plane lines — no organic relief,
no cliff face art, no trees/units/buildings, no donor lighting richness.**
This is a structural fix, **not** donor fidelity and **not** a visual PASS.
No donor binary was executed or copied; only donor text configs/scripts were read.

## 2. Exact new files and contents

### `app/scripts/heightmap_world3d.gd` (NEW, `extends Node3D`)

- `build_from_dump(dump: Dictionary) -> bool` — decodes `map_w/map_h` and the
  base64 little-endian `height[]` grid (`Marshalls.base64_to_raw` +
  `decode_float`), **full grid, no window arguments, no per-chunk dictionaries,
  no frame cap**. `idx = z*w + x` (row-major, `main.gd:688-695`).
- **One surface**: `w*h` cell-centre vertices at
  `Vector3((x+0.5-w/2)*TILE_M, height[i]*1.0, (z+0.5-h/2)*TILE_M)`,
  `TILE_M = 2.0` (`data.gd:23`); `(w-1)*(h-1)*2` triangles with `+Y` winding
  (`i00,i01,i10 / i10,i01,i11`), `ARRAY_VERTEX/NORMAL/TEX_UV/INDEX`.
- **Normals**: central finite differences of `height[]` over `2*TILE_M`
  (`_normal_at()`, one-sided at borders) — the direct heightmap analogue of
  donor `hf.pvl.sm.vert`'s `gl_NormalMatrix * gl_Normal`
  (`shaders.lib:16-19`). No constant `Vector3.UP` quads like M0.6.
- **UVs**: `(x+0.5)/map_w, (z+0.5)/map_h` — 0..1 across the whole map, aligned
  to G3-4's splat texels (cell centres, row-major north/west origin).
- **Albedo** (after coordinator handoff): loads
  `res://assets/terrain/heightmap/splat_albedo.png` at runtime via
  `Image.load(ProjectSettings.globalize_path(...))` → `ImageTexture`, falling
  back to a single donor `grass1.png` block. Runtime `Image.load` was required
  because a Python-generated PNG has **no Godot `.import` sidecar** — MEASURED:
  `load("res://...splat_albedo.png")` produced
  `ERROR: No loader found for resource` (`g32-shot` ticket 1322).
- **Channel mapping**: RGB = donor block albedo (sRGB, no lighting baked by
  the splat tool beyond the block art); **A = normalised dump height DATA**
  (0 = min, 255 = max) and is deliberately **NOT** used as transparency —
  `transparency = TRANSPARENCY_DISABLED` and the stats flag
  `alpha_as_transparency: false`. The A channel is available for a future
  height-driven blend but is currently unused (see open questions).
- **Water/light/environment**: one translucent quad at `WATER_LEVEL = -0.25`
  (`mapgen.gd:29`, C3MapGen.WATER_DEEP); `DirectionalLight3D` + `WorldEnvironment`
  (ProceduralSky, ambient, LINEAR tonemap exposure), 1 expected terrain draw.
- **Measured timings stored in `stats`**: dump parse, float decode, mesh build,
  total build (ms, `Time.get_ticks_usec()`).

### `app/scripts/heightmap3d_sandbox.gd` (NEW/overwritten stub, `extends SceneTree`)

- **Why not `extends Node3D`:** the M0 sandbox is a Node3D scene, but a
  `--script` CLI harness must be a `SceneTree`/`MainLoop`. MEASURED probe
  `g32-cli-probe` (ticket 1312) with `extends Node3D`:
  `ERROR: Can't load the script ... as it doesn't inherit from SceneTree or MainLoop`
  (`main/main.cpp:4385`). This harness therefore loads/instances the Node3D
  world with `load("res://scripts/heightmap_world3d.gd")` and adds it to
  `get_root()`, preserving M0's dynamic-load/no-`class_name` pattern.
  Also note `SceneTree._process` must return `bool` (ticket 1319 parse error
  when declared `-> void`).
- CLI args: `--dump=<res path>`, `--cam-scale=<float>`, `--stay`.
- Camera: `PROJECTION_PERSPECTIVE`, focal **400 mm** (`camera.cfg:44-45`),
  tilt **−32°** (`camera.cfg:32-35`), assumed 216 mm "display sensor"
  ⇒ 17.2716° V-FOV (**UNVERIFIED**, M0.6 visual assumption), default height
  **40 m** (inside donor 20..58, `camera.cfg:6-10`), dolly `h/tan(32°)`,
  near 0.1, far 4000 (PORT choice; `default.cameras:10 DepthOfView=1200` is not
  a donor far-plane constant). Final capture used `--cam-scale=15`
  (600 m / 960.2 m) for an overview — explicitly flagged
  `donor_height_range_ok: false`, diagnostic only.
- Capture: root window set to 1280×720; at rendered frame 30,
  `await RenderingServer.frame_post_draw`, then
  `get_root().get_texture().get_image().save_png("res://shots/hm3d_full.png")`,
  non-blank check by luminance span over a 64×64 sample grid, stats JSON
  `res://shots/hm3d_full.json`, `call_deferred("quit", 0)`.
- No existing file was edited (`world.gd`, `world3d.gd`,
  `terrain3d_sandbox.gd`, `main.gd` untouched). The splat PNG/manifest were
  **regenerated by G3-4's own tool** at coordinator request.

## 3. Donor literals used (read-only; singleplayer skirmish)

| Decision | Donor source | Port value |
|---|---|---|
| Perspective main camera | `data/cameras/camera.cfg:32-35,44-45`; `default.cameras:4-18`; G3-1 claim 1 | `PROJECTION_PERSPECTIVE` |
| Focal length 400 | `camera.cfg:44-45` (`MinFocalLength = MaxFocalLength = 400`) | `FOCAL_LEN = 400.0` |
| Tilt −32° | `camera.cfg:32-35` (all four FreeRotation slots) | `TILT_DEG = 32`, rotation.x = −32° |
| Camera height 20..58 | `camera.cfg:6-10` (`SphereHeight 58`, `Min 20`) | default 40 m (in range); overview 600 m (out of range, flagged) |
| Sun direction | `env/lights/light.cfg:26-29` Position (−0.344731, 0.938701, 0) + `shaders/water/water.dev.vert:22` `lightVector=(x/4, z/2, y)` Z-up → Godot Y-up | `(−0.0861828, 0.9387015, 0)` |
| Ambient / diffuse colour | `light.cfg:3-8` / `:11-16` | literal `Color(0.1961,0.1843,0.1294)` / `Color(0.8118,0.7804,0.6941)` |
| Heightfield shader model | `shaders/shaders.lib:16-19` → `hf.pvl.sm.vert` (normal transform, Blinn–Phong) | finite-difference normals + `DirectionalLight3D` (approximation, not a copy) |
| Height source | `scripts/generatemap.inc:537-577` (bitmap → grid → smoothing) | dump `height[]` from `main.gd:688-695` (port procedural generator) |
| Relief LOD props | `actors/env/terrainmesh1..4.osm` (G3-1 claim 7) | NOT present — deferred |

**UNVERIFIED (not guessed):** donor absolute sensor width / FOV; donor
height-grid→mesh LOD connector; donor terrain cell size in metres; donor
water-height literal; whether donor `.osm` relief meshes are the only relief.
`HEIGHT_SCALE = 1.0` and `TILE_M = 2.0` are **port** facts (`world3d.gd:12-14`,
`data.gd:23`), not proven donor units. Art-pass **energies** (exposure 2.4,
ambient 2.5, sun 2.2, albedo gain 1.15, emission 0.12) are explicitly
PORT-TUNED, not donor constants — see §6.

## 4. Dump generation (MEASURED)

Flag syntax verified first in `app/scripts/main.gd:1117-1119` (`--dump-map`
consumes the next arg) and dispatch at `main.gd:195-197`.

```
python app\tools\godot_runner.py run --id g32-dump --timeout 240 -- --headless --path app -- --dump-map app/shots/g32_dump.json --seed 20261113
```

Result: ticket **1311**, status **ok**, wait 428.94 s, run 42.53 s, exit 0.
Dump: `app/shots/g32_dump.json`, 1,076,863 bytes,
sha256 `79f93c2c1c69c816006e73b122bb9d3b0ad16b1797387b6b6c4262b67963f3de`.
Decoded: `map_w = map_h = 320` (matches G3-1 claim 12; the 160 in `data.gd:33`
is pre-config), `height` base64 → 409,600 bytes = 102,400 little-endian
float32, range **−2.9639999866 … +2.9639999866 m** (span 5.928 m);
`tileblock` 102,400 bytes; seed 20261113. The full `height[]` grid is present.

G3-4 splat regenerated against this exact dump per handoff:

```
python app\tools\heightmap_splat.py --dump app\shots\g32_dump.json --out app\assets\terrain\heightmap\splat_albedo.png
```

Result: 320×320 RGBA; PNG sha256
`b4da4ebdedbddc6acba3b77f4f94a1f1a17f5e3a2c5ad6e2496d9438603d1c06`;
manifest `input_dump_sha256` equals the dump sha above, `input_seed = 20261113`.

## 5. Runner jobs and results (all via `app/tools/godot_runner.py`)

| Ticket | id | Command / purpose | Result |
|---|---|---|---|
| 1311 | `g32-dump` | headless `--dump-map`, seed 20261113 | **ok**, run 42.53 s, full 320² dump |
| 1312 | `g32-cli-probe` | `extends Node3D` + `--script` probe | **failed** (expected): Node3D not a MainLoop — proves SceneTree harness requirement |
| 1319 | `g32-shot` | first sceneTree shot attempt | **failed**: `_process` signature must be `-> bool` |
| 1322 | `g32-shot` | shot with grass1 fallback | **ok**: verts/tris correct; splat `load()` failed (no `.import`); capture dark L 0.134, span 0.0459 |
| 1324 | `g32-import` | `--headless --path app --import` | **failed** (exit 1, no diagnostic) — abandoned; runtime `Image.load` used instead |
| 1326 | `g32-import2` | `--headless --path app --editor --quit` | **failed** (exit 1, no diagnostic) — abandoned for same reason |
| 1327 | `g32-shot` | splat runtime load, donor-valid 40 m camera | **ok**: capture saved but `non_blank=false` (span 0.0059 < 0.02), mean L 0.206 |
| 1331 | `g32-shot` | overview `--cam-scale=15` | **ok**: non_blank=true (span 0.080) |
| 1332 | `g32-shot` | stats-framing fix | **failed**: local `height_m` used in `_capture_async` (scope error) |
| **1334** | `g32-shot` | **final** `--cam-scale=15` | **ok**, run 6.55 s, exit 0, **stderr empty** |

Final job stdout:

```
heightmap3d: ready grid={ "w": 320, "h": 320, "cells": 102400 } verts=102400 tris=203522 fov_v=17.2716045379639 pos=(0.0, 600.0, 960.2007) dump_parse_ms=29.229 build_call_ms=222.961
heightmap3d: captured res://shots/hm3d_full.png non_blank=true
```

## 6. Measured stats (from `app/shots/hm3d_full.json`, final job 1334)

| Metric | MEASURED |
|---|---|
| Grid / cells | 320 × 320 / 102,400 |
| Mesh vertices | 102,400 (shared, one per height cell) |
| Mesh triangles | 203,522 (`(319*319)*2`) |
| Mesh surfaces | 1 (one terrain draw; total frame mean 2.0 incl. water) |
| Mesh build | **129.168 ms** (height decode 8.261 ms; dump parse 9.071 ms; total 148.633 ms) |
| Height min / max / span | −2.964 / +2.964 / 5.928 m |
| Camera | perspective, tilt −32°, focal 400 mm, assumed sensor 216 mm ⇒ V-FOV 17.2716°, height 600 m, dolly 960.2 m, position (0,600,960.2) |
| Capture | 1280×720, source 1280×720, `resized: false`, PNG saved |
| Non-blank | **true** (luminance span 0.08004 over 4,224 samples; mean L 0.18887) |
| Frame performance | 26 samples, mean draw calls 2.0, mean process 9.35 ms, mean delta 15.68 ms |
| Parse/load | clean (final stderr empty; no script errors) |
| Albedo | G3-4 splat 320×320 RGBA, 0..1 UV; alpha-as-transparency false |
| Shot sha256 | `fc7b21e0732b0230494735dd0dbc52191dd654df4d77502a156f8518f236ba03` |

Timing variance is real (mesh build 129–549 ms across jobs 1322/1327/1334 on a
shared machine); all values are from the same machine and runner, not averages.

## 7. What improved vs M0.6 — and what did NOT

**Improved (structural, measured):** full 320² grid used instead of a 32×32
window (1% of the map); one indexed surface instead of 1,024 independent flat
quads + ~hundreds of wall quads; continuous finite-difference normals instead
of constant `Vector3.UP`; no artificial window edge/skirt/seam; one terrain draw
call; 129 ms one-off build vs M0's 2-chunk/frame scheduling; donor literal
sun direction/colours rather than invented ones; G3-4 donor-block splat instead
of a single flat block.

**Did NOT improve (visual, honestly observed):** the final PNG reads as a
near-uniform dark olive full-map trapezoid with a few lighter rock/sand patches
and thin horizontal water-plane lines. At the donor-valid 40 m camera the frame
was even flatter (luminance span 0.0059, non-blank gate FAILED). There is no
visible organic relief at this scale, no donor `verticalfront/verticalside`
oriented striated cliff faces, no trees/units/buildings/decals/HUD/fog, no
3-tap/9-tap PCF or donor fog. Lighting is a PORT-TUNED compensation: using
literal donor ambient (0.196,0.184,0.129) with M0.6's energies produced mean
L 0.134 (nearly black), so exposure/ambient/sun were raised to 2.4/2.5/2.2 —
this is legibility tuning, **not** donor fidelity. The 216 mm sensor / 17.27°
FOV remains an assumption; `--cam-scale=15` (600 m) deliberately exits the
donor 20..58 m camera range to fit the whole map and is labelled diagnostic.

**Conclusion:** the heightmap concept fixes the M0.6 *geometry* defect; it
cannot by itself fix donor *visual* fidelity, which is bounded by the port's
procedural `height[]` values and missing scene content (G3-1 claims 9, 15).

## 8. Handoffs needed

- **G3-3 (visual A/B):** use `app/shots/hm3d_full.png` + JSON; A/B the donor-valid
  40 m / 64 m framing against `--cam-scale` overviews and both FOV candidates
  (36 mm ⇒ 2.90° vs 216 mm ⇒ 17.27°). Gate on visual review, not metrics.
  Flag the thin water lines and flatness explicitly.
- **G3-4 (splat):** texture regenerated and verified against `g32_dump.json`
  (sha match). A channel is currently unused as data; decide whether to
  expose it as a height-driven wetness/rock blend, and whether a
  steepness/cliff variant can recover donor face-art bands.
- **G3-1:** donor absolute FOV/sensor and height-grid→mesh LOD remain
  UNVERIFIED; no new evidence found in this lane.
- **Wave 7 V7-4 (`world3d_full`):** reuse `heightmap_world3d.gd`'s
  `build_from_dump()` mesh recipe (shared vertices, finite-difference normals,
  full-grid UVs) inside `variant3d/`; do NOT reuse the SceneTree capture
  harness (it is a test harness, not a world contract). No donor binaries.

## 9. Open questions

1. Donor absolute sensor width / FOV for focal 400 — still unknown (G3-1 Q1).
2. Does the donor heightfield surface use one vertex per cell or a decimated
   LOD? Only `terrainmesh1..4.osm` props are observed (G3-1 Q2).
3. Are donor height values really metres, and is the donor cell size 2 m?
   Port values only — UNVERIFIED.
4. Should splat A (normalised height) drive a shader blend, or should G3-4
   emit a roughness/terrain-class mask instead?
5. How to recover donor cliff striations on a smooth grid (steepness-based
   treatment) without reintroducing M0's wall stripes?
6. Is the flat local view caused by the port's procedural `height[]` (range
   ±2.964 over 640 m) rather than the mesh? Requires a donor-height-sample
   comparison, out of this lane.
7. The two import jobs (tickets 1324/1326) failed with exit 1 and no diagnostic;
   the runtime `Image.load` workaround is verified but the import cause is
   unexplained.
