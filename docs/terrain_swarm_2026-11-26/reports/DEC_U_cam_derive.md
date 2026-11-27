---
id: DEC-U-CAM-DERIVE
worker: DEC_U_CAM_DERIVE (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (carried from DEC_U_start_deep.md:7; this worker ran no native pass, no binary open/execution/copy)"
donor: "READ ONLY. Donor text scripts/data read as text only via read-only shell (Get-Content/Select-String). No donor binary executed/copied/opened as a target. No repo code/asset/config/Godot/git edit: this report is the only file written."
tooling: "read-only shell only (Get-Content, Select-String, Get-ChildItem) over `C:\\Games\\Cossacks 3\\data\\**` plus repo reports. No native craftanything call made by this worker, so no pin re-verification call was required; pin carried. No donor execution/copying."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. Parity UNVERIFIED."
labels: "[O] verbatim donor literal (path:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT CHOICE = port-authored substitute, never donor fact"
context: "DEC_U_start_deep.md found the start→camera wire at doprogress.inc:41 (_control_MoveCameraToPosition(gMap.players[myPlInd].startx, starty, 0, True)) with producer dogenerate.inc:1939, Home hotkey onshortcut.inc:1000, origin docreate.inc:297. Tasks 221/227 implemented it in camera.gd/camera3d.gd/game.gd. PORT1TO1_u_register2.md keeps CAM-derive and CAM-0 [U]: final target/height and time=0 smoothing, plus zoom 0.75 as PORT CHOICE. The prior camera ABSENT verdict is superseded at path scope only."
---

# DEC-U-CAM-DERIVE — camera target/height/zoom/smoothing producers (text-only sweep, 2026-11-26)

## 0. Scope and method `[O]/[D]`

Sweep question: does donor **text alone** recover (a) the final first-frame camera target, (b) the final height/zoom, (c) `time=0` smoothing semantics — i.e. can CAM-derive / CAM-0 be closed without a donor runtime capture?

Method `[O]`: read-only `Select-String` over `C:\Games\Cossacks 3\data\**` (`*.inc`, `*.script`, `*.cfg`) for `_control_MoveCameraToPosition`, `MoveCameraTo*`, `_misc_ZoomCamera`, `SetCameraElasticDistance`, `SetCameraDepthOfView`, `SetCameraInfoSmoothing*`, `SetMainCameraMoveToTarget*`, `SetMainCameraPositionXZ`, `CameraInfoSaveWithProperties`, `CameraInfoSaveFromCurrentView`, `GetCameraTargetPosition`, `SphereHeight`, `SphereLength`, `0.75|zoom|Zoom`. Denied-file errors on a few `data/scripts/**` leaves were skipped via `Get-ChildItem -Recurse + try/catch`; all readable hits are tabulated below. No file was executed, copied into the repo, or modified.

Result headline: **every call/wire fact below is `[O]` with `path:line`; every numeric constant is separated from its liveness; final height/zoom/target derivation and `time=0` smoothing are NOT recoverable from text alone — CAM-derive and CAM-0 stay `[U]` with matched-camera zero-mismatch termination (§5).** The port `0.75` zoom is PORT CHOICE, not donor law (§4). No parity claim. Parity UNVERIFIED, chain 0/6, RESULT IS NOT GOOD (§6).

## 1. Complete `_control_MoveCameraToPosition` census `[O]`

Definition (single):

| Path:line | Verbatim fact `[O]` |
|---|---|
| `C:\Games\Cossacks 3\data\scripts\lib\control.script:616-618` | `// _control_MoveCameraToPosition` + `procedure _control_MoveCameraToPosition(dstX, dstZ, time : Float; bSetMaxHeight : Boolean);` — 4 params (3×Float + 1×Boolean). Only script-level camera-target entry that ever takes start-derived args. |

All call sites (exhaustive over readable text):

| # | Path:line | Call verbatim `[O]` | Args (target / time / maxH) | Role |
|---|---|---|---|---|
| C1 | `C:\Games\Cossacks 3\data\gui\menu.inc\doprogress.inc:41` | `_control_MoveCameraToPosition(gMap.players[myPlInd].startx, gMap.players[myPlInd].starty, 0, True);` | target = local interface player's post-shuffle `startx/starty`; `time=0`; `bSetMaxHeight=True` | **First-camera wire.** Gated by one-shot `gbool_gui_mapgenerationfinished` (`:38-40`, cleared `:40`). THE skirmish first-frame target call. |
| C2 | `C:\Games\Cossacks 3\data\gui\menu.inc\onshortcut.inc:1000` | `_control_MoveCameraToPosition(gMap.players[plind].startx, gMap.players[plind].starty, time, (bCtrl));` | target = `plind` player's `startx/starty`; `time := 0` if `bCtrl` else `1500` (`:996-999`); `bSetMaxHeight=(bCtrl)` | Home / Ctrl+Home hotkey. Manual, post-start, player-initiated — NOT the first camera. Second start-parameterised site. |
| C3 | `C:\Games\Cossacks 3\data\gui\menu.inc\docreate.inc:297` | `_control_MoveCameraToPosition(0, 0, 0, True);` | target = map origin `(0,0)`; `time=0`; maxH=True | Engine first-run mainmenu origin reset (`:296` gate `gamemode=mainmenu and IsEngine`). NOT a start. |
| C4 | `C:\Games\Cossacks 3\data\scripts\lib\control.script:684` | `_control_MoveCameraToPosition(posX, posZ, 0, False);` | target = unit-list centroid (`:679-683` mean of `GetGameObjectPositionX/ZByHandle`); `time=0`; maxH=False | `_control_MoveCameraToUnitsListCenter(:669-684)` body. Group-hotkey / selection flow, never start-wired. |
| C5 | `C:\Games\Cossacks 3\data\scripts\lib\scenario.script:1849` | `_control_MoveCameraToPosition(gScenario.zones[zoneid].x, gScenario.zones[zoneid].y, 0, True);` | target = scenario zone `(x,y)`; `time=0`; maxH=True | `gc_trigger_action_map_cameraMoveToZone`. Mission trigger flow, never skirmish-start-wired. |
| C6 | `C:\Games\Cossacks 3\data\gui\menu.inc\onmousedown.inc:122` | `_control_MoveCameraToPosition(x, y, 0, False)` | target = minimap click `(x,y)`; `time=0`; maxH=False | Minimap double-click jump (`:118-122`, `bDouble` branch). Never start-wired. |
| C7 | `C:\Games\Cossacks 3\data\gui\menu.inc\onmousedown.inc:141` (commented) | `; _control_MoveCameraToPosition(x, y, time, False);` | dead code inside `{...}` comment (`:132-141`, `time := 100` variants) | NOT live. Proves only that a 100 ms minimap easing was considered and left commented. |
| C8/C9 | `C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:310,316` (commented) | `; _control_MoveCameraToPosition(mx2, mz2);}` / `; _control_MoveCameraToPosition(mx, mz);}` | dead code (whole-file `[*] = ;` convention; surrounding `ZoomCamera` live at `:298`) | NOT live. Wheel path uses `ZoomCamera`, not these lines. |
| — | `C:\Games\Cossacks 3\data\scripts\lib\control.script:707` (indirect) | `_control_MoveCameraToUnitsListCenter(gIntegerList);` | via `_control_MoveCameraToSelectedUnits(:688-707)` ← `onshortcut.inc:846` | Selection centroid flow, never start-wired. |

`[D]` consequence: exactly **two** live start-parameterised call sites exist in readable text (C1 first-camera, C2 Home hotkey). No other live caller passes `startx/starty`, a zone, or a start record.

## 2. Wrapper body — what text fixes vs what stays engine-side `[O]/[D]/[U]`

`control.script:619-664` verbatim sequence `[O]`:

- `:620` `const cCameraName = '@movecamera';` `:621-622` create-if-missing; `:624` `dov := GetCameraDepthOfView` saved; **`:625` `SetCameraInfoSmoothingTime(time);` `:626` `SetCameraInfoSmoothingChange((time>0));`** — smoothing law is a pure function of the `time` argument in text.
- `:628-637` re-parse `.\data\cameras\camera.cfg` every call; `:632-633` `minHeight := ...'SphereLengthMin'`, `maxHeight := ...'SphereLength'` — height limits are **config-key reads, not literals** at this site (values live in `camera.cfg`, §3).
- `:640-641` `CameraInfoSaveFromCurrentView` + `CameraInfoReadProperties(tx,height,tz,cx,cy,cz)` — current-view read.
- **`:643-644` `if (bSetMaxHeight) and (not gProfile.bDbgCamera) then height := maxHeight;`** — the `True` flag forces height to the config max (non-debug). This is the ONLY height assignment on the C1/C2/C3/C5 path.
- `:646` `angleZ := -Lerp(minHeightMaxAngle, maxHeightMaxAngle, Clamp((height-minHeight)/(maxHeight-minHeight),0,1));` `:647-650` `dx:=cx-tx; dz:=0.1; VectorRotateX;` **`:653` `offZ := ArcTan(angleZ)*height;`** `:656-660` `angleX` + `VectorRotateY;` — deterministic text offset math.
- **`:662` `CameraInfoSaveWithProperties(cCameraName, dstX+offX, height, dstZ+offZ, dstX+offX+dx, height+dy, dstZ+offZ+dz);` `:663` `CameraInfoLoadToCurrentView(cCameraName);` `:664` `SetCameraDepthOfView(dov);`** — write + load + depth restore.

`[D]`: text fixes the call graph, the `time→(SmoothingTime, time>0)` law, the `True→maxHeight` assignment, and the `ArcTan` offset formula shape.
`[U]` (NOT in text): whether `SetCameraInfoSmoothingTime(0)` + `Change(False)` is truly instant or one eased engine step; the native `Lerp/Clamp/VectorRotate*/ArcTan/ParserGet*` float semantics; the engine `SphereLength` clamp actually applied (`SetCameraElasticDistance(100)` "camera will clamp this value to maximum", `docreate.inc:82`); final rendered-frame target/height after `CameraInfoLoadToCurrentView` + elastic/raycast/bounds processing. Hence **CAM-0** (smoothing) and the height/target half of **CAM-derive** stay `[U]` (§5).

Sibling offset helper `[O]`: `_control_GetMoveCameraToPositionOffset(dstX,dstZ; var newX,newZ)` (`control.script:572-574`, body `:584-612`) — same key reads (`SphereLengthMin/SphereLength` at `:584-585`), same `angleZ=-Lerp(...)=+32` shape, `offZ=ArcTan(angleZ)*height`; caller ONLY `onmousedown.inc:128` (minimap single-click pan via `SetMainCameraMoveToTargetXZ(newx,newy)` at `:130`). Never start-wired.

## 3. Height / zoom / smoothing / target producers — numeric constants vs liveness `[O]`

### 3.1 Height limits and pitch/focal (config) `[O]`

| Path:line | Literal `[O]` | Liveness `[O]` |
|---|---|---|
| `C:\Games\Cossacks 3\data\cameras\camera.cfg:6-7` | `SphereHeight = 58`, `SphereHeightMin = 20` (commented `//SphereHeight = 49` at `:5` is dead) | LIVE for gameplay: re-parsed every `_control_MoveCameraToPosition` call (`control.script:629-633`); `bSetMaxHeight=True` forces `height := maxHeight` = 58 in text (`:643-644`, non-debug). Engine clamp behaviour itself is `[U]`. |
| `camera.cfg:9-10` | `SphereLength = 58`, `SphereLengthMin = 20` (commented `//SphereLength = 49` at `:8` dead) | LIVE (same reads). `onmousewheel.inc:23-24` + `misc.script:6250-6251` read the same two keys. |
| `camera.cfg:32-35` | pitch `-32` ×4 (`Min/MaxHeight Min/MaxAngle`), `AngleLerpPower=1` | LIVE via wrapper `:646` Lerp (all four −32 ⇒ `angleZ=+32` degenerate in text `[D]`). |
| `camera.cfg:44-45` | `MinFocalLength=400`, `MaxFocalLength=400`, `FocalLengthPower=1.0` | LIVE as config; zoom fixed in file. No script line derives a zoom number from it (focal→FOV law is engine-side; see `DEC_U_camera_projection.md` V1-SENSOR `[U]`). |
| `cameradebug.cfg:5-8` | `SphereHeight=19/Min=5`, `SphereLength=19/Min=5` | LIVE only under `gProfile.bDbgCamera` (`docreate.inc:66-73`). Skirmish default path is non-debug. |
| `camerascreenshot.cfg:6-10` | `SphereHeight=13/Min=0.75`, `SphereLength=13/Min=0.6` | LIVE only under `gbool_gui_screenshotcamera or bfreezoom` (`docreate.inc:299-336`). NOT the skirmish first-camera rig. The `0.75` here is a screenshot min-height, unrelated to any zoom. |
| `docreate.inc:82` | `SetCameraElasticDistance(100); // camera will clamp this value to maximum` | LIVE lobby arming (also `donewgame.inc:51-53`, `eventcampaign.inc:86-88` with `gbool_gui_maxcameradist := True`). Pre-generation, not a target; numeric 100 is an over-max arm, final clamp is engine-side `[U]`. |
| `docreate.inc:86,106` | `SetCameraDepthOfView(1200);` | LIVE menu-state default. Preserved across the wrapper (`control.script:624/664`). Far-plane binding is engine-side `[U]`. |
| `onshortcut.inc:1095,1104` | `SetCameraElasticDistance(dist+step)` / `(dist-step)` | LIVE hotkey zoom-step path (`[`/`]`). Step size `step` is script-local; NOT start-wired; final height after step is engine-clamped `[U]`. |

### 3.2 Smoothing / `time` arguments (all live literals) `[O]`

| Path:line | `time` literal `[O]` | Meaning in text `[D]` |
|---|---|---|
| `doprogress.inc:41` | `0` | `SmoothingTime(0)` + `Change((0>0)=False)` (`control.script:625-626`). First-camera. Instant-vs-eased is engine-side → CAM-0 `[U]`. |
| `docreate.inc:297` | `0` | Same law. Origin reset. |
| `control.script:684` | `0` | Same law. Centroid flow, `False` flag. |
| `scenario.script:1849` | `0` | Same law. Zone trigger, `True` flag. |
| `onmousedown.inc:122` | `0` | Same law. Minimap double-click, `False` flag. |
| `onshortcut.inc:997-999` | `0` (Ctrl) else `1500` | `time := 0 / 1500` then C2. `1500` = the ONLY non-zero live smoothing literal on any start-parameterised path; manual hotkey only. |
| `onshortcut.inc:1313,1324` | `3000` / `1500` | Saved-camera loader (`@cameraGrLook`/`@tempcamera`), not start-wired. |
| `onshortcut1.inc:58-60` | `time>0 → Change/Time(time)`, default editor `time=3000` (`:52`) | Editor camera loader. Not start-wired. |
| `onmousewheel.inc:16-17`, `misc.script:6243-6244` | `SetCameraInfoSmoothingTime(time); Change((time>0));` | Laws inside `ZoomCamera`/`_misc_ZoomCamera`. Callers pass `0` (`docreate.inc:349`, `eventsettings.inc:686`, `onmousewheel.inc:298` wheel `ZoomCamera(0, wheelDelta, ...)`). |
| `docreate.inc:76-78,92`, `dombtncameracontrol.inc:26/59`, `movie.script:92/102/113-114` | `Change(False/true/(time>0))`, `Time(time*1000*...)` | Init / middle-button / cinematic paths. None start-wired. |

No `time` literal other than `0` exists on the first-camera path. No lerp constant, ease curve, or frame count appears in text.

### 3.3 Target producers that are NOT the first camera `[O]`

- `GetCameraTargetPosition(px,py,pz)` reads: `gui.script:2803`, `:2942`, `:3254` — all three feed **audio listener** placement (`ScreenToWorldRayCast` centre + `VectorDistance/Normalize`, `lx := rx-dst*dirx*0.3/0.1`), not a camera write. Parallel sound-progress reads: `soundcontrol.inc:13`, `soundcontrolcounters.inc:69`. Zero camera-target writes derive from these reads.
- `SetMainCameraMoveToTargetXZ(newx,newy)`: `onmousewheel.inc:302` (wheel branch), `onmousedown.inc:130` (minimap single-click via offset helper), `doinitialize.inc:208` sets only `SetMainCameraMoveToTargetSpeed(8)`. Zero callers pass `startx/starty`.
- `_misc_ZoomCamera(time,deltaheight; var newx,newy; bSet)` (`misc.script:6231-6302`): callers `docreate.inc:349` (`0,0,...,True` clamp), `eventsettings.inc:686` (`0,0,...,True`), wheel `ZoomCamera(0,wheelDelta,...,True)` (`onmousewheel.inc:298`). Never start-parameterised; never sets a target from starts.
- `SetGUIMinimapZoom(1)` (`initminimap.inc:34`, commented-out init block) — engine minimap zoom call, not a 3D camera zoom; unrelated to any `0.75`.

### 3.4 Flag / ordering wire `[O]`

- Producer: `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1939` `gbool_gui_mapgenerationfinished := True;` (end of `DoGenerate`, after unit-spawn loop + `_misc_PreloadTextures` + `SetRandomKey`). NOTE: full directory is `scripts\common.inc\dogenerate.inc` (prior `DEC_U_start_deep.md` cited `dogenerate.inc:1939` without the directory; line number re-verified identical this sweep).
- Consumers: `doprogress.inc:38-44` (one-shot camera, clears flag `:40`); `doambientsound.inc:34` (music switch, confirms "first tick after gen" global meaning).
- `[D]` ordering: shuffle precedes the flag; first `DoProgress` tick after generation consumes it → local player's post-shuffle `startx/starty` becomes `(dstX,dstZ)` at `time=0, True`.

## 4. The `0.75` zoom — donor-text result `[O]` + PORT CHOICE separation

Exhaustive `0.75|zoom|Zoom` sweep over readable `C:\Games\Cossacks 3\data\**` `[O]`:

- **Zero** `0.75` hits in any `*.script`/`*.inc` camera call, any `data\cameras\*.cfg`, or any camera smoothing/height argument. The only camera-adjacent `0.75`-looking literal is `camerascreenshot.cfg:7` `SphereHeightMin = 0.75` (screenshot rig min-height, §3.1) — not a zoom, not on the skirmish path.
- Every other `0.75` hit is non-camera: UI blends (`showaiassistantadvices/showunitcontrol/showhud/doprogress/gui.script _gui_FadeElement 0.75`), audio defaults (`profile.script:11-15` `snd*=0.75`), economy (`res.script:214 sellcostmin*0.75`), difficulty scales (`data.gd-relevant donor unit.script:5376/5395 dst:=0.75`, `dogenerate.inc:1258 cUnitR=0.75`, `map.script:45-46/87-88 0.75` grid jitter), scroll `koef ...*0.75` (`onmousewheel.inc:229`), `minimap.cfg X=0.75` sprite offset (`:228`), mesh floats in `objcustom.cfg/wallcustom.cfg`.
- `ZoomCamera` (wheel, `onmousewheel.inc:4,298`) and `_misc_ZoomCamera` (`misc.script:6231`) take `deltaheight`, never a `0.75` factor; `SetGUIMinimapZoom(1)` is the only zoom-factor literal and equals `1`.

Port fact (read-only, no edit) `[O-PORT]`: `variant3d/scripts/main.gd:77` `var start_zoom := 0.75`, `main.gd:194` `cfg.num("camera.start_zoom", 0.75)`, mirrored as PORT CHOICE in `camera.gd:77-88,161` (`PORT CHOICE [U]-CAM - START zoom ... stays a port ...`). Carried from `PORT1TO1_handoff_sync.md:39` (tasks 221/227 DONE: `game.gd:94/709/686-694`, `camera.gd:179-187`, `camera3d.gd:485-492`, parses OK).

`[D]`: the port `0.75` is therefore a **PORT CHOICE with no donor-text counterpart** and must never be written back as donor law. This report does not promote it, nor any height (58 or otherwise), to donor parity. No camera match is claimed.

## 5. Recoverability verdict — CAM-derive / CAM-0 stay `[U]`

| Item | Static state after this sweep | Why text alone cannot close it | Exact zero-mismatch terminator (owner/COORD only; this worker runs nothing) |
|---|---|---|---|
| **CAM-derive** — final first-frame camera target + height after `doprogress.inc:41` | Call + args `[O]` (§1 C1); wrapper offset math `[O]` text (`control.script:639-664`); config limits 58/20 `[O]` (§3.1); native clamp/interp `[U]` (§2) | Text gives `(dstX,dstZ) = (startx,starty)` INPUTS and the `offX/offZ = f(angleZ,height)` formula SHAPE, but final rendered target = `dst + off(angle,height)` after `CameraInfoLoadToCurrentView` + engine elastic/bounds/raycast processing, and final height = engine clamp of `maxHeight=58` — none observable in text. Zoom has no donor literal at all (§4). | Fixed 2-start map, seed S, offline, 3 identical owner runs WITHOUT input: record first-rendered-frame camera target + height + the local `startx/starty`. **Zero-mismatch:** `startx/starty` equal the rescale law exactly; camera target repeats byte-identically across all 3 runs (declares ENGINE-DEFAULT-STABLE, never donor law); `bSetMaxHeight=True` height equals `SphereLength=58` clamp exactly or the deviation is quoted verbatim, never patched. Any jitter ⇒ PORT CHOICE fork stays labelled as such. |
| **CAM-0** — `time=0` smoothing semantics | `time=0 → (SmoothingTime(0), Change(False))` law `[O]` (`control.script:625-626`); all first-path literals `0` `[O]` (§3.2) | Text proves the ARGUMENTS passed to the engine, not what the engine DOES with `Time(0)+Change(False)` (instant cut vs one eased step vs clamped minimum). No duration/frame/ease literal in text. | Same capture with frame-by-frame target log for the first 5 frames. **Zero-mismatch:** frame-1 target == frame-5 target (instant) on all 3 runs, else report eased-step counts verbatim. Until then `time=0` stays `[U]`. |
| S-place / S-ver / N-native | Unchanged from `DEC_U_start_deep.md §6` | Out of this ticket's scope; listed so no row is accidentally closed | Per `DEC_U_start_deep.md §6` / `PORT1TO1_u_register2.md §3 N-2…N-4`. |

`[D]`: no alternative text angle remains — definition site, all 9 call sites (2 live start-wired, 1 origin, 2 centroid/selection, 1 zone trigger, 1 minimap, 2 dead-commented), both zoom helpers, all smoothing literals, all height/focal/pitch config keys, all `GetCameraTargetPosition` reads, the `0.75` sweep, and the flag producer/consumer set were all re-read this sweep. What is missing (engine interpolation, clamp result, focal→FOV law, final pixels) lives behind natives by construction (`DEC_U_camera_projection.md` V1-SENSOR/V2-PROJ `[U]`).

## 6. Verdict, chain, and file discipline

- **Parity UNVERIFIED.** `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. No donor GPU A/B frame exists; none was produced or examined by this worker. No metric, gate, replay pair, ROI, still, hash, byte dump, `[D]` derivation, or "close" value constitutes parity.
- **Six-condition chain 0/6 CLOSED** (carried from `PORT1TO1_u_register2.md:63/177`: condition 6 PARTIAL port-internal only; conditions 1/3/4/5 BLOCKED, 2 PARTIAL). This sweep changes zero conditions.
- **`blocking_unverified` is non-empty** (nine P0 rows per `PORT1TO1_u_register2.md §4` plus domain tails CAM-derive/CAM-0/D4 unless explicitly excluded per §5) — so the honest verdict is **`RESULT IS NOT GOOD`** unconditionally. No parity claim is made.
- **No promotion:** the port `0.75` zoom (`main.gd:77`) and the config `58` clamp limit are PORT/static facts respectively, never donor parity values. No height, zoom, FOV, near/far, target, or smoothing literal is invented or wired to a value in this report.
- **Prior verdict handling:** the "camera ABSENT" verdict stays SUPERSEDED at path scope only (wire C1 `[O]`); file-scope absence for `initmapgen/dogenerate` stands. Nothing in this sweep re-closes or re-opens it beyond exact `path:line` citation.
- **Read-only compliance:** exactly one repository file written (this report). All donor evidence is text reads via read-only shell with `path:line`; donor binary never executed/copied/opened as a target; no source/asset/config/test/runner/Godot/git state changed. Network out of scope.

*End of DEC_U_cam_derive.*
