# Regression test: the build menu has one generic "Mine" button, and the
# concrete mine (gold / iron / coal) is chosen from the deposit under the cursor.
#
# Run with:
#   godot --headless --path app --script res://tests/unified_mine_test.gd
extends SceneTree

const C3Game = preload("res://scripts/game.gd")
const C3HUD = preload("res://scripts/hud.gd")
const ConfigScript = preload("res://scripts/config.gd")

var game
var checks: Array = []

func _check(name: String, ok: bool, detail: String) -> void:
	checks.append({"name": name, "ok": ok, "detail": detail})
	print(("  PASS  " if ok else "  FAIL  ") + name + " - " + detail)

func _initialize() -> void:
	var cfg = ConfigScript.new()
	cfg.load_all()
	cfg.apply()
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")
	game.players[0].res[1] = 10000.0  # wood
	game.players[0].res[2] = 10000.0  # stone

	# The generic sid must be left alone by unrelated calls.
	_check("other_sids_untouched", game.resolve_mine_sid("hou", Vector2.ZERO) == "hou",
		"resolve_mine_sid('hou') == 'hou'")

	# One deposit of each ore type: placing with the single sid must produce
	# the mine matching that deposit, and preview it the same way.
	for ore in ["gold", "iron", "coal"]:
		var dep: Dictionary = {}
		for n in game.res_nodes:
			if n.type == ore and int(n.max_hits) == 0:
				dep = n
				break
		if dep.is_empty():
			_check("deposit_" + ore, false, "no " + ore + " deposit on the test map")
			continue
		var pos: Vector2 = dep.pos + Vector2(1.0, 0.0)  # near, not exactly on it
		var want: String = "mine_" + ore
		var resolved: String = str(game.resolve_mine_sid("mine", pos))
		_check("preview_" + ore, resolved == want,
			"cursor over %s -> %s" % [ore, resolved])
		var chk: Dictionary = game.can_place(0, "mine", pos)
		_check("legal_" + ore, bool(chk.get("ok", false)), str(chk.get("reason", "")))
		var b: Dictionary = game.place_building(0, "mine", pos, false, [])
		_check("build_" + ore, str(b.get("sid", "")) == want,
			"placed %s -> %s" % [ore, str(b.get("sid", ""))])

	# An empty spot must be rejected cleanly (no missing "mine" def crash).
	var empty := Vector2(game.MAP_W * game.TILE * 0.5, game.MAP_H * game.TILE * 0.5)
	var bad: Dictionary = game.can_place(0, "mine", empty)
	_check("no_deposit_rejected", not bool(bad.get("ok", true)), str(bad.get("reason", "")))

	# The build menu must offer a single generic Mine button, not three.
	var hud = C3HUD.new()
	root.add_child(hud)
	hud.set_process(false)  # partial HUD: only the build menu is exercised
	hud.res_labels = [Label.new(), Label.new(), Label.new(),
		Label.new(), Label.new(), Label.new()]
	hud.game = game
	hud.build_bar = HFlowContainer.new()
	hud._refresh_build_menu([])
	var mine_keys: Array = hud.build_buttons.keys().filter(func(k): return str(k).begins_with("mine"))
	_check("one_mine_button", mine_keys.size() == 1 and str(mine_keys[0]) == "mine",
		"mine buttons in build menu: " + str(mine_keys))
	_check("mine_button_name", str(hud.build_buttons["mine"].tooltip_text).begins_with("Mine"),
		str(hud.build_buttons["mine"].tooltip_text))
	root.remove_child(hud)
	hud.free()

	_finish()

func _finish() -> void:
	var ok := true
	for c in checks:
		if not c.ok:
			ok = false
	print("unified_mine_test: %d/%d checks passed" % [
		checks.filter(func(c): return c.ok).size(), checks.size()])
	call_deferred("quit", 0 if ok else 1)
