# QA-2D-FRESH-01 — Re-verify 2D shipping gates on current tree

**Scope:** READ-ONLY on all code/config/tests. Runner jobs used **only** the 2D runner
(`python app\tools\godot_runner.py run --id <unique> --timeout <s> -- ...`).
No direct `godot`, no variant runner, no `doctor`/`cancel`/`reset`/`unwedge`/`ack`, no git operations.

## 1. Runner status BEFORE jobs (`godot_runner.py status`)

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

- Spool: `app/.godot_queue/` (contains `jobs/`, `results/`, `counter`, `now_serving`, `godot.lock`, `status.json`).
- Queue empty, lock free → no FIFO wait required; no slow job was re-submitted.

## 2. Verification jobs

| Job id | Ticket | Command | Timeout | Runner status | Exit | Wait | Run |
|---|---|---|---|---|---|---|---|
| `qa2dfresh01-selftest` | 1350 | `--headless --path app -- --self-test app/selftest.json` | 300 s | `ok` | 0 | 0.0047 s | 99.24 s |
| `qa2dfresh01-uitest` | 1351 | `--headless --path app -- --ui-test app/uitest.json` | 240 s | `ok` | 0 | 0.0010 s | 87.41 s |

Runner log lines:
```
[runner] ticket 1350 'qa2dfresh01-selftest' START (waited 0.00s)
[runner] ticket 1350 'qa2dfresh01-selftest' END ok (run 99.24s)
[runner] ticket 1351 'qa2dfresh01-uitest' START (waited 0.00s)
[runner] ticket 1351 'qa2dfresh01-uitest' END ok (run 87.41s)
```

Status-history records (from `app/.godot_queue/status.json`):
```
{"ticket": 1350, "id": "qa2dfresh01-selftest", "status": "ok", "exit": 0, "wait": 0.0047, "run": 99.2377}
{"ticket": 1351, "id": "qa2dfresh01-uitest",   "status": "ok", "exit": 0, "wait": 0.0010, "run": 87.4136}
```

### 2a. Clean-gate assertion (read-only, direct python — not a runner job)

Command: `python app\tools\assert_clean.py --json`

Result (exit 0):
```json
{
  "clean": true,
  "verdict": "CLEAN",
  "reasons": [],
  "checks": {
    "processes": { "clean": true, "count": 0, "details": [] },
    "lock": { "clean": true, "exists": false, "state": "free", "age_sec": null, "max_age_sec": 300.0 },
    "history": { "clean": true, "enabled": true, "total": 258, "acknowledged": 9, "failures": [] }
  }
}
```

## 3. Pass counts (re-read from regenerated JSONs)

| Artifact | Top-level `passed` | Steps | Passed | Failed |
|---|---|---|---|---|
| `app/selftest.json` | `true` | 29 | **29** | 0 |
| `app/uitest.json` | `true` | 17 | **17** | 0 |

- Expected 29/29 self-test: **met**.
- Expected 17/17 UI test: **met**.
- **Failing steps: none.** No assertions were weakened, skipped or modified.

Note: `app/selftest.json` and `app/uitest.json` are runner-generated outputs, rewritten by
the two jobs above; they were not authored by hand.

## 4. Runner status AFTER jobs (`godot_runner.py status`)

```
now_serving = 1352
next_ticket = 1352
pending      = 0 []
godot.lock   = free
completed    = 258
max wait     = 471.58s   mean wait = 38.99s
max run      = 381.53s
statuses     = {'failed': 77, 'ok': 172, 'skipped': 1, 'timed-out': 8}
```

Queue drained, lock free; `ok` count rose from 170 → 172 (the two jobs in this QA).

## 5. VERDICT

**2D gates CONFIRMED_GREEN on the current tree.**

- Self-test 29/29, UI test 17/17, clean gate CLEAN/exit 0 — all gates pass on the tree as given.
- No failing step was found; nothing was weakened or bypassed.
- **`app/**` was not edited.** All actions were read-only except the three permitted verification
  jobs, which regenerated only their own runner-owned JSON outputs. The sole hand-authored file
  is this report.
