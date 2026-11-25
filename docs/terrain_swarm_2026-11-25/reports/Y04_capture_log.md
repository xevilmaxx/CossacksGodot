---
id: Y04-CAPTURE-LOG-01
title: "Y04 — fresh windowed real-map capture: PNG valid but GATE FAIL (SCRIPT ERROR = 1, world3d_relief.gd:341 parse error)"
ticket: Y04 (visual re-capture after smoothing guard + L01 spots)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: GATE_FAIL__SCRIPT_ERROR_1__NO_SOURCE_EDIT__NO_RERUN__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y04-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y03_capture_log.md
---

# Y04 — fresh real-map capture (after Y04 smoothing guard + L01 spots)

## 0. Authority and reason for this job

COORD authorised exactly one fresh visual re-capture after Y04's smoothing guard and L01's spots
(`game.gd` edited after the y03 capture; COORD reported the fact — G04 did not inspect or edit it).
G04 is the sole runner-job owner (`WAVE_G_CHARTER.md:31`) and performs no visual verdict.

Labels: **OBSERVED** = direct file/command output; **DERIVED** = arithmetic/control-flow
consequence; **INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all,
donor parity — no donor GPU A/B frame exists).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=597`,
`next_ticket=597`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id y04-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y04/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Runner result and PNG

Result JSON `variant3d\.godot_queue\results\00000598.json` (verbatim fields):
- `ticket`: **598**, `id`: `y04-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y04/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0007069110870361328 s, `run`: **47.39118003845215 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout: `variant3d\.godot_queue\results\00000598_y04-realmap\stdout.txt`
- stderr: `variant3d\.godot_queue\results\00000598_y04-realmap\stderr.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04\realmap.png` — **897,934 bytes**,
written 2026-11-25 16:28:17; sidecar `realmap.png.raw.png` (897,934 bytes) present.

Verbatim `smallmap_capture.py stats ".../y04/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y04\\realmap.png",
    "bytes": 897934,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      97.584,
      95.49,
      55.906
    ],
    "mean_luma": 92.88,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```
Capture diag: `camera_current=true`, `world_parent=Screenshot3DViewport`, `image=1280x720`,
`screenshot capture diag: ... camera_pos=(146.0345, 58.0, -86.64849) target=(386.0345, 60.53211)`,
`screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y04/realmap.png`.

## 3. GATE FAIL — SCRIPT ERROR = 1 (verbatim scan-stderr)

`python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000598_y04-realmap\stderr.txt`:
```
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000598_y04-realmap\\stderr.txt",
    "exists": true,
    "script_error_lines": 1,
    "lines": [
      "SCRIPT ERROR: Parse Error: Cannot infer the type of \"path\" variable because the value doesn't have a set type."
    ]
  }
]
```

Verbatim first 15 stderr lines (with the error's backtrace, read by G04 read-only):
```
1: SCRIPT ERROR: Parse Error: Cannot infer the type of "path" variable because the value doesn't have a set type.
2:    at: GDScript::reload (res://scripts/world3d_relief.gd:341)
3:    GDScript backtrace (most recent call first):
4:        [0] _instantiate (res://scripts/world3d.gd:217)
5:        [1] bind (res://scripts/world3d.gd:614)
6:        [2] _setup_full_game (res://scripts/main.gd:1105)
7:        [3] _ready (res://scripts/main.gd:235)
8: ERROR: Failed to load script "res://scripts/world3d_relief.gd" with error "Parse error".
9:    at: load (modules/gdscript/gdscript_resource_format.cpp:46)
10:    GDScript backtrace (most recent call first):
11:        [0] _instantiate (res://scripts/world3d.gd:217)
12:        [1] bind (res://scripts/world3d.gd:614)
13:        [2] _setup_full_game (res://scripts/main.gd:1105)
14:        [3] _ready (res://scripts/main.gd:235)
15: ERROR: world3d: cannot instantiate res://scripts/world3d_relief.gd
```
Counts (read-only): **SCRIPT ERROR lines = 1**, engine `ERROR:` lines = **188** (mostly
`Failed to load resource` for imported `.mesh`/`.ctex` assets such as `tree_*`, `bush1`, `mil*`
via `world3d_entities.gd:_mesh_info` / `_default_material`), plus exit-time resource leaks.

**DERIVED:** `world3d_relief.gd` failed to parse at `:341`, so `world3d` could not instantiate the
relief module; the capture still rendered and saved (runner `ok`/exit 0, PNG non-blank), but the
scene was built with a **failed script load** and many missing model/texture resources.

**Verdict:** `SCRIPT ERROR == 0` is a **mandatory** gate (`C02_gate_plan.md:378-396`;
`L07_reverify_batch.md §6`). With `script_error_lines: 1`, this capture is a **GATE FAIL** even
though runner exit 0 and the PNG is non-blank. The PNG is **not** a gate PASS and must not be used
as one; at most it is a diagnostic frame for the second agent with this caveat attached.

## 4. Final state and honesty statement

Final `status`: `now_serving=598`, `next_ticket=598`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (598). No other gate was re-run.

- No source edit, no threshold lowered, no test weakened, no code/config/test/tool touched.
  G04 did **not** fix `world3d_relief.gd:341`; that is an owning-agent task.
- **No rerun** was performed — per the standing "no reruns without go-ahead" rule.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame
  exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 made no visual R1–R6 verdict and no C01/T11 metric claim.

## 5. Hand-off

**DONE (job submitted and recorded; gate result = FAIL).** Flagged to COORD: the parse error at
`res://scripts/world3d_relief.gd:341` (`path` type inference) must be fixed by its owning agent;
then a fresh capture under a new unique id is required — G04 will not rerun it without explicit
authorisation. G04 stays available.

*End of Y04 capture log — one job, runner ok but SCRIPT ERROR 1 → GATE FAIL; donor parity UNVERIFIED.*
