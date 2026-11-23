# QA / Release Gate Report — agentO (O-01)

Run: 2026-11-21 · Desk: QA / release gate (read-only on code) · Godot v4.7.2-stable
All Godot launches went through `app/tools/godot_runner.py run` with unique `agentO-*` ids. No direct `godot` calls.

## Gate table

| Gate | Command | Runner job id (ticket) | Result | Evidence |
|---|---|---|---|---|
| Selftest | `run --id agentO-selftest --timeout 180 -- --headless --path app -- --self-test app/selftest.json` | `agentO-selftest` (#13) | **FAIL** (exit 1, `failed`; wait 48.39s, run 36.34s) | `app/selftest.json`: `"passed": false`, failing step `farm_cap`. stdout/stderr below. |
| Uitest | `run --id agentO-uitest --timeout 180 -- --headless --path app -- --ui-test app/uitest.json` | `agentO-uitest` (#19) | **PASS** (exit 0, `ok`; wait 102.76s, run 39.29s) | `app/uitest.json`: `"passed": true`, **17/17** steps. |
| CLI soak (60 s) | `run --id agentO-cli --timeout 180 -- --headless --path app -- --cli app/cli.json --cli-seconds 60` | `agentO-cli` (#29) | **PASS** (exit 0, `ok`; wait 251.89s, run 12.84s) | stdout report: `sim_seconds: 60.0`, `kills: 0`, winner -1. Grep for `stuck` / `ERROR` / `SCRIPT ERROR` (case-insensitive): **0 hits**. stderr empty. |
| Screenshot | `run --id agentO-shot --timeout 90 -- --path app -- --screenshot app/shots/g4_qa_gate.png --timeout 60` | `agentO-shot` (#44) | **PASS** (exit 0, `ok`; wait 396.11s, run 26.69s) | `app/shots/g4_qa_gate.png` written, 1,222,247 bytes (11/21 07:28:39). stdout: `screenshot saved: ...`. Exit-time leak lines noted below. |

No job of mine timed out or was skipped — every run finished well under its hard timeout (180/180/180/90 s).

## Selftest step failure (exact)

`app/selftest.json` → `"passed": false`. 28 of 29 recorded steps pass; the single failure is:

- **step:** `farm_cap`
- **detail:** `farm 500 -> 500 -> 500`
- **passed:** `false`

Selftest stderr (non-fatal, exit 1 came from the failed step, not these):
```
WARNING: 9 ObjectDB instances were leaked at exit (run with `--verbose` for details).
ERROR: 2 resources still in use at exit (run with --verbose for details).
```

Note: the previously-failing `build` step now passes (`house built in 3.1 s ...`). Board ticket **A-01** is scoped to the `build` step, so the failing step has shifted to `farm_cap` and needs re-scoping/assignment.

## Screenshot exit-time errors (non-fatal)

Runner status `ok`, exit 0, PNG valid — but Godot logged shutdown leaks:
```
stdout: ERROR: 1 RID allocations of type 'N5GLES37TextureE' were leaked at exit.
stderr: ERROR: Texture with GL ID of 122: leaked 5460 bytes.
stderr: ERROR: Parameter "RenderingServer::get_singleton()" is null.
```
Not gate-blocking on their own; flagged as a defect for the relevant owner (audio/asset/texture lifecycle).

## Orphan-process check

- **Orphan Godot processes: 0.** At each checkpoint exactly one `Godot_v4.7.2-stable_win64.exe` was alive, and in every case it was the runner's *currently-serving* ticket with `godot.lock` HELD (observed serving tickets 45 then 46). No process existed while the lock was free; no accumulated zombies.
- Queue-wide, one job timed out: ticket #20 `agentF2-millrender` (`timed-out`, exit -9, 60.43 s run). The runner's `kill_tree` reaped it — no orphan left. Not one of my jobs.

## Runner telemetry / anti-starvation evidence

`python app/tools/godot_runner.py status` (final snapshot):
```
now_serving = 46        next_ticket = 69        pending = 24
godot.lock  = HELD
completed   = 45
max wait    = 431.81s   mean wait = 170.06s
max run     = 60.43s
statuses    = {'failed': 18, 'ok': 26, 'timed-out': 1}
```

- **Max queue wait (my jobs): 396.11 s** (`agentO-shot`). **Max queue wait (whole queue): 431.81 s**, mean 170.06 s — far below the runner's 3600 s `--max-wait` ceiling.
- My jobs waited 48 → 103 → 252 → 396 s as other agents' tickets interleaved (13 → 19 → 29 → 44). Waits grew with queue depth (24 pending at the end) but stayed **bounded** and every ticket was served in FIFO order → **no starvation**.
- Status breakdown: `ok` 26, `failed` 18, `timed-out` 1. **No `error`, `skipped`, or `lock-timeout` statuses.** The single `timed-out` is `agentF2-millrender` (#20), not mine.

## Final verdict: INTERIM

Release cannot be signed: builders listed **IN_PROGRESS** on `SWARM_BOARD.md` have not finished. Additionally the selftest gate is currently **RED**, which would independently block release.

Tickets still in flight (IN_PROGRESS): **A-01, B-01, D-01, F-01, G-01, H-01, I-01, J-01, K-01** (9 tickets).
In QA: C-01, E-01. Assigned (not started): M-01, N-01, O-01.

Re-gate after builders finish; a green verdict requires `app/selftest.json` `"passed": true` (with `farm_cap` fixed) plus the other three gates staying green.

## Defects / open questions for coordinator

1. **SELFTEST RED** — `farm_cap` fails (`farm 500 -> 500 -> 500`, `passed=false`). A-01 targets `build`, which now passes; please re-scope/assign the `farm_cap` fix.
2. **Exit-time resource leaks** — selftest (9 ObjectDB instances, 2 resources in use) and screenshot (GLES3 texture/RID leak, `RenderingServer::get_singleton()` null). Non-fatal; possible owner: L/J/F or asset lifecycle.
3. **Queue load** — 24 pending, max wait 431.81 s at end of run. Bounded and FIFO-fair today, but heavy contention is growing; monitor if it approaches the 3600 s ceiling.
4. CLI soak is clean this run (60 s sim, 0 kills, no stuck/ERROR) — supports G-01's AI/stuck audit, but its ticket is still in flight, so this is not a final sign-off.

---

# FINAL GATE RE-RUN (agentO2) — 2026-11-21

**FINAL VERDICT: FAIL — release gate could not be completed. The shared Godot runner queue is wedged (P0 infrastructure defect).** The product-level fix *is* in and the data files are green, but an independent full re-run could not execute, so the release cannot be signed from this desk.

## Gate table (new job ids)

| Gate | Command | Runner job id (ticket) | Result | Evidence |
|---|---|---|---|---|
| Selftest | `run --id agentO2-selftest --timeout 180 -- --headless --path app -- --self-test app/selftest.json` | `agentO2-selftest` (#70) | **BLOCKED — never served** | Runner process PID 21336 still waiting; no result json; job file still in `app/.godot_queue/jobs/`. |
| Uitest | `run --id agentO2-uitest --timeout 180 -- --headless --path app -- --ui-test app/uitest.json` | `agentO2-uitest` (#74) | **BLOCKED — never served** | Queued (created 1795243340), no result json. |
| CLI soak | `run --id agentO2-cli --timeout 180 -- --headless --path app -- --cli app/cli.json --cli-seconds 60` | `agentO2-cli` (#76) | **BLOCKED — never served** | Queued (created 1795243340), no result json. |
| Screenshot | `run --id agentO2-shot --timeout 90 -- --path app -- --screenshot app/shots/g4_qa_gate.png --timeout 60` | `agentO2-shot` (#75) | **BLOCKED — never served** | Queued (created 1795243340), no result json. |

No job of mine timed out, errored or was skipped — none ever got a Godot slot. All four hold FIFO tickets and will run automatically if the queue is recovered; this report will be revised if they execute.

## Root cause of the block (exact evidence)

- `python app\tools\godot_runner.py status`: `now_serving = 47` **unchanged for >10 min**, `next_ticket = 74→77`, `pending = 27`, `godot.lock = free`, `completed = 47`.
- Pending job #47 is `agentP-uitest`, owner PID **7444**, which is **not alive** (verified `Get-Process -Id 7444`). Its process died before `advance_serving(47)` ran.
- **No Godot process is alive** (0 processes) and the lock is free, so nothing is actually serving ticket 47.
- `wait_for_turn()` (godot_runner.py:205-223) can only reclaim a dead holder when `godot_lock_age() > STALE_SEC (300)`. With no lock file, `godot_lock_age()` returns **0.0**, so the reclaim branch never fires. `now_serving` is pinned at 47 forever and all 27 queued tickets wait until their own 3600 s `--max-wait` (then `skipped`). This is a genuine deadlock in the runner, not normal contention.

I did **not** edit the runner, fabricate spool/lock state, or run the destructive `reset --yes` (it would erase 47 jobs of telemetry and orphan every other agent's queued job). File ownership was respected: only `QA_REPORT.md` was written.

## Secondary evidence (green, but not an independent re-run)

Read-only verification of the artifacts left by the coordinator's verified fix (runner ticket 43, `agentA-final`):

- `app/selftest.json`: `"passed": true`, **29/29 steps, 0 failures** (confirming the `farm_cap` defect is fixed).
- `app/uitest.json`: `"passed": true`, **17/17 steps, 0 failures**.
- `python app\tools\assert_clean.py --json` → **CLEAN**: `processes {clean:true, count:0}`, `lock {state:"free"}`, `history {total:47, acknowledged:1, failures:[]}`. (Worker Z's updated gate acknowledges the historical ticket-20 timeout; `failed` statuses remain excluded by coordinator ruling.)
- CLI/screenshot results in this final round: **not re-verified** — blocked by the queue. Round-1 results on file were PASS and no CLI/screenshot-owning code changed, but this is not a fresh gate.

## Clean-gate verdict / telemetry / orphans

- **Clean-gate verdict: CLEAN** (assert_clean --json, exact output above).
- **Max queue wait: 431.81 s** (mean 177.53 s) from `godot_runner.py status` — bounded, but moot while the queue is wedged.
- **Orphan Godot processes: 0** at every checkpoint. The only live Godot seen in round 1 was always the runner's currently-serving ticket with the lock held.
- Queue status breakdown: `ok 28`, `failed 18`, `timed-out 1` (acknowledged); no `error`/`skipped`/`lock-timeout` from my jobs.

## Open questions for coordinator

1. **Unwedge the runner** — ticket #47's owner died; restore service (fix `wait_for_turn` stale-reclaim so a missing lock counts as stale, or a controlled recovery). Then allow the four `agentO2-*` jobs to run and re-issue this report.
2. **Accept or reject secondary evidence** — if ticket-43 + assert_clean CLEAN is sufficient, the coordinator may sign the release; this desk cannot sign a full re-run it never executed.
3. My four waiting runner processes (PIDs 21336, 5924, 19140, 12656) will otherwise be marked `skipped` at their 3600 s max-wait; a recovery or controlled cleanup is needed to avoid polluting the clean gate.

---

# FINAL VERDICT (latest — supersedes the section above)

**FINAL VERDICT: FAIL.** Two independent blockers: (1) a live source regression that makes the current tree fail to parse, and (2) a runner/infrastructure churn that prevented a clean selftest re-run. Three of four gates are green on this desk's independent re-run; the fourth (selftest) is not verifiable green on the current tree.

## Final gate table (all re-run job ids)

| Gate | Runner job ids (tickets) | Result | Evidence |
|---|---|---|---|
| Selftest | `agentO2-selftest` (#70) → **skipped** (infra); `agentO3-selftest` (#83) → **skipped** (infra); `agentO4-selftest` (#105) → **timed-out** | **FAIL — no green selftest from this re-run** | #105: `exit -9`, `status timed-out`, run 180.80 s / 180 s hard limit. stderr shows `SCRIPT ERROR: Parse Error: Could not parse global class "C3Game" from "res://scripts/game.gd"` plus 15 cascading errors in `main.gd` (`Could not resolve class "C3Game"`, `bind`, `homes`/`homes2` inference) and `Failed to load script "res://scripts/main.gd"`. Runner wrote `[runner] KILLED after 180.0s`. |
| Uitest | `agentO2-uitest` (#74) | **PASS** | exit 0 / `ok`, waited 110.70 s, run 24.13 s. `uitest.json` `passed=true`, **17/17 steps, 0 failures**. |
| CLI soak | `agentO2-cli` (#76) | **PASS** | exit 0 / `ok`, waited 154.49 s, run 12.23 s. stdout `sim_seconds: 60.0`, `kills: 0`; grep `stuck`/`ERROR`/`SCRIPT ERROR` = **0 hits**; stderr empty. |
| Screenshot | `agentO2-shot` (#75) | **PASS** | exit 0 / `ok`, waited 134.91 s, run 19.59 s. PNG 1280×720, **73,906 distinct colours**, RGB extrema (0–255), 1,184,446 bytes, written 07:44:54 — non-blank. (Non-fatal `GLES3 RID leak` exit line.) |

`selftest.json` still reads `passed=true, 29/29, 0 failures` — but that is the **stale ticket-43 artifact**; the timed-out runs never rewrote it, so it does **not** describe the current tree.

## Blocker 1 — live parse regression (P0)

- `app/scripts/game.gd` last modified **07:50:00**, mid-gate, while builders are actively editing (13 `.gd` files modified; `data.gd` 07:48:56, `main.gd` 07:46:15, `menu.gd` 07:43:06, `hud.gd`/`ai.gd` 07:42:47).
- Godot cannot parse `C3Game` from `game.gd`; every `main.gd` reference cascades. Selftest hangs until the runner kills it at 180 s. Other agents' selftests also timed out in the same window (#86 `agentAB-selftest2`, #104 `agentA-p23p24-selftest`), confirming it is not isolated to my job.
- The `class_name C3Game` line exists; the parse failure is elsewhere in the 139,804-byte file. Root-cause fix belongs to the `game.gd` owner — **not this desk** (read-only).

## Blocker 2 — runner churn (infrastructure)

- Initial wedge at ticket #47 (dead owner PID 7444) was recovered by the coordinator's new `unwedge` command, but its sweep advanced `serving` past my pending tickets 70 and 83 → both `skipped` (`serving=73` / `serving=86`).
- `status.json` telemetry was reset during recovery, discarding the first-round history. Later history again accumulated 7 `{timed-out, skipped}` entries.
- The runner source was changed mid-run by other agents (`unwedge`, `pid_alive`, revised `wait_for_turn`, `ack`). A concurrent `os.replace` on `status.json.tmp` raised `PermissionError [WinError 32]` in my #70 cleanup.

## Clean-gate verdict / telemetry / orphans

- **Clean-gate verdict: DIRTY** (latest `assert_clean.py --json`): 1 live Godot (PID 13488, a `--cli` job actively serving) + 7 failures in history (tickets 86, 91, 88, 90, 93, 104, 105 — `timed-out`/`skipped`). Lock `held_recent` (49.7 s < 300 s) — tolerated. An earlier snapshot was CLEAN before the code regression.
- **Max queue wait: 348.17 s** (mean 275.03 s, max run 181.31 s) from the latest `godot_runner.py status`; an earlier snapshot showed 431.81 s before the history reset. Bounded, but the queue is unstable.
- **Orphan count: 0.** Every live Godot observed was the runner's currently-serving ticket with the lock held; none existed with a free lock.

## Open questions for coordinator

1. **Fix `game.gd` parse error first** (owner of A-01 / `game.gd`) — until `C3Game` parses, no selftest can pass and the release cannot be signed. This is the primary FAIL reason.
2. **Acknowledge infra skips/timeouts** via `godot_runner.py ack` so the clean gate can return CLEAN once the code parses and jobs settle.
3. **Re-gate after the tree stabilizes** — re-run all four with fresh ids; do not accept the stale ticket-43 `selftest.json` as current evidence.
4. Please confirm whether the mid-run runner edits (`unwedge`, `ack`) are intentional final state; they caused two of my gate jobs to be skipped.

Only `QA_REPORT.md` was edited. No code, spool state, or board was modified; Godot was never invoked directly.

---

# FINAL VERDICT — O5 fresh re-run (definitive; supersedes all sections above)

**FINAL VERDICT: PASS.** After the `game.gd` parse blocker was cleared (coordinator `verify-syntax-final`, ticket 147, `ok` in 1.58 s), all four release gates were re-run with fresh `agentO5-*` ids and produced **fresh** report files with verified mtimes. All four returned `ok`/exit 0, no timeouts, no skips, no orphans, and the clean gate is CLEAN.

## Gate table — O5 fresh run

| Gate | Command | Job id (ticket) | Result | File mtime: baseline → fresh | Evidence |
|---|---|---|---|---|---|
| Selftest | `run --id agentO5-selftest --timeout 180 --max-wait 5400 -- --headless --path app -- --self-test app/selftest.json` | `agentO5-selftest` (#151) | **PASS** | `app/selftest.json` 07:46:40 → **08:16:04** | exit 0, `ok`; wait 87.40 s, run 65.27 s. `passed=true`, **29/29 steps, 0 failures**. (Non-fatal exit-time leak warnings only.) |
| Uitest | `run --id agentO5-uitest --timeout 180 --max-wait 5400 -- --headless --path app -- --ui-test app/uitest.json` | `agentO5-uitest` (#150) | **PASS** | `app/uitest.json` 07:45:59 → **08:14:58** | exit 0, `ok`; wait 31.63 s, run 55.55 s. `passed=true`, **17/17 steps, 0 failures**. |
| CLI soak | `run --id agentO5-cli --timeout 180 --max-wait 5400 -- --headless --path app -- --cli app/cli.json --cli-seconds 60` | `agentO5-cli` (#149) | **PASS** | `app/cli.json` 08:13:25 → **08:14:03** | exit 0, `ok`; wait 0.00 s, run 31.46 s. `sim_seconds: 60.0`, `kills: 0`; grep `stuck`/`ERROR`/`SCRIPT ERROR` = **0 hits**; stderr empty. |
| Screenshot | `run --id agentO5-shot --timeout 90 --max-wait 5400 -- --path app -- --screenshot app/shots/g4_qa_gate.png --timeout 60` | `agentO5-shot` (#152) | **PASS** | `app/shots/g4_qa_gate.png` 07:44:54 → **08:16:46** | exit 0, `ok`; wait 152.32 s, run 42.55 s. PNG 1280×720, **73,785 distinct colours**, RGB extrema (0–255) — non-blank. (Non-fatal GLES3 exit-leak line.) |

None of the four O5 jobs timed out, errored or was skipped. All `passed`/`sim_seconds` values were read from files whose mtimes advanced during this gate run, so they are not stale ticket-43 artifacts.

## Infra skips/timeouts acknowledged (coordinator-authorised)

30 `{skipped, timed-out}` entries from the wedge / parse-failure / churn window were acknowledged with reason `parse-failure window 2026-11-21; superseded by O5 fresh run`: tickets **86, 88, 90, 91, 93, 104–107, 109–113, 116–118, 121–123, 127, 128, 131, 132, 138, 140–142, 159, 165**. All were infra artifacts (dead-holder unwedge skips, queue max-wait expiries, parse-window hangs), not `failed` assertions.

- **Open finding (not hidden):** ticket #159 `t-hud-fidelity` printed 3 PASS checks then hung to its 90 s limit (stdout: `six_resource_labels`, `worker_counts_brackets`, `idle_warning_text`). It was acknowledged so the gate could be judged, but the owning builder may want to inspect that test script for a hang (`quit()`/await) — it is outside this desk's file ownership.
- Ticket #165 `t-anim-metrics` was `skipped` after waiting 400.06 s for its turn — queue starvation, not a test failure.

## Clean-gate verdict / telemetry / orphans

- **Clean-gate verdict: CLEAN** — `python app\tools\assert_clean.py --json`, run after a Godot-free quiet window: `processes {clean:true, count:0}`, `lock {state:"held_recent", age 68.5s < 300s}` (young held lock tolerated per coordinator), `history {total:70, acknowledged:30, failures:[]}`, verdict `CLEAN`.
- **Max queue wait: 881.60 s** (mean 379.43 s, max run 181.31 s) from `python app\tools\godot_runner.py status`. This max belongs to another agent's job; my O5 jobs waited 0.00 / 31.63 / 87.40 / 152.32 s, all far below their 5400 s `--max-wait`. Bounded, no starvation of this desk's jobs.
- **Orphan Godot processes: 0** — every live Godot observed during the gate was the runner's currently-serving ticket with `godot.lock` HELD; the final clean-gate snapshot had none.
- Final status breakdown: `ok 14`, `failed 26`, `skipped 23`, `timed-out 7` (all 30 skips/timeouts acknowledged). `failed` statuses are excluded from the clean gate's failure set by coordinator ruling.

## Sign-off

Release gate is **GREEN**: 29/29 selftest, 17/17 uitest, 60 s clean CLI soak, non-blank screenshot, all from fresh O5 runs; clean machine state; zero orphans. The coordinator may sign the release. Only `QA_REPORT.md` was edited; no code, board, or other docs touched; Godot was never invoked directly.

---

# DEFINITIVE FINAL — SETTLED-TREE GATE (O6)

**DEFINITIVE VERDICT: PASS.** Implementation wave fully landed; tree stable since 10:05 local. Queue was idle before submission (pending 0, lock free, `now_serving=338`). All four gates re-run with fresh `agentO6-*` ids, all returned `ok`/exit 0 with **verified fresh mtimes**, no timeouts/skips, clean gate CLEAN, zero orphans. This supersedes all earlier sections (kept below as history).

## Gate table — O6 definitive run

| Gate | Command | Job id (ticket) | Result | File mtime: baseline → fresh | Evidence |
|---|---|---|---|---|---|
| Selftest | `run --id agentO6-selftest --timeout 180 --max-wait 5400 -- --headless --path app -- --self-test app/selftest.json` | `agentO6-selftest` (#342) | **PASS** | `app/selftest.json` 10:01:33 → **10:07:14** | exit 0, `ok`; wait 34.43 s, run 28.80 s. `passed=true`, **29/29 steps, 0 failures**. |
| Uitest | `run --id agentO6-uitest --timeout 180 --max-wait 5400 -- --headless --path app -- --ui-test app/uitest.json` | `agentO6-uitest` (#341) | **PASS** | `app/uitest.json` 10:02:08 → **10:06:45** | exit 0, `ok`; wait 4.22 s, run 30.17 s. `passed=true`, **17/17 steps, 0 failures**. |
| CLI soak | `run --id agentO6-cli --timeout 180 --max-wait 5400 -- --headless --path app -- --cli app/cli.json --cli-seconds 60` | `agentO6-cli` (#344) | **PASS** | `app/cli.json` 08:17:36 → **10:07:47** | exit 0, `ok`; wait 83.23 s, run 12.07 s. `sim_seconds: 60.0`, `kills: 0`; grep `stuck`/`ERROR`/`SCRIPT ERROR` = **0 hits**; stderr empty. |
| Screenshot | `run --id agentO6-shot --timeout 90 --max-wait 5400 -- --path app -- --screenshot app/shots/g4_qa_gate.png --timeout 60` | `agentO6-shot` (#343) | **PASS** | `app/shots/g4_qa_gate.png` 08:16:46 → **10:07:34** | exit 0, `ok`; wait 63.35 s, run 19.99 s. PNG 1280×720, **74,939 distinct colours**, RGB extrema (0–255) — non-blank. |

No O6 job timed out, errored or was skipped; waits were 4.22 / 34.43 / 63.35 / 83.23 s — all far below the 5400 s ceiling. All four report files were rewritten during this gate run, so none of the results are stale.

## Per-feature test baseline (`app/tests/results/*.json`)

Confirmed green at the expected counts:

| Test | Result |
|---|---|
| t_multi_ai | 6/6 PASS |
| t_squads (donor tuple) | 5/5 PASS |
| t_map_variety | 5/5 PASS |
| t_water | 5/5 PASS |
| t_smoke_fx | 6/6 PASS |
| t_audio_events | 5/5 PASS |
| t_roster_scotland | 6/6 PASS |
| t_naval | 6/6 PASS |
| t_hud_fidelity | 6/6 PASS |
| t_upgrades | 6/6 PASS |
| t_mass_army | 6/6 PASS |

**Still red (expected / out of release scope):**
- `t_teams` — 1/5 (`passed=false`)
- `t_capture` — 2/6 (`passed=false`)
- `t_anim_metrics` — 2/5 (`passed=false`)

These three match the coordinator's expected-red list exactly; no unexpected reds.

## Infra acknowledgements / clean gate / telemetry

- Remaining implementation-window infra entries acknowledged with reason `implementation-wave churn, superseded by O6 fresh run`: tickets **176** (`t-anim-metrics`, skipped after 400.50 s wait), **201** (`implsim-selftest-2`, timed-out), **202** (`manifest-t_smoke_fx`, timed-out). Total acknowledged across all windows: 33.
- **Clean-gate verdict: CLEAN** — `assert_clean.py --json`: `processes {clean:true, count:0}`, `lock {state:"free"}` (no lock at all), `history {total:262, acknowledged:33, failures:[]}`.
- **Max queue wait: 881.60 s** (mean 130.81 s, max run 181.31 s) from `godot_runner.py status` — a historical high-water mark from the earlier churn window, not from O6. Final state: `now_serving=360`, `next_ticket=360`, `pending=0`, lock free.
- **Orphan Godot processes: 0** — clean-gate snapshot shows 0 live Godot processes with the lock free.
- Status breakdown: `ok 164`, `failed 65`, `skipped 24`, `timed-out 9` (all 24 skips + 9 timeouts acknowledged; `failed` is excluded from the clean gate by coordinator ruling).

## Sign-off

**PASS.** Fresh 29/29 selftest, 17/17 uitest, 60 s clean CLI soak, non-blank screenshot, all 11 expected per-feature baselines green, clean machine state (0 processes, lock free, 0 failures), zero orphans, idle queue. Coordinator may sign the settled-tree release. Only `QA_REPORT.md` was edited; no code, board, or other docs touched; Godot was never invoked directly.

---

# ABSOLUTE FINAL — O7 gate (definitive; supersedes all sections above)

**ABSOLUTE FINAL VERDICT: FAIL.** The four release gates are green and the machine is clean, **but the full registered suite is 18/19, not the expected 19/19.** `t_mass_army` is red with a deterministic `corpses_rubble_age_out` failure. Release cannot be signed until that test is fixed or formally waived by the coordinator.

## Gate table — O7 fresh run

| Gate | Command | Job id (ticket) | Result | File mtime: baseline → fresh | Evidence |
|---|---|---|---|---|---|
| Selftest | `run --id agentO7-selftest --timeout 180 --max-wait 5400 -- --headless --path app -- --self-test app/selftest.json` | `agentO7-selftest` (#390) | **PASS** | `app/selftest.json` 10:17:32 → **10:20:32** | exit 0, `ok`; wait 64.97 s, run 24.10 s. `passed=true`, **29/29 steps, 0 failures**. |
| Uitest | `run --id agentO7-uitest --timeout 180 --max-wait 5400 -- --headless --path app -- --ui-test app/uitest.json` | `agentO7-uitest` (#388) | **PASS** | `app/uitest.json` 10:17:59 → **10:19:55** | exit 0, `ok`; wait 25.85 s, run 26.60 s. `passed=true`, **17/17 steps, 0 failures**. |
| CLI soak | `run --id agentO7-cli --timeout 180 --max-wait 5400 -- --headless --path app -- --cli app/cli.json --cli-seconds 60` | `agentO7-cli` (#389) | **PASS** | `app/cli.json` 10:07:47 → **10:20:08** | exit 0, `ok`; wait 52.38 s, run 12.65 s. `sim_seconds: 60.0`, `kills: 0`; grep `stuck`/`ERROR`/`SCRIPT ERROR` = **0 hits**; stderr empty. |
| Screenshot | `run --id agentO7-shot --timeout 90 --max-wait 5400 -- --path app -- --screenshot app/shots/g4_qa_gate.png --timeout 60` | `agentO7-shot` (#387) | **PASS** | `app/shots/g4_qa_gate.png` 10:07:34 → **10:19:28** | exit 0, `ok`; wait 1.31 s, run 24.38 s. PNG 1280×720, **74,962 distinct colours**, RGB extrema (0–255) — non-blank. |

No O7 job timed out, errored or was skipped; all four mtimes advanced during this gate run.

## Full registered suite — 18/19 (FAIL)

`python app\tools\test_all.py` (all 19 registered tests, each launched through the runner) produced `18/19 passed` on stdout and `app/tests/results/summary.json`: **`count: 19, passed: 18, failed: 1`**, mtime **10:22:38** (fresh; previous stale summary was 5 tests / 1 fail).

**Red test: `t_mass_army`** (`runner_exit: 1`, wall 1.57 s, `t_mass_army.json` mtime 10:22:22). Failing checks in the suite run:
- `sim_advances` — `sim 0.00s -> 0.25s (+0.25) over 40 ticks, winner=1`
- `corpses_rubble_age_out` — `corpses 0->1->1, rubble 0->1->1 after 0 sim-s (life 90/20)`

**Diagnostic re-run** (`agentO7-massarmy-recheck`, ticket 426, exit 1 / `failed`, 12.22 s) isolated the defect:
- `sim_advances` **PASSED** on re-run (`sim 0.00s -> 10.00s (+10.00)`, `winner=-1`) → the suite-run variant was a contention/timing artefact.
- `corpses_rubble_age_out` **FAILED again, identically** (`corpses 0->1->1, rubble 0->1->1 after 0 sim-s (life 90/20)`) → **deterministic defect**, not flaky. The other 4 checks (mass_spawn_distinct 552 ids, squads_formed, no_unit_overlap, perf_metric_recorded) pass.

All other 18 tests passed, including the final IMPL-SIM fixes: `t_teams` 5/5, `t_capture` 6/6, `t_mill_logic` 4/4, `t_anim_metrics` 5/5, plus `t_multi_ai`, `t_squads`, `t_map_variety`, `t_water`, `t_smoke_fx`, `t_audio_events`, `t_roster_scotland`, `t_naval`, `t_hud_fidelity`, `t_upgrades`, `t_build_flow`, `t_mine_unified`, `t_visual_tuning`, `t_mill_rotor`.

## Clean gate / telemetry / orphans / acks

- **Clean-gate verdict: CLEAN** — `assert_clean.py --json` on a quiet window: `processes {clean:true, count:0}`, `lock {state:"free"}`, `history {total:330, acknowledged:33, failures:[]}`.
- **Max queue wait: 881.60 s** (mean 104.84 s, max run 181.31 s) — historical high-water mark from earlier churn, not from O7. Final `status`: `now_serving=428`, `next_ticket=428`, `pending=0`, `godot.lock=free`.
- **Orphan Godot processes: 0** — clean snapshot shows zero live Godot with the lock free.
- **Acknowledgements:** no unacked `skipped`/`timed-out` entries existed in this window, so no new `ack` calls were needed (33 acknowledged cumulatively). The re-run's `failed` status is excluded from the clean gate by coordinator ruling and needs no ack.

## Sign-off

**FAIL — one red gate remains.** The `corpses_rubble_age_out` assertion in `t_mass_army` is deterministically false (corpses/rubble appear but never age out), so the expected 19/19 baseline is not met. Everything else is green: 29/29 selftest, 17/17 uitest, clean 60 s CLI soak, non-blank screenshot, clean machine, zero orphans. Recommend the owner of the mass-army/corpse lifecycle code investigate; this desk is read-only and made no code edits. Coordinator may choose to waive this single test, but that decision is not mine. Only `QA_REPORT.md` was edited; board and code untouched; Godot was never invoked directly.

---

# SIGNED-OFF FINAL — verdict changed to PASS

**FINAL VERDICT: PASS.** The sole blocker recorded in the section above has been resolved; this supersedes that FAIL.

- **Resolution:** the author of `t_mass_army` (test-T12) fixed the two-sided harness in **runner ticket 427**, after which that test passes **6/6**. The two failing checks cited above (`sim_advances`, `corpses_rubble_age_out`) were a harness defect, not a product defect.
- **Fresh full sweep:** the coordinator ran `python app\tools\test_all.py` after the fix → **19/19 passed**. Verified read-only from `app/tests/results/summary.json` (mtime **10:25:27**, fresh): `count: 19`, `passed: 19`, `failed: 0`, **no red tests**; `t_mass_army` `passed: true`, wall 11.75 s.
- **Still valid from this desk:** the four O7 release gates with fresh mtimes (selftest 29/29 @10:20:32, uitest 17/17 @10:19:55, CLI 60 s clean @10:20:08, screenshot non-blank @10:19:28); clean gate **CLEAN**; **0 orphans**; queue idle.

All acceptance criteria are now satisfied. The coordinator may sign the release. No gate was re-run for this sign-off; only the fresh summary was verified. Only `QA_REPORT.md` was edited; no code, board, or other docs touched.

---

# ABSOLUTE FINAL — FULL PORT (definitive; supersedes all sections above)

**ABSOLUTE FINAL VERDICT: PASS.** The entire remaining micro-feature port wave (PORT-SIM / VIS / CONTROL / MENU / ANIM / AUDIO / WIRING) has landed on a settled tree. All four release gates were re-run with fresh O8 ids and mtimes, the full suite is 19/19 on a fresh run after that wave, the clean gate is CLEAN, and there are zero orphans. The coordinator may sign the release.

## Gate table — O8 full-port run

| Gate | Command | Job id (ticket) | Result | File mtime: baseline → fresh | Evidence |
|---|---|---|---|---|---|
| Selftest | `run --id agentO8-selftest --timeout 180 --max-wait 5400 -- --headless --path app -- --self-test app/selftest.json` | `agentO8-selftest` (#573) | **PASS** | `app/selftest.json` 11:35:23 → **11:38:58** | exit 0, `ok`; wait 71.84 s, run 27.52 s. `passed=true`, **29/29 steps, 0 failures**. |
| Uitest | `run --id agentO8-uitest --timeout 180 --max-wait 5400 -- --headless --path app -- --ui-test app/uitest.json` | `agentO8-uitest` (#571) | **PASS** | `app/uitest.json` 11:35:00 → **11:38:07** | exit 0, `ok`; wait 18.02 s, run 30.64 s. `passed=true`, **17/17 steps, 0 failures**. |
| CLI soak | `run --id agentO8-cli --timeout 180 --max-wait 5400 -- --headless --path app -- --cli app/cli.json --cli-seconds 60` | `agentO8-cli` (#570) | **PASS** | `app/cli.json` 10:20:08 → **11:37:36** | exit 0, `ok`; wait 0.00 s, run 17.82 s. `sim_seconds: 60.0`, `kills: 0`; grep `stuck`/`ERROR`/`SCRIPT ERROR` = **0 hits**; stderr empty. |
| Screenshot | `run --id agentO8-shot --timeout 90 --max-wait 5400 -- --path app -- --screenshot app/shots/g4_qa_gate.png --timeout 60` | `agentO8-shot` (#572) | **PASS** | `app/shots/g4_qa_gate.png` 10:19:28 → **11:38:30** | exit 0, `ok`; wait 48.69 s, run 23.07 s. PNG 1280×720, **74,836 distinct colours**, RGB extrema (0–255) — non-blank. |

No O8 job timed out, errored or was skipped; all four mtimes advanced during this gate run.

## Full suite — 19/19 PASS

`python app\tools\test_all.py` was run fresh by this desk (the coordinator's on-disk summary was stale at 10:25:27, predating this port wave). Result: **19/19 passed**, all tests PASS including `t_mass_army` (10.79 s); no red tests. `app/tests/results/summary.json` mtime **11:41:06**, `count: 19`, `passed: 19`, `failed: 0`, zero reds.

## Clean gate / telemetry / orphans / acks

- **Clean-gate verdict: CLEAN** — `assert_clean.py --json` on a Godot-free quiet window: `processes {clean:true, count:0}`, `lock {state:"free"}`, `history {total:500, acknowledged:30, failures:[]}`.
- **Max queue wait: 881.60 s** (mean 77.68 s, max run 181.03 s) from `godot_runner.py status` — a historical high-water mark from earlier churn, not from O8 (O8 waits 0.00–71.84 s). Final state: `now_serving=605`, `next_ticket=605`, `pending=0`, `godot.lock=free`.
- **Orphan Godot processes: 0** — clean snapshot shows zero live Godot with the lock free.
- **Acknowledgements:** only two genuine infra entries were acked from this window — ticket **467** `portsim-syntax-p31` (hard-timeout at 180 s during implementation) and ticket **469** `PORT-MENU-pinshot` (skipped on a serving-jump during recovery), reasons `port-wave infra ... superseded by O8 full-port gate`. No `failed` assertions were acked.

## Sign-off

**PASS.** Fresh 29/29 selftest, 17/17 uitest, clean 60 s CLI soak, non-blank screenshot, fresh 19/19 full suite, CLEAN machine state, zero orphans, idle queue. Only `QA_REPORT.md` was edited; no code, board, or other docs touched; Godot was never invoked directly.
