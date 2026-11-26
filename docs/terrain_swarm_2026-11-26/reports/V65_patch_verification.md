---
id: V65
ticket: "TERRAIN-SWARM-2026-11-26 / V65 — read-only verification of COORD's four V48 caller-side patches"
agent: "V65 (read-only verification worker, DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_BACKUP_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V65_patch_verification.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V65_patch_verification.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate or capture was used by V65. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Every PASS below is a STATIC type/arity/contract verdict, not a gate result and not a parity claim."
scope_guard: "Only file reads, grep, git read commands and read-only PowerShell (Get-ChildItem/Get-Content/Get-FileHash/Select-String/Test-Path) were used. No .bak, source, shader, asset, test, manifest, config, queue, app/ byte or git state was changed."
multiple_passes: true
snapshot: "2026-11-26; HEAD=e234ac9b. gen.gd and props.gd hashes drifted again since V48's 09:57:59 snapshot; all cites below are from the CURRENT bytes read by V65."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V65 — verification of COORD's four applied V48 patches

## 0. Verdict in one line

**All four patches are present in the current bytes and all four are STATIC PASS on
type / arity / contract.** None of the four flagged new-bug risks (`_prop()` helper,
`stamps_v` type, `data_script.new(size,size)` signature, `C3TerrainData` class_name
resolution) materialised. **No new defect was introduced by the patches.** Verdicts
are static `[O]`/`[D]`; runtime parse, gate and determinism remain `[U]` and are
COORD-owned. **No donor parity claim.**

## 1. Multiple-pass log (owner directive, CHARTER.md:85-93)

No verdict was accepted from one reading; every call side was re-read on both sides
and re-checked after hash drift.

| Pass | Instrument | Result | Effect on verdict |
|---|---|---|---|
| P1 | `read` of all six target files | All four patch blocks visible in composer `:219-254` and test `:330-355` | Candidates located [O] |
| P2 | `grep` on gen/data/props/mesh/test for every `func` signature | gen `generate` still `:420`; props `build` now **`:211`** (V48 cited `:210`); data `_init :162`, `to_live :456`, `to_dump :563`; mesh `bind :122`, `_source_dicts :196`, `_ingest :260`, `build :718`; test `MODULE_DATA :37`, `as C3TerrainData :340` | Drift pinned; no contract change |
| P3 | PowerShell `Select-String` negative greps (V48 §7.2) | **0 hits** for all five broken old call forms | Old defects confirmed gone |
| P4 | PowerShell `Select-String` positive greps (V48 §7.3) | Exactly 1 hit each for the four patched call forms | Patches confirmed applied |
| P5 | `Get-FileHash` sweep vs V48 §0 P10 | world `0B3672D4…→C98F34FE…` and test `62540F29…→3BF7E5FB…` (patched); gen `FC0EE6AF…→0F6DB181…` and props `17BCC814…→C990F604…` (drifted again); mesh `6AB8453A…` and data `77D7BFA1…` **unchanged** | Drift recorded; gen/props contracts re-read, not assumed |
| P6 | `grep` for `func bind` / `func run` / `func generate_streams` | **No** `bind` in props, **no** `run` / `generate_streams` in gen (dead fallbacks stay inert) | No callee-side adapter appeared |
| P7 | `read` gen `:880-901` and `:1065-1086` | Container is actually mutated (`data.set_height(i,…)` `:894`, `data.set_tex(i,…)` `:1084-1086`) — patch (d)'s `src = data` has real streams | A12 half of patch (d) confirmed |
| P8 | `grep` `SIDE_U8_KEYS` + `read` data `:49-52`, `:456-475` | `relief_mask` is a `SIDE_U8_KEYS` member → present in `to_live()` | I08 ingest key satisfied |
| P9 | `git status/diff -- app/`, backup SHA re-read, seam greps | `app/` empty + diff exit 0; backups SHA-exact; seam still `legacy` | Invariants PASS |

**[O] No anomaly was silently skipped.** The two callee hashes that drifted again
(gen, props) were re-read on every relevant line; their published signatures are
unchanged.

## 2. Exact hashes at verification time (SHA-256, leading 8 hex)

| File | V48 §0 P10 | V65 current | Reading |
|---|---|---|---|
| `terrain_donor_world.gd` | `0B3672D4…` | `C98F34FE…` | changed — patch (a)/(b)/(c) applied |
| `terrain_donor_gen.gd` | `FC0EE6AF…` | `0F6DB181…` | drifted again; `generate` still `:420` |
| `terrain_donor_mesh.gd` | `6AB8453A…` | `6AB8453A…` | unchanged — callee untouched |
| `terrain_donor_props.gd` | `17BCC814…` | `C990F604…` | drifted again; `build` `:210→211`; still no `bind` |
| `terrain_donor_data.gd` | `77D7BFA1…` | `77D7BFA1…` | unchanged — converters untouched |
| `t_terrain_donor.gd` | `62540F29…` | `3BF7E5FB…` | changed — patch (d) applied |

## 3. Patch (a) — composer → I07: Dictionary instead of game Object

**Caller** `variant3d/scripts/terrain_donor_world.gd`, exact lines `:214-223`
(patch block is `:215-223`; quote includes the unchanged guard head):

```gdscript
	# I07: optional stage pipeline; never writes sim state or draws RNG.
	# V48 patch (a): I07's typed surface is generate(C3TerrainData, Dictionary)
	# (gen.gd:420). The game Object is NOT a settings Dictionary; decoded donor
	# inputs arrive in p. Empty p => missing inputs stay labelled/skipped,
	# never invented (gen.gd:400-419, :443-446). No gate, no parity claim.
	if _gen != null and _data != null:
		var gen_params: Dictionary = {}
		_gen_applied = _call_adapt(_gen, "generate", [_data, gen_params])
		if not _gen_applied:
			_gen_applied = _call_adapt(_gen, "run", [_data, gen_params])
```

**Callee** `variant3d/scripts/terrain_donor_gen.gd`, exact line `:420` plus the
input-channel lines `:443-450` (head `:400-419` documents `p` keys):

```gdscript
func generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary:
```
```gdscript
	_rng0 = int(p.get("randkey0", 0))
	_rng1 = int(p.get("randkey1", 0))
	if not p.has("randkey0") or not p.has("randkey1"):
		_note("randkey0/1 not supplied — PORT placeholder 0; TODO caller/COORD", "port_approximations")

	# Resolve grid. W,H live in the container, never in a global (spec/01 §2).
	var wv: int = int(p.get("width", p.get("size", 0)))
	var hv: int = int(p.get("height", 0))
```

**Dispatch mechanism** composer `_call_adapt` `:139-143` (re-read, unchanged):

```gdscript
	var argc := _method_arg_count(target, method)
	if argc < 0 or argc > args.size():
		return false
	target.callv(method, args.slice(0, argc))
	return true
```

**Verdict: STATIC PASS — type, arity, contract.**

- Type [O]: arg1 `_data` is the I06 `C3TerrainData` Object constructed in
  `bind()` `:185-195`; arg2 `gen_params` is declared `Dictionary`. Matches
  `(C3TerrainData, Dictionary = {})`.
- Arity [O]: `args = [_data, gen_params]` has 2 elements; `_method_arg_count`
  returns 2 for `generate`; `slice(0,2)` passes both. Default-parameter counting
  cannot drop the settings even if the scanner reports only the required arg —
  in that case `p` simply takes its declared `{}` default.
- Contract [D]: `{}` is I07's declared default; absent keys are handled by
  labelled skip/placeholder (`:445-446`, `:451-460`), never invented.
- **No new bug.** The `_data != null` guard is correctly retained. The `run`
  fallback is dead (P6: no `func run` in gen) but inert, exactly as V48 recorded.
- **[D] Honest limitation, not a patch defect:** `{}` supplies no donor settings,
  so seeds are the labelled PORT placeholder `0` and W/H fall back to
  `data.w/data.h` (`:451-454`). This fixes the type break but does **not** wire
  decoded donor inputs (masks/patterns/starts); that functional gap remains open
  (V38 F-V38-01, V48 R4/Q3) and is **PORT APPROXIMATION**, not parity.
- **[D] Telemetry caveat:** `_call_adapt` returns `true` unconditionally after
  `callv` (`:143`), so `gen_applied=true` means "dispatched", not "streams
  produced" (V48 R9). Stream assertions remain mandatory.

## 4. Patch (b) — composer → I09: direct `build(container, stamps, options)`

**Caller** `variant3d/scripts/terrain_donor_world.gd`, exact lines `:242-254`:

```gdscript
	# I09: optional, built after the mesh/height source is live.
	# V48 patch (b): I09 has no bind(); its single entry is
	# build(Object, Array, Dictionary) (props.gd:210), which binds
	# container/terrain itself (props.gd:211-213).
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

**Callee** `variant3d/scripts/terrain_donor_props.gd`, exact line `:211` (drifted
from V48's `:210`) and body `:212-217`, fallback `:233-241`, return `:288`:

```gdscript
func build(p_container: Object, p_stamps: Array, p_options: Dictionary = {}) -> Dictionary:
```
```gdscript
	_container = p_container
	_stamps = p_stamps.duplicate(true)
	_terrain = p_options.get("terrain", null) as Object
	if p_options.has("lod_enabled"):
		_lod_enabled = bool(p_options["lod_enabled"])
	return rebuild()
```
```gdscript
	if stamp_list.is_empty():
		_unverified.append("NO_I07_STAMP_LIST — build() got no stamps and I06 container carried none")
```
```gdscript
	return st.duplicate(true)
```

**Helper and source** `_prop()` at `world.gd:82-89` and `game.gd:66`:

```gdscript
func _prop(src, key: String):
	if src == null:
		return null
	if src is Dictionary:
		return (src as Dictionary).get(key, null)
	if src is Object:
		return (src as Object).get(key)
	return null
```
```gdscript
var pattern_stamps: Array = []
```

**Verdict: STATIC PASS — type, arity, contract.**

- Type [O]: arg1 `_data` is an Object; arg2 `stamps` is declared `Array`; arg3
  `{"terrain": _mesh}` is a Dictionary literal. Exact match to
  `(Object, Array, Dictionary = {})`. The `"terrain"` key is the one I09 reads
  (`:214`). Return is declared `Dictionary` (`:211`) and concretely returns
  `st.duplicate(true)` (`:288`), so `pres is Dictionary` is satisfiable.
- Arity [O]: `call` supplies exactly 3 arguments (P6 confirms `bind` does not
  exist, so no hidden arity path). I09 binds container/terrain itself
  (`:212-214`) — the deleted `bind` step was redundant.
- **Flag check `_prop()` helper existence: PASS — no new bug.** Present at
  `:82-89`, unchanged by the patch, handles Object/Dictionary/null.
- **Flag check `stamps_v` type: PASS — no new bug.** Declared `Variant` and
  guarded by `is Array` before the `as Array` cast. The only source is
  `game.pattern_stamps`, declared typed `Array` at `game.gd:66` (P2/P3), so the
  guard admits it. If empty, I09's documented fallback reads
  `container.meta["pattern_stamps"]` (`:234-239`) and otherwise records
  `NO_I07_STAMP_LIST` (`:240-241`). **No stamp is synthesised.**
- **No new bug.** Minor robustness note (not a defect): unlike patch (a), this
  block has no explicit `_data != null` guard; `null` is a legal value for a
  typed `Object` parameter and `rebuild()` checks `_container != null` (`:234`),
  so there is no parse/runtime error — only a possible empty stamp list,
  honestly labelled.
- Callee drift [O]: props hash `17BCC814…→C990F604…` and `build` moved
  `:210→:211` after V48; signature, 3-arg contract and absence of `bind` were
  re-verified on the current bytes (P2/P6).

## 5. Patch (c) — composer → I08: I06 `to_live()`/`to_dump()` Dictionary

**Caller** `variant3d/scripts/terrain_donor_world.gd`, exact lines `:224-241`
(patch block `:229-239`):

```gdscript
	# I08: the known contract — bind(game, data), build() -> bool, ONE mesh.
	var mesh_ok := false
	if _mesh != null and _mesh is Object:
		var target: Object = _mesh as Object
		if target.has_method("bind"):
			# V48 patch (c): I08's ingest is Dictionary-only (mesh.gd:196-213);
			# an I06 Object carries no `fields` and is skipped. Hand over I06's
			# read-only live view (data.gd:456-475), or the byte snapshot
			# (data.gd:563-592) as fallback. Typed arrays, no base64 copy on the
			# live path, no sim write, no new constant, no parity claim.
			var mesh_src: Variant = _data
			if _data != null and _data is Object and (_data as Object).has_method("to_live"):
				mesh_src = (_data as Object).call("to_live")
			elif _data != null and _data is Object and (_data as Object).has_method("to_dump"):
				mesh_src = (_data as Object).call("to_dump")
			target.callv("bind", [game, mesh_src])
```

**Callee** `variant3d/scripts/terrain_donor_mesh.gd`, exact lines `:122-124`,
`:196-213`, `:260-265`, `:718-722` (file hash unchanged from V48 — untouched):

```gdscript
func bind(g, d = null) -> void:
	_game = g
	_data = d
```
```gdscript
func _source_dicts(src) -> Array:
	var out: Array = [src]
	var f = _get_prop(src, "fields")
	if f is Dictionary:
		out.append(f as Dictionary)   # additive fields are always secondary
	return out
```
```gdscript
func _first(srcs: Array, keys: Array, fallback: Variant = null) -> Variant:
	for src in srcs:
		for d in _source_dicts(src):
			if not (d is Dictionary):
				continue
```
```gdscript
func _ingest() -> bool:
	var srcs := _candidate_sources()
	var w := int(_first(srcs, ["map_w", "w", "width"], 0))
	var h := int(_first(srcs, ["map_h", "h", "height_cells"], 0))
	if w <= 1 or h <= 1:
		return false
```
```gdscript
func build() -> bool:
	invalidate()
	if not _ingest():
		push_error("terrain_donor_mesh: bind() an I06 container / height dump first")
		return false
```

**Converters** `variant3d/scripts/terrain_donor_data.gd`, exact lines `:456-475`
and `:563-569` (hash unchanged from V48 — untouched):

```gdscript
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
```
```gdscript
func to_dump() -> Dictionary:
	var d: Dictionary = {
		"map_w": w,
		"map_h": h,
		"height": _encode_f32(height),
		"tileblock": _encode_u8(tex),
	}
```

**Verdict: STATIC PASS — type, arity, contract.**

- Type [O]: both converters declare `-> Dictionary`; `mesh_src` therefore holds
  a Dictionary on the live path and on the dump fallback. `bind(g, d=null)` is
  untyped, so `callv("bind", [game, mesh_src])` with 2 args is arity-correct.
- Contract [O]: `to_live()` exposes `w/h/height/tex/collision` plus all side keys;
  `SIDE_U8_KEYS` includes `relief_mask` (`data.gd:49-50`, P8), which is the key
  I08 reads at `mesh.gd:287`. `_first` finds `w/h` at `:262-263`; `_ingest`
  finds `height` at `:271-272`. The fallback `to_dump()` provides the
  `map_w/map_h` + base64 keys that I08's `_as_float_array`/`_as_byte_array`
  handle. Typed arrays are duplicated on ingest (`mesh.gd:277-280`), preserving
  I06's CoW read-only contract (`:455`).
- **No new bug.** If a hypothetical I06 lacked both methods, `mesh_src` would
  remain the old Object — identical to pre-patch behaviour, so no regression.
  The converter methods exist and are verified (P2/P8), so the live path is
  taken. No callee file was edited by this patch.

## 6. Patch (d) — I12 test → I07: `C3TerrainData` + settings Dictionary

**Caller** `variant3d/tests/t_terrain_donor.gd`, exact lines `:330-358` (patch
block `:331-358`; downstream `:359-381` unchanged):

```gdscript
func _generate_streams(size: int) -> Dictionary:
	# V48 patch (d): I07's only generation entry is
	# generate(C3TerrainData, Dictionary) (terrain_donor_gen.gd:420). It returns
	# telemetry; the streams are written into the container (gen.gd:890, :1073).
	# No arity truncation, no int-as-container, no assertion weakened.
	var script := load(MODULE_GEN) as Script
	var data_script := load(MODULE_DATA) as Script
	if script == null or data_script == null or not script.can_instantiate():
		return {}
	var g: Object = script.new()
	var data := data_script.new(size, size) as C3TerrainData
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
```

**Callee / supporting declarations**, exact lines:

`variant3d/tests/t_terrain_donor.gd:37` and `:298-311`:

```gdscript
const MODULE_DATA := "res://scripts/terrain_donor_data.gd"
```
```gdscript
func _call_hook(obj: Object, names: Array, default_args: Array) -> Variant:
	var ml := obj.get_method_list()
	for nm in names:
		for m in ml:
			if str(m.get("name", "")) == str(nm):
				var args_def := m.get("args", [])
				var argc: int = 0
				if args_def is Array:
					argc = (args_def as Array).size()
				var args: Array = []
				for i in range(argc):
					args.append(default_args[i] if i < default_args.size() else null)
				return obj.callv(str(nm), args)
	return null
```

`variant3d/scripts/terrain_donor_data.gd:29` and `:162-164`:

```gdscript
class_name C3TerrainData
```
```gdscript
func _init(width: int = 0, height_cells: int = 0) -> void:
	if width > 0 and height_cells > 0:
		configure_grid(width, height_cells)
```

`variant3d/scripts/terrain_donor_gen.gd:420` (same callee as patch (a)) and the
container writes at `:894` / `:1084-1086`:

```gdscript
func generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary:
```
```gdscript
		data.set_height(i, hwater + hterrain)       # D2:574; I06 setter
```
```gdscript
				data.set_tex(i, 255)   # I06 PORT-ONLY sentinel — PORT APPROX, no donor id
			elif id_of.has(tname):
				data.set_tex(i, int(id_of[tname]))
```

**Verdict: STATIC PASS — type, arity, contract (runtime `[U]`).**

- **Flag check `MODULE_DATA` constant: PASS — no new bug.** Declared at test
  `:37`, loaded at `:336`; the `data_script == null` guard prevents a bad cast.
- **Flag check `data_script.new(size,size)` constructor signature in I06:
  PASS — no new bug.** `_init(width: int = 0, height_cells: int = 0)` at
  `data.gd:162-164` accepts exactly 2 ints and calls `configure_grid`, which
  sizes every array (`:170-179`). `size` is 64 or 240 (`SIZES :60`), within the
  `640` cap (`:171`).
- **Flag check `C3TerrainData` class_name resolution in test scope: STATIC
  PASS / runtime `[U]`.** `class_name C3TerrainData` is declared at
  `data.gd:29` and the test uses `as C3TerrainData` at `:340`; both resolve to
  the same project script. This depends on Godot's global class cache having
  scanned `data.gd` before the atom runs — V48 R6's residual `[U]`, to be
  settled only by COORD's parse job. **No static bug**; do not weaken the
  annotation or the assertion to work around a stale cache.
- Arity [O]: `_call_hook` slices to the discovered method's arg count; for
  `generate` that is 2 → `[data, settings]`, exactly the declared arity; the
  old `(int, Dictionary, int, int)` form is gone (P3: 0 hits).
- Contract [O]: `src = data` reads the streams I07 actually mutates
  (`set_height :894`, `set_tex :1084-1086`, `data.meta` writes at
  `:495-503` etc.). `_read_from` accepts Objects via `Object.get` (`:289-294`),
  `_as_f32`/`_as_u8` accept `PackedFloat32Array`/`PackedByteArray` (`:243-271`),
  so all five `STREAM_NAMES` (`:77`) are sourced without touching a downstream
  assertion. `GEN_KEYS.duplicate(true)` preserves the pinned-key manifest;
  `randkey0/1 = SEED & 0xFFFFFFFF` is labelled **PORT APPROXIMATION** and
  introduces no donor constant.
- **No new bug.** Pre-existing, not patch-introduced: `SIZES := [64, 240]` and
  `RUN_320_OPTIONAL := false` at `:60-61` still omit the hard 320² size
  (V38 F-V38-04). Test hash drift `62540F29…→3BF7E5FB…` is consistent with
  patch (d) alone.

## 7. New-bug scan — consolidated

| Flagged risk | Result | Evidence |
|---|---|---|
| `_prop()` helper existence | **PASS — no bug** | `world.gd:82-89`, unchanged by patch (b) |
| `stamps_v` type | **PASS — no bug** | `Variant` + `is Array` guard at `world.gd:250-252`; source `game.gd:66` typed `Array` |
| `data_script.new(size,size)` signature in I06 | **PASS — no bug** | `data.gd:162-164` `_init(width, height_cells)` |
| `C3TerrainData` class_name in test scope | **STATIC PASS; runtime `[U]`** | `data.gd:29` declares it; test `:340` casts to it; parse pending (V48 R6) |
| New donor constant / threshold / assertion deletion | **None found** | Only labelled bitmask `0xFFFFFFFF` + donor-named `p` keys already declared at `gen.gd:400-419`; no gate line removed in the four patch blocks |
| Stamp synthesis | **None found** | `stamps` defaults `[]`; I09 fallback + `NO_I07_STAMP_LIST` at `props.gd:234-241` |
| Parity claim introduced | **None found** | `visual_parity_claim: bool = false` intact at `world.gd:28`; in-code comments say "no parity claim" |
| Second owner's callee file edited | **None found** | `mesh.gd` and `data.gd` hashes identical to V48; gen/props drift is pre-existing worker activity, not a patch edit by V65 |

## 8. Invariant re-checks (all PASS)

| Check | Result | Exact evidence |
|---|---|---|
| `MODULE_DATA` constant in test | **PASS** | `t_terrain_donor.gd:37` `const MODULE_DATA := "res://scripts/terrain_donor_data.gd"`; used `:336` |
| Shader canonical path referenced everywhere | **PASS (with labelled alias)** | canonical `terrain_donor_shader.gdshader` at `world.gd:13,35`, `mesh.gd:67,509-510,529,562`, `t_terrain_donor.gd:43`, `terrain_qa_harness.py:187`. Alias `world.gd:36` and `:151` is explicitly labelled "A06 N7 alias"; alias file **absent** (`Test-Path False`), canonical **present** (`True`) → alias loop is inert. **[O] Non-blocking residue, not patch-introduced:** the canonical shader's own header comment `terrain_donor_shader.gdshader:5` still names the retired alias as "Owner file"; cosmetic, leave to shader owner. |
| Seam still default legacy | **PASS** | `main.gd:125` `var terrain_backend := "legacy"`; `:189-191` config read with `"legacy"` default + coercion; setters `:593-594` and `:1112-1113` before `bind()`. `world3d.gd:144` `var terrain_backend := "legacy"`, `:220-224` setter coerces to legacy, `:624` ternary, `:645` `_terrain_locked=true`. |
| `app/**` clean | **PASS** | `git status --short -- app/` and `--untracked-files=all -- app/` both empty; `git diff --exit-code -- app/` exit `0`. |
| Backups intact | **PASS** | `inbox/backup/main.gd.bak-COORD-I11` = `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8`; `inbox/backup/world3d.gd.bak-COORD-I11` = `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` — both exactly the V11 E1/E2 baselines (V36 §1.2, V38 §7). |
| HEAD | **PASS (pinned)** | `e234ac9b` |

## 9. What V65 did NOT verify — open for COORD

1. **[U] No Godot parse / runner job / gate / capture was run.** All PASS verdicts
   are static; the `class_name` cache question (§6) and every runtime behaviour
   need COORD's single parse job (V48 §7.4) and behaviour smoke (V48 §7.5).
2. **[D] Patch (a) passes `{}` — generation is contract-correct but receives no
   donor inputs** (seeds labelled PORT placeholder 0, W/H from container). Decoded
   settings wiring remains open (V48 Q3, V38 F-V38-01).
3. **[U] `_call_adapt` still reports dispatch, not success** (`world.gd:143`).
   Require stream assertions, not just `gen_applied=true` (V48 R9).
4. **[D] Pre-existing conflicts untouched by these patches:** 320² omission
   (V38 F-V38-04), V28 F-01 ownership, masked-overlay base-layer risk
   (V38 F-V38-05), config-driven opt-in hook (V36 A17). Do not read this report
   as resolving them.
5. **[U] PARITY:** no matched-seed donor GPU A/B frame exists. **No donor parity
   claim**; parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

## 10. Handoff summary (5 lines)

1. **Verdict:** all four V48 caller-side patches are applied in the current bytes;
   each is a **static PASS** on type, arity and contract — (a) Dictionary to
   `generate`, (b) `build(_data, stamps, {terrain:_mesh})`, (c) `to_live()`/`to_dump()`
   Dictionary to I08, (d) `C3TerrainData` + settings in the atom.
2. **New bugs:** **none introduced.** All four flagged risks checked and cleared:
   `_prop()` exists (`:82-89`), `stamps_v` is Variant + `is Array` guarded,
   I06 `_init(size,size)` matches, `class_name C3TerrainData` resolves statically
   (runtime `[U]` pending parse).
3. **Callees:** `generate` still `gen.gd:420`; props `build` drifted `:210→:211`
   with no `bind`; mesh/data hashes unchanged; gen writes container streams at
   `:894/:1084-1086`, so `src = data` is well-founded.
4. **Invariants:** `MODULE_DATA :37` present; canonical shader path used everywhere
   (alias inert/absent); seam default still `legacy`; `app/**` diff exit 0;
   both `COORD-I11` backups SHA-exact; HEAD `e234ac9b`.
5. **Guards:** read-only, multiple passes (P1-P9), no source/shader/asset/test/
   backup/git/runner/Godot/donor state changed; **no gate result and NO DONOR
   PARITY CLAIM — parity UNVERIFIED / PORT APPROXIMATION.**

*End of V65 report. Exactly one report written; no other file was created, edited or deleted.*
