# V7-78 temporary probe — automatic shipped-skin registration, no manual probe
# registration. Adds ONE unit by REAL roster sid through world3d_entities.gd,
# syncs at two donor frame times and measures the rendered vertex-buffer change.
# Deleted after the run.
extends SceneTree

const OUT_DIR := "res://tests/results"
const RESULT_ID := "v778_probe"
const ANIM_PATH := "res://scripts/anim3d.gd"
const ENT_PATH := "res://scripts/world3d_entities.gd"
const LABEL := "PORT APPROXIMATION — NOT DONOR PARITY"

var _checks: Array[Dictionary] = []
var _ok := true

class StubGame extends RefCounted:
	var entities: Array[Dictionary] = []
	var res_nodes: Array[Dictionary] = []
	var by_id: Dictionary = {}
	var players: Array = [{"id": 0, "entities": []}]
	var fog_explored: Array = []
	var fog_vis: Array = []
	var map_w: int = 64
	var map_h: int = 64
	var tile: float = 1.0
	var time_s: float = 0.0
	func _get(_property: StringName) -> Variant:
		return null
	func tile_visible(_p: Vector2) -> bool:
		return true
	func has_chunk_or_fallback() -> bool:
		return true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("CHECK ", "PASS" if cond else "FAIL", " ", name, " :: ", detail)

func _verts_for(entities: Node) -> Dictionary:
	# donor_frame -> PackedVector3Array, read from the RENDERED morph meshes.
	var out := {}
	for child in entities.get_children():
		if child is MultiMeshInstance3D and str(child.name).find("MORPH_a") >= 0:
			var fr := int(child.get_meta("donor_frame", -1))
			var mm: MultiMesh = (child as MultiMeshInstance3D).multimesh
			var mesh: Mesh = mm.mesh
			var arr: Array = mesh.surface_get_arrays(0)
			out[fr] = arr[Mesh.ARRAY_VERTEX] as PackedVector3Array
	return out

func _initialize() -> void:
	var world := Node3D.new()
	root.add_child(world)

	var anim_script: Resource = load(ANIM_PATH)
	var ent_script: Resource = load(ENT_PATH)
	check("modules_load", anim_script is GDScript and ent_script is GDScript,
		"anim=%s entities=%s" % [str(anim_script), str(ent_script)])
	if not (anim_script is GDScript) or not (ent_script is GDScript):
		call_deferred("quit", 1)
		return

	var anim: Node = (anim_script as GDScript).new()
	world.add_child(anim)
	var entities: Node = (ent_script as GDScript).new()
	world.add_child(entities)

	var game := StubGame.new()
	# REAL roster sid from assets/models/manifest.json (peasant -> peaukr.oss).
	var unit := {
		"id": 9001, "kind": "unit", "player": 0, "sid": "peasant",
		"def": {"hp": 60, "radius": 0.45, "height": 1.9, "speed": 3.0,
			"model": "peasant", "tex": "peasant", "build_time": 0.0},
		"pos": Vector2(10.0, 10.0), "hp": 60, "max_hp": 60, "dead": false,
		"moving": false, "face": 0.0, "finished": true, "selected": false,
	}
	game.entities.append(unit)
	game.by_id[9001] = unit

	entities.call("bind", game)
	anim.call("bind", game, entities)
	entities.call("add_unit", unit)

	# NO register_skin() / load_skin_from_donor() call anywhere in this probe.
	var shipped: Dictionary = anim.call("shipped_skin_info")
	check("auto_loaded_assets", int(shipped.get("auto_loaded", 0)) >= 1,
		"auto_loaded=%d bytes=%d error='%s'" % [int(shipped.get("auto_loaded", 0)),
		int(shipped.get("total_bytes", 0)), str(shipped.get("error", ""))])
	check("auto_error_empty", str(shipped.get("error", "")) == "",
		"error='" + str(shipped.get("error", "")) + "'")
	check("real_sid_auto_registered", bool(anim.call("has_skin", "peasant")),
		"has_skin('peasant') without manual registration")
	var info: Dictionary = anim.call("skin_info", "peasant")
	check("shipped_source", str(info.get("source", "")) == "donor_oss_subset_v1",
		"source=" + str(info.get("source", "")))
	check("shipped_header", int(info.get("verts", 0)) == 577 and int(info.get("bones", 0)) == 20
		and int(info.get("k", 0)) == 483,
		"k=%d bones=%d v=%d" % [int(info.get("k", 0)), int(info.get("bones", 0)), int(info.get("verts", 0))])
	check("shipped_label", str(info.get("label", "")) == LABEL, str(info.get("label", "")))
	check("shipped_visual", str(info.get("visual", "")) == "UNVERIFIED", str(info.get("visual", "")))

	# Donor frame 1 and frame 10 from the unit's OWN AAF (peaukr.aaf:3 idle / :5 walk).
	entities.call("sync", 0.0)
	var stats0: Dictionary = (entities.get("stats") as Dictionary).duplicate(true)
	var batches0: Dictionary = _verts_for(entities)
	entities.call("sync", 0.3)
	var stats1: Dictionary = (entities.get("stats") as Dictionary).duplicate(true)
	var batches1: Dictionary = _verts_for(entities)

	check("morph_units_1", int(stats1.get("donor_morph_units", 0)) == 1,
		"donor_morph_units=%s" % str(stats1.get("donor_morph_units", 0)))
	check("static_units_0", int(stats1.get("donor_morph_static_units", 0)) == 0,
		"static=%s" % str(stats1.get("donor_morph_static_units", 0)))
	check("no_rejects", (stats1.get("donor_morph_rejects", {}) as Dictionary).is_empty(),
		"rejects=" + str(stats1.get("donor_morph_rejects", {})))
	var frames0: Array = stats0.get("donor_morph_frames", [])
	var frames1: Array = stats1.get("donor_morph_frames", [])
	check("two_donor_frames", frames0.size() == 1 and frames1.size() == 1
		and int(frames0[0]) != int(frames1[0]),
		"frames %s -> %s" % [str(frames0), str(frames1)])

	var a: PackedVector3Array = batches0.get(int(frames0[0]), PackedVector3Array())
	var b: PackedVector3Array = batches1.get(int(frames1[0]), PackedVector3Array())
	check("rendered_buffers", a.size() > 0 and a.size() == b.size(),
		"sizes %d / %d" % [a.size(), b.size()])
	var changed := 0
	var maxd := 0.0
	var sumd := 0.0
	if a.size() == b.size():
		for i in range(a.size()):
			var d: float = (b[i] - a[i]).length()
			if d > 0.0:
				changed += 1
			maxd = maxf(maxd, d)
			sumd += d
	var mean: float = sumd / float(maxi(a.size(), 1))
	check("verts_differ", changed > 0,
		"%d/%d verts changed, max=%.9f mean=%.9f m" % [changed, a.size(), maxd, mean])
	check("max_matches_donor", maxd > 0.01 and maxd < 1.0,
		"max displacement %.9f m (donor peaukr walk delta 0.2953 m)" % maxd)

	var pose: Dictionary = anim.call("pose_for", unit, "idle", 0.0)
	check("pose_source", str(pose.get("pose_source", "")) == "donor_flat_root_morph",
		str(pose.get("pose_source", "")))
	check("pose_label", str(pose.get("label", "")) == LABEL, str(pose.get("label", "")))
	check("pose_visual", str(pose.get("visual", "")) == "UNVERIFIED", str(pose.get("visual", "")))
	check("pose_verts", (pose.get("verts") as PackedVector3Array).size() == 577,
		"vertex_count=%d" % int(pose.get("vertex_count", 0)))
	check("own_aaf_range", (pose.get("range") as Array) == [64, 113],
		"range=" + str(pose.get("range", [])))
	check("sample_frame_reported", int(pose.get("sample_frame", -1)) == 64,
		"sample_frame=%d requested_frame=%d" % [int(pose.get("sample_frame", -1)),
		int(pose.get("requested_frame", -1))])

	# Second scenario in a FRESH entity module (so _anim_t starts at 0): walk.
	# t=0 -> donor walk frame 1; t=0.3 -> frame 10 -> shipped subset frame 9.
	var world2 := Node3D.new()
	root.add_child(world2)
	var anim2: Node = (anim_script as GDScript).new()
	world2.add_child(anim2)
	var entities2: Node = (ent_script as GDScript).new()
	world2.add_child(entities2)
	var game2 := StubGame.new()
	var walker := unit.duplicate(true)
	walker["id"] = 9002
	walker["moving"] = true
	game2.entities.append(walker)
	game2.by_id[9002] = walker
	entities2.call("bind", game2)
	anim2.call("bind", game2, entities2)
	entities2.call("add_unit", walker)
	entities2.call("sync", 0.0)
	var wf0: Array = (entities2.get("stats") as Dictionary).get("donor_morph_frames", [])
	entities2.call("sync", 0.3)
	var wf1: Array = (entities2.get("stats") as Dictionary).get("donor_morph_frames", [])
	var wb0: Dictionary = _verts_for(entities2)
	check("walk_two_frames", wf0.size() == 1 and wf1.size() == 1 and int(wf0[0]) != int(wf1[0]),
		"walk frames %s -> %s" % [str(wf0), str(wf1)])
	var wa: PackedVector3Array = wb0.get(int(wf0[0]), PackedVector3Array())
	var wb: PackedVector3Array = wb0.get(int(wf1[0]), PackedVector3Array())
	var w_changed := 0
	var w_max := 0.0
	var w_sum := 0.0
	if wa.size() == wb.size() and wa.size() > 0:
		for i in range(wa.size()):
			var wd: float = (wb[i] - wa[i]).length()
			if wd > 0.0:
				w_changed += 1
			w_max = maxf(w_max, wd)
			w_sum += wd
	var w_mean: float = w_sum / float(maxi(wa.size(), 1))
	check("walk_verts_differ", w_changed > 0 and w_max > 0.1,
		"%d/%d walk verts changed, max=%.9f mean=%.9f m" % [w_changed, wa.size(), w_max, w_mean])
	check("walk_auto_registered", bool(anim2.call("has_skin", "peasant")),
		"second instance also auto-loads shipped skin")

	var payload := {
		"id": RESULT_ID, "passed": _ok, "checks": _checks,
		"auto_loaded": int(shipped.get("auto_loaded", 0)),
		"asset_bytes": int(shipped.get("total_bytes", 0)),
		"frames": [int(frames0[0]), int(frames1[0])],
		"rendered_corners": a.size(), "vertices_changed": changed,
		"max_delta_m": maxd, "mean_delta_m": mean,
		"walk_frames": [int(wf0[0]), int(wf1[0])],
		"walk_vertices_changed": w_changed, "walk_max_delta_m": w_max,
		"walk_mean_delta_m": w_mean,
		"manual_registration_calls": 0,
	}
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open(abs_dir + "/" + RESULT_ID + ".json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(payload, "\t"))
		f.close()
	call_deferred("quit", 0 if _ok else 1)
