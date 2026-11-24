extends Node3D

# V7-51 — world3d.gd: INTEGRATION COMPOSITION of the five landed world3d_* atoms.
#
# SCOPE: SINGLEPLAYER SKIRMISH ONLY (D-12). No donor binaries, no sprite sheets,
# no chunking, no RNG. TABS ONLY. Loaded dynamically (no class_name — a fresh
# global class is not in .godot's cache until an editor import, and every Godot
# launch goes through variant3d/tools/godot_runner.py).
#
# THIS FILE REPLACES the legacy M0 terrain-only world (backup:
# inbox/backup/world3d.gd.bak-V751). It does NOT re-implement terrain, entities,
# fog or FX: it instantiates and delegates to the owned modules and supplies the
# FULL 2D world contract that main.gd / hud.gd / input_controller.gd consume.
#
# --- COMPOSITION MAP (which module owns which contract member) ----------------
#   bind(game)              -> this file: creates + bind()s all modules, aliases
#                              fog arrays, sets view_scale, builds terrain once.
#   sync(dt)                -> this file: derives view_rect, mirrors selection,
#                              then delegates to entities.sync / fx.sync / fog.sync.
#   view_scale (data)       -> this file (Data.PIXELS_PER_METER, data.gd:113).
#   view_rect (data)        -> this file (Camera3D ground frustum -> canvas px;
#                              axis-aligned under yaw is a PORT APPROXIMATION,
#                              V71 §6 Q5 / study open Q9).
#   fx_layer (node)         -> this file: aliases the composed world3d_fx node.
#   world_to_px(p) (data)   -> this file: p * view_scale, canvas px (world.gd:350).
#   fog_explored/fog_vis    -> world3d_fog arrays, ALIASED after fog.bind()
#                              (fog.bind reassigns them). main.gd:1234-1235 fill()
#                              therefore reaches the fog module's live arrays.
#   add_fx(kind,pos)        -> this file swaps to world3d_fx.add_fx(pos,kind,life).
#                              fx.consume_events = false: main._consume_events
#                              (main.gd:1518-1554) forwards events explicitly, so
#                              the module's own event peek must not double-spawn
#                              (V7-15 report §6 Q1).
#   has_chunk_or_fallback() -> world3d_terrain (trivially true: ONE full-grid
#                              mesh, no chunks — V7-13 §2/§4).
#   selected state          -> this file mirrors input_controller's selected_ids
#                              and exposes sel_rect/sel_active (input writes them
#                              at input_controller.gd:1017-1020). The authoritative
#                              e["selected"] flag stays on the sim entities
#                              (V71 §3 "selection state" row).
#   anim3d handoff          -> this file loads anim3d.gd and bind(game, entities);
#                              its PORT_LABEL "PORT APPROXIMATION — NOT DONOR
#                              PARITY" is preserved by that module (V7-18).
#
# --- DONOR / PORT CITATIONS (V73 rule: cite path:line or mark UNVERIFIED) ------
#   Full 2D contract members .... docs/coord_swarm_2026-11-24/reports/
#                                 V71_mechanics_inventory.md:180-199 (§3 table)
#   Integration seam owner ...... V73_ATOMIC_CONTRACT.md:19-24
#   view_scale scalar ........... variant3d/scripts/data.gd:113 PIXELS_PER_METER=16
#                                 (port value; donor px/metre UNVERIFIED).
#   world_to_px ................. variant3d/scripts/world.gd:350-351 (p*view_scale)
#   fx_layer / add_fx ........... world.gd:126,310-316,3563-3579; main.gd:1521-1553
#   fog arrays .................. world.gd:27-28,333-347; main.gd:1234-1235
#   has_chunk_or_fallback ....... world.gd:1746-1747 (test hook; trivial in 3D)
#   terrain module .............. V713 report §4 (generatemap.inc:537-577,
#                                 mapgen.gd:29, data.gd:23; donor absolutes UNVERIFIED)
#   entities module ............. V714 report §2 (116 donor OBJ, envscales.cfg;
#                                 .oss bone parents unreadable -> static bind pose)
#   fx module ................... V715 report §4 (PFX keys literal / SEMANTICS
#                                 UNVERIFIED; lifetimes from world.gd:3563-3579)
#   fog module .................. V716 report §3 (donor fog<->explored UNVERIFIED;
#                                 alpha ladder is port state from world.gd:2251-2255)
#   anim module ................. V718 report / anim3d.gd:41 PORT_LABEL
# HONEST LIMIT: visual / integration runtime is UNVERIFIED until the main.gd,
# input_controller.gd and hud.gd render_mode seams land (separate owners).

const Data = preload("res://scripts/data.gd")

# Module scripts (loaded dynamically — V73_ATOMIC_CONTRACT.md:26-30).
const TERRAIN_SCRIPT := "res://scripts/world3d_terrain.gd"
const ENTITIES_SCRIPT := "res://scripts/world3d_entities.gd"
const FX_SCRIPT := "res://scripts/world3d_fx.gd"
const FOG_SCRIPT := "res://scripts/world3d_fog.gd"
const ANIM_SCRIPT := "res://scripts/anim3d.gd"

# --- FULL 2D WORLD CONTRACT: DATA MEMBERS (V71 §3 :184-195) -------------------
var game = null                      # untyped: C3Game object OR dictionary test double
var hud = null                       # 2D bind parity (world.gd:237-239)
var view_scale: float = 16.0         # port scalar: Data.PIXELS_PER_METER (data.gd:113)
var view_rect := Rect2(0.0, 0.0, 1.0, 1.0)   # canvas px, map-origin (V71 §3 :191)
var fx_layer: Node3D = null          # composed FX node (V71 §3 :190)
var fog_explored: PackedByteArray = PackedByteArray()
var fog_vis: PackedByteArray = PackedByteArray()

# Selection state: world mirrors, input_controller owns the authoritative ids.
var selected_ids: Array = []
var selected: Dictionary = {}        # id -> entity (aura consumers; read-only mirror)
var sel_rect := Rect2(0.0, 0.0, 0.0, 0.0)   # input_controller.gd:1017 writes this
var sel_active := false              # input_controller.gd:1018/1020 writes this

# --- composed module instances (children of this Node3D; never re-implemented) -
var terrain = null   # world3d_terrain.gd : bind/build/invalidate/height_at_world
var entities = null  # world3d_entities.gd : bind/sync/add_*/remove
var fx = null        # world3d_fx.gd       : bind/sync/add_fx/draw_*/
var fog = null       # world3d_fog.gd      : bind/sync + fog_* arrays
var anim = null      # anim3d.gd           : bind(game, entities)/play

var stats: Dictionary = {}
var anim_t: float = 0.0
var _modules_ready: bool = false


# --- helpers -----------------------------------------------------------------

func _int_prop(g, key: String, fallback: int) -> int:
	if g == null:
		return fallback
	var v = g.get(key)
	if v is int:
		return int(v)
	if v is float:
		return int(v)
	return fallback


# Instantiate one module once and attach it to the composed world.
func _instantiate(path: String) -> Node:
	if not ResourceLoader.exists(path):
		push_error("world3d: missing module " + path)
		return null
	var scr = load(path)
	if scr == null or not scr.can_instantiate():
		push_error("world3d: cannot instantiate " + path)
		return null
	var inst = scr.new()
	if not (inst is Node):
		push_error("world3d: module is not a Node " + path)
		return null
	add_child(inst as Node)
	return inst as Node


# The terrain module builds from a dump dict or a live game.height[] grid.
# Check for either so a minimal stub does not emit a spurious push_error.
func _has_height_source(g) -> bool:
	if g == null:
		return false
	for key in ["dump", "map_dump", "self_base"]:
		var cand = g.get(key)
		if cand is Dictionary and (cand as Dictionary).has("height"):
			return true
	return g.get("height") is PackedFloat32Array


func _full_map_rect_px() -> Rect2:
	var w := _int_prop(game, "MAP_W", 160)   # game.gd:35-36 defaults
	var h := _int_prop(game, "MAP_H", 160)
	var t: float = float(Data.TILE_M)        # data.gd:23
	return Rect2(0.0, 0.0, float(w) * t * view_scale, float(h) * t * view_scale)


# Camera3D ground frustum -> visible map rect in canvas px (map-origin metres
# x view_scale), so input_controller.gd:499 `vp.has_point(u.pos*view_scale)` and
# world.gd's view_rect consumers stay semantically identical. Axis-aligned AABB
# under camera yaw is a PORT APPROXIMATION (V71 §6 Q5 / study open Q9).
func _update_view_rect() -> void:
	var rect := _full_map_rect_px()
	var w := _int_prop(game, "MAP_W", 160)
	var h := _int_prop(game, "MAP_H", 160)
	var t: float = float(Data.TILE_M)
	var ox := float(w) * 0.5 * t   # 3D scene is centred on origin; sim is map-origin
	var oz := float(h) * 0.5 * t
	if is_inside_tree():
		var vp = get_viewport()
		if vp != null:
			var cam = vp.get_camera_3d()
			if cam != null and cam.has_method("get_viewport_corners"):
				var corners = cam.call("get_viewport_corners")
				if corners is Array:
					var ca: Array = corners
					if ca.size() >= 4:
						var min_x: float = INF
						var max_x: float = -INF
						var min_z: float = INF
						var max_z: float = -INF
						var saw: bool = false
						for c in ca:
							if not (c is Vector3):
								continue
							saw = true
							min_x = minf(min_x, (c as Vector3).x)
							max_x = maxf(max_x, (c as Vector3).x)
							min_z = minf(min_z, (c as Vector3).z)
							max_z = maxf(max_z, (c as Vector3).z)
						if saw and min_x <= max_x and min_z <= max_z:
							rect = Rect2((min_x + ox) * view_scale,
								(min_z + oz) * view_scale,
								(max_x - min_x) * view_scale,
								(max_z - min_z) * view_scale)
	view_rect = rect


# Mirror only; never write e["selected"] (input_controller.gd:148-158 owns it).
func _sync_selection() -> void:
	if game == null:
		return
	# Dictionary test doubles (V7-13/V7-14 bind those) have no has_method().
	if not (game is Object) or not game.has_method("get_selected"):
		return
	var got = game.call("get_selected")
	if got is Array:
		selected_ids = (got as Array).duplicate()
	selected.clear()
	var by_id = game.get("by_id")
	if by_id is Dictionary:
		for id in selected_ids:
			var k := int(id)
			if (by_id as Dictionary).has(k):
				selected[k] = (by_id as Dictionary)[k]


# --- FULL 2D WORLD CONTRACT: API ---------------------------------------------

func bind(g, h = null) -> void:
	game = g
	hud = h
	view_scale = float(Data.PIXELS_PER_METER)   # world.gd:240; data.gd:113
	if not _modules_ready:
		terrain = _instantiate(TERRAIN_SCRIPT)
		entities = _instantiate(ENTITIES_SCRIPT)
		fx = _instantiate(FX_SCRIPT)
		fog = _instantiate(FOG_SCRIPT)
		anim = _instantiate(ANIM_SCRIPT)
		# fx_layer is a real Node3D the input seam can attach route overlays to.
		if fx != null:
			fx_layer = fx as Node3D
		else:
			var holder := Node3D.new()
			holder.name = "FXLayer3D"
			add_child(holder)
			fx_layer = holder
		_modules_ready = true

	# Dependency order: terrain geometry before fog overlay, entities before anim.
	if terrain != null:
		terrain.bind(game)
		if _has_height_source(game):
			terrain.build()   # ONE full-grid mesh; no chunk scheduling
	if entities != null:
		entities.bind(game)
	if fx != null:
		fx.bind(game)
		# V7-15 §6 Q1: main forwards add_fx(); disable the module's event peek.
		fx.consume_events = false
	if fog != null:
		fog.bind(game)
	if anim != null:
		anim.bind(game, entities)

	# Alias AFTER fog.bind(): fog.bind() reassigns its PackedByteArrays.
	if fog != null:
		fog_explored = fog.fog_explored
		fog_vis = fog.fog_vis
	else:
		var n: int = _int_prop(game, "MAP_W", 0) * _int_prop(game, "MAP_H", 0)
		fog_explored = PackedByteArray()
		fog_vis = PackedByteArray()
		fog_explored.resize(maxi(n, 0))
		fog_vis.resize(maxi(n, 0))

	stats = {
		"composition": "V7-51 world3d.gd",
		"modules": {
			"terrain": terrain != null,
			"entities": entities != null,
			"fx": fx != null,
			"fog": fog != null,
			"anim": anim != null,
		},
		"view_scale": view_scale,
		"fx_events_forwarded_only": true,
		"fog_arrays_aliased": fog != null,
		"contract": "V71_mechanics_inventory.md:180-199 / V73_ATOMIC_CONTRACT.md:24",
	}


# Mirrors world.gd:2072-2081 responsibilities: derive data, then let each
# composed module update its own render state. dt stays sim-agnostic.
func sync(dt: float) -> void:
	anim_t += maxf(dt, 0.0)
	_update_view_rect()
	_sync_selection()
	if entities != null:
		entities.sync(dt)
	if fx != null:
		fx.sync(dt)   # consume_events=false: ages existing FX only
	if fog != null:
		fog.sync(dt)  # internally gated by Data.FOG_INTERVAL (data.gd:118)


# Data-only scalar: metres -> canvas px (world.gd:350-351). Do NOT change the
# meaning for shared callers (V71 §3 :188, §6 Q2).
func world_to_px(p: Vector2) -> Vector2:
	return p * view_scale


# 2D contract order is add_fx(kind, pos) (world.gd:3563 / main.gd:1521-1553);
# the composed fx module takes add_fx(pos, kind, life) (V73 :14, V715 §2).
# Swap here so both call orders work. Returns the spawned item (benign superset).
func add_fx(kind, pos, life := -1.0) -> Dictionary:
	var k = kind
	var p = pos
	if kind is Vector2 and (pos is String or pos is StringName):
		k = pos
		p = kind
	if fx == null:
		return {}
	return fx.add_fx(p, str(k), float(life))


# 2D test-hook takes an optional chunk key; the composed terrain builds ONE
# full-grid mesh so there are no chunks/fallback (V713 §2/§4, V71 §3 :194).
func has_chunk_or_fallback(_k = null) -> bool:
	if terrain != null:
		return bool(terrain.has_chunk_or_fallback())
	return true


# Optional height passthrough for callers that used the legacy M0 world API.
func height_at_world(p: Vector2) -> float:
	if terrain != null:
		return float(terrain.height_at_world(p))
	return 0.0


# Explicit anim3d handoff surface (V73 :17, V714 §4). The module labels every
# pose PORT APPROXIMATION — NOT DONOR PARITY; no rig is fabricated here.
func play_anim(e, action, t):
	if anim == null:
		return {}
	return anim.play(e, action, t)
