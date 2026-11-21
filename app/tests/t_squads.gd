# Small test: squad formation / replenish / disband / bonuses (board P-22).
#
# Asserts the INTENDED donor behaviour of squads: the full infantry size ladder
# 15/36/72/120/196/400 with an officer, switchable line/column/square layout,
# replenishment from loose troops at the officer, clean disband, and the
# +2 attack / +3 defence (+9/+9 when holding) formation bonuses.
# The port currently caps squads at Data.SQUAD_MAX=195, so the 196/400 ladder
# steps fail on baseline. That is a real gap, not a test bug: do not weaken
# the assertion to match the partial implementation.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-squads --timeout 90 -- \
#       --headless --path app --script res://tests/t_squads.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_squads"
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

# Spawn one officer + one drummer + n pikemen and form them with the real API.
func _make_squad(n: int, at: Vector2) -> Dictionary:
	var off = game.spawn("officer", 0, at)
	var dru = game.spawn("drummer", 0, at)
	var mem: Array = []
	for k in n:
		mem.append(game.spawn("pikeman", 0, at))
	var s = game.squad_form([off, dru] + mem)
	return {"off": off, "dru": dru, "mem": mem, "s": s}

func _disband(s) -> void:
	if s is Dictionary and not s.is_empty() and game.squads.has(int(s.squad_id)):
		game.squad_disband(int(s.squad_id))

func _initialize() -> void:
	Data.AI_ENABLED = false
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	# 1. Donor size ladder, always led by an officer. squad_form() must produce
	# a squad whose members and label match the requested size, initially line.
	var sizes: Array[int] = [15, 36, 72, 120, 196, 400]
	var ladder_detail: Array[String] = []
	var ladder_ok := true
	for i in sizes.size():
		var n: int = sizes[i]
		var made := _make_squad(n, Vector2(60.0 + 30.0 * float(i), 60.0))
		var s = made["s"]
		var got: int = 0
		var label: int = 0
		if not s.is_empty():
			got = int(s.members.size())
			label = game._squad_label(s)
		var one: bool = not s.is_empty() and got == n and label == n \
			and int(s.officer) == int(made["off"].id) and str(s.formation) == "line"
		ladder_detail.append("%d->%d/%d" % [n, got, label])
		if not one:
			ladder_ok = false
		_disband(s)
	# An officer is mandatory: soldiers alone must never form a squad.
	var before: int = game.squads.size()
	var lone: Array = []
	for k in 15:
		lone.append(game.spawn("pikeman", 0, Vector2(60.0, 100.0)))
	var no_off = game.squad_form(lone)
	check("squad_size_ladder_with_officer",
		ladder_ok and no_off.is_empty() and game.squads.size() == before,
		"members/label per donor size " + ", ".join(ladder_detail) +
		"; no-officer form: " + ("rejected" if no_off.is_empty() else "WRONGLY ACCEPTED"))

	# 2. Formation switch. The stored formation must follow line/column/square,
	# an unknown name must be ignored, and the three shapes must actually lay
	# the same men out differently (formation_targets() is the order path).
	var made := _make_squad(15, Vector2(160.0, 200.0))
	var s = made["s"]
	var off = made["off"]
	var form_detail: Array[String] = []
	var form_ok: bool = not s.is_empty()
	for f in ["line", "column", "square"]:
		game.squad_set_formation(int(s.squad_id), str(f))
		form_ok = form_ok and str(s.formation) == str(f)
		form_detail.append("%s=%s" % [f, s.formation])
	game.squad_set_formation(int(s.squad_id), "bogus")
	form_ok = form_ok and str(s.formation) == "square"
	var sel: Array = []
	for uid in s.members:
		sel.append(game.by_id[int(uid)])
	var line = game.formation_targets(sel, off.pos, "line")
	var col = game.formation_targets(sel, off.pos, "column")
	var sq = game.formation_targets(sel, off.pos, "square")
	form_ok = form_ok and line.size() == sel.size() and col.size() == sel.size() and sq.size() == sel.size()
	form_ok = form_ok and line != col and col != sq and line != sq
	check("formation_switch_line_column_square", form_ok,
		", ".join(form_detail) + " (bogus ignored); target layouts line/col/sq=" +
		"%d/%d/%d for %d men" % [line.size(), col.size(), sq.size(), sel.size()])

	# 3. Replenish at the officer: loose same-type troops within 6 m join up to
	# the wanted size; a distant unit and a different (cavalry) type stay loose.
	s["target"] = 36
	var loose: Array = []
	for k in 5:
		loose.append(game.spawn("pikeman", 0, off.pos + Vector2(1.0 + 0.5 * float(k), 0.0)))
	var far = game.spawn("pikeman", 0, off.pos + Vector2(20.0, 0.0))
	var other = game.spawn("cossack", 0, off.pos + Vector2(2.0, 2.0))
	var got = game.cmd_replenish(off)
	var absorbed := 0
	for u in loose:
		if int(u.get("squad", 0)) == int(s.squad_id):
			absorbed += 1
	check("replenish_at_officer",
		got == 5 and absorbed == 5 and int(s.members.size()) == 20 \
			and not far.has("squad") and not other.has("squad"),
		"cmd_replenish=%d, loose absorbed=%d, members %d->20, far/wrong-type left loose" % [got, absorbed, int(s.members.size())])

	# 4. Formation bonuses: infantry melee +2 atk / +3 def, +9/+9 on hold,
	# and no bonus at all without the drummer (donor formation requirement).
	var pike = game.by_id[int(s.members[0])]
	pike.hold = false
	var atk = game._formation_atk(pike, "pike")
	var def = game._formation_def(pike)
	pike.hold = true
	var atk_hold = game._formation_atk(pike, "pike")
	var def_hold = game._formation_def(pike)
	pike.hold = false
	var drummer_id := int(s.drummer)
	s["drummer"] = 0
	var atk_no_drum = game._formation_atk(pike, "pike")
	var def_no_drum = game._formation_def(pike)
	s["drummer"] = drummer_id
	check("formation_bonuses_2_3_hold_9",
		atk == 2 and def == 3 and atk_hold == 9 and def_hold == 9 and atk_no_drum == 0 and def_no_drum == 0,
		"atk/def move=%d/%d hold=%d/%d no-drummer=%d/%d" % [atk, def, atk_hold, def_hold, atk_no_drum, def_no_drum])

	# 5. Disband: the squad is removed and every member loses its back-link.
	var sid := int(s.squad_id)
	var first_member := int(s.members[0])
	game.squad_disband(sid)
	check("disband_clears_squad",
		not game.squads.has(sid) and game.squad_of_unit(int(off.id)).is_empty() \
			and game.squad_of_unit(first_member).is_empty() \
			and not off.has("squad") and not game.by_id[first_member].has("squad"),
		"squad %d erased; officer/member squad_of_unit empty and 'squad' keys removed" % sid)

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
