---
id: GATE-FAIL-01
owner: GATE-FAIL-01 read-only debugging subagent
date: 2026-11-25
status: diagnosed
scope: "READ-ONLY repo/file inspection. NO runner-state mutation performed (no cancel/reset/unwedge/ack/doctor, no probe submitted). No test weakening, no game-code change, no visual-parity claim."
verdict: queue/harness race (mutual-exclusion failure), not a shared-file parse error and not a main.gd early exit
---

# GATE-FAIL-01 — why recent variant selftest/uitest jobs exit 1 with banner-only stdout

## Sources (all read directly, read-only)

| Source | What it establishes |
|---|---|
| `variant3d/tools/godot_runner.py` | Ticket allocation, FIFO wait/skip logic, lock lifecycle, cross-reap, result recording |
| `variant3d/scripts/main.gd` | `--self-test` / `--ui-test` startup path, arg parsing, early-exit paths |
| `variant3d/.godot_queue/results/<ticket>.json` (tickets 440–500) | Status/exit/wait/run/argv for each job |
| `variant3d/.godot_queue/results/<ticket>_<id>/stdout.txt`, `stderr.txt` | Exact output signature of failures |
| `variant3d/.godot_queue/{now_serving,counter,godot.lock,status.json}` | Live queue state (`godot_runner.py status`) |
| File mtimes of `variant3d/selftest.json`, `variant3d/uitest.json`, `variant3d/config.json` | Which jobs actually wrote the shared report files |
| `git status --short`, `git log`, `git diff --stat` | Concurrent edits to shared test scripts |
| `docs/coord_swarm_2026-11-25/reports/MAPSIZE_01.md` | Originating ticket: both gates failed, change reverted |

**No queue mutation performed by this worker.** The only runner command executed was the read-only `python variant3d/tools/godot_runner.py status`. No `run`, `cancel`, `reset`, `unwedge`, `ack`, or `doctor` was issued.

## Artifact table (target tickets)

Run windows are derived from each result JSON as `start = created + wait`, `end = start + run`.

| Ticket | Job id | status | exit | wait (s) | run (s) | run window | stdout | stderr | Report file written? |
|---:|---|---|---:|---:|---:|---|---:|---:|---|
| 452 | qaparity01-uitest | **skipped** | null | 1755.9 | 0 | none | missing | missing | no (`uitest.json` untouched) |
| 453 | qaparity01-selftest | **skipped** | null | 1755.9 | 0 | none | missing | missing | no |
| 457 | sp06-sun-smoke | **skipped** | null | 1632.1 | 0 | none | missing | missing | n/a |
| 455 | mapsize01-selftest | **failed** | 1 | 1682.7 | 38.4 | 11:21:17–11:21:56 | **75 B, banner only** | **0 B** | no |
| 461 | mapsmall01-selftest-240-r7 | **failed** | 1 | 1388.2 | 25.6 | 11:21:18–11:21:44 | **75 B, banner only** | **0 B** | no |
| 481 | minimapquad01-boot2 | **failed** | 1 | 64.7 | 88.6 | 11:23:29–11:24:58 | **75 B, banner only** | **0 B** | no |
| 482 | mapsize01-uitest | **failed** | 1 | 96.5 | 35.4 | 11:24:22–11:24:57 | **75 B, banner only** | **0 B** | no |
| 485 | mapsmall01-json-selftest | failed | 1 | 117.7 | 176.5 | 11:25:15–11:28:11 | 906 B (TMCORE line) | 3848 B (warnings) | **yes — `selftest.json` mtime 11:28:11** |

Exact banner bytes (identical for 455/461/481/482):
`b'Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org\r\n\r\n'`

Report-file mtimes: `variant3d/selftest.json` = **11:28:11** (ticket 485), `variant3d/uitest.json` = **10:51:54** (ticket 440), `variant3d/config.json` = 11:09:56. Neither 455 (11:21) nor 482 (11:24) falls in either report mtime window — both jobs died before the report-writing phase. This confirms the evidence statement "no `selftest.json`/`uitest.json` update".

### Skip evidence (explicit, not inferred)

`wait_for_turn` errors recorded in result JSONs, all clustered at **11:21:16–11:21:25**:

```
ticket 448 was skipped (serving=464)      ticket 457 was skipped (serving=458)
ticket 450 was skipped (serving=461)      ticket 458 was skipped (serving=461)
ticket 452 was skipped (serving=461)      ticket 462 was skipped (serving=475)
ticket 453 was skipped (serving=461)      ticket 465 was skipped (serving=475)
ticket 454 was skipped (serving=465)      ticket 466 was skipped (serving=467)
ticket 456 was skipped (serving=461)      ticket 468..473 skipped (serving=475)
```

Plus two `waited > 1800s/600s` timeouts (449, 451). Serving **raced ahead** of these tickets; it did not go stale. This rules out the "stale `now_serving`" hypothesis for 452/453/457 — they were overtaken, not pinned.

### Concurrency evidence — mutual exclusion was broken

Overlapping run windows (>2 s) computed from result JSONs. The runner's own design promise (`godot_runner.py:8-16`) is "exactly one Godot at a time"; these overlaps contradict it:

```
455(failed) & 461(failed) overlap 25.6s   481(failed) & 482(failed) overlap 35.4s
455(failed) & 464(ok)     overlap 17.1s   477(ok)     & 481(failed) overlap 75.9s
455(failed) & 475(ok)     overlap 13.1s   489(failed) & 490(failed) overlap 11.8s
461(failed) & 464(ok)     overlap 17.1s   494(timeout)& 497(failed) overlap 11.9s
477(ok)     & 482(failed) overlap 23.5s   494(timeout)& 498(failed) overlap 107.2s
```

Every banner-only GATE-FAIL-01 job (455, 461, 481, 482) ran concurrently with at least one other Godot job. Serialized windows before the wedge (440–445) and after (486–488, 491, 493, 495, 496, 499) were predominantly green.

`godot_runner.py status` (read-only, at time of inspection):
```
now_serving = 500 ; next_ticket = 505 ; pending = 5 [500..504]
godot.lock = HELD (age 146.4s)
completed = 489 ; max wait = 1825.52s ; mean wait = 107.90s ; max run = 605.56s
statuses = {'failed': 152, 'ok': 298, 'skipped': 16, 'timed-out': 23}
```
Queue was still actively in use by other agents during this investigation (serving advanced from ~497 to 500, and 500→505, between calls). That is why no probe was submitted — see Open questions.

## Code trace

### `variant3d/tools/godot_runner.py`

* `take_ticket` **L115–129** — monotonic ticket under `spinner_lock`, writes job JSON containing the submitting process `pid` (`L126`).
* `wait_for_turn` **L305–343**:
  * **L311–312** `max_wait` → `TimeoutError`.
  * **L313–315** `serving == ticket` → return.
  * **L316–317** `serving > ticket` → `RuntimeError(f"ticket {ticket} was skipped (serving={serving})")`. This is the exact error string on 452/453/457.
  * **L322–337** dead-holder / stale-lock reclaim. `dead_holder = holder is None or (holder_pid != 0 and not holder_alive)`; `lock_stale = godot_lock_age() > STALE_SEC` (`STALE_SEC = 300`, **L54**). The branch `if dead_holder or (lock_stale and not lock_free)` calls `release_godot_lock()` and `advance_serving(serving)` — it does **not** verify that the lock's owning job is still alive, so a long-running (≥300 s) but healthy holder can have its lock released from under it. `max run = 605.56s` in status shows such jobs exist.
* `advance_serving` **L170–175** — advances only when `read_int(SERVING) == expected`, but it is called in **every** job's `finally` (**L422**) and in `wait_for_turn` reclaim (**L340**) and `unwedge` (**L297**). With overlapping jobs, serving and cleanup can interleave.
* `cmd_run` **L349–437** — `take_ticket` (**L355**), create out dir / stdout / stderr (**L357–360**), `wait_for_turn` (**L377**) with skip path writing `status="skipped"`, `exit=None` and returning 3 (**L378–382**), `pids_before = godot_pids()` (**L397**), `Popen` (**L401**), `status = "ok" if code == 0 else "failed"` (**L405**), process-tree kill on hard timeout (**L406–412**).
* `cmd_run finally` **L415–433** — `release_godot_lock()` (**L417**), `advance_serving(ticket)` (**L422**), `reap_spawned_godot(pids_before)` (**L424**). 
* `godot_pids` **L224–241** and `reap_spawned_godot` **L243–253** — kills every Godot PID **not present in the snapshot taken at L397**. When two jobs overlap, the later-started job's PID is absent from the earlier job's snapshot, so the earlier job's cleanup kills the later job's Godot child (`taskkill /PID … /T /F`, **L248–249**). A process killed this way on Windows presents exit code 1 with only already-flushed stdout (the engine banner) and empty stderr — the exact 455/461/481/482 signature.
* `cmd_run` **L435–437** — `END failed` and `return 1` for any non-zero Godot exit. Hence a cross-killed job is indistinguishable from a genuine test failure at the gate level.
* `unwedge` **L275–302** and `cmd_doctor` **L464–490** are other agents' available mechanisms that can also advance serving or kill all Godot processes with the same observable effect.

### `variant3d/scripts/main.gd`

* `_ready` **L168–172** parses **both** `OS.get_cmdline_args()` and `OS.get_cmdline_user_args()`, so the runner's `-- --self-test …` / `-- --ui-test …` form is handled correctly.
* `_parse_args` **L1226–1340**: `--self-test` → `selftest_path` (**L1243–1246**), `--ui-test` → `uitest_path` (**L1263–1266**), `--timeout` → `limit_s` (**L1303–1306**), unknown tokens skipped (**L1337–1339**). No silent exit.
* `_ready` **L205–211** installs the watchdog for selftest/uitest; **L229–244** calls `_setup_full_game()` directly for these modes (no menu wait).
* Early exits are all explicit and preceded by output: `dump_config` **L193–197**, cli **L213–215**, dump-map **L217–219**, self-base dump/check **L221–227**; `_quit` **L1348–1350** uses `get_tree().quit(code)`.
* `_setup_full_game` **L1046–1150** builds map/world/camera/HUD/input; selftest baseline captured at **L1068–1069**.

**Conclusion from the code trace:** there is no path in `main.gd` that parses these two flags and then exits 1 while printing only the engine banner and writing no report. A genuine selftest/uitest failure would produce report output and a report file (cf. ticket 485). Therefore the banner-only jobs never completed Godot startup — the failure is upstream in the launch/lock/kill harness.

### Parse errors are real, but a different failure class

`stderr` of tickets 484, 492, 497 contains explicit `SCRIPT ERROR: Parse Error` for `res://tests/t_season_overlay.gd` and `res://tests/t_terrain_mines.gd`; `git status` shows those test scripts are concurrently modified, and commit `d1fb9e58` (11:30:13) changes `t_season_overlay.gd`. These jobs produced stderr and exit 1 for a visible reason. None of 455/461/481/482 has any stderr at all, so a shared-file parse error is **excluded** as the GATE-FAIL-01 cause.

## Verdict

**Root cause: queue/harness race — the runner's FIFO mutual exclusion broke during the 11:21 wedge, and concurrent Godot jobs were killed mid-startup (most plausibly by each other's `reap_spawned_godot()`, or by a contemporaneous `doctor`/`unwedge` from another agent).**

Attribution by evidence:

1. **Skipped tickets (452/453/457):** explicitly `was skipped (serving=N)` — queue overtaking, not a game/test failure (`godot_runner.py:316–317`).
2. **Failed tickets (455/461/481/482):** identical 75-byte banner, 0-byte stderr, exit 1, no report write; each overlaps ≥1 other running Godot job. This is a process-killed-at-startup signature, and the runner contains an explicit mechanism for exactly that (`godot_runner.py:397, 424, 243–253`).
3. **Not a parse error:** parse-error jobs print `SCRIPT ERROR: Parse Error` to stderr; these do not.
4. **Not a `main.gd` early exit:** all early exits print and are reachable only via flags that were not passed.
5. **Not stale `now_serving`:** serving advanced past the tickets rather than lagging them.
6. **Not test weakening / not a visual-parity result:** no test or game file was changed by this worker, and no parity claim is made.

Confidence: high for "harness/queue race" as the failure class; medium for the precise killer (cross-reap vs another agent's `doctor`/`unwedge` vs stale-lock reclaim), because the runner does not log lock-owner or reap-target PIDs.

## Minimal COORD-only next action

1. **Do not change tests, game code, or seeds.** Do not treat 455/482 as evidence that the reverted MAPSIZE-01 change was wrong — the same signature hit unrelated jobs (461, 481, 490).
2. **Drain and serialize.** Using only read-only `python variant3d/tools/godot_runner.py status`, wait until `pending = 0` and `godot.lock` is free, then run the two gates **strictly one at a time** with no other agent submitting Godot jobs:
   * `--id mapsize01-selftest-r2 --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json`
   * `--id mapsize01-uitest-r2 --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json`
   Confirm success from the result JSON (`status=ok`, `exit=0`) **and** from `selftest.json` / `uitest.json` mtimes advancing past the run windows.
3. **Protect the gate window:** COORD should ask all agents to pause edits to `variant3d/tests/*.gd` while gates run — parse errors in `t_season_overlay.gd` / `t_terrain_mines.gd` are a separate, concurrent failure class that can also turn a gate red.
4. **Escalate only if a solo run still produces banner-only + empty stderr:** then fix the harness in `godot_runner.py` (make `reap_spawned_godot` kill only PIDs it actually spawned; never release `godot.lock` on the `lock_stale` branch while the owner PID is alive; log lock owner/reap targets). No such change was made here.

No `cancel` / `reset` / `unwedge` / `ack` / `doctor` was performed by this worker; if any of those is needed, COORD must decide and issue it.

## Open questions

1. **Exact killer unresolved.** Cross-reap (`godot_runner.py:243–253`) is the mechanism best matching the evidence, but a contemporaneous `doctor`/`unwedge` by another agent or the `lock_stale` release at `L337–339` would look identical. Artifacts contain no lock-owner or reap-target log to distinguish them.
2. **Who advanced serving past 452/453/457?** The mass skip at 11:21:16–25 produced serving values 458/461/464/465/467/475. There is no invocation log for `unwedge`; the jump could be repeated dead-holder reclaim by many waiters or one coordinator `unwedge`.
3. **No diagnostic probe submitted.** Per the read-only scope and the explicit "NO runner-state mutation" constraint, and because the queue was demonstrably busy (`pending = 5`, lock held 146 s, active other agents), I judged a probe unnecessary and potentially disruptive to other agents' jobs. The artifact evidence is conclusive for the failure class. If COORD wants a clean data point, run the exact probe command from the task **after** the queue drains, once only, with no retries, and report its exact result.
4. **MAPSIZE-01 correctness remains untested.** This diagnosis clears the harness as the gate-failure cause; it does not validate the reverted `menu.gd` change or establish any donor parity.

## Summary

Tickets 455 and 482 did not fail because of the game or the tests: Godot printed its 75-byte version banner and was killed before reaching `main.gd` test logic, with empty stderr and no report write. Tickets 452/453/457 were never run at all — they were skipped when `now_serving` overtook them during a mass wedge break at 11:21. Both effects are artifacts of the shared Godot queue losing mutual exclusion: dozens of jobs ran concurrently, and the runner's own `reap_spawned_godot()` (plus possible `doctor`/`unwedge` activity from other agents) terminates overlapping Godot children, which the gate layer records as an ordinary `END failed` / exit 1. Shared-file parse errors were happening at the same time but have a visibly different signature and are not the cause here. The minimal next step is a fully serialized, queue-drained re-run of the two gates with `tests/*.gd` edits paused — no test or game changes, and no visual-parity claim.
