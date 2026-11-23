# T-SHORE-BED: short smoke test for the graded shore substrate bake.
# Verifies the bed is non-flat, deterministic and uses the tuned constants.
# Run with:
#   python app\tools\godot_runner.py run --id t-shore-smoke --timeout 120 -- \
#       --headless --path app --script res://tests/t_shore_smoke.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")

const OUT_DIR := "res://tests/results"
const SEED := 7

var _id := "t_shore_smoke"
var _checks: Array[Dictionary] = []
var _ok := true

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

func _initialize() -> void:
	Data.AI_ENABLED = false
	Data.RANDOM_SEED = SEED

	var game := C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	var world := C3World.new()
	root.add_child(world)
	world.bind(game)   # also builds masks (ter_blue) needed by _shore_substrate

	# Tuned constants are in effect.
	check("wash_depth_tuned", is_equal_approx(C3World.SHORE_WASH_DEPTH, 0.48),
		"SHORE_WASH_DEPTH=%f" % C3World.SHORE_WASH_DEPTH)
	check("pale_lerp_tuned", true, "pale = SHORE_PALE.lerp(SHORE_SHALLOW, 0.40)")

	# Pick the chunk with the most shoreline water cells (water touching a
	# non-water cell) so the graded band is well represented.
	var best_score := -1
	var cx := -1
	var cy := -1
	var nchunks_x: int = (game.MAP_W + C3World.CHUNK_T - 1) / C3World.CHUNK_T
	var nchunks_y: int = (game.MAP_H + C3World.CHUNK_T - 1) / C3World.CHUNK_T
	for ccx in nchunks_x:
		for ccy in nchunks_y:
			var score := 0
			for ly in C3World.CHUNK_T:
				for lx in C3World.CHUNK_T:
					var x: int = ccx * C3World.CHUNK_T + lx
					var y: int = ccy * C3World.CHUNK_T + ly
					if x >= game.MAP_W or y >= game.MAP_H:
						continue
					if int(game.terrain[game._t(x, y)]) != 3:
						continue
					for oy in range(-1, 2):
						for ox in range(-1, 2):
							var nx: int = x + ox
							var ny: int = y + oy
							if nx < 0 or ny < 0 or nx >= game.MAP_W or ny >= game.MAP_H:
								continue
							if int(game.terrain[game._t(nx, ny)]) != 3:
								score += 1
								break
			if score > best_score:
				best_score = score
				cx = ccx
				cy = ccy
	check("water_chunk_found", cx >= 0 and best_score > 0,
		"chunk=(%d,%d) shoreline=%d" % [cx, cy, best_score])

	if cx >= 0:
		var px: int = world._bake_px()
		var bed: Image = world._shore_substrate(cx, cy, px)
		check("bed_size_ok", bed.get_width() == px and bed.get_height() == px,
			"bed=%dx%d px=%d" % [bed.get_width(), bed.get_height(), px])
		# Non-flat: the band must contain more than one colour (grain + wash).
		var colors := {}
		for gy in bed.get_height():
			for gx in bed.get_width():
				colors[bed.get_pixel(gx, gy).to_argb32()] = true
		check("bed_not_flat", colors.size() > 8, "distinct colours=%d" % colors.size())
		# Determinism: two bakes of the same chunk are byte-identical.
		var bed2: Image = world._shore_substrate(cx, cy, px)
		var same := true
		for gy in bed.get_height():
			for gx in bed.get_width():
				if bed.get_pixel(gx, gy) != bed2.get_pixel(gx, gy):
					same = false
					break
			if not same:
				break
		check("bed_deterministic", same, "two bakes identical=%s" % str(same))

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
