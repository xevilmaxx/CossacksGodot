---
id: AUDIT3D-03
title: "AUDIT3D-03 — terrain / environment parity (variant3d vs app vs donor)"
owner: AUDIT3D-03
scope: "variant3d/scripts/world3d_terrain.gd, heightmap/splat tooling+output, water, fog overlay, sky/light; compare app/scripts/world.gd and read-only C:\\Games\\Cossacks 3"
date: 2026-11-24
status: AUDIT_COMPLETE__RENDER_PARITY_UNVERIFIED
verdict: "Runtime 3D terrain is a donor-height-driven full-grid mesh with a donor-block-derived STATIC albedo, but the runtime never wires the donor-grounded sky/sun rig; water and fog are port approximations."
---

# AUDIT3D-03 — Terrain / environment parity

## 1. Scope and method

Read-only audit. No source/asset/config/test edits, no git commands, no donor writes.
Files inspected: `variant3d/scripts/world3d_terrain.gd`, `world3d.gd`, `world3d_fog.gd`,
`world3d_entities.gd`, `picking3d.gd`, `main.gd`, `heightmap_world3d.gd`, `mapgen.gd`,
`game.gd`, `data.gd`, `config.json`, `project.godot`, `scenes/main.tscn`;
`app/scripts/world.gd`, `app/tools/heightmap_splat.py`, `app/tools/copy_assets.py`,
both `splat_albedo.manifest.json`, `app/shots/g32_dump.json`, `variant3d/tests/t_terrain3d.gd`;
donor text under `C:\Games\Cossacks 3\data\...` (read-only).
OBSERVATION = directly read. INFERENCE = reasoned from those reads. UNVERIFIED = no evidence
available in this audit. Donor binaries were never copied.

## 2. Bottom line — what is actually wired

**OBSERVATION.** `variant3d/config.json:38` defaults `render_mode` to `"3d"`;
`main.gd:573-576` and `main.gd:1003-1006` build the world via `make_world3d()`
(`main.gd:944-952` loads `world3d.gd`). `world3d.gd:70` names
`res://scripts/world3d_terrain.gd` as `TERRAIN_SCRIPT`; `world3d.gd:219-238`
instantiates it, binds the live game and calls `build()`. So the runtime terrain module is
**`world3d_terrain.gd`**, and the 102,400-vertex mesh claim is real in the default 320×320
configuration (`world3d_terrain.gd:229-260`, `config.json:39-41`).

**OBSERVATION.** `heightmap_world3d.gd` — the sibling module that owns the donor-grounded
`WorldEnvironment`, `ProceduralSkyMaterial` and `DirectionalLight3D`
(`heightmap_world3d.gd:114-147`) — has **no references anywhere in `variant3d`** (only
comments in `world3d_entities.gd:58` and `picking3d.gd:18`). `scenes/main.tscn` contains
only the `Main` node + `main.gd`; `project.godot:28` supplies only a dark clear colour.
**INFERENCE:** the donor light/sky rig is implemented but dead code; the shipping 3D view is
unlit except for the terrain's own emission floor (`world3d_terrain.gd:43-45,85-87`).

**OBSERVATION.** The splat PNG **is** consumed at runtime by `world3d_terrain.gd:40,63-70,217-225`
via raw `Image.load` (no Godot import sidecar required). Its provenance is genuine:
`manifest:12-16` records `app\shots\g32_dump.json`, seed 20261113, 320×320 and SHA-256
`79f93c2c…` — verified here to match the current dump byte-for-byte. The app/ and variant3d/
copies are identical (SHA-256 `B4DA4EBD…` for both). In contrast, `app/scripts/world.gd`
(2D shipping) never reads the splat — there it is tool/sandbox output only.

## 3. Evidence table

| # | Evidence (path:line) | Observation / inference | Relevance |
|---|---|---|---|
| E1 | `variant3d/config.json:21,38-41,71` | OBS: default 3d, 320×320, seed 20261113, `map_type=land`, fog off | Runtime configuration matches dump parameters |
| E2 | `variant3d/scripts/main.gd:573-576,944-952,1003-1006` | OBS: `make_world3d()` → `world3d.gd` after mapgen/tileblock assignment | Terrain binds post-mapgen, so `game.height[]` is final |
| E3 | `variant3d/scripts/world3d.gd:70,92,219-238` | OBS: `TERRAIN_SCRIPT = world3d_terrain.gd`; `bind()` → `build()` once | Identifies the **wired** terrain module |
| E4 | `variant3d/scripts/world3d_terrain.gd:191-203,229-260,244-249` | OBS: one indexed ArrayMesh, `nverts=w*h`, `ntris=(w-1)(h-1)2`, cell-centre verts, UV `(x+.5)/w` | 320² = 102,400 vertices; no chunks (`:304-305`) |
| E5 | `world3d_terrain.gd:112-145` | OBS: `_dump_from_game()` encodes live `game.height[]` via `Marshalls.raw_to_base64` | Mesh height is runtime sim data, not a baked file |
| E6 | `world3d_terrain.gd:40-41,63-70,217-225` | OBS: `SPLAT_PATH` loaded with `Image.load` of globalized path; grass1 fallback; plain material if both fail | Splat binding is robust but static |
| E7 | `variant3d/assets/terrain/heightmap/splat_albedo.manifest.json:10-16,422-430` | OBS: input `g32_dump.json`, sha256 `79f93c…`, seed 20261113, size 320×320, `texels_per_cell=1`, `water_block=sandsea6` | Provenance of the albedo |
| E8 | `app/tools/heightmap_splat.py:4-6,68-71,191-208,230-297,360` | OBS: tool reads **no donor file**; samples port block PNGs with LANCZOS to 1 texel/cell; alpha = normalised height; "No donor file read" | Albedo is port-block-derived, not a donor map texture |
| E9 | `app/tools/copy_assets.py:160-199`; donor `data/terrain/tiles/textures/*.dds` (present, read-only) | OBS: block PNGs converted from donor DDS; donor folder exists | Donor-derived art lineage, one step removed |
| E10 | SHA-256 of both `splat_albedo.png` copies = `B4DA4EBDEDBD…`; dump sha = `79f93c2c…` | OBS: files byte-identical; dump sha matches manifest | No drift between app/ and variant3d/ copies |
| E11 | `world3d_terrain.gd:19-20,43-45,73-88` | OBS: module explicitly creates no `WorldEnvironment`/`DirectionalLight3D`; `roughness=1`, `metallic=0`, emission `Color(.06,.06,.05)` | Runtime has no donor lighting |
| E12 | `variant3d/scripts/heightmap_world3d.gd:34-37,114-147` | OBS: donor `light.cfg` ambient/diffuse literals + sun vector from `water.dev.vert:22`, sky + `DirectionalLight3D` implemented **here**; no variant3d caller found | Donor-grounded rig exists but is unwired |
| E13 | `scenes/main.tscn:1-6`; `project.godot:21-28` | OBS: only `Main` node; `gl_compatibility`, clear colour `(0.09,0.11,0.08)` | No scene-level environment to inherit |
| E14 | `world3d_terrain.gd:148-175` | OBS: water = one flat translucent quad at y=-0.25, constant `Color(.19,.245,.255,.45)`, no texture/shader | Water is a flat port approximation |
| E15 | `app/scripts/world.gd:923-925,945-1010`; donor `data/water/textures/diffusewaves0-7.bmp` (9 files present) | OBS: 2D path uses donor wave sheets in an animated water shader with sun/depth ramp | Donor water art exists but unused in 3D at runtime |
| E16 | `world3d_terrain.gd:38,309` vs donor `data/scripts/common.inc/texturemap.inc:29-31` | OBS: port uses `-0.25`; donor `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` readable. Port comment calling donor literal "UNVERIFIED" is stale | Water level **is** donor-grounded; classification threshold vs plane Y still distinct |
| E17 | `world3d_fog.gd:168-215,42-44,177-178` | OBS: per-tile flat quads at raw `height[i]+0.03`; file itself flags mesh alignment as an OPEN QUESTION; `config.json:21` fog off by default | Fog can interpenetrate the bilinear mesh |
| E18 | `world3d_terrain.gd:332-348`; `world3d.gd:320-323` | OBS: `height_at_world()` bilinear sampler defined and exposed but no runtime call site found | Dead API |
| E19 | `world3d_entities.gd:413-416`; `picking3d.gd:110-113,125-148`; `game.gd:1893-1907` | OBS: entity Y and mouse pick both call `game.height_at()` on the live grid | Placement/pick agree with mesh only while both read the same bind-time grid |
| E20 | `game.gd:1897` (`clamp … MAP_W-1-0.001`) vs `world3d_terrain.gd:335-336` (`clamp … w-1`) | OBS: edge clamp differs slightly between the two bilinear samplers | Minor boundary discrepancy |
| E21 | `app/scripts/world.gd:817-836,1019-1034` | OBS: 2D uses 1024px mirror-tiled donor block images per chunk, with family blending | 3D flat 1-texel/cell mean colour is far coarser |
| E22 | donor `texturemap.inc:34-38` (`cPlaceForest`, `cPaintEnvironmentTextures`, `cSmoothForestBorders`) | OBS: donor paints forest/stone environment textures from the mask G channel; UNVERIFIED in port 3D | 3D "forest/dirt" is only tileblock mean colour + separate entity props |
| E23 | `variant3d/tests/t_terrain3d.gd:22-23,224-253` | OBS: atomic test verifies vertex count and `height_at_world()` on a 320×320 dictionary double, not a rendered frame | Test proof ≠ visual/runtime proof (AUDIT3D-09 scope) |
| E24 | `heightmap_splat.py:36-38,77-91` | OBS: roughness bytes are an admitted artistic proxy; donor exposes no roughness map | Roughness/specular parity UNVERIFIED |

## 4. Ranked gaps

### P0-1 — Runtime 3D terrain has no donor light rig or sky (blocks visual parity)
**OBSERVATION:** E11, E12, E13. The donor-grounded `WorldEnvironment` + `DirectionalLight3D`
exists in `heightmap_world3d.gd`, which the runtime (`world3d.gd:70`) never loads. The actual
terrain material relies on a small emission floor (`world3d_terrain.gd:45,85-87`) and the
project clear colour (`project.godot:28`). **INFERENCE:** the 3D view cannot reproduce donor
lighting/shadows — donor colours and sun vector are literally available
(`light.cfg:3-16,26-30`, `water.dev.vert:22`) but unused. `mi.cast_shadow=ON`
(`world3d_terrain.gd:274`) has no light to cast against. **UNVERIFIED:** no runtime frame
captured in this audit (AUDIT3D-09).

### P1-1 — Static albedo from one dump; no runtime consistency guard
**OBSERVATION:** E6, E7, E10, E5, E1. The albedo is a fixed 320×320 image baked from
`g32_dump.json` (seed 20261113, map_type land). Default config matches those inputs, so the
default skirmish is plausibly aligned; **UNVERIFIED** that current menu/quality options
reproduce the dump's `tileblock` byte-for-byte (no runtime comparison exists).
**INFERENCE:** any user change to `--seed`, map size or quality (`main.gd:178-181,361-364`)
keeps the mesh driven by the **new** live `height[]` but the albedo from the **old** dump —
colours will not match relief/tileblocks, silently.

### P1-2 — Water is a flat constant-colour quad, not the donor water surface
**OBSERVATION:** E14, E15, E16. Runtime water has no donor wave map, no depth ramp, no
foam and no sun response, whereas the donor wave BMPs and shaders are readable and the 2D
port already uses them. The port's `-0.25` is donor-grounded (`texturemap.inc:30`) but
`world3d_terrain.gd:38,309` incorrectly labels it UNVERIFIED. **INFERENCE:** a full-map plane
at y=-0.25 also tints every low-lying land cell, unlike the donor's per-texel water depth.

### P1-3 — Terrain albedo has no donor texture detail / no forest-stone environment painting
**OBSERVATION:** E8, E21, E22, E7. One texel per cell carries a blended **mean** RGB of donor
block PNGs; grass/rock/dirt read as flat colour patches. The 2D port keeps full 1024px
mirror-tiled donor grain per chunk. Donor `texturemap.inc:34-38` explicitly paints forest/
stone environment textures from the mask's G channel; the port's 3D splat uses only
`tileblock` IDs. **UNVERIFIED:** donor binding of environment-texture painting to the
heightmap mesh (no donor render proof in scope).

### P1-4 — Fog overlay quads can interpenetrate the heightfield
**OBSERVATION:** E17 and `world3d_terrain.gd:244-249`. Fog quads are flat at raw cell-corner
height +0.03; mesh vertices are at cell centres with bilinear slopes. **INFERENCE:** on steep
cells the flat fog quad cuts through the mesh (or floats above it). Mitigated by fog being
off by default (`config.json:21`); donor fog↔terrain binding remains UNVERIFIED
(`world3d_fog.gd:18-31`).

### P1-5 — `height_at_world()` is dead; placement/pick use a different sampler
**OBSERVATION:** E18, E19, E20. Entity Y and mouse picking call `game.height_at()` directly,
not the terrain module's bilinear sampler. Today both read the same bind-time grid, so they
coincide; but no code enforces that if terrain is rebuilt from a different dump (tool/test
path) the entity/pick ground will follow it. Edge clamp differs by 0.001 cell.

### P2-1 — Port-tuned material constants; splat alpha channel unused
**OBSERVATION:** E11, E24, `world3d_terrain.gd:77,79-84`. `roughness=1.0`, `metallic=0`,
cull disabled, emission floor; the A channel (normalised height) is explicitly never read.
Donor roughness data is unavailable (admitted proxy), so parity here is UNVERIFIED.

### P2-2 — Stale citation comments
**OBSERVATION:** E16. `world3d_terrain.gd:38,309` mark the donor water literal UNVERIFIED
although `texturemap.inc:30` is readable. By contrast the donor cell size in metres remains
genuinely UNVERIFIED (`world3d_terrain.gd:36,310`).

## 5. Smallest donor-grounded fix

**P0-1:** copy the existing `_make_environment()` body from
`variant3d/scripts/heightmap_world3d.gd:114-147` into `world3d_terrain.gd` and call it from
`build()` next to `_make_water(w,h)` (`world3d_terrain.gd:278`). Every value in that function is
already donor-cited — ambient/diffuse colours `light.cfg:3-16`, sun position `light.cfg:26-30`,
light-vector transform `water.dev.vert:22` — so no new art or invented constants are needed.
Then drop/reduce the emission floor (`world3d_terrain.gd:45,85-87`) so the donor sun, not an
emissive trick, lights the terrain.

Next smallest, donor-grounded: for P1-1, regenerate `splat_albedo.png` from a dump of the
**current** game via the existing `app/tools/heightmap_splat.py` whenever seed/size/menu inputs
change (the tool reads only port block PNGs derived from donor DDS via `copy_assets.py:160-199`).
Do not hand-author new colours.

## 6. Open questions

1. **UNVERIFIED:** do the default config values (`config.json:39-41,71`, quality, two nations)
   produce a `tileblock`/`height` grid byte-identical to `g32_dump.json`? No runtime comparison
   was found; the sha match only proves the tool's input, not the runtime map.
2. **UNVERIFIED:** was `heightmap_world3d.gd` intentionally left unreferenced in `variant3d`, or
   is its unwired donor rig an integration omission? (No caller found anywhere in `variant3d`.)
3. **UNVERIFIED:** donor water-plane Y (vs the `-0.25` terrain classification threshold used by
   the port) — `water.dev.frag:174` uses `waveheight=clamp(WL*3-1.5,0,1)`; the port's 2D path
   chooses `water_level=1.0` (`app/scripts/world.gd:965-968`). The 3D quad uses neither.
4. **UNVERIFIED:** donor sky background (texture vs clear colour). No donor sky DDS was found
   in the read-only scan; `ProceduralSkyMaterial` (`heightmap_world3d.gd:118-127`) is a port
   approximation, not a donor asset.
5. **UNVERIFIED:** donor binding of fog-of-war state to any terrain shader; the 3D alpha ladder
   is port state from `app/scripts/world.gd:2251-2255`, and donor depth fog is disabled in the
   gameplay camera (`camera.cfg:59`).
6. **UNVERIFIED:** actual rendered 3D frame (lighting, water, fog, albedo scaling). This audit
   is static; AUDIT3D-09 owns runtime/render proof.
