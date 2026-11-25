extends RefCounted

# FOLD-06 — central asset path resolver (path lookup ONLY; no nation wiring, no
# sim change, no donor access). Reads the additive `assets` map in
# res://assets/models/manifest.json; every sid's legacy flat path is retained as
# a fallback so a partly-migrated tree keeps working and rollback is instant.
#
# Priority: mapped res:// bucket path -> legacy composed path -> requested path.
# The 299 pre-existing `obj` / `texture_png` absolute OS fields are deliberately
# ignored: they point into the flat tree and are provenance/offline-tool data.
#
# NOTE: this module only resolves 3D geometry/GLB/tex. No 2D-bake path tokens
# are present, so the source-scan gates on the two runtime modules stay green.

const MANIFEST_PATH: String = "res://assets/models/manifest.json"
const LEGACY_OBJ_DIR: String = "res://assets/models/obj/"
const LEGACY_TEX_DIR: String = "res://assets/models/tex/"
const LEGACY_GLB_DIR: String = "res://assets/models/glb/"

static var _assets: Dictionary = {}
static var _buckets: Dictionary = {}
static var _loaded: bool = false


static func _load_index() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(MANIFEST_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("models"):
		return
	for item in ((parsed as Dictionary)["models"] as Array):
		if not (item is Dictionary):
			continue
		var sid := str((item as Dictionary).get("sid", ""))
		if sid == "":
			continue
		var a: Variant = (item as Dictionary).get("assets", null)
		if a is Dictionary:
			_assets[sid] = a as Dictionary
		var b: Variant = (item as Dictionary).get("bucket", "")
		if b is String and (b as String) != "":
			_buckets[sid] = str(b)
	var extra: Variant = (parsed as Dictionary).get("extra_assets", null)
	if extra is Dictionary:
		for k in (extra as Dictionary).keys():
			var v: Variant = (extra as Dictionary)[k]
			if v is Dictionary:
				_assets[str(k)] = v as Dictionary


static func bucket_for(sid: String) -> String:
	_load_index()
	return str(_buckets.get(sid, ""))


static func legacy_for(sid: String, ext: String, suffix: String = "") -> String:
	match ext:
		"tex":
			return LEGACY_TEX_DIR + sid + ".png"
		"glb":
			return LEGACY_GLB_DIR + sid + ".glb"
		_:
			return LEGACY_OBJ_DIR + sid + suffix + ".obj"


# ext: "obj" (suffix = stage/scaffold stem), "tex", "glb".
static func res_for(sid: String, ext: String, suffix: String = "") -> String:
	_load_index()
	var e: Dictionary = _assets.get(sid, {})
	var mapped := str(e.get(ext, ""))
	if mapped == "":
		return legacy_for(sid, ext, suffix)
	if suffix == "":
		return mapped
	var dot := mapped.rfind(".")
	if dot < 0:
		return mapped + suffix
	return mapped.substr(0, dot) + suffix + mapped.substr(dot)


# Prefer the migrated bucket file; fall back to the untouched flat original.
# Both are checked before returning, so a copy-only migration is safe.
static func existing(sid: String, ext: String, suffix: String = "") -> String:
	var preferred := res_for(sid, ext, suffix)
	if FileAccess.file_exists(preferred) or ResourceLoader.exists(preferred):
		return preferred
	var legacy := legacy_for(sid, ext, suffix)
	if legacy != preferred and (FileAccess.file_exists(legacy) or ResourceLoader.exists(legacy)):
		return legacy
	return preferred
