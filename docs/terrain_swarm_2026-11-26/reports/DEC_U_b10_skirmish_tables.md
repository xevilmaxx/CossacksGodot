---
id: DEC-U-B10-SKIRMISH-TABLES
worker: DEC-U-B10 (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. LAN/Steam/lobby score surfaces observed only to exclude them; no multiplayer law wired or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker; no port capture compared."
context: "PORT1TO1_b_angle_index.md class-B candidate B10 (S-SKIRM tables) NOT EXECUTED. DEC_U_skirmish.md + DEC_U_skirmish_tables.md closed famine/market/upkeep/capture/train/save heads; DEC_U_econ_deep.md closed economy/AI negatives with ZERO promotions. Remaining tails attacked here: AI table, mercy/score literals, exact gProfile defaults, mission trigger mapping."
labels: "[O] verbatim donor literal (file:line or byte offset) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-B10-SKIRMISH-TABLES — packed CODE search + wrapper arities + profile text for the skirmish tails (2026-11-27)

## 0. Pass ledger (owner rule; every native/script pass pinned `t_87f0f3c130b0`; donor read-only)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert (read-only) | `cossacks.exe` 5,768,048 B, SHA256 `87f0f3c1…4e16c` match `[O]`; PE32 (`Magic 10B`), `ImageBase 0x00400000`, 10 sections (`CODE/DATA/BSS/.idata/.edata/.tls/.rdata/.reloc/.rsrc/.bind`) parsed from headers, no execution. |
| P2 | Packed CODE byte search, 8 B10 terms, ASCII + UTF-16LE, whole image | §1 table. 7/8 terms **0 hits both encodings** (incl. all casings); `score` 17 case-insensitive hits, all CODE-mapped but all lobby/LAN/Steam surfaces (§1.2). Method parity: same sweep recovers `GetGameTime`/`GetProjectModeInt`/`Lerp`/`ClampInt`/`MaxFloat`/`RandomExt`/`SetRandomKey` tables (§2). |
| P3 | Case-insensitive whole-image re-sweep (`aidata/progresstick/gprofile/victorystate/mercenary/resbalance/changeplayer/bestprojects/timeprogressai`) | All 0 except `changeplayer` ×1 = substring of `ExchangePlayerIndex` (native player-index API name, not `_misc_ChangePlayer`) `[O]` §1.3. |
| P4 | Native wrapper arity extraction (signature strings adjacent to CODE hits) | §2 table: 8 native arities verbatim `[O]`; `ExecuteState` function-form ABSENT, `_misc_ChangePlayer` ABSENT (script-side) `[O]`. |
| P5 | Donor text reads (read-only): `profile.script`, `classes.script` TProfile/TAiData/TProgress records, `scenario.script` victory/trigger mapping, `res.script`/`dmscript.global` garr block, `serial.script` save procs, `unit.script` score params, `miscext2.script` kill accounting, `progresseconomicai.inc` resbalance dormancy, `nothing.inc` tick consumers | §§3–4, every literal with `file:line`. |
| P6 | Prior-pass carry-forward (not re-counted as new) | DEC_U_econ_deep P2: 20+ economy/AI terms (`garr_res_dlt/gflt_res_dlt/garr_res_trg/resconsume/resonlife/costpercent/sellexp/buycost/sellcost/buytime/selltime/buyexp/MarketTradeResources/CalcDeltaResources/ProcessEconomy/bestprojects/resbalance/TimeProgressAI/…`) **0 stored-byte hits each**; positives (`GetProjectModeInt/Lerp/ClampInt/MaxFloat/ExecuteState×37/GetPlayerIndexByHandle/GetPlayerHandleByIndex/SetGameObjectMinBlend`) recovered. This ticket re-confirms `resbalance` + `garr_res_dlt` at 0 in both encodings and adds the 6 remaining B10 terms. |

DSL note `[D]` (inherited from DEC_U_skirmish §0): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. (a) Packed CODE byte search — B10 API/property names with VAs

`VA = 0x400000 + section.VA + (fileoff − section.rawptr)`. `CODE` section: `VA 0x1000`, raw `0x400–0x4F1200`.

### 1.1 Zero-hit terms (script-side-only shape) `[O]`

| Term | ASCII | UTF-16LE | ci-all-cases | Verdict |
|---|---|---|---|---|
| `resbalance` | 0 | 0 | 0 | `[D]` script-side (`classes.script:2604/2664-2666`, `serial.script:1716-1847/2014/2108`, `progresseconomicai.inc:590-594,971-1024` — all writers/consumers commented, see §4.1). Carries econ_deep P2 (ev_c763fa38/ev_db154291). |
| `garr_res_dlt` | 0 | 0 | — | `[D]` script-side (`dmscript.global:2343-2345`, `res.script:184,254-263,291`). Carries econ_deep P2 (ev_cc4ce17c). |
| `progresstick` | 0 | 0 | 0 (`progresstickeditor` 0) | `[D]` script-side (`classes.script:37,3709`, `progress.inc:181`, `nothing.inc:117,405,758`, `gui.script` sound counters). |
| `aidata` | 0 | 0 (`AIData` 0) | 0 | `[D]` script-side record (`classes.script:2556+`, 584 text hits, serial procs `serial.script:1702/1807/1982/2084`). |
| `gProfile` | 0 | 0 | 0 | `[D]` script-side (`classes.script:7670-7673`, `profile.script` full defaults §3). |
| `victorystate` | 0 | 0 | 0 (`VictoryState` 0) | `[D]` script-side (`classes.script:3684-3685`, `dmscript.global:777-779`, writers §4.5). |
| `mercenary` | 0 | 0 | 0 (`Mercenary` 0) | `[D]` script-side (`classes.script:3643` flag, `dmscript.global:776` index, `nothing.inc:487-495` rebellion gate). |

Packed-region reserve (stated, same as econ_deep/tick workers): stored-byte absence ≠ proof of runtime absence (`.bind` `0x56C000` exec, entropy-packed). Every value below stays `[U]` until its §5 fixed-seed trace terminates; negatives fix only the *shape* (no CODE-embedded table to lift).

### 1.2 `score` — 17 case-insensitive CODE hits, zero sim-side `[O]`

All 17 hits map to `CODE` VAs; contexts show four out-of-scope network surfaces only:

| Cluster | VAs | Content |
|---|---|---|
| Lobby protocol | `0x5A366E`, `0x5A3694` | `TS_CMD_USER_SESSION_KICK / LTS_CMD_SERVER_SESSION_CLSCORE / LTS_CMD_USER_SESSION_CLSCORE / …FORGOT_PSW` |
| Lobby ranking schema | `0x5B3830`, `0x5B9EF0` | `Nick/Country/ID/Score/States/GamesPlayed/GamesWin/LastGame…` record field names |
| LAN server API | `0x680A2A`, `0x680A82`, `0x6811E1`, `0x681452`, `0x68147C`, `0x6814E0`+ | `LanPublicServerGetClientScoreByIndex/ByClientID`, `LanPublicServerProfScore`, `LanSrvSetClientScore(aclientid, ascore)` (arity §2), `LanClSetMyScore` |
| Steam leaderboard | `0x6EF8A0`-region + 4 | `SteamUserStats_UploadLeaderboardScore`, `SteamwrapUploadLeaderboardScore(…score: integer; var scoredetails…)` |

**No CODE-embedded sim-score table exists**: the sim score (`TObjProp.score`, `counter.scores`, `stat.scores`) never appears as a stored CODE name — same script-side-only shape as §1.1. Sim score literals are text-side only (§4.3).

### 1.3 `changeplayer` ×1 is a false friend `[O]`

File offset `0x28CFCC` (`CODE` VA `0x68DBCC`) context `…procedure ExchangePlayerIndex(const index1, index2: Integer)…` — substring of a native player-index API name. `_misc_ChangePlayer` as a CODE string is **ABSENT** (script-defined, `miscext.script`); capture/rebellion flip target stays text-side.

---

## 2. (b) Wrapper arities — native consumers that bound the tails

### 2.1 Byte-proven native signatures `[O]` (verbatim strings at the VA)

| Native | VA (string head) | Verbatim arity |
|---|---|---|
| `GetGameTime` | `0x69FAED` (off `0x29EEED`) | `function GetGameTime(): Float` — 0 args. Adjacent: `procedure SetGameTime(val: Float)`. Consumer: victorystate first-stamp (`progress.inc:132`, `scenario.script:2998,3052`). |
| `GetProjectModeInt` | string head `0x69DDDD` / name `0x69DDE6` (off `0x29D1DD`+9; consistent with econ_deep `0x69dde6` = name offset) | `function GetProjectModeInt(): Integer` — 0 args. Consumer: `garr_res_dlt` updater gate (`res.script:254`). |
| `RandomExt` | `0x60A659` | `function RandomExt(): Float` — 0 args. Consumers: rebellion/AI die rolls, guard sampler, slow-death, headshot. |
| `SetRandomKey` | `0x60A6A8` | `procedure SetRandomKey(key: Integer)` — 1 arg. |
| `Lerp` | `0x60A625` | `function Lerp(const a, b, t: Float): Float` — 3 args. Consumer: `res.script:262` dlt update. |
| `ClampInt` | `0x60A92D` | `function ClampInt(const val, min, max: Integer): Integer` — 3 args. Consumer: `res.script:262`. |
| `MaxFloat` | `0x60A54D` | `function MaxFloat(const a, b: Float): Float` — 2 args. Consumer: `res.script:291` recovery factor. |
| `GetPlayerCurrentPlHandle` | `0x690692` (off `0x28FA92`; reproduces tick_deep P2) | `GetPlayerCurrentPlHandle(): Integer` — 0 args. Consumer: per-plInd Progress slice (`progress.inc:37-38`). |
| `LanSrvSetClientScore` | `0x681452` | `procedure LanSrvSetClientScore(aclientid: Integer; ascore: Integer)` — lobby-only, NOT a sim consumer `[D]`. |

`[D]`: no native setter takes a score/AI-weight/resbalance constant; engine evaluation *semantics* (linear `Lerp`, int clamp, float max, Bankers `round`) are engine-defined and NOT byte-proven beyond the signatures — they stay `[I]` until §5 batteries terminate (same reserve as econ_deep §4 U6-T).

Negative arities `[O]`: `function ExecuteState` ABSENT as a CODE string (the 37 `ExecuteState` hits are GO-delay call-site names per tick_deep/econ_deep — the player `ProgressAI/ProgressEconomicAI` dispatcher is script-side); `procedure _misc_ChangePlayer` ABSENT (script-side); `bestprojects`/`TimeProgressAI` 0 (§1.1 + P3). No native AI target-weight vector exists in stored bytes.

### 2.2 Script-procedure arities for the B10 mechanical audit `[O]` (definitions, not natives)

`SetObjBaseProtection(objbase; pike, sword, bullet, cannister, arrow, cannonball)` — 7 params (`unit.script:510`); `SetObjBaseWeapon(objprop, objbase; index, damage, pause, radiusmin, radiusmax, detectradiusmin, detectradiusmax, kind; bSearchMinAttackRadius)` — 11 (`unit.script:520`); `SetObjBasePrice(objbase; food, wood, stone, gold, iron, coal)` — 7 (`unit.script:493`); `SetObjBaseSearchBuildVisionScore(objprop, objbase; searchradius; buildtime; vision, score)` — 6 (`unit.script:571`); `SetObjBuildingBaseSettings(objprop; bcapture; score, usage)` — 4 (`unit.script:461`); `_weapon_AddWeapon(var ind; weaponsid, fx, projbasename; damage; radius, gravity; propagation; physvalue, time)` — 10 (`weapon.script:39`); `_ai_SetResouceBalance(plind, resid, a0, a1, a2)` — 5, **commented-out** (`progresseconomicai.inc:590`).

---

## 3. (c) Donor settings/profile text — exact `gProfile` defaults `[D]`

### 3.1 `TProfile` record shape `[O]` (`classes.script:5090-5146`)

54 fields in order: `name, sndmute, sndmaster, sndmusic, sndambient, sndfx, sndvoice, sndinterface, keyscrollspeed, mousescrollspeed, middlemousescrollspeed, wheelspeed, igamespeed, lastcampaignsave, lastcustomsave, netemail, netpass, netcdkey, bautosave, bbrushunderunit, bclipmouse, bsearchenemyinfront, binfiniteonleftclick, bselectallunitsonz, bfreezoom, bDbgPreloadPatterns, bDbgLogPointerNil, bDbgVisualizePlayOnceProjFX, bShowPause, bShowMiniMap, bcenterfirstrow, bFamine, bRestrictCamera, bDbgCamera, bDbgNoBrushes, bDbgHotkeys, bDbgUnitDebugInfo, bDemo, bNewMapOnMainMenu, bCheat*×7, bShowFPS, bNoAchs, bDevMode, lang, displaymode, dontshowannouncement, lastknowndlcs, purchaseunixtime`. Globals: `gProfile/gProfileTmp : TProfile`, `gProfileUserStruct/gProfileUserStructTmp : TProfileUserStruct` (`classes.script:7670-7673`).

### 3.2 `_profile_SetDefault` full defaults `[O]`/`[D]` (`profile.script:7-61`)

| Key | Default | Line |
|---|---|---|
| `sndmute` | 0 | :10 |
| `sndmaster/sndmusic/sndambient/sndfx/sndvoice` | 0.75 | :11-15 |
| `sndinterface` | 0.5 (0.33 in sound-subset reset :246 — two verbatim values, NOT merged) | :16, :246 |
| `keyscrollspeed/mousescrollspeed/middlemousescrollspeed/wheelspeed` | 0.5 | :17-20 |
| `igamespeed` | **1** | :21 |
| `bautosave/bbrushunderunit/bclipmouse/bsearchenemyinfront` | True | :27-30 |
| `binfiniteonleftclick/bselectallunitsonz/bDbgPreloadPatterns/bDbgVisualizePlayOnceProjFX/bcenterfirstrow` | False | :31-33, :38 |
| `bDbgLogPointerNil` | `IsEditor` (expression, not a literal) | :34 |
| `bShowPause/bShowMiniMap` | true | :36-37 |
| **`bFamine`** | **True** | **:39** |
| `bRestrictCamera/bDbgHotkeys/bNewMapOnMainMenu` | true | :40, :43, :45 |
| `bDbgCamera/bDbgNoBrushes/bDbgUnitDebugInfo/bDemo/bCheat*×7/bShowFPS/bNoAchs/bDevMode` | false | :41-42, :44, :46-56 |
| `dontshowannouncement/lastknowndlcs/purchaseunixtime` | 0 | :59-61 |
| adviser defaults (`bavailable` etc.) | True except `bmarketadvises=False`, `settings=0`, `version=1` | :661-682 |

`_profile_SetGameOptionsDefault(mode)` (`profile.script:231-267`) resets **only** video (`bfreezoom=False`), sound, and control (`keyscroll/mouse/wheel 0.5, bclipmouse True, igamespeed 1, …`) subsets — it **never touches `bFamine`** `[D]`. No menu/settings path in shipped text can silently flip the famine default; a user-profile *store* round-trip (`StateMachineGlobalVariablesSaveToStack/LoadFromStack`, `profile.script:621,631`) is engine-side, format/flush timing `[U]`-P (bounded in save_deep/famine_profile, not re-derived here).

### 3.3 No settings override for the economy/AI globals `[O]`

`cossacks.ini` 7 lines (`GameSaveDirectoryPath/LogFileEnabled/LogFileRoot/LogFileName/HideHelloScreen/BuildVersion`) — economy-free; `editor.ini` launcher/editor shims only. `c:\Games\Cossacks 3\data` has no `profiles/` dir. Whole-`data` grep: `garr_res_dlt/gflt_res_dlt/garr_res_trg` confined to declaration + `res.script` (`dmscript.global:2343-2345`, `res.script:184,254-257,262-264,291`) — zero hits in any `*.cfg`/`*.res`/`*.ini`/locale/gui/menu/`startingsettings`/save text `[O]` (reproduces econ_deep §3). The runtime gate is exactly `GetProjectModeInt=2` (game) with init-to-0 at `res.script:184` — no settings/profile branch conditions it `[D]`.

---

## 4. (d) Tail-by-tail determination — what becomes `[D]`, what stays `[U]`

### 4.1 AI table: `resbalance` default is byte-proven ZERO and the subsystem is dormant `[D-shape]`; behaviour stays `[U]`

- Record: `resbalance : array[0..gc_ResCount-1] of array[0..2] of Integer` (`classes.script:2604`); `TAiData.Reset` zeroes the full matrix (`classes.script:2664-2666`: `for i:=0 to gc_ResCount-1 do for j:=0 to 2 do self.resbalance[i][j] := 0`) `[O]`.
- The ONLY writer, `_ai_SetResouceBalance`, is `[*] = ;`-commented (dead) (`progresseconomicai.inc:590-594`) `[O]`; every reader (`requiredFood/woodProportion/stoneProportion/reqlevel`, `:971-1024`) is likewise commented `[O]`. Live game therefore carries `resbalance ≡ 0` with no live consumer — **default `[D]`, dormancy `[D]`**.
- Save shape is live: `WriteBuffer/ReadBuffer(SizeOf(val.resbalance))` (`serial.script:1716-1717/1846-1847`), `SizeOf` at `:2014`, `SeekBuffer(gc_ResCount*3*SizeOf(Integer))` at `:2108` `[O]` — the zero matrix round-trips through saves.
- Stays `[U]`-AI-T: mine-band behaviour (`reqlevel` selection) can never fire while writers/readers are commented; if any patch *activates* these rows, the mine-band battery (§5 AI-T) must terminate first. `bestprojects` winner, army-commit, officer-wait, weights, think `2.4 s + id·0.25` + anti-collision, AI RNG attribution: no new native anchor (§§1–2) — carried `[U]`-A1…A8 per ai_thresholds/econ_deep with §5 batteries.

### 4.2 Mercy: NO sim mechanic — CLOSED-NEGATIVE `[D]`; surrender paths are trigger/`bexists` law `[O]`

- Whole-`data` grep `mercy` (case-insensitive, `.script/.inc/.cfg`): **2 hits, both the achievement string** `gc_ach_camp_tutmis1_mercyofficer` (`classes.script:5058`, `doprogress.inc:1103`) `[O]`. No mercy rule, threshold, or pardon action exists in any sim script.
- What the port must NOT invent: any mercy/sparing branch. Genuine donor neighbours, verbatim: scenario trigger actions `gc_trigger_action_endgame_win/lose` (`scenario.script:241-242`, dispatched `:2995-3052`, §4.6) and the `bexists` kill path (`progress.inc:124-135`) plus surrender-as-`victorystate=none`-gate (`scenario.script:1688`).

### 4.3 Score literals: writers/accounting `[O]`/`[D]`; per-sid values stay T1-tail `[U]`; score-victory ABSENT `[O]`

- Per-sid score is the 6th arg of `SetObjBaseSearchBuildVisionScore` (arity §2.2); ~150 call sites carry verbatim score literals (`unit.script:636-2060`, e.g. peasant-family `10`, `musketeer*17c` `20–35`, buildings up to `2000`, walls `0`) `[O]`. Full per-sid table = mechanical cite-or-tag audit (B10 angle, `unit.script:627-~2600` + `classes.script` defaults) — still `[U]`-T1-tail where not yet transcribed (core-infantry/cavalry score samples already in tables-report §1.3 `[O]`).
- Kill accounting `[O]` (`miscext2.script:443-464`): killer `counter.scores += 2×target.score`, inside-units `+3×` each (process-logic path only); build/destroy modifiers `[O]` (`unit.script:3836-3841`: `scoremodifier 5` own / `1` other on build; `:3940-3950`: `5/3/2` on destroy, floor at 0); per-tick stat log `[O]` (`nothing.inc:732-739`: `stat.scores.Add(counter.scores)` per player).
- Score-victory is ABSENT: no trigger condition reads `counter.scores`/`stat.scores` for victory; the only endgame writers are trigger `endgame_win/lose` + `bexists` lose-stamp (§4.6/§4.5) `[O]`. Port `SCORE_LIMIT` stays PORT EXTENSION behind a non-1:1 flag `[D]`.

### 4.4 `gProfile` exact defaults: `[D]` (§3.2 table)

Shipped-default surface is fully enumerated; `bFamine=True` (`profile.script:39`), `igamespeed=1` (`:21`), sound/scroll 0.5/0.75 split, all cheat/debug flags false. Stays `[U]`-PROF only the engine-side user-profile store byte format/flush timing (save_deep/famine_profile lane), never the values.

### 4.5 `victorystate`: enum + writers + first-stamp-wins `[D]`; live sequence stays `[U]`

- Enum `[O]` (`dmscript.global:777-779`): `gc_player_victorystate_none=0, win=1, lose=2`. Fields `[O]` (`classes.script:3684-3685`): `victorystate: Integer; victorystategametime: Float`.
- Writers `[O]`: `progress.inc:130-132` (`bexists` kill path: `victorystate:=lose`, `if victorystategametime=0 then :=GetGameTime` — **first-stamp-wins** `[D]`); `scenario.script:2995-2998` (`endgame_win`: `victorystate:=win`, same first-stamp guard via `GetGameTime()` 0-arg native §2.1); `:3049-3052` (`endgame_lose`, mirrored); inits: `initmapgen.inc:263` (`:=lose`), `inithistoricalbattle.inc:127-128` (`:=none`, time `:=0`). Surrender gate read: `scenario.script:1688` (`bConditionsOK` requires `victorystate=none`, offline, game mode).
- Stays `[U]`-VIC: live end-of-mission sequence in skirmish (which writer fires first, `LanServerSendResults` transport) — §5 VIC battery.

### 4.6 Mission trigger → victory mapping `[O]` (text-side, engine ids are locale keys)

- Action registry: `gc_trigger_action_endgame_win/lose : text := GetLocaleTableListItemByID('editor','triggereditor.action.type.endgame_win/lose')` (`scenario.script:241-242`); full action catalogue `:173-271` (service/counter/resource/objective/map/query/selection/group/player/units/order/gate/ferry/endgame/advanced/save/net families) with dispatcher `:1776-3271` `[O]`.
- Worth recording for the mission lane: `endgame_win/lose` write ONLY `gPlayer[myplind]` (mission-player slot, not every player) `[O]` (`scenario.script:2996,3050`); skirmish defeat uses the separate `progress.inc` per-player path (§4.5). The trigger→victory *mapping* (which shipped mission fires which action on which condition) is per-`.map`/mission data, not enumerated in this static pass — stays `[U]`-F1 (mission rows), with the two action semantics + first-stamp law `[D]`.

### 4.7 `progresstick` fields/writers/consumers `[O]`; engine interleave stays `[U]`

- Fields: `TProgress.progresstick/soundprogresstick/soundcounterprogresstick : Integer` (`classes.script:37-41`); `TPlayer.progresstick : Integer` (`classes.script:3709`) `[O]`.
- Writers: `gProgress.progresstick += 1` per global tick (`nothing.inc:758`); `gPlayer[plind].progresstick += 1` per player slice (`progress.inc:181`) `[O]`.
- Consumers: `mod 2` water/GO-path gate (`nothing.inc:117`), `mod 53` LAN-sync gate (`nothing.inc:405`), `mod 10` commented-out branch (`nothing.inc:408`), `_ai_CheckProcessEnemyInfo(gProgress.progressTick)` (`nothing.inc:754` — capital-T textual form of the same field under case-insensitive script reading `[I]`, no second field declared) `[O]`.
- Stays `[U]`-O1-tail: engine plInd iteration order and stage interleave (tick_deep lane) — §5 TICK battery. (Textual note: `dmscript.source:15-16` GUI `gint_gui_progresstick` counters are editor/GUI-domain, not sim.)

### 4.8 Mercenary literals `[O]` carried; flip target stays `[U]`

`gc_player_mercenaryind = gc_MaxPlayerCount-1 = 11` (`dmscript.global:97,776`) `[O]`; `bmercenary : Boolean` (`classes.script:3643`) `[O]`; rebellion die rolls `6000/100/200` + `plInd<>mercenaryind` gate (`nothing.inc:487-497`) and capture-side rolls (`miscext.script:1147-1173`) carried from skirmish/tables reports `[O]`. Stays `[U]`-U11-M: owner flip target slot mapping in a live skirmish (FP-3 battery, §5).

---

## 5. (e) Fixed-seed skirmish traces — zero-mismatch termination for every still-`[U]` tail

No threshold invented; no parity claimed. Each battery runs on the owner/COORD harness (donor execution forbidden to this worker) and terminates ONLY on exact zero-mismatch criteria.

| # | Tail | Fixed-seed trace (seed pinned by harness, ≥3 repeats unless noted) | Termination (0 mismatches) |
|---|---|---|---|
| AI-T | resbalance mine bands + A1…A8 (winner, commit, officer-wait, weights, `2.4 s+id·0.25`, anti-collision, RNG) | 600 s AI-vs-AI Bitva-seed: log `bestprojects` choice, army-creation tick, squad-form composition, mine `reqlevel` band per res, `lastprogressaitime` growth per plInd, X21 draw ledger | Byte-identical choice/tick/composition/band/draws across 3 seeds; dormant `resbalance≡0` asserted each dump (any nonzero = harness/data mismatch, investigate, never smooth) |
| MERCY/VIC | surrender/victory sequence | Force `bexists=False` on one AI (peasant-hunt to 0) + fire mission `endgame_win` and `endgame_lose` triggers on `myplind`; log `victorystate/victorystategametime` per player per tick + first-stamp order | `lose` stamp tick + `GetGameTime` value match oracle (`progress.inc:130-132` / `scenario.script:2995-3052`); `win`/`lose` confined to `myplind`; 0 mismatches over 3 runs |
| SCORE | per-sid score + kill/build/destroy accounting + stat log | Kill matrix (each killer-kind × each victim-kind, 1v1 fixed seed): log `counter.scores` delta; build + raze one of each building sid: log modifier; 600-tick run: log `stat.scores` series | Deltas equal `2×/3×` oracle, build `5×/1×`, destroy `5×/3×/2×` floored at 0, stat series exact; 0 mismatches |
| PROF | gProfile defaults application | Fresh-profile boot (no user store): assert `bFamine=True` gates famine rolls, `igamespeed=1` rate, `bclipmouse/bRestrictCamera` surface; then flip each default once and reboot | All §3.2 defaults observed live; store round-trip byte-stable (format itself `[U]`-P, recorded not asserted) |
| TICK | `progresstick` interleave (O1-tail) | 3600-frame × 3-seed hash battery (tick_deep §5 U-S1…S8): log `gProgress.progresstick`, `gPlayer[pl].progresstick`, consumer fire ticks (`mod 2/53` gates) | State hashes bit-identical across repeats; consumer fire pattern matches oracle; 0 mismatches |
| F1 | mission trigger rows | Per shipped mission: enumerate trigger→`endgame_win/lose` firings in a scripted playthrough log | Fired action/condition/player-slot match static mapping (§4.6); 0 mismatches |

Port discipline until termination: `resbalance` stays hard-zero + dormant (never back-filled from neighbour bands); no mercy branch; score-victory stays behind the non-1:1 flag; trigger actions write `myplind` only; `capture_t`-style accumulators never substituted for `lasttimecheckcapture`.

---

## 6. Claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | Pin `t_87f0f3c130b0` re-asserted (5,768,048 B, sha256 `87f0…4E16c`, PE32, ImageBase `0x00400000`); binary never executed/copied; exactly one repo file written | `[O]` P1 + scope |
| 2 | Packed CODE search: `resbalance/garr_res_dlt/progresstick/aidata/gProfile/victorystate/mercenary` 0 hits ASCII+UTF-16LE (+ ci sweeps); `changeplayer` ×1 = `ExchangePlayerIndex` substring; `score` 17 ci hits all lobby/LAN/Steam (`0x5A366E…0x6EFxxx`); no CODE sim-score/AI/resbalance/dlt table; econ_deep 20-term zeroes carried, not re-counted | `[O]` §1 (packed-region reserve stated) |
| 3 | Native arities verbatim: `GetGameTime(): Float @0x69FAED`, `GetProjectModeInt(): Integer @0x69DDDD/0x69DDE6`, `RandomExt @0x60A659`, `SetRandomKey @0x60A6A8`, `Lerp @0x60A625`, `ClampInt @0x60A92D`, `MaxFloat @0x60A54D`, `GetPlayerCurrentPlHandle @0x690692`, `LanSrvSetClientScore(aclientid,ascore) @0x681452`; `ExecuteState` function-form and `_misc_ChangePlayer` ABSENT; script arities recorded (§2.2) | `[O]` §2 |
| 4 | `gProfile`: 54-field record + full shipped defaults (`bFamine=True :39`, `igamespeed=1 :21`, …); options-reset never touches `bFamine`; ini files economy-free; no `garr` settings override | `[D]` §3 |
| 5 | Determinations: resbalance default-zero + dormant (`Reset :2664-2666`, writers/readers commented) with live save shape; mercy CLOSED-NEGATIVE (2 achievement-string hits only); sim-score writers/accounting + per-sid audit recipe, score-victory ABSENT; victorystate enum/writers/first-stamp-wins; trigger `endgame_win/lose` → `myplind` mapping; progresstick fields/writers/consumers; mercenary `ind=11` + rolls carried | `[D]` §4 |
| 6 | No still-`[U]` tail closed by static means; six §5 fixed-seed batteries with zero-mismatch termination specified; no invented rate/weight/threshold; `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false` | `[D]` §5 + scope |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; B10 remaining angle EXECUTED (packed CODE search + wrapper arities + profile text + dormancy proofs); byte-proven values promoted to `[D]` only (§§1–4); all live behaviours stay `[U]` until their §5 zero-mismatch batteries terminate. No donor GPU A/B frame exists; no approximation is authorised; no parity claim is made.

*End of DEC-U-B10-SKIRMISH-TABLES. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED.*
