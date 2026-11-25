---
id: V3D-02
title: "Why 3D terrain quality is bad — current rendering code-path audit (variant3d)"
agent: V3D-02
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_GODOT_RUN__NO_DONOR_EXECUTION
scope: "READ-ONLY audit of variant3d terrain rendering path. No game code, shader, asset, config, test or git edit. One report file only."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; not executed, copied or decoded beyond cited text in prior reports)"
confidence_vocabulary:
  observed: "Directly readable in current source/assets or a published measurement"
  derived: "Consequence computed from observed code/math"
  inferred: "Attribution of a visual symptom to a mechanism; no pixel-aligned donor A/B exists"
parity_guard: "No donor GPU A/B frame exists anywhere in this project. Every visual-parity statement is UNVERIFIED."
---

# V3D-02 — 3D terrain quality: rendering code-path audit

## Goal

Explain, from the **current** `variant3d/` code and assets (not from stale reports), why the
shipping 3D terrain looks the way it does, by tracing the full GPU path — height grid → mesh →
UV/UV2 → donor tile index → atlas + masks → shader → water/lighting/sky — and by separating
(a) real active causes, (b) historical causes already fixed, and (c) donor-grounded gaps that
remain UNVERIFIED. Produce a visual-impact-ordered fix plan and an isolated piece-test ladder
on the smallest (64×64) map. No code is edited.

## Sources

**Orientation / status**
- `docs/variant3d/README.md` — project rules, no-2D-bake directive, report index.
- `docs/variant3d/STATUS_WAVE7_PHASE2.md` — FINAL VERDICT §2 (gates green, donor parity UNVERIFIED), post-integration closures §2.
- `docs/coord_swarm_2026-11-24/reports/V713_world3d_terrain.md`, `V731_test_terrain3d.md`.
- `V782_splat_detail.md`, `V784_donor_water_shader.md`, `V785_tile_atlas.md`, `V786_tileindex_shader.md`,
  `V790_donor_camera_changes.md` (**note:** the task named `V789_donor_camera_changes.md`; the file on disk is `V790_…`),
  `V792_terrain_integration.md`.
- `docs/audit/TERRAIN_BEAUTY_TRIAGE.md`, `TERRAIN_CHECKERBOARD_TRIAGE.md`, `TERRAIN_PORT_RENDER.md` — these three are **2D `app/`** audits; used only for contrast and for "already correct" context, not as 3D evidence.

**Follow-up evidence found during the audit (read because they are terrain-quality specific)**
- `docs/coord_swarm_2026-11-24/reports/FIXTERRAIN_visual_quality.md` — face promotion, shadow disable, measured A/B rejections.
- `CAMSEAM_double_subtract.md` — camera SIM→centred double-subtract fix.
- `COMPLETENESS_03_donor_fidelity.md` — current-source RAG verdicts.
- `TERRAIN_SMALL_maps.md` — 64×64 harness, probe and capture.
- `AUDIT3D_03_terrain.md` — **historical** (pre-V7-60/84/92) terrain parity audit; stale claims flagged below.
- `TERRAIN2_01_donor_pipeline.md`, `TERRAIN2_06_tileindex_architecture.md`, `DEEPDEC_02_terrain_render.md`,
  `DEEPDEC_03_water.md` — cited via the reports above (read-only donor text, no donor access this pass).

**Code / shaders / assets read in current source**
- `variant3d/scripts/world3d_terrain.gd` (903 lines — the wired terrain module),
  `world3d.gd` (composition), `tile_atlas_loader.gd`, `heightmap_world3d.gd` (unwired sibling),
  `water3d.gd`, `terrain3d_sandbox.gd` (legacy M0 sandbox), `camera3d.gd`.
- `variant3d/shaders/terrain_tileindex.gdshader` (376 lines), `water3d.gdshader` (235 lines),
  `water_overlay.gdshader` (2D canvas shader, kept for contrast only).
- `variant3d/tests/t_terrain3d.gd`; small-map fixtures/probe referenced from `TERRAIN_SMALL_maps.md`.
- Asset inventory: `assets/terrain/atlas/{tile_index_atlas.png (179,912,941 B), tile_index_atlas.manifest.json,
  alpha.png (55,242 B), alphavert.png (167,954 B)}`; `atlas_parts/{part000,part001,split_manifest.json,alpha.png,alphavert.png}`;
  `heightmap/splat_albedo.png (1,150,428 B = 1280²) + manifest`; `blocks/*.png` (grass1..10, ground1,
  grass_sand1/2, grass_rock1, grass_ground1..3, rock1..9, sand1..9, sandsea1..6, sandrock1..6,
  desert1..12, test0..25, winter0..26); `water_png/diffusewaves0..7.png`; `structs/presets_summer.json`
  (124 names), `tileblocks.json`, `smooth_summer.json`; `dmask/d_00..23.png`; masks tree; `deco_png/`, `decals_png/`.

## Data-flow trace (current source, with citations)

| Stage | Source of truth | Path → consumer | Notes |
|---|---|---|---|
| Height grid | live `game.height: PackedFloat32Array` (`game.gd:44`, bilinear `game.gd:1893-1907`), or dump `height` base64 float32 (`main.gd:694-701`) | `world3d_terrain.gd:408-445` `_dump_from_game()` → `build()` decodes at `:631-648` | `HEIGHT_SCALE=1.0`, metres (`:94`); observed span ±2.964 => correct scale. |
| Mesh | one indexed `ArrayMesh`, 1 surface | `world3d_terrain.gd:664-729`: vertex `(x+0.5-w/2)*TILE_M, height[i], (z+0.5-h/2)*TILE_M`; normals `_normal_at()` `:389-399` (central difference over `2*TILE_M`); indices `:709-719`; material `:731-747` | 320² = 102,400 verts / 203,522 tris; 1 draw call (`t_terrain3d.gd:21-23,224-226` measured). |
| UV (splat/fallback) | cell-centre 0..1 | `world3d_terrain.gd:689-690` `((x+0.5)/w,(z+0.5)/h)`; fallback albedo `splat_albedo.png` loaded via `Image.load` `:197-204,655-662`; LINEAR filter `:332` | Only used by `_terrain_material()` `:328-344` when tile-index path is unavailable. |
| Tile index | **live** `game.tileblock: PackedByteArray`, one uint8/cell (`game.gd:53,1610-1689`; dumped `main.gd:741`) | `world3d_terrain.gd:451-488` `_decode_tile_indices()` → `:691-708` writes `ARRAY_TEX_UV2.x = float(tid)`; out-of-atlas (e.g. `BLK_WATER=255`) clamped to `[0, named_cells-1=123]` at `:680,700-702` | 102,400 UV2 entries measured 0 mismatches (`V792 §3`, `FIXTERRAIN §7` ticket 293). No four-sub-tile data exists in the live buffer. |
| Face mode | donor slope thresholds `cDiff1=0.5` / `cDiff2=0.55` (`texturemap.inc:63-64`) | `world3d_terrain.gd:109-118,347-382` `_face_mode_at()` → `UV2.y` at `:703-708`; `face_hist` in stats `:824` | FIX-TERRAIN change; ~7% of cells promoted at 320² (`{0:95252,1:3416,2:3732}`, `FIXTERRAIN §7`). Exact donor vf/vs promotion remains ENGINE/UNVERIFIED. |
| Atlas | V7-85 `tile_index_atlas.png` 16384×8192, 16×8 grid of 1024² cells, 124 named / 121 filled (`tile_index_atlas.manifest.json:13-40`; `V785 §6`) | `tile_atlas_loader.gd:161-187` auto-fallback single→split→array; grid from manifest `:297-304`; `world3d_terrain.gd:221-280` `_load_atlas()`; `atlas_grid` bound `:313` | Index = `presets_summer.json:2-125` position (donor `terrain.presets:2-6`). Packing is APPROX (donor `tsDouble/ttExtended` engine-side). Big PNG present on disk (179,912,941 B). |
| Masks | donor `alpha.bmp` 512×256 and `alphavert.bmp` 1024×512 (`reftilealpha.mat:30-37,139-146`), converted to L-mode PNGs | `tile_atlas_loader.gd:443-455` → `world3d_terrain.gd:283-296` `_repack_mask_alpha()` R→A → shader samplers `:311-312` | Channel correct; **UV/sub-rect mapping is APPROX/UNVERIFIED** (donor `AlphaRows=8,AlphaCols=4,AlphaTileSize=64` commented, `reftile.lib:7-11`). |
| Shader | `terrain_tileindex.gdshader` (`V786`), `render_mode blend_mix, unshaded, cull_disabled` (`:37`) | bound at `world3d_terrain.gd:303-325`; material selected `:731-747` | Samples atlas cell `tile_rgb()` `:281-287` at `fract(v_st*uv_repeat)` `:300`; reads mask `.a` `:318,323`; donor combine `rgb*v_packed + v_specular` `:328`; PCF `:331-354`; fog `:357-367`; `ALBEDO=rgb`, `ALPHA=mix(1,a,mask_to_alpha)` `:373-375`. |
| Eye-plane UV / lighting inputs | donor equations `hf.pvl.sm.vert:9,12-23,26-45` | shader `vertex()` `:239-275` | **Neutral substitutes**: `eye_plane_s=(1,0,0,0)`, `eye_plane_t=(0,1,0,0)`, `texture_matrix=identity` `:103-105`; `light_position_eye=vec3(0)` `:119`; material literals `ambient=0.15686`, `diffuse=0.78125`, `specular=0` `:123-135`; `uv_repeat=(1,1)` `:185`. |
| Environment | donor `light.cfg:3-16,26-29`, `water.dev.vert:22` | `world3d_terrain.gd:553-593` `_make_environment()` called `:765` | `WorldEnvironment` + `DonorSun` present; **shadows disabled by explicit user decision** `:580-588` and `cast_shadow=OFF` `:751-756`; shader is `unshaded` so the real sun never lights the terrain. |
| Water | donor `water.dev.frag` equations, `diffusewaves0.png`, literals −0.25/−0.1/2.96 (`texturemap.inc:29-31`) | `water3d.gd:138-233`, `world3d_terrain.gd:528-545` `_make_water3d()`, `bind_height_grid()` `water3d.gd:248-264` | One full-map quad at y=−0.25; height-aware via bound grid; old constant quad fallback-only `world3d_terrain.gd:491-520,762-764`. Donor `hmapTex`/reflection/shadow bindings UNVERIFIED. |
| Props (trees / mines / stumps / food) | live `game.res_nodes`, driven through `world3d.gd:390-410` feed | `world3d_entities.gd:113-118` (`ENV_SCALE` mine 0.3152 / tree 0.5, `POOL_TREE`, `POOL_STUMP`), `add_resource()` `:1294`, sid resolution `:327-332,1276-1281` | Present as static donor OBJ meshes, not missing; animated sway and donor environment-texture painting absent. |
| Tests | `t_terrain3d.gd:28-35,180-253` | 6 checks: API, build, surface count, vertex count, `has_chunk_or_fallback`, `height_at_world` | **No shader/atlas/mask/UV2/visual assertion.** 64×64 `t_smallmap_terrain.gd` adds 21 structural checks (`TERRAIN_SMALL_maps.md §3`) but still no donor A/B. |

## Problem table — every concrete cause of bad terrain quality

Confidence: **observed** = readable in current source / published measurement; **derived** = computed consequence; **inferred** = visual attribution without a pixel-aligned donor A/B.

| # | Symptom | Root cause | Citation (path:line) | Confidence / status |
|---|---|---|---|---|
| P1 | Repeated light "maze"/stepped tile pattern; ground reads as a few flat families, not donor meadow. | **Data-level, outside the render module.** Live `tileblock` histogram: 102,400 bytes, 31 ids 0..85; top five (`14:28535 grass_ground1`, `0:15993 grass1`, `16:15962 grass_ground3`, `79:7667 test8`, `78:6691 test7`) = **73.0%**; `test7/8/9` transition tiles = 14,358 cells (14.0%). Only 82 unique block PNGs serve 124 atlas cells; `grass_ground1`/`grass_ground3` byte-identical. | `FIXTERRAIN_visual_quality.md:52-62` (RC1); `V785_tile_atlas.md:235-236`; `TERRAIN_SMALL_maps.md:154-159`; `tile_index_atlas.manifest.json:27-30` | **observed** measurement; **inferred** visual attribution. ACTIVE. |
| P2 | Tile art appears to slide/stretch with camera; wrong texture scale; no stable world-ground texgen. | **Eye-plane UVs are neutral substitutes.** `realpos` is eye space (`VIEW_MATRIX*MODEL_MATRIX`); defaults `eye_plane_s=(1,0,0,0)`, `eye_plane_t=(0,1,0,0)` make `t = eye-space Y` (mix of height and depth), not ground Z. `texture_matrix=identity`, `uv_repeat=(1,1)` gives a 1 m `fract` repeat. Donor `gl_EyePlaneS/T[0]` and `TextureMatrix[0]` are engine-bound and unreadable. | `terrain_tileindex.gdshader:103-105,185,239-265,281-300`; `FIXTERRAIN_visual_quality.md:92-97` (RC5); `V786_tileindex_shader.md:77-81,237-253`; `COMPLETENESS_03_donor_fidelity.md:110` | **observed** defaults; **derived** camera-dependence; **inferred** visual. ACTIVE, largest shader-side gap. |
| P3 | Flat, dark olive ground; no relief shading from the donor sun; no shadows on terrain. | **Shader lighting is a neutral headlight, not the donor sun.** `light_position_eye=vec3(0)` ⇒ `l = normalize(-realpos) = e` and `h = e`; `diffuse = N·e * 0.78125 + 0.15686`. Ambient/diffuse are *material* literals, not engine light products. `render_mode … unshaded` means the real `DonorSun` DirectionalLight3D is ignored; `shadow_enabled=0`; `cast_shadow=OFF`. Donor ambient/diffuse colours recorded but deliberately unused (raw swap measured only +0.9 luma, not donor-faithful). | `terrain_tileindex.gdshader:37,119-135,151,247-258`; `world3d_terrain.gd:100-107,553-593,745-756`; `FIXTERRAIN_visual_quality.md:82-90,215-218,229-246`; `COMPLETENESS_03_donor_fidelity.md:51,73` | **observed** math/constants; **derived** headlight; **inferred** flatness. ACTIVE. |
| P4 | Mask/detail does not line up with tile sub-cells; cliff/sand face art lacks donor orientation detail; "square" repeated look. | **Atlas packing and mask sub-rect mapping are approximations.** One whole preset per 1024² cell (16×8); donor `tsDouble/ttExtended` sub-atlas is engine-side/commented. Donor mask grid (`AlphaRows=8, AlphaCols=4, AlphaTileSize=64`) is commented/UNVERIFIED. Shader samples the *whole* alpha mask at `fract(v_st)` and alphavert at `vec2(eye.x|z,eye.y)*0.125` with no per-tile sub-rect. | `V785_tile_atlas.md:59-61,238-244`; `terrain_tileindex.gdshader:54-70,265,303-324`; `FIXTERRAIN_visual_quality.md:47`; `V792_terrain_integration.md:178-180`; `tile_index_atlas.manifest.json:39` | **observed** commented donor values + shader code; **derived** mismatch; **inferred** visual. ACTIVE, UNVERIFIED. |
| P5 | Cliff cells read as wrong-colour/flat faces rather than donor `rockNvf/vs` walls. | **Face promotion is a port approximation.** `_face_mode_at()` uses donor cDiff thresholds + dominant gradient axis to set `UV2.y∈{0,1,2}`; it never changes `UV2.x`. Exact donor rule that promotes a base tile to vf/vs is ENGINE/UNVERIFIED; `tiles.lib:119-136 AngleX/AngleZ=25` metadata is not applied; RGB stays the base block (which matches donor `.dds` binding). | `world3d_terrain.gd:109-118,347-382,691-708,813-816`; `terrain_tileindex.gdshader:305-318,370-372`; `FIXTERRAIN_visual_quality.md:64-68,253`; `V792_terrain_integration.md:174-176` | **observed** code + face_hist; **derived** partial fix; **inferred** visual. ACTIVE (AMBER, not fixed to parity). |
| P6 | Dark horizontal/diagonal bands across the ground, worse on small maps. | **Height-aware water fields, not shadows.** `water3d.gdshader` discards where `height>level` and fades alpha by `coastfade2`; `hmapMin/Max = ±2.96` is a port approximation; `waveheight=0` under the −0.25 literal; `terrain_map()` bed colour and `map_size` are substitutes. One full-map quad means low-lying land is tinted. A controlled shadow A/B changed **0 pixels** — the tile shader is `unshaded`. | `water3d.gdshader:73-75,147-177,219-235`; `water3d.gd:248-264`; `TERRAIN_SMALL_maps.md:27-29,160-165`; `FIXTERRAIN_visual_quality.md:70-80,220-227` | **observed** controlled A/B attribution; **derived** mechanism; **inferred** exact band appearance. ACTIVE. |
| P7 | Terrain reads washed/dark and semi-transparent over the sky; removing the mask makes it *darker*. | **`mask_to_alpha=1.0` re-applies donor mask as framebuffer ALPHA with no second base-tile pass.** Donor `bmTransparency` blends `texUnit1.a` over a base pass; port has one `blend_mix` pass. Measured A/B: removing it drops luma 42.735 → 38.425 (bright port sky behind), so the shipped value was deliberately kept. | `terrain_tileindex.gdshader:24-37,202-211,373-375`; `world3d_terrain.gd:316-324`; `FIXTERRAIN_visual_quality.md:209-213`; `V786_tileindex_shader.md:103-105` | **observed** measurement; **derived** structural mismatch. ACTIVE (diagnostic knob, not blindly removable). |
| P8 | Cliffs look like smooth slopes; donor stepped/vertical relief and LOD absent. | **Mesh density and normal smoothing.** One vertex per 2 m cell; central difference over `2*TILE_M` smooths a stepped `height[]` field into gentle slopes; no per-step wall mesh, no LOD. Donor height-grid→triangle/LOD connector is UNVERIFIED; `TILE_M=2.0` is port-only. | `world3d_terrain.gd:385-399,664-719`; `V713_world3d_terrain.md:42-51`; `COMPLETENESS_03_donor_fidelity.md:70,87`; `V713_world3d_terrain.md:120-123` | **derived** from mesh recipe; **inferred** visual. ACTIVE (modelling gap, not a UV bug). |
| P9 | No donor view-depth fog, no clouds, flat port sky gradient. | Fog is dormant (`fog_mode=0`, `fog_enabled=0`); active fog is the port FOW overlay (off by default); sky is port-tuned `ProceduralSkyMaterial`, no cloud nodes; donor ambient/diffuse unused; energies 1.45/1.10/1.7 are port compensation. | `terrain_tileindex.gdshader:169,356-367`; `water3d.gd:165`; `world3d_terrain.gd:100-107,553-571`; `COMPLETENESS_03_donor_fidelity.md:51-53,73,92-93` | **observed** defaults; **derived** consequence. ACTIVE (fidelity gap). |
| P10 | Fine grain missing / blurry patches **when the fallback splat path is used**. | Splat was baked at 1 texel per 2 m cell; re-baked at 4 texels/cell (320²→1280²) yields in-cell deviation only 1.233/255 — ~1/256 of the 2D port's 64 px/cell. No mip chain; LINEAR filter. **Not the active path** when live tileblock + atlas exist. | `V782_splat_detail.md:39-41,112-126,182-184`; `world3d_terrain.gd:328-344,731-746` | **observed** measurement; **derived**; conditional on fallback. LOW impact in current path. |
| P11 | Black/off-terrain view after minimap/zoom — a historical "seam" candidate. | v1 signature guard compared `zoom == _last_clamp_zoom` snapshot; a wheel event between foreign centred write and transform caused a **second** half-map subtraction. Fixed by CAM-SEAM v2: `_target` canonical SIM, one unconditional subtraction, `apply_external_target()` transform-then-clamp. | `CAMSEAM_double_subtract.md:14-95,161-188,328-409`; `camera3d.gd:234-252,451-481` | **observed**; **status FIXED — do not redo**. Probe 5/5, 0 double-subtract. |
| P12 | Possible shader compile fallback to plain material. | V786 had two real GLSL errors (invalid `filter_nearest_mipmap_linear`, non-constant `1.0/512.0` default); V784 had `fog_enabled` float/int. All fixed; final probes 47/47 and 10/10 with empty stderr. `surface_mat == null` fallback exists but requires `load()` to return null. | `V786_tileindex_shader.md:191-203`; `V784_donor_water_shader.md:93,99-105`; `world3d_terrain.gd:731-747` | **observed**; **status CLEAN — not an active cause**. |
| P13 | "Missing shore/mines/trees" candidate. | **Not missing at data level.** Shore ids (`sandsea1..6`, `sandrock1..6`, rock face ids) are in the atlas and reachable via live tileblock; trees/mines/stumps are 3D resource meshes via `world3d_entities.add_resource()` with donor `ENV_SCALE`. Gaps: static bind-pose, no sway, no donor forest/stone environment-texture painting (`texturemap.inc:34-38`), feed gated on `res_dirty`. | `V785_tile_atlas.md:93-97,158-163`; `world3d_entities.gd:113-118,327-332,1294`; `world3d.gd:390-410`; `AUDIT3D_03_terrain.md:75,109-114` | **observed** code presence; **inferred** perceived absence. LOW as a *terrain-render* cause. |
| P14 | Wrong height scale / vertical exaggeration. | **Not a cause.** `HEIGHT_SCALE=1.0`; dump height is metres; observed range ±2.964 matches donor `cMaxHeight=2.96`; `TILE_M=2.0` is port-only but internally consistent. | `world3d_terrain.gd:93-95,639-648`; `V784_donor_water_shader.md:33-34`; `COMPLETENESS_03_donor_fidelity.md:70` | **observed**; **resolved — do not redo**. |
| P15 | Tests pass while the ground looks bad. | Committed terrain test asserts only API/geometry; no UV2/tile-index/atlas/mask/shader/color or visual gate. The 64² probe adds structural checks (UV2 range, face hist, atlas grid, shadow state) but still no donor A/B or pixel metric. | `t_terrain3d.gd:28-35,180-253`; `V731_test_terrain3d.md:36-51`; `TERRAIN_SMALL_maps.md:80-97,204-210` | **observed**; ACTIVE (verification gap, not a render cause). |

## What is already correct — do not redo

1. **Live donor tile index reaches the GPU for every cell.** `game.tileblock` → `_decode_tile_indices()` → `UV2.x` → `tile_rgb()` (`world3d_terrain.gd:451-488,691-708`; shader `:281-287`). 102,400 UV2 entries, 0 mismatches. This closes the 2D port's P0 flatness bug (B1 in `TERRAIN_PORT_RENDER.md:90`) — do not "fix" it again.
2. **`atlas_grid` comes from the V7-85 manifest**, never a guessed donor default (`tile_atlas_loader.gd:297-304`; `world3d_terrain.gd:250,313`; `(16,8)` measured).
3. **Masks carry donor intensity in ALPHA** via explicit R→A repack (`world3d_terrain.gd:283-296`); channel contract is right. Only the UV/sub-rect mapping is approximate.
4. **One full-grid indexed mesh, one surface, central-difference normals, cell-centre UV** (`world3d_terrain.gd:664-729`); measured 102,400 verts / 203,522 tris / 1 surface (`V731_test_terrain3d.md:92-93`).
5. **Donor water data path is real**: `diffusewaves0.png`, −0.25/−0.1/2.96 literals, height-aware `bind_height_grid()`, old constant quad fallback-only (`water3d.gd:81,148-179,248-264`; `world3d_terrain.gd:762-764`).
6. **Donor sun/sky rig is wired** (`world3d_terrain.gd:553-593`, called `:765`) — `AUDIT3D_03_terrain.md`'s "no light rig" P0 is **stale** (pre-V7-60). Do not re-add a second rig; only its *consumption* by the unshaded shader is at issue.
7. **Shadows intentionally OFF** by explicit user decision with recorded A/B (`FIXTERRAIN_visual_quality.md:229-246`); re-enable only with a bounded donor-grounded frustum.
8. **Shaders compile cleanly** (V786 47/47, V784 10/10, empty stderr); no active compile fallback.
9. **Camera double-subtract fixed** (CAM-SEAM v2, 5/5 probe); `main.gd` no longer writes private camera fields.
10. **Multi-mode atlas transport** with single (default) → split → array fallback (`tile_atlas_loader.gd:161-187`); big PNG and parts both present on disk.
11. **Face mode now non-constant** from donor-readable slope (`_face_mode_at`); flat cells stay 0 (21/21 small-map regression guard).
12. **64×64 harness exists** with 21/21 structural probe and a real `Screenshot3DViewport` capture (`TERRAIN_SMALL_maps.md:101-148`) — reuse it rather than authoring a new harness.

## Fix plan — ordered by visual impact

All items are **proposals only**; no edits were made. Each must cite donor `path:line` or stay labelled UNVERIFIED per the governing rule (`docs/variant3d/README.md:87-97`).

| Order | Fix | Why this impact | Likely owner / file | Acceptance (measurable) |
|---|---|---|---|---|
| F0 | **Build a repeatable donor A/B + fixed-camera capture baseline** (same seed 20261113, same 64² fixture, same camera, donor frame from read-only donor rendering if permitted). | Blocks every parity claim; without it all "improvements" are guesses. | capture/tooling lane; new harness outside game code | Two pixel-aligned frames + per-region luma/variance; report states PASS/FAIL per criterion. |
| F1 | **Replace neutral eye-plane UVs with a world-ground projection** — recover `gl_EyePlaneS/T[0]`/`TextureMatrix[0]` from donor data or derive a stable world-XZ texgen transform; set a physically meaningful `uv_repeat` (metres per tile). | Largest shader-side visual defect: removes camera-swimming/stretch and restores donor texgen scale (P2). | shader + terrain module owner | Pan/zoom by fixed deltas → sampled ground texel displacement ≈0 in world space; tile period matches donor cell footprint; no donor A/B claim until F0. |
| F2 | **Feed the real donor sun direction into the shader lighting** (replace `light_position_eye=0` headlight) and decide explicitly whether `unshaded` still applies; use donor ground-projected illumination, keep `unshaded` only if the shader reproduces the donor's final colour. | Removes flat/dark headlight look (P3) without touching the already-correct sun rig. | shader owner | Controlled A/B on 64² fixture: non-black >0.9, measurable luma/contrast change, no new dark streaks; record donor label. |
| F3 | **Reduce transition-tile dominance / increase tile diversity at the data level** (regenerate tileblock with more distinct block families; fewer `test7/8/9` as final cells; re-run compatibility smoothing). | P1 is the single largest *visual* pattern cause; cannot be fixed in the shader. | sim/mapgen owner (not terrain module) | Histogram: top-5 share <73%, `test7/8/9` share <14%, ≥3 distinct families visible in adjacent cells; byte-identical dumps for unchanged seed. |
| F4 | **Implement donor sub-atlas + alpha sub-rect mapping** (4 sub-tiles/cell, 8 orientation variants, `AlphaRows/Cols/TileSize` sub-rects) once those values are recovered or explicitly APPROX-labelled. | Removes square repetition and aligns mask intensity (P4). | atlas + shader + loader owners | Each id resolves to a correct sub-rect; mask sampled at sub-rect not whole-atlas; visual A/B on shore/cliff patch. |
| F5 | **Complete vf/vs promotion + 25° tilt path** (exact donor rule currently UNVERIFIED). | Removes wrong-colour/flat cliff faces (P5). | terrain module + shader | `face_hist` matches fixture's known steep cells; flat fixture → 0 promoted; donor label honest. |
| F6 | **Tune the height-aware water band** so low land is not tinted as water; revisit `hmapMin/Max`, `coastfade`, single-quad extent. | Removes dark horizontal bands (P6) that dominate small-map captures. | water owner | Full-width dark rows = 0; water alpha coverage confined to actual water cells; donor literals unchanged or re-cited. |
| F7 | **Restore donor sky/cloud/fog and consume donor ambient/diffuse** with real engine-bound values where recoverable. | Final visual parity layer (P9); currently all port-tuned. | environment owner | Donor fog equations active or explicitly gated; cloud count >0 if donor asset exists; no invented constants. |
| F8 | **Increase detail grain** (higher-res atlas cells / higher splat N with mipmaps) as an interim, labelled APPROX. | Marginal while P1–P4 remain; currently only ~4 texels/cell in fallback (P10). | asset/tool owner | In-cell deviation metric up from 1.233/255; no mip alias; visual A/B. |
| F9 | **Strengthen tests**: port the 21-check small-map probe into `t_terrain3d.gd` (or a new visual atom) with UV2/face/atlas/shader/pixel assertions; add the 128² run. | Prevents regression and false green (P15). | test owner | Committed test fails when UV2/tile/atlas/shader binding breaks; 64² + 128² both run green. |

## Piece-test ladder proposal (smallest map: 64×64)

Reuse `variant3d/tests/fixtures/small_map_64.json` and the `Screenshot3DViewport` capture path
(`TERRAIN_SMALL_maps.md:31-70`). Each test is an **isolated scene** built by a new read-only probe
script (not a game-code edit); same seed 20261113, same camera, 1280×720, capture after ~10 frames.
Baseline expectations from `TERRAIN_SMALL_maps.md:101-121`: 4,096 verts / 7,938 tris / 4,096 UV2 /
UV2.x ∈ [0,85] / face_hist `{0:3455,1:311,2:330}` / atlas `(16,8)` / shadow OFF / 1 water plane.

| Test | What must render | What to measure / assert |
|---|---|---|
| **T0 — terrain only** | One `HeightmapTerrain` mesh + tile-index `ShaderMaterial` + donor sky/sun. **No** water, entities, FX, fog overlay. | 1 surface, 4,096 verts, 7,938 tris, 4,096 UV2; UV2.x ≤123; face_hist sum = 4,096 and matches UV2.y; flat-fixture regression → 0 promoted; `atlas_grid=(16,8)`, 3 samplers bound; shader `shadow_enabled=0`, sun shadow OFF, `cast_shadow=OFF`; non-black >0.9; mean luma + tile-frequency variance; **no full-width dark rows**; per-cell tile-id distinct count and histogram. |
| **T1 — terrain + trees** | T0 plus only tree resource meshes from `game.res_nodes` (`world3d_entities.add_resource`, `POOL_TREE`). | Tree count >0; every tree Y within tolerance of `height_at_world()` at its SIM position; no ground pixel replaced by sky/seam in tree bbox; ground-region luma/variance delta vs T0 recorded (trees should not change ground texgen); draw calls and frame time for the added meshes. |
| **T2 — terrain + shore** | T0 plus the water module with `bind_height_grid()`; coastal fixture with `sandsea*`/`sandrock*` ids present. | Exactly **one** water plane (`WaterPlane`), `height_aware=true`; shore tile ids present in UV2.x histogram; water pixel band count and alpha coverage; `full-width dark rows = 0`; donor literals −0.25/−0.1/2.96 read back; two frames 1 s apart show a non-zero water-only pixel delta (animation); land cells above water not tinted. |
| **T3 — terrain + mines** | T0 plus only mine resource meshes (`ENV_SCALE.mine=0.3152`, sid resolves `mine_*`). | Mine count >0; mine sid resolution non-empty; mine Y matches terrain height; ground luma/variance unchanged vs T0 outside mine bbox; no z-fighting/seam. |
| **T4 — combos (terrain+trees+shore+mines)** | All of the above in one frame, each layer independently toggleable. | All T0–T3 assertions simultaneously; total draw calls; no stacked water planes; no new seam class; non-black >0.9; mean luma recorded; capture comparable to T0 by region subtraction. |
| **T5 — controlled shader A/B** (optional, on T0/T4) | Same fixture/camera, one uniform flipped at a time: `eye_plane_s/t`, `light_position_eye`, `uv_repeat`, `mask_to_alpha`. | Pixel-aligned before/after: changed-pixel count, max channel delta, luma delta; each knob's visual contribution isolated; conclusions labelled PORT APPROX until F0 donor frame exists. |

Every ladder row must also run `python variant3d\tools\smallmap_capture.py scan-stderr` and assert
`SCRIPT ERROR == 0`. The 128×128 fixture is READY_NOT_RUN (`TERRAIN_SMALL_maps.md:123-128`) and
should be added as a second rung after the 64² ladder is green.

**Do not confuse the copied 2D tooling with 3D piece gates.** A full recursive inventory of
`variant3d/` shows near-name matches that all target the **2D `app/` pipeline**, not the 3D path:
`tests/t_shore_smoke.gd:1-5` runs `--path app` and asserts `C3World.SHORE_WASH_DEPTH`;
`tests/visual_tuning_test.gd:1-8` runs `godot --headless --path app` and reads sprite rects from
`C3World._draw_anim`; `tests/t_water.gd` / `t_wave_smoke.gd` / `t_forest_bake*.gd` are likewise 2D;
`tools/terrain_piece_render.py:1-17` is a headless **Pillow** renderer that reads `app/assets` and
never launches Godot, and `tools/pieces/t6_shore_*.py` / `t6_water.py` / `piece_specs/*.json` build
2D single-piece contact sheets. They are useful as *reference art/seeds* for expected shore, mine,
tree and water appearance, but none of them exercises `terrain_tileindex.gdshader`, `UV2`,
`tile_atlas_loader.gd` or `water3d.gd`. Reuse their acceptance ideas (graded shore band, water
animation, forest density, mine display), not their harnesses.

## Open questions

1. Do the exact donor `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` values exist in any readable
   donor text or packed script? (DEEPDEC-02 §6; V786 §6 #1.) Without them F1 stays APPROX.
2. Can the donor `AlphaRows=8/AlphaCols=4/AlphaTileSize=64` sub-rect mapping and
   `tsDouble/ttExtended` packing be recovered, or is whole-atlas sampling the permanent port model?
   (`reftile.lib:3-12` commented; `V785 §7 #2`.)
3. What is the exact engine rule promoting `rockN` → `rockNvf/rockNvs`, and how does `AngleX/AngleZ=25`
   enter geometry/texgen? (`tiles.lib:119-136`; `FIXTERRAIN §8 #2`.)
4. Which shader profile is active — SM20 (`smx3`, 3-tap) or SM30 (`smx9`, 9-tap)? (DEEPDEC-02 §6.)
5. Donor `hmapTex`, reflection FBO and shadow matrix bindings remain UNVERIFIED
   (`DECOMP-04 §8`; `V784 §8`); water fidelity cannot be claimed.
6. Is live `game.tileblock` byte-identical to the donor `GetTileIndex` buffer? (`.map` body not decoded; `V792 §6.7`.)
7. Donor absolute cell size in metres and absolute camera FOV/sensor remain UNVERIFIED
   (`V713 §4`; `V790 §5`; `COMP-03 §4 #4`).
8. Is there any permitted way to produce a donor GPU A/B frame? Universal blocker (COMP-03 E20).
9. `AUDIT3D_03_terrain.md` is stale on light rig, water and splat (pre-V7-60/84/92). Confirm no
   reader still treats its P0-1 as open.
10. Task brief cites `V789_donor_camera_changes.md`; the on-disk file is `V790_donor_camera_changes.md`.
    Coordination naming only; no content difference found.

## Summary

The 3D terrain path is **plumbed correctly**: live donor tile indices, donor atlas art, donor mask
intensity, donor water equations and a donor sun/sky rig all reach the runtime and are measured.
The bad visual quality is therefore **not** the 2D port's "tile map discarded" bug and **not** a
shader-compile or camera-double-subtract failure — those are fixed. It is the combination of:
near-uniform/transition-heavy tile data (P1), neutral eye-plane UVs that make texgen camera-dependent
and wrongly scaled (P2), an unshaded headlight standing in for the donor sun (P3), approximate atlas
packing and mask sub-rect mapping (P4), partial cliff-face promotion (P5), height-driven water bands
(P6), and a structurally wrong-but-measured mask-to-alpha blend (P7), on a 2 m-cell mesh whose
smooth normals erase donor stepped relief (P8). Nothing here can be declared donor-faithful until a
donor GPU A/B exists. The highest-leverage sequence is: baseline A/B → world-ground UVs → real sun
lighting → data diversity → sub-atlas/mask mapping, with the existing 64² harness isolating each
layer before any full-map change.

---

*End of V3D-02. Read-only audit: no game code, shader, asset, config, test or git state was touched;
no Godot job was launched and no donor file was accessed in this pass.*
