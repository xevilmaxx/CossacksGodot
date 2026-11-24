# Session progress — 2026-11-24 coordinator swarm

Living log. Only the coordinator edits this file.

## 2026-11-24 — session start

### Context read (cold-start)
`SWARM_OPS.md` (org, gates, §7 recursive tree), `SWARM_BOARD.md` (ticket states,
T6 wave closed, T5 wave), `SWARM_BACKLOG.md`, `app/tools/AGENT_PROTOCOL.md`,
`RESUME.md`, `STATUS_SKIRMISH.md`, `PERFORMANCE_SWARM.md`, `audit/MICRO.md`
(68 donor micro-features), `DONOR_OPTIONS_GAPS.md`. Donor data tree at
`C:\Games\Cossacks 3\data` confirmed (25 subdirs: scripts, gen, pattern, env, actors,
animations, objects, locale, pfx, shaders, sounds, water, gui, hud, …).

### Baseline truth check (important — docs disagree with disk)
| Signal | Docs claim | On-disk truth (read 2026-11-24) |
|---|---|---|
| `app/selftest.json` | 29/29 PASS | **`passed:false`** — 27/29; FAILs: `peasant_capture` ("peasant captured: player 1"), `resow` ("wild food nodes=0; depleted mill field re-sown: no; mill auto=24 restored=1") |
| `app/uitest.json` | 17/17 PASS | `passed:true` |
| Clean gate | CLEAN (D-23/D-30) | **DIRTY** — 4 unacknowledged historical timeouts in `app/.godot_queue/status.json`: #1132 `t-menu-roster-3`, #1135 `t-menu-roster-4`, #1184 `t-menu-input`, #1205 `t-forest-bake2` (all 100 s runner timeouts, 2026-11-23) |
| Runner | — | `now_serving=1232`, `pending=0`, `godot.lock=free`, 139 completed (98 ok / 37 failed / 4 timed-out) |

**Resolution plan:** fresh `coord-baseline-selftest` job submitted through the runner
to distinguish a stale artifact from a real regression. Each of the 4 timeouts is
superseded by later `ok` runs of the same test:
- #1132/#1135 → #1136/#1160/#1167/#1175 `t-menu-roster` ok; #1154 `-final` ok
- #1184 → #1187 `t-menu-input` ok; #1190 `-final` ok
- #1205 → #1212 `t-forest-bake-final` ok; #1217 `-clean` ok; #1222 `-render` ok
These are genuine historical/resolved timeouts; ack under `CLEAN_GATE.md` §"Resolved
historical failures" once the background job finishes (avoid spool race).

### 2026-11-24 — baseline result + first improvements
- Fresh `coord-baseline-selftest` (runner ticket **1232**, 203.83 s) => `failed`,
  **28/29**: only `resow` fails (`wild food nodes=0; depleted mill field re-sown: no;
  mill auto=18 restored=1 gold=3353`). `peasant_capture` PASSED this run → it is
  flaky, not a stable defect. `BAKE_BENCH max_ms=3753.09` was recorded under heavy
  concurrent-agent load, NOT comparable to the 50 ms gate (machine was saturated).
- **Clean gate CLEAN** achieved: acked the 4 verified historical timeouts
  (#1132/#1135 superseded by #1136/#1160/#1167/#1175 + #1154; #1184 by #1187/#1190;
  #1205 by #1212/#1217/#1222/#1229). `assert_clean.py --json`: `clean:true`,
  140 jobs, 4 acknowledged, 0 live processes, lock free.
- Recon landed: **R1** (farming — features are implemented, MICRO.md stale; one real
  gap = missing aca.3 agronomist +50% upgrade), **P1** (sim: `_grid_rebuild`
  per-tick allocations rank 1; `_kind_class` hoist rank 4 — zero-risk), **P2**
  (render: HUD per-frame O(n) counter scan top pick; no safe water fetch reduction),
  **T1** (29 steps partitioned into 8 coherent subsets, 3 hard deps), **T2**
  (`--self-test` output-only; add `--self-only`/`run_only`; subsets must not overwrite
  canonical selftest.json).
- Wave 2 builders launched: **I1** (data.gd: aca_agronom1 row) and **I2**
  (hud.gd: 0.5 s counter throttle), each exclusive owner, backup + one targeted test.
- **D1** launched: diagnose the sole `resow` failure (truth fix, no weakening).
- Gap matrix consolidated in `GAPS.md`.

### 2026-11-24 — periodic supervision (owner request)
- R8 and R11 had reported but their sessions stayed `running` on trailing background
  donor scans. Pinged both; scans stopped/ignored, reports confirmed final, sessions
  closed. No new work started by either.
- Automation `aut_20c9e4cc0001a6MHYIQ9OSk0sQ` created: every 5 min checks report
  files vs expected ids, pings silent/running agents, reads runner status + clean
  gate, appends a one-line check here (`SWARM_OPS.md` §7.3 supervision loop).
- All 16 wave-1 recon agents + T1–T3 + D1 have now closed with reports. Wave-2
  builders remaining: I4 (resow latch + subsets, re-running full gate), I6
  (300 s AI metal soak). I1/I2/I3/I5 landed with targeted tests green.
- **Coordinator diff review (read-only)** of landed I1/I2/I3/I5: `git diff --stat`
  = data.gd +4, hud.gd +5/-1, world.gd +70/-18, audio.gd -2. All edits are
  minimal, evidence-commented, backup present, no called symbol renamed;
  world.gd preserves draw call order/args (pool count reset in `_draw_units`,
  cached `_bld_key` keyed by SPRITE_CELL+player+sid, negative death-sheet cache
  keyed by resolved path). No protocol block. I4/I6 reviewed after they close.
- **Owner speed question answered** (`TEST_SPEED_NOTES.md`): tests are NOT at x1.
  CLI soaks run up to 1500 fixed ticks/40 ms frame (9,600 ticks for 300 sim-s)
  and bypass `--speed` entirely (`main.gd:1121-1122,1575-1593`); selftest uses
  `game.tick(0.25)` = 4 ticks/sim-s with `dt` hard-capped at 0.25
  (`game.gd:3820`). `--speed 10` is a no-op for CLI and impossible for selftest;
  shortening windows would weaken assertions. I6 informed; real speedups are
  the headless CLI frame-budget flag and T3 Scenario B snapshot restore, both
  recorded as follow-ups.

### 2026-11-24 — 29/29 RESTORED
- I4 ticket **1248 `i4-resow-latch2`** succeeded: diag showed
  `I4RESOW LATCH t=8 sow_t=2.0 hits=50` — the peasant's own `cmd_resow`
  restored the field at tick 8, long before the 60 s auto-sow timer (sow_t=2).
  Canonical `app/selftest.json` is now `passed:true`, **29 steps**, 0 failures
  (sim_seconds 366.5625). This supersedes all earlier red/28-29 snapshots.
  I4 asked to finish the two subset runs + final report; no new code changes.
- I6 report landed with honest partial scorecard (see `IMPROVEMENTS.md`):
  metal mines fixed, but force max 40 / wave 0 are MEASURED failures from a
  separate `_train`-gate cause → follow-up ticket G-AI4.

### 2026-11-24 — FINAL VERDICT (all work closed)
- All 26/26 reports landed. I4 report: subset mechanism `--self-only`/`run_only`
  + 8 groups, resow truth fix, 29/29 gate; documented the `capture` group-order
  FAIL as an open question. I6 report: metal-mine fix real but force/wave targets
  are measured failures from a separate `_train` cause (G-AI4 follow-up).
- Coordinator fixed the last subset interaction (COORD-1): `peasant_capture`
  fixture now avoids buildings; `capture` subset 2/2 PASS (job 1254).
- **Settled gate: selftest 29/29 (job 1255), uitest 17/17 (job 1256), clean gate
  CLEAN.** Supersedes every earlier red snapshot in this doc.
- Runner defects fixed + verified (P4-fix): 2 s `pid_alive` throttle and
  post-job Godot child reaping; job 1257 ok, 0 orphans, gate CLEAN.
- Remaining documented follow-ups (NOT done this session): G-AI4 train gates /
  wave cadence, DDS 613 MiB dead decals, 259 MiB duplicate PNGs (hardlinks),
  `scan_map.py` 28.5 s, T3 Scenario B snapshot restore for <30 s subsets,
  grapeshot range 175 vs donor 450, Scotland depth, HUD fidelity, staged naval
  families, gold-shortage desertion/ship-stop, capture-mode inversion.

### Periodic supervision checks
- Sweep 5: ALL 26/26 expected reports present; runner empty (`pending=0`), no
  Godot processes, lock free, history CLEAN (4 acked) — **CLEAN**. All builders
  closed; coordinator reviewing remaining subset-order issue and preparing the
  final settled gate (selftest already 29/29 from job 1249).
- Sweep 6 (final): all agents closed, no reports pending, no live jobs, gate
  CLEAN; runner leak + poll throttle fixed and verified afterwards. No ping
  needed.
- Sweep 4: reports 25/26 (only `I04_test_split.md` pending); runner ticket 1249
  `i4-final-full` actively serving, one live Godot matching it (expected, lock 47 s,
  history CLEAN) — no orphan, no ping needed (agent is mid-gate, not stalled).
- Sweep 3 — **action taken**: found 2 live Godot processes while the runner had
  already released/moved past their tickets: PID 18188 (soak job 1245, only the
  Godot header written) and PID 7212 (diag job 1246). Killed both with targeted
  `taskkill /PID … /T /F` (NOT `doctor`, which would have killed the active job).
  Root cause: `godot_runner.py` launches the WinGet `godot.EXE` shim; on normal
  completion the shim exits but its real Godot child survives — the runner's
  `kill_tree` only runs on hard timeout (`godot_runner.py:366`). This is a real
  runner defect; add to P4-fix (post-job process-tree cleanup). I6 was also told
  to STOP re-running soaks — jobs 1239 and 1242 already ended `ok`, and a third
  was in flight. No reassignment of I4/I6.
- Sweep 2: I4/I6 reports still absent; runner `pending=1` (#1245 I6 soak re-run),
  one live Godot matching that job (expected, not orphan), lock fresh 14 s,
  history CLEAN. I4 diag2 revealed a FALSE-POSITIVE trap: `hits=50` at t=139
  coincided with `sow_t` reset 55.3→0.0 = the 60 s auto-sow timer, not the
  peasant's `cmd_resow`. Sent urgent test-only correction to I4 (zero sow_t,
  spawn at walkable work slot via `_snap_free_point`+`_work_slot`, latch within
  a <60 s window) and told it to stop guessing if this fails.
- 2026-11-24 automation sweep: 24/26 expected reports present (missing only
  `I04_test_split.md`, `I06_ai_metal_mines.md` — both builders still running).
  Runner `pending=2` (#1242 I6 soak, #1243 I4 diag2), lock HELD 170 s with one
  live Godot whose command matches the queued soak → expected in-flight job,
  **not** an orphan; clean gate DIRTY only for that live process. History CLEAN
  (4 acked). No reassignments.
- I4's diag stdout showed the peasant stuck in `resow` order ~3.4 m from the field
  (`I4RESOW t=20..80 hits=0`), never reaching `_work_slot` (game.gd:4358) — so
  the fix is test-side spawn placement, not just the latch. Hint sent to I4.

### Swarm launched (wave 1 recon — all read-only, no runner cost)
19 micro-agents, each owning exactly one report file under `reports/`:
- R1 farming/production, R2 capture/siege, R3 formations/squads, R4 combat/weapons,
  R5 hotkeys/controls, R6 AI, R7 economy/market, R8 roster/upgrades, R9 naval,
  R10 environment/seasons, R11 HUD/GUI, R12 new-micro sweep.
- P1 sim hot paths, P2 render hot paths, P3 assets/memory, P4 tooling/startup perf.
- T1 selftest subset taxonomy, T2 subset mechanism + existing small-test overlap,
  T3 per-step cost/dependency analysis (owner directive: split big tests into small
  logically meaningful fast sets).

Session ids are recorded in `CHARTER.md`. Wave 2 (implementation) is gated on these
reports + the fresh baseline result.
