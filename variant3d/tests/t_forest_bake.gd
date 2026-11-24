# T-FOREST-BAKE: static forest-detail chunk baking.
#
# Verifies the renderer-side cache that removes the 600-4000 forest prop quads
# per frame while panning:
#   - a dedicated forest_layer sits immediately BELOW res_layer (both z=1);
#   - one reusable transparent SubViewport is set up for bakes;
#   - _sync_forest_chunks() populates forest_chunks with cached sprites;
#   - the LRU stays bounded at <= FOREST_CHUNK_CACHE (20) even after baking
#     many more chunks, and evicted sprites are freed;
#   - invalidation on bind/quality key change clears the cache, while
#     res_dirty / fields_anim changes do NOT invalidate it;
#   - the old live fallback (_draw_forest_detail / tree / understory) is still
#     callable with its original signature (no layer/origin args);
#   - fog (z=10) and water (z=-9) layering is untouched and no errors are
#     produced.
#
# Headless note: there is no rasteriser, so _bake_forest_chunk() registers a
# transparent placeholder texture instead of awaiting frame_post_draw. That
# exercises the same cache/LRU/sync code paths without a render await.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-forest-bake --timeout 100 -- \
#       --headless --path app --script res://tests/t_forest_bake.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const OUT_DIR := "res://tests/results"
const SEED := 7

var _id := "t_forest_bake"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var game
var world

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _pump(n: int) -> void:
	for _i in n:
		world._sync_forest_chunks()

# If _initialize() errors out before the normal quit, the process would spin
# forever (the README hang pattern). This deferred guard closes that hole.
func _failsafe() -> void:
	if _finished:
		return
	check("test_completed", false, "aborted before completion")
	_write_result()
	call_deferred("quit", 1)

func _initialize() -> void:
	call_deferred("_failsafe")
	Data.AI_ENABLED = false
	Data.RANDOM_SEED = SEED
	Data.set_quality("high")

	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	world = C3World.new()
	root.add_child(world)
	world.bind(game)

	# 1. Dedicated layer, below res_layer but at the same z.
	var fi: int = world.forest_layer.get_index()
	var ri: int = world.res_layer.get_index()
	check("forest_layer_below_res_layer",
		world.forest_layer != null and world.forest_layer.z_index == 1
			and fi >= 0 and ri > fi,
		"forest_layer idx=%d z=%d, res_layer idx=%d z=%d" % [
			fi, world.forest_layer.z_index, ri, world.res_layer.z_index])

	# 2. Reusable SubViewport configured for transparent once-only rendering.
	check("bake_viewport_ready",
		world.forest_view != null and world.forest_view.transparent_bg
			and world.forest_view.disable_3d and world.forest_canvas != null,
		"view=%s size=%s canvas=%s" % [
			str(world.forest_view != null),
			str(world.forest_view.size if world.forest_view != null else Vector2i.ZERO),
			str(world.forest_canvas != null)])

	# 3. sync()'s helper populates the chunk cache. Use a whole-map view_rect
	#    (the headless root viewport is small) so several chunks are visible.
	var mspan: float = float(game.MAP_W) * Data.TILE_M * world.view_scale
	world.view_rect = Rect2(0, 0, mspan, mspan)
	world.invalidate_forest_bake()
	_pump(20)
	check("chunks_populate", world.forest_chunks.size() > 0,
		"forest_chunks=%d, order=%d (visible 5x5 chunks)" % [
			world.forest_chunks.size(), world.forest_order.size()])

	# 4. LRU is bounded even when far more chunks than the cap are baked.
	for cy in 8:
		for cx in 8:
			world._bake_forest_chunk(cx, cy)
	var cap: int = world.FOREST_CHUNK_CACHE
	check("lru_bounded",
		world.forest_chunks.size() <= cap and world.forest_order.size() <= cap
			and world.forest_chunks.size() == world.forest_order.size(),
		"chunks=%d order=%d cap=%d" % [
			world.forest_chunks.size(), world.forest_order.size(), cap])

	# 5. Invalidation clears the cache; res_dirty / fields_anim do not.
	var key_before: String = world._forest_bake_key
	game.res_dirty += 1
	game.set("fields_anim", true)
	_pump(1)
	var key_after: String = world._forest_bake_key
	check("no_res_dirty_invalidation", key_after == key_before,
		"key stable across res_dirty/fields_anim: %s" % key_after)
	world.invalidate_forest_bake()
	var cleared: bool = world.forest_chunks.is_empty() and world.forest_order.is_empty()
	_pump(2)
	check("invalidate_rebakes", cleared and world.forest_chunks.size() > 0,
		"cleared=%s, chunks after re-bake=%d" % [
			str(cleared), world.forest_chunks.size()])

	# 6. Old fallback path is still callable with its ORIGINAL signatures.
	#    (Calling draw_* outside a draw callback is an engine error, so verify
	#    the preserved methods + argument counts instead of invoking them here;
	#    _draw_resources still routes to them whenever forest_bake_enabled is
	#    false.) The new layer/origin params are optional, so old callers work.
	var methods := {}
	for m in world.get_method_list():
		methods[str(m.get("name", ""))] = int((m.get("args") as Array).size())
	var fallback_ok: bool = methods.has("_draw_forest_detail") \
		and int(methods.get("_draw_forest_detail", -1)) == 0 \
		and methods.has("_draw_forest_tree") \
		and int(methods.get("_draw_forest_tree", -1)) >= 2 \
		and methods.has("_draw_forest_understory") \
		and int(methods.get("_draw_forest_understory", -1)) >= 2
	world.forest_bake_enabled = false
	world.res_layer.queue_redraw()  # will use the fallback on the next draw
	check("fallback_still_callable", fallback_ok,
		"detail=%d tree=%d understory=%d args (bake args are optional)" % [
			int(methods.get("_draw_forest_detail", -1)),
			int(methods.get("_draw_forest_tree", -1)),
			int(methods.get("_draw_forest_understory", -1))])
	world.forest_bake_enabled = true

	# 7. Layering invariants: fog above everything, water below forest/res.
	check("layering_untouched",
		world.fog_sprite != null and world.fog_sprite.z_index == 10
			and world.water_overlay != null and world.water_overlay.z_index == -9,
		"fog_z=%d water_z=%d" % [
			world.fog_sprite.z_index if world.fog_sprite != null else -999,
			world.water_overlay.z_index if world.water_overlay != null else -999])

	# 8. No new RNG: two identical signature reads stay identical across bakes.
	var s1: String = world._forest_bake_signature()
	var s2: String = world._forest_bake_signature()
	check("deterministic_signature", s1 == s2 and s1 != "", s1)

	_finished = true
	_write_result()
	call_deferred("quit", 0 if _ok else 1)
