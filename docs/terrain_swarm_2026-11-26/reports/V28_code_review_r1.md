---
id: V28
ticket: "TERRAIN-SWARM-2026-11-26 / V28 — first-pass static code review of landed I01–I13 implementation files"
agent: "V28 (review-only subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__REVIEW_ONLY__NO_SOURCE_EDIT__NO_GIT__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V28_code_review_r1.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V28_code_review_r1.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, gate or runner job was used. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,122-130). No PASS/parity claim is made by this review."
scope_guard: "Only file reads and read-only PowerShell Test-Path/Get-Item/Get-ChildItem/Select-String were used. No .bak, source, asset, test, manifest, queue or app/ byte changed."
snapshot: "2026-11-26 09:48:16 +01:00 (08:48:16 UTC). Files were landing DURING this review; presence below is the final snapshot only."
---

# V28 — first-pass code review (round 1)

## 1. Executive summary

1. **[O] Snapshot:** 13 owned implementation/source files plus `spec/terrain_qa_spec.json` are present at the exact V11 canonical paths; four ledger files are still ABSENT (I05-N6, I13-N7, I07-N10, I10-N13). ABSENT entries are recorded as **worker still running**, not as failures.
2. **[D] Overall static quality is high:** every reviewed file declares its owner path, every donor numeric constant in the GDScript modules carries an inline `# donor path:line`, `visual_parity_claim = false` is universal, and no synthetic noise/dither field, tile-art relief, assertion deletion or lowered gate was found. The I06/I08/I12 files are notably disciplined.
3. **[D] Three integration-decision findings precede any merge:** (a) I03 emits outputs owned by I02 into the same directory (`decode_pattern_lib.py:1046,781,1048-1049` vs V11 G3/G4 `V11_ownership_ledger.md:123-124`); (b) I09 scales props by a port-invented `DONOR_UNITS=160` (`terrain_donor_props.gd:76,585`) that I07 explicitly refutes with V08 `[O]` cell-space distances (`terrain_donor_gen.gd:28-34`); (c) `decode_donor_cfg.py --check` can never exit 0 because C01's expected 20 contradicts its own four-pass observed 19 (`:399-405,528-537,752-756`).
4. **[D] Four tautological/faked self-checks were found** in the QA harness and I02/I03 validators (harness `:1028-1031,1100,778`; `decode_pattern_lib.py:988-992`; atlas `:839-844`). They do not lower a shipped gate, but they report "PASS" without measuring anything and must be repaired before the results are trusted.
5. **[U] Scope limit:** this is a *static first pass*. No Godot parse, no Python execution against donor, no gate, no `app/` hash check and no donor access were performed. Gen/props/composer/masks/test bodies were reviewed at header/API/constant level only; full body review is deferred to R2. **No donor parity claim is made.**

## 2. Files read (multiple-pass evidence)

Read set: `CHARTER.md`; `SWARM_BOARD.md`; `IMPLEMENTATION_PLAN.md`; `spec/01_WORLD_DATA_MODEL.md`; `spec/12_QA_AND_INTEGRATION.md`; `reports/V11_ownership_ledger.md`; and every implementation file present at snapshot.

| Pass | Instrument | Result / effect |
|---|---|---|
| P1 | `glob` for `decode_donor_*.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`, `terrain_donor_*.gd` | Only `terrain_donor_data.gd` found; appeared to confirm most files absent |
| P2 | `read` directory listing of `variant3d/tools/` and `variant3d/scripts/` | Same result — but `build_terrain_new_atlas.py` was absent from both listings |
| P3 | PowerShell `Test-Path` + `Get-ChildItem`/`Get-Item` with `LastWriteTimeUtc` | **Contradiction resolved:** `build_terrain_new_atlas.py` existed (43,520 B, written 08:42:55 UTC). Files were landing concurrently; P1/P2 were stale snapshots |
| P4 | Full `read` of atlas tool, then repeated `Test-Path` | `decode_donor_cfg.py`, `decode_donor_pattern.py`, `decode_pattern_lib.py`, `terrain_donor_mesh.gd` appeared between passes; all re-read |
| P5 | `read` of pattern decoder showed a suspected arity bug at `run_checks` call | Second instrument (`Select-String` + re-read at offset 935) showed the file had been corrected (`:941-942` now passes `out`); **suspected BLOCKER withdrawn** — recorded as transient, not a defect |
| P6 | `Select-String` on collaborator APIs | `tile_atlas_loader.gd:99,174,229,260,266` and `water3d.gd:154,305` signatures match every call in `terrain_donor_mesh.gd` |
| P7 | Final `Test-Path`/`Get-Item` sweep at 09:48:16 local | 13 present implementation files + N17 spec; 4 ABSENT. `class_name` grep found 3 global classes, no duplicate |
| P8 | `grep` for `HEIGHT_SCALE`, noise/dither, parity, `DONOR_UNITS` | Confirmed no synthetic field; found the I07↔I09 `DONOR_UNITS` contradiction and a literal HEIGHT_SCALE multiply |

**[O] No anomaly was silently skipped.** The two apparent blockers (missing atlas tool; `run_checks` arity) were resolved by re-reading with a second instrument and are explicitly *not* reported as defects.

## 3. Evidence table (V11 path → snapshot state)

| V11 row | Exact owner path | Owner | State | First-pass verdict |
|---|---|---|---|---|
| N1 | `variant3d/tools/decode_donor_cfg.py` | I01 | PRESENT | Reviewed — MAJOR (permanent red `--check`) |
| N2 | `variant3d/tools/decode_donor_pattern.py` | I02 | PRESENT | Reviewed — OK/MINOR |
| N3 | `variant3d/tools/decode_pattern_lib.py` | I03 | PRESENT | Reviewed — MAJOR (owner-path collision) |
| N4 | `variant3d/tools/decode_donor_masks.py` | I04 | PRESENT | Header/CLI reviewed — OK/MINOR (dep risk) |
| N5 | `variant3d/tools/build_terrain_new_atlas.py` | I05 | PRESENT | Reviewed — MINOR (tautological determinism check) |
| N6 | `variant3d/tools/build_terrain_new_manifest.py` | I05 | **ABSENT** | Worker still running |
| N7 | `variant3d/tools/validate_terrain_new.py` | I13 | **ABSENT** | Worker still running |
| N8 | `variant3d/scripts/terrain_donor_data.gd` | I06 | PRESENT | Fully reviewed — OK/MINOR |
| N9 | `variant3d/scripts/terrain_donor_gen.gd` | I07 | PRESENT | Header/API/constants reviewed — OK/MINOR |
| N10 | `variant3d/scripts/terrain_donor_tiles.gd` | I07 | **ABSENT** | Worker still running |
| N11 | `variant3d/scripts/terrain_donor_mesh.gd` | I08 | PRESENT | Fully reviewed — OK/MINOR |
| N12 | `variant3d/scripts/terrain_donor_props.gd` | I09 | PRESENT | Header/API reviewed — MAJOR (unit contradiction) |
| N13 | `variant3d/shaders/terrain_donor_shader.gdshader` | I10 | **ABSENT** | Worker still running; optional per V11 CR5 |
| N14 | `variant3d/scripts/terrain_donor_world.gd` | I11-COMPOSER | PRESENT | Header/API reviewed — OK/MINOR (stale comment) |
| N15 | `variant3d/tests/t_terrain_donor.gd` | I12 | PRESENT | Header/API reviewed — OK |
| N16 | `variant3d/tools/terrain_qa_harness.py` | I13 | PRESENT | Reviewed — MINOR (tautological self-checks) |
| N17 | `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | I13 | PRESENT | Reviewed — OK (null bands, no red flip) |
| G1–G11 | `variant3d/assets/terrain_new/**` | Various | Not inventoried by V28 | Out of scope for R1; COORD to verify separately |

## 4. Per-file review

### 4.1 `variant3d/tools/decode_donor_cfg.py` (I01)
- **Owner path:** exact V11 N1 ✓. **CLI:** `--game`, `--out`, `--check`, `--dry-run` (`:714-725`); write only with `--out` (`:738-739`); dry-run default ✓ ticket `IMPLEMENTATION_PLAN.md:9`.
- **Constants/citations:** 7 FILE_SPECS with donor rel paths, byte/line counts and SHA-256 (`:46-103`); comment block `:41-45` cites F03 §2 but not inline `# donor path:line` on each constant (MINOR F-08).
- **UNVERIFIED:** `unparsed_record()` sets `value: None`, `value_type: None`, `label: "UNVERIFIED"` (`:173-194`); commented literals routed there (`:231-239`) ✓.
- **Forbidden:** no noise, no HEIGHT_SCALE, no parity claim (`visual_parity_claim = False` `:39,617,625,632`); both donor contradictions preserved verbatim (`:563-581`) ✓.
- **Gate risk:** C01 expected 20, four passes observe 19, deliberately reported FAIL (`:399-405,528-537`); `ok_count` requires all checks PASS (`:753-756`) ⇒ `--check` can never exit 0 → MAJOR F-03.
- **Contract risk:** absolute donor path in committed JSON (`"source": path` `:242`, `unparsed_record` `:181`, `"game_root"` `:632`) → MINOR F-07. Python-only, no syntax error visible; unclosed `open()` at `:550,552-553` (resource hygiene only).

### 4.2 `variant3d/tools/decode_donor_pattern.py` (I02)
- **Owner path:** exact V11 N2 ✓. **CLI:** `--game`, `--out`, mutually exclusive `--dry-run`/`--no-dry-run|--write`, `--check` (`:812-827`); dry-run default (`:832`) ✓.
- **Decoded fields:** exact F01 region walker (`:269-296`), occupancy/grid/Rec24 kept (`:398-506`), Tail13 and i32 weights emitted as `null` + UNVERIFIED (`:346-347,502-507,793-796`) ✓.
- **Citations:** layout/offset/flags cited in record `labels` (`:321-331`) and evidence strings (`:637-665`); inline `# donor path:line` not on every fixed constant (`:81-136`) → MINOR F-08.
- **Forbidden:** no noise/dither/face promotion/HEIGHT_SCALE; `visual_parity_claim=False` (`:344,643,930`) ✓.
- **Blocker withdrawn:** P5 suspected `run_checks` arity mismatch; P6 re-read shows correct `:941-942` call. No defect.
- **Contract risk:** dead `if False else` branch in pipeline hash (`:887-892`) → MINOR F-15. Absolute donor path in emitted records (`:341,902-904,914,916`) → F-07. Does not emit V11 G3 `family_index.json` (owned by I02) — I03 emits it instead; see F-01 for adjudication.

### 4.3 `variant3d/tools/decode_pattern_lib.py` (I03)
- **Owner path:** exact V11 N3 ✓. **CLI:** `--game`, `--out`, `--check`, `--dry-run`/`--write`, default dry (`:1053-1068`) ✓.
- **UNVERIFIED:** `parse_scalar` returns `None` + `LABEL_UNVERIFIED` on any failed literal (`:171-190`); `unverified_fields` null blocks (`:543-549,775-779`); quarantine of `m_swamp_12_old` (`:875-882`) ✓.
- **Forbidden:** no invented band; parity false everywhere (`:164,806,985-987`) ✓.
- **MAJOR F-01:** emits `family_index.json` (`:1046`) and `families/<family>.json` (`:781,1048-1049`) — both owned by I02 per V11 G3/G4 (`V11_ownership_ledger.md:123-124`) — into the same default out dir as I02 (`decode_pattern_lib.py:40`, `decode_donor_pattern.py:77`). Cross-owner output collision.
- **MINOR F-05:** self-check `add("undecodable_fields_null_labelled", …, True, True)` hardcodes the observed value (`:988-992`).
- **Contract risk:** `parse_generator` hardcodes indentation 9/15 (`:442,445,449`) without inline donor path:line; absolute donor string in envelopes (`:166,511`).

### 4.4 `variant3d/tools/decode_donor_masks.py` (I04)
- **Owner path:** exact V11 N4 ✓. **CLI/API:** `--check`, default dry-run, `--write`, `--game`, `--out` documented (`:21-25`) ✓ ticket `IMPLEMENTATION_PLAN.md:12`. Header only reviewed (file landed at 08:47:57 UTC, after first passes).
- **Citations:** donor facts cited as report paths (`:7-19`), constants `H_SCALE=-1.1`, `WATER_DEEP_B=58`, `SHORE_B=24` with `generatemap.inc:4-7,567` / `texturemap.inc:29-31` / X19 (`:56-59`) ✓; contradiction C9 preserved (`:16-19`).
- **Forbidden:** no noise/dither; no parity claim (`:3-5`) ✓.
- **Risk:** `import numpy as np` (`:41`) vs harness's "stdlib only / cp313-only numpy" note (`terrain_qa_harness.py:8`) → environment F-13. Full body deferred to R2.

### 4.5 `variant3d/tools/build_terrain_new_atlas.py` (I05)
- **Owner path:** exact V11 N5 ✓. **CLI:** `--game`, `--out`, `--cell`, `--hires-local`, `--check`, `--dry-run`, `--write`, `--emit-root-manifest` (`:887-908`); dry-run default (`:912`) ✓.
- **UNVERIFIED:** three alpha sentinels `source_png=None`, `status="UNVERIFIED"`, alias recorded not fabricated (`:275-286,401-410`); desert season UNVERIFIED (`:666-676`); pass count UNVERIFIED (`:424-427`) ✓.
- **Forbidden:** no noise/dither/HEIGHT_SCALE/tile-art relief; `visual_parity_claim: false` (`:42,630,704,958`) ✓; identity face reuse explicitly labelled PORT APPROX (`:301-313,588-596`) — no new face art created.
- **MINOR F-06:** `deterministic_manifest_bytes` contains tautology `canonical_json(x) in [canonical_json(x)]` (`:839-844`); the hash-equality clauses are real, so the check is partial, not wholly fake. Manifest self-hash is a two-step fixed-point approximation (`:741-765`) — internal `outputs` table holds the previous manifest hash; root manifest differs; MINOR provenance note.
- **MINOR F-07/F-08:** "no absolute donor path in committed data" policy (`:39,686-687`) is contradicted by other tools, not by this one; its own constants lack inline donor path:line (`:86-97`) though evidence strings exist (`:571-577`).

### 4.6 `variant3d/scripts/terrain_donor_data.gd` (I06)
- **Owner path:** exact V11 N8 ✓; single global class `C3TerrainData` (`:28`), no duplicate (P7).
- **API:** SoA core arrays (`:131-133`), labelled side arrays (`:136-152`), `from_live`/`from_live_object`/`to_live`/`from_dump`/`to_dump`/`stats` (`:379,404,445,495,548,584`), `configure_grid` (`:169`), `assign_side` (`:468`) — matches I06 ticket `IMPLEMENTATION_PLAN.md:14` and I07's declared contract (`terrain_donor_gen.gd:51-65`).
- **UNVERIFIED:** FIELD_META labels every `[U]` field explicitly (`:54-123`); no guessed values, zero-init only; ROW_FLIP/TILE_M/FIELD_ORDER labelled (`:37-41`) ✓.
- **Forbidden:** no noise/dither/face promotion/HEIGHT_SCALE (`"no HEIGHT_SCALE multiplier applied"` `:207`); relief_mask is an art guard "never sim/mesh" (`:99-102`) ✓.
- **Static risks:** `collision_sub_index` does not clamp `tag` (`:277-280`) — out-of-range tag can index the wrong cell; `_diagnostics` not cleared by `configure_grid` (`:169-216`); re-encoding base64 in `to_dump` (`:548-577`) is byte-stable for valid f32-LE but is not a literal byte passthrough. All MINOR.
- **Owner file discipline:** no file I/O, no cross-file write ✓.

### 4.7 `variant3d/scripts/terrain_donor_gen.gd` (I07)
- **Owner path:** exact V11 N9 ✓; global class `C3TerrainDonorGen` (`:48`). Header/API/constants reviewed; full stage bodies deferred to R2.
- **API:** consumes I06 surface (`:51-65`); parity "UNVERIFIED" in telemetry (`:318,390`); no HEIGHT_SCALE multiply (`:333`).
- **Citations:** strongest inline coverage in the swarm — every donor constant in `:68-175` carries `# donor path:line` ✓. UNVERIFIED hooks are null/default with named TODO owners (`:177-180`).
- **Forbidden:** explicitly refuses Gaussian/noise port (`:624`); no face promotion or art rewrite in reviewed portion ✓.
- **MINOR:** `_set_size()` accepts a legacy `set_size(w,h)` spelling (`:63-64`) — a compatibility shim not in the I06 contract; ensure it is not read as a donor fact. Full-body review needed for stage-order and RNG-ledger verification.

### 4.8 `variant3d/scripts/terrain_donor_mesh.gd` (I08)
- **Owner path:** exact V11 N11 ✓; no global class (dynamic load, `:79-80`). **API:** `bind`, `height_at_world`, `set_atlas_mode`, `set_season`, `build`, `invalidate`, `get_mesh`, `get_water_node`, `is_built` (`:122,132,153,159,704,805,826,830,834`) — matches I08 ticket.
- **Citations:** every donor constant `:41-76` has inline `# donor path:line` ✓; collaborator signatures verified (P6).
- **Forbidden:** no noise/dither/tile-art relief; `visual_parity_claim=false` (`:89,664`); relief cells forced face 0 (`:743-751`) — the required Z04-C guard ✓.
- **MINOR F-09:** literal `* HEIGHT_SCALE` at `:150,732` despite PLAN:30. **MINOR F-10:** `_face_mode_at` (`:336-355`) assigns face 1/2 from cDiff thresholds while labelling the donor promotion rule UNVERIFIED (`:334-335`). **MINOR F-11:** `invalidate()` frees every child (`:805-809`).
- **Static risk:** `var shader := load(...) as Shader if ... else null` (`:498`) infers Variant from a mixed ternary — parses in Godot 4 but fragile; prefer explicit `var shader: Shader = null`.

### 4.9 `variant3d/scripts/terrain_donor_props.gd` (I09)
- **Owner path:** exact V11 N12 ✓; global class `C3TerrainDonorProps` (`:41`). Header/API reviewed; body deferred.
- **Citations:** consistent `# donor …` / `# port …` convention (`:37-38`); no invented transform when feed absent — SKIP, not synthesise (`:28-35`) ✓.
- **MAJOR F-02:** `DONOR_UNITS=160.0` (`:76`) used as `cell_scale = dim.x / DONOR_UNITS` (`:585`) contradicts I07's V08 `[O]` cell-space correction (`terrain_donor_gen.gd:28-34`).
- **Forbidden in reviewed portion:** no synthetic scatter/noise/RNG draw (`:34-35`) ✓; parity guard (`:5-12`) ✓.

### 4.10 `variant3d/scripts/terrain_donor_world.gd` (I11-COMPOSER)
- **Owner path:** exact V11 N14 ✓; optional-module composition, no algorithm (`:7-19`); parity false (`:28`); inline donor citations `:39-57` ✓.
- **MINOR F-12:** `:30` claims "no class_name anywhere" but three composed modules declare `class_name` (data `:28`, gen `:48`, props `:41`) — stale comment only.
- **Static risk:** graceful degradation means an opt-in "donor" backend could compose with zero modules and still report built; COORD should require `missing_modules` empty before any capture. No forbidden construct found.

### 4.11 `variant3d/tests/t_terrain_donor.gd` (I12)
- **Owner path:** exact V11 N15 ✓. Atom contract (`:22-31`), pinned keys (`:49-60`), cited constants with inline paths (`:63-88`), advisory bands labelled ADVISORY_UNVERIFIED (`:78-87`), `HOOK_MISSING` never faked PASS (`:22-24`). No forbidden construct found in reviewed portion. Registration in `tests/manifest.json` LAST is I12's separate EDIT step (V11 E3) — not checked here (no git).
- **Note:** `SYNTHESIS_TOKENS` includes `"HEIGHT_SCALE *"` and `"face_promotion"` (`:91-92`) — a positive guard, not a violation.

### 4.12 `variant3d/tools/terrain_qa_harness.py` (I13/N16)
- **Owner path:** exact V11 N16 ✓; N17 spec at exact path ✓. **CLI:** `--dump-a`, `--dump-b`, `--seed-manifest`, `--policy`, `--out`, `--check` (`:1115-1127`); no runner/Godot/donor access (`render` is JSON only; manual commands emitted `:571-617`) ✓.
- **Gates:** 52 rows, 25 A / 16 B / 11 C, order A'-0..D-6 (`:107-160,88-91`); class B always `ADVISORY_UNVERIFIED` (`:808-812`); parity `UNVERIFIED` (`:875-879`); `--policy red` refused without signed donor spec (`:381-431,632`); rollback commands file-scoped, forbidden blanket restores listed (`:176-195`) ✓.
- **Forbidden:** no invented band, no lowered threshold; `validate_spec` refuses invented/changed bands (`:397-415`) ✓.
- **MINOR F-04:** tautological self-checks at `:1028-1031` (`or len(...)==64`), `:1100` (`or True`), and hardcoded `banned_phrases_absent: True` at `:778`. Real checks coexist (`:1037-1050,1063-1096`) so this is telemetry integrity, not a gate lowering.
- **Contract:** requires `--out` explicitly (`:1131-1135`); V11 N18 pins `inbox/qa/terrain_qa_report.json` — supply it from COORD. `spec/terrain_qa_spec.json` correctly has all bands `value: null`, `signed: false` (`:3-21,23-120`) ✓.

## 5. Findings table

| # | Severity | Exact file:line | Finding | Concrete fix suggestion |
|---|---|---|---|---|
| F-01 | **MAJOR** | `decode_pattern_lib.py:1046,781,1048-1049`; `V11_ownership_ledger.md:123-124`; `decode_donor_pattern.py:77` | I03 writes `family_index.json` and `patterns/families/*.json`, both owned by I02, into the same default output dir as I02 | COORD adjudicate: either amend V11 G3/G4 to I03 and forbid I02 from emitting them, or restrict I03 to G5 `pattern_lib_index.json` + uniquely named census docs; add a write-collision guard to both tools |
| F-02 | **MAJOR** | `terrain_donor_props.gd:76,585` vs `terrain_donor_gen.gd:28-34` | I09 divides prop dimensions by port-invented `DONOR_UNITS=160`, refuted by I07's V08 `[O]` "distances are map cells 1:1" | Remove `DONOR_UNITS` or derive it from a donor path:line; consume the I07 stamp's cell-space transform directly; COORD adjudicate V08 vs legacy `pattern_gen.gd:9` before merge |
| F-03 | **MAJOR** | `decode_donor_cfg.py:399-405,528-537,752-756` | `ok_count` requires all 19 checks PASS, but C01 is deliberately FAIL (expected 20, observed 19) ⇒ `--check` can never exit 0; integration gate 2 cannot certify | Split C01 into `C01_claim` (preserve 20 as provenance, non-gating) and `C01_derived` (19, with `globalparams.cfg:2-20` four-pass evidence); record an explicit deviation. Do not delete the assertion |
| F-04 | MINOR | `terrain_qa_harness.py:1028-1031,1100,778` | Self-checks that cannot fail (`or len(...)==64`, `or True`) and a hardcoded `banned_phrases_absent: True` | Compute the digest against a real expected constant; delete `or True`; scan emitted gate rows for banned phrases and store the measured boolean |
| F-05 | MINOR | `decode_pattern_lib.py:988-992` | Check `undecodable_fields_null_labelled` reports `observed=True` regardless of the computed predicate | Pass the computed boolean as `observed` and keep the predicate as `condition` |
| F-06 | MINOR | `build_terrain_new_atlas.py:839-844` | Determinism check includes tautology `canonical_json(x) in [canonical_json(x)]`; also two-step manifest self-hash leaves an internal stale hash (`:741-765`) | Build the plan twice and compare full `outputs_bytes`; remove the tautology; document that a manifest cannot contain its own final hash and validate the root/manifest cross-reference instead |
| F-07 | MINOR | `decode_donor_cfg.py:181,242,632`; `decode_donor_pattern.py:341,902-904,914,916`; `decode_pattern_lib.py:166,511` vs `build_terrain_new_atlas.py:39,686-687` | Absolute donor install paths leak into committed derived JSON although another tool declares "no absolute donor path in committed data" | Emit only `source_rel`/`source_short`; drop `game_root` or store `<DONOR_ROOT>` placeholder; add a repository-wide guard check |
| F-08 | MINOR | `terrain_donor_data.gd:31-45`; `decode_donor_cfg.py:46-103`; `build_terrain_new_atlas.py:86-97`; `decode_pattern_lib.py:52-61` | Donor-derived constants are cited in prose/evidence strings but not with inline `# donor path:line` on each definition line (GDScript modules already comply) | Add inline `# donor <path>:<line>` to each donor constant definition; keep advisory `[I]/[D]` bands explicitly non-donor |
| F-09 | MINOR | `terrain_donor_mesh.gd:42,150,732` vs `IMPLEMENTATION_PLAN.md:30` | Literal `* HEIGHT_SCALE` multiply exists even though value is the labelled 1.0 PORT contract (`spec/01:33`) | Use `_height[i]` directly in vertex Y and `height_at_world`; keep `HEIGHT_SCALE` only as a telemetry label or delete it |
| F-10 | MINOR | `terrain_donor_mesh.gd:334-355` | `_face_mode_at` derives face 1/2 from donor cDiff thresholds while the same block labels the donor promotion rule ENGINE/UNVERIFIED | Obtain D08/COORD sign-off, else force face 0 until the promotion rule is recovered; label the result `[I] PORT APPROXIMATION`, not donor-derived |
| F-11 | MINOR | `terrain_donor_mesh.gd:805-809` | `invalidate()` removes and frees *all* children of the Node3D, including any node a composer may attach | Track the module-owned nodes (`mesh_instance`, `water`) explicitly and free only those |
| F-12 | MINOR | `terrain_donor_world.gd:30` vs `terrain_donor_data.gd:28`, `terrain_donor_gen.gd:48`, `terrain_donor_props.gd:41` | Comment "no class_name anywhere" is false | Correct the comment; confirm global-class registration does not collide (P7: three distinct names, OK) |
| F-13 | MINOR | `decode_donor_masks.py:41`; `build_terrain_new_atlas.py:57`; `terrain_qa_harness.py:8` | External deps (numpy, Pillow) conflict with the harness's stdlib-only Python 3.14 note; gate A'-1 `py_compile` could fail under the wrong interpreter | Declare per-tool interpreter/deps in the COORD runbook and pin the interpreter before gating; no code change required if runners already use compatible Python |
| F-15 | MINOR | `decode_donor_pattern.py:887-892` | Dead `if False else` branch in the pipeline hash generator | Remove the dead branch and keep the single deterministic expression |
| — | **OK** | `terrain_donor_data.gd:24-25,207`; `terrain_donor_mesh.gd:16-17,743-751`; `terrain_qa_harness.py:6-7,381-431`; all files `visual_parity_claim=false` | No synthetic noise/dither, face promotion on relief cells, HEIGHT_SCALE fudge value, tile-art relief, invented donor constant, parity claim or lowered/lowering gate was found | Preserve as-is; add a regression guard rather than editing |
| — | **ABSENT** | N6 `build_terrain_new_manifest.py`, N7 `validate_terrain_new.py`, N10 `terrain_donor_tiles.gd`, N13 `terrain_donor_shader.gdshader` | Not present at snapshot — worker still running, **not** a failure | Re-review when landed; do not infer a defect from absence |

## 6. Implications for COORD integration

1. **[D] Do not merge I01/I03/I09 yet.** F-01, F-02 and F-03 each need a COORD decision before Stage A/A' can be called clean. F-03 in particular blocks the "decoder tools byte-validated" gate (`spec/12 §12.3:62`): with the current C01, `--check` is permanently red regardless of donor bytes.
2. **[D] Stage order is mostly satisfied on paper:** tools I01–I05 present (N6 pending), runtime I06/I08/I09/I11 present (N10/N13 pending), I12 atom present but its manifest append (V11 E3) must remain stage C' and LAST. The seam (E1/E2 `main.gd`/`world3d.gd`) was not inspected in R1 (no git) — V11's pre-edit P1–P4 must still be re-run by COORD.
3. **[D] Parse-before-switch (V11 §6 rule 5) is not yet satisfiable:** N10 tiles and N13 shader are absent; composer degrades gracefully (`terrain_donor_world.gd:15-19`) but a zero-module "donor" backend would be silently inert. Require `missing_modules` empty before any opt-in capture.
4. **[D] I05's atlas is emitted only with `--write`; at snapshot no `terrain_new` atlas asset was inventoried. I08 falls back to the legacy atlas with an explicit label (`terrain_donor_mesh.gd:377-383,503-506`) — acceptable for composition, not acceptable as a donor-semantics result.
5. **[D] QA cannot be claimed green from this harness alone:** all class-A telemetry rows are deliberately UNVERIFIED (`terrain_qa_harness.py:740-765`), class B is advisory, class C is emitted-not-executed (`:814-832`). F-04 must be fixed before any of its "PASS" lines are trusted.

## 7. Risks

| # | Risk | Label | Evidence / mitigation |
|---|---|---|---|
| R1 | Two workers emit the same derived asset (`family_index.json`, `families/*.json`) and clobber each other | [D] HIGH | F-01; V11 G3/G4 vs I03 `:1046` — one owner per emitted path |
| R2 | Prop scale mismatch doubles/attenuates every mountain/mine/field footprint | [D] HIGH | F-02; V08 cell-space correction ignored by I09 |
| R3 | A permanently red I01 `--check` is mistaken for a donor-byte mismatch and "fixed" by changing expected values | [D] MEDIUM | F-03; preserve the contradiction, split claim vs derived check |
| R4 | Self-check PASS lines create false confidence in the QA harness | [D] MEDIUM | F-04, F-05; repair before sign-off |
| R5 | Absolute donor paths committed in derived JSON leak private install layout | [D] MEDIUM | F-07; relativise |
| R6 | Wrong Python interpreter makes numpy/Pillow imports fail at gate A'-1 | [U] MEDIUM | F-13; pin interpreter |
| R7 | Late landings change line numbers and invalidate every citation in this report | [U] MEDIUM | P3/P5 showed two files rewritten mid-review; re-run the P7 snapshot before acting |
| R8 | No donor GPU A/B frame exists; any visual improvement is misread as parity | [U]/PORT APPROX HIGH | `CHARTER.md:43-44,122-130`; harness `GR-C08` `:156`; parity stays UNVERIFIED |
| R9 | Static review cannot catch GDScript parse errors or runtime API drift not covered by P6 | [U] MEDIUM | No Godot was run by V28; COORD must run the parse gate |

## 8. Open questions for COORD

1. **Q1.** Who owns `family_index.json` and `patterns/families/*.json` after F-01 — I02 (V11 G3/G4) or I03 (current emitter)? Amend the ledger or the tool, not both silently.
2. **Q2.** Is `DONOR_UNITS=160` retired per V08 (`terrain_donor_gen.gd:28-34`) for I09 too, or does a donor-cited world-unit exist that justifies it?
3. **Q3.** How should the F03 "20 global keys" headline be represented in a gate that must be able to pass — preserved contradiction plus a derived-19 gate, per F-03?
4. **Q4.** May V28 run a second pass (R2) over the full bodies of I07, I09, I11 and I12 once all files have stopped landing? R1 reviewed those at header/API/constant level only.
5. **Q5.** Which Python interpreter is pinned for `decode_donor_masks.py` (numpy) and `build_terrain_new_atlas.py` (Pillow) given the harness's stdlib-only note?
6. **Q6.** Should the missing `terrain_new` atlas assets be generated before or after the parse-before-switch gate, given I08's labelled legacy fallback?

## 9. Handoff summary (5 lines)

1. **Verdict:** 13 owned implementation files + N17 spec are present at exact V11 paths at 09:48:16 local; four ledger files ABSENT (worker still running); no BLOCKER found in the final snapshot.
2. **Three MAJOR findings needing COORD decision:** I03 emits I02-owned outputs (`decode_pattern_lib.py:1046`); I09's `DONOR_UNITS=160` (`terrain_donor_props.gd:76,585`) contradicts V08 cell-space (`terrain_donor_gen.gd:28-34`); I01 `--check` is permanently red (`decode_donor_cfg.py:752-756`).
3. **Forbidden-construct scan:** clean — no synthetic noise/dither, no face promotion on relief, no HEIGHT_SCALE fudge value, no tile-art relief, no invented donor constant, no parity claim, no lowered gate; `visual_parity_claim=false` everywhere.
4. **Minor repairs:** four tautological self-checks (`terrain_qa_harness.py:1028-1031,1100,778`; `decode_pattern_lib.py:988-992`; `build_terrain_new_atlas.py:839-844`), literal HEIGHT_SCALE multiply (`terrain_donor_mesh.gd:150,732`), absolute donor paths, stale composer comment.
5. **Guards:** two apparent blockers were withdrawn after a second instrument re-read; no source, git, Godot, runner, gate or donor state changed; **donor parity remains UNVERIFIED / PORT APPROXIMATION** — this is a review, not a gate pass.

*End of V28 report. Exactly one report written; no source, shader, config, asset, test, backup, git, queue, runner, Godot, donor or `app/` state changed.*
