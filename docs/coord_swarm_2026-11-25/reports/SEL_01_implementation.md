---
id: SEL-01
title: "SEL-01 — 3D drag rectangle: donor-faithful implementation in variant3d/scripts/input_controller.gd"
owner: SEL-01 (exclusive implementation builder)
date: 2026-11-25
status: IMPLEMENTED__VALIDATED__S1_ATOM_BLOCKED_BY_TEST_PARSE_ERRORS
scope: "Exactly two repo files touched: variant3d/scripts/input_controller.gd (the only game file edited) and this report. Back up copy outside the repo tree: inbox/backup/input_controller.gd.bak-SEL01. Validation probes were authored in the approved Temp folder only, never in the repo."
owns:
  - "variant3d/scripts/input_controller.gd"
  - "docs/coord_swarm_2026-11-25/reports/SEL_01_implementation.md"
donor: "C:\\Games\\Cossacks 3 — read-only source/config reports consumed; no donor binary copied or executed by this builder."
labels: [PORT_APPROXIMATION, DONOR_CITED, REAL_INPUT_PROBE, UNVERIFIED_NATIVE]
gates:
  selftest: "29/29 green (runner ticket 337, id sel01-selftest-final)"
  uitest: "17/17 green (runner ticket 318, id sel01-uitest)"
  external_probe: "12/12 green (runner ticket 329, id sel01-probe-shift)"
---

# SEL-01 — 3D drag rectangle implementation

## Goal

Make the 3D drag rectangle work donor-faithfully **without editing any file other than
`variant3d/scripts/input_controller.gd`**: draw the missing marquee in viewport pixels
(yellow 1 px solid, no fill), replace the port's 6 screen-pixel drag threshold with the
donor's world-ground epsilon, make Shift additive (`spmAdd`), set the donor double-click
window, keep the click-pick branch and all `game.cmd_*` calls unchanged, and retain the
world ground rect (arbitration S-25-06: **no** screen-space `select_in_rect()` in
`picking3d.gd`).

## Donor citations (all read from the landed reports, not re-derived)

| Implemented value | Donor literal | Citation |
|---|---|---|
| Drag threshold `0.005` world metre, axis-wise X/Z | `var epsilon : Float = 0.005;` + `if (Abs(x-prevSelX)>epsilon) or (Abs(z-prevSelZ)>epsilon)` | `data\gui\menu.inc\onmousemove.inc:32`, `:152` — DSEL-01 claim 1/2, RV-SEL-01 Conflict 1 |
| `0.25` in attack-point / guard mode | `if (gbool_gui_attackpointmode) or (gbool_gui_guardmode) then epsilon := 0.25;` | `onmousemove.inc:33-34` — DSEL-01 constants table |
| Ground anchor recorded on the first LMB-held MOVE | `gbool_gui_isselectionstarted := true; prevSelX/ Z := x/z` | `onmousemove.inc:141-147` — DSEL-01 claim 3 |
| Shift = `spmAdd`, otherwise `spmRunTime`; Ctrl branch disabled | `GameManagerStartSelection('spmAdd')` / `('spmRunTime')` | `onmousemove.inc:150-165`, commented `//spmRemove` at `:159-161` — DSEL-01 claim 4/5 |
| LMB-up clears selection state | `gbool_gui_isselectionstarted := false; GameManagerCancelSelection` | `onmousedown.inc:364-390` — DSEL-01 claim 6 |
| Outline `RGBA(1,1,0,1)`, `LinePattern=65535`, `LineWidth=1`, `AntiAliased=False` | selection brush struct | `data\brushes\selection.cfg:3-14`, bound at `data\resources\resource.lib:47` — DSEL-01 claim 18; RV-SEL-01 §"Visual (authoritative, exact)" |
| Double-click window `0.5 s` | `KeyDoubleDelay = 0.5` | `data\gui\menu.cfg:33` — DSEL-01 claim 7 / constants table |
| World ground rect is donor truth (not a screen rect) | `GetCurrentMouseWorldCoord` + `GameManagerStartSelection` | `onmousemove.inc:66-69,135-167` — S-25-06 arbitration in `PLAN_IMPLEMENTATION.md:42-46`; RV-SEL-01 §"Implications" |

Every constant above carries its `path:line` in a code comment in `input_controller.gd`.
No donor file was executed or copied. Native brush rasterisation and the native
inside-box predicate remain **UNVERIFIED** (RV-SEL-01 §"Intent-only / engine-side"), so
the overlay is explicitly labelled a **PORT APPROXIMATION** of the donor visual in code.

## Backup

`copy variant3d\scripts\input_controller.gd inbox\backup\input_controller.gd.bak-SEL01`
— created **before** the first edit; 51,429 bytes; retained.

## Before → after diff summary (line numbers: before from V3D-01 / backup, after from final file)

| # | Before | After | Change |
|---|---|---|---|
| 1 | no overlay node anywhere; `world3d.gd:126-127` only stored `sel_rect`/`sel_active`; V3D-01 break point 1 (`:248`) | `input_controller.gd:85-93` `SelectionRectPainter extends Node2D` with `draw_rect(rect, Color(1,1,0,1), false, 1.0, false)`; `:95-117` `SelectionRectOverlay extends CanvasLayer` (meta `sel_rect_overlay`, `get_selection_rect()`, `set_selection_rect()`); `:181-197` helpers; `:177` created from `bind_3d()` | Marquee drawn from authoritative screen pixels. 1 px solid yellow, **no fill**, no AA. CanvasLayer + Node2D have no `mouse_filter` and consume no input. |
| 2 | `:613` `moved := (mb.position - drag_start).length() > 6.0`; `:662` motion threshold 6 px | `:703` `var moved := dragging`; `:772-788` LMB-held motion tests axis-wise `absf(gp.x-ref.x)>eps or absf(gp.y-ref.y)>eps` on `picking.ground_point()`; `:203-204` epsilon helper (`0.005`, `0.25` when `attack_ground_mode or guard_mode`) | Screen-pixel threshold replaced by donor world epsilon. `drag_start` still set on press (click branch and `drag_start_from_real_event` unchanged); the *ground anchor* is recorded on the first LMB-held move (`:782-783`), donor `onmousemove.inc:141-147`. |
| 3 | `:624` `_set_selection(arr)` always replaced | `:716-733` Shift unions rect result with `get_selected()` by id, then one `_set_selection(arr)`; no Ctrl-remove | Donor `spmAdd` / no-Shift `spmRunTime`; Ctrl branch left commented-out in donor (`:159-161`) is not added. |
| 4 | `:628` double-click `< 0.35` | `:735` `< 0.5` (citation at `:201-202`) | Donor `KeyDoubleDelay`. |
| 5 | `:1164-1172` `_process` wrote only the SIM-metre `world.sel_rect` mirror | `:1307-1315` additionally refreshes the overlay from `Rect2(drag_start, last_mouse).abs()`; `:695-696,753-757` and minimap-release early-out `:630-638` clear anchor/overlay on release | Mirror kept unchanged; overlay hidden and rect emptied on release and while not dragging. No `camera3d.world_to_px()` projection of `sel_rect` (SIM vs centred metres trap). |
| 6 | `:619-623` entity loop, `:626-645` click branch, all `game.cmd_*` calls | entity loop unchanged; click branch unchanged except the `0.5` literal; no `cmd_*` call added or altered | S-25-06 upheld: world ground rect retained; **no** `picking3d.gd` edit. |

## Validation — variant runner only, unique ids

| Ticket / id | Command form | Result |
|---|---|---|
| 314 `sel01-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | **failed** — my first draft used `Rect2.is_empty()`; Godot 4.7.2 parse error at `input_controller.gd:89,115`. Fixed to `Rect2.has_area()` before any further run. |
| 316 `sel01-selftest-2` | same | exit 1, 26/29 at that instant (`wall`, `shell`, `farm_cap` false). Concurrent CFG-01/CFG-02 jobs 315/317 also exited 1 while changing map defaults (240 / mediterranean / hills); no SEL-01 code path touches those steps. |
| 318 `sel01-uitest` | `--headless --path variant3d -- --ui-test variant3d/uitest.json` | **ok**, `uitest.json` `passed: true`, **17/17**. |
| 320 `sel01-tselect-win` | windowed, `--script res://tests/t_select_rect.gd` + fixture + screenshot | **failed before boot**: two pre-existing parse errors in the read-only S1 atom — `t_select_rect.gd:399` `var via_helper := _cam.world_to_px(...)` cannot infer from an untyped Variant, and `:487` `got.is_empty()` on `Rect2`. Also the atom's own `_initialize()` headless guard (`:262-263`) rejects a windowed run by design. No pass/FAIL of the drag logic was observed. |
| 323 `sel01-probe-smoke` | `--script <Temp>/sel01_probe_smoke.gd` | ok — absolute Temp path is loadable by Godot via the runner. |
| 324 `sel01-probe-real` | Temp probe, real 64² boot, real handler events | failed 7/11 — probe artifact: headless `canvas_items` stretch (window 64×36 → viewport 1280×720) scaled `Input.parse_input_event` mouse positions ×20. No repo file was edited. |
| 326 `sel01-probe-real-2` | same probe, events delivered directly to `C3Input._unhandled_input` (still the real handler) | **ok, 11/11**: drag start from event, world epsilon crossed (24.57 m), `dragging` + `world.sel_active` mirror set, overlay rect exactly `Rect2(p0,p1).abs()` and visible during drag, hidden/empty after release, selected ids `[10,11]`, player-0 building excluded by kind, short click selects `[10]`. |
| 329 `sel01-probe-shift` | same + real `KEY_SHIFT` Input state | **ok, 12/12** — adds `shift_drag_is_additive` → `[10,11,12]`. |
| 337 `sel01-selftest-final` | same as 314, after concurrent CFG work settled | **ok**, `selftest.json` `passed: true`, **29/29**. |
| 346 `sel01-probe-final` | repeat of the 329 probe against the later shared tree | exit 1 with empty stdout/stderr (Godot did not emit a log); the queue was busy with other agents' jobs (now_serving 351 at next check). No new evidence either way; 329 remains the last valid probe run. |

The Temp probe files are `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\sel01_probe*.gd`
and their result JSONs (`sel01_probe_result2.json`, `sel01_probe_result3.json`). They are
outside the repo tree and are not part of the deliverable. No repo test was modified.

## Acceptance criteria

| Criterion | Verdict | Evidence |
|---|---|---|
| (a) yellow `(1,1,0,1)` 1 px solid outline, no fill, viewport px, no input consumption | **IMPLEMENTED / structurally verified** — visual is a labelled PORT APPROXIMATION | `input_controller.gd:85-117,181-196,1307-1315`; probe 326/329 exact rect and visibility |
| (b) 6 px screen threshold → `0.005` m world axis-wise on ground X/Z (`0.25` attack/guard) | **PASS** (default branch runtime-verified; `0.25` branch present, not runtime-exercised) | `:203-204,772-788`; probe world delta 24.575 m > 0.005 |
| (c) Shift = add / no Shift = replace; no Ctrl-remove in drag | **PASS** | `:716-733`; probe 329 `[10,11,12]`; replace case probe 326 `[10,11]` |
| (d) double-click `0.35` → `0.5` s | **IMPLEMENTED** (no dedicated timing assertion in the green gates) | `:735`, citation at `:201-202` |
| (e) click-pick branch byte-identical, no `game.cmd_*` change | **PASS** except the mandated `0.5` literal | probe 326/329 short-click `[10]`; diff reviewed |
| World ground rect retained; no `picking3d.gd` screen-space selector | **PASS** | no other repo file edited; S-25-06 upheld |
| `world.sel_rect` / `sel_active` mirror kept | **PASS** | probe 326 `world_sel_active_mirror` |
| Overlay cleared on release and when not dragging | **PASS** | probe 326 `overlay_hidden_after_release` |
| selftest 29/29 + uitest 17/17 | **PASS** | tickets 337 and 318 |

## UNVERIFIED / honest limits

- **Native selection brush rasterisation** — `selection.cfg` values are byte-confirmed in
  donor, but that the native engine actually paints them during a live drag was not
  observed (RV-SEL-01 §"Intent-only", item 4). The screen overlay is a **PORT
  APPROXIMATION**, not donor parity.
- **Native inside-box predicate** (centre / AABB / frustum / `GetGameObjectSelectionSizeByHandle`)
  — still UNVERIFIED; the port keeps its SIM-ground `rect.has_point(e.pos)` test unchanged.
- **Donor A/B** — no donor binary run, no donor screenshot comparison; no claim of visual parity.
- **`0.25 m` attack/guard epsilon** — code branch exists (`attack_ground_mode`, `guard_mode`),
  but no runtime probe exercised it.
- **Double-click timing** — literal changed to `0.5`, but no gate asserts the elapsed window.
- **S1 atom (`variant3d/tests/t_select_rect.gd`)** — cannot run: two parse errors in that
  read-only file (`:399`, `:487`) plus a headless-only guard and a headless stretch-scaling
  issue in its `Input.parse_input_event` injection (observed in probe 324). **Do not weaken
  it**; TEST-S1/COORD owns the repair. This builder did not edit it.
- **Viewport coordinates in the probe** — the 64² boot with `--screenshot` moves the camera
  into a screenshot `SubViewport` (`main.gd:1180-1193`), so projected `p0` is off-screen
  (≈−1588 px). The overlay still tracked the delivered events exactly; this is a harness
  artifact, not a rectangle bug.

## Open questions

1. Who repairs `t_select_rect.gd` parse errors (`:399` untyped `via_helper`, `:487`
   `Rect2.is_empty()`) and its headless stretch-scaled input injection? (TEST-S1 / COORD.)
2. Should the S1 atom deliver events directly to `_unhandled_input()` (as the Temp probe
   did) to avoid the canvas stretch transform, or compensate the coordinates?
3. Should a later ticket add a windowed capture A/B of the yellow outline against donor
   screenshots? Not possible under this charter.
4. Does the donor's `0.25` attack/guard threshold apply to left-drag in this port at all,
   given those modes here are consumed by right-click/orders? Left as donor-literal parity.
5. Should donor composition filters (land/water/building/guard/squad, `onselection.inc:12-16,
   43-53,60-99`) get their own ticket? Out of SEL-01 scope; the existing kind/player filter
   was deliberately left unchanged.

## Summary

Implemented SEL-01 entirely inside `variant3d/scripts/input_controller.gd`: a viewport-pixel
yellow 1 px solid/no-fill marquee overlay created in `bind_3d()` and refreshed from
`_process()` using the authoritative screen pixels; donor `0.005 m` (and `0.25 m` attack/guard)
axis-wise world-ground epsilon with the anchor recorded on the first LMB-held move; Shift
union (`spmAdd`) on the drag branch; `0.5 s` double-click; unchanged click-pick branch,
`game.cmd_*` calls, entity loop and world ground rect. Gates are green (selftest 29/29,
uitest 17/17) and an external real-handler probe passed 12/12 including exact marquee rect,
release clearing, exact selected-id set and Shift-add. The authored S1 atom is **blocked by
its own pre-existing parse errors** and was not modified. Native brush rasterisation, the
inside-box predicate and donor visual parity remain UNVERIFIED; the overlay is labelled a
PORT APPROXIMATION. **No other repo file was edited by this builder** — no `world3d.gd`,
`picking3d.gd`, `camera3d.gd`, `main.gd`, `hud.gd`, config/data/menu file, test, asset,
scene, shader or git state.
