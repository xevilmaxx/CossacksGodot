# Global settings for the whole game: one JSON file, read when the game starts.
#
#   app/config.json          the settings file itself - edit it and the game
#                            changes; it is read before anything is built.
#   --config <file.json>     read another file instead (merged over the first)
#   --dump-config            print the settings the game is running with
#
# Every key is optional: a key that is not in the file keeps the number from
# the original game (scripts/data.gd). The source of every number is written
# down in MECHANICS.md.
extends RefCounted
class_name C3Config

const FILE_NAME := "config.json"

# R06 C1 / donor dmscript.global:781-786,235: six lobby ids
# (none=-1, easy=0, normal=1, hard=2, veryhard=3, impossible=4). "none" marks a
# human slot, so the sim's canonical tiers are these five, in donor order.
const AI_DIFFICULTIES := ["easy", "normal", "hard", "veryhard", "impossible"]

# Donor-backed tier defaults (PE = units/global.inc/progresseconomicai.inc).
# Documented for the W2-4 / main.gd / game.gd hand-off only: config.gd does not
# apply them and leaves ai.gd behaviour and the game.gd resource cheat alone.
#   easy        maxLevelAtt/Def 0/0 (PE:2205-2208), divers 0 (unset PE:2321),
#               mine maxlevel 2 (PE:3654), cannon_count div 2 (PE:2355)
#   normal      maxLevelAtt/Def 2/3 (PE:2209-2212), divers 0 (PE:2323),
#               mine maxlevel 3 (PE:3655) - the unchanged port default
#   hard        inherited 7/7 (PE:2202-2203), divers 2 (PE:2324),
#               mine maxlevel 4 (PE:3656), howitzer 2..8 / mortar 8..40 (PE:2349-2352)
#   veryhard    inherited 7/7, divers 4 (PE:2325), mine maxlevel 5 (PE:3657),
#               artillery as hard
#   impossible  inherited 7/7, divers 4 (PE:2326), mine maxlevel 5 (PE:3658),
#               artillery as hard
const AI_TIER_EFFECTS := {
	"easy": {"max_level_att": 0, "max_level_def": 0, "divers": 0, "mine_maxlevel": 2},
	"normal": {"max_level_att": 2, "max_level_def": 3, "divers": 0, "mine_maxlevel": 3},
	"hard": {"max_level_att": 7, "max_level_def": 7, "divers": 2, "mine_maxlevel": 4},
	"veryhard": {"max_level_att": 7, "max_level_def": 7, "divers": 4, "mine_maxlevel": 5},
	"impossible": {"max_level_att": 7, "max_level_def": 7, "divers": 4, "mine_maxlevel": 5},
}

# The base values. config.json is merged over this, so a file that only
# changes one line still works.
const DEFAULT := {
	"display": {
		"window_width": 1280,
		"window_height": 720,
		"fullscreen": false,
		"vsync": true,
		"pixels_per_meter": 16.0,
		"fog_of_war": false,
		# Quality preset supplies terrain_px / sprite_cell / fx_cap and the
		# fog + minimap rates. Keeping high-quality numbers here as defaults
		# made a low/medium preset only half apply (forced high render cost).
		"quality": "high",
		"unit_scale": 1.25,
		"show_centroids": false,
		"units_opaque": true,
	},
	"camera": {
		"pitch_degrees": -32.0,
		"min_height": 20.0,
		"max_height": 58.0,
		"edge_margin": 8.0,
		"corner_margin": 24.0,
		"key_scroll_speed": 96.0,
		"mouse_scroll_speed": 64.0,
		"zoom_step": 1.15,
	},
	"gameplay": {
		"mode": "skirmish",
		"map_width_tiles": 320,
		"map_height_tiles": 320,
		"random_seed": 20261113,
		"nation0": "ukr",
		"nation1": "rus",
		"map_type": "land",
		# P-19/P-14: exact PORT-MENU keys/defaults (menu.gd:34-37, :435).
		"terrain_type": "land",
		"richness": "med",
		"season": "summer",
		"relief": "plains",
		"start_option": "default",
		"start_resources": {"food": 800, "wood": 800, "stone": 400, "gold": 200, "iron": 150, "coal": 150},
		"start_peasants": 8,
		"build_queue_limit": 10,
		"max_builders_sent": 8,
		"victory": "destroy_all",
		"score_limit": 5000,
		"max_tick_seconds": 0.25,
		"corpse_life": 90.0,
		"deposits": {"gold": 40000, "iron": 30000, "coal": 30000},
		"battle_army": {"pikeman": 16, "serdiuk": 12, "archer": 8, "cossack": 8, "officer": 1, "cannon": 2},
	},
	"economy": {
		"gather": {
			"food": {"hits": 22, "carry": 45, "interval": 1.25},
			"wood": {"hits": 14, "carry": 28, "interval": 1.25},
			"stone": {"hits": 20, "carry": 40, "interval": 1.25},
		},
		"build_progress_per_hit": 0.359375,
		"build_hit_interval": 1.25,
		"max_builders": 30,
		"mine_income_per_second": 1.664,
		"delivery_radius_m": 6.0,
		"upkeep_divisor": 625.0,
		"personal_space": 0.35,
		"formation_spacing": 1.2,
		"morale_base": 70.0,
		"morale_rout_threshold": 25.0,
		"officer_damage_bonus": 0.15,
		"drummer_speed_bonus": 0.12,
		"priest_heal_per_second": 5.0,
		"artillery_deploy_seconds": 2.0,
		"famine_grace_seconds": 120.0,
		"famine_drain_per_second": 0.3,
		"market_rate": 0.65,
	},
	"ai": {
		"enabled": true,
		"think_interval": 1.0,
		"food_threshold": 260.0,
		"wood_threshold": 260.0,
		"stone_threshold": 160.0,
		"attack_force": 60.0,
		"max_peasants": 14.0,
		"difficulty": "normal",
	},
	"audio": {
		"enabled": true,
		"master_volume_db": 0.0,
		"ambient_volume_db": -12.0,
	},
	"controls": {
		"hotkeys": {
			"attack_move": "A",
			"stand_ground": "S",
			"no_stand_ground": "C",
			"guard": "G",
			"patrol": "Q",
			"stop": "Ctrl+S",
			"hold_fire": "D",
			"feuer_frei": "E",
			"engage": "V",
			"select_all": "Ctrl+A",
			"select_idle_peasants": "Ctrl+P",
			"select_all_buildings": "Ctrl+B",
			"select_same_type": "Z",
			"pause": "Space",
			"squad_form": "F",
			"squad_disband": "Shift+F",
			"squad_line": "J",
			"squad_column": "K",
			"squad_square": "L",
			"attack_ground": "R",
			"unload": "U",
			"sow_fields": "Y",
			"select_all_peasants": "Ctrl+`",
			"select_idle_mines": "Ctrl+M",
			"add_same_type": "Shift+Z",
			# PORT-CONTROL hand-off / donor hotkeys.cfg: militaryunits, allships,
			# same-type select variants (Ctrl+Z / Ctrl+Shift+Z), donation patrol P.
			"select_military_units": "Ctrl+Alt+A",
			"select_all_ships": "Ctrl+Q",
			"select_all_same_type": "Ctrl+Z",
			"add_all_same_type": "Ctrl+Shift+Z",
			"patrol_waypoints": "P",
			"minimap_toggle": "Alt+M",
			"build": {
				"cen": "C", "hou": "H", "bla": "L", "bar": "B", "aca": "E", "sta": "S",
				"art": "R", "mil": "I", "sto": "O", "mar": "M", "tow": "T", "mine": "N", "wal": "W",
				"dip": "D", "bar18": "K",
			},
		},
	},
	"names": {
		"units": {
			"peasant": "Peasant",
			"pikeman": "Pikeman, 17th century",
			"roundshier": "Roundshier",
			"serdiuk": "Serdiuk",
			"archer": "Archer",
			"grenadier": "Grenadier",
			"musk18": "Musketeer, 18th century",
			"officer": "Officer, 17th century",
			"officer18": "Officer, 18th century",
			"drummer": "Drummer",
			"priest": "Priest",
			"cossack": "Sich Cossack",
			"dragoon": "Dragoon, 18th century",
			"cannon": "Cannon",
			"howitzer": "Howitzer",
			"mortar": "Mortar",
		},
		"buildings": {
			"cen": "Town Hall",
			"hou": "Dwelling",
			"bar": "Barracks",
			"bar18": "Barracks, 18th century",
			"sta": "Stable",
			"bla": "Blacksmith",
			"aca": "Academy",
			"dip": "Diplomatic Center",
			"sto": "Storehouse",
			"mil": "Mill",
			"mar": "Market",
			"art": "Artillery Depot",
			"tow": "Tower",
			"wal": "Stone Wall",
			"mine": "Mine",
			"mine_gold": "Gold Mine",
			"mine_iron": "Iron Mine",
			"mine_coal": "Coal Mine",
		},
		"player": ["Ukraine", "Russia"],
	},
}

var data: Dictionary = {}          # the settings the game runs with
var source := ""                   # where they were read from
var problems: Array = []           # what was wrong with the file (shown to the person)
static var active = null           # the settings in use

# ------------------------------------------------------------------ loading
# Reads the settings file and puts the result in `data`.
func load_all(extra_path := "") -> void:
	var base: Dictionary = _copy(DEFAULT)
	var found := ""
	for p in _candidate_paths(""):
		var txt := _read(p)
		if txt != "":
			found = p
			base = _merge(base, _parse(txt, p))
			break
	if extra_path != "":
		var extra_ok := false
		for p in _candidate_paths(extra_path):
			var txt2 := _read(p)
			if txt2 != "":
				found = p
				base = _merge(base, _parse(txt2, p))
				extra_ok = true
				break
		if not extra_ok:
			problems.append("extra settings file not found: %s" % extra_path)
	data = base
	source = found if found != "" else "built-in defaults"
	# third layer: user options from the in-game Options panel
	var opt_txt := _read("user://options.json")
	if opt_txt != "":
		var opt := _parse(opt_txt, "user://options.json")
		if opt is Dictionary:
			base = _merge(base, opt)
			data = base
	active = self

# Where a settings file may live: the project folder (res://), the same
# folder on disk (next to the game, for exported copies), the user's own
# folder, and an absolute path.
func _candidate_paths(given: String) -> Array:
	var out: Array = []
	if given != "":
		if given.is_absolute_path():
			out.append(given)
		else:
			out.append(ProjectSettings.globalize_path("res://").path_join(given))
			out.append(given)
			out.append("user://" + given.get_file())
		return out
	out.append("res://" + FILE_NAME)
	out.append(ProjectSettings.globalize_path("res://" + FILE_NAME))
	out.append("user://" + FILE_NAME)
	return out

func _read(path: String) -> String:
	if path.begins_with("res://"):
		if not FileAccess.file_exists(path):
			return ""
	elif path.begins_with("user://"):
		if not FileAccess.file_exists(path):
			return ""
	elif not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var txt := f.get_as_text()
	f.close()
	return txt

func _parse(txt: String, path: String) -> Dictionary:
	if txt.is_empty():
		return {}
	# a text file may start with a byte order mark; the JSON reader stops there
	if txt.length() > 0 and txt.unicode_at(0) == 0xFEFF:
		txt = txt.substr(1)
	var res: Variant = JSON.parse_string(txt)
	if res == null:
		problems.append("could not read the settings file %s (not valid JSON) - the original values are used" % path)
		return {}
	if not (res is Dictionary):
		problems.append("the settings file %s must hold an object at the top" % path)
		return {}
	return res

# ------------------------------------------------------------------ helpers
static func _copy(v: Variant) -> Variant:
	if v is Dictionary:
		var src: Dictionary = v
		var d := {}
		for k in src:
			d[k] = _copy(src[k])
		return d
	if v is Array:
		var arr: Array = v
		var a := []
		for x in arr:
			a.append(_copy(x))
		return a
	if v is float:
		# a JSON file has only one kind of number; a whole number becomes an
		# integer here, so the game keeps the same kinds of numbers as the
		# original data files it was built from
		var f: float = v
		if is_equal_approx(f, round(f)) and absf(f) < 9.2e18:
			return int(round(f))
	return v

# Dictionaries are merged key by key; everything else (arrays, numbers,
# strings) replaces the old value.
static func _merge(dst: Dictionary, src: Dictionary) -> Dictionary:
	for k in src:
		if dst.has(k) and dst[k] is Dictionary and src[k] is Dictionary:
			_merge(dst[k], src[k])
		else:
			dst[k] = _copy(src[k])
	return dst

# A value from the settings, with a fallback when it is not there.
func value(path: String, fallback: Variant) -> Variant:
	var cur: Variant = data
	for part in path.split("."):
		if cur is Dictionary and cur.has(part):
			cur = cur[part]
		else:
			return fallback
	return cur

func num(path: String, fallback: float) -> float:
	var v: Variant = value(path, fallback)
	return float(v) if (v is float or v is int) else fallback

func flag(path: String, fallback: bool) -> bool:
	var v: Variant = value(path, fallback)
	return bool(v) if (v is bool) else fallback

func text(path: String, fallback: String) -> String:
	var v: Variant = value(path, fallback)
	return str(v) if (v is String) else fallback

func section(name: String) -> Dictionary:
	# Go through value() so dotted names such as "controls.hotkeys" reach the
	# nested table; data.get() treated the whole string as one literal key.
	var v: Variant = value(name, {})
	return v if v is Dictionary else {}

# ------------------------------------------------------------------ applying
# Puts the settings into the game data. Everything else in the game reads
# its numbers from scripts/data.gd, so this is the only place that has to
# know how a setting is named.
func apply() -> void:
	const Data = preload("res://scripts/data.gd")

	var disp := section("display")
	Data.WINDOW_WIDTH = int(num("display.window_width", 1280))
	Data.WINDOW_HEIGHT = int(num("display.window_height", 720))
	Data.FULLSCREEN = flag("display.fullscreen", false)
	Data.VSYNC = flag("display.vsync", true)
	Data.PIXELS_PER_METER = num("display.pixels_per_meter", 16.0)
	Data.FOG_OF_WAR = flag("display.fog_of_war", false)
	# Preset first: it sets the render-cost values, and the explicit display
	# keys below override only what the person actually wrote in the file.
	Data.set_quality(text("display.quality", "high"))
	Data.TERRAIN_PX = clampi(int(num("display.terrain_px", Data.TERRAIN_PX)), 1, 64)
	Data.SPRITE_CELL = int(num("display.sprite_cell", Data.SPRITE_CELL))
	Data.FX_CAP = int(num("display.fx_cap", Data.FX_CAP))
	Data.FOG_INTERVAL = num("display.fog_interval", Data.FOG_INTERVAL)
	Data.MINIMAP_INTERVAL = num("display.minimap_interval", Data.MINIMAP_INTERVAL)
	Data.UNIT_SCALE = clampf(num("display.unit_scale", 1.25), 0.25, 4.0)
	Data.SHOW_CENTROIDS = flag("display.show_centroids", false)
	Data.UNITS_OPAQUE = flag("display.units_opaque", true)
	Data.CAPTURE_ENABLED = flag("rules.peasant_capture", true)

	var cam := section("camera")
	Data.CAMERA_PITCH = num("camera.pitch_degrees", -32.0)
	Data.CAMERA_MIN_HEIGHT = num("camera.min_height", 20.0)
	Data.CAMERA_MAX_HEIGHT = num("camera.max_height", 58.0)
	Data.CAMERA_EDGE_MARGIN = num("camera.edge_margin", 8.0)
	Data.CAMERA_CORNER_MARGIN = num("camera.corner_margin", 24.0)
	Data.CAMERA_KEY_SPEED = num("camera.key_scroll_speed", 96.0)
	Data.CAMERA_MOUSE_SPEED = num("camera.mouse_scroll_speed", 64.0)
	Data.CAMERA_ZOOM_STEP = num("camera.zoom_step", 1.15)

	var gp := section("gameplay")
	Data.MAP_W = maxi(16, int(num("gameplay.map_width_tiles", 320)))
	Data.MAP_H = maxi(16, int(num("gameplay.map_height_tiles", 320)))
	Data.RANDOM_SEED = int(num("gameplay.random_seed", 20261113))
	Data.START_PEASANTS = maxi(0, int(num("gameplay.start_peasants", 8)))
	Data.BUILD_QUEUE_LIMIT = maxi(1, int(num("gameplay.build_queue_limit", 10)))
	Data.MAX_BUILDERS_SENT = maxi(1, int(num("gameplay.max_builders_sent", 8)))
	Data.VICTORY = text("gameplay.victory", "destroy_all")
	Data.SCORE_LIMIT = num("gameplay.score_limit", 5000.0)
	Data.TICK_MAX = maxf(0.01, num("gameplay.max_tick_seconds", 0.25))
	Data.CORPSE_LIFE = num("gameplay.corpse_life", 90.0)
	var sr: Variant = section("gameplay").get("start_resources", {})
	var start_res := {}
	for r in Data.RES_NAMES:
		start_res[r] = float(sr.get(r, 0.0)) if sr is Dictionary else 0.0
	Data.START_RESOURCES = start_res
	var dep: Variant = section("gameplay").get("deposits", {})
	var deps := {}
	for r in Data.RES_NAMES:
		deps[r] = float(dep.get(r, 0.0)) if dep is Dictionary else 0.0
	Data.DEPOSITS = deps
	var army: Variant = section("gameplay").get("battle_army", {})
	Data.BATTLE_ARMY = army if army is Dictionary else {}
	Data.MAP_TYPE = text("gameplay.terrain_type", text("gameplay.map_type", "land"))
	Data.BIOME = text("gameplay.season", text("gameplay.biome", "summer"))
	Data.RICHNESS = text("gameplay.richness", "med")
	Data.RELIEF = text("gameplay.relief", "plains")
	Data.START_OPTION = text("gameplay.start_option", "default")
	var n0 := text("gameplay.nation0", "ukr")
	var n1 := text("gameplay.nation1", "rus")
	# T-MENU-ROSTER / T-MENU-MORE-PLAYERS: a saved config may carry the full
	# 2..12 roster. Prefer it, otherwise the legacy nation0/nation1 keys still
	# seed the two-slot default.
	var pn: Variant = section("gameplay").get("player_nations", [])
	if pn is Array and not (pn as Array).is_empty():
		var ns := []
		for code in (pn as Array):
			ns.append(str(code))
		Data.PLAYER_NATIONS = ns
		Data.PLAYER_COUNT = clampi(ns.size(), 2, Data.MAX_PLAYERS)
		Data.PLAYER_NAMES = []
		for i in ns.size():
			Data.PLAYER_NAMES.append(_nation_display(str(ns[i]), i))
	else:
		Data.PLAYER_NATIONS = [n0, n1]
		# P-42: menu/shell may override these later; apply the JSON defaults here.
		Data.PLAYER_COUNT = clampi(maxi(2, int(num("gameplay.players", 2))), 2, Data.MAX_PLAYERS)
		Data.PLAYER_NAMES = [_nation_display(n0, 0), _nation_display(n1, 1)]
	var tm: Variant = section("gameplay").get("teams", [])
	Data.TEAMS = tm.duplicate() if tm is Array else []
	# Per-slot control pick persisted by the lobby; empty keeps the sim fallback.
	Data.PLAYER_AI = []
	var pai: Variant = section("gameplay").get("player_ai", [])
	if pai is Array:
		for v in (pai as Array):
			Data.PLAYER_AI.append(bool(v))
	Data.PLAYER_AI_DIFFICULTY = []
	var pad: Variant = section("gameplay").get("player_ai_difficulty", [])
	if pad is Array:
		for v in (pad as Array):
			var d := str(v)
			Data.PLAYER_AI_DIFFICULTY.append(d if AI_DIFFICULTIES.has(d) else "normal")

	# T-MENU-ROSTER DEEP: full donor option set for saved configs. Unknown ids
	# fall back to the donor default instead of corrupting the sim.
	Data.DONOR_MAP_SHAPE = _donor_id("map_shape", Data.DONOR_MAP_SHAPES.keys(), "land")
	Data.DONOR_RELIEF_TYPE = _donor_id("relief_type", Data.DONOR_RELIEF.keys(), "plain")
	Data.DONOR_RES_START = _donor_id("resource_start", Data.DONOR_RES_START_MULT.keys(), "normal")
	Data.DONOR_RES_MINES = _donor_id("resource_mines", Data.DONOR_MINERALS, "med")
	Data.BALLOON_MODE = _donor_id("balloon", Data.DONOR_BALLOON, "default")
	Data.CANNON_MODE = _donor_id("cannons", Data.DONOR_CANNONS, "default")
	Data.CENTURY18_MODE = _donor_id("century18", Data.DONOR_CENTURY18, "default")
	Data.CAPTURE_MODE = _donor_id("capture", Data.DONOR_CAPTURE, "default")
	Data.MARKET_DIP_MODE = _donor_id("marketdip", Data.DONOR_MARKET_DIP, "default")
	Data.POP_LIMIT = clampi(int(num("gameplay.pop_limit", 0)), 0, 500)
	Data.PEACE_TIME = clampf(num("gameplay.peace_time", 0.0), 0.0, 240.0 * 60.0)
	Data.GAME_SPEED = _donor_id("game_speed", Data.DONOR_GAME_SPEED.keys(), "normal")
	Data.AUTOSAVE_MODE = _donor_id("autosave", Data.DONOR_AUTOSAVE, "off")
	Data.ADVISER_MODE = _donor_id("adviserassistant", Data.DONOR_ADVISER, "default")
	Data.ALLIES_MODE = _donor_id("allies", ["default", "nearby"], "default")
	# Saved configs may use donor ids only: resolve them to generator ids when
	# the legacy terrain_type / relief keys were not supplied.
	var gsec := section("gameplay")
	if not gsec.has("terrain_type") and not gsec.has("map_type"):
		var gen := str(Data.DONOR_MAP_SHAPES[Data.DONOR_MAP_SHAPE].get("generator", "land"))
		Data.MAP_TYPE = "land" if gen == "random" else gen
	if not gp.has("relief"):
		var rg := str(Data.DONOR_RELIEF[Data.DONOR_RELIEF_TYPE].get("relief", "plains"))
		Data.RELIEF = "plains" if rg == "random" else rg

	var ec := section("economy")
	Data.BUILD_PROGRESS_PER_HIT = num("economy.build_progress_per_hit", 0.359375)
	Data.BUILD_HIT_INTERVAL = maxf(0.05, num("economy.build_hit_interval", 1.25))
	Data.MAX_BUILDERS = maxi(1, int(num("economy.max_builders", 30)))
	Data.MINE_INCOME_PER_S = num("economy.mine_income_per_second", 1.664)
	Data.DELIVERY_RADIUS_M = num("economy.delivery_radius_m", 6.0)
	Data.UPKEEP_DIVISOR = maxf(1.0, num("economy.upkeep_divisor", 625.0))
	Data.PERSONAL_SPACE = maxf(0.0, num("economy.personal_space", 0.35))
	Data.FORMATION_SPACING = maxf(0.5, num("economy.formation_spacing", 1.2))
	Data.MORALE_BASE = num("economy.morale_base", 70.0)
	Data.MORALE_ROUT_THRESHOLD = num("economy.morale_rout_threshold", 25.0)
	Data.OFFICER_DAMAGE_BONUS = num("economy.officer_damage_bonus", 0.15)
	Data.DRUMMER_SPEED_BONUS = num("economy.drummer_speed_bonus", 0.12)
	Data.PRIEST_HEAL_PER_S = num("economy.priest_heal_per_second", 5.0)
	Data.ARTILLERY_DEPLOY_S = num("economy.artillery_deploy_seconds", 2.0)
	Data.FAMINE_GRACE_S = num("economy.famine_grace_seconds", 120.0)
	Data.FAMINE_DRAIN_PER_S = num("economy.famine_drain_per_second", 0.3)
	Data.MARKET_RATE = num("economy.market_rate", 0.65)
	var gather: Variant = section("economy").get("gather", {})
	if gather is Dictionary:
		for res in gather:
			if not Data.GATHER.has(res):
				continue
			var g: Dictionary = gather[res]
			if g is Dictionary:
				for k in g:
					Data.GATHER[res][k] = float(g[k])

	var ai := section("ai")
	Data.AI_ENABLED = flag("ai.enabled", true)
	Data.AI_THINK_INTERVAL = maxf(0.1, num("ai.think_interval", 1.0))
	Data.AI_FOOD_THRESHOLD = num("ai.food_threshold", 260.0)
	Data.AI_WOOD_THRESHOLD = num("ai.wood_threshold", 260.0)
	Data.AI_STONE_THRESHOLD = num("ai.stone_threshold", 160.0)
	Data.AI_ATTACK_FORCE = num("ai.attack_force", 60.0)
	Data.AI_MAX_PEASANTS = int(num("ai.max_peasants", 14.0))
	Data.AI_DIFFICULTY = text("ai.difficulty", "normal")
	# Legacy port-only knobs below cover easy/hard. veryhard/impossible are now
	# accepted ids but have no sim effect yet: consuming AI_TIER_EFFECTS above
	# needs ai.gd (W2-4) + per-slot wiring in main.gd/game.gd. The "normal"
	# default path is unchanged.
	if Data.AI_DIFFICULTY == "easy":
		Data.AI_THINK_INTERVAL *= 1.6
		Data.AI_ATTACK_FORCE *= 0.7
	elif Data.AI_DIFFICULTY == "hard":
		Data.AI_ATTACK_FORCE *= 1.3

	var au := section("audio")
	Data.AUDIO_ENABLED = flag("audio.enabled", true)
	Data.MASTER_VOLUME_DB = num("audio.master_volume_db", 0.0)
	Data.AMBIENT_VOLUME_DB = num("audio.ambient_volume_db", -12.0)

	# names of the units and buildings (from the original English text files)
	var names := section("names")
	var un: Dictionary = names.get("units", {})
	var bn: Dictionary = names.get("buildings", {})
	Data.UNIT_NAMES = _copy(un) if un is Dictionary else {}
	Data.BUILDING_NAMES = _copy(bn) if bn is Dictionary else {}
	var pl: Array = names.get("player", [])
	Data.PLAYER_NAMES = pl if pl is Array else ["Ukraine", "Russia"]

	# hotkeys
	var hk_def: Dictionary = _copy(DEFAULT.get("controls", {}).get("hotkeys", {}))
	var hk: Dictionary = section("controls.hotkeys")
	for action in hk:
		if action == "build":
			var bd: Dictionary = hk_def.get("build", {})
			for sid in hk[action]:
				bd[sid] = hk[action][sid]
			hk_def["build"] = bd
		else:
			hk_def[action] = hk[action]
	Data.HOTKEYS = hk_def

	# the units and the buildings themselves
	var uo: Dictionary = section("units")
	for sid in uo:
		if Data.UNITS.has(sid) and uo[sid] is Dictionary:
			_merge(Data.UNITS[sid], uo[sid])
	var bo: Dictionary = section("buildings")
	for sid in bo:
		if Data.BUILDINGS.has(sid) and bo[sid] is Dictionary:
			_merge(Data.BUILDINGS[sid], bo[sid])

# The name the game shows for a unit or a building.
static func unit_name(sid: String) -> String:
	const Data = preload("res://scripts/data.gd")
	return str(Data.UNIT_NAMES.get(sid, sid))
static func building_name(sid: String) -> String:
	const Data = preload("res://scripts/data.gd")
	return str(Data.BUILDING_NAMES.get(sid, sid))

# Donor option id with a safe default: an unknown saved value never reaches
# the sim, it falls back to the donor default and is reported via problems.
func _donor_id(key: String, allowed: Array, default: String) -> String:
	var v := text("gameplay." + key, default)
	if allowed.has(v):
		return v
	problems.append("unknown gameplay.%s='%s', using '%s'" % [key, v, default])
	return default

static func _nation_display(sid: String, i: int) -> String:
	const Data = preload("res://scripts/data.gd")
	if Data.NATIONS.has(sid):
		return str(Data.NATIONS[sid].name)
	var pl: Array = Data.PLAYER_NAMES
	if i < pl.size():
		return str(pl[i])
	return "Player %d" % (i + 1)

# A hotkey written as "Ctrl+Shift+Z" -> the key and the modifiers.
static func parse_hotkey(s: String) -> Dictionary:
	var code := 0
	var ctrl := false
	var shift := false
	var alt := false
	for part in s.split("+", false):
		var t := part.strip_edges()
		match t.to_lower():
			"ctrl", "control":
				ctrl = true
			"shift":
				shift = true
			"alt":
				alt = true
			_:
				if t != "":
					code = OS.find_keycode_from_string(t)
	return {"key": code, "ctrl": ctrl, "shift": shift, "alt": alt}

# The settings as they are now, for --dump-config.
func dump() -> String:
	return JSON.stringify(data, "  ")

# ------------------------------------------------------------------ UI scale
# One scale factor for every interface (menu + HUD), so windowed,
# fullscreen and resized windows all stay proportional. The game world is
# untouched (camera zoom owns the view); only Control fonts, paddings and
# minimum sizes multiply by this.
static func ui_scale_for(vp: Vector2) -> float:
	if vp.x <= 0.0 or vp.y <= 0.0:
		return 1.0
	return clampf(minf(vp.x / 1280.0, vp.y / 720.0), 0.75, 2.5)

static var _ui_panel_style: StyleBoxFlat = null
static var _ui_btn_styles: Dictionary = {}

# Modern shared look: flat dark parchment, soft 10px corners, brighter
# hover, dimmed disabled. Cached once, reused by every button/panel.
static func ui_panel_style() -> StyleBoxFlat:
	if _ui_panel_style == null:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(0.11, 0.09, 0.07, 0.95)
		s.set_corner_radius_all(10)
		s.set_border_width_all(1)
		s.border_color = Color(0.72, 0.60, 0.32)
		s.content_margin_left = 14
		s.content_margin_right = 14
		s.content_margin_top = 10
		s.content_margin_bottom = 10
		_ui_panel_style = s
	return _ui_panel_style

static func ui_button_styles() -> Dictionary:
	if _ui_btn_styles.is_empty():
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.17, 0.14, 0.11, 0.96)
		normal.set_corner_radius_all(8)
		normal.set_border_width_all(1)
		normal.border_color = Color(0.55, 0.45, 0.26)
		normal.content_margin_left = 12
		normal.content_margin_right = 12
		normal.content_margin_top = 7
		normal.content_margin_bottom = 7
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.24, 0.20, 0.14, 0.98)
		hover.border_color = Color(0.85, 0.70, 0.38)
		var pressed := normal.duplicate() as StyleBoxFlat
		pressed.bg_color = Color(0.10, 0.08, 0.06, 0.98)
		var disabled := normal.duplicate() as StyleBoxFlat
		disabled.bg_color = Color(0.10, 0.09, 0.08, 0.7)
		disabled.border_color = Color(0.35, 0.30, 0.22)
		_ui_btn_styles = {"normal": normal, "hover": hover, "pressed": pressed, "disabled": disabled, "focus": StyleBoxEmpty.new()}
	return _ui_btn_styles

static func ui_style_button(b: Button) -> void:
	var st := ui_button_styles()
	for k in st:
		b.add_theme_stylebox_override(k, st[k])
	b.add_theme_color_override("font_hover_color", Color(1, 0.93, 0.65))
	b.add_theme_color_override("font_pressed_color", Color(1, 0.88, 0.55))
	b.add_theme_color_override("font_disabled_color", Color(0.55, 0.52, 0.45))
