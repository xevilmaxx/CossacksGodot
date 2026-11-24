---
id: AUDIT3D-05
title: "AUDIT3D-05 — camera / picking / HUD seam parity (variant3d vs app vs donor)"
owner: AUDIT3D-05
scope: "variant3d/scripts/camera3d.gd, picking3d.gd, input_controller.gd 3D branches, hud.gd 3D branch, hud3d_adapter.gd, main.gd hook/camera call sites; compare app/scripts/camera.gd, input_controller.gd, hud.gd and read-only donor C:\\Games\\Cossacks 3 camera/mouse scripts"
date: 2026-11-24
status: AUDIT_COMPLETE__RUNTIME_PARITY_UNVERIFIED
verdict: "Zoom bounds, tilt, edge-scroll and the cmd_* order layer are 2D-parity; the camera/HUD seam is incomplete. Minimap left-click camera jump is a confirmed P0 no-op, and a Vector2/Vector3 unit mismatch makes world.view_rect the full map in 3D. No double-binding of picking/HUD adapters."
---

# AUDIT3D-05 — Camera / picking / HUD seam parity

## 1. Scope and method

Read-only audit for the 2026-11-24 AUDIT3D swarm. No source, asset, config or test edits; no git
commands; no donor writes and no donor binaries copied/read (only donor text under
`C:\Games\Cossacks 3\data\...`). Files inspected in full or in the cited slices:
`variant3d/scripts/camera3d.gd`, `picking3d.gd`, `input_controller.gd`, `hud.gd`,
`hud3d_adapter.gd`, `world3d.gd`, `world3d_terrain.gd`, `world3d_fog.gd`, `main.gd`,
`data.gd`, `tests/t_camera3d.gd`; `app/scripts/camera.gd`, `input_controller.gd`, `hud.gd`,
`world.gd`; donor `data/cameras/camera.cfg`, `data/cameras/default.cameras`,
`data/gui/menu.inc/oncamera.inc`, `data/gui/menu.inc/cameracontrol.inc`,
`data/gui/menu.inc/onmousedown.inc`, `data/gui/menu.inc/eventminimap.inc`,
`data/gui/common.inc/onmousewheel.inc`.

Labels: **OBS** = directly read at the cited line; **INF** = inference from those reads;
**UNVERIFIED** = no readable donor/port evidence. Per charter, donor FOV/yaw/pick depth and
3D render fidelity remain UNVERIFIED.

## 2. Bottom line

- **OBS.** Zoom limits are donor-derived and byte-comparable to 2D: donor
  `SphereHeight=58 / SphereHeightMin=20` (`camera.cfg:6-7`, mirrored at `:9-10`) maps to
  `min_zoom=20/58, max_zoom=58/20` in both cameras (`app/scripts/camera.gd:79-90`;
  `variant3d/scripts/camera3d.gd:122-126`). Wheel zoom clamps the donor height, not the
  canvas scale (`camera3d.gd:135-141`; donor `onmousewheel.inc:29-41`), and tilt is the
  donor's constant `-32°` (`camera.cfg:32-35`, `onmousewheel.inc:43-47`, `data.gd:165`,
  `camera3d.gd:144-153`).
- **OBS.** Edge-scroll bands and speeds are donor/2D parity: `cMargin=8`, `cCornerMargin=24`
  (`cameracontrol.inc:20-35`), arrow-only pan (`oncamera.inc:18-27,60-72`), with the port's
  depth/dwell acceleration mirrored from 2D (`camera.gd:184-220` ↔ `camera3d.gd:279-307`).
- **OBS.** All `game.cmd_*` order paths, hotkeys, minimap right-click orders and build-ghost
  logic are inherited unchanged by the 3D input controller (`input_controller.gd:234-247`,
  `:584-679`, `:808-1056`); only `_screen_to_world/_pick/_pick_res` are rerouted
  (`:373-420`, `:718-725`). Ground clicks therefore issue correct sim-metre orders via a
  height-field ray (`picking3d.gd:194-202,128-151`).
- **OBS / INF.** The seam is where parity breaks: minimap left-click jump is swallowed by a
  2D-only HUD handler, `world.view_rect` is permanently the full map because of a
  `Vector2`/`Vector3` type mismatch, fog overlay quads use a different height lattice than
  the terrain mesh, and `world.fog_revision` is read by the HUD but never defined on the 3D
  world.
- **OBS.** No double-binding: `_apply_3d_hooks()` is called once per mutually exclusive
  startup path and both `bind_3d()` implementations are idempotent (§4).

## 3. Evidence table

| # | Behaviour | 2D / donor source (path:line) | variant3d source (path:line) | Verdict |
|---|---|---|---|---|
| E1 | Zoom limits | donor `camera.cfg:6-10`; `onmousewheel.inc:29-41`; `app/scripts/camera.gd:79-90,257-262` | `camera3d.gd:43-46,122-126,139-141,334-349` | **PARITY** — height bounds mapped to 2D zoom interval; no invented constants |
| E2 | Tilt | donor `camera.cfg:30-40`; `onmousewheel.inc:43-47`; `data.gd:165` | `camera3d.gd:144-153` | **PARITY** — constant -32°; yaw 0 is a port assumption (donor yaw UNVERIFIED) |
| E3 | FOV / visible scale | donor `default.cameras:17` `FocalLength=400`, `camera.cfg:44-45`; no donor projection matrix readable | `camera3d.gd:48-55,100-103` `FOV_DEG_ASSUMED=17.27` | **GAP P1** — assumed V-FOV; **INF:** at zoom 1 the 3D ground width ≈35 m vs 2D `1280/1/16≈80 m` (`data.gd:117`, `project.godot` viewport), i.e. ~2.3× tighter; donor value UNVERIFIED |
| E4 | Edge-scroll / arrow keys | donor `cameracontrol.inc:20-35`, `oncamera.inc:10-29,60-72`; `app/scripts/camera.gd:166-220,238-244` | `camera3d.gd:259-329` | **PARITY + port extension** (depth/dwell copied from 2D; speeds converted px→m at `data.gd:117,170-171`) |
| E5 | Middle-drag pan | `app/scripts/camera.gd:149-160` (`position -= md/zoom`) | `camera3d.gd:248-257` (`_target -= md/(zoom*view_scale)`) | **GAP P2** — fixed 16 px/m scalar, but perspective ground scale varies with height/depth (`:139-176`) |
| E6 | Zoom-at-cursor | `app/scripts/camera.gd:246-284` (canvas-space anchor); donor `onmousewheel.inc:296-303` (MoveToTargetXZ after ZoomCamera) | `camera3d.gd:332-376` (flat Y=0 anchor via `screen_to_world`) | **GAP P1** — anchor uses plane Y=0 while picking uses height field; **INF:** on relief the held point drifts during dolly |
| E7 | Click-to-move (RMB) | donor `onmousedown.inc:445-484,611-624` `GetCurrentMouseWorldCoord`; `app/scripts/input_controller.gd:584-679` | `input_controller.gd:373-386,388-420,584-679`; `picking3d.gd:194-202,128-151` | **PARITY at cmd layer** — `pw` is sim metres from a terrain ray; donor pick-depth rule UNVERIFIED (`picking3d.gd:21-26`) |
| E8 | Unit/building pick | `app/scripts/input_controller.gd:345-369,471-563`; `app/scripts/game.gd:1555-1560` `pick_radius` | `picking3d.gd:205-236`; `input_controller.gd:388-396` | **GAP P1** — fallback 2 m reach converted with fixed `_ppm(30.0)` (`picking3d.gd:218,37-38`); actual depth ≈37–110 m (`camera3d.gd:139-153`) → **INF:** effective reach ~2.5–7 m instead of 2 m |
| E9 | Double-click “on screen” | `app/scripts/input_controller.gd:494-501`; `app/scripts/world.gd:2075` | `input_controller.gd:545-553`; `world3d.gd:156-190`; `camera3d.gd:181-188` | **GAP P1** — `get_viewport_corners()` appends **Vector2**, but `_update_view_rect()` accepts only **Vector3** (`world3d.gd:178`) → `view_rect` stays `_full_map_rect_px()` (`:157`), so every same-type unit on the map is selected |
| E10 | Drag selection rectangle | `app/scripts/world.gd:3642-3644` draws `sel_rect` | `world3d.gd:88-89` stores `sel_rect/sel_active`; no 3D consumer found | **GAP P2** — selection works (metre AABB at `input_controller.gd:530-541`) but no visual box |
| E11 | Resource pick | `app/scripts/input_controller.gd:643-690,718-749` | `picking3d.gd:239-279`; `input_controller.gd:718-725` | **PARITY with depth ordering** — filters/2.5+radius/strict tie preserved; per-node depth at `picking3d.gd:263` |
| E12 | Minimap viewport box | `app/scripts/hud.gd:1394-1421` (camera rect → tile px) | `hud.gd:1423-1461`; `hud3d_adapter.gd:32-76`; `camera3d.gd:179-188` | **PARITY (flat plane)** — adapter handles Vector2 and Vector3 (`:91-99`); donor frustum box UNVERIFIED (`hud3d_adapter.gd:16-19`) |
| E13 | Minimap left-click / drag camera jump | donor `eventminimap.inc:8-35`, `onmousedown.inc:116-131` (`SetMainCameraMoveToTargetXZ`); `app/scripts/hud.gd:1368-1386`; `app/scripts/camera.gd:96-121` (`jump_to_world`) | `hud.gd:1397-1415` (still `get_camera_2d()`, **no 3D branch**); `input_controller.gd:222-232,459-470`; `camera3d.gd:89-94` has no `jump_to_world` | **GAP P0 (known open item)** — press consumed with `set_input_as_handled()` at `hud.gd:1402` while `cam==null`; drag reaches the fallback which writes `global_position` (Vector2→Vector3) and bypasses `_target`/`_apply_transform`; memoised `clamp_pos()` (`camera3d.gd:214-215`) cannot repair it |
| E14 | Minimap right-click order | `app/scripts/hud.gd:1378-1382`; `app/scripts/input_controller.gd:234-247` | `hud.gd:1407-1411`; `input_controller.gd:234-247` | **PARITY** — sim-metre order path is unchanged and valid in 3D |
| E15 | Fog overlay coordinates | `app/scripts/world.gd:333-347,2186-2272,2251-2255` (tile image, alpha ladder) | `world3d_fog.gd:184-203` (quad corners at tile boundaries, one centre height per quad); `world3d_terrain.gd:244-249` (vertices at cell **centres**) | **GAP P1** — foot print in sim XZ is correct, but fog quad Y is constant at the cell-centre height on a bilinear terrain surface (`world3d_terrain.gd:328-335`), so quads cut into terrain on slopes; `FOG_Y_OFFSET=0.03` only fixes z-fighting (`world3d_fog.gd:42-44,175-178`) |
| E16 | Fog cache revision | `app/scripts/world.gd:137,2247`; `app/scripts/hud.gd:1696-1703` | `hud.gd:1741,1748` reads `world.fog_revision`; `world3d.gd:82-95,250-259` defines no such property | **GAP P1** — dynamic lookup returns null/error every minimap tick; fog cache never hits. The header claim at `hud.gd:12` is false for 3D |
| E17 | Adapter double-binding | — | `main.gd:625,970-974,1063`; `hud.gd:196-208`; `input_controller.gd:111-123` | **NO DOUBLE-BINDING** (§4) |
| E18 | Shift+number group recentre | `app/scripts/input_controller.gd:825-827` (Camera2D position) | same line + `camera3d.gd:146-153` | **GAP P1** — writes `camera.global_position` directly; does not set `_target`, so the next `_apply_transform()` snaps back (or errors on Vector2→Vector3) |
| E19 | Journey-mode camera | `app/scripts/main.gd` equivalent | `main.gd:1553-1578` (`camera.position.lerp(Vector2,…)`) | **GAP P2** — Vector2/Vector3 mismatch under `journey_mode + render_mode=3d` |
| E20 | Patrol route overlay | `app/scripts/input_controller.gd:322-335`; `app/scripts/world.gd:350-351,3642-3644` | `input_controller.gd:93-97,356-371`; `world3d.gd:224-232,293-294` | **GAP P2** — `Node2D` child of `Node3D` `fx_layer`, drawn at `p*view_scale` canvas px, so it does not follow the perspective camera |
| E21 | Adapter dead API | — | `camera3d.gd:156-161`; `hud3d_adapter.gd:79-88` | **OBS P2** — `world_to_px()` and `screen_to_world()` defined but no call sites; no correctness impact |

## 4. Double-binding verification (explicit)

**OBS.** `_apply_3d_hooks()` is the only caller of either `bind_3d()` (`main.gd:970-974`).
It is invoked at `main.gd:625` (staged async load) and `main.gd:1063` (synchronous full
setup). Those are mutually exclusive startup paths: `_on_menu_chosen()` calls either
`_setup_full_game()` (headless/capture, `main.gd:252-255`) or `_do_async_load()`
(interactive, `main.gd:263`); `_ready()` calls `_setup_full_game()` only for
test/capture modes (`main.gd:224-226`). Each path creates a fresh `hud` and `input_ctl`
(`main.gd:606-623`, `:1041-1061`).

**OBS.** Both bindings are idempotent even on reuse: `hud.bind_3d()` creates
`_hud3d_adapter` only when null and otherwise rebinds the camera in place (`hud.gd:197-208`);
`input_controller.bind_3d()` creates and parents `picking` only when null and otherwise
rebinds (`input_controller.gd:116-123`). **Verdict: no duplicate adapters, no duplicate
`add_child`, no double `picking.bind()`.** (No `unbind_3d` exists — reusing a HUD after a
3D→2D switch is a separate known issue, `V753_hud_integration.md:179-181`.)

## 5. Ranked gaps and smallest donor-grounded fixes

### P0 — blocks acceptance

**P0-1 — Minimap left-click / drag does not move the 3D camera (E13).**
Donor moves the camera on minimap LMB down/repeat (`onmousedown.inc:116-131`); 2D does it in
`hud.gd:1368-1386` via `camera.jump_to_world()` (`camera.gd:96-104`). In 3D, `hud.gd:1400`
`cam` is null, but `:1402` still calls `set_input_as_handled()`, so the
`input_controller.gd:459-462` fallback never runs on press; drag motion reaches
`:573-575`, whose fallback at `:222-232` is invalid for `Camera3D`, and
`camera3d.gd:214-215` memo prevents `clamp_pos()` from fixing the transform.
*Smallest fix:* keep the donor-derived `world_pos` at `hud.gd:1399`, add a
`_render_mode_3d` branch in `_on_minimap_input()` that calls
`_bound_cam3d.set("_target", world_pos)` + `_bound_cam3d.clamp_pos()` (existing
`camera3d.gd:89-94,211-237`), and mirror that branch in `input_controller._minimap_reposition()`
so the fallback is also valid. No new art/constants.

### P1 — visible / functional mismatch

**P1-1 — `world.view_rect` is always the full map in 3D (E9).** Fix: in
`world3d.gd:177-190`, accept `Vector2` corners as well as `Vector3` (same conversion as
`hud3d_adapter.gd:91-99`) before computing the AABB.

**P1-2 — Fog overlay Y does not follow the terrain lattice (E15).** Fix: at
`world3d_fog.gd:187-195`, sample `game.height_at()` (port of `game.gd:1893-1907`) at each
quad **corner** (bilinear terrain surface) instead of reusing the cell-centre `h[i]`;
keep `FOG_Y_OFFSET` and the port alpha ladder from `world.gd:2251-2255` unchanged.

**P1-3 — `world.fog_revision` missing (E16).** Fix: add `var fog_revision := 0` to
`world3d.gd` and mirror the existing change gate in `world3d_fog.gd:303-317` (increment when
`changed`), matching `app/scripts/world.gd:137,2247`. One property + one increment.

**P1-4 — 2 m entity fallback is depth-wrong (E8).** Fix: replace the single
`_ppm(30.0)` at `picking3d.gd:218` with per-candidate `_ppm(_depth_of(e.pos, BODY_LIFT_M))`,
keeping the donor/2D literal `FALLBACK_REACH_M = 2.0` from `app/scripts/input_controller.gd:363`.

**P1-5 — Zoom-at-cursor uses flat Y=0 while picks use the height field (E6).** Fix: add an
optional height-sampler callback to `camera3d.gd` used **only** inside `_smooth_zoom()` anchor
resolution (`:361-374`), sourcing `game.height_at()`; leave `screen_to_world()` flat so
`hud3d_adapter.gd:82-88` and `picking3d._recalc_offset():70-88` keep their current contract.
Donor `ZoomCamera`/`MoveToTargetXZ` remains the behavioural source (`onmousewheel.inc:296-303`).

**P1-6 — Shift+number group recentre writes the Camera3D transform directly (E18).** Fix:
replace `input_controller.gd:826` with `_target`/`clamp_pos()` writes as in P0-1.

**P1-7 — FOV/visible scale is an assumed value (E3).** Not a code bug but a parity blocker:
`camera3d.gd:48-51` admits the 17.27° figure is an A/B assumption, whereas donor specifies
`FocalLength=400` (`default.cameras:17`, `camera.cfg:44-45`). Smallest fix: derive FOV from
the donor focal length and the port's sensor/px scale once the A/B is decided (AUDIT3D-09
runtime proof); do not hard-code another invented number.

### P2 — polish / conditional

- **P2-1** Middle-drag uses a fixed 16 px/m (`camera3d.gd:254`); derive the local ground
  px/m from the same ray used by `screen_to_world()` when a cursor-locked drag is required.
- **P2-2** Draw the drag-selection rectangle in 3D: mirror `app/scripts/world.gd:3642-3644`
  by projecting `world3d.sel_rect` corners with `camera3d.world_to_px()` (`camera3d.gd:159-161`).
- **P2-3** Patrol route overlay is a 2D `Node2D` under a `Node3D` `fx_layer`
  (`input_controller.gd:93-97,356-371`); project through `camera3d.world_to_px()` or re-parent
  to a `CanvasLayer`.
- **P2-4** Journey-mode camera writes Vector2 into `Camera3D.position`
  (`main.gd:1553-1578`); route through `_target`/`clamp_pos()` like P1-6.
- **P2-5** Unused adapter APIs (`hud3d_adapter.gd:79-88`, `camera3d.gd:156-161`) should be
  removed or wired before being relied on by future callers.
- **P2-6** Donor `RestrictInfo` bounds (`camera.cfg:2-11`: `HeightTarget`,
  `HeightTargetMin`, `lx/rx/fy/by`) and `SphereLength` vs `SphereHeight` distinction are not
  consumed by either port camera; UNVERIFIED whether they affect gameplay framing.

## 6. Open questions

1. **Donor camera projection.** `Min/MaxFocalLength=400` and `FocalLength=400`
   (`camera.cfg:44-45`, `default.cameras:17`) are readable, but the donor sensor/viewport
   convention is not; the actual donor vertical FOV and therefore the ground metres per
   pixel remain UNVERIFIED. This blocks a definitive verdict on E3.
2. **Donor yaw / minimap rotation.** `DirZ=-1, UpY=1` (`default.cameras:11-15`) is observed;
   absolute yaw and whether the donor minimap box rotates with the camera are UNVERIFIED
   (see `V711_camera3d.md:85`). The port uses yaw 0 and an AABB box.
3. **Donor pick depth / radius.** Donor picking is engine-side
   (`misc.script:7-27`, cited at `picking3d.gd:21-26`); the exact overlap-depth rule is
   UNVERIFIED, so P1-4 is judged against 2D parity, not a donor literal.
4. **Height-field vs flat-plane split.** `screen_to_world()` (flat) and
   `picking3d.ground_point()` (terrain) intentionally differ. Should the HUD minimap box and
   zoom anchor move to the height-field projection, or should a separate flat-plane API stay
   for layout? This decides the shape of P1-5.
5. **Fog shader binding.** Donor `DynFogDepth=False` (`camera.cfg:59`) means donor depth fog
   is off in gameplay; the 2D fog-of-war→shader binding is UNVERIFIED (`world3d_fog.gd:18-31`).
   P1-2 is a terrain-alignment fix only, not a claim of donor fog fidelity.
6. **3D→2D reset.** No `unbind_3d`; flagged by `V753_hud_integration.md:179-181`. Not
   reproducible without a HUD reuse path in `main.gd` today.

## 7. Verdict

Acceptance is **blocked** by P0-1 and the P1 unit/contract mismatches (E9, E15, E16). The
good news is that the donor-derived numbers (zoom bounds, tilt, edge bands, speed profile)
and every sim order call are already correct; all smallest fixes above are local seams that
reuse existing sim metre coordinates and existing camera/HUD methods, with no new art or
invented donor constants. Runtime rendering and visual parity stay UNVERIFIED pending
AUDIT3D-09.
