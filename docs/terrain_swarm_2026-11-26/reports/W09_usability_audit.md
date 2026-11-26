---
id: W09-USABILITY-AUDIT
owner: W09
date: 2026-11-26
role: READ-ONLY VISUAL/USABILITY AUDIT — no code edits, no Godot jobs, one report only
output: docs/terrain_swarm_2026-11-26/reports/W09_usability_audit.md
status: DONOR_BACKEND_NOT_USABILITY_READY__P0_HEIGHT_AND_LIGHT_BLOCKERS__PARITY_UNVERIFIED
labels: [O, D, I, U, PORT APPROXIMATION]
parity_guard: "No donor GPU A/B frame exists. Donor citations are prior read-only evidence from G31/RV-CAM-01/DSEL-02 and source headers. No donor parity claim is made."
---

# W09 — donor-backend usability audit

## 0. Executive verdict

**[O] The camera constants are substantially donor-shaped; the scene is not yet usability-ready.**

- **Camera:** fixed tilt **−32°**, documented focal **400**, and explicit dolly **20–58 m** are present. The capture is at the maximum 58 m dolly. **17.27° V-FOV remains a PORT APPROXIMATION**, not a donor value (`camera3d.gd:58-60,76-88,175-195,262-282`; `RV_CAM_01_fov_resolution.md:217-253,306-313`). The shipped config still defaults to the legacy terrain backend; donor mode is an explicit capture overlay (`variant3d/config.json:24-26`; `main.gd:188-191`).
- **P0 terrain/usability blocker:** the playable simulation is **240×240**, but the donor renderer silently selects and builds a **256×256** donor mask for this capture. Render, picking, entities, ghost, selection FX and fog therefore do not share one height/grid source.
- **P0 graphics/usability blocker:** the donor terrain shader lights itself, but the donor path creates **no `WorldEnvironment` or `DirectionalLight3D`**. Imported unit/building/tree/relief materials render as black silhouettes.
- **P0/P1 picking blocker:** ground orders ray-march `game.height_at`, while the visible donor mesh uses a different generated height container. Entity picking is also a screen-circle approximation with an invented 0.8 m body lift, not the donor ray→AABB/priority rule.
- **[O] The new terrain makes readability worse, not better:** `cap_donor_240c.png` has mean luma **30.56/255**, versus **68.75/255** for flat `cap_donor_240b.png`; its middle band is only **21.18/255**. Black units/buildings merge into the dark stepped ground.
- **No parity claim.** The donor stills are third-party direction-only references; this audit uses them neither as a matched camera A/B nor as a fidelity gate.

## 1. Evidence scope and capture admissibility

### 1.1 Required material read

Read first, as requested:

- `docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md`
- `docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md`
- `docs/coord_swarm_2026-11-25/reports/RV_CAM_01_fov_resolution.md`
- `docs/terrain_swarm_2026-11-26/reports/P03_gates_capture.md`
- `variant3d/scripts/{camera3d,picking3d,hud3d_adapter,input_controller,world3d,main}.gd`

Additional read-only code/assets needed to trace the reported systems:

- `variant3d/scripts/{terrain_donor_world,terrain_donor_data,terrain_donor_gen,terrain_donor_inputs,terrain_donor_mesh,world3d_entities,world3d_fx,world3d_fog,world3d_relief,game,hud,config,data}.gd`
- `variant3d/shaders/terrain_donor_shader.gdshader`
- `variant3d/assets/terrain_new/masks/mask_index.json` and the selected height mask
- Current runner result envelopes/stdout/stderr for tickets 633 and 636

No donor file was executed or copied. No Godot process, runner job, test, code edit, asset edit or config edit was performed.

### 1.2 Current capture set

| Evidence | What it proves | Caveat |
|---|---|---|
| `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_donor_240b.png` | Flat olive terrain with black unit/building/tree silhouettes | Ticket 633 hit the then-current `U64_MASK` parse error; not a clean donor-terrain result (`00000633_v42-cap-donor-240b/stderr.txt:1-14`) |
| `...\cap_donor_240c.png` | I17 inputs wired; large dark stepped/terraced field with diagonal bands; same black silhouettes | No `SCRIPT ERROR`, but warnings and shutdown leaks remain (`00000636_v42-cap-donor-240c/stderr.txt:1-93`; `stdout.txt:8`) |
| `...\map_donor_240.json` | Explicit donor backend, 240² map, seed 20261113, FOV 17.27, start zoom `20/58` | This is a capture overlay, not the shipped default (`map_donor_240.json:29-32,41-43,67-83`) |
| `variant3d/.godot_queue/results/00000636.json:4-24` | Windowed `variant3d` run, 10 screenshot frames, exit 0 | Job wall time is not an FPS measurement |
| `00000636_v42-cap-donor-240c/stdout.txt:4-7` | Real `Screenshot3DViewport`, 1280×720, camera current, max-height pose | HUD is deliberately hidden and no selection is applied in screenshot mode (`main.gd:1165-1166,1173-1178`) |

**[O] Capture facts for ticket 636:**

- Viewport: **1280×720**.
- Camera world position: **`(145.8681, 58.0, -86.8149)`**.
- SIM target: **`(385.8681, 60.3657)`**.
- Config FOV: **17.27°**.
- Fog-of-war and render fog: **off** (`map_donor_240.json:49-54`).
- No motion sequence, HUD-visible frame, selection frame, build-ghost frame, mine-placement frame or fog-on frame exists in `v42`.

**[D] Pose check:** map half-extent is 240 m. The centred target is therefore `(145.8681, 0, -179.6343)`. Camera back-offset is `92.8194 m`; `58 / tan(32°) = 92.8194 m`. The capture is exactly at the donor-legal maximum dolly and fixed −32° tilt. This validates the pose, **not** the assumed FOV.

### 1.3 Read-only image measurements

Measurements below are descriptive capture facts, not gates.

| Frame | Mean luma | Near-black fraction (`max RGB < 10`) | Top / middle / bottom mean luma |
|---|---:|---:|---:|
| `cap_donor_240b.png` | 68.75 | 10.24% | 67.07 / 63.19 / 75.98 |
| `cap_donor_240c.png` | 30.56 | 10.27% | 43.64 / 21.18 / 26.85 |

The near-black fraction is not object-only segmentation: dark terrain contributes. Visually, however, the same black building/unit/tree silhouettes are present in both frames. In `240c` they sit against much darker ground, so contrast and form readability collapse.

## 2. Donor camera baseline versus current port

Donor citations here are the established read-only evidence in G31/RV-CAM-01/DSEL-02.

| Item | Donor evidence | Current implementation | Audit verdict |
|---|---|---|---|
| Projection | Perspective; focal 400 (`camera.cfg:44-45`; `default.cameras:17`; G31 `:40-63,225`) | `Camera3D.PROJECTION_PERSPECTIVE` (`camera3d.gd:175`) | **[O] Correct projection class.** |
| Focal | 400 (`camera.cfg:44-45`) | `DONOR_FOCAL = 400` is documentation only; Godot FOV is assigned directly (`camera3d.gd:60,88,179,195`) | **[O] Constant preserved; not used to derive projection.** |
| Tilt | −32° in all four slots (`camera.cfg:32-35`; `onmousewheel.inc:43-47`) | `Data.CAMERA_PITCH = -32`; `look_at()` from `h/tan(32°)` (`data.gd:196`; `camera3d.gd:278-282`) | **[O] Donor-shaped.** |
| Dolly | Height 20–58 m (`camera.cfg:6-10`; `control.script:584-585`) | Explicit height state and clamps (`camera3d.gd:58-59,118-123,235-245,697-703`) | **[O] Donor-shaped.** |
| Wheel | Additive delta; default 2 m per 120 notch (`onmousewheel.inc:296`; `profile.script:17-20,513-516`) | Same formula and sign (`camera3d.gd:689-703`) | **[O] Donor-shaped.** |
| Start | Donor startup clamps to maximum distance; config documents `20/58` (`docreate.inc:82`; `config.json:14`) | Capture uses `start_zoom=0.3448276`, producing 58 m (`map_donor_240.json:76`; `main.gd:1120`) | **[O] Donor-shaped for this capture.** |
| Pan | `profile*4`, default 2 m/s (`oncamera.inc:10-11`) | Same default 2 m/s (`camera3d.gd:675-684`) | **[O] Donor-shaped; do not “fix” by arbitrary speed inflation.** |
| FOV | Runtime focal+viewport API exists; numeric sensor/FOV **UNVERIFIED** (`RV-CAM-01:217-236`) | 17.27° V-FOV, configurable (`camera3d.gd:76-88,192-195`; `config.gd:456-458`) | **[U] PORT APPROXIMATION. Keep labelled; no donor-grounded replacement exists.** |
| Yaw | `DirZ=-1`, `UpY=1`; effective yaw inferred (`default.cameras:11-15`; DSEL-02 `:70`) | Fixed yaw 0 (`camera3d.gd:46-51,262-282`) | **[I] Reasonable port assumption; parity UNVERIFIED.** |

### 2.1 Camera usability defects that remain

#### U-CAM-1 — camera focus and eye are terrain-blind

**[O]** `_apply_transform()` sets the focus at `y=0`, puts the eye at `y=h`, and calls `look_at(base, Vector3.UP)` (`camera3d.gd:264-282`). It never samples the focus terrain height. On the new relief, the screen centre is the **Y=0 plane**, not the terrain point the player is trying to inspect. Higher ground can also intersect the eye-to-focus segment.

**[D] Impact:** framing changes with absolute relief height; a hill focus is not centred; a high ridge can crowd or clip the view. This is not a reason to change −32°, 400, 20–58 or 17.27°.

**Fix:** keep the donor pose geometry, but make focus and eye terrain-relative through the canonical rendered-height provider, with a bounded clearance rule. Label the clearance rule PORT APPROXIMATION until donor camera/terrain collision behavior is recovered.

#### U-CAM-2 — the camera sampler prefers the wrong height field

**[O]** A correct provider exists at `world3d.gd:766-770` → `terrain_donor_world.gd:294-297` → `terrain_donor_mesh.gd:132-150`. But `_resolve_height_sampler()` chooses `game.height_at_world`, then **`game.height_at`**, and only afterwards checks `game.world.height_at_world` (`camera3d.gd:312-334`). The live game does not expose `height_at_world`, so zoom anchoring uses the procedural SIM height, not the donor mesh height.

**Fix:** pass/bind the world height sampler explicitly, or prefer the bound world provider before `game.height_at`. Preserve the existing public API with an optional sampler argument.

#### U-CAM-3 — frustum corners, clamp, view rect and minimap use Y=0

**[O]** `screen_to_world()` intersects Y=0 (`camera3d.gd:293-305`). `get_viewport_corners()` calls it for all four corners (`:397-404`), and `clamp_pos()` uses those flat corners (`:458-489`). `world3d._update_view_rect()` consumes them (`world3d.gd:267-313`), as does the minimap adapter (`hud3d_adapter.gd:119-153`).

**[D] Impact:** camera edge clamp, double-click “on screen” tests and minimap viewport box disagree with the visible relief. The existing `_screen_to_surface()` (`camera3d.gd:364-381`) is not used for corners.

**Fix:** after canonical-height unification, use surface hits for frustum corners. Keep the AABB only as a conservative internal clamp; draw the minimap’s four-edge frustum polygon.

## 3. TERRAIN-GRAPHICS blockers

These are rendering/pipeline defects. They are separated from interaction defects even where the same root cause affects both.

### TG-1 — P0: 240² SIM grid and 256² donor render grid are mixed

**[O] Current capture configuration:** `map_width_tiles = map_height_tiles = 240` (`map_donor_240.json:81-82`). `terrain_donor_data.gd:44-46` explicitly classifies 240 as a **PORT DEBUG ALIAS**, while donor sizes are 256/320/480/640.

**[O] Mask selection:** `_select_mask()` prefers an exact grid but falls back to native-size masks without rescaling (`terrain_donor_inputs.gd:180-222`). A read-only parse of `mask_index.json` finds **681 land candidates**, widths only **256 or 320**, and **zero 240×240 candidates**. Reproducing the FNV-1a selector for seed 20261113 / shape `land` selects:

- `height/src/land/4pl_mask_land_138.height.png`
- `mask_index.json:277254-277280`
- native size **256×256**

**[O] Grid replacement:** `_apply_mask()` writes `p["width"]` / `p["height"]` from the mask (`terrain_donor_inputs.gd:261-281`). `generate()` prefers those values and calls `configure_grid()` (`terrain_donor_gen.gd:466-478,627-632`). The mesh then emits cell centres over that 256² container (`terrain_donor_mesh.gd:743-749`).

**[D] Consequences:**

- Donor mesh extent: `256 × 2 m = 512 m`.
- Playable SIM extent: `240 × 2 m = 480 m`.
- Picking still offsets by the 240² half-map (`picking3d.gd:80-83`).
- Entity transforms still centre by 240² (`world3d_entities.gd:1664-1683`).
- The rendered terrain extends 16 m beyond each playable map edge and uses a different coordinate-to-cell mapping from the SIM.

**Fix:** choose one canonical grid before any usability claim. For donor-grounded captures, use a donor size (256 or 320; G31’s normal default is 320). If 240 must remain supported, perform an explicit, measured 240↔mask mapping and use that same grid/height provider for render, picking, entities, FX, fog and placement preview. Do not silently mix native mask size with a debug SIM size.

### TG-2 — P0: donor path has no scene light rig; entities are black silhouettes

**[O] Terrain lighting is self-contained:** `terrain_donor_shader.gdshader:47-50,216-232,299-309` computes donor Blinn–Phong and is `unshaded` to avoid double lighting.

**[O] Entity materials need scene lighting or explicit shader lighting:** `world3d_entities._default_material()` creates `StandardMaterial3D` (`world3d_entities.gd:644-662`); tinted bodies use a spatial `ShaderMaterial` (`:103-106,1055-1114`). Relief meshes are imported materials as well.

**[O] Donor composer/mesh create no `WorldEnvironment` or `DirectionalLight3D`:** the donor path is `terrain_donor_world.gd` / `terrain_donor_mesh.gd`, and neither file constructs the rig. The legacy path does construct it at `world3d_terrain.gd:1109-1166`, but that module is not instantiated when `terrain_backend == "donor"` (`world3d.gd:623-629`).

**[D] Root cause of the capture:** the self-lit terrain remains visible while StandardMaterial3D entities/resources/relief receive no donor scene light and render black. This explains why both `240b` and `240c` show the same black silhouettes.

**Donor grounding:** `light.cfg:3-29` supplies ambient/diffuse/specular and sun position; G31 `:89-96,228` confirms the donor heightfield uses lit Blinn–Phong. The legacy rig already records those literals (`terrain_donor_mesh.gd:69-76`; `world3d_terrain.gd:1135-1165`).

**Fix:** add the equivalent environment + directional light to the donor composer using the existing donor-cited colours/direction. Keep Godot shadows disabled until a bounded donor-grounded shadow frustum is verified; the legacy path documents the prior directional-streak failure (`world3d_terrain.gd:1153-1160`). Verify both StandardMaterial3D and tinted ShaderMaterial paths, not just trees.

### TG-3 — P1: stepped/diagonal relief is not explained by the old flat-quad defect

**[O] The new mesh is already a shared-vertex height grid:** one vertex per cell, two triangles per cell, height-derived normals (`terrain_donor_mesh.gd:718-788`). It is not the old M0.6 flat-top-plus-wall mosaic diagnosed in G31 `:136-154`.

**[O] Selected base mask is binary:** read-only inspection of `4pl_mask_land_138.height.png` finds exactly **two values**, 0 and 255, mapping to land height 0 and water height −1.1. Water-class fraction is about **7.916%**, matching `mask_index.json:277273`. The selected mask therefore cannot itself supply organic hills.

**[O] I17 supplies B height, not R/G terrain classes:** `_apply_mask()` reads one grayscale channel into `mask_b` (`terrain_donor_inputs.gd:238-281`); R/G remain absent/zero and are explicitly UNVERIFIED (`:630-635`; `mask_index.json:277245-277248`). Donor G31 evidence says the full source bitmap carries R/B classes and terrain-class heights (`generatemap.inc:537-577`; G31 `:73-80`).

**[D] Inference:** the visible terraces are dominated by downstream pattern/relief generation and texture/normal response, not by a continuous R-class donor mask. The dark diagonal bands are a real capture observation, but their exact layer (height quantization, tile/eye-plane mapping, normal stencil or alpha crossfade) is **UNVERIFIED** without the quantitative diagnostics required by the visual charter.

**Fix:** produce height/tile-id/normal diagnostics from the actual 256² generated container before changing appearance. Recover proper derived R/G inputs if they are the intended donor source; otherwise label the current result pattern-only. Do **not** hide the bands with noise, dither, FOV changes, face promotion or `HEIGHT_SCALE` fudging.

### TG-4 — capture warnings: separate real risks from false positives

- **[O] Four relief “map miss” warnings are false-positive diagnostics.** `world3d_relief.gd:347-350` treats any path beginning `res://assets/models/obj/` as a legacy fallback, but the mapped bucket paths also have that prefix. The actual files exist under `assets/models/obj/shared/terrain/` (`manifest.json:376-468`). Do not claim missing relief geometry from these warnings; fix the path test.
- **[O] Export/import warnings remain:** case mismatch for `K_ravine_2.json` and image-resource import warnings (`00000636.../stderr.txt:1-37,77-85`). They are portability/cleanliness issues, not proof of the visual root cause.
- **[O] Shutdown leaks remain:** RID/texture/object/resource leak messages (`stderr.txt:86-93`; `stdout.txt:8`). The frame is useful visual evidence, but the run is not a clean acceptance capture.

## 4. USABILITY blockers

### U-1 — P0: selection/order ground picking does not use the visible donor surface

**[O] Orders:** `_screen_to_world()` calls `picking3d.ground_point()` (`input_controller.gd:631-641`). `ground_point()` ray-marches `game.height_at` (`picking3d.gd:130-171,235-243`). The donor mesh samples its own `_height` (`terrain_donor_mesh.gd:132-150`).

**[O] Entities/resources:** `world3d_entities._world_pos()` also uses `game.height_at` (`world3d_entities.gd:1664-1683`). FX, ghost, rally and selection markers use it again (`world3d_fx.gd:811-820`).

**[D] Impact:** a click can land on one surface while the unit/tree/building is drawn on another. On the stepped capture this produces floating, sinking or occluded objects and makes “click what I see” unreliable.

**Fix:** make `world.height_at_world()` the canonical presentation height for camera, picking, entities, resources, ghost, rally, selection and fog. Keep SIM arrays read-only; do not “fix” this by writing generated render heights back into gameplay arrays from the renderer.

### U-2 — P1: entity picking is a screen-circle approximation, not donor picking

**[O] Current pick:** project entity ground + `BODY_LIFT_M=0.8`, compare screen-pixel distance to a pixel radius, then use an unconditional 2 m fallback (`picking3d.gd:41-42,224-230,259-301`). The code itself acknowledges the parallax residual (`:259-265`). It does not test the camera→ground segment against entity collision geometry.

**[O] Donor rule:** `control.script:164-184,258-266` casts the camera→cursor-ground ray, tests `GetGameObjectRayCastAABBByHandle`, filters player/visibility/collision, and ranks by `(1+dist)/prio`; priorities are in `dmscript.global:227-233` (DSEL-02 `:71-74,157-179`). Donor ground precision is `1e-7` (`init.script:101`).

**[O] Current ray march:** 1 m steps plus 20 bisections (`picking3d.gd:36-38,148-171`). A narrow ridge or sharp terrace can be crossed between samples; the fallback is Y=0. Donor native ray math is UNVERIFIED, but the call path and AABB test are observed.

**[O] Left-click filter mismatch:** current left-click release calls `_pick(pw, false)` (`input_controller.gd:873`), while donor left-click uses own-player-only; orders use the unfiltered path (`onmousedown.inc:280,394,480,683`; DSEL-02 `:239-242`).

**Fix:**

1. Use the canonical terrain ground point.
2. Build entity collision AABBs at canonical height and intersect the camera→ground ray.
3. Apply donor priority ranking and visibility/FOW filtering.
4. Make left-click `players_only=true`; keep right-order and cursor lookup unfiltered.
5. Remove the arbitrary 0.8 m lift from the primary hit test. If the 2 m fallback is retained for port feel, label it PORT APPROXIMATION and keep it secondary.

### U-3 — P1: steep terrain makes marquee and selection feedback fragile

**[O] Capture limitation:** screenshot mode hides the HUD and deliberately does not select the home building (`main.gd:1165-1166,1173-1178`). No current frame proves selection-ring appearance.

**[O] Marquee geometry:** four ground corners are converted to an **axis-aligned world AABB**, then every friendly unit whose SIM point lies inside is selected (`input_controller.gd:653-677`). On relief, that AABB can include units behind ridges or outside the visible trapezoid.

**[O] Double-click view test:** uses `world.view_rect` and `u.pos * view_scale` (`input_controller.gd:877-884`), but `view_rect` derives from flat Y=0 frustum corners (`world3d.gd:267-313`).

**[O] Selection ring:** a flat torus and centre pip are placed at `game.height_at(pos)` (`world3d_fx.gd:811-820,1256-1277`). It is not draped over the donor surface and can be buried on a slope or float across a terrace.

**Fix:** preserve donor world-ground marquee semantics, but use the actual four-corner ground polygon and terrain/visibility filtering rather than its AABB. Drape or depth-safe the selection ring/pip using the canonical height field. Recompute double-click visibility from the surface frustum. Require a HUD-visible selected-unit capture on flat ground, a slope and a ridge before sign-off.

### U-4 — P1: building and mine placement previews can disagree with the placed result

**[O] Ghost ground point:** the live 3D path forwards the same picking ground point used by the click (`input_controller.gd:1507-1515`), which is correct in principle. But FX grounds the ghost with `game.height_at` (`world3d_fx.gd:811-820`), not the donor mesh.

**[O] Legality:** `can_place()` checks SIM `terrain`, resources, buildings and `blocked`, with no terrain-height/slope/footprint test (`game.gd:4212-4284`). The donor renderer may show water/relief that the SIM legality grid does not represent.

**[O] Mine preview mismatch:** `resolve_mine_sid()` chooses a deposit within 4 m (`game.gd:19,3305-3322`). The ghost resolves the sid but remains at the cursor (`world3d.gd:504-518`). Only the final `place_building()` snaps `pos` to the deposit centre (`game.gd:4318-4337`). On a slope, the mine can jump horizontally and vertically between preview and commit.

**Fix:**

- Ground ghost and final structure from the same canonical height provider.
- Use one shared mine-resolution helper that returns both sid and snapped position; preview exactly what `place_building()` will place.
- Do not invent a slope cutoff. First expose donor-derived water/collision/height legality; if unavailable, keep the donor backend experimental and mark preview legality UNVERIFIED rather than claiming the green ghost is authoritative.

### U-5 — P1: minimap frustum is flat and the implemented quad is not drawn

**[O] Donor behavior:** minimap is 240×240, zoom 1, with `SetMiniMapFrustumVisible(true)` (`initminimap.inc:5-7,29-39`); `GetCameraFrustumQuadrangle` supplies four ground corners (`classes.script:6030-6040`).

**[O] Current adapter:** maps four flat camera corners into minimap space (`hud3d_adapter.gd:119-153`). It also implements `get_minimap_quad()` / `stroke_minimap_quad()` (`:156-195`), but the only references are inside the adapter itself. The live HUD still calls `get_minimap_box()` and `_mm_paint_box()` (`hud.gd:1705-1758`), so the minimap displays an AABB, not the frustum quad.

**Fix:** draw the existing four-edge quad through `stroke_minimap_quad()` and feed it surface-frustum corners. Retain `get_minimap_box()` only for compatibility/tests. Exact donor line style remains UNVERIFIED; keep the PORT APPROXIMATION label.

### U-6 — P2: fog is off in the capture; fog-of-war would use the wrong relief

**[O] Donor depth fog is not a usability fix:** `camera.cfg:51-64` has `DynFogDepth=False` in gameplay (G31 `:44`; DSEL-02 `:103`). The donor terrain shader also sets `fog_mode=0` (`terrain_donor_mesh.gd:542`). Do not enable distance fog to disguise the stepped/dark terrain.

**[O] Fog-of-war is separate and currently off:** capture config has both fog flags false (`map_donor_240.json:49-54`). If enabled, `world3d_fog` builds flat per-tile quads from `game.height` plus 0.03 m (`world3d_fog.gd:168-215`), while explicitly leaving donor-terrain alignment open (`:175-178`). On the 256² donor relief, the overlay can be buried or float.

**Fix:** keep depth fog off. Before enabling fog-of-war, sample/drape the overlay from the canonical rendered height or integrate per-cell fog into the terrain shader. Preserve the existing 0.78/0.30/0.00 port ladder; do not invent a donor fog-of-war rule (`world3d_fog.gd:26-31,38-44`).

### U-7 — P2: donor 0.5× speed is misreported; high speeds are unmeasured

**[O] Donor speed set:** `Data.DONOR_GAME_SPEED` includes slow 0.5, normal 1, fast 2 and very fast 4 (`data.gd:385`). The lobby exposes those donor ids (`menu.gd:757-759`).

**[O] HUD mismatch:** the speed dropdown contains pause, 1, 2, 4, then port-added 8/16/32/64, but **no 0.5** (`hud.gd:462-465`). `_speed_index()` falls back to index 1 when 0.5 is absent (`hud.gd:618-624`), so the dropdown shows 1×. The label uses `"%.0fx"`, so 0.5 is displayed as **0×** (`hud.gd:656-658`).

**[O] High-speed execution:** `set_speed()` allows up to 64 (`main.gd:728-731`); the fixed-step loop allows at most 64 ticks per rendered frame and clamps `dt` to 0.25 (`main.gd:1623-1643`). `world.sync(dt)` runs once per rendered frame with real `dt`, not simulated `dt*speed` (`main.gd:1678-1681`). At low FPS, accumulator debt and visual stepping can therefore diverge from the displayed speed.

**[U] No motion/FPS evidence:** ticket 636 is a still. No claim is made that 8–64× is currently smooth or slow.

**Fix:** add a 0.5× donor option and fractional-safe label formatting. Keep 8–64× explicitly labelled port extensions. Measure actual sim-seconds/wall-second, frame time, accumulator debt and visual interpolation before accepting high speeds; do not alter fixed-step sim semantics merely to make the dropdown look faster.

## 5. Prioritized concrete fixes for COORD

| Priority | Fix | Primary files | Donor-behavior preservation constraint | Verification |
|---:|---|---|---|---|
| **P0-1** | Establish one canonical grid/height provider; use donor 256/320 for donor captures or explicit measured 240 mapping | `terrain_donor_inputs.gd`, `terrain_donor_gen.gd`, `terrain_donor_data.gd`, `world3d.gd`, `main.gd` | Donor sizes are 256/320/480/640; 240 remains a labelled debug alias. No renderer write-back into SIM | Same world point yields identical mesh, pick, entity, ghost and fog heights; mesh extent equals playable extent |
| **P0-2** | Bind camera/picking/entities/FX to `world.height_at_world()` | `camera3d.gd`, `picking3d.gd`, `world3d_entities.gd`, `world3d_fx.gd`, `world3d_fog.gd` | Keep camera tilt −32°, focal citation 400, dolly 20–58 and 17.27° labelled assumption | Flat/slope/ridge click probes; objects visibly contact terrain; no floating/sinking |
| **P0-3** | Add donor-cited environment + directional light to donor path | `terrain_donor_world.gd` or `terrain_donor_mesh.gd` | Use `light.cfg` colours/direction; keep shadows off until bounded/verified | Units/buildings/trees/relief show albedo and form; no pure-black silhouettes |
| **P0-4** | Keep legacy backend default until P0 and interaction captures pass | `variant3d/config.json`, `main.gd` | Visual-wave charter requires legacy default until new captures pass | Explicit donor overlay only for experiments; `app/**` unchanged |
| **P1-1** | Replace primary screen-circle pick with donor ray→AABB + priority; own-only left click | `picking3d.gd`, `input_controller.gd` | Donor `control.script:164-184,258-266`; orders remain unfiltered | Overlapping units, enemy behind own unit, ridge occlusion, resource priority probes |
| **P1-2** | Use surface frustum for clamp/view rect/minimap; draw minimap quad | `camera3d.gd`, `world3d.gd`, `hud3d_adapter.gd`, `hud.gd` | Donor four-corner frustum and minimap-frustum behavior; line style stays PORT APPROXIMATION | Minimap quad follows camera on flat/slope; no box drift at map edge |
| **P1-3** | Make marquee/selection terrain-aware and rings slope-safe | `input_controller.gd`, `world3d_fx.gd` | Keep donor world-ground drag and Shift-add semantics; exact native inside predicate remains U | No selection through ridges; ring/pip readable on slope and terrace |
| **P1-4** | Unify ghost/final height and mine snapped position | `world3d.gd`, `world3d_fx.gd`, `game.gd` | Preserve 4 m mine-site resolution and existing legality messages; no invented slope threshold | Ghost and placed mine coincide; valid/invalid preview matches commit |
| **P1-5** | Diagnose/fix stepped relief at source | `terrain_donor_inputs.gd`, `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, shader | No noise/dither, face promotion, HEIGHT_SCALE or FOV fudge | Height/tile/normal diagnostics explain bands; visual review on 256/320 |
| **P2-1** | Fix 0.5× HUD option/label; instrument high-speed behavior | `hud.gd`, `main.gd` | Donor speeds remain 0.5/1/2/4; extras stay labelled port extensions | Lobby slow shows 0.5×; measured sim/wall rate at 1/4/8/64 |
| **P2-2** | Drape fog-of-war or integrate it into terrain shader; keep depth fog off | `world3d_fog.gd`, donor shader | Donor `DynFogDepth=False`; existing port FOW ladder unchanged | Fog-on capture has no buried/floating overlay |
| **P2-3** | Produce HUD-visible interaction/motion capture set | COORD-owned runner only | Same seed/size/camera/crop; no parity claim | Selected units, marquee, ghost, mine snap, minimap, fog on/off, dolly/pan motion; clean stderr |

## 6. Minimum owner-run capture set after fixes

P03’s existing gate rules remain unchanged. W09 submits no jobs. COORD should capture, one runner job at a time:

1. **Canonical donor grid:** 256² or 320², seed 20261113, donor overlay, same camera constants.
2. **HUD visible:** home selected, resource bar, unit panel, minimap quad.
3. **Selection:** single unit, overlapping units, marquee on flat ground, slope and ridge; selected ring visible.
4. **Picking/orders:** own/enemy overlap, resource behind ridge, right-click ground and resource.
5. **Placement:** ordinary building on flat/slope, invalid ground, mine ghost and final snapped mine.
6. **Fog:** off/on with canonical height; depth fog remains off.
7. **Motion:** wheel through 58→20 m, cursor-anchored dolly, pan, minimap jump, 1×/4× and any retained high speed.
8. **Integrity:** 1280×720 windowed GPU frame, `camera_current=true`, `world_parent=Screenshot3DViewport` where applicable, no `SCRIPT ERROR`, no shutdown leaks, fresh result mtime.

Visual review overrides metrics. No threshold in P03 is lowered, and no image score is a donor-parity gate.

## 7. UNVERIFIED register

| Item | Status / why |
|---|---|
| Donor numeric FOV/sensor | **UNVERIFIED.** RV-CAM-01 found the API but no sensor constant or readable call site. Keep 17.27° labelled PORT APPROXIMATION |
| Effective donor yaw | **UNVERIFIED.** `DirZ=-1` supports yaw 0 only as an inference |
| Camera terrain-follow/collision behavior | **UNVERIFIED.** Current transform is terrain-blind; donor native behavior not recovered |
| Exact donor entity AABB extents and all priority mappings in this scene | **UNVERIFIED.** Script call/ranking is observed; engine collision extents are not |
| Donor drag-selection inside predicate / occlusion rule | **UNVERIFIED.** World-ground selection API is observed; native geometry is not |
| Donor build slope/footprint-height rule | **UNVERIFIED.** Do not invent a threshold |
| `ArcTan()` semantics for minimap offset | **UNVERIFIED.** `height/tan(32°)` is numerically supported by the bookmark but remains a port approximation |
| Exact source of diagonal dark bands | **UNVERIFIED.** Height/tile/normal/alpha diagnostics not yet available |
| Live HUD/minimap/selection appearance | **UNVERIFIED.** Current captures hide HUD and selection |
| Fog-of-war donor binding | **UNVERIFIED.** Depth fog is separately observed off in gameplay |
| High-speed smoothness | **UNVERIFIED.** No motion/FPS capture exists |

## 8. Honesty / scope statement

Exactly one file was written: `docs/terrain_swarm_2026-11-26/reports/W09_usability_audit.md`. No `.gd`, shader, config, asset, test, result JSON, PNG, `app/**` file or git state was edited. No Godot process or runner subcommand was executed. No donor binary was executed or copied. All image measurements and mask-selection arithmetic were read-only local analysis. **PORT APPROXIMATION / internal usability audit only; donor parity remains UNVERIFIED.**
