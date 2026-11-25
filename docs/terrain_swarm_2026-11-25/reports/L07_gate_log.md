---
id: L07-GATE-LOG-01
title: "L07 — post-fix re-verification batch execution log (STOPPED on first failure: l07-selftest)"
ticket: L07
owner: G04 (sole runner-owning agent; executing COORD's L07 batch)
created: 2026-11-25
status: BATCH_COMPLETE__4_GATES_PASS__REALMAP_PNG_UNVERIFIED__NO_SOURCE_EDIT__PARITY_UNVERIFIED
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

## 7. COORD-authorised single re-run — `l07-selftest2` — PASS (batch resumed)

COORD authorised exactly one re-run with the documented operational flag
(`main.gd:31,1334,211-215`); no threshold/assertion/marker touched. Command:
```
python variant3d\tools\godot_runner.py run --id l07-selftest2 --timeout 700 -- --headless --path variant3d -- --self-test variant3d/selftest.json --timeout 600
```
Result JSON `variant3d\.godot_queue\results\00000591.json`: ticket **591**, `status=ok`, `exit=0`,
`run=260.9694917201996 s`, wait 0.0016 s, `timeout=700.0`; stdout/stderr at
`...\00000591_l07-selftest2\`. Acceptance checks — all PASS:
- `scan-stderr` → `{"exists": true, "script_error_lines": 0, "lines": []}` (**SCRIPT ERROR = 0**).
- `selftest.json` START epoch 1795616639.8206642 = **2026-11-25 15:23:59**; `LastWriteTime` = **2026-11-25 15:28:20** → **FRESH (after START)**.
- `passed=true`, **29 steps / 29 `passed=true`**, 0 failed.

Pre-submit status was clean (591/591, pending 0, lock free); post-job status 592/592, pending 0,
lock free. No source edit, no process kill, no `unwedge`/`ack`/`reset`.

## 8. Continuation batch — `l07b-*` ids (COORD-directed)

Because selftest2 passed, COORD directed continuation under fresh `l07b-` ids with PNGs in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07b\` (no baseline overwrite). Evidence is
appended below this section as each job completes. Donor parity remains **UNVERIFIED**.

### 8.1 `l07b-uitest` — PASS
Command: `python variant3d\tools\godot_runner.py run --id l07b-uitest --timeout 700 -- --headless --path variant3d -- --ui-test variant3d/uitest.json --timeout 600`.
Result JSON `variant3d\.godot_queue\results\00000592.json`: ticket **592**, `status=ok`, `exit=0`,
`run=426.41218614578247 s`, `timeout=700.0`. Freshness: START epoch 1795616986.3161032 =
**2026-11-25 15:29:46**; `uitest.json` `LastWriteTime` = **2026-11-25 15:36:51** → **FRESH**.
`passed=true`, **17/17** steps passed, 0 failed. `scan-stderr` → `script_error_lines: 0`.

### 8.2 `l07b-rendermode` — PASS
Command: `python variant3d\tools\godot_runner.py run --id l07b-rendermode --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd`.
Result JSON `00000593.json`: ticket **593**, `status=ok`, `exit=0`, `run=10.780455112457275 s`.
`variant3d/tests/results/t_render_mode.json`: `passed=true`, `result=PASS`, `seam_missing=false`,
10/10 checks PASS. `scan-stderr` → `script_error_lines: 0`. (No main `--timeout` flag was needed.)

### 8.3 `l07b-p0cap` — PASS (windowed)
Command: `python variant3d\tools\godot_runner.py run --id l07b-p0cap --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07b/p0_64.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07b/p0_64.png" --timeout 600`.
The main `--timeout 600` user flag was added as a documented operational guard (no test change)
because selftest/uitest runs measured 261 s / 426 s on this machine.
Result JSON `00000594.json`: ticket **594**, `status=ok`, `exit=0`, `run=26.04201364517212 s`.
PNG `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07b\p0_64.png` (897,029 bytes).
Verbatim `stats`:
```
width=1280 height=720; non_black_fraction=1.0
mean_rgb=[94.562, 97.408, 32.371]; mean_luma=92.129
full_width_dark_rows=0; full_width_dark_row_fraction=0.0
NOTE: qualitative comparison only. No donor parity is claimed.
```
Atom stdout gates PASS: `harness_stub_shape`, `terrain_module_api`, `camera_module_api`,
`build_ok`, `surface_count=1`, `vertex_count=4096`, `triangle_count=7938`, `uv2_count=4096`,
`uv2_y_face_modes`, `flat_grid_promoted=0`, `res_nodes_empty`, `no_water_cells`.
`scan-stderr` → `script_error_lines: 0`.

### 8.4 `l07b-realmap` — CAPTURE-INTEGRITY FAIL / UNVERIFIED (runner exit 0 but NO PNG)
Command: `python variant3d\tools\godot_runner.py run --id l07b-realmap --timeout 600 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07b/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600 --dump-config`.
Result JSON `00000595.json`: ticket **595**, `status=ok`, `exit=0`, `run=13.191428899765015 s`,
`timeout=600.0`, `scan-stderr` → `script_error_lines: 0`.
**No PNG was produced.** `smallmap_capture.py stats ".../l07b/realmap.png"` returned verbatim:
```
FileNotFoundError: [Errno 2] No such file or directory: 'C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\l07b\\realmap.png'
```
`Get-ChildItem` of `...\opencode\l07b\` shows **only `p0_64.png`** (no `realmap.png`, no
`.png.raw.png` sidecar); stdout has **no** `screenshot capture diag` / `camera_current` line —
only the config dump. **Root cause (OBSERVED/DERIVED):** `main.gd` documents `--dump-config` as
"print the settings the game runs with, **then exit**", and L07 §3.1's command combines
`--screenshot` with `--dump-config` — a self-contradictory atom that exits before the capture
path. The config dump does prove pinned settings: `settings file: res://config.json`,
`random_seed: 20261113`, `camera.start_zoom: 0.3448276`,
`gameplay.map_width_tiles/map_height_tiles: 240`, `render_mode: 3d`.
**Verdict:** per `L07_reverify_batch.md §6` / `C02 G-Q1`, a missing frame is `UNVERIFIED → FAIL`;
the green runner status does not rescue it. This is an **instrument/plan defect**, not a visual
finding; no detector or source was edited and no cross-capture A/B is claimed from it.

### 8.5 Final state and gate ledger
Final `status`: `now_serving=596`, `next_ticket=596`, `pending=0 []`, lock free. Six unique ids
consumed in this continuation: 591 (`l07-selftest2`), 592–595 (`l07b-*`). One Godot at a time,
`status` between each; no `unwedge`/`ack`/`reset`/`doctor`, no name-based process kill,
**no source edit** (the misrouted S02-IMPL ownership was explicitly declined and never acted on).

| Gate | Result |
|---|---|
| selftest (`l07-selftest2`) | **PASS** — fresh 29/29, exit 0, SCRIPT ERROR 0 |
| uitest (`l07b-uitest`) | **PASS** — fresh 17/17, exit 0, SCRIPT ERROR 0 |
| `t_render_mode` (`l07b-rendermode`) | **PASS** — 10/10, `seam_missing=false`, 2D default intact |
| P0 capture (`l07b-p0cap`) | **PASS** — windowed 1280×720 non-blank, luma floors met, 0 dark rows, SCRIPT ERROR 0 |
| real-map capture (`l07b-realmap`) | **FAIL / UNVERIFIED** — no PNG (plan-level `--dump-config` conflict); SCRIPT ERROR 0 |
| donor parity | **UNVERIFIED** — no donor GPU A/B frame exists |
| R1–R6 visual read (chessboard-gone / contours-gone) | **UNVERIFIED** — G04 does not self-certify; second-agent review required |

**Hand-off, no action taken:** `l07b-realmap` needs a fresh rerun under a new unique id with
`--dump-config` removed (the config proof is already captured above), pending COORD go-ahead —
per "no reruns without go-ahead" I did not resubmit it. G04 performed no visual verdict and no
C01/C09 metric scoring; those belong to the second agent.

### 8.6 OBSERVED cross-touch during the batch (integrity caveat, no action by G04)
`git status --porcelain` after the batch shows `variant3d/scripts/hud.gd`,
`variant3d/scripts/main.gd`, `variant3d/tests/t_hud_layout.gd` modified, plus three
`inbox/*.bak-S02` backups. Their `LastWriteTime` is **2026-11-25 15:32:05** — inside the
`l07b-uitest` window (START 15:29:46, result 15:36:51) — while the backups were written
12:43–13:01, **before** this batch. These are the work of the **separate S02-IMPL agent** after
COORD's misroute correction; **G04 created no backup and edited none of these files**. Because the
S02 edits landed mid-batch, the earlier jobs may have loaded pre-edit sources and the later ones
post-edit sources; the gate results above are recorded verbatim as run, but any claim that they
certify the *post-S02* tree is **UNVERIFIED**. COORD should decide whether a clean re-run on a
settled tree is needed.

*End of L07 gate log — batch executed, four gates PASS, real-map capture UNVERIFIED (missing PNG), donor parity UNVERIFIED.*

