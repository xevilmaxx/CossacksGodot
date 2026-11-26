---
id: Y08C-CAPTURE-LOG-01
title: "Y08c — retry after game.gd ci-scoping fix: capture PASS"
ticket: Y08c (visual re-capture retry)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y08c-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y08b_capture_log.md
---

# Y08c — retry capture after COORD's `ci` scoping fix

## 0. Authority and reason for this job

`Y08b_capture_log.md` recorded a GATE FAIL: 5 SCRIPT ERRORs from undeclared `ci` at
`game.gd:397-398`, no PNG. COORD corrected the `ci` scoping at `game.gd:394-398` (radius semantics
preserved) and authorised exactly one retry. G04 is the sole runner-job owner
(`WAVE_G_CHARTER.md:31`) and performs no visual verdict.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=605`,
`next_ticket=605`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08c"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id y08c-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08c/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000605.json` (verbatim fields):
- `ticket`: **605**, `id`: `y08c-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08c/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0017573833465576172 s, `run`: **46.274123191833496 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout/stderr: `variant3d\.godot_queue\results\00000605_y08c-realmap\{stdout,stderr}.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08c\realmap.png` — **1,200,060 bytes**,
written 2026-11-25 17:27:44; sidecar `realmap.png.raw.png` (1,200,060 bytes) present.

Verbatim `smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08c/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y08c\\realmap.png",
    "bytes": 1200060,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      82.224,
      82.045,
      28.884
    ],
    "mean_luma": 78.248,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000605_y08c-realmap\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0** (the stop condition did not trigger; the `ci` parse errors are gone).

Verbatim capture diag from stdout:
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2431, 0.2471, 0.0706, 1.0) pcenter=(0.3725, 0.3647, 0.1137, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(145.9536, 58.0, -86.72936) target=(385.9536, 60.45124)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08c/realmap.png
```
Camera differs from the `g04`/`y07`/`y08` baseline (`(144.1104, 58.0, -88.57262)`); cross-capture
A/B attribution is **UNVERIFIED** pending matched-camera confirmation by the second agent.

**Residual caveat (OBSERVED):** stderr has 91 lines with **3 engine `ERROR:` lines**, all exit-time
cleanup, identical in class to `y04b`/`y07`/`y08`/`uvprobe`:
```
ERROR: Texture with GL ID of 71: leaked 5460 bytes.
ERROR: Parameter "RenderingServer::get_singleton()" is null.
ERROR: 1 resources still in use at exit (run with --verbose for details).
```
No asset-load errors, no `SCRIPT ERROR`. Recorded, not claimed harmless-by-design.

## 3. Final state and honesty statement

Final `status`: `now_serving=606`, `next_ticket=606`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (605). No other gate re-run.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
  G04 did not apply the `ci` fix — COORD did.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring; that is the second agent's task.

## 4. Hand-off

**DONE.** The frame is at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08c\realmap.png`
for second-agent visual review. G04 stays available; no further job has been submitted.

*End of Y08c capture log — one job, PASS, donor parity UNVERIFIED.*
