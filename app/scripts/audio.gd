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

var files: Array = []          # the names of all the sound files
var cache: Dictionary = {}     # name -> AudioStream (loaded when first needed)
var players: Array = []
var next_player := 0
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer

func _ready() -> void:
	var d := DirAccess.open(DIR)
	if d != null:
		for f in d.get_files():
			if f.get_extension().to_lower() == "ogg":
				files.append(f.get_basename())
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

# The music of the player's nation and the air around it.
func start_music(nation := "ukr") -> void:
	if not Data.AUDIO_ENABLED:
		return
	music_player = AudioStreamPlayer.new()
	var m := _stream(nation)
	if m != null:
		music_player.stream = m
		music_player.volume_db = Data.AMBIENT_VOLUME_DB - 6.0
		add_child(music_player)
		music_player.play()
	ambient_player = AudioStreamPlayer.new()
	var a := _stream("amb_atmosphere")
	if a != null:
		ambient_player.stream = a
		ambient_player.volume_db = Data.AMBIENT_VOLUME_DB
		add_child(ambient_player)
		ambient_player.play()

func stop_all() -> void:
	for p in players:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	for p in [music_player, ambient_player]:
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
func play(prefixes: Array, vol_db := 0.0) -> void:
	if not Data.AUDIO_ENABLED or players.is_empty():
		return
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
