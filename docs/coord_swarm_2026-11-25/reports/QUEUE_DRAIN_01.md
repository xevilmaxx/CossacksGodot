---
id: QUEUE-DRAIN-01
title: "Exact COORD-only sequence to drain the variant queue and run the final gates solo"
area: coordination / variant3d queue / final gates
owner: QUEUE-DRAIN-01 (read-only planning subagent; session spawned by COORD)
date: 2026-11-25
status: PLAN_ONLY__NO_RUNNER_STATE_MUTATION__NO_JOB_SUBMISSION__NO_CODE_EDIT
scope: "This report file only. No run/cancel/reset/unwedge/ack/doctor, no Godot process started or killed, no code/config/test/fixture/result-JSON/queue/git edit. Commands below are INSTRUCTIONS FOR COORD, not actions taken by this worker."
labels: [observed, derived, inferred, UNVERIFIED]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
sources_read:
  - "docs/coord_swarm_2026-11-25/reports/GATE_FAIL_01.md"
  - "docs/coord_swarm_2026-11-25/reports/QA_CLEAN_02.md"
  - "docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md"
  - "docs/coord_swarm_2026-11-25/TEST_MATRIX.md"
  - "docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md"
  - "docs/coord_swarm_2026-11-25/FINAL_CHECKLIST.md"
  - "docs/coord_swarm_2026-11-25/reports/P0_FRESH_CAPTURE_01.md"
  - "docs/coord_swarm_2026-11-25/reports/RECHECK_P0_FINAL.md"
  - "docs/coord_swarm_2026-11-25/reports/RECHECK_S1.md"
  - "docs/coord_swarm_2026-11-25/reports/QA_2D_GATES_01.md"
  - "docs/coord_swarm_2026-11-25/reports/CLEAN_01_variant_clean.md"
  - "variant3d/tools/godot_runner.py"
  - "variant3d/tools/assert_clean.py"
  - "variant3d/tools/CLEAN_GATE.md"
  - "reports/TEST_P1_report.md, TEST_P2_report.md, TEST_P3_report.md, TEST_C1_report.md, TEST_C2_report.md, TEST_C3_report.md, TEST_C4_report.md, TEST_S1_report.md"
snapshot_caveat: "All queue numbers below are point-in-time. One fresh read-only status/assert_clean poll was made by this worker (§0.2); the queue is a moving target (QA_CLEAN_02.md:128-141; FINAL_GATE_PLAN_01.md:10). COORD must re-poll at the gate window."
not_landed:
  - "CLEAN_ACK_PLAN_01.md — NOT on disk (recursive glob: 0 hits). Ack commands in §(d) are derived from CLEAN_01_variant_clean.md:19-29 and godot_runner.py:538-564, and must be re-checked when/if that plan lands."
  - "RUNNER_FIX_01.md — NOT on disk (recursive glob: 0 hits). §(c) states the patch intent only; no patch was applied."
---

# QUEUE-DRAIN-01 — exact COORD-only drain + solo final-gate sequence

**Citation shorthand (observed):** `R/` = `docs/coord_swarm_2026-11-25/reports/`;
`S/` = `docs/coord_swarm_2026-11-25/`; `V/` = `variant3d/`;
`Q/` = `variant3d/.godot_queue/`. Every citation is workspace-relative `path:line`.
Labels follow `R/FINAL_GATE_PLAN_01.md:30-35`: `observed` = literal file/tool output,
`derived` = arithmetic or control-flow consequence, `inferred` = caveated reading,
`UNVERIFIED` = cannot be proven from available material.

**Purpose.** Convert the diagnoses into one ordered, executable, COORD-only sequence:
freeze submissions → drain → (optionally patch) → ack only evidence-backed history →
run the ladder rows serially with second-agent re-checks → run selftest, uitest and
`assert_clean.py --json` → confirm 2D gates → sign off. No step here was executed by
this worker.

---

## 0. Mutation statement and fresh read-only baseline

### 0.1 No mutation by this worker
Only this report file was written. Read-only commands used: `git status --short`,
`python variant3d\tools\godot_runner.py status`,
`python variant3d\tools\assert_clean.py --json`, `Get-Process -Name Godot*`, and
JSON/file reads under `Q/results/`. **No job was submitted, cancelled, reset,
unwedged, acknowledged or "doctored"; no Godot process was started or killed; no
code, config, test, fixture, result JSON, queue file or git file was edited.**
Every `run` / `ack` command below is an instruction for COORD (compare the discipline
declared in `R/GATE_FAIL_01.md:6,25` and `R/QA_CLEAN_02.md:33-40`).

### 0.2 Fresh snapshots taken read-only by this worker (observed)
`python variant3d\tools\godot_runner.py status`:
```text
now_serving = 508 ; next_ticket = 508 ; pending = 0 []
godot.lock = free ; completed = 497
max wait = 1825.52s   mean wait = 107.16s   max run = 605.56s
statuses = {'failed': 153, 'ok': 305, 'skipped': 16, 'timed-out': 23}
```
`python variant3d\tools\assert_clean.py --json` → **DIRTY / exit 1**:
`processes.clean=true` (count **0**), `lock.state=free`, `history.total=497`,
`acknowledged=22`, **17** unacked `timed-out`/`error`/`skipped` entries.
`Get-Process -Name Godot*` produced **no output** (0 Godot processes).

**Derived delta vs `R/QA_CLEAN_02.md:60-116`:** that report counted **16** unacked
entries (all `skipped`, tickets 448–473). The fresh poll shows **17**: the same 16
plus **ticket 494 `mapsmall01-json-uitest`, `status: timed-out`**, `exit: -9`,
hard timeout after 256.30 s (`Q/results/00000494.json:1-20`, observed). COORD's plan
must account for 17 acks, not 16. The `failed` entries (153 in `status`) are
**excluded** from the gate by D-13 (`assert_clean.py:42`; `R/QA_CLEAN_02.md:118-126`)
and are not blockers.

**Important negative observation (observed):** enumerating `Q/results/*.json` for
tickets ≥ 440, there is **no `status: ok` integrated selftest or uitest job after
ticket 440** (`440 configwireh-uitest ok`; 452/453 skipped; 455/461/482/485/490
failed; 494 timed-out). Therefore tickets **452, 453 and 494 have no verified
superseding PASS yet** — they cannot be acked until step (f) produces fresh green
selftest/uitest. This is the one deliberate dependency reorder inside the task's
sequence (see §(d) and §(f)).

`git status --short` (observed, read-only) shows modified docs and
`V/tests/results/t_terrain_only.json` plus untracked reports/assets. This is
**concurrent swarm churn**, not gate evidence; it is the reason for the freeze in
step (a) and for re-verifying mtimes at each step.

---

## 0.3 One-line rule base

- Piece → combo → FINAL, strict order, one ticket per row, no reorder/parallelise
  (`S/TEST_MATRIX.md:11,57`; `S/CAPTURE_RECHECK.md:12,249`; `R/FINAL_GATE_PLAN_01.md:100-103`).
- One Godot at a time through the **variant** FIFO runner; Windows `python` (3.14),
  never `python3`, never direct `godot` (`S/TEST_MATRIX.md:70-72`; `R/FINAL_GATE_PLAN_01.md:47-49`;
  `V/tools/godot_runner.py:3-33`).
- Second agent re-checks PNG/JSON/stderr before a row is PASS; the owner never
  self-certifies (`S/TEST_MATRIX.md:58-59,75`; `S/CAPTURE_RECHECK.md:34,54,247-249`).
- Stop at first failing row; never rerun hoping for green; never weaken a test
  (`S/TEST_MATRIX.md:60-68`; `R/FINAL_GATE_PLAN_01.md:180-201`).
- Metrics never override donor visual A/B; donor parity and owner visual review stay
  **UNVERIFIED** (`S/TEST_MATRIX.md:73-74`; `R/FINAL_GATE_PLAN_01.md:172-173,208-214`).

---

## 1. Prerequisites (all must hold before step (a))

| # | Prerequisite | Evidence |
|---|---|---|
| PR-1 | COORD is the **only** executor. All other agents pause new `godot_runner.py run` submissions and all `ack`/`cancel`/`reset`/`unwedge`/`doctor` calls. | `R/GATE_FAIL_01.md:131-141`; `R/FINAL_GATE_PLAN_01.md:53-88`; `R/QA_CLEAN_02.md:33-40` |
| PR-2 | Freeze on edits to `V/tests/*.gd`, shaders, `V/config.json`, fixtures and assets for the whole gate window; parse-error jobs are a separate failure class that can red a gate. | `R/GATE_FAIL_01.md:112-114,138`; `R/FINAL_GATE_PLAN_01.md:62,94-96` |
| PR-3 | Read-only polls (`status`, `assert_clean.py --json`, file/dir reads) remain allowed throughout. | `R/QA_CLEAN_02.md:8,35-40`; `V/tools/assert_clean.py:13-21` |
| PR-4 | Owner approval recorded for (i) any runner patch and (ii) each `ack` (ack is a queue-state mutation). | `V/tools/godot_runner.py:538-564`; `R/CLEAN_01_variant_clean.md:19-29`; `V/tools/CLEAN_GATE.md:105-113` |
| PR-5 | Windows `python` 3.14, cwd = repo root; repo-root-relative paths; a private temp capture dir outside the repo. | `S/TEST_MATRIX.md:71-72`; `R/FINAL_GATE_PLAN_01.md:88,117-121` |
| PR-6 | `R/CLEAN_ACK_PLAN_01.md` and `R/RUNNER_FIX_01.md` have **not landed** → their content is **UNVERIFIED**; if they land mid-window, stop and reconcile this plan before continuing. | glob over `docs/**`: 0 hits (this worker, observed) |
| PR-7 | Donor A/B and owner visual review are out of scope and stay UNVERIFIED; no donor access. | `R/FINAL_CHECKLIST.md:317-345`; `S/TEST_MATRIX.md:73-74` |

Temp root used below (COORD creates it once; outside the repo):
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\queue_drain_01\`
(cf. prior roots `S/CAPTURE_RECHECK.md:49`, `R/P0_FRESH_CAPTURE_01.md:77`).

---

## 2. Ordered COORD checklist

### (a) Pause new agent submissions — before any queue interaction

**Action (organisational, no command):** broadcast the freeze in PR-1/PR-2 and record
the wall-clock start time. Permitted: read-only `status` / `assert_clean.py --json` /
file reads. Forbidden from other agents: `run`, `ack`, `cancel`, `reset`, `unwedge`,
`doctor`, and edits to any file under test. Cite `R/GATE_FAIL_01.md:138,141` and
`R/FINAL_GATE_PLAN_01.md:62,94-96`.

**Expected:** no new ticket is allocated after the freeze. Verify read-only:
```
python variant3d\tools\godot_runner.py status
```
Expected: `next_ticket` unchanged across two polls spaced ≥30 s (fresh baseline at
this worker's read: **508**). **Stop/failure:** if `next_ticket` advances, the freeze
failed → re-issue it and restart from (a); never submit into churn
(`R/FINAL_GATE_PLAN_01.md:92-96`; `R/QA_CLEAN_02.md:254-255`).

---

### (b) Poll `status` read-only until pending=0, lock free, no Godot process

Run exactly these three read-only commands; repeat until all three signals are quiet:
```
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
powershell -NoProfile -Command "(Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue | Measure-Object).Count"
```
**Quiet condition (all required):**
- `pending = 0 []` and `godot.lock = free` (`V/tools/godot_runner.py:440-461`;
  `R/FINAL_GATE_PLAN_01.md:84`; `V/tools/CLEAN_GATE.md:100-103`);
- process count **0** (`V/tools/assert_clean.py:110-112`);
- `assert_clean.py --json` shows `processes.clean=true`, `lock.state=free`.
  History may still be DIRTY at this point — that is cleared in (d)/(f), not here.

**At this worker's fresh read (§0.2)** the first three signals were already satisfied
(`pending 0`, lock free, 0 processes); only history was DIRTY. Re-poll at gate time —
the queue is a moving target (`R/QA_CLEAN_02.md:128-141`).

**Stop/failure:** `pending>0`, a held lock, or any live Godot PID → wait and re-poll;
do **not** submit. If a lock is held ≥300 s with no live owner (`STALE_SEC`,
`V/tools/godot_runner.py:54,324-339`), that is a **decision point for COORD**, not an
automatic `doctor`/`unwedge`: those commands can advance serving and kill Godot
children (`V/tools/godot_runner.py:275-302,464-490`; `R/GATE_FAIL_01.md:100,141`).
Record each poll verbatim in COORD's own log.

---

### (c) Apply the runner patch **if approved** — otherwise proceed serialized

`R/RUNNER_FIX_01.md` **has not landed** (PR-6; UNVERIFIED). If COORD has an approved
patch, apply it only now, while the queue is drained and no Godot is running. Patch
intent from `R/GATE_FAIL_01.md:139,145`:

1. `reap_spawned_godot()` — kill only PIDs this job actually spawned
   (`V/tools/godot_runner.py:243-253`, snapshot at `:397`, cleanup at `:424`).
2. `wait_for_turn()` stale-lock branch — never release `godot.lock` while the owning
   PID is alive (`V/tools/godot_runner.py:324-339`; `STALE_SEC` `:54`).
3. Log lock owner / reap targets so the exact killer is distinguishable next time
   (`R/GATE_FAIL_01.md:129,145`).

Read-only syntax check after patching (before any `run`):
```
python -c "import ast,pathlib; ast.parse(pathlib.Path('variant3d/tools/godot_runner.py').read_text(encoding='utf-8')); print('AST_OK')"
```
**Expected:** `AST_OK`. Then **re-run all three commands in (b)** — patching the tool
invalidates the earlier snapshot.

**Stop/failure:** no approval → skip (c) and rely on strict serialization only. Any
banner-only, empty-stderr exit 1 during the gate window after this point is to be
treated as a harness race and escalated, never as a test failure
(`R/GATE_FAIL_01.md:42-45,133,139`). If a patch is applied, re-poll (b) first.

---

### (d) Ack **only** resolved failure-status tickets — verified supersedes required

Ack command form (`R/CLEAN_01_variant_clean.md:19-29`; `V/tools/godot_runner.py:538-564`;
`V/tools/CLEAN_GATE.md:105-113`):
```
python variant3d\tools\godot_runner.py ack <ticket> --reason "<concrete evidence>"
```
Expected per ack: stdout `ticket <N> acknowledged: <reason>`, exit 0; the tool sets
`acknowledged` / `ack_reason` / `ack_at` on `Q/results/<ticket>.json` and syncs the
same fields into `Q/status.json` (`V/tools/godot_runner.py:550-563`).
`assert_clean.py` then skips that entry while still counting it
(`V/tools/assert_clean.py:166-181`).

**Mandatory pre-ack verification (read-only)** — every supersede must be observed
`status: ok` in `Q/results/`, per `R/CLEAN_01_variant_clean.md:25-29`:
```
python -c "import json; [print(t, (lambda d:(d.get('id'),d.get('status'),d.get('exit')))(json.load(open(f'variant3d/.godot_queue/results/{t:08d}.json')))) for t in (476,464,479,487,496,480,499,506,505,493,507,486)]"
```
Expected (observed by this worker, derived from `Q/results/*.json`):
```
476 motionanim01-rotor-smoke-r3 ok 0
464 configwirer-smoke-r2 ok 0
479 weatherdriver01-smoke ok 0
487 audiosel02-smoke ok 0
496 terraindarkfix2-p0-r3 ok 0
480 sp06-sun-smoke-r2 ok 0
499 seasonpath01-smoke-r4 ok 0
506 darkrowall-t_combo_shore_mines-r1 ok 0
505 darkrowall-t_combo_trees_mines-r1 ok 0
493 darkrowall-t_terrain_shore-r1 ok 0
507 darkrowall-t_combo_all-r1 ok 0
486 darkrowall-t_terrain_trees-r1 ok 0
```

**Ack these 14 now** (ticket → verified `ok` supersede; skip cause from
`R/QA_CLEAN_02.md:185-202`; supersedes observed in `Q/results/`):

| Ticket | Supersede (ok) | Concrete `--reason` to use |
|---:|---:|---|
| 448 | 476 | `superseded by ok job 476 motionanim01-rotor-smoke-r3 (QA_CLEAN_02.md:189; Q/results/00000476.json)` |
| 449 | 464 | `superseded by ok job 464 configwirer-smoke-r2 (QA_CLEAN_02.md:188; Q/results/00000464.json)` |
| 450 | 479 | `superseded by ok job 479 weatherdriver01-smoke (QA_CLEAN_02.md:192; Q/results/00000479.json)` |
| 451 | 487 | `superseded by ok job 487 audiosel02-smoke (QA_CLEAN_02.md:187; Q/results/00000487.json)` |
| 456 | 496 | `superseded by ok job 496 terraindarkfix2-p0-r3 (QA_CLEAN_02.md:193; Q/results/00000496.json)` |
| 457 | 480 | `superseded by ok job 480 sp06-sun-smoke-r2 (QA_CLEAN_02.md:191; Q/results/00000480.json)` |
| 458 | 476 | `superseded by ok job 476 motionanim01-rotor-smoke-r3 (QA_CLEAN_02.md:190; Q/results/00000476.json)` |
| 465 | 487 | `superseded by ok job 487 audiosel02-smoke (QA_CLEAN_02.md:197; Q/results/00000487.json)` |
| 466 | 499 | `superseded by ok job 499 seasonpath01-smoke-r4 (QA_CLEAN_02.md:196; Q/results/00000499.json)` |
| 469 | 506 | `superseded by ok job 506 darkrowall-t_combo_shore_mines-r1 (QA_CLEAN_02.md:198; Q/results/00000506.json)` |
| 470 | 505 | `superseded by ok job 505 darkrowall-t_combo_trees_mines-r1 (QA_CLEAN_02.md:199; Q/results/00000505.json)` |
| 471 | 493 | `superseded by ok job 493 darkrowall-t_terrain_shore-r1 (QA_CLEAN_02.md:200; Q/results/00000493.json)` |
| 472 | 507 | `superseded by ok job 507 darkrowall-t_combo_all-r1 (QA_CLEAN_02.md:201; Q/results/00000507.json)` |
| 473 | 486 | `superseded by ok job 486 darkrowall-t_terrain_trees-r1 (QA_CLEAN_02.md:202; Q/results/00000486.json)` |

Worked example (one command only; repeat the form for the other 13):
```
python variant3d\tools\godot_runner.py ack 448 --reason "superseded by ok job 476 motionanim01-rotor-smoke-r3 (QA_CLEAN_02.md:189; Q/results/00000476.json)"
```

**Defer exactly 3 entries to step (f)** — no verified PASS supersede exists yet
(§0.2, observed): ticket **452** `qaparity01-uitest` (skipped), **453**
`qaparity01-selftest` (skipped), **494** `mapsmall01-json-uitest` (timed-out,
`Q/results/00000494.json:1-20`). Their supersedes are the fresh COORD selftest/uitest
jobs of (f) (`R/FINAL_GATE_PLAN_01.md:148-170`). Acking them early would be an
evidence-free ack and is prohibited (`R/CLEAN_01_variant_clean.md:25-29`).

**Re-verify read-only after the 14 acks:**
```
python variant3d\tools\assert_clean.py --json
```
Expected: `history.failures` length **3** (452/453/494), `acknowledged` **36**
(22 historical + 14 new), verdict still DIRTY/exit 1 — this is **expected** until (f).

**Stop/failure:** never ack a `failed` entry to force CLEAN (tickets 296/300 remain
unacked by standing D-13, `R/CLEAN_01_variant_clean.md:287-293`); never use
`--ignore-history` (`V/tools/CLEAN_GATE.md:36-38`); never ack a running/pending job
(`R/CLEAN_01_variant_clean.md:6,24`). If `R/CLEAN_ACK_PLAN_01.md` lands, reconcile its
commands/reasons with this table before continuing (PR-6).

---

### (e) Windowed ladder rows P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1, one at a time

**P0 is already green — do not re-run unless code changed.** Fresh post-final-shader
capture ticket **504** `p0fresh01-capture` `ok`: JSON `PASS 22/22 evaluated, 1 skipped`,
`mean_luma=91.432`, `max_luma=155.163`, `full_width_dark_rows=0`,
`non_black_fraction=1.0`, `SCRIPT ERROR=0`, PNG 10:41:11 UTC > shader edit 09:53:34 UTC
(`R/P0_FRESH_CAPTURE_01.md:51-65,133-187`); second agent confirmed **P0
CONFIRMED_PASS** (`R/RECHECK_P0_FINAL.md:14`). **Conditional re-verify (read-only)**
that no shader/atom changed after the capture:
```
powershell -NoProfile -Command "Get-Item variant3d\shaders\terrain_tileindex.gdshader, variant3d\tests\t_terrain_only.gd | Select-Object FullName,LastWriteTimeUtc"
```
If either mtime is later than **2026-11-25 10:41:11 UTC**, P0 must be re-captured with
the same launch form as `R/P0_FRESH_CAPTURE_01.md:54` before P1. UNVERIFIED: whether
C3's donor dark-row predicate is applicable to P1/C2/C4 water-free frames — if such
a row fails on `full_width_dark_rows`, open a separate evidence-backed ticket; do
not relax it (`R/FINAL_GATE_PLAN_01.md:242-248`; `S/CAPTURE_RECHECK.md:184`).

**One submission at a time.** Submit a row, wait for its result JSON, run the read-only
inspectors and the second-agent re-check, and only then submit the next row
(`S/TEST_MATRIX.md:57-59`; `S/CAPTURE_RECHECK.md:249`). Use unique `qd01-*` ids (never
reuse an id from the churn) and `timeout 300` (runner hard timeout, not a test
threshold; consistent with `R/P0_FRESH_CAPTURE_01.md:54`). All rows are **windowed** —
no `--headless`; PNG path after the second `--`. `<TEMP>` =
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/queue_drain_01`.

| Order | Exact command | Source |
|---|---|---|
| P1 | `python variant3d\tools\godot_runner.py run --id qd01-p1-terrain-trees --timeout 300 -- --path variant3d --script res://tests/t_terrain_trees.gd -- --screenshot <TEMP>\smallmap64_terrain_trees.png --p0-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png` | `R/TEST_P1_report.md:117-121,154-159` (explicit `--p0-png` reuses the *same* final-formula baseline, avoiding a stale/different P0) |
| P2 | `python variant3d\tools\godot_runner.py run --id qd01-p2-terrain-shore --timeout 300 -- --path variant3d --script res://tests/t_terrain_shore.gd -- --screenshot <TEMP>\smallmap64_terrain_shore.png --png-t1 <TEMP>\smallmap64_terrain_shore_t1.png` | `R/TEST_P2_report.md:107-110` (`--png`/`--png-t1` documented overrides); motion frames per `S/CAPTURE_RECHECK.md:52,141` |
| P3 | `python variant3d\tools\godot_runner.py run --id qd01-p3-terrain-mines --timeout 300 -- --path variant3d --script res://tests/t_terrain_mines.gd -- --png <TEMP>\smallmap64_terrain_mines.png` | `V/tests/t_terrain_mines.gd:374-376`; `R/TEST_P3_report.md:115-127` (no false green from headless skip rows) |
| C1 | `python variant3d\tools\godot_runner.py run --id qd01-c1-trees-shore --timeout 300 -- --path variant3d --script res://tests/t_combo_trees_shore.gd -- --screenshot <TEMP>\smallmap64_combo_trees_shore.png` | `R/TEST_C1_report.md:230-233` |
| C2 | `python variant3d\tools\godot_runner.py run --id qd01-c2-trees-mines --timeout 300 -- --path variant3d --script res://tests/t_combo_trees_mines.gd -- --screenshot <TEMP>\smallmap64_combo_trees_mines.png` | `R/TEST_C2_report.md:261-267` |
| C3 | `python variant3d\tools\godot_runner.py run --id qd01-c3-shore-mines --timeout 300 -- --path variant3d --script res://tests/t_combo_shore_mines.gd -- --screenshot <TEMP>\smallmap64_combo_shore_mines.png` | `V/tests/t_combo_shore_mines.gd:499-501,764`; `R/TEST_C3_report.md:183-185` |
| C4 | `python variant3d\tools\godot_runner.py run --id qd01-c4-all --timeout 300 -- --path variant3d --script res://tests/t_combo_all.gd -- --png <TEMP>\smallmap64_combo_all.png --frames 10` | `R/TEST_C4_report.md:41,51-52,92-100`; `V/tests/t_combo_all.gd:538-550` |
| S1 | `python variant3d\tools\godot_runner.py run --id qd01-s1-select-rect --timeout 300 -- --path variant3d --script res://tests/t_select_rect.gd -- --config C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json --screenshot <TEMP>\qd01_s1_smallmap64.png` | proven **windowed** form `R/FINAL_GATE_PLAN_01.md:131-134` / `S1_INPUT_FIX.md:146-151`, job 414; `V/tests/t_select_rect.gd:277-280` |

**Conflict recorded (observed, derived):** `R/TEST_S1_report.md:163-167` proposes a
`--headless` S1 launch. That contradicts `S/TEST_MATRIX.md:62-64` (headless =
`SKIP_CAPTURE`, not PASS) and the proven windowed job 414. **Use the windowed form
above.** The atom itself rejects headless as a fake PASS (`R/RECHECK_S1.md:85`;
`V/tests/t_select_rect.gd:272-276`).

**After every row (read-only, before the next submission):**
```
python variant3d\tools\smallmap_capture.py stats "<TEMP>\smallmap64_<row>.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000NNN_qd01-<row>\stderr.txt
```
Expected: PNG exists, 1280×720, non-blank, `non_black_fraction > 0.9`;
`script_error_lines: 0` (`S/CAPTURE_RECHECK.md:56-83`; `R/FINAL_GATE_PLAN_01.md:138-146`);
runner result `status: ok`, `exit: 0`; atom JSON in `V/tests/results/<atom>.json`
`passed: true` / `verdict: PASS` with no `SKIP_CAPTURE` / `HEADLESS_STRUCTURAL_ONLY`
(`R/FINAL_CHECKLIST.md:239-246`). A **second agent** then writes
`R/RECHECK_<ROW>.md` with the four artifacts, both command outputs verbatim, the
PASS/FAIL/N/A checklist, separate atom-JSON and image verdicts, and `PORT APPROX`
(`S/CAPTURE_RECHECK.md:246-250`). **COORD advances only after that file lands.**
For S1 specifically: accept JSON/stdout-only evidence per the protocol's S1 exception
(`R/RECHECK_S1.md:142-145,167`), but record the visual verdict **UNVERIFIED (no PNG)**
and note the shared-JSON provenance question (`R/RECHECK_S1.md:156-177`) — a fresh
S1-exclusive run is a COORD decision, not an automatic rerun.

**Stop/failure:** stop at the first failing row; record the exact assertion; attribute
to the owning file per `S/CAPTURE_RECHECK.md:254-266`; do not submit the next row and
do not rerun without an actual fix (`R/FINAL_GATE_PLAN_01.md:182-188`). A `SCRIPT ERROR`
is judged before any visual verdict (`R/TEST_RUN_02_ladder_log.md:163`). If a row
produces the banner-only + empty-stderr signature of `R/GATE_FAIL_01.md:42-45`, classify
it as harness race, **not** a test failure, and stop.

---

### (f) FINAL: selftest → uitest → post-gate acks → `assert_clean.py --json`

Only after every ladder row is green and its `RECHECK_<ROW>.md` has landed
(`R/FINAL_GATE_PLAN_01.md:148-158`; `S/TEST_MATRIX.md:27,65-66`). FINAL is COORD-only
and last (`R/FINAL_CHECKLIST.md:54`). Note: `--headless` **is** correct for the two
gate jobs; it is forbidden only for ladder capture rows.

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id qd01-final-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id qd01-final-uitest --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
```
Expected: both result JSONs `status: ok`, `exit: 0`; stdout END ok; `V/selftest.json`
`"passed": true` **29/29** (`R/FINAL_GATE_PLAN_01.md:162-164`; `S/TEST_MATRIX.md:27`);
`V/uitest.json` `"passed": true` **17/17** (`R/FINAL_GATE_PLAN_01.md:165`); both file
mtimes advance past their run windows (`R/GATE_FAIL_01.md:137`). Per-job 29/29 from
old tickets 312/337 is **not** sufficient (`R/FINAL_GATE_PLAN_01.md:76,226`;
`R/FINAL_CHECKLIST.md:158-166`).

**Then close the three deferred acks using the fresh jobs' ticket numbers** (substitute
`<ST>` = selftest ticket, `<UT>` = uitest ticket from the two command outputs):
```
python variant3d\tools\godot_runner.py ack 452 --reason "superseded by fresh COORD uitest ticket <UT> qd01-final-uitest, 17/17 PASS, exit 0 (FINAL_GATE_PLAN_01.md:165; QA_CLEAN_02.md:194)"
python variant3d\tools\godot_runner.py ack 453 --reason "superseded by fresh COORD selftest ticket <ST> qd01-final-selftest, 29/29 PASS, exit 0 (FINAL_GATE_PLAN_01.md:162-164; QA_CLEAN_02.md:195)"
python variant3d\tools\godot_runner.py ack 494 --reason "timed-out job superseded by fresh COORD uitest ticket <UT> qd01-final-uitest, 17/17 PASS, exit 0 (Q/results/00000494.json:1-20; FINAL_GATE_PLAN_01.md:165)"
```
Expected: three `ticket N acknowledged: ...` lines, exit 0.

**Finally the clean assertion (read-only):**
```
python variant3d\tools\assert_clean.py --json
```
Expected: `{"clean": true, "verdict": "CLEAN", "reasons": []}`, exit **0**;
`processes.count: 0`; `lock.state: "free"`; `history.failures: []`,
`history.acknowledged: 25` (22 historical + 14 from (d) + 3 here, derived),
`history.total` = 497 + 2 gate jobs. Exit codes: 0 CLEAN / 1 DIRTY / 2 bad invocation
(`V/tools/assert_clean.py:18,262-288`; `V/tools/CLEAN_GATE.md:40-46`). Then re-run
`status` once more: `pending = 0`, lock free (`R/FINAL_GATE_PLAN_01.md:170`).

**Stop/failure:** a `DIRTY` result while any job is active is expected and must not be
signed (`R/FINAL_GATE_PLAN_01.md:166-169`; `V/tools/CLEAN_GATE.md:99-103`). If the two
gate jobs show the 75-byte banner / empty-stderr / no-report-write signature, treat as
harness race (`R/GATE_FAIL_01.md:36-45,110,139`) and stop — do not call it a test
failure and do not rerun. New skips/timeouts appearing during the window → abort,
return to (b), re-drain, and re-verify supersedes before acking.

---

### (g) 2D gates — already green; re-verify only if changed

`R/QA_2D_GATES_01.md:24-28` records **CONFIRMED_GREEN** on fresh 2D jobs: selftest
29/29 (job 1348), uitest 17/17 (job 1349), clean gate `CLEAN`/exit 0, `pending = 0`.
`R/FINAL_CHECKLIST.md:353-359` marks the current-tree status UNVERIFIED only because
it was not re-run there. Re-check read-only:
```
git status --short -- app
```
Expected: **no output** → `app/**` untouched → carry the CONFIRMED_GREEN verdict
forward (`S/TEST_MATRIX.md:66`; `R/FINAL_GATE_PLAN_01.md:78,171,229`;
`R/FINAL_CHECKLIST.md:349-352`). If `app/**` changed, re-run the 2D gates sequentially
using `app\tools\godot_runner.py` and `app\tools\assert_clean.py` (the 2D pattern is an
acceptance template only: `R/FINAL_GATE_PLAN_01.md:175-178`) — never with the variant
runner, never overwriting `V/selftest.json` / `V/uitest.json`.

---

### (h) Sign-off conditions (all required, none optional)

COORD may sign the **one** final whole-system gate only when every item below holds:

1. Ladder P0 → P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1 green in that order; each row
   windowed with `SCRIPT ERROR == 0` and a landed second-agent
   `R/RECHECK_<ROW>.md` (`S/TEST_MATRIX.md:57-59,75`;
   `R/FINAL_CHECKLIST.md:387-395`).
2. Fresh integrated selftest **29/29 / passed:true** and uitest **17/17 / passed:true**
   from (f), with advancing report mtimes (`R/FINAL_GATE_PLAN_01.md:162-165`;
   `R/GATE_FAIL_01.md:137`).
3. `assert_clean.py --json` → **CLEAN / exit 0** on the **variant** spool: 0 Godot
   processes, free lock, no unacked `timed-out`/`error`/`skipped`
   (`R/FINAL_GATE_PLAN_01.md:85,166-169`; `V/tools/assert_clean.py:33-42,166-188`).
4. `godot_runner.py status` → `pending = 0`, bounded max wait, no held lock
   (`R/FINAL_GATE_PLAN_01.md:84,170`; `V/tools/CLEAN_GATE.md:100-103`).
5. No in-flight builder may touch a file under test; freeze from (a) still in force
   (`R/FINAL_GATE_PLAN_01.md:62,94-96`; `R/FINAL_CHECKLIST.md:89-97,214-217`).
6. 2D `app/**` gates still green and untouched (step (g);
   `S/TEST_MATRIX.md:66`; `R/FINAL_CHECKLIST.md:347-369`).
7. No test weakened, no `expected_pre_fix_failure` marker cleared, no rerun of a
   failing row (`S/TEST_MATRIX.md:60-68`; `R/FINAL_GATE_PLAN_01.md:180-201`).
8. Runner-patch state recorded (applied + `AST_OK`, or explicitly "not applied"),
   and all 17 ack reasons recorded with their supersede ticket numbers
   (`R/CLEAN_01_variant_clean.md:19-29`; §(c)/(d)/(f) of this plan).

**Explicit caveats that survive sign-off (UNVERIFIED):**
- **Donor GPU A/B / visual parity** — no matched donor frame exists; every finding is
  `PORT APPROX — internal consistency only` (`S/TEST_MATRIX.md:32-34,73-74`;
  `S/CAPTURE_RECHECK.md:10,35,237`; `R/FINAL_GATE_PLAN_01.md:208-214`;
  `R/FINAL_CHECKLIST.md:324-329`).
- **Owner visual review** — not signed; a green gate does not constitute it
  (`R/FINAL_CHECKLIST.md:319-323`; `S/CAPTURE_RECHECK.md:34`).
- **S1 visual raster** — no PNG; JSON/stdout-only evidence, visual verdict UNVERIFIED
  (`R/RECHECK_S1.md:142-145,167`).
- The final gate is a truthful **system** gate, **not** a donor-parity certificate
  (`R/FINAL_GATE_PLAN_01.md:172-173`).

---

## 3. Failure / stop policy (applies to every step)

1. **Stop at the first failing row or red signal.** Record the exact assertion and
   route it to the owning file/ticket; do not submit the next row
   (`S/TEST_MATRIX.md:60-61`; `R/FINAL_GATE_PLAN_01.md:182-185`;
   `S/CAPTURE_RECHECK.md:256-266`).
2. **No rerun hoping for green.** A rerun is allowed only after the owning builder
   lands an actual fix and COORD re-opens the row
   (`R/FINAL_GATE_PLAN_01.md:186-188`; `S/TEST_RUN_02_ladder_log.md:249`).
3. **No weakening.** No threshold lowered, no assertion/marker deleted; an
   inapplicable predicate gets a separate evidence-backed ticket with an equally
   strict replacement and the old value recorded (`S/TEST_MATRIX.md:67-68`;
   `R/FINAL_GATE_PLAN_01.md:189-198`).
4. **No fake PASS from headless.** Headless yields `SKIP_CAPTURE`/`passed=false`;
   `SCRIPT ERROR == 0` is mandatory (`S/TEST_MATRIX.md:62-64`;
   `R/FINAL_GATE_PLAN_01.md:199-201`).
5. **Signal classification.** Banner-only stdout (~75 B), empty stderr, no report
   write ⇒ harness race (`R/GATE_FAIL_01.md:31-45,110,116-129`). Explicit
   `SCRIPT ERROR: Parse Error` ⇒ test-file owner (`R/GATE_FAIL_01.md:112-114`).
   `skipped (serving=N)` ⇒ queue overtaking, not a test failure
   (`V/tools/godot_runner.py:316-317`; `R/GATE_FAIL_01.md:47-60`).
6. **Mutation guardrails.** No `reset --yes`, `doctor`, `unwedge` or `cancel` during
   the gate window without an explicit COORD/owner decision: each can advance serving
   or kill Godot children and mimic the original race
   (`V/tools/godot_runner.py:275-302,464-535`; `R/GATE_FAIL_01.md:100,141`).
   No `--ignore-history` on `assert_clean.py` (`V/tools/CLEAN_GATE.md:36-38`).
7. **Moving target.** Every snapshot is point-in-time; if the counter advances, a new
   skip appears, or a PID reappears, abort the window, return to (b) and re-derive the
   ack table (`R/QA_CLEAN_02.md:128-141,254-255`; `R/FINAL_GATE_PLAN_01.md:10`).

---

## 4. Open questions

1. **CLEAN_ACK_PLAN_01.md (UNVERIFIED — not landed).** Does it prescribe different
   reasons or a different ticket set than §(d)? Reconcile before acking (PR-6).
2. **RUNNER_FIX_01.md (UNVERIFIED — not landed).** Is a patch approved, and does it
   cover all three items in §(c)? Exact original killer (cross-reap vs another agent's
   `doctor`/`unwedge` vs stale-lock release) is still unresolved
   (`R/GATE_FAIL_01.md:129,145-147`).
3. **Ack evidence for 452/453/494 (derived dependency).** This plan uses the fresh
   (f) gate jobs as their supersedes; COORD may instead require a separate, older
   verified PASS. No such PASS exists in `Q/results/` for tickets ≥ 440 at this read
   (§0.2, observed).
4. **Row count after the fresh poll (observed/derived).** 17 unacked entries, not the
   16 of `R/QA_CLEAN_02.md`; ticket 494 `timed-out` is new. New skips during the gate
   window would change the table again.
5. **P0 recapture necessity (UNVERIFIED).** Depends on shader/atom mtimes vs
   10:41:11 UTC at gate time; check with the read-only command in §(e).
6. **S1 visual evidence (UNVERIFIED).** Whether to accept JSON/stdout-only, or add a
   capture ticket for the marquee/aura and an owner visual review
   (`R/RECHECK_S1.md:175-177`).
7. **Water-free dark-row applicability (inferred).** P1/C2/C4 hard-assert
   `full_width_dark_rows == 0`; P0's record-only instrument applies to P0 alone
   (`R/FINAL_GATE_PLAN_01.md:242-248`).
8. **Donor A/B and owner visual review (UNVERIFIED).** No donor GPU frame; no owner
   sign-off; a green gate does not convert either to PASS
   (`R/FINAL_CHECKLIST.md:317-345`).
9. **2D current-tree status (UNVERIFIED).** Carried from `R/QA_2D_GATES_01.md:24-28`
   only if `git status --short -- app` stays empty (step (g)).
10. **Concurrent churn (observed).** Modified/untracked files exist in the working tree
    at this read; the freeze in (a) is what makes the gate window meaningful.

---

## 5. Summary

- The queue is **quieter than at `R/QA_CLEAN_02.md`**: fresh read-only poll gives
  `pending = 0`, `godot.lock = free`, **0** Godot processes — but `assert_clean.py`
  remains **DIRTY / exit 1** with **17** unacked failure-status entries: the 16 skips
  of tickets 448–473 plus the new ticket 494 `timed-out` (`Q/results/00000494.json:1-20`).
  `failed` entries (153) are D-13-excluded and are not blockers.
- Exact COORD-only order: **(a)** freeze submissions and edits → **(b)** re-poll the
  three quiet signals → **(c)** apply the approved runner patch and re-poll, else stay
  strictly serialized → **(d)** ack the **14** skips with verified `ok` supersedes,
  defer 452/453/494 → **(e)** run P1→P2→P3→C1→C2→C3→C4→S1 windowed, one unique-id job
  at a time, each with `stats`/`scan-stderr` and a landed second-agent
  `RECHECK_<ROW>.md` → **(f)** fresh headless selftest 29/29 then uitest 17/17, ack the
  three deferred entries using those jobs, then `assert_clean.py --json` CLEAN/exit 0 →
  **(g)** carry 2D CONFIRMED_GREEN if `app/**` unchanged → **(h)** sign off only when
  every condition in §2(h) holds.
- The one deliberate intra-sequence dependency: 452/453/494 cannot be acked credibly
  until (f) produces fresh green gate jobs, so their acks sit between uitest and the
  final `assert_clean.py --json` (§0.2, §(d), §(f)).
- Failure policy: stop at the first red signal, attribute by owning file, never rerun
  or weaken, and classify 75-byte banner + empty stderr as a harness race rather than
  a test failure (`R/GATE_FAIL_01.md`).
- **UNVERIFIED throughout:** donor GPU A/B / visual parity, owner visual review, S1
  raster, and the two not-landed plans (CLEAN_ACK / RUNNER_FIX). This is a plan only:
  no runner-state mutation, no job submission, no code/queue/git edit was performed by
  this worker; the only file written is this report.

---

*End of QUEUE-DRAIN-01. Plan only — every command above is an instruction for COORD, not an action taken by this worker.*
