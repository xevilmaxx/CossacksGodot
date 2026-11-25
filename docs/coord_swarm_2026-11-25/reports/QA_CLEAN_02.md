---
id: QA-CLEAN-02
title: "Read-only re-check of the variant CLEAN gate after current job churn"
area: coordination / variant3d clean gate / QA
owner: QA-CLEAN-02 (read-only queue/gate re-check worker)
date: 2026-11-25
status: REPORT_ONLY__NO_RUNNER_STATE_MUTATION__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Only this report file was written. Commands used: python variant3d\\tools\\godot_runner.py status, python variant3d\\tools\\assert_clean.py --json, and read-only file/dir/CIM reads."
verdict: "CLEAN NOT SIGNABLE — assert_clean DIRTY / exit 1 (1 live Godot process + 16 unacked skipped jobs)"
labels: [observed, derived, inferred, UNVERIFIED]
sources_read:
  - "python variant3d\\tools\\godot_runner.py status (read-only)"
  - "python variant3d\\tools\\assert_clean.py --json (read-only; exit 1)"
  - "variant3d/.godot_queue/{counter,now_serving,status.json,jobs,results} (read-only)"
  - "variant3d/tools/assert_clean.py (read-only; FAILURE_STATUSES / check_history semantics)"
  - "docs/coord_swarm_2026-11-25/reports/CLEAN_01_variant_clean.md"
  - "docs/coord_swarm_2026-11-25/reports/CLEAN_02_variant_gate.md"
  - "docs/coord_swarm_2026-11-25/reports/GATE_READY_01.md"
---

# QA-CLEAN-02 — re-check of variant CLEAN gate state

**Labels:** `observed` = literal command output or file fact read here; `derived` = arithmetic
or control-flow consequence of observed facts; `inferred` = plausible reading with caveat;
`UNVERIFIED` = cannot be proven from the material read.

**No visual-parity claim is made anywhere in this report.** Donor A/B remains UNVERIFIED.
This is a **clean-gate-only** re-check: selftest/uitest artifacts and the piece→combo ladder
were **not** re-run here; GATE_READY_01's non-gate blockers are carried forward, not re-verified.

---

## 0. Mutation statement

**No runner-state mutation was performed.** No job was submitted, cancelled, reset,
unwedged, acknowledged or "doctored". `godot_runner.py status`, `assert_clean.py --json`,
direct file reads and `Get-CimInstance` are all read-only. **No code, config, test, fixture,
asset, queue result/status or git file was edited. No Godot process was started or killed.**
The **only** file written by this worker is this report. All queue movement seen between
snapshots is attributable to other swarm workers (observed, derived).

---

## 1. Status outputs (read-only)

### 1.1 `python variant3d\tools\godot_runner.py status` — verbatim, exit 0

```text
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 491
next_ticket = 496
pending      = 6 [490, 491, 492, 493, 494, 495]
godot.lock   = HELD (age 6.2s)
completed    = 479
max wait     = 1825.52s   mean wait = 106.70s
max run      = 605.56s
statuses     = {'failed': 148, 'ok': 293, 'skipped': 16, 'timed-out': 22}
```

### 1.2 `python variant3d\tools\assert_clean.py --json` — verbatim, exit code **1**

```json
{
  "clean": false,
  "verdict": "DIRTY",
  "reasons": [
    "1 Godot process(es) alive",
    "16 failed job(s) in status.json"
  ],
  "checks": {
    "processes": {
      "clean": false,
      "count": 1,
      "details": [
        {
          "pid": 7552,
          "name": "Godot_v4.7.2-stable_win64.exe",
          "command": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Microsoft\\WinGet\\Links\\godot.EXE --headless --path variant3d --script res://tests/t_terrain3d.gd"
        }
      ]
    },
    "lock": {
      "clean": true,
      "exists": true,
      "state": "held_recent",
      "age_sec": 18.334805965423584,
      "max_age_sec": 300.0
    },
    "history": {
      "clean": false,
      "enabled": true,
      "total": 480,
      "acknowledged": 22,
      "failures": [
        {"ticket": 451, "id": "audiosel02-smoke", "status": "skipped", "error": "ticket 451 waited > 600s for its turn"},
        {"ticket": 449, "id": "configwirer-smoke", "status": "skipped", "error": "ticket 449 waited > 1800s for its turn"},
        {"ticket": 457, "id": "sp06-sun-smoke", "status": "skipped", "error": "ticket 457 was skipped (serving=458)"},
        {"ticket": 450, "id": "weatherdriver01-smoke", "status": "skipped", "error": "ticket 450 was skipped (serving=461)"},
        {"ticket": 456, "id": "terraindarkfix2-p0", "status": "skipped", "error": "ticket 456 was skipped (serving=461)"},
        {"ticket": 452, "id": "qaparity01-uitest", "status": "skipped", "error": "ticket 452 was skipped (serving=461)"},
        {"ticket": 453, "id": "qaparity01-selftest", "status": "skipped", "error": "ticket 453 was skipped (serving=461)"},
        {"ticket": 458, "id": "motionanim01-rotor-smoke-r2", "status": "skipped", "error": "ticket 458 was skipped (serving=461)"},
        {"ticket": 448, "id": "motionanim01-rotor-smoke", "status": "skipped", "error": "ticket 448 was skipped (serving=464)"},
        {"ticket": 466, "id": "seasonpath01-smoke", "status": "skipped", "error": "ticket 466 was skipped (serving=467)"},
        {"ticket": 472, "id": "darkrowall-t_combo_all", "status": "skipped", "error": "ticket 472 was skipped (serving=475)"},
        {"ticket": 470, "id": "darkrowall-t_combo_trees_mines", "status": "skipped", "error": "ticket 470 was skipped (serving=475)"},
        {"ticket": 473, "id": "darkrowall-t_terrain_trees", "status": "skipped", "error": "ticket 473 was skipped (serving=475)"},
        {"ticket": 469, "id": "darkrowall-t_combo_shore_mines", "status": "skipped", "error": "ticket 469 was skipped (serving=475)"},
        {"ticket": 465, "id": "audiosel02-smoke", "status": "skipped", "error": "ticket 465 was skipped (serving=475)"},
        {"ticket": 471, "id": "darkrowall-t_terrain_shore", "status": "skipped", "error": "ticket 471 was skipped (serving=475)"}
      ]
    }
  }
}
EXITCODE=1
```

**Important label caveat (observed, derived):** the reason string `16 failed job(s) in
status.json` is a fixed label from `assert_clean.py:212`, not a claim that 16 entries have
status `failed`. `FAILURE_STATUSES = {"timed-out", "error", "skipped"}` (`assert_clean.py:42`)
and `check_history` (`assert_clean.py:166-181`) counts **unacknowledged** entries in that set.
All 16 listed entries are `status: "skipped"`. The 148 `failed` entries reported by
`godot_runner.py status` are a different set and are **excluded by D-13**, so they are **not**
what makes the gate DIRTY. `acknowledged: 22` is the count of failure-status entries that
*are* acked (the 22 historical `timed-out` jobs acked by CLEAN-01); it is not the total ack
count on the spool.

### 1.3 Supplementary point-in-time reads (clearly later than the two polls above)

| Read | Result | Label |
|---|---|---|
| `status.json` direct read | `total 483`; `failed 150 / ok 295 / timed-out 22 / skipped 16`; failure-status acked **22**, unacked **16** (same 16 tickets 448–473) | observed — queue advanced by 4 completions after §1.1 |
| `counter` / `now_serving` / `jobs/` | `counter 496`, `now_serving 493`, job files 493–495 only (490/491/492 already drained) | observed — churn after §1.1 |
| `results/00000490.json` | `perf3d01-selftestc`, `failed` | observed |
| `results/00000491.json` | `terraindarkfix2-smoke`, `ok`, argv `--headless --path variant3d --script res://tests/t_terrain3d.gd` | observed — identifies the §1.2 live PID 7552 as job 491 (TERRAIN-DARK-FIX) |
| `results/00000492.json` | `seasonpath01-smoke-r3`, `failed` | observed |
| `Get-CimInstance Win32_Process -Filter "Name like 'Godot%'"` (~2 min after §1.2) | **3** processes: PID 14756 `--ui-test variant3d/uitest.json` (= job 494 `mapsmall01-json-uitest`); PID 5860 `--screenshot ...perf3d01_sync_240.png --screenshot-frames 240 --timeout 480` (= job 496 `perf3d01-sync240`); PID 12640 `--path variant3d` only — attribution **UNVERIFIED** | observed / inferred |

The §1.3 figures are **later snapshots**, not replacements for §1.1/§1.2. They confirm the
queue was still advancing while this worker read it. The lock ages also differ (§1.1 `6.2s`,
§1.2 `18.33s`) because the two commands ran ~12 s apart (derived).

---

## 2. Comparison with CLEAN-01, CLEAN-02 and GATE_READY_01

All four observations are of the same spool `variant3d\.godot_queue` — except CLEAN-01's
§2/§4 `assert_clean.py` output, which was still mis-wired to the **2D app spool**
(`history.total 254 / acknowledged 9`); CLEAN-02 fixed line 34 to the variant spool, so
CLEAN-02, GATE_READY_01 and QA-CLEAN-02 outputs are directly comparable.

| Field | CLEAN-01 §2 (before acks) | CLEAN-01 §4/#5 (after acks) | CLEAN-02 validation | GATE_READY_01 A | GATE_READY_01 B | **QA-CLEAN-02 (this check)** | Changed? |
|---|---|---|---|---|---|---|---|
| now_serving | 398 | 408 | not recorded | 478 | 483 | **491** | advanced continuously |
| next_ticket | 401 | 414 | not recorded | 479 | 490 | **496** | advanced continuously |
| pending | 3 `[398,399,400]` | 6 `[408…413]` | not recorded | 1 `[478]` | 7 `[483…489]` | **6 `[490…495]`** | count varies with churn |
| godot.lock (status cmd) | HELD 9.3s | HELD 50.5s | not recorded | HELD 0.9s | free | **HELD 6.2s** | flips with in-flight jobs |
| lock (assert_clean) | free (app spool) | free (app spool) | held_recent 7.78s | held_recent 9.52s | free | **held_recent 18.33s** | co-varies with status cmd |
| completed / history total | 397 / 398 | 407 / 407 | 411 | 466 / 466 | 469 / 470 | **479 / 480** | grew monotonically |
| statuses | failed 127, ok 248, timed-out 22, skipped 0 | failed 130, ok 255, timed-out 22, skipped 0 | not recorded | failed 142, ok 286, skipped 16, timed-out 22 | failed 142, ok 289, skipped 16, timed-out 22 | **failed 148, ok 293, skipped 16, timed-out 22** | `failed`/`ok` grow; `skipped` flat at 16; `timed-out` flat at 22 |
| acknowledged (gate failure-status) | 0 (app spool: 9) | 22 (variant; 98 total incl. 76 acked `failed`) | **22** | **22** | **22** | **22** | unchanged |
| **unacked failure-status (`timed-out`/`error`/`skipped`)** | 22 timed-out (pre-ack) | **0** | **0** | **16** | **16** | **16** | **unchanged since GATE_READY_01** |
| live Godot process count (formal poll) | 1 (PID 4508) | 1 (PID 4508) | 1 (PID 13768) | 1 (PID 21684) | 1 (PID 19436) | **1 (PID 7552)** | **count unchanged at 1; PID/command changes every poll** |
| assert_clean verdict / exit | CLEAN / 0 (wrong spool) | DIRTY / 1 (wrong spool) | DIRTY / 1 | DIRTY / 1 | DIRTY / 1 | **DIRTY / 1** | still DIRTY |

### 2.1 Did the 16 unacked skips change? — **No (16 → 16)**

- CLEAN-01's hygiene pass ended with **0** unacked failure-status jobs (all 22 historical
  `timed-out` acked; 2 unacked `failed` tickets 296/300 excluded by D-13). CLEAN-02's
  validation still showed `failures: []` at `total 411` (`CLEAN_02_variant_gate.md:96-105`).
- GATE_READY_01 snapshots A/B first show **16** unacked `skipped` jobs at `total 466/470`
  (`GATE_READY_01.md:105-113`). The 16 therefore appeared between CLEAN-02's validation and
  GATE_READY_01, in the ticket window **448–473** — during the churn from smoke/retry jobs.
- This check still reports exactly **16**, with the **same ticket set (448–473) and same
  error strings**; `acknowledged` remains 22. No new skip exists in tickets 474–495 despite
  the counter advancing to 496 (observed, derived).
- **Why (attributed, not guessed):** every error string is either a wait-threshold expiry
  (`ticket 451 waited > 600s`, `ticket 449 waited > 1800s`) or an explicit supersession
  (`ticket N was skipped (serving=M)`). The `id` fields and the `results/` directory names
  map each one to a known swarm job; their `-r2`/`-r3` retries and later serving tickets show
  that newer jobs for the same work were submitted while these older queued jobs waited.
  They are queue-contention supersessions, **not** new gate evidence and **not** a change in
  gate state.

| Ticket | id | Known job / owner | Skip cause (from error string) |
|---:|---|---|---|
| 451 | `audiosel02-smoke` | AUDIO-SEL-02 | waited > 600 s |
| 449 | `configwirer-smoke` | CONFIG-WIRE-RELIEF | waited > 1800 s |
| 448 | `motionanim01-rotor-smoke` | MOTION-ANIM-01 | superseded (serving=464) |
| 458 | `motionanim01-rotor-smoke-r2` | MOTION-ANIM-01 | superseded (serving=461) |
| 457 | `sp06-sun-smoke` | SP-6 | superseded (serving=458) |
| 450 | `weatherdriver01-smoke` | WEATHER-DRIVER-01 | superseded (serving=461) |
| 456 | `terraindarkfix2-p0` | TERRAIN-DARK-FIX | superseded (serving=461) |
| 452 | `qaparity01-uitest` | QA-PARITY-01 | superseded (serving=461) |
| 453 | `qaparity01-selftest` | QA-PARITY-01 | superseded (serving=461) |
| 466 | `seasonpath01-smoke` | SEASON-TEST-PATH-01 | superseded (serving=467) |
| 465 | `audiosel02-smoke` | AUDIO-SEL-02 | superseded (serving=475) |
| 469 | `darkrowall-t_combo_shore_mines` | DARKROW-ALL-01 | superseded (serving=475) |
| 470 | `darkrowall-t_combo_trees_mines` | DARKROW-ALL-01 | superseded (serving=475) |
| 471 | `darkrowall-t_terrain_shore` | DARKROW-ALL-01 | superseded (serving=475) |
| 472 | `darkrowall-t_combo_all` | DARKROW-ALL-01 | superseded (serving=475) |
| 473 | `darkrowall-t_terrain_trees` | DARKROW-ALL-01 | superseded (serving=475) |

### 2.2 Did the live process count change? — **Not at the formal polls (1 → 1)**

- Every prior formal poll and this one report **count 1**: CLEAN-01 PID 4508
  (`t_motion_capture.gd`), CLEAN-02 PID 13768 (`--self-test variant3d/selftest.json`),
  GATE_READY_01 A PID 21684 (`perf3d01_sync_c.png` capture), B PID 19436 (empty command
  string), QA-CLEAN-02 PID 7552 (`t_terrain3d.gd`). The **PID and command change each poll**
  because a different job is in flight (derived from `results/00000491.json`: job 491
  `terraindarkfix2-smoke`, TERRAIN-DARK-FIX, now `ok`).
- A **later** ad-hoc CIM read (§1.3) showed **3** live processes, attributable to job 494
  `mapsmall01-json-uitest`, job 496 `perf3d01-sync240`, and one `--path variant3d` process
  whose owner is **UNVERIFIED**. This is a later point-in-time observation during the same
  churn, not a contradiction of the formal poll result: it strengthens the conclusion that
  the queue is **not quiet** (derived). No process had to be started or killed by this worker
  to observe it.

---

## 3. VERDICT — **CLEAN is NOT signable now**

The gate result at this check is `DIRTY`, exit **1** (§1.2). Per
`variant3d/tools/CLEAN_GATE.md:100-103` (as cited by CLEAN-01 §4 and CLEAN-02 §4), a
meaningful verdict requires a quiet queue — no pending jobs and no live Godot process.
That condition does not hold. **No CLEAN claim is made.**

**Exact blockers at the primary poll (all three gate signals considered):**

1. **Process signal not clean** — 1 live Godot process (PID 7552,
   `--headless --path variant3d --script res://tests/t_terrain3d.gd`, attributable to job 491
   `terraindarkfix2-smoke`). A later snapshot showed 3 live processes (§1.3).
2. **History signal not clean** — **16 unacknowledged failure-status (`skipped`) jobs**,
   tickets 448–473, listed in §1.2 / attributed in §2.1. `acknowledged: 22` does not cover
   them; `FINAL_GATE_PLAN_01.md:86` requires *no* unacked `timed-out`/`error`/`skipped` job.
3. **Queue not quiet** — `pending = 6 [490, 491, 492, 493, 494, 495]` and `godot.lock`
   HELD (6.2 s at status poll; `held_recent` 18.33 s at assert_clean poll). The lock itself
   is a *clean* signal (`held_recent`, under the 300 s max), but it co-exists with a live
   process and pending jobs, so it cannot be read as an all-clear (derived).

**Explicitly not counted as blockers here (observed, derived):** the 148 `failed` entries in
`godot_runner.py status` (excluded from `FAILURE_STATUSES` by D-13); the 2 unacked `failed`
tickets 296/300 (excluded by D-13, unchanged by CLEAN-01); and stale/red `selftest.json`
plus the unfinished ladder (GATE_READY_01 §3–§4) — **out of scope and not re-verified here**,
carried forward only as context. **No donor visual-parity claim is made.**

---

## 4. Open questions

1. Will the 16 unacked `skipped` jobs be acknowledged (with concrete reasons and verified
   superseding PASS jobs) once their owning builders close, or will new retries keep adding
   to the set? No ack was written by this worker.
2. Can `pending` reach 0 and all Godot processes drain while new tickets (496+) keep arriving?
   The counter advanced from 496 during this check; queue state is a moving target.
3. Is the `--path variant3d`-only process (PID 12640, §1.3) a runner job or a direct/unmanaged
   launch? Attribution is **UNVERIFIED** from the command line alone.
4. Will a fresh integrated selftest/uitest and a completed ladder land before a formal gate is
   attempted? GATE_READY_01 §3–§4 blockers are not re-verified by this report.
5. Donor A/B visual parity remains UNVERIFIED; no claim is made here.

---

## 5. Summary

- Ran the two required read-only commands. `godot_runner.py status`: `now_serving 491`,
  `next_ticket 496`, `pending 6 [490…495]`, lock HELD 6.2 s, `completed 479`,
  statuses `failed 148 / ok 293 / skipped 16 / timed-out 22`. `assert_clean.py --json`:
  **DIRTY / exit 1**, 1 live Godot process (PID 7552, `t_terrain3d.gd`), lock `held_recent`,
  history `total 480 / acknowledged 22 / 16 unacked skipped`.
- The reason text `16 failed job(s)` is a fixed label; all 16 are `skipped`, and the 148
  `failed` entries are D-13-excluded and do not drive the verdict.
- Compared with CLEAN-01, CLEAN-02 and GATE_READY_01: the **16 unacked skips are unchanged**
  (same tickets 448–473, same causes) and the **formal live-process count is unchanged at 1**
  (PID changes each poll). Both are explained by continued swarm churn from known jobs —
  superseded smoke/retry jobs and a rotating in-flight job — not by any new gate evidence.
- **VERDICT: CLEAN is not signable.** Blockers: 1 live Godot process, 16 unacked skipped
  jobs, and 6 pending tickets with a held lock (queue not quiet). No visual-parity claim.
- **No runner-state mutation and no mutation of any project, source, test, config, fixture,
  asset, queue or git file was performed. No job was submitted, cancelled, reset, unwedged,
  acked or "doctored"; no Godot process was started or killed.** The only file written is
  this report.
