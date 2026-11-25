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
# DONOR (HUD-01, read-only):
#   initminimap.inc:5-7,17,29-39 — 240x240 bottom-right, -8/-8 inset, zoom 1,
#     SetMiniMapFrustumVisible(true) at :37.
#   showunitcontrol.inc:109-110,586 — 289px right strip reserved.
#   classes.script:6030-6040 — GetCameraFrustumQuadrangle(lt,rt,rb,lb) supplies
#     the four GROUND corners; the frustum comes from those corners, never from
#     world_pos*view_scale (DSEL_02 "Minimap box" divergence).
#   misc.script:2017,2025 — world coordinates are CENTRED on the map origin, so
#     the mapping is u=(x+halfW)/mapW, v=(z+halfH)/mapH (halfW/H in METRES).
#   camera3d.gd:363-371 (concurrent CAM01 edit) now also documents the CENTRED
#     contract; the older camera3d line numbers in the preserved PLAY2FIX
#     comment below are kept verbatim for that fix's provenance.
# LINEAR WORLD->MINIMAP SCALE TABLE — DERIVED / UNVERIFIED (DEC_08 §5.4, Q1):
#   The engine owns the projection; no donor script states the factor.
#     256 tiles: 0.9375 px/tile (0.46875 px/m)
#     320 tiles: 0.75    px/tile (0.375    px/m)   <- DERIVED / UNVERIFIED
#     480 tiles: 0.5     px/tile (0.25     px/m)
#     640 tiles: 0.375   px/tile (0.1875   px/m)
#   Recorded for a future A/B only; never used as a code constant here.
# PAINTER CONTRACT: this file supplies four mapped ground corners and their
#   AABB. hud.gd:_mm_paint_box still strokes the AABB (PORT APPROXIMATION;
#   donor quad-vs-AABB frustum shape is UNVERIFIED per DEC_08 §9 Q2).

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
	var pts := get_minimap_corners()
	if pts.is_empty():
		return Rect2(0, 0, mw, mh)
	var x0 := mw
	var y0 := mh
	var x1 := -1
	var y1 := -1
	for pt in pts:
		var cx := clampi(int(pt.x), 0, mw - 1)
		var cy := clampi(int(pt.y), 0, mh - 1)
		x0 = mini(x0, cx)
		y0 = mini(y0, cy)
		x1 = maxi(x1, cx)
		y1 = maxi(y1, cy)
	# +1 makes end exclusive, matching the inclusive _mm_paint_box bounds.
	return Rect2(float(x0), float(y0), float(x1 - x0 + 1), float(y1 - y0 + 1))


# HUD-01: the four camera ground corners (camera3d.get_viewport_corners() gives
# TL,TR,BR,BL — donor GetCameraFrustumQuadrangle, classes.script:6030-6040)
# mapped into MINIMAP IMAGE pixels. Every corner uses the centred-world formula
#   u = (x + halfW) / mapW ; v = (z + halfH) / mapH
# with halfW/H and mapW/H in METRES, then scales to the image's tile grid.
# No world_pos*view_scale anywhere. Empty when no finite camera corner exists.
func get_minimap_corners() -> PackedVector2Array:
	var out := PackedVector2Array()
	var g = hud.get("game") if hud != null else null
	var mw := int(g.MAP_W) if g != null else int(Data.MAP_W)
	var mh := int(g.MAP_H) if g != null else int(Data.MAP_H)
	if mw <= 0 or mh <= 0:
		return out
	if cam == null or not cam.has_method("get_viewport_corners"):
		return out
	var corners = cam.get_viewport_corners()
	if corners == null:
		return out
	# Full map extent and half-map offset, both in the corners' unit (METRES).
	var extent := Vector2(float(mw), float(mh)) * Data.TILE_M
	var half := extent * 0.5
	for c in corners:
		var pc := _corner_xy(c)
		if not _finite(pc):
			continue
		# PLAY2FIX-NAVBOX: camera3d.get_viewport_corners() returns CENTRED metres
		# (camera3d.gd:266-275,354-363; PLAY2-01 E5), while the minimap image is
		# SIM-tile indexed (PLAY2-01 E7: hud.gd:1541,1598,1656,1796). Convert to
		# SIM metres before the tile mapping — the same half-map offset camera3d
		# subtracts at :246-247. Do NOT change int()/clamps/exclusive end (V717:48-56).
		var p: Vector2 = pc + half
		# u = (x + halfW)/mapW: p.x IS x+halfW and extent.x IS mapW. Same value as
		# int(p.x / Data.TILE_M), written as the donor centred-world formula.
		var u := p.x / extent.x
		var v := p.y / extent.y
		if not is_finite(u) or not is_finite(v):
			continue
		out.append(Vector2(
			clampf(u * float(mw), 0.0, float(mw - 1)),
			clampf(v * float(mh), 0.0, float(mh - 1))))
	return out


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
