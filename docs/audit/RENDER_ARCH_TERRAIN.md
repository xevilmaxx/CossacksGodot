---
title: Render architecture — is donor terrain a 2D sprite layer or a 3D textured surface?
owner: R-ARCH-TERRAIN (read-only research subagent)
decision: terrain beauty / render architecture
updated: 2026-11-21
status: FINAL — read-only; no code edit, no Godot run, no donor asset copied
scope: ONE document written — `docs/audit/RENDER_ARCH_TERRAIN.md` only
labels: observed / derived / inferred / UNVERIFIED (per SWARM_OPS.md §5b-QUALITY)
---

# R-ARCH-TERRAIN — donor terrain render architecture

> [!IMPORTANT]
> This is the **only file written** by this agent. The donor was accessed **read-only**
> as private-use data at `C:\Games\Cossacks 3`; no donor binary, DDS, lib, mat, shader or
> texture was copied into the repository. Port files were read only. No Godot process was
> started. Every claim below cites a donor `file:line` or a port `file:line`, or is labelled
> `inferred` / `UNVERIFIED`. Line numbers are 1-based and refer to the donor install as
> present on 2026-11-21.

---

## 1. Question and bottom line

**Question:** is the donor's terrain a 2D sprite/tile layer, or a 3D textured surface?

**Answer (verdict, high confidence): 3D textured surface.** The donor terrain is a
**height-field-driven 3D tile-block mesh rendered by a lit, shadowed, fogged 3D pipeline**,
with separate 3D height-fill meshes (`terrainmesh*.osm`, `terrainplateau*.osm`) for large
relief, and a separate 3D water surface. It is *not* a pre-rendered 2D sprite layer. The
port's `Sprite2D` + `canvas_item` compositor is therefore an architectural substitution,
not an equivalent implementation. Details in §4–§6.

---

## 2. Sources (all read-only)

### 2.1 Donor (private-use install, `C:\Games\Cossacks 3`)

| Id | Path | Role |
|----|------|------|
| D1 | `data\terrain\tiles\terrain.lib` | terrain-level material/scale/cover params |
| D2 | `data\terrain\tiles\tiles.lib` | 245 TileBlock slots; sub-atlas + face-angle metadata |
| D3 | `data\terrain\tiles\tiles.mat` | 253 material sections binding DDS art to face keys |
| D4 | `data\terrain\tiles\terrain.presets` | seasonal block sets (`Summer`, `WaterSet`) |
| D5 | `data\terrain\tiles\tiles.season` | per-tile season binding |
| D6 | `data\terrain\ref\reftile.lib` | tile block scheme/atlas template |
| D7 | `data\terrain\ref\reftile.mat` | **lit material template + vertical-face sections** |
| D8 | `data\terrain\ref\reftilealpha.mat` | alpha / alphavert / alphanull mask materials |
| D9 | `data\terrain\decals\decals.lib`, `decals.mat`, `decals.presets` | ground decals (lit) |
| D10 | `data\gen\globalparams.cfg` | generator size/heights/tile-smooth passes |
| D11 | `data\gen\localparams.cfg` | local height-field parameters |
| D12 | `data\gen\mapcover.cfg` | **height→tile-zone assignment**, seasonal tiles, light patterns |
| D13 | `data\gen\tilesmooth.cfg`, `tilesmooth_scripts.cfg` | tile compatibility smoothing rules |
| D14 | `data\shaders\shaders.lib` | **HeightField shader binding (lighting/shadow/fog)** |
| D15 | `data\shaders\obj\hf.pvl.sm.vert`, `hf.pvl.smx3.frag` | height-field shader programs (referenced, not opened) |
| D16 | `data\actors\env\terrainmesh1.actor`, `terrainmesh1.osm` (+2/3/4, plateau1–4) | **explicit 3D relief meshes** |
| D17 | `data\objects\env\terrainmesh*.prop`, `data\materials\env\terrainmesh*.dds` | mesh props + materials |
| D18 | `data\terrain\tiles\textures\*.dds` (grass/rock/sand/desert/winter) | tiled DDS surface art |

`data\shaders\terrain*` **does not exist as a file family**; the terrain shader is registered
under the generic `HeightField` key in D14 (`shaders.lib:16-52`). There is no `*.mat` shader
literal either — `Shader = [nil]` on the material templates (D7 `:5`, D8 `:5`, D9 `:5`)
means the engine supplies the shader by material/geometry class, and D14 is that binding.

### 2.2 Port (read-only, this repository)

| Id | Path |
|----|------|
| P1 | `app/scripts/world.gd` — `_build_chunk` `:1387-1525`, `_block_img` `:860-887`, `_setup_water_overlay` `:802-858`, `_face_collar` `:1323-1376` |
| P2 | `app/shaders/water_overlay.gdshader` — `shader_type canvas_item` `:1`, fragment `:93-173` |
| P3 | `app/assets/terrain/blocks/*.png` — derived DDS art (RGB-exact per prior arbitration) |
| P4 | `app/assets/terrain/dmask/d_*.png`, `masks/**`, `water_png/diffusewaves*.png` |
| P5 | `docs/audit/PIECES/rock_striation_arbitration.md` — port-vs-donor pixel identity, donor face metrics |
| P6 | `docs/audit/PIECES/shore_water_transition.md` — donor shore plaintext, port gap chain |
| P7 | `docs/audit/RENDER.md:30-62` — port render pipeline diagram |
| P8 | `docs/audit/TERRAIN_DONOR_PIPELINE.md` — donor generator plaintext pipeline (cross-check) |

---

## 3. Evidence table (claim | file:line | observed / derived / inferred)

### 3.1 Explicit 3D evidence in the donor

| # | Claim | file:line | Label |
|---|-------|-----------|-------|
| E1 | Terrain material carries a 3-component `TextureScale` (X/Y/Z) and `TextureScale` X=Y=Z=W=1 | D1 `terrain.lib:5-10`; D7 `reftile.mat:12-16` | **observed** |
| E2 | `CoverDisabled=true` — terrain "cover" is a selectable overlay layer on the height surface, not a sprite flag | D1 `terrain.lib:17` | **observed** (value) / **inferred** (role) |
| E3 | Materials are **lit**: `moNoLighting = False`, `moIgnoreFog = False` | D7 `reftile.mat:19-22`; D8 `reftilealpha.mat:19-22`; D9 `decals.mat:17-21` | **observed** |
| E4 | Full 3D material lighting model: `FrontProperties`/`BackProperties` with `Ambient`, `Diffuse`, `Emission`, `Specular`, `Shininess = 16`, `PolygonMode = pmFill` | D7 `reftile.mat:51-106` | **observed** |
| E5 | 3D raster states `BlendingMode = bmTransparency`, `FaceCulling = fcCull` (back-face culling implies oriented geometry) | D7 `reftile.mat:17-18` | **observed** |
| E6 | 3D texture coordinate generators: `mappingmode = tmmUser`, `tmmEyeLinear`; `mappingscoordinates`/`mappingtcoordinates` with X/Y/Z components; `texturewrap = twBoth` | D7 `reftile.mat:34-49`, `:129-141`, `:155-167`; D8 `:34-49` | **observed** |
| E7 | **Dedicated vertical faces.** `verticalfront` / `verticalside` sections use `Texture2Name = alphavert`, `TextureScale = 0.125`, and `mappingmode = tmmEyeLinear` with the **t-coordinate mapped to Z** (`mappingtcoordinates Z = 1`) — i.e. the side of a tile block is projected along world height | D7 `reftile.mat:120-144` (`verticalfront`), `:146-170` (`verticalside`); mask art D8 `:110-217` | **observed** |
| E8 | A **top/normal face** exists separately (`normalside`, refkey `normal`) | D7 `reftile.mat:110-118` | **observed** |
| E9 | Face-key usage is widespread in the real tile atlas: `tiles.mat` has 253 `section.begin`, of which 199 `refkey=normal`, **18 `refkey=verticalfront`, 18 `refkey=verticalside`, 18 `refkey=normalside`** (first at lines 142, 146, 218) | D3 `tiles.mat:1-5`, `:142`, `:146`, `:218` | **observed** (counts) / **derived** (face-role mapping via D7) |
| E10 | Tile blocks carry **sub-atlas geometry**: `TileSize = 64`, `Rows = 2`, `Cols = 2` for `sand1..sand4`; template defaults `TileScheme = tsDouble`, `TileType = ttExtended`, `TileXOffset = 0.1`, `TileYOffset = 0.2`, commented `AlphaRows=8`, `AlphaCols=4`, `AlphaTileSize=64` | D2 `tiles.lib:54-56`, `:60-62`, `:66-68`, `:72-74`; D6 `reftile.lib:3-12` | **observed** |
| E11 | **Oriented face blocks**: every `rockN`/`sandN` has a `vf` variant (`AngleX = 0, AngleZ = 25`) and an `vs` variant (`AngleX = 25, AngleZ = 0`). 72 `AngleX` lines / 245 `TileBlockName` slots in D2 | D2 `tiles.lib:118-207` (rock1vf…rock9vs), `:208-237` (sand1f…sand3s) | **observed** |
| E12 | Prior swarm note quoted "124 TileBlock slots"; the live install contains **245** `TileBlockName` lines — the "124" is a different subset (likely a single season/face family), not a contradiction of the architecture | D2 count (this audit); prior finding as given in ticket | **derived** (reconciliation) |
| E13 | **Height-field generator**: `Size = 512`, `Sharpness = 0.6`, `TileChangeFactor = 0.3`, `FrequencyFactor = 0.000013`, `DefaultMapSize = 256`, `TileSmoothPasses = 6` | D10 `globalparams.cfg:2-10` | **observed** |
| E14 | Local elevation data: `HillPointsDensity = 0.00008`, `MaxHillsHeight`, `HillsHeightFactor = 0.001`, `MinHeight = 0`, `MaxHeight = 0.0001`, `SmoothLevel/SmoothPasses/SmoothFactor` | D11 `localparams.cfg:2-17` | **observed** |
| E15 | **Tile selection is by elevation**: `HeightTileZones` with `Name = HeightZone0`, `MinHeight = 0`, `MaxHeight = 100`, and seasonal `SummerTileName`/`AutumnTileName`/`WinterTileName`/`SpringTileName` per tile | D12 `mapcover.cfg:3-12`; also D10 `:7` `TileSmoothListFileName` | **observed** |
| E16 | Climatic zones also carry `PatternCovers`, `LocalPresets`, `LightPatterns` (scene lighting is part of terrain cover config) | D12 `mapcover.cfg:14-32` | **observed** |
| E17 | Tile-compatibility smoothing passes name rock/rock/grass_ground/grass adjacency (rock faces blend into plateau tops by rule, not by pixel blit) | D13 `tilesmooth.cfg:1-120` | **observed** |
| E18 | **Dedicated height-field shader**: `ShadersSM20.HeightField` binds `vertex = hf.pvl.sm.vert`, `fragment = hf.pvl.smx3.frag`, with `shadowColor = true`, `cameraMVM = true`, `fogMode = true`, `shadowed = true`, `vertexColor = true`, `texShadow = true`, `texGen = true`, `tangentSpace = false`, and two bound texture units | D14 `shaders.lib:15-52` | **observed** |
| E19 | Bump/relief uniforms exist in the lit shader family: `bumpSmoothness = 2.0`, `bumpHeight = 0.55`, `specularPower = 1.0` | D14 `shaders.lib:392-417` (also `:401-407`, `:1300`, `:1411`) | **observed** |
| E20 | **Explicit terrain meshes**: `terrainmesh1.actor` (`refurl=refmountain.actor`) loads `terrainmesh1.osm` via `ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile`; siblings `terrainmesh2/3/4`, `terrainplateau1/2/3/4` exist with `.dds` materials and `.prop` files | D16 `terrainmesh1.actor:1-5`; D17 listing | **observed** (text), **inferred** (mesh semantics from `.osm`/`MeshObjects`) |
| E21 | `.osm` is a binary mesh container (`IDP2` header, dense IEEE-float triples) — not an image or sprite sheet | D16 `terrainmesh1.osm` (binary header) | **observed** (header) / **inferred** (float triples = vertex data) |
| E22 | Decal materials are lit (`moNoLighting = False`) with `tfAlpha` / `tiaDefault`, `bmTransparency` | D9 `decals.mat:1-45`; decal DDS family in `decals\buildings\*.dds` | **observed** |
| E23 | Seasonal texture remap is a first-class material field (`seasons.Summer/Winter`), plus per-tile `tiles.season` | D1 `terrain.lib:12-15`; D5 `tiles.season:1-4`; D4 `terrain.presets:1-5` | **observed** |

### 3.2 How one terrain cell becomes pixels (donor chain)

| Step | Mechanism | Evidence | Label |
|------|-----------|----------|-------|
| S1 | Generator produces a **height field** (`Size=512`, local hills, `MinHeight/MaxHeight`) | D10 `:2-10`; D11 `:2-17` | **observed** |
| S2 | Each cell's height picks a `HeightTileZone` → tile family per season | D12 `mapcover.cfg:3-12` | **observed** |
| S3 | Neighbouring tile families are compatibility-smoothed over 6 passes | D10 `:7`; D13 `tilesmooth.cfg` | **observed** |
| S4 | The chosen `TileBlock` resolves to a block with a **top face** and oriented **front/side faces** (sub-atlas `Rows/Cols`, `AngleX/AngleZ`) | D2 `tiles.lib:54-56`, `:118-207`; D6 `reftile.lib:3-12` | **observed** |
| S5 | Each face is a DDS material: top `refkey=normal` (DDS art bound at `tiles.mat:4` etc.); sides `refkey=verticalfront/verticalside` with `alphavert` eye-linear Z mapping; alpha masks `alpha.bmp`/`alphavert.bmp` | D3 `tiles.mat:1-5`, `:142`, `:146`; D7 `reftile.mat:1-170`; D8 `:30`, `:139` | **observed** |
| S6 | Material contributes Ambient/Diffuse/Specular/Shininess; lighting and fog are ON; back faces culled | D7 `reftile.mat:19-106` | **observed** |
| S7 | Geometry is drawn by the `HeightField` program with vertex transform, shadow map, texture-gen, fog, per-vertex colour | D14 `shaders.lib:15-52` | **observed** |
| S8 | Large relief is supplemented by placed 3D meshes (mountain/plateau actors) with their own DDS materials | D16 `terrainmesh1.actor:1-5`; D17 | **observed** (binding) / **inferred** (usage) |
| S9 | Water is a separate surface whose soft edge is a shader coast-fade over a 1-cell oriented `sandsea` rim, not a baked wide collar | P6 `shore_water_transition.md:55-71` (donor `texturemap.inc:472-511`, `water.dev.frag:198-199,227`) | **observed** (prior plaintext read) |

**Derived conclusion from S1–S9:** a terrain cell is a **lit 3D quad (or block face) with a
tiled DDS material in a scene with camera, lights, shadow maps and fog**, not a pre-rendered
sprite. The `FrontProperties`/`BackProperties` and vertical-face sections are inexplicable
in a 2D sprite compositor; they describe surface normals and face orientation.

---

## 4. Explaining the reference screenshots with this architecture

### 4.1 Near-vertical, striated rock faces

* Donor rock faces are the **vertical faces of elevated tile blocks** (E7/E9) and the
  placed `terrainmesh*/terrainplateau*` actors (E20), not a top-down texture stretched on
  a flat image. The `verticalfront`/`verticalside` material projects the DDS with
  `tmmEyeLinear` and **t=tZ** (D7 `:129-141`, `:155-167`) so the rock art runs *down* the
  face in world-height space; `alphavert.bmp` (D8 `:110-217`) masks the rim against the
  plateau top.
* Striations are therefore **texture anisotropy × face lighting**: the DDS already carries
  vertical flutes, and the face's normal-oriented diffuse/specular term (D7 `:51-106`) with
  shadowing (D14 `:22-28`) amplifies them. Prior measurement found the *raw* donor block
  `rock8` at VSI 1.33 (native) / 1.66 (256²) and the *rendered* donor face sub-boxes at
  VSI ≈1.45–1.53, crest ≈2.9 — i.e. rendering amplifies rock8's intrinsic flutes
  (P5 `:114-132`, `:165-177`). `rock1` is the strongest raw striation source (VSI 4.29,
  P5 `:84`, `:94-99`) and corresponds to the crest-only case.
* The **abrupt grass rim** (≤3 px, P6 C6) is exactly the alpha-masked top/side boundary
  (E7–E8), not a painted gradient. A 2D compositor must fake it with an alpha mask; it
  cannot derive it from a surface normal.

### 4.2 Soft water shoreline

* Donor softness comes from a **3D water surface shader**: shore/water thresholds
  (`cWaterHeight = -0.25`, `cWaterShoreHeight = -0.1`, P6 `:59-60`), an **oriented one-cell
  sandsea rim** selected by the 8-sector height-gradient angle (P6 `:61`), and a shader
  coast fade (`coast2water_fadedepth = 0.57`, deep `1.07`) with procedural `nautic()`/
  `particles()` foam (P6 `:63-67`). The measured 3-band profile (sand `#A69A79` → wash
  `#B1B3A3` → shallow water `#A8B1AB`, P6 `:25-38`) is a **depth-driven shade**, not three
  stacked sprite tiles.
* Because the fade is computed per-fragment against a depth field and a view/light vector,
  the band moves correctly under camera movement and responds to the scene light. The
  port's flat `#205060` water and 17–81 px tile stair-step (P6 `:77-100`) are the direct
  consequence of doing this in a 2D compositor at one texel per tile.

---

## 5. Port gap — what a 2D compositor cannot reproduce

### 5.1 Port architecture as read

* `world.gd:_build_chunk` (P1 `:1387-1525`) composites donor block **PNG** crops with
  `Image.blend_rect_mask` / `blend_rect` into one `Image` (`:1417`, `:1472`, `:1496`,
  `:1510`), then wraps it in an `ImageTexture` and a **`Sprite2D` at `z_index = -10`**
  (`:1516-1524`). Season tint and "relief shading" are baked as alpha overlays using
  `game.height_at()` sampled on a coarse `N×N` grid (`:1482-1510`). `_face_collar`
  (`:1323-1376`) paints a ravine face from stretched `rock8n`/`rock1n` crops with alpha
  masks — a 2D imitation of E7/E20.
* Water is one full-map `Sprite2D` with `shader_type canvas_item` (P2 `:1`), a per-tile
  coverage/depth mask, wave sheets and a fake normal from finite differences
  (P2 `:93-160`), explicitly **"no screen texture, no compute, no 3D effects"** (P2 `:10`).
* Port block PNGs are RGB-byte-exact copies of the donor DDS (P5 `:69-78`), so the *art* is
  faithful; what is missing is the *geometry and lighting model that consumed it*.

### 5.2 Properties IMPOSSIBLE to reproduce exactly in a 2D compositor

| Donor property | Why 2D cannot match exactly | Port best-effort / evidence |
|---|---|---|
| **Perspective/ortho-correct lighting per surface** | A 2D canvas has one normal (screen +Z). Donor lighting is per-face with distinct top (`normalside`) and vertical (`verticalfront/side`) normals (E7–E9) evaluated against scene lights (E3–E4, E18). A top-down blit gives every pixel the same incidence angle. | P1 `:1482-1510` notes a height-based darkening overlay — a scalar tint, not a normal·light dot product. |
| **Geometric parallax / occlusion** | Tiles and `terrainmesh*.osm` actors occupy 3D space (E20–E21). Elevated faces shift relative to the ground when the camera pans/zooms and can occlude units behind them. A `Sprite2D` at fixed `z_index` has no depth; parallax can only be faked with offset duplicate layers, never derived from the height field. | P1 `:1520-1523` fixed position/scale/z; no per-vertex depth. |
| **Height-based self-shadow / cast shadow** | The donor `HeightField` shader is `shadowed = true`, `texShadow = true`, `shadowColor = true` (E18 `:22-28`); faces shadow adjacent faces. 2D compositing has no shadow map, and a baked height→darkness function cannot produce direction-dependent cast shadows or crest occlusion. | P1 `:1504-1507` `shade = clamp(0.10 - hh*0.04*rscale, 0, 0.14)` — height-only, view-independent. |
| **Shore refraction / depth-refractive water** | Donor water is a 3D surface whose fade and specular depend on a surface normal and a view/light ray (`rd = normalize(sun - r0)`, high-exponent spec) and would sample the refracted scene beneath it. The port shader has no screen texture or 3D effects (P2 `:10`), so it cannot bend background pixels; it can only blend a colour over the baked bed (P2 `:94-172`, P1 `:1467`). | P6 `:92-100` documents the resulting flat colour and tile-step as structural, not tuning. |
| **True vertical-face texture projection** | Donor side faces use `tmmEyeLinear` with `t = Z` (E7). Stretching a top-down DDS crop (P1 `:1323-1341`) cannot reproduce view-correct foreshortening of a 25° oriented face (E11 `AngleX/AngleZ`). | P5 `:172-177` recommends rock8 fill + rock1 flutes "or geometry-driven lit/shadow shading" — i.e. the 2D fix is explicitly a synthesis, not exact. |
| **Fog / atmospheric integration** | Terrain and decal materials have `moIgnoreFog = False` / scene fog (E3, E16 `LightPatterns`); fog is distance/3D-position based. A 2D sprite gets one global fog overlay at best. | P7 `RENDER.md:60` shows a single `fog ImageTexture` layered over the scene. |

**Caveat (fairness):** a `canvas_item` shader *can fake* specular glints (P2 `:142-160`
does, donor-faithfully) and *can* fake soft shore alpha (P2 `:169-172`). Those are
approximations of the *shading terms*, not of the *geometry* that defines them. The four
items above are impossible to make exact — only plausible to approximate — in a 2D
compositor.

---

## 6. Verdict and concrete recommendation

### 6.1 Verdict

**Donor terrain is 3D.** Confidence **high**, based on five independent evidence classes:
(1) lit material model with front/back normals and shininess (E3–E5); (2) explicit vertical
face materials with eye-linear-Z projection and alpha rim masks (E7–E9); (3) a registered
`HeightField` shader with shadow/fog/camera-matrix inputs (E18–E19); (4) height-field
generator + elevation-driven tile zones (E13–E15); (5) real 3D terrain/plateau mesh actors
(E20–E21). The port's 2D PNG compositor is a deliberate re-architecture (P7 `:45-53`),
not a format conversion, and inherits the fidelity ceiling in §5.2.

### 6.2 Recommendation — Godot 4 Compatibility, 3D-ortho terrain

A faithful port should replace `_build_chunk`'s `Sprite2D` output with a **3D mesh surface
rendered by an orthographic camera**, while keeping the existing 2D interaction layer.

**Required components (all inputs already exist in the repo/donor-derived assets):**

1. **Mesh / height source.** Build an `ArrayMesh` grid from the existing height field —
   `game.height_at()` over `MAP_W × MAP_H` (already used at P1 `:1504`) plus `Data.TILE_M`
   spacing. One quad per cell (or per `CHUNK_T` block) with position, normal (from height
   gradients) and UV. For large relief, import the donor `terrainmesh*.osm` /
   `terrainplateau*.osm` geometry (D16) or approximate it with the same height grid at
   higher tessellation — this is the single biggest fidelity lever for ravines/plateaus.
2. **Material.** `ShaderMaterial` (or `StandardMaterial3D`) with the existing donor-derived
   DDS PNGs `app/assets/terrain/blocks/*.png` (P3) as tiled albedo, `UV` scaled by
   `TextureScale`-equivalent (E1), top/side face selection mirroring `refkey=normal` vs
   `verticalfront/verticalside` (E7–E9), and the face-angle metadata (E11) driving UV
   rotation on 25° faces. Feed the same wave sheets (P4) to a 3D water material.
3. **Lighting / shadows / fog.** One `DirectionalLight3D` with the donor light vector
   (already recovered in P1 `:817-819` for the water shader), shadow mapping enabled,
   and scene fog — these directly realize E3–E4, E18. `HeightField`'s bump uniforms
   (E19) map to a normal-from-height or derivative term.
4. **Water.** A separate transparent mesh at `WATER_LEVEL = -0.25` (P1 `:82`), with the
   port's existing `water_overlay` fragment math ported to `shader_type spatial` so the
   coast fade and specular use the 3D surface normal and view vector. Shore refraction
   in Compatibility can be approximated with a screen-space texture copy (`hint_screen_texture`),
   not true refraction.
5. **Keep 2D where it works.** Units, decals, selection/FX, minimap and fog overlays stay
   as `Node2D`/`canvas_item`; only the terrain substrate and water become 3D. Camera
   projection must be tuned so `TILE_M * view_scale` screen coverage matches today's
   sprites (P1 `:1520-1521`) to avoid a global scale regression.

**Effort / risk:** **high effort, medium technical risk, high integration risk.**
* Feasibility is good — Godot 4 Compatibility supports `Camera3D` with `projection = ORTHOGRAPHIC`,
  `ArrayMesh`, `ShaderMaterial`, shadows and `hint_screen_texture`; all art assets already
  exist (P3/P4). No new donor copies are needed.
* Main risks: (a) every sim/interaction path currently assumes tile↔pixel parity, so a
  camera/projection change touches world.gd, input picking and shot comparison; (b) sub-atlas
  UV seams and the 25° face-orientation metadata (E10–E11) must be reverse-engineered from
  the lib/mat scheme to get rock faces right; (c) Compatibility renderer shadow/fog quality
  and screen-space refraction are limited — some donor softness will remain approximate;
  (d) static 3D draw cost at `MAP_W × MAP_H` needs chunking/frustum culling.
* Suggested staging: build a single 16×16 tile **sandbox** with one height mesh + water
  plane, A/B against the reference rock-face and shore crops (P5/P6 acceptance criteria),
  then decide whether to migrate the full map. Do **not** rewrite `_build_chunk` in place
  before the sandbox proves parity.

---

## 7. Claim table (this document)

| # | Claim | Label | Basis |
|---|-------|-------|-------|
| C1 | Donor terrain render architecture is 3D, not 2D sprites | **derived** (high confidence) | E1–E21, S1–S9 |
| C2 | Tile faces are lit with front/back normals and shininess | **observed** | D7 `reftile.mat:51-106` |
| C3 | Vertical rock faces use eye-linear-Z projected DDS + alphavert mask | **observed** | D7 `:120-170`; D8 `:110-217` |
| C4 | Tile selection is driven by height zones and season | **observed** | D12 `mapcover.cfg:3-12`; D1 `:12-15` |
| C5 | A HeightField shader supplies shadows, fog, camera matrix, texgen | **observed** | D14 `shaders.lib:15-52` |
| C6 | Explicit 3D terrain/plateau meshes exist | **observed** (binding), **inferred** (mesh use) | D16 `terrainmesh1.actor:1-5`; D17 |
| C7 | Reference rock-face striation is texture × face-lighting amplification | **inferred** | P5 `:114-132`, `:165-177` + E7/E18 |
| C8 | Reference shore softness is shader coast-fade over a 1-cell rim | **observed** (prior plaintext) | P6 `:55-71` |
| C9 | Port is a 2D `Image` compositor feeding `Sprite2D` z=-10 | **observed** | P1 `:1387-1525` |
| C10 | Port water is a canvas_item shader with no screen/3D effects | **observed** | P2 `:1`, `:10`, `:93-173` |
| C11 | Perspective-correct lighting, geometric parallax, height self-shadow and shore refraction cannot be exact in 2D | **inferred** (architecture) | §5.2 |
| C12 | 245 TileBlock slots in live install (prior note said 124) | **derived** | D2 count |
| C13 | 3D-ortho Godot port is feasible with existing assets but high integration risk | **inferred** | §6.2 + P3/P4 |

---

## 8. Open questions / UNVERIFIED

1. `hf.pvl.sm.vert` / `hf.pvl.smx3.frag` were **referenced but not opened** (D14 `:17-18`);
   the exact per-vertex lighting equation and whether the height field is a displacement
   in the vertex shader vs CPU-built geometry remains **UNVERIFIED**.
2. `.osm` internals were only inspected via header/string dump (D16); vertex/facet counts,
   scale and placement rules in the `.prop` files were not decoded — **UNVERIFIED**.
3. The "124 TileBlock slots" prior figure was not reconciled to a specific named subset;
   only the raw 245-line count was verified (C12). Which subset the prior agent counted is
   **UNVERIFIED**.
4. Whether the donor camera is perspective or orthographic was not directly observed;
   the recommendation assumes orthographic to preserve RTS projection parity — **inferred**.
5. No Godot render was produced; the visual outcome of the proposed 3D sandbox is
   **UNVERIFIED** by design of this read-only task.
6. Donor DDS files were never opened as pixels here (private-use rule); rock/shore numbers
   are quoted from P5/P6, which did read donor art read-only. Exact side-face UV rotation
   for `AngleX/AngleZ = 25°` needs a test render.

**End.**
