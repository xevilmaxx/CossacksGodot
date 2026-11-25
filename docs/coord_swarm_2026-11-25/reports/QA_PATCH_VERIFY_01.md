---
id: QA-PATCH-VERIFY-01
title: "QA-PATCH-VERIFY-01 — verify applied runner patch matches approved diff and changed nothing else"
date: 2026-11-25
owner: QA-PATCH-VERIFY-01 read-only verification subagent
status: complete
scope: "Read-only verification. No code edits, no runner-state mutation, no run/cancel/reset/unwedge/ack/doctor command issued. All validation artifacts were written outside the repo under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ and removed afterwards."
target_file: variant3d/tools/godot_runner.py
sources:
  - docs/coord_swarm_2026-11-25/reports/RUNNER_FIX_01.md (approved diff, §3 lines 130-306)
  - variant3d/tools/godot_runner.py (current, 656 lines, CRLF)
  - inbox/backup/godot_runner.py.bak-RUNNERFIX01 (pre-patch backup, 608 lines, LF)
verdict: APPLIED_AS_APPROVED
labels: observed | derived | inferred | UNVERIFIED
mutation_performed: false
files_written:
  - docs/coord_swarm_2026-11-25/reports/QA_PATCH_VERIFY_01.md
---

# QA-PATCH-VERIFY-01 — applied-patch fidelity verification

## 0. Mandate and mutation statement

**No mutation was performed in the repo.** No code was edited; no runner command that
mutates state was issued; no job was submitted, cancelled, reset, unwedged, acknowledged
or doctored. The only repo file written is this report. All comparison scripts, the
extracted patch and the temp mirror were created under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` and deleted at the end. The one
repo command executed was the explicitly sanctioned read-only `godot_runner.py status`.

Claim labels used below: **[observed]** directly read/measured; **[derived]** computed
from observed data; **[inferred]** reasoned conclusion; **[UNVERIFIED]** not tested in
this scope.

---

## 1. Sources

| Source | Role | Observed facts |
|---|---|---|
| `docs/coord_swarm_2026-11-25/reports/RUNNER_FIX_01.md` | approved diff (§3, fenced ```diff block) | 7 hunks; index line `index 69d599ff..9730aa49 100644` |
| `inbox/backup/godot_runner.py.bak-RUNNERFIX01` | pre-patch image | 608 lines, all LF, 0 CRLF; `git hash-object` = `69d599ff85d9856eb777dc1e3c20b077f8687a5e` |
| `variant3d/tools/godot_runner.py` | applied image | 656 lines, all CRLF, 0 bare LF; `git hash-object` = `9730aa49237be737ff4f8f9c2c0e798627f201b6` |

[observed] The backup's blob hash begins `69d599ff` and the current file's begins
`9730aa49` — exactly the two abbreviations in the approved diff's index line. Git blob
IDs are content-addressed, so **[derived]** the backup is the exact pre-image and the
current file is the exact post-image that the approved diff was written against.

---

## 2. Diff comparison (hunk-for-hunk)

### 2.1 Method

[observed] Two independent comparisons were run, both read-only:

1. `git diff --no-index -- inbox/backup/godot_runner.py.bak-RUNNERFIX01 variant3d/tools/godot_runner.py`
   (console output decoded explicitly as UTF-8 — Windows locale decoding initially
   mangled an em-dash in a context line, a display artifact only).
2. In-memory extraction of the report's fenced diff block, then a line-by-line comparison
   of hunk headers and change bodies against (1), ignoring only `diff --git`, `index`,
   `---` and `+++` header lines.

### 2.2 Result

| Check | Result | Label |
|---|---|---|
| Approved diff body lines vs actual `git diff --no-index` body lines | 171 vs 171, **identical** | [observed] |
| Hunk header sequence | 7 vs 7, **identical** (listed below) | [observed] |
| `index` line | `69d599ff..9730aa49 100644` in both | [observed] |
| Extra hunks not in the approved diff | **none** | [derived] |
| Approved hunks missing from the applied file | **none** | [derived] |
| Approved diff re-applied to a byte-copy of the backup, then compared to live current | **identical content** after LF normalization (25,353 bytes each) | [derived] |

Approved hunk headers (observed, identical in both sources):

```
@@ -142,21 +142,30 @@ def load_job(ticket: int) -> dict | None:
@@ -167,6 +176,15 @@ def godot_lock_age() -> float:
@@ -240,9 +258,10 @@ def godot_pids() -> set[int]:
@@ -320,13 +339,13 @@ def wait_for_turn(ticket: int, max_wait: float) -> None:
@@ -334,12 +353,28 @@ def wait_for_turn(ticket: int, max_wait: float) -> None:
@@ -394,13 +429,25 @@ def cmd_run(ns: argparse.Namespace) -> int:
@@ -414,14 +461,15 @@ def cmd_run(ns: argparse.Namespace) -> int:
```

[derived] Line-count delta check: hunk deltas are +9, +9, +1, 0, +16, +12, +1 = **+48**;
608 + 48 = 656, matching the observed current line count exactly. No unexplained
additions or deletions.

### 2.3 Required mechanisms — each confirmed present in the applied file

| Requirement | Applied code (observed in current file) | Line(s) |
|---|---|---|
| Owner-gated claim | `claim_godot_lock` takes `spinner_lock()`, requires `read_int(SERVING) == ticket`, then `O_EXCL`; writes `ticket timestamp os.getpid()` | 144-156 |
| Owner-gated release | `release_godot_lock(ticket)` re-reads owner under `spinner_lock()` and unlinks only if `owner[0] == ticket` | 159-168 |
| Lock owner PID | Third lock field `os.getpid()`; `godot_lock_owner()` returns `(owner ticket, timestamp)`; `owner_pid` read from `load_job(lock_owner[0])` | 152, 179-185, 358-365 |
| Per-job spawned-PID reap | `spawned_pids = {proc.pid} ∪ (godot_pids() - pids_before)` in a bounded 2 s launch window; `reap_spawned_godot(spawned)` kills `spawned & live` only | 432-448, 261-272, 472 |
| Dead-holder-only SERVING advance | `advance_serving(serving)` appears only inside `if dead_holder:`; `if lock_stale:` only calls `release_godot_lock()` | 367-377 |
| Stale = age AND dead owner | `lock_stale = lock_present and lock_age > STALE_SEC and owner_dead` | 366 |

[derived] All five approved change areas are present; no sixth change area was found.

### 2.4 Byte-level caveat (not drift)

[observed] The backup is 100% LF; the current file is 100% CRLF (656 CRLF, 0 bare LF).
Re-applying the approved diff to a byte-copy of the backup required
`git apply --ignore-whitespace` because the report is a CRLF `.md` file and the extracted
patch inherited CRLF line endings on Windows. After normalizing both to LF, the applied
result and the live file are byte-for-byte identical. **[inferred]** The line-ending
conversion is a checkout/editor artifact, not a content change; it alters no token,
identifier or behaviour. It is the only byte-level difference between the canonical
post-image and the live file.

---

## 3. `py_compile` confirmation

[observed] Because a pre-existing `variant3d/tools/__pycache__/godot_runner.cpython-314.pyc`
was present, compiling the live file in place would have overwritten it. To preserve the
read-only mandate, compilation was run on a byte-identical temp copy outside the repo:

```
temp copy byte-identical to live: True
python -m py_compile exit code: 0
stdout: (empty)
stderr: (empty)
repo pre-existing .pyc untouched: True | sha256: 51811008e601aa3bf3e78ddc164426448e460d9ee4f4ae73350549befe5b645a
temp __pycache__ created: ['godot_runner.cpython-314.pyc']
temp __pycache__ removed: True
```

[derived] The live file's exact bytes compile cleanly under Python 3.14 (`python`, not
`python3`). No `__pycache__` was created or left in the repo by this verification.

---

## 4. Status output (verbatim, read-only)

Command: `python variant3d/tools/godot_runner.py status`

```
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 521
next_ticket = 525
pending      = 4 [521, 522, 523, 524]
godot.lock   = HELD (age 150.9s)
completed    = 500
max wait     = 1825.52s   mean wait = 110.31s
max run      = 605.56s
statuses     = {'failed': 154, 'ok': 306, 'skipped': 16, 'timed-out': 24}
```

[observed] The runner still reports the **variant spool** (`variant3d/.godot_queue`) and a
coherent counter/serving state. Nothing was cancelled or acknowledged; the pending list
and history counters above are as found. `cmd_status` is the sanctioned read-only command
(it only calls `ensure_spool()`, which is idempotent `mkdir(exist_ok=True)`).

[observed] Post-verification `git status --short` for the relevant paths shows only:

```
 M variant3d/tools/godot_runner.py
?? docs/coord_swarm_2026-11-25/reports/RUNNER_FIX_01.md
?? inbox/backup/godot_runner.py.bak-RUNNERFIX01
```

No stray `.diff` / `.patch` / mirror artifacts were left in the repo.

---

## 5. Verdict

> ## APPLIED_AS_APPROVED

**Evidence chain:** [observed] the applied `git diff --no-index` is body-for-body and
hunk-for-hunk identical to the approved diff in `RUNNER_FIX_01.md` §3, with the same index
line; [derived] the backup and current blob hashes are exactly the approved diff's
pre-/post-image hashes; [derived] re-applying the approved diff to the backup reproduces
the live file's content byte-for-byte after LF normalization; [observed] all five required
mechanisms are present and no extra hunk exists; [observed] `py_compile` exits 0;
[observed] status still reports the variant spool. Therefore **[inferred]** the applied
runner patch matches the approved diff and changed nothing else.

No DRIFT condition was found: no missing hunk, no extra hunk, no altered line within a
hunk. UNVERIFIED items below concern runtime behaviour and external validation, not
patch fidelity.

---

## 6. Open questions

1. **[UNVERIFIED] Runtime correctness.** No `run` submission, cancel, reset, unwedge, ack
   or doctor was issued (mandate). Mutual exclusion under live concurrency was not
   exercised; behavioural proof remains with COORD's §5 validation plan in
   `RUNNER_FIX_01.md`.
2. **[observed] Queue not drained at verification time.** Status shows `pending = 4` and
   `godot.lock HELD (age 150.9s)`, whereas `RUNNER_FIX_01.md` §5 sets "pending = 0, lock
   free" as the precondition for validation. The patch was applied before that
   precondition was met; this is a procedural concern, not a diff-fidelity drift.
3. **[observed / inferred] Byte-count discrepancy in source report.** `RUNNER_FIX_01.md`
   §4 states the validated patched copy was "25,247 bytes, LF-normalized"; the
   LF-normalized applied file measured here is 25,353 bytes. **[inferred]** this is a
   stale or erroneous figure in the source report; it does not affect the equivalence
   proof, which uses the diff body and content-addressed blob hashes rather than that
   figure.
4. **[UNVERIFIED] Third-field lock consumers.** As noted in `RUNNER_FIX_01.md` OQ 5, a
   repo-wide search for readers of `godot.lock` beyond `godot_runner.py` and
   `assert_clean.py` was not re-performed here.
5. **[inferred] Exact historical killer** (cross-reap vs `doctor`/`unwedge` vs old
   age-only release) remains unresolved, per `RUNNER_FIX_01.md` OQ 1-2; the patch removes
   the unsafe paths but cannot reconstruct the 11:21 event.
6. **[UNVERIFIED] Whether COORD already ran the four §5 validation commands.** Out of
   scope for this read-only verification; the live spool state suggests they had not all
   completed at the time of this check.

---

## 7. Summary

[observed] The approved diff in `RUNNER_FIX_01.md` (7 hunks, index `69d599ff..9730aa49`)
was applied to `variant3d/tools/godot_runner.py`. Verification by `git diff --no-index`,
hunk-body comparison, content-addressed blob hashes, and re-application of the approved
diff to a temp backup copy all agree: **the applied file is the approved post-image, with
no extra or missing changes**. [observed] `python -m py_compile` passes (exit 0) and
`godot_runner.py status` still reports the `variant3d/.godot_queue` spool with coherent
state. [derived] The only byte-level difference from the canonical LF post-image is a
whole-file CRLF line-ending conversion, which does not change content.

**VERDICT: APPLIED_AS_APPROVED. No mutation was performed.**
