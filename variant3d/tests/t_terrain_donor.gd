extends SceneTree

# ===========================================================================
# I12 — ATOMIC QA atom for the FRESH donor-faithful terrain module.
# Owner file (ONLY repo file this ticket writes): variant3d/tests/t_terrain_donor.gd
# Registry: V11 §3 N15 / §2 E3 (append to tests/manifest.json LAST, stage C').
# Ticket: docs/terrain_swarm_2026-11-26/IMPLEMENTATION_PLAN.md:20 (I12).
# Register: docs/terrain_swarm_2026-11-26/reports/V11_ownership_ledger.md:107,150
# Gates: reports/V21_gate_register.md §4/§7.1/§7.2; reports/A05_qa_harness.md §2.
# Style reference: variant3d/tests/t_terrain3d.gd (SceneTree + load() + call_deferred quit).
#
# TOP-LEVEL PARITY GUARD (binding, do not remove):
#   PORT APPROXIMATION / INTERNAL CONSISTENCY ONLY. No donor GPU A/B frame
#   exists (CHARTER 2026-11-26 §4/§6; V21 GR-C08; A05 parity_guard). Nothing
#   in this atom certifies donor fidelity. Every artefact inspected MUST carry
#   visual_parity_claim = false (spec/11 §11.1:17). Class A checks are RED
#   port-side determinism/structural contracts (V21 §7.1); class B numeric
#   bands are ADVISORY_UNVERIFIED and MUST NOT flip this atom red while those
#   bands are [U] (V21 §7.2). No threshold is lowered, no assertion deleted,
#   no donor parity claimed. Harness is SceneTree so `--script` gets a MainLoop.
#
# HOOK CONTRACT (expected of I07/I11; if absent the atom reports HOOK_MISSING
# as a hard FAIL for determinism and HOOK_MISSING advisory for vectors — NEVER
# a fabricated PASS):
#   res://scripts/terrain_donor_gen.gd, instance method with 0..4 args drawn
#   in order from [seed:int, keys:Dictionary, w:int, h:int]; named one of
#   generate_streams / generate / generate_map / run / build_streams.
#   Return value is a Dictionary or Object exposing: height|height_b64,
#   tileblock|tex, terrain|terrain_class, blocked|collision, map_w|w, map_h|h
#   and any of props|res|resources|clusters|starts|relief_stamps.
# ===========================================================================
const ID := "t_terrain_donor"
const OUT_PATH := "res://tests/results/t_terrain_donor.json"

# Required modules (guard). The composer is the seam target (V11 CR3 / N14).
const MODULE_WORLD := "res://scripts/terrain_donor_world.gd"
const MODULE_DATA := "res://scripts/terrain_donor_data.gd"
const MODULE_GEN := "res://scripts/terrain_donor_gen.gd"
const MODULE_MESH := "res://scripts/terrain_donor_mesh.gd"
const MODULE_PROPS := "res://scripts/terrain_donor_props.gd"
# Optional secondary modules (presence recorded, never gate the atom):
const MODULE_TILES := "res://scripts/terrain_donor_tiles.gd"          # I07 (V11 N10)
const MODULE_SHADER := "res://shaders/terrain_donor_shader.gdshader"  # I10 (V11 N13; V37 canonical rename)
const ASSET_MANIFEST := "res://assets/terrain_new/manifest.json"      # V11 G10
const REQUIRED_MODULES := [MODULE_WORLD, MODULE_DATA, MODULE_GEN, MODULE_MESH, MODULE_PROPS]

# Pinned key manifest (A05 §2.1 / config.json:72-108). Two runs are compared
# only when these keys are identical; the canonical SHA is recorded in results.
const SEED := 20261113                 # config.json:77 gameplay.random_seed
const GEN_KEYS := {
	"map_type": "land",                # config.json:107
	"start_option": "default",         # config.json:108
	"nation0": "rus",                  # config.json:105
	"nation1": "bav",                  # config.json:106
	"relief_stamps": true,             # config.json:24-26 features.terrain
	"water_surface_y": -0.25,          # config.json:28; donor texturemap.inc:29-30
	"map_width_tiles": 240,            # config.json:75 (shipped size, V21 MP7)
	"map_height_tiles": 240,           # config.json:76
}
const SIZES := [64, 240]               # A05 §2.3 D1 — 64² and 240² required
const RUN_320_OPTIONAL := false        # A05 D1 / V21 D-2 — 320² is OPTIONAL here

# --- donor-cited constants (every value carries a donor path:line) ----------
const TILE_ID_MAX := 123               # donor data/terrain/tiles/terrain.presets:2-6,129 (spec/06:9; A01 E11)
const TILE_SENTINEL_WATER := 255       # PORT-ONLY water sentinel, game.gd:52 (never a donor id — spec/06:33)
const WATER_DEEP := -0.25              # donor data/scripts/texturemap.inc:29-31,466-467 (spec/05:12, A01 E12)
const WATER_SHORE := -0.1              # donor data/scripts/texturemap.inc:29-31 (spec/05:12; MP3 four roles)
const FACE_MIN := 0                    # port UV2 face domain, world3d_terrain.gd:1315-1318,1407 (spec/01:34) PORT APPROX
const FACE_MAX := 2                    # port UV2 face domain, world3d_terrain.gd:1315-1318,1407 (spec/01:34) PORT APPROX
const TRI_PER_CELL := 2                # (W-1)*(H-1)*2 indexed tris, t_terrain3d.gd:8-10 (G32 §6)
const TILE_M := 2.0                    # C3Data.TILE_M, variant3d/scripts/data.gd:23 — PORT APPROX / UNVERIFIED
const HEIGHT_SCALE := 1.0              # dump height[] is metres, t_terrain3d.gd:25 (G32 §2); NO multiplier gate
const UV_EPS := 1e-3                   # float32 UV2 tolerance (test-only, not a donor band)
const DONOR_SIZES := [256, 320, 480, 640]  # donor miscext2.script:19-26, dmscript.global:132-135 (spec/01:30)
const PORT_ALIASES := [64, 160, 240]        # port debug aliases, terrain_donor_data.gd:43-45 (not donor mapsizes)
const ALLOWED_SIZES := [256, 320, 480, 640, 160, 64, 240]
const STREAM_NAMES := ["height", "tileblock", "terrain", "blocked", "props"]
const ADVISORY_BANDS := {              # V21 GR-B02..B08 — [I]/PORT APPROX, ADVISORY ONLY
	"water_fraction": [0.05, 0.45],    # A05:150 (S2), V21 GR-B03
	"shore_fraction": [0.02, 0.25],    # A05:151 (S3), V21 GR-B04
	"shore_water_ratio": [0.2, 1.5],   # A05:151, V21 GR-B04
	"distinct_land_ids_min": 8,        # A05:152 (S4), V21 GR-B05
	"top1_share_max": 0.60,            # A05:152, V21 GR-B05
	"height_decile_max_share": 0.85,   # A05:149 (S1), V21 GR-B02
	"donor_bands_min_occupied": 3,     # A05:149 bands from C_WATER/C_PLATEAU/C_HILL, V21 GR-B02
	"family_ratio": [0.5, 2.0],        # A05:154 (S6), V21 GR-B07
}
const DONOR_HEIGHT_BANDS := [-2.964, -1.1, 0.0, 1.317, 2.964]  # A05 E06 / A05:149; [D] from donor constants
const VECTOR_HOOK_NAMES := ["blend_vectors", "blend_test_vectors", "rng_vectors",
		"rng_test_vectors", "test_vectors"]
const SYNTHESIS_TOKENS := ["synthetic_noise", "noise_field", "dither_field",
		"radial_ring", "diagonal_vein", "HEIGHT_SCALE *", "face_promotion"]

var _checks: Array[Dictionary] = []
var _advisories: Array[Dictionary] = []
var _ok := true
var _finished := false
var _status := "RUNNING"
var _key_sha := ""
var _streams: Dictionary = {}          # size -> {stream_name: PackedByteArray}
var _meta: Dictionary = {}             # size -> generation metadata (w/h/source)
var _mesh_info: Dictionary = {}
var _hooks: Dictionary = {}
var _det: Dictionary = {}
var _structure: Dictionary = {}


# ---------------------------------------------------------------- reporting --
func check(name: String, cond: bool, detail: String = "", evidence: String = "") -> void:
	_checks.append({
		"name": name, "class": "A", "passed": cond,
		"detail": detail, "evidence": evidence,
	})
	if not cond:
		_ok = false
	print("T_TERRAIN_DONOR %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


func advisory(name: String, value: Variant, band: Variant, evidence: String, label: String) -> void:
	_advisories.append({
		"name": name, "class": "B", "status": "UNVERIFIED", "value": value,
		"band": band, "label": label, "evidence": evidence,
	})
	var v := str(value)
	var b := str(band)
	if v.length() > 240:
		v = v.substr(0, 240) + "..."
	print("T_TERRAIN_DONOR ADVISORY_UNVERIFIED %s - value=%s band=%s [%s] %s"
		% [name, v, b, label, evidence])


func fail_checks(names: Array, tag: String, reason: String) -> void:
	for nm in names:
		check(str(nm), false, tag + ": " + reason)


func finish() -> void:
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	# Preserve an explicit honest status (MODULE_MISSING) instead of overwriting
	# it with PASS/FAIL — a missing module is reported, never disguised.
	if _status != "MODULE_MISSING":
		_status = "PASS" if _ok else "FAIL"
	var abs_path := ProjectSettings.globalize_path(OUT_PATH)
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({
			"id": ID,
			"passed": _ok,
			"status": _status,
			"passes": passes,
			"total": _checks.size(),
			"checks": _checks,
			"advisories": _advisories,
			"determinism": _det,
			"structure": _structure,
			"mesh": _mesh_info,
			"vector_hooks": _hooks,
			"key_manifest": {"seed": SEED, "keys": GEN_KEYS, "sha256": _key_sha},
			"sizes": SIZES,
			"parity": {
				"claim": "NONE", "status": "UNVERIFIED",
				"visual_parity_claim": false,
				"note": "PORT APPROXIMATION — internal consistency only; no donor GPU A/B frame",
			},
			"modules": {
				"required": REQUIRED_MODULES,
				"optional": [MODULE_TILES, MODULE_SHADER, ASSET_MANIFEST],
			},
			"unix_ms": Time.get_unix_time_from_system() * 1000.0,
		}, "\t"))
		f.close()
	else:
		push_error(ID + ": cannot write result: " + abs_path)
	print("T_TERRAIN_DONOR RESULT: %s %d/%d status=%s" % [_status, passes, _checks.size(), _status])
	call_deferred("quit", 0 if _ok else 1)


func _failsafe() -> void:
	if _finished:
		return
	fail_checks(["failsafe"], "ABORTED", "test aborted before completion")
	finish()


# ------------------------------------------------------------- primitives ----
func _sha256(data: PackedByteArray) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(data)
	return ctx.finish().hex_encode()


func _fhex(v: float) -> String:
	var b := PackedByteArray()
	b.resize(8)
	b.encode_double(0, v)
	return b.hex_encode()


# Serializer-independent canonical form: floats are bit-exact 8-byte LE hex
# (stronger than float.hex()); dictionaries sort by string key; arrays keep
# order. Used ONLY for the canonical props stream (A05 §2.2).
func _canon(v: Variant) -> String:
	match typeof(v):
		TYPE_NIL:
			return "n"
		TYPE_BOOL:
			return "b" + ("1" if bool(v) else "0")
		TYPE_INT:
			return "i" + str(int(v))
		TYPE_FLOAT:
			return "f" + _fhex(float(v))
		TYPE_STRING:
			var s := str(v)
			return "s" + str(s.length()) + ":" + s
		TYPE_ARRAY:
			var parts_arr := ""
			var a := v as Array
			for e in a:
				parts_arr += _canon(e) + ","
			return "a" + str(a.size()) + "[" + parts_arr + "]"
		TYPE_DICTIONARY:
			var d := v as Dictionary
			var pairs: Array = []
			for k in d.keys():
				pairs.append([str(k), d[k]])
			pairs.sort_custom(func(p, q): return str(p[0]) < str(q[0]))
			var parts_dict := ""
			for p in pairs:
				parts_dict += "k" + str(str(p[0]).length()) + ":" + str(p[0]) + "=" + _canon(p[1]) + ","
			return "d" + str(pairs.size()) + "{" + parts_dict + "}"
		_:
			return "x" + str(v)


func _as_f32(v: Variant) -> PackedByteArray:
	var out := PackedByteArray()
	if v is PackedFloat32Array:
		var a := v as PackedFloat32Array
		out.resize(a.size() * 4)
		for i in range(a.size()):
			out.encode_float(i * 4, a[i])
	elif v is String:
		out = Marshalls.base64_to_raw(str(v))
	elif v is Array:
		var a := v as Array
		out.resize(a.size() * 4)
		for i in range(a.size()):
			out.encode_float(i * 4, float(a[i]))
	return out


func _as_u8(v: Variant) -> PackedByteArray:
	var out := PackedByteArray()
	if v is PackedByteArray:
		out = (v as PackedByteArray).duplicate()
	elif v is String:
		out = Marshalls.base64_to_raw(str(v))
	elif v is Array:
		var a := v as Array
		out.resize(a.size())
		for i in range(a.size()):
			out[i] = int(a[i]) & 0xFF
	return out


func _f32_array(raw: PackedByteArray) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var n: int = int(raw.size() / 4)
	out.resize(n)
	for i in range(n):
		out[i] = raw.decode_float(i * 4)
	return out


func _read_from(res: Variant, keys: Array) -> Variant:
	if res is Dictionary:
		var d := res as Dictionary
		for k in keys:
			if d.has(k):
				return d[k]
	elif res is Object:
		var o := res as Object
		for k in keys:
			var v: Variant = o.get(str(k))
			if v != null:
				return v
	return null


func _call_hook(obj: Object, names: Array, default_args: Array) -> Variant:
	var ml := obj.get_method_list()
	for nm in names:
		for m in ml:
			if str(m.get("name", "")) == str(nm):
				var args_def: Variant = m.get("args", [])
				var argc: int = 0
				if args_def is Array:
					argc = (args_def as Array).size()
				var args: Array = []
				for i in range(argc):
					args.append(default_args[i] if i < default_args.size() else null)
				return obj.callv(str(nm), args)
	return null


func _set_if(obj: Object, name: String, value: Variant) -> void:
	obj.set(name, value)  # Object.set on an unknown property is a no-op (returns false)


func _dispose(obj: Object) -> void:
	# RefCounted frees itself; calling free() on it is an error. Only Nodes
	# (composer/gen when it extends Node) need explicit disposal.
	if obj == null or not is_instance_valid(obj):
		return
	if not (obj is RefCounted):
		obj.free()


# ------------------------------------------------------------ generation -----
# Two independent in-process generations at identical (seed, keys). This is
# the atom-level form of A05 D1 (the cross-process form is N16 + --dump-map).
func _generate_streams(size: int) -> Dictionary:
	# V48 patch (d): I07's only generation entry is
	# generate(Object, Dictionary) (terrain_donor_gen.gd:420). It returns
	# telemetry; the streams are written into the container (gen.gd:890, :1073).
	# No arity truncation, no int-as-container, no assertion weakened.
	var script := load(MODULE_GEN) as Script
	var data_script := load(MODULE_DATA) as Script
	if script == null or data_script == null or not script.can_instantiate():
		return {}
	var g: Object = script.new()
	var data := data_script.new(size, size) as Object
	if g == null or data == null:
		_dispose(g)
		return {}
	# PORT APPROX seed mapping: config.json:77 gameplay.random_seed (test :49)
	# -> donor-named key words I07 reads (gen.gd:443-446). No donor value invented.
	var settings: Dictionary = GEN_KEYS.duplicate(true)
	settings["randkey0"] = SEED & 0xFFFFFFFF
	settings["randkey1"] = SEED & 0xFFFFFFFF
	settings["width"] = size
	settings["height"] = size
	var res: Variant = _call_hook(g, ["generate"], [data, settings])
	if res == null:
		_dispose(g)
		return {}
	var src: Variant = data
	var dump_v: Variant = _read_from(data, ["dump"])
	if dump_v is Dictionary:
		src = dump_v
	var props := {}
	for k in ["props", "res", "resources", "clusters", "starts", "relief_stamps"]:
		var v: Variant = _read_from(src, [k])
		if v != null:
			props[k] = v
	var wv: int = int(_read_from(src, ["map_w", "w", "width"]))
	var hv: int = int(_read_from(src, ["map_h", "h", "height_cells"]))
	if wv <= 0:
		wv = size
	if hv <= 0:
		hv = size
	var out := {
		"height": _as_f32(_read_from(src, ["height", "height_b64"])),
		"tileblock": _as_u8(_read_from(src, ["tileblock", "tex", "tileblock_b64"])),
		"terrain": _as_u8(_read_from(src, ["terrain", "terrain_class"])),
		"blocked": _as_u8(_read_from(src, ["blocked", "collision"])),
		"props": _canon(props).to_utf8_buffer(),
		"props_obj": props,
		"w": wv, "h": hv,
		"generator": "gen_streams",
	}
	_dispose(g)
	return out


func _streams_valid(s: Dictionary) -> bool:
	# A vacuous "empty == empty" hash is NOT a determinism pass.
	if s.is_empty():
		return false
	for st in STREAM_NAMES:
		var v: Variant = s.get(st, null)
		if not (v is PackedByteArray) or (v as PackedByteArray).is_empty():
			return false
	return true


func _all_sizes() -> Array:
	var sizes: Array = SIZES.duplicate()
	if RUN_320_OPTIONAL:
		sizes.append(320)
	return sizes


func _script_const(script: Script, name: String) -> Variant:
	if script == null:
		return null
	if script.has_method("get_script_constant_map"):
		var cm: Dictionary = script.call("get_script_constant_map")
		if cm.has(name):
			return cm[name]
	# Fallback: read the declaration from source text.
	var src := ""
	var f := FileAccess.open(script.resource_path, FileAccess.READ)
	if f != null:
		src = f.get_as_text()
		f.close()
	var re := RegEx.new()
	re.compile("(?m)^\\s*const\\s+" + name + "\\s*(?::[^=]+)?[:=]\\s*([^\\s]+)")
	var m := re.search(src)
	if m != null:
		return m.get_string(1)
	return null


func _source_text(path: String) -> String:
	var abs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(abs_path):
		return ""
	var f := FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


# ------------------------------------------------------------- statistics ----
func _hist(raw: PackedByteArray) -> Dictionary:
	var h := {}
	for b in raw:
		var k := str(int(b))
		h[k] = int(h.get(k, 0)) + 1
	return h


func _water_fraction(raw: PackedByteArray) -> float:
	if raw.is_empty():
		return 0.0
	var n := 0
	for b in raw:
		if int(b) == TILE_SENTINEL_WATER:
			n += 1
	return float(n) / float(raw.size())


func _shore_and_ratio(raw: PackedByteArray, w: int, h: int) -> Array:
	if w <= 0 or h <= 0 or raw.size() < w * h:
		return [0.0, 0.0, 0]
	var shore := 0
	var water := 0
	for i in range(w * h):
		if int(raw[i]) == TILE_SENTINEL_WATER:
			water += 1
			continue
		var x := i % w
		var y := int(i / w)
		var adjacent := false
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = x + d.x
			var ny: int = y + d.y
			if nx >= 0 and nx < w and ny >= 0 and ny < h:
				if int(raw[ny * w + nx]) == TILE_SENTINEL_WATER:
					adjacent = true
					break
		if adjacent:
			shore += 1
	var sf := float(shore) / float(w * h)
	var ratio := 0.0
	if water > 0:
		ratio = float(shore) / float(water)
	return [sf, ratio, shore]


func _deciles(raw: PackedByteArray) -> Array:
	var vals: Array[float] = []
	for i in range(int(raw.size() / 4)):
		vals.append(raw.decode_float(i * 4))
	if vals.is_empty():
		return []
	vals.sort()
	var out: Array[float] = [vals[0]]
	for k in range(1, 10):
		var pos := int(roundf(float(k) * float(vals.size() - 1) / 10.0))
		out.append(vals[clampi(pos, 0, vals.size() - 1)])
	out.append(vals[vals.size() - 1])
	var res: Array = []
	for v in out:
		res.append(v)
	return res


# ------------------------------------------------------------------- mesh -----
class StubGame extends C3Game:
	var height_b64: String = ""
	var tileblock_b64: String = ""
	var dump: Dictionary = {}


func _find_terrain_mesh(root: Node) -> MeshInstance3D:
	var best: MeshInstance3D = null
	var best_verts := -1
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			var m: Mesh = mi.mesh
			if m is ArrayMesh and m.get_surface_count() > 0:
				var arr: Array = m.surface_get_arrays(0)
				var vs = arr[Mesh.ARRAY_VERTEX]
				var c: int = vs.size() if vs != null else 0
				if c > best_verts:
					best_verts = c
					best = mi
		for c in n.get_children():
			stack.append(c)
	return best


func _inspect_mesh(size: int, s: Dictionary) -> Dictionary:
	var out := {"inspected": false, "reason": "not inspected"}
	var script := load(MODULE_WORLD) as Script
	if script == null or not script.can_instantiate():
		out["reason"] = "composer load failed"
		return out
	var inst: Object = script.new()
	if inst == null:
		out["reason"] = "composer new() failed"
		return out
	if not (inst is Node):
		out["reason"] = "composer is not a Node (expected Node3D per V11 CR3)"
		return out
	root.add_child(inst as Node)
	var g := StubGame.new()
	var hraw: PackedByteArray = s.get("height", PackedByteArray())
	var traw: PackedByteArray = s.get("tileblock", PackedByteArray())
	var craw: PackedByteArray = s.get("terrain", PackedByteArray())
	var braw: PackedByteArray = s.get("blocked", PackedByteArray())
	var n := size * size
	if craw.size() < n:
		craw = PackedByteArray()
		craw.resize(n)
	if braw.size() < n:
		braw = PackedByteArray()
		braw.resize(n)
	g.height = _f32_array(hraw)
	g.tileblock = traw.duplicate()
	g.terrain = craw
	g.blocked = braw
	root.add_child(g)
	inst.call("bind", g)
	var built := false
	if inst.has_method("build"):
		built = bool(inst.call("build"))
	out["build_ok"] = built
	if not built:
		out["reason"] = "composer build() returned false"
		return out
	var mi := _find_terrain_mesh(inst as Node)
	if mi == null or mi.mesh == null:
		out["reason"] = "no resident full-grid ArrayMesh"
		return out
	var m := mi.mesh
	var surfaces: int = m.get_surface_count()
	var arr: Array = m.surface_get_arrays(0)
	var vs = arr[Mesh.ARRAY_VERTEX]
	var inds = arr[Mesh.ARRAY_INDEX]
	var uv2 = arr[Mesh.ARRAY_TEX_UV2]
	var vertices: int = vs.size() if vs != null else -1
	var triangles: int = int(inds.size() / 3) if inds != null else -1
	var face_bad := 0
	var uv_bad := 0
	if uv2 != null:
		for i in range(uv2.size()):
			var fv := float(uv2[i].y)
			if fv < float(FACE_MIN) or fv > float(FACE_MAX) or absf(fv - roundf(fv)) > UV_EPS:
				face_bad += 1
			if i < traw.size() and absf(float(uv2[i].x) - float(traw[i])) > UV_EPS:
				uv_bad += 1
	else:
		face_bad = -1
		uv_bad = -1
	out = {
		"inspected": true, "build_ok": built, "surfaces": surfaces,
		"vertices": vertices, "expected_vertices": n,
		"triangles": triangles,
		"expected_triangles": (size - 1) * (size - 1) * TRI_PER_CELL,
		"uv2_face_violations": face_bad, "uv2_tile_violations": uv_bad,
		"reason": "",
	}
	return out


# ------------------------------------------------------------ vector hooks ---
func _probe_vector_hook(obj: Object, kind: String) -> void:
	var ml := obj.get_method_list()
	var found := ""
	var found_argc := -1
	for nm in VECTOR_HOOK_NAMES:
		for m in ml:
			if str(m.get("name", "")) == str(nm):
				found = str(nm)
				var ad: Variant = m.get("args", [])
				found_argc = (ad as Array).size() if ad is Array else 0
				break
		if not found.is_empty():
			break
	if found.is_empty():
		_hooks[kind] = {
			"status": "HOOK_MISSING", "policy": "ADVISORY",
			"detail": "no " + kind + " vector hook on I07/I09 module; X13/X21 not landed",
		}
		print("T_TERRAIN_DONOR ADVISORY_UNVERIFIED HOOK_MISSING %s - no vector hook; no pass claimed" % kind)
		return
	if found_argc > 0:
		_hooks[kind] = {
			"status": "UNVERIFIED", "policy": "ADVISORY", "hook": found,
			"detail": "hook needs %d args; not invoked; X13/X21 donor vectors not landed" % found_argc,
		}
		print("T_TERRAIN_DONOR ADVISORY_UNVERIFIED %s - hook=%s needs %d args (not invoked, no pass)"
			% [kind, found, found_argc])
		return
	var v: Variant = _call_hook(obj, [found], [])
	var text := _canon(v)
	if text.length() > 1200:
		text = text.substr(0, 1200) + "..."
	_hooks[kind] = {
		"status": "UNVERIFIED", "policy": "ADVISORY", "hook": found,
		"values": text,
		"detail": "X13/X21 donor vectors not landed; recorded, no parity/pass claim",
	}
	print("T_TERRAIN_DONOR ADVISORY_UNVERIFIED %s - hook=%s values=%s (UNVERIFIED, no pass)" % [kind, found, text])


# ------------------------------------------------------------------ _init ----
func _initialize() -> void:
	if _finished:
		return
	call_deferred("_failsafe")

	var sizes: Array = _all_sizes()
	var det_names: Array = []
	for sz in sizes:
		det_names.append("gen_stream_hook_%d" % sz)
		for st in STREAM_NAMES:
			det_names.append("determinism_%d_%s" % [sz, st])
	var array_struct_names: Array = []
	for sz in sizes:
		array_struct_names.append("grid_size_%d" % sz)
		array_struct_names.append("tile_id_range_%d" % sz)
	array_struct_names.append("water_shore_thresholds")
	array_struct_names.append("surface_count_one")
	array_struct_names.append("vertex_count_exact")
	array_struct_names.append("triangle_count_exact")
	array_struct_names.append("uv2_tile_id_invariant")
	array_struct_names.append("uv2_face_domain")
	var source_struct_names := ["visual_parity_claim_false", "no_synthetic_noise_field"]

	# ---------------------------------------------------------------- 1. GUARD
	var missing: Array[String] = []
	for p in REQUIRED_MODULES:
		var abs_path := ProjectSettings.globalize_path(str(p))
		var exists := FileAccess.file_exists(abs_path)
		if str(p).ends_with(".gd"):
			exists = exists and ResourceLoader.exists(str(p))
		if not exists:
			missing.append(str(p))
	_status = "MODULE_MISSING" if not missing.is_empty() else "RUNNING"
	check("module_present", missing.is_empty(),
		"required=%d missing=%s" % [REQUIRED_MODULES.size(), str(missing)],
		"V11 §3 N1/N8/N9/N11/N12; V21 U4")
	if not missing.is_empty():
		for p in missing:
			print("T_TERRAIN_DONOR MODULE_MISSING: " + str(p) + " is not on disk")
		fail_checks(det_names, "MODULE_MISSING", "fresh terrain module absent")
		fail_checks(array_struct_names, "MODULE_MISSING", "fresh terrain module absent")
		fail_checks(source_struct_names, "MODULE_MISSING", "fresh terrain module absent")
		for sz in sizes:
			advisory("S1_height_deciles_%d" % sz, "NOT_RUN", "MODULE_MISSING", "A05:149", "[I]")
			advisory("S2_water_fraction_%d" % sz, "NOT_RUN", ADVISORY_BANDS["water_fraction"], "A05:150", "[I]")
		for hk in ["blend_vectors", "rng_vectors"]:
			_hooks[hk] = {"status": "HOOK_MISSING", "policy": "ADVISORY",
					"detail": "module absent"}
		finish()
		return

	# Optional presence is informational, never a gate.
	for p in [MODULE_TILES, MODULE_SHADER, ASSET_MANIFEST]:
		advisory("optional_presence", str(p),
				FileAccess.file_exists(ProjectSettings.globalize_path(str(p))),
				"V11 §3 N10/N13, §4 G10", "[O]")
	_key_sha = _sha256(_canon({"seed": SEED, "keys": GEN_KEYS}).to_utf8_buffer())

	# -------------------------------------------- 2. SOURCE-LEVEL STRUCTURE (A)
	var data_script := load(MODULE_DATA) as Script
	var const_max: Variant = _script_const(data_script, "TILE_ID_MAX")
	var const_deep: Variant = _script_const(data_script, "WATER_DEEP")
	var const_shore: Variant = _script_const(data_script, "WATER_SHORE")
	var const_present := const_max != null and const_deep != null and const_shore != null
	check("water_shore_thresholds",
			const_present and absf(float(const_deep) - WATER_DEEP) < 1e-9
			and absf(float(const_shore) - WATER_SHORE) < 1e-9,
			"WATER_DEEP=%s WATER_SHORE=%s expected -0.25/-0.1"
				% [str(const_deep), str(const_shore)],
			"donor data/scripts/texturemap.inc:29-31; spec/05:12; terrain_donor_data.gd:35-36")

	# visual_parity_claim MUST be explicitly false (spec/11 §11.1:17).
	var parity_found := false
	var parity_value: Variant = null
	var parity_source := ""
	for p in [MODULE_WORLD, MODULE_DATA, MODULE_GEN, MODULE_MESH, MODULE_PROPS, ASSET_MANIFEST]:
		var txt := _source_text(p)
		if txt.is_empty():
			continue
		var re := RegEx.new()
		re.compile("(?mi)[\"']?visual_parity_claim[\"']?\\s*[:=]\\s*(false|true)")
		var m := re.search(txt)
		if m != null:
			parity_found = true
			parity_value = str(m.get_string(1)).to_lower() == "false"
			parity_source = str(p)
			break
	check("visual_parity_claim_false", parity_found and parity_value == true,
			"found=%s value=%s source=%s (must be explicit false)"
				% [str(parity_found), str(parity_value), parity_source],
			"spec/11 §11.1:17; A05 parity_guard; V21 U1")

	# No synthetic noise/dither field. Source scan ignores comment lines
	# (provenance comments legitimately say "no synthetic noise/dither").
	var synth_hits: Array[String] = []
	for p in [MODULE_WORLD, MODULE_DATA, MODULE_GEN, MODULE_MESH, MODULE_PROPS]:
		var txt := _source_text(p)
		if txt.is_empty():
			continue
		var lines := txt.split("\n")
		for line in lines:
			var t := str(line).strip_edges()
			if t.begins_with("#") or t.begins_with(";") or t.is_empty():
				continue
			for tok in SYNTHESIS_TOKENS:
				if t.find(str(tok)) >= 0:
					synth_hits.append(str(p) + ": " + t.substr(0, 160))
	check("no_synthetic_noise_field", synth_hits.is_empty(),
			"active synthesis tokens=%d %s" % [synth_hits.size(), str(synth_hits)],
			"CHARTER §4 (no synthetic noise/dither S-25-09); spec/10:60; V21 GR-A21")

	# ------------------------------------------------ 3. GENERATE + DETERMINISM
	for sz in sizes:
		var a := _generate_streams(sz)
		var b := _generate_streams(sz)
		var have: bool = _streams_valid(a) and _streams_valid(b)
		var detail_sizes := ""
		if have:
			for st in STREAM_NAMES:
				detail_sizes += "%s=%d " % [st, int((a[st] as PackedByteArray).size())]
		check("gen_stream_hook_%d" % sz, have,
				"two in-process generations at %d²: %s %s"
					% [sz, "ok" if have else "HOOK_MISSING/EMPTY", detail_sizes],
				"A05 §2.2; spec/12 §12.6:100-104; V21 GR-A01 (hard)")
		if not have:
			continue
		_streams[sz] = a
		_meta[sz] = {"w": a.get("w", sz), "h": a.get("h", sz),
				"source": str(a.get("generator", ""))}
		var hashes_a := {}
		var hashes_b := {}
		var det_row := {"size": sz, "hashes_a": {}, "hashes_b": {}, "equal": {}, "tolerance": 0}
		for st in STREAM_NAMES:
			var av: PackedByteArray = a.get(st, PackedByteArray())
			var bv: PackedByteArray = b.get(st, PackedByteArray())
			var ha := _sha256(av)
			var hb := _sha256(bv)
			hashes_a[st] = ha
			hashes_b[st] = hb
			var same: bool = ha == hb
			det_row["hashes_a"][st] = ha
			det_row["hashes_b"][st] = hb
			det_row["equal"][st] = same
			check("determinism_%d_%s" % [sz, st], same,
					"SHA-256 raw bytes A=%s B=%s bytes=%d/%d zero_tolerance"
						% [ha, hb, av.size(), bv.size()],
					"A05 §2.2/§2.3 D1; V21 GR-A01; CHARTER §6.3")
		det_row["pairwise_equal"] = hashes_a == hashes_b
		_det[str(sz)] = det_row

	# -------------------------------------------- 4. ARRAY STRUCTURE (class A)
	for sz in sizes:
		if not _streams.has(sz):
			continue
		var s: Dictionary = _streams[sz]
		var w: int = int(s.get("w", sz))
		var h: int = int(s.get("h", sz))
		var hraw: PackedByteArray = s.get("height", PackedByteArray())
		var traw: PackedByteArray = s.get("tileblock", PackedByteArray())
		var craw: PackedByteArray = s.get("terrain", PackedByteArray())
		var braw: PackedByteArray = s.get("blocked", PackedByteArray())
		var n := w * h
		var grid_ok: bool = (w == h and ALLOWED_SIZES.has(w) and n == sz * sz
				and hraw.size() == n * 4 and traw.size() == n
				and craw.size() == n and (braw.size() == n or braw.size() == n * 4))
		check("grid_size_%d" % sz, grid_ok,
				"w=%d h=%d n=%d height=%d tileblock=%d terrain=%d blocked=%d"
					% [w, h, n, hraw.size(), traw.size(), craw.size(), braw.size()],
				"donor miscext2.script:19-26, dmscript.global:132-135 (spec/01:30); terrain_donor_data.gd:43-45")
		var bad := 0
		for b in traw:
			var id := int(b)
			if id > TILE_ID_MAX and id != TILE_SENTINEL_WATER:
				bad += 1
		check("tile_id_range_%d" % sz, bad == 0,
				"illegal_ids=%d domain=[0,%d] sentinel=%d PORT-ONLY"
					% [bad, TILE_ID_MAX, TILE_SENTINEL_WATER],
				"donor terrain/tiles/terrain.presets:2-6,129 (spec/06:9); game.gd:52 (sentinel)")

	# Mesh-level invariants on the largest required size (V21 GR-A18/A20/A21).
	var primary: int = sizes[sizes.size() - 1]
	if _streams.has(primary):
		_mesh_info = _inspect_mesh(primary, _streams[primary])
		var mi: Dictionary = _mesh_info
		check("surface_count_one", bool(mi.get("inspected", false))
				and int(mi.get("surfaces", -1)) == 1,
				"surfaces=%s reason=%s" % [str(mi.get("surfaces", -1)), str(mi.get("reason", ""))],
				"t_terrain3d.gd:206-213 (G32 §6); spec/01 §2")
		check("vertex_count_exact", bool(mi.get("inspected", false))
				and int(mi.get("vertices", -1)) == int(mi.get("expected_vertices", -2)),
				"vertices=%s expected=%s" % [str(mi.get("vertices", -1)), str(mi.get("expected_vertices", -2))],
				"t_terrain3d.gd:215-226; G32 §6 (w*h shared cell-centre vertices)")
		check("triangle_count_exact", bool(mi.get("inspected", false))
				and int(mi.get("triangles", -1)) == int(mi.get("expected_triangles", -2)),
				"triangles=%s expected=%s" % [str(mi.get("triangles", -1)), str(mi.get("expected_triangles", -2))],
				"t_terrain3d.gd:8-10; G32 §6 ((w-1)*(h-1)*2)")
		check("uv2_tile_id_invariant", bool(mi.get("inspected", false))
				and int(mi.get("uv2_tile_violations", -1)) == 0,
				"UV2.x!=tex violations=%s eps=%s" % [str(mi.get("uv2_tile_violations", -1)), str(UV_EPS)],
				"spec/01:34; spec/06:42; world3d_terrain.gd:1315-1318 (PORT APPROX)")
		check("uv2_face_domain", bool(mi.get("inspected", false))
				and int(mi.get("uv2_face_violations", -1)) == 0,
				"UV2.y outside {0,1,2} violations=%s" % str(mi.get("uv2_face_violations", -1)),
				"spec/01:34 face in {0,1,2}; world3d_terrain.gd:1315-1318,1407 (PORT APPROX)")
	else:
		fail_checks(["surface_count_one", "vertex_count_exact", "triangle_count_exact",
				"uv2_tile_id_invariant", "uv2_face_domain"],
				"NO_STREAMS", "no generation output to inspect")
		_mesh_info = {"inspected": false, "reason": "no generation output"}

	# ---------------------------------------------- 5. ADVISORY STRUCTURE (B)
	for sz in sizes:
		if not _streams.has(sz):
			continue
		var s: Dictionary = _streams[sz]
		var traw: PackedByteArray = s.get("tileblock", PackedByteArray())
		var hraw: PackedByteArray = s.get("height", PackedByteArray())
		var w: int = int(s.get("w", sz))
		var h: int = int(s.get("h", sz))
		var dec := _deciles(hraw)
		advisory("S1_height_deciles_%d" % sz, dec,
				"max_share<=%s; >=%s of 5 bands" % [str(ADVISORY_BANDS["height_decile_max_share"]),
						str(ADVISORY_BANDS["donor_bands_min_occupied"])],
				"A05:149; donor_gen.py:49-59", "[I]/[D] ADVISORY")
		var wf := _water_fraction(traw)
		advisory("S2_water_fraction_%d" % sz, wf, ADVISORY_BANDS["water_fraction"],
				"A05:150; game.gd:52 water id 255 (hard in GR-A20)", "[I] ADVISORY")
		var sr := _shore_and_ratio(traw, w, h)
		advisory("S3_shore_fraction_%d" % sz, sr[0], ADVISORY_BANDS["shore_fraction"],
				"A05:151; V21 GR-B04", "[I] ADVISORY")
		advisory("S3_shore_water_ratio_%d" % sz, sr[1], ADVISORY_BANDS["shore_water_ratio"],
				"A05:151; V21 GR-B04", "[I] ADVISORY")
		var hist := _hist(traw)
		var land_ids := 0
		var top1 := 0
		for k in hist.keys():
			if int(k) != TILE_SENTINEL_WATER:
				land_ids += 1
			top1 = maxi(top1, int(hist[k]))
		var top_share := 0.0
		if not traw.is_empty():
			top_share = float(top1) / float(traw.size())
		advisory("S4_distinct_land_ids_%d" % sz, land_ids,
				">=%d" % int(ADVISORY_BANDS["distinct_land_ids_min"]),
				"A05:152; V21 GR-B05", "[I] ADVISORY")
		advisory("S4_top1_share_%d" % sz, top_share,
				"<=%s" % str(ADVISORY_BANDS["top1_share_max"]),
				"A05:152; V21 GR-B05", "[I] ADVISORY")
		var stamps_v: Variant = _read_from(s.get("props_obj", {}), ["relief_stamps"])
		var stamp_count: int = (stamps_v as Array).size() if stamps_v is Array else 0
		advisory("S5_relief_stamp_count_%d" % sz, stamp_count,
				"in spec range (empty)", "A05:153; V21 GR-B06", "[I] ADVISORY")
		advisory("S6_family_counts_%d" % sz,
				_read_from(s.get("props_obj", {}), ["res", "resources"]),
				"observed/expected ratio %s" % str(ADVISORY_BANDS["family_ratio"]),
				"A05:154; V21 GR-B07", "[D]/[I] ADVISORY")
		_structure[str(sz)] = {
			"height_deciles": dec, "water_fraction": wf, "shore_fraction": sr[0],
			"shore_water_ratio": sr[1], "tile_histogram": hist,
			"distinct_land_ids": land_ids, "top1_share": top_share,
			"n": traw.size(), "w": w, "h": h,
		}

	# ------------------------------------------------- 6. VECTOR HOOKS (B only)
	# X13 (blend) and X21 (RNG) reports are not landed (V21 U2 / landing check),
	# so even a present hook can only be RECORDED as UNVERIFIED — never a PASS.
	var hook_obj: Object = null
	var gen_script := load(MODULE_GEN) as Script
	if gen_script != null and gen_script.can_instantiate():
		hook_obj = gen_script.new()
	if hook_obj == null:
		var world_script := load(MODULE_WORLD) as Script
		if world_script != null and world_script.can_instantiate():
			hook_obj = world_script.new()
	if hook_obj != null:
		_probe_vector_hook(hook_obj, "blend_vectors")
		_probe_vector_hook(hook_obj, "rng_vectors")
		_dispose(hook_obj)
	else:
		for hk in ["blend_vectors", "rng_vectors"]:
			_hooks[hk] = {"status": "HOOK_MISSING", "policy": "ADVISORY",
					"detail": "no module instance for vector probe; X13/X21 not landed"}
			print("T_TERRAIN_DONOR ADVISORY_UNVERIFIED HOOK_MISSING %s - no module instance" % hk)

	finish()
