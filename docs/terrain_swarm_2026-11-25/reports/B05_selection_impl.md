---
id: B05
title: "B05 — selection quad implementation: Rect2 size root-cause, stuck-quad teardown, D04 geometry/mapping, D05 click UX"
area: terrain-swarm Wave B — exclusive implementation owner of variant3d/scripts/input_controller.gd
owner: B05 (implementation subagent)
date: 2026-11-25
status: IMPLEMENTED__NO_RUNNER_JOB__ONE_FILE_EDITED
scope: "Exactly two repo files touched: variant3d/scripts/input_controller.gd (the only game file edited) and this report. Backup outside the repo tree: inbox/backup/input_controller.gd.bak-B05. No picking3d.gd / world3d.gd / hud.gd / camera3d.gd / config.gd / test / fixture / PNG / gate / git edit. No Godot process or runner job submitted."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
input_reports:
  - docs/terrain_swarm_2026-11-25/reports/D01_selection_quad_audit.md
  - docs/terrain_swarm_2026-11-25/reports/D02_selection_quad_donor.md
  - docs/terrain_swarm_2026-11-25/reports/D03_selection_probe.md
  - docs/terrain_swarm_2026-11-25/reports/D04_selection_projection.md
  - docs/terrain_swarm_2026-11-25/reports/D05_selection_ui.md
  - docs/terrain_swarm_2026-11-25/reports/F03_selection_online.md
labels: [OBSERVED, DERIVED, DONOR_CITED, PORT_APPROXIMATION, UNVERIFIED]
parity_guard: "All donor numbers below are byte-level donor recon (DSEL-01/02, RV-SEL-01) or fetched online text (F03). The native inside-box predicate, FOV constant, ArcTan semantics and brush rasterisation remain UNVERIFIED. No donor GPU A/B frame exists; every port substitute is labelled PORT APPROXIMATION. No donor-parity claim is made."
---

# B05 — selection quad implementation report

## 0. Backup / provenance (governance: backup first)

**OBSERVED** — `Copy-Item variant3d\scripts\input_controller.gd
inbox\backup\input_controller.gd.bak-B05` was executed **before** the first edit.
SHA-256 of both ends matched at copy time:

- `SRC = D78AFF5205DD0F350661C31AF41E65256D13987C6C90E8341E25A02A30011020`
- `BAK = D78AFF5205DD0F350661C31AF41E65256D13987C6C90E8341E25A02A30011020`
- `match = True`
- After edits: `current = 7D8732C423D21BDE39B40D1CC6F589ACD60ABC5ADB742B81B0CF58B60F4D2426`

`git diff --stat -- variant3d/scripts/input_controller.gd`:
`1 file changed, 216 insertions(+), 50 deletions(-)` (backup 1473 lines → current 1639;
the bulk of the growth is citation/comment text).

---

## 1. Defect analysis — the concrete remaining defects, ranked

### 1.1 ROOT CAUSE (D01) — `Rect2(position, END_PIXEL)` size bug — FIXED

**OBSERVED** — old `input_controller.gd:1369`:

```gdscript
_show_selection_rect(Rect2(drag_start, cur).abs())
```

Godot's `Rect2(position, size)` takes the **second argument as a size**, not as the
opposite corner. With the proven drag `p0=(395,274)`, `p1=(917,458)`
(`S1_INPUT_FIX.md`, D01 §root cause) this built `P=(395,274) S=(917,458)`, i.e. an
end point of `(1312,732)` — **outside a 1280×720 viewport**. The correct rect is
`P=(395,274) S=(522,184)`, ending exactly at the cursor. This is the owner's
"quad looks wrong/oversized/offset" symptom: the outline is drawn from the press
pixel toward `press + release`, so it detaches from the cursor and grows with the
absolute cursor position.

**FIX applied** (now `:1527`):

```gdscript
var pixel_rect := Rect2(drag_start, _drag_cur_px - drag_start).abs()
_show_selection_rect(pixel_rect)
```

The `.abs()` is retained from the old call so reverse drags normalise the same way.

### 1.2 Stuck quad (D01) — minimap release bypasses all drag teardown — FIXED

**OBSERVED** — old `:678-681` (now `:777-785`): an LMB press **or release** whose
position lies in `_minimap_screen_rect()` takes
`_mm_dragging = mb.pressed; _minimap_reposition(); return`. A world drag released
over the minimap therefore returned before the cleanup at old `:687-695`; the
`_mm_dragging` cleanup itself only covered the opposite case (drag started on the
minimap). With `drag_start`/`dragging` still set, `_process` kept repainting the
yellow box forever.

**FIX applied** — one `_cancel_drag()` helper (`:234-240`) clears `drag_start`,
`dragging`, `_sel_ground_start`, `_rect_ground_anchor`, `_drag_current` and hides the
overlay. It is now called from **every** teardown path:

1. minimap LMB release early return (`:782-783`) — the D01 root cause;
2. minimap `_mm_dragging` release (`:795`);
3. normal LMB-up finalization (`:940`);
4. motion that carries an active drag onto the minimap (`:955`);
5. build ghost armed mid-drag (`:967`).

### 1.3 Missing event→camera pixel map and canvas inverse (D04 §Q2/Q3) — FIXED

**OBSERVED** — before this ticket, raw `InputEvent` pixels went verbatim into
`picking3d.ground_point()` (`project_ray_*`) and into `draw_rect()`. They coincide
only at the proven 1280×720 windowed case, which is why the green atoms never saw
the defect. At a `canvas_items`/`expand` window of another size (or with the
screenshot `SubViewport`) the quad is offset/skewed/missed.

**FIX applied** — `_event_px_to_cam_px()` (`:595-610`) maps event pixels into the
Camera3D's projection viewport using **live** `get_viewport().size` and
`camera.get_viewport().size` (identity when equal, no baked 1280 ratio).
`_screen_to_world()` now feeds the mapped pixel to `ground_point()` and records it
in `_pick_screen` so `picking.pick()/pick_res()` consume the same space.
`_show_selection_rect()` (`:205-222`) inverts the live canvas transform
(`get_canvas_transform().affine_inverse()`), exactly as the 2D
`_screen_to_world()` already does, before handing the rect to the painter.

### 1.4 Re-unprojected anchor / mirror drift (D04 §Q4 hunks 1/3/5/6/7) — FIXED

**OBSERVED** — the old code re-unprojected `drag_start` on every frame in
`_drag_world_rect()` and used `get_viewport().get_mouse_position()` for the mirror
but `_drag_current` for the outline; a camera pan/zoom mid-drag slid the world rect
away from the box and the two representations disagreed.

**FIX applied** — `_rect_ground_anchor` is captured **once on LMB press**
(`:838-841`), passed into `_drag_world_rect(a,b,anchor)` on release (`:852`) and in
the `_process` mirror (`:1504`), and reused as the epsilon reference (`:984`).
`_process` now computes one `_drag_cur_px` and one `_drag_rect_sim` and drives the
mirror, the yellow outline and the live selection from them.

### 1.5 Two-phase drag start, wall-build gate, live selection (D02/F03) — FIXED

**OBSERVED** — donor starts the frame on the **first LMB-held MOVE**
(`onmousemove.inc:142-147`) and suppresses it in wall/build mode
(`onmousemove.inc:140`, D02 item 34); the box updates the selected set while held
(F03 Finding 2 / almanac). The port already used `_sel_ground_start` for the
first-move epsilon reference; the geometric anchor was the press point.

**FIX applied** — the epsilon reference remains the first-move ground point
(`_sel_ground_start`), with the frozen press anchor as the first-sample partner;
an active drag is cancelled if a build ghost is armed mid-gesture (`:958-967`).
One `_apply_rect_selection()` path (`:652-686`) is shared by the live per-frame
update (3D only) and LMB-up, with an id-set dedupe guard so the selection cue is
not replayed every frame when the boxed set is unchanged.

### 1.6 Click UX (D05 P1/P2, low-risk items only) — FIXED

**FIX applied** in the click branch (`:875-930`):

- Ctrl+click on an already-selected object removes it; Ctrl+click on a new own unit
  selects all of that type (`onmousedown.inc:281-344`; D05 #1/#2).
- Shift+click on empty ground **keeps** the selection instead of clearing it
  (`onmousedown.inc:346-355`; D05 #3).
- Shift+double-click unions same-type units with the prior selection instead of
  replacing it (`onshortcut.inc:135`; D05 #4).

**Deliberately NOT changed (reported, not forced):** D05 #5 hover cursor HUD hit
test and #6 the top-strip `MOUSE_FILTER_IGNORE` decision — the latter is explicitly
an **owner decision**, not a defect fix. D05 #7 empty/building-only selection sounds
were left as-is: COORD states sound wiring is already fixed and D05 itself marks the
edge cases OPEN/decision.

---

## 2. Exact diff (current file vs `inbox/backup/input_controller.gd.bak-B05`)

All line numbers below are **current** (post-edit) line numbers.

### 2.1 `var _rect_ground_anchor` (`:35-42`)
New frozen SIM-ground anchor state; comment cites donor `onmousemove.inc:145-146`
and labels the press-point anchor a **PORT APPROXIMATION** of the donor first-move
point (DSEL-01 claim 3).

### 2.2 `_show_selection_rect()` canvas inverse (`:205-222`)
```gdscript
var canvas_r := r
var vp := get_viewport()
if vp != null:
    var xf: Transform2D = vp.get_canvas_transform().affine_inverse()
    canvas_r = Rect2(xf * r.position, xf.basis_xform(r.size))
sel_rect_overlay.call("set_selection_rect", canvas_r)
```
Identity at 1280×720. (Note recorded in code: the shared test enshrines the old
wrong `Rect2` expectation — see §4.)

### 2.3 `_cancel_drag()` helper (`:229-240`)
Single teardown for all five exit paths listed in §1.2.

### 2.4 `_event_px_to_cam_px()` and `_screen_to_world()` (`:595-626`)
New helper maps event→camera viewport pixels with live sizes; `_screen_to_world()`
sets `_pick_screen` to the mapped pixel and calls
`picking.ground_point(cam_px)`. The 2D inverse branch is byte-identical.

### 2.5 `_drag_world_rect(a, b, anchor_ground = INF)` (`:634-648`)
Third optional arg reuses the frozen anchor; default keeps every 2-arg call valid.

### 2.6 `_apply_rect_selection(rect)` (`:650-686`)
Shared live/release apply. Entity filter (`dead`/`player==0`/`kind=="unit"`),
Shift `spmAdd` union by id and `_set_selection(arr)` are copied verbatim from the
old release branch; only a set-equality early-out is added.

### 2.7 `_unhandled_input()` (`:777-987`)
Minimap release calls `_cancel_drag()`; normal release calls `_cancel_drag()`;
motion entering minimap and build-ghost-mid-drag call `_cancel_drag()`; LMB press
captures `_rect_ground_anchor = _screen_to_world(mb.position)`; release uses
`_drag_world_rect(drag_start, mb.position, _rect_ground_anchor)` + `_apply_rect_selection`;
epsilon reference uses the frozen anchor for the first sample; click branch gains
the Ctrl / Shift-empty / Shift-double-click semantics of §1.6.

### 2.8 `_process()` (`:1492-1535`)
One `_drag_cur_px` and one `_drag_rect_sim` drive: `world.sel_rect`/`sel_active`,
the yellow outline via **`Rect2(drag_start, cur - start).abs()`**, and (3D only)
the live `_apply_rect_selection`.

### 2.9 Explicitly UNCHANGED
Painter/overlay classes (`:85-132`) — yellow `RGBA(1,1,0,1)`, 1 px, solid, no
fill, no AA, config-wired; `bind_3d()`/`_ensure_selection_rect_overlay()`;
`_set_selection()` audio; `_pick()`/`_pick_res()`; all `game.cmd_*` call sites;
hotkeys/control groups; double-click `0.5 s` window; all four-corner ground AABB
math; `world.sel_rect` mirror semantics; every `expected_pre_fix_failure` marker
and test file.

---

## 3. Donor citations and PORT APPROXIMATION labels

| Implemented item | Donor evidence | Label |
|---|---|---|
| Opaque yellow 1 px solid outline, no fill | `brushes\selection.cfg:3-14` (`Red=1,Green=1,Blue=0,Alpha=1`, `LineWidth=1`, `LinePattern=65535`, `AntiAliased=False`), bound at `resource.lib:47`; RV-SEL-01 §Visual; D02 items 17-20 | **DONOR_CITED** (unchanged by B05); live rasterisation **UNVERIFIED** |
| Drag starts on first LMB-held MOVE (two-phase) | `onmousemove.inc:142-147` @`0x007957..0x008171`; D02 item 3; RV-SEL-01 Conflict 1 | **DONOR_CITED**; geometric anchor at press instead of first move = **PORT APPROXIMATION** |
| Axis-wise world-ground epsilon 0.005 m / 0.25 m attack/guard | `onmousemove.inc:32-34,152`; D02 items 5-7 | **DONOR_CITED** (existing helpers untouched) |
| Shift → `spmAdd`, no Ctrl-remove in drag | `onmousemove.inc:156-162`, `//spmRemove` at `:159-161`; D02 item 10/22 | **DONOR_CITED** |
| LMB-up finalize / teardown | `onmousedown.inc:364-390`; D02 item 11 | **DONOR_CITED** |
| Box updates live while held | F03 Finding 2 (almanac `spmFrame` paraphrase, **UNVERIFIED**); byte enum has no `spmFrame` (RV-SEL-01) | **PORT APPROXIMATION** of live update; byte mode strings unchanged |
| Wall/build mode suppresses marquee | `onmousemove.inc:140`; D02 item 34 | **DONOR_CITED** |
| Ctrl+click same-type / remove; Shift+empty no deselect; Shift+double-click union | `onmousedown.inc:281-344,346-355`; `onshortcut.inc:135`; Gamepressure/F03 §3b | **DONOR_CITED** |
| World-ground 4-corner AABB, frozen anchor, event→cam and canvas maps | donor rect is native/world-space (`onmousemove.inc:66-69,135-167`); exact predicate **UNVERIFIED** (EXE `GetGameObjectSelectionSizeByHandle @0x240a3a`, no script caller) | **PORT APPROXIMATION** throughout |
| Event→projection mapping / FOV / `ArcTan` | donor `GetCameraFieldOfViewByFocalLength` exists; numeric FOV and native map **UNVERIFIED** (DSEL-02 claim 2, D04 §9 q1) | **PORT APPROXIMATION** (live viewport ratios, no invented constant) |
| Camera-follows-drag / edge-scroll ("map moves with you") | official Steam 2016-11 announcement RU/UA text; F03 Finding 1/G1; mechanism/mechanics **UNVERIFIED** | **NOT IMPLEMENTED** — outside this file's grant; recorded as follow-up (§5) |
| Donor wall bug "box select fails after selecting a wall" | WGB review; F03 Finding 5; charter §1b.2 | **NOT COPIED** — drag rebuilds `arr` from scratch; building/wall exclusion by `kind` preserved |

---

## 4. Regression list / verification status

### 4.1 What this builder did NOT run
Per ticket and charter §3, **no Godot process, runner job, PNG, gate submission or
test edit** was made. All claims below are static derivations or prior-report
observations; no new PASS verdict is claimed.

### 4.2 Expected to remain green (static derivation from the 23/23 drag atom)
`boot_real_64_3d_game`, `hud_visible`, `test_entities_exact`, `cmd_spy_installed`,
`picking3d_bound`, `projected_pixels_in_viewport`, `unproject_matches_world_to_px`,
`drag_crosses_port_6px_threshold`, `ground_endpoints_finite`,
`drag_crosses_donor_0.005m_epsilon`, `drag_start_from_real_event`,
`world_sel_active_during_drag`, `overlay_hidden_after_release`,
`selected_ids_exact [10,11]`, `unit10_selected`, `unit11_selected`,
`unit12_not_selected`, `building_not_selected`,
`building_inside_rect_but_excluded_by_kind`, `cmd_counter_zero_after_drag`,
`short_click_selects_single_unit [10]`, `cmd_counter_zero_after_click`
— all unchanged by inspection: at 1280×720 the new event→cam and canvas maps are
identity, the frozen anchor equals the old per-frame re-unprojection of the same
press pixel, the entity filter/Shift union/`_set_selection` are verbatim, and
`_cancel_drag()` only adds cleanup on paths the atom does not exercise adversely.

### 4.3 KNOWN test regression — COORD follow-up, NOT edited by B05
`variant3d/tests/t_select_rect.gd:525,532` computes
`expected := Rect2(_p0, _p1).abs()` and asserts the overlay rect equals it. That
expression **encodes the same `Rect2(position, end_px)` size bug** this ticket fixed
in game code. After the fix the overlay reports `Rect2(p0, p1-p0).abs()` (ending at
the cursor, correct), so **`overlay_rect_during_drag` will FAIL** until the
TEST owner updates `expected` to `Rect2(_p0, _p1 - _p0).abs()` (or equivalent).
**Do not weaken or delete the assertion** — correct its expectation. D03's proposed
capture atom §4.4 uses the same wrong `expected := Rect2(_p0,_p1).abs()` and needs
the identical test-owner correction before it is authored. The game code is
correct; the test expectation is the defect. No test file was touched by B05.

### 4.4 Other honest limits
- **selftest 29/29 / uitest 17/17** not re-run (COORD owns runner jobs); no claim made.
- **Donor parity UNVERIFIED** — no donor GPU A/B frame; native inside-box predicate,
  FOV/ArcTan, brush rasterisation and drag-pan mechanism are UNVERIFIED
  (DSEL-01 Q1, DSEL-02 Q1/Q6, D02 §8, F03 O1).
- **Live-selection per frame** replays `_set_selection` only when the boxed id set
  changes (dedupe guard); exact donor selection-sound timing is UNVERIFIED.
- **Camera-follows-drag (F03 G1)** not implemented: requires `camera3d.gd`/`world3d.gd`
  changes, outside this grant. Recorded as follow-up in §5.
- **D05 #5 hover HUD hit-test** and **#6 top-strip `MOUSE_FILTER_IGNORE`** not changed;
  #6 is an explicit owner decision (UI-TOPBAR-01 calls the pass-through intentional).
- **D05 #7 empty/building selection sounds** left as-is per COORD; audible edge-case
  parity UNVERIFIED.
- **Wall bug not copied**: drag selection still rebuilds from scratch and excludes
  buildings/walls by `kind`; a prior wall selection cannot suppress box selection.

---

## 5. Follow-ups for COORD (not in B05's grant)

1. **TEST owner**: fix `t_select_rect.gd:525,532` wrong `Rect2` expectation (§4.3),
   and D03's proposed capture atom `expected` in §4.4. This is required for a
   truthful 23/23 after this fix.
2. **Camera owner (camera3d.gd/world3d.gd)**: implement donor "map moves with you"
   edge-scroll during a frame drag (F03 G1), including the S2 keyboard/mouse-speed
   fix and the S7 "box shifts instead of resizing" failure mode. Explicitly
   out of B05's file grant; no camera/world file touched.
3. **Owner decision**: D05 #6 top-strip `MOUSE_FILTER_IGNORE` (keep pass-through vs
   STOP + explicit hovered-control guard) and D05 #7 building-selection sound
   (`bld<sid>` cue vs silence).
4. **QA**: execute D03's before/during/after capture (CAP-3) with the corrected
   `Rect2` expectation and the overlay reparented into `capture_view3d`
   (D03 Trap A); composer must be an independent second agent (C04).

---

## 6. Summary

**OBSERVED / FIXED** — the owner's "quad not ok" root cause was the
`Rect2(drag_start, cur)` constructor misuse (second argument is a size, so the box
ended at `press + release`, outside the viewport); it is now
`Rect2(drag_start, cur - start).abs()`. The minimap-release early return that froze
the box on screen is closed by a single `_cancel_drag()` used on all five teardown
paths. D04's event→camera pixel map, canvas inverse transform, press-frozen ground
anchor and unified `_drag_cur_px`/`_drag_rect_sim` drive mirror, outline and live
selection from one consistent state. D02/F03 two-phase start, world epsilon,
Shift-add, double-click `0.5 s`, wall/build gate and the do-not-copy wall bug are
preserved; the low-risk D05 Ctrl/Shift click UX gaps are closed.

**PORT APPROXIMATION / UNVERIFIED** — the world rect, event/canvas maps and live
selection update are port approximations of an UNVERIFIED native predicate; donor
parity is not claimed. No runner job, test, config, other game file or git state was
changed. The single known test-contract consequence (`t_select_rect.gd` wrong
`Rect2` expectation) is reported above as a COORD/TEST follow-up, not papered over.

*End of B05.*
