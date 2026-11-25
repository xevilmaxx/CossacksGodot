---
id: QA-GATE-READY-03
title: "Fresh final-gate READY/NOT_READY verdict after the latest fixes"
date: 2026-11-25
owner: "Read-only QA subagent (QA-GATE-READY-03); session spawned by COORD"
status: READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_STATE_MUTATION__NO_JOB_SUBMISSION__NO_CODE_EDIT
scope: "Exclusive output: docs/coord_swarm_2026-11-25/reports/QA_GATE_READY_03.md. Only read-only commands were used: variant3d/tools/godot_runner.py status (two polls), variant3d/tools/assert_clean.py --json (two polls), JSON/file reads, filesystem mtime/hash reads, repo-wide globs and git status --short / git log -1. No run/ack/cancel/reset/unwedge/doctor, no Godot process started or killed, no donor access, no final-gate execution."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: NOT_READY
snapshot_caveat: "All runner numbers are point-in-time observations. Two status/clean polls taken minutes apart show the queue churning: next_ticket 545 -> 546, pending 6 -> 7, lock HELD (133.7 s -> 240.7 s), now_serving pinned at 539 by a long-running build diagnostic. A quiet moment elsewhere in the record cannot certify the current window; COORD must re-poll at gate time."
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; donor parity is UNVERIFIED. This report makes no donor-parity claim and does not convert any green internal metric into parity."
python: "Windows python 3.14 (never python3); variant3d runner/spool only."
sources_read:
  - "read-only python variant3d\\tools\\godot_runner.py status (Poll A + Poll B)"
  - "read-only python variant3d\\tools\\assert_clean.py --json (Poll A + Poll B)"
  - "variant3d/selftest.json, variant3d/uitest.json (content + mtimes)"
  - "app/selftest.json, app/uitest.json (content + mtimes)"
  - "docs/coord_swarm_2026-11-25/reports/QA_GATE_READY_02.md"
  - "docs/coord_swarm_2026-11-25/reports/QA_LADDER_01.md"
  - "docs/coord_swarm_2026-11-25/FINAL_CHECKLIST.md"
  - "docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md"
  - "docs/coord_swarm_2026-11-25/reports/QA_2D_GATES_01.md"
  - "docs/coord_swarm_2026-11-25/reports/QA_CONFIG_JSON_02.md, QA_SPEED_ALIGN_01.md, OWNER_FAULTS_UPDATE_01.md"
  - "repo-wide glob for BLANK_CHECK_01.md (ABSENT) and for *BLANK* (only inbox/backup/main.gd.bak-BLANKCHECK01)"
  - "git status --short and git log -1 (read-only)"
---

# QA-GATE-READY-03 — fresh final-gate readiness QA

**Mutation statement (explicit).** No mutation was performed by this worker. Only the two
read-only gate tools, file/JSON reads, mtime/hash reads, repo-wide globs and `git status
--short` / `git log -1` were used. No `run` / `ack` / `cancel` / `reset` / `unwedge` /
`doctor` command was issued; no Godot process was started or killed; no code, config, test,
fixture, result-JSON, queue file or git file was edited; no donor file was accessed; no job
was submitted; the final gate was not executed. **The only file written is this report.**

**Labels used:** `observed` = literal tool output / file fact read here; `derived` =
arithmetic or control-flow consequence of observed facts; `inferred` = caveated reading;
`UNVERIFIED` = cannot be proven from the material available. Every table row and every
blocker carries a label.

---

## 1. Read-only outputs

### 1.1 `python variant3d\tools\godot_runner.py status` — Poll A (observed)

```text
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving  = 539
next_ticket  = 545
pending      = 6 [539, 540, 541, 542, 543, 544]
godot.lock   = HELD (age 133.7 s)
completed    = 500
max wait     = 1825.52 s   mean wait = 117.64 s
max run      = 605.56 s
statuses     = {'failed': 156, 'ok': 304, 'skipped': 17, 'timed-out': 23}
exit code    = 0
```

### 1.2 `python variant3d\tools\assert_clean.py --json` — Poll A (observed)

```json
{
  "clean": false,
  "verdict": "DIRTY",
  "reasons": [
    "1 Godot process(es) alive",
    "21 failed job(s) in status.json"
  ],
  "checks": {
    "processes": {
      "clean": false,
      "count": 1,
      "details": [
        {
          "pid": 22404,
          "name": "Godot_v4.7.2-stable_win64.exe",
          "command": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Microsoft\\WinGet\\Links\\godot.EXE --headless --path variant3d -- --self-test C:\\Users\\MAXYM~1.OBO\\AppData\\Local\\Temp\\opencode\\selftest_diag_BUILDSTEP01.json --config C:\\Users\\MAXYM~1.OBO\\AppData\\Local\\Temp\\opencode\\config_BUILDSTEP01_240.json --self-only build --timeout 600"
        }
      ]
    },
    "lock": {
      "clean": true, "exists": true, "state": "held_recent",
      "age_sec": 145.17031598091125, "max_age_sec": 300.0
    },
    "history": {
      "clean": false, "enabled": true, "total": 500, "acknowledged": 19,
      "failures": [ /* 21 unacked entries — enumerated below */ ]
    }
  }
}
```

Exit code: **1** (`DIRTY`). The 21 unacked failure-status entries (`observed`, listed in
full tool output) are:

- **17 `skipped`:** 448, 449, 450, 451, 452, 453, 456, 457, 458, 465, 466, 469, 470, 471, 472, 473, 526.
- **4 `timed-out`:** **494** `mapsmall01-json-uitest`, **516** `buildstep01-diag-240-r2`, **521** `reliefenabl01-dump`, **538** `nationspawn01-sid-dump`.

`derived` from `assert_clean.py:42` policy: `failed`-status tickets (156 cumulative) are
excluded and are not gate blockers; `skipped`/`timed-out`/`error` are.

### 1.3 Confirmation polls — Poll B (observed; moving target)

`python variant3d\tools\godot_runner.py status` →
`now_serving=539`, `next_ticket=546`, `pending=7 [539…545]`, `godot.lock=HELD (age 240.7 s)`,
`completed=500`, `statuses={'failed':156,'ok':304,'skipped':17,'timed-out':23}` — unchanged
status histogram, one more ticket queued.

`python variant3d\tools\assert_clean.py --json` → still `"clean": false`,
`"verdict": "DIRTY"`, reasons `"1 Godot process(es) alive"` + `"21 failed job(s) in
status.json"`, `checks.processes.count=1`; **exit code 1**.

**Derived:** between Poll A and Poll B, `next_ticket` advanced 545→546, `pending` 6→7, lock
age 133.7 s→240.7 s; `now_serving` stayed at 539 because the live ticket is a long-running
`--self-only build --timeout 600` diagnostic. The queue is **actively churning** (new jobs
submitted during this QA), not quiet.

### 1.4 Comparison with QA-GATE-READY-02 (observed / derived)

`QA_GATE_READY_02.md` (mtime **2026-11-25T11:06:23Z**) polled `now_serving=516→521`,
`pending=7→3`, lock HELD, 1 live Godot, DIRTY/exit 1 with **17→18** unacked failure-status
entries. At this QA the same spool shows `now_serving=539`, `pending=6→7`, DIRTY/exit 1 with
**21** unacked entries. `derived`: the situation has **worsened**, not improved — three new
failure-status tickets (521, 526, 538) appeared; no ack/cure is visible. `acknowledged`
(failure-status scope) moved 22→19, consistent with the rolling 500-entry history window;
this does not change the verdict.

### 1.5 Test artifacts (observed)

| File | `passed` | Steps | Pass / Fail | Failing step | mtime (UTC) |
|---|---|:--:|:--:|---|---|
| `variant3d/selftest.json` | `false` | 29 | **28 / 1** | `build` — "house built in 3.1 s of build time (cost 120 wood)" | **2026-11-25T10:28:11.6934909Z** |
| `variant3d/uitest.json` | `true` | 17 | **17 / 0** | none | **2026-11-25T09:51:54.3459037Z** |
| `app/selftest.json` | `true` | 29 | **29 / 0** | none | 2026-11-25T10:08:29.3613026Z |
| `app/uitest.json` | `true` | 17 | **17 / 0** | none | 2026-11-25T10:13:12.3587462Z |

`derived`: the integrated 3D selftest is **not** 29/29 and its mtime is byte-identical to
the value recorded in QA-GATE-READY-02 (10:28:11.693Z) — the in-flight `BUILDSTEP01`
diagnostic has not landed a green integrated run. The 3D uitest 17/17 artifact is stale
(09:51:54Z) and was not re-proved by a fresh COORD job. The 2D artifacts are green and
unchanged; `QA_2D_GATES_01.md` confirmed `CLEAN`/exit 0 there on jobs 1348/1349, but no
fresh current-window re-run was performed by this QA.

### 1.6 Documents and state read (observed unless labelled)

- **`QA_GATE_READY_02.md`**: verdict `NOT_READY`; 10 blockers B-1…B-10 (queue churn, DIRTY,
  unacked history, selftest 28/29, stale uitest, unrun ladder rows, missing rechecks,
  unsigned owner review, UNVERIFIED donor parity, no freeze).
- **`FINAL_CHECKLIST.md`** (mtime 2026-11-25T11:33:37Z): verdict `NOT_READY_FOR_FINAL_GATE`;
  **23 OPEN + 11 PARTIAL**; authorisation block requires every OPEN item A–I closed and
  every PARTIAL re-verified before COORD may run the one FINAL gate. E-P0/E-S1 are PARTIAL
  because COORD has not advanced rows; C-1 28/29 (`build`); D-1…D-4 DIRTY; F-2 only P0/S1
  rechecks; H-1/H-5 owner review OPEN; H-2 donor A/B UNVERIFIED; I-2 current-tree 2D
  re-check UNVERIFIED.
- **`QA_LADDER_01.md`** (mtime 2026-11-25T11:06:30Z): P0 **CONFIRMED_PASS** on port gates
  (ticket 504, `PASS 22/22`, second-agent `RECHECK_P0_FINAL.md` 11/0/1); P1, P2, C1–C4 have
  stale pre-edit result JSONs (P3 quarantined/absent), **zero** `RECHECK_<ROW>.md`; S1 is
  artifact-only (23/23, no PNG, shared-JSON provenance ambiguous). Dark-row repairs were
  `--check-only` only. No row advanced by QA.
- **`RELIEF_VISUAL_01.md`** (mtime 2026-11-25T11:28:06Z): real generated 64² windowed GPU
  frame with relief flag on reproduced the owner's white marks (44,381 near-white pixels,
  4.8156 %, frame-wide) and showed **no visible relief**; job 532 `failed` on a
  blank-detector false positive; final PNG not written; `SCRIPT ERROR == 0`; relief-grid
  application UNVERIFIED; `PORT APPROX`, no parity claim.
- **`BLANK_CHECK_01.md`: ABSENT.** Repo-wide glob `**/*BLANK*` finds only
  `inbox/backup/main.gd.bak-BLANKCHECK01` (mtime 2026-11-25T11:05:11Z). `git status --short`
  shows `M variant3d/scripts/main.gd`. `inferred`: a blank-detector fix is in progress, but
  no landed report exists, so its correctness is **UNVERIFIED** and no gate can be promoted
  on it.
- **`QA_CONFIG_JSON_02.md`** (11:31:23Z): the 21-leaf `features` restore is present on disk
  and committed (20 default matches + 1 intentional `relief_stamps: true` override, 320²
  map), but the owner report `CONFIG_RESTORE_01.md` is absent → ticket verdict UNVERIFIED,
  **no PASS promotion**; runtime/dump/visual/parity UNVERIFIED.
- **`QA_SPEED_ALIGN_01.md`** (11:28:57Z): `SPEED_PLAN_01` **NOT APPLIED** (0 of 4 changes);
  ticket stays pending; all speed values `PORT APPROX`; no runtime/visual/parity claim.
- **`OWNER_FAULTS_UPDATE_01.md`** (11:31:52Z): F1–F6 fixes landed at code level but runtime
  UNVERIFIED, no gate/PASS; donor parity blocked.
- **`QA_2D_GATES_01.md`** (10:17:49Z): 2D selftest 29/29, uitest 17/17, `CLEAN`/exit 0,
  `pending=0` on the 2D spool (jobs 1348/1349); current-window re-run not performed here.
- **`git status --short`** (observed): modified `FINAL_CHECKLIST.md`, `OWNER_FAULTS.md`,
  `SWARM_BOARD.md`, `reports/NATION_SPAWN_IMPL_01.md`, `reports/QA_CONFIG_RESTORE_01.md`,
  `variant3d/scripts/main.gd`; untracked `DESERT_CONSUMER_FIX_01.md`,
  `OWNER_FAULTS_UPDATE_01.md`, `QA_CONFIG_JSON_02.md`, `QA_SPEED_ALIGN_01.md`,
  `RELIEF_LIVE_DIAG_01.md`, `STAGE_IMPORT_01.md` and the BLANKCHECK01 backup. HEAD
  `2101e66ed43b2000485e2b649874c43d02edf57b` (2026-11-25 12:28:33 +0100). `derived`: files
  under test are still being edited and new jobs are still being submitted — the
  submission/edit freeze is **not** in force.

---

## 2. Prerequisite table

| # | Prerequisite | Current evidence (label) | Status |
|---:|---|---|:--:|
| PR-1 | **Queue quiet** — `pending=0`, lock free, 0 live Godot, stable across two polls ≥30 s | Poll A `pending=6`, lock HELD 133.7 s, 1 Godot PID 22404; Poll B `pending=7`, lock HELD 240.7 s, 1 Godot; `next_ticket` 545→546. `observed` + `derived` | **OPEN** |
| PR-2 | **CLEAN** — `assert_clean.py --json` CLEAN / exit 0 | Both polls `DIRTY`, exit **1**: "1 Godot process(es) alive" + "21 failed job(s)"; `processes.count=1`, `lock.state=held_recent`. `observed` | **OPEN** |
| PR-3 | **Ack hygiene / no unacked failure-status jobs** | 21 unacked = 17 `skipped` (448…473 + 526) + 4 `timed-out` (494, 516, 521, 538); `acknowledged=19`. Compare 17→18 in QA-GATE-READY-02. No ack was performed by this QA. `observed` + `derived` | **OPEN** |
| PR-4 | **Integrated selftest 29/29 (fresh)** | `selftest.json` `passed=false`, **28/29**, `build` fails; mtime 10:28:11.693Z unchanged from QA-GATE-READY-02; live `--self-only build` diagnostic has not landed green. `observed` + `derived` | **OPEN** |
| PR-5 | **Integrated uitest 17/17 (fresh)** | `uitest.json` `passed=true`, 17/17, mtime 09:51:54.346Z — stale, not re-proved by a fresh COORD job; 452/494 supersedes still unacked. `observed` + `derived` | **OPEN** |
| PR-6 | **P0 PASS (port gates)** | Ticket 504 windowed `PASS 22/22 evaluated, 1 skipped`, luma gates clear, `SCRIPT ERROR=0`, PNG postdates final shader edit; `RECHECK_P0_FINAL.md` = **P0 CONFIRMED_PASS** (11/0/1). Port-only; COORD has not advanced the ladder row. `observed` | **DONE (evidence)**; row advancement **OPEN (COORD-only)** |
| PR-7 | **P1→P2→P3→C1→C2→C3→C4→S1 ladder rows green, in order** | QA_LADDER_01: P1/P2/C1–C4 stale pre-edit JSONs, P3 quarantined/absent, no fresh windowed rows; dark-row repairs `--check-only`; S1 artifact PASS 23/23 but image UNVERIFIED (no PNG) and provenance ambiguous. `observed` + `derived` | **OPEN** |
| PR-8 | **Second-agent re-check per row** | Repo-wide glob finds exactly 3 files: `RECHECK_P0.md`, `RECHECK_P0_FINAL.md`, `RECHECK_S1.md`. None for P1, P2, P3, C1, C2, C3, C4. `observed` | **OPEN** (P0/S1 only) |
| PR-9 | **Owner visual review signed** | No owner sign-off found; `FINAL_CHECKLIST.md` H-1/H-5 OPEN; green internal gates do not constitute review. `derived` from cited rule and absence of signed record | **OPEN** |
| PR-10 | **Donor A/B rendered-frame parity** | No matched donor GPU frame exists; every capture is `PORT APPROX — internal consistency only`; parity **UNVERIFIED** and not converted to PASS by a green gate. `UNVERIFIED` | **OPEN (UNVERIFIED)** — no parity claim |
| PR-11 | **2D gates green** | `app/selftest.json` 29/29 (10:08:29Z), `app/uitest.json` 17/17 (10:13:12Z); `QA_2D_GATES_01.md` confirms `CLEAN`/exit 0 and `pending=0` on the 2D spool. Current-window re-run not performed here. `observed` (artifact/report) / `UNVERIFIED` (current tree) | **DONE (evidence)**; fresh re-run **OPEN** |
| PR-12 | **Latest fixes landed and validated** | `BLANK_CHECK_01.md` **absent** (only `main.gd.bak-BLANKCHECK01` + modified `main.gd`); `CONFIG_RESTORE_01.md` absent → QA_CONFIG_JSON_02 UNVERIFIED, no PASS; `SPEED_PLAN_01` 0/4 applied, pending; relief still flat with white marks reproduced. `observed` + `inferred` / `UNVERIFIED` | **OPEN** |
| PR-13 | **Submission/edit freeze in force** | Modified files under test + concurrent job submissions (`next_ticket` 545→546 during QA), live Godot; `QA_LADDER_01` lists no freeze. `observed` + `derived` | **OPEN** |

---

## 3. Verdict

# NOT_READY

**Labels on the verdict:** queue churn, DIRTY/exit 1, 21 unacked entries, selftest 28/29
with unchanged mtime, stale uitest, three recheck files only, absent BLANK_CHECK_01 /
CONFIG_RESTORE_01 reports and active edits are `observed` / `derived` from the polls, files
and git state above. The absence of an owner visual sign-off is `derived`. Donor A/B parity
is `UNVERIFIED`. The P0 PASS finding is `observed` from the cited reports and scoped
strictly to the port's own gates.

**Exact blockers (all must close before COORD may run the one final whole-system gate):**

1. **B-1 — Queue not quiet (`observed` / `derived`).** `pending` 6→7, lock HELD 133.7→240.7 s,
   one live Godot PID 22404, `next_ticket` 545→546 during this QA. Required: `pending=0`,
   free lock, 0 Godot processes, stable across two polls ≥30 s apart.
2. **B-2 — Clean gate red (`observed`).** `assert_clean.py --json` = `DIRTY`, exit **1** on
   both polls; reasons: live Godot process + 21 failed-status jobs. Required: `CLEAN`, exit 0,
   `processes.count=0`, `lock.state=free`.
3. **B-3 — Unacked failure-status history (`observed`).** 17 skips + 4 timeouts (494, 516,
   521, 538) = 21 unacked; count rose 17→18→21 across QA_GATE_READY_02 and this QA. No ack
   was performed by this worker; resolved PASS supersedes for 452/453 and fresh evidence for
   494/516/521/538 are not on file.
4. **B-4 — Integrated selftest still red (`observed` / `derived`).** `selftest.json`
   `passed=false`, **28/29**, `build` failing, mtime unchanged at 10:28:11.693Z. The live
   `--self-only build --timeout 600` diagnostic has not produced a fresh 29/29.
5. **B-5 — Integrated uitest not freshly proved (`observed` / `derived`).** 17/17 artifact
   exists but mtime 09:51:54.346Z predates the gate window; no fresh COORD job re-proved it.
6. **B-6 — Ladder rows P1→S1 not green (`observed` / `derived`).** No fresh windowed rows;
   P1, P2, C1–C4 stale, P3 absent, dark-row repairs parse-only, S1 artifact-only with
   no drag PNG. Required: every row green in strict order, windowed, `SCRIPT ERROR == 0`.
7. **B-7 — Second-agent re-checks incomplete (`observed`).** Only P0 (×2) and S1 have
   `RECHECK_*.md`; P1–C4 have none. Required: one landed `RECHECK_<ROW>.md` per row.
8. **B-8 — Owner visual review unsigned (`derived`).** No sign-off exists; H-1/H-5 remain
   OPEN. A green gate does not supply it.
9. **B-9 — Donor A/B parity UNVERIFIED (`UNVERIFIED`).** No donor GPU frame exists; not
   curable by a green gate and **not** claimed here. All findings are `PORT APPROX —
   internal consistency only`.
10. **B-10 — Latest fixes not landed/validated (`observed` / `inferred` / `UNVERIFIED`).**
    `BLANK_CHECK_01.md` absent (backup + modified `main.gd` only); config restore file-level
    present but owner report absent → UNVERIFIED/no PASS; SPEED_PLAN_01 not applied; relief
    visual still flat with white marks reproduced.
11. **B-11 — Freeze not in force (`observed` / `derived`).** Files under test still modified
    and tickets still being submitted; `PR-1`/`PR-2` of the queue-drain plan unsatisfied.

**No parity claim.** All findings here are internal-consistency evidence only; no donor
rendered frame was compared, accessed or inferred. Donor fidelity (hue, grain, luma, relief
silhouette) and the luma-gate calibration remain UNVERIFIED.

---

## 4. Open questions

1. **(`UNVERIFIED`)** Will the in-flight `BUILDSTEP01` diagnostic land a genuine integrated
   selftest **29/29**, or will `build` stay red? The temp diagnostic file
   `selftest_diag_BUILDSTEP01.json` is stale (mtime 11:17:52Z) and ticket 516 already timed out.
2. **(`UNVERIFIED`)** Will `BLANK_CHECK_01.md` land and will the `main.gd` blank-detector
   change be validated by a windowed capture that writes the final PNG? The backup and
   modified source exist; no landed report or gate does.
3. **(`UNVERIFIED`)** Will COORD execute the freeze → drain → ack → ladder → fresh-gate plan?
   No ack/submission/freeze action was taken by this QA.
4. **(`UNVERIFIED`)** Will P1→S1 be run windowed, one ticket per row, each with a landed
   second-agent `RECHECK_<ROW>.md`? Only P0/S1 rechecks exist today.
5. **(`UNVERIFIED`)** Will `CONFIG_RESTORE_01.md` land, and will the 21-key config block and
   `SPEED_PLAN_01` receive runtime/gate validation rather than file-level checks only?
6. **(`UNVERIFIED`)** Will the owner sign a visual review (white marks/relief, HUD/top-bar,
   loading/terrain) before sign-off? A green gate does not supply it.
7. **(`UNVERIFIED`)** Donor GPU A/B / rendered parity stays blocked by standing rule; no
   donor frame exists and no donor access is permitted.
8. **(`derived`)** S1 remains JSON/stdout-only (no drag PNG); whether COORD accepts that
   exception or requires a fresh S1-exclusive windowed run is a COORD decision.

---

## 5. Summary

Fresh read-only QA after the latest fixes finds the final gate **NOT_READY** — the same
verdict as QA_GATE_READY_02, with the queue situation measurably worse. P0 remains
independently confirmed PASS on the port's gates (ticket 504 + `RECHECK_P0_FINAL.md`) and
the 2D artifacts remain green, but neither advances the gate: the queue is churning
(`pending` 6→7, lock HELD, live Godot, `next_ticket` 545→546), `assert_clean.py --json` is
**DIRTY / exit 1** with **21** unacked failure-status entries (up from 17→18 in the prior
QA), the integrated selftest is **28/29** with `build` failing and an unchanged mtime, the
uitest 17/17 artifact is stale, P1–C4 were never run as windowed ladder rows, only P0/S1
have second-agent re-checks, the owner visual review is unsigned, the newest fix reports
(`BLANK_CHECK_01.md`, `CONFIG_RESTORE_01.md`) have not landed and `SPEED_PLAN_01` is not
applied, and donor A/B parity remains UNVERIFIED. No parity claim is made.

**No mutation was performed.** Only read-only status/clean polls, file/JSON/mtime reads,
repo-wide globs and `git status --short` / `git log -1` were used; no runner-state change,
no job submission, no Godot process started or killed, no code/config/test/fixture/result/
queue/git edit, no donor access, and no final-gate execution. The only file written is this
report.

---

*End of QA-GATE-READY-03.*
