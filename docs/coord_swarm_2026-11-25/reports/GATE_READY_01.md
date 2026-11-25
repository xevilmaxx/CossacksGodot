---
id: GATE-READY-01
title: "Read-only report — current runner/gate readiness (no mutation)"
area: coordination / gate readiness
owner: GATE-READY-01 (read-only queue/gate readiness worker)
date: 2026-11-25
status: REPORT_ONLY__NO_RUNNER_STATE_MUTATION__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Only this report file was written. Allowed commands used: godot_runner.py status, assert_clean.py --json, and read-only file/dir reads."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot_caveat: "Runner numbers are point-in-time. Two status/clean snapshots were taken minutes apart and they differ materially (see §1); the queue is actively churning."
sources_read:
  - "python variant3d\\tools\\godot_runner.py status (twice, read-only)"
  - "python variant3d\\tools\\assert_clean.py --json (twice, read-only; exit 1 both times)"
  - "variant3d/.godot_queue/{counter,now_serving,jobs,results} (read-only)"
  - "docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md"
  - "docs/coord_swarm_2026-11-25/SWARM_BOARD.md"
  - "variant3d/selftest.json, variant3d/uitest.json"
  - "docs/coord_swarm_2026-11-25/reports/TERRAIN_DARK_FIX.md"
---

# GATE-READY-01 — current runner/gate readiness

**Labels:** `observed` = literal tool output / file fact read here; `derived` = arithmetic or
control-flow consequence of observed facts; `inferred` = plausible reading with caveat;
`UNVERIFIED` = cannot be proven from the read material. Citations are `path:line` in the
workspace root unless they name this report's own sections.

**No visual-parity claim is made anywhere in this report.** Donor A/B remains UNVERIFIED.

---

## 0. Mutation statement

**No runner-state mutation and no mutation of any project, source, test, config, fixture,
asset or git file was performed by this worker.** No job was submitted, cancelled, reset,
unwedged, acked or "doctored". No test was run. The *only* file written is this single
report. Both `godot_runner.py status` and `assert_clean.py --json` are read-only commands;
the live queue changes seen between snapshots are attributable to other swarm workers, not
to this worker (observed, derived).

---

## 1. Status outputs (read-only, two snapshots)

### Snapshot A — first poll

Command: `python variant3d\tools\godot_runner.py status` (exit 0).

| Field | Value (observed) |
|---|---|
| spool | `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue` |
| now_serving | 478 |
| next_ticket | 479 |
| pending | **1 — [478]** |
| godot.lock | **HELD (age 0.9s)** |
| completed | 466 |
| wait | max 1825.52 s, mean 106.07 s |
| max run | 605.56 s |
| statuses | `failed: 142, ok: 286, skipped: 16, timed-out: 22` |

Command: `python variant3d\tools\assert_clean.py --json` → **exit code 1**.

```json
{"clean": false, "verdict": "DIRTY",
 "reasons": ["1 Godot process(es) alive", "16 failed job(s) in status.json"],
 "checks": {
   "processes": {"clean": false, "count": 1, "details": [
     {"pid": 21684, "name": "Godot_v4.7.2-stable_win64.exe",
      "command": "...godot.EXE --headless --path variant3d -- --screenshot ...\\perf3d01_sync_c.png --screenshot-frames 120 --timeout 210"}]},
   "lock": {"clean": true, "exists": true, "state": "held_recent",
            "age_sec": 9.515370607376099, "max_age_sec": 300.0},
   "history": {"clean": false, "enabled": true, "total": 466, "acknowledged": 22,
               "failures": [16 skipped jobs — list identical to Snapshot B below]}}}
```

### Snapshot B — fresh poll, minutes later

Command: `python variant3d\tools\godot_runner.py status` (exit 0).

| Field | Value (observed) |
|---|---|
| spool | same `variant3d\.godot_queue` |
| now_serving | **483** |
| next_ticket | **490** |
| pending | **7 — [483, 484, 485, 486, 487, 488, 489]** |
| godot.lock | **free** |
| completed | 469 |
| wait | max 1825.52 s, mean 105.64 s |
| max run | 605.56 s |
| statuses | `failed: 142, ok: 289, skipped: 16, timed-out: 22` |

Command: `python variant3d\tools\assert_clean.py --json` → **exit code 1**.

```json
{"clean": false, "verdict": "DIRTY",
 "reasons": ["1 Godot process(es) alive", "16 failed job(s) in status.json"],
 "checks": {
   "processes": {"clean": false, "count": 1,
                 "details": [{"pid": 19436, "name": "Godot_v4.7.2-stable_win64.exe", "command": ""}]},
   "lock": {"clean": true, "exists": false, "state": "free", "age_sec": null, "max_age_sec": 300.0},
   "history": {"clean": false, "enabled": true, "total": 470, "acknowledged": 22,
               "failures": [ ...same 16 skipped jobs... ]}}}
```

The 16 history failures are **all `status: skipped`** (none is `failed`/`error`/`timed-out` in
this list): tickets 451 `audiosel02-smoke` (>600 s wait), 449 `configwirer-smoke` (>1800 s
wait), 457 `sp06-sun-smoke`, 450 `weatherdriver01-smoke`, 456 `terraindarkfix2-p0`,
452 `qaparity01-uitest`, 453 `qaparity01-selftest`, 458 `motionanim01-rotor-smoke-r2`,
448 `motionanim01-rotor-smoke`, 466 `seasonpath01-smoke`, 472/470/473/469/471
`darkrowall-*`, 465 `audiosel02-smoke` — all skipped because a newer ticket was already
being served (observed). `acknowledged` stays **22** in both snapshots; the skipped set is
**unchanged**, so these remain unacked failure-status entries for the clean gate
(`FINAL_GATE_PLAN_01.md:86`: "No unacked failure-status (`timed-out`/`error`/`skipped`) jobs").

### Spool detail (read-only)

- Spool dir `variant3d/.godot_queue` contains `counter`, `now_serving`, `status.json`,
  `jobs/`, `results/`; at Snapshot B `counter=490`, `now_serving=483`, `godot.lock` absent
  (observed), matching Snapshot B.
- Ticket 478 (Snapshot A pending) was `00000478_rotorasset01-import-r2` — a MOTION-ANIM-01
  rotor asset import, not a gate job (observed from jobs dir and `status.json`).
- Pending set at Snapshot B: 483 = now_serving (no job JSON present at the moment of read),
  484 `seasonpath01-smoke-r2`, 485 `mapsmall01-json-selftest`,
  486 `darkrowall-t_terrain_trees-r1`, 487 `audiosel02-smoke`, 488 `weatherdriver01-smoke`,
  489 `motionanim01-rotor-boot` (observed). **Every one maps to a still-open builder ticket**
  (derived).

**Derived:** `now_serving` advanced 478→483 and `next_ticket` 479→490 while this worker
read files; `pending` grew 1→7; a Godot process was alive in both snapshots (different PIDs,
first with a visible `perf3d01_sync_c.png` capture command, second with an empty command
string). The queue is busy and churning, and **P-3 is not satisfied**
(`FINAL_GATE_PLAN_01.md:80-88`). The lock flipping HELD→free is not evidence of a quiet
queue: live process + 7 pending jobs contradict it (derived).

---

## 2. Prerequisites and which are still open

### 2.1 Plan prerequisites (`FINAL_GATE_PLAN_01.md:53-88`)

| Plan row | Ticket / session id | Plan-time state | Current board state (observed) | Still open? |
|---|---|---|---|---|
| P-1/A | **MAP-SMALL-01** — `ses_dee1ffa4dffeNE1DyOlFaHFllL` | RUNNING (`SWARM_BOARD.md:66`) | RUNNING at `:66`; `reports/MAP_SMALL_01_report.md` **ABSENT on disk**; job 485 `mapsmall01-json-selftest` pending | **YES — open blocker** |
| P-1/B | **TERRAIN-DARK-FIX** — `ses_dedec4474ffee1ghS4x7WOLRug` | RUNNING (`FINAL_GATE_PLAN_01.md:60` citing `:186`) | `TERRAIN_DARK_FIX.md` now EXISTS (mtime 11:09:42); board `:186` **REPORT DELIVERED**, but `p0_fix2: "PENDING"` and "final-formula P0 re-capture is pending" (`TERRAIN_DARK_FIX.md:16,155-157,217`) | **PARTIAL** — stage-1 P0 green (ticket 441), final-formula P0 re-capture not landed |
| P-1/C | **QA-PARITY-01** — `ses_dede47f21ffeN0cMxpshIcpAOZ` | RUNNING (`:221` in plan) | RUNNING at `SWARM_BOARD.md:230`; `reports/QA_PARITY_01.md` **ABSENT**; its smokes 452 `qaparity01-uitest` and 453 `qaparity01-selftest` were **skipped** | **YES — open blocker** |
| P-1/D | All other RUNNING code builders (plan `:62`) | RUNNING | See §2.2 — several closed, but 7 of the named builders remain open | **YES — partially open** |
| P-2 | Jobs green: integrated selftest / uitest / TRN-DATA 411 / 2D gates | Not green / mixed | Integrated selftest still red (§3); TRN-DATA 411 failed on missing `.ctex` per plan `:75`; 2D `app/**` was confirmed green by `QA_2D_GATES_01` (board `:241`) but **not re-run here** | **YES — selftest not green** |
| P-3 | `pending=0`, no held lock, 0 live Godot processes, `assert_clean` CLEAN exit 0, no unacked failure-status jobs | Not satisfied | §1: DIRTY/exit 1 twice, 1 live Godot process, 7 pending, 16 unacked skipped jobs | **YES — open blocker** |

### 2.2 Every RUNNING row on the current board (`SWARM_BOARD.md`, observed)

| Line | Ticket / session id | Gate relevance |
|---|---|---|
| 66 | MAP-SMALL-01 — `ses_dee1ffa4dffeNE1DyOlFaHFllL` | **P-1/A direct blocker** (owns `selftest.gd`/`config.json`) |
| 120 | MINIMAP-QUAD-01 — `ses_dedf02a90ffdT7nAiMWDUbpMQj` | P-1/D — owns `hud3d_adapter.gd` (file under test) |
| 219 | INVENTORY-01 — `ses_dedd0b783ffeXGxtcSZa3SbA9o` | Doc only; **conflicting row** at `:242` says DONE |
| 220 | LINKS-01 — `ses_dedd0b77affePHsOgnl49CI27l` | Doc only |
| 226 | AUDIO-SEL-02 — `ses_dede47f36ffeaGALXfX3VRRfEG` | **P-1/D** — owns `audio.gd` wiring; job 487 pending |
| 227 | CONFIG-WIRE-RELIEF — `ses_dede47f35ffeJtm9VwqT6yGQNB` | **P-1/D** — owns `main.gd` gate |
| 228 | WEATHER-DRIVER-01 — `ses_dede47f33ffejvS2MRfuAE33S6` | **P-1/D** — owns weather→`world3d_fx` wiring; job 488 pending |
| 230 | QA-PARITY-01 — `ses_dede47f21ffeN0cMxpshIcpAOZ` | **P-1/C direct blocker** |
| 233 | MAPSIZE-01 — `ses_dede3a392ffe6P3B6Ttaon7o44` | **P-1/D** — owns `menu.gd` |
| 236 | README-UPDATE-01 — `ses_deddede29ffep3WHPBG8kRHQYW` | Doc only; **conflicting row** at `:217` says DONE |
| 237 | PERF-3D-01 — `ses_deddede28ffePAlAptFGEy4kzn` | **P-1/D** — owns perf hotpaths; live capture job seen in Snapshot A |
| 239 | DARKROW-ALL-01 — `ses_deddb4a21ffeMNC2rRgf4X3t4F` | Post-plan atom fix; owns P1–C4 dark-row asserts; job 486 pending; report ABSENT |
| 244 | SEASON-TEST-PATH-01 — `ses_dedd5c6b9ffebY8CjZ2LHhmm8U` | Post-plan season atom paths; job 484 pending; report ABSENT |
| 246 | DESERT-REMAP-02 — `ses_dedc825e3ffeCybE4oju7Ds2Az` | Season asset remap; report ABSENT |
| 247 | PROP-W-PLAN-01 — `ses_dedc825dfffe65At77RG2CJO98` | Plan doc, no code |
| 248 | SP8-STATUS-01 — `ses_dedc825deffegTIEqiL78uxsGw` | Audit of season atom |
| 251 | QA-DOCS-01 — `ses_deddad2e3ffe4Cyl6fHeoh0yfz` | Doc audit; report ABSENT |
| 253 | QA-ATOM-RESULTS-01 — `ses_dedcdf2c3ffeeNnd0m5fmCmM6R` | Audit of atom JSONs; report ABSENT |

**Plan P-1/D rows that have since closed (observed, do not count as open):**
`CONFIG-UI-01` DONE (`:184`), `SP-1` **DONE — TERMINATED** (`:169`, plan said RUNNING), `SP-4` DONE (`:174`), `ASSET-IMPORT-01` DONE (`:192`), `DEFAULTS-VERIFY-01` DONE (`:234`), `CONFIG-COUNT-01` DONE (`:235`), `CONFIG-WIRE-SEL` DONE (`:188`), `MOTION-ANIM-01` = REPORT DELIVERED / rotor import finalizing (`:117`), `SP-6` = REPORT DELIVERED (`:175`), `TERRAIN-DARK-FIX` = REPORT DELIVERED (`:186`).
Derived: the plan's P-1 snapshot is partly stale; the *live* board and the live queue, not the plan table, decide readiness.

---

## 3. Artifact state (current files, not a final gate)

| Artifact | `passed` | Steps | Failures | mtime (observed) | Reading |
|---|---|---|---|---|---|
| `variant3d/selftest.json` | **false** (`:2`) | **29** steps (`:12-186`) | **1 — `build`** (`:33-36`: "house built in 3.1 s of build time" failed); 28/29 pass | 2026-11-25T10:57:24+01:00 | **INTEGRATED SELFTEST RED.** Matches QA-AUDIT worktree 28/29 (`build`) and conflicts with the older `PROGRESS.md:188` "29/29" claim (`FINAL_GATE_PLAN_01.md:76,226`). |
| `variant3d/uitest.json` | **true** (`:2`) | **17** steps (`:3-88`), all `passed: true` | none | 2026-11-25T10:51:54+01:00 | Green artifact, but **~32 min older** than the live runner activity; the final gate requires a *fresh* job (`FINAL_GATE_PLAN_01.md:77,157,165`). |

**Derived:** both artifacts predate the current queue churn (now_serving 478→483, completed
466→469). Per the plan (`:76,162-165`) and QA-AUDIT F-01, an isolated or stale 17/17 or
per-job 29/29 is explicitly **not** sufficient. Neither file is treated as a final gate here.

---

## 4. VERDICT: **NOT_READY**

The final whole-system gate must not be run now. Exact blockers:

1. **Queue busy / churning (P-3 violated).** `pending=1→7`, `now_serving=478→483`,
   `next_ticket=479→490`, a live Godot process in both snapshots, and
   `assert_clean.py --json` = `DIRTY`, exit **1** twice (§1). Gate needs `pending=0`, 0 live
   Godot processes, `CLEAN`, exit 0 (`FINAL_GATE_PLAN_01.md:84-85,170`).
2. **16 unacked failure-status (`skipped`) jobs** on the variant spool; acks stay 22
   (§1, `FINAL_GATE_PLAN_01.md:86`).
3. **Integrated selftest red.** `variant3d/selftest.json` `passed:false`, 28/29, `build`
   failing (§3). Gate requires fresh **29/29** (`FINAL_GATE_PLAN_01.md:162-164`).
4. **P0 final-formula re-capture not landed.** TERRAIN-DARK-FIX's stage-1 P0 job 441 passed
   (`mean_luma=98.680`, `max_luma=172.139`), but `p0_fix2: "PENDING"` and the final LIGHT-02
   formula P0 re-capture is pending (`TERRAIN_DARK_FIX.md:16,155-157,212-217`). Condition B
   only partially satisfied.
5. **Ladder not passed.** Both ladder attempts stopped at P0
   (`SWARM_BOARD.md:95,155`; `FINAL_GATE_PLAN_01.md:220-221`); P1–C4, S1 and FINAL never
   executed, so the required piece→combo ladder is incomplete
   (`FINAL_GATE_PLAN_01.md:87,98-115,148-159`).
6. **P-1 tickets still open.** MAP-SMALL-01 RUNNING with no report (job 485 pending);
   QA-PARITY-01 RUNNING with no report (smokes 452/453 skipped); plus open builders
   MINIMAP-QUAD-01, AUDIO-SEL-02, CONFIG-WIRE-RELIEF, WEATHER-DRIVER-01, MAPSIZE-01,
   PERF-3D-01, DARKROW-ALL-01 and SEASON-TEST-PATH-01 all still own files under test (§2.2).
7. **Donor A/B absent (standing UNVERIFIED caveat).** No donor GPU A/B frame exists
   (`TERRAIN_DARK_FIX.md:30,172-173`; `FINAL_GATE_PLAN_01.md:172-173,208-214,230`). This
   worker makes **no visual-parity claim**; a future green gate is a system gate, not a
   donor-parity certificate.

**Not counted as blockers here (observed):** 2D `app/**` gates were independently confirmed
green by `QA_2D_GATES_01` (board `:241`: selftest 29/29 job 1348, uitest 17/17 job 1349,
CLEAN exit 0); this worker did **not** re-run them, so their current-tree status is
UNVERIFIED by this report. `TERRAIN_DARK_FIX.md` and `QA_2D_GATES_01.md` exist on disk
(observed).

---

## 5. Open questions

1. Will ticket 485 `mapsmall01-json-selftest` land a fresh integrated selftest at **29/29 at
   both map sizes** with no pass criterion changed (`FINAL_GATE_PLAN_01.md:59`)?
2. Will the final LIGHT-02-formula P0 re-capture clear the strict gates
   `ground_mean_luma>=40` + `ground_max_luma>=100` with `SCRIPT ERROR == 0`
   (`TERRAIN_DARK_FIX.md:16,155-157`; `P0_GATE_01.md:81-105`)?
3. Can the queue reach `pending=0`, zero live Godot processes and `CLEAN`/exit 0 while new
   tickets (483–489) keep arriving? Queue state is a moving target
   (`FINAL_GATE_PLAN_01.md:254-255`).
4. Will DARKROW-ALL-01's inapplicable dark-row asserts in P1–C4 be resolved without weakening
   any test (`FINAL_GATE_PLAN_01.md:242-248`; ticket 486 pending)?
5. Will QA-PARITY-01 produce a fresh integrated 29/29 + 17/17 + CLEAN result, superseding the
   stale artifacts in §3?
6. Donor visual parity / owner visual review remains UNVERIFIED; no donor GPU A/B exists
   (`TEST_MATRIX.md:73-74` as cited by `FINAL_GATE_PLAN_01.md:51,208-214`).
7. Board inconsistency: `INVENTORY-01` is both RUNNING (`:219`) and DONE (`:242`);
   `README-UPDATE-01` is both DONE (`:217`) and RUNNING (`:236`). Derived: the State column
   is not fully reconciled; do not infer closure from either row alone.

---

## 6. Summary

- **READINESS: NOT_READY.** Two read-only polls show a busy, advancing queue
  (`pending 1→7`, `now_serving 478→483`, 1 live Godot process) and `assert_clean.py --json`
  returning **DIRTY / exit 1** both times, with 16 unacked skipped jobs.
- Integrated `variant3d/selftest.json` is **red** (`passed:false`, 28/29, `build` failed);
  `uitest.json` is green 17/17 but stale. Neither is accepted as a final gate.
- The three named P-1 prerequisites are not all landed: MAP-SMALL-01 and QA-PARITY-01 are
  RUNNING with no reports; TERRAIN-DARK-FIX is delivered but its final-formula P0 re-capture
  is PENDING. Multiple other RUNNING builders still own files under test.
- The piece→combo ladder never got past P0 in either attempt, so the final gate is not
  authorised by the plan.
- **No runner-state mutation and no project/file mutation was performed. No visual-parity
  claim is made.** The only write is this report.

---

*End of GATE-READY-01. Read-only observation; no job submission, no cancellation/reset/unwedge/ack/doctor, no code or git change.*
