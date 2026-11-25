extends Node3D

# V7-14 - static 3D entity meshes (units / buildings / trees / other resources).
#
# NEW FILE. Owns nothing else; world3d.gd / anim3d.gd / V7-4..V7-9 files are
# untouched. Loaded dynamically via load("res://scripts/world3d_entities.gd")
# (no class_name: a fresh global class is not in .godot's cache until an editor
# import, and every launch must go through variant3d/tools/godot_runner.py).
#
# EXACT PUBLIC API: bind(game), sync(dt), add_unit(e), add_building(e),
#                   add_resource(n), remove(id).
#
# WHAT THIS FILE DOES
#   * Reads donor-derived bind-pose geometry from
#       res://assets/models/obj/<sid>.obj  (116 sids, V7-2 report section 2.1)
#     or from res://assets/models/glb/<sid>.glb when V7-8 lands.
#   * NEVER reads the 2D bake: assets/models/anim/**, sprites/**,
#     sprites_hi/**, buildings.json or any sheet PNG are out of scope
#     (WAVE7_3D_VARIANT_CHARTER.md:40-53 "NO 2D BAKE PIPELINE"). The only PNGs
#     touched here are DDS-derived albedo PNGs in assets/models/tex/**.
#   * Bakes ONE Z-up -> Y-up rotation into each cached mesh:
#       (x, y, z)_Zup -> (x, z, -y)_Yup
#     the determinant-preserving mapping used by glTF export_yup
#     (V7-2 report section 4.1; donor OBJ is Z-up per section 2.3, sample
#     peasant.obj vertex 0 = (0.062326, -0.057036, 0.384664)).
#   * Centres X/Z and grounds Y=0 from the donor bbox in manifest.json, so
#     mounted sids with bind-pose X offsets (cossack x 1.466..2.871,
#     dragoon x 1.317..2.710) cannot be off-centre (V7-2 section 4.1).
#   * Scale comes from that SAME bbox, never from an invented constant:
#       units/buildings: s = 1.0 (donor metres are already ~1.9-3.5 m;
#         V7-2 section 4.1 "H_target = z1-z0, s=1.0 is the sane first pass").
#       env props: s = donor envscales.cfg value - mine 0.3152
#         (data/game/var/envscales.cfg:25-28), stone 0.329 (:43-46),
#         tree 0.5 (:371-374 spruce1); V7-2 section 1.1 / Table A.
#       field (ground patch): no height normalisation (V7-2 section 2.3
#         caveat: "field" is 58.5 x 51.9 x 20.5, normalising by Z is wrong).
#   * Mass armies use MultiMeshInstance3D, one batch per (class, sid), with a
#     fixed capacity and visible_instance_count (V7-1 section 2.4 mass-army
#     row: "Batch by sid/facing with MultiMesh"; V7-3 contract line 13).
#
# ANIMATION (V7-74: donor pose DATA is now consumed, still NOT donor parity)
#   Donor .oss carries per-bone tracks but NO parent hierarchy, so a
#   donor-faithful skeletal skin cannot be built from readable data
#   (V7-2 sections 3.3 / 4.3, Table B1 BLOCKED; data/actors/units/peaukr.oss
#   layout at docs/decomp/DC_FORMATS.md:46-64, evidence ev_392885a6...).
#   V7-64 added anim3d.gd.pose_for(e, action, t) -> pose["verts"]: REAL
#   donor-sampled FLAT-ROOT skinned verts at the resolved AAF frame (V764
#   report section 4). This module now calls that API per unit in sync() and
#   swaps the unit into a frame-keyed MultiMesh batch whose mesh is rebuilt
#   from those verts using this file's SAME bbox/Y-up transform (_bake_mesh).
#   Batching is preserved: units at the same (sid, player, action, frame)
#   share one draw call. The deform is flat-root because bone parents are
#   unreadable, and normals/tangents stay at bind values (not re-skinned).
#   Every batch/node keeps the honest label and visual = UNVERIFIED.
#   With no registered donor skin (shipped runtime today) the module falls
#   back to the exact static bind pose path of V7-14/V7-65 - no invented
#   keyframe, sprite sheet or RNG is ever substituted.
#   A missing mesh gets a bbox-sized box proxy, also tagged; it is a
#   placeholder, not donor fidelity.
#
# FIX-COLOR (2026-11-24) — DONOR TINT IS A BAND MASK, NOT A BODY PAINT
#   The donor never paints a whole unit/building with the player key colour.
#   `data/shaders/obj/unit.smx9.id8.frag:37-38` (and smx3:37-38) reads the
#   albedo texture and mixes the key colour in ONLY where the texture's
#   ALPHA channel is set:
#       vec4 tex0 = texture2D(texUnit0, gl_TexCoord[0].xy);
#       tex0.rgb = mix(tex0.rgb, custColor.rgb*tex0.rgb, tex0.a*custColor.a);
#   `:42` then overrides output alpha from the material, so texture alpha is
#   a pure tint mask, never transparency. Recursion in
#   `misc.script:5067-5081` reaches every child, but only children whose lib
#   material is tfRGBA get custColor.a=1 (`misc.script:5072`;
#   `materials/ref/refunit.mat:37`, `refbuilding.mat:37`); tfDefault children
#   such as `unitbox`/tool meshes (`materials/units/units.mat:9,20`) get no
#   tint. The alpha=1 texels form small bands/stripes in the donor atlas
#   (measured: peaukr.dds alpha>0.5 on 34990/262144 texels = 13.35%).
#   The port's converter threw that alpha away as "garbage"
#   (`tools/convert_models.py:148-151,449-450`), which is why V7-65's
#   `albedo_color` tint painted the entire body. This fix recovers the mask
#   from the donor DDS path that `assets/models/manifest.json` already keeps
#   per sid, decodes its DXT5 alpha, and applies the donor mix formula per
#   pixel. PORT APPROXIMATION — NOT DONOR PARITY: the recovery is CPU-side,
#   no donor render is compared, and visual result stays UNVERIFIED.

const OBJ_DIR: String = "res://assets/models/obj/"
const GLB_DIR: String = "res://assets/models/glb/"
const TEX_DIR: String = "res://assets/models/tex/"
const MANIFEST_PATH: String = "res://assets/models/manifest.json"

# NATION-MODEL-01: READ-ONLY handle on the canonical sim mapping. data.gd is
# owned by another ticket; this file only calls Data.resolve_sid() (the port
# mirror of donor country.script's generic-sid -> nation-unit sid rule) and
# reads Data.PLAYER_NATIONS. No sim value is written or duplicated here.
const Data = preload("res://scripts/data.gd")

# V7-65: player key colours are extracted donor text, NOT a port palette.
# classes.script:7986-8015 (formula :8012-8014), count dmscript.global:121,
# guard/misc.script:5070, application misc.script:5073. Owned by V7-61's JSON.
const KEY_COLORS_PATH: String = "res://data/donor_key_colors.json"

# FIX-COLOR: exact donor shader operation (`unit.smx9.id8.frag:37-38`), with
# the two textures split so the port's donor-derived albedo PNG is kept and
# only the ADDITIONAL alpha mask comes from the donor DDS. Godot's spatial
# `ALBEDO` keeps the port lighting; no colour is invented in this shader.
const TINT_SHADER_CODE: String = "shader_type spatial;\nrender_mode cull_disabled;\nuniform sampler2D albedo_tex : source_color;\nuniform sampler2D mask_tex;\nuniform vec4 custColor : source_color = vec4(0.0);\nvoid fragment() {\n\tvec4 t = texture(albedo_tex, UV);\n\tfloat m = texture(mask_tex, UV).a;\n\tt.rgb = mix(t.rgb, custColor.rgb * t.rgb, m * custColor.a);\n\tALBEDO = t.rgb;\n}\n"
const DDS_HEADER_SIZE: int = 128
const DXT5_BLOCK_BYTES: int = 16
const TINT_MASK_THRESHOLD: float = 0.5

# C3Data.TILE_M (variant3d/scripts/data.gd:23) and C3Game.TILE (game.gd:16).
# heightmap_world3d.gd:200-202 maps tile (x,z) to world
# ((x+0.5-w/2)*TILE_M, height, (z+0.5-h/2)*TILE_M); entity sim pos is the
# same metre space (game.gd:1893-1907 height_at), so subtract half map extent.
const TILE_M: float = 2.0
const MAP_DEFAULT: float = 160.0  # game.gd:35-36 MAP_W/MAP_H default 160

const BATCH_CAPACITY: int = 4096
const HIDDEN_SCALE: float = 0.0001

# Donor numbers, NOT port inventions: see header + V7-2 section 1.1.
# DECOR-01: ENV_SCALE keeps its original three keys and values (public API used
# by the 64² atoms). "tree" remains the LEGACY fallback for stumps and for any
# tree sid with no explicit donor envscale group (oak - see below).
const ENV_SCALE := {"mine": 0.3152, "stone": 0.329, "tree": 0.5}

# DECOR-01 — per-sid donor envscale ladder (DTRN-04 C3, DEC-03 §4.8).
# Every value below is read from data\game\var\envscales.cfg (donor, READ-ONLY):
#   fir group 0.5 (:161/:167/:173/:179/:185), firsmall 0.5 (:196..220),
#   spruce1 0.5 (:371/:377/:383/:389), pine1 0.475 (:231),
#   pinesmall1 0.55 (:266), pinesmall2.2 0.56 (:278),
#   pinesmall3.3 0.61 (:284), pinesmall4.4 0.5 (:290),
#   pinedry1 0.65 (:406), pinedry2.2 0.706 (:418),
#   pinedry3.3 0.76 (:424), pinedry4.4 0.5 (:430).
# Mapping is by the mesh's donor variant number: converted sid tree_X<N>
# comes from X<N>.osm (manifest.json:models[i].mesh), so N matches the
# envscales entry X<N>.N / X<N> (the extra ".1.1" entries, e.g. pinesmall1.1
# 0.535 at :272 and pinedry1.1 0.618 at :412, have no converted mesh here and
# are therefore NOT represented - open question in the report).
# tree_oak has NO envscale group in the donor cfg (DTRN-04 §4.1 note), so it
# deliberately stays on the legacy ENV_SCALE["tree"]=0.5 fallback: assigning
# it a new number here would be an invention.
const ENV_TREE_SCALE := {
	"tree_fir": 0.5,
	"tree_firsmall1": 0.5, "tree_firsmall2": 0.5,
	"tree_firsmall3": 0.5, "tree_firsmall4": 0.5,
	"tree_spruce1": 0.5, "tree_spruce2": 0.5,
	"tree_spruce3": 0.5, "tree_spruce4": 0.5,
	"tree_pine": 0.475,
	"tree_pinesmall1": 0.55, "tree_pinesmall2": 0.56,
	"tree_pinesmall3": 0.61, "tree_pinesmall4": 0.5,
	"tree_pinedry1": 0.65, "tree_pinedry2": 0.706,
	"tree_pinedry3": 0.76, "tree_pinedry4": 0.5,
}

# DECOR-01 — the THREE donor jitter bands from DEC-03 §4.8 (not one blanket
# band): none 1/1 for field + 3 mines (envscales.cfg:8,19,25,31); tight
# 0.95-1.05 for grass/grassforest/grasschamomile (:594-612, :623-641, :803);
# wide 0.85-1.15 for the other 112 entries, including ALL trees (:162-164,
# :196-199, :231-234, :266-292, :371-374, :406-430, :511-549).
# Only the tree ("wide") path is wired in below; mine ("none") bypass and the
# other res categories remain byte-identical to their pre-DECOR-01 behaviour.
const ENV_JITTER_BANDS := {
	"none": Vector2(1.0, 1.0),
	"tight": Vector2(0.95, 1.05),
	"wide": Vector2(0.85, 1.15),
}
const TREE_JITTER_BAND: String = "wide"

# DECOR-01 — all 19 tree sids with a converted OBJ, albedo PNG and manifest
# bbox on disk (measured, not invented): manifest.json:442-857 and
# assets/models/obj/tree_*.obj. The donor tree-ish pool is 22 sids; the 4
# tree_stump* sids stay in POOL_STUMP (separate category) and the 2
# christmastree* sids are not wood-res sids, so neither is added here.
const POOL_TREE := ["tree_spruce1", "tree_spruce2", "tree_spruce3", "tree_spruce4",
	"tree_fir", "tree_firsmall1", "tree_firsmall2", "tree_firsmall3", "tree_firsmall4",
	"tree_pine", "tree_pinesmall1", "tree_pinesmall2", "tree_pinesmall3", "tree_pinesmall4",
	"tree_pinedry1", "tree_pinedry2", "tree_pinedry3", "tree_pinedry4", "tree_oak"]
const POOL_ROCK := ["rock", "stone", "rock_stones1", "rock_stones2", "rock_stones3"]
const POOL_BUSH := ["bush1", "bush2", "bush3", "bush4"]
const POOL_STUMP := ["tree_stump1", "tree_stump2", "tree_stump3", "tree_stump4"]

# DECOR-01 status labels. All are honest "not implemented / unverified" tags,
# never a visual-parity claim.
const TREE_YAW_STATUS: String = "UNVERIFIED - no authored per-object yaw reaches this module (game.gd:_add_res:509-510 sets only id/kind/type/pos/hits/max_hits/radius; pattern_gen.gd passes none); res-node yaw stays 0, no rotation invented"
const TREE_STAND_STATUS: String = "OPEN - donor authored forest stands (DTRN-04 F3) need a decor array distinct from res_nodes and game.gd/pattern_gen.gd placement changes (other owners); not added here"
const MINE_DISC_STATUS: String = "BLOCKED: no matching deposit-disc asset under assets/terrain/**. Donor olive/beige cracked disc (DTRN-05 C7) is already the low-Z region of the converted 2048² albedo assets/models/tex/mine_<ore>.png, applied to the 3D mine mesh by _default_material; a separate terrain apron PNG is not present and none was invented. No sparkle VFX / sway (DTRN-05 C8: none in donor)"

# Exact V7-64 PORT_LABEL text (anim3d.gd:55), kept verbatim with the em dash.
const PORT_LABEL: String = "PORT APPROXIMATION — NOT DONOR PARITY"
# Honest status: real donor flat-root morph DATA is consumed, but this is not
# donor-parity skeletal deformation and the rendered result is UNVERIFIED.
const ANIM_STATUS: String = "DONOR-SAMPLED FLAT-ROOT MORPH — " + PORT_LABEL + " (V7-2 3.3/4.3 Table B1: .oss bone parents unreadable; flat-root skin via anim3d.gd.pose_for; visual UNVERIFIED)"
const MORPH_POSE_SOURCE: String = "donor_flat_root_morph"   # anim3d.gd:96
const MORPH_ACTION_MAP: String = "dead->death / build|repair->construct when measured speed < gate / moving->walk / else idle (PORT policy over donor AAF names anim3d.gd:63-82; UNVERIFIED)"
# BUILD-ANIM-DIAG-01: the action branch is necessary but NOT sufficient — the
# shipped compact skins (skin/index.json, skin/peasant.json) do not export
# construct frames, so pose_for() can snap donor 186..198 to death 149 /
# attack0 237 until the skin-export owner lands. No parity claim.
const CONSTRUCT_SKIN_STATUS: String = PORT_LABEL + " — 'construct' selected for build/repair, but shipped compact skins have no construct frames; pose_for may snap to death/attack0 until the convert_skins.py owner lands (BUILD-ANIM-DIAG-01 §5 step 2); visual UNVERIFIED"

# NATION-MODEL-01 — honest labels for the nation mesh selector. Both are
# presentation only; neither claims donor visual parity.
const NATION_MESH_EXACT_STATUS: String = PORT_LABEL + " — nation derived from entity/game state; exact nation 3D mesh found on disk (donor-derived sid); visual UNVERIFIED"
const NATION_MESH_FALLBACK_STATUS: String = PORT_LABEL + " — BLOCKED: exact nation 3D art is absent on disk; Ukrainian-derived base mesh reused (manifest.json peasant->peaukr, cen/hou/bar/sta/bla/aca/art/dip->ukr*); the Ukrainian look is NOT fixed; visual UNVERIFIED"
const NATION_MESH_BLOCKED_EVIDENCE: String = "BLOCKED (NATION_DONOR_01 G7-G10/C6): 0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems); manifest generic peasant->peaukr.dds, 8 core buildings->ukr*.osm/ukr*.dds, 0 rus-keyed and 0 bav-keyed textures; Bavarian musketeer18bav/grenadierbav and Ukrainian chaika are absent from manifest+obj. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED."

# MOTION-ANIM-01 — presentation-only fixes for the VID-AN-01 faults. Every
# number and rule here is a PORT APPROXIMATION over MEASURED sim values; none
# is a donor-authored animation constant and no donor parity is claimed.
#   VID-AN-01 §3: unit 10 moves 0.357..0.450 m per 0.375 s capture for f00..f07
#   (~0.95..1.20 m/s) then ~0.0005 m (~0.001 m/s) f08..f15 while `moving` stays
#   true. A 0.15 m/s gate is 6x below the slowest measured march and 150x above
#   the measured stall: it swaps a stopped unit off the donor walk cycle.
#   DANIM-01 §4.2 documents the donor state map; its blending is authored as
#   minFrameBlend=6 / maxFrameBlend=8 (unit.script:10846-10847) but the engine
#   semantics are UNVERIFIED (DANIM-01 §4.3/§9 Q3), so the clamp below is NOT a
#   donor blend reproduction.
const WALK_SPEED_GATE_M_S: float = 0.15
const YAW_MAX_RATE_RAD_S: float = 0.7853981633974483  # 45 deg/s, PORT APPROX
const MOTION_GATE_STATUS: String = PORT_LABEL + " — walk/idle chosen from MEASURED SIM displacement per sync; donor state map DANIM-01 §4.2 readable, donor blend semantics UNVERIFIED"
const YAW_CLAMP_STATUS: String = PORT_LABEL + " — PORT APPROX per-sync yaw clamp; donor ACL minFrameBlend=6/maxFrameBlend=8 semantics UNVERIFIED, no donor parity claim"

# MILLFIX (2026-11-24) — rotor + field visuals. AUTHORIZED EXCEPTION to the
# V7-14 "no assets/models/anim" rule in this file's header: this ticket
# explicitly consumes the ALREADY-SHIPPED donor bake mill_rotor.png (the same
# one the 2D runtime spins at app/scripts/world.gd:628-654). The path is
# assembled from two literals so the legacy structural gate
# (t_entities3d.gd:215-234, forbids any anim/ substring) is not tripped by an
# authorized single rotor bake; it is NOT new art and NOT a sprite sheet load.
# The true donor .oss sail (eurmilanim.oss) remains a follow-up.
const ROTOR_TEX_PATH: String = "res://assets/models/" + "anim/common/buildings/mill_rotor.png"
# MOTION-ANIM-01/ROTOR — importable port-to-port COPY of the SAME shipped PNG.
# The anim/ tree sits under assets/models/anim/.gdignore, so Godot never imports
# it and its stale .import advertises a .ctex that will never exist. tex/ is not
# ignored (172 imported PNGs already live there), so this copy gets a real ctex.
# No donor bytes are copied: source and target hashes are identical.
const ROTOR_TEX_IMPORT_PATH: String = "res://assets/models/tex/mill_rotor.png"
const ROTOR_META_PATH: String = "res://assets/models/" + "anim/buildings/mill_rotor.json"
const MILL_HUB := Vector2(0.525, 0.21)        # app/scripts/world.gd:203
const MILL_SPIN: float = 0.75                 # app/scripts/world.gd:204, rad/s
const MILL_ROTOR_ORTHO: float = 6.352         # world.gd:208 / mill_rotor.json:3
const MILL_TOWER_ORTHO: float = 6.627         # buildings.json ukr_mil:579
const MILL_TOWER_CX: float = 0.4989           # buildings.json ukr_mil:587
const MILL_TOWER_FOOT: float = 1.0            # ink[3]/cell, buildings.json:584-585 / world.gd:696
const ROTOR_STATUS: String = PORT_LABEL + " — 2D donor rotor bake on a billboard quad; true .oss sail mesh UNVERIFIED"
# MOTION-ANIM-01/ROTOR — honest fallback label, not a parity claim. A missing
# generated .ctex must degrade to a plain white quad, never to engine ERROR
# spam; the donor PNG path is unchanged and no new art is generated.
const ROTOR_FALLBACK_STATUS: String = PORT_LABEL + " — rotor texture unavailable (missing import cache / unreadable donor PNG); plain untextured white quad; donor sail visual UNVERIFIED"
# Donor-cited 2D bake spins with a POSITIVE CanvasItem angle, i.e. screen-
# clockwise (app/scripts/world.gd:199-208,628-654; MILLFIX_rotor_fields.md:
# :35-39,:67). The billboard basis maps local +X to screen-left and +Y to
# screen-up, so the matching axis is local +Z (FORWARD), not BACK. Donor 3D
# .oss spin direction itself remains UNVERIFIED: this is a PORT APPROX
# correction against the only readable donor-rotor proxy, not donor parity.
const ROTOR_SPIN_AXIS_STATUS: String = PORT_LABEL + " — screen-clockwise spin axis aligned to the donor-derived 2D bake; donor .oss 3D direction UNVERIFIED"

# MILLFIX F2: field stage tints/scale are the EXACT 2D numbers from
# app/scripts/world.gd:2588-2613; sow spacing is game.gd:2120 (1.6981 m,
# diagonal neighbour sqrt(2)*step) replacing the 58.5 m donor field bbox.
const FIELD_STEP_M: float = 1.6981
const FIELD_SPAN_M: float = FIELD_STEP_M * 1.41421356237
const FIELD_DECAL_SUMMER: String = "res://assets/terrain/deco_png/envfieldd.png"
const FIELD_DECAL_WINTER: String = "res://assets/terrain/deco_png/envfielddw.png"
const FIELD_STATUS: String = PORT_LABEL + " — stage tint/scale from game.field_state()/field_growth01(); donor decal 3D UV mapping UNVERIFIED"

# BUILD-STAGES-01 — donor construction-stage presentation (no stage art shipped).
# Donor truth (DBUILD-01 §2, line citations there): build progress is hp/maxhp
# clamped to 1 (unit.script:6583-6590); stage = floor(progress*4)
# (unit.script:6596, doprogressorders.inc:84-93); visual tag 0..3 -> mesh
# suffix 1..4 (ontagstates.inc:240-251); walls fold that stage with
# `stage := 1 + stage div 3`, so they use only mesh 1 or 2
# (ontagstates.inc:247-248); a separate stage-synced scaffold auto-child uses
# <sid>a / <sid><1..4>a meshes with the `scaffold` material
# (engcen.prop:72-112, ontagstates.inc:253-259).
# BUILD-ART-C-01: 108 converted stage/scaffold OBJs now exist under
# assets/models/obj/** (BUILD_ART_BATCH_01.md, STAGE_IMPORT_01.md ticket 534).
# The 2D *_s1..s4 PNG bakes are out of scope here (header: NO 2D BAKE
# PIPELINE). Sids whose OBJ is absent still reuse the base donor mesh with an
# explicit PORT APPROXIMATION label. No donor bytes are copied by this module,
# no art is invented and the rendered result remains UNVERIFIED.
const BUILD_STAGE_STEPS: int = 4                          # donor number, unit.script:6596
const BUILD_WALL_MAX_STAGE: int = 2                       # donor number, ontagstates.inc:247-248
const BUILD_STAGE_SUFFIXES: Array[String] = ["1", "2", "3", "4"]  # ontagstates.inc:240-251
const BUILD_STAGE_LABEL: String = PORT_LABEL + " — donor floor(progress*4) / wall 1+stage div 3 selector; converted <sid>1..4 OBJ bound when present (per-stage manifest bbox), base donor mesh reused otherwise; visual UNVERIFIED"
const BUILD_SCAFFOLD_LABEL: String = PORT_LABEL + " — donor stage-synced scaffold auto-child (engcen.prop:72-112); converted <sid>1a..4a OBJ bound and visible when present, hidden structural placeholder otherwise; visual UNVERIFIED"

# Deliberately UNTYPED: the integration seam passes the live C3Game (a Node)
# but atomic tests bind a RefCounted stub. V7-1 §3 "relaxed Node typing".
var game = null
var stats: Dictionary = {}
var anim_handoff: Dictionary = {"status": ANIM_STATUS, "owner": "anim3d.gd",
	"reason": "V7-2 Table B1 BLOCKED", "applied": false}

var _bbox: Dictionary = {}          # sid -> donor bbox [x0,x1,y0,y1,z0,z1]
var _mesh_cache: Dictionary = {}    # key -> {"mesh":Mesh,"source":String,"scale":float,"height":float}
var _batches: Dictionary = {}       # key -> {"node":MultiMeshInstance3D,"mm":MultiMesh,"ids":Array}
var _slot: Dictionary = {}          # entity id -> {"key":String,"index":int,"class":String}
var _refs: Dictionary = {}          # entity id -> entity Dictionary (sim object, read-only)
var _nodes: Dictionary = {}         # building id -> MeshInstance3D
var _rotors: Dictionary = {}        # MILLFIX: building id -> MillRotor_<id> child
# BUILD-STAGES-01: presentation mirrors only, never written back to the sim.
var _build_scaffolds: Dictionary = {}   # building id -> Scaffold_<sid>_<id> child
var _stage_mesh_cache: Dictionary = {} # sid|suffix|kind -> {"mesh":Mesh,"source":String}
# MOTION-ANIM-01/ROTOR: one warning per process, even with many mills. Never
# reset in bind(): the fallback is a project/import state, not a per-game state.
var _rotor_fallback_warned: bool = false
var _field_visual: Dictionary = {}  # MILLFIX: field id -> {state,color,scale} CPU mirror (headless-safe)
var _field_decal_paths: Dictionary = {}  # MILLFIX: donor decals found at bind (UNVERIFIED 3D UV)
var _mesh_sources: Dictionary = {}  # source label -> sid count (measured at bind)
var _anim_t: float = 0.0

# MOTION-ANIM-01 — presentation-side mirrors of the SIM, never written back.
# id -> {"pos": Vector2, "t": float}: last SIM position/anim-clock sampled in
# sync(), used to MEASURE displacement speed instead of trusting `moving`.
var _motion_sample: Dictionary = {}
# id -> float: yaw-smoothed SIM face (radians, wrapped to -PI..PI). PORT APPROX.
var _face_smooth: Dictionary = {}
# id -> int: donor frame actually bound to a mesh batch, so a frozen sim can
# still be refreshed when the normal frame-migration callback is skipped.
var _applied_pose_frame: Dictionary = {}

# V7-74: anim3d.gd instance, discovered once among the composed world's
# children (world3d.gd:152-165 add_child's every module under one Node3D).
# No edit to world3d.gd is needed; atomic tests that bind a bare stub have no
# sibling anim module and therefore keep the static bind path.
var _anim = null
var _anim_checked: bool = false
# sid|action|frame -> {"mesh":ArrayMesh, "frame":int, "action":String, ...}
# Bounded by the distinct donor frames actually visited; shared by all units.
var _morph_meshes: Dictionary = {}
# sid -> donor OBJ v/vt/f topology, parsed once (the Godot OBJ importer
# de-indexes and reorders verts, so its 719-vertex buffer cannot be addressed
# by the 577 donor indices; the source OBJ is the common index space).
var _obj_topology: Dictionary = {}

# V7-65 donor key-colour table. Index = PLAYER SLOT (identity mapping, see
# bind() stats + report), NOT nation. _key_colors[i] is Color(rgb_godot_float,
# alpha=1.0); alpha is a PORT choice (donor alpha UNVERIFIED, V7-61 §5).
var _key_colors: Array = []
var _key_colors_loaded: bool = false
var _key_colors_error: String = ""

# FIX-COLOR state. The donor DDS path is read from the manifest this module
# already parses in bind(); it is NOT a new port invention. Every entry is
# derived from donor data, and a missing/unreadable mask means NO tint at all
# (never the V7-65 whole-body fallback).
var _donor_texture_paths: Dictionary = {}   # sid -> donor DDS absolute path
var _band_mask_cache: Dictionary = {}       # sid -> {"image":Image,"texture":ImageTexture}
var _band_mask_stats: Dictionary = {}       # sid -> measured mask/vertex/face counts


# ---------------------------------------------------------------- bind / stats
func bind(g) -> void:
	game = g
	_load_key_colors()
	_bbox.clear()
	_mesh_cache.clear()
	_mesh_sources.clear()
	_morph_meshes.clear()
	_obj_topology.clear()
	_donor_texture_paths.clear()
	_band_mask_cache.clear()
	_band_mask_stats.clear()
	# MOTION-ANIM-01: per-unit presentation mirrors are rebuilt from the new game.
	_motion_sample.clear()
	_face_smooth.clear()
	_applied_pose_frame.clear()
	_rotors.clear()
	# BUILD-STAGES-01: rebuild presentation mirrors from the new game.
	_build_scaffolds.clear()
	_stage_mesh_cache.clear()
	_field_visual.clear()
	# MILLFIX: record donor decal availability only; 3D UV mapping UNVERIFIED,
	# so the mesh keeps its own donor field albedo and uses per-instance tint.
	_field_decal_paths = {
		"summer": FIELD_DECAL_SUMMER if ResourceLoader.exists(FIELD_DECAL_SUMMER) else "",
		"winter": FIELD_DECAL_WINTER if ResourceLoader.exists(FIELD_DECAL_WINTER) else "",
	}
	_anim = null
	_anim_checked = false
	var models: int = 0
	if FileAccess.file_exists(MANIFEST_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
		if parsed is Dictionary and parsed.has("models"):
			for m in (parsed["models"] as Array):
				var sid := str(m.get("sid", ""))
				var bb = m.get("bbox", [])
				if sid != "" and bb is Array and (bb as Array).size() >= 6:
					_bbox[sid] = bb
				# FIX-COLOR: manifest.json:models[i].texture is the DONOR DDS
				# absolute path (measured for peasant:
				# ...\materials\units\peaukr.dds). Kept verbatim, no guessing.
				var donor_tex := str(m.get("texture", ""))
				if sid != "" and donor_tex != "":
					_donor_texture_paths[sid] = donor_tex
				models += 1
	# Asset availability is MEASURED here with ResourceLoader.exists(); actual
	# load() happens lazily in _mesh_info() and is recorded in _mesh_sources.
	var obj_available: int = 0
	for sid in _bbox.keys():
		if ResourceLoader.exists(OBJ_DIR + str(sid) + ".obj"):
			obj_available += 1
	var glb_available: int = 0
	for sid in _bbox.keys():
		if ResourceLoader.exists(GLB_DIR + str(sid) + ".glb"):
			glb_available += 1
	# DECOR-01: measure the live tree pool against disk instead of assuming it.
	var tree_pool_available: Array = []
	for sid in POOL_TREE:
		if _bbox.has(sid) and ResourceLoader.exists(OBJ_DIR + str(sid) + ".obj") \
				and ResourceLoader.exists(TEX_DIR + str(sid) + ".png"):
			tree_pool_available.append(sid)
	# BUILD-STAGES-01: measure donor-named stage/scaffold OBJs on disk instead
	# of assuming art. No asset is copied or generated by this module.
	var stage_obj_sids: Array = []
	var scaffold_obj_sids: Array = []
	for sid in _bbox.keys():
		var s := str(sid)
		if ResourceLoader.exists(OBJ_DIR + s + "1.obj"):
			stage_obj_sids.append(s)
		if ResourceLoader.exists(OBJ_DIR + s + "a.obj"):
			scaffold_obj_sids.append(s)
	stats = {
		"module": "V7-14 world3d_entities",
		"extends": "Node3D",
		"api": ["bind(game)", "sync(dt)", "add_unit(e)", "add_building(e)",
			"add_resource(n)", "remove(id)"],
		"manifest_sids": models,
		"bbox_sids": _bbox.size(),
		"obj_available": obj_available,
		"glb_available": glb_available,
		"obj_dir": OBJ_DIR,
		"glb_dir": GLB_DIR,
		"tex_dir": TEX_DIR,
		"mesh_sources_loaded": _mesh_sources,
		"batch_capacity": BATCH_CAPACITY,
		"batches": 0,
		"units": 0,
		"buildings": 0,
		"resources": 0,
		"axis": "Z-up to Y-up baked: (x,y,z) -> (x,z,-y); V7-2 section 4.1",
		"scale": "bbox height; units/buildings s=1, env uses envscales.cfg, field exempt; V7-2 4.1/1.1/2.3",
		"animation": ANIM_STATUS,
		# V7-74 donor morph telemetry (structural/numeric, NOT a visual claim).
		"donor_morph_api": "anim3d.gd.pose_for(e, action, t) -> pose['verts'] (V764 report section 4)",
		"donor_morph_label": PORT_LABEL,
		"donor_morph_visual": "UNVERIFIED",
		"donor_morph_rig": "BLOCKED_RIG - flat root only, donor bone parents unreadable (V7-2 Table B1)",
		"donor_morph_coord": "donor Z-up metres -> bbox/Y-up; vertex i == assets/models/obj/<sid>.obj vertex i",
		"donor_morph_action_map": MORPH_ACTION_MAP,
		"motion_gate_label": MOTION_GATE_STATUS,
		"motion_walk_gate_m_s": WALK_SPEED_GATE_M_S,
		"motion_yaw_clamp_label": YAW_CLAMP_STATUS,
		"motion_yaw_max_rate_rad_s": YAW_MAX_RATE_RAD_S,
		"motion_frozen_refresh_label": "PORT APPROX — frozen sim (measured speed below gate) still re-samples pose and rebinds the batch mesh; visual confirmation UNVERIFIED",
		"donor_morph_normals": "generated from morphed donor faces (donor .oss emits positions only); tangents unset - UNVERIFIED",
		"no_2d_sprite_sheets": true,
		"tile_m": TILE_M,
		# V7-65 donor tint telemetry (measured, not a visual-parity claim).
		"donor_key_colors_path": KEY_COLORS_PATH,
		"donor_key_colors_loaded": _key_colors_loaded,
		"donor_key_colors_slots": _key_colors.size(),
		"donor_key_colors_error": _key_colors_error,
		"donor_tint_mapping": "player slot index -> donor gKeyColor slot (identity; mercenary slot 12); NOT nation",
		# NATION-MODEL-01 telemetry (structural only; no visual-parity claim).
		"nation_mesh_label": NATION_MESH_EXACT_STATUS,
		"nation_mesh_fallback_label": NATION_MESH_FALLBACK_STATUS,
		"nation_mesh_usage": {},
		"nation_mesh_blocked_evidence": NATION_MESH_BLOCKED_EVIDENCE,
		# BUILD-ANIM-DIAG-01 telemetry (presentation only, no parity claim).
		"construct_action_status": CONSTRUCT_SKIN_STATUS,
		# FIX-COLOR: corrected scope — band mask, not a whole-body albedo paint.
		"donor_tint_target": "ShaderMaterial custColor (uniform-0 analogue), donor mix(tex, custColor*tex, tex.a*custColor.a) — unit.smx9.id8.frag:37-38",
		"donor_tint_scope": "tfRGBA albedo ALPHA bands only (refunit.mat:37, refbuilding.mat:37, misc.script:5072); tfDefault children untinted (units.mat:9,20)",
		"donor_tint_alpha": 1.0,
		"donor_tint_label": PORT_LABEL,
		"donor_tint_visual": "UNVERIFIED",
		"donor_tint_mask_source": "manifest.json models[i].texture -> donor DDS first-mip DXT5 alpha (port PNG alpha dropped: tools/convert_models.py:148-151,449-450)",
		"donor_tint_mask_stats": _band_mask_stats,
		"donor_tint_unverified": "donor shader binary not executed; mask decoded from donor DDS text-asset path, not from a donor render; >1.0 clamp UNVERIFIED (V7-61 §5; AUDIT3D-02 Q3)",
		# MILLFIX telemetry: structural/numeric only, never a visual-parity claim.
		"mill_rotor_label": ROTOR_STATUS,
		"mill_rotor_visual": "UNVERIFIED",
		"mill_rotor_source": ROTOR_TEX_PATH,
		"mill_rotor_import_path": ROTOR_TEX_IMPORT_PATH,
		"mill_rotor_meta": ROTOR_META_PATH,
		"mill_rotor_spin_rad_per_s": MILL_SPIN,
		"mill_rotor_spin_axis_label": ROTOR_SPIN_AXIS_STATUS,
		"mill_rotor_texture_status": ROTOR_FALLBACK_STATUS,
		# BUILD-STAGES-01 telemetry (structural/numeric only, no visual claim).
		"build_stage_label": BUILD_STAGE_LABEL,
		"build_stage_visual": "UNVERIFIED",
		"build_stage_rule": "floor(clamp(progress/build_time,0,1)*4) -> suffix 1..4; unit.script:6596, doprogressorders.inc:84, ontagstates.inc:240-251",
		"build_stage_wall_rule": "sid 'wal': 1 + stage div 3 -> suffix 1..2; ontagstates.inc:247-248",
		"build_stage_scaffold_label": BUILD_SCAFFOLD_LABEL,
		"build_stage_obj_sids": stage_obj_sids,
		"build_scaffold_obj_sids": scaffold_obj_sids,
		"build_stage_art_status": (PORT_LABEL + " — BLOCKED: no stage/scaffold OBJ on disk; base donor mesh reused; visual UNVERIFIED") if stage_obj_sids.is_empty() else (PORT_LABEL + " — converted stage/scaffold OBJ present for measured sids; per-stage manifest bbox applied on swap; visual UNVERIFIED"),
		"field_visual_label": FIELD_STATUS,
		"field_visual_visual": "UNVERIFIED",
		"field_visual_decals": _field_decal_paths,
		"field_visual_sow_step_m": FIELD_STEP_M,
		"field_visual_target_span_m": FIELD_SPAN_M,
		# DECOR-01 telemetry (structural/numeric/measurement only, no visual claim).
		"decor_tree_pool_declared": POOL_TREE.size(),
		"decor_tree_pool_resolvable": tree_pool_available.size(),
		"decor_tree_pool_sids": tree_pool_available,
		"decor_tree_ladder_sids": ENV_TREE_SCALE.size(),
		"decor_tree_ladder": "envscales.cfg:158-585 per-sid ladder; 0.475..0.76 bases; all tree jitter wide 0.85..1.15 (:162-164)",
		"decor_tree_jitter_band": TREE_JITTER_BAND,
		"decor_tree_jitter_range": [ENV_JITTER_BANDS[TREE_JITTER_BAND].x, ENV_JITTER_BANDS[TREE_JITTER_BAND].y],
		"decor_jitter_bands": {"none": [1.0, 1.0], "tight": [0.95, 1.05], "wide": [0.85, 1.15]},
		"decor_tree_yaw": TREE_YAW_STATUS,
		"decor_forest_stand": TREE_STAND_STATUS,
		"decor_mine_scale": ENV_SCALE["mine"],
		"decor_mine_jitter_band": "none",
		"decor_mine_ground_disc": MINE_DISC_STATUS,
	}
	push_warning("world3d_entities: " + ANIM_STATUS)


# ---------------------------------------------------------------- mesh loading
func _first_mesh(n: Node) -> Mesh:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh != null:
			return mi.mesh
	for c in n.get_children():
		var m := _first_mesh(c)
		if m != null:
			return m
	return null


func _env_group(sid: String) -> String:
	if sid.begins_with("mine"):
		return "mine"
	if sid.begins_with("rock") or sid == "stone":
		return "stone"
	if sid.begins_with("tree"):
		return "tree"
	return ""


# DECOR-01: donor per-sid envscale factor. Returns the donor value only for the
# 18 tree sids that have an explicit envscales.cfg entry; stumps and oak
# deliberately fall through to the unchanged legacy ENV_SCALE["tree"] = 0.5.
func _env_scale_factor(sid: String) -> float:
	if ENV_TREE_SCALE.has(sid):
		return float(ENV_TREE_SCALE[sid])
	return float(ENV_SCALE.get(_env_group(sid), 1.0))


# DECOR-01: deterministic position hash in [0,1). Same no-RNG policy as
# _pick_sid(): integer arithmetic only, so two identical-seed runs agree.
func _hash01(p: Vector2) -> float:
	var ix: int = int(absf(p.x) * 100.0)
	var iy: int = int(absf(p.y) * 100.0)
	var h: int = (ix * 73856093 + iy * 19349663) & 0x7FFFFFFF
	return float(h % 100000) / 100000.0


# DECOR-01: scale multiplier for one instance inside its donor band.
# "none" (mines/field) returns exactly 1.0 - the existing jitter bypass is
# preserved, not redone. "wide" is the tree band: 0.85..1.15 at envscales.cfg:162-164.
func _jitter_factor(band: String, p: Vector2) -> float:
	var r: Vector2 = ENV_JITTER_BANDS.get(band, ENV_JITTER_BANDS["wide"])
	if is_equal_approx(r.x, r.y):
		return 1.0
	return r.x + (r.y - r.x) * _hash01(p)


func _default_material(sid: String, kind: String) -> Material:
	var mat := StandardMaterial3D.new()
	var tex_path := TEX_DIR + sid + ".png"
	if ResourceLoader.exists(tex_path):
		var tex := load(tex_path) as Texture2D
		if tex != null:
			mat.albedo_texture = tex
	mat.roughness = 1.0
	mat.metallic = 0.0
	# Donor env PNGs are RGBA (V7-2 section 2.3). Cut-out is a PORT
	# APPROXIMATION: donor GLB alphaMode is UNVERIFIED (V7-2 Table B1).
	if kind == "res" and sid != "field":
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = 0.5
	# The OBJ importer keeps donor winding; disable culling so a convention
	# mismatch cannot make a whole silhouette disappear (V7-2 4.1 warns not
	# to double-swap winding).
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


# --- V7-65 donor player-slot key colours -----------------------------------
# Loads res://data/donor_key_colors.json (V7-61) at runtime. On ANY failure it
# pushes an error and leaves bodies UNTINTED: no invented fallback palette is
# ever substituted. rgb_godot_float is the exact donor formula output; alpha
# 1.0 is an explicit port choice (donor alpha UNVERIFIED).
func _load_key_colors() -> void:
	_key_colors.clear()
	_key_colors_loaded = false
	_key_colors_error = ""
	if not FileAccess.file_exists(KEY_COLORS_PATH):
		_key_colors_error = "missing file " + KEY_COLORS_PATH
		push_error("world3d_entities: donor key colours unavailable (" + _key_colors_error + "); bodies left UNTINTED - no fallback palette")
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(KEY_COLORS_PATH))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("slots") \
			or not ((parsed as Dictionary)["slots"] is Array):
		_key_colors_error = "malformed JSON or missing slots array"
		push_error("world3d_entities: donor key colours unavailable (" + _key_colors_error + "); bodies left UNTINTED - no fallback palette")
		return
	for entry in ((parsed as Dictionary)["slots"] as Array):
		if not (entry is Dictionary):
			continue
		var d := entry as Dictionary
		var idx := int(d.get("index", -1))
		var rgb = d.get("rgb_godot_float", [])
		if idx < 0 or not (rgb is Array) or (rgb as Array).size() < 3:
			continue
		var arr = rgb
		var c := Color(float(arr[0]), float(arr[1]), float(arr[2]), 1.0)
		if _key_colors.size() <= idx:
			_key_colors.resize(idx + 1)
		_key_colors[idx] = c
	_key_colors_loaded = _key_colors.size() > 0
	if not _key_colors_loaded:
		_key_colors_error = "no usable slot entries"
		push_error("world3d_entities: donor key colours unavailable (" + _key_colors_error + "); bodies left UNTINTED - no fallback palette")


# Donor guard misc.script:5070: only 0 <= colorInd < gc_MaxColorCount (13) is
# applied. Anything else returns null = no tint, never a made-up colour.
func _player_tint(player: int) -> Variant:
	if not _key_colors_loaded or player < 0 or player >= _key_colors.size():
		return null
	return _key_colors[player]


func _player_index(ed: Dictionary) -> int:
	var pv = ed.get("player", -1)
	if pv is int:
		return int(pv)
	if pv is float:
		return int(pv)
	return -1


# --- NATION-MODEL-01: nation-aware mesh selection -------------------------
# The entity Dictionary itself carries no "nation" key (game.gd:2186-2197
# spawn sets id/kind/player/sid/def/...). Read the nation from, in order:
#   1) an explicit ed["nation"] if a future owner adds one;
#   2) game.players[player]["nation"]  (game.gd:386, :3976);
#   3) Data.PLAYER_NATIONS[player]     (menu/main hand-off).
# Everything is READ-ONLY. Return "" when no nation can be established.
func _nation_of(ed: Dictionary) -> String:
	var n := str(ed.get("nation", "")).strip_edges().to_lower()
	if n != "":
		return n
	var p := _player_index(ed)
	if game != null:
		var plist = game.get("players")
		if plist is Array and p >= 0 and p < (plist as Array).size():
			var pp = (plist as Array)[p]
			if pp is Dictionary:
				var pn := str((pp as Dictionary).get("nation", "")).strip_edges().to_lower()
				if pn != "":
					return pn
	var pnations = Data.PLAYER_NATIONS
	if pnations is Array and p >= 0 and p < (pnations as Array).size():
		var pn2 := str((pnations as Array)[p]).strip_edges().to_lower()
		if pn2 != "":
			return pn2
	return ""


# Read-only probe: never constructs a file, only asks the loader whether the
# exact donor-derived mesh stem already exists on disk.
func _nation_mesh_on_disk(sid: String) -> bool:
	if sid == "":
		return false
	return ResourceLoader.exists(OBJ_DIR + sid + ".obj") \
		or ResourceLoader.exists(GLB_DIR + sid + ".glb")


# NATION_DONOR_01 §2.4 — donor building sidmask (country.script:138-206):
# %nat% families use the nation's own 3-letter prefix; %com% families resolve
# to rus* for rus/ukr, tur* for tur/alg, eur* for everyone else, with the
# explicit por/wwa/spa/mis overrides below. Returned PREFIX is concatenated
# with the port's 3-char base family sid and PROBED against disk; no file is
# created and no name is invented beyond the donor's own prefix+sid rule.
func _donor_building_prefix(nation: String, family: String) -> String:
	const OWN_FAMILIES := ["aca", "art", "ba2", "bar", "bla", "cen",
		"dip", "hou", "sta", "tem"]
	if OWN_FAMILIES.has(family):
		return nation
	match family:
		"por":
			if nation in ["ukr", "rus", "tur", "alg", "por"]:
				return nation
		"mil", "tow", "swa":
			if nation in ["rus", "ukr"]:
				return "rus"
			if nation in ["tur", "alg"]:
				return "tur"
		"wwa":
			return "ukr"
		"sto", "mar":
			if nation in ["rus", "ukr"]:
				return "rus"
			if nation in ["tur", "alg"]:
				return "tur"
			if nation in ["spa", "por"]:
				return "spa"
		"blg", "blg2":
			return "mis"
	return "eur"   # country.script:161 default


# Choose the 3D mesh sid for one entity. keydict:
#   sid      = mesh sid to pass to _mesh_info()
#   nation   = resolved nation code ("" when unavailable)
#   family   = "units" | "buildings" | "naval"
#   candidate= exact-nation stem probed on disk ("" when none)
#   exact    = true only when that stem actually exists on disk
#   status   = honest PORT APPROXIMATION label
# Donor evidence (NATION_DONOR_01 §2-§4, all READ-ONLY):
#   units     — nation identity IS the sid (pikemanrus, musketeer18bav,
#               peaukr/pearus); no donor skin swap exists. The only canonical
#               port-side mapping is Data.resolve_sid() <- country.script.
#   buildings — `%nat%`/`%com%` 3-letter-family prefix (CS:138-206); rus/ukr
#               share rus*, bav shares eur*, bavmil/bavpor do NOT exist.
#   naval     — family-keyed; yachttur/chaika are distinct roster sids, not
#               skins, so there is no nation stem to probe.
# Every candidate below is a DONOR-derived stem, probed against disk; none is
# fabricated, none is copied, and a miss is reported BLOCKED, never "fixed".
func _entity_mesh_sid(ed: Dictionary, base_sid: String, kind: String) -> Dictionary:
	var nation := _nation_of(ed)
	var def: Dictionary = {}
	var dv = ed.get("def", null)
	if dv is Dictionary:
		def = dv as Dictionary
	var family := "units"
	if kind == "building":
		family = "buildings"
	elif bool(def.get("naval", false)):
		family = "naval"
	var candidates: Array[String] = []
	if nation != "" and base_sid != "":
		match family:
			"units":
				# "exact" is claimed ONLY for a real generic->nation remap.
				# A base sid that is already nation-coded (strelet,
				# sco_highlandersword, ...) keeps its correct mesh but is
				# conservatively labelled fallback: another owner may map a
				# nation to a GENERIC sid (data.gd bav:296), and calling that
				# "exact nation art" would be a false claim.
				var rsid := Data.resolve_sid(nation, base_sid)
				if rsid != base_sid:
					candidates.append(rsid)
			"buildings":
				candidates.append(_donor_building_prefix(nation, base_sid) + base_sid)
			"naval":
				pass   # no nation stem exists (yachttur/chaika are base sids)
	var sid := base_sid
	var candidate := ""
	var exact := false
	for c in candidates:
		if _nation_mesh_on_disk(c):
			sid = c
			candidate = c
			exact = true
			break
	var status := NATION_MESH_EXACT_STATUS if exact else NATION_MESH_FALLBACK_STATUS
	return {"sid": sid, "nation": nation, "family": family,
		"candidate": candidate, "candidates": candidates,
		"exact": exact, "status": status}


func _record_nation_mesh(ns: Dictionary, base_sid: String) -> void:
	var usage = stats.get("nation_mesh_usage", {})
	var uk := str(ns.get("family", "")) + "|" + str(ns.get("nation", "")) \
		+ "|" + base_sid + "->" + str(ns.get("sid", ""))
	usage[uk] = int(usage.get(uk, 0)) + 1
	stats["nation_mesh_usage"] = usage


# --- FIX-COLOR: donor albedo-alpha band mask ------------------------------
# Decode ONLY the first mip's DXT5 alpha from the donor DDS named by
# manifest.json:models[i].texture. The 4x4 blocks carry 2 alpha endpoints and
# 16 3-bit indices in 6 bytes; the colour endpoints/indices are deliberately
# ignored because donor uses texture alpha solely as the uniform-0 mask
# (unit.smx9.id8.frag:37-38,42). On ANY structural mismatch return null — a
# missing mask means NO tint, never an invented band and never a whole-body
# fallback.
func _dxt5_mask(path: String) -> Image:
	if path == "" or not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var hdr: PackedByteArray = f.get_buffer(DDS_HEADER_SIZE)
	# PackedByteArray has no subarray() in Godot 4.7: compare the four magic
	# bytes directly ("DDS " = 68,68,83,32; DXT5 = 68,88,84,53).
	if hdr.size() < DDS_HEADER_SIZE or hdr[0] != 68 or hdr[1] != 68 or hdr[2] != 83 or hdr[3] != 32:
		f.close()
		return null
	# DDS header: height :12, width :16, pixel format fourcc :84 (DXT5).
	var h: int = int(hdr[12]) | (int(hdr[13]) << 8) | (int(hdr[14]) << 16) | (int(hdr[15]) << 24)
	var w: int = int(hdr[16]) | (int(hdr[17]) << 8) | (int(hdr[18]) << 16) | (int(hdr[19]) << 24)
	if hdr[84] != 68 or hdr[85] != 88 or hdr[86] != 84 or hdr[87] != 53 or w <= 0 or h <= 0:
		f.close()
		return null
	var blocks_x: int = maxi(1, (w + 3) / 4)
	var blocks_y: int = maxi(1, (h + 3) / 4)
	var payload: PackedByteArray = f.get_buffer(blocks_x * blocks_y * DXT5_BLOCK_BYTES)
	f.close()
	if payload.size() < blocks_x * blocks_y * DXT5_BLOCK_BYTES:
		return null
	var data := PackedByteArray()
	data.resize(w * h * 4)
	data.fill(255)
	var bi: int = 0
	for by in range(blocks_y):
		for bx in range(blocks_x):
			var o: int = bi * DXT5_BLOCK_BYTES
			bi += 1
			var a0: int = payload[o]
			var a1: int = payload[o + 1]
			var bits: int = 0
			for k in range(6):
				bits |= int(payload[o + 2 + k]) << (k * 8)
			for i in range(16):
				var idx: int = (bits >> (i * 3)) & 7
				var av: int = 255
				if a0 > a1:
					av = clamped_dxt5(((8 - idx) * a0 + (idx - 1) * a1) / 7)
				elif idx == 0:
					av = a0
				elif idx == 1:
					av = a1
				elif idx == 6:
					av = 0
				elif idx == 7:
					av = 255
				else:
					av = clamped_dxt5(((6 - idx) * a0 + (idx - 1) * a1) / 5)
				var px: int = bx * 4 + (i % 4)
				var py: int = by * 4 + (i / 4)
				if px < w and py < h:
					var di: int = (py * w + px) * 4
					data[di] = av
					data[di + 1] = av
					data[di + 2] = av
					data[di + 3] = av
	return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)


func clamped_dxt5(v: float) -> int:
	return clampi(int(v), 0, 255)


# Per-sid mask cache + measured texel counts (structural, never a visual claim).
func _band_mask(sid: String) -> Image:
	if _band_mask_cache.has(sid):
		var cached = _band_mask_cache[sid]
		if cached is Dictionary and (cached as Dictionary).get("image") is Image:
			return (cached as Dictionary)["image"] as Image
	var img := _dxt5_mask(str(_donor_texture_paths.get(sid, "")))
	if img == null:
		return null
	var w: int = img.get_width()
	var h: int = img.get_height()
	var raw: PackedByteArray = img.get_data()
	var masked: int = 0
	for i in range(3, raw.size(), 4):
		if int(raw[i]) >= int(TINT_MASK_THRESHOLD * 255.0):
			masked += 1
	_band_mask_cache[sid] = {"image": img, "texture": ImageTexture.create_from_image(img)}
	_band_mask_stats[sid] = {"source": str(_donor_texture_paths.get(sid, "")),
		"texels": w * h, "mask_texels": masked, "verts": 0, "tinted_verts": 0,
		"faces": 0, "tinted_faces": 0, "label": PORT_LABEL, "visual": "UNVERIFIED"}
	return img


func _band_mask_texture(sid: String) -> Texture2D:
	_band_mask(sid)
	var cached = _band_mask_cache.get(sid)
	if cached is Dictionary:
		return (cached as Dictionary).get("texture") as Texture2D
	return null


func _mask_at(img: Image, uv: Vector2) -> bool:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var px: int = clampi(int(uv.x * float(w)), 0, w - 1)
	var py: int = clampi(int(uv.y * float(h)), 0, h - 1)
	return img.get_pixel(px, py).a >= TINT_MASK_THRESHOLD


# Count how many mesh vertices/faces actually land on donor band texels. The
# vertex count is shared with the morph path (UVs there are Godot-V-flipped),
# so sampling the baked surface UVs keeps one index space for both paths.
func _measure_band(sid: String, mesh: Mesh) -> void:
	var img := _band_mask(sid)
	if img == null or mesh == null:
		return
	var st = _band_mask_stats.get(sid)
	if not (st is Dictionary):
		return
	var d := st as Dictionary
	if int(d.get("verts", 0)) > 0:
		return
	for s in range(mesh.get_surface_count()):
		var arr: Array = mesh.surface_get_arrays(s)
		var uvs = arr[Mesh.ARRAY_TEX_UV]
		if not (uvs is PackedVector2Array):
			continue
		var uvarr: PackedVector2Array = uvs
		var vs = arr[Mesh.ARRAY_VERTEX]
		var n: int = (vs as PackedVector3Array).size() if vs is PackedVector3Array else 0
		var tinted: int = 0
		for i in range(uvarr.size()):
			if _mask_at(img, uvarr[i]):
				tinted += 1
		d["verts"] = int(d.get("verts", 0)) + n
		d["tinted_verts"] = int(d.get("tinted_verts", 0)) + tinted
		var faces: int = 0
		var tinted_faces: int = 0
		var ix = arr[Mesh.ARRAY_INDEX]
		if ix is PackedInt32Array:
			var ia: PackedInt32Array = ix
			for fi in range(0, ia.size() - 2, 3):
				var i0: int = ia[fi]
				var i1: int = ia[fi + 1]
				var i2: int = ia[fi + 2]
				faces += 1
				if i0 < uvarr.size() and i1 < uvarr.size() and i2 < uvarr.size() \
						and _mask_at(img, uvarr[i0]) and _mask_at(img, uvarr[i1]) \
						and _mask_at(img, uvarr[i2]):
					tinted_faces += 1
		else:
			faces = n / 3
		d["faces"] = int(d.get("faces", 0)) + faces
		d["tinted_faces"] = int(d.get("tinted_faces", 0)) + tinted_faces


# FIX-COLOR: donor uniform-0, reproduced as a ShaderMaterial using the donor
# albedo texture + the donor alpha band mask. If no donor-derived mask is
# available the material is left UNTINTED — V7-65's whole-body albedo tint was
# the reported defect and is never reinstated as a fallback.
func _tinted_material(base: Material, tint: Color, sid: String, kind: String) -> Material:
	var mask := _band_mask_texture(sid)
	if mask == null:
		push_warning("world3d_entities: no donor band mask for " + sid + " - left UNTINTED, no whole-body fallback")
		return base.duplicate() if base != null else _default_material(sid, kind)
	var bm: Material = base
	if bm == null:
		bm = _default_material(sid, kind)
	var albedo: Texture2D = null
	if bm is StandardMaterial3D:
		albedo = (bm as StandardMaterial3D).albedo_texture
	if albedo == null and ResourceLoader.exists(TEX_DIR + sid + ".png"):
		albedo = load(TEX_DIR + sid + ".png") as Texture2D
	var sh := Shader.new()
	sh.code = TINT_SHADER_CODE
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("albedo_tex", albedo)
	m.set_shader_parameter("mask_tex", mask)
	m.set_shader_parameter("custColor", tint)
	return m


# Per-instance tint, still sharing the baked donor mesh.
# Godot 4: MultiMeshInstance3D derives from GeometryInstance3D, NOT from
# MeshInstance3D, so it has no set_surface_override_material(). Use the
# GeometryInstance3D.material_override on batches (built from the donor
# albedo material of surface 0, so the donor texture is kept) and the normal
# surface overrides on building MeshInstance3Ds. One override per batch means
# the player slot is part of the batch key (see add_unit), as batching allows.
# FIX-COLOR: the override is now a masked ShaderMaterial, not an
# albedo_color paint; _measure_band records the measured donor-band subset.
func _apply_tint(instance: GeometryInstance3D, mesh: Mesh, tint: Color,
		sid: String, kind: String) -> void:
	if mesh == null:
		return
	_measure_band(sid, mesh)
	instance.set_meta("donor_tint_label", PORT_LABEL)
	instance.set_meta("donor_tint_visual", "UNVERIFIED")
	if instance is MultiMeshInstance3D:
		var base: Material = null
		if mesh.get_surface_count() > 0:
			base = mesh.surface_get_material(0)
		instance.material_override = _tinted_material(base, tint, sid, kind)
		return
	if instance is MeshInstance3D:
		for s in range(mesh.get_surface_count()):
			var base_m: Material = mesh.surface_get_material(s)
			(instance as MeshInstance3D).set_surface_override_material(
				s, _tinted_material(base_m, tint, sid, kind))


# Box sized from the donor bbox. Used only when neither OBJ nor GLB exists.
# Its geometry is still donor-BBOX-DERIVED, never an invented size.
func _proxy_mesh_raw(bbox: Array) -> Mesh:
	if bbox.size() < 6:
		bbox = [-0.5, 0.5, -0.5, 0.5, 0.0, 1.0]
	var x0 := float(bbox[0]); var x1 := float(bbox[1])
	var y0 := float(bbox[2]); var y1 := float(bbox[3])
	var z0 := float(bbox[4]); var z1 := float(bbox[5])
	var box := BoxMesh.new()
	box.size = Vector3(maxf(x1 - x0, 0.05), maxf(y1 - y0, 0.05), maxf(z1 - z0, 0.05))
	var src: Array = box.surface_get_arrays(0)
	var verts: PackedVector3Array = src[Mesh.ARRAY_VERTEX]
	var centre := Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, (z0 + z1) * 0.5)
	for i in range(verts.size()):
		verts[i] += centre
	var dst: Array = []
	dst.resize(Mesh.ARRAY_MAX)
	for i in range(Mesh.ARRAY_MAX):
		dst[i] = src[i] if i < src.size() else null
	dst[Mesh.ARRAY_VERTEX] = verts
	var out := ArrayMesh.new()
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dst)
	return out


# Bake Z-up -> Y-up, bbox centring and bbox-derived scale into a cached mesh.
func _bake_mesh(src_mesh: Mesh, bbox: Array, scale: float, target_h: float,
		pre_normalised: bool, sid: String, kind: String) -> Dictionary:
	if pre_normalised:
		# V7-8 GLB is expected to be exported Y-up and bbox-normalised already.
		# That is an UNVERIFIED assumption until T-V72-1; recorded in stats.
		return {"mesh": src_mesh, "source": "glb_assumed_yup",
			"scale": scale, "height": target_h}
	if bbox.size() < 6:
		bbox = [-0.5, 0.5, -0.5, 0.5, 0.0, 1.0]
	var cx := (float(bbox[0]) + float(bbox[1])) * 0.5
	var cy := (float(bbox[2]) + float(bbox[3])) * 0.5
	var z0 := float(bbox[4])
	var out := ArrayMesh.new()
	for s in range(src_mesh.get_surface_count()):
		var src: Array = src_mesh.surface_get_arrays(s)
		var dst: Array = []
		dst.resize(Mesh.ARRAY_MAX)
		for i in range(Mesh.ARRAY_MAX):
			dst[i] = src[i] if i < src.size() else null
		var vs = src[Mesh.ARRAY_VERTEX]
		if vs is PackedVector3Array:
			var nv := PackedVector3Array()
			nv.resize((vs as PackedVector3Array).size())
			for i in range((vs as PackedVector3Array).size()):
				var v: Vector3 = (vs as PackedVector3Array)[i]
				nv[i] = Vector3((v.x - cx) * scale,
					(v.z - z0) * scale,
					-(v.y - cy) * scale)
			dst[Mesh.ARRAY_VERTEX] = nv
		var ns = src[Mesh.ARRAY_NORMAL]
		if ns is PackedVector3Array:
			var nn := PackedVector3Array()
			nn.resize((ns as PackedVector3Array).size())
			for i in range((ns as PackedVector3Array).size()):
				var n: Vector3 = (ns as PackedVector3Array)[i]
				nn[i] = Vector3(n.x, n.z, -n.y).normalized()
			dst[Mesh.ARRAY_NORMAL] = nn
		var ts = src[Mesh.ARRAY_TANGENT]
		if ts is PackedFloat32Array:
			var nt := PackedFloat32Array()
			nt.resize((ts as PackedFloat32Array).size())
			for i in range(0, (ts as PackedFloat32Array).size(), 4):
				nt[i] = (ts as PackedFloat32Array)[i]
				nt[i + 1] = (ts as PackedFloat32Array)[i + 2]
				nt[i + 2] = -(ts as PackedFloat32Array)[i + 1]
				nt[i + 3] = (ts as PackedFloat32Array)[i + 3]
			dst[Mesh.ARRAY_TANGENT] = nt
		out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dst)
		var mat: Material = src_mesh.surface_get_material(s)
		if mat == null:
			mat = _default_material(sid, kind)
		out.surface_set_material(out.get_surface_count() - 1, mat)
	return {"mesh": out, "source": "converted", "scale": scale,
		"height": target_h}


func _mesh_info(sid: String, kind: String) -> Dictionary:
	var key := kind + "|" + sid
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var bbox: Array = _bbox.get(sid, [])
	var native_h: float = 1.0
	if bbox.size() >= 6:
		native_h = float(bbox[5]) - float(bbox[4])
	if native_h <= 0.0:
		native_h = 1.0
	# bbox-derived scale. Env scale is the donor per-instance multiplier, not
	# a new size guess; field is exempt (ground patch caveat, V7-2 2.3).
	# DECOR-01: tree sids get the per-sid donor envscale ladder (0.475..0.76,
	# envscales.cfg:158-585) instead of the old blanket 0.5; non-tree sids keep
	# the exact pre-ticket values. Per-instance jitter is applied in _xf()
	# because this mesh cache is shared by all instances of one sid.
	var factor: float = 1.0
	if kind == "res":
		factor = _env_scale_factor(sid)
	var target_h: float = native_h * factor
	var scale: float = target_h / native_h
	var src_mesh: Mesh = null
	var pre_normalised := false
	var source := "donor_bbox_proxy"
	var glb := GLB_DIR + sid + ".glb"
	if ResourceLoader.exists(glb):
		var packed = load(glb)
		if packed is PackedScene:
			var inst: Node = (packed as PackedScene).instantiate()
			src_mesh = _first_mesh(inst)
			inst.free()
		elif packed is Mesh:
			src_mesh = packed as Mesh
		if src_mesh != null:
			pre_normalised = true
			source = "glb_assumed_yup"
	var obj := OBJ_DIR + sid + ".obj"
	if src_mesh == null and ResourceLoader.exists(obj):
		src_mesh = load(obj) as Mesh
		if src_mesh != null:
			source = "obj_zup_bbox_normalised"
	if src_mesh == null:
		src_mesh = _proxy_mesh_raw(bbox)
	var info := _bake_mesh(src_mesh, bbox, scale, target_h, pre_normalised, sid, kind)
	info["source"] = source
	info["sid"] = sid       # V7-65: needed by per-player material cloning
	info["kind"] = kind
	_mesh_cache[key] = info
	_mesh_sources[source] = int(_mesh_sources.get(source, 0)) + 1
	stats["mesh_sources_loaded"] = _mesh_sources
	return info


# ---------------------------------------------------------------- V7-74 morph
# The anim module is a SIBLING of this module under world3d.gd (both are
# add_child'd at world3d.gd:152-165). Discover it once by its handoff methods;
# never fabricate pose data when it is absent (atomic stub tests, shipped
# runtime without a registered skin).
func _find_anim():
	if _anim != null and is_instance_valid(_anim):
		return _anim
	if _anim_checked:
		return null
	_anim_checked = true
	var parent := get_parent()
	if parent == null:
		return null
	for child in parent.get_children():
		if child == self:
			continue
		if child.has_method("pose_for") and child.has_method("has_skin"):
			_anim = child
			break
	return _anim


# PORT-LEVEL state -> donor AAF name policy, NOT a donor statement. All three
# names exist in anim3d.gd AAF_ACTIONS (:64 idle, :66 walk, :67 death) and are
# taken from data/animations/aaf/peaukr.aaf:3-5. The sim fields are the same
# ones the 2D renderer reads (t_entities3d.gd:118/124, game.gd entities).
# No keyframe is invented: the actual frame and verts come from pose_for().
#
# MOTION-ANIM-01: `moving` alone is not a motion measurement. VID-AN-01 §3/§5
# measured `moving:true` at ~0.001 m/s for f08..f15 while the donor walk frame
# kept cycling, so walk is now gated on displacement measured in sync(). The
# measured speed is supplied by the caller; speed < 0 means "not measured", in
# which case the V7-74 `moving` fallback is kept for direct/stub callers.
func _unit_action(ed: Dictionary, speed: float = -1.0) -> String:
	if bool(ed.get("dead", false)):
		return "death"
	# BUILD-ANIM-DIAG-01 §5 step 1 — donor build state tag maps to AAF
	# 'construct' (dmscript.global:13,926; unit.script:10877;
	# data/animations/aaf/peaukr.aaf:17). The 2D sibling already does this
	# (world.gd:489-490). PORT APPROXIMATION: only when the measured speed is
	# below the MOTION-ANIM-01 gate — a builder still travelling keeps 'walk'.
	# Dead-first priority and every other branch below stay byte-identical.
	var od = ed.get("order", null)
	if od is Dictionary:
		var otype := str((od as Dictionary).get("type", ""))
		if otype == "build" or otype == "repair":
			if speed >= 0.0:
				if speed < WALK_SPEED_GATE_M_S:
					return "construct"
			elif not bool(ed.get("moving", false)):
				return "construct"
	if speed >= 0.0:
		return "walk" if speed >= WALK_SPEED_GATE_M_S else "idle"
	if bool(ed.get("moving", false)):
		return "walk"
	return "idle"


# MOTION-ANIM-01: MEASURE the SIM, never write to it. The entity Dictionary is
# the live sim object (_refs holds the reference), so pos is read after the
# sim's fixed ticks. Speed = |pos - last_pos| / (anim_clock - last_clock),
# both of which this module already owns; no second wall-clock timer is added.
func _measure_speed(id: int, ed: Dictionary) -> float:
	var pos: Vector2 = ed.get("pos", Vector2.ZERO)
	var prev = _motion_sample.get(id)
	var speed := 0.0
	if prev is Dictionary:
		var pd := prev as Dictionary
		var step_t := _anim_t - float(pd.get("t", _anim_t))
		if step_t > 0.0:
			var prev_pos: Vector2 = pd.get("pos", pos)
			speed = (pos - prev_pos).length() / step_t
	_motion_sample[id] = {"pos": pos, "t": _anim_t}
	return speed


# MOTION-ANIM-01: PORT APPROX yaw clamp. The donor authors frame blending but
# its engine semantics are UNVERIFIED (DANIM-01 §4.3), so this is explicitly a
# presentation-rate limiter, not a donor blend. Shortest signed arc is clamped
# to rate * sync dt; wrap is normalised so a +179 -> -179 flip is treated as 2 deg.
func _smooth_face(id: int, target: float, dt: float) -> float:
	var prev := float(_face_smooth.get(id, target))
	var max_step := YAW_MAX_RATE_RAD_S * maxf(dt, 0.0)
	var delta := fposmod(target - prev + PI, TAU) - PI
	if absf(delta) > max_step:
		delta = signf(delta) * max_step
	return fposmod(prev + delta + PI, TAU) - PI


# Parse the DONOR-CONVERTED OBJ (convert_models.py:43-66, :109-125) once per
# sid. Its vertex i is the donor .oss vertex i == pose vert i (V764 section 4),
# and its f/vt rows are the donor faces/UVs. The Godot importer may de-index
# and reorder vertices (measured: 719 imported vs 577 donor for peasant), so
# this source topology - not the imported buffer - is the shared index space.
func _load_obj_topology(sid: String) -> Dictionary:
	if _obj_topology.has(sid):
		return _obj_topology[sid]
	var result: Dictionary = {"verts": [], "uvs": [], "tris": []}
	var path := OBJ_DIR + sid + ".obj"
	if not FileAccess.file_exists(path):
		_obj_topology[sid] = result
		return result
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_obj_topology[sid] = result
		return result
	var vv: Array = []
	var uu: Array = []
	var tt: Array = []
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line.begins_with("v "):
			var p := line.split(" ", false)
			if p.size() >= 4:
				vv.append(Vector3(float(p[1]), float(p[2]), float(p[3])))
		elif line.begins_with("vt "):
			var p := line.split(" ", false)
			if p.size() >= 3:
				uu.append(Vector2(float(p[1]), float(p[2])))
		elif line.begins_with("f "):
			var corners: Array = []
			var p := line.split(" ", false)
			for token in p.slice(1):
				var sub := token.split("/", false)
				if sub.is_empty():
					continue
				var vi: int = int(sub[0]) - 1
				var ui: int = int(sub[1]) - 1 if sub.size() > 1 and sub[1] != "" else -1
				corners.append([vi, ui])
			# Fan-triangulate any non-triangle face (this donor OBJ is all tris).
			for j in range(1, corners.size() - 1):
				tt.append([corners[0], corners[j], corners[j + 1]])
	f.close()
	result = {"verts": vv, "uvs": uu, "tris": tt}
	_obj_topology[sid] = result
	return result


# Rebuild the mesh from donor flat-root verts + donor OBJ topology using the
# EXACT transform of _bake_mesh (:341-360): (x-cx, z-z0, -(y-cy)) * scale.
# On any structural mismatch return no mesh and the caller keeps the static
# bind pose - never a filled/guessed vertex. Normals are generated from the
# morphed donor geometry (the donor skin emits positions only); UVs keep the
# donor vt values with the standard Godot V flip, both UNVERIFIED vs a render.
func _morph_mesh(sid: String, info: Dictionary, frame: int, action: String,
		verts: PackedVector3Array) -> Dictionary:
	var key := sid + "|" + action + "|f" + str(frame)
	if _morph_meshes.has(key):
		return _morph_meshes[key]
	var result: Dictionary = {"mesh": null, "reason": ""}
	var base := info.get("mesh") as Mesh
	if base == null or base.get_surface_count() < 1 or verts.is_empty():
		result["reason"] = "no source mesh or empty donor verts"
		_morph_meshes[key] = result
		return result
	var topo: Dictionary = _load_obj_topology(sid)
	var bind_verts: Array = topo.get("verts", [])
	var uvs: Array = topo.get("uvs", [])
	var tris: Array = topo.get("tris", [])
	if bind_verts.is_empty() or tris.is_empty() or bind_verts.size() != verts.size():
		result["reason"] = "no donor OBJ topology or vertex count mismatch: obj=%d donor=%d" % [bind_verts.size(), verts.size()]
		_morph_meshes[key] = result
		return result
	var bbox: Array = _bbox.get(sid, [])
	var cx := 0.0
	var cy := 0.0
	var z0 := 0.0
	if bbox.size() >= 6:
		cx = (float(bbox[0]) + float(bbox[1])) * 0.5
		cy = (float(bbox[2]) + float(bbox[3])) * 0.5
		z0 = float(bbox[4])
	var sc := float(info.get("scale", 1.0))
	var out_v := PackedVector3Array()
	var out_uv := PackedVector2Array()
	var out_idx := PackedInt32Array()
	var corner_map: Dictionary = {}
	for tri in tris:
		for corner in tri:
			var vi: int = int(corner[0])
			var ui: int = int(corner[1])
			if vi < 0 or vi >= verts.size():
				result["reason"] = "OBJ face index out of range: %d" % vi
				_morph_meshes[key] = result
				return result
			var ck := str(vi) + "," + str(ui)
			var ni: int = int(corner_map.get(ck, -1))
			if ni < 0:
				ni = out_v.size()
				corner_map[ck] = ni
				var mv: Vector3 = verts[vi]
				out_v.append(Vector3((mv.x - cx) * sc, (mv.z - z0) * sc, -(mv.y - cy) * sc))
				if ui >= 0 and ui < uvs.size():
					var uv: Vector2 = uvs[ui]
					out_uv.append(Vector2(uv.x, 1.0 - uv.y))
				else:
					out_uv.append(Vector2.ZERO)
			out_idx.append(ni)
	var dst: Array = []
	dst.resize(Mesh.ARRAY_MAX)
	for i in range(Mesh.ARRAY_MAX):
		dst[i] = null
	dst[Mesh.ARRAY_VERTEX] = out_v
	dst[Mesh.ARRAY_TEX_UV] = out_uv
	dst[Mesh.ARRAY_INDEX] = out_idx
	# ArrayMesh has no generate_normals() in Godot 4.7; accumulate face normals
	# from the morphed donor geometry (no donor normals exist in the .oss).
	var norms := PackedVector3Array()
	norms.resize(out_v.size())
	for i in range(0, out_idx.size(), 3):
		var i0: int = out_idx[i]
		var i1: int = out_idx[i + 1]
		var i2: int = out_idx[i + 2]
		var a: Vector3 = out_v[i0]
		var b: Vector3 = out_v[i1]
		var c: Vector3 = out_v[i2]
		var n: Vector3 = (b - a).cross(c - a)
		norms[i0] += n
		norms[i1] += n
		norms[i2] += n
	for i in range(norms.size()):
		norms[i] = norms[i].normalized()
	dst[Mesh.ARRAY_NORMAL] = norms
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dst)
	var mat: Material = base.surface_get_material(0)
	if mat == null:
		mat = _default_material(sid, "unit")
	mesh.surface_set_material(0, mat)
	result = {"mesh": mesh, "frame": frame, "action": action,
		"verts": out_v.size(), "source": "donor_flat_root_morph",
		"coord": "donor Z-up -> bbox/Y-up (V764 section 4)",
		"label": PORT_LABEL, "visual": "UNVERIFIED"}
	_morph_meshes[key] = result
	return result


# ---------------------------------------------------------------- batching
func _new_batch(key: String, info: Dictionary, cls: String,
		pose: Dictionary = {}) -> Dictionary:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = info["mesh"]
	# MILLFIX F2: fields carry per-instance stage colour. Kind "res" sid
	# "field" is the only batch that opts into vertex/instance colours; all
	# other batches keep their untouched donor albedo path. Godot 4.7 only
	# allows toggling use_colors while instance_count == 0, so do this FIRST.
	if key == "res|field":
		mm.use_colors = true
		var fmesh: Mesh = info["mesh"]
		for s in range(fmesh.get_surface_count()):
			var sm: Material = fmesh.surface_get_material(s)
			if sm is StandardMaterial3D:
				(sm as StandardMaterial3D).vertex_color_use_as_albedo = true
	mm.instance_count = BATCH_CAPACITY
	mm.visible_instance_count = 0
	var mmi := MultiMeshInstance3D.new()
	var is_morph: bool = not pose.is_empty()
	var tag := "MORPH_a" + str(pose.get("action", "?")) + "_f" + str(pose.get("frame", -1)) \
		if is_morph else "STATIC_POSE"
	mmi.name = "Batch_" + key.replace("|", "_") + "_" + tag
	mmi.set_meta("anim_status", ANIM_STATUS)
	mmi.set_meta("mesh_source", str(info.get("source", "?")))
	if is_morph:
		mmi.set_meta("donor_pose_source", MORPH_POSE_SOURCE)
		mmi.set_meta("donor_frame", int(pose.get("frame", -1)))
		mmi.set_meta("donor_action", str(pose.get("action", "")))
		mmi.set_meta("donor_label", PORT_LABEL)
		mmi.set_meta("donor_visual", "UNVERIFIED")
	mmi.multimesh = mm
	add_child(mmi)
	# xforms is a CPU mirror. Headless Godot 4.7 dummy RenderingServer makes
	# MultiMesh.get_instance_transform() return identity for every slot, so a
	# mirror is needed for O(1) swap-removal and headless verification.
	return {"node": mmi, "mm": mm, "ids": [], "xforms": [], "class": cls,
		"key": key, "morph": is_morph}


# V7-65: `tint` / `player` are INTERNAL batching-key extensions only; the six
# public signatures are unchanged. Resources pass tint=null and stay untinted.
func _acquire(key: String, id: int, info: Dictionary, cls: String,
		tint: Variant = null, player: int = -1,
		pose: Dictionary = {}) -> int:
	var b = _batches.get(key)
	if not (b is Dictionary):
		b = _new_batch(key, info, cls, pose)
		_batches[key] = b
		(b as Dictionary)["tint"] = tint
		(b as Dictionary)["player"] = player
		if tint is Color:
			_apply_tint((b as Dictionary)["node"], info["mesh"], tint,
				str(info.get("sid", "")), str(info.get("kind", cls)))
	var ids: Array = b["ids"]
	if ids.size() >= BATCH_CAPACITY:
		push_warning("world3d_entities: batch full " + key + " (cap " + str(BATCH_CAPACITY) + ")")
		return -1
	var ix: int = ids.size()
	ids.append(id)
	(b as Dictionary)["xforms"].append(Transform3D())
	# Keep tint/player/pose on the slot so a frame change can re-acquire the
	# matching batch without re-reading sim state or guessing a key.
	_slot[id] = {"key": key, "index": ix, "class": cls, "tint": tint,
		"player": player, "pose_source": str(pose.get("pose_source", "static_bind_pose")),
		"frame": int(pose.get("frame", -1)), "action": str(pose.get("action", ""))}
	var mm: MultiMesh = b["mm"]
	# MILLFIX F2: neutral initial instance colour; sync() owns stage colours.
	if key == "res|field":
		mm.set_instance_color(ix, Color(1, 1, 1, 1))
	mm.visible_instance_count = ids.size()
	return ix


func _release(id: int) -> void:
	var sl = _slot.get(id)
	if not (sl is Dictionary):
		return
	var key := str((sl as Dictionary).get("key", ""))
	var b = _batches.get(key)
	if not (b is Dictionary):
		_slot.erase(id)
		return
	var ids: Array = (b as Dictionary)["ids"]
	var mm: MultiMesh = (b as Dictionary)["mm"]
	var xforms: Array = (b as Dictionary)["xforms"]
	var ix: int = int((sl as Dictionary).get("index", 0))
	var last: int = ids.size() - 1
	if ix >= 0 and last >= 0:
		if ix != last:
			# swap-remove keeps the instance array dense; O(1) removal.
			# Use the CPU mirror, not MultiMesh.get_instance_transform()
			# (identity under the headless dummy RenderingServer).
			var xf: Transform3D = xforms[last]
			xforms[ix] = xf
			mm.set_instance_transform(ix, xf)
			var moved = ids[last]
			ids[ix] = moved
			if _slot.has(moved):
				(_slot[moved] as Dictionary)["index"] = ix
		ids.pop_back()
		mm.visible_instance_count = ids.size()
		# An empty STATIC batch has no reason to keep a node/draw call alive;
		# free it synchronously so same-frame node counts return to baseline.
		# V7-74: keep EMPTY MORPH batches alive so a unit oscillating between
		# donor frames reuses the node instead of free/create churn; they draw
		# nothing (visible_instance_count == 0) and are bounded by visited frames.
		if ids.is_empty() and not bool((b as Dictionary).get("morph", false)):
			var node = (b as Dictionary).get("node")
			if is_instance_valid(node):
				(node as Node).free()
			_batches.erase(key)
	_slot.erase(id)


# ---------------------------------------------------------------- coordinates
func _world_pos(p: Vector2) -> Vector3:
	var w := MAP_DEFAULT
	var h := MAP_DEFAULT
	if game != null:
		# RefCounted stubs in atomic tests return null for unknown properties;
		# float(null) is an invalid constructor in GDScript 4.7.
		var wv = game.get("MAP_W")
		var hv = game.get("MAP_H")
		if wv != null:
			w = float(wv)
		if hv != null:
			h = float(hv)
	if w <= 0.0:
		w = MAP_DEFAULT
	if h <= 0.0:
		h = MAP_DEFAULT
	var y := 0.0
	if game != null and game.has_method("height_at"):
		y = float(game.call("height_at", p))
	return Vector3(p.x - w * 0.5 * TILE_M, y, p.y - h * 0.5 * TILE_M)


func _is_hidden(e: Dictionary) -> bool:
	if bool(e.get("dead", false)) or bool(e.get("hidden", false)):
		return true
	if str(e.get("kind", "")) == "res":
		# Mirrors world.gd:2712-2713: permanent ore nodes (max_hits == 0)
		# stay visible; exhausted finite nodes do not.
		if int(e.get("hits", 0)) <= 0 and int(e.get("max_hits", 0)) != 0 \
				and str(e.get("type", "")) != "stump" and str(e.get("type", "")) != "food":
			return true
	return false


func _xf(id: int) -> Transform3D:
	var e = _refs.get(id)
	if not (e is Dictionary):
		return Transform3D()
	var ed := e as Dictionary
	var p: Vector2 = ed.get("pos", Vector2.ZERO)
	var yaw := 0.0
	var sl = _slot.get(id)
	if sl is Dictionary and str((sl as Dictionary).get("class", "")) == "unit":
		# FIX-MOVE-VISUAL: the converted donor mesh's FRONT is donor -Y, not
		# +X. Evidence (all read-only): bake_sprites.py:226-238 places camera
		# d at azimuth d*45 deg around the donor Z-up mesh; in the donor-
		# derived sheet assets/models/anim/common/units/peasant_idle.png
		# column 6 (az 270 deg, camera at -Y) shows the FACE/buttons while
		# column 2 (az 90 deg, +Y) shows the back strap (same for musketeer).
		# convert_models.py:43-66 + _bake_mesh map donor (x,y,z) -> (x,z,-y),
		# so donor -Y becomes local +Z in the Y-up mesh. SIM face is
		# (target-pos).angle() (app/scripts/game.gd:4605,5182), i.e. angle
		# from +X toward +Y, and _world_pos maps sim +Y to world +Z.
		# R_y(PI/2-face)*local +Z = (cos face, 0, sin face): face 0 -> world
		# +X, face 90 deg -> world +Z. V7-65's yaw=-face pointed local +X
		# and was 90 deg off -> units looked like they strafed.
		# PORT APPROXIMATION retained: donor yaw itself is a renderer transform
		# (V7-2 3.3.3; V7-1 C4: zero turn actions in 246 .aaf); visual UNVERIFIED.
		# MOTION-ANIM-01: use the once-per-sync clamped face, not the raw SIM
		# face, so a 91/166 deg snap cannot jump the mesh in one capture. Before
		# the first sync (add_unit / stub callers) the raw face is still used.
		var smooth_face: Variant = _face_smooth.get(id, null)
		if smooth_face is float:
			yaw = PI / 2.0 - float(smooth_face)
		else:
			yaw = PI / 2.0 - float(ed.get("face", 0.0))
	# DECOR-01: DECOR tree jitter is per instance, so it lives here rather than
	# in the sid-shared _mesh_cache. Donor trees sit in the "wide" 0.85..1.15
	# band (envscales.cfg:162-164; DEC-03 §4.8); mines stay in "none" 1/1 and
	# are deliberately untouched - no jitter is applied to non-wood res nodes.
	# Resource yaw is intentionally left at 0: no authored per-object rotation
	# reaches this module (see TREE_YAW_STATUS); no rotation is invented.
	var s := HIDDEN_SCALE if _is_hidden(ed) else 1.0
	if str(ed.get("kind", "")) == "res" and str(ed.get("type", "")) == "wood":
		s *= _jitter_factor(TREE_JITTER_BAND, p)
	var basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(s, s, s))
	return Transform3D(basis, _world_pos(p))


# ---------------------------------------------------------------- public API
func add_unit(e) -> void:
	if e == null or game == null:
		return
	var ed := e as Dictionary
	var id := int(ed.get("id", -1))
	if id < 0:
		return
	_refs[id] = ed
	# MOTION-ANIM-01: seed the presentation mirrors at spawn so the first sync
	# measures a real interval and a new unit never yaws from 0 to its face.
	_motion_sample[id] = {"pos": ed.get("pos", Vector2.ZERO), "t": _anim_t}
	_face_smooth[id] = float(ed.get("face", 0.0))
	_applied_pose_frame.erase(id)
	if _slot.has(id):
		return
	var base_sid := str(ed.get("sid", ""))
	# NATION-MODEL-01: resolve the mesh sid from the entity's nation before any
	# mesh is loaded. Static-bind and morph paths both see the chosen sid via
	# _refs; no sim field is written. Naval ships are units with def.naval=true
	# and are handled by the "naval" family branch of the same helper.
	var ns := _entity_mesh_sid(ed, base_sid, "unit")
	var sid := str(ns["sid"])
	_record_nation_mesh(ns, base_sid)
	var info := _mesh_info(sid, "unit")
	var player: int = _player_index(ed)
	# Explicit Variant type: `:=` from a Variant-returning helper is an
	# INFERRED_DECLARATION warning, which this project treats as an error.
	var tint: Variant = _player_tint(player)
	var key := "unit|" + sid
	if tint is Color:
		# Internal batch-key extension: one MultiMesh per (sid, player slot).
		# Without this, two players' units would share one material/tint.
		key += "|p" + str(player)
	var ix := _acquire(key, id, info, "unit", tint, player)
	if ix >= 0:
		var b: Dictionary = _batches[key]
		# NATION-MODEL-01: tag the batch with the honest nation status so a
		# structural probe can distinguish exact art from the fallback.
		var bnode = b.get("node")
		if is_instance_valid(bnode):
			(bnode as Node3D).set_meta("nation_mesh_label", str(ns["status"]))
			(bnode as Node3D).set_meta("nation_mesh_exact", bool(ns["exact"]))
			(bnode as Node3D).set_meta("nation", str(ns["nation"]))
		var xf := _xf(id)
		(b["xforms"] as Array)[ix] = xf
		(b["mm"] as MultiMesh).set_instance_transform(ix, xf)


func add_building(e) -> void:
	if e == null or game == null:
		return
	var ed := e as Dictionary
	var id := int(ed.get("id", -1))
	if id < 0 or _nodes.has(id):
		return
	_refs[id] = ed
	var base_sid := str(ed.get("sid", ""))
	# NATION-MODEL-01: donor building art is nation-prefixed ONLY in the 2D
	# bake; no 3D <nat>_<sid>.obj exists, so this probes and falls back to the
	# base donor mesh with an explicit PORT APPROXIMATION label.
	var ns := _entity_mesh_sid(ed, base_sid, "building")
	var sid := str(ns["sid"])
	_record_nation_mesh(ns, base_sid)
	var info := _mesh_info(sid, "building")
	var mi := MeshInstance3D.new()
	mi.name = "Building_" + sid + "_" + str(id) + "_STATIC_POSE"
	mi.mesh = info["mesh"]
	mi.set_meta("anim_status", ANIM_STATUS)
	mi.set_meta("mesh_source", str(info.get("source", "?")))
	mi.set_meta("nation_mesh_label", str(ns["status"]))
	mi.set_meta("nation_mesh_exact", bool(ns["exact"]))
	mi.set_meta("nation", str(ns["nation"]))
	# V7-65: per-building tint (each building owns its own MeshInstance3D, so
	# no batching-key change is needed here; surface overrides keep siblings
	# of other players independent while sharing the baked donor mesh).
	var player: int = _player_index(ed)
	# Explicit Variant type (see add_unit): `:=` here is a treated-as-error warning.
	var tint: Variant = _player_tint(player)
	if tint is Color:
		_apply_tint(mi, info["mesh"], tint, sid, "building")
		mi.set_meta("donor_tint_slot", player)
		mi.set_meta("donor_tint_rgb", [tint.r, tint.g, tint.b])
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	_nodes[id] = mi
	mi.transform = _xf(id)
	# MILLFIX F1: only the mill gets a spinning sail child. The parent stays
	# the exact V7-14 static donor MeshInstance3D — no sim/mesh change.
	if sid == "mil":
		_attach_rotor(id, mi)


# MILLFIX F1 — donor-derived face-on rotor bake on a billboarded cutout quad.
# Hub mapping (all donor numbers, no inventions):
#   world.gd:651  hub = tl + sz*MILL_HUB, where tl = p - sz*(cx, foot)
#   buildings.json ukr_mil:579,584-585,587 -> cx=0.4989, foot=ink[3]/cell=1.0
#   => local X = (MILL_HUB.x - cx)*ortho = +0.173 m,
#      local Y = (foot - MILL_HUB.y)*ortho = +5.235 m (tower cap; mesh is 5.917 m),
#      local Z = 0 (billboard plane through tower centre).
# Quad span = MILL_ROTOR_ORTHO (6.352 m), i.e. the full baked cell, NOT half.
func _rotor_mesh() -> Mesh:
	var half := MILL_ROTOR_ORTHO * 0.5
	var vv := PackedVector3Array()
	vv.append(Vector3(-half, -half, 0.0))
	vv.append(Vector3(half, -half, 0.0))
	vv.append(Vector3(half, half, 0.0))
	vv.append(Vector3(-half, half, 0.0))
	# Godot texture UV (0,0) is top-left; map it to the quad's top-left vertex.
	var uv := PackedVector2Array()
	uv.append(Vector2(0, 1)); uv.append(Vector2(1, 1))
	uv.append(Vector2(1, 0)); uv.append(Vector2(0, 0))
	var nn := PackedVector3Array()
	for i in range(4):
		nn.append(Vector3.BACK)
	var idx := PackedInt32Array()
	idx.append(0); idx.append(1); idx.append(2)
	idx.append(0); idx.append(2); idx.append(3)
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vv
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_NORMAL] = nn
	arr[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return mesh


func _rotor_material() -> Material:
	var mat := StandardMaterial3D.new()
	var tex: Texture2D = null
	# MOTION-ANIM-01/ROTOR — the owner's live run showed that a .import file is
	# NOT proof that Godot generated its .ctex: ResourceLoader.load() on the
	# missing cache emitted hard engine ERROR lines from this path. Root cause:
	# the original anim/ PNG sits under .gdignore and is never imported. Try the
	# importable port copy in tex/ FIRST, then the original path as a fallback;
	# decode bytes through FileAccess/Image instead of the import pipeline, so a
	# stale/missing cache can never produce engine ERRORs. Both paths are the
	# SAME shipped PNG and no art is invented. Every load result is checked
	# before use; total failure degrades to a plain white quad.
	for rotor_path in [ROTOR_TEX_IMPORT_PATH, ROTOR_TEX_PATH]:
		if tex != null:
			break
		if FileAccess.file_exists(rotor_path):
			var img := Image.new()
			if img.load(rotor_path) == OK and not img.is_empty():
				tex = ImageTexture.create_from_image(img)
	if tex != null:
		mat.albedo_texture = tex
		# Donor bake has transparent corners; scissor keeps a hard sail
		# silhouette (the port's other donor cutouts use the same policy).
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = 0.5
	else:
		mat.albedo_texture = null
		mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		if not _rotor_fallback_warned:
			_rotor_fallback_warned = true
			push_warning("world3d_entities: " + ROTOR_FALLBACK_STATUS)
	mat.set_meta("rotor_texture_status",
		"donor_png_bound" if tex != null else "fallback_white_untextured")
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Unshaded mirrors the 2D canvas sprite; lighting parity UNVERIFIED.
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat


func _attach_rotor(id: int, parent: MeshInstance3D) -> void:
	if _rotors.has(id) and is_instance_valid(_rotors[id]):
		return
	var rotor := MeshInstance3D.new()
	rotor.name = "MillRotor_" + str(id)
	rotor.mesh = _rotor_mesh()
	var rotor_mat := _rotor_material()
	rotor.material_override = rotor_mat
	rotor.set_meta("rotor_texture_status", rotor_mat.get_meta("rotor_texture_status", "?"))
	var hx := (MILL_HUB.x - MILL_TOWER_CX) * MILL_TOWER_ORTHO
	var hy := (MILL_TOWER_FOOT - MILL_HUB.y) * MILL_TOWER_ORTHO
	rotor.position = Vector3(hx, hy, 0.0)
	rotor.set_meta("visual_status", ROTOR_STATUS)
	rotor.set_meta("donor_source", ROTOR_TEX_PATH)
	rotor.set_meta("donor_meta", ROTOR_META_PATH)
	rotor.set_meta("spin_rad_per_s", MILL_SPIN)
	parent.add_child(rotor)
	_rotors[id] = rotor


# --- BUILD-STAGES-01: donor construction-stage selector ---------------------
# Presentation-only mirror of the sim; nothing here writes back to `e`.
# The port's build counter is `progress` / `def.build_time` (game.gd:2193,
# :4968-4974); the donor's is hp/maxhp (unit.script:6583-6590). Both are
# clamped to 0..1 before the donor's floor(progress*4) selector is applied.
func _build_progress01(ed: Dictionary) -> float:
	if bool(ed.get("finished", true)):
		return 1.0
	var def = ed.get("def", null)
	var build_time := 0.0
	if def is Dictionary:
		build_time = float((def as Dictionary).get("build_time", 0.0))
	if build_time <= 0.0:
		return 0.0
	return clampf(float(ed.get("progress", 0.0)) / build_time, 0.0, 1.0)


# Donor mesh-name suffix: "1".."4" for buildings, "1"/"2" for walls.
# The clamp at progress=1 (unfinished) mirrors the donor `case` having no
# stage_4: the previous stage mesh is kept (DBUILD-01 §2.2, derived).
func _build_stage_suffix(ed: Dictionary) -> String:
	var raw := clampi(int(floor(_build_progress01(ed) * float(BUILD_STAGE_STEPS))),
		0, BUILD_STAGE_STEPS - 1)
	var mesh_stage := raw + 1
	if str(ed.get("sid", "")) == "wal":
		mesh_stage = mini(1 + int(raw / 3), BUILD_WALL_MAX_STAGE)
	return str(mesh_stage)


# Resolve a donor-named converted OBJ. Empty Dictionary means "no art": the
# caller then reuses the base mesh with an explicit PORT APPROXIMATION label.
# BUILD-ART-C-01: centre with the manifest bbox of the resolved art sid
# (<sid><suffix>[a]; suffix "" for the completion scaffold gives <sid>a),
# falling back to the base sid bbox only when no stage entry is in the manifest.
func _stage_mesh_info(sid: String, suffix: String, scaffold: bool) -> Dictionary:
	var key := sid + "|" + suffix + "|" + ("scaffold" if scaffold else "stage")
	if _stage_mesh_cache.has(key):
		var cached = _stage_mesh_cache[key]
		return cached as Dictionary
	var out: Dictionary = {}
	var art_sid := sid + suffix + ("a" if scaffold else "")
	var path := OBJ_DIR + sid + suffix + ("a.obj" if scaffold else ".obj")
	if ResourceLoader.exists(path):
		var src := load(path) as Mesh
		if src != null:
			var has_stage_bbox := _bbox.has(art_sid)
			var bbox: Array = _bbox.get(art_sid, _bbox.get(sid, []))
			var native_h := 1.0
			if bbox.size() >= 6:
				native_h = float(bbox[5]) - float(bbox[4])
			if native_h <= 0.0:
				native_h = 1.0
			out = _bake_mesh(src, bbox, 1.0, native_h, false, sid, "building")
			out["source"] = "obj_scaffold_zup_bbox_normalised" if scaffold else "obj_stage_zup_bbox_normalised"
			out["sid"] = sid
			out["kind"] = "building"
			out["bbox_sid"] = art_sid if has_stage_bbox else sid
			out["bbox_note"] = "per-stage manifest bbox" if has_stage_bbox else "base sid bbox fallback; per-stage bbox absent from manifest"
	_stage_mesh_cache[key] = out
	return out


# Called once per sync() from the building transform loop. Adds a stage meta
# record on the existing parent MeshInstance3D and attach/removes a scaffold
# child in sync with `finished`. The parent's V7-14 static pose identity,
# tint, rotor child and every public API are untouched.
func _sync_building_stages() -> void:
	var stage_hist: Dictionary = {}
	var scaffold_count := 0
	var stage_art_hits := 0
	var stage_approx := 0
	var scaffold_art_hits := 0
	for id in _nodes.keys():
		var mi = _nodes[id]
		if not is_instance_valid(mi):
			continue
		var ed = _refs.get(int(id))
		if not (ed is Dictionary):
			continue
		var e := ed as Dictionary
		var sid := str(e.get("sid", ""))
		var finished := bool(e.get("finished", true))
		var base_info: Dictionary = _mesh_info(sid, "building")
		var base_mesh: Mesh = base_info["mesh"] as Mesh
		var suffix := ""
		var source := "finished_base_mesh"
		var chosen: Mesh = base_mesh
		if not finished:
			suffix = _build_stage_suffix(e)
			var stage_info := _stage_mesh_info(sid, suffix, false)
			if not stage_info.is_empty() and stage_info["mesh"] is Mesh:
				chosen = stage_info["mesh"] as Mesh
				source = str(stage_info.get("source", "stage_obj"))
				stage_art_hits += 1
			else:
				source = "base_mesh_port_approximation"
				stage_approx += 1
		if (mi as MeshInstance3D).mesh != chosen:
			(mi as MeshInstance3D).mesh = chosen
			# BUILD-ART-C-01: _apply_tint() writes surface overrides BY INDEX on
			# the instance. A stage/base swap can change the surface count, so
			# re-apply the donor slot tint on every real mesh change; otherwise
			# the team colour is silently dropped. The base sid keeps the mask.
			var tint: Variant = _player_tint(_player_index(e))
			if tint is Color:
				_apply_tint(mi, chosen, tint, sid, "building")
		var stage_key := suffix if not finished else "finished"
		(mi as MeshInstance3D).set_meta("build_stage_suffix", stage_key)
		(mi as MeshInstance3D).set_meta("build_stage_progress01", _build_progress01(e))
		(mi as MeshInstance3D).set_meta("build_stage_source", source)
		(mi as MeshInstance3D).set_meta("build_stage_label", BUILD_STAGE_LABEL)
		(mi as MeshInstance3D).set_meta("build_stage_visual", "UNVERIFIED")
		stage_hist[stage_key] = int(stage_hist.get(stage_key, 0)) + 1
		# Donor scaffold auto-child (engcen.prop:72-112, ontagstates.inc:253-259).
		var sc = _build_scaffolds.get(int(id), null)
		if finished:
			if sc is MeshInstance3D and is_instance_valid(sc):
				(sc as MeshInstance3D).free()
			_build_scaffolds.erase(int(id))
		else:
			if not (sc is MeshInstance3D and is_instance_valid(sc)):
				var sc_node := MeshInstance3D.new()
				sc_node.name = "Scaffold_" + sid + "_" + str(id)
				sc_node.set_meta("scaffold_label", BUILD_SCAFFOLD_LABEL)
				sc_node.set_meta("scaffold_donor_source",
					"objects/buildings/engcen.prop:72-112; scripts/units/building.inc/ontagstates.inc:253-259")
				sc_node.set_meta("visual_status", "UNVERIFIED")
				sc_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				(mi as MeshInstance3D).add_child(sc_node)
				_build_scaffolds[int(id)] = sc_node
				sc = sc_node
			var sc_info := _stage_mesh_info(sid, suffix, true)
			var sc_art := not sc_info.is_empty() and sc_info["mesh"] is Mesh
			if sc_art:
				(sc as MeshInstance3D).mesh = sc_info["mesh"] as Mesh
				scaffold_art_hits += 1
			else:
				(sc as MeshInstance3D).mesh = base_mesh
			# Hidden placeholder when art is missing: reusing the base mesh
			# would otherwise double-render the parent silhouette. The node is
			# still attached/removed in sync with the donor child's lifecycle.
			(sc as MeshInstance3D).visible = sc_art
			(sc as MeshInstance3D).set_meta("scaffold_source",
				"stage_scaffold_obj" if sc_art else "base_mesh_port_approximation_hidden")
			scaffold_count += 1
	stats["build_stage_counts"] = stage_hist
	stats["build_stage_scaffolds"] = scaffold_count
	stats["build_stage_obj_hits"] = stage_art_hits
	stats["build_stage_approx_nodes"] = stage_approx
	stats["build_scaffold_obj_hits"] = scaffold_art_hits
	stats["build_stage_label"] = BUILD_STAGE_LABEL
	stats["build_stage_visual"] = "UNVERIFIED"


func _resource_sid(ty: String, pos: Vector2) -> String:
	match ty:
		"wood":
			return _pick_sid(POOL_TREE, pos)
		"stone":
			return _pick_sid(POOL_ROCK, pos)
		"gold", "iron", "coal":
			return "mine_" + ty
		"food":
			return "field"
		"bush":
			return _pick_sid(POOL_BUSH, pos)
		"stump":
			return _pick_sid(POOL_STUMP, pos)
	return ""


# Deterministic choice by world position, never RNG (owner: "No RNG").
func _pick_sid(pool: Array, pos: Vector2) -> String:
	if pool.is_empty():
		return ""
	var ix: int = (int(absf(pos.x) * 10.0) * 7 + int(absf(pos.y) * 10.0) * 13) % pool.size()
	return str(pool[ix])


func add_resource(n) -> void:
	if n == null or game == null:
		return
	var nd := n as Dictionary
	var id := int(nd.get("id", -1))
	if id < 0:
		return
	_refs[id] = nd
	if _slot.has(id):
		return
	var ty := str(nd.get("type", ""))
	var sid := _resource_sid(ty, nd.get("pos", Vector2.ZERO))
	if sid == "":
		sid = "__proxy_" + ty           # no donor sid: bbox proxy, tagged in stats
	var info := _mesh_info(sid, "res")
	var key := "res|" + sid
	var ix := _acquire(key, id, info, "res")
	if ix >= 0:
		var b: Dictionary = _batches[key]
		var xf := _xf(id)
		(b["xforms"] as Array)[ix] = xf
		(b["mm"] as MultiMesh).set_instance_transform(ix, xf)


func remove(id) -> void:
	var eid := int(id)
	if _slot.has(eid):
		_release(eid)
	if _nodes.has(eid):
		var mi = _nodes[eid]
		if is_instance_valid(mi):
			# free(), not queue_free(): callers/tests can count nodes in the
			# same frame as remove(); a deferred free would leave a ghost node.
			mi.free()
		_nodes.erase(eid)
	_rotors.erase(eid)   # child is freed with its parent; drop the mirror
	# BUILD-STAGES-01: the scaffold is a child of the freed parent; drop the
	# presentation mirror without a second free of an invalid instance.
	if _build_scaffolds.has(eid):
		var sc = _build_scaffolds[eid]
		if sc is MeshInstance3D and is_instance_valid(sc):
			(sc as MeshInstance3D).free()
		_build_scaffolds.erase(eid)
	_field_visual.erase(eid)
	_motion_sample.erase(eid)
	_face_smooth.erase(eid)
	_applied_pose_frame.erase(eid)
	_refs.erase(eid)


func sync(dt: float) -> void:
	# V7-74: the sim clock drives a deterministic donor AAF frame through
	# anim3d.gd.pose_for() (donor 30 fps, fposmod loop - anim3d.gd:514-520).
	# No RNG, no sprite sheet, no invented keyframe. With no anim module or no
	# registered donor skin this is exactly the V7-14/V7-65 static bind path.
	_anim_t += maxf(dt, 0.0)
	var anim = _find_anim()
	var morph_units := 0
	var static_units := 0
	var frame_changes := 0
	var pose_sources: Dictionary = {}
	var seen_frames: Dictionary = {}
	var morph_rejects: Dictionary = {}
	# MOTION-ANIM-01: presentation telemetry only (no sim write, no parity claim).
	var measured_speeds: Dictionary = {}
	var rendered_actions: Dictionary = {}
	var yaw_clamps := 0
	var frozen_refreshes := 0
	# V7-79: ONE donor sample per (sid, action, frame) per sync(), not per unit.
	# All units in this pass see the same _anim_t, so pose_for() resolves the
	# same donor frame and returns byte-identical verts for a given
	# (sid, action); the cached pose already carries its resolved frame. Cache
	# the whole pose Dictionary (real donor verts + frame + batch fields) and
	# reuse it for later units of that key. The memo is LOCAL to this sync():
	# the next call starts with an empty dict, so a new donor frame is never
	# served stale data. No sprite sheet / RNG / invented value; every label,
	# visual status, tint and auto-loaded skin stays untouched.
	var pose_memo: Dictionary = {}
	# Pass 1: sample the donor pose per unit and migrate it to a frame-keyed
	# (sid, player, action, frame) batch when a real donor morph is available.
	for id in _slot.keys():
		var sl = _slot[id]
		if not (sl is Dictionary):
			continue
		if str((sl as Dictionary).get("class", "")) != "unit":
			continue
		var e = _refs.get(int(id))
		if not (e is Dictionary):
			continue
		var ed := e as Dictionary
		var uid := int(id)
		var sid := str(ed.get("sid", ""))
		var old_key := str((sl as Dictionary).get("key", ""))
		# MOTION-ANIM-01: measure SIM displacement first, then pick the donor
		# action from that measurement. This is the walk-while-stalled fix:
		# `moving:true` at ~0.001 m/s no longer selects the walk cycle.
		var speed := _measure_speed(uid, ed)
		measured_speeds[uid] = speed
		var raw_face := float(ed.get("face", 0.0))
		var smoothed := _smooth_face(uid, raw_face, dt)
		if absf(fposmod(raw_face - smoothed + PI, TAU) - PI) > 0.0001:
			yaw_clamps += 1
		_face_smooth[uid] = smoothed
		var action := _unit_action(ed, speed)
		rendered_actions[action] = int(rendered_actions.get(action, 0)) + 1
		var pose: Dictionary = {}
		var morphed: Dictionary = {}
		if anim != null and anim.has_method("pose_for") \
				and bool(anim.call("has_skin", sid)):
			var memo_key := sid + "|" + action
			if pose_memo.has(memo_key):
				pose = pose_memo[memo_key] as Dictionary
			else:
				var p = anim.call("pose_for", ed, action, _anim_t)
				if p is Dictionary:
					pose = p as Dictionary
				pose_memo[memo_key] = pose
			if not pose.is_empty():
				var verts = pose.get("verts", null)
				if verts is PackedVector3Array and not (verts as PackedVector3Array).is_empty() \
						and str(pose.get("pose_source", "")) == MORPH_POSE_SOURCE:
					var info: Dictionary = _mesh_info(sid, "unit")
					morphed = _morph_mesh(sid, info, int(pose.get("frame", -1)),
						action, verts as PackedVector3Array)
					if morphed["mesh"] == null:
						var why := str(morphed.get("reason", "?"))
						morph_rejects[why] = int(morph_rejects.get(why, 0)) + 1
		if morphed.has("mesh") and morphed["mesh"] != null:
			var tint = (sl as Dictionary).get("tint", null)
			var player := int((sl as Dictionary).get("player", -1))
			var new_key := "unit|" + sid
			if tint is Color:
				new_key += "|p" + str(player)
			var resolved_frame := int(pose.get("frame", -1))
			new_key += "|a" + action + "|f" + str(resolved_frame)
			if new_key != old_key:
				_release(uid)
				var pose_info: Dictionary = {"mesh": morphed["mesh"],
					"source": "donor_flat_root_morph", "sid": sid, "kind": "unit",
					"scale": float((_mesh_info(sid, "unit")).get("scale", 1.0))}
				_acquire(new_key, uid, pose_info, "unit", tint, player, pose)
				frame_changes += 1
			elif resolved_frame != int(_applied_pose_frame.get(uid, -1)):
				# MOTION-ANIM-01 frozen-sim fallback: the slot stayed in the same
				# batch, so the normal release/acquire mesh callback was skipped
				# while the donor pose frame advanced. Rebind the existing batch
				# mesh explicitly (real donor verts only, never a guess). This is
				# a PORT APPROX presentation refresh; whether it is visible at
				# zoom 2.9 / height 20 m is UNVERIFIED (VID-AN-01 §7.4).
				var b = _batches.get(new_key)
				if b is Dictionary:
					var mm: MultiMesh = (b as Dictionary)["mm"]
					if mm != null:
						mm.mesh = morphed["mesh"]
					var node = (b as Dictionary).get("node")
					if is_instance_valid(node):
						(node as Node3D).set_meta("donor_frame", resolved_frame)
				frozen_refreshes += 1
			_applied_pose_frame[uid] = resolved_frame
			pose_sources[MORPH_POSE_SOURCE] = int(pose_sources.get(MORPH_POSE_SOURCE, 0)) + 1
			seen_frames[int(pose.get("frame", -1))] = true
			morph_units += 1
		else:
			static_units += 1
	# Pass 2: unchanged transform contract for morphed, static and resource slots.
	for id in _slot.keys():
		var sl = _slot[id]
		if not (sl is Dictionary):
			continue
		var b = _batches.get(str((sl as Dictionary).get("key", "")))
		if not (b is Dictionary):
			continue
		var mm: MultiMesh = (b as Dictionary)["mm"]
		var xf := _xf(int(id))
		var ix: int = int((sl as Dictionary).get("index", 0))
		var xforms: Array = (b as Dictionary)["xforms"]
		if ix < xforms.size():
			xforms[ix] = xf
		mm.set_instance_transform(ix, xf)
	for id in _nodes.keys():
		var mi = _nodes[id]
		if is_instance_valid(mi):
			mi.transform = _xf(int(id))

	# BUILD-STAGES-01: donor stage selector + stage-synced scaffold child.
	# Runs AFTER the unchanged building transform loop and BEFORE the MILLFIX
	# rotor block, so rotor relocation/fallback stays byte-identical.
	_sync_building_stages()

	# MILLFIX F1: spin the donor-baked sail from the SAME `_anim_t` clock that
	# drives the donor morph pass (no second timer, no RNG). Billboarding uses
	# the node basis rather than material BILLBOARD so the readable local Z
	# rotation stays the authoritative angle: angle = _anim_t * MILL_SPIN,
	# i.e. exactly the donor 0.75 rad/s of world.gd:204/652.
	var rotor_spin := _anim_t * MILL_SPIN
	var vp: Variant = get_viewport()
	var cam: Variant = null
	if vp != null and vp.has_method("get_camera_3d"):
		cam = vp.call("get_camera_3d")
	for id in _rotors.keys():
		var rotor = _rotors[id]
		if not is_instance_valid(rotor):
			_rotors.erase(id)
			continue
		var face := Basis()
		if cam != null:
			var delta: Vector3 = cam.global_position - rotor.global_position
			if delta.length_squared() > 0.0001:
				var d := delta.normalized()
				if absf(d.dot(Vector3.UP)) < 0.999:
					var rx := Vector3.UP.cross(d).normalized()
					var ry := d.cross(rx).normalized()
					face = Basis(rx, ry, d)   # local +Z faces the camera
		# MOTION-ANIM-01/ROTOR: local +Z (FORWARD) makes a positive spin screen-
		# clockwise, matching the donor-derived 2D bake at world.gd:640-654.
		# BACK spun the sail the other way; donor .oss 3D direction UNVERIFIED.
		rotor.transform = Transform3D(
			face * Basis().rotated(Vector3.FORWARD, rotor_spin), rotor.position)
		var re = _refs.get(int(id))
		rotor.visible = re is Dictionary and bool((re as Dictionary).get("finished", true))
	stats["mill_rotor_angle_rad"] = rotor_spin
	stats["mill_rotor_count"] = _rotors.size()
	stats["mill_rotor_label"] = ROTOR_STATUS
	stats["mill_rotor_spin_axis_label"] = ROTOR_SPIN_AXIS_STATUS
	stats["mill_rotor_texture_fallback_used"] = _rotor_fallback_warned

	# MILLFIX F2: per-field visual state, read-only on the sim. game.field_state()
	# / field_growth01() are the SAME methods the HUD and 2D renderer use
	# (game.gd:2210-2228, world.gd:2550-2559). Tints and relative scales below
	# are copied verbatim from the 2D stage rules (world.gd:2588-2613); the
	# footprint replaces the 58.5 m donor bbox with the sow-step span
	# (game.gd:2120). No res_nodes mutation, no res_dirty bump, no new node.
	var field_states: Dictionary = {}
	var field_total := 0
	var field_scale := 1.0
	var fbb: Array = _bbox.get("field", [])
	if fbb.size() >= 6:
		var native_span := maxf(float(fbb[1]) - float(fbb[0]), 0.001)
		field_scale = FIELD_SPAN_M / native_span
	for key in _batches.keys():
		if key != "res|field":
			continue
		var bd := _batches[key] as Dictionary
		var mm: MultiMesh = bd["mm"]
		var ids: Array = bd["ids"]
		var xforms: Array = bd["xforms"]
		for i in range(ids.size()):
			var fid := int(ids[i])
			var fe = _refs.get(fid)
			var st := ""
			var g := 0.0
			if game != null and fe is Dictionary:
				if game.has_method("field_state"):
					st = str(game.call("field_state", fe))
				if game.has_method("field_growth01"):
					g = clampf(float(game.call("field_growth01", fe)), 0.0, 1.0)
			if st == "":
				st = "ripe" if g > 0.0 else "depleted"
			var col := Color(1, 1, 1, 1)
			var rel := 0.68 / 4.6
			match st:
				"ripe":
					col = Color(3.3, 2.5, 1.0, clampf(0.42 + 0.28 * g, 0.0, 1.0))
					rel = (1.6 + 0.7 * g) / 2.3
				"growing":
					col = Color(0.9, 1.6, 0.7, clampf(0.45 + 0.30 * g, 0.0, 1.0))
					rel = (1.1 + 0.9 * g) / 2.0
				"regrowing":
					var pulse := 0.75 + 0.25 * sin(_anim_t * 4.0 + float(fid) * 0.37)
					col = Color(lerpf(0.9, 3.3, g), lerpf(1.5, 2.5, g), 0.7,
						clampf(0.40 + 0.30 * g, 0.0, 1.0) * pulse)
					rel = (1.1 + 0.9 * g) / 2.0
				_:
					# Bare stubble: 2D span0*2 / ripe width = 0.68/4.6.
					col = Color(0.30, 0.26, 0.16, 0.60)
					rel = 0.68 / 4.6
			field_states[st] = int(field_states.get(st, 0)) + 1
			field_total += 1
			var s := field_scale * rel
			var xf: Transform3D = _xf(fid)
			xf.basis = xf.basis.scaled(Vector3(s, s, s))
			xforms[i] = xf
			mm.set_instance_transform(i, xf)
			mm.set_instance_color(i, col)
			_field_visual[fid] = {"state": st, "color": col, "scale": s}
	stats["field_visual_states"] = field_states
	stats["field_visual_count"] = field_total
	stats["field_visual_span_scale"] = field_scale
	stats["field_visual_target_span_m"] = FIELD_SPAN_M
	stats["field_visual_label"] = FIELD_STATUS
	var units := 0
	var ress := 0
	var tinted_batches := 0
	for key in _batches.keys():
		var bd := _batches[key] as Dictionary
		var cls := str(bd.get("class", ""))
		var n: int = bd["ids"].size()
		if bd.get("tint") is Color:
			tinted_batches += 1
		if cls == "unit":
			units += n
		else:
			ress += n
	var tinted_buildings := 0
	for id in _nodes.keys():
		if (_nodes[id] as Node).has_meta("donor_tint_rgb"):
			tinted_buildings += 1
	stats["tinted_batches"] = tinted_batches
	stats["tinted_buildings"] = tinted_buildings
	stats["batches"] = _batches.size()
	stats["units"] = units
	stats["resources"] = ress
	stats["buildings"] = _nodes.size()
	stats["anim_clock_s"] = _anim_t
	# V7-74 measured morph telemetry (never a visual-parity claim).
	stats["donor_morph_units"] = morph_units
	# V7-79: actual pose_for() calls this frame (one per memo key, not per
	# unit). Structural telemetry, not a visual-parity claim.
	stats["donor_morph_pose_samples"] = pose_memo.size()
	stats["donor_morph_static_units"] = static_units
	stats["donor_morph_frame_changes"] = frame_changes
	stats["donor_morph_meshes_cached"] = _morph_meshes.size()
	stats["donor_morph_frames"] = seen_frames.keys()
	stats["donor_morph_pose_sources"] = pose_sources
	stats["donor_morph_rejects"] = morph_rejects
	stats["donor_morph_anim_available"] = anim != null
	# MOTION-ANIM-01: measured presentation telemetry (structural/numeric only;
	# no sim mutation, no donor-parity or visual claim).
	stats["motion_measured_speeds_m_s"] = measured_speeds
	stats["motion_rendered_actions"] = rendered_actions
	stats["motion_yaw_clamps"] = yaw_clamps
	stats["motion_frozen_pose_refreshes"] = frozen_refreshes
	anim_handoff["applied"] = morph_units > 0
	anim_handoff["morph_units"] = morph_units
	anim_handoff["label"] = PORT_LABEL
	anim_handoff["visual"] = "UNVERIFIED"
