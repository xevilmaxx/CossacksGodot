# Clean-exit / zero-orphan release gate (N-20)

The brief requires "Godot never hangs during tests". `godot_runner.py` enforces
this at job time (FIFO lock + hard timeout + `doctor` to kill orphans), but it
did not *assert* cleanliness. `assert_clean.py` is that assertion: a read-only
check that exits **0 only if the machine is clean**, 1 otherwise.

`assert_clean.py` never kills anything and never writes to the spool. Remediation
remains `python app\tools\godot_runner.py doctor`.

## What it checks

| Signal | Source | DIRTY when |
|---|---|---|
| Orphan processes | PowerShell `Get-CimInstance ... Name like 'Godot%'` (Win), `pgrep -f godot` (POSIX) | any Godot process is still alive |
| Lock | `app/.godot_queue/godot.lock` | lock exists and is older than `--max-lock-age` (or its age is unreadable) |
| History | `app/.godot_queue/status.json` → `history[]` | any job has `status` in `{timed-out, error, skipped}` |

Notes:
- A lock younger than `--max-lock-age` is tolerated (a runner job may be in
  flight); the process signal is the authoritative orphan check. Default
  `300 s` matches the runner's `STALE_SEC`.
- `failed` (non-zero exit) is deliberately **not** a failure signal — a test may
  fail cleanly. Only leaked/hung/skipped jobs are.
- Paths come from `__file__`, so run the command from the project root.

## CLI

```
python app\tools\assert_clean.py                       # human-readable report
python app\tools\assert_clean.py --json                # machine-readable
python app\tools\assert_clean.py --max-lock-age 30     # stricter stale-lock bound
python app\tools\assert_clean.py --ignore-history      # accept historical failures
```

`--ignore-history` suppresses only the `status.json` check (useful when the
queue holds known old failures from unrelated workers); processes and lock are
still checked.

## Exit codes

| Code | Meaning |
|---|---|
| `0` | CLEAN — no Godot processes, no stale lock, no failure-status jobs |
| `1` | DIRTY — at least one check failed; do not sign the release |
| `2` | Bad invocation (e.g. negative `--max-lock-age`) |

## How QA wires it into the release gate (ticket O-01)

Run every acceptance job **through the runner**, then assert. Example (Windows,
from the project root):

```
python app\tools\godot_runner.py run --id agentO-selftest --timeout 180 -- --headless --path app -- --self-test app/selftest.json
python app\tools\godot_runner.py run --id agentO-uitest  --timeout 180 -- --headless --path app -- --ui-test app/uitest.json
python app\tools\godot_runner.py run --id agentO-cli     --timeout 180 -- --headless --path app -- --cli app/cli.json --cli-seconds 60
python app\tools\godot_runner.py run --id agentO-shot   --timeout 90  -- --path app -- --screenshot app/shots/g4_l1.png --timeout 60
python app\tools\assert_clean.py
if %ERRORLEVEL% NEQ 0 ( python app\tools\godot_runner.py doctor & goto fail )
```

POSIX equivalent of the last two lines:

```
python app/tools/assert_clean.py || { python app/tools/godot_runner.py doctor; exit 1; }
```

For CI, capture the machine-readable form and fail the pipeline on exit 1:

```
python app/tools/assert_clean.py --json > clean_gate.json || exit 1
```

N-20 also asks for repetition: run selftest, uitest, CLI and screenshot **3×**
via the runner, asserting clean after each batch, with bounded `max wait` in
`python app\tools\godot_runner.py status`. Three consecutive clean batches with
zero orphans is the measurable proof of "never hangs".

## Interpreting a DIRTY result

- **processes DIRTY** — a Godot process leaked. On Windows it was likely a
  `quit()`-in-`_initialize()` script (see N-01 / `mill_render_test.gd`). Fix the
  script to use `call_deferred("quit", code)`, then run `doctor`.
- **lock stale** — a worker died mid-job or the lock was not released. `doctor`
  clears it; `reset --yes` clears all queue state (maintenance only).
- **history DIRTY** — a job timed out, errored or was skipped. Inspect the job's
  `stdout.txt`/`stderr.txt` under `app/.godot_queue/results/`. Use
  `--ignore-history` only if the failures are known and unrelated to this gate.

## Coordinator rulings (2026-11-21)

1. **N-20 accepted as-is.** The standalone `assert_clean.py` satisfies the
   measurable no-hang gate; the runner does NOT need a `doctor --assert-clean`
   subcommand. Keeping assertion separate from remediation is deliberate.
2. **`failed` is excluded from the failure set.** Correct — self-test steps are
   currently red from known game-logic tickets (A-01, P-01..P-04); including
   `failed` would make the gate permanently red and therefore useless. The gate
   tracks *hangs and infrastructure failures*, not gameplay correctness.
3. **Young held locks are tolerated.** Correct — false positives during an
   in-flight job are worse. QA must run the gate on a quiet queue (no pending
   jobs, no live Godot process) for a meaningful verdict.
4. **Live DIRTY verdicts during swarm churn are expected.** They are not a
   failure of the gate. The release gate runs after the batch settles.

## Resolved historical failures (`ack`)

A `timed-out`/`error`/`skipped` entry stays in the history forever, so a fixed
hang would keep the gate permanently red. The coordinator acknowledges resolved
failures, which makes `assert_clean.py` skip them while still counting them:

```
python app\tools\godot_runner.py ack <ticket> --reason "<fix evidence>"
```

2026-11-21: ticket 20 (`agentF2-millrender`) acknowledged — worker F added the
headless guard to `mill_render_test.gd`; `F3-headless` (1.99 s) and
`F3-windowed` (11.15 s) both exited `ok` with zero orphans. Gate is CLEAN.
