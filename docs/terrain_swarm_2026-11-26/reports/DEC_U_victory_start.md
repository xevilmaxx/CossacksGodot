---
id: DEC-U-VICTORY-START
worker: DEC-U-VICTORY-START (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed. Net branches (_net_IsServer/Client/Replay/Record, LanServerSendResults, WritePeaceTime/WriteFreeList net effects) are cited only to exclude them from the 1:1 sim contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_skirmish_tables.md resolved 6-resource start tables (double-add quirk), role->airole map, masks, liveness/victory heads; DEC_U_save_float.md closed victorystate ints 0/1/2. This ticket attacks the still-[U] remainder from PORT1TO1_skirmish_logic.md: exact victory condition set (score thresholds, elimination, time limit, peace/peaceful), start placement/camera, queue/training timing."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-VICTORY-START — victory/defeat literals + precedence, start placement/camera, queue timing (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c` (matches DEC-U-SKIRMISH-TABLES §0). No binary executed, copied, or opened as a target. |
| P2 | `units/global.inc/progress.inc:1-185` full read | EV-V: defeat/liveness transition verbatim §1 (all `[O]`). Precedence + stagger + slice order re-pinned against DEC-U-SKIRMISH-TABLES §7. |
| P3 | `progress/progress.inc/nothing.inc:650-695` peacemode-expiry read | EV-P: `gbool_peacemode/gfloat_peacetime` expiry + ptborder destroy + WritePeaceTime verbatim §2 (all `[O]`). |
| P4 | `dmscript.global` enum grep (read-only) | EV-G: `victorystate` 777-779, `MaxPlayerCount` 97, `peacetime` 1055-1066, `startingunits` 1032-1045, `limit` 1090-1097, `MaxObjCount` 110, `_misc_GetPeaceTime` 4262-4277, order-type enum 630-660, `buildtime`/`frames_to_time` 174-182 §1-§4 (all `[O]`). |
| P5 | `common.inc/dogenerate.inc:230-396,486-510,980-1231,1599-1930,2054-2064` start/peacetime dispatch read | EV-S: start dispatch + `CreateStartPoint` + `GetRandom` + team/shuffle + peacetime init verbatim §3 (all `[O]`). |
| P6 | `common.inc/generatemap.inc:285-502` bitmap-start scan read | EV-M: `-10000` sentinel + white-pixel scan + dedupe + rescale verbatim §3 (all `[O]`). |
| P7 | `common.inc/initmapgen.inc:240-287` post-gen read | EV-I: spectator forced-lose + gamestage + version gates verbatim §1 (all `[O]`). |
| P8 | `lib/scenario.script:2995-3062` endgame-trigger read | EV-T: ONLY `win=1` write path in readable scripts (trigger actions) verbatim §1 (all `[O]`). |
| P9 | `lib/player.script:33-138,200-228,349-396,3162-3171` + `lib/unit.script:478-506,571-581,5993-6074,6572-6608,9080-9126` producer/queue read | EV-Q: dummy creation, access-control/art gates, order-merge, build-progress visuals, builder caps verbatim §4 (all `[O]`). |
| P10 | `units/building.inc/doprogressorders.inc:1-379` produce-timing read | EV-QT: full train-timing formula + gates + completion verbatim §4 (all `[O]`). |
| P11 | `units/building.inc/nothing.inc:293-492` + `units/unit.inc/nothing.inc:17-588` cadence grep | EV-C: capture cadence + produce-tick driver placement verbatim §4 (all `[O]`). |
| P12 | `lib/misc.script:460-498` conversion + `startingsettings.cfg:1-13,182-504` key grep | EV-K: `PixelsToTiles/FramesToTime/BuildtimeToTime` + cfg key absence (no victory/score/timelimit keys) `[O]` §1/§4. |
| P13 | `variant3d/scripts/game.gd` + `data.gd` read-only inspection (no edit) | EV-PORT: live `VICTORY/SCORE_LIMIT/PEACE_TIME/BUILD_QUEUE_LIMIT/START_PEASANTS/DONOR_PEACE_TIMES/_check_victory/_player_bexists/_tick_building/train_unit` lines §5 (all `[O]` port-side). |
| P14 | Camera-focus negative search | `initmapgen.inc` + `dogenerate.inc` grep for `camer|focus|select.*start` → record-manager noise only; NO camera literal found `[O-absence]` §3. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. Victory / defeat — exact literals and precedence [O]

### 1.1 Value table (closed, re-pinned from DEC-U-SAVE-FLOAT §5)

- `dmscript.global:777-779` `[O]`: `gc_player_victorystate_none = 0; _win = 1; _lose = 2;`
- Field: `TPlayer.victorystate: Integer` + `victorystategametime: Float` (serial contract; types `[O]`).
- Behavioural anchors `[O]`: `initmapgen.inc:263` assigns `…_lose` (spectator purge); `initmaphistoricalbattle.inc:127-128` assigns `…_none` + `victorystategametime := 0`.

### 1.2 The ONLY skirmish defeat law (verbatim `units/global.inc/progress.inc:56-141`)

Order inside the per-player Progress slice (§1.4):

1. Stagger gate `[O]` (`:56-61`, `dmscript.global:1484` `gc_global_TimeCheckExists = 0.01*200 = 2.0 s`): `addtime := 0.125*plInd + (bexists ? 4*2.0 = 8.0 s : 12*2.0 = 24.0 s)`; `_player_CheckProgressLastTimeAndIncrease(lastcheckexists, 0, addtime)`.
2. Surrender guards `[O]` (`:63-64`): `bnetsurrender := (_net_IsServer) {and bleave}`; `bsurrender := (_net_IsOffline) and (victorystate == lose)`. If either, the exists block is skipped (no re-entry).
3. Battle-mode short-circuit `[O]` (`:65-68`): `if (gMap.bbattle) then bexists := True` (no scan, no kill).
4. Peasant/building scan `[O]` (`:69-123`):
   - `if (0 < farmused < 100)`: `bexists := False`, then scan peasant section for `statetag visual_none+essential_none` (or human-owner `insideofuid<>0`); if none, scan building section for built `usage=center` (`bbuilt`). Either hit sets `bexists := True`.
   - `else bexists := (farmused > 0)`.
5. Lose transition `[O]` (`:124-135`): `if (not bexists) and ((bai) or (map-player human))`: `if (GetPlayerGameObjectsCountByHandle > 0) then _misc_KillPlayerUnits(plHnd)`; `if (bPrevExists)`: `victorystate := lose`; `if (victorystategametime = 0) then victorystategametime := GetGameTime`; `_misc_LanServerSendResults` (net — excluded from sim contract).
6. Leaver branch `[O]` (`:137-139`): surrendered/leaver with units → `_misc_KillPlayerUnits` only (no victorystate write on this path).

Port note: this is the law behind `game.gd:7060-7073` `_check_player_exists` — the donor writes `l`+`gametime` exactly once (first transition), never a score, never a timer.

### 1.3 Score victory / time-limit victory: ABSENT from all readable donor scripts [O-absence]

- `startingsettings.cfg` key grep (P12): keys present are `startingunits/dataversion/addresources/countries/masks/legends` only. **No `victory`, `score`, `scorelimit`, `timelimit`, `time_limit`, `peaceful`, `wincondition` key exists** in the file (grep 0 hits for those stems).
- The ONLY `victorystate := win` write in readable scripts is scenario-trigger-gated `[O]` (`scenario.script:2995-3008`): `gc_trigger_action_endgame_win → victorystate := win; victorystategametime := GetGameTime (if 0)` + campaign-mission progress bookkeeping. The `lose` mirror is `:3049-3062`. These are mission/trigger paths (`gScenario.bactive`), not skirmish auto-rules.
- Consequence `[D]`: **there is no donor score threshold and no donor time-limit literal to recover**. `Data.VICTORY="score"` / `Data.SCORE_LIMIT=5000.0` (`data.gd:265-266`) have NO donor counterpart — they stay `PORT EXTENSION` behind the existing `PORT_EXTENSION_SCORE_VICTORY=false` opt-in (`game.gd:7088`). Never gate 1:1 behaviour on them. Never invent a threshold (no 5000, no timer value).

### 1.4 Full Progress-slice precedence (the victory context) `[O]` (`progress.inc:37-184`)

`GetPlayerCurrentPlHandle → plInd`; `if (lastprogresstime>0) and (deltatime>0)`; client/replay global does not progress (`:46-49`); else: battle-music timer (`:52-53`); gamestage/gamemode gate (`:54`: `not gScenario.bactive` and `gamestage > waitingloading` and `gamemode in (game, spectator)`); exists block §1.2; `if (plind < gc_MaxPlayerCount-1 = 11)`: `_player_ProcessResourceIncome → _player_ProcessResourceConsume` (`:144-148`); non-AI `CalcSquadsMoveCount` gated by `(0.001*plInd)+0.3 s` (`:150-154`); squad hold loop (`:156-172`); non-AI `CheckSquadsDisband` (`:174-175`, threshold `count < basecount*0.25`, `dmscript.global:156`); `if (bexists and (bai or adviser-enabled)) then ExecuteState('ProgressAI')` (`:177-178`); `progresstick += 1; lastprogresstime := GetGameTime` (`:181-184`).

Donor has NO `_winner_of_loser` / team-continuation rule in this slice: `game.gd:7009-7032` `_winner_of_loser/_team_alive` team aggregation is PORT policy, not donor law — label it as such and never present a team-win as 1:1. [SUPERSESSION-FIX: point-in-time/historical claim, not current — SUPERSEDED by `DEC_U_scenario_win.md` §5/§7 (team-win is donor-verbatim `CheckEndGame`, `miscext2.script:3769-3844`, global `nothing.inc:646`; source label at `game.gd:8828`); parity UNVERIFIED — NO PARITY CLAIM.]

---

## 2. Peace / peaceful mode — timed protection rule, NOT a victory condition [O]

### 2.1 Enum + seconds mapping (CORRECTION to the port table)

- `dmscript.global:1055-1066` `[O]`: `peacetime_default=0, _10=1, _20=2, _30=3, _45=4, _60=5, _90=6, _120=7, _180=8, _240=9, _reserved=10, _15=11`.
- `dmscript.global:4262-4277` `_misc_GetPeaceTime(ind)` `[O]`: `default: 0; _10: 10; _20: 20; _30: 30; _45: 45; _60: 60; _90: 90; _120: 120; _180: 180; _240: 240; _15: 15` (seconds; `_reserved` has no arm — falls through).
- **Port `DONOR_PEACE_TIMES = [0,10,20,30,40,50,60,90,120,180,240]` (`data.gd:674`) is WRONG** `[D]`: `40/50` are invented, `45/15` are missing, and the donor is an 11+1-slot INDEX enum, not a seconds menu. Correct 1:1 surface: index→seconds table above (indices 0-9, 11; index 10 reserved/unmapped).

### 2.2 Init + expiry (verbatim)

- Init `[O]` (`dogenerate.inc:2054-2064`): `gbool_editor_peacemode := False; gfloat_peacetime := _misc_GetPeaceTime(additional.peacetime); gbool_peacemode := (additional.peacetime <> peacetime_default); if (gbool_peacemode) then …` (border setup follows).
- Expiry `[O]` (`progress.inc/nothing.inc:658-695`): `if (gbool_peacemode) and (gametime > gfloat_peacetime) and (not replay) and (not client)`: `gbool_peacemode := False`; destroy `ptborder` objects via `WriteFreeList`; broadcast `WritePeaceTime` with `fbstate := gbool_peacemode`; `GameObjectRequestToDestroy` each border; `GUIMiniMapPrimitivesClear + _misc_UpdateMiniMapPrimitives(True)`.
- Combat gate `[O]` (`miscext2.script:294-326`, per DEC-U-SKIRMISH-TABLES §2): peacetime territory check — attacker takes `hp := 0` when firing outside mutual enemy territory (`bSkipOnDeath`), mutual-enemy-territory sets `bPeaceSkip := False`.
- There is NO `peaceful` victory/defeat/liveness write anywhere on these paths — peace only suppresses damage and expires on the timer. `game.gd:7082-7083` gating `_check_victory` on `PEACE_TIME` is PORT policy (harmless, keep labelled); the seconds SOURCE must become the index→seconds table above.

---

## 3. Start placement — exact literals; camera focus: statically ABSENT [O / U] [SUPERSESSION-FIX: point-in-time/historical claim, not current — camera ABSENT finding is file-scope only; path-scope SUPERSEDED by `DEC_U_start_deep.md` §3 (wire found at `doprogress.inc:41`; impl tasks 221/227); camera numerics still [U]; parity UNVERIFIED — NO PARITY CLAIM.]

### 3.1 Bitmap starts (fixed maps) `[O]` (`generatemap.inc:304-502`)

- Sentinel `[O]` (`:304-308`): all 12 `gMap.players[].startx/y := -10000`.
- Detection `[O]` (`:315-343`, `:400-443`): pixel is a start iff `(fr=1) and (fg=1) and (fb=1)` (white, i.e. 255,255,255); per-player dedupe (`spInd=0` or differs from previous; second loop also scans all prior `i < spInd` with `bdubl` flag); cap `spInd < gc_MaxPlayerCount` else `ErrorLog('spInd>gc_MaxPlayerCount')`; start pixels are zeroed (`fr=fg=fb=0`) so they never become terrain; `gPatternMask := False` for black `(0,0,0)` and white `(255,255,255)` cells, `True` otherwise (`:491-495`).
- Rescale `[O]` (`:498-502`): `startx := -(MapWidth div 2) + (bitmapx/srcwidth)*mapwidth`, same for `y` (integer `div` on the half-width, float scale on the bitmap ratio).
- No camera, focus, selection, or rally literal exists on this path.

### 3.2 Random-map starts `[O]` (`dogenerate.inc`)

- Slot tables `[O]` (`:486-491` + `initmapgen` seeding): `arrStartPos[0..7]`, `arrStartPosBusy[i] := -1`.
- `CreateStartPoint(plInd, pointx, pointy, minesdensity, spcount)` `[O]` (`:980-988`): `_misc_FillPatternMaskElipse(pointx, pointy+2, cCircle1MaskX, cCircle1MaskY)`; `SetupMines(pointx, pointy, 0, 1, minesdensity, spcount)`; `SetupStartingResources(pointx, pointy)`. (Ellipse `+2` y-offset is verbatim — port keep-clear must reproduce it, not centre on the point.)
- Draws `[O]` (`:990-997`): `GetRandom(n) = floor(RandomExt*n)`; `GetRandomRange(min,max) = min+floor(RandomExt*(max-min+1))`.
- Team clustering `[O]` (`:999-1088`): first point uniform `GetRandom(count)`; each further point = most-voted nearest-to-existing (vote count, tie-break smaller summed distance).
- `RandomStartingPoints` `[O]` (`:1090-1226`): `gRecordGeneratorVersion<61` legacy path (`:1093-1100`, `SetRandomKey` per player); modern path shuffles `arrStartPosBusy`/`teamlist`/`points` with `SetRandomKey(gMap.settings.gen.randkey1)` + `GetRandom` draws (`:1100-1226`), then `CreateStartPoint(i, …)` + `gMap.players[i].startx/y := arrStartPos…` (`:1114-1117,1190-1226`).
- Peasants `[O]` (`:1918-1921` + `CreateStartPointPeasants :1231+`): unit creation pass AFTER the mask/pattern pass (pre-shuffle circle stamp `r=5` buildings / `1` units + 3 D07 ellipses preserved per DEC-U-SKIRMISH-TABLES §4).
- Owner BFS + mine/resource provisioning at `:1370-1428/:1770` (FillOwnerMap + SetupMines per slot) — port `_ensure_start_ore_clusters` is a substitute, not the donor BFS.

### 3.3 Camera / initial focus: NO donor literal recovered — stays [U]

- P14 negative search `[O-absence]`: `initmapgen.inc` and `dogenerate.inc` contain no `camera/focus/start-selection` assignment; the only `select` hits are `ParserSelect*` record-manager calls. No `startx/y → camera` wiring exists in any read pass.
- Consequence: the port's spawn-facing/peasant-grid/camera-forward placement (`game.gd:3640-3678`) is PORT APPROXIMATION. Do NOT invent a camera target, zoom, or facing constant.
- Experiment E-CAM (owner-authorised, fixed seed): generate seed S with N=2 on a shipped bitmap with 2 white pixels at known bitmap coords; record `gMap.players[i].startx/y` (expect rescale formula §3.1) AND the owner-session initial camera target (first rendered frame centre) across 3 runs. **Zero-mismatch criterion:** identical seed → byte-identical `startx/y` pair AND identical camera target; any camera jitter across identical runs = engine-side default, declared PORT CHOICE, never donor law.

---

## 4. Queue / training timing per category — exact formula, no per-category constant [O]

### 4.1 Time base (no invention)

- `[O]` `misc.script:470-482`: `_misc_FramesToTime(v) = v*gc_frames_to_time`; `_misc_BuildtimeToTime(v) = v*gc_frames_to_time*gc_buildtime_modifier`; `dmscript.global:174-179`: `gc_frames_to_time = 0.03125` (32 fps), `gc_buildtime_modifier = 10`.
- `[O]` `unit.script:571-581`: units `objbase.buildtime := _misc_FramesToTime(buildtime)` (NO ×10); `unit.script:478-506`: buildings `objbase.buildtime := _misc_BuildtimeToTime(buildtime)` (×10). Category timing differences ARE these per-sid `buildtime` frame literals — there is no second per-category train constant.

### 4.2 Order capacity (donor caps vs port caps)

- `[O]` `dmscript.global:113` `gc_obj_MaxOrderCount = 12` (slots per building, TOrderInfo 12-slot order in DEC-U-SAVE-FLOAT §0-P10); producer carries batch size in ONE order's `amount`, not N slots (DONOR_RECRUIT_MODIFIERS D19, re-pinned). Port `BUILD_QUEUE_LIMIT=10` (`data.gd:260`) is 2 short of donor and counts jobs, not slots — PORT APPROXIMATION until raised/rewired.
- `[O]` `dmscript.global:464` `gc_ai_max_construction_sites = 12`; `[O]` `unit.script:9092-9120` builder caps: mine `min=max=5`, farm `min=max=2`, else `min = bcount div 2`, `btime = Round(buildtime*32/10)`: `btime<=100 → max = bcount div 2`; `<1000 → max = bcount*2 div 3`; `<2000 → max = bcount*3 div 4`; else `max = bcount`. Port `MAX_BUILDERS_SENT=8` has no counterpart here — PORT APPROXIMATION.
- `[O]` order-type enum `dmscript.global:630-650` (`none=0 … build=17, guard=18, repair=19, exitunits=20`), `gc_obj_order_produce_infinite = -1` (`:660`).

### 4.3 Ordering (cost charged at order time) `[O]` (`unit.script:5995-6053`)

`_unit_OrderProduce(goHnd, ordercid, orderid, amount)`: scan slots top-down; same `produceid` + (`costpercent` in (100, 0) or `unitcount = orders[i].info.restype`) → merge (`amount += amount`, charge each unit via `_unit_ApplyCostByID` loop) unless infinite↔finite collision (cancel-then-exit path `:6011-6038`); else new slot: charge loop (skipped for `usage=field`), `_unit_AddOrder(…, produce, …, upgradeid=ordercid, produceid=orderid, restype=unitcount, amount, …)`.

### 4.4 Progress (the per-tick train formula) `[O]` (`building.inc/doprogressorders.inc:123-379`)

1. `bStart := (progress = 0)` (`:139`).
2. Gates at start AND every tick (`:142-169`): `bFarmOk := farmused < farm`, clamped by map-limit table `[O]` (`:143-152`, `dmscript.global:1089-1098`: limits `500/750/1000/1500/2200/3000/5000/8000` for settings 1-8); `bUnitLimitOk := (total < gc_MaxObjCount = 32000)` (`:164`, `:110`); `bArtOk := artcount[artind] < artlimit[artind]` (`:167`); port-place free `cMinDist = 3` (`:19`); infinite-cost recheck + log; food rule verbatim `:199-200`: `if (not res.food < 500) and (price.food > 0) then bEnoughResInfinite := False` (kept verbatim under the DSL `not`-rule; do NOT reinterpret).
3. Tick `[O]` (`:217-234`): `deltatime := GetGameTime - lastprogresstime` (guarded `lastprogresstime>0, deltatime>0`); **`deltabuildtime := deltatime / objbase.buildtime`** (`:221`); AI-humanai difficulty scale (`:222-231`): `easy ×0.3, normal ×0.50, hard ×0.75, veryhard ×1, impossible ×1.25`; `progress += deltabuildtime`, clamp 1 (`:232-234`); AI capturer-near check pins `progress := 0.995` (`:235-239`).
4. Completion `[O]` (`:247-372`): at `progress >= 1` (and `bProcess`): exit-point spawn (`exitCount/exitPoints` or self pos; port override via `_misc_GetPortResourcePoint`); `amount -= 1` unless infinite; `progress := 0`; access-control recheck → `_unit_ProduceUnit` refill path (`:280-290`); `amount=0 → RemoveOrder`; infinite rotates slot to last free (`:295-313`); `WriteNew` spawn + `SetSTO/hide+birth` tags + `OrderLeave` (+ rally/resource for land, `GetBuildingExitData` for ships).
5. Upgrade orders on the same slot (`:380-383`) delegate to `_misc_UnitProgressOrderPerformUpgrade` — timing inside that fn was NOT read this ticket → stays `[U]`-Q2 (experiment §6).

So: **train time for every category = `objbase.buildtime` seconds** (per-sid frames × §4.1 factor), progress linear in game-time, NO queue-slot time bonus, NO batch discount. Port `train_speed_mult/art_build_mult/build_mult` multipliers, batch-5/100, endless re-arm, 60 s/5 s/2 s cadences: NO donor counterpart on this path — PORT APPROXIMATION.

### 4.5 Construction progress (builders) `[O]`

- `_unit_ControlBuildProgress` (`unit.script:6574-6608`): `newprogress := hp/maxhp`, monotonic latch, `buildprogress` clamp 1, `stage := floor(progress*4)` → `visual_stage_0..3` + `essential_birth` tags; walls at `upglevel>0` snap `hp := maxhp` (`:6580-6581`).
- Per-hit economics live in `gc_buildtime_progressperhit = 10*0.03125*1.15` (`dmscript.global:182`) — the hit path itself (`building.inc/nothing.inc` repair section + `unit.inc` build order) is cited but NOT fully transcribed → `[U]`-Q3 with experiment §6. Do not retune `BUILD_PROGRESS_PER_HIT` until that read lands.

---

## 5. Port change list (`game.gd` / `data.gd` — owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, or network.

1. **`data.gd:674` `DONOR_PEACE_TIMES` — FIX (wrong values).** Replace `[0,10,20,30,40,50,60,90,120,180,240]` with the index→seconds table `[O]` §2.1: indices `0..9 → 0,10,20,30,45,60,90,120,180,240`, index `11 → 15`, index `10 reserved/unmapped`. Any menu/option surface must address entries by DONOR INDEX (`dmscript.global:1055-1066`), never by seconds guess. Cite `dmscript.global:1055-1066 + 4262-4277` on the constant.
2. **`data.gd:265-270` victory surface — keep, relabel.** `VICTORY/SCORE_LIMIT` stay ONLY as `PORT EXTENSION` (already gated by `PORT_EXTENSION_SCORE_VICTORY=false`; `game.gd:7088` correct). Add comment: `NO donor score threshold or time limit exists in readable scripts (EVID §1.3); scenario win writes exist only via trigger actions (scenario.script:2995-3062)`. Never default `VICTORY` to `"score"`; never gate 1:1 asserts on `SCORE_LIMIT`.
3. **`game.gd:7082-7083` peace gate — re-source, keep behaviour.** Keep the `time_s < PEACE_TIME → return` guard (harmless PORT policy) but source `PEACE_TIME` from the corrected index table (item 1) + `dogenerate.inc:2059-2064` init rule (`peacetime≠default ⇔ gbool_peacemode`). Cite `progress.inc/nothing.inc:658-695` expiry on the comment.
4. **`game.gd:7009-7032` team-win aggregation — label PORT POLICY.** `_team_alive/_winner_of_loser` continuation ("teammate survives ⇒ no defeat") has no donor counterpart in the Progress slice (§1.2/§1.4). Keep for playability, tag `PORT POLICY`, never cite as donor law. [SUPERSESSION-FIX: point-in-time/historical claim, not current — SUPERSEDED by `DEC_U_scenario_win.md` §5/§7 (team-win is donor-verbatim `CheckEndGame`, `miscext2.script:3769-3844`, global `nothing.inc:646`; source label at `game.gd:8828`); parity UNVERIFIED — NO PARITY CLAIM.]
5. **`game.gd:3640-3678` spawn placement — rewire to §3.** `START_PEASANTS=8` fallback (`data.gd:253`) stays ONLY where masks give no P legend (already the rule); elsewhere legend/mask spawn uses `dir=-90`, `unitradius` formula, double-add resources (already landed per `data.gd:1483-1493`). ADD the verbatim `+2` y-offset on the keep-clear ellipse (`dogenerate.inc:984`), the `-10000` sentinel + white-pixel + rescale rule for fixed maps (`generatemap.inc:304-502`), and the `RandomStartingPoints` version gate (`<61` legacy vs modern shuffle). No camera constant added (none exists — §3.3).
6. **`game.gd:6746-6794` `_tick_building` produce — rewire to §4.4.** Replace `job.t -= dt*tsm` countdown with donor accumulation: `progress += (dt / objbase.buildtime_seconds) × difficulty_mult` (AI-humanai only: `0.3/0.50/0.75/1/1.25`), clamp 1, `0.995` AI-capturer pin. Source `build_time` per sid from the ALREADY-GROUNDED per-sid frame literals (× §4.1 factor: units plain `FramesToTime`, buildings ×10). Delete `train_speed_mult/art_build_mult/build_mult` from the sim path (or move to an explicitly-tagged cheat/test multiplier, never default-on). Finite `count` lives in the order's `amount`, batch-5/100 entry stays HUD-only until a donor batch literal is cited.
7. **`data.gd:260` `BUILD_QUEUE_LIMIT=10` — correct to 12 or relabel.** Donor slot cap is `gc_obj_MaxOrderCount = 12` (`dmscript.global:113`). Either raise to 12 with cite, or keep 10 tagged `PORT APPROXIMATION (donor 12)`. Same for `MAX_BUILDERS_SENT=8`: donor rule is §4.2 mine/farm/btime tiers — tag accordingly.
8. **Upgrades/research (`game.gd:6796-6807`) — timing stays `[U]`-Q2.** `performupgrade` path not transcribed this ticket; keep current `r.t` countdown tagged PORT APPROXIMATION until `_misc_UnitProgressOrderPerformUpgrade` is read (experiment §6-Q2).
9. **Telemetry/format.** Every added line carries `file:line` + `[O]/[U]` tag; `visual_parity_claim=false`; unresolved list after this ticket = [V-score-absent (closed as absent, not pending), Q2-upgrade-timing, Q3-build-hit-path, CAM-initial-focus, T1-tail/D1/G1-tail/A1-tail/R1/O1-tail per SKIRMISH-TABLES §9]. [SUPERSESSION-FIX: "CAM-initial-focus" is a point-in-time/historical unresolved tag, not current — path-scope SUPERSEDED by `DEC_U_start_deep.md` §3 (wire found at `doprogress.inc:41`; impl tasks 221/227); camera numerics still [U]; parity UNVERIFIED — NO PARITY CLAIM.]

---

## 6. Still-[U] register — each with a fixed-seed scenario capture + zero-mismatch criterion (no threshold/timing invented)

| # | Item | Static state after this ticket | Exact experiment (owner-authorised; binary run by owner, never this worker) |
|---|---|---|---|
| V-score | Score/time-limit victory literals | CLOSED-as-ABSENT `[O-absence]` §1.3: no key, no threshold, no timer in readable scripts; scenario win is trigger-gated | Confirm by menu-cfg grep (`victory\|score_limit\|timelimit` over `data/game/var/*.cfg` + `donewgame.inc`): 0 skirmish-auto hits expected. **Zero-mismatch:** any hit must be quoted verbatim with `file:line` or the ABSENT verdict stands. No capture needed beyond the grep log. |
| V-prec | Team-win / multi-loser precedence | Donor slice §1.4 has no team rule; port team-continuation is policy | Fixed seed S, 2v2, eliminate one member of team A: assert port declares NO team defeat while teammate `bexists` (current behaviour), tag PORT POLICY. **Zero-mismatch:** 3 identical-seed runs → identical `victorystate/gametime` stamps. [SUPERSESSION-FIX: point-in-time/historical claim, not current — SUPERSEDED by `DEC_U_scenario_win.md` §5/§7 (team-win is donor-verbatim `CheckEndGame`, `miscext2.script:3769-3844`, global `nothing.inc:646`; source label at `game.gd:8828`); parity UNVERIFIED — NO PARITY CLAIM.] |
| P-peace | Peace seconds wiring | Table §2.1 `[O]`; port list wrong | Set each peacetime index 1-9,11 on seed S; assert `gfloat_peacetime` seconds = table AND expiry at `gametime > peacetime` clears `gbool_peacemode` + destroys ptborders. **Zero-mismatch:** identical (seed,index) → identical expiry tick. |
| S-place | Random-start shuffle order | Formulas `[O]` §3.2; exact draw ORDER per site | Seed S, N=4 FFA: dump `arrStartPosBusy` + `gMap.players[].startx/y` across 3 runs. **Zero-mismatch:** all three identical. Then vary one draw site (team count) and assert ONLY downstream words diverge. |
| CAM | Initial camera/focus | NO literal `[U]` §3.3 | Seed S fixed map (2 white pixels at logged bitmap coords): record first-frame camera target + `startx/y`. **Zero-mismatch:** `startx/y` must equal rescale formula exactly; camera target must repeat across 3 identical runs or be declared PORT CHOICE. |
| Q1 | Train timing per building/unit category | Formula `[O]` §4.4; per-sid frame literals live in `unit.script` rows | For one barracks + one stable + one artillery depot on seed S: order 1 unit each with full resources, log `progress` each tick to completion. **Zero-mismatch:** `completion_tick - start_tick = ceil(buildtime_seconds/dt)` exactly; AI-difficulty ×0.3/0.5/0.75/1/1.25 verified on AI-owned buildings. No per-category constant asserted beyond the per-sid literal. |
| Q2 | Upgrade/research timing | NOT read (`performupgrade` delegate) `[U]` | Queue one blacksmith upgrade on seed S; log `progress` to completion. **Zero-mismatch:** 3 runs identical tick count; value cited only after `_misc_UnitProgressOrderPerformUpgrade` read lands. |
| Q3 | Builder per-hit progress | Factor `[O]` (`progressperhit`), hit path `[U]` | 1 peasant builds 1 house on seed S; log `hp/buildprogress/stage` per hit. **Zero-mismatch:** stage flips exactly at `floor(progress*4)` boundaries; hit cadence quoted after the repair/build-order read. |

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items (defeat transition, peace table, start placement, queue formula) rest on donor TEXT `[O]` with `file:line`; open items name exact next reads/captures in §6.
- No number invented: score has NO threshold (not 5000), time limit has NO value, camera has NO constant, queue has NO per-category constant beyond per-sid `buildtime` frames. Every port default that fills these gaps stays tagged `PORT EXTENSION` / `PORT APPROXIMATION` / `PORT POLICY`.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + negative-grep logs; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: `LanServerSendResults`, `WritePeaceTime/WriteFreeList` net effects, and all `_net_*` branches are cited only as exclusion boundaries.

*End of DEC-U-VICTORY-START.*
