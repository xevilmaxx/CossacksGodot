# anim3d.gd — donor-timed action/pose clock for the 3D variant.
#
# SCOPE: SINGLEPLAYER SKIRMISH ONLY (WAVE7_3D_VARIANT_CHARTER.md:37-38).
# GOVERNING RULE: leverage donor code, cite donor path:line, leave unreadable
# semantics UNVERIFIED (WAVE7_3D_VARIANT_CHARTER.md:29-36).
#
# WHAT THIS MODULE IS:
#   A deterministic donor-frame clock. For a sim action name it resolves the
#   donor AAF inclusive frame range and converts the caller's time t into the
#   exact donor frame index at the donor's 30 fps. It publishes that frame as a
#   "pose request" on the entity so a 3D entity renderer can consume it.
#
# WHAT THIS MODULE IS NOT:
#   It is NOT donor-faithful skeletal animation. V7-2 proved the donor .oss skin
#   payload is readable but the BONE PARENT HIERARCHY is absent, so no donor
#   rig may be reconstructed (docs/coord_swarm_2026-11-24/reports/
#   V72_mesh_conversion_feasibility.md:180-186, :264-284, Table B1 :380-386).
#   No morph/skin GLB exists in the project, and no sprite sheet or bake is used
#   here per owner directive (WAVE7_3D_VARIANT_CHARTER.md:40-57).
#   Consequently every returned status is labelled:
#       PORT APPROXIMATION — NOT DONOR PARITY
#   and the VISUAL result is reported UNVERIFIED. The frame numbers and timing
#   are donor-backed; the deformation is not.
#
# DONOR CITATIONS (all private-use, read-only bytes/ASCII; no donor binary run):
#   data\animations\aaf\peaukr.aaf:1-20  — 18 named actions, inclusive ranges,
#       "walk",1,20,morph at :5; AAF dialect decoded at docs/decomp/DC_FORMATS.md:96-109.
#   data\actors\units\peaukr.oss byte 0 — <6i k,fps,b,v,fc,t> header; layout at
#       docs/decomp/DC_FORMATS.md:46-64; verified k=483, fps=30, b=20 and exact
#       size closure at reports/V72_mesh_conversion_feasibility.md:159, :163-165.
#
# NO RNG. NO SPRITE SHEETS. NO BAKE. TABS ONLY.
extends Node

# Donor fps from the .oss header second int (see header citation above).
# NOT an invented cadence: 30 fps is measured on three donors in V7-2.
const DONOR_FPS: float = 30.0

# Exact label mandated by V7-2 §4.4 / Table C (reports/V72...:305-311, :400-410)
# and by WAVE7_3D_VARIANT_CHARTER.md:54-57. Never omit it.
const PORT_LABEL: String = "PORT APPROXIMATION — NOT DONOR PARITY"

# Why no donor-parity skin is possible today (V7-2 §3.3 item 1, :180-183).
const BLOCKED_RIG: String = "BLOCKED: donor bone parent hierarchy unreadable (V7-2 §3.3.1 / Table B1)"

# All 18 action ranges from data\animations\aaf\peaukr.aaf:3-20.
# Value = [first_frame, last_frame, donor_line, type_token]. Bounds are INCLUSIVE
# (docs/decomp/DC_FORMATS.md:109). No frame value is invented here.
const AAF_ACTIONS: Dictionary = {
	"idle": [64, 113, 3, "morph"],
	"idle0": [64, 113, 4, "morph"],
	"walk": [1, 20, 5, "morph"],
	"death": [115, 149, 6, "morph"],
	"attack0": [237, 254, 7, "morph"],
	"workfood": [278, 299, 8, "morph"],
	"workwood": [237, 254, 9, "morph"],
	"workstone": [217, 234, 10, "morph"],
	"idlefood": [405, 454, 11, "morph"],
	"idlewood": [354, 403, 12, "morph"],
	"idlestone": [303, 352, 13, "morph"],
	"walkfood": [257, 276, 14, "morph"],
	"walkwood": [22, 41, 15, "morph"],
	"walkstone": [43, 62, 16, "morph"],
	"construct": [186, 198, 17, "morph"],
	"reaction": [456, 481, 18, "morph"],
	"prepare0": [64, 65, 19, "morph"],
	"unprepare0": [64, 65, 20, "morph"],
}

# PORT-LEVEL alias only (not a donor statement): the 2D sim emits "attack" at
# world.gd:475-476 while the donor AAF names the clip "attack0" at :7.
# Marked as an assumption in the returned status; not claimed as donor parity.
const ACTION_ALIAS: Dictionary = {
	"attack": "attack0",
}

# Key written onto an entity Dictionary (or Object metadata) per play() call.
const POSE_KEY: String = "anim3d_pose"

var _game = null
var _entities = null


# ---------------------------------------------------------------------------
# EXACT CONTRACT API
# ---------------------------------------------------------------------------

# Store the sim and the 3D entity renderer. Neither is used to fabricate rig
# data: this module only computes donor frame numbers and publishes them.
func bind(game, entities) -> void:
	_game = game
	_entities = entities


# Resolve action -> donor frame at donor 30 fps and publish a pose request.
# Returns a Dictionary status. "ok" means the DONOR-TIMED CLOCK was computed;
# it never means donor-parity visual deformation was achieved.
func play(e, action, t):
	var requested := str(action)
	var donor_action: String = str(ACTION_ALIAS.get(requested, requested))
	var aliased: bool = donor_action != requested
	if not AAF_ACTIONS.has(donor_action):
		return _unknown(requested, aliased)

	var row: Array = AAF_ACTIONS[donor_action]
	var first: int = int(row[0])
	var last: int = int(row[1])
	var line: int = int(row[2])
	var kind: String = str(row[3])
	var frame: int = _frame_at(first, last, t)

	var donor_cite := "data/animations/aaf/peaukr.aaf:%d" % line
	var pose: Dictionary = {
		"action": donor_action,
		"requested": requested,
		"frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": kind,
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
	}
	_publish(e, pose)
	return {
		"ok": true,
		"action": donor_action,
		"requested": requested,
		"aliased": aliased,
		"frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": kind,
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED — no donor bone hierarchy, no morph/skin asset applied",
		"verified": false,
		"loop": "UNVERIFIED — AAF entries carry no loop flag; all are 'morph' (peaukr.aaf:3-20)",
		"pose": pose,
	}


# ---------------------------------------------------------------------------
# Helpers (donor-backed, deterministic, no RNG)
# ---------------------------------------------------------------------------

# Inclusive-frame lookup. Returns {} when the donor AAF has no such action.
func action_info(action) -> Dictionary:
	var key := str(action)
	if ACTION_ALIAS.has(key):
		key = str(ACTION_ALIAS[key])
	if not AAF_ACTIONS.has(key):
		return {}
	var row: Array = AAF_ACTIONS[key]
	return {
		"action": key,
		"first": int(row[0]),
		"last": int(row[1]),
		"donor": "data/animations/aaf/peaukr.aaf:%d" % int(row[2]),
		"kind": str(row[3]),
	}


# Donor frame index for time t in seconds at the donor's 30 fps.
# Frame a occupies [a/30, (a+1)/30); fposmod loops the span deterministically.
func _frame_at(first: int, last: int, t) -> int:
	var span: int = maxi(1, last - first + 1)
	var donor_s := float(t) * DONOR_FPS
	var offset := int(floor(fposmod(donor_s, float(span))))
	if offset >= span:
		offset = span - 1
	return first + offset


func _unknown(requested: String, aliased: bool) -> Dictionary:
	return {
		"ok": false,
		"action": "",
		"requested": requested,
		"aliased": aliased,
		"frame": -1,
		"fps": DONOR_FPS,
		"range": [],
		"donor": "UNVERIFIED — no readable AAF entry for '%s'" % requested,
		"kind": "UNVERIFIED",
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
		"reason": "action not present in data/animations/aaf/peaukr.aaf:3-20",
	}


# Entities in this sim are Dictionaries (game.gd:82); accept Object metadata too
# so a Node3D-based entity can read the same pose request without a type error.
func _publish(e, pose: Dictionary) -> void:
	if e is Dictionary:
		(e as Dictionary)[POSE_KEY] = pose
	elif e is Object:
		(e as Object).set_meta(POSE_KEY, pose)
