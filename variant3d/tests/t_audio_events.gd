# Small headless test: audio event -> file mapping (board P-12/P-13, DE_AUDIO_UI.md).
# Asserts intended behaviour: every event prefix emitted by main.gd resolves to a
# real .ogg, audio.gd's prefix lookup resolves, and every nation has a theme (or
# a registered fallback). Missing nation themes are a known baseline failure.
extends SceneTree

const OUT_DIR := "res://tests/results"
const AudioScript = preload("res://scripts/audio.gd")
const Data = preload("res://scripts/data.gd")

# Prefixes emitted by main.gd::_consume_events / audio.gd::walk_sound.
# (musket2/deathinf2 are the alternative variants on the same event branches;
# walk* are the six prefixes returned by walk_sound for the unit roster.)
const EVENT_PREFIXES := [
	"musket1", "musket2", "arrow1", "shotcannon1", "sabre1",
	"alarm", "construct", "arrowimpact1", "cannonexpl1", "workwood",
	"deathbuilding1", "deathinf1", "deathinf2", "btnclick",
	"walkpea", "walkinfmetal", "walkinfcloth", "walkcavfast", "walkcavslow", "walkartwheels",
]

var _id := "t_audio_events"
var _checks: Array[Dictionary] = []
var _ok := true
var _audio: Node = null

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
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

# Basenames of every .ogg actually present under res://assets/sounds (real read).
func _ogg_basenames() -> Dictionary:
	var out := {}
	var d := DirAccess.open("res://assets/sounds")
	if d == null:
		return out
	for f in d.get_files():
		if f.get_extension().to_lower() == "ogg":
			out[f.get_basename()] = true
	return out

# Mirror audio.gd::names_for's rule: exact name, or prefix followed by a digit.
func _prefix_has_file(prefix: String, names: Dictionary) -> bool:
	for n in names:
		var s := str(n)
		if s == prefix:
			return true
		if s.begins_with(prefix):
			var rest := s.substr(prefix.length())
			if rest != "" and rest[0] >= "0" and rest[0] <= "9":
				return true
	return false

# Read the "chop" event branch out of main.gd and return the prefixes it plays.
func _chop_prefixes() -> Array:
	var f := FileAccess.open("res://scripts/main.gd", FileAccess.READ)
	if f == null:
		return []
	var src := f.get_as_text()
	f.close()
	var idx := src.find('"chop":')
	if idx < 0:
		return []
	var tail := src.substr(idx, 500)
	var p := tail.find("_play([")
	if p < 0:
		return []
	tail = tail.substr(p)
	var out: Array = []
	var i := 0
	while i < tail.length():
		var ch := tail[i]
		if ch == ']':
			break
		if ch == '"':
			var j := i + 1
			while j < tail.length() and tail[j] != '"':
				j += 1
			out.append(tail.substr(i + 1, j - i - 1))
			i = j + 1
		else:
			i += 1
	return out

# A fallback is "registered" only if audio.gd declares one explicitly.
func _fallback_registered() -> bool:
	if _audio != null:
		var scr := _audio.get_script() as GDScript
		if scr != null:
			var c := scr.get_script_constant_map()
			if c.has("MUSIC_FALLBACK") or c.has("MUSIC_FALLBACK_NATION") or c.has("DEFAULT_NATION_MUSIC"):
				return true
	var f := FileAccess.open("res://scripts/audio.gd", FileAccess.READ)
	if f != null:
		var src := f.get_as_text()
		f.close()
		if src.contains("MUSIC_FALLBACK") or src.contains("music_fallback"):
			return true
	return false

func _initialize() -> void:
	var names := _ogg_basenames()

	# 1. Every documented event prefix has at least one backing .ogg file.
	var missing_files: Array = []
	for p in EVENT_PREFIXES:
		if not _prefix_has_file(str(p), names):
			missing_files.append(str(p))
	check("event_prefix_files_exist", missing_files.is_empty(),
		"%d/%d prefixes backed by .ogg; missing: %s (of %d files)" % [
			EVENT_PREFIXES.size() - missing_files.size(), EVENT_PREFIXES.size(),
			str(missing_files) if not missing_files.is_empty() else "none", names.size()])

	# Instantiate the real audio node. _initialize() runs before the tree is
	# ready, so add_child() would not fire _ready() yet; invoke it directly so
	# audio.gd's own code populates 'files' and the lookup uses real state.
	_audio = AudioScript.new()
	_audio._ready()

	# 2. audio.gd's real names_for()/has() prefix lookup resolves every event.
	var missing_lookup: Array = []
	if _audio == null:
		missing_lookup = EVENT_PREFIXES.duplicate()
	else:
		for p in EVENT_PREFIXES:
			if _audio.names_for([p]).is_empty():
				missing_lookup.append(str(p))
	check("audio_names_for_resolves_events", missing_lookup.is_empty(),
		"names_for() unresolved: %s" % [str(missing_lookup) if not missing_lookup.is_empty() else "none"])

	# 3. walk_sound() maps every known unit sid to a resolvable prefix.
	var bad_walk: Array = []
	if _audio == null:
		bad_walk = ["<no audio node>"]
	else:
		for sid in ["peasant", "pikeman", "roundshier", "serdiuk", "archer",
				"officer", "cossack", "dragoon", "cannon"]:
			var pre: Array = _audio.walk_sound(sid)
			if pre.is_empty() or not _audio.has(pre):
				bad_walk.append(sid)
	check("walk_sound_prefixes_resolve", bad_walk.is_empty(),
		"unresolved walk sids: %s" % [str(bad_walk) if not bad_walk.is_empty() else "none"])

	# 4. The "chop" event must emit a prefix that actually resolves (chop->workwood).
	var chop_pre := _chop_prefixes()
	var chop_names: Array = []
	if _audio != null and not chop_pre.is_empty():
		chop_names = _audio.names_for(chop_pre)
	check("chop_event_maps_to_sound", not chop_pre.is_empty() and not chop_names.is_empty(),
		"main.gd chop -> %s; names_for=%s" % [str(chop_pre), str(chop_names)])

	# 5. All 20 nations have a theme .ogg, or audio.gd registers a fallback.
	var fallback := _fallback_registered()
	var missing_nations: Array = []
	for code in Data.NATIONS.keys():
		if not names.has(str(code)) and not fallback:
			missing_nations.append(str(code))
	check("nation_theme_files_or_fallback", missing_nations.is_empty(),
		"%d nations, %d themed, fallback=%s; missing: %s" % [
			Data.NATIONS.size(), Data.NATIONS.size() - missing_nations.size(),
			str(fallback), str(missing_nations)])

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
