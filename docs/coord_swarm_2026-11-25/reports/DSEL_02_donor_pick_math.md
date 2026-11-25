---
id: DSEL-02
title: "DSEL-02 — Donor screen↔world projection, ground picking and camera math that selection depends on"
owner: DSEL-02 (micro-worker)
date: 2026-11-25
status: READ_ONLY_DONOR_RECON__3_PASSES__NO_CODE_EDIT
scope: "Exactly one report file written. No game code, shared file, config, asset, test or git edit. No Godot run."
donor: "C:\\Games\\Cossacks 3 (read-only; Python bytes/latin-1 for text, raw byte counts + context for the EXE; never executed or copied)"
labels: [observed, derived, inferred, UNVERIFIED]
passes:
  - "P1 — camera configs/bookmarks + runtime setup + wheel/tilt math"
  - "P2 — full-tree text grep (data\\** + top-level scripts\\**) for raycast/pick/selection/viewport/minimap tokens; read every hit-bearing source"
  - "P3 — EXE byte-string census + camera API declaration block; cross-check shader projection and second-source duplication"
output: docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md
---

# DSEL-02 — donor projection / ground-pick / camera math

## Goal

Establish, from the donor only, the exact math the main view uses to turn screen pixels into
ground points and entity hits — projection type, tilt/focal/dolly/yaw/target, unproject,
hit-test, drag rectangle, viewport rectangle, minimap→world — and translate each into a
concrete Godot 4 `Camera3D` equivalent for click-pick, drag-rectangle select, ground point and
minimap camera box. Every number gets `path:line`; labels are `observed`, `derived`,
`inferred`, `UNVERIFIED`. Where a prior doc is wrong, say so.

## Sources

**Orientation read (not re-trusted as evidence):**
`docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md`,
`DEEPDEC_01_camera.md`, `V711_camera3d.md`, `V790_donor_camera_changes.md`,
`FIXSEL_picking_orders.md`, `V768_picking_fix.md`, `docs/audit/RENDER_ARCH_CAMERA.md`;
plus same-wave `V3D_01_selection_rectangle_audit.md`.

**Donor text, freshly read this session (Python `open(...,'rb').read().decode('latin-1')`, numbered lines):**
- `data\cameras\camera.cfg`, `default.cameras`, `cameradebug.cfg`
- `data\gui\menu.inc\onresize.inc`, `docreate.inc`, `cameracontrol.inc`,
  `onmousedown.inc`, `onmousemove.inc`, `onselection.inc`, `initminimap.inc`, `showhud.inc`
- `data\gui\common.inc\onmousewheel.inc`
- `data\scripts\lib\control.script` (the authoritative pick + camera-offset helpers),
  `misc.script`, `unit.script`, `classes.script`, `init.script`
- `data\scripts\dmscript.global`
- `data\shaders\obj\*.vert`, `data\shaders\water\*.vert` (projection matrix spot-check)

**Donor binary, read-only byte census (`C:\Games\Cossacks 3\cossacks.exe`, Python `bytes.count` +
±140-byte printable context):** `FieldOfView` ×3, `FocalLength` ×16, `glFrustum` ×1,
`glOrtho` ×1, `gluPerspective` ×1, `gluOrtho2D` ×1, `ScreenToWorldRayCast` ×1,
`GetCurrentMouseWorldCoord` ×1, `GameObjectRayCastMouseRay` ×1,
`GetGameObjectRayCastAABBByHandle` ×1, `ArcTan` ×1, `SetMiniMapFrustumVisible` ×1,
`Sensor`/`sensor` ×0.

**Port, read-only (for the divergences section only):**
`variant3d/scripts/camera3d.gd`, `picking3d.gd`, `input_controller.gd`.

---

## Claim table

Labels: **O** = observed literal; **D** = derived arithmetic/control-flow; **I** = inferred;
**U** = UNVERIFIED. "2nd source" column records a second independent file/binary check where one exists.

| # | Claim | Label | Citation | Verification method | 2nd source | Verdict |
|---:|---|---|---|---|---|---|
| 1 | Main world view is a true perspective camera parameterised by focal length 400; no ortho extent key | O | `camera.cfg:44-45`; `default.cameras:17,47`; `onresize.inc:81,86,91,96,101,107,116-125`; `docreate.inc:59-61,94` | fresh line reads + EXE API block `0x1fde00..0x1fe400` | `onmousewheel.inc:326,334`; shaders `gl_ModelViewProjectionMatrix` (`obj\b1.id23.vert:8`, `obj\gr.pvl.sm.vert:38`) | **CONFIRMED** (projection type) |
| 2 | FOV is computed at runtime from focal length **and a viewport dimension**, not from a stored sensor constant | O (API existence) / U (formula, numeric FOV) | EXE `0x1fe0ef`: `function GetCameraFieldOfViewByFocalLength(const focallength, viewportdimension : Float) : Float`; `0x1fe168`: inverse | raw byte context dump | `Sensor`/`sensor` 0 hits; `FieldOfView` 3 hits (one GUI event name, two API signatures) | **CONFIRMED** that the API exists; numeric FOV **UNVERIFIED** — corrects "no FOV token in donor" in prior docs |
| 3 | Tilt fixed at −32° (internally `angleZ = +32°`) in normal play | O | `camera.cfg:32-35`; `onresize.inc:82,87,92,97,102,108,119-122`; `onmousewheel.inc:43-47`; `control.script:595-599` | fresh reads; wheel guard forces −32 if positive | `misc.script:6270`; `default.cameras:6-7` numeric ratio | **CONFIRMED** |
| 4 | Zoom/dolly is camera height clamped to `SphereLengthMin=20 … SphereLength=58` | O | `camera.cfg:6-10`; `onmousewheel.inc:23-24,30,39-41`; `control.script:584-585` | fresh reads | `dmscript.global:1230` (`gc_gui_camera_maxheight = 58`); `onresize.inc:80,124` | **CONFIRMED** |
| 5 | Camera back-offset ≈ `height / tan(32°)`; bookmark `(TargetY=49, TargetZ=78.42125)` | O + D | `default.cameras:6-7`; `control.script:602` (`offZ := ArcTan(angleZ)*height`); `onmousewheel.inc:56,60` | `78.42125/49 = 1.60043` vs `cot(32°)=1.60033` (0.006% apart) | `misc.script:6279,6283` (identical formula, 2nd file) | **CONFIRMED numerically**; `ArcTan` VM semantics **UNVERIFIED** |
| 6 | Yaw: `DirZ=-1, UpY=1`, no absolute yaw key | O | `default.cameras:11-15,41-45,71-75` | fresh reads | `cameracontrol.inc:27-35` pan tags only; `oncamera.inc:60-63` (prior read) gives absolute *directions*, not yaw | **CONFIRMED** (data); effective yaw 0 is **inferred** |
| 7 | Ground point under cursor = engine heightfield ray hit (`GetCurrentMouseWorldCoord` / `ScreenToWorldRayCast`) | O (API use) / U (native ray math) | `control.script:170,184,288,300`; `onmousedown.inc:157,407`; `onmousemove.inc:69,135`; `onresize.inc:66-69`; `showhud.inc:95-96`; `init.script:101` (`SetTerrainRayCastPrecison(0.0000001)`) | full-tree grep (46 files, 144 hits) + fresh reads | EXE: each API name exactly 1 hit (script-VM signature) | **CONFIRMED** at call sites; native ray implementation **UNVERIFIED** |
| 8 | Click hit-test is a ray→AABB test from camera position to cursor ground point, not a screen-space radius | O | `control.script:164-165,170-184` (`GameObjectRayCastMouseRay`, `GameObjectSortRayCastList`, `GetGameObjectRayCastAABBByHandle(goHnd, cPos.x,cPos.y,cPos.z, mPos.x,mPos.y,mPos.z)`) | fresh read | duplicate in `control.script:285-303`; `onshortcut.inc:1251-1252,1286` (prior grep) | **CONFIRMED** script-side; engine AABB internals **UNVERIFIED** |
| 9 | Pick winner = min `(1+dist)/prio`; priority constants my=1 … enemy=7 | O + D | `control.script:188,258-266`; `dmscript.global:227-233` | fresh reads | `misc.script:663-669` (distance helper) | **CONFIRMED** |
| 10 | `_misc_GetDistancePos(..., false)` computes distance on fields `.x` and `.y` (not `.z`) | O | `misc.script:663-669` (`VectorDistance(pos1.x,0,pos1.y, pos2.x,0,pos2.y)`); `classes.script:14-16` (`TPos3f = x,y,z`) | fresh reads | `unit.script:6457` fills x,y,z from engine; `unit.script:6464-6465` uses `.y` as second horizontal for `TPos2f` | **CONFIRMED as code**; whether `.y` is height or depth for this API is **UNVERIFIED** (donor quirk) |
| 11 | Drag rectangle is defined in **world ground coordinates**, by `GameManagerBeginSelection` + `GameManagerStartSelection('spmAdd' / 'spmRunTime')` | O | `onmousemove.inc:66-69,135-167`; `onmousedown.inc:365,377-380`; `onselection.inc:34-43`; `docreate.inc:99-100` | fresh reads | `control.script:28-32,108-112,426-427` uses same engine selection API | **CONFIRMED** script-side; engine rect test **UNVERIFIED** |
| 12 | Viewport rectangle = 4 screen-corner ground rays; `mw=((wx3-wx2)+(wx1-wx0))/2`, `mh=wz0-wz2`, `area=mw*mh` | O | `onresize.inc:62-72` | fresh read | EXE API `GetCameraFrustumQuadrangle(...12 floats)` @`0x1fdf..`; used at `classes.script:6030-6040` | **CONFIRMED** |
| 13 | Metres-per-pixel at a screen row from two ground rays: `scale = perspwidth / GetViewerWidth` | O + D | `showhud.inc:90-111` | fresh read | `onresize.inc:70-72` (same two-edge averaging idea) | **CONFIRMED** |
| 14 | Resolution-dependent scene scale `viewheight/2400*4` (<5) or `viewwidth/3840*2.5` (≥5) | O | `onresize.inc:111-114` | fresh read | EXE `GetCameraSceneScale`/`SetCameraSceneScale` in API block | **CONFIRMED** |
| 15 | Minimap is 240×240 at (width−240+−8, −8), zoom 1, engine-drawn frustum box | O | `initminimap.inc:5-7,29-39` | fresh read | `gui.script:592-595` (minimap rect margins) | **CONFIRMED** |
| 16 | Minimap click = `_control_GetMoveCameraToPositionOffset(x,y,newx,newy)` then `SetMainCameraMoveToTargetXZ` | O | `onmousedown.inc:116-131`; helper body `control.script:572-613` (reads `camera.cfg` directly at `:581`) | fresh reads | `eventminimap.inc:8-35` (prior read) routes tags 10/20/30 | **CONFIRMED** — **corrects DEEPDEC-01 §7 / E26**, which said the helper body was absent |
| 17 | Older minimap-camera formula constants: 28.565 / 78.42125 / 1.6897 / `(ty-20)/(49+tarY)` | O | `onmousewheel.inc:82-107` | fresh read | `control.script:602` same 78.42125 back-offset | **CONFIRMED as commented/legacy code**; live status **UNVERIFIED** |
| 18 | World↔grid index mapping: `i = Floor(2*x)+GetMapWidth`; inverse `x=(i-GetMapWidth)/2` | O | `misc.script:2013-2027`; `onmousedown.inc:99-100` | fresh reads | `dogenerate.inc:373`, `misc.script:1946` (+half-map) | **CONFIRMED** |
| 19 | World coordinates are centred on map origin (half-map offsets) | O + D | `dogenerate.inc:402-404` (`x0=-(GetMapWidth div 2)`); `env\env.inc\initial.inc:108`; `misc.script:2017,2025` | fresh grep | `default.cameras:5-7` target (0,49,78.4) near origin | **CONFIRMED** |
| 20 | Main view is focal-driven perspective, *not* orthographic; `glOrtho`/`gluOrtho2D` imports exist but no data key selects them | O + I | EXE imports @`0x4ffbc6`,`0x4ff8b8`; `camera.cfg:44-45`; prior 1,710-file scan 0 projection keywords | byte census + prior scan | shaders all use `gl_ModelViewProjectionMatrix` | **CONFIRMED** (no ortho key); debug/HUD ortho use **UNVERIFIED** |

---

## Camera / pick parameter table (donor values)

| Parameter | Donor literal | `path:line` | Independent corroboration | Label |
|---|---|---|---|---|
| Projection | perspective (focal 400, no ortho extent) | `camera.cfg:44-45`; `default.cameras:17` | `onresize.inc:116-125`; EXE FOV API | O |
| Min/Max focal | `400` / `400` | `camera.cfg:44-45` | `default.cameras:17,47`; `onresize.inc:81-107,116` | O |
| Focal step (screenshot/CTRL only) | `focal = 400 + fov*5` | `onmousewheel.inc:320-337` | `docreate.inc:324`; `onshortcut.inc:1077-1084` | O |
| Tilt (all 4 slots) | `-32` | `camera.cfg:32-35` | `onresize.inc:119-122`; `onmousewheel.inc:43-47` | O |
| Internal tilt | `angleZ = -Lerp(-32,-32,t) = +32°` | `onmousewheel.inc:47`; `control.script:595` | `misc.script:6270` | D |
| Height clamp | `SphereLengthMin=20`, `SphereLength=58` | `camera.cfg:9-10` | `control.script:584-585`; `dmscript.global:1230` | O |
| SphereHeight pair | `58` / `20` (same values) | `camera.cfg:6-7` | `onresize.inc:80,124` | O |
| Bookmark geometry | `TargetY=49`, `TargetZ=78.42125`, `DirZ=-1`, `UpY=1`, `DOV=1200` | `default.cameras:5-18` | `@Camera0` duplicate `:34-49` | O |
| Back offset | `offZ = ArcTan(angleZ)*height` ≈ `1.6004*height` | `control.script:602` | `onmousewheel.inc:60`; `default.cameras:6-7` | O+D, semantics U |
| Target focus | `(TargetX,TargetY,TargetZ)`; camera absolute pos from `GetCameraAbsolutePosition` | `default.cameras:5-10`; `control.script:172` | `onshortcut.inc:1286-1287` | O |
| Yaw | no key; `DirZ=-1` ⇒ look toward −Z | `default.cameras:11-15` | `oncamera.inc:60-63` (absolute directions) | O/I |
| DOF / fog | `PowerDOF=0.5`, DOF keys fixed 128/256, `DynFogDepth=False` | `camera.cfg:51-64` | `default.cameras:18`; `docreate.inc:86` | O |
| Raycast precision | `SetTerrainRayCastPrecison(0.0000001)` | `init.script:101` | `StepTimeTargetRaycast=0.05` `camera.cfg:25` | O |
| Edge bands | `cMargin=8`, `cCornerMargin=24`, tags 20–27 | `cameracontrol.inc:15-35` | `oncamera.inc:37-58` (prior read) | O |
| Pan speeds | `keyscrollspeed*4`, `mousescrollspeed*4` (default 0.5 → 2.0) | `oncamera.inc:10-11` (prior read); V790 `:39-41` | `profile.script:17-20,513-516` | O |
| Middle drag | `Δx/60`, `Δy/45`, `*(0.5+middlemousescrollspeed)` | `dombtncameracontrol.inc:23-24` (prior read) | V790 `:42` | O |
| Cursor priorities | my 1, wood 2, food 3, stone 4, goinside 5, build 6, enemy 7 | `dmscript.global:227-233` | `control.script:208-252` | O |
| Pick ranking | `relativeDst=(1+dist)/prio`, smallest wins | `control.script:258-266` | `control.script:176-266` duplicate path | O+D |
| Selection modes | `spmRunTime` (replace), `spmAdd` (shift), `spmRemove` (commented out) | `onmousemove.inc:154-162`; `onselection.inc:34` | `control.script:28-32,426-427` | O |
| Minimap size/zoom/frustum | 240×240, zoom 1, `SetMiniMapFrustumVisible(true)` | `initminimap.inc:5-7,29-39` | `gui.script:592-595` | O |
| Debug profile | height 5–19, focal 86–100, tilt −30/−48 | `cameradebug.cfg:5-8,30-33,42-43` | `docreate.inc:69-70` | O |
| Resolution scene scale | `viewheight/2400*4` or `viewwidth/3840*2.5` | `onresize.inc:111-114` | EXE `Get/SetCameraSceneScale` | O |

---

## Exact formulas (verbatim donor → pseudocode)

### A. Screen pixel → ground point (unproject)

Donor never implements the ray in text; it calls engine APIs.

```
# onresize.inc:66-69 — four viewport-corner unprojects
ScreenToWorldRayCast(0,          viewheight, wx0, wy0, wz0)
ScreenToWorldRayCast(viewheight, viewheight, wx1, wy1, wz1)   # literal donor: X=viewheight
ScreenToWorldRayCast(0,          0,          wx2, wy2, wz2)
ScreenToWorldRayCast(viewwidth,  0,          wx3, wy3, wz3)
mw      := ((wx3-wx2) + (wx1-wx0)) / 2        # :70  mean ground width
mh      := wz0 - wz2                          # :71  ground depth
curarea := mw * mh                            # :72

# classes.script:6030-6040 — engine frustum → four ground corners
GetCameraFrustumQuadrangle(ltx,y,ltz, rtx,y,rtz, rbx,y,rbz, lbx,y,lbz)
cenx := (ltx+rtx+rbx+lbx)/4;  cenz := (ltz+rtz+rbz+lbz)/4
rad  := ((rtx-ltx)+(rbz-ltz))/4

# onmousedown.inc:157, onmousemove.inc:69 — cursor ground point
GetCurrentMouseWorldCoord(mx, my, mz)         # engine heightfield ray hit
```

### B. Zoom / camera offset (`angleZ = +32°` for shipped config)

```
# onmousewheel.inc:39-67 == misc.script:6266-6290 == control.script:591-612
oldHeight := height
height    := Clamp(height + deltaheight, SphereLengthMin, SphereLength)   # 20..58
angleZ    := -Lerp(-32, -32, Clamp((height-minHeight)/(maxHeight-minHeight),0,1))  # = +32
dx := cx - tx;  dy := ?;  dz := 0.1;  VectorRotateX(dx, dy, dz, angleZ)
angleX := VectorAngle(0,0,1, dx,0,dz)
dstX := tx;  dstZ := tz + ArcTan(-angleZ)*oldHeight;  VectorRotateY(dstX, tmp, dstZ, angleX)
offX := ?;   offZ := ArcTan(angleZ)*height;  VectorRotateY(offX, tmp, offZ, angleX)
newX := dstX + offX + dx;   newZ := dstZ + offZ + dz
# numerically ArcTan(±32)*h ≈ ±cot(32°)*h = ±1.60043*h  (49 → 78.42125)
```

### C. Click hit-test (authoritative, `control.script:154-274`)

```
if GetGUIMinimapUnderMouse: return 0                    # :161-162
GameObjectRayCastMouseRay()                              # :164  engine ray → candidate list
GameObjectSortRayCastList()                              # :165  engine distance sort
GetCurrentMouseWorldCoord(mpos)                          # :170  ground point under cursor
GetCameraAbsolutePosition(cpos)                          # :172  camera world point
for go in raycast_list:                                  # :176-269
    if not (playable and visible and collision_enabled): continue          # :181
    if not (not myPlayerOnly or go.player == me): continue                 # :183
    if not GetGameObjectRayCastAABBByHandle(go, cpos, mpos): continue      # :184  HIT TEST
    dist := _misc_GetDistancePos(mpos, go.pos, false)                      # :188
    prio := cursorprio[resource/enemy/my/build/goinside]                   # :199-255
    if prio > 0:                                                          # :258
        relativeDst := (1 + dist) / prio                                  # :260
        keep smallest relativeDst                                         # :261-265
if not FOW_LOS(winner.x, winner.z): return 0                              # :270-272
return winner
```
`dmscript.global:227-233`: my 1, wood 2, food 3, stone 4, goinside 5, build 6, enemy 7
(higher `prio` ⇒ smaller `relativeDst` ⇒ wins ties). `misc.script:668` defines the false-branch
distance on `.x,.y` (observed quirk; see claim 10).

### D. Drag-rectangle selection (`onmousemove.inc:135-167`, `onselection.inc`)

```
# on LMB move, with x,y,z = GetCurrentMouseWorldCoord(...)  (:69)
if not selection_started:
    selection_started := true; prevSelX := x; prevSelZ := z       # :142-147
else if not GameManagerIsSelectionMode and not brush and no picked bld:
    if abs(x-prevSelX)>epsilon or abs(z-prevSelZ)>epsilon:        # :152  WORLD-space threshold
        GameManagerBeginSelection()                               # :154
        if Shift: GameManagerStartSelection('spmAdd')             # :156-157
        else:     GameManagerStartSelection('spmRunTime')         # :162  replace
        ExecuteState('DoUpdateSelection')                         # :164
# LButtonUp: selection_started := false; GameManagerCancelSelection()  (:365,377-380)
# onselection.inc:34-43: read GetCountGameManagerPickedObjects /
# GetHandleGameManagerPickedObjects, filter by player, squad, building/water/guard.
```

### E. Metres↔pixel scale at a screen row (`showhud.inc:90-111`)

```
GetGUIElementAlignPosition(hud, ax, ay)
ScreenToWorldRayCast(1, ay, sx1, sy1, sz1)
ScreenToWorldRayCast(GetViewerWidth-1, ay, sx2, sy2, sz2)
perspwidth := VectorDistance(sx1, 0, sz1, sx2, 0, sz2)    # :105
scale      := perspwidth / GetViewerWidth                  # :106  world m per pixel
sizex      := abs(x2-x1)/scale*0.9                         # :109  world m → HUD px
```

### F. Minimap jump (`onmousedown.inc:116-131` + `control.script:574-613`)

```
# helper reads camera.cfg itself: minH=20, maxH=58, four angles=-32  (:581-589)
CameraInfoSaveFromCurrentView('@movecamera')
CameraInfoReadProperties('@movecamera', tx, height, tz, cx, cy, cz)   # :592-593
angleZ := -Lerp(-32,-32,Clamp((height-20)/(58-20),0,1)) = +32         # :595
dx := cx-tx; dz := 0.1; VectorRotateX(dx,dy,dz,angleZ)                 # :596-599
offZ := ArcTan(angleZ)*height ≈ 1.6004*height                          # :602
angleX := VectorAngle(0,0,1,dx,0,dz); if dx<0 then angleX:=-angleX     # :605-607
VectorRotateY(offX,tmp,offZ,angleX)                                    # :609
newX := dstX+offX+dx;  newZ := dstZ+offZ+dz                            # :611-612
SetMainCameraRotateToTargetDir(false); SetMainCameraMoveToTargetXZ(newX,newZ)  # onmousedown:129-130
```

### G. World↔grid (`misc.script:2013-2027`)

```
i := Floor(2*x) + GetMapWidth;   j := Floor(2*y) + GetMapHeight
x := (i - GetMapWidth)/2;        y := (j - GetMapHeight)/2
```

---

## Divergences from the current port (donor is truth; 2D port secondary)

| Topic | Donor | Current port | Divergence / consequence |
|---|---|---|---|
| Projection | focal-length perspective; runtime FOV from `(focallength, viewportdimension)` | `camera3d.gd:60,65,153` `DONOR_FOCAL=400` documented, `FOV_DEG_ASSUMED=17.27` hard-coded | FOV is an assumption; donor API proves FOV is resolution-dependent. Do not claim parity |
| Camera offset / bookmark | `offZ≈cot(32°)*h`; `TargetZ=78.42125` for `h=49` | `camera3d.gd` uses `h/tan(32°)` (V790 probe measured back 54.505 at h=34.06) | numerically consistent; keep, but document `ArcTan` semantics as U |
| Click pick | ray→**AABB** segment camera→ground cursor (`control.script:184`), ranked by `(1+dist)/prio` | `picking3d.gd:266-304` screen-space pixel radius from `game.pick_radius` at entity depth + 2 m fallback; `_pixel_reach()` `:214` | **fundamental**: port approximates a 3D AABB hit with a 2D screen circle; parallax/occlusion and priority semantics differ |
| Click player filter | left-click uses `_control_GetUnitUnderCursor(**True**)` → own player only (`onmousedown.inc:280`); orders use `False` (`:394,480,683`) | left-click `input_controller.gd:626` `_pick(pw, false)` → every player competes | **donor-grounded fix**: left-click should be `players_only=true`; orders stay `false` |
| Fallback radius | no "2 m fallback" in donor; AABB hit + priority | `FALLBACK_REACH_M=2.0` unconditional (`picking3d.gd:40,296`) | port-only heuristic; document as approximation, not donor parity |
| Distance ranking | `relativeDst=(1+dist)/prio`, prio 1..7; `.x,.y` quirk | nearest screen pixel, 0.5 px tie (`picking3d.gd:266-304`, `TIE_PX :42`) | priority ordering absent in port |
| Drag rectangle | world-space ground coords, world epsilon threshold, `spmAdd` on Shift (`onmousemove.inc:142-167`) | screen-pixel threshold 6 px (`input_controller.gd:613,662`), ground-space rect (`:615-624`), Shift ignored for rect (always replace) | threshold space and Shift semantics differ; port selects only `player==0 && kind=="unit"` (`:620`) while donor filters via `OnSelection` incl. squads/buildings/water/guard |
| Ground point | engine heightfield ray, precision 1e-7 (`init.script:101`) | `picking3d.gd:235-241` ray-march (`RAY_STEP_M=1`) + 20 bisections; `camera3d.screen_to_world` flat Y=0 (`:266`) | port approximation; flat anchor can diverge from terrain hit |
| Viewport rect | `GetCameraFrustumQuadrangle` / 4 corner raycasts (`classes.script:6030`, `onresize.inc:66-72`) | `camera3d.gd:356-368` `get_viewport_corners()/get_view_rect()` uses `project_ray_*` ∩ ground | conceptually correct; must use heightfield, not Y=0, for donor parity |
| Minimap box | engine `SetMiniMapFrustumVisible(true)`, primitives at world `(x,z)` (`initminimap.inc:37`, `dogenerate.inc:423`) | 2D heritage `cam.global_position = world*view_scale` (RENDER_ARCH_CAMERA `:223-226`) | perspective breaks direct world↔minimap identity; needs frustum-corner mapping |
| Minimap jump | full offset helper body exists in donor text (`control.script:574-613`) | `camera3d.gd` centres clicked sim point; ArcTan offset "LEFT OPEN" (V790 `:326-328`) | DEEPDEC-01's "body absent" was wrong; formula now available, semantics still U |
| World origin | centred (`x=(i-GetMapWidth)/2`) | centred scene + sim `[0..MAP_W*TILE]` offset (FIXSEL `:71-77`) | both frames exist; keep adapter explicit (FIXSEL regression) |
| FOV token | `GetCameraFieldOfViewByFocalLength` exists in EXE | no equivalent; assumed 17.27° | prior docs said "no FOV token"; corrected |

---

## Concrete fix recipe (Godot 4 equivalent math)

**(a) Click-pick a unit.** Keep the `Camera3D`, drop the screen-radius test as the primary rule.
1. `screen` → ground point `g` with the same ray used for orders (below). 2. `from =
cam.global_position`, `dir = (g - from).normalized()`. 3. For each live entity, build its
collision AABB in centred world metres (`Vector3(sim.x-halfW, height_at, sim.z-halfH)` ±
half extents + height) and test `aabb.intersects_ray(from, dir)` (Godot's slab test is the
equivalent of `GetGameObjectRayCastAABBByHandle`). 4. Rank survivors with donor priority
`prio` = my 1 / wood 2 / food 3 / stone 4 / goinside 5 / build 6 / enemy 7 and
`relativeDst=(1+dist)/prio`, taking the minimum; `dist` = ground distance from `g` to entity
centre (use XZ; donor's `.x,.y` field quirk is documented, not copied blindly). 5. Apply donor
player filter: left-click `players_only=true` (own only), orders/cursor `false`; apply FOW LOS
check on the winner. 6. Keep the 2 m screen-space fallback only as a *declared port
approximation* until an AABB test is wired.

**(b) Drag-rectangle select.** Replace the 6-px screen threshold with a **world** threshold
(`epsilon` on `ground_point` delta, donor `onmousemove.inc:152`). On LMB down store the
ground point; on move, if world-delta > epsilon, set selection mode; on up finalise. Build the
rectangle from the two ground points and select entities whose AABB centre/point is inside,
iteratively (`SetGameManagerSelectionUseStep(true)`, `docreate.inc:100`). Shift = additive
(`spmAdd`), no Shift = replace (`spmRunTime`); Ctrl-remove is commented out in donor — do not
add it. After collection, apply an `OnSelection`-style filter (own player; land units before
water/buildings; exclude guards if non-guard units present; squad collapse) rather than the
current `kind=="unit" && player==0` filter (`input_controller.gd:620`).

**(c) Ground point under cursor.** Use `Camera3D.project_ray_origin/normal(screen)` and intersect
the **heightfield** (the existing `_ray_heightfield` march+bisection in `picking3d.gd:148`,
precision tighten toward donor `1e-7`), not the flat Y=0 plane (`camera3d.gd:266`). For HUD
pixel scale at an entity's depth, mirror `showhud.inc:90-111`: unproject two points at the
same screen row across the viewport width, `m_per_px = VectorDistance(p1,p2)/viewport_width`,
then convert metre radii/AABBs with that scale; equivalently use
`cam.unproject_position()` at the entity's world point (already done in `_pixel_reach()` `:214`).

**(d) Minimap camera box.** Compute four ground corners with the same rays as (c) — donor's
`GetCameraFrustumQuadrangle` — and map world→minimap with the centred-world formula
`u=(x+halfW)/mapW`, `v=(z+halfH)/mapH` (`misc.script:2017,2025`; map texture size 240 at
`initminimap.inc:31-33`). Draw the frustum quad (donor engine does this via
`SetMiniMapFrustumVisible(true)`); do not use `world_pos*view_scale`. For minimap click→camera,
invert the uv to `(dstX,dstZ)` and apply `control.script:574-613`: preserve the current camera
offset `(dx,dz)`, `angleZ=+32°`, `offZ = height/tan(32°)` (donor `ArcTan(angleZ)*height`,
≈1.6004·h), rotate into the current heading, then move the camera target to
`(dstX+offX+dx, dstZ+offZ+dz)` with rotate-to-target disabled.

**FOV:** do not replace `FOV_DEG_ASSUMED` with a claimed donor number. The donor API
`GetCameraFieldOfViewByFocalLength(f, viewportdimension)` proves FOV is derived at runtime and
resolution-dependent; keep 17.27° as a documented A/B assumption until the native conversion
constant is recovered or a donor screenshot A/B is consented.

---

## Open questions

1. **Native `ArcTan` semantics.** EXE declares only `function ArcTan(const val: Float): Float`
   (`0x209cc6`), which looks like ordinary arctangent, yet the camera formula needs a
   cotangent-like value to reproduce `78.42125`. Degrees/radians and VM implementation
   **UNVERIFIED**; `height/tan(32°)` is used as a numerically equivalent stand-in.
2. **Focal→FOV conversion constant.** API signature observed (focal + viewportdimension), body
   not decompiled this pass; numeric FOV, and which viewport dimension (width vs height vs
   scene scale) it uses, **UNVERIFIED**.
3. **`GetCameraFrustumQuadrangle` corner order.** `classes.script:6030` names corners
   LT/RT/RB/LB; the `ScreenToWorldRayCast` calls in `onresize.inc:66-69` mix `viewheight` into
   an X argument (likely donor quirk). Exact screen-corner↔ground-corner order **UNVERIFIED**.
4. **`_misc_GetDistancePos` `.x,.y` field choice.** Whether `TPos3f.y` from
   `GetCurrentMouseWorldCoord` is ground height or the second horizontal axis in this VM
   **UNVERIFIED**; copied literally only as a caveat, not as a port rule.
5. **Minimap GUI event X/Y units.** `onmousedown.inc:119-128` feeds `GetIntValueByName('X'/'Y')`
   straight into the world-space offset helper; whether the minimap element reports pixel or
   world coordinates **UNVERIFIED** (engine-side GUI event mapping).
6. **Engine selection internals.** `GameObjectRayCastMouseRay`, `GetGameObjectRayCastAABBByHandle`,
   `GameManagerBeginSelection/StartSelection` bodies are native-only; exact AABB and rect
   predicate **UNVERIFIED** beyond the script call contract.
7. **`GetCameraRestrictInfo(lx,rx,fy,by)` bounds.** Source of these four values not found in
   `camera.cfg`; likely map bounds set natively — **UNVERIFIED**.
8. **Ortho branches.** `glOrtho`/`gluOrtho2D` imports exist; which debug/HUD/editor paths use
   them **UNVERIFIED** (do not claim the main view uses them).

---

## Summary

Three independent donor passes converge: the main view is a **focal-length-driven perspective**
camera (focal 400, fixed +32° internal tilt, dolly height 20–58, `DirZ=-1`), with a runtime
**FOV API** that takes focal length and viewport dimension (new finding; prior "no FOV token"
is corrected). Picking is **engine ray→AABB** from camera position to the engine-computed
**ground point under the cursor**, ranked by `(1+dist)/prio` with donor priority 1–7;
drag-select is a **world-space** ground rectangle driven by `GameManagerStartSelection`; the
viewport rectangle comes from four ground raycasts / `GetCameraFrustumQuadrangle`; and the
minimap jump helper body **is present in donor text** (`control.script:574-613`), contradicting
DEEPDEC-01. The shipping port's screen-space radius pick, 6-px screen drag threshold, flat-Y=0
ground anchor and `view_scale` minimap identity are approximations, not donor math; the fix
recipe above replaces each with its documented donor equivalent while labelling the remaining
native unknowns (`ArcTan`, FOV constant, AABB/rect internals) as UNVERIFIED.

No donor file was executed or copied; no repo code/asset/config/test/git state was changed;
exactly one report file was written.
