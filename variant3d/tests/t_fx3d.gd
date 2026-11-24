# V7-35 atomic test — res://scripts/world3d_fx.gd API surface + FX lifetime.
# Owner: V7-35. Owns exactly this file (+ its report). TABS per contract.
# Contract: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:14,26-30,37
#   world3d_fx.gd (extends Node3D) MUST expose bind(game), sync(dt),
#   add_fx(pos, kind, life), draw_ghost(sid, pos, ok), draw_rally(pos, player).
#   FX lifetime expiry removes nodes; event stream sim-agnostic; NO 2D sheets.
# If the module is absent or cannot be instantiated, this FAILs loudly with
# MODULE_MISSING and BLOCKED-PENDING-MODULE; no assertion is weakened.
# Run via: python variant3d\tools\godot_runner.py run --id v735-fx3d \
#   --timeout 60 -- --headless --path variant3d --script res://tests/t_fx3d.gd
extends SceneTree

const MODULE_PATH := "res://scripts/world3d_fx.gd"

# Fixed, deterministic FX lifecycle: life 0.10 s, first sync 0.01 s (let a
# lazy renderer build its node), then 6 x 0.05 s = 0.31 s total > life.
const FX_LIFE := 0.10
const FX_POS := Vector2(12.0, 34.0)
const GHOST_SID := "peasant"
const GHOST_POS := Vector2(40.0, 12.0)
const RALLY_POS := Vector2(60.0, 18.0)
const RALLY_PLAYER := 0

# Dead-weight 2D bake pipeline (WAVE7_3D_VARIANT_CHARTER.md:40-52). These are
# usage tokens, not comments, so a "no Sprite2D here" comment cannot trip them.
const FORBIDDEN_2D_TOKENS := [
	"res://assets/models/anim/",
	"res://assets/sprites/",
	"res://assets/sprites_hi/",
	"Sprite2D.new(",
	"AnimatedSprite2D.new(",
	"SpriteFrames.new(",
	": Sprite2D",
	": AnimatedSprite2D",
	"_nation_sheet(",
]

var _pass := 0
var _fail := 0
var _api_errors: Array[String] = []


class MockGame extends Node:
	# Minimal sim-agnostic stub: the FX host binds a game reference but the FX
	# event stream must not depend on sim internals (contract :14).
	# `projectiles` is intentionally absent: _emit_arrow_trails() must guard it.
	var events: Array = []
	var players: Array = []
	var units: Array = []
	var buildings: Array = []
	var fog_explored: Array = []
	var fog_vis: Array = []


func _report(name: String, ok: bool, detail: String = "") -> void:
	if ok:
		_pass += 1
		print("PASS ", name, " - ", detail)
	else:
		_fail += 1
		print("FAIL ", name, " - ", detail)


func _finish() -> void:
	print("T_FX3D %s %d/%d checks" % ["PASS" if _fail == 0 else "FAIL", _pass, _pass + _fail])
	call_deferred("quit", 0 if _fail == 0 else 1)


func _module_missing(why: String) -> void:
	_report("MODULE_MISSING", false, MODULE_PATH + " (" + why + ")")
	print("STATUS BLOCKED-PENDING-MODULE — world3d_fx.gd is missing/unusable; assertions NOT weakened")
	_finish()


# All dynamic calls go through here so a missing method is recorded as an API
# error rather than as a silent no-op. GDScript has no exception hook, so this
# flag plus the runner's stderr is the honest "no errors" signal.
func _call_api(obj: Object, method: String, args: Array) -> Variant:
	if obj == null or not obj.has_method(method):
		_api_errors.append("missing method: " + method)
		return null
	return obj.callv(method, args)


func _count_nodes(n: Node) -> int:
	var total := 0
	for c in n.get_children():
		total += 1 + _count_nodes(c)
	return total


# Any 2D CanvasItem node under the FX host is a contract violation: the 3D FX
# layer must be made of Node3D/MeshInstance3D, never sprite-sheet sprites.
func _find_2d_nodes(n: Node) -> Array[String]:
	var found: Array[String] = []
	for c in n.get_children():
		var cls := c.get_class()
		if cls == "Sprite2D" or cls == "AnimatedSprite2D" or cls == "Node2D":
			found.append(cls)
		found.append_array(_find_2d_nodes(c))
	return found


# Static scan of the module source for dead-weight 2D bake-pipeline usage.
# Comment lines are skipped so a doc comment cannot produce a false positive.
func _source_2d_hits() -> Array[String]:
	var hits: Array[String] = []
	var f := FileAccess.open(MODULE_PATH, FileAccess.READ)
	if f == null:
		hits.append("SOURCE_UNREADABLE")
		return hits
	var text := f.get_as_text()
	f.close()
	for raw in text.split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("#"):
			continue
		for tok in FORBIDDEN_2D_TOKENS:
			if line.contains(tok) and not hits.has(tok):
				hits.append(tok)
	return hits


func _initialize() -> void:
	print("T_FX3D start ", MODULE_PATH)
	# Harness probe only: exercises the MODULE_MISSING / BLOCKED branch without
	# touching the module file (owned by the V7-15 module agent).
	if OS.has_environment("T_FX3D_SIMULATE_MISSING"):
		_module_missing("simulated via T_FX3D_SIMULATE_MISSING=1")
		return
	if not (ResourceLoader.exists(MODULE_PATH) or FileAccess.file_exists(MODULE_PATH)):
		_module_missing("ResourceLoader.exists()/FileAccess.file_exists() == false")
		return
	var script: Script = load(MODULE_PATH) as Script
	if script == null:
		_module_missing("load() returned null")
		return
	# A script with parse errors still loads as a non-null GDScript resource but
	# cannot be instantiated. Treat that as MODULE_MISSING/BLOCKED instead of
	# calling new() on it (which errors and can strand the SceneTree main loop).
	if not script.can_instantiate():
		_module_missing("load() returned an invalid/uninstantiable script (parse errors)")
		return

	_report("MODULE_LOADS", true, "dynamic load() -> " + script.get_class())

	var inst: Object = script.new()
	if inst == null or not (inst is Node3D):
		var cls := "null" if inst == null else inst.get_class()
		_report("MODULE_IS_NODE3D", false, "instance class=" + cls)
		_report("NO_ERRORS", false, "instantiation failed: " + cls)
		_finish()
		return
	_report("MODULE_IS_NODE3D", true, "instance class=" + inst.get_class())

	var tree_root := get_root()
	if tree_root != null:
		tree_root.add_child(inst)
	var fx := inst as Node3D
	var game := MockGame.new()
	if tree_root != null:
		tree_root.add_child(game)

	# --- Declared API surface (contract :14) --------------------------------
	var required := ["bind", "sync", "add_fx", "draw_ghost", "draw_rally"]
	var missing: Array[String] = []
	for m in required:
		if not fx.has_method(m):
			missing.append(m)
		_report("CALLABLE_" + m.to_upper(), fx.has_method(m),
			"has_method(\"" + m + "\")=" + str(fx.has_method(m)))
	_report("API_SURFACE", missing.is_empty(),
		"missing=" + str(missing) if not missing.is_empty() else "all 5 contract methods present")
	if not missing.is_empty():
		_report("NO_ERRORS", false, "missing methods: " + str(missing))
		_finish()
		return

	_call_api(fx, "bind", [game])

	# --- FX lifetime expiry removes the FX node -----------------------------
	var base := _count_nodes(fx)
	_call_api(fx, "add_fx", [FX_POS, "smoke", FX_LIFE])
	_call_api(fx, "sync", [0.01])  # let a lazy renderer materialise the node
	var after_add := _count_nodes(fx)
	_report("FX_ADDS_NODES", after_add > base,
		"descendant nodes %d -> %d (pos=%s kind=smoke life=%.2f)" % [
		base, after_add, str(FX_POS), FX_LIFE])

	# Capture the actual FX holder node so removal can be asserted directly.
	# world3d_fx.gd removes expired items with queue_free(); Godot exposes that
	# state via is_queued_for_deletion(), which is deterministic in a headless
	# --script SceneTree (the physical memdelete waits for a frame flush that
	# this harness does not provide). Both the logical list and the node must
	# be cleared/clearing for this check to pass.
	var items0: Array = fx.get("fx_items") as Array
	var holder: Node = null
	if not items0.is_empty() and items0[0] is Dictionary:
		holder = (items0[0] as Dictionary).get("node") as Node
	var stats0: Dictionary = fx.get("stats") as Dictionary
	var expired_before := int(stats0.get("expired", 0))

	for _k in range(6):
		_call_api(fx, "sync", [0.05])
	var elapsed := 0.01 + 6.0 * 0.05
	var items1: Array = fx.get("fx_items") as Array
	var stats1: Dictionary = fx.get("stats") as Dictionary
	var expired_after := int(stats1.get("expired", 0))
	var holder_removed := holder == null or not is_instance_valid(holder) or holder.is_queued_for_deletion()
	var logical_expired := items1.is_empty() and expired_after > expired_before
	_report("FX_LIFETIME_EXPIRY_REMOVES_NODES",
		after_add > base and holder != null and holder_removed and logical_expired,
		"fx_items=%d expired %d->%d holder_queued_or_freed=%s nodes %d->%d->%d (life=%.2f elapsed=%.2f)" % [
		items1.size(), expired_before, expired_after, str(holder_removed),
		base, after_add, _count_nodes(fx), FX_LIFE, elapsed])

	# --- Ghost + rally are callable and stay 3D -----------------------------
	_call_api(fx, "draw_ghost", [GHOST_SID, GHOST_POS, true])
	_call_api(fx, "draw_rally", [RALLY_POS, RALLY_PLAYER])
	_report("GHOST_RALLY_CALLS", true,
		"draw_ghost(%s, %s, true); draw_rally(%s, %d)" % [
		GHOST_SID, str(GHOST_POS), str(RALLY_POS), RALLY_PLAYER])

	# --- No 2D sprite-sheet loads (static source + runtime node tree) -------
	var src_hits := _source_2d_hits()
	var runtime_hits := _find_2d_nodes(fx)
	var hits := src_hits
	hits.append_array(runtime_hits)
	_report("NO_2D_SPRITE_SHEET_LOADS", hits.is_empty(),
		"hits=" + str(hits) if not hits.is_empty() else "no sheet paths / 2D nodes in module or FX tree")

	# --- No errors signalled by the exercised APIs --------------------------
	_report("NO_ERRORS", _api_errors.is_empty(),
		"api_errors=" + str(_api_errors) if not _api_errors.is_empty() else "all dynamic calls returned without signal")

	_finish()
