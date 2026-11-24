# Small test: skirmish building/unit capture rules
# (board P-03 done = peasant capture; RB_MECHANICS G-01 / G-07 / G-09 gaps).
#
# Asserts the INTENDED donor behaviour of capture:
#   * enemy town hall can be taken by peasants (works today - P-03/G-01 partial);
#   * taking a mine also hands over its ore deposit (G-01: mines lack capture:true);
#   * taking a foreign nation's town hall unlocks that nation's units (G-07);
#   * a guarded / defended building resists capture until defenders are gone (G-09);
#   * the wiki capturable set (town hall, market, mines, storehouse) is flagged,
#     while military buildings are not.
#
# PENDING gaps are asserted, not worked around: a failing check is the correct
# baseline for a feature that has not landed yet. Do NOT weaken these checks.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-capture --timeout 90 -- \
#       --headless --path app --script res://tests/t_capture.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_capture"
var _checks: Array[Dictionary] = []
var _ok := true
var game

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

# Put `n` peasants on the open (south) side of a building: inside the 8 m +
# radius capture ring, outside the footprint push-out that tick() applies.
func _swarm(pos: Vector2, n: int, player: int) -> Array:
	var out: Array = []
	for i in n:
		var off := Vector2((float(i) - float(n - 1) * 0.5) * 2.5, 7.0 + float(i % 2))
		out.append(game.spawn("peasant", player, pos + off))
	return out

func _initialize() -> void:
	# Make player 1 Turkey: its town hall is foreign to player 0 (rus) and its
	# NATION_UNITS resolve "serdiuk" -> "jannisary" once G-07 lands.
	var saved_nations: Array = Data.PLAYER_NATIONS.duplicate()
	Data.PLAYER_NATIONS = ["rus", "tur"]
	Data.AI_ENABLED = false

	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	# Fund player 0 so train_unit() can really queue a unit in the G-07 check.
	for i in range(game.players[0].res.size()):
		game.players[0].res[i] = 100000.0

	# Four independent sites, all near the middle of the 320x320 m map so the
	# corner starts cannot interfere with the capture ring.
	var hall_pos := Vector2(120.0, 150.0)
	var mine_pos := Vector2(200.0, 150.0)
	var guarded_pos := Vector2(160.0, 210.0)
	var barracks_pos := Vector2(100.0, 220.0)

	var hall: Dictionary = game.spawn("cen", 1, hall_pos)          # enemy town hall
	var mine: Dictionary = game.spawn("mine_gold", 1, mine_pos)    # enemy ore mine + deposit
	var guarded: Dictionary = game.spawn("cen", 1, guarded_pos)    # defended enemy hall
	var barracks: Dictionary = game.spawn("bar", 0, barracks_pos)  # player 0's own barracks

	var deposit_before := float(mine.get("deposit_left", 0.0))

	_swarm(hall_pos, 4, 0)
	_swarm(mine_pos, 4, 0)
	_swarm(guarded_pos, 4, 0)

	# A support unit with an explicit guard order: present and guarding, but it
	# cannot shoot/capture our peasants, so baseline capture still completes.
	var guard: Dictionary = game.spawn("priest", 1, guarded_pos + Vector2(4.0, 4.0))
	game.cmd_guard(guard, guarded)

	# Advance the real simulation (capture needs ~1.8 s with 4 peasants).
	for _i in range(80):
		game.tick(0.1)

	# 1. Town hall capture by peasants (already implemented - P-03 / G-01 part).
	check("town_hall_capturable_by_peasants", int(hall.player) == 0,
		"enemy tur town hall owner after 8 s with 4 peasants = %d (want 0), flag=%s"
			% [int(hall.player), str(hall.def.get("capture", false))])

	# 2. G-01: a mine is capturable, and its ore deposit comes with it.
	var mine_flag := bool(Data.BUILDINGS.get("mine_gold", {}).get("capture", false))
	var usable: Dictionary = game.nearest_mine(mine_pos, "gold", 0)
	var usable_ok: bool = not usable.is_empty() and int(usable.get("id", -1)) == int(mine.id)
	check("mine_deposit_captured_with_mine",
		mine_flag and int(mine.player) == 0
			and float(mine.get("deposit_left", 0.0)) > 0.0 and usable_ok,
		"mine capture flag=%s, owner=%d, deposit %.0f->%.0f, nearest_mine(p0)=%s"
			% [str(mine_flag), int(mine.player), deposit_before,
				float(mine.get("deposit_left", 0.0)),
				("id=%d" % int(usable.get("id", -1)) if usable_ok else "none")])

	# 3. G-07: taking a foreign town hall unlocks that nation's units.
	#    With player 0 = rus, train_unit() resolves "serdiuk" -> "strelet";
	#    after capturing a Turkish hall it must resolve -> Turkish "jannisary".
	var expected := Data.resolve_sid("tur", "serdiuk")
	var trained: bool = game.train_unit(0, barracks, "serdiuk")
	var queued := ""
	if barracks.queue.size() > 0:
		queued = str(barracks.queue[0].get("sid", ""))
	check("foreign_town_hall_unlocks_nation", trained and queued == expected,
		"captured tur hall; train_unit(0,'serdiuk') queued '%s', want '%s' (baseline rus '%s')"
			% [queued, expected, Data.resolve_sid("rus", "serdiuk")])

	# 4. G-09: a guarded / defended building must not fall to a mere swarm.
	var guard_order := str(guard.get("order", {}).get("type", ""))
	check("capture_precondition_guard_blocks", int(guarded.player) == 1,
		"guarded enemy hall owner after assault = %d (want 1), guard order=%s, attackers=4"
			% [int(guarded.player), guard_order])

	# 5. G-01: the wiki's capturable economy set is fully flagged.
	var economy := ["cen", "mar", "sto", "mine_gold", "mine_iron", "mine_coal"]
	var missing: Array[String] = []
	for sid in economy:
		if not bool(Data.BUILDINGS.get(sid, {}).get("capture", false)):
			missing.append(sid)
	check("economy_buildings_capturable", missing.is_empty(),
		"economy sids without capture:true = %s" % str(missing))

	# 6. Guard against an over-broad fix: military buildings stay uncapturable.
	var military := ["bar", "bar18", "sta", "bla", "aca", "art", "tow", "wal", "gat"]
	var wrongly: Array[String] = []
	for sid in military:
		if bool(Data.BUILDINGS.get(sid, {}).get("capture", false)):
			wrongly.append(sid)
	check("military_buildings_not_capturable", wrongly.is_empty(),
		"military sids with capture:true = %s" % str(wrongly))

	Data.PLAYER_NATIONS = saved_nations
	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
