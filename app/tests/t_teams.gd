# Small test: teams / diplomacy on a random skirmish map (board P-19, P-18).
#
# Asserts INTENDED behaviour of 2v2 teams on a generated skirmish map:
#   - four players in two teams of two, each with a start/home (shared/neutral
#     start placement covers all players, not just the first two);
#   - units of an allied player are NOT acquired as targets by combat queries;
#   - an explicit attack order cannot be issued against an ally;
#   - enemy-team units ARE still acquired as targets;
#   - victory is decided per TEAM, so losing one member of a two-player team
#     does not end the match.
#
# The team model used here is the one convention that already exists in the
# codebase: `team` on a player dict (see C3AIScript._is_enemy in ai.gd) plus
# C3Game.new_player()/spawn()/setup_spawns()/enemies_in_radius()/
# enemies_preferred()/cmd_attack()/_check_victory() (real APIs).
# On the current build the simulation layer is still two-player-only, so
# several checks fail. That is the correct baseline for a pending feature,
# NOT a test bug: do not weaken these assertions to make them pass.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-teams --timeout 120 -- \
#       --headless --path app --script res://tests/t_teams.gd
extends SceneTree

const C3Game = preload("res://scripts/game.gd")
const Data = preload("res://scripts/data.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_teams"
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

func _team_of(player_index: int) -> int:
	# Team 0: players 0 and 2; team 1: players 1 and 3.
	return 0 if player_index in [0, 2] else 1

func _alive_buildings(player_index: int) -> int:
	return game.buildings_of(player_index).size()

func _initialize() -> void:
	Data.AI_ENABLED = false
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")  # full random skirmish map

	# --- build the 2v2 roster using the real player-model API -------------
	while game.players.size() < 4:
		var idx: int = game.players.size()
		game.players.append(game.new_player(idx, "Team%d" % idx, true))
	for p in game.players:
		p["team"] = _team_of(int(p["index"]))
		p["home_pos"] = Vector2(float(Data.MAP_W) * 0.125, float(Data.MAP_H) * 0.125) * float(Data.TILE_M)

	# Re-run start placement now that the roster is a 2v2: every player must
	# receive a shared/neutral start home, not just the first two.
	game.setup_spawns()

	var team_counts := {}
	for p in game.players:
		var t := int(p["team"])
		team_counts[t] = int(team_counts.get(t, 0)) + 1
	var homed := 0
	for p in game.players:
		if _alive_buildings(int(p["index"])) > 0:
			homed += 1
	var roster_ok: bool = game.players.size() == 4 \
		and int(team_counts.get(0, 0)) == 2 and int(team_counts.get(1, 0)) == 2
	check("teams_2v2_start_homes", roster_ok and homed == 4,
		"players=%d, team counts=%s, players with a home building=%d (want 4)"
		% [game.players.size(), str(team_counts), homed])

	# --- combat target acquisition must respect teams --------------------
	var probe := Vector2(float(Data.MAP_W) * 0.5, float(Data.MAP_H) * 0.5) * float(Data.TILE_M)
	var attacker = game.spawn("pikeman", 0, probe)                         # team 0
	var ally = game.spawn("pikeman", 2, probe + Vector2(1.0, 0.0))         # team 0 -> ally
	var enemy = game.spawn("pikeman", 1, probe + Vector2(6.0, 0.0))        # team 1 -> enemy
	game._grid_rebuild()

	# Small radius contains only the ally: a team-aware query must find nobody.
	var near = game.enemies_in_radius(probe, 0, 3.0)
	# Larger radius contains the closer ally and the farther enemy: a
	# team-aware preferred-target query must pick the enemy, never the ally.
	var pref = game.enemies_preferred(probe, 0, 8.0, attacker)
	var ally_excluded: bool = near.is_empty() and int(pref.get("player", -1)) == 1
	check("allies_not_targetable", ally_excluded,
		"enemies_in_radius(r=3)=%s (want empty), enemies_preferred=%s (want team-1 player 1)"
		% [str(near.get("player", -1)), str(pref.get("player", -1))])

	# Explicit attack order against an ally must be refused.
	game.cmd_attack(attacker, ally)
	var attack_order := str(attacker.order.get("type", ""))
	check("allied_attack_rejected", attack_order != "attack",
		"cmd_attack(player0 -> player2 ally) left order.type='%s' (want not 'attack')" % attack_order)
	attacker.order = {"type": "none"}

	# Enemies must still be targetable: probe at the enemy unit, away from ally.
	var found = game.enemies_in_radius(enemy.pos, 0, 3.0)
	var found_pref = game.enemies_preferred(enemy.pos, 0, 3.0, attacker)
	check("enemy_team_targetable", int(found.get("player", -1)) == 1 \
		and int(found_pref.get("player", -1)) == 1,
		"from team 0, enemy-team player 1 target found=%s / preferred=%s (want 1)"
		% [str(found.get("player", -1)), str(found_pref.get("player", -1))])

	# --- victory is a team decision --------------------------------------
	# Give the surviving ally a home so this check isolates victory logic
	# from the start-placement check above.
	for pi in [2, 3]:
		if game.buildings_of(pi).is_empty():
			game.spawn("hou", pi, Vector2(40.0 + float(pi) * 10.0, 40.0))
	game._grid_rebuild()
	# Eliminate ONLY player 0 (team 0); player 2 is still alive, so the team
	# is not defeated and the game must continue.
	for eid in game.players[0].entities:
		var e = game.by_id.get(int(eid), {})
		if not e.is_empty():
			e["dead"] = true
	game._grid_rebuild()
	game._check_victory()
	check("victory_respects_teams", game.winner == -1,
		"player0 eliminated but ally player2 still alive: winner=%d (want -1, no team wiped out)"
		% game.winner)

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
