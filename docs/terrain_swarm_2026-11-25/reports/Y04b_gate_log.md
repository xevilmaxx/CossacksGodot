---
id: Y04B-GATE-LOG-01
title: "Y04b — two-step recovery (bucket import + real-map capture): PASS"
ticket: Y04b
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Exactly one new report written. Two runner jobs submitted (g04-import-buckets, y04b-realmap), sequentially with status between them. No code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y04_capture_log.md
---

# Y04b — two-step recovery after the y04 gate fail

## 0. Authority and reason

COORD authorised a two-step recovery after `Y04_capture_log.md` recorded `SCRIPT ERROR = 1`
(`world3d_relief.gd:341` parse error) plus 188 asset-load errors. COORD fixed the parse error
(typed `var path: String`) and identified the asset errors as bucket copies lacking Godot `.import`
sidecars after FOLD06's migration, requiring an editor import pass. G04 submitted exactly the two
authorised jobs, one at a time, with `status` re-checked between them. No source edit by G04.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Step 1 — `g04-import-buckets` (editor import pass) — PASS

Command (exact, from COORD):
```
python variant3d\tools\godot_runner.py run --id g04-import-buckets --timeout 700 -- --headless --path variant3d --editor --quit
```
Pre-flight: `now_serving=599`, `next_ticket=599`, `pending=0 []`, lock free.

Result JSON `variant3d\.godot_queue\results\00000599.json` (verbatim fields): ticket **599**,
`status=ok`, `exit=0`, `wait=0.001735687255859375 s`, `run=229.5950083732605 s`, `timeout=700.0`.
stdout/stderr: `variant3d\.godot_queue\results\00000599_g04-import-buckets\{stdout,stderr}.txt`.

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000599_g04-import-buckets\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0**, so the stop condition did not trigger. Post-job status:
`now_serving=600`, `next_ticket=600`, `pending=0 []`, lock free.

## 2. Step 2 — `y04b-realmap` (windowed capture) — PASS

Fresh artifact dir created: `New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04b"`.

Command (exact, from COORD):
```
python variant3d\tools\godot_runner.py run --id y04b-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y04b/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

Result JSON `variant3d\.godot_queue\results\00000600.json` (verbatim fields): ticket **600**,
`status=ok`, `exit=0`, `wait=0.0007421970367431641 s`, `run=50.569905042648315 s`, `timeout=700.0`.
stdout/stderr: `variant3d\.godot_queue\results\00000600_y04b-realmap\{stdout,stderr}.txt`.

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04b\realmap.png` — **1,553,208 bytes**,
written 2026-11-25 16:35:59; sidecar `realmap.png.raw.png` (1,553,208 bytes) present.

Verbatim `smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y04b/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y04b\\realmap.png",
    "bytes": 1553208,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      85.863,
      83.041,
      35.116
    ],
    "mean_luma": 80.167,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000600_y04b-realmap\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0** (all stated acceptance conditions met).

Verbatim capture diag from stdout:
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2431, 0.2431, 0.0667, 1.0) pcenter=(0.3412, 0.302, 0.1882, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(145.2856, 58.0, -87.39741) target=(385.2856, 59.78319)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y04b/realmap.png
```

**Residual caveat (OBSERVED, recorded for honesty):** stderr has 91 lines and **3 engine `ERROR:`
lines**, all at exit-time cleanup, not load failures:
```
ERROR: Texture with GL ID of 71: leaked 5460 bytes.
ERROR: Parameter "RenderingServer::get_singleton()" is null.
ERROR: 1 resources still in use at exit (run with --verbose for details).
```
The 188 `Failed to load resource` errors seen in the y04 capture are **gone** after the import pass.
These exit-time messages are the same class recorded on earlier green jobs (e.g. `g04-uitest2`)
and do not change the stated gate result; G04 makes no claim that they are harmless-by-design.

## 3. Final state and honesty statement

Final `status`: `now_serving=601`, `next_ticket=601`, `pending=0 []`, `godot.lock=free`. Two unique
tickets consumed (599, 600), submitted sequentially with `status` between them; no name-based
process kill, no `unwedge`/`ack`/`reset`/`doctor`.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
  G04 did not fix `world3d_relief.gd:341` — COORD did — and did not perform the import by any
  means other than the authorised runner job.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring; the PNG is handed to the
  second agent. Camera differs slightly from earlier real-map frames, so cross-capture A/B
  attribution is **UNVERIFIED** pending a matched-camera check.

## 4. Hand-off

**DONE.** Both authorised steps completed; the clean frame is at
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04b\realmap.png` for second-agent visual
review. G04 stays available for a follow-up; no further job has been submitted.

*End of Y04b gate log — two steps, both PASS, donor parity UNVERIFIED.*
