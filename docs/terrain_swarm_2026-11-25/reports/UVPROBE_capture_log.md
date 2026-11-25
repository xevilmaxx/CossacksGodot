---
id: UVPROBE-CAPTURE-LOG-01
title: "UVPROBE — 4 m UV probe (shader :214 0.5 -> 0.25) windowed capture: PASS"
ticket: UVPROBE (visual probe)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (uvprobe-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y08_capture_log.md
---

# UVPROBE — 4 m UV probe capture

## 0. Authority and reason for this job

COORD authorised exactly one capture of the 4 m UV probe: `shader :214` changed `0.5` → `0.25`,
backup `.bak-B01b` (COORD reported this — G04 did not inspect or edit the shader). G04 is the sole
runner-job owner (`WAVE_G_CHARTER.md:31`) and performs no visual verdict; this frame is an input
for the second agent's visual/metric comparison against earlier real-map frames.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=603`,
`next_ticket=603`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\uvprobe"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id uvprobe-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/uvprobe/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000603.json` (verbatim fields):
- `ticket`: **603**, `id`: `uvprobe-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/uvprobe/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0007040500640869141 s, `run`: **39.51112103462219 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout/stderr: `variant3d\.godot_queue\results\00000603_uvprobe-realmap\{stdout,stderr}.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\uvprobe\realmap.png` — **1,418,152 bytes**,
written 2026-11-25 17:06:23; sidecar `realmap.png.raw.png` (1,418,152 bytes) present.

Verbatim `smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/uvprobe/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\uvprobe\\realmap.png",
    "bytes": 1418152,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      84.583,
      82.669,
      32.705
    ],
    "mean_luma": 79.478,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000603_uvprobe-realmap\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0**.

Verbatim capture diag from stdout:
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2353, 0.2392, 0.0706, 1.0) pcenter=(0.2392, 0.1843, 0.1294, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(145.4698, 58.0, -87.21319) target=(385.4698, 59.96741)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/uvprobe/realmap.png
```
Camera differs from the `g04`/`y07`/`y08` baseline (`(144.1104, 58.0, -88.57262)`) — this frame's
`(145.4698, 58.0, -87.21319)` is close to the `y03`/`y04b` cluster. **INFERRED:** normal
seed-dependent map-generation variance at the same camera settings; any cross-capture A/B
attribution is **UNVERIFIED** until a second agent confirms matched camera/zoom. G04 made no
visual verdict.

**Residual caveat (OBSERVED):** stderr has 91 lines with **3 engine `ERROR:` lines**, all exit-time
cleanup, identical in class to `y04b`/`y07`/`y08`:
```
ERROR: Texture with GL ID of 71: leaked 5460 bytes.
ERROR: Parameter "RenderingServer::get_singleton()" is null.
ERROR: 1 resources still in use at exit (run with --verbose for details).
```
No asset-load errors and no `SCRIPT ERROR`. Recorded, not claimed harmless-by-design.

## 3. Final state and honesty statement

Final `status`: `now_serving=604`, `next_ticket=604`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (603). No other gate re-run.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
  G04 did not edit the shader (`shader :214`) — COORD reported that change.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring; that is the second agent's task.

## 4. Hand-off

**DONE.** The frame is at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\uvprobe\realmap.png`
for second-agent visual/metric review against earlier real-map frames. G04 stays available; no
further job has been submitted.

*End of UVPROBE capture log — one job, PASS, donor parity UNVERIFIED.*
