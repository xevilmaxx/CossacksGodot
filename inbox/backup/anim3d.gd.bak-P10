# anim3d.gd — donor-sampled flat-root morph/pose source for the 3D variant.
#
# SCOPE: SINGLEPLAYER SKIRMISH ONLY (WAVE7_3D_VARIANT_CHARTER.md:37-38).
# GOVERNING RULE: leverage donor code, cite donor path:line, leave unreadable
# semantics UNVERIFIED (WAVE7_3D_VARIANT_CHARTER.md:29-36).
#
# WHAT THIS MODULE IS NOW (V7-64):
#   A deterministic donor-frame clock PLUS a donor-sampled flat-root skinner.
#   The readable part of the donor .oss payload (vertices, per-vertex weights,
#   per-bone position+quaternion tracks) is translated verbatim from
#   variant3d/tools/bake_sprites.py into GDScript:
#       read_oss  :91-103   -> parse_donor_oss()
#       qmat      :118-129  -> _qmat()
#       skin      :131-143  -> skin_vertices()
#       sample    :145-152  -> sample_frames()
#   Given a registered donor skin for a sid, pose_for()/play() return the ACTUAL
#   skinned vertex array at the resolved donor AAF frame. That array is a donor
#   morph target in donor Z-up metres, index-for-index identical to the bind
#   vertices written to assets/models/obj/<sid>.obj by convert_models.py:43-66,
#   :109-125 (both readers consume the same first vertex block of the same
#   .oss). The entity renderer can therefore replace its static mesh vertices
#   with this array after applying its existing bbox/Y-up transform.
#
# WHAT THIS MODULE IS STILL NOT:
#   It is NOT donor-faithful SKELETAL animation. V7-2 proved the donor .oss skin
#   payload is readable but the BONE PARENT HIERARCHY is absent; the skin below
#   applies every bone track DIRECTLY to the bind vertex (flat root), exactly
#   as bake_sprites.skin does. No parent matrix is invented
#   (V72_mesh_conversion_feasibility.md:180-186, :264-284, Table B1 :380-386).
#   There is no sprite sheet, no PNG bake, no 2D bake output and no RNG.
#   Every status keeps the label:
#       PORT APPROXIMATION — NOT DONOR PARITY
#   and the VISUAL result stays UNVERIFIED until a frame A/B proves it.
#
# V7-78 — SHIPPED SKIN ASSETS (automatic, no manual registration):
#   variant3d/tools/convert_skins.py exports a deterministic donor-frame SUBSET
#   to res://assets/models/skin/<sid>.json + index.json. _ensure_shipped_skins()
#   loads that index lazily on first bind()/has_skin()/pose_for() call and
#   registers every sid itself. The shipped runtime therefore morphs units
#   WITHOUT any probe calling register_skin()/load_skin_from_donor(). No donor
#   bytes are read at runtime; only the offline-converted JSON assets.
#
# DONOR CITATIONS (all private-use, read-only bytes/ASCII; no donor binary run):
#   data\animations\aaf\peaukr.aaf:1-20  — 18 named actions, inclusive ranges,
#       "walk",1,20,morph at :5; AAF dialect at docs/decomp/DC_FORMATS.md:96-109.
#   data\actors\units\peaukr.oss byte 0 — <6i k,fps,b,v,fc,t> header; layout at
#       docs/decomp/DC_FORMATS.md:46-64; measured k=483, fps=30, b=20, v=577,
#       fc=921, t=733, exact 312376-byte closure (V72 report :159, :163-165).
#   variant3d\tools\bake_sprites.py:91-103, :118-129, :131-143, :145-152 —
#       the donor skin math copied here, never re-derived from donor bytes.
#   variant3d\tools\convert_models.py:43-66, :109-125 — identical vertex order
#       in the shipped OBJ (morph index i == OBJ vertex i).
#
# TABS ONLY. NO RNG. NO SPRITE SHEETS. NO 2D BAKE OUTPUTS.
extends Node

# Donor fps from the .oss header second int (see header citation above).
# NOT an invented cadence: 30 fps is measured on three donors in V7-2.
const DONOR_FPS: float = 30.0

# Exact label mandated by V7-2 §4.4 / Table C (reports/V72...:305-311, :400-410)
# and by WAVE7_3D_VARIANT_CHARTER.md:54-57. Never omit it.
const PORT_LABEL: String = "PORT APPROXIMATION — NOT DONOR PARITY"

# Why no donor-parity skin is possible today (V7-2 §3.3 item 1, :180-183).
const BLOCKED_RIG: String = "BLOCKED: donor bone parent hierarchy unreadable (V7-2 §3.3.1 / Table B1); flat-root skin only"

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
const ACTION_ALIAS: Dictionary = {
	"attack": "attack0",
}

# Key written onto an entity Dictionary (or Object metadata) per play() call.
const POSE_KEY: String = "anim3d_pose"

# Honest provenance tags for the payload. "donor_flat_root_morph" means the
# verts are real donor skin output; "donor_timing_only" means there was no
# readable skin for that sid and only the donor frame number is available.
const POSE_SOURCE_MORPH: String = "donor_flat_root_morph"
const POSE_SOURCE_TIMING: String = "donor_timing_only"
const MORPH_COORD: String = "donor Z-up metres; vertex i == assets/models/obj/<sid>.obj vertex i (bake_sprites.py:94 / convert_models.py:47)"
const SKIN_CITE: String = "variant3d/tools/bake_sprites.py:118-143 (qmat + skin)"
const OSS_CITE: String = "data/actors/units/<sid>.oss <6i k,fps,b,v,fc,t> (docs/decomp/DC_FORMATS.md:46-64)"

# V7-78: shipped donor-derived skin assets, written offline by
# variant3d/tools/convert_skins.py. Never read the private donor at runtime.
const SKIN_INDEX_PATH: String = "res://assets/models/skin/index.json"
const SKIN_ASSET_DIR: String = "res://assets/models/skin/"
const SHIPPED_SKIN_SOURCE: String = "donor_oss_subset_v1"

var _game = null
var _entities = null
var _skins: Dictionary = {}     # sid -> normalised donor skin Dictionary
var last_error: String = ""     # reason for the last failed parse/register
# V7-78 automatic shipped-skin load state (lazy, once, deterministic).
var _shipped_loaded: bool = false
var _shipped_count: int = 0
var _shipped_bytes: int = 0
var _shipped_error: String = ""


# ---------------------------------------------------------------------------
# EXACT CONTRACT API (V73_ATOMIC_CONTRACT.md:17 — signatures unchanged)
# ---------------------------------------------------------------------------

# Store the sim and the 3D entity renderer. Neither is used to fabricate rig
# data: this module only computes donor frame numbers and samples donor skin.
func bind(game, entities) -> void:
	_game = game
	_entities = entities
	_ensure_shipped_skins()


# Resolve action -> donor frame at donor 30 fps, sample the registered donor
# skin at that frame when one exists, and publish the pose request.
# "ok" means the DONOR-TIMED CLOCK was computed; it never means donor-parity
# visual deformation was achieved.
func play(e, action, t):
	_ensure_shipped_skins()
	var requested := str(action)
	var donor_action: String = str(ACTION_ALIAS.get(requested, requested))
	var aliased: bool = donor_action != requested
	var sid := _sid_of(e)
	var skin: Dictionary = {}
	if _skins.has(sid):
		skin = _skins[sid] as Dictionary
	# V7-78: a shipped skin carries its unit's OWN donor AAF ranges; without
	# one, the V7-18 peaukr.AAF_ACTIONS table is used unchanged.
	var row: Array = _action_range_for(sid, donor_action)
	if row.is_empty():
		return _unknown(requested, aliased)

	var first: int = int(row[0])
	var last: int = int(row[1])
	var line: int = int(row[2])
	var kind: String = str(row[3])
	var donor_cite: String = str(row[4]) if row.size() >= 5 else "data/animations/aaf/peaukr.aaf:%d" % line
	var frame: int = _frame_at(first, last, t)

	var morph := _morph_fields(skin, frame)
	var sample_frame: int = int(morph.get("sample_frame", frame))
	var pose: Dictionary = {
		"action": donor_action,
		"requested": requested,
		"frame": sample_frame,
		"requested_frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": kind,
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
		"sid": sid,
		"pose_source": str(morph["pose_source"]),
	}
	for key in morph.keys():
		pose[key] = morph[key]
	_publish(e, pose)
	return {
		"ok": true,
		"action": donor_action,
		"requested": requested,
		"aliased": aliased,
		"frame": sample_frame,
		"sample_frame": sample_frame,
		"requested_frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": kind,
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED — flat-root donor skin, no bone hierarchy, visual A/B pending",
		"verified": false,
		"loop": "UNVERIFIED — AAF entries carry no loop flag; all are 'morph' (peaukr.aaf:3-20)",
		"sid": sid,
		"pose_source": str(morph["pose_source"]),
		"skin_registered": not skin.is_empty(),
		"vertex_count": int(morph["vertex_count"]),
		"pose": pose,
	}


# ---------------------------------------------------------------------------
# DONOR SKIN DATA — read-only translation of bake_sprites.read_oss / skin
# ---------------------------------------------------------------------------

# Parse a donor .oss file into the normalised skin Dictionary consumed by
# skin_vertices(). Private-use, read-only; the caller supplies a readable path
# (the shipped game must NOT rely on this — register_skin() takes the converted
# data in production). Mirrors bake_sprites.py:91-103 byte for byte.
# Returns {} on failure; last_error holds the reason.
func parse_donor_oss(path: String) -> Dictionary:
	last_error = ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		last_error = "cannot open donor .oss: " + path
		return {}
	var file_bytes: int = f.get_length()
	# Donor files are little-endian ('<6i', '<3f', ...). Godot's get_32/get_float
	# default to NATIVE byte order, which is little-endian on the target (Win32);
	# documented rather than guessed.
	var k: int = f.get_32()
	var fps: int = f.get_32()
	var bones: int = f.get_32()
	var vcount: int = f.get_32()
	var fcount: int = f.get_32()
	var tcount: int = f.get_32()
	if k <= 0 or k > 100000 or fps <= 0 or bones <= 0 or bones > 4096 \
			or vcount <= 0 or vcount > 200000 or fcount < 0 or fcount > 500000 \
			or tcount < 0 or tcount > 500000:
		last_error = "implausible .oss header k=%d fps=%d b=%d v=%d fc=%d t=%d" % [k, fps, bones, vcount, fcount, tcount]
		f.close()
		return {}

	var verts := PackedVector3Array()
	verts.resize(vcount)
	for i in range(vcount):
		verts[i] = Vector3(f.get_float(), f.get_float(), f.get_float())
	# Faces, UVs and UV-face indices are not needed by the skinner; skip them
	# by SEEK, never by inventing replacements (bake_sprites.py:95-97).
	f.seek(f.get_position() + fcount * 12 + tcount * 8 + fcount * 12)
	var w_bone := PackedInt32Array()
	var w_val := PackedFloat32Array()
	var w_off := PackedInt32Array()
	w_off.resize(vcount + 1)
	for i in range(vcount):
		w_off[i] = w_bone.size()
		var n: int = f.get_32()
		if n < 0 or n > 16:
			last_error = "implausible weight count %d at vertex %d" % [n, i]
			f.close()
			return {}
		for _j in range(n):
			w_bone.append(f.get_32())
			w_val.append(f.get_float())
	w_off[vcount] = w_bone.size()
	var anim := PackedFloat32Array()
	anim.resize(bones * k * 7)
	for i in range(anim.size()):
		anim[i] = f.get_float()
	var consumed: int = f.get_position()
	f.close()
	if consumed != file_bytes:
		last_error = "size closure failed: consumed %d of %d bytes" % [consumed, file_bytes]
		return {}
	return {
		"ok": true,
		"source": "donor_oss",
		"path": path,
		"k": k,
		"fps": fps,
		"bones": bones,
		"v": vcount,
		"verts": verts,
		"w_bone": w_bone,
		"w_val": w_val,
		"w_off": w_off,
		"anim": anim,
		"bytes": consumed,
		"cite": OSS_CITE,
		"skin_math": SKIN_CITE,
	}


# Register a normalised skin (from parse_donor_oss) OR a raw Dictionary in the
# read_oss shape (verts/weights/anim as nested Arrays, e.g. from a converted
# JSON). No motion is invented: only the arrays donor actually contains.
func register_skin(sid, skin: Dictionary) -> bool:
	last_error = ""
	var key := str(sid)
	if key == "":
		last_error = "empty sid"
		return false
	var norm: Dictionary = skin
	if not skin.has("w_off"):
		norm = _normalise_raw(skin)
	if norm.is_empty():
		return false
	if not _valid_skin(norm):
		return false
	_skins[key] = norm
	return true


func has_skin(sid) -> bool:
	_ensure_shipped_skins()
	return _skins.has(str(sid))


func unregister_skin(sid) -> void:
	_skins.erase(str(sid))


func skin_info(sid) -> Dictionary:
	_ensure_shipped_skins()
	var skin: Dictionary = {}
	if _skins.has(str(sid)):
		skin = _skins[str(sid)] as Dictionary
	if skin.is_empty():
		return {"registered": false, "sid": str(sid)}
	var out := {
		"registered": true,
		"sid": str(sid),
		"source": str(skin.get("source", "?")),
		"k": int(skin.get("k", 0)),
		"fps": int(skin.get("fps", 0)),
		"bones": int(skin.get("bones", 0)),
		"verts": int(skin.get("v", 0)),
		"weight_pairs": (skin["w_bone"] as PackedInt32Array).size(),
		"cite": str(skin.get("cite", "")),
		"skin_math": str(skin.get("skin_math", "")),
	}
	if bool(skin.get("compact", false)):
		out["compact"] = true
		out["shipped_asset"] = str(skin.get("asset", ""))
		out["sample_frames"] = (skin.get("frames", []) as Array).duplicate()
		out["actions"] = (skin.get("actions", {}) as Dictionary).keys()
		out["label"] = str(skin.get("label", PORT_LABEL))
		out["visual"] = "UNVERIFIED"
	return out


# Parse a donor file AND register it under sid. Convenience for tools/probes.
func load_skin_from_donor(sid, path: String) -> bool:
	var skin := parse_donor_oss(path)
	if skin.is_empty():
		return false
	return register_skin(str(sid), skin)


# V7-78 observability: how many shipped skins were auto-registered, from which
# index and with what total on-disk size. No donor path is touched at runtime.
func shipped_skin_info() -> Dictionary:
	_ensure_shipped_skins()
	return {
		"auto_loaded": _shipped_count,
		"index": SKIN_INDEX_PATH,
		"asset_dir": SKIN_ASSET_DIR,
		"total_bytes": _shipped_bytes,
		"error": _shipped_error,
		"registered_sids": _skins.keys(),
		"label": PORT_LABEL,
		"visual": "UNVERIFIED",
	}


# Honest summary of the readable / unreadable split for integration agents.
func capabilities() -> Dictionary:
	_ensure_shipped_skins()
	return {
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"shipped_skins": _shipped_count,
		"shipped_skin_bytes": _shipped_bytes,
		"shipped_skin_index": SKIN_INDEX_PATH,
		"readable": [
			"donor .oss header <6i k,fps,b,v,fc,t> (docs/decomp/DC_FORMATS.md:46-64)",
			"donor .oss verts / per-vertex bone+weight pairs / flat bone tracks (bake_sprites.py:91-103)",
			"donor AAF inclusive action ranges (peaukr.aaf:3-20)",
			"flat-root skin output via bake_sprites.skin (bake_sprites.py:118-143)",
		],
		"unreadable": [
			"donor bone PARENT hierarchy (V7-2 3.3 / Table B1)",
			"donor-to-god quaternion convention (V7-2 open question 2)",
			"AAF loop/clamp flag (peaukr.aaf:3-20 carries only 'morph')",
		],
		"coord": MORPH_COORD,
		"visual": "UNVERIFIED",
		"registered_sids": _skins.keys(),
	}


# ---------------------------------------------------------------------------
# DONOR MORPH SAMPLING
# ---------------------------------------------------------------------------

# Exact flat-root skin at donor frame `fr`, copied from bake_sprites.skin
# (:131-143) with qmat from :118-129. Output is donor Z-up metres, index i ==
# bind vertex i == OBJ vertex i. If ref_frame >= 0, subtract the bone-0 root
# translation delta the same way bake_sprites.bake_unit does (:310-342); the
# default (-1) leaves the raw skin output untouched.
func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVector3Array:
	var empty := PackedVector3Array()
	if skin.is_empty() or not _valid_skin(skin):
		last_error = "skin_vertices: invalid skin"
		return empty
	var k: int = int(skin["k"])
	var bones: int = int(skin["bones"])
	var compact: bool = bool(skin.get("compact", false))
	# V7-78: a shipped skin shares this same skinner but stores only the
	# exported donor frames; map donor frame -> compact slot position first.
	var nf: int = int(skin.get("frame_count", k))
	var frame: int = _nearest_local(skin, fr) if compact else clampi(fr, 0, k - 1)
	var anim: PackedFloat32Array = skin["anim"]
	var mats: Array[PackedFloat32Array] = []
	var poss: Array[Vector3] = []
	mats.resize(bones)
	poss.resize(bones)
	for bi in range(bones):
		var base := (bi * nf + frame) * 7
		poss[bi] = Vector3(anim[base], anim[base + 1], anim[base + 2])
		mats[bi] = _qmat(anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
	var rx := 0.0
	var ry := 0.0
	if ref_frame >= 0:
		var rb: int = _nearest_local(skin, ref_frame) if compact else clampi(ref_frame, 0, k - 1)
		var hb := rb * 7
		var fb := frame * 7
		rx = anim[fb] - anim[hb]
		ry = anim[fb + 1] - anim[hb + 1]
	var verts: PackedVector3Array = skin["verts"]
	var w_bone: PackedInt32Array = skin["w_bone"]
	var w_val: PackedFloat32Array = skin["w_val"]
	var w_off: PackedInt32Array = skin["w_off"]
	var out := PackedVector3Array()
	out.resize(verts.size())
	for i in range(verts.size()):
		var vv: Vector3 = verts[i]
		var sx := 0.0
		var sy := 0.0
		var sz := 0.0
		for j in range(w_off[i], w_off[i + 1]):
			var bi: int = w_bone[j]
			var w: float = w_val[j]
			var m: PackedFloat32Array = mats[bi]
			var p: Vector3 = poss[bi]
			sx += w * (m[0] * vv.x + m[1] * vv.y + m[2] * vv.z + p.x)
			sy += w * (m[3] * vv.x + m[4] * vv.y + m[5] * vv.z + p.y)
			sz += w * (m[6] * vv.x + m[7] * vv.y + m[8] * vv.z + p.z)
		out[i] = Vector3(sx - rx, sy - ry, sz)
	return out


# Frames a..b in DONOR ORDER, copied from bake_sprites.sample (:145-152).
# Python's round() is half-to-even; _py_round_i() reproduces it so sampled
# morph targets are byte-for-byte the same frame indices the 2D bake uses.
func sample_frames(first: int, last: int, n: int) -> Array[int]:
	var out: Array[int] = []
	if last <= first:
		out.append(first)
		return out
	var total: int = last - first + 1
	if total <= n:
		for fr in range(first, last + 1):
			out.append(fr)
		return out
	if n > 1:
		for i in range(n):
			out.append(first + _py_round_i(float(last - first) * float(i) / float(n - 1)))
		return out
	out.append(first)
	return out


# THE HANDOFF CALL. Returns the donor morph target for `e` (entity Dictionary,
# Object with a `sid` property, or a sid String), action and sim time t.
# `verts` is a PackedVector3Array of donor-space skinned vertices (empty when
# no skin is registered); `pose_source` says which case applies. The entity
# renderer maps these through its existing bbox/Y-up transform and writes them
# to the mesh vertex buffer. No visual parity is claimed.
func pose_for(e, action, t) -> Dictionary:
	_ensure_shipped_skins()
	var requested := str(action)
	var donor_action: String = str(ACTION_ALIAS.get(requested, requested))
	var sid := _sid_of(e)
	var skin: Dictionary = {}
	if _skins.has(sid):
		skin = _skins[sid] as Dictionary
	var row: Array = _action_range_for(sid, donor_action)
	if row.is_empty():
		var u := _unknown(requested, donor_action != requested)
		u["verts"] = PackedVector3Array()
		u["pose_source"] = POSE_SOURCE_TIMING
		u["coord"] = MORPH_COORD
		return u
	var first: int = int(row[0])
	var last: int = int(row[1])
	var line: int = int(row[2])
	var frame: int = _frame_at(first, last, t)
	var donor_cite: String = str(row[4]) if row.size() >= 5 else "data/animations/aaf/peaukr.aaf:%d" % line
	var morph := _morph_fields(skin, frame)
	var sample_frame: int = int(morph.get("sample_frame", frame))
	var out: Dictionary = {
		"ok": true,
		"action": donor_action,
		"requested": requested,
		"sid": sid,
		"frame": sample_frame,
		"requested_frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": str(row[3]),
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
		"coord": MORPH_COORD,
	}
	for key in morph.keys():
		out[key] = morph[key]
	return out


# Produce the morph fields once, shared by play() and pose_for().
func _morph_fields(skin: Dictionary, frame: int) -> Dictionary:
	if skin.is_empty():
		return {
			"pose_source": POSE_SOURCE_TIMING,
			"skin_registered": false,
			"vertex_count": 0,
			"verts": PackedVector3Array(),
			"frame_clamped": false,
			"sample_frame": frame,
			"skin_math": "NONE — timing only",
		}
	var k: int = int(skin["k"])
	var src_frame: int = _nearest_exported_frame(skin, frame) if bool(skin.get("compact", false)) else frame
	var verts := skin_vertices(skin, src_frame)
	return {
		"pose_source": POSE_SOURCE_MORPH,
		"skin_registered": true,
		"vertex_count": verts.size(),
		"verts": verts,
		"frame_clamped": frame < 0 or frame >= k,
		"sample_frame": src_frame,
		"skin_math": str(skin.get("skin_math", SKIN_CITE)),
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


# Transposed donor rotation matrix, flattened row-major, copied verbatim from
# bake_sprites.qmat (:118-129, row-vector convention verified bone by bone).
func _qmat(x: float, y: float, z: float, w: float) -> PackedFloat32Array:
	var m00 := 1.0 - 2.0 * (y * y + z * z)
	var m01 := 2.0 * (x * y - z * w)
	var m02 := 2.0 * (x * z + y * w)
	var m10 := 2.0 * (x * y + z * w)
	var m11 := 1.0 - 2.0 * (x * x + z * z)
	var m12 := 2.0 * (y * z - x * w)
	var m20 := 2.0 * (x * z - y * w)
	var m21 := 2.0 * (y * z + x * w)
	var m22 := 1.0 - 2.0 * (x * x + y * y)
	return PackedFloat32Array([m00, m10, m20, m01, m11, m21, m02, m12, m22])


# Python round() is half-to-even for nonnegative frame indices.
func _py_round_i(x: float) -> int:
	var fl := floorf(x)
	var frac := x - fl
	if frac > 0.5:
		return int(fl) + 1
	if frac < 0.5:
		return int(fl)
	var f := int(fl)
	return f if f % 2 == 0 else f + 1


# Accept a Dictionary with a sid, an Object exposing a sid, or a sid String.
func _sid_of(e) -> String:
	if e is String:
		return e as String
	if e is Dictionary:
		return str((e as Dictionary).get("sid", ""))
	if e is Object:
		var v = (e as Object).get("sid")
		return str(v) if v != null else ""
	return ""


func _valid_skin(skin: Dictionary) -> bool:
	for key in ["k", "fps", "bones", "v", "verts", "w_bone", "w_val", "w_off", "anim"]:
		if not skin.has(key):
			last_error = "skin missing key: " + str(key)
			return false
	if int(skin["k"]) <= 0 or int(skin["bones"]) <= 0 or int(skin["v"]) <= 0:
		last_error = "skin has non-positive k/bones/v"
		return false
	# V7-78: a shipped subset skin stores only `frame_count` donor frames,
	# laid out as bones * frame_count * 7; a full parsed skin keeps bones*k*7.
	var nf: int = int(skin.get("frame_count", int(skin["k"])))
	if (skin["anim"] as PackedFloat32Array).size() != int(skin["bones"]) * nf * 7:
		last_error = "skin anim size != bones*frame_count*7"
		return false
	if (skin["verts"] as PackedVector3Array).size() != int(skin["v"]):
		last_error = "skin verts size != v"
		return false
	if (skin["w_off"] as PackedInt32Array).size() != int(skin["v"]) + 1:
		last_error = "skin w_off size != v+1"
		return false
	return true


# Convert a raw read_oss-shaped Dictionary (JSON-friendly nested Arrays) into
# the packed normal form. Strict: never fills missing data with invented values.
func _normalise_raw(raw: Dictionary) -> Dictionary:
	last_error = ""
	var vraw: Variant = raw.get("verts", null)
	var wraw: Variant = raw.get("weights", null)
	var araw: Variant = raw.get("anim", raw.get("animation", null))
	if not (vraw is Array) or not (wraw is Array) or not (araw is Array):
		last_error = "raw skin needs Array verts/weights/anim"
		return {}
	var verts := PackedVector3Array()
	var w_bone := PackedInt32Array()
	var w_val := PackedFloat32Array()
	var w_off := PackedInt32Array()
	w_off.resize((vraw as Array).size() + 1)
	for i in range((vraw as Array).size()):
		var vv: Variant = (vraw as Array)[i]
		if vv is Vector3:
			verts.append(vv)
		elif vv is Array and (vv as Array).size() >= 3:
			verts.append(Vector3(float((vv as Array)[0]), float((vv as Array)[1]), float((vv as Array)[2])))
		else:
			last_error = "raw vert %d is not Vector3/3-array" % i
			return {}
		w_off[i] = w_bone.size()
		if i >= (wraw as Array).size():
			last_error = "raw weights shorter than verts"
			return {}
		var pairs: Variant = (wraw as Array)[i]
		if not (pairs is Array):
			last_error = "raw weights[%d] not Array" % i
			return {}
		for p in (pairs as Array):
			var pair: Variant = p
			if not (pair is Array) or (pair as Array).size() < 2:
				last_error = "raw weight pair malformed at vertex %d" % i
				return {}
			w_bone.append(int((pair as Array)[0]))
			w_val.append(float((pair as Array)[1]))
	w_off[(vraw as Array).size()] = w_bone.size()
	var k: int = int(raw.get("k", raw.get("frames", 0)))
	var bones: int = int(raw.get("bones", raw.get("b", 0)))
	if k <= 0 or bones <= 0:
		last_error = "raw skin needs k/frames and bones/b"
		return {}
	var anim := PackedFloat32Array()
	anim.resize(k * bones * 7)
	var ai := 0
	for bi in range(bones):
		if bi >= (araw as Array).size():
			last_error = "raw anim has fewer bones than declared"
			return {}
		var rows: Variant = (araw as Array)[bi]
		if not (rows is Array) or (rows as Array).size() < k:
			last_error = "raw anim bone %d has fewer than k frames" % bi
			return {}
		for fr in range(k):
			var row: Variant = (rows as Array)[fr]
			if not (row is Array) or (row as Array).size() < 7:
				last_error = "raw anim row malformed bone %d frame %d" % [bi, fr]
				return {}
			for q in range(7):
				anim[ai] = float((row as Array)[q])
				ai += 1
	return {
		"ok": true,
		"source": str(raw.get("source", "registered_raw")),
		"path": str(raw.get("path", "")),
		"k": k,
		"fps": int(raw.get("fps", DONOR_FPS)),
		"bones": bones,
		"v": verts.size(),
		"verts": verts,
		"w_bone": w_bone,
		"w_val": w_val,
		"w_off": w_off,
		"anim": anim,
		"cite": str(raw.get("cite", OSS_CITE)),
		"skin_math": str(raw.get("skin_math", SKIN_CITE)),
	}


# ---------------------------------------------------------------------------
# V7-78: automatic shipped-skin assets (offline converter output only)
# ---------------------------------------------------------------------------

# Lazy, once. Safe to call from bind()/has_skin()/pose_for()/play(); the guard
# makes the per-unit sync path free after the first call. No donor path is read
# here: only the offline-converted index + JSON assets under res://.
func _ensure_shipped_skins() -> void:
	if _shipped_loaded:
		return
	_shipped_loaded = true
	_shipped_error = ""
	if not FileAccess.file_exists(SKIN_INDEX_PATH):
		_shipped_error = "no shipped skin index: " + SKIN_INDEX_PATH
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SKIN_INDEX_PATH))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("entries"):
		_shipped_error = "invalid shipped skin index: " + SKIN_INDEX_PATH
		return
	var entries: Array = (parsed as Dictionary)["entries"]
	for item in entries:
		if not (item is Dictionary):
			continue
		var file_name := str((item as Dictionary).get("file", ""))
		if file_name == "":
			continue
		if _load_shipped_skin(SKIN_ASSET_DIR + file_name):
			_shipped_count += 1
			_shipped_bytes += int((item as Dictionary).get("bytes", 0))
		else:
			_shipped_error = "last failure " + file_name + ": " + last_error


# Load one c3_skin_v1 asset and register it under its real roster sid. Uses the
# SAME packed representation and skinner as parse_donor_oss(); only the anim
# block is frame-subsetted. Strict rejection: no fill values, no guesswork.
func _load_shipped_skin(path: String) -> bool:
	last_error = ""
	if not FileAccess.file_exists(path):
		last_error = "shipped skin missing: " + path
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		last_error = "shipped skin is not a JSON object: " + path
		return false
	var d := parsed as Dictionary
	if str(d.get("schema", "")) != "c3_skin_v1":
		last_error = "shipped skin schema mismatch: " + path
		return false
	var sid := str(d.get("sid", ""))
	if sid == "":
		last_error = "shipped skin has empty sid: " + path
		return false
	var frames: Array = d.get("frames", [])
	var nf: int = frames.size()
	var bones: int = int(d.get("bones", 0))
	var vraw: Array = d.get("verts", [])
	var wraw: Array = d.get("weights", [])
	var araw: Array = d.get("anim", [])
	if nf <= 0 or bones <= 0 or vraw.is_empty() or wraw.size() != vraw.size() or araw.size() != bones:
		last_error = "shipped skin structural mismatch: " + path
		return false
	var verts := PackedVector3Array()
	verts.resize(vraw.size())
	for i in range(vraw.size()):
		var vv: Variant = vraw[i]
		if not (vv is Array) or (vv as Array).size() < 3:
			last_error = "shipped vert %d malformed: %s" % [i, path]
			return false
		var a3: Array = vv as Array
		verts[i] = Vector3(float(a3[0]), float(a3[1]), float(a3[2]))
	var w_bone := PackedInt32Array()
	var w_val := PackedFloat32Array()
	var w_off := PackedInt32Array()
	w_off.resize(vraw.size() + 1)
	for i in range(vraw.size()):
		w_off[i] = w_bone.size()
		var pairs: Variant = wraw[i]
		if not (pairs is Array):
			last_error = "shipped weights[%d] malformed: %s" % [i, path]
			return false
		for p in (pairs as Array):
			if not (p is Array) or (p as Array).size() < 2:
				last_error = "shipped weight pair malformed at %d: %s" % [i, path]
				return false
			var pair: Array = p as Array
			w_bone.append(int(pair[0]))
			w_val.append(float(pair[1]))
	w_off[vraw.size()] = w_bone.size()
	var anim := PackedFloat32Array()
	anim.resize(bones * nf * 7)
	var ai := 0
	for bi in range(bones):
		var rows: Variant = araw[bi]
		if not (rows is Array) or (rows as Array).size() != nf:
			last_error = "shipped anim bone %d frame count mismatch: %s" % [bi, path]
			return false
		for fi in range(nf):
			var row: Variant = (rows as Array)[fi]
			if not (row is Array) or (row as Array).size() < 7:
				last_error = "shipped anim row malformed bone %d frame %d: %s" % [bi, fi, path]
				return false
			for q in range(7):
				anim[ai] = float((row as Array)[q])
				ai += 1
	var frame_index := {}
	for i in range(nf):
		frame_index[int(frames[i])] = i
	var actions := {}
	var raw_actions: Variant = d.get("actions", {})
	if raw_actions is Dictionary:
		for name in (raw_actions as Dictionary).keys():
			var av: Variant = (raw_actions as Dictionary)[name]
			if not (av is Dictionary):
				continue
			var ad := av as Dictionary
			actions[str(name)] = {
				"first": int(ad.get("first", -1)),
				"last": int(ad.get("last", -1)),
				"kind": str(ad.get("kind", "morph")),
				"donor": str(ad.get("donor", "")),
				"frames": (ad.get("frames", []) as Array).duplicate(),
			}
	var skin := {
		"ok": true,
		"compact": true,
		"source": SHIPPED_SKIN_SOURCE,
		"path": str(d.get("path", "")),
		"asset": path,
		"aaf_path": str(d.get("aaf_path", "")),
		"k": int(d.get("k", 0)),
		"fps": int(d.get("fps", DONOR_FPS)),
		"bones": bones,
		"v": verts.size(),
		"verts": verts,
		"w_bone": w_bone,
		"w_val": w_val,
		"w_off": w_off,
		"anim": anim,
		"frame_count": nf,
		"frames": frames,
		"frame_index": frame_index,
		"actions": actions,
		"cite": str(d.get("cite", OSS_CITE)),
		"skin_math": str(d.get("skin_math", SKIN_CITE)),
		"label": str(d.get("label", PORT_LABEL)),
		"rig": str(d.get("rig", BLOCKED_RIG)),
		"visual": "UNVERIFIED",
		"coord": str(d.get("coord", MORPH_COORD)),
	}
	if not _valid_skin(skin):
		return false
	_skins[sid] = skin
	return true


# Deterministic nearest exported donor frame. `frames` is ascending, so a tie
# keeps the lower frame. No interpolation and no invented frame index.
func _nearest_local(skin: Dictionary, donor_frame: int) -> int:
	var frames: Array = skin.get("frames", [])
	if frames.is_empty():
		return 0
	var best := 0
	var best_dist: int = absi(int(frames[0]) - donor_frame)
	for i in range(1, frames.size()):
		var dist: int = absi(int(frames[i]) - donor_frame)
		if dist < best_dist:
			best_dist = dist
			best = i
	return best


func _nearest_exported_frame(skin: Dictionary, donor_frame: int) -> int:
	var frames: Array = skin.get("frames", [])
	var local := _nearest_local(skin, donor_frame)
	if local >= frames.size():
		return donor_frame
	return int(frames[local])


# [first, last, line, kind, donor_cite]. A shipped skin carries its unit's OWN
# donor AAF ranges (converter read them from data/animations/aaf/<base>.aaf);
# unregistered/legacy skins keep the V7-18 peaukr table unchanged.
func _action_range_for(sid: String, action: String) -> Array:
	if _skins.has(sid):
		var skin: Dictionary = _skins[sid] as Dictionary
		if bool(skin.get("compact", false)):
			var actions: Dictionary = skin.get("actions", {})
			if actions.has(action):
				var a: Dictionary = actions[action] as Dictionary
				var donor_path := str(a.get("donor", ""))
				var line := 0
				var colon: int = donor_path.rfind(":")
				if colon >= 0:
					line = int(donor_path.substr(colon + 1))
				return [int(a["first"]), int(a["last"]), line,
					str(a.get("kind", "morph")), donor_path]
	if not AAF_ACTIONS.has(action):
		return []
	return (AAF_ACTIONS[action] as Array).duplicate()


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
