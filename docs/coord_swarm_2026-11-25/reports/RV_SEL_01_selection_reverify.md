---
id: RV-SEL-01
title: "RV-SEL-01 — Independent donor re-verification: authoritative selection spec after conflict arbitration"
owner: RV-SEL-01 (third/fourth-pass independent donor re-verification worker)
date: 2026-11-25
status: READ_ONLY_DONOR_REVERIFY__NO_CODE_EDIT__NO_RUNNER__NO_DONOR_COPY
scope: "Exactly one file written — this report. No repo code/config/asset/test/scene/shader/git edit, no Godot run, no donor binary executed or copied."
donor: "C:\\Games\\Cossacks 3 — Python open(...,'rb').read().decode('latin-1') for text with computed byte offsets; bytes.count/find + printable context for cossacks.exe (5,768,048 B). Never executed, unpacked or copied."
labels: [observed, derived, inferred, UNVERIFIED]
method: ">=2 independent means per claim: fresh numbered line read with raw byte offset AND one of (raw-byte structural census / EXE byte-string census / a second donor file)."
input_reports:
  - docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md
  - docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md
  - docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shaders.md
  - docs/coord_swarm_2026-11-25/reports/V3D_01_selection_rectangle_audit.md
output: docs/coord_swarm_2026-11-25/reports/RV_SEL_01_selection_reverify.md
---

# RV-SEL-01 — authoritative donor selection spec (conflict arbitration)

## Goal

Resolve the conflicts between the two landed donor selection reports (DSEL-01, DSEL-02)
and the camera/shader decompilation (DEC-07), using **fresh reads and raw byte evidence**
rather than restating prior conclusions. Deliver one authoritative donor spec that the
`SEL-01` implementation ticket in `PLAN_IMPLEMENTATION.md` can consume without
re-litigating donor truth. The single most important open item is the meaning of the
`[*] = ;` prefix: DEC-07 examined **camera** `.inc` files and called them commented-out
source; DSEL-01 examined **selection** `.inc` files and called the identical prefix
live string-literal code. Both families are re-read at byte level here, together with
their `.aix`/`.cfg` registrations, and a per-file verdict is issued.

## Reports under review

| Report | What it asserted that is in conflict | Disposition here |
|---|---|---|
| DSEL-01 (claims 1–6, 8, 15, 18, 22) | drag threshold 0.005/0.25 world m; start on first LMB-held MOVE; yellow 1px box; engine filter flags; left-click own-only; sounds | **CONFIRMED** with byte offsets; one minor EXE-offset convention correction |
| DSEL-02 (claims 11, divergences "Click player filter"/"Drag rectangle") | world-space rect via `GameManagerStartSelection`; left-click own-only | **CONFIRMED** |
| DEC-07 (§8.1, §5.4) | all camera `.inc` scripts are "commented-out source", runtime activity UNVERIFIED | **CORRECTED**: byte format is identical to selection scripts; they are live `Code`-struct source. Residual UNVERIFIED item is the *native engine*, not the script text |
| V3D-01 (§3, break-point table) | port drag path present, no 3D draw consumer, screen-space `select_in_rect()` proposed | Not donor truth; port side noted only where `PLAN_IMPLEMENTATION.md` SEL-01 arbitrates it |

---

## The `[*] = ;` convention — definitive byte-level resolution

This is the master finding; every per-file verdict below depends on it.

**Raw byte structure** (identical in both families). A `.inc` file is a config record:

```
section.begin\r\n
   Name = OnMouseMove\r\n
   UsedFileName = \r\n
   Code : struct.begin\r\n
      [*] = ;<one script source line>\r\n       (repeated)
   struct.end\r\n
section.end\r\n
```

Observed byte examples:

- `data\gui\menu.inc\onmousemove.inc` @`0x000000`: `b'section.begin\r\n   Name = OnMouseMove\r\n   UsedFileName = \r\n   Code : struct.begin\r\n      [*] = ;if (GameManagerIsSelectionMode)...'`
- `data\gui\common.inc\onmousewheel.inc` @`0x000000`: `b'section.begin\r\n   Name = OnMouseWheel\r\n   Code : struct.begin\r\n      [*] = ;function ZoomCamera(time, deltaheight ...'`

**Verdict: `[*] = ;` is a live source-storage encoding, NOT a comment.**
`[*]` is the wildcard/repeated-array key that appends one element to the `Code : struct`
container; the leading `; ` is a storage escape that makes generic INI readers treat the
value as a comment, while the game's own loader strips it to recover the executable
line. Four independent byte facts prove this:

1. **Uniformity scan (observed).** All **136** files under `data\gui\*.inc\*.inc` were
   scanned; inside `Code : struct` blocks there are **39,074** `[*] = ;`-prefixed code
   lines and **0** nonconforming lines. Camera and selection files are stored by the
   exact same rule — there is no per-family convention.
2. **The container is named `Code` (observed).** `Code : struct.begin` is a code
   container; the structural lines (`section.begin`, `Name`, `UsedFileName`,
   `struct.end`, `section.end`) are unprefixed, only source lines carry `[*] = ;`.
3. **The script language's real comment token is `//` (observed).** Genuine disables use
   `//`, e.g. `onmousemove.inc:159-161` @`0x008882..0x009018`
   `//if GetGUIShiftStateCtrl then` / `//GameManagerStartSelection('spmRemove')` /
   `//else`; `onmousedown.inc:380` @`0x021313` `//ExecuteState('DoUpdateSelection')`;
   `onselection.inc:56-57` @`0x002878` `//var plHnd...`. If `;` killed a line, `//`
   would be redundant and no donor GUI script would execute at all.
4. **Registration (observed).** `data\gui\menu.cfg:2` @`0x000015`
   `StateMachineFileName = .\data\gui\menu.aix`; every state of interest is a section in
   `menu.aix` with `UsedFile = True` and a `UsedFileName` pointing at the `.inc`.

### Per-file verdicts (byte evidence)

| `.inc` file | Byte evidence of encoding + registration | Verdict |
|---|---|---|
| `menu.inc\onmousemove.inc` | `Code : struct.begin` @`0x000058`; `menu.aix:77-80` `Name=OnMouseMove` @`0x001680`, `UsedFile=True`, `UsedFileName=...\onmousemove.inc`; `menu.cfg:11` `StateOnMouseMove = OnMouseMove` @`0x000297` | **ACTIVE_SCRIPT_TEXT** |
| `menu.inc\onmousedown.inc` | same encoding; `menu.aix` `Name=OnMouseDown, UsedFile=True, ...\onmousedown.inc`; dispatches on `'LButtonUp' : begin` @`0x020480` (`:364`) via the GUI status-tag path (see note) | **ACTIVE_SCRIPT_TEXT** |
| `menu.inc\onselection.inc` | `Code : struct.begin` @`0x000038`; `menu.aix:159-162` `Name=OnSelection, UsedFile=True, ...\onselection.inc` @`0x003503..0x003574`; `menu.cfg:16 StateOnProcessSelection = OnSelection` @`0x000451` | **ACTIVE_SCRIPT_TEXT** |
| `common.inc\onmousehook.inc` | same encoding; `menu.aix:91-94` `Name=OnMouseHook, UsedFile=True, ...\onmousehook.inc` @`0x001996..0x002067`; `menu.cfg:27 StateOnGUIHookEvent = OnMouseHook` @`0x000770` | **ACTIVE_SCRIPT_TEXT** |
| `common.inc\onmousewheel.inc` | `Code : struct.begin` @ start; `menu.aix:84-87` `Name=OnMouseWheel` @`0x001836`, `UsedFile=True` @`0x001888`, `UsedFileName=...\onmousewheel.inc` @`0x001908`; `menu.cfg:14 StateOnMouseWheel = OnMouseWheel` @`0x000378` | **ACTIVE_SCRIPT_TEXT** |
| `menu.inc\onresize.inc` | same encoding; `menu.aix` `Name=OnResize, UsedFile=True, ...\onresize.inc`; `menu.cfg:22 StateResizeGUI = OnResize` | **ACTIVE_SCRIPT_TEXT** |
| `menu.inc\docreate.inc` | same encoding; `menu.aix:2-5` `Name=DoCreate, UsedFile=True, ...\docreate.inc` @`0x000015..0x000083`; `menu.cfg:3 StateCreateGUI = DoCreate` | **ACTIVE_SCRIPT_TEXT** |
| `menu.inc\oncamera.inc`, `cameracontrol.inc`, `dombtncameracontrol.inc` | same encoding; `menu.aix:145` `Name=OnCamera` @`0x003205`, `:185` `Name=DoMBtnCameraControl` @`0x004092`, `:204` `Name=CameraControl` @`0x004521` — each section `UsedFile = True` with a `UsedFileName` | **ACTIVE_SCRIPT_TEXT** |

**Note on `onmousedown.inc` (honest caveat).** `menu.cfg:12 StateOnMouseDown = ` is
**empty**, so this state is not wired through the direct `StateOnMouseDown` slot. The
file *is* registered `UsedFile = True` in `menu.aix`, and its body is a `case` on the GUI
`'Status'` tag (`'LButtonUp' : begin` at `:364`), i.e. it is driven by the GUI-hook /
`ExecuteState` path (`OnMouseHook` bound at `menu.cfg:27`). Registration is
**observed**; the exact dispatch chain from a physical LMB press to this state is
**derived** from the status-tag code and the hook binding, not observed at runtime.
The file is still live script source, not a dead comment.

**What this means for "intent vs runtime".** We have verified that the source text is
active and the literals are exact. We have **not** executed the donor, so we cannot claim
to have observed a drag at runtime. The correct boundary is: *script-side facts are
verified from active donor source; native engine internals (inside-box predicate, ray/AABB
bodies, timing of sound/highlight playback) remain UNVERIFIED.* "commented-out source"
is the wrong label for the scripts; "native engine body not read" is the right label for
the unknowns.

---

## Per-conflict evidence table

Labels: **observed** = literal donor byte/text fact; **derived** = control-flow/arithmetic
from observed; **inferred** = plausible with caveat; **UNVERIFIED** = native body not read.

### Conflict 1 — threshold literals, control flow, and active/commented status

| Claim | Method | path:offset/line | Excerpt | Label | Verdict |
|---|---|---|---|---|---|
| Default epsilon `0.005` world m | 1) fresh numbered read w/ byte offset; 2) independent prior DSEL-02 §D quoting same line | `onmousemove.inc:32` @`0x001402` | `[*] = ;var epsilon : Float = 0.005;` | observed | **CONFIRMED** |
| epsilon `0.25` in attack-point/guard mode | 1) fresh read; 2) control-flow re-derivation | `onmousemove.inc:33` @`0x001445`, `:34` @`0x001520` | `[*] = ;if (gbool_gui_attackpointmode) or (gbool_gui_guardmode) then` / `[*] = ;epsilon := 0.25;` | observed | **CONFIRMED** |
| x/z from ground ray hit | 1) fresh read; 2) EXE census `GetCurrentMouseWorldCoord` ×1 @`0x26cea2` and `ScreenToWorldRayCast` ×1 @`0x29d85a` | `onmousemove.inc:66` @`0x002847`, `:69` @`0x002961` | `[*] = ;if (IsGUIShortcutPressed('LButton')) then` / `[*] = ;   GetCurrentMouseWorldCoord(x, y, z);` | observed (call); native ray UNVERIFIED | **CONFIRMED** script-side |
| Selection starts on first **LMB-held MOVE**, not on down | 1) fresh read; 2) full-tree grep for `gbool_gui_isselectionstarted` → only `onmousedown.inc:365` (reset false), `onmousemove.inc:142,144`, declaration `dmscript.global:2226` | `onmousemove.inc:142` @`0x007957`, `:144` @`0x008050`, `:145-146` @`0x008114/0x008171` | `if not gbool_gui_isselectionstarted then` / `gbool_gui_isselectionstarted := true;` / `gfloat_gui_prevselmousex := x;` `...z := z;` | observed + derived | **CONFIRMED** — no other true-set exists |
| Threshold crossing uses axis-wise world delta | fresh read + byte context | `onmousemove.inc:150` @`0x008312`, `:152` @`0x008474` | `if (not GameManagerIsSelectionMode) and (not GameManagerIsBrushMode) and (gint_gui_pickedbldhnd=0) then` / `if (Abs(x - gfloat_gui_prevselmousex) > epsilon) or (Abs(z - gfloat_gui_prevselmousez) > epsilon) then` | observed | **CONFIRMED** |
| On crossing: Begin + Start('spmAdd' on Shift else 'spmRunTime') | 1) fresh read; 2) EXE census confirms API decls + enum strings | `onmousemove.inc:154` @`0x008641`, `:156-157` @`0x008715/0x008777`, `:162` @`0x009057` | `GameManagerBeginSelection;` / `if GetGUIShiftStateShift then GameManagerStartSelection('spmAdd')` / `GameManagerStartSelection('spmRunTime'); // 'spmClear', spmRunTime` | observed | **CONFIRMED** |
| Ctrl→`spmRemove` is disabled by `//`, not by `[*] = ;` | fresh read + byte context | `onmousemove.inc:159-161` @`0x008882..0x009018` | `//if GetGUIShiftStateCtrl then` / `//GameManagerStartSelection('spmRemove')` / `//else` | observed | **CONFIRMED** — decisive for the encoding question |
| File is active script text (not commented-out source) | 1) raw-byte structure; 2) `.aix`/`.cfg` registration; 3) 136-file/39,074-line uniformity scan | `onmousemove.inc:1-4` @`0x000000..0x000058`; `menu.aix` `UsedFile=True`; `menu.cfg:11` @`0x000297` | `section.begin / Name = OnMouseMove / Code : struct.begin / [*] = ;...` | observed + derived | **ACTIVE_SCRIPT_TEXT** |

### Conflict 2 — visual, sounds, config constants

| Claim | Method | path:offset/line | Excerpt | Label | Verdict |
|---|---|---|---|---|---|
| Rect outline bound by `SelectionBrushFileName=.\data\brushes\selection.cfg` | 1) fresh read; 2) EXE `TXSelectionBrush` @`0x1103c5`, `XSelectionBrush` @`0x1103c6`, `LineStep` @`0x110d5c` | `resource.lib:47` @`0x002113` | `SelectionBrushFileName = .\data\brushes\selection.cfg` | observed | **CONFIRMED** config binding; renderer use UNVERIFIED |
| Outline yellow `(1,1,0,1)`, solid `LinePattern=65535`, `LineWidth=1`, `AntiAliased=False`, `LineStep=1`, `Visible=True` | 1) fresh read of full struct; 2) EXE string census for `LineStep`/brush types | `brushes\selection.cfg:3` @`0x000044` … `:14` @`0x000300` | `AntiAliased = False`; `Red = 1`, `Green = 1`, `Blue = 0`, `Alpha = 1`; `LinePattern = 65535`; `LineWidth = 1`; `Visible = True`; `LineStep = 1` | observed | **CONFIRMED (value extraction exact)**; that the engine draws this during a live drag is UNVERIFIED |
| `KeyDoubleDelay = 0.5` (and `KeyRepeatDelay = 0.05`) | 1) fresh read; 2) `ProgressInterval = 10` corroborates same config block | `menu.cfg:32` @`0x000914`, `:33` @`0x000940`, `:28` @`0x000808` | `KeyRepeatDelay = 0.05` / `KeyDoubleDelay = 0.5` / `ProgressInterval = 10` | observed | **CONFIRMED** config; engine double-click producer UNVERIFIED |
| Highlight materials | 1) fresh script read; 2) filesystem DDS census | `gui.script:3372-3377`; `brushes\textures\selection.friend.dds`, `selection.building(.small).dds`, `selection.ship.0/1.dds`, `highlight.friend/ally/enemy.dds` | `const cHighlightSelected = 'selection.friend';` … `cHighlightEnemy = 'highlight.friend/ally/enemy' names`; `EffectHighlightGetOrCreate(goHnd, 'h', visible, mat);` @`:3470` | observed (names+files); binding UNVERIFIED | **CONFIRMED names**, engine-side render UNVERIFIED |
| Highlight render size `0.7`, master `gc_settings_highlights = True` | 1) fresh reads; 2) EXE `EffectHighlightGetOrCreate` ×1 @`0x2dc8fe` | `init.script:111`; `dmscript.global:1019` | `size:=0.7; SetHighlightRenderSettings(...)`; `gc_settings_highlights = True;` | observed | **CONFIRMED** |
| Sounds `selectpeasant1..6`/`selectship`, indices 26/27 | 1) fresh reads; 2) filesystem OGG census (7 files) | `dmscript.global:1276-1277`; `sound.script:207-208`; `sounds\interface\selectpeasant1..6.ogg`, `selectship.ogg` | `gc_snd_ind_selectpeasant = 26;` `gc_snd_ind_selectship = 27;`; `_sound_AddSoundToSoundLibrary(gc_snd_ind_selectpeasant, 'selectpeasant'+IntToStr(i), ...)` | observed (library+files); playback timing UNVERIFIED | **CONFIRMED existence/loading** |

### Conflict 3 — world-space rect and engine filter flags

| Claim | Method | path:offset/line | Excerpt | Label | Verdict |
|---|---|---|---|---|---|
| Drag rect is native/world-space via `GameManagerStartSelection('spmAdd'/'spmRunTime')` | 1) fresh read of `onmousemove.inc:154-164`; 2) EXE byte census of `GameManagerStartSelection(const smode: String)` @`0x29f74e`, `GameManagerBeginSelection` @`0x29f7fa`, `GameManagerIsSelectionMode` @`0x29f7c2` | `onmousemove.inc:154,157,162` (offsets above) | `GameManagerBeginSelection;` … `GameManagerStartSelection('spmAdd')` … `GameManagerStartSelection('spmRunTime');` | observed (call contract); native rect test UNVERIFIED | **CONFIRMED script-side; engine predicate UNVERIFIED** |
| Filter flags `pickgroups=false, pickgamemanagerplayer=true, pickplayableObject=true, pickfrustum=true` | 1) fresh read of plain `.script` (active, no `[*] = ;`); 2) EXE signature decl with exact param names @`0x2a716e` | `init.script:220` @`0x010267` | `SetGameManagerSelectionSettings(false, true, true, true);`; EXE: `procedure SetGameManagerSelectionSettings(const pickgroups, pickgamemanagerplayer, pickplayableObject, pickfrustum: Boolean)` | observed (args + param names) / derived (positional mapping) | **CONFIRMED as call; native use of each flag UNVERIFIED** |
| Picking-mode enum has 7 values | 1) EXE byte dump around `TXSelectionPickingMode` @`0x1111fa`; 2) `onselection.inc:34` reads one member | EXE @`0x11121e..0x11124f`; `onselection.inc:34` @`0x001550` | `spmNone spmClear spmXor spmNot spmRunTime spmAdd spmRemove`; `bpickRemove := (GetGameManagerPickingMode='spmRemove')` | observed | **CONFIRMED** |
| `OnSelection` post-filter own+playable, skip groups | 1) fresh read; 2) duplicate guards in `control.script:181,183` | `onselection.inc:40` @`0x001859`, `:43` @`0x002008` | `if (not IsGroupByHandle(goHnd)) then` / `if (pobj<>nil) and (TObj(pobj).pl=myPlInd) and (GetGameObjectPlayableObjectByHandle(goHnd)) then` | observed | **CONFIRMED** script-side |
| Native inside-box predicate (centre vs AABB vs frustum vs `GetGameObjectSelectionSizeByHandle`) | EXE proves API exists @`0x240a3a`, body not read; no script call to size getter found | EXE `GetGameObjectSelectionSizeByHandle` ×1 @`0x240a3a` | API declaration only | UNVERIFIED | **UNVERIFIED — do not invent a predicate** |

### Conflict 4 — left-click player filter

| Claim | Method | path:offset/line | Excerpt | Label | Verdict |
|---|---|---|---|---|---|
| Left-click is own-only: `_control_GetUnitUnderCursor(True)` | 1) fresh read w/ byte offset; 2) callee body in a **second file** proves `True` ⇒ own player | `onmousedown.inc:280` @`0x015449`; `control.script:156` @ body, `:183` | `var goHnd : Integer = _control_GetUnitUnderCursor(True);`; `function _control_GetUnitUnderCursor(bMyPlayerOnly : Boolean)`; `if ((not bMyPlayerOnly) or (GetGameObjectPlayerHandleByHandle(goHnd)=myPlHnd)) and ...` | observed | **CONFIRMED** |
| Order/guard/cursor paths pass `False` (enemies targetable) | fresh reads at 3 independent sites | `onmousedown.inc:394` @`0x022007`, `:480` @`0x027000`, `:683` @`0x040057` | `_control_GetUnitUnderCursor(False)` at each | observed | **CONFIRMED** |
| The call site is active text, not commented | raw-byte encoding + registration | `onmousedown.inc:1-4`; `menu.aix` `UsedFile=True` | `Code : struct.begin` / `[*] = ;...`; no `//` before the call | observed | **ACTIVE_SCRIPT_TEXT** |

---

## Final authoritative donor selection spec

### Constants (all `observed` unless marked)

| Constant | Value | Meaning | Source |
|---|---|---|---|
| `epsilon` (default) | `0.005` | world m of X/Z ground delta to start box | `onmousemove.inc:32` @`0x001402` |
| `epsilon` (attack/guard) | `0.25` | world m | `onmousemove.inc:33-34` @`0x001445/0x001520` |
| `KeyDoubleDelay` | `0.5` s | double-click window | `menu.cfg:33` @`0x000940` |
| `KeyRepeatDelay` | `0.05` s | key repeat | `menu.cfg:32` @`0x000914` |
| `ProgressInterval` | `10` ms | GUI tick / highlight throttle | `menu.cfg:28` @`0x000808` |
| Selection settings | `(false, true, true, true)` | `pickgroups`, `pickgamemanagerplayer`, `pickplayableObject`, `pickfrustum` | `init.script:220` @`0x010267` + EXE @`0x2a716e` |
| Live drag modes | `spmRunTime` (replace), `spmAdd` (Shift-add) | `GameManagerStartSelection` arg | `onmousemove.inc:157,162` |
| Enum (7) | `spmNone, spmClear, spmXor, spmNot, spmRunTime, spmAdd, spmRemove` | native strings | EXE @`0x11121e..0x11124f` |
| `gc_snd_ind_selectpeasant` / `...selectship` | `26` / `27` | sound indices | `dmscript.global:1276-1277` |
| Highlight render size | `0.7` | `SetHighlightRenderSettings` | `init.script:111` |
| `gc_settings_highlights` | `True` | master default | `dmscript.global:1019` |
| Outline | `RGBA(1,1,0,1)`, `LinePattern=65535`, `LineWidth=1`, `AntiAliased=False`, `LineStep=1`, `Visible=True` | yellow 1px solid | `brushes\selection.cfg:3-14` |
| Brush binding | `.\data\brushes\selection.cfg` | `SelectionBrushFileName` | `resource.lib:47` @`0x002113` |

### Pseudocode (reconstructed from active source; native parts marked)

```
# --- wiring (observed) ---
StateMachineFileName = .\data\gui\menu.aix          # menu.cfg:2
StateOnMouseMove     = OnMouseMove                  # menu.cfg:11
StateOnProcessSelection = OnSelection              # menu.cfg:16
StateOnGUIHookEvent  = OnMouseHook                  # menu.cfg:27
# menu.aix: OnMouseMove/OnMouseDown/OnSelection/OnMouseWheel/OnResize/... 
#          each section UsedFile=True, UsedFileName -> the matching .inc

# --- init, once (observed) ---
SetGameManagerSelectionSettings(false, true, true, true)   # init.script:220

# --- LMB DOWN (onmousedown.inc, active) ---
# minimap / order-mode / build-ghost gates precede  (:116-268)
goHnd := _control_GetUnitUnderCursor(True)          # :280  OWN player only
if bDouble or GUI_Ctrl: _misc_SelectAllUnitsOfType(...)   # :281-291
elif goHnd<>0: replace / add / ctrl-remove          # :296-341
else: if not shift and not ctrl: DeselectAll        # :346-355
ExecuteState('DoUpdateSelection')                   # :359
# NOTE: down does NOT set isselectionstarted

# --- LMB HELD + MOVE (onmousemove.inc, active) ---
x,y,z := GetCurrentMouseWorldCoord(...)             # :69  ground ray hit
epsilon := 0.005                                    # :32
if attackpointmode or guardmode: epsilon := 0.25    # :33-34
if not isselectionstarted:                          # :142
    isselectionstarted := true                      # :144
    prevSelX := x; prevSelZ := z                    # :145-146   FIRST MOVE, not down
else if (not GameManagerIsSelectionMode) and (not GameManagerIsBrushMode)
        and (gint_gui_pickedbldhnd=0):              # :150
    if Abs(x-prevSelX)>epsilon or Abs(z-prevSelZ)>epsilon:  # :152
        GameManagerBeginSelection                   # :154
        if Shift: GameManagerStartSelection('spmAdd')       # :157
        else:     GameManagerStartSelection('spmRunTime')   # :162
        # Ctrl->spmRemove branch DISABLED WITH // at :159-161
        ExecuteState('DoUpdateSelection')           # :164

# --- LMB UP (onmousedown.inc, active) ---
isselectionstarted := false                         # :365
if (not bDouble) and GameManagerIsSelectionMode:    # :375-377
    GameManagerCancelSelection                      # :379
    update_unitcontrol := True; update_rallypoints := True       # :381-382
    goinattackmode := False; guardmode := False                # :384-385
    attackpointmode := False; patrolmode := False              # :386-387
    update_cursor := True; requestsoundonunitcontrol := True   # :388-389

# --- NATIVE (UNVERIFIED body) ---
# GameManager collects GameManagerPickedObjects; exact inside-box test unknown.
# EXE proves API GetGameObjectSelectionSizeByHandle @0x240a3a exists; no script caller.

# --- OnSelection POST-FILTER (onselection.inc, active) ---
bpickRemove := (GetGameManagerPickingMode='spmRemove')          # :34
_GetSelectionInfo(build, land, water, nonGuard, True)            # :13
selUnit := land; selWater := not land and water; selBuild := not land and not water
for i := CountGameManagerPickedObjects-1 downto 0:              # :37
    goHnd := HandleGameManagerPickedObjects(i)                   # :39
    if IsGroupByHandle(goHnd): continue                          # :40
    pobj := _GetTObj(goHnd)
    if pobj=nil or TObj(pobj).pl<>myPlInd
       or not PlayableObjectByHandle(goHnd): continue            # :43
    if (not selBuild) and bBuilding: SetPicked(False)            # :46-47
    elif (not selWater) and media=water: SetPicked(False)        # :49-50
    elif selUnit and nonGuard and order=guard: SetPicked(False)  # :52-53
    else: ... squad collapse / Add + SetPicked(True) ...         # :55-168
```

### Visual (authoritative, exact)

- Outline stored in `brushes\selection.cfg:3-14`: `LineSetup : struct.begin`;
  `AntiAliased=False`; `LineColor : struct` with `Red=1, Green=1, Blue=0, Alpha=1`
  (yellow); `LinePattern=65535` (solid); `LineWidth=1`; `Visible=True`; `struct.end`;
  `LineStep=1`. Bound from `resource.lib:47` `SelectionBrushFileName=.\data\brushes\selection.cfg`.
- **Port divergence to record, not to copy:** the 2D port `app/scripts/world.gd:3641-3647`
  draws a **white** `Color(1,1,1,0.9)` 1.5 px outline **plus a 0.18 alpha fill**; the 3D
  port draws no rectangle at all (`V3D-01:248,268`). Neither matches the donor yellow
  1 px solid/no-fill style. The donor values above are the target for the SEL-01 overlay;
  the port white+fill is a divergence, not a donor style.

---

## Which donor facts are intent-only vs verified-runtime

**Verified from active donor source (script-side, byte-checked):** every literal and
control-flow above — threshold 0.005/0.25, first-move start, axis-wise world delta,
GameManager call sequence, Shift semantics, `//`-disabled Ctrl, filter flags and their
parameter names, 7-value enum, own-only left-click (callee body proves it), own+playable
`OnSelection` filter, exact brush/color/sound/highlight constants, state wiring via
`.aix`/`.cfg`. These are **donor-authored and active**, not inferred from dead comments.

**Intent-only / engine-side (UNVERIFIED, do not claim as observed runtime):**
1. Native inside-box predicate (centre vs AABB vs selection-size vs frustum quad) — API
   exists in EXE but body not read; no script call to `GetGameObjectSelectionSizeByHandle`.
2. Native implementation of `GameManager*` call chain and whether `GameManager` uses all
   four filter flags at runtime and in what order.
3. `GetCurrentMouseWorldCoord` / `ScreenToWorldRayCast` native ray and heightfield behavior
   (terrain-surface hit vs flat plane).
4. That the `selection.cfg` brush is actually rasterised during a live drag, and exact
   `EffectHighlightGetOrCreate` render semantics / cursor/AABB internals.
5. Double-click *producer* of `GetBoolValueByName('Double')` and
   `GetGUIShiftStateDouble`; sound/highlight *playback timing* relative to rectangle release.
6. `SetGameManagerSelectionUseStep(true)` native meaning (`docreate.inc:100`).
7. Enemy/wall/gate inclusion by the *native* rectangle (script post-filter implies
   own-only, but no runtime observation).

The boundary is **not** "scripts are dead". It is "active scripts call native bodies we
cannot read". DEC-07's §8.1 caution should be narrowed accordingly.

---

## Corrections to prior reports

1. **DEC-07 §8.1 — CORRECTED (material).** "All camera `.inc` control scripts are
   commented-out source … runtime activity UNVERIFIED" is wrong at the byte-format level.
   `onmousewheel.inc`, `oncamera.inc`, `cameracontrol.inc`, `dombtncameracontrol.inc`,
   `onresize.inc`, `docreate.inc` use the **identical** `Code : struct.begin` + `[*] = ;`
   live-code encoding as the selection `.inc` files, are registered `UsedFile = True` in
   `menu.aix`, and are bound by `menu.cfg`. Their code is **ACTIVE_SCRIPT_TEXT**. The
   legitimate residual caveat is that their *formulas* agree with the active `control.script`
   helper but the native engine bodies remain UNVERIFIED — not that the text is dead.
2. **DSEL-01 §"Reading convention" (lines 21–29) — CONFIRMED and generalised.** Its claim
   that `[*] = ;` lines are live string-literal code is correct, and the 136-file/39,074-line
   uniformity scan shows the same rule for camera files. DSEL-01 did not need to walk back;
   DEC-07 needed narrowing.
3. **DSEL-01 EXE offsets — MINOR CORRECTION (convention, not substance).** Reported offsets
   (e.g. `GameManagerBeginSelection @0x29F7F0`, `GameManagerStartSelection @0x29F744`,
   `SetGameManagerSelectionSettings @0x2A7164`, `GetGameObjectSelectionSizeByHandle
   @0x240A30`) are consistently **0x0A below** the first ASCII byte of the name; fresh
   census finds ASCII at `0x29f7fa`, `0x29f74e`, `0x2a716e`, `0x240a3a`. DSEL-01 cited the
   VM string-record start (length prefix), not the text start. Param names, enum and counts
   are otherwise exactly right. `LineStep @0x110D5C`, `TXSelectionBrush @0x1103C5`,
   `TXSelectionPickingMode @0x1111FA` match exactly.
4. **DSEL-02 "Click player filter" divergence — CONFIRMED, no correction needed.**
   Left-click own-only (`onmousedown.inc:280` `True`) vs port `_pick(pw,false)` is correct;
   callee body `control.script:183` independently proves the flag semantics.
5. **V3D-01 §Fix A screen-space `select_in_rect()` — not donor truth; already arbitrated.**
   It is a 2D-derived port suggestion. `PLAN_IMPLEMENTATION.md §2` (S-25-06) rejects it and
   keeps the world rect. This report does not re-open that decision.

---

## Implications for our 3D fix (cite `PLAN_IMPLEMENTATION.md` SEL-01)

`PLAN_IMPLEMENTATION.md:28` defines SEL-01 (`variant3d/scripts/input_controller.gd`):
(a) yellow 1 px `CanvasLayer` overlay in viewport pixels; (b) replace 6-px screen threshold
with donor **world epsilon** on `ground_point()` delta; (c) Shift=add / no-Shift=replace;
(d) keep click-pick byte-identical; gated on `DSEL-01 + DSEL-02 + RV-SEL-01` + S1.

This re-verification **unblocks and sharpens** SEL-01:

- The epsilon gate is now byte-certain: `0.005` m (default) and `0.25` m in attack/guard
  mode, axis-wise on `Abs(x-prevX) or Abs(z-prevZ)` from `GetCurrentMouseWorldCoord`.
  Implement (b) exactly; the "start on first move" nuance means the reference point is
  captured on the **first LMB-held motion**, not on press — mirror that two-phase start.
- Keep the **world** rectangle (S-25-06 upheld). Do **not** adopt V3D-01's screen-space
  `select_in_rect()` (that was the rejected 2D-derived option).
- Shift semantics are confirmed `spmAdd` / `spmRunTime`; Ctrl-remove for the *drag* is
  disabled by `//` in the donor — do not add it to the drag path (SEL-01 (c) + DSEL-01 §recipe 4).
- The overlay style in (a) must be the donor `selection.cfg` values: `Color(1,1,0,1)`,
  **1 px solid, no fill** — not the port's white 1.5 px + 0.18 fill. Record the port style
  as a divergence (per the follow-up directive). Keep the overlay in viewport pixels and
  `MOUSE_FILTER_IGNORE` per the existing plan.
- Own-only left-click (`_control_GetUnitUnderCursor(True)`) stays for the click branch;
  SEL-01 (d) keeps it byte-identical — no change there.
- Because `[*] = ;` is now proven live-code encoding, the donor script findings are safe
  to treat as **active donor intent** for the fix. Still label the native rectangle
  predicate, frustum flag, sound/highlight timing and FOV as UNVERIFIED / PORT
  APPROXIMATION in the SEL-01 report; do not present them as recovered runtime truth.

For S1/TEST-04 (`PLAN_IMPLEMENTATION.md:29`, driven in `SEL-02`), assert the exact
selected-ID set, overlay `Rect2 == drag pixels` during drag and cleared on release,
`cmd_*` counter 0, and 29/29 + 17/17 green — unchanged by this arbitration.

---

## Open questions

1. Native inside-box predicate (centre / AABB / `GetGameObjectSelectionSizeByHandle` /
   frustum quad) — **UNVERIFIED**; no script caller of the size getter and EXE body not read.
2. Native use/order of the four `SetGameManagerSelectionSettings` flags — **UNVERIFIED**.
3. Native `GameManagerBegin/Start/CancelSelection` implementation and whether
   `GameManager` collects picked objects by screen rect, world quad or frustum.
4. Whether the `selection.cfg` brush is rasterised live and with what line-step semantics.
5. Exact runtime dispatch chain for `onmousedown.inc` given `menu.cfg:12 StateOnMouseDown`
   is empty (GUI status-tag/`ExecuteState` path derived, not observed).
6. Double-click event producer and sound/highlight playback timing vs rectangle release.
7. Enemy/wall/gate inclusion by the native rectangle (script post-filter implies own-only).
8. `SetGameManagerSelectionUseStep(true)` native meaning (`docreate.inc:100`).
9. `pickfrustum=true` semantics on the −32° perspective view (screen rect vs projected quad).

---

## Summary

Four conflict areas are arbitrated with fresh byte evidence. (1) The drag threshold is
byte-exact `0.005` m, raised to `0.25` m in attack/guard mode, axis-wise on world X/Z from
`GetCurrentMouseWorldCoord`; the box starts on the **first LMB-held move**, not on down
(no other true-set of `gbool_gui_isselectionstarted` exists). (2) The visual is exactly
`RGBA(1,1,0,1)` yellow, 1 px, solid `LinePattern=65535`, `AntiAliased=False`, `LineStep=1`,
bound via `resource.lib:47` → `brushes\selection.cfg`; sounds `selectpeasant1..6`/`selectship`
(indices 26/27) and `KeyDoubleDelay=0.5` are confirmed, with engine playback/timing left
UNVERIFIED. (3) The rectangle is native/world-space via `GameManagerStartSelection`,
with filter flags `(false,true,true,true)` whose parameter names are independently present
in the EXE signature @`0x2a716e`; the 7-value picking enum is confirmed; the native inside-box
predicate remains UNVERIFIED. (4) Left-click is own-only via `_control_GetUnitUnderCursor(True)`,
proved by the callee's `bMyPlayerOnly` check in a second file; order paths pass `False`.

The master resolution: **`[*] = ;` is a live `Code`-struct source encoding used identically
by all 136 GUI `.inc` files (39,074 lines, 0 exceptions), not a comment marker.** The real
comment token is `//`. Consequently both selection and camera `.inc` scripts are
**ACTIVE_SCRIPT_TEXT**, and DEC-07 §8.1's "commented-out source" label is corrected; the
legitimate unknown is the native engine body, not the script text. The authoritative spec,
constants and pseudocode above are safe to treat as active donor intent for SEL-01, while
native rectangle/AABB/frustum/sound-timing facts stay UNVERIFIED. DSEL-01 and DSEL-02 are
substantively confirmed (one minor EXE offset convention corrected); DEC-07 is narrowed.
No donor file was executed or copied; no repo code, config, asset, test, scene, shader or
git state was changed; exactly one report file was written.
