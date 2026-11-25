---
id: B-SELRECT-FIX
title: "B-SELRECT-FIX — four-corner ground-rect fix in variant3d/scripts/input_controller.gd only"
owner: B-SELRECT-FIX (implementation builder)
date: 2026-11-25
status: DONE__ONE_FILE__ONE_JOB
scope: "Exactly two files written: variant3d/scripts/input_controller.gd (fix) + this report. No other .gd/config/fixture/test/result/PNG/git edit. picking3d.gd, world3d_fx.gd, camera3d.gd, hud.gd untouched (read-only). app/ never touched."
labels: [observed, derived, UNVERIFIED]
parity_guard: "PORT APPROXIMATION only. No donor GPU A/B consulted; no donor-parity claim anywhere in this report."
---

# B-SELRECT-FIX — implementation report

## 0. Diagnosis carried (not re-derived)

**observed** — `docs/coord_swarm_2026-11-25/reports/B_SELRECT_DIAG.md` (219 lines, read in full
before editing): LMB press→motion→release at `input_controller.gd:648-799`; screen→sim-ground
via `_screen_to_world` `:575-588` → `picking3d.ground_point` `:235-243` (ray+march, not unproject);
rect was the ground AABB of TWO screen-corner rays `:747-751`; inclusion `rect.has_point`
`:753-757`; Shift unions `:758-772`; epsilon metres `:214-218,826-828`; screen-px yellow marquee
`:85-126,1353-1355`; SIM mirror `world.sel_rect` `:1332-1339`. Leading hypothesis #1: two-corner
AABB vs full marquee under −32° tilt (`camera3d.gd:262,278`) + relief skew. Owner acceptance:
rect must select what the marquee covers.

## 1. Backup evidence (governance: backup first, byte-identical)

**observed** — `Copy-Item variant3d/scripts/input_controller.gd ->
inbox/backup/input_controller.gd.bak-BSELFIX` BEFORE any edit. SHA256 both ends:

- `SRC=32CF6A96308CB971DF308BADC166F54DB1B62D513288C87B2CC7F3B27`
- `BAK=32CF6A96308CB971DF308BADC166F54DB1B62D513288C87B2CC7F3B27`
- match = `True`

## 2. Exact diff (minimal; current 1473 lines vs backup 1459 = +14)

One helper beside `:575-588`, two call-site swaps. Nothing else touched.

### 2a. New helper after `_screen_to_world` (lines 590-603)

```gdscript
# B-SELRECT-FIX (PORT APPROXIMATION): ground AABB of all FOUR marquee corners.
# Same ray+march path as _screen_to_world (picking3d.ground_point world ground
# coords + world epsilon, DSEL_02-carried); no new projection method. Fixes the
# two-corner under-coverage under -32 deg tilt vs the screen-px marquee.
func _drag_world_rect(a_px: Vector2, b_px: Vector2) -> Rect2:
	var c := _screen_to_world(a_px)
	var d := _screen_to_world(b_px)
	var e := _screen_to_world(Vector2(a_px.x, b_px.y))
	var f := _screen_to_world(Vector2(b_px.x, a_px.y))
	var minx := minf(minf(c.x, d.x), minf(e.x, f.x))
	var miny := minf(minf(c.y, d.y), minf(e.y, f.y))
	var maxx := maxf(maxf(c.x, d.x), maxf(e.x, f.x))
	var maxy := maxf(maxf(c.y, d.y), maxf(e.y, f.y))
	return Rect2(minx, miny, maxx - minx, maxy - miny)
```

**derived** — same `minf/maxf` AABB form as the old line; projects all four marquee corners
through the identical ray+march path. No new projection method, no screen-space
`select_in_rect()`, no threshold/unit change. Donor cites carried from DSEL_02 only
(world ground coords + world epsilon); all else UNVERIFIED.

### 2b. Release branch (old `:747-751`, now `:762-766`)

Removed the two-ray construction:

```gdscript
var a := _screen_to_world(drag_start)
var bp := _screen_to_world(mb.position)
var rect := Rect2(minf(a.x, bp.x), minf(a.y, bp.y), absf(a.x - bp.x), absf(a.y - bp.y))
```

Replaced with (donor S-25-06 comments kept verbatim above it):

```gdscript
# B-SELRECT-FIX: four-corner ground AABB of the full marquee
# (same ray+march path; PORT APPROXIMATION).
var rect := _drag_world_rect(drag_start, mb.position)
```

### 2c. SIM mirror in `_process` (old `:1334-1336`, now `:1348-1350`)

Removed the two-ray mirror; replaced with:

```gdscript
# B-SELRECT-FIX: same four-corner helper so mirror and selection agree.
world.sel_rect = _drag_world_rect(drag_start, get_viewport().get_mouse_position())
```

### 2d. Explicitly unchanged

- Screen-px marquee `:1367-1369` (`Rect2(drag_start, cur).abs()`) — byte-identical behaviour.
- Inclusion predicate `rect.has_point(e.pos)` + `dead/player/kind` filter — unchanged.
- Shift union `:758-772` (real `Input.is_key_pressed(KEY_SHIFT)`) — unchanged.
- LMB-only gating, epsilon test `:826-828`, click/double-click branch — unchanged.
- `_pick_screen` note: the helper calls `_screen_to_world` 4×, each recording `_pick_screen`.
  **derived** safe — release path issues no `_pick` after the rect; `_process` path re-sets it
  via build-ghost/cursor `_screen_to_world` calls before any consumer reads it.

## 3. Validation — ONE job via variant runner only (governance max)

Queue was quiet before submit (`status`: pending=0, lock free, now_serving=next_ticket=578).

- Job: `python variant3d\tools\godot_runner.py run --id bselrect-fix-probe1 --timeout 300 -- --path variant3d --script res://tests/t_select_rect.gd -- --config res://tests/fixtures/small_map_64.json --screenshot <Temp>/bselrect_probe.png`
- Ticket: **578** (`variant3d/.godot_queue/results/00000578_bselrect-fix-probe1/` + `00000578.json`)
- Status: **ok**; run 24.18 s; wait 0.00 s; **exit 0**
- Atom: `T_SELECT_RECT RESULT: PASS 23/23`
- `scan-stderr`: **script_error_lines 0** (`SCRIPT ERROR == 0`); stderr holds only the known
  benign warnings (T-MINES-FIX coal, atlas image-load, donor flat-root morph label, exit-time
  RID/ObjectDB leak noise).
- Probe result detail (**observed** from `stdout.txt`):
  - `selected_ids_exact — selected=[10, 11] expected=[10,11]` PASS
  - `unit10_selected`, `unit11_selected` PASS; `unit12_not_selected` PASS
  - `building_not_selected` (id 13, kind=building) PASS;
    `building_inside_rect_but_excluded_by_kind` (bld pos (64,64) inside ground rect) PASS
  - `short_click_selects_single_unit [10]` PASS (no click-pick regression);
    `cmd_counter_zero_after_drag/click` PASS
  - `overlay_rect_during_drag` (screen-px marquee == `Rect2(p0,p1).abs()`) PASS;
    `world_sel_active_during_drag` PASS
- Shift-add `[10,11,12]`: **UNVERIFIED — not covered by this probe.** The atom forces
  `ev.shift_pressed = false` (`t_select_rect.gd:477`) while the production branch reads the
  real `Input.is_key_pressed(KEY_SHIFT)` (`:758`); a real-Shift drag needs a TEST-owner atom
  extension (diag §3.3), which is outside this builder's ownership. The Shift union code path
  itself was not modified by this fix.
- No full selftest/uitest run (COORD last, per governance).

## 4. PNG verdict

**UNVERIFIED image.** No PNG artifact was produced by this job: the `--screenshot` flag is the
menu-skip flag only and the atom asserts JSON + overlay rects, not pixels (consistent with
`RECHECK_S1.md:121-136` — no real-drag PNG exists). No second-agent read was available to this
worker; per instructions a PASS verdict requires one, so none is claimed.

## 5. Summary

**observed** — backup byte-identical (SHA256 match); diff is +14/−8 lines in the single owned
file; ticket 578 `bselrect-fix-probe1` ok/exit 0, PASS 23/23, SCRIPT ERROR 0, with `[10,11]` +
building-exclusion + no-click-regression + marquee-geometry all green. Shift-add and any pixel
visual remain UNVERIFIED. No parity claim of any kind.

*End of B-SELRECT-FIX.*
