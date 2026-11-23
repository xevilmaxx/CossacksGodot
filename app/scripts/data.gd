# Original Cossacks 3 stats, read from the game's own data files.
# Deep-mode decompilation fresh run 2026-11-17: C:\Games\Cossacks 3\cossacks.exe (PE x86, entry 0x8f1a08,
# sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, 18918 funcs, 12073 strings)
# waited for every result: native_strings_find peasant ev_35f172bb / pikeman ev_36f8c402 / Serdiuk ev_02657a9a /
# damage ev_b080109a / food ev_fd251932 / wood ev_a22a063b / gold ev_4c3035c2 / mine ev_e50560fd / cannon ev_7d44631c /
# .ini ev_ea29aa57 = 0 hits; engine strings XDMScript @0x958d1a ev_c58219d8, XCamera @0x958b6b/@0x959066 ev_aa633a3e,
# DMScript ev_a290cdaf, Cossacks 3 @0x96b304 ev_18cb6d74, Warning @0x955e34 ev_10cfab87;
# native_xrefs_list 0 refs ev_9945c378 ev_5a0f553a ev_1e8d950e ev_bc64940b ev_ff7ce366 ev_113114fb;
# core_feature_find Cossacks 3 ev_f2d20363 / Camera ev_f1ed6d4b / DMScript ev_1703acd5 0 funcs;
# native_function_pseudocode entry @0x8f1a08 ev_03507405 (142 lines) / sub_8f0ad4 @0x8f0ad4 ev_dec6ad57 /
# sub_47c804 @0x47c804 ev_bd3eda2b / sub_4c37dc @0x4c37dc ev_d5891fef (dlcs.ini/mods.ini) /
# sub_404574 @0x404574 ev_39b2ec80, 34 callees ev_9dbee4f4 — packed launcher, no economy/combat numbers in static code,
# so the authoritative numbers are the shipped scripts below (see ../MECHANICS.md).
# Sources per value are in ../MECHANICS.md. Conversions:
#   seconds = frames * 0.03125   (gc_time_to_frames = 32)
#   meters  = pixels / 26.6666666   (gc_pixels_to_meter)
#   tiles   = meters / 2
extends RefCounted
class_name C3Data

const FRAMES_TO_TIME := 0.03125
const PX_TO_M := 1.0 / 26.6666666
const TILE_M := 2.0

const RES_NAMES := ["food", "wood", "stone", "gold", "iron", "coal"]
const RES_ICONS := [Rect2(0, 418, 44, 38), Rect2(49, 418, 40, 38), Rect2(93, 418, 41, 38), Rect2(141, 418, 39, 38), Rect2(186, 418, 42, 38), Rect2(235, 418, 37, 38)]

# ------------------------------------------------------------------ settings
# Every number below can be changed from the global settings file
# (config.json, read when the game starts). The values that are here are the
# ones from the original game; the file overrides them. Sources in MECHANICS.md.
static var FPS := 32.0                       # game logic rate, dmscript.global:174
static var MAP_W := 160                     # tiles (the port map; original is 640)
static var MAP_H := 160
static var RANDOM_SEED := 20261113
# P-31: donor generator-version gates. Read-only from
# data/scripts/common.inc/initmapgen.inc (:78,:84,:103,:109,:121,:273,:280) and
# dogenerate.inc (:559,:573,:584,:606,:617,:628,:660,:735,:774,:1093,:1175,:1547).
# The port records the newest version (91), so every "<" gate is false and the
# legacy single-stream seeds/dumps stay byte-identical. The donor also has a <90
# gate at dogenerate.inc:660 (not in the DB_SCRIPTS summary).
static var GENERATOR_VERSION := 91
const GENERATOR_VERSION_GATES := [53, 61, 63, 68, 70, 75, 77, 80, 89, 90, 91]
static func generator_gate(v: int) -> bool:
	return int(GENERATOR_VERSION) < v
static var START_PEASANTS := 8               # estimated, the original default was not in readable files
static var START_RESOURCES := {}             # food, wood, stone, gold, iron, coal
static var DEPOSITS := {}                    # how much gold/iron/coal lies in the ground
static var BATTLE_ARMY := {}                 # the army each side gets in battle mode
static var BUILD_QUEUE_LIMIT := 10
static var MAX_BUILDERS_SENT := 8            # builders sent to one site at once
static var VICTORY := "destroy_all"          # or "score"
static var SCORE_LIMIT := 5000.0
static var TICK_MAX := 0.25                  # clamp on dt so a test never stalls
static var FOG_OF_WAR := false
static var CORPSE_LIFE := 90.0
static var CAPTURE_ENABLED := true  # match rule "peasant capture" (config rules.peasant_capture)

static var BUILD_PROGRESS_PER_HIT := 10 * 0.03125 * 1.15  # 0.359 s, dmscript.global:182
static var BUILD_HIT_INTERVAL := 1.25  # cWalkIntervalInf
static var MAX_BUILDERS := 30          # dmscript.global:159
static var PERSONAL_SPACE := 0.35      # extra gap between unit bodies (m); original keeps ranks apart
static var FORMATION_SPACING := 1.2    # grid step for group move orders (m)
static var MINE_INCOME_PER_S := 13.0 * 32.0 / 250.0  # 1.664, player.script 240-266
static var DELIVERY_RADIUS_M := 3.0 * 2.0            # 3 tiles, dmscript.global:210
static var UPKEEP_DIVISOR := 625.0      # player.script _player_ProcessResourceConsume

static var AI_ENABLED := true
static var AI_THINK_INTERVAL := 1.0
static var AI_FOOD_THRESHOLD := 260.0
static var AI_WOOD_THRESHOLD := 260.0
static var AI_STONE_THRESHOLD := 160.0
static var AI_ATTACK_FORCE := 260.0
static var AI_MAX_PEASANTS := 40
static var AI_DIFFICULTY := "normal"

# --- video-observed battle feel (see MECHANICS.md "Video pass"): volley smoke,
# officer/drummer auras, morale routing, priests, artillery dispersion and
# deploy, famine, market commission. All estimated, tunable in config.json.
static var MORALE_BASE := 70.0
static var MORALE_ROUT_THRESHOLD := 25.0
static var MORALE_OFFICER_RADIUS := 12.0
static var MORALE_OFFICER_BONUS := 20.0
static var MORALE_DRUMMER_RADIUS := 10.0
static var MORALE_DRUMMER_BONUS := 10.0
static var MORALE_LOW_HP_PENALTY := 20.0
static var MORALE_FAMINE_PENALTY := 15.0
static var OFFICER_DAMAGE_BONUS := 0.15   # +15% damage near an officer
static var DRUMMER_SPEED_BONUS := 0.12    # +12% march speed near a drummer
static var PRIEST_HEAL_RADIUS := 8.0
static var PRIEST_HEAL_PER_S := 5.0
static var ARTILLERY_DEPLOY_S := 2.0      # cannon must stand still this long
static var ARROW_DISPERSION_PX := 175.0   # weapon.script archer dispersion
static var CANNON_DISPERSION_PX := 225.0  # unit.script cannon dispersion
static var TOWER_DISPERSION_PX := 100.0   # unit.script tower dispersion
static var FAMINE_GRACE_S := 120.0        # no deaths before this long starving
static var FAMINE_DRAIN_PER_S := 0.3      # hp/s per unit after the grace
static var MARKET_RATE := 0.65            # 100 of one res buys 65 of another
static var MARKET_DRIFT := 0.02          # rate slips this much per 100 traded
# PORT-CONTROL hand-off: post-trade rate recovery. INFERRED - no donor cadence
# was found in the readable scripts; tunable, and small enough not to disturb
# the existing market tests.
static var MARKET_RECOVERY_PER_S := 0.002

static var AUDIO_ENABLED := true
static var MASTER_VOLUME_DB := 0.0
static var AMBIENT_VOLUME_DB := -12.0

static var WINDOW_WIDTH := 1280
static var WINDOW_HEIGHT := 720
static var FULLSCREEN := false
static var VSYNC := true
static var PIXELS_PER_METER := 16.0     # screen pixels per metre
static var TERRAIN_PX := 16
static var QUALITY := "high"
static var SPRITE_CELL := 160
static var FX_CAP := 220
static var FOG_INTERVAL := 0.5
static var MINIMAP_INTERVAL := 0.25
# Visual tuning (config.json / display): unit sprites are scaled by UNIT_SCALE
# so they read correctly next to donor-scale buildings. SHOW_CENTROIDS draws
# the flat round anchor disks under buildings/trees (off by default - they
# read as debug "centroid" markers). UNITS_OPAQUE keeps unit bodies solid.
static var UNIT_SCALE := 1.25
static var SHOW_CENTROIDS := false
static var UNITS_OPAQUE := true

# Donor-mask map build budget, keyed by the SAME quality preset.  The donor
# scales pattern counts by map size; the port scales them by GPU/CPU budget so
# a weak machine gets a lighter (but structurally identical) random map.
#   belts / trees / quarries / relief domes = pattern pass density
#   smooth = coastal height passes, decor = bushes + forest-border stamps
const MAPGEN := {
	"low": {"belts": [4, 5], "trees": [16, 28], "quarries": 4, "domes": 2,
		"decor": false, "stamps": false, "lake_detail": 0},
	"medium": {"belts": [5, 6], "trees": [24, 40], "quarries": 5, "domes": 3,
		"decor": true, "stamps": true, "lake_detail": 1},
	"high": {"belts": [6, 8], "trees": [34, 60], "quarries": 7, "domes": 4,
		"decor": true, "stamps": true, "lake_detail": 2},
}

static func mapgen_budget() -> Dictionary:
	return MAPGEN.get(QUALITY, MAPGEN["high"])

# Quality presets: one switch scales render cost (terrain px, sprite cells,
# fx) and update rates (fog/minimap). Called from the Options menu live
# (the caller rebuilds world caches) and at startup from config.
static func set_quality(q: String) -> void:
	QUALITY = q
	match q:
		"low":
			TERRAIN_PX = 8; SPRITE_CELL = 64; FX_CAP = 60
			FOG_INTERVAL = 1.5; MINIMAP_INTERVAL = 1.0
		"medium":
			TERRAIN_PX = 12; SPRITE_CELL = 96; FX_CAP = 120
			FOG_INTERVAL = 0.8; MINIMAP_INTERVAL = 0.5
		_:
			TERRAIN_PX = 16; SPRITE_CELL = 160; FX_CAP = 220
			FOG_INTERVAL = 0.5; MINIMAP_INTERVAL = 0.25

static var CAMERA_PITCH := -32.0        # camera.cfg FreeRotationInfo
static var CAMERA_MIN_HEIGHT := 20.0    # camera.cfg SphereHeightMin
static var CAMERA_MAX_HEIGHT := 58.0    # camera.cfg SphereHeight
static var CAMERA_EDGE_MARGIN := 8.0    # cameracontrol.inc cMargin
static var CAMERA_CORNER_MARGIN := 24.0 # cCornerMargin
static var CAMERA_KEY_SPEED := 96.0     # profile keyscrollspeed*4
static var CAMERA_MOUSE_SPEED := 64.0   # profile mousescrollspeed*4
static var CAMERA_ZOOM_STEP := 1.15

static var UNIT_NAMES := {}             # display names, from data/locale/en/units.txt
static var BUILDING_NAMES := {}         # display names, from data/locale/en/gui.txt
static var PLAYER_NAMES := ["Russia", "Bavaria", "Poland", "Sweden"]
static var PLAYER_NATIONS := ["rus", "bav", "pol", "swe"]  # country.script sids, menu picks these
# P-42 sim contract. main.gd writes these through Object.set(); keep the exact
# names/types. Defaults stay 2 players / free-for-all so existing tests hold.
static var PLAYER_COUNT := 2
static var TEAMS: Array = []
static var MAP_TYPE := "land"           # generator.cfg TerrainTypes key
static var BIOME := "summer"            # donor season: summer / winter / desert
# P-19/P-14: PORT-MENU emits terrain_type/richness/season/relief (menu.gd:34-37,
# :435). These defaults are EXACTLY the emitted defaults, so legacy dumps hold.
# terrain_type is deliberately ALIASED onto MAP_TYPE (same 6 donor values).
static var RICHNESS := "med"            # low / med / rich (donor Minerals)
static var RELIEF := "plains"           # plains / hills / mountains (donor Terrain Type)
const RICHNESS_MULT := {"low": 0.5, "med": 1.0, "rich": 1.5}   # per-node ore pool
const RICHNESS_ORE_DELTA := {"low": -1, "med": 0, "rich": 1}   # ore nodes per start (inferred)
# T5GEN: donor Minerals also controls how many mine CLUSTERS a map gets.  The
# canonical menu values are low/med/rich; poor/normal are accepted aliases so a
# richness-named config scales deterministically.  Consumed by pattern_gen.gd.
const RICHNESS_CLUSTER_SCALE := {
	"low": 0.55, "poor": 0.55,
	"med": 1.0, "normal": 1.0,
	"rich": 1.55,
}
const RELIEF_SCALE := {"plains": 1.0, "hills": 1.5, "mountains": 2.2}
const RELIEF_DOME_DELTA := {"plains": 0, "hills": 1, "mountains": 2}
# Season tint exposed for world.gd (separate worker); never stored in map_meta
# because map_meta is serialised into every --dump-map file.
const TERRAIN_TINT := {
	"summer": Color(1.0, 1.0, 1.0, 1.0),
	"winter": Color(0.86, 0.91, 1.0, 1.0),
	"desert": Color(1.0, 0.90, 0.70, 1.0),
}
static func terrain_tint(biome: String = "") -> Color:
	return TERRAIN_TINT.get(biome if biome != "" else str(BIOME), TERRAIN_TINT["summer"])
static var START_OPTION := "default"    # startingsettings.gc_mapsettings_* key
static var HOTKEYS := {}                # action -> "Ctrl+S" style binding

# Nations from data/scripts/lib/country.script _country_GetSIDByID.
# Colors are the two team colours the port draws; names are the original sids.
const NATIONS := {
	"aus": {"name": "Austria"}, "fra": {"name": "France"},
	"eng": {"name": "England"}, "spa": {"name": "Spain"},
	"rus": {"name": "Russia"}, "ukr": {"name": "Ukraine", "no18c": true},
	"pol": {"name": "Poland"}, "swe": {"name": "Sweden"},
	"pru": {"name": "Prussia"}, "ven": {"name": "Venice"},
	"tur": {"name": "Turkey", "no18c": true}, "alg": {"name": "Algeria", "no18c": true},
	"net": {"name": "Netherlands"}, "den": {"name": "Denmark"},
	"por": {"name": "Portugal"}, "pie": {"name": "Piedmont"},
	"sax": {"name": "Saxony"}, "bav": {"name": "Bavaria"},
	"hun": {"name": "Hungary"}, "swi": {"name": "Switzerland"},
	"sco": {"name": "Scotland"},
}

# Nation barracks variants: generic train-list sid -> nation unit (all in
# UNITS_BASE above; stats estimated, marked so in mechanics.json).
const NATION_UNITS := {
	"rus": {"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"},
	"ukr": {"priest": "pope"},
	"pol": {"cossack": "wingedhussar"},
	"tur": {"serdiuk": "jannisary", "musketeer": "jannisary", "cossack": "sipahi", "dragoon": "sipahi", "priest": "mullah"},
	"alg": {"serdiuk": "jannisary", "musketeer": "jannisary", "cossack": "mameluke", "dragoon": "spakh", "priest": "mullah"},
	"swe": {"cossack": "hackapell"},
	# Scotland: bagpipers plus the baked unique infantry (P-41). The baked
	# sco_units.json walk clip is DONOR-exact 0.8 s / 12 frames (swordsmansco);
	# the port's 1.08 s = n*0.09 convention is an estimate, so fidelity wins.
	"sco": {"drummer": "bagpiper", "musketeer": "sco_highlandersword", "serdiuk": "sco_highlandersword"},
}

# Nation-unique animation sheets live in a SEPARATE index (as naval/index.json
# does) so the 54-key main index and t_anim_metrics stay untouched.
static var EXTRA_ANIM_INDEX := {}
static func load_extra_anim_index() -> void:
	if not EXTRA_ANIM_INDEX.is_empty():
		return
	var path := "res://assets/models/anim/land_units/sco_units.json"
	if not FileAccess.file_exists(path):
		path = "res://assets/models/anim/sco_units.json"  # legacy flat fallback
	if not FileAccess.file_exists(path):
		return
	var raw := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(raw)
	if parsed is Dictionary:
		for k in parsed:
			EXTRA_ANIM_INDEX[k] = parsed[k]

# Random-map terrain types from data/game/var/generator.cfg TerrainTypes.
# water_frac drives how many lakes the port paints (Land ~ none, Islands ~ many).
const MAP_TYPES := {
	"land": {"water_frac": 0.5, "name": "Land"},
	"mediterranean": {"water_frac": 1.6, "name": "Mediterranean"},
	"peninsulas": {"water_frac": 1.2, "name": "Peninsulas"},
	"islands": {"water_frac": 2.2, "name": "Islands"},
	"continents": {"water_frac": 1.8, "name": "Continents"},
	"continent": {"water_frac": 1.0, "name": "Continent"},
}

# Starting options from data/game/var/startingsettings.cfg comments
# (gc_mapsettings_startingunits_*). Armies scale the battle preset.
const START_OPTIONS := {
	"default": {"army_mult": 0.0, "food": 0, "towers": 0, "cannons": 0},
	"armysmall": {"army_mult": 0.5, "food": 1000, "towers": 0, "cannons": 0},
	"armymedium": {"army_mult": 1.0, "food": 1000, "towers": 0, "cannons": 0},
	"armylarge": {"army_mult": 1.8, "food": 2000, "towers": 0, "cannons": 0},
	"towers": {"army_mult": 0.3, "food": 500, "towers": 3, "cannons": 0},
	"cannons": {"army_mult": 0.3, "food": 500, "towers": 0, "cannons": 3},
}

# Squad formations from data/game/var/formations.cfg. The port keeps the
# masks as shapes: line = wide, column = deep, square = ring. The donor's
# exact per-formation bonus tuples are imported below as FORMATION_BONUSES.
const FORMATIONS := {
	"none": {"cols_mult": 1.0, "rows_mult": 1.0},
	"line": {"cols_mult": 1.8, "rows_mult": 0.6},
	"column": {"cols_mult": 0.6, "rows_mult": 1.8},
	"square": {"cols_mult": 1.0, "rows_mult": 1.0, "hollow": true},
	"wedge": {"cols_mult": 0.5, "rows_mult": 1.4},
}

# Exact donor bonus tuples, keyed by formations.cfg id. Each value is
# [bonusdamage, bonusshield, bonusdamagehold, bonusshieldhold] read from
# C:\Games\Cossacks 3\data\game\var\formations.cfg (149 records, 46 nonzero:
# 15x(2,2,7,7), 22x(1,1,1,1), 3x(3,3,7,7), plus legacy _OLD outliers).
const FORMATION_BONUSES := {
	"none": [0, 0, 0, 0],
	"LINE3": [0, 0, 0, 0],
	"LINE4": [0, 0, 0, 0],
	"LINE5": [0, 0, 0, 0],
	"LINE6": [0, 0, 0, 0],
	"LINE7": [0, 0, 0, 0],
	"LINE8": [0, 0, 0, 0],
	"LINE9": [0, 0, 0, 0],
	"LINE10": [0, 0, 0, 0],
	"LINE3PUS": [0, 0, 0, 0],
	"LINE4PUS": [0, 0, 0, 0],
	"LINE5PUS": [0, 0, 0, 0],
	"LINE6PUS": [0, 0, 0, 0],
	"LINE7PUS": [0, 0, 0, 0],
	"LINE8PUS": [0, 0, 0, 0],
	"LINE9PUS": [0, 0, 0, 0],
	"LINE10PUS": [0, 0, 0, 0],
	"LINE11PUS": [0, 0, 0, 0],
	"LINE12PUS": [0, 0, 0, 0],
	"LINE13PUS": [0, 0, 0, 0],
	"LINE14PUS": [0, 0, 0, 0],
	"LINE15PUS": [0, 0, 0, 0],
	"LINE16PUS": [0, 0, 0, 0],
	"LINE17PUS": [0, 0, 0, 0],
	"LINE18PUS": [0, 0, 0, 0],
	"LINE19PUS": [0, 0, 0, 0],
	"LINE20PUS": [0, 0, 0, 0],
	"LINE21PUS": [0, 0, 0, 0],
	"LINE22PUS": [0, 0, 0, 0],
	"LINE23PUS": [0, 0, 0, 0],
	"LINE24PUS": [0, 0, 0, 0],
	"LINE25PUS": [0, 0, 0, 0],
	"LINE26PUS": [0, 0, 0, 0],
	"LINE27PUS": [0, 0, 0, 0],
	"LINE28PUS": [0, 0, 0, 0],
	"LINE29PUS": [0, 0, 0, 0],
	"LINE30PUS": [0, 0, 0, 0],
	"LINE31PUS": [0, 0, 0, 0],
	"LINE32PUS": [0, 0, 0, 0],
	"LINE33PUS": [0, 0, 0, 0],
	"LINE34PUS": [0, 0, 0, 0],
	"LINE35PUS": [0, 0, 0, 0],
	"LINE36PUS": [0, 0, 0, 0],
	"LINE37PUS": [0, 0, 0, 0],
	"LINE38PUS": [0, 0, 0, 0],
	"LINE39PUS": [0, 0, 0, 0],
	"LINE40PUS": [0, 0, 0, 0],
	"LINE100PUS": [0, 0, 0, 0],
	"LINEMORB5": [0, 0, 0, 0],
	"LINEMORB6": [0, 0, 0, 0],
	"LINEMORB7": [0, 0, 0, 0],
	"LINEMORB8": [0, 0, 0, 0],
	"LINEMORB9": [0, 0, 0, 0],
	"LINEMORB10": [0, 0, 0, 0],
	"LINEMORB11": [0, 0, 0, 0],
	"LINEMORB12": [0, 0, 0, 0],
	"LINEMORB13": [0, 0, 0, 0],
	"LINEMORB14": [0, 0, 0, 0],
	"LINEMORB15": [0, 0, 0, 0],
	"LINEMORB16": [0, 0, 0, 0],
	"LINEMORB17": [0, 0, 0, 0],
	"LINEMORB18": [0, 0, 0, 0],
	"LINEMORB19": [0, 0, 0, 0],
	"LINEMORB20": [0, 0, 0, 0],
	"LINE15": [2, 2, 7, 7],
	"LINE36": [2, 2, 7, 7],
	"LINE72": [2, 2, 7, 7],
	"LINE120": [2, 2, 7, 7],
	"LINE196": [2, 2, 7, 7],
	"SQUARE36": [2, 2, 7, 7],
	"SQUARE72": [2, 2, 7, 7],
	"SQUARE120": [2, 2, 7, 7],
	"SQUARE196": [2, 2, 7, 7],
	"KARE36": [2, 2, 7, 7],
	"KARE72": [2, 2, 7, 7],
	"KARE120": [2, 2, 7, 7],
	"KARE196": [2, 2, 7, 7],
	"ALONE": [0, 0, 0, 0],
	"ODIN": [0, 0, 0, 0],
	"SHIPS12": [0, 0, 0, 0],
	"SHIPS5": [0, 0, 0, 0],
	"SHIPSN5": [0, 0, 0, 0],
	"SHIPS8": [0, 0, 0, 0],
	"SHIPS3": [0, 0, 0, 0],
	"PACK20": [0, 0, 0, 0],
	"TRI_OLD": [-10, 9, 95, -19],
	"TRI2_OLD": [0, 0, 0, 0],
	"TRI3_OLD": [0, 0, 0, 0],
	"PRUS_OLD": [5, -5, -27, 80],
	"PRUS2_OLD": [0, 0, 0, 0],
	"PRUS3_OLD": [0, 0, 0, 0],
	"SHER_OLD": [2, 1, 2, 1],
	"SHER2_OLD": [1, 1, 1, 1],
	"SHER3_OLD": [0, 1, 1, 0],
	"PRUS0_OLD": [1, 1, 1, 1],
	"TRI0_OLD": [1, 1, 1, 1],
	"PRUS02_OLD": [0, 0, 0, 0],
	"PRUS03_OLD": [0, 0, 0, 0],
	"SHER0_OLD": [2, 1, 2, 1],
	"SHER02_OLD": [1, 1, 1, 1],
	"SHER03_OLD": [0, 1, 1, 0],
	"TRI02_OLD": [0, 0, 0, 0],
	"TRI03_OLD": [0, 0, 0, 0],
	"SQUARE15": [2, 2, 7, 7],
	"KARE15": [2, 2, 7, 7],
	"TRI": [1, 1, 1, 1],
	"TRI2": [1, 1, 1, 1],
	"TRI3": [1, 1, 1, 1],
	"PRUS": [1, 1, 1, 1],
	"PRUS2": [1, 1, 1, 1],
	"PRUS3": [1, 1, 1, 1],
	"SHER": [1, 1, 1, 1],
	"SHER2": [1, 1, 1, 1],
	"SHER3": [1, 1, 1, 1],
	"TRI0": [1, 1, 1, 1],
	"TRI02": [1, 1, 1, 1],
	"TRI03": [1, 1, 1, 1],
	"PRUS0": [1, 1, 1, 1],
	"PRUS02": [1, 1, 1, 1],
	"PRUS03": [1, 1, 1, 1],
	"SHER0": [1, 1, 1, 1],
	"SHER02": [1, 1, 1, 1],
	"SHER03": [1, 1, 1, 1],
	"LINE2": [0, 0, 0, 0],
	"LINE2PUS": [0, 0, 0, 0],
	"LINEMORB2": [0, 0, 0, 0],
	"LINEMORB3": [0, 0, 0, 0],
	"LINEMORB4": [0, 0, 0, 0],
	"LINE400": [3, 3, 7, 7],
	"SQUARE400": [3, 3, 7, 7],
	"KARE400": [3, 3, 7, 7],
	"LINE15NB": [0, 0, 0, 0],
	"LINE36NB": [0, 0, 0, 0],
	"LINE72NB": [0, 0, 0, 0],
	"LINE120NB": [0, 0, 0, 0],
	"LINE196NB": [0, 0, 0, 0],
	"LINE400NB": [0, 0, 0, 0],
	"SQUARE15NB": [0, 0, 0, 0],
	"SQUARE36NB": [0, 0, 0, 0],
	"SQUARE72NB": [0, 0, 0, 0],
	"SQUARE120NB": [0, 0, 0, 0],
	"SQUARE196NB": [0, 0, 0, 0],
	"SQUARE400NB": [0, 0, 0, 0],
	"KARE15NB": [0, 0, 0, 0],
	"KARE36NB": [0, 0, 0, 0],
	"KARE72NB": [0, 0, 0, 0],
	"KARE120NB": [0, 0, 0, 0],
	"KARE196NB": [0, 0, 0, 0],
	"KARE400NB": [0, 0, 0, 0],
}

# Return [bonusdamage, bonusshield, bonusdamagehold, bonusshieldhold] for a
# donor formations.cfg id; unknown ids get the all-zero tuple.
static func formation_bonuses(fid: String) -> Array:
	return FORMATION_BONUSES.get(fid, [0, 0, 0, 0])

# RB G-13: surviving squads harden with kills. XP accumulates on the squad dict
# for the whole match and adds at most SQUAD_XP_CAP points to EACH donor tuple
# field (bounded - no runaway scaling). 2 kills per point by default.
static var SQUAD_XP_PER_KILL := 1.0
static var SQUAD_XP_PER_BONUS := 2.0
static var SQUAD_XP_CAP := 3

# Donor formation ladder tops out at 400 soldiers (formations.cfg LINE400 /
# SQUARE400 / KARE400, imported in FORMATION_BONUSES above). squad_form()
# counts the officer + drummer in this cap, so 400 soldiers need 402 slots and
# the check at game.gd `total >= SQUAD_MAX` breaks *before* the next add —
# hence 403 (derived), not 400.
const SQUAD_MAX := 403

# resource gathering: hits per carried load, carried amount, source dmscript.global 799-806
const GATHER_BASE := {
	"food": {"hits": 22, "carry": 45, "interval": 1.25},
	"wood": {"hits": 14, "carry": 28, "interval": 1.25},
	"stone": {"hits": 20, "carry": 40, "interval": 1.25},
}
static var GATHER := {}
# G-13 / donor dmscript.global:222-225 gc_gameplay_resource_maxattackers_*:
# food 3, wood 2, stone 3 (none 4). Max simultaneous gatherers per resource node.
const RESOURCE_WORKERS := {"food": 3, "wood": 2, "stone": 3}

# weapon kinds — donor dmscript.global:279-286 (gc_obj_weapon_kind_*).
const WK := {"none": 0, "pike": 1, "sword": 2, "bullet": 3, "cannister": 4, "arrow": 5, "firearrow": 6, "cannonball": 7}

# Weapon kind -> slot in the port's 6-element `prot` array below.
# Donor `_misc_DoDamage` (miscext2.script:380,434) subtracts
# `protection[weapkind]` directly, i.e. it indexes by the 0..7 kind value.
# The port compresses those 8 kinds into 6 slots ordered
# [pike, sword, bullet, cannister, arrow, cannonball] (no `none`, no `firearrow`).
# -1 means "no protection slot" (kind `none`, or an unknown kind defaulting to 0).
# INFERENCE (documented): firearrow(6) has its own donor slot protection[6], but
# the port's 6-slot data cannot represent it, so it is clamped to the last valid
# slot (cannonball). This is a port-representation clamp, not donor behaviour.
const PROT_SLOT := [-1, 0, 1, 2, 3, 4, 5, 5]

# protection order: [pike, sword, bullet, cannister, arrow, cannonball]
const UNITS_BASE := {
	"peasant": {
		"hp": 75, "speed": 1.5, "score": 20, "aiforce": 1, "worker": true,
		"price": {"food": 100}, "build_time": 400 * 0.03125, "search": 300 * PX_TO_M,
		"eat": {"food": 32},
		"weapons": [{"kind": "sword", "dmg": 20, "min": 10 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(184, 0, 46, 46),
	},
	"pikeman": {
		"hp": 90, "speed": 1.2, "score": 10, "aiforce": 10,
		"price": {"food": 25, "gold": 3, "iron": 20}, "build_time": 144 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "pike", "dmg": 8, "min": 35 * PX_TO_M, "max": 100 * PX_TO_M, "cd": 1.25}],
		"prot": [3, 2, 4, 210, 6, 40],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	"roundshier": {
		"hp": 100, "speed": 1.2, "score": 7, "aiforce": 10,
		"price": {"food": 20, "gold": 3, "iron": 25}, "build_time": 128 * 0.03125, "search": 600 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "sword", "dmg": 6, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [3, 3, 7, 225, 16, 80],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"serdiuk": {
		"hp": 85, "speed": 1.2, "score": 12, "aiforce": 2, "no_melee": true,
		"price": {"food": 60, "gold": 11, "iron": 5}, "build_time": 352 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"archer": {
		"hp": 40, "speed": 1.2, "score": 15, "aiforce": 2, "no_melee": true,
		"price": {"food": 20, "wood": 2, "gold": 1}, "build_time": 48 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "arrow", "dmg": 15, "min": 400 * PX_TO_M, "max": 800 * PX_TO_M, "cd": 75 * 0.03125,
			"cost": {"wood": 1}, "splash": 20 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	"cossack": {
		"hp": 250, "speed": 3.6, "score": 35, "aiforce": 25, "cavalry": "fast",
		"price": {"food": 130, "iron": 2}, "build_time": 432 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "sword", "dmg": 13, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"dragoon": {
		"hp": 225, "speed": 2.1, "score": 40, "aiforce": 15, "cavalry": "hard",
		"price": {"food": 70, "gold": 60, "iron": 7}, "build_time": 720 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 45},
		"weapons": [{"kind": "bullet", "dmg": 19, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 170 * 0.03125,
			"cost": {"iron": 4, "coal": 5}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	"officer": {
		"hp": 125, "speed": 1.2, "score": 10, "aiforce": 5,
		"price": {"food": 50, "gold": 150, "iron": 30}, "build_time": 320 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 60},
		"weapons": [{"kind": "pike", "dmg": 30, "min": 35 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [2, 2, 5, 200, 10, 30],
		"radius": 0.35,
		"icon": Rect2(0, 184, 46, 46),
	},
	"cannon": {
		"hp": 9000, "speed": 0.75, "score": 50, "aiforce": 1, "artillery": true, "shield": 75,
		"price": {"wood": 250, "gold": 400, "iron": 400}, "build_time": 2400 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 300},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 550 * PX_TO_M, "max": 2160 * PX_TO_M, "cd": 350 * 0.03125,
			"cost": {"iron": 20, "coal": 40}, "splash": 35 * PX_TO_M},
			{"kind": "cannister", "dmg": 300, "min": 0.0, "max": 175 * PX_TO_M, "cd": 300 * 0.03125,
			"cost": {"iron": 10, "coal": 20}, "splash": 60 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(138, 230, 46, 46),
	},
	# Video pass: the original marches officers with flags, drummers beating
	# the pace, and priests in black robes healing the line (all visible in
	# any Cossacks 3 battle video). Stats estimated, marked so in mechanics.
	"officer18": {
		"hp": 140, "speed": 1.2, "score": 12, "aiforce": 6,
		"price": {"food": 60, "gold": 180, "iron": 40}, "build_time": 360 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 70},
		"weapons": [{"kind": "pike", "dmg": 32, "min": 35 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [2, 2, 5, 200, 10, 30],
		"radius": 0.35,
		"icon": Rect2(0, 184, 46, 46),
	},
	"drummer": {
		"hp": 60, "speed": 1.32, "score": 8, "aiforce": 3, "support": true,
		"price": {"food": 30, "gold": 20}, "build_time": 200 * 0.03125, "search": 6000 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(46, 184, 46, 46),
	},
	"priest": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	# Late-game roster visible in every battle video (stats estimated, marked
	# so in mechanics; grenade base 110 dmg / 50 px from weapon.script NUCLGRE).
	"grenadier": {
		"hp": 110, "speed": 1.2, "score": 18, "aiforce": 8,
		"price": {"food": 70, "gold": 15, "iron": 10}, "build_time": 400 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 35},
		"weapons": [{"kind": "cannonball", "dmg": 60, "min": 60 * PX_TO_M, "max": 420 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 2, "coal": 3}, "splash": 50 * PX_TO_M},
			{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 1, 2, 100, 4, 10],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"musk18": {
		"hp": 105, "speed": 1.2, "score": 16, "aiforce": 6,
		"price": {"food": 80, "gold": 20, "iron": 12}, "build_time": 420 * 0.03125, "search": 950 * PX_TO_M,
		"eat": {"food": 32},
		"weapons": [{"kind": "bullet", "dmg": 16, "min": 400 * PX_TO_M, "max": 950 * PX_TO_M, "cd": 140 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0},
			{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 1, 2, 120, 3, 12],
		"radius": 0.35,
		"icon": Rect2(276, 92, 46, 46),
	},
	"howitzer": {
		"hp": 6000, "speed": 0.7, "score": 60, "aiforce": 2, "artillery": true, "shield": 60,
		"price": {"wood": 300, "gold": 500, "iron": 500}, "build_time": 2600 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 350},
		"weapons": [{"kind": "cannonball", "dmg": 1200, "min": 300 * PX_TO_M, "max": 1800 * PX_TO_M, "cd": 380 * 0.03125,
			"cost": {"iron": 25, "coal": 50}, "splash": 50 * PX_TO_M},
			{"kind": "cannister", "dmg": 250, "min": 0.0, "max": 150 * PX_TO_M, "cd": 300 * 0.03125,
			"cost": {"iron": 10, "coal": 20}, "splash": 55 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(184, 230, 46, 46),
	},
	"mortar": {
		"hp": 3500, "speed": 0.9, "score": 45, "aiforce": 2, "artillery": true, "shield": 40,
		"price": {"wood": 200, "gold": 300, "iron": 300}, "build_time": 2000 * 0.03125, "search": 480 * PX_TO_M,
		"eat": {"gold": 250},
		"weapons": [{"kind": "cannonball", "dmg": 900, "min": 400 * PX_TO_M, "max": 2000 * PX_TO_M, "cd": 320 * 0.03125,
			"cost": {"iron": 15, "coal": 35}, "splash": 60 * PX_TO_M, "only_buildings": true}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.55,
		"icon": Rect2(230, 230, 46, 46),
	},
	# ---- nation-variety roster (Step 3; stats estimated unless wiki-sourced,
	# marked so in mechanics.json). Baked sheets in assets/models/anim.
	"musketeer": {
		"hp": 85, "speed": 1.2, "score": 12, "aiforce": 2, "no_melee": true,
		"price": {"food": 60, "gold": 11, "iron": 5}, "build_time": 352 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(276, 92, 46, 46),
	},
	"strelet": {
		"hp": 85, "speed": 1.2, "score": 12, "aiforce": 2, "no_melee": true,
		"price": {"food": 60, "gold": 11, "iron": 5}, "build_time": 352 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"pikeman18": {
		"hp": 120, "speed": 1.2, "score": 14, "aiforce": 12,
		"price": {"food": 40, "gold": 8, "iron": 30}, "build_time": 200 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "pike", "dmg": 10, "min": 35 * PX_TO_M, "max": 100 * PX_TO_M, "cd": 1.25}],
		"prot": [4, 3, 8, 210, 6, 40],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	"dragoon17": {
		"hp": 200, "speed": 2.1, "score": 35, "aiforce": 12, "cavalry": "hard",
		"price": {"food": 60, "gold": 40, "iron": 5}, "build_time": 600 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 45},
		"weapons": [{"kind": "bullet", "dmg": 15, "min": 400 * PX_TO_M, "max": 850 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 3, "coal": 4}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	"hussar": {
		"hp": 220, "speed": 3.6, "score": 32, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 110, "gold": 20}, "build_time": 400 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 15, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"wingedhussar": {
		"hp": 260, "speed": 3.6, "score": 45, "aiforce": 25, "cavalry": "fast",
		"price": {"food": 130, "gold": 30, "iron": 5}, "build_time": 480 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "pike", "dmg": 18, "min": 25 * PX_TO_M, "max": 75 * PX_TO_M, "cd": 1.0}],
		"prot": [2, 2, 4, 100, 3, 20],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"cuirassier": {
		"hp": 300, "speed": 2.1, "score": 48, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 120, "gold": 60, "iron": 20}, "build_time": 640 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "sword", "dmg": 20, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [3, 3, 8, 150, 5, 30],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"reiter": {
		"hp": 230, "speed": 2.1, "score": 38, "aiforce": 15, "cavalry": "hard",
		"price": {"food": 90, "gold": 50, "iron": 8}, "build_time": 560 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 50},
		"weapons": [{"kind": "bullet", "dmg": 14, "min": 350 * PX_TO_M, "max": 800 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 3, "coal": 4}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	"lightcavalry": {
		"hp": 180, "speed": 3.6, "score": 28, "aiforce": 18, "cavalry": "fast",
		"price": {"food": 90, "gold": 10}, "build_time": 360 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 50},
		"weapons": [{"kind": "sword", "dmg": 12, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"lightinfantry": {
		"hp": 70, "speed": 1.32, "score": 10, "aiforce": 4, "no_melee": true,
		"price": {"food": 40, "gold": 5}, "build_time": 240 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 25},
		"weapons": [{"kind": "bullet", "dmg": 10, "min": 300 * PX_TO_M, "max": 750 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 2, "coal": 4}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	"tatar": {
		"hp": 170, "speed": 3.6, "score": 30, "aiforce": 18, "cavalry": "fast", "no_melee": true,
		"price": {"food": 80, "wood": 10}, "build_time": 360 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 50},
		"weapons": [{"kind": "arrow", "dmg": 12, "min": 350 * PX_TO_M, "max": 750 * PX_TO_M, "cd": 75 * 0.03125,
			"cost": {"wood": 1}, "splash": 20 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"sipahi": {
		"hp": 260, "speed": 2.1, "score": 42, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 110, "gold": 40, "iron": 10}, "build_time": 520 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 18, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [1, 1, 3, 100, 2, 15],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"jannisary": {
		"hp": 95, "speed": 1.2, "score": 15, "aiforce": 6, "no_melee": true,
		"price": {"food": 65, "gold": 15, "iron": 6}, "build_time": 380 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 14, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 135 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"spakh": {
		"hp": 240, "speed": 2.1, "score": 38, "aiforce": 20, "cavalry": "hard",
		"price": {"food": 100, "gold": 30, "iron": 8}, "build_time": 480 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [1, 1, 2, 80, 2, 10],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"mameluke": {
		"hp": 250, "speed": 2.1, "score": 40, "aiforce": 20, "cavalry": "hard",
		"price": {"food": 105, "gold": 35, "iron": 8}, "build_time": 500 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 17, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [1, 1, 2, 80, 2, 10],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"vityaz": {
		"hp": 280, "speed": 2.1, "score": 44, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 115, "gold": 50, "iron": 15}, "build_time": 560 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 58},
		"weapons": [{"kind": "sword", "dmg": 19, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [2, 2, 5, 120, 3, 20],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"hetman": {
		"hp": 260, "speed": 3.6, "score": 42, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 120, "gold": 60, "iron": 20}, "build_time": 500 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [1, 1, 2, 80, 2, 10],
		"radius": 0.5,
		"icon": Rect2(0, 184, 46, 46),
	},
	"croat": {
		"hp": 75, "speed": 1.32, "score": 9, "aiforce": 5,
		"price": {"food": 30, "gold": 3}, "build_time": 160 * 0.03125, "search": 650 * PX_TO_M,
		"eat": {"food": 28},
		"weapons": [{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 1, 50, 1, 10],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"pandur": {
		"hp": 80, "speed": 1.32, "score": 10, "aiforce": 5,
		"price": {"food": 35, "gold": 5}, "build_time": 180 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 28},
		"weapons": [{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 1, 50, 1, 10],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"chasseur": {
		"hp": 90, "speed": 1.32, "score": 13, "aiforce": 6, "no_melee": true,
		"price": {"food": 55, "gold": 12, "iron": 6}, "build_time": 320 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 13, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 135 * 0.03125,
			"cost": {"iron": 3, "coal": 5}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	"highlander": {
		"hp": 95, "speed": 1.2, "score": 12, "aiforce": 8,
		"price": {"food": 45, "gold": 5, "iron": 10}, "build_time": 220 * 0.03125, "search": 650 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "sword", "dmg": 10, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 1, 2, 60, 2, 15],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"pope": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	"padre": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	"mullah": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	"drummer18": {
		"hp": 70, "speed": 1.32, "score": 9, "aiforce": 3, "support": true,
		"price": {"food": 35, "gold": 25}, "build_time": 220 * 0.03125, "search": 6000 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(46, 184, 46, 46),
	},
	"multicannon": {
		"hp": 7000, "speed": 0.7, "score": 55, "aiforce": 2, "artillery": true, "shield": 60,
		"price": {"wood": 350, "gold": 450, "iron": 450}, "build_time": 2500 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 320},
		"weapons": [{"kind": "cannister", "dmg": 300, "min": 60 * PX_TO_M, "max": 500 * PX_TO_M, "cd": 300 * 0.03125,
			"cost": {"iron": 15, "coal": 30}, "splash": 60 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(138, 230, 46, 46),
	},
	# Baked sprite keys from RA G08 that had no sim row. cossackdon/hackapell
	# were already named by NATION_UNITS, so without these rows those mappings
	# silently failed callers that check UNITS.has() (e.g. the AI army picker).
	"cossackdon": {
		"hp": 220, "speed": 3.6, "score": 32, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 110, "gold": 25}, "build_time": 400 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 15, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"hackapell": {
		"hp": 210, "speed": 3.6, "score": 34, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 110, "gold": 30}, "build_time": 400 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"sco_highlandersword": {
		# Scottish unique infantry (donor swordsmansco). Sprites/metrics come
		# from sco_units.json; stats estimated against strelet/pikeman18 until
		# a donor unit-stat read exists (quality-first: UNVERIFIED).
		"hp": 100, "speed": 1.2, "score": 14, "aiforce": 6,
		"price": {"food": 60, "gold": 12, "iron": 8}, "build_time": 380 * 0.03125,
		"search": 700 * PX_TO_M, "eat": {"food": 32},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 10 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.1}],
		"prot": [2, 2, 4, 100, 3, 20],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	"cossackregister": {
		"hp": 240, "speed": 2.1, "score": 38, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 120, "gold": 35, "iron": 5}, "build_time": 480 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "sword", "dmg": 17, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [2, 2, 4, 100, 3, 20],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"bagpiper": {
		"hp": 60, "speed": 1.32, "score": 9, "aiforce": 3, "support": true,
		"price": {"food": 30, "gold": 25}, "build_time": 200 * 0.03125, "search": 6000 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(46, 184, 46, 46),
	},
	# P-10 naval: static hull + crew sheets baked in app/assets/models/anim/naval_units/
	# (index.json: hull ortho 11.355, crew ortho 6.047). Movement/shape flags are
	# donor-evidenced; hp/speed/dmg/price are ESTIMATED (NAVAL_PORT_PLAN §5 Q2).
	"yacht": {
		"hp": 900, "speed": 2.8, "score": 60, "aiforce": 12, "naval": true,
		"price": {"wood": 220, "gold": 120, "iron": 60}, "build_time": 1600 * 0.03125, "search": 1200 * PX_TO_M,
		"eat": {"gold": 40},
		"weapons": [{"kind": "cannonball", "dmg": 220, "min": 400 * PX_TO_M, "max": 1200 * PX_TO_M,
			"cd": 180 * 0.03125, "cost": {"iron": 2, "coal": 3}, "splash": 12 * PX_TO_M}],
		"prot": [2, 2, 4, 60, 6, 45],
		"radius": 1.8,
		"icon": Rect2(322, 368, 46, 46),
	},
}

# buildings: hp, build_time s, cost, radius (footprint, estimated), trains, stores, farm, score
const BUILDINGS_BASE := {
	"cen": {"hp": 5300, "build_time": 500 * 0.03125, "cost": {"wood": 700}, "radius": 3.0, "farm": 100,
		"stores": ["food", "wood", "stone"], "trains": ["peasant"], "score": 1000, "capture": true, "drop": true,
		"icon": Rect2(92, 92, 46, 46)},
	"hou": {"hp": 4150, "build_time": 100 * 0.03125, "cost": {"wood": 120}, "radius": 1.5, "farm": 25,
		"score": 100, "icon": Rect2(0, 0, 46, 46)},
	"bar": {"hp": 20000, "build_time": 300 * 0.03125, "cost": {"wood": 150, "stone": 150}, "radius": 2.5, "farm": 150,
		"trains": ["pikeman", "roundshier", "serdiuk", "archer", "officer", "drummer", "priest"], "score": 500,
		"icon": Rect2(46, 46, 46, 46)},
	"bar18": {"hp": 20000, "build_time": 400 * 0.03125, "cost": {"wood": 300, "stone": 300}, "radius": 2.5, "farm": 250,
		"trains": ["musk18", "grenadier", "pikeman18", "officer18", "drummer18"], "score": 500,
		"icon": Rect2(46, 46, 46, 46)},
	"dip": {"hp": 8000, "build_time": 400 * 0.03125, "cost": {"wood": 400, "gold": 200}, "radius": 2.5,
		"trains": ["roundshier", "dragoon17", "reiter"], "score": 300,
		"icon": Rect2(0, 46, 46, 46)},
	"sta": {"hp": 10000, "build_time": 500 * 0.03125, "cost": {"wood": 3200, "stone": 850, "gold": 850}, "radius": 2.5,
		"trains": ["cossack", "dragoon"], "score": 500, "icon": Rect2(138, 46, 46, 46)},
	"bla": {"hp": 4500, "build_time": 200 * 0.03125, "cost": {"wood": 100, "stone": 30, "iron": 640}, "radius": 2.0,
		"score": 500, "icon": Rect2(92, 46, 46, 46)},
	"aca": {"hp": 65000, "build_time": 150 * 0.03125, "cost": {"wood": 1350, "stone": 1200}, "radius": 2.5,
		"score": 500, "icon": Rect2(230, 46, 46, 46)},
	# G-01: the capturable set (town hall, market, mines, storehouse) is
	# wiki-sourced (RB_MECHANICS S3/S5/S6/S7), not donor-byte verified - INFERENCE.
	# Military buildings below deliberately stay uncapturable.
	"sto": {"hp": 10000, "build_time": 100 * 0.03125, "cost": {"wood": 50, "stone": 20}, "radius": 1.5,
		"stores": ["wood", "stone"], "score": 30, "drop": true, "capture": true, "icon": Rect2(92, 0, 46, 46)},
	"mil": {"hp": 20000, "build_time": 300 * 0.03125, "cost": {"wood": 30, "stone": 150}, "radius": 2.0,
		"stores": ["food"], "score": 20, "drop": true, "icon": Rect2(46, 0, 46, 46)},
	"mar": {"hp": 4000, "build_time": 750 * 0.03125, "cost": {"wood": 450}, "radius": 2.0, "score": 500,
		"capture": true, "icon": Rect2(0, 46, 46, 46)},
	"art": {"hp": 40000, "build_time": 787 * 0.03125, "cost": {"wood": 100, "stone": 1000, "coal": 1400}, "radius": 2.5,
		"trains": ["cannon", "howitzer", "mortar", "multicannon"], "score": 500, "icon": Rect2(184, 46, 46, 46)},
	# Stone wall segment (data/game/var/wallcustom.cfg BuilderPoints ±0.9 m).
	# Cheap, chainable, no upkeep; estimated hp/cost, marked so in mechanics.
	"wal": {"hp": 3000, "build_time": 60 * 0.03125, "cost": {"wood": 10, "stone": 20}, "radius": 1.0,
		"eat": {"stone": 40}, "score": 20, "wall": true, "icon": Rect2(414, 0, 46, 46)},
	"gat": {"hp": 3000, "build_time": 60 * 0.03125, "cost": {"wood": 10, "stone": 60}, "radius": 1.0,
		"score": 20, "wall": true, "gate": true, "icon": Rect2(414, 0, 46, 46)},
	"mine_gold": {"hp": 2500, "build_time": 300 * 0.03125, "cost": {"wood": 100, "stone": 100}, "radius": 1.6,
		"mine": "gold", "slots": 5, "produce": 13, "score": 500, "capture": true, "icon": Rect2(138, 0, 46, 46)},
	"mine_iron": {"hp": 2500, "build_time": 300 * 0.03125, "cost": {"wood": 100, "stone": 100}, "radius": 1.6,
		"mine": "iron", "slots": 5, "produce": 13, "score": 500, "capture": true, "icon": Rect2(138, 0, 46, 46)},
	"mine_coal": {"hp": 2500, "build_time": 300 * 0.03125, "cost": {"wood": 100, "stone": 100}, "radius": 1.6,
		"mine": "coal", "slots": 5, "produce": 13, "score": 500, "capture": true, "icon": Rect2(138, 0, 46, 46)},
	"tow": {"hp": 20000, "build_time": 3937 * 0.03125, "cost": {"wood": 100, "stone": 100, "gold": 150}, "radius": 1.6,
		"weapons": [{"kind": "cannonball", "dmg": 1000, "min": 550 * PX_TO_M, "max": 1500 * PX_TO_M, "cd": 400 * 0.03125,
			"cost": {"iron": 10, "coal": 30}, "splash": 35 * PX_TO_M}],
		"eat": {"gold": 500}, "score": 500, "icon": Rect2(414, 0, 46, 46)},
	# P-10: donor Shipyard (hotkey P) has no readable stats; hp/cost are
	# ESTIMATED. train_unit() gates strictly on `trains`, so this is the only
	# training hook needed for the yacht.
	"dock": {"hp": 12000, "build_time": 900 * 0.03125, "cost": {"wood": 600, "stone": 200, "gold": 150}, "radius": 3.0,
		"trains": ["yacht"], "score": 500, "icon": Rect2(414, 46, 46, 46)},
}

# Upgrades researched at blacksmith (bla) and academy (aca).
# Video pass: every battle video shows the bread/iron/steel upgrade path and
# the 18th-century transition; costs/effects estimated, marked so in mechanics.
const UPGRADES_BASE := {
	"bla_sword1": {"building": "bla", "cost": {"wood": 100, "food": 200}, "time": 8.0,
		"effect": {"damage_mult": {"sword": 1.15, "pike": 1.15}}, "name": "Sharpened blades +15%"},
	"bla_armor1": {"building": "bla", "cost": {"wood": 100, "iron": 100}, "time": 8.0,
		"effect": {"prot_bonus": 2}, "name": "Forged armor +2"},
	"bla_bullet1": {"building": "bla", "cost": {"gold": 200, "iron": 200}, "time": 12.0,
		"effect": {"damage_mult": {"bullet": 1.2, "cannonball": 1.1}}, "name": "Improved powder +20%"},
	"aca_bread1": {"building": "aca", "cost": {"food": 300, "gold": 100}, "time": 10.0,
		"effect": {"gather_mult": {"food": 1.25}}, "name": "Crop rotation +25% food"},
	"aca_wood1": {"building": "aca", "cost": {"food": 200, "wood": 200}, "time": 10.0,
		"effect": {"gather_mult": {"wood": 1.2}}, "name": "Sawmills +20% wood"},
	"cen_18c": {"building": "cen", "cost": {"food": 800, "gold": 600}, "time": 20.0,
		"effect": {"unlock18c": true}, "name": "18th century"},
	"sta_horse1": {"building": "sta", "cost": {"food": 400, "gold": 200}, "time": 12.0,
		"effect": {"damage_mult": {"sword": 1.1}}, "name": "Bred horses +10% cavalry"},
	"art_caliber1": {"building": "art", "cost": {"gold": 300, "iron": 300}, "time": 14.0,
		"effect": {"damage_mult": {"cannonball": 1.15}}, "name": "Heavy caliber +15%"},
	"mil_food1": {"building": "mil", "cost": {"food": 750, "gold": 250}, "time": 10.0,
		"effect": {"gather_mult": {"food": 2.4}}, "name": "Grain treatment +140%"},
	# Donor locale/en/upgrades.txt:144 = "storage +180" -> multiplier 2.8,
	# not the previous estimated +250% (deep-MICRO §2.2).
	"mil_food2": {"building": "mil", "cost": {"food": 25600, "gold": 3350, "iron": 2000}, "time": 20.0,
		"effect": {"gather_mult": {"food": 2.8}}, "name": "Grain storage +180%"},
	"aca_field1": {"building": "aca", "cost": {"food": 2000, "gold": 500}, "time": 12.0,
		"effect": {"field_cap": 3.0}, "name": "Field melioration +200%"},
	"bla_field1": {"building": "bla", "cost": {"food": 1000, "iron": 200}, "time": 10.0,
		"effect": {"field_cap": 2.0}, "name": "Agricultural equipment +100%"},
	"aca_wheat1": {"building": "aca", "cost": {"food": 1500, "gold": 300}, "time": 10.0,
		"effect": {"gather_mult": {"food": 1.4}}, "name": "New wheat +40%"},
	# Donor locale/en/upgrades.txt:4 = "rye +50" -> multiplier 1.5,
	# not the previous estimated +40% (deep-MICRO §2.2).
	"aca_rye1": {"building": "aca", "cost": {"food": 2500, "gold": 500}, "time": 12.0,
		"effect": {"gather_mult": {"food": 1.5}}, "name": "New rye +50%"},
	"aca_wood1b": {"building": "aca", "cost": {"wood": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"wood": 2.0}}, "name": "Woodworking tools +100%"},
	"aca_stone1": {"building": "aca", "cost": {"stone": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"stone": 2.0}}, "name": "Stone excavation +100%"},
	"aca_build1": {"building": "aca", "cost": {"wood": 1500, "stone": 1000}, "time": 12.0,
		"effect": {"build_mult": 0.25}, "name": "Builders' salary (build time -75%)"},
	"aca_hp1": {"building": "aca", "cost": {"wood": 2000, "stone": 1500}, "time": 14.0,
		"effect": {"bld_hp_add": 85}, "name": "New construction materials +85 hp"},
	"aca_fort1": {"building": "aca", "cost": {"stone": 2500, "gold": 600}, "time": 14.0,
		"effect": {"fort_hp_add": 80}, "name": "Fortification grades +80 hp"},
	"aca_geo1": {"building": "aca", "cost": {"gold": 800, "food": 500}, "time": 10.0,
		"effect": {"reveal_deposits": true}, "name": "Geology (reveal deposits)"},
	"aca_balloon1": {"building": "aca", "cost": {"gold": 2000, "food": 1000}, "time": 16.0,
		"effect": {"reveal_map": true}, "name": "Montgolfier (reveal map)"},
	"art_range1": {"building": "art", "cost": {"gold": 600, "iron": 300}, "time": 12.0,
		"effect": {"art_range": 1.05}, "name": "Artillery range +5%"},
	"art_range2": {"building": "art", "cost": {"gold": 1200, "iron": 600}, "time": 14.0,
		"effect": {"art_range": 1.1}, "name": "Mathematics (range +10%)"},
	"art_hp1": {"building": "art", "cost": {"gold": 1500, "iron": 800}, "time": 14.0,
		"effect": {"art_hp": 2.5}, "name": "Gribovalle system (arty hp +150%)"},
	"art_acc1": {"building": "art", "cost": {"gold": 900, "iron": 400}, "time": 12.0,
		"effect": {"art_acc": 0.65}, "name": "Artillery accuracy +35%"},
	"art_multi1": {"building": "art", "cost": {"gold": 2000, "iron": 1000, "coal": 500}, "time": 18.0,
		"effect": {"unlock_multi": true}, "name": "Multi-barrelled cannon"},
	"tow_rof1": {"building": "tow", "cost": {"gold": 400, "iron": 200, "coal": 200}, "time": 10.0,
		"effect": {"tower_rof": 0.8}, "name": "More cannons +20% RoF"},
	"tow_rof2": {"building": "tow", "cost": {"gold": 800, "iron": 400, "coal": 400}, "time": 12.0,
		"effect": {"tower_rof": 0.8}, "name": "More cannons II +20% RoF"},
	"tow_rof3": {"building": "tow", "cost": {"gold": 1200, "iron": 600, "coal": 600}, "time": 14.0,
		"effect": {"tower_rof": 0.9}, "name": "More cannons III +10% RoF"},
	"mine_gold_up1": {"building": "mine_gold", "cost": {"wood": 200, "stone": 100}, "time": 10.0,
		"effect": {"mine_mult": 1.5}, "name": "Deep shafts +50% gold"},
	"mine_iron_up1": {"building": "mine_iron", "cost": {"wood": 200, "stone": 100}, "time": 10.0,
		"effect": {"mine_mult": 1.5}, "name": "Deep shafts +50% iron"},
	"mine_coal_up1": {"building": "mine_coal", "cost": {"wood": 200, "stone": 100}, "time": 10.0,
		"effect": {"mine_mult": 1.5}, "name": "Deep shafts +50% coal"},
	"mine_gold_up2": {"building": "mine_gold", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"mine_gold_up3": {"building": "mine_gold", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"mine_gold_up4": {"building": "mine_gold", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"mine_gold_up5": {"building": "mine_gold", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"mine_gold_up6": {"building": "mine_gold", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"mine_gold_up7": {"building": "mine_gold", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
	"mine_iron_up2": {"building": "mine_iron", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"mine_iron_up3": {"building": "mine_iron", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"mine_iron_up4": {"building": "mine_iron", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"mine_iron_up5": {"building": "mine_iron", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"mine_iron_up6": {"building": "mine_iron", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"mine_iron_up7": {"building": "mine_iron", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
	"mine_coal_up2": {"building": "mine_coal", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"mine_coal_up3": {"building": "mine_coal", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"mine_coal_up4": {"building": "mine_coal", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"mine_coal_up5": {"building": "mine_coal", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"mine_coal_up6": {"building": "mine_coal", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"mine_coal_up7": {"building": "mine_coal", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
	# --- Skirmish combat tree (RB G-02..G-06, G-08). Effects are applied in
	# game.gd apply_upgrade(); costs/times are estimated like the rows above.
	"aca_fire1": {"building": "aca", "cost": {"gold": 300, "iron": 200}, "time": 10.0,
		"effect": {"damage_mult": {"bullet": 1.1, "cannonball": 1.1}}, "name": "Rifled barrels +10%"},
	"aca_fire2": {"building": "aca", "cost": {"gold": 600, "iron": 400}, "time": 11.0,
		"effect": {"damage_mult": {"bullet": 1.15, "cannonball": 1.15}}, "name": "Granular powder +15%"},
	"aca_fire3": {"building": "aca", "cost": {"gold": 1000, "iron": 700}, "time": 12.0,
		"effect": {"damage_mult": {"bullet": 1.2, "cannonball": 1.2}}, "name": "Purified sulphur +20%"},
	"aca_fire4": {"building": "aca", "cost": {"gold": 1600, "iron": 1100}, "time": 13.0,
		"effect": {"damage_mult": {"bullet": 1.3, "cannonball": 1.3}}, "name": "Saltpetre +30%"},
	"aca_rof1": {"building": "aca", "cost": {"gold": 900, "iron": 500}, "time": 12.0,
		"effect": {"rof_mult": {"bullet": 0.65}}, "name": "Wheellock (+35% RoF)"},
	"aca_rof2": {"building": "aca", "cost": {"gold": 1400, "iron": 800}, "time": 13.0,
		"effect": {"rof_mult": {"bullet": 0.65}}, "name": "Paper cartridge (+35% RoF)"},
	"bla_flint1": {"building": "bla", "cost": {"gold": 500, "iron": 300}, "time": 10.0,
		"effect": {"cost_mult": 0.5}, "name": "Flintlock muskets (-50% shot cost)"},
	"bla_bayonet1": {"building": "bla", "cost": {"wood": 200, "iron": 250}, "time": 10.0,
		"effect": {"melee_add": 7}, "name": "Bayonets +7 melee"},
	"bla_steel1": {"building": "bla", "cost": {"iron": 600, "gold": 400}, "time": 12.0, "no18c": true,
		"effect": {"damage_mult": {"sword": 1.25, "pike": 1.25}}, "name": "Steel grades +25% melee"},
	"bla_harness1": {"building": "bla", "cost": {"food": 500, "gold": 300}, "time": 10.0,
		"effect": {"train_speed_mult": 0.5}, "name": "Harnesses (mounted recruit x2)"},
	"bla_sabre1": {"building": "bla", "cost": {"iron": 450, "gold": 350}, "time": 11.0,
		"effect": {"cav_dmg_add": 5}, "name": "Broadswords +5 cavalry attack"},
	"aca_riding1": {"building": "aca", "cost": {"food": 600, "gold": 400}, "time": 11.0,
		"effect": {"cav_prot_bonus": 2}, "name": "Riding drill +2 cavalry defence"},
	"sta_fence1": {"building": "sta", "cost": {"food": 400, "iron": 200}, "time": 10.0,
		"effect": {"damage_mult": {"sword": 1.15}}, "name": "Fencing drill +15% melee"},
	"sta_fire1": {"building": "sta", "cost": {"food": 400, "gold": 250}, "time": 10.0,
		"effect": {"damage_mult": {"bullet": 1.15}}, "name": "Firing practice +15% ranged"},
	"bar_phys1": {"building": "bar", "cost": {"food": 400, "gold": 200}, "time": 10.0,
		"effect": {"prot_bonus": 2}, "name": "Physical training +2 defence"},
	"bar_music1": {"building": "bar", "cost": {"food": 300, "gold": 250}, "time": 10.0,
		"effect": {"prot_bonus": 2}, "name": "Musician drill +2 defence"},
	"bar_grenade1": {"building": "bar", "cost": {"iron": 400, "gold": 300}, "time": 11.0,
		"effect": {"damage_mult": {"cannister": 1.25}}, "name": "New grenades +25%"},
	"aca_med1": {"building": "aca", "cost": {"food": 1200, "gold": 900}, "time": 14.0,
		"effect": {"heal_all": true}, "name": "Medical science (heal all)"},
	"art_foundry1": {"building": "art", "cost": {"gold": 800, "iron": 600}, "time": 12.0,
		"effect": {"art_cost_mult": 0.8}, "name": "Foundry mechanization -20% cost"},
	"art_metal1": {"building": "art", "cost": {"gold": 1000, "iron": 900}, "time": 13.0,
		"effect": {"art_build_mult": 0.6}, "name": "Metalworking +40% build speed"},
	"art_repair1": {"building": "art", "cost": {"gold": 700, "iron": 500}, "time": 12.0,
		"effect": {"repair_arty": true}, "name": "Artillery repair shops"},
}

# The live tables. They start as a copy of the original numbers and are then
# changed by the global settings file (config.json) when the game starts.
static var UNITS := {}
static var BUILDINGS := {}
static var UPGRADES := {}

# The tables are built once, when the script is loaded, so that the settings
# file can change them without them being read-only.
static func _static_init() -> void:
	UNITS = copy_value(UNITS_BASE)
	BUILDINGS = copy_value(BUILDINGS_BASE)
	UPGRADES = copy_value(UPGRADES_BASE)
	GATHER = copy_value(GATHER_BASE)
	START_RESOURCES = {"food": 0.0, "wood": 0.0, "stone": 0.0, "gold": 0.0, "iron": 0.0, "coal": 0.0}
	DEPOSITS = {"gold": 40000.0, "iron": 30000.0, "coal": 30000.0}
	BATTLE_ARMY = {"pikeman": 16, "serdiuk": 12, "archer": 8, "cossack": 8, "officer": 1, "cannon": 2}

# nation train-list resolution: generic sid -> nation's own unit (or sid)
static func resolve_sid(nat: String, sid: String) -> String:
	var m: Dictionary = NATION_UNITS.get(nat, {})
	var r: String = str(m.get(sid, sid))
	return r if UNITS.has(r) else sid

# A copy of a table that can be changed afterwards.
static func copy_value(v: Variant) -> Variant:
	if v is Dictionary:
		var d := {}
		for k in v:
			d[k] = copy_value(v[k])
		return d
	if v is Array:
		var a := []
		for x in v:
			a.append(copy_value(x))
		return a
	return v

# damage formula, miscext2.script _misc_DoDamage
static func apply_damage(dmg: float, weap_kind: String, target: Dictionary) -> int:
	var d := int(dmg)
	if target.get("cavalry", "") == "fast" and target.get("moving", false) \
			and (weap_kind == "arrow" or weap_kind == "bullet"):
		d -= 5
	var shield: int = target.get("shield", 0)
	if target.get("finished", true):
		d -= shield
	else:
		d -= int(shield / 3.0)
	var prot: Array = target.get("prot", [0, 0, 0, 0, 0, 0])
	var wk: int = WK.get(weap_kind, 0)
	if wk >= 0 and wk < PROT_SLOT.size():
		var slot: int = PROT_SLOT[wk]
		if slot >= 0 and slot < prot.size():
			d -= int(prot[slot])
	if d < 1:
		d = 1
	return d

# res is the player's 6-slot array in RES_NAMES order (food, wood, stone, gold, iron, coal)
static func can_pay(res: Array, cost: Dictionary) -> bool:
	for k in cost:
		if res[RES_NAMES.find(k)] < int(cost[k]):
			return false
	return true

static func pay(res: Array, cost: Dictionary) -> void:
	for k in cost:
		res[RES_NAMES.find(k)] = res[RES_NAMES.find(k)] - int(cost[k])

static func refund(res: Array, cost: Dictionary, percent: float) -> void:
	for k in cost:
		res[RES_NAMES.find(k)] = res[RES_NAMES.find(k)] + int(round(cost[k] * percent))
