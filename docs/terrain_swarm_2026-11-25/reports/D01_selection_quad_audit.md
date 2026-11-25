---
id: D01
title: "D01 — Selection quad / marquee: current end-to-end audit (variant3d, READ-ONLY)"
owner: D01 (analysis subagent)
date: 2026-11-25
status: STATIC_AUDIT_COMPLETE__NO_GODOT_JOB__NO_CODE_EDIT
scope: "Read-only. No code/config/test/result/scene/shader/git edit; no Godot runner job. Exactly one report written: docs/terrain_swarm_2026-11-25/reports/D01_selection_quad_audit.md."
labels: [observed, derived, inferred, UNVERIFIED, evidence-labelled]
evidence_labels:
  observed: "literal source line, result-JSON value, or runner status read this session"
  derived: "arithmetic / control-flow consequence of observed facts"
  inferred: "plausible user-visible consequence; not measured in this audit"
  UNVERIFIED: "native donor internals or pixels not observed under this charter"
gate_note: "Job 581 (coord-final-uitest) has a queue directory but no result JSON at audit time; no job was started, waited on, or read as a new verdict here."
---

# D01 — Selection quad audit (current tree)

## 0. Method and prior context

Read in full this session: `docs/terrain_swarm_2026-11-25/CHARTER.md`; prior reports
`SEL_01_implementation.md`, `S1_INPUT_FIX.md`, `V3D_01_selection_rectangle_audit.md`,
`DSEL_01_donor_selection_rectangle.md`, `DSEL_02_donor_pick_math.md`; additionally
`B_SELRECT_FIX.md`, `CONFIG_WIRE_SEL.md` (both post-SEL-01 and necessary to understand
the *current* file).

Read-only source audited: `variant3d/scripts/{input_controller,picking3d,world3d,hud,
hud3d_adapter,camera3d,config,main}.gd`, `variant3d/config.json`, `variant3d/project.godot`,
`variant3d/tests/t_select_rect.gd`, `variant3d/tests/results/t_select_rect.json`,
runner metadata `variant3d/.godot_queue/results/00000578.json` and its `stderr.txt`.

**No Godot process was started.** Every claim is a static observation, an explicitly
labelled derivation, or a documented prior measurement. Donor parity stays UNVERIFIED.

## 1. Verdict (top of ranked list)

The quad *is* drawn and *is* hidden after release, and the style is donor-correct
(1 px solid yellow, no fill). But the drawn rectangle's **size is computed from the
end pixel instead of the drag delta**: `Rect2(drag_start, cur).abs()` is a
`(position, size)` constructor, not a two-point constructor. The green test encodes
the same mistake as its expected value, so the 23/23 atom cannot detect it. This is a
**high-confidence, user-visible geometry defect** and the most plausible meaning of
"the quad is still not OK".

```
D01-1  CRITICAL  marquee size = end pixel, not delta      input_controller.gd:1369
D01-2  HIGH      test self-validates the wrong rect        t_select_rect.gd:525,532
D01-3  HIGH      drag released over minimap => stuck quad  input_controller.gd:678-695
D01-4  MED       four-corner ground AABB over-selects      input_controller.gd:590-603
D01-5  MED       overlay mirror frozen vs live mouse       input_controller.gd:1368 vs :1350
D01-6  MED       stale test metadata / markers             t_select_rect.gd:234-240,477,538
D01-7  LOW       minimap frustum QUAD API never called      hud3d_adapter.gd:160-179
D01-8  LOW       above-horizon corners corrupt ground rect  picking3d.gd:148-171
D01-9  INFO      no parse/runtime error blocks the quad     t_select_rect.json:243-248
```

## 2. Defect list (evidence-labelled, ranked by user-visible severity)

### D01-1 — CRITICAL: the yellow quad has the wrong size (extends far past the cursor)

**Labels: observed + derived.**

- **observed** — `variant3d/scripts/input_controller.gd:1367-1371`:
  `_show_selection_rect(Rect2(drag_start, cur).abs())`.
- **observed** — `input_controller.gd:121-126` stores that Rect2 verbatim as
  `selection_rect`; `:88-100` passes it straight to
  `draw_rect(rect_px, Color(...), false, width, false)`.
- **observed** — in Godot `Rect2(Vector2 position, Vector2 size)`; `Rect2.abs()`
  normalises a *negative size* by shifting position, it never converts an end point
  into a delta. The result JSON proves which interpretation the code used:
  `t_select_rect.json:77` and `:201-212` record
  `rect = P (395.262, 273.539), S (917.084, 457.888)` for
  `p0=(395.262,273.539)`, `p1=(917.084,457.888)` (`:213-220`).
- **derived** — the drawn box therefore ends at `(395.262+917.084, 273.539+457.888)
  = (1312.35, 731.43)`, which is **outside the 1280×720 viewport**
  (`t_select_rect.json:221-233`). The correct box between the two drag pixels is
  `P = p0`, `S = p1-p0 = (521.822, 184.349)`, ending exactly at the cursor `p1`.
  The current quad overshoots by exactly `p0` in both axes — it is pinned at the
  drag origin and its right/bottom edges run off screen.
- **observed** — `B_SELRECT_FIX.md:89-92` explicitly preserved this line as
  "byte-identical behaviour"; `SEL_01_implementation.md:58,88` called
  `Rect2(drag_start, current_mouse).abs()` the marquee. The bug was introduced with
  the overlay itself and survived every green gate.
- **inferred** (user-visible) — during a drag the user sees a giant yellow box that
  does not bound the units being selected; the marquee and the actual selected set
  disagree. This is a direct, first-order explanation of the owner complaint.
- **derived** — the same misuse occurs a second time at `t_select_rect.gd:561`
  (`var ground_rect := Rect2(_g0, _g1).abs()` for the "building inside rect" check),
  so that check uses an oversized rect too.

**Minimal fix (not applied):** `input_controller.gd:1369` →
`_show_selection_rect(Rect2(drag_start, cur - drag_start).abs())`; and
`t_select_rect.gd:525` → `var expected := Rect2(_p0, _p1 - _p0).abs()`.

### D01-2 — HIGH: the atom validates the wrong geometry, so 23/23 is not evidence the quad is right

**Labels: observed + inferred.**

- **observed** — `t_select_rect.gd:524-539`: `expected := Rect2(_p0, _p1).abs()`
  (`:525`), compared with the overlay's returned rect (`:526,532`). Both sides make
  the identical `(position, size)` mistake; the check is tautological with respect
  to the defect in D01-1.
- **observed** — `t_select_rect.json:77,79-81,85-86` both overlay checks PASS;
  `:243-248` `"passed": true, "passes": 23, "total": 23`.
- **observed** — no pixel proof exists: `t_select_rect.json:2` says "no PNG assertion";
  `B_SELRECT_FIX.md:126-131` and `S1_INPUT_FIX.md:222-224` both state no visual
  capture is asserted by this atom.
- **inferred** — the green gates (selftest 29/29, uitest 17/17, atom 23/23) certify
  *input plumbing and selection ids*, not the drawn quad. A second-agent windowed
  capture is required before the quad can be called visually correct.

### D01-3 — HIGH: a world drag released over the minimap leaves the quad stuck on screen

**Labels: observed + derived + inferred.**

- **observed** — `input_controller.gd:678-681`: **every** LMB button event
  (press *or* release) whose position is inside `_minimap_screen_rect()` sets
  `_mm_dragging = mb.pressed`, repositions the camera, and `return`s.
- **observed** — the only drag-state cleanup at `:687-695` is guarded by
  `not mb.pressed and _mm_dragging`; by the time a release *inside* the minimap
  reaches that line, `_mm_dragging` has already been set to `false` at `:679` and
  the function has returned. That branch is reachable for a minimap drag released
  **outside** the minimap, not for the world-drag case its comment at `:689-690`
  claims to handle.
- **observed** — `hud.gd:1636-1640` consumes minimap LMB **press** but not release;
  `:1641-1645` never swallows motion. So a release over the minimap either returns
  at `input_controller.gd:678-681` or is not delivered at all — both leave state.
- **derived** — `drag_start`, `dragging`, `_sel_ground_start`, `_drag_current` stay
  set; `_process:1367-1371` keeps calling `_show_selection_rect()` every frame with
  the frozen last rect, and `:1350-1351` keeps `world.sel_active = true`. No
  `_set_selection()` runs (`:760-788` is skipped by the early return).
- **inferred** — user sees a yellow marquee that will not disappear and a selection
  that was never applied; a further LMB press/release is needed to clear it.
- Note: the atom drives only world-space press/motion/release
  (`t_select_rect.gd:585-623`), so this path is **untested**.

**Minimal fix:** at `:678`, when `not mb.pressed`, first run a shared `_end_drag()`
(clear `drag_start`, `dragging`, `_sel_ground_start`, `_drag_current`, call
`_hide_selection_rect()`) before returning; reuse it at `:687-695` and `:810-814`.

### D01-4 — MEDIUM: the selection rect is a four-corner ground AABB, not the marquee footprint

**Labels: observed + derived; donor exact predicate UNVERIFIED.**

- **observed** — `input_controller.gd:590-603` `_drag_world_rect()` projects all
  four screen corners through `_screen_to_world()` → `picking3d.ground_point()`
  (`:235-243`) and takes the min/max AABB; `:766` uses it for selection,
  `:771` tests `rect.has_point(e.pos)`.
- **observed** — `picking3d.gd:148-171` ray-marches at 1 m steps + 20 bisections
  against `game.height_at()`; `picking3d.gd:224-225` `_screen_of()` (the
  `Camera3D.unproject_position()` frame FIX-SEL proved) exists but the drag path
  never uses it (V3D-01 `:166-172`).
- **derived** — under the shipped −32° perspective (`camera3d.gd:262,278`), the
  ground footprint of a screen rectangle is a trapezoid; its axis-aligned bounding
  box includes ground **outside** the drawn marquee. The AABB can therefore
  over-select units that appear outside the box, and ground-point testing ignores
  unit height/parallax. `B_SELRECT_FIX.md:20-23` changed two-corner under-coverage
  into four-corner over-coverage; the acceptance "rect must select what the marquee
  covers" is not proven.
- **UNVERIFIED** — donor native inside-box predicate (centre vs AABB vs frustum vs
  `GetGameObjectSelectionSizeByHandle`): DSEL-01 claim 24, DSEL-02 claim 11.
  Any replacement remains a declared PORT APPROXIMATION. Owner arbitration
  S-25-06 currently keeps the world ground rect, so a screen-space
  `select_in_rect()` needs an owner decision (SEL-01 `:28-29`).

### D01-5 — MEDIUM: overlay position comes from the last motion event; the world mirror uses the live mouse

**Labels: observed + derived + inferred.**

- **observed** — `_drag_current` is written only in the motion handler
  (`input_controller.gd:829-830`); the overlay reads it at `:1368`. The SIM mirror
  at `:1350` instead calls `get_viewport().get_mouse_position()`.
- **derived** — if the pointer stops sending motion while the camera edge-scrolls
  or zooms, the two rectangles describe different moments; after a successful
  release the selection uses `mb.position` (`:766`) while the last drawn quad used
  `_drag_current`.
- **inferred** — small visual "jump"/mismatch just before release; also makes the
  mirror in `world.sel_rect` a misleading debug surface. Note `world.sel_rect` /
  `sel_active` (`world3d.gd:126-127`) still have **no draw consumer** anywhere —
  grep finds only the writes at `input_controller.gd:1350-1351`, the declarations,
  and the test reads (`t_select_rect.gd:599-602`). The stale comment at
  `world3d.gd:126-127` cites `input_controller.gd:1017/1018/1020`, which are now
  `:1350-1351`.

### D01-6 — MEDIUM: stale test metadata and retained pre-fix markers misrepresent verification

**Labels: observed.**

- **observed** — `t_select_rect.gd:234-240` still declares
  `"shift": "... port drag ignores Shift ..."`, but the current drag branch
  implements Shift union (`input_controller.gd:773-787`; SEL-01 probe 329 was green
  at `[10,11,12]`). `:477` hardcodes `ev.shift_pressed = false`, so the atom never
  tests the live `Input.is_key_pressed(KEY_SHIFT)` path.
- **observed** — `t_select_rect.gd:538-539` passes `expected_pre_fix_failure = true`
  unconditionally for **both** overlay checks although they now pass; the result
  JSON retains `true` at `:78` and `:84`. Any future FAIL would still print
  `[EXPECTED_FAILURE_PRE_FIX]` (`:187-188`) and could be tolerated by downstream
  gate readers.
- **observed** — `t_select_rect.json:246` `runner_declaration` names job
  `s1inputfix-run` (ticket 407, which **failed** 5/7 per `S1_INPUT_FIX.md:155`),
  not the green job 414/438/578.
- **derived** — the atom's documented contract (`:14-17`) describes the superseded
  6 px / no-Shift port; current code uses the world epsilon (`:841-843`) and
  Shift-add. None of these are runtime defects, but they make the green JSON an
  unreliable statement of the quad's correctness.

### D01-7 — LOW: the minimap frustum *quad* is implemented but never drawn

**Labels: observed + inferred.**

- **observed** — `hud3d_adapter.gd:164-179` `stroke_minimap_quad()` and
  `:146-150` `get_minimap_quad()` exist, with donor
  `GetCameraFrustumQuadrangle` citation at `:39-55`.
- **observed** — `hud3d_adapter.gd:160-163` explicitly says the call site is left
  open because `hud.gd` is foreign-owned; `hud.gd:1666-1703` still strokes the
  AABB via `_mm_paint_box()` (`:1701,1703`).
- **inferred** — if the owner's "quad" also means the minimap viewport shape, the
  user still sees a rectangle, not a frustum quad. This is a separate atom from the
  marquee; donor engine shape is UNVERIFIED (DEC_08 §9 Q2, cited at `hud3d_adapter.gd:49-55`).

### D01-8 — LOW: above-horizon screen corners can corrupt the ground AABB

**Labels: observed + derived + UNVERIFIED (magnitude).**

- **observed** — `picking3d.gd:148-171`: for a ray that never crosses the
  heightfield, `_ray_heightfield()` falls back to `_plane_hit(origin, dir, 0.0)`;
  `_plane_hit()` at `:136-142` clamps a negative `t` to `0`, i.e. returns the
  camera origin. `ground_point()` (`:235-243`) does not check finiteness or map
  bounds.
- **derived** — `_drag_world_rect()` (`input_controller.gd:594-603`) has no
  finiteness guard; a marquee whose top edge is above the horizon can fold a camera
  origin into the AABB and produce a huge/incorrect selection rect. Outside the
  tested map-centre camera pose this is unmeasured (UNVERIFIED).

### D01-9 — INFO: parse / runtime error scan (no blocker found)

**Labels: observed.**

- `variant3d/tests/results/t_select_rect.json:243-248`: `"passed": true`, 23/23,
  `run_mode: windowed_real_input`; **no error field**.
- Runner metadata `variant3d/.godot_queue/results/00000578.json`: `status: "ok"`,
  `exit: 0`. Its `stderr.txt` contains only exit-time noise
  (`Texture with GL ID ... leaked`, `RenderingServer::get_singleton() is null`,
  `3 resources still in use at exit`) and **no `SCRIPT ERROR`**.
- Prior parse errors are documented and closed, not current:
  `SEL_01_implementation.md:69` (`Rect2.is_empty()` at `input_controller.gd:89,115`,
  fixed to `has_area()`) and `:72` (`t_select_rect.gd:399` untyped `via_helper`,
  `:487` `Rect2.is_empty()`, both fixed before S1-INPUT-FIX).
- The five new `ConfigScript.feature_selection_*` calls (`input_controller.gd:98,99,
  214-224`) resolve to real getters (`config.gd:425-439`) with defaults matching
  `config.json:17-22`; ticket 430 `configwires-smoke` parsed them clean
  (`CONFIG_WIRE_SEL.md:94`).
- **Conclusion:** no parse or runtime error in the results JSON explains the owner's
  complaint. It is a geometry/verification problem, not a crash.

## 3. Direct answers to the audit questions

| Question | Answer | Evidence |
|---|---|---|
| Is the quad actually drawn? | **YES** — `SelectionRectPainter._draw()` runs; overlay node `SelectionRectOverlay` found in-tree and `visible=true` during drag | `input_controller.gd:85-100,103-126,185,194-195`; `t_select_rect.json:77,201-212` |
| Is position/size correct? | **NO** — position correct, size is the end pixel, not the delta; box ends at (1312,731) in a 1280×720 viewport | `input_controller.gd:1369`; `t_select_rect.json:77,213-233` (D01-1) |
| Lifetime: shown during drag, hidden after? | **YES in the tested world-drag path** (`:1367-1371`; JSON `:77,83-86,189-200`), **NO for a drag released over the minimap** (D01-3) | `input_controller.gd:1367-1371,678-695`; `t_select_rect.json:201-212,234-235` |
| 1 px yellow style? | **YES** — `draw_rect(..., Color(1,1,0,1), false, 1.0, false)`, config-defaulted to yellow/width 1; donor `selection.cfg:3-14` | `input_controller.gd:91-100`; `config.gd:431-436`; `config.json:20-21`; DSEL-01 claim 18 |
| Projection / stretch scaling? | Overlay uses viewport px and matches events at the proven 1280×720 identity. Test's root→projection transform (`t_select_rect.gd:321-340`) is identity there; at other window sizes the test's SubViewport camera (1280×720, `main.gd:1240-1253`) and root-window event coords diverge, and `_drag_world_rect()` would feed the wrong pixels to `picking3d.ground_point()`. Headless is an explicit non-pass, not a fake fix. | `S1_INPUT_FIX.md:78-107`; `project.godot:15-19`; `t_select_rect.json:178-181,221-228` |
| Interaction with existing selection? | Replace by default; Shift unions with `get_selected()` by id (`spmAdd`). Building selector filter intact. No Ctrl-remove (donor branch commented out). | `input_controller.gd:768-788`; DSEL-01 claims 4/5 |
| Building exclusion? | **YES** — `e.kind != "unit"` skips buildings; atom proves a player-0 building at (64,64) inside the ground rect is not selected. Donor *does* have a building-selection branch (`onselection.inc:162-168`) — declared divergence. | `input_controller.gd:769`; `t_select_rect.json:112-123`; DSEL-01 claims 11/21 |
| Double-click? | Window now 0.5 s via config (`input_controller.gd:222-224,792`); 3D `view_rect` **now has the half-map shift** (`world3d.gd:271-274`) so V3D-01 row 5 is resolved. Remaining divergence: `_pick(pw,false)` lets enemies compete, donor left-click is own-only; no atom asserts timing. | `input_controller.gd:790-800`; `world3d.gd:247-293`; DSEL_02 `:240`; DSEL-01 claim 16 |
| Donor "box selection fails after wall" quirk? | Not reproduced; walls are buildings here and are excluded by kind (`:769`). Not a defect to copy. | `input_controller.gd:769`; CHARTER `:119-120` |
| Parse/runtime errors? | None current (D01-9). | `t_select_rect.json:243-248`; `00000578.json`; `00000578_.../stderr.txt` |

## 4. Minimal fix plan (proposal only — no edits made)

Owner-governed, smallest atoms; each needs its own builder ticket per CHARTER `:66-68`.

1. **Geometry (blocking, one line + one test line).**
   - `input_controller.gd:1369`: `Rect2(drag_start, cur - drag_start).abs()`.
   - `t_select_rect.gd:525`: `Rect2(_p0, _p1 - _p0).abs()` (and `:561` likewise for
     the ground-rect expectation). Re-run the windowed atom; assert the drawn rect's
     `end` equals `p1`, not `p0+p1`. Add a windowed capture read by a second agent —
     the current JSON alone cannot prove a visual fix.
2. **Lifetime (one helper).** Factor `_end_drag()` from `:810-814`; call it in the
   minimap early-out (`:678-681` on release) and in `:687-695`. Update the comment
   at `:689-690` to describe the real case.
3. **Test honesty (metadata only).** Correct `t_select_rect.gd:234-240` (Shift IS
   implemented), add a real-Shift drag check, flip the two stale
   `expected_pre_fix_failure` markers at `:538-539` by owner decision, fix
   `runner_declaration` in `t_select_rect.json:246`.
4. **Alignment of mirror/freeze (optional).** Use one authoritative current pixel
   for both the overlay (`:1368`) and the SIM mirror (`:1350`), refreshed on motion
   and after camera changes.
5. **Geometry semantics (needs owner decision, S-25-06).** If "the box selects what
   it covers" must be exact under −32° tilt, add a screen-space projection path on
   the existing `picking3d` adapter (`_screen_of()` at `picking3d.gd:224-225`
   already exists) and branch the drag release on `render_mode`, or document the
   four-corner AABB as an accepted PORT APPROXIMATION. Do not invent a donor
   predicate (DSEL-01 claim 24 is UNVERIFIED).
6. **Minimap quad (separate atom).** Wire `hud3d_adapter.stroke_minimap_quad()` into
   `hud.gd:1666-1703` only if the owner's "quad" includes the minimap frustum; the
   donor engine shape remains UNVERIFIED.

## 5. Open questions / UNVERIFIED

1. **Which quad did the owner see?** The world marquee (D01-1) is a proven geometry
   defect; the minimap frustum (D01-7) is unwired. No windowed screenshot of a live
   drag exists, so the exact user-visible surface is **inferred**, not observed.
2. Native selection-brush rasterisation and the inside-box predicate remain
   UNVERIFIED (DSEL-01 claims 18/24); the overlay is a declared PORT APPROXIMATION.
3. Magnitude of D01-8 (above-horizon drags) is unmeasured; the atom uses a fixed
   map-centre camera pose (`t_select_rect.gd:370-380`).
4. Job 581 (`coord-final-uitest`) had no result JSON at audit time; this report does
   not claim its verdict.
5. Non-1280×720 window behaviour of the stretch transform is derived from
   `project.godot:15-19` and the test's transform (`:321-340`), not measured.

**No repo file, config, test, result, scene, shader or git state was edited by this
ticket. No Godot job was started or waited on. Exactly one report file was written.**
