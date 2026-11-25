---
id: QA-2D-GATES-01
title: "2D shipping project (app/) gates still green after the 2026-11-25 3D-only swarm"
area: QA / release gates (2D app only)
owner: QA-2D-GATES-01 (read-only QA worker; board session ses_dedd673d5fferCfjOZUq5RuWOa)
date: 2026-11-25
status: DONE
verdict: CONFIRMED_GREEN
runner: 2D only — app\tools\godot_runner.py (Windows python 3.14; no direct godot, no doctor)
labels: [observed, derived, UNVERIFIED]
scope: "One report file only. No hand edit of app/selftest.json or app/uitest.json, no variant3d access, no code edit, no cancel/reset."
sources_read:
  - docs/coord_swarm_2026-11-24/FINAL_GATE.md  (note: path in task, docs/FINAL_GATE.md, does not exist; real file is here)
  - docs/RESUME.md (gate sections §1, §2, §4, §6, §8)
  - docs/coord_swarm_2026-11-25/PROGRESS.md (Gates status; decisions S-25-08, S-25-12, S-25-14)
  - docs/coord_swarm_2026-11-25/SWARM_BOARD.md (ownership; QA-2D-GATES-01 row 241; V2D-01/02 read-only)
  - docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md (2D gate pattern vs variant gate)
  - app/tools/AGENT_PROTOCOL.md §1, §1b, §2, §4
  - app/tools/assert_clean.py:34,42,154-188 (spool + failure-status policy)
---

# QA-2D-GATES-01 — 2D gates after the 3D-only swarm

**Verdict: `CONFIRMED_GREEN`.** All four 2D acceptance criteria from
`docs/coord_swarm_2026-11-24/FINAL_GATE.md:13-17` were met on fresh jobs:
selftest **29/29**, uitest **17/17**, clean gate **`CLEAN` / exit 0**, queue
**`pending = 0`** with a free lock. No step was weakened, no test file was
hand-edited, and `variant3d/` was not touched.

Labels: `observed` = literal command output / file content read here;
`derived` = arithmetic or control-flow consequence of observed facts;
`UNVERIFIED` = not proven by this ticket.

---

## 1. Runner status (read-only, before any submission)

Command: `python app\tools\godot_runner.py status`

```
now_serving = 1348
next_ticket = 1348
pending      = 0 []
godot.lock   = free
completed    = 254
max wait     = 471.58s   mean wait = 39.61s
max run      = 381.53s
statuses     = {'failed': 77, 'ok': 168, 'skipped': 1, 'timed-out': 8}
```

Queue was quiet at submission time — no held lock, no pending ticket — so both
jobs started with `wait = 0.00s`. No `doctor` was run at any point (rule: never
while a job is active; none was needed). The cumulative `failed` / `timed-out`
counts are historical (see §6 open questions); they are not failures of this
QA run.

Post-run status (same command, after both jobs finished):

```
now_serving = 1350
next_ticket = 1350
pending      = 0 []
godot.lock   = free
completed    = 256
max wait     = 471.58s   mean wait = 39.30s
max run      = 381.53s
statuses     = {'failed': 77, 'ok': 170, 'skipped': 1, 'timed-out': 8}
```

Only the two 2D QA jobs advanced the counters (`ok` 168 → 170); `failed`,
`skipped` and `timed-out` counts are unchanged (`derived`: this run added no
failure-status job).

---

## 2. Job table

Both jobs used the **2D** runner (`app\tools\godot_runner.py`), unique `qa2d-`
ids, `--headless --path app`, and a generous tool timeout (600000 ms) so FIFO
wait could not be mistaken for a hang. Exactly one job was in flight at a time.

| # | Job id | Ticket | Purpose | Runner status | exit | FIFO wait | Godot run | Result record | stdout / stderr |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `qa2d-selftest` | **1348** | `--self-test app/selftest.json` | `ok` | `0` | 0.00 s | 209.35 s | `app\.godot_queue\results\00001348.json` | `app\.godot_queue\results\00001348_qa2d-selftest\stdout.txt`, `stderr.txt` |
| 2 | `qa2d-uitest` | **1349** | `--ui-test app/uitest.json` | `ok` | `0` | 0.00 s | 260.50 s | `app\.godot_queue\results\00001349.json` | `app\.godot_queue\results\00001349_qa2d-uitest\stdout.txt`, `stderr.txt` |

Runner lines observed:

```
[runner] ticket 1348 'qa2d-selftest' START (waited 0.00s)
[runner] ticket 1348 'qa2d-selftest' END ok (run 209.35s)
[runner] ticket 1349 'qa2d-uitest'  START (waited 0.00s)
[runner] ticket 1349 'qa2d-uitest'  END ok (run 260.50s)
```

No `timed-out`, `error`, or `skipped` result occurred; no job was re-submitted.

---

## 3. Gate results

Acceptance criteria are quoted from `docs/coord_swarm_2026-11-24/FINAL_GATE.md:13-17`.

| Gate | Criterion | Measured (fresh, this ticket) | Result |
|---|---|---|---|
| 2D selftest | `"passed": true`, **29 steps**, zero failures | `app/selftest.json` → `"passed": true`, `len(steps)=29`, failing steps `[]` | **PASS 29/29** |
| 2D uitest | `"passed": true`, **17/17** | `app/uitest.json` → `"passed": true`, `len(steps)=17`, failing steps `[]` | **PASS 17/17** |
| Clean-exit gate | `CLEAN`, exit 0, 0 processes, free lock, no unacked `timed-out`/`error`/`skipped` | `python app\tools\assert_clean.py --json` → `"clean": true`, `"verdict": "CLEAN"`, `"reasons": []`; `processes.count=0`; `lock.exists=false / state=free`; `history.total=256, acknowledged=9, failures=[]`. Separate exit-code capture: `assert_clean EXIT=0` | **PASS CLEAN** |
| Queue | `pending = 0`, bounded max wait | `pending = 0 []`, `godot.lock = free`, `max wait = 471.58s`, `mean wait = 39.30s` | **PASS** |

### 3.1 Failing steps

**None.** Every step in both canonical JSONs has `"passed": true`. The selftest
steps are `move, act, fight, build, train, mine, hud, no_overlap, volley, heal,
morale, upgrade, market, capture, squad, formation, wall, shell,
formation_bonus, replenish, flee, garrison, peasant_capture, resow,
attack_ground, save_load, grid_equiv, farm_cap, nav_detour` (29). The uitest
steps are `menu_shell, select_box, order_keys, build_flow, train_flow,
squad_keys, rally_panel, market_panel, research_panel, delete_key, speed_pause,
cursor_ctx, groups, minimap_frustum, garrison_keys, hotkeys_live, save_load_ui`
(17).

Note: the previously red trio `wall` / `shell` / `farm_cap`
(`QA_AUDIT_01_implementation_claims.md` HEAD 26/29) and the `build` step
(worktree 28/29) are all `passed: true` in this fresh run — consistent with the
final integrated gate being reserved for the end (S-25-12), not a transitory
per-job artifact. No assertion was relaxed to obtain this.

### 3.2 stdout / stderr notes (not gate failures)

- Selftest stderr (250 B) contains only engine cleanup warnings: `WARNING: 10
  ObjectDB instances were leaked at exit` and `ERROR: 2 resources still in use
  at exit`. These are known exit-time noise; the runner still reported `ok` /
  exit `0` and the canonical JSON is green. No `SCRIPT ERROR` line in either
  job. Uitest stderr is empty (0 B).
- Both stdout logs show `sprites: 116 sets loaded (sids=173)` and a
  `BAKE_BENCH` line; the selftest stdout confirms it wrote
  `.../app/selftest.json`, and the uitest stdout confirms
  `.../app/uitest.json`.

### 3.3 2D was not edited today (ownership / evidence)

- `docs/coord_swarm_2026-11-25/PROGRESS.md:175` decision **S-25-08**:
  "Defaults change (CFG-01) scoped to `variant3d/` only; `app/**` stays
  untouched — Today's 3D focus; 2D gates must stay green".
- `docs/coord_swarm_2026-11-25/PROGRESS.md:191` gates table: "2D app gates |
  29/29 / 17/17 / CLEAN | untouched; must remain green".
- `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:28-29` — the only 2D tickets
  (V2D-01, V2D-02) are **read-only secondary analysis reports**; no
  implementation ticket owns an `app/**` file. All named implementation files
  are under `variant3d/` (e.g. rows 201, 235, 245-248).
- `git status --short -- app` is empty (no uncommitted `app/**` change).
- `git log --since="2026-11-25 00:00" --name-only -- app` shows exactly one
  commit, `1d67e32b` ("step", 11:14:22), touching only
  `app/.godot_queue/counter`, `app/.godot_queue/now_serving` and
  `app/selftest.json`. Its `app/selftest.json` diff is **runner output only**
  (`sim_seconds` and `wall_ms` values); zero lines matching
  `"passed"` / `"step"` / `"detail"` changed. No `app/**/*.gd` or test
  definition was edited today. This ticket made no hand edit to either JSON —
  the only writes were by the runner itself.

---

## 4. Verdict

### `CONFIRMED_GREEN`

Evidence: fresh 2D selftest 29/29 (`passed: true`, 0 failures) at ticket 1348;
fresh 2D uitest 17/17 (`passed: true`, 0 failures) at ticket 1349; clean gate
`CLEAN` with exit 0, 0 processes, free lock and no unacked failure-status jobs;
`pending = 0` with bounded wait. No gate was weakened, no job was re-submitted,
no direct `godot` was invoked, no `doctor` was run, nothing was cancelled or
reset, and `variant3d/` was not accessed.

This verdict is scoped strictly to the **2D shipping project (`app/`)**. It
does **not** certify the 3D variant: the variant3d integrated state / donor
visual A/B remain as recorded elsewhere (`FINAL_GATE_PLAN_01.md:226-230`,
`:252` — integrated selftest not green in QA-AUDIT, donor parity UNVERIFIED).
That is outside this ticket's scope and ownership.

---

## 5. Open questions

1. **Historical failure counters (observed, no action taken).** The 2D runner
   reports cumulative `failed=77, timed-out=8, skipped=1` across 256 jobs.
   `assert_clean.py:42,169-181` counts only `{timed-out, error, skipped}` as
   history failures; all 9 such records are acknowledged, and `failed` is
   excluded by policy (D-13/D-14), hence `CLEAN`. The coordinator may confirm
   that exclusion is still the intended policy; this ticket did not ack,
   cancel or reset anything.
2. **Exit-time cleanup warnings (observed).** 10 leaked ObjectDB instances and
   2 resources still in use at selftest exit are non-gating noise. Recorded for
   completeness; no fix attempted (read-only ticket).
3. **Commit `1d67e32b` (observed).** A commit today at 11:14:22 snapshotted the
   runner's `app/selftest.json` runtime output plus queue counter files. It is
   runtime output, not a test change; owner/coordinator can confirm it was
   intentional if desired. It does not affect this verdict.
4. **2D `minimap_frustum` expectation (observed).** `app/uitest.json` asserts
   "minimap bottom-left: yes" and passes; `PROGRESS.md:189`'s "minimap
   bottom-right" anchor is a variant3d/UITEST-ANCHOR (job 366) matter, not a 2D
   gate. No 2D action implied.
5. **No 2D-specific open risk found.** All four 2D gates are green on fresh
   jobs. Donor visual parity / owner visual review remains `UNVERIFIED` in the
   3D lane only and is not claimed here.

---

## 6. Summary

- Read the gate definitions and ownership: the real `FINAL_GATE.md` is
  `docs/coord_swarm_2026-11-24/FINAL_GATE.md` (the task's `docs/FINAL_GATE.md`
  path does not exist); confirmed runner commands in `AGENT_PROTOCOL.md §1/§1b/§2/§4`.
- Pre-run queue telemetry: `now_serving=1348`, `pending=0`, lock free,
  `completed=254`.
- Two fresh 2D runner jobs: `qa2d-selftest` (ticket **1348**, `ok`, exit 0,
  209.35 s) and `qa2d-uitest` (ticket **1349**, `ok`, exit 0, 260.50 s); both
  `wait=0.00s`; result records `app\.godot_queue\results\00001348.json` and
  `app\.godot_queue\results\00001349.json`.
- Fresh gate results: **selftest 29/29**, **uitest 17/17**, **CLEAN / exit 0**,
  **pending 0** — zero failing steps, no weakened assertions.
- Verdict: **`CONFIRMED_GREEN`** for the 2D shipping project. 2D was never
  intentionally edited today (S-25-08, PROGRESS §Gates status, SWARM_BOARD
  ownership; git shows no `app/**/*.gd` edit today), so the green result is
  consistent with ownership as well as measurement.
- Read-only discipline: only this report file was written by hand; `variant3d`
  untouched; no direct `godot`, no `doctor`, no re-submission, no cancel/reset.
