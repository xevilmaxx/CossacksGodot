# V7-91 / TERRAIN2-06 — dual-mode donor tile-atlas loader.
#
# Owned by V7-91 ONLY. This is the single new .gd in this atom: it does not
# edit the V7-85 build tool, the V7-86 shader, any other .gd, app/, config,
# tests or git state. It provides the STABLE API that V7-86 (and later A3)
# binds against, in two mutually exclusive modes:
#
#   MODE_SPLIT  reassemble the V7-85 atlas from lossless byte parts in
#               res://assets/terrain/atlas_parts/ into a user:// cache file,
#               verify its whole-file SHA-256, decode with Image.load_from_file
#               and expose ONE ImageTexture (a 16384x8192 atlas sampler).
#   MODE_ARRAY  build a Texture2DArray from the 112 already-shipped donor block
#               PNGs in res://assets/terrain/blocks/, using the V7-85 manifest
#               `layout` for index order, and expose the index->slot map.
#
# Mode is selectable by constructor OR config OR explicit load() call:
#   var loader := TileAtlasLoader.new("array")          # ctor
#   var loader := TileAtlasLoader.new({"tile_atlas_mode": "split"})  # config dict
#   var loader := TileAtlasLoader.new(); loader.load("array")        # explicit
# A ProjectSettings setting `terrain/tile_atlas_mode` is read as a last config
# source (read-only — this file never edits config). Default: MODE_SPLIT.
#
# DONOR EVIDENCE (all read-only citations, no invented indices):
#   * index dictionary = variant3d/assets/terrain/structs/presets_summer.json:2-125
#     mirror of data/terrain/tiles/terrain.presets:2-6 (Summer, DefaultIndex=0,
#     grass1 at index 0). 124 named cells = preset index, never a guessed id.
#   * face cells reuse the base block: data/terrain/tiles/tiles.mat:142-148,206-220
#     (rockNvf/vs -> rockN.dds; sand1f/s -> sand1.dds). Recorded in V7-85
#     manifest `layout[k].kind == FACE_BASE_REUSE`.
#   * masks: data/terrain/ref/reftilealpha.mat:30-37 (alpha.bmp, 512x256,
#     tiaAlphaFromIntensity, tfAlpha) and :139-146 (alphavert.bmp, 1024x512).
#     V7-85 converted them to L-mode PNGs; both stay small separate files.
#   * atlas grid/packing is APPROX: donor tsDouble/ttExtended packing is
#     engine-side / commented out (data/terrain/ref/reftile.lib:3-12). The
#     16x8 grid comes from the V7-85 manifest, not from a made-up constant.
#   * sand1/sand2 ship 256x256 (data/terrain/tiles/tiles.lib:53-63). The
#     upscale to 1024x1024 uses NEAREST so no texel value is invented —
#     APPROX_SAND_UPSCALE, inherited explicitly from V7-85.
#
# NO VISUAL PARITY CLAIM: no GPU A/B was run. Modes are alternative transports
# of the same donor-grounded art; this loader makes no rendering claim.
extends RefCounted
class_name TileAtlasLoader

const MODE_SPLIT := "split"
const MODE_ARRAY := "array"

const PARTS_DIR := "res://assets/terrain/atlas_parts/"
const ATLAS_DIR := "res://assets/terrain/atlas/"
const BLOCKS_DIR := "res://assets/terrain/blocks/"
const SPLIT_MANIFEST := "res://assets/terrain/atlas_parts/split_manifest.json"
const V785_MANIFEST := "res://assets/terrain/atlas/tile_index_atlas.manifest.json"
const CACHE_DIR := "user://tile_atlas_cache/"
const CACHE_FILE := "user://tile_atlas_cache/tile_index_atlas.png"
const CONFIG_SETTING := "terrain/tile_atlas_mode"
const CONFIG_KEY := "tile_atlas_mode"
const CHUNK := 1 << 20  # 1 MiB — never hold the whole 180 MB in RAM

var mode: String = MODE_SPLIT
var last_error: String = ""

var _atlas_texture: ImageTexture = null
var _tile_array: Texture2DArray = null
var _masks: Array[Texture2D] = []
var _index_to_slot: Dictionary = {}
var _slot_to_index: Dictionary = {}
var _grid: Vector2 = Vector2(16.0, 8.0)
var _loaded := false
var _reassembled_bytes := 0
var _reassembled_sha256 := ""


func _init(p_mode: Variant = "", p_config: Dictionary = {}) -> void:
	# Accept either TileAtlasLoader.new("array") or
	# TileAtlasLoader.new({"tile_atlas_mode": "array"}).
	var cfg: Dictionary = p_config
	var chosen := ""
	if p_mode is Dictionary:
		cfg = p_mode
	elif p_mode != null and str(p_mode).strip_edges() != "":
		chosen = str(p_mode).strip_edges()
	if chosen.is_empty() and cfg.has(CONFIG_KEY):
		chosen = str(cfg[CONFIG_KEY]).strip_edges()
	if chosen.is_empty():
		var setting: Variant = ProjectSettings.get_setting(CONFIG_SETTING, null)
		if setting != null and str(setting).strip_edges() != "":
			chosen = str(setting).strip_edges()
	set_mode(chosen)


# ---------------------------------------------------------------------------
# Mode selection / stable API consumed by V7-86 and A3.
# ---------------------------------------------------------------------------
func set_mode(p_mode: String) -> void:
	mode = p_mode if (p_mode == MODE_SPLIT or p_mode == MODE_ARRAY) else MODE_SPLIT
	_reset()


func get_mode() -> String:
	return mode


func is_loaded() -> bool:
	return _loaded


func get_last_error() -> String:
	return last_error


func _reset() -> void:
	_atlas_texture = null
	_tile_array = null
	_masks.clear()
	_index_to_slot.clear()
	_slot_to_index.clear()
	_loaded = false
	_reassembled_bytes = 0
	_reassembled_sha256 = ""
	last_error = ""


func _fail(msg: String) -> bool:
	last_error = msg
	_loaded = false
	push_error("TileAtlasLoader: " + msg)
	return false


# Stable entry point. `load()` deliberately mirrors the requested API name; it
# shadows GDScript's global load() INSIDE this instance only — no global load()
# is called anywhere in this file (textures use Image.load / create_from_image).
func load(p_mode: String = "") -> bool:
	var target := p_mode.strip_edges()
	if not target.is_empty():
		set_mode(target)
	_reset()
	last_error = ""
	if mode == MODE_ARRAY:
		return _load_array()
	return _load_split()


# Explicit alias for callers that prefer a non-shadowing name.
func load_atlas(p_mode: String = "") -> bool:
	return self.load(p_mode)  # self. disambiguates from the global load()


func get_atlas_texture() -> Texture2D:
	# MODE_SPLIT only: one 16384x8192 RGBA atlas sampler (V7-85 atlas).
	return _atlas_texture


func get_tile_array() -> Texture2DArray:
	# MODE_ARRAY only: 121 layers, one per filled V7-85 layout cell.
	return _tile_array


func get_index_to_slot() -> Dictionary:
	# MODE_ARRAY only: donor preset index -> Texture2DArray layer. Indices come
	# from presets_summer.json:2-125 via the V7-85 manifest; none invented.
	return _index_to_slot.duplicate()


func get_slot_to_index() -> Dictionary:
	return _slot_to_index.duplicate()


func atlas_grid() -> Vector2:
	return _grid


# Stable UV helper for V7-86.
#   MODE_SPLIT: bottom-left UV of the index's cell in the single atlas image,
#               cell = (index % cols, index / cols), cols/rows from V7-85.
#               Shader adds the local fract(s,t) fraction inside that cell.
#   MODE_ARRAY: Vector2.ZERO — each layer IS one whole tile, so the shader's
#               local UV applies directly (no atlas offset needed).
func tile_uv(index: int) -> Vector2:
	if mode != MODE_SPLIT:
		return Vector2.ZERO
	var cols := int(maxf(_grid.x, 1.0))
	var rows := int(maxf(_grid.y, 1.0))
	if index < 0:
		return Vector2.ZERO
	return Vector2(float(index % cols) / float(cols),
			float(index / cols) / float(rows))


# Stable layer helper for V7-86. Returns -1 in split mode (no array) or for an
# unresolved/empty preset index (alpha0a/b/c never had a shipped PNG).
func tile_layer(index: int) -> int:
	if mode != MODE_ARRAY:
		return -1
	return int(_index_to_slot.get(index, -1))


# Two donor masks, order [alpha, alphavert] to match V7-86's
# `alpha_atlas` / `alphavert_atlas` samplers (reftilealpha.mat:30-37 / :139-146).
func get_mask_textures() -> Array[Texture2D]:
	if _masks.is_empty():
		_load_masks()
	return _masks


func get_reassembly_info() -> Dictionary:
	return {
		"mode": mode,
		"bytes": _reassembled_bytes,
		"sha256": _reassembled_sha256,
		"array_layers": _tile_array.get_layers() if _tile_array != null else 0,
	}


# ---------------------------------------------------------------------------
# MODE_SPLIT — reassemble parts to user://, verify SHA-256, decode to texture.
# ---------------------------------------------------------------------------
func _read_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		last_error = "cannot open %s (error %d)" % [path, FileAccess.get_open_error()]
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		last_error = "invalid JSON in %s" % path
		return {}
	return parsed


func _load_grid() -> void:
	# Grid/packing comes from V7-85's manifest, never from a hardcoded table.
	var v785 := _read_json(V785_MANIFEST)
	var atlas: Dictionary = v785.get("atlas", {})
	var g: Array = atlas.get("grid", [])
	if g.size() == 2:
		_grid = Vector2(float(g[0]), float(g[1]))


func _load_image_at(path: String) -> Image:
	# Godot's Image.load accepts res:// paths directly. Try that first: the
	# project root contains a space ("Craft Anything"), so globalize_path()
	# is only a fallback, never the primary route.
	var img := Image.new()
	var err := img.load(path)
	if err == OK:
		return img
	var abs_err := img.load(ProjectSettings.globalize_path(path))
	if abs_err != OK:
		last_error = "cannot load image %s (res err %d, abs err %d)" % [path, err, abs_err]
		return null
	return img


func _load_split() -> bool:
	var manifest := _read_json(SPLIT_MANIFEST)
	if manifest.is_empty():
		return _fail("split manifest unavailable: " + last_error)
	_load_grid()
	var src: Dictionary = manifest.get("source", {})
	var expected_hash := str(src.get("sha256", ""))
	var expected_bytes := int(src.get("bytes", 0))
	var parts: Array = manifest.get("parts", [])
	if expected_hash.is_empty() or expected_bytes <= 0 or parts.is_empty():
		return _fail("split manifest missing source hash/bytes or parts")

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CACHE_DIR))
	var out := FileAccess.open(CACHE_FILE, FileAccess.WRITE)
	if out == null:
		return _fail("cannot open user:// cache for writing (error %d)"
				% FileAccess.get_open_error())

	var ctx := HashingContext.new()
	if ctx.start(HashingContext.HASH_SHA256) != OK:
		out.close()
		return _fail("HashingContext SHA-256 unavailable")
	var total := 0
	for entry in parts:
		if not entry is Dictionary:
			out.close()
			return _fail("malformed part entry")
		var name := str(entry.get("name", ""))
		if name.is_empty() or name.contains("..") or name.contains("/") or name.contains("\\"):
			out.close()
			return _fail("unsafe part name: " + name)
		var pf := FileAccess.open(PARTS_DIR + name, FileAccess.READ)
		if pf == null:
			out.close()
			return _fail("cannot read part: " + name)
		while not pf.eof_reached():
			var chunk := pf.get_buffer(CHUNK)
			if chunk.is_empty():
				break
			ctx.update(chunk)
			out.store_buffer(chunk)
			total += chunk.size()
		pf.close()
	out.close()

	var got := ctx.finish().hex_encode()
	_reassembled_bytes = total
	_reassembled_sha256 = got
	if total != expected_bytes or got != expected_hash:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CACHE_FILE))
		return _fail("reassembly mismatch: bytes=%d/%d sha=%s/%s"
				% [total, expected_bytes, got, expected_hash])

	var img := Image.new()
	var err := img.load(ProjectSettings.globalize_path(CACHE_FILE))
	if err != OK:
		return _fail("Image.load_from_file failed (error %d)" % err)
	_atlas_texture = ImageTexture.create_from_image(img)
	if _atlas_texture == null:
		return _fail("ImageTexture.create_from_image failed")
	_load_masks()
	_loaded = true
	return true


# ---------------------------------------------------------------------------
# MODE_ARRAY — Texture2DArray from shipped donor block PNGs in V7-85 order.
# ---------------------------------------------------------------------------
func _load_array() -> bool:
	var manifest := _read_json(V785_MANIFEST)
	if manifest.is_empty():
		return _fail("V7-85 manifest unavailable: " + last_error)
	var atlas: Dictionary = manifest.get("atlas", {})
	var g: Array = atlas.get("grid", [])
	if g.size() == 2:
		_grid = Vector2(float(g[0]), float(g[1]))
	var layout: Array = manifest.get("layout", [])
	if layout.is_empty():
		return _fail("V7-85 manifest has no layout")

	var images: Array[Image] = []
	for entry in layout:
		if not entry is Dictionary:
			return _fail("malformed V7-85 layout entry")
		var raw_src: Variant = entry.get("source_png", null)
		# JSON null must be checked BEFORE str(): GDScript str(null) == "<null>",
		# which would try to open a file literally named "<null>".
		if raw_src == null:
			# EMPTY preset (alpha0a/b/c): no shipped PNG -> no layer. Never
			# fabricate art (V7-85 UNVERIFIED_EMPTY_CELLS).
			continue
		var src_name := str(raw_src)
		if src_name.is_empty():
			continue
		var idx := int(entry.get("index", -1))
		var img := _load_image_at(BLOCKS_DIR + src_name)
		if img == null:
			return _fail("block PNG failed to load: %s (%s)" % [src_name, last_error])
		if img.get_size() != Vector2i(1024, 1024):
			# APPROX_SAND_UPSCALE: sand1/sand2 ship 256x256 (tiles.lib:53-63).
			# NEAREST replicates existing texels; no colour value invented.
			img.resize(1024, 1024, Image.INTERPOLATE_NEAREST)  # void in Godot 4.7
		if img.get_format() != Image.FORMAT_RGBA8:
			img.convert(Image.FORMAT_RGBA8)
		var slot := images.size()
		images.append(img)
		_index_to_slot[idx] = slot
		_slot_to_index[slot] = idx

	if images.is_empty():
		return _fail("no block images assembled")
	# Godot 4.7: create_from_images() is an INSTANCE method returning Error.
	var ta := Texture2DArray.new()
	var derr := ta.create_from_images(images)
	if derr != OK:
		return _fail("Texture2DArray.create_from_images failed (error %d)" % derr)
	_tile_array = ta
	_load_masks()
	_loaded = true
	return true


func _load_masks() -> void:
	_masks.clear()
	# Order matches V7-86 samplers: alpha_atlas then alphavert_atlas.
	var names := ["alpha.png", "alphavert.png"]
	for name in names:
		var tex: Texture2D = null
		for dir in [PARTS_DIR, ATLAS_DIR]:
			var img := _load_image_at(dir + name)
			if img != null:
				tex = ImageTexture.create_from_image(img)
				break
		if tex != null:
			_masks.append(tex)
