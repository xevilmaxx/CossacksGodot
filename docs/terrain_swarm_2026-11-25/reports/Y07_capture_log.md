---
id: Y07-CAPTURE-LOG-01
title: "Y07 — fresh windowed real-map capture after widened smoothing guards: PASS"
ticket: Y07 (visual re-capture)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y07-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y04b_gate_log.md
---

# Y07 — fresh real-map capture (after Y07 widened smoothing guards)

## 0. Authority and reason for this job

COORD authorised exactly one fresh visual re-capture after Y07's widened smoothing guards
(`game.gd` edited, backup `.bak-Y07`; COORD reported this — G04 did not inspect or edit it).
G04 is the sole runner-job owner (`WAVE_G_CHARTER.md:31`) and performs no visual verdict.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=601`,
`next_ticket=601`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y07"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id y07-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y07/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000601.json` (verbatim fields):
- `ticket`: **601**, `id`: `y07-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y07/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0033490657806396484 s, `run`: **102.863600730896 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout/stderr: `variant3d\.godot_queue\results\00000601_y07-realmap\{stdout,stderr}.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y07\realmap.png` — **1,525,857 bytes**,
written 2026-11-25 16:47:33; sidecar `realmap.png.raw.png` (1,525,857 bytes) present.

Verbatim `smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y07/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y07\\realmap.png",
    "bytes": 1525857,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      85.513,
      82.949,
      34.432
    ],
    "mean_luma": 79.987,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000601_y07-realmap\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0**.

Verbatim capture diag from stdout:
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2314, 0.2353, 0.0667, 1.0) pcenter=(0.1059, 0.098, 0.0941, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(144.1104, 58.0, -88.57262) target=(384.1104, 58.60797)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y07/realmap.png
```
Notable (OBSERVED): this frame's `camera_pos=(144.1104, 58.0, -88.57262)` matches the original
`g04/realmap` baseline exactly (unlike `y03`/`y04b`, which shifted). Cross-capture A/B attribution
is therefore on matched camera, but **donor parity remains UNVERIFIED** and no visual read was
performed by G04.

**Residual caveat (OBSERVED):** stderr has 91 lines with **3 engine `ERROR:` lines**, all exit-time
cleanup, identical in class to `y04b`:
```
ERROR: Texture with GL ID of 71: leaked 5460 bytes.
ERROR: Parameter "RenderingServer::get_singleton()" is null.
ERROR: 1 resources still in use at exit (run with --verbose for details).
```
No asset-load errors and no `SCRIPT ERROR`. Recorded, not claimed harmless-by-design.

## 3. Final state and honesty statement

Final `status`: `now_serving=602`, `next_ticket=602`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (601). No other gate re-run.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring; that is the second agent's task.

## 4. Hand-off

**DONE.** The frame is at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y07\realmap.png`
for second-agent visual review. G04 stays available; no further job has been submitted.

*End of Y07 capture log — one job, PASS, donor parity UNVERIFIED.*
