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
#
# TERRAINRES — PARTIAL FULL-RESOLUTION TILE TIER (opt-in, additive)
# ------------------------------------------------------------------
# AUDIT-ATLAS-RES §2/§6 says the commit-default terrain_new atlas gives a
# 16x16 px subcell (128px cell / 8x8 selector) while the donor authoring unit
# is 128x128 px (1024^2 block / 8x8). §6 option B (full 16384x8192 atlas) is
# already wired as HIRES-ATLAS-C / `features.terrain.hires_atlas` above, but it
# costs 512 MiB base / ~683 MiB with mips. This file adds a THIRD, opt-in tier:
# `features.terrain.array_atlas`. It collects only the tile ids actually present
# in the ingested grid (the canonical dumps use 14 legal ids, AUDIT §5/E7),
# reads their already-on-disk byte-identical 1024^2 donor-derived block PNGs,
# and packs them into the smallest 4-column power-of-two 2D atlas with one
# 1024^2 cell per id. The L8 tile map is remapped id -> compact slot so the
# UNCHANGED shader sees cell_px=1024, donor_to_packed=1 and a 128 px subcell.
# It is a partial-array-style layer set exposed through the existing sampler2D
# (a true sampler2DArray needs a shader edit, which is OUT OF SCOPE here).
# Default tier, hires opt-in, shader, masks, geometry and sim stay untouched.
# NO synthetic upscaling, NO invented art, NO donor visual parity claim: all
# new state is labelled telemetry only and never feeds back into sim.

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
# HIRES-ATLAS-C opt-in diagnostic tier. The legacy pair is the ALREADY ON DISK
# 16384x8192 / 16x8 x 1024^2-cell atlas (AUDIT-ATLAS-RES §6 option B, evidence
# E2: manifest size/cell_size + PNG IHDR). Nothing is generated, resampled or
# upscaled here; the commit-default terrain_new tier stays byte-identical.
const LEGACY_ATLAS_DIR := "res://assets/terrain/atlas/"
const LEGACY_ATLAS_SINGLE := LEGACY_ATLAS_DIR + "tile_index_atlas.png"
const LEGACY_ATLAS_MANIFEST := LEGACY_ATLAS_DIR + "tile_index_atlas.manifest.json"
const HIRES_ATLAS_FLAG_PATH := "features.terrain.hires_atlas"
# TERRAINRES opt-in: partial full-resolution tile tier (AUDIT-ATLAS-RES §6 D).
# Reads only the ids actually present in the ingested grid and packs their
# 1024^2 donor-derived block PNGs into a compact index-remapped 2D atlas.
# Absent/false => commit-default terrain_new; no shader, config.gd or asset edit.
const ARRAY_ATLAS_FLAG_PATH := "features.terrain.array_atlas"
const BLOCKS_DIR := "res://assets/terrain/blocks/"   # TileAtlasLoader:69, :455
const ARRAY_ATLAS_BLOCK_PX: int = 1024               # D08 §3.1 / E3; donor block
const ARRAY_ATLAS_COLS: int = 4                      # compact grid columns
const ARRAY_ATLAS_MAX_SLOTS: int = 16                # hard VRAM cap: 4x4 x 1024^2 = 64 MiB base
# LIGHT-MATCH opt-in: PORT CONSISTENCY calibration, NOT donor parity. When true,
# the terrain material binds the SAME ambient/sun energies the composer already
# uses for scene props (terrain_donor_world.gd:69-70); when false/absent the
# shader keeps its neutral 1.0 defaults, i.e. today's unscaled donor colours.
const LIGHT_MATCH_FLAG_PATH := "features.terrain.light_match"
# COLOR-UNIFY opt-in: PORT CALIBRATION, NOT donor parity. The full rig lift was
# MEASURED to overshoot (HANDOFF §9.15), so this flag applies ONLY the missing
# fraction of that same lift — never the full rig, never a second brightness
# constant, never a gamma/exposure/shadow/AO/emissive/noise fill. The gain is a
# ratio of measured candidate ROI pixels, not a donor material constant.
#   grass G      = [72.0, 74.4, 20.3]   # PHOTO_LED §1 global grass left
#   full rig O   = [134.1, 139.2, 42.9] # HANDOFF §9.15 measured light_match grass
#   lift   L=O-G = [62.1, 64.8, 22.6]
#   halo H       = [76.3, 78.4, 25.4]   # PHOTO_LED §1 mine halo
#   donor dir V  = [78.0, 80.0, 36.0]   # PHOTO_LED §2 direction-only cue
#   disc D       = [83.9, 85.0, 35.9]   # PHOTO_LED §1 (corroborates V.b ~= D.b)
#   target T per channel = [H.r, H.g, V.b] = [76.3, 78.4, 36.0]
#     r/g collapse the measured +4R/+4G grass->halo seam; b takes the donor
#     direction (== measured disc b within 0.1), collapsing the +16B disc delta.
#   need   N=T-G = [4.3, 4.0, 15.7]
#   fraction f=N/L = [0.06924, 0.06173, 0.69469]
#   gain g = 1 + f*(O/G - 1) = T/G = [1.05972, 1.05376, 1.77340]
const COLOR_UNIFY_FLAG_PATH := "features.terrain.color_unify"
const COLOR_UNIFY_GRASS_BASE := Vector3(72.0, 74.4, 20.3)   # PHOTO_LED §1
const COLOR_UNIFY_MINE_HALO := Vector3(76.3, 78.4, 25.4)    # PHOTO_LED §1
const COLOR_UNIFY_MINE_DISC := Vector3(83.9, 85.0, 35.9)    # PHOTO_LED §1
const COLOR_UNIFY_DONOR_DIR := Vector3(78.0, 80.0, 36.0)    # PHOTO_LED §2 direction only
const COLOR_UNIFY_FULL_RIG := Vector3(134.1, 139.2, 42.9)   # HANDOFF §9.15
const COLOR_UNIFY_TARGET := Vector3(76.3, 78.4, 36.0)       # [halo.r, halo.g, donor.b]
# Null-safe config access (same pattern as water3d.gd:6,163-167). config.gd
# owns the features table, so this file reads the dotted key through flag()
# and does NOT add a getter or edit config.gd.
const C3ConfigScript = preload("res://scripts/config.gd")

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
var hires_atlas: bool = false             # opt-in diagnostic; resolved once per build
var array_atlas: bool = false             # TERRAINRES opt-in; resolved once per build
var light_match: bool = false             # LIGHT-MATCH opt-in; resolved once per build
var color_unify: bool = false             # COLOR-UNIFY opt-in; resolved once per build
var _light_match: Dictionary = {}         # labelled rig-energy binding telemetry
var _color_unify: Dictionary = {}         # labelled partial-lift calibration telemetry
var _atlas_resolution: Dictionary = {}    # labelled resolution / VRAM telemetry
var _array_atlas: Dictionary = {}         # TERRAINRES partial-tier labelled telemetry
var _id_to_slot: Dictionary = {}          # donor tile id -> compact atlas slot (0..15)
var _slot_to_id: Dictionary = {}          # inverse map, telemetry only
var _compact_atlas_texture: Texture2D = null
var _compact_grid := Vector2.ZERO
var _unmapped_cells: int = 0              # cells whose id was not carried by the partial tier

var _game = null                       # untyped I06 container / game reference
var _data = null                       # untyped explicit I06 container
var _w: int = 0
var _h: int = 0
var _n: int = 0
var _height := PackedFloat32Array()
var _tex := PackedByteArray()
var _relief_mask := PackedByteArray()
var _collision := PackedByteArray()
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
		var cv: Variant = _first(source_dicts, ["collision4", "collision"], null)
		var cc := _as_byte_array(cv)
		_collision = PackedByteArray()
		_collision.resize(n)
		for i in range(n):
			_collision[i] = cc[i] if i < cc.size() else 0
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
		# TERRAINRES partial tier: the shader derives its atlas cell as
		# (id % grid.x, id / grid.x). Compact packing therefore requires the
		# L8 tile map to carry a SLOT index, not the donor id. UV2.x is left
		# untouched (alpha/debug transport keeps the original id). Unmapped
		# ids fall back to slot 0, a real donor-derived block — no art is
		# invented and the count is exported as labelled telemetry.
		if array_atlas and not _id_to_slot.is_empty():
			if _id_to_slot.has(tid):
				tid = int(_id_to_slot[tid])
			else:
				_unmapped_cells += 1
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
# axis is texturemap.inc:438-447. DEC_SMALL_chevron_source: these cDiff tests
# feed the COLLISION field; the donor only promotes to vf/vs when the cell is
# collision-tagged or on the far map edge (texturemap.inc:557). Untagged steep
# cells keep base tile art, so they must return face 0 here.
func _face_mode_at(h: PackedFloat32Array, w: int, height_cells: int,
		x: int, z: int, collision: PackedByteArray) -> int:
	var i: int = z * w + x
	var collision_tag: int = collision[i] if i < collision.size() else 0
	if collision_tag <= 0 and x < w - 1 and z < height_cells - 1:
		return 0
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


func _resolve_hires_atlas_flag() -> bool:
	# HIRES-ATLAS-C: opt-in ONLY. Reads the dotted key through config.gd's
	# generic flag() reader (no new getter, no config.gd edit). Active config can
	# be null before settings load and an older/no key falls back to false, so
	# the commit-default atlas tier is unchanged. Labelled in stats.
	var cfg = C3ConfigScript.active
	if cfg == null or not cfg.has_method("flag"):
		return false
	return bool(cfg.call("flag", HIRES_ATLAS_FLAG_PATH, false))


func _resolve_array_atlas_flag() -> bool:
	# TERRAINRES: opt-in ONLY. Same config.gd generic flag() reader as the other
	# opt-ins (no new getter, no config.gd edit). Active config can be null
	# before settings load and an older/no key falls back to false, so the
	# commit-default terrain_new tier is byte-identical. Independent of
	# light_match / color_unify; explicitly suppressed by hires_atlas.
	var cfg = C3ConfigScript.active
	if cfg == null or not cfg.has_method("flag"):
		return false
	return bool(cfg.call("flag", ARRAY_ATLAS_FLAG_PATH, false))


func _resolve_light_match_flag() -> bool:
	# LIGHT-MATCH: opt-in ONLY, resolved through config.gd's generic flag()
	# reader (no config.gd edit). Active config may be null before settings load
	# and an older/no key falls back to false, so the commit-default terrain is
	# unchanged. Labelled in stats.
	var cfg = C3ConfigScript.active
	if cfg == null or not cfg.has_method("flag"):
		return false
	return bool(cfg.call("flag", LIGHT_MATCH_FLAG_PATH, false))


func _resolve_color_unify_flag() -> bool:
	# COLOR-UNIFY: opt-in ONLY, resolved through the same config.gd flag() reader
	# (no config.gd edit). Null active config / missing key -> false, so the
	# commit-default terrain is byte-identical. Independent of light_match.
	var cfg = C3ConfigScript.active
	if cfg == null or not cfg.has_method("flag"):
		return false
	return bool(cfg.call("flag", COLOR_UNIFY_FLAG_PATH, false))


func _composer_light_energies() -> Dictionary:
	# LIGHT-MATCH: read the energies the ONE scene rig ALREADY uses for props.
	# The composer adds this mesh as its child (terrain_donor_world.gd:275), and
	# its own telemetry surface _lighting_stats() (:461-476) exposes
	# AMBIENT_ENERGY (:69) and SUN_ENERGY (:70). No constant is duplicated here
	# and no donor binary/GPU value is claimed. Standalone builds (unit tests or
	# direct mesh use, no composer parent) return {} and stay neutral.
	var parent := get_parent()
	if parent == null or not (parent is Object):
		return {}
	if not parent.has_method("_lighting_stats"):
		return {}
	var lighting: Variant = parent.call("_lighting_stats")
	if not (lighting is Dictionary):
		return {}
	var rig: Dictionary = lighting as Dictionary
	var ae: Variant = rig.get("ambient_energy", null)
	var se: Variant = rig.get("sun_energy", null)
	if not (ae is float or ae is int) or not (se is float or se is int):
		return {}
	return {
		"ambient_energy": float(ae),
		"sun_energy": float(se),
		"source": ("terrain_donor_world.gd:_lighting_stats() — "
			+ "AMBIENT_ENERGY :69 / SUN_ENERGY :70"),
	}


func _color_unify_calibration() -> Dictionary:
	# PORT CALIBRATION (candidate-internal, direction-only donor cue), NOT parity.
	# Arithmetic, per channel, from the two measured frames + the acceptance band:
	#   G  = [72.0, 74.4, 20.3]           global grass (PHOTO_LED §1)
	#   O  = [134.1, 139.2, 42.9]         full-rig overshoot (HANDOFF §9.15)
	#   L  = O-G = [62.1, 64.8, 22.6]     existing rig lift
	#   T  = [76.3, 78.4, 36.0]           halo.r, halo.g, donor-direction.b
	#   N  = T-G = [4.3, 4.0, 15.7]       missing lift (seam closure)
	#   f  = N/L = [0.06924, 0.06173, 0.69469]
	#   g  = 1 + f*(O/G - 1) = T/G = [1.05972, 1.05376, 1.77340]
	# The shader multiplies g into the packed donor Blinn-Phong term only. With
	# g = vec3(1) this is byte-identical to today's unscaled lighting. No gamma,
	# exposure, shadow, AO, emissive fill, noise or new donor constant is used.
	var lift := COLOR_UNIFY_FULL_RIG - COLOR_UNIFY_GRASS_BASE
	var need := COLOR_UNIFY_TARGET - COLOR_UNIFY_GRASS_BASE
	var lx := maxf(lift.x, 1e-6)
	var ly := maxf(lift.y, 1e-6)
	var lz := maxf(lift.z, 1e-6)
	var fx := need.x / lx
	var fy := need.y / ly
	var fz := need.z / lz
	var gx := 1.0 + fx * (COLOR_UNIFY_FULL_RIG.x / maxf(COLOR_UNIFY_GRASS_BASE.x, 1e-6) - 1.0)
	var gy := 1.0 + fy * (COLOR_UNIFY_FULL_RIG.y / maxf(COLOR_UNIFY_GRASS_BASE.y, 1e-6) - 1.0)
	var gz := 1.0 + fz * (COLOR_UNIFY_FULL_RIG.z / maxf(COLOR_UNIFY_GRASS_BASE.z, 1e-6) - 1.0)
	return {
		"feature": COLOR_UNIFY_FLAG_PATH,
		"label": "PORT CALIBRATION — missing fraction of the MEASURED rig lift; NOT donor parity",
		"measured_grass": [COLOR_UNIFY_GRASS_BASE.x, COLOR_UNIFY_GRASS_BASE.y, COLOR_UNIFY_GRASS_BASE.z],
		"measured_full_rig_overshoot": [COLOR_UNIFY_FULL_RIG.x, COLOR_UNIFY_FULL_RIG.y, COLOR_UNIFY_FULL_RIG.z],
		"measured_lift": [lift.x, lift.y, lift.z],
		"measured_halo": [COLOR_UNIFY_MINE_HALO.x, COLOR_UNIFY_MINE_HALO.y, COLOR_UNIFY_MINE_HALO.z],
		"measured_disc": [COLOR_UNIFY_MINE_DISC.x, COLOR_UNIFY_MINE_DISC.y, COLOR_UNIFY_MINE_DISC.z],
		"donor_video_grass_direction": [COLOR_UNIFY_DONOR_DIR.x, COLOR_UNIFY_DONOR_DIR.y, COLOR_UNIFY_DONOR_DIR.z],
		"target": [COLOR_UNIFY_TARGET.x, COLOR_UNIFY_TARGET.y, COLOR_UNIFY_TARGET.z],
		"missing_lift": [need.x, need.y, need.z],
		"fraction_of_full_rig_lift": [fx, fy, fz],
		"gain": [gx, gy, gz],
		"gain_vector": Vector3(gx, gy, gz),
		"predicted_grass": [COLOR_UNIFY_TARGET.x, COLOR_UNIFY_TARGET.y, COLOR_UNIFY_TARGET.z],
		"saturation_before": (COLOR_UNIFY_GRASS_BASE.y - COLOR_UNIFY_GRASS_BASE.z) / COLOR_UNIFY_GRASS_BASE.y,
		"saturation_target": (COLOR_UNIFY_TARGET.y - COLOR_UNIFY_TARGET.z) / COLOR_UNIFY_TARGET.y,
		"arithmetic": ("L=O-G; N=T-G; f=N/L; g=1+f*(O/G-1)=T/G; "
			+ "T.r=halo.r, T.g=halo.g, T.b=donor-direction.b (~= disc.b)"),
		"shader_uniform": "color_unify_gain",
		"scope": "terrain shader packed Blinn-Phong light term only; props/roofs/mines untouched",
		"guard": ("no gamma/exposure lift, no shadow/AO/emissive/noise, "
			+ "specular stays zero, debug defaults unchanged"),
	}


func _read_manifest_atlas(path: String) -> Dictionary:
	# Read-only probe of the CHOSEN manifest's declared geometry — the same file
	# the loader consumes in _load_grid() (tile_atlas_loader.gd:310-317). No
	# asset is written and no index is fabricated.
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var txt := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if not (parsed is Dictionary):
		return {}
	var atlas_v: Variant = (parsed as Dictionary).get("atlas", null)
	if not (atlas_v is Dictionary):
		return {}
	return atlas_v as Dictionary


func _read_manifest_full(path: String) -> Dictionary:
	# Read-only probe of the WHOLE manifest. `_read_manifest_atlas()` above
	# returns only its `atlas` block; the partial tier also needs `layout`
	# (index -> source_png / source_size). No asset is written or resampled.
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var txt := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary


func _used_tile_id_counts() -> Dictionary:
	# Data-driven used-id set: the ingested L8 grid is the only source of truth.
	# Water sentinel / out-of-range bytes are excluded exactly as in build().
	# The canonical 240^2 dumps contain 12 legal ids; across 64^2/240^2/320^2
	# the union is 14 (AUDIT-ATLAS-RES §5/E7). This reports what THIS map
	# actually uses — no fabricated id list.
	var counts: Dictionary = {}
	for i in range(_tex.size()):
		var tid := int(_tex[i])
		if tid < 0 or tid > MAX_TILE_ID:
			continue
		counts[tid] = int(counts.get(tid, 0)) + 1
	return counts


func _array_atlas_fallback(reason: String) -> bool:
	# EVERY failure is a labelled fallback to the unchanged commit-default
	# terrain_new tier. No partial atlas is bound and no art is synthesised.
	_array_atlas = {
		"feature": ARRAY_ATLAS_FLAG_PATH,
		"enabled": true,
		"active": false,
		"tier": "terrain_new_2048x1024_128cell (DEFAULT — partial tier unavailable)",
		"fallback": reason,
		"ids_covered": [],
		"ids_covered_count": 0,
		"no_synthetic_upscaling": true,
		"no_invented_art": true,
		"visual_parity_claim": false,
	}
	return false


func _build_partial_array_atlas() -> bool:
	# TERRAINRES: opt-in partial full-resolution tier (AUDIT-ATLAS-RES §6 D/B).
	# Collect the ids present in THIS grid, read their already-on-disk
	# byte-identical 1024^2 donor-derived block PNGs, and pack one cell per id
	# into the smallest 4-column power-of-two 2D atlas. The tile map is later
	# remapped id -> slot so the UNCHANGED shader computes cell_px=1024 and a
	# 128 px subcell. Source art is never resampled, upscaled or invented.
	_array_atlas = {}
	_id_to_slot = {}
	_slot_to_id = {}
	_compact_atlas_texture = null
	_compact_grid = Vector2.ZERO
	_unmapped_cells = 0
	if hires_atlas:
		# HIRES-ATLAS-C is the higher-priority opt-in and is left unchanged.
		return _array_atlas_fallback("suppressed by features.terrain.hires_atlas (option B tier kept)")
	var counts := _used_tile_id_counts()
	if counts.is_empty():
		return _array_atlas_fallback("ingested grid has no legal tile id")
	var manifest := _read_manifest_full(LEGACY_ATLAS_MANIFEST)
	var layout: Variant = manifest.get("layout", null)
	if not (layout is Array) or (layout as Array).is_empty():
		return _array_atlas_fallback("legacy manifest layout unavailable: " + LEGACY_ATLAS_MANIFEST)
	var sources: Dictionary = {}
	for entry in (layout as Array):
		if not (entry is Dictionary):
			continue
		var raw_png: Variant = (entry as Dictionary).get("source_png", null)
		if raw_png == null:
			continue   # EMPTY preset (alpha0a/b/c): never fabricate art
		var png := str(raw_png)
		if png.is_empty():
			continue
		var sz: Variant = (entry as Dictionary).get("source_size", null)
		if not (sz is Array) or (sz as Array).size() != 2:
			continue
		if int((sz as Array)[0]) != ARRAY_ATLAS_BLOCK_PX or int((sz as Array)[1]) != ARRAY_ATLAS_BLOCK_PX:
			continue   # e.g. sand1/sand2 256^2 donor: no upscaling, not carried
		sources[int((entry as Dictionary).get("index", -1))] = png
	var ids: Array = []
	for key in counts.keys():
		ids.append(int(key))
	ids.sort()
	var kept: Array = []
	var dropped: Array = []
	for idv in ids:
		var id := int(idv)
		if not sources.has(id):
			dropped.append(id)
			continue
		if kept.size() >= ARRAY_ATLAS_MAX_SLOTS:
			dropped.append(id)
			continue
		kept.append(id)
	if kept.is_empty():
		return _array_atlas_fallback("no used id has a 1024^2 donor-derived block PNG")
	var rows: int = int(ceil(float(kept.size()) / float(ARRAY_ATLAS_COLS)))
	var rows_pow2: int = 1
	while rows_pow2 < rows:
		rows_pow2 *= 2
	var cols: int = ARRAY_ATLAS_COLS
	rows = rows_pow2
	var w: int = cols * ARRAY_ATLAS_BLOCK_PX
	var h: int = rows * ARRAY_ATLAS_BLOCK_PX
	var blocks: Array[Image] = []
	for idv2 in kept:
		var id2 := int(idv2)
		var block := Image.new()
		var err := block.load(BLOCKS_DIR + str(sources[id2]))
		if err != OK:
			err = block.load(ProjectSettings.globalize_path(BLOCKS_DIR + str(sources[id2])))
		if err != OK or block.get_size() != Vector2i(ARRAY_ATLAS_BLOCK_PX, ARRAY_ATLAS_BLOCK_PX):
			return _array_atlas_fallback("block PNG missing/wrong size for id %d (%s)"
				% [id2, str(sources[id2])])
		if block.get_format() != Image.FORMAT_RGBA8:
			block.convert(Image.FORMAT_RGBA8)
		blocks.append(block)
	if blocks.is_empty():
		return _array_atlas_fallback("no block image assembled")
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	if img == null or img.is_empty():
		return _array_atlas_fallback("cannot allocate %dx%d compact atlas image" % [w, h])
	# Unused slots duplicate a REAL used block: byte-identical donor-derived
	# pixels, not synthetic detail and not invented art. No fragment samples
	# those slots in this tier (the tile map carries only kept slots); the fill
	# only prevents garbage when coarse mip levels blend across cells.
	var filler: Image = blocks[0]
	for slot in range(cols * rows):
		img.blit_rect(filler, Rect2i(0, 0, ARRAY_ATLAS_BLOCK_PX, ARRAY_ATLAS_BLOCK_PX),
			Vector2i((slot % cols) * ARRAY_ATLAS_BLOCK_PX,
				int(slot / cols) * ARRAY_ATLAS_BLOCK_PX))
	for slot2 in range(kept.size()):
		img.blit_rect(blocks[slot2], Rect2i(0, 0, ARRAY_ATLAS_BLOCK_PX, ARRAY_ATLAS_BLOCK_PX),
			Vector2i((slot2 % cols) * ARRAY_ATLAS_BLOCK_PX,
				int(slot2 / cols) * ARRAY_ATLAS_BLOCK_PX))
		_id_to_slot[int(kept[slot2])] = slot2
		_slot_to_id[slot2] = int(kept[slot2])
	if img.generate_mipmaps(false) != OK:
		push_warning("terrain_donor_mesh: partial atlas mipmap generation failed; base level unchanged")
	_compact_atlas_texture = ImageTexture.create_from_image(img)
	if _compact_atlas_texture == null:
		return _array_atlas_fallback("ImageTexture.create_from_image failed for partial atlas")
	_compact_grid = Vector2(float(cols), float(rows))
	var base_bytes := float(w * h * 4)
	var base_mib := base_bytes / 1048576.0
	var mip_mib := base_mib * 4.0 / 3.0
	var full_base := float(16384 * 8192 * 4) / 1048576.0
	var full_mip := full_base * 4.0 / 3.0
	var covered: Array = []
	for idv3 in kept:
		covered.append(int(idv3))
	_array_atlas = {
		"feature": ARRAY_ATLAS_FLAG_PATH,
		"enabled": true,
		"active": true,
		"tier": "partial_array_2d_%dx%d_1024cell" % [cols, rows],
		"label": ("PARTIAL FULL-RES TILE TIER — one 1024^2 donor-derived block per used "
			+ "id, index-remapped tile map; PORT APPROXIMATION, NO donor parity claim"),
		"fallback": "NONE — partial tier active",
		"source_manifest": LEGACY_ATLAS_MANIFEST,
		"source_blocks_dir": BLOCKS_DIR,
		"ids_covered": covered,
		"ids_covered_count": covered.size(),
		"cells_by_id": counts.duplicate(true),
		"ids_dropped": dropped.duplicate(),
		"ids_dropped_count": dropped.size(),
		"unmapped_cells": 0,   # filled in build() after the tile map is remapped
		"grid": [cols, rows],
		"atlas_size_px": [w, h],
		"cell_size_px": [ARRAY_ATLAS_BLOCK_PX, ARRAY_ATLAS_BLOCK_PX],
		"effective_subcell_px": [DONOR_RGB_SUBCELL_PX, DONOR_RGB_SUBCELL_PX],
		"selection_period_m": TILE_M * float(maxi(DONOR_RGB_ROWS, DONOR_RGB_COLS)),
		"vram_rgba8_bytes_base": int(base_bytes),
		"vram_rgba8_mib_base": base_mib,
		"vram_rgba8_mib_with_mips": mip_mib,
		"full_atlas_rgba8_mib_base": full_base,
		"full_atlas_rgba8_mib_with_mips": full_mip,
		"vram_saved_mib_with_mips": full_mip - mip_mib,
		"mip_basis": "CPU generate_mipmaps(false) before ImageTexture.create_from_image (level 0 unchanged)",
		"shader_binding": ("sampler2D tile_atlas bound to compact atlas; atlas_grid = partial grid; "
			+ "donor_to_packed = 1; NO shader edit. True sampler2DArray needs a shader change (OUT OF SCOPE)"),
		"id_remap": ("L8 tile map carries compact slot, not donor id; UV2.x keeps the original "
			+ "id for alpha/debug. id-gated shader alpha overrides therefore see slot indices — "
			+ "labelled PORT APPROXIMATION"),
		"no_synthetic_upscaling": true,
		"no_invented_art": true,
		"filler_policy": "unused slots duplicate a real used block; no fragment samples them",
		"visual_parity_claim": false,
	}
	return true


func _atlas_resolution_info(paths: Dictionary) -> Dictionary:
	# HIRES-ATLAS-C labelled diagnostic. Numbers come from the chosen manifest
	# plus arithmetic: RGBA8 base = w*h*4 bytes, full mip chain = base*4/3.
	# 16384x8192 => 512 MiB base / ~683 MiB with mips (AUDIT-ATLAS-RES §6 B).
	# This is telemetry only; no shader uniform, geometry or sim value is fed.
	var size := Vector2i(2048, 1024)
	var cell := Vector2i(128, 128)
	var atlas := _read_manifest_atlas(str(paths.get("manifest_path", "")))
	var s: Variant = atlas.get("size", null)
	var c: Variant = atlas.get("cell_size", null)
	if s is Array and (s as Array).size() == 2:
		size = Vector2i(int((s as Array)[0]), int((s as Array)[1]))
	if c is Array and (c as Array).size() == 2:
		cell = Vector2i(int((c as Array)[0]), int((c as Array)[1]))
	if hires_atlas:
		# Documented tier geometry used only if the manifest cannot be read.
		if size.x <= 0 or size.y <= 0:
			size = Vector2i(16384, 8192)
		if cell.x <= 0 or cell.y <= 0:
			cell = Vector2i(1024, 1024)
	var base_bytes := float(size.x * size.y * 4)
	var base_mib := base_bytes / 1048576.0
	var mip_mib := base_mib * 4.0 / 3.0
	var subcell := Vector2i(maxi(1, cell.x / maxi(1, DONOR_RGB_ROWS)),
		maxi(1, cell.y / maxi(1, DONOR_RGB_COLS)))
	var period_m := TILE_M * float(maxi(DONOR_RGB_ROWS, DONOR_RGB_COLS))
	var warning := ""
	if hires_atlas:
		warning = ("DIAGNOSTIC / NO PARITY CLAIM: hires atlas %dx%d, %dx%d cell; "
			+ "RGBA8 VRAM ~= %.0f MiB base / ~%.0f MiB with CPU mips. "
			+ "Verify target VRAM before shipping.") % [
				size.x, size.y, cell.x, cell.y, base_mib, mip_mib,
			]
	return {
		"feature": HIRES_ATLAS_FLAG_PATH,
		"enabled": hires_atlas,
		"tier": str(paths.get("tier", "")),
		"size_px": [size.x, size.y],
		"cell_size_px": [cell.x, cell.y],
		"subcell_px": [subcell.x, subcell.y],
		"selection_period_m": period_m,
		"vram_rgba8_bytes_base": int(base_bytes),
		"vram_rgba8_mib_base": base_mib,
		"vram_rgba8_mib_with_mips": mip_mib,
		"mip_basis": "CPU generate_mipmaps before ImageTexture.create_from_image (level 0 unchanged)",
		"masks": "loader get_mask_textures() from atlas/atlas_parts dirs — tier-independent",
		"season_aliases": "season atlas + manifest selected from the active tier when present",
		"diagnostic_warning": warning,
		"note": ("diagnostic only; shader textureSize() adapts, no shader edit, no synthetic "
			+ "detail, no upscaling beyond the labelled tier, NO donor parity claim"),
	}


func _atlas_paths() -> Dictionary:
	# Default tier stays terrain_new. The opt-in tier binds the EXISTING legacy
	# 16384x8192 / 1024^2-cell pair; season variants are flat in that same dir
	# (tile_index_atlas_<season>.png / .manifest.json) and existence-gated.
	var single := NEW_ATLAS_SINGLE
	var manifest := NEW_ATLAS_MANIFEST
	var tier := "terrain_new_2048x1024_128cell"
	if hires_atlas:
		single = LEGACY_ATLAS_SINGLE
		manifest = LEGACY_ATLAS_MANIFEST
		tier = "legacy_16384x8192_1024cell"
	if not season.is_empty():
		var season_single := ""
		var season_manifest := ""
		if hires_atlas:
			season_single = LEGACY_ATLAS_DIR + "tile_index_atlas_" + season + ".png"
			season_manifest = LEGACY_ATLAS_DIR + "tile_index_atlas_" + season + ".manifest.json"
		else:
			season_single = NEW_ATLAS_DIR + "seasons/" + season + "/tile_index_atlas.png"
			season_manifest = NEW_ATLAS_DIR + "seasons/" + season + "/tile_index_atlas.manifest.json"
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
	return {
		"single_atlas_path": single,
		"manifest_path": manifest,
		"tier": tier,
	}


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
	_atlas_resolution = _atlas_resolution_info(paths)
	if hires_atlas:
		var diag := str(_atlas_resolution.get("diagnostic_warning", ""))
		if not diag.is_empty():
			push_warning("terrain_donor_mesh: " + diag)
	var loader_script := load(TILE_ATLAS_LOADER_PATH) as Script
	if loader_script == null or not loader_script.can_instantiate():
		push_error("terrain_donor_mesh: cannot load " + TILE_ATLAS_LOADER_PATH)
		return false
	_atlas_loader = loader_script.new(atlas_mode_request, paths)
	if _atlas_loader == null:
		return false
	var use_partial: bool = (array_atlas and not hires_atlas
		and _compact_atlas_texture != null and not _id_to_slot.is_empty())
	if use_partial:
		# TERRAINRES partial tier: bind the compact full-res atlas built from
		# the used ids' real block PNGs. The loader is used for its two masks
		# ONLY (get_mask_textures() lazily calls _load_masks()), so the default
		# terrain_new atlas is never decoded into VRAM. Sampler, grid and the
		# remapped tile map are already prepared; no shader edit is involved.
		atlas_mode = str(_array_atlas.get("tier", "partial_array_2d"))
		atlas_texture = _compact_atlas_texture
		_atlas_texture = _compact_atlas_texture
		_atlas_grid = _compact_grid
		_mip_source = "CPU generate_mipmaps before ImageTexture.create_from_image (partial tier)"
		_atlas_info = {
			"mode": atlas_mode,
			"array_layers": _id_to_slot.size(),
			"single_path": "partial block PNGs: " + BLOCKS_DIR,
			"note": "partial-array-style 2D atlas; true sampler2DArray requires a shader edit (OUT OF SCOPE)",
		}
		_atlas_resolution["superseded_by"] = ARRAY_ATLAS_FLAG_PATH
		_atlas_resolution["active_tier"] = atlas_mode
		_atlas_resolution["tier"] = atlas_mode
		var partial_masks: Array = _atlas_loader.call("get_mask_textures")
		if partial_masks.size() < 2:
			push_error("terrain_donor_mesh: loader returned fewer than 2 masks (partial tier)")
			return false
		_alpha_tex = _repack_mask_alpha(partial_masks[0])
		_alphavert_tex = _repack_mask_alpha(partial_masks[1])
		return _alpha_tex != null and _alphavert_tex != null
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
	# LIGHT-MATCH: bind the shared rig energies only under the opt-in. The
	# shader uniforms default to 1.0 (unscaled donor colours), so with the flag
	# off — or with no composer parent to read from — behaviour is unchanged.
	# COLOR-UNIFY is INDEPENDENT: its gain already encodes the missing fraction
	# of that same rig lift measured from neutral, so when it is active the rig
	# energies stay at 1.0 (no stacking, no second full lift). light_match stats
	# still report the rig's own values and decision unchanged.
	var rig_energies: Dictionary = _composer_light_energies() if (light_match or color_unify) else {}
	var rig_ambient: float = float(rig_energies.get("ambient_energy", 1.0))
	var rig_sun: float = float(rig_energies.get("sun_energy", 1.0))
	var cu := _color_unify_calibration()
	var cu_gain: Vector3 = cu.get("gain_vector", Vector3.ONE)
	cu.erase("gain_vector")   # keep stats JSON-safe; the Vector3 is bound only
	var apply_full_rig: bool = light_match and not color_unify
	var ambient_energy: float = rig_ambient if apply_full_rig else 1.0
	var sun_energy: float = rig_sun if apply_full_rig else 1.0
	_light_match = {
		"feature": LIGHT_MATCH_FLAG_PATH,
		"enabled": light_match,
		"rig_found": not rig_energies.is_empty(),
		"ambient_energy_bound": ambient_energy,
		"sun_energy_bound": sun_energy,
		"rig_ambient_energy": rig_ambient,
		"rig_sun_energy": rig_sun,
		"suppressed_by_color_unify": (light_match and color_unify),
		"source": str(rig_energies.get("source", "NONE — neutral 1.0 shader defaults")),
		"label": ("PORT CONSISTENCY CALIBRATION — shared scene light rig; "
			+ "NO donor parity claim, no new donor constant, no gamma/exposure lift"),
	}
	_color_unify = cu
	_color_unify["enabled"] = color_unify
	_color_unify["active"] = color_unify
	_color_unify["wins_over_light_match"] = (light_match and color_unify)
	_color_unify["rig_energies_left_neutral"] = color_unify
	_color_unify["bound_gain"] = ([cu_gain.x, cu_gain.y, cu_gain.z]
		if color_unify else [1.0, 1.0, 1.0])
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
		# LIGHT-MATCH: SAME rig energies scene props already receive; 1.0 when off.
		"light_rig_ambient_energy": ambient_energy,
		"light_rig_sun_energy": sun_energy,
		# COLOR-UNIFY: calibrated per-channel fraction of the measured rig lift;
		# vec3(1) when off (byte-identical), neutral rig energies when on.
		"color_unify_gain": cu_gain if color_unify else Vector3.ONE,
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
			"hires_diagnostic": _atlas_resolution.duplicate(true),
			"partial_array_diagnostic": _array_atlas.duplicate(true),
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
		"light_match": _light_match.duplicate(true),
		"color_unify": _color_unify.duplicate(true),
		"array_atlas": _array_atlas.duplicate(true),
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
			"light_match": ("PORT CONSISTENCY only — shared rig AMBIENT_ENERGY/SUN_ENERGY "
				+ "(terrain_donor_world.gd:69-70); opt-in features.terrain.light_match; "
				+ "NOT donor parity"),
			"color_unify": ("PORT CALIBRATION only — per-channel fraction of the MEASURED "
				+ "full-rig lift (PHOTO_LED §1 halo/grass; HANDOFF §9.15 overshoot; "
				+ "PHOTO_LED §2 donor-direction b); opt-in features.terrain.color_unify; "
				+ "NOT donor parity, no gamma/exposure lift"),
			"partial_array": ("OPT-IN features.terrain.array_atlas; AUDIT-ATLAS-RES §2/§5/§6 "
				+ "options B/D. 1024^2 donor-derived block PNGs from assets/terrain/blocks/, "
				+ "id -> compact slot remap, one 128 px subcell per used id. "
				+ "PORT APPROXIMATION, NO donor parity claim"),
		},
	}


# ---------------------------------------------------------------------------
# Build: ONE indexed ArrayMesh, ONE surface, ONE draw call.
# ---------------------------------------------------------------------------
func build() -> bool:
	invalidate()
	# HIRES-ATLAS-C: resolve the opt-in once, before any path/sampler binding,
	# so _atlas_paths(), stats and the loader all see the same tier this build.
	hires_atlas = _resolve_hires_atlas_flag()
	# TERRAINRES: resolve the partial-tier opt-in once per build so the tile
	# map, atlas binding, loader path and stats all see the same decision.
	array_atlas = _resolve_array_atlas_flag()
	# LIGHT-MATCH: likewise resolve the opt-in once per build so the material
	# binding and the stats block see the same decision.
	light_match = _resolve_light_match_flag()
	# COLOR-UNIFY: likewise resolved once per build; independent of light_match.
	color_unify = _resolve_color_unify_flag()
	if not _ingest():
		push_error("terrain_donor_mesh: bind() an I06 container / height dump first")
		return false
	_mip_source = ""
	# TERRAINRES: build the compact full-res tier BEFORE the tile map so the
	# id -> slot remap is available when the L8 image is packed. A failure is
	# labelled and silently leaves the commit-default terrain_new tier intact.
	if array_atlas:
		_build_partial_array_atlas()
	_tile_map_tex = _build_tile_map_texture()
	if not _array_atlas.is_empty():
		_array_atlas["unmapped_cells"] = _unmapped_cells
	var tile_map_ok: bool = _tile_map_tex != null
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
				face = _face_mode_at(_height, _w, _h, x, z, _collision)
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
	_collision = PackedByteArray()
	_alpha_tex = null
	_alphavert_tex = null
	_atlas_grid = Vector2.ZERO
	_atlas_info = {}
	_atlas_resolution = {}
	_array_atlas = {}
	_id_to_slot = {}
	_slot_to_id = {}
	_compact_atlas_texture = null
	_compact_grid = Vector2.ZERO
	_unmapped_cells = 0
	_shader_params = {}
	_light_match = {}
	light_match = false
	_color_unify = {}
	color_unify = false
	array_atlas = false
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
