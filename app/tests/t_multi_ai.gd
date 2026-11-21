# Small test: 2+ AI opponents on one random skirmish map (board P-18).
#
# Asserts INTENDED behaviour of a multi-AI skirmish: the generated map offers a
# start per participant, the engine can host three players / two AIs, each AI
# gets a home + resources, both AIs issue orders, neither freezes, chat does not
# flood, and the simulation keeps running (or resolves) without breaking.
#
# The current engine hardcodes a two-player setup/generator, so several checks
# FAIL on the baseline. That is the correct result for a pending feature — do
# not weaken the assertions to make this green prematurely.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-multi-ai --timeout 120 -- \
#       --headless --path app --script res://tests/t_multi_ai.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3AI = preload("res://scripts/ai.gd")

const OUT_DIR := "res://tests/results"

const SIM_SECONDS := 30.0
const DT := 0.25          # game.TICK_MAX clamp keeps this honest
const AI_PLAYERS := [1, 2]
const SPAM_LIMIT := 5     # identical chat line repeated more than this = spam

var _id := "t_multi_ai"
var _checks: Array[Dictionary] = []
var _ok := true
var game: C3Game

var _messages: Array[String] = []
var _prev_order: Dictionary = {}      # unit id -> last observed order type
var _start_pos: Dictionary = {}       # unit id -> initial position
var _orders_issued := [0, 0, 0]       # indexed by player number
var _active_ticks := [0, 0, 0]
var _late_active_ticks := [0, 0, 0]

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

func _on_message(text: String) -> void:
	_messages.append(text)

# A third participant needs a nation sid because ai.gd resolves unit names
# through Data.PLAYER_NATIONS[player] when it trains from a barracks.
func _ensure_third_nation() -> void:
	if Data.PLAYER_NATIONS.size() < 3:
		Data.PLAYER_NATIONS.append("pol")
	if Data.PLAYER_NAMES.size() < 3:
		Data.PLAYER_NAMES.append("Poland")

# The map generator currently emits only two starts. Provide a deterministic
# walkable fallback so the simulation can still run and expose the real gap.
func _start_for(index: int) -> Vector2:
	if index < game.map_starts.size():
		return game.map_starts[index]
	var w: float = float(Data.MAP_W) * game.TILE
	var h: float = float(Data.MAP_H) * game.TILE
	var base: Vector2 = Vector2(w * 0.5, h * 0.12)
	for ring in 30:
		for k in 16:
			var a: float = TAU * float(k) / 16.0
			var p: Vector2 = base + Vector2(cos(a), sin(a)) * float(ring) * game.TILE
			if game.in_bounds(p) and not game.is_blocked(p):
				return p
	return base

# Uses only real game APIs: new_player(), players[], spawn().
func _add_ai_player(index: int, start: Vector2) -> void:
	var p: Dictionary = game.new_player(index, "AI %d" % index, true)
	game.players.append(p)
	if index < Data.PLAYER_NATIONS.size():
		p["nation"] = str(Data.PLAYER_NATIONS[index])
	var cen: Dictionary = game.spawn("cen", index, start)
	p["home_id"] = cen.id
	p["home_pos"] = start
	var cr: float = float(cen.get("block_r", cen.def.radius))
	var n: int = maxi(1, int(Data.START_PEASANTS))
	for k in n:
		var a: float = TAU * float(k) / float(n)
		var pe: Dictionary = game.spawn("peasant", index, start + Vector2(cos(a), sin(a)) * (cr + 3.0))
		pe.order = {"type": "none"}

func _home_of(player: int) -> Dictionary:
	for b in game.buildings_of(player, false):
		if b.sid == "cen" and not b.dead:
			return b
	return {}

func _initialize() -> void:
	Data.AI_ENABLED = true
	Data.AI_THINK_INTERVAL = 1.0
	# Skirmish starting purse: a real menu supplies this; make it explicit so
	# both the engine-created AI and the added AI go through res_list().
	Data.START_RESOURCES = {"food": 500.0, "wood": 500.0, "stone": 300.0,
		"gold": 150.0, "iron": 150.0, "coal": 150.0}
	_ensure_third_nation()

	game = C3Game.new()
	root.add_child(game)
	game.message.connect(_on_message)
	game.setup("skirmish")

	# setup() only creates two slots; host the second AI with the same real
	# APIs the menu would use (new_player / players / spawn).
	if game.players.size() < 3:
		_add_ai_player(2, _start_for(2))

	# A genuine three-player skirmish needs three headers and two AI flags.
	var ai_count := 0
	for p in game.players:
		if bool(p.get("is_ai", false)):
			ai_count += 1
	check("three_players_two_ai", game.players.size() == 3 and ai_count == 2,
		"players=%d, is_ai=%d (want 3 / 2)" % [game.players.size(), ai_count])

	# --- check: start position + resources for every AI ---------------------
	var start_ok := true
	var start_detail: Array[String] = []
	start_detail.append("map_starts=%d" % game.map_starts.size())
	if game.map_starts.size() < 3:
		start_ok = false
	for pi in AI_PLAYERS:
		var home := _home_of(pi)
		var res: Array = game.players[pi].res if pi < game.players.size() else []
		var purse := 0.0
		for v in res:
			purse += float(v)
		var in_bounds: bool = not home.is_empty() and game.in_bounds(home.pos)
		var has_purse := res.size() == 6 and purse > 0.0
		if not in_bounds or not has_purse:
			start_ok = false
		start_detail.append("AI%d home=%s purse=%.0f" % [pi,
			("(%.1f,%.1f)" % [home.pos.x, home.pos.y]) if not home.is_empty() else "none", purse])
	check("each_ai_has_start_and_resources", start_ok, ", ".join(start_detail))

	# --- simulate with two independent AI brains (as main.gd does) ----------
	var ais: Array = []
	for pi in AI_PLAYERS:
		ais.append(C3AI.new(game, pi))
	for pi in AI_PLAYERS:
		for u in game.units_of(pi):
			_prev_order[int(u.id)] = str(u.get("order", {}).get("type", "none"))
			_start_pos[int(u.id)] = u.pos

	var steps := int(round(SIM_SECONDS / DT))
	for s in steps:
		game.tick(DT)
		for ai in ais:
			ai.tick(DT)
		for pi in AI_PLAYERS:
			var any_active := false
			for u in game.units_of(pi):
				var uid := int(u.id)
				var t := str(u.get("order", {}).get("type", "none"))
				if t != "none":
					any_active = true
				if str(_prev_order.get(uid, "none")) == "none" and t != "none":
					_orders_issued[pi] += 1
				_prev_order[uid] = t
			if any_active:
				_active_ticks[pi] += 1
				if s >= steps / 2:
					_late_active_ticks[pi] += 1

	# --- check: each AI actually issued orders within the window -----------
	var orders_ok := true
	var orders_detail: Array[String] = []
	for pi in AI_PLAYERS:
		if _orders_issued[pi] < 1:
			orders_ok = false
		orders_detail.append("AI%d issued=%d active_ticks=%d" % [pi, _orders_issued[pi], _active_ticks[pi]])
	check("each_ai_issues_orders", orders_ok, ", ".join(orders_detail))

	# --- check: no AI froze halfway through --------------------------------
	var stuck_ok := true
	var stuck_detail: Array[String] = []
	for pi in AI_PLAYERS:
		var moved := 0.0
		var alive := 0
		for u in game.units_of(pi):
			var uid := int(u.id)
			if _start_pos.has(uid):
				moved += u.pos.distance_to(_start_pos[uid])
				alive += 1
		# Sustained activity in the second half + real movement != frozen AI.
		if _late_active_ticks[pi] < steps / 8 or moved < 1.0:
			stuck_ok = false
		stuck_detail.append("AI%d late_active=%d/%d moved=%.1fm units=%d" % [pi,
			_late_active_ticks[pi], steps - steps / 2, moved, alive])
	check("no_ai_stuck", stuck_ok, ", ".join(stuck_detail))

	# --- check: no chat spam ------------------------------------------------
	var counts := {}
	for m in _messages:
		counts[m] = int(counts.get(m, 0)) + 1
	var max_repeat := 0
	var top := ""
	for m in counts:
		if int(counts[m]) > max_repeat:
			max_repeat = int(counts[m])
			top = str(m)
	check("no_chat_spam", max_repeat <= SPAM_LIMIT and _messages.size() <= 80,
		"messages=%d, distinct=%d, worst=%dx \"%s\" (limit %dx)" % [_messages.size(),
			counts.size(), max_repeat, top, SPAM_LIMIT])

	# --- check: game advanced / resolved without breaking ------------------
	var finite := true
	for p in game.players:
		for v in p.res:
			if not is_finite(float(v)):
				finite = false
	var progressed: bool = game.winner != -1 or game.time_s >= SIM_SECONDS - DT * 1.5
	check("game_continues_or_ends_cleanly", finite and progressed,
		"time_s=%.2f winner=%d finite_res=%s" % [game.time_s, game.winner, str(finite)])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
