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
#
# TRN-GEOM (2026-11-25) — donor-grounded face / environment / normal pass. All
# edits are in THIS FILE ONLY (the shader and water files have other owners):
#   * 25-degree face tilt literals rockNvf AngleX=0 AngleZ=25 / rockNvs
#     AngleX=25 AngleZ=0 (tiles.lib:119-296,543-719; RV-TRN-01 §4.3) applied to
#     promoted faces as vf/vs atlas-cell selection + a 25-degree normal tilt.
#     The vf/vs PROMOTION rule is UNVERIFIED — label PORT APPROXIMATION.
#   * exact donor cliff/shore aspect tables (texturemap.inc:474-529,559-591)
#     and rock height overrides (:594-601), using only atlas art already on disk.
#   * light.cfg ambient/diffuse/specular colours imported into the rig AND the
#     unshaded shader's own lighting terms; fog stays OFF (colors.lib:23,34-43),
#     shadows stay OFF (explicit A/B decision).
#   * 1-cell normal stencil; TILE_M/height scale/mesh/topology and the live
#     tile-index path are UNCHANGED. Relief-grid (.pattern) stamping is a
#     SEPARATE ticket — not attempted here.
#
# RELIEF-01 (2026-11-25) — first small step toward donor relief-grid stamping.
# ALL edits in THIS FILE ONLY. No donor binary copied; the two tables below are
# NUMBERS transcribed from DPATTERN-01 Appendix A1/A2 (docs/coord_swarm_2026-11-25/
# reports/DPATTERN_01_relief_grids.md:602-626), i.e. 8x10 block-mean downsamples
# of the decoded float32 height windows of `k_ravine_1` (G=2866, offset 2866)
# and `plt2` (G=2266, offset 2266). Stamping is OPT-IN: it fires only when the
# input dump carries a `relief_stamps` marker array with a matching donor
# pattern name. The current dump schema (main.gd:736-743) has NO such field, so
# this is a no-op in every existing path — an integration ticket is recorded in
# docs/coord_swarm_2026-11-25/reports/RELIEF_01_stamping.md. A public read-only
# helper `apply_relief_grid()` is provided for explicit, testable opt-in use.
# BLEND LABEL: PORT APPROXIMATION — DONOR ENGINE BLEND UNVERIFIED.
#   The donor sculpt config exists only in pattern.lib (DPATTERN-01 §5.2, 9,520
#   hits, zero script consumers), so the engine's Replace/Smooth/clamp order
#   cannot be recovered here. The port uses the report's additive-clamp form:
#     h = clamp(h + coarse*HeightFieldScale + Offset, HeightFieldMin, HeightFieldMax)
#   with verified donor literals for scale/min/max. Mountain patterns have
#   ALL-ZERO height grids and embed terrainmeshN props (DPATTERN-01 §4.6) —
#   they are deliberately NOT in these tables; props are a separate ticket.
# Mesh invariants are untouched: 1 surface, w*h verts, (w-1)*(h-1)*2 tris,
# UV2 pair intact, atlas (16,8), face_hist contract, shadow OFF.

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

const TILE_M: float = 2.0                 # data.gd:23; donor-grounded: gc_meters_to_tile=2 (dmscript.global:171, DEC-05)
const HEIGHT_SCALE: float = 1.0           # dump height[] is already metres (main.gd:698)
const WATER_LEVEL: float = -0.25          # mapgen.gd:29 C3MapGen.WATER_DEEP; donor literal UNVERIFIED

# V7-60 donor light rig constants (verbatim values + citations from
# heightmap_world3d.gd:34-37); only the two light.cfg colours are recorded as
# donor evidence, the rig itself uses the same body as the sibling module.
const SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)  # light.cfg:26-29
const SUN_LIGHTVEC := Vector3(SUN_POS.x, SUN_POS.y, SUN_POS.z)  # LIGHT-02 verdict: normalize(vec3(P.x,P.y,P.z)), light.cfg:26-31; reports/LIGHT_02_light_space.md §3.4/§5.4 — Y-up identity map, water-local /4,/2 dropped; |P|=0.99999999 and _make_environment() normalizes at :1107, shader normalizes donor_sun_position; PORT APPROXIMATION, no donor GPU parity claim
const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-8 (donor evidence)
const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)  # light.cfg:11-16 (donor evidence)
const DONOR_SPECULAR := Color(0.278431385755539, 0.266666680574417, 0.211764708161354)  # TRN-GEOM: light.cfg:20-23 (donor evidence)
# TRN-GEOM — donor sky band colours, skydome.cfg:11-40 via DEC-03 §4.4 (observed
# literals; the band->Godot-gradient MAPPING is a PORT APPROXIMATION: donor is a
# 32/32 two-band dome, port is ProceduralSkyMaterial). upskydomeband startangle
# -5 (horizon) carries the pale colour; stopangle 90 (zenith) the deep blue.
const DONOR_SKY_HORIZON := Color(0.600000023841858, 0.776470601558685, 0.992156863212585)
const DONOR_SKY_TOP := Color(0.0, 0.141176477074623, 0.807843148708344)
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

# TRN-GEOM — donor face-tilt literals (RV-TRN-01 §4.3, §5 verdict C):
#   rockNvf  AngleX=0  AngleZ=25  -> refkey verticalfront  (tiles.mat:142-210)
#   rockNvs  AngleX=25 AngleZ=0   -> refkey verticalside   (tiles.mat:142-210)
# 36 vf + 36 vs blocks, tiles.lib:119-296,543-719 (RV-TRN-01 correction #3).
# The engine APPLICATION of 25 degrees is UNVERIFIED (names occur only in
# terrain.presets/tiles.lib/tiles.mat, never in a script). Port applies the
# literal as a normal tilt + vf/vs atlas-cell choice: PORT APPROXIMATION.
const DONOR_FACE_TILT_DEG: float = 25.0
# Donor face-alpha projection scale, reftile.mat:124-126 / :150-152. The
# eye-linear planes themselves are ALREADY in the shader (read-only owner):
# front S=(1,0,0,0) T=(0,0,1,0); side S=(0,1,0,0) T=(0,0,1,0).
const DONOR_FACE_SCALE: float = 0.125

# TRN-GEOM — donor rock-art height gates (texturemap.inc:594-601, DTRN-01 C13):
# abs(h)>2.7 -> rock8, abs(h)>2.4 -> rock4, abs(h)<0.1 -> no cliff tile.
const DONOR_ROCK8_H: float = 2.7
const DONOR_ROCK4_H: float = 2.4
const DONOR_ROCK_NONE_H: float = 0.1
# Donor shore test cWaterShoreHeight (texturemap.inc:31, :469-470).
const DONOR_SHORE_H: float = -0.1

# RELIEF-01 — donor-derived coarse relief grids. NUMBERS ONLY (no bytes shipped,
# no donor asset copied). Each table is the 8x10 block-mean downsample from
# DPATTERN-01 Appendix A (A1 k_ravine_1 :602-613, A2 plt2 :615-626), flattened
# row-major: index = gy*RELIEF_COARSE_W + gx, gy=file-row band top->bottom,
# gx=file-col band left->right. "-0.000" in the report is written 0.0 here
# (identical float32 value). These are DEBUG/PREVIEW-GRADE means; the report
# explicitly says to stamp from the full grid when fidelity is needed. The full
# w*h float32 grids are NOT copied into this file — that is a later ticket.
const RELIEF_COARSE_W: int = 10
const RELIEF_COARSE_H: int = 8

const RELIEF_K_RAVINE_1: Array = [
	-0.056, -0.309, -0.251, -0.067, -0.190, -1.119, -0.714,  0.000,  0.000, -0.013,
	-2.056, -2.251, -1.897, -0.629, -0.006, -0.121, -0.098, -0.001, -0.537, -2.300,
	-2.947, -2.941, -2.916, -1.785, -0.011,  0.000,  0.000, -0.018, -0.809, -2.411,
	-2.920, -2.384, -2.015, -1.071, -0.008,  0.000,  0.000,  0.162,  0.730, -2.255,
	-0.352,  1.656,  0.740,  0.019,  0.000,  0.000,  0.000,  0.178,  2.249,  1.379,
	 2.937,  2.730,  1.909,  0.227,  0.000,  0.000,  0.000,  0.001,  0.964,  2.763,
	 1.258,  0.391,  0.098,  0.001,  0.000,  0.000,  0.000,  0.000,  0.007,  0.422,
	 0.000,  0.000,  0.000,  0.000,  0.000,  0.000,  0.025,  0.094,  0.100,  0.075,
]

const RELIEF_PLT2: Array = [
	 0.032,  0.065,  0.061,  0.031, -0.001, -0.002,  0.000,  0.000, -0.001, -0.005,
	 1.406,  2.451,  2.364,  1.313,  0.500,  0.163,  0.028,  0.001,  0.001,  0.212,
	 2.914,  3.294,  3.096,  2.627,  1.492,  0.226,  0.039,  0.002,  0.018,  0.580,
	 1.325,  3.033,  3.437,  3.392,  1.927,  0.188,  0.003,  0.000,  0.019,  0.305,
	 2.699,  3.198,  3.176,  2.573,  1.144,  0.128,  0.013, -0.001,  0.017,  0.759,
	 1.546,  2.625,  3.149,  2.309,  0.384,  0.061,  0.001,  0.001,  0.057,  0.457,
	 0.296,  1.158,  1.478,  0.743,  0.167,  0.015,  0.000,  0.000,  0.004,  0.025,
	 0.006,  0.019,  0.029,  0.026,  0.011,  0.000,  0.000,  0.000,  0.143,  0.086,
]

# Per-pattern metadata: scale/min/max are the VERIFIED pattern.lib literals
# cross-checked bit-exactly against the decoded windows (DPATTERN-01 §3/§4).
# `src_offset` is traceability only — no donor bytes are shipped.
# Blend label is mandatory on every consumer of these tables.
const RELIEF_TABLES: Dictionary = {
	"k_ravine_1": {
		"table": RELIEF_K_RAVINE_1,
		"family": "ravine_medium",          # generator.cfg:540 (//-disabled stamp, :1760)
		"src_offset": 2866, "grid_w": 46, "grid_h": 63,
		"scale": 1.0,                        # pattern.lib:549568
		"min": -2.963627576828003,           # pattern.lib:549585 (exact float32)
		"max": 3.139820098876953,            # pattern.lib:549586 (exact float32)
		"cite": "DPATTERN-01 §4.1/:602-613; pattern.lib:549568,549585-549586",
	},
	"plt2": {
		"table": RELIEF_PLT2,
		"family": "plateau",                # generator.cfg:588
		"src_offset": 2266, "grid_w": 42, "grid_h": 55,
		"scale": 1.0,                        # DPATTERN-01 §3 inventory: scale 1
		"min": -0.07325489819049835,         # pattern.lib:6805 (exact float32)
		"max": 3.6134116649627686,           # pattern.lib:6806 (exact float32)
		"cite": "DPATTERN-01 §3/§4.4/:615-626; pattern.lib:6805-6806 (scale 1 per §3)",
	},
}
const RELIEF_BLEND_LABEL := ("PORT APPROXIMATION — donor engine blend UNVERIFIED "
	+ "(DPATTERN-01 §5.2: sculpt config is pattern.lib-only, no plaintext consumer)")

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

# --- SP-6 / SEASON-PLAN-01 §4.3 — season -> atlas selection (INDEX-PRESERVING) ---
# Donor season is a SET swap at the SAME preset index (terrain.lib:12-15,
# terrain.presets:2-6/134-263; via DENV-01), so tile indices stay unchanged and
# DALPHA-02's index-preserving shader needs NO edit (SEASON-PLAN-01 B4/B5).
# Enum values are from SP-1 (data.gd:227 SEASON_ENUM): summer=0, winter=2,
# desert=3. Value 1 is UNVERIFIED (dmscript.global:237 gc_MaxSeasonCount=3
# implies 0/1/2; DENV-01 Q5 / SEASON-PLAN-01 B7) and has NO entry — no guessed
# art. All donor swap logic lives in ';'-prefixed .inc/.script lines, so donor
# RUNTIME activity is UNVERIFIED (SEASON-PLAN-01 B6, DENV-01 Q6): this is donor
# INTENT implemented as a PORT APPROXIMATION, not a "donor runs this" claim.
const DATA_SCRIPT = preload("res://scripts/data.gd")  # SP-1 BIOME / SEASON_ENUM
const SUMMER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas.png"  # tile_atlas_loader.gd:66 (V7-85)
# SP-4 LANDED with these exact on-disk names (tile_index_atlas_winter.*), NOT the
# planned tile_index_winter_atlas.* of SEASON_PLAN_01.md:189 — path corrected here
# to the verified artifact bytes. No rename/copy and no git add/LFS action here.
const WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.manifest.json"  # SP-4 landed (verified on disk)
const WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.png"  # SP-4 landed (verified on disk)
const DESERT_REMAP_PATH := "res://assets/terrain/atlas/desert_remap.json"  # SP-3 landed at atlas/ (SP_03 O1)
const SEASON_DEFAULT_NAME := "summer"  # map.script:250 gen.season=0; terrain.lib:12 seasons.Summer=Summer
const SEASON_ATLAS: Dictionary = {
	"summer": {"enum": 0, "manifest_path": V785_MANIFEST_PATH, "atlas_path": SUMMER_ATLAS_PATH},
	"winter": {"enum": 2, "manifest_path": WINTER_MANIFEST_PATH, "atlas_path": WINTER_ATLAS_PATH},
	# Desert has NO separate donor preset section (DENV-01 §4 / SEASON-PLAN-01 §4.3):
	# the Summer atlas/manifest stays bound and SP-3's name remap is applied to
	# tile ids BEFORE UV2.x. No second atlas is ever accumulated (B2 memory).
	"desert": {"enum": 3, "manifest_path": V785_MANIFEST_PATH, "atlas_path": SUMMER_ATLAS_PATH},
}

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
# SP-6 — season selection / provenance (no mesh state).
var season: String = SEASON_DEFAULT_NAME   # public: "summer" (default) | "winter" | "desert"
var _season_resolved: String = SEASON_DEFAULT_NAME
var _season_manifest_path: String = V785_MANIFEST_PATH
var _season_atlas_path: String = SUMMER_ATLAS_PATH
var _season_fallback: String = ""          # non-empty when Winter art was absent
var _desert_remap: Dictionary = {}         # SP-3 source tile id -> packed atlas id
var _desert_remap_entries: int = 0
var _desert_remap_cells: int = 0
var _tile_indices := PackedByteArray()
var _tile_index_source: String = ""
var _tile_index_hist: Dictionary = {}
var _tile_index_out_of_atlas: int = 0
var _face_hist: Dictionary = {}             # FIX-TERRAIN: face-mode cell counts
var _water3d = null                         # V7-84 water3d.gd instance
# TRN-GEOM — donor index dictionary (name<->index from the V7-85 manifest, whose
# index_dictionary points at presets_summer.json:2-125 <- terrain.presets:2-6).
var _tile_name_index: Dictionary = {}
var _tile_index_name: Dictionary = {}
var _face_tilt_cells: int = 0
var _rock_override_cells: int = 0
var _shore_sector_cells: int = 0
var _water_tile_cells: int = 0          # BLK_WATER remapped off grass1 (TRN-WATER handoff)
var _water_fallback_cells: int = 0      # BLK_WATER with no donor aspect -> sandsea1
# RELIEF-01 — audit ledger for opt-in stamp calls (no mesh state).
var _relief_applied: Array = []


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
# SP-6 — season selection. An explicit `season` field wins; otherwise follow
# the port's live string selector BIOME (data.gd:199 <- config.gd:546), which
# SP-1 maps to the donor enum SEASON_ENUM {summer:0,winter:2,desert:3}
# (data.gd:227). Unknown values normalize to Summer; no value-1 path exists.
# ---------------------------------------------------------------------------
func _effective_season() -> String:
	var s: String = season.strip_edges().to_lower()
	if s.is_empty() or s == SEASON_DEFAULT_NAME:
		var b: String = str(DATA_SCRIPT.BIOME).strip_edges().to_lower()
		if b == "winter" or b == "desert":
			return b
		return SEASON_DEFAULT_NAME
	return s if SEASON_ATLAS.has(s) else SEASON_DEFAULT_NAME


func _season_file_exists(res_path: String) -> bool:
	# res:// works in-editor; globalize_path() covers an exported build.
	return (FileAccess.file_exists(res_path)
		or FileAccess.file_exists(ProjectSettings.globalize_path(res_path)))


func _select_season_atlas(s: String) -> Dictionary:
	var chosen: Dictionary = SEASON_ATLAS.get(s, SEASON_ATLAS[SEASON_DEFAULT_NAME])
	var mp: String = str(chosen.get("manifest_path", V785_MANIFEST_PATH))
	var ap: String = str(chosen.get("atlas_path", SUMMER_ATLAS_PATH))
	# SP-4's Winter atlas may still be building: never crash on a missing file.
	# Fall back to the Summer pair for BOTH paths so the index dictionary and
	# the bound texture always agree (index-preserving contract). Desert has no
	# separate atlas by design, so it never takes this branch.
	if not (_season_file_exists(mp) and _season_file_exists(ap)):
		if not (mp == V785_MANIFEST_PATH and ap == SUMMER_ATLAS_PATH):
			_season_fallback = ("SP-4 winter manifest/atlas absent — SP-6 fell back "
				+ "to the V7-85 Summer pair (index-preserving; winter art UNVERIFIED)")
			mp = V785_MANIFEST_PATH
			ap = SUMMER_ATLAS_PATH
	return {"manifest_path": mp, "atlas_path": ap}


func _load_desert_remap() -> void:
	# SP-3's 11 DIRECT pairs (source_index -> packed atlas index) from
	# atlas/desert_remap.json. The single height-gated rock8 row is
	# DATA_ONLY_NOT_EXECUTED and deliberately NOT loaded: SP-6 is index-only
	# (SEASON_PLAN_01 Q2 / SP_03 §5), so a rock8 cell keeps its Summer index.
	_desert_remap = {}
	_desert_remap_entries = 0
	var d := _read_json(DESERT_REMAP_PATH)
	var rv: Variant = d.get("remap", null)
	if not (rv is Dictionary):
		return
	for k in (rv as Dictionary).keys():
		var e: Variant = (rv as Dictionary)[k]
		if not (e is Dictionary):
			continue
		var src: Variant = (e as Dictionary).get("source_index", null)
		var dst: Variant = (e as Dictionary).get("atlas_index", null)
		if src is int and dst is int:
			_desert_remap[int(src)] = int(dst)
	_desert_remap_entries = _desert_remap.size()


# ---------------------------------------------------------------------------
# RELIEF-01 — opt-in relief-grid stamping. PORT APPROXIMATION: donor engine
# blend UNVERIFIED (RELIEF_BLEND_LABEL). A coarse 8x10 donor-derived table is
# mapped onto a small footprint window centred on (cx,cy) in MAP CELLS; each
# cell receives coarse[gy,gx] * effective_scale additively, then the donor
# pattern's verified HeightFieldMin/Max clamp. No mesh/node/atlas/water state
# is touched and no donor file is read — this is a pure, testable helper.
# Returns false for an unknown pattern name or a too-small grid.
# ---------------------------------------------------------------------------
func apply_relief_grid(height: PackedFloat32Array, w: int, h: int,
		pname: String, cx: int = 0, cy: int = 0, scale: float = 1.0,
		footprint_w: int = RELIEF_COARSE_W,
		footprint_h: int = RELIEF_COARSE_H) -> bool:
	if w <= 0 or h <= 0 or height.size() < w * h:
		return false
	var key: String = pname.strip_edges()
	var mv: Variant = RELIEF_TABLES.get(key, null)
	if mv == null or not (mv is Dictionary):
		return false
	var md: Dictionary = mv
	var tv: Variant = md.get("table", null)
	if not (tv is Array) or (tv as Array).size() != RELIEF_COARSE_W * RELIEF_COARSE_H:
		return false
	var tbl: Array = tv
	var lo: float = float(md.get("min", 0.0))
	var hi: float = float(md.get("max", 0.0))
	var sf: float = float(md.get("scale", 1.0)) * scale
	var fw: int = maxi(1, footprint_w)
	var fh: int = maxi(1, footprint_h)
	var x0: int = cx - fw / 2
	var z0: int = cy - fh / 2
	var cells: int = 0
	for gy in range(fh):
		var mz: int = z0 + gy
		if mz < 0 or mz >= h:
			continue
		for gx in range(fw):
			var ux: int = x0 + gx
			if ux < 0 or ux >= w:
				continue
			# PORT APPROXIMATION — donor engine blend UNVERIFIED.
			var delta: float = float(tbl[gy * RELIEF_COARSE_W + gx]) * sf
			var idx: int = mz * w + ux
			height[idx] = clampf(height[idx] + delta, lo, hi)
			cells += 1
	_relief_applied.append({
		"name": key,
		"cells": cells,
		"center": [cx, cy],
		"footprint": [fw, fh],
		"scale": sf,
		"min": lo,
		"max": hi,
		"cite": str(md.get("cite", "")),
		"blend": RELIEF_BLEND_LABEL,
		"source": "DPATTERN-01 Appendix A coarse 8x10 block-mean (derived numbers only)",
	})
	return cells > 0


# RELIEF-01 — opt-in marker reader. The CURRENT dump schema (main.gd:736-743)
# has no relief marker, so this returns 0 and build() is byte-identical to the
# pre-RELIEF-01 path. An integration ticket (RELIEF_01_stamping.md) records the
# producer-side work needed to emit dump["relief_stamps"]. No other file edited.
# Marker fields: name (donor pattern id), cx/cy (map cells), optional scale /
# footprint_w / footprint_h. JSON numbers may arrive as float — accept both.
func _apply_relief_stamps_from_dump(dump: Dictionary, height: PackedFloat32Array,
		w: int, h: int) -> int:
	var markers: Variant = dump.get("relief_stamps", null)
	if not (markers is Array):
		return 0
	var applied: int = 0
	for sv in (markers as Array):
		if not (sv is Dictionary):
			continue
		var m: Dictionary = sv
		var pname: String = str(m.get("name", m.get("pattern", "")))
		if pname.is_empty():
			continue
		var cx: int = w / 2
		var cz: int = h / 2
		var cv: Variant = m.get("cx", m.get("x", null))
		if cv is int or cv is float:
			cx = int(cv)
		var zv: Variant = m.get("cy", m.get("y", null))
		if zv is int or zv is float:
			cz = int(zv)
		var sc: float = 1.0
		var scv: Variant = m.get("scale", null)
		if scv is int or scv is float:
			sc = float(scv)
		var fw: int = RELIEF_COARSE_W
		var fwv: Variant = m.get("footprint_w", null)
		if fwv is int or fwv is float:
			fw = int(fwv)
		var fh: int = RELIEF_COARSE_H
		var fhv: Variant = m.get("footprint_h", null)
		if fhv is int or fhv is float:
			fh = int(fhv)
		if apply_relief_grid(height, w, h, pname, cx, cz, sc, fw, fh):
			applied += 1
	return applied


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
	# SP-6 — select both paths from the season, never accumulate two atlases.
	_season_resolved = _effective_season()
	_season_fallback = ""
	var sel: Dictionary = _select_season_atlas(_season_resolved)
	_season_manifest_path = str(sel.get("manifest_path", V785_MANIFEST_PATH))
	_season_atlas_path = str(sel.get("atlas_path", SUMMER_ATLAS_PATH))
	_manifest = _read_json(_season_manifest_path)
	if _manifest.is_empty() and _season_manifest_path != V785_MANIFEST_PATH:
		# Defensive: a manifest that exists but fails to parse is treated like an
		# absent Winter asset — fall back, label it, never crash.
		_season_fallback = ("selected manifest unreadable — SP-6 fell back to the "
			+ "V7-85 Summer pair (index-preserving)")
		_season_manifest_path = V785_MANIFEST_PATH
		_season_atlas_path = SUMMER_ATLAS_PATH
		_manifest = _read_json(V785_MANIFEST_PATH)
	# SP-3 data is loaded for every season but only consumed by Desert in build().
	_load_desert_remap()
	var loader_script := load(TILE_ATLAS_LOADER_PATH) as Script
	if loader_script == null or not loader_script.can_instantiate():
		push_error("world3d_terrain: cannot load " + TILE_ATLAS_LOADER_PATH)
		return false

	# Instantiate the loader in the requested mode (default "single"). V7-91's
	# loader owns auto-fallback single -> split -> array with a warning; this
	# module never second-guesses that choice, it only reports it in stats.
	# SP-6 passes the SP-5 overrides (manifest_path + single_atlas_path) so the
	# loader reads the selected manifest PNG pair. For Summer the values equal
	# the loader defaults, so the original no-config call is preserved verbatim.
	var use_season_paths: bool = (_season_manifest_path != V785_MANIFEST_PATH
		or _season_atlas_path != SUMMER_ATLAS_PATH)
	if use_season_paths:
		_atlas_loader = loader_script.new(atlas_mode, {
			"manifest_path": _season_manifest_path,
			"single_atlas_path": _season_atlas_path,
		})
	else:
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
	# TRN-GEOM — import the donor light.cfg COLOURS into the shader's own
	# (unshaded) Blinn-Phong terms. Parameters already exist at
	# terrain_tileindex.gdshader:123-135; NO shader edit is made here (the shader
	# has another owner). PORT APPROXIMATION: donor light PRODUCTS are engine-
	# bound; the shader's previous 0.15686/0.78125/0.0 were MATERIAL literals.
	mat.set_shader_parameter("ambient_rgb", Vector3(DONOR_AMBIENT.r, DONOR_AMBIENT.g, DONOR_AMBIENT.b))
	mat.set_shader_parameter("diffuse_rgb", Vector3(DONOR_DIFFUSE.r, DONOR_DIFFUSE.g, DONOR_DIFFUSE.b))
	mat.set_shader_parameter("specular_rgb", Vector3(DONOR_SPECULAR.r, DONOR_SPECULAR.g, DONOR_SPECULAR.b))
	# TRN-SHADER handoff: the shader's `donor_sun_position` is the RAW donor
	# light.cfg Position (x,y,z), not the transformed water.dev.vert vector.
	# Bind SUN_POS verbatim so rig and shader cannot drift apart.
	mat.set_shader_parameter("donor_sun_position", Vector3(SUN_POS.x, SUN_POS.y, SUN_POS.z))
	# Donor face-alpha scale literal (reftile.mat:124-126,:150-152); the shader
	# already defaults to it, binding explicitly so the value is auditable here.
	mat.set_shader_parameter("face_scale", DONOR_FACE_SCALE)
	# No real shadow map is supplied; keep the shader default OFF (explicit A/B).
	mat.set_shader_parameter("shadow_enabled", 0.0)
	# Fog default palette is FogMode=0 (colors.lib:23,34-43, DTRN-01 C20) — OFF.
	mat.set_shader_parameter("fog_mode", 0.0)
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


# ---------------------------------------------------------------------------
# TRN-GEOM — donor aspect / cliff / shore tile selection. All tables below are
# transcribed from read-only donor text, NOT invented:
#   signed angle  : texturemap.inc:433-448 (dirX=lh-rh, dirY=th-bh,
#                   VectorAngle(1,0,0,dirX,0,dirY), negate when dirY<0)
#   shore 8-sector: texturemap.inc:474-529 (cAngle=45, vecangle+=180)
#   cliff sector  : texturemap.inc:559-591 (bRB/bLB/bR/bB/bT/bL -> rockN)
#   height gates  : texturemap.inc:594-601
# Names resolve through the V7-85 manifest layout (presets_summer.json:2-125).
# The donor vf/vs PROMOTION rule remains UNVERIFIED (RV-TRN-01 verdict C).
# ---------------------------------------------------------------------------
func _donor_aspect_deg(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> float:
	var lh: float = height[z * w + maxi(0, x - 1)]
	var rh: float = height[z * w + mini(w - 1, x + 1)]
	var th: float = height[maxi(0, z - 1) * w + x]
	var bh: float = height[mini(h - 1, z + 1) * w + x]
	var dx: float = lh - rh
	var dy: float = th - bh
	if absf(dx) < 0.0001 and absf(dy) < 0.0001:
		return -999.0   # donor's `len>0.01` guard fails -> no newtile
	return rad_to_deg(atan2(dy, dx))


func _donor_cliff_name(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> String:
	var c: float = height[z * w + x]
	if absf(c) < DONOR_ROCK_NONE_H:      # texturemap.inc:600-601 -> no tile
		return ""
	if absf(c) > DONOR_ROCK8_H:          # texturemap.inc:594-595
		return "rock8"
	if absf(c) > DONOR_ROCK4_H:          # texturemap.inc:597-598
		return "rock4"
	var a: float = _donor_aspect_deg(height, w, h, x, z)
	if a < -900.0:
		return ""
	var sector: String = "L"            # texturemap.inc:575 (else -> bL)
	if a >= 22.5 and a <= 67.5:
		sector = "RB"                   # :560-561
	elif a >= 120.0 and a <= 170.0:
		sector = "LB"                   # :563-564
	elif a >= -45.0 and a <= 45.0:
		sector = "R"                    # :566-567
	elif a > 45.0 and a <= 135.0:
		sector = "B"                    # :569-570 (45 belongs to bR)
	elif a >= -135.0 and a < -45.0:
		sector = "T"                    # :572-573
	# Newtile assignment order is the donor's later-wins chain :578-591.
	match sector:
		"LB": return "rock7"            # :578
		"B": return "rock1"             # :580
		"L": return "rock3"             # :581
		"RB": return "rock4"            # :591 (rock6 at :579 is commented out)
		"R": return "rock4"             # :583 (rock2 at :582 is commented out)
		"T": return "rock4"             # :590
	return ""


func _donor_shore_name(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> String:
	var a: float = _donor_aspect_deg(height, w, h, x, z)
	if a < -900.0:
		return ""
	a += 180.0                          # texturemap.inc:476
	var sector: String = "RT"           # :500-501 (else -> bRT)
	if a >= -22.5 and a < 22.5:
		sector = "R"                    # :479-480
	elif a >= 22.5 and a < 67.5:
		sector = "RB"                   # :482-483
	elif a >= 67.5 and a < 112.5:
		sector = "B"                    # :485-486
	elif a >= 112.5 and a < 157.5:
		sector = "LB"                   # :488-489
	elif a >= 157.5 and a < 202.5:
		sector = "L"                    # :491-492
	elif a >= 202.5 and a < 247.5:
		sector = "LT"                   # :494-495
	elif a >= 247.5 and a < 292.5:
		sector = "T"                    # :497-498
	# Later-wins chain :504-511.
	match sector:
		"LB": return "sandsea5"         # :504
		"RB": return "sandsea6"         # :505
		"B": return "sandsea1"          # :506
		"L": return "sandsea6"          # :507
		"R": return "sandsea6"          # :508
		"T": return "sandsea1"          # :509
		"RT": return "sandsea5"         # :510
		"LT": return "sandsea6"         # :511
	return ""


func _tile_index_for_name(tile_name: String) -> int:
	if tile_name.is_empty():
		return -1
	var v: Variant = _tile_name_index.get(tile_name, null)
	return int(v) if v is int else -1


# TRN-GEOM — apply the donor face-tilt LITERAL as a normal rotation. Only the
# NORMAL array changes: vertex count, index count and surface count are intact.
# face 1 = rockNvf AngleX=0 AngleZ=25 -> rotate about Z.
# face 2 = rockNvs AngleX=25 AngleZ=0 -> rotate about X.
# ENGINE PATH UNVERIFIED: PORT APPROXIMATION, not donor parity.
func _tilt_face_normal(n: Vector3, face: int) -> Vector3:
	if face == 0:
		return n
	var a: float = deg_to_rad(DONOR_FACE_TILT_DEG)
	var ca: float = cos(a)
	var sa: float = sin(a)
	if face == 1:
		return Vector3(n.x * ca - n.y * sa, n.x * sa + n.y * ca, n.z).normalized()
	return Vector3(n.x, n.y * ca - n.z * sa, n.y * sa + n.z * ca).normalized()


# 1-cell forward difference (one-sided backward at the last row/column) instead
# of the previous 2*TILE_M central stencil, per DTRN-02 Step 5: a 1-cell cliff
# step is no longer averaged away. TILE_M stays 2.0 m (gc_meters_to_tile=2,
# dmscript.global:171 via DEC-05) and no vertex/index is added. Port analogue
# of donor hf.pvl.sm.vert normals (shaders.lib:16-19), not a donor copy.
func _normal_at(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> Vector3:
	if w < 2 or h < 2:
		return Vector3(0.0, 1.0, 0.0)
	var xa: int = x + 1
	var xb: int = x
	if xa > w - 1:
		xa = x
		xb = x - 1
	var za: int = z + 1
	var zb: int = z
	if za > h - 1:
		za = z
		zb = z - 1
	var dhdx: float = (height[z * w + xa] - height[z * w + xb]) / TILE_M
	var dhdz: float = (height[za * w + x] - height[zb * w + x]) / TILE_M
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
	# TRN-GEOM — donor sky band colours, skydome.cfg:11-40 via DEC-03 §4.4.
	# Donor has a two-band dome (startangle -5 = horizon pale, stopangle 90 =
	# zenith deep blue) with a uniform pale lower band (:31-40). Mapping that
	# dome onto Godot's gradient is a PORT APPROXIMATION — the COLOURS are the
	# observed donor literals, not invented port values. Curves stay port-tuned.
	skymat.sky_top_color = DONOR_SKY_TOP
	skymat.sky_horizon_color = DONOR_SKY_HORIZON
	skymat.sky_curve = 0.18
	skymat.ground_bottom_color = DONOR_SKY_HORIZON
	skymat.ground_horizon_color = DONOR_SKY_HORIZON
	skymat.ground_curve = 0.10
	sky.sky_material = skymat
	env.sky = sky
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = EXPOSURE
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	# TRN-GEOM — was port-tuned Color(0.86,0.88,0.82); now the donor ambient
	# literal light.cfg:3-6 (DEC-03 §4.3). Energy stays as M0.6 PORT APPROX.
	env.ambient_light_color = DONOR_AMBIENT
	env.ambient_light_energy = AMBIENT_ENERGY
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "DonorSun"
	# TRN-GEOM — donor diffuse = sun colour (light.cfg:10-13, DEC-03 §4.3).
	# Donor specular (light.cfg:20-23) has no Light3D colour slot; it is bound
	# to the shader's `specular_rgb` in _tileindex_material() and to stats.
	# Position/energy stay donor-grounded/port-compensated respectively.
	sun.light_color = DONOR_DIFFUSE
	sun.light_energy = SUN_ENERGY
	# FIX-TERRAIN — EXPLICIT USER DECISION (this wave): shadows are DISABLED.
	# The old shadow map combined a near-vertical donor sun, a 400 m frustum on
	# a 640 x 640 m self-shadowing mesh and engine-side projection (UNVERIFIED:
	# light.cfg:26-29 / water.dev.vert:22 give the vector, not a shadow matrix),
	# producing long directional streaks. Donor sun colour/energy and the sky
	# rig are UNCHANGED; only the Godot shadow map is switched off. Re-enable
	# ONLY after a bounded donor-grounded frustum is implemented and A/B'd.
	sun.shadow_enabled = false
	sun.directional_shadow_max_distance = 400.0  # retained, now INERT (no map)
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
	# TRN-GEOM state (so a rebuild cannot carry stale counts / name tables).
	_tile_name_index = {}
	_tile_index_name = {}
	_face_tilt_cells = 0
	_rock_override_cells = 0
	_shore_sector_cells = 0
	_water_tile_cells = 0
	_water_fallback_cells = 0
	# RELIEF-01 (no mesh state; keep a rebuild from stacking stamp ledgers).
	_relief_applied = []
	# SP-6 (no mesh state; rebuild must not carry a stale season selection).
	# The public `season` field is intentionally persistent across rebuilds.
	_season_resolved = SEASON_DEFAULT_NAME
	_season_manifest_path = V785_MANIFEST_PATH
	_season_atlas_path = SUMMER_ATLAS_PATH
	_season_fallback = ""
	_desert_remap = {}
	_desert_remap_entries = 0
	_desert_remap_cells = 0


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

	# RELIEF-01 — OPT-IN donor-grid stamping. Only fires when the dump carries a
	# `relief_stamps` marker (none in the current schema / smoke test), so all
	# existing paths keep their exact heights. PORT APPROXIMATION — donor engine
	# blend UNVERIFIED (RELIEF_BLEND_LABEL). Topology is never changed here.
	var relief_applied: int = _apply_relief_stamps_from_dump(dump, height, w, h)
	if relief_applied > 0:
		hmin = INF
		hmax = -INF
		for i in range(w * h):
			hmin = minf(hmin, height[i])
			hmax = maxf(hmax, height[i])

	# V7-92: decode donor tile indices and load the selected atlas transport.
	_decode_tile_indices(dump, w, h)
	var atlas_ready := _load_atlas()
	var tiles_available: bool = not _tile_indices.is_empty()

	# TRN-GEOM — donor tile-name dictionary from the V7-85 manifest layout
	# (index_dictionary: presets_summer.json:2-125 <- data/terrain/tiles/
	# terrain.presets:2-6). No name or index is invented. If a manifest layout
	# is absent the donor-grounded overrides simply no-op (reported in stats).
	var layout_v: Variant = _manifest.get("layout", [])
	if layout_v is Array:
		for entry in layout_v:
			if entry is Dictionary:
				var nm: String = str(entry.get("name", ""))
				var ix: Variant = entry.get("index", null)
				if not nm.is_empty() and ix is int:
					_tile_name_index[nm] = int(ix)
					_tile_index_name[int(ix)] = nm

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
	# SP-6 — Desert-only; Summer and Winter cells are never remapped, so those
	# builds (UV2, face_hist, mesh counts) stay byte-identical.
	var season_is_desert: bool = (_season_resolved == "desert")
	_face_hist = {"0": nverts}
	for z in range(h):
		for x in range(w):
			var i: int = z * w + x
			verts[i] = Vector3((float(x) + 0.5 - cx) * TILE_M,
				height[i] * HEIGHT_SCALE,
				(float(z) + 0.5 - cz) * TILE_M)
			uvs[i] = Vector2((float(x) + 0.5) / float(w),
				(float(z) + 0.5) / float(h))
			# V7-86 CONTRACT: UV2.x = float(donor tile id), UV2.y = face mode.
			# FIX-TERRAIN: UV2.y is derived from donor-readable slope data
			# (_face_mode_at, texturemap.inc:63-64/438-447/559-575). 0 = ground
			# default (reftile.mat:1-108), 1 = verticalfront, 2 = verticalside.
			# TRN-GEOM / TRN-WATER handoff: the live game's 255 = BLK_WATER
			# (game.gd:52) used to clamp to 0 = grass1, giving a grass-coloured
			# shoreline under the near-zero-alpha water band (DTRN-03 W2/F2).
			# It is now mapped to donor shore art by the 8x45-deg sector table
			# (texturemap.inc:463-472,503-511) instead of to grass1.
			var raw_tid: int = int(_tile_indices[i]) if tiles_available else 0
			var water_sentinel: bool = tiles_available and raw_tid > max_tile_id
			var shore_gate: bool = water_sentinel or height[i] < DONOR_SHORE_H
			var tid: int = raw_tid
			if tid < 0 or tid > max_tile_id:
				tid = 0
			# Donor water/shore branch (:472-530) precedes the cliff branch
			# (:556-610): do not promote water/shore cells to vf/vs cliff faces.
			var face: int = 0 if shore_gate else _face_mode_at(height, w, h, x, z)

			# TRN-GEOM — donor cliff tile selection on promoted cells only.
			# _donor_cliff_name() applies the exact donor height gates
			# (texturemap.inc:594-601) and 6-sector cliff table (:559-591).
			# TRN-GEOM APPROX: mapping the port-promoted cell onto the donor
			# vf/vs atlas cell is a PORT APPROXIMATION — the donor promotion
			# rule is UNVERIFIED (RV-TRN-01 verdict C). Never alters mesh counts.
			if face != 0:
				var cliff_name: String = _donor_cliff_name(height, w, h, x, z)
				if cliff_name.is_empty():
					face = 0   # donor abs(h)<0.1 -> "no cliff tile"
				else:
					_rock_override_cells += 1
					var face_name: String = cliff_name + ("vf" if face == 1 else "vs")
					var face_idx: int = _tile_index_for_name(face_name)
					if face_idx >= 0:
						tid = face_idx
						_face_tilt_cells += 1
					else:
						var base_idx: int = _tile_index_for_name(cliff_name)
						if base_idx >= 0:
							tid = base_idx   # vf/vs art absent -> base cliff tile
			elif shore_gate and tiles_available:
				# TRN-GEOM / TRN-WATER — donor 8-sector shore orientation
				# (texturemap.inc:474-529,503-511): sandsea1=93, sandsea5=97,
				# sandsea6=98 in the V7-85 atlas (64² atoms, DTRN_03). Names are
				# resolved from the manifest dictionary, not hard-coded.
				# Gate: BLK_WATER sentinel OR already-sandsea* art OR low sand*
				# art. The donor mask B test (texturemap.inc:464) is not
				# readable here -> PORT APPROX gate; the SECTOR TABLE is donor
				# exact. No new art, no foam, no water-literal change.
				var base_name: String = str(_tile_index_name.get(tid, ""))
				if (water_sentinel or base_name.begins_with("sandsea")
						or (height[i] < WATER_LEVEL and base_name.begins_with("sand"))):
					var shore_name: String = _donor_shore_name(height, w, h, x, z)
					var shore_idx: int = -1
					if not shore_name.is_empty():
						shore_idx = _tile_index_for_name(shore_name)
					if water_sentinel:
						if shore_idx < 0:
							# Flat deep water has no donor aspect (len<=0.01 at
							# :442); donor leaves its own water tile unchanged,
							# but the port atlas has no water block. Fall back
							# to sandsea1 (donor literal :506/:509) so no water
							# cell ever samples grass1. PORT APPROXIMATION.
							shore_idx = _tile_index_for_name("sandsea1")
							_water_fallback_cells += 1
						if shore_idx >= 0:
							_water_tile_cells += 1
					elif shore_idx >= 0 and shore_idx != tid:
						_shore_sector_cells += 1
					if shore_idx >= 0:
						tid = shore_idx

			norms[i] = _tilt_face_normal(_normal_at(height, w, h, x, z), face)
			if face != 0:
				var fk: String = str(face)
				_face_hist[fk] = int(_face_hist.get(fk, 0)) + 1
				_face_hist["0"] = int(_face_hist["0"]) - 1

			# SP-6 / SP-3 — DESERT name remap, applied to the resolved tile id
			# BEFORE UV2.x. Donor _misc_SetDesert (miscext.script:1447-1502) is an
			# explicit per-case NAME remap, not a palette swap; SP-3's 11 direct
			# pairs are stored as source_index -> packed atlas index. The one
			# height-gated rock8 row is DATA_ONLY_NOT_EXECUTED (not loaded).
			# Indices stay inside the atlas, tileblock bytes are never mutated,
			# and DALPHA-02's shader keeps its index-preserving contract.
			# Runtime activity of the ';'-prefixed donor .inc lines UNVERIFIED.
			if season_is_desert and tiles_available and _desert_remap.has(tid):
				var remapped: int = int(_desert_remap[tid])
				if remapped >= 0 and remapped <= max_tile_id:
					tid = remapped
					_desert_remap_cells += 1

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
	# FIX-TERRAIN — EXPLICIT USER DECISION: a 640 x 640 m self-shadowing mesh
	# with a near-vertical sun produced unbounded directional streaks. The
	# tile-index ShaderMaterial is `unshaded`, so terrain receives no Godot
	# shadow map anyway; casting one only shaded OTHER objects. Keep it OFF
	# until a bounded donor-grounded shadow frustum is measured.
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	# SP-6 — stats provenance. Summer keeps the exact legacy note and values.
	var atlas_path_note: String = "V7-85 manifest; V7-91 loader transport"
	if not _season_fallback.is_empty():
		atlas_path_note = "SP-6 season fallback to V7-85; " + _season_fallback
	elif _season_resolved == "winter":
		atlas_path_note = "SP-4 winter manifest; SP-6 season selection"
	var season_entry: Dictionary = SEASON_ATLAS.get(_season_resolved, {})
	var season_enum: int = int(season_entry.get("enum", -1))
	stats = {
		"grid": {"w": w, "h": h, "cells": nverts},
		"tile_m": TILE_M,
		"height_scale": HEIGHT_SCALE,
		"height_min_m": hmin,
		"height_max_m": hmax,
		"height_range_m": hmax - hmin,
		# RELIEF-01 — auditable opt-in provenance. No stamp fires without a
		# dump["relief_stamps"] marker; the two coarse tables are derived
		# NUMBERS from DPATTERN-01 Appendix A, never donor bytes.
		"relief_grid": {
			"label": RELIEF_BLEND_LABEL,
			"blend_form": ("h = clamp(h + coarse[gy,gx]*HeightFieldScale, "
				+ "HeightFieldMin, HeightFieldMax) — PORT APPROXIMATION, "
				+ "engine Replace/Smooth/clamp order UNVERIFIED"),
			"tables": ["k_ravine_1 (DPATTERN-01 A1)", "plt2 (DPATTERN-01 A2)"],
			"coarse_size": [RELIEF_COARSE_W, RELIEF_COARSE_H],
			"source": "DPATTERN-01 Appendix A block-mean floats; no donor binary copied",
			"marker_field": "dump['relief_stamps'] (NOT in the current dump schema)",
			"applied": relief_applied,
			"stamps": _relief_applied.duplicate(true),
			"not_done": ["full 26-grid float32 tables", "mountain terrainmesh props",
				"exact donor engine blend", "2x collision sampler"],
		},
		"mesh_vertices": nverts,
		"mesh_triangles": ntris,
		"mesh_surfaces": mesh.get_surface_count(),
		"terrain_draw_calls_expected": 1,
		"normals": ("TRN-GEOM 1-cell forward difference on height[] (backward at last "
			+ "row/col); TILE_M=2.0 m donor-grounded by gc_meters_to_tile=2 "
			+ "(dmscript.global:171, DEC-05); no vertex/index change"),
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
		# SP-6 — selected manifest path; Summer resolves to the exact legacy string.
		"atlas_path": _season_manifest_path + " (" + atlas_path_note + ")",
		"uv_model": ("TRN-SHADER world-ground XZ texgen: eye_plane_s=(1,0,0,0) "
			+ "eye_plane_t=(0,0,1,0), identity texture_matrix, uv_repeat=(0.5,0.5) "
			+ "in terrain_tileindex.gdshader:120-122,211 — PORT APPROXIMATION, "
			+ "NOT donor parity: runtime gl_EyePlaneS/T[0] / TextureMatrix[0] remain "
			+ "engine-bound and CONFIRMED_UNVERIFIED (RV-TRN-01 verdict A)"),
		"face_model": ("UV2.y = donor cDiff1/cDiff2 slope + aspect axis "
			+ "(texturemap.inc:63-64,438-447,559-575) -> 0 ground / 1 front / 2 side; "
			+ "TRN-GEOM: promoted cells now select donor vf/vs atlas art and a "
			+ "25-degree normal tilt. Exact vf/vs PROMOTION rule ENGINE/UNVERIFIED "
			+ "(RV-TRN-01 verdict C) -> PORT APPROXIMATION, NOT DONOR PARITY"),
		# TRN-GEOM — auditable evidence ledger; no visual-parity claim.
		"face_tilt": {
			"vf": "AngleX=0 AngleZ=25",      # tiles.lib:119-296,543-719
			"vs": "AngleX=25 AngleZ=0",      # tiles.lib:119-296,543-719
			"deg": DONOR_FACE_TILT_DEG,
			"cite": "tiles.lib:119-296,543-719; tiles.mat:142-210; reftile.mat:120-170 (RV-TRN-01 §4.3)",
			"engine_path": "UNVERIFIED — no readable donor script selects vf/vs",
			"label": "PORT APPROXIMATION — normal tilt + vf/vs atlas cell; no mesh change",
			"cells": _face_tilt_cells,
		},
		"face_alpha_planes": {
			"front": "S=(1,0,0,0) T=(0,0,1,0)",
			"side": "S=(0,1,0,0) T=(0,0,1,0)",
			"scale": DONOR_FACE_SCALE,
			"cite": "reftile.mat:120-170 (RV-TRN-01 §4.3)",
			"status": ("ALREADY APPLIED in terrain_tileindex.gdshader:309-318 "
				+ "(shader has another owner; VERIFIED read-only, not re-edited here)"),
		},
		"rock_height_overrides": {
			"rock8_abs_h_gt": DONOR_ROCK8_H,
			"rock4_abs_h_gt": DONOR_ROCK4_H,
			"no_tile_abs_h_lt": DONOR_ROCK_NONE_H,
			"cite": "texturemap.inc:594-601 (DTRN-01 C13)",
			"cells": _rock_override_cells,
		},
		"sector_tiles": {
			"cliff": "texturemap.inc:559-591 (6-sector bRB/bLB/bR/bB/bT/bL -> rock7/1/3/4)",
			"shore": "texturemap.inc:463-472,474-529,503-511 (8 x 45 deg, vecangle+=180)",
			"atlas_ids": "sandsea1=93 sandsea5=97 sandsea6=98 (V7-85 manifest / 64² atoms)",
			"shore_cells_reoriented": _shore_sector_cells,
			"label": ("DONOR-GROUNDED name tables; PORT GATE uses height + live "
				+ "sandsea* family, not donor mask B (UNVERIFIED here)"),
		},
		# TRN-WATER handoff — no more BLK_WATER -> grass1 clamp.
		"water_shore_tiles": {
			"blk_water_sentinel": 255,       # game.gd:52
			"water_cells_remapped": _water_tile_cells,
			"no_aspect_fallback_cells": _water_fallback_cells,
			"fallback_tile": "sandsea1 (texturemap.inc:506/:509; PORT APPROX for flat water)",
			"cite": "DTRN_03 W2/F2; texturemap.inc:463-472,503-511; game.gd:52",
			"water_literals_untouched": [-0.25, -0.1, 2.96, 0.57, 1.07],
			"no_foam_or_new_texture": true,
		},
		"light_cols": {
			"ambient": [DONOR_AMBIENT.r, DONOR_AMBIENT.g, DONOR_AMBIENT.b],
			"diffuse": [DONOR_DIFFUSE.r, DONOR_DIFFUSE.g, DONOR_DIFFUSE.b],
			"specular": [DONOR_SPECULAR.r, DONOR_SPECULAR.g, DONOR_SPECULAR.b],
			"position": [SUN_POS.x, SUN_POS.y, SUN_POS.z],
			"cite": "data/env/lights/light.cfg:3-6,10-13,20-23,26-29 (DEC-03 §4.3)",
			"sky": "skydome.cfg:11-40 via DEC-03 §4.4; band->gradient mapping PORT APPROXIMATION",
			"fog": "OFF (FogMode=0, colors.lib:23,34-43; DTRN-01 C20)",
			"shadows": "OFF (explicit A/B decision; not re-enabled)",
			"shader": "ambient_rgb/diffuse_rgb/specular_rgb uniforms set (shader owner unchanged)",
		},
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
			# SP-6 — selected by season; Summer equals the legacy V785 path.
			"manifest": _season_manifest_path,
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
			"cell_size": ("variant3d/scripts/data.gd:23 C3Data.TILE_M=2.0; donor-grounded "
				+ "by gc_meters_to_tile=2 (dmscript.global:171, DEC-05)"),
			"sun_position": "data/env/lights/light.cfg:26-29 (SUN_POS, donor Z-up)",
			"sun_light_vector": "data/shaders/water/water.dev.vert:22 (x/4, z/2, y) then Z-up->Y-up",
			"ambient_diffuse": "data/env/lights/light.cfg:3-16 (Ambient/Diffuse literals)",
			"specular": "data/env/lights/light.cfg:20-23 (TRN-GEOM import)",
			"sky_bands": "data/env/skydome/skydome.cfg:11-40 via DEC-03 §4.4 (mapping APPROX)",
			"face_tilt": "data/terrain/tiles/tiles.lib:119-296,543-719 (AngleX/AngleZ=25 literals)",
			"face_planes_scale": "data/terrain/ref/reftile.mat:120-170 (S/T planes, TextureScale=0.125)",
			"cliff_shore_sectors": "data/scripts/common.inc/texturemap.inc:433-448,474-529,559-601",
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
		# --- SP-6 season selection (PORT APPROXIMATION; donor runtime UNVERIFIED) ---
		"season": {
			"selected": _season_resolved,
			"field": season,
			"biome": str(DATA_SCRIPT.BIOME),
			"enum": season_enum,
			"enum_note": ("summer=0 winter=2 desert=3 (data.gd:227 SEASON_ENUM); "
				+ "value 1 UNVERIFIED (dmscript.global:237 gc_MaxSeasonCount=3)"),
			"manifest_path": _season_manifest_path,
			"atlas_path": _season_atlas_path,
			"fallback": _season_fallback,
			"cite": ("terrain.lib:12-15; terrain.presets:2-6,134-263; "
				+ "texturemap.inc:525-526,605-606 (_winter); miscext.script:1429-1543 (desert)"),
			"label": ("PORT APPROXIMATION — donor set-swap INTENT; ';'-prefixed donor "
				+ ".inc runtime UNVERIFIED (SEASON_PLAN_01 B6, DENV-01 Q6)"),
		},
		"desert_remap": {
			"file": DESERT_REMAP_PATH,
			"direct_entries": _desert_remap_entries,
			"cells_remapped": _desert_remap_cells,
			"cite": ("miscext.script:1447-1502 (11 direct pairs); rock8 :1504-1505 "
				+ "DATA_ONLY_NOT_EXECUTED"),
			"height_koef": ("0.8 DATA_ONLY_NOT_EXECUTED (miscext.script:1513-1520; "
				+ "SP-6 is index-only)"),
			"label": ("DONOR INTENT / PORT APPROXIMATION — runtime UNVERIFIED; "
				+ "tileblock bytes unchanged, DALPHA-02 shader untouched"),
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
