# Small test: skirmish roster / Scotland (board P-24, docs/research/RA_ROSTER.md
# gaps G01 "Scotland nation absent", G06 "Scottish unique units absent",
# G08 "baked-but-unwired sprites").
#
# Asserts INTENDED behaviour of a selectable Scotland nation with its own
# nation-unique roster and skinned buildings, and that the already-baked
# `sco_peasant` sheet is reachable through the real world key-resolution APIs.
# The feature is PENDING: on the current build several checks fail (no `sco`
# in NATIONS / NATION_UNITS, no sco building skins, fewer than 3 sco-unique
# roster units). That is the correct baseline - do NOT weaken these assertions
# to make it pass. Two reachability checks (baked sheet + spawn/move) pass on
# the baseline and prove the runtime APIs can carry the feature once it lands.
#
# Discovery is by naming tokens / real resolve APIs, not by exact sid strings,
# so the feature owner is free to choose concrete unit names.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-roster-scotland --timeout 90 -- \
#       --headless --path app --script res://tests/t_roster_scotland.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_roster_scotland"
var _checks: Array[Dictionary] = []
var _ok := true
var game
var world

# scotland-specific naming families (donor sids/icons, RA_ROSTER S2/S6)
const _SCO_TOKENS := ["sco", "highland", "clan", "covenanter", "framegun", "bagpipe"]

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

func _is_sco_sid(sid: String) -> bool:
	var s := sid.to_lower()
	for tok in _SCO_TOKENS:
		if s.contains(tok):
			return true
	return false

func _sim(seconds: float) -> void:
	var steps := int(seconds / 0.25)
	for i in steps:
		game.tick(0.25)

func _initialize() -> void:
	# Force the test player to Scotland so the real key-resolution paths
	# (world._anim_key / _bld_key / Data.resolve_sid) use the sco nation.
	var saved_nations: Array = Data.PLAYER_NATIONS.duplicate()
	Data.PLAYER_NATIONS[0] = "sco"
	Data.AI_ENABLED = false

	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")
	world = C3World.new()
	root.add_child(world)
	world.bind(game)

	# G01 (a): Scotland is a selectable skirmish nation.
	var sco_name := ""
	if Data.NATIONS.has("sco"):
		sco_name = str(Data.NATIONS["sco"].get("name", ""))
	check("sco_nation_registered", Data.NATIONS.has("sco")
		and sco_name.to_lower().contains("scotland"),
		"Data.NATIONS has sco=%s, name='%s', nations=%d (want sco/Scotland)" % [
			str(Data.NATIONS.has("sco")), sco_name, Data.NATIONS.size()])

	# G01/G06 (b): the sco train list is wired through NATION_UNITS and at
	# least one generic barracks sid resolves to a scotland-specific unit that
	# actually exists in Data.UNITS. Uses the real resolve_sid API.
	# Probe every sid any building can train (derived from the live tables, so
	# the check does not miss a nation-unique mapping on an unusual train sid).
	var train_probe: Array[String] = []
	for b in Data.BUILDINGS:
		for s in Data.BUILDINGS[b].get("trains", []):
			var ss := str(s)
			if not train_probe.has(ss):
				train_probe.append(ss)
	var sco_resolved: Array[String] = []
	if Data.NATION_UNITS.has("sco"):
		for generic in train_probe:
			var rid := str(Data.resolve_sid("sco", generic))
			if Data.UNITS.has(rid) and _is_sco_sid(rid) and not sco_resolved.has(rid):
				sco_resolved.append(rid)
	check("sco_nation_units_wired", Data.NATION_UNITS.has("sco") and sco_resolved.size() >= 1,
		"NATION_UNITS has sco=%s, sco train sids resolved=%s" % [
			str(Data.NATION_UNITS.has("sco")), str(sco_resolved)])

	# G06 (c): the roster carries a distinct set of Scottish unique units
	# (donor: Bow/Sword Clansman, Covenanter, Lancer, Raider, Frame gun,
	# Highlander, ...), not just the single generic Highlander entry.
	var sco_unit_keys: Array[String] = []
	for sid in Data.UNITS:
		if _is_sco_sid(str(sid)):
			sco_unit_keys.append(str(sid))
	sco_unit_keys.sort()
	check("sco_unique_units_in_roster", sco_unit_keys.size() >= 3,
		"sco-specific Data.UNITS keys=%d (want >= 3): %s" % [
			sco_unit_keys.size(), str(sco_unit_keys)])

	# G01 (d): a sco player's town hall resolves to a skinned sco building
	# sprite that actually loads (buildings.json sco_* families, RA G01).
	var hall_key: String = str(world._bld_key({"player": 0, "sid": "cen"}))
	var hall_skin_ok: bool = hall_key.begins_with("sco_") and world._bld_anim(hall_key) != null
	check("sco_building_skin", hall_skin_ok,
		"_bld_key(player=sco, cen)='%s', sprite loadable=%s (want sco_* skin)" % [
			hall_key, str(world._bld_anim(hall_key) != null)])

	# G08 (e): the baked-but-unwired `sco_peasant` sheet IS reachable through
	# the real anim-key API once the player nation is sco (reachability check;
	# passes on the baseline, proving the asset needs no new art).
	var peasant_key: String = str(world._anim_key("peasant", 0))
	var pinfo: Dictionary = world.anim_index.get(peasant_key, {})
	var pact: Dictionary = pinfo.get("actions", {})
	check("sco_peasant_sheet_reachable", peasant_key == "sco_peasant"
		and pinfo.has("actions") and pact.has("idle") and pact.has("walk"),
		"_anim_key(peasant, sco)='%s', in index=%s, actions=%s" % [
			peasant_key, str(world.anim_index.has(peasant_key)), str(pact.keys())])

	# (f): a scotland unit spawns and executes a real move order. Prefer a
	# sco-resolved unit; fall back to the baked Highlander so the check still
	# exercises the real spawn/cmd_move/tick path on the baseline.
	var spawn_sid := "highlander"
	if sco_resolved.size() > 0:
		spawn_sid = sco_resolved[0]
	if not Data.UNITS.has(spawn_sid):
		spawn_sid = "highlander"
	# Anchor on an existing starting peasant so the spawn tile is known-walkable
	# (the same pattern the main selftest uses for its move step).
	var sp := Vector2(game.MAP_W * game.TILE * 0.3, game.MAP_H * game.TILE * 0.3)
	for u in game.units_of(0):
		if str(u.sid) == "peasant":
			sp = u.pos
			break
	var e: Dictionary = game.spawn(spawn_sid, 0, sp)
	var start_pos: Vector2 = e.get("pos", sp)
	game.cmd_move(e, start_pos + Vector2(6.0, 0.0))
	_sim(8.0)
	var walked := start_pos.distance_to(e.get("pos", start_pos))
	check("sco_unit_spawn_and_move", not e.is_empty() and str(e.get("kind", "")) == "unit"
		and int(e.get("player", -1)) == 0 and walked >= 3.0,
		"spawned '%s' (player %d), order=%s, walked %.1f m (want >= 3.0)" % [
			spawn_sid, int(e.get("player", -1)), str(e.get("order", {}).get("type", "")), walked])

	# restore the global before exiting (single process, but keep it clean)
	Data.PLAYER_NATIONS = saved_nations

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
