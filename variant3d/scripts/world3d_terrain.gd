extends Node3D

# V7-13 — full-grid heightmap terrain for the 3D variant.
#
# PORT OF (read-only reference, NOT edited): app/scripts/heightmap_world3d.gd
# (G3-2 full-grid mesh proof). Loaded dynamically via load() — no class_name:
# a fresh global class is not in .godot's cache until an editor import, and all
# Godot launches go through variant3d/tools/godot_runner.py.
#
# DESIGN (owner directive: leverage the heightmap concept, no chunk reasoning):
#   * ONE indexed ArrayMesh, ONE surface, ONE draw call for the whole grid;
#   * one shared vertex per height[] cell (no per-tile quads, no step walls);
#   * central-difference normals from the height field itself (one-sided edges);
#   * UV = ((x+0.5)/map_w, (z+0.5)/map_h) — 0..1 over the full map, aligned to
#     the G3-4 splat albedo cell centres (row-major, north/west origin);
#   * V7-92: UV2.x = donor tile index (game.tileblock uint8), UV2.y = face mode
#     (FIX-TERRAIN: 0 ground / 1 front / 2 side from donor cDiff1/cDiff2 slope
#     + aspect axis; PORT APPROXIMATION — NOT DONOR PARITY, see _face_mode_at);
#   * V7-92: V7-86 tile-index ShaderMaterial bound to the V7-91 multi-mode atlas
#     loader (single/split/array), with V7-82 splat kept as an explicit
#     PORT APPROXIMATION — NOT DONOR PARITY fallback;
#   * V7-92: V7-84 donor water module with bind_height_grid(); the old constant
#     water quad is retained only as a fallback if that module cannot build.
# NO per-chunk dictionaries, NO 2-chunk/frame cap, NO imported sprite sheets,
# NO RNG. V7-13 deliberately left lighting to V7-9; V7-60 now ports the
# donor-cited WorldEnvironment + DirectionalLight3D rig from the UNWIRED
# variant3d/scripts/heightmap_world3d.gd:114-147 so the WIRED runtime terrain
# is actually lit. All rig values stay donor-cited; none are invented here.
#
# V7-92 INTEGRATION (all three landed pieces wired here, no other file edited):
#   * V7-85 / TERRAIN2-06 A1: donor-indexed 124-cell atlas + two converted masks
#     (docs/coord_swarm_2026-11-24/reports/V785_tile_atlas.md).
#   * V7-86 / TERRAIN2-06 A2: terrain_tileindex.gdshader. Its INTEGRATION
#     CONTRACT (V786_tileindex_shader.md §3) is followed exactly: UV2.x carries
#     the donor `.tex` id, UV2.y the face mode; `atlas_grid` comes from the
#     V7-85 manifest (16x8), never a donor default; the three samplers are bound
#     with donor intensity in ALPHA; `shadow_enabled=0` (no shadow map shipped);
#     NO second cull setting (the shader already declares
#     `render_mode blend_mix, unshaded, cull_disabled`, :37).
#   * V7-91: tile_atlas_loader.gd multi-mode transport (coordinator update:
#     "single" is now the DEFAULT — the original 180 MB PNG was restored;
#     "split" and "array" remain selectable). The loader auto-falls back
#     single -> split -> array with a warning when the single PNG is absent
#     (fresh clones observe GitHub's 100 MB/file limit); this module simply
#     uses the loader's default and surfaces its CHOSEN mode in stats as
#     `stats["atlas_mode"]`. Both split and array were runtime-verified 28/28
#     by V7-91 job 245 (`v791-dual-mode`). `set_atlas_mode` selects
#     "single"/"split"/"array" publicly; the V7-86 shader is sampler2D-only, so
#     when the chosen transport exposes no 2D atlas (array) the selected loader
#     is still loaded and its index→slot map exposed in stats, while a dedicated
#     SECOND split loader supplies the single 2D atlas sampler the shader
#     requires. This is an explicit PORT LIMITATION, not a donor claim.
#   * V7-84: water3d.gd + water3d.gdshader, built at the decoded grid size and
#     fed the live height[] via bind_height_grid(). All donor literals
#     (-0.25 / -0.1 / 2.96) and UNVERIFIED labels from V784 remain in force.
#
# NO VISUAL / DONOR PARITY CLAIM: no GPU A/B was run by this agent. Every visual
# effect remains a prediction from static donor text (TERRAIN2-06 §6).

# Donor citations (read-only text; singleplayer skirmish path):
#   C:\Games\Cossacks 3\data\scripts\generatemap.inc:537-577 — bitmap -> engine
#     height grid -> smoothing; the height[] source this mesh visualises
#     (G31 report docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md:73,:230).
#   data\cameras\camera.cfg:32-35 (tilt -32), :44-45 (focal 400) — camera framing
#     is V7-5's camera3d.gd, NOT this terrain module; no camera constant copied.
#   variant3d/scripts/mapgen.gd:29 — C3MapGen.WATER_DEEP = -0.25 (port comment
#     cites donor data\scripts\texturemap.inc:30; donor literal UNVERIFIED).
#   variant3d/scripts/data.gd:23 — C3Data.TILE_M = 2.0 (donor cell size in
#     metres is UNVERIFIED; G32 report §3).
#   variant3d/scripts/main.gd:694-701 — dump schema (map_w/map_h/height base64).
#   variant3d/scripts/game.gd:44,1893-1907 — live height[] grid + bilinear read.
#   variant3d/scripts/game.gd:5564 — height[] -> base64 on save/dump.
#   TERRAIN2-06:29-31 (E01/E02) — game.gd:53 `tileblock: PackedByteArray`,
#     game.gd:1610-1689 `_assign_tileblocks()`, main.gd:741 dumps it base64;
#     dmscript.global:2026-2035 `TMapTerrainDataTile{height,tex,collision[4]}`.
#     VERIFIED live in this agent: game.gd:53/1621 sizes tileblock to
#     MAP_W*MAP_H (320² = 102,400 bytes); world3d.gd:185-202 (2D 3D sibling)
#     decodes `dump["tileblock"]` as uint8 per cell; world.gd:258-261 iterates
#     the live `game.tileblock`. One uint8 per cell, NOT four sub-tile indices.

# V7-60 light/sky rig — translated (not invented) from the UNWIRED sibling
# variant3d/scripts/heightmap_world3d.gd:22-37,114-147. Donor references
# (read-only text, singleplayer skirmish path):
#   C:\Games\Cossacks 3\data\shaders\water\water.dev.vert:22 builds
#     lightVector = (LightPos.x/4, LightPos.z/2, LightPos.y)  [donor Z-up]
#   C:\Games\Cossacks 3\data\env\lights\light.cfg:26-29 Position =
#     (-0.344731152057648, 0.938701450824738, 0)
#   -> donor lightVector = (-0.0861828, 0, 0.9387015) Z-up
#   -> Godot Y-up        = (-0.0861828, 0.9387015, 0)
# Donor light colours are literal light.cfg:3-16 Ambient/Diffuse; the ENERGIES
# below are port-side M0.6 compensation, not donor values.

const TILE_M: float = 2.0                 # data.gd:23; donor cell size UNVERIFIED
const HEIGHT_SCALE: float = 1.0           # dump height[] is already metres (main.gd:698)
const WATER_LEVEL: float = -0.25          # mapgen.gd:29 C3MapGen.WATER_DEEP; donor literal UNVERIFIED

# V7-60 donor light rig constants (verbatim values + citations from
# heightmap_world3d.gd:34-37); only the two light.cfg colours are recorded as
# donor evidence, the rig itself uses the same body as the sibling module.
const SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)  # light.cfg:26-29
const SUN_LIGHTVEC := Vector3(SUN_POS.x / 4.0, SUN_POS.z / 2.0, SUN_POS.y)  # water.dev.vert:22, then Z-up->Y-up
const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-8 (donor evidence)
const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)  # light.cfg:11-16 (donor evidence)
# Port-side M0.6 art compensation (NOT donor values) — kept as cited in the rig.
const EXPOSURE: float = 1.45
const AMBIENT_ENERGY: float = 1.10
const SUN_ENERGY: float = 1.7

# FIX-TERRAIN — donor cliff/aspect thresholds, VERBATIM literals:
#   data/scripts/common.inc/texturemap.inc:63  cDiff1 = 0.5
#   data/scripts/common.inc/texturemap.inc:64  cDiff2 = 0.55
# Donor uses them on 4-neighbour height deltas (:76-79, :88-129) to tag steep
# cells, then quantises the gradient into 8 sectors (:438-447, :559-575) to pick
# rockN / rockNvf / rockNvs. The port's EXACT base-tile -> vf/vs promotion rule
# is UNVERIFIED (TERRAIN2-01 §6 #3), so these are used ONLY to set UV2.y face
# mode — never to invent a tile index. See _face_mode_at().
const DONOR_CDIFF1: float = 0.5   # texturemap.inc:63
const DONOR_CDIFF2: float = 0.55  # texturemap.inc:64

const SPLAT_PATH := "res://assets/terrain/heightmap/splat_albedo.png"
const FALLBACK_BLOCK := "res://assets/terrain/blocks/grass1.png"

# V7-92 module paths. Dynamic load() keeps the no-class_name cache rule above.
const TILE_ATLAS_LOADER_PATH := "res://scripts/tile_atlas_loader.gd"
const WATER3D_PATH := "res://scripts/water3d.gd"
const TILEINDEX_SHADER_PATH := "res://shaders/terrain_tileindex.gdshader"
const V785_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas.manifest.json"
const ATLAS_MODE_SINGLE := "single"  # coordinator update: DEFAULT (original PNG restored)
const ATLAS_MODE_SPLIT := "split"    # lossless byte parts -> user:// cache
const ATLAS_MODE_ARRAY := "array"    # 121-layer Texture2DArray

# PORT-TUNED art floor (not a donor value): a tiny emission keeps the terrain
# legible in a standalone no-light probe. V7-60 leaves this value UNCHANGED —
# the donor-grounded light/sky rig lives in this module (see _make_environment).
# NOTE: only used by the V7-82 splat fallback material; the V7-86 shader is
# `unshaded` and reproduces the donor's final colour itself.
const EMISSION_RGB := Color(0.06, 0.06, 0.05)

var stats: Dictionary = {}

var _game = null   # untyped: real C3Game object OR a dictionary test double
var _height := PackedFloat32Array()
var _w: int = 0
var _h: int = 0
var _built: bool = false

# V7-92 state.
var atlas_mode: String = ATLAS_MODE_SINGLE  # public: "single" (default) | "split" | "array"
var _atlas_loader = null                    # TileAtlasLoader in the selected mode
var _shader_atlas_loader = null             # split-only loader for shader sampler2D
var _atlas_texture: Texture2D = null
var _alpha_tex: Texture2D = null            # donor intensity repacked into ALPHA
var _alphavert_tex: Texture2D = null        # donor intensity repacked into ALPHA
var _atlas_grid := Vector2.ZERO             # (cols, rows) from V7-85 manifest
var _atlas_info: Dictionary = {}
var _atlas_mode_loaded: String = ""
var _manifest: Dictionary = {}
var _tile_indices := PackedByteArray()
var _tile_index_source: String = ""
var _tile_index_hist: Dictionary = {}
var _tile_index_out_of_atlas: int = 0
var _face_hist: Dictionary = {}             # FIX-TERRAIN: face-mode cell counts
var _water3d = null                         # V7-84 water3d.gd instance


func bind(game) -> void:
	_game = game


# ---------------------------------------------------------------------------
# V7-92 — public atlas-mode selection (coordinator update).
#   "single" (DEFAULT) : the restored single 16384x8192 PNG; loader auto-falls
#                        back to "split" then "array" when absent (fresh clones).
#   "split"            : V7-91 lossless split parts reassembled into user:// cache.
#   "array"            : V7-91 Texture2DArray, 121 layers, donor index→slot map.
# Split and array were runtime-verified 28/28 by V7-91 job 245 (`v791-dual-mode`).
# Unknown values normalize to "single". The loader decides the mode it actually
# uses; it is surfaced in stats["atlas_mode"] / stats["atlas"]["loaded_mode"].
# If already built and bound, the terrain is rebuilt to apply the new transport.
# ---------------------------------------------------------------------------
func set_atlas_mode(mode: String) -> void:
	var m := mode.strip_edges().to_lower()
	if m != ATLAS_MODE_SINGLE and m != ATLAS_MODE_SPLIT and m != ATLAS_MODE_ARRAY:
		m = ATLAS_MODE_SINGLE
	if m == atlas_mode and _atlas_loader != null:
		return
	atlas_mode = m
	if _atlas_loader != null:
		_atlas_loader.set_mode(m)
	if _built and _game != null:
		build()


# Python-written splat PNG has no Godot .import sidecar in a --script run:
# load("res://...png") => "No loader found for resource" (G32 ticket 1322).
# Runtime Image.load of the globalized path needs no import step.
func _load_png_texture(res_path: String) -> Texture2D:
	var abs_path := ProjectSettings.globalize_path(res_path)
	if not FileAccess.file_exists(abs_path):
		return null
	var img := Image.new()
	if img.load(abs_path) != OK or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)


func _read_json(res_path: String) -> Dictionary:
	var abs_path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


# ---------------------------------------------------------------------------
# V7-92 — V7-91 loader + V7-86 material bindings.
# ---------------------------------------------------------------------------
func _load_atlas() -> bool:
	_atlas_texture = null
	_alpha_tex = null
	_alphavert_tex = null
	_atlas_grid = Vector2.ZERO
	_atlas_info = {}
	_atlas_mode_loaded = ""
	_manifest = _read_json(V785_MANIFEST_PATH)
	var loader_script := load(TILE_ATLAS_LOADER_PATH) as Script
	if loader_script == null or not loader_script.can_instantiate():
		push_error("world3d_terrain: cannot load " + TILE_ATLAS_LOADER_PATH)
		return false

	# Instantiate the loader in the requested mode (default "single"). V7-91's
	# loader owns auto-fallback single -> split -> array with a warning; this
	# module never second-guesses that choice, it only reports it in stats.
	_atlas_loader = loader_script.new(atlas_mode)
	if _atlas_loader == null:
		return false
	if not bool(_atlas_loader.call("load")):
		push_error("world3d_terrain: atlas load(%s) failed: %s" % [
			atlas_mode, str(_atlas_loader.call("get_last_error"))])
		return false
	# V7-91 coordinator update exposes `current_mode` (the mode actually chosen
	# after fallback); older loaders only have get_mode(). Read defensively.
	var chosen: Variant = _atlas_loader.get("current_mode")
	if chosen == null or str(chosen).is_empty():
		chosen = _atlas_loader.call("get_mode")
	_atlas_mode_loaded = str(chosen)
	_atlas_grid = _atlas_loader.call("atlas_grid")   # from V7-85 manifest, NO donor default
	_atlas_info = _atlas_loader.call("get_reassembly_info")

	var masks: Array = _atlas_loader.call("get_mask_textures")
	if masks.size() < 2:
		push_error("world3d_terrain: V7-91 loader returned fewer than 2 masks")
		return false
	# V7-85 PNGs are single-channel grayscale (IHDR colour type 0: alpha.png
	# 512x256, alphavert.png 1024x512). V7-86 §3.2 reads donor intensity from
	# `.a`, so repack R->A here rather than inventing a new asset.
	_alpha_tex = _repack_mask_alpha(masks[0])
	_alphavert_tex = _repack_mask_alpha(masks[1])
	if _alpha_tex == null or _alphavert_tex == null:
		push_error("world3d_terrain: mask alpha repack failed")
		return false

	# "single" and "split" both expose a 16384x8192 2D atlas sampler. An array
	# transport (or any fallback that yields no 2D texture) needs a dedicated
	# split loader for the V7-86 `uniform sampler2D tile_atlas` (:54) — PORT
	# LIMITATION only; no shader edit is in this agent's ownership.
	_atlas_texture = _atlas_loader.call("get_atlas_texture")
	if _atlas_texture == null:
		_shader_atlas_loader = loader_script.new(ATLAS_MODE_SPLIT)
		if _shader_atlas_loader == null or not bool(_shader_atlas_loader.call("load")):
			push_error("world3d_terrain: split fallback for sampler2D failed")
			return false
		_atlas_texture = _shader_atlas_loader.call("get_atlas_texture")
	if _atlas_texture == null:
		push_error("world3d_terrain: no 2D atlas texture for tile_atlas sampler")
		return false
	return true


func _repack_mask_alpha(src: Texture2D) -> Texture2D:
	if src == null or not (src is ImageTexture):
		return null
	var img: Image = (src as ImageTexture).get_image()
	if img == null or img.is_empty():
		return null
	img.convert(Image.FORMAT_RGBA8)
	var w: int = img.get_width()
	var h: int = img.get_height()
	for y in range(h):
		for x in range(w):
			var v: float = img.get_pixel(x, y).r   # donor tiaAlphaFromIntensity
			img.set_pixel(x, y, Color(v, v, v, v)) # alpha = intensity for V7-86 `.a`
	return ImageTexture.create_from_image(img)


# V7-86 INTEGRATION CONTRACT (V786_tileindex_shader.md §3.2/§3.3):
# atlas_grid from V7-85 manifest; three samplers with alpha-channel masks;
# shadow_enabled=0 (no shadow map shipped); NO second cull setting because the
# shader already declares `blend_mix, unshaded, cull_disabled` (:37).
func _tileindex_material() -> Material:
	var shader := load(TILEINDEX_SHADER_PATH) as Shader
	if shader == null:
		push_error("world3d_terrain: cannot load " + TILEINDEX_SHADER_PATH)
		return null
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("tile_atlas", _atlas_texture)
	mat.set_shader_parameter("alpha_atlas", _alpha_tex)
	mat.set_shader_parameter("alphavert_atlas", _alphavert_tex)
	mat.set_shader_parameter("atlas_grid", _atlas_grid)
	# No real shadow map is supplied; keep the shader default OFF.
	mat.set_shader_parameter("shadow_enabled", 0.0)
	# FIX-TERRAIN — MEASURED, DELIBERATELY NOT CHANGED.
	# The donor bmTransparency mask is re-applied as Godot framebuffer ALPHA
	# (V7-86). This is structurally wrong (no second base-tile pass in the port)
	# but an OpenGL A/B proved that REMOVING it makes the terrain DARKER, not
	# brighter: the port sky behind the semi-transparent ground is brighter
	# than the dark donor tile art. fixterrain_ab_before/after: luma 42.735 ->
	# 38.425. The shader exposes `mask_to_alpha` (default 1.0 = V7-86) so the
	# experiment is reproducible; this module leaves it at the shipped value.
	# Deliberately NO cull_mode / transparency here: the shader owns both.
	return mat


func _terrain_material(splat: Texture2D) -> Material:
	var mat := StandardMaterial3D.new()
	if splat != null:
		mat.albedo_texture = splat
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR  # V7-82: 4x splat texels stay smooth, no mip chain in tool PNG
	# Splat A is normalised height DATA (G3-4), not opacity: never blend it.
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.vertex_color_use_as_albedo = false
	# Continuous heightfield, no underside; cull disabled so winding conventions
	# cannot hide a face (same guard as the G3-2 proof).
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission_enabled = true
	mat.emission = EMISSION_RGB
	mat.emission_energy_multiplier = 1.0
	return mat


# FIX-TERRAIN — UV2.y face mode from DONOR-READABLE slope data.
# PORT APPROXIMATION — NOT DONOR PARITY.
#   Steep test  : donor texturemap.inc:63-64,76-79,88-129 (cDiff1=0.5 on the
#                 4 axis neighbours, cDiff2=0.55 on the 2 diagonals).
#   Aspect axis: donor texturemap.inc:438-447 (dirX=lh-rh, dirY=th-bh) and
#                 :559-575 (dominant sector picks rockN / rockNvf / rockNvs).
#   Face planes: donor reftile.mat:130-141 verticalfront S=X,T=Z(height)
#                 -> Godot front mode 1; reftile.mat:156-167 verticalside
#                 S=Y(donor),T=Z(height) -> Godot side mode 2.
# The donor's exact rule that PROMOTES a base tile to its vf/vs variant is
# ENGINE/UNVERIFIED (TERRAIN2-01 §6 #3). This therefore changes ONLY the face
# mode (which second sampler + eye-linear projection the shader uses); it never
# changes UV2.x or fabricates a tile index. Flat cells stay mode 0.
func _face_mode_at(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> int:
	var i: int = z * w + x
	var c: float = height[i]
	var lh: float = height[z * w + maxi(0, x - 1)]
	var rh: float = height[z * w + mini(w - 1, x + 1)]
	var th: float = height[maxi(0, z - 1) * w + x]
	var bh: float = height[mini(h - 1, z + 1) * w + x]
	var steep: bool = (absf(c - lh) > DONOR_CDIFF1
		or absf(c - rh) > DONOR_CDIFF1
		or absf(c - th) > DONOR_CDIFF1
		or absf(c - bh) > DONOR_CDIFF1)
	if not steep:
		# Donor's diagonal collision test (texturemap.inc:116-129, cDiff2).
		var rb: float = height[mini(h - 1, z + 1) * w + mini(w - 1, x + 1)]
		steep = (absf(bh - rh) > DONOR_CDIFF2
			or absf(c - rb) > DONOR_CDIFF2)
	if not steep:
		return 0
	# Dominant donor gradient axis decides front (mode 1) vs side (mode 2).
	var gx: float = lh - rh   # donor X -> Godot X
	var gy: float = th - bh   # donor Y -> Godot Z
	return 1 if absf(gy) >= absf(gx) else 2


# Central difference over 2*TILE_M; one-sided at the grid borders. Donor
# height[] is stepped, so a large dh across one cell gives a steep normal
# without a separate wall mesh. Port analogue of donor hf.pvl.sm.vert normal
# transform (shaders.lib:16-19), not a donor copy.
func _normal_at(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> Vector3:
	var x0: int = maxi(0, x - 1)
	var x1: int = mini(w - 1, x + 1)
	var z0: int = maxi(0, z - 1)
	var z1: int = mini(h - 1, z + 1)
	var dx: float = float(x1 - x0) * TILE_M
	var dz: float = float(z1 - z0) * TILE_M
	var dhdx: float = (height[z * w + x1] - height[z * w + x0]) / dx
	var dhdz: float = (height[z1 * w + x] - height[z0 * w + x]) / dz
	return Vector3(-dhdx, 1.0, -dhdz).normalized()


# Resolve the bound game into the dump schema of main.gd:694-701. An explicit
# dump dictionary on the game wins; otherwise the live game.height[] grid is
# encoded with the SAME Marshalls recipe as game.gd:5564 so build() always
# decodes a base64 height[] grid, exactly like the G3-2 donor reference.
# V7-92: the synthesized dump also carries base64(game.tileblock) so the live
# donor index buffer is visible to build() (TERRAIN2-06:72, V786 §3.3 step 2).
func _dump_from_game() -> Dictionary:
	if _game == null:
		return {}
	for key in ["dump", "map_dump", "self_base"]:
		var cand = _game.get(key)
		if cand is Dictionary and (cand as Dictionary).has("height"):
			return cand
	var src = _game.get("height")
	if not (src is PackedFloat32Array):
		return {}
	var gw: int = 0
	var gh: int = 0
	var v = _game.get("MAP_W")
	if v is int:
		gw = int(v)
	if gw <= 0:
		v = _game.get("map_w")
		if v is int:
			gw = int(v)
	v = _game.get("MAP_H")
	if v is int:
		gh = int(v)
	if gh <= 0:
		v = _game.get("map_h")
		if v is int:
			gh = int(v)
	var grid: PackedFloat32Array = src
	if gw <= 0 or gh <= 0 or grid.size() < gw * gh:
		return {}
	var result := {
		"map_w": gw,
		"map_h": gh,
		"height": Marshalls.raw_to_base64(grid.to_byte_array()),
	}
	var tb: Variant = _game.get("tileblock")
	if tb is PackedByteArray and (tb as PackedByteArray).size() >= gw * gh:
		result["tileblock"] = Marshalls.raw_to_base64(tb as PackedByteArray)
	return result


# V7-92 — decode the ONE uint8 per cell written by game.gd:1621-1689 and dumped
# at main.gd:741. Accepts base64 in a dump dictionary OR a live PackedByteArray.
# The 2D 3D sibling app/scripts/world3d.gd:185-202 decodes the same byte source.
func _decode_tile_indices(dump: Dictionary, w: int, h: int) -> void:
	_tile_indices = PackedByteArray()
	_tile_index_source = ""
	var want: int = w * h
	var tbv: Variant = dump.get("tileblock", null)
	if tbv is PackedByteArray:
		var live: PackedByteArray = tbv
		if live.size() >= want:
			_tile_indices.resize(want)
			for i in range(want):
				_tile_indices[i] = live[i]
			_tile_index_source = "dump.tileblock PackedByteArray (main.gd:725)"
	elif tbv is String and not str(tbv).is_empty():
		var raw := Marshalls.base64_to_raw(str(tbv))
		if raw.size() >= want:
			_tile_indices.resize(want)
			for i in range(want):
				_tile_indices[i] = raw[i]
			_tile_index_source = "dump.tileblock base64 (main.gd:741)"
	if _tile_indices.is_empty() and _game != null:
		var live_v: Variant = _game.get("tileblock")
		if live_v is PackedByteArray and (live_v as PackedByteArray).size() >= want:
			var live2: PackedByteArray = live_v
			_tile_indices.resize(want)
			for i in range(want):
				_tile_indices[i] = live2[i]
			_tile_index_source = "live game.tileblock PackedByteArray (game.gd:53,1610-1689)"
	if _tile_indices.is_empty():
		_tile_index_source = ("PORT APPROXIMATION — NOT DONOR PARITY: "
			+ "no tileblock in dump or game; V7-82 splat fallback retained")
		return
	_tile_index_hist = {}
	_tile_index_out_of_atlas = 0
	for i in range(want):
		var tid: int = int(_tile_indices[i])
		_tile_index_hist[str(tid)] = int(_tile_index_hist.get(str(tid), 0)) + 1
		if tid >= int(_manifest.get("atlas", {}).get("named_cells", 124)):
			_tile_index_out_of_atlas += 1


# Keep the original constant water quad only as a fallback. The V7-84 module
# replaces it in the normal path; never submit both surfaces at once.
func _make_water(w: int, h: int) -> void:
	var half_x: float = float(w) * TILE_M * 0.5
	var half_z: float = float(h) * TILE_M * 0.5
	var v := PackedVector3Array([
		Vector3(-half_x, WATER_LEVEL, -half_z),
		Vector3(half_x, WATER_LEVEL, -half_z),
		Vector3(half_x, WATER_LEVEL, half_z),
		Vector3(-half_x, WATER_LEVEL, half_z)])
	var uv := PackedVector2Array([
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	var ind := PackedInt32Array([0, 3, 1, 1, 3, 2])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_INDEX] = ind
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.19, 0.245, 0.255, 0.45)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 0.35
	var mi := MeshInstance3D.new()
	mi.name = "WaterPlane"
	mi.mesh = mesh
	mi.material_override = mat
	add_child(mi)


# V7-92 — V7-84 water3d.gd integration hook (V784 §5):
#   build(w, h) with the decoded dump dims, then bind_height_grid(height, w, h).
# The module is built BEFORE add_child so its _ready() does not auto-build a
# default 320² grid. The internal plane is renamed "WaterPlane" to keep the
# terrain3d_sandbox.gd:122 seam-mask hook working; only ONE water plane exists.
func _make_water3d(w: int, h: int, height: PackedFloat32Array) -> bool:
	var script := load(WATER3D_PATH) as Script
	if script == null or not script.can_instantiate():
		push_error("world3d_terrain: cannot load " + WATER3D_PATH)
		return false
	var node: Node = script.new()
	if node == null or not bool(node.call("build", w, h)):
		if node != null:
			node.free()
		return false
	bool(node.call("bind_height_grid", height, w, h))
	node.name = "Water3D"
	add_child(node)
	var plane := node.get_node_or_null("WaterPlane3D")
	if plane != null:
		plane.name = "WaterPlane"
	_water3d = node
	return true


# V7-60 — donor-grounded sky/sun rig translated VERBATIM from the unwired
# variant3d/scripts/heightmap_world3d.gd:114-147. Values/citations: light.cfg:3-16
# (ambient/diffuse), light.cfg:26-29 (sun position), water.dev.vert:22 (light
# vector transform). Port-side energies stay flagged as M0.6 compensation.
# invalidate() frees these children too, so a rebuild cannot stack rigs.
func _make_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.background_color = Color(0.62, 0.70, 0.66)
	var sky := Sky.new()
	var skymat := ProceduralSkyMaterial.new()
	skymat.sky_top_color = Color(0.18, 0.30, 0.42)
	skymat.sky_horizon_color = Color(0.36, 0.44, 0.38)
	skymat.sky_curve = 0.18
	skymat.ground_bottom_color = Color(0.09, 0.12, 0.07)
	skymat.ground_horizon_color = Color(0.17, 0.22, 0.14)
	skymat.ground_curve = 0.10
	sky.sky_material = skymat
	env.sky = sky
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = EXPOSURE
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.86, 0.88, 0.82)
	env.ambient_light_energy = AMBIENT_ENERGY
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "DonorSun"
	sun.light_energy = SUN_ENERGY
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 400.0
	# The donor sun is almost overhead, so look_at with up=+Y is degenerate;
	# use +Z as the up axis exactly as M0.6 did.
	sun.look_at_from_position(SUN_LIGHTVEC.normalized() * 120.0,
		Vector3.ZERO, Vector3.FORWARD)
	add_child(sun)


# Drop every object created by the last build so a rebuild cannot stack meshes.
func invalidate() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	_height = PackedFloat32Array()
	_w = 0
	_h = 0
	_built = false
	stats = {}
	_atlas_loader = null
	_shader_atlas_loader = null
	_atlas_texture = null
	_alpha_tex = null
	_alphavert_tex = null
	_atlas_grid = Vector2.ZERO
	_atlas_info = {}
	_atlas_mode_loaded = ""
	_manifest = {}
	_tile_indices = PackedByteArray()
	_tile_index_source = ""
	_tile_index_hist = {}
	_tile_index_out_of_atlas = 0
	_face_hist = {}
	_water3d = null


# EXACT CONTRACT: one full-grid ArrayMesh from the base64 dump height[] grid.
func build() -> bool:
	var t_total := Time.get_ticks_usec()
	invalidate()
	var dump := _dump_from_game()
	if dump.is_empty():
		push_error("world3d_terrain: bind(game) with a height dump first")
		return false
	var w := int(dump.get("map_w", 0))
	var h := int(dump.get("map_h", 0))
	var raw := Marshalls.base64_to_raw(str(dump.get("height", "")))
	if w <= 0 or h <= 0 or raw.size() < w * h * 4:
		push_error("world3d_terrain: bad dump dimensions / height grid")
		return false
	var t_parsed := Time.get_ticks_usec()

	var height := PackedFloat32Array()
	height.resize(w * h)
	var hmin: float = INF
	var hmax: float = -INF
	for i in range(w * h):
		var y: float = raw.decode_float(i * 4)
		height[i] = y
		hmin = minf(hmin, y)
		hmax = maxf(hmax, y)
	var t_heights := Time.get_ticks_usec()

	# V7-92: decode donor tile indices and load the selected atlas transport.
	_decode_tile_indices(dump, w, h)
	var atlas_ready := _load_atlas()
	var tiles_available: bool = not _tile_indices.is_empty()

	# Splat stays loaded for the V7-82 fallback path and for stats provenance.
	var splat_path := SPLAT_PATH
	var splat := _load_png_texture(splat_path)
	if splat == null:
		splat = _load_png_texture(FALLBACK_BLOCK)
		splat_path = FALLBACK_BLOCK
	if splat == null:
		splat_path = "NONE (plain material)"

	# ONE vertex per height cell (cell centres), so splat texel (x,z) maps to
	# UV ((x+0.5)/w, (z+0.5)/h). Two triangles per interior cell square.
	var nverts: int = w * h
	var ntris: int = (w - 1) * (h - 1) * 2
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var uvs := PackedVector2Array()
	var uvs2 := PackedVector2Array()
	verts.resize(nverts)
	norms.resize(nverts)
	uvs.resize(nverts)
	uvs2.resize(nverts)
	var inds := PackedInt32Array()
	inds.resize(ntris * 3)
	var cx: float = float(w) * 0.5
	var cz: float = float(h) * 0.5
	var max_tile_id: int = int(_manifest.get("atlas", {}).get("named_cells", 124)) - 1
	_face_hist = {"0": nverts}
	for z in range(h):
		for x in range(w):
			var i: int = z * w + x
			verts[i] = Vector3((float(x) + 0.5 - cx) * TILE_M,
				height[i] * HEIGHT_SCALE,
				(float(z) + 0.5 - cz) * TILE_M)
			norms[i] = _normal_at(height, w, h, x, z)
			uvs[i] = Vector2((float(x) + 0.5) / float(w),
				(float(z) + 0.5) / float(h))
			# V7-86 CONTRACT: UV2.x = float(donor tile id), UV2.y = face mode.
			# FIX-TERRAIN: UV2.y is now derived from donor-readable slope data
			# (_face_mode_at, texturemap.inc:63-64/438-447/559-575). 0 = ground
			# default (reftile.mat:1-108), 1 = verticalfront, 2 = verticalside.
			# This is a PORT APPROXIMATION — NOT DONOR PARITY: vf/vs promotion
			# is ENGINE/UNVERIFIED, so no tile id is altered here.
			# PORT GUARD: the live game uses 255 = BLK_WATER (game.gd:52) and
			# other out-of-atlas ids; clamp to the V7-85 named-cell range so the
			# shader never samples an empty/overflow cell. Counted in stats.
			var tid: int = int(_tile_indices[i]) if tiles_available else 0
			if tid < 0 or tid > max_tile_id:
				tid = 0
			var face: int = _face_mode_at(height, w, h, x, z)
			if face != 0:
				var fk: String = str(face)
				_face_hist[fk] = int(_face_hist.get(fk, 0)) + 1
				_face_hist["0"] = int(_face_hist["0"]) - 1
			uvs2[i] = Vector2(float(tid), float(face))
	var k: int = 0
	for z in range(h - 1):
		for x in range(w - 1):
			var i00: int = z * w + x
			var i10: int = i00 + 1
			var i01: int = i00 + w
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
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	# V7-86 tile-index material only when BOTH live indices and atlas art exist.
	# Otherwise the V7-82 splat path is kept with an explicit approximation label.
	var surface_mat: Material = null
	var material_model: String = ""
	if tiles_available and atlas_ready:
		surface_mat = _tileindex_material()
		if surface_mat != null:
			material_model = ("V7-86 terrain_tileindex.gdshader ShaderMaterial; "
				+ "UV2.x=donor tile id, UV2.y=donor-slope face mode (0/1/2); "
				+ "atlas_grid from V7-85 manifest; shadow_enabled=0; "
				+ "V7-86 mask blend retained (measured removal darkens); shader owns blend/cull")
	if surface_mat == null:
		surface_mat = _terrain_material(splat)
		material_model = ("V7-82 splat fallback — PORT APPROXIMATION — NOT DONOR PARITY"
			+ (" (atlas unavailable)" if not atlas_ready else "")
			+ (" (no live tileblock)" if not tiles_available else ""))
	mesh.surface_set_material(0, surface_mat)
	var mi := MeshInstance3D.new()
	mi.name = "HeightmapTerrain"
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	var t_mesh := Time.get_ticks_usec()

	# V7-84 water module replaces the old constant quad; fallback only if the
	# module cannot build. Never stack both water surfaces.
	var water_module_ok := _make_water3d(w, h, height)
	if not water_module_ok:
		_make_water(w, h)
	_make_environment()

	_height = height
	_w = w
	_h = h
	_built = true
	var albedo_size := Vector2i(0, 0)
	if splat != null:
		albedo_size = splat.get_size()
	var atlas_size := Vector2i(0, 0)
	if _atlas_texture != null:
		atlas_size = _atlas_texture.get_size()
	var water_literals: Dictionary = {}
	var water_stats: Dictionary = {}
	if _water3d != null:
		water_stats = _water3d.get("stats")
		if water_stats is Dictionary and water_stats.has("donor_literals"):
			var wl: Variant = water_stats.get("donor_literals")
			if wl is Dictionary:
				water_literals = wl
	stats = {
		"grid": {"w": w, "h": h, "cells": nverts},
		"tile_m": TILE_M,
		"height_scale": HEIGHT_SCALE,
		"height_min_m": hmin,
		"height_max_m": hmax,
		"height_range_m": hmax - hmin,
		"mesh_vertices": nverts,
		"mesh_triangles": ntris,
		"mesh_surfaces": mesh.get_surface_count(),
		"terrain_draw_calls_expected": 1,
		"normals": "central finite difference on height[] (one-sided at borders)",
		"uv": "cell-centre (x+0.5)/map_w, (z+0.5)/map_h; 0..1 over full map",
		"albedo_path": splat_path,
		"albedo_size": [albedo_size.x, albedo_size.y],
		"alpha_as_transparency": false,
		"water_level_m": WATER_LEVEL,
		"sun_direction_yup": [SUN_LIGHTVEC.x, SUN_LIGHTVEC.y, SUN_LIGHTVEC.z],
		"chunks": 0,
		"per_frame_cap": 0,
		# ---- V7-92 additions (TERRAIN2-06 A3 stats shape + integration) ----
		"tile_index_cells": nverts if tiles_available else 0,
		"tile_index_hist": _tile_index_hist.duplicate(true),
		"atlas_mode": _atlas_mode_loaded,   # loader's CHOSEN mode after auto-fallback
		"atlas_path": V785_MANIFEST_PATH + " (V7-85 manifest; V7-91 loader transport)",
		"uv_model": ("V7-86 eye-plane dot(realpos,eye_plane_s/t) + texture_matrix + "
			+ "fract repeat — PORT APPROXIMATION: donor gl_EyePlane*/TextureMatrix "
			+ "values are engine-bound and UNVERIFIED (TERRAIN2-06 §6 #1)"),
		"face_model": ("UV2.y = donor cDiff1/cDiff2 slope + aspect axis "
			+ "(texturemap.inc:63-64,438-447,559-575) -> 0 ground / 1 front / 2 side; "
			+ "PORT APPROXIMATION — NOT DONOR PARITY: exact vf/vs promotion ENGINE/UNVERIFIED; "
			+ "25-degree AngleX/AngleZ remains metadata only"),
		"tile_index": {
			"source": _tile_index_source,
			"cells": nverts if tiles_available else 0,
			"hist": _tile_index_hist.duplicate(true),
			"out_of_atlas_cells_clamped": _tile_index_out_of_atlas,
			"uv2": ("x=float(donor tile id 0..123), "
				+ "y=face mode 0/1/2 from donor slope+aspect (PORT APPROXIMATION)"),
			"face_hist": _face_hist.duplicate(true),
			"transport": "PORT APPROXIMATION (donor has no vertex attribute)",
		},
		"atlas": {
			"requested_mode": atlas_mode,
			"loaded_mode": _atlas_mode_loaded,
			"fallback_policy": "loader auto-fallback single -> split -> array (coordinator update)",
			"v791_verified": "split and array 28/28 (job 245, v791-dual-mode)",
			"grid": [_atlas_grid.x, _atlas_grid.y],
			"texture_size": [atlas_size.x, atlas_size.y],
			"manifest": V785_MANIFEST_PATH,
			"reassembly": _atlas_info.duplicate(true),
			"masks": "alpha.png 512x256 + alphavert.png 1024x512, intensity repacked into ALPHA",
			"array_mode_note": ("V7-86 shader is sampler2D-only; array loader is "
				+ "loaded/exposed, a dedicated split loader supplies tile_atlas"),
		},
		"material_model": material_model,
		"water": {
			"module": WATER3D_PATH if water_module_ok else "V7-82 constant quad fallback",
			"height_aware": bool(water_stats.get("height_aware", false)),
			"donor_literals": water_literals,
			"visual_parity_claimed": false,
			"label": ("V7-84 donor equations; hmapTex engine binding UNVERIFIED "
				+ "(DECOMP-04 §8); PORT SUBSTITUTE height grid via bind_height_grid()"),
		},
		"donor_references": {
			"height_source": "data/scripts/generatemap.inc:537-577 (bitmap->grid->smoothing)",
			"camera_framing": "data/cameras/camera.cfg:32-35,44-45 (V7-5, not this module)",
			"water_level": "variant3d/scripts/mapgen.gd:29 C3MapGen.WATER_DEEP (donor texturemap.inc:30; literal UNVERIFIED)",
			"cell_size": "variant3d/scripts/data.gd:23 C3Data.TILE_M (donor metres UNVERIFIED)",
			"sun_position": "data/env/lights/light.cfg:26-29 (SUN_POS, donor Z-up)",
			"sun_light_vector": "data/shaders/water/water.dev.vert:22 (x/4, z/2, y) then Z-up->Y-up",
			"ambient_diffuse": "data/env/lights/light.cfg:3-16 (Ambient/Diffuse literals)",
			"light_rig_port": "variant3d/scripts/heightmap_world3d.gd:114-147 (V7-60, translated)",
			"tile_index": ("data/scripts/dmscript.global:2026-2035 (.tex); "
				+ "variant3d/scripts/game.gd:53,1610-1689; main.gd:741; TERRAIN2-06:29-31,67-72"),
			"tile_atlas": ("data/terrain/tiles/terrain.presets:2-6; presets_summer.json:2-125; "
				+ "V7-85 manifest; V7-91 dual-mode loader"),
			"tileindex_shader": ("hf.pvl.sm.vert:9,26-33; hf.pvl.smx3.frag:13-14; "
				+ "reftile.mat:120-169; V7-86 INTEGRATION CONTRACT §3"),
			"water_shader": ("data/shaders/water/water.dev.frag; texturemap.inc:29-31 "
				+ "(-0.25/-0.1/2.96); V7-84 §5 integration hook"),
		},
		"timing_ms": {
			"parse_dump": float(t_parsed - t_total) / 1000.0,
			"decode_heights": float(t_heights - t_parsed) / 1000.0,
			"mesh_build": float(t_mesh - t_heights) / 1000.0,
			"total_build": float(Time.get_ticks_usec() - t_total) / 1000.0,
		},
	}
	return true


# Trivially true: the single full-grid mesh covers the whole map, so there are
# no chunks and no chunk fallback to wait for. Satisfies the 2D world contract.
func has_chunk_or_fallback() -> bool:
	return true


# Bilinear sample of the SAME height[] grid the mesh was built from. p is a
# Vector2 of world (x,z) metres with the map centred on the origin, matching
# the mesh's (x+0.5-w/2)*TILE_M / (z+0.5-h/2)*TILE_M layout. Recipe mirrors
# game.height_at() (game.gd:1893-1907); returns metres or 0.0 when unbuilt.
func height_at_world(p: Vector2) -> float:
	if not _built or _height.size() != _w * _h or _w <= 0 or _h <= 0:
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
