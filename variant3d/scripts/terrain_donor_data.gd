# ---------------------------------------------------------------------------
# variant3d/scripts/terrain_donor_data.gd  — I06 owner file (2026-11-26)
#
# PROVENANCE / PARITY GUARD
#   Donor core (text/RTTI observation only):
#     TMapTerrainDataTile = {height: Float, tex: Integer, collision: Integer[4]}
#       data/scripts/dmscript.global:2026-2030; gc_terraindata_collision=4 (:80);
#       collision grid = 2*W (:134-135); texturemap.inc:133-134.
#     Grid sides 256/320/480/640: miscext2.script:19-26, dmscript.global:132-135.
#     Cell centre (x+0.5-W/2), flat index y*W+x, origin -W/2:
#       TERRAIN2_01:136-138, world3d_terrain.gd:1300-1314 (port [D]).
#     Water thresholds -0.25 / -0.1: texturemap.inc:29-31.
#     Tile ids [0,123]: terrain/tiles/terrain.presets:2-6; 255 is a PORT-ONLY
#       water sentinel (game.gd:52), never asserted as a donor id.
#   All GODOT representation choices below are PORT APPROXIMATION. Struct field
#   order / stride are UNVERIFIED (A01 E22), so the SoA order here is a PORT
#   CHOICE. Row sign is UNVERIFIED. TILE_M=2.0 is DONOR-GROUNDED horizontally
#   (dmscript.global:170-173, 2m/cell per V08); stored height units remain
#   UNVERIFIED [U] — no donor metre assertion is made for the height float.
#   The 2x collision grid is recorded as
#   a derived option in metadata; donor engine-side consumption is [U].
#   NO donor binary/data was run or copied. NO DONOR PARITY CLAIM: no GPU A/B
#   frame exists (CHARTER 2026-11-26 4/5). stats() is diagnostics only and is
#   never fed back into sim, mesh, water or tile assignment.
#   Self-contained: no dependency on legacy scripts; no RNG, no synthetic
#   noise/dither, no invented donor constants.
# ---------------------------------------------------------------------------
extends RefCounted
class_name C3TerrainData

# --- donor-observed constants (PORT APPROXIMATION where a choice is made) ---
const DUMP_VERSION: int = 1
const COLLISION_STRIDE: int = 4
const TILE_ID_MAX: int = 123
const TILE_SENTINEL_WATER: int = 255
const WATER_DEEP: float = -0.25
const WATER_SHORE: float = -0.1
const TILE_M: float = 2.0
const TILE_M_LABEL: String = "DONOR-GROUNDED horizontally (dmscript.global:170-173, 2m/cell); stored height units remain UNVERIFIED; row sign UNVERIFIED"
const ROW_FLIP_LABEL: String = "UNVERIFIED"
const FIELD_ORDER_LABEL: String = "PORT CHOICE — SoA order: height, tex, collision[4]; donor struct order/stride [U] (A01 E22)"
const COLLISION_LAYOUT_LABEL: String = "u8[4] per height cell (stride 4; u8 narrowing [U]); 2x grid = derived (2W)*(2H) view, donor engine consumption [U]"

const DONOR_SIZES := [256, 320, 480, 640]
const PORT_DEBUG_ALIASES := [160, 64, 240]
const ALLOWED_SIZES := [256, 320, 480, 640, 160, 64, 240]

# Iteration order is fixed for deterministic dumps and coverage reports.
const SIDE_U8_KEYS := ["terrain_class", "water", "owner", "fog", "forest_density",
		"stone_density", "relief_mask"]
const SIDE_U16_KEYS := ["resource_id", "prop_index"]
const SIDE_F32_KEYS := ["mask_r", "mask_g", "mask_b"]

# Every field carries an explicit label and donor-source string.
const FIELD_META: Dictionary = {
	"height": {
		"label": "DONOR-CORE [O]; f32 LE in dump",
		"source": "TMapTerrainDataTile.height, dmscript.global:2026-2030 (A01 E1/E9); dump world3d_terrain.gd:926-963",
	},
	"tex": {
		"label": "DONOR-CORE [O]; id [0,123], 255 = PORT-ONLY sentinel",
		"source": "TMapTerrainDataTile.tex / SetTileIndex, dmscript.global:2026-2030; texturemap.inc:528,608,642; terrain.presets:2-6 (A01 E10/E11)",
	},
	"collision": {
		"label": "DONOR-CORE [O]; u8[4] per cell is PORT narrowing [U]; 2x grid option in meta",
		"source": "TMapTerrainDataTile.collision[4], dmscript.global:80,134-135,2026-2029; texturemap.inc:133-134 (A01 E2); tags dmscript.global:83-92",
	},
	"terrain_class": {
		"label": "SIDE — source [O], per-cell byte PORT APPROX",
		"source": "source bitmap R, generatemap.inc:413-480 (A01 E6)",
	},
	"water": {
		"label": "SIDE — donor thresholds [O], tri-state flag PORT APPROX",
		"source": "height classify -0.25 deep / -0.1 shore, texturemap.inc:29-31 (A01 E12)",
	},
	"owner": {
		"label": "SIDE — [U] UNVERIFIED donor per-cell field",
		"source": "players/objects; no per-cell donor field found (A01 2.2; D04/D07)",
	},
	"fog": {
		"label": "SIDE — donor GLOBAL [O], per-cell byte PORT APPROX",
		"source": "colors.lib:23,34-43 (A01 E17)",
	},
	"forest_density": {
		"label": "SIDE — source [O], density byte PORT APPROX",
		"source": "source bitmap G, generatemap.inc:473-480 (A01 E6)",
	},
	"stone_density": {
		"label": "SIDE — source [O]/[I], density byte PORT APPROX",
		"source": "source bitmap G / rock family, generatemap.inc:473-480 (D07/F08)",
	},
	"resource_id": {
		"label": "SIDE — [U] as per-cell field; u16 LE index, 0 = none",
		"source": "object table res_nodes, game.gd:575-584 (A01 2.2)",
	},
	"prop_index": {
		"label": "SIDE — prop object [O], per-cell u16 LE ref PORT APPROX, 0 = none",
		"source": "pattern-instantiated terrainmesh*.osm, pattern.lib:338482/344362/348758/356906 (A01 E15)",
	},
	"relief_mask": {
		"label": "SIDE — PORT APPROX, read-only art guard (never sim/mesh)",
		"source": "producer provenance, game.gd:80; Z04_height_only_design.md:80,322-336 (A01 E19)",
	},
	"mask_r": {
		"label": "SIDE — generation scratch [O] source, retention PORT APPROX, optional",
		"source": "gMapMask float channel R, generatemap.inc:505-547 (A01 E7)",
	},
	"mask_g": {
		"label": "SIDE — generation scratch [O] source, retention PORT APPROX, optional",
		"source": "gMapMask float channel G, generatemap.inc:505-547 (A01 E7)",
	},
	"mask_b": {
		"label": "SIDE — generation scratch [O] source, retention PORT APPROX, optional",
		"source": "gMapMask float channel B, generatemap.inc:505-547 (A01 E7)",
	},
	"props": {
		"label": "SIDE — object table [O], flat list PORT APPROX",
		"source": "terrainmesh*.osm pattern instances, pattern.lib:338482 (A01 E15)",
	},
	"resources": {
		"label": "SIDE — [U] per-cell id; flat list PORT APPROX",
		"source": "res_nodes object table, game.gd:575-584 (A01 2.2)",
	},
}

# --- grid -------------------------------------------------------------------
var w: int = 0
var h: int = 0
var n: int = 0

# --- donor-confirmed core, structure-of-arrays (order = PORT CHOICE) ---------
var height: PackedFloat32Array = PackedFloat32Array()
var tex: PackedByteArray = PackedByteArray()
var collision: PackedByteArray = PackedByteArray()  # u8[4] per cell; alias view: collision4_view()

# --- labelled side arrays ----------------------------------------------------
var terrain_class: PackedByteArray = PackedByteArray()
var water: PackedByteArray = PackedByteArray()
var owner: PackedByteArray = PackedByteArray()
var fog: PackedByteArray = PackedByteArray()
var forest_density: PackedByteArray = PackedByteArray()
var stone_density: PackedByteArray = PackedByteArray()
var resource_id: PackedByteArray = PackedByteArray()   # u16 LE, 0 = none
var prop_index: PackedByteArray = PackedByteArray()     # u16 LE, 0 = none
var relief_mask: PackedByteArray = PackedByteArray()

# Optional, allocated only on request by a generation stage.
var mask_r: PackedFloat32Array = PackedFloat32Array()
var mask_g: PackedFloat32Array = PackedFloat32Array()
var mask_b: PackedFloat32Array = PackedFloat32Array()

var props: Array[Dictionary] = []
var resources: Array[Dictionary] = []

var meta: Dictionary = {}
var tile_m: float = TILE_M

var _passthrough: Dictionary = {}       # unknown top-level dump keys, byte-preserved
var _diagnostics: Array[String] = []


func _init(width: int = 0, height_cells: int = 0) -> void:
	if width > 0 and height_cells > 0:
		configure_grid(width, height_cells)


# ---------------------------------------------------------------------------
# Grid / coordinates. W,H live in the container, never read from a global.
# ---------------------------------------------------------------------------
func configure_grid(width: int, height_cells: int) -> bool:
	if width <= 0 or height_cells <= 0 or width > 640 or height_cells > 640:
		_diag("configure_grid: invalid W/H %d x %d (cap 640)" % [width, height_cells])
		return false
	w = width
	h = height_cells
	n = w * h
	_passthrough = {}
	height = PackedFloat32Array()
	height.resize(n)
	tex = PackedByteArray()
	tex.resize(n)
	collision = PackedByteArray()
	collision.resize(n * COLLISION_STRIDE)
	for key in SIDE_U8_KEYS:
		var arr: PackedByteArray = PackedByteArray()
		arr.resize(n)
		set(key, arr)
	for key in SIDE_U16_KEYS:
		var arr16: PackedByteArray = PackedByteArray()
		arr16.resize(n * 2)
		set(key, arr16)
	mask_r = PackedFloat32Array()
	mask_g = PackedFloat32Array()
	mask_b = PackedFloat32Array()
	props = []
	resources = []
	tile_m = TILE_M
	var size_class: String = "DONOR [O] 256/320/480/640"
	if PORT_DEBUG_ALIASES.has(width) and PORT_DEBUG_ALIASES.has(height_cells):
		size_class = "PORT DEBUG ALIAS — not a donor mapsize"
	elif not (DONOR_SIZES.has(width) and DONOR_SIZES.has(height_cells)):
		size_class = "UNLISTED PORT SIZE — labelled, not asserted as donor"
	meta = {
		"size_class": size_class,
		"row_flip": ROW_FLIP_LABEL,
		"tile_m": TILE_M,
		"tile_m_label": TILE_M_LABEL,
		"height_unit": "[U] raw float32; no HEIGHT_SCALE multiplier applied",
		"per_cell_field_order": FIELD_ORDER_LABEL,
		"collision_layout": COLLISION_LAYOUT_LABEL,
		"collision_2x_option": "derived view via collision_sub_index(cx,cy,tag); (2W)*(2H); [U] engine consumption",
		"collision_population": "from_live_object does NOT map legacy blocked -> collision; I07/I11 must populate collision explicitly (4 tags/cell; 2x view is derived); no legacy semantics invented",
		"labels": "PORT APPROXIMATION — no donor parity claim",
		"field_labels": FIELD_META.duplicate(true),
		"dump_version": DUMP_VERSION,
		"handoff": "unset",
	}
	return true


func ensure_mask_channels() -> void:
	for key in SIDE_F32_KEYS:
		var arr: Variant = get(key)
		var need: bool = true
		if arr is PackedFloat32Array:
			var cur: PackedFloat32Array = arr
			need = cur.size() < n
		if need:
			var fresh := PackedFloat32Array()
			fresh.resize(n)
			set(key, fresh)


func _diag(msg: String) -> void:
	_diagnostics.append(msg)


func diagnostics() -> Array[String]:
	return _diagnostics.duplicate()


func field_meta(key: String) -> Dictionary:
	if FIELD_META.has(key):
		var entry: Dictionary = FIELD_META[key]
		return entry.duplicate(true)
	return {"label": "UNKNOWN", "source": "UNKNOWN"}


# ---------------------------------------------------------------------------
# Indexing. Flat index i = y*W + x; x fastest. Row sign stays UNVERIFIED.
# ---------------------------------------------------------------------------
func idx(x: int, y: int) -> int:
	return y * w + x


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < w and y >= 0 and y < h


func cell_center_world(x: int, y: int, p_tile_m: float = TILE_M) -> Vector3:
	var i: int = idx(x, y)
	return Vector3(
			(float(x) + 0.5 - float(w) * 0.5) * p_tile_m,
			height[i],
			(float(y) + 0.5 - float(h) * 0.5) * p_tile_m)


# Inverse world -> cell. Clamped; row sign unverified, so z uses +h/2 here.
func world_to_cell(p: Vector3) -> Vector2i:
	var x: int = int(floorf(p.x / tile_m + float(w) * 0.5))
	var y: int = int(floorf(p.z / tile_m + float(h) * 0.5))
	return Vector2i(clampi(x, 0, w - 1), clampi(y, 0, h - 1))


func get_collision(i: int, tag: int) -> int:
	return collision[i * COLLISION_STRIDE + tag]


func set_collision(i: int, tag: int, value: int) -> void:
	collision[i * COLLISION_STRIDE + tag] = value


# Derived (2W)*(2H) sub-cell view over the same u8[4] core (no second buffer).
func collision_sub_index(cx: int, cy: int, tag: int) -> int:
	var cell_x: int = clampi(cx / 2, 0, w - 1)
	var cell_y: int = clampi(cy / 2, 0, h - 1)
	return idx(cell_x, cell_y) * COLLISION_STRIDE + tag


func collision4_view() -> PackedByteArray:
	return collision


func get_u16(a: PackedByteArray, i: int) -> int:
	return int(a[i * 2]) | (int(a[i * 2 + 1]) << 8)


func set_u16(a: PackedByteArray, i: int, v: int) -> void:
	a[i * 2] = v & 0xFF
	a[i * 2 + 1] = (v >> 8) & 0xFF


func set_height(i: int, v: float) -> void:
	height[i] = v


func set_tex(i: int, v: int) -> void:
	tex[i] = v & 0xFF


# Donor thresholds [O]; tri-state flag is PORT APPROX. No noise, no smoothing.
func derive_water(deep: float = WATER_DEEP, shore: float = WATER_SHORE) -> void:
	if water.size() < n:
		water.resize(n)
	for i in range(n):
		var hv: float = height[i]
		if hv < deep:
			water[i] = 2
		elif hv < shore:
			water[i] = 1
		else:
			water[i] = 0
	meta["water_derivation"] = "thresholds -0.25 / -0.1 [O] source; tri-state flag PORT APPROX"


# ---------------------------------------------------------------------------
# Decode helpers. Missing / short data leaves the pre-zeroed destination alone.
# Packed typed input is accepted directly (the live, no-base64 path).
# ---------------------------------------------------------------------------
func _decode_u8_into(dst: PackedByteArray, src: Variant) -> void:
	var m: int = 0
	var live: PackedByteArray = PackedByteArray()
	var raw: PackedByteArray = PackedByteArray()
	if src is PackedByteArray:
		live = src
		m = mini(live.size(), dst.size())
	elif src is String:
		raw = Marshalls.base64_to_raw(str(src))
		m = mini(raw.size(), dst.size())
	else:
		return
	for i in range(m):
		dst[i] = live[i] if (src is PackedByteArray) else raw[i]


func _decode_f32_into(dst: PackedFloat32Array, src: Variant) -> void:
	var m: int = 0
	var live: PackedFloat32Array = PackedFloat32Array()
	var raw: PackedByteArray = PackedByteArray()
	if src is PackedFloat32Array:
		live = src
		m = mini(live.size(), dst.size())
	elif src is String:
		raw = Marshalls.base64_to_raw(str(src))
		m = mini(raw.size() / 4, dst.size())
	else:
		return
	for i in range(m):
		dst[i] = live[i] if (src is PackedFloat32Array) else raw.decode_float(i * 4)


func _encode_u8(src: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(src)


func _encode_f32(src: PackedFloat32Array) -> String:
	var raw := PackedByteArray()
	raw.resize(src.size() * 4)
	for i in range(src.size()):
		raw.encode_float(i * 4, src[i])
	return Marshalls.raw_to_base64(raw)


func _first_int(src: Object, keys: Array) -> int:
	for key in keys:
		var v: Variant = src.get(str(key))
		if v is int:
			return int(v)
	return 0


# ---------------------------------------------------------------------------
# LIVE handoff: typed arrays by reference, no base64 copy (Godot CoW contract:
# renderer/builder reads only; a later write by either side copies).
# ---------------------------------------------------------------------------
func from_live(p_height: PackedFloat32Array, p_tex: PackedByteArray,
		p_w: int, p_h: int, p_collision: Variant = null) -> bool:
	if not configure_grid(p_w, p_h):
		return false
	if p_height.size() >= n:
		height = p_height
	else:
		_decode_f32_into(height, p_height)
		_diag("from_live: short height array, zero-filled remainder")
	if p_tex.size() >= n:
		tex = p_tex
	else:
		_decode_u8_into(tex, p_tex)
		_diag("from_live: short tex array, zero-filled remainder")
	if p_collision is PackedByteArray:
		var c: PackedByteArray = p_collision
		if c.size() >= n * COLLISION_STRIDE:
			collision = c
		else:
			_decode_u8_into(collision, c)
	meta["handoff"] = "LIVE TYPED ARRAY — zero-copy alias, renderer must be read-only (CoW)"
	return true


# Live sim -> container through dynamic Object.get(); no legacy script dependency.
func from_live_object(src: Object) -> bool:
	var wv: int = _first_int(src, ["MAP_W", "map_w", "w"])
	var hv: int = _first_int(src, ["MAP_H", "map_h", "h"])
	var hvarr: Variant = src.get("height")
	var tv: Variant = src.get("tileblock")
	if tv == null:
		tv = src.get("tex")
	if wv <= 0 or hv <= 0 or not (hvarr is PackedFloat32Array) or not (tv is PackedByteArray):
		_diag("from_live_object: missing typed height/tileblock or W/H")
		return false
	if not from_live(hvarr, tv, wv, hv, src.get("collision")):
		return false
	_diag("from_live_object: legacy blocked -> collision NOT mapped; I07/I11 must populate collision explicitly")
	for key in SIDE_U8_KEYS:
		var v: Variant = src.get(key)
		if v is PackedByteArray:
			var vb: PackedByteArray = v
			var dst: PackedByteArray = get(key)
			if vb.size() >= dst.size():
				set(key, vb)
			else:
				_decode_u8_into(dst, vb)
	for key in SIDE_U16_KEYS:
		var v16: Variant = src.get(key)
		if v16 is PackedByteArray:
			var vb16: PackedByteArray = v16
			var dst16: PackedByteArray = get(key)
			if vb16.size() >= dst16.size():
				set(key, vb16)
			else:
				_decode_u8_into(dst16, vb16)
	for key in SIDE_F32_KEYS:
		var vf: Variant = src.get(key)
		if vf is PackedFloat32Array:
			ensure_mask_channels()
			var vf32: PackedFloat32Array = vf
			var dstf: PackedFloat32Array = get(key)
			if vf32.size() >= dstf.size():
				set(key, vf32)
			else:
				_decode_f32_into(dstf, vf32)
	return true


# Renderer-facing live view: typed arrays, no base64, no copy.
func to_live() -> Dictionary:
	var d: Dictionary = {
		"w": w,
		"h": h,
		"n": n,
		"height": height,
		"tex": tex,
		"collision": collision,
	}
	for key in SIDE_U8_KEYS:
		d[key] = get(key)
	for key in SIDE_U16_KEYS:
		d[key] = get(key)
	for key in SIDE_F32_KEYS:
		d[key] = get(key)
	d["props"] = props
	d["resources"] = resources
	d["meta"] = meta.duplicate(true)
	d["handoff"] = "LIVE TYPED ARRAY — no base64; CoW read-only contract"
	return d


# Convenience for the generator stage: assign one labelled side array.
func assign_side(key: String, values: Variant) -> bool:
	if SIDE_U8_KEYS.has(key) or SIDE_U16_KEYS.has(key):
		if not (values is PackedByteArray):
			return false
		var vb: PackedByteArray = values
		var dst: PackedByteArray = get(key)
		if vb.size() >= dst.size():
			set(key, vb)
		else:
			_decode_u8_into(dst, vb)
		return true
	if SIDE_F32_KEYS.has(key):
		if not (values is PackedFloat32Array):
			return false
		ensure_mask_channels()
		var vf32: PackedFloat32Array = values
		var dstf: PackedFloat32Array = get(key)
		if vf32.size() >= dstf.size():
			set(key, vf32)
		else:
			_decode_f32_into(dstf, vf32)
		return true
	return false


# ---------------------------------------------------------------------------
# Additive dump contract. Existing top-level keys keep their exact type/bytes;
# new data lives only under "fields". Old builders ignore "fields".
# ---------------------------------------------------------------------------
func from_dump(dump: Dictionary) -> bool:
	var wv: int = int(dump.get("map_w", 0))
	var hv: int = int(dump.get("map_h", 0))
	if not configure_grid(wv, hv):
		return false
	_passthrough = {}
	for key in dump.keys():
		if key == "map_w" or key == "map_h" or key == "height" or key == "tileblock" or key == "fields":
			continue
		_passthrough[key] = dump[key]

	_decode_f32_into(height, dump.get("height", null))
	_decode_u8_into(tex, dump.get("tileblock", null))
	var tv: Variant = dump.get("tex", null)
	if tex.size() < n and tv != null:
		_decode_u8_into(tex, tv)

	var fields_v: Variant = dump.get("fields", null)
	if not (fields_v is Dictionary):
		meta["fields_version_seen"] = 0
		return true
	var fields: Dictionary = fields_v
	var ver: int = int(fields.get("version", -1))
	meta["fields_version_seen"] = ver
	if ver != DUMP_VERSION:
		_diag("from_dump: fields version %d != %d — fields ignored (no failure)" % [ver, DUMP_VERSION])
		return true

	for key in SIDE_U8_KEYS:
		if fields.has(key):
			var dst: PackedByteArray = get(key)
			_decode_u8_into(dst, fields[key])
	for key in SIDE_U16_KEYS:
		if fields.has(key):
			var dst16: PackedByteArray = get(key)
			_decode_u8_into(dst16, fields[key])
	for key in SIDE_F32_KEYS:
		if fields.has(key):
			ensure_mask_channels()
			var dstf: PackedFloat32Array = get(key)
			_decode_f32_into(dstf, fields[key])
	if fields.has("collision4"):
		_decode_u8_into(collision, fields["collision4"])
	elif fields.has("collision"):
		_decode_u8_into(collision, fields["collision"])
	if fields.has("props") and fields["props"] is Array:
		var pa: Array = fields["props"]
		props = pa.duplicate(true)
	if fields.has("resources") and fields["resources"] is Array:
		var ra: Array = fields["resources"]
		resources = ra.duplicate(true)
	meta["handoff"] = "DUMP SNAPSHOT — base64 decoded once (one unavoidable copy)"
	return true


func to_dump() -> Dictionary:
	var d: Dictionary = {
		"map_w": w,
		"map_h": h,
		"height": _encode_f32(height),
		"tileblock": _encode_u8(tex),
	}
	for key in _passthrough.keys():
		if not d.has(key):
			d[key] = _passthrough[key]
	var fields: Dictionary = {
		"version": DUMP_VERSION,
		"labels": "PORT APPROXIMATION — no donor parity claim",
		"collision4": _encode_u8(collision),
	}
	for key in SIDE_U8_KEYS:
		fields[key] = _encode_u8(get(key))
	for key in SIDE_U16_KEYS:
		fields[key] = _encode_u8(get(key))
	if mask_r.size() >= n:
		fields["mask_r"] = _encode_f32(mask_r)
	if mask_g.size() >= n:
		fields["mask_g"] = _encode_f32(mask_g)
	if mask_b.size() >= n:
		fields["mask_b"] = _encode_f32(mask_b)
	fields["props"] = props.duplicate(true)
	fields["resources"] = resources.duplicate(true)
	fields["field_labels"] = FIELD_META.duplicate(true)
	d["fields"] = fields
	return d


# ---------------------------------------------------------------------------
# stats(): DIAGNOSTICS ONLY. Nothing here is read back into sim, mesh, water,
# tile assignment or any gate threshold. No RNG, no synthesis.
# ---------------------------------------------------------------------------
func stats() -> Dictionary:
	var out: Dictionary = {
		"grid": {"w": w, "h": h, "n": n},
		"parity": "UNVERIFIED — no donor GPU A/B frame; diagnostics only",
		"height_unit": "[U] raw float32; no scale multiplier",
		"row_flip": ROW_FLIP_LABEL,
		"tile_m_label": TILE_M_LABEL,
		"field_order": FIELD_ORDER_LABEL,
		"collision_layout": COLLISION_LAYOUT_LABEL,
		"diagnostics_only": true,
	}
	if n <= 0:
		return out

	# Height deciles: [min, d1..d9, max] over a sorted copy; source untouched.
	var vals: Array[float] = []
	for i in range(n):
		vals.append(height[i])
	vals.sort()
	var dec: Array[float] = []
	dec.append(vals[0])
	for k in range(1, 10):
		var pos: int = int(roundf(float(k) * float(n - 1) / 10.0))
		dec.append(vals[clampi(pos, 0, n - 1)])
	dec.append(vals[n - 1])
	out["height_deciles"] = dec
	out["height_deciles_label"] = "[min, d1..d9, max] — diagnostic only, never fed back"
	out["height_min"] = vals[0]
	out["height_max"] = vals[n - 1]

	# Tile-id histogram. 255 is counted but never silently remapped.
	var hist: Dictionary = {}
	var out_of_atlas: int = 0
	for i in range(n):
		var tid: int = int(tex[i])
		var key: String = str(tid)
		hist[key] = int(hist.get(key, 0)) + 1
		if tid > TILE_ID_MAX:
			out_of_atlas += 1
	out["tile_id_histogram"] = hist
	out["tile_id_out_of_atlas"] = out_of_atlas
	out["tile_id_note"] = "ids [0,123] donor [O]; other values incl. 255 are PORT-ONLY sentinels"

	# Water / shore counts. Uses the stored flag if present, else a diagnostic
	# read of height against the donor thresholds; never writes the flag.
	var deep: int = 0
	var shore: int = 0
	var land: int = 0
	if water.size() >= n:
		for i in range(n):
			var wv: int = int(water[i])
			if wv == 2:
				deep += 1
			elif wv == 1:
				shore += 1
			else:
				land += 1
		out["water_counts_source"] = "stored water side array (PORT APPROX tri-state)"
	else:
		for i in range(n):
			var hv: float = height[i]
			if hv < WATER_DEEP:
				deep += 1
			elif hv < WATER_SHORE:
				shore += 1
			else:
				land += 1
		out["water_counts_source"] = "height thresholds -0.25/-0.1 (diagnostic read, not stored)"
	out["water_counts"] = {"deep": deep, "shore": shore, "land": land}

	# Field coverage, with each field's label and donor source.
	var cov: Dictionary = {}
	for key in ["height", "tex", "collision"]:
		var exp: int = n
		if key == "collision":
			exp = n * COLLISION_STRIDE
		var arr_v: Variant = get(key)
		var sz: int = 0
		if arr_v is PackedByteArray:
			var ba: PackedByteArray = arr_v
			sz = ba.size()
		elif arr_v is PackedFloat32Array:
			var fa: PackedFloat32Array = arr_v
			sz = fa.size()
		cov[key] = {
			"label": field_meta(key)["label"],
			"source": field_meta(key)["source"],
			"size": sz,
			"expected": exp,
			"present": sz >= exp,
		}
	for key in SIDE_U8_KEYS:
		var arr8: PackedByteArray = get(key)
		cov[key] = {
			"label": field_meta(key)["label"],
			"source": field_meta(key)["source"],
			"size": arr8.size(),
			"expected": n,
			"present": arr8.size() >= n,
		}
	for key in SIDE_U16_KEYS:
		var arr16: PackedByteArray = get(key)
		cov[key] = {
			"label": field_meta(key)["label"],
			"source": field_meta(key)["source"],
			"size": arr16.size(),
			"expected": n * 2,
			"present": arr16.size() >= n * 2,
		}
	for key in SIDE_F32_KEYS:
		var arrf: Variant = get(key)
		var fsz: int = 0
		if arrf is PackedFloat32Array:
			var farr: PackedFloat32Array = arrf
			fsz = farr.size()
		cov[key] = {
			"label": field_meta(key)["label"],
			"source": field_meta(key)["source"],
			"size": fsz,
			"expected": n,
			"present": fsz >= n,
		}
	for key in ["props", "resources"]:
		var la: Array = get(key)
		cov[key] = {
			"label": field_meta(key)["label"],
			"source": field_meta(key)["source"],
			"size": la.size(),
			"expected": -1,
			"present": not la.is_empty(),
		}
	out["fields_coverage"] = cov
	out["fields_version_seen"] = int(meta.get("fields_version_seen", -1))
	out["diagnostic_log"] = _diagnostics.duplicate()
	return out
