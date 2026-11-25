---
id: L07C-GATE-LOG-01
title: "L07c — corrected windowed real-map capture (no --dump-config): PASS"
ticket: L07c
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__NO_RERUN__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (l07c-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/L07_gate_log.md
---

# L07c — corrected real-map capture

## 0. Authority and reason for this job

`L07_gate_log.md §8.4` recorded `l07b-realmap` as a capture-integrity FAIL: the runner exited 0,
but no PNG was written because L07 §3.1's command combined `--screenshot` with `--dump-config`,
and `main.gd` documents `--dump-config` as "print the settings the game runs with, **then exit**".
Per the earlier "no reruns without go-ahead" rule, G04 did not resubmit. COORD then authorised
exactly one corrected capture under id `l07c-realmap` with `--dump-config` removed.

Labels: **OBSERVED** = direct file/command output; **DERIVED** = arithmetic/control-flow
consequence; **UNVERIFIED** = not proven (above all, donor parity — no donor GPU A/B frame exists).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=596`,
`next_ticket=596`, `pending=0 []`, `godot.lock=free` (counter aligned, queue quiet). Fresh artifact
dir created: `New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07c"`.

Exact command submitted (repo root, Windows `python`, windowed — no `--headless`):
```
python variant3d\tools\godot_runner.py run --id l07c-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07c/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000596.json` (verbatim fields):
- `ticket`: **596**, `id`: `l07c-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07c/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0010454654693603516 s, `run`: **83.13703680038452 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout: `variant3d\.godot_queue\results\00000596_l07c-realmap\stdout.txt`
- stderr: `variant3d\.godot_queue\results\00000596_l07c-realmap\stderr.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07c\realmap.png` — **1,770,781 bytes**,
written 2026-11-25 15:44:48. Sidecar `realmap.png.raw.png` (1,770,781 bytes) also present.

Verbatim `python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07c/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\l07c\\realmap.png",
    "bytes": 1770781,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      90.427,
      86.435,
      38.911
    ],
    "mean_luma": 83.86,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000596_l07c-realmap\stderr.txt`:
```
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000596_l07c-realmap\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```
→ **SCRIPT ERROR count = 0**.

Verbatim capture diag from stdout (integrity proof):
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2863, 0.2392, 0.1098, 1.0) pcenter=(0.0588, 0.0549, 0.0706, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(144.5727, 58.0, -88.1103) target=(384.5727, 59.0703)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07c/realmap.png
```

Pinned-seed note: `--seed 20261113` is a user arg applied after config merge; the shipped
`config.json` also carries `random_seed: 20261113` and `camera.start_zoom: 0.3448276` (OBSERVED
from earlier reads in this session). Camera position differs slightly from the `g04/realmap`
baseline (`(144.5727, 58.0, -88.1103)` vs `(144.1104, 58.0, -88.57262)`) — **INFERRED:** normal
map-generation variance from the same seed; any cross-capture A/B attribution remains
**UNVERIFIED** until a second agent checks it with matched camera.

## 3. Final state and honesty statement

Final `status`: `now_serving=597`, `next_ticket=597`, `pending=0 []`, `godot.lock=free`. One new
unique `l07-` ticket consumed (596). No other gate was re-run.

- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- `stats` / luma numbers are qualitative integrity checks, not visual verdicts; G04 did not open
  the PNG for a C04/G21 R1–R6 read and did not run C01/T11 metrics. A second agent must do that.
- No threshold lowered, no test weakened, no assertion deleted, no source edit, no code/config/
  test/tool touched. No cross-touch by G04 of `hud.gd`/`main.gd`/`t_hud_layout.gd`.
- COORD's note is recorded: S02/P11 landed mid-batch, so a full re-gating after all writes settle
  is COORD's separate responsibility; this log covers only the single authorised capture.

## 4. Hand-off

**DONE.** The real-map capture is now available at `...\opencode\l07c\realmap.png` for G05/C04
visual review and C01 comparison against the `g04/realmap` contour-defect baseline. G04 stays
available for a follow-up; no further job has been submitted.

*End of L07c gate log — one job, PASS, donor parity UNVERIFIED.*
