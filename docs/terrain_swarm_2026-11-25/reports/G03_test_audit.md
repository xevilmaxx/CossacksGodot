---
id: G03
title: "G03 — re-audit of t_select_rect.gd after COORD's :525 Rect2 fix: stale expectations that let a green 23/23 mask a defect"
area: terrain-swarm Wave G — read-only test audit
owner: G03 (read-only analysis subagent)
date: 2026-11-25
status: READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT
scope: "Exactly one file written: docs/terrain_swarm_2026-11-25/reports/G03_test_audit.md. No .gd/.gdshader/config/fixture/result-JSON/PNG/gate/git edit; no Godot process or runner job; no test line changed. Every replacement below is a PROPOSAL for the test owner (COORD) to apply."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
inputs:
  - variant3d/tests/t_select_rect.gd (full file, post-COORD-fix working tree)
  - variant3d/tests/results/t_select_rect.json (stale 23/23 artifact, pre-fix)
  - variant3d/scripts/input_controller.gd (B05 implementation)
  - docs/terrain_swarm_2026-11-25/reports/B05_selection_impl.md
  - docs/terrain_swarm_2026-11-25/reports/D01_selection_quad_audit.md
  - docs/terrain_swarm_2026-11-25/reports/D03_selection_probe.md
  - docs/terrain_swarm_2026-11-25/reports/D04_selection_projection.md
  - docs/terrain_swarm_2026-11-25/reports/D05_selection_ui.md
  - variant3d/tests/t_select_rect_capture.gd (G01's new file, read-only cross-check)
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "No donor GPU A/B frame exists; no donor-parity claim is made. All geometry numbers below are from the local result JSON or derived arithmetic."
---

# G03 — `t_select_rect.gd` stale-expectation audit

## 0. Boundary and label key

**OBSERVED** = literal source line or result-JSON value read this session.
**DERIVED** = arithmetic / control-flow consequence of an observed line.
**INFERRED** = reasoned but not measured. **UNVERIFIED** = cannot be established here.

G03 did **not** edit any test line, flip any marker, or submit a runner job. All `file:line`
values refer to the **current working tree** (after COORD's `t_select_rect.gd:525-529` fix,
which added four comment lines and shifted every later line by +4). Where an earlier report
cites pre-shift numbers (D01 cites `:525,:561,:538-539`), both numbers are given.

---

## 1. Verdict

**OBSERVED** — COORD's fix at `t_select_rect.gd:529` is correct:
`var expected := Rect2(_p0, _p1 - _p0).abs()` now ends at the cursor and can genuinely
catch the pre-B05 `Rect2(position, end_px)` defect. **No further change is needed at :529.**

**OBSERVED** — the atom still contains a **second, unfixed instance of the same
`Rect2(position, end)` misuse** at `:565`, plus stale metadata that misdescribes what was
verified. The pre-fix `t_select_rect.json` (23/23, `overlay_rect_during_drag` PASS with
`S=(917,458)`) is direct evidence that a green atom can certify the wrong rectangle.

| # | Severity | Finding | Current line | Mask risk |
|---:|---|---|---|---|
| G03-1 | **REQUIRED** | Second `Rect2(_g0, _g1)` (end used as size) in the ground-rect control | `:565` (D01 `:561`) | HIGH — self-validating oversized rect |
| G03-2 | **REPORT ONLY** | Two `expected_pre_fix_failure: true` records from one `true` argument | `:543` → checks `:615`,`:616` (D01 `:538-539`) | MED — future FAIL labelled `[EXPECTED_FAILURE_PRE_FIX]` |
| G03-3 | REQUIRED (honesty) | Header still documents the *wrong* expectation and a superseded overlay cause | `:20-24` | MED — misleading contract |
| G03-4 | REQUIRED (honesty) | `donor_semantics` claims port drag ignores Shift; `drag_start` claim stale | `:236-237` | MED — JSON misrepresents coverage |
| G03-5 | RECOMMENDED (strengthen) | `event_coord_scale` / canvas transform recorded but **never asserted** | `:336-337`, no check | MED — identity precondition unproved |
| G03-6 | RECOMMENDED (strengthen) | `world.sel_rect` rect content never asserted; only `sel_active` | `:603-607` | MED — dead-mirror drift invisible |
| G03-7 | RECOMMENDED (strengthen) | B05's new live-selection-while-held path has no assertion | stage 3, `:599-609` | MED — B05 behavior can regress green |
| G03-8 | RECOMMENDED (coverage) | Minimap-release teardown (D01-3 fix) untested; hover path untested | stages `:578-632` | HIGH for the stuck-quad fix |
| G03-9 | INFO | Stale line citations / `runner_declaration` names a failed job | `:451`,`:607`,`:241` | LOW |

---

## 2. Detailed findings and exact proposals

### G03-1 — REQUIRED: the ground-rect expectation repeats the pre-B05 Rect2 bug

**OBSERVED** — `t_select_rect.gd:565` (inside `_assert_drag_result()`):

```gdscript
	var ground_rect := Rect2(_g0, _g1).abs()
	check("building_inside_rect_but_excluded_by_kind", ground_rect.has_point(_bld.pos),
```

`Rect2(position, size)` again receives the **end ground point as a size**. D01 already
flagged this at old `:561` (D01 report `:87-89`, `:277-278`); COORD's `:525` fix did not
cover it.

**DERIVED** — with the measured `ground_point(p0)=(51.810,54.407)`,
`ground_point(p1)=(76.111,71.214)` (`t_select_rect.json` `ground_endpoints_finite`/
`measured_ground_rect`):

- current expression → `P=(51.810,54.407) S=(76.111,71.214)`, end `=(127.921,125.621)`;
- correct expression → `P=(51.810,54.407) S=(24.301,16.806)`, end `=(76.111,71.214)`.

The building at SIM `(64,64)` lies inside **both**, so the check is PASS either way. It is
therefore tautological with respect to the exact oversize defect this wave is fixing: a
regression that reintroduces an oversized ground rect is not detected by this control.
It is also not a check against the game's real selection rect — the measured
`world_sel_rect_during` is `P=(51.810,54.380) S=(29.627,45.340)` (4-corner AABB, see
G03-6), not either 2-corner rect.

**Exact replacement (test owner to apply)** — `t_select_rect.gd:565`:

```gdscript
-	var ground_rect := Rect2(_g0, _g1).abs()
+	var ground_rect := Rect2(_g0, _g1 - _g0).abs()
```

**DERIVED** — after replacement the check still PASSes at the measured geometry
(`(64,64)` is inside `(51.810,54.407)-(76.111,71.214)`), so this is a pure expectation
correction, not a weakening, and the 23/23 count is unchanged.

**Cross-atom note (COORD to relay, G03 did not edit):** G01's new
`variant3d/tests/t_select_rect_capture.gd:707` copied the same line
`var ground_rect := Rect2(_g0, _g1).abs()`; its overlay expectations at `:672` and `:821`
are already correct. It needs the identical one-line change, or the new capture atom will
inherit the same blind spot.

---

### G03-2 — REPORT ONLY: the two `expected_pre_fix_failure: true` markers

**OBSERVED** — `t_select_rect.gd:542-543` (`_assert_overlay`):

```gdscript
	check(label, ok, "node=%s api=%s visible=%s rect=%s expected=%s" % [
		str(probe.get("node", "")), str(api), str(visible), str(got), str(expected)], true)
```

The single trailing `true` is the `expected_pre_fix_failure` argument of `check()`
(`:178-188`) and is used by **both** call sites:

- `:615` `_assert_overlay(_overlay_during, true, "overlay_rect_during_drag")`
- `:616` `_assert_overlay(_overlay_after, false, "overlay_hidden_after_release")`

So the result JSON contains exactly two `expected_pre_fix_failure: true` records
(`t_select_rect.json` checks 13 and 14). D01 flagged these at old `:538-539`
(D01 report `:194-198`, `:285-286`).

**OBSERVED** — in the stale pre-fix JSON both checks were **PASS** while carrying the
`true` label, because game and test shared the same wrong rect. After B05 + COORD's fix
they PASS for the right reason. `check()` still sets `_ok = false` on any FAIL regardless
of the marker (`:185-186`), so the marker does not change the atom's own exit code — but any
future overlay regression would print `[EXPECTED_FAILURE_PRE_FIX]` (`:187-188`) and be
labelled as expected by downstream readers.

**G03 does NOT flip them**, per ticket instruction. **Proposal for COORD/test owner**
(owner decision; CHARTER §3's precondition — a landed fix — is satisfied by B05 +
`:525`):

```gdscript
-		str(probe.get("node", "")), str(api), str(visible), str(got), str(expected)], true)
+		str(probe.get("node", "")), str(api), str(visible), str(got), str(expected)], false)
```

If COORD elects to retain them, record explicitly in the gate log that a FAIL of either
overlay check is **not** acceptable even though it is labelled expected-pre-fix.

---

### G03-3 — REQUIRED (honesty): header documents the wrong contract

**OBSERVED** — `t_select_rect.gd:20-24`:

```gdscript
#   * A CanvasLayer selection-rect overlay with Rect2 == Rect2(p0,p1).abs()
#     during drag, hidden after release, is ASSERTED. Pre-fix this fails
#     (EXPECTED_FAILURE) because world3d.gd:126-127 stores sel_rect/sel_active
#     with no draw consumer (V3D-01 break point 1; DSEL-01 claim 28). The
#     assertion is retained, never weakened or deleted.
```

Two stale claims: (a) `Rect2(p0,p1).abs()` is the wrong expectation just corrected at
`:529`; (b) the overlay now lives in `input_controller.gd` (`SelectionRectOverlay`,
`:111-134`, created by `bind_3d()` at `:180-203`), not in `world3d.gd:126-127`. The dead
`world.sel_rect` mirror is not the marquee's draw consumer.

**Exact replacement** — `t_select_rect.gd:20-24`:

```gdscript
#   * A CanvasLayer selection-rect overlay (input_controller.gd SelectionRectOverlay)
#     with Rect2 == Rect2(p0, p1 - p0).abs() during drag, hidden after release,
#     is ASSERTED. Pre-B05 the game used Rect2(position, end_px) and the test
#     encoded the same wrong rectangle, so 23/23 could not catch it; the
#     corrected expectation (:529) now does. The assertion is retained, never
#     weakened or deleted.
```

Related stale header: `:11-17` still calls `6 px` a "port threshold" at
`input_controller.gd:613,662-663` and says "the port's drag branch ignores Shift
(`input_controller.gd:624`)". **DERIVED** — `input_controller.gd` no longer contains a 6 px
drag gate (grep: only `:428` uses `6.0`, for an unrelated proximity rule); `dragging` is
set by the world-ground epsilon at `:985-988`, and Shift drag union is implemented at
`:678-691`. Suggested replacement for `:11-17`:

```gdscript
#   * The synthetic drag crosses 6 screen pixels (a harness geometry pre-condition;
#     B05 removed the old 6 px port drag gate — `dragging` now comes from the
#     world-ground epsilon) and the donor's 0.005 m world-ground epsilon
#     (DSEL-01 claim 1; onmousemove.inc:32-34); both are MEASURED and asserted.
#   * Donor Shift=add (DSEL-01 claim 4) is recorded in JSON; B05 implements the
#     drag union by id (input_controller.gd:678-691), but this atom sends
#     shift_pressed=false (`:477`) and does NOT assert the union — a declared
#     coverage gap, not a claim that Shift is ignored.
```

---

### G03-4 — REQUIRED (honesty): `donor_semantics` misstates what was verified

**OBSERVED** — `t_select_rect.gd:234-240`; D01-6 (`:189-193`) already flagged `:234-240`.

**Exact replacements:**

`t_select_rect.gd:236`:
```gdscript
-		"drag_start": "first LMB-held move (DSEL-01 claim 3)",
+		"drag_start": "press pixel + press-frozen ground anchor (B05/D04 PORT APPROX of donor first LMB-held move, DSEL-01 claim 3)",
```

`t_select_rect.gd:237`:
```gdscript
-		"shift": "add / spmAdd (DSEL-01 claim 4) — port drag ignores Shift (claim 27); declared divergence, not asserted here",
+		"shift": "add / spmAdd (DSEL-01 claim 4) — port drag unions by id on Shift (input_controller.gd:678-691); this atom sends shift_pressed=false and does not assert the union (declared coverage gap)",
```

`t_select_rect.gd:241` (low priority; D01 `:199-201`):
```gdscript
-		"runner_declaration": "S1-INPUT-FIX: validated via variant runner, windowed real-input job s1inputfix-run; see docs/coord_swarm_2026-11-25/reports/S1_INPUT_FIX.md",
+		"runner_declaration": "S1-INPUT-FIX harness declaration only; verdict must be read from the current runner result envelope (job s1inputfix-run failed 5/7 per S1_INPUT_FIX.md)",
```

---

### G03-5 — RECOMMENDED (strengthen): assert the identity precondition instead of only recording it

**OBSERVED** — `_to_event_coord()` (`:321-340`) writes `_m["event_coord_scale"]` at
`:336-337`, but no `check()` reads it. D03 §4.1 item 3 and §6(c) require
`event_coord_scale = [1,1]` and both viewports `[1280,720]` as an admission condition; the
atom merely records them. The overlay expectation `Rect2(_p0, _p1-_p0).abs()` is in
**camera-projection pixels**, while `_show_selection_rect()` now stores a **canvas-space**
rect via `get_canvas_transform().affine_inverse()` (`input_controller.gd:205-222`). These
spaces coincide only at identity, which is why every green atom was green.

**Proposal** — insert immediately before `:615` (`_assert_overlay(_overlay_during, ...)`),
i.e. after `_m["world_sel_active_after"] = bool(_world.sel_active)` at `:614`:

```gdscript
				var es: Array = _m.get("event_coord_scale", [])
				check("event_coord_scale_identity", es.size() == 2
					and absf(float(es[0]) - 1.0) < 0.001 and absf(float(es[1]) - 1.0) < 0.001,
					"event_coord_scale=%s root=%s proj=%s (identity precondition for the overlay Rect2 expectation)" % [
					str(es), str(root.size), str(_cam.get_viewport().size)])
				var xf: Transform2D = root.get_canvas_transform()
				check("canvas_transform_identity", xf.is_equal_approx(Transform2D.IDENTITY),
					"root canvas=%s (B05 _show_selection_rect applies affine_inverse; expectation assumes identity)" % str(xf))
```

**DERIVED** — at the measured windowed pose (`root_viewport_px=[1280,720]`,
`projection_viewport_px=[1280,720]`, `event_coord_scale=[1,1]` in the stale JSON) both new
checks PASS; at any other size they go RED honestly instead of producing a misleading
green. If `Transform2D.IDENTITY` is unavailable in this Godot build, compare
`xf.origin.is_equal_approx(Vector2.ZERO)` and
`xf.basis_xform(Vector2(1,0)).is_equal_approx(Vector2(1,0))` instead.

---

### G03-6 — RECOMMENDED (strengthen): assert the world mirror's rect, not only `sel_active`

**OBSERVED** — `:603-607` records `_m["world_sel_rect_during"]` but the only assertion is
`check("world_sel_active_during_drag", bool(_world.sel_active), ...)`. The detail string
cites superseded `input_controller.gd:1164-1172`; the live code is `:1496-1506` (B05 unified
`_drag_cur_px` + press-frozen `_rect_ground_anchor`). A reintroduced double-shift or stale
mirror rect would leave 23/23 green.

**Exact replacement** — `t_select_rect.gd:606-607`:

```gdscript
				check("world_sel_active_during_drag", bool(_world.sel_active),
					"world.sel_rect mirror from input_controller.gd:1496-1506 (B05 one _drag_cur_px + press-frozen anchor)")
				var got_sim: Rect2 = _world.sel_rect
				check("world_sel_rect_covers_drag_corners", got_sim.has_area()
					and got_sim.grow(0.5).has_point(_g0) and got_sim.grow(0.5).has_point(_g1)
					and got_sim.size.x < 100.0 and got_sim.size.y < 100.0,
					"world.sel_rect=%s g0=%s g1=%s (4-corner AABB may exceed the 2-corner rect; bound only)" % [
					str(got_sim), str(_g0), str(_g1)])
```

**DERIVED** — the measured mirror `P=(51.810,54.380) S=(29.627,45.340)` contains both
ground corners and is well under the 100 m map-scale bound, so this PASSes as written.
**Important:** do **not** use `is_equal_approx` against `Rect2(_g0,_g1-_g0)` here — the
measured mirror legitimately over-covers the 2-corner rect by ~28 m in Y (4-corner AABB,
D01-4), so a tight equality would be a false red. The mirror is a dead SIM-metre surface
with no draw consumer (D01-5, D04 §9 q5); this check is a drift detector, not a visual claim.

---

### G03-7 — RECOMMENDED (strengthen): assert B05's live-selection-while-held behavior

**OBSERVED** — B05 added `_apply_rect_selection(_drag_rect_sim)` inside `_process()`
(`input_controller.gd:1531-1535`) so the boxed set updates while LMB is held, but the atom
checks selection only after release (`_assert_drag_result()` at `:617`, stage 4). A
regression that removes live selection is invisible to 23/23.

**Proposal** — insert at stage 3, immediately before `:608`
(`_send_mouse_button(_p1, false)`):

```gdscript
				check("live_selection_while_held", _selected_ids() == [10, 11],
					"B05 _process applies _apply_rect_selection while LMB held; selected=%s" % str(_selected_ids()))
				_send_mouse_button(_p1, false)
```

**DERIVED** — stage 3 waits 2 frames after the motion event, so `_process()` has applied the
live rect; the measured final set is `[10,11]`, so this PASSes. This is a new assertion
(check count +1), not a change to any existing expectation.

---

### G03-8 — RECOMMENDED (coverage): minimap release and hover paths

**OBSERVED** — the atom drives only world-space press → motion → release at
`:589-626` (D01 `:134-135`, `:262`). There is **no** check for the D01-3 stuck-quad path
that B05 fixed with `_cancel_drag()` (`input_controller.gd:234-240`, called at `:783`,
`:795`, `:942`, `:957`, `:969`). A regression that reintroduces the minimap early return
would leave a yellow quad stuck on screen and the atom still 23/23.

**Proposal (owner's choice of home):**

- Preferred: add the minimap-release check to G01's new capture atom, which is already a
  new file and not the shared 23/23 gate driver. No change to `t_select_rect.gd`.
- If COORD wants it in this atom, replace stage 7 (`:628-631`) with the block below and add
  stages 8/9. Note the minimap rect is already in **root/event** pixels, so its events must
  **not** pass through `_to_event_coord()` (which expects camera-projection pixels).

```gdscript
		7:  # click assertion, then minimap-teardown probe
			if _stage_frames >= 2:
				_assert_click_result()
				_goto(8)
		8:  # D01-3 / B05 _cancel_drag: world drag released over the minimap
			if _stage_frames >= 2:
				_send_mouse_button(_p0, true)
				_send_mouse_motion(_p1, true)
				var mm: Rect2 = _ictl.call("_minimap_screen_rect")
				var mmc: Vector2 = mm.get_center()  # already root/event px; no _to_event_coord()
				var ev := InputEventMouseButton.new()
				ev.position = mmc
				ev.global_position = mmc
				ev.button_index = MOUSE_BUTTON_LEFT
				ev.pressed = false
				Input.parse_input_event(ev)
				_goto(9)
		9:
			if _stage_frames >= 2:
				var after_mm := _overlay_probe()
				check("minimap_release_clears_drag", _ictl.drag_start == Vector2.INF
					and not bool(_ictl.dragging) and not bool(after_mm.get("visible", false)),
					"drag_start=%s dragging=%s overlay=%s" % [
					str(_ictl.drag_start), str(_ictl.dragging), str(after_mm)])
				_finish()
```

**UNVERIFIED (not asserted anywhere):** the hover cursor over HUD (D05 defect #5) was
deliberately **not** fixed by B05 (B05 report `:144-148`), and D05 #6 top-strip
`MOUSE_FILTER_IGNORE` is an explicit owner decision. Do **not** add an assertion that would
declare hover fixed; record it as an open gap in the gate log instead. The atom's
`_send_mouse_motion(_p_click, false)` at `:618` only parks the cursor before the click — it
is not a hover test.

---

### G03-9 — INFO: stale citations

- `:451` detail string cites `input_controller.gd:613,662-663` for the 6 px threshold; no
  such gate exists after B05 (see G03-3).
- `:607` cites `input_controller.gd:1164-1172`; live mirror is `:1496-1506` (covered by
  G03-6's replacement).
- `:241` names failed job `s1inputfix-run` (covered by G03-4's replacement).
- **Cross-file, not G03's edit:** `input_controller.gd:214-216` and `:1527-1528` still say
  `t_select_rect.gd:525` encodes a wrong expectation. That is now false after COORD's fix;
  owner/G14 may update those comments. G03 touched no game file.

---

## 3. Consolidated change proposal (COORD / test owner applies; G03 applied none)

All line numbers are the **current** working tree.

| Priority | File:line | Current text (exact) | Replacement (exact) |
|---|---|---|---|
| REQUIRED | `t_select_rect.gd:565` | `	var ground_rect := Rect2(_g0, _g1).abs()` | `	var ground_rect := Rect2(_g0, _g1 - _g0).abs()` |
| REPORT ONLY — do not flip in G03 | `t_select_rect.gd:543` | `... str(got), str(expected)], true)` | `... str(got), str(expected)], false)` **only on owner decision** (see G03-2) |
| REQUIRED (honesty) | `t_select_rect.gd:20-24` | `Rect2 == Rect2(p0,p1).abs()` + world3d cause | block in G03-3 |
| REQUIRED (honesty) | `t_select_rect.gd:11-17` | 6 px "port threshold" + "drag ignores Shift" | block in G03-3 |
| REQUIRED (honesty) | `t_select_rect.gd:236` | `"drag_start": "first LMB-held move ..."` | block in G03-4 |
| REQUIRED (honesty) | `t_select_rect.gd:237` | `"shift": "... port drag ignores Shift ..."` | block in G03-4 |
| LOW | `t_select_rect.gd:241` | `runner_declaration` naming job `s1inputfix-run` | block in G03-4 |
| RECOMMENDED | before `t_select_rect.gd:615` | *(no assertion)* | identity-check block in G03-5 |
| RECOMMENDED | `t_select_rect.gd:606-607` | `sel_active` check + stale `:1164-1172` cite | block in G03-6 |
| RECOMMENDED | before `t_select_rect.gd:608` | *(no assertion)* | live-selection check in G03-7 |
| RECOMMENDED (coverage) | `t_select_rect.gd:628-631` or G01 atom | *(no minimap test)* | block in G03-8 |
| Cross-atom relay | `t_select_rect_capture.gd:707` | `	var ground_rect := Rect2(_g0, _g1).abs()` | `	var ground_rect := Rect2(_g0, _g1 - _g0).abs()` |

Check-count impact: the two required line replacements keep 23/23. Each recommended new
`check()` raises the total by one (identity ×2, mirror ×1, live-selection ×1, minimap ×1
→ up to 28/28). No threshold (`6.0`, `0.005`) and no existing assertion is lowered or
deleted by any proposal here.

---

## 4. Confirmed correct — do not change

- **OBSERVED** — `:529` `Rect2(_p0, _p1 - _p0).abs()` is the right expectation; it is the
  direct inverse of B05's `Rect2(drag_start, cur - drag_start).abs()`
  (`input_controller.gd:1529`), and `.abs()` is available in this Godot version
  (the `is_empty()` precedent at `:539-540` was correctly handled with `has_area()`).
- **OBSERVED** — `_overlay_probe()` (`:491-514`) still matches the live node:
  `SelectionRectOverlay` sets both `name` and meta `sel_rect_overlay`
  (`input_controller.gd:111-134`), and `get_selection_rect()` exists (`:126-127`).
- **OBSERVED** — the hidden branch (`:537-541`) correctly treats "node not found",
  "invisible" and "no area" as hidden; the stuck-quad regression it must catch is a
  *visible* overlay with a non-empty rect, which it rejects.
- **OBSERVED** — `_p0/_p1` come from `_cam.unproject_position()` (`:313-318`) and are
  cross-checked against `_cam.world_to_px()` at `:445-447`; the harness inverse
  `_to_event_coord()` (`:321-340`) is the exact inverse of B05's
  `_event_px_to_cam_px()` (`input_controller.gd:617-628`). No coordinate correction is
  missing at the proven identity pose — only its **assertion** is missing (G03-5).

---

## 5. Honesty statement

- Exactly one file was written by G03: this report. No `.gd`, shader, config, fixture,
  result JSON, PNG, gate or git state was edited; no Godot process or runner job was
  submitted; no marker was flipped.
- The stale `t_select_rect.json` (23/23) was read as historical evidence only — not as a
  new verdict. No fresh run is claimed; G04 owns the runner.
- Donor internals and pixels stay **UNVERIFIED**; no donor-parity claim is made. The
  minimap/hover coverage proposals are PORT APPROXIMATION / port-internal checks, not
  donor reconstructions.
- Proposals G03-3..G03-8 are deliberately labelled RECOMMENDED where they *add* coverage;
  only G03-1 and the metadata corrections are marked REQUIRED because they fix assertions
  that currently encode the pre-B05 defect or misstate what was verified.

*End of G03.*
