# V7-32 atomic test — res://scripts/camera3d.gd API surface.
# Owner: V7-32. Owns exactly this file (+ its report). TABS per contract.
# Contract: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:10,26-30,37
# Donor evidence: docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md
#   §2a + claim 1: main view perspective, tilt -32 deg, dolly 20..58 m,
#   focal 400. camera.cfg:6-10 (SphereHeight 58 / SphereHeightMin 20),
#   :32-35 (four tilt slots -32), :44-45 (Min/MaxFocalLength 400).
# If the module is absent, this FAILs loudly with MODULE_MISSING and
# BLOCKED-PENDING-MODULE; no assertion is weakened or skipped silently.
extends SceneTree

const MODULE_PATH := "res://scripts/camera3d.gd"
const DONOR_CFG := "C:/Games/Cossacks 3/data/cameras/camera.cfg"
const VIEW_W := 1280
const VIEW_H := 720
const PX_TOL := 1.0           # screen -> world -> screen must land within 1 px
const TILT_TOL_DEG := 0.5
const BOUND_TOL := 1.0e-3
const STEP_EPS := 1.0e-6

var _pass := 0
var _fail := 0


class MockGame extends Node:
	var MAP_W := 320
	var MAP_H := 320
	var map_w := 320
	var map_h := 320
	var view_scale := 1.0
	var height := PackedFloat32Array()


func _report(name: String, ok: bool, detail: String = "") -> void:
	if ok:
		_pass += 1
		print("PASS ", name, " — ", detail)
	else:
		_fail += 1
		print("FAIL ", name, " — ", detail)


func _module_missing(why: String) -> void:
	print("FAIL MODULE_MISSING — ", MODULE_PATH, " (", why, ")")
	print("STATUS BLOCKED-PENDING-MODULE — camera3d.gd has not landed; assertions NOT weakened")
	print("T_CAMERA3D FAIL 0 checks (module missing)")
	call_deferred("quit", 1)


func _donor_constants() -> Dictionary:
	# Donor cfg is read at runtime when reachable; the checked-in constant below
	# is the same value observed in G31 (camera.cfg:6-10,32-35).
	var out := {
		"tilt_deg": -32.0,
		"h_min": 20.0,
		"h_max": 58.0,
		"source": "G31 report fallback (camera.cfg:6-10,32-35)",
	}
	var f := FileAccess.open(DONOR_CFG, FileAccess.READ)
	if f == null:
		return out
	var text := f.get_as_text()
	f.close()
	var got_tilt := false
	var got_hmin := false
	var got_hmax := false
	for raw in text.split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("//") or line.begins_with("#"):
			continue
		var eq := line.find("=")
		if eq < 0:
			continue
		var key := line.substr(0, eq).strip_edges()
		var val := line.substr(eq + 1).strip_edges()
		if key == "MinHeightMinAngle" and not got_tilt:
			out["tilt_deg"] = val.to_float()
			got_tilt = true
		elif key == "SphereHeightMin" and not got_hmin:
			out["h_min"] = val.to_float()
			got_hmin = true
		elif key == "SphereHeight" and not got_hmax:
			out["h_max"] = val.to_float()
			got_hmax = true
	out["source"] = "runtime donor camera.cfg (tilt=%s h=%s..%s)" % [
		str(out["tilt_deg"]), str(out["h_min"]), str(out["h_max"])]
	return out


func _tilt_signed_deg(cam: Camera3D) -> float:
	# Camera3D looks down local -Z. A view pointing down yields negative donor
	# tilt (donor FreeRotationInfo angles are all -32).
	var fwd: Vector3 = -cam.global_transform.basis.z.normalized()
	return -rad_to_deg(asin(clampf(-fwd.y, -1.0, 1.0)))


func _initialize() -> void:
	print("T_CAMERA3D start ", MODULE_PATH)
	if not ResourceLoader.exists(MODULE_PATH):
		_module_missing("ResourceLoader.exists() == false")
		return
	var script: Script = load(MODULE_PATH) as Script
	if script == null:
		_module_missing("load() returned null")
		return

	var inst: Object = script.new()
	if inst == null or not (inst is Camera3D):
		var cls := "null" if inst == null else inst.get_class()
		_report("MODULE_IS_CAMERA3D", false, "instance class=" + cls)
		_finish()
		return
	_report("MODULE_IS_CAMERA3D", true, "instance class=" + inst.get_class())

	var donor := _donor_constants()
	print("INFO donor constants: ", donor)

	var root := get_root()
	if root != null:
		root.size = Vector2i(VIEW_W, VIEW_H)
	var game := MockGame.new()
	if root != null:
		root.add_child(game)

	var cam := inst as Camera3D
	if root != null:
		root.add_child(cam)
	cam.call("bind", game, 1.0)
	cam.make_current()

	# --- Declared API surface -------------------------------------------------
	var required := ["bind", "world_to_px", "screen_to_world", "clamp_pos",
		"get_view_rect", "get_viewport_corners", "zoom_step", "set_zoom_target"]
	var missing: Array[String] = []
	for m in required:
		if not cam.has_method(m):
			missing.append(m)
	_report("API_SURFACE", missing.is_empty(),
		"missing=" + str(missing) if not missing.is_empty() else "all 8 contract methods present")
	_report("API_VIEW_SCALE", cam.get("view_scale") != null,
		"view_scale=" + str(cam.get("view_scale")))
	var z0 = cam.get("zoom_target")
	if not (z0 is float or z0 is int):
		_report("API_ZOOM_TARGET", false, "zoom_target missing/non-numeric: " + str(z0))
		_finish()
		return
	_report("API_ZOOM_TARGET", true, "zoom_target=" + str(z0))

	# --- Donor projection and tilt -------------------------------------------
	_report("PROJECTION_PERSPECTIVE",
		cam.projection == Camera3D.PROJECTION_PERSPECTIVE,
		"projection=" + str(cam.projection))
	var want_tilt := float(donor["tilt_deg"])
	var got_tilt := _tilt_signed_deg(cam)
	_report("TILT_NEG32", absf(got_tilt - want_tilt) <= TILT_TOL_DEG,
		"tilt=%.3f deg want=%.3f deg source=%s" % [got_tilt, want_tilt, str(donor["source"])])

	# --- screen -> world -> screen at 3 deterministic points ------------------
	var pts := [Vector2(VIEW_W * 0.5, VIEW_H * 0.5),
		Vector2(VIEW_W * 0.25, VIEW_H * 0.75),
		Vector2(VIEW_W * 0.75, VIEW_H * 0.85)]
	for i in range(pts.size()):
		var p: Vector2 = pts[i]
		var w = cam.call("screen_to_world", p)
		var p2 = cam.call("world_to_px", w)
		var finite := w is Vector2 and p2 is Vector2
		if finite:
			var pv := p2 as Vector2
			finite = not is_nan(pv.x) and not is_inf(pv.x) and not is_nan(pv.y) and not is_inf(pv.y)
		var err: Vector2 = Vector2.INF if not (p2 is Vector2) else (p2 as Vector2) - p
		var ok := finite and absf(err.x) <= PX_TOL and absf(err.y) <= PX_TOL
		_report("ROUNDTRIP_P%d" % (i + 1), ok,
			"screen=%s world=%s back=%s err=%s tol=%.1fpx" % [str(p), str(w), str(p2), str(err), PX_TOL])

	# --- Minimap ground box ---------------------------------------------------
	var corners = cam.call("get_viewport_corners")
	var ncorner := -1
	if corners is Array:
		ncorner = (corners as Array).size()
	_report("VIEWPORT_CORNERS_4", ncorner == 4,
		"get_viewport_corners().size()=" + str(ncorner))
	var rect = cam.call("get_view_rect")
	var rect_ok := rect is Rect2 and (rect as Rect2).size.x > 0.0 and (rect as Rect2).size.y > 0.0
	_report("VIEW_RECT_NONEMPTY", rect_ok, "get_view_rect()=" + str(rect))

	# --- Donor zoom bounds (SphereHeight 58 / SphereHeightMin 20) --------------
	var h_min := float(donor["h_min"])
	var h_max := float(donor["h_max"])
	var z_min := h_min / h_max
	var z_max := h_max / h_min
	cam.call("set_zoom_target", 1.0e9, true)
	var z_hi = cam.get("zoom_target")
	cam.call("set_zoom_target", 1.0e-9, true)
	var z_lo = cam.get("zoom_target")
	var clamp_ok := false
	if z_hi is float and z_lo is float:
		clamp_ok = absf(float(z_hi) - z_max) <= BOUND_TOL and absf(float(z_lo) - z_min) <= BOUND_TOL
	_report("ZOOM_CLAMP_DONOR", clamp_ok,
		"clamped=[%s, %s] donor_zoom=[%.6f, %.6f] donor_h=%.1f..%.1f m" % [
			str(z_hi), str(z_lo), z_min, z_max, h_min, h_max])

	var bound_detail := ""
	var bound_ok := true
	if cam.get("min_zoom") != null and cam.get("max_zoom") != null:
		bound_ok = absf(float(cam.get("min_zoom")) - z_min) <= BOUND_TOL and \
			absf(float(cam.get("max_zoom")) - z_max) <= BOUND_TOL
		bound_detail = "min_zoom=%s max_zoom=%s donor=[%.6f, %.6f]" % [
			str(cam.get("min_zoom")), str(cam.get("max_zoom")), z_min, z_max]
	elif cam.get("min_height") != null and cam.get("max_height") != null:
		bound_ok = absf(float(cam.get("min_height")) - h_min) <= BOUND_TOL and \
			absf(float(cam.get("max_height")) - h_max) <= BOUND_TOL
		bound_detail = "min_height=%s max_height=%s donor=[%.1f, %.1f] m" % [
			str(cam.get("min_height")), str(cam.get("max_height")), h_min, h_max]
	else:
		bound_detail = "no bound properties; ZOOM_CLAMP_DONOR verifies bounds behaviorally"
	_report("BOUNDS_MATCH_DONOR", bound_ok, bound_detail)

	# --- zoom_step monotone target movement -----------------------------------
	var base := (z_min + z_max) * 0.5
	cam.call("set_zoom_target", base, true)
	var seq: Array[float] = [float(cam.get("zoom_target"))]
	var anchor := Vector2(VIEW_W * 0.5, VIEW_H * 0.5)
	for _k in range(3):
		cam.call("zoom_step", 0.5, anchor)
		seq.append(float(cam.get("zoom_target")))
	for _k in range(3):
		cam.call("zoom_step", -0.5, anchor)
		seq.append(float(cam.get("zoom_target")))
	var mono_in := seq[1] > seq[0] + STEP_EPS and seq[2] > seq[1] + STEP_EPS and seq[3] > seq[2] + STEP_EPS
	var mono_out := seq[4] < seq[3] - STEP_EPS and seq[5] < seq[4] - STEP_EPS and seq[6] < seq[5] - STEP_EPS
	_report("ZOOM_STEP_MONOTONIC", mono_in and mono_out,
		"targets=%s (3x +0.5 notch then 3x -0.5)" % str(seq))

	_finish()


func _finish() -> void:
	print("T_CAMERA3D %s %d/%d checks" % ["PASS" if _fail == 0 else "FAIL", _pass, _pass + _fail])
	call_deferred("quit", 0 if _fail == 0 else 1)
