---
id: L07-GATE-LOG-01
title: "L07 — post-fix re-verification batch execution log (STOPPED on first failure: l07-selftest)"
ticket: L07
owner: G04 (sole runner-owning agent; executing COORD's L07 batch)
created: 2026-11-25
status: STOPPED_ON_FIRST_FAILURE__NO_RERUN__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Only this report was written by G04. L07_reverify_batch.md was read, not modified. One runner job submitted (l07-selftest); no unwedge/ack/reset/doctor, no process kill by name, no test/threshold/marker change."
labels: [observed, derived, inferred, UNVERIFIED]
plan: docs/terrain_swarm_2026-11-25/reports/L07_reverify_batch.md
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
---

# L07 — post-fix re-verification batch (execution log)

## 0. Authority, labels, and stop rule

Per `WAVE_G_CHARTER.md:31`, G04 is the only Wave G agent permitted to submit runner jobs. COORD
authorised this batch after declaring the code settled; COORD's overrides to the L07 design were:
`l07-` ids (not `g04-`), runner timeout **700 s** for selftest and for uitest (uitest additionally
gets the documented user flag `--timeout 600` **after** the second `--`), new artifact dir
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07\`, a **new** report at this path, and
**stop on first failure — no rerun-of-hope, no weakening**. This log honours those overrides.

Labels: **OBSERVED** = file/command output read directly; **DERIVED** = control-flow/arithmetic
consequence; **INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all,
donor parity — no donor GPU A/B frame exists).

## 1. Pre-submit state check (read-only)

`python variant3d\tools\godot_runner.py status` (immediately before the first job):
```
now_serving = 590
next_ticket = 590
pending      = 0 []
godot.lock   = free
completed    = 500
```
Counter aligned, pending 0, lock free → G0 PASS (0 live Godot processes implied by free lock and
confirmed by the runner's clean start). `Get-CimInstance Win32_Process -Filter "Name like 'Godot%'"`
was not needed before submission because state was clean.

`git status --porcelain` (OBSERVED): `variant3d/scripts/game.gd` modified with backup
`inbox/backup/game.gd.bak-B03-relief`; `variant3d/shaders/terrain_tileindex.gdshader` modified with
`...bak-B01`; `variant3d/shaders/water3d.gdshader` modified with `...bak-P13`; `world3d_terrain.gd`
is **no longer modified** (B04 fully reverted, matching COORD's statement); `input_controller.gd`,
`tile_atlas_loader.gd`, `world3d_fx.gd`, the two atlas `.import` files, `selftest.json`,
`t_select_rect.gd`, `t_terrain_only.json` and `t_render_mode.json` also show as modified from prior
work. P13's water-shader change is present and harmless for this batch (it introduces no test
change). Fresh artifact dir `...\opencode\l07\` created before submission; no baseline was
overwritten.

## 2. Job 1 — `l07-selftest` — FAILED (batch stopped here)

Command submitted (repo root, Windows `python`, runner timeout 700 s per COORD):
```
python variant3d\tools\godot_runner.py run --id l07-selftest --timeout 700 -- --headless --path variant3d -- --self-test variant3d/selftest.json
```

Result JSON `variant3d\.godot_queue\results\00000590.json` (verbatim fields):
- `ticket`: **590**, `id`: `l07-selftest`
- `argv`: `--headless --path variant3d -- --self-test variant3d/selftest.json`
- `wait`: 0.0014 s, `run`: **143.67096495628357 s**, `exit`: **1**, `timeout`: 700.0
- `status`: **failed**
- stdout: `variant3d\.godot_queue\results\00000590_l07-selftest\stdout.txt`
- stderr: `variant3d\.godot_queue\results\00000590_l07-selftest\stderr.txt`

Integrity / findings:
- stdout contains only the banner `Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org` — **no test output** from this run.
- `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000590_l07-selftest\stderr.txt` returned verbatim:
```
[{"path": "variant3d\\.godot_queue\\results\\00000590_l07-selftest\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR count = 0**.
- stderr tail (verbatim relevant lines):
```
watchdog: wall-clock limit reached, forced exit
WARNING: 3 ObjectDB instances were leaked at exit (run with `--verbose` for details).
ERROR: 1 resources still in use at exit (run with `--verbose` for details).
```
The `ERROR:` is an **engine** resource-cleanup error, not a `SCRIPT ERROR`.
- **OBSERVED staleness:** job 590 START at epoch 1795616379.3745933 = **2026-11-25 15:19:39** local; `variant3d/selftest.json` `LastWriteTime` = **2026-11-25 14:51:29**, i.e. ~28 min **before** the job started. On disk it reads `passed=true`, 29 steps, 29 `passed=true`, 0 failed — but that is **stale**, not fresh evidence from this job.
- **DERIVED cause:** `main.gd:209-212,1588-1591` sets a default 120 s wall-clock watchdog for `--self-test`; at the slow current frame rate it forced exit at ~143 s wall (120 s watchdog + setup), so the test never wrote a fresh JSON and the process exited 1. The runner's 700 s limit was **not** the binding limit. (COORD already established the same mechanism for uitest in the prior follow-up; `--timeout <seconds>` is a documented operational flag, not a test criterion.)
- **Verdict:** job 1 is a **FAIL** for gate purposes: no fresh 29/29, exit 1, watchdog-forced exit. The stale 29/29 on disk is **UNVERIFIED as fresh evidence** and is not accepted as a PASS. No assertion failure was observed; no threshold was lowered and no marker flipped.

## 3. Jobs NOT submitted (stop-on-first-failure)

Per COORD's explicit stop rule, the remaining four jobs were **not** submitted:
`l07-uitest` (runner 700 s, user `--timeout 600`), `l07-rendermode`, `l07-p0cap` (windowed),
`l07-realmap` (windowed, seed 20261113). No ticket ids, exit codes, PNG paths, `stats` numbers or
SCRIPT ERROR counts exist for them — all **UNVERIFIED / N/A**, deliberately not fabricated.
The `...\opencode\l07\` artifact dir exists but is **empty** (no baselines overwritten).

## 4. Final queue state (read-only)
```
now_serving = 591
next_ticket = 591
pending      = 0 []
godot.lock   = free
```
Queue is clean; one unique `l07-` ticket consumed (590). No process was killed by name; no
`cancel`/`unwedge`/`ack`/`reset`/`doctor` was used; no test, tool, config or source file was edited.

## 5. Honesty / parity statement

- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- The watchdog forced exit is a performance/harness finding, not a weakened or failed assertion.
  I did not rerun the job ("no rerun-of-hope") and did not add a user flag to selftest that COORD
  did not authorise for it.
- `stats`/C01 numbers from L07 §5 were not produced because no capture job ran; none are claimed.
- G04 did not perform any visual verdict; the chessboard-gone / contours-gone R1–R6 reads belong
  to a second agent and remain UNVERIFIED.

## 6. Hand-off to COORD (no action taken)

**Recommendation only, awaiting explicit authorisation:** the selftest failure has the same root
cause as the earlier uitest failure — main's default 120 s watchdog — and `--timeout 600` is a
documented operational flag (`main.gd:31,1334,211-215`) that does not alter any assertion. If COORD
elects to allow it, re-run selftest **once** under a fresh unique id (e.g. `l07-selftest2`) with
`--timeout 600` as a user arg after the second `--` and a runner timeout of 700 s, verifying a
fresh `selftest.json` mtime after job START plus 29/29 and SCRIPT ERROR 0. Until COORD authorises
that, the batch stays STOPPED at job 1. G04 is available for the follow-up.

*End of L07 gate log — stopped on first failure, no rerun, no source edit, donor parity UNVERIFIED.*
