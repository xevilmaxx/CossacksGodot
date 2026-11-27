---
id: DEC-U-TICK-DEEP
worker: DEC-U-TICK-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor texts read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "Prior: DEC_U_tick_order.md recovered all stage/cadence literals and the absolute-deadline gate but left no native scheduler VA; DEC_U_tick_driver.md found GetPlayerCurrentPlHandle has 2 script reads + 0 writers, driver native; interleave still [U]. This worker attacks from NEW angles: raw CODE byte/xref search for script API names in packed code tables (blend-worker method), DScript dispatch inspection around any found VA, frame-callback/timer object hunt, plInd order only if byte-proven."
labels: "[O] observed donor bytes/lines verified by a second pass · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment"
---

# DEC-U-TICK-DEEP — native scheduler deep pass: CODE-embedded API table, dispatch, timer object, plInd order (2026-11-26)

## 0. Pass ledger (multiple NEW passes, all pinned `t_87f0f3c130b0`, donor read-only)

| # | Pass (read-only) | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `Get-FileHash` SHA256 `87F0F3C1…AF4E16C`, 5,768,048 B [O]. Binary never executed/copied. |
| P2 | `native_bytes_find GetPlayerCurrentPlHandle` | **1 hit**, VA `0x690692`, file-offset `0x28fa92`, CODE section, utf8 (ev_72fbfab4bb79741e8fa584fcef7fa14ad9935d807b716a9fc5aeda4b4b5c180c) [O] |
| P3 | `native_bytes_find CheckProgressLastTimeAndIncrease` + `progresstick` | **0 hits each** (ev_85db17f2 / ev_eb9f393492) [O-absence in stored bytes; packed-region reserve] |
| P4 | `native_bytes_find GetPlayerIndexByHandle / CurrentPlHandle` | 1 hit each: `0x68f4e2` / `0x69069b` (suffix of the P2 string), both CODE [O] |
| P5 | `native_bytes_find ExecuteState / GetGameTime / ProgressAI / SetPlayerProgressSectionMax / GetPlayerProgressSection / TimeCheckExists` | ExecuteState 37 hits (~`0x63c4c4…`); GetGameTime 1 hit `0x69faf6`; ProgressAI 0; SetMax 2 (`0x693a62`,`0x693aee`); GetSection 10 (`0x693a2a…`); TimeCheckExists 0 [O] |
| P6 | `native_bytes_find Progress / LastTime / SetPlayerCurrent / MaxPlayerCount / gPlayer / gProgress / ProgressTick` | `Progress` 234 hits (substring, mostly table text); `LastTime` 7; `SetPlayerCurrent*` 0; `MaxPlayerCount` 1 (`0x6f2377`, Steam-server context, unrelated — §4); `gPlayer/gProgress/ProgressTick/progresstick` 0 [O] |
| P7 | `native_bytes_show` table windows | `0x690692+900` (ev_b5da0d6e), `0x68f4e2+900`, `0x693a00+1200`, `0x69faf6+700`, `0x63c4c4+700`, `0x68d9b3+700`, `0x693f89…0x6a8894` thread cluster — all ASCII prototype runs [O] (§1, §3) |
| P8 | `native_strings_find` complement | `GetPlayerCurrentPlHandle` 0 hits in data-section index vs P2 1 hit in CODE bytes — same index-vs-CODE split as blend-worker P2/P5 [O] (method parity) |
| P9 | `native_sections_list` | CODE `0x401000-0x8f1da8` entropy 6.61 exec; DATA 44 kB; `.bind` `0x96c000-0x98fd70` entropy **7.96 exec** (packed); `.rsrc` 128 kB (ev_d5b51af0808dd609842ab36f411ca6cbd512d8de39acf648e641acfd28d3198239f) [O] |
| P10 | `native_function_find` + `native_xrefs_list` on table VAs | `0x690692` inside `sub_690048+0x64a` (ev_547a7ede); `0x68f4e2` in no discovered function (ev_b9b1ef21); xref `0x690692`: 1 `references_to` from `0x690624` kind jump (ev_ac684ffcc…); xref `0x693a62`: 0 (ev_d48f749d…), both under stated `computed pointers at run time are not seen` limit [O] |
| P11 | `native_function_disassemble sub_690048` | 8128-line listing decodes table ASCII as nonsense `insb/outsb/popad/imul` stream (ev_0e51e02d…) — **data-as-code garbage, discarded**, same class as blend-worker `sub_401000` [D] (§2) |
| P12 | Donor-text re-census (Select-String/Get-Content, read-only) | `GetPlayerCurrentPlHandle`: exactly 2 reads (`progress.inc:37`, `progressai.inc:4`), 0 writers; `_player_Process*`: 2 procedures (income `:242`, consume `:270` in `player.script`); global Nothing ascending `for i:=0 to gc_MaxPlayerCount-1` loops at `:424,:458,:586,:604,:636` + `:721` (`-2`, mercenary excluded); per-player Progress has NO plInd loop [O] (§4) |

Strange-read log: `native_strings_find` covers data sections only — zero-hit never means absent (P8 proves the symbol lives in CODE-embedded tables). `native_xrefs_list` 0/1 results carry the engine limit `references made through computed pointers at run time are not seen` — never evidence of dead code. `.bind` packed (entropy 7.96): `no match is not proof of absence`. No donor binary executed; no donor bytes copied into the repo.

---

## 1. (a) CODE-embedded script-API table — scheduler entries localized as TEXT [O]

All hits are ASCII prototype runs inside CODE, byte-identical in style to the blend-worker table (`0x62f300–0x630700`):

- **P2 anchor** (`0x690692`, ev_b5da0d6e): `GetPlayerCurrentPlHandle(): Integer` followed by `GetPlayersInitialArmyDist/Set…`, `GetPlayersDistKoef/Set…`, `GetPlayerGrHandle…`, `PlayerSaveCurrentArmiesRectanglesByHandle…`. The `CurrentPlHandle` match at `0x69069b` is the suffix of the same string, not a second entry [D].
- **Player-index cluster** (`0x68f4e2`): `GetPlayerIndexByHandle(plhandle: Integer): Integer` + `PlayerCalcGroups/Rectangles…ByHandle…`, `GetPlayerArmyDistance/RelativeQuarter…ByHandle…` [O].
- **Section/scheduler cluster** (`0x693a00–0x693c00`): `Get/SetPlayerProgressSectionMax`, `Get/Set…MaxByHandle`, `Get/Set…AutoClear(+Interval)`, `Get…Count`, `Get…IntervalByIndex`, `Get…CountGOByIndex`, `Get…IndexByInterval`, `GetOrAdd…ByInterval`, `Get…GOHandleByIndex` [O].
- **Thread/priority cluster** (`0x693f89–0x6940xx`, `0x6a8894`): see §3 [O].
- **Time/state cluster** (`0x69faf6–0x69fbce`): `…SetGameTime / GetRealTime / GetSeasonType…` then **`PlayerSwitchToByHandle(plhandle: Integer; const state: String)`** (sole hit, P5-A) then scenario + `SetProgressingPauseMode/GetProgressingPauseMode` [O].
- **GO-delay-ExecuteState cluster** (`0x63c4c4…`): `ExecuteStateByHandle`, `GetGameObjectDelayExecuteStateNameByHandle`, `…Delay/CancelDelay…ByHandle`, `SetGameObjectValueByHandle…` — GO-scoped delay states, NOT the player `ExecuteState('ProgressAI'/'Scenario')` dispatcher [O]. The 37 `ExecuteState` hits are this family; no `ProgressAI/ProgressEconomicAI/CheckProgress/lastcheckexists/TimeCheckExists/progresstick/gPlayer/gProgress` byte runs exist in stored bytes (P3/P5/P6) — the gate primitive and field names are script-side only (consistent with `squad.script` definition), with the packed-region reserve [D].

[D] consequence: `GetPlayerCurrentPlHandle` is a real native export whose name is stored exactly as the script spells it (re-spelling impossible — byte-identical). Its callers/dispatchers are NOT in the table (table holds names, not code), and no loop bound or rotation lives within ±1500 B of any scheduler entry (all neighbors are further prototypes, then binary code at `~0x694075+`, §2).

## 2. (b) DScript dispatch / player-slice loop around the found VA — NOT localized [U]

- `native_function_find 0x690692 → sub_690048+0x64a` is a mis-attribution: the 8128-line disassembly of `sub_690048` (ev_0e51e02d) decodes the prototype ASCII as `insb/outsb/popad/imul ebp,[esi+…],0x…` garbage across the whole `0x690048–0x6907xx` range. This is data-as-code, not a scheduler loop; discarded, not cited as code [D].
- The single xref `0x690624 →(jump) 0x690692` (ev_ac684ff) likewise decodes inside the ASCII run (`0x690624: jo 0x690692` where both endpoints are mid-string bytes) — a phantom edge from decoding text as code, not a table-walk loop [D].
- `native_function_find 0x68f4e2 → not inside any known function`; xref `0x693a62 → 0 refs` under the computed-pointer limit — localizes nothing [O].
- Interpreter-side strings `XDMScript@0x958d1a / frmDMScriptEvaluate@0x95977f` live in `.rsrc` (P8 complement) — form resources, not a dispatch table with loop bounds/index increment/stage order [O].
- **Verdict [U]-DSP: no DScript interpreter dispatch table with player-slice loop bounds, index increment, or stage call order was isolated.** The table regions give names only. Capture R-DSP (§5) is prescribed; no disassembly of the packed `.bind` region is prescribed.

## 3. (c) Frame-callback / timer / thread object with per-player iteration list — object found, list NOT found

[O] native prototype runs (P7):

```
0x693f89: …GetPlayerProgressSectionGOHandleByIndex…
  function GetProgressPlayersThread: Boolean
  procedure SetProgressPlayersThread(const v: Boolean)
  function GetProgressPlayersPriority: Integer
  procedure SetProgressPlayersPriority(const v: Integer)
  function GetProgressPlayersPerformance: Float      (== script `perffps` source, Nothing :~perf block)
  procedure SetProgressMaxDisabled(const v: Boolean) / function GetProgressMaxDisabled: Boolean
  …(table ends ~0x694075+, binary code follows)…
0x6a8894: …ProgressPlayersThread(const val: boolean)…
  function GetUseProgressPlayersThread: boolean
  procedure SetUseProgressControlThread(const val: boolean) / function GetUse…
  procedure SetUseMultithreadedMode(const val: boolean) / function GetUse…
  function GetPerfTotal/GetPerfRender/GetPerfProgress/GetPerfLanSend/GetPerfLanRecv(index: integer): Float
```

[D] consequences: (i) a native progress-players thread/priority/performance object EXISTS — this is the closest native counterpart to a frame-callback/timer control for the per-player pass; (ii) `GetProgressPlayersPerformance` is the native source of the global Nothing perf block (`perffps`, TICK-ORDER §1-1); (iii) NO per-player iteration list, loop bound, index order, or rate literal appears within the cluster — neighbors are `SetProgressMaxDisabled` then raw code, and `Perf*` accessors. Whether the thread object walks players ascending, reverse, or via section budgets is not in stored bytes.

**Verdict [U]-THR: object localized, iteration list not localized.** Capture R-THR (§5) decides observably; the port keeps a single-threaded ordered pass labelled PORT SUBSTITUTE.

## 4. (d) `plInd` order — index order for GLOBAL loops [O]; CurrentPlHandle rotation [U] (never invent)

Byte- and text-proven split:

- [O] Global-Nothing script loops ARE ascending index order, verbatim:
  - `:424` `for i:=0 to gc_MaxPlayerCount-1 do` (search-enemy init scan);
  - `:458` `for i:=0 to gc_MaxPlayerCount-1 do` (delta/weight pass);
  - `:586` + `:604` `for i:=0 to gc_MaxPlayerCount-1 do` (section-max adapt + client/replay `arrProgress[i]` apply via `GetPlayerHandleByIndex(i)`);
  - `:636` `for i:=0 to gc_MaxPlayerCount-1 do` (`arrProgress[i]>0` server send);
  - `:721` `for i:=0 to gc_MaxPlayerCount-2 do // -2, no need to count mercenary player` (statistics buckets).
  These order section-max/search-enemy/stat bookkeeping ascending — they do NOT select the CurrentPlHandle player.
- [O] Per-player Progress body addresses exactly ONE native-selected player per firing (`progress.inc:37-38`; re-read P12), re-confirmed; `progressai.inc:4-5` re-reads the same handle. Zero script writers (`SetPlayerCurrent*` 0 hits, P6) — advance/rotation/firing-rate is engine-side (DRIVER F2, unchanged).
- [O] Native index accessors exist as names (`GetPlayerHandleByIndex@0x68d892`, `GetPlayerNameByIndex/Set…`, `GetCountOfPlayers@0x68d6e6-cluster`, `ExchangePlayerIndex@0x68dbca`, `SetPlayerHandleInterfaceIO…`); the `0x6f2377 MaxPlayerCount` hit is Steam-server API text, not a scheduler bound [D — not a loop literal].
- **[U]-ORD: whether CurrentPlHandle visits 0..11 ascending, reverse, or native-list (section-budget) order is NOT byte-proven.** No `for plInd` rotation, no descending loop, no list-walk opcodes were found in script text or in CODE bytes around any scheduler VA. The port's `for pi in players.size()` ascending all-players-per-frame pass stays labelled PORT SUBSTITUTE. No reverse order is claimed either.

---

## 5. Still-[U] register — exact 12-player / 3600-frame / 3-seed state-hash captures, zero-mismatch termination

General harness (all experiments): pin `t_87f0f3c130b0` donor texts; fixed `randkey0/1`; map + startid set from `startingsettings`; fixed `GetTimeSpeedFactor`; headless fixed-dt frame loop; 12 mixed human/AI players; canonical JSON state hash (players, entities, projectiles, RNG-stream counters, per-player deadlines `lastcheckexists/lastcalcsquadsmovecounttime/lastprogressaitime/lastseedwheattime/lastprogresstime/progresstick`, banks `resincomeremains/resconsumeremains`, section-max array) logged per global tick AND per per-player firing. **Zero-mismatch = byte-identical hash sequences across 3 seeds AND across process restarts; any single-tick divergence = FAIL, no tolerance, no statistics.** Losers deleted; winner documented with losing permutations listed. Until a winner settles, `TICK_ORDER v1` stays labelled PORT APPROXIMATION.

| # | Field | Static state after this ticket | Exact experiment (owner-authorised; no donor binary) |
|---|---|---|---|
| U-S1 | CurrentPlHandle rotation order | §4: one player per firing, native advance; global loops ascending [O]; rotation [U] | Rotation census: instrument port `tick()` to record `plind` per per-player firing for **3600 frames**, 12 mixed players. Candidates: (i) 1-per-frame RR ascending, (ii) all-per-frame ascending, (iii) budget-driven (section-max). Criterion: only candidate reproducing R1-anchor + R2-veto deadline-hit sequences for **3 seeds with 0 mismatches** survives. |
| U-S2 | Per-player firing rate | Gated blocks known; rate native | Rate census: same 3600-frame harness under idle + battle load; count firings/player/100 frames; log `lastprogresstime/progresstick`. Criterion: only rate law reproducing `lastcheckexists` hits (8.0/24.0 + slot) with **0 mismatches across 3 seeds** survives. |
| U-S3 | Global-vs-player-vs-unit-vs-projectile interleave | Internal block orders [O]; mutual order native | Boundary-permutation harness: freeze each internally-[O] block, permute ONLY block boundaries. **3 seeds × full skirmish** (peasants + army + capture + market). Criterion: **0 hash mismatches**; survivor documented with losers listed. |
| U-S4 | Mod-cohort alignment (path mod 2, sync mod 53, reach 3, rally 31, smoke 7) | Counter inits/phases [O] (TICK-ORDER R6) | Cohort log `progresstick mod {2,53,3,31,7}` per entity for **3600 frames**. Criterion: per-entity phase = init +1/frame reproduced with **0 mismatches**; any cross-player alignment beyond shared global counter declared absent. |
| U-S5 | Bank quantisation edge | Formula [O]; float bit-behaviour open | Fixed-dt sweep across sub-unit banks for 3600 s sim; assert `floor` carry sequence byte-identical for **3 seeds, 0 mismatches**. |
| U-S6 | Capture jitter anchor | Fire-time+jitter rule [O] (TICK-ORDER R5) | 200 capturers, 600 s: log `lasttimecheckcapture` deadlines; assert fire-time anchoring with **0 mismatches**; art 0.475 s vs base 1.875 s separated. |
| U-S7 | Veto reachability | Veto expression [O]; rarity open | Phase-crafting (`id*0.25` inits vs `0.125*plInd` slots) to force `checktime-addtime==gametime`; assert skip (no write, no block) with **0 mismatches across 3 seeds**. |
| U-S8 | AI sub-state split (Econ vs War) | Gate expressions [O]; body order [U]-A1 | 1 AI vs 1 idle human, 600 s: log Econ/War entry per `lastprogressaitime` firing; assert 2.4 s gate + adviser-only branch with **0 mismatches**. |
| U-DSP | DScript dispatch loop (new) | Table names [O] §1; loop [U] §2 | Static + harness: extend CODE-table sweep to neighbouring `0x68xxxx–0x6axxxx` prototype runs for any loop/stride literal; pair with U-S1 census (dispatch order observed at hash level). Criterion: byte literal + **0-mismatch** reproduction, else stays [U]. No `.bind` unpacking. |
| U-THR | ProgressPlayers thread effect (new) | Object names [O] §3; iteration list [U] | Toggle-harness (port-side only): single-threaded ordered pass vs deferred/batched section application; log section-max + visitation hash for **3600 frames × 3 seeds**. Criterion: **0 mismatches** decides whether thread/priority has observable order effect; else stays [U] with labelled single-threaded substitute. |

U-S7/U-DSP/U-THR permanence note: if the engine rotation/dispatch is unobservable from stored bytes + script text, U-S1 stays PERMANENTLY NATIVE with the labelled port order kept — no Ghidra/binary edit by any DEC worker (same limit as TICK-ORDER U-O7).

## 6. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items are additive completions/pointers only. None invents iteration order, rate, or interleave. None touches save version, existing keys, or I11 seam paths.

1. Keep `TICK_ORDER v1` frozen; append pointer to this report §5 U-S1/S2/S3 (3600-frame × 3-seed × zero-mismatch protocol) at the existing order comment. Do not move `_tick_players_slice` vs entities/projectiles/market/victory until U-S3 settles a winner.
2. Keep the ascending `for pi` player loop labelled PORT SUBSTITUTE; correct/extend its comment: driver reads are `progress.inc:37` + `progressai.inc:4` (2 reads, 0 writers); native export name byte-anchored at `cossacks.exe 0x690692` (ev_72fbfab4); global ascending loops (`nothing.inc:424,458,586,604,636,721`) order bookkeeping only — they do NOT prove CurrentPlHandle rotation (§4). Cite this report §4.
3. Record the native scheduler clusters as comment-only anchors (no behaviour change): section API `0x693a00–0x693c00`; time/state `0x69faf6–0x69fbce` (`PlayerSwitchToByHandle`, `SetProgressingPauseMode`); thread object `0x693f89/0x6a8894` (`ProgressPlayersThread/Priority/Performance`, `Use…Thread`, `UseMultithreadedMode`, `Perf*`); GO-delay-ExecuteState `0x63c4c4…` (not the player dispatcher). Mark U-DSP/U-THR open with §5 captures.
4. Verify-only items (IMPL-TICK-ORDER active — do not alter semantics): absolute-deadline gate (`time_s <= deadline → false`; veto `==` loop; write `time_s + addtime`); init `progresstick := id*2` + four `id*0.25+const` deadlines; bank shape (`speed 250.0 = 256/1.024` income / `20000` consume, `*32`, `mult 100`, `floor` carry); capture `lasttimecheckcapture` fire-time+jitter anchoring. Harnesses §5 U-S2/S5/S6/S7.
5. `ai.gd` seed-wheat `add` must read `TimeSeedWheat + plInd*3` (60.0+pi*3), init `id*0.25+60.0`; ProgressAI entry keeps `bexists` precondition + 2.4 s gate + adviser-only branch + implicit `SwitchTo('Progress')` return. Harness §5 U-S8.

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. Closed items (CODE table names/VAs, 2 driver reads + 0 writers, global ascending loops, inits/cadences/gate/bank/capture rules, GO-vs-player ExecuteState split, thread-object existence, data-as-code discard) rest on donor BYTES [O] with VA/file:line or donor TEXT [O] with file:line; open items list exact harnesses in §5.
- The ONLY iteration fact asserted: each Progress/ProgressAI firing addresses the ONE `GetPlayerCurrentPlHandle` player; global bookkeeping loops run ascending `0..MaxPlayerCount-1` (statistics `0..-2`). Any frame-level round-robin, rate, dispatch loop, thread effect, or stage interleave is [U] — never default plInd-ascending all-players-per-frame to donor law.
- Read-only compliance: exactly one repo file written (this report). No code/asset/config/Godot/git edit. Temp state: none (all reads via Craft Anything evidence + Get-Content/Select-String; dump outputs remain in the tool evidence store, not the repo). Shared investigation memory never written.
- Limits disclosed: no binary-side control-flow trace beyond the P11 garbage-decode discard; no `.bind` unpacking; `native_xrefs_list` 0/1 results are tool-limited, not liveness proofs.

*End of DEC-U-TICK-DEEP.*
