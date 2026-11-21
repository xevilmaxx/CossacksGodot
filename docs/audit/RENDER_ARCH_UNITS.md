# RENDER_ARCH_UNITS — are units / buildings / trees live 3D meshes or baked 2D sprites?

**Lane:** R-ARCH-UNITS (read-only research subagent). **Date:** 2026-11-21.
**Donor:** `C:\Games\Cossacks 3` (private use, read-only). **Port:** `app/` in this repo.

No donor file was copied, converted or committed; no Godot run, no code edit, no donor
executable launched. Binary inspection used `struct`/`hex` only; rasters were read with
Pillow 12.1.1. Mesh layouts were **reused** from prior CA findings
(`docs/decomp/DC_FORMATS.md` §2.1–2.2, `docs/audit/DECOMP.md` §claims 3a/3b,
`NAVAL_EVIDENCE.md` §2.2), not re-derived: `.oss` = `<6i k,fps,b,v,fc,t>` + bind verts +
faces + UVs + UV-faces + per-vertex weights + `b×k×<7f>` bone tracks; `.osm` = 68-byte
`IDP2` header with section offsets at longs **12/13/14**.

---

## 1. Sources

### Donor (all read-only, absolute paths under `C:\Games\Cossacks 3\data\`)
| id | Source | What it supplied |
|---|---|---|
| D1 | `actors\units\yacht.osm`, `eng…` / `buildings\eng\enghou.osm`, `env\spruce1.osm`, `env\pine1.osm`, `env\stones1.osm`, `env\bushes1.osm` | IDP2 headers, counts, offsets, vertex bboxes (this pass, `struct`) |
| D2 | `actors\units\yacht.oss`, `peaukr.oss`, `pikeman.oss` | `<6i>` headers, full size closure, bind bboxes (this pass) |
| D3 | `animations\aaf\peaukr.aaf`, `yacht.aaf`; recursive grep over all 246 `.aaf` | named action ranges; absence of turn/rotate/scale actions |
| D4 | `game\var\envscales.cfg` | per-object `scale` + `minscale`/`maxscale` ranges, tree/stone/mine groups |
| D5 | `objects\env\spruce1.prop` | LOD mesh names, random mesh/material selection, seasonal materials |
| D6 | recursive extension census of `data\` + filename scan of all rasters + 12 sampled TGA/2 sampled DDS | rarity of sprite-like names; TGA = terrain masks, DDS = skins/plant atlas |
| D7 | `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (1280×720) | donor reference screenshot (viewed) |
| D8 | `docs/decomp/DC_FORMATS.md`, `docs/audit/DECOMP.md`, `NAVAL_EVIDENCE.md`, `docs/UNIT_BAKING_FIX.md`, `docs/guides/GUIDE1.md` | prior decoded layouts and attach-prop evidence (reused) |

### Port
| id | Source | What it supplied |
|---|---|---|
| P1 | `app/tools/bake_sprites.py` (2, 8, 38, 139–144, 179–187, 464–478, 509–525) | 8-azimuth / 32°-elevation CPU-Cycles ortho baker; buildings baked from **one** camera |
| P2 | `app/assets/models/anim/**` (Pillow dimension checks) | 1280×1920 unit sheets (8×160 px × 12 rows), 320×320 building sheets, 1280×160 naval hull |
| P3 | `app/scripts/world.gd` (369, 488, 650–661, 2474–2520, 2511) | `_draw_sprite` billboard blit; 8-way facing quantisation |
| P4 | `app/tools/convert_models.py` (43–65, 109–125) + `app/assets/models/obj|tex` census | 116 static bind-pose `.obj`, 232 `.tex`; animation read then discarded |
| P5 | `app/project.godot` (`renderer/rendering_method="gl_compatibility"`), `docs/audit/RENDER_ARCH_TERRAIN.md:217–262`, `docs/guides/GUIDE4.md:2258–2262`, `app/tests/results/t_mass_army.json`, `SWARM_OPS.md:17` | Compatibility constraints, mass-army cap/perf evidence |
| P6 | `app/shots/session1/frame_0005.png` (1280×720) | port screenshot (viewed) |
| P7 | `docs/audit/TERRAIN_REFERENCE_IMAGES.md` | catalogue of 12 donor reference frames |

---

## 2. Mesh / asset evidence table

### 2.1 Donor geometry (this pass; all integers little-endian)

| File (rel. to `data\`) | Bytes | Vertices `nv` | Tris `nt` | UVs `nu` | Offsets `ou/ot/of` | End `og/oe` | Size closure | Bind bbox (x,y,z) |
|---|---:|---:|---:|---:|---:|---:|---|---|
| `actors\units\yacht.osm` | 427,436 | **9,364** | **7,731** | 11,490 | 132 / 92,052 / 277,596 | 427,436 / 427,436 | exact | x −1.752..1.752, y −4.819..3.208, z −0.376..6.803 |
| `actors\buildings\eng\enghou.osm` | 314,996 | 7,587 | 5,339 | 8,165 | 132 / 65,452 / 193,588 | 314,996 / 314,996 | exact | x −3.212..3.255, y −2.800..2.367, z 0.005..5.866 |
| `actors\env\stones1.osm` | 9,500 | 156 | 224 | 185 | 132 / 1,612 / 6,988 | 9,500 / 9,500 | exact | x −3.127..3.169, y −3.260..3.289, z −0.046..2.100 |
| `actors\env\bushes1.osm` | 49,908 | 840 | 1,140 | 1,120 | 132 / 9,092 / 36,452 | 49,908 / 49,908 | exact | x −1.415..1.326, y −1.285..1.574, z −0.239..1.685 |
| `actors\env\spruce1.osm` | 60,300 | 863 | 1,060 | 887 | 132 / 7,228 / 32,668 | 46,492 / 46,492 | first frame exact; **+13,808 B tail = `nv`×16 → second vertex frame** | x −1.531..1.601, y −1.750..1.744, z −0.045..6.885 |
| `actors\env\pine1.osm` | 85,900 | 1,201 | 1,516 | 1,367 | 132 / 11,068 / 47,452 | 66,684 / 66,684 | first frame exact; **+19,216 B tail = `nv`×16 → second vertex frame** | x −1.855..1.483, y −1.469..1.728, z −0.075..7.647 |

All six carry the `IDP2` magic, version 8, 256×256 skin hint, and `ng=0, nf=1`. The tree
meshes' trailing `nv×16` bytes are an exact second vertex frame (verified arithmetically),
i.e. even "static" vegetation ships more than one geometry state — consistent with a live
mesh that can be swapped/posed, not a flattened picture.

| File | Bytes | `k` frames | fps | bones | verts | faces | UVs | weight pairs | anim bytes | Closure | Bind bbox |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|
| `actors\units\yacht.oss` | 217,344 | **311** | 30 | **20** | 584 | 947 | 793 | 593 | 174,160 | exact (0 tail) | x −0.747..0.745, y −0.266..0.686, z 0.001..3.516 |
| `actors\units\peaukr.oss` | 312,376 | **483** | 30 | **20** | 577 | 921 | 733 | 584 | 270,480 | exact (0 tail) | x −0.717..0.717, y −0.227..0.285, z 0.007..1.995 |
| `actors\units\pikeman.oss` | 225,352 | 312 | 30 | 20 | 733 | 1,062 | 939 | 735 | 174,720 | exact (0 tail) | x −0.745..0.748, y −0.268..0.687, z 0.001..3.516 |

Z-up, ~2 m peasant / ~3.5 m ship crew, feet at z≈0 — real skinned characters, not 2D
cells. `yacht.osm` 9,364 verts / 7,731 faces and `peaukr.oss` 20 bones / 483 frames
match the task's expected figures exactly.

### 2.2 Asset-family census (`data\`, this pass) and sprite-sheet search

| ext | count | role |
|---|---:|---|
| `.osm` | 3,897 | static IDP2 meshes: buildings, env, ship hulls, rubble/stages |
| `.oss` | 335 | skinned animated meshes: units, attach props, cannons, crews |
| `.aaf` | 246 | ASCII action→frame-range descriptors |
| `.acl` | 30 | animation clips |
| `.dds` | 1,469 | textures (skins, terrain, decals, water) |
| `.tga` | 4,510 | terrain masks / HDR flares |
| `.bmp` | 264 | UI bitmaps |
| `.mat` / `.lib` | 35 / 62 | material / library manifests |
| `.prop` / `.actor` | 1,285 / 976 | prop / actor registrations |
| `.pattern` / `.cfg` | 710 / 74 | brush footprints / config |

**Pre-rendered entity sprite sheets: none found.** A filename scan over every raster for
`sprite|atlas|sheet|anim|seq|frame|flipbook|billboard|icon` returned only 10 hits:
`hud\textures\ui\icons*.bmp` (UI icons), `materials\env\plantsatlas*.dds` and
`plantswateratlas*.dds` / `plantsyellowatlas*.dds` (a **1024² RGBA plant-material atlas**,
not rendered entity frames), and `materials\units\framegun.dds` (a unit skin). Twelve
randomly sampled `.tga` files were all 256²/320² RGB terrain masks; `units\peaukr.dds` is
512² RGBA — a **skin texture**, not a bake. No unit/building/tree flipbook or atlas exists
in the donor install.

### 2.3 Animation / runtime metadata

- `peaukr.aaf`: 18 named actions with inclusive ranges — `walk 1..20`, `idle 64..113`,
  `death 115..149`, `attack0 = workwood 237..254`, `workstone 217..234`,
  `construct 186..198`, `idlewood 354..403`, `reaction 456..481`, etc. `yacht.aaf` has
  `idle/walk/death/attack0` all mapped to `1..280` (one morph track). A recursive grep for
  `turn|rotat|scale|mov|slide` across all 246 `.aaf` returned **0 matches**: actions are
  poses/morphs only. Arbitrary yaw is therefore a *renderer transform*, not a stored frame
  set — the hallmark of live 3D (a true 2D game would store 8 facing strips per action).
- `game\var\envscales.cfg`: `scale` plus `minscale`/`maxscale` per object — e.g.
  `stones` scale 0.329 with 0.85–1.15 random range, `stones2` 0.37, mines 0.3152,
  `field` 0.033; groups include `pine1..4`, `pinesmall`, `pinebroken`, `spruce`,
  `leaftree`, `pinestump`, `grassforest`. Per-instance random scale requires live objects.
- `objects\env\spruce1.prop`: `LODActorName = spruce`, `DefaultMeshName = spruce1.mesh`,
  `RandomMeshName = True` with `UseableMeshes[0..3]`, `RandomMaterialName = True`,
  `UseSeasonMaterial = True` with separate summer/winter material lists. Runtime LOD,
  random mesh/material choice and seasonal swaps are meaningless for a fixed baked image.

### 2.4 Screenshots (viewed this pass)

- **Donor** (D7): hundreds of individually shaded men in formed blocks; watchtowers with
  distinct lit/shaded wall faces and pitched roofs; ravine walls with striated, lighted
  rock faces; conifers/broadleaf with volumetric crowns and angled cast shadows; ground
  recedes under an oblique ortho camera. Facing and scale vary continuously across the field.
- **Port** (P6, `app/shots/session1/frame_0005.png`): the 8 visible units are tiny flat
  cut-outs with no cast shadows; the storehouse, house and church are **single-viewpoint
  flat sprites** with painted roofs and hard rectangular bottom edges; trees are 2D
  silhouettes with baked-in shading; the only "shadow" under the storehouse is a drawn
  ellipse. Ground is flat paint. The HUD reads `units 8/200`.

---

## 3. Verdict — donor is a live 3D renderer; port is baked 2D

**DONOR: live 3D geometry, high confidence.** Units, buildings and trees are genuine
3D assets (vertices + triangles + UVs, plus bones/skin weights and 311–483 per-bone
translation+quaternion tracks for units; 3,897 `.osm` + 335 `.oss` files, exact size
closure). They are rendered at runtime under a directional light with arbitrary yaw,
per-object scale and per-instance material/LOD selection (D4–D5). The install contains
**no pre-rendered entity sprite sheets** that could indicate a 2D renderer. The only
"atlases" are a plant-material texture atlas and UI icons.

**PORT: deliberate 2D re-architecture.** `bake_sprites.py` pre-renders those meshes with
Blender **CPU Cycles**, an **orthographic** camera at fixed **32° elevation**:
- units/buildings: 8 azimuths `0,45..315°` (`:2,8,471`), sheets `cell×8 × cell×frames`
  (`:464`), facing snapped by `round(face/(PI/4)) % 8` (`world.gd:369,488`);
- buildings and props: **one** camera `camera(center, 0.0, ortho)` and **one**
  `render_cell` (`:509–525`) → a single baked viewpoint, e.g. `ukr_hou.png` 320×320;
- draw: `_draw_sprite` (`world.gd:650–661`) scales a `Texture2D` to `world_h` and blits it
  with `draw_texture_rect`, anchoring the foot at `p − 0.82·height`; naval hulls are an
  8-cell strip (`yacht_hull.png` 1280×160) blitted by `dir*cell` (`:2511–2513`).

**Fidelity lost by baking (concrete examples):**
1. **No dynamic lighting.** Sun/shadow and seasonal light are fused into pixels; the port
   can only add a uniform `tint` and a fake ellipse. Donor towers/trees/ravines in D7 show
   real lit faces and angled cast shadows; P6 buildings have none.
2. **Fixed viewpoints.** Buildings are baked from one azimuth/elevation, so orbiting the
   camera never reveals a different facade, roof plane or side — D7's towers show real
   side faces and roof geometry.
3. **No continuous rotation.** Unit facing is quantised to 45° steps; between-step and
   arbitrary-yaw poses don't exist. Attach props (`peaukr_hammer.oss` etc., D8) are baked
   into the sheet and cannot be re-posed independently.
4. **Animation decimation.** The 483-frame `.oss` track is reduced to a handful of sampled
   rows (e.g. `peasant_walk.png` 1280×1920 = 8 dirs × **12** frames); 97.5% of the authored
   frames are gone.
5. **Per-instance variation lost.** `envscales.cfg` random scale and `.prop` random
   mesh/seasonal materials become one fixed image per key.
6. **No parallax/occlusion.** Sprites do not intersect ravine walls or cast/receive shadows
   as 3D bodies; depth order is a draw-order hack.

---

## 4. Port gap and 3D-mode asset feasibility

### 4.1 What already exists (reusable)
`app/assets/models/obj` holds **116 static `.obj`** bind-pose meshes and `tex` holds
232 donor-derived PNG textures — e.g. `peasant.obj`, `pikeman.obj`, `archer.obj`,
`cossack.obj`, `hou.obj`, `tow.obj`, `bar.obj`, `cen.obj`, `tree_spruce1..4.obj`,
`tree_pine*.obj`, `rock_*.obj`. These are adequate **static** geometry/material inputs for
a 3D-ortho mode on buildings, trees and rocks (the substrate case is already argued in
`RENDER_ARCH_TERRAIN.md §6.2`). They are raw Z-up (e.g. `peasant.obj` first verts
`v 0.062 −0.057 0.385` — height in Z), so a Godot Y-up conversion is required.

### 4.2 What does NOT exist (new asset pass required)
- **Animation/skinning.** `convert_models.py:43–65` reads weights and all bone tracks, but
  `write_obj` (`:109–125`) writes only `v/vt/f` — the bind pose. There is no `.glb`,
  `.gltf`, `.dae`, bone JSON or animation resource anywhere under `app/assets/models`.
  Reproducing the 20-bone / 483-frame skeleton motion needs a **new export pass** (e.g.
  Blender glTF with skin+animation from `.oss`, or a runtime skinning shader fed packed
  bone tracks) plus a Z-up→Y-up fix.
- **Coverage.** 116 `.obj` generic keys vs 54 unit keys × nation variants and 215 building
  sheets; no `yacht.obj`/naval hulls; construction stages `_s1..s4` and `_dead` variants are
  mostly absent. A faithful 3D mode would need to re-convert those donor families.
- **Live metadata.** Nothing currently consumes `.aaf` ranges, `envscales.cfg` or `.prop`
  LOD/season rules at runtime; a 3D mode must implement them.

**Answer to the task question:** a 3D-ortho mode can **reuse the existing `.obj`/`.tex`
conversions for static geometry and textures only**. Moving units (and any animated prop)
**requires a new animation/rig asset pass**; it is not a config toggle.

### 4.3 Godot 4 Compatibility constraints for mass armies
- `app/project.godot` pins `renderer/rendering_method="gl_compatibility"` (features 4.4).
  Compatibility supports `Camera3D.projection = ORTHOGRAPHIC`, `ArrayMesh`,
  `ShaderMaterial`, a `DirectionalLight3D` with shadows and `hint_screen_texture`, but
  **not** compute shaders, SDFGI, volumetric fog or true screen-space refraction;
  shadow/fog softness stays approximate (`RENDER_ARCH_TERRAIN.md:250–258`).
- **Draw-call / skinning cost:** every animated 3D soldier would be a separate
  `MeshInstance3D` with skinned geometry. GLES3 skinning relies on float-texture vertex
  sampling, which is absent/slow on many weak GPUs; hundreds of skinned instances would
  multiply draw calls versus today's hundreds of textured quads. Mitigations: MultiMesh
  for static/pose-shared crowds, vertex-animation textures + `ShaderMaterial` for pose,
  `LOD`/`VisibilityRange`, frustum culling, a single directional light, and baked
  contact shadows rather than real-time shadow maps per unit.
- **Scale target is already strained:** `t_mass_army.json` spawns **552 units** (6/6 checks
  pass), but the sim alone costs **9,695.91 ms per 10 sim-seconds** (headless); the port
  cap is 200/side and skirmish starts at 8 peasants (`GUIDE4.md:2258–2262`). The donor
  screenshot D7 shows hundreds per side. `SWARM_OPS.md:17` requires performance to hold
  with mass armies on weak GPUs, and no windowed FPS has been measured
  (`CONFIG_EFFICIENCY.md`: `headless_sim_only`).
- **Recommendation:** do not migrate in place. Prove a 16×16-tile **sandbox** with one
  `Camera3D` ORTHO, one lit unit mesh and one static building (reusing `.obj`/`.tex`),
  measure windowed FPS at 200 and 552 units on a weak GPU, and only then scope the new
  animation export pass. Keep 2D HUD/minimap/selection overlays.

---

## 5. Claim table (this document)

| # | Claim | Label | Basis |
|---|---|---|---|
| C1 | Donor units/buildings/trees are live 3D meshes, not pre-rendered sprites | **Observed + Derived** | D1/D2 IDP2 + `<6i>` decode, exact size closure, bone tracks; D6 zero entity sprite atlases; confidence high |
| C2 | `yacht.osm` = 9,364 verts / 7,731 faces; `peaukr.oss` = 20 bones / 483 frames @30 fps | **Observed** | D1/D2 this pass, matching D8 prior findings |
| C3 | Two env tree meshes carry a full second vertex frame | **Derived** | D1: tails 13,808 B and 19,216 B = `nv`×16 exactly; meaning of frame unknown |
| C4 | Arbitrary yaw is a renderer transform, not stored facing frames | **Inferred (high)** | D3 zero turn/rotate actions in 246 `.aaf`; D2 real skeleton; no 8-dir frame sets in donor |
| C5 | Donor does per-instance scale, LOD and seasonal material selection | **Observed** | D4 `scale`/`minscale`/`maxscale`; D5 `LODActorName`, `RandomMeshName`, `UseSeasonMaterial` |
| C6 | Only plant-material/UI atlases exist; no unit/building/tree sprite sheets | **Observed** | D6 recursive raster filename scan + Pillow dimension checks |
| C7 | Port bakes 8 azimuths at 32° elevation with CPU Cycles; buildings get one viewpoint | **Observed** | P1 `:2,8,139–144,179–187,464–525` |
| C8 | Baking loses dynamic light, continuous rotation, full animation and per-instance variation | **Derived** | C1/C4/C5 vs P1/P3; screenshots D7 vs P6 |
| C9 | Existing `.obj` are static bind-pose, Z-up; skinning data is discarded | **Observed** | P4 `:43–65,109–125`; `peasant.obj` vertex lines |
| C10 | 3D-ortho mode reuses static geometry only; animation needs a new asset pass | **Derived** | C9 + no rig assets in `app/assets/models` |
| C11 | Compatibility + 552 skinned instances is a perf risk; sandbox + measurement first | **Inferred** | P5: `gl_compatibility`, 552 units / 9.7 s sim, 200/side cap, weak-GPU rule |
| C12 | Donor screenshot shows real volumetric shading/cast shadows; port shows flat sprites | **Observed** | D7 vs P6 (both viewed this pass) |

---

## 6. Open questions

1. What is the second vertex frame in `spruce1.osm` / `pine1.osm` — wind pose, seasonal
   variant or LOD? `ng=0, nf=1` does not explain it; needs a frame-delta diff (out of scope).
2. Does the donor engine render units at truly continuous yaw, or snap to 8 facings
   in-engine? Inference C4 is strong but unproven without reading game scripts (`.aix`)
   or running the donor (both forbidden here).
3. Are the `plantsatlas*.dds` frames ever used as **impostor foliage billboards** by the
   donor renderer, or purely as a plant material atlas? Only the filename/size is observed.
4. What is the exact hardware skinning capability/limit of the target weak GPU under Godot
   4 Compatibility? Needs a windowed measurement (PERF-02 style), not a doc claim.
5. Should a future 3D mode keep Z-up `.obj` and convert at import, or re-convert from donor
   with Y-up baked in? Current `.obj` were kept raw for the 2D baker; intent UNVERIFIED.
6. How many of the 335 `.oss` are genuinely skeleton-animated vs single-frame? The
   reader-validation sweep (T-2 in `DC_FORMATS.md`) has not been run.

---
*R-ARCH-UNITS. Read-only pass: no donor file copied, no donor executable run, no Godot
run, no repo file edited other than this document.*
