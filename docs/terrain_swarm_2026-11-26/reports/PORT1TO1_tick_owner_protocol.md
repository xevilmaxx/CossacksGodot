---
id: PORT1TO1-TICK-OWNER-PROTOCOL
worker: TICK-OWNER-PROTOCOL (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "The single ordered, owner-only experiment packet that settles P0-4 global player/unit/AI tick interleave: 12-player / 3600-frame / 3-seed state-hash harness, exact per-frame log schema, pinned cadences and VAs where known, zero-mismatch termination from the reports, and outcome-to-port-change (which interleave to adopt)."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/captured by this worker; donor facts below are re-cited [O]/[D] from the pinned upstream reports. The owner-only harness in §2-§3 is SPECIFIED, not performed."
scope_guard: "No repo code/asset/config/shader/Godot/git change, no gate/runner job, no capture, no Craft Anything native call, no investigation memory written. Exactly one repository file written: this report."
upstream: "DEC_U_tick_order.md §§1-7 (U-O1a-d, U-O2..O7); DEC_U_tick_driver.md §§1-5 (U-D1..D9); DEC_U_skirmish_tables.md §§7-9 (O1-tail, G1-tail); DEC_U_ai_activation.md §§3-7 (U-A6r/U-A7); DEC_U_rng_ledger.md §§1-4 (two streams, draw ledger, VAs); PORT1TO1_u_register_update.md §1 P0-4; PORT1TO1_owner_decisions.md §4; PORT1TO1_fixed_step_plan.md §§2-3/§8 (fixed-step engine contract); variant3d/scripts/{game,ai,main,data}.gd (read-only anchors)."
harness_class: RUNTIME-HARNESS (owner/COORD; no donor binary; workers forbidden to promote)
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
visual_parity_claim: false
---

# PORT1TO1 TICK — single owner-only global tick-order experiment packet (read-only, no parity)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim donor text/byte or verbatim port file line), `[D]` (deterministic arithmetic/control-flow consequence of `[O]`), `[I]` (interpretation, flagged), or `[U]` (UNVERIFIED — retired **only** by the owner/COORD running §2-§3 under the §5 zero-mismatch rule).

- **This worker ran nothing.** No donor binary, no Godot process, no gate, no harness, no capture, no frame/hash comparison. All donor constants, VAs, evidence ids and experiment ids are **re-cited pinned records** from the upstream reports named in `upstream`; they were not re-lifted. Port anchors marked `VERIFIED` were re-read read-only; anchors marked `DEC-U` are carried from the reports and **must be re-read at apply time** — concurrent local edits have already moved the tick block (the reports' `game.gd:5135-5195/5385-5455` are now `game.gd:5727-5787/6059-6088`; `DEC_U_ai_activation.md`'s `data.gd:69/ai.gd:73-76` are now `data.gd:407/ai.gd:15,24,89-94`). Line drift is disclosed, not smoothed over.
- **Owner-only.** §2-§3 may be executed only by the owner or COORD, on the port, headless fixed-dt, with a pinned config and literal seeds. Workers are forbidden to run the donor binary or to promote any `[U]` item. No donor execution is part of this packet.
- **No order invented.** The candidate records in §4 are the *enumerated hypotheses of the landed reports*, not donor facts and not a recommendation. The harness deletes losers; it never averages, merges, or ships two orders. The current port behaviour (`for pi in players.size()`, index order, every frame) is explicitly a **PORT SUBSTITUTE**, not donor law (`DEC_U_tick_driver.md` §2 F6).
- **No parity claim.** A surviving candidate is a `[D]+harness-id` *internal* order consistent with donor-text-pinned algebra. It is not a donor runtime observation and cannot become a parity claim. `parity.status="UNVERIFIED"`, `parity.claim=NONE`, `visual_parity_claim=false` before, during and after this packet.

**Load-bearing port fact `[D]` (VERIFIED, unchanged by this report):** `variant3d/scripts/game.gd:5691-5726` declares the whole per-tick sequence `TICK_ORDER v1 PORT APPROXIMATION` because donor per-tick order is not recovered; `game.gd:5727-5787 tick()` executes `ai_cheat → grid → fields → field-growth(60 s) → compact(5 s) → entities → projectiles → ageing → separate → cleanup → _tick_players_slice → tick_market → _check_victory`; `game.gd:6059-6088 _tick_players_slice()` visits every roster slot once per global frame in index order. Nothing in this report changes any of it.

---

## 1. What is already pinned (carry-forward; do not re-open in the harness)

### 1.1 Settled donor text `[O]/[D]` — the bodies the harness freezes

| Scope | Pinned content | Source |
|---|---|---|
| Global Nothing stage order | `progress.inc\nothing.inc` guarded body: perf → `_res_ProcessEconomy` → scenario zones/state/movie/proj-points → path batch → section-max + SearchEnemy scheduler → `_misc_SyncUnitsParams` (`mod 53`) → `_misc_CheckEndGame` → topology flush → peacetime expiry (wall clock) → LAN writes → statistics → `_ai_CheckProcessEnemyInfo(progressTick)` + top zones. Pause gate first/last. | `DEC_U_tick_order.md` §1; `DEC_U_tick_driver.md` EV-D6 |
| Per-player Progress slice order | `units\global.inc\progress.inc:37-184`: driver read `GetPlayerCurrentPlHandle` → pause gate → exists block (gated) → income+consume (UNGATED, `plind<11`) → `CalcSquadsMoveCount` (non-AI, gated) → hold-progress loop (ungated) → `CheckSquadsDisband` (non-AI, ungated) → `bexists and (bAI or adviser)` → `ExecuteState('ProgressAI')` → `progresstick += 1` → `lastprogresstime := GetGameTime` (unconditional, outside gate). | `DEC_U_tick_order.md` §2; `DEC_U_tick_driver.md` EV-D1 |
| ProgressAI sub-order | `progressai.inc:4-20`: second driver read → itype-2 `CheckProgressLastTimeAndIncrease(lastprogressaitime,2,2.4)` → `ProgressEconomicAI` then `ProgressWarAI` (or adviser-only else-branch) → `SwitchTo('Progress')` always. | `DEC_U_tick_driver.md` EV-D2; `DEC_U_ai_activation.md` §3 |
| Gate primitive | `lib\squad.script:754-782` (`756-785` in AI pass): **R1** absolute deadline `lasttime := gametime+addtime` (no catch-up; late fire permanently phase-shifts); **R2** exact-float cross-player veto — skip if ANY player's same-itype `checktime - addtime == gametime`; **R3** only caller's deadline written, others read-only; four itypes `0 exists / 1 movecount / 2 AI / 3 seed-wheat`. | `DEC_U_tick_order.md` §3; `DEC_U_tick_driver.md` EV-D3 |
| Contrast mechanisms | **R4** banks use `floor(bank*mult)` integer carry, no deadline; **R5** capture anchor `gametimewithrnd := gametime+uniqrnd`, `lasttimecheckcapture := gametimewithrnd+interval` (NOT deadline-relative, no post-capture cooldown); **R6** per-entity `progresstick := floor(RandomExt*32)` at creation, `lastprogresstime:=0`, `+1` per firing; **R7** wall-clock jitters `random*4.0/1.4/0.1/1.0/0.2/2.0`. | `DEC_U_tick_order.md` §3; `DEC_U_skirmish_tables.md` §3 |
| Driver attribution | Exactly **2** `GetPlayerCurrentPlHandle` reads (progress.inc:37, progressai.inc:4), **zero** writers in swept scheduler text. Advance/rotation/firing rate/stage interleave are engine-side `[U]`. | `DEC_U_tick_driver.md` §1-§2 F1-F3 |

### 1.2 Pinned cadences, phases, counters `[O]` — all literal products, no estimates

| Constant | Donor literal / file:line | Derived value / use |
|---|---|---|
| `gc_MaxPlayerCount` | `dmscript.global:97` | 12 players; slot 11 mercenary excluded from 5 s statistics buckets |
| `gc_time_to_frames` | `dmscript.global:175` | 32 ⇒ 1 frame = `1/32 = 0.03125 s` at fixed dt (port `Data.FPS=32.0`) |
| `TimeCheckExists` | `dmscript.global:1484` `0.01*200` | 2.0 s ⇒ alive `4× = 8.0 s`, dead `12× = 24.0 s`, plus `0.125*plInd` ⇒ `0 … 1.375 s` (itype 0) |
| `TimeCalcSquadsMoveCount` | `dmscript.global:1485` `0.03*10` | 0.3 s + `0.001*plInd` ⇒ `0.300 … 0.311 s` (itype 1, non-AI) |
| `TimeProgressAI` | `dmscript.global:1486` `0.03*16*5` | 2.4 s (itype 2); first fire `2.4 + 0.25·id` s |
| `TimeSeedWheat` | `dmscript.global:1487` `0.03*2000` | 60.0 s + `plInd*3` ⇒ `60 … 93 s` (itype 3, Econ only) |
| Init phases | `player.script:131-141`; save twin `serial.script:2213-2214` | `lastprogresstime:=0`; `progresstick:=id*2` ⇒ `0,2,…,22`; `lastcheckexists:=id*0.25+2.0`; `lastcalcsquadsmovecounttime:=id*0.25+0.3`; `lastprogressaitime:=id*0.25+2.4`; `lastseedwheattime:=id*0.25+60.0`. First firing is pause-gated, so phases begin at first unpaused frame. |
| Hold mode | `dmscript.global:180` `150*8*gc_frames_to_time` | 37.5 s; `fHoldModeProgress += dt/37.5`, `>=1 → hold` |
| Disband | `dmscript.global:156` | `count < basecount*0.25` |
| Mod cohorts | TICK-ORDER §3-R6 / TICK-DRIVER EV-D6 | global `progresstick mod 2` path, `mod 53` sync; per-entity `mod 3` reach, `mod 31` rally, `mod 7` smoke. `progresstick` and `progressTick` are DISTINCT fields — never merge. |
| Bank arithmetic | `player.script:240-321` | `mult=100`; income `speed=256/1.024=250.0`; consume `speed=20000`; rate `*32`; carry `floor((realbank-value)*speed*mult)`. Shortfall drains to `not res` (current-value read `[D]`). |
| Capture cadence | `dmscript.global:1476,1479-1480` | base `0.1*19−eps = 1.875 s`, art `0.1*5−eps = 0.475 s`; jitter `random*1.875` at spawn; per-entity stored `uniqrnd` |
| Section intervals | `dmscript.global:1457-1474` | default/units 100, peasants 135, buildings 33, mines 25, wheat 110, oreplace 120, artillery 60, pfx 13-29; section-max recomputed per frame by SearchEnemy scheduler |

### 1.3 Pinned VAs `[O]` — what exists and what does not

| Domain | Pinned VA(s) | Use in this packet | Source |
|---|---|---|---|
| Sim RNG stream S | `0x60f64c` (`RandomExt` LCG recurrence, `0x60f64c-0x60f696`); helpers `0x406718` / `0x4067b8` (key mixing; cross term discarded ⇒ `key0` never feeds a draw); global `0x9048d4/d8` at fire time | Log S-stream draw counts per site (§3.5); assert `floor(RandomExt*n)` and the X21 20-vector oracle `(0x44A108F9,0x00000001)` exactly. | `DEC_U_rng_ledger.md` §§1-4; `X21_rng_vectors.md` |
| General Delphi stream G | `0x403a0c` (`state=state*0x8088405+1 mod 2^32`, `ret=state>>>24`), seeder `0x4033b8` (QPC-low else TickCount), global `0x8f2008`, divisor `0x8f206c=2^-32` | Separate G draw count from S: famine roll, headshot `random<0.05`, capture AI die rolls, wall-clock jitters, friendly-fire reseed. G is seeded once at process start and is **never** reseeded by sim `SetRandomKey`/`SetRandomExtKey64`. | `DEC_U_rng_ledger.md` §§1-4 |
| Native scheduler / driver | **NONE RECOVERED — explicitly `[U]`.** All scheduler facts above are script-text `[O]`; no binary-side scheduler trace (PE imports/sections/xrefs, Ghidra) was run by any DEC worker. | Do **not** substitute an assumed VA. If an owner-authorised native pass ever recovers the driver VA, it is a separate report; this packet stays script/harness-only. | `DEC_U_tick_order.md` §5 U-O7/§7; `DEC_U_tick_driver.md` §3 U-D1/§5 |

### 1.4 Current port anchors `[O]` (read-only VERIFIED; re-read before applying any §6 change)

| Anchor | Current content | Label / drift note |
|---|---|---|
| `game.gd:5691-5726` | `TICK_ORDER v1 PORT APPROXIMATION` comment + RESOLVED internal global stage order + pointer to U-O1c | freeze; do not reorder |
| `game.gd:5727-5787` | `tick()` sequence listed in §0; `_tick_players_slice` at `:5785`, `tick_market` `:5786`, `_check_victory` `:5787` | stage boundaries are the permutation variables of U-O1c |
| `game.gd:6059-6088` | `_tick_players_slice()`: `for pi in players.size()`; exists itype 0 at `:6075`; income ungated `:6078`; movecount itype 1 at `:6081-6083`; `progresstick+=1` `:6087`; `lastprogresstime=time_s` `:6088` | `[U]-O1a/O1b` PORT SUBSTITUTE |
| `game.gd:477` / `game.gd:518` | `_TICK_CALCSQUADS_S := 0.3`; player init writes absolute deadline keys | `[O]` values |
| `data.gd:1723-1726` | `DONOR_TICK_EXISTS_SLOT_S 0.125`, `EXISTS_ALIVE 8.0`, `EXISTS_DEAD 24.0`, `MOVECOUNT_SLOT_S 0.001` | `[O]` values |
| `data.gd:407` / `ai.gd:15,24,89-94` | `AI_THINK_INTERVAL := 1.0`; `_TICK_AI_S := 2.4`; `think_t := 0.0`; gate via `game._check_progress_lasttime_and_increase(player, 2, _TICK_AI_S)` | Mixed snapshot: an itype-2 gate is landed, but `AI_THINK_INTERVAL=1.0` and `think_t=0.0` remain; stale comment at `ai.gd:1324` still says "1.0 vs 2.4". **The harness records what actually executes; it does not trust comments.** |
| `main.gd:1673/1676`, `:1686/1691`, `:2248/2250` | `game.tick(step)` then `brain.tick(step)` in all driver paths | donor shape `Progress → ExecuteState('ProgressAI') → SwitchTo('Progress')` `[D]` |

---

## 2. THE harness — one ordered owner/COORD run matrix (specified, not performed)

### 2.1 Admissible setup (no donor binary; Class-N excluded)

1. **Engine contract:** use the opt-in fixed-step path of `PORT1TO1_fixed_step_plan.md` §2-§3 (`--deterministic-capture --capture-ticks N`, windowed `--seq`, literal `--seed`, `deadline_ms=0`, `watchdog=0`, authoritative 1280×720 viewport, CPU fallback refused). For a pure state-hash battery, headless fixed-dt is admissible only if `N3` fisher `randf()` (`game.gd:8127-8130`) is code-neutralised and no fishing delivery occurs; otherwise the run is inadmissible.
2. **Frame budget:** `N = 3600` fixed ticks of `1/32 s` ⇒ `time_s = 112.5 s` exactly (`game.gd:5731`). This is the primary matrix. The 600 s experiments (U-O3 capture jitter, U-O6/U-D9 AI, U-O7 section micro-order) are **separate 19200-tick batteries** — never silently conflated with the 3600-frame run.
3. **Players:** **12** roster slots, mixed human/AI, with slot 11 mercenary present (statistics exclusion must be observable). Pin `bai` per slot at generation (`dogenerate.inc:2039`) from `startingsettings`; no mid-run AI toggles.
4. **Seeds:** **3 literal seeds** (`randkey0`/`randkey1` pinned per seed, map from one fixed `startingsettings` startid set, fixed `GetTimeSpeedFactor`) plus **a process restart of each seed** ⇒ 6 runs per candidate. A run hash-differing after restart is a FAIL even if the same-seed pair matches.
5. **Load profiles:** (i) idle ([O] deadline hits only), (ii) full skirmish (peasants + army + capture + market), (iii) forced veto profile (phase-crafted, §4.4). Every candidate is run on all three.
6. **Excluded paths:** `--seed random`, menu Random button, wall-clock watchdog, frame-paced stepping, async-load yields, 800×600 GPU fallback, `load_save` seed rewrite, audio RNG/wall-clock dedup (`audio.gd:334-337,360,368`). Record config SHA and a Class-N "none active" assertion in the run manifest.
7. **Instrumentation is additive and labelled**; it must not change sim order, RNG consumption, or save keys. No donor file is opened for write. Workers do not run this matrix.

### 2.2 Ordered execution per candidate (do top-to-bottom; ★ = stop-and-gate)

| Step | Act | Gate / output |
|---|---|---|
| 1 | Pin build, config SHA, 3 seed key pairs, startid set, speed factor, player roster. Refuse if any Class-N path active. | ★ manifest fields immutable for all 6 runs |
| 2 | Reset all [O] init phases from §1.2 (deadlines, `progresstick:=id*2`, `lastprogresstime:=0`, entity `floor(RandomExt*32)`). | ★ assert each slot's four deadline values before tick 0 |
| 3 | For frame `f = 0 … 3599`: advance `time_s += 1/32` once; execute the candidate stage-boundary order (§4.2) with internally-[O] blocks frozen; log the §3 schema; emit canonical hash `H_f`. | no wall-clock input; one hash per frame AND one per per-player firing |
| 4 | At the per-player slice, emit the candidate rotation (§4.1), recording the selected `plind` for every firing; run each player's four itype gates under R1/R2/R3 and the ungated blocks. | ★ any gate write that is not absolute-deadline form ⇒ candidate FAIL |
| 5 | Count S and G RNG draws per site (§3.5) and cross-check against the pinned ledger. | ★ a site drawing from the wrong stream ⇒ candidate FAIL |
| 6 | After 3600 frames, append restart run; compare `H_0…H_3599` byte-for-byte across all 6 sequences. | ★ single survivor only; any mismatch ⇒ no order adopted |
| 7 | Discriminate survivors against the donor-text algebra (R1/R2/R3 + cadences + slice order). Delete losers; document the winner with its losing permutations. | no winner ⇒ P0-4 stays open, `TICK_ORDER v1` frozen |

---

## 3. EXACT per-frame / per-firing log schema (the load-bearing packet)

Every line is keyed `(seed, run_kind, global_frame f, event_seq)`. Canonical JSON with sorted keys and full Float precision (the R2 veto compares `==` on Float deadlines — never quantise). The state hash `H_f` is over items 3.1-3.7 below plus the candidate id; `sha256(canonical_json)` is authoritative.

### 3.1 Frame header (one per global frame)
`f`, `time_s` (must equal `f/32`), `dt` (`0.03125`), `candidate_id`, `pause_gate` (donor requires `lastprogresstime>0 and deltatime>0`), `global_progresstick`, `global_progressTick` (distinct; record both), `stage_order_observed` (ordered list of block ids actually executed; missing [O] blocks recorded as `absent`, never invented), `unit_tick_order` (ordered list of entity ids in `_tick_unit`/`_tick_building` visitation), `projectile_order` (ordered ids from `_tick_projectiles`), `separation_pass_order` (9-cell scan order — sequential relaxation, order-sensitive).

### 3.2 Player-selection record (one per per-player firing)
`event_seq`, `selected_plind` (the `GetPlayerCurrentPlHandle` analogue actually used), `selection_mechanism` (`rr_asc` / `all_per_frame_asc` / `section_budget` / other — recorded, never asserted), `firing_index_per_player[0..11]`, `progresstick[plind]`, `lastprogresstime[plind]`.

### 3.3 Gate record (one per gate evaluation, per player)
For each itype `0 exists / 1 movecount / 2 AI / 3 seed-wheat` log: `plind`, `itype`, `deadline_before` (Float), `gametime`, `addtime` (the exact pinned value from §1.2), `fire_bool`, `veto_bool` (R2 — and **which** player/itype collided), `deadline_after` (`gametime+addtime` on fire, unchanged otherwise), `bexists`, `bai`, `adviser_branch_taken`, `block_executed`. For itype 0 also record `alive_or_dead` (8.0 vs 24.0) and the `0.125*plInd` slot; for itype 1 `non_ai_only`; for itype 2 the `adviser-only else` vs `Econ+War` branch; for itype 3 `bprocess` and `centerfound`.

### 3.4 Ungated / per-entity records
`income_consume_fired` per player (every firing), bank `remains[i]` before/after with `floor` carry, famine/rebellion set/clear thresholds; squad hold progress `+= dt/37.5`; disband events; per-entity `progresstick_init := floor(RandomExt*32)`, `progresstick` per firing, and each mod-cohort hit (`mod 2 path`, `mod 53 sync`, `mod 3 reach`, `mod 31 rally`, `mod 7 smoke`) with entity id and global vs per-entity counter attribution; capture deadline `lasttimecheckcapture` and `gametimewithrnd` anchor (art 0.475 vs base 1.875 cohorts tagged).

### 3.5 RNG draw-count record (per stage and per site)
Two independent counters, never merged: `S` (`RandomExt` LCG at `0x60f64c`) and `G` (Delphi `Random` at `0x403a0c`). Log `draws_before`, `draws_after`, `stream`, `site_id`, `n_literal`, `reseed_bool` for each pinned site: enemy-info top-zone, exists scan, income/consume (**0** draws), movecount, hold/disband, ProgressAI entry, seed-wheat (_ai_DoSeedWheat), Econ mine-position, WarAI scatter/`4096/32768` gate, guard sampler (3000/6000/10000/20000), fear selector (**0**), headshot `random<0.05` + stored `uniqrnd` (**0**), friendly-fire reseed (G1+S k), projectile scatter + `frnd` (S 2+S 1), stray `random1` (S 6), `stand` (S ≤1), `DoExplode` resync (0), round-damage victims (S m+n), `randomsimulate` (S 2 + local LCG), famine roll, capture AI die rolls, wall-clock jitters, and entity-init `floor(RandomExt*32)`/`uniqrnd`. Assert S/G attribution and the X21 oracle; a single wrong-stream or wrong-count site is a FAIL.

### 3.6 Stage-order record
Ordered block-id sequence for the frame (economy / scenario / paths / section-max / scheduler / sync / endgame / topology / peacetime / LAN / statistics / AI-enemy-info / **player-slice** / **entities** / **projectiles** / **cleanup** / **market** / **victory**), plus the position of the per-player slice relative to entities/projectiles/market/victory — the exact U-O1c unknown. [O] stages with no port counterpart are logged `absent` (no scenario, global path batch, section-max, sync queue, topology, peacetime, LAN or enemy-info stage in this skirmish-only port — `game.gd:5711-5716`).

### 3.7 Section visitation (U-O7 battery only)
With section-max budgets **frozen** (adaptation disabled), per section class log ordered GO ids (`GetPlayerProgressSectionCountGOByIndex` / `GetGOHandleByIndex` analogue), stride vs contiguous, rotation offset, and interval class (§1.2). Capture protector scan order is logged separately. If unobservable from script, record `[U]-O1 PERMANENTLY NATIVE` and keep the labelled port order.

---

## 4. Candidate records — enumerated hypotheses only, none asserted

### 4.1 U-O1a / U-D1 — CurrentPlHandle rotation (one record per candidate)
- **(i)** 1-per-frame round-robin ascending in `plInd` order.
- **(ii)** all-players-per-frame ascending in `plInd` order (**this is the current port behaviour — PORT SUBSTITUTE, not donor law**).
- **(iii)** section-budget-driven visitation (section-max budgets select the fired player). Requires §3.7 to settle first.
Criterion: only the candidate reproducing the R1-anchor + R2-veto deadline-hit sequences for 3 seeds with 0 mismatches survives; losers deleted; never ship two orders.

### 4.2 U-O1c / U-D3 — stage-boundary interleave
Freeze every internally-[O] block (global Nothing order §1.1; per-player slice order §1.1) and permute **only block boundaries**: economy / scenario / paths / sections / player-slice / entities / projectiles / cleanup / market / victory / AI. Each permutation is a candidate id in `H_f`. Full skirmish load, 3 seeds × 2 runs. The surviving permutation is documented **with its losing permutations listed**; `TICK_ORDER v1` stays labelled PORT APPROXIMATION until then.

### 4.3 U-O1b / U-D2 — firing rate
Same matrix under idle + battle load; count firings/player/100 frames, `lastprogresstime`/`progresstick` per firing. Only the rate law reproducing `lastcheckexists` deadline hits (`0.125*pi + 8.0/24.0`) with 0 mismatches survives.

### 4.4 U-O5 / U-D8 — veto reachability (phase-crafted profile)
Craft inits (`id*0.25`) against slot terms (`0.125*plInd`, `0.001*plInd`, `plInd*3`) to force `checktime-addtime == gametime`. Assert skip: no deadline write, no block execution, `veto_bool=true`, identical hash sequence. Proves R2 is live code, not dead code.

### 4.5 U-O1d / U-D4, U-O4 / U-D7, U-O2 / U-D5, U-O3 / U-D6, U-O6 / U-D9, U-A6r / U-A7 — companion batteries
Log `progresstick mod {2,53,3,31,7}` per entity (per-entity phase = pinned init +1/frame; cross-player alignment beyond the shared global counter declared absent); `not res` shortfall drain-to-current-value and famine/rebellion thresholds; bank `floor` carry sweep over sub-unit rates (negatives unreachable — bank ≥ 0 by construction); 200 capturers over 600 s asserting fire-time+jitter anchoring; 1 AI vs 1 idle human over 600 s logging Econ/War entry per itype-2 firing and the adviser-only branch; AI cadence `2.4 + 0.25·id` with cross-player anti-collision in an owner-attached unmodded observation (U-A6r — text binding closed, runtime binding `[U]`, **not run by workers**). Body internals inside each AI sub-state stay `[U]`-A1.

---

## 5. Zero-mismatch termination criteria (verbatim shape from the reports; no partial credit)

A `[U]` item retires **iff** the named tuple is byte-identical with **0 mismatches** across **3 seeds and process restarts** (6 sequences) and all load profiles. Any single-tick divergence, missing dump, wrong-stream draw, closed gate, or path/candidate mixing ⇒ item stays `[U]`, its candidate is deleted, and the port keeps its current label. "Close", a metric, an average, or a port-internal replay pair never counts.

| Experiment | Tuple that must repeat with 0 mismatches | Minimum sample | Source |
|---|---|---|---|
| U-O1a / U-D1 | `plind` sequence + `progresstick`/`lastprogresstime` per firing under R1-anchor + R2-veto; **one survivor**, losers listed | 3600 frames × 12 players × 3 seeds × 2 runs, idle + battle | TICK-ORDER §5; DRIVER §3 |
| U-O1b / U-D2 | firings/player/100 frames + `lastcheckexists` deadline-hit sequence (`0.125*pi` + 8.0/24.0) | same matrix | TICK-ORDER §5; DRIVER §3 |
| U-O1c / U-D3 | canonical state hash `H_0…H_3599` over the full block-boundary permutation | 3 seeds × full skirmish; survivor + loser list | TICK-ORDER §5; DRIVER §3 |
| U-O1d / U-D4 | per-entity `progresstick mod {2,53,3,31,7}` phase = init +1/frame; no unproven cross-player alignment | 3600 frames | TICK-ORDER §5; DRIVER §3 |
| U-O2 / U-D5 | `floor` bank carry sequence byte-identical across sub-unit sweeps | 3600 s sim (separate battery) | TICK-ORDER §5; DRIVER §3 |
| U-O3 / U-D6 | `lasttimecheckcapture` fire-time+jitter anchors, art 0.475 vs base 1.875 cohorts separated | 200 capturers / 600 s | TICK-ORDER §5; DRIVER §3 |
| U-O4 / U-D7 | shortfall drains to `not res` current value; famine/rebellion clear thresholds per tick | shortfall-tick battery | TICK-ORDER §5; DRIVER §3 |
| U-O5 / U-D8 | veto skip with no deadline write and no block execution | forced-collision profile | TICK-ORDER §5; DRIVER §3 |
| U-O6 / U-D9 | Econ/War entry per itype-2 firing; 2.4 s gate + adviser-only branch | 1 AI vs 1 idle human / 600 s | TICK-ORDER §5; DRIVER §3 |
| U-O7 | GO visitation stride/contiguity with budgets frozen; else `[U]-O1 PERMANENTLY NATIVE` | 600 frames | TICK-ORDER §5 |
| U-A6r / U-A7 | `aidata` list growth on `2.4 + id*0.25` cadence with anti-collision; hash stable with plInd order documented | 600 s owner-attached observation (owner only) | AI-ACTIVATION §6 |

**Global rule:** byte-identical hash sequences across seeds **and** restarts, **single surviving order**, losers deleted/listed. Until that holds, `TICK_ORDER v1` stays `PORT APPROXIMATION` and no rotation, rate or interleave is promoted to donor law.

---

## 6. Outcome → exact port change (owner/COORD applies; NO edits made here)

Every row fires **only** on its zero-mismatch result. All anchors must be re-read at apply time (§0 drift note). None touches save version, existing v5 keys, or I11 seam paths.

| Zero-mismatch outcome | Exact port change — which interleave to adopt | What stays frozen / hard-labelled |
|---|---|---|
| **U-O1a candidate (i)** wins | Replace `game.gd:6061` `for pi in players.size()` with exactly one player fired per global frame, ascending rotation, preserving the frozen slice body at `:6067-6088`. Re-tag `[U]-O1a` to `[D]+harness-id` with its candidate id. | All other stage boundaries frozen; no claim of donor parity; losers (ii)/(iii) deleted, not shipped. |
| **U-O1a candidate (ii)** wins | Keep `game.gd:6061` index order byte-for-byte; only re-tag from PORT SUBSTITUTE to `[D]+harness-id`. **No behavioural change.** | Do not infer donor law beyond the harness id; (i)/(iii) deleted. |
| **U-O1a candidate (iii)** wins, **and** U-O7 passes | Implement section-max-driven selection at `:6061` using the pinned interval classes (§1.2) and the captured stride/contiguity; freeze section-max adaptation as captured. | U-O7 must be 0-mismatch first; no rotation beyond the reported class invented; losers deleted. |
| **U-O1c block-boundary permutation** wins | Move **only** the block boundaries in `game.gd:5727-5787` to the surviving permutation; keep every internally-[O] stage body byte-identical. Replace the `TICK_ORDER v1 PORT APPROXIMATION` label at `:5691-5726` with the surviving permutation id + loser list. `_check_victory()` stays post-slice unless the winner explicitly places it elsewhere (`nothing.inc:646` fresh-bexists constraint). | Missing [O] stages stay absent (no scenario/path/section/sync/topology/peacetime/LAN stage invented); parity still UNVERIFIED. |
| **U-O1b rate law** wins | Wire the surviving firing rate into the per-player slice; keep the four absolute-deadline gates and the unconditional `lastprogresstime` stamp unchanged. | No countdown accumulator; no catch-up loop. |
| **U-O5 veto reachable** | Keep `game._check_progress_lasttime_and_increase` R1/R2/R3 semantics verbatim (strict `gametime>lasttime`, cross-player `checktime-addtime==time_s` skip, `time_s+addtime` write); add telemetry id. | No `+=` accumulator, no deadline quantisation, no cross-stream shortcut. |
| **U-O6 / U-A6r / U-A7 AI interleave** passes | Keep/wire the itype-2 gate at `ai.gd:89-94` (`2.4 + 0.25·slot`, cross-brain anti-collision), `bexists` precondition from `progress.inc:177`, adviser-only else branch, and `SwitchTo('Progress')` return. Reconcile stale `ai.gd:1324` comment and `data.gd:407 AI_THINK_INTERVAL=1.0` / `ai.gd:24 think_t=0.0` **only** to the surviving cadence; `main.gd` keeps `game.tick` before `brain.tick`. No `//`/`{...}`-disabled row activated. | Body internals stay `[U]`-A1; `wave_cd` per-step decrement stays; no D-row enabled. |
| **U-O7 unobservable / no single survivor / any mismatch** | **No port change.** Keep `TICK_ORDER v1` frozen at `game.gd:5691-5726`, keep index-order slice at `:6061`, record `[U]-O1 PERMANENTLY NATIVE` if the driver is unobservable, and keep all current labels. | P0-4 stays open; no order adopted; no test weakened; no fallback added to force a match. |

**Single-survivor rule:** never ship two orders. A candidate that loses on any seed, load profile, or restart is deleted and listed as a loser in the winning record. Passing this harness yields port-internal self-consistency against donor-text-pinned algebra only — **not** a donor parity claim; a matched-seed donor-vs-port A/B remains a separate owner-only obligation (X39).

---

## 7. Hard-fail matrix — gaps that may NEVER be substituted

| Gap → / Forbidden substitute ↓ | Rotation unknown | Stage interleave unknown | Firing rate unknown | AI gate unknown | RNG stream unknown |
|---|---|---|---|---|---|
| Default to plInd-ascending all-players-per-frame as donor law | ✗ | — | ✗ | — | — |
| Invent a round-robin, section-budget stride, or cadence not enumerated in §4 | ✗ | ✗ | ✗ | ✗ | — |
| Reorder internally-[O] stage bodies or merge `progresstick` with `progressTick` | — | ✗ | — | — | — |
| Countdown accumulator / `+=` catch-up in place of R1 absolute deadline | — | — | ✗ | ✗ | — |
| Quantise Float deadlines, weakening the R2 exact-float veto | — | — | ✗ | ✗ | — |
| Assert the port 1.0 s shared AI think gate as donor cadence | — | — | — | ✗ | — |
| Enable a `//`/`{...}`-disabled AI row on a guess | — | — | — | ✗ | — |
| Merge S (`RandomExt`) and G (Delphi) draws into one stream; `floor(x+0.5)` for donor `round()` | — | — | — | — | ✗ |
| Add a port fallback, lower a threshold, or retry until green to force 0 mismatches | ✗ | ✗ | ✗ | ✗ | ✗ |
| Rename/remove v5 save keys or bump save version to "make the order fit" | ✗ | ✗ | ✗ | ✗ | ✗ |

Telemetry rule: keep `visual_parity_claim=false`; each retired sub-item flips to `[D]+harness-id` with its tuple and loser list; everything else stays `[U]` with the §4/§5 experiment that would settle it.

---

## 8. Status until the owner executes §2-§3 (explicit, non-negotiable)

- `TICK_ORDER v1` stays `PORT APPROXIMATION` in `game.gd:5691-5726`; the per-player slice at `game.gd:6059-6088` stays index-order PORT SUBSTITUTE; no rotation, rate or stage interleave is claimed as donor.
- P0-4 (`PORT1TO1_u_register_update.md` §1) stays **open**. `blocking_unverified` stays non-empty; the six-condition chain remains 0/6 CLOSED; verdict remains **`RESULT IS NOT GOOD`**.
- Port AI stays **DONOR-TEXT-DRIVEN** with the mixed 2.4 s gate / 1.0 s interval snapshot disclosed in §1.4; no D-row activated.
- `parity.status="UNVERIFIED"`, `parity.claim=NONE`, `visual_parity_claim=false` throughout. Even after a survivor lands, no same-camera donor/port A/B frame exists and no parity statement is authorised.

## 9. Non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no harness/gate/runner job launched, no port capture compared by this worker. All donor readings are re-cited `[O]/[D]` from the pinned upstream reports; all unsettled items are `[U]` with the §4 experiments and §5 gates.
- **No approximation supplied and no order invented.** §4 candidates are the landed reports' enumerated hypotheses, not a recommendation or a donor value. The current port's index-order behaviour is disclosed as a substitute, not endorsed as donor law.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md`. No code/asset/config/shader/Godot/git change; no donor file opened for write; no Craft Anything native call; no investigation memory written.

*End of PORT1TO1-TICK-OWNER-PROTOCOL.*
