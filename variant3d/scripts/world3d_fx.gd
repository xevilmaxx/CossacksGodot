extends Node3D

# V7-15 — spatial FX / ghost / rally layer. NEW FILE; no sim or 2D file is edited.
#
# API (exact, per docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:14):
#   bind(game), sync(dt), add_fx(pos, kind, life),
#   draw_ghost(sid, pos, ok:bool), draw_rally(pos, player:int)
#
# DONOR EVIDENCE POLICY (WAVE7 charter :29-38, V7-1 inventory §2.4 :156-176):
#   readable donor keys are CITED as `path:line`; their runtime mapping is NOT
#   proven. `C:\Games\Cossacks 3\data\pfx\source.pfx` is private-use, read-only,
#   and V7-2 reports PFX semantics as UNMAPPED. Every number taken from it is
#   therefore labelled `LITERAL KEY / SEMANTICS UNVERIFIED`. Port-side precedents
#   from app/variant3d world.gd are cited separately and are NOT donor truth.
#
# No RNG: all drift/flicker is a deterministic function of (age, spawn index).
# No water re-bake: the spatial water shader plane is owned by world3d.gd
#   (`_make_water`, world3d.gd:345-406); this module never touches terrain/water.

const Data = preload("res://scripts/data.gd")

# TILE_M / cell size: game.gd:16 (`const TILE := 2.0`), world3d.gd:12. Read-only.
const TILE_M: float = 2.0

# Port FX lifetimes (world.gd:3563-3579, :3559). These are PORT values, not
# donor values; donor PFX has only interval/pixel-ratio keys (see below).
const LIFE := {
	"shot": 0.35,
	"smoke": 1.6,
	"explode": 0.8,
	"crater": 0.8,
	"fire": 0.9,
	"heal": 0.9,
	"capture": 1.2,
	"rout": 1.2,
	"chop": 0.35,
	"trail": 0.22,
}
const DEFAULT_LIFE: float = 0.35
const FALLBACK_FX_CAP: int = 220   # data.gd:117 (quality-tier default)

# Donor PFX literal keys — SEMANTICS UNVERIFIED (V7-2: PFX semantics UNMAPPED):
#   source.pfx:41-62   musketsmoke: EndFrame 127, FrameWidth 256,
#       FrameHeight 128, Interval 10, PixelRatio 175, AlphaTime 1.5,
#       AlphaPower 1.5, OnEndFrameState FreeToPool.
#   source.pfx:105-177 musketflash: 4 frames, Interval 100, FrameRate 10,
#       PixelRatio 350, OnEndFrameHide = True.
#   source.pfx:385-411 cannonsmoke: EndFrame 127, PixelRatio 120,
#       AlphaTime 1.5, AlphaPower 1.5.
#   source.pfx:1322-1415 cannonexp: EndFrame 255, PixelRatio 30,
#       AlphaTime 1.2, AlphaPower 1.0.
#   source.pfx:1739-1746 bullettrail: VertLimit 150, TimeLimit 0.2,
#       MinDistance 0.05, Alpha 0.2, AlphaFade True, MarkStyle msFaceCamera,
#       MarkWidth 0.1.
# The two trail constants below quote those keys literally; the Godot-side
# interpretation (metres vs pixels, seconds vs frames) is UNVERIFIED.
const TRAIL_TIME_LIMIT: float = 0.2   # source.pfx:1740 `TimeLimit = 0.2`
const TRAIL_ALPHA: float = 0.2        # source.pfx:1742 `Alpha = 0.2`
const TRAIL_WIDTH_M: float = 0.1      # source.pfx:1746 `MarkWidth = 0.1`
const TRAIL_STREAK_M: float = 1.2     # PORT approximation (no donor length key)

# Colour precedents are PORT, not donor art:
#   world.gd:3509 green/red build ghost; world.gd:3655-3668 smoke/fire;
#   world.gd:2172-2179 player palette (copied from hud.gd MM_PLAYER_COLORS).
const GHOST_OK := Color(0.20, 1.00, 0.30, 0.45)   # world.gd:3509
const GHOST_BAD := Color(1.00, 0.25, 0.20, 0.45)  # world.gd:3509
const PLAYER_COLORS := [
	Color(0.30, 0.62, 1.00), Color(1.00, 0.32, 0.26),
	Color(1.00, 0.78, 0.22), Color(0.42, 0.85, 0.42),
	Color(0.70, 0.45, 1.00), Color(0.25, 0.85, 0.85),
	Color(1.00, 0.55, 0.72), Color(0.85, 0.85, 0.85),
	Color(1.00, 0.60, 0.10), Color(0.55, 0.95, 0.30),
	Color(0.10, 0.70, 0.65), Color(0.65, 0.42, 0.22),
]

# Event names are sim-agnostic and come from main.gd:1518-1554 `_consume_events`
# (which forwards only shot/smoke/heal/rout/crater/explode/chop to add_fx).
const EVENT_FX := {
	"shot": "shot", "smoke": "smoke", "heal": "heal", "rout": "rout",
	"crater": "crater", "explode": "explode", "chop": "chop",
	"fire": "fire", "capture": "capture",
}

const RALLY_TTL: float = 2.0   # PORT choice: clear markers not redrawn for 2 s (no donor key)

# --- public state ----------------------------------------------------------
var game = null
var consume_events: bool = true    # set false if main.gd already forwards add_fx
var emit_arrow_trails: bool = true
var world_offset: Vector2 = Vector2.ZERO  # subtract from map pos to centre the scene
var height_bias: float = 0.0
var fx_items: Array = []
var stats: Dictionary = {
	"spawned": 0, "expired": 0, "events_consumed": 0,
	"rally_active": 0, "ghost_shown": 0,
}

# --- private state ---------------------------------------------------------
var _root: Node3D = null
var _ghost_root: Node3D = null
var _ghost_mesh: MeshInstance3D = null
var _ghost_mat: StandardMaterial3D = null
var _ghost_active: bool = false
var _ghost_ok: bool = true
var _ghost_sid: String = ""
var _rally_root: Node3D = null
var _rally_markers: Dictionary = {}
var _time: float = 0.0
var _events_seen: int = 0
var _spawn_index: int = 0


# --- PUBLIC API ------------------------------------------------------------

func bind(g) -> void:
	game = g
	_events_seen = 0
	_ensure_roots()


func sync(dt) -> void:
	var d: float = maxf(0.0, float(dt))
	_time += d
	if consume_events:
		_consume_events()
	if emit_arrow_trails:
		_emit_arrow_trails()
	_update_fx(d)
	_update_rally()
	_update_ghost()


# Exact signature per contract: add_fx(pos, kind, life). `life` <= 0 means
# "use the port lifetime table" so a caller may pass -1 / 0 as a sentinel.
func add_fx(pos, kind, life := -1.0) -> Dictionary:
	_ensure_roots()
	var k: String = str(kind)
	var span: float = float(life)
	if span <= 0.0:
		span = float(LIFE.get(k, DEFAULT_LIFE))
	if span <= 0.0:
		span = DEFAULT_LIFE
	var p3: Vector3 = world_pos(pos)
	if not _finite3(p3):
		return {}
	_spawn_index += 1
	var holder := Node3D.new()
	holder.name = "FX_%s_%d" % [k, _spawn_index]
	holder.position = p3
	_root.add_child(holder)

	var item: Dictionary = {
		"kind": k, "pos": pos, "life": span, "age": 0.0,
		"node": holder, "mat": null, "light": null,
		"base_alpha": 1.0, "light_energy": 0.0, "base_y": p3.y,
		"pr": null, "index": _spawn_index,
	}
	_build_visual(item, k)
	fx_items.append(item)
	_enforce_cap()
	stats["spawned"] = int(stats.get("spawned", 0)) + 1
	return item


# Translucent green (ok) / red (blocked) 3D footprint. PORT primitives:
# no donor ghost config was readable; colour follows world.gd:3509.
func draw_ghost(sid, pos, ok: bool) -> void:
	_ensure_roots()
	var s: String = str(sid)
	if s.is_empty() or not _valid_pos(pos):
		_ghost_active = false
		_ghost_root.visible = false
		return
	_ghost_active = true
	_ghost_sid = s
	_ghost_ok = bool(ok)
	var p3: Vector3 = world_pos(pos)
	if not _finite3(p3):
		_ghost_active = false
		_ghost_root.visible = false
		return
	_ghost_root.position = p3
	_ghost_root.visible = true
	var r: float = _building_radius(s)
	_ghost_mesh.scale = Vector3(r * 2.0, 1.0, r * 2.0)
	stats["ghost_shown"] = int(stats.get("ghost_shown", 0)) + 1


# Pole + pennant in player colour. PROCEDURAL PRIMITIVE — the donor
# `rallypoint.dds` is private-use and stays uncopied (see world.gd:3602-3604).
func draw_rally(pos, player: int) -> void:
	_ensure_roots()
	var p3: Vector3 = world_pos(pos)
	if not _finite3(p3):
		return
	var key := Vector2(roundf(p3.x * 2.0) * 0.5, roundf(p3.z * 2.0) * 0.5)
	if _rally_markers.has(key):
		var old: Dictionary = _rally_markers[key]
		old["seen"] = _time
		_set_rally_color(old, int(player))
	else:
		_rally_markers[key] = _make_rally(p3, int(player))
	stats["rally_active"] = _rally_markers.size()


func clear_all() -> void:
	for item in fx_items:
		_free_item(item)
	fx_items.clear()
	for key in _rally_markers.keys():
		var m: Dictionary = _rally_markers[key]
		var n = m.get("node")
		if n != null and is_instance_valid(n):
			n.queue_free()
	_rally_markers.clear()
	_ghost_active = false
	if _ghost_root != null:
		_ghost_root.visible = false
	stats["rally_active"] = 0


# --- coordinate helper -----------------------------------------------------

# Map positions are Vector2 metres (game.gd:16 TILE=2.0, game.height_at at
# game.gd:1893-1907). Vector3 callers are passed through unchanged so the
# integration owner can feed already-transformed scene coordinates.
func world_pos(p) -> Vector3:
	if p is Vector3:
		return p
	if not (p is Vector2):
		return Vector3.ZERO
	var v2: Vector2 = p
	var h: float = height_bias
	if game != null and game.has_method("height_at"):
		h += float(game.call("height_at", v2))
	return Vector3(v2.x - world_offset.x, h, v2.y - world_offset.y)


# --- event stream (peek, never clear or edit the sim) ----------------------

# game.gd:2823 appends {"type","pos","kind","extra"} to game.events. main.gd
# clears that array in its own _consume_events (main.gd:1514-1564). This module
# peeks with a high-water index and NEVER clears: if main clears first there is
# nothing to see, so integration should call fx.sync() before main consumes,
# or set consume_events=false and forward add_fx() itself. Open question Q3.
func _consume_events() -> void:
	if game == null:
		return
	var evs = game.get("events")
	if not (evs is Array):
		return
	if evs.size() < _events_seen:
		_events_seen = 0
	for i in range(_events_seen, evs.size()):
		var ev = evs[i]
		if not (ev is Dictionary):
			continue
		var kind: String = str(EVENT_FX.get(str(ev.get("type", "")), ""))
		if kind.is_empty():
			continue
		if not _valid_pos(ev.get("pos", null)):
			continue
		add_fx(ev.get("pos"), kind, -1.0)
		stats["events_consumed"] = int(stats.get("events_consumed", 0)) + 1
	_events_seen = evs.size()


# Mirrors world.gd:3545-3561 `_emit_arrow_trails`; reads game.projectiles only.
# Donor trail timing/width come from source.pfx:1740/1746 (literal, UNVERIFIED).
func _emit_arrow_trails() -> void:
	if game == null:
		return
	var prs = game.get("projectiles")
	if not (prs is Array):
		return
	for pr in prs:
		if not (pr is Dictionary):
			continue
		if str(pr.get("kind", "")) not in ["arrow", "firearrow"]:
			continue
		var seen := false
		for item in fx_items:
			if str(item.get("kind", "")) == "trail" and item.get("pr") == pr:
				seen = true
				break
		if seen:
			continue
		var pos = pr.get("pos", null)
		if not _valid_pos(pos):
			continue
		var item: Dictionary = add_fx(pos, "trail", TRAIL_TIME_LIMIT)
		if not item.is_empty():
			item["pr"] = pr
			item["base_alpha"] = TRAIL_ALPHA


# --- node construction -----------------------------------------------------

func _ensure_roots() -> void:
	if _root == null:
		_root = Node3D.new()
		_root.name = "FX3D"
		add_child(_root)
	if _ghost_root == null:
		_ghost_root = Node3D.new()
		_ghost_root.name = "BuildGhost3D"
		_ghost_root.visible = false
		add_child(_ghost_root)
		_ghost_mat = _material(GHOST_OK, false)
		var bm := BoxMesh.new()
		bm.size = Vector3(1.0, 0.05, 1.0)
		_ghost_mesh = MeshInstance3D.new()
		_ghost_mesh.name = "Footprint"
		_ghost_mesh.mesh = bm
		_ghost_mesh.material_override = _ghost_mat
		_ghost_root.add_child(_ghost_mesh)
	if _rally_root == null:
		_rally_root = Node3D.new()
		_rally_root.name = "Rally3D"
		add_child(_rally_root)


func _material(col: Color, additive: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = Color(col.r, col.g, col.b)
	m.emission_energy_multiplier = 0.35
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if additive:
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	return m


func _add_mesh(holder: Node3D, mesh: Mesh, mat: Material,
		p: Vector3, rot: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = p
	mi.rotation = rot
	holder.add_child(mi)
	return mi


func _add_light(holder: Node3D, col: Color, energy: float, range_m: float) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.light_color = col
	l.light_energy = energy
	l.omni_range = range_m
	l.shadow_enabled = false
	holder.add_child(l)
	return l


func _kind_color(k: String) -> Color:
	match k:
		"shot":
			return Color(1.0, 0.90, 0.50, 0.95)   # world.gd:3653
		"smoke":
			return Color(0.85, 0.85, 0.82, 0.55)  # world.gd:3657
		"explode":
			return Color(1.0, 0.60, 0.20, 0.90)   # world.gd:3660
		"crater":
			return Color(0.15, 0.12, 0.09, 0.80)  # world.gd:3663
		"fire":
			return Color(1.0, 0.45, 0.10, 0.85)   # world.gd:3666
		"heal":
			return Color(0.40, 1.00, 0.50, 0.80)  # world.gd:3669
		"capture":
			return Color(1.0, 1.0, 1.0, 0.85)     # world.gd:3672
		"rout":
			return Color(1.0, 0.30, 0.20, 0.85)   # world.gd:3674
		"chop":
			return Color(0.70, 0.60, 0.30, 0.80)  # world.gd:3676
		"trail":
			return Color(1.0, 0.88, 0.62, TRAIL_ALPHA)  # world.gd:3685
	return Color(1.0, 1.0, 1.0, 0.6)


func _build_visual(item: Dictionary, k: String) -> void:
	var holder: Node3D = item["node"]
	var col: Color = _kind_color(k)
	var additive: bool = k in ["shot", "explode", "fire", "heal"]
	var mat := _material(col, additive)
	item["mat"] = mat
	item["base_alpha"] = col.a
	match k:
		"shot":
			var sm := SphereMesh.new()
			sm.radius = 0.35
			sm.height = 0.7
			_add_mesh(holder, sm, mat, Vector3(0, 1.2, 0), Vector3.ZERO)
			item["light"] = _add_light(holder, Color(1, 0.85, 0.45), 3.0, 6.0)
			item["light_energy"] = 3.0
		"smoke":
			var qm := PlaneMesh.new()
			qm.size = Vector2(1.4, 1.4)
			_add_mesh(holder, qm, mat, Vector3(0, 1.4, 0), Vector3.ZERO)
			_add_mesh(holder, qm, mat, Vector3(0, 1.4, 0), Vector3(0, PI * 0.5, 0))
		"explode":
			var sm2 := SphereMesh.new()
			sm2.radius = 0.8
			sm2.height = 1.6
			_add_mesh(holder, sm2, mat, Vector3(0, 0.9, 0), Vector3.ZERO)
			item["light"] = _add_light(holder, Color(1, 0.5, 0.15), 5.0, 12.0)
			item["light_energy"] = 5.0
		"crater":
			var cyl := CylinderMesh.new()
			cyl.top_radius = 1.2
			cyl.bottom_radius = 1.2
			cyl.height = 0.05
			_add_mesh(holder, cyl, mat, Vector3(0, 0.03, 0), Vector3.ZERO)
		"fire":
			var qm2 := PlaneMesh.new()
			qm2.size = Vector2(0.7, 1.0)
			_add_mesh(holder, qm2, mat, Vector3(0, 0.7, 0), Vector3.ZERO)
			_add_mesh(holder, qm2, mat, Vector3(0, 0.7, 0), Vector3(0, PI * 0.5, 0))
			item["light"] = _add_light(holder, Color(1, 0.45, 0.1), 2.0, 5.0)
			item["light_energy"] = 2.0
		"heal":
			var tm := TorusMesh.new()
			tm.inner_radius = 0.6
			tm.outer_radius = 0.75
			_add_mesh(holder, tm, mat, Vector3(0, 0.15, 0), Vector3.ZERO)
		"capture":
			var b := BoxMesh.new()
			b.size = Vector3(0.9, 0.5, 0.04)
			_add_mesh(holder, b, mat, Vector3(0.5, 1.9, 0), Vector3.ZERO)
		"rout", "chop":
			var qm3 := PlaneMesh.new()
			qm3.size = Vector2(0.6, 0.6)
			_add_mesh(holder, qm3, mat, Vector3(0, 1.1, 0), Vector3.ZERO)
		"trail":
			var tb := BoxMesh.new()
			tb.size = Vector3(TRAIL_WIDTH_M, TRAIL_WIDTH_M, TRAIL_STREAK_M)
			_add_mesh(holder, tb, mat, Vector3.ZERO, Vector3.ZERO)


func _make_rally(p3: Vector3, player: int) -> Dictionary:
	var holder := Node3D.new()
	holder.name = "RallyP%d" % player
	holder.position = p3
	_rally_root.add_child(holder)

	# Pole: wood tone copied from world.gd:3623 (port primitive, not donor art).
	var wood := _material(Color(0.55, 0.42, 0.25, 1.0), false)
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.05
	pole_mesh.bottom_radius = 0.06
	pole_mesh.height = 1.6
	_add_mesh(holder, pole_mesh, wood, Vector3(0, 0.8, 0), Vector3.ZERO)

	var finial_mat := _material(Color(0.95, 0.85, 0.45, 1.0), false)  # world.gd:3629
	var fin := SphereMesh.new()
	fin.radius = 0.09
	fin.height = 0.18
	_add_mesh(holder, fin, finial_mat, Vector3(0, 1.68, 0), Vector3.ZERO)

	var dark := _material(Color(0.0, 0.0, 0.0, 0.35), false)  # world.gd:3619
	var foot := CylinderMesh.new()
	foot.top_radius = 0.45
	foot.bottom_radius = 0.45
	foot.height = 0.05
	_add_mesh(holder, foot, dark, Vector3(0, 0.03, 0), Vector3.ZERO)

	var flag_mat := _material(_player_color(player), false)
	var flag := PlaneMesh.new()
	flag.size = Vector2(0.9, 0.5)
	_add_mesh(holder, flag, flag_mat, Vector3(0.50, 1.35, 0), Vector3.ZERO)
	return {"node": holder, "mat": flag_mat, "player": player, "seen": _time}


func _set_rally_color(m: Dictionary, player: int) -> void:
	if int(m.get("player", -1)) == player:
		return
	m["player"] = player
	var c: Color = _player_color(player)
	var mat: StandardMaterial3D = m.get("mat")
	if mat != null:
		mat.albedo_color = c
		mat.emission = Color(c.r, c.g, c.b)


# --- per-frame animation ---------------------------------------------------

func _update_fx(dt: float) -> void:
	var keep: Array = []
	for item in fx_items:
		var age: float = float(item.get("age", 0.0)) + dt
		item["age"] = age
		var life: float = maxf(0.001, float(item.get("life", DEFAULT_LIFE)))
		var k: float = clampf(age / life, 0.0, 1.0)
		var node = item.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var idx: float = float(item.get("index", 0))
		match str(item.get("kind", "")):
			"smoke":
				node.position.y = float(item.get("base_y", 0.0)) + k * 1.6
				var s: float = 1.0 + k * 1.4
				node.scale = Vector3(s, s, s)
			"explode":
				var s2: float = 1.0 + k * 2.2
				node.scale = Vector3(s2, s2, s2)
			"heal":
				var s3: float = 0.6 + k * 2.0
				node.scale = Vector3(s3, 1.0, s3)
			"fire":
				var f: float = 0.85 + 0.15 * sin(age * 14.0 + idx)
				node.scale = Vector3(f, f, f)
			"trail":
				_orient_trail(item, node)
		var mat: StandardMaterial3D = item.get("mat")
		if mat != null:
			var c: Color = mat.albedo_color
			c.a = float(item.get("base_alpha", 1.0)) * (1.0 - k)
			mat.albedo_color = c
			mat.emission_energy_multiplier = 0.35 * (1.0 - k)
		var light: OmniLight3D = item.get("light")
		if light != null and is_instance_valid(light):
			light.light_energy = float(item.get("light_energy", 0.0)) * (1.0 - k)
		if age < life:
			keep.append(item)
		else:
			_free_item(item)
			stats["expired"] = int(stats.get("expired", 0)) + 1
	fx_items = keep


func _orient_trail(item: Dictionary, node: Node3D) -> void:
	var pr = item.get("pr")
	if not (pr is Dictionary):
		return
	if not (pr.has("pos") and pr.has("target") and pr.has("t") and pr.has("total")):
		return
	if not (pr.get("pos") is Vector2 and pr.get("target") is Vector2):
		return
	var head2: Vector2 = (pr["target"] as Vector2).lerp(
		pr["pos"] as Vector2, 1.0 - float(pr["t"]) / maxf(0.01, float(pr["total"])))
	var dir2: Vector2 = (pr["target"] as Vector2) - (pr["pos"] as Vector2)
	if dir2.length_squared() < 0.01:
		dir2 = Vector2.RIGHT
	dir2 = dir2.normalized()
	var tail2: Vector2 = head2 - dir2 * TRAIL_STREAK_M
	var a: Vector3 = world_pos(tail2)
	var b: Vector3 = world_pos(head2)
	node.position = (a + b) * 0.5
	if node.is_inside_tree() and a.distance_to(b) > 0.001:
		node.look_at(b, Vector3.UP)


func _update_rally() -> void:
	var stale: Array = []
	for key in _rally_markers.keys():
		var m: Dictionary = _rally_markers[key]
		if _time - float(m.get("seen", 0.0)) <= RALLY_TTL:
			continue
		var n = m.get("node")
		if n != null and is_instance_valid(n):
			n.queue_free()
		stale.append(key)
	for key in stale:
		_rally_markers.erase(key)
	stats["rally_active"] = _rally_markers.size()


func _update_ghost() -> void:
	if _ghost_root == null:
		return
	_ghost_root.visible = _ghost_active
	if not _ghost_active or _ghost_mat == null:
		return
	var c: Color = GHOST_OK if _ghost_ok else GHOST_BAD
	var pulse: float = 0.85 + 0.15 * sin(_time * 4.0)
	c.a *= pulse
	_ghost_mat.albedo_color = c
	_ghost_mat.emission = Color(c.r, c.g, c.b)


# --- small helpers ---------------------------------------------------------

func _enforce_cap() -> void:
	var cap: int = FALLBACK_FX_CAP
	if Data != null:
		cap = int(Data.FX_CAP)
	if cap <= 0:
		cap = FALLBACK_FX_CAP
	while fx_items.size() > cap:
		var old: Dictionary = fx_items.pop_front()
		_free_item(old)


func _free_item(item: Dictionary) -> void:
	var n = item.get("node")
	if n != null and is_instance_valid(n):
		n.queue_free()
	item["node"] = null
	item["mat"] = null
	item["light"] = null


func _finite(x: float) -> bool:
	return not is_nan(x) and not is_inf(x)


func _finite3(v: Vector3) -> bool:
	return _finite(v.x) and _finite(v.y) and _finite(v.z)


func _valid_pos(p) -> bool:
	if p is Vector2:
		var v: Vector2 = p
		return _finite(v.x) and _finite(v.y)
	if p is Vector3:
		return _finite3(p)
	return false


func _player_color(p: int) -> Color:
	return PLAYER_COLORS[wrapi(p, 0, PLAYER_COLORS.size())]


func _building_radius(sid: String) -> float:
	if Data != null and Data.BUILDINGS.has(sid):
		var d = Data.BUILDINGS[sid]
		if d is Dictionary and d.has("radius"):
			return maxf(0.25, float(d.radius))
	return 1.5
