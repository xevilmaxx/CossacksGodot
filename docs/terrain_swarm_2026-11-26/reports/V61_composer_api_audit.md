---
id: V61
ticket: "TERRAIN-SWARM-2026-11-26 / V61 — re-audit of the four hard composer API breaks after owner corrections + shader rename"
agent: "V61 (read-only composer/API audit subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_BACKUP_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V61_composer_api_audit.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V61_composer_api_audit.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate, capture or git mutation was used by V61. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Nothing below is a gate result or a parity claim."
scope_guard: "Read-only: file reads, glob, grep, git read commands only. No .bak, source, shader, asset, test, manifest, config, queue, app/ byte or git state was changed. No patch is proposed: no API break remains at final read."
multiple_passes: true
snapshot: "Final read after V48 landed AND its four text patches were applied by COORD mid-audit. HEAD=e234ac9b. Hashes in §0 are the final values; earlier in-turn reads saw the pre-patch tree and are recorded as superseded passes."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V61 — composer API re-audit (a)–(f), FINAL current-state verdicts

## 0. Multiple-pass log — decisive re-reads (owner directive, CHARTER.md:85-93)

**Important:** the tree was volatile during this audit. The first reads (P3–P7)
saw the pre-patch tree and matched V36/V48's four BREAKs. Then
`V48_api_fix_plan.md` **landed**, and its four caller-side text patches were
applied by the owning agents (NOT by V61) before the final read. Every "no
break" verdict below comes from a second/third read of **both** sides after that
change; the earlier FAIL observations are recorded, not silently skipped.

| Pass | Instrument | Result | Effect on verdict |
|---|---|---|---|
| P1 | Full read `CHARTER.md`, `SWARM_BOARD.md`, `V36_integration_checklist.md`, `V11_ownership_ledger.md` | V36 §4 = four BREAKs (A4/A5/A6/A11-A12) + shader conflict C1 | Baseline claims to re-test, not inherit |
| P2 | `glob **/*V48*`, `glob **/*api_fix*`, `grep V48\|api_fix` | First sweep: no V48 file; `REPORT_INDEX.md:115` then said "No report file" | Later superseded — see P9 |
| P3 | Read composer full + `read :210-234` | Pre-patch: `:216` `generate(...,[_data, game])`, `:224` `bind(...,[_data])`, `:229` props `bind`, `:231` `build([])` | Four break candidates, pre-patch [O] |
| P4 | Read gen full (1062 lines) + `read :418-422,:500-506` + `grep ^func` | `generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary` at `:420`; returns `stats()` at `:504`; no `run`, no `generate_streams` | Callee contracts pinned |
| P5 | Read mesh full (831 lines) + `read :122-124,:196-213,:260-303,:718-722` | Dictionary-only `_first()`/`_ingest()`; `build()` gated on `_ingest()`; `bind(g,d=null)` untyped | Pre-patch (b) confirmed on 2nd read |
| P6 | Read props full (1022 lines) + `grep ^func (bind\|build)` | `build(Object, Array, Dictionary={})` at `:211`; **no `bind`** | Pre-patch (c) confirmed |
| P7 | Read test full (928 lines) + `read :298-311,:343-375,:43` | Pre-patch `_call_hook(...,[SEED, GEN_KEYS, size, size])`, `src = res` | Pre-patch (d) confirmed |
| P8 | `glob **/terrain_donor*.gdshader`; read shader; `grep DONOR_SHADER_PATH\|MODULE_SHADER`; seam greps + targeted reads of `main.gd`/`world3d.gd` | Canonical shader present, alias file absent; composer `:35`, mesh `:67`, test `:43` canonical; default `"legacy"`, both guarded setter sites | (e)/(f) PASS |
| P9 | `git status --short` sweep | **`V48_api_fix_plan.md` now on disk** (landed during audit), together with other late reports | P2 superseded; V48 read in full (519 lines) |
| P10 | `Get-FileHash` on six files; re-read composer `:200-254`, gen `:416-423`, props `:200-219`, test `:328-377`; `grep ^func ...` + composer call sites | Hashes differ from V48 §0 P10; composer now contains V48 patches (a)/(b)/(c), test contains patch (d); callees unchanged | **Verdicts upgraded from FAIL to PASS after re-reading both sides** |
| P11 | Re-read composer `:30-39,:148-161`, `main.gd:590-596,1109-1115` | Shader constants/seam guards unchanged; canonical wins at `:151` | (e)/(f) PASS re-confirmed |

Final SHA-256 (24 hex) at P10: composer `C98F34FE881B13E1C420237B…`,
gen `581205A5959AA6B406A39364…`, mesh `6AB8453AC9791B13099D814F…`
(= V48 value), props `C990F604F17B650E4F29F033…`, data `77D7BFA1CF59578CCBE953B2…`
(= V48 value), test `3BF7E5FBE95B8E485526B53A…`. HEAD `e234ac9b`.

**[O] No anomaly was silently skipped.** The pre-patch FAILs are preserved above;
the final PASSes in §1–§3 are from P10/P11, not from an unchanged tree.

---

## 1. Verdict summary (static [O]/[D]; no Godot parse, gate or run)

| # | Pair | FINAL verdict | Status vs V36 / V48 |
|---|---|---|---|
| (a) | composer → I07 `generate` argument type | **PASS** | repaired by V48 patch (a), applied mid-audit |
| (b) | composer → I08 ingest (`to_live()` vs Object) | **PASS** | repaired by V48 patch (c), applied mid-audit |
| (c) | composer → I09 method name | **PASS** | repaired by V48 patch (b), applied mid-audit |
| (d) | I12 → I07 `generate` signature/arity/return | **PASS** | repaired by V48 patch (d), applied mid-audit |
| (e) | canonical shader path in composer/mesh/test | **PASS** | rename landed; V36 C1 resolved |
| (f) | seam default `legacy` + both `make_world3d()` sites guarded | **PASS** | unchanged from V36 |

**[D] No API break remains on any of the six audited pairs at final read.**
**[U] This is a line-level static verdict only:** V61 ran no parse job, gate,
runner, capture or Godot process. It does **not** assert that generation produces
valid streams, that the mesh/props are visually correct, or that any gate is
green. Non-API data/telemetry caveats are in §5; parity stays UNVERIFIED.

V48 cross-check [O]: V48 §1 recorded all four breaks live at its 09:57:59
snapshot and supplied text-only caller-side patches in its §3–§6. Those patches
are now visibly present in the composer and test at final read; V61 did not
apply them and edited no source file.

---

## 2. Pair-by-pair evidence — exact CURRENT lines, both sides

### (a) composer → I07 `generate` argument type — **PASS**

Caller, `variant3d/scripts/terrain_donor_world.gd:219-223` (P10 re-read):

```gdscript
	if _gen != null and _data != null:
		var gen_params: Dictionary = {}
		_gen_applied = _call_adapt(_gen, "generate", [_data, gen_params])
		if not _gen_applied:
			_gen_applied = _call_adapt(_gen, "run", [_data, gen_params])
```

Adapter, `terrain_donor_world.gd:133-143` (unchanged):

```gdscript
func _call_adapt(obj, method: String, args: Array) -> bool:
	...
	var argc := _method_arg_count(target, method)
	if argc < 0 or argc > args.size():
		return false
	target.callv(method, args.slice(0, argc))
	return true
```

Callee, `variant3d/scripts/terrain_donor_gen.gd:420` (P4 + P10 re-read):

```gdscript
func generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary:
```

**[O]/[D] PASS:** `generate` declares argc 2; `_call_adapt` slices
`[_data, gen_params]` to those two arguments. `_data` is the I06
`C3TerrainData` Object (`world.gd:208-213`) and `gen_params` is a **Dictionary**,
so both declared types are satisfied. The `game` Object is no longer passed.
The `:223` `"run"` fallback is dead (no `run` on I07 — P4/P10) but inert, not a
break. `gen_params = {}` means decoded donor inputs are absent; I07 labels and
skips missing inputs (`gen.gd:443-446`) — a data-completeness caveat, not an API
break (§5 Q1).

### (b) composer → I08 ingest — **PASS**

Caller, `variant3d/scripts/terrain_donor_world.gd:234-241` (P10 re-read):

```gdscript
			var mesh_src: Variant = _data
			if _data != null and _data is Object and (_data as Object).has_method("to_live"):
				mesh_src = (_data as Object).call("to_live")
			elif _data != null and _data is Object and (_data as Object).has_method("to_dump"):
				mesh_src = (_data as Object).call("to_dump")
			target.callv("bind", [game, mesh_src])
```

Converter, `variant3d/scripts/terrain_donor_data.gd:456-464` (hash unchanged):

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
```

Callee, `variant3d/scripts/terrain_donor_mesh.gd:122-124`:

```gdscript
func bind(g, d = null) -> void:
	_game = g
	_data = d
```

Callee ingest preconditions, `terrain_donor_mesh.gd:196-201,204-213,260-266`:

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
			for k in keys:
				var v: Variant = (d as Dictionary).get(k, null)
				if v != null:
					return v
	return fallback
```

```gdscript
func _ingest() -> bool:
	var srcs := _candidate_sources()
	var w := int(_first(srcs, ["map_w", "w", "width"], 0))
	var h := int(_first(srcs, ["map_h", "h", "height_cells"], 0))
	if w <= 1 or h <= 1:
		return false
```

**[O]/[D] PASS:** the composer now hands I08 the Dictionary returned by I06's
own `to_live()` (fallback `to_dump()`), not the bare I06 Object. With a
Dictionary in the explicit `_data` slot, `_source_dicts()` returns `[dictionary]`,
`_first()` finds `w`/`h`, and `_ingest()` finds `height`/`tex` — exactly the
keys `to_live()` exposes (`:456-475`). I08's `bind(g, d=null)` is untyped, so no
signature change was needed. Mesh build order is unchanged: I07 mutates `_data`
at `:219-223` before the view is taken at `:234-238`.

### (c) composer → I09 method name — **PASS**

Caller, `variant3d/scripts/terrain_donor_world.gd:246-254` (P10 re-read):

```gdscript
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

Callee, `variant3d/scripts/terrain_donor_props.gd:211-217` (P6 + P10 re-read):

```gdscript
func build(p_container: Object, p_stamps: Array, p_options: Dictionary = {}) -> Dictionary:
	_container = p_container
	_stamps = p_stamps.duplicate(true)
	_terrain = p_options.get("terrain", null) as Object
	if p_options.has("lod_enabled"):
		_lod_enabled = bool(p_options["lod_enabled"])
	return rebuild()
```

**[O]/[D] PASS:** the caller uses I09's actual single entry point with the
declared three types: `_data` (Object), `stamps` (Array), `{"terrain": _mesh}`
(Dictionary). The nonexistent `bind()` is gone; `build([])` no longer occurs.
`_props_applied = pres is Dictionary` reflects `build()`'s declared return
(`props.gd:211,216,288`). Stamps are read from `game.pattern_stamps` (V48 EV12;
`game.gd:66`) or left empty — none are synthesised; I09's own
`container.meta["pattern_stamps"]` fallback at `props.gd:233-240` still applies.

### (d) I12 → I07 `generate` — **PASS**

Caller, `variant3d/tests/t_terrain_donor.gd:330-358` (P10 re-read; key lines):

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
...
	var settings: Dictionary = GEN_KEYS.duplicate(true)
	settings["randkey0"] = SEED & 0xFFFFFFFF
	settings["randkey1"] = SEED & 0xFFFFFFFF
	settings["width"] = size
	settings["height"] = size
	var res: Variant = _call_hook(g, ["generate"], [data, settings])
...
	var src: Variant = data
	var dump_v: Variant = _read_from(data, ["dump"])
	if dump_v is Dictionary:
		src = dump_v
```

Caller helper, `t_terrain_donor.gd:298-311`:

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

Callee, `terrain_donor_gen.gd:420` + `:504`:

```gdscript
func generate(data: C3TerrainData, p: Dictionary = {}) -> Dictionary:
...
	return stats()
```

**[O]/[D] PASS:** `_call_hook` truncates `[data, settings]` to argc 2 and calls
`generate(data, settings)` — container first, Dictionary second, both correct.
The former `int` first argument is gone. Because I07 writes streams into the
container but returns telemetry (`:504`), the caller now reads `src = data`;
`_read_from` (`t_terrain_donor.gd:283-295`) reads Objects via `Object.get()`, and
`_as_f32`/`_as_u8` (`:243-271`) accept the typed arrays that `C3TerrainData`
exposes at `terrain_donor_data.gd:127-153`. No downstream assertion was changed.

### (e) shader path canonical — **PASS**

Composer, `terrain_donor_world.gd:35-36,151`:

```gdscript
const DONOR_SHADER_PATH := "res://shaders/terrain_donor_shader.gdshader"  # I10 canonical
const DONOR_SHADER_ALIAS := "res://shaders/terrain_donor.gdshader"        # A06 N7 alias (labelled)
```

```gdscript
	for path in [DONOR_SHADER_PATH, DONOR_SHADER_ALIAS]:
```

Mesh, `terrain_donor_mesh.gd:67`, used at `:509-510,529`:

```gdscript
const DONOR_SHADER_PATH := "res://shaders/terrain_donor_shader.gdshader"  # I10, optional
```

```gdscript
	if ResourceLoader.exists(DONOR_SHADER_PATH):
		shader = load(DONOR_SHADER_PATH) as Shader
```

Test, `t_terrain_donor.gd:43`:

```gdscript
const MODULE_SHADER := "res://shaders/terrain_donor_shader.gdshader"  # I10 (V11 N13; V37 canonical rename)
```

On disk (P8/P11): `variant3d/shaders/terrain_donor_shader.gdshader` **exists**
(`shader_type spatial;` at `:1`); the alias `terrain_donor.gdshader` is **absent**.
**[O]/[D] PASS:** all three consumers use the canonical path and the file is
there. The composer's dead alias entry at `:36` is only a fallback that
`ResourceLoader.exists()` skips; canonical at `:151` wins. Cosmetic residue:
the shader's own comment at `terrain_donor_shader.gdshader:5` still names the old
alias path — comment text only, no path resolution effect. No edit made.

### (f) seam default `legacy` + both `make_world3d()` sites guarded — **PASS**

`variant3d/scripts/main.gd:125,188-191`:

```gdscript
var terrain_backend := "legacy"
```

```gdscript
	# I11-SEAM / V05 §4.2: opt-in terrain backend; unknown values coerce to legacy.
	terrain_backend = str(cfg.text("features.terrain.backend", "legacy")).to_lower()
	if terrain_backend != "donor":
		terrain_backend = "legacy"
```

`main.gd:591-595` and `:1110-1114` (P11 re-read):

```gdscript
	if render_mode == "3d":
		world = make_world3d()
		if world != null and world.has_method("set_terrain_backend"):
			world.set_terrain_backend(terrain_backend)
		world.bind(game)
```

```gdscript
	if render_mode == "3d":
		world = make_world3d()
		if world != null and world.has_method("set_terrain_backend"):
			world.set_terrain_backend(terrain_backend)
```

`variant3d/scripts/world3d.gd:117-118,143-145,220-224,624,645`:

```gdscript
# I11-SEAM / V05 §4.2: opt-in donor backend; legacy stays the default.
const TERRAIN_DONOR_SCRIPT := "res://scripts/terrain_donor_world.gd"
```

```gdscript
# I11-SEAM / V05 §4.2: backend switch — default legacy, opt-in donor only.
var terrain_backend := "legacy"
var _terrain_locked := false
```

```gdscript
func set_terrain_backend(mode: String) -> void:
	if _terrain_locked:
		push_error("world3d: terrain backend locked after bind()")
		return
	terrain_backend = "donor" if str(mode).to_lower() == "donor" else "legacy"
```

```gdscript
		terrain = _instantiate(TERRAIN_DONOR_SCRIPT if terrain_backend == "donor" else TERRAIN_SCRIPT)
```

```gdscript
		_terrain_locked = true
```

**[O]/[D] PASS:** default `"legacy"` on both sides; both `make_world3d()` sites
guard the setter with `world != null and world.has_method(...)`; both setter
calls precede `world.bind(game)` (`main.gd:595`, `:1114`) and `_terrain_locked`
is only set inside `world3d.bind()` (`:645`), so the switch is not refused.
Informational, outside (f): no `features.terrain.backend` key in
`config.gd`/`config.json` (V36 EV15), so opt-in still needs an override or a
direct `set_terrain_backend("donor")`.

---

## 3. Compatibility matrix (FINAL)

| # | Caller → callee | Caller site (current) | Callee contract (current) | Verdict |
|---|---|---|---|---|
| a | composer → I07 | `terrain_donor_world.gd:219-223` | `terrain_donor_gen.gd:420` `(C3TerrainData, Dictionary)` | **PASS** |
| b | composer → I08 | `terrain_donor_world.gd:234-241` | `terrain_donor_mesh.gd:122,196-213,260-266` + `data.gd:456` | **PASS** |
| c | composer → I09 | `terrain_donor_world.gd:246-254` | `terrain_donor_props.gd:211` `build(Object, Array, Dictionary)` | **PASS** |
| d | I12 → I07 | `t_terrain_donor.gd:330-358` | `terrain_donor_gen.gd:420,504` | **PASS** |
| e | composer/mesh/test → shader | `world.gd:35`, `mesh.gd:67`, `test:43` | canonical file on disk | **PASS** |
| f | `main.gd` → `world3d.gd` seam | `main.gd:125,189-191,592-595,1111-1114` | `world3d.gd:144,220-224,624,645` | **PASS** |

---

## 4. Patches

**None.** No caller-side patch is required: a second/third read of both sides of
all six pairs (P10/P11) found no remaining FAIL. V61 supplied no replacement
text because there is nothing to patch; proposing one against the final tree
would reintroduce a break. V48's §3–§6 patches are already present in the live
composer/test and were **not** applied by this worker.

---

## 5. Residual non-API caveats / open questions (NOT FAILs of (a)–(f))

1. **Q1 [D].** `gen_params = {}` (`world.gd:220`): I07 runs with default settings
   and labelled missing-input notes (`gen.gd:443-446`), not donor-validated
   decoded inputs. Pin `randkey0/1`, `mapsize`, `width/height`, `patterns`,
   `families` and tile dictionaries into that Dictionary before any A/B. API
   types are correct; data completeness is a separate question.
2. **Q2 [D].** `stamps` (`world.gd:249-252`) comes from `game.pattern_stamps` and
   may be empty; I09 then records `NO_I07_STAMP_LIST` (`props.gd:240`). Empty is
   honest — do not synthesise stamps or weaken this to fake a PASS.
3. **Q3 [PORT APPROX].** Test seed mapping `SEED & 0xFFFFFFFF` to
   `randkey0/randkey1` (`t_terrain_donor.gd:346-350`) is a port choice, labelled
   in V48 §6 R4; it adds no donor constant and parity stays UNVERIFIED.
4. **Q4 [D].** `_call_adapt` still reports `true` on dispatch-only success
   (`world.gd:133-143`) and does not inspect returned stats. Keep explicit
   `gen_applied` / `mesh_built` / `props_applied` stream assertions in COORD's
   smoke; `true` does not prove generation produced valid data.
5. **Q5 [U].** V61 ran no Godot parse, gate, runner or capture. V48 §7.4/§7.5
   remain COORD-owned. Out-of-scope V36 conflicts (I02/I03 write ownership, I01
   `--check`, tautologies, `face_promotion` synthesis-guard residue at
   `mesh.gd:660` vs `t_terrain_donor.gd:91-92`) were not re-adjudicated here.
6. **Q6 [U].** Tree volatility is real: gen/props/test/composer hashes drifted
   twice during this audit. Re-run V48 §7.1 hashes immediately before any gate.

---

## 6. Handoff summary (5 lines)

1. **Verdict:** all six audited pairs **PASS** at final read — (a)–(d) were
   repaired by V48 patches applied by their owners mid-audit (V61 saw and
   re-read both the pre-patch FAIL and post-patch PASS states); (e) and (f) were
   PASS throughout after the shader rename.
2. **Evidence:** exact current lines quoted in §2 from both sides; final hashes
   in §0; HEAD `e234ac9b`; V48 landed during the audit and was read in full.
3. **Patches:** none required — no FAIL remains, so no caller-side patch text is
   offered against the final tree.
4. **Scope:** line-level static verdict only; no parse, gate, capture or runner
   job; no proof that streams, mesh, props or gates are green.
5. **Guards:** read-only audit; no source, shader, asset, test, backup, git,
   runner, Godot, gate or donor state changed by V61; **no donor parity claim** —
   parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

*End of V61 report. Exactly one report written; no other file was created, edited or deleted.*
