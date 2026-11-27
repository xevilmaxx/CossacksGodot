---
id: DEC-U-SETTINGS-PERSIST
worker: DEC-U-SETTINGS (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo source/asset/config/Godot/git edit: this report is the only file written."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All captures below are owner-authorised procedures, not worker runs."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT = port-side fact"
context: "DEC_U_menu_peace.md left U-S1 (port config save-side no writer, persistence UNVERIFIED); port config.json is a preserve-only user mod with donor/color changes, and config_donor_capture.json has demo_mill=true. Owner forbids overwriting those files."
---

# DEC-U-SETTINGS-PERSIST — donor settings persistence law: what is written, where, on what trigger (2026-11-26)

## 0. Pin + multi-pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, SHA256 `87F0F3C1…4E16C` (matches `DEC-U-MENU-PEACE` §0 / `DEC-U-VICTORY-START` §0 / X01 §2 E2). No execution, copy, or target-open. Size/hash re-cited from landed reports, not re-hashed by running anything. |
| P2 | Startup-ini reads | `C:\Games\Cossacks 3\cossacks.ini:1-7` + `C:\Games\Cossacks 3\editor.ini:1-24` read verbatim (§1, EV-SP-01/02). |
| P3 | `startingsettings.cfg` key sweep | Case-insensitive grep `victory\|score\|timelimit\|time_limit\|peaceful\|wincondition\|startingunits\|peacetime\|additional` over `data/game/var/startingsettings.cfg` → only `startingunits` comment hits, 0 gameplay-persistence keys (§2, EV-SP-03). Extends `DEC-U-VICTORY-START` §1.3 P12 and `DEC-U-MENU-PEACE` §5 P9. |
| P4 | Menu-settings init + write trigger reads | `data/gui/menu.inc/initmapsettings.inc:1-53`, `eventcustomgame.inc:320-392`, `donewgame.inc:1-171`, `showcustomgame.inc:828-1151` read verbatim (§3, EV-SP-04/05/06). |
| P5 | Profile persistence reads | `data/scripts/lib/profile.script:7-62` (`_profile_SetDefault`), `:269-281` (save-struct), `:615-652` (save/load user profile), `:729-737` (boot sequence) (§4, EV-SP-07/08/09). |
| P6 | Struct + enum reads | `data/scripts/lib/classes.script:58-88` (`TMapSettingsAdditional`/`TMapSettingsGen`/`TMapSettings`), `:115-128` (`TMap`), `:5090-5146` (`TProfile`), `:5191-5206` (`TProfileUserStruct`); `data/scripts/dmscript.global:1025-1098` (gamespeed/startingunits/balloon/cannons/peacetime/century18/capture/marketdip/teams/limit enums) (§4-§5, EV-SP-10/11). |
| P7 | Conversion + options-menu write reads | `data/scripts/lib/misc.script:4262-4282` (`_misc_GetPeaceTime` incl `*60`); `data/gui/menu.inc/eventsettings.inc:692-734` (Accept writer), `:729` (hotkeys path); `data/gui/menu.inc/showsettings.inc:587-592` (config.res fallback) (§4, EV-SP-12/13). |
| P8 | Native-boundary negative search | Grep `procedure UserSaveProfile\|function GetAppSaveDirectoryPath\|procedure StateMachineGlobalVariablesSaveToParser\|function ParserSelectUser` over `data/scripts` → **0 script definitions** [O-absence] (§4, EV-SP-14). These are engine natives; file bytes under `GetAppSaveDirectoryPath` were never read or executed by this worker. |
| P9 | Port read-only inspection (no edit) | `app/scripts/{config,menu,main,data}.gd` + `variant3d/config.json` + `variant3d/config_donor_capture.json` peace/victory/save lines (§7, EV-PORT). `app/config.json` + `variant3d/config.json` treated as preserve-only per owner directive; neither opened for write. |
| P10 | Cross-check | Reconciled against `DEC-U-MENU-PEACE` §4-§5/§8 U-S1, `DEC-U-VICTORY-START` §1.3/§2, X09 §4-§5 (cfg is placement masks, not settings store). No contradiction; two prior imprecise cites corrected (§8). |

## 1. `cossacks.ini` / `editor.ini` — startup files, NOT a settings store [O]

### 1.1 Verbatim content

EV-SP-01 [O] `C:\Games\Cossacks 3\cossacks.ini:1-7`:

```
section.begin
   GameSaveDirectoryPath=cossacks
   LogFileEnabled = false
   LogFileRoot = false
   LogFileName = cos
   HideHelloScreen = true
section.end
```

EV-SP-02 [O] `C:\Games\Cossacks 3\editor.ini:1-24`:

```
section.begin
   EditorMap =
   FullScreen = false
   DisableDebug = false
   NoGUI = false
   FixSize = false
   FixPos = false
   FixSize.Width  = 800
   FixSize.Height = 600
   FixSize.Left   = 50
   FixSize.Top    = 50
   AutoRunState = OnAutoRunEditor
   ConstLODFactor = 1.0
   HideHelloScreen = true
   LogFileEnabled = false
   LogFileRoot = false
   LogFileName = cos
   GameSaveDirectoryPath=cossacks
section.end
```

### 1.2 Format + persistence law [O/D]

- Format [O]: `section.begin` / `section.end` wrapper, one `Key = value` or `Key=value` per line, CRLF. Same grammar as `startingsettings.cfg` outer wrapper, but these two files carry no game struct.
- Keys present [O]: save-directory name, log flags, hello-screen flag (both files); editor-only window geometry (`FixSize.*`), `EditorMap`, `FullScreen`, `DisableDebug`, `NoGUI`, `AutoRunState`, `ConstLODFactor`.
- Keys ABSENT [O-absence]: victory, score, scorelimit, timelimit, peace, peacetime, AI, difficulty, map, terrain, relief, season, richness, startingunits, balloon, cannons, capture, marketdip, teams, limit, gamespeed, autosave, adviserassistant. Grep over both files for those stems → 0 hits (P2 re-read).
- Writer [D, forced by P8 + full grep]: NO `ParserSaveToFile*`, `UserSaveProfile*`, or ini-write call in `data/scripts` or `data/gui/menu.inc` targets either ini file (P2/P8 greps for `cossacks.ini|editor.ini|GameSaveDirectoryPath` as a *write target* → only reads of the directory name; the single `GetAppSaveDirectoryPath` consumers are `resource.lib` at `profile.script:111,125,141,161,206` and `hotkeys.cfg` at `eventsettings.inc:729`, never either ini). The ini files are engine-startup inputs; menu Apply writes elsewhere (§4).
- Default [D]: no in-file default mechanism; absent key = engine built-in. No default value is stated in text for any ini key, so none is recorded here (never invent a default).
- `GameSaveDirectoryPath=cossacks` [O] is the ONLY persistence-path law in these files: it names the save-directory suffix appended to the engine `GetAppSaveDirectoryPath` for the native user-profile store (§4). It is not itself a gameplay setting.

## 2. `startingsettings.cfg` — static placement data, NEVER written [O]

- Identity [O]: `C:\Games\Cossacks 3\data\game\var\startingsettings.cfg`, path literal `dmscript.global:1358` `gc_filepath_startingsettings = '.\data\game\var\startingsettings.cfg'`; consumed once at `dogenerate.inc:242` `ParserLoadFromFileByHandle(pStartingSettings, gc_filepath_startingsettings)` [O].
- Content [O]: `startid` presets, `dataversionmin/max`, per-preset `addresources`, `countries/allowedcountries`, `legends[key/role/countrysid/basename]`, `mask[]` rows (X09 §4-§5; 19 presets / 61 masks / 276 legends). P3 grep confirms the ONLY `startingunits`-stem hits are the `//gc_mapsettings_startingunits_*` comments (`:3-12`, `:182-2972`); **0 hits** for `victory|score|timelimit|time_limit|peaceful|wincondition|peacetime|additional` as keys.
- Writer [O-absence]: no `ParserSaveToFile*` call in the repo targets this path; the only code reference is the load at `dogenerate.inc:242`. It is read-only data, not a persistence target.
- Defaults [O]: `startid=-1` example block (`:87-180`) and empty `startid=0` default block (`:181-184`) per X09 §5; `startingunits > default` gate at `dogenerate.inc:232` means `0` selects no mask. No victory/score/peace default exists in this file — none recorded.

## 3. Lobby (`gui*.inc`) — where each setting lives and what the write trigger is [O]

### 3.1 Canonical setting inventory (the ONLY skirmish settings that exist donor-side)

EV-SP-04 [O] `TMapSettingsAdditional` (`classes.script:58-72`) — exactly 13 integers, in order:

```
activeoption, startingunits, balloon, cannons, peacetime, century18,
capture, marketdip, teams, autosave, limit, gamespeed, adviserassistant
```

EV-SP-10 [O] `TMapSettingsGen` (`classes.script:74-83`) — exactly 8 integers:

```
randkey0, randkey1, mapsize, terraintype, relieftype, resourcestart, resourcemines, season
```

EV-SP-10 [O] `TMap` (`classes.script:115-128`): `settings` (above) + `players[0..gc_MaxPlayerCount-1]` (`id/cid/csid/name/team/color/lanid/startx/starty/aidifficulty/bexists/bai/bhuman/bclosed/bready/bloaded/bleave`) + header (`name/gamestage/lastenvuid/dlcs/brating/bbattle/battlestage/battleind/battlemap`). **There is no `victory`, `score`, `scorelimit`, `timelimit`, `time_limit`, or `peaceful` field anywhere in `TMapSettingsAdditional`, `TMapSettingsGen`, `TMap`, or `TMapPlayer`** [O-absence, full struct reads P6].

EV-SP-11 [O] value domains (`dmscript.global`): `startingunits` 0-13 (`:1032-1045`); `balloon` 0-2 (`:1047-1049`); `cannons` 0-2 (`:1051-1052`); `peacetime` 0-9,11 with 10 reserved (`:1055-1066`); `century18` 0-2 (`:1068-1070`); `capture` 0-3 (`:1072-1075`); `marketdip` 0-4 (`:1077-1080`); `adviserassistant` 0-1 (`:1083-1084`); `teams` 0-1 (`:1086-1087`); `limit` index 0-8 → pop caps `500/750/1000/1500/2200/3000/5000/8000` (`:1089-1098`, `gc_mapsettings_limit_count = 8`); `gamespeed` default `-1`, values `7/10/14` (`:1025-1029`).

Lobby rows [O] `showcustomgame.inc:828-1066`: gen combos (`mapsize/season/terraintype/relieftype/resourcestart/resourcemines`) + `additional` category box (11 rows: indices 0-10 = startingunits/balloon/cannons/**peacetime**/century18/capture/marketdip/teams/limit/gamespeed/adviserassistant; `:833-854`) + `additional_options` value box whose tag IS the stored integer (`eventcustomgame.inc:59-90`, peace `:79` `gMap.settings.additional.peacetime := tag`). `limit` renders pop-cap text (`:934-946`); `gamespeed` renders `0/1/2/-1` (`:948-955`).

### 3.2 Init defaults (menu entry) [O]

EV-SP-05 [O] `initmapsettings.inc:10-29`: ALL of `gen.mapsize/terraintype/relieftype/resourcestart/resourcemines/season` := 0 AND `additional.activeoption/startingunits/balloon/cannons/peacetime/century18/capture/marketdip/teams/autosave/limit/gamespeed/adviserassistant` := 0; players reset to `cid` = pol, `name` = `player+i`, `team` = 0, `color` = i (`:31-45`); `players[0..1].bexists := True` (`:48-49`). So the lobby-entry default for **every** persisted map setting, including peace, is integer `0` (= `default` / `No Peace Time` for peace). `gamespeed := 0` here coexists with `gc_settings_gamespeed_default = -1` (`dmscript.global:1026`): both literals are recorded, neither is normalised here [O, no invention].

`map.script:274-282` [O] sets `map.settings.additional.peacetime := gc_mapsettings_peacetime_15` twice in a commented-alternative block; this is map-template code, not the lobby default path, and is NOT cited as a default — recorded only to prevent mis-citation.

### 3.3 The ONLY map-settings write trigger: Start pressed → `custommap` snapshot [O]

EV-SP-06 [O] `eventcustomgame.inc:320-392`:

- Server path (`:320-379`): `gProfileUserStruct.custommap := gMap` (`:324`; `bbattle := false; battlestage := 0` at `:325-326`), then after `DoStartGame()` → `custommap.settings.gen.randkey0/1 := 0` (`:376-377`) → `_profile_SaveStructToUserProfileParser('gProfileUserStruct')` (`:378`).
- Offline path (`:384-394`): `gProfileUserStruct.custommap := gMap` (`:386`; same battle-field clearing `:387-388`; `randkey0/1 := 0` at `:389-390`) → `_profile_SaveStructToUserProfileParser('gProfileUserStruct')` (`:391`) → `DoNewGame`.
- Non-start lobby edits (each `select` at `:59-90`, each player/AI/country/team/color pick at `:92-240`) mutate ONLY the live `gMap` in memory (`gMap.settings.* := tag`, `gMap.players[]` fields); they call `ExecuteState(showstate)` (redraw), never any save routine [D, forced by absence of save calls on those paths].

Consequence [D]: map settings (gen + all 13 additional incl. **peace index**, + full player/AI roster) persist **exactly once per game start**, as a `TMap` snapshot inside `gProfileUserStruct.custommap` with the two random keys zeroed. There is NO write on menu Apply tick, on exit, on dropdown close, or per-row. Closing the lobby without pressing Start persists nothing to `custommap`.

`writepeacemode.inc` / `readpeacemode.inc` [O] (`menu.inc/writepeacemode.inc:1-18`, `readpeacemode.inc:1-17`) are net-only `RecordCustom*` packages for editor peacemode sync, not persistence; `writepeacetime.inc`/`readpeacetime.inc` (`units/global.aix:391/398`) are the sim-side expiry net pair per `DEC-U-VICTORY-START` §2.2 — neither touches any file.

## 4. Native settings code — file format, what is written on menu Accept, defaults [O / O-absence]

### 4.1 Two disjoint stores; only one holds map settings

EV-SP-07 [O] save paths (`profile.script`):

- (a) Options menu Accept (`eventsettings.inc:692-734`): `gProfile := gProfileTmp; gSettings := gSettingsTmp;` (`:698-699`) → `_profile_SaveUserProfile` (`:700`) → `StateMachineGlobalVariablesSaveToStack(GetUserProfileStateMachineHandle, 'gProfile', '')` + `UserSaveProfile` (`profile.script:617-623`); hotkeys separately → `ParserSaveToFileByHandle(pHotkeys, GetAppSaveDirectoryPath+gc_filepath_hotkeys_relative)` with `gc_filepath_hotkeys_relative = 'hotkeys\hotkeys.cfg'` (`eventsettings.inc:727-730`; `dmscript.global:1353`) gated on `parserhotkeycount>=54` (`:727`). Cancel copies back and writes nothing (`:735-739`).
- (b) Skirmish Start (`eventcustomgame.inc` above): `_profile_SaveStructToUserProfileParser('gProfileUserStruct')` (`profile.script:269-281`): select-or-create child `structName` under `ParserSelectUser`, `ParserClearByHandle`, `StateMachineGlobalVariablesSaveToParser(pUserStructName, structName, False, False)`, then `UserSaveProfileExt(false, true)` (`:280`).
- Boot (`profile.script:729-737`): `_profile_SetDefault(gProfile)` → `_profile_SetDefaultProjectOptions` → `_profile_LoadUserProfile` → `_profile_SetLocaleFromResource` → `_profile_GetDisplayModeFromResource` → `_profile_ApplySoundOptions` → `_profile_LoadStructFromUserProfileParser('gProfileUserStruct')` → `_profile_SetDefaultAdviser`.

EV-SP-14 [O-absence]: `UserSaveProfile`, `UserSaveProfileExt`, `GetUserProfileStateMachineHandle`, `GetAppSaveDirectoryPath`, `ParserSelectUser`, `StateMachineGlobalVariablesSaveToParser/LoadFromParser/SaveToStack/LoadFromStack` have **zero procedure/function definitions** anywhere under `data/scripts` (P8 grep). They are engine natives. Their file encoding, flush timing, and exit-time behaviour are therefore NOT recoverable from text and are recorded as [U] (§6 U-SP5). What IS law is the script-side contract: struct names `'gProfile'` and `'gProfileUserStruct'`, the `ParserSelectUser` child key, and the directory suffix `GameSaveDirectoryPath=cossacks` (§1).

### 4.2 File formats [O, script side only]

| Store | Format (script-visible) | Donor cite |
|---|---|---|
| User profile (`gProfile` + `gProfileUserStruct` incl `custommap`) | Engine-native user-profile store under `GetAppSaveDirectoryPath` (+ `cossacks` suffix per §1); script addresses it ONLY by struct name via `ParserSelectUser` / `StateMachine*` natives. NOT `.ini`, NOT `.cfg` text; NOT `startingsettings.cfg`; NOT `resource.lib`. | `profile.script:269-281,617-652`; `cossacks.ini:2` |
| Options/video/audio/control/gameplay | Same native store for `gProfile`/`gSettings` structs (`eventsettings.inc:698-700`; `profile.script:617-623`); engine project options via `SetProjectOptionAs*` / `GetProjectOptionAs*`; locale + DisplayMode mirrored in `resource.lib` (`profile.script:106-227`). | `eventsettings.inc:227-596`; `profile.script:152-227` |
| Hotkeys | Text parser file `GetAppSaveDirectoryPath + 'hotkeys\hotkeys.cfg'`, children `*` with `Key/AlternativeKey/Action[/Repeat\|/Up]` | `eventsettings.inc:702-730`; `dmscript.global:1353` |
| Engine/video presets fallback | `.\data\resources\config.res`, parser key `config` | `showsettings.inc:587-592`; `eventsettings.inc:190-195` |
| Startup | `cossacks.ini` / `editor.ini` `section.begin/end` text (§1) | §1 EV-SP-01/02 |

### 4.3 Exact defaults (never invent; only list literals present) [O]

EV-SP-08 [O] `_profile_SetDefault` (`profile.script:7-62`): `name=''; sndmute=0; sndmaster/sndmusic/sndambient/sndfx/sndvoice=0.75; sndinterface=0.5; keyscrollspeed/mousescrollspeed/middlemousescrollspeed/wheelspeed=0.5; igamespeed=1; lastcampaignsave/lastcustomsave/netemail/netpass/netcdkey=''; bautosave/bbrushunderunit/bclipmouse/bsearchenemyinfront=True; binfiniteonleftclick/bselectallunitsonz/bDbgPreloadPatterns/bDbgVisualizePlayOnceProjFX/bcenterfirstrow/bDbgCamera/bDbgNoBrushes/bDbgUnitDebugInfo/bDemo/bCheat*=False; bShowPause/bShowMiniMap/bFamine/bRestrictCamera/bNewMapOnMainMenu=True; bDbgHotkeys=True; bShowFPS/bNoAchs/bDevMode=False; lang=''; displaymode='dmWindowFullScreen'; dontshowannouncement=0; lastknowndlcs=0; purchaseunixtime=0. Game-options reset (`_profile_SetGameOptionsDefault`, `:231-267`): `bfreezoom=False`; sound `sndmute=0, snd*=0.75, sndinterface=0.33`; control `key/mouse/mid/wheel=0.5, bclipmouse=True, igamespeed=1, bbrushunderunit/bsearchenemyinfront=True, binfiniteonleftclick/bselectallunitsonz/bcenterfirstrow=False`. Clamp (`:504-570`): sounds/scrolls clamped `0..1`; `igamespeed` clamped `0..3`; locale/displaymode repaired, never invented.

EV-SP-12 [O] `_misc_GetPeaceTime` (`misc.script:4264-4282`): index→minutes `{0:0,1:10,2:20,3:30,4:45,5:60,6:90,7:120,8:180,9:240,11:15}`, `else → 0`, then `Result := Result * 60` (seconds). This is conversion, not storage; stored value is always the index (§3.3).

### 4.4 What the Options Accept writes — and does NOT write [O]

Written on Accept [O] (`eventsettings.inc:197-596` slider/combo/checkbox handlers into `gProfileTmp`/`gSettingsTmp`, committed at `:698-700`): video preset/shadow/antialiasing/texturefilter/shadertype/waterreflection/ssao/fxaa/vsync/resolution/displaymode/lightpreset; sound `sndmute/sndmaster/sndmusic/sndambient/sndfx/sndinterface`; control `mousescrollspeed/keyscrollspeed/wheelspeed/middlemousescrollspeed/bclipmouse/bfreezoom`; gameplay `igamespeed/bautosave/bbrushunderunit/bsearchenemyinfront/binfiniteonleftclick/bselectallunitsonz/bcenterfirstrow`; language; hotkeys file. NOT written by Options [O-absence]: `startingunits/balloon/cannons/peacetime/century18/capture/marketdip/teams/limit/adviserassistant`, any `gen.*` key, any victory/score key (no such key exists to write), `startingsettings.cfg`, `cossacks.ini`/`editor.ini`.

## 5. Persistence verdicts: victory / score / peace / AI / map [O/D]

| Setting | Persists? | Where / as what | Default | Donor cite |
|---|---|---|---|---|
| Victory condition | **NO — absent.** No `victory` key, enum, or struct field in `TMap*`, lobby incs, or `startingsettings.cfg`. Only `victorystate` 0/1/2 runtime ints (`dmscript.global:777-779`), trigger/net writes, never a menu-persisted rule. | — (port `victory` is PORT EXTENSION) | NONE — none exists; do not record one | §3.1 struct reads; `DEC-U-VICTORY-START` §1.3 |
| Score / score-limit / time-limit | **NO — absent** as a victory rule. `limit` (0-8) is the POP cap 500..8000 (`dmscript.global:1089-1098`), consumed at `doprogressorders.inc:143-152`; it is NOT a score and has no timer. | `limit` index persists inside `custommap.additional.limit` (§3.3); score itself has nowhere to persist | `limit` default `0` (= `default`/unlimited, `initmapsettings.inc:27`); score threshold NONE | `dmscript.global:1089-1098`; `showcustomgame.inc:934-946,1051-1054` |
| Peace / peacetime | **YES — as lobby INDEX inside `custommap`.** Written only on Start (`eventcustomgame.inc:324-391`); converted to seconds at gen time (`dogenerate.inc:2059-2060` via `misc.script:4264-4282`); expires by `nothing.inc:658-695`. Never in `cossacks.ini`/`editor.ini`/`startingsettings.cfg`/Options. | `custommap.settings.additional.peacetime` ∈ {0,1,2,3,4,5,6,7,8,9,11} (10 never stored by lobby) | `0` (`initmapsettings.inc:21`; `= gc_mapsettings_peacetime_default`, `dmscript.global:1055`) | §3.2-§3.3; `DEC-U-MENU-PEACE` §1-§4 |
| AI (per-slot + speed) | **YES — two places.** Per-slot `aidifficulty/bai/bhuman/bexists/cid/team/color` inside `custommap.players[]`; global speed `gProfile.igamespeed` (0-3, default 1) via Options Accept; `adviserassistant` 0-1 inside `custommap.additional`. | `custommap.players[i].aidifficulty` + `gProfile.igamespeed` | `igamespeed=1` (`profile.script:21,256,517`); lobby slots from `initmapsettings.inc:31-49` (pol/players 0-1 exist); `adviserassistant=0` | `eventcustomgame.inc:123-147`; `classes.script:95-113`; `profile.script:7-62` |
| Map gen + all additional incl. start/AI-adjacent knobs | **YES — whole-`TMap` snapshot.** All `gen.*` (8 ints) + all `additional.*` (13 ints, incl `startingunits/balloon/cannons/century18/capture/marketdip/teams/autosave/limit/gamespeed/adviserassistant`) + `players[]` roster + header; `randkey0/1` zeroed before save. Offline AND server Start both save; client never saves. | `gProfileUserStruct.custommap` (native store) | All `0` at lobby init (`initmapsettings.inc:10-29`); DLC-gated 11th row (`adviserassistant`) hidden unless `lastknowndlcs&exp1` or client (`showcustomgame.inc:833-837`) | §3.3 EV-SP-06; `classes.script:58-88` |

Corrections to prior phrasing: (a) `DEC-U-VICTORY-START` §2.1 cited `_misc_GetPeaceTime` at `dmscript.global:4262-4277` — correct path is `lib/misc.script:4262-4282` (re-pinned EV-SP-12; `dmscript.global` has only 2400 lines per `DEC-U-MENU-PEACE` P2); arm units are minutes with ×60 at `:4281`, and the `else → 0` arm exists at `:4278-4279`. (b) Any task-context phrasing sourcing peace from `startingsettings.cfg` is refuted by §2 P3.

## 6. Still-[U] register — paired runs with known setting changes, zero-mismatch criteria, no invention

Rules: every run uses a FIXED seed / fixed lobby preset, is performed by the OWNER (donor binary never run by a worker), and passes ONLY on ZERO mismatch across 3 identical runs. No key or default may be asserted beyond §1-§5 cites.

| # | Item | Static state after this ticket | Exact paired run (owner-authorised) + zero-mismatch criterion |
|---|---|---|---|
| U-S1 | Port config save-side audit (inherited from `DEC-U-MENU-PEACE` §8) | Port has NO `peace_time` writer in `config.gd` (load-only `:479`); only Options writer is `menu.gd:891-895` (`user://options.json`, `ai.difficulty` only) | Headless: set lobby peace tags {0,1,11} on fixed seed, emit cfg, run `config.gd:apply()` + save/load round-trip. **Zero-mismatch:** emitted `peacetime` equals the lobby TAG byte-for-byte; reloaded `PEACE_TIME` equals U-P2 seconds (see `DEC-U-MENU-PEACE` U-P2); saved file contains NO invented key; 3 runs identical. Until then saved-game peace is UNVERIFIED — never claim persistence. |
| U-SP1 | Peace index round-trip via `custommap` | Stored index law [O] §3.3, no live dump | Fixed seed S, offline: Start with peace tags `1` then `11` (10 min vs 15 min); dump `gProfileUserStruct.custommap.settings.additional.peacetime` (script-side parser dump). **Zero-mismatch:** dumps exactly `1` then `11`; `randkey0/1` both `0`; all other `additional.*` unchanged between the pair; 3 repeats per tag identical. |
| U-SP2 | Victory/score/time-limit absence | Closed-as-ABSENT [O-absence] §5, no threshold/timer literal | Grep `victory\|score_limit\|timelimit\|time_limit\|peaceful\|wincondition` over `data/game/var/*.cfg` + `data/gui/menu.inc/donewgame.inc` + `TMap*` struct dump. **Zero-mismatch:** 0 skirmish-auto hits; any hit must be quoted with `file:line` or the ABSENT verdict stands. No capture beyond the grep log. |
| U-SP3 | AI persistence pair | Per-slot + `igamespeed` law [O] §5, no live dump | Fixed seed S: (A) slot1 AI `normal` + `igamespeed=1`; (B) slot1 AI `impossible` + `igamespeed=3`. Dump `custommap.players[1].aidifficulty/bai/bhuman` + `gProfile.igamespeed` on Start. **Zero-mismatch:** A→`aidifficulty` of normal-tag, `igamespeed=1`; B→impossible-tag, `igamespeed=3`; nothing else in `custommap` differs except the intended pair; 3 repeats identical. |
| U-SP4 | Map snapshot pair (gen + additional + randkey zeroing) | Snapshot law [O] §3.3, live bytes [U] | Fixed seed S: (A) all-`0` lobby; (B) `mapsize=2, season=2, startingunits=5, peacetime=4, limit=7, gamespeed=2` (values chosen only from §5 enums). Dump `custommap.settings.gen` + `additional` + `randkey0/1`. **Zero-mismatch:** A all zeros; B exactly the six changed ints with all others `0`, `randkey0/1=0` in both; 3 repeats identical. |
| U-SP5 | Exit/menu-Apply writes nothing native-side | Script side shows writes ONLY on Accept (§4.1a) and Start (§3.3); engine flush/exit behaviour is native [U] | Fixed lobby L: snapshot native store (owner-readable copy); press Options Accept with NO change, then exit game without Start; snapshot again. Paired change: Accept WITH `bautosave` flipped. **Zero-mismatch:** no-change Accept+exit leaves store byte-identical across 3 runs; flipped Accept changes ONLY the `gProfile.bautosave` field; Start changes ONLY `custommap` (+ `gProfile` if Accept also pressed). Any exit-time write of map settings fails this item and must be quoted. |
| U-SP6 | `cossacks.ini` / `editor.ini` untouched by menu | [O-absence] §1, live mtime [U] | Record mtime+bytes of both inis; run lobby: change peace 0→9, Start offline, Accept options, exit. **Zero-mismatch:** both files byte-identical across 3 runs; `GameSaveDirectoryPath` still `cossacks`. Any byte change fails and must be quoted with the writer. |

## 7. Port note — `config.gd` / `menu.gd` (`app/` + `variant3d/`): PRESERVE all user values, label-only unless donor law is exact (NO EDITS MADE)

Owner constraints: `app/config.json` and `variant3d/config.json` are preserve-only user mods (donor/color changes live there); `variant3d/config_donor_capture.json` carries port-only `features.terrain.demo_mill=true` (P9 read: `variant3d/config.json:28-32` backend/relief_stamps/color_unify WITHOUT demo_mill vs capture file WITH `demo_mill`). NOTHING below overwrites any of these files or adds a writer for them. Port `user://options.json` writer (`app/menu.gd:891-895`) persists ONLY `{"ai":{"difficulty"}}` and `config.gd:249-255` merges it as third layer — keep as-is.

Conventions: `app/` = `app/scripts/…`; `v3d/` = `variant3d/scripts/…`. Every change is an instruction for the owning worker; each cites donor `file:line` + `[O]/[U]` and keeps every stored value byte-identical.

1. **Labels only — `app/menu.gd:209-213` `_peace_items()` + `:713` Peace-time row (same in `v3d/`).** Replace `{"id": str(m), "name": "No"/"%d min"}` rendering with the §5/EV-SP-11 index table and `DEC-U-MENU-PEACE` §2 verbatim labels (`No Peace Time`, `10 min`, `15 min`, `20 min`, `30 min`, `45 min`, `60 min`, `1.5 hours`, `2 hours`, `3 hours`, `4 hours`, display order tags `0,1,11,2,3,4,5,6,7,8,9`; cite `showcustomgame.inc:1126-1150 + gui.txt:553-575`). Keep `id` = the donor INDEX string and `peace_time` an int tag (default `0`, `menu.gd:47` already correct as a tag holder); keep emitted key `"peacetime"` (`menu.gd:910`, `main.gd:329`) unchanged. Do NOT store seconds, do NOT add `40/50`, do NOT renumber any id — stored user values must round-trip unchanged.
2. **Comment-only — `app/data.gd:327` `DONOR_PEACE_TIMES` (and `v3d/data.gd:732-737`).** Keep the array (user configs may reference its positions) but fix the comment to "donor INDEX table; minutes per `misc.script:4267-4277`, ×60 at `:4281`; index 10 reserved/unmapped, 11 = 15 min". No value change without the owning worker's migration plan, because any reorder would corrupt preserved configs.
3. **Label-only — `app/main.gd:329` + `app/config.gd:479` (`v3d` twins `main.gd:358` / `config.gd:594`).** Keep reading key `"peacetime"`/`"gameplay.peace_time"` and the `0.0..14400.0` clamp (already `240*60`, correct). Re-point the comment to the index→seconds law (`misc.script:4262-4282` + `dogenerate.inc:2059-2060`; init rule `<> default`, expiry `nothing.inc:658-695`). Do NOT change the accepted value domain (still accept minute-numbers already stored in user files); convert at apply exactly once. Do NOT add a save-side writer for `peace_time` (U-S1 stays open until its criterion passes).
4. **Label-only — victory/score (`app/config.gd:88-89,411-412`; `app/main.gd` victory wiring; `game.gd:5464-5485` `_check_victory`).** Keep keys `"victory"`/`"score_limit"` and defaults (`"destroy_all"`/`5000.0`) byte-identical (user files depend on them). Tag the comment `PORT EXTENSION — NO donor victory/score/timelimit key exists (struct absence §3.1, cfg absence §2; scenario win is trigger-gated per DEC-U-VICTORY-START §1.3)` and keep the existing `PORT_EXTENSION_SCORE_VICTORY=false` opt-in. Never default `VICTORY` to `"score"`; never gate 1:1 asserts on `SCORE_LIMIT`. `limit` (`menu.gd:725` pop row, `main.gd:328`, `config.gd` donor-id path) is the POP cap 0-8 → 500..8000 (`dmscript.global:1089-1098`) — label it as such, keep its stored index unchanged.
5. **Keep — AI/map passthrough (`menu.gd:897-914` emit; `main.gd:323-333,341-347`; `config.gd:405-483`).** Keys `balloon/cannons/century18/capture/marketdip/autosave/limit/gamespeed/adviserassistant/terraintype/relieftype/resourcestart/resourcemines/mapsize/startingunits/players/teams/player_ai/player_ai_difficulty` already mirror the `TMap` snapshot shape (§3.1); preserve every key and every stored id string. `user://options.json` stays `ai.difficulty`-only; do NOT widen it to map settings (donor keeps them in `custommap`, §4.1). `features.terrain.demo_mill` (capture file only) stays port-QA, never a donor claim.
6. **Telemetry.** Every touched line carries `file:line` + `[O]/[U]`; `visual_parity_claim=false`; unresolved list after this ticket = U-S1 + U-SP1..U-SP6 above.

## 8. Explicit non-claims + file discipline

- NO PARITY CLAIM. Resolved items (ini contents, cfg non-role, lobby inventory, defaults, Start-only snapshot law, absence of victory/score keys) rest on donor TEXT with `file:line` (§1-§5); open bytes (native store encoding, exit-flush) name exact captures in §6.
- No number invented: no victory threshold, no score limit, no timer value, no camera constant, no ini default, no `40/50` peace rows, no `%d min` for 90+. Every port default that fills a donor gap stays tagged `PORT EXTENSION` / `PORT APPROXIMATION` / `PORT POLICY`.
- Read-only compliance: exactly one repo file written (this report). Donor evidence is text reads + count greps; donor binaries never executed, never copied; no source/asset/config/test/runner/Godot/git state changed; `config.json` / `config_donor_capture.json` / `options.json` untouched.
- Network out of scope: `WritePeaceTime/WriteFreeList`, `LanSendParser`, `_net_*` branches, and room-wire transport (`miscext2.script:2375/:2635`) are cited only as the index-carrier boundary, never as persistence law.

*End of DEC-U-SETTINGS-PERSIST.*
