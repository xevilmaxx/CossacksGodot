---
title: "DSEL-01 — Donor drag-box (selection rectangle) unit selection: full script/config/binary recon"
area: "donor truth → Godot 4 variant3d drag-select parity"
owner: DSEL-01
updated: 2026-11-25
status: READ_ONLY_DONOR_RECON__4_PASSES__NO_CODE_EDIT
id: DSEL-01
donor: "C:\\Games\\Cossacks 3 (read-only; Python bytes/latin-1 for text, raw byte-string census for cossacks.exe; never executed, never copied into repo)"
scope: "Exactly ONE file written — this report. No game code, shared file, asset, config, test or git edit. No Godot run."
labels: [observed, derived, inferred, UNVERIFIED]
passes:
  - "P1 — orientation docs (required list) read before any donor claim"
  - "P2 — full-tree keyword grep over data\\scripts + data\\gui + all .cfg/.global/.lib/.aix, then full reads of every hit-bearing selection file"
  - "P3 — independent EXE byte-string census of cossacks.exe for the GameManager/selection API signatures and picking-mode enum"
  - "P4 — read-only port comparison (app/scripts + variant3d/scripts) against DSEL-02 and V3D-01 sibling reports"
output: docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md
---

# DSEL-01 — Donor selection rectangle / drag-box unit selection

> [!NOTE]
> **Reading convention.** Donor GUI scripts (`data\gui\menu.inc\*.inc`,
> `data\gui\common.inc\*.inc`) store their executable code as a string-literal
> block, so every code line in the file is prefixed `[*] = ;`. Those lines are
> **live script code**, not comments: `gui\menu.aix:91-94` registers
> `OnMouseHook` → `.\data\gui\common.inc\onmousehook.inc`, and
> `gui\menu.cfg:2,11,15-16` binds the states. Citations below use the physical
> line number in the file as read (prefix included where quoted). All donor
> paths are relative to `C:\Games\Cossacks 3`.

## Goal

Recover the donor's exact drag-box selection behaviour from primary evidence:
drag threshold, rectangle start/end events, left-button down/move/up handling,
what is selected (unit types, friendlies/enemies, walls/gates/buildings),
additive selection (Shift), double-click, drag-select of your own army,
selection visual feedback (aura/markers), selection sounds and selection
constants. Determine the coordinate system and the screen-space → world-space
inside-box rule, cross-check every important claim by a second method, and give
the variant3d Godot port a concrete donor-grounded fix recipe. Nothing in the
repo was edited.

## Sources read

**Orientation (context, not truth), all read first:**
`docs/coord_swarm_2026-11-24/reports/FIXSEL_picking_orders.md`,
`.../FIXSEL_visuals.md`, `.../V712_picking3d.md`, `.../V768_picking_fix.md`,
`.../G31_donor_3d_truth.md`, `docs/audit/RENDER_ARCH_CAMERA.md`,
`docs/audit/MICRO.md`. Sibling reports read for cross-check only:
`docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md`,
`.../V3D_01_selection_rectangle_audit.md`.

**Donor text freshly read this session (Python `open(...,'rb').read().decode('latin-1')`, numbered lines):**

| Donor path | Why |
|---|---|
| `data\gui\menu.cfg` | state-machine bindings, `KeyDoubleDelay` |
| `data\gui\menu.aix` | state → `.inc` file registration |
| `data\gui\menu.inc\onmousedown.inc` | LButton down/up, click vs drag, double-click, shift/ctrl |
| `data\gui\menu.inc\onmousemove.inc` | LMB-held drag threshold, rectangle start |
| `data\gui\menu.inc\onselection.inc` | `OnSelection` post-filter of engine-picked objects |
| `data\gui\menu.inc\doupdateselection.inc`, `onclear.inc`, `onmousedown.inc`, `onshortcut.inc` | highlight update, clear, hotkeys |
| `data\gui\menu.inc\docreate.inc`, `dodestroy.inc`, `showunitcontrol.inc`, `eventsettings.inc`, `showsettings.inc` | engine selection flags, selection sounds, settings |
| `data\gui\common.inc\onmousehook.inc` | GUI hook (no rectangle draw here) |
| `data\scripts\lib\control.script` | `_control_GetUnitUnderCursor` ray-AABB pick, selection helpers |
| `data\scripts\lib\gui.script` | `_gui_UpdateHighlights` — aura/marker materials |
| `data\scripts\lib\misc.script`, `init.script`, `classes.script`, `profile.script`, `sound.script` | selection helpers, engine settings, highlight size, sounds |
| `data\scripts\dmscript.global`, `dmscript.source` | cursor priorities, highlight setting, sound indices, state vars |
| `data\resources\resource.lib`, `data\brushes\selection.cfg` | selection brush binding + line style |
| `data\game\var\hotkeys.cfg` | select-* hotkeys |
| `data\brushes\textures\selection.*.dds`, `data\sounds\interface\select*.ogg` | filesystem cross-check of materials/sounds |

**Donor binary (read-only byte-string census, `cossacks.exe`, 5,768,048 B):** the
embedded script-VM API declaration block proves the engine-side selection
contract (offsets in the claim table).

**Port, read-only (divergence section only):**
`app/scripts/input_controller.gd`, `app/scripts/world.gd`,
`variant3d/scripts/input_controller.gd`, `variant3d/scripts/world3d.gd`,
`variant3d/scripts/world3d_fx.gd`.

## Claim table

Labels: **observed** = literal donor line / binary header / filesystem fact;
**derived** = control-flow or arithmetic consequence of observed lines;
**inferred** = plausible reading with stated caveat; **UNVERIFIED** = native
code not readable from scripts/config. Verdicts use the audit convention
(CONFIRMED / PARTIAL / UNVERIFIED).

| Claim | observed / derived / inferred | Donor `path:line` or evidence id | Verification method | Verdict |
|---|---|---|---|---|
| 1. Drag threshold is `epsilon = 0.005` in **world metres**, raised to `0.25` when attack-point or guard mode is active | observed | `data\gui\menu.inc\onmousemove.inc:32-34`, `:152` | P2 full-file read + P2 keyword grep + DSEL-02 claim 11 (independent pass) | **CONFIRMED** |
| 2. Threshold is **axis-wise** on world X/Z: `Abs(x-prevSelX)>epsilon or Abs(z-prevSelZ)>epsilon`; `x,z` come from `GetCurrentMouseWorldCoord` (ground ray hit) | observed | `onmousemove.inc:66-69`, `:141-147`, `:152` | full read; `GetCurrentMouseWorldCoord` API cross-checked in EXE (DSEL-02 claim 7) | **CONFIRMED** script-side; native unproject UNVERIFIED |
| 3. Rectangle start is recorded on the **first LMB-held mouse-move**, not on mouse-down: `gbool_gui_isselectionstarted := true; gfloat_gui_prevselmousex/z := x/z` | observed | `onmousemove.inc:138-147` | full read + grep for `isselectionstarted` (only 3 hits: `dmscript.global:2226`, `onmousemove.inc:142,144`, `onmousedown.inc:365`) | **CONFIRMED** |
| 4. On threshold crossing the engine mode starts: `GameManagerBeginSelection` then `GameManagerStartSelection('spmAdd')` if Shift else `'spmRunTime'`; then `ExecuteState('DoUpdateSelection')` | observed | `onmousemove.inc:150-165` | full read + EXE signatures `GameManagerBeginSelection` @`0x29F7F0`, `GameManagerStartSelection(const smode:String)` @`0x29F744`; `spmAdd`/`spmRunTime` enum strings @`0x111248`/`0x11123D` | **CONFIRMED** |
| 5. Drag-time Ctrl→`spmRemove` is deliberately **commented out**; only `spmAdd` and `spmRunTime` are live in the drag path | observed | `onmousemove.inc:159-161` | full read + full-tree grep for `spmXor/spmNot/spmClear` → only the comment at `:162` | **CONFIRMED** (negative search) |
| 6. Rectangle ends on LMB-up: `gbool_gui_isselectionstarted := false`; if `GameManagerIsSelectionMode` → `GameManagerCancelSelection` and UI flags (unitcontrol, rallypoints, cursor, sound-request) are set | observed | `onmousedown.inc:364-390` | full read + EXE `GameManagerCancelSelection` @`0x29F788`, `GameManagerIsSelectionMode` @`0x29F7B8` | **CONFIRMED** |
| 7. Engine calls back into script state `OnSelection` after processing the rectangle; double-click delay is `KeyDoubleDelay = 0.5` (s); `KeyRepeatDelay = 0.05` | observed | `gui\menu.cfg:15-18,32-33`; `gui\menu.aix:159-162`; `onselection.inc:1-2` | direct config read + state registration in `.aix` + file-name match | **CONFIRMED** |
| 8. Engine rectangle filters: `SetGameManagerSelectionSettings(false, true, true, true)` = pickgroups=false, pickgamemanagerplayer=true, pickplayableObject=true, pickfrustum=true | observed (args) / derived (param names) | `scripts\lib\init.script:220`; param names from EXE `procedure SetGameManagerSelectionSettings(const pickgroups, pickgamemanagerplayer, pickplayableObject, pickfrustum: Boolean)` @`0x2A7164` | direct read + independent EXE string census; only one caller in whole tree | **CONFIRMED** as call; semantics of `pickfrustum` on oblique perspective UNVERIFIED |
| 9. Picking-mode enum has 7 values `spmNone, spmClear, spmXor, spmNot, spmRunTime, spmAdd, spmRemove` | observed | EXE @`0x11121E-0x111254` (`TXSelectionPickingMode` @`0x1111FA`) | byte-string dump + cross-check `onselection.inc:34` reads `GetGameManagerPickingMode='spmRemove'`; `control.script:28-29,108-109,426-427` use StartSelection | **CONFIRMED**; `spmXor/spmNot` have no script caller (UNUSED in scripts) |
| 10. `OnSelection` post-filter keeps only the interface player's **playable** objects (`TObj(pobj).pl=myPlInd` and `GetGameObjectPlayableObjectByHandle`), skips group handles | observed | `onselection.inc:34-43` | full read + duplicate player/playable guards in `control.script:181,183` | **CONFIRMED** |
| 11. Composition filter: buildings dropped when land units are selected; water units dropped when land units selected; guard units dropped when a non-guard unit exists | observed | `onselection.inc:12-16`, `:46-53` | full read + helper `_control_GetSelectionInfo` `control.script:361-407` computes the same four booleans | **CONFIRMED** |
| 12. Squads are selected as a whole: for a squad member, `TSquad.fSelected` is set and **every** member gets `SetGameObjectPickedByHandle(True)`; in `spmRemove` all members must be picked to deselect | observed | `onselection.inc:60-99`, `:75-86` | full read + `misc.script:6377-6385 _misc_SetSquadsSelection` | **CONFIRMED** |
| 13. Single click under cursor is an **engine 3D ray→AABB** test from camera absolute position to cursor ground point, sorted by ray-cast list, with priority ranking `relativeDst=(1+dist)/prio` and a final fog-of-war LOS check | observed | `control.script:156-274` (esp. `:164-165`, `:170-184`, `:258-272`) | full read + EXE signatures `GameObjectRayCastMouseRay` @`0x29D818`, `GetGameObjectRayCastAABBByHandle` (DSEL-02 claim 8) | **CONFIRMED** script-side; native AABB internals UNVERIFIED |
| 14. Cursor priorities: my=1, wood=2, food=3, stone=4, goinside=5, build=6, enemy=7 (higher priority wins ties) | observed | `scripts\dmscript.global:227-233`; used at `control.script:208-252` | direct constant read + all six use sites cross-checked | **CONFIRMED** |
| 15. Left-click selection calls `_control_GetUnitUnderCursor(True)` — **friendly only**; order/guard/cursor paths call it with `False` (enemies targetable) | observed | `onmousedown.inc:280`, `:394`, `:480`, `:683` | grep + full read + DSEL-02 divergence row "Click player filter" | **CONFIRMED** |
| 16. Single-click Shift adds (`_misc_AddUnitsToSelection`), Ctrl on an already-selected object removes (`_misc_RemoveUnitsFromSelection`); double-click **or Ctrl** selects all same-type units (`_misc_SelectAllUnitsOfType`) | observed | `onmousedown.inc:281-344`; `misc.script:6409-6448`, `:6452-6470`, `:6475+` | full read + EXE call chain; `onshortcut.inc:135` `GetGUIShiftStateDouble` | **CONFIRMED** |
| 17. Clicking empty ground with no modifiers deselects all; `OnClear` copies old picked objects into `gGuiSelectionHelper` for highlight diffing | observed | `onmousedown.inc:346-356`; `onclear.inc:4-11`; `onselection.inc:182-195` | direct reads of all three states | **CONFIRMED** |
| 18. Selection rectangle outline style: yellow `(1,1,0,1)`, solid (`LinePattern=65535`), `LineWidth=1`, `AntiAliased=False`, `LineStep=1`, `Visible=True`; bound via `SelectionBrushFileName=.\data\brushes\selection.cfg` | observed | `resources\resource.lib:47`; `brushes\selection.cfg:2-14` | full read of both + EXE `LineStep` @`0x110D5C`, `TXSelectionBrush` @`0x1103C5`, `XSelectionBrush` @`0x1103F9` | **CONFIRMED** |
| 19. Highlight material names `selection.friend`, `selection.building.<0..3>`, `selection.ship.<0..1>` (ship branch commented out), `highlight.friend/ally/enemy`; building size bucket from collision-mask bbox mid `(cw+ch)/2`: <5→0, <8→1, <12→2, else 3 | observed | `scripts\lib\gui.script:3372-3377`, `:3397-3463`; EXE `EffectHighlightGetOrCreate(hnd,key,visible,mat)` @`0x2DC8F4`, applied at `:3470` | full read + filesystem DDS check (`brushes\textures\selection.friend.dds`, `selection.building.dds`, `selection.building.small.dds`, `selection.ship.0/1.dds`, `selection.enemy.dds`) | **CONFIRMED** |
| 20. Highlight render size forced to `0.7` at init; highlights master setting `gc_settings_highlights = True`; `_gui_UpdateHighlights` is throttled by `gint_gui_progresstick` | observed | `scripts\lib\init.script:104-113`; `dmscript.global:1019`; `gui.script:3362-3370`; `doupdateselection.inc:4-17` | direct reads + DSEL-01 prior-doc note that donor glow is engine-side (`FIXSEL_visuals.md:24,80`) | **CONFIRMED** |
| 21. Highlight skips dead objects, birth-state objects and **walls** (`visible := False`); non-owned objects get friend/ally/enemy material by player masks; picked flag also updates the minimap primitive | observed | `gui.script:3393`, `:3399-3400`, `:3453-3469`, `:3472` | full read + `_unit_IsBuilding`/wall helpers in `control.script:326-341` | **CONFIRMED** |
| 22. Selection sounds: `gc_snd_ind_selectpeasant = 26`, `gc_snd_ind_selectship = 27`; `selectpeasant1..6` + `selectship` loaded and played on unit-control rebuild when peasants/ships are in the selection; building cues `bld<sid-suffix>` | observed | `dmscript.global:1276-1277`; `sound.script:206-208`; `showunitcontrol.inc:1015-1027` | direct reads + filesystem `sounds\interface\selectpeasant1..6.ogg`, `selectship.ogg` | **CONFIRMED**; played on panel rebuild, not a dedicated drag sound |
| 23. No script/config numeric drag threshold or rectangle-size constant exists outside `epsilon` (`onmousemove.inc:32-34`) and `KeyDoubleDelay` (`menu.cfg:33`); all rectangle→object geometry is native | observed (negative) / inferred (attribution) | full-tree scan of `data\**\*.cfg|*.global|*.script|*.inc|*.aix|*.lib`; EXE API block | P2 exhaustive scan + P3 byte census; camera configs contain no selection keys (G31 `§2a`, DSEL-02 claim 1) | **CONFIRMED** absence; native rule UNVERIFIED |
| 24. Exact inside-rect predicate (centre point vs AABB vs `GetGameObjectSelectionSizeByHandle` vs frustum) is **not readable** from scripts | UNVERIFIED | EXE `GameManagerStartSelection`/`GetGameManagerPickingMode` @`0x29F744`/`0x29F848`; `GetGameObjectSelectionSizeByHandle(gohandle):Float` @`0x240A30` | byte census shows API exists but body not read; no script call to size getter found | **UNVERIFIED** — do not invent a predicate |
| 25. Any entity outside the camera frustum cannot be rectangle-picked (`pickfrustum=true`), and groups are picked via squads rather than group handles (`pickgroups=false`) | derived | `init.script:220` + EXE signature @`0x2A7164` + `onselection.inc:40,60-99` | arithmetic/parameter-name control-flow derivation, two independent sources | **CONFIRMED** at setting level; native test order UNVERIFIED |
| 26. Keyboard select commands: Ctrl+Alt+A/Ctrl+Shift+A military, Ctrl+A all units, Ctrl+Q ships, Ctrl+B buildings, Ctrl+P/`` ` `` idle peasants, Ctrl+` all peasants, Ctrl+M idle mines, Z/Shift+Z/Ctrl+Shift+Z/Ctrl+Z same-type variants; `bselectallunitsonz` default False | observed | `game\var\hotkeys.cfg:154-206`; `onshortcut.inc:517-640`; `profile.script:32,260`; `classes.script:5114` | direct reads + settings UI `showsettings.inc:584,1136-1146` | **CONFIRMED** |
| 27. Port 2D/3D drag-select uses a **6 screen-pixel** threshold, a SIM-metre `Rect2` from two ground hits, and tests only `!dead && player==0 && kind=="unit"` via `rect.has_point(e.pos)`; Shift is ignored for the rectangle | observed (port) | `app/scripts/input_controller.gd:474-512,527-528`; `variant3d/scripts/input_controller.gd:608-647,662-663` | read-only port read + V3D-01 `§3,257-268` (independent audit) | **CONFIRMED** divergence |
| 28. Port 3D draws **no** rectangle: `world3d.gd` declares `sel_rect/sel_active` but has no draw consumer; 2D draws white outline+fill (`Color(1,1,1,0.9)` 1.5 px + `0.18` fill) | observed (port) | `variant3d/scripts/world3d.gd:126-127`; `world.gd:3641-3647`; V3D-01 `:248,257-268` | grep of all `variant3d/**/*.gd` + V3D-01 static audit | **CONFIRMED** |

## Detailed algorithm (donor pseudocode, reconstructed from observed lines)

```
# ---- GUI state wiring (gui\menu.cfg:2,11,15-16,28,32-33; menu.aix:159-162) ----
StateOnMouseMove          = OnMouseMove
StateOnClearSelection     = OnClear
StateOnProcessSelection   = OnSelection        # engine → script after rectangle
ProgressInterval          = 10                 # ms
KeyRepeatDelay            = 0.05
KeyDoubleDelay            = 0.5                # seconds (donor) vs port 0.35

# ---- engine selection settings, once at init (init.script:220) ----
SetGameManagerSelectionSettings(false, true, true, true)
#   pickgroups=false, pickgamemanagerplayer=true,
#   pickplayableObject=true, pickfrustum=true

# ---- LMB DOWN (onmousedown.inc:110-363) ----
if minimap_under_mouse: jump camera; exit                          # :116-131
if attackpoint|patrol|guard mode or editor placing: handle order/build; exit  # :144-145
if build_ghost_active (gint_gui_pickedbldhnd<>0): place building; exit        # :147-268
goHnd := _control_GetUnitUnderCursor(True)       # friendly only, ray-AABB      # :280
if bDouble or GUI_Ctrl:                                                        # :281
    _misc_SelectAllUnitsOfType(cid, id, True, False, GUI_Shift, squadSel)      # :288-291
elif goHnd <> 0:                                                               # :296
    if not Shift and not Ctrl: _misc_SetUnitsToSelection(pl, [goHnd])          # :301-302
    elif not already selected: _misc_AddUnitsToSelection([goHnd])              # :320-321
    elif Ctrl:                 _misc_RemoveUnitsFromSelection([goHnd] + squad) # :324-341
else:
    if not Shift and not Ctrl: _control_DeselectAllUnits(False)                # :346-355
ExecuteState('DoUpdateSelection')                                              # :359
# NOTE: LMB-down does NOT set gbool_gui_isselectionstarted; only motion does.

# ---- LMB HELD + MOVE (onmousemove.inc:63-170) ----
if MButton held: DoMBtnCameraControl
x,y,z := GetCurrentMouseWorldCoord(...)                                        # :68-69
epsilon := 0.005                                                               # :32
if attackpointmode or guardmode: epsilon := 0.25                               # :33-34
if editor placing units: ... (place at cursor, unrelated)                      # :71-137
else if not gWallCluster.buildWall:                                            # :140
    if not gbool_gui_isselectionstarted:                                       # :142
        gbool_gui_isselectionstarted := true                                   # :144
        gfloat_gui_prevselmousex := x;  gfloat_gui_prevselmousez := z           # :145-146
    else:
        if not GameManagerIsSelectionMode and not GameManagerIsBrushMode
           and gint_gui_pickedbldhnd = 0:                                       # :150
            if Abs(x-prevselmousex)>epsilon or Abs(z-prevselmousez)>epsilon:    # :152
                GameManagerBeginSelection                                      # :154
                if GUI_Shift: GameManagerStartSelection('spmAdd')              # :156-157
                else:         GameManagerStartSelection('spmRunTime')          # :162
                ExecuteState('DoUpdateSelection')                              # :164
# Ctrl → spmRemove branch is commented out at :159-161.

# ---- LMB UP (onmousedown.inc:364-390) ----
gbool_gui_isselectionstarted := false                                          # :365
if not bDouble and GameManagerIsSelectionMode:                                 # :375-377
    GameManagerCancelSelection                                                 # :379
    gbool_gui_update_unitcontrol := True; gbool_gui_update_rallypoints := True # :381-382
    gbool_gui_goinattackmode := False; gbool_gui_guardmode := False            # :384-385
    gbool_gui_attackpointmode := False; gbool_gui_patrolmode := False          # :386-387
    gbool_gui_update_cursor := True; gbool_gui_requestsoundonunitcontrol := True# :388-389

# ---- NATIVE (UNVERIFIED internals) ----
# GameManager fills GameManagerPickedObjects. Scripts can only read:
GetCountGameManagerPickedObjects / GetHandleGameManagerPickedObjects(i)
# EXE proves the API exists: @0x2A70D0 / @0x2A7110; selection brush is
# resources\resource.lib:47 → brushes\selection.cfg (yellow 1px solid line).
# Whether the native test uses screen rect, frustum, AABBs or
# GetGameObjectSelectionSizeByHandle (@0x240A30) is UNVERIFIED.

# ---- OnSelection POST-FILTER (onselection.inc:1-199) ----
rebuildGUI := GetGameManagerSelectionRebuildGUICommands
SetGameManagerSelectionRebuildGUICommands(false)
bpickRemove := (GetGameManagerPickingMode = 'spmRemove')                       # :34
_control_GetSelectionInfo(build, landUnit, waterUnit, nonGuard, True)          # :13
selUnit := landUnit; selWater := not landUnit and waterUnit
selBuild := not landUnit and not waterUnit
gSelectedObjects.Clear; gSelectedSquads.Clear; _misc_SetSquadsSelection(pl,false)
for i := CountGameManagerPickedObjects-1 downto 0:                             # :37
    goHnd := HandleGameManagerPickedObjects(i)
    if IsGroupByHandle(goHnd): continue                                        # :40
    pobj := _unit_GetTObj(goHnd)
    if pobj=nil or TObj(pobj).pl<>myPlInd or not Playable(goHnd): continue     # :43
    if (not selBuild) and bBuilding: SetGameObjectPickedByHandle(goHnd,False)  # :46-47
    elif (not selWater) and media=water: SetPicked(False)                      # :49-50
    elif selUnit and nonGuardExists and orders[0]=guard: SetPicked(False)      # :52-53
    else:
        if selUnit:
            if squad>=0: select whole squad; all members Picked(True)         # :64-99
            else: gSelectedObjects.Add(goHnd); SetPicked(True)                 # :135-136
        elif selWater and _unit_IsWaterUnit: squad branch                      # :141-159
        elif selBuild and _unit_IsBuilding: Add; SetPicked(True)               # :162-168
# diff old vs new picked into gGuiUpdateHighlights; rebuild GUI                # :182-195
ExecuteState('DoUpdateSelection')
```

**Click pick (not the rectangle), for contrast — `_control_GetUnitUnderCursor`
`control.script:156-274`:** engine ray list → `AABB(go, cameraPos, groundCursor)`
→ `(1+dist)/prio` minimum → FOW LOS. This path is used by left-click, orders,
guard target and cursor updates; the drag rectangle does **not** call it.

## Constants table

| Constant | Donor value | Unit / meaning | `path:line` | Label |
|---|---|---|---|---|
| `epsilon` (default) | `0.005` | world metres of X/Z mouse-ground movement to start a box | `onmousemove.inc:32` | observed |
| `epsilon` (attack-point / guard) | `0.25` | world metres | `onmousemove.inc:33-34` | observed |
| `KeyDoubleDelay` | `0.5` | seconds (donor double-click window) | `gui\menu.cfg:33` | observed |
| `KeyRepeatDelay` | `0.05` | seconds | `gui\menu.cfg:32` | observed |
| `ProgressInterval` | `10` | ms GUI tick (`_gui_UpdateHighlights` throttle) | `gui\menu.cfg:28`; `gui.script:3367` | observed |
| Selection settings | `(false,true,true,true)` | pickgroups / pickgamemanagerplayer / pickplayableObject / pickfrustum | `init.script:220`; EXE @`0x2A7164` | observed + derived |
| Selection modes | `spmNone, spmClear, spmXor, spmNot, spmRunTime, spmAdd, spmRemove` | native enum strings | EXE @`0x11121E-0x111254` | observed |
| Live drag modes | `spmRunTime` (replace), `spmAdd` (Shift-add) | `GameManagerStartSelection` argument | `onmousemove.inc:156-162` | observed |
| Highlight render size | `0.7` | global `SetHighlightRenderSettings` size | `init.script:106-113` | observed |
| Building highlight buckets | mid `(cw+ch)/2`: `<5→0, <8→1, <12→2, else 3` | collision-mask footprint class | `gui.script:3422-3438` | observed + derived |
| Highlight master | `gc_settings_highlights = True` | default on | `dmscript.global:1019` | observed |
| Line colour | `R=1, G=1, B=0, A=1` (yellow), width 1, pattern 65535, antialias false, step 1 | drag-box outline | `brushes\selection.cfg:3-14` | observed |
| Cursor priorities | my 1, wood 2, food 3, stone 4, goinside 5, build 6, enemy 7 | click rank divider | `dmscript.global:227-233` | observed |
| Collision radius default | `0.16` | world metres; used for editor placement step `3×`, unrelated to box threshold | `dmscript.global:972`; `onmousemove.inc:74` | observed |
| Sounds | `selectpeasant=26`, `selectship=27`; 6 + 1 OGG files | selection cue indices | `dmscript.global:1276-1277`; `sound.script:206-208` | observed |
| `gc_collision_radius_default*3` | `0.48` | editor-only unit placement distance gate (NOT drag threshold) | `onmousemove.inc:74`; `dmscript.global:972` | derived |

## What EXISTS in donor

- **Full drag-box state machine**: world-space threshold + start point on
  LMB-move, `GameManagerBeginSelection`/`StartSelection`/`CancelSelection`,
  script callback `OnSelection`, `OnClear`, `DoUpdateSelection`
  (`onmousemove.inc:32-34,141-167`; `onmousedown.inc:364-390`; `menu.cfg:15-16`).
- **Additive selection**: Shift → `spmAdd`; Ctrl → same-type select and
  single-click removal; native enum also has `spmXor`/`spmNot` (unused in
  scripts) (`onmousemove.inc:156-162`; `onmousedown.inc:281-344`; EXE enum).
- **Double-click**: `KeyDoubleDelay=0.5`; `bDouble` from engine
  `GetBoolValueByName('Double')`; Ctrl is an equivalent alternative;
  `GetGUIShiftStateDouble` also exists (`menu.cfg:33`; `onmousedown.inc:76,281`;
  `onshortcut.inc:135`).
- **Own-army drag-select**: engine setting `pickgamemanagerplayer=true`
  (`init.script:220`) + `OnSelection` player check (`onselection.inc:43`);
  enemies are targetable only through the click/order path
  (`onmousedown.inc:280` vs `:394,480,683`).
- **Composition-aware filtering**: land units > water units > buildings;
  guards dropped when non-guards present; whole-squad selection
  (`onselection.inc:12-16,46-99,141-168`).
- **Walls/gates/buildings**: buildings are a separate selection branch
  (`:162-168`); walls explicitly receive **no** highlight
  (`gui.script:3468-3469`); unbuilt buildings get a special cursor priority in
  the click path (`control.script:236-242`). There is no evidence of gates being
  separately handled by the rectangle (UNVERIFIED).
- **Distance / fog / alive filters**: engine `pickplayableObject=true`,
  `pickfrustum=true` (`init.script:220`); click path requires playable+visible+
  collision and FOW LOS (`control.script:181,270-272`); highlight skips dead and
  birth-state objects (`gui.script:3393,3399-3400`). The explicit dead check in
  `onselection.inc:57` is **commented out** — engine playable filter must cover it.
- **Visual feedback**: native yellow 1 px solid rectangle
  (`resource.lib:47`, `brushes\selection.cfg`); highlight materials
  `selection.friend`, `selection.building.<0..3>`, `highlight.friend/ally/enemy`
  with per-owner colour (`gui.script:3372-3472`), render size 0.7
  (`init.script:111`), minimap primitive updates (`:3472`), resource HUD
  markers with FOW blend 0.5 (`:3475-3529`).
- **Selection sounds**: `selectpeasant1..6`, `selectship`, building cues on
  unit-control rebuild (`showunitcontrol.inc:1015-1027`;
  `dmscript.global:1276-1277`).
- **Keyboard selection**: Ctrl+A/Ctrl+B/Ctrl+Q/Ctrl+P/Ctrl+M/Ctrl+` and the four
  Z variants (`hotkeys.cfg:154-206`; `onshortcut.inc:517-640`).

## What is MISSING from our port (donor is truth; 2D port secondary)

| Donor behaviour | 2D `app/` port | 3D `variant3d/` port | Gap verdict |
|---|---|---|---|
| Drag threshold `0.005` m world (`0.25` in attack/guard) | `6.0` **screen px** (`input_controller.gd:479,527`) | same 6 px copy (`input_controller.gd:613,662`) | **CONFIRMED divergence** |
| Rect start on LMB-move from world ground coords | start on LMB-down from pixels (`:474`), converted to sim on release (`:481-483`) | identical (`input_controller.gd:608,615-617`) | **CONFIRMED divergence** |
| Shift additive `spmAdd` on drag | Shift ignored in rectangle branch; `_set_selection(arr)` replaces (`:490`) | same (`input_controller.gd:624`) | **CONFIRMED divergence** |
| Inside-box test: native frustum/AABB/selection-size (UNVERIFIED exact) | `rect.has_point(e.pos)` — centre point only, sim metres (`:488`) | identical (`input_controller.gd:622`); no `picking3d._screen_of()` projection in drag path (V3D-01 `:166-172`) | **CONFIRMED approximation** |
| Land/water/building/guard/squad composition filter | only `!dead && player==0 && kind=="unit"` (`:486`) | same (`:620`) | **CONFIRMED gap** |
| `pickfrustum`/`pickplayableObject` filters | absent | absent | **CONFIRMED gap** |
| Own-player-only rectangle | `player==0` is hardcoded (matches) | matches for player 0 | aligned (but via port-only filter) |
| Yellow 1 px solid native box outline | white outline `Color(1,1,1,0.9)` 1.5 px + 0.18 fill (`world.gd:3641-3647`) | **no draw at all** — `sel_rect/sel_active` declared only (`world3d.gd:126-127`; V3D-01 `:248`) | **CONFIRMED gap** (3D) / style divergence (2D) |
| Highlight materials `selection.friend`, `selection.building.<0..3>`, `highlight.friend/ally/enemy`, size `0.7` | procedural sprite rings/auras (`world.gd:3011-3041,3252-3254` per `FIXSEL_visuals.md:16-22`) | procedural torus rings + 13 donor key colours (`FIXSEL_visuals.md:37-45`) — explicitly "NOT DONOR PARITY" | **PORT APPROXIMATION** (no material mapping) |
| Selection sounds `selectpeasant*`, `selectship`, building cues | no dedicated selection cue in dispatch table (`MICRO.md:65,354`) | same | **CONFIRMED gap** |
| Double-click `0.5 s`, `bselectallunitsonz` config | `0.35 s`, units only, `vp.has_point(u.pos*view_scale)` (`:493-501`) | same (`input_controller.gd:628-635`); 3D `view_rect` misses half-map shift (V3D-01 `:252`) | **CONFIRMED divergence** |
| Ctrl remove / Z hotkey 4-variant parity | partial (`MICRO.md:210-212`, rows 28/31) | same | **PARTIAL** |

Prior-doc corroboration: `FIXSEL_picking_orders.md:114-117` explicitly defers
selection visuals; `FIXSEL_visuals.md:6,24,80` declares procedural stand-ins and
engine-side donor glow UNMAPPED; `V712_picking3d.md:73-75` and
`V768_picking_fix.md:38,204` declare donor pick radius/depth engine-side
UNVERIFIED; `MICRO.md:210,328` records double-click 0.35 s / off-screen scope
as UNVERIFIED vs donor; `RENDER_ARCH_CAMERA.md:218-222` records picking breakage
risk under a Camera3D switch; DSEL-02 `:243` and V3D-01 `:410-433` independently
confirm the divergences above.

## Concrete fix recipe for the Godot variant (algorithmic steps — **no code edits made**)

1. **Keep the donor's two-phase start.** In `variant3d/scripts/input_controller.gd`,
   stop using the 6-px screen threshold as the *authoritative* drag trigger.
   On LMB press record the start **pixel** and its ground point
   (`picking.ground_point(mb.position)` — already used at `:555`); on LMB-held
   motion compute world X/Z delta and start selection mode only when
   `abs(dx)>0.005 or abs(dz)>0.005` (`0.25` if attack-point/guard mode active),
   mirroring `onmousemove.inc:32-34,141-167`. Keep the minimap preemption
   (`input_controller.gd:543-554,656-661`) — donor also exits for minimap
   (`control.script:161-162`).
2. **Test in screen space, not the SIM-ground rectangle.** The native donor
   rectangle selects with frustum/object-bounds; the current sim `Rect2` of two
   ground hits is nonlinear under the −32° perspective (DSEL-02 `§D`,
   V3D-01 `:250`). Add a rect-select method on the existing `picking3d` adapter
   (read-only, no `cmd_*`): build `Rect2(start_px, end_px).abs()` in viewport
   pixels; for each live entity use `_screen_of(sim, BODY_LIFT_M)`
   (`picking3d.gd:198-207,224-225`, `Camera3D.unproject_position()` — the frame
   FIX-SEL already proved at `FIXSEL_picking_orders.md:202-213`) and require the
   projected point **and** a footprint margin derived from `game.pick_radius(e)`
   to intersect the rect; reject entities with non-positive `_depth_of()`.
   Do not invent a donor literal for the footprint: label it PORT APPROXIMATION
   until the native predicate is recovered.
3. **Apply donor composition filters after collection.** Own player only
   (`player==0` at minimum; add `playable`/visible/FOW LOS if available);
   frustum membership; land units before water units before buildings; drop
   guards if non-guards present; collapse squads to `fSelected` + all members
   picked. This is `onselection.inc:12-16,43-53,60-99,141-168` translated,
   not the current bare `kind=="unit"` filter (`input_controller.gd:620`).
   Whether to include buildings/walls/gates in the 3D box is an owner decision:
   donor has a building branch but explicitly hides wall highlights
   (`gui.script:3468-3469`); keep them excluded until decided.
4. **Additive / finalize.** Shift on the drag → union with current selection
   (`spmAdd`); no Shift → replace (`spmRunTime`); on LMB-up finalize and set the
   same UI flags as `onmousedown.inc:377-389`. Ctrl-remove for the *drag* is
   commented out in donor (`onmousemove.inc:159-161`) — do not add it; keep
   Ctrl-remove only on single click (`onmousedown.inc:324-341`).
5. **Double-click parity.** Change the port's `0.35` s window to donor
   `KeyDoubleDelay = 0.5` (`menu.cfg:33`; port `input_controller.gd:628`), keep
   same-type selection, and fix the 3D `view_rect` half-map offset before using
   `vp.has_point(u.pos*view_scale)` (V3D-01 `:252`, DSEL-02 `:247`). Optional
   `bselectallunitsonz` toggle default False (`profile.script:32,260`).
6. **Draw the box in the donor's style.** The authoritative screen pixels live
   in `input_controller.gd`; add a `CanvasLayer`/`Control` overlay with
   `mouse_filter = MOUSE_FILTER_IGNORE` (precedent: FIX-SEL patrol overlay
   `FIXSEL_picking_orders.md:91-102,141-148`) and draw
   `Rect2(drag_start, current_mouse).abs()` as a **1 px solid yellow**
   `Color(1,1,0,1)` outline, no fill, matching `brushes\selection.cfg:3-11`.
   Do **not** project `world.sel_rect` through `camera3d.world_to_px()` — it is
   SIM metres while that helper expects centred metres (V3D-01 `:319-336`).
7. **Feedback / sounds.** Map selected entities to donor highlight material
   semantics (`selection.friend`, `selection.building.<0..3>` from collision
   mask mid, `selection.enemy/ally/friend`) in `world3d_fx.gd` alongside the
   existing FIX-SELECTVIS rings; keep rings as declared PORT APPROXIMATION since
   native glow is UNMAPPED (`FIXSEL_visuals.md:24,80`). On selection change,
   play `selectpeasant*` / `selectship` / `bld<sid>` equivalents
   (`sound.script:206-208`, `showunitcontrol.inc:1015-1027`) if port audio assets
   exist; otherwise document as missing rather than inventing.
8. **Verification recipe (no run performed here).** A 3-unit stub-game probe
   driving real `InputEventMouseButton` + `InputEventMouseMotion` events through
   `_unhandled_input()` must assert `selected_ids == [two inside units]`, the
   outside unit unselected, the box overlay present while dragging and cleared
   after release, and `game.cmd_*` counter 0 — per V3D-01 `:340-383`. The
   existing `uitest select_box` step calls `_set_selection()` directly
   (`uitest.gd:115-123`) and proves nothing about the real drag path
   (V3D-01 `:226-242`).

## Open questions

1. **Exact native inside-box predicate** — centre, AABB, frustum quad or
   `GetGameObjectSelectionSizeByHandle` (`EXE @0x240A30`)? Scripts never call
   the size getter; body not decompiled. **UNVERIFIED** (blocking for true parity).
2. **`SetGameManagerSelectionUseStep(true)`** (`docreate.inc:100`,
   `dodestroy.inc:28`) — likely incremental/stepped selection; native meaning
   **UNVERIFIED**. No script reads it back.
3. **`pickfrustum=true`** semantics on the −32° perspective view: is the test a
   screen rectangle, a projected frustum quad, or ground-corner rays
   (`onresize.inc:66-72`)? **UNVERIFIED**.
4. **Enemy inclusion by rectangle** — `pickgamemanagerplayer=true` +
   `onselection.inc:43` strongly imply own-only; no runtime confirmation.
   **UNVERIFIED** (donor cannot be run under this charter).
5. **Enemies/walls/gates** — walls have no highlight (`gui.script:3468`) and
   gates have no distinct script handling; whether a gate is a selectable
   building object in the native rect is **UNVERIFIED**.
6. **Highlight material binding** — DDS files exist for `selection.friend`,
   `selection.building(.small)`, `selection.ship.0/1`, `selection.enemy`, but
   the `highlight.friend/ally/enemy` material definitions were not found in
   plaintext data; likely engine-owned. **UNVERIFIED**.
7. **Double-click engine flag** — `menu.cfg:33` gives `KeyDoubleDelay=0.5`, but
   the native producer of `GetBoolValueByName('Double')` /
   `GetGUIShiftStateDouble` was not read. **UNVERIFIED**.
8. **`spmXor`/`spmNot`** exist in the EXE enum with no script caller — internal
   or dead? **UNVERIFIED**.
9. **Selection sound timing** — cues fire on unit-control rebuild
   (`showunitcontrol.inc:1015-1027`), not demonstrably on rectangle release;
   whether `gbool_gui_requestsoundonunitcontrol` (`onmousedown.inc:389`) triggers
   them for drag selection is **UNVERIFIED**.

## Summary

Across four independent passes — required orientation docs, exhaustive donor
text search plus full reads of every selection-bearing file, a raw EXE string
census of the native selection API, and a read-only port/sibling cross-check —
the donor's drag box is now pinned down: it starts on the **first LMB-held
mouse-move** once the cursor's **world ground** position has shifted more than
`epsilon = 0.005` m (`0.25` m in attack-point/guard mode), calls
`GameManagerBeginSelection` + `GameManagerStartSelection('spmAdd' on Shift,
else 'spmRunTime')`, is finalized by `GameManagerCancelSelection` on LMB-up, and
is post-filtered by the `OnSelection` state to the interface player's playable
objects with land/water/building/guard/squad rules. The native rectangle→object
predicate itself is engine-side (the EXE exposes the API, a selection brush
style and a selection-size getter) and remains **UNVERIFIED**, as do the exact
FOV/frustum maths; what *is* observable is the yellow 1 px native box outline,
the `selection.friend`/`selection.building.<0..3>`/friend-ally-enemy highlight
materials at render size `0.7`, the `selectpeasant*`/`selectship` sounds and the
`0.5 s` double-click window. The shipped 2D and 3D ports implement a 6-pixel
screen threshold, a SIM-ground `Rect2` centre-point test with no Shift,
no composition filters, no selection sounds, a 0.35 s double-click and a
white-filled box (no box at all in 3D); the fix recipe above replaces each of
those with a donor-grounded equivalent while flagging the native unknowns
instead of inventing values. No donor file was executed or copied; no repo
code, config, asset, test or git state was changed; exactly one report file was
written.
