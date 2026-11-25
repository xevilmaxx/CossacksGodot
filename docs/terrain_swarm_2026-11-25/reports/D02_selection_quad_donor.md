---
id: D02
title: "D02 — Selection quad / marquee donor ground truth and port specification"
area: "terrain-swarm Wave D — selection quad end-to-end audit"
owner: D02
date: 2026-11-25
status: READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__ONE_REPORT
scope: "Exactly one new file written — this report. No repo code/config/asset/test/scene/shader/git edit. No donor execution. No Godot runner job."
labels: [OBSERVED, UNVERIFIED, INFERRED, PORT_APPROXIMATION]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
output: docs/terrain_swarm_2026-11-25/reports/D02_selection_quad_donor.md
---

# D02 — selection quad donor ground truth

## 1. Goal and method

Establish **ground truth for the drag-selection quad / marquee** from two
independent evidence classes and deliver a precise specification table our Godot 4
port should satisfy. Every item is labelled **OBSERVED** (literal donor file,
binary string, or fetched online text) or **UNVERIFIED** (native engine body not
read, runtime not observed, or source not retrievable). Nothing here is a code
change, and no Godot job was submitted.

Evidence classes:

1. **Local decomp / prior donor recon** — DSEL-01, DSEL-02, RV-SEL-01 (conflict
   arbitration with raw byte offsets) and DEC-08 (UI/brush definitions).
2. **Online** — official Steam 2016-11 announcement, the charter's controls
   article (Gamepressure UI guide), the cossacks-3-almanac "Controls and Player
   Feedback" article, and a 2016 review containing the wall bug.

Where online prose conflicts with byte-level decomp, **byte-level donor decomp is
authoritative** and the conflict is recorded in §6.

## 2. Sources read

### 2.1 Local (all read in full this task)

| File | What it supplied |
|---|---|
| `docs/terrain_swarm_2026-11-25/CHARTER.md` | Task guardrails; §1b.2 (quad re-audit, wall bug), §6 URLs |
| `docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md` | 26-claim donor recon: epsilon, two-phase start, call chain, Shift, style, filters, walls |
| `docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md` | World-space rect, camera/pick math, port divergences |
| `docs/coord_swarm_2026-11-25/reports/RV_SEL_01_selection_reverify.md` | Byte offsets, `[*] = ;` = live code, conflict arbitration, EXE enum |
| `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` | `selection.cfg` brush record, state wiring, no selection locale strings, port gaps |

### 2.2 Online (fetched this task; URLs from charter §6 unless noted)

| URL | Result | Key evidence |
|---|---|---|
| `https://store.steampowered.com/news/app/333420/view/4042499938190999083` | Chrome-only as markdown (JS-rendered). Full body recovered from `?l=english` HTML `data-partnereventstore.announcement_body.body` | Official 2016-11-12 announcement, drag frame added, map moves with drag — §3.1 |
| `https://www.gamepressure.com/cossacks3/user-interface/zd91b1` | Fetched in full (last update 17 Oct 2016) | Shift-add, double-click / Ctrl / Z same-type, Ctrl+A, queue controls — §3.2 |
| `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/systems/ui_input_and_feedback.md` | Fetched in full (article "Controls and Player Feedback"; repo seeded in charter §6) | Box updates set while button held; per-frame selection scan; 4 filter params; Z variants; cursor clip — §3.3 |
| `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/combat/target_selection.md` | Fetched in full | Confirms almanac is technical-recon prose, not a selection-quad spec; no extra quad facts |
| `https://wolfsgamingblog.com/2016/09/28/cossacks-3-review-less-sequel-more-hd-remaster` | Fetched in full | Exact "box selection not working after you select a wall" sentence — §3.4 |
| `http://dl.cossacks3.com/?threads/all-hotkeys-and-cheats-updated-in-encyclopedia.29026/` | **UNVERIFIED** — HTTP 522 on fetch; search snippet only, not used as primary evidence | Snippet claims Shift+drag adds; already covered by donor script + Gamepressure |
| `https://api.github.com/repos/anyalink99/cossacks-3-almanac/git/trees/main?recursive=1` | Fetched; used to locate `docs_en/recon/systems/ui_input_and_feedback.md` | No dedicated "controls/selection quad" spec file beyond the two docs above |

## 3. Online evidence — verbatim quotes (OBSERVED as web text)

### 3.1 Official Steam announcement — drag selection frame is canonical

Title: **"The Cossacks 3 Mod Manager is here + selection frame dragging ability!"**
`article:published_time = 2016-11-12T08:53:08-08:00`; GID `4042499938190999083`.

> "2. An ability to drag the selection frame – community's favorite. Rejoice, as
> you are now able to select your grand armies even if they take more place than
> could fit on one screen. Select your numerous pikemen, musketeers and dragoons
> and send them away to fight in your name!"

Russian body (authoritative for the extra behavioural detail):

> "2. Добавлена рамка выделения. Теперь, когда тянете рамку, карта движется с
> вами. … Вы можете выбрать ваши великие армии, даже если они настолько огромны,
> что не помещаются на одном экране …"

**OBSERVED:** drag-frame selection was an officially shipped feature (added
2016-11); it is intended to select armies larger than one screen; the map moves
with the player while dragging the frame.
**UNVERIFIED:** the exact mechanism of "map moves with you" (edge-scroll bands,
auto-pan speed, cursor clamping) — the announcement gives no numbers and no
local script line ties a pan speed to the drag state.

### 3.2 Gamepressure "Cossacks 3: User interface" (controls article, 2016-10-17)

> "If you have some troops selected, hold shift and left mouse to add more units
> to the selection."
>
> "Double clicking a unit, clicking a unit while holding **CTRL**, or selecting a
> unit and pressing Z selects all units of the same kind. Combine this with
> holding **SHIFT** to instantly add more units to selection."
>
> "**CTRL + A** will select every unit on the map."

Also: CTRL+0..9 assigns a control group; SHIFT path-setting; right-click removes
one unit from the recruitment queue, Shift removes five, Ctrl sets unlimited.

### 3.3 Cossacks-3-almanac — "Controls and Player Feedback" (secondary recon)

> "A single click selects the object under the cursor; a selection box updates
> the selected set while the mouse button is held."
>
> "1. `GameManagerBeginSelection` prepares the selection buffer.
> 2. `GameManagerStartSelection(mode)` starts either: `spmRunTime` for a
>    one-frame click; `spmFrame` for a box updated every frame while the button
>    is held.
> 3. Each box-selection frame, a `_control_*` function scans objects and marks
>    matches with `SetGameObjectPickedByHandle`."
>
> "`SetClipCursor(val)` — Lock the cursor inside the window (for the selection
> frame)."
>
> "Human players normally use `pickplayableObject = True` and an owner filter
> for their own player."
>
> `Z` = `select|unitsofsametype`, `Shift+Z` = `select|addunitsofsametype`,
> `Ctrl+A` = `select|allunits`, `Ctrl+B` = `select|allbuildings`, `Ctrl+Q` =
> `select|allships`, `Ctrl+P`/backtick = idle peasants.

**Conflict flag:** the almanac's `spmFrame` is **not** one of the seven native
enum strings recovered from `cossacks.exe` (`spmNone, spmClear, spmXor, spmNot,
spmRunTime, spmAdd, spmRemove`, RV-SEL-01 @`0x11121e..0x11124f`). Treat
`spmFrame` as almanac paraphrase, not a donor literal; keep `spmAdd`/`spmRunTime`
from the byte-level recon. Its "per-frame `_control_*` scan" also differs from
the local recon, where `GameManager*` collects `GameManagerPickedObjects` and the
script `OnSelection` state post-filters them (§6).

### 3.4 Wall bug — third-party review (2016-09-28)

> "Yup, Cossacks 3 has quite a number of bugs living within its code, from the
> developer's console still being accessible through a tap of P to the **box
> selection not working after you select a wall** and units sometimes failing to
> obey commands."

— Wolf's Gaming Blog, *Cossacks 3 Review – Less Sequel, More HD Remaster*.

**OBSERVED:** a reviewer reported the defect. **UNVERIFIED:** the exact
reproduction steps, version, and native cause. Donor script evidence shows only
adjacent facts (wall-build mode gates the marquee at `onmousemove.inc:140`; walls
receive no highlight at `gui.script:3468-3469`). Per charter §1b.2 this is a bug
**not to copy**: our port must keep box selection working after a wall has been
selected.

## 4. Specification table — what our port must satisfy

Legend: **OBSERVED** = literal donor artifact / fetched online text; **UNVERIFIED**
= native body, runtime, or exact mechanism not established. "Port" column records
the current shipped behaviour from DSEL-01/DSEL-02/DEC-08 (read-only observations).

| # | Item | Required donor-grounded rule | Status | Source | Current port |
|---:|---|---|---|---|---|
| 1 | Drag-frame existence | Drag-marquee selection is a canonical shipped feature; must exist and select armies larger than one screen | **OBSERVED** | Steam 2016-11-12 announcement §3.1; donor state machine `menu.cfg:11,16` + `onmousemove.inc:142-167` | Present but incomplete: 6 px threshold, no draw in 3D |
| 2 | Preconditions before marquee | Minimap hover, attack-point/patrol/guard/order mode, active build ghost (`gint_gui_pickedbldhnd<>0`) and wall-build (`gWallCluster.buildWall`) all preempt the box | **OBSERVED** | `onmousedown.inc:116-268`; `onmousemove.inc:140,150`; DSEL-01 pseudocode | Minimap preempt present; order/ghost/wall gates not mirrored |
| 3 | Drag start event | Start flag is set on the **first LMB-held MOUSE-MOVE**, never on LMB-down; no other true-set of `gbool_gui_isselectionstarted` exists | **OBSERVED** | `onmousemove.inc:142-147` @`0x007957..0x008171`; `dmscript.global:2226`; `onmousedown.inc:365` reset; RV-SEL-01 conflict 1 | Starts on LMB-down (`input_controller.gd:474` / `:608`) |
| 4 | Start reference point | `gfloat_gui_prevselmousex/z` captured from `GetCurrentMouseWorldCoord` (ground ray hit), not from screen pixels | **OBSERVED** (call); native ray **UNVERIFIED** | `onmousemove.inc:66,69` @`0x002847/0x002961`; EXE `GetCurrentMouseWorldCoord` ×1; DSEL-02 claim 7 | Stores start pixel, converts to sim on release |
| 5 | Coordinate space of threshold | Threshold is **world-space**, axis-wise on X/Z ground metres: `Abs(x-prevSelX)>epsilon or Abs(z-prevSelZ)>epsilon` (strict `>`) | **OBSERVED** | `onmousemove.inc:152` @`0x008474`; RV-SEL-01; DSEL-02 §D | 6 **screen pixels** (`input_controller.gd:479,527` / `:613,662`) |
| 6 | Epsilon (default) | `0.005` world metres | **OBSERVED** | `onmousemove.inc:32` @`0x001402` `var epsilon : Float = 0.005;` | 6 px |
| 7 | Epsilon (attack/guard) | Raised to `0.25` world metres when attack-point or guard mode active | **OBSERVED** | `onmousemove.inc:33-34` @`0x001445/0x001520` | No mode-dependent threshold |
| 8 | Engine call chain | On crossing: `GameManagerBeginSelection`, then `GameManagerStartSelection(mode)`, then `ExecuteState('DoUpdateSelection')` | **OBSERVED** (script-side) | `onmousemove.inc:154-164`; EXE `Begin @0x29f7fa`, `Start @0x29f74e` (RV-SEL-01 corrected offsets) | No engine equivalent |
| 9 | Live drag modes | `spmAdd` when Shift held, else `spmRunTime` (replace). Native enum has 7 values; no `spmFrame` literal exists | **OBSERVED** | `onmousemove.inc:156-162`; EXE enum @`0x11121e..0x11124f`; almanac `spmFrame` is paraphrase (§3.3) | Shift ignored; always replace |
| 10 | Ctrl during drag | Ctrl→`spmRemove` is **disabled with the real comment token `//`**; do not port a drag-time Ctrl-remove | **OBSERVED** | `onmousemove.inc:159-161` @`0x008882..0x009018`; RV-SEL-01 encoding proof | Not implemented (aligned by absence) |
| 11 | Finalize | On LMB-up: `isselectionstarted := false`; if `GameManagerIsSelectionMode` → `GameManagerCancelSelection` + set unitcontrol/rallypoint/cursor/sound flags, clear attack/guard/attackpoint/patrol modes | **OBSERVED** | `onmousedown.inc:364-390`; EXE `Cancel`, `IsSelectionMode @0x29f7c2` | Selection applied on release; UI flags not mirrored |
| 12 | Double-click vs marquee finalize | Finalize is guarded by `not bDouble`: a double-click **suppresses the normal marquee commit/finalize path** — i.e. the frame is aborted on a double-click, not merely a same-type shortcut | **OBSERVED** (guard literal); native meaning **UNVERIFIED** | `onmousedown.inc:375-377` `(not bDouble) and GameManagerIsSelectionMode`; producer of `GetBoolValueByName('Double')` unread (RV-SEL-01 open q5) | No `bDouble` guard on drag release |
| 13 | Double-click window | `KeyDoubleDelay = 0.5` s (port uses 0.35 s) | **OBSERVED** as config; native producer **UNVERIFIED** | `menu.cfg:33` @`0x000940`; port `input_controller.gd:628` | 0.35 s |
| 14 | Camera behaviour while dragging | Map moves with the player during a frame drag; intended for armies larger than one screen | **OBSERVED** (Steam RU prose); mechanism **UNVERIFIED** | Steam announcement §3.1; almanac `SetClipCursor` mention (secondary) | Not implemented |
| 15 | Inside-box predicate | Exact native test (centre point vs AABB vs frustum quad vs `GetGameObjectSelectionSizeByHandle`) cannot be recovered; API exists in EXE but body unread and no script call to the size getter | **UNVERIFIED** | EXE `GetGameObjectSelectionSizeByHandle @0x240a3a`; RV-SEL-01 open q1; DEC-08 C3 | Sim `Rect2.has_point(e.pos)` centre test — **PORT APPROXIMATION** |
| 16 | Frustum flag semantics | `pickfrustum=true` meaning on the −32° perspective view (screen rect / projected quad / corner rays) | **UNVERIFIED** | `init.script:220` + EXE signature @`0x2a716e`; DSEL-02 claim 25; RV-SEL-01 open q9 | Absent |
| 17 | Outline colour | `RGBA(1,1,0,1)` — opaque **yellow** | **OBSERVED** | `brushes\selection.cfg` `Red=1, Green=1, Blue=0, Alpha=1`; RV-SEL-01 conflict 2 | 2D white `Color(1,1,1,0.9)`; 3D none |
| 18 | Outline thickness / style | `LineWidth = 1`; `LinePattern = 65535` (solid); `AntiAliased = False`; `LineStep = 1`; `Visible = True` | **OBSERVED** | `brushes\selection.cfg:3-14`; DEC-08 §6.1 | 2D 1.5 px; 3D none |
| 19 | Fill | No fill key exists in `selection.cfg`; donor record defines a **line only** (no fill). "No fill is rendered" is an inference from that absence | **OBSERVED** absence / INFERRED effect | `brushes\selection.cfg` full struct read (DEC-08 §6.1, RV-SEL-01 §Visual) | 2D adds `0.18` alpha fill — divergence |
| 20 | Brush binding | `SelectionBrushFileName = .\data\brushes\selection.cfg` | **OBSERVED** | `resources\resource.lib:47` @`0x002113`; DEC-08 C3 | No brush concept |
| 21 | Live rasterisation | That the brush is actually drawn during a live drag, and with what line-step semantics | **UNVERIFIED** | `menu.cfg:17-18` begin/end hooks empty; RV-SEL-01 open q4; DEC-08 C3/Q5 | N/A |
| 22 | Shift-add on drag | Shift held at threshold crossing → `spmAdd` (union); no Shift → `spmRunTime` (replace) | **OBSERVED** | `onmousemove.inc:156-162`; Gamepressure §3.2; almanac `select|addunitsofsametype` | Ignored for rectangle |
| 23 | Shift on single click | Click with Shift adds units; Ctrl on an already-selected object removes it | **OBSERVED** | `onmousedown.inc:281-344`; Gamepressure §3.2 | Partial (MICRO.md rows 28/31) |
| 24 | Select-same-type — double-click | Double-clicking a unit selects all units of that kind; combinable with Shift to add | **OBSERVED** | `onmousedown.inc:281` `bDouble` → `_misc_SelectAllUnitsOfType`; Gamepressure §3.2; donor `KeyDoubleDelay=0.5` | 0.35 s window, units only |
| 25 | Select-same-type — Ctrl | Ctrl+click on a unit selects all of that kind (same helper as double-click) | **OBSERVED** | `onmousedown.inc:281-291`; Gamepressure §3.2 | Partial |
| 26 | Select-same-type — Z variants | `Z`, `Shift+Z`, `Ctrl+Shift+Z`, `Ctrl+Z` = same-type / add / all-of-type variants; default `bselectallunitsonz = False` | **OBSERVED** | `hotkeys.cfg:154-206`; `onshortcut.inc:517-640`; almanac §7.3; `profile.script:32,260` | Partial |
| 27 | Empty-ground click | Clicking empty ground with no modifier deselects all | **OBSERVED** | `onmousedown.inc:346-356`; `onclear.inc:4-11` | Implemented in click path |
| 28 | Selection hotkeys | `Ctrl+A` all units, `Ctrl+B` buildings, `Ctrl+Q` ships, `Ctrl+P`/backtick idle peasants, `Ctrl+` all peasants, `Ctrl+M` idle mines; `Ctrl+0..9` groups, `Alt+0..9` recall | **OBSERVED** | `hotkeys.cfg:154-206`; `onshortcut.inc:517-640`; Gamepressure §3.2; almanac §7/§8 | Partial |
| 29 | Engine filter flags | `SetGameManagerSelectionSettings(false, true, true, true)` = `pickgroups=false`, `pickgamemanagerplayer=true`, `pickplayableObject=true`, `pickfrustum=true` | **OBSERVED** as call + param names; native use/order **UNVERIFIED** | `init.script:220` @`0x010267`; EXE signature @`0x2a716e`; almanac §1.2 | Absent |
| 30 | Post-filter ownership | `OnSelection` skips group handles, keeps only `TObj(pobj).pl = myPlInd` and playable objects | **OBSERVED** | `onselection.inc:34-43` @`0x001550/0x001859/0x002008`; `control.script:181,183`; almanac §1.2 | Hardcoded `player==0` only |
| 31 | Composition filter | Land units win over water units and buildings; guards dropped when a non-guard unit is present; squads selected whole (all members picked), `spmRemove` needs all members picked | **OBSERVED** | `onselection.inc:12-16,46-99,141-168`; `_control_GetSelectionInfo` `control.script:361-407` | Absent (`kind=="unit"` only) |
| 32 | Click player filter | Left-click pick is own-only: `_control_GetUnitUnderCursor(True)` — callee proves `True` ⇒ own player; order/guard/cursor paths pass `False` | **OBSERVED** | `onmousedown.inc:280` @`0x015449`, `:394/@0x022007`, `:480/@0x027000`, `:683/@0x040057`; `control.script:156,183` | Port `_pick(pw,false)` every player competes |
| 33 | Enemy inclusion by rectangle | Native rectangle enemy inclusion — script implies own-only, no runtime proof | **UNVERIFIED** | `pickgamemanagerplayer=true` + `onselection.inc:43`; RV-SEL-01 open q7 | N/A |
| 34 | Wall-build gate | Wall-build mode suppresses the marquee entirely (`else if not gWallCluster.buildWall`) | **OBSERVED** | `onmousemove.inc:140`; DSEL-01 §Detailed algorithm | Not mirrored |
| 35 | Wall highlights | Walls are explicitly skipped by the highlight updater (`visible := False`); dead and birth-state objects also skipped | **OBSERVED** | `gui.script:3393,3399-3400,3468-3469`; DSEL-01 claim 21 | Procedural rings, no donor mapping |
| 36 | Wall bug ("box selection broken after selecting a wall") | Reviewer-observed donor defect. Our port must **not** reproduce it — drag selection must keep working after a wall was selected; native cause unknown | **OBSERVED** as report; mechanism **UNVERIFIED** | WGB review §3.4; charter §1b.2; donor-adjacent evidence items 34-35 | No known regression; must add guard test |
| 37 | Gates | Whether a gate is a distinct selectable object in the native rectangle | **UNVERIFIED** | No distinct gate branch in `onselection.inc`; RV-SEL-01 open q7; DEC-08 has only gate **order** icons, not selection | N/A |
| 38 | Highlight materials / size | Names `selection.friend`, `selection.building.0..3`, `selection.ship.0/1`, `highlight.friend/ally/enemy`; DDS files exist; render size `0.7`, master `gc_settings_highlights=True`; building bucket from collision-mask mid `<5/<8/<12/else 3` | **OBSERVED** names/files/constants; engine render **UNVERIFIED** | `gui.script:3372-3472`; `init.script:111`; `dmscript.global:1019`; `brushes.mat:199-260`; DEC-08 §6.1 | PORT APPROXIMATION (procedural rings) |
| 39 | Selection sounds | `gc_snd_ind_selectpeasant=26`, `...selectship=27`; `selectpeasant1..6.ogg` + `selectship.ogg` loaded; played on unit-panel rebuild | **OBSERVED** indices/loading; playback timing **UNVERIFIED** | `dmscript.global:1276-1277`; `sound.script:206-208`; `showunitcontrol.inc:1015-1027`; RV-SEL-01 open q6 | Absent |
| 40 | Locale strings | No `selection`/`ghost` key in `gui.txt` (461 keys scanned) — selection/ghost are visual, not text | **OBSERVED** (negative scan) | DEC-08 §4.3 | N/A |
| 41 | Selection-use-step | `SetGameManagerSelectionUseStep(true)` native meaning (likely incremental selection) | **UNVERIFIED** | `docreate.inc:100`; RV-SEL-01 open q8 | N/A |

## 5. Reconstructed donor algorithm (authoritative, native parts marked)

```
# wiring (OBSERVED): menu.cfg:2,11,16,27-34; menu.aix state sections
StateOnMouseMove = OnMouseMove
StateOnProcessSelection = OnSelection
ProgressInterval = 10; KeyRepeatDelay = 0.05; KeyDoubleDelay = 0.5

# init once (OBSERVED): init.script:220
SetGameManagerSelectionSettings(false, true, true, true)

# LMB DOWN (OBSERVED): onmousedown.inc:116-359
if minimap_under_mouse: jump camera; exit
if attackpoint|patrol|guard|order mode or editor placing: handle order; exit
if build_ghost_active: place building; exit
goHnd := _control_GetUnitUnderCursor(True)        # OWN player only, ray→AABB
if bDouble or GUI_Ctrl:
    _misc_SelectAllUnitsOfType(... GUI_Shift ...)  # same-type + optional add
elif goHnd <> 0:
    if not Shift and not Ctrl: SetUnitsToSelection([goHnd])
    elif not already selected: AddUnitsToSelection([goHnd])
    elif Ctrl: RemoveUnitsFromSelection([goHnd]+squad)
else:
    if not Shift and not Ctrl: DeselectAllUnits(False)
ExecuteState('DoUpdateSelection')
# NOTE: down does NOT set isselectionstarted

# LMB HELD + MOVE (OBSERVED): onmousemove.inc:32-34,66-69,140-167
if wall_build_mode: skip marquee                                # :140
x,y,z := GetCurrentMouseWorldCoord(...)                         # :69  ground ray
epsilon := 0.005; if attackpoint or guard: epsilon := 0.25      # :32-34
if not isselectionstarted:                                      # :142
    isselectionstarted := true                                  # :144
    prevSelX := x; prevSelZ := z                                # :145-146 first move
else if not GameManagerIsSelectionMode and not brush and no ghost: # :150
    if Abs(x-prevSelX)>epsilon or Abs(z-prevSelZ)>epsilon:       # :152 world, axis-wise
        GameManagerBeginSelection                               # :154
        if Shift: GameManagerStartSelection('spmAdd')           # :157
        else:     GameManagerStartSelection('spmRunTime')       # :162
        # //Ctrl -> spmRemove DISABLED at :159-161
        ExecuteState('DoUpdateSelection')                       # :164

# LMB UP (OBSERVED): onmousedown.inc:364-390
isselectionstarted := false                                     # :365
if (not bDouble) and GameManagerIsSelectionMode:                 # :375-377
    GameManagerCancelSelection                                  # :379 finalize
    update_unitcontrol/rallypoints/cursor/sound := True
    attack/guard/attackpoint/patrol modes := False

# NATIVE (UNVERIFIED): GameManager collects picked objects.
# EXE exposes GetGameObjectSelectionSizeByHandle @0x240a3a; no script caller.

# OnSelection POST-FILTER (OBSERVED): onselection.inc:1-199
for i from CountPicked-1 downto 0:
    h := HandlePicked(i)
    if IsGroupByHandle(h): continue
    if pl<>myPlInd or not Playable(h): continue
    if buildings selected: drop when land units present
    elif water selected: drop when land units present
    elif guard and non-guard present: drop
    else: squad-collapse or Add + SetPicked(True)
```

## 6. Conflicts and boundaries

1. **Almanac `spmFrame` vs EXE enum** — almanac §1.1 names `spmFrame` as the
   per-frame box mode; the native 7-value enum has no such string. OBSERVED EXE
   enum wins; `spmFrame` is UNVERIFIED paraphrase, do not encode it as a mode.
2. **Almanac "per-frame `_control_*` scan" vs donor scripts** — local recon has
   `GameManager*` collecting a picked-object list and `OnSelection` filtering
   once; the almanac describes a per-frame script scan. Both are secondary
   recon prose vs byte-checked active script; keep the local model, mark the
   almanac model UNVERIFIED.
3. **Steam "map moves with you"** — OBSERVED prose, UNVERIFIED mechanism. Do not
   invent an edge-scroll speed.
4. **Wall bug** — reviewer OBSERVED, native cause UNVERIFIED; explicitly a
   **do-not-copy** defect per charter §1b.2.
5. **Script-side vs runtime** — following RV-SEL-01: `[*] = ;` is live code
   encoding (136 files / 39,074 lines, 0 exceptions), so all literals above are
   active donor intent. What remains UNVERIFIED is the native engine body
   (inside-box predicate, ray/AABB internals, brush rasterisation, sound/highlight
   timing, double-click producer), not the script text.

## 7. Concrete acceptance criteria for the port (no edits made here)

1. Two-phase start: press records nothing; first LMB-held move records world
   ground point; a *later* move crossing `0.005` m (`0.25` m in attack/guard)
   axis-wise starts the box.
2. Threshold in world metres from a ground ray hit — never screen pixels.
3. Shift → union (`spmAdd`), no Shift → replace (`spmRunTime`); no Ctrl-remove
   in the drag path.
4. LMB-up commits unless the event is a double-click (`not bDouble` guard);
   set the donor UI flags and clear order modes.
5. Overlay drawn in viewport pixels as opaque yellow `Color(1,1,0,1)`, 1 px,
   solid, no fill, `MOUSE_FILTER_IGNORE`, matching `brushes/selection.cfg`.
6. Post-filter: own player + playable + frustum (where available), land >
   water > buildings, guard dropped with non-guards, squads collapsed.
7. Keep click-pick own-only and the double-click / Ctrl / Z same-type family;
   use `0.5` s double-click window (`KeyDoubleDelay`).
8. Add a regression test: select a wall, then drag-box over units — the units
   must be selected. Reproducing the donor wall bug is a **failure**.
9. Label any footprint margin, AABB stand-in or screen-rect approximation
   `PORT APPROXIMATION`; do not invent donor constants for the native predicate.

## 8. Open questions — UNVERIFIED (blocking for true parity)

1. Native inside-box predicate (centre / AABB / selection-size / frustum quad).
2. `pickfrustum=true` maths on the −32° perspective view.
3. Mechanism behind "the map moves with you" during drag (Steam prose only).
4. Whether `selection.cfg` is rasterised live and with what line-step semantics.
5. Runtime dispatch chain for `onmousedown.inc` (`menu.cfg:12 StateOnMouseDown`
   is empty; hook/`ExecuteState` path derived, not observed).
6. Double-click event producer (`GetBoolValueByName('Double')`,
   `GetGUIShiftStateDouble`) and why `not bDouble` suppresses finalize.
7. Sound/highlight playback timing relative to rectangle release.
8. Enemy / wall / gate inclusion by the native rectangle.
9. `SetGameManagerSelectionUseStep(true)` native meaning.
10. Almanac-specific claims (`spmFrame`, per-frame `_control_*` scan,
    `SetClipCursor` for the frame) — secondary, not byte-verified.

## 9. Summary

The donor quad is a **world-space, two-phase marquee**: start point captured on
the first LMB-held move from `GetCurrentMouseWorldCoord`, threshold `0.005` m
(`0.25` m in attack/guard) axis-wise on X/Z, engine finish via
`GameManagerBeginSelection` + `GameManagerStartSelection('spmAdd'|'spmRunTime')`,
committed on LMB-up unless a double-click suppresses it, post-filtered to the
interface player's playable objects with land/water/building/guard/squad rules.
Its visible style is byte-exact: **opaque yellow `(1,1,0,1)`, 1 px, solid
`LinePattern=65535`, `AntiAliased=False`, `LineStep=1`, no fill field**, bound
through `resource.lib:47` → `brushes\selection.cfg`. Shift-add, double-click /
Ctrl / Z same-type, `KeyDoubleDelay=0.5` and the Ctrl+A family are confirmed by
both donor files and online sources. What stays **UNVERIFIED** is the native
inside-box predicate, frustum maths, brush rasterisation, drag-time camera pan
mechanism, sound/highlight timing and the wall-bug cause. The port currently
uses a 6-px screen threshold, a sim-ground centre-point rect with no Shift, no
composition filters, a white 1.5 px + 0.18 fill outline in 2D and no outline at
all in 3D — all recorded as divergences, not donor style.

No repo code, config, asset, test, scene, shader, Godot job or git state was
changed. Exactly one report file was written.
