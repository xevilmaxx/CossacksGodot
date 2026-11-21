# RENDER_ARCH_PORT_FEASIBILITY — feasibility of a selectable 3D-ortho render mode

Agent: R-ARCH-PORT3D. Date: 2026-11-21.
Scope: **READ-ONLY feasibility study.** No code edits, no Godot runs, no donor
archaeology. Sole deliverable: this file.

## 0. Ground rules

- `OBSERVED` = read directly from the repository at the cited `file:line`.
  `INFERRED` = reasoned from observed code. `UNVERIFIED` = owner-supplied figure
  or toolchain knowledge not checked in this study (no Godot run was permitted).
- The pending `R-ARCH_*` investigations may confirm that the donor uses a true
  3D orthographic pipeline. This study **assumes that outcome is plausible** and
  sizes the port cost; it does not assert that the donor is 3D.
- Line references are to the working tree as of 2026-11-21, which contains other
  swarm agents' uncommitted edits. Re-check them before implementation.

---

## 1. Current architecture map (2D mode)

| File | Role | Key API / facts | Relevance to a 3D branch |
|---|---|---|---|
| `app/scripts/main.gd` | Entry, config, staged load, dispatch, sim loop, captures | `_ready` :123; menu hand-off :196; `_apply_menu_cfg` :213; staged load `_do_async_load` :352 (world :400, camera :405, HUD :413, input :428); `_setup_full_game` :540 (world :553, camera :557); `_process` :968 → `world.sync(dt)` :1042; `_consume_events` :1104; `_dump_map` :508; `game_load` :831; headless CPU render :1264 | **Primary divergence seam**: world/camera/input construction in two places (:400-430 and :553-594); typed `var world: C3World` / `var camera: C3Camera` :44-46; fog reset touches `world.fog_*` :836-838 |
| `app/scripts/game.gd` | Pure simulation + map generation | `terrain`, `blocked`, `height: PackedFloat32Array`, `tileblock`, `tbl_names` :27-43; `entities` :67; `height_at` :1609; `tile_of` :370; `pick_radius` :1271; `serialize`/`deserialize` :4744/:4781 | Fully render-agnostic; the 3D terrain mesh reads `height` + `tileblock` directly. **Shared, no rewrite.** |
| `app/scripts/world.gd` | `Node2D` compositor: terrain, water, entities, fog, FX | `extends Node2D` :9; `view_scale=16` :16; `CHUNK_T=32` :25 and `terrain_chunks` :26; `view_scale=Data.PIXELS_PER_METER` :176; `_art_name` :1005 (tileblock index → donor block name); `_build_chunk` :1387; `_sync_terrain_chunks` :1559 (2 bakes/frame, whole map resident); `sync` :1631; `_update_fog` :1667; sprite loading :306; `world_to_px` :274 | **Do not reuse draw code.** Its 2D outputs (baked chunk textures, CanvasItem `_draw_*` callbacks, fog Sprite2D, canvas-item water shader) have no 3D analogue. Keep as the 2D branch. |
| `app/scripts/camera.gd` | `Camera2D` edge-scroll + zoom-at-cursor | `extends Camera2D` :2; `DEFAULT_ZOOM=2.0` :15; `bind` :20; `clamp_pos` :38; `_zoom_at_cursor` :77 | Keep for 2D; a `Camera3D` twin needs the same clamp/zoom semantics expressed in metres. |
| `app/scripts/data.gd` | All tunables / donor-derived constants | `TILE_M=2.0` :23, `MAP_W/H` :33-34, `PIXELS_PER_METER=16` :113, `TERRAIN_PX` :114, `CAMERA_PITCH=-32.0` :161, `CAMERA_MIN/MAX_HEIGHT=20/58` :162-163, quality presets :148-159 | Add `render_mode` + 3D camera constants here; existing sim numbers untouched. |
| `app/project.godot` | Engine config | `config/features=("4.4","GL Compatibility")` :9; `renderer/rendering_method="gl_compatibility"` :25-26; `stretch/mode="canvas_items"` :18; 1280×720 :15-16 | Fixes the renderer constraints in §5; 3D must work under Compatibility. |
| `app/scripts/input_controller.gd` | Orders, selection, build ghost, hotkeys | typed `world: C3World`, `camera: C3Camera` :10-12; `bind` :35; `route_node: Node2D` :33/:48-52; `_screen_to_world` :226 (canvas inverse ÷ `view_scale`); `_pick` :234 (distance vs `pick_radius`); `_unhandled_input` :258; `_pick_res` :453; `minimap_order` :109 | **Second divergence seam.** Only screen→world unprojection and entity hit-testing change; all `game.cmd_*` calls stay. |
| `app/scripts/hud.gd` | HUD + minimap | typed `world: C3World` :9; minimap images :32-38; `_build_minimap` :992; `_on_minimap_input` :1039; `_draw_minimap_viewport_box` :1065 uses `get_camera_2d()` :1072 | **Third divergence seam.** Minimap *data* is shared; only the viewport box needs a 3D camera adapter. |
| `app/tools/convert_models.py` | Donor mesh → `.obj`/`.mtl`/`.png` | OSS/OSM readers :43/:69; `write_obj` :109 (writes `v`, `vt`, `f` only); `convert_texture(force_opaque)` :135/:143-147; model tables :160/:186/:224; manifest :361 | Source of the 3D asset limitations in §5. |
| `app/assets/models/{obj,tex}` | Converted donor models | 116 `.obj`, 116 `.mtl`, 116 `.png`; manifest `bbox` is Z-up (peasant z 0.007..1.995) | Candidate 3D meshes, but need re-conversion (normals, axes, alpha, animation). |
| `app/assets/terrain/**` | Donor terrain art | 691 PNGs in `blocks/`, `decals/`, `masks/`, `water_png/`, … | Candidate tile materials for a 3D terrain mesh. |
| `app/tools/render_models.py`, `bake_sprites.py` | Bake donor meshes to 2D sprites | ortho camera, `--elevation 32` :50, azimuth `start_angle + 360*d/directions` :417, `setup_camera` :310; sprite `--size` default 256 :47; anim cell default 160 (`bake_sprites.py:50`); `sprites_hi` 512 px rebake (`world.gd:331-335`) | Provides the working tilt/yaw proxy for a 3D camera (§5). |
| `docs/audit/TERRAIN_REFERENCE_IMAGES.md` | Donor still spec | 12 stills in `C:\Users\Maxym.Oboyshev\Downloads\c3\`; primary #8 `cossacks-3-v1-498085.jpg` :23 | Visual target for the M1 comparison. |

**Load path (observed):** `menu.gd` emits a Dictionary → `main._on_menu_chosen`
→ `_apply_menu_cfg` writes `Data` statics → `_do_async_load` builds `game` then
`world` then `camera` then `hud` then `input` → `_process` ticks `game`/AI then
calls `world.sync(dt)` → `world` redraws its CanvasItem layers and consumes
`game.events` via `main._consume_events`. Headless/CLI/`--dump-map` paths build
**no world at all** (`main.gd:164-170`, :498-538).

**Where rendering diverges:** (1) bind/setup in `main.gd`; (2) screen↔world
unprojection + picking in `input_controller.gd`; (3) camera-derived viewport box
in `hud.gd`; (4) the static `C3World`/`C3Camera` types in `main.gd`, `hud.gd`,
`input_controller.gd`. Everything downstream of `game.cmd_*` is shared.

There is currently **no 3D code in the project**: a grep over all `*.gd` for
`MeshInstance3D|Camera3D|ArrayMesh|SurfaceTool|Node3D` returned zero functional
hits (only a nav.gd comment containing "orthogonal").

---

## 2. Required 3D subsystems (target file + risk)

| # | Subsystem | Target file(s) | Work required | Risk |
|---|---|---|---|---|
| 1 | `render_mode` flag + pre-skirmish UI | `menu.gd:274-310,459`; `main.gd:213-253,400-430,553-594`; `config.gd`/`config.json` | OptionButton row ("2D sprites / 3D ortho"), emit in `chosen`, read in main, branch world/camera/input; default `2d`; force 2D for CLI/screenshot/dump in M1-M2 | **Low** |
| 2 | Common world contract | new `world_base.gd` or relaxed `Node` typing in `main.gd:44-46`, `hud.gd:9`, `input_controller.gd:10-12` | Agree on `bind(game)`, `sync(dt)`, `view_scale`, `world_to_px`, `fx_layer`, `view_rect`, `fog_explored/fog_vis`; without this, `C3World3D` cannot be assigned to `var world: C3World` | **Medium** |
| 3 | `Node3D` world | new `app/scripts/world3d.gd` (`extends Node3D`, `class_name C3World3D`) + `app/scenes/world3d.tscn` | Replace Sprite2D layers / `_draw_*` callbacks with 3D children; implement the same `bind`/`sync` contract; own scene-instanced environment/lights | **High** |
| 4 | Orthographic `Camera3D` | new `camera3d.gd` (`extends Camera3D`) + focus code in `main.gd:408-412,560-572` | `PROJECTION_ORTHOGONAL`; `size` derived from existing zoom range; elevation 32° (`data.gd:161`), yaw 45° working assumption; clamp to `MAP_W/TILE_M`; zoom-at-cursor via ground-plane ray | **Medium** |
| 5 | Terrain mesh from `game.height` | new `world3d_terrain.gd` (or inside `world3d.gd`) | Build `ArrayMesh`/`SurfaceTool` quads indexed `y*MAP_W+x`, height = `game.height[idx] * HEIGHT_SCALE`; chunk by `CHUNK_T=32` to bound rebuilds; water plane at `WATER_LEVEL=-0.25` | **High** |
| 6 | Tile materials / texturing | new `tools/convert_terrain_3d.py` or a build-time atlas over `app/assets/terrain/**` | Map `game.tbl_names[tileblock[i]]` → material; per-chunk multi-material or one atlas with per-tile UV; preserve season/relief tint | **High** |
| 7 | Unit/building/tree meshes | extend `convert_models.py` / new `convert_models_3d.py` → `.glb`; `MeshInstance3D`/`MultiMeshInstance3D` in `world3d.gd` | Y-up conversion, normals/tangents, per-team materials, scale normalisation from manifest `bbox`; reuse the 116 converted sids first | **High** |
| 8 | Animation | new `anim3d.gd` (or converted clips) | Donor `.oss` has bone frames/weights but they are discarded by `write_obj`; need skeleton import or per-frame baked meshes for 8 directions | **High** |
| 9 | Lighting / shadows | `WorldEnvironment` + `DirectionalLight3D` in `world3d.tscn` | Key/fill analogous to `render_models.py:300-307`; shadow budget keyed to `Data.QUALITY` | **Medium** |
| 10 | Water shader | port `app/shaders/water_overlay.gdshader` to a `spatial` shader on a plane | Scrolling waves + shore alpha; the existing shader is `canvas_item` and cannot be attached to a mesh | **Medium** |
| 11 | Fog of war | `world3d.gd` shader/vertex-color + existing `game.reveal_requests`, `fog_counts`, `tile_visible` | Replace the full-map `Sprite2D` overlay (`world.gd:264-271`) with per-tile terrain shading and entity visibility filtering | **Medium** |
| 12 | Picking / raycast path | new `_screen_to_world3d`/`_pick3d` in `input_controller.gd` (seam at :226-256) | `Camera3D.project_ray_origin/normal` ∩ heightfield, plus screen-space entity hit test with depth ordering; do **not** change `game.cmd_*` | **Medium** |
| 13 | Minimap / HUD adapter | `hud.gd:1065-1096` | Feed the visible world rect from `camera3d` (project frustum corners to ground) because `get_camera_2d()` returns null; minimap image and orders stay | **Low-Medium** |
| 14 | FX / projectiles / ghosts | `world3d.gd` counterparts of `world.add_fx` / `_draw_fx` | Event stream from `main._consume_events:1104-1154` is sim-agnostic; draw as 3D quads/particles | **Medium** |
| 15 | Save/load + test harness | `main.gd:831-841`; `tools/godot_runner.py`, `tools/test_drive.py`, `app/tests/*` | Adapt fog reset; add a windowed 3D capture gate; keep headless paths sim-only | **Low** |
| 16 | Performance gate | `tools/test_drive.py` bench / `shots/bench.json`, `t_mass_army` test | Measure draw calls and frame time; batch per sid/facing with `MultiMesh`; benchmark on a named machine | **Medium-High** |

---

## 3. Shareable vs rewrite

| Asset / subsystem | Verdict | Notes |
|---|---|---|
| `game.gd` sim: arrays, generator, orders, squads, morale, economy, victory | **SHARE (100%)** | No render types referenced; `height`, `tileblock`, `entities` are plain data. |
| `mapgen.gd`, `pattern_gen.gd`, `nav.gd` | **SHARE** | Sim-side generation/pathfinding; 3D reads their output only. |
| `ai.gd`, all `C3AI` brains | **SHARE** | Orders are world-coordinate based; unprojection is upstream. |
| `data.gd` constants / quality presets | **SHARE + extend** | Add `render_mode`, `HEIGHT_SCALE`, 3D camera yaw/size; never mutate sim numbers. |
| `game.cmd_*` / `formation_targets` / `can_place` | **SHARE** | All take metres; the only change is how a click becomes metres. |
| HUD resource/selection/build/train panels, messages | **SHARE** | They read sim dictionaries (`hud.gd` bind :8-10). |
| Minimap image generation + minimap orders | **SHARE** | Derived from `terrain`, `entities`, `res_nodes`; only the viewport box is camera-dependent. |
| `serialize`/`deserialize`, `--dump-map`, quicksave/replay | **SHARE** | Render state is not serialised; `game_load`'s fog reset is the one adapter (:836-838). |
| Converted terrain PNGs (691) and prop textures with alpha | **SHARE** | Usable as 3D material inputs after UV/atlas work. |
| 2D sprite sheets (`assets/models/sprites`, `sprites_hi`, `anim`, `naval`) | **KEEP for 2D; unused in 3D** | Baked orthographic views of the donor meshes; a 3D scene re-renders geometry instead. |
| Unit/building `.obj` + `.png` as-is | **ADAPT / RE-CONVERT** | No normals, no animation, Z-up, alpha forced off (§5). |
| `world.gd` 2D compositor | **KEEP as 2D branch; do not rewrite** | Its CPU bake, face collar, water overlay and fog sprite are 2D-only techniques. |
| `camera.gd` (`Camera2D`) | **KEEP for 2D; new twin for 3D** | Shared behaviour is zoom/clamp, not the node type. |
| `input_controller.gd` selection/hotkeys/orders | **ADAPT (small seam)** | Replace `_screen_to_world`/`_pick`/`_pick_res` internals; route overlay `Node2D` needs a 3D equivalent or CanvasLayer. |
| Water shader, fog overlay, contact shadows | **REWRITE** | canvas_item → spatial/shader-material equivalents. |
| Test/capture tooling | **EXTEND** | Add a 3D capture path; do not weaken existing 2D gates. |

**Net:** the simulation, generator, AI, orders, HUD data, minimap, and
save/load/dump are reusable verbatim. The rewrite is confined to a new
`world3d.gd`, `camera3d.gd`, a small input/picking adapter, material conversion,
and the camera-derived minimap box.

---

## 4. Proposed implementation shape

### 4.1 Settings flag

Add `render_mode = "2d" | "3d"` to the pre-skirmish screen: an `OptionButton`
row in `menu.gd:_show_skirmish` near "Map size" (:292), emitted in the `chosen`
Dictionary (~:459), written to `Data` / config as `gameplay.render_mode` and
read by `main._apply_menu_cfg`. **Default `"2d"`** so every existing test,
capture and save remains byte-stable. CLI, `--screenshot`, `--dump-map`,
self-test and UI-test stay 2D/sim-only through M2.

### 4.2 Dispatch

In both construction sites (`main.gd:400-430` and `:553-594`):

```
if render_mode == "3d":
    world = C3World3DScript.new()      # extends Node3D
    camera = C3Camera3DScript.new()    # extends Camera3D
    input_ctl = C3Input3DScript.new()  # or same controller with a mode strategy
else:
    ... existing C3World / C3Camera / C3Input ...
```

Because `main.gd`, `hud.gd` and `input_controller.gd` declare `world: C3World`
and `camera: C3Camera`, either introduce a tiny shared interface/base node or
relax those declarations to `Node` and guard feature access (`fx_layer`,
`fog_*`, `view_rect`). The shared interface is preferable: it makes the seam
explicit and keeps `game_load` (:836-838) working.

### 4.3 Staged plan

**M0 — design gate (no code).** Confirm donor tilt/yaw from `R-ARCH_*`; choose
chunking (recommend 32 tiles, matching `CHUNK_T`), mesh format (recommend `.glb`
over runtime `.obj` import to control axes/normals/materials), and the height
scale constant. Exit criterion: camera and material decisions written down.

**M1 — minimal first milestone: terrain-only 3D sample.** 3D ortho camera, an
`ArrayMesh` terrain built from `game.height` + `tileblock`/donor block colours,
a flat water plane, one directional light, no units/buildings/trees/fog/FX.
Selectable via the menu flag; capturable with a 3D `--screenshot` branch.
Visually compared to the donor stills in
`C:\Users\Maxym.Oboyshev\Downloads\c3\` (primary `cossacks-3-v1-498085.jpg`,
see `docs/audit/TERRAIN_REFERENCE_IMAGES.md:23`).

*Acceptance criteria (all required, measurable):*

1. Vertex count = `MAP_W * MAP_H` (102,400 at the default 320×320) and every
   sampled vertex Y equals `game.height[y*MAP_W+x] * HEIGHT_SCALE` within
   `1e-3 m` for 100 deterministic sampled tiles; the tile role at each sample
   matches `game.terrain`/`game.tileblock`.
2. `camera.projection == Projection.PROJECTION_ORTHOGONAL`; pitch
   `32.0° ± 0.5°`; yaw equals the `R-ARCH` value `±1°` (45° placeholder);
   camera clamped to the map bounds within one tile.
3. 1280×720 capture is non-blank: Pillow luminance standard deviation ≥ 10
   over the full frame; the shoreline crossing and the deepest ravine land in
   the same screen quadrant as the matching 2D capture for the same seed/focus,
   with tile-index difference ≤ 2.
4. Sim invariants: `--dump-map` JSON byte-identical to the 2D path for the same
   seed; self-test `29/29` and UI-test `17/17` PASS; a 2D screenshot's pixel
   hash is unchanged.
5. Performance: ≤16.7 ms mean frame time over 120 frames at 1280×720 terrain
   only, ≤100 draw calls, and no chunk holes after load.

**M2 — static entities.** Re-converted `.glb` meshes for units/buildings/trees,
static (no animation), plus the picking and minimap adapters. Criteria: a
1,000-unit static scene ≤33 ms/frame with <200 draw calls after MultiMesh
batching; ≥95% agreement with 2D on 50 scripted click→selection cases.

**M3 — animation, FX, fog.** Criteria: walk-cycle frame timing within one
frame of the baked 2D index; fog visibility matches `world.tile_visible` at 100
sampled tiles; all `game.events` types in `main._consume_events` have a visible
or explicitly-suppressed 3D representation.

**M4 — mass army + parity.** Benchmark with the existing `t_mass_army` scenario
on a named machine; publish draw calls, frame time, memory. 3D remains opt-in
until this gate passes; 2D stays the default.

### 4.4 Compatibility guard

`render_mode="2d"` is the default and must remain pixel-identical. Headless,
CLI and dump paths never instantiate 3D nodes. A failed/unavailable 3D import
must fall back to 2D with a printed warning rather than a black screen.

---

## 5. Risks and honest constraints

- **Compatibility renderer** (`project.godot:25-26`): Godot 4's `gl_compatibility`
  has no SDFGI/VoxelGI/SSAO/SSR/volumetric fog or compute-based effects and
  offers only limited real-time shadows (finite atlas, simpler filtering) and a
  mobile-oriented feature budget. A 3D mode will look flatter than the donor
  stills unless lighting is baked into materials/vertex colours. This is
  toolchain knowledge, **not verified by a Godot run** (out of scope).
- **No 3D precedent in the repo**: zero functional 3D-node references in any
  `.gd` file; `world.gd` is ~2,936 lines of CanvasItem baking/drawing. M1 is a
  new subsystem, not an edit to existing draw code.
- **Mass-army draw calls**: one `MeshInstance3D` per entity scales badly; the
  sim supports squads up to 403 units and a bench mode with 300+ units per side
  (`main.gd:178-182`). Batching by sid/facing with `MultiMesh` is mandatory; the
  budget must be *measured*, not assumed.
- **Donor mesh inventory**: the owner-supplied figure of **3,897 donor meshes**
  cannot be verified from this repository — only **116** converted models are
  present in `assets/models/{obj,tex}`. Shipping thousands of 3D meshes would be
  a memory/disk problem; curate to the used sids and atlas the textures.
- **`.obj` conversion quality** (all `OBSERVED`): `convert_models.py:109-126`
  writes `v`, `vt`, `f` only — **no normals**, **no skinning/animation**, and
  only a single rest frame even though the OSS reader parses bone weights and
  frames (:51-61). Unit/building textures are forced opaque via
  `img.convert("RGB")` (:143-147), so alpha cut-outs are gone. Coordinates are
  donor Z-up (peasant bbox z 0.007..1.995 in `manifest.json`) and need a Y-up
  swap. **Re-conversion needed:** preserve alpha where the donor uses it,
  export normals/tangents, Y-up + scale normalisation, full texture resolution,
  and glTF (`.glb`) with explicit materials; add skeleton clips or per-frame
  meshes for the 8 unit directions if animation is required in 3D.
- **"Baked at 512px"**: the `.obj` files are geometry and carry no pixel
  resolution. The 512 px figure corresponds to the `sprites_hi` CPU-Cycles
  rebake (`world.gd:331-335`); the default sprite render is 256 px
  (`render_models.py:47`) and animation cells default to 160 px
  (`bake_sprites.py:50`). A 3D mode samples the .dds→.png textures directly, so
  effective texture resolution is whatever conversion preserved — **not
  re-measured here**. Owner's phrasing is recorded as an open question.
- **Terrain look**: the 2D bake does per-cell donor-block compositing, face
  collars, season tint and relief shading (`world.gd:1387-1525`). A naive
  one-material-per-tile 3D mesh will not match the donor stills; an atlas with
  per-tile UVs plus vertex-colour relief is likely needed and will require its
  own tuning loop.
- **Camera yaw**: elevation 32° is corroborated by `data.gd:161` and
  `render_models.py:50`; yaw 45° is an **inference** from
  `docs/UNIT_BAKING_FIX.md:114,141` (8 azimuths at 45°) and the sprite naming
  (`:422`), not a donor camera read. `R-ARCH_*` must settle it.
- **Fidelity of 2D→3D comparison**: donor stills are arbitrary screenshots, not
  aligned to a generated seed. M1 acceptance uses structural checks (shoreline,
  ravine, palette), not pixel-exact matching; claiming an exact donor match is
  **not** supported.
- **Test coverage**: headless captures use a CPU map render (`main.gd:1208-1218`)
  and would never exercise a 3D scene. A dedicated windowed capture/benchmark
  gate is required before any 3D claim is accepted.

---

## 6. Claim table

| # | Claim | Status | Evidence |
|---|---|---|---|
| C1 | Rendering currently diverges from the sim at `world.bind`, camera bind, input bind in `main.gd` | OBSERVED | `app/scripts/main.gd:400-430`, `:553-594` |
| C2 | The 2D world is a `Node2D` compositor of Sprite2D chunks + CanvasItem draw layers | OBSERVED | `app/scripts/world.gd:9`, `:25-26`, `:86-91`, `:1387`, `:1543` |
| C3 | Terrain height is a plain `PackedFloat32Array` indexed `y*MAP_W+x`, so it can drive mesh vertices | OBSERVED | `app/scripts/game.gd:29`, `:20-21`, `:1609`; `main.gd:634-637` |
| C4 | Tile→art mapping already exists (`tileblock` index → `tbl_names` block name) | OBSERVED | `app/scripts/world.gd:1005-1013`; `game.gd:38`, `:43` |
| C5 | Picking is CPU geometry, not physics/raycast | OBSERVED | `app/scripts/input_controller.gd:226-256`, `:453-466`; no physics node in world |
| C6 | HUD minimap viewport box depends on `get_camera_2d()` and will be wrong in 3D without an adapter | OBSERVED + INFERRED | `app/scripts/hud.gd:1072-1083` |
| C7 | Static types `C3World`/`C3Camera` block a drop-in 3D class | OBSERVED | `main.gd:44-46`; `hud.gd:9`; `input_controller.gd:10-12` |
| C8 | Sim/generator/AI/save/load carry no 3D dependency | OBSERVED | `game.gd` (no Canvas/Node2D types in its API); `game.gd:4744-4781` (`serialize`/`deserialize`); `main.gd:508-538` |
| C9 | Renderer is `gl_compatibility` with canvas-item stretch | OBSERVED | `app/project.godot:9`, `:18`, `:25-26` |
| C10 | No functional 3D code exists in the project today | OBSERVED | repo-wide grep of `*.gd` for 3D node/mesh symbols: 0 functional hits |
| C11 | Converted OBJs have no normals and no animation; unit/building alpha is forced off | OBSERVED | `app/tools/convert_models.py:51-61`, `:109-126`, `:135-153` |
| C12 | Only 116 models are converted in-repo | OBSERVED | `app/assets/models/obj/*.obj` count = 116; `manifest.json` |
| C13 | "3,897 donor meshes" is an owner-supplied figure, not verified here | UNVERIFIED | task context; no matching in-repo inventory found |
| C14 | Working camera elevation proxy is 32°; 45° yaw is a proxy, not a donor camera read | OBSERVED (32°) / INFERRED (45°) | `data.gd:161`; `render_models.py:50`, `:417`; `UNIT_BAKING_FIX.md:114,141` |
| C15 | Sprite imagery is baked at 256 px default with a 512 px `sprites_hi` variant; 160 px animation cells | OBSERVED | `render_models.py:47`; `world.gd:331-335`; `bake_sprites.py:50` |
| C16 | Compatibility renderer lacks SDFGI/VoxelGI/SSAO/SSR/volumetric fog | UNVERIFIED (toolchain knowledge, no Godot run) | `project.godot:25` + Godot 4 renderer feature set |
| C17 | M1 terrain-only sample is feasible without touching the sim | INFERRED | C3/C4/C8 + new-file-only target list (§2) |
| C18 | Full 3D parity (mass armies, animation, fog) is high risk, not a near-term guarantee | INFERRED | §5 draw-call, animation and texture constraints |

---

## 7. Open questions

1. What yaw and exact elevation does the donor orthographic camera use? Does
   `R-ARCH_*` find a camera.cfg section beyond `CAMERA_PITCH=-32.0` and
   `SphereHeight 20/58` already in `data.gd:161-163`?
2. Is the donor terrain a real height mesh with per-tile materials, or a set of
   prerendered high-angle tiles? This decides whether M1 needs geometry at all.
3. At what world scale should `game.height` values map to 3D Y (`HEIGHT_SCALE`),
   and how should water at `WATER_LEVEL=-0.25` interact with the heightfield?
4. Is screen-space picking (what the donor likely does for an oblique view)
   preferable to ground-plane ray intersection? Both change `_pick` semantics.
5. Can the 116 converted models be re-baked with alpha and normals, and at what
   texture resolution? Is the owner's "512px" constraint about `sprites_hi` or
   about the `.dds→.png` conversion itself?
6. How should unit animation work in 3D — donor skeleton from `.oss` (which our
   reader already parses but discards), or per-frame meshes per direction?
7. Can a `MultiMesh`-based entity renderer meet mass-army frame budgets under
   `gl_compatibility`, and on which benchmark machine?
8. Does `render_mode` belong in the skirmish screen only, or also in a persistent
   config/Options menu (the in-game Options UI is `main.gd:900-962`)?
9. Should the minimap viewport box be a projected ground quad or an axis-aligned
   approximation under yaw, and does the donor minimap rotate with the camera?
10. Which donor stills are the acceptance anchors for M1 terrain comparison, and
    who signs off on the qualitative palette/shape criteria?

---

**End of study.**
