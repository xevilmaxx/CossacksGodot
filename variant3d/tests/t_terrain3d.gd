extends SceneTree

# V7-31 — ATOMIC test for variant3d/scripts/world3d_terrain.gd.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-24/reports/V731_test_terrain3d.md).
# Contract: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:12,26-30.
# Geometry reference (NOT a donor binary): G32 report §2/§6 — a single indexed
# ArrayMesh, one surface, w*h shared cell-centre vertices,
# (w-1)*(h-1)*2 triangles, vertex at
# ((x+0.5-w/2)*TILE_M, height[z*w+x]*HEIGHT_SCALE, (z+0.5-h/2)*TILE_M).
#
# Harness is SceneTree because `--script` requires a MainLoop (G32 ticket 1312).
# The module is loaded dynamically via load() — no class_name dependency.
# Every exit goes through call_deferred("quit", ...) — never from _initialize().
# If the module is not on disk the test FAILS with a clearly labelled
# MODULE_MISSING line for every check; no assertion is weakened or skipped.

const MODULE_PATH := "res://scripts/world3d_terrain.gd"
const OUT_PATH := "res://tests/results/t_terrain3d.json"

# 320^2 mirrors G32: 102,400 verts / 203,522 tris / 1 surface.
const GRID_W := 320
const GRID_H := 320
const TILE_M := 2.0           # C3Data.TILE_M (variant3d/scripts/data.gd:23)
const HEIGHT_SCALE := 1.0     # dump height[] is metres (G32 §2)
const SAMPLE_EPS := 1e-4      # float32 grid tolerance

const CHECK_NAMES := [
	"module_load_and_api",
	"build_ok",
	"surface_count",
	"vertex_count",
	"has_chunk_or_fallback",
	"height_at_world_samples",
]

# Minimal game: extends the real C3Game so a typed bind(game: C3Game) also works.
# The base64 height grid is exposed explicitly (height_b64 / dump["height"]),
# and the decoded PackedFloat32Array is placed in the inherited `height`, which
# is the representation the port sim uses (game.gd:44, main.gd:847-850).
class StubGame extends C3Game:
	var height_b64: String = ""
	var dump: Dictionary = {}
	var map_w: int = 0
	var map_h: int = 0


var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _world: Node = null
var _heights := PackedFloat32Array()
var _mesh: MeshInstance3D = null


func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("T_TERRAIN3D %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


func finish() -> void:
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var abs_path := ProjectSettings.globalize_path(OUT_PATH)
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({
			"id": "t_terrain3d",
			"passed": _ok,
			"passes": passes,
			"total": _checks.size(),
			"checks": _checks,
			"module": MODULE_PATH,
			"grid": {"w": GRID_W, "h": GRID_H},
		}, "\t"))
		f.close()
	else:
		push_error("t_terrain3d: cannot write result: " + abs_path)
	print("T_TERRAIN3D RESULT: %s %d/%d" % ["PASS" if _ok else "FAIL", passes, _checks.size()])
	call_deferred("quit", 0 if _ok else 1)


func abort_checks(from_index: int, tag: String, reason: String) -> void:
	for i in range(from_index, CHECK_NAMES.size()):
		check(CHECK_NAMES[i], false, tag + ": " + reason)
	finish()


# Safety net: if _initialize() aborts on a runtime error, still report + quit.
func _failsafe() -> void:
	if _finished:
		return
	abort_checks(0, "ABORTED", "test aborted before completion")


# Deterministic synthetic height grid; base64 little-endian float32, row-major
# idx = z*w + x (G32 §2, main.gd:688-695).
func _make_game() -> StubGame:
	var n: int = GRID_W * GRID_H
	var raw := PackedByteArray()
	raw.resize(n * 4)
	_heights.resize(n)
	for z in range(GRID_H):
		for x in range(GRID_W):
			var i: int = z * GRID_W + x
			var v: float = sin(float(x) * 0.07) * 1.5 + cos(float(z) * 0.05)
			v += float((x * 7 + z * 13) % 17) * 0.01
			_heights[i] = v
			raw.encode_float(i * 4, v)
	var b64: String = Marshalls.raw_to_base64(raw)
	var g := StubGame.new()
	g.MAP_W = GRID_W
	g.MAP_H = GRID_H
	g.map_w = GRID_W
	g.map_h = GRID_H
	g.height = _heights
	g.height_b64 = b64
	g.dump = {"map_w": GRID_W, "map_h": GRID_H, "height": b64}
	return g


# Locate the resident full-grid ArrayMesh. The water quad (4 verts) is smaller,
# so the largest indexed mesh is the terrain — no reliance on a node name or on
# a stats dictionary the contract does not promise.
func _find_terrain_mesh(root: Node) -> MeshInstance3D:
	var best: MeshInstance3D = null
	var best_verts: int = -1
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			var m: Mesh = mi.mesh
			if m is ArrayMesh and m.get_surface_count() > 0:
				var arr: Array = m.surface_get_arrays(0)
				var vs = arr[Mesh.ARRAY_VERTEX]
				var count: int = vs.size() if vs != null else 0
				if count > best_verts:
					best_verts = count
					best = mi
		for c in n.get_children():
			stack.append(c)
	return best


# Cell-centre world coordinate from the G32 mesh recipe.
func _cell_world(x: int, z: int) -> Vector2:
	return Vector2(
		(float(x) + 0.5 - float(GRID_W) * 0.5) * TILE_M,
		(float(z) + 0.5 - float(GRID_H) * 0.5) * TILE_M)


func _initialize() -> void:
	if _finished:
		return
	call_deferred("_failsafe")

	# Check 1 — module present, parse/load clean, full API callable.
	if not (FileAccess.file_exists(ProjectSettings.globalize_path(MODULE_PATH))
			and ResourceLoader.exists(MODULE_PATH)):
		print("T_TERRAIN3D MODULE_MISSING: " + MODULE_PATH + " is not on disk")
		abort_checks(0, "MODULE_MISSING", MODULE_PATH + " not on disk")
		return
	var script := load(MODULE_PATH) as Script
	if script == null or not script.can_instantiate():
		abort_checks(0, "LOAD_ERROR", "load()/can_instantiate() failed for " + MODULE_PATH)
		return
	var inst: Object = script.new()
	if inst == null:
		abort_checks(0, "LOAD_ERROR", "script.new() returned null")
		return
	var required := ["bind", "build", "invalidate", "has_chunk_or_fallback", "height_at_world"]
	var missing: Array[String] = []
	for m in required:
		if not inst.has_method(m):
			missing.append(m)
	check("module_load_and_api", missing.is_empty(),
		"loaded " + MODULE_PATH + "; missing_methods=" + str(missing))
	if not missing.is_empty():
		abort_checks(1, "API_INCOMPLETE", "missing " + str(missing))
		return
	_world = inst as Node
	get_root().add_child(_world)

	var game := _make_game()
	get_root().add_child(game)
	inst.call("bind", game)

	# Check 2 — build() must succeed before geometry can be inspected.
	var built := false
	if inst.has_method("build"):
		built = bool(inst.call("build"))
	check("build_ok", built, "build() returned " + str(built))
	if not built:
		abort_checks(2, "SETUP_FAILED", "build() returned false")
		return

	# Check 3 — exactly one surface on the resident full-grid terrain mesh.
	_mesh = _find_terrain_mesh(_world)
	var surfaces: int = -1
	if _mesh != null and _mesh.mesh != null:
		surfaces = _mesh.mesh.get_surface_count()
	check("surface_count", surfaces == 1,
		"terrain_mesh=" + str(_mesh.name if _mesh != null else "<none>")
		+ " surfaces=" + str(surfaces) + " (expected 1)")

	# Check 4 — vertex count equals w*h (102,400 at 320^2 per G32 §6).
	var vertices: int = -1
	var triangles: int = -1
	if _mesh != null and _mesh.mesh != null and surfaces > 0:
		var arr: Array = _mesh.mesh.surface_get_arrays(0)
		var vs = arr[Mesh.ARRAY_VERTEX]
		var inds = arr[Mesh.ARRAY_INDEX]
		vertices = vs.size() if vs != null else -1
		triangles = (inds.size() / 3) if inds != null else -1
	check("vertex_count", vertices == GRID_W * GRID_H,
		"vertices=" + str(vertices) + " expected=" + str(GRID_W * GRID_H)
		+ " triangles=" + str(triangles) + " (informational)")

	# Check 5 — no chunks/fallback: trivially true when the full mesh is resident.
	var has_resident := false
	if inst.has_method("has_chunk_or_fallback"):
		has_resident = bool(inst.call("has_chunk_or_fallback"))
	check("has_chunk_or_fallback", has_resident,
		"returned " + str(has_resident) + " (expected true, no chunks)")

	# Check 6 — height_at_world() at three cell centres matches the source grid.
	var samples := [[3, 5], [160, 160], [317, 312]]
	var sample_ok := true
	var detail_parts: Array[String] = []
	for s in samples:
		var x: int = int(s[0])
		var z: int = int(s[1])
		var expected: float = _heights[z * GRID_W + x]
		var p: Vector2 = _cell_world(x, z)
		var got: float = float(inst.call("height_at_world", p))
		var err: float = absf(got - expected)
		var ok: bool = err <= SAMPLE_EPS
		if not ok:
			sample_ok = false
		detail_parts.append("(%s,%s) expected=%s got=%s err=%s %s"
			% [str(x), str(z), str(expected), str(got), str(err),
				"ok" if ok else "MISMATCH"])
	check("height_at_world_samples", sample_ok,
		"eps=" + str(SAMPLE_EPS) + " " + " | ".join(detail_parts))

	finish()
