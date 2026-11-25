---
title: "UITOP-DONOR-01 — donor resource-panel and game-speed UI truth for the top bar"
area: "donor truth → Godot 4 top bar (resource panel, speed control, responsive/dropdown form)"
owner: UITOP-DONOR-01
updated: 2026-11-25
status: READ_ONLY_DONOR_VERIFICATION__NO_CODE_EDIT__NO_DONOR_COPY
id: UITOP-DONOR-01
donor: "C:\\Games\\Cossacks 3 (read-only; Python 3.14 bytes/latin-1 decode; never executed, never copied into repo)"
scope: "Exactly ONE file written — this report. No game code, shared file, asset, config, test, or git edit. No Godot run."
labels: ["ACTIVE [*]=;", "ACTIVE-data", "intent-only ;", "OBSERVED-census", UNVERIFIED]
output: docs/coord_swarm_2026-11-25/reports/UITOP_DONOR_01.md
---

# UITOP-DONOR-01 — Donor resource panel & game-speed UI truth (top bar)

> [!NOTE]
> **Reading convention.** Donor GUI scripts under `D\gui\menu.inc\` and
> `D\gui\common.inc\` store executable code as a string literal, so every live
> line starts with the literal prefix `[*] = ;`. That prefix means **ACTIVE
> script code**, not a comment; the states are bound in `D\gui\menu.aix` (see
> DEC-08 §5.1). A line whose payload starts with `//`, sits inside `{…}`, is a
> declared-but-unused variable, or is plain prose is **intent-only**. `D` below
> means `C:\Games\Cossacks 3\data`; port paths are relative to the repo root.
> Every donor number was re-read in this pass (fresh `open(...,'rb').decode('latin-1')`
> numbered dump) after the prior docs, not copied from them.

---

## 1. Sources read

### Required prior docs (read in full this pass)

| Doc | Takeaway used |
|---|---|
| `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` | §4.3 locale keys, §5.3 HUD geometry, §8 port comparison, §9 open questions. Authority for menu state-machine binding (`menu.cfg`/`menu.aix`) which this report does not re-derive. |
| `docs/research/RE_VISUAL.md` | §2/§3 S11 text-only HUD description: pop/limit, idle villager, unused-mine slots, six resources with worker brackets, red negative gold, game menu, lower-left unit window. §5 marks the donor minimap corner **[U]**, since corrected by DEC-08 C1. |
| `docs/coord_swarm_2026-11-24/reports/W23_hud_fidelity.md` | Port already back-ported net `(income-consume)`, `9999999+` cap, hover hints, idle/mine buttons (`hud.gd`); item 4 (minimap bottom-right) NOT-DONE at that time; Q2 cap mismatch, Q3 condensed tooltips. |
| `docs/coord_swarm_2026-11-24/reports/R05_hotkeys_controls.md` | Row 17: donor speed keys Registration at `registershortcuts.inc:51-54,178-181`, handler cited there as `onshortcut.inc:2079-2130` (**this pass finds the real handler at `:1010-1075`**); port had no key handler and only `main.gd` API. Row 22: donor `Pause`, not `Space`. |

### Fresh donor reads (read-only)

`D\gui\menu.inc\showresourcepanel.inc` (431 lines / 26,758 B), `D\gui\menu.inc\eventresourcepanel.inc` (46 lines / 1,812 B), `D\game\var\hotkeys.cfg` (243 lines / 5,316 B), `D\scripts\lib\gui.script` (3,572 lines / 169,837 B), `D\gui\menu.inc\registershortcuts.inc`, `D\gui\menu.inc\onshortcut.inc`, `D\gui\menu.inc\showsettings.inc`, `D\gui\menu.inc\showcustomgame.inc`, `D\gui\menu.inc\eventsettings.inc`, `D\gui\menu.inc\eventcustomgame.inc`, `D\gui\menu.inc\writetimespeed.inc`, `D\gui\menu.inc\readtimespeed.inc`, `D\gui\menu.inc\showpause.inc`, `D\gui\menu.inc\initminimap.inc`, `D\gui\menu.inc\showunitcontrol.inc`, `D\gui\menu.inc\docreate.inc`, plus `D\scripts\dmscript.global`, `D\scripts\lib\control.script`, `D\scripts\lib\classes.script`, `D\locale\en\tools.txt`, `D\locale\en\gui.txt`, `D\hud\hud.mat`. A full `D` tree keyword sweep for `gamespeed` / `_control_SetGameSpeedByMode` / `WriteTimeSpeed` was also run (no additional UI definition found).

### Port read-only comparison

`variant3d/scripts/hud.gd`, `app/scripts/hud.gd`, `variant3d/scripts/data.gd`, `app/scripts/data.gd`, `variant3d/scripts/main.gd`, `app/scripts/main.gd`. No port file was edited.

---

## 2. Activity-label convention

| Label | Meaning |
|---|---|
| `ACTIVE [*]=;` | Literal `[*] = ;` line in a donor `.inc` — live state-machine code. |
| `ACTIVE data` | Operative constant/string in `.global`, `.script`, `.cfg`, `.txt`, `.mat` (no prefix exists in those formats). |
| `intent-only ;` | `//` comment, `{…}` block, commented-out constant, declared-but-unused variable, or prior-doc prose with no live line behind it. |
| `OBSERVED census` | File-wide count/absence established by reading the whole file or directory. |
| `UNVERIFIED` | Engine-side or runtime-only; no donor script/data definition found. No claim made beyond the cited call site. |

---

## 3. Donor truth — top resource panel

All `D\…` paths below are relative to `C:\Games\Cossacks 3\data`.

| # | Claim | Evidence (`path:line`) | Label | Notes |
|---|---|---|---|---|
| R1 | Panel state is `ShowResourcePanel`; its event state is `EventResourcePanel`. | `DEC_08_ui_strings.md:141` (`menu.aix:246-249`) | intent-only ; | Prior-doc binding only; not re-derived from `menu.aix` in this pass. |
| R2 | **Six** resources are shown: food, wood, stone, gold, iron, coal. Loop is `for i:=1 to gc_ResCount-1` with `gc_ResCount = 7`, and IDs 1..6 are the six resources. | `showresourcepanel.inc:76`; `dmscript.global:3`; `dmscript.global:792-797` | ACTIVE [*]=; + ACTIVE data | Slot 0 = `gc_resource_type_none` is skipped. `gui.txt:5-16` gives English names `Food…Coal` (DEC-08 §4.3). |
| R3 | **Visual order is wood, food, stone, gold, iron, coal** — display indices 1 and 2 are swapped (`i=1 → ind=2`, `i=2 → ind=1`). | `showresourcepanel.inc:87-90` | ACTIVE [*]=; | Trailing note `// swap wood and food visualization to correspond c1` at `:87` is a comment, but the swap itself is live code. |
| R4 | Slot pitch `cResourceSizeX = 162` px. Earlier 122 px and the `Max()` clamp are dead. | `showresourcepanel.inc:44`; `:24`,`:45` | ACTIVE [*]=; (`:44`) / intent-only ; (`:24`,`:45`) | `cResourceSizeXMin=0` declared at `:24`; clamp commented at `:45`; `// 122` is a trailing comment. |
| R5 | Slot X formula: `162*((i mod 7)-1) - (7 div 2)*162 + 84 + 5`, plus `+81` (half pitch) because the count is odd, then `cSideOffsetX=-10`: `-5` for `i<4`, `-6` otherwise. | `showresourcepanel.inc:78-85` | ACTIVE [*]=; | Centred strip; no hard-coded per-slot table. |
| R6 | Old button offsets `-362/1` are superseded by `cButtonOffsetX=11`, `cButtonOffsetY=40`. | `showresourcepanel.inc:19-22` | ACTIVE [*]=; (`:21-22`) / intent-only ; (`:19-20`) | The `-362/1` pair is `//`-commented. |
| R7 | Parent is top-left anchored, width `round(GetViewerWidth/dpiscale)`, height `GetGUITextureHeight('resourcepanel.background')`; visible outside the main menu. | `showresourcepanel.inc:54-57` | ACTIVE [*]=; | Background slice: `hud.mat:984-990` — `resourcepanel.background`, `tex03`, `ImageH=512`, UV `(386,183)`, size `1159×58` → 58 px slice before scaling. |
| R8 | Background image `resbackground` is middle/top anchored at `(xoff, -7)`, size 0×0 (native texture size). | `showresourcepanel.inc:64`; `:25` (`cResourceOffY=-7`) | ACTIVE [*]=; | |
| R9 | Resource text uses `gc_font_serif_13`, colour `(0.9219*0.94, 0.75*0.98, 0.59375*0.98)` with black shadow, drawn at `(x+xoff, -11)` in a `cResourceSizeX`-wide box. | `showresourcepanel.inc:69-73`, `:139` | ACTIVE [*]=; | |
| R10 | Stock is `IntToStr(res[ind])`; if `res[ind] > 99999999` the text becomes locale `resourcepanel.lotofresources` (`9999999+`). | `showresourcepanel.inc:101-103`; `gui.txt:251-252` (DEC-08 §4.3) | ACTIVE [*]=; | 8-digit script threshold vs 7-digit locale literal — W23 Q2 / DEC-08 C9. |
| R11 | Net readout: `income = counter.workersonres[ind]`; for `ind >= gold`, `rawconsume = floor((resconsume[ind]*32/100)/250)`, `income1 = floor(income-rawconsume)`, `income2 = floor(rawconsume)`; prints `(income-consume)` when `consume>0` else `(income)`, darkgrey when `income1>=0`, **red otherwise**. | `showresourcepanel.inc:105-125`; `classes.script:7402` (`workersonres`); `dmscript.global:1807-1811` | ACTIVE [*]=; + ACTIVE data | Applies only to gold/iron/coal; food/wood/stone stay gross. Legacy gross block at `:127-137` is `//`-commented → intent-only ;. |
| R12 | Six hover hit rects `resourcehintN`, width `cResourceSizeX-10 = 152`, y `-17`; x offset `-160` when `dpiscale=2`, else `-60`; hint text prefixed with `gc_font_sans_13` plus `.add` lines for wood/stone/gold/iron/coal. | `showresourcepanel.inc:141-144`; `:28-33` | ACTIVE [*]=; | Strings from `gui.txt:227-248` (DEC-08 §4.3). |
| R13 | Population element `population` is a 142-px-wide hit rect at `(0,5)` with `icons.nofarm` at `(0,3)` and a fade loop when at cap; text `_txt_population` at `x=cPopulationOffsetX=64`, font `gc_font_sans_12`. | `showresourcepanel.inc:163-178`, `:202`; `:26` | ACTIVE [*]=; | Cap cases use `gc_mapsettings_limit_1..8` at `:152-161` and `:190-200`; values `500/750/1000/1500/2200/3000/5000/8000` at `dmscript.global:1090-1097`. `farmused/farmexist` strings come from the `misc` table (`:182-200`). |
| R14 | Idle-peasant button `_img_idlepeasants`/`_btn_idlepeasants` at `(3, 64+posY)`, serif-14 count, user-blend `1` when count>0 else `0.4`. | `showresourcepanel.inc:219-229` | ACTIVE [*]=; | `SetGUIElementVisible` toggle at `:230` is `//`-commented → intent-only ;. |
| R15 | Unused-mine button `_img_idlemines`/`_btn_idlemines` at `(3, 64+posY+50)`, blend `1` when count>0 else `0.5`. | `showresourcepanel.inc:232-243` | ACTIVE [*]=; | Visibility toggle at `:243` is `//`-commented → intent-only ;. |
| R16 | `posY = 50` when any scenario objective is visible, else 0; objectives parent `objs` at `(59+cpadding, 66+cpadding-8)` with `cpadding=8` (`38` only when `bPaper=True`, a design-test flag). | `showresourcepanel.inc:204-218`, `:261-268` | ACTIVE [*]=; | `bPaper` is a **declared toggle set to False** (`:261`), so the 38-px branch is effectively intent-only ;. |
| R17 | Objectives show/hide switch `_img_switchobjectives` at `(3,64)` with button tag 112; click toggles `gInterface.bhideobjectives`. | `showresourcepanel.inc:293,301`; `eventresourcepanel.inc:18,37-41` | ACTIVE [*]=; | Label text from `misc` at `showresourcepanel.inc:40-42`. |
| R18 | Game-menu button `btnmenu` is right-width anchored at `(-1,1)`, text `menu.gamemenu`, serif-13. The `{+' (F10)'}` suffix is inactive. | `showresourcepanel.inc:418-427` | ACTIVE [*]=; (`:425-427`) / intent-only ; (`:426` suffix) | Menu show/close tags chosen at `:419-423`. |
| R19 | Low-food warning icon block is entirely inside `{…}` and never executes. | `showresourcepanel.inc:398-416` | intent-only ; | The locale string `resourcepanel.lowfood` is loaded at `:37` and `cTextLowFood` is otherwise unused here. |
| R20 | Panel hides in main menu only; no other mode gate. | `showresourcepanel.inc:57` | ACTIVE [*]=; | |

### 3.1 Window-size dependence of the donor panel

| # | Rule | Evidence | Label |
|---|---|---|---|
| W1 | `dpiscale := _gui_GetAbsScaleByDPI(0,0)`; **forced to `1` when `GetViewerWidth < 2520`**; if `GetViewerWidth < 1260`, `dpiscale := GetViewerWidth/1260`. Parent width/scale use this value. | `showresourcepanel.inc:46-49`, `:52-56` | ACTIVE [*]=; |
| W2 | `basedpiscale` keeps the *pre-force* DPI value; it is used for the `xoff` decision, while `dpiscale` (possibly forced) is used for parent width and `-45*dpiscale`. | `showresourcepanel.inc:47,49,53,59-60` | ACTIVE [*]=; |
| W3 | `xoff = -45*dpiscale` if `GetViewerWidth/basedpiscale < cminwidth (1280)`; `xoff = -100` if `< 1440`; otherwise unassigned (effectively 0). | `showresourcepanel.inc:50-51`, `:58-63` | ACTIVE [*]=; |
| W4 | Variables `minwidth := 1440` and `cResourceSizeXMin := 0` are declared but never read. | `showresourcepanel.inc:50`, `:24` (+ commented clamp `:45`) | intent-only ; |
| W5 | Hint hit-rect x offset changes at `dpiscale=2` (`-160` vs `-60`). | `showresourcepanel.inc:141-144` | ACTIVE [*]=; |
| W6 | All geometry is computed from `GetViewerWidth`/`GetViewerHeight`-family engine calls; **no fixed 1280/1920 design resolution is hard-coded as a layout basis**. | `showresourcepanel.inc:48-54`, `:139` (`GetGUIElementHeight(elmParent)`); `hud.mat:986-990` | ACTIVE [*]=; + ACTIVE data |
| W7 | The engine internals of `GetViewerWidth`, `_gui_GetAbsScaleByDPI`, `_gui_AbsScaleByDPI`, `_gui_SetAbsScale` and `GetGUITextureHeight` are not defined in any donor script. | call sites above; no definition found in `D\scripts` | UNVERIFIED |

### 3.2 Event behaviour

| # | Claim | Evidence | Label |
|---|---|---|---|
| E1 | Tags: `110` idle peasants, `111` idle mines, `112` objectives toggle; menu show/close use `gc_gui_event_tagShow/tagClose`. | `showresourcepanel.inc:13-17`; `eventresourcepanel.inc:16-18` | ACTIVE [*]=; |
| E2 | On click (`press='c'`), show first cancels a pending build dummy (`_misc_GUICancelBuilding(True,False)`), forwards to `EventMenu`, and invokes mouse-move; close forwards tagClose. | `eventresourcepanel.inc:19-30` | ACTIVE [*]=; |
| E3 | On down (`press='d'`), 110 → `EmulateGUIShortcut('select\|idlepeasants')`, 111 → `'select\|idlemines'`, 112 flips `gInterface.bhideobjectives`. | `eventresourcepanel.inc:31-43` | ACTIVE [*]=; |

---

## 4. Donor truth — game speed

### 4.1 `hotkeys.cfg` contains **no** speed bindings

| # | Claim | Evidence | Label |
|---|---|---|---|
| H1 | `D\game\var\hotkeys.cfg` is 243 lines / 5,316 B with 55 `Action` rows. Speed has **zero** rows there — the file covers build (`C,H,L,B,E,S,R,D,K,J,I,O,M,N,P,T`), unit orders, interface/select, and main-menu events only. | `hotkeys.cfg:1-243` (full read); count corroborated by `R05_hotkeys_controls.md:10,16` | OBSERVED census |
| H2 | The file is reached as a default constant, overridable from the save dir: `gc_filepath_hotkeys_default = '.\data\game\var\hotkeys.cfg'`, `gc_filepath_hotkeys_relative = 'hotkeys\hotkeys.cfg'`; loader prefers the save-dir copy. | `dmscript.global:1353-1354`; `registershortcuts.inc:187-221` | ACTIVE data + ACTIVE [*]=; |
| H3 | Therefore speed keys are **static registrations in `registershortcuts.inc`**, not user-editable through `hotkeys.cfg`. | `registershortcuts.inc:51-54`, `:178-181` (vs `hotkeys.cfg:1-243`) | ACTIVE [*]=; + OBSERVED census |

> **Correction to R05:** R05 row 17 locates the speed handler at `onshortcut.inc:2079-2130`. That file has only 1,333 lines. The actual handler is `onshortcut.inc:1010-1075`.

### 4.2 Speed keys and handler

| # | Claim | Evidence | Label |
|---|---|---|---|
| S1 | Four static registrations: `Sub`/`-` decrease, `Add`/`=` increase, all `spiDown`, filter `Shift+Ctrl+Alt`, state `OnShortcut`. | `registershortcuts.inc:51-54` | ACTIVE [*]=; |
| S2 | Four more: `[` decrease, `]` increase, `Ctrl+Sub` decrease, `Ctrl+Add` increase. | `registershortcuts.inc:178-181` | ACTIVE [*]=; |
| S3 | Dispatch is by registered **name**, not raw key: `name := GetValueByName('Name')`, then `case name of`. | `onshortcut.inc:129`, `:667` | ACTIVE [*]=; |
| S4 | `[` / `Ctrl+Sub`: **debug/editor only** (`bCheatNoSpeedLimit` or editor gamemode); halves `GetTimeSpeedFactor` via `WriteTimeSpeed`, clamped `0..100` when not devmode. | `onshortcut.inc:1010-1024` | ACTIVE [*]=; |
| S5 | `]` / `Ctrl+Add`: same gate; doubles the factor. | `onshortcut.inc:1025-1039` | ACTIVE [*]=; |
| S6 | `Sub` / `-`: offline or single-client or (online with map gamespeed `<0` after start); at speed 0 and not already paused it routes to `Pause`; otherwise `_misc_ClampInt(gProfile.igamespeed-1, 0, gc_settings_gamespeed_count-1)` → `_control_SetGameSpeedByMode(...,True)`. | `onshortcut.inc:1040-1057` | ACTIVE [*]=; |
| S7 | `Add` / `=`: at speed **0** with a progressing pause it *unpauses* instead of incrementing; otherwise increments with the same clamp. | `onshortcut.inc:1058-1075` | ACTIVE [*]=; |
| S8 | Stepping is gated by `gbool_gui_querywindow` and by network state; speed 0 is **not** "pause" by itself — pause is a separate flag (`GetProgressingPauseMode`). | `onshortcut.inc:1042-1043`, `:1060-1063`; `showpause.inc:12` | ACTIVE [*]=; |
| S9 | Pause is bound to `Pause` and `Ctrl+Shift+P`; `Space`/`SpaceD` are camera-to-selected, not pause. | `registershortcuts.inc:47-48`, `:27`, `:30`; `R05_hotkeys_controls.md:22,37` | ACTIVE [*]=; + intent-only ; (prior doc) |
| S10 | Pause handler has online rate limits (`gc_pause_timelimit`, `gc_pause_countlimit`); `showpause.inc` draws `gui|text.pause` on a full-viewport parent. | `onshortcut.inc:951-975`; `showpause.inc:4-24`; `gui.txt:217-218` | ACTIVE [*]=; + ACTIVE data |

### 4.3 Speed options (the real donor step table)

| # | Claim | Evidence | Label |
|---|---|---|---|
| T1 | `gc_settings_gamespeed_count = 3`; `gc_settings_gamespeed_default = -1`; factors `gc_settings_gamespeed_0 = 7`, `_1 = 10`, `_2 = 14`. A fourth `_3 = 20` is commented out. | `dmscript.global:1025-1030` | ACTIVE data (`:1025-1029`) / intent-only ; (`:1030`) |
| T2 | `_control_GetGameSpeedMode()` maps factor `7/10/14` → mode `0/1/2`; unknown factor logs an error. | `control.script:535-547` | ACTIVE data |
| T3 | `_control_SetGameSpeedByMode(mode,bLan)` maps `0/1/2` → `7/10/14` (default `10`), then calls `GUIExecuteState('WriteTimeSpeed')` with registers `(speedfactor, mode)`. Mode 3 is commented out. | `control.script:551-570` | ACTIVE data / intent-only ; (`:559`) |
| T4 | English option labels: `CFG.PROFILE.GAMESPEED` = **"Game speed"**; `.0` = **Normal**, `.1` = **Fast**, `.2` = **Very Fast**, `.-1` = **Adjustable**. | `locale/en/tools.txt:197-206` | ACTIVE data |
| T5 | Applied at game create from map setting; reapplied on LAN resync, menu/options close and load. | `docreate.inc:163`; `doprogress.inc:1350`; `eventmenu.inc:100-101`; `eventsettings.inc:783-784`; `scripts/common.inc/onloadfull.inc:120` | ACTIVE [*]=; |
| T6 | Online speed is replicated via `WriteTimeSpeed`/`ReadTimeSpeed` records carrying `(float speed, int igamespeed)`; server/client roles are explicit. | `writetimespeed.inc:1-22`; `readtimespeed.inc:1-37`; `gui/menu.aix:431` | ACTIVE [*]=; + ACTIVE data |
| T7 | LAN tick smooths received speed with `Clamp(percent, 0.875, 1.125)` before `SetTimeSpeedFactor`. | `onlaneventsession.inc:208-236`; `doprogress.inc:1435-1436` | ACTIVE [*]=; |
| T8 | Map/options UI: `CFG.VALUE.GAMESPEED` dropdown, count `3` offline / `4` online (adds `-1` Adjustable); values rendered as `'0'/'1'/'2'/'-1'`; label `CFG.PROFILE.GAMESPEED`. | `showcustomgame.inc:852`, `:948-955`, `:984`, `:1055-1060`, `:1238-1259`; `eventcustomgame.inc:85`; `eventhistoricalbattle.inc:62` | ACTIVE [*]=; |
| T9 | Options → Game speed combo `igamespeed`, width 256, filled from engine config; in an online game with map-enforced speed the other list items are deleted (host lock). | `showsettings.inc:566`, `:1056-1089`; `eventsettings.inc:162`, `:538-548` | ACTIVE [*]=; |
| T10 | `SetTimeSpeedFactor`, `GetTimeSpeedFactor`, `GetProgressingPauseMode`, `RegisterGUIShortcutIgnoreShift`, `EmulateGUIShortcut`, `_gui_GetAbsScaleByDPI` are engine APIs — no donor definition exists in `D\scripts`. | call sites listed above; no definition found | UNVERIFIED |

### 4.4 Is there a donor in-game top-bar speed widget?

| # | Claim | Evidence | Label |
|---|---|---|---|
| U1 | **No speed control element is created by `showresourcepanel.inc`.** A full 431-line read shows only: background, six resource slots, population, idle/mine buttons, objectives block, menu button. | `showresourcepanel.inc:1-431` (whole file) | OBSERVED census |
| U2 | A keyword sweep of every file in `gui\menu.inc\` + `gui\common.inc\` finds speed references only in: shortcut registration/dispatch, settings & custom-game combos, pause, LAN sync, save/record states, and camera-scroll speed. No HUD speed button/label. | `registershortcuts.inc:51-54,178-181`; `onshortcut.inc:1010-1075`; `showsettings.inc:1056-1089`; `showcustomgame.inc:1055-1060`; `showpause.inc`; `onlaneventsession.inc:208-236`; `writetimespeed.inc`; `readtimespeed.inc` | OBSERVED census |
| U3 | `scripts\lib\gui.script` contains **no** resource-panel layout constants; the only relevant line is a config load. The resource-panel constants live in `showresourcepanel.inc` and `dmscript.global`. (Prompt premise corrected.) | `gui.script:2647` (`ParserLoadFromFile('.\data\resources\config.res')`); `gui.script:1-3572` (full keyword scan) | OBSERVED census |
| U4 | Donor speed UI therefore = **hotkeys + menu/skirmish dropdowns + engine pause overlay**, not a clickable in-game top-bar control. A top-bar dropdown/button is a port design addition. | U1 + U2 + T8 + T9 + `showpause.inc:4-24` | OBSERVED census |

---

## 5. Port comparison (read-only) — elements that must survive a responsive/dropdown bar

### 5.1 Current port state

| Donor truth (cite) | Port state (cite) | Verdict |
|---|---|---|
| Six resources, visual order wood→food→stone→gold→iron→coal, stock + net, red deficit (`showresourcepanel.inc:76-125`, `:87-90`) | `variant3d/scripts/hud.gd:407-418` six icon/label pairs; `:104-116` `RES_TOOLTIPS`; readout at `:1141-1157`-analogue (W23 `hud.gd:1141-1167`) | Semantic parity; visual swap and verbatim donor colour constants not asserted. |
| Six hover hit rects with locale hints (`showresourcepanel.inc:141-144`) | `variant3d/scripts/hud.gd:412-413` `ic.tooltip_text = RES_TOOLTIPS[i]` | Closest Godot equivalent; condensed English (W23 Q3). |
| Population/farm warning with `icons.nofarm` (`showresourcepanel.inc:151-202`) | `variant3d/scripts/hud.gd:1491-1498` status line `"units %d/%d score %d …"` uses `farm_cap`; no dedicated nofarm icon/fade | **Gap** — donor element absent from top bar. |
| Idle-peasant / idle-mine **buttons** (`showresourcepanel.inc:219-243`; `eventresourcepanel.inc:35-36`) | `variant3d/scripts/hud.gd:419-431` `eco_label`, `mines_btn`; handlers `:649-659`; disabled at zero `:1479,1490` | Present; W23 FIXED. |
| Objectives show/hide switch tag 112 (`showresourcepanel.inc:293,301`; `eventresourcepanel.inc:37-41`) | `variant3d/scripts/hud.gd:604-625` `obj_panel` only; no toggle button found | **Gap** — donor toggle absent. |
| Menu button right-anchored (`showresourcepanel.inc:425-427`) | `variant3d/scripts/hud.gd:448-451` `mb` in top bar, not right-anchored | Present but placement differs. |
| Full-width DPI-scaled top-left parent (`showresourcepanel.inc:46-64`) | `variant3d/scripts/hud.gd:394-407` full-width `Control`+`PanelContainer`+`HBoxContainer`, `mouse_filter=IGNORE`; `_layout_top` `:512-588` | Port already responsive (UI-TOPBAR-01); thresholds `1000/700/560` vs donor `2520/1260/1440/1280`. |
| Speed = 3 modes `7/10/14`, labels Normal/Fast/Very Fast, pause separate (`dmscript.global:1025-1030`; `tools.txt:197-206`; `onshortcut.inc:1040-1075`) | `variant3d/scripts/hud.gd:444-447` `OptionButton` items `II/1x/2x/4x`; `:590-642` index bridge + `refresh_speed`; `variant3d/scripts/data.gd:384` `DONOR_GAME_SPEED={slow:0.5,normal:1.0,fast:2.0,very_fast:4.0}`; `main.gd:362` clamp `0.1..8.0` | **Divergent values and labels.** Port's `DONOR_GAME_SPEED` is not donor data. Donor `0` = Normal(7), port `0.0` = pause/II; donor has no `slow` and no `4x` step. |
| `app/scripts/hud.gd` (2D path) still uses four speed buttons | `app/scripts/hud.gd:357-371` `speed_buttons`, `:423-430` `refresh_speed`/`_on_speed` | Not converted to dropdown; donor truth unaffected. |

### 5.2 Constraints for the responsive/dropdown bar (do not edit — requirements only)

1. **Keep all six resource icon+label pairs present in every width mode.** The port's own rule already states this (`variant3d/scripts/hud.gd:508-511`); donor has six fixed slots (`showresourcepanel.inc:76-90`) and never drops one on narrow windows — it only shifts `xoff` (`:58-63`) and DPI-scales (`:46-56`).
2. **Keep the per-resource deficit state** (food famine, gold/iron/coal red) (`showresourcepanel.inc:101-125`; `gui.txt:59-60,77-78`); a dropdown/responsive pass must not collapse the six labels into a single summary that loses colour.
3. **Keep the two clickable idle/mine buttons** (`showresourcepanel.inc:221-243`; `eventresourcepanel.inc:35-36`), including their disabled/dim state; they are data-driven actions, not decoration.
4. **Keep hover/hint affordances** (`showresourcepanel.inc:28-38,141-144`); when controls become a popup, the equivalent `tooltip_text` must survive on each resource item.
5. **Keep a reachable game-menu control** (`showresourcepanel.inc:425-427`) and a reachable speed/pause control in all width modes (`variant3d/scripts/hud.gd:580-582`, `:628-637`). Hiding the speed menu at `ultra` width would break donor-equivalent hotkey feedback.
6. **Keep click-through on empty band space** — port-only requirement so map clicks/orders still work (`variant3d/scripts/hud.gd:391-402`); donor has no analogous script (engine hit-rect model, UNVERIFIED).
7. **Population and objectives controls are donor-present but port-absent** (`showresourcepanel.inc:151-202,293,301`). If the bar is re-laid-out, reserve space or explicitly scope them as follow-up gaps rather than silently dropping them.
8. **Speed values/labels must be a policy decision, not an accident.** Any dropdown in the port currently offers port floats (`variant3d/scripts/data.gd:384`); donor truth is `7/10/14` with `Normal/Fast/Very Fast` (`dmscript.global:1025-1029`; `tools.txt:197-206`). Either label the port steps as port-only or add a donor-mode mapping; do not claim current values are donor parity.
9. **Pause semantics**: donor `Pause`/`Ctrl+Shift+P`, `Space` = camera-to-selected (`registershortcuts.inc:47-48,27,30`; R05:22) vs port `Space` = pause (`R05_hotkeys_controls.md:22,37`). The dropdown's "II" item is a port convention, not a donor mode.

---

## 6. Open questions

1. **Top-bar speed widget absence** — confirmed only by static script census (`showresourcepanel.inc:1-431` + full `gui/*.inc` sweep). A donor screenshot (never opened here) could still show an engine-drawn speed readout; if so it is engine-side and **UNVERIFIED**.
2. **Factor meaning of `7/10/14`** — `gc_settings_gamespeed_*` are passed to `SetTimeSpeedFactor` (an engine call). Whether they are multipliers, tick budgets, or an internal clock divisor is **UNVERIFIED**; no donor definition found (`control.script:563` even has the direct `SetTimeSpeedFactor` line commented out and routes through `WriteTimeSpeed`).
3. **`gamespeed = -1` ("Adjustable")** — label observed at `tools.txt:205-206`; the runtime resolution of server-enforced speed is in `onlaneventsession.inc:208-236` + engine, not fully determined here.
4. **`minwidth := 1440` and `cResourceSizeXMin := 0`** — dead locals (`showresourcepanel.inc:50,24`). Were they intended as a minimum-width clamp that was removed? No other donor file resolves this.
5. **`xoff` unassigned branch** — when `GetViewerWidth/basedpiscale >= 1440`, `xoff` is never set (`showresourcepanel.inc:58-63`); whether the script engine zero-initialises locals is engine-side **UNVERIFIED**.
6. **Cap inconsistency** — script `99999999` vs locale `9999999+` (`showresourcepanel.inc:102`; `gui.txt:251-252`); still unresolved (W23 Q2 / DEC-08 C9).
7. **Handler line drift** — R05 cites `onshortcut.inc:2079-2130`; the file is 1,333 lines and the real handler is `:1010-1075`. Sibling docs should be updated by their owners; this report only records the discrepancy.
8. **Port speed policy** — `DONOR_GAME_SPEED` (`variant3d/scripts/data.gd:384`) is mislabelled relative to donor factors. Owner decision needed: rename as port-only, or add a true donor-mode table.
9. **Objectives/population controls** — donor-present but port-absent; whether to add them during the responsive-bar work or track separately is a scope decision.
10. **Concurrent workers** — `variant3d/scripts/hud.gd:108-112,390-447,505-642` already carries `UI-TOPBAR-01` changes. This report is a read-only snapshot; line numbers may drift if that worker edits again.

---

## 7. Summary

- The donor top strip (`showresourcepanel.inc`) is a **full-viewport-width, top-left, DPI-scaled parent** whose height comes from the `resourcepanel.background` atlas slice (58 px at `hud.mat:984-990`), with **six** resource slots at 162 px pitch, visual order **wood, food, stone, gold, iron, coal** (food/wood swapped at `:87-90`), gross brackets for the first three and **net `(income-consume)`** in darkgrey/red for gold/iron/coal (`:101-125`), six hover-hint hit rects, a population/farm warning, idle-peasant and idle-mine **buttons**, an objectives toggle, and a right-anchored menu button. All geometry derives from `GetViewerWidth`/`_gui_GetAbsScaleByDPI`, with shift-only (`xoff`) adaptation on narrow windows — no fixed design resolution.
- The donor game speed is **three** modes (`0/1/2` → factors `7/10/14`; mode `3=20` commented out) labelled **Normal / Fast / Very Fast**, plus `-1 = Adjustable` online, and a separate pause state. Speed keys are static registrations (`Sub/Add/-/=`, `[`/`]`, `Ctrl+Sub/Add`) in `registershortcuts.inc`; **`hotkeys.cfg` has no speed rows**. `[`/`]`/`Ctrl+Sub`/`Ctrl+Add` are debug/editor-only in the handler; `Sub`/`Add` step the profile index and toggle pause at speed 0.
- There is **no donor in-game top-bar speed widget** in any script; the speed UI lives in the settings/skirmish dropdowns (`showsettings.inc`, `showcustomgame.inc`) and the pause overlay. A responsive/dropdown speed control in the port is a design addition, and its current values (`0.5/1/2/4`) are **not** donor values.
- The port comparison identifies elements that must remain present through a responsive/dropdown pass: all six resources + deficit colours, hover hints, idle/mine buttons, menu and speed/pause access, click-through band; population and objectives toggle are donor-present gaps.
- No donor file was copied or executed; no code file was edited. Only this report was written.
