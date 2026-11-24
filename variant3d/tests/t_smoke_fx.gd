# Small test: volley smoke / muzzle flash / arrow trails / artillery FX.
# Board P-20, docs/research/RE_VISUAL.md gap #1 (the top visual gap).
#
# Asserts the INTENDED behaviour of the world.gd fx layer and the game.gd
# volley / projectile event stream. Where the feature is still incomplete
# (notably the arrow trail) the check FAILS on the baseline build — that is the
# gap under test, not a test bug. Do not weaken it to make the baseline green.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-smoke-fx --timeout 90 -- \
#       --headless --path app --script res://tests/t_smoke_fx.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_smoke_fx"
var _checks: Array[Dictionary] = []
var _ok := true
var game
var world
var _fx_seen: Array[String] = []

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

# main.gd::_consume_events() only runs inside the full main scene (it also
# starts audio). Replicate just its event -> world.add_fx mapping so this
# headless test drives the same real APIs without the audio/HUD scene.
func _pump_events() -> void:
	for ev in game.events:
		var t := str(ev.get("type", ""))
		if t in ["shot", "smoke", "explode", "crater", "heal", "rout", "chop"]:
			world.add_fx(t, ev.pos)
			_fx_seen.append(t)
	game.events.clear()

func _sim(seconds: float) -> void:
	var steps := int(seconds / 0.25)
	for i in steps:
		game.tick(0.25)
		_pump_events()

# world.sync() advances fx_items and drops those whose t >= life, but it also
# reads get_viewport() which is null in a headless --script SceneTree (even
# with an explicit SubViewport). Apply the identical lifetime rule to the real
# fx_items so expire/persist can be asserted without a render viewport.
func _advance_fx(dt: float) -> void:
	for f in world.fx_items:
		f.t += dt
	world.fx_items = world.fx_items.filter(func(f): return f.t < f.life)

func _initialize() -> void:
	Data.AI_ENABLED = false
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")
	world = C3World.new()
	root.add_child(world)
	world.bind(game)
	for i in 6:
		game.players[0].res[i] += 5000.0  # iron/coal/wood for musket, arrow, shell

	# anchor on a real starting unit so every spawn stays inside the map
	var anchor := Vector2.ZERO
	for u in game.units_of(0):
		if u.sid == "peasant":
			anchor = u.pos
			break

	# ---- 1. musket volley spawns an FX item on the fx layer ---------------
	# "shot" is the muzzle flash, "smoke" is the volley puff; both are emitted
	# by game.gd::_fire() and land on world.fx_layer via add_fx().
	var shots0: int = game.stats.shots
	var fx0: int = world.fx_items.size()
	var musk = game.spawn("serdiuk", 0, anchor + Vector2(3, -3))
	var mtarget = game.spawn("pikeman", 1, anchor + Vector2(3 + 22, -3))
	game.cmd_attack(musk, mtarget)
	_sim(8.0)
	var layer_ok: bool = world.fx_layer != null and world.fx_layer.z_index == 4
	var volley_fx: bool = game.stats.shots > shots0 and world.fx_items.size() > fx0 \
		and (_fx_seen.has("shot") or _fx_seen.has("smoke")) and layer_ok
	var near_shooter := false
	var shooter_px: Vector2 = world.world_to_px(musk.pos)
	for f in world.fx_items:
		if f.has("pos") and f.pos is Vector2 and f.pos.distance_to(shooter_px) < 48.0:
			near_shooter = true
	check("volley_fx_on_layer", volley_fx and near_shooter,
		"shots +%d, fx %d->%d, events=%s, fx_layer z=%s, near-shooter=%s" % [
		game.stats.shots - shots0, fx0, world.fx_items.size(), str(_fx_seen),
		str(world.fx_layer.z_index) if layer_ok else "missing", str(near_shooter)])

	# ---- 2. muzzle flash is a distinct short-lived FX ---------------------
	world.fx_items.clear()
	_fx_seen.clear()
	world.add_fx("shot", anchor)
	world.add_fx("smoke", anchor + Vector2(2, 0))
	var shot_life := -1.0
	var smoke_life := -1.0
	for f in world.fx_items:
		if str(f.get("kind", "")) == "shot":
			shot_life = float(f.get("life", -1.0))
		if str(f.get("kind", "")) == "smoke":
			smoke_life = float(f.get("life", -1.0))
	check("muzzle_flash_short_lived", shot_life > 0.0 and shot_life < smoke_life,
		"shot life=%.2fs, smoke life=%.2fs (flash must be shorter than the puff)" % [shot_life, smoke_life])

	# ---- 3. smoke persists, then expires on the real world clock ---------
	world.fx_items.clear()
	world.add_fx("smoke", anchor + Vector2(5, 0))
	var smoke_item: Dictionary = world.fx_items[0]
	var smoke_life2 := float(smoke_item.get("life", -1.0))
	_advance_fx(0.25)
	_advance_fx(0.25)
	var smoke_t_mid: float = float(smoke_item.get("t", 0.0))
	var persists: bool = world.fx_items.has(smoke_item) and smoke_t_mid >= 0.5
	for i in 8:
		_advance_fx(0.25)
	var expired: bool = not world.fx_items.has(smoke_item)
	check("smoke_persists_then_expires", smoke_life2 > 0.5 and persists and expired,
		"life=%.2fs, alive after 0.5s=%s (t=%.2f), gone after 2.5s=%s" % [
		smoke_life2, str(persists), smoke_t_mid, str(expired)])

	# ---- 4. arrow shot produces a visible trail --------------------------
	# Intended (gap #1c): an arrow in flight leaves a streak behind it —
	# either a dedicated FX item on the fx layer or explicit trail data on
	# the projectile for the renderer to draw. The baseline draws only a 6px
	# line at the arrow head and emits no trail: this check is EXPECTED TO FAIL.
	var ashots0: int = game.stats.shots
	var archer = game.spawn("archer", 0, anchor + Vector2(-6, 6))
	var atarget = game.spawn("pikeman", 1, anchor + Vector2(-6 + 22, 6))
	game.cmd_attack(archer, atarget)
	var arrow_seen := false
	var trail_evidence := false
	for i in 48:
		game.tick(0.25)
		_pump_events()
		for pr in game.projectiles:
			if str(pr.get("kind", "")) in ["arrow", "firearrow"]:
				arrow_seen = true
				for key in ["trail", "trail_points", "trail_len", "trail_t"]:
					if pr.has(key):
						trail_evidence = true
		for f in world.fx_items:
			if str(f.get("kind", "")).contains("trail"):
				trail_evidence = true
		if arrow_seen and trail_evidence:
			break
	check("arrow_trail", game.stats.shots > ashots0 and arrow_seen and trail_evidence,
		"arrow shots +%d, in-flight arrow=%s, trail evidence=%s (baseline has no trail FX — FAIL is correct)" % [
		game.stats.shots - ashots0, str(arrow_seen), str(trail_evidence)])

	# ---- 5. artillery shell produces explosion FX ------------------------
	var cshots0: int = game.stats.shots
	var explode0: int = _fx_seen.count("explode")
	world.fx_items.clear()
	var cannon = game.spawn("cannon", 0, anchor + Vector2(0, 25))
	cannon.deploy_t = Data.ARTILLERY_DEPLOY_S + 1.0
	var ctarget = game.spawn("pikeman", 1, anchor + Vector2(45, 25))
	game.cmd_attack(cannon, ctarget)
	for i in 120:
		game.tick(0.25)
		_pump_events()
		if _fx_seen.count("explode") > explode0:
			break
	var impact_fx := false
	for f in world.fx_items:
		if str(f.get("kind", "")) in ["explode", "crater"]:
			impact_fx = true
	check("artillery_explosion_fx", game.stats.shots > cshots0 \
			and _fx_seen.count("explode") > explode0 and impact_fx,
		"cannon shots +%d, explode events +%d, explode/crater fx=%s" % [
		game.stats.shots - cshots0, _fx_seen.count("explode") - explode0, str(impact_fx)])

	# ---- 6. FX cap holds under heavy fire --------------------------------
	var cap: int = Data.FX_CAP
	var before_cap: int = world.fx_items.size()
	var adds: int = cap + 60
	for i in adds:
		world.add_fx("shot", anchor)
	check("fx_cap_respected", cap > 0 and world.fx_items.size() <= cap,
		"FX_CAP=%d, before=%d, after %d adds=%d (oldest items evicted)" % [
		cap, before_cap, adds, world.fx_items.size()])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
