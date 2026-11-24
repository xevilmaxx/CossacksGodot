---
id: DEEPDEC-08
scope: "Donor HUD / minimap / hotkeys / selection UI — whole-file static evidence in cossacks.exe (shared target t_87f0f3c130b0) + read-only donor GUI/script text; map to app/scripts/hud.gd + variant3d HUD/input/camera/world"
date: 2026-11-24
status: AUDIT_COMPLETE__RUNTIME_PARITY_UNVERIFIED
labels:
  PROVEN: "directly read at cited path:line, VA/file offset or evidence id"
  INFERRED: "reading of PROVEN code, not runtime observation"
  UNVERIFIED: "no readable donor/port evidence; no claim made"
rules_kept: "read-only donor; no Frida/runtime/unpacking/executing; no target_open/select; no source/asset/config/test/git edits; one report only"
---

# DEEPDEC-08 — Donor HUD / minimap / hotkeys / selection UI

## 0. Method and tooling

- Craft Anything (deep mode, shared target `t_87f0f3c130b0`, `cossacks.exe`, sha256
  `87f0f3c1…16c`, 5,768,048 bytes): `enable_toolset("native")`, `core_session_show`,
  `core_investigation_show`, `native_bytes_find` (**whole file**, UTF-8 + UTF-16LE),
  `core_feature_find`, `native_function_find`, `native_function_show`,
  `native_function_study`, `native_address_show`, `native_functions_list`.
- Donor text read read-only from `C:\Games\Cossacks 3\data\...` via the `read` tool
  (exact line numbers) and scoped `grep`. No donor binary was copied.
- Port text read read-only from `app/scripts/` and `variant3d/scripts/`.

**Important reproduceable observation (binary search).** Data-section-only search is a false
negative here: `core_feature_find("ScreenToWorldRayCast")` returns **0 strings, 0 function names,
0 imports, 0 functions** (`ev_3f5b5514025492812556fdbd622594ed43da7a3a1d09400b7bdd73effd4294a3`),
yet whole-file `native_bytes_find` finds the literal at VA `0x69e45a` (file `0x29d85a`, section
`CODE`). Same for `GetGUIMinimapUnderMouse` (`0x66db22` / `0x26cf22`), `GetCurrentMouseWorldCoord`
(`0x66daa2` / `0x26cea2`), `SetMainCameraMoveToTargetXZ` (`0x5fc902` / `0x1fbd02`),
`IsKeyDownByName` (`0x66a916` / `0x269d16`), `GetGUIEventMouseWheelDelta` (`0x673a06` / `0x272e06`),
`GetCameraRestrictInfo` (`0x5fe772` / `0x1fdb72`), `AddCameraInfo` (`0x5fd84e` / `0x1fcc4e`).
`core_feature_find("MiniMap")` finds only one data-section string `_XMiniMap` @ `0x958d01`
with no references (`ev_ab7397bb9afd567e7200bc839e7110ad1d65ca11723ef1eb948e097b90e9b2ca`).
Whole-file `MiniMap` has **61** matches (CODE VAs incl. `0x5da83a`, `0x611f7f`, `0x611fa0`,
`0x61552a`, `0x669848`, `0x669842` = `GetGUIMiniMapVisible`, `0x669b8d`…).
`hotkeys.cfg`, `gCtrlGroups`, `patrolmode`, `GetGUIShortcutPressed` have **0** whole-file literal
matches — these are external config paths / script-side variables, not proof of absent features.

**Function-level limit.** `native_function_find` at `0x69e45a` and `0x66db22` reports "not inside
any discovered function" (`ev_0b2fd781432777010f26a2d0a5020ee75cf67713c6733e82fbaae8af9e7cf6ba`,
`ev_f51449104708c6532b7707fc0cbfba10c30d84cd47ebd61a4651e597026da01b`). This is consistent with
the shared engine's known limits: 18,918 functions, discovery stopped at 6,000,000 instructions,
1,238 unresolved indirect jumps, stripped names (`ev_2d2c8d222271cc791d4aacdf0fc0e075e9b387faad67e0cbe6643cd758b1e11f`).
`0x5fc902` **is** inside `sub_5fc2d0` (`ev_b17317e942c72e654f47adcbb02ae0b4af2ca7122ca`),
a 2,698-block / 5,583-instruction, 0-caller, 70-callee, 97-outgoing-reference thunk-like body with
0 referenced data strings (`ev_b444c76210fb32525d57e2a1423472fe2b508b479f45fb08a95243dd5cc3bfa4`,
`ev_b0c3f4c4891f313fa0f73e67516af47ffa78facc2f4d08936ba2335dca27e96e`): consistent with an
engine script-API name/registration table whose names live in CODE, not `.rdata`. **INFERRED** —
no decompiled implementation of the camera/minimap API was recovered; the donor *script* text
below is the authoritative behavioural source.

---

## 1. Evidence table

| # | Status | Finding | Source (path:line / VA / evidence id) |
|---|---|---|---|
| E1 | PROVEN | Minimap LMB routes through `EventMinimap` with `Tag=10` down, `20` repeat, `30` up; RButton up fires `RButton` then `RButtonUp` then `GameManagerCancelBrush` | `data/gui/menu.inc/eventminimap.inc:8-55` |
| E2 | PROVEN | Minimap LMB (non-double) calls `_control_GetMoveCameraToPositionOffset(x,y,newx,newy)`, `SetCameraElasticTargetObject(0)`, `SetMainCameraRotateToTargetDir(false)`, `SetMainCameraMoveToTargetXZ(newx,newy)`; double-click uses `_control_MoveCameraToPosition(x,y,0,False)` | `data/gui/menu.inc/onmousedown.inc:116-131` |
| E3 | PROVEN | Exact camera target offset math (see §2) | `data/scripts/lib/control.script:574-613` |
| E4 | PROVEN | Double-click / instant variant of same math writes `CameraInfoSaveWithProperties` + `CameraInfoLoadToCurrentView` + `SetCameraDepthOfView(dov)` | `data/scripts/lib/control.script:618-665` |
| E5 | PROVEN | Minimap event `X`/`Y` are consumed directly as **world X/Z**, not as pixels: used for move-arrow target and group target | `onmousedown.inc:618-624`, `:788-801` |
| E6 | PROVEN | `camera.cfg` constants feeding E3: `SphereLengthMin=20`, `SphereLength=58`, all four `…Angle=-32` | `data/cameras/camera.cfg:2-11,30-40` |
| E7 | PROVEN | Camera keys: `keySpeed=gProfile.keyscrollspeed*4`, `mouseSpeed=gProfile.mousescrollspeed*4`; arrow tags 20/21/22/23 + corners 24-27; direction vectors summed and pushed via `SetCameraElasticMoveDirection`; tag 30 (up) calls `SetCameraElasticMoveTurnOff` | `data/gui/menu.inc/oncamera.inc:10-11,18-27,37-58,60-76`; `registershortcuts.inc:8-17` |
| E8 | PROVEN | Edge bands: 8 px sides, 24 px corners, tags 20-27, cursor names | `data/gui/menu.inc/cameracontrol.inc:12-35` |
| E9 | PROVEN | Wheel: `wheelDelta = -(delta/60)*(wheelspeed*0.5+0.25)*2`; `ZoomCamera(0,…)` clamps height to `[minHeight,maxHeight]`, forces `-32°` tilt, then `SetMainCameraMoveToTargetXZ(newx,newy)` | `data/gui/common.inc/onmousewheel.inc:29-80,288-303` |
| E10 | PROVEN (dead code) | `GetCameraPositionExt` maps minimap cursor to a camera position with `koef=(ty-20)/(49+tarY)`, `offsetZ=Lerp(28.565,78.42125,Lerp(0,1.6897,koef))`, `x:=tx; y:=tz-offsetZ`; its only callers are commented out | `onmousewheel.inc:82-107`, `:305-310`; `camera.cfg:5` (old `SphereHeight=49`) |
| E11 | PROVEN | Hotkey table source is `data/game/var/hotkeys.cfg`: 55 `Key`/`Action` records (counted); `registershortcuts.inc` loads save-dir override else `gc_filepath_hotkeys_default`, maps `Repeat→spiRepeat`, `Up→spiUp`, else `spiDown`, registers `AlternativeKey` as `action+'|alt'`, tag `-1` | `data/game/var/hotkeys.cfg:1-243`; `data/gui/menu.inc/registershortcuts.inc:187-221` |
| E12 | PROVEN | Custom-hotkey dispatch splits `category|action` and handles `event/build/unit/squad/interface/select/upgrade`; tag `-1` selects this path | `data/gui/menu.inc/onshortcut.inc:197-665` |
| E13 | PROVEN | Control groups: `N` selects `gCtrlGroups[plInd][num]`, double-click recentres; `Ctrl+N` toggles bit `1 shl num` (XOR old, OR new incl. squads); `Shift+N` OR-adds only when bit unset | `onshortcut.inc:668-704`, `:705-756`, `:757-806`; `registershortcuts.inc:84-91` |
| E14 | PROVEN | Patrol order: set `bstandground=False`, `bsearchenemy=True`, clear orders if shift not held, `_unit_OrderPatrol(goHnd, ownX, ownZ, trgx, trgz)`, network `gc_obj_order_type_patrol`; issued on LMB-up in patrol mode | `onmousedown.inc:38-69`, `:404-411`; `onshortcut.inc:400-403` |
| E15 | PROVEN | Patrol is **button-only** in donor: `hotkeys.cfg` has no `unit|patrol` entry and `registershortcuts.inc:70` (`P` patrol) is commented `//TOHOTKEYS//`; unit-control tag `cTagControlPatrol=305` | `hotkeys.cfg:83-143`; `registershortcuts.inc:66-71`; `showunitcontrol.inc:91` |
| E16 | PROVEN | RMB order decision tree (attack enemy, gather res, build, go-inside, move/stretch brush); minimap RMB supplies target X/Y from the event | `onmousedown.inc:445-637`, `:638-901` |
| E17 | PROVEN | Selection filtering: `_control_GetSelectionInfo(building, unit, water, nonGuard)`; drops buildings/water/guards depending on mode; squads selected as a unit; flags for peasant/drummer/bagpiper/officer | `data/gui/menu.inc/onselection.inc:10-175`; `doupdateselection.inc:4-19` |
| E18 | PROVEN | LMB click selection/double-click/ctrl/shift rules; double-click or Ctrl selects all of type; shift toggles add/remove; empty click deselects | `onmousedown.inc:280-362` |
| E19 | PROVEN | Drag selection is engine-side (`GameManagerIsSelectionMode`, `GameManagerCancelSelection`, `gbool_gui_isselectionstarted`); script has no rectangle geometry/z-order | `onmousedown.inc:364-390`; `onmousemove.inc:5-30` |
| E20 | PROVEN | HUD widgets: resource panel with 6 counters, `(workers)` income, "lot of resources" and low-food text, idle-peasant/idle-mine/objectives buttons; tooltips from locale `resourcepanel.*.hint` | `data/gui/menu.inc/showresourcepanel.inc:28-42,44-125`; `eventresourcepanel.inc:16-42` |
| E21 | PROVEN | Unit-control panel button/tag vocabulary (rally, hold, attack flags, patrol/guard, squad fill/disband/formations, market, gates, unload) | `data/gui/menu.inc/showunitcontrol.inc:73-107` |
| E22 | PROVEN | Minimap widget: 240×240, bottom-left, border in player colour, zoom 1, layer 3, frustum visible, press event `EventMinimap`, primitives `lens`, `pl2x2/3x3.*`, `cross1x1`, `ptborder` (atlas UVs) | `data/gui/menu.inc/initminimap.inc:5-39`; `data/gui/minimap.cfg:2-27,28-723,724-816` |
| E23 | PROVEN | Port already has 3D `jump_to_world` + minimap 3D branch; journey camera and Shift+number recentre were also already routed through it | `variant3d/scripts/camera3d.gd:341-350`; `variant3d/scripts/hud.gd:1402-1454`; `variant3d/scripts/input_controller.gd:843-846`; `variant3d/scripts/main.gd:1645-1651` |
| E24 | PROVEN | Port patrol is two-click waypoints (`P`) plus instant ±6 m (`Q`), with a route overlay | `variant3d/scripts/input_controller.gd:308-331,364-371,884-887,1040-1044` |
| E25 | PROVEN | Port minimap is tile→metre via mouse fraction and displays a camera-derived box through `hud3d_adapter` | `variant3d/scripts/hud.gd:1403-1404,1462-1491`; `hud3d_adapter.gd:32-76` |

---

## 2. Exact minimap click → camera math (PROVEN, literal donor code)

Chain: `eventminimap.inc:11-17` sets `Tag=10`, `Name='LButton'`, `gfloat_gui_movecamerax := x`,
`gfloat_gui_movecameraz := y`, then `ExecuteState('OnMouseDown')`.
`eventminimap.inc:29-34` repeats the same call with `Tag=20` for drag; `:41-43` with `Tag=30` on up.

`onmousedown.inc:116-131`:
```
if (GetGUIMinimapUnderMouse) then begin
  x := GetIntValueByName('X');  y := GetIntValueByName('Y');
  if bDouble then _control_MoveCameraToPosition(x, y, 0, False)
  else begin
    SetCameraElasticTargetObject(0);
    _control_GetMoveCameraToPositionOffset(x, y, newx, newy);
    SetMainCameraRotateToTargetDir(false);
    SetMainCameraMoveToTargetXZ(newx, newy);
  end;
end;
```
`data/scripts/lib/control.script:574-613` (`dstX=x`, `dstZ=y`; `@movecamera` camera info):
```
minHeight := RestrictInfo.SphereLengthMin      (=20, camera.cfg:10)
maxHeight := RestrictInfo.SphereLength         (=58, camera.cfg:9)
CameraInfoSaveFromCurrentView('@movecamera');
CameraInfoReadProperties(camera, tx, height, tz, cx, cy, cz);

angleZ := -Lerp(minHeightMaxAngle, maxHeightMaxAngle,
                Clamp((height-minHeight)/(maxHeight-minHeight), 0, 1));
dx := cx - tx;  dz := 0.1;
VectorRotateX(dx, dy, dz, angleZ);

offZ := ArcTan(angleZ) * height;
angleX := VectorAngle(0, 0, 1, dx, 0, dz);
if dx < 0 then angleX := -angleX;
VectorRotateY(offX, tmp, offZ, angleX);

newX := dstX + offX + dx;
newZ := dstZ + offZ + dz;
```
`SetMainCameraMoveToTargetXZ(newx, newy)` then moves the **target** (elastic), preserving height.

With `camera.cfg:32-35` all four angles = `-32`, `angleZ = +32` for every height
(**INFERRED** from the literal `Lerp/Clamp` read; no runtime evaluation). Units of `ArcTan`
(deg vs rad) are engine-internal and **UNVERIFIED** — `ArcTan` is not defined in any donor
script (`grep` over `data/scripts` finds only its four call sites at `control.script:602,653`
and `misc.script:6279,6283`), so no numeric offset is asserted.

**Double-click** (`control.script:618-665`): identical offset math, but with
`SetCameraInfoSmoothingTime(0)`, `SetCameraInfoSmoothingChange(false)`, optional
`height := maxHeight` only when `bSetMaxHeight` (false here), then
`CameraInfoSaveWithProperties(camera, dstX+offX, height, dstZ+offZ,
dstX+offX+dx, height+dy, dstZ+offZ+dz)`, `CameraInfoLoadToCurrentView`, `SetCameraDepthOfView(dov)`
— i.e. an immediate, non-elastic relocation.

**PROVEN that `x`/`y` are sim-metres, not pixels:** the same `GetIntValueByName('X')/'Y'` are
assigned to `gfloat_gui_movearrowx/z` (`onmousedown.inc:618-624`) and to `grX/grY` group target
positions (`:788-801`) and consumed as world coordinates.

**Drag behaviour:** no rectangle/stretch on the minimap — repeat events each re-run the same
target computation with the new cursor world coordinate (`eventminimap.inc:26-34`). The older
time-based variant (`Tag 10/20/30`, `SetCameraElasticMoveFactor(1)`, `_control_MoveCameraToPosition(x,y,time,False)`)
is commented out at `onmousedown.inc:125-141`.

**Contrast with port (PROVEN):** `variant3d/scripts/camera3d.gd:341-350` sets `_target = world_pos`
and applies the transform directly; no `cx-tx`, `dz=0.1`, `ArcTan(angleZ)*height`, heading rotation
or double-click distinction exists. The port centres the clicked point; the donor keeps the
camera's pre-existing offset from its target. This is a **donor-grounded framing difference**, not
a proven bug (whether it matters visually is UNVERIFIED without runtime A/B).

---

## 3. Donor HUD widget → port mapping

| Donor widget / behaviour (path:line) | app/scripts/hud.gd | variant3d/scripts/hud.gd + others | 3D verdict |
|---|---|---|---|
| Resource counters `(workers)` + income/hints (`showresourcepanel.inc:28-42,101-125`) | `:313-396`, `:1144-1217`, `RES_TOOLTIPS` `:104` | `:347-415`, `:1178-1251` | **PARITY** (code ported; donor text labels differ) |
| Idle-peasant / idle-mine buttons → `EmulateGUIShortcut('select|idlepeasants'/'select|idlemines')` (`eventresourcepanel.inc:35-36`) | `:341-350`, `:437-447` | `:375-384`, `:471-481` | **PARITY** |
| Hints/tooltips (`showresourcepanel.inc:28-42`, `onhint.inc`) | `tooltip_text` at `:335,346,350,…` | `:369,380,384,…` | **PARITY (partial)** — builder/unit tooltips ported; engine `onhint` timing/style UNVERIFIED |
| Unit-control buttons + tags (`showunitcontrol.inc:73-107`) | `:491-716` `_unit_button`/`refresh_selection` | `:525-749` | **PARITY (subset)** — attack/stand/fire/patrol/guard/stop/squad/market/gate/unload present; artillery prep, officer size +/-, squad-group button not found |
| Unit counts / selection summary (`onselection.inc:10-175`; `doupdateselection.inc:14-17`) | `:896-948` `_selection_summary` | `:930-983` | **PARTIAL** — donor squad/flag filtering (drummer/bagpiper/officer/water/guard) not mirrored; **UNVERIFIED** whether sim relies on it |
| Minimap 240×240 bottom-left, player-colour border, frustum (`initminimap.inc:5-39`; `minimap.cfg:2-27`) | `:1306-1366`, box `:1394-1421` | `:1340-1400`, box `:1462-1491`, adapter `hud3d_adapter.gd:32-76` | **PARTIAL** — 200×200 canvas rect in port, box is camera-derived AABB; donor frustum is engine-drawn and **UNVERIFIED** (AUDIT3D-05 E12) |
| Minimap blips/primitives (`minimap.cfg:28-723`) | `_update_minimap`/`_mm_paint_box` | same, unchanged | **PARTIAL** — port paints terrain+blips; donor atlas primitive set and player-colour keying not byte-matched |
| Minimap LMB jump (`onmousedown.inc:116-131`) | `camera.gd:96-104` | `hud.gd:1402-1454` → `camera3d.gd:341-350` | **DIVERGENT** — see §2 (offset math missing, double-click missing) |
| Minimap RMB order (`eventminimap.inc:45-54`; `onmousedown.inc:445-637`) | `hud.gd:1378-1382` → `ictl.minimap_order` | `hud.gd:1418-1422` (unchanged) | **PARITY at cmd layer**; donor drag-orders on minimap (`onmousedown.inc:788-801`) **UNVERIFIED** in port |
| Camera keys + edge bands (`oncamera.inc`, `cameracontrol.inc`) | `camera.gd:166-244` | `camera3d.gd:259-329` | **PARITY** per AUDIT3D-05 E4; donor `keyscrollspeed*4`/`mousescrollspeed*4` literal not asserted in 3D |
| Patrol mode (`onmousedown.inc:38-69,404-411`) | `input_controller.gd` order layer | `input_controller.gd:308-331,884-887,1040-1044` | **DIVERGENT** — donor button-only + one target; port adds `P` two-click and `Q` ±6 m (port extensions, not donor-derived) |
| Patrol/journey overlay | `world.gd:350-351,3642-3644` | `input_controller.gd:93-97,364-371`; `world3d.gd:224-232` | **GAP P2** — `Node2D` under `Node3D` (AUDIT3D-05 E20). "Journey mode" is port-only (`main.gd:18,109,1282-1283`) — **no donor counterpart** |
| Control groups (`onshortcut.inc:668-806`) | `input_controller.gd` | `input_controller.gd:818-847` | **DIVERGENT** — donor `Shift+N` add-to-group and double-click-`N` recentre; port uses `Shift+N` for recentre and has no group 0 |
| Hotkey table (`hotkeys.cfg:1-243`) | `ConfigScript`/`Data.HOTKEYS` | `input_controller.gd:126-144,774-873,1015-1070` | **PARTIAL** — donor combos patched in at `:778-873`; config override/save path and rebind UI (`hotkeysettings.inc`) **UNVERIFIED** |
| Selection rectangle (`onmousedown.inc:364-390`) | `world.gd:3642-3644` | `world3d.gd:88-89` only | **GAP P2** — no 3D visual box (AUDIT3D-05 E10) |

---

## 4. Donor hotkey table (exact, `data/game/var/hotkeys.cfg`)

Source and registration are PROVEN at `hotkeys.cfg:1-243` + `registershortcuts.inc:187-221`;
validation/duplicate rules at `hotkeysettings.inc:25-160,162-223`; key-string assembly
(`Ctrl`/`Shift`/`Alt` prefix + `GetKeyNameByCode(tag)`) at `hotkeysettings.inc:228-261`.

Buildings: `C→build|%nat%cen` (`:4-5`), `H→hou`, `L→bla`, `B→bar`, `E→aca`, `S→sta`,
`R→art`, `D→dip`, `K→ba2`, `J→tem` (`:7-42`); `I/O/M/P/T→%com%mil/sto/mar/por/tow`
(`:43-74`); `%com%wwa`, `%com%swa` unbound (`:75-82`).

Unit/squad commands: `A→unit|attack` (`:85-86`), `S→standground` (`:89`), `C→nostandground`
(`:93`), `F→squad|fill` (`:97`), disband unbound (`:101`), `G→cancelguard` and `G→guard`
(both, `:105-111`), `E→enableattack` (`:113`), `D→disableattack` (`:117`),
`R→attackpoint` (`:121`), `J/K/L→squad|rank/column/square` (`:125-135`),
`Ctrl+S→unit|stop` (`:137-138`), `U→unloadall` (`:141-142`).
**No `unit|patrol` record.**

Interface/select (`:145-207`): `Alt+M→interface|minimap`, `Q→viewcollision`,
`Ctrl+Alt+A` (+ alt `Ctrl+Shift+A`, Repeat)→`select|militaryunits`,
`Ctrl+A`→allunits, `Ctrl+Q`→allships, `Ctrl+B`→allbuildings,
`Ctrl+P` / alt `` ` ``→idlepeasants, `Ctrl+\``→allpeasants, `Ctrl+M`→idlemines,
`Z`→unitsofsametype, `Shift+Z`→addunitsofsametype, `Ctrl+Shift+Z`→addallunitsofsametype,
`Ctrl+Z`→allunitsofsametype (all four Repeat=True). Menu keys `C/R/S/E/L/X/M→event|eventmainmenu|…`
with `Up=True` (`:208-242`).

Hardwired in `registershortcuts.inc` (not in hotkeys.cfg): arrows (`:8-17`), mouse buttons
(`:19-25`), `Space` (`:27-30`), `Escape/Return/Ctrl+Return/PrintScreen0-2/Alt+F4/F10`
(`:31-38`), `Pause/Ctrl+Shift+P`, `Sub/Add/-/=`, `PGUP/PGDN`, `Ctrl+PGUP/PGDN`, `Del`,
`Home/Ctrl+Home`, `C` attach camera (`:47-63`), `Shift/Ctrl/Alt` modifiers (`:74-79`),
groups `0-9`, `Ctrl+0-9`, `Shift+0-9` (`:84-91`), `Back`, many editor/debug combos (`:93-185`).
`//TOHOTKEYS//` lines at `:39-71` are disabled legacy registrations.

---

## 5. Donor behaviours still missing / divergent in 3D (ranked)

**P1 — donor-grounded divergence**
1. **Minimap target math** — donor offset/heading computation (`control.script:595-612`) and
   double-click instant jump (`:618-665`) are absent; port uses raw click (`camera3d.gd:341-350`).
   No invented constant needed: translate the literal formula and add a second arg for `bDouble`.
2. **Control groups** — `Shift+N` add-to-group (`onshortcut.inc:757-806`) and group-0 missing;
   port `Shift+N` recentres camera (`input_controller.gd:834-846`) and only handles 1-9 (`:819`).
3. **Patrol target semantics** — donor `_unit_OrderPatrol(ownX,ownZ,trgx,trgz)` with one target
   and stand-ground/search-enemy flags (`onmousedown.inc:38-69`); port uses two clicked waypoints
   plus a `Q` ±6 m shortcut (`input_controller.gd:308-331,1040-1044`). Whether the sim's
   `cmd_patrol` sets those two flags is **UNVERIFIED**.
4. **Selection filtering** — donor squad/water/guard/peasant/drummer/bagpiper/officer filtering
   (`onselection.inc:10-175`) not mirrored in the port summary (`hud.gd:930-983`).
5. **Hotkey rebind/override** — donor loads a user override from the save directory and supports
   `AlternativeKey`, `Repeat`, `Up` (`registershortcuts.inc:187-221`); port reads `ConfigScript`
   only (`input_controller.gd:126-144`) and hard-codes donor combos (`:778-873`).

**P2 — carry over from AUDIT3D-05, still applicable**
6. No 3D drag-selection rectangle (`world3d.gd:88-89`, AUDIT3D-05 E10).
7. Patrol route overlay is a `Node2D` under `Node3D` (`input_controller.gd:93-97,364-371`, E20).
8. Minimap frustum box is an AABB; donor frustum rotation/geometry engine-side, UNVERIFIED (E12).
9. Donor atlas primitive set (`minimap.cfg:28-723`) not byte-matched; port repaints blips.
10. `ArcTan`/`VectorRotate*` units and the exact donor projection matrix remain UNVERIFIED — do
    not hard-code a derived numeric offset until A/B runtime proof.

**Already closed since AUDIT3D-05 (PROVEN):** minimap 3D jump (V7-67 + `camera3d.gd:341`),
Shift+number recentre (`:843-846`), journey camera (`main.gd:1645-1651`). FOV remains an assumed
value (`camera3d.gd:51,120`).

---

## 6. Donor-grounded UI parity checklist for variant3d

`PROVEN` = donor and port code both read; `UNVERIFIED` = no readable evidence for one side.

- [x] PROVEN — minimap LMB down/drag repositions camera (`eventminimap.inc:8-34`; `hud.gd:1402-1454`)
- [ ] PROVEN GAP — minimap target uses donor offset math (`control.script:574-613`)
- [ ] PROVEN GAP — minimap double-click instant jump (`onmousedown.inc:121-122`; `control.script:618-665`)
- [x] PROVEN — minimap RMB issues order for selection (`eventminimap.inc:45-54`; `hud.gd:1418-1422`)
- [ ] UNVERIFIED — minimap RMB drag/stretch orders (`onmousedown.inc:788-801`)
- [x] PROVEN — arrow-key + edge-band camera (`oncamera.inc`; `cameracontrol.inc`; `camera3d.gd:259-329`)
- [x] PROVEN — wheel clamps height and emits `MoveToTargetXZ` (`onmousewheel.inc:296-303`; `camera3d.gd`)
- [ ] UNVERIFIED — exact FOV / projection / `ArcTan` units (`camera.cfg:44-45`; `camera3d.gd:51`)
- [x] PROVEN — resource counters/income/tooltips (`showresourcepanel.inc`; `hud.gd:347-415`)
- [x] PROVEN — idle-peasant/idle-mine buttons (`eventresourcepanel.inc:35-36`; `hud.gd:471-481`)
- [ ] PROVEN GAP — unit-control button subset (artillery prep, officer size, squad-groups tags)
- [ ] PROVEN GAP — donor selection filtering (`onselection.inc:10-175`)
- [ ] PROVEN GAP — 3D selection rectangle (`world3d.gd:88-89`)
- [ ] PROVEN GAP — patrol overlay under `Node3D` (`input_controller.gd:93-97`)
- [x] PROVEN — control groups 1-9 (`onshortcut.inc:668-756`; `input_controller.gd:818-827`)
- [ ] PROVEN GAP — `Shift+N` add-to-group and group 0 (`onshortcut.inc:757-806`)
- [ ] PROVEN GAP — `N` double-click recentres on group (`onshortcut.inc:700-701`)
- [ ] UNVERIFIED — donor hotkey user-override file/rebind UI (`hotkeysettings.inc`; `registershortcuts.inc:187-192`)
- [ ] PROVEN DIVERGENCE — patrol `P`/`Q` bindings are port extensions (`input_controller.gd:884-887,1040-1044`; no donor record)
- [ ] UNVERIFIED — "journey mode" is port-only (`main.gd:18,109,1282-1283`)

---

## 7. UNVERIFIED / BLOCKED and next atomic tasks

**UNVERIFIED:** numeric result of `ArcTan(angleZ)*height`; donor projection/sensor convention;
whether donor minimap frustum box rotates with camera; donor engine-side selection-rectangle
geometry; donor per-button art/atlas identity; runtime effect of any of the above in 3D.
No runtime instrumentation or donor code execution was used.

**Next atomic tasks (smallest, donor-grounded):**
1. Port `control.script:595-612` into `camera3d.gd` as an optional `jump_to_world(world_pos,
   b_double:=false)` offset/heading branch; keep existing one-arg callers working.
2. Give `hud.gd:1409` a double-click flag and call the two-arg API; keep RMB fall-through.
3. Add `Shift+N` add-to-group and group 0 in `input_controller.gd:818-847`; move camera recentre
   to double-click-`N` only (donor `onshortcut.inc:700-701,757-806`).
4. Re-check `_unit_OrderPatrol` / `game.cmd_patrol` stand-ground and search-enemy flags against
   `onmousedown.inc:47-51` before changing the port's patrol binding.
5. Project `world3d.sel_rect` and the patrol route through `camera3d.world_to_px()` into a
   `CanvasLayer` (AUDIT3D-05 E10/E20), with no new constants.
