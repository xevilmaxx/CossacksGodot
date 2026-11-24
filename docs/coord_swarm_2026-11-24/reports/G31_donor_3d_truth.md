---
owner: G3-1
date: 2026-11-24
role: read-only recon (no code/asset/config edits, no Godot runs)
lane: Wave 6 donor-3D truth re-verification
donor: C:\Games\Cossacks 3 (private use, read-only; Python bytes+latin-1; never executed/copied)
output: docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md
---

# G3-1 — Donor 3D truth re-verified; M0.6 failure causes; heightmap feasibility

## 0. Method and boundaries

- Read first: `docs/audit/RENDER_ARCH_SYNTHESIS.md`, `RENDER_ARCH_CAMERA.md`,
  `RENDER_ARCH_TERRAIN.md`, `RENDER_ARCH_SHADERS.md`, `docs/research/T6_S01_camera.md`,
  `docs/t6/reports/T6-S01.md`, `docs/SWARM_BOARD.md:394-428`, and the Wave-6 charter.
- FRESH donor evidence below was re-read directly from `C:\Games\Cossacks 3` with Python
  byte reads decoded as latin-1 (binary headers via `struct`). No donor file was run or copied.
- Labels: **observed** = literal file line / binary header / filesystem fact; **derived** =
  arithmetic or control-flow consequence of observed facts; **inferred** = plausible reading
  with a stated caveat; **UNVERIFIED** = not provable without running the donor or RE-ing
  the binary further.
- Port side read-only: `app/scripts/world3d.gd`, `terrain3d_sandbox.gd`, `main.gd`,
  `game.gd`, `config.gd`, `data.gd`.

## 1. Already-established donor 3D facts (prior evidence ids, not re-trusted blindly)

| Area | Established fact | Evidence id / doc |
|---|---|---|
| Renderer | Live OpenGL 1.x imports; D3D9 imported with 0 xrefs; RTTI `XCamera/XWorld/XTile/XLightShader/XShadowMap/XWaterShader` | `RENDER_ARCH_SYNTHESIS.md:15` |
| Projection | 5-way switch at renderer `+0xC8`: `0=glFrustum`, `1=glOrtho`, `2=gluOrtho2D` (HUD), `3=callback`, `4=matrix`; default constructor sets `0` | `ev_030dff8c…`, `ev_10f78080…`, `ev_0f634d4b…`, `ev_f05b04f6…` (T6_S01_camera.md:39-54,86-125); `ev_cc0ee18b…` (glFrustum, 1 real call), `ev_3e2611e3…` (glOrtho, 1), `ev_9974b6a2…` (gluOrtho2D, 1), `ev_c6949392…` (gluPerspective, 0) |
| Camera | Main RTS camera = focal 400, tilt −32°, dolly 20–58; no ortho extent key anywhere in `data/**` | `RENDER_ARCH_CAMERA.md:175-184`; `camera.cfg:32-35,44-45`; `default.cameras:17-18` |
| Terrain | Lit `normal` materials, `verticalfront`/`verticalside` faces, `ShadersSM20.HeightField` with shadows/fog, `HeightTileZones`, explicit `terrainmesh*.osm` | `E3-E9`, `E15`, `E18`, `E20-E21` in `RENDER_ARCH_TERRAIN.md:87-108`; `C1-C4` in `RENDER_ARCH_SHADERS.md:332-335` |
| Shaders | 109 GLSL programs: `gl_Vertex`/`gl_NormalMatrix`/`gl_LightSource[0]`, Blinn–Phong, TBN normal maps, `boneMatrices[16]`, 3-/9-tap PCF, cube reflections, depth SSAO/DOF/FXAA | `E1-E29` in `RENDER_ARCH_SHADERS.md:132-160` |
| Heightfield resolution | Grid = map grid: 256²/320²/480²/640² by size setting, cap 640², 2× collision grid | `miscext2.script:19-26,45`; `dmscript.global:132-135`; `T6_S01_camera.md:174-215` |
| Mesh LOD from height grid | **UNVERIFIED** (RTTI `HXHeightField`, `XTerrainData`, `XTile` only; no plaintext connector) | `T6_S01_camera.md:216-222`, claim 14 |

## 2. Fresh donor verification (this session)

### 2(a) Main-view projection: perspective only; ortho/2D is HUD/debug

- Fresh byte-read of `data\cameras\camera.cfg:44-45` = `MinFocalLength`/`MaxFocalLength` both
  `400`; `:32-35` all four tilt slots `-32`; `:6-10` `SphereHeight/Length` `20..58`;
  `:51-64` fixed DOF/fog. `default.cameras:4-18` carries `Target/Pos/Dir/Up` X,Y,Z with
  `DirZ=-1`, `UpY=1`, `FocalLength=400`, `DepthOfView=1200`. No `OrthoWidth`, `OrthoHeight`
  or equivalent in either file. **observed.**
- Fresh scan of **1,710** plaintext files under `data\**` (`.script/.inc/.cfg/.lib/.global/
  .txt/.source/.ref/.mat/.frag/.vert/...`, latin-1, NUL-filtered): **0 hits** for
  `glOrtho`, `glFrustum`, `gluOrtho` or `SetPerspective`. Projection is selected in the
  binary, not by scripts/config. **observed.**
- Fresh read of alternate camera profiles: `cameradebug.cfg:30-43` (focal 86–100, tilt
  −30…−48°, height 5–19) and `camerascreenshot.cfg:32-48` (focal 95, tilt −90…+20°,
  `Bounded=False`). These are separate debug/screenshot presets selected by
  `docreate.inc:59,94` (`cCamFilename = .\data\cameras\camera.cfg`,
  `SetCameraDynamicFocalLength`) — the main view still takes `camera.cfg`. **observed.**
- Fresh EXE string counts (`cossacks.exe`, 5,768,048 B): `HXHeightField` ×1, `XCamera` ×19,
  `XTerrainData` ×25, `XTile` ×39, `XShadowMap` ×4, `XWaterShader` ×4, `Billboard` ×7,
  `Sprite2D` ×0. **observed.**
- **Answer:** the main world view has **no true ortho/2D branch**. The `gluOrtho2D` branch
  (`+0xC8==2`) is the flat HUD pass; `glOrtho` (`==1`) is an unreachable-by-default
  alternative setter. The near-isometric *look* comes from a fixed −32° tilt and long focal
  length, not from an orthographic projection. Editor/minimap/debug use of `glOrtho` remains
  **UNVERIFIED** (do not assert).

### 2(b) Heightfield data source and resolution

- **Grid resolution (fresh):** `data\scripts\lib\miscext2.script:19-26` maps `mapsize`
  0/1/2/3/else → `w = 320/480/640/256/320`; `:45` calls
  `SetMapNeeded(filename, zonename, presetname, w, w, ...)`. `dmscript.global:132-135`
  caps at 640×640 and allocates a 2× collision grid. **observed.** This is the height grid:
  `SetHeightData(x,y,h)` / `GetHeightData(x,y)` share the same coordinates
  (`generatemap.inc:242,574`; `texturemap.inc:433-437`). **derived (strong).**
- **Height source (fresh):** `generatemap.inc:537-547` samples a source/target bitmap into
  `gMapMask[x,y]` (R/B channels); `:552-577` under `cLoadHeightDataFromTexture` computes
  `hwater = cWaterHeight*(fb*(1+fr*3.5))` plus `cPlateauHeight/cHillHeight/cRavineHeight * fr`
  by cell terrain class and writes `SetHeightData(realx,realy,hwater+hterrain)`.
  `:230-243` then smooths via 4-neighbour `GetHeightData` reads. So the engine height source
  is a **per-map terrain bitmap, decoded into an engine height grid, then smoothed** — not
  a baked image. `loadtextureterrainfrombitmap.inc:8-42` separately assigns TileBlocks from
  `tile_lowground.bmp`/`tile_highground.bmp` based on `GetHeightData` (`cLowHeight = 0.1`).
  **observed.**
- **Height-driven texturing (fresh):** `data\gen\mapcover.cfg:5-18` `HeightTileZones[*]` with
  `Name=HeightZone0, MinHeight=0, MaxHeight=100` and seasonal tile names.
  `data\pattern\pattern.lib:8-33` (fresh read of its 1,172,416 lines) shows each terrain
  brush carries `HeightFieldStand=True`, `HeightFieldReplace[ForWater]`,
  `HeightFieldSmooth/Radius/Factor/Offset`, `HeightFieldMin/Max/Offset`, `TerrainScale`,
  `RotationAngle`, `CollisionStand` — patterns stamp **and smooth heightfield geometry**,
  not just 2D tiles. **observed.**
- **Shader binding (fresh):** `data\shaders\shaders.lib:15-52` `ShadersSM20.HeightField` →
  vertex `hf.pvl.sm.vert`, fragment `hf.pvl.smx3.frag`, `shadowColor/cameraMVM/fogMode/
  shadowed/vertexColor/texShadow/texGen = true`, `tangentSpace/boneMatrices = false`,
  two bound texture units. `hf.pvl.sm.vert:9,13,15,19,23,36,49` performs
  `gl_ModelViewMatrix*gl_Vertex`, `gl_NormalMatrix*gl_Normal`, `gl_LightSource[0]`, Blinn–
  Phong diffuse/specular, eye-plane texgen, shadow texcoord and `ftransform()`.
  `hf.pvl.smx3.frag:3,26-30` = 3-tap `sampler2DShadow` PCF; `hf.pvl.smx9.frag:25-34` =
  9-tap. **observed** — independent fresh confirmation of `E18`, `E4-E8`.
- **Relief LOD meshes (fresh, new partial answer to the UNVERIFIED LOD question):**
  `data\actors\env\terrainmesh{1,2,3,4}.osm` are real `IDP2` meshes (magic 844121161),
  decoded from their 68-byte headers: **2662 v / 5305 f**, **2272 v / 4532 f**,
  **2177 v / 4323 f**, **2509 v / 5002 f** (1 skin, 1 frame each; frame `FRAME 000......`).
  `terrainmesh1.actor:1-5` binds `LODList.Items[0].MeshObjects.LoadFromFile = ...terrainmesh1.osm`,
  with siblings 2/3/4 in `actors.lib:1200-1213`; each has summer/winter `.dds` albedo
  (5,592,560 B) and a `.prop`. **observed.** Donor therefore uses **4 discrete LOD relief
  props** for mountains/plateaus. Whether the *height-grid surface itself* is one mesh per
  cell or a decimated grid remains **UNVERIFIED** — no plaintext connector found.
- Water height source (fresh): `data\water\water.lib:45` leaves `HeightMapWaves0` commented,
  `:60` `HeightMapEnable = True`; `water.dev.frag` reads `hmapMin + w*(hmapMax-hmapMin)`.
  The literal engine binding of `hmapTex` stays **UNVERIFIED** (consistent with
  `WATER_REPORT.md §2.2`: engine-supplied height texture, not `heightmapwaves0.tga`).

### 2(c) Live meshes vs "baked 3D→2D sprites"

- Fresh decode `data\actors\units\yacht.oss` header: **311 frames @ 30 fps, 20 bones,
  584 verts, 947 faces, 793 UVs** — a genuine skinned mesh (`read_oss` layout in
  `app/tools/convert_models.py:43-66`). `yacht.osm` is a real `IDP2` mesh (the repo's
  `bake_naval.py:84-108` independently decodes 9,364 verts / 7,731 faces). The synthesis
  doc's "483 frames" is evidently a different unit; treat the count as mesh-specific.
  **observed.**
- Fresh filename scan of `data\**` for `sprite/facing/billboard/azim/frame`: only
  `framegun.*` (a weapon named "frame gun") and building decals with a `2d` suffix — **no
  pre-rendered unit facing/azimuth sheets**. The baked azimuth sheets in
  `app/assets/models/anim/**` are **port-side** conversion artifacts
  (`bake_sprites.py`, `bake_naval.py`), not donor assets. **observed** (negative search) /
  **inferred** (absence of sheets).
- Donor shaders transform and light geometry per frame (`gl_Vertex`, `gl_NormalMatrix`,
  `boneMatrices[16]` — `RENDER_ARCH_SHADERS.md E4-E6,E17`); that is incompatible with a
  runtime 3D→2D sprite bake as the *primary* entity renderer. **derived (strong).**
- Caveat: no runtime frame was captured (forbidden), so the absolute claim "donor never
  bakes any 3D to 2D for anything" stays **UNVERIFIED**; only the main rendering paradigm
  is refuted.

## 3. Why M0.6 failed visually, and what a full heightmap mesh changes

Concrete causes, from code + the recorded visual verdict:

1. **Flat per-tile quads = terraced mosaic.** `world3d.gd:7-8` states the design explicitly:
   "each tile is a flat top quad and every steep step gets a real vertical wall quad".
   `:207-224` emits one quad per tile at a single `y = height[z*n+x]` — no interpolation
   between samples. `:226-286` emits a wall at *every* discontinuity `> SIDE_EPS = 1e-4`
   (`:16`), producing grid-aligned bands; M0.5's `SIDE_STEP = 0.35` dead-band had left
   literal cracks, so the fix traded cracks for stripes. **observed.**
2. **Tiny window, no scene content.** `terrain3d_sandbox.gd:9-11` samples only a
   `WIN_N = 32` tile window (64 m) out of the 320² dump (~1% of the map), padded past the
   frame edges (`:180-181`). The captured stats list what is absent
   (`terrain3d_sandbox.gd:203-209`): units/buildings/trees/decor, HUD/minimap/fog, water
   refraction/DOF/fog, donor 25° oriented face art, donor sub-atlas UV seams. The
   coordinator's verdict (`SWARM_BOARD.md:410-412`): "donor depth comes from organic eroded
   relief + scene content (trees, shadows, units), which a donor-block heightfield cannot
   supply at this stage". **observed.**
3. **Lighting compensation, not donor lighting.** `world3d.gd:21-30` raises exposure to
   1.45, ambient 1.10, sun 1.7, emission 1.0, albedo gain 1.05 to recover ~30% sRGB loss;
   `:72-96` lightens the wall material after near-vertical-sun blowout. Flat quads have a
   constant `Vector3.UP` normal (`:222`), so continuous per-face lighting cannot appear.
   **observed.**
4. **Sensor/FOV unresolved and a bad trade-off.** `terrain3d_sandbox.gd:24-36` records that
   the donor sensor constant is unknown. M0.5's "physically sane" 36 mm / f-400 derivation
   gave **2.90° V-FOV** and flattened depth into a top-down mosaic; M0.6 switched to a
   216 mm "display sensor" giving **17.27° V-FOV** at 40 m / 64 m to make vertical faces
   visible (`SWARM_BOARD.md:415-420`). Both are assumptions; `fov_verified = false`
   (`terrain3d_sandbox.gd:182-188`). **observed.**
5. **Metrics passed while visuals failed.** M0.6 fixed tilt, padding and wall normals
   (cliff-band metric 2921→0, seam gaps 0, ground luminance 80.65, 78 draw calls / 16 ms)
   yet still "reads as a flat top-down tile mosaic" (`SWARM_BOARD.md:407-410`). The gate
   rule "metrics never override visual review" governed. **observed.**

**A full-grid heightmap mesh (one vertex per `height[]` sample) would fix:**

- the per-tile flat-top terrace: shared vertices + interpolated/smoothed normals give
  continuous relief instead of 32×32 hard-edged quads and grid-aligned wall stripes;
- border/seam artifacts: the whole 320² grid has no artificial window edge, skirt or
  perimeter lip to feather;
- lost resolution: all 102,400 height samples are used, not a 32×32 window — real relief
  everywhere, including ravines/hills away from the chosen crop;
- continuous lighting: per-vertex normals from height gradients + `DirectionalLight3D`
  shadows on a continuous surface, replacing the constant-normal flat quads;
- camera framing pressure: with a whole map visible, FOV/dolly need not be twisted to make
  a tiny patch fill the frame.

**It would NOT fix (set expectations for G3-2/G3-3):**

- missing trees/buildings/units/decals/tile face art and fog/HUD — a heightmap is bare
  ground; those need the deferred M1+ object pass;
- donor-shaped relief if the *height values* are wrong: the port's `height[]` comes from a
  procedural generator (`game.gd:1008-1009`), not the donor bitmap+pattern brush pipeline
  (§2b). A better mesh cannot invent donor escarpments the samples do not contain;
- donor's `verticalfront`/`verticalside` 25°-oriented striated face art and sub-atlas UVs
  (a smooth surface has no discrete wall faces unless G3-2 adds a wall/steepness treatment);
- donor's 3-tap/9-tap PCF + fog (`E8`, `E14`, `E19`) and water reflection/height-depth —
  Godot `StandardMaterial3D` only approximates them;
- the unknown donor sensor/FOV (§2a) — still an assumption to A/B visually;
- sim / HUD / fog-of-war / picking seams — unchanged by a render-mode experiment.

## 4. Heightmap feasibility: the dump and its grid

- Producer: `main.gd:672-702` `_dump_map()` calls `game.setup(start_mode)` then serialises
  `"map_w": game.MAP_W`, `"map_h": game.MAP_H`, `"height":
  Marshalls.raw_to_base64(game.height.to_byte_array())`, plus `terrain`, `blocked`,
  `tileblock` (byte arrays), `starts`, `clusters`, `res`, `meta`. CLI `--dump-map <path>` is
  parsed at `main.gd:1117-1119` and dispatched at `:196`. **observed.**
- Grid size: `game.gd:355-365` sets `MAP_W/H = Data.MAP_W/H` and resizes `height` to
  `MAP_W*MAP_H`. `data.gd:33-34` declares a static 160 default, **but**
  `config.gd:405-406` overrides it to `gameplay.map_width_tiles/height_tiles = 320` by
  default on `load_all()` (`main.gd:156-157`); `main.gd:338-341` only overrides when a
  `mapsize`/`map_size` config key exists. Therefore a plain
  `--dump-map ... --seed 20261113` with no config override yields a **320×320** height
  grid = **102,400 Float32 samples** ≈ 400 KB raw (≈533 KB base64). **derived (strong).**
  The 160² figure is the pre-config static default, not the dump. **observed.**
- `app/shots/final_fullmap_dump.json` is **MISSING** (verified by filesystem `Test-Path`;
  also `WAVE6_3D_CHARTER.md:14`). It must be regenerated with G3-2's own runner id
  (`g32-dump`) per the charter; do not reuse a wave-5 id. **observed.**
- Vertex mapping (derived from `world3d.gd:182-224`): for `y in 0..H-1`, `x in 0..W-1`,
  `idx = y*W + x`; height bytes are little-endian Float32 at `idx*4`; vertex
  `p = Vector3((x - W/2)*TILE_M, height[idx]*HEIGHT_SCALE, (y - H/2)*TILE_M)` with
  `TILE_M = 2.0` and `HEIGHT_SCALE = 1.0` (`world3d.gd:12-13`: dump height is already in
  metres). Two triangles per cell → `(W-1)*(H-1)*2 = 203,522` triangles for 320², with
  102,400 shared vertices (vs M0.6's 32×32 = 1,024 flat quads over a 4×4 vertex top grid).
  Use `tileblock`/`terrain` base64 bytes at the same `idx` for G3-4 albedo/splat. **derived.**
- Indexing/height semantics are already exercised by the shipping sim: `main.gd:960-983`
  scans `game.height` with `y*MAP_W+x` indexing. **observed.**

## 5. Claim table

| # | Claim | Evidence (donor path:line + port path:line / evidence id) | Method | Verdict | Implication for G3-2 |
|---|---|---|---|---|---|
| 1 | Donor main world view is perspective 3D, not ortho/2D | D `camera.cfg:44-45,:32-35`; `default.cameras:4-18`; fresh 1,710-file scan = 0 projection keywords; `ev_030dff8c…`, `ev_cc0ee18b…`, `ev_10f78080…`, `ev_0f634d4b…`; P `terrain3d_sandbox.gd:89` | observed + derived (binary CFG) | **CONFIRMED** (derived strong; runtime byte unobserved) | Use `PROJECTION_PERSPECTIVE`; do not emulate ortho |
| 2 | Ortho/`gluOrtho2D` branch serves HUD, not the main view | `ev_3e2611e3…`, `ev_9974b6a2…`; D `cameradebug.cfg:30-43`, `camerascreenshot.cfg:32-48`; `RENDER_ARCH_CAMERA.md:92-98` | observed + derived | **PARTIAL** (HUD confirmed; editor/minimap `glOrtho` UNVERIFIED) | Ignore ortho; don't claim it is the main camera |
| 3 | Donor sensor/FOV constant unknown; "isometric" look is fixed tilt + long focal | D `camera.cfg:32-35,44-45`; `T6_S01_camera.md:168-170`; P `terrain3d_sandbox.gd:24-36,182-188` | observed + inferred | **CONFIRMED** (unknown) | Label FOV as assumption; A/B at ≥2 candidates |
| 4 | Terrain is a lit heightfield with real shadowed shader (per-vertex Blinn–Phong, PCF, fog) | D `shaders.lib:15-52`; `hf.pvl.sm.vert:9,13,15,19,23,36,49`; `hf.pvl.smx3.frag:3,26-30`; `smx9.frag:25-34`; `E18`, `C1-C4` | observed | **CONFIRMED** | Smooth normals + light essential; flat quads are not donor-like |
| 5 | Height grid = map grid, 256²/320²/480²/640²; height stored per cell | D `miscext2.script:19-26,45`; `dmscript.global:132-135`; `generatemap.inc:242,574`; `texturemap.inc:433-437` | observed + derived | **CONFIRMED** | 320² dump matches donor default size; use every sample |
| 6 | Height source = per-map terrain bitmap → engine grid → smoothing; height drives tiles | D `generatemap.inc:537-577`, `:230-243`; `loadtextureterrainfrombitmap.inc:8-42`; `mapcover.cfg:5-18`; `pattern.lib:8-33` | observed | **CONFIRMED** | Splat albedo by height/tileblock, not flat per-cell quads |
| 7 | Donor has 4 LOD relief meshes (`terrainmesh1..4.osm`) with DDS albedo | D fresh header decode: 2662/5305, 2272/4532, 2177/4323, 2509/5002 (v/f); `terrainmesh1.actor:1-5`; `actors.lib:1200-1213`; `E20-E21` | observed | **CONFIRMED** (relief LOD; height-grid mesh LOD still UNVERIFIED) | Bare heightmap still lacks these props — defer to M1 |
| 8 | Donor renders live 3D meshes + skeletal animation; no unit facing sheets found | D `yacht.oss` 311f/30fps/20 bones/584v/947f; `yacht.osm` IDP2; filename scan of `data\**`; `E17`; P `bake_sprites.py:551-560`, `bake_naval.py:84-108` | observed + inferred (absence) | **CONFIRMED** for live meshes; absolute "never bakes" **UNVERIFIED** | "Optimized 2D perspective" is a port approximation, not donor paradigm |
| 9 | M0.6 failed because of flat per-tile quads + walls, 32×32 window, no scene content, lighting hacks, FOV trade-off | P `world3d.gd:7-8,16,21-30,207-224,226-286`; `terrain3d_sandbox.gd:9-13,24-36,203-209`; `SWARM_BOARD.md:407-428` | observed | **CONFIRMED** | Fix geometry shading/content; metrics alone are not a gate |
| 10 | M0.6's numeric metrics improved while visual verdict stayed FAIL | `SWARM_BOARD.md:407-412` (cliff metric 2921→0, seams 0, L 80.65, 78 calls/16 ms) | observed | **CONFIRMED** | G3-3 must deliver an honest visual A/B, not metric pass |
| 11 | `--dump-map` exports the full `height[]` Float32 grid plus tileblock/terrain | P `main.gd:688-695,1117-1119`; `game.gd:355-365` | observed | **CONFIRMED** | G3-2 can build one mesh from the dump without mapgen |
| 12 | Dump grid defaults to 320×320 (102,400 verts / 203,522 tris), not 160² | P `config.gd:405-406`; `game.gd:357-358`; `main.gd:338-341,689`; `data.gd:33-34` (static pre-config) | observed + derived | **CONFIRMED** | Size buffers for 320²; 160² only if a config forces it |
| 13 | Old dump `app/shots/final_fullmap_dump.json` is gone | Filesystem `Test-Path` = MISSING; `WAVE6_3D_CHARTER.md:14` | observed | **CONFIRMED** | Regenerate via `g32-dump` runner id before capturing |
| 14 | height[] → ArrayMesh mapping is `idx=y*W+x`, metres, TILE_M 2.0, shared verts | P `world3d.gd:12-13,182-224`; `main.gd:960-983` | derived | **CONFIRMED** | Implementation recipe for G3-2 (see §4) |
| 15 | Full heightmap mesh cannot by itself supply donor scene content, relief values, face art or FOV | D §2b/§2c; P `terrain3d_sandbox.gd:203-209`; `SWARM_BOARD.md:410-412` | derived | **CONFIRMED** | Scope G3-2 as terrain-only; do not promise donor fidelity |

## 6. Verdict on the owner's hypothesis and the heightmap approach

**Hypothesis** — "maybe donor were full 3D game with just optimized 2d perspective?":
**REFUTED as a donor paradigm, CONFIRMED as a description of our port.** Fresh and prior
evidence agree: the donor is a live 3D OpenGL renderer with a perspective main camera,
lit/smoothed heightfield, per-frame mesh/skeleton transforms and GLSL lighting/shadows.
What is "2D perspective" is the *shipping Godot port*: CPU-composited tile Images and
baked azimuth sheets (`RENDER_ARCH_SHADERS.md E30-E34`; `bake_sprites.py`). The near-isometric
look is a fixed −32° tilt + focal 400, not a 2D projection. The one honest residue is that
the donor's absolute FOV/sensor constant and the exact height-grid→mesh LOD are
**UNVERIFIED** without running the donor or deeper binary RE.

**Heightmap approach:** technically sound and the right next experiment — it attacks the
actual M0.6 geometry defect (flat per-tile quads and 32×32 sampling) using a dump that
really contains 320² Float32 heights. It is **not** a fidelity shortcut: relief quality is
bounded by the port's procedural height values, and trees/units, cliff face art, donor
shading and the FOV assumption are out of scope. Capture must be judged visually against
the donor still; improved metrics alone must not be allowed to pass the gate.

## 7. Open questions / hand-off

1. What is the donor's absolute FOV / sensor width for `f = 400`? No constant in `data\**`;
   both 2.90° (36 mm) and 17.27° (216 mm) are assumptions. G3-3 should A/B both.
2. Does the engine emit one vertex per height cell or a decimated mesh (LOD) for the
   heightfield surface? Only placed `terrainmesh*.osm` LODs are observed; the surface
   connector is **UNVERIFIED**.
3. Is `glOrtho` ever used by the editor/minimap/debug view? No evidence found; do not claim.
4. What is the literal engine binding of the water shader's `hmapTex`? `HeightMapEnable=True`
   is observed; the binding is **UNVERIFIED** (G3-2 should not bind `heightmapwaves0.tga`).
5. Synthesis doc says 483 animation frames; fresh `yacht.oss` has 311 — confirm which unit
   the 483 belonged to before quoting it again.
6. G3-2 must regenerate the dump (`g32-dump`), confirm `map_w/map_h = 320` from the dump
   header rather than assuming, and record actual vertex/triangle counts in its report.
7. Whether a steepness-based wall/face-art treatment is needed to recover donor cliff
   striations on a smooth grid is a G3-2/G3-4 visual decision, not a donor-doc fact.

No donor file was executed or copied; no repo code/asset/config was edited; no Godot run.
