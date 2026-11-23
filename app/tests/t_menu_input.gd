# T-MENU-INPUT-BUG: the full-screen skirmish menu must stay fully interactive.
#
# Root cause this guards against: `shell_full` and `shell_center` are sibling
# full-rect Controls. Godot's hit test returns the topmost Control under the
# cursor even when its mouse_filter is PASS (PASS only forwards the event up
# the parent chain, never to siblings behind it). `shell_center` is added
# after `shell_full`, so once `_show_skirmish()` reparents `root` out of it,
# the empty shell is topmost, wins every hit test, and swallows all clicks
# and wheel events. The idle shell must be MOUSE_FILTER_IGNORE, and the shell
# that hosts `root` must be topmost.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-menu-input --timeout 100 -- \
#       --headless --path app --script res://tests/t_menu_input.gd
extends SceneTree

const C3Menu = preload("res://scripts/menu.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_menu_input"
var _checks: Array[Dictionary] = []
var _ok := true
var _menu
var _done := false

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _mname(m: int) -> String:
	return ["STOP", "PASS", "IGNORE"][m] if m >= 0 and m < 3 else str(m)

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

func _finish() -> void:
	if _done:
		return
	_done = true
	_write_result()
	call_deferred("quit", 0 if _ok else 1)

func _force_quit() -> void:
	if not _done:
		check("watchdog", false, "test did not finish in time")
		_finish()

func _initialize() -> void:
	var guard := create_timer(15.0)
	guard.timeout.connect(_force_quit)
	# Headless starts with a 100x100 window; give the mouse a real 1280x720
	# area so synthetic motion/hover events reach the controls.
	get_root().size = Vector2i(1280, 720)
	_menu = C3Menu.new()
	root.add_child(_menu)
	# _ready() (which calls _build()) is deferred inside SceneTree._initialize;
	# give it two frames before driving the menu by hand.
	process_frame.connect(_frame1, CONNECT_ONE_SHOT)

func _frame1() -> void:
	process_frame.connect(_frame2, CONNECT_ONE_SHOT)

func _frame2() -> void:
	_menu._show_skirmish()
	process_frame.connect(_check, CONNECT_ONE_SHOT)

func _check() -> void:
	var m = _menu
	check("root_in_full_shell", m.root.get_parent() == m.shell_full,
		"parent=%s" % str(m.root.get_parent()))
	check("root_receives_input", m.root.mouse_filter != Control.MOUSE_FILTER_IGNORE,
		"filter=%s" % _mname(m.root.mouse_filter))
	check("scrolls_visible", m.menu_scroll.visible and m.options_scroll.visible,
		"menu=%s options=%s" % [str(m.menu_scroll.visible), str(m.options_scroll.visible)])
	var disabled := 0
	for b in m.action_bar.get_children():
		if b is BaseButton and b.disabled:
			disabled += 1
	check("action_bar_enabled", m.action_bar.get_child_count() >= 2 and disabled == 0,
		"buttons=%d disabled=%d" % [m.action_bar.get_child_count(), disabled])

	# The idle full-rect shell must never win a hit test.
	check("idle_shell_ignores_input",
		m.shell_center.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"shell_center.filter=%s" % _mname(m.shell_center.mouse_filter))
	check("active_shell_on_top", m.shell_full.get_index() > m.shell_center.get_index(),
		"full=%d center=%d" % [m.shell_full.get_index(), m.shell_center.get_index()])
	check("active_shell_receives_input",
		m.shell_full.mouse_filter != Control.MOUSE_FILTER_IGNORE,
		"shell_full.filter=%s" % _mname(m.shell_full.mouse_filter))

	# No visible full-rect sibling above the active shell may claim a click.
	# (Godot returns a PASS control as the hit too - PASS only forwards the
	# event up the parent chain, so only IGNORE makes a shell click-through.)
	var mid := get_root().get_visible_rect().size * 0.5
	var blockers := []
	for s in m.get_children():
		if not s is Control or s == m.shell_full:
			continue
		var c := s as Control
		if c.is_visible_in_tree() and c.mouse_filter != Control.MOUSE_FILTER_IGNORE \
			and c.get_global_rect().has_point(mid):
			blockers.append("%s:%s" % [c.name, _mname(c.mouse_filter)])
	check("no_overlay_blocker", blockers.is_empty(),
		"at %s blockers=%s" % [str(mid), str(blockers)])

	# Returning to the centered card must restore symmetric routing.
	m._show_main()
	check("center_restored", m.root.get_parent() == m.shell_center \
		and m.shell_full.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and m.shell_center.mouse_filter != Control.MOUSE_FILTER_IGNORE \
		and m.shell_center.get_index() > m.shell_full.get_index(),
		"parent=%s full=%s center=%s idx=%d/%d" % [str(m.root.get_parent()),
		_mname(m.shell_full.mouse_filter), _mname(m.shell_center.mouse_filter),
		m.shell_center.get_index(), m.shell_full.get_index()])

	m.queue_free()
	_finish()
