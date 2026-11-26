---
id: V38
ticket: "TERRAIN-SWARM-2026-11-26 / V38 — round-2 code review of newly landed implementation files"
agent: "V38 (review-only subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__REVIEW_ONLY__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V38_code_review_r2.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V38_code_review_r2.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate result or capture was used by V38. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). This is a static review, not a PASS or a parity claim."
scope_guard: "Only file reads and read-only PowerShell (Test-Path, Get-ChildItem, Get-Item, Get-FileHash, Select-String, git status/diff --no-index/numstat/ls-files, ConvertFrom-Json) were used. No .bak, source, shader, asset, test, manifest, queue, git state, app/ byte or Godot job was changed."
multiple_passes: true
snapshot_note: "Files were landing DURING this review. Presence and SHA-256 below are from the FINAL snapshot; earlier transient states are recorded in §2 so no anomaly was accepted after one reading."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V38 — round-2 code review (implementation files)

## 1. Executive summary

1. **[O] Snapshot:** 13 of 16 V11 NEW source/tool/test rows are present at the exact canonical paths plus N17 `spec/terrain_qa_spec.json`. **ABSENT (worker running, not a defect):** N6 `build_terrain_new_manifest.py`, N7 `validate_terrain_new.py`, N10 `terrain_donor_tiles.gd`; all G1–G11 derived assets under `variant3d/assets/terrain_new/**` are also absent (tools default to dry-run). N13's shader **was** transiently at the retired A06 alias `terrain_donor.gdshader` early in this review and was renamed to canonical `variant3d/shaders/terrain_donor_shader.gdshader` (SHA `BB31B1EB…`) by the final snapshot — final state OK.
2. **[D] Six R2 findings need COORD/owner attention** before any donor-backend capture: three cross-module call mismatches (composer→gen, composer→props, test atom→gen), the omitted 320² hard determinism size, a masked-overlay-without-opaque-base rendering risk, and V28 F-01's ownership collision still open. No BLOCKER in the default-legacy path; the opt-in donor path is partially inert until the call mismatches are fixed.
3. **[D] V28/V33 MAJOR findings F-02 (`DONOR_UNITS=160`) and F-03 (permanently red `--check`) are RESOLVED** in the current bytes; V33's exact scan now reports **4 hits, all benign** (no live D14 hit). V28 F-01 and MINOR F-05/F-04(partial)/F-12 persist. Full disposition in §5.
4. **[O] Seam is clean and additive:** `main.gd` 9 insertions / 0 deletions, both `make_world3d()` sites guarded, default `legacy`; `world3d.gd` 20 insertions / 1 line substituted (the documented `:609` ternary), no behaviour removed, `_terrain_locked` refuses a late switch. Both `COORD-I11` backups exist with the exact V11 E1/E2 SHAs. `app/**` and all absolute-freeze files are byte-unchanged. **[U]** No gate was run.
5. **[U]/PORT APPROXIMATION** No donor parity claim: no donor frame, Godot process or gate was used by V38. Parity remains UNVERIFIED; all port choices remain PORT APPROXIMATION (CHARTER.md:43-44,125).

## 2. Evidence table / multiple-pass log

Labels: **[O]** literal read, **[D]** deterministic consequence of [O], **[I]** inference, **[U]** UNVERIFIED, **PORT APPROXIMATION** for port substitutes. SHA-256 is of working-tree bytes (PowerShell `Get-FileHash -Algorithm SHA256`); `core.autocrlf=true`, so git blob ids are not quoted as equal.

| Pass | Instrument | Result / effect on verdict |
|---|---|---|
| P1 | `git status --short`, `Test-Path` over all N/G paths | Initial tree: V33/V28 ABSENT, shader at A06 alias `terrain_donor.gdshader`, derived assets absent. No anomaly accepted yet. |
| P2 | `git diff --no-index` of both seam files vs `COORD-I11` backups; `--numstat` | `main.gd` 9/0; `world3d.gd` 20/1 (the one deletion is the ternary substitution). Re-run in P7 — identical. |
| P3 | API grep of all `terrain_donor_*.gd` | Composer calls `props.bind` (absent) and `gen.generate(_data, game)` (p: Dictionary); test calls `generate(SEED, GEN_KEYS)`. Recorded as suspected MAJOR, not yet final. |
| P4 | V33 exact §4 snippet, first run | 4 hits — the two live D14 `DONOR_UNITS` hits V33/V28 reported had already disappeared. Re-ran in P8: identical. |
| P5 | `Get-FileHash` sweep at three points during review | `gen.gd`, `props.gd`, `t_terrain_donor.gd` and all 6 Python tools changed hash mid-review; e.g. gen `A31BCBA1… → 4D8F08EF… → BB137A8B… → 187954A3…`, props `59E7EA7F… → 30AB291F… → 4832272A… → 33BEBDCF…`. Every finding below was re-checked at the FINAL hash, not accepted from P3. |
| P6 | V33 and V28 reports landed mid-review; full read of both | V33's §4 snippet and V28 R1 findings adopted verbatim where still applicable; V28's F-02/F-03 re-tested against current bytes (resolved). |
| P7 | Second `git diff --no-index --numstat`, backup SHA re-read, `git status --short -- app/` | Seam numbers stable; backups match V11 E1/E2 exactly; `app/` empty in tracked and untracked views. |
| P8 | V33 snippet re-run + targeted greps for `DONOR_UNITS`, `family_index`, `C01`, tautologies, class_name, 320² | Same 4 benign hits; confirmed F-02/F-03/F-06 resolved, F-01/F-04(partial)/F-05/F-12 persist. |

**[O] No anomaly was silently skipped.** Apparent defects withdrawn after a second instrument: (a) alias shader path — renamed to canonical before final snapshot; (b) V33's live D14 hit — removed by owner before final snapshot; (c) "permanently red `--check`" — C01 now validates against the observed 19. All three are reported as RESOLVED, not as defects.

### 2.1 Final file inventory (SHA-256 of working-tree bytes)

| V11 row | Exact canonical path | State | SHA-256 (final) | Bytes |
|---|---|---|---|---|
| N1 | `variant3d/tools/decode_donor_cfg.py` | PRESENT | `ABBF0571647F318E1D88F3B1032EB1E39CA887AFA9C671D348338EF50D85AB0E` | 37,682 |
| N2 | `variant3d/tools/decode_donor_pattern.py` | PRESENT | `F710FD0D2FCEDFAC9026F9ADF801A88A3A3F864D9EB9E182EA31693A35E8FA9C` | 42,025 |
| N3 | `variant3d/tools/decode_pattern_lib.py` | PRESENT | `E594E24CE54F3BC260D31510AB47376391107F9AAF13B5E6386639B2FA8E6140` | 51,324 |
| N4 | `variant3d/tools/decode_donor_masks.py` | PRESENT | `22753AE75E187E8E4D2297C6954A8AB1EA025C7B6AE8BBC49661BD1B4E4D0602` | 27,979 |
| N5 | `variant3d/tools/build_terrain_new_atlas.py` | PRESENT | `3A92D053A3E361001FC305F0DBD98681702BA756124566D4408BBCFDA99904FF` | 44,759 |
| N6 | `variant3d/tools/build_terrain_new_manifest.py` | **ABSENT (worker running)** | — | — |
| N7 | `variant3d/tools/validate_terrain_new.py` | **ABSENT (worker running)** | — | — |
| N16 | `variant3d/tools/terrain_qa_harness.py` | PRESENT | `5A3B9E772F0BE82330F4A0E6F42D4E1B36909815A3E79ECABA9F6E311C5D8492` | 61,675 |
| N8 | `variant3d/scripts/terrain_donor_data.gd` | PRESENT | `77D7BFA1CF59578CCBE953B2D69B6512D6C7CDFE3015DE3CCC9FA5D172C18AC4` | 25,557 |
| N9 | `variant3d/scripts/terrain_donor_gen.gd` | PRESENT | `187954A39A5E4B052F7641F96EE2E52EBC933A02CC1DF3DC67CA0743212A31B2` | 90,434 |
| N10 | `variant3d/scripts/terrain_donor_tiles.gd` | **ABSENT (worker running)** | — | — |
| N11 | `variant3d/scripts/terrain_donor_mesh.gd` | PRESENT | `6AB8453AC9791B13099D814F3792B1C9E9886D897AB646D1DFDFF7F8B63C946B` | 33,704 |
| N12 | `variant3d/scripts/terrain_donor_props.gd` | PRESENT | `33BEBDCF08D675CEBDE7C04C8D2D021D0CDB75287C5D11B5F20A0AFCEDE5EE1A` | 43,617 |
| N13 | `variant3d/shaders/terrain_donor_shader.gdshader` | PRESENT (renamed from alias during review) | `BB31B1EB03829B232040EB3DAE1B19A4B8E21EF82E75DB8A7F92F7051AC3E701` | 18,833 |
| N14 | `variant3d/scripts/terrain_donor_world.gd` | PRESENT | `0B3672D4719F78165255976148966D44280E01BD720D59A00C72382F0BC46310` | 13,834 |
| N15 | `variant3d/tests/t_terrain_donor.gd` | PRESENT | `62540F29E1C5BD03F03EDDBBE0D9BC391AAADCD2FF6589FBF4A7B366F67E965C` | 35,944 |
| N17 | `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | PRESENT | `4D1BFE226FB80B796E09EB520C95317D3DCB884419887F8690D3297A381B8617` | 5,913 |

**[O] Retired alias `variant3d/shaders/terrain_donor.gdshader` is ABSENT at the final snapshot; V11 CR5 canonical path now holds.** **[O]** N18 is only `inbox/qa/terrain_qa_report.json.PENDING` plus `PENDING_*` notes — no generated report yet, as expected for stage D. **[O]** Every implementation file above is **untracked** (`git ls-files --error-unmatch` returns "did not match any file(s) known to git") — one file, one owner, no cross-file edit recorded.

## 3. Per-file review

Verdict key: **BLOCKER** = must not land / would red a hard gate; **MAJOR** = must be fixed or explicitly adjudicated before donor-backend capture; **MINOR** = repair or note; **OK** = no R2 defect observed; **ABSENT** = worker still running.

### 3.1 `variant3d/scripts/terrain_donor_world.gd` (N14, I11-COMPOSER) — MAJOR ×2, MINOR ×1

- **[O] Owner path:** exact V11 N14 ✓. Const paths at `:31-36` are N8/N9/N11/N12/N13 exact; parity guard `visual_parity_claim: bool = false` at `:28` ✓.
- **[O] Module loading** `_load_module()` `:106-119` uses `ResourceLoader.exists` + `can_instantiate`, records `_missing`, never raises; `_call_adapt()` `:133-143` checks `has_method` and arity but **ignores the call result** and returns `true` at `:143`.
- **[MAJOR] F-V38-01 — composer→gen has the wrong second-argument type and can report a false success.** `world.gd:216` passes `[_data, game]` to `gen.generate`; `terrain_donor_gen.gd:408` declares `generate(data: C3TerrainData, p: Dictionary = {})`. [D] At runtime Godot rejects `Object → Dictionary` on argument 2; the method does not run, yet `_call_adapt` returns `true`, so `_gen_applied` and stats `"gen_applied": true` (`:306`) are misleading. The fallback at `:218` targets `run`, which I07 does not define (API grep over all donor modules). **Fix:** build the `p: Dictionary` from game/cfg (`randkey0/randkey1`, `width`, `height`, masks, starts, patterns, tile maps) and call `_call_adapt(_gen, "generate", [_data, p])`; make `_call_adapt` capture and return the call result instead of unconditionally `true`.
- **[MAJOR] F-V38-02 — composer never builds I09 props.** `world.gd:229` calls `_call_adapt(_props, "bind", [game, _data, _mesh])`, but `terrain_donor_props.gd` has **no `bind` method** (its declared I11 surface at `:189-196` is `build(container, stamps, options)`; actual definition at `:210`). `_call_adapt` therefore returns `false` at `:137-138`; the guarded `build` at `:231` never runs, and even if it did, `build` needs 3 args while `[]` is passed (arity guard `:140` refuses). `props._ready()` `:195-196` only sets `UNBUILT`. [D] With `terrain_backend="donor"` no forests, mines, fields or mountain props are instantiated; `stats["props_applied"]` stays `false`. **Fix:** replace `:229-231` with `_props_applied = _call_adapt(_props, "build", [game, stamps, {"terrain": _mesh}])`, taking `stamps` from the container's `meta["pattern_stamps"]` or the generated `data.meta` (I07 writes it); keep the optional-module guard.
- **[MINOR] F-V38-09 — stale comment:** `:30` says "no class_name anywhere", but `terrain_donor_data.gd:29`, `terrain_donor_gen.gd:51`, `terrain_donor_props.gd:41` each declare a distinct `class_name` (V28 F-12). **Fix:** correct the comment to "three distinct global classes; no duplicate".
- **[OK]** Shader path `:35` now resolves (`terrain_donor_shader.gdshader` present); fallback alias `:36` is labelled. `bind()` `:182-193`, `height_at_world()` `:246-249`, `invalidate()` `:238-244` are read-only. Composer `invalidate()` calls `invalidate` on gen and props, which do not define it — harmless best-effort no-op (MINOR telemetry note, not a defect).
- **[OK]** `_call_adapt` on `_data.from_live_object`/`configure_grid` (`:192,:213`) matches `data.gd:411/:170` signatures. Mesh `bind(game, _data)`/`build()` at `:224-226` matches `mesh.gd:122/:718` ✓.

### 3.2 `variant3d/scripts/terrain_donor_gen.gd` (N9, I07) — OK own-file, MAJOR at the test seam

- **[O] Owner path:** exact V11 N9 ✓; global class `C3TerrainDonorGen` at `:51`. Head `:375-399` documents the `p` Dictionary contract and donor citations; `generate(data: C3TerrainData, p: Dictionary = {})` at `:408`; stage order `_stage_init → _stage_clear → … → _stage_finalize` at `:451-462` matches spec/10 §1; RNG ledger seeded by `p.randkey0/randkey1` at `:431-434` with an explicit PORT-placeholder note when absent ✓.
- **[OK]** No face promotion or synthetic field in reviewed sections; relief only feeds height (consistent with V33 D01/D02/D03). The telemetry string at `:689` "MAP CELLS 1:1 … no DONOR_UNITS scaling" is V33's benign P4 hit and must be preserved.
- **[MAJOR] F-V38-03 (shared with N15):** the published signature is not the one the atom calls — see §3.6. **Fix:** either add a typed adapter `generate_streams(seed:int, keys:Dictionary, w:int, h:int) -> Dictionary` that builds the container and `p`, or fix the atom. No gen-internal edit is required if the atom is fixed.

### 3.3 `variant3d/scripts/terrain_donor_mesh.gd` (N11, I08) — OK / one [I] rendering risk

- **[O] Owner path:** exact V11 N11 ✓; no global class; API `bind` `:122`, `height_at_world` `:132`, `set_atlas_mode` `:153`, `set_season` `:159`, `build` `:718`, `invalidate` `:801`, `get_mesh` `:822`, `get_water_node` `:826`, `is_built` `:830`. Collaborator signatures (`tile_atlas_loader.gd`, `water3d.gd`) were independently verified by V28 P6 and are unchanged here.
- **[OK]** `HEIGHT_SCALE` is the labelled 1.0 contract (`:42`, used at `:748`); relief cells force face 0 (`:762-765`); one `ArrayMesh`, one surface, one water node (`:786-794`); `visual_parity_claim=false` (`:89`). Canonical shader path `:67` and `:509-510` now resolve; `_bind_known_params` `:480-494` records unbound keys rather than inventing uniforms.
- **[OK]** Shader/mesh uniform cross-check: `tile_atlas`, `alpha_atlas`, `alphavert_atlas`, `atlas_grid`, `ambient_rgb`, `diffuse_rgb`, `specular_rgb`, `donor_sun_position`, `face_scale` exist in `terrain_donor_shader.gdshader:58,63,71,90,129,151,154,156,158` and are bound. `shadow_enabled`, `fog_mode`, `mask_to_alpha`, `alpha_from_mask`, `donor_blend_*` are intentionally unbound telemetry (shader implements crossfade unconditionally at `:266-306`); they are recorded in `mesh._alpha_contract["unbound_parameters"]` — labelled, not faked.
- **[MAJOR] F-V38-05 — [I] masked overlay with no opaque base layer.** `terrain_donor_shader.gdshader:31-32` states: "A base opaque layer must already be in the framebuffer (composer I11/N14), else ALPHA<1 reveals sky"; the shader uses `render_mode blend_mix` (`:50`) and writes `ALBEDO=rgb; ALPHA=a` (`:305-306`). `mesh.build()` `:786-793` creates exactly **one** masked `MeshInstance3D`; the composer adds no base layer. [D] Alpha<1 cells blend against sky/background rather than donor-style terrain beneath. **[I]** Visual severity needs a capture to confirm — none was run. **Fix:** add a second opaque `MeshInstance3D` sharing the geometry with an opaque atlas material beneath the masked surface (keep the `surface_count_one` gate on the masked surface unchanged), or obtain explicit COORD adjudication that the background is an accepted PORT APPROXIMATION.

### 3.4 `variant3d/scripts/terrain_donor_props.gd` (N12, I09) — OK (V28/V33 MAJOR resolved)

- **[O] Owner path:** exact V11 N12 ✓; global class `C3TerrainDonorProps` at `:41`. Public surface `:189-196`, `build(p_container, p_stamps, p_options={})` at `:210`, `rebuild` `:207`, `stats` `:278`, `unverified` `:284`, `props` `:288`, LOD `:301/:314`, `mill_field_hook` `:330`, `asset_inventory` `:367`, `clear` `:398`.
- **[OK] V28 F-02 / V33 D14 RESOLVED:** `:24` and `:88` explicitly mark `DONOR_UNITS=160` / `s=MAP_W/160` REFUTED and removed; V33's exact scan no longer reports a live hit (only benign `"donor_units"` key at `:564`). The V33 scan hit list dropped from 6/9 files to 4/9 files. **Do not re-add the scale.**
- **[OK]** Feeds are read-only (`pattern_lib_index.json` / `family_index.json` at `:59-60`, Z08 `mountain_props.json` fallback at `:49,171`); both new-index files are absent, so the labelled fallback is used — consistent with V28 §6.4. No synthetic scatter/RNG draw found in reviewed sections.
- **[OK]** For the missing `bind`, see F-V38-02 in §3.1 — the defect is the **caller**, not this file.

### 3.5 `variant3d/scripts/terrain_donor_data.gd` (N8, I06) — OK

- **[O] Owner path:** exact V11 N8 ✓; `C3TerrainData` `:29`; SoA core `height/tex/collision` `:132-134`; labelled side arrays `:137-152`; `FIELD_META` `:55-123`. Dump contract spec/01 §4 satisfied: `from_dump` `:508-561` reads only `map_w/map_h/height/tileblock/fields`, ignores unknown keys and version mismatch (`:532-533`), puts all new fields under `fields`; `to_dump` `:563-591` emits `fields.version`, base64 f32/u8 and `props/resources`; `to_live` `:456` uses typed arrays with no copy ✓.
- **[OK]** V28's MINORs (`collision_sub_index` unclamped tag at `:284`, diagnostics not cleared, base64 re-encode) are unchanged and remain MINOR; no R2 escalation.
- **[OK]** No cross-file write, no sim mutation, no parity claim.

### 3.6 `variant3d/tests/t_terrain_donor.gd` (N15, I12) — MAJOR ×2

- **[O] Owner path:** exact V11 N15 ✓; `extends SceneTree`; required modules `:36-45` all PRESENT ✓; optional presence at `:685-688` records `terrain_donor_tiles.gd` ABSENT, canonical shader PRESENT, `terrain_new/manifest.json` ABSENT — advisory only, never a gate ✓. Parity source guard `:704-723` and synthesis-token scan `:725-742` are positive guards.
- **[MAJOR] F-V38-03 — atom→gen call is arity/type-incompatible.** `:343-345` calls `_call_hook(g, ["generate_streams","generate","generate_map","run","build_streams"], [SEED, GEN_KEYS, size, size])`. `_call_hook` `:298-311` slices `default_args` to the discovered method's arg count; `generate` has 2 declared args (`:408`), so the actual call is `generate(20261113, GEN_KEYS)` — argument 1 is `int` where `C3TerrainData` is required and no `generate_streams` exists. [D] `res` is null ⇒ `_generate_streams` returns `{}` at `:346-348` ⇒ `gen_stream_hook_64/240` FAIL, determinism rows are not produced and mesh invariants FAIL with `NO_STREAMS` (`:838-841`). **[U] This is a static prediction; V38 ran no Godot job.** **Fix:** instantiate `C3TerrainData`, call `configure_grid(size,size)`, call `gen.generate(data, {"randkey0":…,"randkey1":…,"width":size,"height":size, ...})`, and map `data.to_dump()` into the five streams; alternatively add the typed `generate_streams` adapter to I07.
- **[MAJOR] F-V38-04 — 320² hard size is silently omitted.** `:60-61` `SIZES := [64, 240]`, `RUN_320_OPTIONAL := false` with comment "V21 D-2 — 320² is OPTIONAL here". [O] `A05_qa_harness.md:31,134`, `V21_gate_register.md:173` (D-2: 2 runs × {64²,240²,320²}) and `spec/12 §12.6:100-104` make 320² part of hard D1; V21 does not grant an atom-level waiver. **Fix:** add `320` to `SIZES` (with COORD supplying the 320² dump/run), or attach an explicit COORD-signed waiver; do not relabel a hard gate "optional".
- **[OK]** `:50-59` pinned key manifest lacks `randkey0/randkey1`; this is consistent with the adapter fix above (the test must supply them, otherwise I07 records a PORT placeholder at `gen.gd:433-434`).
- **[OK/staged]** `variant3d/tests/manifest.json` still has 40 tests, last `t_select_rect`; `t_terrain_donor` is not registered and no `tests_manifest.json.bak-I12` exists — expected for V11 stage C′, not a defect.

### 3.7 `variant3d/shaders/terrain_donor_shader.gdshader` (N13, I10) — OK (path resolved), [I] base-layer risk in §3.3

- **[O] Canonical path** ✓, final SHA `BB31B1EB…`; 18,833 B. `visual_parity_claim:false` in header `:18`; `render_mode blend_mix, unshaded, cull_disabled` `:50`; all donor numbers cited (`:58-181`); mask enters ALPHA only (`:266-306`), no albedo multiply, no dither/noise/shadow fakery. Uniform names match the mesh bindings (§3.3). **No R2 shader defect.** The earlier observed alias `terrain_donor.gdshader` is ABSENT at final snapshot; V28's "N13 ABSENT" verdict is superseded.

### 3.8 Python tools (N1–N5, N16) and N17 spec

- **N1 `decode_donor_cfg.py` — OK (V28 F-03 RESOLVED):** `C01` now validates against the **observed 19** at `:432-442`, records the F03 "20" headline as documented exception MP-1 at `:569-578,674-704`; `ok_count` at `:822-825` can now succeed. Dry-run default `:793-809`; refuses `--out` inside donor root `:802-806`; parity false `:39,658,666,673`. **[MINOR]** absolute donor path still emitted (V28 F-07).
- **N2 `decode_donor_pattern.py` — OK:** dry-run default, parity false at `:344,643,930`; no `family_index` emission now (grep: no matches) — relevant to F-V38-06 below. V28 F-15 dead branch not re-verified (MINOR).
- **N3 `decode_pattern_lib.py` — MAJOR (V28 F-01 persists), MINOR (F-05 persists):** `:768,787,1055-1056,1118-1120` emit **only** `family_index.json` + `families/<family>.json`; V11 `G3/G4` at `V11_ownership_ledger.md:123-124` assign both to **I02**, while I02's tool no longer emits them. [D] Tool and ledger disagree on one owner per path. **Fix (F-V38-06):** COORD amend V11 G3/G4 to I03 and record that I02 retired those outputs, or restrict I03 to G5 `pattern_lib_index.json`; never leave two claimants. `:1066-1070` still hardcodes `observed=True` for `undecodable_fields_null_labelled` (V28 F-05) — **Fix:** pass the computed predicate as `observed`.
- **N4 `decode_donor_masks.py` — OK/MINOR:** canonical path ✓, dry-run default, `--write` explicit `:574-584`, parity false `:516,566`, C9 contradiction preserved `:12-16`. `B>58` hit at `:14` is a docstring recording X19's bug and **must not be deleted** (V33 §5.4). External numpy dep (V28 F-13) unchanged.
- **N5 `build_terrain_new_atlas.py` — OK (V28 F-06 RESOLVED):** `deterministic_manifest_bytes` at `:854-856` now compares real hashes; the `canonical_json(x) in [canonical_json(x)]` tautology is gone. Commit-tier writes confined to `terrain_new` `:478-493`; donor root refused; `visual_parity_claim: false` at `:646,678,691,720,982`. **[MINOR]** absolute donor paths (V28 F-07) and inline-citation (F-08) unchanged.
- **N16 `terrain_qa_harness.py` — OK/MINOR:** `--check` is Python-only; self-check `:1109-1111` asserts no subprocess; `FORBIDDEN_RESTORE` `:192-196` and rollback text `:185-190` are data, never executed; parity `UNVERIFIED` by construction `:4-5,30,1174`; `--policy red` refused without signed spec `:1139-1142,1160-1163`. **[MINOR] F-V38-07:** `:784` still hardcodes `"banned_phrases_absent": True` (V28 F-04 partial) — **Fix:** scan emitted gate rows and store the measured boolean. The `or True`/`or len(...)==64` tautologies V28 cited are gone.
- **N17 `spec/terrain_qa_spec.json` — OK:** `schema_only`, `status=SCHEMA_ONLY__UNPOPULATED__NO_PARITY_CLAIM` `:3-4`, all bands `value: null`, `signed: false` `:14-22,23-120`, parity `UNVERIFIED/claim NONE` `:9-13`, forbidden list `:173-180` ✓.

## 4. Forbidden-pattern hits (V33 §4 snippet, read-only, re-run at final snapshot)

V33's §4 snippet scans `Get-ChildItem variant3d -Recurse` files named `terrain_donor*` or `decode_donor*` with extensions `.gd/.gdshader/.py`, skipping `#`/`//` comment lines. **Exact observed output:**

```
variant3d\scripts\terrain_donor_gen.gd:689: [P4_donor_units] _tel["mine_band_units"] = "MAP CELLS 1:1 (V08:155-190) — no DONOR_UNITS scaling"
variant3d\scripts\terrain_donor_props.gd:564: [P4_donor_units] "pattern_index", "note", "donor_units"]:
variant3d\tools\decode_donor_cfg.py:23: [P7_smooth_6_3x3] never "fixed": TileSmoothPasses=6 vs script SmoothTileMap(...,3), and
variant3d\tools\decode_donor_masks.py:14: [P5_B_gt_58] and the two manifest bugs in the legacy tool (B>58 off-by-one; starts
FILES=9 HITS=4
```

| # | Hit | Pattern | Classification | Verdict |
|---|---|---|---|---|
| H1 | `terrain_donor_gen.gd:689` | P4 `DONOR_UNITS` | [O] Telemetry string asserting the **absence** of scaling; deleting it destroys the V08 record. | **OK** |
| H2 | `terrain_donor_props.gd:564` | P4 `donor_units` | [O] Field-name list in a key filter; no division/scale operation anywhere in the file (`:24,88` refute it). | **OK** |
| H3 | `decode_donor_cfg.py:23` | P7 `TileSmoothPasses=6` | [O] Docstring preserving contradiction C2 (cfg 6 vs script 3); V33 §5.4 says preserve. | **OK** |
| H4 | `decode_donor_masks.py:14` | P5 `B>58` | [O] Docstring preserving X19's off-by-one; do not "fix" the prose. | **OK** |

**[D] No P1 (noise/dither), P2 (face promotion/terrain=5), P3 (bad HEIGHT_SCALE), P6 (rgb*alpha), P8 (parity claim) hits.** No live D14 hit — V33's two executable hits were removed by I09 between V33's scan and this one; re-ran the identical snippet in pass P8 and got the same 4 hits.

**Extended scan (V38, read-only, broader token set over 13 files including those V33's glob excludes):** additional benign hits — `terrain_qa_harness.py:193,1091-1093` (FORBIDDEN_RESTORE literals + a self-check, never executed; verified by `:1109-1111` no-subprocess assertion), `terrain_donor_mesh.gd:660` telemetry key `relief_mask_cells_no_face_promotion`, `terrain_donor_props.gd:440` telemetry `"no_noise_field": true`, `t_terrain_donor.gd:91-92,665,751` the test's own token list/check names. All are guards or telemetry, not forbidden behaviour. **[U]** Static scan is necessary but not sufficient: stage order, RNG identity re-seeds and runtime API behaviour were checked by code reading only; no gate was run.

## 5. Disposition of V28 R1 / V33 findings

| Prior finding | Severity then | Current state (final snapshot) | Evidence |
|---|---|---|---|
| V28 F-01 I03 emits I02-owned `family_index.json`/`families/*.json` | MAJOR | **OPEN — F-V38-06 (MAJOR)** | `decode_pattern_lib.py:768,787,1055-1056,1118-1120`; `V11_ownership_ledger.md:123-124`; I02 tool has no such emission |
| V28 F-02 `DONOR_UNITS=160` in props | MAJOR | **RESOLVED** | `terrain_donor_props.gd:24,88`; V33 §4 output now 4 benign hits |
| V28 F-03 `--check` permanently red (C01=20) | MAJOR | **RESOLVED** | `decode_donor_cfg.py:432-442,569-578,687-690,822-825` |
| V28 F-04 harness tautologies | MINOR | **PARTIAL — F-V38-07 (MINOR)** | `or True`/`or len(...)==64` gone; `terrain_qa_harness.py:784` still hardcoded |
| V28 F-05 `decode_pattern_lib` hardcoded observed | MINOR | **OPEN — §3.8 (MINOR)** | `decode_pattern_lib.py:1066-1070` |
| V28 F-06 atlas determinism tautology | MINOR | **RESOLVED** | `build_terrain_new_atlas.py:854-856` |
| V28 F-07 absolute donor paths | MINOR | **OPEN (MINOR)** | `decode_donor_cfg.py:181,242,632` et al. — not re-scoped by R2 |
| V28 F-08 inline citations | MINOR | **OPEN (MINOR)** | as R1; GDScript modules still comply |
| V28 F-09/10/11 mesh notes | MINOR | **OPEN (MINOR)** | `terrain_donor_mesh.gd:42,150,732`; `:334-355`; `:801-807` |
| V28 F-12 stale composer comment | MINOR | **OPEN — F-V38-09 (MINOR)** | `terrain_donor_world.gd:30,61` |
| V28 F-13 Python deps | MINOR | **OPEN (MINOR)** | `decode_donor_masks.py:41`; `build_terrain_new_atlas.py:57` |
| V28 F-15 dead branch | MINOR | NOT RE-VERIFIED in R2 | R1 `:887-892` |
| V33 D14 live hit | HIGH | **RESOLVED** | same as F-02; V33 §4 scan re-run |
| V33 §7 Q4 `field_sowing_hook` binding | UNVERIFIED | **OPEN (UNVERIFIED)** | `terrain_donor_gen.gd` hook exists; composer `:216` does not bind it, and the call itself is broken (F-V38-01) |

## 6. API matrix (cross-module compatibility at final snapshot)

| Caller → callee | Expected signature | Actual call site | Verdict |
|---|---|---|---|
| composer `bind` → `data.from_live_object` | `from_live_object(src: Object) -> bool` (`data.gd:411`) | `world.gd:191,206-207` with `[game]` / `.call("from_live_object", game)` | **OK** |
| composer `build` → `data.configure_grid` | `(int,int)` (`data.gd:170`) | `world.gd:195,213` with `[size.x,size.y]` | **OK** |
| composer → `gen.generate` | `(C3TerrainData, Dictionary)` (`gen.gd:408`) | `world.gd:216` `[_data, game]` | **MAJOR** F-V38-01 |
| composer → `gen.run` | does not exist | `world.gd:218` fallback | **MINOR** (dead fallback) |
| composer → `mesh.bind` / `mesh.build` | `bind(g, d=null)` (`mesh.gd:122`), `build()->bool` (`:718`) | `world.gd:224-226` | **OK** |
| composer → `props.bind` | does not exist | `world.gd:229` | **MAJOR** F-V38-02 |
| composer → `props.build` | `(Object, Array, Dictionary={})` (`props.gd:210`) | `world.gd:231` `[]` (arity guard refuses) | **MAJOR** F-V38-02 |
| composer → shader | `terrain_donor_shader.gdshader` (`world.gd:35`) | file present; `mesh.set_donor_shader` absent → direct material swap `world.gd:169-174` | **OK** (same shader already bound by `mesh.gd:509-510`) |
| composer → `height_at_world` | `(Vector2)->float` (`mesh.gd:132`) | `world.gd:247-248` | **OK** |
| composer/gen/props `invalidate` | only mesh defines it (`mesh.gd:801`) | `world.gd:239-240` best-effort | **MINOR** no-op for gen/props |
| test atom → `gen.generate` | `(C3TerrainData, Dictionary)` | `t_terrain_donor.gd:343-345` slices to `[SEED, GEN_KEYS]` | **MAJOR** F-V38-03 |
| test atom → data constants | `TILE_ID_MAX=123`, `WATER_DEEP=-0.25`, `WATER_SHORE=-0.1` (`data.gd:34,36-37`) | `t_terrain_donor.gd:64-66,693-702` | **OK** |
| mesh → atlas | `terrain_new/atlas/*` (`mesh.gd:57-59`) | directory ABSENT → legacy atlas + explicit label (`mesh.gd:367-386,503-518`) | **OK** (staged, labelled PORT APPROX) |
| props → feeds | `pattern_lib_index.json`/`family_index.json` (`props.gd:59-60`) | ABSENT → Z08 `mountain_props.json` fallback (`:49,171`) | **OK** (staged, labelled) |
| data dump → spec/01 §4 | legacy keys + `fields` dict | `data.gd:508-591` | **OK** |
| QA harness → spec bands | all `value: null`, `signed: false` | `terrain_qa_spec.json:14-120` | **OK** |

## 7. Seam verification (main.gd / world3d.gd)

| Check | Result | Evidence |
|---|---|---|
| Backup existence + expected SHA | **OK** | `inbox/backup/main.gd.bak-COORD-I11` = `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` (V11 E1 exactly); `inbox/backup/world3d.gd.bak-COORD-I11` = `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` (V11 E2 exactly) |
| Current files differ from backups | **OK** | `main.gd` `FA9D93ED7C278F78AFC2A8A316FB6B76D1EC1AA60C405A1EE572713F1DCBC3F3`; `world3d.gd` `EEC6560A1BC751B53446647D719410481747E342C715C1F0C94A970C44B3718A` |
| Additive only | **OK** | `main.gd` **9 insertions / 0 deletions**; `world3d.gd` **20 insertions / 1 substitution** — the single deletion is the documented ternary line `terrain = _instantiate(TERRAIN_SCRIPT)` → `terrain = _instantiate(TERRAIN_DONOR_SCRIPT if terrain_backend == "donor" else TERRAIN_SCRIPT)` (`world3d.gd:624`). No legacy behaviour removed. |
| Default legacy | **OK** | `main.gd:125 var terrain_backend := "legacy"`; `:188-191` config read with default `"legacy"` and unknown-value coercion; `world3d.gd:143 var terrain_backend := "legacy"`; setter `:220-226` coerces anything but `"donor"` to legacy |
| Both `make_world3d()` sites guarded | **OK** | `main.gd:592-594` (`_do_async_load`) and `main.gd:1111-1113` (`_setup_full_game`): `if world != null and world.has_method("set_terrain_backend"): world.set_terrain_backend(terrain_backend)` — exactly two calls, both before `world.bind(game)` (`:595`, `:1114`) |
| Late switch refused | **OK** | `world3d.gd:220-226` checks `_terrain_locked` and `push_error`s; `_terrain_locked = true` set after module init at `:645`. `make_world3d()` (`main.gd:1044-1052`) only constructs + returns the node, so the setter always runs before `bind()`. |
| Composer target exists | **OK** | `const TERRAIN_SCRIPT` remains at `world3d.gd:108` unchanged; `TERRAIN_DONOR_SCRIPT := "res://scripts/terrain_donor_world.gd"` at `:117` resolves (N14 present) |
| Stats observability | **OK** | `world3d.gd:705-706` adds `terrain_backend` and `terrain_script` keys; composer stats at `terrain_donor_world.gd:300-324` adds `backend`, `missing_modules`, `shader_path`, `visual_parity_claim=false`, `fed_back_into_sim=false` |
| No cross-file edits | **OK** | Tracked modified files are only `docs/terrain_swarm_2026-11-26/CHARTER.md`, `SWARM_BOARD.md`, `spec/11_ASSET_CONVERSION.md` (COORD-owned docs) plus the two seam files; every implementation file is untracked and matches exactly one V11 owner row |
| No `app/**` change | **OK** | `git status --short -- app/` and `--untracked-files=all -- app/` both empty; freeze set `game.gd`, `world3d_terrain.gd`, `world3d_relief.gd`, `terrain_tileindex.gdshader`, `water3d.gd`, `project.godot` shows no diff |

**[D] Verdict:** the seam itself satisfies spec/12 §12.1 and V11 CR1/CR2. The remaining risk is *inside* the opt-in backend (§3.1–3.3), not in the switch. **[U]** No gate, parse or capture was run by V38.

## 8. Risks

| # | Risk | Label | Evidence / mitigation |
|---|---|---|---|
| R1 | "Donor" backend composes but silently runs no generator and no props | **[D] HIGH** | F-V38-01/02; `_call_adapt` returns true on a failed call (`world.gd:143`); require `gen_applied` and `props_applied` true and `missing_modules` empty before any capture |
| R2 | Atom hard checks fail because of the signature mismatch, tempting a "fix" by lowering checks | **[D] HIGH** | F-V38-03; fix the call/adapter, never the assertions (`V21 GR-A23`) |
| R3 | 320² omitted from the atom while a report claims D1 green | **[D] HIGH** | F-V38-04; 320² stays UNVERIFIED until a real 320² run exists |
| R4 | Alpha<1 reveals sky; port misread as donor shore | **[I]/PORT APPROX MEDIUM** | F-V38-05; need a capture, not a static verdict |
| R5 | Two claimants for `family_index.json`/`families/*.json` | **[D] MEDIUM** | F-V38-06; ledger/tool must name one owner |
| R6 | Late landings invalidate hashes and line numbers again | **[O] MEDIUM** | P5: 8 files changed hash during this review; re-run §4 and re-fetch hashes before acting on any finding |
| R7 | Labelled telemetry/docstring forbidden-pattern hits "cleaned up", destroying contradiction records | **[O] MEDIUM** | §4 H1–H4; preserve verbatim (V33 §5.4) |
| R8 | Self-check PASS lines create false confidence | **[D] MEDIUM** | F-V38-07, V28 F-05; repair before trusting harness output |
| R9 | Missing N6/N7/N10 and all derived assets are mistaken for failures | **[O] LOW** | §2.1; workers still running, staged rollout by V11 §7 |
| R10 | Any visual improvement mistaken for donor parity | **[U]/PORT APPROX HIGH** | No donor GPU A/B frame; parity UNVERIFIED (CHARTER.md:43-44,125) |

## 9. Open questions for COORD

1. **Q1.** Who owns `family_index.json` and `families/<family>.json` after F-V38-06 — I02 (V11 G3/G4) or I03 (current sole emitter)? Amend the ledger or the tool, not both silently.
2. **Q2.** Should I07 add `generate_streams(seed, keys, w, h)` as the canonical atom/composer adapter, or should I12 and I11 be changed to build the `C3TerrainData` + `p` Dictionary themselves? One adapter shape must serve both callers.
3. **Q3.** Is a masked overlay without an opaque base layer an accepted PORT APPROXIMATION, or must I08/I11 add the base pass before any opt-in capture (F-V38-05)?
4. **Q4.** Is there a COORD-signed waiver for the atom's 320² omission, or must `SIZES` include 320 (F-V38-04)?
5. **Q5.** When N6/N7/N10 land, should V38 (or a V39) run R3 over just those files, re-running V33's snippet and the API matrix?
6. **Q6.** Should `gen_applied`/`props_applied` be promoted from telemetry to a hard prerequisite for any donor-backend capture, given the false-success path in `_call_adapt`?

## 10. Handoff summary (5 lines)

1. **Verdict:** 13 owned implementation files + N17 are present at exact V11 canonical paths; N6/N7/N10 and all `terrain_new` derived assets are ABSENT (workers running); N13's shader was renamed mid-review from the retired alias to canonical `terrain_donor_shader.gdshader` — final state OK.
2. **R2 findings:** two MAJOR call mismatches in the composer (`gen.generate` Dictionary arg at `world.gd:216`, props `bind`/`build` at `:229-231`), one MAJOR atom→gen mismatch at `t_terrain_donor.gd:343-345`, one MAJOR 320² omission at `:60-61`, one [I] MAJOR masked-overlay base-layer risk, and V28 F-01 still open; concrete fixes in §3.
3. **Resolved since R1/V33:** `DONOR_UNITS=160` removed (props `:24,88`), `--check` C01 now validates observed 19 (`decode_donor_cfg.py:432-442`), atlas determinism tautology removed (`:854-856`); V33's exact scan is down to 4 benign hits, no live executable hit.
4. **Seam/guards:** `main.gd` 9/0 and `world3d.gd` 20/1 additive, default legacy, both `make_world3d()` sites guarded, backups match V11 E1/E2 SHAs exactly, `app/**` and all freeze files byte-unchanged; no cross-file edits.
5. **Guards:** multiple passes recorded (8 hashes changed mid-review, two apparent blockers withdrawn after second instruments); **no source, git, Godot, runner, gate, capture or donor state changed; NO DONOR PARITY CLAIM — parity stays UNVERIFIED / PORT APPROXIMATION.**

*End of V38 report. Exactly one report written; no source, shader, config, asset, test, backup, queue, git, runner, Godot, donor or `app/` state changed.*
