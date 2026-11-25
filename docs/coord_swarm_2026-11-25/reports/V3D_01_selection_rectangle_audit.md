---
id: V3D-01
title: "V3D-01 — Why the 3D selection rectangle does not work: current code-path audit (variant3d)"
owner: V3D-01 (micro-worker)
date: 2026-11-25
scope: "READ-ONLY audit. No game code, config, test, scene, shader or git edits. One report file only."
status: STATIC_AUDIT_COMPLETE__NO_GODOT_RUN__NO_RUNTIME_CLAIM
labels: [VARIANT3D, SELECTION_RECTANGLE, DRAG_BOX, CODE_PATH_AUDIT, COORDINATE_SPACES]
evidence_labels: [observed, derived, inferred]
verification: "Source read only. No Godot process started (one-Godot-at-a-time swarm rule); every claim below is a static source reading or a documented prior measurement, labelled accordingly."
---

# V3D-01 — 3D selection rectangle: current code-path audit

## Goal

Explain, with `path:line` citations at every hop, why drag-box selection in
`variant3d/` (render_mode `"3d"`) does not work: trace input events → drag
state → unit enumeration → projection → inside-box test → selection apply →
selection visuals; identify the exact break points; compare with the 2D `app/`
implementation as **SECONDARY** evidence; and propose the smallest fix + test.
No code was edited.

## Sources

**Orientation docs (read):** `docs/variant3d/README.md`;
`docs/variant3d/STATUS_WAVE7_PHASE2.md`;
`docs/coord_swarm_2026-11-24/reports/FIXSEL_picking_orders.md`;
`.../FIXSEL_visuals.md`; `.../V768_picking_fix.md`;
`.../V775_pick_caller.md`; `.../V712_picking3d.md`;
`.../V733_test_pick3d.md`; `.../PLAY2FIX_navbox.md`;
`docs/coord_swarm_2026-11-25/CHARTER.md`;
`.../SWARM_BOARD.md`.

**Code read (variant3d, all read-only):**
`scripts/input_controller.gd` (1235 lines), `scripts/main.gd` (2030),
`scripts/picking3d.gd` (319), `scripts/camera3d.gd` (606),
`scripts/world3d.gd` (743), `scripts/world3d_entities.gd` (spot checks),
`scripts/world3d_fx.gd` (881, node-construction + FX API sections),
`scripts/hud.gd` (1766, input/minimap sections), `scripts/hud3d_adapter.gd`,
`scripts/world.gd` (2D analogue in the variant copy), `scripts/selftest.gd`,
`scripts/testbridge.gd`, `scripts/uitest.gd`, `scenes/main.tscn`,
`tests/t_pick3d.gd`, `tests/t_nav_smoke.gd`, `tests/fixtures/small_map_64.json`.

**SECONDARY (2D shipping port, read-only):** `app/scripts/input_controller.gd`,
`app/scripts/world.gd` (via the byte-identical variant copy plus direct app read).

**Prior gap reports used as corroboration (not as new evidence):**
`AUDIT3D_05_camera_hud_pick.md:68,153-154`;
`DEEPDEC_08_ui_minimap.md:234,263,289-290`;
`COMPLETENESS_02_vs_2d.md:84`; `COMPLETENESS_03_donor_fidelity.md:78,81`;
`V751_world3d_integration.md:59`; `TERRAIN_SMALL_maps.md:43-49,57-65`.

## Full trace (observed static facts unless labelled otherwise)

### 0. Wiring: the 3D path is actually constructed

- `main.gd:181-182` — `gameplay.render_mode` from config → `Data.RENDER_MODE`;
  canonical variant config is `3d` (`TERRAIN_SMALL_maps.md:47`).
- `main.gd:578-591` — in 3D, `world = make_world3d()` (`world3d.gd` instance,
  factory at `:977-985`), `world.bind(game)`, then `camera = make_camera3d()`
  (`camera3d.gd` instance, factory at `:988-996`) and `camera.bind(game,
  world.view_scale)`.
- `main.gd:627-631` — `input_ctl = C3InputScript.new()`, added to the tree,
  `input_ctl.bind(game, world, hud, camera)`, then `_apply_3d_hooks(...)`.
- `main.gd:1010-1014` — `_apply_3d_hooks()` calls `hud.bind_3d(cam)` and
  `input_ctl.bind_3d(cam)`.
- `input_controller.gd:114-126` — `bind_3d()` creates/binds `picking3d.gd`
  (`load("res://scripts/picking3d.gd")` at `:115`, `picking.bind(game, cam)` at
  `:125`) and sets `render_mode = "3d"` at `:126`.
- **Conclusion (observed):** the input controller, `picking3d` adapter,
  `world3d` and `Camera3D` are all live in a 3D run. Nothing in the construction
  path disables drag input.

### 1. Input events → drag start (is drag input captured?)

- `input_controller.gd:528` — `func _unhandled_input(event: InputEvent)`.
- `input_controller.gd:529-536` — `InputEventMouseButton` branch; wheel is
  consumed at `:534-536`; the node has no `_input()` override, so unhandled
  events reach it.
- `input_controller.gd:537-554` — minimap preemption:
  - `:543-546` LMB inside `_minimap_screen_rect()` sets `_mm_dragging`,
    repositions the camera and **returns**;
  - `:547-551` RMB inside minimap issues an order and returns;
  - `:552-554` LMB release while `_mm_dragging` returns.
- `input_controller.gd:555` — every world mouse-button event computes
  `var pw := _screen_to_world(mb.position)`.
- `input_controller.gd:556-609` — LMB **press**: patrol/guard/build gates at
  `:558-607`; the ordinary path reaches `drag_start = mb.position` and
  `dragging = false` at `:608-609`.
- `input_controller.gd:650-663` — `InputEventMouseMotion`: after the minimap
  guard at `:656-661`, `drag_start != INF` and movement `> 6.0` px sets
  `dragging = true` at `:662-663`.
- `camera3d.gd:484-505` — the 3D camera's `_process` uses
  `Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)` for middle-drag pan; it
  has no `_unhandled_input` and consumes no LMB event.
- `hud.gd:1400-1443` — only `minimap_rect.gui_input` handles map input. In 3D,
  `_minimap_jump_3d()` consumes the LMB **press** only when the jump succeeds
  (`hud.gd:1434-1438`); 3D motion is explicitly **not** swallowed
  (`hud.gd:1431-1432,1439-1442`). Non-minimap HUD controls that call
  `set_input_as_handled()` are local buttons (`hud.gd:795,804`), not a
  full-screen blocker; `top_center.mouse_filter = MOUSE_FILTER_IGNORE`
  (`hud.gd:354`).
- **Conclusion (observed):** drag input **is** captured for world drags;
  `drag_start`/`dragging` are set normally. The only capture loss is a drag
  that starts **or ends** over the minimap rect (`input_controller.gd:543-554,
  656-661`), which is preempted and/or jumps the camera.

### 2. Rectangle state (is there a state variable?)

- `input_controller.gd:29` — `var drag_start := Vector2.INF`; `:30` —
  `var dragging := false` (screen pixels).
- `input_controller.gd:1164-1172` — in `_process`, while dragging, writes
  `world.sel_rect` (a **SIM-metre** `Rect2`) and `world.sel_active = true`;
  clears `sel_active` otherwise.
- `world3d.gd:126-127` — declares `sel_rect` and `sel_active` so those writes
  are legal; the comment cites `input_controller.gd:1017-1020`, which is stale
  (live lines are `1169-1172`) — evidence of drift, not of a draw.
- **Conclusion (observed):** state exists in two forms — the authoritative
  screen-pixel pair in the input controller, and a SIM-metre mirror in the
  world.

### 3. Unit enumeration + projection + inside-box test + apply

This is the core of the drag-select, on **mouse release**:

- `input_controller.gd:610-612` — LMB release; bail if `drag_start == INF`.
- `input_controller.gd:613` — `var moved := (mb.position - drag_start).length() > 6.0`.
- `input_controller.gd:615-616` — `var a := _screen_to_world(drag_start)` and
  `var bp := _screen_to_world(mb.position)`.
- `input_controller.gd:617` — `var rect := Rect2(minf(a.x,bp.x), minf(a.y,bp.y), absf(a.x-bp.x), absf(a.y-bp.y))`.
- `input_controller.gd:619-623` — `for e in game.entities`, skip
  `e.dead or e.player != 0 or e.kind != "unit"`, then `rect.has_point(e.pos)`
  → append.
- `input_controller.gd:624` — `_set_selection(arr)`.
- `input_controller.gd:207-217` — `_set_selection()` clears old `e["selected"]`
  flags, sets new ones, bumps `game.bld_dirty`, calls `hud.refresh_selection()`.
- `game.gd:2585-2590` (as cited in `FIXSEL_picking_orders.md:46`) —
  `game.get_selected()` reads those same flags.
- `world3d.gd:297-319` — `_sync_selection()` mirrors `game.get_selected()` into
  `selected_ids` / `selected` (read-only with respect to the sim).

**3D seam used by `_screen_to_world`:**

- `input_controller.gd:455-462` — in 3D, `_screen_to_world(p)` records
  `_pick_screen = p` and returns `picking.ground_point(p)`.
- `picking3d.gd:235-243` — `ground_point()` builds
  `project_ray_origin/project_ray_normal` and returns
  `_to_sim(_ray_heightfield(o,d))`.
- `picking3d.gd:148-171` — `_ray_heightfield()` marches 1 m steps (`:153-156`)
  against `game.height_at()` at `_to_sim(p)`, refines 20 bisections (`:160-169`),
  falls back to the Y=0 plane at `:171`.
- `picking3d.gd:75-108` — `_recalc_offset()` sets `_world_to_sim =
  (MAP_W*TILE/2, MAP_H*TILE/2)` (`:80-83`) and, for a `Camera3D` exposing
  `jump_to_world()`, **never** re-calibrates (`:86-88`).
- `picking3d.gd:121-127` — `_to_sim(w) = Vector2(w.x,w.z) + _world_to_sim`;
  `_to_world(sim,y) = Vector3(sim - offset)`.
- `world3d_entities.gd:997-1016` (as cited in `FIXSEL_picking_orders.md:81-83`)
  renders an entity at `sim - half`; the picker uses the same frame.
- **Conclusion (observed):** the rectangle endpoints are **SIM map-origin
  metres** and `e.pos` is **SIM map-origin metres**. The box test is therefore
  in a *single, matching* coordinate space — it is **not** mixing canvas px
  with world px. The drop-in copy preserved the 2D algorithm verbatim
  (`app/scripts/input_controller.gd:474-490` vs variant `:608-624`).

**What is NOT used in the drag path (important):**

- `picking3d.gd:198-207` — `_project_world()` (world→screen via
  `Camera3D.unproject_position()`) exists, and `:224-225` `_screen_of()` uses
  it, but **only `pick()`/`pick_res()` call them** (`:285`, `:328`). The drag
  path never projects a unit to screen pixels.
- `input_controller.gd:632-635` — the *double-click* path uses
  `world.view_rect` + `u.pos * world.view_scale`; it is a separate path from
  drag-select.

### 4. Selection apply → visuals

- `input_controller.gd:624` + `:207-217` — selection flags updated (above).
- `world3d.gd:682-688` — `sync()` calls `_sync_selection()` then
  `_sync_selection_aura()` (`:535-559`), which builds `{id,pos,player,kind,radius}`
  entries and calls `fx.sync_selection(entries)` at `:559`.
- `world3d_fx.gd:379-387,387-435` — `sync_selection()` creates/removes
  `SelRing_<id>` markers; roots created at `:556-559`. This is the
  FIX-SELECTVIS work (`FIXSEL_visuals.md:30-53`, measured 2 rings / 0 after
  clear in that report §3). **Selection feedback for already-selected units
  exists in 3D.**
- **Rectangle visual:** `world3d.gd:126-127` declares the data only. A grep of
  all `variant3d/**/*.gd` finds `sel_rect`/`sel_active` at exactly:
  `input_controller.gd:1169-1172`, `world3d.gd:126-127`, and `world.gd:130-131,
  2141,3642-3644`. There is **no 3D draw consumer**.
  `world3d_fx.gd:534-559` creates `FX3D`, `BuildGhost3D`, `Rally3D`,
  `Selection3D` roots — no rectangle root.
- The 2D analogue draws it: `world.gd:3641-3647` — `world_to_px()` both corners,
  `fx_layer.draw_rect()` outline + fill; gated by `_fx_needs_redraw()`'s
  `if sel_active: return true` at `world.gd:2141`.
- Prior audits already declared this gap: `AUDIT3D_05_camera_hud_pick.md:68`
  ("no 3D consumer found … selection works (metre AABB) but no visual box"),
  `:153-154` (proposed fix), `DEEPDEC_08_ui_minimap.md:234,263,289-290`,
  `COMPLETENESS_02_vs_2d.md:84`, `COMPLETENESS_03_donor_fidelity.md:81`.

### 5. Click-pick vs drag-select: conflict analysis

- `input_controller.gd:613-647` — the two are **mutually exclusive** on mouse
  release: `moved > 6 px` → drag branch (`:615-624`), else → `_pick(pw,false)`
  branch (`:626-645`). No double-apply.
- `input_controller.gd:470-480` — 3D click-pick forwards the flag to
  `picking.pick(_pick_screen, players_only)`; the finite guard at `:478` uses
  `_pick_screen`, which `_screen_to_world` last wrote (`:461`). Because
  `_screen_to_world` is called at `:555`, `:615`, `:616`, `:1167-1168` and
  `:1239`, `_pick_screen` can be left at the **rectangle start** or the
  **current mouse position** rather than the released click pixel. In the drag
  branch `_pick()` is not called, so this does not corrupt drag result; it is a
  latent hazard for mixed click/guard/cursor paths.
- `picking3d.gd:266-301` — click-pick projects each entity to screen and uses
  `_pixel_reach()` (`:214-221`) at the entity's own depth. FIX-SEL measured this
  working after the offset fix (`FIXSEL_picking_orders.md:185-197`, 10/10).
- `camera3d.gd:266-275` returns CENTRED world metres; `picking3d` adds the
  half-map offset. `world3d.gd:271-274` still claims
  `get_viewport_corners()` returns MAP-ORIGIN sim metres and applies **no**
  half-map shift in `_update_view_rect()` (`:247-293`). `PLAY2FIX_navbox.md:14-29,69-83`
  measured the corners as CENTRED and added the half offset in
  `hud3d_adapter.gd:62`. **Derived:** `world3d.view_rect` remains off by the
  half-map vector in 3D; that affects the double-click select-all-of-type path
  at `input_controller.gd:632-635`, not the drag-box.

### 6. Automated coverage

- `uitest.gd:115-123` — the step named `select_box` **does not drag**: it calls
  `ictl._set_selection(_peas().slice(0,3))` directly (`:117-118`) and checks the
  HUD panel. It would pass even if `_unhandled_input` were deleted.
- `selftest.gd` — grep for `drag|select_box|sel_rect|sel_active|MOUSE_BUTTON_LEFT`
  returns **0 matches**.
- `tests/t_pick3d.gd:16,26-29` — asserts only `ground_point` finite and
  `pick()/pick_res()` return Dictionaries; no box test, and it uses a stub
  identity camera (`V733_test_pick3d.md:34-37`).
- `tests/t_nav_smoke.gd:48-51` — minimap only.
- `testbridge.gd:82-89,121-142` — has `click`, `move`, `key` but **no drag
  command**; a UI-driven drag test would need two mouse events with an
  intermediate motion, which the bridge cannot express in one command.
- **Conclusion (observed):** no automated test exercises the drag-box path, so
  neither the visual gap nor any functional regression could be caught by the
  green 29/29 + 17/17 gates.

## Break-point table

| # | Symptom | Root cause | Citation | Confidence |
|---:|---|---|---|---|
| 1 | No rectangle is ever visible during a 3D drag | `world3d.gd` declares `sel_rect`/`sel_active` but nothing draws them; the 2D `fx_layer.draw_rect()` call has no 3D counterpart | `world3d.gd:126-127`; grep of all `variant3d/**/*.gd`; `world.gd:3641-3647,2141`; `world3d_fx.gd:534-559`; `AUDIT3D_05:68,153-154` | **HIGH — observed (static)** |
| 2 | Users report "drag-box selecting units" does not work | The only *proven* total break is the visual (row 1). The functional branch is present and in matching SIM space; it has never been tested end-to-end in 3D, and its geometric accuracy under a tilted perspective camera is unproven | `input_controller.gd:613-624`; `picking3d.gd:235-243,121-127`; `uitest.gd:115-123`; `selftest.gd` (0 matches) | **MEDIUM — inferred** (symptom is real; which part the user sees is unverified) |
| 3 | Drag box is geometrically wrong / includes wrong units | The box is a SIM-ground AABB built from **two** screen-corner ray hits; `picking3d._ray_heightfield()` falls back to the camera ray origin for above-horizon pixels, and screen↔ground under a −32° perspective is nonlinear. Units are tested by ground `e.pos`, not by their projected 3D point | `input_controller.gd:615-622`; `picking3d.gd:148-171,171,198-207`; `camera3d.gd:232-252` | **MEDIUM — derived** (plausible mis-selection, magnitude unmeasured) |
| 4 | Drag ending on the minimap does not select and jumps the camera | Minimap press/release/motion branches preempt and `return` before the world drag branch | `input_controller.gd:543-554,656-661`; `hud.gd:1409-1443` | **HIGH — observed (static)** |
| 5 | Double-click select-all-of-type selects the wrong set in 3D | `world3d._update_view_rect()` trusts a stale comment and omits the half-map shift that `hud3d_adapter.gd:62` adds | `world3d.gd:247-293` (esp. `:271-274`); `camera3d.gd:266-275,354-363`; `PLAY2FIX_navbox.md:14-29,69-83`; `input_controller.gd:632-635` | **MEDIUM-HIGH — derived** (single prior measurement supports CENTRED corners) |
| 6 | Green gates did not catch any of this | `select_box` uitest bypasses input; selftest has no drag checks; no bridge drag command | `uitest.gd:115-123`; `selftest.gd`; `testbridge.gd:82-89,121-142` | **HIGH — observed** |
| 7 | `render_mode == "3d"` gating out drag-select? | **No.** The drag branch has no `render_mode` guard; it runs identically in both modes. Only `_screen_to_world` swaps adapter | `input_controller.gd:21,455-462,613-624` (no mode check in drag branch) | **HIGH — observed (negative finding)** |
| 8 | Click-pick vs drag-select conflict? | **No direct conflict** — mutually exclusive on release. Latent `_pick_screen` mutation by unrelated `_screen_to_world()` calls, but not used in the drag branch | `input_controller.gd:613-647,461,555,1167-1168,1239` | **HIGH — observed (negative finding)** |

## What exists / missing (checklist of the task's questions)

| Question | Answer | Evidence |
|---|---|---|
| Is drag input captured? | **YES** for world drags; LMB press/motion/release all present; only minimap-overlapping drags are preempted | `input_controller.gd:528,543-554,555,608-609,650-663` |
| Is there a rectangle state variable? | **YES** — `drag_start`, `dragging` (screen px) + `world.sel_rect`, `world.sel_active` (SIM m mirror) | `input_controller.gd:29-30,1164-1172`; `world3d.gd:126-127` |
| Are units enumerated in 3D? | **YES** — plain `for e in game.entities`, same as 2D, player-0 units only | `input_controller.gd:619-623`; `app/scripts/input_controller.gd:485-489` |
| Is there a world→screen projection? | **YES, but not used by drag** — `_project_world()`/`_screen_of()` are used only by `pick()`/`pick_res()`; drag uses screen→ground (`ground_point()`) instead | `picking3d.gd:198-207,224-225,285,328`; `input_controller.gd:615-616` |
| Is the box test in the wrong coordinate space? | **NO mixing of px vs m** — both endpoints and `e.pos` are SIM metres. But the *geometry* is a ground AABB of a screen box, which is an approximation under perspective | `input_controller.gd:615-622`; `picking3d.gd:121-127`; `camera3d.gd:232-252` |
| Is `render_mode=="3d"` gating it out? | **NO** | `input_controller.gd:21,613-624` |
| Do click-pick and drag-select conflict? | **NO** (mutually exclusive); `_pick_screen` mutation is a latent hazard elsewhere | `input_controller.gd:613-647` |
| Is the rectangle visual drawn at all? | **NO** — data mirror only; no 3D draw consumer exists | `world3d.gd:126-127`; `world.gd:3641-3647`; `world3d_fx.gd:534-559` |

## SECONDARY evidence — what the 2D `app/` copy had and the 3D adaptation lost

*(SECONDARY by charter `docs/coord_swarm_2026-11-25/CHARTER.md:37-38`; donor is
primary and is being handled by the sibling DSEL-01 ticket.)*

| 2D behaviour | 2D site | 3D state | Lost/adapted? |
|---|---|---|---|
| Drag state + screen-pixel threshold | `app/scripts/input_controller.gd:14,474-479,527-528` | `variant3d/scripts/input_controller.gd:29-30,608-613,662-663` | **COPIED** byte-identically |
| Box test on `game.entities` with `e.pos` in sim metres | `app/scripts/input_controller.gd:481-490` | `variant3d/scripts/input_controller.gd:615-624` | **COPIED**; only `_screen_to_world` adapter changes |
| `_screen_to_world` = canvas-inverse ÷ view_scale → SIM m | `app/scripts/input_controller.gd:337-343` | `variant3d/scripts/input_controller.gd:455-462` → `picking3d.gd:235-243` | **ADAPTED** (ray-march to SIM m); mathematically same space |
| Rectangle drawn in `fx_layer` in canvas px | `app/scripts/world.gd:130-131,2141,3641-3647` | `variant3d/scripts/world3d.gd:126-127` only | **LOST** — no draw, no redraw gate, no overlay node |
| Click-pick projects entities to screen and uses pick radius | `app/scripts/input_controller.gd:345-369` | `picking3d.gd:266-301` + FIX-SEL offset fix | **ADAPTED and VERIFIED** by `FIXSEL_picking_orders.md:185-197` |
| Patrol route drawn as `Node2D` under `Node2D` fx layer | `app/scripts/input_controller.gd` route path | FIX-SEL replaced with `MeshInstance3D`/`ImmediateMesh` under `Node3D` fx layer (`input_controller.gd:132-148,404-453`) | **ADAPTED** — precedent for how to add a 3D overlay without editing `world3d.gd` |
| `uitest select_box` | `app/scripts/uitest.gd` | `variant3d/scripts/uitest.gd:115-123` | **COPIED, but never tested the real drag** in either port |

## Fix plan (proposed; no edits made)

Owner note: per `CHARTER.md:44-47`, implementation needs a builder ticket with
exclusive file ownership. Two small, independent changes.

### Fix A — make the box test screen-space and 3D-correct (functional)

1. **`variant3d/scripts/picking3d.gd`** — add one public method, e.g.
   `select_in_rect(start_px: Vector2, end_px: Vector2, players_only: bool = false) -> Array`:
   - build `var r := Rect2(start_px, end_px).abs()` in **viewport pixels**;
   - iterate `game.entities` exactly as today (skip `dead`, `player != 0` when
     `players_only`, non-unit kinds as the caller decides);
   - for each candidate use the **existing** `_screen_of(sim, BODY_LIFT_M)`
     (`picking3d.gd:224-225`, which already goes through `Camera3D.unproject_position()`)
     and `r.has_point(sp)`;
   - optionally require the projected point to be in front of the camera via
     `_depth_of()` (`picking3d.gd:228-230`) > 0, to reject behind-camera
     entities (V768 open question 3 is the opposite failure in `pick()`);
   - return live entity Dictionaries; issue **no** `game.cmd_*` call (contract at
     `picking3d.gd:4-8`).
   This reuses the already-proven renderer frame from FIX-SEL and removes the
   tilted-perspective ground-AABB approximation entirely.
2. **`variant3d/scripts/input_controller.gd:613-624`** — add a 3D branch inside
   the `moved` block: if `render_mode == "3d" and picking != null`, call
   `picking.select_in_rect(drag_start, mb.position, false)` and
   `_set_selection(result)`; keep the existing 2D SIM-metre branch byte-identical.
   Do **not** touch `_pick`, `_set_selection`, `cmd_*` calls or the click branch.
3. **(Optional, related)** `world3d.gd:247-293` — add the half-map offset for
   `Vector2` corners from `camera3d.get_viewport_corners()` before multiplying by
   `view_scale`, mirroring `hud3d_adapter.gd:62`. This fixes double-click
   select-all-of-type (`input_controller.gd:632-635`), not the drag-box.

### Fix B — draw the rectangle in 3D (visual), smallest surface

**Do not** project `world.sel_rect` through `camera3d.world_to_px()`: that helper
(`camera3d.gd:255-260`) expects **centred world metres**, while `sel_rect` holds
**SIM metres** — the same trap documented in `PLAY2FIX_navbox.md:14-29` and
`FIXSEL_picking_orders.md:71-89`.

Smallest option: in **`input_controller.gd`** (already owns the authoritative
screen pixels), add a `CanvasLayer` + `Control` overlay with
`mouse_filter = MOUSE_FILTER_IGNORE`, created in `bind_3d()` (`:114-126`), and
draw `Rect2(drag_start, current_mouse).abs()` directly in **viewport pixels**
in its `_draw()`, refreshed from `_process()` (`:1164-1172`). Outline + 18 %
fill match `world.gd:3646-3647`. This needs no world/FX edits, no camera math,
and cannot be affected by the minimap frame — the precedent is the FIX-SEL
patrol overlay added entirely inside `input_controller.gd`
(`FIXSEL_picking_orders.md:91-102,141-148`).

Alternative (if a world-owned overlay is preferred): add a `SelectionRect3D`
root in `world3d_fx.gd:534-559` driven by a new `draw_selection_rect(screen_rect)`
API, but that requires converting SIM→centred→pixels and touches two files.

### Smallest automated test proposal

**Atom:** new `variant3d/tests/t_drag_rect3d.gd`, `extends SceneTree`,
`--script` through `python variant3d\tools\godot_runner.py run --id ... --headless
--path variant3d --script res://tests/t_drag_rect3d.gd` (pattern from
`t_pick3d.gd:12,39-41` and the deleted FIX-SEL probe described at
`FIXSEL_picking_orders.md:170-181`).

**Smallest map:** reuse `variant3d/tests/fixtures/small_map_64.json` (64×64
tiles, `TERRAIN_SMALL_maps.md:48,60-65`) or an even smaller **stub** game with
`MAP_W = MAP_H = 8`, `TILE_M = 2`, `height_at() = 0` — a stub is enough because
the test targets the input/box algorithm, not terrain rendering.

**Setup (fewest units):** a real `camera3d.gd` Camera3D in the tree bound to the
stub (`bind(game, 16.0)`, `apply_external_target(Vector2(8,8)*TILE)`), a real
`picking3d.gd`, a real `input_controller.gd` wired with `bind_3d(cam)`, and
**exactly 3 friendly units**: `id=10` at sim `(8,8)`, `id=11` at `(12,8)`,
`id=12` at `(40,40)` (the last one deliberately outside the box). One neutral
`kind="building"` at `(10,8)` to prove the kind filter still excludes
buildings. No mapgen, no AI, no FX required.

**Drive the real path (no direct `_set_selection`):** defer the body to the
first frame (`FIXSEL_picking_orders.md:159` records why `_initialize()` fails —
null viewport / camera not in tree). Then:
1. compute pixels with `cam.unproject_position()` for the intended ground
   corners (as FIX-SEL did at `:177-180`);
2. send `InputEventMouseButton` LMB pressed at `p0` through
   `ictl._unhandled_input(ev)` (or `Input.parse_input_event` via testbridge's
   `_mouse` pattern at `testbridge.gd:121-127`);
3. send `InputEventMouseMotion` at `p1` with left button mask
   (`testbridge.gd:137-140`) so `dragging` becomes true;
4. send LMB released at `p1`; assert `ictl.selected_ids == [10,11]` and
   `e.selected` flags match, building not selected.
5. Assert the overlay: while dragging, a `CanvasLayer` overlay exists and
   reports a non-empty `Rect2` equal to `Rect2(p0,p1).abs()`; after release it
   reports empty/hidden.
6. Regression guards (cheap, same probe): a click with `|p1-p0| < 6 px` still
   selects the single unit under the cursor via `picking3d.pick()`;
   `game.cmd_*` counter stays 0.

**Expected result:** pre-fix, check 4 fails if the visual assertion is included
(and check 3 may fail/over-select if the ground-AABB approximation is exposed);
post-fix all checks pass. Write `res://tests/results/t_drag_rect3d.json` and
exit via `call_deferred("quit", 0/1)` (`t_pick3d.gd:39-41`). This is the
smallest test that *proves* drag-box selection rather than simulating its
result — unlike `uitest.gd:115-123`.

## Open questions

1. **Which part of "does not work" did the user observe?** No visual box is
   proven; a functional failure is **inferred** but has never been measured in
   3D. A single windowed repro (drag over two known units, observe selection
   panel and rectangle) would settle this.
2. Does `InputEventMouseMotion` reach `_unhandled_input` reliably in a real
   windowed 3D run with the HUD CanvasLayer? Static reading says yes
   (`hud.gd:354,1409-1443`), but no runtime probe was run here.
3. Should the 3D box use the **rendered projected point** (`_screen_of`,
   body-lift 0.8 m — an UNVERIFIED estimate, `picking3d.gd:41`) or the ground
   point? The projected point matches click-pick; the ground point matches 2D
   semantics. Donor selection rectangle internals are engine-side/UNVERIFIED
   (`picking3d.gd:23-28`; sibling DSEL-01 owns that research).
4. Should buildings be selectable by drag? 2D excludes them
   (`input_controller.gd:620`); donor filtering (`onselection.inc:10-175`, cited
   in `DEEPDEC_08_ui_minimap.md:227-228`) is not mirrored. Keep 2D behaviour
   until DSEL-01 reports.
5. Does the minimap preemption (row 4) need fixing, or is it acceptable?
6. Does `world3d.view_rect` need the half-map fix (row 5) in the same ticket,
   or is it a separate atom? It is a distinct call site (double-click).
7. The `world3d.gd:126-127` comments cite `input_controller.gd:1017-1020` but
   the live lines are `1169-1172`; update the comment when an owner touches the
   file.

## Summary

- The 3D drag-select **code path is present end to end**: input is captured,
  `drag_start`/`dragging` exist, entities are enumerated, endpoints are converted
  from screen pixels to SIM metres through `picking3d.ground_point()`, the box
  test runs in that same SIM-metre space, and `_set_selection()` applies the
  result with working selection-aura visuals.
- The one **definitive, high-confidence break** is the **rectangle visual**:
  `world3d.gd` stores `sel_rect`/`sel_active` but no 3D code ever draws them
  (`world3d.gd:126-127` vs `world.gd:3641-3647`). This was already flagged as
  `AUDIT3D_05` E10 and is still open.
- The functional drag-box is **untested** and geometrically approximate under a
  tilted perspective camera; it may over-select or mis-select near the frame
  edges, but no evidence found here proves a total functional failure.
- `render_mode == "3d"` does **not** gate it out, and click-pick vs drag-select
  are mutually exclusive. Real conflicts are minimap-overlapping drags and a
  stale half-map assumption in `world3d.view_rect` (double-click path).
- Smallest fix: add `picking3d.select_in_rect()` using the already-proven
  `Camera3D.unproject_position()` projection and branch the input controller's
  `moved` block on `render_mode`; draw the box as a screen-pixel `CanvasLayer`
  overlay inside `input_controller.gd`. Prove it with a 3-unit stub-game probe
  that drives real mouse events and asserts `selected_ids == [10,11]` plus
  overlay presence — not the existing `uitest` step, which calls
  `_set_selection()` directly.

**No game code, tests, config, scene or shader were edited. No Godot process was
started. All findings are static observations or explicitly labelled
derivations/inferences.**

---

**Related:** `DSEL_01_donor_selection_rectangle.md` (donor truth, sibling) ·
`docs/coord_swarm_2026-11-25/CHARTER.md` ·
`docs/coord_swarm_2026-11-24/reports/FIXSEL_picking_orders.md` ·
`docs/coord_swarm_2026-11-24/reports/AUDIT3D_05_camera_hud_pick.md`
