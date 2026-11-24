# Final settled gate — run after every wave-2 builder releases its files

Do not interpret a transient red result while workers are editing as a regression
(AGENT_PROTOCOL §1b / past waves). Run this sequence on a QUIET queue only.

```bat
python app\tools\godot_runner.py status
python app\tools\godot_runner.py run --id coord-final-selftest --timeout 300 -- --headless --path app -- --self-test app/selftest.json
python app\tools\godot_runner.py run --id coord-final-uitest  --timeout 240 -- --headless --path app -- --ui-test app/uitest.json
python app\tools\assert_clean.py --json
```

Acceptance:
- `app/selftest.json` `"passed": true`, **29 steps**, zero failures (resow truth fix from I4).
- `app/uitest.json` `"passed": true`, **17/17**.
- clean gate `CLEAN` (0 processes, free lock, no unacked timed-out/error/skipped jobs).
- `python app\tools\godot_runner.py status` → `pending = 0`, bounded max wait.

Subset diagnostics (from I4, never overwrite the canonical report):
```bat
python app\tools\godot_runner.py run --id coord-sub-formations --timeout 180 -- --headless --path app -- --self-test app/tests/results/selftest_formations_morale.json --self-only formations_morale
python app\tools\godot_runner.py run --id coord-sub-capture --timeout 180 -- --headless --path app -- --self-test app/tests/results/selftest_capture.json --self-only capture
```
Each subset must report only its own step count (5 and 2). Re-read `app/selftest.json`
afterward and confirm it still has 29 steps.

Determinism-sensitive changes in this wave: NONE touch the generator/RNG (I1 data row,
I2 HUD timer, I3 draw scratch, I4 test-only, I5 audio cache, I6 AI spend order).
I6 changes AI resource-spend order — verify a fresh `--dump-map` is byte-identical
to a pre-change dump if the harness exposes one; otherwise record as UNVERIFIED.

After the gate: update `IMPROVEMENTS.md` with job ids/results and `PROGRESS.md` with
the final verdict.
