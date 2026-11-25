---
id: G01
title: "G01 — authored D03's selection-marquee windowed capture atom (NEW file only)"
owner: G01 (WAVE-G implementation worker)
date: 2026-11-25
status: AUTHORED__NOT_RUN__NO_RUNNER_JOB__NO_GODOT__NO_PNG
scope: "Exactly two files: variant3d/tests/t_select_rect_capture.gd (NEW) and this report. No runner job, no Godot launch, no PNG, no result JSON, no edit to any other file."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION — internal visual evidence only. No donor GPU A/B frame exists; donor parity stays UNVERIFIED (CHARTER §3, D03 §0/§9)."
---

# G01 — D03 capture atom, authored

## 0. Boundary and label key

I authored **only** `variant3d/tests/t_select_rect_capture.gd` (new) and this report.
Per WAVE-G charter line 31, **G04 is the sole runner owner**: I did not run Godot,
did not submit a runner job, and did not create any PNG or result JSON. The atom is
**static-parsed by inspection only**; it has never been executed. Its verdict is
therefore **UNVERIFIED (NOT RUN)**, never a PASS.

Labels: **observed** = read directly from a cited file/line; **derived** = arithmetic
or control-flow consequence; **inferred** = reasoned but not directly observed;
**UNVERIFIED** = cannot be established without a real windowed run.

---

## 1. What was delivered (OBSERVED — read the new file)

`variant3d/tests/t_select_rect_capture.gd` — 1056 lines, `extends SceneTree`, loadable
as `res://tests/t_select_rect_capture.gd`. It implements D03 §4 "verbatim in spirit":

| D03 requirement | Implementation site in the new atom |
|---|---|
| Real 64² 3D boot, staged `_process`, `call_deferred("quit")` only | `_initialize()` headless guard + args; `_goto()`/`_process()` stage machine 0…10 |
| `--config` + `--screenshot` (menu-skip flag only) | `_arg_value()`, `_resolve_config()`, `_initialize()` |
| 4 peasants `[10..13]` + 1 building `[14]`, all in view | `_configure()` spawn table (D03 §4.2 SIM offsets); `all_entities_projected_in_viewport` check |
| Real `Input.parse_input_event` drag, both thresholds retained | `_send_mouse_button/_send_mouse_motion`, `drag_start_from_real_event`, `drag_crosses_port_6px_threshold`, `drag_crosses_donor_0.005m_epsilon` |
| THREE windowed PNGs before/during/after | stages 1–2, 4–5, 6–7 → `d03_selquad_before|during|after.png` |
| Pixel assertions: visible / position / colour / no-fill / hidden | `_assert_pixels()` → `quad_visible_during_pixels`, `quad_position_pixels`, `quad_colour_pixels`, `quad_no_fill_pixels`, `quad_hidden_after_pixels` |
| Logic-vs-raster cross-check | `overlay_rect_matches_pixels` (live overlay Rect2 + visible at both phases) |
| Anti-donor-bug control | `selected_ids_exact == [10,11]`, `unit12_not_selected`, `unit13_not_selected`, `building_not_selected`, `building_inside_rect_but_excluded_by_kind`, `cmd_counter_zero_after_drag` |
| Headless → `SKIP_CAPTURE`, `passed=false`, quit 1 | `_initialize()` first branch → `_abort()` → `_finish()` with `capture_path` = literal `SKIP_CAPTURE ...` |
| Result JSON with paths, samples, colours, parent | `_finish()` writes `res://tests/results/t_select_rect_capture.json` |

**OBSERVED** — all 23 `check()` sites of `t_select_rect.gd` are retained (same names,
same 6.0 px / 0.005 m thresholds, same `expected_pre_fix_failure=true` on both
overlay assertions). New file has 36 check sites: 23 retained + 13 additive
(`boot_and_setup` is the retained abort site). No marker, threshold or verdict
rule was lowered or deleted (CHARTER §3; D03 §8 item 12).

**DERIVED** — the one changed expectation is `test_entities_exact`: original
`[10,11,12,13]` → `[10,11,12,13,14]`, because D03 §4.2 explicitly adds a fifth
entity (the player-0 building). This is an **increase** in scene content and a
stronger exact-set assertion, not a weakening. Added `unit13_not_selected` for
the new fourth peasant.

---

## 2. The two critical traps — how each is closed

### Trap A — overlay lives in the wrong viewport (D03 §3.1)

**OBSERVED** — `main.gd:1240-1253` reparents only `world` and `camera` into
`Screenshot3DViewport`; `sel_rect_overlay` is created as a child of `input_ctl`
(`input_controller.gd:197-203`) and stays in the root viewport. A plain
`capture_view3d.get_texture().get_image()` therefore cannot show the marquee.

**IMPLEMENTED** — `_configure()` takes the **live** node
`_ictl.get("sel_rect_overlay")`, removes it from its current parent and adds it
to `_main.capture_view3d` (harness-only, no game-code edit). It asserts
`_ov.get_parent() == _main.capture_view3d` via
`check("overlay_reparented_into_capture_view3d", ...)`, and records
`overlay_parent`, `overlay_parent_is_capture_view3d`, `overlay_name` in the JSON
both inside `measured` and at top level. Both viewports are asserted 1280×720
(`windowed_capture_geometry`) before reparenting.

**INFERRED** — a `CanvasLayer` with `layer = 10` under a `SubViewport` composites
above that viewport's 3D pass, and `CanvasLayer`/`Node2D` have no `mouse_filter`,
so input routing is unchanged (D03 §9 open risk retained). The atom re-verifies
`drag_start_from_real_event` after reparenting; if routing did change, that
check fails — it is not silently worked around.

### Trap B — root-texture readback is blank under gl_compatibility (D03 §3.2)

**OBSERVED** — `main.gd:1235-1238,1861-1863` documents the blank window backbuffer
and the deliberate switch to `capture_view3d`'s texture.

**IMPLEMENTED** — `_capture_now()` reads **only**
`(capture_view3d as SubViewport).get_texture().get_image()`. There is no
`root.get_texture()` call anywhere in the file. A null/empty image, wrong size,
corner alpha < 0.5, or `main._is_blank(img)` produces `ok=false` with a recorded
`reason` and **no** CPU fallback. All three `capture_*_ok` checks then FAIL;
pixel checks are gated on three valid images and cannot pass vacuously.

### Trap C / Trap D (also closed)

**OBSERVED** — main's saver fires on a frame counter and quits (`main.gd:1730-1732,1930`).
**IMPLEMENTED** — `screenshot_frames=1000000`, `screenshot_done=true`; the atom
saves PNGs itself through main's proven `_write_bytes` helper (invoked dynamically
via `call`, because `_main` is statically typed `Node`).

**OBSERVED** — headless root 64×64 vs projection 1280×720 breaks
`Input.parse_input_event` (`CAM_RV_01:159-166`, `SEL-01` probe 324).
**IMPLEMENTED** — literal `SKIP_CAPTURE`, `passed=false`, quit 1 before any boot;
no fake PASS path exists.

---

## 3. Pixel assertion detail (D03 §4.4, not weakened)

`_assert_pixels()` builds `expected := Rect2(_p0, _p1 - _p0).abs()` and samples
four edge midpoints, all four corners and the rect centre of the DURING image.
`is_marquee` is D03's exact default predicate `r>=0.85, g>=0.85, b<=0.25,
a>=0.9`, parameterised by the colour actually returned by
`ConfigScript.active.feature_selection_marquee_color()`; width comes from
`feature_selection_marquee_width_px()`. Both are recorded in JSON, together with
`marquee_override_declared` (true only if the values differ from the documented
`[1,1,0,1]` / `1` defaults at `config.gd:50-51,431-436`).

| Check | Predicate | Source of threshold |
|---|---|---|
| `quad_visible_during_pixels` | ≥3/4 edge midpoints **and** ≥2/4 corners yellow | D03 §4.4 table |
| `quad_position_pixels` | every yellow hit inside `expected.grow(2)`; zero yellow pixels outside `expected.grow(width+2)` on rows `top/centre/bottom` | D03 §4.4 table |
| `quad_no_fill_pixels` | centre not yellow **and** ≤8/255 per channel vs BASELINE | D03 §4.4 table, `SEL_01_implementation.md:58,88` |
| `quad_colour_pixels` | every yellow hit ≤16/255 per channel vs configured RGBA; at least one hit | D03 §4.4 table |
| `quad_hidden_after_pixels` | every DURING yellow coordinate not yellow in AFTER **and** ≤8/255 vs BASELINE | D03 §4.4 table |
| `overlay_rect_matches_pixels` | live overlay `get_selection_rect()` ≈ `expected` + visible during; invisible + no area after | D03 §4.4 table |

**DERIVED implementation decisions (documented, not assertion changes):**

1. **D03 §4.4 prose typo.** D03 wrote `expected := Rect2(_p0,_p1).abs()`, which
   treats `p1` as a *size*, contradicting both its own edge-midpoint formulas
   (which use `p0`/`p1` as corners) and COORD's `t_select_rect.gd:525` fix. I used
   `Rect2(_p0, _p1 - _p0).abs()`. This preserves the intended corner semantics and
   matches the game's `Rect2(drag_start, cur - start).abs()`
   (`input_controller.gd:1529`). Using the prose literally would guarantee a
   false FAIL of `overlay_rect_matches_pixels`.
2. **Awaits → stage frames.** D03's `_capture()` awaited
   `RenderingServer.frame_post_draw` twice. `_process()` must stay synchronous:
   `SceneTree._process() -> bool` returning a coroutine object would be read as
   "quit". The two awaits are implemented as **two `_process` stage frames**
   between `UPDATE_ONCE` and read-back — same fresh-render guarantee, no awaits.
3. **±1 neighbourhood for probes.** A 1 px solid outline is centred on the rect
   boundary, so each probe accepts a hit in a 3×3 window around the ideal point.
   The line must still lie within 1 px of the expected edge; this is sampling
   tolerance, not a lowered predicate, and `grow(2)`/`grow(width+2)` still bound
   every accepted hit.
4. **PNG paths derived from `--screenshot`** — the three files are written beside
   the menu-skip flag path (`d03_selquad_before|during|after.png`) using main's
   `_write_bytes` (which creates the directory). G04's D03 §5 command passes a
   unique Temp folder, so this yields the intended unique filenames and avoids
   hard-coding a machine-specific absolute path. Recorded as `capture_dir` and
   per-capture `path` in JSON.

---

## 4. Static review performed (OBSERVED — by inspection, no Godot)

- `extends SceneTree`, `class CmdSpy extends C3Game` (global `class_name C3Game` at
  `game.gd:4`), `preload` paths `res://scripts/data.gd` / `res://scripts/config.gd`
  mirror the working atom.
- Typed declarations (`Array[Dictionary]`, `Image`, `Rect2`, `ViewportTexture`,
  `Vector2i`) and ternaries reviewed for GDScript 4 syntax; Variant-returning
  `call()` results are cast (`as Rect2`, `as Dictionary`, `str(...)`, `bool(...)`).
- main.gd-only helpers are invoked as `_main.call("_is_blank"/"_write_bytes", ...)`
  rather than dotted members, since `_main` is statically typed `Node`.
- Stage machine terminates exactly once via `_finish()` → `call_deferred("quit", ...)`.
- **No execution was attempted, so a runtime parse/verdict is UNVERIFIED.** The
  authoritative check is G04's windowed runner run and `scan-stderr`.

---

## 5. Open risks and UNVERIFIED items (must not be read as PASS)

- **UNVERIFIED** — whether reparenting the CanvasLayer into `capture_view3d`
  composites the marquee identically to the window (D03 §9). That is exactly what
  `quad_visible_during_pixels` tests; it is not assumed here.
- **UNVERIFIED** — whether the full-row stray scan meets unrelated yellow UI
  pixels in the BASELINE/DURING frames. The assertion is kept strict per D03; a
  failure must be triaged against the recorded `stray_yellow` coordinates and
  `row_yellow_counts`, never by relaxing the check.
- **UNVERIFIED** — donor brush rasterisation / native inside-box predicate; this
  atom is a PORT APPROXIMATION of the donor visual, not donor parity.
- **UNVERIFIED** — the atom has not been run; all 36 checks have no runtime result.

## 6. Hand-off to G04 (not executed by G01)

Use D03 §5 verbatim with a fresh id (e.g. `g01-selquad-cap1`), **no `--headless`**,
after `godot_runner.py status` shows the lock free. Accept only if the envelope is
`status=ok`, `exit=0`, argv has no `--headless`, `run_mode=windowed_real_input`,
`headless=false`, viewports `[1280,720]`, `event_coord_scale=[1,1]`,
`overlay_parent_is_capture_view3d=true`, all three PNGs exist and are non-blank,
and all 36 checks pass. If any PNG is missing/blank the verdict is
`UNVERIFIED (NO PNG)` — never a visual PASS from JSON alone (D03 §6/§8).

*End of G01.*
