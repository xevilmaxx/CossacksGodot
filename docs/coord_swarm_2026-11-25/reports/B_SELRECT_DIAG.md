---
id: B-SELRECT-DIAG
title: "B-SELRECT-DIAG — read-only diagnosis of 'units selection rect is wrong' (variant3d/ only)"
owner: B-SELRECT-DIAG (read-only micro-worker)
date: 2026-11-25
status: REPORT_ONLY__NO_CODE__NO_RUN__NO_GIT__NO_DONOR
scope: "Exactly one file written: this report. No .gd/.gdshader/config/fixture/result/PNG edit, no Godot launch, no queue job, no donor binary access, no gate or row PASS claim, no parity claim."
labels: [observed, derived, inferred, UNVERIFIED]
owner_report: "units selection rect is wrong"
path_key: "Bare .gd filenames are variant3d/scripts/ except 't_select_rect.gd' (variant3d/tests/); report names are docs/coord_swarm_2026-11-25/reports/; 'PROGRESS.md' is docs/coord_swarm_2026-11-25/PROGRESS.md."
parity_guard: "PORT APPROXIMATION only. No donor GPU A/B consulted; no donor-parity claim anywhere in this report."
---

# B-SELRECT-DIAG — selection-rectangle diagnosis

Label key: **observed** = read directly from a file; **derived** = arithmetic/control-flow
consequence of cited code; **inferred** = reasoned hypothesis, not directly demonstrated;
**UNVERIFIED** = cannot be established from available material.

## 0. Boundary

Read-only. All current-behaviour facts below are **observed** in `input_controller.gd`,
`picking3d.gd`, `camera3d.gd`, `data.gd`, `game.gd`, `world3d.gd`, `world3d_fx.gd`,
`config.gd`, `t_select_rect.gd` and the four governing reports at the paths in the
frontmatter. Nothing here proves or disproves the owner's visual observation by execution;
no donor binary was opened (`SEL_01_implementation.md:11,45-47`).

## 1. Exact current drag path (press -> motion -> release)

### 1.1 State

**observed** — `input_controller.gd:28-36`: `selected_ids`, `drag_start := Vector2.INF`,
`dragging := false`, SEL-01 `_sel_ground_start := Vector2.INF`, `_drag_current := Vector2.INF`,
`sel_rect_overlay`; epsilon/double-click helpers at `:214-224`.

**observed** — 3D mode is selected only by `bind_3d()` (`:172-185`), which creates
`picking3d` (`:177-183`) and the marquee overlay (`:185`, `:189-195`). 2D path is unchanged
(`:16-21`).

### 1.2 Press (LMB down)

**observed** — `input_controller.gd:648-733`: wheel and minimap branches return first
(`:654-680`). Non-drag mode branches (patrol `:684-692`, guard `:693-704`, build ghost
`:705-733`) return before setting drag state. The plain LMB-down path is `:734-738`:
`drag_start = mb.position` (screen px), `dragging = false`, `_drag_current = mb.position`,
`_sel_ground_start = INF`, `_hide_selection_rect()`. Buttons: **LMB only** for selection
(`:682`); RMB routes to `_right_order()` (`:800-801`). No modifier is read on press.

### 1.3 Motion (LMB held)

**observed** — `input_controller.gd:802-830`: minimap follow short-circuits (`:808-813`);
drag requires `drag_start != INF` and `button_mask & MOUSE_BUTTON_MASK_LEFT` (`:814`).
`:815` stores `_drag_current = event.position` (screen px); `:817` computes
`gp := _screen_to_world(event.position)` (sim ground metres); `:823` sets the epsilon
reference to `_screen_to_world(drag_start)` on the first move, else `_sel_ground_start`;
`:824-825` records `_sel_ground_start = gp` on that first move. The donor epsilon test is
`:826-828`: axis-wise `absf(gp.x-ref.x) > eps or absf(gp.y-ref.y) > eps` (gp.y is ground
Z, `:827`). Only that test sets `dragging = true` (`:829`). **derived** — there is no
screen-pixel drag threshold in the current path; `6 px` survives only as a probe constant
(`t_select_rect.gd:48,450,465`).

### 1.4 Release (LMB up)

**observed** — `input_controller.gd:739-799`. A release over the minimap cancels the drag
without selecting (`:672-680`). Otherwise `moved := dragging` (`:745`):

- **dragging branch `:746-773`**: `a := _screen_to_world(drag_start)` (`:747`),
  `bp := _screen_to_world(mb.position)` (`:748`), rect built at `:751` as
  `Rect2(min(a.x,bp.x), min(a.y,bp.y), absf(a.x-bp.x), absf(a.y-bp.y))`.
  **observed** — this is still exactly the **ground AABB of two screen-corner rays**;
  no four-corner or frustum construction exists. Entity predicate at `:753-757`: skip
  `e.dead or e.player != 0 or e.kind != "unit"`, then `rect.has_point(e.pos)` — a
  world-ground inside-rect test in **sim metres** (e.pos is sim; `picking3d.gd:121-122`),
  **not** a screen-space test (`PROGRESS.md:213`, S-25-06).
  Shift path `:758-772`: `Input.is_key_pressed(KEY_SHIFT)` (not `ev.shift_pressed`) unions
  the rect result with `get_selected()` by `int(e.id)` (`:765-771`); `_set_selection(arr)`
  at `:773`. Ctrl-remove is intentionally absent (`:760-762`).
- **click branch `:774-794`**: `_pick(pw,false)`, double-click window `_double_click_s()`
  (`:777`, helper `:222-224`), Shift-add `:786-790`, otherwise replace `:792`.
- **cleanup `:795-799`**: `drag_start/dragging/_sel_ground_start/_drag_current` reset,
  overlay hidden. `_set_selection` writes `e["selected"]` on by_id dicts and refreshes HUD
  (`:305-315`).

### 1.5 Screen rect -> world ground rect (functions and space)

**observed** — `_screen_to_world()` at `input_controller.gd:575-588` delegates in 3D to
`picking.ground_point(p)` (`:580-582`). `picking3d.gd:235-243` uses
`cam.project_ray_origin(screen)` / `cam.project_ray_normal(screen)` (`:241-242`) and
`_to_sim(_ray_heightfield(o,d))` (`:243`): analytic ray construction plus a 1 m-step
height-field march and 20-iteration bisection (`picking3d.gd:145-171`), then
`Vector2(w.x,w.z) + _world_to_sim` (`:121-122`). `_world_to_sim` is the half-map offset
(`:75-88`, constants `:34-43`).

**observed** — `camera.unproject_position()` is **not** used to build the drag rect. It is
used only for entity projection/radius in `picking3d.gd:198-207` (`_project_world`) and
`:214-221` (`_pixel_reach`), and for the click-pick depth path. The marquee explicitly
never projects `world.sel_rect` through `camera3d.world_to_px()`
(`input_controller.gd:1351-1352`, `camera3d.gd:288`).

### 1.6 Epsilon units

**observed** — `input_controller.gd:214-218` returns metres: `0.005` default, `0.25` when
`attack_ground_mode or guard_mode`; config getters `config.gd:425-429` keep the same
literal defaults. Applied to ground X/Z at `:826-828` — units are consistent (metres vs
metres). The `0.25` branch has no runtime exercise (`SEL_01_implementation.md:107-108`).

### 1.7 Marquee visual

**observed** — `input_controller.gd:85-100` (`SelectionRectPainter extends Node2D`,
`draw_rect(rect_px,..., false, width, false)`, colour/width from config at `:96-100` with
defaults `[1,1,0,1]` / `1.0`), `:103-126` (`SelectionRectOverlay extends CanvasLayer`,
layer 10, meta `sel_rect_overlay`, `set_selection_rect()` sets visibility from
`has_area()`), created at `:185,189-195`, driven at `:197-205`. `:1353-1355` draws
`Rect2(drag_start, cur).abs()` in **viewport/screen pixels** from `_drag_current` (or live
mouse); `:1356-1357` hides when not dragging. Separately, `:1332-1339` writes the **SIM-metre**
mirror `world.sel_rect` / `world.sel_active`. These are two different spaces by design.

### 1.8 Existing evidence (not a gate claim)

**observed** — S1 atom job 414: `PASS 23/23`, exit 0, `SCRIPT ERROR` 0, selected `[10,11]`,
building id 13 excluded by kind while inside the ground rect
(`S1_INPUT_FIX.md:156,164-191`; `RECHECK_S1.md:100-115`). Real-handler probe 329 added
Shift `[10,11,12]` (`SEL_01_implementation.md:76,90`). **UNVERIFIED** — no PNG of the
real drag exists (`RECHECK_S1.md:121-136,143-145`), and the shared result JSON carries
other jobs' provenance (`RECHECK_S1.md:151-158`). None of this is a donor-parity claim.

## 2. Every way the rect can be "wrong"

| # | Failure mode | Mechanism and citations | Label / current status |
|---:|---|---|---|
| 1 | **AABB of two corner rays under perspective tilt** | The selection rect is the AABB of only the press and release ground rays (`input_controller.gd:747-751`), but the visible marquee is the full screen rectangle (`:1353-1355`). Under the fixed `-32 deg` pitch (`camera3d.gd:262,278`; `data.gd:196`) a screen rectangle maps to a **ground trapezoid**, and the height-field march (`picking3d.gd:145-171`) makes the two endpoint ground heights/depths differ. The two-corner AABB can exclude units visibly inside the box and include units outside; inclusion is `rect.has_point(e.pos)` (`:756`). | **derived** geometric risk; **unmeasured** and flagged in `PROGRESS.md:181-185`. Leading hypothesis for the owner report, **not proven**. Donor inside-box predicate is **UNVERIFIED** (`SEL_01_implementation.md:104-105`). |
| 2 | Donor anchor mismatch | The epsilon reference anchor is the **first-move** ground point (`input_controller.gd:823-825`; donor `SEL_01_implementation.md:37`), but the selection rect starts at the **press pixel's** ground point (`:747`). Under motion between press and first move, the two anchors differ. | **derived** divergence; magnitude **UNVERIFIED**. |
| 3 | Half-map offset regression | `picking3d.gd:75-108` sets `_world_to_sim` to half the map (`:80-88`) and returns early when the camera has `jump_to_world` (`:87-88`; `camera3d.gd:444`). A legacy/SIM camera without that method would run the calibration at `:90-108`, which historically zeroed the offset and put ground points 160 m short (`picking3d.gd:65-74`). | **observed** guard active with the current camera; regression in the owner's session **UNVERIFIED**. |
| 4 | Epsilon in wrong units / config override | Metres applied to ground X/Z (`input_controller.gd:214-218,826-828`; `config.gd:425-429`). Wrong-unit regressions would be applying it to screen pixels or to `e.pos.y` without the ground-Z mapping; an active config could override the default literals (`:215-218`). | **observed** units correct now; regression **inferred**, override value **UNVERIFIED**. |
| 5 | Marquee drawn in wrong space / stretch mismatch | Screen-px overlay (`input_controller.gd:85-126,1353-1355`) vs SIM-metre mirror (`:1336`); `camera3d.world_to_px()` expects centred metres (`camera3d.gd:288`) and is deliberately not used (`:1351-1352`). Root-window event px vs camera-viewport px were measured ×20 apart headless and identity at 1280x720 windowed (`S1_INPUT_FIX.md:80-108`); other window sizes can diverge. | **observed** design; at non-1280x720 sizes a mismatch is **inferred**, not measured. |
| 6 | Selection-mirror / ring staleness | `_set_selection` writes `e["selected"]` on by_id dicts (`input_controller.gd:305-315`); by_id holds the same entity dicts (`game.gd:2363,5937`); `game.get_selected()` filters that flag (`game.gd:2925-2930`); `world3d.gd:297-319` mirrors ids each sync (`:682-688`); fx rings use set semantics (`world3d_fx.gd:613-657`) and the aura reads the mirror (`world3d.gd:535-549`). | **observed** consistent chain; staleness only if by_id/entities diverge or sync is skipped — **UNVERIFIED**. |
| 7 | Composition / kind filter | Rect branch selects only player-0 `kind == "unit"` (`input_controller.gd:754`); building exclusion is asserted (`t_select_rect.gd:558,562`). Donor composition filters are **UNVERIFIED** (`SEL_01_implementation.md:129-131`). If the owner expects buildings via marquee, that is a design divergence, not a regression. | **observed** code; owner expectation **UNVERIFIED**. |
| 8 | Release over minimap cancels | LMB release inside the minimap rect clears drag state and hides the overlay without selecting (`input_controller.gd:672-680`). | **observed** edge case. |
| 9 | Mode early-returns skip drag setup | Patrol/guard/build presses return before `:734-738` (`input_controller.gd:684-733`); a world drag in those modes never starts. Stale state is cleared on release (`:795-799`). | **observed**; no stale-state case demonstrated. |
| 10 | Click-vs-drag split | `moved := dragging` (`input_controller.gd:745`) makes a short drag below the metre epsilon a click, not a box; donor semantics by design (`SEL_01_implementation.md:25-26,59`). A user expecting the old 6 px threshold will perceive "wrong". | **observed**; expectation **UNVERIFIED**. |

## 3. Minimal fix proposal

### 3.1 ONE-builder ownership

**`input_controller.gd` only.** It owns the drag state (`:28-36`), both rect construction
sites (`:747-751`, `:1334-1336`) and the overlay (`:85-126,189-205,1353-1355`).
`picking3d.gd` (ray/ground projection) and `world3d_fx.gd` (rings) are **not** to be
edited; `world3d.gd`, `game.gd`, `config.gd` and `t_select_rect.gd` are also out of this
fix's scope. No second implementation builder.

### 3.2 Change set (for hypothesis #1)

**proposed, not proven** — add one helper beside `_screen_to_world()` at
`input_controller.gd:575-588`, e.g. `_drag_world_rect(a_px: Vector2, b_px: Vector2) -> Rect2`,
which calls `_screen_to_world()` for all four screen-rectangle corners
(`a_px`, `b_px`, `Vector2(a_px.x,b_px.y)`, `Vector2(b_px.x,a_px.y)`) and returns their
sim-ground AABB using the same `minf/absf` form as `:751`. Then:

- replace `input_controller.gd:747-751` with `var rect := _drag_world_rect(drag_start, mb.position)`;
- replace the mirror construction at `input_controller.gd:1334-1336` with the same helper,
  using `_drag_current` (or live mouse) as the second pixel so mirror and selection agree;
- leave the marquee at `input_controller.gd:1353-1355` in screen pixels;
- leave Shift union (`:758-772`), epsilon test (`:826-828`), click branch (`:774-794`) and
  entity filter (`:754-757`) unchanged.

**derived** — this keeps a **world-ground** rect (S-25-06, `PROGRESS.md:213`), introduces
no screen-space `select_in_rect()`, and removes the two-corner under-coverage at `:747-751`
without touching donor-cited constants. It does **not** claim donor parity: the native
inside-box predicate is still **UNVERIFIED** (`SEL_01_implementation.md:104-105`).

**inferred alternative** — if COORD/owner confirms donor two-point semantics, the cheaper
change is to start the rect from `_sel_ground_start` at `input_controller.gd:747`
(donor first-move anchor, `SEL_01_implementation.md:37`) instead of `drag_start`; this fixes
hypothesis #2 but not the trapezoid error of #1. That choice needs a decision; donor
predicate remains **UNVERIFIED**.

### 3.3 Real-drag windowed probe (extend the S1 atom pattern)

**proposed** — extend `variant3d/tests/t_select_rect.gd` (atom owner = TEST builder, not the
fix builder): keep its windowed 1280x720 real `Input.parse_input_event` setup and stretch
transform (`t_select_rect.gd:470-488`; `S1_INPUT_FIX.md:143-151,184-191`) and its fixed
camera pose (`S1_INPUT_FIX.md:118-123`). Add:

1. a second full press -> motion -> release sequence with a **real Shift key state**
   injected through `Input` — the production branch reads `Input.is_key_pressed(KEY_SHIFT)`
   (`input_controller.gd:758`), while the atom currently forces `ev.shift_pressed = false`
   (`t_select_rect.gd:477`), so a key event (as in probe 329,
   `SEL_01_implementation.md:76`) is required;
2. assertions after the existing selection checks (`t_select_rect.gd:553-564`) for
   selected ids `[10,11]` on plain drag, building id 13 excluded by kind while inside the
   rect, and union `[10,11,12]` for the Shift drag;
3. an alignment assertion comparing the ground rect from the new helper against the
   screen-marquee endpoints `p0/p1` recorded at `t_select_rect.gd:433-435,452-465`, so a
   two-corner-vs-four-corner regression is visible.

**observed** — the plain `[10,11]` / building-exclusion claims already have atom evidence
(`S1_INPUT_FIX.md:164-176`; `RECHECK_S1.md:107`); Shift is declared but not asserted in
this atom (`t_select_rect.gd:237`; `RECHECK_S1.md:180`). **No gate/row PASS claim is made
here**: this is a probe design only. No PNG or donor visual comparison is proposed or
claimed; the existing capture gap is **UNVERIFIED** (`RECHECK_S1.md:121-136,143-145`).

## 4. Summary

**observed** — current drag is LMB-only, screen px -> two ground rays -> sim-ground AABB
(`input_controller.gd:734-751`), inclusion `rect.has_point(e.pos)` for player-0 units
(`:753-757`), Shift union from real `Input` key state (`:758-772`), screen-px yellow marquee
(`:85-126,1353-1355`) and a separate SIM-metre mirror (`:1332-1339`). Epsilon is metres
(`:214-218,826-828`), offset guard is active (`picking3d.gd:87-88`), mirror chain is
consistent (`world3d.gd:297-319`; `world3d_fx.gd:613-657`).

**derived/inferred** — the only unmeasured, geometry-level candidate that directly explains
"units selection rect is wrong" is the two-corner ground AABB under `-32 deg` perspective
and height-field relief (`input_controller.gd:747-751` vs `:1353-1355`;
`camera3d.gd:262,278`; `picking3d.gd:145-171`), with the first-move/press anchor mismatch
as a smaller companion. **UNVERIFIED** — which cause the owner saw; no fresh run, no PNG,
no donor A/B, and no parity claim of any kind.

*End of B-SELRECT-DIAG.*
