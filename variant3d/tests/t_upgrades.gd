# Small test: skirmish upgrade-tree depth (board P-23, RB_MECHANICS G-02..G-05).
#
# Asserts INTENDED behaviour of the firepower/bayonet/cavalry/drill upgrade
# tree. Upgrade ids are discovered from Data.UPGRADES by their effect signature
# so the test does not depend on the exact names the feature owner chooses.
# On a build where the tree is still a single upgrade, several checks fail —
# that is the correct baseline for a pending feature, not a test bug.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-upgrades --timeout 90 -- \
#       --headless --path app --script res://tests/t_upgrades.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_upgrades"
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

# ---------------------------------------------------------------- discovery
func _eff(uid: String) -> Dictionary:
	var u: Dictionary = Data.UPGRADES.get(uid, {})
	if u.is_empty():
		return {}
	var e = u.get("effect", {})
	return e if e is Dictionary else {}

func _ids_with_effect_key(key: String) -> Array[String]:
	var out: Array[String] = []
	for uid in Data.UPGRADES:
		if _eff(str(uid)).has(key):
			out.append(str(uid))
	out.sort()
	return out

func _bullet_upgrades() -> Array[String]:
	var out: Array[String] = []
	for uid in Data.UPGRADES:
		var dm = _eff(str(uid)).get("damage_mult", {})
		if dm is Dictionary and bool(dm.has("bullet")):
			out.append(str(uid))
	out.sort()
	return out

func _ids_named(needle: String) -> Array[String]:
	var out: Array[String] = []
	for uid in Data.UPGRADES:
		var u: Dictionary = Data.UPGRADES[uid]
		var nm := (str(u.get("name", "")) + " " + str(uid)).to_lower()
		if nm.contains(needle):
			out.append(str(uid))
	out.sort()
	return out

# ------------------------------------------------------------------ the test
func _initialize() -> void:
	Data.AI_ENABLED = false
	# Soft load: a feature owner may be mid-edit on game.gd. Always write a
	# result JSON, even when the game script cannot currently be parsed.
	var GameScript = load("res://scripts/game.gd")
	if GameScript == null:
		check("game_script_loads", false, "res://scripts/game.gd failed to load (owner mid-edit?)")
		_write_result()
		call_deferred("quit", 1)
		return
	game = GameScript.new()
	root.add_child(game)
	game.setup("skirmish")

	var bullet_ids := _bullet_upgrades()

	# G-02 (a): the firepower tree has depth, not a single powder upgrade.
	var tiers := 0
	var tier_detail: Array[String] = []
	for uid in bullet_ids:
		var m := float(_eff(uid).get("damage_mult", {}).get("bullet", 1.0))
		if m > 1.0:
			tiers += 1
			tier_detail.append("%s=%.2f" % [uid, m])
	check("firepower_tiers_depth", tiers >= 3,
		"bullet damage_mult tiers with >1x = %d (need >= 3): %s" % [tiers, str(tier_detail)])

	# G-02 (b): successive firepower tiers stack via the real damage path.
	var d0: float = float(game.effective_damage(0, "bullet", Vector2.ZERO))
	var want: float = d0
	var applied := 0
	for uid in bullet_ids:
		if applied >= 2:
			break
		var m := float(_eff(uid).get("damage_mult", {}).get("bullet", 1.0))
		game.apply_upgrade(0, uid)
		want *= m
		applied += 1
	var d1: float = float(game.effective_damage(0, "bullet", Vector2.ZERO))
	var stacks: bool = applied >= 2 and d1 > d0 and absf(d1 - want) < 0.001
	check("firepower_damage_stacks", stacks,
		"effective bullet damage %.3f -> %.3f (want %.3f, %d tiers applied)" % [d0, d1, want, applied])

	# G-02 (c): flintlock shot cost -50% and wheellock/paper-cartridge RoF +35%.
	var cost_ids := _ids_with_effect_key("cost_mult")
	cost_ids.append_array(_ids_with_effect_key("shot_cost_mult"))
	var flintlock := false
	for uid in cost_ids:
		var cm = _eff(uid).get("cost_mult", _eff(uid).get("shot_cost_mult", {}))
		if cm is Dictionary:
			for k in cm:
				if float(cm[k]) < 1.0 and str(k) in ["bullet", "shot", "musket", "firearm", "gunpowder", "all"]:
					flintlock = true
		elif float(cm) < 1.0:
			flintlock = true
	var rof_ids := _ids_with_effect_key("rof_mult")
	check("flintlock_cost_and_rof", flintlock and rof_ids.size() >= 1,
		"cost-reduction effects=%s, rof_mult effects=%s" % [str(cost_ids), str(rof_ids)])

	# G-03: bayonet adds melee, steel grades raise 18c melee. Accept either a
	# multiplicative (melee_mult) or flat (melee_add) implementation, and verify
	# the effect through the real apply_upgrade path rather than a key name.
	var melee_ids := _ids_with_effect_key("melee_mult")
	melee_ids.append_array(_ids_with_effect_key("melee_add"))
	var bay_ids := _ids_named("bayonet")
	var steel_ids := _ids_named("steel")
	var add0: float = float(game.players[0].get("melee_add", 0.0))
	var mult0: float = float(game.players[0].get("melee_mult", 1.0))
	for uid in bay_ids + melee_ids:
		if not game.players[0].upgrades.has(uid):
			game.apply_upgrade(0, uid)
	var add1: float = float(game.players[0].get("melee_add", 0.0))
	var mult1: float = float(game.players[0].get("melee_mult", 1.0))
	var sword0: float = float(game.players[0].damage_mult.get("sword", 1.0))
	for uid in steel_ids:
		if not game.players[0].upgrades.has(uid):
			game.apply_upgrade(0, uid)
	var sword1: float = float(game.players[0].damage_mult.get("sword", 1.0))
	var bay_ok := add1 > add0 or mult1 > mult0
	var steel_ok := steel_ids.size() >= 1 and sword1 > sword0
	check("bayonet_melee_upgrade", bay_ok and steel_ok,
		"bayonet=%s steel=%s melee_add %.0f->%.0f melee_mult %.2f->%.2f sword %.2f->%.2f" % [
		str(bay_ids), str(steel_ids), add0, add1, mult0, mult1, sword0, sword1])

	# G-04 + G-05: cavalry recruit/attack upgrades and barracks/stable drills.
	var train_ids := _ids_with_effect_key("train_speed_mult")
	train_ids.append_array(_ids_with_effect_key("train_mult"))
	var drill_ids: Array[String] = []
	for uid in Data.UPGRADES:
		var u: Dictionary = Data.UPGRADES[uid]
		var eff := _eff(str(uid))
		var nm := (str(u.get("name", "")) + " " + str(uid)).to_lower()
		var drill_word := nm.contains("drill") or nm.contains("fencing") or nm.contains("rehearsal") \
			or nm.contains("practice") or nm.contains("training") or nm.contains("grenade")
		var prot_at_barracks := str(u.get("building", "")) in ["bar", "sta"] and eff.has("prot_bonus")
		if drill_word or prot_at_barracks:
			drill_ids.append(str(uid))
	check("cavalry_and_drills", train_ids.size() >= 1 and drill_ids.size() >= 1,
		"cavalry recruit effects=%s, drill effects=%s" % [str(train_ids), str(drill_ids)])

	# Guard: applying the same upgrade twice must not double-apply its effect.
	var dup0: float = float(game.players[0].damage_mult.get("sword", 1.0))
	game.apply_upgrade(0, "bla_sword1")
	var dup1: float = float(game.players[0].damage_mult.get("sword", 1.0))
	game.apply_upgrade(0, "bla_sword1")
	var dup2: float = float(game.players[0].damage_mult.get("sword", 1.0))
	var cnt := 0
	for uid in game.players[0].upgrades:
		if str(uid) == "bla_sword1":
			cnt += 1
	var nodup: bool = cnt == 1 and dup1 > dup0 and absf(dup1 - dup2) < 0.0001
	check("no_duplicate_application", nodup,
		"sword mult %.3f -> %.3f -> %.3f, upgrade recorded %d times" % [dup0, dup1, dup2, cnt])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
