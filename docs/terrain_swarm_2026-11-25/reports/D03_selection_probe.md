---
id: D03
title: "D03 — decisive windowed capture probe for the selection quad (proposal, not authored)"
owner: D03 (read-only analysis worker)
date: 2026-11-25
status: PROPOSAL__READ_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT__NO_PNG
scope: "Exactly one new file: docs/terrain_swarm_2026-11-25/reports/D03_selection_probe.md. No atom, .gd/.gdshader/config/fixture/result-JSON/PNG edit, no Godot launch, no runner job, no donor access."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION — internal visual evidence only. No donor GPU A/B frame exists; donor-parity stays UNVERIFIED (CHARTER §3, RECHECK_S1:10)."
---

# D03 — decisive windowed capture probe for the selection quad

## 0. Boundary and label key

This ticket **designs** a probe; it does not create or run it. Everything below is
a hand-off proposal for a later implementation ticket (suggested **D04**). No Godot
process, runner job, atom, fixture or artifact was created or modified by D03.

Labels: **observed** = read directly from a cited file/line; **derived** = arithmetic
or control-flow consequence; **inferred** = reasoned but not directly observed;
**UNVERIFIED** = cannot be established from available material.

---

## 1. Why this probe is needed (covers the owner's complaint)

- **OBSERVED** — CHARTER §1b.2: "Selection quad is still not OK. Re-audit the
  marquee/quad end-to-end (draw, geometry, lifetime, hit semantics)", and §1b.2
  also forbids copying the donor bug "box selection not working after you select a
  wall".
- **OBSERVED** — `t_select_rect.gd:524-539,595-613` asserts the overlay **node state**
  (`found`, `has_api`, `visible`, `Rect2` ≈ `Rect2(p0,p1).abs()` during drag,
  hidden/empty after release) but never asserts a **pixel**.
- **OBSERVED** — `S1_INPUT_FIX.md:222-224`: "No PNG/visual capture is asserted by
  this atom."
- **OBSERVED** — `RECHECK_S1.md:119-136,143,167`: six candidate PNG paths all
  `ABSENT`; image verdict `UNVERIFIED - NO PNG`; "S1 must not be announced as a
  visual PASS". The `--screenshot` path is only the menu-skip flag
  (`main.gd:206,230-244`), not an asserted capture.
- **DERIVED** — therefore the owner's complaint is still open on the **visual**
  half: no frame exists that shows whether the marquee is actually rasterised, in
  the right place, in the right colour, and gone after release. Logic-level
  23/23 + 20/20 (`S1_INPUT_FIX.md:156`, `CAM_RV_01_view_rect_runtime.md:151`)
  cannot close it.
- **UNVERIFIED** — donor brush rasterisation and native inside-box predicate
  (`SEL_01_implementation.md:98-106`); this probe is explicitly a PORT
  APPROXIMATION of the donor visual, not donor parity.

---

## 2. Sources read (all read-only)

| Source | Supply for this design |
|---|---|
| `docs/terrain_swarm_2026-11-25/CHARTER.md` §1b.2, §3, §5 | Owner requirement, one-Godot rule, no-weakening guard, result bar |
| `variant3d/tests/t_select_rect.gd:39-39,56,178-188,264-295,343-467,470-539,551-628` | Proven atom pattern: staged `_process`, real `Input.parse_input_event`, `_to_event_coord` stretch transform, drag thresholds, overlay probe, `SKIP_CAPTURE` branch |
| `docs/coord_swarm_2026-11-25/reports/S1_INPUT_FIX.md:43-107,141-166,193-226` | Windowed launch form, identity stretch `[1,1]`, camera-pose setup, no-PNG limitation |
| `docs/coord_swarm_2026-11-25/reports/RECHECK_S1.md:25-42,80-136,140-168` | No PNG at six paths; JSON/stdout is the only S1 surface; provenance overwrite caution |
| `docs/coord_swarm_2026-11-25/reports/CAM_RV_01_view_rect_runtime.md:88-94,145-172,199-210` | Windowed 1280×720 convention, `jump_to_world(half)`, zeroed edge/corner margins, headless input failure (job 373) |
| `docs/coord_swarm_2026-11-25/reports/SEL_01_implementation.md:40,54-63,84-96,98-106` | Marquee is `draw_rect(..., Color(1,1,0,1), false, 1.0, false)`, CONFIG-WIRE-SEL configurable, no fill/AA, PORT APPROXIMATION label |
| `variant3d/scripts/input_controller.gd:85-126,172-205,1340-1371` | `SelectionRectPainter` / `SelectionRectOverlay` live under `input_ctl`; `_process` refreshes it from `Rect2(drag_start,_drag_current).abs()` and hides it when not dragging |
| `variant3d/scripts/main.gd:1235-1253,1730-1732,1849-1930,2056-2066` | `Screenshot3DViewport` capture seam; root texture blank under gl_compatibility; saver quits after saving; `_write_bytes` helper |
| `variant3d/scripts/config.gd:425-439` + `variant3d/tests/fixtures/small_map_64.json:1-15` | Marquee colour/width defaults `[1,1,0,1]` / `1 px`; fixture does not override them |
| `variant3d/tools/smallmap_capture.py:21-58` | Read-only `stats` / `scan-stderr` inspectors for the acceptance steps |
| `variant3d/tools/godot_runner.py:25-33,384-437,488-509,615-652` | Single legal Godot door; `run`/`status` syntax; FIFO one-Godot lock; spool paths |

---

## 3. The two capture traps this design must avoid (critical)

1. **Trap A — capturing the wrong viewport.** `main.gd:1240-1253` reparents **only**
   `world` and `camera` into `Screenshot3DViewport`; `input_ctl` (and therefore its
   `SelectionRectOverlay`, `input_controller.gd:194-195`) stays in the main/root
   viewport. A verbatim `capture_view3d.get_texture().get_image()` — exactly what
   main's saver uses at `main.gd:1864-1880` — shows terrain and units but **no
   marquee**. That would be a false negative that could be misread as "quad still
   broken". **Fix:** in the proposed atom, reparent the **live** overlay node into
   `main.capture_view3d` during configure (harness-only, no game code edit):
   `var ov = _ictl.get("sel_rect_overlay"); ov.get_parent().remove_child(ov);
   _main.capture_view3d.add_child(ov)`. Both viewports are 1280×720
   (`main.gd:1244`, `CAM_RV_01:92`), so `layer = 10` and the overlay's pixel-space
   `Rect2` remain valid and draw on top of the 3D pass.
2. **Trap B — root-window texture under gl_compatibility.** `main.gd:1235-1238,
   1861-1863` records that the window backbuffer read blank, so the harness uses
   the SubViewport target. Do **not** substitute `root.get_texture().get_image()`
   as a shortcut; if a blank image is returned, fail loudly (`main.gd:1906-1913`
   precedent) — never present a blank/CPU-fallback frame as visual proof.
3. **Trap C — main's saver cannot be reused mid-drag.** `main.gd:1730-1732` fires
   the saver on a frame counter and `main.gd:1930` calls `_quit(0)`. The atom must
   keep `screenshot_frames = 1000000` / `screenshot_done = true`
   (`t_select_rect.gd:363-364`) and do its own `get_image()` + `save_png()`.
4. **Trap D — headless `SKIP_CAPTURE`.** See §6.

---

## 4. Proposed atom (NOT created) — `variant3d/tests/t_select_rect_capture.gd`

**Proposal only.** Suggested owner: D04. New file in the repo's test tree so it can
be loaded as `res://tests/t_select_rect_capture.gd`; built by copying the proven
`t_select_rect.gd` skeleton and adding the capture stages. **Do not modify**
`t_select_rect.gd`, `input_controller.gd`, any fixture, config or result JSON.
Reuse the existing 24 `check()` sites byte-for-byte and append new checks — no
threshold, expectation, marker or verdict rule may be weakened (CHARTER §3).

### 4.1 Boot and harness (verbatim S1_INPUT_FIX / CAM-RV-01 pattern)

1. `extends SceneTree`; dynamic `load()` of `res://scripts/data.gd`,
   `res://scenes/main.tscn`; all work in staged `_process()`; `call_deferred("quit",
   0/1)` only — never `quit()` from `_initialize()`.
2. Require user args `--config <abs small_map_64.json>` and `--screenshot
   <temp>\d03_selquad_menu_skip.png`; `--screenshot` is the menu-skip flag only.
3. **Windowed guard:** if `DisplayServer.get_name() == "headless"`, write
   `passed=false`, `capture_path="SKIP_CAPTURE ..."`, quit 1 (same as
   `t_select_rect.gd:272-275`). Record `run_mode`, `root_viewport_px`,
   `projection_viewport_px`, `event_coord_scale`; require both viewports
   `[1280,720]` and scale `[1,1]` — otherwise abort, do not "fix" coordinates.
4. `_main = packed.instantiate(); root.add_child(_main)`; `_game/_cam/_world/_hud/
   _ictl` from main's properties; assert `render_mode == "3d"`, `MAP 64×64`.
5. `_hud.visible = true`; `screenshot_frames = 1000000`, `screenshot_done = true`,
   clear `_main.ais`, `speed = 0.0`; `camera.jump_to_world(half)` where
   `half = Vector2(64,64)` m; `edge_margin = corner_margin = 0.0`.
6. **Reparent overlay into the capture target** (Trap A fix) and verify
   `ov.get_parent() == _main.capture_view3d`.
7. `_cam.world_to_px()` cross-check and all original projection/threshold checks
   retained (`t_select_rect.gd:428-467`).

### 4.2 Scene content — 4 units + 1 building, all in view

Clear generated entities as in `t_select_rect.gd:298-311`; `next_id = 10`; spawn
through the real `_game.spawn()`:

| id | sid | SIM pos (m) | Offset from half `(64,64)` | Relation to drag box |
|---:|---|---|---|---|
| 10 | peasant | `(58,62)` | `(-6,-2)` | inside |
| 11 | peasant | `(68,68)` | `(+4,+4)` | inside |
| 12 | peasant | `(74,55)` | `(+10,-9)` | outside (y beyond +8) |
| 13 | peasant | `(54,73)` | `(-10,+9)` | outside (y beyond +8) |
| 14 | `cen` building | `(64,64)` | `(0,0)` | inside box, **excluded by kind** |

Drag box = `half + (-12,-8)` → `half + (12,8)`, the proven in-view box from
job 414 (`S1_INPUT_FIX.md:184-186`: `p0≈(395,274)`, `p1≈(917,458)`).
**DERIVED:** from CAM-RV-01's measured view rectangle at this pose (SIM x
24.96…103.04, y 22.56…89.23, `CAM_RV_01:99-108`), all five entities are inside
the viewport. Assert that with `projected_pixels_in_viewport`-style checks on all
five projected positions before any event is sent. The player-0 building inside
the rect is the deliberate **anti-donor-bug** control: units must still be
selected; we do not reproduce "box select fails after selecting a wall".

### 4.3 Real drag and three captures

Use `_send_mouse_button` / `_send_mouse_motion` from `t_select_rect.gd:470-488`
(`Input.parse_input_event`, `_to_event_coord` stretch transform, left mask).

Stages (2 frames per stage, as in `t_select_rect.gd:578-628`):

| Stage | Action | Artifact |
|---:|---|---|
| 0 | boot + configure + reparent overlay + spawn | — |
| 1 | capture **BASELINE** with empty overlay | `d03_selquad_before.png` |
| 2 | press at `p0` | — |
| 3 | motion to `p1` with left mask; assert `drag_start`, `world.sel_active`, overlay rect | — |
| 4 | wait 2 frames so `_process` + `queue_redraw()` land; capture **DURING drag** while LMB still held | `d03_selquad_during.png` |
| 5 | release at `p1`; wait 2 frames; capture **AFTER release** | `d03_selquad_after.png` |
| 6 | assert selection semantics + short-click regression, write result JSON, quit | `t_select_rect_capture.json` |

Capture helper (one function, called at stages 1/4/5):

```gdscript
func _capture(path: String) -> Dictionary:
    var vp = _main.capture_view3d
    vp.render_target_update_mode = SubViewport.UPDATE_ONCE
    await RenderingServer.frame_post_draw
    await RenderingServer.frame_post_draw
    var img: Image = vp.get_texture().get_image()
    if img == null or img.is_empty():
        return {"ok": false, "path": path, "reason": "null/empty image (root-texture trap)"}
    var w := img.get_width(); var h := img.get_height()
    if w != 1280 or h != 720 or img.get_pixel(0, 0).a < 0.5:
        return {"ok": false, "path": path, "reason": "wrong size / blank frame"}
    var written: String = _main._write_bytes(path, img)   # main.gd:2056-2066
    return {"ok": written != "", "path": written, "w": w, "h": h,
            "p00": img.get_pixel(0, 0).to_string(),
            "center": img.get_pixel(w / 2, h / 2).to_string()}
```

Write PNGs to a **unique Temp folder**, e.g.
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\d03_selquad\`
(`before|during|after.png`). Never reuse an S1 filename — `RECHECK_S1.md:121-130`
shows six same-name candidates were overwritten/lost.

### 4.4 Pixel assertions (the decisive part)

Sample the captured `Image` in Godot and also re-check offline with
`smallmap_capture.py stats` (§7). Let `expected := Rect2(_p0,_p1).abs()`; sample:

- four edge midpoints: `(round((p0.x+p1.x)/2), round(min(p0.y,p1.y)))`, etc.;
- all four corners;
- rect **centre** (must stay non-yellow — no fill, `SEL_01_implementation.md:58,88`).

For each sample point `q`, read `during.get_pixel(q.x,q.y)`. Define
`is_marquee(c) := c.r >= 0.85 and c.g >= 0.85 and c.b <= 0.25 and c.a >= 0.9`
(default `[1,1,0,1]`; read the actual expected colour from
`ConfigScript.active.feature_selection_marquee_color()` and width from
`..._width_px()`, record both in JSON, and assert the default if no override).

New checks (append, do not replace):

| Check name | Predicate |
|---|---|
| `capture_before_ok` / `capture_during_ok` / `capture_after_ok` | PNG written, 1280×720, non-blank |
| `quad_visible_during_pixels` | ≥3 of 4 edge midpoints **and** ≥2 of 4 corners `is_marquee` in DURING |
| `quad_position_pixels` | each yellow sample lies within `expected.grow(2)`; no yellow sample outside `expected.grow(width+2)` along the scanned rows |
| `quad_no_fill_pixels` | rect centre **not** `is_marquee` in DURING, and matches BASELINE within 8/255 per channel |
| `quad_colour_pixels` | yellow samples match the configured RGBA within 16/255 per channel; recorded `marquee_color` equals `[1,1,0,1]` unless config override declared |
| `quad_hidden_after_pixels` | the DURING yellow sample coordinates are **not** `is_marquee` in AFTER and match BASELINE within 8/255 per channel |
| `overlay_rect_matches_pixels` | `ov.get_selection_rect().is_equal_approx(expected)` during drag, `visible == true`; after release `visible == false` and no area — cross-check logic vs raster |
| `entity_state` (existing, retained) | selected `[10,11]`; ids 12/13 and building 14 not selected; building geometrically inside ground rect; `cmd_*` spy counter 0 |

All three PNG paths and the sampled coordinates/colours go into the result JSON
(`variant3d/tests/results/t_select_rect_capture.json`) so a second agent can
reproduce the pixel reading without rerunning Godot.

---

## 5. Exact runner command (copy-pasteable, Windows `python`, PowerShell)

**Before submitting** — one-Godot rule (CHARTER §3; `godot_runner.py:25-33,384-437,488-509`):

```powershell
python variant3d\tools\godot_runner.py status
```

Proceed only if `godot.lock = free` and `pending = 0` (or you are willing to wait
in the FIFO). Never launch `godot` directly; never submit two jobs; do not use
`doctor`/`reset` while another agent's job is live.

Set paths (unique id, unique screenshot name):

```powershell
$ROOT = "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
$TEMP = "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\d03_selquad"
New-Item -ItemType Directory -Force -Path $TEMP | Out-Null
```

Submit the **windowed** probe (note: no `--headless`; first `--` is consumed by
the runner, second separates Godot engine args from user args):

```powershell
python variant3d\tools\godot_runner.py run --id d03-selquad-cap1 --timeout 300 -- `
  --path variant3d --script res://tests/t_select_rect_capture.gd -- `
  --config "$ROOT\variant3d\tests\fixtures\small_map_64.json" `
  --screenshot "$TEMP\d03_selquad_menu_skip.png"
```

Use a **new id** for every attempt (`d03-selquad-cap1`, `-cap2`, …) so result
envelopes are never confused (`RECHECK_S1.md:149-158`). Expected envelope:
`variant3d\.godot_queue\results\000NNNNN.json` plus
`000NNNNN_d03-selquad-cap1\stdout.txt` / `stderr.txt`.

---

## 6. Avoiding the headless `SKIP_CAPTURE` trap

- **OBSERVED** — `t_select_rect.gd:272-275`: headless → `_run_mode =
  "headless_skip"`, `_abort("SKIP_CAPTURE ... No fake PASS.")`, `passed=false`,
  exit 1. `S1_INPUT_FIX.md:63-76` and `CAM_RV_01:159-166` explain why: headless
  root viewport is 64×64 while projection is 1280×720, so
  `Input.parse_input_event` never reaches `_unhandled_input`.
- **OBSERVED** — `RECHECK_S1.md:84-89` reads windowed + no-`--headless` as a
  capture-integrity prerequisite.
- **Therefore:** (a) the command in §5 has **no** `--headless`; (b) the atom's own
  guard must reject headless and write a literal `SKIP_CAPTURE` string, never a
  fake PASS; (c) accept the run only when result JSON says
  `run_mode = "windowed_real_input"`, `measured.headless = false`,
  `event_coord_scale = [1,1]`, and all three PNGs exist; (d) if any PNG is
  missing/blank, verdict is `UNVERIFIED`, not PASS — do not manufacture a visual
  PASS from JSON alone (the exact mistake `RECHECK_S1.md:42,136` guards against).

---

## 7. Copy-pasteable verification steps (after the run, still read-only)

```powershell
# 1) envelope: expect status "ok", exit 0, and NO --headless in argv
Get-Content "$ROOT\variant3d\.godot_queue\results\000NNNNN.json"

# 2) stdout: expect D03_SELQUAD RESULT: PASS N/N and three PNG paths
Get-Content "$ROOT\variant3d\.godot_queue\results\000NNNNN_d03-selquad-cap1\stdout.txt"

# 3) stderr: expect script_error_lines 0
python variant3d\tools\smallmap_capture.py scan-stderr "$ROOT\variant3d\.godot_queue\results\000NNNNN_d03-selquad-cap1\stderr.txt"

# 4) image sanity: expect 1280x720, non_black_fraction > 0.5,
#    full_width_dark_rows 0, mean_luma > 10 for all three
python variant3d\tools\smallmap_capture.py stats `
  "$TEMP\d03_selquad_before.png" "$TEMP\d03_selquad_during.png" `
  "$TEMP\d03_selquad_after.png"

# 5) human read: open DURING and AFTER side by side; a thin yellow rectangle
#    must be present in DURING and absent in AFTER
```

`stats` is qualitative only (`smallmap_capture.py:42-48`); the authoritative
colour/position verdict is the in-atom pixel assertion of §4.4.

---

## 8. Exact acceptance criteria

| # | Criterion | Evidence required | Verdict rule |
|---:|---|---|---|
| 1 | Runner envelope `status=ok`, `exit=0`, `argv` has no `--headless` | `000NNNNN.json` | mandatory |
| 2 | `SCRIPT ERROR` count 0 | `scan-stderr` output | mandatory |
| 3 | `run_mode=windowed_real_input`, `headless=false`, both viewports `[1280,720]`, `event_coord_scale=[1,1]`, overlay reparented into `capture_view3d` | result JSON | mandatory |
| 4 | Exactly 5 entities `[10,11,12,13,14]`; ids 10–13 units, 14 building; all projected inside viewport | result JSON + stdout | mandatory |
| 5 | Real drag: event-sourced `drag_start == p0`; crosses 6 px and 0.005 m thresholds | JSON (retained checks) | mandatory |
| 6 | Three PNGs exist, are 1280×720 and non-blank | `stats` + JSON capture records | mandatory; missing → `UNVERIFIED`, never PASS |
| 7 | **Visible:** ≥3/4 edge midpoints and ≥2/4 corners yellow in DURING, inside `expected.grow(2)` | DURING PNG pixel samples | decisive |
| 8 | **Position/colour:** yellow samples match configured RGBA (`[1,1,0,1]` default) within 16/255; width 1 px; no stray yellow outside rect | DURING PNG + config record | decisive |
| 9 | **No fill:** rect centre equals BASELINE within 8/255 and is not yellow | DURING vs BASELINE | decisive |
| 10 | **Hidden:** all DURING yellow sample coordinates equal BASELINE within 8/255 in AFTER; `overlay.visible=false`, no area; `world.sel_active=false` | AFTER PNG + JSON | decisive |
| 11 | Selected `[10,11]`; 12/13/14 not selected; building 14 is geometrically inside the ground rect but excluded by kind; `cmd_*` count 0 | JSON (retained checks) | mandatory — proves the donor wall bug was **not** copied |
| 12 | Existing checks not weakened: `check()` count, thresholds 6.0/0.005, all `expected_pre_fix_failure` markers unchanged | source diff vs `t_select_rect.gd` | mandatory |
| 13 | No assertion is a donor-parity claim; verdict labelled PORT APPROXIMATION / internal consistency | report + JSON label | mandatory |

**Overall PASS** = all 1–13 satisfied. If 7–10 cannot be satisfied because no PNG
was produced, the honest verdict is `UNVERIFIED (NO PNG)` — exactly the state this
probe exists to eliminate, not to restate.

---

## 9. Status, ownership and open questions

- **No atom was authored, no runner job submitted, no Godot launched, no file
  other than this report written by D03.** The atom in §4 is a proposal for D04.
- **OBSERVED open risk:** reparenting the live overlay into `capture_view3d` is a
  harness-only node-tree change; if it changes input routing (CanvasLayer has no
  `mouse_filter`, so **inferred** low risk), the atom must still verify
  `drag_start_from_real_event` and fall back to capturing the overlay in a
  transparent SubViewport copy rather than weakening any predicate.
- **UNVERIFIED:** whether `capture_view3d` composites the CanvasLayer exactly as
  the window does; §8 item 7 is the test of that, not an assumption.
- **UNVERIFIED:** donor parity / native brush rasterisation — no donor GPU frame
  exists under this charter.
- **COORD decision needed:** whether to author D04 with the new atom or instead
  append capture stages to `t_select_rect.gd` (higher regression risk because that
  file is the shared 23/23 gate driver; not recommended).

*End of D03.*
