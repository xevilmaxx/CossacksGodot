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
# PERF (W06 Rank 2): the validated compact bundle at
# `assets/terrain_new/patterns/compact/` is the preferred runtime input. It is
# decoded in memory; the original family-index/family-file/pattern-file path is
# retained as an explicit fallback for an absent or invalid bundle. Runtime
# parse counts below are diagnostics only. NO DONOR PARITY CLAIM.
#
# Public API:  build(game, w, h) -> Dictionary      (I07 `p`)
#              stats() -> Dictionary                (diagnostics only)
#
# GEN1TO1 HARD PORT (2026-11-26, worker IMPL-GEN-1TO1), driven by
# docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_generation.md §G.6.
# Backup: inbox/backup/terrain_donor_inputs.gd.bak-GEN1TO1 (SHA256 9511E178…).
# No invented constant, no synthetic field, no parity claim. [U] items stay
# labelled and are reported, never given a fabricated fallback.
#
# GENSEED HARD PORT (2026-11-26, worker IMPL-GEN-SEED), driven by
# docs/terrain_swarm_2026-11-26/reports/DEC_U_gen_seed.md §2.2/§2.4/§4 and
# PORT1TO1_terrain_generation.md §G.6. Backup before edit:
# inbox/backup/terrain_donor_inputs.gd.bak-GENSEED (SHA256 10B7FA08…).
# SCOPE: static donor facts only — randkey0/1 seed source, key0-discard across
# all 11+3 reseeds, [U] GenerateMapRandKey with ±1 probe. ADDITIVE labels only:
# no mask-pick draw, no seed derivation, no gate, no constant, no parity claim.
# Donor never executed; no Godot/runner/git.
#
# PLACEMENT HARD PORT (2026-11-26, worker IMPL-PLACEMENT), driven by
# docs/terrain_swarm_2026-11-26/reports/DEC_U_placement.md §8 P-PLACE-01..16.
# Backup before edit: inbox/backup/terrain_donor_inputs.gd.bak-PLACEMENT.
# SCOPE: P-PLACE-16 only — remove the FNV hash mask-pick draw; inputs exposes
# `mask_count` and selects a deterministic sorted asset index. The donor
# `floor(RandomExt*count)` draw is the generator's D2:190 on the inherited
# D1:1538 stream. Nearest sampling, land->nowater2 alias and conifer gate are
# unchanged. No invented density/draw/count, no parity claim; IMPL-GEN-SEED and
# all user mods preserved.
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
const COMPACT_DIR := "res://assets/terrain_new/patterns/compact/"
const COMPACT_MANIFEST := COMPACT_DIR + "manifest.json"
const COMPACT_FAMILIES := COMPACT_DIR + "families.json"
const COMPACT_PATTERNS := COMPACT_DIR + "patterns.json"
const COMPACT_SCHEMA := "terrain_new/patterns_compact/v1"

# GEN1TO1 §G.6 [O] generator.cfg:5-6 — live Land shape folder is `nowater2`
# (`land` is commented out). Canonicalise only that alias, never other shapes.
const SHAPE_ALIASES: Dictionary = {"land": "nowater2"}

# --- donor-cited values (NO invention) -------------------------------------
const GENERATOR_VERSION_FALLBACK: int = 92   # donor serial.script:27 gDataVersion=92; X54 §1 row 10
const U32_MASK: int = 0xFFFFFFFF              # donor SetRandomExtKey64 64->32 split, spec/02 §1
const MASK_HEIGHT_SCALE: float = -1.1         # donor generatemap.inc:4-7 (cWaterHeight); spec/03 §1
const MASK_B_WATER_BYTE: int = 58             # donor generatemap.inc:486-490; spec/03 §1 (B>=58)
const MAX_PATTERNS: int = 64                  # PORT memory cap (not a donor constant)
const MAX_FAMILIES: int = 64                  # donor generator.cfg has exactly 64 families (spec/09 §1)
const TILE_SMOOTH_CHAIN_COUNT: int = 22       # tilesmooth_scripts.cfg:1-1863; spec/09 §1 (282 active entries)

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
var _shape_info: Dictionary = {}

# GEN1TO1 §G.6 [O]: donor nearest-pixel sampler is `floor(x/W*srcW)` /
# `floor(y/H*srcH)` (D2:409-411,541-542). Nearest is now the DEFAULT; bilinear
# is retained ONLY as an explicit comparison hook, never as donor truth.
var mask_resample_mode: String = "nearest"

# GEN1TO1 §G.6 [O]: shipped skirmish pins foreststype=0 (D1:5-6) = conifer only.
# Leaf/mixed families stay gated behind this explicit opt-in; default false.
var include_leaf_forests: bool = false
var _family_gate_notes: Array[String] = []


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


func _pattern_entry_name(entry: Dictionary) -> String:
	# Some authoritative family rows have match:null and a valid pattern name.
	# Never stringify null or case-fold a name: both would invent a lookup key.
	var match_v: Variant = entry.get("match", null)
	if match_v is String and not (match_v as String).is_empty():
		return match_v as String
	var pattern_v: Variant = entry.get("pattern", null)
	if pattern_v is String and not (pattern_v as String).is_empty():
		return pattern_v as String
	return ""


func _read_compact_json(path: String, skipped: Array, telemetry: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		skipped.append("ABSENT " + path + " [U] — no substitute invented")
		telemetry["fallback_reason"] = "ABSENT " + path
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		skipped.append("UNREADABLE " + path + " [U] — no substitute invented")
		telemetry["fallback_reason"] = "UNREADABLE " + path
		return {}
	var byte_count: int = f.get_length()
	var txt: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if not (parsed is Dictionary):
		skipped.append("BAD_JSON " + path + " [U] — no substitute invented")
		telemetry["fallback_reason"] = "BAD_JSON " + path
		return {}
	telemetry["files_parsed"] = int(telemetry.get("files_parsed", 0)) + 1
	telemetry["bytes_parsed"] = int(telemetry.get("bytes_parsed", 0)) + byte_count
	return parsed as Dictionary


func _compact_failure(reason: String, skipped: Array, telemetry: Dictionary) -> Dictionary:
	telemetry["fallback_reason"] = reason
	skipped.append("COMPACT_FALLBACK [U] — " + reason +
			"; file-based family/pattern sources retained")
	return {"telemetry": telemetry}


func _compact_false_claim(doc: Dictionary) -> bool:
	var claim: Variant = doc.get("visual_parity_claim", null)
	return claim is bool and not (claim as bool)


func _compact_sha256(value: Variant) -> bool:
	if not (value is String) or (value as String).length() != 64:
		return false
	var text: String = value as String
	for i in range(64):
		if not "0123456789abcdef".contains(text[i]):
			return false
	return true


func _compact_nonnegative_int(value: Variant) -> bool:
	return value is int and int(value) >= 0


func _compact_positive_int(value: Variant) -> bool:
	return value is int and int(value) > 0


func _compact_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _compact_grid_valid(value: Variant, expected: int) -> bool:
	if not (value is Array) or (value as Array).size() != expected:
		return false
	for item in (value as Array):
		if not _compact_number(item):
			return false
	return true


func _compact_occupancy_valid(value: Variant, w: int, h: int) -> bool:
	if not (value is Array):
		return false
	var cells: Array = value as Array
	if cells.size() != w * h and cells.size() != (w - 1) * (h - 1):
		return false
	for item in cells:
		if not (item is int) or int(item) < 0 or int(item) > 255:
			return false
	return true


func _validate_compact_bundle(manifest: Dictionary, families_doc: Dictionary,
		patterns_doc: Dictionary, families_bytes: int, patterns_bytes: int) -> String:
	if manifest.get("schema", null) != COMPACT_SCHEMA:
		return COMPACT_MANIFEST + " — unsupported schema"
	if families_doc.get("schema", null) != COMPACT_SCHEMA:
		return COMPACT_FAMILIES + " — unsupported schema"
	if patterns_doc.get("schema", null) != COMPACT_SCHEMA:
		return COMPACT_PATTERNS + " — unsupported schema"
	if not _compact_false_claim(manifest):
		return COMPACT_MANIFEST + " — visual_parity_claim must be false"
	if not _compact_false_claim(families_doc):
		return COMPACT_FAMILIES + " — visual_parity_claim must be false"
	if not _compact_false_claim(patterns_doc):
		return COMPACT_PATTERNS + " — visual_parity_claim must be false"
	if not (families_doc.get("families", null) is Array):
		return COMPACT_FAMILIES + " — families must be an array"
	if not (patterns_doc.get("patterns", null) is Dictionary):
		return COMPACT_PATTERNS + " — patterns must be a map"
	if not (manifest.get("excluded_non_pattern_json", null) is Array):
		return COMPACT_MANIFEST + " — excluded_non_pattern_json must be an array"
	if not (manifest.get("missing_family_pattern_files", null) is Array):
		return COMPACT_MANIFEST + " — missing_family_pattern_files must be an array"
	for item in (manifest.get("excluded_non_pattern_json") as Array):
		if not (item is String):
			return COMPACT_MANIFEST + " — excluded_non_pattern_json entries must be strings"
	for item in (manifest.get("missing_family_pattern_files") as Array):
		if not (item is String):
			return COMPACT_MANIFEST + " — missing_family_pattern_files entries must be strings"

	var source_sha: Variant = manifest.get("source_family_index_sha256", null)
	if not _compact_sha256(source_sha):
		return COMPACT_MANIFEST + " — source family-index SHA-256 missing or malformed"
	if families_doc.get("source_sha256", null) != source_sha:
		return COMPACT_FAMILIES + " — source SHA-256 does not match manifest"
	if not (families_doc.get("source", null) is String) or (families_doc.get("source") as String).is_empty():
		return COMPACT_FAMILIES + " — source family-index path missing"
	if not _compact_positive_int(manifest.get("source_family_index_bytes", null)):
		return COMPACT_MANIFEST + " — invalid source_family_index_bytes"
	if not _compact_nonnegative_int(manifest.get("source_family_bytes", null)):
		return COMPACT_MANIFEST + " — invalid source_family_bytes"
	if not _compact_positive_int(manifest.get("source_pattern_bytes", null)):
		return COMPACT_MANIFEST + " — invalid source_pattern_bytes"
	if not _compact_nonnegative_int(manifest.get("source_family_files", null)):
		return COMPACT_MANIFEST + " — invalid source_family_files"
	if not _compact_positive_int(manifest.get("source_pattern_files", null)):
		return COMPACT_MANIFEST + " — invalid source_pattern_files"
	if not _compact_positive_int(manifest.get("source_total_bytes", null)):
		return COMPACT_MANIFEST + " — invalid source_total_bytes"
	if not _compact_nonnegative_int(manifest.get("compact_family_count", null)):
		return COMPACT_MANIFEST + " — invalid compact_family_count"
	if not _compact_positive_int(manifest.get("compact_pattern_count", null)):
		return COMPACT_MANIFEST + " — invalid compact_pattern_count"
	if manifest.get("compact_files", null) != 2:
		return COMPACT_MANIFEST + " — compact_files must count the two payload files"
	if not _compact_positive_int(manifest.get("compact_bytes", null)):
		return COMPACT_MANIFEST + " — invalid compact_bytes"
	if manifest.get("roundtrip", null) != "PASS":
		return COMPACT_MANIFEST + " — roundtrip must be PASS"

	var family_entries: Array = families_doc.get("families") as Array
	var pattern_map: Dictionary = patterns_doc.get("patterns") as Dictionary
	if int(manifest["compact_family_count"]) != family_entries.size():
		return COMPACT_MANIFEST + " — compact_family_count mismatch"
	if int(manifest["compact_pattern_count"]) != pattern_map.size():
		return COMPACT_MANIFEST + " — compact_pattern_count mismatch"
	if int(manifest["source_family_files"]) != family_entries.size():
		return COMPACT_MANIFEST + " — source_family_files mismatch"
	if int(manifest["source_pattern_files"]) != pattern_map.size():
		return COMPACT_MANIFEST + " — source_pattern_files mismatch"
	if int(manifest["compact_bytes"]) != families_bytes + patterns_bytes:
		return COMPACT_MANIFEST + " — compact_bytes mismatch"
	if int(manifest["source_total_bytes"]) != int(manifest["source_family_index_bytes"]) + \
			int(manifest["source_family_bytes"]) + int(manifest["source_pattern_bytes"]):
		return COMPACT_MANIFEST + " — source_total_bytes mismatch"

	var missing: Array[String] = []
	var missing_seen := {}
	for family_v in family_entries:
		if not (family_v is Dictionary):
			return COMPACT_FAMILIES + " — family entry must be a map"
		var family: Dictionary = family_v as Dictionary
		if not (family.get("family", null) is String) or (family.get("family") as String).is_empty():
			return COMPACT_FAMILIES + " — family name missing"
		if not (family.get("output", null) is String) or (family.get("output") as String).is_empty():
			return COMPACT_FAMILIES + " — family output missing"
		if not _compact_nonnegative_int(family.get("pattern_count", null)):
			return COMPACT_FAMILIES + " — invalid family pattern_count"
		if not (family.get("patterns", null) is Array):
			return COMPACT_FAMILIES + " — family patterns must be an array"
		var members: Array = family.get("patterns") as Array
		if int(family["pattern_count"]) != members.size():
			return COMPACT_FAMILIES + " — family pattern_count mismatch"
		for member_v in members:
			if not (member_v is Dictionary):
				return COMPACT_FAMILIES + " — family pattern entry must be a map"
			var member: Dictionary = member_v as Dictionary
			var member_name := _pattern_entry_name(member)
			if member_name.is_empty():
				return COMPACT_FAMILIES + " — family pattern entry has no match/pattern name"
			if not _compact_number(member.get("freq", 1.0)):
				return COMPACT_FAMILIES + " — family pattern freq must be finite"
			if not pattern_map.has(member_name) and not missing_seen.has(member_name):
				missing.append(member_name)
				missing_seen[member_name] = true
	missing.sort()
	var recorded_missing: Array = manifest.get("missing_family_pattern_files") as Array
	if recorded_missing.size() != missing.size():
		return COMPACT_MANIFEST + " — missing_family_pattern_files count mismatch"
	for i in range(missing.size()):
		if recorded_missing[i] != missing[i]:
			return COMPACT_MANIFEST + " — missing_family_pattern_files mismatch"

	for key in pattern_map:
		if not (key is String) or (key as String).is_empty():
			return COMPACT_PATTERNS + " — pattern map key must be a non-empty string"
		var doc_v: Variant = pattern_map[key]
		if not (doc_v is Dictionary):
			return COMPACT_PATTERNS + "#" + str(key) + " — pattern document must be a map"
		var doc: Dictionary = doc_v as Dictionary
		if not (doc.get("name", null) is String):
			return COMPACT_PATTERNS + "#" + str(key) + " — name missing"
		if not _compact_positive_int(doc.get("w", null)) or not _compact_positive_int(doc.get("h", null)):
			return COMPACT_PATTERNS + "#" + str(key) + " — invalid dimensions"
		var w: int = int(doc["w"])
		var h: int = int(doc["h"])
		if not _compact_grid_valid(doc.get("relief_float_grid", null), w * h):
			return COMPACT_PATTERNS + "#" + str(key) + " — invalid relief_float_grid"
		if not (doc.get("flags", null) is Dictionary):
			return COMPACT_PATTERNS + "#" + str(key) + " — flags must be a map"
		var flags: Dictionary = doc.get("flags") as Dictionary
		for flag_name in ["Scale", "Min", "Offset", "TerrainScale"]:
			if flags.has(flag_name) and not _compact_number(flags[flag_name]):
				return COMPACT_PATTERNS + "#" + str(key) + " — non-finite numeric flag " + flag_name
		for flag_name in ["Replace", "ReplaceForWater", "Stand", "Smooth"]:
			if flags.has(flag_name) and not (flags[flag_name] is bool):
				return COMPACT_PATTERNS + "#" + str(key) + " — non-boolean flag " + flag_name
		if not (doc.get("grid_offset", null) is int):
			return COMPACT_PATTERNS + "#" + str(key) + " — grid_offset must be an integer"
		if not (doc.get("grid_layout", null) is String):
			return COMPACT_PATTERNS + "#" + str(key) + " — grid_layout must be a string"
		if doc.has("grid") and not _compact_grid_valid(doc.get("grid"), w * h):
			return COMPACT_PATTERNS + "#" + str(key) + " — invalid canonical grid"
		if doc.has("occupancy_cells") and not _compact_occupancy_valid(doc.get("occupancy_cells"), w, h):
			return COMPACT_PATTERNS + "#" + str(key) + " — invalid occupancy_cells"
	return ""


func _load_compact_pattern_bundle(skipped: Array) -> Dictionary:
	var telemetry := {"files_parsed": 0, "bytes_parsed": 0, "fallback_reason": ""}
	var manifest_bytes: int = 0
	var families_bytes: int = 0
	var before_patterns: int = 0
	var patterns_bytes: int = 0
	var manifest := _read_compact_json(COMPACT_MANIFEST, skipped, telemetry)
	if manifest.is_empty():
		var manifest_reason := str(telemetry["fallback_reason"])
		if manifest_reason.is_empty():
			manifest_reason = COMPACT_MANIFEST + " — empty document"
		return _compact_failure(manifest_reason, skipped, telemetry)
	manifest_bytes = int(telemetry.get("bytes_parsed", 0))
	var families_doc := _read_compact_json(COMPACT_FAMILIES, skipped, telemetry)
	if families_doc.is_empty():
		var families_reason := str(telemetry["fallback_reason"])
		if families_reason.is_empty():
			families_reason = COMPACT_FAMILIES + " — empty document"
		return _compact_failure(families_reason, skipped, telemetry)
	families_bytes = int(telemetry.get("bytes_parsed", 0)) - manifest_bytes
	before_patterns = int(telemetry.get("bytes_parsed", 0))
	var patterns_doc := _read_compact_json(COMPACT_PATTERNS, skipped, telemetry)
	if patterns_doc.is_empty():
		var patterns_reason := str(telemetry["fallback_reason"])
		if patterns_reason.is_empty():
			patterns_reason = COMPACT_PATTERNS + " — empty document"
		return _compact_failure(patterns_reason, skipped, telemetry)
	patterns_bytes = int(telemetry.get("bytes_parsed", 0)) - before_patterns
	var validation_error := _validate_compact_bundle(manifest, families_doc, patterns_doc,
			families_bytes, patterns_bytes)
	if not validation_error.is_empty():
		return _compact_failure(validation_error, skipped, telemetry)
	var missing_files: Array = manifest.get("missing_family_pattern_files") as Array
	for missing_name in missing_files:
		skipped.append("ABSENT " + PATTERN_DIR + str(missing_name) +
				".json [U] — pattern not stamped; family-referenced compact key absent, no substitute invented")
	telemetry["payload_bytes"] = families_bytes + patterns_bytes
	return {
		"families": families_doc.get("families"),
		"patterns": patterns_doc.get("patterns"),
		"manifest": manifest,
		"telemetry": telemetry,
	}


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
# (spec/02 §1; donewgame.inc:16,33-37). GENSEED §2.2 [O]: verbatim donor text is
# `randkey0 := gMap.settings.gen.randkey0; randkey1 := gMap.settings.gen.randkey1`
# (generatemap.inc:141-142, ev_51c638a0…). X21 §4.3: key0 is discarded by
# mod 2^32 — only key1 seeds; key0 is therefore a labelled NO-OP; ALL 11
# SetRandomKey + ALL 3 SetRandomExtKey64 reseeds consume randkey1
# (ev_9defac5a… / ev_661ef2e6… RTTI, key0 discarded ev_661ef2e6…).
# GenerateMapRandKey / Get-Set(Map|GlobalMap)GeneratorRandomKey are RTTI names
# with ZERO static xrefs (ev_3e61f9fa…, §1 xref rows): derivation stays [U] U5/P5.
# Terminating ±1 probe (§2.4.2): fix randkey0, vary randkey1 ±1, dump the D2:190
# mask pick + first three RandomExt floats; terminate on key0-only = bit-identical
# and key1±1 = changed stream. No silent fallback, no invented derivation.
# ---------------------------------------------------------------------------
func _derive_seed(game) -> Dictionary:
	var seed_value: int = 0
	var have_seed := false
	var source := "NONE"
	var cfg = C3ConfigScript.active
	# GEN1TO1 §G.6 [O] donewgame.inc:16,33-37 — donor has TWO independent 32-bit
	# settings. Consume them verbatim when the caller exposes them; the old
	# high/low split of one 32-bit seed is retained only as a labelled [U]
	# fallback (GenerateMapRandKey derivation is still unverified).
	var kw0: Variant = null
	var kw1: Variant = null
	if cfg != null and cfg is Object and (cfg as Object).has_method("num"):
		var a0: Variant = (cfg as Object).call("num", "gameplay.randkey0", -1.0)
		var a1: Variant = (cfg as Object).call("num", "gameplay.randkey1", -1.0)
		if (a0 is int or a0 is float) and int(a0) >= 0:
			kw0 = a0
		if (a1 is int or a1 is float) and int(a1) >= 0:
			kw1 = a1
	for key0_name in ["randkey0", "random_seed0"]:
		var g0: Variant = _prop(game, key0_name)
		if (g0 is int or g0 is float) and int(g0) >= 0:
			kw0 = g0
			break
	for key1_name in ["randkey1", "random_seed1"]:
		var g1: Variant = _prop(game, key1_name)
		if (g1 is int or g1 is float) and int(g1) >= 0:
			kw1 = g1
			break
	if kw0 != null and kw1 != null:
		return {
			"seed": (int(kw0) << 32) | (int(kw1) & U32_MASK),
			"have_seed": true,
			"source": "gameplay.randkey0/randkey1 (donewgame.inc:16,33-37)",
			"randkey0": int(kw0) & U32_MASK,
			"randkey1": int(kw1) & U32_MASK,
			"key0_label": "DONOR high word consumed verbatim [O] — NO-OP mod 2^32 (X21 §4.3)",
			"key1_label": "DONOR low word consumed verbatim [O] — seeds RandomExt",
			"derivation_label": "[O] two independent donor words; GenerateMapRandKey itself [U]",
			"seed_source": "gMap.settings.gen.randkey0/1 (generatemap.inc:141-142, ev_51c638a0…)",
			"derivation_probe": "[U] U5/P5 ±1 probe §2.4.2: fix key0, vary key1 ±1; terminate on key0-only bit-identical / key1-changed stream",
			"reseed_contract": "ALL 11 SetRandomKey + ALL 3 SetRandomExtKey64 consume key1; key0 DISCARDED mod 2^32 (ev_661ef2e6…)",
		}
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
		"seed_source": "gMap.settings.gen.randkey0/1 (generatemap.inc:141-142, ev_51c638a0…)",
		"derivation_probe": "[U] U5/P5 ±1 probe §2.4.2: fix key0, vary key1 ±1; terminate on key0-only bit-identical / key1-changed stream",
		"reseed_contract": "ALL 11 SetRandomKey + ALL 3 SetRandomExtKey64 consume key1; key0 DISCARDED mod 2^32 (ev_661ef2e6…)",
	}


# Map shape: explicit game/capture keys win over resolved defaults. In the live
# capture JSON `gameplay.map_type="land"` is explicit while `terrain_type` is
# only the built-in "mediterranean" default; reading the merged terrain_type
# first silently selected the wrong donor mask family (W03 §2.1).
func _explicit_config_shape(cfg) -> Dictionary:
	var out: Dictionary = {"map_type": "", "terrain_type": "", "source": ""}
	if cfg == null or not (cfg is Object):
		return out
	var src: String = str(_prop(cfg, "source"))
	if src.is_empty() or not FileAccess.file_exists(src):
		return out
	var doc := _read_json(src, [])
	var gp_v: Variant = doc.get("gameplay", {})
	if not (gp_v is Dictionary):
		return out
	var gp: Dictionary = gp_v
	for key in ["map_type", "terrain_type"]:
		var v: Variant = gp.get(key, null)
		if v is String and not str(v).strip_edges().is_empty():
			out[key] = str(v).strip_edges().to_lower()
	out["source"] = src
	return out


func _shape_of(game) -> String:
	_shape_info = {}
	# Explicit per-game values (not the resolved Data.MAP_TYPE alias).
	for key in ["shape", "map_type", "terrain_type", "biome"]:
		var v: Variant = _prop(game, key)
		if v is String and not str(v).strip_edges().is_empty():
			var shape: String = str(v).strip_edges().to_lower()
			_shape_info = {"shape": shape, "source": "game." + key,
				"explicit_map_type": shape if key == "map_type" else "",
				"explicit_terrain_type": shape if key == "terrain_type" else "",
				"conflict": false, "resolution": "explicit game key"}
			return shape
	var cfg = C3ConfigScript.active
	var explicit := _explicit_config_shape(cfg)
	var em: String = str(explicit.get("map_type", ""))
	var et: String = str(explicit.get("terrain_type", ""))
	var conflict: bool = not em.is_empty() and not et.is_empty() and em != et
	# config.gd:535 makes terrain_type canonical when BOTH were explicitly set.
	# When only map_type was explicit, the default terrain_type cannot override it.
	if not et.is_empty() or not em.is_empty():
		var shape: String = et if not et.is_empty() else em
		_shape_info = {"shape": shape, "source": str(explicit.get("source", "")),
			"explicit_map_type": em, "explicit_terrain_type": et,
			"conflict": conflict,
			"resolution": "explicit capture config; terrain_type wins only when explicit" if conflict else "explicit capture config"}
		return shape
	# Resolved aliases are fallbacks, never allowed to beat an explicit capture
	# key. Prefer map_type over the donor-default terrain_type in this fallback.
	for key in ["MAP_TYPE", "TERRAIN_TYPE"]:
		var v: Variant = _prop(game, key)
		if v is String and not str(v).strip_edges().is_empty():
			var shape: String = str(v).strip_edges().to_lower()
			_shape_info = {"shape": shape, "source": "game." + key,
				"explicit_map_type": "", "explicit_terrain_type": "",
				"conflict": false, "resolution": "resolved game alias fallback"}
			return shape
	if cfg != null and cfg is Object and (cfg as Object).has_method("text"):
		for key in ["gameplay.map_type", "gameplay.terrain_type"]:
			var t: Variant = (cfg as Object).call("text", key, "")
			if t is String and not str(t).strip_edges().is_empty():
				var shape: String = str(t).strip_edges().to_lower()
				_shape_info = {"shape": shape, "source": key,
					"explicit_map_type": "", "explicit_terrain_type": "",
					"conflict": false, "resolution": "merged config fallback; map_type preferred"}
				return shape
	_shape_info = {"shape": "", "source": "NONE", "explicit_map_type": em,
		"explicit_terrain_type": et, "conflict": conflict,
		"resolution": "no shape from game/config"}
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
	# Prefer a mask whose native grid equals the caller's grid; otherwise the
	# selected mask is deterministically resampled to the requested w/h below.
	var exact: Array = []
	for c in candidates:
		var m: Dictionary = c["mask"]
		if int(m.get("width", 0)) == w and int(m.get("height", 0)) == h:
			exact.append(c)
	var pool: Array = candidates
	if not exact.is_empty():
		pool = exact
	# P-PLACE-16 (DEC_U_placement §8 P-PLACE-16; GENSEED §5.2.1/§5.3): the donor
	# mask pick is `floor(RandomExt*count)` on the stream inherited from D1:1538.
	# That draw belongs to the GENERATOR at D2:190 (`_enter_inherited_site` +
	# `_active_rng.next_int(mask_count)`), BEFORE the D2:216 ext-reseed; inputs
	# exposes `count` (the donor `count`) only. The old FNV hash pick is REMOVED:
	# no hash/RNG draw is consumed here. Selection is the first entry of the
	# deterministic, sorted, native-grid-preferred pool. `seed` stays in the
	# signature for API stability only — it no longer drives selection.
	# Nearest sampling, the land->nowater2 alias and the conifer gate are unchanged.
	var chosen: Dictionary = (pool[0] as Dictionary)["mask"]
	return {"type": str((pool[0] as Dictionary)["type"]), "mask": chosen,
			"exact_grid": not exact.is_empty(),
			"count": candidates.size(), "pool_size": pool.size(),
			"pick_label": "[U] deterministic sorted asset index 0 — NO hash/RNG draw in inputs; the donor floor(RandomExt*count) draw is the generator's D2:190 on the inherited stream (exact seed [U])"}


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


func _mask_bytes_from_image(img: Image, w: int, h: int) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(w * h)
	for y in range(h):
		for x in range(w):
			var v: int = clampi(int(roundf(img.get_pixel(x, y).r * 255.0)), 0, 255)
			out[y * w + x] = v
	return out


func _resample_mask_image(img: Image, mw: int, mh: int, w: int, h: int,
		skipped: Array) -> Dictionary:
	if w <= 0 or h <= 0:
		return {"bytes": PackedByteArray(), "method": "SKIPPED",
			"label": "invalid requested grid — no mask resampled"}
	if mw == w and mh == h:
		return {"bytes": _mask_bytes_from_image(img, w, h), "method": "NATIVE",
			"label": "native mask grid; no resample"}
	# GEN1TO1 §G.6 [O] D2:409-411/541-542: donor sampler is NEAREST with
	# floor(x/W*srcW), floor(y/H*srcH); no synthetic values. It is now the
	# default. Bilinear stays exclusively as an explicit comparison hook.
	var nearest := PackedByteArray()
	nearest.resize(w * h)
	for y in range(h):
		var sy: int = mini(mh - 1, int(floor(float(y) * float(mh) / float(h))))
		for x in range(w):
			var sx: int = mini(mw - 1, int(floor(float(x) * float(mw) / float(w))))
			nearest[y * w + x] = clampi(int(roundf(img.get_pixel(sx, sy).r * 255.0)), 0, 255)
	if mask_resample_mode != "bilinear":
		return {"bytes": nearest, "method": "NEAREST",
			"label": "[O] donor nearest sampler floor(x/W*srcW), floor(y/H*srcH) (D2:409-411/541-542)"}
	# Explicit comparison-only bilinear path — NEVER claimed as donor parity.
	var resized := img.duplicate()          # never mutate a cached Texture2D image
	resized.resize(w, h, Image.INTERPOLATE_BILINEAR)
	if resized.get_width() == w and resized.get_height() == h:
		return {"bytes": _mask_bytes_from_image(resized, w, h), "method": "BILINEAR",
			"label": "[U] PORT APPROXIMATION — comparison hook only; donor sampler is nearest (E-D2: nearest/bilinear upload byte dump, terminate on zero mismatch)"}
	skipped.append("MASK bilinear resize unavailable — nearest donor sampler used instead (no synthetic values)")
	return {"bytes": nearest, "method": "NEAREST",
		"label": "[O] donor nearest sampler; bilinear comparison hook failed"}


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
	var resampled := _resample_mask_image(img, mw, mh, w, h, skipped)
	var mb: PackedByteArray = resampled["bytes"]
	if mb.size() != w * h:
		skipped.append("MASK resample did not produce requested " + str(w) + "x" + str(h) + " — skipped [U]")
		return {}
	p["mask_b"] = mb                                   # raw gray8 byte v; h=-1.1*v/255
	p["width"] = w                                     # REQUESTED grid; never native mask size
	p["height"] = h
	# GEN1TO1 §A.3/§G.6: candidate count is consumed by I07's D2:190
	# `floor(RandomExt*count)` draw on the inherited stream. Native size drives
	# the D2:329 scaled-vs-equal-size start dedup branch.
	p["mask_count"] = int(sel.get("count", 1))
	p["mask_native_width"] = mw
	p["mask_native_height"] = mh
	var starts: Array = []
	var sv: Variant = m.get("starts", [])
	if sv is Array:
		for s in (sv as Array):
			if s is Array and (s as Array).size() >= 2:
				var nx: float = float((s as Array)[0])
				var ny: float = float((s as Array)[1])
				# Starts stay normalised source coordinates; only the donor-centred
				# conversion uses the requested grid, never the native mask grid.
				starts.append(Vector2(nx * float(w) - float(w) * 0.5,
						ny * float(h) - float(h) * 0.5))
	if not starts.is_empty():
		p["starts"] = starts                           # donor-centred cells, gen.gd:1450
	loaded.append("MASK " + path + " (source " + str(mw) + "x" + str(mh) +
			" -> requested " + str(w) + "x" + str(h) + ", " + str(resampled["method"]) +
			", " + str(starts.size()) + " starts)")
	return {
		"type": str(sel["type"]), "file": path,
		"source_width": mw, "source_height": mh,
		"width": w, "height": h, "starts": starts.size(),
		"exact_grid": bool(sel["exact_grid"]) and str(resampled["method"]) == "NATIVE",
		"resample": str(resampled["method"]),
		"resample_label": str(resampled["label"]),
		"height_formula": "h=-1.1*v/255 (donor generatemap.inc:4-7; p.mask_b carries raw byte v)",
		"mask_count": int(sel.get("count", 1)),
		"mask_pick_label": str(sel.get("pick_label", "")),
		"mask_selection_label": ("[U] PORT APPROX: deterministic sorted asset index 0; NO hash/RNG "
				+ "draw in inputs. The donor D2:190 floor(RandomExt*count) draw is issued by the "
				+ "generator on the inherited D1:1538 stream using p.mask_count "
				+ "(E-I07: fixed-seed draw ledger, terminate on zero mismatch)"),
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
	# I01 emits paths such as:
	# <root>/TileSmoothLists/[*]#1/SmoothTiles/[*]#4/TileNames/[*]#2/Prob
	# The 1-based index is on the wildcard segment AFTER each container name,
	# not on the container segment itself (the old parser never matched it).
	for i in range(parts.size()):
		var seg: String = str(parts[i])
		for j in range(names.size()):
			if seg == names[j] or seg.begins_with(names[j]):
				var index_seg: String = seg
				if seg == names[j] and i + 1 < parts.size():
					index_seg = str(parts[i + 1])
				var hashpos: int = index_seg.find("#")
				if hashpos >= 0:
					var one_based: int = int(index_seg.substr(hashpos + 1))
					if one_based > 0:
						out[j] = one_based - 1
	return out


func _valid_tile_smooth_chains(chains: Array) -> bool:
	for chain_v in chains:
		if not (chain_v is Array):
			return false
		for group_v in (chain_v as Array):
			if not (group_v is Array):
				return false
			for entry_v in (group_v as Array):
				if not (entry_v is Dictionary):
					return false
				var entry: Dictionary = entry_v
				if not (entry.get("name") is String) or not (entry.get("id") is int):
					return false
				if not ((entry.get("prob") is int) or (entry.get("prob") is float)):
					return false
	return true


func _tile_smooth_counts(chains: Array) -> Dictionary:
	var groups: int = 0
	var active_groups: int = 0
	var entries: int = 0
	var empty_chains: int = 0
	for chain_v in chains:
		if not (chain_v is Array):
			continue
		var chain: Array = chain_v
		if chain.is_empty():
			empty_chains += 1
		groups += chain.size()
		for group_v in chain:
			if not (group_v is Array):
				continue
			var group: Array = group_v
			entries += group.size()
			if not group.is_empty():
				active_groups += 1
	return {"chains": chains.size(), "groups": groups,
		"active_groups": active_groups, "entries": entries,
		"empty_chains": empty_chains}


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
				# tilesmooth_scripts.cfg:1-1863 — flat ACTIVE entries carrying a
				# structural_path; rebuild the 22-chain table without inventing
				# commented/inactive rows.
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
	var active_group_count := 0
	var entry_count := 0
	var empty_chain_count := 0
	if have_chains:
		var direct: Array = p["tile_smooth_chains"]
		if not _valid_tile_smooth_chains(direct):
			skipped.append("tile_smooth_chains malformed in constants.json — skipped, no invented table")
			p.erase("tile_smooth_chains")
			have_chains = false
		else:
			var counts := _tile_smooth_counts(direct)
			chain_count = int(counts["chains"])
			group_count = int(counts["groups"])
			active_group_count = int(counts["active_groups"])
			entry_count = int(counts["entries"])
			empty_chain_count = int(counts["empty_chains"])
			loaded.append("tile_smooth_chains " + str(chain_count) + " chains / " +
					str(active_group_count) + " active groups / " + str(entry_count) +
					" entries from constants.json canonical table")
	if not have_chains and not stat_names.is_empty():
		var complete: bool = true
		for ck in stat_names.keys():
			if not stat_probs.has(ck) or not names_to_id.has(str(stat_names[ck])):
				complete = false
				break
		if not complete:
			skipped.append("tile_smooth_chains incomplete in constants.json (missing Prob or tile id) — tile smoothing stays skipped, no invented table")
		else:
			var chains: Array = []
			var keys: Array = stat_names.keys()
			keys.sort()                                # zero-padded = donor order
			for ck in keys:
				var segs: Array = str(ck).split("_")
				var li: int = int(segs[0])
				var gi: int = int(segs[1])
				while chains.size() <= li:
					chains.append([])
				var groups: Array = chains[li]
				while groups.size() <= gi:
					groups.append([])                 # preserve inactive group positions
				var entries: Array = groups[gi]
				var tname: String = str(stat_names[ck])
				# Active entries are compacted in donor order; inactive/commented
				# entries are absent from constants.json and are never fabricated.
				entries.append({"name": tname, "prob": float(stat_probs[ck]),
					"id": int(names_to_id[tname])})
			# I01 emits active literals only, so empty donor chains 11 and 22
			# have no rows. Preserve the observed 22-slot census without inventing
			# any group, entry, probability or tile id (spec/09 §1; X54 row 9).
			while chains.size() < TILE_SMOOTH_CHAIN_COUNT:
				chains.append([])
			p["tile_smooth_chains"] = chains
			var counts := _tile_smooth_counts(chains)
			chain_count = int(counts["chains"])
			group_count = int(counts["groups"])
			active_group_count = int(counts["active_groups"])
			entry_count = int(counts["entries"])
			empty_chain_count = int(counts["empty_chains"])
			loaded.append("tile_smooth_chains " + str(chain_count) + " chains / " +
					str(active_group_count) + " active groups / " + str(entry_count) +
					" active entries from tilesmooth_scripts.cfg:1-1863; empty chain slots preserved")
	elif not have_chains and stat_names.is_empty():
		skipped.append("tile_smooth_chains not emitted [U] — tile smoothing stays skipped, no invented table")

	return {
		"generator_version": int(p.get("generator_version", -1)),
		"mapsize_present": have_mapsize,
		"relieftype_present": have_relief,
		"minesdensity_present": have_mines,
		"tile_ids": names_to_id.size(),
		"chains": chain_count, "groups": group_count,
		"active_groups": active_group_count, "entries": entry_count,
		"empty_chains": empty_chain_count,
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
	if name.find("forest") < 0:
		return false
	# GEN1TO1 §G.6 [O] D1:5-6: foreststype is hard-forced 0 (conifer only).
	# Leaf/mixed families are gated behind the explicit opt-in; no family is
	# renamed or synthesised, and TARGET_FAMILIES entries are never dropped.
	if not include_leaf_forests:
		var conifer: bool = (name.find("pine") >= 0 or name.find("spruce") >= 0
				or name.find("fir") >= 0 or name.find("conifer") >= 0
				or name.find("stoneforest") >= 0)
		if not conifer:
			_family_gate_notes.append("GATED leaf/mixed family '" + name
					+ "' — foreststype=0 conifer-only (D1:5-6)")
			return false
	return true


func _target_pattern(name: String) -> bool:
	if EXACT_PATTERNS.has(name):
		return true
	for prefix in ["frs_", "frt_", "d_frt_", "b_frt_", "d_stn_", "d_str_", "b_str_", "str_new_", "d_plt", "hil", "g_hil", "plt", "k_ravine", "mng", "mni", "mnc"]:
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
	return _decode_pattern_doc(name, doc, path, skipped)


func _decode_pattern_doc(name: String, doc: Dictionary, source: String, skipped: Array) -> Dictionary:
	if doc.is_empty():
		return {}
	var w: int = int(doc.get("w", 0))
	var hh: int = int(doc.get("h", 0))
	var gv: Variant = doc.get("relief_float_grid", null)
	if w <= 0 or hh <= 0 or not (gv is Array):
		skipped.append("NO_GRID " + source + " [U] — no synthetic grid")
		return {}
	var src: Array = gv
	if src.size() != w * hh:
		skipped.append("GRID_SIZE " + source + " [U] — expected " + str(w * hh) +
				" relief_float_grid values, got " + str(src.size()) + "; no zero padding")
		return {}
	var grid := PackedFloat32Array()
	grid.resize(w * hh)
	for i in range(w * hh):
		grid[i] = float(src[i])
	var fv: Variant = doc.get("flags", {})
	var flags: Dictionary = fv if fv is Dictionary else {}
	var out: Dictionary = {
		"name": str(doc.get("name", name)),
		"w": w, "h": hh,
		"relief_float_grid": grid,                       # I02 primary key; corrected F01 G
		"grid_source_key": "relief_float_grid",
		"scale": float(flags.get("Scale", 1.0)),        # pattern.lib HeightFieldScale +0x48
		"min": float(flags.get("Min", 0.0)),            # +0x5c, PIVOT (never a clamp)
		"offset": float(flags.get("Offset", 0.0)),      # +0x64
		"terrain_scale": float(flags.get("TerrainScale", 1.0)),  # +0x68
		"replace": bool(flags.get("Replace", false)),              # +0x3a
		"replace_for_water": bool(flags.get("ReplaceForWater", false)),  # +0x3b
		"height_field_stand": bool(flags.get("Stand", false)),
		"height_field_smooth": bool(flags.get("Smooth", false)),
		"grid_offset": int(doc.get("grid_offset", 0)),
		"grid_layout": "h x w row-major f32[w*h]; G=8+(w-1)(h-1) [O] F01 §4.4",
		"label": "[O] DECODED grid+flags; row sign / global clamp [U]; no parity claim",
	}
	# Optional canonical override: never alias the donor-decoded key to `grid`.
	var canonical_v: Variant = doc.get("grid", null)
	if canonical_v is Array:
		var canonical_src: Array = canonical_v
		if canonical_src.size() != w * hh:
			skipped.append("CANONICAL_GRID_SIZE " + source + " [U] — optional grid override rejected; no synthetic grid")
			return {}
		var canonical := PackedFloat32Array()
		canonical.resize(w * hh)
		for i in range(w * hh):
			canonical[i] = float(canonical_src[i])
		out["grid"] = canonical
	var occ_v: Variant = doc.get("occupancy_cells", null)
	var lattice_n: int = (w - 1) * (hh - 1)
	if occ_v is Array and ((occ_v as Array).size() == lattice_n or (occ_v as Array).size() == w * hh):
		var occ := PackedByteArray()
		occ.resize((occ_v as Array).size())
		for i in range(occ.size()):
			occ[i] = int((occ_v as Array)[i]) & 0xFF
		out["occupancy"] = occ
		out["occupancy_label"] = "[O] raw 0/1 mask; F01 lattice (h-1)x(w-1); PatternMaskStand/ReverceStand [U], no inverse/expansion invented"
	else:
		out["occupancy_label"] = "[U] occupancy_cells absent or wrong size — stand rejected, no invented footprint"
	return out


func _apply_patterns(p: Dictionary, seed: int, skipped: Array, loaded: Array) -> Dictionary:
	var families: Dictionary = {}
	var patterns: Dictionary = {}
	var compact := _load_compact_pattern_bundle(skipped)
	var use_compact: bool = compact.has("patterns")
	var compact_telemetry: Dictionary = compact.get("telemetry", {}) as Dictionary
	var compact_manifest: Dictionary = compact.get("manifest", {}) as Dictionary
	var compact_families: Array = compact.get("families", []) as Array
	var compact_patterns: Dictionary = compact.get("patterns", {}) as Dictionary
	var family_lookup := {}
	if use_compact:
		for family_v in compact_families:
			var family: Dictionary = family_v as Dictionary
			family_lookup[str(family["family"])] = family

	# The compact bundle is preferred. The original file path remains byte-for-byte
	# selectable below and is labelled in telemetry whenever bundle loading fails.
	var fi := {}
	if not use_compact:
		fi = _read_json(FAMILY_INDEX, skipped)
	var fam_names: Array[String] = []
	if use_compact:
		for fv in compact_families:
			if fv is Dictionary and (fv as Dictionary).has("family"):
				fam_names.append(str((fv as Dictionary)["family"]))
	elif not fi.is_empty():
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
		var fd: Dictionary
		var family_source: String = fp
		if use_compact:
			if not family_lookup.has(fn):
				skipped.append("ABSENT " + fp + " [U] — family not supplied")
				continue
			fd = family_lookup[fn] as Dictionary
			family_source = COMPACT_FAMILIES + "#" + fn
		else:
			if not FileAccess.file_exists(fp):
				skipped.append("ABSENT " + fp + " [U] — family not supplied")
				continue
			fd = _read_json(fp, skipped)
			if fd.is_empty():
				continue
		var members: Array = []
		var pv: Variant = fd.get("patterns", [])
		if pv is Array:
			for mv in (pv as Array):
				if not (mv is Dictionary):
					continue
				var md: Dictionary = mv as Dictionary
				var nm: String = _pattern_entry_name(md)
				if nm.is_empty():
					continue
				members.append({"name": nm, "freq": float(md.get("freq", 1.0))})
				# Every member of a selected donor family is a valid placement
				# candidate. The old prefix filter silently excluded donor families
				# such as g_mnt_*, f_plt_*, big_hill_* and str_new_*.
				if not EXACT_PATTERNS.has(nm) and not fam_pattern_names.has(nm):
					fam_pattern_names.append(nm)
		families[fn] = members
		loaded.append("FAMILY " + family_source + " (" + str(members.size()) + " name/freq pairs)")
	if use_compact:
		loaded.append("COMPACT_PATTERNS " + COMPACT_MANIFEST + " + " + COMPACT_FAMILIES +
				" + " + COMPACT_PATTERNS + " (" + str(compact_families.size()) +
				" family entries / " + str(compact_patterns.size()) + " pattern docs)")
	elif not fi.is_empty():
		skipped.append("NOT_LOADED " + ASSET_ROOT + "lib/pattern_lib_index.json [U] — 55.8 MB metadata index, family_index.json used instead")

	# Exact relief/mine patterns first, then a seed-rotated bounded sample of
	# the forest/stone/plateau names from those families (cap 64, no synthesis).
	var ordered: Array[String] = []
	for n in EXACT_PATTERNS:
		if use_compact:
			if compact_patterns.has(n):
				ordered.append(n)
			else:
				skipped.append("ABSENT " + PATTERN_DIR + n + ".json [U] — pattern not stamped")
		else:
			if FileAccess.file_exists(PATTERN_DIR + n + ".json"):
				ordered.append(n)
			else:
				skipped.append("ABSENT " + PATTERN_DIR + n + ".json [U] — pattern not stamped")
	fam_pattern_names.sort()
	var pool: Array[String] = []
	for n in fam_pattern_names:
		if use_compact:
			if compact_patterns.has(n):
				pool.append(n)
			else:
				# Missing family references were labelled once from the validated
				# manifest. Exact-key lookup never aliases K_ravine_2 to k_ravine_2.
				continue
		else:
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
		var decoded: Dictionary
		if use_compact:
			var pattern_source: String = COMPACT_PATTERNS + "#" + n
			decoded = _decode_pattern_doc(n, compact_patterns[n] as Dictionary, pattern_source, skipped)
			if not decoded.is_empty():
				loaded.append("PATTERN " + pattern_source)
		else:
			decoded = _decode_pattern(n, skipped)
			if not decoded.is_empty():
				loaded.append("PATTERN " + PATTERN_DIR + n + ".json")
		if not decoded.is_empty():
			patterns[n] = decoded
	p["patterns"] = patterns
	p["families"] = families
	var files_parsed: int = int(compact_telemetry.get("files_parsed", 0))
	var bytes_parsed: int = int(compact_telemetry.get("bytes_parsed", 0))
	var missing_files: Array = compact_manifest.get("missing_family_pattern_files", []) as Array
	return {
		"patterns_loaded": patterns.size(),
		"families_loaded": families.size(),
		"cap": MAX_PATTERNS,
		"source": "compact" if use_compact else "file",
		"compact_source_used": use_compact,
		"files_parsed": files_parsed,
		"bytes_parsed": bytes_parsed,
		"compact_files_parsed": files_parsed,
		"compact_bytes_parsed": bytes_parsed,
		"compact_payload_files": int(compact_manifest.get("compact_files", 0)),
		"compact_payload_bytes": int(compact_telemetry.get("payload_bytes", 0)),
		"compact_family_count": int(compact_manifest.get("compact_family_count", 0)),
		"compact_pattern_count": int(compact_manifest.get("compact_pattern_count", 0)),
		"source_corpus_bytes": int(compact_manifest.get("source_total_bytes", 0)),
		"source_family_index_sha256": str(compact_manifest.get("source_family_index_sha256", "")),
		"missing_family_pattern_files": missing_files.duplicate(true),
		"fallback_reason": str(compact_telemetry.get("fallback_reason", "")),
		"parse_scope": "compact bundle" if use_compact else "compact bundle attempt; fallback file reads not counted",
		# Explicit proof that the 55 MB family-index and 29 MB family files were
		# never opened while the validated compact bundle was in use. Diagnostics
		# only: these counters never feed selection, rotation or any RNG draw.
		"source_family_index_parsed": not use_compact,
		"source_family_files_parsed": 0 if use_compact else families.size(),
		"source_pattern_files_parsed": 0 if use_compact else patterns.size(),
		"cite": "generator.cfg:67-154; pattern.lib:549563-549575; cossacks.exe:0x755f30; F01 §4.4",
	}


# ---------------------------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------------------------

## Build I07's `p` Dictionary (terrain_donor_gen.gd:414-437) from derived
## assets. `game` is read-only; w/h are the caller's requested grid. A native-
## size mask is preferred, otherwise it is deterministically resampled to w/h.
## Missing assets are labelled skips, never inventions.
func build(game, w: int, h: int) -> Dictionary:
	var skipped: Array = []
	var loaded: Array = []
	_family_gate_notes.clear()
	var p: Dictionary = {}
	var seed_info := _derive_seed(game)
	var seed: int = int(seed_info["seed"])
	if bool(seed_info["have_seed"]):
		p["randkey0"] = int(seed_info["randkey0"])   # high word — NO-OP per X21 §4.3
		p["randkey1"] = int(seed_info["randkey1"])   # low word — seeds per spec/02 §2
		loaded.append("seed from " + str(seed_info["source"]))
	else:
		skipped.append("no seed in config/game — randkey0/1 omitted, no invented seed [U]")
	var raw_shape: String = _shape_of(game)
	# GEN1TO1 §G.6 [O] generator.cfg:5-6: live Land path is nowater2; `land` is
	# commented out. Canonicalise only that alias before mask selection.
	var shape: String = str(SHAPE_ALIASES.get(raw_shape, raw_shape))
	if shape != raw_shape:
		loaded.append("shape alias " + raw_shape + " -> " + shape + " (generator.cfg:5-6)")
	var mask_info := _apply_mask(p, seed, shape, w, h, skipped, loaded)
	var const_info := _apply_constants(p, skipped, loaded)
	var pat_info := _apply_patterns(p, seed, skipped, loaded)
	p["visual_parity_claim"] = false
	# The donor LoadTextureTerrainFromBitmap routine is fully commented source.
	# Keep its exact implementation available for diagnostics, but never enable
	# editor/test tile art in normal generation without an explicit opt-in.
	var cfg = C3ConfigScript.active
	p["detail_bitmap_enabled"] = bool(cfg.flag("features.terrain.detail_bitmap", false)) if cfg != null else false
	var unverified: Array[String] = [
		"forest density from mask G: [U] G=0 on all shipped vanilla non-start pixels; no density invented (spec/03 §4; mask_index.json:76-77)",
		"GenerateMapRandKey: [U] U5/P5 — RTTI names only, 0 static xrefs (ev_3e61f9fa…); ±1 probe §2.4.2; no mix64 per-stage derivation (spec/02 §5); no silent fallback",
		"stamp row sign / global setter clamp / x87 precision: [U] spec/04 §6",
		"tile_smooth pass count 6 (globalparams.cfg:9) preserved as donor contradiction; script uses 3 (smoothtiles.inc:237)",
		"U2: native SmoothTerrain(x,-y,False,3) bsmooth kernel unrecovered; I07 hook stays NULL/SKIP",
		"U4: generation-time Delphi LCG state unknown — ALGORITHM [O] sub_403a0c state=(state*0x8088405+1) mod 2^32 out=state>>>24; seeder sub_4033b8 (QPC-low else TickCount, ev_78bcf9c8…) has only 3 non-generation callers; I07 image state 0 is a labelled placeholder, NOT an invented per-map seed; breakpoint probe §2.4.1",
		"U7/P1: minx/miny numeric pair unrecovered — PRODUCER _misc_GetMapLeftTopPos IS [O] (generatemap.inc:218-228, ev_b7759b44…); I07 hook stays NULL, no bounds guessed; §4 probe",
		"U8: fa/broad absent in shipped 24-bit TGAs; road tile branch D4:622-636 omitted",
		"U13: water runtime plane Y / WaterFieldAdd class binding unknown; I07 records exact tx/tz/bx/bz only",
		"U14: steep/cliff collision tag numeric value unknown; I07 leaves tag clear and labels steep cells",
		"U16: no donor GPU A/B frame — visual parity UNVERIFIED",
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
			"seed_source": str(seed_info.get("seed_source", "[U] not supplied")),
			"derivation_probe": str(seed_info.get("derivation_probe", "[U] ±1 probe §2.4.2")),
			"reseed_contract": str(seed_info.get("reseed_contract", "11+3 reseeds consume key1; key0 DISCARDED")),
		},
		"shape": shape,
		"raw_shape": raw_shape,
		"shape_alias": ("land -> nowater2 (generator.cfg:5-6)" if shape != raw_shape else "none"),
		"shape_resolution": _shape_info.duplicate(true),
		"mask": mask_info,
		"constants": const_info,
		"patterns": pat_info,
		"loaded": loaded,
		"skipped": skipped,
		"family_gate_notes": _family_gate_notes.duplicate(),
		"mask_resample_mode": mask_resample_mode,
		"include_leaf_forests": include_leaf_forests,
		"unverified": unverified,
		"donor_citations": [
			"generatemap.inc:4-7 (h=-1.1*B/255)",
			"generatemap.inc:440-443,486-490 (white starts; B class)",
			"donewgame.inc:16,33-37 (randkey0/1 high/low words)",
			"generatemap.inc:141-142 (gMap.settings.gen.randkey0/1, ev_51c638a0…)",
			"RTTI ev_9defac5a… SetRandomKey / ev_661ef2e6… SetRandomExtKey64 (key0 discarded) / ev_3e61f9fa… GenerateMapRandKey (0 xrefs)",
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
