# RENDER_ARCH_SYNTHESIS — donor rendering paradigm and the 2D/3D decision

Coordinator synthesis of the R-ARCH wave (8 parallel agents + Craft Anything). Evidence docs:
`RENDER_ARCH_CRAFT_ANYTHING.md`, `RENDER_ARCH_CAMERA.md`, `RENDER_ARCH_TERRAIN.md`,
`RENDER_ARCH_UNITS.md`, `RENDER_ARCH_SHADERS.md`, `RENDER_ARCH_PATTERNS.md`,
`RENDER_ARCH_PORT_FEASIBILITY.md`, `RENDER_ARCH_WHY_WE_FAILED.md`.

## 1. Answer to the owner's question

**The donor is a low-poly 3D game, not a 2D sprite compositor.** The conclusion is supported by five
independent evidence classes, not by one inference:

| Area | Evidence | Verdict |
|---|---|---|
| Executable | OpenGL 1.x imports live (D3D9 imported, 0 xrefs); decompiled `sub_4cd334` switches `glFrustum` / `glOrtho` / `gluOrtho2D` (HUD); RTTI `XCamera/XWorld/XTile/XLightShader/XShadowMap/XWaterShader` | 3D renderer with a 2D overlay |
| Camera | `data/cameras/*.cfg`: `FocalLength=400` gameplay, `Target/Pos/Dir/Up` X,Y,Z, tilt −32°, dolly 20–58, RTS mode. No orthographic width/height anywhere | **perspective** 3D camera, fixed angle |
| Terrain | lit `normal` materials with Ambient/Diffuse/Specular/Shininess; explicit `verticalfront`/`verticalside` faces; `ShadersSM20.HeightField` with shadowed/fog; `HeightTileZones`; real `terrainmesh*.osm` | 3D heightfield with lit materials |
| Units/props | `.osm` meshes decoded with exact size closure (yacht 9,364 v / 7,731 f; building 7,587 v; trees 2 geometry states); `.oss` skinned 20 bones / 483 frames @30 fps; **no pre-rendered entity sprite sheets**; yaw is a renderer transform | live 3D meshes + skeletal animation |
| Shaders/patterns | 109 GLSL shaders with `gl_Vertex`, `gl_NormalMatrix`, `gl_LightSource[0]`, `boneMatrices[16]`, Blinn-Phong, PCF shadows, TBN normal maps, cube reflections, depth-based SSAO/DOF/FXAA; every pattern placement ends in `StandPattern[WithAngle](envPlHnd, name, x, z, angle, …)` | GPU 3D pipeline; patterns place 3D objects |

Correction to earlier assumption: the main view is **perspective** (focal length), not orthographic; it only
reads isometric because tilt and focal length are fixed. `glOrtho` exists in the binary but which branch
drives the main view is still UNVERIFIED (Craft Anything unknown `unk_a6b4c119…`).

## 2. Why the 2D port cannot reach donor fidelity

The port composites donor-derived tile art into `Image` → `Sprite2D` chunks, draws units as baked
azimuth sheets, and uses one `canvas_item` water shader. Structurally impossible on this path:

- perspective-correct per-face lighting and height-based self-shadow (faces are flat pixels);
- geometric parallax/occlusion and near-vertical rock walls with real normals;
- shore refraction/alpha fade driven by a 3D water surface;
- continuous unit yaw, dynamic lighting, and 483-frame skeletal animation;
- depth-based post effects (no depth buffer in a CanvasLayer compositor).

This is not a tuning problem. The checkerboard we just removed was a symptom of trying to synthesise
terrain variety with a 2D gain field instead of using the donor's real TileBlock + SmoothTileMap path.

## 3. Honest answer to "was it decompilation, understanding, or my ask?"

- **Decompilation was not the blocker.** The donor's tile smoothing, tile presets, water shader and
  camera config are plaintext; Craft Anything decoded the binary formats and found a readable 5.18 MB
  CODE section with Deep-mode pseudocode. The packed `.bind` is a 147 KB stub.
- **The failure was ours:** we understood the donor truth and substituted approximations, then
  certified them with self-chosen metrics (std, hi-freq, ACF). Visual review came too late.
- **Your original ask was consistent** — maximum fidelity, "no good enough", repeated rejections of
  approximations. The only fair concession is that the harness biased us toward 2D/headless solutions.

## 4. Decision and staged plan

Recommendation: **keep the 2D mode working, add an optional 3D render mode**, selected before skirmish
(`render_mode = 2d|3d`). Do not rewrite the sim.

| Milestone | Scope | Acceptance |
|---|---|---|
| M0 — terrain-only 3D sandbox | 16×16 tiles; `ArrayMesh` from `game.height_at()`; donor `blocks/*.png` albedo; `Camera3D` perspective equivalent to FocalLength 400 / tilt −32°; one `DirectionalLight3D` with shadows; water plane ported to `shader_type spatial` | non-blank 3D capture of a ravine+shore patch; visual side-by-side with `cossacks-3-v1-498085.jpg`; height error < 0.05 m; frame budget measured |
| M1 — objects | anchor existing 116 `.obj` models on pattern footprints; hash cell position for yaw/scale; env meshes only first | ≥3 distinct tree silhouettes, correct contact shadows, no elevation drift |
| M2 — input/HUD seam | `input_controller.gd` screen→world raycast; `hud.gd` minimap box; keep sim orders identical | select/move/build works in 3D; minimap click no slower than 2D |
| M3 — animated units | new rig/animation export pass (`.oss` → bones + frames); skinning in Compatibility | ≥8 azimuths continuous, walk cycle from real frames, army-scale perf measured |
| M4 — mode switch | pre-skirmish menu flag; `main.gd` selects `world.gd` or `world3d.gd`; dumps/tests byte-identical | selftest 29/29, uitest 17/17 in both modes; same seed → same sim dump |

**Do not start M1–M4 until M0 is visually accepted by the owner.** If M0 cannot beat the 2D mode,
stop and keep 2D with the current honest caveats.

## 5. Risks and asset debt

- Converted `.obj` are bind-pose, Z-up, have no normals/animation and forced-opaque textures — static
  props are reusable, animated units need re-export.
- Compatibility renderer limits: no SDFGI; 9-tap PCF and depth post need workarounds; mass-army draw
  calls and a weak-GPU target require measurement before migration.
- Seams are cross-cutting: `main.gd` bind/setup, `input_controller.gd` picking, `hud.gd` camera box,
  static `C3World`/`C3Camera` typing. Sim/generator/AI/orders/HUD data/minimap/save-load are reusable.

## 6. Process rule for the next wave

1. Donor-paradigm-first: establish the donor mechanism before writing a port fix.
2. Visual A/B gate with terrain-only images BEFORE code changes; metrics support, never replace, eyes.
3. Every approximation must be labelled as such and cannot be called "donor-faithful".
4. Keep the 20480×20480 dump and piece harness as regression artifacts, not as proof of beauty.
