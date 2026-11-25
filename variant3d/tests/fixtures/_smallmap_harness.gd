# Shared 64² stub-game helper for the small-map 3D ladder (TEST-HARNESS).
# load()ed DYNAMICALLY — deliberately NO class_name (TEST-01 Blockers 10).
# Modelled on t_terrain3d.gd:41-46,106-127 and t_pick3d.gd:53-71,73-145.
# All values derived from existing code; see inline citations.
extends RefCounted

const TILE := 2.0              # game.gd:16 (== Data.TILE_M, data.gd:23)
const MINE_SITE_RADIUS := 4.0  # game.gd:19, used at :2689

# ---------------------------------------------------------------- stub game
class StubGame extends Node:
	var MAP_W: int = 0
	var MAP_H: int = 0
	var map_w: int = 0               # world3d_terrain.gd:424 fallback
	var map_h: int = 0               # world3d_terrain.gd:433 fallback
	var height := PackedFloat32Array()
	var tileblock := PackedByteArray()
	var terrain := PackedByteArray() # main.gd:738: one uint8 per cell
	var dump: Dictionary = {}
	var res_nodes: Array = []
	var res_dirty: int = 0           # t_pick3d.gd:59
	var entities: Array = []
	var cmd_calls: Dictionary = {}

	func _bump(m: String) -> int:
		cmd_calls[m] = int(cmd_calls.get(m, 0)) + 1   # t_pick3d.gd:61-62
		return 0

	func total_cmd_calls() -> int:
		var n := 0
		for v in cmd_calls.values(): n += int(v)
		return n                                       # t_pick3d.gd:67-71

	func pick_radius(_e: Dictionary) -> float:
		return 1.0                                     # t_pick3d.gd:64-65

	# n.type/n.pos (game.gd) or nd.get(...) (world3d_entities.gd:1297-1305).
	func _rn(n, key: String, def):
		if n is Dictionary: return (n as Dictionary).get(key, def)
		if n is Object: return (n as Object).get(key)
		return def

	# Vector2 arg = sim map-origin metres, the exact bilinear recipe of
	# game.gd:1893-1907 (called at world3d_entities.gd:1078 / camera3d.gd:292).
	# Two numbers = direct cell read height[z*MAP_W+x] (game.gd:453-454).
	func height_at(a, b = null) -> float:
		var n: int = MAP_W * MAP_H
		if n <= 0 or height.size() < n: return 0.0
		if not (a is Vector2):
			var x := clampi(int(a), 0, MAP_W - 1)
			var z := clampi(int(b) if b != null else 0, 0, MAP_H - 1)
			return height[z * MAP_W + x]
		var fx := clampf((a as Vector2).x / TILE - 0.5, 0.0, float(MAP_W - 1) - 0.001)
		var fz := clampf((a as Vector2).y / TILE - 0.5, 0.0, float(MAP_H - 1) - 0.001)
		var x0 := int(fx); var z0 := int(fz)
		var x1 := mini(x0 + 1, MAP_W - 1); var z1 := mini(z0 + 1, MAP_H - 1)
		var tx: float = fx - float(x0); var tz: float = fz - float(z0)
		var h00: float = height[z0 * MAP_W + x0]; var h10: float = height[z0 * MAP_W + x1]
		var h01: float = height[z1 * MAP_W + x0]; var h11: float = height[z1 * MAP_W + x1]
		return h00 + (h10 - h00) * tx + (h01 - h00) * tz + (h00 - h10 - h01 + h11) * tx * tz

	# game.gd:2685-2702: "mine" resolves to the closest in-range ore node.
	func resolve_mine_sid(sid: String, pos: Vector2) -> String:
		if sid != "mine": return sid
		var best_type := ""
		var best_d := MINE_SITE_RADIUS
		for n in res_nodes:
			if int(_rn(n, "max_hits", 0)) != 0: continue
			var t := str(_rn(n, "type", ""))
			if t != "gold" and t != "iron" and t != "coal": continue
			var p = _rn(n, "pos", Vector2.ZERO)
			if not (p is Vector2): continue
			var d: float = (p as Vector2).distance_to(pos)
			if d < best_d:
				best_d = d
				best_type = t
		return "mine_" + best_type if best_type != "" else "mine_gold"

	# All 24 cmd_* of game.gd, counted like t_pick3d.gd:73-145 (no side effects).
	func cmd_sow(a = null, b = null, c = null) -> int: return _bump("cmd_sow")
	func cmd_move(a = null, b = null, c = null) -> void: _bump("cmd_move")
	func cmd_attack(a = null, b = null, c = null) -> void: _bump("cmd_attack")
	func cmd_attack_move(a = null, b = null, c = null) -> void: _bump("cmd_attack_move")
	func cmd_gather(a = null, b = null, c = null) -> void: _bump("cmd_gather")
	func cmd_resow(a = null, b = null, c = null) -> void: _bump("cmd_resow")
	func cmd_build(a = null, b = null, c = null) -> void: _bump("cmd_build")
	func cmd_stand_ground(a = null, b = null, c = null) -> void: _bump("cmd_stand_ground")
	func cmd_no_stand_ground(a = null, b = null, c = null) -> void: _bump("cmd_no_stand_ground")
	func cmd_hold_fire(a = null, b = null, c = null) -> void: _bump("cmd_hold_fire")
	func cmd_engage(a = null, b = null, c = null) -> void: _bump("cmd_engage")
	func cmd_stop(a = null, b = null, c = null) -> void: _bump("cmd_stop")
	func cmd_guard(a = null, b = null, c = null) -> void: _bump("cmd_guard")
	func cmd_cancel_guard(a = null, b = null, c = null) -> void: _bump("cmd_cancel_guard")
	func cmd_patrol(a = null, b = null, c = null) -> void: _bump("cmd_patrol")
	func cmd_attack_ground(a = null, b = null, c = null) -> void: _bump("cmd_attack_ground")
	func cmd_enter(a = null, b = null, c = null) -> void: _bump("cmd_enter")
	func cmd_unload(a = null, b = null, c = null) -> void: _bump("cmd_unload")
	func cmd_replenish(a = null, b = null, c = null) -> int: return _bump("cmd_replenish")
	func cmd_form_size(a = null, b = null, c = null) -> void: _bump("cmd_form_size")
	func cmd_make_gate(a = null, b = null, c = null) -> void: _bump("cmd_make_gate")
	func cmd_gate_toggle(a = null, b = null, c = null) -> void: _bump("cmd_gate_toggle")
	func cmd_repair(a = null, b = null, c = null) -> void: _bump("cmd_repair")
	func cmd_delete(a = null, b = null, c = null) -> void: _bump("cmd_delete")

# ---------------------------------------------------------------- factories
static func make_height(w: int, h: int, fn: Callable = Callable()) -> PackedFloat32Array:
	var a := PackedFloat32Array(); a.resize(w * h)
	for z in range(h):
		for x in range(w): a[z * w + x] = float(fn.call(x, z)) if fn.is_valid() else 0.0
	return a

static func make_tileblock(w: int, h: int, id: int) -> PackedByteArray:
	var a := PackedByteArray(); a.resize(w * h); a.fill(id)
	return a

# Returns a Node so atoms can root.add_child() it like the proven stubs;
# dump mirrors main.gd:737-741 for world3d_terrain.gd:411-445.
static func make_stub_game(w: int, h: int, height: PackedFloat32Array, res_nodes: Array, tileblock: PackedByteArray) -> Object:
	var g := StubGame.new()
	g.MAP_W = w; g.MAP_H = h; g.map_w = w; g.map_h = h
	g.height = height; g.tileblock = tileblock; g.res_nodes = res_nodes
	g.terrain.resize(w * h)          # zeros: no water (terrain==3 is water)
	g.dump = {
		"map_w": w, "map_h": h,
		"height": Marshalls.raw_to_base64(height.to_byte_array()),
		"tileblock": Marshalls.raw_to_base64(tileblock),
	}
	return g

# Categories from world3d_entities.gd:1269-1278 (_resource_sid mapping).
static func count_categories(res_nodes: Array) -> Dictionary:
	var out := {"wood": 0, "stone": 0, "mine": 0, "food": 0}
	for n in res_nodes:
		# HARNESS-01: `as Object` on a Dictionary (the atoms' res_nodes shape)
		# is an invalid cast at runtime. Guard casts with `is`, as _rn does (:38-41).
		var t := ""
		if n is Dictionary:
			t = str((n as Dictionary).get("type", ""))
		elif n is Object:
			t = str((n as Object).get("type"))
		match t:
			"wood": out["wood"] = int(out["wood"]) + 1
			"stone": out["stone"] = int(out["stone"]) + 1
			"gold", "iron", "coal": out["mine"] = int(out["mine"]) + 1
			"food": out["food"] = int(out["food"]) + 1
	return out

# Result JSON shape of _template_test.gd:6,17-31. `path` = res:// results dir.
static func write_result(path: String, id: String, checks: Array, passed: bool) -> void:
	var abs_dir := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open("%s/%s.json" % [abs_dir, id], FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path + "/" + id + ".json")
		return
	f.store_string(JSON.stringify({"id": id, "passed": passed, "checks": checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0}, "\t"))
	f.close()
