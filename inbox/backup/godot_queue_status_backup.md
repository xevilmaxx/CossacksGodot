# Snapshot — variant Godot queue status BEFORE CLEAN-01 acks

Captured: 2026-11-25 (session time), project root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.
Purpose: text snapshot of the variant runner's status **before any ack** was written by
CLEAN-01. No result JSON was modified at the time of this snapshot.

## 1. Verbatim: `python variant3d\tools\godot_runner.py status`

```text
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 398
next_ticket = 401
pending      = 3 [398, 399, 400]
godot.lock   = HELD (age 9.3s)
completed    = 397
max wait     = 503.08s   mean wait = 46.73s
max run      = 605.56s
statuses     = {'failed': 127, 'ok': 248, 'timed-out': 22}
```

Note: tickets 398/399/400 were still pending and the lock was held — current swarm
jobs, explicitly OUT OF SCOPE for CLEAN-01 (ticket < 312 only, never running/pending).

## 2. Verbatim: `python variant3d\tools\assert_clean.py --json`

```json
{
  "clean": true,
  "verdict": "CLEAN",
  "reasons": [],
  "checks": {
    "processes": {
      "clean": true,
      "count": 0,
      "details": []
    },
    "lock": {
      "clean": true,
      "exists": false,
      "state": "free",
      "age_sec": null,
      "max_age_sec": 300.0
    },
    "history": {
      "clean": true,
      "enabled": true,
      "total": 254,
      "acknowledged": 9,
      "failures": []
    }
  }
}
```

WARNING (观察者 finding, do not silently drop): `variant3d/tools/assert_clean.py:34`
sets `SPOOL = ROOT / "app" / ".godot_queue"`, so this tool checks the **2D app spool**
(254 jobs, 9 acks), NOT `variant3d/.godot_queue`. Its CLEAN output is NOT evidence of a
variant clean gate. `app/tools/assert_clean.py:34` has the same path.

## 3. Variant spool (`variant3d/.godot_queue/status.json`) pre-ack dump

Read directly (file read only). `history` = 398 entries.

| Metric | Value |
|---|---|
| `ok` | 249 |
| `failed` | 127 (all unacked) |
| `timed-out` | 22 (all unacked) |
| `error` / `skipped` | 0 / 0 |
| unacked failure-status (`timed-out`+`error`+`skipped`) | **22** |
| unacked `failed` | 127 |
| unacked non-ok total | 149 |
| unacked non-ok with **ticket < 312** (CLEAN-01 scope) | **100** (22 timed-out + 78 failed) |
| unacked non-ok with ticket >= 312 (out of scope) | 49 `failed`, 0 timed-out |
| acked entries | 0 |

### 3a. All 22 unacked `timed-out` entries (ticket, id, run/timeout s)

| Ticket | id | run s | timeout s | argv script/target |
|---:|---|---:|---:|---|
| 16 | v714-probe | 66.38 | 60 | temp `v714_probe.gd` |
| 17 | v735-fx3d | 65.51 | 60 | `res://tests/t_fx3d.gd` |
| 21 | v715-parse | 125.00 | 120 | temp `t_v715_parse_tmp.gd` |
| 29 | v735-fx3d-r2 | 63.96 | 60 | `res://tests/t_fx3d.gd` |
| 62 | v7-52-input-uitest | 182.06 | 180 | ui-test temp `v752_uitest_report.json` |
| 89 | v762-probe-before | 124.22 | 120 | `res://tests/v762_entity_feed_probe.gd` |
| 103 | v768-pick-probe-r2 | 122.67 | 120 | `res://tests/_v768_pick_probe.gd` |
| 105 | v765-probe | 122.54 | 120 | `res://tests/_v765_probe.gd` |
| 107 | v771-audio-probe | 182.27 | 180 | `res://tests/t_v771_audio_tmp.gd` |
| 167 | v777-zoom-anchor-probe | 122.07 | 120 | `res://tests/t_v777_zoom_anchor_probe.gd` |
| 178 | v778-auto-skin-probe | 122.67 | 120 | `res://tests/_v778_probe.gd` |
| 215 | v782-parse-terrain | 186.32 | 180 | `--check-only res://scripts/world3d_terrain.gd` |
| 218 | v782-parse-terrain-retry | 312.49 | 300 | `--check-only res://scripts/world3d_terrain.gd` |
| 221 | v782-parse-terrain-order | 161.56 | 150 | `res://scripts/world3d_terrain.gd --check-only` |
| 223 | v786-tileindex-shader-probe-v2 | 184.19 | 180 | `res://tests/_v786_shader_probe.gd` |
| 225 | v782-enum-probe | 124.70 | 120 | temp `v782_enum_probe.gd` |
| 227 | v782-parse-water-control | 127.09 | 120 | `--check-only res://scripts/water3d.gd` |
| 230 | v791-dual-mode | 605.56 | 600 | `res://tests/_v791_dual_mode_probe.gd` |
| 237 | v782-parse-terrain-r2 | 244.36 | 240 | `--check-only res://scripts/world3d_terrain.gd` |
| 260 | fixsel-before-probe | 123.90 | 120 | `res://tests/_fixsel_probe.gd` |
| 287 | fixterrain-probe-final | 302.57 | 300 | `res://scripts/t_fixterrain_probe.gd` |
| 292 | fixterrain-probe-shadow | 182.53 | 180 | `res://scripts/t_fixterrain_probe.gd` |

### 3b. Unacked `failed` with ticket < 312 (78 entries; excluded from the gate by D-13)

Ticket/id list (verbatim from status.json): 0 v70-baseline-selftest; 1 v70-import-bootstrap;
2 v70-baseline-selftest-r2; 3 v70-import-bootstrap-r2; 7 v732-camera3d; 8 v718-anim3d-check;
9 v734-entities3d; 10 v736-t-fog3d; 14 v711-camera-parse; 15 v733-t-pick3d;
18 v737-render-mode-seam-r1; 33 v735-fx3d-r3; 37 v735-fx3d-final; 40 v735-fx3d-missing;
43 v735-fx3d-missing2; 46/47/48 v714-entities-test{,,3}; 53 v750-baseline-render-mode;
56 v7-52-input-integration-parse; 69 v-launcher-config3d-selftest; 73 audit3d-shot-windowed;
81/84 v760-light-probe{,2}; 93 v769-check-self-base-before; 95 v768-pick-probe;
96 v766-jump-probe; 99 v766-t-camera3d; 106 v766-jump-probe2; 108 v770-shot-windowed;
119 v768-pick-probe-r4; 123 v770-shot-windowed-diag; 124 v768-pick-probe-dbg;
125 v762-probe-after2; 132 v770-shot-windowed-diag2; 139/142/146/156/159 v774-probe{,2,3,4,5};
150 v774-parse2; 160 v774-probe-final; 166 v770-journey3d; 168 v770-journey3d-long;
170 v777-zoom-anchor-probe-r2; 173 v770-journey3d-probe; 175 v770-journey2d-probe;
188/189 perf3d-sync-probe2/3; 194 v779-probe-before; 206 v781-probe-before;
219 v786-tileindex-shader-probe; 226/228/232 v786-tileindex-shader-probe-v3/v4/v5;
231/236 v790-probe{,2}; 233 v782-parse-terrain-final; 234 v782-selftest;
239/244 v791-dual-mode; 240 v790-uitest; 246 v792-parse-terrain;
248 v791-triple-mode; 249 v792-integration-probe; 264 fixterrain-probe;
266 fixsel-before-probe-r2; 267 fixselvis-probe; 269 fixterrain-after;
271 fixcolor-parse1; 275 fixterrain-depcheck; 296 play2fix-navbox-probe-before;
297 fixcolor-probe; 300 play2fix-navbox-probe-after; 301/302/306 smallmap-probe-64{,r2,r3};
309 millfix-probe.

### 3c. Out-of-scope current jobs

Pending tickets 398, 399, 400 (now_serving 398, next_ticket 401, lock held). No ack,
no delete, no reset performed on these or any ticket >= 312.
