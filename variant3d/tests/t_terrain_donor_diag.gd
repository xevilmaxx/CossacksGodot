extends SceneTree

# ---------------------------------------------------------------------------
# W02 — live donor-backend data-path diagnostic (2026-11-26)
# Owner file: variant3d/tests/t_terrain_donor_diag.gd
#
# DIAGNOSTIC ONLY. This atom does not certify donor fidelity and does not make a
# visual parity claim. It exercises the live I17 -> I07 -> I06 path, writes raw
# arrays outside the repo, and derives measurements from those arrays. It does
# not read donor files, synthesise noise/dither, change generator thresholds,
# or feed diagnostics back into generation.
#
# I17 may select a native 320x320 mask even when asked for the configured size
# (--size 64|240|320, default 64). The returned params are passed to I07
# unchanged; the actual live grid is reported. Only the ASCII view is
# capped/downsampled to 64x64. Raw arrays and PNGs retain the actual generated
# grid.
# ---------------------------------------------------------------------------

const ID := "t_terrain_donor_diag"
const OUT_DIR := "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/diag"
const DEFAULT_SIZE := 64
const ALLOWED_SIZES := [64, 240, 320]  # supported donor/port grid sizes
const ASCII_CAP := 64
const SEED := 20261113                 # config.json:77 gameplay.random_seed
const MAP_TYPE := "land"               # config.json:107 gameplay.map_type

const MODULE_INPUTS := "res://scripts/terrain_donor_inputs.gd"  # I17
const MODULE_DATA := "res://scripts/terrain_donor_data.gd"      # I06
const MODULE_GEN := "res://scripts/terrain_donor_gen.gd"        # I07

const COLLISION_TAGS := 4             # dmscript.global:80,134-135,2026-2029
const TILE_ID_MAX := 123               # terrain.presets:2-6,129; spec/06 §1
const WATER_DEEP := -0.25              # texturemap.inc:29-30; spec/05 §1
const WATER_SHORE := -0.1              # texturemap.inc:31; spec/05 §1
const ASCII_RAMP := " .:-=+*#%@"

# Requested grid size is a runtime value: --size <int> in user args, default 64.
# Only ALLOWED_SIZES are accepted; anything else falls back to DEFAULT_SIZE.
var requested_size: int = DEFAULT_SIZE


class StubGame extends RefCounted:
	var seed: int = 0
	var map_type: String = ""


var _ok: bool = true
var _finished: bool = false
var _status: String = "RUNNING"
var _checks: Array[Dictionary] = []
var _errors: Array[String] = []
var _observations: Array[String] = []
var _report: Dictionary = {}


# ---------------------------------------------------------------- lifecycle --
func _initialize() -> void:
	if _finished:
		return
	requested_size = _parse_requested_size()
	call_deferred("_run")
	call_deferred("_failsafe")


func _failsafe() -> void:
	if _finished:
		return
	_check("failsafe", false, "diagnostic aborted before normal completion")
	_status = "ABORTED"
	_finish()


func _run() -> void:
	_report = {
		"id": ID,
		"status": "RUNNING",
		"passed": false,
		"diagnostic_only": true,
		"diagnostic_scope": "LIVE I17 -> I07 -> I06 data path; raw arrays and derived diagnostics only",
		"visual_parity_claim": false,
		"parity": "UNVERIFIED — no donor GPU A/B frame; this is not a parity claim",
		"donor_files_used": false,
		"synthetic_noise": false,
		"synthetic_dither": false,
		"labels": {
			"raw_arrays": "[D] direct live I06 container arrays",
			"metrics": "[D] deterministic diagnostic consequences; never fed back",
			"visual_parity": "[U] UNVERIFIED; no donor GPU A/B frame",
		},
		"output_dir": OUT_DIR,
		"stats_file": OUT_DIR + "/stats.json",
		"requested_grid": {"w": requested_size, "h": requested_size, "n": requested_size * requested_size},
		"actual_grid": {"w": 0, "h": 0, "n": 0},
		"array_layout": {
			"index": "i=y*w+x (x fastest)",
			"height_unit": "[U] raw float32; no HEIGHT_SCALE multiplier",
			"row_sign": "UNVERIFIED",
			"collision": "u8[4] per height cell; PORT narrowing [U]",
		},
		"stub_game": {"seed": SEED, "map_type": MAP_TYPE},
		"modules": {},
		"params_summary": {},
		"input_provider_stats": {},
		"input_provider_loaded": [],
		"input_provider_skipped": [],
		"generation_ledger": [],
		"generation_telemetry": {},
		"generation_trace": {},
		"container_stats": {},
		"metrics": {},
		"raw_arrays": {},
		"raw_sha256": {},
		"ascii_heightmap": {},
		"png_maps": {},
		"artifacts": {},
		"errors": _errors,
		"observations": _observations,
	}

	var dir_err: Error = DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_check("output_directory", dir_err == OK, "make_dir_recursive_absolute err=%d" % dir_err)
	if dir_err != OK:
		_status = "OUTPUT_DIR_ERROR"
		_finish()
		return

	# Load every module independently so one failure does not hide the others.
	var inputs_script: Script = _load_script(MODULE_INPUTS, "I17_inputs")
	var data_script: Script = _load_script(MODULE_DATA, "I06_data")
	var gen_script: Script = _load_script(MODULE_GEN, "I07_generator")
	if inputs_script == null or data_script == null or gen_script == null:
		if _status == "RUNNING":
			_status = "MODULE_LOAD_FAILED"
		_finish()
		return

	var inputs: Object = null
	var data: Object = null
	var gen: Object = null
	var inputs_value: Variant = inputs_script.new()
	var data_value: Variant = data_script.new(requested_size, requested_size)
	var gen_value: Variant = gen_script.new()
	if inputs_value is Object:
		inputs = inputs_value as Object
	if data_value is Object:
		data = data_value as Object
	if gen_value is Object:
		gen = gen_value as Object
	_check("instantiate_inputs", inputs != null, "I17 new()")
	_check("instantiate_data", data != null, "I06 new(%d,%d)" % [requested_size, requested_size])
	_check("instantiate_generator", gen != null, "I07 new()")
	if inputs == null or data == null or gen == null:
		_status = "INSTANTIATION_FAILED"
		_finish()
		return

	var initial_w: int = _object_int(data, "w")
	var initial_h: int = _object_int(data, "h")
	var initial_n: int = _object_int(data, "n")
	_check("initial_container_grid", initial_w == requested_size and initial_h == requested_size
			and initial_n == requested_size * requested_size,
			"w=%d h=%d n=%d expected=%dx%d" % [initial_w, initial_h, initial_n, requested_size, requested_size])

	# I17: the returned Dictionary is passed to I07 unchanged.
	var game := StubGame.new()
	game.seed = SEED
	game.map_type = MAP_TYPE
	var params: Dictionary = {}
	if inputs.has_method("build"):
		var params_value: Variant = inputs.call("build", game, requested_size, requested_size)
		if params_value is Dictionary:
			params = params_value as Dictionary
		_check("input_provider_build", params_value is Dictionary,
				"build(game,%d,%d) returned %s" % [requested_size, requested_size, typeof(params_value)])
	else:
		_check("input_provider_build", false, "I17 has no build() method")
	if params.is_empty():
		_check("input_provider_params_nonempty", false, "I17 build() returned an empty params Dictionary")
		_status = "INPUT_BUILD_FAILED"
		_finish()
		return
	_check("input_provider_params_nonempty", true, "params keys=%d" % params.size())

	var parity_value: Variant = params.get("visual_parity_claim", null)
	var parity_ok: bool = params.has("visual_parity_claim") and parity_value is bool and parity_value == false
	_check("input_visual_parity_guard", parity_ok,
			"visual_parity_claim=%s (must be explicit false)" % str(parity_value))
	_report["params_summary"] = _summarize_params(params)

	var input_stats: Dictionary = {}
	if inputs.has_method("stats"):
		var input_stats_value: Variant = inputs.call("stats")
		if input_stats_value is Dictionary:
			input_stats = input_stats_value as Dictionary
		_check("input_provider_stats", input_stats_value is Dictionary,
				"stats() returned %s" % typeof(input_stats_value))
	else:
		_check("input_provider_stats", false, "I17 has no stats() method")
	_report["input_provider_stats"] = input_stats.duplicate(true)
	var loaded_value: Variant = input_stats.get("loaded", [])
	var skipped_value: Variant = input_stats.get("skipped", [])
	_report["input_provider_loaded"] = (loaded_value as Array).duplicate(true) if loaded_value is Array else []
	_report["input_provider_skipped"] = (skipped_value as Array).duplicate(true) if skipped_value is Array else []

	# I07: generate into the I06 container using the live provider params.
	if not gen.has_method("generate"):
		_check("generator_generate_method", false, "I07 has no generate() method")
		_status = "GENERATION_FAILED"
		_finish()
		return
	var generation_value: Variant = gen.call("generate", data, params)
	_check("generator_return_dictionary", generation_value is Dictionary,
			"generate(data,params) returned %s" % typeof(generation_value))
	if not (generation_value is Dictionary):
		_status = "GENERATION_FAILED"
		_finish()
		return

	var telemetry: Dictionary = {}
	if gen.has_method("stats"):
		var telemetry_value: Variant = gen.call("stats")
		if telemetry_value is Dictionary:
			telemetry = telemetry_value as Dictionary
		_check("generator_stats", telemetry_value is Dictionary,
				"stats() returned %s" % typeof(telemetry_value))
	else:
		_check("generator_stats", false, "I07 has no stats() method")
	_report["generation_telemetry"] = telemetry.duplicate(true)
	var ledger: Array = _extract_generation_ledger(gen, telemetry)
	_report["generation_ledger"] = ledger.duplicate(true)
	_check("generation_ledger_complete", _ledger_has_end(ledger),
			"rng_sites=%d; END marker=%s" % [ledger.size(), str(_ledger_has_end(ledger))])

	var container_stats: Dictionary = {}
	if data.has_method("stats"):
		var container_stats_value: Variant = data.call("stats")
		if container_stats_value is Dictionary:
			container_stats = container_stats_value as Dictionary
		_check("container_stats", container_stats_value is Dictionary,
				"stats() returned %s" % typeof(container_stats_value))
	else:
		_check("container_stats", false, "I06 has no stats() method")
	_report["container_stats"] = container_stats.duplicate(true)

	var meta_value: Variant = data.get("meta")
	if meta_value is Dictionary:
		var trace_value: Variant = (meta_value as Dictionary).get("generator_trace", {})
		if trace_value is Dictionary:
			_report["generation_trace"] = (trace_value as Dictionary).duplicate(true)

	var actual_w: int = _object_int(data, "w")
	var actual_h: int = _object_int(data, "h")
	var actual_n: int = _object_int(data, "n")
	_report["actual_grid"] = {"w": actual_w, "h": actual_h, "n": actual_n}
	var grid_ok: bool = actual_w > 0 and actual_h > 0 and actual_w <= 640 and actual_h <= 640 \
			and actual_n == actual_w * actual_h
	_check("generated_grid", grid_ok, "w=%d h=%d n=%d" % [actual_w, actual_h, actual_n])
	if actual_w != requested_size or actual_h != requested_size:
		_observe("I17 requested %dx%d but supplied native grid %dx%d; I07 reconfigured I06. Raw arrays/PNGs use the actual live grid; ASCII is capped at %dx%d."
				% [requested_size, requested_size, actual_w, actual_h, ASCII_CAP, ASCII_CAP])
	if not grid_ok:
		_status = "DATA_CONTRACT_FAILED"
		_finish()
		return

	var height_value: Variant = data.get("height")
	var tex_value: Variant = data.get("tex")
	var terrain_value: Variant = data.get("terrain_class")
	var collision_value: Variant = data.get("collision")
	var water_value: Variant = data.get("water")
	var height_ok: bool = height_value is PackedFloat32Array and (height_value as PackedFloat32Array).size() == actual_n
	var tex_ok: bool = tex_value is PackedByteArray and (tex_value as PackedByteArray).size() == actual_n
	var terrain_ok: bool = terrain_value is PackedByteArray and (terrain_value as PackedByteArray).size() == actual_n
	var collision_ok: bool = collision_value is PackedByteArray \
			and (collision_value as PackedByteArray).size() == actual_n * COLLISION_TAGS
	var water_ok: bool = water_value is PackedByteArray and (water_value as PackedByteArray).size() == actual_n
	_check("height_array_contract", height_ok, "expected %d float32 values" % actual_n)
	_check("tileblock_array_contract", tex_ok, "expected %d bytes" % actual_n)
	_check("terrain_array_contract", terrain_ok, "expected %d bytes" % actual_n)
	_check("collision_array_contract", collision_ok, "expected %d bytes (%d tags/cell)" % [actual_n * COLLISION_TAGS, COLLISION_TAGS])
	_check("water_array_contract", water_ok, "expected %d bytes" % actual_n)
	if not (height_ok and tex_ok and terrain_ok and collision_ok and water_ok):
		_status = "DATA_CONTRACT_FAILED"
		_finish()
		return

	var height: PackedFloat32Array = height_value as PackedFloat32Array
	var tex: PackedByteArray = tex_value as PackedByteArray
	var terrain: PackedByteArray = terrain_value as PackedByteArray
	var collision: PackedByteArray = collision_value as PackedByteArray
	var water: PackedByteArray = water_value as PackedByteArray

	# Metrics are derived after generation and are never fed back into it.
	var height_metrics: Dictionary = _height_metrics(height, actual_w, actual_h)
	_check("height_finite", bool(height_metrics.get("all_finite", false)),
			"nonfinite=%d finite=%d" % [int(height_metrics.get("nonfinite", -1)), int(height_metrics.get("finite", -1))])
	var tile_report: Dictionary = _tile_report(tex)
	var tile_names_value: Variant = params.get("tile_id_to_name", {})
	if tile_names_value is Dictionary:
		tile_report["tile_id_names"] = (tile_names_value as Dictionary).duplicate(true)
	_report["metrics"] = {
		"height": height_metrics,
		"cell_counts": {
			"height": _byte_counts_from_height(height),
			"tileblock": _byte_counts(tex),
			"terrain": _byte_counts(terrain),
			"collision_bytes": _byte_counts(collision),
			"collision_cells": _collision_cell_counts(collision),
		},
		"tile": tile_report,
		"terrain_class_histogram": _byte_histogram(terrain),
		"water": _water_report(water, height),
		"collision": _collision_report(collision),
	}
	if int(height_metrics.get("nonzero", -1)) == 0:
		_observe("Height field is all exact zero; recorded without a visual-quality gate.")
	if int(tile_report.get("distinct_ids", -1)) <= 1:
		_observe("Tile field has at most one distinct id; recorded without a visual-quality gate.")

	# Raw arrays: explicit float32 little-endian encoding; byte arrays unchanged.
	var raw_height: PackedByteArray = _f32_le(height)
	var raw_tile: PackedByteArray = tex.duplicate()
	var raw_terrain: PackedByteArray = terrain.duplicate()
	var raw_collision: PackedByteArray = collision.duplicate()
	var raw_arrays: Dictionary = {
		"height.raw": raw_height,
		"tileblock.raw": raw_tile,
		"terrain.raw": raw_terrain,
		"collision.raw": raw_collision,
	}
	_report["raw_arrays"] = {
		"height.raw": {"encoding": "IEEE-754 float32 little-endian", "values": actual_n, "bytes": raw_height.size()},
		"tileblock.raw": {"encoding": "u8 tile id", "values": actual_n, "bytes": raw_tile.size()},
		"terrain.raw": {"encoding": "u8 terrain_class side array", "values": actual_n, "bytes": raw_terrain.size()},
		"collision.raw": {"encoding": "u8[4] per height cell, tag-major within cell", "values": actual_n * COLLISION_TAGS, "bytes": raw_collision.size()},
	}
	for raw_name in raw_arrays.keys():
		var raw: PackedByteArray = raw_arrays[raw_name]
		var digest: String = _sha256(raw)
		_report["raw_sha256"][raw_name] = digest
		var raw_path: String = OUT_DIR + "/" + raw_name
		var write_err: Error = _write_bytes(raw_path, raw)
		_check("write_" + raw_name, write_err == OK, "path=%s err=%d" % [raw_path, write_err])
		if write_err == OK:
			var disk_bytes: PackedByteArray = FileAccess.get_file_as_bytes(raw_path)
			var disk_digest: String = _sha256(disk_bytes)
			_check("readback_" + raw_name, disk_digest == digest,
					"disk_sha256=%s array_sha256=%s" % [disk_digest, digest])
			_record_artifact(raw_name, raw_path)

	# ASCII heightmap: no header/footer, at most 64 rows x 64 columns.
	var ascii: Dictionary = _ascii_heightmap(height, actual_w, actual_h, height_metrics)
	_report["ascii_heightmap"] = {
		"file": "heightmap.txt",
		"width": int(ascii["width"]),
		"height": int(ascii["height"]),
		"source_width": actual_w,
		"source_height": actual_h,
		"cap": ASCII_CAP,
		"method": "finite block means; global finite min/max normalisation",
		"ramp": ASCII_RAMP,
		"flat_marker": "~",
		"nonfinite_marker": "?",
	}
	var ascii_path: String = OUT_DIR + "/heightmap.txt"
	var ascii_err: Error = _write_text(ascii_path, str(ascii["text"]))
	_check("write_heightmap_ascii", ascii_err == OK, "path=%s err=%d" % [ascii_path, ascii_err])
	if ascii_err == OK:
		var ascii_text: String = str(ascii["text"])
		var ascii_lines: PackedStringArray = ascii_text.split("\n")
		var ascii_shape_ok: bool = ascii_lines.size() == int(ascii["height"])
		for line in ascii_lines:
			if str(line).length() != int(ascii["width"]):
				ascii_shape_ok = false
				break
		_check("heightmap_ascii_shape", ascii_shape_ok and int(ascii["width"]) <= ASCII_CAP \
				and int(ascii["height"]) <= ASCII_CAP,
				"rows=%d cols=%d cap=%d" % [ascii_lines.size(), int(ascii["width"]), ASCII_CAP])
		_record_artifact("heightmap.txt", ascii_path)

	# PNG maps are generated only from the live arrays; no atlas/donor images.
	var height_image: Image = _height_image(height, actual_w, actual_h,
			height_metrics.get("min", null), height_metrics.get("max", null))
	var height_png_path: String = OUT_DIR + "/heightmap.png"
	var height_png_err: Error = height_image.save_png(height_png_path)
	_check("write_heightmap_png", height_png_err == OK, "path=%s err=%d" % [height_png_path, height_png_err])
	if height_png_err == OK:
		_record_artifact("heightmap.png", height_png_path)

	var tile_image: Image = _tile_image(tex, actual_w, actual_h)
	var tile_png_path: String = OUT_DIR + "/tile_id_map.png"
	var tile_png_err: Error = tile_image.save_png(tile_png_path)
	_check("write_tile_id_map_png", tile_png_err == OK, "path=%s err=%d" % [tile_png_path, tile_png_err])
	if tile_png_err == OK:
		_record_artifact("tile_id_map.png", tile_png_path)
	_report["png_maps"] = {
		"heightmap.png": {
			"width": actual_w, "height": actual_h,
			"mapping": "finite min -> black, finite max -> white; flat -> mid-gray; nonfinite -> magenta",
			"source": "I06 height only",
		},
		"tile_id_map.png": {
			"width": actual_w, "height": actual_h,
			"mapping": "R=G=B=tile_id/255, A=255 (direct id intensity; no art substitution)",
			"source": "I06 tex only",
		},
	}

	_finish()


# ------------------------------------------------------------- module guards --
func _load_script(path: String, label: String) -> Script:
	var exists: bool = ResourceLoader.exists(path)
	_report["modules"][label] = {"path": path, "resource_exists": exists, "loaded": false}
	if not exists:
		_check("module_" + label, false, "MODULE_MISSING " + path)
		if _status == "RUNNING":
			_status = "MODULE_MISSING"
		return null
	var loaded: Variant = load(path)
	if not (loaded is Script):
		_check("module_" + label, false, "load() returned %s for %s" % [typeof(loaded), path])
		if _status == "RUNNING":
			_status = "MODULE_LOAD_FAILED"
		return null
	var script: Script = loaded as Script
	if not script.can_instantiate():
		_check("module_" + label, false, "script cannot instantiate: " + path)
		if _status == "RUNNING":
			_status = "MODULE_LOAD_FAILED"
		return null
	_report["modules"][label]["loaded"] = true
	_check("module_" + label, true, path)
	return script


# --------------------------------------------------------------- reporting ----
func _check(name: String, passed: bool, detail: String = "") -> void:
	_checks.append({"name": name, "class": "A", "passed": passed, "detail": detail})
	if not passed:
		_ok = false
		_errors.append(name + ": " + detail)
	print("T_TERRAIN_DONOR_DIAG %s %s - %s" % ["PASS" if passed else "FAIL", name, detail])


func _observe(message: String) -> void:
	_observations.append(message)
	print("T_TERRAIN_DONOR_DIAG OBSERVATION: " + message)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	# Binding top-level guards, including the failsafe path.
	_report["id"] = ID
	_report["diagnostic_only"] = true
	_report["visual_parity_claim"] = false
	_report["parity"] = "UNVERIFIED — no donor GPU A/B frame; this is not a parity claim"
	_report["donor_files_used"] = false
	_report["synthetic_noise"] = false
	_report["synthetic_dither"] = false
	_report["output_dir"] = OUT_DIR
	_report["stats_file"] = OUT_DIR + "/stats.json"
	if _status == "RUNNING":
		_status = "PASS" if _ok else "FAIL"
	var passes: int = 0
	for entry in _checks:
		if bool(entry.get("passed", false)):
			passes += 1
	_report["status"] = _status
	_report["passed"] = _ok
	_report["passes"] = passes
	_report["total_checks"] = _checks.size()
	_report["checks"] = _checks.duplicate(true)
	_report["errors"] = _errors
	_report["observations"] = _observations
	_report["unix_ms"] = Time.get_unix_time_from_system() * 1000.0

	var json_text: String = JSON.stringify(_report, "\t")
	if json_text.is_empty():
		_status = "STATS_SERIALIZATION_FAILED"
		_ok = false
		push_error(ID + ": JSON.stringify returned an empty report")
	else:
		var stats_path: String = OUT_DIR + "/stats.json"
		var stats_err: Error = _write_text(stats_path, json_text)
		if stats_err != OK:
			_status = "STATS_WRITE_FAILED"
			_ok = false
			push_error(ID + ": cannot write " + stats_path + " err=" + str(stats_err))
	print("T_TERRAIN_DONOR_DIAG RESULT: %s %d/%d output=%s" % [_status, passes, _checks.size(), OUT_DIR])
	call_deferred("quit", 0 if _ok else 1)


# ------------------------------------------------------------- small helpers --
# Reads --size from Godot user args (everything after `--`). A token is accepted
# only when it exactly matches an allowed donor/port size; first valid wins.
func _parse_requested_size() -> int:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for i in range(args.size()):
		if str(args[i]) != "--size" or i + 1 >= args.size():
			continue
		var token: String = str(args[i + 1])
		for allowed in ALLOWED_SIZES:
			if token == str(allowed):
				return int(allowed)
	return DEFAULT_SIZE


func _object_int(obj: Object, key: String) -> int:
	if obj == null:
		return 0
	var value: Variant = obj.get(key)
	if value is int:
		return int(value)
	if value is float:
		return int(value)
	return 0


func _array_size(value: Variant) -> int:
	if value is PackedByteArray:
		return (value as PackedByteArray).size()
	if value is PackedFloat32Array:
		return (value as PackedFloat32Array).size()
	if value is Array:
		return (value as Array).size()
	if value is Dictionary:
		return (value as Dictionary).size()
	return 0


func _summarize_params(params: Dictionary) -> Dictionary:
	var patterns_value: Variant = params.get("patterns", {})
	var families_value: Variant = params.get("families", {})
	var starts_value: Variant = params.get("starts", [])
	var tile_ids_value: Variant = params.get("tile_name_to_id", null)
	return {
		"keys": params.keys(),
		"randkey0": params.get("randkey0", null),
		"randkey1": params.get("randkey1", null),
		"width": params.get("width", null),
		"height": params.get("height", null),
		"mask_b_bytes": _array_size(params.get("mask_b", null)),
		"patterns": (patterns_value as Dictionary).size() if patterns_value is Dictionary else 0,
		"families": (families_value as Dictionary).size() if families_value is Dictionary else 0,
		"starts": (starts_value as Array).size() if starts_value is Array else 0,
		"tile_name_to_id_entries": (tile_ids_value as Dictionary).size() if tile_ids_value is Dictionary else 0,
		"tile_smooth_chains": _array_size(params.get("tile_smooth_chains", null)),
		"visual_parity_claim": params.get("visual_parity_claim", null),
	}


func _extract_generation_ledger(gen: Object, telemetry: Dictionary) -> Array:
	var ledger_value: Variant = telemetry.get("rng_sites", null)
	if ledger_value is Array:
		return (ledger_value as Array).duplicate(true)
	if gen.has_method("rng_ledger"):
		var fallback_value: Variant = gen.call("rng_ledger")
		if fallback_value is Array:
			return (fallback_value as Array).duplicate(true)
	return []


func _ledger_has_end(ledger: Array) -> bool:
	for entry in ledger:
		if entry is Dictionary and str((entry as Dictionary).get("site", "")) == "END":
			return true
	return false


func _sha256(data: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(data)
	return context.finish().hex_encode()


func _f32_le(values: PackedFloat32Array) -> PackedByteArray:
	var raw := PackedByteArray()
	raw.resize(values.size() * 4)
	for i in range(values.size()):
		raw.encode_float(i * 4, values[i])
	return raw


func _write_bytes(path: String, data: PackedByteArray) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ERR_CANT_OPEN
	file.store_buffer(data)
	var err: Error = file.get_error()
	file.close()
	return err


func _write_text(path: String, text: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ERR_CANT_OPEN
	file.store_string(text)
	var err: Error = file.get_error()
	file.close()
	return err


func _record_artifact(name: String, path: String) -> void:
	if not FileAccess.file_exists(path):
		_check("artifact_" + name, false, "missing after write: " + path)
		return
	var data := FileAccess.get_file_as_bytes(path)
	_report["artifacts"][name] = {"path": path, "bytes": data.size(), "sha256": _sha256(data)}
	_check("artifact_nonempty_" + name, not data.is_empty(), "path=%s bytes=%d" % [path, data.size()])
	_check("artifact_" + name, true, "path=%s bytes=%d" % [path, data.size()])


# ---------------------------------------------------------- height metrics ----
func _height_metrics(values: PackedFloat32Array, w: int, h: int) -> Dictionary:
	var finite_values: Array[float] = []
	var finite_count: int = 0
	var nonfinite_count: int = 0
	var zero_count: int = 0
	var nonzero_count: int = 0
	var minimum: float = INF
	var maximum: float = -INF
	var mean: float = 0.0
	var m2: float = 0.0
	for i in range(values.size()):
		var value: float = values[i]
		if value == 0.0:
			zero_count += 1
		else:
			nonzero_count += 1
		if is_nan(value) or is_inf(value):
			nonfinite_count += 1
			continue
		finite_count += 1
		finite_values.append(value)
		minimum = minf(minimum, value)
		maximum = maxf(maximum, value)
		var delta: float = value - mean
		mean += delta / float(finite_count)
		m2 += delta * (value - mean)

	var sorted_values: Array = finite_values.duplicate()
	sorted_values.sort()
	var deciles: Array[float] = []
	if not sorted_values.is_empty():
		deciles.append(float(sorted_values[0]))
		for k in range(1, 10):
			var position: int = int(roundf(float(k) * float(sorted_values.size() - 1) / 10.0))
			deciles.append(float(sorted_values[clampi(position, 0, sorted_values.size() - 1)]))
		deciles.append(float(sorted_values[sorted_values.size() - 1]))

	var row_sums: Array[float] = []
	var row_counts: Array[int] = []
	var col_sums: Array[float] = []
	var col_counts: Array[int] = []
	row_sums.resize(h)
	row_counts.resize(h)
	col_sums.resize(w)
	col_counts.resize(w)
	for y in range(h):
		row_sums[y] = 0.0
		row_counts[y] = 0
	for x in range(w):
		col_sums[x] = 0.0
		col_counts[x] = 0
	for y in range(h):
		for x in range(w):
			var value: float = values[y * w + x]
			if is_nan(value) or is_inf(value):
				continue
			row_sums[y] += value
			row_counts[y] += 1
			col_sums[x] += value
			col_counts[x] += 1
	var row_means: Array[float] = []
	var col_means: Array[float] = []
	for y in range(h):
		row_means.append(row_sums[y] / float(row_counts[y]) if row_counts[y] > 0 else 0.0)
	for x in range(w):
		col_means.append(col_sums[x] / float(col_counts[x]) if col_counts[x] > 0 else 0.0)

	var max_delta: float = 0.0
	var max_delta_info: Dictionary = {}
	var adjacent_pairs: int = 0
	var skipped_pairs: int = 0
	for y in range(h):
		for x in range(w):
			var index: int = y * w + x
			for neighbour in [Vector2i(x + 1, y), Vector2i(x, y + 1)]:
				var nx: int = (neighbour as Vector2i).x
				var ny: int = (neighbour as Vector2i).y
				if nx < 0 or nx >= w or ny < 0 or ny >= h:
					continue
				var a: float = values[index]
				var b: float = values[ny * w + nx]
				if is_nan(a) or is_inf(a) or is_nan(b) or is_inf(b):
					skipped_pairs += 1
					continue
				var delta: float = absf(a - b)
				if adjacent_pairs == 0 or delta > max_delta:
					max_delta = delta
					max_delta_info = {
						"x": x, "y": y, "neighbour_x": nx, "neighbour_y": ny,
						"height_a": a, "height_b": b, "signed_delta_b_minus_a": b - a,
					}
				adjacent_pairs += 1

	var stddev: float = sqrt(maxf(0.0, m2 / float(finite_count))) if finite_count > 0 else 0.0
	return {
		"min": minimum if finite_count > 0 else null,
		"max": maximum if finite_count > 0 else null,
		"mean": mean if finite_count > 0 else null,
		"std": stddev if finite_count > 0 else null,
		"std_definition": "population standard deviation over finite cells: sqrt(sum((x-mean)^2)/N)",
		"finite": finite_count,
		"nonfinite": nonfinite_count,
		"all_finite": nonfinite_count == 0,
		"zero": zero_count,
		"nonzero": nonzero_count,
		"deciles": deciles,
		"deciles_definition": "[min,d1..d9,max]; rounded nearest index over sorted finite cells",
		"row_means": row_means,
		"row_finite_counts": row_counts,
		"col_means": col_means,
		"col_finite_counts": col_counts,
		"row_col_means_definition": "arithmetic mean of finite float32 cells; 0.0 only when a row/column has no finite cell",
		"max_adjacent_delta": max_delta if adjacent_pairs > 0 else null,
		"max_adjacent_delta_definition": "maximum absolute height difference over in-bounds 4-neighbour pairs; no wrap",
		"max_adjacent_delta_info": max_delta_info if adjacent_pairs > 0 else null,
		"adjacent_pairs_checked": adjacent_pairs,
		"adjacent_pairs_skipped_nonfinite": skipped_pairs,
	}


# --------------------------------------------------------- array histograms ---
func _byte_counts(values: PackedByteArray) -> Dictionary:
	var zero_count: int = 0
	for value in values:
		if int(value) == 0:
			zero_count += 1
	return {"total": values.size(), "zero": zero_count, "nonzero": values.size() - zero_count}


func _byte_counts_from_height(values: PackedFloat32Array) -> Dictionary:
	var zero_count: int = 0
	var nonfinite_count: int = 0
	for i in range(values.size()):
		var v: float = values[i]
		if is_nan(v) or is_inf(v):
			nonfinite_count += 1
		elif v == 0.0:
			zero_count += 1
	return {
		"total": values.size(),
		"zero": zero_count,
		"nonzero": values.size() - zero_count,
		"nonfinite": nonfinite_count,
		"zero_definition": "exact float comparison to 0.0; NaN/INF count as nonzero",
	}


func _collision_cell_counts(values: PackedByteArray) -> Dictionary:
	var cells: int = values.size() / COLLISION_TAGS
	var any_tag: int = 0
	var all_clear: int = 0
	for i in range(cells):
		var occupied: bool = false
		for tag in range(COLLISION_TAGS):
			if int(values[i * COLLISION_TAGS + tag]) != 0:
				occupied = true
				break
		if occupied:
			any_tag += 1
		else:
			all_clear += 1
	return {"total": cells, "any_nonzero_tag": any_tag, "all_four_tags_zero": all_clear}


func _byte_histogram(values: PackedByteArray) -> Dictionary:
	var histogram: Dictionary = {}
	for value in values:
		var key: String = str(int(value))
		histogram[key] = int(histogram.get(key, 0)) + 1
	return histogram


func _sorted_histogram(histogram: Dictionary) -> Dictionary:
	var ids: Array[int] = []
	for key in histogram.keys():
		ids.append(int(key))
	ids.sort()
	var sorted: Dictionary = {}
	for id in ids:
		sorted[str(id)] = histogram[str(id)]
	return sorted


func _tile_report(values: PackedByteArray) -> Dictionary:
	var histogram: Dictionary = _byte_histogram(values)
	var out_of_atlas: int = 0
	var sentinel_count: int = 0
	for value in values:
		var id: int = int(value)
		if id > TILE_ID_MAX:
			out_of_atlas += 1
		if id == 255:
			sentinel_count += 1
	return {
		"histogram": _sorted_histogram(histogram),
		"distinct_ids": histogram.size(),
		"out_of_atlas_count": out_of_atlas,
		"port_sentinel_255_count": sentinel_count,
		"id_note": "donor ids [0,123]; 255 is PORT-ONLY water sentinel, never asserted as a donor id",
	}


func _collision_report(values: PackedByteArray) -> Dictionary:
	var tag0_histogram: Dictionary = {}
	var cells: int = values.size() / COLLISION_TAGS
	for i in range(cells):
		var key: String = str(int(values[i * COLLISION_TAGS]))
		tag0_histogram[key] = int(tag0_histogram.get(key, 0)) + 1
	return {
		"bytes_per_cell": COLLISION_TAGS,
		"tag0_histogram": _sorted_histogram(tag0_histogram),
		"all_tag_bytes_histogram": _sorted_histogram(_byte_histogram(values)),
		"layout": "u8[4] per height cell is PORT narrowing [U]; tag0 is the populated water/cliff gate",
	}


# ------------------------------------------------------------- water counts ---
func _water_report(water: PackedByteArray, height: PackedFloat32Array) -> Dictionary:
	var deep: int = 0
	var shore: int = 0
	var land: int = 0
	var other: int = 0
	for value in water:
		var flag: int = int(value)
		if flag == 2:
			deep += 1
		elif flag == 1:
			shore += 1
		elif flag == 0:
			land += 1
		else:
			other += 1
	var height_deep: int = 0
	var height_shore: int = 0
	var height_land: int = 0
	var height_nonfinite: int = 0
	for value in height:
		var v: float = value
		if is_nan(v) or is_inf(v):
			height_nonfinite += 1
		elif v < WATER_DEEP:
			height_deep += 1
		elif v < WATER_SHORE:
			height_shore += 1
		else:
			height_land += 1
	return {
		"stored_counts": {"deep": deep, "shore": shore, "land": land, "other": other, "total": water.size()},
		"stored_source": "I06 water side array populated by I07 mask-gated tri-state classification (PORT APPROX flag)",
		"height_threshold_counts": {"deep": height_deep, "shore": height_shore, "land": height_land,
				"nonfinite": height_nonfinite, "total": height.size()},
		"height_threshold_source": "diagnostic only: deep h<%.2f; shore %.2f<=h<%.2f; land h>=%.2f"
				% [WATER_DEEP, WATER_DEEP, WATER_SHORE, WATER_SHORE],
		"thresholds": {"deep": WATER_DEEP, "shore": WATER_SHORE},
	}


# ---------------------------------------------------------- ASCII / PNG maps --
func _ascii_heightmap(values: PackedFloat32Array, w: int, h: int, metrics: Dictionary) -> Dictionary:
	var out_w: int = mini(w, ASCII_CAP)
	var out_h: int = mini(h, ASCII_CAP)
	var minimum_value: Variant = metrics.get("min", null)
	var maximum_value: Variant = metrics.get("max", null)
	var has_range: bool = minimum_value is float and maximum_value is float \
			and float(maximum_value) > float(minimum_value)
	var text: String = ""
	for oy in range(out_h):
		var y0: int = int(floor(float(oy) * float(h) / float(out_h)))
		var y1: int = maxi(y0 + 1, int(floor(float(oy + 1) * float(h) / float(out_h))))
		var row: String = ""
		for ox in range(out_w):
			var x0: int = int(floor(float(ox) * float(w) / float(out_w)))
			var x1: int = maxi(x0 + 1, int(floor(float(ox + 1) * float(w) / float(out_w))))
			var sum: float = 0.0
			var count: int = 0
			for y in range(y0, mini(y1, h)):
				for x in range(x0, mini(x1, w)):
					var value: float = values[y * w + x]
					if is_nan(value) or is_inf(value):
						continue
					sum += value
					count += 1
			if count == 0:
				row += "?"
			elif not has_range:
				row += "~"
			else:
				var mean: float = sum / float(count)
				var t: float = clampf((mean - float(minimum_value)) / (float(maximum_value) - float(minimum_value)), 0.0, 1.0)
				var ramp_index: int = clampi(int(floor(t * float(ASCII_RAMP.length() - 1))), 0, ASCII_RAMP.length() - 1)
				row += ASCII_RAMP.substr(ramp_index, 1)
		text += row
		if oy + 1 < out_h:
			text += "\n"
	return {"text": text, "width": out_w, "height": out_h}


func _height_image(values: PackedFloat32Array, w: int, h: int,
		minimum_value: Variant, maximum_value: Variant) -> Image:
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var has_range: bool = minimum_value is float and maximum_value is float \
			and float(maximum_value) > float(minimum_value)
	for y in range(h):
		for x in range(w):
			var value: float = values[y * w + x]
			if is_nan(value) or is_inf(value):
				image.set_pixel(x, y, Color(1.0, 0.0, 1.0, 1.0))
				continue
			var t: float = 0.5
			if has_range:
				t = clampf((value - float(minimum_value)) / (float(maximum_value) - float(minimum_value)), 0.0, 1.0)
			var gray: float = float(int(round(t * 255.0))) / 255.0
			image.set_pixel(x, y, Color(gray, gray, gray, 1.0))
	return image


func _tile_image(values: PackedByteArray, w: int, h: int) -> Image:
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			var intensity: float = float(int(values[y * w + x])) / 255.0
			image.set_pixel(x, y, Color(intensity, intensity, intensity, 1.0))
	return image
