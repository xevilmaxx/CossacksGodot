# Original Cossacks 3 stats, read from the game's own data files.
# Deep-mode decompilation fresh run 2026-11-17: C:\Games\Cossacks 3\cossacks.exe (PE x86, entry 0x8f1a08,
# sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, 18918 funcs, 12073 strings)
# waited for every result: native_strings_find peasant ev_35f172bb / pikeman ev_36f8c402 / Serdiuk ev_02657a9a /
# damage ev_b080109a / food ev_fd251932 / wood ev_a22a063b / gold ev_4c3035c2 / mine ev_e50560fd / cannon ev_7d44631c /
# .ini ev_ea29aa57 = 0 hits; engine strings XDMScript @0x958d1a ev_c58219d8, XCamera @0x958b6b/@0x959066 ev_aa633a3e,
# DMScript ev_a290cdaf, Cossacks 3 @0x96b304 ev_18cb6d74, Warning @0x955e34 ev_10cfab87;
# native_xrefs_list 0 refs ev_9945c378 ev_5a0f553a ev_1e8d950e ev_bc64940b ev_ff7ce366 ev_113114fb;
# core_feature_find Cossacks 3 ev_f2d20363 / Camera ev_f1ed6d4b / DMScript ev_1703acd5 0 funcs;
# native_function_pseudocode entry @0x8f1a08 ev_03507405 (142 lines) / sub_8f0ad4 @0x8f0ad4 ev_dec6ad57 /
# sub_47c804 @0x47c804 ev_bd3eda2b / sub_4c37dc @0x4c37dc ev_d5891fef (dlcs.ini/mods.ini) /
# sub_404574 @0x404574 ev_39b2ec80, 34 callees ev_9dbee4f4 — packed launcher, no economy/combat numbers in static code,
# so the authoritative numbers are the shipped scripts below (see ../MECHANICS.md).
# Sources per value are in ../MECHANICS.md. Conversions:
#   seconds = frames * 0.03125   (gc_time_to_frames = 32)
#   meters  = pixels / 26.6666666   (gc_pixels_to_meter)
#   tiles   = meters / 2
extends RefCounted
class_name C3Data

const FRAMES_TO_TIME := 0.03125
const PX_TO_M := 1.0 / 26.6666666
const TILE_M := 2.0

# ─── PORT1TO1 SKIRMISH UNVERIFIED / APPROXIMATION REGISTER ───────────────────
# NO PARITY CLAIM. Network / multiplayer is OUT OF SCOPE.
# Authority: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_skirmish_logic.md
#   §13 U1-U20 (each [U] with its decomp plan) and §14 items 1-18.
# Every value below that has no donor-grounded literal stays [U] with its
# decomp plan cited in place. No number was invented, no gate weakened.
#   U1 tick order · U2 order predicates · U3 tower gate · U4 capture ·
#   U5 train/queue · U6 market · U7 damage matrix · U8 dispersion ·
#   U9 deploy/gold-fire delay · U10 morale (donor has NONE) · U11 famine roll ·
#   U12 victory · U13 start stock · U14 stat rows · U15 save format ·
#   U16 selection predicate · U17 camera · U18 fog/minimap ·
#   U19 AI thresholds (ai.gd is OUT OF AUTHORIZED SCOPE) · U20 RNG draw ledger.
# Donor-grounded literals already applied (do NOT relabel as [U]):
#   FPS=32 (dmscript.global:174), FRAMES_TO_TIME=1/32, PX_TO_M=1/26.6666666,
#   TILE_M=2, UPKEEP_DIVISOR=625 (player.script), MINE_INCOME=13*32/250
#   (player.script:240-266), DELIVERY_RADIUS=3 tiles (dmscript.global:210),
#   BUILD_PROGRESS_PER_HIT=10*0.03125*1.15 (dmscript.global:182),
#   BUILD_HIT_INTERVAL=1.25 (cWalkIntervalInf), MAX_BUILDERS=30
#   (dmscript.global:159), ARROW_DISPERSION_PX=175 (weapon.script archer),
#   GENERATOR_VERSION=91 + gates (serial.script:27 / initmapgen.inc),
#   21 nation sids (country.script:138-206), gold-fire-stop <4 gold +
#   100-frame delay (unit.script:8185-8201), RESOURCE_WORKERS caps
#   (dmscript.global:222-225). All other numbers are [U] with a plan below.
# ─────────────────────────────────────────────────────────────────────────────

# ─── DEC-U COLLISION-CALLER SINGLE SOURCE (§5.3 / §6 P11–P15) ─────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md.
# [O]/[D] = statically recovered with the evidence ids named in that report;
# [U] = unresolved and keeps a named experiment. NO PARITY CLAIM. Caller geometry
# only: no mask bitmap and no ray test is invented here.

# Unit/frame conversions (§5.3 ev_a3ba…, §5.1 ev_7c9a…).
const DEC_U_PX_PER_TILE := 53.3333333          # _misc_PixelsToTiles = val/53.3333333
const DEC_U_FRAMES_PER_TIME := 32.0            # gc_time_to_frames = 32
const DEC_U_COLLISION_CELL_M := 0.5            # gc_collision_size = 0.5

# Gameplay radii -> metres, single source (§5.3 ev_eeca…/ev_a3ba…; §6 P11).
const DEC_U_R_DEFAULT_M := 10.0 / DEC_U_PX_PER_TILE * TILE_M   # 0.375 m
const DEC_U_R_MOUNT_M := 15.0 / DEC_U_PX_PER_TILE * TILE_M     # 0.5625 m
# [U] U12-ships: the donor pixel list is [O] (40/70/35/50/45/80/90/80/90 px),
# the sid->slot mapping is NOT. Never invent a mapping; experiment E-U12b.
const DEC_U_R_SHIPS_PX := [40.0, 70.0, 35.0, 50.0, 45.0, 80.0, 90.0, 80.0, 90.0]
const DEC_U_R_SHIPS_M := [1.5, 2.625, 1.3125, 1.875, 1.6875, 3.0, 3.375, 3.0, 3.375]
const DEC_U_R_FORMATION_M := [8.0 / DEC_U_PX_PER_TILE * TILE_M,
	12.0 / DEC_U_PX_PER_TILE * TILE_M]                          # 0.30 / 0.45 m
const DEC_U_MELEE_RADIUS_TILES := 3.5                          # gc_unit_meleeattackradius
const DEC_U_MELEE_RADIUS_M := DEC_U_MELEE_RADIUS_TILES * TILE_M  # 7.0 m
const DEC_U_EPSILON_DISTANCE_M := 0.25
const DEC_U_UNCOLLIDE_DELTA := 0.05

# Unit collision geometry (§5.3 ev_3c27…): AABB, sphere, CI solver inputs.
const DEC_U_UNIT_AABB_MIN := Vector3(-0.25, -0.10, -0.25)
const DEC_U_UNIT_AABB_MAX := Vector3(0.25, 0.90, 0.25)
const DEC_U_UNIT_SPHERE_R := 0.32
const DEC_U_UNIT_CI_RADIUS := 0.16
const DEC_U_UNIT_CI_MASS := 1.0
# One donor building AABB is [O] (ev_3f82…); every other sid is [U] U12.
const DEC_U_EURMIL_AABB_MIN := Vector3(-0.70, -0.15, -0.60)
const DEC_U_EURMIL_AABB_MAX := Vector3(0.60, 2.20, 0.65)
const DEC_U_EURMIL_SCALE := 0.43

# Donor collision TAGS (§5.3 ev_fb59…), distinct from the renderer terrain enum.
const DEC_U_TAG_NONE := 0
const DEC_U_TAG_BRIDGE := 10
const DEC_U_TAG_BUILDING := 80
const DEC_U_TAG_TERRAIN := 101
const DEC_U_TAG_WATER := 87
const DEC_U_TAG_WATERBORDER := 110
const DEC_U_TAG_LANDBORDER := 109
const DEC_U_TAG_STRETCHLAND := 85
const DEC_U_TAG_WALL := 95
const DEC_U_TEST_EQUAL := "ctpoEqual"
const DEC_U_TEST_GREATER := "ctpoGreater"
const DEC_U_WATER_TEST := DEC_U_TEST_EQUAL
const DEC_U_LAND_TEST := DEC_U_TEST_GREATER

# U-inertia: the NUMERIC text IS recovered (DEC-U-COLLISION-FULL §6,
# dmscript.global:969-974 ev_c875…): mass 1/1.5/3, CI radius 0.16/0.1/0.1,
# build -> 0.0. See DONOR_COLL_INERTIA_TEXT / DONOR_COLL_CI_CLASS_ROWS /
# DONOR_COLL_CI_BUILD_RULE appended below. `XCollisionInertia` /
# `3XCollisionInertia` remain .rsrc class names (P1) with 0 static xrefs (P4);
# ENGINE-SIDE stand/attack switching stays [U] U-inertia (runtime shoving
# capture, §6). Sentinel, NEVER read by a consumer. Experiment E-U13-inertia
# (RTTI field dump) retained for that engine-side switch only.
# DEC-U-INERTIA-RTTI R1 (report §5 R1): KEEP this sentinel `null`, NEVER read.
# RTTI field offsets/count/types stay [U] U-offsets (capture S-OFFSETS); in-binary
# numeric defaults stay [U] U-ctor (S-CTOR); the meaning of the `3` prefix stays
# [U] U-prefix (S-PREFIX) — only the `3XCollisionInertia` spelling exists (P1);
# the engine shove/separation solver law stays [U] U-solver (S-SOLVER). The
# stand/attack CONSUMER stays [U] U-mass-switch / U-radius-switch (S-STAND /
# S-RADIUS) even though its 1.5/3 and 0.1/0.1 VALUES are [O] defined with zero
# sampled readers (§2.4). Build-switch order is [O] text guarded by S-BUILD.
# Every DONOR_COLL_* block appended below is INERT DATA/TELEMETRY ONLY: no
# consumer wired, no solver law added, NO PARITY CLAIM.
static var DEC_U_COLLISION_INERTIA: Variant = null

# Building death keys are [O] but their visual use is [U] U14 (§4.1).
const DEC_U_BUILDING_DEATHTIME_FRAMES := 30      # gc_building_deathtime_0/_1 = 30
const DEC_U_BUILDING_DEATHTIME_S_SHOWN := 30 * FRAMES_TO_TIME  # 0.9375 s; shown, not endorsed

static func dec_u_pixels_to_tiles(px: float) -> float:
	return px / DEC_U_PX_PER_TILE

static func dec_u_pixels_to_metres(px: float) -> float:
	return dec_u_pixels_to_tiles(px) * TILE_M

static func dec_u_frames_to_time(frames: float) -> float:
	return frames * FRAMES_TO_TIME

static func dec_u_collision_test(actual: int, required: int, op: String) -> bool:
	# [I] from the donor enum NAMES ctpoEqual / ctpoGreater (ev_fb59…).
	# Exact engine compare operands remain [U] U13 (experiment E-U13-tag).
	if op == DEC_U_TEST_GREATER:
		return actual >= required
	return actual == required

# ─── DEC-U-FOG-CAMERA-HUD §1 — RESOLVED donor vision law (data.gd mirror) ──────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_fog_camera_hud.md §1.1/§1.2.
# [O] unit.script:11567-11571 — cBaseVal=20, cModVal=4; the 18/3.6/3.75 rows at
#     :11568-11569 are commented-out DEAD alternates and are NOT ported.
# [O] dmscript.global:1439 — gc_properties_stringtag_fogreveal = 109.
# The integer floor() is load-bearing: vision 0/1/3/8 -> 20/24/32/52.
# FOW grid cell size, max/sum combine and occlusion stay [U] F1-GRID with the
# GetFOWLOSData transect experiment (DEC-U §1.4). NO PARITY CLAIM.
const DEC_U_FOG_BASE := 20
const DEC_U_FOG_PER_VISION := 4
const DEC_U_FOGREVEAL_TAG := 109

# ─── DEC-U-VISION-AUDIT §§3-4 — FULL resolved donor sid→vision table ───────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_vision_audit.md
#            (read-only donor text pass P2-P7, 2026-11-26; donor binary NEVER run).
# [O] unit.script:636-2581, all rows resolved. Keys are LITERAL donor sid strings,
#     NOT loop expressions: the old commonsid-concatenation keys could never
#     match an entity; replaced by spapor/porpor and the six literal *tow sids.
#     Port short sids ("cen", "tow", ...) are NOT donor sid strings;
#     the sid→def mapping stays [U] F1-GRID and is never guessed here.
# [O] CORRECTION (audit P4/P7): :2167, :2236 and :2550+ are DIRECT
#     `objprop.vision := N` writes, NOT SetObjBaseSearchBuildVisionScore calls.
#     All other cited rows are Set... calls; `default` (-1) = keep prior value.
# [D] Brace values are dead Pascal comments, NEVER ported: :1358 `5{8}`, :1412
#     `4{8}`, :1717 `1{8}`, law :11568-11569 `18/3.6/3.75`. Active values are
#     the integers OUTSIDE the braces (5/4/1, law = floor(20+4·vision)).
# [I] Unwritten standard buildings (mills/markets/storage/walls/mines, and
#     eurpor/ruspor/turpor/ukrpor where `commonpor` is false) have NO donor
#     write; stored 0 is an auditable placeholder, NOT a donor-verified value.
# [U] Record zero-init (→ res 20), res unit (cells vs metres), FOW cell size and
#     combine stay UNVERIFIED — P-VIS-PROBE / F1-GRID (audit §9). NO PARITY
#     CLAIM. Helper default `.get(sid, 0)` is unchanged: it IS the donor mis*-
#     else 0 (:2581) plus the [I] building defaults. Nothing invented here.
# [O] Exact deciding-line cites for the report's spot-check rows:
#     misflagman :2069(D)=8 · hetman :1475=7 · drummer18 :1135=8 ·
#     cannon :1717=1 (`1{8}` dead [D]) · archerscodip :1015/:1050=2
#     (absent from the :613 bmercenary sid list, so no M row ever fires).
const DEC_U_DONOR_VISION := {
	# ── infantry / officers / drummers / priests / peasants ──
	"pikeman": 1, "pikemanpol": 1, "pikemantur": 1, "pikemanrus": 1,
	"pikemansco": 2, "pikemanpor": 1, "pikemanspa": 1, "pikemanswi": 1, # :636/:668
	"pikeman18": 2, "pikeman18swe": 1,                                 # :698/:708
	"lightinfantry": 2, "lightinfantrydip": 1,                         # :717/:726(M)
	"roundshier": 1, "roundshierdip": 1, "swordsmansco": 2,            # :741/:761(M)/:752
	"musketeer": 2, "musketeerpol": 1, "musketeernet": 2, "pandur": 2,
	"chasseur": 4, "highlander": 1, "serdiuk": 2, "jannisary": 1,
	"musketeersco": 2, "gauduk": 2, "pandurhun": 3, "jagerpor": 1,
	"jagerswi": 4,                                                     # :782-:893
	"musketeerspa": 1, "musketeeraus": 1, "strelet": 1,                # :908
	"musketeer18": 2, "musketeer18pru": 2, "musketeer18bav": 2,
	"musketeer18den": 2, "musketeer18sax": 2,                          # :954-:993
	"archer": 2, "archerdip": 1, "archertur": 1, "archerturdip": 1,
	# [O] archerscodip is absent from the :613 bmercenary sid list => no M row
	#     ever fires; it keeps the sco-branch 2 (not 1 like the other dip hires).
	"archersco": 2, "archerscodip": 2,                                 # :1015-:1050
	"officer": 2, "officerrus": 1, "officertur": 3, "officersco": 2,
	"officer18": 4,                                                   # :1068-:1105
	"drummer": 6, "drummerrus": 5, "drummertur": 7,
	"bagpiper": 5, "drummer18": 8,                                     # :1118-:1147
	"priest": 1, "pope": 1, "mullah": 1, "padre": 1,                   # :1157-:1186
	"peaaus": 1, "peatur": 1, "pearus": 3, "peapol": 1, "peaspa": 1,
	"peaeng": 1, "peaukr": 4, "peasco": 1,                             # :1196-:1218
	"grenadier": 2, "grenadierdip": 1, "grenadierden": 2,
	"grenadierpru": 2, "grenadierbav": 2, "grenadiersax": 2,
	"grenadierhun": 2,                                                 # :1243-:1309
	# ── cavalry ──
	"croat": 2, "hussar": 3, "hussarpru": 5, "wingedhussar": 2,        # :1327-:1367
	# [O] cossacksichdip: non-merc 3 (:1375) / merc-hire 1 (:1383); §8 stores
	#     the mercenary-hire value, the row cited in the report's recommendation.
	"cossacksich": 3, "cossacksichdip": 1,                             # :1375/:1383(M)
	"hackapell": 3, "raidersco": 2, "hussarhun": 3, "hussarswi": 4,    # :1343/:1396/:1404/:1412
	"reiter": 1, "cuirassier": 3, "reiterswe": 2, "reiterpol": 3,
	"hetman": 7, "cossackdon": 3, "vityaz": 2, "cossackregister": 3,
	"spakh": 3, "mameluke": 3, "guardcavalrysax": 3, "lancersco": 2,
	"sipahi": 2,                                                       # :1426-:1538
	"dragoon": 3, "kingmusketeer": 4, "dragoon18fra": 2,
	"dragoonpol": 2, "dragoon18net": 3, "dragoon18pie": 5,
	"lightcavalry": 2, "dragoon18": 3, "dragoon18dip": 1,
	"lightcavalrydip": 1,                                              # :1556-:1652
	"tatar": 4,                                                        # :1681
	# ── artillery / ships / mission units ──
	"cannon": 1, "howitzer": 1, "mortar": 1, "multicannon": 1,         # :1717 (`1{8}`, 8 dead [D])
	"framegun": 1, "fishboat": 1, "ferry": 1, "unitbox": 1,            # :1748-:2054
	"yacht": 3, "yachttur": 3, "galley": 2,                            # :1888/:1918/:1945
	"frigate": 8, "xebec": 8, "battleship": 8, "chaika": 4,            # :1974-:2023
	"misdonkey": 1, "mistrader": 1, "misflagman": 8, "misgeneral": 1,  # :2060/:2069(D)/:2082
	# ── buildings: literal sids ──
	"eurtow": 3, "rustow": 3, "turtow": 3,                             # :2236 (D, unconditional)
	"spatow": 3, "ukrtow": 3, "portow": 3,                             # :2236 (D, unconditional)
	"spapor": 3, "porpor": 3,                                          # :2167 (D, commonpor gate)
	"misblg": 3, "misblg2": 3, "misyurt": 2, "miscommandcenter": 2,    # :2550/:2560/:2569 (D)
	# ── [I] unwritten buildings → presumed 0 (probe §9; helper default covers mis*-other :2581) ──
	"eurpor": 0, "ruspor": 0, "turpor": 0, "ukrpor": 0,                # no write (commonpor false)
}

static func dec_u_donor_vision(sid: String) -> int:
	return int(DEC_U_DONOR_VISION.get(sid, 0))

const RES_NAMES := ["food", "wood", "stone", "gold", "iron", "coal"]
const RES_ICONS := [Rect2(0, 418, 44, 38), Rect2(49, 418, 40, 38), Rect2(93, 418, 41, 38), Rect2(141, 418, 39, 38), Rect2(186, 418, 42, 38), Rect2(235, 418, 37, 38)]

# ------------------------------------------------------------------ settings
# Every number below can be changed from the global settings file
# (config.json, read when the game starts). The values that are here are the
# ones from the original game; the file overrides them. Sources in MECHANICS.md.
static var FPS := 32.0                       # game logic rate, dmscript.global:174
static var MAP_W := 160                     # tiles (the port map; original is 640)
static var MAP_H := 160
static var RANDOM_SEED := 20261113
# P-31: donor generator-version gates. Read-only from
# data/scripts/common.inc/initmapgen.inc (:78,:84,:103,:109,:121,:273,:280) and
# dogenerate.inc (:559,:573,:584,:606,:617,:628,:660,:735,:774,:1093,:1175,:1547).
# The port records the newest version (91), so every "<" gate is false and the
# legacy single-stream seeds/dumps stay byte-identical. The donor also has a <90
# gate at dogenerate.inc:660 (not in the DB_SCRIPTS summary).
static var GENERATOR_VERSION := 91
const GENERATOR_VERSION_GATES := [53, 61, 63, 68, 70, 75, 77, 80, 89, 90, 91]
static func generator_gate(v: int) -> bool:
	return int(GENERATOR_VERSION) < v
# [U] U13: port estimate — no donor start-stock/peasant literal is readable.
# Decomp plan: X09 §7 items 1-7 (`addresources` per preset incl. the double-add
# quirk DG:283, mask walker, 4 occupancy contributions, two insertion points).
static var START_PEASANTS := 8               # estimated, the original default was not in readable files
static var START_RESOURCES := {}             # food, wood, stone, gold, iron, coal
static var DEPOSITS := {}                    # how much gold/iron/coal lies in the ground
static var BATTLE_ARMY := {}                 # the army each side gets in battle mode
# [U] U5 / §14 item 5: queue cap, builder batch and battle-mode army are
# port-side. Decomp plan: player.script train/research producer fns → cost,
# time and cap literals; until then these stay PORT APPROXIMATION, never gates.
# DEC-U-VICTORY-START §4.2 / §5-7 [O]: donor slot cap is
# gc_obj_MaxOrderCount = 12 (dmscript.global:113); the order-slot iteration that
# consumes it is doprogressorders.inc:217-234. The port's 10 was 2 slots short
# and is raised to the donor literal. CAVEAT (still PORT APPROXIMATION): the
# donor counts ORDER SLOTS (a batch lives in one order's `amount`), the port
# counts jobs; rewiring the queue is a game.gd-side change (out of scope).
const DONOR_MAX_ORDER_COUNT := 12          # dmscript.global:113 [O]; doprogressorders.inc:217-234
static var BUILD_QUEUE_LIMIT := DONOR_MAX_ORDER_COUNT
static var MAX_BUILDERS_SENT := 8            # PORT APPROXIMATION: donor mine/farm/btime tiers (DEC-U-VICTORY-START §4.2)
# [U] U12 / §14 item 2: port estimate — donor skirmish end condition was NOT
# recovered. Decomp plan: player.script / donewgame.inc / menu cfg
# (victory|score|peacetime keys); never gate on these until cited.
# DEC-U-VICTORY-START §1.3 / §5-2 [O-absence]: startingsettings.cfg has NO
# victory/score/timelimit key; the only `victorystate := win` write in readable
# scripts is scenario-trigger-gated (scenario.script:2995-3062), NOT a skirmish
# auto-rule. So SCORE_LIMIT=5000 has NO donor counterpart: it stays strictly
# PORT EXTENSION, never a 1:1 gate. Never invent a score threshold or timer.
static var VICTORY := "destroy_all"          # or "score" — PORT EXTENSION
static var SCORE_LIMIT := 5000.0              # PORT EXTENSION (no donor value)
# [U]-U12 / PORT EXTENSION: donor score-limit victory is ABSENT from all
# readable scripts. Kept as an explicit non-1:1 opt-in (default false), never
# a 1:1 law. Experiment: donewgame.inc + menu cfg victory/score literals.
static var PORT_EXTENSION_SCORE_VICTORY := false
# CORRECTED / LANDED (DEC_U_scenario_win §5 / EV-E): team-win law LANDED at game.gd:8168
# (two-phase `_misc_CheckEndGame`, IMPL-ENDGAME-SAVE); donor `miscext2.script:3769-3844`,
# every global tick (nothing.inc:646) win-stamps all live non-leavers when one team left.
# `_player_bexists` mapping + `winnerteam` init stay APPROX. NO PARITY CLAIM.
# R6 [O] DEC_U_teams §6/§8 — victory surface note (COMMENT ONLY, no key/value
# touched): team-win is donor `_misc_CheckEndGame` (miscext2.script:3775-3844),
# keyed on the SIM team id, now game.gd's single `_sim_team` accessor fed by the
# donor SetupTeams law; win stamps every live non-leaver, defeat is per-player.
# `VICTORY`/`SCORE_LIMIT`/`PORT_EXTENSION_SCORE_VICTORY` remain PORT EXTENSIONS:
# no donor score/time threshold is readable, so none is invented or promoted
# to a 1:1 gate here. Trigger win/lose (scenario.script:2995-3064) strikes the
# interface slot only — no team-wide trigger stamp is ported.
# §3.3 / §5-5 / §6 E-CAM: initial camera/focus has NO donor literal [U]. The
# spawn-facing/camera-forward placement lives in game.gd and stays PORT
# APPROXIMATION; E-CAM capture = fixed seed, 2 white pixels at logged bitmap
# coords, record first-frame camera target + startx/y over 3 identical runs
# (startx/y must match the rescale formula; camera jitter ⇒ PORT CHOICE). No
# camera target/zoom/facing constant is invented here. NO PARITY CLAIM.

# ─── DEC-U-VICTORY-START §4.1/§4.4 — DONOR TRAIN-TIMING LAW (labelled data) ────
# Every value below is [O] donor text with file:line cites in that report.
# No per-category train constant exists: category differences ARE the per-sid
# `buildtime` frame literals. NO PARITY CLAIM; consumer rewiring is game.gd-side
# and out of scope — this block is data + law only, never a default-on gate.
# doprogressorders.inc:221: deltabuildtime := deltatime / objbase.buildtime.
const DONOR_DELTABUILDTIME_FORMULA := "deltabuildtime := deltatime / objbase.buildtime"
# doprogressorders.inc:222-231: AI vs humanai difficulty scale only (human-owned
# and human-AI-owned buildings are NOT scaled); 0.3/0.5/0.75/1/1.25 verbatim.
const DONOR_AI_TRAIN_DIFFICULTY_MULT := {
	"easy": 0.3, "normal": 0.5, "hard": 0.75, "veryhard": 1.0, "impossible": 1.25,
}
# doprogressorders.inc:232-234: progress += deltabuildtime, clamped to 1;
# :235-239: AI capturer-near check pins progress := 0.995.
const DONOR_TRAIN_PROGRESS_CLAMP := 1.0
const DONOR_AI_CAPTURER_PROGRESS_PIN := 0.995
# lib/misc.script:470-482 + dmscript.global:174-179: time-base conversions.
# units: objbase.buildtime := _misc_FramesToTime(buildtime) (unit.script:571-581,
# NO ×10); buildings: objbase.buildtime := _misc_BuildtimeToTime(buildtime)
# (unit.script:478-506, ×10 gc_buildtime_modifier). Per-sid frame literals are
# already stored in UNITS_BASE below as `build_time: <frames> * FRAMES_TO_TIME`.
const DONOR_BUILDTIME_MODIFIER := 10.0      # dmscript.global:179 gc_buildtime_modifier [O]
static func donor_frames_to_time(frames: float) -> float:
	return frames * FRAMES_TO_TIME
static func donor_buildtime_to_time(frames: float) -> float:
	return frames * FRAMES_TO_TIME * DONOR_BUILDTIME_MODIFIER

# [U] U1: per-tick dt clamp is a port stability guard, not a donor constant.
# Decomp plan: recover per-tick order from player.script/unit.script first.
static var TICK_MAX := 0.25                  # clamp on dt so a test never stalls
static var FOG_OF_WAR := false
static var CORPSE_LIFE := 90.0
static var CAPTURE_ENABLED := true  # match rule "peasant capture" (config rules.peasant_capture)
# V7-50 PORT ADDITION — there is no donor render-mode key (V71 mechanics
# inventory :171,:176: "No donor 'render mode' flag exists — port-side switch").
# Additive only: no existing simulation number or default is changed.
static var RENDER_MODE := "2d"      # gameplay.render_mode; 2d default, 3d opt-in
# Host-mode (--script res://tests/t_mcp_host.gd) cannot assign a static var
# through a preloaded GDScript const; use this explicit setter instead.
static func set_render_mode(value: String) -> void:
	RENDER_MODE = value

static var BUILD_PROGRESS_PER_HIT := 10 * 0.03125 * 1.15  # 0.359 s, dmscript.global:182
static var BUILD_HIT_INTERVAL := 1.25  # cWalkIntervalInf
static var MAX_BUILDERS := 30          # dmscript.global:159
static var PERSONAL_SPACE := 0.35      # extra gap between unit bodies (m); original keeps ranks apart
static var FORMATION_SPACING := 1.2    # grid step for group move orders (m)
# DEC-U MOVE-SPEED §5/§7-S6 [O-negative]: no donor separation/grid-step scalar.
# Donor separation is the XCollisionInertia solver [U] + unitRadius*0.8/*0.5
# pitch (group.script:131-148); PERSONAL_SPACE 0.35 and FORMATION_SPACING 1.2
# are PORT APPROXIMATIONS [U] U-formation. BUILD_HIT_INTERVAL 1.25 above is a
# donor ANIM cadence (cWalkIntervalInf, unit.script:595-598) reused as a
# build/gather hit cadence — a PORT APPROXIMATION [U] U-walkinterval, NOT a
# donor velocity. All four values stay unchanged; data-only donor rows follow.
static var MINE_INCOME_PER_S := 13.0 * 32.0 / 250.0  # 1.664, player.script 240-266
static var DELIVERY_RADIUS_M := 3.0 * 2.0            # 3 tiles, dmscript.global:210
static var UPKEEP_DIVISOR := 625.0      # player.script _player_ProcessResourceConsume
# RESOLVED donor accumulator literals (DEC-U §2.1, player.script:240-322).
# UPKEEP_DIVISOR (625) is UPKEEP_SPEED/FRAMES_PER_TIME and stays as a
# compatibility mirror because config.gd:608 still writes it.
const UPKEEP_MULT := 100.0        # per-res mult
const UPKEEP_SPEED := 20000.0     # consume speed
const INCOME_SPEED := 250.0       # 256/1.024, income speed
const FRAMES_PER_TIME := 32.0     # gc_time_to_frames

# ─── DEC-U §7.1 conversions + squad/progress cadences (data.gd mirror) ─────────
# All literal values below are [O] donor text, re-read 2026-11-26. The per-unit
# `Nothing` stage order and the global player-vs-unit interleave remain [U]-O1
# with the fixed-seed hash experiment (DEC-U §7.2). NO PARITY CLAIM.
const DEC_U_C1RAND_TO_RANDOM := 32768  # dmscript.global:176 (65536 is a dead comment)
# _misc_RandToRandom(val) = val/gc_c1rand_to_random (misc.script:484-490).
static func dec_u_rand_to_random(c1rand: int) -> float:
	return float(c1rand) / float(DEC_U_C1RAND_TO_RANDOM)
# _misc_RandomInt() = floor(random*gc_c1rand_to_random) (misc.script:492-498).
# The caller supplies the sim RNG draw; no second generator is invented here.
static func dec_u_random_int(r: float) -> int:
	return int(floorf(r * float(DEC_U_C1RAND_TO_RANDOM)))

const DEC_U_SQUAD_DISMISS_PERCENT := 0.25   # gc_player_SquadDismissPercent :156
const DEC_U_SQUAD_HOLDMODE_S := 37.5        # 150*8*0.03125, dmscript.global:180
const DEC_U_TIME_CHECK_EXISTS_S := 2.0      # 0.01*200, dmscript.global:1484
const DEC_U_TIME_CALC_SQUADS_S := 0.3       # 0.03*10, dmscript.global:1485
const DEC_U_TIME_SCAN_GRID_S := 1.675       # 0.1*17-0.025, dmscript.global:1476-1478
const DEC_U_TIME_IDLE_GRID_S := 3.075       # 0.1*31-0.025, dmscript.global:1476-1477
const DEC_U_TIME_FIND_BEST_S := 3.075       # 0.1*31-0.025, dmscript.global:1476,1482
# The "3.0" in the IMPL-FOG-HUD patch shorthand is a progresstick MODULUS,
# not seconds: nothing.inc:441 (cProgressSmartSearch) and :537 (cProgressTestReach).
const DEC_U_PROGRESS_SMART_SEARCH_TICKS := 3
const DEC_U_PROGRESS_TEST_REACH_TICKS := 3

# [U] U19 / §14 item 17: every threshold below is a video/AI estimate; the
# only grounded AI bit is `progresswarai.inc:2799-2832` fear selector.
# Decomp plan: progresswarai.inc literal table or explicit PORT-AI label.
# ai.gd is NOT in this worker's authorized files — thresholds stay as-is.
static var AI_ENABLED := true
static var AI_THINK_INTERVAL := 1.0
static var AI_FOOD_THRESHOLD := 260.0
static var AI_WOOD_THRESHOLD := 260.0
static var AI_STONE_THRESHOLD := 160.0
static var AI_ATTACK_FORCE := 260.0
static var AI_MAX_PEASANTS := 40
static var AI_DIFFICULTY := "normal"

# --- PORT APPROXIMATION — INVENTED, NO DONOR EQUIVALENT -----------------------
# DEC-02 §7.8 (decomp/DEC_02_scripts.md:984-986) and DFORM-01 "Morale verdict"
# (reports/DFORM_01_formations_morale.md:149-218) proved the donor has NO numeric
# morale: whole-tree scans of 2,559 files / 373 code files return 0 code hits for
# morale/rout/panic/flee/veteran/experience (the only `fear` is an AI target-
# selection bool at progresswarai.inc:2799-2832). Donor squad disband is a COUNT
# fraction — count < basecount*0.25, rank-and-file, human-only
# (dmscript.global:156; progress.inc:5-35,174-175; lib/squad.script:98-107);
# shooter "retreat" is a move-order mode (gc_obj_order_move_mode_runaway=2,
# runawaydelay=1.3, runawaydist=3.5; dmscript.global:198-199,657;
# lib/unit.script:7175-7238). The MORALE_* values and officer/drummer aura
# bonuses below (this block, data.gd:84-95) are PORT INVENTIONS from the wiki
# "video pass" estimate (MECHANICS.md "Video pass"; RB S13), not donor values.
# PRIEST_HEAL_* in the same block is likewise a video-pass estimate, not an
# asserted donor-exact stat. LABEL ONLY — values, defaults and every consumer
# stay byte-identical. The `0.25` match in MORALE_ROUT_THRESHOLD=25.0 is a
# coincidental decimal match, NOT donor provenance. Do not delete/retune here:
# rout feeds ai.gd:855-860 and the selftest `morale` step (selftest.gd:397-407).
static var MORALE_BASE := 70.0
static var MORALE_ROUT_THRESHOLD := 25.0
static var MORALE_OFFICER_RADIUS := 12.0
static var MORALE_OFFICER_BONUS := 20.0
static var MORALE_DRUMMER_RADIUS := 10.0
static var MORALE_DRUMMER_BONUS := 10.0
static var MORALE_LOW_HP_PENALTY := 20.0
static var MORALE_FAMINE_PENALTY := 15.0
static var OFFICER_DAMAGE_BONUS := 0.15   # +15% damage near an officer
static var DRUMMER_SPEED_BONUS := 0.12    # +12% march speed near a drummer
# DEC-U MOVE-SPEED §5.4/§7-S3 [O-negative]: no donor drummer/routing speed
# scalar in sampled script (full-lib `drummer.*speed|march.*bonus` grep x0).
# This +12% and the game.gd `routing` x1.35 branch are PORT APPROXIMATIONS
# [U] U-carry/U-formation family — keep unchanged; remove/gate only when
# T-FORM/T-CARRY close. Donor rotate-speed facts are appended INERT below.
static var PRIEST_HEAL_RADIUS := 8.0
static var PRIEST_HEAL_PER_S := 5.0
static var ARTILLERY_DEPLOY_S := 2.0      # cannon must stand still this long
static var ARROW_DISPERSION_PX := 175.0   # weapon.script archer dispersion
static var CANNON_DISPERSION_PX := 225.0  # unit.script cannon dispersion
static var TOWER_DISPERSION_PX := 100.0   # unit.script tower dispersion
# DEPRECATED / NOT CONSUMED BY THE SIM (donor has NO grace or HP drain).
# RESOLVED donor law (DEC-U §2.1): unit.inc/nothing.inc:450-506,
# lib/misc.script:493-498, dmscript.global:176. The 1:1 law is the
# floor(rand*32768) roll wired in game.gd (Patches 1b/1c). NO PARITY CLAIM.
# Kept only so config.gd:617-618 still writes a defined static.
static var FAMINE_GRACE_S := 120.0        # no deaths before this long starving
static var FAMINE_DRAIN_PER_S := 0.3      # hp/s per unit after the grace
# [U]-U11-P: donor shipped profile.bFamine default TRUE (profile.script:39,
# _profile_SetDefault; field classes.script:5122) — [O] literal read. Reads:
# nothing.inc:450 (unit death gate), doprogress.inc:239 (HUD/log warning),
# progresseconomicai.inc:748,975,2920,3059 (AI samplers of the player flag).
# A stored profile can overwrite shipped true on boot (profile.script:642,
# 729-736) via engine natives only — zero script-side writes: [U]-P-store;
# no cfg/menu writer exists. Port gate value TRUE matches the shipped default
# but remains a labelled PORT gate (not a donor-literal claim). The RESOLVED
# 50/12/5 roll lives in game.gd.
static var FAMINE_PROFILE_ENABLED := true
# MORALE-02 quarantine gate — additive marker only (INVENTED mechanics).
# PORT_MORALE_FAMINE_ENABLED is intentionally NOT read by any consumer yet:
# wiring it from config is MORALE-03; retiring the invented morale/famine
# behaviour behind it is MORALE-04..06. Changing this value ALONE has NO effect
# on gameplay or any gate — it is a quarantine marker, not a live switch.
static var PORT_MORALE_FAMINE_ENABLED := true
# DEPRECATED display-only mirrors (config.gd:619 writes MARKET_RATE; hud.gd:878
# displays it). trade()/tick_market() consume ONLY the resolved tables below.
static var MARKET_RATE := 0.65            # 100 of one res buys 65 of another
static var MARKET_DRIFT := 0.02          # rate slips this much per 100 traded
static var MARKET_RECOVERY_PER_S := 0.002
# RESOLVED donor per-resource market tables (DEC-U §2.2; lib/res.script:180-248).
# All triplets are [min, def, max]. NO PARITY CLAIM.
const MARKET_EXP := 0.00002        # gc_economy_exp (buyexp=sellexp)
const MARKET_TIME := 0.0001 * 32.0 # gc_economy_time = 0.0032
const MARKET_RECOVERY_RATE := 0.025
const MARKET_BUY_COST := {
	"food":  [20.0, 25.0, 40.0],
	"wood":  [40.0, 50.0, 60.0],
	"stone": [40.0, 50.0, 60.0],
	"gold":  [140.0, 190.0, 240.0],
	"iron":  [100.0, 140.0, 180.0],
	"coal":  [100.0, 140.0, 180.0],
}
const MARKET_SELL_COST := {
	"food":  [18.24095*0.8333*0.7, 18.24095*0.8333, 18.24095*0.8333*1.3],
	"wood":  [20.0, 30.0, 40.0],
	"stone": [19.29725*1.08306*0.75, 19.29725*1.08306, 19.29725*1.08306*1.25],
	"gold":  [80.0, 110.0, 140.0],
	"iron":  [40.0, 60.0, 80.0],
	"coal":  [40.0, 60.0, 80.0],
}
static func market_triplet(res: String, buying: bool) -> Array:
	if buying:
		return MARKET_BUY_COST.get(res, [40.0, 50.0, 60.0])
	return MARKET_SELL_COST.get(res, [20.0, 30.0, 40.0])

static var AUDIO_ENABLED := true
static var MASTER_VOLUME_DB := 0.0
static var AMBIENT_VOLUME_DB := -12.0

static var WINDOW_WIDTH := 1280
static var WINDOW_HEIGHT := 720
static var FULLSCREEN := false
static var VSYNC := true
static var PIXELS_PER_METER := 16.0     # screen pixels per metre
static var TERRAIN_PX := 16
static var QUALITY := "high"
static var SPRITE_CELL := 160
static var FX_CAP := 220
static var FOG_INTERVAL := 0.5
static var MINIMAP_INTERVAL := 0.25
# Visual tuning (config.json / display): unit sprites are scaled by UNIT_SCALE
# so they read correctly next to donor-scale buildings. SHOW_CENTROIDS draws
# the flat round anchor disks under buildings/trees (off by default - they
# read as debug "centroid" markers). UNITS_OPAQUE keeps unit bodies solid.
static var UNIT_SCALE := 1.25
static var SHOW_CENTROIDS := false
static var UNITS_OPAQUE := true
# [U] U17/U18 / §14 item 6: UNIT_SCALE, SHOW_CENTROIDS, UNITS_OPAQUE, QUALITY,
# SPRITE_CELL, FX_CAP, FOG_INTERVAL, MINIMAP_INTERVAL and the MAPGEN budget
# table below are visual/perf tunables with NO donor counterpart. Decomp plan:
# move them OUT of the sim into render config; never consume in a tick or gate.

# Donor-mask map build budget, keyed by the SAME quality preset.  The donor
# scales pattern counts by map size; the port scales them by GPU/CPU budget so
# a weak machine gets a lighter (but structurally identical) random map.
#   belts / trees / quarries / relief domes = pattern pass density
#   smooth = coastal height passes, decor = bushes + forest-border stamps
const MAPGEN := {
	"low": {"belts": [4, 5], "trees": [16, 28], "quarries": 4, "domes": 2,
		"decor": false, "stamps": false, "lake_detail": 0},
	"medium": {"belts": [5, 6], "trees": [24, 40], "quarries": 5, "domes": 3,
		"decor": true, "stamps": true, "lake_detail": 1},
	"high": {"belts": [6, 8], "trees": [34, 60], "quarries": 7, "domes": 4,
		"decor": true, "stamps": true, "lake_detail": 2},
}

static func mapgen_budget() -> Dictionary:
	return MAPGEN.get(QUALITY, MAPGEN["high"])

# Quality presets: one switch scales render cost (terrain px, sprite cells,
# fx) and update rates (fog/minimap). Called from the Options menu live
# (the caller rebuilds world caches) and at startup from config.
static func set_quality(q: String) -> void:
	QUALITY = q
	match q:
		"low":
			TERRAIN_PX = 8; SPRITE_CELL = 64; FX_CAP = 60
			FOG_INTERVAL = 1.5; MINIMAP_INTERVAL = 1.0
		"medium":
			TERRAIN_PX = 12; SPRITE_CELL = 96; FX_CAP = 120
			FOG_INTERVAL = 0.8; MINIMAP_INTERVAL = 0.5
		_:
			TERRAIN_PX = 16; SPRITE_CELL = 160; FX_CAP = 220
			FOG_INTERVAL = 0.5; MINIMAP_INTERVAL = 0.25

# Camera pins owned here (DEC-U §2.9, data/cameras/camera.cfg:1-65).
# DONOR-GROUNDED: pitch -32 at all heights (:32-35), height/sphere 58 (:6-10),
# min height 20 (:6-10), focal fixed at 400 (:44-45, Min=Max => no zoom).
# FOV 17.27 degrees stays [U]-V1 (px->angle needs sensor width; experiment §9-V1).
static var CAMERA_PITCH := -32.0        # camera.cfg FreeRotationInfo (:32-35)
static var CAMERA_MIN_HEIGHT := 20.0    # camera.cfg SphereHeightMin (:6-10)
static var CAMERA_MAX_HEIGHT := 58.0    # camera.cfg SphereHeight (:6-10)
static var CAMERA_SPHERE_LENGTH := 58.0 # camera.cfg SphereLength (=SphereHeight)
static var CAMERA_FOCAL := 400.0        # camera.cfg MinFocalLength=MaxFocalLength (:44-45)
static var CAMERA_EDGE_MARGIN := 8.0    # cameracontrol.inc cMargin
static var CAMERA_CORNER_MARGIN := 24.0 # cCornerMargin
static var CAMERA_KEY_SPEED := 96.0     # profile keyscrollspeed*4
static var CAMERA_MOUSE_SPEED := 64.0   # profile mousescrollspeed*4
static var CAMERA_ZOOM_STEP := 1.15

static var UNIT_NAMES := {}             # display names, from data/locale/en/units.txt
static var BUILDING_NAMES := {}         # display names, from data/locale/en/gui.txt
static var PLAYER_NAMES := ["Russia", "Bavaria", "Poland", "Sweden"]
static var PLAYER_NATIONS := ["rus", "bav", "pol", "swe"]  # country.script sids, menu picks these
# P-42 sim contract. main.gd writes these through Object.set(); keep the exact
# names/types. Defaults stay 2 players / free-for-all so existing tests hold.
# T-MENU-ROSTER / T-MENU-MORE-PLAYERS: the skirmish lobby can field 2..12
# players. MAX_PLAYERS is the single cap used by menu.gd (row rebuild),
# main.gd (cfg mapping), config.gd (saved configs) and game.gd (setup_begin /
# _ensure_start_slots clamp).
# PORT EXTENSION: the donor's gc_MaxNonSpectatorsCount is 8 (gc_MaxPlayerCount
# is 12 including pseudo/spectator slots). The owner explicitly asked for MORE
# skirmish players, so the port expands its non-spectator cap to 12 and
# documents this as a PORT EXTENSION beyond donor spec (DONOR_OPTIONS_GAPS.md).
const MAX_PLAYERS := 12
static var PLAYER_COUNT := 2
# R5 [O] DEC_U_teams §8 change 7 / §7-[D] — TEAMS is the LOBBY wire key row,
# NOT the sim team id. `[]`/absent = every slot lobby 0 = FFA; game.gd's
# `_setup_teams(true)` expands that to dense sim ids 1..N (U-T1/T3). LAN FFA
# keys 13..24 (`gc_MaxPlayerCount+plind+1`, misc.script:5812-5837) are distinct
# positives that never match, so they collapse to the same singleton expansion
# as 0 — no value/key is added here. Closed/spectator slots are carried by
# `roster_bexists=false`, NEVER by a shared `team=0` alliance (CheckEndGame's
# roster gate ignores them). Port `-1` in the lobby is the unset marker, mapped
# to donor lobby 0 only at the `_setup_teams` boundary. No value changed.
static var TEAMS: Array = []
# Per-slot Human/Computer pick from the roster UI. Empty => legacy fallback
# (slot 0 human, every other slot AI) in game.gd setup_begin.
static var PLAYER_AI: Array = []
# Donor per-player AI difficulty (none/normal/hard/veryhard/impossible), mapped
# to the sim's easy/normal/hard where possible. The sim still uses the single
# global AI_DIFFICULTY; per-slot tiers are recorded here for config fidelity.
static var PLAYER_AI_DIFFICULTY: Array = []
static var MAP_TYPE := "land"           # generator.cfg TerrainTypes key
static var BIOME := "summer"            # donor season: summer / winter / desert
# P-19/P-14: PORT-MENU emits terrain_type/richness/season/relief (menu.gd:34-37,
# :435). These defaults are EXACTLY the emitted defaults, so legacy dumps hold.
# terrain_type is deliberately ALIASED onto MAP_TYPE (same 6 donor values).
static var RICHNESS := "med"            # low / med / rich (donor Minerals)
static var RELIEF := "plains"           # plains / hills / mountains (donor Terrain Type)
# [U] U13 / §14 item 6: the RICHNESS_*/RELIEF_* multiplier and delta tables
# below are port-inferred. Decomp plan: generator.cfg:802-908 / F08 roulette
# Freq*0.2, or relabel as tunables OUTSIDE the sim; no invented map value.
const RICHNESS_MULT := {"low": 0.5, "med": 1.0, "rich": 1.5}   # per-node ore pool
const RICHNESS_ORE_DELTA := {"low": -1, "med": 0, "rich": 1}   # ore nodes per start (inferred)
# T5GEN: donor Minerals also controls how many mine CLUSTERS a map gets.  The
# canonical menu values are low/med/rich; poor/normal are accepted aliases so a
# richness-named config scales deterministically.  Consumed by pattern_gen.gd.
const RICHNESS_CLUSTER_SCALE := {
	"low": 0.55, "poor": 0.55,
	"med": 1.0, "normal": 1.0,
	"rich": 1.55,
}
const RELIEF_SCALE := {"plains": 1.0, "hills": 1.5, "mountains": 2.2}
const RELIEF_DOME_DELTA := {"plains": 0, "hills": 1, "mountains": 2}
# --- SP-1 SEASON / CLIMATE ENUM (donor season values; DATA ONLY) --------------
# Donor season values, read-only from the shipped donor scripts (via DENV-01):
#   scripts\lib\map.script:250          gen.season default = 0 (Summer)
#   scripts\dmscript.global:237         gc_MaxSeasonCount = 3  (0/1/2 implied)
#   scripts\lib\miscext2.script:3318-3323  UI toggle season 0 <-> 2
#   scripts\dogenerate.inc:4, :2079     desert branch gen.season = 3
#   scripts\lib\miscext.script:1549     SetSeasonType(season)
# Season 1 is UNVERIFIED (DENV-01 Q5 / SEASON-PLAN-01 B7) and is deliberately NOT
# encoded here. Additive data constants only: no behaviour change, no renames,
# no new mechanics. The existing string BIOME (data.gd:199) is left untouched.
const SEASON_ENUM := {"summer": 0, "winter": 2, "desert": 3}
const SEASON_DEFAULT := 0  # summer/default: map.script:250 (gen.season=0); terrain.lib:12 (seasons.Summer=Summer)
# Season tint exposed for world.gd (separate worker); never stored in map_meta
# because map_meta is serialised into every --dump-map file.
# LEGACY FLAT TINT / PORT APPROXIMATION: the donor winter/desert swap is a tile-SET
# swap plus colors.lib lighting tables (DENV-01 §4/§5.2; SEASON-PLAN-01 B9), NOT a
# colour multiply. Kept for the 2D sibling which consumes it; do not delete or
# mistake this for the donor swap mechanism.
const TERRAIN_TINT := {
	"summer": Color(1.0, 1.0, 1.0, 1.0),
	"winter": Color(0.86, 0.91, 1.0, 1.0),
	"desert": Color(1.0, 0.90, 0.70, 1.0),
}
static func terrain_tint(biome: String = "") -> Color:
	return TERRAIN_TINT.get(biome if biome != "" else str(BIOME), TERRAIN_TINT["summer"])
static var START_OPTION := "default"    # startingsettings.gc_mapsettings_* key
static var HOTKEYS := {}                # action -> "Ctrl+S" style binding

# Nations from data/scripts/lib/country.script _country_GetSIDByID.
# Colors are the two team colours the port draws; names are the original sids.
const NATIONS := {
	"aus": {"name": "Austria"}, "fra": {"name": "France"},
	"eng": {"name": "England"}, "spa": {"name": "Spain"},
	"rus": {"name": "Russia"}, "ukr": {"name": "Ukraine", "no18c": true},
	"pol": {"name": "Poland"}, "swe": {"name": "Sweden"},
	"pru": {"name": "Prussia"}, "ven": {"name": "Venice"},
	"tur": {"name": "Turkey", "no18c": true}, "alg": {"name": "Algeria", "no18c": true},
	"net": {"name": "Netherlands"}, "den": {"name": "Denmark"},
	"por": {"name": "Portugal"}, "pie": {"name": "Piedmont"},
	"sax": {"name": "Saxony"}, "bav": {"name": "Bavaria"},
	"hun": {"name": "Hungary"}, "swi": {"name": "Switzerland"},
	"sco": {"name": "Scotland"},
}

# Nation barracks variants: generic train-list sid -> nation unit (all in
# UNITS_BASE above; stats estimated, marked so in mechanics.json).
const NATION_UNITS := {
	"rus": {"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"},
	"bav": {"serdiuk": "musketeer", "cossack": "hussar"},
	"ukr": {"priest": "pope"},
	"pol": {"cossack": "wingedhussar"},
	"tur": {"serdiuk": "jannisary", "musketeer": "jannisary", "cossack": "sipahi", "dragoon": "sipahi", "priest": "mullah"},
	"alg": {"serdiuk": "jannisary", "musketeer": "jannisary", "cossack": "mameluke", "dragoon": "spakh", "priest": "mullah"},
	"swe": {"cossack": "hackapell"},
	# Scotland: bagpipers plus the baked unique infantry (P-41). The baked
	# sco_units.json walk clip is DONOR-exact 0.8 s / 12 frames (swordsmansco);
	# the port's 1.08 s = n*0.09 convention is an estimate, so fidelity wins.
	"sco": {"drummer": "bagpiper", "musketeer": "sco_highlandersword", "serdiuk": "sco_highlandersword"},
}

# Nation-unique animation sheets live in a SEPARATE index (as naval/index.json
# does) so the 54-key main index and t_anim_metrics stay untouched.
static var EXTRA_ANIM_INDEX := {}
static func load_extra_anim_index() -> void:
	if not EXTRA_ANIM_INDEX.is_empty():
		return
	var path := "res://assets/models/anim/land_units/sco_units.json"
	if not FileAccess.file_exists(path):
		path = "res://assets/models/anim/sco_units.json"  # legacy flat fallback
	if not FileAccess.file_exists(path):
		return
	var raw := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(raw)
	if parsed is Dictionary:
		for k in parsed:
			EXTRA_ANIM_INDEX[k] = parsed[k]

# Random-map terrain types from data/game/var/generator.cfg TerrainTypes.
# water_frac drives how many lakes the port paints (Land ~ none, Islands ~ many).
const MAP_TYPES := {
	"land": {"water_frac": 0.5, "name": "Land"},
	"mediterranean": {"water_frac": 1.6, "name": "Mediterranean"},
	"peninsulas": {"water_frac": 1.2, "name": "Peninsulas"},
	"islands": {"water_frac": 2.2, "name": "Islands"},
	"continents": {"water_frac": 1.8, "name": "Continents"},
	"continent": {"water_frac": 1.0, "name": "Continent"},
}

# T-MENU-ROSTER DEEP: donor skirmish option enums (miscext2.script serialized
# struct: season,terraintype,relieftype,resourcestart,resourcemines,mapsize,
# startingunits,balloon,cannons,peacetime,century18,capture,marketdip,teams,
# autosave,limit,gamespeed,adviserassistant). Labels live in menu.gd; these are
# the canonical ids so menu / cfg / saved config / docs agree.
#
# Map Shape: 9 real shapes + Random (gui.txt:413-434,855-862). The generator
# only knows the 6 mask families in MAP_TYPES above (mapgen.pick falls back to
# "land" for unknown ids), so every donor shape maps to the NEAREST family:
# coastal -> mediterranean, lakes -> islands, rivers -> peninsulas, etc. These
# are deliberate approximations, not exact donor map masks (see gaps doc).
const DONOR_MAP_SHAPES := {
	"land": {"name": "Land", "generator": "land"},
	"mediterranean": {"name": "Mediterranean", "generator": "mediterranean"},
	"peninsulas": {"name": "Peninsulas", "generator": "peninsulas"},
	"islands": {"name": "Islands", "generator": "islands"},
	"several_continents": {"name": "Several Continents", "generator": "continents"},
	"single_continent": {"name": "Single Continent", "generator": "continent"},
	"coastal": {"name": "Coastal", "generator": "mediterranean"},
	"lakes": {"name": "Lakes", "generator": "islands"},
	"rivers": {"name": "Rivers", "generator": "peninsulas"},
	"random": {"name": "Random", "generator": "random"},
}

# Relief / Terrain Type (gui.txt:449-460): 6 donor values. The sim's relief
# scale table has only plain/hills/mountains, so the three extra tiers are
# approximated by the nearest supported tier.
const DONOR_RELIEF := {
	"plain": {"name": "Plain", "relief": "plains"},
	"low_mountains": {"name": "Low Mountains", "relief": "hills"},
	"high_mountains": {"name": "High Mountains", "relief": "mountains"},
	"highlands": {"name": "Highlands", "relief": "hills"},
	"plateaus": {"name": "Plateaus", "relief": "mountains"},
	"random": {"name": "Random", "relief": "random"},
}

const DONOR_RES_START_MULT := {
	"normal": 1.0, "rich": 4.0, "thousands": 25.0,
	"millions": 1000.0, "random": 0.0,  # 0 = seed-resolved at apply time
}
const DONOR_MINERALS := ["low", "med", "rich", "random"]
const DONOR_BALLOON := ["default", "no_balloons", "balloons"]
const DONOR_CANNONS := ["default", "no_cannons_towers_walls", "expensive_cannons"]
# [O] DEC-U-VICTORY-START §2.1 / §5-1: index→seconds, addressed by DONOR INDEX
# (dmscript.global:1055-1066 enum), NOT by a seconds menu. Seconds arm values
# are dmscript.global:4262-4277 (_misc_GetPeaceTime(ind)):
#   0=_default→0, 1=_10→10, 2=_20→20, 3=_30→30, 4=_45→45, 5=_60→60,
#   6=_90→90, 7=_120→120, 8=_180→180, 9=_240→240,
#   10=_reserved→UNMAPPED (no arm in _misc_GetPeaceTime), 11=_15→15.
# The old 40/50 were invented and are REMOVED; 45 (index 4) and 15 (index 11)
# are restored verbatim. null at index 10 is an unmapped sentinel, not a value.
const DONOR_PEACE_TIMES := [0, 10, 20, 30, 45, 60, 90, 120, 180, 240, null, 15]
const DONOR_PEACE_TIME_RESERVED_INDEX := 10            # _reserved: unmapped
# Canonical index→seconds lookup; index 10 deliberately absent (unmapped).
const DONOR_PEACE_TIME_INDEX_SECONDS := {
	0: 0, 1: 10, 2: 20, 3: 30, 4: 45, 5: 60, 6: 90, 7: 120, 8: 180, 9: 240, 11: 15,
}
const DONOR_CENTURY18 := ["default", "never", "immediately"]
const DONOR_CAPTURE := ["default", "no_peasants", "no_peasants_or_centres", "artillery_only"]
const DONOR_MARKET_DIP := ["default", "without_dip_center", "without_market", "without_both"]
const DONOR_POP_LIMITS := [0, 25, 50, 100, 200, 500]
const DONOR_ADVISER := ["default", "with", "without"]
const DONOR_GAME_SPEED := {"slow": 0.5, "normal": 1.0, "fast": 2.0, "very_fast": 4.0}
const DONOR_AUTOSAVE := ["off", "on", "every_5_min"]  # labels unverified (English guesses)

# Applied donor options. Defaults are the donor "Default"/"Normal"/"No" picks,
# so an unchanged config behaves exactly like the pre-expansion port.
static var DONOR_MAP_SHAPE := "land"
static var DONOR_RELIEF_TYPE := "plain"
static var DONOR_RES_START := "normal"
static var DONOR_RES_MINES := "med"
static var BALLOON_MODE := "default"
static var CANNON_MODE := "default"
static var PEACE_TIME := 0.0          # seconds of protected start (rule timer)
static var CENTURY18_MODE := "default"
static var CAPTURE_MODE := "default"
static var MARKET_DIP_MODE := "default"
static var POP_LIMIT := 0             # 0 = unlimited
static var GAME_SPEED := "normal"
static var AUTOSAVE_MODE := "off"
static var ADVISER_MODE := "default"
static var ALLIES_MODE := "default"

# Starting options from data/game/var/startingsettings.cfg comments
# (gc_mapsettings_startingunits_*). Armies scale the battle preset.
const START_OPTIONS := {
	"default": {"army_mult": 0.0, "food": 0, "towers": 0, "cannons": 0},
	"armysmall": {"army_mult": 0.5, "food": 1000, "towers": 0, "cannons": 0},
	"armymedium": {"army_mult": 1.0, "food": 1000, "towers": 0, "cannons": 0},
	"armylarge": {"army_mult": 1.8, "food": 2000, "towers": 0, "cannons": 0},
	# §4.1 startid 4 = peasantslot (startingsettings.cfg:723-730). Added as a
	# KEY only; the live 6-resource values come from DONOR_START_RESOURCES with
	# the double-add quirk, not from the legacy `food` shortcut.
	"peasantslot": {"army_mult": 0.0, "food": 0, "towers": 0, "cannons": 0},
	"towers": {"army_mult": 0.3, "food": 500, "towers": 3, "cannons": 0},
	"cannons": {"army_mult": 0.3, "food": 500, "towers": 0, "cannons": 3},
}

# Squad formations from data/game/var/formations.cfg. The port keeps the
# masks as shapes: line = wide, column = deep, square = ring. The donor's
# exact per-formation bonus tuples are imported below as FORMATION_BONUSES.
const FORMATIONS := {
	"none": {"cols_mult": 1.0, "rows_mult": 1.0},
	"line": {"cols_mult": 1.8, "rows_mult": 0.6},
	"column": {"cols_mult": 0.6, "rows_mult": 1.8},
	"square": {"cols_mult": 1.0, "rows_mult": 1.0, "hollow": true},
	"wedge": {"cols_mult": 0.5, "rows_mult": 1.4},
}
# DEC-U MOVE-SPEED §5.1/§7-S6 [O-negative]: these cols_mult/rows_mult shape
# values are PORT APPROXIMATION [U] U-formation. Donor formation bonuses in
# FORMATION_BONUSES below are damage/shield ONLY (formations.cfg has no speed
# column); group.script:115-160 changes SLOT POSITIONS, never speed. No
# formation speed factor is invented here; [U] U-formation (T-FORM trace).

# Exact donor bonus tuples, keyed by formations.cfg id. Each value is
# [bonusdamage, bonusshield, bonusdamagehold, bonusshieldhold] read from
# C:\Games\Cossacks 3\data\game\var\formations.cfg (149 records, 46 nonzero:
# 15x(2,2,7,7), 22x(1,1,1,1), 3x(3,3,7,7), plus legacy _OLD outliers).
const FORMATION_BONUSES := {
	"none": [0, 0, 0, 0],
	"LINE3": [0, 0, 0, 0],
	"LINE4": [0, 0, 0, 0],
	"LINE5": [0, 0, 0, 0],
	"LINE6": [0, 0, 0, 0],
	"LINE7": [0, 0, 0, 0],
	"LINE8": [0, 0, 0, 0],
	"LINE9": [0, 0, 0, 0],
	"LINE10": [0, 0, 0, 0],
	"LINE3PUS": [0, 0, 0, 0],
	"LINE4PUS": [0, 0, 0, 0],
	"LINE5PUS": [0, 0, 0, 0],
	"LINE6PUS": [0, 0, 0, 0],
	"LINE7PUS": [0, 0, 0, 0],
	"LINE8PUS": [0, 0, 0, 0],
	"LINE9PUS": [0, 0, 0, 0],
	"LINE10PUS": [0, 0, 0, 0],
	"LINE11PUS": [0, 0, 0, 0],
	"LINE12PUS": [0, 0, 0, 0],
	"LINE13PUS": [0, 0, 0, 0],
	"LINE14PUS": [0, 0, 0, 0],
	"LINE15PUS": [0, 0, 0, 0],
	"LINE16PUS": [0, 0, 0, 0],
	"LINE17PUS": [0, 0, 0, 0],
	"LINE18PUS": [0, 0, 0, 0],
	"LINE19PUS": [0, 0, 0, 0],
	"LINE20PUS": [0, 0, 0, 0],
	"LINE21PUS": [0, 0, 0, 0],
	"LINE22PUS": [0, 0, 0, 0],
	"LINE23PUS": [0, 0, 0, 0],
	"LINE24PUS": [0, 0, 0, 0],
	"LINE25PUS": [0, 0, 0, 0],
	"LINE26PUS": [0, 0, 0, 0],
	"LINE27PUS": [0, 0, 0, 0],
	"LINE28PUS": [0, 0, 0, 0],
	"LINE29PUS": [0, 0, 0, 0],
	"LINE30PUS": [0, 0, 0, 0],
	"LINE31PUS": [0, 0, 0, 0],
	"LINE32PUS": [0, 0, 0, 0],
	"LINE33PUS": [0, 0, 0, 0],
	"LINE34PUS": [0, 0, 0, 0],
	"LINE35PUS": [0, 0, 0, 0],
	"LINE36PUS": [0, 0, 0, 0],
	"LINE37PUS": [0, 0, 0, 0],
	"LINE38PUS": [0, 0, 0, 0],
	"LINE39PUS": [0, 0, 0, 0],
	"LINE40PUS": [0, 0, 0, 0],
	"LINE100PUS": [0, 0, 0, 0],
	"LINEMORB5": [0, 0, 0, 0],
	"LINEMORB6": [0, 0, 0, 0],
	"LINEMORB7": [0, 0, 0, 0],
	"LINEMORB8": [0, 0, 0, 0],
	"LINEMORB9": [0, 0, 0, 0],
	"LINEMORB10": [0, 0, 0, 0],
	"LINEMORB11": [0, 0, 0, 0],
	"LINEMORB12": [0, 0, 0, 0],
	"LINEMORB13": [0, 0, 0, 0],
	"LINEMORB14": [0, 0, 0, 0],
	"LINEMORB15": [0, 0, 0, 0],
	"LINEMORB16": [0, 0, 0, 0],
	"LINEMORB17": [0, 0, 0, 0],
	"LINEMORB18": [0, 0, 0, 0],
	"LINEMORB19": [0, 0, 0, 0],
	"LINEMORB20": [0, 0, 0, 0],
	"LINE15": [2, 2, 7, 7],
	"LINE36": [2, 2, 7, 7],
	"LINE72": [2, 2, 7, 7],
	"LINE120": [2, 2, 7, 7],
	"LINE196": [2, 2, 7, 7],
	"SQUARE36": [2, 2, 7, 7],
	"SQUARE72": [2, 2, 7, 7],
	"SQUARE120": [2, 2, 7, 7],
	"SQUARE196": [2, 2, 7, 7],
	"KARE36": [2, 2, 7, 7],
	"KARE72": [2, 2, 7, 7],
	"KARE120": [2, 2, 7, 7],
	"KARE196": [2, 2, 7, 7],
	"ALONE": [0, 0, 0, 0],
	"ODIN": [0, 0, 0, 0],
	"SHIPS12": [0, 0, 0, 0],
	"SHIPS5": [0, 0, 0, 0],
	"SHIPSN5": [0, 0, 0, 0],
	"SHIPS8": [0, 0, 0, 0],
	"SHIPS3": [0, 0, 0, 0],
	"PACK20": [0, 0, 0, 0],
	"TRI_OLD": [-10, 9, 95, -19],
	"TRI2_OLD": [0, 0, 0, 0],
	"TRI3_OLD": [0, 0, 0, 0],
	"PRUS_OLD": [5, -5, -27, 80],
	"PRUS2_OLD": [0, 0, 0, 0],
	"PRUS3_OLD": [0, 0, 0, 0],
	"SHER_OLD": [2, 1, 2, 1],
	"SHER2_OLD": [1, 1, 1, 1],
	"SHER3_OLD": [0, 1, 1, 0],
	"PRUS0_OLD": [1, 1, 1, 1],
	"TRI0_OLD": [1, 1, 1, 1],
	"PRUS02_OLD": [0, 0, 0, 0],
	"PRUS03_OLD": [0, 0, 0, 0],
	"SHER0_OLD": [2, 1, 2, 1],
	"SHER02_OLD": [1, 1, 1, 1],
	"SHER03_OLD": [0, 1, 1, 0],
	"TRI02_OLD": [0, 0, 0, 0],
	"TRI03_OLD": [0, 0, 0, 0],
	"SQUARE15": [2, 2, 7, 7],
	"KARE15": [2, 2, 7, 7],
	"TRI": [1, 1, 1, 1],
	"TRI2": [1, 1, 1, 1],
	"TRI3": [1, 1, 1, 1],
	"PRUS": [1, 1, 1, 1],
	"PRUS2": [1, 1, 1, 1],
	"PRUS3": [1, 1, 1, 1],
	"SHER": [1, 1, 1, 1],
	"SHER2": [1, 1, 1, 1],
	"SHER3": [1, 1, 1, 1],
	"TRI0": [1, 1, 1, 1],
	"TRI02": [1, 1, 1, 1],
	"TRI03": [1, 1, 1, 1],
	"PRUS0": [1, 1, 1, 1],
	"PRUS02": [1, 1, 1, 1],
	"PRUS03": [1, 1, 1, 1],
	"SHER0": [1, 1, 1, 1],
	"SHER02": [1, 1, 1, 1],
	"SHER03": [1, 1, 1, 1],
	"LINE2": [0, 0, 0, 0],
	"LINE2PUS": [0, 0, 0, 0],
	"LINEMORB2": [0, 0, 0, 0],
	"LINEMORB3": [0, 0, 0, 0],
	"LINEMORB4": [0, 0, 0, 0],
	"LINE400": [3, 3, 7, 7],
	"SQUARE400": [3, 3, 7, 7],
	"KARE400": [3, 3, 7, 7],
	"LINE15NB": [0, 0, 0, 0],
	"LINE36NB": [0, 0, 0, 0],
	"LINE72NB": [0, 0, 0, 0],
	"LINE120NB": [0, 0, 0, 0],
	"LINE196NB": [0, 0, 0, 0],
	"LINE400NB": [0, 0, 0, 0],
	"SQUARE15NB": [0, 0, 0, 0],
	"SQUARE36NB": [0, 0, 0, 0],
	"SQUARE72NB": [0, 0, 0, 0],
	"SQUARE120NB": [0, 0, 0, 0],
	"SQUARE196NB": [0, 0, 0, 0],
	"SQUARE400NB": [0, 0, 0, 0],
	"KARE15NB": [0, 0, 0, 0],
	"KARE36NB": [0, 0, 0, 0],
	"KARE72NB": [0, 0, 0, 0],
	"KARE120NB": [0, 0, 0, 0],
	"KARE196NB": [0, 0, 0, 0],
	"KARE400NB": [0, 0, 0, 0],
}

# Return [bonusdamage, bonusshield, bonusdamagehold, bonusshieldhold] for a
# donor formations.cfg id; unknown ids get the all-zero tuple.
static func formation_bonuses(fid: String) -> Array:
	return FORMATION_BONUSES.get(fid, [0, 0, 0, 0])

# --- PORT APPROXIMATION — INVENTED, NO DONOR EQUIVALENT -----------------------
# DEC-02 §6 (decomp/DEC_02_scripts.md:932) and DFORM-01
# (reports/DFORM_01_formations_morale.md:210): `experience`/`veteran` have 0 donor
# code hits; donor formation bonus tuples are fixed per formations.cfg and are
# snapshotted onto the squad at set-time (lib/player.script:809-812). No donor XP
# raises formation bonuses. RB S13 (docs/research/RB_MECHANICS.md:231-238) is
# UNVERIFIED against donor plaintext. The SQUAD_XP_* constants below are a PORT
# INVENTION. LABEL ONLY — removal is MORALE-05, not this ticket; values, defaults
# and every consumer stay byte-identical here.
# RB G-13: surviving squads harden with kills. XP accumulates on the squad dict
# for the whole match and adds at most SQUAD_XP_CAP points to EACH donor tuple
# field (bounded - no runaway scaling). 2 kills per point by default.
static var SQUAD_XP_PER_KILL := 1.0
static var SQUAD_XP_PER_BONUS := 2.0
static var SQUAD_XP_CAP := 3

# Donor formation ladder tops out at 400 soldiers (formations.cfg LINE400 /
# SQUARE400 / KARE400, imported in FORMATION_BONUSES above). squad_form()
# counts the officer + drummer in this cap, so 400 soldiers need 402 slots and
# the check at game.gd `total >= SQUAD_MAX` breaks *before* the next add —
# hence 403 (derived), not 400.
const SQUAD_MAX := 403

# resource gathering: hits per carried load, carried amount.
# [O] `hits` = _res_GetHitsNeeded (res.script:348-358; consts dmscript.global:799-801:
#     food 22 / wood 14 / stone 20 / else 10), with the resamount := hitsneeded clamp
#     at unit.script:9661 — NO per-sid capacity table exists. `carry` =
#     _unit_GetPeasantResPortion (unit.script:9544-9553; consts :804-806: 45/28/40,
#     else 20), credited ONLY on a full load as portion*eff div 100 (unit.script:
#     9557-9560, eff default 100 player.script:109). Both triples already agree [O].
# `interval: 1.25` is PORT APPROXIMATION [U] U-CAD: donor cadence is a per-(action,nation)
#     AAF work window @30 fps (peaukr 22/18/18 f, pearus food 24 f; work rows have NO
#     NumberCycle), never a uniform rate — settling trace T-CAD. Full donor law, the
#     inert telemetry mirror and the five fixed-seed traces are appended at EOF.
const GATHER_BASE := {
	"food": {"hits": 22, "carry": 45, "interval": 1.25},
	"wood": {"hits": 14, "carry": 28, "interval": 1.25},
	"stone": {"hits": 20, "carry": 40, "interval": 1.25},
}
static var GATHER := {}
# G-13 / donor dmscript.global:222-225 gc_gameplay_resource_maxattackers_*:
# food 3, wood 2, stone 3 (none 4). Max simultaneous gatherers per resource node.
const RESOURCE_WORKERS := {"food": 3, "wood": 2, "stone": 3}

# weapon kinds — donor dmscript.global:279-286 (gc_obj_weapon_kind_*).
const WK := {"none": 0, "pike": 1, "sword": 2, "bullet": 3, "cannister": 4, "arrow": 5, "firearrow": 6, "cannonball": 7}

# Weapon kind -> slot in the port's 6-element `prot` array below.
# Donor `_misc_DoDamage` (miscext2.script:380,434) subtracts
# `protection[weapkind]` directly, i.e. it indexes by the 0..7 kind value.
# The port compresses those 8 kinds into 6 slots ordered
# [pike, sword, bullet, cannister, arrow, cannonball] (no `none`, no `firearrow`).
# -1 means "no protection slot" (kind `none`, or an unknown kind defaulting to 0).
# DEC-U-SKIRMISH-TABLES §10 item 5 / §1.2: donor `protection[6]` (firearrow) is a
# DISTINCT slot and is NEVER written by SetObjBaseProtection (unit.script:510-517),
# so it is 0 at base. The old `5` here silently merged firearrow into cannonball
# (slot 5); that merge is REMOVED. firearrow now resolves to 0, which is the
# donor base law. Any upgrade that ever adds firearrow protection stays [U]-T1-tail
# (experiment §9: country.script:2050-2210 audit) — no value is invented here.
const PROT_SLOT := [-1, 0, 1, 2, 3, 4, -1, 5]

# DONOR-VERBATIM row shapes (DEC-U-SKIRMISH-TABLES §1.1/§1.2; weapon.script
# :39-62,250-391; unit.script:510-517). The per-sid VALUES below are now
# transcribed from that report — no interpolation, no neighbour copy. The
# damage-application law is `donor_do_damage()` (§2 / miscext2.script:274-465).
# Only the T1-tail (ships/buildings/walls/shields), round() banker semantics and
# per-frame RNG ORDER remain [U] with their §9 experiments. NO PARITY CLAIM.
# radius is in donor PIXELS: PX_TO_M = 1/26.6666666; tiles = /DEC_U_PX_PER_TILE.
const DONOR_WEAPON_ROW_KEYS := ["ind", "sid", "fx", "projbasename", "damage",
	"radius_px", "gravity", "propagation", "physvalue", "time"]
static func donor_weapon_radius_m(radius_px: float) -> float:
	return radius_px * PX_TO_M
static func donor_weapon_radius_tiles(radius_px: float) -> float:
	return radius_px / DEC_U_PX_PER_TILE
# protection[6] order is already exact in UNITS_BASE; do NOT reorder PROT_SLOT.
# Example donor rows: unit.script:762 -> (5,3,8,225,17,80);
# unit.script:739 / port "roundshier" -> (3,3,7,225,16,80).
const DONOR_PROT_KINDS := ["pike", "sword", "bullet", "cannister", "arrow", "cannonball"]

# ── DEC-U-SKIRMISH-TABLES (§10 port change list) — DONOR-VERBATIM tables ───────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_skirmish_tables.md
# All rows are [O] donor TEXT with file:line cites in that report. No donor binary
# was executed, no GPU frame compared. NO PARITY CLAIM. Every unresolved tail keeps
# its §9 experiment tag. Nothing below changes a save version or an existing key.

# §1.0 / dmscript.global:278-288,687-705 — projectile enums.
const DONOR_WEAPON_KIND_IDS := {"none": 0, "pike": 1, "sword": 2, "bullet": 3,
	"cannister": 4, "arrow": 5, "firearrow": 6, "cannonball": 7, "mortarball": 8,
	"heal": 9}
const DONOR_WEAPON_PROPAGATION := {"stand": 0, "slightup": 1, "random": 2, "fly": 3,
	"immediate": 4, "angle": 5, "random1": 6, "randomsimulate": 7}
const DONOR_WEAPON_TIME := {"cInfinite": -1, "cPlayOnce": 0}
# weapon.script:59-62 — physvalue meaning is decided by propagation, not by kind.
const DONOR_PHYS_MEANING := {"random": "speed", "random1": "speed", "fly": "speed",
	"randomsimulate": "speed", "angle": "angle", "slightup": "gravity",
	"stand": "unused", "immediate": "unused"}

# §1.1 COMPLETE weapon-prototype table — 77-of-77 registration rows [O] CLOSED per
# DEC_U_weapon_tail §1 (weapon.script:314 + :316-391). The old "78 rows" count was a
# miscount: the 78th `_weapon_AddWeapon` hit is the :39 procedure definition, NOT a
# row. DONOR_WEAPON_PROTOS is complete; no row is added or invented. NO PARITY CLAIM.
# Tuple = [damage, radius_px, gravity, propagation, physvalue, time_expr].
# radius_px is the LITERAL donor pixel value; tiles = px/DEC_U_PX_PER_TILE (53.3333333,
# dmscript.global:172), metres = px*PX_TO_M (px/26.6666666). `time_expr` is the
# DONOR EXPRESSION verbatim — round(...) is NEVER pre-rounded here.
const DONOR_WEAPON_PROTOS := {
	"(none)": [0, 0.0, 0, "stand", 0, "PlayOnce"],                      # weapon.script:314
	"SHOTMUSKET": [0, 0.0, 0, "immediate", 1, "PlayOnce"],
	"SHOTCANNON": [0, 20.0, 0, "slightup", 0, "PlayOnce"],
	"SHOTSHIP": [0, 20.0, 0, "slightup", 0, "PlayOnce"],
	"SHOTCANNISTER": [0, 20.0, 0, "slightup", 0, "PlayOnce"],
	"SHOTMORTAR": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"SHOTHOWITZER": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"SHOTMULTICANNON": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"SHOTTOWER": [0, 20.0, 0, "slightup", 0, "PlayOnce"],
	"NUCL2P": [340, 35.0, 2, "angle", 10, "Infinite"],
	"NUCL2PTOW": [340, 35.0, 2, "fly", 38, "Infinite"],
	"NUCL2PKOR": [400, 35.0, 2, "fly", 38, "Infinite"],
	"NUCL3M": [800, 60.0, 5, "angle", 55, "Infinite"],
	"NUCL3MONO": [250, 2.0, 5, "angle", 70, "Infinite"],
	"NUCL3MONONEW": [0, 2.0, 5, "angle", 70, "Infinite"],
	"NUCL3MONONEWDMG": [500, 2.0, 5, "random", 1, "Infinite"],          # `{250}` is donor comment; live head 500
	"NUCL3MONOEXPL": [0, 0.0, 5, "slightup", 0, "PlayOnce"],
	"NUCLGRE": [110, 50.0, 5, "angle", 55, "Infinite"],
	"NUCLM": [100, 50.0, 5, "slightup", 0, "FramesToTime(2)"],
	"NUCLMOSKOL": [800, 30.0, 5, "random", 4, "Infinite"],
	"STRELA": [25, 20.0, 2, "fly", 25, "Infinite"],
	"OSTRELA": [50, 15.0, 2, "fly", 15, "Infinite"],
	"STRELDEZ": [0, 0.0, 0, "stand", 0, "FramesToTime(950)"],
	"POINT": [0, 1.0, 3, "random", 3, "Infinite"],
	"POINTOTVZRIV": [100, 15.0, 3, "randomsimulate", 3, "Infinite"],
	"POINTSTONE4": [0, 1.0, 3, "slightup", 0, "PlayOnce"],
	"PPOINTT": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"PPOINTTTOW": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"PPOINTTKOR": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"PSMPOINTT": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"PSMPOINTTPUS": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"DIMMORT1": [0, 0.0, 5, "slightup", 0, "PlayOnce"],
	"DIMMORT2": [0, 0.0, 5, "slightup", 0, "PlayOnce"],
	"DIMMORT2NEW": [0, 0.0, 5, "slightup", 0, "PlayOnce"],
	"PUSSTRELA": [512, 25.0, 0, "fly", 20, "FramesToTime(round(2*1.625))"],
	"PUSSTRELA1": [256, 50.0, 0, "fly", 20, "FramesToTime(round(4*1.625))"],  # 6.5 half-to-even caveat [U]-G1
	"PUSSTRELA2": [128, 75.0, 0, "fly", 20, "FramesToTime(round(8*1.625))"],
	"PUSSTRELA3": [112, 100.0, 0, "fly", 20, "FramesToTime(round(2*1.625))"],
	"PUSSTRELA4": [30, 125.0, 0, "fly", 20, "FramesToTime(round(5*1.625))"],
	"PUSSTRELA5": [30, 150.0, 0, "fly", 20, "FramesToTime(round(10*1.625))"],
	"PUSSTRELA6": [30, 175.0, 0, "fly", 20, "FramesToTime(round(15*1.625))"],
	"PUSSTRELAPUS": [600, 35.0, 0, "fly", 20, "FramesToTime(round(2*2.75))"],   # 25+10 px
	"PUSSTRELA1PUS": [480, 65.0, 0, "fly", 20, "FramesToTime(round(4*2.75))"],  # 50+15 px
	"PUSSTRELA2PUS": [350, 95.0, 0, "fly", 20, "FramesToTime(round(8*2))"],     # 75+20 px
	"PUSSTRELA3PUS": [210, 0.0, 0, "fly", 20, "FramesToTime(round(2*0.5))"],    # 100-100 px
	"PUSSTRELA4PUS": [150, 25.0, 0, "fly", 20, "FramesToTime(round(5*0.5))"],   # 125-100 px; 2.5 caveat
	"PUSSTRELA5PUS": [150, 50.0, 0, "fly", 20, "FramesToTime(round(10*0.5))"],  # 150-100 px
	"PUSSTRELA6PUS": [96, 75.0, 0, "fly", 20, "FramesToTime(round(15*0.5))"],   # 175-100 px; 7.5 caveat
	"KAPEZ": [3000, 25.0, 2, "random1", 9, "PlayOnce"],               # +brotate,+bcollisiondetection
	"STRELDEZPRO": [0, 0.0, 0, "stand", 0, "PlayOnce"],
	"PUEXP": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUNOEXP": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUEXPBUILDINGDEATH": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUEXPBLD": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUNOEXPBLD": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUEXPHOWITZER": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUEXPHOWITZERBLD": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PUEXPKOR": [900, 50.0, 0, "slightup", 0, "PlayOnce"],
	"PUNOEXPKOR": [900, 50.0, 0, "slightup", 0, "PlayOnce"],
	"PUEXPKORDEATH": [200, 50.0, 0, "slightup", 0, "PlayOnce"],       # `{900}` is donor comment; live 200
	"PU4GRE": [50, 10.0, 0, "slightup", 0, "PlayOnce"],
	"SMALL": [10, 10.0, 0, "slightup", 0, "PlayOnce"],
	"SMALL2": [10, 10.0, 0, "slightup", 0, "PlayOnce"],
	"SMALL2BLD": [10, 10.0, 0, "slightup", 0, "PlayOnce"],
	"VODABUL": [10, 10.0, 0, "slightup", 0, "PlayOnce"],
	"VODABUL2": [10, 10.0, 0, "slightup", 0, "PlayOnce"],
	"debrisstone": [300, 15.0, 3, "random1", 9, "Infinite"],
	"debriswood": [300, 15.0, 3, "random1", 9, "Infinite"],
	"SHOTBLOCKHOUSE": [0, 0.0, 0, "immediate", 1, "PlayOnce"],
	"PUEXPKORVSKOR": [900, 50.0, 0, "slightup", 0, "PlayOnce"],
	"PUNOEXPKORVSKOR": [900, 50.0, 0, "slightup", 0, "PlayOnce"],
	"DIMMORT2KOR": [0, 0.0, 5, "slightup", 0, "PlayOnce"],
	"PUEXPONSHIP": [900, 10.0, 0, "slightup", 0, "PlayOnce"],
	"PPOINTTFRAME": [500, 20.0, 5, "angle", 15, "Infinite"],
	"PPOINTTFRAME5": [0, 0.0, 0, "slightup", 0, "PlayOnce"],
	"PU4FRAMEGRE": [10, 1.0, 0, "slightup", 0, "PlayOnce"],
	"POINTOTVZRIVFRAME": [110, 32.0, 5, "random1", 4, "Infinite"],
}

# §1.2 COMPLETE SetObjBaseProtection table — 33 donor rows [O]. Tuple order is
# (pike, sword, bullet, cannister, arrow, cannonball). A key with a `.` suffix is
# a nation/mercenary override of the base family; `tur_alg` is ONE donor row
# shared by both nations. Sids with no row here are donor-absent zero (§1.2 note):
# do NOT back-fill from a neighbour. `wall` is a single-slot cannister:=500 write.
const DONOR_PROT_ROWS := {
	"pikeman": [3, 2, 4, 210, 6, 40],                 # unit.script:634
	"pikeman.pol": [0, 0, 0, 0, 0, 0],                # :646
	"pikeman.tur_alg": [0, 0, 0, 0, 0, 0],           # :653
	"pikeman.rus": [2, 1, 4, 140, 4, 25],            # :660
	"pikeman.sco": [0, 0, 0, 0, 0, 0],               # :667
	"pikeman.spa": [3, 4, 6, 240, 12, 50],           # :674
	"pikeman.swi": [3, 3, 6, 220, 6, 45],            # :681 ({7}6 live=6)
	"pikeman.por": [0, 1, 1, 25, 4, 0],              # :688
	"roundshier": [3, 3, 7, 225, 16, 80],            # :739
	"roundshier.sco": [1, 2, 2, 110, 6, 10],         # :750 (swordsmansco)
	"roundshier.merc": [5, 3, 8, 225, 17, 80],       # :762 ({19}17 live=17)
	"musketeeraus": [2, 2, 5, 165, 5, 35],           # :919
	"musketeerspa": [3, 2, 5, 210, 7, 40],           # :928
	"officer": [2, 2, 5, 200, 10, 30],               # :1066
	"officer.rus": [0, 0, 0, 0, 0, 0],               # :1080
	"officer.tur": [0, 0, 0, 0, 0, 0],               # :1086
	"officer.sco": [0, 0, 0, 0, 0, 0],               # :1094
	"wingedhussar": [1, 2, 5, 160, 10, 30],          # :1366
	"reiter": [2, 6, 6, 190, 14, 40],                # :1424 group base
	"reiter.reiter": [2, 6, 6, 190, 15, 40],         # :1436 c3 re-pin (live reiter)
	"cuirassier": [2, 4, 10, 160, 5, 80],            # :1442
	"reiterswe": [2, 3, 7, 140, 7, 35],              # :1449
	"guardcavalrysax": [2, 5, 9, 150, 9, 70],        # :1457
	"reiterpol": [0, 0, 0, 0, 0, 0],                 # :1465
	"hetman": [0, 1, 3, 75, 3, 15],                  # :1474
	"cossackdon": [0, 0, 0, 0, 0, 0],                # :1484
	"vityaz": [2, 4, 3, 160, 17, 40],                # :1493
	"cossackregister": [0, 0, 0, 0, 0, 0],           # :1501
	"spakh": [0, 1, 0, 10, 2, 0],                    # :1510
	"mameluke": [1, 3, 1, 75, 8, 0],                 # :1519
	"lancersco": [0, 0, 0, 0, 0, 0],                 # :1528
	"sipahi": [3, 7, 4, 225, 24, 60],                # :1537
	"wall": [0, 0, 0, 500, 0, 0],                    # :1821 single-slot cannister:=500
}
const DONOR_PROT_NATION_TOKENS := ["pol", "tur", "alg", "rus", "sco", "spa", "swi", "por"]
const DONOR_PROT_SID_FAMILY := {
	"pikeman": "pikeman", "pikemanpol": "pikeman", "pikemantur": "pikeman",
	"pikemanrus": "pikeman", "pikemansco": "pikeman", "pikemanspa": "pikeman",
	"pikemanswi": "pikeman", "pikemanswis": "pikeman", "pikemanpor": "pikeman",
	"roundshier": "roundshier", "roundshierdip": "roundshier",
	"swordsmansco": "roundshier", "musketeeraus": "musketeeraus",
	"musketeerspa": "musketeerspa", "officer": "officer", "officerrus": "officer",
	"officertur": "officer", "officersco": "officer", "wingedhussar": "wingedhussar",
	"reiter": "reiter", "reiterswe": "reiter", "cuirassier": "cuirassier",
	"guardcavalrysax": "guardcavalrysax", "hetman": "hetman",
	"cossackdon": "cossackdon", "vityaz": "vityaz",
	"cossackregister": "cossackregister", "spakh": "spakh",
	"mameluke": "mameluke", "lancersco": "lancersco", "sipahi": "sipahi",
}
# Resolve a shipped sid + player nation + mercenary flag to the exact donor
# protection tuple. Returns donor-absent zero when no row exists (§1.2: do not
# back-fill). The live UNITS_BASE arrays stay as the sim's copy; this resolver is
# the cited 1:1 source used by T1-tail audits and by donor-mode consumers.
static func donor_protection(sid: String, nation: String = "", mercenary: bool = false) -> Array:
	var fam: String = str(DONOR_PROT_SID_FAMILY.get(sid, sid))
	if not DONOR_PROT_ROWS.has(fam):
		return [0, 0, 0, 0, 0, 0]
	var row: Array = (DONOR_PROT_ROWS[fam] as Array).duplicate()
	var nat: String = nation
	if nat == "" and sid.length() > fam.length():
		var tail: String = sid.substr(fam.length())
		if DONOR_PROT_NATION_TOKENS.has(tail):
			nat = tail
	if nat != "" and nat != "merc":
		var key: String = fam + "." + ("tur_alg" if nat == "tur" or nat == "alg" else nat)
		if DONOR_PROT_ROWS.has(key):
			row = (DONOR_PROT_ROWS[key] as Array).duplicate()
	if mercenary and DONOR_PROT_ROWS.has(fam + ".merc"):
		row = (DONOR_PROT_ROWS[fam + ".merc"] as Array).duplicate()
	return row

# §1.1 helpers. Donor `round()` is half-to-even (§1.1 caveat); the EXACT donor
# banker behaviour against the pinned binary is still [U]-G1 (X21 20-vector
# fixture, §9). No floor(x+0.5) substitute is used.
# [O] weapon.script:349-362 — the 14 PUSSTRELA `time` rows are the ONLY round()
#     in the shot path; each reads FramesToTime(round(...)) verbatim, never
#     pre-rounded. Delphi System.Round(X: Extended) is Bankers half-to-even
#     (ties -> even: 6.5->6, 5.5->6, 2.5->2, 7.5->8, ledger §3). The body below
#     is VERBATIM and MUST NOT become floor(x+0.5) (wrong on 3 of 4 ties).
#     [U]-G1 stays ONLY on the native @Round address; series R20/F7 are the
#     zero-mismatch gate before that tag may drop.
static func donor_round(x: float) -> int:
	var f: float = floorf(x)
	var frac: float = x - f
	if frac > 0.5:
		return int(f) + 1
	if frac < 0.5:
		return int(f)
	var fi: int = int(f)
	return fi if fi % 2 == 0 else fi + 1

# ─── DEC-U-WEAPON-TAIL §2.2 / §3 — DONOR SHIELD + MOUNT ROWS [O] ────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_weapon_tail.md
# Read-only donor text against pinned t_87f0f3c130b0; donor binary NEVER executed.
# Every row below is a verbatim donor literal carrying its unit.script:<line> cite.
# Brace values are DEAD Pascal comments and are NEVER ported (80{100} -> 80,
# 600{1250} -> 600, ...); only the live head is stored. `default` (-1, :593) means
# keep-prior. NO PARITY CLAIM; no interpolation from a neighbour row; donor-absent
# sids stay 0 and are NEVER back-filled. The [U]-G1 round() caveat stays on
# donor_round() above and on the verbatim time_expr rows in DONOR_WEAPON_PROTOS.

# §2.2 — objbase.shield: 12 cited rows H0-H11 [O]. H0 is the base law, 0 for EVERY
# sid (unit.script:617); sid-scoped overrides are the only non-zero values. The
# scoping is explicit in the KEY: yachttur-only (base yacht stays H0 0),
# battleship-only (frigate/xebec/chaika stay H0 0), commonrus-tower-only (other
# towers stay H0 0). The live per-unit "shield" fields in UNITS_BASE are the sim's
# estimated copy; this is the cited 1:1 source for T1-tail audits. DATA ONLY:
# no consumer is wired here, so adding it changes no runtime behaviour.
const DONOR_SHIELD_ROWS := {
	"(default)": 0,          # H0 unit.script:617 — objbase.shield := 0 (all sids)
	"cannon": 75,            # H1 unit.script:1702 — `75; // C1 was 90`
	"howitzer": 75,          # H2 unit.script:1738 — `75;` (port estimate 60 corrected below)
	"mortar": 25,            # H3 unit.script:1768 — `25;` (port estimate 40 corrected below)
	"multicannon": 50,       # H4 unit.script:1799 — `50;`
	"framegun": 50,          # H5 unit.script:1829 — `50; // C1 was 90`
	"yachttur": 100,         # H6 unit.script:1908 — yachttur ONLY; base yacht = H0 0
	"galley": 80,            # H7 unit.script:1929 — `80{100}` live head 80 ({100} dead comment)
	"battleship": 100,       # H8 unit.script:2000 — battleship ONLY; frigate/xebec/chaika = H0 0
	"misgeneral": 10,        # H9 unit.script:2083 — scenario marker, port label-only
	"tower.commonrus": 5,    # H10 unit.script:2245 — commonrus tower ONLY; other towers = H0 0
	"weakwall.ukr": 15 + 80, # H11 unit.script:2299 — `15+80` verbatim = 95 (ukrwwa,ukrwga)
}

# §3 — SetObjBaseWeapon mounts, exact donor tuples [O]. Tuple shape:
# [index, damage, pause_frames, rmin_px, rmax_px, detmin_px, detmax_px, kind,
#  bSearchMin]; attachments are the cited weaponsid / iron+coal per shot /
# addradius+dispertion in DONOR PIXELS / fxshot. Inside `tuple`, -1 is donor
# `default` (keep-prior, :593); in an attachment field it means NO donor write is
# cited for that entry (also keep-prior). Integer `350 div 2` (chaika :2019) is
# stored evaluated as 175 with the donor expression preserved in its note. Stone
# swa/sga, weakwall and ferry carry NO donor weapon and stay empty ([D] zero).
const DONOR_MOUNT_ROWS := {
	"cannon": {                                # unit.script:1696-1731
		"maxhp": 9000,                           # :1697 `9000{12500}` live head
		"price": [0, 250, 0, 400, 400, 0],     # :1715 verbatim tuple
		"mounts": [
			{"tuple": [0, 1800, 350, 550, 2160, 550, 100000, "cannonball", false],
				"weaponsid": "PPOINTT", "iron": 20, "coal": 40,
				"addradius_px": 32, "dispertion_px": 225, "fxshot": "shotcannon",
				"cite": ":1704-1709"},
			{"tuple": [1, 0, 350, 0, 450, 0, 550, "cannister", true],
				"weaponsid": "PSMPOINTTPUS", "iron": 24, "coal": 21,
				"addradius_px": -1, "dispertion_px": -1, "fxshot": "shotcannon",
				"cite": ":1711-1714", "note": "pause `350{1200}{c1 1400}` live 350 (:1711)"},
		],
	},
	"howitzer": {                              # :1732-1763
		"maxhp": 3000,                           # :1733 `3000{150}` live head
		"mounts": [
			{"tuple": [0, 4000, 600, 700, 1400, 0, 70000, "cannonball", true],
				"weaponsid": "DIMMORT1", "iron": 20, "coal": 100,
				"addradius_px": 32, "dispertion_px": 300, "fxshot": "shothowitzer",
				"cite": ":1740-1745",
				"note": "pause `600{1250}`=600; rmax `1400{950}`=1400; disp `300{250}`=300; :1739 was mortarball, min-radius was 500"},
		],
	},
	"mortar": {                                # :1764-1793
		"maxhp": 400,                            # :1765 `400{100}` live head
		"mounts": [
			{"tuple": [0, 200, 250, 1250, 2600, 0, 70000, "mortarball", true],
				"weaponsid": "DIMMORT2NEW", "iron": 20, "coal": 30,
				"addradius_px": 32, "dispertion_px": 200, "fxshot": "shotmortar",
				"cite": ":1772-1778",
				"note": "DIMMORT2 commented :1773; disp `(200){100}`=200"},
		],
	},
	"multicannon": {                           # :1794-1822
		"maxhp": 2000,                           # :1795 `2000{1000}` live head
		"mounts": [
			{"tuple": [0, 500, 60, 10, 700, 0, 50000, "cannister", true],
				"weaponsid": "PSMPOINTT", "iron": 40, "coal": 30,
				"addradius_px": 32, "dispertion_px": -1, "fxshot": "shotmcannon",
				"cite": ":1801-1805",
				"note": "c1 max range 950 comment :1800; protection cannister:=500 :1821"},
		],
	},
	"framegun": {                              # :1823-1853
		"maxhp": 3000,                           # :1824
		"mounts": [
			{"tuple": [0, 500, 90, 200, 1800, 250, 100000, "cannonball", false],
				"weaponsid": "PPOINTTFRAME", "iron": 30, "coal": 40,
				"addradius_px": 32, "dispertion_px": 250, "fxshot": "shotcannon",
				"cite": ":1831-1836"},
		],
	},
	"yacht": {                                 # :1873-1886 base
		"maxhp": 31000,                          # :1874
		"mounts": [
			{"tuple": [0, 1000, 350, 300, 1100, 0, 50000, "cannonball", true],
				"weaponsid": "PPOINTTKOR", "iron": 4, "coal": 9,
				"addradius_px": 32, "dispertion_px": 250, "fxshot": "",
				"cite": ":1881-1885"},
		],
	},
	"yacht.yachttur": {                        # :1903-1920 override (shield H6)
		"maxhp": 35000,                          # :1903-1920
		"mounts": [
			{"tuple": [0, 30, 400, -1, 1000, 300, 1000, -1, true],
				"weaponsid": "", "iron": 5, "coal": 15,
				"addradius_px": -1, "dispertion_px": 25, "fxshot": "",
				"cite": ":1909-1912", "note": "rmin/kind are donor `default` (-1 keep-prior; kind stays cannonball)"},
			{"tuple": [1, 0, 700, 1000, 1650, 1000, 100000, -1, false],
				"weaponsid": "PPOINTTKOR", "iron": 5, "coal": 15,
				"addradius_px": -1, "dispertion_px": 25, "fxshot": "",
				"cite": ":1913-1917", "note": "kind donor `default` (-1 keep-prior)"},
		],
	},
	"galley": {                                # :1922-1958
		"maxhp": 35000,                          # :1923
		"mounts": [
			{"tuple": [0, 100, 150, 300, 1200, 300, 100000, "cannonball", true],
				"weaponsid": "PPOINTTKOR", "iron": 4, "coal": 9,
				"addradius_px": -1, "dispertion_px": 25, "fxshot": "",
				"cite": ":1930-1934"},
			{"tuple": [1, 1000, 50, 1100, 3100, 1100, 100000, "mortarball", false],
				"weaponsid": "DIMMORT2KOR", "iron": 4, "coal": 9,
				"addradius_px": 32, "dispertion_px": 200, "fxshot": "",
				"cite": ":1935-1940", "note": "mortarball has no port WK slot; do not remap to cannonball here"},
		],
	},
	"frigate": {                               # :1959-1988 base
		"maxhp": 50000,                          # :1960
		"mounts": [
			{"tuple": [0, 1800, 75, 400, 1650, 0, 50000, "cannonball", true],
				"weaponsid": "PPOINTTKOR", "iron": 25, "coal": 35,
				"addradius_px": 32, "dispertion_px": 250, "fxshot": "",
				"cite": ":1966-1971"},
		],
	},
	"frigate.xebec": {                         # :1989-1997 override
		"maxhp": 65000,                          # :1989-1997
		"mounts": [
			{"tuple": [0, -1, 50, 550, 1700, -1, 70000, "cannonball", true],
				"weaponsid": "", "iron": -1, "coal": -1,
				"addradius_px": -1, "dispertion_px": -1, "fxshot": "",
				"cite": ":1993", "note": "damage and detmin are donor `default` (-1 keep-prior)"},
		],
	},
	"frigate.battleship": {                    # :1998-2012 override (shield H8)
		"maxhp": 90000,                          # :1998-2012
		"mounts": [
			{"tuple": [0, -1, 20, 600, 1950, 600, -1, "cannonball", true],
				"weaponsid": "", "iron": 5, "coal": 15,
				"addradius_px": -1, "dispertion_px": -1, "fxshot": "",
				"cite": ":2003-2005", "note": "damage and detmax are donor `default` (-1 keep-prior)"},
		],
	},
	"frigate.chaika": {                        # :2013-2030 override
		"maxhp": 25000,                          # :2013-2030
		"mounts": [
			{"tuple": [0, 1000, 175, 300, 1100, 0, 50000, "cannonball", true],
				"weaponsid": "", "iron": 4, "coal": 9,
				"addradius_px": -1, "dispertion_px": -1, "fxshot": "",
				"cite": ":2019-2021", "note": "pause `350 div 2` (donor integer div) = 175"},
		],
	},
	"ferry": {                                 # :2033-2049 — unarmed transport [D]
		"maxhp": 62000,                          # :2034
		"mounts": [],                            # NO SetObjBaseWeapon: donor-absent zero
	},
	"tower": {                                 # commonsid+'tow' :2223-2257
		"mounts": [
			{"tuple": [0, 1000, 400, 550, 1500, 550, 50000, "cannonball", true],
				"weaponsid": "PPOINTTTOW", "iron": 10, "coal": 30,
				"addradius_px": -1, "dispertion_px": 100, "fxshot": "shottower",
				"cite": ":2227-2232"},
		],
	},
	"tower.commonrus": {                       # :2241-2246 override (shield H10)
		"mounts": [
			{"tuple": [0, -1, 300, -1, -1, -1, -1, "cannonball", true],
				"weaponsid": "", "iron": -1, "coal": -1,
				"addradius_px": -1, "dispertion_px": 125, "fxshot": "",
				"cite": ":2246", "note": "all -1 fields are donor `default` keep-prior; disp `(125)` override"},
		],
	},
	"tower.commontur": {                       # :2248-2256 override
		"mounts": [
			{"tuple": [0, 1200, 500, -1, 1600, -1, -1, "cannonball", true],
				"weaponsid": "", "iron": 15, "coal": 40,
				"addradius_px": -1, "dispertion_px": -1, "fxshot": "",
				"cite": ":2252-2254", "note": "rmin/detmin/detmax are donor `default` (-1 keep-prior); coal 40 / iron 15 (:2253-2254)"},
		],
	},
	"stonewall": {                             # commonsid+'swa','sga' :2258-2284
		"mounts": [],                            # NO weapon, NO shield, NO protection [D]
	},
	"weakwall.ukr": {                          # ukrwwa,ukrwga :2285-2310
		"mounts": [],                            # NO weapon, NO protection; shield H11 = 95
	},
}

static func donor_weapon_row(sid: String) -> Dictionary:
	var t: Variant = DONOR_WEAPON_PROTOS.get(sid, null)
	if t == null:
		return {}
	var r: Array = t
	var prop: String = str(r[3])
	var radius_px: float = float(r[1])
	var expr: String = str(r[5])
	var frames: int = -1
	if expr == "Infinite":
		frames = -1                       # cInfinite
	elif expr == "PlayOnce":
		frames = 0                        # cPlayOnce (no periodic fire)
	else:
		var inner: String = expr.trim_prefix("FramesToTime(").trim_suffix(")")
		if inner.begins_with("round("):
			var arg: String = inner.trim_prefix("round(").trim_suffix(")")
			var parts: PackedStringArray = arg.split("*")
			var product: float = 1.0
			for p in parts:
				product *= float(p)
			frames = donor_round(product)
		else:
			frames = int(inner)  # non-round donor time_expr rows are plain integers
	return {"sid": sid, "damage": int(r[0]), "radius_px": radius_px,
		"radius_tiles": radius_px / DEC_U_PX_PER_TILE, "radius_m": radius_px * PX_TO_M,
		"gravity": int(r[2]), "propagation": prop,
		"propagation_id": int(DONOR_WEAPON_PROPAGATION.get(prop, 0)),
		"physvalue": int(r[4]), "phys_means": str(DONOR_PHYS_MEANING.get(prop, "unused")),
		"time_expr": expr, "time_frames": frames,
		"time_seconds": float(frames) * (1.0 / FRAMES_PER_TIME) if frames > 0 else 0.0}

# §2 — `_misc_DoDamage` exact net law (miscext2.script:274-465, :439). The
# caller owns HP/score/kill bookkeeping; this returns the integer damage dealt.
# Priest attacks are the HEAL path: caller adds indamage to target.hp (capped at
# maxhp) and skips protection/headshot entirely — indamage is returned verbatim.
# There is NO height, dispersion or distance term anywhere in this function.
static func donor_do_damage(indamage: int, weap_kind: String, target: Dictionary, ctx: Dictionary) -> int:
	if bool(ctx.get("priest_attacker", false)):
		return indamage                                   # :371-377 heal path
	var damage: int = indamage
	var shield: int = int(target.get("shield", 0))
	if bool(target.get("finished", true)):
		damage -= shield                                   # :339-340 built
	else:
		damage -= int(floorf(float(shield) / 3.0))         # :341-342 integer div
	# Defender squad hold shield (defender's current hold state).
	if bool(ctx.get("defender_hold", false)):
		damage -= int(ctx.get("defender_shield_hold", 0))
	else:
		damage -= int(ctx.get("defender_shield", 0))
	if bool(ctx.get("process_logic", true)):
		# Attacker squad hold damage bonus; firearrow is excluded from the bonus.
		if bool(ctx.get("attacker_hold", false)):
			damage += int(ctx.get("attacker_damage_hold", 0))
		else:
			damage += int(ctx.get("attacker_damage", 0))
	# protection[weapkind] (6-slot port mirror; firearrow resolves to 0).
	var prot: Array = target.get("prot", [0, 0, 0, 0, 0, 0])
	var wk: int = int(WK.get(weap_kind, 0))
	if wk >= 0 and wk < PROT_SLOT.size():
		var slot: int = PROT_SLOT[wk]
		if slot >= 0 and slot < prot.size():
			damage -= int(prot[slot])
	# Headshot: bCanHeadShot && random<0.05 && !bFastHorseBullet, then
	# floor(uniqrnd*500). `uniqrnd` is per-unit, NOT an extra stream draw.
	if bool(ctx.get("can_headshot", false)) and bool(ctx.get("headshot_roll", false)) \
			and not bool(ctx.get("fast_horse_bullet", false)):
		damage += int(floorf(float(ctx.get("uniqrnd", 0.0)) * 500.0))
	# Fast-horse bullet penalty (step 6, before protection in donor order).
	if bool(ctx.get("fast_horse_bullet", false)):
		damage -= 5
	if damage < 1:
		damage = 1                                        # :439
	return damage

# :443-464 — killer.score += 2*target.score, inside-units +3*each, kill += 1.
static func donor_kill_score(target_score: int, inside_unit_scores: Array) -> int:
	var s: int = 2 * int(target_score)
	for v in inside_unit_scores:
		s += 3 * int(v)
	return s

# §3 — capture constants, all [O] donor text. `dmscript.global:172` px/tile and
# TILE_M=2 convert px -> tiles -> metres; the radii are TILES in donor, not metres.
const DONOR_CAPTURE_INTERVAL_S := 1.875            # 0.1*19 - 0.025 (dmscript.global:1476,1479-1480)
const DONOR_CAPTURE_ART_INTERVAL_S := 0.475        # 0.1*5 - 0.025
const DONOR_CAPTURE_PX := 214.0                    # :207-209 captureradius
const DONOR_BLOCKSHOT_PX := 160.0                  # :217-219 blockshotradius
const DONOR_PROTECTION_PX := 426.0                 # :217-219 protectorradius
const DONOR_BLOCKSHOT_LOCK_FRAMES := 100           # :1036-1040 (100*gc_frames_to_time)
const DONOR_SLOW_DEATH_HP := 1999                  # gc_BuildingSlowDeathHP :129
const DONOR_SLOW_DEATH_RAND := 300                 # RandomExt span :130
const DONOR_AI_EASY_MAX := 1                       # bEasy := aidifficulty < veryhard (2)
# :1073-1088 — AI artillery suicide majority. Evaluated ONLY when owner is AI
# and the target is bartillery; the easy-player roll gate is applied by caller.
const DONOR_AI_ART_MAJORITY := {
	1: 0,   # capturers >= protectors  (> protectors-1)
	2: 3,   # capturers > 3
	3: 7,   # capturers > 7
	4: 10,  # capturers > 10
}
# :1147-1173 — exact die-roll thresholds (random > value => bDie).
const DONOR_AI_DIE_ROLL := {
	"building": 0.25, "supermortar": 0.5859375, "cannon": 0.390625,
	"mortar": 0.140625, "peasant": 0.546875,
}
static func donor_capture_ai_art_suicide(protectors: int, capturers: int) -> bool:
	if protectors == 1:
		return capturers >= protectors
	if DONOR_AI_ART_MAJORITY.has(protectors):
		return capturers > int(DONOR_AI_ART_MAJORITY[protectors])
	return false

# §4 — start 6-resource tables (startingsettings.cfg:87-858, dispatch
# dogenerate.inc:255-292). One top-level addresources block is applied, then the
# SAME block is applied AGAIN per matched country => 2x, the X09-7 double-add
# quirk. startid 4 tur/alg adds +1000 gold ONCE from the country override.
# RES_NAMES order: food, wood, stone, gold, iron, coal.
const DONOR_START_RESOURCES := {
	"-1": [0, 0, 0, 0, 0, 0],                       # :89-97 example
	"0": [0, 0, 0, 0, 0, 0],                        # :183-184 no block
	"1": [1000, 0, 0, 0, 0, 0],                     # :190-197 armysmall
	"2": [20000, 0, 0, 0, 0, 0],                    # :317-324 armymedium
	"3": [20000, 0, 0, 0, 6000, 9000],              # :506-513 armylarge
	"4": [20000, 0, 0, 0, 6000, 9000],              # :723-730 peasantslot
}
const DONOR_START_COUNTRY_GOLD := {"4": {"tur": 1000, "alg": 1000}}  # :820-827
const DONOR_START_DATAVERSION := [60, 1000]        # dataversionmin/max on 1-4
static func donor_start_resources(startid: int, nation: String = "") -> Array:
	var base: Array = (DONOR_START_RESOURCES.get(str(startid), [0, 0, 0, 0, 0, 0]) as Array).duplicate()
	var out: Array = []
	for v in base:
		out.append(2 * int(v))                       # double-add quirk DG:255-292
	var key: String = str(startid)
	if DONOR_START_COUNTRY_GOLD.has(key):
		var bynat: Dictionary = DONOR_START_COUNTRY_GOLD[key]
		if bynat.has(nation):
			out[3] = int(out[3]) + int(bynat[nation])
	return out

# §4.2 — role char -> AI role id (dmscript.global:341-398). Q/W are basenames
# (misblg / misblg2), not AI roles, so they map to 0 and are resolved by basename.
const DONOR_ROLE_TO_AIROLE := {"X": 1, "O": 21, "B": 22, "P": 23, "Q": 0, "W": 0}
# §4.3 legend P-role by start group (startid:nation -> airole).
const DONOR_START_P_ROLE := {
	"1:default": 23, "1:ukr": 25,
	"2:default": 26, "2:alg": 26, "2:tur": 26, "2:ukr": 26,
	"3:default": 25, "3:pol": 25, "3:ukr": 25, "3:alg": 34,
}
const DONOR_START_UNIT_RADIUS_FACTOR := 4           # gc_obj_radius_default*tiles_to_pixels*4
const DONOR_START_DIR_DEG := -90.0
# §4.3 masks — verbatim strings ONLY where the report actually prints them.
# Entries with `verbatim=false` carry the derived P/X counts but NO invented row
# text; experiment §9-S-mask: re-read startingsettings.cfg:<line> to recover the
# exact strings. P-counts are counted from P chars, never estimated.
const DONOR_START_MASKS := {
	"1:default": {"verbatim": false, "cite": "startingsettings.cfg:260-268",
		"counts": {"O": 2, "B": 2, "P": 72, "X": 30, "Q": 1, "W": 1},
		"rows": []},
	"1:ukr": {"verbatim": true, "cite": "startingsettings.cfg:300-308",
		"counts": {"P": 48, "X": 24, "Q": 1, "W": 1},
		"rows": ["PPPP..XXXXXX..PPPP", "PPPP..XXXXXX..PPPP", "PPPP..XXXXXX..PPPP",
			"PPPP..XXXXXX..PPPP", "PPPP..XXXXXX..PPPP", "PPPP..XXXXXX..PPPP"]},
	"2:default": {"verbatim": true, "cite": "startingsettings.cfg:373-380",
		"counts": {"P": 96, "X": 36},
		"rows": ["PPPPPPPP..XXXXXX..PPPPPPPP", "PPPPPPPP..XXXXXX..PPPPPPPP",
			"PPPPPPPP..XXXXXX..PPPPPPPP", "PPPPPPPP..XXXXXX..PPPPPPPP",
			"PPPPPPPP..XXXXXX..PPPPPPPP", "PPPPPPPP..XXXXXX..PPPPPPPP"]},
	"2:alg": {"verbatim": false, "cite": "startingsettings.cfg:412-419",
		"counts": {"P": 168, "X": 36}, "rows": []},
	"2:tur": {"verbatim": false, "cite": "startingsettings.cfg:451-458",
		"counts": {"P": 180, "X": 36}, "rows": []},
	"2:ukr": {"verbatim": false, "cite": "startingsettings.cfg:490-497",
		"counts": {"P": 108, "X": 36}, "rows": []},
	"3:default": {"verbatim": true, "cite": "startingsettings.cfg:574-581",
		"counts": {"O": 6, "B": 3, "P": 72, "X": 18},
		"rows": ["PPPPPP..PPPPPP", "PPPPPP..PPPPPP", "PPPPPP..PPPPPP",
			"PPPPPP..PPPPPP", "PPPPPP..PPPPPP", "PPPPPP..PPPPPP"]},
	"3:pol": {"verbatim": false, "cite": "startingsettings.cfg:626-634",
		"counts": {"O": 2, "B": 2, "P": 72, "X": 30}, "rows": []},
	"3:ukr": {"verbatim": false, "cite": "startingsettings.cfg:666-673",
		"counts": {"P": 72, "X": 36}, "rows": []},
	"3:alg": {"verbatim": false, "cite": "startingsettings.cfg:705-714",
		"counts": {"P": 112}, "rows": []},
	"4:default": {"verbatim": false, "cite": "startingsettings.cfg:773-780",
		"counts": {"X": 96}, "rows": []},
	"4:ukr": {"verbatim": false, "cite": "startingsettings.cfg:806-813",
		"counts": {"X": 96}, "rows": []},
	"4:tur_alg": {"verbatim": false, "cite": "startingsettings.cfg:848-855",
		"counts": {"X": 96}, "rows": []},
}

# §5 — A1 head literals [O]. ai.gd is OUT OF AUTHORIZED SCOPE for this worker;
# these are the cited source constants for a later A1 wiring, not a behaviour
# change here. The remainder is PORT-AI / [U]-A1-tail (experiment §9).
const DONOR_AI_DISBAND_PERCENT := 0.25            # progress.inc:5-35, global:156
const DONOR_AI_HOLD_SECONDS := 37.5               # progress.inc:156-172, global:180
const DONOR_AI_MAX_GUARDS := 120                  # global:500
# §5-G1 — AI classification sampler literals [O]/[D]; DONOR-TEXT LABELS ONLY.
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_guard_sampler.md §1/§3
# (pin t_87f0f3c130b0; donor text read-only, no donor binary run, no behaviour).
# _misc_RandToRandom(v) = v/gc_c1rand_to_random = v/32768
#   (misc.script:484-490; dmscript.global:176 = DEC_U_C1RAND_TO_RANDOM above).
# EXACT fractions [D] — percentages, NOT rounded; nothing invented:
#   3000/32768  =  9.1552734375%  — NON-AI shooter/grenadier, guards.GetCount<120 (unit.script:3644)
#   10000/32768 = 30.517578125%   — AI first roll (freewarrior), freewarriors.GetCount<20 (unit.script:3655)
#   6000/32768  = 18.310546875%   — AI second roll (defender), guards.GetCount<120 (unit.script:3658)
#   20000/32768 = 61.03515625%    — NON-AI lightinfantry, guards.GetCount<120 (unit.script:3665)
const DONOR_AI_SAMPLER := {                        # RandToRandom(v)=v/32768
	"nonai_shooter_grenadier": 3000, # unit.script:3644 — non-AI shooter/grenadier + guards<120
	"ai_freewarrior": 10000,          # unit.script:3655 — AI roll 1 + freewarriors<20
	"ai_defender": 6000,              # unit.script:3658 — AI roll 2 + guards<120
	"nonai_lightinfantry": 20000,     # unit.script:3665 — non-AI lightinfantry + guards<120
}
# §1-D/§7-2 — priest / freewarrior-overflow gate, STRICT inequalities [O]:
#   bPriest OR (freewarriors.GetCount > 15 AND guards.GetCount > 120) -> agressors
#   (unit.script:3649-3650). free_low_lt:20 is the DISTINCT AI-sampler first-arm
#   cap freewarriors.GetCount < 20 (unit.script:3655). Values 15/120/20 unchanged;
#   inert data, no consumer. `=120` hits the one-wide dead band: neither
#   overflow (>120, :3649) nor sampler caps (<120, :3638/:3658) — see flag below.
const DONOR_AI_FREEWARRIOR_GATE := {"free_gt": 15, "guards_gt": 120, "free_low_lt": 20}
# §1/§7-1 — one-wide dead band [D]: guards.GetCount == 120 satisfies NEITHER the
#   overflow gate (>120, unit.script:3649) NOR the sampler caps (<120,
#   unit.script:3638/:3658/:3665). Inert telemetry flag; no branch reads it.
const DONOR_AI_GUARD_DEADBAND_120 := true
# §3/§7-1 — per-candidate S-draw shape [D]; corrects the earlier single-draw
#   ledger note (DEC_U_rng_ledger.md S5-a):
#     AI: 1-2 short-circuit — 10000 free-roll always drawn; 6000 def-roll only
#         when arm 1 fails (roll OR freewarriors>=20); free-roll then def-roll.
#     non-AI: 0-or-1 — 3000 shooter/grenadier (:3644), 20000 lightinfantry (:3665).
#   Inert data; no draw happens here. [U]-G1b (Series S200, zero mismatches).
const DONOR_AI_SAMPLER_DRAWS := {"ai": "1-2 short-circuit, free-roll then def-roll", "nonai": "0-or-1"}
const DONOR_AI_FEAR_NEAR := 30.0                   # dist<30 && enForce>myForce
const DONOR_AI_FEAR_TRACK := 400.0                 # dist<400 track nearest
const DONOR_AI_MAX_ATTACKERS := {"food": 3, "wood": 2, "stone": 3, "none": 4}

# §7 — O1 stagger/lose-stamp head [O]. Only the EXISTS block is gated by the
# stagger; the per-player income/consume/hold/disband slice is not.
const DONOR_TICK_EXISTS_SLOT_S := 0.125            # 0.125*plInd
const DONOR_TICK_EXISTS_ALIVE_S := 8.0             # 4*TimeCheckExists (2.0 s)
const DONOR_TICK_EXISTS_DEAD_S := 24.0             # 12*TimeCheckExists
const DONOR_TICK_MOVECOUNT_SLOT_S := 0.001         # (0.001*plInd)+0.3 s

# §8 — G1 RNG draw ledger [O] site inventory. Stream labels are DONOR FACTS per
# DEC_U_rng_ledger.md §4: S = sim `RandomExt` LCG, G = general Delphi `Random()`,
# stored = per-unit `uniqrnd` (NOT a draw). They do NOT implement the split:
# cross-stream byte ORDER, per-site draw COUNTS and G VALUES stay [U]-G1
# (X21 20-vector fixture / series L20+C300; ZERO mismatches needed to wire).
# No draw order, count or value is invented here.
#
# [D] LCG recurrences — DONOR-VERBATIM constants (X21 §2/§4, D02 §4.1/§4.3):
#     S: s <- (s*DONOR_LCG_M + DONOR_LCG_C) & 0xFFFFFFFF; f32(s/2^32).
#     G: d <- (d*DONOR_DELPHI_M + DONOR_DELPHI_C) & 0xFFFFFFFF; f32(d*2^-32).
#     PORT APPROXIMATION: port `rng`/`gen_rng` are Godot RandomNumberGenerator,
#     NOT these recurrences; labelled here as data only, never substituted live.
const DONOR_DELPHI_M := 0x8088405                   # Delphi Random() multiplier (0x403a0c, 0x8f2008; D02 §4.1)
const DONOR_DELPHI_C := 1                           # Delphi Random() increment: seed=seed*M+1 (D02 §4.1)
const DONOR_LCG_M := 64525                          # 0xFC0D RandomExt multiplier (X21 §2, 0x60f65d)
const DONOR_LCG_C := 1013904223                     # 0x3C6EF35F RandomExt increment (X21 §2)
const DONOR_RNG_DRAW_SITES := [
	{"site": "GetRandom(n)", "formula": "floor(RandomExt*n)", "cite": "dogenerate.inc:990-997", "stream": "S"},
	{"site": "GetRandomRange(min,max)", "formula": "min+floor(RandomExt*(max-min+1))", "cite": "dogenerate.inc:994-997", "stream": "S"},
	{"site": "RandomInt", "formula": "floor(random*32768)", "cite": "misc.script:493-498", "stream": "G"},
	{"site": "famine_rebellion", "formula": "floor(random*32768)", "cite": "misc.script:493-498", "stream": "G"},
	{"site": "capture_ai_easy", "formula": "random>0.5", "cite": "miscext.script:1082", "stream": "G"},
	{"site": "capture_ai_building", "formula": "random>0.25", "cite": "miscext.script:1147", "stream": "G"},
	{"site": "capture_die_rolls", "formula": "random>0.5859375/0.390625/0.140625/0.546875", "cite": "miscext.script:1147-1173", "stream": "G"},
	{"site": "slow_death", "formula": "1999-floor(RandomExt*300)", "cite": "miscext.script:1152", "stream": "S"},
	# [D] DEC-U-GUARD-SAMPLER §3: this site draws 1-2 S values by short-circuit,
	#     NOT a single draw. AI: 10000 free-roll (:3655) always, 6000 def-roll
	#     (:3658) only when arm 1 fails on roll OR freewarriors>=20; order
	#     free-roll then def-roll. non-AI: 0-or-1 (:3644/:3665). [U]-G1b until
	#     Series S200 captures match with zero mismatches. formula/stream unchanged.
	{"site": "guard_sampler", "formula": "RandomExt<v/32768", "cite": "unit.script:3638-3668", "stream": "S"},
	{"site": "damage_headshot_gate", "formula": "random<0.05", "cite": "miscext2.script:420", "stream": "G"},
	{"site": "damage_headshot_bonus", "formula": "floor(uniqrnd*500)", "cite": "miscext2.script:437", "stream": "stored"},
	{"site": "capture_jitter", "formula": "random*TimeCheckCapture", "cite": "miscext2.script:2757", "stream": "G"},
]
# [O] LIVE wrapper — UNCHANGED. `r` is an already-drawn SIM-stream RandomExt
#     float in 0..1 (upper exclusive); no RNG drawn here (dogenerate.inc:990-997).
#     The f32/f64 helpers below are INERT telemetry and are NEVER called here.
static func donor_get_random(r: float, n: int) -> int:
	return int(floorf(r * float(n)))                # dogenerate.inc:990-997

# ── §8 G1-e TELEMETRY (INERT — no live consumer) ────────────────────────────────
# [O]/[D] X21 §2/§4.5: RandomExt = f32(s/2^32); `fstp dword` is the ONLY rounding.
#     DScript promotion of f32(r)*n stays [U]-G1-e: §6 saw no divergence over
#     the 20 vectors for n in {3,5,10,256}; series F1M sweeps n in {1..512,
#     100000} before the tag may drop. Both helpers take an ALREADY-DRAWN r —
#     NO new draw, NO stream split, NO game.gd change. Telemetry only.
static func donor_get_random_f32(r: float, n: int) -> int:
	var f32r := PackedFloat32Array()
	f32r.append(r)
	return int(floorf(f32r[0] * float(n)))          # f32-product path (G1-e)

static func donor_get_random_f64(r: float, n: int) -> int:
	return int(floorf(r * float(n)))                # f64 comparator, G1-e ONLY

# §6 — R1 save framing INVENTORY [O-shape]. Names and record sizes are donor
# text; the BYTE ORDER inside each record stays [U]-R1 (full write*.inc/read*.inc
# field-order enumeration + round-trip test, §9). The port v5 save is a PORT
# EXTENSION contract — no byte parity is claimed and no version/key is changed.
const DONOR_SAVE_FRAMING := {
	"player": {"write": 1133, "read": 942, "bytes_order": "[U]-R1"},
	"sync": {"write": 5272, "read": 5951, "bytes_order": "[U]-R1"},
	"wall": {"write": 11393, "read": 10116, "bytes_order": "[U]-R1"},
	"proj": {"write": 3368, "read": 2766, "bytes_order": "[U]-R1"},
	"squadnew": {"write": 7145, "read": 4456, "bytes_order": "[U]-R1"},
	"order": {"write": 2997, "read": 7294, "bytes_order": "[U]-R1"},
	"move": {"write": 7441, "read": 3069, "bytes_order": "[U]-R1"},
	"death": {"write": 5220, "read": 3489, "bytes_order": "[U]-R1"},
	"upgrade": {"write": 7251, "read": 3540, "bytes_order": "[U]-R1"},
	"peacetime": {"write": 1478, "read": 1423, "bytes_order": "[U]-R1"},
	"traderesources": {"write": null, "read": null, "bytes_order": "[U]-R1"},
	"squadrecord": {"fields": ["fBaseCount:Integer", "fStandGround:Boolean"],
		"cite": "serial.script:1035-1036,1106-1107,1178-1179,1246-1247",
		"bytes_order": "[U]-R1"},
}

# protection order: [pike, sword, bullet, cannister, arrow, cannonball]
# DONOR-VERBATIM per-sid train frames (DEC-U-VICTORY-START §4.1/§4.4): each
# `"build_time": <frames> * FRAMES_TO_TIME` below is a unit.script per-sid frame
# literal through _misc_FramesToTime (unit.script:571-581; NO ×10). Buildings use
# donor_buildtime_to_time (×10 gc_buildtime_modifier, unit.script:478-506). These
# literals ARE the only per-category timing source; no extra constant exists.
# ─── DEC-U MOVE-SPEED §1.3/§7-S1 — SPEED ROW LABEL (DATA ONLY, NO ACTIVATION) ───
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_move_speed.md §1.1-§1.4, §7 S1.
# EVERY `"speed"` value in UNITS_BASE below is a PORT APPROXIMATION and is
# DEFINED-BUT-UNCONSUMED in the donor: dmscript.global:603-620 defines the px
# constants, but unit.script:618 unconditionally sets `objbase.speed := 1` for
# every sid and ALL per-sid `objbase.speed :=` writes (unit.script:1192-2037)
# are `//`-dead. The land ladder matches §1.1 × PX_TO_M arithmetically [D] but
# NO live donor consumer is sampled: [U] U-speed-consumer (T-SPEED trace).
# NEVER present these rows as donor-verified locomotion; DO NOT retune/activate.
# Naval rows (yacht/fishboat/yachttur/galley/frigate/xebec/battleship) keep
# their existing PORT ESTIMATES (NOT donor-verbatim) flag below; the exact
# §1.1 ship constants are appended as INERT DONOR_SHIP_SPEED_CONST, never
# substituted into these rows. The constants' px/s UNIT is [I] (MECHANICS.md);
# the m/s column is [D] exact arithmetic. NO PARITY CLAIM.
const UNITS_BASE := {
	"peasant": {
		"hp": 75, "speed": 1.5, "score": 20, "aiforce": 1, "worker": true,
		"price": {"food": 100}, "build_time": 400 * 0.03125, "search": 300 * PX_TO_M,
		"eat": {"food": 32},
		"weapons": [{"kind": "sword", "dmg": 20, "min": 10 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(184, 0, 46, 46),
	},
	"pikeman": {
		"hp": 90, "speed": 1.2, "score": 10, "aiforce": 10,
		"price": {"food": 25, "gold": 3, "iron": 20}, "build_time": 144 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "pike", "dmg": 8, "min": 35 * PX_TO_M, "max": 100 * PX_TO_M, "cd": 1.25}],
		"prot": [3, 2, 4, 210, 6, 40],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	"roundshier": {
		"hp": 100, "speed": 1.2, "score": 7, "aiforce": 10,
		"price": {"food": 20, "gold": 3, "iron": 25}, "build_time": 128 * 0.03125, "search": 600 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "sword", "dmg": 6, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [3, 3, 7, 225, 16, 80],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"serdiuk": {
		"hp": 85, "speed": 1.2, "score": 12, "aiforce": 2, "no_melee": true,
		"price": {"food": 60, "gold": 11, "iron": 5}, "build_time": 352 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"archer": {
		"hp": 40, "speed": 1.2, "score": 15, "aiforce": 2, "no_melee": true,
		"price": {"food": 20, "wood": 2, "gold": 1}, "build_time": 48 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "arrow", "dmg": 15, "min": 400 * PX_TO_M, "max": 800 * PX_TO_M, "cd": 75 * 0.03125,
			"cost": {"wood": 1}, "splash": 20 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	"cossack": {
		"hp": 250, "speed": 3.6, "score": 35, "aiforce": 25, "cavalry": "fast",
		"price": {"food": 130, "iron": 2}, "build_time": 432 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "sword", "dmg": 13, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"dragoon": {
		"hp": 225, "speed": 2.1, "score": 40, "aiforce": 15, "cavalry": "hard",
		"price": {"food": 70, "gold": 60, "iron": 7}, "build_time": 720 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 45},
		"weapons": [{"kind": "bullet", "dmg": 19, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 170 * 0.03125,
			"cost": {"iron": 4, "coal": 5}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	"officer": {
		"hp": 125, "speed": 1.2, "score": 10, "aiforce": 5,
		"price": {"food": 50, "gold": 150, "iron": 30}, "build_time": 320 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 60},
		"weapons": [{"kind": "pike", "dmg": 30, "min": 35 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [2, 2, 5, 200, 10, 30],
		"radius": 0.35,
		"icon": Rect2(0, 184, 46, 46),
	},
	"cannon": {
		"hp": 9000, "speed": 0.75, "score": 50, "aiforce": 1, "artillery": true, "shield": 75,
		"price": {"wood": 250, "gold": 400, "iron": 400}, "build_time": 2400 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 300},
		# W2-2 data truth: donor lib/unit.script:1710 cannon weapon[1] (cannister)
		# has radiusmax = 450 px, detectmax = 550 px. Every port weapon range is
		# donor pixels * PX_TO_M (metres; header line 16), so 450 px -> 16.875 m.
		# The old 175 px (6.5625 m) made the cannon advance instead of firing in
		# the 175-450 px band. Only the range is corrected here; cd/cost stay as
		# the existing port estimates (donor: pause 350, iron 24, coal 21).
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 550 * PX_TO_M, "max": 2160 * PX_TO_M, "cd": 350 * 0.03125,
			"cost": {"iron": 20, "coal": 40}, "splash": 35 * PX_TO_M},
			{"kind": "cannister", "dmg": 300, "min": 0.0, "max": 450 * PX_TO_M, "cd": 300 * 0.03125,
			"cost": {"iron": 10, "coal": 20}, "splash": 60 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(138, 230, 46, 46),
	},
	# Video pass: the original marches officers with flags, drummers beating
	# the pace, and priests in black robes healing the line (all visible in
	# any Cossacks 3 battle video). Stats estimated, marked so in mechanics.
	"officer18": {
		"hp": 140, "speed": 1.2, "score": 12, "aiforce": 6,
		"price": {"food": 60, "gold": 180, "iron": 40}, "build_time": 360 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 70},
		"weapons": [{"kind": "pike", "dmg": 32, "min": 35 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [2, 2, 5, 200, 10, 30],
		"radius": 0.35,
		"icon": Rect2(0, 184, 46, 46),
	},
	"drummer": {
		"hp": 60, "speed": 1.32, "score": 8, "aiforce": 3, "support": true,
		"price": {"food": 30, "gold": 20}, "build_time": 200 * 0.03125, "search": 6000 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(46, 184, 46, 46),
	},
	"priest": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	# Late-game roster visible in every battle video (stats estimated, marked
	# so in mechanics; grenade base 110 dmg / 50 px from weapon.script NUCLGRE).
	"grenadier": {
		"hp": 110, "speed": 1.2, "score": 18, "aiforce": 8,
		"price": {"food": 70, "gold": 15, "iron": 10}, "build_time": 400 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 35},
		"weapons": [{"kind": "cannonball", "dmg": 60, "min": 60 * PX_TO_M, "max": 420 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 2, "coal": 3}, "splash": 50 * PX_TO_M},
			{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 1, 2, 100, 4, 10],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"musk18": {
		"hp": 105, "speed": 1.2, "score": 16, "aiforce": 6,
		"price": {"food": 80, "gold": 20, "iron": 12}, "build_time": 420 * 0.03125, "search": 950 * PX_TO_M,
		"eat": {"food": 32},
		"weapons": [{"kind": "bullet", "dmg": 16, "min": 400 * PX_TO_M, "max": 950 * PX_TO_M, "cd": 140 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0},
			{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 1, 2, 120, 3, 12],
		"radius": 0.35,
		"icon": Rect2(276, 92, 46, 46),
	},
	"howitzer": {
		"hp": 6000, "speed": 0.7, "score": 60, "aiforce": 2, "artillery": true, "shield": 75,  # donor unit.script:1738
		"price": {"wood": 300, "gold": 500, "iron": 500}, "build_time": 2600 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 350},
		# W2-2 data-truth note: donor lib/unit.script:1732-1763 defines only
		# weapon[0] cannonball for the howitzer. The cannister row below is a
		# PORT-ONLY extension (R04 GAP-2), not a donor-parity value; kept to
		# avoid a gameplay change, but do not cite it as donor-faithful.
		"weapons": [{"kind": "cannonball", "dmg": 1200, "min": 300 * PX_TO_M, "max": 1800 * PX_TO_M, "cd": 380 * 0.03125,
			"cost": {"iron": 25, "coal": 50}, "splash": 50 * PX_TO_M},
			{"kind": "cannister", "dmg": 250, "min": 0.0, "max": 150 * PX_TO_M, "cd": 300 * 0.03125,
			"cost": {"iron": 10, "coal": 20}, "splash": 55 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(184, 230, 46, 46),
	},
	"mortar": {
		"hp": 3500, "speed": 0.9, "score": 45, "aiforce": 2, "artillery": true, "shield": 25,  # donor unit.script:1768
		"price": {"wood": 200, "gold": 300, "iron": 300}, "build_time": 2000 * 0.03125, "search": 480 * PX_TO_M,
		"eat": {"gold": 250},
		"weapons": [{"kind": "cannonball", "dmg": 900, "min": 400 * PX_TO_M, "max": 2000 * PX_TO_M, "cd": 320 * 0.03125,
			"cost": {"iron": 15, "coal": 35}, "splash": 60 * PX_TO_M, "only_buildings": true}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.55,
		"icon": Rect2(230, 230, 46, 46),
	},
	# ---- nation-variety roster (Step 3; stats estimated unless wiki-sourced,
	# marked so in mechanics.json). Baked sheets in assets/models/anim.
	"musketeer": {
		"hp": 85, "speed": 1.2, "score": 12, "aiforce": 2, "no_melee": true,
		"price": {"food": 60, "gold": 11, "iron": 5}, "build_time": 352 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(276, 92, 46, 46),
	},
	"strelet": {
		"hp": 85, "speed": 1.2, "score": 12, "aiforce": 2, "no_melee": true,
		"price": {"food": 60, "gold": 11, "iron": 5}, "build_time": 352 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"pikeman18": {
		"hp": 120, "speed": 1.2, "score": 14, "aiforce": 12,
		"price": {"food": 40, "gold": 8, "iron": 30}, "build_time": 200 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "pike", "dmg": 10, "min": 35 * PX_TO_M, "max": 100 * PX_TO_M, "cd": 1.25}],
		"prot": [4, 3, 8, 210, 6, 40],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	"dragoon17": {
		"hp": 200, "speed": 2.1, "score": 35, "aiforce": 12, "cavalry": "hard",
		"price": {"food": 60, "gold": 40, "iron": 5}, "build_time": 600 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 45},
		"weapons": [{"kind": "bullet", "dmg": 15, "min": 400 * PX_TO_M, "max": 850 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 3, "coal": 4}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	"hussar": {
		"hp": 220, "speed": 3.6, "score": 32, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 110, "gold": 20}, "build_time": 400 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 15, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"wingedhussar": {
		"hp": 260, "speed": 3.6, "score": 45, "aiforce": 25, "cavalry": "fast",
		"price": {"food": 130, "gold": 30, "iron": 5}, "build_time": 480 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "pike", "dmg": 18, "min": 25 * PX_TO_M, "max": 75 * PX_TO_M, "cd": 1.0}],
		"prot": [1, 2, 5, 160, 10, 30],  # DONOR unit.script:1366
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"cuirassier": {
		"hp": 300, "speed": 2.1, "score": 48, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 120, "gold": 60, "iron": 20}, "build_time": 640 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "sword", "dmg": 20, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [2, 4, 10, 160, 5, 80],  # DONOR unit.script:1442
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"reiter": {
		"hp": 230, "speed": 2.1, "score": 38, "aiforce": 15, "cavalry": "hard",
		"price": {"food": 90, "gold": 50, "iron": 8}, "build_time": 560 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 50},
		"weapons": [{"kind": "bullet", "dmg": 14, "min": 350 * PX_TO_M, "max": 800 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 3, "coal": 4}, "splash": 0.0}],
		"prot": [2, 6, 6, 190, 15, 40],  # DONOR unit.script:1436 (reiter re-pin)
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	"lightcavalry": {
		"hp": 180, "speed": 3.6, "score": 28, "aiforce": 18, "cavalry": "fast",
		"price": {"food": 90, "gold": 10}, "build_time": 360 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 50},
		"weapons": [{"kind": "sword", "dmg": 12, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"lightinfantry": {
		"hp": 70, "speed": 1.32, "score": 10, "aiforce": 4, "no_melee": true,
		"price": {"food": 40, "gold": 5}, "build_time": 240 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 25},
		"weapons": [{"kind": "bullet", "dmg": 10, "min": 300 * PX_TO_M, "max": 750 * PX_TO_M, "cd": 130 * 0.03125,
			"cost": {"iron": 2, "coal": 4}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	"tatar": {
		"hp": 170, "speed": 3.6, "score": 30, "aiforce": 18, "cavalry": "fast", "no_melee": true,
		"price": {"food": 80, "wood": 10}, "build_time": 360 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 50},
		"weapons": [{"kind": "arrow", "dmg": 12, "min": 350 * PX_TO_M, "max": 750 * PX_TO_M, "cd": 75 * 0.03125,
			"cost": {"wood": 1}, "splash": 20 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"sipahi": {
		"hp": 260, "speed": 2.1, "score": 42, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 110, "gold": 40, "iron": 10}, "build_time": 520 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 18, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [3, 7, 4, 225, 24, 60],  # DONOR unit.script:1537
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"jannisary": {
		"hp": 95, "speed": 1.2, "score": 15, "aiforce": 6, "no_melee": true,
		"price": {"food": 65, "gold": 15, "iron": 6}, "build_time": 380 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 14, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 135 * 0.03125,
			"cost": {"iron": 3, "coal": 6}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	"spakh": {
		"hp": 240, "speed": 2.1, "score": 38, "aiforce": 20, "cavalry": "hard",
		"price": {"food": 100, "gold": 30, "iron": 8}, "build_time": 480 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 1, 0, 10, 2, 0],  # DONOR unit.script:1510
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"mameluke": {
		"hp": 250, "speed": 2.1, "score": 40, "aiforce": 20, "cavalry": "hard",
		"price": {"food": 105, "gold": 35, "iron": 8}, "build_time": 500 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 17, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [1, 3, 1, 75, 8, 0],  # DONOR unit.script:1519
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"vityaz": {
		"hp": 280, "speed": 2.1, "score": 44, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 115, "gold": 50, "iron": 15}, "build_time": 560 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 58},
		"weapons": [{"kind": "sword", "dmg": 19, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [2, 4, 3, 160, 17, 40],  # DONOR unit.script:1493
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"hetman": {
		"hp": 260, "speed": 3.6, "score": 42, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 120, "gold": 60, "iron": 20}, "build_time": 500 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 1, 3, 75, 3, 15],  # DONOR unit.script:1474
		"radius": 0.5,
		"icon": Rect2(0, 184, 46, 46),
	},
	"croat": {
		"hp": 75, "speed": 1.32, "score": 9, "aiforce": 5,
		"price": {"food": 30, "gold": 3}, "build_time": 160 * 0.03125, "search": 650 * PX_TO_M,
		"eat": {"food": 28},
		"weapons": [{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 1, 50, 1, 10],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"pandur": {
		"hp": 80, "speed": 1.32, "score": 10, "aiforce": 5,
		"price": {"food": 35, "gold": 5}, "build_time": 180 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 28},
		"weapons": [{"kind": "sword", "dmg": 8, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 1, 50, 1, 10],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"chasseur": {
		"hp": 90, "speed": 1.32, "score": 13, "aiforce": 6, "no_melee": true,
		"price": {"food": 55, "gold": 12, "iron": 6}, "build_time": 320 * 0.03125, "search": 900 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 13, "min": 400 * PX_TO_M, "max": 900 * PX_TO_M, "cd": 135 * 0.03125,
			"cost": {"iron": 3, "coal": 5}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	"highlander": {
		"hp": 95, "speed": 1.2, "score": 12, "aiforce": 8,
		"price": {"food": 45, "gold": 5, "iron": 10}, "build_time": 220 * 0.03125, "search": 650 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "sword", "dmg": 10, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 1, 2, 60, 2, 15],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	"pope": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	"padre": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	"mullah": {
		"hp": 50, "speed": 1.1, "score": 8, "aiforce": 2, "support": true, "healer": true,
		"price": {"food": 40, "gold": 50}, "build_time": 240 * 0.03125, "search": 400 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(92, 184, 46, 46),
	},
	"drummer18": {
		"hp": 70, "speed": 1.32, "score": 9, "aiforce": 3, "support": true,
		"price": {"food": 35, "gold": 25}, "build_time": 220 * 0.03125, "search": 6000 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(46, 184, 46, 46),
	},
	"multicannon": {
		"hp": 7000, "speed": 0.7, "score": 55, "aiforce": 2, "artillery": true, "shield": 60,
		"price": {"wood": 350, "gold": 450, "iron": 450}, "build_time": 2500 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 320},
		"weapons": [{"kind": "cannister", "dmg": 300, "min": 60 * PX_TO_M, "max": 500 * PX_TO_M, "cd": 300 * 0.03125,
			"cost": {"iron": 15, "coal": 30}, "splash": 60 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(138, 230, 46, 46),
	},
	# Baked sprite keys from RA G08 that had no sim row. cossackdon/hackapell
	# were already named by NATION_UNITS, so without these rows those mappings
	# silently failed callers that check UNITS.has() (e.g. the AI army picker).
	"cossackdon": {
		"hp": 220, "speed": 3.6, "score": 32, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 110, "gold": 25}, "build_time": 400 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 15, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"hackapell": {
		"hp": 210, "speed": 3.6, "score": 34, "aiforce": 20, "cavalry": "fast",
		"price": {"food": 110, "gold": 30}, "build_time": 400 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 55},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"sco_highlandersword": {
		# Scottish unique infantry (donor swordsmansco). Sprites/metrics come
		# from sco_units.json; stats estimated against strelet/pikeman18 until
		# a donor unit-stat read exists (quality-first: UNVERIFIED).
		"hp": 100, "speed": 1.2, "score": 14, "aiforce": 6,
		"price": {"food": 60, "gold": 12, "iron": 8}, "build_time": 380 * 0.03125,
		"search": 700 * PX_TO_M, "eat": {"food": 32},
		"weapons": [{"kind": "sword", "dmg": 16, "min": 10 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.1}],
		"prot": [2, 2, 4, 100, 3, 20],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	"cossackregister": {
		"hp": 240, "speed": 2.1, "score": 38, "aiforce": 22, "cavalry": "hard",
		"price": {"food": 120, "gold": 35, "iron": 5}, "build_time": 480 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "sword", "dmg": 17, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [2, 2, 4, 100, 3, 20],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	"bagpiper": {
		"hp": 60, "speed": 1.32, "score": 9, "aiforce": 3, "support": true,
		"price": {"food": 30, "gold": 25}, "build_time": 200 * 0.03125, "search": 6000 * PX_TO_M,
		"eat": {"food": 20},
		"weapons": [],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(46, 184, 46, 46),
	},
	# --- W2-2 data truth: the 8 Scottish donor-unique combat units
	# (R08 claim 2 / G-RO2). R08 §2 said "7" because it counted the pre-existing
	# sco_highlandersword as the stand-in for swordsmansco; the literal donor
	# sid swordsmansco is added here too (units.txt:1248-1252), so all 8 donor
	# combat sids now exist. Names/nation mapping: locale/en/units.txt:1237-1284
	# and lib/country.script:942,1039,1143,1266,1573,1936,2031,2820. HP / price /
	# protection / weapon damage+ranges are transcribed from the donor stat
	# blocks cited per row (ranges are donor px * PX_TO_M as everywhere here).
	# build_time, speed, score and icon follow the nearest port generic unit and
	# are ESTIMATED: donor build times/speeds are not read for these sids.
	# No NATION_UNITS or train-list wiring is done here (that would change AI
	# army picks / existing seed traces); no sprite keys are added (W2-10 owns
	# assets). These rows are data-only and unreachable in current skirmish play.
	# Covenanter pikeman - donor lib/unit.script:630-636 (shared pikeman block).
	"pikemansco": {
		"hp": 90, "speed": 1.2, "score": 10, "aiforce": 10,
		"price": {"food": 25, "gold": 3, "iron": 20}, "build_time": 144 * 0.03125, "search": 700 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "pike", "dmg": 8, "min": 35 * PX_TO_M, "max": 100 * PX_TO_M, "cd": 1.25}],
		"prot": [3, 2, 4, 210, 6, 40],
		"radius": 0.35,
		"icon": Rect2(0, 46, 46, 46),
	},
	# Sword Clansman - donor lib/unit.script:735-754, sco override at 746-753.
	"swordsmansco": {
		"hp": 180, "speed": 1.1, "score": 18, "aiforce": 5,
		"price": {"food": 110, "wood": 5, "gold": 10}, "build_time": 128 * 0.03125, "search": 800 * PX_TO_M,
		"eat": {"food": 45},
		"weapons": [{"kind": "sword", "dmg": 10, "min": 25 * PX_TO_M, "max": 60 * PX_TO_M, "cd": 1.25}],
		"prot": [1, 2, 2, 110, 6, 10],
		"radius": 0.35,
		"icon": Rect2(184, 46, 46, 46),
	},
	# Covenanter musketeer - donor lib/unit.script:771-787 + 852-859.
	"musketeersco": {
		"hp": 90, "speed": 1.2, "score": 12, "aiforce": 15, "no_melee": true,
		"price": {"food": 55, "gold": 8, "iron": 7}, "build_time": 352 * 0.03125, "search": 850 * PX_TO_M,
		"eat": {"food": 30},
		"weapons": [{"kind": "bullet", "dmg": 12, "min": 350 * PX_TO_M, "max": 850 * PX_TO_M, "cd": 150 * 0.03125,
			"cost": {"iron": 2, "coal": 5}, "splash": 0.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(230, 92, 46, 46),
	},
	# Bow Clansman - donor lib/unit.script:997-1039, sco override at 1029-1038.
	# Donor weapon[1] is firearrow (unit.script:1005,1034); the port has no
	# firearrow weapon and PROT_SLOT clamps that kind, so it is NOT added here
	# (adding it would introduce a new live weapon kind into the sim).
	"archersco": {
		"hp": 150, "speed": 1.2, "score": 15, "aiforce": 2, "no_melee": true,
		"price": {"food": 80, "wood": 5, "gold": 7}, "build_time": 48 * 0.03125, "search": 1000 * PX_TO_M,
		"eat": {"food": 40},
		"weapons": [{"kind": "arrow", "dmg": 20, "min": 250 * PX_TO_M, "max": 1000 * PX_TO_M, "cd": 100 * 0.03125,
			"cost": {"wood": 2}, "splash": 20 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.35,
		"icon": Rect2(322, 92, 46, 46),
	},
	# Officer - donor lib/unit.script:1062-1074 (shared officer block).
	"officersco": {
		"hp": 125, "speed": 1.2, "score": 10, "aiforce": 5,
		"price": {"food": 50, "gold": 150, "iron": 30}, "build_time": 320 * 0.03125, "search": 500 * PX_TO_M,
		"eat": {"gold": 60},
		"weapons": [{"kind": "pike", "dmg": 30, "min": 35 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.25}],
		"prot": [2, 2, 5, 200, 10, 30],
		"radius": 0.35,
		"icon": Rect2(0, 184, 46, 46),
	},
	# Lancer - donor lib/unit.script:1418-1430 + 1524-1531.
	"lancersco": {
		"hp": 320, "speed": 2.1, "score": 38, "aiforce": 10, "cavalry": "hard",
		"price": {"food": 120, "gold": 6}, "build_time": 720 * 0.03125, "search": 600 * PX_TO_M,
		"eat": {"food": 60},
		"weapons": [{"kind": "pike", "dmg": 11, "min": 30 * PX_TO_M, "max": 100 * PX_TO_M, "cd": 1.25}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(0, 368, 46, 46),
	},
	# Raider - donor lib/unit.script:1320-1329 + 1392-1398.
	"raidersco": {
		"hp": 280, "speed": 3.6, "score": 35, "aiforce": 25, "cavalry": "fast",
		"price": {"food": 130, "gold": 8, "iron": 2}, "build_time": 432 * 0.03125, "search": 1000 * PX_TO_M,
		"eat": {"food": 75},
		"weapons": [{"kind": "sword", "dmg": 11, "min": 20 * PX_TO_M, "max": 65 * PX_TO_M, "cd": 1.0}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.5,
		"icon": Rect2(92, 276, 46, 46),
	},
	# Frame gun - donor lib/unit.script:1823-1840.
	"framegun": {
		"hp": 3000, "speed": 0.75, "score": 50, "aiforce": 2, "artillery": true, "shield": 50,
		"price": {"wood": 200, "gold": 300, "iron": 150}, "build_time": 2400 * 0.03125, "search": 1200 * PX_TO_M,
		"eat": {"gold": 300},
		"weapons": [{"kind": "cannonball", "dmg": 500, "min": 200 * PX_TO_M, "max": 1800 * PX_TO_M, "cd": 90 * 0.03125,
			"cost": {"iron": 30, "coal": 40}, "splash": 32 * PX_TO_M}],
		"prot": [0, 0, 0, 0, 0, 0],
		"radius": 0.6,
		"icon": Rect2(138, 230, 46, 46),
	},
	# P-10 naval: static hull + crew sheets baked in app/assets/models/anim/naval_units/
	# (index.json: hull ortho 11.355, crew ortho 6.047). Movement/shape flags are
	# donor-evidenced; hp/speed/dmg/price are ESTIMATED (NAVAL_PORT_PLAN §5 Q2).
	"yacht": {
		"hp": 900, "speed": 2.8, "score": 60, "aiforce": 12, "naval": true,
		"price": {"wood": 220, "gold": 120, "iron": 60}, "build_time": 1600 * 0.03125, "search": 1200 * PX_TO_M,
		"eat": {"gold": 40},
		"weapons": [{"kind": "cannonball", "dmg": 220, "min": 400 * PX_TO_M, "max": 1200 * PX_TO_M,
			"cd": 180 * 0.03125, "cost": {"iron": 2, "coal": 3}, "splash": 12 * PX_TO_M}],
		"prot": [2, 2, 4, 60, 6, 45],
		"radius": 1.8,
		"icon": Rect2(322, 368, 46, 46),
	},
	# --- G-N1 W2-10 hand-off (reports/W210_naval_assets.md §3): six staged ship
	# sids whose hull PNGs/index keys are already baked. Donor-exact hp / price /
	# eat / weapon damage+range+per-shot cost from lib/unit.script lines cited
	# in that report. PORT ESTIMATES (flagged, NOT donor-verbatim): speed, score,
	# aiforce, prot, radius, icon, all pause->cd conversions, all build_time and
	# search values. Archetype: galley weapon[1] is donor mortarball (no port
	# kind), stored here as a long-range cannonball; battleship/xebec damage is
	# derived from the shared 1800 block (donor says `default`).
	# OPEN: these hp values are donor-exact (30000-90000) while the existing
	# yacht hp above stays at the old declared estimate 900 (~34x mismatch).
	# Rescaling all seven is a coordinator decision; NOT done here to avoid
	# changing existing yacht combat behaviour / seed traces.
	# xebec eat.gold 0 is donor-exact; game.gd's gold-firing gate keys on the
	# presence of "gold", so W2-1 must arbitrate that interaction.
	"fishboat": {
		"hp": 300, "speed": 2.4, "score": 50, "aiforce": 4, "naval": true,
		"price": {"wood": 600}, "build_time": 1280 * 0.03125, "search": 1280 * PX_TO_M,
		"weapons": [],
		"prot": [1, 1, 2, 30, 3, 20],
		"radius": 1.0,
		"icon": Rect2(322, 368, 46, 46),
	},
	"yachttur": {
		"hp": 35000, "speed": 2.6, "score": 200, "aiforce": 14, "naval": true,
		"price": {"wood": 900, "gold": 450, "iron": 150, "coal": 200},
		"build_time": 1536 * 0.03125, "search": 1050 * PX_TO_M,
		"eat": {"gold": 1500},
		"weapons": [{"kind": "cannonball", "dmg": 30, "min": 300 * PX_TO_M, "max": 1000 * PX_TO_M,
			"cd": 400 * 0.03125, "cost": {"iron": 5, "coal": 15}, "splash": 32 * PX_TO_M}],
		"prot": [2, 2, 4, 60, 6, 45],
		"radius": 1.8,
		"icon": Rect2(322, 368, 46, 46),
	},
	"galley": {
		"hp": 35000, "speed": 2.5, "score": 200, "aiforce": 14, "naval": true,
		"price": {"wood": 9500, "gold": 900, "iron": 800},
		"build_time": 1600 * 0.03125, "search": 1100 * PX_TO_M,
		"eat": {"gold": 1000},
		"weapons": [
			{"kind": "cannonball", "dmg": 100, "min": 300 * PX_TO_M, "max": 1200 * PX_TO_M,
				"cd": 150 * 0.03125, "cost": {"iron": 4, "coal": 9}, "splash": 32 * PX_TO_M},
			{"kind": "cannonball", "dmg": 1000, "min": 1100 * PX_TO_M, "max": 3100 * PX_TO_M,
				"cd": 50 * 0.03125, "cost": {"iron": 4, "coal": 9}, "splash": 32 * PX_TO_M}
		],
		"prot": [2, 2, 4, 60, 6, 45],
		"radius": 1.8,
		"icon": Rect2(322, 368, 46, 46),
	},
	"frigate": {
		"hp": 50000, "speed": 2.7, "score": 300, "aiforce": 20, "naval": true,
		"price": {"wood": 5000, "gold": 1100, "iron": 600, "coal": 800},
		"build_time": 7360 * 0.03125, "search": 1800 * PX_TO_M,
		"eat": {"gold": 150},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 400 * PX_TO_M, "max": 1650 * PX_TO_M,
			"cd": 75 * 0.03125, "cost": {"iron": 25, "coal": 35}, "splash": 32 * PX_TO_M}],
		"prot": [3, 3, 6, 80, 8, 60],
		"radius": 2.2,
		"icon": Rect2(322, 368, 46, 46),
	},
	"xebec": {
		"hp": 65000, "speed": 2.9, "score": 300, "aiforce": 20, "naval": true,
		"price": {"wood": 7000, "gold": 1600, "iron": 320, "coal": 960},
		"build_time": 7360 * 0.03125, "search": 1800 * PX_TO_M,
		"eat": {"gold": 0},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 550 * PX_TO_M, "max": 1700 * PX_TO_M,
			"cd": 50 * 0.03125, "cost": {"iron": 25, "coal": 35}, "splash": 32 * PX_TO_M}],
		"prot": [3, 3, 6, 80, 8, 60],
		"radius": 2.2,
		"icon": Rect2(322, 368, 46, 46),
	},
	"battleship": {
		"hp": 90000, "speed": 2.2, "score": 500, "aiforce": 32, "naval": true,
		"price": {"wood": 9000, "gold": 3200, "iron": 700, "coal": 6500},
		"build_time": 12480 * 0.03125, "search": 1680 * PX_TO_M,
		"eat": {"gold": 15000},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 600 * PX_TO_M, "max": 1950 * PX_TO_M,
			"cd": 20 * 0.03125, "cost": {"iron": 5, "coal": 15}, "splash": 32 * PX_TO_M}],
		"prot": [4, 4, 8, 100, 10, 80],
		"radius": 2.6,
		"icon": Rect2(322, 368, 46, 46),
	},
}

# buildings: hp, build_time s, cost, radius (footprint, estimated), trains, stores, farm, score
const BUILDINGS_BASE := {
	"cen": {"hp": 5300, "build_time": 500 * 0.03125, "cost": {"wood": 700}, "radius": 3.0, "farm": 100,
		"stores": ["food", "wood", "stone"], "trains": ["peasant"], "score": 1000, "capture": true, "drop": true,
		"icon": Rect2(92, 92, 46, 46)},
	"hou": {"hp": 4150, "build_time": 100 * 0.03125, "cost": {"wood": 120}, "radius": 1.5, "farm": 25,
		"score": 100, "icon": Rect2(0, 0, 46, 46)},
	"bar": {"hp": 20000, "build_time": 300 * 0.03125, "cost": {"wood": 150, "stone": 150}, "radius": 2.5, "farm": 150,
		"trains": ["pikeman", "roundshier", "serdiuk", "archer", "officer", "drummer", "priest"], "score": 500,
		"icon": Rect2(46, 46, 46, 46)},
	"bar18": {"hp": 20000, "build_time": 400 * 0.03125, "cost": {"wood": 300, "stone": 300}, "radius": 2.5, "farm": 250,
		"trains": ["musk18", "grenadier", "pikeman18", "officer18", "drummer18"], "score": 500,
		"icon": Rect2(46, 46, 46, 46)},
	"dip": {"hp": 8000, "build_time": 400 * 0.03125, "cost": {"wood": 400, "gold": 200}, "radius": 2.5,
		"trains": ["roundshier", "dragoon17", "reiter"], "score": 300,
		"icon": Rect2(0, 46, 46, 46)},
	"sta": {"hp": 10000, "build_time": 500 * 0.03125, "cost": {"wood": 3200, "stone": 850, "gold": 850}, "radius": 2.5,
		"trains": ["cossack", "dragoon"], "score": 500, "icon": Rect2(138, 46, 46, 46)},
	"bla": {"hp": 4500, "build_time": 200 * 0.03125, "cost": {"wood": 100, "stone": 30, "iron": 640}, "radius": 2.0,
		"score": 500, "icon": Rect2(92, 46, 46, 46)},
	"aca": {"hp": 65000, "build_time": 150 * 0.03125, "cost": {"wood": 1350, "stone": 1200}, "radius": 2.5,
		"score": 500, "icon": Rect2(230, 46, 46, 46)},
	# G-01: the capturable set (town hall, market, mines, storehouse) is
	# wiki-sourced (RB_MECHANICS S3/S5/S6/S7), not donor-byte verified - INFERENCE.
	# Military buildings below deliberately stay uncapturable.
	"sto": {"hp": 10000, "build_time": 100 * 0.03125, "cost": {"wood": 50, "stone": 20}, "radius": 1.5,
		"stores": ["wood", "stone"], "score": 30, "drop": true, "capture": true, "icon": Rect2(92, 0, 46, 46)},
	"mil": {"hp": 20000, "build_time": 300 * 0.03125, "cost": {"wood": 30, "stone": 150}, "radius": 2.0,
		"stores": ["food"], "score": 20, "drop": true, "icon": Rect2(46, 0, 46, 46)},
	"mar": {"hp": 4000, "build_time": 750 * 0.03125, "cost": {"wood": 450}, "radius": 2.0, "score": 500,
		"capture": true, "icon": Rect2(0, 46, 46, 46)},
	"art": {"hp": 40000, "build_time": 787 * 0.03125, "cost": {"wood": 100, "stone": 1000, "coal": 1400}, "radius": 2.5,
		"trains": ["cannon", "howitzer", "mortar", "multicannon"], "score": 500, "icon": Rect2(184, 46, 46, 46)},
	# Stone wall segment (data/game/var/wallcustom.cfg BuilderPoints ±0.9 m).
	# Cheap, chainable, no upkeep; estimated hp/cost, marked so in mechanics.
	"wal": {"hp": 3000, "build_time": 60 * 0.03125, "cost": {"wood": 10, "stone": 20}, "radius": 1.0,
		"eat": {"stone": 40}, "score": 20, "wall": true, "icon": Rect2(414, 0, 46, 46)},
	"gat": {"hp": 3000, "build_time": 60 * 0.03125, "cost": {"wood": 10, "stone": 60}, "radius": 1.0,
		"score": 20, "wall": true, "gate": true, "icon": Rect2(414, 0, 46, 46)},
	"mine_gold": {"hp": 2500, "build_time": 300 * 0.03125, "cost": {"wood": 100, "stone": 100}, "radius": 1.6,
		"mine": "gold", "slots": 5, "produce": 13, "score": 500, "capture": true, "icon": Rect2(138, 0, 46, 46)},
	"mine_iron": {"hp": 2500, "build_time": 300 * 0.03125, "cost": {"wood": 100, "stone": 100}, "radius": 1.6,
		"mine": "iron", "slots": 5, "produce": 13, "score": 500, "capture": true, "icon": Rect2(138, 0, 46, 46)},
	"mine_coal": {"hp": 2500, "build_time": 300 * 0.03125, "cost": {"wood": 100, "stone": 100}, "radius": 1.6,
		"mine": "coal", "slots": 5, "produce": 13, "score": 500, "capture": true, "icon": Rect2(138, 0, 46, 46)},
	"tow": {"hp": 20000, "build_time": 3937 * 0.03125, "cost": {"wood": 100, "stone": 100, "gold": 150}, "radius": 1.6,
		"weapons": [{"kind": "cannonball", "dmg": 1000, "min": 550 * PX_TO_M, "max": 1500 * PX_TO_M, "cd": 400 * 0.03125,
			"cost": {"iron": 10, "coal": 30}, "splash": 35 * PX_TO_M}],
		"eat": {"gold": 500}, "score": 500, "icon": Rect2(414, 0, 46, 46)},
	# P-10: donor Shipyard (hotkey P) has no readable stats; hp/cost are
	# ESTIMATED. train_unit() gates strictly on `trains`, so this is the only
	# training hook needed for the seven ship sids (W2-10 hand-off). AI never
	# builds docks (ai.gd has no dock/naval reference), so extending this list
	# cannot change AI army picks or existing seed traces.
	"dock": {"hp": 12000, "build_time": 900 * 0.03125, "cost": {"wood": 600, "stone": 200, "gold": 150}, "radius": 3.0,
		"trains": ["fishboat", "yacht", "yachttur", "galley", "frigate", "xebec", "battleship"], "score": 500, "icon": Rect2(414, 46, 46, 46)},
}

# Upgrades researched at blacksmith (bla) and academy (aca).
# Video pass: every battle video shows the bread/iron/steel upgrade path and
# the 18th-century transition; costs/effects estimated, marked so in mechanics.
const UPGRADES_BASE := {
	"bla_sword1": {"building": "bla", "cost": {"wood": 100, "food": 200}, "time": 8.0,
		"effect": {"damage_mult": {"sword": 1.15, "pike": 1.15}}, "name": "Sharpened blades +15%"},
	"bla_armor1": {"building": "bla", "cost": {"wood": 100, "iron": 100}, "time": 8.0,
		"effect": {"prot_bonus": 2}, "name": "Forged armor +2"},
	"bla_bullet1": {"building": "bla", "cost": {"gold": 200, "iron": 200}, "time": 12.0,
		"effect": {"damage_mult": {"bullet": 1.2, "cannonball": 1.1}}, "name": "Improved powder +20%"},
	"aca_bread1": {"building": "aca", "cost": {"food": 300, "gold": 100}, "time": 10.0,
		"effect": {"gather_mult": {"food": 1.25}}, "name": "Crop rotation +25% food"},
	"aca_wood1": {"building": "aca", "cost": {"food": 200, "wood": 200}, "time": 10.0,
		"effect": {"gather_mult": {"wood": 1.2}}, "name": "Sawmills +20% wood"},
	"cen_18c": {"building": "cen", "cost": {"food": 800, "gold": 600}, "time": 20.0,
		"effect": {"unlock18c": true}, "name": "18th century"},
	"sta_horse1": {"building": "sta", "cost": {"food": 400, "gold": 200}, "time": 12.0,
		"effect": {"damage_mult": {"sword": 1.1}}, "name": "Bred horses +10% cavalry"},
	"art_caliber1": {"building": "art", "cost": {"gold": 300, "iron": 300}, "time": 14.0,
		"effect": {"damage_mult": {"cannonball": 1.15}}, "name": "Heavy caliber +15%"},
	"mil_food1": {"building": "mil", "cost": {"food": 750, "gold": 250}, "time": 10.0,
		"effect": {"gather_mult": {"food": 2.4}}, "name": "Grain treatment +140%"},
	# Donor locale/en/upgrades.txt:144 = "storage +180" -> multiplier 2.8,
	# not the previous estimated +250% (deep-MICRO §2.2).
	"mil_food2": {"building": "mil", "cost": {"food": 25600, "gold": 3350, "iron": 2000}, "time": 20.0,
		"effect": {"gather_mult": {"food": 2.8}}, "name": "Grain storage +180%"},
	"aca_field1": {"building": "aca", "cost": {"food": 2000, "gold": 500}, "time": 12.0,
		"effect": {"field_cap": 3.0}, "name": "Field melioration +200%"},
	"bla_field1": {"building": "bla", "cost": {"food": 1000, "iron": 200}, "time": 10.0,
		"effect": {"field_cap": 2.0}, "name": "Agricultural equipment +100%"},
	"aca_wheat1": {"building": "aca", "cost": {"food": 1500, "gold": 300}, "time": 10.0,
		"effect": {"gather_mult": {"food": 1.4}}, "name": "New wheat +40%"},
	# Donor locale/en/upgrades.txt:4 = "rye +50" -> multiplier 1.5,
	# not the previous estimated +40% (deep-MICRO §2.2).
	"aca_rye1": {"building": "aca", "cost": {"food": 2500, "gold": 500}, "time": 12.0,
		"effect": {"gather_mult": {"food": 1.5}}, "name": "New rye +50%"},
	# Donor locale/en/upgrades.txt:5-6 = "agriculturists' salary +50%" -> multiplier 1.5
	# (aca.3); cost estimated, donor locale gives the effect only.
	"aca_agronom1": {"building": "aca", "cost": {"food": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"food": 1.5}}, "name": "Agriculturists' salary +50%"},
	"aca_wood1b": {"building": "aca", "cost": {"wood": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"wood": 2.0}}, "name": "Woodworking tools +100%"},
	"aca_stone1": {"building": "aca", "cost": {"stone": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"stone": 2.0}}, "name": "Stone excavation +100%"},
	"aca_build1": {"building": "aca", "cost": {"wood": 1500, "stone": 1000}, "time": 12.0,
		"effect": {"build_mult": 0.25}, "name": "Builders' salary (build time -75%)"},
	"aca_hp1": {"building": "aca", "cost": {"wood": 2000, "stone": 1500}, "time": 14.0,
		"effect": {"bld_hp_add": 85}, "name": "New construction materials +85 hp"},
	"aca_fort1": {"building": "aca", "cost": {"stone": 2500, "gold": 600}, "time": 14.0,
		"effect": {"fort_hp_add": 80}, "name": "Fortification grades +80 hp"},
	"aca_geo1": {"building": "aca", "cost": {"gold": 800, "food": 500}, "time": 10.0,
		"effect": {"reveal_deposits": true}, "name": "Geology (reveal deposits)"},
	"aca_balloon1": {"building": "aca", "cost": {"gold": 2000, "food": 1000}, "time": 16.0,
		"effect": {"reveal_map": true}, "name": "Montgolfier (reveal map)"},
	"art_range1": {"building": "art", "cost": {"gold": 600, "iron": 300}, "time": 12.0,
		"effect": {"art_range": 1.05}, "name": "Artillery range +5%"},
	# W2-2 data truth: donor aca.27 "Develop mathematics" is
	# gc_upg_type_attdispertionperc = -35 (lib/country.script:3629) = artillery
	# accuracy +35% (locale/en/upgrades.txt:58). The +10% range this row used to
	# carry is donor aca.17 "unicorn, carronade" (country.script:3575,
	# upgrades.txt:38) and is preserved under its own row below. The key
	# "art_range2" is retained deliberately so no called symbol is renamed.
	"art_range2": {"building": "art", "cost": {"gold": 1200, "iron": 600}, "time": 14.0,
		"effect": {"art_acc": 0.65}, "name": "Mathematics (accuracy +35%)"},
	"aca_range2": {"building": "art", "cost": {"gold": 1200, "iron": 600}, "time": 14.0,
		"effect": {"art_range": 1.1}, "name": "Unicorn & carronade barrels (range +10%)"},
	"art_hp1": {"building": "art", "cost": {"gold": 1500, "iron": 800}, "time": 14.0,
		"effect": {"art_hp": 2.5}, "name": "Gribovalle system (arty hp +150%)"},
	"art_acc1": {"building": "art", "cost": {"gold": 900, "iron": 400}, "time": 12.0,
		"effect": {"art_acc": 0.65}, "name": "Artillery accuracy +35%"},
	"art_multi1": {"building": "art", "cost": {"gold": 2000, "iron": 1000, "coal": 500}, "time": 18.0,
		"effect": {"unlock_multi": true}, "name": "Multi-barrelled cannon"},
	"tow_rof1": {"building": "tow", "cost": {"gold": 400, "iron": 200, "coal": 200}, "time": 10.0,
		"effect": {"tower_rof": 0.8}, "name": "More cannons +20% RoF"},
	"tow_rof2": {"building": "tow", "cost": {"gold": 800, "iron": 400, "coal": 400}, "time": 12.0,
		"effect": {"tower_rof": 0.8}, "name": "More cannons II +20% RoF"},
	"tow_rof3": {"building": "tow", "cost": {"gold": 1200, "iron": 600, "coal": 600}, "time": 14.0,
		"effect": {"tower_rof": 0.9}, "name": "More cannons III +10% RoF"},
	"mine_gold_up1": {"building": "mine_gold", "cost": {"wood": 200, "stone": 100}, "time": 10.0,
		"effect": {"mine_mult": 1.5}, "name": "Deep shafts +50% gold"},
	"mine_iron_up1": {"building": "mine_iron", "cost": {"wood": 200, "stone": 100}, "time": 10.0,
		"effect": {"mine_mult": 1.5}, "name": "Deep shafts +50% iron"},
	"mine_coal_up1": {"building": "mine_coal", "cost": {"wood": 200, "stone": 100}, "time": 10.0,
		"effect": {"mine_mult": 1.5}, "name": "Deep shafts +50% coal"},
	"mine_gold_up2": {"building": "mine_gold", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"mine_gold_up3": {"building": "mine_gold", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"mine_gold_up4": {"building": "mine_gold", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"mine_gold_up5": {"building": "mine_gold", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"mine_gold_up6": {"building": "mine_gold", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"mine_gold_up7": {"building": "mine_gold", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
	"mine_iron_up2": {"building": "mine_iron", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"mine_iron_up3": {"building": "mine_iron", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"mine_iron_up4": {"building": "mine_iron", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"mine_iron_up5": {"building": "mine_iron", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"mine_iron_up6": {"building": "mine_iron", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"mine_iron_up7": {"building": "mine_iron", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
	"mine_coal_up2": {"building": "mine_coal", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"mine_coal_up3": {"building": "mine_coal", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"mine_coal_up4": {"building": "mine_coal", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"mine_coal_up5": {"building": "mine_coal", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"mine_coal_up6": {"building": "mine_coal", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"mine_coal_up7": {"building": "mine_coal", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
	# --- Skirmish combat tree (RB G-02..G-06, G-08). Effects are applied in
	# game.gd apply_upgrade(); costs/times are estimated like the rows above.
	# W2-2 data truth: donor aca.12/13/14/15 = +10/+10/+15/+25% fire power
	# (locale/en/upgrades.txt:28,30,32,34; lib/country.script:3555,3557,3559,3561
	# gc_upg_type_damageperc 10,10,15,25). aca_fire1 was already +10% (untouched).
	"aca_fire1": {"building": "aca", "cost": {"gold": 300, "iron": 200}, "time": 10.0,
		"effect": {"damage_mult": {"bullet": 1.1, "cannonball": 1.1}}, "name": "Rifled barrels +10%"},
	"aca_fire2": {"building": "aca", "cost": {"gold": 600, "iron": 400}, "time": 11.0,
		"effect": {"damage_mult": {"bullet": 1.1, "cannonball": 1.1}}, "name": "Granular powder +10%"},
	"aca_fire3": {"building": "aca", "cost": {"gold": 1000, "iron": 700}, "time": 12.0,
		"effect": {"damage_mult": {"bullet": 1.15, "cannonball": 1.15}}, "name": "Purified sulphur +15%"},
	"aca_fire4": {"building": "aca", "cost": {"gold": 1600, "iron": 1100}, "time": 13.0,
		"effect": {"damage_mult": {"bullet": 1.25, "cannonball": 1.25}}, "name": "Saltpetre +25%"},
	# W2-2 data truth: donor aca.31/33 (lib/country.script:3664,3697) pass
	# gc_upg_type_attpauseperc = -30, and lib/player.script:1857 applies
	# pause := pause * (1 + value/100) = 0.70. Port rof_mult multiplies the
	# cooldown (game.gd:4855), so 0.70 is the exact donor script value.
	# Locale upgrades.txt:66,70 says "rate of fire +30%" (tooltip copy);
	# -30% pause is actually ~+42.9% RoF. The name follows the tooltip, the
	# effect follows the script (D-22: numeric params are authoritative).
	"aca_rof1": {"building": "aca", "cost": {"gold": 900, "iron": 500}, "time": 12.0,
		"effect": {"rof_mult": {"bullet": 0.7}}, "name": "Wheellock (+30% RoF)"},
	"aca_rof2": {"building": "aca", "cost": {"gold": 1400, "iron": 800}, "time": 13.0,
		"effect": {"rof_mult": {"bullet": 0.7}}, "name": "Paper cartridge (+30% RoF)"},
	"bla_flint1": {"building": "bla", "cost": {"gold": 500, "iron": 300}, "time": 10.0,
		"effect": {"cost_mult": 0.5}, "name": "Flintlock muskets (-50% shot cost)"},
	# W2-2 data truth: donor aca.35 (lib/country.script:3707) is
	# gc_upg_type_damage = 5 on pike, locale/en/upgrades.txt:74 "+5". The
	# "+7" came from the stale comment at dmscript.global:542; script wins.
	"bla_bayonet1": {"building": "bla", "cost": {"wood": 200, "iron": 250}, "time": 10.0,
		"effect": {"melee_add": 5}, "name": "Bayonets +5 melee"},
	"bla_steel1": {"building": "bla", "cost": {"iron": 600, "gold": 400}, "time": 12.0, "no18c": true,
		"effect": {"damage_mult": {"sword": 1.25, "pike": 1.25}}, "name": "Steel grades +25% melee"},
	"bla_harness1": {"building": "bla", "cost": {"food": 500, "gold": 300}, "time": 10.0,
		"effect": {"train_speed_mult": 0.5}, "name": "Harnesses (mounted recruit x2)"},
	"bla_sabre1": {"building": "bla", "cost": {"iron": 450, "gold": 350}, "time": 11.0,
		"effect": {"cav_dmg_add": 5}, "name": "Broadswords +5 cavalry attack"},
	"aca_riding1": {"building": "aca", "cost": {"food": 600, "gold": 400}, "time": 11.0,
		"effect": {"cav_prot_bonus": 2}, "name": "Riding drill +2 cavalry defence"},
	"sta_fence1": {"building": "sta", "cost": {"food": 400, "iron": 200}, "time": 10.0,
		"effect": {"damage_mult": {"sword": 1.15}}, "name": "Fencing drill +15% melee"},
	"sta_fire1": {"building": "sta", "cost": {"food": 400, "gold": 250}, "time": 10.0,
		"effect": {"damage_mult": {"bullet": 1.15}}, "name": "Firing practice +15% ranged"},
	"bar_phys1": {"building": "bar", "cost": {"food": 400, "gold": 200}, "time": 10.0,
		"effect": {"prot_bonus": 2}, "name": "Physical training +2 defence"},
	"bar_music1": {"building": "bar", "cost": {"food": 300, "gold": 250}, "time": 10.0,
		"effect": {"prot_bonus": 2}, "name": "Musician drill +2 defence"},
	"bar_grenade1": {"building": "bar", "cost": {"iron": 400, "gold": 300}, "time": 11.0,
		"effect": {"damage_mult": {"cannister": 1.25}}, "name": "New grenades +25%"},
	"aca_med1": {"building": "aca", "cost": {"food": 1200, "gold": 900}, "time": 14.0,
		"effect": {"heal_all": true}, "name": "Medical science (heal all)"},
	"art_foundry1": {"building": "art", "cost": {"gold": 800, "iron": 600}, "time": 12.0,
		"effect": {"art_cost_mult": 0.8}, "name": "Foundry mechanization -20% cost"},
	"art_metal1": {"building": "art", "cost": {"gold": 1000, "iron": 900}, "time": 13.0,
		"effect": {"art_build_mult": 0.6}, "name": "Metalworking +40% build speed"},
	"art_repair1": {"building": "art", "cost": {"gold": 700, "iron": 500}, "time": 12.0,
		"effect": {"repair_arty": true}, "name": "Artillery repair shops"},
	# --- W2-2 data truth: naval upgrades (R08 claim 17). Donor values ARE
	# readable (locale/en/upgrades.txt:10,12,18,60,62,64,165-166;
	# lib/country.script:3495,3503,3512-3513,3639,3650,3655,3993), but the port
	# naval sim has no handlers for them yet. Every effect key below is
	# deliberately INERT - none is in game.gd apply_upgrade's handled-key list -
	# so these are data-only records, not live buffs. Costs/times are estimated
	# like the rest of this table. R9 must add handlers before these are live.
	"aca_boat_eff1": {"building": "dock", "cost": {"wood": 300, "gold": 200}, "time": 12.0,
		"effect": {"naval_fishing_mult": 2.0}, "name": "New tackle & fishing nets (boat efficiency +100%)"},
	"aca_frigate1": {"building": "dock", "cost": {"wood": 800, "gold": 500}, "time": 14.0,
		"effect": {"naval_unlock": "frigate"}, "name": "New woodworking methods (frigate building)"},
	"aca_fishboat_cost1": {"building": "dock", "cost": {"wood": 200, "gold": 300}, "time": 12.0,
		"effect": {"naval_unit_cost_mult": {"fishboat": 0.15}}, "name": "New fishing boat shipyards (cost -85%)"},
	"aca_ship_speed1": {"building": "dock", "cost": {"wood": 700, "gold": 900}, "time": 14.0,
		"effect": {"naval_speed_mult": 1.4}, "name": "New rigging types (ship speed +40%)"},
	"aca_battleship1": {"building": "dock", "cost": {"wood": 1200, "gold": 1500, "iron": 800}, "time": 18.0,
		"effect": {"naval_unlock": "battleship"}, "name": "New ribs & hulls (battleship construction)"},
	# Donor-internal conflict: country.script:3655 buildtimeperc -5000000 =
	# -50% build time (cf. aca.10 -7500000 = -75%, country.script:3530), but
	# upgrades.txt:64 says "shipbuilding speed x10". Stored as the locale x10
	# flag; unresolved and inert either way.
	"aca_shipbuild1": {"building": "dock", "cost": {"wood": 900, "gold": 1200}, "time": 16.0,
		"effect": {"naval_build_mult": 0.1}, "name": "Train carpenters (shipbuilding x10)"},
	"por_repair1": {"building": "dock", "cost": {"wood": 400, "gold": 500}, "time": 12.0,
		"effect": {"naval_repair_all": true}, "name": "Train woodworkers (repair all ships)"},
}

# The live tables. They start as a copy of the original numbers and are then
# changed by the global settings file (config.json) when the game starts.
static var UNITS := {}
static var BUILDINGS := {}
static var UPGRADES := {}

# The tables are built once, when the script is loaded, so that the settings
# file can change them without them being read-only.
static func _static_init() -> void:
	UNITS = copy_value(UNITS_BASE)
	BUILDINGS = copy_value(BUILDINGS_BASE)
	UPGRADES = copy_value(UPGRADES_BASE)
	GATHER = copy_value(GATHER_BASE)
	START_RESOURCES = {"food": 0.0, "wood": 0.0, "stone": 0.0, "gold": 0.0, "iron": 0.0, "coal": 0.0}
	DEPOSITS = {"gold": 40000.0, "iron": 30000.0, "coal": 30000.0}
	BATTLE_ARMY = {"pikeman": 16, "serdiuk": 12, "archer": 8, "cossack": 8, "officer": 1, "cannon": 2}

# nation train-list resolution: generic sid -> nation's own unit (or sid)
static func resolve_sid(nat: String, sid: String) -> String:
	var m: Dictionary = NATION_UNITS.get(nat, {})
	var r: String = str(m.get(sid, sid))
	return r if UNITS.has(r) else sid

# A copy of a table that can be changed afterwards.
static func copy_value(v: Variant) -> Variant:
	if v is Dictionary:
		var d := {}
		for k in v:
			d[k] = copy_value(v[k])
		return d
	if v is Array:
		var a := []
		for x in v:
			a.append(copy_value(x))
		return a
	return v

# damage formula, miscext2.script _misc_DoDamage
static func apply_damage(dmg: float, weap_kind: String, target: Dictionary) -> int:
	var d := int(dmg)
	if target.get("cavalry", "") == "fast" and target.get("moving", false) \
			and (weap_kind == "arrow" or weap_kind == "bullet"):
		d -= 5
	var shield: int = target.get("shield", 0)
	if target.get("finished", true):
		d -= shield
	else:
		d -= int(shield / 3.0)
	var prot: Array = target.get("prot", [0, 0, 0, 0, 0, 0])
	var wk: int = WK.get(weap_kind, 0)
	if wk >= 0 and wk < PROT_SLOT.size():
		var slot: int = PROT_SLOT[wk]
		if slot >= 0 and slot < prot.size():
			d -= int(prot[slot])
	if d < 1:
		d = 1
	return d

# res is the player's 6-slot array in RES_NAMES order (food, wood, stone, gold, iron, coal)
static func can_pay(res: Array, cost: Dictionary) -> bool:
	for k in cost:
		if res[RES_NAMES.find(k)] < int(cost[k]):
			return false
	return true

static func pay(res: Array, cost: Dictionary) -> void:
	for k in cost:
		res[RES_NAMES.find(k)] = res[RES_NAMES.find(k)] - int(cost[k])

static func refund(res: Array, cost: Dictionary, percent: float) -> void:
	for k in cost:
		res[RES_NAMES.find(k)] = res[RES_NAMES.find(k)] + int(round(cost[k] * percent))

# ─── IMPL-COLLISION-DATA — DEC-U-COLLISION-FULL §1–§7 donor telemetry ──────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_collision_full.md
#            (read-only donor text/byte/decomp passes, pin t_87f0f3c130b0;
#            donor binary NEVER executed). Every row below is an [O]/[D] donor
#            fact from that report or its read-only shell census. DATA ONLY:
#            no consumer is wired, no UNITS_BASE/BUILDINGS_BASE number, gate,
#            key or save version is changed. NO PARITY CLAIM. No [U] is closed
#            by a port fallback: each keeps its named recipe/capture.
# §1 radius · §2 masks · §3 scale/AABB/selection · §4 formation ·
# §5 centred origin + rotation · §6 inertia · §7 LOS/ctpo.

# §1.2 donor conversion law [O/D] — dmscript.global:170-172 (ev_fc13…).
# The port's PX_TO_M / TILE_M / DEC_U_PX_PER_TILE already carry these; the
# §1.3 metres below use the DONOR divisor 26.6666666, never a port estimate.
const DONOR_COLL_PX_PER_TILE := 53.3333333          # gc_pixels_to_tile :172
const DONOR_COLL_PX_PER_METRE := 26.6666666         # gc_pixels_to_meter :170
const DONOR_COLL_METRES_PER_TILE := 2.0             # gc_meters_to_tile :171
const DONOR_COLL_CELL_M := 0.5                      # gc_collision_size (C6/§2.3)

# §1.3 radius constants [O] dmscript.global:665-678 (ev_4fef…) + [D] metres.
# "applies_to" is the branch site as read, NOT a complete per-sid map; the
# full 140-sid closure stays [U] U12-ships-open (recipe §9(i), capture C-CAP-2).
const DONOR_COLL_RADIUS_CONSTANTS := {
	"default": {"px": 10, "tiles": 0.1875, "m": 0.375,
		"cite": "dmscript.global:665-678; unit.script:630-1330 sampled",
		"applies_to": "sid branches with NO objprop.radius override; closure [U] U12-ships-open"},
	"horse": {"px": 15, "tiles": 0.28125, "m": 0.5625,
		"cite": "dmscript.global:665-678; unit.script:1323/:1421/:1547/:1667",
		"applies_to": "horse branch heads; ellipsis list NOT expanded into a per-sid map"},
	"artillery": {"px": 15, "tiles": 0.28125, "m": 0.5625,
		"cite": "dmscript.global:665-678; unit.script:1700/:1736/:1769/:1797/:1827",
		"applies_to": "cannon/howitzer/mortar/multicannon/framegun (explicit rows)"},
}

# §1.3 EXPLICIT per-sid rows [O px + D m], keyed by donor sid with its branch
# cite. 5 artillery rows + all 9 ship rows in the report's table order.
# This is the single-source cited table; the older DEC_U_R_SHIPS_PX/M constant
# above stays UNCHANGED as the unordered [U] slot list, not a sid map.
const DONOR_COLL_RADIUS_BY_SID := {
	"cannon": {"px": 15, "m": 0.5625, "group": "artillery", "cite": "unit.script:1700"},
	"howitzer": {"px": 15, "m": 0.5625, "group": "artillery", "cite": "unit.script:1736"},
	"mortar": {"px": 15, "m": 0.5625, "group": "artillery", "cite": "unit.script:1769"},
	"multicannon": {"px": 15, "m": 0.5625, "group": "artillery", "cite": "unit.script:1797"},
	"framegun": {"px": 15, "m": 0.5625, "group": "artillery", "cite": "unit.script:1827"},
	"fishboat": {"px": 40, "tiles": 0.75, "m": 1.5, "group": "ship", "cite": "unit.script:1858"},
	"ferry": {"px": 70, "tiles": 1.3125, "m": 2.625, "group": "ship", "cite": "unit.script:2036"},
	"yacht": {"px": 35, "tiles": 0.65625, "m": 1.3125, "group": "ship", "cite": "unit.script:1876"},
	"yachttur": {"px": 50, "tiles": 0.9375, "m": 1.875, "group": "ship", "cite": "unit.script:1907",
		"note": "inside yacht/yachttur branch; yachttur never uses the yacht 35 px"},
	"chaika": {"px": 45, "tiles": 0.84375, "m": 1.6875, "group": "ship", "cite": "unit.script:2016",
		"note": "chaika override inside the 4-ship branch"},
	"galley": {"px": 80, "tiles": 1.5, "m": 3.0, "group": "ship", "cite": "unit.script:1925"},
	"frigate": {"px": 90, "tiles": 1.6875, "m": 3.375, "group": "ship", "cite": "unit.script:1962",
		"note": "base of frigate/xebec/battleship/chaika; frigate keeps it"},
	"xebec": {"px": 80, "tiles": 1.5, "m": 3.0, "group": "ship", "cite": "unit.script:1992",
		"note": "xebec override; never uses the 90 px base"},
	"battleship": {"px": 90, "tiles": 1.6875, "m": 3.375, "group": "ship", "cite": "unit.script:2002"},
}

# §1.3 ship-branch NESTING [O] unit.script:1855-2036 (shell read). Kept as
# branch structure, not flattened into a guessed map for unnamed sids.
const DONOR_COLL_SHIP_BRANCHES := {
	"cite": "unit.script:1855-2036 (shell [O])",
	"groups": [
		{"branch": "fishboat", "sids": ["fishboat"], "base_px": 40},
		{"branch": "yacht/yachttur", "sids": ["yacht", "yachttur"], "base_px": 35,
			"override": {"yachttur": 50}},
		{"branch": "galley", "sids": ["galley"], "base_px": 80},
		{"branch": "frigate/xebec/battleship/chaika", "sids": ["frigate", "xebec", "battleship", "chaika"],
			"base_px": 90, "override": {"xebec": 80, "battleship": 90, "chaika": 45}},
		{"branch": "ferry", "sids": ["ferry"], "base_px": 70},
	],
	"invariants": ["yachttur never uses 35 px", "xebec never uses 90 px", "frigate keeps the 90 px base"],
	"status": "[O] five sampled branch groups; complete 140-sid closure [U] U12-ships-open",
}

# §1.3 horse branch heads [O] — explicitly cited sids only; the report's
# ellipses mean this is NOT a complete per-sid map and must not be used as one.
const DONOR_COLL_HORSE_BRANCH_HEADS := [
	{"cite": "unit.script:1323", "sids": ["croat", "hussar", "hussarpru", "wingedhussar", "cossacksich", "hackapell", "raidersco"]},
	{"cite": "unit.script:1421", "sids": ["reiter", "cuirassier"]},
	{"cite": "unit.script:1547", "sids": ["dragoon"]},
	{"cite": "unit.script:1667", "sids": ["tatar"]},
]

# §4 formation slot constants [O] DEFINED but commented out at the sampled
# consumer (group.script:122-160). NOT an implemented slot pitch.
const DONOR_COLL_FORMATION_RADIUS := {
	"default": {"px": 8, "m": 0.30, "cite": "dmscript.global:677"},
	"horse": {"px": 12, "m": 0.45, "cite": "dmscript.global:678"},
	"sampled_consumer": "group.script:122-160: `//unitRadius := _misc_PixelsToTiles(gc_obj_radius_formation_default);` is COMMENTED OUT; live code uses unitRadius := _group_GetMaxUnitRadius(grHnd), unitRadius*0.8, dispRadius := unitRadius*0.5, formation-mask gating",
	"unresolved": "[U] U12-form-open: horse-slot kinds and exact arGrid offsets need squad.script + C-CAP-3",
}

# DATA-ONLY resolver: exact donor metres only for an explicitly cited per-sid
# row; null means UNRESOLVED, NOT a bucket fallback. No consumer is wired.
static func donor_collision_radius_m(sid: String) -> Variant:
	var row: Variant = DONOR_COLL_RADIUS_BY_SID.get(sid, null)
	if row == null:
		return null
	return float((row as Dictionary)["m"])

# §6 inertia numerics [O] dmscript.global:969-974 (ev_c875…) + ref props.
# Engine-side stand/attack switching stays [U] U-inertia (§6 runtime shoving
# capture); DEC_U_COLLISION_INERTIA above stays null for that switch.
const DONOR_COLL_INERTIA_TEXT := {
	"mass": {"default": 1, "stand": 1.5, "attack": 3},
	"radius": {"default": 0.16, "stand": 0.1, "attack": 0.1},
	"cite": "dmscript.global:969-974 (ev_c875…)",
	"unresolved": "[U] U-mass-switch (S-STAND) / U-radius-switch (S-RADIUS): the stand 1.5 / 0.1 and attack 3 / 0.1 rows are [O] DEFINED at dmscript.global:970-971/973-974 but have ZERO sampled active consumers (DEC-U-INERTIA-RTTI §2.4, P9-T full-tree grep = definition lines only). VALUES are closed as text; the CONSUMER is open. No stand/attack value is wired into any solver.",
}
const DONOR_COLL_CI_CLASS_ROWS := {
	"CIMass": 1, "CIIntersectRadius": 0.16, "CIMaxDistKoef": 2,
	"CIDeltaStep": 0.005, "CIRotationSpeed": 5, "CIStuckAngle": 5,
	"CIEpsilonAngle": 4, "CIEpsilonShift": 0.001, "CIEpsilonMove": 0.02,
	"CIDistExtPointEpsilon": 0.005, "CIAvoidPointMaxAngle": 60,
	"CIMaxCollideCounter": 7, "UncollideDelta": 0.05,
	"refunit": {"CIEnabled": true, "CIMovable": true},
	"refbuilding": {"CIEnabled": false, "CIMovable": false},
	"cite": "refunit.prop (carried) / refbuilding.prop (ev_ae79…)",
}
const DONOR_COLL_CI_BUILD_RULE := {
	"on_build": {"movable": false, "intersect_radius_m": 0.0,
		"expr": "gc_collision_radius_default*0", "cite": "unit.script:11163-11169"},
	"on_leave_build": {"movable": true, "intersect_radius_m": 0.16,
		"expr": "gc_collision_radius_default", "cite": "unit.script:11163-11169"},
	"note": "[D] 0.16*0 = 0.0 exactly; mobile CI radius is exactly 0.16",
}

# ── DEC-U-INERTIA-RTTI §5 R2 — INERT DONOR CI DATA / TELEMETRY ───────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_inertia_rtti.md
#   §2.2 SetCustom ship table · §2.3 gate colliders · §3 S3-S6 switches ·
#   §1/§2.4/§4 [U] field table.
# Read-only donor TEXT against pin t_87f0f3c130b0; donor binary NEVER executed;
# no GPU frame captured, NO PARITY CLAIM. Every number below is [O] verbatim with
# a file:line cite, or [D] arithmetic derived ONLY from cited [O] literals.
# DATA / TELEMETRY ONLY: no consumer wired, no solver law added, no existing
# value changed. Landed VISIONTABLE / SHIELDROWS / COLLDATA / VICTORYDATA /
# DAMAGEDATA / RNGDATA / FLIGHTDATA edits are preserved byte-for-byte.
# ────────────────────────────────────────────────────────────────────────────────

# (a) §2.2 ACTIVE `SetCustomCollisionInertia` ship table [O] — procedure at
# initial.inc:21-56, active call sites at :239-257 / :242-248. Tuple keys match
# the donor signature (hnd, IntersectRadiusFactor, MassFactor,
# DeltaStepFactor, bMovable). [D] radius_m = 0.16*radius_factor;
# mass = 1*mass_factor; delta_step = 0.005/delta_factor = 0.05 for every active
# row (all pass delta_factor = 0.1; MassFactor > 0 branch at :38-39).
const DONOR_COLL_SHIP_INERTIA := {
	"ferry": {"radius_factor": 11, "mass_factor": 32, "delta_factor": 0.1, "radius_m": 1.76, "mass": 32, "delta_step": 0.05},
	"battleship": {"radius_factor": 11, "mass_factor": 32, "delta_factor": 0.1, "radius_m": 1.76, "mass": 32, "delta_step": 0.05},
	"frigate": {"radius_factor": 9, "mass_factor": 16, "delta_factor": 0.1, "radius_m": 1.44, "mass": 16, "delta_step": 0.05},
	"xebec": {"radius_factor": 9, "mass_factor": 16, "delta_factor": 0.1, "radius_m": 1.44, "mass": 16, "delta_step": 0.05},
	"galley": {"radius_factor": 7, "mass_factor": 12, "delta_factor": 0.1, "radius_m": 1.12, "mass": 12, "delta_step": 0.05},
	"chaika": {"radius_factor": 6, "mass_factor": 8, "delta_factor": 0.1, "radius_m": 0.96, "mass": 8, "delta_step": 0.05},
	"yacht": {"radius_factor": 6, "mass_factor": 8, "delta_factor": 0.1, "radius_m": 0.96, "mass": 8, "delta_step": 0.05},
	"yachttur": {"radius_factor": 6, "mass_factor": 8, "delta_factor": 0.1, "radius_m": 0.96, "mass": 8, "delta_step": 0.05},
	"fishboat": {"radius_factor": 3, "mass_factor": 1, "delta_factor": 0.1, "radius_m": 0.48, "mass": 1, "delta_step": 0.05},
	"cite": "unit.inc/initial.inc:21-56 (procedure) + :239-257/:242-248 (active call sites) [O]",
	"derive": "[D] radius_m = 0.16*radius_factor; mass = 1*mass_factor; delta_step = 0.005/0.1 = 0.05 (MassFactor > 0, :38-39)",
	"overrides": {"avoid_point_max_angle": 180, "stuck_angle": 0, "max_collide_counter": 21, "max_process_object": 12, "build_ext_points": true},
	"overrides_cite": "unit.inc/initial.inc:21-56 [O] avoid 180 vs class 60; stuck 0 vs class 5; counter 7*3=21 vs 7; maxproc 4*3=12; ext-points True",
	"dead_alternates": {"factors": [14, 11, 9, 8, 4], "cite": "unit.inc/initial.inc:249-255 [O] {…} COMMENTED-OUT block — DEAD text, NOT active, NOT ported as active"}
}

# (b) §2.3 gate / building collider literals [O] — building.inc/initial.inc:52-94.
const DONOR_COLL_GATE_COLLIDER := {
	"mass": 10000, "intersect_radius_m": 0.35, "avoid_point_max_angle": 120,
	"max_collide_counter": 7, "collision_inertia": true, "movable": false,
	"max_dist_koef": 2, "delta_step": 0.005, "rotation_speed": 5,
	"stuck_angle": 5, "epsilon_angle": 4, "epsilon_shift": 0.001,
	"epsilon_move": 0.02, "dist_ext_point_epsilon": 0.005,
	"cite": "building.inc/initial.inc:52-94 [O] AddCICollider + SetupCollider",
	"setup_collider_rule": "[O] :92 — SetGameObjectCIIntersectRadiusByHandle(goHnd, rad) with cited call-site rad = 0.35; SetupCollider also sets CollisionDetection False",
	"map_blob_rule": "[O] :30-47 — CIIntersectRadius 0 -> position -> scale -> CIIntersectRadius 0.2; CIMass 1"
}

# (c) §2.2 `SetCustomCollisionInertia` formula block [O] initial.inc:21-56.
const DONOR_COLL_SETCUSTOM_FORMULAS := {
	"mass": "1*massFactor",
	"intersect_radius": "gc_collision_radius_default*IntersectRadiusFactor",
	"delta_step": "0.005/DeltaStepFactor when MassFactor > 0, else 0",
	"avoid_point_max_angle": 180, "stuck_angle": 0,
	"max_collide_counter": "7*3 = 21 [D]", "max_process_object": "4*3 = 12 [D]",
	"build_ext_points": true,
	"max_dist_koef": 2, "rotation_speed": 5, "epsilon_angle": 4,
	"epsilon_shift": 0.001, "epsilon_move": 0.02, "dist_ext_point_epsilon": 0.005,
	"aabb_widen": "±gc_collision_radius_default*IntersectRadiusFactor (:47-55)",
	"cite": "unit.inc/initial.inc:21-56 [O]",
	"note": "INERT formula text only — no solver law, no wired consumer"
}

# §3 S3-S6 sampled birth / none / build / force-tag switches [O]. INERT register;
# the S5/S6 build values are already mirrored in DONOR_COLL_CI_BUILD_RULE above.
const DONOR_COLL_CI_SWITCH_SITES := {
	"birth": {
		"cite": "unit.inc/ontagstates.inc:888-902 [O] switchEssential=birth",
		"non_ship": "CIIntersectRadius gc_collision_radius_default*0.4 (= 0.064 m [D]); CollisionInertia False; hide/pick/scan removals"
	},
	"none": {
		"cite": "unit.inc/ontagstates.inc:903-923 [O] switchEssential=none",
		"non_ship": "CollisionInertia True THEN CIIntersectRadius gc_collision_radius_default (0.16 m [O]) — ORDER-DEPENDENT, :910 comment: else radius will be 0.8; collision-detect True; STO+scan re-added; ships create childs"
	},
	"build": {
		"cite": "unit.inc/ontagstates.inc:924-936 [O] switchAction=build / iOldAction=build -> not build",
		"on_build": "CIMovable False + CIIntersectRadius 0",
		"on_leave_build": "CIMovable True + CIIntersectRadius gc_collision_radius_default (0.16)",
		"dead": "the CollisionInertia toggles in this block are //-commented OUT (dead) — do not wire"
	},
	"force_tag_build": {
		"cite": "lib/unit.script:11160-11170 [O] ForceStateTag build mirror",
		"on_build": "iAction=build and movable -> CIMovable False + CIIntersectRadius gc_collision_radius_default*0 (= 0.0 [D])",
		"on_leave_build": "iAction<>build and not movable -> CIMovable True + CIIntersectRadius gc_collision_radius_default (0.16 [O])"
	},
	"order_law": "[O] un-birth sets radius AFTER enable (:910 comment); build transitions set movable+radius atomically (R4 — for a FUTURE consumer only, not this ticket)",
	"unresolved": "[U] U-solver (S-SOLVER): no engine shove/separation law recovered; none is modelled here. NO PARITY CLAIM."
}

# §1/§2.4/§4 open items [U] — each terminates in a named two-unit shove capture,
# NEVER in a port fallback. No numeric is invented to close any of these.
const DONOR_COLL_CI_UNRESOLVED := {
	"U-offsets": "field offsets/count/types — no RTTI string, 0 xref, no field table (P2/P5/P6/P8) -> S-OFFSETS",
	"U-ctor": "in-binary numeric defaults — CI property / verb strings all x0 (P3/P7/P8); text table §2 is the only source -> S-CTOR",
	"U-prefix": "meaning of the `3` in `3XCollisionInertia` — only the 3-prefixed spelling exists (P1) -> S-PREFIX",
	"U-mass-switch": "consumer of mass 1.5 / 3 — DEFINED, ZERO sampled active readers -> S-STAND",
	"U-radius-switch": "consumer of radius 0.1 / 0.1 — DEFINED, ZERO sampled active readers -> S-RADIUS",
	"U-solver": "engine shove/separation law — no name, no float, no caller recovered -> S-SOLVER",
	"build_order_law": "[O] text captured above; capture S-BUILD is a zero-mismatch guard, not an open item",
	"claim": "NO PARITY CLAIM; every [U] terminates in a named capture, never a port fallback"
}

# §2.1/§2.2 mask census [O] read-only shell of D:objects/buildings/*.prop
# (369 files). No bitmap is fabricated: only the verbatim rows printed in
# §2.3 are stored below; the 15 mask-less files and the unscanned 354 remain
# an explicit gap list, never a resized stand-in.
const DONOR_COLL_MASK_CENSUS := {
	"buildings": 369, "with_rows": 354, "without_rows": 15,
	"maskless": ["algaca", "algart", "algbar", "algbla", "algdip", "algsta", "algtem",
		"misdecor1", "misdecor2", "misdecor3", "misdecor4", "misdecor5", "misdecor6",
		"misdecor7", "misdecor8"],
	"units": 140, "units_with_rows": 0,
	"cell_m": 0.5,
	"refurl_template": ".\\data\\objects\\ref\\<ref>.prop",
	"provenance": "each <sid>.prop carries {refurl=...} and only the sections it overrides; reference files define class defaults and carry NO Mask block (refbuilding.prop:39-73)",
	"extraction": "rows are [*] = <01-string> inside collisionmaskproperty; row count = h, first-row length = w; ragged files fail closed as [U]",
	"cite": "shell census §2.2 (no evidence id; commands listed in §9)",
}
# [O] dimension histogram (rows×width, count); counts sum to 354.
const DONOR_COLL_MASK_DIM_HISTOGRAM := [
	[2, 2, 62], [4, 4, 45], [5, 5, 2], [5, 6, 1],
	[3, 5, 1], [3, 6, 1], [4, 2, 1], [5, 7, 2],
	[5, 8, 1], [6, 2, 4], [6, 8, 2], [7, 6, 6],
	[7, 8, 5], [7, 10, 7], [7, 11, 1], [7, 12, 4],
	[8, 6, 3], [8, 8, 8], [8, 10, 4], [8, 12, 3],
	[8, 14, 2], [9, 8, 2], [9, 10, 20], [9, 11, 1],
	[9, 12, 10], [9, 14, 2], [10, 8, 9], [10, 10, 10],
	[10, 11, 1], [10, 12, 10], [10, 14, 1], [11, 10, 6],
	[11, 11, 2], [11, 12, 24], [11, 14, 5], [11, 15, 1],
	[11, 16, 1], [12, 12, 15], [12, 14, 3], [13, 12, 4],
	[13, 13, 1], [13, 14, 17], [13, 16, 2], [14, 12, 2],
	[14, 13, 1], [14, 14, 5], [14, 15, 1], [14, 16, 1],
	[14, 18, 1], [15, 12, 2], [15, 14, 2], [15, 16, 10],
	[15, 18, 1], [16, 8, 1], [16, 12, 1], [17, 16, 1],
	[17, 18, 4], [19, 18, 1], [19, 20, 2], [19, 22, 1],
	[21, 18, 1], [2, 6, 4],
]

# §2.3 VERBATIM bitmaps [O] — the only mask rows stored here. `1` = blocked.
# Game sids aggregate 21 nation-prefixed donor files; dims differ by
# (nation,sid), so these cited eur/algcen samples are NOT a uniform per-sid map.
const DONOR_COLL_MASK_BITMAPS := {
	"mil": {"file": "eurmil.prop", "rows": ["00100", "01110", "11111", "01110", "00100"],
		"w": 5, "h": 5, "aabb_min": [-0.70, -0.15, -0.60], "aabb_max": [0.60, 2.20, 0.65],
		"scale": 0.43, "roll": 45, "cite": "eurmil.prop:47-51 (§2.3)"},
	"tow": {"file": "eurtow.prop", "rows": ["01110", "11111", "11111", "11111", "01110"],
		"w": 5, "h": 5, "aabb_min": [-1.05, -0.25, -0.65], "aabb_max": [0.80, 2.35, 0.85],
		"scale": 0.54, "roll": 45, "cite": "eurtow.prop:47-51 (§2.3)"},
	"sto": {"file": "eursto.prop", "rows": ["0000000", "0000010", "1100010", "0000010", "0000000"],
		"w": 7, "h": 5, "aabb_min": [-1.30, -0.55, -0.30], "aabb_max": [0.15, 0.85, 1.50],
		"scale": 0.665, "roll": 45, "cite": "eursto.prop:47-51 (§2.3)"},
	"mar": {"file": "eurmar.prop",
		"rows": ["000000000110000", "000001111111000", "000011111111100", "000111111111110",
			"011111111111110", "111111111111100", "011111111111000", "001111111100000",
			"000011111000000", "000001110000000", "000000100000000"],
		"w": 15, "h": 11, "aabb_min": [-2.25, 0.00, -1.55], "aabb_max": [2.55, 1.70, 1.80],
		"scale": 0.463, "roll": 135, "cite": "eurmar.prop (§2.3)"},
	"cen": {"file": "algcen.prop",
		"rows": ["000000011000", "000000111100", "000001111110", "000011111111",
			"000111111111", "001111111110", "011111111100", "011111111000",
			"011111110000", "001111100000", "000000000000"],
		"w": 12, "h": 11, "aabb_min": [-2.40, 0.00, -1.20], "aabb_max": [2.55, 1.65, 1.20],
		"scale": 0.41, "roll": 135, "cite": "algcen.prop:47-57 (ev_21bc…)"},
	"eurswa": {"file": "eurswa.prop", "rows": ["11", "11"], "w": 2, "h": 2, "cite": "eurswa*.prop (§2.3)"},
	"eurswa_01": {"file": "eurswa_01.prop", "rows": ["11", "11"], "w": 2, "h": 2, "cite": "eurswa*.prop (§2.3)"},
	"eurswa_gate": {"file": "eurswa_gate.prop", "rows": ["11", "11"], "w": 2, "h": 2,
		"aabb_min": [-0.6, 0.00, -0.6], "aabb_max": [0.6, 1.65, 0.6],
		"scale": 0.33333, "roll": 0, "cite": "eurswa_gate.prop (§2.3)"},
	"eurswa_tower": {"file": "eurswa_tower.prop", "rows": ["11", "11"], "w": 2, "h": 2, "cite": "eurswa*.prop (§2.3)"},
}

# §2.4 / §5 — [U] gaps and rotation verdict. No fabricated bitmap, no
# rotation implementation; each gap keeps its recipe/capture.
const DONOR_COLL_MASK_GAPS := {
	"U12-mask-a": "[U] full 369-file (nation,sid)->(w,h,rows) dump; recipe §9(ii)",
	"U12-mask-b": "[U] fallback semantics for the 15 mask-less files (ref default has NO bitmap; e.g. algsta placement unproven)",
	"U12-mask-c": "[U] Rotate/Reflect/tmoRotate scan across all 369 files; recipe §9(ii)",
	"U12-rot": "[O-in-samples] no mask rotation: sampled files inherit Rotate=0/Reflect=False/tmoRotate=False; DefaultRollAngle 45/135/0 is directionupproperty VISUAL yaw, not collisionmaskproperty. [U] for unscanned files.",
	"rule": "no resized stand-in is stored; the verbatim rows above are the only bitmaps in this file",
	"capture": "C-CAP-1: place mil/tow/sto/mar/cen/eurswa_gate at 4 yaws + one mask-less sid, dump (w+4)x(h+4) occupancy; 0 mismatches, even-width bias on algcen",
}
# §3.2 sampled mask-layer transform keys [O] (refbuilding.prop:39-73 ev_ae79…).
const DONOR_COLL_MASK_TRANSFORM_KEYS := {
	"Rotate": 0, "ScaleFactor": 1, "Reflect": false,
	"tmoScale": false, "tmoRotate": false,
	"TransformChildrenMaskOptions": [false, false],
	"LayerOptions": [false, false, false, false],
	"coTest": true, "coWrite": true, "ChildrenOptions": [false, false],
	"TestTypeOption": "cttoNone", "TestPriorityOption": "ctpoNever",
	"note": "scale does NOT rescale the bitmap at the mask layer in any sampled file; AABB is the scaled broadphase (UseCustTransformed=True on buildings)",
}

# §3.1 class defaults [O]: DefaultScale / AABB / sphere / SelectionSize / CI.
const DONOR_COLL_REF_GEOMETRY := {
	"refunit": {"default_scale": [0.5, 0.5, 0.5], "aabb_min": [-0.25, -0.10, -0.25],
		"aabb_max": [0.25, 0.90, 0.25], "sphere": 0.32, "selection_shape": "stoCircle",
		"selection_size": 0.5, "cite": "refunit.prop:331 selection block (carried)"},
	"refunithorse": {"default_scale": 0.5375, "aabb_min": [-0.35, 0.05, -0.35],
		"aabb_max": [0.35, 0.95, 0.35], "cite": "refunithorse.prop (§3.1)",
		"note": "inherits unit selection/CI"},
	"refbuilding": {"default_scale": 0.375, "aabb_min": [-0.5, -0.5, -0.5],
		"aabb_max": [0.5, 0.5, 0.5], "sphere": 0.5, "selection_shape": "stoCircle",
		"selection_size": 1, "cite": "refbuilding.prop (ev_ae79…)"},
}
# §3.1 unit inheritance/overrides [O]; §3.2 building per-sid overrides [O].
# DefaultRollAngle is visual yaw (directionupproperty), NOT mask rotation.
const DONOR_COLL_UNIT_GEOMETRY_OVERRIDES := {
	"cannon": {"default_scale": 0.5, "cite": "cannon.prop — no scaleproperty block [O]"},
	"horse_sids": {"default_scale": 0.5375, "cite": "refunithorse.prop; horse sids use this class [O]"},
	"frigate": {"default_scale": 0.5, "aabb_min": [-0.7, -0.4, -2.0], "aabb_max": [0.7, 0.9, 3.2],
		"use_cust_transformed": true, "terrain": "ocoTerrainWater",
		"cite": "frigate.prop — no scaleproperty block [O]"},
}
const DONOR_COLL_BUILDING_GEOMETRY := {
	"mil": {"sid": "eurmil", "default_scale": 0.43, "roll": 45,
		"aabb_min": [-0.70, -0.15, -0.60], "aabb_max": [0.60, 2.20, 0.65]},
	"sto": {"sid": "eursto", "default_scale": 0.665, "roll": 45,
		"aabb_min": [-1.30, -0.55, -0.30], "aabb_max": [0.15, 0.85, 1.50]},
	"mar": {"sid": "eurmar", "default_scale": 0.463, "roll": 135,
		"aabb_min": [-2.25, 0.00, -1.55], "aabb_max": [2.55, 1.70, 1.80]},
	"tow": {"sid": "eurtow", "default_scale": 0.54, "roll": 45,
		"aabb_min": [-1.05, -0.25, -0.65], "aabb_max": [0.80, 2.35, 0.85]},
	"wall_gate": {"sid": "eurswa_gate", "default_scale": 0.33333, "roll": 0,
		"aabb_min": [-0.6, 0.00, -0.6], "aabb_max": [0.6, 1.65, 0.6]},
	"cen": {"sid": "algcen", "default_scale": 0.41, "roll": 135,
		"aabb_min": [-2.40, 0.00, -1.20], "aabb_max": [2.55, 1.65, 1.20]},
	"cite": "§3.2 building per-sid overrides (shell reads)",
}

# §5 centred mask origin [O] binary decomp (ev_8655…, pin t_87f0f3c130b0).
# Static telemetry only — no game.gd stamp/ray test is edited by this worker.
const DONOR_COLL_CENTRED_ORIGIN := {
	"centre_offset": "(W-1)>>1 / (H-1)>>1",
	"write": "sub_764e04: if 0<=edx<W and 0<=ecx<H then rowTable[[obj+0xa8]][edx][ecx]=arg_8",
	"write_centre": "sub_755168: add (W-1)>>1 to dx and (H-1)>>1 to dz before sub_764e04; even sizes bias by >>1 truncation",
	"read": "sub_7550f8: test -W/2..+W/2 x -H/2..+H/2, add W>>1/H>>1 back before the row-table read",
	"gate": "sub_75505c: centred test + if [esi+0x65]!=0 then sub_7d9694; occupant id at +0x1c",
	"offsets": {"row_table": "+0xa8", "gate": "+0x65", "occupant_id": "+0x1c"},
	"cell_stride_m": 0.5, "cell_sample_offset_m": 0.25,
	"cite": "ev_8655… / gc_collision_size ev_fc13… / misc.script:4677,4706",
	"consumer_side": "unit.script:8588-8595/8714-8724/8771-8981 mask walk; misc.script:4646-4706 per-cell GetMapCollisionTagInRadius(x+i*0.5+0.25,...)",
}

# §7 LOS surface [O] donor text; ENGINE IMPLEMENTATION STAYS [U]. No ray test
# is added here; C-CAP-4 is the terminator for the engine-side truth table.
const DONOR_COLL_LOS_SURFACE := {
	"projectile": "projectile.inc/nothing.inc:55-56: OctreeRayCastIntersect(trgHnd,sx,sy,sz,dx,dy,dz,px,py,pz,nx,ny,nz); Children variant commented out; dst<2 branch",
	"mouse_pick": "control.script:150-200/:286-300: GameObjectRayCastMouseRay; GameObjectSortRayCastList; prio 0.5; GetGameObjectRayCastAABBByHandle + nearest by _misc_GetDistancePos",
	"scan_march": "misc.script:2281-2360: GetGameObjectRayCastAABBByHandle or ...CustAABB... when gCustomObjPoints[cid][id].aabb.buse; y<0.05 -> 0.05 clamp",
	"toggles": "SetGameObjectRayCastIntersectEnabledByHandle (unit.script:11805); SetTerrainRayCastPrecison(0.0000001) (init.script:101)",
	"flags": "RayCastIntersect=False, RayCastUsingTLF=False, UseCameraCollision=False, BVRayCastIntersect=False in refunit/refbuilding; no per-sid override sampled",
	"status": "[O] call shapes only. [U] U13-impl: argument types, return convention and engine ctpo comparison UNRECOVERED; NO ray test is implemented here.",
	"capture": "C-CAP-4: wall/ridge/open-water pairings, toggle sets, log (hit,px,py,pz,nx,ny,nz); typed signature + ctpo truth table, 0 mismatches",
}
const DONOR_COLL_CTPO_TEXT := {
	"water": "ctpoEqual", "land": "ctpoGreater",
	"cite": "dmscript.global:94-95 (shell [O])",
	"mirror": "DEC_U_WATER_TEST / DEC_U_LAND_TEST above carry these names; no engine compare operand is claimed",
}

# ─── DEC-U-DAMAGE-HEIGHT §§2-9 — DONOR DISPERSION / HEIGHT / addradius / uniqrnd ──
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_damage_height.md
# (read-only donor TEXT pass P1-P9, 2026-11-26, pin t_87f0f3c130b0; donor binary
# NEVER executed, no GPU frame compared). [O] = verbatim donor literal + cite,
# [D] = deterministic reading, [U] = unresolved with the report's exact capture.
# DATA + LAW ONLY: every constant and helper below is an inert, cited mirror; NO
# consumer is wired here and game.gd behavioural rewiring is OUT OF SCOPE. Adding
# this block changes no runtime behaviour, no save key and no existing value.
# NO PARITY CLAIM. The three port inventions (hd>0.6 -> max*1.25, dist/30 flight,
# halved constant scatter) are NOT reproduced and are not smoothed over.

# ── §2 DISPERSION — uniform SQUARE scatter of the IMPACT POINT, NOT a hit roll ──
# [O] weapon.script:627-646 `_weapon_CalcShotDispertion`:
#   dist := VectorDistance(px,0,pz,tx,0,tz);
#   maxdisp := dist*disp*gc_pixels_to_tile/2000;   (:639)
#   dx := tx+(1-RandomExt*2)*maxdisp;               (:640)
#   dz := tz+(1-RandomExt*2)*maxdisp;               (:641)
#   dy := ty;                                       (:642; RayCastHeight alt dead)
# [O] gc_pixels_to_tile = 53.3333333 (dmscript.global:172); `disp` is TILES (per-
#     mount `_misc_PixelsToTiles(dispertion_px)` at registration), `dist` is TILES.
# [D] Substituting dispertion_px/53.3333333 cancels the tile factor:
#     maxdisp_tiles = dist_tiles*dispertion_px/2000, and with TILE_M=2 the SAME
#     numeric law holds in metres: maxdisp_m = dist_m*dispertion_px/2000.
# [D] Distribution is UNIFORM SQUARE — two INDEPENDENT (1-RandomExt*2) draws,
#     each uniform in [-maxdisp,+maxdisp] — NOT Gaussian. `_misc_ProjSimulatePoint`
#     Gaussian scatter (miscext2.script:641-728) applies ONLY to randomsimulate
#     child fragments, never to aimed fire.
# [D] There is NO hit-probability / to-hit / percentage roll in the donor fire→
#     impact chain: dispersion shifts WHERE the shot lands, not WHETHER it hits.
#     The only percentage roll in the chain is the T2-closed headshot random<0.05.
# [O] Gating (:629-645): only when goHnd<>0 AND disp>0; a zero-dispersion mount
#     (muskets: no dispertion write) scatters NOTHING — its in-game spread comes
#     from uniqrnd range shortening (§4), never aim error.
const DONOR_DISPERSION_DENOM := 2000.0              # weapon.script:639

static func donor_max_dispersion(dist: float, dispertion_px: float) -> float:
	# [O]/[D] dist in TILES or METRES — the tile factor cancels (identical law).
	return dist * dispertion_px / DONOR_DISPERSION_DENOM

static func donor_dispersion_axis_offset(maxdisp: float, random_ext: float) -> float:
	# [O] one (1-RandomExt*2)*maxdisp term (:640 dx, :641 dz); dy stays ty (:642).
	# The caller supplies a SIM-stream RandomExt draw in [0,1); no RNG invented.
	return (1.0 - 2.0 * random_ext) * maxdisp

# [O] Cited per-mount dispertion_px already live in DONOR_MOUNT_ROWS above:
#     cannon idx0 225 (:1708), tower 100 (:2232), tower.commonrus 125
#     (report §10-2 cites :2244; the landed DONOR_MOUNT_ROWS note cites :2246),
#     howitzer 300 (:1745), mortar 200 (:1778), framegun 250 (:1836),
#     yacht 250 (:1885), galley 25/200 (:1934/:1940), frigate 250 (:1971).
#     -1 = donor `default` keep-prior (NO cited write), never back-filled.
# [O] Foot-mount fallback VALUE SET (per-sid mapping NOT recovered here [U]; do
#     not copy a neighbour): archer-family 175/100/150/200, unit.script:1001-1047.
#     Musket foot mounts 0 = no scatter. Existing ARROW/CANNON/TOWER_DISPERSION_PX
#     (data.gd:421-423) stay untouched as port constants.
const DONOR_DISPERSION_FOOT_FALLBACK_PX := [175.0, 100.0, 150.0, 200.0]
const DONOR_DISPERSION_FOOT_FALLBACK_CITE := "unit.script:1001-1047 [O] values; per-sid mapping [U]"

# [O] Same maxdisp formula reused for the friendly-fire PRE-CHECK
#     (unit.script:5300-5305 `_unit_CheckFriendlyFireExplosion`): scan radius
#     maxdisp+dmgRad, dmgRad 3.75 mortar else 1.25 (tiles), needs
#     enemycount >= friendcount*4. Port has NO equivalent gate (§9-U4 / §11-5) —
#     DATA ONLY here, never a live veto in this worker.
const DONOR_FF_PRECHECK_DMG_RADIUS_TILES := {"mortar": 3.75, "other": 1.25}
const DONOR_FF_PRECHECK_ENEMY_RATIO := 4

# ── §4 HEIGHT — RANGE ONLY, DOWNHILL ONLY, ADDITIVE; NEVER damage/dispersion ───
# [O] Site A, attack-order weapon choice (unit.script:7855-7873):
#     bonusrng := MaxFloat((py-ty)*4, 0) if bArtillery else MaxFloat((py-ty)*2, 0);
#     if (bonusrng<0.25) then bonusrng := 0;       (:7870-7872)
#     melee (radiusmax<=gc_unit_meleeattackradius=3.5) => rbonus := 0 (:7869-7872);
#     BOTH `dist<=(detectradiusmax+rbonus)` and `dist<=(radiusmax+rbonus)` grow
#     (:7893-7906). [O] py/ty are engine Y in TILES (GetGameObjectAbsolutePosition-
#     ByHandle; RayCastHeight/RayCastWater for ground targets). 0.25 tiles = 0.5 m.
# [O] Site B, movement/approach (unit.script:7547-7568): MaxFloat((py-dstHeight)*2,0)
#     — NO artillery split here; radiusmax -= gc_obj_maxattackradiusdisp*uniqrnd
#     when radiusmax>3.5 and standtime<0.25; bDistanceOk := (not bDistanceFar) and
#     dist>=radiusmin.
# [O] Site C, point-attack weapon index (unit.script:6332-6356
#     `_unit_GetWeaponToAttackIndexByPoint`): bonusrng := (py-dstHeight)*2 RAW,
#     UNCLAMPED at this site; same melee exclusion; `dist<(radiusmax+rbonus)`.
# [D] Uphill is NEVER penalised (MaxFloat(...,0)); damage is NEVER touched
#     (`_misc_DoDamage` :332-464 / `_misc_DoRoundDamage` :562-604 have no height).
const DONOR_HEIGHT_K_ARTILLERY := 4.0              # unit.script:7855-7873
const DONOR_HEIGHT_K_OTHER := 2.0                  # :7855-7873, :7547-7568, :6332-6356
const DONOR_HEIGHT_FLOOR_TILES := 0.25             # :7870-7872 (0.5 m)
const DONOR_HEIGHT_MELEE_MAX_TILES := DEC_U_MELEE_RADIUS_TILES  # 3.5, dmscript.global:197
const DONOR_MAX_ATTACK_RADIUS_DISP := 3             # dmscript.global:116 (gc_obj_maxattackradiusdisp)
const DONOR_UNIQRND_ARTILLERY_MULT := 0.5          # unit.script:8017-8023

static func donor_height_is_melee(radiusmax_tiles: float) -> bool:
	# [O] :7869-7872 / :6332-6356 melee iff radiusmax <= 3.5 tiles.
	return radiusmax_tiles <= DONOR_HEIGHT_MELEE_MAX_TILES

static func donor_height_bonusrng_tiles(py_tiles: float, ty_tiles: float, artillery: bool) -> float:
	# [O] Site A :7855-7873 — MaxFloat((py-ty)*k,0), floor 0.25 -> 0; rated k=4/2.
	var k: float = DONOR_HEIGHT_K_ARTILLERY if artillery else DONOR_HEIGHT_K_OTHER
	var bonus: float = maxf((py_tiles - ty_tiles) * k, 0.0)
	return bonus if bonus >= DONOR_HEIGHT_FLOOR_TILES else 0.0

static func donor_height_site_c_bonusrng_tiles(py_tiles: float, ty_tiles: float) -> float:
	# [O] Site C :6332-6356 — raw (py-dstHeight)*2, deliberately UNCLAMPED here.
	return (py_tiles - ty_tiles) * DONOR_HEIGHT_K_OTHER

static func donor_uniqrnd_range_shortening_tiles(uniqrnd: float, artillery: bool) -> float:
	# [O] :8017-8023 — radiusmax -= 3*uniqrnd (else), 3*uniqrnd*0.5 (artillery),
	#     only when standtime<0.25 and kind<>cannister. Movement variant :7565
	#     has NO cannister/artillery carve-out. uniqrnd is per-unit (§8 :2726).
	var mult: float = DONOR_UNIQRND_ARTILLERY_MULT if artillery else 1.0
	return float(DONOR_MAX_ATTACK_RADIUS_DISP) * uniqrnd * mult

# ── §3 addradius — IDLE-STANCE RANGE bonus, and the weakwall kicker ────────────
# [O] Storage (unit.script:520-546): TObjWeaponStatic.addradius is per-mount,
#     TILES via `_misc_PixelsToTiles(32)` -> 0.6 tiles (1.2 m) for the universal
#     32 px infantry/arty value; -1/`default` (:593) = keep-prior, NEVER back-filled.
# [O] Consumption (unit.script:8026-8031): `if (bIdle) then rbonus := rbonus +
#     TObjProp(pobjprop).weapon[i].addradius;`, where bIdle = statetag and
#     move_idle; then `bDistanceFar := dist>(radiusmax+rbonus)` (:8033). It is a
#     RANGE term, NOT an accuracy term.
# [O] Weakwall kicker (unit.script:8030-8031): `if (usage=gc_usage_weakwall) then
#     rbonus := rbonus+0.36;` — +0.36 tiles (0.72 m), SEPARATE from the idle gate.
# Cited mount rows (already in DONOR_MOUNT_ROWS): addradius_px 32 at cannon
# :1704-1709, howitzer :1740-1745, mortar :1772-1778, framegun :1831-1836,
# yacht :1881-1885, galley mortar-idx1 :1935-1940, frigate :1966-1971; -1 keep-
# prior on the remaining rows (cannister idx1, yachttur, xebec/battleship/chaika,
# tower, tower.commonrus, tower.commontur) — never invented as 32.
const DONOR_ADDRADIUS_IDLE_PX := 32.0              # universal infantry/arty value
const DONOR_ADDRADIUS_KEEP_PRIOR := -1              # donor `default` (:593)
const DONOR_WEAKWALL_KICKER_TILES := 0.36          # unit.script:8031 (verbatim)

static func donor_idle_range_bonus_tiles(addradius_px: float, is_idle: bool, is_weakwall: bool) -> float:
	# [O] addRadius_px -> tiles via the existing _misc_PixelsToTiles mirror;
	#     -1 (keep-prior) contributes nothing. Weakwall applies independently.
	var bonus: float = 0.0
	if is_idle and addradius_px > 0.0:
		bonus += dec_u_pixels_to_tiles(addradius_px)
	if is_weakwall:
		bonus += DONOR_WEAKWALL_KICKER_TILES
	return bonus

# ── §7/§8 uniqrnd — RECOVERED spawn site (telemetry/cite, not behaviour) ───────
# [O] unit.script:2726 — `obj.uniqrnd := RandomExt`, drawn ONCE per unit at
#     creation from the SIM stream. This CORRECTS the stale game.gd:6547 claim
#     that "no static site was recovered": the site IS recovered (:2726).
# [O] The same per-unit value is read, NOT redrawn, at miscext2.script:420,437
#     (headshot `floor(uniqrnd*500)` — already mirrored in donor_do_damage above)
#     and as the projectile's stored stream key in `_weapon_CreateProjectileBy-
#     WeaponID` / DoExplode (`doexplode.inc:12`). uniqrnd is also the per-unit
#     "accuracy" stat that shortens max range on the move (§4 above), NOT aim
#     scatter. Save contract (report §11-9): additive `uniqrnd` per projectile,
#     missing key defaults 0.0 — NO version bump, NO key rename (out of scope).
const DONOR_UNIQRND_SPAWN_SITE := "unit.script:2726"
const DONOR_UNIQRND_SPAWN_ASSIGN := "obj.uniqrnd := RandomExt"
const DONOR_UNIQRND_SPAWN_TELEMETRY := {
	"site": DONOR_UNIQRND_SPAWN_SITE,
	"assignment": DONOR_UNIQRND_SPAWN_ASSIGN,
	"stream": "sim (RandomExt)",
	"frequency": "once per unit at creation",
	"headshot_read_site": "miscext2.script:420,437 (floor(uniqrnd*500), no extra draw)",
	"corrects": "game.gd:6547 'no static site recovered' is stale",
}

# ── §5 FLIGHT — native TXThrowBehaviour integration STAYS [U]-U1 ───────────────
# [O] Script side only (weapon.script:855-986 `_weapon_InitProjectile`): speed,
#     gravity and time rows are already mirrored in DONOR_WEAPON_PROTOS above.
#     Flight itself emerges from the ENGINE `TXThrowBehaviour` — `CalcSpeedByDir-
#     AndTrgPos`, `CalcDirByHSpeedAndTrgPos`, `SetupThrowBehaviourSpeed` are native
#     calls with no script source. NO script-side timer exists in the donor.
# [U]-U1 Engine units/path/landing remain UNVERIFIED: packed exe, no donor binary
#     executed, no GPU frame captured. NO flight formula and NO curve interpolation
#     is added here; no gravity unit is invented. Port `dist/30` clamp, 0.45 s arrow
#     and 512 cap are PORT APPROXIMATION (game.gd side) and are left tagged, not
#     tuned, by this worker.
# [O] gravity-arg remap (weapon.script:877-890), engine-internal units only:
const DONOR_FLIGHT_GRAVITY_REMAP := {0: 2.0, 1: 2.5, 2: 3.75, 3: 7.0, 4: 9.25, 5: 11.5}
const DONOR_FLIGHT_GRAVITY_FLY_ARG2 := 11.5         # fly + gravity-arg 2 (arrows)
const DONOR_FLIGHT_INTEGRATION := {
	"owner": "native TXThrowBehaviour (engine boundary, no script source)",
	"script_inputs": "[O] weapon.script:855-986; rows already in DONOR_WEAPON_PROTOS",
	"native_calls": "CalcSpeedByDirAndTrgPos / CalcDirByHSpeedAndTrgPos / SetupThrowBehaviourSpeed",
	"status": "[U]-U1 — engine units/flight path/landing UNVERIFIED; no donor binary run, no GPU A/B",
	"port_inventions": "game.gd dist/30 clamp, 0.45 s arrow, 512 cap stay PORT APPROXIMATION — tag, do not tune",
	"no_formula_here": true,
}

# ── §9 SHOT-SERIES CAPTURES — telemetry register for every still-[U] item ──────
# NO PARITY CLAIM. General harness (all items): fixed camera (frozen camera3d, no
# shake), flat map (all height==h0), two entities (shooter S, target T), seeded
# rng re-seeded per series; assertions read projectiles[].target / entities[].hp,
# never pixels. TERMINATION (all): ANY single mismatch keeps the item [U] and
# forbids wiring; ZERO mismatches across the FULL series closes it. Never fit or
# invent a dispersion curve — the §2 box formula is the only admissible shape.
const DONOR_SHOT_SERIES_HARNESS := {
	"camera": "frozen camera3d, no shake (shake moves pixels, not sim)",
	"map": "flat, all height==h0; shooter S, target T",
	"rng": "seeded, re-seeded per series",
	"assertions": "projectiles[].target / entities[].hp — never pixels",
	"termination": "ANY mismatch => item stays [U], wiring forbidden; ZERO across FULL series => closed",
	"dispersion_curve": "invented/fitted curve NEVER admissible; §2 uniform box only",
}
const DONOR_SHOT_SERIES_CAPTURES := {
	"U1": "F1: flat map, cannon S vs ground aim T at 10/20/30/40 m, 50 shots each (200); record per-shot total flight + landing target; [O] script inputs (12 tiles/s, gravity 11.5-fly) but expectation is ENGINE-side => only 'lands within §2 scatter box'; landing outside box or NaN flight => stays [U]",
	"U2": "F2: two targets 1.5 m apart crosswise/downrange at mid dispersion box, 100 shots each geometry (300); victim distribution consistent with §2 uniform box x donor r+explradius rule, zero systematic bias (e.g. always-nearest) => close, else [U]",
	"U3": "F3: shooter/target height differentials 0.0-3.0 m in 0.25 m steps (13), 20 shots each (260), fixed 25 m ground dist, mount with base radiusmax ending exactly at 25 m; fire permitted iff Delta-h_tiles*k >= shortfall (k=2/4); zero mismatches => threshold+units proven, else [U]",
	"U4": "F4: ally lane-blocked / 3-ally-1-foe / 1-ally-5-foe geometries x musket/cannister/cannon (9 cells), 30 shots each (270); donor allow/veto per cell; zero mismatches => port may implement the gate, else gate stays out",
	"U5": "F5: stand-propagation mount (e.g. STRELDEZ profile) ordered to fire, 50 attempts; expectation NO projectile + 1 s-equivalent attackdelay penalty each; port currently fires => KNOWN mismatch, stays [U] until wired + re-run green",
	"U6": "F6: NUCLMOSKOL-profile impact, destroy 200 child impact points + damage times; Box-Muller sigma=0.425 clamp pattern, dst<=1.3 tiles, damagetime in [0.275,0.64] s; KS-test p>0.01 AND 0 bound violations => wireable, else [U]",
	"U7": "F7: X21 20-vector fixture (DEC_U_skirmish_tables §9-G1): assert round(6.5)=6, round(5.5)=6, round(2.5)=2, round(7.5)=8 via port donor_round vs pinned-binary; any deviation => single-site override, never floor(x+0.5)",
	"U8": "F8: fixed-seed headless draw-count per shot — musket 0 scatter draws, archer 2, cannon 2 + WriteProj frnd; exact counts 1(uniqrnd, spawn-only)/0/2/3; any extra draw => [U]",
	"U9": "F9: PUSSTRELA-profile vs target beyond ballistic reach, 50 shots; airburst at donor_round-exact time with full round+target damage at burst point; zero mismatches => wireable",
}

# ══════════════════════════════════════════════════════════════════════════════
# ─── DEC-U-FLIGHT-NATIVE §8 — DONOR STATIC FLIGHT FACTS (DATA + LAW ONLY) ──────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_flight_native.md
#   §2 script throw inputs [O] · §3 conversions [O] / gravity unit [U] ·
#   §4 TProj fields + lifecycle, gating, victim cap, simulate-point law [O] ·
#   §5 aim-side snap [O] / contact side [U] · §6 native boundary [U] ·
#   §7 N1-N7 shot-series captures · §8 port change list.
# Read-only donor TEXT against pin t_87f0f3c130b0; donor binary NEVER executed,
# no GPU frame captured, NO PARITY CLAIM. Every value below is [O] verbatim with
# its file:line cite or [D] arithmetic explicitly derived from cited [O] literals.
# DATA + LAW ONLY: no consumer is wired here; game.gd behavioural rewiring is
# OUT OF SCOPE. This APPEND changes no runtime default, no save key, no existing
# value. Landed SKIRMISHROWS/SHIELDROWS/COLLDATA/VICTORYDATA/DAMAGEDATA/RNGDATA
# edits above are preserved byte-for-byte (proof in the delivery report).
# NEVER INVENTED here: a gravity UNIT (m/s^2, tiles/s^2, px/s^2, per-frame), a
# flight CURVE (linear/parabolic/clamped) and a port TTL (`total`, 0.45 s, 512).
# Those stay [U] with the exact N1-N7 series below. The earlier §5 DONOR_FLIGHT_*
# / DONOR_SHOT_SERIES_CAPTURES (U1-U9) block is retained verbatim; this is its
# DEC-U-FLIGHT-NATIVE static-fact extension.
# ─────────────────────────────────────────────────────────────────────────────

# ── §2.1 / §3.1 speed INPUT — verbatim expression + conversion chain [O] ──────
# [O] weapon.script:872:
#   speed := _misc_PixelsToTiles(floor(gWeapons[id].speed*1000))*0.001*gc_time_to_frames
# [O] _misc_PixelsToTiles(v) = v/53.3333333 (misc.script:462-466, dmscript.global:172)
# [O] gc_time_to_frames = 32 (dmscript.global:175); TILE_M = 2 m/tile
#     (gc_meters_to_tile, dmscript.global:170-173; data.gd:23).
# [D] speed_tiles_s = floor(phys*1000)/53.3333333*0.001*32; speed_m_s = x2.0.
# floor() is DONOR-VERBATIM (:872) and is NEVER simplified away: the products on
# the cited rows are integral so floor is inert there, but the call stays.
const DONOR_FLIGHT_SPEED_INPUT_EXPR := "speed := _misc_PixelsToTiles(floor(gWeapons[id].speed*1000))*0.001*gc_time_to_frames"  # [O] weapon.script:872
const DONOR_FLIGHT_SPEED_CITES := {
	"expr": "weapon.script:872 [O]",
	"pixels_to_tiles": "misc.script:462-466 / dmscript.global:172 [O] _misc_PixelsToTiles(v)=v/53.3333333",
	"gc_time_to_frames": "dmscript.global:175 [O] 32",
	"metres_per_tile": "dmscript.global:170-173 gc_meters_to_tile=2 / data.gd:23 TILE_M [O]",
	"floor_verbatim": "weapon.script:872 [O] — do not simplify",
}
# [O] weapon.script:58-62 — ONLY these four propagations put a SPEED in
#     physvalue. angle physvalue is DEGREES; slightup is -gravity; stand and
#     immediate are unused. NEVER feed an angle into the speed chain.
const DONOR_FLIGHT_SPEED_PHYS_PROPS := ["fly", "random", "random1", "randomsimulate"]  # [O] weapon.script:58-62
const DONOR_FLIGHT_SPEED_PHYS_CITE := "weapon.script:58-62 [O]; angle=DEGREES, slightup=-gravity, stand/immediate unused"

static func donor_flight_speed_tiles_s(phys: float) -> float:
	# [O]/[D] weapon.script:872 + misc.script:462-466 + dmscript.global:172,175.
	# Reuses the already donor-grounded DEC_U_PX_PER_TILE / DEC_U_FRAMES_PER_TIME
	# mirrors — NO new const is introduced (report §8 item 9).
	return floorf(phys * 1000.0) / DEC_U_PX_PER_TILE * 0.001 * DEC_U_FRAMES_PER_TIME

static func donor_flight_speed_mps(phys: float) -> float:
	# [D] tiles/s x TILE_M (2 m/tile, dmscript.global:170-173). No curve, no dt.
	return donor_flight_speed_tiles_s(phys) * TILE_M

# [D] worked rows per report §3.1 (arithmetic on [O] literals). These are
#     LABELLED DATA for the descriptor handed to the engine (weapon.script:872) —
#     NOT a flight timer: they are NEVER repurposed as `total` (§6.6).
const DONOR_FLIGHT_SPEED_TABLE := {
	20: {"tiles_s": 12.0, "m_s": 24.0, "prototype": "fly (PUSSTRELA phys)", "cite": "weapon.script:872 [D]"},
	25: {"tiles_s": 15.0, "m_s": 30.0, "prototype": "fly (STRELA)", "cite": "weapon.script:872/:1067 [O/D]"},
	38: {"tiles_s": 22.8, "m_s": 45.6, "prototype": "fly (NUCL2PTOW)", "cite": "weapon.script:872/:1057 [O/D]"},
	3: {"tiles_s": 1.8, "m_s": 3.6, "prototype": "random (POINT)", "cite": "weapon.script:872/:1070 [O/D]"},
	4: {"tiles_s": 2.4, "m_s": 4.8, "prototype": "random (NUCLMOSKOL)", "cite": "weapon.script:872/:1066 [O/D]"},
	9: {"tiles_s": 5.4, "m_s": 10.8, "prototype": "random1 (KAPEZ)", "cite": "weapon.script:872/:1095 [O/D]"},
	15: {"tiles_s": 9.0, "m_s": 18.0, "prototype": "fly (OSTRELA)", "cite": "weapon.script:872/:1068 [O/D]"},
}

# ── §2.2 / §3.2 gravity remap VALUES [O]; UNIT explicitly NOT closed [U] ──────
# VALUES already live in DONOR_FLIGHT_GRAVITY_REMAP (data.gd:3157) and the
# fly+arg-2 override in DONOR_FLIGHT_GRAVITY_FLY_ARG2 (:3158). Cited row
# inventory below is additive and inert. weapon.script:877-894:
#   0 -> 2 (`if gravity=0 then gravity:=2`, :894) · 1 -> 2.5 · 2 -> 3.75 ·
#   3 -> 7 (`//5.625` is a DEAD comment) · 4 -> 9.25 · 5 -> 11.5 ·
#   fly + arg-2 -> 11.5 (arrows).
# [U]-N1 THE UNIT IS REFUSED: no px/s^2, tiles/s^2, m/s^2, per-second-vs-per-
#     frame or integrator-order gloss co-occurs with these numbers in
#     weapon.script:877-913 / dmscript.global:688-695. Do NOT name a unit,
#     wire a `g`, or write a 1/2*g*t^2 term anywhere.
const DONOR_FLIGHT_GRAVITY_ROWS := {
	0: {"engine_value": 2.0, "cite": "weapon.script:877-894 [O] zero->2 default (:894)"},
	1: {"engine_value": 2.5, "cite": "weapon.script:877-894 [O]"},
	2: {"engine_value": 3.75, "cite": "weapon.script:877-894 [O]; fly+arg2->11.5 override"},
	3: {"engine_value": 7.0, "cite": "weapon.script:877-894 [O] `//5.625` dead comment"},
	4: {"engine_value": 9.25, "cite": "weapon.script:877-894 [O]"},
	5: {"engine_value": 11.5, "cite": "weapon.script:877-894 [O]"},
}
const DONOR_FLIGHT_GRAVITY_ZERO_DEFAULT := 2.0     # weapon.script:894 [O]
const DONOR_FLIGHT_GRAVITY_UNIT_STATUS := "[U]-N1 engine-internal units ONLY — never physical; no unit/curve/TTL is named"
const DONOR_FLIGHT_ENERGYLOSS_RULE := "EnergyLoss := 1 iff gravity-arg<>0 (weapon.script:911-913 [O]); effect on curve is engine-side [U]-N1"

# ── §2.3 propagation dispatch [O] weapon.script:945-985 ────────────────────────
const DONOR_FLIGHT_PROPAGATION_DISPATCH := {
	"angle": {"id": 5, "throw": "_weapon_ThrowByAngle", "engine_call": "CalcSpeedByDirAndTrgPos",
		"bthrow": true, "collision": "CollisionPriority=10000 + _weapon_OnCollide iff bthrow and bcollisiondetection (:967-973)",
		"note": "aimed arc; direction rotated by `angle` DEGREES about horizontal perpendicular (:807-822,947)",
		"cite": "weapon.script:807-822,945-947,967-973 [O]"},
	"fly": {"id": 3, "throw": "_weapon_ThrowByHSpeed", "engine_call": "CalcDirByHSpeedAndTrgPos",
		"bthrow": true, "collision": "same ON law as angle (:967-973)",
		"note": "flat/levelled aimed flight; script speed from §2.1 (:826-832,951-955)",
		"cite": "weapon.script:826-832,951-955,967-973 [O]"},
	"random": {"id": 2, "throw": "_weapon_ThrowRandom(speed)", "engine_call": "none",
		"bthrow": false, "collision": "OFF (:976-979)",
		"note": "3x RandomExt sphere-ish kick (:838-852,957-960)",
		"cite": "weapon.script:838-852,957-979 [O]"},
	"random1": {"id": 6, "throw": "_weapon_ThrowRandom(speed)", "engine_call": "none",
		"bthrow": false, "collision": "OFF (:976-979)",
		"note": "brotate := random1 and projbasename<>'' and <>'point' (:54)",
		"cite": "weapon.script:54,838-852,957-979 [O]"},
	"randomsimulate": {"id": 7, "throw": "_weapon_ThrowRandom(speed)", "engine_call": "none",
		"bthrow": false, "collision": "OFF",
		"note": "REAL damage later via _misc_ProjSimulatePoint children (doexplode.inc:192-193); Gaussian system miscext2.script:641-728 [O]; port UNPORTED",
		"cite": "weapon.script:957-979 / doexplode.inc:192-193 [O]"},
	"slightup": {"id": 1, "throw": "cPlayOnce instant branch (:988-1033)", "engine_call": "none",
		"bthrow": false, "collision": "OFF",
		"note": "NO throw behaviour for all 40+ registered slightup rows (all time=PlayOnce); scale 0.00001, instant DoExplode+FreeToPool; FX from mount (buseownerfxshot) or prototype; GENERAL-random fx roll explicitly non-sync (:1011)",
		"cite": "weapon.script:988-1033 [O]"},
	"stand": {"id": 0, "throw": "NO throw", "engine_call": "none",
		"bthrow": false, "collision": "n/a (pooled cProjArrowGround visual)",
		"note": "py := RandomExt*0.125, pitch -(30+RandomExt*30) (:1135-1136,1156-1157); STRELDEZ time=FramesToTime(950), STRELDEZPRO PlayOnce",
		"cite": "weapon.script:1135-1136,1156-1157 [O]"},
	"immediate": {"id": 4, "throw": "direct _misc_DoDamage", "engine_call": "none",
		"bthrow": false, "collision": "n/a (no projectile, no flight)",
		"note": "NEVER reaches projectile code (onaclanimationreachedattack.inc:58-60)",
		"cite": "onaclanimationreachedattack.inc:58-60 [O]"},
}
const DONOR_FLIGHT_BCOLLISIONDETECTION_RULE := "bcollisiondetection := (angle or fly) (weapon.script:55 [O])"
const DONOR_FLIGHT_BCHECKFRIEND_DEFAULT := true    # weapon.script:56 [O]
# [O] weapon.script:482-492 — exactly 10 sids opt OUT of bcheckfriendonline.
const DONOR_FLIGHT_BCHECKFRIEND_OPT_OUT := ["STRELA", "OSTRELA", "SHOTMUSKET",  # [O] weapon.script:482-492
	"SHOTBLOCKHOUSE", "NUCLGRE", "PSMPOINTTPUS", "DIMMORT1", "DIMMORT2NEW",
	"PSMPOINTT", "DIMMORT2KOR"]
const DONOR_FLIGHT_BCHECKFRIEND_CITE := "weapon.script:482-492 [O] — FF ray gate, NOT a flight term"

# ── §2.4 / §3.3 time modes + FramesToTime rows [O] ─────────────────────────────
# weapon.script:41-43,900: <0 Infinite (cInfinite=-1), =0 PlayOnce (cPlayOnce),
# >0 timed. Handling (:984-985): cInfinite -> OnStopEvent='OnStopEvent' (ballistic
# end); time>0 -> ALSO GameObjectDelayExecuteStateByHandle(projHnd,'OnStopEvent',
# time) (timed airburst); cPlayOnce -> no behaviour, instant DoExplode+FreeToPool
# (:988-1033). NO other script-side flight timer exists: dist/30, 0.45 s,
# 0.5-1.6 clamp and 512 cap have NO donor counterpart ([O] absence §6.6).
const DONOR_FLIGHT_TIME_MODES := {"cInfinite": -1, "cPlayOnce": 0, "timed": ">0"}  # [O] weapon.script:41-43,900
const DONOR_FLIGHT_TIME_MODE_CITE := "weapon.script:41-43,900,984-985,988-1033 [O]"
const DONOR_FLIGHT_FRAMES_TO_TIME_EXPR := "_misc_FramesToTime(v) = v*0.03125"  # misc.script:470-474 / dmscript.global:175 [O]

# [D] resolved rows; `expr` is the VERBATIM donor time_expr from
# DONOR_WEAPON_PROTOS (never pre-rounded). `frames`/`seconds` are the report's
# [D] arithmetic; every half-to-even tie stays [U]-G1 (X21 20-vector fixture).
const DONOR_FLIGHT_TIME_ROWS := {
	"NUCLM": {"expr": "FramesToTime(2)", "frames": 2, "seconds": 0.0625,
		"cite": "weapon.script:1065 / misc.script:470-474 [O/D]"},
	"STRELDEZ": {"expr": "FramesToTime(950)", "frames": 950, "seconds": 29.59375,
		"cite": "weapon.script:1069 / misc.script:470-474 [O/D]"},
	"PUSSTRELA": {"expr": "FramesToTime(round(2*1.625))", "frames": 3, "seconds": 0.09375,
		"cite": "weapon.script:349-362,1081 [O/D]"},
	"PUSSTRELA1": {"expr": "FramesToTime(round(4*1.625))", "frames": 6, "seconds": 0.1875,
		"cite": "weapon.script:349-362,1082 [O/D] 6.5 bankers [U]-G1"},
	"PUSSTRELA2": {"expr": "FramesToTime(round(8*1.625))", "frames": 13, "seconds": 0.40625,
		"cite": "weapon.script:349-362,1083 [O/D]"},
	"PUSSTRELA3": {"expr": "FramesToTime(round(2*1.625))", "frames": 3, "seconds": 0.09375,
		"cite": "weapon.script:349-362,1084 [O/D]"},
	"PUSSTRELA4": {"expr": "FramesToTime(round(5*1.625))", "frames": 8, "seconds": 0.25,
		"cite": "weapon.script:349-362,1085 [O/D]"},
	"PUSSTRELA5": {"expr": "FramesToTime(round(10*1.625))", "frames": 16, "seconds": 0.5,
		"cite": "weapon.script:349-362,1086 [O/D]"},
	"PUSSTRELA6": {"expr": "FramesToTime(round(15*1.625))", "frames": 24, "seconds": 0.75,
		"cite": "weapon.script:349-362,1087 [O/D]"},
	"PUSSTRELAPUS": {"expr": "FramesToTime(round(2*2.75))", "frames": 6, "seconds": 0.1875,
		"cite": "weapon.script:349-362,1088 [O/D] 5.5 bankers [U]-G1"},
	"PUSSTRELA1PUS": {"expr": "FramesToTime(round(4*2.75))", "frames": 11, "seconds": 0.34375,
		"cite": "weapon.script:349-362,1089 [O/D]"},
	"PUSSTRELA2PUS": {"expr": "FramesToTime(round(8*2))", "frames": 16, "seconds": 0.5,
		"cite": "weapon.script:349-362,1090 [O/D]"},
	"PUSSTRELA3PUS": {"expr": "FramesToTime(round(2*0.5))", "frames": 1, "seconds": 0.03125,
		"cite": "weapon.script:349-362,1091 [O/D]"},
	"PUSSTRELA4PUS": {"expr": "FramesToTime(round(5*0.5))", "frames": 2, "seconds": 0.0625,
		"cite": "weapon.script:349-362,1092 [O/D] 2.5 bankers [U]-G1"},
	"PUSSTRELA5PUS": {"expr": "FramesToTime(round(10*0.5))", "frames": 5, "seconds": 0.15625,
		"cite": "weapon.script:349-362,1093 [O/D]"},
	"PUSSTRELA6PUS": {"expr": "FramesToTime(round(15*0.5))", "frames": 8, "seconds": 0.25,
		"cite": "weapon.script:349-362,1094 [O/D] 7.5 bankers [U]-G1"},
}
static func donor_flight_time_expr_frames(expr: String) -> int:
	# [O]/[D] weapon.script:349-362 + misc.script:470-474. Parses the VERBATIM
	# expr (never pre-rounded); round() goes through the existing donor_round()
	# banker body (data.gd:1213) whose native address stays [U]-G1.
	if not (expr.begins_with("FramesToTime(") and expr.ends_with(")")):
		return -1
	var inner: String = expr.trim_prefix("FramesToTime(").trim_suffix(")")
	if inner.begins_with("round(") and inner.ends_with(")"):
		var arg: String = inner.trim_prefix("round(").trim_suffix(")")
		var product: float = 1.0
		for p in arg.split("*"):
			product *= float(p)
		return donor_round(product)
	return int(inner)

# ── §4.1 TProj fields [O] classes.script:4351-4367 ─────────────────────────────
# Launch (px/py/pz) and aim (dx/dy/dz) are SEPARATE fields: the port's `pos`
# vs `target` split. owner/trg are UNIQUE IDs; ownerpl is the player index;
# ownercid/ownerid/ownerweaponind carry the firing mount; uniqrnd is the stored
# stream key (weapon.script:1185). No DONOR_FF_PRECHECK_* const exists in donor
# text (DEC_U_ff_predict P10): the owner/team gate inputs live HERE, not in a
# table. Absent port keys default 0/0.0 — NO version bump, NO key rename
# (report §8 item 5; wiring is a game.gd-side change, out of scope here).
const DONOR_TPROJ_FIELDS := [
	{"name": "weaponid", "cite": "classes.script:4351-4367 [O]"},
	{"name": "owner", "meaning": "unique id", "cite": "classes.script:4351-4367 [O]"},
	{"name": "trg", "meaning": "locked-target uid; §8 item 5 maps 0 to ground aim", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "px", "meaning": "launch X -> port pos", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "py", "meaning": "launch Y -> port pos", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "pz", "meaning": "launch Z -> port pos", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "dx", "meaning": "aim X -> port target", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "dy", "meaning": "aim Y -> port target", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "dz", "meaning": "aim Z -> port target", "cite": "classes.script:4351-4367 [O] / report §8 item 5"},
	{"name": "ownerpl", "meaning": "player index", "cite": "classes.script:4351-4367 [O]"},
	{"name": "ownercid", "cite": "classes.script:4351-4367 [O]"},
	{"name": "ownerid", "cite": "classes.script:4351-4367 [O]"},
	{"name": "ownerweaponind", "cite": "classes.script:4351-4367 [O]"},
	{"name": "uniqrnd", "meaning": "stored stream key", "cite": "classes.script:4351-4367 / weapon.script:1185 [O]"},
]

# ── §4.2 lifecycle [O] shape, native flight tail [U]-N1 ────────────────────────
const DONOR_TPROJ_LIFECYCLE := [
	{"stage": 1, "law": "animation gate: bProcess client check; weaponid=0 -> direct damage; immediate -> direct damage + pooled FX ghost; else PredictShot allow/deny (:97-109,131-137); DENY applies literal attackdelay := MaxFloat(attackdelay,1) + attackmaxdelay*2 and creates NOTHING (:107-108,135-136)",
		"cite": "onaclanimationreachedattack.inc:1-155 [O]"},
	{"stage": 2, "law": "_unit_DoProjectile scatter -> WriteProj -> _weapon_CreateProjectileByWeaponID resync + field store (TProj.uniqrnd := newuniqrnd, :1185) -> _weapon_InitProjectile behaviour attach",
		"cite": "unit.script:11520-11561 / weapon.script:1039-1192,1185,855-986 [O]"},
	{"stage": 3, "law": "flight: engine TXThrowBehaviour owns position integration",
		"cite": "§6 [U]-N1 — native, no script source"},
	{"stage": 4, "law": "terminate EITHER (a) ballistic end / timed airburst -> OnStopEvent -> DoExplode chain, OR (b) mid-flight OnCollide (aimed angle/fly only) -> trg-switch -> DoExplode, OR (c) PlayOnce instant DoExplode+FreeToPool with no flight at all",
		"cite": "weapon.script:967-973,984-985,988-1033 / doexplode.inc:31-89 [O]"},
]

# ── §2.5 launch geometry / draw ORDER [O] (normative; stream split [U]-F7/N7) ──
const DONOR_FLIGHT_LAUNCH_GEOMETRY := {
	"disp": "firing-mount dispertion in TILES (_unit_DoProjectile, unit.script:11520-11561 [O])",
	"set_random_key": "SetRandomKey(floor(random*gc_MaxInt)) GENERAL (unit.script:11520-11561; gc_MaxInt dmscript.global:815 [O])",
	"scatter": "2x RandomExt iff disp>0 — _weapon_CalcShotDispertion (weapon.script:627-646); box law maxdisp = dist*disp*gc_pixels_to_tile/2000 (tiles); dy := ty (:642, RayCastHeight alt dead)",
	"frnd": "frnd := RandomExt stored for WriteProj AFTER scatter (unit.script:11520-11561 [O])",
	"write": "PlayerExecuteStateByHandle(plHnd,'WriteProj') (unit.script:11520-11561 [O])",
	"shot_point": "floor(RandomExt*count) (weapon.script:1118 [O])",
	"random1_orientation": "6x RandomExt (weapon.script:1151 [O])",
	"stand_draw": "1x RandomExt (weapon.script:1135-1136,1156-1157 [O])",
	"rotspeed": "1x RandomExt iff brotate (weapon.script:936-938 [O])",
	"throw_random": "3x RandomExt (weapon.script:838-852 [O])",
	"uniqrnd_store": "TProj.uniqrnd := newuniqrnd (weapon.script:1185 [O]); newuniqrnd := random GENERAL iff uniqrnd=0 (:1047-1048)",
	"aim_height": "ty via RayCastWater/RayCastHeight (onaclanimationreachedattack.inc:128-129 [O])",
	"cite": "weapon.script:627-646,838-852,936-938,1039-1192,1118,1151,1185 / unit.script:11520-11561 [O]",
}

# ── §4.4 hittable / explode gating [O]; VOLUMES [U]-N4 ─────────────────────────
const DONOR_FLIGHT_HITTABLE_GATE := {
	"in_flight_hittable": "ONLY aimed angle/fly throws with bthrow and bcollisiondetection get CollisionPriority=10000 + _weapon_OnCollide (weapon.script:967-973 [O])",
	"never_midflight_hittable": "random/random1/randomsimulate (bthrow=False), slightup/stand (no behaviour), immediate (no projectile) are NEVER mid-flight hittable — terminus only (weapon.script:976-979,988-1033 [O])",
	"collision_priority": 10000,
	"volume": "[U]-N4 — what 10000 MEANS (priority/radius/order) and the projectile hit volume are ENGINE-side; port 1.2+block_r nearest-in-8 m (app game.gd:5058-5066) is UNGROUNDED",
	"cite": "weapon.script:967-973 [O] / §6.5 [U]",
}
const DONOR_FLIGHT_EXPLODE_GATE := {
	"doexplode": "if damage>0: if TWeapon(pweapon).radius>0 -> _misc_DoRoundDamage(px,pz,radius,damage,owner,trg,kind,False); if bAllowTrgDamage and trgHnd<>0 and ownerHnd<>trgHnd and target alive -> _misc_DoDamage(owner,trg,...) — the locked target takes BOTH (double-dip is donor law)",
	"buildings_immune": "Buildings immune to non-CheckWeaponTargetable propagations (doexplode.inc:73 [O])",
	"dead_target": "dead-target custom-explosion routing (doexplode.inc:148-210 [O])",
	"oncollide_trg_switch": "collision retargets trgHnd BEFORE the same DoExplode chain (doexplode.inc:31-54 [O])",
	"owner_round_exclusion": "owner excluded as dmgHnd in round loop (owner<>dmgHnd, miscext2.script:583) but NOT excluded as locked victim when directly targeted — suicide-by-lock allowed (doexplode.inc:83 [O])",
	"cite": "doexplode.inc:31-54,73,78-89,148-210 / miscext2.script:583 [O]",
}

# ── §4.4 victim cap [O] miscext2.script:562-604 ────────────────────────────────
const DONOR_FLIGHT_ROUND_DAMAGE_RULES := {
	"scan_radius": "r (+cMaxExplMediaR=225/53.3333333=4.21875 tiles when not bsimulation and not barrow) (miscext2.script:562-604 [O])",
	"max_expl_media_tiles": 225.0 / 53.3333333,   # 4.21875 tiles [O]
	"victim_cap_formula": "count = Floor(1 + sqr(r/0.35)) (miscext2.script:562-604 [O])",
	"cap_divisor_tiles": 0.35,
	"nonbuilding_gate": "dist < r+explradius (non-arrow) or dist < r (arrow, plus listcount>300 overflow rule) (miscext2.script:583-604 [O])",
	"wall_splash": "separate engine-adjacent call miscext2.script:240-256 — already [U]-U3, untouched here",
	"cite": "miscext2.script:562-604 [O]",
}
static func donor_round_damage_victim_cap(r_tiles: float) -> int:
	# [O] Floor(1 + sqr(r/0.35)) (miscext2.script:562-604). r is in TILES.
	return int(floorf(1.0 + (r_tiles / 0.35) * (r_tiles / 0.35)))
# [D] report §4.4 sample values of the SAME formula (not new constants).
const DONOR_FLIGHT_VICTIM_CAP_SAMPLES := {0.9375: 8, 1.875: 29}  # [D] report §4.4 / miscext2.script:562-604 [O]

# ── §4.3 PSimulatePoint law [O] miscext2.script:639-728 ────────────────────────
# randomsimulate children ONLY. Port has NO such system: POINTOTVZRIV /
# POINTOTVZRIVFRAME mounts stay unported by construction (report §8 item 7;
# series N6 stays red). Do NOT fake with uniform scatter.
const DONOR_FLIGHT_SIMULATE_POINT := {
	"seed": "floor(RandomExt*100000) (miscext2.script:644 [O])",
	"local_lcg": "a=314159269, c=453806245, m=2147483647 (miscext2.script:648-650 [O])",
	"gauss_seed": "RandomGauss localseed=floor(RandomExt*1000000) (:670); RandomGaussExt (:685) [O]",
	"sigma": [0.25, 0.425],
	"dst_rotation": "RandomExt*360 (:718) [O]",
	"dst_limit_tiles": 1.3,
	"damagetime_window_s": [0.275, 0.64],
	"damagetime_expr": "0.275+... (0.275-0.64 s window, :716) [O]",
	"ring_slots": 2048,
	"ring": "gProjSimulatePoints 2048-slot ring, resolved in _misc_ProjSimulatePointsProgress via _misc_DoRoundDamage(...,True) [O]",
	"cite": "miscext2.script:641-728 / doexplode.inc:192-193 [O]",
}
const DONOR_FLIGHT_SIMULATE_LCG := {"a": 314159269, "c": 453806245, "m": 2147483647}  # [O] miscext2.script:648-650

# ── §5 aim-side snap [O] / contact side [U]-N5 ─────────────────────────────────
const DONOR_FLIGHT_AIM_SNAP := {
	"attack_point": "attack-point shots snap ty through RayCastWater/RayCastHeight (onaclanimationreachedattack.inc:128-129 [O])",
	"dispertion": "_weapon_CalcShotDispertion keeps dy := ty; commented RayCastHeight alternative is DEAD (weapon.script:627-646 [O])",
	"law": "dispersion NEVER changes height — the aim point Y is the snapped terrain/water height",
	"contact": "[U]-N5 — which surface (terrain/water/building AABB), the terminating threshold, water delay and splash-vs-crater FX are all ENGINE-side; no script line states them",
}

# ── §6 / §7 NATIVE BOUNDARY — every remaining item stays [U] ───────────────────
const DONOR_FLIGHT_NATIVE_UNVERIFIED := {
	"integrator": "[U]-N1 — TXThrowBehaviour per-frame update has NO recovered address/pseudocode/script gloss (packed exe, §0-P2); no curve is invented",
	"gravity_unit": "[U]-N1 — six remap values + overrides are the complete donor statement; no divisor/dt/unit co-occurs; NEVER name a unit",
	"time_step": "[U]-N7 — 32 fps frame clock is [O] (dmscript.global:174-175); per sim-frame vs render-frame vs sub-stepped is NOT stated",
	"energy_loss": "[U]-N1 — EnergyLoss := 1 iff gravity-arg<>0 is a set flag (weapon.script:911-913 [O]); effect unstated; no drag modelled",
	"ground_water_contact": "[U]-N5 — aim-side ty snap is [O]; surface/threshold/water-FX are ENGINE-side",
	"collision_volume": "[U]-N4 — CollisionPriority=10000 + OnCollide gating [O]; meaning of 10000, hit volume and test order native",
	"port_total_cap_fx": "[U]-N1/N2/N7 — dist/speed + clampf(0.5,1.6), 0.45 s arrow and 512 cap have NO donor counterpart ([O] absence §6.6); crater/hit FX at p.target (app game.gd:5067-5073) is UNGROUNDED — TAG, do not tune",
	"port_fx": "[U]-N5 — surface FX (splash vs crater) ungrounded; no surface rule wired",
	"airburst_total": "[U]-N3 — donor time rows (§3.3) are airburst/despawn timers via DelayExecuteState, NOT flight-duration estimates; never repurpose them as `total`",
	"simulate_points": "[U]-N6 — port has no simulate-point system; do not fake with uniform scatter",
}

# [O] §7 harness + termination criterion, verbatim. Fixed camera, flat map,
# seeded rng, sim assertions only. ANY mismatch keeps the item [U] and forbids
# wiring; ZERO mismatches across the FULL series closes it. Never fit/invent a
# gravity unit or curve — §2 input law + §3 conversions are the only shapes.
const DONOR_FLIGHT_SHOT_SERIES_HARNESS := "General harness (all series): fixed camera (frozen camera3d, no shake — sim assertions read projectiles[].t/total/target / entities[].hp / cooldown, never pixels). Flat test map (all height==h0), actors S (shooter) + T (target), seeded sim rng re-seeded per series. Termination criterion (all): run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item [U] and forbids wiring; zero mismatches across the full series closes it. Never fit/invent a gravity unit or curve — the §2 input law + §3 conversions are the only admissible shapes; series constrain BEHAVIOUR, not units."
const DONOR_FLIGHT_SHOT_SERIES_N := {
	"N1": "Series N1-FLT: flat map, cannon (PPOINTT / phys n/a — angle path via CalcSpeedByDirAndTrgPos) vs ground aim T at 10/20/30/40 m, 50 shots each (200). Record per-shot total + landing target + (if exposed) mid-flight pos samples. Expectation: landing inside the §2.5 scatter box (maxdisp_m = dist_m*dispertion_px/2000, cannon idx0 225 px [O] unit.script:1708); total consistent with donor speed table order (12 t/s-class flight, NOT dist/30); no NaN, no outside-box landing. Any outside-box/NaN -> stays [U]. Mid-flight samples are TELEMETRY ONLY (no curve fitted, no gravity unit named).",
	"N2": "Series N2-FLY: archer (STRELA-profile, fly, phys 25) vs ground aim at 10/20/30 m, 50 shots each (150). Expectation: same box law (archer 175 px [O]), flight ordered by 30 m/s donor speed; total MUST differ from the current fixed 0.45 s on at least one range (else the 0.45 s is falsified but nothing is wired — item stays [U] until a behaviour-matching replacement passes the full series with zero mismatches).",
	"N3": "Series N3-BURST: PUSSTRELA-profile (e.g. round(2*1.625)=3 -> 0.09375 s) vs target BEYOND ballistic reach, 50 shots. Expectation: burst at donor-time (via donor_round-exact value, bankers caveat [U]-G1) with full round+locked-target damage at the burst point (doexplode.inc:78-89 law). Zero mismatches -> wireable as total=time for timed rows ONLY; any -> [U].",
	"N4": "Series N4-HIT: two targets 1.5 m apart crosswise/downrange inside the dispersion box at mid flight path, 100 shots per geometry (300); plus owner-inside-own-radius geometry, 30 shots. Expectation: (i) random/slightup/stand/immediate profiles NEVER retarget mid-flight (terminus-only); (ii) angle/fly retarget per doexplode.inc:31-54 trg-switch (not port nearest-in-8 m — systematic always-nearest = mismatch); (iii) owner takes NO round damage (owner<>dmgHnd) but CAN take locked-target damage when targeted; (iv) victim counts obey Floor(1+sqr(r/0.35)). Zero mismatches -> wireable; any -> [U].",
	"N5": "Series N5-SURF: ground aim vs water aim (same dist), 50 shots each (100), flat map with a water patch. Expectation (minimal): terminus OnStopEvent fires for BOTH (no hang/no NaN/no infinite t); landing target inside the scatter box in both cases. Surface-FX delta (splash vs crater) is TELEMETRY ONLY — no FX rule wired on this series. Any hang/NaN/outside-box -> [U].",
	"N6": "Series N6-SIM: NUCLMOSKOL-profile impact, record 200 child impact points + damage times. Expectation: Box-Muller sigma=0.425 clamp pattern, dst <= 1.3 tiles, damagetime in [0.275,0.64] s (per DEC_U_damage_height §7/§9-U6). KS-test p>0.01 AND bound violations=0 -> wireable verbatim; else [U]. Do NOT fake with uniform scatter.",
	"N7": "Series N7-STEP: sustained cannon fire (600 shots, cap would bite at 512) at fixed 32 Hz sim step, then at 2x step. Expectation: NO 512-drop (every shot yields a terminus event — port currently drops -> known mismatch, stays [U]); t accumulates in seconds; step-doubling does not change landing boxes (engine determinism probe — landing outside box at either step -> [U]).",
}

# ─── DEC-U MOVE-SPEED — INERT DONOR LOCOMOTION DATA / TELEMETRY ────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_move_speed.md
#   §1 constants / dead consumers · §2 accel-negative · §3 rotate law ·
#   §4 terrain-negative · §5 formation/carry/walk · §6 speedperc ·
#   §7 S1-S6 change list · §8 seven fixed-seed traces · §10 claim register.
# [O] donor text observation · [D] exact arithmetic over [O] ·
# [I] reading / unproven unit · [U] unresolved, named trace, ZERO wiring.
# EVERY declaration below is INERT DATA/TELEMETRY: no consumer reads it, no
# behaviour changes, NO DONOR PARITY IS CLAIMED. Donor text was read READ-ONLY;
# no donor binary was executed, no donor bytes copied. Network OUT OF SCOPE.
# This block does NOT touch the VISION/SHIELD/COLL/VICTORY/DAMAGE/RNG/FLIGHT/
# INERTIA/GUARD lanes above; those stay byte-identical.

# §1.1 canonical per-sid speed constants [O] dmscript.global:603-620.
# px is [O]; m/s and tiles/s are [D] over px/26.6666666 and px/53.3333333
# (dmscript.global:170-175). The px/s UNIT is [I] per app/MECHANICS.md:238 —
# donor text states no unit, so NO donor unit claim is made here.
# DEFINED-BUT-UNCONSUMED [D]: unit.script:618 forces objbase.speed := 1 for
# every sid; all per-sid writes are //dead (DONOR_SPEED_DEAD_WRITES below).
# NEVER activate. Report P8-T prose says 18 constants; §1.1 enumerates 17
# rows (dmscript.global:603-620, :611 not listed). Both carried as TEXT.
# [U] U-speed-consumer / T-SPEED.
const DONOR_SPEED_CONSTANTS := {
	"default": {"px": 32, "m_s": 1.20, "tiles_s": 0.60, "cite": "dmscript.global:603 gc_obj_speed_default"},
	"peasant": {"px": 40, "m_s": 1.50, "tiles_s": 0.75, "cite": "dmscript.global:604 gc_obj_speed_peasant"},
	"hardhorse": {"px": 56, "m_s": 2.10, "tiles_s": 1.05, "cite": "dmscript.global:605 gc_obj_speed_hardhorse"},
	"fasthorse": {"px": 96, "m_s": 3.60, "tiles_s": 1.80, "cite": "dmscript.global:606 gc_obj_speed_fasthorse"},
	"cannon": {"px": 20, "m_s": 0.75, "tiles_s": 0.375, "cite": "dmscript.global:607 gc_obj_speed_cannon"},
	"mortar": {"px": 24, "m_s": 0.90, "tiles_s": 0.45, "cite": "dmscript.global:608 gc_obj_speed_mortar"},
	"howitzer": {"px": 20, "m_s": 0.75, "tiles_s": 0.375, "cite": "dmscript.global:609 gc_obj_speed_howitzer"},
	"multicannon": {"px": 16, "m_s": 0.60, "tiles_s": 0.30, "cite": "dmscript.global:610 gc_obj_speed_multicannon"},
	"fishboat": {"px": 16, "m_s": 0.60, "tiles_s": 0.30, "cite": "dmscript.global:612 gc_obj_speed_fishboat"},
	"ferry": {"px": 28, "m_s": 1.05, "tiles_s": 0.525, "cite": "dmscript.global:613 gc_obj_speed_ferry"},
	"yacht": {"px": 40, "m_s": 1.50, "tiles_s": 0.75, "cite": "dmscript.global:614 gc_obj_speed_yacht"},
	"yachttur": {"px": 70, "m_s": 2.625, "tiles_s": 1.3125, "cite": "dmscript.global:615 gc_obj_speed_yachttur"},
	"chaika": {"px": 55, "m_s": 2.0625, "tiles_s": 1.03125, "cite": "dmscript.global:616 gc_obj_speed_chaika"},
	"galley": {"px": 40, "m_s": 1.50, "tiles_s": 0.75, "cite": "dmscript.global:617 gc_obj_speed_galley"},
	"frigate": {"px": 30, "m_s": 1.125, "tiles_s": 0.5625, "cite": "dmscript.global:618 gc_obj_speed_frigate"},
	"xebec": {"px": 28, "m_s": 1.05, "tiles_s": 0.525, "cite": "dmscript.global:619 gc_obj_speed_xebec"},
	"battleship": {"px": 16, "m_s": 0.60, "tiles_s": 0.30, "cite": "dmscript.global:620 gc_obj_speed_battleship"},
	"status": "[O]/[D] TEXT ONLY — DEFINED-BUT-UNCONSUMED [D]; no sampled live consumer; [U] U-speed-consumer (T-SPEED)",
}

# §7 S1 — exact ship constants, DATA ONLY. NEVER substituted into the port's
# UNITS_BASE naval `speed` rows, which keep their PORT ESTIMATES (NOT
# donor-verbatim) flag. Ships 16-70 px: 16/28/40/70/55/40/30/28/16.
const DONOR_SHIP_SPEED_CONST := {
	"fishboat": 16, "ferry": 28, "yacht": 40, "yachttur": 70,
	"chaika": 55, "galley": 40, "frigate": 30, "xebec": 28, "battleship": 16,
	"cite": "dmscript.global:612-620 [O]; m/s = px/26.6666666 [D] in DONOR_SPEED_CONSTANTS",
	"status": "DATA ONLY — DEFINED-BUT-UNCONSUMED [D]; no consumer; [U] U-speed-consumer (T-SPEED)",
}

# §1.3 [O] live value + dead writes. The only LIVE write is :618; the class
# default 32 (classes.script:3594-3600) is overwritten unconditionally.
const DONOR_SPEED_LIVE_VALUE := {
	"live": 1,
	"class_default": 32,
	"live_cite": "unit.script:617-618 _unit_InitBase: objbase.shield := 0; objbase.speed := 1",
	"class_cite": "classes.script:3594-3600 TObjBase.Create: speed := gc_obj_speed_default (=32)",
	"serial_pin": "serial.script:516 speed := 1 for gSerialVersion<91",
	"status": "[D] after InitBase every sid's objbase.speed is 1; the §1.1 table has no sampled live consumer",
}
# Report prose says 17 per-sid writes; the §1.3 enumeration lists the 18 site
# numbers below. Both are carried verbatim as TEXT — no count is invented.
const DONOR_SPEED_DEAD_WRITES := {
	"sites": [1192, 1322, 1420, 1546, 1699, 1735, 1767, 1796, 1826,
		1857, 1875, 1906, 1924, 1961, 1991, 2001, 2015, 2035],
	"cite": "unit.script:1192-2037 [O] — every per-sid objbase.speed := is `//`-commented dead text",
	"status": "[O] zero live per-sid writes outside unit.script:618; [U] U-speed-consumer-a (full-tree .speed := sweep, recipe §9(i))",
}

# §3.1 [O] LIVE rotate-speed constants (dmscript.global:622-628). Unlike §1
# these writes are LIVE (no // prefix). :622 keeps the old C1 value 16 as a
# // comment; the LIVE default is 5.
const DONOR_ROTATE_SPEEDS := {
	"default": 5, "cannon": 1, "mortar": 4, "howitzer": 4,
	"multicannon": 5, "ships": 2,
	"cite": "dmscript.global:623-628 [O]; default classes.script:3660; cannon unit.script:1701/:1828; mortar :1770; howitzer :1737; multicannon :1798; ships :1859/:1877/:1926/:1963/:2037",
	"old_c1_dead": "dmscript.global:622 `//16` — dead C1 value, NOT the live default",
	"status": "[O] LIVE constants + LIVE consumer; native integration [U] U-turn (T-TURN)",
}
# §3.3 [O] the one sampled LIVE consumer, verbatim argument list.
const DONOR_ROTATE_LAW := {
	"expr": "rotatespeed*2.225, 50, epsilon, True",
	"call": "GameObjectSetupRotatingToDirectionByHandle(hnd, dx, dy, dz, anim, anim, anim, gObjProp[...].rotatespeed*2.225, 50, GetGameObjectEpsilonAngleByHandle(hnd), True)",
	"cite": "unit.script:11066 (DoSetupMoveAnimation tail) [O]; siblings :10996/:11001, miscext.script gates, control.script:444 idle gate",
	"status": "[O] donor-verbatim; entry is engine-native with ZERO binary strings (P3) and 0-xref XTrackPoint (P7) — timing/signature [U] U-turn (T-TURN)",
}
# §3.2 [O] motion styles — what they change natively is [U] U-motionstyle.
const DONOR_MOTIONSTYLES := {
	"default": 0, "ship": 1, "slowrotate": 2,
	"cite": "dmscript.global:296-300 [O]; artillery writes unit.script:1698/:1734/:1766/:1825 = slowrotate; ships :1861/:1879/:1928/:1965/:2039 = ship; default classes.script:3664",
	"status": "[O] values live; native effect [U] U-motionstyle (P5 strings x0)",
}

# §6 [O] the only LIVE speed-mutating path — recorded as cited DATA ONLY.
# objbase.speed is a DESCENDING INTERVAL DIVISOR, not a velocity.
const DONOR_SPEED_DIVISOR_INIT := 1.0   # unit.script:618; serial.script:516 [O]
const DONOR_UPG_SPEEDPERC := {
	"ships28": 40,
	"cite": "country.script:3639 upgplace+'.28' with gc_upg_type_speedperc; dmscript.global:759 (upgrade TYPE id 22) [O]",
	"note": "40 is the PERCENT value; 22 is the upgrade TYPE id — do not conflate",
}
const DONOR_SPEED_FORMULA := "s := 1/(s*(1+v/100)); Floor(moveI*s); Floor(turnI*s)"  # player.script:1930-1943 [O]
const DONOR_SPEED_FORMULA_DETAIL := {
	"divisor": "s := 1/(s*(1+v/100))",
	"rewrite": "Floor(moveI*s); Floor(turnI*s)",
	"cite": "player.script:1930 divisor, :1936-1943 interval rewrite [O]",
	"skip_guard": "(speed>0) and (speed<>1) at :1938 [O]",
	"water_gate": "{and _unit_IsWaterUnit(trgHnd)} at :1938 — {…} DSL semantics ambiguous; [U] U-upg-gate (T-UPG)",
	"stacking": "[U] U-upg-stack: s=1,v=40 -> 1/1.4=0.7142857; a second application -> 1.0 (OSCILLATION, not compounding) [D]; stacking unsampled",
	"status": "DATA ONLY — NO consumer wired; gate any future wiring behind T-UPG with ZERO mismatches",
}

# §2/§4/§5 [O-negative] ZERO donor rows — no invented values, no new scalars.
const DONOR_MOVE_SPEED_ZERO_ROWS := {
	"accel": "no accel/decel/ramp/MaxSpeed locomotion row in sampled lib (P11-T grep x0); only projectile Deceleration/RotationSpeed weapon.script:924/:934-939 [O-negative]; [U] U-accel (T-ACCEL)",
	"terrain_cost": "no terrain/slope/water/swamp/road speed multiplier in sampled lib (P11-T grep x0); movement gates are BINARY (miscext.script:280/:380/:459/:527/:558, unit.script:6091-6093/:10804) [O-negative]; [U] U-terrain (T-TERRAIN)",
	"formation_speed": "no formation/squad/march speed factor (group.script:115-160 is POSITION pitch; formations.cfg bonuses are damage/shield only) [O-negative]; [U] U-formation (T-FORM)",
	"carry_speed": "no resamount/carry/loaded speed scalar (unit.script:2687/:5544/:9658-9661 credit restotal, economy) [O-negative]; [U] U-carry (T-CARRY)",
	"status": "[O-negative] absence agreement only, NOT a positive donor law. Port approximations (DRUMMER_SPEED_BONUS +12%, routing x1.35, PERSONAL_SPACE 0.35, FORMATION_SPACING 1.2, FORMATIONS shape mults) stay LABELLED and unchanged; remove/gate only when T-FORM/T-CARRY close",
}

# §5.1/§5.3 [O] position-pitch + animation cadence, DATA ONLY (not velocity).
const DONOR_FORMATION_PITCH := "unitRadius*0.8, dispRadius=*0.5, min*=4 (group.script:131-148)"  # [O]; 8/12 px formation-radius constants are //dead
const DONOR_WALK_INTERVALS := {
	"inf": 1.25, "hardhorse": 1.25, "fasthorse": 1.0, "donkey": 1.4, "exc_748": 1.12,
	"cite": "unit.script:595-598 constants, :640-2065 live writes, classes.script:3667 default=1 [O]",
	"consumer": "SetGameObjectIntervalFactorByHandle (unit.script:11054-11173) — ANIM playback cadence, not proven velocity [O]; [U] U-walkinterval (T-SPEED logs anim rate)",
	"status": "DATA ONLY — port BUILD_HIT_INTERVAL=1.25 reuse is a PORT APPROXIMATION, not donor velocity",
}

# DATA-ONLY resolver: exact donor m/s only for an explicitly cited §1.1 row;
# null means UNRESOLVED, not a bucket fallback. NO consumer is wired — this
# NEVER sets a unit speed and is never called by gameplay code.
static func donor_speed_m_s(sid: String) -> Variant:
	var row: Variant = DONOR_SPEED_CONSTANTS.get(sid, null)
	if row is Dictionary and (row as Dictionary).has("m_s"):
		return float((row as Dictionary)["m_s"])
	return null

# §8 — SEVEN fixed-seed traces. TERMINATION (all): run the FULL stated series;
# ANY single positional/temporal mismatch vs the stated donor expectation
# keeps the item [U] and FORBIDS wiring; ZERO mismatches across the FULL
# series closes it. Never fit/invent a rate, ramp, scalar or gate. Assertions
# read positions/handles, never pixels. Harness: singleplayer skirmish, fixed
# map seed (randkey0/1), flat open ground (T-TERRAIN excepted), fixed camera,
# headless fixed-dt = 1/32 s, seeded RNG re-seeded per series, canonical JSON
# state hash. No parity claim: no same-camera donor/port A/B was produced.
const DONOR_MOVE_SPEED_TERMINATION := "run the FULL stated series; ANY single positional/temporal mismatch vs the stated donor expectation keeps the item [U] and forbids wiring; zero mismatches across the FULL series closes it. Never fit or invent a rate, ramp, scalar or gate."
const DONOR_MOVE_SPEED_TRACES := {
	"T-SPEED": "U-speed-consumer: one unit per class (peasant, foot, hardhorse, fasthorse, cannon, mortar, howitzer, multicannon, all 7 ship sids), straight 20 m march (ships 40 m), no orders/formation/aura/upgrades. Log per-tick (pos, tick). Pass = middle-50% mean velocity matches its §1.1 [D] m/s cell within ±1 tick / ±0.05 m, 0 mismatches across 5 trials x 15 classes; first mismatch stops with its capture id. Decides whether ANY §1.1 constant is the live speed.",
	"T-TURN": "U-turn/U-motionstyle: foot, cannon (slowrotate rate 1), ship (ship rate 2); from standstill order 90 deg then 180 deg facing changes, no translation. Log per-tick facing + translation-start tick. Pass = turn-duration ordering matches 5 < 4 < 2 < 1 (ships slowest), 0 mismatches across 10 trials x 3 classes; records whether *2.225 predicts absolute durations (asserted, never fitted).",
	"T-ACCEL": "U-accel: foot + fasthorse + cannon; from mmNone order 10 m march. Log first 32 ticks of (pos, per-tick displacement). Pass = 0 mismatches vs the step hypothesis (first-tick displacement already v*dt within quantisation) across 10 trials x 3 classes; any systematic ramp keeps [U] and NOTHING is wired.",
	"T-TERRAIN": "U-terrain: foot unit marches 20 m across (a) flat, (b) max-slope climbable, (c) shallow-water edge lane, (d) bridge deck. Log transit ticks per lane. Pass = all four lanes within ±1 tick (null-cost), 0 mismatches across 10 trials; any systematic delta is filed as a MEASURED table, never a fitted scalar.",
	"T-FORM": "U-formation: 12-foot squad in LINE8 vs 12 solo feet over 20 m, then LINE3 vs COLUMN. Log per-unit arrival ticks + slot offsets. Pass = squad mean arrival within ±2 ticks of solo AND offsets match the unitRadius*0.8/*0.5 pitch, 0 mismatches; any formation speed delta keeps [U].",
	"T-CARRY": "U-carry: peasant 10 m storehouse<->tree shuttles empty then full (resamount>0 both legs), 20 round trips. Pass = loaded and empty leg ticks identical within ±1 tick, 0 mismatches; any delta keeps [U].",
	"T-UPG": "U-upg-gate/U-upg-stack: 40 m sail baseline per ship sid x5, apply aca.28-class speedperc 40, sail again, then (if permitted) a second speedperc. Log TrackPoint move/turn intervals + transit ticks. Pass = post intervals equal Floor(pre*(1/1.4)), 0 mismatches AND land intervals unchanged (decides the {and _unit_IsWaterUnit} gate); stacking run decides oscillation vs compounding. Until green, NOTHING from §6 is wired.",
}
const DONOR_MOVE_SPEED_UNRESOLVED := {
	"U-speed-consumer": "[U] DEFINED-BUT-UNCONSUMED [D]: no live sampled consumer of §1.1 table; unit.script:618 forces 1 and 17/18 per-sid writes are //dead. Terminator T-SPEED (zero mismatches).",
	"U-turn": "[U] native rotate integration (rotatespeed*2.225, 50, epsilon, True) unrecovered; P3 x0 / P7 0-xref. Terminator T-TURN.",
	"U-motionstyle": "[U] slowrotate vs ship native effect unrecovered. Terminator T-TURN.",
	"U-accel": "[U] zero donor accel rows [O-negative]; port step integrator is absence-agreement only. Terminator T-ACCEL.",
	"U-terrain": "[U] zero donor terrain-cost rows [O-negative]; donor gates are binary. Terminator T-TERRAIN.",
	"U-formation": "[U] zero donor formation-speed rows [O-negative]. Terminator T-FORM.",
	"U-carry": "[U] zero donor carry-speed rows [O-negative]. Terminator T-CARRY.",
	"U-walkinterval": "[U] walkintervalfactor is anim cadence, not proven velocity. Logged in T-SPEED.",
	"U-upg-gate": "[U] {and _unit_IsWaterUnit} brace semantics DSL-ambiguous. Terminator T-UPG.",
	"U-upg-stack": "[U] divisor oscillation vs compounding unsampled. Terminator T-UPG.",
	"no_parity_claim": "NO same-camera donor/port A/B frame was produced or examined; every port visual motion claim is DENIED.",
}

# ─── DEC-U-CARRY §§1-4 — DONOR CARRY LAW (data-only telemetry mirror) ───────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_carry.md (read-only donor
#     text pass 2026-11-26; donor binary NEVER executed). Every value below is
#     [O] donor file:line or [D] deterministic reading of [O]; [U] items keep
#     their fixed-seed trace in DONOR_CARRY_TRACES. NO PARITY CLAIM.
# INERT DATA / TELEMETRY ONLY: nothing below is read by the sim, nothing changes
#     a default, a gate, a capacity, a rate or a save field. The port's uniform
#     GATHER_BASE interval, its partial-load credit and its carry/resamount
#     placeholders stay LABELLED [U] and byte-identical (see PORT_APPROX below).

# §1 [O] capacity is a PURE FUNCTION of restype / live objbase.fishingmax —
#     NO per-sid/per-unit carry table exists anywhere in the donor scripts.
const DONOR_CARRY_HITSNEEDED := {"food": 22, "wood": 14, "stone": 20, "else": 10}
const DONOR_CARRY_HITSNEEDED_CITE := "_res_GetHitsNeeded case (res.script:348-358, arms :352-356); consts food/wood/stone = 22/14/20 (dmscript.global:799-801); else 10 (:355-356) [O]"
const DONOR_CARRY_CLAMP_CITE := "_unit_CheckReturnToStorehouse: hitsneeded := _res_GetHitsNeeded(restype); if resamount >= hitsneeded then resamount := hitsneeded (unit.script:9657-9661) [O]; init resamount := 0 / restype := none (:2687-2688) [O]"
const DONOR_CARRY_NO_PER_SID_TABLE := "[O-negative] capacity has NO sid key: field units key off restype (res.script:351-356), fish boats off live gPlayer[pl].objbase[cid][id].fishingmax (unit.script:11936-11942). Any port table keyed by sid invents law — do not build one."
static func donor_carry_hitsneeded(restype: String) -> int:
	# INERT resolver: verbatim donor case, no consumer, no port default changed.
	return int(DONOR_CARRY_HITSNEEDED.get(restype, DONOR_CARRY_HITSNEEDED["else"]))

# §1 [O] fisher twin: same full-load clamp, own capacity/rate from objbase.
const DONOR_CARRY_FISHINGMAX_BASE := 1000   # objbase.fishingmax := 1000 (unit.script:1866) [O]
const DONOR_CARRY_FISHINGSPEED_BASE := 12   # 50 div 4 (unit.script:1865) [O]
const DONOR_CARRY_FISHER_CAPACITY_CITE := "_unit_GetFishBoatMaxCapacity reads live objbase.fishingmax per (cid,id) (unit.script:11936-11942); clamp resamount := capacity at return-to-port (unit.script:11951-11954) [O]; upgrade scaling is a commented pattern (:11933-11934) + res-efficiency arms (player.script:1812-1831) — per-sid post-upgrade values [U] U-FISH"

# §2 [O] +1 per hit; node debit differs by resource; credit ONLY on full load.
const DONOR_CARRY_INCREMENT_PER_HIT := 1    # resamount := resamount+1 (onaclanimationreachedwork.inc:50) [O]
const DONOR_CARRY_INCREMENT_GATE_CITE := "OnAclAnimationReachedWork gate: bProcess := not(_net_IsClient or _net_IsReplay) AND orders[0].itype = gainres (:8-9); restype := node.itype (:49); SwitchTo('Nothing') tail re-arms the next work event (:59) [O]"
const DONOR_CARRY_NODE_DEBIT := {
	"food": "resdec := Max(1, floor(100/(1+fieldlife/100))); hp := hp-resdec (onaclanimationreachedwork.inc:24-26) [O]; fieldlife default 0 (player.script:110) => 1/hit in base game [D]",
	"wood": "hp := hp-1; death state tag when hp=0 (:33-35) [O]",
	"stone": "hp := hp-1; no death-tag arm (:42) [O]",
	"cite": "onaclanimationreachedwork.inc:20-46 [O] — node-side debit only; NO portion applied at gather time",
}
const DONOR_CARRY_PORTION := {"food": 45, "wood": 28, "stone": 40, "else": 20}
const DONOR_CARRY_EFF_DEFAULT := 100         # player.script:109 [O]; per-(cid,restype) :9559
const DONOR_CARRY_CREDIT_CITE := "amount := (_unit_GetPeasantResPortion(restype)*eff) div 100 (unit.script:9557-9560); portions food/wood/stone = 45/28/40, else 20 (:9546-9552; dmscript.global:804-806) [O]; eff = gPlayer[pl].resefficiency[cid][restype], Integer percent default 100 (:9559; player.script:109) [O]; _res_AddResToPlayerByIndex + stat.restotal += amount (:9567-9569) [O]"
const DONOR_CARRY_FULL_LOAD_ONLY := "credit happens ONLY on arrival at the store with resamount >= hitsneeded: credit full portion*eff div 100, then restype := none; resamount := 0 (unit.script:9702-9713) [O]; partial loads are never credited"

# §2 [O-shape / U-rate] work cadence = one AAF window per Work event @30 fps.
const DONOR_CARRY_AAF_FPS := 30
const DONOR_CARRY_AAF_WORK_WINDOWS := {
	"peaukr": {"workfood": 22, "workwood": 18, "workstone": 18},
	"pearus": {"workfood": 24, "workwood": 18, "workstone": 18},
	"cite": "peaukr.aaf workfood 278..299 (22 f ~0.733 s), workwood 237..254 / workstone 217..234 (18 f = 0.6 s); pearus.aaf workfood 281..304 (24 f = 0.8 s), wood/stone spans identical to ukr [O] (DEC-U-CARRY §2, tool-attach §2.2)",
	"ratio": "[D] ukr food ~22% slower than wood/stone; rus food ~9% slower than ukr food",
}
const DONOR_CARRY_WORK_NO_NUMBERCYCLE := "peasant.acl:2140-2166 work rows are bare AnimationName + ExecuteState with NO NumberCycle (attack rows carry NumberCycle=1) [O] => one Work event per animation-cycle completion, re-armed by the SwitchTo('Nothing') tail (work.inc:59) [D]"
const DONOR_CARRY_INTERVAL_FACTOR := "[U] U-CAD: no SetGameObjectIntervalFactorByHandle on the work path (calls only on walk/death/attack); engine default factor unproven — do NOT assert 1 as donor law"
const DONOR_CARRY_FISHER_STEP_CITE := "continuous, NOT per-hit: addFish := fishingspeed*deltaTime + orders[0].info.progress; addFishInt := Floor(addFish); resamount += addFishInt; progress := addFish-addFishInt (unit.script:12113-12117) [O]; base rate 12/s (50 div 4, :1865) [O]; no animation event involved"

# §3 [O / O-negative] drop law: full-load credit, partial retained, death loses load.
const DONOR_CARRY_DROP_LAW := {
	"field": "arrival dstSqr < 0.5 vs storehouse.pos + resourcePoint (unit.script:9702-9705); with resamount >= hitsneeded credit then restype := none / resamount := 0 (:9712-9713); re-target same node or clear order (:9715-9747) [O]",
	"partial": "resamount < hitsneeded -> extract branch, re-search each tick (:9828); nothing found and standtime > 59 -> targetnotvalid + SetSTO(0)/ClearOrders + idle tags (:9889-9893); _unit_ClearOrder touches only order slots (unit.script:2756-2808), NEVER resamount/restype => partial load stays on the unit, uncredited [O]",
	"reorder": "OrderGainResource zeroes resamount ONLY when the new restype differs (unit.script:5541-5545) [O] — same-restype reorder keeps the load; different restype silently discards it",
	"death": "ondeath.inc stops walk sounds, drops scenario-list membership, SwitchTo('Nothing'), _unit_DestroyObj; _unit_DestroyObj (miscext2.script:4205-4267) never reads/writes resamount — the carried load VANISHES with the unit [O-negative]",
	"fisher": "dstSqr < gc_gameplay_resourceDropRadiusSqr (16) vs port resource point (unit.script:12027-12033): credit fishingmax + restotal[food], resamount := 0 (:12035-12037), retarget (0.5+random)*gc_fisher_radius_move_change (:12039) [O]; same death rule [O-negative]",
	"mine": "gold/iron/coal income accrues while inside the mine (miscext2.script:4629-4632); field resamount law does NOT cross that boundary in either implementation [O]",
}

# §4 [O] seven RNG draws — route-only; none touches an amount, portion, capacity or credit.
const DONOR_CARRY_RNG_DRAWS := {
	"R1": "progresstick := floor(RandomExt*32) (unit.script:2707, init) — tick-phase jitter only",
	"R2": "rmax := food_radiusmaxSqr*random while walking (unit.script:9788-9792) — in-range gate this tick, food only",
	"R3": "standtime>=9 or random>0.9 -> search radius := searchradius*(0.3+standtime/5), clamp 2x (unit.script:9821-9827)",
	"R4": "search throttle random<waitrnd (gc_obj_res_searchwaitrnd=0.65), bskipcheck := random>0.75, rndind := floor(random*count) (unit.script:4052-4062/:4114-4120)",
	"R5": "angle := random*360, up to 20 tries with water/scancell check (unit.script:11970-11989) — fisher working/chase position",
	"R6": "(0.5+random)*15.0 post-delivery / idle retarget (unit.script:12039/:12090)",
	"R7": "SetGameObjectIntervalFactorByHandle(..., 0.7+random*0.6) on death (ontagstates.inc:599) — visual desync only",
	"status": "[D] no draw touches an amount, portion, capacity or credit: quantities are deterministic given the event sequence; randomness only routes WHICH node / WHEN a tick engages. Fixed-seed traces must fix the seed AND log R2-R6.",
}

# §5/§6 [U] port approximations stay labelled and byte-identical; five fixed-seed
#     traces decide whether any of them may ever be rewired (zero mismatches only).
const DONOR_CARRY_PORT_APPROX := {
	"interval": "PORT APPROXIMATION [U] U-CAD: GATHER_BASE interval 1.25 is uniform for all three resources; donor cadence is a per-(action,nation) AAF window @30 fps (22/18/18 ukr, 24 food rus), not a uniform rate",
	"resamount": "PORT APPROXIMATION [U] U-PART/_tick_gather: carry += 1 with a min(carry,hits) ratio credit and no stored clamp; donor is +1/hit, clamp at hitsneeded, credit only on full load (no ratio)",
	"reston": "PORT APPROXIMATION [U] U-PART: node-empty partial-load handling / rest-on-node standstill is not the donor standtime>59 order-clear-with-load law; game.gd-side, out of scope for this file",
	"fisher": "PORT APPROXIMATION [U] U-FISH: no producer fills e.resamount today; donor is the continuous per-tick floor(rate*dt+progress) accumulator",
	"status": "no capacity, rate, portion or gate is invented here; do not relabel these as donor-grounded until their trace closes with ZERO mismatches",
}
const DONOR_CARRY_TRACES := {
	"T-CAD": "U-CAD: fixed seed, 1 ukr + 1 rus peasant per resource, log OnAclAnimationReachedWork event ticks for 30 hits each. Oracle: +1 per event; inter-hit gaps = AAF window/30 s +/-1 tick. Termination: 90/90 gaps match AND the uniform 1.25 interval is replaced by a per-(action,nation) table; until then 1.25 stays [U].",
	"T-PART": "U-PART: fixed seed, deplete a food node at carry 7/22; log order/retarget/carry every tick for 90 s sim. Oracle: no credit; retarget-or-wait; order cleared only after standtime>59 with carry=7 intact; same-res reorder keeps 7; different-res reorder zeroes. Termination: tick-exact 3/3 runs.",
	"T-FISH": "U-FISH: fixed seed, 1 fishboat, log resamount per tick to full + delivery tick + retarget radius (0.5+r)*15. Oracle: floor(12*dt+progress) accumulation; credit exactly 1000 at dstSqr<16; resamount := 0. Termination: tick-exact 3/3 runs.",
	"T-CAP": "U-CAP: else -> 10 is DEAD in practice (gold/iron/coal route to mines); no trace required — keep documented only. Reopen only if a field-gather order with a non-food/wood/stone restype is ever observed.",
	"T-DEATH": "U-DEATH: load-on-death negative proven in text (no transfer anywhere in ondeath.inc / _unit_DestroyObj); no trace needed — absence agreement. Reopen only if a resamount write is found in a death path.",
}
const DONOR_CARRY_UNRESOLVED := {
	"U-CAP": "[O] else -> 10 quoted; no port branch, dead in practice (T-CAP: no trace required)",
	"U-CAD": "[O-shape] windows quoted; engine default interval factor unproven (T-CAD) — 1.25 stays PORT APPROXIMATION",
	"U-PART": "[O] partial-load / reorder / standtime law quoted; port partial-credit path is out of scope for data.gd (T-PART)",
	"U-FISH": "[O] base 12/s + 1000 quoted; per-sid upgrades / per-boat capacity / water-ring fallback unread (T-FISH)",
	"U-DEATH": "[O-negative] load vanishes, port _kill already matches (T-DEATH: no trace needed)",
	"no_parity_claim": "NO donor binary executed, NO GPU A/B frame captured, NO port capture compared by this worker. Closed items rest on donor text [O] with file:line; open items list the exact settling trace above.",
}

# ══════════════════════════════════════════════════════════════════════════════
# ─── DEC-U-UPGRADE-MATRIX §§1-6 — DONOR UPGRADE-PACK MATRIX (INERT TELEMETRY) ──
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_upgrade_matrix.md
#   §1 generator law (TUpgStruct/setters/AddUpgradePack/append/sentinel) [O] ·
#   §§2-3 the complete 157-row `_aus` column (A/B/S/D/C/H/E/P/U + 6 explicit
#   sword rows), all six-cost tuples with file:line [O] · §4 tur/alg gold
#   overrides + cannon/howitzer 320f-vs-1000f split [O] · §5 [U] captures ·
#   §6 port change list (CITES ONLY — NOT adopted here).
# Pin t_87f0f3c130b0: donor cossacks.exe / country.script read READ-ONLY as TEXT;
#   no donor binary executed, copied or opened as target. NO PARITY CLAIM.
# [O] verbatim donor literal with file:line · [D] deterministic reading or
#   arithmetic over [O] (frames * 0.03125) · [U] unresolved with exact capture.
# INERT DATA / TELEMETRY ONLY: no consumer reads any DONOR_UPG_* declaration;
#   no UPGRADES_BASE value, gate, key or save version is changed and NOTHING is
#   wired into live upgrade behaviour. Every §6 anchor is recorded as a cite,
#   never adopted: all port numeric time/cost rows stay PORT APPROXIMATION.
# This APPEND preserves the VISION/SHIELD/COLL/VICTORY/DAMAGE/RNG/FLIGHT/
#   INERTIA/GUARD/MOVE/CARRY lanes byte-for-byte (proof: .bak-UPGMATRIX prefix).
# No neighbour extrapolation, no invented cost/time, no test weakening: the
#   [U] items keep their fixed-seed ZERO-MISMATCH captures in DONOR_UPG_UNRESOLVED.
# ══════════════════════════════════════════════════════════════════════════════

# ── §1 [O] generator law — append cursor / SID / level / link-to-next-nonzero ──
# This is the labelled PROVENANCE BLOCK: it states the mechanical law by which
# every row in DONOR_UPG_AUS_ROWS below was emitted. No row is inferred from a
# neighbouring nation or a neighbouring tier.
const DONOR_UPG_GENERATOR_LAW := {
	"struct": "TUpgStruct{place, member, req[0..5], value[0..5], food[0..5], wood[0..5], stone[0..5], gold[0..5], iron[0..5], coal[0..5]}",
	"struct_cite": "country.script:821-848 [O] EV-M-STRUCT",
	"reset": "ResetUpgStruct zeroes place, member and all six arrays (value/food/wood/stone/gold/iron/coal[0..5])",
	"reset_cite": "country.script:833-847 [O]",
	"setters": {
		"SetUpgStructFoodGold": "per slot (value, food, gold) — country.script:849-858 [O]",
		"SetUpgStructFoodGoldIron": "per slot (value, food, gold, iron) — country.script:859-864 [O]",
		"SetUpgStructFoodGoldIronCoal": "per slot (value, food, gold, iron, coal) — country.script:865-871 [O]",
	},
	"setter_note": "Three setters differ ONLY in the trailing resource tuple. Unmentioned resources stay 0 after Reset. Per-slot Boolean params b0..b5 are ACCEPTED and DROPPED [D]: TUpgStruct has no Boolean field and AddUpgradePack never reads them. All b params are True on every cited line; NO semantics are assigned.",
	"setter_cite": "country.script:849-871 [O] EV-M-SET",
	"pack_loop": "for j=0..5: skip slot iff value[j]=0; else emit ONE row",
	"pack_loop_cite": "country.script:872-925, :877 [O] EV-M-PACK",
	"itype": "iupgtype := damage/protection + iparam1..3 weapon kinds per upgradetype; iupgtype2 := 1 for damage types, 2 for protection types",
	"itype_cite": "country.script:880,883-916 [O]",
	"sid": "SID := place.member.iupgtype2.(j+1) — j is 0-based so tiers are .1..6",
	"level": "level := j+2 — the first emitted tier is L2, never L1",
	"enabled": "enabled := (j = 0) and bEnabled — only the first tier of a pack starts enabled",
	"time_frames": "time := 500 FRAMES for every slot emitted by AddUpgradePack (before any post-pack overwrite)",
	"cost_order": "cost := (food[j], wood[j], stone[j], gold[j], iron[j], coal[j]) — RES_NAMES order, no field omitted",
	"access_req": "access req := req[0..1]",
	"emit_cite": "country.script:920 [O] EV-M-PACK",
	"link_law": "Chain each emitted row to the next NONZERO slot (j+1..5); a zero slot is skipped and skipped over, it does not sever the chain",
	"link_cite": "country.script:921-922 [O]",
	"unknown_type": "else ErrorLog('AddUpgradePack : Unknown type')",
	"unknown_type_cite": "country.script:917-918 [O]",
	"append": "_country_AddUpgrade resolves the index, calls _country_SetUpgrade (price copy :626-631; time := FramesToTime(time) :632; bindividual := False :636), registers the SID into upgradeplace and increments the append cursor ind := ind+1",
	"append_cite": "country.script:654-670, :626-631, :632, :636, :668 [O] EV-M-APPEND",
	"sentinel": "_country_ModifyUpgrade writes value/price fields ONLY if the argument <> -1; -1 is the sentinel KEEP value and is NEVER 0",
	"sentinel_cite": "country.script:599-615 [O] EV-M-DELTA",
	"delta_target": "A tur/alg gold override applied at ind-1 targets the JUST-EMITTED row [D]",
	"place_sequence": ["bar :935", "ba2 :1204", "sta :1500", "ba2 :1884", "sta :1930", "bar :2013,2023", "ba2 :2032", "bar :2039", "sta :2185"],
	"place_cite": "country.script:935,1204,1500,1884,1930,2013,2023,2032,2039,2185 [O] EV-M-PLACE",
	"sta2_absence": "[O-negative] no `sta2` upgplace exists: repo-wide `upgplace :=` grep finds only bar/ba2/sta; 18c stables rows KEEP upgplace aussta",
	"status": "[O]/[D] PROVENANCE ONLY — governs the cited transcription; no generator is executed and no live upgrade gate is changed.",
}

# ── §1 / ROWS [O]/[D] frames-to-seconds law + attested overwrites ──────────────
const DONOR_UPG_TIME_LAW := {
	"law": "seconds = frames * 0.03125",
	"law_cite": "_misc_FramesToTime (dmscript.global:174, ROWS EV-R-TIME) [O]; product is [D]",
	"attested_frames_s": {"500": 15.625, "1500": 46.875, "750": 23.4375, "250": 7.8125, "320": 10.0, "1000": 31.25},
	"attested_cite": "500 country.script:920 [O]; 1500 :1173/:1198/:1471/:1495 [O]; 750 and 250 :1538-1539/:1563-1564 [O]; 320 and 1000 :3783-3794/:3834-3845 [O]",
	"status": "TEXT LAW. The port's 8.0/10.0/12.0/... seconds set is NEVER asserted as donor.",
}

# ── §§2-3 pack pairings — struct line -> pack call, place/member/type [O] ─────
# One entry per cited `SetUpgStruct` -> `AddUpgradePack` pair plus the explicit
# sword block. `tf` is the PRE-OVERWRITE pack time (500 unless noted); the
# overwrites are repeated on the affected rows in DONOR_UPG_AUS_ROWS.
const DONOR_UPG_PACK_META := {
	"A1": {"place": "ausbar", "member": "pikeman", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":953", "pack": ":975", "x": 0, "y": 1, "tf": 500, "cite": "country.script:947,:953,:975 [O]"},
	"A2": {"place": "ausbar", "member": "pikeman", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":977", "pack": ":1004", "x": 0, "y": 2, "tf": 500, "note": "tmptype :1000", "cite": "country.script:977,:1000,:1004 [O]"},
	"A3": {"place": "ausbar", "member": "roundshier", "itype": "ctypeDamageSword", "setter": "SetUpgStructFoodGold", "struct": ":1017", "pack": ":1021", "x": 1, "y": 1, "tf": 500, "cite": "country.script:1008,:1017,:1021 [O]"},
	"A4": {"place": "ausbar", "member": "roundshier", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGoldIron", "struct": ":1023", "pack": ":1027", "x": 1, "y": 2, "tf": 500, "cite": "country.script:1023,:1027 [O]"},
	"A5": {"place": "ausbar", "member": "musketeeraus", "itype": "ctypeDamageBullet", "setter": "SetUpgStructFoodGold", "struct": ":1050", "pack": ":1073", "x": 2, "y": 1, "tf": 500, "note": "posx :1046", "cite": "country.script:1031,:1046,:1050,:1073 [O]"},
	"A6": {"place": "ausbar", "member": "musketeeraus", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGoldIron", "struct": ":1075", "pack": ":1098", "x": 2, "y": 2, "tf": 500, "note": "all 6 slots nonzero", "cite": "country.script:1075,:1098 [O]"},
	"A7": {"place": "ausbar", "member": "drummer", "itype": "ctypeProtection drummerdef", "setter": "SetUpgStructFoodGold", "struct": ":1113", "pack": ":1135", "x": 4, "y": 2, "tf": 500, "cite": "country.script:1108,:1113,:1135 [O]"},
	"A8": {"place": "ausbar", "member": "officer", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1150", "pack": ":1172", "x": 5, "y": 1, "tf": 1500, "note": "time overwrite :1173 -> 46.875", "cite": "country.script:1145,:1150,:1172,:1173 [O]"},
	"A9": {"place": "ausbar", "member": "officer", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":1175", "pack": ":1197", "x": 5, "y": 2, "tf": 1500, "note": "time overwrite :1198 -> 46.875", "cite": "country.script:1175,:1197,:1198 [O]"},
	"B1": {"place": "ausba2", "member": "pikeman18", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1217", "pack": ":1238", "x": 0, "y": 1, "tf": 500, "cite": "country.script:1212,:1217,:1238 [O]"},
	"B2": {"place": "ausba2", "member": "pikeman18", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":1240", "pack": ":1261", "x": 0, "y": 2, "tf": 500, "cite": "country.script:1240,:1261 [O]"},
	"B3": {"place": "ausba2", "member": "musketeer18", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1288", "pack": ":1310", "x": 2, "y": 1, "tf": 500, "cite": "country.script:1283,:1288,:1310 [O]"},
	"B4": {"place": "ausba2", "member": "musketeer18", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":1312", "pack": ":1333", "x": 2, "y": 2, "tf": 500, "cite": "country.script:1312,:1333 [O]"},
	"B5": {"place": "ausba2", "member": "grenadier", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1352", "pack": ":1373", "x": 3, "y": 1, "tf": 500, "note": "last row .1.6 retargeted to grenadedmg/mortarball :1374-1376", "cite": "country.script:1347,:1352,:1373,:1374-1376 [O]"},
	"B6": {"place": "ausba2", "member": "grenadier", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":1378", "pack": ":1399", "x": 3, "y": 2, "tf": 500, "cite": "country.script:1378,:1399 [O]"},
	"B7": {"place": "ausba2", "member": "drummer18", "itype": "ctypeProtection drummerdef", "setter": "SetUpgStructFoodGold", "struct": ":1414", "pack": ":1435", "x": 4, "y": 2, "tf": 500, "cite": "country.script:1408-1409,:1414,:1435 [O]"},
	"B8": {"place": "ausba2", "member": "officer18", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1449", "pack": ":1470", "x": 5, "y": 1, "tf": 1500, "note": "time overwrite :1471 -> 46.875", "cite": "country.script:1443-1444,:1449,:1470,:1471 [O]"},
	"B9": {"place": "ausba2", "member": "officer18", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":1473", "pack": ":1494", "x": 5, "y": 2, "tf": 1500, "note": "time overwrite :1495 -> 46.875", "cite": "country.script:1473,:1494,:1495 [O]"},
	"S1": {"place": "aussta", "member": "reiter", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1515", "pack": ":1536", "x": 0, "y": 1, "tf": 750, "note": "overwrite :1538-1539 -> all 6 rows 23.4375", "cite": "country.script:1510,:1515,:1536,:1538-1539 [O]"},
	"S2": {"place": "aussta", "member": "reiter", "itype": "ctypeProtection horsedef", "setter": "SetUpgStructFoodGoldIron", "struct": ":1541", "pack": ":1562", "x": 0, "y": 2, "tf": 250, "note": "overwrite :1563-1564 -> all 6 rows 7.8125", "cite": "country.script:1541,:1562,:1563-1564 [O]"},
	"D1": {"place": "aussta", "member": "dragoon", "itype": "ctypeDamageBullet", "setter": "SetUpgStructFoodGold", "struct": ":1634", "pack": ":1657", "x": 2, "y": 1, "tf": 500, "note": "bEnabled True :1656; link sever :1658-1667 heads containing sta.dragoon.1.3", "cite": "country.script:1629,:1634,:1656,:1657,:1658-1667 [O]"},
	"D2": {"place": "aussta", "member": "dragoon", "itype": "ctypeProtection horsedef", "setter": "SetUpgStructFoodGold", "struct": ":1670", "pack": ":1692", "x": 2, "y": 2, "tf": 500, "cite": "country.script:1670,:1692 [O]"},
	"C1": {"place": "aussta", "member": "cuirassier", "itype": "ctypeDamagePike", "setter": "SetUpgStructFoodGold", "struct": ":1710", "pack": ":1731", "x": 3, "y": 1, "tf": 500, "cite": "country.script:1705,:1710,:1731 [O]"},
	"C2": {"place": "aussta", "member": "cuirassier", "itype": "ctypeProtection horsedef", "setter": "SetUpgStructFoodGoldIron", "struct": ":1733", "pack": ":1754", "x": 3, "y": 2, "tf": 500, "cite": "country.script:1733,:1754 [O]"},
	"H1": {"place": "aussta", "member": "hussar", "itype": "ctypeDamageSword", "setter": "SetUpgStructFoodGoldIron", "struct": ":1771", "pack": ":1792", "x": 4, "y": 1, "tf": 500, "note": "food 0 on early tiers is verbatim", "cite": "country.script:1766,:1771,:1792 [O]"},
	"H2": {"place": "aussta", "member": "hussar", "itype": "ctypeProtection", "setter": "SetUpgStructFoodGold", "struct": ":1794", "pack": ":1815", "x": 4, "y": 2, "tf": 500, "cite": "country.script:1794,:1815 [O]"},
	"E1": {"place": "aussta", "member": "dragoon18", "itype": "ctypeDamageBullet", "setter": "SetUpgStructFoodGold", "struct": ":1833", "pack": ":1854", "x": 5, "y": 1, "tf": 500, "note": "2nd access req = century18", "cite": "country.script:1828,:1833,:1854 [O]"},
	"E2": {"place": "aussta", "member": "dragoon18", "itype": "ctypeProtection horsedef", "setter": "SetUpgStructFoodGold", "struct": ":1856", "pack": ":1877", "x": 5, "y": 2, "tf": 500, "cite": "country.script:1856,:1877 [O]"},
	"P1": {"place": "ausba2", "member": "pandur", "itype": "ctypeDamageBullet", "setter": "SetUpgStructFoodGold", "struct": ":1898", "pack": ":1905", "x": 1, "y": 1, "tf": 500, "note": "upgplace back to ba2 :1884", "cite": "country.script:1884,:1886,:1898,:1905 [O]"},
	"P2": {"place": "ausba2", "member": "pandur", "itype": "ctypeProtection infdef", "setter": "SetUpgStructFoodGold", "struct": ":1918", "pack": ":1925", "x": 1, "y": 2, "tf": 500, "cite": "country.script:1918,:1925 [O]"},
	"U1": {"place": "aussta", "member": "croat", "itype": "ctypeDamageSword (aus; only pol/swe remap to pike)", "setter": "SetUpgStructFoodGold", "struct": ":1947", "pack": ":1957", "x": 1, "y": 1, "tf": 500, "cite": "country.script:1930,:1932,:1943-1945,:1947,:1955-1956,:1957 [O]"},
	"U2": {"place": "aussta", "member": "croat", "itype": "ctypeProtection horsedef", "setter": "SetUpgStructFoodGold", "struct": ":1959", "pack": ":1966", "x": 1, "y": 2, "tf": 500, "cite": "country.script:1959,:1966 [O]"},
	"SW": {"place": "ausbar", "member": "roundshier", "itype": "explicit AddUpgradeWithAccessControl (NOT a pack)", "setter": "n/a", "struct": "n/a", "pack": ":2126-2135", "x": 0, "y": 0, "tf": 500, "note": "6 explicit rows, en=False, links :2129-2130 and :2134-2135", "cite": "country.script:2039,:2115,:2126-2135 [O]"},
}

# ── §§2-3 [O] the complete 157-row `_aus` column, keyed by donor SID ─────────────
# `cost` is the SIX-tuple [food, wood, stone, gold, iron, coal] (RES_NAMES order).
# `tf`/`ts` are the donor FRAME literal and its [D] seconds (frames * 0.03125).
# `value` is the donor per-slot value literal — B5 `.1.6` value 1500 is DAMAGE,
#   NOT a time. `en` is the generator's enabled flag; `lvl` = j+2 [O].
# Every tuple is verbatim at its cited country.script line; NOT one value is
#   borrowed from a neighbouring nation or a neighbouring tier. The six
#   explicit sword rows carry `"explicit": true` and their own :21xx cites.
# PORT ADOPTION OF ANY VALUE IS [U] (R-MATRIX-aus) — see DONOR_UPG_UNRESOLVED.
const DONOR_UPG_AUS_ROWS := {
	"ausbar.pikeman.1.1": {"pack": "A1", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [200, 0, 0, 50, 0, 0], "cite": "country.script:953,:975 [O]"},
	"ausbar.pikeman.1.2": {"pack": "A1", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [1300, 0, 0, 300, 0, 0], "cite": "country.script:953,:975 [O]"},
	"ausbar.pikeman.1.3": {"pack": "A1", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [3600, 0, 0, 450, 0, 0], "cite": "country.script:953,:975 [O]"},
	"ausbar.pikeman.1.4": {"pack": "A1", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [7200, 0, 0, 1850, 0, 0], "cite": "country.script:953,:975 [O]"},
	"ausbar.pikeman.1.5": {"pack": "A1", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [16030, 0, 0, 2000, 0, 0], "cite": "country.script:953,:975 [O]"},
	"ausbar.pikeman.2.1": {"pack": "A2", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [150, 0, 0, 50, 0, 0], "cite": "country.script:977,:1000,:1004 [O]"},
	"ausbar.pikeman.2.2": {"pack": "A2", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [900, 0, 0, 175, 0, 0], "cite": "country.script:977,:1004 [O]"},
	"ausbar.pikeman.2.3": {"pack": "A2", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [4500, 0, 0, 300, 0, 0], "cite": "country.script:977,:1004 [O]"},
	"ausbar.pikeman.2.4": {"pack": "A2", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [9005, 0, 0, 507, 0, 0], "cite": "country.script:977,:1004 [O]"},
	"ausbar.pikeman.2.5": {"pack": "A2", "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [18010, 0, 0, 3050, 0, 0], "cite": "country.script:977,:1004 [O]"},
	"ausbar.roundshier.1.1": {"pack": "A3", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [150, 0, 0, 50, 0, 0], "cite": "country.script:1017,:1021 [O]"},
	"ausbar.roundshier.1.2": {"pack": "A3", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1500, 0, 0, 200, 0, 0], "cite": "country.script:1017,:1021 [O]"},
	"ausbar.roundshier.1.3": {"pack": "A3", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [1300, 0, 0, 325, 0, 0], "cite": "country.script:1017,:1021 [O]"},
	"ausbar.roundshier.2.1": {"pack": "A4", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [200, 0, 0, 70, 120, 0], "cite": "country.script:1023,:1027 [O]"},
	"ausbar.roundshier.2.2": {"pack": "A4", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [4360, 0, 0, 150, 320, 0], "cite": "country.script:1023,:1027 [O]"},
	"ausbar.roundshier.2.3": {"pack": "A4", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [506, 0, 0, 250, 420, 0], "cite": "country.script:1023,:1027 [O]"},
	"ausbar.musketeeraus.1.1": {"pack": "A5", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 100, 0, 0], "cite": "country.script:1046,:1050,:1073 [O]"},
	"ausbar.musketeeraus.1.2": {"pack": "A5", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1000, 0, 0, 300, 0, 0], "cite": "country.script:1050,:1073 [O]"},
	"ausbar.musketeeraus.1.3": {"pack": "A5", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [500, 0, 0, 700, 0, 0], "cite": "country.script:1050,:1073 [O]"},
	"ausbar.musketeeraus.2.1": {"pack": "A6", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [170, 0, 0, 50, 100, 0], "cite": "country.script:1075,:1098 [O]"},
	"ausbar.musketeeraus.2.2": {"pack": "A6", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [405, 0, 0, 150, 200, 0], "cite": "country.script:1075,:1098 [O]"},
	"ausbar.musketeeraus.2.3": {"pack": "A6", "lvl": 4, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1570, 0, 0, 100, 350, 0], "cite": "country.script:1075,:1098 [O]"},
	"ausbar.musketeeraus.2.4": {"pack": "A6", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1556, 0, 0, 550, 100, 0], "cite": "country.script:1075,:1098 [O]"},
	"ausbar.musketeeraus.2.5": {"pack": "A6", "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1060, 0, 0, 850, 400, 0], "cite": "country.script:1075,:1098 [O]"},
	"ausbar.musketeeraus.2.6": {"pack": "A6", "lvl": 7, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [3700, 0, 0, 750, 700, 0], "cite": "country.script:1075,:1098 [O]"},
	"ausbar.drummer.2.1": {"pack": "A7", "lvl": 2, "value": 12, "en": true, "tf": 500, "ts": 15.625, "cost": [706, 0, 0, 50, 0, 0], "cite": "country.script:1113,:1135 [O]"},
	"ausbar.officer.1.1": {"pack": "A8", "lvl": 2, "value": 20, "en": true, "tf": 1500, "ts": 46.875, "cost": [100, 0, 0, 50, 0, 0], "cite": "country.script:1150,:1172 + overwrite :1173 [O]"},
	"ausbar.officer.2.1": {"pack": "A9", "lvl": 2, "value": 6, "en": true, "tf": 1500, "ts": 46.875, "cost": [1850, 0, 0, 450, 0, 0], "cite": "country.script:1175,:1197 + overwrite :1198 [O]"},
	"ausbar.roundshier.1.4": {"pack": "SW", "explicit": true, "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [7500, 0, 0, 900, 0, 0], "cite": "country.script:2126 [O]"},
	"ausbar.roundshier.1.5": {"pack": "SW", "explicit": true, "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [9000, 0, 0, 1080, 0, 0], "cite": "country.script:2127 [O]"},
	"ausbar.roundshier.1.6": {"pack": "SW", "explicit": true, "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [18750, 0, 0, 2250, 0, 0], "cite": "country.script:2128 [O]"},
	"ausbar.roundshier.2.4": {"pack": "SW", "explicit": true, "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [3750, 0, 0, 450, 0, 0], "cite": "country.script:2131 [O]"},
	"ausbar.roundshier.2.5": {"pack": "SW", "explicit": true, "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [6750, 0, 0, 810, 0, 0], "cite": "country.script:2132 [O]"},
	"ausbar.roundshier.2.6": {"pack": "SW", "explicit": true, "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [9375, 0, 0, 1125, 0, 0], "cite": "country.script:2133 [O]"},
	"ausba2.pikeman18.1.1": {"pack": "B1", "lvl": 2, "value": 2, "en": true, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 800, 0, 0], "cite": "country.script:1217,:1238 [O]"},
	"ausba2.pikeman18.1.2": {"pack": "B1", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [8000, 0, 0, 1200, 0, 0], "cite": "country.script:1217,:1238 [O]"},
	"ausba2.pikeman18.1.3": {"pack": "B1", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [20000, 0, 0, 2500, 0, 0], "cite": "country.script:1217,:1238 [O]"},
	"ausba2.pikeman18.1.4": {"pack": "B1", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [32000, 0, 0, 2800, 0, 0], "cite": "country.script:1217,:1238 [O]"},
	"ausba2.pikeman18.1.5": {"pack": "B1", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [32000, 0, 0, 3800, 0, 0], "cite": "country.script:1217,:1238 [O]"},
	"ausba2.pikeman18.1.6": {"pack": "B1", "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [40500, 0, 0, 4800, 0, 0], "cite": "country.script:1217,:1238 [O]"},
	"ausba2.pikeman18.2.1": {"pack": "B2", "lvl": 2, "value": 2, "en": true, "tf": 500, "ts": 15.625, "cost": [1500, 0, 0, 500, 0, 0], "cite": "country.script:1240,:1261 [O]"},
	"ausba2.pikeman18.2.2": {"pack": "B2", "lvl": 3, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [7000, 0, 0, 1500, 0, 0], "cite": "country.script:1240,:1261 [O]"},
	"ausba2.pikeman18.2.3": {"pack": "B2", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [37000, 0, 0, 2000, 0, 0], "cite": "country.script:1240,:1261 [O]"},
	"ausba2.pikeman18.2.4": {"pack": "B2", "lvl": 5, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [37000, 0, 0, 5500, 0, 0], "cite": "country.script:1240,:1261 [O]"},
	"ausba2.pikeman18.2.5": {"pack": "B2", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [37000, 0, 0, 5500, 0, 0], "cite": "country.script:1240,:1261 [O]"},
	"ausba2.pikeman18.2.6": {"pack": "B2", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [64600, 0, 0, 5500, 0, 0], "cite": "country.script:1240,:1261 [O]"},
	"ausba2.musketeer18.1.1": {"pack": "B3", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [1000, 0, 0, 800, 0, 0], "cite": "country.script:1288,:1310 [O]"},
	"ausba2.musketeer18.1.2": {"pack": "B3", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1500, 0, 0, 800, 0, 0], "cite": "country.script:1288,:1310 [O]"},
	"ausba2.musketeer18.1.3": {"pack": "B3", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 800, 0, 0], "cite": "country.script:1288,:1310 [O]"},
	"ausba2.musketeer18.1.4": {"pack": "B3", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [2500, 0, 0, 800, 0, 0], "cite": "country.script:1288,:1310 [O]"},
	"ausba2.musketeer18.1.5": {"pack": "B3", "lvl": 6, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [3000, 0, 0, 800, 0, 0], "cite": "country.script:1288,:1310 [O]"},
	"ausba2.musketeer18.1.6": {"pack": "B3", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [3500, 0, 0, 800, 0, 0], "cite": "country.script:1288,:1310 [O]"},
	"ausba2.musketeer18.2.1": {"pack": "B4", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [3706, 0, 0, 350, 0, 0], "cite": "country.script:1312,:1333 [O]"},
	"ausba2.musketeer18.2.2": {"pack": "B4", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [11030, 0, 0, 1350, 0, 0], "cite": "country.script:1312,:1333 [O]"},
	"ausba2.musketeer18.2.3": {"pack": "B4", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [35706, 0, 0, 4000, 0, 0], "cite": "country.script:1312,:1333 [O]"},
	"ausba2.musketeer18.2.4": {"pack": "B4", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [36556, 0, 0, 4350, 0, 0], "cite": "country.script:1312,:1333 [O]"},
	"ausba2.musketeer18.2.5": {"pack": "B4", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [30060, 0, 0, 1350, 0, 0], "cite": "country.script:1312,:1333 [O]"},
	"ausba2.musketeer18.2.6": {"pack": "B4", "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [37600, 0, 0, 1350, 0, 0], "cite": "country.script:1312,:1333 [O]"},
	"ausba2.grenadier.1.1": {"pack": "B5", "lvl": 2, "value": 2, "en": true, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 800, 0, 0], "cite": "country.script:1352,:1373 [O]"},
	"ausba2.grenadier.1.2": {"pack": "B5", "lvl": 3, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [12000, 0, 0, 1800, 0, 0], "cite": "country.script:1352,:1373 [O]"},
	"ausba2.grenadier.1.3": {"pack": "B5", "lvl": 4, "value": 4, "en": false, "tf": 500, "ts": 15.625, "cost": [32000, 0, 0, 2800, 0, 0], "cite": "country.script:1352,:1373 [O]"},
	"ausba2.grenadier.1.4": {"pack": "B5", "lvl": 5, "value": 5, "en": false, "tf": 500, "ts": 15.625, "cost": [42000, 0, 0, 3800, 0, 0], "cite": "country.script:1352,:1373 [O]"},
	"ausba2.grenadier.1.5": {"pack": "B5", "lvl": 6, "value": 6, "en": false, "tf": 500, "ts": 15.625, "cost": [52000, 0, 0, 4800, 0, 0], "cite": "country.script:1352,:1373 [O]"},
	"ausba2.grenadier.1.6": {"pack": "B5", "lvl": 7, "value": 1500, "en": false, "tf": 500, "ts": 15.625, "cost": [62000, 0, 0, 15800, 0, 0], "cite": "country.script:1352,:1373 + retarget :1374-1376 (value 1500 = DAMAGE, not time) [O]"},
	"ausba2.grenadier.2.1": {"pack": "B6", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [3706, 0, 0, 350, 0, 0], "cite": "country.script:1378,:1399 [O]"},
	"ausba2.grenadier.2.2": {"pack": "B6", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [11030, 0, 0, 1350, 0, 0], "cite": "country.script:1378,:1399 [O]"},
	"ausba2.grenadier.2.3": {"pack": "B6", "lvl": 4, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [35706, 0, 0, 3000, 0, 0], "cite": "country.script:1378,:1399 [O]"},
	"ausba2.grenadier.2.4": {"pack": "B6", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [36556, 0, 0, 3350, 0, 0], "cite": "country.script:1378,:1399 [O]"},
	"ausba2.grenadier.2.5": {"pack": "B6", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [30060, 0, 0, 1350, 0, 0], "cite": "country.script:1378,:1399 [O]"},
	"ausba2.grenadier.2.6": {"pack": "B6", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [64000, 0, 0, 1350, 0, 0], "cite": "country.script:1378,:1399 [O]"},
	"ausba2.drummer18.2.1": {"pack": "B7", "lvl": 2, "value": 15, "en": true, "tf": 500, "ts": 15.625, "cost": [706, 0, 0, 50, 0, 0], "cite": "country.script:1414,:1435 [O]"},
	"ausba2.officer18.1.1": {"pack": "B8", "lvl": 2, "value": 30, "en": true, "tf": 1500, "ts": 46.875, "cost": [1000, 0, 0, 800, 0, 0], "cite": "country.script:1449,:1470 + overwrite :1471 [O]"},
	"ausba2.officer18.2.1": {"pack": "B9", "lvl": 2, "value": 12, "en": true, "tf": 1500, "ts": 46.875, "cost": [1706, 0, 0, 350, 0, 0], "cite": "country.script:1473,:1494 + overwrite :1495 [O]"},
	"aussta.reiter.1.1": {"pack": "S1", "lvl": 2, "value": 1, "en": true, "tf": 750, "ts": 23.4375, "cost": [500, 0, 0, 100, 0, 0], "cite": "country.script:1515,:1536 + overwrite :1538-1539 [O]"},
	"aussta.reiter.1.2": {"pack": "S1", "lvl": 3, "value": 2, "en": false, "tf": 750, "ts": 23.4375, "cost": [900, 0, 0, 220, 0, 0], "cite": "country.script:1515,:1536 + overwrite :1538-1539 [O]"},
	"aussta.reiter.1.3": {"pack": "S1", "lvl": 4, "value": 1, "en": false, "tf": 750, "ts": 23.4375, "cost": [4400, 0, 0, 280, 0, 0], "cite": "country.script:1515,:1536 + overwrite :1538-1539 [O]"},
	"aussta.reiter.1.4": {"pack": "S1", "lvl": 5, "value": 1, "en": false, "tf": 750, "ts": 23.4375, "cost": [2250, 0, 0, 320, 0, 0], "cite": "country.script:1515,:1536 + overwrite :1538-1539 [O]"},
	"aussta.reiter.1.5": {"pack": "S1", "lvl": 6, "value": 1, "en": false, "tf": 750, "ts": 23.4375, "cost": [3030, 0, 0, 600, 0, 0], "cite": "country.script:1515,:1536 + overwrite :1538-1539 [O]"},
	"aussta.reiter.1.6": {"pack": "S1", "lvl": 7, "value": 1, "en": false, "tf": 750, "ts": 23.4375, "cost": [7500, 0, 0, 1800, 0, 0], "cite": "country.script:1515,:1536 + overwrite :1538-1539 [O]"},
	"aussta.reiter.2.1": {"pack": "S2", "lvl": 2, "value": 2, "en": true, "tf": 250, "ts": 7.8125, "cost": [200, 0, 0, 135, 300, 0], "cite": "country.script:1541,:1562 + overwrite :1563-1564 [O]"},
	"aussta.reiter.2.2": {"pack": "S2", "lvl": 3, "value": 3, "en": false, "tf": 250, "ts": 7.8125, "cost": [600, 0, 0, 100, 400, 0], "cite": "country.script:1541,:1562 + overwrite :1563-1564 [O]"},
	"aussta.reiter.2.3": {"pack": "S2", "lvl": 4, "value": 3, "en": false, "tf": 250, "ts": 7.8125, "cost": [800, 0, 0, 200, 560, 0], "cite": "country.script:1541,:1562 + overwrite :1563-1564 [O]"},
	"aussta.reiter.2.4": {"pack": "S2", "lvl": 5, "value": 2, "en": false, "tf": 250, "ts": 7.8125, "cost": [1600, 0, 0, 300, 640, 0], "cite": "country.script:1541,:1562 + overwrite :1563-1564 [O]"},
	"aussta.reiter.2.5": {"pack": "S2", "lvl": 6, "value": 1, "en": false, "tf": 250, "ts": 7.8125, "cost": [3200, 0, 0, 350, 300, 0], "cite": "country.script:1541,:1562 + overwrite :1563-1564 [O]"},
	"aussta.reiter.2.6": {"pack": "S2", "lvl": 7, "value": 1, "en": false, "tf": 250, "ts": 7.8125, "cost": [16000, 0, 0, 1000, 5000, 0], "cite": "country.script:1541,:1562 + overwrite :1563-1564 [O]"},
	"aussta.dragoon.1.1": {"pack": "D1", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [500, 0, 0, 150, 0, 0], "cite": "country.script:1634,:1657 [O]"},
	"aussta.dragoon.1.2": {"pack": "D1", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [700, 0, 0, 200, 0, 0], "cite": "country.script:1634,:1657 [O]"},
	"aussta.dragoon.1.3": {"pack": "D1", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [900, 0, 0, 340, 0, 0], "cite": "country.script:1634,:1657 [O]"},
	"aussta.dragoon.1.4": {"pack": "D1", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [0, 0, 0, 0, 0, 0], "cite": "country.script:1634,:1657 [O]; unreachable via links :1658-1667"},
	"aussta.dragoon.1.5": {"pack": "D1", "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [0, 0, 0, 0, 0, 0], "cite": "country.script:1634,:1657 [O]; unreachable via links :1658-1667"},
	"aussta.dragoon.1.6": {"pack": "D1", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [0, 0, 0, 0, 0, 0], "cite": "country.script:1634,:1657 [O]; unreachable via links :1658-1667"},
	"aussta.dragoon.2.1": {"pack": "D2", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [900, 0, 0, 150, 0, 0], "cite": "country.script:1670,:1692 [O]"},
	"aussta.dragoon.2.2": {"pack": "D2", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [6600, 0, 0, 750, 0, 0], "cite": "country.script:1670,:1692 [O]"},
	"aussta.dragoon.2.3": {"pack": "D2", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [5000, 0, 0, 1250, 0, 0], "cite": "country.script:1670,:1692 [O]"},
	"aussta.dragoon.2.4": {"pack": "D2", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [3000, 0, 0, 700, 0, 0], "cite": "country.script:1670,:1692 [O]"},
	"aussta.dragoon.2.5": {"pack": "D2", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [1000, 0, 0, 2350, 0, 0], "cite": "country.script:1670,:1692 [O]"},
	"aussta.dragoon.2.6": {"pack": "D2", "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [6001, 0, 0, 5000, 0, 0], "cite": "country.script:1670,:1692 [O]"},
	"aussta.cuirassier.1.1": {"pack": "C1", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [12000, 0, 0, 600, 0, 0], "cite": "country.script:1710,:1731 [O]"},
	"aussta.cuirassier.1.2": {"pack": "C1", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [32000, 0, 0, 1300, 0, 0], "cite": "country.script:1710,:1731 [O]"},
	"aussta.cuirassier.1.3": {"pack": "C1", "lvl": 4, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [62000, 0, 0, 2200, 0, 0], "cite": "country.script:1710,:1731 [O]"},
	"aussta.cuirassier.1.4": {"pack": "C1", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [61000, 0, 0, 3150, 0, 0], "cite": "country.script:1710,:1731 [O]"},
	"aussta.cuirassier.1.5": {"pack": "C1", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [57055, 0, 0, 4100, 0, 0], "cite": "country.script:1710,:1731 [O]"},
	"aussta.cuirassier.1.6": {"pack": "C1", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [49050, 0, 0, 8020, 0, 0], "cite": "country.script:1710,:1731 [O]"},
	"aussta.cuirassier.2.1": {"pack": "C2", "lvl": 2, "value": 2, "en": true, "tf": 500, "ts": 15.625, "cost": [1760, 0, 0, 350, 1000, 0], "cite": "country.script:1733,:1754 [O]"},
	"aussta.cuirassier.2.2": {"pack": "C2", "lvl": 3, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [3000, 0, 0, 750, 2000, 0], "cite": "country.script:1733,:1754 [O]"},
	"aussta.cuirassier.2.3": {"pack": "C2", "lvl": 4, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [7600, 0, 0, 300, 3030, 0], "cite": "country.script:1733,:1754 [O]"},
	"aussta.cuirassier.2.4": {"pack": "C2", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [8700, 0, 0, 6200, 100, 0], "cite": "country.script:1733,:1754 [O]"},
	"aussta.cuirassier.2.5": {"pack": "C2", "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [8700, 0, 0, 2350, 5000, 0], "cite": "country.script:1733,:1754 [O]"},
	"aussta.cuirassier.2.6": {"pack": "C2", "lvl": 7, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [9700, 0, 0, 4444, 7060, 0], "cite": "country.script:1733,:1754 [O]"},
	"aussta.hussar.1.1": {"pack": "H1", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [0, 0, 0, 1800, 1000, 0], "cite": "country.script:1771,:1792 [O]"},
	"aussta.hussar.1.2": {"pack": "H1", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [0, 0, 0, 3800, 2000, 0], "cite": "country.script:1771,:1792 [O]"},
	"aussta.hussar.1.3": {"pack": "H1", "lvl": 4, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [20200, 0, 0, 0, 2000, 0], "cite": "country.script:1771,:1792 [O]"},
	"aussta.hussar.1.4": {"pack": "H1", "lvl": 5, "value": 4, "en": false, "tf": 500, "ts": 15.625, "cost": [32000, 0, 0, 0, 3000, 0], "cite": "country.script:1771,:1792 [O]"},
	"aussta.hussar.1.5": {"pack": "H1", "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [49200, 0, 0, 0, 3500, 0], "cite": "country.script:1771,:1792 [O]"},
	"aussta.hussar.1.6": {"pack": "H1", "lvl": 7, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [20000, 0, 0, 0, 6000, 0], "cite": "country.script:1771,:1792 [O]"},
	"aussta.hussar.2.1": {"pack": "H2", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [1760, 0, 0, 1350, 0, 0], "cite": "country.script:1794,:1815 [O]"},
	"aussta.hussar.2.2": {"pack": "H2", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1900, 0, 0, 2350, 0, 0], "cite": "country.script:1794,:1815 [O]"},
	"aussta.hussar.2.3": {"pack": "H2", "lvl": 4, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1600, 0, 0, 5350, 0, 0], "cite": "country.script:1794,:1815 [O]"},
	"aussta.hussar.2.4": {"pack": "H2", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [8000, 0, 0, 8350, 0, 0], "cite": "country.script:1794,:1815 [O]"},
	"aussta.hussar.2.5": {"pack": "H2", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 15350, 0, 0], "cite": "country.script:1794,:1815 [O]"},
	"aussta.hussar.2.6": {"pack": "H2", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [56000, 0, 0, 20150, 0, 0], "cite": "country.script:1794,:1815 [O]"},
	"aussta.dragoon18.1.1": {"pack": "E1", "lvl": 2, "value": 2, "en": true, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 100, 0, 0], "cite": "country.script:1833,:1854 [O]"},
	"aussta.dragoon18.1.2": {"pack": "E1", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [9000, 0, 0, 350, 0, 0], "cite": "country.script:1833,:1854 [O]"},
	"aussta.dragoon18.1.3": {"pack": "E1", "lvl": 4, "value": 4, "en": false, "tf": 500, "ts": 15.625, "cost": [12000, 0, 0, 400, 0, 0], "cite": "country.script:1833,:1854 [O]"},
	"aussta.dragoon18.1.4": {"pack": "E1", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [23000, 0, 0, 580, 0, 0], "cite": "country.script:1833,:1854 [O]"},
	"aussta.dragoon18.1.5": {"pack": "E1", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [32000, 0, 0, 680, 0, 0], "cite": "country.script:1833,:1854 [O]"},
	"aussta.dragoon18.1.6": {"pack": "E1", "lvl": 7, "value": 4, "en": false, "tf": 500, "ts": 15.625, "cost": [42000, 0, 0, 780, 0, 0], "cite": "country.script:1833,:1854 [O]"},
	"aussta.dragoon18.2.1": {"pack": "E2", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [760, 0, 0, 935, 0, 0], "cite": "country.script:1856,:1877 [O]"},
	"aussta.dragoon18.2.2": {"pack": "E2", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1260, 0, 0, 1150, 0, 0], "cite": "country.script:1856,:1877 [O]"},
	"aussta.dragoon18.2.3": {"pack": "E2", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [15600, 0, 0, 2350, 0, 0], "cite": "country.script:1856,:1877 [O]"},
	"aussta.dragoon18.2.4": {"pack": "E2", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [17600, 0, 0, 3350, 0, 0], "cite": "country.script:1856,:1877 [O]"},
	"aussta.dragoon18.2.5": {"pack": "E2", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [19600, 0, 0, 5350, 0, 0], "cite": "country.script:1856,:1877 [O]"},
	"aussta.dragoon18.2.6": {"pack": "E2", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [21760, 0, 0, 9350, 0, 0], "cite": "country.script:1856,:1877 [O]"},
	"ausba2.pandur.1.1": {"pack": "P1", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [3000, 0, 0, 750, 0, 0], "cite": "country.script:1884,:1898,:1905 [O]"},
	"ausba2.pandur.1.2": {"pack": "P1", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [4000, 0, 0, 1100, 0, 0], "cite": "country.script:1898,:1905 [O]"},
	"ausba2.pandur.1.3": {"pack": "P1", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [7000, 0, 0, 1800, 0, 0], "cite": "country.script:1898,:1905 [O]"},
	"ausba2.pandur.1.4": {"pack": "P1", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [12000, 0, 0, 350, 0, 0], "cite": "country.script:1898,:1905 [O]"},
	"ausba2.pandur.1.5": {"pack": "P1", "lvl": 6, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [32020, 0, 0, 850, 0, 0], "cite": "country.script:1898,:1905 [O]"},
	"ausba2.pandur.1.6": {"pack": "P1", "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [45200, 0, 0, 1330, 0, 0], "cite": "country.script:1898,:1905 [O]"},
	"ausba2.pandur.2.1": {"pack": "P2", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [3706, 0, 0, 350, 0, 0], "cite": "country.script:1918,:1925 [O]"},
	"ausba2.pandur.2.2": {"pack": "P2", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [12060, 0, 0, 1350, 0, 0], "cite": "country.script:1918,:1925 [O]"},
	"ausba2.pandur.2.3": {"pack": "P2", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [36706, 0, 0, 2250, 0, 0], "cite": "country.script:1918,:1925 [O]"},
	"ausba2.pandur.2.4": {"pack": "P2", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [36706, 0, 0, 3350, 0, 0], "cite": "country.script:1918,:1925 [O]"},
	"ausba2.pandur.2.5": {"pack": "P2", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [37060, 0, 0, 1350, 0, 0], "cite": "country.script:1918,:1925 [O]"},
	"ausba2.pandur.2.6": {"pack": "P2", "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [16706, 0, 0, 1350, 0, 0], "cite": "country.script:1918,:1925 [O]"},
	"aussta.croat.1.1": {"pack": "U1", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 500, 0, 0], "cite": "country.script:1947,:1955-1956,:1957 [O]"},
	"aussta.croat.1.2": {"pack": "U1", "lvl": 3, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [5000, 0, 0, 800, 0, 0], "cite": "country.script:1947,:1957 [O]"},
	"aussta.croat.1.3": {"pack": "U1", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [10000, 0, 0, 1200, 0, 0], "cite": "country.script:1947,:1957 [O]"},
	"aussta.croat.1.4": {"pack": "U1", "lvl": 5, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [20000, 0, 0, 1300, 0, 0], "cite": "country.script:1947,:1957 [O]"},
	"aussta.croat.1.5": {"pack": "U1", "lvl": 6, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [30000, 0, 0, 3000, 0, 0], "cite": "country.script:1947,:1957 [O]"},
	"aussta.croat.1.6": {"pack": "U1", "lvl": 7, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [20000, 0, 0, 5000, 0, 0], "cite": "country.script:1947,:1957 [O]"},
	"aussta.croat.2.1": {"pack": "U2", "lvl": 2, "value": 1, "en": true, "tf": 500, "ts": 15.625, "cost": [2000, 0, 0, 1350, 0, 0], "cite": "country.script:1959,:1966 [O]"},
	"aussta.croat.2.2": {"pack": "U2", "lvl": 3, "value": 1, "en": false, "tf": 500, "ts": 15.625, "cost": [1500, 0, 0, 2100, 0, 0], "cite": "country.script:1959,:1966 [O]"},
	"aussta.croat.2.3": {"pack": "U2", "lvl": 4, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [5000, 0, 0, 2300, 0, 0], "cite": "country.script:1959,:1966 [O]"},
	"aussta.croat.2.4": {"pack": "U2", "lvl": 5, "value": 2, "en": false, "tf": 500, "ts": 15.625, "cost": [10500, 0, 0, 3400, 0, 0], "cite": "country.script:1959,:1966 [O]"},
	"aussta.croat.2.5": {"pack": "U2", "lvl": 6, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [12600, 0, 0, 4500, 0, 0], "cite": "country.script:1959,:1966 [O]"},
	"aussta.croat.2.6": {"pack": "U2", "lvl": 7, "value": 3, "en": false, "tf": 500, "ts": 15.625, "cost": [40000, 0, 0, 5000, 0, 0], "cite": "country.script:1959,:1966 [O]"},
}
# [D-count] 28 (A) + 39 (B) + 12 (S) + 12 (D) + 12 (C) + 12 (H) + 12 (E) +
# 12 (P) + 12 (U) + 6 (explicit SW) = 157 rows, matching the report §3 total.

# ── §2 explicit-sword cross-index — the SIX non-pack `_aus` sword rows [O] ─────
# SIDs and their exact cited lines are repeated here so the 6-row block is
# independently countable; the six tuples themselves live once, in
# DONOR_UPG_AUS_ROWS above (flagged `"explicit": true`). Links :2129-2130
# (damage .1.3 -> .1.6 chain) and :2134-2135 (protection chain) are [O].
const DONOR_UPG_SWORD_EXPLICIT := {
	"rows": [
		{"sid": "ausbar.roundshier.1.4", "line": ":2126"},
		{"sid": "ausbar.roundshier.1.5", "line": ":2127"},
		{"sid": "ausbar.roundshier.1.6", "line": ":2128"},
		{"sid": "ausbar.roundshier.2.4", "line": ":2131"},
		{"sid": "ausbar.roundshier.2.5", "line": ":2132"},
		{"sid": "ausbar.roundshier.2.6", "line": ":2133"},
	],
	"links": "country.script:2129-2130 damage .1.3 -> .1.6; :2134-2135 protection chain [O]",
	"cite": "country.script:2039,:2115,:2126-2135 [O]",
	"status": "[O] non-pack AddUpgradeWithAccessControl rows; en=False; NO port key added.",
}

# ── §4 [O] artillery base rows + tur/alg gold overrides, 320f/1000f split ──────
# `base_cost` is the six-tuple [food, wood, stone, gold, iron, coal]; `tur_alg_gold`
# is the gold value WRITTEN by the ModifyOverride at ind-1 (sentinel law), NOT a
# fold into the base cost. `tf`/`ts`: .2.1-.2.3 are 320f both members; .2.4-.2.6
# are 500f cannon / 1000f howitzer. The .1.* cost rows are cited in the split
# summary below, never numbered here — their tuples are NOT in the report.
const DONOR_UPG_ARTILLERY_ROWS := {
	"art.cannon.2.1": {"member": "cannon", "lvl": 2, "en": true, "base_cost": [0, 0, 0, 500, 1000, 0], "tf": 320, "ts": 10.0, "build_timeperc": -2500000, "tur_alg_gold": 950, "cite": "country.script:3783-3784 [O]"},
	"art.cannon.2.2": {"member": "cannon", "lvl": 3, "en": false, "base_cost": [0, 0, 0, 1000, 2000, 0], "tf": 320, "ts": 10.0, "tur_alg_gold": 150, "cite": "country.script:3785-3786 [O]"},
	"art.cannon.2.3": {"member": "cannon", "lvl": 4, "en": false, "base_cost": [0, 0, 0, 2000, 3000, 0], "tf": 320, "ts": 10.0, "tur_alg_gold": 250, "cite": "country.script:3787-3788 [O]"},
	"art.cannon.2.4": {"member": "cannon", "lvl": 5, "en": false, "base_cost": [2560, 0, 0, 0, 0, 0], "tf": 500, "ts": 15.625, "tur_alg_gold": 1350, "cite": "country.script:3789-3790 [O]"},
	"art.cannon.2.5": {"member": "cannon", "lvl": 6, "en": false, "base_cost": [3560, 0, 0, 0, 0, 0], "tf": 500, "ts": 15.625, "tur_alg_gold": 2500, "cite": "country.script:3791-3792 [O]"},
	"art.cannon.2.6": {"member": "cannon", "lvl": 7, "en": false, "base_cost": [5560, 0, 0, 0, 0, 0], "tf": 500, "ts": 15.625, "tur_alg_gold": 3350, "cite": "country.script:3793-3794 [O]"},
	"art.howitzer.2.1": {"member": "howitzer", "lvl": 2, "en": true, "base_cost": [0, 0, 0, 500, 1000, 0], "tf": 320, "ts": 10.0, "build_timeperc": -2500000, "tur_alg_gold": 350, "cite": "country.script:3834-3835 [O]"},
	"art.howitzer.2.2": {"member": "howitzer", "lvl": 3, "en": false, "base_cost": [0, 0, 0, 1000, 2000, 0], "tf": 320, "ts": 10.0, "tur_alg_gold": 450, "cite": "country.script:3836-3837 [O]"},
	"art.howitzer.2.3": {"member": "howitzer", "lvl": 4, "en": false, "base_cost": [0, 0, 0, 2000, 3000, 0], "tf": 320, "ts": 10.0, "tur_alg_gold": 550, "cite": "country.script:3838-3839 [O]"},
	"art.howitzer.2.4": {"member": "howitzer", "lvl": 5, "en": false, "base_cost": [2560, 0, 0, 0, 0, 0], "tf": 1000, "ts": 31.25, "tur_alg_gold": 1150, "cite": "country.script:3840-3841 [O]"},
	"art.howitzer.2.5": {"member": "howitzer", "lvl": 6, "en": false, "base_cost": [3560, 0, 0, 0, 0, 0], "tf": 1000, "ts": 31.25, "tur_alg_gold": 3200, "cite": "country.script:3842-3843 [O]"},
	"art.howitzer.2.6": {"member": "howitzer", "lvl": 7, "en": false, "base_cost": [5560, 0, 0, 0, 0, 0], "tf": 1000, "ts": 31.25, "tur_alg_gold": 4500, "cite": "country.script:3844-3845 [O]"},
}

const DONOR_UPG_ART_SPLIT_SUMMARY := {
	"member_switch": "member cannon -> howitzer switch at country.script:3796 [O]",
	"cost_rows_1": "country.script:3758-3781 (cannon) / :3809-3832 (howitzer) [O] — .1.1-.1.6 cost rows are IDENTICAL; times 320/320/320/500/500/500 for both members. Their six-tuples are NOT transcribed in the report and are NOT invented here; they stay [U] R-COST.",
	"head_2": ".2.1-.2.3: identical 320f both members (country.script:3783-3788 / :3834-3839 [O])",
	"tail_2": ".2.4-.2.6: SPLIT — cannon 500f vs howitzer 1000f (country.script:3789-3794 / :3840-3845 [O])",
	"gold_tail": "tur/alg gold override tail — cannon 1350/2500/3350 vs howitzer 1150/3200/4500 [O] (:3793-3794 / :3844-3845)",
	"link_sever": "last-3 tail links severed: cannon country.script:3799-3803; howitzer :3804-3807 [O]",
	"delta_mechanism": "ModifyUpgrade -1 sentinel (country.script:599-615 [O]) applies the gold delta at ind-1 = the just-emitted row [D]; NOT a base-cost fold.",
	"status": "[O]/[D] TEXT ONLY — no artillery row is added to UPGRADES_BASE and no nation modifier is wired.",
}

# ── §4 [O] pack-level tur/alg struct deltas (same pack sites, other tuples) ────
# Only the examples the report actually transcribed are carried. Values not
# present in the report are referenced back to their cited row, never guessed.
const DONOR_UPG_TUR_ALG_PACK_DELTAS := {
	"pikeman_dmg": {
		"aus": {"struct": ":953", "values": [1, 2, 2, 1, 2], "food": [200, 1300, 3600, 7200, 16030], "gold": [50, 300, 450, 1850, 2000]},
		"tur": {"struct": ":963", "values": [2, 2, 2, 2, 2], "food": [200, 600, 1200, 2200, 16030], "gold": [50, 300, 450, 1850, 2000]},
		"alg": "same tuples as tur at country.script:964 [O]",
		"cite": "country.script:953,963,964 [O]",
	},
	"pikeman_prot": {
		"aus": {"struct": ":977", "values": [1, 1, 2, 1, 1]},
		"tur": {"struct": ":987", "values": [1, 2, 3, 1, 2]},
		"alg": "same values as tur at country.script:988 [O]",
		"note": "same food/gold as the aus A2 rows ([O] 'same food/gold') — not restated, never invented",
		"cite": "country.script:977,987,988 [O]",
	},
	"roundshier_dmg": {
		"aus": {"struct": ":1017", "values": [1, 1, 2]},
		"tur_alg": {"struct": ":1018-1019", "values": [1, 1, 1]},
		"note": "third (1300-gold) tier value 2 -> 1 [O]",
		"cite": "country.script:1017,1018-1019 [O]",
	},
	"roundshier_prot": {
		"aus": {"struct": ":1023", "values": [1, 2, 2]},
		"tur_alg": {"struct": ":1024-1025", "values": [1, 1, 2]},
		"note": "second tier value 2 -> 1 and food 4360 -> 6360 [O]",
		"cite": "country.script:1023,1024-1025 [O]",
	},
	"status": "[O] cited examples only. The full per-nation matrix remains [U] R-MATRIX-other; no aus neighbour value is borrowed.",
}

# ── §6 port change list recorded as CITES ONLY — nothing adopted ───────────────
const DONOR_UPG_PORT_APPROX := {
	"UPGRADES_BASE": "UNCHANGED by this worker: every value, cost, time, gate and key at data.gd:2527-2708 is the existing PORT APPROXIMATION. No DONOR_UPG_* const is read by _static_init() or by any live table.",
	"anchor_cen_18c": "port cen_18c 800f/600g (data.gd:2538-2539) <- country.script:3438 (300f, 30000f/5000g/2000i/2000c) — PORT APPROXIMATION; do not relabel.",
	"anchor_mil_food1": "port mil_food1 750f/250g / time 10.0 (data.gd:2544) <- country.script:3454 (750f/250g MATCH on cost, time APPROXIMATION: donor 15.625) — NOT adopted.",
	"anchor_mil_food2": "port mil_food2 (data.gd:2548-2549) <- country.script:3466 (25600f/3350g/2000i row + req0 access; port lacks req) — NOT adopted.",
	"anchor_aca_build1": "port aca_build1 build_mult 0.25 (data.gd:2568-2569) <- country.script:3530 (-7500000 buildtimeperc, 6950g) — shape APPROXIMATION, NOT adopted.",
	"new_keys": "§6 suggests future bla_sword_*/art_*/sta_reiter_* rows carrying donor_sid / donor_time_frames / donor_price_fws_gic / donor_lines comments. This worker ADDS NO KEY; all such numbers remain [U] until their captures pass.",
	"status": "NO PARITY CLAIM. Port 8.0/10.0/12.0/... seconds are NEVER asserted as donor literals.",
}

# ── §5 [U] register — fixed-seed ZERO-MISMATCH captures, nothing weakened ──────
const DONOR_UPG_SEED_CONVENTION := "Seed convention S (owner-executed; this worker never runs the binary): fixed map + fixed nation pair + fixed DONOR_GAME_SPEED + full stock. Instrumented owner build logs orders[0].info.{upgradeid,progress}, gCountry[cid].upgrade[upgind].{time,price[0..6]} at queue time, and res[0..6] + stat.resonupgrade/resonmines before / after / cancel / complete. Wall-clock IRRELEVANT."
const DONOR_UPG_TERMINATION := "Run the FULL stated series. ANY single mismatch keeps the item [U] and FORBIDS wiring. ZERO mismatches across the FULL series closes it. Three identical-seed runs must give an identical tick count and progress trace. No port fallback may close a [U]; no neighbour row may be extrapolated; no cost or time may be invented."
const DONOR_UPG_UNRESOLVED := {
	"R-MATRIX-aus": "157 _aus rows in DONOR_UPG_AUS_ROWS are donor TEXT [O] with cites; PORT ADOPTION STILL [U]. Capture: per _aus SID, queue its tier (prereq chain first), then run R-TIME + R-COST. ZERO-MISMATCH: 3 identical-seed runs => identical tick count + progress trace + after_order = before - price exactly; cancel restores; link-enable per :921-922 (severed: dragoon :1658-1667, artillery :3799-3807, 17c-officer tails — last-3 sever per ROWS §2.2).",
	"R-MATRIX-other": "All non-aus nation columns use the same pack skeleton with their own tuples at sibling _xxx lines (e.g. :954-973, :978-997). Generator LAW [O]; hundreds of cells remain [U] — NEVER copy an _aus neighbour value. Capture: same per (nation x member x tier), ZERO-MISMATCH as above. Priority: tur/alg (§4 gold deltas), ukr/sco (bhave18century=False :929, empty members :938/:1005-1007/:1036-1037), pru/swe value-order swaps (:961 food rotation).",
	"R-TIME": "Seconds for every row. LAW + all frame params + 6 overwrites grounded [O], but port values stay [U]. Capture: orders[0].info.progress per building-Nothing tick to completion. ZERO-MISMATCH: 3 runs identical trace; ticks*dt_tick approximates <row seconds> within one tick.",
	"R-COST": "Six-price per row incl. gold. Base + delta tuples transcribed [O]; PORT dicts are estimates. Capture: res/stat snapshot before / after / cancel / complete. ZERO-MISMATCH: exact delta, exact restore, resonupgrade (or resonmines for mine rows).",
	"R-1972": "Pack call country.script:1972 (protection horsedef 1,2) — the CALL is [O]; its feeding struct block was UNREAD by the report and stays [U]. Capture: cite the struct lines, then run R-MATRIX on its SIDs before any adoption.",
	"R-ADDON": "Nation-specific add-on rows country.script:2039-2210. Block cites are [O]; aus participation is UNVERIFIED ([U]) — do not assume absence. Capture: owner grep-equivalent check per nation, then R-MATRIX for any emitted aus SID.",
	"seed_convention": DONOR_UPG_SEED_CONVENTION,
	"termination": DONOR_UPG_TERMINATION,
	"no_parity_claim": "NO donor binary executed, no GPU A/B frame captured, no port capture compared by this worker. Closed items rest on donor text [O] with file:line; every open item keeps its exact settling capture above.",
}

# ── DEC-U-ATTACK-DELAY §§1-5 — INERT DONOR ATTACK-TIMING DATA / TELEMETRY ────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_attack_delay.md
#   §1 fields / overwrite law / pause sources · §2 FramesToTime · §3 reuse gating
#   and decay · §4 the literal `1` · §5 eight still-open [U] captures · §6
#   data.gd-side change-list items 1-2.
# Read-only donor TEXT against pin t_87f0f3c130b0; donor binary NEVER executed;
# no GPU frame captured, NO PARITY CLAIM. Every value is [O] verbatim with its
# file:line cite, or [D] arithmetic derived ONLY from cited [O] literals.
# DATA / TELEMETRY ONLY: no consumer wired, no gate added, NO BEHAVIOUR CHANGE.
# FRAMES_TO_TIME (data.gd:21) and DONOR_MOUNT_ROWS (data.gd:1300+) stay untouched;
# no UNITS_BASE[*].weapons[].cd is re-derived here — report §6 item 2 is a live-sim
# patch for the owner, OUT of this inert scope. game.gd cooldown code (incl. the
# :4900 PORT APPROXIMATION `1.0`) is OUT OF SCOPE: exact patch recs go in the final
# report, NOT into this file. No delay, cooldown or sid number invented.
# ────────────────────────────────────────────────────────────────────────────────

# §1.1 field identity + spawn/init [O].
const DONOR_ATTACK_FIELDS := {
	"attackdelay": "Float seconds, per entity — dmscript.global:1737 [O]",
	"attackmaxdelay": "Float seconds, per entity — dmscript.global:1738 [O]",
	"spawn": {"attackdelay": 0, "attackmaxdelay": 0, "cite": "unit.script:2703-2704 [O] _unit_ResetObj-family init"},
	"attackrate_default": 1,
	"attackrate_cite": "unit.script:2727-2729 [O] individual.attackrate := 1; individual.benabled := False",
	"display_seed": {"value": 1, "iff": "bshowdelay", "cite": "unit.inc/initial.inc:263-264 [O] UI-only MAX-bar prefill; delay stays 0; bshowdelay decl classes.script:3637 [O]"},
	"dead_ui_comment": "unit.script:10791-10792 commented bshowdelay -> attackmaxdelay := 1 — DEAD text [O]",
	"no_maxdelay_gate": "[O] negative grep: zero `attackmaxdelay=0` gates in the corpus — maxdelay is a sticky UI tracker, never a reuse gate [D]",
	"inert": "INERT FIELD RECORD ONLY — no port field added or read"
}

# §1.2 the ONLY normal writer: OVERWRITE, not MaxFloat [O].
const DONOR_APPLY_ATTACK_PAUSE := {
	"cite": "unit.script:10750-10789 [O] procedure _unit_ApplyAttackPause(const goHnd, weapind : Integer)",
	"source": "attpause := TObjBase(pobjbase).weapon[weapind].pause — per-MOUNT seconds — :10758 [O]",
	"need_pause": "bNeedPause := (attpause>0) — :10759 [O]",
	"enable_gate": "(individual.benabled) and (attpause>0) — :10760 [O]",
	"unit_scaling": "attpause := attpause * TObj(pobj).individual.attackrate — :10761 [O]",
	"zero_rule": "if (not bNeedPause) then attpause := 0 — :10786 [O] zero-pause mounts stay 0",
	"write_attackdelay": "TObj(pobj).attackdelay := attpause — :10788 [O] OVERWRITE (:=, never MaxFloat)",
	"write_attackmaxdelay": "TObj(pobj).attackmaxdelay := attpause — :10789 [O] OVERWRITE",
	"order": "[D] both fields set to the firing mount's pause_s, discarding any prior residual; MaxFloat floors belong ONLY to penalty writers (§1.4)",
	"dead_text": "commented animation-frame trim :10763-10780 is DEAD ({...}); live law ignores animation length [O]/[D]",
	"base_prop_split": "pause/damageinit/radiusmax in per-player BASE; kind/radiusmin/detect*/cost in shared PROP — player.script upgrades mutate gPlayer..objbase..weapon[j].pause (:1857), costs mutate PROP [O]",
	"melee": "[D] pause=0 melee rows write 0/0 — no reuse delay from this path; reuse gated by animation event + `=0` checks only",
	"inert": "INERT LAW TEXT ONLY — no wired consumer, no port cooldown write"
}

# §1.3 / §2 pause source and frames->seconds conversion [O]+[D].
const DONOR_PAUSE_TO_SECONDS := {
	"setter": "unit.script:520-546 [O] SetObjBaseWeapon: if (pause<>-1) then objbase.weapon[index].pause := _misc_FramesToTime(pause)",
	"setter_line": "unit.script:539 [O]",
	"arg_units": "INTEGER FRAMES; -1 = donor `default` = keep-prior (unit.script:593) [O]",
	"frames_to_time": "_misc_FramesToTime(v) = v * gc_frames_to_time — misc.script:470-474 [O]",
	"gc_frames_to_time": 0.03125,
	"gc_time_to_frames": 32,
	"const_cite": "dmscript.global:174-175 [O]",
	"law_s": "[D] pause_s = frames * 0.03125 = frames / 32 (set time), stored Float seconds, copied verbatim at :10788-10789",
	"buildtime_not_pause": "_misc_BuildtimeToTime(v) = v*gc_frames_to_time*10 (misc.script:480-482) is BUILD time ONLY — NEVER used for pause [O]",
	"other_timebases": "[O] projectile time (weapon.script FramesToTime rows), gc_squad_holdmode_time = 150*8*gc_frames_to_time (dmscript.global:180), gc_buildtime_progressperhit are disjoint — never substituted for pause",
	"samples": [
		{"sid": "cannon mount-0", "frames": 350, "seconds": 10.9375, "cite": "unit.script:1696-1731 (:1704-1709) [O]"},
		{"sid": "cannon mount-1", "frames": 350, "seconds": 10.9375, "cite": "unit.script:1711 [O] `350{1200}{c1 1400}` live head 350"},
		{"sid": "multicannon", "frames": 60, "seconds": 1.875, "cite": "unit.script:1794-1822 (:1800/:1801-1805) [O]"},
		{"sid": "musket line", "frames": 150, "seconds": 4.6875, "cite": "unit.script:774 [O] (12 dmg, pause 150)"},
		{"sid": "musket", "frames": 150, "seconds": 4.6875, "cite": "unit.script:807 [O]"},
		{"sid": "musket", "frames": 190, "seconds": 5.9375, "cite": "unit.script:816 [O]"},
		{"sid": "musket", "frames": 220, "seconds": 6.875, "cite": "unit.script:889 [O]"},
		{"sid": "archer", "frames": 75, "seconds": 2.34375, "cite": "unit.script:999 [O]"},
		{"sid": "archer", "frames": 80, "seconds": 2.5, "cite": "unit.script:1044 [O] `80{60}` live head 80"},
		{"sid": "archer", "frames": 85, "seconds": 2.65625, "cite": "unit.script:1023 [O]"},
		{"sid": "archer", "frames": 100, "seconds": 3.125, "cite": "unit.script:1031 [O]"},
		{"sid": "officer-bow", "frames": 125, "seconds": 3.90625, "cite": "unit.script:1005 [O]"},
		{"sid": "firearrow", "frames": 25, "seconds": 0.78125, "cite": "unit.script:1046 [O]"},
		{"sid": "howitzer", "frames": 600, "seconds": 18.75, "cite": "unit.script:1739 [O] `600{1250}` live head 600"},
		{"sid": "mortar", "frames": 250, "seconds": 7.8125, "cite": "unit.script:1771 [O]"},
		{"sid": "framegun", "frames": 90, "seconds": 2.8125, "cite": "unit.script:1830 [O]"},
		{"sid": "yacht base", "frames": 350, "seconds": 10.9375, "cite": "unit.script:1881 [O]"},
		{"sid": "yachttur override", "frames": 400, "seconds": 12.5, "cite": "unit.script:1909 [O]"},
		{"sid": "galley", "frames": 150, "seconds": 4.6875, "cite": "unit.script:1930 [O]"},
		{"sid": "frigate base", "frames": 75, "seconds": 2.34375, "cite": "unit.script:1966 [O]"},
		{"sid": "tower", "frames": 400, "seconds": 12.5, "cite": "unit.script:2227 [O]"},
		{"sid": "tower.commonrus override", "frames": 300, "seconds": 9.375, "cite": "unit.script:2246 [O]"}
	],
	"full_table_owner": "[O] complete per-sid pause ledger is OWNED by DEC_U_weapon_tail §3 (already mirrored in DONOR_MOUNT_ROWS, data.gd:1300+) — cited here, NOT duplicated and NOT invented",
	"inert": "[D] arithmetic only from cited [O] frame literals; no UNITS_BASE cd changed"
}

# §1.3 upgrade scaling [O].
const DONOR_PAUSE_UPGRADE := {
	"global_kind": "gc_upg_type_attpauseperc = 15 [O] (dmscript.global upgrade kinds; report §2)",
	"global_law": "objbase..weapon[j].pause *= (1 + value/100) for ALL mounts of matching kind — player.script:1850-1858, active :1857 [O]",
	"global_sample": {"value": -30, "factor": 0.70, "kind": "bullet", "cite": "country.script:3664,3697 [O]; port rof_mult bullet 0.7 (data.gd:2646-2649) is GROUNDED, not [U]"},
	"single_kind": "gc_upg_type_single_attpauseperc = 26 [O] (dmscript.global upgrade kinds; report §2)",
	"single_law": "individual.attackrate += value/100 — player.script:1965-1973, active :1971 [O]; applied as pause * attackrate at unit.script:10761 [O]",
	"single_reading": "[D] ADDITIVE on the rate, not multiplicative: tower steps -20/-10 (country.script:3903-3913) accumulate BEFORE the :10761 product",
	"inert": "INERT FORMULA TEXT ONLY — no upgrade key added or wired"
}

# §3.1-3.2 entry / order / gating law [O].
const DONOR_ATTACK_GATE := {
	"delay_gate": "(arg_obj.attackdelay = 0) — onaclanimationreachedattack.inc:9 [O]",
	"delay_gate_sites": "unit.inc/ontagstates.inc:732; building.inc/ontagstates.inc:369; unit.script:8181 (melee OR delay=0), :7652, :8519 [O]",
	"order_gate": "orders[0].itype in {attackobj, attackpoint} — inc:9 [O]",
	"process_gate": "bProcess := not (_net_IsClient or _net_IsReplay); clients/replays SKIP the whole block (no cost, no pause, no projectile) — inc:8-9 [O]",
	"statetag_gate": "(statetag & action_attack)<>0 — inc:13; weapon slot decode none/0/1/2 -> weapind 0/0/1/2 — inc:16-21 [O]",
	"resource_gate": "_unit_EnoughResForShot — ontagstates.inc:732, unit.script:7654,8205,8524 [O]",
	"geometry_gates": "PredictShot + FriendOnLine + kind vetoes + building shot-points (DEC_U_ff_predict §§1-2,5) — on deny write MaxFloat(...,1)x2, no projectile [O]",
	"fire_order_inc": "_unit_ApplyWeaponCost(myHnd, weapInd) :26 THEN _unit_ApplyAttackPause(myHnd, weapind) :28 — cost + pause BEFORE PredictShot/deny in the animation-event path [O]",
	"alternate_order": "unit.inc/ontagstates.inc:740-742,766-767,812-813 and building.inc/ontagstates.inc:391,433 — pause + cost only on the ALLOWED branch AFTER PredictShot and ray/shot-point checks [O] — BOTH orders are verbatim, DO NOT UNIFY",
	"deny_effect": "[D] a PredictShot-denied animation-event shot already paid cost and installed the full mount pause before :107-108 floors the residual with MaxFloat(...,1) (no-op unless pause < 1 s, e.g. firearrow 0.78 s or melee 0)",
	"inert": "INERT GATE LAW TEXT ONLY — no port gate added or changed"
}

# §1.4 penalty writers — all MaxFloat floors, never overwrite [O].
const DONOR_ATTACK_PENALTIES := {
	"floor_law": "Every non-fire writer sets BOTH fields with MaxFloat(current, X) — a floor preserving a longer live cooldown [O]",
	"literal_token": 1,
	"sites_count": "13 sites per report §1.4 table / §4 prose",
	"sites": [
		{"literal": 1, "fields": "both", "cite": "onaclanimationreachedattack.inc:107-108 [O] PredictShot deny attackobj"},
		{"literal": 1, "fields": "both", "cite": "onaclanimationreachedattack.inc:135-136 [O] PredictShot deny attackpoint"},
		{"literal": 1, "fields": "both", "cite": "onaclanimationreachedattack.inc:145-146 [O] fallthrough neither obj nor point"},
		{"literal": 1, "fields": "both", "cite": "unit.script:7701-7702 [O] TryAttackPoint ray veto"},
		{"literal": 1, "fields": "both", "cite": "unit.script:8280-8281 [O] Friendly-fire veto"},
		{"literal": 1, "fields": "both", "cite": "unit.inc/ontagstates.inc:760-761 [O]"},
		{"literal": 1, "fields": "both", "cite": "unit.inc/ontagstates.inc:778-779 [O]"},
		{"literal": 1, "fields": "both", "cite": "unit.inc/ontagstates.inc:806-807 [O]"},
		{"literal": 1, "fields": "both", "cite": "unit.inc/ontagstates.inc:818-819 [O]"},
		{"literal": 1, "fields": "both", "cite": "unit.inc/ontagstates.inc:827-828 [O]"},
		{"literal": 1, "fields": "both", "cite": "building.inc/ontagstates.inc:404-405 [O]"},
		{"literal": 1, "fields": "both", "cite": "building.inc/ontagstates.inc:440-441 [O]"},
		{"literal": 1, "fields": "both", "cite": "building.inc/ontagstates.inc:457-458 [O]"}
	],
	"report_4_extra_token_cite": "unit.script:8536-8537 [O] — §4 enumerates this 14th textual site while calling the set '13'; recorded verbatim, count discrepancy NOT resolved by invention",
	"clear_site": {"literal": 0, "fields": "both", "cite": "building.inc/ontagstates.inc:411-412,447-448 [O] shot-point-blocked CLEAR — the ONLY :=0 penalty-site write"},
	"gold_upkeep": {"expr": "100*gc_frames_to_time", "seconds": 3.125, "cite": "unit.script:8187-8188; miscext.script:1038 [O]"},
	"poor_shot": {"expr": "64*gc_frames_to_time", "seconds": 2.0, "cite": "unit.script:8208-8209 [O]"},
	"capture_block": {"expr": "100*gc_frames_to_time", "seconds": 3.125, "cite": "miscext.script:1038-1039 [O]"},
	"seconds_scale": "[D] attackdelay/maxdelay are Float seconds (dmscript.global:1737-1738); sibling writers on the same fields use 100*gc_frames_to_time = 3.125 s and 64*gc_frames_to_time = 2.0 s on the identical scale, so the bare token `1` glosses as 1.0 s — corroborated by the bshowdelay display seed (initial.inc:264) and the dead UI comment (unit.script:10792)",
	"invention_ban": "[O] VERBATIM token `1` only (1.0 as a GDScript float gloss); the word 'second' is a derived unit gloss, never a new number; port game.gd:4900 `1.0` is a PORT APPROXIMATION and is NOT changed here",
	"inert": "INERT LITERAL REGISTER ONLY — no port cooldown write, no deny helper added"
}

# §3.3 decay and movie reset [O].
const DONOR_ATTACK_DECAY := {
	"units": "if (attackdelay>0) then attackdelay -= deltatime; if (<0) then :=0 — unit.inc/nothing.inc:87-92 [O]",
	"buildings": "attackdelay := _misc_MaxFloat(attackdelay-deltatime, 0) — building.inc/nothing.inc:28-29,330-331 [O] float-safe form",
	"deltatime": "GetGameTime - lastprogresstime (seconds) — building.inc/nothing.inc:27 [D]",
	"maxdelay_not_decayed": "[D] attackmaxdelay is NOT decayed here; it is the sticky UI/max tracker; only attackdelay gates reuse; zero attackmaxdelay=0 gates in corpus [O]",
	"movie_reset": "_movie_UnitResetAttackDelay := attackdelay := 0 — movie.script:762-767; squad/list variants :768-778 [O] leaves attackmaxdelay untouched; scenario/cutscene only",
	"initial_seed": "initial.inc:264 attackmaxdelay := 1 iff bshowdelay is set ONCE at creation and never gates anything [O]",
	"inert": "INERT DECAY LAW TEXT ONLY — no tick consumer added or changed"
}

# §5 eight still-[U] items — fixed-camera shot-series, zero-mismatch termination.
const DONOR_ATTACK_DELAY_SEED_CONVENTION := "Harness (all series): fixed camera (camera3d frozen, no shake — sim assertions read entities[].cooldown / projectiles[] / hp, never pixels). Flat map (height==h0), two actors S (shooter) + T (target) unless noted. Seeded rng re-seeded per series."
const DONOR_ATTACK_DELAY_TERMINATION := "Run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item [U] and FORBIDS wiring; zero mismatches across the FULL series closes it. Never fit a curve; never invent a literal."
const DONOR_ATTACK_DELAY_UNRESOLVED := {
	"U-D1": "Mount pause per sid (reuse interval). LAW closed by §§1-2 [O]; ~10 sample frames verified P10; FULL sid table owned by DEC_U_weapon_tail §3 — port cd values partly estimated. Series D1-PAUSE: per sid under test, order 1 attack vs practice target, record cooldown on the firing tick (= pause_s) then tick dt=1/32 and assert cooldown -= dt each tick until 0. 30 shots/sid. Expectation: cooldown_0 == pause_frames*0.03125 exactly; any delta => [U].",
	"U-D2": "Melee zero-pause reuse. pause=0 melee rows [O] §1.2; donor melee still gated by animation event inc:9 + TryAttack `melee or delay=0` (unit.script:8181). Series D2-MELEE: pikeman vs adjacent target, 50 swings. Expectation: cooldown stays 0.0 after every swing (ApplyAttackPause writes 0), next swing fires on next attack animation event without waiting. Any cooldown>0 => [U].",
	"U-D3": "individual.attackrate scaling. pause*attackrate law + +=value/100 upgrade law [O] §1.3; per-sid trigger values open. Series D3-RATE: tower with single_attpauseperc -20 applied twice, 30 shots. Expectation: cooldown_0 == base_pause*(1-0.20-0.20) (additive per player.script:1971). Any multiplicative reading => [U].",
	"U-D4": "Global attpauseperc (-30% -> x0.70). Formula [O] §1.3; port rof_mult 0.7 grounded but live wiring unverified. Series D4-ROF: musket line with aca.31, 30 shots. Expectation: cooldown_0 == base*0.70. Any other factor => [U].",
	"U-D5": "Gold-upkeep 3.125 s / poor-shot 2.0 s penalties. Literals 100*f2t / 64*f2t [O] §1.4; port _GOLD_FIRE_STOP_S = 100/32 grounded but can_pay->1.0 mapping is PORT APPROXIMATION. Series D5-RES: (a) gold<4 upkeep unit ordered to fire, 20 attempts — cooldown==3.125, no cost deducted, no projectile; (b) 0-coal cannon ordered to fire, 20 attempts — cooldown==2.0. Port writes 1.0 for (b) (game.gd:4900) — known mismatch; stays [U] until §6-item-4.",
	"U-D6": "PredictShot-deny 1.0 s floor on top of mount pause. Order (cost+pause BEFORE deny in inc, AFTER deny in ontagstates) [O] §3.2; port has no PredictShot gate at all. Series D6-PRED: stand-chain mount (no fly/angle/immediate child or sync), 50 attackobj + 50 attackpoint attempts (100). Expectation per attempt: no projectiles entry, cooldown == max(pause_s, 1.0). Zero mismatches => wireable.",
	"U-D7": "Building shot-point :=0 clear vs MaxFloat(...,1) split. Both branches [O] building.inc/ontagstates.inc:402-413,438-449. Series D7-SHOTPT: tower with blocked shot-point arc, 30 attempts each vs obj + vs point. Expectation: cooldown==0.0 AND maxdelay==0.0 with order+STO dropped (not 1.0). Any 1.0 => [U] (port has no shot-point model).",
	"U-D8": "attackmaxdelay UI-only (no gate). Negative grep: no attackmaxdelay=0 gate [O] §3.3; port has no maxdelay field. Series D8-MAX: fire once, assert maxdelay_0 == cooldown_0, then assert next shot is allowed the tick cooldown hits 0 even though maxdelay>0 still (sticky). Any gate on maxdelay => [U].",
	"seed_convention": DONOR_ATTACK_DELAY_SEED_CONVENTION,
	"termination": DONOR_ATTACK_DELAY_TERMINATION,
	"claim": "NO PARITY CLAIM. All eight stay OPEN [U]. No delay invented, no behaviour changed, no port capture compared. Zero-mismatch across a FULL series is the ONLY closer; a port fallback never closes a [U]."
}

# §6 port change list — owner-applied patch recs recorded as CITES ONLY, NOT applied.
const DONOR_ATTACK_DELAY_PORT_PATCH_RECS := {
	"data_item_1": "data.gd:21-23 KEEP (grounded): FRAMES_TO_TIME=0.03125, PX_TO_M, TILE_M match dmscript.global:170-175 [O]. No change by this worker.",
	"data_item_2": "data.gd UNITS_BASE[*].weapons[].cd re-derive from mount pause frames: cd: <donor_pause_frames>*0.03125 + cite unit.script:<line>; melee pause 0 -> cd: 0.0; sids NOT in the tail table keep current value tagged PORT APPROXIMATION [U]-D1; never copy a neighbour sid. LIVE-SIM PATCH — owner-applied, NOT applied here (inert scope).",
	"game_item_3": "game.gd:4928 e.cooldown = w.cd * rof KEEP shape, fix inputs: w.cd = §1.3 pause_s; rof = player.script:1857/1971 product (rof_mult 0.7 grounded data.gd:2646-2649); add comment unit.script:10750-10789.",
	"game_item_4": "game.gd:4900 replace PORT APPROXIMATION 1.0 with donor 2.0: e.cooldown = 64.0 * Data.FRAMES_TO_TIME (unit.script:8208-8209), mirror to maxdelay when present; split it from the deny literal with per-line cites. NOT applied here.",
	"game_item_5": "game.gd:4906 keep 3.125, add cite unit.script:8187-8188 / miscext.script:1038; extend to building capture-block if ported, else tag [U]-D5.",
	"game_item_6": "game.gd:4910,4915,4920 tag PORT APPROXIMATION: 0.25 deploy-tick and 0.5 wall/ridge vetoes have NO donor counterpart (donor vetoes write literal 1.0, unit.script:8280-8281); route through helper item 8.",
	"game_item_7": "Add attackmaxdelay tracking: game.gd:1994 entity init add cooldown_max: 0.0 beside cooldown: 0.0; mirror every e.cooldown = X with e.cooldown_max = maxf(e.cooldown_max, X) for X in {w.cd*rof, 1.0, 2.0, 3.125}; NEVER gate on it. Cites dmscript.global:1737-1738, unit.script:10788-10789.",
	"game_item_8": "Add single-sourced deny helper (verbatim literal): func _deny_with_floor(e): e.cooldown = 1.0; e.cooldown_max = maxf(e.cooldown_max, 1.0) with cites onaclanimationreachedattack.inc:107-108,135-136,145-146; unit.script:7701-7702,8280-8281,8536-8537. Call from new PredictShot gate [U]-D6, wall/ridge vetoes, and future friendly-fire vetoes; cover both attackobj and attackpoint paths.",
	"game_item_9": "game.gd:4513 + 5347-5349 decay KEEP + cite unit.inc/nothing.inc:87-92 / building.inc/nothing.inc:28-29; fix 4739-4741 double-decrement: attackground subtracts dt a SECOND time on top of _tick_unit (donor decays once/tick) — delete :4739 line or tag PORT APPROXIMATION [U]-D1.",
	"game_item_10": "Telemetry/format: every value carries its unit.script / dmscript.global / misc.script / *.inc cite; every estimate keeps PORT APPROXIMATION + [U] + its §5 series; visual_parity_claim=false; unresolved = U-D1..U-D8 (+ carried F4/F5/F6/F7, G1-tail).",
	"status": "NO PARITY CLAIM. This worker applied NONE of these. data.gd holds only inert donor-text telemetry; game.gd is OUT OF SCOPE and was never opened for edit by this worker."
}

# ══════════════════════════════════════════════════════════════════════════════
# ─── DEC-U-TRAIN-TIME §§1-7 — DONOR TRAIN-TIME CENSUS (INERT TELEMETRY) ────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_train_time.md §1-§7,
#   §6 port change list items 1-3 and 6 (data.gd scope); donor read as TEXT only.
# Pin t_87f0f3c130b0: cossacks.exe sha256 87f0f3c1…4e16c, never executed,
#   never copied, never opened as target. NO GPU A/B frame, NO PARITY CLAIM.
# [O] verbatim donor literal with file:line · [D] deterministic reading of [O]
#   (frames × 0.03125 units / × 0.3125 buildings) · [U] unresolved with its §7
#   fixed-seed ZERO-MISMATCH capture. Every port train/build value stays [U].
# INERT DATA / TELEMETRY ONLY: no listener/consumer reads any DONOR_TRAINTIME_*
#   declaration; no gate, key, save version, UNITS_BASE / BUILDINGS_BASE /
#   UPGRADES_BASE value is changed; no game.gd edit is made here (its §6 items
#   4-5 are recorded as exact patch recommendations below and in the report).
# Never interpolate a neighbour (sid,nation) row; never invent a time.
# Preservation proof: this is an APPEND after every landed lane; .bak-TRAINTIME
#   is byte-identical to the pre-edit file except the coordinator-requested
#   4-line C2 tail-comment rewrite at :293-296 (no value/gate changed there).
# ══════════════════════════════════════════════════════════════════════════════

# §1 [O]/[D] — the only two converters and the SETTER fork. The fork is by
# setter, not by sid spelling: SetObjBuildingProperties (unit.script:478-484)
# uses BuildtimeToTime (×10); SetObjBaseSearchBuildVisionScore (:571-581) uses
# FramesToTime (×1). The DEC ticket's parenthetical shorthand swaps the two
# setter names; donor text and EV-TT-SET at §1/§4 of the report are followed.
const DONOR_TRAINTIME_TIME_BASE := {
	"frames_to_time": {"factor": 0.03125, "cite": "dmscript.global:174 gc_frames_to_time=0.03125; lib/misc.script:470-474 _misc_FramesToTime [O]"},
	"time_to_frames": {"factor": 32, "cite": "dmscript.global:175 gc_time_to_frames=32 [O]"},
	"buildtime_modifier": {"factor": 10, "cite": "dmscript.global:179 gc_buildtime_modifier=10 [O]"},
	"buildtime_to_time": {"factor": 0.3125, "expr": "val * gc_frames_to_time * gc_buildtime_modifier", "cite": "lib/misc.script:478-482 _misc_BuildtimeToTime [O]"},
	"building_setter": {"name": "SetObjBuildingProperties", "lines": "unit.script:478-484", "write": "if (buildtime<>-1) then objbase.buildtime := _misc_BuildtimeToTime(buildtime)", "seconds_per_frame": 0.3125, "cite": "unit.script:482-483 [O] EV-TT-SET"},
	"unit_setter": {"name": "SetObjBaseSearchBuildVisionScore", "lines": "unit.script:571-581", "write": "if (buildtime<>-1) then objbase.buildtime := _misc_FramesToTime(buildtime)", "seconds_per_frame": 0.03125, "cite": "unit.script:575-576 [O] EV-TT-SET"},
	"fork": "[D] by SETTER (building :478-484 ×0.3125 vs unit :571-581 ×0.03125), never by sid spelling; no third per-category constant exists [O] §1",
	"reverse_read": "btime := Round(objbase.buildtime*gc_time_to_frames/gc_buildtime_modifier) (unit.script:9109 [O])",
	"progress_per_hit": {"expr": "10*0.03125*1.15", "seconds": 0.359375, "cite": "dmscript.global:182 [O]; hit PATH itself [U]"},
	"keep_sentinel": "default = -1 = keep prior field value (unit.script:593 [O]/[D])",
	"dead_literals": "[D] {n} braces and c1-comments are dead, never adopted",
	"status": "[O]/[D] TEXT LAW ONLY — no converter is wired into live train/build timing.",
}

# §2 [O] census — P5 counted 118 SetObjBaseSearchBuildVisionScore call sites at
# unit.script:636-2082 (EV-TT-U). The report transcribes 114 effective rows with
# sid/nation scope + frames; all are copied here verbatim, none inferred from a
# neighbour. Seconds are frames × 0.03125 [D] and every row stays [U] until its
# Q-T-INF/Q-T-CAV/Q-T-ART fixed-seed capture passes with zero mismatch.
const DONOR_TRAINTIME_UNIT_CENSUS := {
	"census_sites": 118,
	"site_lines": "unit.script:636-2082",
	"transcribed_rows": 114,
	"cite": "DEC_U_train_time.md §2 / EV-TT-U [O]",
	"fork": "unit.script:571-581 SetObjBaseSearchBuildVisionScore -> FramesToTime, NO ×10 [O]",
	"effective_rule": "[D] for (sid,nation), the LAST non-default buildtime arg in its group->nation chain is live; default = keep",
	"status": "[U] per-(sid,nation) effective values pending §7; no neighbour (sid,nation) is ever interpolated.",
}

const DONOR_TRAINTIME_UNIT_ROWS := {
	"pikeman_group@636": {"scope": "GROUP pikeman,pikemanpol,pikemantur,pikemanrus,pikemansco,pikemanpor,pikemanspa,pikemanswi", "frames": 144, "seconds": 4.5, "expr": "144", "cite": "unit.script:636 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"pol_nation@647": {"scope": "NATION pol (buildtime only)", "frames": 96, "seconds": 3.0, "expr": "96", "cite": "unit.script:647 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"tur_nation@654": {"scope": "NATION tur,alg", "frames": 176, "seconds": 5.5, "expr": "176", "cite": "unit.script:654 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"rus_nation@661": {"scope": "NATION rus", "frames": 176, "seconds": 5.5, "expr": "176", "cite": "unit.script:661 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_nation@668": {"scope": "NATION sco", "frames": 128, "seconds": 4.0, "expr": "128", "cite": "unit.script:668 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"spa_nation@675": {"scope": "NATION spa", "frames": 176, "seconds": 5.5, "expr": "176", "cite": "unit.script:675 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"swi_nation@682": {"scope": "NATION swi", "frames": 160, "seconds": 5.0, "expr": "5*32=160", "cite": "unit.script:682 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"por_nation@689": {"scope": "NATION por", "frames": 128, "seconds": 4.0, "expr": "128 ({144} dead)", "cite": "unit.script:689 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"pikeman18_group@698": {"scope": "GROUP pikeman18,pikeman18swe", "frames": 40, "seconds": 1.25, "expr": "40", "cite": "unit.script:698 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"swe_nation@708": {"scope": "NATION swe", "frames": 48, "seconds": 1.5, "expr": "48", "cite": "unit.script:708 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"lightinfantry_group@717": {"scope": "GROUP lightinfantry,lightinfantrydip (mercenary-flagged `:721` — flag only, same row)", "frames": 32, "seconds": 1.0, "expr": "32", "cite": "unit.script:717 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"lightinfantry_group@726": {"scope": "GROUP lightinfantry (bmercenary arm)", "frames": 40, "seconds": 1.25, "expr": "40", "cite": "unit.script:726 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"roundshier_group@741": {"scope": "GROUP roundshier,roundshierdip,swordsmansco", "frames": 128, "seconds": 4.0, "expr": "128", "cite": "unit.script:741 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_nation@752": {"scope": "NATION sco, bmercenary arm", "frames": 224, "seconds": 7.0, "expr": "224", "cite": "unit.script:752 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_nation@761": {"scope": "NATION sco, non-mercenary arm (`:756` guard)", "frames": 48, "seconds": 1.5, "expr": "48", "cite": "unit.script:761 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeer_group@782": {"scope": "GROUP musketeer,musketeerpol,musketeernet,pandur,chasseur,highlander,serdiuk,jannisary,musketeersco (+2 further sids in full line)", "frames": 192, "seconds": 6.0, "expr": "192", "cite": "unit.script:782 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeerpol_nation@795": {"scope": "NATION musketeerpol", "frames": 144, "seconds": 4.5, "expr": "144", "cite": "unit.script:795 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeernet_nation@802": {"scope": "NATION musketeernet", "frames": 160, "seconds": 5.0, "expr": "160", "cite": "unit.script:802 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"pandur_nation@811": {"scope": "NATION pandur", "frames": 176, "seconds": 5.5, "expr": "5.5*32=176", "cite": "unit.script:811 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"chasseur_nation@820": {"scope": "NATION chasseur", "frames": 240, "seconds": 7.5, "expr": "7.5*32=240", "cite": "unit.script:820 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"highlander_nation@829": {"scope": "NATION highlander", "frames": 208, "seconds": 6.5, "expr": "6.5*32=208", "cite": "unit.script:829 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"serdiuk_nation@840": {"scope": "NATION serdiuk", "frames": 352, "seconds": 11.0, "expr": "352", "cite": "unit.script:840 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"jannisary_nation@849": {"scope": "NATION jannisary", "frames": 256, "seconds": 8.0, "expr": "256", "cite": "unit.script:849 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeersco_nation@858": {"scope": "NATION musketeersco", "frames": 224, "seconds": 7.0, "expr": "224", "cite": "unit.script:858 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"gauduk_sid@867": {"scope": "SID gauduk", "frames": 144, "seconds": 4.5, "expr": "144", "cite": "unit.script:867 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"pandurhun_sid@875": {"scope": "SID pandurhun", "frames": 208, "seconds": 6.5, "expr": "6.5*32=208", "cite": "unit.script:875 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"jagerpor_sid@884": {"scope": "SID jagerpor", "frames": 72, "seconds": 2.25, "expr": "2.25*32=72", "cite": "unit.script:884 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"jagerswi_sid@893": {"scope": "SID jagerswi", "frames": 272, "seconds": 8.5, "expr": "8.5*32=272", "cite": "unit.script:893 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeerspa_group@908": {"scope": "GROUP musketeerspa,musketeeraus,strelet", "frames": 600, "seconds": 18.75, "expr": "600", "cite": "unit.script:908 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeeraus_nation@920": {"scope": "NATION musketeeraus", "frames": 208, "seconds": 6.5, "expr": "208", "cite": "unit.script:920 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeerspa_nation@929": {"scope": "NATION musketeerspa", "frames": 240, "seconds": 7.5, "expr": "240", "cite": "unit.script:929 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"strelet_nation@937": {"scope": "NATION strelet", "frames": 272, "seconds": 8.5, "expr": "272", "cite": "unit.script:937 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"musketeer18_group@954": {"scope": "GROUP musketeer18,musketeer18pru,musketeer18bav,musketeer18sax (+den implied by `:986` arm)", "frames": 144, "seconds": 4.5, "expr": "144", "cite": "unit.script:954 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"pru_nation@967": {"scope": "NATION pru", "frames": 192, "seconds": 6.0, "expr": "192", "cite": "unit.script:967 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"bav_nation@975": {"scope": "NATION bav", "frames": 160, "seconds": 5.0, "expr": "160 ({225;180} dead)", "cite": "unit.script:975 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sax_nation@984": {"scope": "NATION sax", "frames": 144, "seconds": 4.5, "expr": "144 ({225;144} dead)", "cite": "unit.script:984 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"den_nation@993": {"scope": "NATION den", "frames": 176, "seconds": 5.5, "expr": "176 ({150;225;192} dead)", "cite": "unit.script:993 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"archer_group@1015": {"scope": "GROUP archer,archerdip,archertur,archerturdip,archersco", "frames": 48, "seconds": 1.5, "expr": "1.5*32=48 ({25;32} dead)", "cite": "unit.script:1015 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"tur_nation@1027": {"scope": "NATION tur", "frames": 96, "seconds": 3.0, "expr": "3*32=96", "cite": "unit.script:1027 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_nation@1037": {"scope": "NATION sco", "frames": 192, "seconds": 6.0, "expr": "192", "cite": "unit.script:1037 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_group@1050": {"scope": "GROUP sco mercenary arm (`bmercenary` `:1041`)", "frames": 40, "seconds": 1.25, "expr": "40", "cite": "unit.script:1050 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"officer_group@1068": {"scope": "GROUP officer,officerrus,officertur,officersco", "frames": 320, "seconds": 10.0, "expr": "320", "cite": "unit.script:1068 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"rus_nation@1081": {"scope": "NATION rus", "frames": 400, "seconds": 12.5, "expr": "400", "cite": "unit.script:1081 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"tur_nation@1087": {"scope": "NATION tur", "frames": 240, "seconds": 7.5, "expr": "240", "cite": "unit.script:1087 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_nation@1095": {"scope": "NATION sco", "frames": 320, "seconds": 10.0, "expr": "320", "cite": "unit.script:1095 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"officer18_sid@1105": {"scope": "SID officer18", "frames": 192, "seconds": 6.0, "expr": "192 ({150} dead)", "cite": "unit.script:1105 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"drummer_group@1118": {"scope": "GROUP drummer,drummerrus,drummertur,bagpiper,drummer18", "frames": 160, "seconds": 5.0, "expr": "160", "cite": "unit.script:1118 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"drummerfamily_group@1128": {"scope": "GROUP drummer-family (`:1124` bagpiper arm)", "frames": 224, "seconds": 7.0, "expr": "224", "cite": "unit.script:1128 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"drummerfamily_group@1135": {"scope": "GROUP drummer-family (`:1131` drummer18 arm)", "frames": 192, "seconds": 6.0, "expr": "192", "cite": "unit.script:1135 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"rus_nation@1142": {"scope": "NATION rus drummer arm", "frames": 192, "seconds": 6.0, "expr": "192", "cite": "unit.script:1142 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"tur_nation@1147": {"scope": "NATION tur drummer arm", "frames": 128, "seconds": 4.0, "expr": "128", "cite": "unit.script:1147 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"priest_group_stack@1157-1169-1177-1186": {"scope": "GROUP priest,pope,mullah,padre — four stacked calls (pope `:1169`=640f, mullah `:1177`=480f, padre `:1186`=25*32=800f all overwrite base `:1157`=640f)", "stack": [{"name": "base", "frames": 640, "seconds": 20.0, "cite": "unit.script:1157 [O]"}, {"name": "pope", "frames": 640, "seconds": 20.0, "cite": "unit.script:1169 [O]"}, {"name": "mullah", "frames": 480, "seconds": 15.0, "cite": "unit.script:1177 [O]"}, {"name": "padre", "frames": 800, "seconds": 25.0, "cite": "unit.script:1186 [O]"}], "cite": "unit.script:1157/:1169/:1177/:1186 [O] EV-TT-U", "status": "[O] four stacked calls; LAST non-default arg wins per group chain [U] until Q-T-INF"},
	"peaaus_group@1196": {"scope": "GROUP peaaus,peatur,pearus,peapol,peaspa,peaeng,peaukr,peasco (all peasants)", "frames": 400, "seconds": 12.5, "expr": "400", "cite": "unit.script:1196 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"rus_nation@1208": {"scope": "NATION rus peasant", "frames": 400, "seconds": 12.5, "expr": "400", "cite": "unit.script:1208 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"ukr_nation@1213": {"scope": "NATION ukr peasant", "frames": 360, "seconds": 11.25, "expr": "360", "cite": "unit.script:1213 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sco_nation@1218": {"scope": "NATION sco peasant", "frames": 400, "seconds": 12.5, "expr": "400", "cite": "unit.script:1218 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadier_group@1243": {"scope": "GROUP grenadier,grenadierdip,grenadierden,grenadierpru,grenadierbav,grenadiersax,grenadierhun", "frames": 192, "seconds": 6.0, "expr": "192 ({150;180} dead)", "cite": "unit.script:1243 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadierden_nation@1258": {"scope": "NATION grenadierden", "frames": 208, "seconds": 6.5, "expr": "208 ({150;180},c1-135 dead)", "cite": "unit.script:1258 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadierpru_nation@1266": {"scope": "NATION grenadierpru", "frames": 224, "seconds": 7.0, "expr": "224", "cite": "unit.script:1266 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadierbav_nation@1276": {"scope": "NATION grenadierbav", "frames": 192, "seconds": 6.0, "expr": "192 ({150;180} dead)", "cite": "unit.script:1276 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadiersax_nation@1287": {"scope": "NATION grenadiersax", "frames": 192, "seconds": 6.0, "expr": "192 ({135;150} dead)", "cite": "unit.script:1287 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadierhun_nation@1297": {"scope": "NATION grenadierhun", "frames": 208, "seconds": 6.5, "expr": "208", "cite": "unit.script:1297 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"grenadierhun_nation@1309": {"scope": "NATION grenadierhun mercenary arm (`bmercenary` `:1300`)", "frames": 48, "seconds": 1.5, "expr": "48", "cite": "unit.script:1309 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"croat_group@1327": {"scope": "GROUP croat,hussar,hussarpru,wingedhussar,cossacksich,cossacksichdip,hackapell,raidersco,hussarhun (+swe tail)", "frames": 528, "seconds": 16.5, "expr": "528 → 16.5", "cite": "unit.script:1327 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"croat_nation@1335": {"scope": "NATION croat", "frames": 504, "seconds": 15.75, "expr": "15.75*32=504 → 15.75", "cite": "unit.script:1335 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"hackapell_nation@1343": {"scope": "NATION hackapell", "frames": 576, "seconds": 18.0, "expr": "18*32=576 ({960} dead) → 18.0", "cite": "unit.script:1343 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"hussar_nation@1350": {"scope": "NATION hussar", "frames": 480, "seconds": 15.0, "expr": "15*32=480 ({528;475;570} dead) → 15.0", "cite": "unit.script:1350 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"hussarpru_nation@1358": {"scope": "NATION hussarpru", "frames": 360, "seconds": 11.25, "expr": "11.25*32=360 ({384;325;420} dead) → 11.25", "cite": "unit.script:1358 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"wingedhussar_nation@1367": {"scope": "NATION wingedhussar", "frames": 832, "seconds": 26.0, "expr": "832 ({1250} dead) → 26.0", "cite": "unit.script:1367 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"cossacksich_nation@1375": {"scope": "NATION cossacksich,cossacksichdip (non-merc arm)", "frames": 432, "seconds": 13.5, "expr": "432 ({550} dead) → 13.5", "cite": "unit.script:1375 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"cossacksich_nation@1383": {"scope": "NATION cossacksich mercenary arm (`bmercenary` `:1377`)", "frames": 80, "seconds": 2.5, "expr": "80 ({50} dead) → 2.5", "cite": "unit.script:1383 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"raidersco_nation@1396": {"scope": "NATION raidersco", "frames": 720, "seconds": 22.5, "expr": "720 → 22.5", "cite": "unit.script:1396 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"hussarhun_nation@1404": {"scope": "NATION hussarhun", "frames": 672, "seconds": 21.0, "expr": "672 → 21.0", "cite": "unit.script:1404 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"hussarswi_nation@1412": {"scope": "NATION hussarswi", "frames": 624, "seconds": 19.5, "expr": "19.5*32=624 ({384;325;420} dead) → 19.5", "cite": "unit.script:1412 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"reiter_group@1426": {"scope": "GROUP reiter,cuirassier,reiterswe,reiterpol,hetman,cossackdon,vityaz,cossackregister,spakh,mameluke (+lancersco/sipahi tails)", "frames": 768, "seconds": 24.0, "expr": "768 → 24.0", "cite": "unit.script:1426 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"cuirassier_nation@1443": {"scope": "NATION cuirassier", "frames": 720, "seconds": 22.5, "expr": "22.5*32=720 → 22.5", "cite": "unit.script:1443 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"reiterswe_nation@1450": {"scope": "NATION reiterswe", "frames": 720, "seconds": 22.5, "expr": "720 → 22.5", "cite": "unit.script:1450 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"guardcavalrysax_sid@1458": {"scope": "SID guardcavalrysax", "frames": 768, "seconds": 24.0, "expr": "768 → 24.0", "cite": "unit.script:1458 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"reiterpol_nation@1466": {"scope": "NATION reiterpol", "frames": 264, "seconds": 8.25, "expr": "264 ({300} dead) → 8.25", "cite": "unit.script:1466 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"hetman_nation@1475": {"scope": "NATION hetman", "frames": 528, "seconds": 16.5, "expr": "528 ({432;450} dead) → 16.5", "cite": "unit.script:1475 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"cossackdon_nation@1485": {"scope": "NATION cossackdon", "frames": 432, "seconds": 13.5, "expr": "432 ({550} dead) → 13.5", "cite": "unit.script:1485 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"vityaz_nation@1494": {"scope": "NATION vityaz", "frames": 816, "seconds": 25.5, "expr": "816 ({1500} dead) → 25.5", "cite": "unit.script:1494 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"cossackregister_nation@1502": {"scope": "NATION cossackregister", "frames": 336, "seconds": 10.5, "expr": "336 → 10.5", "cite": "unit.script:1502 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"spakh_nation@1511": {"scope": "NATION spakh", "frames": 288, "seconds": 9.0, "expr": "288 ({325} dead) → 9.0", "cite": "unit.script:1511 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"mameluke_nation@1520": {"scope": "NATION mameluke", "frames": 384, "seconds": 12.0, "expr": "384 → 12.0", "cite": "unit.script:1520 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"lancersco_nation@1529": {"scope": "NATION lancersco", "frames": 672, "seconds": 21.0, "expr": "672 → 21.0", "cite": "unit.script:1529 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"sipahi_nation@1538": {"scope": "NATION sipahi", "frames": 576, "seconds": 18.0, "expr": "18*32=576 → 18.0", "cite": "unit.script:1538 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoon_group@1556": {"scope": "GROUP dragoon,kingmusketeer,dragoon18fra,dragoonpol,dragoon18,dragoon18net,dragoon18pie,dragoon18dip (+dip)", "frames": 480, "seconds": 15.0, "expr": "15*32=480 ({624} dead; c1-1750 comment dead) → 15.0", "cite": "unit.script:1556 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoonpol_nation@1572": {"scope": "NATION dragoonpol", "frames": 432, "seconds": 13.5, "expr": "432 → 13.5", "cite": "unit.script:1572 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"kingmusketeer_nation@1580": {"scope": "NATION kingmusketeer", "frames": 864, "seconds": 27.0, "expr": "864 ({960;2000} dead) → 27.0", "cite": "unit.script:1580 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoon18fra_nation@1593": {"scope": "NATION dragoon18fra", "frames": 480, "seconds": 15.0, "expr": "480 → 15.0", "cite": "unit.script:1593 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoon18net_nation@1606": {"scope": "NATION dragoon18net", "frames": 768, "seconds": 24.0, "expr": "768 ({960;1600} dead) → 24.0", "cite": "unit.script:1606 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoon18pie_nation@1618": {"scope": "NATION dragoon18pie", "frames": 648, "seconds": 20.25, "expr": "20.25*32=648 ({960;1600} dead) → 20.25", "cite": "unit.script:1618 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"lightcavalry_sid@1630": {"scope": "SID lightcavalry", "frames": 672, "seconds": 21.0, "expr": "672 → 21.0", "cite": "unit.script:1630 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoon18_group@1642": {"scope": "GROUP dragoon18,dragoon18dip,lightcavalrydip (shared arm)", "frames": 720, "seconds": 22.5, "expr": "720 ({1750} dead) → 22.5", "cite": "unit.script:1642 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"dragoon18_group@1652": {"scope": "GROUP dragoon18 mercenary arm (`bmercenary` `:1645`)", "frames": 64, "seconds": 2.0, "expr": "64 → 2.0", "cite": "unit.script:1652 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"tatar_sid@1681": {"scope": "SID tatar", "frames": 360, "seconds": 11.25, "expr": "11.25*32=360 → 11.25", "cite": "unit.script:1681 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"cannon_sid@1717": {"scope": "SID cannon", "frames": 2400, "seconds": 75.0, "expr": "2400 ({3840} dead) → 75.0", "cite": "unit.script:1717 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"howitzer_sid@1748": {"scope": "SID howitzer", "frames": 3008, "seconds": 94.0, "expr": "3008 ({4800} dead) → 94.0", "cite": "unit.script:1748 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"mortar_sid@1781": {"scope": "SID mortar", "frames": 800, "seconds": 25.0, "expr": "800 → 25.0", "cite": "unit.script:1781 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"multicannon_sid@1808": {"scope": "SID multicannon", "frames": 1600, "seconds": 50.0, "expr": "1600 → 50.0", "cite": "unit.script:1808 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"framegun_sid@1839": {"scope": "SID framegun", "frames": 1600, "seconds": 50.0, "expr": "1600 → 50.0", "cite": "unit.script:1839 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"fishboat_sid@1864": {"scope": "SID fishboat", "frames": 1280, "seconds": 40.0, "expr": "1280 → 40.0", "cite": "unit.script:1864 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"yacht_group@1888": {"scope": "GROUP yacht,yachttur", "frames": 1536, "seconds": 48.0, "expr": "1536 → 48.0", "cite": "unit.script:1888 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"yacht_group@1918": {"scope": "GROUP yacht,yachttur c1-speed comment arm (`default,default{300}` — live value keeps `:1888`)", "frames": 1536, "seconds": 48.0, "expr": "keeps 1536 → 48.0 (comment 300 dead)", "cite": "unit.script:1918 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"galley_sid@1945": {"scope": "SID galley", "frames": 1600, "seconds": 50.0, "expr": "1600 → 50.0", "cite": "unit.script:1945 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"frigate_group@1974": {"scope": "GROUP frigate,xebec,battleship,chaika", "frames": 7360, "seconds": 230.0, "expr": "7360 → 230.0", "cite": "unit.script:1974 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"xebec_sid@1995": {"scope": "SID xebec (score-only arm, buildtime `default`)", "frames": 7360, "seconds": 230.0, "expr": "keeps 7360 → 230.0", "cite": "unit.script:1995 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"battleship_sid@2007": {"scope": "SID battleship", "frames": 12480, "seconds": 390.0, "expr": "12480 → 390.0", "cite": "unit.script:2007 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"chaika_sid@2023": {"scope": "SID chaika", "frames": 1280, "seconds": 40.0, "expr": "1280 → 40.0", "cite": "unit.script:2023 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"ferry_sid@2042": {"scope": "SID ferry", "frames": 1792, "seconds": 56.0, "expr": "1792 → 56.0", "cite": "unit.script:2042 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"unitbox_sid@2054": {"scope": "SID unitbox (debug)", "frames": 100, "seconds": 3.125, "expr": "100 → 3.125", "cite": "unit.script:2054 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"misdonkey_group@2060": {"scope": "GROUP misdonkey,mistrader,misflagman", "frames": 150, "seconds": 4.6875, "expr": "150 → 4.6875", "cite": "unit.script:2060 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
	"misgeneral_sid@2082": {"scope": "SID misgeneral", "frames": 150, "seconds": 4.6875, "expr": "150 → 4.6875", "cite": "unit.script:2082 [O] EV-TT-U", "status": "[U] until Q-T-INF/Q-T-CAV/Q-T-ART capture"},
}

# §3 [O] census — P6 counted ~45 effective SetObjBuilding* call sites at
# unit.script:2143-2577 (EV-TT-B); the report transcribes 26 sid-pattern rows with
# base frames + per-nation overrides. Seconds are frames × 0.3125 [D] via the
# building setter fork. The port's BUILDINGS_BASE[*].build_time values (×0.03125)
# are PORT APPROXIMATIONS and are NOT changed here; every donor row stays [U]
# until its Q-T-BLD capture passes with zero mismatch.
const DONOR_TRAINTIME_BUILDING_CENSUS := {
	"census_sites": "~45 effective SetObjBuilding* call sites",
	"site_lines": "unit.script:2143-2577",
	"transcribed_rows": 26,
	"cite": "DEC_U_train_time.md §3 / EV-TT-B [O]",
	"fork": "unit.script:478-484 SetObjBuildingProperties -> BuildtimeToTime, ×10 gc_buildtime_modifier [O]",
	"commonsid": "eur,rus,tur,spa,ukr,por art-family loop (unit.script:2113-2139); sid = commonsid + suffix [O]",
	"training_buildings": "center/bar/ba2/sta/art/dip/tem train units; the rest are construction-only but inventoried [O]",
	"status": "[U] until Q-T-BLD; port BUILDINGS_BASE stays untouched.",
}

const DONOR_TRAINTIME_BUILDING_ROWS := {
	"mil@2143-2150": {"sid_pattern": "`*mil` (mill)", "base_expr": "300 → 93.75", "override_text": "rus-family (`commonrus`): keeps 300 (hp/price only)", "cite": "unit.script:2143-2150 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 300, "base_seconds": 93.75},
	"por@2154-2187": {"sid_pattern": "`*por` (port)", "base_expr": "5000 → 1562.5", "override_text": "rus: keep; tur: keep; ukr: keep (price/hp only)", "cite": "unit.script:2154-2187 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 5000, "base_seconds": 1562.5},
	"mar@2191-2202": {"sid_pattern": "`*mar` (market)", "base_expr": "750 → 234.375", "override_text": "spa: 500 → 156.25; tur: keep 750 (hp/price arm)", "cite": "unit.script:2191-2202 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 750, "base_seconds": 234.375, "overrides_frames": {"spa": {"frames": 500, "seconds": 156.25}}},
	"sto@2206-2221": {"sid_pattern": "`*sto` (storage)", "base_expr": "100 → 31.25", "override_text": "spa/rus/tur: keep (price only)", "cite": "unit.script:2206-2221 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 100, "base_seconds": 31.25},
	"tow@2225-2256": {"sid_pattern": "`*tow` (stone tower)", "base_expr": "3937 ({4000} dead) → 1230.3125", "override_text": "rus 4725 → 1476.5625; tur 3150 → 984.375", "cite": "unit.script:2225-2256 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 3937, "base_seconds": 1230.3125, "overrides_frames": {"rus": {"frames": 4725, "seconds": 1476.5625}, "tur": {"frames": 3150, "seconds": 984.375}}},
	"swa@2260-2277": {"sid_pattern": "`*swa`,`*sga` (stone wall/gate)", "base_expr": "288 ({420} dead) → 90.0", "override_text": "rus 640 ({945} dead) → 200.0; tur 384 ({577} dead) → 120.0", "cite": "unit.script:2260-2277 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 288, "base_seconds": 90.0, "overrides_frames": {"rus": {"frames": 640, "seconds": 200.0}, "tur": {"frames": 384, "seconds": 120.0}}},
	"ukrwwa@2287-2309": {"sid_pattern": "`ukrwwa,ukrwga` (wooden wall/gate)", "base_expr": "18 ({26} dead) → 5.625", "override_text": "ukr: 26 ({39} dead) → 8.125", "cite": "unit.script:2287-2309 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 18, "base_seconds": 5.625, "overrides_frames": {"ukr": {"frames": 26, "seconds": 8.125}}},
	"gol@2313": {"sid_pattern": "`*gol,*iro,*coa` (mines)", "base_expr": "300 → 93.75", "override_text": "none (price/produce only)", "cite": "unit.script:2313 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 300, "base_seconds": 93.75},
	"csidcen@2371-2400": {"sid_pattern": "`csid+cen` (town center)", "base_expr": "500 → 156.25", "override_text": "aus: 150 → 46.875 (live!); fra/eng/spa/pol/swe/pru/ven/den/net: keep 500 (hp/price only); tur: keep; default-region arm `:2382` keep", "cite": "unit.script:2371-2400 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 500, "base_seconds": 156.25, "overrides_frames": {"aus": {"frames": 150, "seconds": 46.875}}},
	"farm@2403-2417": {"sid_pattern": "farm (`csid`-farm block; `usage=farm`)", "base_expr": "100 → 31.25", "override_text": "all listed nations: keep (price/costpercent only; tur/ukr costpercent-only arms)", "cite": "unit.script:2403-2417 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 100, "base_seconds": 31.25},
	"csidaca@2421-2438": {"sid_pattern": "`csid+aca` (academy)", "base_expr": "2000 → 625.0", "override_text": "rus 2700 → 843.75; ukr 150 → 46.875; tur/alg 500 → 156.25; rest keep", "cite": "unit.script:2421-2438 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 2000, "base_seconds": 625.0, "overrides_frames": {"rus": {"frames": 2700, "seconds": 843.75}, "ukr": {"frames": 150, "seconds": 46.875}, "tur": {"frames": 500, "seconds": 156.25}, "alg": {"frames": 500, "seconds": 156.25}}},
	"csidart@2440-2450": {"sid_pattern": "`csid+art` (artillery depot)", "base_expr": "787 → 245.9375", "override_text": "ukr/tur: keep (price only)", "cite": "unit.script:2440-2450 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 787, "base_seconds": 245.9375},
	"csiddip@2452-2460": {"sid_pattern": "`csid+dip` (diplomatic center)", "base_expr": "1000 → 312.5", "override_text": "rus/ukr/tur/alg: keep (price only)", "cite": "unit.script:2452-2460 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 1000, "base_seconds": 312.5},
	"csidtem@2462-2470": {"sid_pattern": "`csid+tem` (town hall/cathedral/mosque)", "base_expr": "500 → 156.25", "override_text": "fra 1000 → 312.5; tur/alg 300 → 93.75; rus/ukr: keep", "cite": "unit.script:2462-2470 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 500, "base_seconds": 156.25, "overrides_frames": {"fra": {"frames": 1000, "seconds": 312.5}, "tur": {"frames": 300, "seconds": 93.75}, "alg": {"frames": 300, "seconds": 93.75}}},
	"csidbar@2472": {"sid_pattern": "`csid+bar` (barracks)", "base_expr": "300 → 93.75", "override_text": "—", "cite": "unit.script:2472 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 300, "base_seconds": 93.75},
	"csidbararm2@2476": {"sid_pattern": "`csid+bar`-arm2 (second barracks call)", "base_expr": "250 → 78.125", "override_text": "—", "cite": "unit.script:2476 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 250, "base_seconds": 78.125},
	"barracks@2480": {"sid_pattern": "barracks price arm", "base_expr": "keep", "override_text": "—", "cite": "unit.script:2480 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": null, "base_seconds": null, "keep": true},
	"barracks@2484": {"sid_pattern": "barracks price arm", "base_expr": "keep", "override_text": "—", "cite": "unit.script:2484 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": null, "base_seconds": null, "keep": true},
	"second@2488": {"sid_pattern": "second barracks-type block", "base_expr": "keep", "override_text": "—", "cite": "unit.script:2488 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": null, "base_seconds": null, "keep": true},
	"csidba2@2493": {"sid_pattern": "`csid+ba2` (18c barracks)", "base_expr": "18000 → 5625.0", "override_text": "—", "cite": "unit.script:2493 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 18000, "base_seconds": 5625.0},
	"csidstaarm@2497": {"sid_pattern": "`csid+sta`-arm (stable block 1)", "base_expr": "2000 → 625.0", "override_text": "—", "cite": "unit.script:2497 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 2000, "base_seconds": 625.0},
	"csidsta@2503-2511": {"sid_pattern": "`csid+sta` (stable block 2)", "base_expr": "2000 → 625.0", "override_text": "eng/rus/sco 1200 → 375.0; ukr 500 → 156.25; tur/alg 500 → 156.25", "cite": "unit.script:2503-2511 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 2000, "base_seconds": 625.0, "overrides_frames": {"eng": {"frames": 1200, "seconds": 375.0}, "rus": {"frames": 1200, "seconds": 375.0}, "sco": {"frames": 1200, "seconds": 375.0}, "ukr": {"frames": 500, "seconds": 156.25}, "tur": {"frames": 500, "seconds": 156.25}, "alg": {"frames": 500, "seconds": 156.25}}},
	"csidbla@2514-2519": {"sid_pattern": "`csid+bla` (blacksmith)", "base_expr": "300 → 93.75", "override_text": "fra costpercent-only; ukr 200 → 62.5; tur/alg 350 → 109.375", "cite": "unit.script:2514-2519 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 300, "base_seconds": 93.75, "overrides_frames": {"ukr": {"frames": 200, "seconds": 62.5}, "tur": {"frames": 350, "seconds": 109.375}, "alg": {"frames": 350, "seconds": 109.375}}},
	"misblg@2541": {"sid_pattern": "`misblg,misblg2` (mission blockhouse)", "base_expr": "4500 → 1406.25", "override_text": "—", "cite": "unit.script:2541 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 4500, "base_seconds": 1406.25},
	"misyurt@2556": {"sid_pattern": "`misyurt`", "base_expr": "100 → 31.25", "override_text": "—", "cite": "unit.script:2556 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 100, "base_seconds": 31.25},
	"miscommandcenter@2565-2577": {"sid_pattern": "`miscommandcenter` (two stacked calls)", "base_expr": "1000 → 312.5, then 100 → 31.25 (LAST wins → 100f live `[D]`)", "override_text": "—", "cite": "unit.script:2565/:2577 [O] EV-TT-B", "status": "[U] until Q-T-BLD capture", "base_frames": 100, "base_seconds": 31.25, "stack_frames": [1000, 100], "last_wins": true},
}

# §4.1 [O] progress tick — re-pinned third pass (doprogressorders.inc:139-239).
const DONOR_TRAINTIME_TICK_LAW := {
	"deltatime": "deltatime := GetGameTime - lastprogresstime (guarded lastprogresstime>0, deltatime>0) — doprogressorders.inc:217-219 [O]",
	"divisor": "deltabuildtime := deltatime / objbase.buildtime — doprogressorders.inc:221 [O]; objbase[cid][id] is the §2 row of the TRAINED sid on the producing building's owner",
	"accumulate": "progress += deltabuildtime; if (progress>1) then progress := 1 — doprogressorders.inc:232-234 [O]",
	"ai_capturer_pin": "progress := 0.995 when an AI capturer is near — doprogressorders.inc:235-239 [O]",
	"completion": "amount -= 1 finite / progress := 0 / refill via _unit_ProduceUnit / amount=0 -> RemoveOrder / infinite rotate-to-tail — doprogressorders.inc:247-313 [O]; ORDER-SLOTS §4.4 re-pinned",
	"status": "[O]/[D] LAW TEXT ONLY — no tick consumer added or rewired; port progress path is [U] Q-T-DIFF/Q-T-GATE.",
}

# §4.2 [O] difficulty multiplier — AI-nonhuman ONLY. Human-owned buildings are
# NEVER scaled; the same objbase.buildtime divisor is scaled for AI.
const DONOR_TRAINTIME_DIFFICULTY_MULT := {
	"easy": 0.3, "normal": 0.5, "hard": 0.75, "veryhard": 1.0, "impossible": 1.25,
	"enum": {"none": -1, "easy": 0, "normal": 1, "hard": 2, "veryhard": 3, "impossible": 4},
	"guard": "if (baihuman) then <no scale> else case difficulty — doprogressorders.inc:222-231 [O]",
	"cite": "doprogressorders.inc:222-231; dmscript.global:781-786 [O] EV-TT-TICK",
	"status": "[O] TABLE ONLY — port behaviour [U] Q-T-DIFF; human ticks unscaled, AI ticks = human × (1/mult).",
}

# §4.4 [O] start gates — evaluated at bStart AND every tick; all AND-ed before
# the §4.1 tick runs. Frozen progress is the exact Q-T-GATE oracle.
const DONOR_TRAINTIME_START_GATES := {
	"bStart": "bStart := (progress = 0) — doprogressorders.inc:139 [O]",
	"farm": "farmused < farm, clamped by map-limit table 500/750/1000/1500/2200/3000/5000/8000 — :142-152, dmscript.global:1089-1098 [O]",
	"unit_cap": "total < 32000 (gc_MaxObjCount) — :164, dmscript.global:110 [O]",
	"artillery": "artcount[artind] < artlimit[artind] — :167 [O]",
	"port_place": "cMinDist = 3 + ship-exclusion radius — :19-33 [O]",
	"infinite_food": "if (not res.food < 500) and (price.food > 0) then bEnoughResInfinite := False — :184-200 (verbatim :199-200) [O]",
	"and_before_tick": "all gates AND-ed before the :217-234 tick — :205 [O]",
	"status": "[O] GATE LAWS ONLY — no port gate added/changed; port wiring [U] Q-T-GATE.",
}

# §4.3 [D] speed — NOT a train-duration law. Wall-clock rate changes only.
const DONOR_TRAINTIME_SPEED_NON_LAW := {
	"law": "[D] game speed changes the wall-clock engine clock only; game-time train duration is identical at every speed; no script scales GetGameTime / deltatime / objbase.buildtime",
	"cite": "control.script:551-570 speedfactor {7,10,14} -> WriteTimeSpeed; //SetTimeSpeedFactor is COMMENTED OUT at :563 [O]",
	"port_key": "data.gd DONOR_GAME_SPEED {slow 0.5, normal 1.0, fast 2.0, very_fast 4.0} stays UNCHANGED and is a port-side label set, NOT donor frames [U] Q-T-SPEED",
	"status": "NO multiplier on this path. NO PARITY CLAIM.",
}

# §5 [O-absence] verdicts — no timing rows outside unit.script §§2-3.
const DONOR_TRAINTIME_ABSENCE := {
	"buildings_script": "[O-absence] no buildings.script exists in the donor tree; buildings live in lib/unit.script + units/building.inc/*",
	"prop_files": "[O-absence] buildtime grep over data/objects/buildings/rusbar.prop = 0 hits; unit/art .prop files are art/collision records only",
	"dmscript_global": "[O] no per-sid rows — only gc_frames_to_time :174, gc_time_to_frames :175, gc_buildtime_modifier :179, gc_buildtime_progressperhit :182, gc_squad_holdmode_time :180, gc_economy_time :811",
	"status": "NEGATIVE VERDICTS ONLY — no timing row invented from an absent source.",
}

# §7 [U] register — seven fixed-seed captures, ZERO mismatches only.
const DONOR_TRAINTIME_SEED_CONVENTION := "Owner-executed (never this worker): fixed seed S, fixed map, fixed nation pair, full stock unless cost is varied; instrumented owner build logs building-Nothing-tick orders[0].{itype,produceid,amount,restype,progress} + gPlayer[pl].objbase[cid][id].buildtime at order time + res[] before/after. Wall-clock IRRELEVANT; compare game-time tick counts and slot dumps."
const DONOR_TRAINTIME_TERMINATION := "Run the FULL stated series. ANY single mismatch keeps the item [U] and FORBIDS wiring. ZERO mismatches across the full series closes it; three identical-seed runs must give an identical tick count and progress trace. Never interpolate a neighbour row, never invent a time, never let a port fallback close a [U]."
const DONOR_TRAINTIME_UNRESOLVED := {
	"Q-T-INF": "§2.1 infantry effective rows: call-site literals [O]; per-(sid,nation) EFFECTIVE value [U]. Capture: per (sid × nation), 1 barracks, full stock, order 1 unit, log progress each tick to completion. ZERO-MISMATCH: 3 identical-seed runs => identical tick count AND progress trace; ticks×dt_tick ≈ frames×0.03125 within one tick. Priority: pikeman-group (144/96/176), musketeer-group (192 + nation arms), grenadier-group, officer-group.",
	"Q-T-CAV": "§2.2 cavalry effective rows: same as above at a stable. Priority: hussar-group (528 vs 504/576/480/360 arms), reiter-group (768 vs 720/264/432/816), dragoon-group (480 + fra/net/pie arms). Mercenary arms (:752,:1383,:1652,:1309) each get their own capture — never infer from the non-mercenary twin.",
	"Q-T-ART": "§2.3 artillery/ship rows: literals [O], port values [U]. Capture at artillery depot / port. Priority: cannon 2400f, howitzer 3008f, battleship 12480f, frigate-group 7360f, ferry 1792f. ZERO-MISMATCH as above; ship rows additionally assert bPortPlaceIsFree gate behaviour (cMinDist=3) when blocked.",
	"Q-T-BLD": "§3 construction rows: literals [O], port values [U]. Capture: 1 peasant builds each pattern (*cen,*aca,*art,*bar,*sta,*bla,*tow,*mil,*mar,*sto,*swa,*wwa, mine trio) on seed S; log hp/buildprogress/stage per hit + completion tick. ZERO-MISMATCH: 3 runs identical; stage flips at floor(progress*4); per-nation override rows (aus-cen 150f, aca 2700/150/500, sta 1200/500, bla 200/350, tow 4725/3150) captured separately.",
	"Q-T-DIFF": "Difficulty scale :222-231: law [O], behaviour [U]. Capture: one human barracks + one AI-owned barracks per difficulty on seed S, same unit; log ticks-to-complete. ZERO-MISMATCH: human ticks unscaled; AI ticks = human × (1/0.3, 1/0.5, 1/0.75, 1, 1/1.25) within one tick, 3 runs identical.",
	"Q-T-GATE": "Start gates :139-205: laws [O], port wiring [U]. Capture: farm-capped, art-capped, unit-cap-near-32000, port-blocked, food-rule (res.food<500 + price.food>0) states; assert progress frozen (no :232 advance). ZERO-MISMATCH: 3 runs identical frozen traces + log line.",
	"Q-T-SPEED": "Speed invariance [D] §4.3. Capture: same research at each DONOR_GAME_SPEED mode (7/10/14); game-time ticks identical, wall-clock scales. ZERO-MISMATCH: per-mode 3-run identical tick counts.",
	"seed_convention": DONOR_TRAINTIME_SEED_CONVENTION,
	"termination": DONOR_TRAINTIME_TERMINATION,
	"no_parity_claim": "NO donor binary executed, no GPU A/B frame captured, no port capture compared by this worker. Closed items rest on donor text [O] with file:line; all seven items above stay OPEN [U].",
}

# §6 port change list — CITES / EXACT PATCH RECS ONLY; NONE applied here.
const DONOR_TRAINTIME_PORT_PATCH_RECS := {
	"data_item_1": "data.gd:1782+ UNITS[] build_time: re-source row by row to §2, keep tagged until capture. Anchors [O] now: peasant 400f (:1196; ukr 360f :1213), musketeer-base 192f (:782), officer 320f (:1068), dragoon-group 480f (:1556), cannon 2400f (:1717), howitzer 3008f (:1748), battleship 12480f (:2007). Rows without a cite stay PORT APPROXIMATION. NOT applied: no UNITS_BASE value changed.",
	"data_item_2": "data.gd:304-324 train-law block: ADD comment only — human owner unscaled (baihuman guard :223); divisor is the TRAINED sid's objbase.buildtime (:221); clamp 1 + 0.995 AI-capturer pin (:232-239); cite misc.script:470-482 + unit.script:571-581 for ×0.03125. Already-landed DONOR_AI_TRAIN_DIFFICULTY_MULT/DONOR_AI_CAPTURER_PROGRESS_PIN stay UNCHANGED; the same law is re-recorded in this inert append.",
	"data_item_3": "data.gd BUILDINGS table: add §3 construction rows as labelled data (donor_sid_pattern / donor_frames / seconds=frames×0.3125 / donor_lines); priorities *cen 500+aus 150 (:2371/:2377), *aca 2000/2700/150/500 (:2421-2435), *sta 2000/1200/500 (:2497-2510), *bla 300/200/350 (:2514-2519), *tow 3937/4725/3150 (:2225-2250), walls 288/640/384 + 18/26 (:2260-2289). Tag every value [U] until Q-T-BLD. Satisfied here by DONOR_TRAINTIME_BUILDING_ROWS only; BUILDINGS_BASE untouched.",
	"game_item_4": "EXACT PATCH REC — NOT APPLIED (game.gd OUT OF SCOPE): at game.gd:7779-7867 _tick_building keep progress += dt/buildtime × difficulty_mult (:7788-7795 cites :221-234, CORRECT shape); DELETE train_speed_mult/art_build_mult/build_mult from the sim path (move to cheat/test multiplier, never default-on — no donor counterpart on this path); ADD the 0.995 AI-capturer pin (:235-239) and the §4.4 start-gate AND before the tick; finite count stays HUD-side view of donor amount.",
	"game_item_5": "EXACT PATCH REC — NOT APPLIED (game.gd OUT OF SCOPE): at game.gd:5366-5377 train_unit append, cite batch law — {\"count\": affordable} in ONE job dict IS the amount-in-one-slot law (unit.script:6051) [O]. Do NOT fan a batch into N jobs.",
	"data_item_6": "Telemetry/format: every added line carries file:line + [O]/[D]/[U] tag; visual_parity_claim=false; unresolved register = §7 seven items.",
	"status": "NO PARITY CLAIM. This worker applied NO live-sim patch: no UNITS_BASE/BUILDINGS_BASE/UPGRADES_BASE value, gate, key or save version changed; no game.gd edit.",
}

const DONOR_TRAINTIME_TELEMETRY := {
	"visual_parity_claim": false,
	"donor_binary_executed": false,
	"wired_consumer": false,
	"units_rows": 114,
	"building_rows": 26,
	"unresolved": "Q-T-INF, Q-T-CAV, Q-T-ART, Q-T-BLD, Q-T-DIFF, Q-T-GATE, Q-T-SPEED",
	"scope": "data.gd append only; game.gd patch recs are recorded, not applied",
}
# ══════════════════════════════════════════════════════════════════════════════
# ─── DEC-U-RES-POINT §5.1 — ADDITIVE DONOR RESOURCE-POINT CONSTANTS ────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_res_point.md §1 [O]
#   (27/27 objcustom.cfg ResourcePoint blocks) + §5.1 cite-only port snippet.
# Parse law [O]: country.script:4111-4170 stores resourcePoint.x/z verbatim
#   (`:4167`,`:4169`) with y FORCED TO 0 (`:4168`, donor file y disabled).
# Container TCustomObjPoints.resourcePoint : TPos3f (classes.script:4272).
# NO PARITY CLAIM. All 27 offsets are donor text with objcustom.cfg:line cites;
#   no offset invented, no y component stored, no rotation/scale applied.
# INERT HERE: these constants are additive class-level data only; COORD wires
#   game.gd spawn() to direct `Data.RESOURCE_POINT` / `Data.PORT_SID_TO_DONOR`
#   (class-name access, NOT has_method/call). No existing value or gate changed.
# ══════════════════════════════════════════════════════════════════════════════

# DONOR resourcePoint offsets (objcustom.cfg via country.script:4164-4169;
# y forced 0 at :4168). Keyed by donor sid; port generic sids map by their own
# prop-file cites (§1 [D]4). Full 27-row donor table: x/z verbatim, y = 0.
const RESOURCE_POINT := {
	"swecen": Vector2(0.02, -3.68),   # objcustom.cfg:1452 [O]
	"prucen": Vector2(-0.06, -3.07),   # objcustom.cfg:3714 [O]
	"polcen": Vector2(-0.06, -2.63),   # objcustom.cfg:5274 [O]
	"turcen": Vector2(0.49, -3.41),   # objcustom.cfg:7597 [O]
	"algcen": Vector2(0.80, -3.20),   # objcustom.cfg:7744 [O]
	"spacen": Vector2(0.10, -3.35),   # objcustom.cfg:9020 [O]
	"eurmil": Vector2(-0.02, -1.61),   # objcustom.cfg:10952 [O]
	"ukrcen": Vector2(-1.30, -3.16),   # objcustom.cfg:12330 [O]
	"ruscen": Vector2(-0.28, -3.22),   # objcustom.cfg:14011 [O]
	"auscen": Vector2(-0.11, -3.34),   # objcustom.cfg:15051 [O]
	"engcen": Vector2(-0.50, -3.67),   # objcustom.cfg:16801 [O]
	"fracen": Vector2(0.01, -3.12),   # objcustom.cfg:18652 [O]
	"vencen": Vector2(0.07, -3.86),   # objcustom.cfg:20826 [O]
	"eursto": Vector2(0.20, -1.69),   # objcustom.cfg:21428 [O]
	"russto": Vector2(0.19, -1.50),   # objcustom.cfg:21591 [O]
	"tursto": Vector2(0.17, -1.67),   # objcustom.cfg:21766 [O]
	"rusmil": Vector2(0.04, -1.09),   # objcustom.cfg:21879 [O]
	"turmil": Vector2(-0.44, -2.56),   # objcustom.cfg:22078 [O]
	"dencen": Vector2(-0.10, -2.20),   # objcustom.cfg:29341 [O]
	"netcen": Vector2(0.43, -2.23),   # objcustom.cfg:32119 [O]
	"bavcen": Vector2(-1.45, -3.07),   # objcustom.cfg:34233 [O]
	"saxcen": Vector2(0.24, -3.25),   # objcustom.cfg:35963 [O]
	"scocen": Vector2(0.00, -0.72),   # objcustom.cfg:38373 [O]
	"porcen": Vector2(0.30, -3.17),   # objcustom.cfg:41015 [O]
	"huncen": Vector2(1.39, -2.25),   # objcustom.cfg:44398 [O]
	"piecen": Vector2(-0.25, -2.42),   # objcustom.cfg:47168 [O]
	"swicen": Vector2(-1.82, -2.51),   # objcustom.cfg:50098 [O]
}
const PORT_SID_TO_DONOR := {"sto": "eursto", "mil": "eurmil", "cen": "algcen", "dock": ""}
# sto→eursto.prop (data.gd:3059, as-read 2026-11-26); mil→eurmil.prop (:3053);
# cen→algcen.prop (:3068). `dock` has NO donor resourcePoint block, hence "".
# Port generic-sid rows: sto=(0.20,-1.69), mil=(-0.02,-1.61), cen=(0.80,-3.20).
# E1-OFF wiring / T-OFF / T-ROT traces stay [U] on game.gd side; NO PARITY CLAIM.

