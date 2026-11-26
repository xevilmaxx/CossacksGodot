# ---------------------------------------------------------------------------
# variant3d/scripts/terrain_donor_inputs.gd — I17 (COORD-owned, 2026-11-26)
#
# The final functional gap: build I07's `p` Dictionary (contract at
# terrain_donor_gen.gd:414-437) from DERIVED assets only. No donor binary is
# executed, no donor path is read, no donor byte is copied. All inputs come
# from variant3d/assets/terrain_new/** (I15 report §4) and the live game/config
# (config.gd:515 `gameplay.random_seed`; config.gd:189
# `features.terrain.backend` path pattern).
#
# LABELS: [O] observed donor text/derived asset byte, [D] deterministic
# consequence, [U] UNVERIFIED, PORT APPROXIMATION for port substitutes.
# NO DONOR PARITY CLAIM: `visual_parity_claim` is hard-coded false; no donor
# GPU A/B frame exists (CHARTER.md:43-44,125; X54 card §3).
#
# Every donor constant below carries a `# donor path:line` citation. Unknown
# values are OMITTED, never guessed. No synthetic noise/dither field, no
# threshold change, no forest density derived from zero G.
#
# Public API:  build(game, w, h) -> Dictionary      (I07 `p`)
#              stats() -> Dictionary                (diagnostics only)
# ---------------------------------------------------------------------------
extends RefCounted
class_name C3TerrainDonorInputs

# --- derived-asset paths (canonical root: spec/11 §11.1, V11 G1-G11) --------
const ASSET_ROOT := "res://assets/terrain_new/"
const MASK_INDEX := "res://assets/terrain_new/masks/mask_index.json"
const CONSTANTS := "res://assets/terrain_new/cfg/constants.json"
const ATLAS_MANIFEST := "res://assets/terrain_new/atlas/tile_index_atlas.manifest.json"
const WINTER_ALIASES := "res://assets/terrain_new/atlas/seasons/winter_aliases.json"
const FAMILY_INDEX := "res://assets/terrain_new/patterns/family_index.json"
const FAMILY_DIR := "res://assets/terrain_new/patterns/families/"
const PATTERN_DIR := "res://assets/terrain_new/patterns/"

# --- donor-cited values (NO invention) -------------------------------------
const GENERATOR_VERSION_FALLBACK: int = 92   # donor serial.script:27 gDataVersion=92; X54 §1 row 10
const U32_MASK: int = 0xFFFFFFFF              # donor SetRandomExtKey64 64->32 split, spec/02 §1
const MASK_HEIGHT_SCALE: float = -1.1         # donor generatemap.inc:4-7 (cWaterHeight); spec/03 §1
const MASK_B_WATER_BYTE: int = 58             # donor generatemap.inc:486-490; spec/03 §1 (B>=58)
const MAX_PATTERNS: int = 64                  # PORT memory cap (not a donor constant)
const MAX_FAMILIES: int = 64                  # donor generator.cfg has exactly 64 families (spec/09 §1)

# Stamp families/patterns actually named by the ticket (donor generator.cfg:
# 67-154 / pattern.lib sections; spec/04 §1-§2, X54 §1 row 4).
const EXACT_PATTERNS: Array[String] = [
	"hil1", "g_hil4", "plt2", "k_ravine_1",     # relief grids, F01 offsets G=968/1864/2222/2798
	"mng_1", "mni_1", "mnc_1",                  # gold / iron / coal mines, pattern.lib:713285 etc.
]
const TARGET_FAMILIES: Array[String] = [
	"mng", "mni", "mnc", "tiles", "desert_tiles",
	"mountains", "hills_dark", "hills_light",
	"plateau", "plateau_big", "plateau_small",
	"ravine_big", "ravine_medium",
	"stones", "stoneforests", "desert_stones",
]

# Live config/data are read by preload, exactly as main.gd:41 / camera.gd:55 do.
const C3ConfigScript = preload("res://scripts/config.gd")
const DataScript = preload("res://scripts/data.gd")

var _last_stats: Dictionary = {}


# ---------------------------------------------------------------------------
# Small read-only helpers. A missing asset is a labelled skip, never an error.
# ---------------------------------------------------------------------------

func _prop(src, key: String):
	if src == null:
		return null
	if src is Dictionary:
		return (src as Dictionary).get(key, null)
	if src is Object:
		return (src as Object).get(key)
	return null


func _read_json(path: String, skipped: Array) -> Dictionary:
	if not FileAccess.file_exists(path):
		skipped.append("ABSENT " + path + " [U] — no substitute invented")
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		skipped.append("UNREADABLE " + path + " [U] — no substitute invented")
		return {}
	var txt: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if not (parsed is Dictionary):
		skipped.append("BAD_JSON " + path + " [U] — no substitute invented")
		return {}
	return parsed as Dictionary


func _hash32(s: String) -> int:
	# FNV-1a/32, a stable selector only. NOT an RNG draw and NOT terrain noise.
	var h: int = 2166136261
	for i in range(s.length()):
		h = (h ^ s.unicode_at(i)) & U32_MASK
		h = (h * 16777619) & U32_MASK
	return h


# ---------------------------------------------------------------------------
# Seed: config.gd:515 maps `gameplay.random_seed` to Data.RANDOM_SEED
# (data.gd:35). donor has TWO 32-bit words: high = randkey0, low = randkey1
# (spec/02 §1; donewgame.inc:16,33-37). X21 §4.3: key0 is discarded by
# mod 2^32 — only key1 seeds; key0 is therefore a labelled NO-OP.
# GenerateMapRandKey itself is [U] (spec/02 §1) — no derivation invented.
# ---------------------------------------------------------------------------
func _derive_seed(game) -> Dictionary:
	var seed_value: int = 0
	var have_seed := false
	var source := "NONE"
	var cfg = C3ConfigScript.active
	if cfg != null and cfg is Object and (cfg as Object).has_method("num"):
		var v: Variant = (cfg as Object).call("num", "gameplay.random_seed", -1.0)
		if v is int or v is float:
			seed_value = int(v)
			have_seed = seed_value >= 0
			if have_seed:
				source = "gameplay.random_seed (config.gd:515)"
	if not have_seed:
		for key in ["seed", "random_seed", "RANDOM_SEED"]:
			var gv: Variant = _prop(game, key)
			if gv is int or gv is float:
				seed_value = int(gv)
				have_seed = true
				source = "game." + key
				break
	if not have_seed:
		var dv: Variant = DataScript.RANDOM_SEED       # data.gd:35
		if dv is int:
			seed_value = int(dv)
			have_seed = true
			source = "C3Data.RANDOM_SEED (data.gd:35; config.gd:515)"
	var key0: int = (seed_value >> 32) & U32_MASK   # high word, donor spec/02 §1
	var key1: int = seed_value & U32_MASK           # low word, donor spec/02 §1
	return {
		"seed": seed_value,
		"have_seed": have_seed,
		"source": source,
		"randkey0": key0,
		"randkey1": key1,
		"key0_label": "DONOR high word [O] spec/02 §1; NO-OP mod 2^32 (X21 §4.3)",
		"key1_label": "DONOR low word [O] spec/02 §1; seeds the LCG (spec/02 §2)",
		"derivation_label": "[U] GenerateMapRandKey (spec/02 §1) — single 32-bit port seed used verbatim as key1; no mix64",
	}


# Map shape: menu/config terrain_type wins, then map_type (config.gd:535).
# The derived mask index uses the donor folder name as `shape`
# (mask_index.json:24 `shape`, :6-26 `types` keys).
func _shape_of(game) -> String:
	for key in ["shape", "map_type", "MAP_TYPE", "terrain_type", "TERRAIN_TYPE", "biome"]:
		var v: Variant = _prop(game, key)
		if v is String and not str(v).is_empty():
			return str(v).strip_edges().to_lower()
	var cfg = C3ConfigScript.active
	if cfg != null and cfg is Object and (cfg as Object).has_method("text"):
		var t: Variant = (cfg as Object).call("text", "gameplay.terrain_type", "")
		if t is String and not str(t).is_empty():
			return str(t).strip_edges().to_lower()
		var m: Variant = (cfg as Object).call("text", "gameplay.map_type", "")
		if m is String and not str(m).is_empty():
			return str(m).strip_edges().to_lower()
	return ""


# ---------------------------------------------------------------------------
# Mask: mask_index.json entry -> gray8 height PNG -> raw B bytes.
# h = -1.1*v/255 (donor generatemap.inc:4-7; shipped vanilla B channel per
# spec/03 §1). `p.mask_b` carries the RAW BYTE v: I07 divides by 255 and
# applies the same -1.1 scale (gen.gd:906), so the formula is preserved once.
# Starts are the manifest's normalised white dots (donor generatemap.inc:
# 440-443/486-490); converted to donor-centred cell coords (gen.gd:1450-1459).
# Forest density from G is [U] (mask_index.json:76-77) — NEVER derived from 0.
# ---------------------------------------------------------------------------
func _select_mask(seed: int, shape: String, w: int, h: int, skipped: Array) -> Dictionary:
	if shape.is_empty():
		skipped.append("MASK no shape from game/config — no mask selected, no synthetic field [U]")
		return {}
	var idx := _read_json(MASK_INDEX, skipped)
	if idx.is_empty():
		return {}
	var types_v: Variant = idx.get("types", null)
	if not (types_v is Dictionary):
		skipped.append("MASK index has no types table [U] — no mask selected")
		return {}
	var candidates: Array = []
	for type_key in (types_v as Dictionary).keys():
		var section_v: Variant = (types_v as Dictionary)[type_key]
		if not (section_v is Dictionary):
			continue
		var masks_v: Variant = (section_v as Dictionary).get("masks", [])
		if not (masks_v is Array):
			continue
		for mv in (masks_v as Array):
			if not (mv is Dictionary):
				continue
			var m: Dictionary = mv as Dictionary
			if str(m.get("shape", "")).strip_edges().to_lower() != shape:
				continue
			candidates.append({"type": str(type_key), "mask": m})
	if candidates.is_empty():
		skipped.append("MASK no entry for shape '" + shape + "' — no synthetic mask [U]")
		return {}
	candidates.sort_custom(func(a, b): return str(a["type"]) + "|" + str((a["mask"] as Dictionary).get("file", "")) < str(b["type"]) + "|" + str((b["mask"] as Dictionary).get("file", "")))
	# Prefer a mask whose native grid equals the caller's grid; never rescale.
	var exact: Array = []
	for c in candidates:
		var m: Dictionary = c["mask"]
		if int(m.get("width", 0)) == w and int(m.get("height", 0)) == h:
			exact.append(c)
	var pool: Array = candidates
	if not exact.is_empty():
		pool = exact
	var pick: int = _hash32("%d|%s" % [seed, shape]) % pool.size()
	var chosen: Dictionary = (pool[pick] as Dictionary)["mask"]
	return {"type": str((pool[pick] as Dictionary)["type"]), "mask": chosen,
			"exact_grid": not exact.is_empty()}


func _load_image(path: String) -> Image:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			var im: Image = (res as Texture2D).get_image()
			if im != null and not im.is_empty():
				return im
	var im2: Image = Image.load_from_file(path)
	if im2 != null and not im2.is_empty():
		return im2
	return null


func _apply_mask(p: Dictionary, seed: int, shape: String, w: int, h: int,
		skipped: Array, loaded: Array) -> Dictionary:
	var sel := _select_mask(seed, shape, w, h, skipped)
	if sel.is_empty():
		return {}
	var m: Dictionary = sel["mask"]
	var rel: String = str(m.get("file", ""))
	if rel.is_empty():
		skipped.append("MASK entry has no file — skipped [U]")
		return {}
	var path: String = ASSET_ROOT + "masks/" + rel
	if not FileAccess.file_exists(path):
		skipped.append("ABSENT " + path + " [U] — no substitute invented")
		return {}
	var img: Image = _load_image(path)
	if img == null:
		skipped.append("UNREADABLE " + path + " [U] — no substitute invented")
		return {}
	var mw: int = int(m.get("width", img.get_width()))
	var mh: int = int(m.get("height", img.get_height()))
	if mw != img.get_width() or mh != img.get_height():
		skipped.append("MASK size mismatch " + path + " — no resampling invented [U]")
		return {}
	var mb := PackedByteArray()
	mb.resize(mw * mh)
	for y in range(mh):
		for x in range(mw):
			var v: int = clampi(int(roundf(img.get_pixel(x, y).r * 255.0)), 0, 255)
			mb[y * mw + x] = v
	p["mask_b"] = mb                                   # raw gray8 byte v; h=-1.1*v/255
	p["width"] = mw                                    # native mask grid, never resampled
	p["height"] = mh
	var starts: Array = []
	var sv: Variant = m.get("starts", [])
	if sv is Array:
		for s in (sv as Array):
			if s is Array and (s as Array).size() >= 2:
				var nx: float = float((s as Array)[0])
				var ny: float = float((s as Array)[1])
				starts.append(Vector2(nx * float(mw) - float(mw) * 0.5,
						ny * float(mh) - float(mh) * 0.5))
	if not starts.is_empty():
		p["starts"] = starts                           # donor-centred cells, gen.gd:1450
	loaded.append("MASK " + path + " (" + str(mw) + "x" + str(mh) + ", " + str(starts.size()) + " starts)")
	return {
		"type": str(sel["type"]), "file": path,
		"width": mw, "height": mh, "starts": starts.size(),
		"exact_grid": bool(sel["exact_grid"]),
		"height_formula": "h=-1.1*v/255 (donor generatemap.inc:4-7; p.mask_b carries raw byte v)",
		"forest_density": null,
		"forest_density_label": "[U] G=0 on vanilla non-start pixels; no density invented (mask_index.json:76-77)",
	}


# ---------------------------------------------------------------------------
# Config-derived scalars and tile data. Only keys that are actually emitted
# are copied; unknown values stay absent (spec/11 §11.1 item 2).
# ---------------------------------------------------------------------------
func _struct_indices(path: String) -> Array:
	var out: Array = [-1, -1, -1]
	var parts: Array = path.split("/")
	var names: Array[String] = ["TileSmoothLists", "SmoothTiles", "TileNames"]
	for part in parts:
		var seg: String = str(part)
		for j in range(names.size()):
			if seg.begins_with(names[j]):
				var hashpos: int = seg.find("#")
				if hashpos >= 0:
					out[j] = int(seg.substr(hashpos + 1)) - 1   # cfg is 1-based
	return out


func _apply_constants(p: Dictionary, skipped: Array, loaded: Array) -> Dictionary:
	var doc := _read_json(CONSTANTS, skipped)
	var names_to_id: Dictionary = {}
	var id_to_names: Dictionary = {}
	var stat_names: Dictionary = {}
	var stat_probs: Dictionary = {}
	var have_version := false
	var have_mapsize := false
	var have_relief := false
	var have_mines := false
	var have_chains := false
	var have_ids := false
	if not doc.is_empty():
		var list_v: Variant = doc.get("constants", [])
		if list_v is Array:
			for cv in (list_v as Array):
				if not (cv is Dictionary):
					continue
				var c: Dictionary = cv as Dictionary
				var key: String = str(c.get("key", ""))
				var cite: String = str(c.get("source_short", "")) + ":" + str(c.get("line", "?"))
				if not bool(c.get("active", true)):
					continue
				if not have_version and key in ["generator_version", "gDataVersion", "DataVersion"]:
					p["generator_version"] = int(c.get("value", 0))
					have_version = true
					loaded.append("generator_version from " + cite)
				elif not have_mapsize and key == "mapsize":
					p["mapsize"] = int(c.get("value", 0))
					have_mapsize = true
					loaded.append("mapsize from " + cite)
				elif not have_relief and key == "relieftype":
					p["relieftype"] = int(c.get("value", 0))
					have_relief = true
					loaded.append("relieftype from " + cite)
				elif not have_mines and key in ["minesdensity", "minerdensity"]:
					p["minesdensity"] = int(c.get("value", 0))
					have_mines = true
					loaded.append("minesdensity from " + cite)
				elif not have_ids and key == "tile_name_to_id" and c.get("value") is Dictionary:
					p["tile_name_to_id"] = c["value"]
					have_ids = true
				elif not have_chains and key == "tile_smooth_chains" and c.get("value") is Array:
					p["tile_smooth_chains"] = c["value"]
					have_chains = true
				# tilesmooth_scripts.cfg:1-1863 — flat entries carrying a
				# structural_path; rebuild the 22-chain table losslessly.
				var path: String = str(c.get("structural_path", ""))
				if path.find("TileSmoothLists/") < 0:
					continue
				var ix: Array = _struct_indices(path)
				if ix[0] < 0 or ix[1] < 0 or ix[2] < 0:
					continue
				var ck: String = "%03d_%03d_%03d" % [ix[0], ix[1], ix[2]]
				if key == "TileName":
					stat_names[ck] = str(c.get("value", ""))
				elif key == "Prob":
					stat_probs[ck] = float(c.get("value", 0.0))
	if not have_version:
		p["generator_version"] = GENERATOR_VERSION_FALLBACK    # donor serial.script:27
		loaded.append("generator_version=92 [O] donor serial.script:27 (not emitted in constants.json)")

	# Tile ids: atlas layout is derived from donor presets (F05 E01/E04;
	# terrain.presets:6-129), winter is a one-for-one rename (F05 §1).
	var am := _read_json(ATLAS_MANIFEST, skipped)
	if not am.is_empty():
		var layout_v: Variant = am.get("layout", [])
		if layout_v is Array:
			for lv in (layout_v as Array):
				if not (lv is Dictionary):
					continue
				var e: Dictionary = lv as Dictionary
				if not (e.has("index") and e.has("name")):
					continue
				var tid: int = int(e["index"])
				var tname: String = str(e["name"])
				names_to_id[tname] = tid
				id_to_names[str(tid)] = tname
			if not names_to_id.is_empty():
				loaded.append("tile ids " + str(names_to_id.size()) + " from atlas/tile_index_atlas.manifest.json:8-129 (donor presets)")
	var wa := _read_json(WINTER_ALIASES, skipped)
	if not wa.is_empty():
		var we_v: Variant = wa.get("entries", [])
		if we_v is Array:
			for wv in (we_v as Array):
				if wv is Dictionary and (wv as Dictionary).has("winter_alias"):
					var wed: Dictionary = wv as Dictionary
					names_to_id[str(wed["winter_alias"])] = int(wed.get("index", -1))
	if not names_to_id.is_empty():
		if not have_ids:
			p["tile_name_to_id"] = names_to_id
		p["tile_id_to_name"] = id_to_names
		loaded.append("winter tile aliases from atlas/seasons/winter_aliases.json (index-preserving)")

	var chain_count := 0
	var group_count := 0
	var entry_count := 0
	if not have_chains and not stat_names.is_empty():
		var chains: Array = []
		var keys: Array = stat_names.keys()
		keys.sort()                                    # zero-padded = donor order
		for ck in keys:
			var segs: Array = str(ck).split("_")
			var li: int = int(segs[0])
			var gi: int = int(segs[1])
			var ei: int = int(segs[2])
			while chains.size() <= li:
				chains.append([])
			var groups: Array = chains[li]
			while groups.size() <= gi:
				groups.append([])
			var entries: Array = groups[gi]
			while entries.size() <= ei:
				entries.append({})
			var entry: Dictionary = {
				"name": str(stat_names[ck]),
				"prob": float(stat_probs.get(ck, 0.0)),
			}
			if names_to_id.has(str(stat_names[ck])):
				entry["id"] = int(names_to_id[str(stat_names[ck])])
			entries[ei] = entry
		p["tile_smooth_chains"] = chains
		chain_count = chains.size()
		for g in chains:
			group_count += (g as Array).size()
			for e2 in (g as Array):
				entry_count += (e2 as Array).size()
		loaded.append("tile_smooth_chains " + str(chain_count) + " chains / " + str(group_count) +
				" groups / " + str(entry_count) + " entries from tilesmooth_scripts.cfg:1-1863")
	elif not have_chains:
		skipped.append("tile_smooth_chains not emitted [U] — tile smoothing stays skipped, no invented table")

	return {
		"generator_version": int(p.get("generator_version", -1)),
		"mapsize_present": have_mapsize,
		"relieftype_present": have_relief,
		"minesdensity_present": have_mines,
		"tile_ids": names_to_id.size(),
		"chains": chain_count, "groups": group_count, "entries": entry_count,
		"cite": "globalparams.cfg:2-20; tilesmooth_scripts.cfg:1-1863; presets_summer.json:2-125",
	}


# ---------------------------------------------------------------------------
# Bounded decoded patterns + families (NEVER the 55.8 MB lib index at runtime).
# pattern.lib family/freq metadata: generator.cfg:67-154 (spec/04 §2).
# Decoded float grid: F01 G=8+(w-1)(h-1) (spec/04 §4; X54 §1 row 4).
# Blend fields: pattern.lib:549563-549575; native stamp cossacks.exe:0x755f30
# (spec/04 §6). Only those fields are carried into I07's `p`.
# ---------------------------------------------------------------------------
func _target_family(name: String) -> bool:
	if TARGET_FAMILIES.has(name):
		return true
	return name.find("forest") >= 0 or name.find("stoneforest") >= 0


func _target_pattern(name: String) -> bool:
	if EXACT_PATTERNS.has(name):
		return true
	for prefix in ["frs_", "frt_", "d_frt_", "d_stn_", "d_plt", "hil", "g_hil", "plt", "k_ravine", "mng", "mni", "mnc"]:
		if name.begins_with(prefix):
			return true
	return false


func _decode_pattern(name: String, skipped: Array) -> Dictionary:
	var path: String = PATTERN_DIR + name + ".json"
	if not FileAccess.file_exists(path):
		skipped.append("ABSENT " + path + " [U] — pattern not stamped")
		return {}
	var doc := _read_json(path, skipped)
	if doc.is_empty():
		return {}
	var w: int = int(doc.get("w", 0))
	var hh: int = int(doc.get("h", 0))
	var gv: Variant = doc.get("relief_float_grid", null)
	if w <= 0 or hh <= 0 or not (gv is Array):
		skipped.append("NO_GRID " + path + " [U] — no synthetic grid")
		return {}
	var grid := PackedFloat32Array()
	grid.resize(w * hh)
	var src: Array = gv as Array
	var m: int = mini(grid.size(), src.size())
	for i in range(m):
		grid[i] = float(src[i])
	var fv: Variant = doc.get("flags", {})
	var flags: Dictionary = fv if fv is Dictionary else {}
	var out: Dictionary = {
		"name": str(doc.get("name", name)),
		"w": w, "h": hh,
		"grid": grid,                                   # f32[w*h] at corrected F01 offset
		"scale": float(flags.get("Scale", 1.0)),        # pattern.lib HeightFieldScale +0x48
		"min": float(flags.get("Min", 0.0)),            # +0x5c, PIVOT (never a clamp)
		"offset": float(flags.get("Offset", 0.0)),      # +0x64
		"terrain_scale": float(flags.get("TerrainScale", 1.0)),  # +0x68
		"replace": bool(flags.get("Replace", false)),              # +0x3a
		"replace_for_water": bool(flags.get("ReplaceForWater", false)),  # +0x3b
		"height_field_stand": bool(flags.get("Stand", false)),
		"height_field_smooth": bool(flags.get("Smooth", false)),
		"grid_offset": int(doc.get("grid_offset", 0)),
		"grid_layout": "h x w row-major f32; G=8+(w-1)(h-1) [O] F01 §4.4",
		"label": "[O] DECODED grid+flags; row sign / global clamp [U]; no parity claim",
	}
	var occ_v: Variant = doc.get("occupancy_cells", null)
	if occ_v is Array and (occ_v as Array).size() == w * hh:
		var occ := PackedByteArray()
		occ.resize(w * hh)
		for i in range(w * hh):
			occ[i] = int((occ_v as Array)[i]) & 0xFF
		out["occupancy"] = occ
	else:
		out["occupancy_label"] = "[U] decoded occupancy is (h-1)x(w-1) lattice, not the w*h stamp mask — gate left unmodified"
	return out


func _apply_patterns(p: Dictionary, seed: int, skipped: Array, loaded: Array) -> Dictionary:
	var families: Dictionary = {}
	var patterns: Dictionary = {}
	var fi := _read_json(FAMILY_INDEX, skipped)
	var fam_names: Array[String] = []
	if not fi.is_empty():
		var fs_v: Variant = fi.get("families", [])
		if fs_v is Array:
			for fv in (fs_v as Array):
				if fv is Dictionary and (fv as Dictionary).has("family"):
					fam_names.append(str((fv as Dictionary)["family"]))
	fam_names.sort()                                   # deterministic set order
	var selected: Array[String] = []
	for fn in fam_names:
		if _target_family(fn):
			selected.append(fn)
	if selected.size() > MAX_FAMILIES:
		selected = selected.slice(0, MAX_FAMILIES)
	var fam_pattern_names: Array[String] = []
	for fn in selected:
		var fp: String = FAMILY_DIR + fn + ".json"
		if not FileAccess.file_exists(fp):
			skipped.append("ABSENT " + fp + " [U] — family not supplied")
			continue
		var fd := _read_json(fp, skipped)
		if fd.is_empty():
			continue
		var members: Array = []
		var pv: Variant = fd.get("patterns", [])
		if pv is Array:
			for mv in (pv as Array):
				if not (mv is Dictionary):
					continue
				var md: Dictionary = mv as Dictionary
				var nm: String = str(md.get("match", md.get("pattern", "")))
				if nm.is_empty():
					continue
				members.append({"name": nm, "freq": float(md.get("freq", 0.0))})
				if _target_pattern(nm) and not EXACT_PATTERNS.has(nm) and not fam_pattern_names.has(nm):
					fam_pattern_names.append(nm)
		families[fn] = members
		loaded.append("FAMILY " + fp + " (" + str(members.size()) + " name/freq pairs)")
	if not fi.is_empty():
		skipped.append("NOT_LOADED " + ASSET_ROOT + "lib/pattern_lib_index.json [U] — 55.8 MB metadata index, family_index.json used instead")

	# Exact relief/mine patterns first, then a seed-rotated bounded sample of
	# the forest/stone/plateau names from those families (cap 64, no synthesis).
	var ordered: Array[String] = []
	for n in EXACT_PATTERNS:
		if FileAccess.file_exists(PATTERN_DIR + n + ".json"):
			ordered.append(n)
		else:
			skipped.append("ABSENT " + PATTERN_DIR + n + ".json [U] — pattern not stamped")
	fam_pattern_names.sort()
	var pool: Array[String] = []
	for n in fam_pattern_names:
		if FileAccess.file_exists(PATTERN_DIR + n + ".json"):
			pool.append(n)
	if not pool.is_empty():
		var start: int = _hash32("%d|patterns" % seed) % pool.size()
		for k in range(pool.size()):
			if ordered.size() >= MAX_PATTERNS:
				break
			var candidate: String = pool[(start + k) % pool.size()]
			if not ordered.has(candidate):
				ordered.append(candidate)
	for n in ordered:
		var decoded := _decode_pattern(n, skipped)
		if not decoded.is_empty():
			patterns[n] = decoded
			loaded.append("PATTERN " + PATTERN_DIR + n + ".json")
	p["patterns"] = patterns
	p["families"] = families
	return {
		"patterns_loaded": patterns.size(),
		"families_loaded": families.size(),
		"cap": MAX_PATTERNS,
		"cite": "generator.cfg:67-154; pattern.lib:549563-549575; cossacks.exe:0x755f30; F01 §4.4",
	}


# ---------------------------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------------------------

## Build I07's `p` Dictionary (terrain_donor_gen.gd:414-437) from derived
## assets. `game` is read-only; w/h are the caller's grid (used only to prefer
## a native-size mask). Missing assets are labelled skips, never inventions.
func build(game, w: int, h: int) -> Dictionary:
	var skipped: Array = []
	var loaded: Array = []
	var p: Dictionary = {}
	var seed_info := _derive_seed(game)
	var seed: int = int(seed_info["seed"])
	if bool(seed_info["have_seed"]):
		p["randkey0"] = int(seed_info["randkey0"])   # high word — NO-OP per X21 §4.3
		p["randkey1"] = int(seed_info["randkey1"])   # low word — seeds per spec/02 §2
		loaded.append("seed from " + str(seed_info["source"]))
	else:
		skipped.append("no seed in config/game — randkey0/1 omitted, no invented seed [U]")
	var shape: String = _shape_of(game)
	var mask_info := _apply_mask(p, seed, shape, w, h, skipped, loaded)
	var const_info := _apply_constants(p, skipped, loaded)
	var pat_info := _apply_patterns(p, seed, skipped, loaded)
	p["visual_parity_claim"] = false
	var unverified: Array[String] = [
		"forest density from mask G: [U] G=0 on all shipped vanilla non-start pixels; no density invented (spec/03 §4; mask_index.json:76-77)",
		"GenerateMapRandKey: [U] spec/02 §1; no mix64 per-stage derivation (spec/02 §5)",
		"stamp row sign / global setter clamp / x87 precision: [U] spec/04 §6",
		"tile_smooth pass count 6 (globalparams.cfg:9) preserved as donor contradiction; script uses 3 (smoothtiles.inc:237)",
	]
	_last_stats = {
		"module": "res://scripts/terrain_donor_inputs.gd",
		"ticket": "I17",
		"visual_parity_claim": false,
		"parity": "UNVERIFIED — derived assets only; no donor GPU A/B frame",
		"diagnostics_only": true,
		"requested_grid": {"w": w, "h": h},
		"seed": {
			"value": seed,
			"source": str(seed_info["source"]),
			"randkey0": int(seed_info["randkey0"]),
			"randkey1": int(seed_info["randkey1"]),
			"key0_label": str(seed_info["key0_label"]),
			"key1_label": str(seed_info["key1_label"]),
			"derivation_label": str(seed_info["derivation_label"]),
		},
		"shape": shape,
		"mask": mask_info,
		"constants": const_info,
		"patterns": pat_info,
		"loaded": loaded,
		"skipped": skipped,
		"unverified": unverified,
		"donor_citations": [
			"generatemap.inc:4-7 (h=-1.1*B/255)",
			"generatemap.inc:440-443,486-490 (white starts; B class)",
			"donewgame.inc:16,33-37 (randkey0/1 high/low words)",
			"spec/02 §1/§2/§5 + X21 §4.3 (key1 seeds; key0 NO-OP)",
			"serial.script:27 (gDataVersion=92)",
			"globalparams.cfg:2-20 (flat keys)",
			"tilesmooth_scripts.cfg:1-1863 (22 chains / 282 entries)",
			"terrain.presets:6-129 (124 tile ids; F05 E01/E04)",
			"generator.cfg:67-154 (64 families / 493 Pattern+Freq)",
			"F01 §4.4 G=8+(w-1)(h-1) (decoded relief float grid)",
			"pattern.lib:549563-549575; cossacks.exe:0x755f30 (blend flags/math)",
		],
	}
	return p


## Exact diagnostics for the most recent build(); never fed back into sim,
## mesh, water, tile assignment or gates.
func stats() -> Dictionary:
	if _last_stats.is_empty():
		return {
			"module": "res://scripts/terrain_donor_inputs.gd",
			"ticket": "I17",
			"visual_parity_claim": false,
			"parity": "UNVERIFIED — build() not called yet",
			"loaded": [], "skipped": [],
		}
	return _last_stats.duplicate(true)
