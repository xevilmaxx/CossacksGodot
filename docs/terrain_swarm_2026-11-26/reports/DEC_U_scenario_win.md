---
id: DEC-U-SCENARIO-WIN
worker: DEC-U-SCENARIO-WIN (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed. Net branches (_net_IsServer/Client/Replay/Record, Lan* parsers, net trigger actions 90-98, LAN-human fixups inside CheckEndGame) are cited only to exclude them from the 1:1 sim contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_victory_start.md proved no score/time-limit victory key and cited scenario.script:2995-3008 as the only readable `victorystate := win` write. That report's §1.4/§5-4 claim ('no donor team rule; team-win is port policy') is CORRECTED here: the team-win law lives in `_misc_CheckEndGame` (miscext2.script:3769-3844), run every global tick from nothing.inc:646 — outside the per-player Progress slice that victory_start read. Port keeps SCORE_LIMIT=5000 behind PORT_EXTENSION_SCORE_VICTORY=false and team-win as policy until the change list in §7 lands."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-SCENARIO-WIN — trigger→victory/defeat conditions, team-win law, bexists interaction (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c`, entry `0x8f1a08`; triage `ev_31960c6f`, overview `ev_60b49743` (18918 funcs / 12073 strings, scripts authoritative, 0 unit-name hits). No binary executed, copied, or opened as a target. |
| P2 | Endgame trigger actions read | EV-W: `lib/scenario.script:2994-3064` verbatim §3 — win/lose write `myplind` only, first-transition timestamp, campaign bookkeeping. |
| P3 | Trigger-condition evaluator read | EV-C: `lib/scenario.script:1375-1734` (`_scenario_CheckTriggerConditions`) full 32-kind table + AND/OR + sign compare verbatim §2. |
| P4 | Trigger-action dispatcher head read | EV-A: `lib/scenario.script:1738-1774` (`_scenario_EvaluateTriggerActions`): `myplind` capture, online net-sync pre-pass, sequential `j=0..15` dispatch verbatim §4. |
| P5 | Scenario Progress section read | EV-S: `progress/progress.inc/scenario.inc` (full file, 66 lines): timers → triggers `0..511` in index order → one-shot deactivate → `SwitchTo('Nothing')` verbatim §4. |
| P6 | `_misc_CheckEndGame` read (THE team-win law) | EV-E: `lib/miscext2.script:3767-3844` verbatim §5 — roster gate → live gate → win-stamp-all-survivors + LAN-human fixups. Corrects DEC-U-VICTORY-START §1.4. |
| P7 | Global Nothing ordering read | EV-N: `progress/progress.inc/nothing.inc:83-106,646,657-694`: Scenario (if `bactive`) → … → `_misc_CheckEndGame` (UNGATED) → peacetime expiry verbatim §4. |
| P8 | Per-player exists scan re-pin + gate | EV-B: `units/global.inc/progress.inc:37-141`: whole sim slice (exists + income + squads + AI) gated by `not gScenario.bactive` (`:54`) verbatim §6. |
| P9 | Victorystate writer census (repo-wide grep) | EV-V: 6 writer sites enumerated §7 — `player.script:110-111`, `initmapgen.inc:255-263`, `initmaphistoricalbattle.inc:123-128`, `scenario.script:2996+3050`, `progress.inc:130-132`, `miscext2.script:3052/3056/3108 + 3812/3823/3831 + 3858/3890` (debug-console + CheckEndGame + surrender paths) §7. |
| P10 | Score/time-limit absence grep | EV-0: `victory\|scorelimit\|score_limit\|timelimit\|time_limit\|wincondition\|victory.*threshold` over all `*.inc/*.script/*.global/*.cfg` → exactly 1 hit: `dmscript.global:1662 gc_pause_timelimit = 120` (pause-menu, not victory) `[O-absence]` §7. |
| P11 | Trigger enum census | EV-T: `lib/classes.script:6205-6384`: 512/8/16/32/64/256/32/256/32/64/8 caps; 32 condition ids; 99 action ids; 7 signs; `TScenarioTriggerCondition` (17 params) + `TScenarioTriggerAction` (20 params) field lists verbatim §1. |
| P12 | Team model read | EV-M: `lib/player.script:2140-2172` `_player_SetupTeams` (team-0 → distinct sim teams; shared map-team → shared sim team) + `lib/map.script:142-150` menu defaults + `player.script:116-117` reset verbatim §5. |
| P13 | Donor mission-file survey | EV-F: `data/maps/missions/*.map` (binary trigger blobs) + `*.aix` (tweak scripts only, e.g. `ausmis1.aix` stat tweaks) → per-mission trigger→victory mapping NOT statically recoverable → [U]-F1 §8. |
| P14 | Port `game.gd`/`data.gd` read-only inspection (no edit) | EV-P: `game.gd:7394-7495` (`_winner_of_loser/_team_alive/_player_bexists/_check_player_exists/_check_victory`), `:5342/:5625-5626` call sites; `data.gd:271-282,732-735` victory surface verbatim §7. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. Trigger system census [O]

`lib/classes.script:6205-6384`:

- Caps `[O]`: `gc_scenario_maxflags = 256` (`:6205`); `maxcounters = 256` (`:6206`); `maxtimers = 32` (`:6207`); `maxgroups = 256-1` (`:6208`); `maxzones = 256` (`:6209`); **`gc_scenario_maxtriggers = 512`** (`:6210`); maxobjectives 32 / maxqueries 256 / maxresults 256 (`:6211-6213`); **`gc_trigger_maxconditions = 8`** (`:6215`); **`gc_trigger_maxactions = 16`** (`:6216`); maxresulttriggers 64 / maxqueryresults 8 / maximages 64 (`:6218-6220`).
- Signs `[O]` (`:6239-6246`): `none = 0, equal = 1, notequal = 2, more = 3, moreequal = 4, less = 5, lessequal = 6`.
- Conditions `[O]` (`:6250-6282`): 32 kinds `0..31` — `none 0, undefined 1, triggerIsActive 2, triggerIsNotActive 3, flagActive 4, flagNotActive 5, timerFinished 6, timerNotFinished 7, difficulty 8, playerResources 9, CountOfUnitsInGroup 10, CountOfGroupUnitsInZone 11, CountOfPlayerUnitsInZone 12, triggerIsActiveTime 13, counterValue 14, resultExecutedCount 15, executeState 16, CountOfPlayerUnits 17, CountOfPlayerUnitsInGroup 18, CountOfActingUnitsInGroup 19, logical_OR 20, net_IsServer 21, net_IsClient 22, net_IsOnline 23, net_IsOffline 24, net_IsQueryDialogVisible 25, net_CurrentPlayer 26, net_CurrentPlayerTeam 27, net_CurrentPlayerPosition 28 (= same as current player), net_CountOfPlayersInTeam 29, CountOfUnitsInZone 30, CountOfPlayersTeamUnitsInZone 31`.
- Actions `[O]` (`:6285-6384`): 99 kinds `0..98` — `none 0, undefined 1, service_timerStart 2, service_timerStop 3, service_flagSetActive 4, service_flagSetNotActive 5, resource_resourceAdd 6, resource_resourceRemove 7, resource_resourceSet 8, objective_show 9, objective_hide 10, objective_setDone 11, map_cameraMoveToZone 12, map_revealZone 13, query_show 14, selection_addGroup 15, selection_addUnitsInZone 16, selection_clear 17, player_setAsEnemy 18, player_setAsAlly 19, player_setAsNeutral 20, player_unitsChangePlayer 21, units_DestroyGroup 22, units_KillGroup 23, units_CreateUnits 24, units_MakeUnplayable 25, units_MakePlayable 26, country_unitProduceEnable 27, country_unitProduceDisable 28, country_upgradeEnable 29, country_upgradeDisable 30, country_makeUpgradeInstanly 31, order_attackGroup 32, order_attackZone 33, order_standground 34, order_cancelStandGround 35, order_enableSearchEnemy 36, order_disableSearchEnemy 37, order_moveToZone 38, order_runUpgrade 39, order_doExtractFood 40, order_doExtractWood 41, order_doExtractStone 42, order_goInside 43, gate_open 44, gate_close 45, ferry_goOutside 46, endgame_win 47, endgame_lose 48, advanced_ifThenElse 49 (stub: logs `todo`, scenario.script:3066), advanced_enableTrigger 50, advanced_disableTrigger 51, advanced_enableThisTrigger 52, save_save 53, save_load 54, service_timerStartCustom 55, service_DebugLog 56, service_DebugMessage 57, order_setDirectionToZone 58, order_setUnitsVisible 59, order_setUnitsUnvisible 60, service_counterAddValue 61, service_counterRemoveValue 62, service_counterSetValue 63, order_moveToZoneInstanly 64, advanced_executeState 65, group_Clear 66 … group/order/objective helpers 67-89, net_SetTriggerActive 90 … net_TeamExecuteTriggerActions 98` (net 90-98 excluded from sim contract).
- Records `[O]`: `TScenarioTriggerCondition` (`:6489-6524`): `flagid, counterid, timerid, groupid, zoneid, resultid, bactive, bstate, usecounterid, busecounterasamount, busecounterastime, player, difficulty, resource, amount, sign, time, executestate, stringregister` (+ `Create()` sets `bactive := True`). `TScenarioTriggerAction` (`:6526-6570`): `id, triggerid, flagid, counterid, timerid, groupid, groupidtrg, zoneid, objectiveid, queryid, bactive, bstate, usecounterid, busecounterasamount, busecounterastime, player, playertrg, resource, amount, time, radius, countryid, unitid, direction, formationid, executestate, stringregister, marker`. `TScenarioTrigger` (`:6572-6581`): `name, bactive, bexists, btriggertreeopen, bconditionstreeopen, bactionstreeopen, conditions[0..7], actions[0..15], activetime`.

---

## 2. Condition semantics — exact trigger→victory/defeat vocabulary [O]

Evaluator: `scenario.script:1375-1734`. Per trigger, slots `j = 0..7` are AND-combined with `logical_OR` (id 20) as OR-separator (`:1380-1431`): a slot holding `logical_OR`, or flanked by one, joins the OR-group via `bPrevIsOR/bNextIsOR/bPrevIsConditionOK` (`:1726-1731`); final `Result := bConditionsOK` (`:1733`). Inactive/`none`/`undefined` slots are skipped (`:1396`).

- Counter indirection `[O]` (`:1400-1414`): if `busecounterasamount`, `amount := counters[usecounterid].value` for kinds 9,10,11,12,30,17,18,31,19,26,27,28; if `busecounterastime`, kind 13 takes `time` from a counter.
- Sign law `[O]` (`:798-809` `_scenario_CheckSignCondition`): `equal = / notequal <> / more > / moreequal >= / less < / lessequal <=`; `sign_none` → `False` (ErrorLog line commented out — no veto, just false).
- Kind-by-kind law `[O]`:
  - `triggerIsActive 2` (`:1416`): `triggers[triggerid].bactive`; `triggerIsNotActive 3` (`:1417`): its negation (value-read `not`).
  - `flagActive 4 / flagNotActive 5` (`:1418-1419`): `flags[flagid].bactive` / negation.
  - `timerFinished 6 / timerNotFinished 7` (`:1426-1427`): `timers[timerid].bfinished` / negation. Timers advance in `scenario.inc` (`delta_ms = (GetGameTime-starttime)*1000 >= time`); set by actions 2/3/55 (`:1777-1801`).
  - `difficulty 8` (`:1428`): `gScenario.difficulty = difficulty` (exact equality, no sign).
  - `playerResources 9` (`:1429-1438`): `CheckSign(not gPlayer[pl].res[res], sign, amount)`; `res = none` → `False`.
  - `CountOfUnitsInGroup 10` (`:1439-1444`): `CheckSign(groups[groupid].unitslist.GetCount, sign, amount)`.
  - `CountOfGroupUnitsInZone 11` (`:1445-1480`): count zone-list members whose `TObj.scenariogroupid = groupid`; zone `bactive` required else `False`;UID 0 → ErrorLog, skipped; early `break` once `count > amount` `[D]` (upper-bound short-circuit; exact for threshold signs).
  - `CountOfPlayerUnitsInZone 12` (`:1481-1517`): same shape, `TObj.pl = player`, buildings excluded unless `bstate` (include-buildings).
  - `CountOfPlayersTeamUnitsInZone 31` (`:1518-1555`): same shape, `gPlayer[TObj.pl].team = gPlayer[player].team` — **team is read from the SIM player record**, buildings excluded unless `bstate`.
  - `CountOfUnitsInZone 30` (`:1556-1591`): same shape, no owner filter, buildings excluded unless `bstate`.
  - `CountOfPlayerUnits 17` (`:1592-1603`): buildings-included → `gPlayer[pl].counter.total`, else `counter.farmused`; sign-compare. (This is the defeat-adjacent counter read: `farmused = 0` with `lessequal 0` reproduces the liveness predicate without killing.)
  - `CountOfPlayerUnitsInGroup 18` (`:1604-1630`): group members with `scenariogroupid = groupid AND pl = player`.
  - `CountOfActingUnitsInGroup 19` (`:1631-1645`): group members with `(statetag & move_walk) <> 0 OR (statetag & action_none) = 0`.
  - `triggerIsActiveTime 13` (`:1646-1655`): `activetime > 0` required; `False` unless `(GetGameTime - triggers[triggerid].activetime)*1000 >= time` `[D]` (delta < time → False; equality passes).
  - `resultExecutedCount 15` (`:1656-1661`): `CheckSign(results[resultid].executecount, sign, amount)`.
  - `executeState 16` (`:1662-1675`): runs statemachine `trigger0` state `executestate`, compares returned `IntRegister0` by sign.
  - Net 21-24 (`:1676-1688`): `IsServer/IsClient/IsOnline` passthrough; **`net_IsOffline 24` = `_net_IsOffline AND gamemode = game AND gPlayer[myplind].victorystate = none`** — a trigger gated on 24 stops firing once the interface player has any terminal state.
  - `net_IsQueryDialogVisible 25` (`:1689-1692`): `gbool_gui_querywindow = bstate`.
  - `net_CurrentPlayer 26 / CurrentPlayerTeam 27 / CurrentPlayerPosition 28` (`:1693-1713`): `myplind = amount` / `gMap.players[myplind].team = amount` / `gMap.players[myplind].cid = amount`.
  - `net_CountOfPlayersInTeam 29` (`:1714-1723`): count `i` in `0..11` with `gMap.players[i].bexists AND team = counters[counterid].value` — **roster-side** bexists + counter-selected team (the only condition reading map-side liveness).

---

## 3. Endgame actions — the ONLY scenario victory/defeat writes [O]

`scenario.script:2994-3064`, dispatched from `_scenario_EvaluateTriggerActions` (`:1738-1774`):

- `endgame_win 47` (`:2995-3047`): `gPlayer[myplind].victorystate := win`; `if (victorystategametime = 0) then victorystategametime := GetGameTime`; then campaign-mission progress (`started := 1`, `finished := Min(finished+1, started)`, `maxfinishdifficulty := Max(…, gScenario.difficulty)`), per-campaign achievement bits (`auscam/engcam/fracam/ukrcam/ruscam`, `tutcam` counters), `_profile_SaveStructToUserProfileParser`. (`:2999-3000` spectator-switch lines are commented out — dead.)
- `endgame_lose 48` (`:3049-3064`): mirror with `lose`, `lose := Min(lose+1, started)`; no achievement bits.
- Targeting `[O]`: `myplind = GetPlayerIndexInterfaceIO` captured once at `:1742`. The win/lose branches read **no `.player` action field** — they always strike the interface player, unlike neighbours (`resource_add/remove/set` take `.player` at `:1818-1829`; net/team actions compare `.player` to `myplind` or team-match at `:3196-3280`). Consequence `[D]`: a mission defeats/victories exactly the local human slot; AI/co-op slots are unaffected by these two actions.
- One-shot + re-arm `[O]`: firing sets `triggers[i].bactive := False; activetime := 0` (`scenario.inc`); action 52 `advanced_enableThisTrigger` (`:3082-3084`) re-arms the *currently firing* trigger, so a win/lose trigger CAN refire if re-armed; actions 50/51 toggle other triggers (`:3068-3081`).
- Sibling stub `[O]`: action 49 `advanced_ifThenElse` only logs `todo` (`:3065-3067`) — never invent if/else trigger semantics.

---

## 4. Ordering / precedence — the full endgame pipeline [O]

1. **Global tick head** (`nothing.inc:83-106`) `[O]`: zone→AI-region rect sync → `WriteNew` queue → **`if (gScenario.bactive)` + (offline OR (lan-ready AND gamemode = game AND gamestage > waitingloading)) → `ExecuteState('Scenario')`** → movie → projectile sim → pathing.
2. **Scenario section** (`scenario.inc`, full file) `[O]`: (a) timers: `bfinished := True` when `(GetGameTime - starttime)*1000 >= time`; (b) triggers `i = 0..511` **in index order**: skip `!bactive`; stamp `activetime := GetGameTime` if `<= 0`; battle-mode pre-scan (`gMap.bbattle`): only net-kind conditions may veto (`bConditionExists := False; break`), any other active condition breaks the scan loop (`:1674-1704` path via `else break`); non-battle: scan stops at the first active real condition; (c) `if (bConditionExists AND _scenario_CheckTriggerConditions)` → one-shot deactivate + `_scenario_EvaluateTriggerActions` + editor refresh + `bUpdateAIRegionsActiveState := True`; (d) `if (_net_IsOffline AND GetProgressingPauseMode)` (query dialog requested) → **`break`: later triggers do NOT run this tick**; (e) `UpdateAIRegionsActiveStateToTriggers`; `SwitchTo('Nothing')`.
3. **Global tick tail** (`nothing.inc:646-694`) `[O]`: **`_misc_CheckEndGame` runs UNGATED** (no `bactive`/gamemode gate) → peacetime expiry (`gbool_peacemode AND gametime > gfloat_peacetime AND not replay AND not client` → clear flag, destroy `ptborder` objects via `WriteFreeList`, broadcast `WritePeaceTime`, `GameObjectRequestToDestroy`, minimap refresh).
4. **Per-player slice** (`progress.inc:37-184`) `[O]`: staggered by `addtime = 0.125*plInd + (bexists ? 4*2.0 s : 12*2.0 s)` (`:56-61`, `gc_global_TimeCheckExists = 0.01*200`, `dmscript.global:1484`); surrender guards → `bbattle ⇒ bexists := True` → exists scan (peasant `visual_none+essential_none` / human inside-transport / built `usage=center`, `farmused` shape) → **first-transition lose stamp + `_misc_KillPlayerUnits`** (`:124-135`) → income/consume (`plind < 11`) → squad hold/disband → `ProgressAI`. **The entire block is inside `if (not gScenario.bactive) AND gamestage > waitingloading AND gamemode in (game, spectator)`** (`:54`) — in scenario/mission mode there is NO auto-defeat, NO income/consume, NO squad AI from this slice.
5. **Precedence summary** `[D]`: skirmish (`bactive = False`) = exists-scan lose-stamps (staggered, per-player) + `CheckEndGame` win-stamps (every global tick) + peacetime expiry. Scenario (`bactive = True`) = trigger win/lose-stamps on `myplind` (index order, one-shot, query-break) + `CheckEndGame` still active globally + peacetime expiry; NO auto-defeat. `CheckEndGame` therefore **overrides trigger silence**: a mission that never fires an endgame trigger still stamps wins when its team setup collapses to one live team (§5).

---

## 5. `_misc_CheckEndGame` — the donor team-win law [O] (corrects DEC-U-VICTORY-START §1.4)

`lib/miscext2.script:3769-3844`, called every global tick (`nothing.inc:646`) + from `_misc_Surrender` (`:3861-3862` online-server, `:3893` offline):

- Phase 1 — roster gate `[O]` (`:3775-3788`): over `gMap.players[i].bexists` (**roster-side** liveness, static after gen except spectator purge): collect `gPlayer[i].team` (**sim-side** teams); if two rostered slots have distinct sim teams → `bSecondTeamExist`. Else return `False`, **no writes**.
- Phase 2 — live gate `[O]` (`:3791-3803`): pairwise over `gPlayer[i].bexists AND NOT gMap.players[i].bleave` (**sim** liveness, leavers excluded): any two such slots on distinct teams → `bOneTeamLeft := False`, break.
- Stamp `[O]` (`:3804-3841`): if one team left: every `gPlayer[i]` live + non-leaver + `victorystate <> win` → `win` (+ `gametime` iff 0), recording `winnerteam`; then LAN-human fixups (out of scope, cited): humans with `lanid > 0` + `lose` on `winnerteam` → flipped to `win` (`:3819-3826`); humans `lanid > 0` neither lose nor win → `lose` (`:3828-3834`); `if (bchanges)`: `LanServerSendResults + LanCloseSessionSetScores` (net, excluded).
- Team model `[O]`: `_player_SetupTeams` (`player.script:2140-2172`): every sim-team-0 slot gets a fresh `curTeam = 1,2,…` UNLESS map-teams match (`mapInfo`), in which case mates share the new team. Menu defaults (`map.script:142-150`): slot frame `team := 0`, quick-play 1v1 sets teams 1/2. Reset default `player.team := 0` (`player.script:116`). Consequence `[D]`: FFA (all map-team 0) ⇒ all-distinct sim teams ⇒ `CheckEndGame` stamps `win` on the last live non-leaver; team games ⇒ stamps `win` on every live member of the surviving team. Unused-var edge `[D]`: `winnerteam` is only meaningful when `bchanges`; script `var` zero-inits (cf. `count` accumulators §2), so the `winnerteam > 0` guard (`:3819`) is deterministically false on the no-stamp path — port initialises `-1`, same outcome, tagged in §7.
- Callers `[O]`: global tick, online-server surrender, offline surrender (`_misc_Surrender :3848-3895`: sets `bleave`, stamps caller `lose` first — server/offline only — then `CheckEndGame`, so a surrender can immediately crown the surviving team).

---

## 6. Interaction with the normal `bexists` defeat scan [O]

- Skirmish: scan (`progress.inc:65-141`) clears sim `bexists` and stamps `lose` (first transition only) + kills units; `CheckEndGame` (global, later in the same frame per §4) reads the fresh `bexists` and may stamp `win` on survivors **in the same tick** `[D]` (ordering §4.1 vs §4.3). Surrender/leaver branch (`:137-139`) kills units with NO victorystate write on that path — the `lose` comes from `_misc_Surrender` itself.
- Scenario: scan block never runs (`:54` gate); sim `bexists` is whatever init/trigger logic set: historical-battle forces all `True` (`initmaphistoricalbattle.inc:123-128`); scenario-start console path sets `bexists := (farmused > 0)` per slot + slot 0 forced `True` offline (`miscext2.script:3073-3086`); trigger 80/81 `player_enableAI` sets `bexists := True` (`scenario.script:2309-2318`).
- Spectator purge `[O]` (`initmapgen.inc:255-263`): roster slots with spectator country → roster `bexists := False` + sim `bexists := False` + `bleave := True` + `lose` stamp (no timestamp guard — unconditional write).
- Debug console `[O]` (`miscext2.script:3042-3062`): `scenario win/lose` writes `gPlayer[0]` directly (no timestamp guard, immediate `exit`) — tooling path, never a sim rule; port must not wire it.

---

## 7. Score / time-limit / peaceful verdict + port change list (no edits made)

- Score victory: ABSENT `[O-absence]` (P10; sole `timelimit` hit is pause-menu `gc_pause_timelimit = 120`). `Data.VICTORY = "destroy_all" / SCORE_LIMIT = 5000.0 / PORT_EXTENSION_SCORE_VICTORY = false` (`data.gd:277-282`) stays PORT EXTENSION behind the existing flag — never a 1:1 law.
- Time-limit victory: ABSENT (same grep). Peacetime (`nothing.inc:657-694`) only suppresses damage then expires; never writes victorystate. Port `PEACE_TIME` gate (`game.gd:7466-7467`) is harmless policy; seconds table already corrected (`data.gd:732-735`).
- Peaceful: no `peaceful` victory/liveness literal anywhere — correctly absent from port.

Port change list (`variant3d/scripts/game.gd` + `data.gd`; COORD/owner applies; this worker wrote no code):

1. **`game.gd:7394-7414` team-win — rewire to EV-E.** Replace `_winner_of_loser` (single-winner pick over units/buildings emptiness) + `_team_alive` with two-phase donor law: phase-1 roster gate over menu slots (`bexists` roster flag, sim teams), phase-2 live gate over `_player_bexists(pi)` + `bleave`. Stamp `win` (+ `lose_t`-style stamp iff 0) on EVERY live non-leaver non-win survivor, not one picked winner. Roster `bexists` must be stored per slot (init from menu; spectator purge per `initmapgen.inc:255-263`); sim `bexists` already exists (`_player_bexists`). Drop LAN-human fixup branches (net, out of scope). Cite `miscext2.script:3769-3844 + nothing.inc:646`.
2. **`game.gd:7448-7457` defeat — add winnerteam-safe first-transition + surrender path.** Keep one-shot `eliminated` guard (= donor `bPrevExists` edge); add `_surrender(pi)`: set `bleave`, stamp `lose` (+ stamp time iff 0), then run the §5 check (donor `:3848-3895`). Cite `player.script`/`miscext2.script:3846-3895`.
3. **`game.gd:7462-7495` `_check_victory` — split skirmish/scenario paths.** Add `scenario_active: bool` (default false; no trigger engine yet — see U-F1). When true: skip `_check_player_exists` defeat scan (donor `:54` gate) AND skip auto-win; only trigger stamps (future) + §5 check apply. When false: current scan + §5 check. Move the `CheckEndGame` equivalent to run AFTER the per-player slice every global tick (currently `_check_victory()` at `:5342` already post-slice — keep position, cite `nothing.inc:646`). Peace gate stays.
4. **`game.gd:7420-7442` `_player_bexists` — keep, annotate gap.** Donor tag test is `visual_none+essential_none` over engine state tags (`progress.inc:93-106`); port maps to `not dead and not hidden` + human-inside-transport + built `cen` — keep as PORT APPROXIMATION with cite; human-transport branch must key on `p.is_ai == false` (already) — matches `(gMap.players[plInd].bhuman)` (`:100`).
5. **`game.gd:7508+` serialize — add roster `bexists`, `bleave`, per-player `victorystategametime`.** `victorystate_int` mirror (`:7572-8028`) already grounded (`dmscript.global:777-779`); add the two flags the §5 law reads. No save-version bump without COORD.
6. **`data.gd:277-282` — keep + relabel comment.** Append: `NO donor score/time-limit key exists (DEC-U-SCENARIO-WIN §7/P10); scenario win writes exist only via trigger actions 47/48 (scenario.script:2995-3064) and team law (miscext2.script:3769-3844)`.
7. **Do NOT port**: debug-console `scenario win/lose` (`miscext2.script:3051-3058`), commented spectator-switch (`:2999-3000/3053-3054`), `advanced_ifThenElse` (stub), net actions 90-98, LAN-human fixups (`:3819-3834`).

---

## 8. Still-[U] register — fixed-seed scenario captures, zero-mismatch criteria (no trigger invented)

| # | Item | Static state after this ticket | Exact experiment (owner-authorised; donor binary run by owner only, never this worker) |
|---|---|---|---|
| U-F1 | Per-mission trigger→victory mapping (which shipped missions fire 47/48, with which condition kinds/params) | System fully recovered (§1-§4); mission blobs are binary `.map` + tweak-only `.aix` (EV-F) | Owner opens each `data/maps/missions/*.map` in the donor editor, exports the trigger list (kind ids + params per §1 field lists). Port test harness replays ONLY exported rows (each row cites `mission + trigger index`): fixed seed S, 2-slot fixture, condition forced true by construction (e.g. `counterValue` pre-set). **Zero-mismatch:** 3 identical-seed runs → identical `victorystate_int` + identical stamp tick; any invented kind/param (not in §1 enums) fails the run. |
| U-E1 | `CheckEndGame` same-tick interaction with staggered exists scan | Order recovered (§4.1 vs §4.3) `[D]`; engine slice scheduler uncited | Fixed seed S, 1v1 skirmish fixture: kill P1's last peasant/center at tick T (port harness). **Zero-mismatch:** `lose` stamp tick and `win` stamp tick identical across 3 runs AND `win_tick >= lose_tick` (same global frame allowed); any `win_tick < lose_tick` = ordering bug. |
| U-E2 | Leaver exclusion (`bleave`) in phase 2 | Law verbatim §5; port has no `bleave` flag | 2v2 fixture, seed S: mark one team-A slot `bleave` (surrender path change §7-2) with units alive. **Zero-mismatch:** 3 runs → surviving team-B ALL stamped `win` same tick; leaver slot keeps `lose`, never flipped to `win`. |
| U-E3 | FFA last-man win vs multi-team partial wipe | Law `[D]` §5 (distinct sim teams via SetupTeams) | FFA 4-slot, seed S: eliminate slots in fixed order. **Zero-mismatch:** no `win` stamp until exactly one live non-leaver remains; final survivor `victorystate_int = 1`, all others `2`, identical ticks across 3 runs. Then 2v2: wipe one team → BOTH survivors `win` same tick. |
| U-T1 | `triggerIsActiveTime` ms boundary + `activetime` one-shot reset | Law verbatim (`>=` passes at `:1649-1651`; reset to 0 on fire) | Timer-trigger fixture, seed S. **Zero-mismatch:** fire tick = `ceil(time_ms / dt)` exactly, identical across 3 runs; re-armed copy (action 52) refires with fresh `activetime`. |
| U-T2 | Zone-count early-break (`count > amount`) vs exact counts | Short-circuit `[D]` §2; exact for threshold signs | Zone fixture with N units, `CountOfUnitsInZone` + `moreequal N`. **Zero-mismatch:** fires iff N present; add N+1 → same fire tick (break path), never earlier. |
| U-T3 | Battle-mode (`gMap.bbattle`) condition pre-scan | Law verbatim §4.2; port `battle_mode` exists but no trigger engine | Deferred until trigger engine lands (U-F1 harness): battle fixture with one net + one non-net condition. **Zero-mismatch:** non-net condition neither fires nor vetoes; net veto respected. Until then port asserts nothing about battle triggers. |
| U-S1 | `scenario.inc` query-dialog `break` (later triggers skipped) | Law verbatim §4.2; GUI path | Port harness: two fireable triggers, second asserts unreachable when first raises query. **Zero-mismatch:** trigger[1] fires same tick iff no query requested, else next tick. GUI-owned; sim asserts only the break. |
| U-P1 | `ptborder` destroy on peacetime expiry (sim side) | Expiry verbatim §4.3 (`WriteFreeList` + destroy + minimap); port border handling unverified | Peacetime-index fixture, seed S. **Zero-mismatch:** border entities all destroyed on the exact expiry tick across 3 runs; minimap primitives cleared. Until verified, port peace expiry stays PORT APPROXIMATION. |

---

## 9. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items rest on donor TEXT `[O]` with `file:line`; open items name exact next reads/captures in §8.
- CORRECTION logged: DEC-U-VICTORY-START §1.4/§5-4 ("no donor team rule; `_winner_of_loser/_team_alive` pure port policy") is superseded by EV-E/EV-M: the team-win law is donor-verbatim (`miscext2.script:3769-3844` + `player.script:2140-2172`), running globally in BOTH modes (`nothing.inc:646`). The port's single-winner pick and units-emptiness liveness remain PORT APPROXIMATION until §7-1 lands.
- No number invented: score has NO threshold, time limit has NO value, per-mission triggers are NOT listed (U-F1 forbids inventing any). Every port default filling these gaps stays tagged `PORT EXTENSION` / `PORT APPROXIMATION` / `PORT POLICY`.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + negative-grep logs; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed. Network excluded throughout.

*End of DEC-U-SCENARIO-WIN.*
