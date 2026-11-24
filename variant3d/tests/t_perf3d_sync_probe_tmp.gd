# TEMPORARY AUDIT PROBE (PERF-3D) — delete after measurement.
# Times every sub-stage of world3d.sync() with a live C3Game and real skinned units.
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3Config = preload("res://scripts/config.gd")

const FRAMES := 120
const WARMUP := 40
const SKINS := ["peasant", "pikeman", "archer", "cossack", "musketeer", "grenadier"]

var world = null
var game = null
var cam = null
var rows: Array = []

func _us() -> int:
	return Time.get_ticks_usec()

func _ms(us: int) -> float:
	return float(us) / 1000.0

func _spawn_units(n: int, start_id: int) -> void:
	var side := ceili(sqrt(float(n)))
	for i in n:
		var sid: String = SKINS[(start_id + i) % SKINS.size()]
		var e = game.spawn(sid, (start_id + i) % 2,
			Vector2(40.0 + float((start_id + i) % side) * 2.2,
				40.0 + float((start_id + i) / side) * 2.2))
		if i % 3 == 0:
			e["moving"] = true

func _measure(label: String, n_units: int) -> void:
	var dt := 1.0 / Data.FPS
	for _i in WARMUP:
		world.sync(dt)
	var acc := {
		"view": 0, "selection": 0, "ghost": 0, "rally": 0,
		"reconcile": 0, "entities": 0, "fx": 0, "fog": 0,
		"fogrev": 0, "total": 0,
	}
	var t0 := 0
	for _f in FRAMES:
		t0 = _us()
		world._update_view_rect()
		acc.view += _us() - t0
		t0 = _us()
		world._sync_selection()
		acc.selection += _us() - t0
		t0 = _us()
		world._sync_build_ghost()
		acc.ghost += _us() - t0
		t0 = _us()
		world._sync_rally()
		acc.rally += _us() - t0
		t0 = _us()
		world._reconcile_entities()
		acc.reconcile += _us() - t0
		t0 = _us()
		world.entities.sync(dt)
		acc.entities += _us() - t0
		t0 = _us()
		world.fx.sync(dt)
		acc.fx += _us() - t0
		t0 = _us()
		world.fog.sync(dt)
		acc.fog += _us() - t0
		t0 = _us()
		if world.fog_vis != world._fog_rev_vis:
			world._fog_rev_vis = world.fog_vis.duplicate()
		acc.fogrev += _us() - t0
		t0 = _us()
		world.sync(dt)
		acc.total += _us() - t0

	var f := float(FRAMES)
	var row := {
		"label": label,
		"units": n_units,
		"res_nodes": (game.res_nodes as Array).size(),
		"frames": FRAMES,
		"view_ms": _ms(int(acc.view)) / f,
		"selection_ms": _ms(int(acc.selection)) / f,
		"ghost_ms": _ms(int(acc.ghost)) / f,
		"rally_ms": _ms(int(acc.rally)) / f,
		"reconcile_ms": _ms(int(acc.reconcile)) / f,
		"entities_ms": _ms(int(acc.entities)) / f,
		"fx_ms": _ms(int(acc.fx)) / f,
		"fog_ms": _ms(int(acc.fog)) / f,
		"fogrev_ms": _ms(int(acc.fogrev)) / f,
		"total_ms": _ms(int(acc.total)) / f,
		"morph_units": world.entities.stats.get("donor_morph_units", -1),
		"morph_static": world.entities.stats.get("donor_morph_static_units", -1),
		"morph_cached_meshes": world.entities.stats.get("donor_morph_meshes_cached", -1),
		"morph_frame_changes": world.entities.stats.get("donor_morph_frame_changes", -1),
		"batches": world.entities.stats.get("batches", -1),
		"fog_of_war": Data.FOG_OF_WAR,
		"map": [Data.MAP_W, Data.MAP_H],
		"fog_bytes": world.fog_vis.size(),
	}
	rows.append(row)
	print("PERF3D %s units=%d res=%d total=%.3f view=%.3f sel=%.3f ghost=%.3f rally=%.3f reconcile=%.3f entities=%.3f fx=%.3f fog=%.3f fogrev=%.3f morph=%d cached=%d batches=%d" % [
		label, n_units, int(row.res_nodes), row.total_ms, row.view_ms, row.selection_ms,
		row.ghost_ms, row.rally_ms, row.reconcile_ms, row.entities_ms, row.fx_ms,
		row.fog_ms, row.fogrev_ms, int(row.morph_units), int(row.morph_cached_meshes),
		int(row.batches)])

func _initialize() -> void:
	var cfg = C3Config.new()
	cfg.apply()
	Data.AI_ENABLED = false
	game = C3Game.new()
	root.add_child(game)
	game.setup_begin("skirmish")
	game.players[0].res[0] = 1.0e6
	game.players[1].res[0] = 1.0e6

	var ws = load("res://scripts/world3d.gd")
	world = ws.new()
	root.add_child(world)

	_spawn_units(50, 0)
	world.bind(game)
	var cs = load("res://scripts/camera3d.gd")
	cam = cs.new()
	root.add_child(cam)
	cam.bind(game, world.view_scale)
	_measure("n50", 50)

	_spawn_units(150, 50)
	_measure("n200", 200)
	_micro("n200")

	var abs_dir := ProjectSettings.globalize_path("res://tests/results")
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open(abs_dir + "/per3d_sync_probe_tmp.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"id": "per3d_sync_probe_tmp", "rows": rows}, "\t"))
		f.close()
	call_deferred("quit", 0)
