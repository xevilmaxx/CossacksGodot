extends SceneTree

# W5-3: LIGHT headless probe for the P2 #3 post-bake chunk-scheduling gate.
# Deliberately does NOT call C3Game.setup() or the heavy C3World.bind() body
# (block warm-up / sprite load / viewport bake): t_forest_bake hangs in this
# environment even on untouched baseline, so that path is never touched here.
# Instead a ProbeWorld subclass overrides only the bake helpers with counters and
# a StubGame subclass overrides tile_of(). The real _sync_terrain_chunks() and
# _sync_forest_chunks() from res://scripts/world.gd do all the scheduling work.
#
# Run:
#   python app\tools\godot_runner.py run --id w53-light --timeout 60 -- \
#       --headless --path app --script res://tests/t_chunk_schedule_light.gd

class StubGame extends C3Game:
	var tile_calls := 0

	func tile_of(p: Vector2) -> Vector2i:
		tile_calls += 1
		return Vector2i(int(p.x / TILE), int(p.y / TILE))


class ProbeWorld extends C3World:
	var low_calls := 0
	var full_calls := 0
	var key_calls := 0
	var sprite_calls := 0
	var build_order: Array = []

	# Minimal bind: only the fields the scheduler reads. No asset/block warm-up.
	func bind(g: C3Game, h: CanvasLayer = null) -> void:
		game = g
		view_scale = 16.0

	func _chunk_key(cx: int, cy: int) -> Vector2i:
		key_calls += 1
		return Vector2i(cx, cy)

	func _build_chunk(cx: int, cy: int) -> Sprite2D:
		full_calls += 1
		build_order.append(Vector2i(cx, cy))
		return Sprite2D.new()

	func _build_chunk_low(cx: int, cy: int) -> Sprite2D:
		low_calls += 1
		return Sprite2D.new()

	func _make_chunk_sprite(cx: int, cy: int, tex: Texture2D, z: int, scale: float) -> Sprite2D:
		sprite_calls += 1
		return Sprite2D.new()

	func _fallback_texture() -> ImageTexture:
		return null


var _finished := false
var _ok := true
var _passes := 0
var _totals := 0

func check(name: String, cond: bool, detail: String = "") -> void:
	_totals += 1
	if cond:
		_passes += 1
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _failsafe() -> void:
	if _finished:
		return
	check("test_completed", false, "aborted before completion")
	call_deferred("quit", 1)

func _initialize() -> void:
	call_deferred("_failsafe")
	var t0 := Time.get_ticks_usec()
	var stub := StubGame.new()
	stub.MAP_W = 320
	stub.MAP_H = 320
	var world := ProbeWorld.new()
	root.add_child(world)
	world.bind(stub)
	# 32 canvas px / view_scale 16 = 2 m; TILE=2 => tile (1,1); CHUNK_T=32
	# => in-view range is the single chunk (0,0). Whole map is 10x10=100 chunks.
	world.view_rect = Rect2(0.0, 0.0, 32.0, 32.0)
	var ncx: int = int(ceil(float(stub.MAP_W) / float(world.CHUNK_T)))
	var ncy: int = int(ceil(float(stub.MAP_H) / float(world.CHUNK_T)))
	var total: int = ncx * ncy

	# --- steady state: every map chunk resident, one stale full_chunks key ---
	for cy in ncy:
		for cx in ncx:
			world.terrain_chunks[Vector2i(cx, cy)] = RefCounted.new()
	var stale := Vector2i(77, 77)
	world.full_chunks[Vector2i(0, 0)] = true
	world.full_chunks[stale] = true
	# sync() normally sets this before both syncs; a direct caller leaves -1.
	world.set("view_chunk_range", Vector4i(0, 0, 0, 0))
	world.key_calls = 0
	world.low_calls = 0
	world.full_calls = 0
	stub.tile_calls = 0
	world._sync_terrain_chunks()
	var key_delta: int = world.key_calls
	check("lod_complete_gate", world.get("lod_complete") == true,
		"lod_complete=%s, resident=%d/%d" % [str(world.get("lod_complete")), world.terrain_chunks.size(), total])
	check("shared_view_range", stub.tile_calls == 0,
		"tile_of calls with preset range=%d (expected 0)" % stub.tile_calls)
	check("no_fullmap_key_scan", key_delta == 1,
		"chunk-key derivations=%d, expected in-view=1, unpatched full-map=%d" % [key_delta, total + 1])
	check("stale_full_key_kept", world.full_chunks.has(stale),
		"stale key retained when gate is closed")
	check("no_steady_state_build", world.low_calls == 0 and world.full_calls == 0 and world.sprite_calls == 0,
		"low=%d full=%d fallback_sprite=%d" % [world.low_calls, world.full_calls, world.sprite_calls])

	# --- forest sync reuses the same shared range (no bake render) ---
	world.forest_layer = Node2D.new()
	world.add_child(world.forest_layer)
	world.forest_chunks[Vector2i(0, 0)] = true
	world._forest_bake_key = world._forest_bake_signature()
	stub.tile_calls = 0
	world._sync_forest_chunks()
	check("forest_shared_view_range", stub.tile_calls == 0,
		"tile_of calls from forest sync=%d (expected 0)" % stub.tile_calls)

	# --- quality change clears terrain_chunks: gate must self-reset ---
	world.terrain_chunks.clear()
	world.key_calls = 0
	world.low_calls = 0
	world.full_calls = 0
	stub.tile_calls = 0
	world._sync_terrain_chunks()
	check("gate_self_resets", world.get("lod_complete") == false and world.low_calls > 0,
		"lod_complete=%s, low builds after clear=%d" % [str(world.get("lod_complete")), world.low_calls])
	check("stale_key_reconciled", not world.full_chunks.has(stale),
		"stale key removed after quality clear")

	# --- bake order / 2-per-frame cap untouched ---
	world.terrain_chunks.clear()
	world.full_chunks.clear()
	world.build_order.clear()
	world.set("view_chunk_range", Vector4i(0, 0, 2, 2))
	world._sync_terrain_chunks()
	var order: Array = world.build_order
	var centre_ok: bool = order.size() >= 1 and order[0] == Vector2i(1, 1)
	var d_ok: bool = order.size() >= 2 and absi(order[1].x - 1) + absi(order[1].y - 1) == 1
	check("bake_cap_and_order", order.size() == 2 and centre_ok and d_ok,
		"order=%s (cap=2, centre first)" % str(order))

	var elapsed_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	print("CHUNK_SCHEDULE_LIGHT %d/%d checks, %.1f ms" % [
		int(_checks_passed()), int(_checks_total()), elapsed_ms])
	_finished = true
	quit(0 if _ok else 1)

func _checks_passed() -> int:
	return _passes

func _checks_total() -> int:
	return _totals
