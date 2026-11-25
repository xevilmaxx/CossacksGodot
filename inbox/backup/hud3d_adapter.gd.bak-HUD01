extends Node

# V7-17: 3D-aware minimap viewport-box adapter. CanvasItem HUD, minimap image
# and minimap data are UNCHANGED; only the camera-derived box is redirected.
#
# PORT EVIDENCE (read-only references):
#   app/scripts/hud.gd:1394-1412 — the 2D box derives x0/y0/x1/y1 from the
#     camera rect with pxm = Data.TILE_M * world.view_scale and
#     x_mm = int(canvas_px / pxm). hud.gd:1375 shows canvas_px = world_m *
#     view_scale, so view_scale cancels: x_mm = int(world_m / Data.TILE_M).
#   app/scripts/hud.gd:1423-1433 — _mm_paint_box uses INCLUSIVE Vector4i bounds.
#   app/scripts/data.gd:23 — const TILE_M := 2.0.
#   app/scripts/game.gd:16 — const TILE := 2.0.
#   app/scripts/game.gd:459-460 — tile_of(p) = Vector2i(int(p.x/TILE), int(p.y/TILE)).
#   variant3d/scripts/world3d.gd:215-216 — game (x,y) maps to world (x,z).
# DONOR: no donor path:line was re-read for the 3D frustum->minimap box in this
#   atom; V71 report :160/:212 marks it UNVERIFIED. The ground-corner projection
#   itself belongs to camera3d.gd (V73_ATOMIC_CONTRACT.md:10); this file only
#   maps those corners into the existing minimap pixel space.

const Data = preload("res://scripts/data.gd")

var cam: Object = null
var hud: Object = null


func bind(p_cam, p_hud) -> void:
	cam = p_cam
	hud = p_hud


# Rect2 in MINIMAP PIXEL (tile) space.
# position = inclusive (x0,y0); end = EXCLUSIVE (x1+1,y1+1).
# For the unchanged HUD painter (app/scripts/hud.gd:1423-1433) convert with:
#   Vector4i(int(b.position.x), int(b.position.y),
#            int(b.end.x) - 1, int(b.end.y) - 1)
func get_minimap_box() -> Rect2:
	var g = hud.get("game") if hud != null else null
	var mw := int(g.MAP_W) if g != null else int(Data.MAP_W)
	var mh := int(g.MAP_H) if g != null else int(Data.MAP_H)
	if mw <= 0 or mh <= 0:
		return Rect2()
	if cam == null or not cam.has_method("get_viewport_corners"):
		return Rect2(0, 0, mw, mh)
	var corners = cam.get_viewport_corners()
	if corners == null:
		return Rect2(0, 0, mw, mh)
	var x0 := mw
	var y0 := mh
	var x1 := -1
	var y1 := -1
	var seen := 0
	for c in corners:
		var p := _corner_xy(c)
		if not _finite(p):
			continue
		# PLAY2FIX-NAVBOX: camera3d.get_viewport_corners() returns CENTRED metres
		# (camera3d.gd:266-275,354-363; PLAY2-01 E5), while the minimap image is
		# SIM-tile indexed (PLAY2-01 E7: hud.gd:1541,1598,1656,1796). Convert to
		# SIM metres before the tile mapping — the same half-map offset camera3d
		# subtracts at :246-247. Do NOT change int()/clamps/exclusive end (V717:48-56).
		p += Vector2(mw, mh) * Data.TILE_M * 0.5
		# Same mapping as 2D hud.gd:1409-1412. The view_scale factors cancel:
		#   int(canvas_px / pxm) == int(world_m / Data.TILE_M)
		# 2D uses int() (truncate toward zero), so keep int() here too.
		var cx := clampi(int(p.x / float(Data.TILE_M)), 0, mw - 1)
		var cy := clampi(int(p.y / float(Data.TILE_M)), 0, mh - 1)
		x0 = mini(x0, cx)
		y0 = mini(y0, cy)
		x1 = maxi(x1, cx)
		y1 = maxi(y1, cy)
		seen += 1
	if seen == 0:
		return Rect2(0, 0, mw, mh)
	if x1 < x0:
		x0 = 0
		x1 = mw - 1
	if y1 < y0:
		y0 = 0
		y1 = mh - 1
	# +1 makes end exclusive, matching the inclusive _mm_paint_box bounds.
	return Rect2(float(x0), float(y0), float(x1 - x0 + 1), float(y1 - y0 + 1))


func screen_to_world(screen) -> Vector2:
	# Single source of truth: camera3d owns viewport-px -> ground-metre
	# (V73_ATOMIC_CONTRACT.md:10). Forward only; no duplicate projection here.
	if cam != null and cam.has_method("screen_to_world"):
		var w = cam.screen_to_world(screen)
		if w is Vector2:
			return w
		if w is Vector3:
			return Vector2(w.x, w.z)
	return Vector2.ZERO


func _corner_xy(c) -> Vector2:
	if c is Vector2:
		return c
	if c is Vector3:
		# variant3d/scripts/world3d.gd:215-216: game y == world z.
		return Vector2(c.x, c.z)
	if c is Array and c.size() >= 2:
		return Vector2(float(c[0]), float(c[1]))
	return Vector2.ZERO


func _finite(p: Vector2) -> bool:
	return p.x == p.x and p.y == p.y and absf(p.x) < 1.0e9 and absf(p.y) < 1.0e9
