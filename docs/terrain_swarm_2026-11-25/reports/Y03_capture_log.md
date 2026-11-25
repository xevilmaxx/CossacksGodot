---
id: Y03-CAPTURE-LOG-01
title: "Y03 — fresh windowed real-map capture after detail-pass neutralisation: PASS"
ticket: Y03 (visual re-capture)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: PASS__NO_SOURCE_EDIT__NO_RERUN__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y03-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/L07c_gate_log.md
---

# Y03 — fresh real-map capture after Y03 detail-pass neutralisation

## 0. Authority and reason for this job

COORD authorised exactly one fresh visual re-capture after Y03's detail-pass neutralisation
(`game.gd` edited at 15:xx with backup `.bak-Y03`, OBSERVED from COORD's dispatch — G04 did not
inspect or edit that file). The purpose is a new frame for a second-agent visual review; G04 is
the sole runner-job owner (`WAVE_G_CHARTER.md:31`) and performs **no** visual verdict itself.

Labels: **OBSERVED** = direct file/command output; **DERIVED** = arithmetic/control-flow
consequence; **INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all,
donor parity — no donor GPU A/B frame exists).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=597`,
`next_ticket=597`, `pending=0 []`, `godot.lock=free` (counter aligned, queue quiet). Fresh artifact
dir created: `New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03"`.

Exact command submitted (repo root, Windows `python`, windowed — no `--headless`, and **no
`--dump-config`**, which `main.gd` documents as an early-exit mode):
```
python variant3d\tools\godot_runner.py run --id y03-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y03/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result (all acceptance conditions PASS)

Result JSON `variant3d\.godot_queue\results\00000597.json` (verbatim fields):
- `ticket`: **597**, `id`: `y03-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y03/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.0014903545379638672 s, `run`: **66.33086109161377 s**, `exit`: **0**,
  `timeout`: 700.0, `status`: **ok**
- stdout: `variant3d\.godot_queue\results\00000597_y03-realmap\stdout.txt`
- stderr: `variant3d\.godot_queue\results\00000597_y03-realmap\stderr.txt`

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03\realmap.png` — **1,385,801 bytes**,
written 2026-11-25 16:04:17. Sidecar `realmap.png.raw.png` (1,385,801 bytes) also present.

Verbatim `python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y03/realmap.png"`:
```
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y03\\realmap.png",
    "bytes": 1385801,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      83.499,
      80.066,
      32.11
    ],
    "mean_luma": 77.345,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Verbatim `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000597_y03-realmap\stderr.txt`:
```
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000597_y03-realmap\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```
→ **SCRIPT ERROR count = 0**.

Verbatim capture diag from stdout (integrity proof):
```
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.2549, 0.251, 0.0745, 1.0) pcenter=(0.3412, 0.298, 0.1882, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(145.2939, 58.0, -87.389) target=(385.2939, 59.7916)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y03/realmap.png
```

Pinned-seed note: `--seed 20261113` is a user arg applied after config merge. Camera position
differs slightly from the `g04`/`l07c` real-map frames (this job `(145.2939, 58.0, -87.389)` vs
`l07c` `(144.5727, 58.0, -88.1103)`), so any cross-capture A/B attribution is **UNVERIFIED**
until a second agent checks matched camera/zoom. G04 made no such claim.

## 3. Final state and honesty statement

Final `status`: `now_serving=598`, `next_ticket=598`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (597). No other gate was re-run.

- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- `stats` / luma numbers are qualitative integrity checks, not visual verdicts. G04 did **not**
  open the PNG for a C04/G21 R1–R6 read and did **not** run C01/T11 metrics — that is the
  second-agent visual review this hand-off enables.
- No threshold lowered, no test weakened, no assertion deleted, no source edit, no code/config/
  test/tool touched. No cross-touch of `hud.gd`/`main.gd`/`t_hud_layout.gd`/`game.gd` by G04.
- The frame reflects the tree *at capture time* (16:04), after Y03's 15:xx `game.gd` change;
  whether other writes landed during the run is **UNVERIFIED** by G04 and is COORD's concern.

## 4. Hand-off — DONE

**DONE.** The new frame is available at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03\realmap.png`
for the second-agent visual review (C04 protocol / G21 R1–R6) and any C01 comparison against the
`g04/realmap` contour-defect baseline. G04 stays available for a follow-up; no further job has
been submitted.

*End of Y03 capture log — one job, PASS, donor parity UNVERIFIED.*
