# Small test: animation duration/metrics across the roster (board P-26).
# Data-only test: reads the baked anim metrics indexes and asserts the schema
# and numeric ranges every unit/action is expected to satisfy. No world state.
# A red result here means the generated metric data is unhealthy, not a test bug.
#
# P-45 adjudication (decision D-22, docs/audit/ANIM_ADJUDICATION.md): the three
# original thresholds were GUIDE4 eyeball heuristics for a standing peasant walk,
# not universal laws. They are narrowed to donor-measured, per-class bands below;
# no value in index.json was changed to make this test green.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-anim-metrics --timeout 90 -- \
#       --headless --path app --script res://tests/t_anim_metrics.gd
extends SceneTree

const OUT_DIR := "res://tests/results"
const MAIN_PATH := "res://assets/models/anim/index.json"
const NAVAL_PATH := "res://assets/models/anim/naval/index.json"

# ADJ-P45 / P-45: the single `duration = frames*0.09` rule came from GUIDE4
# DO-L7.06, but DO-L7.08 assigns DIFFERENT cadences to cavalry and artillery,
# and the baker writes donor AAF range / 30 fps (bake_sprites.py:246).
# Observed: 45/54 walks are donor-exact; the other 9 are the explicit DO-L7.06
# n*0.09 peasant correction. Bands are SECONDS FOR A 12-FRAME walk, one per
# donor-measured class (citations in docs/audit/ANIM_ADJUDICATION.md); they scale
# linearly for any other frame count. Each is tight enough to still catch the
# 0.05 s min-clamp hyper-flap DO-L7.02 warns about.
const WALK_CADENCE := {
	"march": [0.78, 0.85],   # pikeman.aaf walk 1..24 /30 = 0.8; cossackregister.aaf 614..638 /30 = 0.833
	"gallop": [0.52, 0.58],  # hussar/wingedhussar walk 1..16 /30 = 0.533; hackapell/croat 1..17 /30 = 0.567
	"cossack": [1.55, 1.65], # cossacksich.aaf walk 1..48 /30 = 1.6 (DO-L7.08 fast cav)
	"siege": [3.25, 3.35],   # cannon/howitzer/mortar/multicannon walk 1..99 /30 = 3.3 (DO-L7.08 slow roll)
	"peasant": [1.06, 1.10], # DO-L7.06 n*0.09 = 1.08 correction (donor peaukr walk 1..20 /30 = 0.667)
}
# These four donors define idle as a single pose (AAF idle 1..1): a 1-frame,
# 0.033 s static idle is a faithful bake, not the DO-L7.01 "skate" bake failure.
const STATIC_ARTILLERY_IDLE := ["cannon", "howitzer", "mortar", "multicannon"]
# foot = y1/cell = bottom of the per-action ink bbox (DO-L7.04). Lying death
# poses, weapon swings and rolling siege poses legitimately sit outside the
# standing-man eyeball band 0.70..0.90 of DO-L7.02. Exact-method Pillow
# re-measure reproduced all 299 stored values from the PNG pixels (0 mismatches):
# measured pose envelope 0.6813..0.95, plus 0.02 rounding margin.
const FOOT_MIN := 0.66
const FOOT_MAX := 0.96

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

func _walk_class(key: String) -> String:
	if key == "peasant" or key.ends_with("_peasant"):
		return "peasant"
	if key.find("hussar") >= 0 or key == "hackapell" or key == "croat":
		return "gallop"
	if key == "cossack":
		return "cossack"
	if STATIC_ARTILLERY_IDLE.has(key):
		return "siege"
	return "march"

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
			var fr_ok := _is_num(fr) and float(fr) >= 2.0
			# DO-L7.01's single-row prohibition guards WALK sheets (skate).
			# The four siege donors have a literally static idle (AAF idle 1..1),
			# so frames=1 / 0.033 s is faithful for those idles only.
			if aname == "idle" and STATIC_ARTILLERY_IDLE.has(str(key)) and _is_num(fr) and float(fr) == 1.0:
				fr_ok = true
			if not fr_ok:
				reasons.append("frames=%s" % str(fr))
			if not ((v as Dictionary).get("loop") is bool):
				reasons.append("loop-not-bool")
			if not reasons.is_empty():
				struct_bad.append("%s/%s[%s]" % [str(key), str(aname), str(reasons)])
	check("action_structure", struct_bad.is_empty(),
		"actions=%d, out-of-spec=%d (duration>0, frames>=2 except donor-static siege idle, loop bool): %s"
		% [action_count, struct_bad.size(), str(struct_bad)])

	# 3) Metric ranges: fig_h 0.30..0.95, foot measured pose band, cx 0.40..0.60.
	# fig_h is still the G1 tiny-men guard (1.0 default excluded); foot is only
	# the render anchor fallback (world.gd prefers ax/ay), so its band follows
	# the measured pose envelope rather than a standing-man eyeball estimate.
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
			if not _is_num(ft) or not (FOOT_MIN <= float(ft) and float(ft) <= FOOT_MAX):
				reasons.append("foot=%s" % str(ft))
			var cx: Variant = (v as Dictionary).get("cx")
			if not _is_num(cx) or not (0.40 <= float(cx) and float(cx) <= 0.60):
				reasons.append("cx=%s" % str(cx))
			if not reasons.is_empty():
				metric_bad.append("%s/%s[%s]" % [str(key), str(aname), str(reasons)])
	check("metric_ranges", metric_bad.is_empty(),
		"out-of-range actions=%d (fig_h 0.30..0.95, foot %.2f..%.2f measured pose band, cx 0.40..0.60): %s"
		% [metric_bad.size(), FOOT_MIN, FOOT_MAX, str(metric_bad)])

	# 4) Walk cadence: donor AAF range / 30 fps per class, not a single n*0.09.
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
		var klass := _walk_class(str(key))
		var band: Variant = WALK_CADENCE[klass]
		# Bands are calibrated for 12 sampled frames; scale for any other count.
		var scale := float(fr) / 12.0
		var lo := float(band[0]) * scale
		var hi := float(band[1]) * scale
		if dur < lo or dur > hi:
			walk_bad.append("%s[%s](frames=%d,dur=%s,band=%.3f..%.3f)"
				% [str(key), klass, fr, str(dur), lo, hi])
	check("walk_stride", walk_bad.is_empty(),
		"walks checked=%d, donor-class cadence bands, out-of-band=%d: %s"
		% [walk_count, walk_bad.size(), str(walk_bad)])

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
