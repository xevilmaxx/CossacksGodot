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
#   entity feed (V7-62)     -> this file reconciles game.entities / game.res_nodes
#                              into the entities module via add_*/remove (2D
#                              sources: world.gd:2213,2706,2837; by_id keys at
#                              game.gd:2023,517). The module itself only mutates
#                              already-registered slots (world3d_entities.gd:555+).
#   ghost / rally (V7-76)   -> this file translates the 2D build-ghost and
#                              selected-building rally conditions (world.gd:3460-
#                              3509 / :3602-3613) and forwards them to the FX
#                              module's public draw_ghost / draw_rally. No 2D file
#                              is edited; the FX meshes already exist.
#   selection aura (FIX-SELECTVIS) -> this file derives one entry per selected id
#                              from the EXISTING selected_ids / selected mirror
#                              and calls fx.sync_selection(entries). FX builds a
#                              flat ring + owner-colour pip per entry, in the 13
#                              donor key colours. No sim state / 2D file edited.
#   2D-only legacy slots    -> AUDIT3D-04 E08: aliases/no-ops for unbranched
#                              main.gd/hud.gd/input_controller.gd call sites;
#                              NO sprite/chunk pixels are fabricated (charter :40-53).
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
#   ghost trigger ............... app/scripts/world.gd:3460-3509 (hud.build_ghost_sid
#                                 :3464; mouse->ground wp :3467-3469; in_bounds :3470;
#                                 resolve_mine_sid :3486; BUILDINGS gate :3493;
#                                 can_place + can_pay :3502-3503; colour :3509)
#   rally trigger ............... app/scripts/world.gd:3602-3613 (selected player-0
#                                 building with a "rally" field -> e.rally/e.player)
#   selection ring / aura ....... app/scripts/world.gd:3011-3041 (building:
#                                 squashed player glow, dark under-ring, tinted
#                                 ring_sel, pulse), :3252-3254 (unit player ring),
#                                 :2845,2969-2972 (building flag player colour);
#                                 docs/coord_swarm_2026-11-24/reports/
#                                   COMPLETENESS_02_vs_2d.md:81,127 (no 3D ring),
#                                   AUDIT3D_02_colors.md:46-47,103-108 (G1/G3:
#                                   player colour never rendered; draw_rally had
#                                   no caller before V7-76)
#   donor key colours ........... variant3d/data/donor_key_colors.json slots 0..12
#                                 (13 donor colours; alpha UNVERIFIED — fx chooses 1.0)
#   ghost/rally dead API ........ AUDIT3D_06_fx_anim_audio.md:45-46,103 (P0 G10)
#   camera screen->ground ....... variant3d/scripts/camera3d.gd:167-176 (Camera3D
#                                 raycast; the 3D translation of world.gd:3467-3469)
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
# Z08 — HEIGHT WAVE relief props: static per-sid MultiMesh layer. New sibling
# module; no edit to pattern_gen.gd / game.gd / world3d_terrain.gd, so no stamp,
# RNG, height[] or blocked[] stream is touched.
const RELIEF_SCRIPT := "res://scripts/world3d_relief.gd"

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
var relief = null    # world3d_relief.gd   : bind(game, terrain) -> static prop MultiMeshes (Z08)

var stats: Dictionary = {}
var anim_t: float = 0.0

# PERF redraw counters read/reset by the unbranched debug print at
# main.gd:1592,1599-1602. 2D declares them at app/scripts/world.gd:59-62 and
# increments at :2696 (resources), :2836 (buildings), :3227 (units), :3582 (FX).
# The 3D world has no sprite redraws, so count the equivalent module work:
# entity-feed additions below and explicit FX spawns in add_fx().
var dbg_res: int = 0
var dbg_bld: int = 0
var dbg_unit: int = 0
var dbg_fx: int = 0
var _modules_ready: bool = false

# --- 2D-only legacy contract slots (AUDIT3D-04 E08; app/scripts/world.gd) -----
# These keep byte-identical callers legal in 3D. They carry NO drawn pixels:
# 3D terrain is ONE mesh (no Sprite2D chunks) and the 3D branch loads no
# baked sheet (WAVE7 charter :40-53). See report V762_entity_feed.md §4.
var fog_revision: int = 0                       # world.gd:137 / hud.gd:1741
var _fog_rev_vis: PackedByteArray = PackedByteArray()
var fog_sprite: Node3D = null                   # visibility proxy, NOT a Sprite2D
var terrain_chunks: Dictionary = {}             # world.gd:32
var terrain_order: Array = []                   # world.gd:34
var terrain_px: int = int(Data.TERRAIN_PX)      # world.gd:56; data.gd:118
var terrain_masks: Array = []                   # world.gd:69
var anim_index: Dictionary = {}                 # world.gd:163
var anim_tex: Dictionary = {}                   # world.gd:164
var _rally_dirty: bool = false                  # world.gd:149 (legacy slot)

# V7-62 entity feed: ids already forwarded to the composed entities module.
var _feed_entity_ids: Dictionary = {}
var _feed_res_ids: Dictionary = {}

# V7-80: mirrors of the 2D resource-change gate (app/scripts/game.gd:2642-2661).
# -1 is the "unset" sentinel: a real res_dirty starts at 0 (game.gd:149) and only
# climbs, so a freshly bound game can never match a stale value from the last one.
var _feed_res_ver: int = -1
var _feed_res_size: int = -1

# V7-76 build-ghost ground position (SIM map-origin metres). In a live 3D run
# `_ghost_world_pos()` derives this from the current Camera3D + viewport mouse:
# camera3d.gd:266-275's screen_to_world() returns CENTRED scene metres since
# V7-81, so the fallback adds the half-map offset before returning (FIX-GHOST F1).
# The 2D analogue is world.gd:3467-3469. `_ghost_pos_override` lets a caller hand
# a SIM point in when no Camera3D is current (headless probe/tests) or when the
# input owner prefers picking3d.ground_point(); see `set_build_ghost_pos()`.
var _ghost_pos: Vector2 = Vector2.INF
var _ghost_pos_override: bool = false


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


# Same key read for Dictionary entities (game.gd:1980-1999) and Object stubs.
func _prop(g, key: String, fallback):
	if g == null:
		return fallback
	var v = g.get(key)
	return fallback if v == null else v


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
							var xy := Vector2.ZERO
							if c is Vector2:
								# camera3d.get_viewport_corners() returns CENTRED world metres
								# (camera3d.gd:354-363, :435-438; hud3d_adapter.gd:57-62);
								# shift to SIM map-origin metres before the view_scale multiply.
								xy = (c as Vector2) + Vector2(ox, oz)
							elif c is Vector3:
								# Legacy centre-origin corner: preserve the
								# existing re-centring onto map-origin metres.
								var v3 := c as Vector3
								xy = Vector2(v3.x, v3.z) + Vector2(ox, oz)
							else:
								continue
							if not is_finite(xy.x) or not is_finite(xy.y):
								continue
							saw = true
							min_x = minf(min_x, xy.x)
							max_x = maxf(max_x, xy.x)
							min_z = minf(min_z, xy.y)
							max_z = maxf(max_z, xy.y)
						if saw and min_x <= max_x and min_z <= max_z:
							rect = Rect2(min_x * view_scale, min_z * view_scale,
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
	selected_ids.clear()
	selected.clear()
	if not (got is Array):
		return
	# game.gd:2585-2590 returns ENTITY DICTIONARIES, not ids. Extract the id
	# with the same key by_id uses (game.gd:2023); `int(item)` on a Dictionary
	# throws "Nonexistent 'int' constructor" every frame (AUDIT3D-09 G2).
	# selected_ids therefore holds ints, matching input_controller.gd:189.
	var by_id = game.get("by_id")
	for item in (got as Array):
		var k := _int_prop(item, "id", -1)
		if k < 0:
			continue
		selected_ids.append(k)
		if by_id is Dictionary and (by_id as Dictionary).has(k):
			selected[k] = (by_id as Dictionary)[k]


# --- V7-62: live sim entities -> composed entity module ----------------------
# The 2D renderer draws units/buildings from game.entities (world.gd:2213,
# :2837) and resource nodes from game.res_nodes (world.gd:2706); by_id keys
# both collections (game.gd:2023, :517). Reconcile those SAME collections into
# the existing world3d_entities API — no new art, no RNG, no sprite sheets.
# The module's add_* calls are idempotent; the two id sets here make the
# "newly seen -> add_* / gone -> remove()" transitions explicit and O(n).
func _reconcile_entities() -> void:
	if entities == null or game == null:
		return
	var ent_coll = game.get("entities")
	var res_coll = game.get("res_nodes")
	var live_ents: Dictionary = {}
	if ent_coll is Array:
		for e in (ent_coll as Array):
			var id := _int_prop(e, "id", -1)
			# 2D skips dead entities at world.gd:2201/2230/2838.
			if id < 0 or bool(_prop(e, "dead", false)):
				continue
			live_ents[id] = e
			if _feed_entity_ids.has(id):
				continue
			var kind := str(_prop(e, "kind", ""))
			if kind == "unit":
				entities.add_unit(e)
				dbg_unit += 1  # 3D analogue of world.gd:3227
			elif kind == "building":
				entities.add_building(e)
				dbg_bld += 1  # 3D analogue of world.gd:2836
			else:
				live_ents.erase(id)
				continue
			_feed_entity_ids[id] = true
	for id in _feed_entity_ids.keys():
		if not live_ents.has(id):
			entities.remove(id)
			_feed_entity_ids.erase(id)

	# --- V7-80: gate ONLY the resource half of this feed -----------------------
	# Translate, do not invent: 2D rebuilds its resource hash only when the node
	# SET changes —
	#   if _res_grid_ver == res_dirty and _res_grid_src_size == res_nodes.size():
	#       return
	# (app/scripts/game.gd:2642-2661). res_dirty is the exact field
	# (game.gd:149): it is bumped on add (:520), mine relocation (:1360), field
	# restore (:2170), stump expiry (:3942) and resow (:5206). The array-size
	# guard is ALSO verbatim 2D: _compact()'s depletion filter (game.gd:251-280,
	# called :3914) and mapgen's remove_at (:1225) mutate membership without a
	# res_dirty bump; the same comment sits at game.gd:2643-2644.
	# The 2D world layer additionally force-redraws on camera move / fields_anim
	# (app/scripts/world.gd:2095-2104), but that clause is for per-frame growth
	# bars and rotors (world.gd:2096-2098) — pure redraw concerns with no
	# counterpart in this add/remove feed. Field restoration bumps res_dirty at
	# game.gd:2170, so the add/remove state is still fully covered.
	#
	# SAFE FALLBACK: if the signal is unavailable (Dictionary test doubles,
	# Object stubs without res_dirty, or a non-Array res_nodes), run the resource
	# half every frame — byte-identical to the pre-V7-80 behaviour.
	var rd = _prop(game, "res_dirty", null)
	var signal_ok: bool = (rd is int or rd is float) and res_coll is Array
	if signal_ok:
		var rv := int(rd)
		var rs: int = (res_coll as Array).size()
		if rv == _feed_res_ver and rs == _feed_res_size:
			return
		# Mark seen on the run that actually rebuilds (game.gd:2660-2661).
		_feed_res_ver = rv
		_feed_res_size = rs
	var live_res: Dictionary = {}
	if res_coll is Array:
		for n in (res_coll as Array):
			var rid := _int_prop(n, "id", -1)
			if rid < 0:
				continue
			var ty := str(_prop(n, "type", ""))
			# Mirror 2D world.gd:2712-2716: exhausted finite nodes are gone;
			# permanent ore (max_hits == 0), stumps and food stay visible.
			if _int_prop(n, "hits", 0) <= 0 and _int_prop(n, "max_hits", 0) != 0 \
					and ty != "stump" and ty != "food":
				continue
			live_res[rid] = n
			if not _feed_res_ids.has(rid):
				entities.add_resource(n)
				dbg_res += 1  # 3D analogue of world.gd:2696
				_feed_res_ids[rid] = true
	for id in _feed_res_ids.keys():
		if not live_res.has(id):
			entities.remove(id)
			_feed_res_ids.erase(id)


# --- V7-76: 2D build-ghost / rally state -> FX draw_ghost / draw_rally --------
# P0 G10 (AUDIT3D_06_fx_anim_audio.md:45-46,103): world3d_fx.gd exposes the two
# public draw APIs but nothing called them at runtime. Translate the exact 2D
# conditions; do not invent a placement sid, point or affordability rule.

# Build the ghost's SIM map-origin ground point. Two sources, in order:
#   1. explicit handoff via set_build_ghost_pos() (headless probe / input owner);
#   2. the current Camera3D's screen_to_world(viewport mouse) — camera3d.gd:266-275
#      returns CENTRED scene metres since V7-81, so add the half-map offset here
#      to reach SIM map-origin metres (3D analogue of world.gd:3467-3469).
# Returns Vector2.INF when neither is usable; the caller then hides the ghost.
func _ghost_world_pos() -> Vector2:
	if _ghost_pos_override and is_finite(_ghost_pos.x) and is_finite(_ghost_pos.y):
		return _ghost_pos
	if is_inside_tree():
		var vp = get_viewport()
		if vp != null:
			var cam = vp.get_camera_3d()
			if cam != null and cam.has_method("screen_to_world"):
				var wp = cam.call("screen_to_world", vp.get_mouse_position())
				if wp is Vector2 and is_finite((wp as Vector2).x) and is_finite((wp as Vector2).y):
					var hw := float(_int_prop(game, "MAP_W", 0)) * float(Data.TILE_M) * 0.5
					var hh := float(_int_prop(game, "MAP_H", 0)) * float(Data.TILE_M) * 0.5
					return (wp as Vector2) + Vector2(hw, hh)   # centred -> SIM map-origin
	return Vector2.INF


# world.gd:3502-3503 gates the ghost colour on can_place().ok AND affordability
# of Data.BUILDINGS[sid].cost from game.players[0].res (data.gd:1549-1553).
func _can_pay_building(def) -> bool:
	if not (def is Dictionary):
		return true
	var players = (null if game == null else game.get("players"))
	if not (players is Array) or (players as Array).is_empty():
		return true   # no sim treasury to consult: do not block the preview
	var p = (players as Array)[0]
	var res = null
	if p is Dictionary:
		res = (p as Dictionary).get("res")
	elif p is Object:
		res = p.get("res")
	if not (res is Array) or not ((def as Dictionary).get("cost") is Dictionary):
		return true
	return Data.can_pay(res as Array, (def as Dictionary)["cost"])


# Mirrors world.gd:3460-3509. `hud.build_ghost_sid` is authoritative (main.gd:614
# assigns world.hud AFTER hud.bind, so it is live in both ports). No mouse-cache/
# 120 ms verdict throttle is copied: that is a perf optimization, not a state
# condition, and the 3D FX ghost has no per-draw cost scan.
func _sync_build_ghost() -> void:
	if fx == null:
		return
	var sid: String = ""
	if hud != null:
		var raw = hud.get("build_ghost_sid")
		if raw != null:
			sid = str(raw)
	if sid.is_empty():
		# world.gd:3465 returns; FX has no ghost TTL, so actively clear it.
		fx.draw_ghost("", Vector2.ZERO, false)
		return
	var wp := _ghost_world_pos()
	if not is_finite(wp.x) or not is_finite(wp.y):
		fx.draw_ghost("", Vector2.ZERO, false)
		return
	# world.gd:3470 in_bounds gate.
	if game is Object and game.has_method("in_bounds") \
			and not bool(game.call("in_bounds", wp)):
		fx.draw_ghost("", Vector2.ZERO, false)
		return
	# world.gd:3486: the single "mine" button resolves to the deposit under cursor.
	if game is Object and game.has_method("resolve_mine_sid"):
		sid = str(game.call("resolve_mine_sid", sid, wp))
	# world.gd:3493: unknown sid draws no ghost.
	if not Data.BUILDINGS.has(sid):
		fx.draw_ghost("", Vector2.ZERO, false)
		return
	var ok := false
	if game is Object and game.has_method("can_place"):
		var chk = game.call("can_place", 0, sid, wp)
		if chk is Dictionary:
			ok = bool((chk as Dictionary).get("ok", false))
	if ok and not _can_pay_building(Data.BUILDINGS[sid]):
		ok = false
	fx.draw_ghost(sid, wp, ok)


# Mirrors world.gd:3602-3613: one rally marker per SELECTED player-0 building
# that has a "rally" field. FX caches markers by rounded ground point and expires
# unseen ones after world3d_fx.gd:102 RALLY_TTL, so a fresh draw each sync both
# refreshes live flags and lets stale ones expire — no 2D dirty-bit copy needed.
func _sync_rally() -> void:
	if fx == null or game == null:
		return
	var ents = game.get("entities")
	if not (ents is Array):
		return
	for e in (ents as Array):
		if e == null or bool(_prop(e, "dead", false)):
			continue
		if str(_prop(e, "kind", "")) != "building":
			continue
		var rp = _prop(e, "rally", null)
		if not (rp is Vector2):
			continue
		if _int_prop(e, "player", -1) != 0:
			continue
		if not bool(_prop(e, "selected", false)):
			continue
		fx.draw_rally(rp, 0)


# --- FIX-SELECTVIS: existing selection state -> FX selection ring / owner ----
# 2D draws a player-tinted aura under each selected building
# (app/scripts/world.gd:3011-3041) and a player ring under each selected unit
# (world.gd:3252-3254). Neither exists in 3D (COMPLETENESS_02_vs_2d.md:81,127;
# AUDIT3D_02_colors.md:46-47,103-108). Translate the SEMANTICS only: hand FX one
# entry per currently selected id and let it build procedural geometry. This
# reads the SAME read-only selected_ids / selected mirror established by
# _sync_selection(); it never writes e["selected"] or any other sim state.
# The FX ring meshes are labelled PORT APPROXIMATION — NOT DONOR PARITY.
func _sync_selection_aura() -> void:
	if fx == null:
		return
	var entries: Array = []
	for raw_id in selected_ids:
		var id := int(raw_id)
		var e = selected.get(id, null)
		if e == null:
			e = _entity_by_id(id)
		if e == null:
			continue
		var p = _prop(e, "pos", null)
		if not (p is Vector2 or p is Vector3):
			continue
		var kind := str(_prop(e, "kind", ""))
		if kind != "unit" and kind != "building":
			continue
		entries.append({
			"id": id,
			"pos": p,
			"player": _int_prop(e, "player", -1),
			"kind": kind,
			"radius": _selection_radius(e, kind),
		})
	fx.sync_selection(entries)


# Fallback lookup when the mirror has an id but by_id was unavailable (e.g. an
# Object stub that exposes get_selected() but not by_id). game.gd:2023 keys by_id
# with the same `id` field used here; game.entities is the 2D draw source.
func _entity_by_id(id: int):
	if game == null:
		return null
	var ents = game.get("entities")
	if ents is Array:
		for e in (ents as Array):
			if _int_prop(e, "id", -1) == id:
				return e
	var by_id = game.get("by_id")
	if by_id is Dictionary and (by_id as Dictionary).has(id):
		return (by_id as Dictionary)[id]
	return null


# Sim-metre footprint radius. 2D uses e.def.radius (world.gd:2846/3244); when a
# stub has no def, the same sid-keyed Data tables used by fx._building_radius()
# supply the donor-cited value (no invented per-frame measurement).
func _selection_radius(e, kind: String) -> float:
	var def = _prop(e, "def", null)
	if def is Dictionary and (def as Dictionary).has("radius"):
		return maxf(0.25, float((def as Dictionary).get("radius")))
	var sid := str(_prop(e, "sid", ""))
	var table = null
	if Data != null:
		table = Data.BUILDINGS if kind == "building" else Data.UNITS
	if table is Dictionary and (table as Dictionary).has(sid):
		var d = (table as Dictionary)[sid]
		if d is Dictionary and (d as Dictionary).has("radius"):
			return maxf(0.25, float((d as Dictionary).get("radius")))
	return 1.5 if kind == "building" else 0.35


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
		relief = _instantiate(RELIEF_SCRIPT)
		# fx_layer is a real Node3D the input seam can attach route overlays to.
		if fx != null:
			fx_layer = fx as Node3D
		else:
			var holder := Node3D.new()
			holder.name = "FXLayer3D"
			add_child(holder)
			fx_layer = holder
		# AUDIT3D-04 E08: main.gd:1442 writes `world.fog_sprite.visible`. 3D has
		# no Sprite2D; this Node3D is an honest visibility proxy only. Actual
		# fog visibility is read from Data.FOG_OF_WAR by world3d_fog.gd:317.
		fog_sprite = Node3D.new()
		fog_sprite.name = "FogVisibilityProxy3D"
		add_child(fog_sprite)
		_modules_ready = true

	# Re-binding reuses the module instances but rebuilds their registration
	# state; restart the feed id sets so no id is silently skipped.
	_feed_entity_ids.clear()
	_feed_res_ids.clear()
	# V7-80: reset the resource gate too. Without this, a new game whose
	# res_dirty/size match the old cached pair would skip the seed reconcile just
	# below and leave _feed_res_ids empty with no resources ever registered.
	_feed_res_ver = -1
	_feed_res_size = -1

	# Dependency order: terrain geometry before fog overlay, entities before anim.
	if terrain != null:
		terrain.bind(game)
		if _has_height_source(game):
			terrain.build()   # ONE full-grid mesh; no chunk scheduling
	# Z08: relief props are STATIC — build once here, after terrain.height_at_world
	# is live, from the already-generated game.pattern_stamps. Read-only on all
	# sim state; no per-frame work in sync().
	if relief != null:
		relief.bind(game, terrain)
	if entities != null:
		entities.bind(game)
		_reconcile_entities()   # V7-62: seed meshes from the live sim collections
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
			"relief": relief != null,
		},
		"view_scale": view_scale,
		"fx_events_forwarded_only": true,
		"fog_arrays_aliased": fog != null,
		"entity_feed": "V7-62 game.entities + game.res_nodes -> add_*/remove",
		"contract": "V71_mechanics_inventory.md:180-199 / V73_ATOMIC_CONTRACT.md:24",
		# Z08 observability — derived prop counts + PORT APPROX labels. The
		# module's own stats carries per-prop descriptors for QA reconciliation.
		"relief_props": relief.stats if relief != null else {},
	}


# Mirrors world.gd:2072-2081 responsibilities: derive data, then let each
# composed module update its own render state. dt stays sim-agnostic.
func sync(dt: float) -> void:
	anim_t += maxf(dt, 0.0)
	_update_view_rect()
	_sync_selection()
	_sync_selection_aura() # FIX-SELECTVIS: selected mirror -> fx.sync_selection
	_sync_build_ghost()    # V7-76: 2D build ghost -> fx.draw_ghost (P0 G10)
	_sync_rally()          # V7-76: selected-building rally -> fx.draw_rally
	_reconcile_entities()   # V7-62: add new sim entities, remove gone ones
	if entities != null:
		entities.sync(dt)
	if fx != null:
		fx.sync(dt)   # consume_events=false: ages existing FX only
	if fog != null:
		fog.sync(dt)  # internally gated by Data.FOG_INTERVAL (data.gd:118)
		# AUDIT3D-05 E16 / app world.gd:137,2247: bump only when the live
		# aliased fog array actually changes, so HUD's minimap cache can hit.
		if fog_vis != _fog_rev_vis:
			_fog_rev_vis = fog_vis.duplicate()
			fog_revision += 1


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
	dbg_fx += 1  # 3D analogue of world.gd:3582
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


# --- AUDIT3D-04 E08: 2D-only members used by UNBRANCHED shared callers --------
# All of these are honest aliases/no-ops. They keep main.gd:1331/1418-1442,
# hud.gd:1741/1748 and input_controller.gd:609/634 callable in 3D mode. No
# donor behaviour is invented and no sprite sheet is loaded (charter :40-53).

# Forced recompute after F9 load (main.gd:1329-1331). Fog state is owned by
# world3d_fog.gd:128; the arrays here are its live aliases (bind :361-364).
func _update_fog() -> void:
	if fog == null:
		return
	var before: PackedByteArray = fog_vis.duplicate()
	fog.call("_update_fog")
	if fog_vis != before:
		_fog_rev_vis = fog_vis.duplicate()
		fog_revision += 1


# 2D uses a dirty bit for static rally lines (world.gd:149-156). The 3D FX
# module refreshes rally markers on EVERY sync (world3d_fx.gd:129), so no bit
# is needed; dt=0 forces an immediate refresh without ageing any FX.
# V7-76: re-read the live selected-building rally state first, then age it, so
# a right-click (input_controller.gd:619/644) shows the new marker this frame.
func mark_rally_dirty() -> void:
	_rally_dirty = true
	_sync_rally()
	if fx != null:
		fx.sync(0.0)


# Input-side handoff (V7-76; now WIRED by FIX-GHOST F2 in 3D build mode). sync()
# can still derive a fallback from the current Camera3D + viewport mouse, but
# camera3d.gd:266-275 returns CENTRED scene metres there, so F1 converts it to
# SIM map-origin metres. The live 3D path prefers this explicit handoff: the
# input owner forwards the SAME SIM `pw` from picking3d.ground_point() that
# placement uses, avoiding a second projection and the flat-ray slope residual.
# `pw` must be SIM map-origin metres — the space FX's world_pos()/world_offset
# and game.in_bounds/can_place all expect.
func set_build_ghost_pos(p: Vector2) -> void:
	_ghost_pos = p
	_ghost_pos_override = true


# NO-OP by design: every 3D entity is a static bind pose and anim3d.gd owns
# the (explicitly labelled PORT APPROXIMATION) handoff. No sprite frames.
func _update_anim(_dt: float = 0.0) -> void:
	pass


# NO-OP: 3D terrain is ONE mesh; there are no Sprite2D chunks or forest bake.
func invalidate_forest_bake() -> void:
	pass


# Legacy scalar/array slots. `_bake_px` is copied verbatim from world.gd:1039
# (mini(terrain_px * 4, 64)); `_build_masks` returns the same empty legacy
# array as world.gd:1044-1051 — no side-effect images exist in 3D.
func _bake_px() -> int:
	return mini(terrain_px * 4, 64)


func _build_masks(_px: int) -> Array:
	return []


# Path STRING only, copied from world.gd:501-508 so main.gd:1429-1436 can
# resolve its legacy index. world3d.gd never loads from this directory.
func _anim_dir() -> String:
	if Data.SPRITE_CELL != 160:
		var d := "res://assets/models/anim%d" % Data.SPRITE_CELL
		if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(d)):
			return d
		if FileAccess.file_exists(d + "/land_units/index.json") or FileAccess.file_exists(d + "/index.json"):
			return d
	return "res://assets/models/anim"


# NO-OP: camera3d.gd derives its transform from _target/clamp_pos (:146-153)
# and has no 2D camera-dirty gate (camera.gd:116-121).
func mark_camera_dirty() -> void:
	pass
