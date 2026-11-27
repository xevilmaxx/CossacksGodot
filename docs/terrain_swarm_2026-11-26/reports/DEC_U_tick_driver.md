---
id: DEC-U-TICK-DRIVER
worker: DEC-U-TICK-DRIVER (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor texts read as text only (Get-Content/Select-String). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_tick_order.md recovered global Nothing order, per-player slice order and all cadences but left the native plInd driver open: GetPlayerCurrentPlHandle has only script read(s); iteration order, firing rate and stage interleave stay [U]. IMPL-TICK-ORDER (absolute-deadline progress gate in game.gd) is active — not edited."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment"
---

# DEC-U-TICK-DRIVER — native tick/scheduler driver: player iteration order, firing rate, stage interleave (2026-11-26)

## 0. Pass ledger (multiple passes; every pass pinned `t_87f0f3c130b0`; donor read-only)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `Get-FileHash cossacks.exe SHA256` = `87F0F3C130B0…AF4E16C` [O], `(Get-Item).Length` = `5768048` [O]. Matches `t_87f0f3c130b0` (craft.json donor target `C:\Games\Cossacks 3`, DEC-U-TICK-ORDER §0). Binary never executed/copied. |
| P2 | Driver-reference census (script side) | `Select-String GetPlayerCurrentPlHandle\|SetPlayerCurrent` over the 4 scheduler files → exactly **2** hits, both reads, zero definitions: EV-D1 (`progress.inc:37`), EV-D2 (`progressai.inc:4`). No `SetPlayerCurrent*` anywhere in the 4 files. Scope correction to TICK-ORDER §4.1b/P9 (whose `lib\*.script`+`dmscript.global` scope found 1 hit): the full scheduler scope has 2 reads, still 0 writers — driver is native. |
| P3 | Per-player Progress body | `Get-Content units\global.inc\progress.inc` full dump: EV-D1 §1 (all `[O]`). Verbatim slice order re-pinned; driver read + per-player stamp + `progresstick+=1` positions fixed. |
| P4 | ProgressAI body | `progressai.inc` full dump (20 lines): EV-D2 §1 (all `[O]`). Second driver read + itype-2 self-gate + `SwitchTo('Progress')` fixed. |
| P5 | Gate primitive | `squad.script:754-782` re-read via Get-Content: EV-D3 §2 (all `[O]`, identical to TICK-ORDER EV-T3). Absolute-deadline + exact-float veto re-pinned. |
| P6 | Player init phases | `player.script:125-145` re-read: EV-D4 §2 (all `[O]`). `progresstick:=id*2`, four `id*0.25+const` deadlines, `lastprogresstime:=0` fixed. |
| P7 | Cadence constants | `dmscript.global:1484-1487` + `175,180`: EV-D5 §2 (all `[O]`). `32`, `150*8*frames_to_time`, `0.01*200`, `0.03*10`, `0.03*16*5`, `0.03*2000` evaluated. |
| P8 | Global Nothing head/tail + counters | `progress.inc\nothing.inc` head (lines 1-120) + `Select-String progresstick\|lastprogresstime` + line count 762: EV-D6 §3 (all `[O]`). Pause gate, `mod 2` path alternation line 117, `mod 53` sync line 405, `progressTick` line 754, global `progresstick+=1` + `lastprogresstime:=gametime` lines 757-759 fixed. |
| P9 | Section-interval classes | `dmscript.global:97-102,1457-1474`: EV-D7 §3 (all `[O]`). `gc_MaxPlayerCount=12`, env/misc/progress/pool pseudo-indices, interval classes 13-135. |
| P10 | Income/consume/bank formulae | `player.script:240-321` re-read (income head verbatim): EV-D8 §2 (all `[O]`). `mult=100`, `speed=256/1.024`, `resincome*32`, `floor` carry fixed. |
| P11 | Seed-wheat gate | `progresseconomicai.inc:3896-3901` re-read: EV-D9 §2 (all `[O]`). `itype 3`, `TimeSeedWheat+plInd*3` fixed. |
| P12 | Port anchor read-only inspection | `game.gd` tick 5178-5238, slice 5468-5493, gate 5431-5445, init 418-426, capture/save/ai refs via grep: EV-D10 §5 (no edit). `ai.gd:81-140` ProgressAI dispatch: EV-D11 §5 (no edit). `data.gd:1564-1567` consts: EV-D12 §5 (no edit). |
| P13 | Setter-absence sweep | No `SetPlayerCurrent*`, no `CurrentPlHandle :=` write, no `for plInd` player-rotation loop in any of the 4 scheduler files [O — absence within swept scope]. Native side therefore owns every CurrentPlHandle advance. |

DSL note [D] (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. What the driver reads are — verbatim [O]

### EV-D1 — `data\scripts\units\global.inc\progress.inc:37-38,40-43,181-184`

```
[*] = ;var plhnd: Integer = GetPlayerCurrentPlHandle;          // :37 — SOLE native-driver read in this state
[*] = ;var plind: Integer = GetPlayerIndexByHandle(plhnd);     // :38
[*] = ;var lastprogresstime : Float = gPlayer[plind].lastprogresstime;   // :40
[*] = ;var deltatime : Float = GetGameTime-lastprogresstime;             // :41
[*] = ;if (lastprogresstime>0) and (deltatime>0) then …end;              // :43 pause gate
[*] = ;   gPlayer[plind].progresstick := gPlayer[plind].progresstick+1;  // :181 (inside gate)
[*] = ;gPlayer[plind].lastprogresstime := GetGameTime;                  // :184 (OUTSIDE gate, unconditional)
```

Downstream `:44-180` addresses **only** `gPlayer[plInd]` (that one player): attack-music timeout, exists gate (itype 0), income+consume UNGATED (`plind<gc_MaxPlayerCount-1`), non-AI `CalcSquadsMoveCount` gate (itype 1), squad hold-progress loop (ungated), non-AI `CheckSquadsDisband` (ungated), `bexists and (bAI or adviser)` → `ExecuteState('ProgressAI')` (`:177-178`).

### EV-D2 — `data\scripts\units\global.inc\progressai.inc:4-18` (full body, 20-line file)

```
[*] = ;var plHnd : Integer = GetPlayerCurrentPlHandle;                                   // :4 — second read
[*] = ;var plInd : Integer = GetPlayerIndexByHandle(plHnd);                              // :5
[*] = ;if (_player_CheckProgressLastTimeAndIncrease(gPlayer[plInd].lastprogressaitime, 2, gc_global_TimeProgressAI)) then  // :6
[*] = ;begin  ExecuteState('ProgressEconomicAI');  ExecuteState('ProgressWarAI');  end   // :7-10
[*] = ;else if (gbool_gui_recheckadviseradvice) and (plHnd=GetPlayerHandleInterfaceIO) then  // :12
[*] = ;begin  ExecuteState('ProgressEconomicAI');  gbool_gui_recheckadviseradvice := False;  end  // :14-15
[*] = ;SwitchTo('Progress');                                                             // :18 (always)
```

### EV-D3 — gate primitive `lib\squad.script:754-782` [O] (re-pinned identical to TICK-ORDER EV-T3)

Absolute-deadline, NOT countdown: on fire `lasttime := gametime+addtime` (R1 — no catch-up, late firing permanently phase-shifts). Exact-float cross-player collision veto per itype: skip (no write) if ANY player's same-itype `checktime - addtime == gametime` (R2). Only the caller's deadline is written (R3). Four itypes: 0 exists / 1 movecount / 2 AI / 3 seed-wheat.

### EV-D4 — init `lib\player.script:125-145` [O]

`lastprogresstime := 0; progresstick := id*2` (⇒ 0,2,…,22); `lastcheckexists := id*0.25+TimeCheckExists`; `lastcalcsquadsmovecounttime := id*0.25+TimeCalcSquadsMoveCount`; `lastprogressaitime := id*0.25+TimeProgressAI`; `lastseedwheattime := id*0.25+TimeSeedWheat`; search-enemy cursors 0. First firing is pause-gated (`lastprogresstime>0` required).

### EV-D5 — constants `dmscript.global:175,180,1484-1487` [O]

`gc_time_to_frames = 32`; `gc_squad_holdmode_time = 150*8*gc_frames_to_time` (= 37.5 s at 32 fps ⇒ hold loop `deltatime/37.5`); `TimeCheckExists = 0.01*200 = 2.0 s` ⇒ alive `8.0 s`, dead `24.0 s`; `TimeCalcSquadsMoveCount = 0.03*10 = 0.3 s`; `TimeProgressAI = 0.03*16*5 = 2.4 s`; `TimeSeedWheat = 0.03*2000 = 60.0 s`.

### EV-D6 — global Nothing `progress\progress.inc\nothing.inc` (762 lines) [O]

Pause gate `:71-75`; tail `:757-759` (`progresstick+=1`, `lastprogresstime:=gametime`, same pause condition). `mod 2` water/land path alternation `:117`; `mod 53` sync `:405`; `_ai_CheckProcessEnemyInfo(gProgress.progressTick)` `:754` — `progresstick` vs `progressTick` are DISTINCT fields, never merge.

### EV-D7 — player/count/section classes `dmscript.global:97-102,1457-1474` [O]

`gc_MaxPlayerCount = 12`; pseudo-indices env/misc/progress/pool = 12-15; mercenary = 11 (excluded from 5 s statistics buckets per TICK-ORDER §1-16). Section intervals: default 100, units 100, peasants 135, buildings 33, mines 25, wheat 110, oreplace 120, artillery 60, pfx 13-29.

### EV-D8 — income/consume `lib\player.script:240-321` [O]

Income: `mult=100; speed=256/1.024=250.0; resincome*=32; bank=rem/mult+income*dt; realbank=bank/speed; value=floor(realbank)`; carry `remains[i]=floor((realbank-value)*speed*mult)`. Consume: same shape with `speed=20000`. Shortfall drains to `not res` (current-value read [D]) + famine (food) / rebellion (gold iff consume>income) flags; clears `res[food]<=0 or consume<=0` / `res[gold]<2 or consume<=0`.

### EV-D9 — seed wheat `progresseconomicai.inc:3896-3901` [O]

`if bprocess and CheckProgressLastTimeAndIncrease(lastseedwheattime, 3, TimeSeedWheat+plInd*3)` → `_ai_DoSeedWheat` ⇒ `60.0+plInd*3` s ⇒ `60…93 s`.

---

## 2. Settled driver facts [O/D] (what this ticket closes vs TICK-ORDER)

- F1 [O]. The per-player Progress state consumes **exactly one** native-selected player per firing (`progress.inc:37-38`); every `gPlayer[plInd]` access in `:44-181` is that player. The ProgressAI state re-reads the same handle (`progressai.inc:4-5`).
- F2 [O]. No script text writes `CurrentPlHandle`: zero `SetPlayerCurrent*`, zero `CurrentPlHandle :=`, zero player-rotation loop in the swept scheduler scope (P13). Advance/rotation/firing-rate of `CurrentPlHandle` is engine-side.
- F3 [O]. Scope correction to TICK-ORDER §4.1b: the "exactly one reference" count was scoped to `lib\*.script`+`dmscript.global`. Across the scheduler states there are exactly **two** `GetPlayerCurrentPlHandle` reads (EV-D1, EV-D2), still zero writers. Native-driver attribution is unchanged, only the count scope is corrected.
- F4 [O]. Per-firing positions are fixed: `progresstick+=1` INSIDE the pause gate (`:181`), `lastprogresstime:=GetGameTime` OUTSIDE/after it (`:184`, unconditional). Global Nothing mirrors the same pattern (`:757-759`).
- F5 [O]. All four deadline inits and the `progresstick:=id*2` stagger are literal (EV-D4); all six cadence values are literal products (EV-D5). No script text selects which player fires when — only WHEN a selected player may pass each gate.
- F6 [D]. Consequence: any port loop over players (e.g. `game.gd:5470` index order) is a PORT SUBSTITUTE for an unobservable native rotation — it reproduces gate algebra per visited player but asserts nothing about visitation order/rate.

---

## 3. Still-[U] register — each with a fixed-seed hash/byte-dump capture and zero-mismatch criterion

General harness (all experiments): pin `t_87f0f3c130b0` donor texts; fixed `randkey0/1`; fixed map/startingsettings startid set; fixed `GetTimeSpeedFactor`; headless fixed-dt frame loop; canonical JSON state hash (players, entities, projectiles, RNG-stream counters, per-player deadlines `lastcheckexists/lastcalcsquadsmovecounttime/lastprogressaitime/lastseedwheattime/lastprogresstime/progresstick`, banks `resincomeremains/resconsumeremains`) logged per global tick AND per per-player firing. Zero-mismatch = byte-identical hash sequences across 3 seeds AND across process restarts; any single-tick divergence = FAIL, no tolerance, no statistics. Never invent/ship an order — losers are deleted, winner is documented with its losing permutations listed.

| # | Field | Static state after this ticket | Exact experiment (owner-authorised; no donor binary) |
|---|---|---|---|
| U-D1 | CurrentPlHandle rotation order | F1-F3: one player per firing, native advance | Rotation census: instrument port `tick()` to record `plind` per per-player firing for 3600 frames on 12 mixed human/AI players. Candidates: (i) 1-per-frame round-robin ascending, (ii) all-players-per-frame ascending, (iii) section-budget-driven (section-max). Criterion: only the candidate reproducing R1-anchor + R2-veto deadline-hit sequences for 3 seeds with 0 mismatches survives. Until then `game.gd:5470-5475` keeps its `[U]-O1a` label. |
| U-D2 | Per-player firing rate | Gated blocks known; rate native | Rate census: same harness under idle + battle load; count firings/player/100 frames; log `lastprogresstime`/`progresstick` per firing. Criterion: only the rate law reproducing `lastcheckexists` deadline hits (`0.125*pi` + 8.0/24.0) with 0 mismatches across seeds survives. Current every-frame visitation is PORT SUBSTITUTE, not donor law. |
| U-D3 | Global-vs-player-vs-unit-vs-projectile interleave | TICK-ORDER §1 global order [O] internally; §1-per-player slice order [O] internally; mutual order native | Boundary-permutation harness: freeze each internally-[O] block (economy / scenario / paths / sections / player-slice / projectiles / cleanup / market / victory / AI), permute ONLY block boundaries. 3 seeds × full skirmish (peasants + army + capture + market). Criterion: 0 hash mismatches required; surviving permutation documented with losers listed. `TICK_ORDER v1` stays labelled PORT APPROXIMATION until then. |
| U-D4 | Mod-cohort alignment (path mod 2, sync mod 53, reach 3, rally 31, smoke 7) | Counter inits/phases [O] (TICK-ORDER R6) | Cohort log: `progresstick mod {2,53,3,31,7}` firings per entity for 3600 frames. Criterion: per-entity phase = init +1/frame reproduced with 0 mismatches; any cross-player alignment beyond the shared global counter declared absent. |
| U-D5 | Bank quantisation edge | Formula [O] (EV-D8); float bit-behaviour open | Fixed-dt sweep: income/consume rates across sub-unit banks for 3600 s sim; assert `floor` carry sequence byte-identical for 3 seeds, 0 mismatches. `floor` on negatives never reached (bank ≥ 0 by construction). |
| U-D6 | Capture jitter anchor | Fire-time+jitter rule [O] (TICK-ORDER R5) | 200 capturers, 600 s: log `lasttimecheckcapture` deadlines; assert fire-time anchoring (NOT deadline-relative) with 0 mismatches; art 0.475 s vs base 1.875 s cohorts separated. |
| U-D7 | `not res` read | Current-value read [D] | Shortfall tick asserts drain-to-current-value (not boolean) with 0 mismatches; famine/rebellion set/clear thresholds asserted per tick. |
| U-D8 | Veto reachability | Veto expression [O]; trigger rarity open | Phase-crafting: `id*0.25` inits vs `0.125*plInd` slots to force `checktime-addtime==gametime`; assert skip (no deadline write, no block execution) with 0 mismatches. Proves veto is live, not dead code. |
| U-D9 | AI sub-state split (Econ vs War) | Gate expressions [O] (EV-D2); body order inside each AI state [U]-A1 | 1 AI vs 1 idle human, 600 s: log Econ/War entry per `lastprogressaitime` firing; assert 2.4 s gate + adviser-only branch with 0 mismatches; body internals stay [U]-A1. |

U-D7/U-D8 permanence note: if the engine rotation (U-D1) is unobservable from script, U-D1 stays PERMANENTLY NATIVE with the labelled port order kept — no Ghidra/binary edit by any DEC worker either way (same limit as TICK-ORDER U-O7).

---

## 4. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents iteration order, rate, or interleave. None touches save version number, existing keys, or I11 seam paths. IMPL-TICK-ORDER (`game.gd:5436-5445` gate + `5468-5493` slice + `ai.gd:94` AI dispatch) is ACTIVE — do not edit its semantics; items below are additive completions/pointers only.

1. **`game.gd:5468-5475` — keep `[U]-O1a/O1b` label; correct the comment's driver count.** Comment says "native plInd driver … UNVERIFIED" — append: "driver reads are `progress.inc:37` + `progressai.inc:4` (2 reads, 0 writers per DEC_U_tick_driver.md §1 F3; TICK-ORDER §4.1b 1-hit count was `lib`+`dmscript.global` scope)." Keep `for pi in players.size()` index order frozen as PORT SUBSTITUTE. Do not rotate/reorder. No parity claim.
2. **`game.gd:5178-5238` `tick()` — TICK_ORDER v1 stays frozen; add pointer.** Append to the `5127-5177` comment block: "Driver interleaving: see DEC_U_tick_driver.md §3 U-D3 boundary-permutation harness (3 seeds, 0 mismatches). Do not move `_tick_players_slice` vs entities/projectiles/market/victory until U-D3 settles a winner." No reorder, no new stage.
3. **`game.gd:5436-5445` gate — already IMPL-TICK-ORDER ACTIVE; verify-only.** Confirm `time_s <= deadline → false` (strict `gametime>lasttime`), veto loop `players[i][key] - addtime == time_s → false`, write `time_s + addtime`, return true. No change. Veto-reachability harness is §3 U-D8.
4. **`game.gd:418-426` init — already `progresstick:=id*2` + `lastcheckexists` absolute [O]; ADD the three missing absolute deadline keys.** Add `"lastcalcsquadsmovecounttime": id*0.25+0.3`, `"lastprogressaitime": id*0.25+2.4`, `"lastseedwheattime": id*0.25+60.0` with `player.script:138-141` cites. Never initialise to 0.0 (0.0 would fire immediately, donor staggers first firing). Save keys already listed at `7778-7779` — wire them to these inits.
5. **`ai.gd:81-95` dispatch — already gated itype 2 [O]; add `bexists` precondition comment.** Donor `progress.inc:177` requires `gPlayer[plind].bexists` before `ExecuteState('ProgressAI')`: add `# bexists precondition per progr:177 [O]; AI brains only exist for live slots here` without changing behaviour. Adviser-only else branch (`progressai.inc:11-16`) stays inert with its existing label. `SwitchTo('Progress')` implicit-return label already present — keep.
6. **`ai.gd:274-283` `_seed_wheat` — already itype 3 [O]; verify `add` expression.** Must read `TimeSeedWheat + plInd*3` (= `60.0+pi*3`, `progresseconomicai.inc:3896-3901`), NOT `60.0+pi*0.25`. Init `id*0.25+60.0` comes from item 4. Harness §3 U-D9.
7. **`data.gd:1564-1567` — extend the donor tick const block.** Present: `EXISTS_SLOT 0.125`, `EXISTS_ALIVE 8.0`, `EXISTS_DEAD 24.0`, `MOVECOUNT_SLOT 0.001`. ADD: `DONOR_TICK_CALCSQUADS_S := 0.3`, `DONOR_TICK_AI_S := 2.4`, `DONOR_TICK_SEED_S := 60.0`, `DONOR_TICK_SEED_SLOT_S := 3.0`, `DONOR_TICK_INIT_PHASE_S := 0.25`, each cited `dmscript.global:1484-1487` / `player.script:138-141`, with note "all four share `squad.script:754-782`". `game.gd:5486` `_TICK_CALCSQUADS_S` and `ai.gd` `_TICK_AI_S` should reference these (single source) when COORD touches those lines.
8. **`game.gd:5495+` upkeep — verify folded constants equal donor products bit-for-bit.** Donor income `speed=256/1.024` (=250.0, keep expression), `*32` (`gc_time_to_frames`), `mult=100`; consume `speed=20000`. If the port folds `eat[k]*UPKEEP_SPEED*dt` with `UPKEEP_SPEED=20000.0` for BOTH income and consume, that is WRONG for income (250.0) — unfold to the donor shape or prove the fold is bit-identical. Keep `floor` carry + famine/rebellion thresholds verbatim (EV-D8). Harness §3 U-D5.
9. **`game.gd:7209+` save — ADD deadline/bank keys only.** `lastcalcsquadsmovecounttime, lastprogressaitime, lastseedwheattime` (Float, inits §1 EV-D4) and `resincomeremains/resconsumeremains` (Int arrays) if absent; never rename/remove existing v5 keys; never bump version. Deadlines are Float game-time, comparable with `==` for the veto — serialise full precision.

---

## 5. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (two driver reads, zero writers, slice/stage internal orders, all cadences + inits, gate primitive, bank formulae, capture anchoring, projectile event-driven-ness) rest on donor TEXT [O] with file:line; open items list harnesses in §3.
- The ONLY iteration fact asserted: each Progress/ProgressAI firing addresses the ONE `GetPlayerCurrentPlHandle` player (§1 F1). Any frame-level round-robin, rate, or stage interleave is [U]-D1/D2/D3 — never default to plInd-ascending all-players-per-frame as donor law (that is the current port behaviour at `game.gd:5470` and it is UNVERIFIED).
- Read-only compliance: exactly one repo file written (this report). No code/asset/config/Godot/git edit. Temp state: none (all reads via Get-Content/Select-String, no dump files left behind). Shared investigation memory never written.
- Limits disclosed: no binary-side scheduler trace (PE imports/sections/xrefs, Ghidra) was run by this worker; U-D1/U-D3 name that as a possible future pass, not performed here.

*End of DEC-U-TICK-DRIVER.*
