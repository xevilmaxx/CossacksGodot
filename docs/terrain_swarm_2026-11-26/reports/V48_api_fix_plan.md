---
id: V48
ticket: "TERRAIN-SWARM-2026-11-26 / V48 — paste-ready fix plan for V36's four hard API breaks"
agent: "V48 (read-only planning subagent, DONOR-FIRST terrain swarm 2026-11-26; worker V48, reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_BACKUP_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V48_api_fix_plan.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V48_api_fix_plan.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate or capture was used by V48. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Nothing below is a PASS, a gate result or a donor-parity claim. All conversions described are PORT APPROXIMATION."
scope_guard: "Read-only: file reads, grep, git read commands, PowerShell Get-Date/Get-FileHash/Select-String/Get-ChildItem via git status were used. No .bak, source, shader, asset, test, manifest, config, queue, app/ byte or git state was changed. Patches below are TEXT ONLY and were NOT applied."
multiple_passes: true
snapshot: "2026-11-26 09:57:59 +01:00 (08:57:59 UTC); HEAD=e234ac9b. Implementation files were still landing during V36 and this audit: I07 and I09 hashes/line numbers drifted since V36's 09:52:04 snapshot. Re-read immediately before COORD applies anything (V11 §6 rule 4; V28 R7)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V48 — paste-ready fix plan for V36's four hard API breaks

## 0. Multiple-pass log (owner directive, CHARTER.md:85-93)

No break was accepted from one reading; every call was re-read on both sides with a
second instrument (file `read` → `grep` → PowerShell `Select-String`), and re-read
again after the I07/I09 hash drift.

| Pass | Instrument | Result | Effect on verdict |
|---|---|---|---|
| P1 | `read` of `terrain_donor_world.gd` (full, 333 lines) | Call sites at `:216` gen, `:224` mesh, `:229/:231` props | Break candidates located [O] |
| P2 | `Select-String` on the composer (2nd instrument) | Same four lines, with context `:215-232` | Confirmed; not a first-read artefact |
| P3 | `read` gen `380-499` + `Select-String` for `func generate` | `generate(data: C3TerrainData, p: Dictionary = {})`; **now :420**, V36 cited :408; hash `3DA99FBA…` → `FC0EE6AF…` | Drift recorded; signature unchanged |
| P4 | `Select-String` across gen/props/mesh for `func generate/bind/build/_source_dicts/_first` | gen `:420`, props `build` **:210** (V36 :198), mesh `bind` `:122`, `_source_dicts` `:196`, `_first` `:204`, `build` `:718` | Current line cites pinned; props hash `17BCC814…` |
| P5 | `read` mesh `100-329` + `grep` `_data` + `Select-String` | `_source_dicts()` yields only Dictionary/`fields`; I06 has no `fields`; `_ingest()` `:260-265` returns false when `w<=1 or h<=1`; `build()` `:718-722` gates on `_ingest()` | Break (c) confirmed on both sides (3rd read) |
| P6 | `read` props `1-240,278-291` (2nd pass after drift) | No `func bind` anywhere; `build(p_container: Object, p_stamps: Array, p_options: Dictionary = {}) -> Dictionary` `:210`, binds container/terrain itself `:211-213`, returns stats `:216/:288` | Break (b) confirmed after repair window |
| P7 | `read` data `1-194,380-499,555-629` + `grep` | `to_live()` `:456-475` (w/h/height/tex/collision/SIDE arrays/props/meta), `to_dump()` `:563-592`; `SIDE_U8_KEYS` includes `relief_mask` (`:49-50`); **no `fields` member** | Adapters (c) exist and are I06-owned |
| P8 | `read` test `1-120,225-399` + `Select-String` | Hook call `:343-345` still `(SEED, GEN_KEYS, size, size)`; `_call_hook` `:298-311` truncates to argc; `src = res` `:351` (telemetry) | Break (d) confirmed post-drift (test hash `62540F29…`) |
| P9 | `grep` gen for `generate_streams|func run|func build_streams|func generate_map|func bind` | **Only** `func stats()` `:508`; no alternative hook, no `run`, no `bind` | `run` fallback in composer is a no-op; no adapter landed |
| P10 | `Get-FileHash` on all six files + `git status`/`git rev-parse` at 09:57:59 | composer `0B3672D4…`, gen `FC0EE6AF…`, mesh `6AB8453A…`, props `17BCC814…`, data `77D7BFA1…`, test `62540F29…`; HEAD `e234ac9b`; canonical shader now present, `assets/terrain_new/` untracked | Tree still volatile; cite current lines, not V36's |

**[O] No anomaly was silently skipped.** All remaining unknowns are in §6. No patch was applied.

---

## 1. Executive summary

1. **[O]/[D] All four V36 hard breaks are still live after a second, post-drift read.** The
   composer passes a game `Object` where I07 requires a `Dictionary` (`:216` vs gen `:420`);
   gates props behind a `bind()` that I09 does not define (`:229` vs props `:210`); hands the
   I06 `Object` to I08 whose ingest reads Dictionaries only (`:224` vs mesh `:196-213`); and
   I12 calls `generate` with `(int, Dictionary, int, int)` against a typed
   `(C3TerrainData, Dictionary)` first parameter (test `:343-345` vs gen `:420`).
2. **[D] All four are caller-side fixes.** Prefer repairing `terrain_donor_world.gd` (COORD's
   own I11-COMPOSER file, V11 N14) and `t_terrain_donor.gd` (I12's own file, V11 N15). Callee-side
   adapters are supplied as fallbacks but each touches a second owner's file and are therefore
   higher risk under V11 §6 one-owner-per-file.
3. **[D] No donor constant, threshold, assertion or gate is changed.** The patches only pass
   already-owned values through the callees' declared types: `{}` settings, `game.pattern_stamps`
   (game.gd:66), I06's own `to_live()`/`to_dump()`, and a `C3TerrainData` container constructed
   with the test's existing `SEED`/`GEN_KEYS`.
4. **[O] Drift is real:** gen `408→420` and props `198→210` since V36's snapshot; current
   hashes are in §0 P10. COORD must re-read before applying. The canonical shader now exists and
   `assets/terrain_new/` is untracked — V36 C1/C10 have moved independently of this ticket.
5. **[U]/PORT APPROXIMATION** No Godot parse, runner job, gate or capture was performed by V48.
   **No donor parity claim.** The verification checklist is for COORD to execute.

---

## 2. Evidence table

| ID | Source (current file:line; snapshot 09:57:59) | Observation [O] unless labelled | Consequence [D] |
|---|---|---|---|
| EV01 | `terrain_donor_world.gd:216` | `_call_adapt(_gen, "generate", [_data, game])` | `game` is an Object; I07 expects Dictionary (a) |
| EV02 | `terrain_donor_gen.gd:400-420` | Doc: `p keys …`; `func generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary`; returns telemetry (`:419`,`:504`) | (a) and (d) share one typed signature |
| EV03 | `terrain_donor_gen.gd:443-450` | `p.get("randkey0"/"randkey1")`, `p.get("width")`, `p.get("height")` | Settings Dictionary is the ONLY input channel besides the container |
| EV04 | `terrain_donor_gen.gd:890,1073,443-446` | Writes `data.height`, `data.tex`; missing keys produce labelled PORT placeholder note | Streams live in the container, not in the return value (d/A12) |
| EV05 | `terrain_donor_world.gd:224` | `target.callv("bind", [game, _data])` | `_data` is the I06 Object (c) |
| EV06 | `terrain_donor_mesh.gd:122,177-193,196-213,260-265,718-722` | `bind(g, d=null)` untyped; `_source_dicts()` yields `[src]` plus `fields` only if Dictionary; `_first()` skips non-Dictionary; `_ingest()` false if `w<=1 or h<=1`; `build()` false if `!_ingest()` | Object handoff yields no mesh (c) |
| EV07 | `terrain_donor_data.gd:49-52,456-475,563-592` | No `fields` member; `to_live()` Dictionary has `w,h,height,tex,collision,relief_mask,props,meta`; `to_dump()` has `map_w,map_h,height(b64),tileblock(b64),fields` | Both converters are ready-made caller-side adapters (c) |
| EV08 | `terrain_donor_world.gd:229-231` | `_call_adapt(_props,"bind",[game,_data,_mesh])` gates `_call_adapt(_props,"build",[])` | Props never built (b) |
| EV09 | `terrain_donor_props.gd:200-216,233-240,285-288` | Public API lists `build(container, stamps, options) -> stats`; **no `bind`**; `build()` stores container/stamps/terrain itself and returns `rebuild()` stats; falls back to `container.meta["pattern_stamps"]`, else records `NO_I07_STAMP_LIST` | (b); no stamp fabrication permitted |
| EV10 | `t_terrain_donor.gd:49-59,298-311,343-345,349-354` | `SEED`, `GEN_KEYS`; `_call_hook` truncates args to method arity; call uses `[SEED, GEN_KEYS, size, size]`; `src = res` | `generate` receives `int` where `C3TerrainData` required; streams read from telemetry (d) |
| EV11 | `t_terrain_donor.gd:243-271,283-295,360-375` | `_as_f32` accepts `PackedFloat32Array`; `_as_u8` accepts `PackedByteArray`; `_read_from` accepts Object via `Object.get`; stream keys `height,tileblock,terrain,blocked,props,w,h` | Reading the mutated container satisfies every stream field without changing the test's downstream logic (d) |
| EV12 | `game.gd:66`; `world3d_relief.gd:121`; `config.gd:62` (via V36 EV15) | `game.pattern_stamps` exists and is the established read-only stamp source; relief-stamp opt-in defaults off | Composer can pass stamps without synthesising any (b) |
| EV13 | `terrain_donor_mesh.gd:221,248,297,681` | Typed arrays are duplicated on ingest; `stats["source"]` reports `_ingest_source` | `to_live()` CoW read-only contract is respected; verifiable telemetry key exists (c) |
| EV14 | `git rev-parse --short HEAD`; `git status --short -- variant3d/ app/` | `e234ac9b`; `main.gd`/`world3d.gd` modified; canonical `terrain_donor_shader.gdshader` present; `app/` empty | Snapshot pinned; V36's other conflicts are outside this ticket |

---

## 3. Patch (a) — composer → I07: Object where `p: Dictionary` required

**Owner/file:** I11-COMPOSER (COORD), `variant3d/scripts/terrain_donor_world.gd` — V11 N14
(`V11_ownership_ledger.md:106`). **Callee:** I07, `terrain_donor_gen.gd:420` (V36 cited :408;
hash drift `3DA99FBA…` → `FC0EE6AF…`).

### Exact current lines (`:214-218`)

```gdscript
	if _gen != null:
		_gen_applied = _call_adapt(_gen, "generate", [_data, game])
		if not _gen_applied:
			_gen_applied = _call_adapt(_gen, "run", [_data, game])
```

### Exact replacement lines

```gdscript
	if _gen != null and _data != null:
		# I07's typed surface is generate(C3TerrainData, Dictionary) (gen.gd:420).
		# The game Object is never a settings Dictionary; decoded donor inputs
		# arrive in p. Empty p => missing inputs stay labelled/skipped, never
		# invented (gen.gd:400-419, :443-446). No gate, no parity claim.
		var gen_params: Dictionary = {}
		_gen_applied = _call_adapt(_gen, "generate", [_data, gen_params])
		if not _gen_applied:
			_gen_applied = _call_adapt(_gen, "run", [_data, gen_params])
```

### Why this preserves the callee contract

- I07 documents exactly two inputs: the `C3TerrainData` container and a settings `Dictionary`
  (`gen.gd:400-419`). The replacement supplies both with the right types; the `game` Object was
  never part of I07's surface.
- `{}` is the declared default (`gen.gd:420`) and I07 explicitly handles absent decoded inputs
  by labelling and skipping them (`gen.gd:384-386`, `443-446`). No donor constant is invented, no
  threshold is lowered, no assertion deleted.
- The `_data != null` guard prevents handing `null` to a typed `C3TerrainData` parameter; it only
  makes `_gen_applied` honestly report "not called" when I06 is missing.
- The `run` fallback is retained for graceful degradation of a hypothetical narrower module
  (composer `:15-19`). V48 verified `run` does **not** exist on I07 (P9), so this is inert, not a
  second generation path.

### Minimal adapter if changing the module is riskier than changing the caller

Add to **I07** (owner I07 — touches a second owner's file, therefore NOT recommended):

```gdscript
func generate_from_game(game: Object, p: Dictionary = {}) -> Dictionary:
	var d := C3TerrainData.new()
	if not d.from_live_object(game):          # data.gd:411 — existing read-only handoff
		return stats()
	return generate(d, p)
```

Composer then replaces `:216` with `_gen_applied = _call_adapt(_gen, "generate_from_game", [game])`.
This keeps the typed `generate()` unchanged but adds a new public method to I07 and relies on I06's
`from_live_object()` succeeding; caller-side `{}` is lower risk and fully contract-correct.

---

## 4. Patch (b) — composer → I09: `bind()` does not exist, `build()` has three inputs

**Owner/file:** I11-COMPOSER (COORD), `terrain_donor_world.gd:227-231`.
**Callee:** I09, `terrain_donor_props.gd:210` (V36 cited :198; hash drift `E8638915…` →
`17BCC814…`); `grep` confirms **no `func bind`** in that file (P4/P6).

### Exact current lines (`:227-231`)

```gdscript
	# I09: optional, built after the mesh/height source is live.
	if _props != null:
		_props_applied = _call_adapt(_props, "bind", [game, _data, _mesh])
		if _props_applied:
			_call_adapt(_props, "build", [])
```

### Exact replacement lines

```gdscript
	# I09: optional, built after the mesh/height source is live. I09 has no
	# bind(); its single entry is build(Object, Array, Dictionary) (props.gd:210)
	# and it binds container/terrain itself (props.gd:211-213).
	if _props != null and _props is Object:
		var ptarget: Object = _props as Object
		if ptarget.has_method("build"):
			var stamps: Array = []
			var stamps_v: Variant = _prop(game, "pattern_stamps")
			if stamps_v is Array:
				stamps = stamps_v as Array
			var pres: Variant = ptarget.call("build", _data, stamps, {"terrain": _mesh})
			_props_applied = pres is Dictionary
```

### Why this preserves the callee contract

- `build(p_container: Object, p_stamps: Array, p_options: Dictionary = {}) -> Dictionary`
  (`props.gd:210`) is called with exactly those three types. I06 `_data` is an Object; the stamps
  are an Array; `{"terrain": _mesh}` is the option key I09 actually reads (`props.gd:213`).
- I09's `build()` itself assigns `_container`, `_stamps` and `_terrain` and calls `rebuild()`
  (`props.gd:211-216`), so a separate `bind()` would be redundant even if it existed.
- Stamps come from `game.pattern_stamps` (`game.gd:66`; already the read-only source used by
  `world3d_relief.gd:121`), or an empty Array. I09's own documented fallback reads
  `container.meta["pattern_stamps"]` and otherwise records `NO_I07_STAMP_LIST`
  (`props.gd:233-240`). **No stamp is synthesised.**
- `_props_applied = pres is Dictionary` means "build was dispatched and returned its stats
  dictionary" (`props.gd:210,216,288`), not a claim that any prop was placed or that parity holds.

### Minimal adapter if changing the module is riskier than changing the caller

Add to **I09** (owner I09 — second owner's file, NOT recommended):

```gdscript
func bind(g, d = null, m = null) -> void:
	_game = g
	_container = d
	_terrain = m
```

The composer could then keep its existing `bind` call, but `build()` still needs the three
arguments, so this shim alone does not repair `:231`; the caller-side fix above is both smaller
and complete.

---

## 5. Patch (c) — composer → I08: I06 Object handed to Dictionary-only ingest

**Owner/file:** I11-COMPOSER (COORD), `terrain_donor_world.gd:223-224`.
**Callee:** I08, `terrain_donor_mesh.gd:122` (`bind(g, d=null)`), `_source_dicts():196-201`,
`_first():204-213`, `_ingest():260-303`, `build():718-722`. **Converter:** I06,
`terrain_donor_data.gd:456-475` (`to_live()`), `:563-592` (`to_dump()`).

### Exact current lines (`:223-224`)

```gdscript
		if target.has_method("bind"):
			target.callv("bind", [game, _data])
```

### Exact replacement lines

```gdscript
		if target.has_method("bind"):
			# I08's ingest is Dictionary-only (mesh.gd:196-213); an I06 Object
			# carries no `fields` and is skipped. Hand over I06's own read-only
			# live view (data.gd:456-475): typed arrays, no base64 copy, no
			# sim write, no new constant, no parity claim. to_dump() is the
			# byte-snapshot fallback (data.gd:563-592).
			var mesh_src: Variant = _data
			if _data != null and _data is Object and (_data as Object).has_method("to_live"):
				mesh_src = (_data as Object).call("to_live")
			elif _data != null and _data is Object and (_data as Object).has_method("to_dump"):
				mesh_src = (_data as Object).call("to_dump")
			target.callv("bind", [game, mesh_src])
```

### Why this preserves the callee contract

- `_candidate_sources()` puts the explicit `_data` first (`mesh.gd:177-193`). With a Dictionary
  in that slot, `_source_dicts()` returns `[dictionary]` (`mesh.gd:196-201`), so `_first()` finds
  `w`/`h` (`mesh.gd:262-263`) and `_ingest()` finds `height`, `tex`, `relief_mask`
  (`mesh.gd:271-292`). With the old I06 Object it skipped every source, `w=0`, `_ingest()` false
  (`:264-265`), `build()` false (`:720-722`).
- `to_live()` exposes exactly the needed keys: `w,h,n,height,tex,collision`, all SIDE arrays
  (including `relief_mask`, `data.gd:49-50`) and `props/meta` (`data.gd:456-475`). Its typed
  arrays need no base64 decode and are duplicated on ingest by I08 (`mesh.gd:221,248`), preserving
  I06's CoW read-only contract (`data.gd:455-456`).
- `to_dump()` is the fallback for a hypothetical I06 without `to_live()`: its `map_w/map_h`,
  base64 `height/tileblock` and `fields` are handled by I08's `_as_float_array()`/`_as_byte_array()`
  (`mesh.gd:216-257`). Both converters are I06-owned; no new adapter data is fabricated.
- `bind()` remains untyped (`mesh.gd:122`), so no I08 signature change is needed. Mesh build order
  is unchanged: I07 has already mutated `_data` before this call (`world.gd:215-218` → `224`),
  so the view contains generated heights and tile ids.

### Minimal adapter if changing the module is riskier than changing the caller

Add at the head of **I08's** `_source_dicts()` (owner I08 — second owner's file, NOT recommended):

```gdscript
func _source_dicts(src) -> Array:
	if src is Object:
		if (src as Object).has_method("to_live"):
			return [(src as Object).call("to_live")]
		if (src as Object).has_method("to_dump"):
			return [(src as Object).call("to_dump")]
	var out: Array = [src]
	var f = _get_prop(src, "fields")
	if f is Dictionary:
		out.append(f as Dictionary)
	return out
```

This preserves I08's Dictionary-only ingest (it still reads Dictionaries) while accepting I06
Objects, but it changes another owner's ingest semantics for **all** callers. The caller-side fix
above is local to COORD's composer.

---

## 6. Patch (d) — I12 test hook: `(int, Dictionary, int, int)` vs typed first parameter

**Owner/file:** I12, `variant3d/tests/t_terrain_donor.gd:330-354` — V11 N15
(`V11_ownership_ledger.md:107`). **Callee:** I07 `generate(data: C3TerrainData, p: Dictionary = {})`
(`gen.gd:420`), writes streams into the container (`gen.gd:890,1073`) and returns telemetry only
(`gen.gd:419,504`). This single patch repairs both V36 A11 (arity/type) and A12 (return shape).

### Exact current lines (`:330-354`)

```gdscript
func _generate_streams(size: int) -> Dictionary:
	var script := load(MODULE_GEN) as Script
	if script == null or not script.can_instantiate():
		return {}
	var g: Object = script.new()
	if g == null:
		return {}
	_set_if(g, "seed", SEED)
	_set_if(g, "random_seed", SEED)
	_set_if(g, "map_w", size)
	_set_if(g, "map_h", size)
	_set_if(g, "keys", GEN_KEYS)
	_set_if(g, "map_type", str(GEN_KEYS["map_type"]))
	var res: Variant = _call_hook(g,
			["generate_streams", "generate", "generate_map", "run", "build_streams"],
			[SEED, GEN_KEYS, size, size])
	if res == null:
		_dispose(g)
		return {}
	# The new module may return a C3TerrainData container, a raw dump Dictionary,
	# or an object carrying a `dump` Dictionary — read from the richest source.
	var src: Variant = res
	var dump_v: Variant = _read_from(res, ["dump"])
	if dump_v is Dictionary:
		src = dump_v
```

### Exact replacement lines

```gdscript
func _generate_streams(size: int) -> Dictionary:
	var script := load(MODULE_GEN) as Script
	var data_script := load(MODULE_DATA) as Script
	if script == null or data_script == null or not script.can_instantiate():
		return {}
	var g: Object = script.new()
	var data := data_script.new(size, size) as C3TerrainData
	if g == null or data == null:
		_dispose(g)
		return {}
	# I07's only generation entry is generate(C3TerrainData, Dictionary)
	# (terrain_donor_gen.gd:420); it returns telemetry (gen.gd:419, :504) while
	# the streams are written into the container (gen.gd:890, :1073). No arity
	# truncation, no int-as-container, no gate weakened.
	# Seed mapping is PORT APPROX: config.json:77 gameplay.random_seed (test :49)
	# -> the donor-named key words I07 reads (gen.gd:443-446). No donor constant
	# is invented; parity stays UNVERIFIED.
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
```

Lines `:355-377` of the test (`props` collection, `w/h` resolution, `out` dictionary, `_dispose`)
stay **exactly as they are**: `_read_from()` accepts an Object via `Object.get()` (`:289-294`),
`_as_f32()` accepts `PackedFloat32Array` (`:245-249`) and `_as_u8()` accepts `PackedByteArray`
(`:262-263`), so the container satisfies every stream key (`height`, `tex`, `terrain_class`,
`collision`, `props`, `resources`, `w`, `h`) without touching a downstream assertion.

### Why this preserves the callee contract

- `data_script.new(size, size)` invokes I06's `_init(width, height_cells)` (`data.gd:162-164`),
  producing a real `C3TerrainData` with sized arrays; `_call_hook()` passes it as argument 1 and
  the settings Dictionary as argument 2 — exactly the declared arity (`:298-311` + gen `:420`).
- The removed `_set_if(g, …)` lines were `Object.set()` on properties I07 does not declare
  (no-op); seed/size are now supplied through the documented `p` channel instead. Nothing is
  deleted from a gate.
- Reading `src = data` fixes A12 without changing I07's return type: I07's telemetry is
  diagnostics only (`gen.gd:419,504`) and the streams are in the container it mutates.
- The `SEED & 0xFFFFFFFF` mapping is labelled PORT APPROXIMATION in-code; it adds no donor value.
  Two runs with identical `(data, settings)` remain byte-comparable, so the determinism contract
  of `:757-758` is unchanged.

### Minimal adapter if changing the module is riskier than changing the caller

Add to **I07** (owner I07 — second owner's file, NOT recommended):

```gdscript
func generate_streams(seed: int, keys: Dictionary, w: int, h: int) -> Dictionary:
	var d := C3TerrainData.new(w, h)
	var p: Dictionary = keys.duplicate(true)
	p["randkey0"] = seed & 0xFFFFFFFF
	p["randkey1"] = seed & 0xFFFFFFFF
	p["width"] = w
	p["height"] = h
	generate(d, p)
	var out: Dictionary = d.to_live()          # data.gd:456 — typed streams
	out["map_w"] = w
	out["map_h"] = h
	return out
```

The test's original `_call_hook` would then bind `generate_streams` first and read a flattened
Dictionary directly; this keeps the typed `generate()` intact but duplicates seed mapping in
I07 and adds a public method to another owner's file. Caller-side patch is preferred.

---

## 7. Verification checklist for COORD (static grep + parse smoke)

**V48 ran no Godot job and no gate.** Execute these read-only checks from the repo root before
and after applying the text patches. Re-run the §0 hashes first; if any differs, re-derive line
numbers before pasting.

### 7.1 Preflight (read-only)

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
git rev-parse --short HEAD
git status --short -- variant3d/ app/
Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\terrain_donor_world.gd','variant3d\scripts\terrain_donor_gen.gd','variant3d\scripts\terrain_donor_mesh.gd','variant3d\scripts\terrain_donor_props.gd','variant3d\scripts\terrain_donor_data.gd','variant3d\tests\t_terrain_donor.gd' | Format-Table -AutoSize
```

Expected: HEAD `e234ac9b`; `app/` empty; hashes equal §0 P10. If I07/I09 moved again, re-run
`Select-String` to re-locate `func generate`, `func build` and the composer call sites.

### 7.2 Static grep — negative checks (expect **0** hits after patching)

```powershell
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Pattern '_call_adapt\(_gen, "generate", \[_data, game\]\)|_call_adapt\(_gen, "run", \[_data, game\]\)'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Pattern 'target\.callv\("bind", \[game, _data\]\)'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Pattern '_call_adapt\(_props, "bind"|_call_adapt\(_props, "build", \[\]\)'
Select-String -LiteralPath 'variant3d\tests\t_terrain_donor.gd' -Pattern '\[SEED, GEN_KEYS, size, size\]|var src: Variant = res'
```

### 7.3 Static grep — positive checks (expect **1** hit each, at the cited lines)

```powershell
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Pattern '_call_adapt\(_gen, "generate", \[_data, gen_params\]\)'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Pattern 'has_method\("to_live"\)|mesh_src = \(_data as Object\)\.call\("to_live"\)'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Pattern 'ptarget\.call\("build", _data, stamps, \{"terrain": _mesh\}\)'
Select-String -LiteralPath 'variant3d\tests\t_terrain_donor.gd' -Pattern 'as C3TerrainData|_call_hook\(g, \["generate"\], \[data, settings\]\)|var src: Variant = data'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_gen.gd' -Pattern 'func generate\(data: C3TerrainData, p: Dictionary = \{\}\)'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_data.gd' -Pattern 'func to_live\(\)|func to_dump\(\)'
Select-String -LiteralPath 'variant3d\scripts\terrain_donor_props.gd' -Pattern 'func build\(p_container: Object, p_stamps: Array'
```

Additionally confirm no new donor constant or weakened assertion slipped in:

```powershell
git diff --unified=0 -- variant3d/scripts/terrain_donor_world.gd variant3d/tests/t_terrain_donor.gd
git diff --exit-code -- app/ variant3d/scripts/game.gd variant3d/scripts/world3d_terrain.gd variant3d/scripts/world3d_relief.gd variant3d/shaders/terrain_tileindex.gdshader variant3d/project.godot
```

Expected: only the four documented call-site changes; freeze diff exit 0; `app/` clean.

### 7.4 Parse smoke (COORD only — V48 submits no runner job)

Per `V36_integration_checklist.md:169` (§6 step 2), after the tree is frozen run **one** Godot
parse job with a unique id, e.g. `python variant3d\tools\godot_runner.py run --id V48-PARSE-1`.
Accept only: all six files parse; composer instantiates with `missing_modules` empty; **no**
`Invalid type in function 'generate'` or `Cannot convert argument 1 from int to C3TerrainData`
error. Any parse error → stop; restore only the files just edited from COORD's file-scoped
creation/backup ledger, never a blanket `git` restore (V11 §6 rule 3; V36 §7).

### 7.5 Behaviour smoke (after opt-in, still legacy default)

- Composer `stats`: `gen_applied=true`, `mesh_built=true`, `props_applied=true`
  (`terrain_donor_world.gd:311-313`). These mean "dispatched successfully", not parity.
- I08 `stats["source"]` reports `"explicit I06 data (additive fields)"`
  (`terrain_donor_mesh.gd:297,681`) — proves the Dictionary handoff actually ingested.
- `t_terrain_donor` produces non-empty streams for all five `STREAM_NAMES` at 64² and 240²
  (`t_terrain_donor.gd:77,380-388,757-758`); two runs at identical `(SEED, GEN_KEYS)` are
  byte-identical.
- `visual_parity_claim=false` everywhere (`world.gd:28/327`, `mesh.gd:13`, `props.gd:10`).
  Any "parity PASS" line is a defect, not a success.

---

## 8. Risks

| # | Risk | Label | Evidence / mitigation |
|---|---|---|---|
| R1 | Trees drifted mid-audit; line cites become stale | [O]/[U] MED | I07 `408→420`, I09 `198→210`, both hashes changed (§0 P3/P4/P10). Re-run §7.1 immediately before pasting. |
| R2 | Two owners touch one file during repair | [D] HIGH | Patches (a)-(c) are in COORD's N14; patch (d) is I12's N15. V11 §6 one-owner-per-file; COORD integrates. |
| R3 | `game.pattern_stamps` empty → no props, misread as a patch failure | [D] MED | `config.gd:62` relief opt-in defaults false; I09 records `NO_I07_STAMP_LIST` (`props.gd:240`). Do **not** synthesise stamps; empty is honest. |
| R4 | Seed→`randkey0/1` mapping is a port choice | PORT APPROX MED | `config.json:77` seed (test `:49`) mapped to donor-named words (`gen.gd:443-446`). Labelled in-code; no donor constant invented. |
| R5 | CoW violation if a callee writes to the handed `to_live()` Dictionary | [D] LOW | `data.gd:455-456,474` read-only contract; I08 duplicates typed arrays (`mesh.gd:221,248`). No write-back added. |
| R6 | Test patch depends on global `class_name C3TerrainData` | [U] LOW | `data.gd:29` declares it. If the class registry is stale, use an untyped `var data = data_script.new(size, size)` and rely on the runtime type in `callv`; do not weaken the assertion. |
| R7 | No parse/gate was run by V48 | [U] MED | §7.4/§7.5 are COORD-owned; static verdicts only. |
| R8 | Visual "improvement" reported as donor parity | [U]/PORT APPROX HIGH | CHARTER `:43-44,125`; no donor GPU A/B frame exists. Parity stays UNVERIFIED. |
| R9 | `gen_applied=true` misread as "generation produced streams" | [D] MED | `_call_adapt()` reports dispatch only (`world.gd:133-143`); I07 can abort early and return telemetry (`gen.gd:455-460,504`). Require the stream assertions in §7.5. |
| R10 | V36's non-API conflicts are wrongly considered resolved by this plan | [D] MED | Canonical shader now present and `assets/terrain_new/` untracked (EV14), but C7/I02-I03 write ownership, I01 `--check` and tautologies are untouched. Re-run V36 §6 step 0/1 after these patches. |

---

## 9. Open questions for COORD

1. **Q1.** Who is the single owner authorised to apply all four text patches? (a)-(c) are in
   COORD's I11-COMPOSER file; (d) is I12's file — V36 Q2 remains open.
2. **Q2.** Accept `to_live()` as the primary I08 handoff with `to_dump()` only as fallback?
   (V48 recommendation: yes — no base64 copy, exact key match at `mesh.gd:262-263,271-292`.)
3. **Q3.** Accept the labelled PORT APPROX mapping `randkey0/1 = SEED & 0xFFFFFFFF` in the test,
   or leave I07's own placeholder-0 note (`gen.gd:446`) and pass only `GEN_KEYS`?
4. **Q4.** Accept `game.pattern_stamps` as the composer's stamp source, or require stamps to come
   only from `I06.meta["pattern_stamps"]` (`props.gd:233-238`)? V48 recommends the former with the
   latter as I09's built-in fallback.
5. **Q5.** Keep the dead `run` fallback (`world.gd:218`) after patch (a), or retire it explicitly?
   V48 verified no `run` exists on I07 (P9).
6. **Q6.** May V36's checklist be re-run against a frozen tree after these patches to refresh all
   hashes and the V36 C2/C3/C4/C5 status? (V36 Q7/Q8 remain open.)
7. **Q7.** Should composer `stats` also surface I07/I09 stats (currently only I08 at
   `world.gd:300-305`)? V48 left this out of scope: it is telemetry only and changes no API break.

---

## 10. Handoff summary (5 lines)

1. **Verdict:** all four V36 hard API breaks confirmed on both sides after a second, post-drift read; all four are repairable caller-side with text-only, paste-ready patches in §3-§6.
2. **Current lines:** composer `:216/:224/:229-231` unchanged; I07 `generate` moved `408→420`; I09 `build` moved `198→210`; test hook `:343-345` unchanged — hashes pinned in §0 P10.
3. **Fixes:** pass `{Dictionary}` to I07; call I09 `build(Object, Array, Dictionary)` directly; hand I06 `to_live()`/`to_dump()` to I08; construct `C3TerrainData` in I12 and read streams from the container I07 mutates.
4. **Guards:** no donor constant, no new threshold, no deleted assertion, no stamp synthesis, no gate weakening; minimal callee-side adapters supplied but NOT recommended because they touch a second owner's file (V11 §6).
5. **Status:** V48 applied nothing and ran no Godot job, gate or capture; **no donor parity claim** — parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

*End of V48 report. Exactly one report written; no source, shader, asset, test, manifest, backup, git, runner, Godot, donor or `app/` state changed.*
