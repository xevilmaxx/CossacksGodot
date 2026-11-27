---
id: DEC-U-START-DEEP
worker: DEC-U-START-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as a target. Donor text scripts/data read as text only. CODE bytes read via file-offset reads (no execution, no disassembly). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "Prior DEC-U-START-POSITIONS recovered fixed-map law (-10000 sentinel, white-pixel dedup, rescale, +2 ellipse, team shuffle) but declared the first camera/focus wire ABSENT and camera derivation [U]. This ticket re-attacks from NEW angles. HEADLINE: the ABSENT verdict is SUPERSEDED — a start-parameterised first-camera call exists on the skirmish start path (doprogress.inc:41). Camera numeric derivation stays [U]."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-START-DEEP — start/camera wire from new angles (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c`. PE32, ImageBase `0x400000`, 10 sections. CODE: file `0x400`, len `0x4F0E00`, VA `0x401000–0x8F1E00` (parsed from e_lfanew + section table, read-only). Binary never executed, copied, or opened as a target. |
| P2 | CODE byte search, 18 terms, full CODE range | EV-CODE: zero-count VAs for `CreateStartPoint`, `RandomStartingPoints`, `docreate`, `docamera`, `SetCameraPosition`, `startingunits`, `arrStartPos`, `cCircle1MaskX`, `_control_SetPlayer` (§1). `startx` ×6 / `starty` ×3 are pathfinding param names only; `SphereHeight` ×2 is a config blob; camera natives present as a 151-entry API table (§1). Full-binary recount confirms (§1). |
| P3 | Whole-file recount (outside CODE) | EV-FULL: `CreateStartPoint`/`RandomStartingPoints`/`docreate`/`SetCameraPosition`/`startingunits`/`arrStartPos`/`_control_*`/flag-name totals = 0 across all 5,768,048 B. `DoCreate` ×2 are `QueryMachineQuery/ResultDoCreateExecute` proc names (`VA 0x6E2613/0x6E3CA0`), not menu-state refs. `SetMainCamera*` ×6, `CameraInfoLoad*` ×2 exist in the API table only (§1). |
| P4 | Script wrapper census (control/misc + gui) | EV-WRAP: arities of all camera movers (§2). `_control_MoveCameraToPosition(dstX,dstZ,time,bSetMaxHeight)` = 4 params; `...Offset` = 2 in + 2 `var` out; `...UnitsListCenter(var list)` = 1; `...SelectedUnits()` = 0; `_misc_ZoomCamera(time,delta,d,newx,newy,bSet)` = 5 in → Boolean. No native takes a start record; starts enter only as script-level arguments (§2). |
| P5 | Start→camera call-site hunt (new grep over `data/scripts` + `data/gui`) | EV-WIRE (SUPERSEDES prior ABSENT): `doprogress.inc:41` `_control_MoveCameraToPosition(gMap.players[myPlInd].startx, gMap.players[myPlInd].starty, 0, True)` gated by `gbool_gui_mapgenerationfinished` (§3). Second wire `onshortcut.inc:1000` Home-hotkey re-target (§3). Third: `docreate.inc:297` origin move `(0,0,0,True)` on engine first-run mainmenu (§4). |
| P6 | Flag producer/consumer trace | EV-FLAG: producer `dogenerate.inc:1939` `gbool_gui_mapgenerationfinished := True` (end of `DoGenerate`, after unit spawn + `SetRandomKey`); consumer `doprogress.inc:38-44` (one-shot, clears flag); parallel consumer `doambientsound.inc:34` (music, not camera) (§3). |
| P7 | Shipped `.map` read-only scan (4 mission maps, whole-file token search) | EV-MAP: header `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]`; `startx/starty....float` TMapPlayer fields (1 hit each); `startingunits....integer`; zero `StartPoint` records; `MergeCameraBegin…MergeCameraEnd` block holds NAMED saved cameras (`@movecamera`, `@CameraMiddleBtn…`), plus literal `.\data\cameras\camera.cfg` path (§5). |
| P8 | Camera-init census (`docreate` + `doinitialize` + `donewgame` + `eventcampaign` + `onmousewheel` + `onmousedown` + `onresize`) | EV-INIT: `docreate.inc:61-99` is NOT the only camera init — six further init/wire sites (§4). Refutes the (d) hypothesis as stated; docreate block remains the only properties/mode/depth/bounded setter. |
| P9 | Config + restrict re-read (`camera.cfg`, `doinitialize.inc:145-151`, `docreate.inc:296-350`) | EV-CFG: `SphereHeight=58/Min=20`, `SphereLength=58/Min=20`, pitch `-32` ×4, focal `400/400/1.0` `[O]`; map-size-parameterised `SetCameraElasticRestrict` triples; `_misc_ZoomCamera(0,0,…,True)` clamp (§4). No start-derived numeric literal anywhere. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. (a) Packed CODE byte search — API/property names with VAs [O]

Method `[O]`: read-only file-offset reads of `t_87f0f3c130b0`. CODE = file `0x400`, `0x4F0E00` B, VA base `0x401000` (ImageBase `0x400000` + RVA `0x1000`). VA for a CODE hit = `0x401000 + (fileoff − 0x400)`. Matches are inside the engine's CODE-embedded script-API registration table: entries read `procedure <Name>(<signature>)` / `function <Name>(<signature>): <type>` with `ffffffff <len>` framing. No disassembly, no execution.

### 1.1 Zero-hit table — names with NO CODE presence (and no full-binary presence)

| Term | CODE total | Full-binary total | Verdict |
|---|---|---|---|
| `CreateStartPoint` (also `CreateStartPointDebug`) | 0 | 0 | `[O-absence]` No native/script-API-table entry. Script-only (`dogenerate.inc:980`, `map.script:27/36/72`). |
| `RandomStartingPoints` | 0 | 0 | `[O-absence]` Script-only (`dogenerate.inc:1090`). |
| `startx` / `starty` as fields | 6 / 3, all other identifiers | same 6 / 3 | `[O]` All hits are unrelated param names: `GameObjectCalcPathExtByHandle(... const startx, startz, endx, endz ...)`, `GameObjectMyCreatePath(startx,starty,startz,endx,endy,endz)`, `GetGroupBetweenCoordsHandle(... startx, startz, endx, endz ...)`, `SLogicFrmPointGetPath(const startx, starty, endx, endy ...)`, `SetStretchBrushLockedStart(startx, starty, startz ...)`, `GetSLogicTestLineDistance(vstartx, …)` (`VA 0x62D61B, 0x63A0D1, 0x65E369, 0x69243D, 0x692786, 0x69E1A5`). NO `TMapPlayer.startx` field string in CODE. |
| `docreate` / `docamera` | 0 / 0 | 0 / 0 | `[O-absence]` No lowercase hits. `DoCreate` ×2 are `QueryMachineQueryDoCreateExecute` (`fileoff 0x2E1A13, VA 0x6E2613`) and `QueryMachineResultDoCreateExecute` (`fileoff 0x2E30A0, VA 0x6E3CA0`) — query-machine proc names, not the `DoCreate` menu state. |
| `SetCameraPosition` | 0 | 0 | `[O-absence]` No such native. Camera moves go through `CameraInfoSaveWithProperties` + `CameraInfoLoadToCurrentView`, and `SetMainCamera*` below. |
| `startingunits` / `arrStartPos` / `cCircle1MaskX` | 0 / 0 / 0 | 0 / 0 / 0 | `[O-absence]` Script-struct/config identifiers only, never linked into the binary. |
| `_control_SetPlayer` / `_control_MoveCameraToPosition` / `gbool_gui_mapgenerationfinished` / `MoveCameraToUnitsListCenter` | 0 each | 0 each | `[O-absence]` Script wrappers/flags only. The engine exposes the primitives they call, not the wrappers. |
| `@movecamera` / `@Camera0` / `default.cameras` | 0 / 0 / 0 | 0 / 0 / 0 | `[O]` Runtime string values passed as `const cCameraName` / filenames in script; not embedded literals in the binary. |

### 1.2 Positive hits — what IS in the CODE table [O]

- `SphereHeight` ×2, both in one embedded default-config blob: `...RestrictInfo...HeightTarget...HeightTargetMin...SphereHeight...SphereHeightMin...SphereLength...SphereLengthMin...ElasticInfo...MoveVelocity...` at CODErel `0x3AAC44` / `0x3AAC5C` = fileoff `0x3AB044` / `0x3AB05C` = **VA `0x7ABC44` / `0x7ABC5C`**. `[D]`: key-name blob (mirrors `camera.cfg` `RestrictInfo` keys), not a script API entry; no numeric value travels with the names in the visible window.
- `CameraInfoLoad` ×2: `CameraInfoLoadWithProperties(tx,ty,tz,cx,cy,cz)` (CODErel `0x1FC9EE`, **VA `0x5FD9EE`**) and `CameraInfoLoadToCurrentView(const cameraname: String)` (CODErel `0x1FCB72`, **VA `0x5FDB72`**).
- `SetCameraElasticDistance(dist: Float)` ×1: CODErel `0x1FBD2A`, **VA `0x5FCD2A`**.
- `SetCameraBounded(bounded: Boolean)` ×1: CODErel `0x1FCFEA`, **VA `0x5FDFEA`**.
- `SetCameraDepthOfView(const d: Float)` ×1: CODErel `0x1FD37E`, **VA `0x5FE37E`**.
- `GetCameraTargetPosition(var x,y,z: Float)` ×1: CODErel `0x1FBC52`, **VA `0x5FCC52`**.
- `SetMainCamera*` ×6 total in table: `SetMainCameraRotateXYZ(x,y,z: Float)` (`VA 0x5FC82A`), `SetMainCameraRotateToTargetDir(rotatetotargetdir: Boolean)` (`VA 0x5FC872`), `SetMainCameraPositionXZ(x: Float; z: Float)` + `SetMainCameraMoveToTargetXZ(x: Float; z: Float)` (shared window, `VA 0x5FC8C2/0x5FC902`), `SetMainCameraMoveToTarget(val: Boolean)` (`VA 0x5FC946`), `SetMainCameraMoveToTargetSpeed(val: Float)` (`VA 0x5FC9BA`).
- Full camera-API census `[O]`: **151 entries** matching `(procedure|function) …Camera…(…)` in CODE, each with an arity-bearing signature (representative arities in §2 table; full list retained in temp `codecam.txt`, not committed). No entry in the 151 takes a start record, a player index, or a `startx/starty` pair.

---

## 2. (b) Wrapper arities — no native camera-to-start call on the skirmish path [O]

| Wrapper / native | Arity (donor text) | Callers on start path | Verdict |
|---|---|---|---|
| `_control_MoveCameraToPosition(dstX, dstZ, time: Float; bSetMaxHeight: Boolean)` (`control.script:618`) | 4 (3×Float + 1×Boolean) | `doprogress.inc:41` with `(startx, starty, 0, True)` — THE first-camera wire (§3); `onshortcut.inc:1000` Home hotkey; `scenario.script:1849` zone trigger; `docreate.inc:297` origin `(0,0,0,True)`; `onmousedown.inc:122`; `doinitialize`-adjacent `onmousewheel.inc:310/316` (commented) | `[O]` Script wrapper, not native. Engine natives it sequences: `CameraInfoSaveFromCurrentView` → `CameraInfoReadProperties` → `CameraInfoSaveWithProperties` → `CameraInfoLoadToCurrentView` + `SetCameraDepthOfView` preserve (`control.script:640-664`). |
| `_control_GetMoveCameraToPositionOffset(dstX, dstZ: Float; var newX, newZ: Float)` (`:574`) | 4 (2 in + 2 `var` out) | `onmousedown.inc:128` only (drag-pan helper) | `[O]` Never start-wired. |
| `_control_MoveCameraToUnitsListCenter(var list: TIntegerList)` (`:669`) | 1 | `control.script:684` (self), `:707`, `onshortcut.inc:536/548/701` (group hotkeys) | `[O]` Unit-centroid flow, never start-wired. |
| `_control_MoveCameraToSelectedUnits()` (`:688`) | 0 | `onshortcut.inc:846` | `[O]` Selection flow, never start-wired. |
| `_misc_ZoomCamera(time, deltaheight: Float; var newx, newy: Float; bSet: Boolean): Boolean` (`misc.script:6231`) | 5 in (2 Float + 2 `var` Float + Boolean), Boolean return | `docreate.inc:349` `_misc_ZoomCamera(0, 0, newx, newy, True)` (height clamp, result discarded) | `[O]` Never start-parameterised. |
| `_control_SetPlayer(plInd: Integer)` (`control.script:712`) | 1 | `initmapgen.inc:204/214/225-226`, `initmap.inc:70`, `initmaphistoricalbattle.inc:89/97/106` | `[O]` Body = `GUIMiniMapPrimitivesClear; SetPlayerHandleInterfaceIO; _player_UpdateFOW; _control_DeselectAllUnits(False); GUIExecuteState('DoUpdateSelection'); GUIExecuteState('InitMinimap')` — NO camera call, NO selection, NO focus. |
| Natives `SetMainCameraMoveToTargetXZ(x,z)` / `SetMainCameraPositionXZ(x,z)` (CODE table §1.2) | 2 ×Float each | Script callers found: `onmousewheel.inc:302` (`SetMainCameraMoveToTargetXZ(newx,newy)`), `doinitialize.inc:208` (`SetMainCameraMoveToTargetSpeed(8)`); **zero** callers pass `startx/starty` | `[O-absence]` The only arity-2 direct camera-target natives are never start-wired in readable script. |
| Natives `SetCameraElasticDistance(dist)` / `SetCameraDepthOfView(d)` / `SetCameraBounded(b)` / `SetCameraPropertiesFromFile(f)` | 1 each | Lobby/menu init only (§4) | `[O]` Never start-parameterised. |

`[D]` consequence: there is NO engine-native "camera-to-start" entry point. The start reaches the camera exactly once, as two Float arguments through the 4-param script wrapper (§3). Any engine-side interpolation (height clamp to `SphereLength`, smoothing `time=0` semantics, `ArcTan(angleZ)*height` offset in `:646-662`) is native and stays `[U]` (captures in §6).

---

## 3. First-camera wire — prior ABSENT verdict SUPERSEDED [O]

- EV-WIRE-1 `[O]` — the skirmish first-camera call, `data/gui/menu.inc/doprogress.inc:36-44`:
  `var myPlHnd: Integer = GetPlayerHandleInterfaceIO; var myPlInd: Integer = GetPlayerIndexByHandle(myPlHnd); if (gbool_gui_mapgenerationfinished) and (myPlHnd<>0) then begin gbool_gui_mapgenerationfinished := False; _control_MoveCameraToPosition(gMap.players[myPlInd].startx, gMap.players[myPlInd].starty, 0, True); _misc_UpdateMiniMapPrimitives(False); end;`
  Args verbatim: `dstX = startx`, `dstZ = starty` of the LOCAL interface player, `time = 0`, `bSetMaxHeight = True`. One-shot (flag cleared). Runs inside the per-frame `DoProgress` GUI state, i.e. the first progress tick after generation finishes.
- EV-FLAG-1 `[O]` — producer, `dogenerate.inc:1939`: `gbool_gui_mapgenerationfinished := True;` placed AFTER the unit-spawn loop (`:1914-1923`), AFTER `_misc_PreloadTextures` (`:1925`) and the closing `SetRandomKey(randkey1)` (`:1927`). Declaration `dmscript.global:2071` (`gbool_gui_mapgenerationfinished = Boolean`), default `False` (`dmscript.source:4`).
- EV-FLAG-2 `[O]` — parallel consumer, `doambientsound.inc:34`: `if (gInterface.gamemode<>gc_gamemode_mainmenu) and (gbool_gui_mapgenerationfinished) then` → per-nation music switch. Confirms the flag means "first tick after gen" globally, not camera-specific.
- EV-WIRE-2 `[O]` — Home-hotkey re-target, `onshortcut.inc:991-1000`: `'Home','Ctrl+Home': … time := 0 (Ctrl) else 1500; _control_MoveCameraToPosition(gMap.players[plind].startx, gMap.players[plind].starty, time, (bCtrl));` Manual, post-start, player-initiated — NOT the first camera, but the second start-parameterised call site the prior P11 census missed (prior grep covered `data/scripts` only, not `data/gui`).
- `[D]` ordering law: `DoGenerate` (`:1939` flag) → `InitMapGen` tail (`TopologyBuild`, FOW, `gamestage := started` for offline) → `DoCreate` menu-state camera defaults (§4) → first `DoProgress` tick consumes flag → camera jumps to local player's post-shuffle `startx/starty` at max height. Post-shuffle values are guaranteed: shuffle (`:1615`) precedes the flag by ~324 lines.
- `[I]` (framed): with `time=0` the wrapper still runs the full `CameraInfoSave/Read/SaveWith/Load` sequence with `SetCameraInfoSmoothingTime(0)` + `SetCameraInfoSmoothingChange((0>0)=False)`; whether `time=0` is truly instant or one eased step is engine-side and stays `[U]` (CAM capture §6).

---

## 4. (d) `docreate.inc:61-99` — NOT the only camera initialization [O] (hypothesis REFUTED as stated)

Full start-path camera-init census (all `[O]`, verbatim):

1. Lobby arming — `donewgame.inc:51-53` (skirmish) and `eventcampaign.inc:86-88` (mission): `SetCameraElasticDistance(100); … gbool_gui_maxcameradist := True; // used in DoCreate to reset camera to default height`. Pre-generation, not a target.
2. Menu-state defaults — `docreate.inc:59-99`: `SetCameraPropertiesFromFile(cCamFilename)` (`.\data\cameras\camera.cfg`); max-dist branch loads `default.cameras` `@Camera0`/`@CameraDebug` with smoothing preserved/restored, deletes infos, `SetCameraElasticDistance(100)` ("camera will clamp this value to maximum"), `gbool_gui_maxcameradist := False`; then `SetCameraDepthOfView(1200); SetCameraElasticTargetObject(0); SetCameraElasticMoveTurnOff(); SetCameraElasticRotationTurnOff(); SetCameraControlMode('ccmRTS'); SetCameraInfoSmoothingChange(true); SetCameraBounded(False); SetCameraDynamicFocalLength(gProfile.bDbgCamera); SetCameraControlMouseWheelRotate/Distance(false)`. The ONLY properties/mode/depth/bounded setter on the path.
3. Dbg-camera branch — `docreate.inc:104-125`: `bDbgCamera` only (`DepthOfView(1200)`, `RestrictInfo` max-height 500, free-rotation ±90, wheel-rotate, mouse speed 10). Else-branch (`:126-137`): FOW update + `OnResize`.
4. Map-size bounds — `doinitialize.inc:145-151` (called FROM `docreate.inc:158` `ExecuteState('DoInitialize')`): `bfreezoom → Restrict(-W/2, -H/2-280, W/2, H/2+250)`; else `not bRestrictCamera or screenshot → (…, ±50)`; else `(-W/2, -H/2, W/2, H/2+85)`. Start-independent, map-size-dependent. Plus `SetMainCameraMoveToTargetSpeed(8)` (`:208`).
5. Engine first-run origin move — `docreate.inc:296-297`: `if (gamemode=mainmenu) and (IsEngine) then _control_MoveCameraToPosition(0, 0, 0, True);` Map origin, NOT a start — the mainmenu/reset camera.
6. Post-init clamp — `docreate.inc:341-350` (non-screenshot path): `_misc_GetMapLeftTopPos(maplx,mapty); SetCameraElasticRestrict(maplx+14, mapty, -(maplx+10.5), -mapty+85); var newx,newy; _misc_ZoomCamera(0, 0, newx, newy, True);` Forces height clamp. No target change.
7. Screenshot branch — `docreate.inc:299-336`: `camerascreenshot.cfg`, wheel-rotate/distance, fog/DOF/focal overrides. Orthogonal to skirmish.
8. THE start-derived target — `doprogress.inc:41` (§3). The only call on the whole path whose arguments are a player's `startx/starty`.

`[D]`: (d) is refuted in its "only" form: docreate:61-99 owns properties/mode/depth/bounded, but bounds come from doinitialize/docreate:341-350, arming from the lobby, the origin reset from docreate:297, and the first START-derived target from doprogress:41. No `CAMERA_START_*` numeric constant exists at any of these sites — camera derivation (final pixels after the wrapper's `ArcTan` offset + native clamp) stays `[U]`.

---

## 5. (c) Shipped `.map` files — start records present, no camera-to-start field [O]

Method `[O]`: whole-file byte search of 4 mission maps (`ausmis1–4.map`, 32–53 MB), plus ASCII header read. No map executed, none copied into the repo.

- Header (all 4): `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, `GameMapSnapShotBegin…End`, `GameMapRecordBegin`. `section.begin`/`struct.begin` counts = 0 (binary serialisation, not DScript text).
- `startx` ×1 + `starty` ×1 per file (exact field descriptors): `...color....integer...lanid....integer...startx....float...starty....float...aidifficulty....integer...bexists...` — i.e. `TMapPlayer.startx/starty: Float` stored per player record (cf. `classes.script:103`). Offsets differ per file (`ausmis1: 0xB8EACC`; `ausmis2: 0x39830A`; `ausmis3: 0x475A4B`; `ausmis4: 0x1009A6D`).
- `startingunits....integer` ×1 per file inside `...settingsAdditional...activeoption....integer...startingunits....integer...balloon...` — the UI preset id, not a coordinate.
- `StartPoint` (capitalised API form) ×0 in all files. No start-point object records; starts live ONLY as the two floats in the player record.
- Camera block ×1 per file: `MergeCameraBegin…@movecamera…CFG…MergeCameraEnd.Default` with per-file saved-camera bytes, plus stored path literals `.\data\cameras\camera.cfg`, `load.game`, `save.game`, `.\data\brushes\…`. Named entries observed: `@movecamera` (all files), `@CameraMiddleBtn…` variants (ausmis1-3), `@Camera0era` (ausmis4). These are SAVED camera snapshots serialised with the map, not a start-derived target field — no `startx/starty → camera` linkage record exists in the format.
- `players` ×3 per file: `players....TAfterGameStatisticsPlayers[8]`, `players....TMapPlayer[8]`, `players....TScenarioPlayer[8]` — three distinct 8-slot tables, consistent with `gc_MaxPlayerCount=12` script constant vs 8-slot serialised records (version-band truncation, cf. `<89` purge `initmapgen.inc:280-286`).

---

## 6. Still-[U] register — fixed-seed map/camera captures with zero-mismatch criteria

No constant invented. No parity claim. Owner-authorised runs only (binary run by owner, never this worker).

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| CAM-derive | Final first-frame camera target + height after `doprogress.inc:41` | Call + args `[O]` §3; wrapper offset math `[O]` text (`control.script:639-664`); native clamp/interp `[U]` | Fixed 2-start map, seed S, offline: record first-rendered-frame camera target + height + the local `startx/starty` across 3 identical owner runs WITHOUT input. **Zero-mismatch:** `startx/starty` equal §1-rescale law exactly (DEC-U-START-POSITIONS §8 S-bitmap); camera target repeats byte-identically across all 3 runs (declares ENGINE-DEFAULT-STABLE, never donor law); `bSetMaxHeight=True` height equals `SphereLength=58` clamp exactly or the deviation is quoted, never patched. Any jitter → PORT CHOICE fork stays labelled as such. |
| CAM-0 | `time=0` smoothing semantics | `[U]` | Same capture with frame-by-frame target log for the first 5 frames. **Zero-mismatch:** target at frame 1 == target at frame 5 (instant) on all 3 runs, else report eased-step counts verbatim. |
| S-place | Random-slot preset + shuffle order | Copy gate + shuffle `[O]` (prior §3/§4); engine preset `[U]` | Unchanged from prior S-place (seed S, N=4 FFA then 2v2-nearby, triple-run byte-identity + single-team-flip divergence). |
| S-ver | Version gates | Table `[O]` (prior §5) | Unchanged from prior S-ver (60/61/77/89/90/91 bands). |
| N-native | Engine-native VAs | `[U]-N` | If a future owner session recovers addresses: quote VA + bytes + calling line. New anchors from this ticket: API-table entries `SetCameraElasticDistance` VA `0x5FCD2A`, `CameraInfoLoadToCurrentView` VA `0x5FDB72`, `CameraInfoLoadWithProperties` VA `0x5FD9EE`, `SetMainCameraMoveToTargetXZ` window VA `0x5FC8C2/0x5FC902`; config blob `SphereHeight` VA `0x7ABC44/0x7ABC5C`. Until then no `sub_*` cited. |

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. Newly resolved items (doprogress first-camera wire + args, Home hotkey, origin move, flag producer/consumer, CODE zero/positive tables with VAs, .map record layout, multi-site camera-init census) rest on donor TEXT/BYTES with `file:line` / `fileoff`+VA; open items name exact captures in §6.
- No number invented: no camera target/zoom/pitch/facing constant (not 0.75, not 58-as-target — 58 is a clamp limit), no start-separation distance, no fixed-fraction slot coordinates, no peasant count other than 18 on the default path.
- Correction to prior work: DEC-U-START-POSITIONS §6 EV-CAM-1 "NO start→camera wiring" and §8 CAM-row are SUPERSEDED by §3 of this report (grep scope was `data/scripts`, missed `data/gui`). The prior ABSENT verdict for `initmapgen`/`dogenerate` file scope stands; the path-scope verdict flips to WIRED-VIA-DOPROGRESS.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + in-place byte searches with temp-only scratch (`codeterms/codecam/fullterms/mapscan` under approved temp, never committed). Donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: no net branches cited beyond exclusion.

*End of DEC-U-START-DEEP.*
