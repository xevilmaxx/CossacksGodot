extends Node3D

# I08 — mesh / rendering side of the fresh DONOR-FIRST terrain module
# (TERRAIN-SWARM-2026-11-26). SUBCELLS pass owner files: this file and
# variant3d/shaders/terrain_donor_shader.gdshader ONLY. No edit to
# world3d_terrain.gd, world3d.gd, game.gd, any test, asset or app/**.
# No runner job, no Godot process and no git operation was used to write it.
#
# TOP-LEVEL PROVENANCE / PARITY GUARD
# -----------------------------------
# Every donor constant below is a read-only citation of donor text or of the
# proven port geometry contract (world3d_terrain.gd). Nothing here is a donor
# binary, a donor GPU frame or a measurement. NO DONOR VISUAL PARITY CLAIM:
# `visual_parity_claim = false` and `stats["visual_parity_claim"] = false` are
# hard-coded; `stats` is telemetry ONLY and no value ever feeds back into sim.
# Port representation choices are labelled PORT APPROXIMATION. There is no
# synthetic noise/dither, no art-face promotion on relief cells, no shadow/AO
# fakery and no HEIGHT_SCALE fudge multiplier.
#
# Geometry contract translated verbatim from the proven port implementation
# (world3d_terrain.gd:1286-1428): ONE indexed ArrayMesh, ONE surface, ONE draw
# call; w*h vertices at cell centres; (w-1)*(h-1)*2 triangles; NORMAL from the
# SAME height field via the 1-cell forward-difference stencil
# (world3d_terrain.gd:901-917, :1387); UV2 = (float(tex_id), float(face))
# (world3d_terrain.gd:1315-1318, :1407). HEIGHT_SCALE is the labelled PORT
# contract 1.0 (world3d_terrain.gd:131, :1311) — never multiplied again.
#
# Relief is consumed ONLY as geometry (vertex Y) and as the input to the donor
# Blinn-Phong normal stencil. Z04-C guard: a cell marked in the additive
# `relief_mask` side channel never promotes its face mode (face stays 0), and no
# cliff / shore / desert tile art rewrite is performed here at all
# (P01 report §6 item 8; spec/01 §3:51-53).
#
# I06 INGEST: untyped `_game` / `data` references, additive dump keys only.
# The I06 SoA container (spec/01 §4:55-66; A01 §4.3/§4.4) is read, never written;
# `height` and `tex`/`tileblock` stay top-level, `fields.relief_mask` is optional
# and a short/missing array is zero-filled exactly as the dump contract says.

# ---------------------------------------------------------------------------
# Donor constants (every value carries its donor path:line citation)
# ---------------------------------------------------------------------------
const TILE_M: float = 2.0                  # data.gd:23; donor gc_meters_to_tile=2 (dmscript.global:171, DEC-05)
# Recovered tsDouble/ttExtended RGB selector geometry (DEC-VIS-01 §4/§6.2).
# TileSize=64 is the producer's selector unit; the shipped 1024² DDS divided by
# Rows/Cols=8 gives the effective 128² art subcell. TileSize cancels in UV space.
const DONOR_RGB_ROWS: int = 8              # DEC-VIS-01 §4.1/§4.2; ev_1d5e6e/ev_b2e664
const DONOR_RGB_COLS: int = 8              # DEC-VIS-01 §4.1/§4.2; ev_1d5e6e/ev_b2e664
const DONOR_RGB_TILE_SIZE: int = 64        # DEC-VIS-01 §4.1; reftile.lib active default
const DONOR_RGB_BLOCK_SIZE: int = 1024     # D08 §3.1 grass1.dds header (1024x1024, 11 mips)
const DONOR_RGB_SUBCELL_PX: int = DONOR_RGB_BLOCK_SIZE / DONOR_RGB_ROWS  # 128, DEC-VIS-01 §4.2
const HEIGHT_SCALE: float = 1.0            # world3d_terrain.gd:131,1311 — PORT contract, NO multiplier
const WATER_LEVEL: float = -0.25           # texturemap.inc:29-30,466-467 cWaterHeight (tile classify)
const SHORE_LEVEL: float = -0.1            # texturemap.inc:31,463-472 cWaterShoreHeight
const DONOR_WATER_BASIN_H: float = -1.1    # generatemap.inc:7 cWaterHeight (generation basin, NOT plane Y)
const DONOR_WATER_OFFSET_Y: float = -0.5   # generatemap.inc:688,704 cOffsetY (WaterFieldAdd per 2x2 field)
const WATER_SURFACE_Y: float = -0.25       # PORT APPROX placeholder for gl_TexCoord[1].z (water.dev.vert:18; water3d.gd:26-36)
const DONOR_CDIFF1: float = 0.5            # texturemap.inc:63 (4-neighbour steep test)
const DONOR_CDIFF2: float = 0.55           # texturemap.inc:64 (diagonal steep test)
const MAX_TILE_ID: int = 123               # terrain.presets:6-129 / spec/06:9 (124 ids, 0..123)
const WATER_SENTINEL: int = 255            # game.gd:52 BLK_WATER — PORT ONLY, not a donor tile id
const ATLAS_GRID_EXPECTED := Vector2(16.0, 8.0)  # V7-85 manifest:23-26; spec/06:19 (index-preserving 16x8)
const ALPHA_SRC_FACTOR := "GL_SRC_ALPHA"  # donor bmTransparency glBlendFunc (cossacks.exe:949234; D08/X17)
const ALPHA_DST_FACTOR := "GL_ONE_MINUS_SRC_ALPHA"  # donor bmTransparency (cossacks.exe:949234; D08/X17)

# Procedural assets (I05 output root, V11 ledger G8/G9; never the legacy root)
const NEW_ATLAS_DIR := "res://assets/terrain_new/atlas/"
const NEW_ATLAS_SINGLE := NEW_ATLAS_DIR + "tile_index_atlas.png"
const NEW_ATLAS_MANIFEST := NEW_ATLAS_DIR + "tile_index_atlas.manifest.json"
const LEGACY_ATLAS_SINGLE := "res://assets/terrain/atlas/tile_index_atlas.png"
const LEGACY_ATLAS_MANIFEST := "res://assets/terrain/atlas/tile_index_atlas.manifest.json"

# Read-only collaborators (their files are NEVER edited by this module)
const TILE_ATLAS_LOADER_PATH := "res://scripts/tile_atlas_loader.gd"
const WATER_SCRIPT_PATH := "res://scripts/water3d.gd"
const LEGACY_SHADER_PATH := "res://shaders/terrain_tileindex.gdshader"
const DONOR_SHADER_PATH := "res://shaders/terrain_donor_shader.gdshader"  # I10, optional

# Donor light.cfg literals (light.cfg:3-23,26-29) — Blinn-Phong terms consumed
# by the shader from the normal array; no lighting is invented here.
const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-8
const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)   # light.cfg:11-16
const DONOR_SPECULAR := Color(0.278431385755539, 0.266666680574417, 0.211764708161354)  # light.cfg:20-23
const DONOR_SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)              # light.cfg:26-29
const DONOR_FACE_SCALE: float = 0.125       # reftile.mat:124-126,150-152 (face alpha projection)
const FACE_TILT_DEG: float = 25.0           # tiles.lib:119-296,543-719 (reported, NOT applied here)

# ---------------------------------------------------------------------------
# Public state (all additive; no global class_name — dynamic load, like the
# proven world3d_terrain.gd:6-8)
# ---------------------------------------------------------------------------
var stats: Dictionary = {}
var mesh: ArrayMesh = null
var mesh_instance: MeshInstance3D = null
var water = null                       # one water3d.gd node, read-only binding
var atlas_mode: String = ""
var atlas_texture: Texture2D = null
var material_model: String = ""
var visual_parity_claim: bool = false  # hard guard, never set true
var atlas_mode_request: String = "single"
var season: String = ""

var _game = null                       # untyped I06 container / game reference
var _data = null                       # untyped explicit I06 container
var _w: int = 0
var _h: int = 0
var _n: int = 0
var _height := PackedFloat32Array()
var _tex := PackedByteArray()
var _relief_mask := PackedByteArray()
var _built: bool = false
var _ingest_source: String = ""
var _face_hist: Dictionary = {"0": 0, "1": 0, "2": 0}
var _water_sentinel_cells: int = 0
var _out_of_atlas_cells: int = 0
var _relief_guard_cells: int = 0
var _atlas_grid := Vector2.ZERO
var _atlas_info: Dictionary = {}
var _atlas_loader = null
var _atlas_texture: Texture2D = null
var _tile_map_tex: ImageTexture = null   # L8, nearest; one resolved donor id per I08 cell
var _alpha_tex: Texture2D = null
var _alphavert_tex: Texture2D = null
var _mip_source: String = ""
var _shader_path_used: String = ""
var _shader_params: Dictionary = {}
var _alpha_contract: Dictionary = {}


# ---------------------------------------------------------------------------
# Contract surface consumed by world3d.gd (P01 E14 / spec/12 §12.1)
# ---------------------------------------------------------------------------
func bind(g, d = null) -> void:
	_game = g
	_data = d


func has_chunk_or_fallback() -> bool:
	# One full-grid mesh covers the whole map; no chunk scheduling exists.
	return _built and mesh != null


func height_at_world(p: Vector2) -> float:
	# Bilinear sample of the SAME height[] grid the mesh was built from.
	# Mirrors world3d_terrain.gd:1722-1738 (game.gd:1893-1907).
	if not _built or _height.size() != _n or _w <= 0 or _h <= 0:
		return 0.0
	var fx := clampf(p.x / TILE_M + float(_w) * 0.5 - 0.5, 0.0, float(_w - 1))
	var fz := clampf(p.y / TILE_M + float(_h) * 0.5 - 0.5, 0.0, float(_h - 1))
	var x0 := int(fx)
	var z0 := int(fz)
	var x1: int = mini(x0 + 1, _w - 1)
	var z1: int = mini(z0 + 1, _h - 1)
	var tx: float = fx - float(x0)
	var tz: float = fz - float(z0)
	var h00: float = _height[z0 * _w + x0]
	var h10: float = _height[z0 * _w + x1]
	var h01: float = _height[z1 * _w + x0]
	var h11: float = _height[z1 * _w + x1]
	return (h00 + (h10 - h00) * tx + (h01 - h00) * tz
		+ (h00 - h10 - h01 + h11) * tx * tz) * HEIGHT_SCALE


func set_atlas_mode(mode: String) -> void:
	# Optional driver override; the loader still owns single -> split -> array.
	if mode in ["single", "split", "array"]:
		atlas_mode_request = mode


func set_season(value: String) -> void:
	# I05 season alias directories (V11 ledger G9); index-preserving rename.
	season = value.strip_edges().to_lower()


# ---------------------------------------------------------------------------
# Untyped, read-only I06 / additive-dump ingest (spec/01 §4)
# ---------------------------------------------------------------------------
func _get_prop(src, key: String):
	if src == null:
		return null
	if src is Dictionary:
		return (src as Dictionary).get(key, null)
	if src is Object:
		return (src as Object).get(key)
	return null


func _candidate_sources() -> Array:
	# Explicit I06 container wins; then container fields attached to the game;
	# then additive dump dictionaries; finally the game object itself.
	var out: Array = []
	if _data != null:
		out.append(_data)
	if _game != null and not (_data is Object and _game == _data):
		for key in ["terrain_data", "terrain_new", "terrain_donor_data"]:
			var c = _get_prop(_game, key)
			if c != null:
				out.append(c)
		for key in ["dump", "map_dump", "self_base"]:
			var d = _get_prop(_game, key)
			if d is Dictionary and (d as Dictionary).has("height"):
				out.append(d)
		out.append(_game)
	return out


func _source_dicts(src) -> Array:
	var out: Array = [src]
	var f = _get_prop(src, "fields")
	if f is Dictionary:
		out.append(f as Dictionary)   # additive fields are always secondary
	return out


func _first(srcs: Array, keys: Array, fallback: Variant = null) -> Variant:
	for src in srcs:
		for d in _source_dicts(src):
			if not (d is Dictionary):
				continue
			for k in keys:
				var v: Variant = (d as Dictionary).get(k, null)
				if v != null:
					return v
	return fallback


func _as_float_array(v) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	if v == null:
		return out
	if v is PackedFloat32Array:
		return (v as PackedFloat32Array).duplicate()   # copy; source untouched
	if v is PackedByteArray:
		var raw_b: PackedByteArray = v as PackedByteArray
		out.resize(int(raw_b.size() / 4))
		for i in range(out.size()):
			out[i] = raw_b.decode_float(i * 4)
		return out
	if v is Array:
		var a: Array = v as Array
		out.resize(a.size())
		for i in range(a.size()):
			out[i] = float(a[i])
		return out
	if v is String:
		var raw: PackedByteArray = Marshalls.base64_to_raw(v as String)
		out.resize(int(raw.size() / 4))
		for i in range(out.size()):
			out[i] = raw.decode_float(i * 4)
		return out
	return out


func _as_byte_array(v) -> PackedByteArray:
	var out := PackedByteArray()
	if v == null:
		return out
	if v is PackedByteArray:
		return (v as PackedByteArray).duplicate()      # copy; source untouched
	if v is String:
		return Marshalls.base64_to_raw(v as String)
	if v is Array:
		var a: Array = v as Array
		out.resize(a.size())
		for i in range(a.size()):
			out[i] = int(a[i]) & 0xFF
		return out
	return out


func _ingest() -> bool:
	var srcs := _candidate_sources()
	var w := int(_first(srcs, ["map_w", "w", "width"], 0))
	var h := int(_first(srcs, ["map_h", "h", "height_cells"], 0))
	if w <= 1 or h <= 1:
		return false
	var n := w * h
	for src in srcs:
		var source_dicts := _source_dicts(src)
		var hv: Variant = null
		for d in source_dicts:
			if d is Dictionary and (d as Dictionary).has("height"):
				hv = (d as Dictionary)["height"]
				break
		var candidate := _as_float_array(hv)
		if candidate.size() < n:   # short array => zeros, never an error
			continue
		_height = PackedFloat32Array()
		_height.resize(n)
		for i in range(n):
			_height[i] = candidate[i]
		var tv: Variant = _first(source_dicts, ["tex", "tileblock", "tile_indices"], null)
		var tc := _as_byte_array(tv)
		_tex = PackedByteArray()
		_tex.resize(n)
		for i in range(n):
			_tex[i] = tc[i] if i < tc.size() else 0
		var rv: Variant = _first(source_dicts, ["relief_mask"], null)
		var rc := _as_byte_array(rv)
		_relief_mask = PackedByteArray()
		_relief_mask.resize(n)
		for i in range(n):
			_relief_mask[i] = rc[i] if i < rc.size() else 0
		_w = w
		_h = h
		_n = n
		if src == _data:
			_ingest_source = "explicit I06 data (additive fields)"
		elif src == _game:
			_ingest_source = "game direct fields"
		else:
			_ingest_source = "game.terrain_data / additive dump (fields)"
		return true
	return false


func _build_tile_map_texture() -> ImageTexture:
	# SUBCELLS: RGB tile ids are fetched here, not by interpolating UV2.x across
	# a triangle. The L8 image is exactly _w x _h and the shader samples texel
	# centres from integer world-cell coordinates with a nearest sampler.
	if _w <= 0 or _h <= 0 or _n != _w * _h or _tex.size() != _n:
		push_error("terrain_donor_mesh: tile-map source grid is invalid")
		return null
	var pixels := _tex.duplicate()   # source I08 array stays read-only
	for i in range(_n):
		var tid := int(pixels[i])
		# Match the existing UV2.x atlas clamp exactly: water sentinel 255 and
		# every other out-of-range byte become tile 0, with stats still counted
		# from the raw value in build().
		if tid < 0 or tid > MAX_TILE_ID:
			tid = 0
		pixels[i] = tid
	var image := Image.create_from_data(_w, _h, false, Image.FORMAT_L8, pixels)
	if image == null or image.is_empty():
		push_error("terrain_donor_mesh: cannot create L8 tile-map image")
		return null
	var texture := ImageTexture.create_from_image(image)
	if texture == null:
		push_error("terrain_donor_mesh: cannot create tile-map texture")
	return texture


# ---------------------------------------------------------------------------
# Normals: proven 1-cell forward difference (one-sided backward at last
# row/column), world3d_terrain.gd:901-917. TILE_M stays 2.0 m and NO vertex or
# index is added. Donor analogue of hf.pvl.sm.vert normals (shaders.lib:16-19),
# which feed the donor Blinn-Phong light equations (hf.pvl.smx3.frag:13-17).
# This is the ONLY normal source in this module: no face tilt, no AO, no fake.
# ---------------------------------------------------------------------------
func _normal_at(h: PackedFloat32Array, w: int, height_cells: int,
		x: int, z: int) -> Vector3:
	if w < 2 or height_cells < 2:
		return Vector3(0.0, 1.0, 0.0)
	var xa: int = x + 1
	var xb: int = x
	if xa > w - 1:
		xa = x
		xb = x - 1
	var za: int = z + 1
	var zb: int = z
	if za > height_cells - 1:
		za = z
		zb = z - 1
	var dhdx: float = (h[z * w + xa] - h[z * w + xb]) / TILE_M
	var dhdz: float = (h[za * w + x] - h[zb * w + x]) / TILE_M
	return Vector3(-dhdx, 1.0, -dhdz).normalized()


# Donor face MODE for UV2.y only (0 ground / 1 front / 2 side). Steep tests are
# the donor cDiff1/cDiff2 literals (texturemap.inc:63-64,76-79,88-129); aspect
# axis is texturemap.inc:438-447. The donor PROMOTION rule is ENGINE/UNVERIFIED
# (RV-TRN-01 verdict C), so this changes neither UV2.x nor any tile art.
func _face_mode_at(h: PackedFloat32Array, w: int, height_cells: int,
		x: int, z: int) -> int:
	var i: int = z * w + x
	var c: float = h[i]
	var lh: float = h[z * w + maxi(0, x - 1)]
	var rh: float = h[z * w + mini(w - 1, x + 1)]
	var th: float = h[maxi(0, z - 1) * w + x]
	var bh: float = h[mini(height_cells - 1, z + 1) * w + x]
	var steep: bool = (absf(c - lh) > DONOR_CDIFF1
		or absf(c - rh) > DONOR_CDIFF1
		or absf(c - th) > DONOR_CDIFF1
		or absf(c - bh) > DONOR_CDIFF1)
	if not steep:
		var rb: float = h[mini(height_cells - 1, z + 1) * w + mini(w - 1, x + 1)]
		steep = (absf(bh - rh) > DONOR_CDIFF2 or absf(c - rb) > DONOR_CDIFF2)
	if not steep:
		return 0
	var gx: float = lh - rh
	var gy: float = th - bh
	return 1 if absf(gy) >= absf(gx) else 2


# ---------------------------------------------------------------------------
# Atlas transport (I05 output). Only path overrides are passed to TileAtlasLoader;
# that loader owns the single -> split -> array fallback and the CPU mip chain
# (tile_atlas_loader.gd:174-200, 335-356). Legacy atlas/loader are NEVER edited.
# ---------------------------------------------------------------------------
func _res_exists(path: String) -> bool:
	return FileAccess.file_exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(path))


func _atlas_paths() -> Dictionary:
	var single := NEW_ATLAS_SINGLE
	var manifest := NEW_ATLAS_MANIFEST
	if not season.is_empty():
		var season_single := NEW_ATLAS_DIR + "seasons/" + season + "/tile_index_atlas.png"
		var season_manifest := NEW_ATLAS_DIR + "seasons/" + season + "/tile_index_atlas.manifest.json"
		if _res_exists(season_single):
			single = season_single
		if _res_exists(season_manifest):
			manifest = season_manifest
	# Defensive: if the I05 asset tier is absent, fall back to the committed V7-85
	# pair so an unbuilt workspace still composes. Labelled in stats, not hidden.
	if not _res_exists(single):
		single = LEGACY_ATLAS_SINGLE
	if not _res_exists(manifest):
		manifest = LEGACY_ATLAS_MANIFEST
	return {"single_atlas_path": single, "manifest_path": manifest}


func _ensure_cpu_mipmaps(tex: Texture2D) -> Texture2D:
	# B02 fix: generate mips on the CPU BEFORE ImageTexture.create_from_image().
	# TileAtlasLoader already does this (tile_atlas_loader.gd:350-356); if a
	# transport returns a base-level-only image, regenerate here as a labelled
	# defensive fallback. Level 0 stays byte-identical; grid/index are unchanged.
	if tex == null or not (tex is ImageTexture):
		return tex
	var img: Image = (tex as ImageTexture).get_image()
	if img == null or img.is_empty() or img.has_mipmaps():
		return tex
	var err := img.generate_mipmaps(false)
	if err != OK:
		push_warning("terrain_donor_mesh: atlas mipmap generation failed (error %d)" % err)
		_mip_source = "base-level only (mip generation failed)"
		return tex
	_mip_source = "local CPU generate_mipmaps before ImageTexture.create_from_image"
	return ImageTexture.create_from_image(img)


func _repack_mask_alpha(src: Texture2D) -> Texture2D:
	# Donor mask intensity -> ALPHA (reftilealpha.mat:30-37,139-146;
	# hf.pvl.smx3.frag:13-17 reads texUnit1 intensity). Repack R -> A without
	# inventing a new asset, exactly as world3d_terrain.gd:662-675.
	if src == null or not (src is ImageTexture):
		return null
	var img: Image = (src as ImageTexture).get_image()
	if img == null or img.is_empty():
		return null
	img.convert(Image.FORMAT_RGBA8)
	var mw: int = img.get_width()
	var mh: int = img.get_height()
	for y in range(mh):
		for x in range(mw):
			var v: float = img.get_pixel(x, y).r
			img.set_pixel(x, y, Color(v, v, v, v))
	return ImageTexture.create_from_image(img)


func _load_atlas() -> bool:
	var paths := _atlas_paths()
	var loader_script := load(TILE_ATLAS_LOADER_PATH) as Script
	if loader_script == null or not loader_script.can_instantiate():
		push_error("terrain_donor_mesh: cannot load " + TILE_ATLAS_LOADER_PATH)
		return false
	_atlas_loader = loader_script.new(atlas_mode_request, paths)
	if _atlas_loader == null:
		return false
	# load() owns single -> split -> array; it reports the CHOSEN mode.
	if not bool(_atlas_loader.call("load")):
		push_error("terrain_donor_mesh: atlas load failed: %s" % str(_atlas_loader.call("get_last_error")))
		return false
	var chosen: Variant = _atlas_loader.get("current_mode")
	if chosen == null or str(chosen).is_empty():
		chosen = _atlas_loader.call("get_mode")
	atlas_mode = str(chosen)
	atlas_texture = _atlas_loader.call("get_atlas_texture")
	if atlas_texture == null:
		# ARRAY transport exposes Texture2DArray, not sampler2D. Use a dedicated
		# split loader for the single 2D atlas sampler (PORT LIMITATION, same as
		# world3d_terrain.gd:645-658); never stack two atlas resources.
		var split_loader = loader_script.new("split")
		if split_loader != null and bool(split_loader.call("load")):
			atlas_texture = split_loader.call("get_atlas_texture")
	_atlas_texture = _ensure_cpu_mipmaps(atlas_texture)
	if _atlas_texture == null:
		return false
	var mip_img: Image = null
	if _atlas_texture is ImageTexture:
		mip_img = (_atlas_texture as ImageTexture).get_image()
	if mip_img != null and mip_img.has_mipmaps() and _mip_source.is_empty():
		_mip_source = "loader CPU generate_mipmaps before ImageTexture.create_from_image"
	_atlas_grid = _atlas_loader.call("atlas_grid")
	if _atlas_grid.x <= 0.0 or _atlas_grid.y <= 0.0:
		_atlas_grid = ATLAS_GRID_EXPECTED
	_atlas_info = _atlas_loader.call("get_reassembly_info")
	var masks: Array = _atlas_loader.call("get_mask_textures")
	if masks.size() < 2:
		push_error("terrain_donor_mesh: loader returned fewer than 2 masks")
		return false
	_alpha_tex = _repack_mask_alpha(masks[0])
	_alphavert_tex = _repack_mask_alpha(masks[1])
	return _alpha_tex != null and _alphavert_tex != null


# ---------------------------------------------------------------------------
# Material. Donor alpha is a SEPARATE framebuffer crossfade channel:
# bmTransparency -> glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
# (cossacks.exe:949234; D08/X17; hf.pvl.smx3.frag:13-17,50). The legacy shader
# at :427 multiplies the mask into ALBEDO and writes ALPHA=1.0 (:475) — this is
# NOT donor semantics, so mask_to_alpha is set to 0.0 here (no albedo multiply)
# and the correct blend factors are exposed as material parameters + telemetry.
# If I10's new shader is unavailable the legacy shader is used explicitly as a
# PORT APPROXIMATION fallback; this file never edits terrain_tileindex.gdshader.
# ---------------------------------------------------------------------------
func _bind_known_params(mat: ShaderMaterial, params: Dictionary) -> Dictionary:
	var known: Dictionary = {}
	if mat.shader != null:
		for u in mat.shader.get_shader_uniform_list():
			known[str(u.get("name", ""))] = true
	var bound: Dictionary = {}
	var unbound: Array = []
	for k in params.keys():
		var key := str(k)
		if known.has(key):
			mat.set_shader_parameter(key, params[key])
			bound[key] = true
		else:
			unbound.append(key)
	return {"bound": bound, "unbound": unbound}


func _make_material(atlas_ready: bool = true) -> Material:
	if not atlas_ready or _tile_map_tex == null:
		# Geometry still builds; no shader sampler is bound to a null atlas/map.
		material_model = "PORT APPROXIMATION — plain material (atlas/tile map unavailable)"
		_shader_path_used = "NONE"
		var plain_fallback := StandardMaterial3D.new()
		plain_fallback.cull_mode = BaseMaterial3D.CULL_DISABLED
		plain_fallback.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		return plain_fallback
	# ResourceLoader.exists() avoids a spurious engine error when I10 has not
	# landed yet; the legacy shader (frozen, never edited) is the fallback.
	var shader: Shader = null
	if ResourceLoader.exists(DONOR_SHADER_PATH):
		shader = load(DONOR_SHADER_PATH) as Shader
	var is_new_shader: bool = shader != null
	var fallback_reason: String = ""
	if shader == null:
		shader = load(LEGACY_SHADER_PATH) as Shader
		fallback_reason = ("I10 shader unavailable — legacy terrain_tileindex.gdshader "
			+ "fallback; albedo multiply disabled (mask_to_alpha=0) but ALPHA=1.0 is "
			+ "hard-coded at :475, so true donor framebuffer crossfade is NOT achievable "
			+ "without I10. PORT APPROXIMATION, NO DONOR PARITY.")
	if shader == null:
		material_model = "no shader — plain PORT APPROXIMATION fallback"
		_shader_path_used = "NONE"
		var plain := StandardMaterial3D.new()
		plain.cull_mode = BaseMaterial3D.CULL_DISABLED
		plain.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		plain.roughness = 1.0
		return plain
	var mat := ShaderMaterial.new()
	mat.shader = shader
	_shader_path_used = DONOR_SHADER_PATH if is_new_shader else LEGACY_SHADER_PATH
	var params := {
		"tile_atlas": _atlas_texture,
		"tile_map": _tile_map_tex,
		"alpha_atlas": _alpha_tex,
		"alphavert_atlas": _alphavert_tex,
		"atlas_grid": _atlas_grid,
		# DEC-VIS-01 §6.2: integer world-cell lookup + map-half-offset 8x8 select.
		"map_cells": Vector2(float(_w), float(_h)),
		"donor_rows": float(DONOR_RGB_ROWS),
		"donor_cols": float(DONOR_RGB_COLS),
		"donor_tile_size": float(DONOR_RGB_TILE_SIZE),
		"donor_rgb_block_size": float(DONOR_RGB_BLOCK_SIZE),
		# Donor Blinn-Phong terms from light.cfg (donor path:line cited above).
		"ambient_rgb": Vector3(DONOR_AMBIENT.r, DONOR_AMBIENT.g, DONOR_AMBIENT.b),
		"diffuse_rgb": Vector3(DONOR_DIFFUSE.r, DONOR_DIFFUSE.g, DONOR_DIFFUSE.b),
		"specular_rgb": Vector3(DONOR_SPECULAR.r, DONOR_SPECULAR.g, DONOR_SPECULAR.b),
		"donor_sun_position": DONOR_SUN_POS,
		"face_scale": DONOR_FACE_SCALE,
		"shadow_enabled": 0.0,   # no shadow map shipped; no shadow fakery
		"fog_mode": 0.0,         # FogMode=0 (colors.lib:23,34-43)
		# Donor alpha: separate framebuffer channel, NOT an albedo multiply.
		"mask_to_alpha": 0.0,
		"alpha_from_mask": 1.0,
		"donor_blend_src_alpha": 1.0,
		"donor_blend_one_minus_src_alpha": 1.0,
	}
	_shader_params = _bind_known_params(mat, params)
	_alpha_contract = {
		"donor_blend": ALPHA_SRC_FACTOR + ", " + ALPHA_DST_FACTOR,
		"cite": "cossacks.exe:949234 (bmTransparency enum 1); hf.pvl.smx3.frag:13-17,50; D08/X17",
		"mask_is_framebuffer_alpha": true,
		"albedo_multiply_disabled": true,
		"rejected": "terrain_tileindex.gdshader:427 albedo multiply / :475 ALPHA=1.0",
		"shader_available": is_new_shader,
		"bound": _shader_params.get("bound", {}).duplicate(true),
		"unbound_parameters": (_shader_params.get("unbound", []) as Array).duplicate(true),
		"label": ("DONOR GLSL SEMANTICS" if is_new_shader
			else "PORT APPROXIMATION — " + fallback_reason),
	}
	material_model = ("I10 terrain_donor_shader.gdshader; donor bmTransparency framebuffer crossfade"
		if is_new_shader else "PORT APPROXIMATION — " + fallback_reason)
	return mat


# ---------------------------------------------------------------------------
# One height-aware water plane via the read-only bind_height_grid() contract
# (water3d.gd:305-321; integration hook :283-294). No wave texture is invented:
# hmapTex is a parameter key only (D06 §4:34-43); water3d supplies its shipped
# donor-derived diffusewaves0.png and the neutral substitute. Only ONE water
# node is ever created here — the composer must keep the legacy branch exclusive.
# ---------------------------------------------------------------------------
func _make_water(w: int, height_cells: int) -> bool:
	var script := load(WATER_SCRIPT_PATH) as Script
	if script == null or not script.can_instantiate():
		return false
	var node = script.new()
	if node == null:
		return false
	if not bool(node.call("build", w, height_cells)):
		node.free()
		return false
	node.call("bind_height_grid", _height, w, height_cells)
	water = node
	add_child(node)
	return true


# ---------------------------------------------------------------------------
# Telemetry: deterministic, additive, diagnostic only. NO sim write-back.
# ---------------------------------------------------------------------------
func _height_deciles() -> Dictionary:
	if _n <= 0:
		return {"boundaries": [], "counts": []}
	var sorted: Array = []
	sorted.resize(_n)
	for i in range(_n):
		sorted[i] = _height[i]
	sorted.sort()
	var bounds: Array = []
	for k in range(11):
		var pos: int = clampi(int(round(float(k) * 0.1 * float(_n - 1))), 0, _n - 1)
		bounds.append(float(sorted[pos]))
	var counts: Array = []
	counts.resize(10)
	for j in range(10):
		counts[j] = 0
	for i in range(_n):
		var v: float = _height[i]
		var bin: int = 9
		for j in range(10):
			if v <= bounds[j + 1]:
				bin = j
				break
		counts[bin] = int(counts[bin]) + 1
	return {"boundaries": bounds, "counts": counts}


func _make_stats(nverts: int, ntris: int, surfaces: int) -> Dictionary:
	var dec := _height_deciles()
	var hmin: float = INF
	var hmax: float = -INF
	for i in range(_n):
		hmin = minf(hmin, _height[i])
		hmax = maxf(hmax, _height[i])
	var water_stats: Dictionary = {}
	if water != null:
		var ws = water.get("stats")
		if ws is Dictionary:
			water_stats = ws as Dictionary
	return {
		"module": "res://scripts/terrain_donor_mesh.gd",
		"ticket": "I08",
		"grid": {"w": _w, "h": _h, "cells": nverts},
		"tile_m": TILE_M,
		"height_scale": HEIGHT_SCALE,
		"height_min_m": hmin,
		"height_max_m": hmax,
		"height_hist_deciles": dec,
		"face_hist": _face_hist.duplicate(true),
		"mesh_vertices": nverts,
		"mesh_triangles": ntris,
		"mesh_surfaces": surfaces,
		"terrain_draw_calls_expected": 1,
		"normals": ("1-cell forward difference on the same height[] field "
			+ "(world3d_terrain.gd:901-917,:1387); donor Blinn-Phong input; "
			+ "no tilt/AO/shadow fakery"),
		"uv": "cell-centre ((x+0.5)/w,(z+0.5)/h) over the full map",
		"uv2": ("x=float(tile id 0..123), y=float(face 0/1/2) "
			+ "(world3d_terrain.gd:1315-1318,:1407)"),
		"tile_ids": {
			"max": MAX_TILE_ID,
			"water_sentinel": WATER_SENTINEL,
			"water_sentinel_cells": _water_sentinel_cells,
			"out_of_atlas_cells_clamped": _out_of_atlas_cells,
			"sentinel_label": "PORT APPROXIMATION — 255 is game.gd:52, not a donor tile id",
		},
		"z04_guard": {
			"relief_mask_cells_no_face_promotion": _relief_guard_cells,
			"relief_read_as": "geometry (vertex Y) + donor Blinn-Phong normals only",
			"no_art_rewrite": true,
			"cite": "P01 report §6 item 8; spec/01 §3:51-53",
		},
		"atlas": {
			"requested_mode": atlas_mode_request,
			"active_mode": atlas_mode,
			"fallback_policy": "single -> split -> array (TileAtlasLoader.load, :174-200)",
			"grid": [_atlas_grid.x, _atlas_grid.y],
			"grid_expected": [ATLAS_GRID_EXPECTED.x, ATLAS_GRID_EXPECTED.y],
			"paths": _atlas_paths(),
			"info": _atlas_info.duplicate(true),
			"mipmaps_cpu_before_create_from_image": _mip_source,
		},
		"rgb_subcells": {
			"rows": DONOR_RGB_ROWS,
			"cols": DONOR_RGB_COLS,
			"tile_size": DONOR_RGB_TILE_SIZE,
			"donor_block_px": DONOR_RGB_BLOCK_SIZE,
			"effective_subcell_px": [DONOR_RGB_SUBCELL_PX, DONOR_RGB_BLOCK_SIZE / DONOR_RGB_COLS],
			"period_m": TILE_M * float(maxi(DONOR_RGB_ROWS, DONOR_RGB_COLS)),
			"selection": "DEC-VIS-01 §6.2 world-cell + map-half offset, mod Rows/Cols",
			"tile_map": {
				"width": _w,
				"height": _h,
				"format": "L8",
				"filter": "nearest (shader tile_map)",
				"source": "I08 _tex; same out-of-range clamp as UV2.x",
				"ready": _tile_map_tex != null,
			},
		},
		"material_model": material_model,
		"shader_path": _shader_path_used,
		"alpha": _alpha_contract.duplicate(true),
		"visual_parity_claim": visual_parity_claim,
		"fed_back_into_sim": false,
		"ingest": {
			"source": _ingest_source,
			"container": "I06 SoA (spec/01 §4), untyped read-only",
			"sim_arrays_mutated": false,
		},
		"water": {
			"module": WATER_SCRIPT_PATH if water != null else "NONE",
			"height_aware": bool(water_stats.get("height_aware", false)),
			"binding": "water3d.bind_height_grid(height,w,h) (water3d.gd:305-321)",
			"donor_levels_distinct": {
				"basin_generation": DONOR_WATER_BASIN_H,   # generatemap.inc:7
				"water_field_offset_y": DONOR_WATER_OFFSET_Y,  # generatemap.inc:688,704
				"tile_classify": WATER_LEVEL,              # texturemap.inc:29-30
				"shore": SHORE_LEVEL,                      # texturemap.inc:31
			},
			"surface_y": WATER_SURFACE_Y,
			"surface_y_label": "PORT APPROX placeholder (water.dev.vert:18; water3d.gd:26-36)",
			"hmap_tex": "parameter key only, NOT a texture (D06 §4:34-43); no wave texture invented",
			"one_water_node": water != null,
			"visual_parity_claimed": false,
		},
		"donor_references": {
			"cell_size": "data.gd:23; donor dmscript.global:171 (gc_meters_to_tile=2)",
			"height_scale": "world3d_terrain.gd:131,1311 (PORT contract 1.0)",
			"mesh_topology": "world3d_terrain.gd:1288-1289,1408-1428",
			"normals": "world3d_terrain.gd:901-917,1387; shaders.lib:16-19",
			"uv2": "world3d_terrain.gd:1315-1318,1407",
			"atlas": "terrain.presets:6-129; spec/06:19; V7-85 manifest:23-26",
			"alpha_blend": "cossacks.exe:949234; hf.pvl.smx3.frag:13-17,50",
			"water": "texturemap.inc:29-31,688,704; generatemap.inc:7; water3d.gd:305-321",
			"light": "light.cfg:3-23,26-29",
		},
	}


# ---------------------------------------------------------------------------
# Build: ONE indexed ArrayMesh, ONE surface, ONE draw call.
# ---------------------------------------------------------------------------
func build() -> bool:
	invalidate()
	if not _ingest():
		push_error("terrain_donor_mesh: bind() an I06 container / height dump first")
		return false
	_mip_source = ""
	var tile_map_ok := _build_tile_map_texture() != null
	var atlas_ok := _load_atlas()   # resolve samplers BEFORE the material is made
	var nverts: int = _n
	var ntris: int = (_w - 1) * (_h - 1) * 2
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var uvs := PackedVector2Array()
	var uvs2 := PackedVector2Array()
	var inds := PackedInt32Array()
	verts.resize(nverts)
	norms.resize(nverts)
	uvs.resize(nverts)
	uvs2.resize(nverts)
	inds.resize(ntris * 3)
	var cx: float = float(_w) * 0.5
	var cz: float = float(_h) * 0.5
	_face_hist = {"0": 0, "1": 0, "2": 0}
	_water_sentinel_cells = 0
	_out_of_atlas_cells = 0
	_relief_guard_cells = 0
	for z in range(_h):
		for x in range(_w):
			var i: int = z * _w + x
			# HEIGHT_SCALE is the labelled PORT contract 1.0 — no fudge multiplier.
			verts[i] = Vector3((float(x) + 0.5 - cx) * TILE_M,
				_height[i] * HEIGHT_SCALE,
				(float(z) + 0.5 - cz) * TILE_M)
			uvs[i] = Vector2((float(x) + 0.5) / float(_w),
				(float(z) + 0.5) / float(_h))
			norms[i] = _normal_at(_height, _w, _h, x, z)
			var raw_tid: int = int(_tex[i])
			if raw_tid == WATER_SENTINEL:
				_water_sentinel_cells += 1
			if raw_tid < 0 or raw_tid > MAX_TILE_ID:
				_out_of_atlas_cells += 1
				raw_tid = 0   # port water sentinel 255 is clamped; labelled PORT APPROX
			# Z04-C guard: relief cells never promote a face; relief affects ONLY
			# vertex Y and the height-field normal. No cliff/shore/desert rewrite.
			var face: int = 0
			if _relief_mask[i] != 0:
				_relief_guard_cells += 1
			else:
				face = _face_mode_at(_height, _w, _h, x, z)
			uvs2[i] = Vector2(float(raw_tid), float(face))
			_face_hist[str(face)] = int(_face_hist.get(str(face), 0)) + 1
	var k: int = 0
	for z in range(_h - 1):
		for x in range(_w - 1):
			var i00: int = z * _w + x
			var i10: int = i00 + 1
			var i01: int = i00 + _w
			var i11: int = i01 + 1
			# +Y facing: cross(Z, X) = +Y, hence i00,i01,i10 order.
			inds[k] = i00;      inds[k + 1] = i01;  inds[k + 2] = i10
			inds[k + 3] = i10;  inds[k + 4] = i01;  inds[k + 5] = i11
			k += 6
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norms
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_TEX_UV2] = uvs2
	arrays[Mesh.ARRAY_INDEX] = inds
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, _make_material(atlas_ok and tile_map_ok))
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "DonorTerrainMesh"
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	_make_water(_w, _h)
	_built = true
	stats = _make_stats(nverts, ntris, mesh.get_surface_count())
	stats["atlas"]["loaded"] = atlas_ok
	return true


func invalidate() -> void:
	# Free only THIS module's nodes; never touch sim arrays or another module.
	for child in get_children():
		remove_child(child)
		child.free()
	mesh_instance = null
	mesh = null
	water = null
	_atlas_loader = null
	_atlas_texture = null
	_tile_map_tex = null
	_alpha_tex = null
	_alphavert_tex = null
	_atlas_grid = Vector2.ZERO
	_atlas_info = {}
	_shader_params = {}
	_alpha_contract = {}
	_mip_source = ""
	_built = false
	stats = {}


func get_mesh() -> ArrayMesh:
	return mesh


func get_water_node():
	return water


func is_built() -> bool:
	return _built
