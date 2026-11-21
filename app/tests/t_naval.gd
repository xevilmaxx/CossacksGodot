# Small asset test: baked naval yacht sprite + hull composite (board P-10, AC).
#
# Verifies the baked assets under res://assets/models/anim/naval/:
#   * index.json parses and exposes walk + hull actions with a cell size
#   * yacht_walk.png is 1280x1920 -> 8 columns of 160px cells, 12 frame rows
#   * yacht_hull.png exists and is 1280x160 -> 8 columns, 1 frame row
#   * each action's sheet dimensions agree with cell * columns / frames
#   * every PNG referenced by the index exists on disk
#
# This is an ASSET test: it must pass on current data. Failures are reported
# exactly; assertions are never weakened to make the test green.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-naval --timeout 90 -- \
#       --headless --path app --script res://tests/t_naval.gd
extends SceneTree

const OUT_DIR := "res://tests/results"
const NAVAL_DIR := "res://assets/models/anim/naval"
const OWNER := "yacht"           # top-level key in index.json
const COLUMNS := 8               # baked sheets use 8 facing columns

var _id := "t_naval"
var _checks: Array[Dictionary] = []
var _ok := true

# Populated during the test; keyed by PNG basename.
var _images := {}

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

func _png_path(basename: String) -> String:
	return NAVAL_DIR + "/" + basename

func _load_png(basename: String) -> Image:
	# Read the raw PNG from disk; works headless and for un-imported files.
	if _images.has(basename):
		return _images[basename]
	var p := _png_path(basename)
	if not FileAccess.file_exists(p):
		_images[basename] = null
		return null
	var img := Image.load_from_file(ProjectSettings.globalize_path(p))
	_images[basename] = img
	return img

func _dims(basename: String) -> String:
	var img: Image = _load_png(basename)
	if img == null:
		return "<missing>"
	return "%dx%d" % [img.get_width(), img.get_height()]

func _initialize() -> void:
	# --- load + parse index.json -------------------------------------------
	var idx_path := _png_path("index.json")
	var raw := FileAccess.get_file_as_string(idx_path)
	var idx = JSON.parse_string(raw) if raw != "" else null
	check("index_parses_with_walk_hull", idx is Dictionary \
		and (idx.has(OWNER)) and (idx[OWNER] is Dictionary) \
		and (idx[OWNER].has("cell")) and (idx[OWNER].has("actions")) \
		and (idx[OWNER]["actions"] is Dictionary) \
		and (idx[OWNER]["actions"].has("walk")) \
		and (idx[OWNER]["actions"].has("hull")),
		"index.json parsed=%s, owner '%s' present=%s, actions=%s" % [
			str(idx is Dictionary), OWNER,
			str(idx is Dictionary and idx.has(OWNER)),
			str(idx[OWNER]["actions"].keys()) if idx is Dictionary \
				and idx.has(OWNER) and idx[OWNER] is Dictionary \
				and idx[OWNER].has("actions") and idx[OWNER]["actions"] is Dictionary else "<none>"])

	# Safe defaults so later checks still run (and report) if parse failed.
	var cell := 160.0
	var actions := {}
	if idx is Dictionary and idx.has(OWNER) and idx[OWNER] is Dictionary:
		cell = float(idx[OWNER].get("cell", 160.0))
		var a = idx[OWNER].get("actions", {})
		if a is Dictionary:
			actions = a

	# --- walk sheet must be exactly 1280x1920 (8 cols x 12 rows) -----------
	var walk := _load_png("yacht_walk.png")
	var walk_ok := walk != null and walk.get_width() == 1280 and walk.get_height() == 1920
	check("walk_sheet_1280x1920", walk_ok,
		"yacht_walk.png dims=%s (want 1280x1920)" % _dims("yacht_walk.png"))

	# --- 8 columns, derived from the cell size in the index ----------------
	var cols_ok := walk != null and is_equal_approx(float(walk.get_width()) / cell, float(COLUMNS)) \
		and is_equal_approx(cell, 160.0)
	check("walk_eight_columns", cols_ok,
		"width=%s, cell=%.1f, width/cell=%.3f (want 8, cell 160)" % [
			str(walk.get_width()) if walk != null else "<missing>", cell,
			float(walk.get_width()) / cell if walk != null else -1.0])

	# --- hull sheet exists and loads ---------------------------------------
	var hull_exists := FileAccess.file_exists(_png_path("yacht_hull.png"))
	var hull := _load_png("yacht_hull.png")
	check("hull_sheet_exists", hull_exists and hull != null and hull.get_width() == 1280 \
		and hull.get_height() == 160,
		"yacht_hull.png exists=%s, dims=%s (want 1280x160)" % [
			str(hull_exists), _dims("yacht_hull.png")])

	# --- metrics/cell consistent for every action --------------------------
	var metric_lines: Array[String] = []
	var metrics_ok := true
	for action in actions:
		var e = actions[action]
		if not (e is Dictionary) or not e.has("frames"):
			metrics_ok = false
			metric_lines.append("%s:no frames" % str(action))
			continue
		var frames := int(e.get("frames", 0))
		var basename := "%s_%s.png" % [OWNER, str(action)]
		var img: Image = _load_png(basename)
		var want_w := int(round(cell * COLUMNS))
		var want_h := int(round(cell * float(frames)))
		if img == null:
			metrics_ok = false
			metric_lines.append("%s:missing" % basename)
			continue
		var ok := img.get_width() == want_w and img.get_height() == want_h
		metric_lines.append("%s:%dx%d(want %dx%d)" % [
			basename, img.get_width(), img.get_height(), want_w, want_h])
		if not ok:
			metrics_ok = false
	check("metrics_cell_consistent", metrics_ok and actions.size() >= 2,
		"cell=%.1f, cols=%d -> %s" % [cell, COLUMNS, ", ".join(metric_lines)])

	# --- no missing PNG referenced by the index ----------------------------
	var missing: Array[String] = []
	for action in actions:
		var basename := "%s_%s.png" % [OWNER, str(action)]
		if not FileAccess.file_exists(_png_path(basename)):
			missing.append(basename)
		# A 'tool' field, when set, names another referenced PNG.
		var e = actions[action]
		if e is Dictionary:
			var tool = e.get("tool", null)
			if tool is String and str(tool) != "" and not FileAccess.file_exists(_png_path(str(tool))):
				missing.append(str(tool))
	check("no_missing_referenced_png", missing.is_empty(),
		"actions=%d, missing=%s" % [actions.size(), str(missing) if not missing.is_empty() else "none"])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
