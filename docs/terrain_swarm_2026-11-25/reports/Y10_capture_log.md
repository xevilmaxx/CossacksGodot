---
id: Y10-CAPTURE-LOG-01
title: "Y10 — anisotropic sampler A/B capture (filter_linear_mipmap_anisotropic): PASS"
ticket: Y10 (visual probe)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y10-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y08c_capture_log.md
---

# Y10 — anisotropic sampler A/B capture

## 0. Authority and reason for this job

COORD authorised exactly one capture of Y10's anisotropic sampler A/B: shader `:60` changed to
`filter_linear_mipmap_anisotropic`, backup `.bak-Y10` (COORD reported this — G04 did not inspect or
edit the shader). The explicit extra acceptance condition was that the anisotropic hint compiles
(**SCRIPT ERROR = 0**, no shader/compile error). G04 is the sole runner-job owner
(`WAVE_G_CHARTER.md:31`) and performs no visual verdict.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=606`,
`next_ticket=606`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y10"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id y10-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y10/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000606.json` (verbatim fields):
- `ticket`: **606**, `id`: `y10-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y10/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0013606548309326172 s, `run`: **47.202231645584106 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout/stderr: `variant3d\.godot_queue\results\00000606_y10-realmap\{stdout,stderr}.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y10\realmap.png` — **1,351,399 bytes**,
written 2026-11-25 17:37:27; sidecar `realmap.png.raw.png` (1,351,399 bytes) present.

Verbatim `smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y10/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y10\\realmap.png",
    "bytes": 1351399,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      81.073,
      80.918,
      28.396
    ],
    "mean_luma": 77.166,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000606_y10-realmap\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0**. A literal grep of stderr for `SCRIPT ERROR|shader|compile|anisotropic`
returned **no lines** — the anisotropic sampler hint compiled without error, so the stop condition
did not trigger.

Verbatim capture diag from stdout:
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2392, 0.2392, 0.0706, 1.0) pcenter=(0.3569, 0.3608, 0.1137, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(145.7892, 58.0, -86.89378) target=(385.7892, 60.28682)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y10/realmap.png
```
Camera differs from the `g04`/`y07`/`y08` baseline (`(144.1104, 58.0, -88.57262)`); cross-capture
A/B attribution is **UNVERIFIED** pending matched-camera confirmation by the second agent.

**Residual caveat (OBSERVED):** stderr has 91 lines with **3 engine `ERROR:` lines**, all exit-time
cleanup, identical in class to `y04b`/`y07`/`y08`/`uvprobe`/`y08c`:
```
ERROR: Texture with GL ID of 71: leaked 5460 bytes.
ERROR: Parameter "RenderingServer::get_singleton()" is null.
ERROR: 1 resources still in use at exit (run with --verbose for details).
```
No asset-load errors, no `SCRIPT ERROR`, no shader compile error. Recorded, not claimed
harmless-by-design.

**Directory note (OBSERVED):** `...\opencode\y10\` also contains `read_metrics.py` (17:31) and
`verify_y10.py` (17:32) from another agent, written before this job. G04 wrote only
`realmap.png` / `realmap.png.raw.png` and used none of those files as evidence.

## 3. Final state and honesty statement

Final `status`: `now_serving=607`, `next_ticket=607`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (606). No other gate re-run.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
  G04 did not edit the shader — COORD reported the `:60` change.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring; that is the second agent's task.

## 4. Hand-off

**DONE.** The frame is at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y10\realmap.png`
for second-agent visual/metric A/B review. G04 stays available; no further job has been submitted.

*End of Y10 capture log — one job, PASS, anisotropic hint compiled, donor parity UNVERIFIED.*
