---
id: P12-HUD-IMPL
ticket: "P12-IMPL (WAVE P integration — hunks re-derived over POST-S02 hud.gd)"
title: "P12 — H1/H2/H3/H4 per-frame HUD/minimap cost reduction APPLIED (2 owned files; no Godot, no runner)"
owner: "P12 implementation subagent — EXCLUSIVE owner of hud.gd + hud3d_adapter.gd"
date: 2026-11-25
status: IMPLEMENTED__AWAITING_G04_GATES__NO_GODOT__NO_RUNNER_JOB
scope: "Exactly 5 repo paths created/modified by this agent: 2 owned sources + 2 backups (created BEFORE the first edit) + this report. main.gd / t_hud_layout.gd / all tests / config / all other files NOT touched. app/** zero edits."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
proposal: docs/terrain_swarm_2026-11-25/reports/P12_hud_fix_proposal.md
baseline: docs/terrain_swarm_2026-11-25/reports/S02_impl.md
cost_audit: docs/terrain_swarm_2026-11-25/reports/P04_hud_cost.md
---

# P12 — implementation landing report

## 0. Authority, reads, and what was NOT done

**OBSERVED — files created/modified by P12-IMPL:** `variant3d/scripts/hud.gd`,
`variant3d/scripts/hud3d_adapter.gd`, `inbox/backup/hud.gd.bak-P12`,
`inbox/backup/hud3d_adapter.gd.bak-P12`, `docs/terrain_swarm_2026-11-25/reports/P12_impl.md`.
No other path was written by this agent.

- **OBSERVED:** dispatch grants EXCLUSIVE ownership of `variant3d/scripts/hud.gd` and
  `variant3d/scripts/hud3d_adapter.gd` only. The five required documents were read in full
  before any edit: `WAVE_G_CHARTER.md`, `CHARTER.md`, `P04_hud_cost.md`,
  `P12_hud_fix_proposal.md`, `S02_impl.md`.
- **OBSERVED:** **No Godot process, no runner job, no capture, no test execution, no
  FPS/frame-time measurement** (`WAVE_G_CHARTER.md:31,67-70`: only G04 runs jobs). Every gate
  result in §7 is an **UNVERIFIED expectation for G04**, not an observation.
- **OBSERVED:** `main.gd`, `t_hud_layout.gd`, `uitest.gd/json`, `selftest.gd/json`,
  `t_hud_fidelity.gd`, `config.gd`, `data.gd`, `camera3d.gd` and all of `app/**` were **not
  edited**. Other paths visible in `git status` during this work (`P10_impl.md`,
  `Y01_maze_data_proof.md`, `M03_impl.md`, `world3d_entities.gd`, `convert_models.py`,
  `convert_skins.py`, C01ASSET assets/backups) belong to **concurrent other owners**;
  P12 did not create or modify any of them. P12-created untracked paths are exactly the two
  `.bak-P12` backups and this report.
- **OBSERVED:** the optional P04 items P12-D (`fps_ema` deletion) and P12-E
  (`blit_rect` instead of `duplicate()`) were **not applied** — the dispatch asks only for
  H1–H4. `fps_ema` stays byte-identical; the minimap image duplicate/upload path is untouched.
- **OBSERVED:** no test weakening, no threshold/assertion/fixture edit, no synthetic noise,
  no donor-parity claim, no invented donor constant.

## 1. Baseline proof and re-derivation (why offsets changed)

The proposal (`P12_hud_fix_proposal.md:88-321`) was written against the **pre-S02** tree.
S02 landed two extra comment lines at `hud.gd:444-445`, shifting all later line numbers by
**+2** (`S02_impl.md:148`). Rather than blind `git apply --recount`, each hunk was located
by its exact source text in the current file and applied with the `edit` tool.

- **OBSERVED:** pre-edit `hud.gd` SHA-256 =
  `7748CC9507A35AF313C62C2D89BFF1BD8C9D0E1851E9837AEC6D0F97FCE0C319`, 87,380 bytes —
  **exactly** S02's reported post-edit hash and byte count (`S02_impl.md:70`). Therefore the
  patched baseline is genuinely **post-S02**, including the x8/x16/x32/x64 dropdown.
- **OBSERVED:** pre-edit `hud3d_adapter.gd` SHA-256 =
  `F2CCFA02E9D92A52CEC1165C96FADF4B061551087656DCB0CAD75FEDACE6FF6C`, 10,221 bytes.

| Hunk | Proposal line (pre-S02) | Applied line (post-S02 + P12) | Content |
|---|---|---|---|
| H1 vars / readouts | `:89-94`, `:1445-1504` | `:95-105`, `:1471-1523` | `readouts_due` reuse of the existing `eco_t` 0.5 s poll |
| H2 viewport cache | `:174`, `:1611`, `:1667` | `:188`, `:1638-1639`, `:1697-1700`, `:1743` | `_vp` cached at `bind()`, used in both minimap paths |
| H3 box gate | `:1667-1698` | `:1692-1746` | 3D transform+fov / 2D position+zoom signature before the adapter call |
| H3 invalidation | `:218`, `:273` | `:233-235`, `:291-293` | `bind_3d()` / `_on_vp_resize()` force a fresh box |
| H4 adapter cache | `hud3d_adapter.gd:59-137` | `hud3d_adapter.gd:61-124` | `_sync_game()` snapshots game + `MAP_W`/`MAP_H` at `bind()` |

**DERIVED safety of the H3 signature:** `camera3d.get_viewport_corners()`
(`camera3d.gd:397-404`) projects four screen corners through
`screen_to_world()` (`:296-305`); fov is set at bind (`:179,195`), pan and zoom move the
camera transform (`:444-452,560-586,589-592`), and viewport size is invalidated by
`_on_vp_resize()`. The box is therefore a pure function of transform + fov + viewport +
map size. **UNVERIFIED:** no runtime proof; the ≤0.25 s `force=true` minimap tick
(`hud.gd:2090`) self-heals any missed property.

**F3 same-frame contract preserved (OBSERVED):** `jump_to_world_donor_offset()` calls
`_apply_transform()` synchronously (`camera3d.gd:584`) before the post-edit
`hud.gd:1665/1669` redraws; 2D handlers set `cam.global_position` then redraw
(post-edit `hud.gd:1643-1645/1652-1654`). A changed transform always passes the gate.

## 2. Backups — taken BEFORE the first edit

`CHARTER.md:66` / `WAVE_G_CHARTER.md:87` require `inbox/backup/<name>.bak-P12`. Both
destinations were absent before this work (checked). Copies were made first, then hashed;
backup hash == pre-edit hash for both.

| File | Pre-edit SHA-256 | Backup | Backup SHA-256 | Bytes | Line endings |
|---|---|---|---|---:|---|
| `variant3d/scripts/hud.gd` | `7748CC9507A35AF313C62C2D89BFF1BD8C9D0E1851E9837AEC6D0F97FCE0C319` | `inbox/backup/hud.gd.bak-P12` | `7748CC9507A35AF313C62C2D89BFF1BD8C9D0E1851E9837AEC6D0F97FCE0C319` | 87380 | CRLF (unchanged) |
| `variant3d/scripts/hud3d_adapter.gd` | `F2CCFA02E9D92A52CEC1165C96FADF4B061551087656DCB0CAD75FEDACE6FF6C` | `inbox/backup/hud3d_adapter.gd.bak-P12` | `F2CCFA02E9D92A52CEC1165C96FADF4B061551087656DCB0CAD75FEDACE6FF6C` | 10221 | LF (unchanged) |

Post-edit (for audit):

| File | Post-edit SHA-256 | Bytes | Line endings |
|---|---|---:|---|
| `variant3d/scripts/hud.gd` | `552AE3EE2BC1EDA068ED170108CF4A27D85706B1EF0BD6BC6C4EBDB1DDE682D9` | 90018 | CRLF (every line; no mixed endings) |
| `variant3d/scripts/hud3d_adapter.gd` | `5C6E31B8E7070DF23C0F7041C6DCBA29A0D46D52FDA16D079E0BF7DA3A6DEE3D` | 10604 | LF (no CRLF) |

Rollback = copy each `.bak-P12` back over its target.

## 3. Hunks applied (behavioural summary)

- **H1 (`hud.gd:1471-1523`):** `var readouts_due := eco_t <= 0.0` reuses the existing
  0.5 s economy poll; the six resource labels, idle/slots buttons and status line are
  formatted only on due frames (`for i in (6 if readouts_due else 0)`). `_recompute_eco()`,
  `_cached_ucount`, all dirty flags, `_last_*` comparisons, deficit colours and disabled
  assignments stay in their original blocks. First `_process()` frame still populates every
  label (`eco_t` starts at `0.0`), which `t_hud_fidelity.gd:76-77` and
  `hud_report():2092-2111` rely on.
- **H2 (`hud.gd:188,1638-1639,1697-1700,1743`):** `_vp = get_viewport()` at `bind()`;
  both minimap paths read `_vp` with an `is_instance_valid()` fallback. The 3D path no
  longer looks up a 2D camera at all.
- **H3 (`hud.gd:233-235,291-293,1709-1722,1734-1740`):** new `_mm_box_cam_xform/fov`
  (3D) and `_mm_box_cam2_pos/zoom` (2D) signatures with sentinels; unchanged camera + fov
  (or pos + zoom) returns **before** `_hud3d_adapter.get_minimap_box()` / the 2D maths and
  therefore before the four ray casts and `minimap_tex.update()`. `force=true` and input
  jumps bypass the gate; invalidation on `bind_3d()` and resize.
- **H4 (`hud3d_adapter.gd:61-124`):** `_game/_mw/_mh` snapshotted in `bind()`;
  `_sync_game()` refreshes on a changed `hud.game`. Both `get_minimap_box()` and
  `get_minimap_corners()` read the cached values. Inclusive→exclusive conversion, clamps,
  centred-world formula, quad stroke helpers and donor comments are untouched.

## 4. Exact diff (verbatim `git diff` of the two owned files)

```diff
diff --git a/variant3d/scripts/hud.gd b/variant3d/scripts/hud.gd
index e0151501..817cde95 100644
--- a/variant3d/scripts/hud.gd
+++ b/variant3d/scripts/hud.gd
@@ -92,6 +92,17 @@ var _last_res_text: Array = []
 var _last_eco_text := ""
 var _last_mines_text := ""
 var _last_status_text := "\n"
+# P12: the CanvasLayer viewport is stable for the HUD's lifetime; cache it at
+# bind() instead of calling get_viewport() on every _process frame.
+var _vp: Viewport = null
+# P12: minimap-box change gate. The 3D adapter ray-casts four camera corners
+# per call, so a still camera must not pay that cost every frame. Sentinels
+# force the first draw; _on_vp_resize()/bind_3d() invalidate on projection or
+# camera changes. force=true (minimap ticks) always bypasses the gate.
+var _mm_box_cam_xform := Transform3D()
+var _mm_box_cam_fov := -1.0
+var _mm_box_cam2_pos := Vector2.INF
+var _mm_box_cam2_zoom := Vector2.ZERO
 var fps_label: Label
 var fps_t := 0.0
 var fps_ema := 60.0
@@ -174,6 +185,7 @@ var top_center: Control
 func bind(g: C3Game, w) -> void:
 	game = g
 	world = w
+	_vp = get_viewport()  # P12: cached for the per-frame minimap box painter
 	ui_us = _calc_us()
 	icons_tex = load("res://assets/ui/icons.bmp")
 	units_tex = load("res://assets/ui/iconsunits.bmp")
@@ -218,6 +230,9 @@ func bind_3d(cam) -> void:
 	_hud3d_adapter.bind(cam, self)
 	_bound_cam3d = cam
 	_render_mode_3d = true
+	# P12: a rebound camera invalidates the minimap box change signature.
+	_mm_box_cam_fov = -1.0
+	_mm_box_cam2_pos = Vector2.INF
 
 func atlas(src: Texture2D, region: Rect2) -> AtlasTexture:
 	var at := AtlasTexture.new()
@@ -273,6 +288,9 @@ func _reg(c: Control, fs := 0, mh := 0, mw := 0) -> Control:
 func _on_vp_resize() -> void:
 	ui_us = _calc_us()
 	_apply_scale()
+	# P12: projection size changed even if the camera transform did not.
+	_mm_box_cam_fov = -1.0
+	_mm_box_cam2_pos = Vector2.INF
 
 # CONFIG-WIRE-HUD: minimap geometry now reads the global feature config through
 # the typed getters CONFIG-CORE-01 added to config.gd. Reads go through the
@@ -1450,11 +1468,14 @@ func _process(dt: float) -> void:
 		fps_t = 0.5
 		fps_label.text = "%03d" % int(Performance.get_monitor(Performance.TIME_FPS))
 	eco_t -= dt
-	if eco_t <= 0.0:
+	# P12: all formatted read-outs below are polled on this existing 0.5 s
+	# cadence instead of being rebuilt (and dirty-checked) every frame.
+	var readouts_due := eco_t <= 0.0
+	if readouts_due:
 		eco_t = 0.5
 		_recompute_eco()
 		_cached_ucount = game.unit_count(0) + game.queue_count(0)
-	for i in 6:
+	for i in (6 if readouts_due else 0):  # P12: no string work on idle frames
 		var rname: String = str(Data.RES_NAMES[i])
 		var stock: int = int(game.players[0].res[i])
 		var stock_s: String = RES_STOCK_CAP_TEXT if stock > RES_STOCK_CAP else str(stock)
@@ -1481,7 +1502,7 @@ func _process(dt: float) -> void:
 		if deficit != bool(res_deficit[i]):
 			res_deficit[i] = deficit
 			res_labels[i].add_theme_color_override("font_color", Color(1, 0.42, 0.38) if deficit else Color(1, 0.97, 0.9))
-	if eco_label != null:
+	if readouts_due and eco_label != null:
 		var et := "idle %d" % idle_count
 		if et != _last_eco_text:
 			_last_eco_text = et
@@ -1491,15 +1512,15 @@ func _process(dt: float) -> void:
 		if warn != eco_warn:
 			eco_warn = warn
 			eco_label.add_theme_color_override("font_color", Color(1, 0.45, 0.4) if warn else Color(0.8, 0.85, 1))
-	if mines_btn != null:
+	if readouts_due and mines_btn != null:
 		var mt := "slots %d" % free_slots_count
 		if mt != _last_mines_text:
 			_last_mines_text = mt
 			mines_btn.text = mt
 		mines_btn.disabled = free_slots_count <= 0
-	var ucount := _cached_ucount  # throttled on eco_t (~0.5 s); other fields stay live
+	var ucount := _cached_ucount  # P12: refreshed with the read-out poll (~0.5 s)
 	# the hint line carries placement text; the status line keeps units/score
-	if hint_label == null or hint_label.text == "":
+	if readouts_due and (hint_label == null or hint_label.text == ""):
 		var st := "units %d/%d    score %d    %s" % [ucount, game.players[0].farm_cap,
 			game.players[0].score, ("PAUSED" if game.paused else "")]
 		if st != _last_status_text:
@@ -1613,7 +1634,9 @@ func _on_minimap_input(ev: InputEvent) -> void:
 	# orders are NOT consumed here: they fall through to the unchanged block below.
 	if _render_mode_3d and _minimap_jump_3d(ev, world_pos):
 		return
-	var cam := get_viewport().get_camera_2d() as C3Camera
+	# P12: reuse the viewport cached at bind() (event-driven path).
+	var vp_node: Viewport = _vp if _vp != null and is_instance_valid(_vp) else get_viewport()
+	var cam := vp_node.get_camera_2d() as C3Camera
 	if ev is InputEventMouseButton and ev.pressed:
 		get_viewport().set_input_as_handled()
 		if ev.button_index == MOUSE_BUTTON_LEFT and cam:
@@ -1669,12 +1692,34 @@ func _cam3d_jump(world_pos: Vector2) -> bool:
 func _draw_minimap_viewport_box(force: bool = false) -> void:
 	if minimap_img == null or minimap_view_img == null or minimap_tex == null or game == null:
 		return
+	# P12: the viewport does not change between frames; the old code called
+	# get_viewport() twice per frame here and looked up the 2D camera even in 3D.
+	var vp_node: Viewport = _vp if _vp != null and is_instance_valid(_vp) else get_viewport()
+	var cam = null
+	if not _render_mode_3d and vp_node != null:
+		cam = vp_node.get_camera_2d()
 	var x0 := 0
 	var y0 := 0
 	var x1 := game.MAP_W - 1
 	var y1 := game.MAP_H - 1
-	var cam := get_viewport().get_camera_2d()
 	if _render_mode_3d and _hud3d_adapter != null:
+		# P12: get_minimap_box() casts four camera rays (camera3d.gd:397-404).
+		# An unchanged camera transform + fov cannot change the box, so skip the
+		# adapter call on still frames. force=true (minimap ticks) and every
+		# input-driven jump still recompute.
+		var cam3: Object = _bound_cam3d
+		var has_cam3 := cam3 != null and is_instance_valid(cam3)
+		var xf: Variant = null
+		var fv := -1.0
+		if has_cam3:
+			xf = cam3.get("global_transform")
+			fv = float(cam3.get("fov"))
+		if has_cam3 and not force:
+			if xf == _mm_box_cam_xform and is_equal_approx(fv, _mm_box_cam_fov):
+				return
+		if has_cam3:
+			_mm_box_cam_xform = xf
+			_mm_box_cam_fov = fv
 		# V7-53: 3D seam. The box source is the V7-17 adapter ONLY; the minimap
 		# image, its data/orders and _mm_paint_box below are unchanged.
 		# get_minimap_box(): position = inclusive (x0,y0), end = EXCLUSIVE.
@@ -1686,9 +1731,16 @@ func _draw_minimap_viewport_box(force: bool = false) -> void:
 		x1 = clampi(int(b3.end.x) - 1, 0, game.MAP_W - 1)
 		y1 = clampi(int(b3.end.y) - 1, 0, game.MAP_H - 1)
 	elif cam != null and world != null:
+		# P12: same gate for 2D â€” position + zoom fully determine the box.
+		var cp: Vector2 = cam.global_position
+		var cz: Vector2 = cam.zoom
+		if not force and cp == _mm_box_cam2_pos and cz == _mm_box_cam2_zoom:
+			return
+		_mm_box_cam2_pos = cp
+		_mm_box_cam2_zoom = cz
 		# view_rect is canvas pixels (metres * view_scale); screen = canvas * zoom
 		var pxm: float = Data.TILE_M * world.view_scale
-		var vp: Vector2 = get_viewport().get_visible_rect().size
+		var vp: Vector2 = vp_node.get_visible_rect().size
 		var extent: Vector2 = vp / maxf(cam.zoom.x, 0.0001)
 		var view_pos: Vector2 = cam.global_position - extent * 0.5
 		var view_end: Vector2 = view_pos + extent
diff --git a/variant3d/scripts/hud3d_adapter.gd b/variant3d/scripts/hud3d_adapter.gd
index a6f5bcbc..adbf3bdd 100644
--- a/variant3d/scripts/hud3d_adapter.gd
+++ b/variant3d/scripts/hud3d_adapter.gd
@@ -58,11 +58,27 @@ const Data = preload("res://scripts/data.gd")
 
 var cam: Object = null
 var hud: Object = null
+# P12: the game ref and MAP_W/MAP_H are fixed for a HUD's lifetime. Snapshot
+# them once at bind() so each camera-change box poll does no repeated dynamic
+# MAP_W/MAP_H reads. _sync_game() refreshes if hud.game is ever replaced.
+var _game: Object = null
+var _mw := 0
+var _mh := 0
 
 
 func bind(p_cam, p_hud) -> void:
 	cam = p_cam
 	hud = p_hud
+	_sync_game()
+
+
+func _sync_game() -> void:
+	var g = hud.get("game") if hud != null else null
+	if g == _game:
+		return
+	_game = g
+	_mw = int(g.MAP_W) if g != null else int(Data.MAP_W)
+	_mh = int(g.MAP_H) if g != null else int(Data.MAP_H)
 
 
 # Rect2 in MINIMAP PIXEL (tile) space.
@@ -71,9 +87,9 @@ func bind(p_cam, p_hud) -> void:
 #   Vector4i(int(b.position.x), int(b.position.y),
 #            int(b.end.x) - 1, int(b.end.y) - 1)
 func get_minimap_box() -> Rect2:
-	var g = hud.get("game") if hud != null else null
-	var mw := int(g.MAP_W) if g != null else int(Data.MAP_W)
-	var mh := int(g.MAP_H) if g != null else int(Data.MAP_H)
+	_sync_game()  # P12: cached game + map size (same values as before)
+	var mw := _mw
+	var mh := _mh
 	if mw <= 0 or mh <= 0:
 		return Rect2()
 	var pts := get_minimap_corners()
@@ -102,9 +118,9 @@ func get_minimap_box() -> Rect2:
 # No world_pos*view_scale anywhere. Empty when no finite camera corner exists.
 func get_minimap_corners() -> PackedVector2Array:
 	var out := PackedVector2Array()
-	var g = hud.get("game") if hud != null else null
-	var mw := int(g.MAP_W) if g != null else int(Data.MAP_W)
-	var mh := int(g.MAP_H) if g != null else int(Data.MAP_H)
+	_sync_game()  # P12: cached game + map size (same values as before)
+	var mw := _mw
+	var mh := _mh
 	if mw <= 0 or mh <= 0:
 		return out
 	if cam == null or not cam.has_method("get_viewport_corners"):
```

## 5. Preservation proof vs S02 / UI-TOPBAR-01 / CONFIG-WIRE-HUD

Byte slices were extracted from the backup (post-S02) and from the patched file,
normalized only for the pre-existing line-ending style (hud.gd CRLF, adapter LF), and
SHA-256 compared. **All 23 blocks matched byte-for-byte:**

| Block (hud.gd unless noted) | SHA-256 prefix (both sides) | Result |
|---|---|---|
| S02 speed dropdown + 8-option metadata (`:439-450`, shifted) | `E1017072A9676D6C` | IDENTICAL |
| S02 `_mkoption()` float-metadata writer | `B4FEC75C25347BF4` | IDENTICAL |
| S02 `_speed_index()` | `6C0187B576778EB4` | IDENTICAL |
| S02 `refresh_speed()` (no feedback loop) | `A9B45E22C96E0994` | IDENTICAL |
| UI-TOPBAR-01 `_layout_top()` (1500/1100/800, full-width clip) | `A182396B6C31F46F` | IDENTICAL |
| UI-TOPBAR-01 `_apply_scale()` | `9A5E84822F8588D3` | IDENTICAL |
| CONFIG-WIRE-HUD `_mm_size()` → 240 | `B47F7E25E95EB4A7` | IDENTICAL |
| CONFIG-WIRE-HUD `_mm_inset()` → -8 | `6027DF7ACD74D784` | IDENTICAL |
| CONFIG-WIRE-HUD `_mm_corner()` → `bottom_right` | `15019B4D41AA8F74` | IDENTICAL |
| `_build_minimap()` (bottom-right anchors, 240 slot, offsets) | `8F626D5381FBDA93` | IDENTICAL |
| `_minimap_jump_3d()` (F3 jump contract) | `190BDAE8A7F8CF13` | IDENTICAL |
| `_mm_paint_box()` | `C149B1B28D0D8245` | IDENTICAL |
| `_recompute_eco()` | `E03789C55D11BB2D` | IDENTICAL |
| `_update_minimap()` incl. `_draw_minimap_viewport_box(true)` | `A2F248C30693B65D` | IDENTICAL |
| `hud_report()` (every key read by selftest/uitest) | `4955C1AF087B9CA4` | IDENTICAL |
| adapter donor/PORT-APPROX header (`:1-55`) | `3CEEAF185635F799` | IDENTICAL |
| adapter `get_minimap_box()` clamp + AABB tail | `2F6F06064912C4A6` | IDENTICAL |
| adapter `get_minimap_corners()` tail | `C9C3F95570AA5FED` | IDENTICAL |
| adapter `get_minimap_quad()` | `8698423D87BB864E` | IDENTICAL |
| adapter `stroke_minimap_quad()` (call site still open) | `196D7BFA0BA22602` | IDENTICAL |
| adapter `_plot_quad_line()` | `3E2F5EC6375D7A9E` | IDENTICAL |
| adapter `screen_to_world()` | `312EED041B7B435B` | IDENTICAL |
| adapter `_corner_xy()` / `_finite()` | `F85FAE08C70FE8BA` | IDENTICAL |

Additional checks (all **OBSERVED**):

- `git diff --check` on both owned files: **no whitespace errors**.
- `git diff --name-only` for P12: **only** `variant3d/scripts/hud.gd` and
  `variant3d/scripts/hud3d_adapter.gd` (plus this new report). Zero paths under
  `variant3d/tests/**`, `uitest.*`, `selftest.*`, `main.gd`, `config.gd`, `app/**`.
- Bracket/paren/brace balance and tab indentation preserved (static script check; no Godot).
- Line-ending style preserved: hud.gd CRLF 2059→2111 lines, adapter LF 234→250 lines.
- All 62 `t_hud_layout` check sites and the 17 uitest steps were read; none assert
  per-frame readout cadence. `t_hud_layout.gd:395-407` only requires six **non-empty**
  resource labels, which frame 1 provides; `uitest.gd:120` reads `hud_report()` keys, all
  unchanged. No test file was edited.

## 6. Static checks performed by P12 (no Godot, no runner)

| Check | Result |
|---|---|
| Backup hash == pre-edit hash | PASS (2/2) |
| Baseline == S02 post-edit hash/bytes | PASS |
| Protected-block byte identity | PASS (23/23) |
| `git diff --check` | PASS — 0 whitespace errors (git's pre-existing `core.autocrlf` eol notice on the LF adapter is not a diff error) |
| Bracket / indentation smoke | PASS |
| Line endings unchanged per file | PASS |
| Godot / runner / capture / FPS measurement | **0** (none submitted) |

## 7. Gate list for G04 (sole runner owner) — ALL UNVERIFIED

Every entry is a **request**; P12 submitted no jobs. A single failure means stop and
re-derive, never loosen an assertion.

| # | Gate | Required result | Why P12 should not break it | Status |
|---:|---|---|---|---|
| 1 | variant **selftest** | 29/29, `passed:true`, `SCRIPT ERROR == 0` | `hud_report()` byte-identical; frame 1 fills all labels; no new per-frame call | UNVERIFIED — G04 |
| 2 | **uitest** 17/17 (`variant3d/uitest.json`) | `speed_pause` detail "game speed set to 2x: yes"; `minimap_frustum` bottom-right; `select_box`/`train_flow`/`market_panel`/`research_panel` green | Only upper clamp belongs to S02; test API keys unchanged; anchors untouched | UNVERIFIED — G04 |
| 3 | **t_hud_layout** windowed 1024/1280/1920 | `verdict: PASS`, 62 evaluated / 0 fails / 3 skips (or 3 real PNGs), 0 unclipped offenders | `_layout_top()`/`_apply_scale()` byte-identical; six labels non-empty on frame 1; `_on_vp_resize()` only gains two sentinel writes | UNVERIFIED — G04 |
| 4 | **t_hud_fidelity** | 6 non-empty labels, bracketed worker counts, deficit colours | test forces `hud.eco_t = 0.0` then `_process(0.0)` → `readouts_due == true` → exact original text/colour pass | UNVERIFIED — G04 |
| 5 | **t_render_mode** / 3D minimap seam | `result=PASS`, `seam_missing=false`, `SCRIPT ERROR == 0` | box still comes from `_hud3d_adapter.get_minimap_box()`; AABB mapping byte-identical; jump invalidates via transform change | UNVERIFIED — G04 |
| 6 | **CAM-RV-01** AABB atom (if re-run) | `(12,11,40,34)` unchanged | adapter clamps/conversion byte-identical; `_sync_game()` returns same `MAP_W/MAP_H` | UNVERIFIED — G04 |
| 7 | **CONFIG-WIRE-HUD** | `_mm_size()==240`, `_mm_inset()==-8`, `_mm_corner()=="bottom_right"` | all three getters byte-identical | UNVERIFIED — G04 |
| 8 | **UI-TOPBAR-01** | thresholds 1500/1100/800; single OptionButton with 8 items / float metadata; FPS + messages present | S02 block + metadata writer byte-identical; `_layout_top()` byte-identical | UNVERIFIED — G04 |
| 9 | Static parse of both edited scripts (`--check-only`, unique ids) | parse OK, no SCRIPT ERROR | structural smoke passed; real parser check is G04-only | UNVERIFIED — G04 |
| 10 | **2D `app/**`** | zero edits | P12 owns only 2 variant3d scripts; diff has no `app/` paths | OBSERVED — no edit |

Suggested runner ids (submitted by G04 only): `p12-checkonly-hud`,
`p12-checkonly-adapter`, `P12-uitest`, `P12-hudlayout` — exact command forms in
`P12_hud_fix_proposal.md:298-316`.

## 8. Honesty / risk register

- **UNVERIFIED:** all gate results and all FPS/frame-time impact. No capture, telemetry or
  runner job exists for this landing. "Stops ~15 formats/frame" and "skips four ray casts"
  are **derived** work removals, not measured speed-ups; no "X% faster" claim is made.
- **Derived bounded behaviour changes (owner awareness):** top-bar stock/idle/slots/status
  refresh at most 2 Hz instead of every frame (strings unchanged because their inputs are
  already polled at 2 Hz); a status line yields to a live hint on the next poll (≤0.5 s);
  the minimap box is recomputed only on camera/viewport change or the ≤0.25 s forced tick.
- **INFERRED:** H3 signature completeness from `camera3d.gd:175,179,195,296-305,397-404`;
  self-healed by the forced tick if any unmapped property changes.
- **PORT APPROX:** the AABB-vs-quad frustum shape and S02's x16/x32/x64 remain as landed
  by their owners; P12 made no donor claim and touched neither.
- No synthetic dither/noise, no invented donor constant, no test weakening, no Godot, no
  runner job, no other owner's file modified.

## 9. Availability

Implementation is complete and backed up. This agent stays available for COORD's follow-up
(e.g. re-deriving a hunk after G04 gate results, or adjusting the gate signature). No further
edits are pending from P12-IMPL.

*End of P12 implementation report — 2 owned files patched, 2 backups taken, 0 Godot/runner jobs submitted.*
