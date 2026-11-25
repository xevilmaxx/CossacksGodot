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
const AMBIENT_TICK := 0.4        # seconds between ambient proximity checks
# The five donor ambient beds (donor sounds/ambient/ambient.snd:103-135).
const AMB_ATMOSPHERE := "amb_atmosphere"
const AMB_WIND := "amb_wind"
const AMB_WINDMILL := "amb_windmill"
const AMB_TOWN := "amb_towneur"
const AMB_SEA := "amb_sea"
# Donor gui.script:3310,3328 - sea scan cell size and frustum-cell divisor.
const AMBIENT_SEA_STEP := 4.0
const AMBIENT_SEA_DIV := 200.0
# AUDIO-SEL-01: donor selection feedback. Interface bank, cLoudFull (8000 =>
# global), played NON-POSITIONALLY on unit-control rebuild
# (gui\menu.inc\showunitcontrol.inc:1024-1027). Clips are among the 325 already
# converted assets in res://assets/sounds (DEC_04 §8 325/325 Ogg census).
const SELECT_PEASANT := "selectpeasant"
const SELECT_PEASANT_VARIANTS := 6
const SELECT_SHIP := "selectship"
# Port ship sids (data.gd:1169-1250, all `naval: true`) plus generic caller
# tokens; everything else is treated as a peasant/unit selection.
const SHIP_SELECT_KINDS := [
	"ship", "naval", "boat",
	"yacht", "yachttur", "fishboat", "galley", "frigate", "xebec", "battleship",
]

var files: Array = []          # the names of all the sound files
var cache: Dictionary = {}     # name -> AudioStream (loaded when first needed)
var players: Array = []
var next_player := 0
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var mill_ambient_player: AudioStreamPlayer
var mill_ambient_active := false
var wind_ambient_player: AudioStreamPlayer
var town_ambient_player: AudioStreamPlayer
var town_ambient_active := false
var sea_ambient_player: AudioStreamPlayer
var sea_ambient_active := false
var sea_ambient_vol := 0.0     # donor's smoothed linear sea volume
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
	var a := _stream(AMB_ATMOSPHERE)
	if a != null:
		ambient_player.stream = a
		ambient_player.volume_db = Data.AMBIENT_VOLUME_DB
		add_child(ambient_player)
		ambient_player.finished.connect(_replay_ambient)
		ambient_player.play()

	# Dedicated looping players for the other four donor beds. None is taken
	# from the 16-player polyphony pool: an ambient bed must never steal a slot
	# from a shot or a work sound, and each bed exists exactly once (no orphans).
	var wm := _stream(AMB_WINDMILL)
	if wm != null:
		mill_ambient_player = AudioStreamPlayer.new()
		if wm is AudioStreamOggVorbis:
			wm.loop = true
		mill_ambient_player.stream = wm
		mill_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB - 10.0
		add_child(mill_ambient_player)
		mill_ambient_player.finished.connect(_replay_mill_ambient)

	# amb_wind: continuous bed, donor doambientsound.inc:56-77 sets vol 0.2 and
	# no object drives its volume. 0.2 linear == -13.98 dB vs amb_atmosphere's 1.
	var wind := _ambient_player(AMB_WIND, Data.AMBIENT_VOLUME_DB + linear_to_db(0.2))
	if wind != null:
		wind_ambient_player = wind
		wind.finished.connect(_replay_wind_ambient)
		wind.play()

	# amb_towneur / amb_sea start silent; _process() drives their volume by
	# distance (donor gui.script:3303-3335), exactly like the mill bed above.
	var town := _ambient_player(AMB_TOWN, Data.AMBIENT_VOLUME_DB)
	if town != null:
		town_ambient_player = town
		town.finished.connect(_replay_town_ambient)
	var sea := _ambient_player(AMB_SEA, Data.AMBIENT_VOLUME_DB)
	if sea != null:
		sea_ambient_player = sea
		sea.finished.connect(_replay_sea_ambient)

# One dedicated looping ambient player. Same loop-fallback pattern as the
# windmill bed above, shared by the three newly wired beds.
func _ambient_player(name: String, vol_db: float) -> AudioStreamPlayer:
	var s := _stream(name)
	if s == null:
		return null
	if s is AudioStreamOggVorbis:
		s.loop = true
	var p := AudioStreamPlayer.new()
	p.stream = s
	p.volume_db = vol_db
	add_child(p)
	return p

# Quiet ambient beds while a finished mill / town hall is near the camera or
# water is in view. main.gd owns the game/camera objects; this node is its child,
# so read them through get_parent() without editing (or owning) main.gd/game.gd.
# The proximity scan is throttled and touches no game state — it only reads
# buildings, terrain and camera position.
func _process(dt: float) -> void:
	if not music_on or not Data.AUDIO_ENABLED:
		return
	ambient_tick -= dt
	if ambient_tick > 0.0:
		return
	ambient_tick = AMBIENT_TICK
	var parent := get_parent()
	if parent == null or not is_instance_valid(parent):
		return
	var game = parent.get("game")
	if game == null or not is_instance_valid(game):
		return
	var center := Vector2.ZERO
	var cam = parent.get("camera")
	if cam != null and is_instance_valid(cam):
		# Variant3d may bind a Camera3D here (camera3d.gd:38): its global_position
		# is Vector3. Keep the 2D ground-plane convention — game y is world z
		# (hud3d_adapter.gd:95-96, camera3d.gd:159-161) — and feed the same two
		# horizontal components into the unchanged /16.0 metres conversion below.
		if cam.global_position is Vector3:
			var p3: Vector3 = cam.global_position
			center = Vector2(p3.x, p3.z) / 16.0
		else:
			center = cam.global_position / 16.0   # main.gd's metres convention

	# Donor gui.script:3274-3298 scans built storehouses for mill/town usage.
	var nearest_mill := AMBIENT_MAX_DIST
	var nearest_town := AMBIENT_MAX_DIST
	for b in game.live_blds:
		if b.dead or not bool(b.get("finished", false)):
			continue
		var sid := str(b.get("sid", ""))
		var d: float = b.pos.distance_to(center)
		if sid == "mil" and d < nearest_mill:
			nearest_mill = d
		elif sid == "cen" and d < nearest_town:
			nearest_town = d

	if mill_ambient_player != null and is_instance_valid(mill_ambient_player):
		if nearest_mill >= AMBIENT_MAX_DIST:
			if mill_ambient_active:
				mill_ambient_player.stop()
				mill_ambient_active = false
		else:
			# Quiet bed, further attenuated with distance just like the donor's
			# volume-by-distance windmill (gui.script:3285-3302).
			mill_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB - 10.0 \
					- clampf((nearest_mill - 8.0) * 0.25, 0.0, 8.0)
			if not mill_ambient_active or not mill_ambient_player.playing:
				mill_ambient_player.play()
				mill_ambient_active = true

	# amb_towneur: donor gui.script:3292-3304 ramps 20..60 m at base volume 1.
	if town_ambient_player != null and is_instance_valid(town_ambient_player):
		var town_vol := clampf(1.0 - (nearest_town - 20.0) / 40.0, 0.0, 1.0)
		if town_vol <= 0.0:
			if town_ambient_active:
				town_ambient_player.stop()
				town_ambient_active = false
		else:
			town_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB + linear_to_db(town_vol)
			if not town_ambient_active or not town_ambient_player.playing:
				town_ambient_player.play()
				town_ambient_active = true

	# amb_sea: donor gui.script:3313-3335 counts water cells on a 4 m grid in
	# view, ramps volume by 20..60 m distance, then smooths it (base vol 0.5).
	# The 2D port has no frustum query, so a camera-centred +/-60 m window is
	# the read-only stand-in; no game state is written.
	if sea_ambient_player != null and is_instance_valid(sea_ambient_player):
		var terrain = game.get("terrain")
		var sea_target := 0.0
		if terrain is PackedByteArray and not (terrain as PackedByteArray).is_empty():
			var water_cells := 0
			var nearest_sea := AMBIENT_MAX_DIST
			var gx := int(center.x / AMBIENT_SEA_STEP)
			var gy := int(center.y / AMBIENT_SEA_STEP)
			var steps: int = int(AMBIENT_MAX_DIST / AMBIENT_SEA_STEP)
			for iy in range(gy - steps, gy + steps + 1):
				for ix in range(gx - steps, gx + steps + 1):
					var p := Vector2(ix * AMBIENT_SEA_STEP, iy * AMBIENT_SEA_STEP)
					if not game._is_water(p):
						continue
					water_cells += 1
					var d: float = p.distance_to(center)
					if d < nearest_sea:
						nearest_sea = d
			var sea_factor := clampf(float(water_cells) / AMBIENT_SEA_DIV, 0.0, 1.0)
			var sea_near := clampf(1.0 - (nearest_sea - 20.0) / 40.0, 0.0, 1.0)
			sea_target = sea_near * 0.5 * sea_factor
		# donor :3329-3334 delta clamp (-0.15..+0.075) and half-step smoothing.
		var delta := clampf(sea_target - sea_ambient_vol, -0.15, 0.075)
		sea_ambient_vol = clampf(sea_ambient_vol + delta * 0.5, 0.0, 1.0)
		if sea_ambient_vol <= 0.01:
			if sea_ambient_active:
				sea_ambient_player.stop()
				sea_ambient_active = false
		else:
			sea_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB + linear_to_db(sea_ambient_vol)
			if not sea_ambient_active or not sea_ambient_player.playing:
				sea_ambient_player.play()
				sea_ambient_active = true

func _replay_mill_ambient() -> void:
	# Covers importers that do not honour AudioStreamOggVorbis.loop. Never
	# restart a bed we deliberately stopped when the mill went out of range.
	if music_on and mill_ambient_active and is_instance_valid(mill_ambient_player):
		mill_ambient_player.play()

func _replay_wind_ambient() -> void:
	if music_on and wind_ambient_player != null and is_instance_valid(wind_ambient_player):
		wind_ambient_player.play()

func _replay_town_ambient() -> void:
	# Never restart a bed deliberately stopped when the town hall went away.
	if music_on and town_ambient_active and is_instance_valid(town_ambient_player):
		town_ambient_player.play()

func _replay_sea_ambient() -> void:
	if music_on and sea_ambient_active and is_instance_valid(sea_ambient_player):
		sea_ambient_player.play()

func _replay_music() -> void:
	if music_on and music_player != null and is_instance_valid(music_player):
		music_player.play()

func _replay_ambient() -> void:
	if music_on and ambient_player != null and is_instance_valid(ambient_player):
		ambient_player.play()

func stop_all() -> void:
	music_on = false
	mill_ambient_active = false
	town_ambient_active = false
	sea_ambient_active = false
	sea_ambient_vol = 0.0
	for p in players:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	for p in [music_player, ambient_player, mill_ambient_player,
			wind_ambient_player, town_ambient_player, sea_ambient_player]:
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
		else:
			# No Camera2D in render_mode="3d" (AUDIT3D-06 §5, audio.gd:317-323):
			# use the active Camera3D's horizontal ground-plane components with
			# the SAME cutoff/curve literals as the 2D branch above.
			var vp := get_viewport()
			var cam3 := vp.get_camera_3d() if vp != null else null
			if cam3 != null:
				var p3: Vector3 = cam3.global_position
				var d3: float = at.distance_to(Vector2(p3.x, p3.z) / 16.0)
				if d3 > 60.0:
					return
				vol_db -= clampf((d3 - 20.0) * 0.15, 0.0, 12.0)
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

# ------------------------------------------------------------------ selection
# AUDIO-SEL-01 — donor selection acknowledgement.
#
# Donor chain (read-only, all citations from DAUDIO-01 §3.1 / RV-SEL-01):
#   * gui\menu.inc\showunitcontrol.inc:1024-1027 — on unit-control rebuild,
#     `_sound_PlaySound(gc_sndlib_ind_interface, ...)` fires selectpeasant for
#     peasants/units and selectship for ships.
#   * dmscript.global:1276-1277 — gc_snd_ind_selectpeasant = 26,
#     gc_snd_ind_selectship = 27 (namespace :1250-1343).
#   * lib\sound.script:206-208 — both registered with cLoudFull; :98-102 gives
#     cLoudFull = 8000 (the 8000 global/isometric radius used by
#     `_sound_PlaySound`, sound.script:494-530), so this is a UI/global sound,
#     NOT a world-positioned emitter.
#   * sounds\interface\interface.snd:128-129 (selectship),
#     :132-158 (selectpeasant1..6); bank wiring at data\sounds\sounds.slc:7-8
#     (interface -> interface.snd); gc_sndlib_ind_interface = 1
#     (dmscript.global:1245-1247).
#   * data\resources\resource.lib:47 binds the visual selection brush
#     (brushes\selection.cfg); it is cited for completeness — it is the
#     rectangle style, not the sound.
#
# The port has no separate interface bank or listener/emitter objects. The
# existing `play()` called WITHOUT an `at` position is its non-positional /
# global path, so this API routes through it unchanged: no AudioStreamPlayer3D,
# no new player pool, no change to any existing API or default.
#
# Pure resolver: deterministic, testable without audio being enabled. The donor
# registers six peasant variants; selection size/index picks one (wrapping), so
# repeated identical selections resolve identically.
func selection_clip(kind: String, count: int) -> String:
	var k := kind.to_lower()
	if SHIP_SELECT_KINDS.has(k):
		return SELECT_SHIP
	var idx := ((maxi(count, 1) - 1) % SELECT_PEASANT_VARIANTS) + 1
	return "%s%d" % [SELECT_PEASANT, idx]

# Non-positional acknowledgement for a selection of `count` units of `kind`.
# Integration is deliberately NOT wired here: the owning caller (unit-control /
# selection rebuild site) must call this. See AUDIO_SEL_01.md, integration ticket.
func play_selection(kind: String, count: int) -> void:
	play([selection_clip(kind, count)])
