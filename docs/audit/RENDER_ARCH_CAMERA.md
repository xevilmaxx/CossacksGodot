# Donor camera / projection audit → port implications

**Agent:** R-ARCH-CAM (read-only research). **Date:** 2026-11-21.
**Scope:** determine the Cossacks 3 donor camera/projection from configuration only
(no binary disassembly, no running the donor, no donor assets copied). All donor paths
are under read-only `C:\Games\Cossacks 3`; all port paths are relative to the repo root.

---

## 1. Sources

Donor files actually opened (all text; read via shell/Pillow-style text reads):

| Source | What it is |
|---|---|
| `data\cameras\camera.cfg` | Main in-game (RTS) camera profile — focal length, orbit sphere, tilt, DOF/fog |
| `data\cameras\cameradebug.cfg` | Debug/free camera profile (`bDbgCamera`) |
| `data\cameras\camerascreenshot.cfg` | Screenshot/cinematic camera profile (`gbool_gui_screenshotcamera`) |
| `data\cameras\default.cameras` | Named camera bookmarks (`Camera0`, `@Camera0`, `@CameraDebug`) with explicit position/target/FoV data |
| `data\env\env.cfg`, `data\env\time.cfg` | Environment/lighting/time — loaded to check for camera/projection keys (none found) |
| `cossacks.ini` | Root config — saves/log/show-intro only (no camera keys) |
| `data\gui\menu.inc\docreate.inc` | Runtime camera construction: which .cfg is loaded, control mode, depth-of-view, bounds |
| `data\gui\menu.inc\onresize.inc` | Resolution/mode branch: height/focal/angle selected per aspect mode; scene scale |
| `data\gui\common.inc\onmousewheel.inc` | Zoom/focal-length logic, FOV variable, camera info save/load |
| `data\scripts\lib\control.script` (lines ~577–664) | Camera restrict-info helpers (SphereLength ↔ height clamping) |
| `data\scripts\dmscript.global` (line 1230) | `gc_gui_camera_maxheight = 58` |
| `data\scripts\progress\progress.inc\soundcontrolcounters.inc` (line 52) | "3D sound / isometric sound" comment |
| `data\game\var\*.cfg` (battles, campaigns, envscales, formations, generator, hotkeys, objcustom, random, startingsettings, units, wallcustom) | Grepped for camera/projection overrides — **no camera/projection keys found** |

Port files opened:

`app/scripts/camera.gd`, `app/scripts/config.gd`, `app/scripts/data.gd`, `app/project.godot`,
plus grep sweeps over `app/scripts/*.gd` and `app/**/*.tscn` for `Camera2D`, `Camera3D`,
`ortho`, `perspect`, `Sprite2D`, `Node3D`, `view_scale`, `get_camera_2d`.

---

## 2. Parameter table (donor, exact key = value with file:line)

### 2.1 Main game camera — `data\cameras\camera.cfg`

| Key | Value | file:line | Meaning |
|---|---|---|---|
| `HeightTarget` | `1` | :3 | target height above terrain |
| `HeightTargetMin` | `5` | :4 | min target height |
| `SphereHeight` | `58` | :6 | orbit sphere vertical radius (max height / zoom-out) |
| `SphereHeightMin` | `20` | :7 | orbit sphere min vertical radius (min height / zoom-in) |
| `SphereLength` | `58` | :9 | orbit sphere horizontal radius |
| `SphereLengthMin` | `20` | :10 | min horizontal radius |
| `FreeRotationMode` | `True` | :30 | free-rotation enabled |
| `MinHeightMinAngle` / `MinHeightMaxAngle` | `-32` / `-32` | :32–33 | tilt at min height |
| `MaxHeightMinAngle` / `MaxHeightMaxAngle` | `-32` / `-32` | :34–35 | tilt at max height |
| `AngleLerpPower` | `1` | :36 | tilt interpolation |
| `Bounded` | `True` | :42 | pan bounded to map |
| `DistToGroups` | `15` | :43 | elastic distance to unit groups |
| `MinFocalLength` | `400` | :44 | **focal length (perspective)** |
| `MaxFocalLength` | `400` | :45 | focal length fixed (no zoom-by-FoV in normal mode) |
| `FocalLengthPower` | `1.0` | :46 | focal interpolation |
| `PowerDOF` | `0.5` | :51 | depth-of-field power |
| `MinLengthDOF` / `MaxLengthDOF` | `128.0` / `128.0` | :52–53 | DOF length (fixed ⇒ effectively disabled) |
| `MinNearDOF`/`MaxNearDOF`/`MinFarDOF`/`MaxFarDOF` | `256.0` (all) | :54–57 | DOF near/far (fixed ⇒ effectively disabled) |
| `DynFogDepth` | `False` | :59 | dynamic depth fog off in game mode |

Elastic/raycast timing keys (`MoveVelocity 0.125`, `RotationVelocity 0.05`,
`StepTime*`, etc., :13–28) are motion-smoothing constants, not projection parameters.

### 2.2 Alternate camera profiles

| Profile | Key = value | file:line |
|---|---|---|
| Debug | `SphereHeight=19`, `SphereHeightMin=5`, `SphereLength=19`, `SphereLengthMin=5` | `cameradebug.cfg`:5–8 |
| Debug | `MinHeight*Angle=-30/-30`, `MaxHeight*Angle=-48/-48` (tilt range −30°…−48°) | `cameradebug.cfg`:30–33 |
| Debug | `MinFocalLength=86`, `MaxFocalLength=100` | `cameradebug.cfg`:42–43 |
| Screenshot | `SphereHeight=13`, `SphereHeightMin=0.75`, `SphereLength=13`, `SphereLengthMin=0.6` | `camerascreenshot.cfg`:6–10 |
| Screenshot | tilt `-90 … 20` (full free tilt) | `camerascreenshot.cfg`:32–35 |
| Screenshot | `Bounded=False`, `MinFocalLength=95`, `MaxFocalLength=95`, `FocalLengthPower=0.5` | `camerascreenshot.cfg`:42,46–48 |
| Screenshot | `DynFogDepth=True` | `camerascreenshot.cfg`:61 |

### 2.3 Named bookmarks — `data\cameras\default.cameras`

`Camera0` and `@Camera0` (identical): `TargetX=0, TargetY=49, TargetZ=78.42125`
(:5–7); `PosX=0, PosY≈0.05299, PosZ≈0.08481` (:8–10); `DirZ=-1`, `UpY=1`
(:13,:15); **`FocalLength=400`** (:17); **`DepthOfView=1200`** (:18);
`MoveSpeedToMark=1`, `TurnSpeedToMark=0.1` (:19–20).
`@CameraDebug`: `TargetY=19, TargetZ=18`, **`FocalLength=100`**, **`DepthOfView=50`**
(:64–78). `SmoothingChange=False`, `SmoothingTime=3000` (:94–95).

### 2.4 Runtime setup (scripts)

| Parameter / call | Value | file:line |
|---|---|---|
| `cCamFilename` | `.\data\cameras\camera.cfg` | `docreate.inc`:59 |
| `SetCameraPropertiesFromFile(cCamFilename)` | loads main profile when not debug/screenshot | `docreate.inc`:60–61 |
| `SetCameraDepthOfView(1200)` | DOV 1200 | `docreate.inc`:86 |
| `SetCameraControlMode('ccmRTS')` | **RTS control mode** | `docreate.inc`:91 |
| `SetCameraBounded(False)` | runtime overrides cfg `Bounded=True` | `docreate.inc`:93 |
| `SetCameraDynamicFocalLength(gProfile.bDbgCamera)` | normal play = fixed focal length | `docreate.inc`:94 |
| debug `cMaxCameraHeight` | `500`, tilt ±90° | `docreate.inc`:108,116–119 |
| screenshot `cMaxCameraHeight`/`cMinCameraHeight` | `140` / `20` | `docreate.inc`:308–309 |
| screenshot cam | loads `camerascreenshot.cfg`, wheel rotate/distance on, speed 2 | `docreate.inc`:301–306 |
| per-aspect mode 0..4 + else | `height = gc_gui_camera_maxheight (58)`, `focal = 400`, `angle = -32` | `onresize.inc`:77–110 |
| `SetCameraSceneScale((viewheight/2400)*4, …)` | mode < 5 | `onresize.inc`:112 |
| `SetCameraSceneScale((viewwidth/3840)*2.5, …)` | mode ≥ 5 | `onresize.inc`:114 |
| `SetCameraFocalLengthInfo(focalmin, focalmax, focalfactor)` | `focal=400` forced after resize | `onresize.inc`:116–125 |
| `SetCameraFreeRotationInfo(...)` | all four angle slots set to `-32` | `onresize.inc`:119–126 |
| `gfloat_gui_screenshotcamerafov` → `focal := 400 + fov*5` | FOV is *expressed as focal length* | `onmousewheel.inc`:322–336 |
| `gc_gui_camera_maxheight` | `58` | `dmscript.global`:1230 |
| comment | `//80 - for 3D sound, 8000 for isometric sound` | `soundcontrolcounters.inc`:52 |

**Viewport:** `data\env\env.cfg` contains no camera/projection keys; `cossacks.ini`
contains only save path, logging and `HideHelloScreen`. No `ortho`,
`perspective`, `projection`, `field of view` key exists anywhere in
`data\**\*.cfg|*.cameras|*.ini|*.inc|*.lib` (grep of full tree).

**Per-campaign / per-battle overrides:** none found. `campaigns.cfg`, `battles.cfg`,
`startingsettings.cfg`, `generator.cfg`, `envscales.cfg`, `units.cfg`,
`wallcustom.cfg`, `formations.cfg`, `hotkeys.cfg`, `objcustom.cfg`, `random.cfg`
were grepped for `camera|focal|sphereheight|pitch|viewscale|ortho` — zero hits.
Camera configuration is global (one RTS profile) plus the three profile files and
the debug/screenshot switches; campaign scripts only call the generic
`SetCameraElasticDistance`/camera-info helpers (`menu.inc\donewgame.inc`:51,
`menu.inc\eventcampaign.inc`:86).

---

## 3. Projection determination: perspective, not orthographic

**Verdict: the donor uses a true perspective 3D camera.** Evidence:

1. **Focal length is the projection primitive.** The camera is parameterised by
   `MinFocalLength = MaxFocalLength = 400` (`camera.cfg`:44–45),
   `FocalLength = 400` (`default.cameras`:17), and the engine calls
   `SetCameraFocalLengthInfo` / `GetCameraFocalLengthInfo` / `SetCameraDynamicFocalLength`
   (`onresize.inc`:125, `onmousewheel.inc`:322–336, `docreate.inc`:94). Orthographic
   cameras have no focal length — they have an ortho width/height. No ortho extent
   key exists anywhere in the donor data.
2. **FOV is explicitly derived from focal length.** The screenshot-zoom variable is
   literally named `gfloat_gui_screenshotcamerafov` and changes `focal` by `+/-5`
   per notch (`onmousewheel.inc`:325–336). This is perspective FOV manipulation.
3. **Depth-of-field, depth fog and near/far plane keys** (`PowerDOF`, `*DOF`,
   `DynFog*`, `DepthOfView=1200`) are perspective-3D effects (`camera.cfg`:51–64,
   `default.cameras`:18, `docreate.inc`:86).
4. **3D ray casting against the ground plane** (`ScreenToWorldRayCast`,
   `onresize.inc`:66–69, `onmousewheel.inc`:315) and world-space camera position/
   direction vectors (`default.cameras`:5–16, `DirZ=-1`, `UpY=1`) describe a 3D
   view frustum, not a 2D canvas transform.
5. **Zoom = dolly along an orbital sphere**, not scale. `SphereHeight/Length`
   clamp 20…58 (`camera.cfg`:6–10), consumed as camera height limits
   (`control.script`:584–585, `onmousewheel.inc`:23–24). A fixed focal length with
   changing camera→target distance produces real perspective foreshortening (near
   objects grow faster than far ones).

**Why it *looks* isometric:** the tilt is pinned to a single value, `-32°`
(`camera.cfg`:32–35, `onresize.inc`:82,102,108,119–122), and focal length is pinned
to `400` in normal play (`docreate.inc`:94). A fixed oblique angle plus a fixed,
long focal length (narrow FOV) yields an axonometric/near-isometric *appearance*
with minimal distortion — and the audio code even calls it "isometric sound"
(`soundcontrolcounters.inc`:52). But "isometric" here is a genre/appearance label,
**not** an orthographic projection. Constant on-screen scale is not guaranteed by
the config; scale varies with distance to target.

**Numeric FOV note:** no explicit FOV or sensor-width value is present in the donor
config, so FOV cannot be computed exactly from configuration alone. If (UNVERIFIED
assumption) the engine uses a 36 mm-equivalent sensor, `f=400` would imply a narrow
FOV of ≈ `2·atan(36/(2·400)) ≈ 5.2°`; the engine may use a different sensor
constant. Treat the absolute FOV value as **UNVERIFIED**; the *fact* that projection
is focal-length-driven (hence perspective) is **observed**.

---

## 4. Claim table

| # | Claim | Evidence (file:line) | Status |
|---|---|---|---|
| 1 | Main game camera is perspective, parameterised by focal length 400 | `camera.cfg`:44–45; `default.cameras`:17; `docreate.inc`:94; `onresize.inc`:116–125 | observed |
| 2 | Camera tilt fixed at −32° in normal play | `camera.cfg`:32–35; `onresize.inc`:82,102,108,119–122 | observed |
| 3 | Zoom/dolly range is height 20…58 (sphere radius), not a scale factor | `camera.cfg`:6–10; `dmscript.global`:1230; `control.script`:584–585 | observed |
| 4 | Debug profile: height 5…19, focal 86…100, tilt −30°…−48° | `cameradebug.cfg`:5–8,30–33,42–43 | observed |
| 5 | Screenshot profile: height 0.6…13, focal 95, tilt −90°…20°, unbounded, depth fog on | `camerascreenshot.cfg`:6–10,32–35,42,46–48,61 | observed |
| 6 | Runtime control mode is RTS (`ccmRTS`) | `docreate.inc`:91 | observed |
| 7 | Depth of view = 1200; DOF keys fixed ⇒ effectively disabled | `default.cameras`:18; `docreate.inc`:86; `camera.cfg`:51–57 | observed + inferred (disabled) |
| 8 | Viewport scale is resolution-dependent (`viewheight/2400*4` or `viewwidth/3840*2.5`) | `onresize.inc`:112–114 | observed |
| 9 | No explicit FOV/ortho-width/sensor constant in donor config; exact FOV unknown | full-tree grep of `data\**` (no hits) | observed (absence) |
| 10 | Project looks isometric but is perspective (fixed tilt + long focal length) | combination of #1,#2 | inferred |
| 11 | "Isometric sound" comment corroborates genre label, not projection | `soundcontrolcounters.inc`:52 | observed (text only) |
| 12 | No per-campaign/per-battle camera overrides | grep of `data\game\var\*.cfg` (zero camera hits) | observed (absence) |
| 13 | Absolute FOV ≈ 5.2° assuming 36 mm sensor | derived with assumed sensor | UNVERIFIED |
| 14 | Port camera is `Camera2D` (2D-only), zoom = uniform scale | `camera.gd`:2,15–18,34,77–87 | observed |
| 15 | Port stores pitch −32° but never applies it (no 3D rotation; tilt baked into sprite art) | `config.gd`:35,369; `data.gd`:161; grep: no `Camera3D`/`CAMERA_PITCH` use outside config | observed + inferred |
| 16 | Port renders the world entirely as 2D sprites on CanvasLayers | `world.gd`:16–17,176; `hud.gd`:2; `main.gd`:35; `get_camera_2d()` in `hud.gd`/`audio.gd` | observed |
| 17 | Port's `ortho` values are sprite world-footprint sizes, not projection | `game.gd`:1204,1252; `world.gd`:501,588 | observed |

---

## 5. Verdict — what a faithful port would need

A faithful camera would use a **Godot 4 `Camera3D` with a perspective projection**:
fixed tilt ≈ **−32°**, fixed focal length ≈ **400** (translate to a narrow `fov`,
or keep as a verifiable constant once the donor sensor/FoV conversion is pinned
down), dolly distance clamped to the donor **20…58** height range, `depth = 1200`,
and RTS edge-scroll/zoom-at-cursor behaviour. Resolution-dependent scene scale
(`onresize.inc`:112–114) maps to a `Camera3D` viewport/scale adjustment. The debug
and screenshot profiles are separate presets (focal 86…100 / 95, tilt ranges
−30…−48 / −90…20).

The current port is **2D-only**: `camera.gd` extends `Camera2D`; its "zoom" is a
uniform `Vector2` scale and its "height limits" are only used to derive zoom
bounds (`camera.gd`:28–34); there is no `Camera3D`, no `Node3D`/`Sprite3D`/mesh
scene, and the −32° pitch is dead config. The entire world is pre-rendered 2D
sprites (`Sprite2D` + `CanvasLayer`) at `PIXELS_PER_METER = 16`, `TILE_M = 2.0`,
`view_scale = 16` (`data.gd`:113,23; `world.gd`:16,176). The isometric *look* is
baked into the sprite artwork, not produced by a camera transform.

---

## 6. Port implications — what would break on a Camera3D switch

- **Input picking:** `input_controller.gd` converts mouse→world with 2D transforms
  and divides by `view_scale` (`input_controller.gd`:232,329; `world.gd`:2761). These
  assume a flat 2D plane and would need real 3D ray→ground-plane intersection
  (the donor itself uses `ScreenToWorldRayCast`). Unit selection and
  edge-scroll/zoom-at-cursor (`camera.gd`:77–87) would mis-aim under perspective.
- **Minimap:** HUD camera positioning uses `cam.global_position = world_pos * view_scale`
  (`hud.gd`:1046,1055); world→canvas mapping is 2D. A perspective camera breaks the
  direct world↔minimap coordinate identity; the minimap must project through the
  3D camera frustum instead.
- **HUD:** HUD is a `CanvasLayer` (`hud.gd`:2) and reads `get_camera_2d()`
  (`hud.gd`:1042,1072). It would need rebinding to a `Camera3D` (or a dedicated
  `CanvasLayer` overlay) and the `pxm = TILE_M * view_scale` assumption
  (`hud.gd`:1075) no longer holds uniformly across the screen under perspective.
- **Sprites / art:** the whole renderer is billboard-style 2D sprites scaled by
  `view_scale` and pre-baked "ortho" footprints (`world.gd`:501–505,588;
  `game.gd`:1252–1265). They have no 3D depth/geometry, so a perspective camera
  would produce no correct foreshortening and would expose the flat cut-outs. A
  faithful 3D camera is only worthwhile if the art pipeline moves to real 3D
  meshes; otherwise the current Camera2D + baked-isometric approach is the
  pragmatic faithful *look* (though not a faithful *projection*).
- **Zoom semantics:** donor zoom changes camera distance (foreshortening); port zoom
  changes uniform scale. Switching to Camera3D would change apparent unit sizes and
  occlusion, requiring re-tuning of `view_scale`, `DEFAULT_ZOOM`, and clamp bounds.

Net: switching to `Camera3D` is a **cross-cutting rewrite** of picking, HUD/minimap,
and the sprite pipeline, not a one-line camera-node swap. Given the 2D art, the
recommended path is to keep `Camera2D` for parity of appearance and document the
projection divergence, unless a full 3D art migration is planned.

---

## 7. Open questions

1. **Exact FOV / sensor constant for `focal = 400`.** No explicit FOV or sensor width
   in config. Needs donor binary/renderer analysis (out of read-only scope) to map
   focal length → Godot `fov` numerically.
2. **Is `SetCameraDynamicFocalLength` truly off in normal play?** `docreate.inc`:94
   sets it from `gProfile.bDbgCamera`; `onresize.inc` still forces focal=400. Need to
   confirm no other script enables dynamic focal length during gameplay.
3. **Height ↔ SphereLength semantics.** `HeightTarget=1` vs `HeightTargetMin=5` and
   `SphereHeight=58` vs min 20 are read as zoom range; confirm which value the engine
   uses as the actual camera Y at each zoom extreme.
4. **`Bounded` conflict.** `camera.cfg`:42 `Bounded=True` vs `docreate.inc`:93
   `SetCameraBounded(False)` — runtime wins; confirm effective behaviour.
5. **Scene scale vs zoom interaction.** `SetCameraSceneScale` (`onresize.inc`:112–114)
   is resolution-dependent; its interaction with focal length/height at non-16:9
   aspects needs pixel-level verification against donor screenshots.
6. **Profile-scope of debug/screenshot modes.** Whether `bDbgCamera` / screenshot
   camera are reachable in shipping builds (affects whether those profiles must be
   reproduced at all).
