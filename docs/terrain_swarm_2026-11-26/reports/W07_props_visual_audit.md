---
id: W07
ticket: "TERRAIN-VISUAL-WAVE-2026-11-26 / W07 — donor props visual audit"
agent: "W07 (worker subagent, donor-terrain VISUAL WAVE; reports to COORD)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/W07_props_visual_audit.md
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Read-only source/JSON/image inspection and bounded Python probes. No .gd/.json/.shader/asset/config/test/app edit; no Godot process, runner job, gate or capture. Exactly one repo file written: this report."
parity_guard: "No donor GPU A/B frame exists. Every runtime consequence below is a static trace or inference, not an observed engine result. NO DONOR PARITY CLAIM."
subject_sha256: "terrain_donor_props.gd = 3a451f586d05ec22d8feb76578bae6b4cf9f4454b8b15052bd9b3fd8f901e723"
capture: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\v42\\cap_donor_240c.png"
capture_sha256: 27a2952ca0b4177e3338d39e558dab6684510c2b80b5653f6ea53b5807fe3ac6
---

# W07 — why `cap_donor_240c.png` has legacy black silhouettes and no donor props

## 0. Executive verdict

| # | Mandated question | Verdict | Decisive current evidence |
|---:|---|---|---|
| 1 | Does `_try_feed` walk `pattern_lib.sections[].blocks[].records[]`, unwrap `BaseName.value`, and key by `section.name`? | **FAIL** | `variant3d/scripts/terrain_donor_props.gd:584-617` scans only top-level keys. There is no `pattern_lib`/`sections`/`blocks` walker. `_normalize_record` reads `BaseName` as a string at `:674`; the JSON value is a wrapper dictionary. `_records` is keyed by the top-level key at `:616`, currently the literal `generator_families`. |
| 2 | Does `_collect_stamp` receive dictionary stamps with pattern names? | **FAIL on the live path** | It rejects every non-Dictionary at `terrain_donor_props.gd:627-631`. The composer passes `game.pattern_stamps` unchanged at `terrain_donor_world.gd:268-272`; those elements are `C3PatternGen.Stamp` **Objects** (`pattern_gen.gd:66-73,200-208,356-365,549-557`), assigned by `game.gd:748`. I07 does not produce `data.meta["pattern_stamps"]`. |
| 3 | Are `terrainmesh1..4` placed? Are mine/stone/forest records present? | **I09 placement: FAIL. Data/assets: PASS.** | I09 cannot reach a record (§1) or accept a live stamp (§2). Separately, the 240² capture's effective `hills` setting yields `needed = 0` mountain stamps (`pattern_gen.gd:31,565-589`), so the legacy Z08 relief layer also has no `g_mnt_*` stamp to consume. The canonical index nevertheless contains 112 `terrainmesh*` records, 27 mine records, 1,164 stone-bearing records and 17,403 tree-bearing records; all four relief OBJ/PNG pairs exist. |
| 4 | Why are trees/units/buildings black: lighting/material or missing albedo? | **Lighting/material path, not missing albedo art.** | The donor backend never installs the legacy `WorldEnvironment` + `DirectionalLight3D` rig (`world3d_terrain.gd:1114-1166`); `main.tscn` contains only `Main`, and neither `terrain_donor_world.gd` nor `terrain_donor_mesh.gd` creates a replacement. Legacy entities use shaded `StandardMaterial3D` (`world3d_entities.gd:644-662`) or a spatial tint shader without `unshaded` (`:105-106`), while donor terrain is explicitly `unshaded` (`terrain_donor_shader.gdshader:47-50`). Tree/unit/mine albedo PNGs exist, are non-black, have import sidecars, and are bound by `_default_material`. |
| 5 | What consumer fixes are required? | **FAIL today; patch sketch in §7.** | Add the canonical nested Objects walker; stop accepting `generator_families` as records; accept `Stamp` Objects or convert them to dictionaries; unwrap `BaseName.value`; preserve full `Position` and `Scaling`; restore the scene lighting/material path; make provenance and `_props_applied` depend on `props_total > 0`; prevent duplicate legacy/I09 relief consumers. |

**Bottom line [D]/[I].** The capture is consistent with three independent facts:

1. **H/T channels are alive:** the donor height mesh and tile shader produce the visible stepped/terraced ground.
2. **P channel is dead:** I09 rejects the live stamp type and never reads the nested Objects records, so donor props are not instanced.
3. **Legacy entity materials receive no scene light:** trees, units and buildings still render, but without the donor-backend lighting rig their shaded materials collapse to black silhouettes.

No runtime telemetry was captured with the PNG. `props_total == 0` is therefore a deterministic static prediction, not an observed engine counter.

## 1. Item 1 — `_try_feed` is still the wrong shape reader

### 1.1 Exact current code

`variant3d/scripts/terrain_donor_props.gd:584-597` only considers top-level maps/arrays:

```gdscript
	# Z08-style `props` map is preferred; other I03 shapes are accepted too.
	for key in ["props", "objects", "Objects", "records", "by_pattern"]:
		var v: Variant = root.get(key, null)
		if v is Dictionary:
			source_map = v as Dictionary
			break
	if source_map.is_empty():
		for key in root.keys():
			if key in ["version", "source", "source_sha256", "selection", "labels",
					"derived_stats", "families", "fields", "stats", "family_index",
					"pattern_index", "note", "donor_units"]:
				continue
			if root[key] is Array:
				source_map[str(key)] = true
```

The sole write into `_records` is `terrain_donor_props.gd:615-617`:

```gdscript
			if not recs.is_empty():
				_records[str(name)] = recs
				found += recs.size()
```

There is no reference to `pattern_lib`, `sections`, `blocks`, `block == "Objects"`, or `BaseName.value` anywhere in the function. A dedicated grep found only the stale explanatory comment at `:41` and the feed path at `:59`.

The canonical file's top-level keys are:

`description`, `family_count`, `generator_families`, `heightfield_census`, `join_summary`, `labels`, `line_byte_offsets`, `object_census`, `pair_count`, `pattern_lib`, `schema`, `source`, `source_sha256`, `unverified_fields`, `visual_parity_claim`.

There is no top-level `props`/`objects`/`Objects`/`records`/`by_pattern` map. `generator_families` is an Array and is not in the skip list, so the current code sets `source_map["generator_families"] = true` (`:596-597`), reads that same top-level array through the `arr == true` branch (`:608-614`), and stores the 64 family metadata dictionaries under `_records["generator_families"]` (`:616`). `found` becomes 64 and `_try_feed` returns true (`:618-623`).

### 1.2 `BaseName.value` is not unwrapped

A canonical record has this shape (`pattern_lib_index.json:1123133-1123168`):

```json
"BaseName": { "label": "OBSERVED", "line": 713844,
              "literal": "minegold", "value": "minegold" },
"Position": { "W": 1, "X": -2.98023223876953e-08, "Y": 0, "Z": -0.25 },
"Scaling": { "W": 0, "X": 0.315200001001358,
             "Y": 0.315200001001358, "Z": 0.315200001001358 },
"Up": { "W": 0, "X": 1, "Y": 0, "Z": 0 }
```

But `_normalize_record` does this at `terrain_donor_props.gd:674`:

```gdscript
	var base: String = _s(p_raw, "base", _s(p_raw, "BaseName", _s(p_raw, "base_name", "")))
```

`_s` calls `str(v)` (`:988-993`). Passing the wrapper dictionary would produce a string representation of the whole dictionary, not `minegold`; `_sid_for_base` would then fail and increment `skipped_unknown_sid` (`:693-702`). **Verdict: FAIL.**

`Position`/`Scaling`/`Up` dictionaries are otherwise compatible with `_vec3`, which reads `X/Y/Z` at `terrain_donor_props.gd:1002-1006`. The missing conversion is specifically the `BaseName` wrapper, plus the downstream loss of full scaling and local Y discussed in §6.

### 1.3 Canonical data probe — the records exist

Bounded full parse of `variant3d/assets/terrain_new/lib/pattern_lib_index.json` (55,784,815 B; SHA-256 `a9fff8a1b7f5d35ce5697b1156be06247b58441203c2dd988f870849c3d91581`) found:

| Metric | Observed value |
|---|---:|
| `pattern_lib.sections` | 680 |
| `blocks[]` entries with `block == "Objects"` | 668 |
| Nested Objects records | 39,783 |
| Records with `BaseName` wrapper containing `value` | 39,783 |
| Records with finite numeric `Position.X/Y/Z` | 39,783 |
| Records with finite numeric `Scaling.X/Y/Z` | 39,783 |
| Records with finite numeric `Up.X/Y/Z` | 39,783 |
| Records with a zero scale component | 0 |

Selected parsed sections:

| Section | Objects records | Relevant contents |
|---|---:|---|
| `g_mnt_1` | 99 | 5 `terrainmesh*`; 75 tree-bearing records |
| `mng_1` | 11 | includes `minegold` |
| `mni_1` | 14 | includes `mineiron` |
| `mnc_1` | 13 | includes `minecoal` |
| `g_frt_big_1` | 167 | 116 tree-bearing records |
| `d_stn_1` | 34 | 16 stone-bearing records |
| `str_new_1` | 45 | stone/tree/understory records |

Canonical class census over all 39,783 records:

- **112** `terrainmesh*` records: `terrainmesh1` 14, `terrainmesh2` 21, `terrainmesh3` 29, `terrainmesh4` 25, plus 23 desert variants.
- **27** mine records: 18 standard `minegold/mineiron/minecoal` and 9 desert `mine*golds/mine*irons/mine*coals`.
- **17,403** tree-bearing records across 407 sections.
- **1,164** stone-bearing records across 192 sections.

Concrete index evidence:

- `g_mnt_1` section name: `pattern_lib_index.json:539598`; Objects block: `:539616`; first `terrainmesh4`: `:536800-536837` with Position and Scaling literals.
- `mng_1` section name: `:1122871`; Objects block: `:1122889`; `minegold`: `:1123133-1123168`.
- `mni_1` section name: `:1126651`; `mineiron`: `:1126793-1126828`.
- `mnc_1` section name: `:1129991`; `minecoal`: `:1130053-1130088`.
- `g_frt_big_1` section name: `:521078`; Objects block: `:521096`.
- `d_stn_1` section name: `:338718`; Objects block: `:338736`.

**Conclusion [O]/[D].** The blocker is entirely consumer-side. The donor-derived records and converted relief assets are present; I09 does not read them.

## 2. Item 2 — live stamps are Objects, not dictionaries

### 2.1 Current rejection

`terrain_donor_props.gd:626-638`:

```gdscript
func _collect_stamp(p_raw, p_out: Array[Dictionary], p_stats: Dictionary) -> void:
	if not (p_raw is Dictionary):
		var c0: Dictionary = p_stats["counts"]
		c0["skipped_non_dictionary_stamp"] = int(c0.get("skipped_non_dictionary_stamp", 0)) + 1
		p_stats["counts"] = c0
		return
	var counts: Dictionary = p_stats["counts"]
	var name: String = _s(p_raw, "name", _s(p_raw, "pattern", _s(p_raw, "pattern_name", "")))
```

### 2.2 Actual source

`variant3d/scripts/pattern_gen.gd:66-73` defines:

```gdscript
class Stamp:
	var family: String = ""
	var name: String = ""
	var kind: String = ""
	var res: String = ""
	var x: int = 0
	var y: int = 0
	var cells: Array[Vector2i] = []
```

Stamps are created with `Stamp.new()` and appended as Objects at:

- `pattern_gen.gd:200-208` — forest/stone/hill/decor;
- `pattern_gen.gd:356-365` — mines;
- `pattern_gen.gd:549-557` — relief.

`game.gd:748` assigns the array directly:

```gdscript
	pattern_stamps = result.get("stamps", [])
```

The donor composer reads that same property and passes it directly to I09 (`terrain_donor_world.gd:268-272`):

```gdscript
			var stamps: Array = []
			var stamps_v: Variant = _prop(game, "pattern_stamps")
			if stamps_v is Array:
				stamps = stamps_v as Array
			var pres: Variant = ptarget.call("build", _data, stamps, {"terrain": _mesh})
```

There is no Object→Dictionary conversion in `game.gd`, `terrain_donor_world.gd`, or `terrain_donor_props.gd`.

### 2.3 I07 `data.meta["pattern_stamps"]` is not the live source

The fallback in `terrain_donor_props.gd:233-240` only runs when `build()` received an empty stamp array:

```gdscript
	var stamp_list: Array = _stamps
	if stamp_list.is_empty() and _container != null:
		var cmeta: Variant = _container.get("meta")
		if cmeta is Dictionary and (cmeta as Dictionary).has("pattern_stamps"):
			var sv: Variant = (cmeta as Dictionary)["pattern_stamps"]
			if sv is Array:
				stamp_list = sv as Array
```

A dedicated grep found no producer for that key. `C3TerrainData.configure_grid()` initialises `meta` without it (`terrain_donor_data.gd:203-217`); `from_live_object()` copies terrain arrays and sets only handoff/side metadata (`:411-452`); I07 writes `generator_trace`, water/collision/scan/finalize metadata (`terrain_donor_gen.gd:513-522,1053-1056,1176-1180,2162-2165,2195-2198`) but never `pattern_stamps`.

**Answer [O].** `_collect_stamp` does **not** receive dictionary stamps on the capture path. It receives `C3PatternGen.Stamp` Objects from `game.pattern_stamps`. The I07 `data.meta["pattern_stamps"]` route is a stale comment/fallback, not the current producer.

### 2.4 Static live-path consequence

Assuming the normal non-empty legacy stamp array, the current trace is:

- `counts.stamps_seen = N`;
- `counts.skipped_non_dictionary_stamp = N`;
- `counts.matched_stamps = 0`;
- `_records` contains only `generator_families` metadata;
- `counts.props_total = 0`;
- `feed.label` can still say `DONOR LITERALS (I03 decoded feed)` because `_fallback_used == false` (`terrain_donor_props.gd:272-277`).

This is more specific than V106's dictionary-stamp trace: on the actual composer path, execution fails at the type gate before the pattern-name lookup. Runtime counters remain **[U]** because no Godot job was run.

## 3. Item 3 — relief placement, mines, stone, forests and fields

### 3.1 `terrainmesh1..4`: records and assets exist, but this capture has no mountain stamp to consume

The four relief assets are present and mapped in `variant3d/assets/models/manifest.json`:

| SID | OBJ | Albedo |
|---|---|---|
| `terrainmesh1` | `assets/models/obj/shared/terrain/terrainmesh1.obj` | `assets/models/tex/shared/terrain/terrainmesh1.png` |
| `terrainmesh2` | `.../terrainmesh2.obj` | `.../terrainmesh2.png` |
| `terrainmesh3` | `.../terrainmesh3.obj` | `.../terrainmesh3.png` |
| `terrainmesh4` | `.../terrainmesh4.obj` | `.../terrainmesh4.png` |

The canonical index has the 112 records listed in §1.3. The legacy Z08 table also has 112 records / 30 sections, including 22 renderable green-map records across `g_mnt_1..7` (`variant3d/assets/terrain/mountain_props.json`; X16 `:79-86`, X25 `:172-199`).

However, the capture config does not set `gameplay.relief`. The current config default is `hills` (`config.gd:538`), and the default donor relief id `low_mountains` also maps to `hills` (`config.gd:578,598-600`; `data.gd:363-369`). For `hills`, `pattern_gen.gd:31` sets `mnt = 0.000002`. At 240²:

- `size_mod = 640 / 240 = 2.6666667` (`pattern_gen.gd:562-565`);
- mountain frequency after modifier = `0.000002 * 2.6666667 = 0.0000053333`;
- `W*H*freq = 57600 * 0.0000053333 = 0.3072`;
- `floor(0.3072) = 0`, fallback `round(0.3072) = 0`, so `needed <= 0` and no mountain stamp is attempted (`pattern_gen.gd:579-589`).

For comparison, the same derivation gives 19 hill stamps and 3 plateau stamps. **Expected `g_mnt_*` stamp count for this capture: zero [D].**

Consequences:

- **I09:** no `terrainmesh*` can be placed because its feed and stamp gates already fail.
- **Legacy Z08:** `world3d_relief.gd:149-158` can accept Object stamps through `_g`, but only stamps whose names exist in `mountain_props.json` match. With no expected `g_mnt_*` stamp, it also has no relief record to place.
- A future mountain capture must use an explicit owner-approved mountain relief setting. At 240² with `mountains`, the same code derives 18 mountain stamps; this report does not change the config or run that capture.

The visible terraced surface in `cap_donor_240c.png` is therefore **H-channel height relief**, not evidence that P-channel `terrainmesh*` props are active.

### 3.2 Mines, stone and forests are present in the data

The canonical index contains the records counted in §1.3. The legacy pattern source also contains the corresponding stamp names and families (`variant3d/assets/terrain/patterns/donor_patterns.json`; bounded probe confirmed `g_mnt_1..7`, `mng_1`, `mni_1`, `mnc_1`, `g_frt_big_1`, `d_frt_big_1`, `e_frt_big_1`, `d_stn_1`, `str_new_1`).

Thus the absence of donor mine/stone/forest props is not an asset/data absence. It is the same I09 consumer failure:

1. the live `Stamp` Object is rejected;
2. even a dictionary stamp would look up `_records["mng_1"]`/`_records["d_stn_1"]`/etc., but `_try_feed` populated only `_records["generator_families"]`;
3. if the nested walker were added without unwrapping `BaseName.value`, `minegold`, `stones*`, and tree names would still fail SID resolution.

The black discs and black tree/unit/building shapes in the capture are consistent with the legacy `world3d_entities.gd` resource/entity layer. Image alone does not identify ore type or prove which batch produced a disc; no runtime node census was saved. **[I]/[U]**

### 3.3 Fields are a separate script-sown path and are not expected from pattern Objects

`spec/08_FIELDS_AND_PROPS.md:67-81` states that donor fields come from `unit.script` as a 7×7/49-node mill-sown lattice; no pattern/lib record names a field or mill.

I09 reflects this at `terrain_donor_props.gd:340-379`: `mill_field_hook()` returns `stamped:false`, `hook_only:true`, and a 49-node plan. It adds no node or MultiMesh. A dedicated grep found no caller anywhere under `variant3d/**`. Therefore donor field instances cannot appear from the current I09 path, independently of the Objects-feed bug.

## 4. Item 4 — black silhouettes are a lighting/material failure, not missing albedo

### 4.1 The donor backend omits the scene lighting rig

The legacy terrain installs the rig at `world3d_terrain.gd:1114-1166`:

- `WorldEnvironment` with sky, linear tonemap, ambient colour/energy (`:1114-1143`);
- `DirectionalLight3D` with donor diffuse colour, energy and orientation (`:1145-1166`).

The donor backend bypasses that module. `world3d.gd:623-626` selects `TERRAIN_DONOR_SCRIPT` when `terrain_backend == "donor"`; `main.gd:591-596` builds that backend. Neither `terrain_donor_world.gd` nor `terrain_donor_mesh.gd` contains `WorldEnvironment`, `Environment`, `DirectionalLight3D`, or an equivalent setup. `variant3d/scenes/main.tscn:1-6` contains only the `Main` node and script.

**Static consequence [I].** Lit spatial materials in the scene receive no donor sun/ambient rig. The donor terrain shader still renders because it is explicitly unshaded, while ordinary entity materials go black. This matches the capture: ground is visible; trees, units and buildings are black.

### 4.2 The entity materials are shaded

`world3d_entities.gd:644-662` creates `StandardMaterial3D`, binds the converted albedo, sets roughness/metallicity/alpha/culling, and never sets `SHADING_MODE_UNSHADED`.

The player tint path uses `TINT_SHADER_CODE` at `world3d_entities.gd:105-106`:

```gdscript
"shader_type spatial;\nrender_mode cull_disabled;\nuniform sampler2D albedo_tex : source_color;..."
```

It also has no `unshaded` render mode. Buildings and units using this override therefore remain dependent on scene lighting.

By contrast, `variant3d/shaders/terrain_donor_shader.gdshader:47-50` declares:

```gdscript
render_mode blend_mix, unshaded, cull_disabled;
```

That is why the terrain survives while the legacy silhouettes do not.

### 4.3 Albedo art exists and is bound

Bounded Pillow probes:

| Texture | Size / mode | Mean RGBA | Alpha nonzero | `.import` sidecar |
|---|---|---:|---:|---|
| `tree_pine.png` | 512² RGBA | 27.72, 29.37, 13.67, 134.60 | 53.93% | yes |
| `tree_spruce1.png` | 512² RGBA | 18.74, 16.03, 6.66, 107.82 | 45.67% | yes |
| `peasant.png` | 512² RGB | 95.35, 86.11, 73.11, 255 | 100% | yes |
| `mine_gold.png` | 2048² RGB | 62.09, 60.53, 36.59, 255 | 100% | yes |
| `terrainmesh1.png` | 2048² RGBA | 68.44, 63.36, 37.73, 198.90 | 96.0% | yes |

The manifest maps these sids to the bucketed OBJ/PNG paths, and `world3d_entities.gd:646-650` loads `AssetPaths.existing(sid, "tex")` into `albedo_texture`. The tree MTL also names the texture (`tree_pine.mtl:1-3`).

**Verdict [O]/[I].** The black silhouette is not explained by missing albedo files. The primary defect is the missing donor-backend light/environment rig. Runtime texture import success remains **[U]** without a Godot job, but the art, sidecars, manifest mapping and binding code are all present.

### 4.4 Donor prop batches also need an explicit material check

I09's `_add_to_batch` assigns the OBJ mesh to a `MultiMesh` (`terrain_donor_props.gd:759-767`) but never assigns a `material_override` or verifies the imported surface albedo. Legacy Z08 does the same (`world3d_relief.gd:206-246`). After the feed is fixed, props may appear but remain dark unless the restored lighting rig and imported MTL/albedo path are verified. This is a separate material integration task, not a reason to leave `props_total == 0`.

## 5. Capture evidence and limits

- The requested filename was not present under the repo root. It was located at `%TEMP%\opencode\v42\cap_donor_240c.png`, consistent with `VISUAL_WAVE_CHARTER.md:20`.
- PNG: 1280×720, 1,109,975 B, SHA-256 `27a2952ca0b4177e3338d39e558dab6684510c2b80b5653f6ea53b5807fe3ac6`.
- Bounded pixel probe: 94,638 pixels are exactly RGB `(0,0,0)` = **10.269%** of the frame; 95,363 pixels (10.348%) have all channels ≤12; 75.576% have all channels ≤32. The most common non-black colours are dark olive terrain values.
- Config: `features.terrain.backend = donor`, `relief_stamps = true`, 240×240, seed `20261113`, `map_type = land`, camera pitch −32°, start zoom `0.3448276`.
- Visual read **[O]**: readable stepped/terraced ground plus black tree/unit/building silhouettes; no readable donor mountain, mine, stone, forest-object or field layer.
- No stderr, I09 stats, scene-node dump or stamp dump accompanies the capture. No runtime count is asserted.

## 6. Additional consumer defects that matter after the feed walker lands

### 6.1 Full `Scaling` is currently collapsed

`_normalize_record` parses the full vector at `terrain_donor_props.gd:678`, but returns only `scale.x` at `:742`. `_add_to_batch` then applies a uniform scalar at `:793-794`.

A canonical census found **1,070 non-uniform Scaling records**. Example: `l_lake_small_4`, donor line 859660, `plantain`, Scaling `[0.4407208562, 0.4407208562, 0.3305406272]`. Current code silently changes that record to uniform X scale.

**Required fix:** carry a `Vector3` through normalization and use `Basis.scaled(scale_vec)`. Keep scalar compatibility for the Z08 fallback, whose records expose `sx`.

### 6.2 `Position.Y` is parsed and then dropped

`_normalize_record` returns `py` at `terrain_donor_props.gd:739`, but `_collect_stamp` computes world Y only from `_ground_y` at `:662`; `py` is never used. **17,354** canonical records have non-zero `Position.Y`.

For mountain records A04 reports `Y≈0` (`A04_landscape_props.md:227-233`), so this does not explain missing mountain silhouettes. It does affect other prop classes. The minimum honest consumer fix is to retain/apply the local Y under the existing **PORT APPROXIMATION** grounding contract (for example `ground + py`) and keep native `StandPatternWithAngle` semantics **[U]**; do not silently discard the field.

### 6.3 `_props_applied` is true for any Dictionary, including zero props

`terrain_donor_world.gd:273` sets:

```gdscript
			_props_applied = pres is Dictionary
```

A zero-prop stats Dictionary therefore reports `props_applied = true`. This must become a `counts.props_total > 0` check (with `built == true`) before it is used as evidence that the P channel is active.

### 6.4 Two relief consumers can duplicate geometry

`world3d.gd:629,665-666` always instantiates and binds legacy `world3d_relief.gd`, including when `terrain_backend == "donor"`. If I09 is repaired and a mountain stamp exists, both legacy Z08 and I09 can instance the same `terrainmesh*` records. COORD should choose one authoritative donor-prop consumer and disable/bypass the other on the donor backend.

## 7. Exact consumer-side fixes and text-only patch sketch

### 7.1 `_try_feed`: canonical section walker

Insert a canonical branch **before** the generic top-level fallback, moving the existing `found` declaration ahead of it. Count only real Objects records; do not treat family metadata as records.

```gdscript
var found: int = 0

# I03 canonical shape: root.pattern_lib.sections[].blocks[].records[]
var pl: Variant = root.get("pattern_lib", null)
if pl is Dictionary:
	var sections_v: Variant = (pl as Dictionary).get("sections", [])
	if sections_v is Array:
		for section_v in (sections_v as Array):
			if not (section_v is Dictionary):
				continue
			var section: Dictionary = section_v as Dictionary
			var pattern_name: String = str(section.get("name", "")).strip_edges()
			if pattern_name.is_empty():
				continue
			var blocks_v: Variant = section.get("blocks", [])
			if not (blocks_v is Array):
				continue
			for block_v in (blocks_v as Array):
				if not (block_v is Dictionary):
					continue
				var block: Dictionary = block_v as Dictionary
				if str(block.get("block", "")) != "Objects":
					continue
				var records_v: Variant = block.get("records", [])
				if not (records_v is Array):
					continue
				var normalised: Array[Dictionary] = []
				for raw_v in (records_v as Array):
					if not (raw_v is Dictionary):
						continue
					var rec: Dictionary = (raw_v as Dictionary).duplicate(true)
					var base_v: Variant = rec.get("BaseName", null)
					if base_v is Dictionary:
						rec["BaseName"] = str((base_v as Dictionary).get("value", ""))
					# Position/Scaling/Up already use X/Y/Z and _vec3() reads them.
					normalised.append(rec)
				if not normalised.is_empty():
					var dst: Array = _records.get(pattern_name, [])
					dst.append_array(normalised)
					_records[pattern_name] = dst
					found += normalised.size()

# Existing generic/Z08 shape only if no canonical Objects were found.
# Add "generator_families" to the metadata skip list at :592-594.
```

Important schema note **[O]:** in the pretty-printed JSON, `blocks` may appear before `name` within a section. Ownership must be determined from the parsed `section.name`, not from line adjacency. For example, the Objects block at `pattern_lib_index.json:29388` belongs to parsed section `plt1`, not the preceding `brush_plt_1x1_mid` metadata section. A parsed walker keyed by `section.name` is correct; a line-neighbour heuristic is not.

### 7.2 `_collect_stamp`: accept the live `Stamp` Objects

Minimal I09-local fix (the existing `_stamp_cell()` already supports Objects through `_g` at `:966-985`):

```gdscript
func _collect_stamp(p_raw, p_out: Array[Dictionary], p_stats: Dictionary) -> void:
	if not (p_raw is Dictionary or p_raw is Object):
		# count skipped_non_dictionary_stamp only for truly unsupported values
		return
	var name_v: Variant = _g(p_raw, "name",
		_g(p_raw, "pattern", _g(p_raw, "pattern_name", "")))
	var name: String = "" if name_v == null else str(name_v).strip_edges()
	# ... existing empty-name / _stamp_cell / _records.get(name) path ...
```

Alternative COORD fix: convert each `C3PatternGen.Stamp` to `{"name": st.name, "x": st.x, "y": st.y}` before `build()`. Do not rely on `data.meta["pattern_stamps"]`; no current producer writes it.

### 7.3 Preserve `Position` and `Scaling`

In `_normalize_record`:

```gdscript
# BaseName is a string after the walker above; harden here too if desired.
var base: String = _s(p_raw, "base", _s(p_raw, "BaseName", _s(p_raw, "base_name", "")))
var pos: Vector3 = _vec3(p_raw.get("Position", p_raw.get("position", null)))
var scale_vec: Vector3 = _vec3(p_raw.get("Scaling", p_raw.get("scaling", null)))
# ... existing finite checks / yaw ...
return {
	# ...
	"px": pos.x, "py": pos.y, "pz": pos.z,
	"scale_vec": scale_vec,
	# ...
}
```

In `_collect_stamp`, under the existing PORT APPROX grounding label:

```gdscript
var wy: float = _ground_y(wx, wz, pc) + float(rec["py"])
```

In `_add_to_batch`:

```gdscript
var sc: Vector3 = Vector3.ONE
if p_rec.get("scale_vec") is Vector3:
	sc = p_rec["scale_vec"] as Vector3
elif p_rec.get("scale") != null:
	sc = Vector3.ONE * float(p_rec["scale"])  # Z08 scalar compatibility
basis = basis.scaled(sc)
```

### 7.4 Provenance label conditional on `props_total > 0`

Replace the unconditional label at `terrain_donor_props.gd:272-277` with logic equivalent to:

```gdscript
var donor_objects_instanced: bool = (
	int(counts["props_total"]) > 0
	and not _fallback_used
	and _feed_source.begins_with("res://assets/terrain_new/")
)
var feed_label: String
if donor_objects_instanced:
	feed_label = "DONOR LITERALS (I03 Objects[])"
elif _fallback_used and int(counts["props_total"]) > 0:
	feed_label = "PORT APPROX — Z08 fallback table"
elif int(counts["props_total"]) == 0:
	feed_label = "ZERO PROPS — feed/stamp/shape UNVERIFIED"
else:
	feed_label = "UNVERIFIED — non-canonical object source"
st["feed"] = {"source": _feed_source, "fallback_used": _fallback_used, "label": feed_label}
```

Also change the composer's success flag (`terrain_donor_world.gd:273`) to require:

```gdscript
_props_applied = pres is Dictionary and bool(pres.get("built", false)) \
	and int(pres.get("counts", {}).get("props_total", 0)) > 0
```

### 7.5 Restore lighting/materials and avoid duplicate consumers

- **COORD/I08:** port the existing donor-cited rig from `world3d_terrain.gd:1114-1166` into the donor backend, or explicitly share one rig at world composition level. Do not invent new light constants.
- **I09/COORD:** verify each `DonorProps_*` batch has the converted OBJ/MTL albedo or an explicit `material_override`; then re-check under the restored rig. Do not use a black/default material as a placeholder.
- **COORD:** when donor I09 is authoritative, bypass legacy `world3d_relief.gd` to prevent duplicate `terrainmesh*` instances.
- **COORD:** for a mountain visual audit, use an explicit mountain-relief config. The current 240² `hills` config derives zero mountain stamps even after the P-channel consumer is fixed.

## 8. Required post-fix checks (not run here)

For a future owner-run donor-backend capture, require all of the following before interpreting the image:

1. `stats.feed.source` is `res://assets/terrain_new/lib/pattern_lib_index.json`;
2. `stats.feed.fallback_used == false`;
3. `counts.props_total > 0`;
4. `counts.skipped_non_dictionary_stamp == 0` and `counts.matched_stamps > 0`;
5. on a mountain fixture, instanced `terrainmesh1..4` count is greater than zero;
6. mine, forest and stone class counts are each greater than zero on a map containing those stamps;
7. sampled `mng_1` → `minegold` resolves to sid `mine_gold` with the literal Position/Scaling above;
8. non-uniform scale vectors are preserved and `Position.Y` is not silently dropped;
9. no duplicate legacy Z08 + I09 relief batches;
10. restored lighting produces non-black entity/prop albedo, with no script errors.

These are structural/self-consistency checks only. They are **not** donor-parity gates.

## 9. Multiple-pass register

| Pass | Instrument | Result |
|---|---|---|
| P1 | Full read of the required charter, X16/X25/X36/V59/V106, spec §08, current `terrain_donor_props.gd` | Established current line numbers and the V106 consumer blocker. |
| P2 | Bounded line-by-line needle scan of the 55.8 MB index | 668 Objects blocks; 39,783 Scaling/Up; 39,790 textual `BaseName` mentions (includes metadata mentions). Confirmed nested data without full output. |
| P3 | Full JSON parse with bounded aggregate/selected output | 680 sections / 668 Objects blocks / 39,783 records; selected `g_mnt`, mine, forest and stone sections enumerated. |
| P4 | Independent parse of all 64 `patterns/families/*.json` | 479 Objects blocks / 31,951 records; selected families present. Shared mine pattern names repeat across family files, so the canonical lib index is the safer unique source. |
| P5 | Parse of all 710 root per-pattern JSONs | 550,908 `object_records`, all with only `f4/id/k/tail4/u/v`; none carries `BaseName`. Confirms they are the 24-byte tail, not prop transforms. |
| P6 | Section ownership/schema cross-check | All 668 Objects blocks belong to named parsed sections. Corrected a line-adjacency trap: `blocks` can precede `name`; key by parsed `section.name`. |
| P7 | Transform census | All Position/Scaling/Up numeric and finite; 1,070 non-uniform scales; 17,354 non-zero Position.Y values. |
| P8 | Legacy pattern/table and manifest probes | Legacy source contains the stamp names; Z08 has only relief records; four relief OBJ/PNG pairs and tree/unit/mine textures exist. |
| P9 | Current source trace for composer, stamps, lighting and config | Live stamps are Objects; I07 meta route has no producer; donor backend lacks the legacy light rig; 240² hills derives zero mountain stamps. |
| P10 | Capture pixel/config probe | 1280×720 donor capture; 10.269% exact-black pixels (10.348% at ≤12/channel); config pins donor/240²/seed but no explicit mountain relief. |

No anomaly was accepted from a single reading. No Godot process, donor binary, runner job, gate, capture or parity comparison was used.

## 10. Handoff to COORD

1. **P0 — I09 owner:** implement §7.1–§7.4. This is the minimum path to `props_total > 0` from canonical Objects records.
2. **P0 — COORD/I08:** restore the donor-backend lighting rig and verify prop/entity albedo materials. Feed fixes alone will produce dark or black props under the current scene.
3. **P0 — COORD:** choose one relief consumer; do not run legacy Z08 and donor I09 over the same mountain stamps.
4. **P1 — capture owner:** current 240² `hills` config cannot exercise `terrainmesh*`; use an explicit mountain fixture after the consumer fixes.
5. **P1 — field owner:** wire the script-sown mill-field hook separately if fields are in scope; it is not an Objects-feed problem.

**NO DONOR PARITY CLAIM. Donor parity remains UNVERIFIED.**
