---
id: V13
ticket: "TERRAIN-SWARM-2026-11-26 / V13 — stale QA reference and asset-path audit"
owner: "V13 (read-only verification worker)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_GODOT_JOB__NO_CODE_OR_ASSET_EDIT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Read-only literal-path audit of ALL top-level variant3d/tests/*.gd (67 files), variant3d/tools/*.py (51 files) and variant3d/scripts/*.gd (34 files), 152 files total. Prior art read first: docs/terrain_swarm_2026-11-26/{CHARTER,SWARM_BOARD}.md, reports/{P02_asset_inventory,P03_gates_capture}.md, spec/12_QA_AND_INTEGRATION.md."
outputs: "Exactly one repo file: docs/terrain_swarm_2026-11-26/reports/V13_stale_qa_refs.md. Throwaway probes live in %TEMP%\\opencode\\v13_*.py/.json (outside the repo)."
parity_guard: "No donor GPU A/B frame was produced, no donor binary was opened or run, and no Godot process or runner job was submitted by this worker. 'Real file' means an on-disk path check only, never a rendered-look claim. All visual/QA outcomes remain UNVERIFIED; no donor parity claim."
method_note: "MULTIPLE PASSES MANDATORY (CHARTER §4): pass 1 = Python literal-string scan with res:// resolution (v13_paths.py); pass 2 = corrected multi-root resolver + donor-root resolution (v13_pass2.py); pass 3 = app/variant root, template and output-path audit (v13_pass3.py); pass 4 = PowerShell Test-Path -LiteralPath re-check of every declared missing path (v13_pass4.py + shell); pass 5 = basename search across the entire variant3d/assets tree + Pillow import probe (v13_pass5.py). 87 raw 'missing' candidates from pass 1 were reduced to 3 stale-reference groups after passes 2–5; the discarded 84 are documented in the second table of §2."
---

# V13 — stale QA references / missing asset paths (read-only)

## 0. Executive summary

1. **[O] The P02 finding is confirmed and is a HARD failure.** `variant3d/tests/t_relief_props_qa.gd:30` declares `PROP_MANIFEST := "res://assets/terrain/terrainmesh_props.json"`; that path is absent on all five passes. `_load_manifest()` (`:284-289`) fails the `prop_manifest_loaded` check and returns `false`, and `_initialize()` (`:785-787`) routes that to `_finish()` → `status=FAIL`, `passed=false`, exit 1 (`:141,149,170`). It is **not** a guarded fallback. The live table is `res://assets/terrain/mountain_props.json` (`world3d_relief.gd:42`; confirmed present with `bbox_m` and `by_pattern` keys matching the atom's expectations). Confirmed by P02 at `P02_asset_inventory.md:22,164,185` and re-verified here.
2. **[O] Two further stale-reference groups exist in the same 152-file aperture:** (a) `variant3d/tests/t_sheet_load.gd:8,9,10,12` — four anim sheet PNGs that do not exist anywhere under `variant3d/assets/**` (the nation subfolders exist but contain zero PNGs); `:11` (`yacht_hull.png`) is the only valid entry; (b) `variant3d/tools/terrain3d_shot.py:25-26,120` — legacy M0.6 shot/stats/seammask PNG+JSON under `app/shots/` that are all absent; `:26` (stats) is a hard failure (`terrain3d_shot.py:127-141`).
3. **[D] None of the three groups touches a non-negotiable gate.** `t_relief_props_qa` and `t_sheet_load` are not registered in `variant3d/tests/manifest.json` (grep: zero hits) and are not part of selftest 29/29 or uitest 17/17; `terrain3d_shot.py` is a legacy M0.5/M0.6 art-pass instrument (`P03_gates_capture.md:99`, E14/E16), not `t_render_mode`, `assert_clean` or `scan_map.py`. Gate impact on `spec/12 §12.5` is therefore **none proven**, but the relief atom is a real regression-detector blind spot (P02 R4).
4. **[O] 84 of 87 raw "missing" candidates were false positives** produced by naive resolution (output paths, `%s`/`{seed}` templates, donor-root inputs, `res://../docs` relative paths, guarded legacy fallbacks). They are enumerated in the second table of §2 so COORD does not "fix" correct code. **[D]** The false-positive rate is itself evidence that a second command is mandatory before declaring a path missing.
5. **[O] Pillow cp313-vs-system mismatch re-verified:** `variant3d/tools/blender_py/PIL` ships only `cp313-win_amd64.pyd` natives; under the installed Python **3.14.3** `from PIL import Image` raises `ImportError: cannot import name '_imaging' from 'PIL'`, while the system install at `%APPDATA%\Roaming\Python\Python314\site-packages\PIL` is **Pillow 12.1.1** and imports cleanly. This corroborates P02 frontmatter `tool_note` and risk R6 (`P02_asset_inventory.md:11,187`).
6. **No parity claim.** Every verdict above is a literal path/existence or static-control-flow observation; no test was run and no assertion was changed.

## 1. Method and evidence table

| # | Label | Source (file:line / instrument) | Establishes |
|---|---|---|---|
| E01 | [O] | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-31,66-85,94` | Read-only worker, one-report rule, mandatory labels, multi-pass-on-anomaly rule |
| E02 | [O] | `reports/P02_asset_inventory.md:22,164,185,221` | Prior discovery of `t_relief_props_qa.gd:30` stale path; `mountain_props.json` is live; R4 risk |
| E03 | [O] | `reports/P03_gates_capture.md:20-26,65-75,99,281`; `spec/12_QA_AND_INTEGRATION.md:65-69,102-114` | The five non-negotiable gates; legacy tool classification; no runner job by analysis workers |
| E04 | [O] | `v13_paths.py` (pass 1): 67+51+34 = **152 files**, 978 quoted path-like string rows, 87 raw "missing" | Exhaustive literal-string sweep of the requested aperture |
| E05 | [O] | `v13_pass2.py`, `v13_pass3.py`, `v13_pass4.py` (PowerShell `Test-Path -LiteralPath`) | Multi-root and second-command existence re-checks; stale vs false-positive split |
| E06 | [O] | `v13_pass5.py` (recursive basename search over `variant3d/assets/**`) | The four `t_sheet_load` basenames have **zero** on-disk matches anywhere; only `yacht_hull` found |
| E07 | [O] | `variant3d/tests/t_relief_props_qa.gd:30,284-311,785-787,141,149,170` | Hard-failure control flow of the stale manifest constant |
| E08 | [O] | `variant3d/assets/terrain/mountain_props.json:11-18`; `world3d_relief.gd:42` | Real file exists; `bbox_m` values equal `DONOR_H` at `t_relief_props_qa.gd:57-60`; `by_pattern` key present |
| E09 | [O] | `variant3d/tests/t_sheet_load.gd:7-23`; `variant3d/tests/manifest.json` (grep: no hit) | Per-path hard failure and unregistered status |
| E10 | [O] | `variant3d/tools/terrain3d_shot.py:25-30,101-104,109-113,120-141` | Hard (shot/stats) vs guarded (M0/M0.5/2D/seammask) missing references |
| E11 | [O] | `v13_pass5.py`; system `python -c "import PIL"`; P02 `:11,187` | Python 3.14.3 + bundled cp313 PIL ImportError; system Pillow 12.1.1 OK |
| E12 | [O] | `variant3d/tools/heightmap3d_shot.py:43-45,124-127`; `terrain_sample_shot.py:40,63-64`; `terrain_land_shot.py:30-31` | Guarded/false-positive references (scene fallback; `SHOTS=APP/shots`) |
| E13 | [O] | `variant3d/scripts/data.gd:314-318`; `game.gd:1872-1875,1903-1906`; `input_controller.gd:143-146` | Guarded legacy flat fallbacks and guarded cursor template — correct code, not stale |

**Label convention:** **[O]** = literal file:line, on-disk `Test-Path` result, or direct import probe this pass. **[D]** = deterministic consequence of observed code/paths. **[I]** = reading with explicit caveat. **[U]** = cannot be proven without an engine run / captured frame. **PORT APPROXIMATION** = explicit port substitute, never donor truth.

## 2. Stale-reference table

Only references that are (a) literal asset/JSON paths in the audited aperture, (b) absent after ≥2 existence commands, and (c) not an output path or a template are listed.

| # | Exact file:line | Referenced path | Existence (pass 4 / pass 5) | Failure mode | Affected gate / test | Minimal legitimate remediation |
|---|---|---|---|---|---|---|
| S1 | `variant3d/tests/t_relief_props_qa.gd:30` | `res://assets/terrain/terrainmesh_props.json` | **MISSING** (3 Python passes + PowerShell `Test-Path=False`); real `mountain_props.json` = True | **HARD** — `:286-289` fails `prop_manifest_loaded`, returns `false`; `:785-787` → `_finish()`; `status=FAIL`, `passed=false`, exit 1 (`:141,149,170`) | `t_relief_props_qa` (Z07/Z08 relief-props QA atom). **Unregistered** — no hit in `tests/manifest.json`; not in selftest 29/29 or uitest 17/17 | Repoint `:30` to `"res://assets/terrain/mountain_props.json"`. Verified schema: `bbox_m` (`:11-16`) equals `DONOR_H` (test `:57-60`), `by_pattern` present (JSON `:18+`) so `:297-309` can pass. **Do not delete/lower any assertion**: the interface gaps at test `:7-14` (`SCALE_WANT=1.0` vs authored scaling `0.3539..0.6562`; one `MeshInstance3D` expected vs landed `MultiMeshInstance3D` batching) remain legitimate FAILs for the QA owner to reconcile |
| S2a | `variant3d/tests/t_sheet_load.gd:8` | `res://assets/models/anim/rus/units/rus_peasant_idle.png` | **MISSING** (pass 2/4/5; zero basename hits in `variant3d/assets/**`) | **HARD** per entry: `:16-20` increments `bad`; `:23` `quit(1)` | `t_sheet_load` anim-import-cache smoke (unregistered; no other repo reference) | Add an explicit skip with recorded reason (sheet not present in the migrated tree), or repoint to a verified existing sheet **only if** QA owner declares it an equivalent import-cache probe. Never remove the loop or the exit code |
| S2b | `variant3d/tests/t_sheet_load.gd:9` | `res://assets/models/anim/aus/buildings/aus_cen.png` | **MISSING** (pass 2/4/5; zero basename hits) | HARD (same as S2a) | same | same as S2a |
| S2c | `variant3d/tests/t_sheet_load.gd:10` | `res://assets/models/anim/common/units/archer_walk.png` | **MISSING** (pass 2/4/5; zero basename hits) | HARD (same as S2a) | same | same as S2a |
| S2d | `variant3d/tests/t_sheet_load.gd:12` | `res://assets/models/anim/sco/units/sco_peasant_walk.png` | **MISSING** (pass 2/4/5; zero basename hits) | HARD (same as S2a) | same | same as S2a |
| S3a | `variant3d/tools/terrain3d_shot.py:25` | `ROOT/app/shots/terrain3d_m06.png` (`DEFAULT_SHOT`) | **MISSING** (pass 3/4; `Test-Path=False`) | **HARD** — `:101-104` prints `MISSING` and `return 1` | Legacy M0.5/M0.6 art-pass verifier (`P03:99`); **no** non-negotiable gate | Regenerate the artefact at the path the tool reads, or point `--shot` at a real captured PNG with the exact path recorded in the gate log; do not lower the size/non-blank test |
| S3b | `variant3d/tools/terrain3d_shot.py:26` | `ROOT/app/shots/terrain3d_m06.json` (`DEFAULT_STATS`) | **MISSING** (pass 3/4; `Test-Path=False`) | **HARD** — `:127-141` prints `[stats] MISSING`, sets `ok=False`, verdict FAIL, `return 1` | same | Regenerate the sidecar JSON alongside S3a (the variant sandbox writes `res://shots/**` → `variant3d/shots/**` under `--path variant3d`, **not** `app/shots/**`); or mark the tool explicitly OUT-OF-SCOPE for the fresh port with a COORD-recorded reason |
| S3c | `variant3d/tools/terrain3d_shot.py:120` | `ROOT/app/shots/terrain3d_m06_seammask.png` | **MISSING** (pass 3/4) | **GUARDED** — `:121-125` prints `[seams] M0.6 = MISSING magenta mask render`, does **not** set `ok=False` | same | Informational only; if the M0.6 seam metric is still wanted, regenerate the mask PNG, otherwise leave the honest MISSING message. No assertion to remove |

**Not stale but worth recording (guarded, correct behaviour):**

| File:line | Path | Verdict |
|---|---|---|
| `variant3d/tools/heightmap3d_shot.py:43,45` | `res://scenes/heightmap3d_sandbox.tscn` / `app/scenes/heightmap3d_sandbox.tscn` | **MISSING but guarded** — `:127` selects `SANDBOX_SCRIPT_REL` (`:44`, `app/scripts/heightmap3d_sandbox.gd` EXISTS) when the scene is absent. Do not "repair" |
| `variant3d/scripts/data.gd:316`; `game.gd:1874,1905` | `res://assets/models/anim/sco_units.json`, `.../buildings.json` | **Guarded legacy flat fallbacks** — primary bucket paths at `:314` / `:1872,1903` exist; fallback only reached if primary missing. Correct by design |
| `variant3d/scripts/asset_paths.gd:18`; `world3d_entities.gd:85` | `res://assets/models/glb/` | **Directory absent by design** (`world3d_entities.gd:16`: "when V7-8 lands"); no active load site |
| `variant3d/scripts/input_controller.gd:144` | `res://assets/ui/cursor_%s.bmp` | **Template** — all 11 `cn` values at `:143` have real BMPs (`cursor_default`, `cursor_attack`, `cursor_captureattack`, `cursor_artillery`, `cursor_patrol`, `cursor_construct`, `cursor_gainfood`, `cursor_gainwood`, `cursor_gainstone`, `cursor_gotomine`, `cursor_wait`); `:145` guards the load |
| `variant3d/tests/t_fx3d.gd:27-29` | `res://assets/models/anim/`, `assets/sprites/`, `assets/sprites_hi/` | **Negative tokens** (`FORBIDDEN_2D_TOKENS`, `:26`) — existence is intentionally irrelevant |
| `variant3d/tests/t_final_gate.gd:43-45` | `res://../docs/REPORT_*.md`, `DONOR_OPTIONS_GAPS.md` | **EXIST** at repo-root `docs/` once `res://../` is resolved correctly (pass-1 resolver bug); not stale |
| `variant3d/tools/build_tile_index_atlas.py:344`; `build_winter_atlas.py:245`; `pack_tile_atlas_split.py:235,250,269`; `convert_skins.py:284-285` | `variant3d/assets/...` strings | **EXIST** relative to repo root (pass-1 resolved them relative to `variant3d/`, a false positive) |
| `variant3d/tools/copy_assets.py:97-103,178-233`; `build_missions.py:138-139` | `data/...` donor inputs | **EXIST** under `C:\Games\Cossacks 3\data\...` (read-only donor root); not repo paths |
| `variant3d/tools/terrain_sample_shot.py:63-64`; `terrain_land_shot.py:30-31` | `shots/terrain_sample.json`, `shots/terrain_land.json` | **EXIST** — `SHOTS = APP/"shots"` at `terrain_sample_shot.py:40`; pass-1 mis-resolved to `variant3d/shots` |
| `variant3d/tests/_v716_probe.gd:6`; `.../mill_render_test.gd:71`; `t_ghost_final_stage.gd:30`; `main.gd:1659`; `terrain3d_sandbox.gd:6,12-17` | `tests/results/*.json`, `shots/*` | **Runtime output paths**; directories created on demand (`_ensure_dir` / Python `mkdir`). Absence before a run is expected |
| `variant3d/tools/migrate_anim_layout.py:446-447`; `migrate_anim_nations.py:129-170`; `convert_models.py:729-730`; `render_models.py:66-67`; `world.gd:409,543,775,1059`; `world3d.gd:830`; `world3d_entities.gd:190,218,258,520` | `%s`, `{}`, `<sid>`, `CREATED ...` strings | **Templates / comments / `BLOCKED` notes**; not file references |

## 3. Remediation per item (COORD-owned; V13 edits nothing)

- **R-S1 (terrain, priority):** single-line literal change `t_relief_props_qa.gd:30` → `"res://assets/terrain/mountain_props.json"`. Preconditions: (a) re-read the file before editing (other workers may own it — check V11 ownership ledger); (b) keep every assertion at `:89-93`, `:286-311`, `:337-439`, `:518-528`, `:710-731` intact; (c) record in the gate log that the remaining failures are the **documented** Z07/Z08 interface gaps (`:7-14`), not a reason to lower `SCALE_WANT`, `BBOX_TOL` or the prop-count expectation; (d) re-run with a fresh unique runner id, windowed, with the mountains-tier fixture, and require mtime-after-START. **[U]** No Godot run by V13, so the post-repoint result is unknown.
- **R-S2 (adjacent, model anim):** for each of `:8,9,10,12`, either (i) add an explicit `SKIP` entry with recorded reason "sheet absent after anim migration; no on-disk equivalent anywhere under `variant3d/assets/**`" while preserving the `:11` positive assertion and the `:23` exit contract, or (ii) repoint only if a QA owner names equivalent real sheets. **[U]** V13 cannot decide equivalence without a render; no parity claim.
- **R-S3 (legacy tool):** either regenerate `app/shots/terrain3d_m06.{png,json}` from the existing sandbox, or explicitly retire `terrain3d_shot.py` as OUT-OF-SCOPE for the fresh port in the gate log. Do **not** change `:107`'s `1280x720`/stddev gate or `:141`'s failure branch. **[I]** Regeneration is the honest fix if the M0.6 comparison is still needed; retirement is acceptable because P03 already classifies the tool as legacy.
- **Pillow (environment):** use system Pillow 12.1.1 explicitly (verified working) for all `variant3d/tools/*.py` image gates, or regenerate the bundled PIL natives for cp314. Do not vendor donor binaries or silently switch metrics. **[I]** COORD/environment owner decision; V13 changed no package.

## 4. Gate impact

| Gate (`spec/12 §12.5`, `P03` §2) | Impact from S1/S2/S3 | Reasoning |
|---|---|---|
| selftest 29/29 | **No proven impact** [D] | `t_relief_props_qa`/`t_sheet_load` are not in `scripts/selftest.gd`'s 29 steps and not in `tests/manifest.json`; selftest uses its own JSON |
| uitest 17/17 | **No proven impact** [D] | Same; `uitest.gd` does not reference either atom |
| `t_render_mode` PASS / `seam_missing=false` | **No impact** [D] | Reads `scripts/main.gd` and render mode only (`t_render_mode.gd:5,44-126`) |
| `assert_clean` CLEAN | **No impact** [D] | Reads runner spool `variant3d/.godot_queue/status.json` (`assert_clean.py:34-42`); none of S1–S3 submits jobs. Existing 3 unacked entries remain COORD's issue (`P03:26,122`) |
| `t_map_variety` 5/5, `scan_map.py` ALL GREEN | **No impact** [D] | No terrain asset load in either (`t_map_variety.gd:15-17,184-259`; `scan_map.py:446-510`) |
| Z07/Z08 relief-props atom | **BLOCKED by S1** [O] | Hard exit 1 before any prop geometry or pixel A/B check executes (`t_relief_props_qa.gd:284-311,785-787`). This is a regression-detector blind spot even though it is not a named gate (P02 R4) |
| Anim import-cache smoke | **BLOCKED by S2** [O] | 4/5 paths hard-fail; no gate registration |
| Legacy M0.5/M0.6 art-pass verifier | **BLOCKED by S3** [O] | `terrain3d_shot.py` returns 1; not a fresh-port gate |

**Note [D]:** "no proven impact" is not "verified green" — V13 ran no gate. All five gates remain UNVERIFIED for today's tree, consistent with `P03_gates_capture.md:258,281` and `spec/12_QA_AND_INTEGRATION.md:102-114`.

## 5. Pillow cp313-vs-system issue (P02 finding, re-verified)

| Item | Evidence | Label |
|---|---|---|
| Bundled PIL ships only `cp313-win_amd64.pyd` natives (`_imaging`, `_imagingcms`, `_imagingft`, `_imagingmath`, `_imagingmorph`, `_imagingtk`) | `variant3d/tools/blender_py/PIL/` directory listing, pass 5 | [O] |
| Current interpreter is Python **3.14.3**; importing the bundled package fails: `ImportError: cannot import name '_imaging' from 'PIL'` | `v13_pass5.py`, then clean-process probe | [O] |
| System Pillow **12.1.1** at `%APPDATA%\Roaming\Python\Python314\site-packages\PIL` imports `Image` successfully | clean-process `python -c "import PIL; from PIL import Image"` | [O] |
| P02 already recorded this and used system Pillow for every image measurement; no repo image was modified | `P02_asset_inventory.md:11` (`tool_note`), `:187` (R6), `:228` (attestation) | [O] |
| Consequence: any `variant3d/tools/*.py` that prepends `tools/blender_py` to `sys.path` will fail image measurement under 3.14; metrics silently using the wrong Pillow are an environment confound, not a terrain defect | `v13_pass5.py` | [D] |
| Whether any *specific* gate script actually prepends that path in a shipped run | not traced by V13 | [U] |

No donor parity claim follows from any Pillow measurement; image stats are port-internal.

## 6. Risks

1. **Regression blind spot [O/D]** — S1 makes the only donor-driven relief-props QA atom fail before its checks run; "gates green" could be reported while relief props are unvalidated (`P02:185`, R4).
2. **Greenwashing pressure [D]** — the temptation to "fix" S1 by deleting the manifest check or lowering `SCALE_WANT`/`BBOX_TOL` must be resisted; CHARTER §4 forbids threshold lowering and assertion deletion. Repoint only.
3. **Schema mismatch after repoint [U]** — `mountain_props.json` carries donor-unit `bbox_m` (`:17` explicitly says "NOT metres") while the atom labels them metres (`t_relief_props_qa.gd:392-400`); the manifest check may pass while the bbox/scale checks still fail for documented reasons. This is a QA-owner reconciliation, not a path fix.
4. **Aperture confusion [O]** — pass 1 produced 87 false "missing" hits; a worker trusting one command could edit correct code (e.g., `terrain_sample_shot.py:64`, `t_final_gate.gd:43-45`). Multi-pass discipline is mandatory.
5. **Legacy tool paths vs fresh outputs [D]** — `terrain3d_shot.py` reads `app/shots/**` while `terrain3d_sandbox.gd:6,12-17` writes `res://shots/**`; under `--path variant3d` these are different directories, so "regenerate the PNG" requires an explicit, recorded destination decision.
6. **Unregistered tests [O]** — S1/S2 are invisible to `test_all.py`/`manifest.json`; a stale atom can rot without failing any listed gate.
7. **Pillow environment confound [O]** — cp313-only bundled natives under Python 3.14 can change which Pillow computed a metric; do not compare numbers across the two installs without recording the version (`P02:11`).
8. **Ownership collisions [U]** — V06 owns "gate/capture remediation (stale JSON, unacked)" on the board (`SWARM_BOARD.md:49`); S1/S3 may overlap. V13 wrote only its own report; COORD must deconflict before any edit.

## 7. Open questions

1. **COORD / V06:** who applies the S1 one-line repoint, and is `t_relief_props_qa.gd` to be registered in `tests/manifest.json` or explicitly retired? (V13 makes no edit.)
2. **QA owner (Z07/Z08 / V07):** after repointing S1, how are the documented `SCALE_WANT=1.0` vs authored scaling and `MeshInstance3D` vs `MultiMeshInstance3D` interface gaps to be reconciled **without** lowering any threshold?
3. **COORD:** for S2, are the four absent anim sheets to be restored from a donor-derived conversion, or should the atom carry explicit skips with reasons? V13 found no equivalent anywhere in `variant3d/assets/**`.
4. **COORD:** is `terrain3d_shot.py` still an accepted instrument for the fresh port? If yes, regenerate `app/shots/terrain3d_m06.{png,json}` with recorded provenance; if no, mark OUT-OF-SCOPE in the gate log rather than deleting the failure branch.
5. **Environment owner:** should `variant3d/tools/blender_py/PIL` be rebuilt for cp314, or should all tools be pinned to system Pillow 12.1.1 in the gate log? Either way, record the version beside every image metric.
6. **V06 / COORD:** do S2/S3 interact with the three unacked runner failures (tickets 575/582/585, `P03:26,122`)? V13 submitted no runner job and did not touch the spool.
7. **[U]** Whether any of S1–S3 is already fixed by another worker's in-flight report (V06/V07 landed concurrently); re-read before acting.

## 8. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | `terrainmesh_props.json` absent after 5 existence passes; `mountain_props.json` present | §2 S1, E05, E08 | [O] |
| 2 | S1 is a hard failure, not a guarded fallback | E07 | [O] |
| 3 | Four `t_sheet_load` paths absent with zero basename matches; one valid | E06, §2 S2a–d | [O] |
| 4 | Three `terrain3d_shot.py` references absent; two hard, one guarded | E10, §2 S3a–c | [O] |
| 5 | 84/87 raw candidates are false positives | E04/E05, §2 second table | [O]/[D] |
| 6 | No non-negotiable gate affected; relief atom blocked | E03, §4 | [D] |
| 7 | Bundled PIL cp313 fails, system Pillow 12.1.1 works, on Python 3.14.3 | E11 | [O] |
| 8 | Any donor-parity / visual / runtime result | none | [U] |

## 9. Attestation

- **Read-only:** no `.gd`, `.py`, `.json`, asset, manifest, config, test, result JSON, runner spool or git state was modified. No file was copied from or opened in the donor beyond read-only `Test-Path` checks of donor input paths under `C:\Games\Cossacks 3\data\...`. No donor binary was executed.
- **No Godot:** no `godot` process, no `godot_runner.py` subcommand (not even `status`), no capture, no A/B frame.
- **One repo file written:** `docs/terrain_swarm_2026-11-26/reports/V13_stale_qa_refs.md`. Probes live in `%TEMP%\opencode\v13_*.py/.json`.
- **Labels observed:** OBSERVED / DERIVED / INFERRED / UNVERIFIED / PORT APPROXIMATION throughout; **no donor parity claim**.

## 10. Five-line summary

1. [O] Confirmed `variant3d/tests/t_relief_props_qa.gd:30` points at nonexistent `terrainmesh_props.json`; it hard-fails before any prop check, and the live file is `mountain_props.json` (`world3d_relief.gd:42`).
2. [O] Two more stale groups: `t_sheet_load.gd:8,9,10,12` (4 absent anim PNGs, no equivalents anywhere) and `terrain3d_shot.py:25-26` (absent M0.6 PNG/JSON, hard failure).
3. [O] Five existence passes reduced 87 raw "missing" candidates to 3 real groups; 84 are templates, outputs, donor-root inputs, guarded fallbacks or resolver artefacts and must not be "fixed".
4. [D] No non-negotiable gate is impacted; the relief atom and anim smoke are unregistered, so the stale paths create a QA blind spot rather than a red gate — repoint/skip with reasons, never delete assertions.
5. [O] Pillow cp313-only bundled natives fail under Python 3.14.3 while system Pillow 12.1.1 works; donor parity stays UNVERIFIED with no Godot job from V13.

*End of V13 stale-QA-reference audit.*
