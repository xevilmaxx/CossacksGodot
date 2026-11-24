---
id: FIX-SEL
title: "FIX-SEL — 3D units/buildings unselectable: centred-vs-sim offset regression in picking3d; 3D patrol route Node2D fixed"
owner: FIX-SEL
scope: "variant3d/scripts/picking3d.gd + variant3d/scripts/input_controller.gd ONLY, plus this one report. No edits to world3d.gd/world3d_fx.gd/world3d_entities.gd/camera3d.gd/main.gd/hud/app/config/tests (the temp probe was created and deleted). No git operations."
date: 2026-11-24
status: FIXED__FUNCTIONAL_PATH_VERIFIED__NO_VISUAL_PARITY_CLAIM
verdict: "Real-camera probe: before the fix 0/5 functional assertions passed (unit pick, building pick, left-click selection, selection mirror, right-click move); after the fix 10/10 passed, including an exact sim ground destination (155,155) from a projected world point (-5,0,-5) on a 160x160 map. Root cause: picking3d._recalc_offset() compared camera3d.screen_to_world(centre) with the flat Y=0 ray hit; after V7-81 both are CENTRED metres, so the calibration zeroed the required +half-map offset (160,160). Ground clicks landed 160 m short of sim and every entity was projected 160 m away from its rendered position. Also fixed the COMP-04 patrol/guard overlay: a Node2D child of world3d's Node3D fx_layer never rendered; the 3D path now uses a MeshInstance3D/ImmediateMesh, 2D path unchanged. Parse clean, selftest 29/29, t_pick3d 6/6, probe deleted, no Godot process left."
---

# FIX-SEL — 3D picking / orders functional fix

## 1. Boundaries

Owned files only: `variant3d/scripts/picking3d.gd`,
`variant3d/scripts/input_controller.gd`, and this report. Backups:
`inbox/backup/picking3d.gd.bak-FIXSEL`,
`inbox/backup/input_controller.gd.bak-FIXSEL`. No git operations. The temporary
probe `variant3d/tests/_fixsel_probe.gd` and its result JSON were deleted after
the final run (verified: `Test-Path` false; `assert_clean.py --json` → `CLEAN`,
0 live Godot processes, lock free).

## 2. Full click path (current source, file:line at each hop)

### 2.1 Left-click selection

1. `input_controller.gd:555` — `var pw := _screen_to_world(mb.position)` for every
   world mouse-button event (minimap branches at `:537-550` return earlier).
2. `input_controller.gd:455-460` — 3D seam: records the raw pixel in
   `_pick_screen`, returns `picking.ground_point(p)` (`:459`).
3. `picking3d.gd:235-241` — `ground_point()` builds `project_ray_origin/normal`
   and returns `_to_sim(_ray_heightfield(o,d))`; `_ray_heightfield` is at `:148`,
   `_to_world`/`_to_sim` at `:121/:125`.
4. `input_controller.gd:626` — mouse-up calls `var e := _pick(pw, false)` (flag
   `false` = every player may compete). `:470-480` forwards the flag verbatim:
   `return picking.pick(_pick_screen, players_only)` (`:480`), with a finite
   guard on `_pick_screen` (`:478`).
5. `picking3d.gd:266-304` — `pick(screen, players_only)`: for each live entity,
   projects its **rendered world point**
   `_to_world(sim, height_at(sim)+BODY_LIFT_M)` (`:281-282`) with
   `_project_world()` (`:198`), converts `game.pick_radius(e)` and the 2 m
   fallback to pixels with `_pixel_reach()` (`:214`), and depth-orders ties via
   `_closer()` (`:352`).
6. `input_controller.gd:643` — `_set_selection([e] …)`; `:207-216` flips
   `e["selected"]`, updates `selected_ids`, `game.bld_dirty` and
   `hud.refresh_selection()`; `game.get_selected()` (game.gd:2585-2590) reads
   those same flags. `world3d.gd:279-301` mirrors selected ids from
   `game.get_selected()` (read-only).

### 2.2 Right-click order

1. `input_controller.gd:649` — `_right_order(pw)` (`:667`); with a selected unit
   it calls `var target := _pick(pw, false)` (`:720`) and `_pick_res()` (`:721`,
   seam at `:801-809` → `picking3d.pick_res`, `:307`).
2. When no entity is hit, `input_controller.gd:740` calls
   `game.cmd_move(e, dest)` (or `cmd_attack_move` at `:738`); `pw` came from
   step 3 above, so a wrong sim offset sent orders to the wrong map point.

### 2.3 Where it broke (both units and buildings)

Measured BEFORE (ticket 266) with a real `camera3d.gd` bound to a stub game
(`MAP_W=MAP_H=160`, `TILE_M=2`):

```
viewport=(64.0, 64.0) map_half=(160.0, 160.0)
w2s_center=(-12.05569, -22.75006) offset=(0.0, 0.0) ground_center=(-12.05569, -22.75006)
entity id=10 sim=(160.0, 160.0) world=(0.0, 0.8, 0.0) screen=(640.0, 595.2185)
entity id=20 sim=(165.0, 160.0) world=(5.0, 0.8, 0.0) screen=(970.0346, 595.2185)
```

- `offset=(0,0)` instead of `(160,160)`: the old `_recalc_offset()` compared
  `cam.screen_to_world(ref)` with `_plane_hit(project_ray_origin/normal, y=0)`
  at the same pixel. Before V7-81 the former returned SIM metres and the
  difference was the map half; after V7-81
  (`camera3d.gd:266-278`, centred X/Z, and `:234-247`, centred
  `_target`) **both return the same centred point**, so the difference is
  exactly zero and the correct default was overwritten.
- Consequences: `ground_point()` returned centred metres, i.e. 160 m short of
  sim — move/build/rally/attack-ground orders all landed at the wrong place.
- Worse for selection: `_to_world(sim, …)` put every entity at *sim* world
  coordinates while `world3d_entities.gd:997-1016` renders it at
  `sim - half` and the camera focuses the centred scene. Entities were
  projected to `screen=(640,595)` while the cursor/ray space was centred, so
  no unit or building could ever satisfy the radius test. Because the same
  offset drives both entity kinds, the failure was total — matching the user
  report ("nothing works in play despite headless probes passing").
- The old probes passed because they used an identity/orthographic stub camera
  (V768 ticket 127) or only asserted "returns a Dictionary" (`t_pick3d.gd`),
  never projecting a real rendered entity through the real camera.

### 2.4 Additional real defect fixed in the same owned file (COMP-04)

`input_controller.gd:52-97` (pre-fix numbering) created the patrol/guard route
as a `Node2D` attached to `world.fx_layer`, which is a `Node3D` in 3D
(`world3d.gd:119`, `:606`). CanvasItem draw commands never render there, so
patrol/guard waypoints were invisible in 3D. The 3D branch now creates a
`MeshInstance3D` with an `ImmediateMesh` (`input_controller.gd:132-148`,
`:406-453`) in centred world metres (`_route_world`, `:412-419`); the 2D
branch keeps the original Node2D + draw-signal code byte-for-byte. Redraw call
sites now go through `_route_redraw()` (`:338`, `:356`, `:565`,
`:1174`). Probe measured `route_node=null`, `route_mesh_node` parented to
the 3D FX layer with 1 mesh surface.

## 3. Root cause

**Primary:** V7-81 changed `camera3d.screen_to_world()` from SIM to CENTRED
metres without updating `picking3d._recalc_offset()`'s self-calibration. A
calibration that compares a function to itself cannot recover a frame offset;
it returned `(0,0)` and silently disabled the correct half-map mapping.
**Secondary:** the analytic world→screen projection (`_project_world`) used
`_viewport_size()` from `get_viewport().size`, which in headless was 64×64
while `Camera3D.unproject_position()` used the 1280×720 effective viewport —
another source of pixel/radius mismatch. Fixed by using the real camera API.
**Third (presentation, separately owned):** no selection rings/aura in 3D;
FIX-SELECTVIS owns `world3d_fx.gd`/`world3d.gd` and is adding them. The
functional selection/move path works after this fix; visual confirmation is
handled separately and is explicitly out of this ticket.

## 4. Exact diff (both owned files)

`picking3d.gd` (+81/-31 lines):
- `:59-108` — rewrote `_recalc_offset()`; deterministic
  `_world_to_sim = (MAP_W*TILE/2, MAP_H*TILE/2)`; if `cam.has_method("jump_to_world")`
  (camera3d.gd, V7-66) **never** re-calibrate; legacy SIM-metre cameras keep the
  old flat-plane calibration but the candidate is accepted only within
  `max(2 m, 2% of half)` of the known half-map offset.
- `:191-206` — `_project_world()` uses `cam.unproject_position(w)` when finite,
  analytic FOV projection only as fallback.
- `:208-224` — new `_pixel_reach(world, metres)` measures pixels/metre from two
  real unprojected points at the entity's own depth; analytic `_ppm` fallback.
- `:279-297` — `pick()` projects the centred rendered world point and uses
  `_pixel_reach` for `pick_radius` and the 2 m fallback. V7-68
  `players_only` semantics and `_closer()` tie rules untouched.
- `:320-330` — `pick_res()` uses the same renderer frame for screen position
  and reach; its filters / lowest-id tie rule untouched.
- `ground_point()`, `cmd_*`-free contract, constants and public API unchanged.

`input_controller.gd` (+99/-12 lines):
- `:53-57` — new `route_mesh_node: MeshInstance3D`.
- `:97-100` — `bind()` delegates overlay creation to `_ensure_route_overlay()`.
- `:128-148` — `_ensure_route_overlay()`: 3D → mesh overlay on `world.fx_layer`;
  2D → original Node2D creation/signal.
- `:338`, `:356`, `:565`, `:1174` — redraw call sites use `_route_redraw()`.
- `:403-453` — `_route_redraw()` (`:406`), `_route_world()` (`:412`),
  `_draw_patrol_route3d()` (`:421`) (lines + 2-end ticks + arrow head,
  `PRIMITIVE_LINES`, one reusable `ImmediateMesh`).
- V7-75 `picking.pick(_pick_screen, players_only)` at `:480`, all `cmd_*`
  semantics, hotkeys, minimap, build ghost and 2D internals unchanged.

## 5. Verification — variant3d runner only (serial jobs)

All launches: `python variant3d\tools\godot_runner.py run --id <id> --timeout <t>
--max-wait 900 -- --headless --path variant3d …`.

| Ticket | Job id | Command tail | Result |
|---:|---|---|---|
| 258 | `fixsel-before-parse-pick` | `--check-only --script res://scripts/picking3d.gd` | ok, exit 0, 4.97 s |
| 259 | `fixsel-before-parse-input` | `--check-only --script res://scripts/input_controller.gd` | ok, exit 0, 6.47 s |
| 260 | `fixsel-before-probe` | `--script res://tests/_fixsel_probe.gd` | **timed-out** — probe defect: work ran in SceneTree `_initialize()` where Camera3D is not in the tree and `get_viewport()` is null; script error skipped `quit()`. Runner hard-killed the child; coordinator-flagged PID 15656 was already gone when checked (`Get-Process` empty). Fixed by deferring the probe body to the first frame. |
| 266 | `fixsel-before-probe-r2` | same | failed exit 1, **1/6 PASS, 5/6 FAIL** — the measured before state below |
| 272 | `fixsel-after-parse-pick` | parse | ok, exit 0, 5.75 s |
| 274 | `fixsel-after-parse-input` | parse | ok, exit 0, 9.26 s |
| 276 | `fixsel-after-probe` | probe | ok, exit 0, 6.57 s, **9/9 PASS** (before the destination-precision assertion was added) |
| 279 | `fixsel-after-probe-r2` | probe | ok, exit 0, 6.54 s, **10/10 PASS**, final measured state |
| 280 | `fixsel-selftest` | `-- --self-test variant3d/selftest.json` | ok, exit 0, 76.57 s; `selftest.json` `passed:true`, **29 steps / 29 passed / 0 failed** |
| 282 | `fixsel-t-pick3d` | `--script res://tests/t_pick3d.gd` | ok, exit 0, 3.45 s; `t_pick3d.json` `passed:true`, **6/6** (legacy stub-camera contract preserved) |

No visual-parity claim; no windowed A/B was run by this ticket.

### Probe design

Stub game = `class StubGame extends C3Game` (so the typed `C3Input.game`
accepts it), `MAP_W=MAP_H=160`, `height_at()=0`, one unit `id=10` at sim
`(160,160)` and one building `id=20` at sim `(165,160)`, `pick_r=2 m`.
Real `camera3d.gd` Camera3D added to the tree and `bind(game,1.0)`; real
`picking3d.gd` adapter; real `input_controller.gd` wired by `bind_3d(cam)`.
Each entity's **rendered** world point (`sim - (160,160)`, y=0.8 m, matching
`world3d_entities.gd:1016`) is projected with
`Camera3D.unproject_position()`; those pixels are clicked via
`InputEventMouseButton` through `_unhandled_input()`. A second controller with
a `Node3D` FX-layer stub checks the route overlay.

### Measured hits / misses

| Assertion | Before (266) | After (279) |
|---|---:|---:|
| pick(unit pixel) → id 10 | **0/1** (`got=-1`) | **1/1** (`got=10`) |
| pick(building pixel) → id 20 | **0/1** (`got=-1`) | **1/1** (`got=20`) |
| left-click selects unit | **0/1** (`selected_ids=[]`) | **1/1** (`selected_ids=[10]`, `e.selected=true`, HUD refreshed) |
| selection mirror matches | **0/1** | **1/1** (`[10]`; building still false) |
| right-click issues `cmd_move` | **0/1** (`calls=[]`) | **1/1** (`id=10`) |
| move lands at sim ground point | not measured before | **1/1** (`dest=(155,155) == expected` for world `(-5,0,-5)`) |
| 3D route is MeshInstance3D on FX layer | n/a | **1/1** |
| 3D route draws ImmediateMesh (1 surface) | n/a | **1/1** |
| 3D path has no Node2D route | n/a | **1/1** |
| scripts load | 1/1 | 1/1 |
| **Total** | **1/6** | **10/10** |

Final probe stdout (ticket 279):

```text
FIXSEL viewport=(64.0, 64.0) map_half=(160.0, 160.0) w2s_center=(-12.05569, -22.75006) offset=(160.0, 160.0) ground_center=(147.9443, 137.2499)
FIXSEL entity id=10 sim=(160.0, 160.0) world=(0.0, 0.8, 0.0) screen=(640.0, 595.2185) depth=63.848
FIXSEL entity id=20 sim=(165.0, 160.0) world=(5.0, 0.8, 0.0) screen=(970.0346, 595.2185) depth=63.848
FIXSEL PASS pick(unit screen)->unit id 10 :: got=10
FIXSEL PASS pick(building screen)->building id 20 :: got=20
FIXSEL PASS left click selects unit :: selected_ids=[10] flags u=true b=false hud=1
FIXSEL PASS selection mirror matches :: mirror=[10]
FIXSEL PASS right click issues cmd_move :: calls=[{ "id": 10, "pos": (155.0, 155.0) }]
FIXSEL PASS move order lands at sim ground point :: dest=(155.0, 155.0) expected=(155.0, 155.0)
FIXSEL PASS 3D route overlay is MeshInstance3D :: node=PatrolRoute3D parent=<Node3D>
FIXSEL PASS 3D route draws ImmediateMesh :: surfaces=1
FIXSEL PASS 3D path has no Node2D route :: route_node=<null>
```

Post-run cleanup: probe and `variant3d/tests/results/fixsel_probe.json`
deleted; immediately after cleanup `assert_clean.py --json` → `clean:true`,
`processes.count:0`, `godot.lock free`. A later sweep showed two live Godot
processes belonging to OTHER agents (a plain `--path variant3d` session and
FIX-TERRAIN's `--screenshot …/fixterrain_after_full.png`); none matched any
FIX-SEL job command (`_fixsel_probe.gd`, `--check-only`, `--self-test`). All
FIX-SEL jobs 258/259/260/266/272/274/276/279/280/282 are terminal. The only stderr was pre-existing headless renderer RID /
ObjectDB exit leaks from creating the stub camera, mesh and material — no
script errors.

## 6. Handoffs (NOT edited by this ticket)

1. **Visual feedback** — functional selection/move now works, but 3D still has
   no selection rings / player aura / owner colour. FIX-SELECTVIS owns
   `world3d_fx.gd` + `world3d.gd` and is adding them; no edit here.
2. `camera3d.gd:266-278` / `:234-247` — its screen_to_world contract is
   CENTRED metres; any future change must keep `jump_to_world()`/`_target`
   SIM-metre so the adapter's frame detection stays valid. A separate report
   `CAMSEAM_double_subtract.md` is tracking that seam with another owner.
3. `world3d.gd:279-301` — selection mirror is read-only and driven by
   `game.get_selected()`; the probe verified the `e.selected` flags and
   `selected_ids`, and no world3d edit was needed.
4. `world3d_entities.gd:997-1016` — entity render positions are
   `sim - (MAP_W*TILE/2, MAP_H*TILE/2)`; picking now matches exactly. If that
   convention changes, update `_recalc_offset()` in the same atomic change.
5. Patrol/guard route uses a plain unshaded line mesh at `height_at(p)+0.18 m`;
   a renderer-owned 3D overlay with arrows/depth-test policy would be a
   follow-up for the world3d FX owner (not blocking functionality).

## 7. Open questions / residual risk

1. `BODY_LIFT_M = 0.8 m` is still an unverified body-centre estimate; the
   cursor is a height-field ground hit, so a small parallax residual remains
   for tall buildings. The 2 m footprint radius comfortably covers it in the
   measured geometry, but donor pick depth is engine-side and UNVERIFIED.
2. `_pixel_reach()` measures pixels/metre along world X. The shipped camera
   yaw is 0 (`camera3d.gd:221-242`); a future non-zero yaw would need an
   ellipse-aware ground-footprint projection.
3. Legacy SIM-metre cameras are accepted only if their calibration is within
   2 % of the known half-map offset; an exotic camera with a different but
   valid frame would fall back to the deterministic map-half offset. No such
   camera exists in the current source.
4. The 3D route overlay is drawn in world metres and has no occlusion policy;
   whether waypoints should depth-test against buildings is UNVERIFIED.
5. No visual parity / donor A/B was attempted (none exists); this report
   claims functional correctness only.
