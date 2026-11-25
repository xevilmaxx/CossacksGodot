# HUD-LAYOUT-01 / t_hud_layout.gd — responsive top-bar layout atom.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_01.md).
# AUTHORING ONLY: this file was never executed by this agent; no Godot job was
# submitted, no runner ticket was opened, no PASS is claimed. No shared code was
# edited. UI-TOPBAR-01 owns hud.gd; LOAD-ASYNC-01 owns main.gd.
#
# Boots the REAL game through res://scenes/main.tscn with the committed 64²
# fixture (the same boot form as t_smallmap_terrain.gd:9-16,213-224), disables
# main's own screenshot saver, re-shows the HUD (main.gd:1125-1126 hides it in
# --screenshot mode), then resizes the root viewport through THREE sizes and
# re-runs the HUD's own resize hook (hud.gd:273-275). One boot / three resizes
# keeps the same map, seed and game state, so a difference between sizes is
# attributable to layout alone (TEST_01_smallmap_harness.md:11-12,183-189).
#
# Sources (read-only citations used by the assertions below):
#   variant3d/scripts/hud.gd:17,112-114,273-275,301-326,390-457,480-500,505-512,590-601
#       (top panel, OptionButton speed menu, resource icons/labels, resize hook)
#   variant3d/scripts/hud.gd:283-299,327-333,1519-1596 (minimap slot/anchors)
#   variant3d/scripts/data.gd:25-26,113-114 (six resources, base window size)
#   variant3d/scripts/config.gd:751-754 (ui_scale_for = clamp(min(w/1280,h/720),.75,2.5))
#   variant3d/scripts/main.gd:171-172,199-244,1110-1132,1125-1126,1307-1310,1699-1701,1818-1884
#       (user-arg parsing, fixture boot, HUD bind, screenshot-mode side effects)
#   variant3d/scripts/testbridge.gd:103-105 (root.size resize precedent)
#   variant3d/project.godot:18-19 (canvas_items stretch, 1280x720 base;
#       HUD-LAYOUT-REPAIR-01 harness retargets content_scale_size per size)
#   variant3d/tests/_template_test.gd:1-38 (one file / one verdict / deferred quit)
#   variant3d/tests/t_smallmap_terrain.gd:42-111,174-231 (real-boot atom pattern)
#   variant3d/tests/t_terrain_only.gd:175-246,648-679 (SKIP_CAPTURE + PNG guard pattern)
#   docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:79,98,110,220,269-280
#   docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md:45-60,62-73 (capture integrity)
#   docs/coord_swarm_2026-11-25/reports/HUD_01_minimap.md:35,52-61,120 (240 slot vs ui_us)
#   docs/coord_swarm_2026-11-25/PROGRESS.md:104-113 (owner directive / ticket split)
#
# Launch forms (Windows `python`, through the FIFO runner ONLY, one job at a time):
#   python variant3d\tools\godot_runner.py run --id HUDLAYOUT01-headless --timeout 90 -- \
#     --headless --path variant3d --script res://tests/t_hud_layout.gd -- \
#     --config <ABS>\small_map_64.json --screenshot <TEMP>\hud_layout_unused.png
#   python variant3d\tools\godot_runner.py run --id HUDLAYOUT01-windowed --timeout 90 -- \
#     --path variant3d --script res://tests/t_hud_layout.gd -- \
#     --config <ABS>\small_map_64.json --screenshot <TEMP>\hud_layout_unused.png \
#     --png-1024x576 <TEMP>\hud_1024x576.png \
#     --png-1280x720 <TEMP>\hud_1280x720.png \
#     --png-1920x1080 <TEMP>\hud_1920x1080.png
# (main.gd:171-172 parses user args too; unknown --png-* flags are ignored by it.)
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const DATA_SCRIPT = preload("res://scripts/data.gd")
const OUT_PATH := "res://tests/results/t_hud_layout.json"

const FIXTURE_W := 64
const FIXTURE_H := 64
const FIXTURE_SEED := 20261113
const VIEWPORTS := [Vector2i(1024, 576), Vector2i(1280, 720), Vector2i(1920, 1080)]
const PNG_FLAGS := ["--png-1024x576", "--png-1280x720", "--png-1920x1080"]

# Pixel slack only for float/container rounding, never for a real overflow.
const EPS := 2.0
# hud.gd:444 / :495-498 — donor speed set plus pause, item metadata in seconds.
const SPEED_LABELS := ["II", "1x", "2x", "4x"]
const SPEED_META := [0.0, 1.0, 2.0, 4.0]
# hud.gd:124-130 (RES_TOOLTIPS) + data.gd:25 (six resources in this order).
# HUD-LAYOUT-REPAIR-01: gold/iron/coal now read "produced at", matching the
# current donor-cited literals at hud.gd:128-130 (hud.gd itself is NOT edited).
const RES_TOOLTIPS_EXPECTED := [
	"Food is produced by peasants in the fields and by fish boats at the port.",
	"Wood is cut in the forests then stored at storehouses or town halls. Wood is primarily used for building construction.",
	"Peasants gather stone at stone quarries then store it at storehouses or town halls. Stone is used for construction and for walls and towers.",
	"Gold is produced at gold mines which can be placed over gold deposits. It recruits and maintains mercenaries and pays for upgrades; without gold, mercenaries rebel.",
	"Iron is produced at iron mines. It recruits armored units and pays for upgrades and ammunition; without iron, ranged units cannot fire.",
	"Coal is produced at coal mines. It is used to produce ammunition for ranged units, artillery and ships; without coal, they cannot fire.",
]

var _id := "t_hud_layout"
var _checks: Array[Dictionary] = []
var _m: Dictionary = {}
var _ok := true
var _finished := false
var _boot_pending := false
var _main: Node = null
var _config_path := ""
var _abs_config := ""
var _headless := true
var _frames := 0
var _capture_paths: Array = []
var _captures_ok := 0


# Variant `cond`: JSON null marks SKIP_CAPTURE / recorded diagnostics and is
# never a PASS. Only an explicit false flips _ok (t_terrain_only.gd:175-184).
func check(name: String, cond, detail: String = "", status: String = "") -> void:
	var st := status
	if st == "":
		st = "PASS" if cond == true else ("FAIL" if cond == false else "SKIPPED")
	_checks.append({"name": name, "passed": cond, "status": st, "detail": detail})
	if cond == false:
		_ok = false
	print("T_HUD_LAYOUT %s %s - %s" % [st, name, detail])


func _verdict() -> String:
	if not _ok:
		return "FAIL"
	return "PASS" if _captures_ok == VIEWPORTS.size() else "SKIP_CAPTURE"


func finish() -> void:
	if _finished:
		return
	_finished = true
	var verdict := _verdict()
	var passes := 0
	var fails := 0
	var skips := 0
	for c in _checks:
		if c.get("passed") == true:
			passes += 1
		elif c.get("passed") == false:
			fails += 1
		else:
			skips += 1
	var out := {
		"id": _id,
		# No full PASS on the headless/skip path (t_terrain_only.gd:213-218).
		"passed": verdict == "PASS",
		"verdict": verdict,
		"structural_ok": _ok,
		"passes": passes,
		"fails": fails,
		"skipped_or_skip_capture": skips,
		"capture_status": "PASS" if _captures_ok == VIEWPORTS.size() else "SKIP_CAPTURE",
		"headless": _headless,
		"config": _abs_config,
		"fixture": [FIXTURE_W, FIXTURE_H, FIXTURE_SEED],
		"viewports": [Vector2i(1024, 576), Vector2i(1280, 720), Vector2i(1920, 1080)],
		"png_user_args": _capture_paths,
		"checks": _checks,
		"measured": _m,
		"script_error_note": "verify via smallmap_capture.py scan-stderr on runner stderr.txt",
		"parity_label": "PORT APPROX — internal layout consistency only; no donor GPU A/B frame",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	var abs_path := ProjectSettings.globalize_path(OUT_PATH)
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f == null:
		push_error("t_hud_layout: cannot write " + abs_path)
	else:
		f.store_string(JSON.stringify(out, "\t"))
		f.close()
	print("T_HUD_LAYOUT RESULT_JSON: " + abs_path)
	print("T_HUD_LAYOUT RESULT: %s %d/%d evaluated, %d skipped" % [verdict, passes, passes + fails, skips])
	# Never quit() directly from _initialize() — hangs in Godot 4.7
	# (_template_test.gd:3,38; t_smallmap_terrain.gd:85).
	call_deferred("quit", 0 if _ok else 1)


func abort_all(reason: String) -> void:
	check("boot", false, reason)
	finish()


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _resolve_config(given: String) -> String:
	if given.is_absolute_path():
		return given if FileAccess.file_exists(given) else ""
	var by_res := ProjectSettings.globalize_path("res://").path_join(given)
	if FileAccess.file_exists(by_res):
		return by_res
	if FileAccess.file_exists(given):
		return given
	return ""


func _initialize() -> void:
	if _finished:
		return
	_headless = DisplayServer.get_name() == "headless"
	_config_path = _arg_value("--config")
	if _config_path == "":
		abort_all("missing --config <fixture.json> in user args (t_smallmap_terrain.gd:178-181)")
		return
	_abs_config = _resolve_config(_config_path)
	if _abs_config == "":
		abort_all("config fixture not found: " + _config_path)
		return
	for i in range(PNG_FLAGS.size()):
		_capture_paths.append(_arg_value(PNG_FLAGS[i]))
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		abort_all("cannot load " + MAIN_SCENE)
		return
	_main = packed.instantiate()
	root.add_child(_main)
	# Scene _ready() is delivered when the loop starts; inspect on first _process
	# tick so main.gd has applied the fixture (t_smallmap_terrain.gd:220-224).
	_boot_pending = true


func _process(_delta: float) -> bool:
	if _finished:
		return false
	_frames += 1
	if _frames > 600:
		abort_all("watchdog: layout sweep did not finish in 600 frames")
		return false
	if _boot_pending:
		_boot_pending = false
		_run_async()
	return false


func _tag(want: Vector2i) -> String:
	return "%dx%d" % [want.x, want.y]


# Async sweep: three resizes with one settled frame each. main's screenshot
# saver is disarmed so it cannot quit at frame >= screenshot_frames
# (main.gd:1699-1701); the atom owns its own capture and deferred quit.
func _run_async() -> void:
	if _main == null:
		abort_all("main scene did not instantiate")
		return
	if _main.get("screenshot_path") != null:
		_main.set("screenshot_path", "")
	var hud_v: Variant = _main.get("hud")
	var hud_ok: bool = hud_v != null and (hud_v is Object) and is_instance_valid(hud_v)
	if hud_ok:
		(hud_v as Object).set("visible", true)  # main.gd:1125-1126 hides HUD for screenshots
	var game_v: Variant = _main.get("game")
	var boot_ok: bool = (game_v != null and (game_v is Object)
		and int(DATA_SCRIPT.MAP_W) == FIXTURE_W and int(DATA_SCRIPT.MAP_H) == FIXTURE_H
		and int(DATA_SCRIPT.RANDOM_SEED) == FIXTURE_SEED
		and str(_main.get("render_mode")).to_lower() == "3d")
	check("real_64_boot", boot_ok,
		"mode=%s map=%dx%d seed=%d expected=%dx%d/%d 3d (t_smallmap_terrain.gd:235-247)" % [
			str(_main.get("render_mode")), int(DATA_SCRIPT.MAP_W), int(DATA_SCRIPT.MAP_H),
			int(DATA_SCRIPT.RANDOM_SEED), FIXTURE_W, FIXTURE_H, FIXTURE_SEED])
	check("hud_bound", hud_ok and (hud_v as Object).get("game") != null,
		"main.hud=%s (main.gd:1110-1112)" % ("bound" if hud_ok else "<none>"))
	if not boot_ok or not hud_ok:
		finish()
		return
	var hud: Object = hud_v as Object
	var original_size: Vector2i = root.size
	var original_scale: Vector2i = root.content_scale_size
	for i in range(VIEWPORTS.size()):
		if _finished:
			return
		var want: Vector2i = VIEWPORTS[i]
		# HUD-LAYOUT-REPAIR-01 resize mechanism - TEST-ONLY harness setup, no
		# game code touched. project.godot:18-19 uses canvas_items stretch with
		# a 1280x720 base, so get_viewport().get_visible_rect().size - the value
		# hud._calc_us() reads (hud.gd:234-239) - stays 1280x720 for all three
		# 16:9 sizes when only root.size changes (testbridge.gd:103-105). The
		# three-size sweep must retarget the root viewport's logical base too,
		# otherwise it silently measures one layout three times. In a windowed
		# run the real DisplayServer window is resized as well, so the physical
		# viewport and PNG capture follow; headless has no real window, so the
		# logical override alone drives the sweep (capture stays SKIP_CAPTURE).
		if not _headless and DisplayServer.get_name() != "headless":
			DisplayServer.window_set_size(want)
		root.size = want                     # testbridge.gd:103-105
		root.content_scale_size = want       # test-only logical viewport override
		await process_frame
		await process_frame
		if _finished:
			return
		if hud.has_method("_on_vp_resize"):
			hud.call("_on_vp_resize")        # hud.gd:273-275
		await process_frame
		if _finished:
			return
		_check_size(hud, want)
		if _finished:
			return
		if _headless:
			_skip_capture(want)
		else:
			await _capture_async(want, i)
	root.size = original_size
	root.content_scale_size = original_scale
	finish()


func _collect_controls(n: Node, out: Array[Control]) -> void:
	if n is Control:
		out.append(n as Control)
	for c in n.get_children():
		_collect_controls(c, out)


func _rect_info(c: Control) -> Dictionary:
	var r := c.get_global_rect()
	return {"name": c.name, "class": c.get_class(),
		"x": r.position.x, "y": r.position.y, "right": r.end.x, "bottom": r.end.y}


# A control whose own rect leaves the viewport but is enclosed by a clipping
# ancestor is visually contained; hud.gd:402 makes top_panel that ancestor.
func _is_clipped_outside(c: Control) -> bool:
	var cr := c.get_global_rect()
	var p: Node = c.get_parent()
	while p != null:
		if p is Control:
			var pc := p as Control
			if pc.clip_contents and not pc.get_global_rect().encloses(cr):
				return true
		p = p.get_parent()
	return false


func _option_texts(c: Control) -> Array:
	var out: Array = []
	if c is OptionButton:
		var ob := c as OptionButton
		for i in range(ob.item_count):
			out.append(str(ob.get_item_text(i)))
	elif c is MenuButton:
		var mb := c as MenuButton
		var popup: PopupMenu = mb.get_popup()
		if popup != null:
			for i in range(popup.item_count):
				out.append(str(popup.get_item_text(i)))
	return out


func _speed_metadata(c: Control) -> Array:
	var out: Array = []
	if c is OptionButton:
		var ob := c as OptionButton
		for i in range(ob.item_count):
			out.append(ob.get_item_metadata(i))
	elif c is MenuButton:
		var mb := c as MenuButton
		var popup: PopupMenu = mb.get_popup()
		if popup != null:
			for i in range(popup.item_count):
				out.append(popup.get_item_metadata(i))
	return out


func _check_size(hud: Object, want: Vector2i) -> void:
	var tag := _tag(want)
	var vp: Vector2 = Vector2(root.size)
	var measured: Dictionary = {}
	_m[tag] = measured
	measured["viewport"] = [vp.x, vp.y]
	check("viewport_" + tag, vp.is_equal_approx(Vector2(want)),
		"root.size=%s expected=%s (testbridge.gd:103-105)" % [str(vp), str(want)])
	var hud_vp_v: Variant = hud.get("ui_vp")
	var hud_vp: Vector2 = hud_vp_v if hud_vp_v is Vector2 else Vector2.ZERO
	measured["hud_ui_vp"] = [hud_vp.x, hud_vp.y]
	check("hud_scale_viewport_" + tag, hud_vp.is_equal_approx(Vector2(want)),
		"hud.ui_vp=%s expected=%s (hud.gd:232-234,273-275; config.gd:751-754)" % [
			str(hud_vp), str(want)])
	check("resize_hook_" + tag, hud.has_method("_on_vp_resize"),
		"hud._on_vp_resize present (hud.gd:273-275)")

	# ---- Top bar -----------------------------------------------------------
	var top_v: Variant = hud.get("top_panel")
	var top: Control = null
	if top_v is Control and is_instance_valid(top_v):
		top = top_v as Control
	check("top_panel_present_" + tag, top != null,
		"hud.top_panel (hud.gd:17,398-403)")
	if top == null:
		return
	var top_rect := top.get_global_rect()
	measured["top_panel_rect"] = _rect_info(top)
	check("top_panel_right_in_viewport_" + tag,
		top_rect.position.x >= -EPS and top_rect.end.x <= vp.x + EPS,
		"top_panel x=[%.1f,%.1f] vp.width=%.1f (PROGRESS.md:105-108; hud.gd:554-557)" % [
			top_rect.position.x, top_rect.end.x, vp.x])
	check("top_panel_clip_" + tag, top.clip_contents,
		"top_panel.clip_contents=%s (hud.gd:402)" % str(top.clip_contents))

	var top_controls: Array[Control] = []
	_collect_controls(top, top_controls)

	# Six resource entries: six non-empty labels + six distinct stock icons
	# carrying the donor's six resource hints (hud.gd:124-130,407-418).
	var labels_ok := 0
	var label_texts: Array = []
	var res_labels_v: Variant = hud.get("res_labels")
	if res_labels_v is Array:
		for l in (res_labels_v as Array):
			if l is Label and is_instance_valid(l):
				var txt := str((l as Label).text).strip_edges()
				label_texts.append(txt)
				if txt != "":
					labels_ok += 1
	var icon_hints: Dictionary = {}
	for c in top_controls:
		if c is TextureRect and RES_TOOLTIPS_EXPECTED.has(str(c.tooltip_text)):
			icon_hints[str(c.tooltip_text)] = true
	measured["resource_labels"] = label_texts
	measured["resource_hints_found"] = icon_hints.size()
	check("six_resource_entries_" + tag, labels_ok == 6 and icon_hints.size() == 6,
		"labels=%d icons_with_hint=%d expected 6/6 (hud.gd:124-130,407-418; data.gd:25-26)" % [
			labels_ok, icon_hints.size()])

	# One speed dropdown, exactly the donor speed set, no leftover speed Buttons
	# (hud.gd:439-447,490-500,598-601; main.gd:1114-1120).
	var speed_widgets: Array[Control] = []
	for c in top_controls:
		if c is OptionButton or c is MenuButton:
			speed_widgets.append(c)
	measured["speed_widgets"] = speed_widgets.size()
	check("single_speed_widget_" + tag, speed_widgets.size() == 1,
		"OptionButton/MenuButton count=%d expected 1 (hud.gd:112,444,490-500)" % speed_widgets.size())
	if speed_widgets.size() == 1:
		var texts := _option_texts(speed_widgets[0])
		measured["speed_options"] = texts
		check("speed_options_" + tag, texts == SPEED_LABELS,
			"options=%s expected=%s (hud.gd:444,495-498)" % [str(texts), str(SPEED_LABELS)])
		var md := _speed_metadata(speed_widgets[0])
		var md_ok: bool = md.size() == SPEED_META.size()
		if md_ok:
			for i in range(md.size()):
				if not (md[i] is float) or absf(float(md[i]) - float(SPEED_META[i])) > 0.001:
					md_ok = false
		check("speed_option_metadata_" + tag, md_ok,
			"metadata=%s expected=%s seconds (hud.gd:496-498,598-601)" % [
				str(md), str(SPEED_META)])
	var legacy: Array = []
	for c in top_controls:
		if c is Button and not (c is OptionButton) and not (c is MenuButton):
			if SPEED_LABELS.has(str(c.text)) or str(c.tooltip_text).contains("Game speed"):
				legacy.append(_rect_info(c))
	check("no_legacy_speed_buttons_" + tag, legacy.is_empty(),
		"leftover speed Buttons=%d expected 0 (pre-fix hud.gd speed_buttons loop)" % legacy.size())

	# ---- Minimap -----------------------------------------------------------
	var mm_rect_v: Variant = hud.get("minimap_rect")
	var mm_panel_v: Variant = hud.get("minimap_panel")
	var mm_rect: TextureRect = null
	if mm_rect_v is TextureRect and is_instance_valid(mm_rect_v):
		mm_rect = mm_rect_v as TextureRect
	var mm_panel: PanelContainer = null
	if mm_panel_v is PanelContainer and is_instance_valid(mm_panel_v):
		mm_panel = mm_panel_v as PanelContainer
	check("minimap_nodes_present_" + tag, mm_rect != null and mm_panel != null,
		"hud.minimap_rect/minimap_panel (hud.gd:48-49,1555-1595)")
	if mm_rect != null:
		var declared := -1
		if hud.has_method("_mm_size"):
			declared = int(hud.call("_mm_size"))
		var mw := int(mm_rect.get_meta("uimw", 0))
		var mh := int(mm_rect.get_meta("uimh", 0))
		var slot_ok: bool = declared == 240 and mw == 240 and mh == 240
		measured["minimap_declared_slot"] = [mw, mh]
		measured["minimap_scaled_min"] = [mm_rect.custom_minimum_size.x, mm_rect.custom_minimum_size.y]
		measured["minimap_render_px"] = [mm_rect.size.x, mm_rect.size.y]
		check("minimap_declared_240_" + tag, slot_ok,
			"_mm_size=%d meta=(%d,%d) expected 240 (hud.gd:283-287,1560-1563; HUD_01_minimap.md:52-61)" % [
				declared, mw, mh])
		var r := mm_rect.get_global_rect()
		check("minimap_square_" + tag, absf(r.size.x - r.size.y) <= 2.0,
			"rendered minimap=%.1fx%.1f (ui_us scale documented at hud.gd:327-333)" % [
				r.size.x, r.size.y])
		if mm_panel != null:
			var pr := mm_panel.get_global_rect()
			measured["minimap_panel_rect"] = _rect_info(mm_panel)
			check("minimap_bottom_right_" + tag,
				is_equal_approx(mm_panel.anchor_left, 1.0)
				and is_equal_approx(mm_panel.anchor_right, 1.0)
				and is_equal_approx(mm_panel.anchor_top, 1.0)
				and is_equal_approx(mm_panel.anchor_bottom, 1.0)
				and pr.position.x >= vp.x * 0.5 and pr.position.y >= vp.y * 0.5
				and pr.end.x <= vp.x + EPS and pr.end.y <= vp.y + EPS,
				"anchors=(%.1f,%.1f,%.1f,%.1f) rect=%s vp=%s (hud.gd:1579-1595; HUD_01_minimap.md:54-56)" % [
					mm_panel.anchor_left, mm_panel.anchor_right, mm_panel.anchor_top,
					mm_panel.anchor_bottom, str(_rect_info(mm_panel)), str(vp)])
			check("minimap_no_topbar_overlap_" + tag, not pr.intersects(top_rect),
				"minimap=%s top=%s (hud.gd:319-321,327-350)" % [
					str(_rect_info(mm_panel)), str(_rect_info(top))])

	# ---- Whole-HUD viewport containment ------------------------------------
	var all_controls: Array[Control] = []
	_collect_controls(_main, all_controls)
	var offenders: Array = []
	var clipped: Array = []
	for c in all_controls:
		if not is_instance_valid(c) or not c.is_visible_in_tree():
			continue
		if c.get_viewport() != root:
			continue
		var r := c.get_global_rect()
		if r.size.x <= 0.0 or r.size.y <= 0.0:
			continue
		if r.position.x >= -EPS and r.position.y >= -EPS and r.end.x <= vp.x + EPS and r.end.y <= vp.y + EPS:
			continue
		if _is_clipped_outside(c):
			clipped.append(_rect_info(c))
		else:
			offenders.append(_rect_info(c))
	measured["unclipped_offenders"] = offenders
	measured["clipped_overflow_count"] = clipped.size()
	check("no_unclipped_control_outside_viewport_" + tag, offenders.is_empty(),
		"offenders=%d first=%s (PROGRESS.md:105-108; hud.gd:402,554-557)" % [
			offenders.size(), str(offenders.slice(0, 6))])
	# Not a gate: descendants clipped by top_panel are intentionally contained
	# (hud.gd:402); the old value stays recorded, P0_GATE-01 precedent.
	check("clipped_overflow_children_" + tag, null,
		"clipped children outside their panel=%d RECORDED_NOT_GATE (hud.gd:402)" % clipped.size(),
		"RECORDED_NOT_GATE")


func _skip_capture(want: Vector2i) -> void:
	var tag := _tag(want)
	var why := "SKIP_CAPTURE: DisplayServer.get_name()==headless; state-only result, no PNG claim (CAPTURE_RECHECK.md:57-60)"
	check("capture_image_" + tag, null, why, "SKIP_CAPTURE")
	check("capture_saved_" + tag, null, why, "SKIP_CAPTURE")
	check("capture_nonblank_" + tag, null, why, "SKIP_CAPTURE")


func _image_metrics(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var step := maxi(1, int(minf(float(w), float(h)) / 64.0))
	var total := 0
	var nonblack := 0
	var luma_sum := 0.0
	var luma_max := 0.0
	for y in range(0, h, step):
		for x in range(0, w, step):
			var c := img.get_pixel(x, y)
			var l := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			total += 1
			luma_sum += l
			luma_max = maxf(luma_max, l)
			if l > 8.0:
				nonblack += 1
	return {
		"width": w, "height": h,
		"non_black_fraction": float(nonblack) / float(maxi(1, total)),
		"mean_luma": luma_sum / float(maxi(1, total)),
		"max_luma": luma_max,
	}


# Windowed-only root-viewport readback. No CPU fallback: a blank frame is a
# FAIL, never a PASS (main.gd:1830-1832,1875-1882; CAPTURE_RECHECK.md:57-60).
func _capture_async(want: Vector2i, idx: int) -> void:
	var tag := _tag(want)
	var png := str(_capture_paths[idx])
	if png == "":
		check("capture_arg_" + tag, false,
			"windowed run needs %s <abs.png> user arg (TEST_01_smallmap_harness.md:188-197)" % PNG_FLAGS[idx])
		return
	var abs_png := png
	if not abs_png.is_absolute_path():
		if abs_png.begins_with("res://") or abs_png.begins_with("user://"):
			abs_png = ProjectSettings.globalize_path(abs_png)
		else:
			abs_png = ProjectSettings.globalize_path("res://").path_join(abs_png)
	var tex := root.get_texture()
	await RenderingServer.frame_post_draw
	if _finished:
		return
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		check("capture_image_" + tag, false,
			"blank root viewport texture — no CPU fallback (main.gd:1830-1832,1875-1882)")
		return
	check("capture_image_" + tag,
		img.get_width() == want.x and img.get_height() == want.y,
		"root texture %dx%d expected %dx%d (main.gd:1185-1202)" % [
			img.get_width(), img.get_height(), want.x, want.y])
	if not DirAccess.dir_exists_absolute(abs_png.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(abs_png.get_base_dir())
	var err := img.save_png(abs_png)
	var exists := FileAccess.file_exists(abs_png)
	check("capture_saved_" + tag, err == OK and exists,
		"save_png(%s) err=%d exists=%s" % [abs_png, err, str(exists)])
	if err != OK or not exists:
		return
	var metrics := _image_metrics(img)
	metrics["png_path"] = abs_png
	metrics["bytes"] = FileAccess.get_file_as_bytes(abs_png).size()
	var measured: Dictionary = _m.get(tag, {})
	measured["png_metrics"] = metrics
	_m[tag] = measured
	check("capture_nonblank_" + tag, float(metrics["non_black_fraction"]) > 0.0,
		"non_black_fraction=%.4f mean_luma=%.2f (loud blank-frame guard, main.gd:1875-1882)" % [
			float(metrics["non_black_fraction"]), float(metrics["mean_luma"])])
	_captures_ok += 1
