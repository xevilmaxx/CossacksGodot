# Small test: animation duration/metrics across the roster (board P-26).
# Data-only test: reads the baked anim metrics indexes and asserts the schema
# and numeric ranges every unit/action is expected to satisfy. No world state.
# A red result here means the generated metric data is unhealthy, not a test bug.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-anim-metrics --timeout 90 -- \
#       --headless --path app --script res://tests/t_anim_metrics.gd
extends SceneTree

const OUT_DIR := "res://tests/results"
const MAIN_PATH := "res://assets/models/anim/index.json"
const NAVAL_PATH := "res://assets/models/anim/naval/index.json"

# Nominal walk stride is 0.09 s per frame. Tolerance is 0.15 s absolute
# (~ +/-0.0125 s/frame for a 12-frame walk): loose enough for rounding,
# tight enough to catch a mis-baked duration.
const WALK_STRIDE_TOL := 0.15

# Full action-level schema, mirroring the main roster index.
const REQUIRED_FIELDS := [
	"frames", "duration", "loop", "ortho", "center", "ax", "ay",
	"tool", "bbox", "fig_h", "foot", "cx",
]

var _id := "t_anim_metrics"
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

func _load_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("cannot open " + path)
		return null
	var txt := f.get_as_text()
	f.close()
	return JSON.parse_string(txt)

func _is_num(v: Variant) -> bool:
	return (v is float) or (v is int)

func _initialize() -> void:
	var parsed_main: Variant = _load_json(MAIN_PATH)
	var parsed_naval: Variant = _load_json(NAVAL_PATH)
	var main: Dictionary = parsed_main if parsed_main is Dictionary else {}
	var naval: Dictionary = parsed_naval if parsed_naval is Dictionary else {}

	# 1) Main index loads and covers all 54 roster units.
	check("main_index_54_units", not main.is_empty() and main.size() == 54,
		"parsed=%s, unit keys=%d (expect 54)" % [str(parsed_main is Dictionary), main.size()])

	# 2) Structural fields: duration > 0, frames >= 2, loop is bool.
	var struct_bad: Array[String] = []
	var action_count := 0
	for key in main:
		var u: Variant = main[key]
		if not (u is Dictionary):
			struct_bad.append("%s:unit-not-dict" % str(key))
			continue
		var acts: Variant = (u as Dictionary).get("actions", {})
		if not (acts is Dictionary):
			struct_bad.append("%s:actions-not-dict" % str(key))
			continue
		for aname in acts:
			action_count += 1
			var v: Variant = acts[aname]
			if not (v is Dictionary):
				struct_bad.append("%s/%s:not-dict" % [str(key), str(aname)])
				continue
			var reasons: Array[String] = []
			var dur: Variant = (v as Dictionary).get("duration")
			if not _is_num(dur) or float(dur) <= 0.0:
				reasons.append("duration=%s" % str(dur))
			var fr: Variant = (v as Dictionary).get("frames")
			if not _is_num(fr) or float(fr) < 2:
				reasons.append("frames=%s" % str(fr))
			if not ((v as Dictionary).get("loop") is bool):
				reasons.append("loop-not-bool")
			if not reasons.is_empty():
				struct_bad.append("%s/%s[%s]" % [str(key), str(aname), str(reasons)])
	check("action_structure", struct_bad.is_empty(),
		"actions=%d, out-of-spec=%d (duration>0, frames>=2, loop bool): %s"
		% [action_count, struct_bad.size(), str(struct_bad)])

	# 3) Metric ranges: fig_h 0.30..0.95, foot 0.70..0.90, cx 0.40..0.60.
	var metric_bad: Array[String] = []
	for key in main:
		var u: Variant = main[key]
		var acts: Variant = u.get("actions", {}) if u is Dictionary else {}
		if not (acts is Dictionary):
			continue
		for aname in acts:
			var v: Variant = acts[aname]
			if not (v is Dictionary):
				continue
			var reasons: Array[String] = []
			var fh: Variant = (v as Dictionary).get("fig_h")
			if not _is_num(fh) or not (0.30 <= float(fh) and float(fh) <= 0.95):
				reasons.append("fig_h=%s" % str(fh))
			var ft: Variant = (v as Dictionary).get("foot")
			if not _is_num(ft) or not (0.70 <= float(ft) and float(ft) <= 0.90):
				reasons.append("foot=%s" % str(ft))
			var cx: Variant = (v as Dictionary).get("cx")
			if not _is_num(cx) or not (0.40 <= float(cx) and float(cx) <= 0.60):
				reasons.append("cx=%s" % str(cx))
			if not reasons.is_empty():
				metric_bad.append("%s/%s[%s]" % [str(key), str(aname), str(reasons)])
	check("metric_ranges", metric_bad.is_empty(),
		"out-of-range actions=%d (fig_h 0.30..0.95, foot 0.70..0.90, cx 0.40..0.60): %s"
		% [metric_bad.size(), str(metric_bad)])

	# 4) Walk stride: duration ~= frames * 0.09 within WALK_STRIDE_TOL.
	var walk_bad: Array[String] = []
	var walk_count := 0
	for key in main:
		var u: Variant = main[key]
		var acts: Variant = u.get("actions", {}) if u is Dictionary else {}
		var w: Variant = acts.get("walk") if acts is Dictionary else null
		if not (w is Dictionary):
			continue
		walk_count += 1
		var fr := int((w as Dictionary).get("frames", 0))
		var dur := float((w as Dictionary).get("duration", 0.0))
		var expect := float(fr) * 0.09
		var diff: float = absf(dur - expect)
		if diff > WALK_STRIDE_TOL:
			walk_bad.append("%s(frames=%d,dur=%s,expect=%.3f,diff=%.3f)"
				% [str(key), fr, str(dur), expect, diff])
	check("walk_stride", walk_bad.is_empty(),
		"walks checked=%d, tol=%.3f, out-of-tolerance=%d: %s"
		% [walk_count, WALK_STRIDE_TOL, walk_bad.size(), str(walk_bad)])

	# 5) Naval index uses the same action-level schema.
	var naval_bad: Array[String] = []
	if parsed_naval is Dictionary:
		for key in naval:
			var u: Variant = naval[key]
			var acts: Variant = u.get("actions", {}) if u is Dictionary else {}
			if not (acts is Dictionary):
				naval_bad.append("%s:actions-not-dict" % str(key))
				continue
			for aname in acts:
				var v: Variant = acts[aname]
				var missing: Array[String] = []
				for fld in REQUIRED_FIELDS:
					if not (v is Dictionary and (v as Dictionary).has(str(fld))):
						missing.append(str(fld))
				if not missing.is_empty():
					naval_bad.append("%s/%s missing=%s"
						% [str(key), str(aname), str(missing)])
	else:
		naval_bad.append("naval index did not parse as a Dictionary")
	check("naval_schema", not naval.is_empty() and naval_bad.is_empty(),
		"naval units=%d, schema deviations=%d: %s"
		% [naval.size(), naval_bad.size(), str(naval_bad)])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
