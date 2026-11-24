extends SceneTree

# V7-36 - deterministic atomic test for res://scripts/world3d_fog.gd.
#
# Contract source: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:15
#   world3d_fog.gd (extends Node3D): bind(game), sync(dt), per-tile fog shading
#   from game.fog_explored / game.fog_vis; expose fog_explored, fog_vis arrays
#   so the HUD minimap can read them.
#
# This test binds a SMALL stub game (4x3 = 12 fog tiles) so it stays fast and
# deterministic: no mapgen, no sim, no GPU frame. It checks the module loads,
# exposes both fog arrays at the expected size, has a callable sync(), and does
# NOT fall back to a full-map Sprite2D (structural check on both the live node
# tree and the module source).
#
# If the module is absent, the only failing check is MODULE_MISSING and the
# result is BLOCKED (the test cannot judge an owner's file that is not there).
#
# Run via the variant runner (never bare godot):
#   python variant3d\tools\godot_runner.py run --id v7-36-t-fog3d --timeout 90 -- \
#       --headless --path variant3d --script res://tests/t_fog3d.gd

const MODULE_PATH := "res://scripts/world3d_fog.gd"
const OUT_DIR := "res://tests/results"
const TEST_ID := "t_fog3d"
const MAP_W := 4
const MAP_H := 3
const N_TILES := MAP_W * MAP_H

var _checks: Array[Dictionary] = []
var _ok := true
var _blocked := false
var _start_ms := 0

# Minimal stand-in for the game: ONLY the fields the fog contract names.
# Literal 4/3 here on purpose - inner classes do not see outer constants.
class StubGame extends RefCounted:
	var MAP_W: int = 4
	var MAP_H: int = 3
	var fog_explored: PackedByteArray = PackedByteArray()
	var fog_vis: PackedByteArray = PackedByteArray()

	func _init() -> void:
		fog_explored.resize(MAP_W * MAP_H)
		fog_vis.resize(MAP_W * MAP_H)
		for i in range(MAP_W * MAP_H):
			fog_explored[i] = 1 if i % 2 == 0 else 0
			fog_vis[i] = 1 if i < 5 else 0


func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false


# Accept the packed forms a fog module would plausibly expose plus a plain Array.
func _array_size(v: Variant) -> int:
	if v is PackedByteArray:
		return (v as PackedByteArray).size()
	if v is PackedInt32Array:
		return (v as PackedInt32Array).size()
	if v is PackedFloat32Array:
		return (v as PackedFloat32Array).size()
	if v is Array:
		return (v as Array).size()
	return -1


func _array_first(v: Variant) -> int:
	if v is PackedByteArray and not (v as PackedByteArray).is_empty():
		return int((v as PackedByteArray)[0])
	if v is Array and not (v as Array).is_empty():
		return int((v as Array)[0])
	return -1


# Recursive structural check: any Sprite2D anywhere under the fog module means
# the 3D fog path has fallen back to a 2D overlay.
func _sprite2d_count(node: Node) -> int:
	var n := 0
	if node is Sprite2D:
		n += 1
	for c in node.get_children():
		n += _sprite2d_count(c)
	return n


# Source-level half of the structural check: catch an allocation that has not
# been attached to the tree yet (e.g. built lazily on the first sync()).
func _source_allocates_sprite2d() -> bool:
	var f := FileAccess.open(MODULE_PATH, FileAccess.READ)
	if f == null:
		return false
	var txt: String = f.get_as_text()
	f.close()
	return txt.find("Sprite2D.new(") >= 0


func _write_result() -> void:
	var status := "BLOCKED" if _blocked else ("PASS" if _ok else "FAIL")
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, TEST_ID]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": TEST_ID,
		"agent": "V7-36",
		"status": status,
		"passed": _ok and not _blocked,
		"blocked": _blocked,
		"checks": _checks,
		"elapsed_s": float(Time.get_ticks_msec() - _start_ms) / 1000.0,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()


func _finish() -> void:
	_write_result()
	# Never call quit() directly from _initialize(): it hangs in Godot 4.7.
	call_deferred("quit", 0 if (_ok and not _blocked) else 1)


func _initialize() -> void:
	_start_ms = Time.get_ticks_msec()
	print("V736 FOG3D START module=", MODULE_PATH)

	# 1. Module must exist and parse. Missing module -> the ONLY verdict is a
	#    MODULE_MISSING failure plus BLOCKED; no other check can be judged.
	if not ResourceLoader.exists(MODULE_PATH):
		_blocked = true
		check("MODULE_MISSING", false, MODULE_PATH + " absent - BLOCKED on module owner")
		print("V736 FOG3D BLOCKED: module missing")
		_finish()
		return
	var script_res: Resource = load(MODULE_PATH)
	if script_res == null or not (script_res is GDScript):
		_blocked = true
		check("MODULE_MISSING", false, "load() -> %s - BLOCKED on module owner" % str(script_res))
		print("V736 FOG3D BLOCKED: module did not load")
		_finish()
		return
	check("module_loads", true, "GDScript loaded from " + MODULE_PATH)

	# 2. Instantiate and bind the small stub game.
	var inst = (script_res as GDScript).new()
	check("instance_created", inst is Node, "new() -> " + str(inst))
	if not (inst is Node):
		_finish()
		return
	root.add_child(inst)
	var has_bind: bool = inst.has_method("bind")
	check("bind_api", has_bind, "has_method('bind')=" + str(has_bind))
	if has_bind:
		inst.call("bind", StubGame.new())
		print("V736 FOG3D bound stub game ", N_TILES, " tiles")

	# 3. sync(dt) must exist as a method AND be callable with the stub bound.
	var has_sync: bool = inst.has_method("sync")
	check("sync_api", has_sync, "has_method('sync')=" + str(has_sync))
	if has_sync:
		inst.call("sync", 0.016)
		check("sync_callable", true, "sync(0.016) returned without aborting the test")

	# 4. Both fog arrays must be exposed at the stub's full tile count.
	var exp: Variant = inst.get("fog_explored")
	var vis: Variant = inst.get("fog_vis")
	var exp_n := _array_size(exp)
	var vis_n := _array_size(vis)
	check("fog_explored_exposed", exp_n == N_TILES,
		"size=%d want=%d first=%d" % [exp_n, N_TILES, _array_first(exp)])
	check("fog_vis_exposed", vis_n == N_TILES,
		"size=%d want=%d first=%d" % [vis_n, N_TILES, _array_first(vis)])

	# 5. Structural: 3D fog must not become a full-map Sprite2D overlay.
	var sprite_nodes := _sprite2d_count(inst)
	var sprite_alloc := _source_allocates_sprite2d()
	check("no_fullmap_sprite2d", sprite_nodes == 0 and not sprite_alloc,
		"sprite2d_nodes=%d source_Sprite2D.new=%s" % [sprite_nodes, str(sprite_alloc)])

	# 6. Sanity: no probe may hang (runner hard timeout is 90 s).
	var elapsed_s := float(Time.get_ticks_msec() - _start_ms) / 1000.0
	check("no_new_hangs", elapsed_s < 60.0,
		"all checks completed in %.2fs (runner hard timeout 90s)" % elapsed_s)

	print("V736 FOG3D END status=", ("BLOCKED" if _blocked else ("PASS" if _ok else "FAIL")))
	_finish()
