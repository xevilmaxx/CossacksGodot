---
id: QA-GATE-READY-02
title: "Fresh final-gate readiness QA after the runner patch and P0 confirmation"
date: 2026-11-25
owner: "Read-only QA subagent (QA-GATE-READY-02); session spawned by COORD"
status: READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_STATE_MUTATION__NO_JOB_SUBMISSION__NO_CODE_EDIT
scope: "Exclusive output: docs/coord_swarm_2026-11-25/reports/QA_GATE_READY_02.md. Only read-only commands were used (godot_runner.py status, assert_clean.py --json, JSON/file reads, git status --short). No run/ack/cancel/reset/unwedge/doctor, no Godot process started or killed, no donor access, no final-gate execution."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: NOT_READY
snapshot_caveat: "All runner numbers are point-in-time. Two status and two assert_clean polls were taken minutes apart and the queue demonstrably churned between them (now_serving 516 -> 521, failure count 17 -> 18, live PID 8984 -> 11292). At gate time COORD must re-poll; a quiet moment elsewhere in the record (FINAL_CHECKLIST.md:13, QUEUE_DRAIN_01.md:62-73) does not certify the current window."
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; donor parity is UNVERIFIED. This report makes no donor-parity claim."
sources_read:
  - "read-only python variant3d\\tools\\godot_runner.py status (two polls)"
  - "read-only python variant3d\\tools\\assert_clean.py --json (two polls)"
  - "variant3d/selftest.json, variant3d/uitest.json (content + mtimes)"
  - "variant3d/.godot_queue/status.json (read-only history cross-check)"
  - "variant3d/tools/godot_runner.py (read-only source inspection), variant3d/tools/assert_clean.py"
  - "docs/coord_swarm_2026-11-25/reports/P0_FRESH_CAPTURE_01.md"
  - "docs/coord_swarm_2026-11-25/reports/RECHECK_P0_FINAL.md"
  - "docs/coord_swarm_2026-11-25/reports/QUEUE_DRAIN_01.md"
  - "docs/coord_swarm_2026-11-25/FINAL_CHECKLIST.md"
  - "docs/coord_swarm_2026-11-25/reports/CLEAN_ACK_PLAN_01.md, RUNNER_FIX_01.md"
  - "docs/coord_swarm_2026-11-25/PROGRESS.md:104-112"
  - "git status --short (read-only)"
---

# QA-GATE-READY-02 — fresh final-gate readiness QA

**Mutation statement (explicit).** No mutation was performed by this worker. Only the two
read-only gate tools, file/JSON reads and `git status --short` were used. No
`run` / `ack` / `cancel` / `reset` / `unwedge` / `doctor` command was issued; no Godot
process was started or killed; no code, config, test, fixture, result-JSON, queue file or
git file was edited; no donor file was accessed; no job was submitted; the final gate was
not executed. **The only file written is this report.**

**Labels used:** `observed` = literal tool output / file fact read here; `derived` =
arithmetic or control-flow consequence of observed facts; `inferred` = caveated reading;
`UNVERIFIED` = cannot be proven from the material available. Every table row carries a
label, and the verdict is labelled item by item.

---

## 1. Read-only outputs

### 1.1 `python variant3d\tools\godot_runner.py status` — Poll A (first, observed)

```text
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 516
next_ticket = 523
pending      = 7 [516, 517, 518, 519, 520, 521, 522]
godot.lock   = HELD (age 237.2s)
completed    = 500
max wait     = 1825.52s   mean wait = 107.76s
max run      = 605.56s
statuses     = {'failed': 154, 'ok': 307, 'skipped': 16, 'timed-out': 23}
```

### 1.2 `python variant3d\tools\assert_clean.py --json` — Poll A (first, observed)

```json
{
  "clean": false,
  "verdict": "DIRTY",
  "reasons": [
    "1 Godot process(es) alive",
    "17 failed job(s) in status.json"
  ],
  "checks": {
    "processes": {
      "clean": false,
      "count": 1,
      "details": [
        {
          "pid": 8984,
          "name": "Godot_v4.7.2-stable_win64.exe",
          "command": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Microsoft\\WinGet\\Links\\godot.EXE --headless --path variant3d -- --self-test C:\\Users\\MAXYM~1.OBO\\AppData\\Local\\Temp\\opencode\\selftest_diag_BUILDSTEP01.json --config C:\\Users\\MAXYM~1.OBO\\AppData\\Local\\Temp\\opencode\\config_BUILDSTEP01_240.json --self-only move,act,fight,build"
        }
      ]
    },
    "lock": {
      "clean": true,
      "exists": true,
      "state": "held_recent",
      "age_sec": 242.6815550327301,
      "max_age_sec": 300.0
    },
    "history": {
      "clean": false,
      "enabled": true,
      "total": 500,
      "acknowledged": 22,
      "failures": [ /* 16 skipped tickets 448-473 + ticket 494 mapsmall01-json-uitest timed-out */ ]
    }
  }
}
```

Exit code: **1** (`DIRTY`). The 17 unacked failure-status entries are the 16 `skipped`
tickets 448/449/450/451/452/453/456/457/458/465/466/469/470/471/472/473 plus ticket
**494** `mapsmall01-json-uitest` (`timed-out`, empty error). `failed` entries (154 in
`statuses`) are excluded by D-13 (`assert_clean.py:42`) and are not gate blockers.

### 1.3 Confirmation polls — Poll B (later; observed, moving target)

`assert_clean.py --json` → **DIRTY / exit 1**: reasons now
`"1 Godot process(es) alive"` + `"18 failed job(s) in status.json"`; live process **PID
11292** (`--dump-map C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefenabl01_dump.json`);
`lock.state=held_recent`, `age_sec=26.10`; `history.total=500`, `acknowledged=22`; 18
unacked failure-status entries = the same 16 skips + tickets **494** and **516**
(`buildstep01-diag-240-r2`, `timed-out`, `exit -9`, `run 304.999 s`, `timeout 300`).

`godot_runner.py status` →
`now_serving=521`, `next_ticket=524`, `pending=3 [521,522,523]`, `godot.lock=HELD (age 38.2s)`,
`completed=500`, `statuses={'failed':154,'ok':306,'skipped':16,'timed-out':24}`.

**Derived:** between polls, `now_serving` advanced 516→521, `next_ticket` 523→524,
`pending` 7→3, the live PID changed, and the unacked failure count rose 17→18. The queue
is actively churning, not quiet.

### 1.4 Cross-check of `status.json` history (observed / derived)

Read-only direct parse of `variant3d/.godot_queue/status.json` → `history` is a 500-entry
list; `acknowledged` is truthy on **94** entries and unacked `skipped`/`timed-out`/`error`
entries number **18** (16 skipped + 494 + 516). `assert_clean.py:166-188` counts
`acknowledged` only **within the failure statuses**, hence its 22, and excludes the
currently-served ticket from `failures` at Poll A time; this explains the differing raw
counts without changing the verdict (both are DIRTY). `derived` from `assert_clean.py:42,166-188`.

### 1.5 selftest / uitest artifacts (observed)

| File | `passed` field | Steps | Pass / Fail | Failing step | mtime (UTC) |
|---|---|:--:|:--:|---|---|
| `variant3d/selftest.json` | `false` | 29 | **28 / 1** | `build` — "house built in 3.1 s of build time (cost 120 wood)", `passed: false` | **2026-11-25T10:28:11.693Z** |
| `variant3d/uitest.json` | `true` | 17 | **17 / 0** | none | **2026-11-25T09:51:54.346Z** |

`derived`: the integrated selftest is **not** 29/29; the uitest is 17/17 but its mtime
predates the P0 capture (10:41:11 UTC) and is not proved by a fresh COORD final-gate job.
`FINAL_CHECKLIST.md:175-190` and `QUEUE_DRAIN_01.md:359-376` require fresh **29/29** and
**17/17** with advancing mtimes; neither condition holds here.

### 1.6 Other documents read (observed unless labelled)

- `P0_FRESH_CAPTURE_01.md`: ticket 504 `p0fresh01-capture`, windowed, JSON `PASS`,
  `passes=22`, `fails=0`, `skipped_or_skip_capture=1`, `mean_luma=91.432`,
  `max_luma=155.163`, `non_black_fraction=1.0`, `full_width_dark_rows=0` (recorded-only
  N/A), `SCRIPT ERROR=0`; PNG mtime 10:41:11 UTC > shader mtime 09:53:34 UTC. Verdict
  `P0 READY_FOR_LADDER` on port gates; `PORT APPROX`, no donor parity claimed.
- `RECHECK_P0_FINAL.md`: second agent, read-only, **P0 CONFIRMED_PASS** — 11 PASS / 0 FAIL /
  1 N/A on port gates; gap closed; COORD cleared to decide P1; no ladder advancement.
- `QUEUE_DRAIN_01.md`: COORD-only plan; fresh read at its authoring time was
  `pending=0`, lock free, 0 Godot processes but DIRTY/exit 1 with 17 unacked entries; plan
  orders freeze → drain → patch → 14 acks (defer 452/453/494) → ladder rows → fresh gates →
  3 more acks → CLEAN. Explicitly **plan only**, no action taken.
- `FINAL_CHECKLIST.md`: overall verdict `NOT_READY_FOR_FINAL_GATE`; 23 OPEN + 11 PARTIAL;
  selftest RED 28/29 (`build`), queue DIRTY, second-agent rechecks absent for P1–C4,
  owner review and donor A/B UNVERIFIED.
- `PROGRESS.md:104-112`: runner patch **applied** by COORD at a quiet moment; `git apply
  --check` and `git apply` succeeded, backup `inbox/backup/godot_runner.py.bak-RUNNERFIX01`,
  `py_compile` passed; queue refilled with 4 jobs immediately after; "No CLEAN or
  final-gate claim made." Read-only source inspection here confirms the patched symbols
  (`godot_lock_owner`, `spawned_pids`, `owner_dead`, `lock_stale = lock_present and
  lock_age > STALE_SEC and owner_dead`, owner-gated `claim_godot_lock` /
  `release_godot_lock(ticket)`) are present in `variant3d/tools/godot_runner.py`. **Derived:**
  `RUNNER_FIX_01.md` frontmatter `patch_applied: false` is stale relative to the applied
  source; the patch state is APPLIED, not verified by a solo post-patch gate.
- `CLEAN_ACK_PLAN_01.md`: 16 mapped skips, 14 verified `ok`/exit 0 supersedes, 2
  UNRESOLVED (452, 453); all ack commands prepared, **not executed**; ticket 494 noted as a
  later unacked `timed-out`.
- `git status --short` (observed): modified docs, `variant3d/config.json`, several
  `variant3d/scripts/*.gd`, `variant3d/tests/t_season_overlay.gd`,
  `variant3d/tools/godot_runner.py` and `t_terrain_only.json`; deleted
  `variant3d/tests/results/t_terrain_mines.json`; many untracked reports, backups under
  `inbox/backup/` (including `selftest.gd.bak-BUILDSTEP01` and the four `DARKROWREPAIR`
  atom backups). `derived`: files under test are still being edited; the submission/edit
  freeze prerequisite is not in force.

---

## 2. Prerequisite table

| # | Prerequisite | Current evidence (label) | Status |
|---:|---|---|:--:|
| PR-1 | **Queue quiet** — `pending=0`, lock free, 0 live Godot | Poll A: `pending=7`, `godot.lock=HELD (237.2s)`, 1 Godot PID 8984. Poll B: `pending=3`, lock HELD (38.2s), 1 Godot PID 11292; `now_serving` 516→521, `next_ticket` 523→524. `observed` | **OPEN** |
| PR-2 | **CLEAN** — `assert_clean.py --json` CLEAN / exit 0 | Poll A: `verdict=DIRTY`, exit **1**, reasons "1 Godot process(es) alive" + "17 failed job(s)". Poll B: DIRTY/exit 1, 18 failed jobs. `observed` | **OPEN** |
| PR-2b | **Ack hygiene / no unacked failure-status jobs** | `acknowledged=22` (failure-status scope), 17→18 unacked (16 skipped + 494 + 516 timed-out). `CLEAN_ACK_PLAN_01` / `QUEUE_DRAIN_01` prepared acks only; none executed. `observed` + `derived` | **OPEN** |
| PR-3 | **Integrated selftest 29/29** | `selftest.json`: `passed=false`, 28/29, `build` fails, mtime 10:28:11 UTC; no fresh COORD 29/29 job. `observed` + `derived` | **OPEN** |
| PR-4 | **Integrated uitest 17/17** | `uitest.json`: `passed=true`, 17/17, mtime 09:51:54 UTC (stale; not re-proved by a fresh COORD job; 452/494 supersedes still unacked). `observed` + `derived` | **OPEN** |
| PR-5 | **P0 PASS (port gates)** | Ticket 504 windowed `PASS 22/22 evaluated, 1 skipped`, both luma gates clear, `SCRIPT ERROR=0`, PNG postdates final shader edit; `RECHECK_P0_FINAL.md` = **P0 CONFIRMED_PASS** (11/0/1). `observed`. Row advancement remains COORD-only and has not occurred. `observed` + `derived` | **DONE** (evidence); ladder row not advanced |
| PR-6 | **P1→P2→P3→C1→C2→C3→C4→S1 ladder rows green, in order** | `FINAL_CHECKLIST.md` E: P1, P2, P3, C1–C4 **OPEN — never executed as rows**; only `TEST_RUN_01`/`TEST_RUN_02` ladder logs exist, no newer ladder log. S1 **PARTIAL** (atom job 414 23/23, row not re-run, no PNG). `observed` (docs) + `derived` (file set) | **OPEN** |
| PR-7 | **Second-agent capture re-checks per row** | Only `RECHECK_P0.md`, `RECHECK_P0_FINAL.md`, `RECHECK_S1.md` on disk; no `RECHECK_<ROW>.md` for P1–C4. S1 image verdict UNVERIFIED (no PNG). `observed` | **OPEN** (P0/S1 only) |
| PR-8 | **Owner visual review signed** | `FINAL_CHECKLIST.md` H-1/H-5 OPEN; no owner sign-off; a green gate does not constitute review. `derived` from cited rule and absence of signed record | **OPEN** |
| PR-9 | **Donor A/B rendered-frame parity** | No matched donor GPU frame exists; every capture is `PORT APPROX — internal consistency only`; parity is **UNVERIFIED** and is never converted to PASS by a green gate (`TEST_MATRIX.md:32-34,73-74`). `UNVERIFIED` | **OPEN (UNVERIFIED)** — no parity claim |
| PR-10 | **Runner patch state recorded and validated** | Patch source symbols present in `godot_runner.py`; `PROGRESS.md:104-112` records applied + `py_compile` OK + backup. No solo post-patch gate has been run (solo runs deferred to queue drain). `observed` + `derived` | **DONE (applied)**; post-patch gate **OPEN** |
| PR-11 | **Submission/edit freeze in force** | `git status --short` shows modified files under test and active ticket churn / live Godot jobs. `observed` + `derived` | **OPEN** |

---

## 3. Verdict

# NOT_READY

**Labels on the verdict:** queue churn, DIRTY/exit 1, selftest 28/29, stale uitest mtime,
17→18 unacked entries, missing per-row rechecks and active edits are `observed` /
`derived` from the polls and files above; the absence of owner sign-off is `derived`;
donor parity is `UNVERIFIED`. The P0 PASS finding is `observed` from the two cited
reports and is scoped to the port's own gates only.

**Exact blockers (all must be closed before COORD may run the one final whole-system gate):**

1. **B-1 — Queue not quiet (`observed`).** Poll A `pending=7 [516…522]`, lock HELD
   237.2 s, live Godot PID 8984; Poll B `pending=3 [521…523]`, lock HELD 38.2 s, live
   Godot PID 11292. `now_serving` advanced 516→521 during this QA. Required:
   `pending=0`, free lock, 0 Godot processes, stable across two polls ≥30 s apart.
2. **B-2 — Clean gate red (`observed`).** `assert_clean.py --json` = `DIRTY`, exit **1**
   on both polls; reasons: live Godot process + 17 (then 18) failed jobs in `status.json`.
   Required: `CLEAN`, exit 0, `processes.count=0`, `lock.state=free`.
3. **B-3 — Unacked failure-status history (`observed`).** 16 skipped + ticket 494
   `timed-out` + new ticket 516 `timed-out` = 18 unacked at Poll B; `acknowledged=22`.
   The prepared ack plans were not executed; 452/453 remain UNRESOLVED by a verified
   PASS supersede, and 494/516 need fresh evidence. No ack was performed by this QA.
4. **B-4 — Integrated selftest not green (`observed`).** `selftest.json` `passed=false`,
   **28/29**, `build` failing; fresh **29/29** with advancing mtime is required. The
   in-flight `BUILDSTEP01` diagnostic (job 516 timed out; 517–523 churning) does not
   constitute a green integrated run.
5. **B-5 — Integrated uitest not freshly proved (`observed`/`derived`).** 17/17 artifact
   exists but mtime 09:51:54 UTC predates the gate window; `QUEUE_DRAIN_01.md` step (f)
   requires a fresh COORD job, and the 452/494 acks depend on it.
6. **B-6 — Ladder rows P1→S1 not green (`observed`/`derived`).** P1, P2, P3, C1–C4 were
   never executed as windowed ladder rows; S1 is atom-level PARTIAL with visual verdict
   UNVERIFIED. Required: all rows green in order, each windowed with `SCRIPT ERROR=0`.
7. **B-7 — Second-agent re-checks incomplete (`observed`).** Only P0 and S1 have
   `RECHECK_*.md`; P1–C4 have none. Required: a landed `RECHECK_<ROW>.md` per row.
8. **B-8 — Owner visual review not signed (`derived`).** No owner sign-off exists;
   `FINAL_CHECKLIST.md` H-1/H-5 remain OPEN.
9. **B-9 — Donor A/B parity UNVERIFIED (`UNVERIFIED`).** No donor GPU frame exists.
   This is not curable by a green gate and is **not** claimed here. `PORT APPROX —
   internal consistency only`.
10. **B-10 — Freeze not in force (`observed`/`derived`).** Modified files under test and
    concurrent job churn continue; `QUEUE_DRAIN_01.md` PR-1/PR-2 are not satisfied.

**No parity claim.** All findings are internal-consistency evidence only; no donor
rendered frame was compared, accessed or inferred. Donor fidelity (hue, grain, luma) and
the luma-gate calibration remain UNVERIFIED.

---

## 4. Open questions

1. **(`UNVERIFIED`)** Will the in-flight BUILDSTEP01 work land a genuine integrated
   selftest **29/29**, or will `build` remain red? Job 516 already timed out; the queue
   is still processing retries.
2. **(`UNVERIFIED`)** Will COORD execute the freeze, drain, 14+3 acks and fresh gate jobs
   from `QUEUE_DRAIN_01.md` / `CLEAN_ACK_PLAN_01.md`? All are prepared commands only;
   this QA executed none of them.
3. **(`UNVERIFIED`)** Will the ladder rows P1→S1 be run windowed, one at a time, with a
   landed second-agent re-check each? No `TEST_RUN_03` or new `RECHECK_<ROW>.md` exists yet.
4. **(`UNVERIFIED`)** Is the applied runner patch behaviourally validated by a solo
   post-patch gate (no overlap, non-empty stderr/report, no banner-only cross-kill)?
   Source presence and `py_compile` are recorded; a solo gate is not.
5. **(`UNVERIFIED`)** Will ticket 516's timeout be resolved/accepted, and will further
   skips/timeouts appear during the gate window? The unacked count moved 17→18 within
   this QA.
6. **(`UNVERIFIED`)** Will the owner sign a visual review (HUD/loading/terrain) before
   sign-off? A green gate does not supply it.
7. **(`UNVERIFIED`)** Donor GPU A/B / rendered parity stays blocked by standing rule;
   no donor frame exists and no donor access is permitted.
8. **(`derived`)** S1 remains JSON/stdout-only (no PNG); whether COORD accepts that
   exception or requires a fresh capture is a COORD decision.

---

## 5. Summary

Fresh read-only QA finds the final gate **NOT_READY**. The runner patch is applied
(`PROGRESS.md:104-112` plus patched symbols in source) and P0 is independently confirmed
PASS on the port's gates (ticket 504 + `RECHECK_P0_FINAL.md`), but those two advances do
not close the gate: the queue is actively churning (`pending` 7→3, lock HELD, live Godot
PID changed), `assert_clean.py --json` is **DIRTY / exit 1** with 17→18 unacked
failure-status entries, the integrated selftest is **28/29** with `build` failing, the
uitest 17/17 artifact is stale, P1–C4 were never run as ladder rows, only P0/S1 have
second-agent re-checks, the owner visual review is unsigned, and donor A/B parity remains
UNVERIFIED. No parity claim is made.

**No mutation was performed.** Only read-only status/clean polls, file/JSON reads and
`git status --short` were used; no runner-state change, no job submission, no Godot
process started or killed, no code/config/test/fixture/result/queue/git edit, no donor
access, and no final-gate execution. The only file written is this report.

---

*End of QA-GATE-READY-02.*
