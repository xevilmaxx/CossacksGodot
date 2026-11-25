---
id: RUNNER-FIX-01
title: "RUNNER-FIX-01 — prepared (NOT applied) minimal mutual-exclusion fix for variant3d godot_runner.py"
date: 2026-11-25
owner: RUNNER-FIX-01 tooling-engineering subagent
status: prepared-not-applied
scope: "Read-only inspection of runner + reports; static construction and validation of a unified diff in a temp directory OUTSIDE the repo. No runner file edited, no runner command that mutates state issued."
patch_applied: false
runner_state_touched: false
files_written:
  - docs/coord_swarm_2026-11-25/reports/RUNNER_FIX_01.md
target_file: variant3d/tools/godot_runner.py
sources:
  - variant3d/tools/godot_runner.py (read in full, 608 lines)
  - docs/coord_swarm_2026-11-25/reports/GATE_FAIL_01.md
  - docs/coord_swarm_2026-11-25/reports/QA_RUNNER_ARTIFACTS_01.md
  - variant3d/tools/assert_clean.py:118-143, variant3d/tools/CLEAN_GATE.md:90-117, docs/DECISION_LOG.md:49 (D-13)
verdict: "One minimal diff prepared: authoritative owner-gated mutex, per-job spawned-PID kill set, no advance past a live pending ticket, stale = age AND dead owner. Static checks green. Awaiting COORD application after queue drain."
---

# RUNNER-FIX-01 — prepared fix for the variant runner's broken mutual exclusion

**The patch below was NOT applied.** `variant3d/tools/godot_runner.py` was not edited, and
no `run` / `cancel` / `reset` / `unwedge` / `ack` / `doctor` command was issued. The only
file written in the repo is this report. All construction and validation of the diff
happened on a byte-for-byte copy under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\RUNNER_FIX_01\`, outside the repo.

---

## 1. Diagnosis (all line numbers refer to the pre-patch `variant3d/tools/godot_runner.py`)

### (a) How `take_ticket` / `now_serving` can overtake still-pending tickets

`take_ticket` (`:115–129`) allocates a strictly increasing ticket under `spinner_lock()`
and records the submitting process PID (`:126`). Allocation itself is FIFO. The break is
in **who may advance `now_serving`**:

* `wait_for_turn` (`:305–343`) returns only on `serving == ticket` (`:313–315`) and raises
  the fatal `ticket N was skipped (serving=M)` as soon as `serving > ticket` (`:316–317`).
  Once SERVING passes a ticket, that ticket can never run.
* SERVING is written by **three uncoordinated callers**: the finishing job's `finally`
  (`:422`), the waiter reclaim loop (`:340`), and `unwedge` (`:297`).
* The reclaim condition at `:337` is
  `if dead_holder or (lock_stale and not lock_free)`. The second disjunct does **not**
  inspect `dead_holder`, so `advance_serving(serving)` at `:340` can execute while the
  holder's PID is alive — i.e. past a live pending/serving ticket.
* `unwedge` (`:275–302`) loops over every ticket whose job file is missing or whose
  submitter PID is dead (`:286–289`) and advances SERVING once per ticket (`:297`), gated
  only by "no lock and zero Godot processes" (`:277–283`). Repeated dead-holder reclaims
  by many waiters, or one `unwedge`, produce exactly the observed multi-ticket jumps.

Evidence: GATE_FAIL_01.md `:49–60` lists 17 overtake skips clustered at 11:21:16–25 with
serving fronts 461, 465, 475; QA_RUNNER_ARTIFACTS_01.md `:146–171` records deltas up to
+16 (`448 → 464`). Tickets 452/453/457 are in that set — they were never launched, which
is why they have empty result dirs (QA_RUNNER_ARTIFACTS_01.md `:61–66,101–103`).

### (b) How a job can start while another job holds the lock

The runner has **two independent gates**, not one mutex: ticket turn (`:313–315`) and the
lock file (`:387–393`). `wait_for_turn` returns without acquiring anything; the lock is
claimed afterwards. Three defects let a second job through:

1. `lock_stale = godot_lock_age() > STALE_SEC` (`:324`, `STALE_SEC = 300` at `:54`) is
   age-only. The branch at `:337–339` calls `release_godot_lock()` even when
   `dead_holder` is false (holder alive and running). GATE_FAIL_01.md `:80` records a max
   run of **605.56 s** — well past 300 s — so healthy holders are routinely reclaimed.
2. `release_godot_lock()` (`:155–159`) unlinks whatever lock file exists, with **no owner
   check**. `cmd_run finally` calls it unconditionally at `:417`; a job that lost its lock
   to (1) can therefore delete a *different* job's newly acquired lock.
3. `claim_godot_lock` (`:144–152`) is atomic `O_EXCL` but checks nothing except file
   absence — it never verifies that the caller is the current serving ticket.

Result: overlapping run windows (GATE_FAIL_01.md `:64–74`, e.g. 481 & 482 overlap 35.4 s),
contradicting the "exactly one Godot at a time" promise at `:8–16`.

### (c) How cross-kill happens (PID snapshot vs spawned PID)

* At `:397` the job snapshots **all** live Godot PIDs: `pids_before = godot_pids()`
  (`:224–241`).
* At cleanup, `:424` calls `reap_spawned_godot(pids_before)`; that function (`:243–253`)
  kills `godot_pids() - before` with `taskkill /PID <pid> /T /F` (`:248–249`) /
  `os.kill(SIGKILL)` (`:251`).
* The delta is "every Godot spawned since the snapshot **by anyone**", not "the children
  this job spawned". When jobs overlap, the later job's engine PID is absent from the
  earlier job's snapshot, so the earlier job's cleanup kills the later job's engine.
* The WinGet shim exits before its engine child (comment at `:244`), so `kill_tree(proc)`
  at `:407` (tree rooted at `proc.pid`) cannot reach the child; the over-broad snapshot
  delta is the compensation — and the source of the cross-kill.
* Windows presents a tree-killed job as exit 1 with only the already-flushed 75-byte
  engine banner and empty stderr — the exact 455/461/481/482 signature
  (GATE_FAIL_01.md `:36–45,98,123`).

### (d) Stale-lock release while the owner is alive

`godot_lock_age()` (`:162–167`) derives age from the timestamp written at `:148`.
`wait_for_turn` computes `lock_stale` at `:324` **before** any liveness test, and the
comment at `:326–329` claims the PID throttle protects live tickets — but the
`or (lock_stale and not lock_free)` at `:337` bypasses `dead_holder` entirely. Thus an
owner alive for >300 s (see max run 605.56 s, GATE_FAIL_01.md `:80`) has its lock deleted
at `:338–339`, after which another ticket passes `claim_godot_lock` (`:387`) and a second
Godot starts. The same unconditional delete exists in `cmd_doctor` (`:489`) and
`cmd_reset` (`:500`); those are explicit maintenance actions and are deliberately left
unchanged.

---

## 2. What the patch changes (requirement → mechanism)

| Requirement | Mechanism in diff |
|---|---|
| Lock ownership authoritative; no job starts unless acquired atomically | `claim_godot_lock` now takes `spinner_lock`, requires `read_int(SERVING) == ticket`, then `O_EXCL`; lock content becomes `ticket timestamp owner_pid`. `release_godot_lock(ticket)` unlinks only when the recorded owner ticket matches. |
| Track only own spawned PID(s) | `spawned_pids` starts with `proc.pid` and the bounded 2 s launch-window delta over `godot_pids() - pids_before`; `reap_spawned_godot(spawned)` intersects with the live Godot set and kills only those. A later job's PID can never be in an earlier job's set. |
| Never advance SERVING past a pending live ticket | SERVING advances only in the `dead_holder` branch; the former `lock_stale` advance is removed. Stale lock frees the mutex but keeps the live holder's turn. |
| Stale = age AND no live PID | `lock_stale = lock_present and lock_age > STALE_SEC and owner_dead`, where `owner_dead` is derived from the PID of the job recorded in the lock (`owner_pid == 0 or not pid_alive(owner_pid)`). Liveness probing is lazy: only when the holder is dead or the lock is old, preserving the `:330–331` throttle. |

**Preserved unchanged:** CLI subcommands/flags (`main()` `:567–604`), result JSON keys and
values shape (`result` dict `:362–374` and `record()` `:178–188`), exit codes 0/1/2/3/4
(`:382,392,437,495,544`), FIFO ticket order, `advance_serving`'s compare-and-set
(`:170–175`), the `finally` ordering "advance before cleanup" (`:418–422`), `cmd_ack`
(`:538–564`) including `acknowledged` / `ack_reason` / `ack_at`, and D-13 semantics
(`docs/DECISION_LOG.md:49`; `CLEAN_GATE.md:95–98` — `failed` excluded, infra failures ack-ed).
`godot.lock` gains a third whitespace field; both `godot_lock_age()` (`:162–167`) and
`assert_clean.py:132` read `split()[1]`, so old and new formats are both accepted.

---

## 3. Unified diff (complete, applies to the current `variant3d/tools/godot_runner.py`)

```diff
diff --git a/variant3d/tools/godot_runner.py b/variant3d/tools/godot_runner.py
index 69d599ff..9730aa49 100644
--- a/variant3d/tools/godot_runner.py
+++ b/variant3d/tools/godot_runner.py
@@ -142,21 +142,30 @@ def load_job(ticket: int) -> dict | None:
 
 
 def claim_godot_lock(ticket: int) -> bool:
-    """O_EXCL exclusivity, refreshed with the serving ticket's timestamp."""
-    try:
-        fd = os.open(GODOT_LOCK, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
-        os.write(fd, f"{ticket} {time.time():.3f}".encode())
-        os.close(fd)
-        return True
-    except FileExistsError:
-        return False
+    """Atomically claim the mutex; only the serving ticket may hold it."""
+    with spinner_lock():
+        if read_int(SERVING) != ticket or GODOT_LOCK.exists():
+            return False
+        try:
+            fd = os.open(GODOT_LOCK, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
+            # ticket, timestamp, owner pid -> makes stale checks verifiable.
+            os.write(fd, f"{ticket} {time.time():.3f} {os.getpid()}".encode())
+            os.close(fd)
+            return True
+        except FileExistsError:
+            return False
 
 
-def release_godot_lock() -> None:
-    try:
-        GODOT_LOCK.unlink()
-    except OSError:
-        pass
+def release_godot_lock(ticket: int | None = None) -> None:
+    """Unlink godot.lock; with `ticket`, only if that ticket still owns it."""
+    with spinner_lock():
+        owner = godot_lock_owner()
+        if owner is None or (ticket is not None and owner[0] != ticket):
+            return
+        try:
+            GODOT_LOCK.unlink()
+        except OSError:
+            pass
 
 
 def godot_lock_age() -> float:
@@ -167,6 +176,15 @@ def godot_lock_age() -> float:
         return 0.0
 
 
+def godot_lock_owner() -> tuple[int, float] | None:
+    """Parse the lock as (owner ticket, timestamp); None = no valid lock."""
+    try:
+        parts = GODOT_LOCK.read_text(encoding="utf-8").split()
+        return int(parts[0]), float(parts[1])
+    except (OSError, ValueError, IndexError):
+        return None
+
+
 def advance_serving(expected: int) -> bool:
     with spinner_lock():
         if read_int(SERVING) == expected:
@@ -240,9 +258,10 @@ def godot_pids() -> set[int]:
     return {int(x) for x in out.split() if x.strip().isdigit()}
 
 
-def reap_spawned_godot(before: set[int]) -> None:
-    """Kill Godot children left alive after a job (WinGet shim exits first)."""
-    for pid in godot_pids() - before:
+def reap_spawned_godot(spawned: set[int]) -> None:
+    """Kill ONLY Godot PIDs this job spawned; never another job's child."""
+    live = godot_pids()
+    for pid in spawned & live:
         try:
             if sys.platform == "win32":
                 subprocess.run(["taskkill", "/PID", str(pid), "/T", "/F"],
@@ -320,13 +339,13 @@ def wait_for_turn(ticket: int, max_wait: float) -> None:
         # godot_lock_age() is 0.0 and the old check could never reclaim it —
         # serving stayed pinned forever (the 2026-11-21 wedge on ticket 47).
         holder = load_job(serving)
-        lock_free = not GODOT_LOCK.exists()
-        lock_stale = godot_lock_age() > STALE_SEC
+        lock_present = GODOT_LOCK.exists()
+        lock_owner = godot_lock_owner()          # (owner ticket, timestamp) or None
+        lock_age = godot_lock_age() if lock_present else 0.0
         holder_pid = int(holder.get("pid", 0)) if holder else 0
-        # Reclaim ONLY when the holder is genuinely gone (or its lock is
-        # demonstrably stale). Age alone is NOT proof of death: a live waiter
-        # can sit in the FIFO queue longer than STALE_SEC and must not be
-        # skipped (2026-11-21: agentQ's tickets 48/84 were wrongly skipped).
+        # Reclaim ONLY when the holder is genuinely gone. Age alone is NOT
+        # proof of death: a live job may run > STALE_SEC (max run 605 s seen),
+        # and a live waiter may queue longer than STALE_SEC (2026-11-21).
         # T-PERF-TOOL: pid_alive() spawns `tasklist` (~1 s on Windows); with a
         # 0.15 s poll that cost dominates a waiting job. Throttle it to ~2 s.
         now = time.time()
@@ -334,12 +353,28 @@ def wait_for_turn(ticket: int, max_wait: float) -> None:
             last_pid_check = now
             holder_alive = pid_alive(holder_pid) if holder_pid else False
         dead_holder = holder is None or (holder_pid != 0 and not holder_alive)
-        if dead_holder or (lock_stale and not lock_free):
-            if not lock_free:
+        # A stale lock is old AND its recorded owner is gone. Never release a
+        # live owner's lock: that let a second job start (RUNNER-FIX-01).
+        owner_pid = 0
+        if lock_owner is not None:
+            owner_job = load_job(lock_owner[0])
+            owner_pid = int(owner_job.get("pid", 0)) if owner_job else 0
+        owner_dead = False
+        if lock_present and (dead_holder or lock_age > STALE_SEC):
+            owner_dead = (lock_owner is None or owner_pid == 0
+                          or not pid_alive(owner_pid))
+        lock_stale = lock_present and lock_age > STALE_SEC and owner_dead
+        if dead_holder:
+            # Advance past a DEAD holder only; never past a pending live ticket.
+            if lock_present and (lock_owner is None or lock_owner[0] == serving
+                                 or owner_dead):
                 release_godot_lock()
             if advance_serving(serving):
                 job_path(serving).unlink(missing_ok=True)
             continue
+        if lock_stale:
+            # Owner is gone: free the mutex but keep the live holder's turn.
+            release_godot_lock()
         time.sleep(POLL_SEC)
 
 
@@ -394,13 +429,25 @@ def cmd_run(ns: argparse.Namespace) -> int:
 
     started = time.time()
     result["status"] = "running"
-    pids_before = godot_pids()  # T-PERF-TOOL: reap children left by the shim
+    pids_before = godot_pids()      # baseline used ONLY to identify our children
+    spawned_pids: set[int] = set()  # PIDs this job owns and may kill
     print(f"[runner] ticket {ticket} '{ns.id}' START (waited {result['wait']:.2f}s)", flush=True)
     try:
         with open(out_file, "wb") as fo, open(err_file, "wb") as fe:
             proc = subprocess.Popen([GODOT, *argv], stdout=fo, stderr=fe)
+            launched = time.time()
+            # The WinGet shim can exit before the real Godot child appears.
+            # Sample our delta in a short, exclusive launch window so cleanup
+            # never mistakes another job's child for ours.
+            spawned_pids.add(proc.pid)
+            settle_end = launched + 2.0
+            while time.time() < settle_end:
+                spawned_pids |= godot_pids() - pids_before
+                if spawned_pids - {proc.pid}:
+                    break
+                time.sleep(0.1)
             try:
-                code = proc.wait(timeout=ns.timeout)
+                code = proc.wait(timeout=max(0.0, ns.timeout - (time.time() - launched)))
                 result["exit"] = code
                 result["status"] = "ok" if code == 0 else "failed"
             except subprocess.TimeoutExpired:
@@ -414,14 +461,15 @@ def cmd_run(ns: argparse.Namespace) -> int:
         result.update(status="error", error=repr(e), exit=-1)
     finally:
         result["run"] = time.time() - started
-        release_godot_lock()
+        # Only the owning ticket may delete the lock it actually acquired.
+        release_godot_lock(ticket)
         # CRITICAL: advance the serving ticket BEFORE any cleanup that can fail.
         # On Windows an antivirus or another reader can briefly hold the job
         # file open; if unlink() raised here, now_serving would never advance
         # and every later ticket would wait forever (real starvation).
         advance_serving(ticket)
         try:
-            reap_spawned_godot(pids_before)
+            reap_spawned_godot(spawned_pids)
         except Exception:  # noqa: BLE001 - cleanup must never stall the queue
             pass
         for attempt in range(10):
```

Apply from repo root, e.g. `git apply docs/coord_swarm_2026-11-25/reports/RUNNER_FIX_01.md`
will not work directly (the diff is fenced in prose) — extract the fenced block to a
`.diff` file first, then `git apply --check <file>` followed by `git apply <file>`.

---

## 4. Static validation (performed; no patch applied, no runner state touched)

These checks ran against a temp copy under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\RUNNER_FIX_01\`, never against a repo
file:

| Check | Command | Result |
|---|---|---|
| Python syntax (Python 3.14.3) | `python -m py_compile <temp>\godot_runner.py` | exit **0** |
| Diff applicability (dry run) | `git apply --check patch_clean.diff` from repo root | exit **0** |
| Diff fidelity | `git apply` into a fresh temp mirror of the original, then byte-compare with the validated patched copy | **identical** (25,247 bytes, LF-normalized) |

Careful line-by-line argument for the invariants:

1. **Atomic ownership.** `claim_godot_lock` holds `spinner_lock` while it checks
   `SERVING == ticket` and `GODOT_LOCK.exists()` and creates the file with `O_EXCL`. No
   interleaving can let two tickets both succeed. `release_godot_lock(ticket)` re-parses
   the owner under the same `spinner_lock` before unlinking, so a job cannot delete a
   lock it does not own. `spinner_lock` is not re-acquired recursively: `claim` and
   `release` are called from `cmd_run` outside any `spinner_lock`, and `wait_for_turn`
   calls `release` then `advance_serving` sequentially.
2. **Kill set.** `spawned_pids` is initialized before the `try`, so `finally` always has a
   set. It contains `proc.pid` plus only the Godot delta observed in the 2 s window right
   after this job's `Popen`. Because mutex is now authoritative, no other runner job can
   spawn during that window, so a later job's PID cannot enter this set.
   `reap_spawned_godot` intersects with `godot_pids()` once, so a recycled PID that is not
   a Godot process is skipped. `kill_tree(proc)` on timeout still targets only `proc.pid`.
3. **FIFO guard.** The only `advance_serving` calls are `:297` (`unwedge`, gated by a live
   holder check at `:288`), `:370` (the `dead_holder` branch), and `:468` (the owning
   ticket's `finally`). The stale-lock branch now only deletes the lock; it no longer
   advances. Therefore SERVING cannot pass a ticket whose submitter PID is alive.
4. **Stale detection.** `owner_dead` is computed from the PID of the job named in the lock
   file; `lock_stale` additionally requires `lock_age > STALE_SEC` and `lock_present`.
   The old age-only bypass is gone. Owner liveness is probed lazily (holder dead or lock
   old), so the 2 s throttle from `:330–331` is preserved for the common case.
5. **No runtime probe** was executed: a `run` submission would mutate the live queue and
   is outside this subagent's scope. Behavioural proof is left to COORD's validation plan.

---

## 5. Validation plan for COORD (after the queue drains; apply the patch first)

Precondition: `python variant3d/tools/godot_runner.py status` shows `pending = 0`,
`godot.lock = free`, no live Godot process, and all agents have paused submissions and
`variant3d/tests/*.gd` edits (GATE_FAIL_01.md `:134–138`).

Run these four commands, strictly one at a time, using `python` (not `python3`):

1. **Status baseline**
   ```
   python variant3d/tools/godot_runner.py status
   ```
   Expect `pending = 0`, `godot.lock = free`, stable `now_serving` / `next_ticket`.
2. **One solo selftest**
   ```
   python variant3d/tools/godot_runner.py run --id runnerfix01-selftest-verify --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
   ```
   Check the result JSON: `status=ok`, `exit=0`, no overlap with any other job, and
   `variant3d/selftest.json` mtime advanced past the run window. A genuine test-red
   selftest is allowed to exit 1 — but it must have non-empty stderr / report output,
   **not** the 75-byte-banner + 0-byte-stderr cross-kill signature. (RUN_GUIDE.md `:57`
   notes the selftest artifact is currently red at `build`; do not weaken it.)
3. **One solo uitest** (only after step 2's job has fully exited and the lock is free)
   ```
   python variant3d/tools/godot_runner.py run --id runnerfix01-uitest-verify --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
   ```
   Same checks; expect `variant3d/uitest.json` mtime to advance and 17/17 if green.
4. **Clean gate**
   ```
   python variant3d/tools/assert_clean.py --json
   ```
   Expect `VERDICT: CLEAN`, exit 0. Under D-13 (`docs/DECISION_LOG.md:49`,
   `CLEAN_GATE.md:95–98`) `failed` statuses are excluded; resolved `timed-out` /
   `error` / `skipped` entries remain ack-ed by the untouched `ack` command. If DIRTY,
   distinguish a genuine live orphan from historical unacked infra failures before
   signing.

Optional (COORD-only, if a concurrency regression is wanted after the four steps): submit
two short jobs within a second of each other and assert from their result JSONs that their
run windows do not overlap and neither shows the banner-only/empty-stderr signature.

---

## 6. Risk analysis

| Risk | Assessment |
|---|---|
| 2 s launch sampling adds up to 2 s to short jobs | Bounded, runs only in the exclusive launch window; the hard timeout is recomputed from `launched` so total run time stays ≤ `--timeout`. Acceptable versus a cross-killed gate. |
| Engine child appears after the 2 s window and leaks | Fails safe: it is *not* killed by another job (the original failure mode). `doctor` remains the explicit orphan remediation. Mitigation: extend the window if slow-shim leaks are observed. |
| `godot.lock` third field | Backward compatible with `godot_runner.py:162–167` and `assert_clean.py:132` (both use `split()[1]`). Historical two-field locks still parse with owner PID 0, i.e. reclaimable once old. |
| `spinner_lock` contention | `claim`/`release` now serialize with counter/serving writes; each critical section is a few filesystem ops. A stale `spool.lock` from a crash still blocks after 10 s — pre-existing behaviour, unchanged. |
| Malformed lock file | `godot_lock_owner()` returns `None`; with `lock_present=True` the owner is treated as dead and an old lock is reclaimable. No `TypeError` (guarded by `lock_owner is not None`). `claim_godot_lock` still refuses while the file exists. |
| PID reuse for a killed process | Narrowed from "every new Godot PID" to "our own sampled PIDs ∩ live Godot set"; materially lower than before. Not eliminable without a process-handle API. |
| Other agents invoking `doctor` / `unwedge` / `reset` | Those paths are intentionally left as explicit maintenance tools and can still break mutual exclusion if used mid-run. The patch cannot protect against a human issuing them; COORD must protect the gate window procedurally. |
| `assert_clean` D-13 / ack semantics | Untouched: no change to `record()`, `cmd_ack()`, or `assert_clean.py`; result JSON keeps all existing keys. |

---

## 7. Open questions

1. **Exact historical killer remains unproven.** GATE_FAIL_01.md `:129,145` could not
   distinguish cross-reap from a contemporaneous `doctor`/`unwedge` or the old
   `lock_stale` release, because no lock-owner/reap-target log existed. The lock now
   records the owner PID, but no diagnostic logging is added in this minimal patch.
2. **Who advanced SERVING past 452/453/457** is still unresolved (no `unwedge`
   invocation log); the patch removes the unsafe advance paths but cannot reconstruct
   the 11:21 event.
3. **Submitter PID as identity.** A `run` process whose shell is killed while its Godot
   child lives is still treated as a dead holder (`pid_alive` on the submitter PID). With
   serialized launches and per-job PID ownership this is much less harmful, but a true
   "child outlives submitter" case would need a lock owner PID of the engine, not the
   submitter.
4. **Current gate truth.** RUN_GUIDE.md `:57` says `selftest.json` is genuinely red at
   `build`; the validation plan therefore judges the harness by the *signature* of the
   result (stderr/report present, no overlap), not solely by exit 0.
5. **Third-field lock and other consumers.** Only `godot_runner.py` and
   `assert_clean.py` were inspected for lock parsing; a repo-wide search for other
   readers was not part of this scope.

---

## 8. Summary

The runner's FIFO was correct at ticket allocation but not at dispatch: SERVING could be
advanced by a stale-lock condition that ignored holder liveness (`:324,337–340`) and by
`unwedge` (`:297`), while `wait_for_turn` permanently skips any ticket already passed
(`:316–317`) — that produced the 452/453/457 skips. Mutual exclusion was only a
two-gate convention: turn equality returned without a lock (`:313–315`), `claim` checked
nothing but file absence (`:144–152`), `release` deleted any lock unconditionally
(`:155–159,417`), and a 300 s age-only stale rule (`:54,324`) could free a live holder's
lock. Once jobs overlapped, `reap_spawned_godot` (`:243–253`) killed every Godot spawned
after each job's snapshot (`:397,424`), which is the best fit for the banner-only,
empty-stderr, exit-1 failures of 455/461/481/482.

The prepared diff is minimal and targeted: owner-gated atomic claim/release, per-job
spawned-PID kill set, dead-holder-only SERVING advance, and stale = age **and** dead
owner. CLI, result shape, exit codes, FIFO order, and D-13 ack semantics are unchanged.

**Patch NOT applied. No runner state was touched. No job was submitted, cancelled,
reset, unwedged, acknowledged or doctored. The only repo file written is this report.
COORD should apply the diff only after the queue drains, then run the four validation
commands in §5.**
