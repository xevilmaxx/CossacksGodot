# The sounds of the original game, played the way the original plays them:
# a musket shot for a musketeer, a sabre for a swordsman, an arrow for a
# bow, the work sounds while the peasants work, the building sound when a
# building is finished, and the walking sound of the unit that walks.
#
# The sounds are the original files (data/sounds of the installed game),
# copied into assets/sounds by tools/copy_assets.py. They are loaded when
# they are first needed, so the game starts fast.
extends Node
class_name C3Audio

const Data = preload("res://scripts/data.gd")
const DIR := "res://assets/sounds"
# Only ukr/rus were ported originally. Any other nation id falls back to this
# theme so a missing track never leaves an unparented AudioStreamPlayer behind.
const MUSIC_FALLBACK := "ukr"
# MICRO #19 (docs/audit/MICRO.md rows 13/65). The donor plays amb_windmill by
# distance to a windmill (gui.script:3234-3303) and keeps work sounds distinct
# per resource (units/unit.inc/ontagstates.inc). Both are driven from the game
# state exposed by main.gd, which owns the event dispatch and is read-only here.
const AMBIENT_MAX_DIST := 60.0   # same audibility cutoff as play() below
const AMBIENT_TICK := 0.4        # seconds between mill-ambient proximity checks

var files: Array = []          # the names of all the sound files
var cache: Dictionary = {}     # name -> AudioStream (loaded when first needed)
var players: Array = []
var next_player := 0
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var mill_ambient_player: AudioStreamPlayer
var mill_ambient_active := false
var ambient_tick := 0.0
var last_play: Dictionary = {}
var music_on := false

func _ready() -> void:
	var d := DirAccess.open(DIR)
	if d != null:
		for f in d.get_files():
			if f.get_extension().to_lower() == "ogg":
				files.append(f.get_basename())
	for i in 16:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

# The music of the player's nation and the air around it.
func start_music(nation := "ukr") -> void:
	if not Data.AUDIO_ENABLED:
		return
	music_on = true
	var m := _stream(nation)
	if m == null:
		m = _stream(MUSIC_FALLBACK)
	if m != null:
		music_player = AudioStreamPlayer.new()
		music_player.stream = m
		music_player.volume_db = Data.AMBIENT_VOLUME_DB - 6.0
		add_child(music_player)
		music_player.finished.connect(_replay_music)
		music_player.play()
	ambient_player = AudioStreamPlayer.new()
	var a := _stream("amb_atmosphere")
	if a != null:
		ambient_player.stream = a
		ambient_player.volume_db = Data.AMBIENT_VOLUME_DB
		add_child(ambient_player)
		ambient_player.finished.connect(_replay_ambient)
		ambient_player.play()

	# Dedicated looping player for the donor windmill ambience. It is not taken
	# from the 16-player polyphony pool: an ambient bed must never steal a slot
	# from a shot or a work sound, and there is exactly one of it (no orphans).
	var wm := _stream("amb_windmill")
	if wm != null:
		mill_ambient_player = AudioStreamPlayer.new()
		if wm is AudioStreamOggVorbis:
			wm.loop = true
		mill_ambient_player.stream = wm
		mill_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB - 10.0
		add_child(mill_ambient_player)
		mill_ambient_player.finished.connect(_replay_mill_ambient)

# Quiet windmill bed while a finished mill is near the camera. main.gd owns the
# game/camera objects; this node is its child, so read them through get_parent()
# without editing (or owning) main.gd / game.gd. The proximity scan is throttled
# and touches no game state — it only reads buildings and camera position.
func _process(dt: float) -> void:
	if not music_on or not Data.AUDIO_ENABLED or mill_ambient_player == null \
			or not is_instance_valid(mill_ambient_player):
		return
	ambient_tick -= dt
	if ambient_tick > 0.0:
		return
	ambient_tick = AMBIENT_TICK
	var parent := get_parent()
	if parent == null or not is_instance_valid(parent):
		return
	var game = parent.get("game")
	if game == null:
		return
	var center := Vector2.ZERO
	var cam = parent.get("camera")
	if cam != null and is_instance_valid(cam):
		center = cam.global_position / 16.0   # main.gd's metres convention
	var nearest := AMBIENT_MAX_DIST
	for b in game.live_blds:
		if b.dead or str(b.get("sid", "")) != "mil" or not bool(b.get("finished", false)):
			continue
		var d: float = b.pos.distance_to(center)
		if d < nearest:
			nearest = d
	if nearest >= AMBIENT_MAX_DIST:
		if mill_ambient_active:
			mill_ambient_player.stop()
			mill_ambient_active = false
		return
	# Quiet bed, further attenuated with distance just like the donor's
	# volume-by-distance windmill (gui.script:3234-3303).
	mill_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB - 10.0 \
			- clampf((nearest - 8.0) * 0.25, 0.0, 8.0)
	if not mill_ambient_active or not mill_ambient_player.playing:
		mill_ambient_player.play()
		mill_ambient_active = true

func _replay_mill_ambient() -> void:
	# Covers importers that do not honour AudioStreamOggVorbis.loop. Never
	# restart a bed we deliberately stopped when the mill went out of range.
	if music_on and mill_ambient_active and is_instance_valid(mill_ambient_player):
		mill_ambient_player.play()

func _replay_music() -> void:
	if music_on and music_player != null and is_instance_valid(music_player):
		music_player.play()

func _replay_ambient() -> void:
	if music_on and ambient_player != null and is_instance_valid(ambient_player):
		ambient_player.play()

func stop_all() -> void:
	music_on = false
	mill_ambient_active = false
	for p in players:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	for p in [music_player, ambient_player, mill_ambient_player]:
		if p != null and is_instance_valid(p):
			p.stop()
			p.stream = null

# The names of the sounds that start with one of the given words.
# A name matches when the rest of it is empty or starts with a number, so
# "arrow" finds arrow1..arrow7 but not arrowimpact1.
func names_for(prefixes: Array) -> Array:
	var out: Array = []
	for f in files:
		for p in prefixes:
			var pre := str(p)
			if not f.begins_with(pre):
				continue
			var rest: String = f.substr(pre.length())
			if rest == "" or rest[0] >= "0" and rest[0] <= "9":
				out.append(f)
				break
	return out

func has(prefixes: Array) -> bool:
	return not names_for(prefixes).is_empty()

func _stream(name: String) -> AudioStream:
	if cache.has(name):
		return cache[name]
	var s: AudioStream = load("%s/%s.ogg" % [DIR, name])
	cache[name] = s
	return s

# Play one of the sounds that starts with one of the given words.
func play(prefixes: Array, vol_db := 0.0, at := Vector2.INF) -> void:
	if not Data.AUDIO_ENABLED or players.is_empty():
		return
	# MICRO #19: main.gd owns the "chop" dispatch and passes only ["workwood"]
	# together with the resource-node position (game.gd:3842). Recover the
	# resource kind from the node at that position so the donor's distinct work
	# families are heard, without editing main.gd or game.gd.
	if prefixes.size() == 1 and str(prefixes[0]) == "workwood" and at != Vector2.INF:
		prefixes = _work_sound_at(at, prefixes)
	var key: String = str(prefixes[0]) if prefixes.size() > 0 else ""
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(last_play.get(key, -10.0)) < 0.09:
		return
	last_play[key] = now
	if at != Vector2.INF:
		var cam := get_viewport().get_camera_2d() if get_viewport() != null else null
		if cam != null:
			var d: float = at.distance_to(cam.global_position / 16.0)
			if d > 60.0:
				return
			vol_db -= clampf((d - 20.0) * 0.15, 0.0, 12.0)
	var names := names_for(prefixes)
	if names.is_empty():
		return
	var n: String = names[randi() % names.size()]
	var s := _stream(n)
	if s == null:
		return
	var p: AudioStreamPlayer = players[next_player]
	next_player = (next_player + 1) % players.size()
	p.stream = s
	p.volume_db = vol_db + Data.MASTER_VOLUME_DB
	p.pitch_scale = randf_range(0.92, 1.08)
	p.play()

# Donor truth (units/unit.inc/ontagstates.inc and onaclanimationreachedwork.inc,
# read-only): wood -> workwood, stone -> workstone, mines use the same pick.
# Food is SILENT in the donor: sound.script's `workfood` loop and the
# `_unit_RequestPlaySound(..., gc_snd_ind_workfood)` call are both commented out,
# and no workfood*.ogg exists. The closest donor work clip (a short tap) is used
# as an INFERRED stand-in so food is audible and distinct; it is not donor-exact.
func work_sound(res: String) -> Array:
	match res:
		"wood", "stump", "bush":
			return ["workwood"]
		"stone", "gold", "iron", "coal":
			return ["workstone"]
		"food":
			return ["workconstruct"]
	return ["workwood"]

# Find the resource node that emitted a "chop" event and pick its work family.
# Only the node within 2 m of the event position counts; anything else falls
# back to the prefix main.gd supplied, so ordinary workwood calls are unchanged.
func _work_sound_at(at: Vector2, fallback: Array) -> Array:
	var parent := get_parent()
	if parent == null or not is_instance_valid(parent):
		return fallback
	var game = parent.get("game")
	if game == null:
		return fallback
	var best_type := ""
	var best_d := 2.0
	for n in game.res_nodes:
		var d: float = n.pos.distance_to(at)
		if d < best_d:
			best_d = d
			best_type = str(n.get("type", ""))
	if best_type == "":
		return fallback
	return work_sound(best_type)

# The walking sound of a kind of unit (the original has one per unit type).
func walk_sound(sid: String) -> Array:
	match sid:
		"peasant":
			return ["walkpea"]
		"pikeman":
			return ["walkinfmetal"]
		"roundshier", "serdiuk", "archer", "officer":
			return ["walkinfcloth"]
		"cossack":
			return ["walkcavfast"]
		"dragoon":
			return ["walkcavslow"]
		"cannon":
			return ["walkartwheels"]
	return []

# The sound of a building being finished (bldcen, bldhou, ...).
func building_sound(sid: String) -> Array:
	var m := {
		"cen": "bldcen", "hou": "bldhou", "bar": "bldbar", "sta": "bldsta",
		"bla": "bldbla", "aca": "bldaca", "sto": "bldsto", "mil": "bldmil",
		"mar": "bldmar", "art": "bldart", "tow": "bldtow",
		"mine_gold": "bldgol", "mine_iron": "bldiro", "mine_coal": "bldcoa",
	}
	if m.has(sid):
		return [m[sid]]
	return ["construct"]
