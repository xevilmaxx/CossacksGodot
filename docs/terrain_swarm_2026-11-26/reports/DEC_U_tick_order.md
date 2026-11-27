---
id: DEC-U-TICK-ORDER
worker: DEC-U-TICK-ORDER (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only (Get-Content/findstr). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_skirmish_tables.md recovered per-player exists stagger 0.125*plInd + 8/24 s, lose-stamp rule and slice order, but left O1-tail global interleave [U] (engine player-vs-unit iteration order / TICK_ORDER v1 port label). IMPL-SKIRMISH-ROWS added stagger gates behind a labelled port order."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-TICK-ORDER — global tick order: player vs unit/entity vs AI, plInd iteration, cadence remainders (2026-11-26)

## 0. Pass ledger (multiple passes; every native/script pass pinned `t_87f0f3c130b0`; donor read-only)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = craft.json donor target `C:\Games\Cossacks 3`, 5,768,048 B, sha256 `87f0f3c1…` (matches DEC-U-SKIRMISH §0). No binary executed. Binary strings/xrefs NOT re-run; scheduler recovered from script side only (stated as limit, §5-U7). |
| P2 | Global tick body | `progress.inc\nothing.inc` full stripped dump (755 code lines) — EV-T1 §1 (all `[O]`). |
| P3 | Per-player Progress body | `units\global.inc\progress.inc` full stripped dump (180 code lines) — EV-T2 §2 (all `[O]`). |
| P4 | Gate primitive | `squad.script:754-782` `_player_CheckProgressLastTimeAndIncrease` verbatim — EV-T3 §3 (all `[O]`). Single definition in `lib\*.script`. |
| P5 | Player init + resource remainders | `player.script:100-145` init; `:240-321` income/consume bank formulae; `:2591-2606` CalcSquadsMoveCount — EV-T4 §3–§4 (all `[O]`). |
| P6 | Constants | `dmscript.global:175,811,1457-1500` all cadence values evaluated — EV-T5 §2–§4 (all `[O]`). |
| P7 | Unit/building/projectile cadence | `unit.inc\nothing.inc` head + capture block; `building.inc\nothing.inc` head + capture blocks; `projectile.inc\nothing.inc` full scan; `unit.inc\initial.inc:320-325`, `building.inc\initial.inc:390`, `unit.script:2706-2726`, `serial.script:841-875`, `miscext2.script:1861-1912` — EV-T6 §3–§4 (all `[O]`). |
| P8 | AI gates | `units\global.inc\progressai.inc` full body (18 lines); `progresseconomicai.inc:3832,3896-3901` seed-wheat gate — EV-T7 §2 (all `[O]`). |
| P9 | Driver hunt (native vs script) | `findstr /S /I` over `lib\*.script` + `dmscript.global`: `CurrentPlHandle` = 0 hits; `GetPlayerCurrentPlHandle` = exactly 1 hit (`progress.inc:37`) — EV-T8 §4 (all `[O]`). |
| P10 | Port anchor read-only inspection | `variant3d/scripts/game.gd` tick 5135-5195, slice 5385-5455, capture 6851-6872/6947-7007, save 7209-7654; `ai.gd:1241-1256,1285-1291`; `data.gd:1558-1562` — EV-T9 §6 (no edit). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. Global tick (`progress.inc\nothing.inc`) — verbatim stage order [O]

File: `C:\Games\Cossacks 3\data\scripts\progress\progress.inc\nothing.inc`. Engine fires this Nothing-state body once per global frame for the progress pseudo-object. Guard and tail `[O]`:

- Head: `lastprogresstime := gProgress.lastprogresstime; gametime := GetGameTime; deltatime := gametime-lastprogresstime; if (lastprogresstime>0) and (deltatime>0) then begin … end` (pause gate: first frame and paused frames skip the whole body).
- Tail: `if (lastprogresstime>0) and (deltatime>0) then gProgress.progresstick := gProgress.progresstick+1; gProgress.lastprogresstime := gametime`.

Inside the guarded body, verbatim order (stripped-code sequence, EV-T1):

1. Perf: `perffps := GetProgressPlayersPerformance; perffps := MinFloat(perffps, 1/FramesPerSecond)`; `realfps := 1/perffps`; `cycletime := perffps*(GetTimeSpeedFactor/10)`; ring-buffer `garrfloat_perf_progress`.
2. `_res_ProcessEconomy(deltatime)` — market exponential recovery ONLY (`res.script:270-307 [O]`): `_res_CalcDeltaResources` + per-resource buy/sell cost relaxation `dt := deltatime*0.025*MaxFloat(1, garr_res_dlt[i]*0.01)` toward def, clamped to min/max. NO per-player income here (income lives in per-player Progress, §2).
3. Scenario AI-region rect: `if gScenario.bexists then for i:=0 to gc_scenario_maxzones-1` active+linked zones → `_scenario_SetAIRegionRectToUnitsList` (uses units list, addradius, buseaverage).
4. `_player_ProgressWriteNewRequestList` if queue non-empty and offline-or-server.
5. `ExecuteState('Scenario')` if scenario active and (offline or LAN-ready in game/spectator after loading).
6. `_movie_ProcessMovie` if `gMovie.bstarted`.
7. `_misc_ProjSimulatePointsProgress` if `gProjSimulatePoints.maxdamagetime>0`.
8. Path batch: water list preferred iff non-empty AND (`gGOPathList` empty OR `gProgress.progresstick mod 2=0`); topology solve (`TopologyGetPath` land / `TopologyGetPathExt` water); per-unit exit-point/track fix-up, hide-request clear, `bpathrequested := False`, current-order `bremove := True`; ships forced toward water on no-path; `DoSetupMoveAnimation` + track indexes; `TIntegerList(pList).Clear`.
9. `misc`/`@pool` section-max maintenance: `gProgress.lastmiscplsecmaxtime := gametime+4.0 s` (`200*0.02`); `@pool` `+1.4 s` (`70*0.02`); secmax `100/250` base + `count div {20,15,10}` tiers, applied only if `Abs(secmax-curmax)>20`.
10. SearchEnemy adaptive scheduler: counter `+0.1 s` (`5*0.02`); mid `+1.0 s` (`50*0.02`); per-player `searchenemyprev/last/cur` rotation when `gametime-lasttime > cProgressCheckTime(1 s)`; weight `delta/weight-divisor` (AI ×0.75 floor); war-factor `Clamp(weight/20,0,1)` → maxtime `Lerp(0.6 s peace, 0.2 s war)` → cycles → per-player `SetPlayerProgressSectionMaxByHandle` with +20/-30 asymmetric slew; time-speed-factor adaptation (±0.2 steps, newspeed clamp `[5, gamespeed_2]`, render/progress-fps comparison, `progresstick mod`-free, server sends `SetTimeSpeedFactor` + LAN parser sync). Client/replay branch applies `arrProgress` directly.
11. `_misc_SyncUnitsParams` iff `(gProgress.progresstick mod 53)=0` and sync-params queue non-empty and (online-server or record).
12. `_misc_CheckEndGame`.
13. Topology dirty-area flush (`gInt_UpdateAreasCount` downto 0).
14. Peacetime expiry (wall-clock `GetCurrentTime`, NOT game time): `gbool_peacemode and gametime > gfloat_peacetime and not replay and not client` → clear border objects via player-0 `WriteFreeList` + `WritePeaceTime`, destroy, minimap refresh.
15. Wall-clock LAN writes: `WriteRes` every 0.1 s, `WriteStats` every 20 s, `WriteLanSyncData` every 0.1 s (`GetCurrentTime`-based).
16. Statistics: `gProgress.lastprogressstatisticstime := gametime+0.2 s` (`10*0.02`); per player `0..MaxPlayerCount-2` (excludes mercenary), 5 s bucket append `farmused/scores` with catch-up `enum` loop.
17. `_ai_CheckProcessEnemyInfo(gProgress.progressTick)` + top-zones (`+2.0 s` = `100*0.02`) + `_misc_UpdateTopZonesInfo`, gated by `_misc_IsProcessAI` (offline or server).

Note the two tick counters `[O]`: `gProgress.progresstick` (global frame counter, drives `mod 2` path alternation and `mod 53` sync) vs `gProgress.progressTick` (passed to `_ai_CheckProcessEnemyInfo`). Distinct fields; do not merge.

---

## 2. Per-player Progress (`units\global.inc\progress.inc`) — verbatim slice order [O]

File: `C:\Games\Cossacks 3\data\scripts\units\global.inc\progress.inc`. Fires for the CURRENT player handle only (EV-T2):

- `plhnd := GetPlayerCurrentPlHandle; plind := GetPlayerIndexByHandle(plhnd)` (`:37-38`).
- `lastprogresstime := gPlayer[plind].lastprogresstime; deltatime := GetGameTime-lastprogresstime; if (lastprogresstime>0) and (deltatime>0) then begin … end; gPlayer[plind].lastprogresstime := GetGameTime` — unconditional stamp at end (outside the gate), per-CURRENT-player only.
- Client/replay: global does not progress (empty branch).
- Inner order: attack-music timeout → exists block (gated) → `if plind < MaxPlayerCount-1 (11)` income+consume (UNGATED every firing) → non-AI `CalcSquadsMoveCount` (gated) → squad hold-progress loop (ungated, per-squad bonus precondition) → non-AI `CheckSquadsDisband` (ungated) → `bexists and (bAI or adviser)` `ExecuteState('ProgressAI')` → `progresstick += 1`.

### 2.1 Exists gate and stagger [O] (`:56-61`, constants EV-T5)

`addtime := 0.125*plInd + (bexists ? 4*TimeCheckExists : 12*TimeCheckExists)`; `TimeCheckExists = 0.01*200 = 2.0 s` → alive `8.0 s`, dead `24.0 s`; slot term `0.125*plInd` → plInd 0..11 ⇒ `0 … 1.375 s`. Gate: `_player_CheckProgressLastTimeAndIncrease(gPlayer[plInd].lastcheckexists, 0, addtime)` (EV-T3, §3). Exists rule + lose stamp per TABLES §7 (re-pinned, not re-transcribed): battle-mode exempt; `farmused` scan (peasant visual_none+essential_none, else built center); lose path kills units, first transition stamps `victorystate=lose + victorystategametime=GetGameTime + LanServerSendResults`.

### 2.2 Income / consume — UNGATED, with fractional bank remainders [O] (EV-T4, `player.script:240-321`)

- Income per resource (`resincome>0`): `mult=100; speed=256/1.024=250.0`; `resincomerem := remains[i]/100`; `resincome := resincome*32` (`gc_time_to_frames`); `bank := rem+income*dt`; `realbank := bank/250`; `value := floor(realbank)` → add + `stat.restotal += value`; carry `remains[i] := floor((realbank-value)*250*100)`.
- Consume per resource (`resconsume>0`): `mult=100; speed=20000`; same shape with `*32`; on `value<>0`: affordable → subtract + clear famine/rebellion flags; shortfall → drain to `not res` (current value), set `bfamine := True` (food) / `brebellion := True` iff `consume>income` (gold). Tail: rebellion cleared iff `res[gold]<2 or consume<=0`; famine cleared iff `res[food]<=0 or consume<=0`. Carry `remains[i] := floor((realbank-value)*20000*100)`.
- `[D]`: remainders are FLOORED integer carries (`floor(bank*mult)`), not floats — sub-unit fractions below `1/(speed*mult)` are lost each firing.

### 2.3 Other per-player gates [O]

- `CalcSquadsMoveCount` (non-AI only): `addtime = 0.001*plInd + TimeCalcSquadsMoveCount(0.03*10=0.3 s)` → `0.300…0.311 s`; itype 1; body zeroes+recounts walk-tagged members (`player.script:2591-2606`).
- Hold loop (all players, ungated): stand-ground + not-hold + not-aggressive + moveCount 0 + hold bonuses differ → `fHoldModeProgress += deltatime/37.5` (`150*8*0.03125`); `>=1` → hold.
- `CheckSquadsDisband` (non-AI only, ungated): `count < basecount*0.25` → `_misc_DisbandSquad` (selection-preserving for interface-IO).
- `ProgressAI`: `bexists and (bAI or adviser-available+enabled)` → `ExecuteState('ProgressAI')`. The ProgressAI state itself re-gates: `if CheckProgressLastTimeAndIncrease(lastprogressaitime, 2, TimeProgressAI=0.03*16*5=2.4 s)` → Econ+War AI; elsif adviser-recheck on interface-IO → Econ only; always `SwitchTo('Progress')` (`progressai.inc:6-18`). Seed wheat (Econ): `if bprocess and Check(lastseedwheattime, 3, 60.0+plInd*3)` → `_ai_DoSeedWheat` (`progresseconomicai.inc:3896-3901`; `TimeSeedWheat=0.03*2000=60.0 s`, stagger `plInd*3` ⇒ `60…93 s`).

### 2.4 Per-player init (absolute-deadline phases) [O] (`player.script:131-141`, EV-T4)

`lastprogresstime := 0; progresstick := id*2` (⇒ 0,2,…,22 across 12 players); `searchenemy{prev,last,cur} := 0; searchenemylasttime := 0`; `lastcheckexists := id*0.25+2.0`; `lastcalcsquadsmovecounttime := id*0.25+0.3`; `lastprogressaitime := id*0.25+2.4`; `lastseedwheattime := id*0.25+60.0`. `serial.script:2214` re-applies `lastseedwheattime := plInd*0.25+60.0` on the same path family. First firing is pause-gated (`lastprogresstime>0` required), so phase offsets begin at first unpaused frame.

---

## 3. Cadence-remainder semantics — the load-bearing primitive [O] (EV-T3)

`squad.script:754-782`:

```
function _player_CheckProgressLastTimeAndIncrease(var lasttime : Float; itype : Integer; addtime : Float) : Boolean;
begin
   Result := False;
   var gametime : Float = GetGameTime;
   if (gametime>lasttime) then
   begin
      var bskip : Boolean;            // defaults False; set True on collision
      var i : Integer;
      for i:=0 to gc_MaxPlayerCount-1 do
      begin
         var checktime : Float;
         case itype of
            0 : checktime := gPlayer[i].lastcheckexists;
            1 : checktime := gPlayer[i].lastcalcsquadsmovecounttime;
            2 : checktime := gPlayer[i].lastprogressaitime;
            3 : checktime := gPlayer[i].lastseedwheattime;
         end;
         if (checktime-addtime=gametime) then begin bskip := true; break; end;
      end;
      if (not bskip) then begin Result := True; lasttime := gametime+addtime; end;
   end;
end;
```

Settled semantics `[D]`:

- R1. Absolute-deadline, NOT countdown: on fire, `lasttime := gametime+addtime`. Overdue firings do NOT catch up (no `+=` loop, no while); the next deadline is anchored at the firing frame. Late by X ⇒ period becomes `addtime+X`, permanently phase-shifted.
- R2. Exact-float collision veto: if ANY player's same-itype deadline minus THIS call's addtime bit-equals current `gametime`, the firing is skipped (returns False, deadline unchanged). With per-player phases `id*0.25` vs slot terms `0.125*plInd` / `0.001*plInd` / `plInd*3`, collisions are rare but structurally possible; the veto serialises same-frame same-itype firings.
- R3. Per-player state: only the CURRENT player's `lasttime` is written; other players' deadlines are read-only in the loop. Remainder state = 4 absolute Float deadlines per player (no accumulator).
- R4. Resource banks (contrast): `floor(bank*mult)` integer carry — fractional remainder preserved up to quantisation, entirely different mechanism from R1 (no deadline; every firing adds `income*dt`).
- R5. Unit/building capture (contrast): `if gametime>lasttimecheckcapture then lasttimecheckcapture := gametimewithrnd+interval` where `gametimewithrnd := gametime+uniqrnd` (`unit.inc\nothing.inc:13-14,510-515`; `building.inc\nothing.inc:293-315`). Jitter `uniqrnd := RandomExt` per entity (`unit.script:2726`); init `lasttimecheckcapture := random*1.875` (unit initial:320, building initial:390, serial:870); art interval `0.475 s` vs base `1.875 s`. The `{arg_obj.lasttimecheckcapture}` comment-brace in unit code shows the alternative (deadline-relative, drift-free) was considered and NOT taken — donor anchors at firing time plus static jitter, so capture phase drifts with frame timing `[D]`. No post-capture cooldown (TABLES C1 closed).
- R6. Per-entity tick counters: `obj.progresstick := floor(RandomExt*32)` at creation (`unit.script:2707`) with `lastprogresstime := 0`; each Nothing firing `progresstick += 1`. Mod gates: `cProgressTestReach=3` (unit reach test), `cProgressRallyPointTick=31`, `cProgressSmokeIncrease=7` (building), path `mod 2`, sync `mod 53` (global). Randomised init phases spread mod-gate cohorts `[D]`.
- R7. Global wall-clock timers (`ResetProgressPlayer`, `miscext2.script:1887-1907`): `lastmiscplsecmaxtime := random*4.0`, `lastpoolplsecmaxtime := random*1.4`, `lastsearchenemy{counter,mid} := random*{0.1,1.0}`, `lastprogressstatistictime := random*0.2`, `lastprogresstopzonestime := random*2.0` — `random` (not RandomExt) jitter, same absolute-deadline pattern (`gametime+interval`).

---

## 4. How plInd iterates + where unit/entity ticks interleave

### 4.1 What is statically settled [O]

- (a) Per-player Progress reads exactly one player per firing: `GetPlayerCurrentPlHandle` (`progress.inc:37-38`). All downstream `gPlayer[plInd]` accesses in that body are that single player.
- (b) The driver is NATIVE: `GetPlayerCurrentPlHandle`/`SetPlayerCurrent*` has ZERO script definitions — `findstr /S /I "CurrentPlHandle"` over `lib\*.script` + `dmscript.global` = 0 hits; the sole reference in the entire script corpus is the read at `progress.inc:37` (EV-T8). No script text selects, rotates, or round-robins the current player. Who advances CurrentPlHandle per frame, and whether every Progress-state firing covers all 12 players or one, is therefore engine-side and NOT recoverable from text.
- (c) Per-object Nothing states (`unit.inc\nothing.inc`, `building.inc\nothing.inc`, `projectile.inc\nothing.inc`, group/env/decor) are likewise engine-scheduled. The engine exposes section slicing: `GetPlayerProgressSectionIndexByInterval(plHnd, interval)` with interval classes `units=100, peasants=135, buildings=33, mines=25, wheat=110, oreplace=120, artillery=60, pfx 13-29, default=100` (`dmscript.global:1457-1474`); per-player `SetPlayerProgressSectionMaxByHandle` budgets recomputed most frames (§1 item 10) from live section counts; objects are visited via `GetPlayerProgressSectionCountGOByIndex / GetGOHandleByIndex` (exists scan, capture protector scan, `miscext.script:1301-1405`, `control.script:118-124`). Section-max IS in save-relevant engine state but its exact per-frame visitation order (stride vs contiguous, section rotation vs player rotation) is native.
- (d) Projectile `nothing.inc` is collision-event, not cadence: no `progresstick/deltatime/mod/GetGameTime` gate (EV-T6: sole `GetRandomKey` hit is a log line). Projectile-vs-unit-vs-player ordering is engine collision-dispatch order — native.
- (e) `_misc_OnPlayerProgressSectionReached(plHnd, interval)` body is a no-op (reads plind/rinterval, does nothing) (`miscext2.script:1879-1885`) — section-reached callbacks do not re-order anything in script.

### 4.2 What remains [U]-O1 (never invent)

U-O1a. Engine CurrentPlHandle rotation: 1-per-frame round-robin vs all-players-per-frame vs section-budget-driven. U-O1b. Per-player Progress firing rate relative to global frames (every frame? only when its sections are scheduled?). U-O1c. Unit-Nothing vs per-player-Progress vs global-Nothing vs projectile-collision vs ProgressAI Econ/War sequencing within one frame. U-O1d. Whether `progresstick mod` cohorts (path mod 2, sync mod 53, rally 31, smoke 7, reach 3) align across players (they share only the global counter for path/sync; per-entity counters are independently phased).

---

## 5. Still-[U] register — each with a fixed-seed hash experiment and zero-mismatch criterion

General harness (all experiments): pin `t_87f0f3c130b0` donor texts; fixed `randkey0/1`; map from `startingsettings` startid set; fixed `GetTimeSpeedFactor`; headless fixed-dt frame loop; canonical JSON state hash (players, entities, projectiles, RNG-stream counters, deadlines, banks) logged per global tick AND per per-player firing. Zero-mismatch = byte-identical hash sequences across 3 seeds AND across process restarts; any single-tick divergence = FAIL, no tolerance, no statistical pass.

| # | Field | Static state after this ticket | Exact experiment (owner-authorised; no donor binary) |
|---|---|---|---|
| U-O1a | CurrentPlHandle rotation | §4.1(a–b): one player per firing, native driver | Harness: instrument port `tick()` to record `plind` sequence per firing for 3600 frames, 12 mixed human/AI players. Vary: (i) 1-per-frame RR, (ii) all-players-per-frame in plInd order, (iii) budget-driven (section-max). Criterion: candidate whose per-player `progresstick`/`lastprogresstime` sequences match the R1–R3 deadline algebra (R1 anchor + R2 veto) for 3 seeds with 0 mismatches; losers deleted. Never ship two orders. |
| U-O1b | Per-player firing rate | Gated blocks known; rate unknown | Same harness: count firings/player/100 frames under idle + battle load. Criterion: only the rate law reproducing `lastcheckexists` deadline hits (8.0/24.0 + slot) with 0 mismatches across seeds survives. |
| U-O1c | Global-vs-player-vs-unit-vs-projectile stage order | §1 order + §2 slice order both [O] internally; mutual interleave native | Order-permutation harness: freeze each internally-[O] block, permute ONLY block boundaries (economy / scenario / paths / sections / player-slice / projectiles / cleanup / market / victory / AI). 3 seeds × full skirmish (peasants + army + capture + market). Criterion: 0 hash mismatches required; the surviving permutation is documented with its losing permutations listed. Until then `TICK_ORDER v1` stays labelled PORT APPROXIMATION. |
| U-O1d | Mod-cohort alignment | Counter inits [O] (§3-R6) | Cohort test: log `progresstick mod {2,3,7,31,53}` firings per entity for 3600 frames. Criterion: per-entity phase = `floor(RandomExt*32)` init +1/frame reproduced with 0 mismatches; any cross-player alignment beyond shared global counter is declared absent. |
| U-O2 | Resource bank quantisation edge | Formula [O]; float bit-behaviour open | Fixed-dt test: income/consume rates sweeping sub-unit banks (1 food/min … 20000 gold ticks) for 3600 s sim; assert `floor` carry sequence byte-identical for 3 seeds, 0 mismatches; record Delphi `floor` on negatives (never reached in practice — bank ≥ 0 by construction). |
| U-O3 | Capture jitter drift | Anchor rule [O] (§3-R5); `uniqrnd` stream open | Jitter test: spawn 200 capturers, log `lasttimecheckcapture` deadlines for 600 s; assert fire-time+jitter anchoring (NOT deadline-relative) with 0 mismatches; art (0.475) vs base (1.875) cohorts separated. |
| U-O4 | Income/consume `not res` read | `not gPlayer[plInd].res[i]` current-value read [D] | DSL test: shortfall tick asserts drain-to-current-value (not boolean) with 0 mismatches; famine/rebellion clear thresholds (`>0` food / `>=2` gold / consume<=0) asserted per tick. |
| U-O5 | `CheckProgress…` float-equality veto | Veto expression [O]; trigger rarity open | Collision test: craft phases (`id*0.25` inits vs `0.125*plInd` slots) to force `checktime-addtime==gametime`; assert skip (no deadline write, no block execution) with 0 mismatches. Documents that the veto is reachable, not dead code. |
| U-O6 | AI sub-state split (Econ vs War) | Gate expressions [O] (§2.3); body order inside each AI state open | AI-tick test: 1 AI vs 1 idle human, log Econ/War entry per `lastprogressaitime` firing for 600 s; assert 2.4 s gate + adviser-only branch with 0 mismatches; body internals stay [U]-A1. |
| U-O7 | Native section visitation micro-order | Interval classes + section-max algebra [O] (§1-10, §4.1c); rotation native | Section test: fix section-max budgets (disable adaptation), record GO visitation order per section for 600 frames; assert stride/contiguity hypothesis with 0 mismatches. If engine order is unobservable from script, record [U]-O1 as PERMANENTLY NATIVE and keep the labelled port order. No Ghidra/binary edit by this worker either way. |

---

## 6. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents an iteration order. None touches save version number, existing keys, or I11 seam paths.

1. **`game.gd:5385-5403` `_tick_players_slice` — R1 deadline semantics (load-bearing)**. Current port uses a countdown accumulator (`lastcheckexists += dt; if >= stagger: reset 0; fire`). Donor (EV-T3) uses an absolute deadline (`if gametime>lasttime: … lasttime := gametime+addtime`) with an exact-float cross-player collision veto (itype 0). Change to: store absolute `lastcheckexists` deadline (game-time, init `id*0.25+2.0` per §2.4, NOT 0.0); fire iff `time_s > lastcheckexists`; on fire set `lastcheckexists = time_s + 0.125*pi + (8.0|24.0)`; skip (no write) if any player's `lastcheckexists - addtime == time_s`. Same rewrite for the two missing gates below. Keep per-player `progresstick += 1` + `lastprogresstime = time_s` per firing (already correct shape) but init `progresstick := id*2` (currently 0 — EV-T4).
2. **`game.gd:5135-5195` `tick()` — TICK_ORDER v1 stays labelled; do NOT reorder**. Insert the per-player slice at its donor-unknown position only after U-O1c settles a winner; until then keep `tick()` order frozen with the existing `TICK_ORDER v1 PORT APPROXIMATION` comment (`game.gd:5127-5134`) and add a pointer to this report §5-U-O1c. Never invent rotation (i)/(ii)/(iii) as the order.
3. **`game.gd:5385-5403` — add the two missing per-player gates** (currently ungated-or-absent): non-AI `CalcSquadsMoveCount` gate `0.001*pi+0.3` (itype 1, init `id*0.25+0.3`); ProgressAI entry gate `2.4 s` (itype 2, init `id*0.25+2.4`) in front of `ai.gd` dispatch, preserving the adviser-only else-branch (`progressai.inc:11-16`). Seed-wheat `60.0+pi*3` (itype 3, init `id*0.25+60.0`) belongs in `ai.gd` Econ (§6-5).
4. **`game.gd:5405-5455` upkeep — bank constants to donor literals**: income `speed=250.0` (=256/1.024, keep expression), consume `speed=20000`, `mult=100`, rate scale `*32` (`gc_time_to_frames`), carry `floor(bank*mult)` integer. Port currently folds rates via `UPKEEP_SPEED/Data.UPKEEP_MULT` — verify the folded product equals `resconsume*32*dt` bit-for-bit or unfold to the donor shape. Keep `not res` drain + famine/rebellion set/clear thresholds verbatim (§2.2).
5. **`ai.gd:1241-1256` + `game.gd` AI dispatch — wire the grounded AI gates only**: 2.4 s ProgressAI gate, adviser-only path, `SwitchTo('Progress')` return, 0.25 disband, 37.5 s hold, 120 guard cap, sampler thresholds, fear rule (TABLES §5). Everything else stays `PORT-AI` labelled; U-A7 (`ai.gd:1291`) experiment text updated to point at §5 U-O1c/U-O6 harness instead of the generic TABLES reference.
6. **`game.gd:6851-6872` + `6947-7007` capture — replace countdown with R5 deadline**: `lasttimecheckcapture` absolute game-time deadline, init `rand*1.875`, `gametimewithrnd := gametime+uniqrnd` anchoring, art `0.475 s`; delete `capture_t` accumulation (`capture_t` at 2986/6947-7007 is PORT EXTENSION with confirmed-absent donor counterpart — TABLES C1 closed). Keep `lasttimecheckcapture` mirror key; `cap_check_t` additive mirror may remain ONLY as a save-compat alias with the `[D]` absent-note already present.
7. **`game.gd:7209-7221` + `7272-7654` save — ADD deadline/bank keys only**: `lastcalcsquadsmovecounttime, lastprogressaitime, lastseedwheattime` (Float, inits §2.4), `resincomeremains/resconsumeremains` (Int arrays), per-entity `lasttimebestposition/lastsearchenemy` already listed at 7613 — verify presence; never rename/remove existing v5 keys; never bump version.
8. **`data.gd:1558-1562` — extend the stagger const block**: add `DONOR_TICK_SQUAD_SLOT_S := 0.001`, `DONOR_TICK_CALCSQUADS_S := 0.3`, `DONOR_TICK_AI_S := 2.4`, `DONOR_TICK_SEED_S := 60.0`, `DONOR_TICK_SEED_SLOT_S := 3.0`, `DONOR_TICK_INIT_PHASE_S := 0.25` with `player.script:131-141` cites; add comment that all four share the EV-T3 gate primitive (`squad.script:754-782`).

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (global stage order, per-player slice order, all six cadence values + four init phases, gate primitive, bank formulae, capture anchoring, projectile event-driven-ness, single-current-player read, native-driver attribution) rest on donor TEXT `[O]` with file:line; open items list exact harnesses in §5.
- The ONLY iteration order asserted is: per-player Progress body addresses one `GetPlayerCurrentPlHandle` player per firing (§4.1a). Any frame-level round-robin, rate, or stage interleave is `[U]`-O1 — never default to plInd-ascending all-players-per-frame (that is the current port behaviour at `game.gd:5387` and is UNVERIFIED as donor law).
- Read-only compliance: exactly one repo file written (this report). The temp dump used for reading long donor bodies was removed; no target opened/selected/closed by this worker; shared investigation memory never written.
- Limits disclosed: no binary-side scheduler trace (PE imports/sections/xrefs) was run by this worker; U-O7 names that as a possible future pass, not performed here.

*End of DEC-U-TICK-ORDER.*
