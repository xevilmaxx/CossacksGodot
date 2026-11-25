---
id: Y08-CAPTURE-LOG-01
title: "Y08 — fresh windowed real-map capture after single-ground-ID authority: PASS"
ticket: Y08 (visual re-capture)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y08-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/Y07_capture_log.md
---

# Y08 — fresh real-map capture (after Y08 single-ground-ID authority)

## 0. Authority and reason for this job

COORD authorised exactly one fresh visual re-capture after Y08's single-ground-ID authority
(`game.gd` edited, backup `.bak-Y08`; COORD reported this — G04 did not inspect or edit it).
G04 is the sole runner-job owner (`WAVE_G_CHARTER.md:31`) and performs no visual verdict.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=602`,
`next_ticket=602`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id y08-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000602.json` (verbatim fields):
- `ticket`: **602**, `id`: `y08-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0007519721984863281 s, `run`: **61.37613797187805 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout/stderr: `variant3d\.godot_queue\results\00000602_y08-realmap\{stdout,stderr}.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08\realmap.png` — **1,419,673 bytes**,
written 2026-11-25 17:00:53; sidecar `realmap.png.raw.png` (1,419,673 bytes) present.

Verbatim `smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y08\\realmap.png",
    "bytes": 1419673,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      83.567,
      81.462,
      32.622
    ],
    "mean_luma": 78.388,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `scan-stderr`:
```
[{"path": "variant3d\\.godot_queue\\results\\00000602_y08-realmap\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```
→ **SCRIPT ERROR = 0**.

Verbatim capture diag from stdout:
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2314, 0.2353, 0.0667, 1.0) pcenter=(0.1059, 0.098, 0.0941, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(144.1104, 58.0, -88.57262) target=(384.1104, 58.60797)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08/realmap.png
```
Camera matches the `g04/realmap` and `y07` baselines exactly (`(144.1104, 58.0, -88.57262)`),
so any later cross-capture A/B is on matched camera. No visual read by G04; donor parity
**UNVERIFIED**.

**Residual caveat (OBSERVED):** stderr has 91 lines with **3 engine `ERROR:` lines**, all exit-time
cleanup, identical in class to `y04b`/`y07`:
```
ERROR: Texture with GL ID of 71: leaked 5460 bytes.
ERROR: Parameter "RenderingServer::get_singleton()" is null.
ERROR: 1 resources still in use at exit (run with --verbose for details).
```
No asset-load errors and no `SCRIPT ERROR`. Recorded, not claimed harmless-by-design.

**Directory note (OBSERVED):** `...\opencode\y08\` also contains pre-existing analysis scripts and
PNG crops from another agent (`ab.py`, `alpha_patches.py`, `zoom_*.png`, etc., mtimes 16:39–16:50),
created before this job. G04 wrote only `realmap.png` and `realmap.png.raw.png` there; none of the
other files were touched or used as evidence.

## 3. Final state and honesty statement

Final `status`: `now_serving=603`, `next_ticket=603`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (602). No other gate re-run.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring; that is the second agent's task.

## 4. Hand-off

**DONE.** The frame is at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08\realmap.png`
for second-agent visual review. G04 stays available; no further job has been submitted.

*End of Y08 capture log — one job, PASS, donor parity UNVERIFIED.*
