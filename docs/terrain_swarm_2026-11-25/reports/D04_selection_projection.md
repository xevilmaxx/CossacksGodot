---
id: D04
title: "D04 — geometry of the 3D selection quad: corner projection, stretch scaling, and the correct world-space rect"
owner: D04 (READ-ONLY design worker, terrain swarm ticket D04)
date: 2026-11-25
status: READ_ONLY_DESIGN__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Exactly ONE file written: this report. No game code, config, test, fixture, scene, shader, asset, git state or runner job touched."
labels: [observed, derived, inferred, PORT_APPROXIMATION, UNVERIFIED]
output: docs/terrain_swarm_2026-11-25/reports/D04_selection_projection.md
---

# D04 — geometry of the 3D selection quad

## 0. Goal and method

Answer four narrow questions with `path:line` evidence at every hop:

1. Are the marquee corners computed by **unprojecting mouse pixels onto a fixed-height
   ground plane**, or by **raycasting the terrain heightfield**?
2. How is the **projection / stretch scaling applied at non-1280 widths**?
3. Why can the quad be **offset, skewed, missing, or wrong-sized**?
4. What is the **precise mathematical specification** of the correct world-space rect
   (carrying donor world-epsilon semantics from DSEL-01/02), and what exact code hunk
   should B05 apply?

All game-code line numbers below refer to the **current live tree**, not to the older
line numbers cited in prior reports. No Godot process was started; every claim is a
static source reading or an explicitly labelled derivation. Donor internals stay
**UNVERIFIED**; every substitute is labelled **PORT APPROXIMATION**.

## 1. Sources read (all read-only)

| Source | What it supplied |
|---|---|
| `docs/terrain_swarm_2026-11-25/CHARTER.md` `:1-132` | Guardrails: observed/derived/UNVERIFIED separation; no test weakening; no invented donor constants; disjoint ownership; one report per analysis agent |
| `variant3d/scripts/input_controller.gd` `:23-205,214-218,575-603,663-845,1340-1374` | Live marquee state, overlay classes, `_screen_to_world`, `_drag_world_rect`, press/motion/release branches, `_process` mirror |
| `variant3d/scripts/camera3d.gd` `:264-305,352-421` | Camera pose, `world_to_px`, flat-`Y=0` `screen_to_world`, `_screen_to_plane`, `_screen_to_surface`, viewport corners / view rect |
| `variant3d/scripts/picking3d.gd` `:34-43,75-108,111-118,136-207,235-243` | `ground_point`, heightfield ray march + bisection, viewport-size fallback, `_ppm`, `unproject_position` projection |
| `variant3d/scripts/main.gd` `:1156-1169,1216-1253,1849-1875` | `Screenshot3DViewport` is created **only** in `--screenshot` runs, at fixed 1280×720 |
| `variant3d/project.godot` `:13-19` | Design viewport 1280×720, `resizable=true`, `stretch/mode="canvas_items"`, `aspect="expand"` |
| `docs/coord_swarm_2026-11-25/reports/CAM_RV_01_view_rect_runtime.md` `:88-94,145-172,199-210` | Proven windowed real-input pattern: root viewport == camera viewport == 1280×720, identity event scale `[1,1]`, job 381 20/20 |
| `docs/coord_swarm_2026-11-25/reports/S1_INPUT_FIX.md` `:78-107,125-133,164-191,208-226` | Stretch mismatch diagnosis and the **test-harness-only** `p * win / proj` transform; measured `p0=(395.262,273.539)`, `p1=(917.084,457.888)`, ground rect `(51.810,54.407)–(76.111,71.214)` |
| `docs/coord_swarm_2026-11-25/reports/V3D_01_selection_rectangle_audit.md` `:123-175,244-268,285-336` | Coordinate-space audit, break-point table, "do not project `world.sel_rect`" trap |
| `docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md` `:90-119,153-190,310-359` | Donor epsilon `0.005`/`0.25`, first-move anchor, `spmAdd`/`spmRunTime`, native predicate UNVERIFIED |
| `docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md` `:63-85,117-140,181-196,268-285` | Donor `GetCurrentMouseWorldCoord` = engine heightfield hit; drag rect in world ground coords; FOV/unproject resolution dependence |
| `docs/coord_swarm_2026-11-25/reports/SEL_01_implementation.md` `:72-77,110-117` | Headless probe 324: 64×36 window vs 1280×720 viewport → mouse positions scaled ×20; screenshot SubViewport off-screen projection artifact |

## 2. Live code trace — what actually computes the corners

### 2.1 The selection geometry (OBSERVED)

- `input_controller.gd:575-588` `_screen_to_world(p)`. In 3D (`:580-582`) it records
  `_pick_screen = p` and returns `picking.ground_point(p)`.
- `picking3d.gd:235-243` `ground_point(screen)` builds the ray with
  `cam.project_ray_origin(screen)` / `cam.project_ray_normal(screen)` and returns
  `_to_sim(_ray_heightfield(o, d))`.
- `picking3d.gd:148-171` `_ray_heightfield()` **marches 1 m steps** (`:153-156`) against
  `game.height_at()` at `_to_sim(p)` (bilinear height field), then **refines 20 bisections**
  (`:160-169`), finally setting `hit.y = _height_at_sim(...)` (`:168`). Only when the ray
  is parallel, points away, or never crosses does it fall back to the flat `Y=0` plane
  (`:149-150`, `:171`, via `_plane_hit()` `:136-142`).
- `picking3d.gd:121-127` `_to_sim(w) = Vector2(w.x, w.z) + _world_to_sim`, with
  `_world_to_sim = (MAP_W·TILE_M/2, MAP_H·TILE_M/2)` fixed at `:80-83` for a `Camera3D`
  exposing `jump_to_world()` (`:86-88` — **no** flat-ray recalibration).
- `input_controller.gd:590-603` `_drag_world_rect(a_px, b_px)` (the landed
  **B-SELRECT-FIX**) unprojects **four** pixels — `a`, `b`, `(a.x,b.y)`, `(b.x,a.y)` —
  through that same `_screen_to_world`, then returns the min/max AABB in SIM metres.
- `input_controller.gd:761-788` on LMB release, if `dragging`, calls
  `_drag_world_rect(drag_start, mb.position)` and selects player-0 units with
  `rect.has_point(e.pos)`.
- `input_controller.gd:1347-1351` `_process()` mirrors the same rect into
  `world.sel_rect` (SIM metres) while dragging; `:1367-1371` shows/hides the pixel overlay.

**Answer to Q1 (CONFIRMED, observed):** the marquee corners are **terrain raycasts**, not
fixed-height unprojections. `picking3d.ground_point()` → `_ray_heightfield()` marches and
bisects the bilinear height field; the flat `Y = 0` hit is only a fallback. Fixed-height
plane hits do exist in `camera3d.gd` (`screen_to_world` `:296-305`, `_screen_to_plane`
`:352-361`, `_screen_to_surface` `:369-381`) but are used by viewport-corner/view-rect
math and zoom anchoring, **not** by the drag box. This is directionally donor-aligned:
DSEL-02 claim 7 identifies `GetCurrentMouseWorldCoord`/`ScreenToWorldRayCast` as engine
heightfield hits. Precision differs (port ≈ 1 m / 2²⁰ ≈ 1 µm vs donor `SetTerrainRayCastPrecison(0.0000001)`),
a **PORT APPROXIMATION**.

### 2.2 The visible quad (OBSERVED)

- `input_controller.gd:85-126` `SelectionRectPainter` (Node2D) + `SelectionRectOverlay`
  (CanvasLayer, `layer = 10`). `_draw()` calls `draw_rect(rect_px, …, false, width, false)`
  — yellow `(1,1,0,1)`, 1 px, no fill (donor `brushes\selection.cfg:3-14`, DSEL-01
  claim 18; declared **PORT APPROXIMATION** in the file header `:77-84`).
- `input_controller.gd:197-205` `_show_selection_rect(r)` passes `r` **verbatim** to the
  painter; `:829-845` (motion) and `:1367-1371` (`_process`) feed it
  `Rect2(drag_start, cur).abs()` from raw mouse pixels.
- The overlay is created **only** by `bind_3d()` → `_ensure_selection_rect_overlay()`
  (`:172-195`). 2D mode has no overlay (2D draws in `world.gd:3641-3647`).

**Key structural fact:** the world-space rect and the yellow outline are computed from
**the same two raw mouse pixels**, but through two **different, uncorrected**
transforms (raycast vs canvas draw). They agree only when both transforms are the
identity — which is exactly the 1280×720 case the green atoms measured.

## 3. Coordinate frames (DERIVED definitions used below)

| Symbol | Frame | Definition |
|---|---|---|
| `s` | SIM metres, **top-left** map origin | entity `e.pos`; `s ∈ [0, MAP_W·TILE_M] × [0, MAP_H·TILE_M]` |
| `H` | half-map vector | `H = (MAP_W·TILE_M/2, MAP_H·TILE_M/2)`; at 64² × 2 m, `H=(64,64)` m |
| `w` | centred world metres | `w = s − H`; terrain mesh and camera `_target−H` live here (`camera3d.gd:276-282`) |
| `V_cam` | camera projection viewport pixels | `camera.get_viewport().size`; 1280×720 in project config / screenshot SubViewport |
| `p` | pixel in `V_cam` | input to `project_ray_origin/normal` and output of `unproject_position` |
| `m` | pixel delivered by an `InputEvent` | `mb.position` / `event.position`; viewport space of the node that receives input |
| `G(p)` | ground map | `G(p) = to_sim(ray_heightfield(o,d))`, `o=project_ray_origin(p)`, `d=project_ray_normal(p)`; returns SIM metres |
| `C` | root canvas transform | `get_viewport().get_canvas_transform()`; identity at 1280×720, a stretch scale otherwise |

## 4. Q2 — projection / stretch scaling at non-1280 widths

### 4.1 What the code does today (OBSERVED)

- **No scaling is applied anywhere in game code.** Raw event pixels are fed straight to
  `picking.ground_point(p)` (`input_controller.gd:581-582`) and straight to
  `draw_rect()` via `_show_selection_rect(r)` (`:197-200`, `:1369`).
- `picking3d._viewport_size()` (`:111-118`) uses the **live** camera viewport size and
  only falls back to `ProjectSettings` 1280×720 when the viewport is absent/zero;
  `_ppm()` (`:174-190`) and `_project_world()` (`:198-207`) likewise use live sizes and
  `Camera3D.unproject_position()`. So the *raycast* side is resolution-aware.
- The only explicit stretch compensation in the whole wave is in the **test harness**,
  `t_select_rect.gd` `_to_event_coord()` from S1_INPUT_FIX `:91-98`:
  `ev.position = p * Vector2(root.size) / Vector2(cam.get_viewport().size)`. It evaluates
  to `[1,1]` at the proven 1280×720 windowed job (S1_INPUT_FIX `:100-107`, CAM-RV-01 `:151`).
- The headless mismatch was measured: window 64×36 vs camera viewport 1280×720 →
  injected mouse positions scaled **×20** (SEL_01_implementation `:74`, probe 324).
- `Screenshot3DViewport` is created **only in `--screenshot` runs** (`main.gd:1156-1157,
  1216-1253`) at fixed `Data.WINDOW_WIDTH × WINDOW_HEIGHT` (`:1241-1245`); normal play
  keeps the Camera3D in the root viewport.

### 4.2 The two transforms that are missing (DERIVED)

1. **Event pixels → camera-viewport pixels** (needed for the ground raycast and for
   `_pick_screen`, which `picking3d.pick()/pick_res()` consume at `:266-346`):
   `p_cam = m ⊙ (V_cam ⊘ V_in)` per axis, where `V_in = get_viewport().size` of the node
   receiving input. Identity in the 1280×720 windowed case; ×20 in the headless case.
   An `aspect="expand"` offset may also be present — ignored here, **PORT APPROXIMATION**
   (donor's native event→projection mapping is UNVERIFIED, DSEL-02 claims 2/§FOV).
2. **Event pixels → canvas pixels** (needed for the yellow outline): the painter is a
   Node2D under a CanvasLayer, so `draw_rect` coordinates are canvas-space; event
   positions are viewport-space. The correct inverse is the same one the 2D
   `_screen_to_world()` already uses at `input_controller.gd:587`:
   `r_canvas = C.affine_inverse() * r_event` (position) and
   `C.affine_inverse().basis_xform(size)` (extent). At 1280×720 `C` is identity, so all
   green atoms stayed green; at other widths the box is translated/scaled relative to
   the cursor.

Neither transform is a hardcoded donor number — both are derived from live viewport
sizes, so they are safe at any window width. Label: **PORT APPROXIMATION**, not donor
parity.

## 5. Q3 — why the quad can be offset, skewed, missing, or wrong-sized

| Symptom | Concrete cause (evidence) | Class |
|---|---|---|
| **Offset** | Event pixels ≠ camera-viewport pixels; no `p_cam` mapping (`:581-582`; S1_INPUT_FIX `:78-107`, SEL-01 probe 324 ×20) | OBSERVED code, DERIVED effect |
| **Offset** | Overlay drawn in canvas space with raw event pixels; no `C⁻¹` (`:197-200`, `:1369` vs `:587`) | DERIVED |
| **Offset** | Anchor pixel `drag_start` is **re-unprojected every frame** (`_drag_world_rect` `:595`, `_process` `:1350`); if edge-scroll/middle-drag/zoom moves the camera during the drag, the world anchor slides. Donor freezes `prevSelX/Z` as a world point (`onmousemove.inc:145-146`) | OBSERVED divergence |
| **Huge offset / quad disappears** | Projecting SIM `world.sel_rect` through `camera3d.world_to_px()` (`:288-290`) without subtracting `H`: +`H·view_scale` = `(1024,1024)` px at 64²/16 px/m — the exact CAM-02 double-shift signature (CAM_RV_01 `:112-117`). The file already forbids this (`:1365-1366`) | OBSERVED trap |
| **Skewed** | Under −32° perspective the pixel→ground map is a homography on flat ground and non-projective on a heightfield. An axis-aligned pixel box maps to a curvilinear quad; its 4-corner AABB over-covers bowed edges; the old 2-corner version under-covered (B-SELRECT-FIX `:590-593`, V3D_01 `:250`) | DERIVED; native predicate UNVERIFIED (DSEL-01 claim 24) |
| **Skewed** | Yaw ≠ 0 would rotate the ground quad; port yaw is fixed 0 (`camera3d.gd:262-282`), donor effective yaw UNVERIFIED (DSEL-02 claim 6) | PORT APPROXIMATION |
| **Missing** | Overlay exists only after `bind_3d()` (`:172-195`); no overlay in 2D | OBSERVED |
| **Missing** | `_show_selection_rect` hides on `!r.has_area()` (`:121-126`); zero-width or zero-height pixel drag (no motion, pure axis with identical component) yields no visible box | OBSERVED |
| **Missing** | `dragging` is set only after the **world** epsilon is crossed (`:829-845`); a tiny ground delta never shows the box. This is donor-literal (`onmousemove.inc:152`), not a bug | OBSERVED |
| **Missing** | A drag that starts/ends over the minimap returns early from the motion branch (`:818-828`), leaving `_drag_current` at the press pixel → zero-area overlay; the release branch clears drag state (`:687-695`) | OBSERVED (V3D_01 row 4) |
| **Wrong-sized** | 2-corner under-coverage / 4-corner over-coverage (above); `view_scale` (16 px/m) must never be mixed into the metre rect | DERIVED |
| **Wrong-sized (harness)** | Screenshot `SubViewport` off-screen projection: `p0≈−1588 px` when the camera is framed on the home building (SEL_01_implementation `:114-117`; S1_INPUT_FIX `:109-123` fixed it with `jump_to_world(half)` + zeroed edge margins) | OBSERVED harness artifact |

## 6. Precise specification of the correct world-space rect

### 6.1 Donor semantics carried in (DSEL-01 / DSEL-02 — OBSERVED / UNVERIFIED)

- `epsilon = 0.005` m, raised to `0.25` m in attack-point / guard mode
  (`onmousemove.inc:32-34`; DSEL-01 claim 1). The port already mirrors this in
  `_selection_epsilon_m()` (`input_controller.gd:214-218`).
- The test is **axis-wise on world X/Z**: `|Δx| > ε or |Δz| > ε`, with x/z from the
  engine ground coordinate (`onmousemove.inc:66-69,141-147,152`; DSEL-01 claim 2;
  DSEL-02 claim 11). The motion branch at `:842-843` already does this on
  `picking3d.ground_point()` output — **keep it**.
- The anchor is recorded on the **first LMB-held move**, not on press
  (`onmousemove.inc:142-147`; DSEL-01 claim 3). The port currently records
  `_sel_ground_start` on first move but uses the **press pixel** as the rect anchor;
  that divergence is now explicit and labelled **PORT APPROXIMATION**.
- Threshold crossing starts `GameManagerBeginSelection` + `StartSelection('spmAdd' |
  'spmRunTime')`; LMB-up finalizes (DSEL-01 claims 4,6). Port Shift-union is already
  at `:773-787`; keep.
- The exact native rectangle→object predicate is **UNVERIFIED** (DSEL-01 claim 24:
  centre vs AABB vs frustum vs `GetGameObjectSelectionSizeByHandle`). Do **not** invent
  one. By S-25-06 the port keeps the world ground rect; no screen-space
  `select_in_rect()` is introduced by this ticket.

### 6.2 Authoritative definition (DERIVED; donor-equivalent where observable)

Let `m₀` be the LMB-press pixel, `m₁` the current/release pixel, both in **input-viewport**
space. Define the pixel rectangle and its four corners in camera space:

```
Φ(m) = m ⊙ (V_cam ⊘ V_in)                    (per axis; identity at 1280×720)
p_TL = Φ(m₀)                    p_TR = Φ((m₁.x, m₀.y))
p_BL = Φ((m₀.x, m₁.y))          p_BR = Φ(m₁)
q_i  = G(p_i)          i ∈ {TL,TR,BL,BR}       (SIM metres; G as in §3)
R_sim = Rect2( min_i q_i.x , min_i q_i.y ,
               max_i q_i.x − min_i q_i.x ,
               max_i q_i.y − min_i q_i.y )      (SIM metres, top-left map origin)
```

Selection: player-0 units `e` with `R_sim.has_point(e.pos)` (port composition filter
`!dead && player==0 && kind=="unit"` at `:768-772`; donor land/water/building/guard/squad
filters UNVERIFIED — DSEL-01 claims 11/12).

**Why the 4-corner AABB:** on a flat ground plane `G` is a projective homography, so the
image of the pixel rectangle is a trapezoid whose X/Z extrema are attained at corners —
the 4-corner AABB is then **exact**. On the bilinear heightfield the edges bow, so the
AABB is a conservative **PORT APPROXIMATION**; it is strictly better than the old
diagonal-2-corner version and deliberately kept (B-SELRECT-FIX `:590-593`).

**Anchor freezing (the fix):** `q_TL` must be captured **once** at press and reused for
every frame of the drag, because donor's anchor is a frozen world point. The other three
corners are re-unprojected from the live camera. Pixel overlay must use `C⁻¹` so the
yellow outline and `R_sim` remain the same marquee in two coordinate spaces.

**Drag-start rule:** `dragging` flips true when
`|G_current.x − _rect_ground_anchor.x| > ε or |G_current.z − _rect_ground_anchor.z| > ε`
with ε from `_selection_epsilon_m()`; `_sel_ground_start` (first-move ground point) stays
the donor-faithful reference after the first move. Keeping both is intentional:
`_rect_ground_anchor` = geometric anchor for the rect/overlay,
`_sel_ground_start` = donor's `prevSelX/Z` for the threshold. **PORT APPROXIMATION**
because donor starts the rect at the first-move ground point rather than the press point.

## 7. Exact proposed code hunks for B05 (report only — not applied)

All hunks target `variant3d/scripts/input_controller.gd`. Take
`inbox/backup/input_controller.gd.bak-D04` first (CHARTER `:66`). No other file changes.

### Hunk 1 — frozen anchor state (after `:34`)

```gdscript
 var _sel_ground_start := Vector2.INF
 var _drag_current := Vector2.INF
+# D04: frozen SIM-ground anchor of the marquee (top-left map origin), captured on
+# LMB press with the SAME pixel the overlay uses. Donor freezes prevSelX/Z on the
+# first LMB-held move (onmousemove.inc:145-146); the port freezes the press ground
+# so the yellow outline and R_sim share ONE anchor. PORT APPROXIMATION of the
+# donor's two-phase start (DSEL-01 claim 3).
+var _rect_ground_anchor := Vector2.INF
```

### Hunk 2 — event→camera pixel map, applied in `_screen_to_world` (replaces `:575-588` region)

```gdscript
+# D04: InputEvent pixels -> the pixel space of the Camera3D that owns the raycaster.
+# No baked 1280: canvas_items/expand stretch and the screenshot SubViewport
+# (main.gd:1241-1245) can make the two viewports differ; SEL-01 probe 324 measured
+# 64x36 root vs 1280x720 camera viewport (x20). S1_INPUT_FIX applied this ratio in
+# the TEST harness only; game code had none. PORT APPROXIMATION: the donor's native
+# event->projection map is UNVERIFIED (DSEL-02 claim 2).
+func _event_px_to_cam_px(p: Vector2) -> Vector2:
+	if render_mode != "3d" or camera == null or not is_instance_valid(camera):
+		return p
+	var src := get_viewport()
+	var dst := camera.get_viewport()
+	if src == null or dst == null:
+		return p
+	var a: Vector2 = Vector2(src.size)
+	var b: Vector2 = Vector2(dst.size)
+	if a.x <= 0.0 or a.y <= 0.0 or b.x <= 0.0 or b.y <= 0.0:
+		return p
+	if a.is_equal_approx(b):
+		return p
+	return Vector2(p.x * b.x / a.x, p.y * b.y / a.y)
+
 func _screen_to_world(p: Vector2) -> Vector2:
 	# V7-52 3D seam: ground unprojection moves to picking3d.ground_point(screen),
 	# which ray-marches the height field and returns the SAME sim-metre `pw` the
 	# 2D inverse below produced. Record the source pixel so _pick/_pick_res (which
 	# call sites feed `pw`, not the screen point) can use the adapter unchanged.
 	if render_mode == "3d" and picking != null:
-		_pick_screen = p
-		return picking.ground_point(p)
+		var cam_px := _event_px_to_cam_px(p)
+		_pick_screen = cam_px
+		return picking.ground_point(cam_px)
```

Note: `_pick_screen` must carry the **camera-space** pixel because `picking.pick()`
/ `pick_res()` (`picking3d.gd:266-346`) consume it in that space. The 2D branch below
is untouched. All `_screen_to_world` call sites feed event/root pixels, so the change
is uniform (`:555, :832, :838, :1362`, plus patrol `:515/:553`).

### Hunk 3 — use the frozen anchor in the 4-corner rect (replaces `:594-595`)

```gdscript
-func _drag_world_rect(a_px: Vector2, b_px: Vector2) -> Rect2:
-	var c := _screen_to_world(a_px)
+func _drag_world_rect(a_px: Vector2, b_px: Vector2, anchor_ground: Vector2 = Vector2.INF) -> Rect2:
+	var c: Vector2 = anchor_ground if is_finite(anchor_ground.x) and is_finite(anchor_ground.y) else _screen_to_world(a_px)
 	var d := _screen_to_world(b_px)
 	var e := _screen_to_world(Vector2(a_px.x, b_px.y))
 	var f := _screen_to_world(Vector2(b_px.x, a_px.y))
```

The default argument keeps every existing 2-argument call valid. The remaining three
corners and the min/max accumulation (`:596-603`) are unchanged.

### Hunk 4 — overlay stretch correction (replaces `:197-205`)

```gdscript
 func _show_selection_rect(r: Rect2) -> void:
 	if sel_rect_overlay == null or not is_instance_valid(sel_rect_overlay):
 		return
-	sel_rect_overlay.call("set_selection_rect", r)
+	# D04: event pixels are VIEWPORT pixels; the CanvasLayer painter draws in CANVAS
+	# pixels. Invert the stretch transform exactly as the 2D _screen_to_world()
+	# does (:587) so a non-1280 window cannot offset/rescale the yellow box.
+	var vp := get_viewport()
+	var canvas_r := r
+	if vp != null:
+		var xf: Transform2D = vp.get_canvas_transform().affine_inverse()
+		canvas_r = Rect2(xf * r.position, xf.basis_xform(r.size))
+	sel_rect_overlay.call("set_selection_rect", canvas_r)
```

`_hide_selection_rect()` passes an empty rect; no change needed. At 1280×720 `xf` is
identity, so S1's `overlay_rect_during_drag == Rect2(p0,p1).abs()` assertion remains
byte-identical.

### Hunk 5 — capture the anchor on LMB press (in `:749-753`)

```gdscript
 				drag_start = mb.position
 				dragging = false
 				_drag_current = mb.position
+				_rect_ground_anchor = _screen_to_world(mb.position) if render_mode == "3d" and picking != null else Vector2.INF
 				_sel_ground_start = Vector2.INF
 				_hide_selection_rect()
```

### Hunk 6 — use it on release and in the mirror (`:766` and `:1350`)

```gdscript
-					var rect := _drag_world_rect(drag_start, mb.position)
+					var rect := _drag_world_rect(drag_start, mb.position, _rect_ground_anchor)
```

```gdscript
-			world.sel_rect = _drag_world_rect(drag_start, get_viewport().get_mouse_position())
+			world.sel_rect = _drag_world_rect(drag_start, get_viewport().get_mouse_position(), _rect_ground_anchor)
```

### Hunk 7 — freeze the epsilon reference too (replaces `:838`)

```gdscript
-			var ref: Vector2 = _screen_to_world(drag_start) if _sel_ground_start == Vector2.INF else _sel_ground_start
+			var ref: Vector2 = _sel_ground_start
+			if _sel_ground_start == Vector2.INF:
+				ref = _rect_ground_anchor if is_finite(_rect_ground_anchor.x) else _screen_to_world(drag_start)
```

### Hunk 8 — clear the anchor on every drag teardown (three sites: `:693`, `:812`, `:813` region)

In the minimap-release block (`:691-695`) and the normal release block (`:810-814`),
insert one line after `_sel_ground_start = Vector2.INF`:

```gdscript
 			_sel_ground_start = Vector2.INF
+			_rect_ground_anchor = Vector2.INF
 			_hide_selection_rect()
```

(At `:810-814` the following line is `_drag_current = Vector2.INF`; insert before it.)

### Invariants preserved by these hunks (OBSERVED)

- `_set_selection`, Shift-union (`:773-787`), double-click (`:790-809`), all `game.cmd_*`
  calls, hover/cursor, build ghost and hotkeys: **untouched**.
- Epsilon literals, `KeyDoubleDelay = 0.5`, `PORT_DRAG_PX` fallbacks, all test
  `expected_pre_fix_failure` markers: **unchanged** (CHARTER "no test weakening").
- `picking3d.gd`, `camera3d.gd`, `world3d.gd`, `hud.gd`, all atoms, config and fixture:
  **not edited** — this remains a single-file implementation.

## 8. Verification recipe for B05 / C-wave (not run by D04)

1. **Regression at the proven size**: windowed 1280×720, `CAM_RV_01` shape and
   `S1_INPUT_FIX` job-414 shape must stay green (20/20 and 23/23, `SCRIPT ERROR` 0);
   `event_coord_scale == [1,1]`, overlay during drag `== Rect2(p0,p1).abs()`,
   `selected_ids == [10,11]`, short-click `[10]`, `cmd_*` counter 0.
2. **Non-1280 A/B (new coverage)**: run windowed at e.g. 1600×900 without
   `--screenshot` (root viewport == camera viewport) and assert
   `_event_px_to_cam_px` identity; then a run with a mismatched root/camera viewport
   (headless probe shape) and assert `p_cam == p_ev ⊙ (V_cam ⊘ V_in)` and that the
   selected units equal `R_sim.has_point(e.pos)` for the four corner points.
3. **Anchor-freeze check**: pan the camera by a known amount mid-drag (via
   `jump_to_world`) and assert `R_sim.position` stays at the frozen SIM anchor while
   `R_sim.end` tracks the cursor — this is the regression the current code fails.
4. **No donor claim**: all of the above verify port-internal consistency only.
   Donor parity of the native inside-box predicate, FOV, AABB test and `ArcTan`
   remains **UNVERIFIED** (DSEL-01 Q1, DSEL-02 Q1/Q6).

## 9. Open questions

1. Does Godot report `InputEventMouse.position` in root-viewport pixels or in stretched
   canvas pixels under `canvas_items`/`expand` at arbitrary widths? The two hunks use
   the live canvas transform and live viewport sizes so they are self-consistent in
   either case, but a windowed A/B at two widths is required before removing the
   **PORT APPROXIMATION** label.
2. `aspect="expand"` may introduce a translation offset not captured by the per-axis
   ratio. If the A/B shows one, extend `Φ` with the canvas-transform offset.
3. Donor starts the rectangle at the first-move ground point; the port freezes the
   press-ground point so the overlay and the world rect share one anchor. Whether to
   switch both to the first-move point is an owner decision (visual consistency vs
   literal donor timing).
4. The heightfield march precision (1 m steps, 20 bisections) and the missing yaw make
   `R_sim` an approximation; tightening either is out of scope for D04/B05 and must be
   labelled PORT APPROXIMATION.
5. `world.sel_rect` remains a dead SIM-metre mirror in 3D (no draw consumer,
   V3D_01 `:248`); it is harmless but should not be used as the overlay source.

## 10. Summary

- **Q1:** marquee corners are **terrain raycasts** (`picking3d._ray_heightfield`: 1 m
  march + 20 bisections against `game.height_at`), **not** fixed-height unprojections;
  the flat `Y=0` hit is only a fallback. `camera3d` fixed-height helpers are not in the
  drag path. Donor directionally agrees (engine ground ray hit), precision is a
  **PORT APPROXIMATION**.
- **Q2:** at non-1280 widths **no** stretch/projection scaling is applied in game code;
  event pixels go verbatim into `project_ray_*` and `draw_rect`. The only compensation
  is in `t_select_rect.gd` (S1_INPUT_FIX), identity at 1280×720, ×20 in the headless
  probe. Two live-derived maps are required (event→camera viewport, event→canvas), and
  B05's hunks add both.
- **Q3:** offset = uncorrected event/viewport/canvas spaces, re-unprojected anchor, or
  half-map double-shift; skew = perspective/heightfield image of a pixel rect plus
  assumed yaw 0; missing = no overlay in 2D, zero-area rect, world-epsilon gate,
  minimap preemption, off-screen harness projection; wrong-sized = 2-vs-4 corner
  coverage and stretch scaling.
- **Q4:** the precise rect is the SIM-metre AABB `R_sim` of the four ground-corner
  images `G(Φ(p_i))`, anchored once at press, with donor axis-wise world epsilon
  `0.005`/`0.25` m; exact code hunks are in §7. Native predicate, FOV and `ArcTan`
  stay **UNVERIFIED**; all substitutes are labelled **PORT APPROXIMATION**.

**No code, config, test, scene, shader, asset, git state or runner job was touched by
D04. Exactly this one report file was written.**
