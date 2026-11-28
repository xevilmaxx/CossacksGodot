# PICKSCREEN-RACE-01 — flaky click selection / marquee anchor

Date: 2026-11-27. Runner tickets 235-240. Port-internal fix; no donor value,
no approximation, no parity claim.

## 1. Owner report and reproduction

Owner: "click and selection starts from the wrong point of the pointer — it
starts from bottom right, needs top left"; confirmed window 1280×720 default
and the **marquee box anchor** as the affected interaction.

Windowed real-input capture (`t_select_rect_capture.gd`, ticket 235) showed the
marquee geometry itself was already correct:
`overlay_rect=[P:(395.262,273.5391), S:(521.8215,184.3488)]` (size = end−start),
and the pixel assertions `quad_visible/position/no_fill/colour/hidden` all
PASSED. The actual failure was `short_click_selects_single_unit: selected=[]
expected=[10]` — a plain click on a unit selected nothing.

## 2. Root cause

`_screen_to_world()` had a side effect: it wrote the shared `_pick_screen`
camera pixel. `_process()` calls it every frame for cursor hints
(`input_controller.gd:1846`), route redraw (`:600/:638`), build ghost (`:1766`)
and marquee corners (`:712-715`) using the **real OS mouse position**. A LMB
release could therefore pick a stale cursor pixel (observed `_pick_screen`
`(1073,637)` / `(850,601)` while the click pixel was `(512,337)`).

The test was timing-dependent: adding one print-only DEBUG line to the click
path made it pass (tickets 236/237/238), confirming a frame-order race rather
than a coordinate transform error. `ground_point(px)` itself is exact (0.00 m
error, `t_click_diag.gd` ticket 229).

## 3. Fix

`variant3d/scripts/input_controller.gd` (backup `.bak-PICKSCREEN-FIX`;
earlier diagnostic backup `.bak-PICKSCREEN-DIAG`):

- Added `_screen_to_world_pure(p)` — the projection, with **no** mutation of
  `_pick_screen`.
- `_screen_to_world(p)` is now the **event-only** wrapper that records the
  camera-space pixel before projecting; kept at the three real mouse-event
  call sites (`:1048` mouse button, `:1107` press anchor, `:1224` motion).
- All per-frame / read-only callers switched to the pure form: route redraw
  ×2, `_drag_world_rect` corners ×4, build ghost, cursor hint.

No donor constant, no threshold, no assertion changed. The test file's
`Color.to_string()` → `str()` fixes (`.bak-GODOT4STR`) were a mechanical Godot 4
API repair so the pre-existing capture atom could run at all; the added
`CLICK-DIAG` print in the test is print-only (`.bak-CLICKDIAG`).

## 4. Verification

Two identical windowed real-input capture runs (tickets 239/240), with the
temporary click-path diagnostic removed so no timing perturbation remained:

```
T_SELECT_RECT_CAPTURE RESULT: PASS 37/37
short_click_selects_single_unit - selected=[10] expected=[10]
```

Both runs 0 parse/script errors. Marquee pixel assertions still pass; the
drag/click coordinate mapping is unchanged for the donor-backed 64×64 QA map
at 1280×720.

## 5. Status

The reproducible click defect is fixed. The owner's exact visual impression
of a "bottom-right anchor" was not a separate transform bug in the drawn box;
the box pixels match the drag start. If it persists after this fix on the
owner's setup, capture the window/canvas transform and the drag pixel pair
before any further code change. Parity remains UNVERIFIED.
