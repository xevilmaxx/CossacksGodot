# FIELD-WINTER-01 — standalone winter field-crop decal helper (new file only).
#
# AUTHORING ONLY. This is a NEW file: it does not edit any existing port source,
# asset, config, test or manifest; it is not registered, instantiated, called or
# wired into any scene/runner. No Godot process was run and no PASS is claimed.
#
# WHY THIS EXISTS
#   DSEASON-01 §2.3 (docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md:109-118)
#   found the explicit donor season binding, read-only:
#     C:\Games\Cossacks 3\data\terrain\decals\decals.lib:37-44
#       Decal.SummerLibMaterialName = envfieldd
#       Decal.WinterLibMaterialName = envfielddw
#   registered at decals.mat:110-115; both are DXT5 512x512 (DEC-05 §4.2) with
#   the IDENTICAL alpha footprint bbox (17,19,494,494) and opaque means
#   #4D442E (summer) / #756F61 (winter) (docs/audit/PIECES/field_crops.md §1.1).
#   The port records the two res:// paths in stats only
#   (world3d_entities.gd:244-245, :328-333) and never draws them — DSEASON-01
#   gap rank 4 (:175). This helper exposes the donor-grounded *decision data*
#   for the owner of world3d_entities.gd to call. It draws nothing itself.
#
# LABELS USED BELOW
#   OBSERVED     = literal donor lines / on-disk port pixels read this task.
#   DERIVED      = arithmetic over observed values (channel/255 -> Color).
#   INERT_DATA   = real donor config bytes whose native consumer is engine-side.
#   PORT APPROX  = port-side choice, NOT donor parity; no donor GPU A/B was run.
#   UNVERIFIED   = native EXE activity of `;`-prefixed .inc lines (DEC-05 §8 Q3),
#                  donor 3D UV mapping, render-time gold tint, Desert binding.
#
# DONOR CITATIONS (all read-only, no donor file copied, run or modified)
#   decals.lib:37-44              summer/winter decal material names  [OBSERVED]
#   decals.mat:110-115            name -> .\data\terrain\decals\env\*.dds [OBSERVED]
#   env\envfieldd.dds / envfielddw.dds   DXT5 512x512, same alpha bbox [OBSERVED]
#   field_crops.md:31-41,54-72    alpha bbox/means; port PNG conversion notes
#   scripts\lib\misc.script:4284-4295, miscext2.script:772
#                                 single `envfieldd` spring point; winter comes
#                                 from the decal library, not a second branch
#   objects\env\field.prop:152-157  //DefaultDecalName = envfieldd -> DISABLED_INTENT
#   DSEASON-01:109-118,170-181    season matrix + rank-4 port gap
#   DEC-05 §4.2 / §8 Q3           DDS format facts; `;`-line activity UNVERIFIED
#   DEC-08 §5.2 / §6.1            minimap primitives + brush handling are UI-only;
#                                 no field-decal consumer exists in DEC-08.
#
# NO INVENTED ASSETS: the two res:// paths below are the exact constants already
# present at world3d_entities.gd:244-245. No texture is generated or copied.

extends RefCounted

const PORT_LABEL: String = "PORT APPROXIMATION — NOT DONOR PARITY"
const STATUS: String = PORT_LABEL + " — donor binding is INERT_DATA; native EXE activity UNVERIFIED; no donor GPU A/B; 3D UV mapping UNVERIFIED"

# Season values mirror Data.SEASON_ENUM (data.gd:227: summer=0, winter=2,
# desert=3). Value 1 is UNVERIFIED and deliberately not encoded (data.gd:224-226).
const SEASON_SUMMER: int = 0
const SEASON_WINTER: int = 2
const SEASON_DESERT: int = 3

# Donor material names, verbatim from decals.lib:37-44 / decals.mat:110-115.
const DONOR_SUMMER_MATERIAL: String = "envfieldd"
const DONOR_WINTER_MATERIAL: String = "envfielddw"
const DONOR_DECALS_LIB: String = "C:\\Games\\Cossacks 3\\data\\terrain\\decals\\decals.lib:37-44"
const DONOR_DECALS_MAT: String = "C:\\Games\\Cossacks 3\\data\\terrain\\decals\\decals.mat:110-115"

# Port asset paths, copied unchanged from world3d_entities.gd:244-245.
# Both files exist on disk this task and carry the donor alpha footprint:
# 512x512 RGBA, alpha mean 148.1, a>8 bbox (17,19,494,494), opaque means
# (77.2,68.4,46.1) / (116.7,111.1,97.1).  [OBSERVED, read-only Pillow]
const SUMMER_DECAL_PATH: String = "res://assets/terrain/deco_png/envfieldd.png"
const WINTER_DECAL_PATH: String = "res://assets/terrain/deco_png/envfielddw.png"

# Donor opaque means (field_crops.md:38, :224): summer (77.2,68.4,46.1) ->
# #4D442E = (77,68,46)/255; winter (116.7,111.1,97.1) -> #756F61 =
# (117,111,97)/255 (DSEASON-01:113-114). Kept as literals INSIDE decal_color()
# rather than const constructors, so this file has no constant-expression
# dependency that could only be verified by a Godot parse (none was run).


# --------------------------------------------------------------------------- API

# The winter path as a pure constant: no load, no side effect, no existence
# probe. Callers keep their own ResourceLoader.exists() gate
# (world3d_entities.gd:331-332), so a missing import cache degrades quietly.
static func winter_decal_path() -> String:
	return WINTER_DECAL_PATH


# Season -> res:// decal path. Winter is the donor-bound `envfielddw`; Summer
# (and every non-winter season) falls back to `envfieldd`. Deserts have NO donor
# field-decal binding — this fallback is PORT APPROX, not a donor claim.
static func decal_path(season: int) -> String:
	return WINTER_DECAL_PATH if season == SEASON_WINTER else SUMMER_DECAL_PATH


# Season -> decal tint, DERIVED from the donor decal opaque means.
#   0 (summer) -> #4D442E, donor (77.2, 68.4, 46.1)
#   2 (winter) -> #756F61, donor (116.7, 111.1, 97.1)
#   1 (UNVERIFIED enum value) and 3 (desert, no binding) -> SUMMER value.
# PORT APPROX: the donor gold screenshot colour is a render-time tint
# (field_crops.md:44-47 / DSEASON-01:118), NOT these decal bytes; this helper
# never manufactures a gold or a desert colour.
static func decal_color(season: int) -> Color:
	if season == SEASON_WINTER:
		return Color(117.0 / 255.0, 111.0 / 255.0, 97.0 / 255.0, 1.0)
	return Color(77.0 / 255.0, 68.0 / 255.0, 46.0 / 255.0, 1.0)


# Gate: true only for the two seasons with an explicit donor decals.lib binding
# (0 summer, 2 winter). Season 1 is UNVERIFIED (data.gd:224-227) and season 3
# (desert) has no donor field-decal binding (DSEASON-01 §2.3), so neither may
# silently acquire a decal. This gates the SEASON, not the entity: growth stage
# and field-node presence stay with the caller (world3d_entities.gd:265, :430).
static func should_draw(season: int) -> bool:
	return season == SEASON_SUMMER or season == SEASON_WINTER
