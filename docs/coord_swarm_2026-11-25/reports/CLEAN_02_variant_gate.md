---
title: CLEAN-02 — point variant3d assert_clean.py at the VARIANT spool
area: variant3d / clean gate / tooling
owner: CLEAN-02 queue-hygiene micro-worker
date: 2026-11-25
status: TOOL FIXED — gate signing DEFERRED to COORD after queue drain
---

# CLEAN-02 — variant gate tool spool correction

## 1. Scope and references read

- `docs/coord_swarm_2026-11-25/reports/CLEAN_01_variant_clean.md` §5 (independent
  variant-spool check), plus its §4 critical-tool finding and §6 verdict conditions.
- `variant3d/tools/assert_clean.py` (full file, read/write — exclusive ownership).
- `variant3d/tools/godot_runner.py:46-53` — `ROOT = Path(__file__).resolve().parents[2]`,
  `SPOOL = ROOT / "variant3d" / ".godot_queue"` (the authoritative variant spool definition).
- `docs/CLEAN_GATE.md:100-103` was requested but **does not exist** in this repo. The
  same text was read at `variant3d/tools/CLEAN_GATE.md:100-103`, which is the file CLEAN-01
  §4 actually cites: "QA must run the gate on a quiet queue (no pending jobs, no live
  Godot process) for a meaningful verdict" and "Live DIRTY verdicts during swarm churn
  are expected. They are not a failure of the gate."
- `app/tools/assert_clean.py` read-only for reference: byte-identical to the variant copy,
  including the same wrong-at line 34. **Not edited** (out of scope).

CLEAN-01 §5 established that direct reading of `variant3d/.godot_queue/status.json` gave
407 history entries, 98 acknowledged, **0 unacked failure-status jobs**, 2 unacked `failed`
jobs (296, 300 — excluded by D-13), and a held lock with live jobs. CLEAN-01 §6 stated that
a formal CLEAN verdict requires, among other things, that `assert_clean.py` be pointed at
`variant3d/.godot_queue` — this task implements exactly that prerequisite.

## 2. Backup

Made before any edit, using the exact requested command:

```
copy variant3d\tools\assert_clean.py inbox\backup\assert_clean.py.bak-CLEAN02
```

Result: `inbox/backup/assert_clean.py.bak-CLEAN02` created; SHA-256 of backup and of the
pre-edit original matched (`10E55201F609D...`).

## 3. Before → after (one line changed)

`variant3d/tools/assert_clean.py`:

| Line | Before | After |
|---:|---|---|
| 34 | `SPOOL = ROOT / "app" / ".godot_queue"` | `SPOOL = ROOT / "variant3d" / ".godot_queue"` |

Line 33 `ROOT = Path(__file__).resolve().parents[2]` is unchanged and continues to mirror
`variant3d/tools/godot_runner.py:46`. Lines 35-36 derive `GODOT_LOCK` and `STATUS` from
`SPOOL`, so both now resolve to `variant3d/.godot_queue/godot.lock` and
`variant3d/.godot_queue/status.json` automatically. No other line was changed.

Verified by re-reading lines 30-39 and by grep over the whole edited file for
`app/.godot_queue` / `app\.godot_queue`: **no matches**. No remaining hard-coded 2D spool
path exists in this file.

Gate semantics, `FAILURE_STATUSES` (D-13: `failed` excluded) at lines 40-42, exit codes
(0/1/2), CLI flags (`--json`, `--max-lock-age`, `--ignore-history`) and all check/report
logic are byte-for-byte unchanged.

## 4. Validation (read-only, honest output)

Command (from project root): `python variant3d\tools\assert_clean.py --json`

Verbatim stdout, exit code **1**:

```json
{
  "clean": false,
  "verdict": "DIRTY",
  "reasons": [
    "1 Godot process(es) alive"
  ],
  "checks": {
    "processes": {
      "clean": false,
      "count": 1,
      "details": [
        {
          "pid": 13768,
          "name": "Godot_v4.7.2-stable_win64.exe",
          "command": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Microsoft\\WinGet\\Links\\godot.EXE --headless --path variant3d -- --self-test variant3d/selftest.json"
        }
      ]
    },
    "lock": {
      "clean": true,
      "exists": true,
      "state": "held_recent",
      "age_sec": 7.778902292251587,
      "max_age_sec": 300.0
    },
    "history": {
      "clean": true,
      "enabled": true,
      "total": 411,
      "acknowledged": 22,
      "failures": []
    }
  }
}
EXITCODE=1
```

Interpretation, without claiming a green gate:

- **The tool now reads the variant spool.** Evidence: `history.total` is 411 and
  `history.acknowledged` is 22, versus the 2D spool's 254 / 9 recorded in CLEAN-01 §2.
  The lock is also the variant one (held, not the 2D free lock).
- `history.clean = true`, `failures: []`, `acknowledged: 22` — the 22 acknowledged entries
  are exactly the 22 gate-relevant `timed-out` jobs CLEAN-01 acked; the 98 total acked in
  CLEAN-01 §5 include 78 `failed` jobs that D-13 excludes from `FAILURE_STATUSES`. This is
  consistent with CLEAN-01 §5's "0 unacked failure-status jobs".
- `VERDICT: DIRTY`, exit 1, is the **correct and expected** result while a live variant job
  (PID 13768, `--path variant3d -- --self-test variant3d/selftest.json`) is running and a
  recent lock is held. Per `variant3d/tools/CLEAN_GATE.md:100-103` this is swarm churn, not
  a failure of the fix. No process was killed, no job cancelled, no queue reset, no wait
  for drain, and no direct `godot` invocation.
- The live PID changed from CLEAN-01's 4508 to 13768 and history total moved 407 → 411,
  confirming the queue is still churning.

## 5. Gate signing

**Formal CLEAN gate signing is explicitly DEFERRED to COORD after the queue drains.**
This worker only corrected the tool's spool path. A signable verdict requires a quiet
queue (no pending tickets, no live Godot process) and a fresh `assert_clean.py` run
returning CLEAN / exit 0 — neither condition holds at validation time. No CLEAN claim is
made here.

## 6. Open questions

1. Docstring line 16 still says `python app/tools/godot_runner.py doctor` as the remediation
   hint. It is not an `app/.godot_queue` path and was left untouched under the
   minimal-change instruction; COORD may decide whether to retarget it to
   `variant3d/tools/godot_runner.py doctor` in a separate task.
2. `app/tools/assert_clean.py:34` remains wired to `app/.godot_queue`. That file was
   explicitly out of scope and was not edited; the 2D gate's own semantics are unaffected.
3. Queue state (pending tickets, PID, lock age, history total) is a moving target; the
   numbers above are a point-in-time observation only.
4. Tickets 296 and 300 remain unacked `failed`, excluded by D-13; unchanged by this task.

## 7. Summary

- Fixed the single mis-wired line in `variant3d/tools/assert_clean.py` (line 34) so the
  variant gate checks `variant3d/.godot_queue`, mirroring `godot_runner.py:47`; the
  required path change identified in CLEAN-01 §5/§6 is now in place.
- Backup saved to `inbox/backup/assert_clean.py.bak-CLEAN02` before the edit.
- Validation run correctly reported **DIRTY / exit 1** because a live variant Godot job and
  a held lock exist; the history signal is clean (0 unacked failure-status jobs, 22 acked).
- Gate signing deferred to COORD after queue drain.
- **Files authored/edited:** only `variant3d/tools/assert_clean.py` (one line) and this
  report. Backup file created as instructed. **No other file was edited** — in particular
  not `app/tools/assert_clean.py`, not the runner, not queue results/status, and no other
  report.
