---
owner: W5-5 (visual A/B worker)
date: 2026-11-24
scope: visual A/B residual for W3-3 building selection aura and W4-1/W4-2 startup zoom + wheel zoom
files_owned:
  - app/shots/w55_startup.png
  - app/shots/w55_selected.png
  - app/shots/w55_noselect.png
  - app/shots/w55_zoom_in.png
  - app/shots/w55_zoom_out.png
  - docs/coord_swarm_2026-11-24/reports/W55_visual_ab.md
mode: READ-ONLY on all code; windowed live-window captures via godot_runner.py + --test-api RPC
status: ZOOM/STARTUP VERIFIED; AURA UNVERIFIED (selected building off-screen)
runner_jobs: [1299, 1310, 1317, 1320]
---

# W5-5 — Visual A/B: selection aura + zoom (honest verdict)

## 0. Bottom line

The **zoom/startup half is closed visually**: a real windowed renderer produced
1280×720 frames whose measured camera scale goes 0.75 (wide default) → 2.90
(donor-derived max clamp) → 0.395 (approaching min 0.345) under real OS wheel
events, with a 245,740-pixel visible terrain change. The **aura half is NOT
closed**: although the HUD and RPC state confirm `selected = 1`, the selected
town hall was outside the captured viewport in every frame, so no aura or rally
flag pixel was ever measured. Aura verdict: **UNVERIFIED**, not PASS.

## 1. Capture route (why this and not headless)

- W3-3's caveat is correct and was re-confirmed: `--headless --script` jobs parse
  and instantiate `world.gd` but never call `_draw_buildings()` / `_draw_fx()`.
- `main.gd:1383-1394` makes any **headless `--screenshot`** an 800×600 CPU map
  render (`_render_headless_image`) — no world draw, no aura.
- A **windowed `--screenshot`** does draw the real viewport, but `main.gd:740-752`
  hides the HUD and skips the default building selection in screenshot mode, so
  it cannot produce the selected/aura state either.
- Therefore all captures used a **windowed game driven by the existing
  `--test-api` bridge** (`app/scripts/testbridge.gd:99,277-308`): its `shot`
  command saves `get_viewport().get_texture().get_image()` at 1280×720, i.e. the
  real GPU frame, so `_draw_buildings()` / `_draw_fx()` are exercised every frame.
  A temporary Python RPC client outside the repo drove `click`, `state`, `xform`,
  `shot`, `quit`. **No project code was edited; no Godot was launched directly.**

Config used: `shots/terrain_sample.json` (128×128 tiles, Mediterranean/hills,
AI off, seed 20261113) — chosen for speed under heavy shared-queue contention,
**not** the 320×320 default confrontation map. This limits beauty comparison.

## 2. Capture commands and runner jobs

All launches through `python app\tools\godot_runner.py run ...`; Godot never
invoked directly. Exact successful runner command (`w55-live-final`, the zoom
capture):

```
python app\tools\godot_runner.py run --id w55-live-final --timeout 700 --max-wait 3600 -- --path app -- --config shots/terrain_sample.json --seed 20261113 --test-api 8157 --timeout 660
```

| Job | Ticket | Runner result | What it produced / failure evidence |
|---|---|---|---|
| `w55-live-startup` | 1294 | no result JSON | My driver's connect budget expired during a 174 s queue wait; I killed the runner. No images used. |
| `w55-live-startup2` | 1299 | **ok**, wait 385.50 s, run 54.34 s | First windowed game. Captures INVALID: a concurrent W5-1 edit left `ai.gd:609/625` with parse errors (`uid2`, `food_budget` untyped inference), main.gd failed to compile, `frame=0`, sim frozen, world black. stderr retained those errors; frames later overwritten. |
| `w55-live-final` | 1310 | **ok**, wait 285.41 s, run 165.67 s | Valid frames. Startup `frame=475`, `time=4.22 s`, `blds0=1`, `selected=1`, `canvas_scale=0.749999940395355`, `draw_calls=51`. Wheel-in `canvas_scale=2.90000009536743`; wheel-out `0.394935518503189`. Produced `w55_startup.png`, `w55_zoom_in.png`, `w55_zoom_out.png`. |
| `w55-live-aura` | 1317 | **failed**, run 7.42 s | Environmental startup failure: stderr **empty**, stdout only the Godot 4.7.2 banner + `OpenGL API 3.3.0 ... NVIDIA GeForce MX130`. No captures. |
| `w55-live-aura2` | 1320 | **ok**, wait 0.00 s, run 84.23 s | Already serving when the coordinator ordered the retry stopped; it completed before it could be cancelled. `selected=1` at capture (`frame=502`), then `selected=0` (`frame=949`) at the same camera. Produced current `w55_selected.png` / `w55_noselect.png` — but the building is off-screen. |

RPC state excerpts (job 1310 / 1320, verbatim values): startup
`{"blds0":1,"selected":1,"time":4.21875,"unfin0":0,"units0":8,"units1":8}`;
selected-final `{"blds0":1,"selected":1,"time":3.96875}`;
deselected-final `{"blds0":1,"selected":0,"time":6.25}`.
All frames were `vp=[1280,720]`, mode RGBA, `world_dark_frac = 0.0` — real
renderer, not the 800×600 fallback.

## 3. Image paths and Pillow measurements (**MEASURED**)

Measurement: `python` 3.14 + Pillow; world region = x 250..1240, y 85..565
(excludes top bar, bottom panels, minimap). "Changed" = any RGB channel Δ ≥ 12.

| Image | Bytes | Size / mode | World mean RGB | World distinct colours | World luma levels | World dark fraction |
|---|---|---|---|---|---|---|
| `app/shots/w55_startup.png` | 949,510 | 1280×720 RGBA | [67.45, 73.28, 16.55] | 8,285 | 194 | 0.0000 |
| `app/shots/w55_selected.png` | 962,943 | 1280×720 RGBA | [67.61, 73.40, 16.51] | 7,766 | 192 | 0.0000 |
| `app/shots/w55_noselect.png` | 950,151 | 1280×720 RGBA | [67.14, 73.01, 16.23] | 6,870 | 80 | 0.0000 |
| `app/shots/w55_zoom_in.png` | 569,008 | 1280×720 RGBA | [68.54, 75.50, 17.12] | 2,485 | 64 | 0.0000 |
| `app/shots/w55_zoom_out.png` | 1,477,287 | 1280×720 RGBA | [67.73, 69.10, 21.57] | 34,494 | 148 | 0.0000 |
| Before-reference `app/shots/uidrive/04_game_hud.png` (2026-11-19, pre-W3-3) | 727,284 | 1280×720 RGBA | [69.8, 69.3, 29.3] | 41,571 | 246 | n/a |

Pairwise differences:

- **zoom_in vs zoom_out**: 245,740 changed pixels (26.66 %), mean abs RGB diff
  [5.778, 7.535, 5.46], bbox full frame. Zoom-out visibly reveals a large rock
  ravine and many more terrain tiles; zoom-in is a close grass crop (2,485 vs
  34,494 world colours). This is a real visual zoom, not a text-only diff.
- **selected vs noselect, same camera (job 1320)**: 24,639 changed pixels
  (2.67 %), centroid (437.4, 515.4) — dominated by the selection panel and HUD.
  Restricted to the world region only **1,832** changed pixels, bbox
  (250,110)–(810,138), centroid (632.7, 116.5), dominant colour **(255,230,127)**,
  which is the yellow "Rally: right-click the map…" hint text. **No player-tinted
  ellipse, ring, diamond, pip or rally-pennant cluster was measured.**
- **noselect vs zoom_in**: 99,915 changed pixels (10.84 %) — different camera
  states; not used as aura evidence.

## 4. Qualitative comparison against report expectations

- **Before (W3-3 report; confirmed by the 2026-11-19 frame)**: a thin white
  circular arc around the town hall with four amber dots; rally marker drawn for
  every own building with a `rally` key. The old frame shows exactly that circle
  near canvas (440, 390).
- **After (W3-3 expectation)**: squashed player-tinted ground-hugging ellipse,
  dark under-ring, tinted `ring_sel`, pulsing corner diamonds, site-progress arc,
  garrison pips; selected-gated rally flag with pole/pennant/finial. **Not
  observed in any capture** — the selected building was outside the viewport in
  jobs 1310 and 1320 (minimap blue start cluster at ~canvas (207, 523) while the
  camera viewport box sat at ~y 551–570, then ~y 690–710 after the minimap jump).
  A minimap click at (207, 525) moved the viewport box *down*, not onto the
  cluster — a framing/axis question for the owner (§7).
- **Zoom (W4-1 expectation)**: port before `DEFAULT_ZOOM = 2.0` instant step;
  after `camera.start_zoom = 0.75` wide start + `1.15²` target step with
  `exp(-18·dt)` smoothing. MEASURED start 0.75 is 2.67× wider than 2.0 and
  directionally matches the donor's max-distance start (`docreate.inc:82`,
  derived, not a literal). Donor instant wheel vs port smoothed wheel remains a
  deliberate owner-directed deviation, not a match claim.

## 5. Verdict table

| # | Visual item | Verdict | Evidence |
|---|---|---|---|
| 1 | Startup more zoomed-out than old 2.0 (W4-1) | **PASS** | MEASURED `canvas_scale=0.74999994` at `frame=475`, `blds0=1`, `selected=1`; `w55_startup.png` |
| 2 | Wheel events change camera zoom (W4-2) | **PASS** | Real OS wheel through test-api window; MEASURED 0.75 → 2.90 → 0.395; jobs 1310 |
| 3 | Zoom clamp bounds | **PASS** | MEASURED max 2.900000095 (donor-derived 58/20 = 2.9); 0.395 trending to min 0.345 |
| 4 | Zoom produces a visibly different world view | **PASS** | 245,740 changed px (26.66 %); `w55_zoom_in.png` / `w55_zoom_out.png` |
| 5 | Minimap viewport box present at new zoom levels | **PARTIAL** | Box visibly shrinks at 2.9 and grows at 0.395 in both zoom frames; click/drag accuracy not exercised |
| 6 | Zoom *smoothing/feel* between endpoints | **UNVERIFIED** | Only before/after frames captured; no per-frame trace. 17/17 UI test (job 1288) and camera smoke (1286/1287) are non-visual |
| 7 | Building selection aura visible (W3-3) | **UNVERIFIED** | `selected=1` confirmed by state/HUD, but building off-screen; world-region diff = 1,832 px of yellow HUD hint text only |
| 8 | Rally flag on selected building | **UNVERIFIED** | Same: "Rally set (601.0, 51.6)" in HUD only; no flag pixels measured |
| 9 | No stale rally flags after deselect | **UNVERIFIED** | `selected=0` confirmed, but world view has no building in frame |
| 10 | Donor visual equality of aura / flag | **UNVERIFIED** | No donor screenshot at matching seed/camera/zoom; donor glow is engine-side with private-use textures; qualitative shape only from W3-3 report |
| 11 | Capture validity (real renderer, non-blank) | **PASS** | 1280×720 RGBA, `world_dark_frac=0.0`, 6,870–34,494 world colours |

## 6. Honest limits

- All frames use the 128×128 diagnostic config, not the 320×320 default map;
  building density/framing and beauty are not comparable to donor confrontation
  shots.
- The live window was driven through the RPC bridge, not by a human at the
  keyboard; "feel" (how the smoothing looks during a wheel spin) is not
  inferable from endpoint stills.
- FOV/perspective and zoom-to-cursor anchoring were **not** verified: the cursor
  was parked at viewport centre for wheel injection, and no donor same-frame
  reference exists.
- Job 1299's frames were discarded because the shared tree was mid-edit
  (`ai.gd` parse errors); that was an environmental state, not a code claim by
  this worker.
- Job 1317's empty stderr + Godot banner is an unexplained startup failure
  under swarm contention; no conclusion about port visuals is drawn from it.
- Per supervisor instruction, no further runner jobs were submitted after the
  stop order; job 1320 was already in flight and finished before it could be
  cancelled.

## 7. Open questions for owner / human review

1. **Camera framing**: why did the selected town hall sit off-screen in the
   128×128 config (viewport box below the blue start cluster)? Is this a real
   W4-1 regression or a `view_scale`/timing artifact of the small config?
2. **Minimap jump axis**: clicking the blue cluster at (207, 525) moved the
   viewport box downward instead of centring on it — confirm `_minimap_world()`
   y mapping against a live window.
3. A clean aura A/B needs one more live capture with the building actually on
   screen (centre on the town hall, then `selected` / `deselected` at an
   identical camera), plus an unfinished site and a garrisoned tower.
4. W3-3's pulse-on-idle-camera redraw gate and always-on-rally-flag toggle
   remain open as documented in `W33_selection_aura.md`.
5. Donor exact start zoom and `gProfile.wheelspeed` default remain UNVERIFIED;
   the 0.75 start and 2.0 notch gain are derived/port choices, not donor literals.
