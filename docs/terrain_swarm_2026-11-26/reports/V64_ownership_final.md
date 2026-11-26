---
id: V64
ticket: "TERRAIN-SWARM-2026-11-26 / V64 — final ownership / output-collision audit (I01–I13 implementation files)"
agent: "V64 (read-only ownership/output-collision subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_ACCESS__NO_GIT_MUTATION
owner_file: docs/terrain_swarm_2026-11-26/reports/V64_ownership_final.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V64_ownership_final.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
multiple_passes: true
parity_guard: "No donor binary, donor data, donor GPU frame, Godot process, runner job, capture or gate was used. No donor visual parity claim is made or implied; parity stays UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,122-130). No gate PASS is asserted."
scope_guard: "Read-only: file reads, grep / PowerShell Select-String, git status / git diff (read-only), Test-Path / Get-ChildItem / Get-Item / Get-FileHash. No source, shader, config, asset, test, backup, git, queue, runner, Godot, donor or app/ byte was changed by this worker."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V64 — final ownership / output-collision audit

## 0. Scope, inputs and multiple-pass log

**[O] Requested context read:** `CHARTER.md`, `SWARM_BOARD.md`, `reports/V11_ownership_ledger.md`,
`reports/V44_code_review_r3.md`, all current implementation-file headers/docstrings listed in the
task. **[O] "reports/I03 completion note" is NOT on disk:** two globs and a repo-wide filename scan
found only `docs/coord_swarm_2026-11-24/reports/I03_world_render_micro.md` (unrelated older wave);
there is no `reports/I03*.md` under `terrain_swarm_2026-11-26`. V44's F-01 record
(`V44_code_review_r3.md:21,60,84-88,142,172`) was therefore used as the prior state and the live
source was audited directly. No completion claim is inferred from a missing note.

| Pass | Instrument | Result / effect |
|---|---|---|
| P1 | `glob` over `reports/**`; grep for `I03`/`completion` | Report inventory built; I03 completion note absent (above). |
| P2 | Full `read` of CHARTER / BOARD / V11 / V44 | Canonical rows N1–N16 (`V11:93-111`), EDIT rows E1–E3 (`:78-80`), generated rows G1–G11 (`:121-131`), freeze rules (`:156-162`) established. |
| P3 | First write-op scan: `grep` over all six Python tools for `--out`, `open(`, `write_text`, `write_bytes`, `mkdir`, `json.dump`, `Path.write_*`, `save(` | Candidate write sites enumerated; no literal non-owned write target found. |
| P4 | Full/section `read` of each Python tool (argparse + emission blocks) | Defaults, write gates and exact emitted filenames confirmed in context, not just by token match. |
| P5 | Second independent scan: PowerShell `Select-String` over the same six tools for write verbs, `app/`, `family_index`, `families/` | P3 reproduced; **zero** `family_index`/`families/` tokens in `decode_pattern_lib.py` — contradicts V44 E05. |
| P6 | Broad mutation scan (`shutil`, `unlink`, `rename`, `replace`, `rmtree`, `copy`, `.save`, `f.write`) | Only the already-known emission calls; no hidden file rewrite, copy or delete in any of the six tools. |
| P7 | `grep` + PowerShell scan of all GDScript/shader/test files for `FileAccess.open`, `ResourceSaver`, `DirAccess` mutations, `app/`; header/docstring `read` of each | No disk write in any donor module or shader; only the I12 result atom writes a result JSON. |
| P8 | `git status --short -- variant3d/ app/`, `git diff --unified=0 -- main.gd world3d.gd`, `Test-Path`/`Get-ChildItem` of `variant3d/assets/terrain_new/**`, `Get-Item LastWriteTimeUtc`, `Get-FileHash` | Working tree and generated-output state verified; seam is additive-only; stale F-01 artefacts located and dated (§3). |

**[O] No anomaly was accepted after one reading.** The apparent F-01 blocker was re-read with three
instruments (grep, PowerShell scan, full code read) and then cross-checked against the on-disk
artefacts and their timestamps. **[U]** No parity claim, no gate result, no run of any decoder was
performed by V64.

---

## 1. Source-path conformance — implementation file vs V11 canonical

Legend: **[O]** literal read; **[D]** deterministic consequence. Shader rename (V37 decision b,
recorded in `V44:24,136` and `HANDOFF.md:21`) is accounted for: V11 N13 canonical
`terrain_donor_shader.gdshader` is the path present; A06's `terrain_donor.gdshader` alias is absent.

| V11 row | Canonical exact path | On-disk state at this read | Verdict |
|---|---|---|---|
| N1 `:93` | `variant3d/tools/decode_donor_cfg.py` | present, owner token `TOOL_ID = "decode_donor_cfg.py/I01"` (`decode_donor_cfg.py:38`) | **PASS** |
| N2 `:94` | `variant3d/tools/decode_donor_pattern.py` | present, owner header `:2-4` | **PASS** |
| N3 `:95` | `variant3d/tools/decode_pattern_lib.py` | present, owner header `:2` | **PASS** |
| N4 `:96` | `variant3d/tools/decode_donor_masks.py` | present, owner header `:1-5` | **PASS** |
| N5 `:97` | `variant3d/tools/build_terrain_new_atlas.py` | present, owner header `:1-3` | **PASS** |
| N8 `:100` | `variant3d/scripts/terrain_donor_data.gd` | present, owner header `:1-2` (`class_name C3TerrainData` `:29`) | **PASS** |
| N9 `:101` | `variant3d/scripts/terrain_donor_gen.gd` | present, owner header `:1-2` (`class_name C3TerrainDonorGen` `:75`) | **PASS** |
| N10 `:102` | `variant3d/scripts/terrain_donor_tiles.gd` | **ABSENT** — no file to audit; owner decision V16-27 still open | **N/A (absent)** |
| N11 `:103` | `variant3d/scripts/terrain_donor_mesh.gd` | present, owner header `:3-6` | **PASS** |
| N12 `:104` | `variant3d/scripts/terrain_donor_props.gd` | present, owner header `:1-9` | **PASS** |
| N13 `:105` | `variant3d/shaders/terrain_donor_shader.gdshader` | present at canonical name; alias `terrain_donor.gdshader` absent | **PASS (rename accounted for)** |
| N14 `:106` | `variant3d/scripts/terrain_donor_world.gd` | present, I11-COMPOSER header `:3-13` | **PASS** |
| N15 `:107` | `variant3d/tests/t_terrain_donor.gd` | present, owner header `:4-5` | **PASS** |
| N16 `:108` | `variant3d/tools/terrain_qa_harness.py` | present, owner header `:1-11` | **PASS** |
| E1 `:78` | `variant3d/scripts/main.gd` | present, modified only by the I11-SEAM hunks (§5) | **PASS** |
| E2 `:79` | `variant3d/scripts/world3d.gd` | present, modified only by the I11-SEAM hunks (§5) | **PASS** |

**[O] Doc-only residue:** `terrain_donor_shader.gdshader:5` still names the retired alias
`terrain_donor.gdshader` as the owner file, although the file on disk and every consumer use the
V37 canonical name (`terrain_donor_world.gd:35`, `terrain_donor_mesh.gd:67`, `t_terrain_donor.gd:43`).
This is a stale comment, not a path violation.

---

## 2. What each file WRITES when run, and collision analysis

All paths below are emitted under the single V11/CR7 root `variant3d/assets/terrain_new/**`
(`V11:147`) unless noted. **[D]** Two current implementations write the same exact path = collision;
none was found. Filenames not present in V11 G1–G11 are recorded as **ledger gaps**, not collisions.

| Ticket / file | Default `--out` and write gate | Exact files written when run | Collision with another ticket? |
|---|---|---|---|
| I01 `decode_donor_cfg.py` | `default_out_dir()` → `variant3d/assets/terrain_new/cfg` (`:775-779`); `write = bool(args.out) and not args.dry_run` (`:787,808`); emission `:860-869` | `cfg/constants.json` (G1), `cfg/config_strings.json` (G2), **`cfg/manifest.json`** (not V11 G10 — G10 is root `terrain_new/manifest.json`) | **PASS — no collision.** `cfg/manifest.json` is unique. Ledger gap: unregistered third output. |
| I02 `decode_donor_pattern.py` | `DEFAULT_OUT = .../terrain_new/patterns` (`:87`); `--out` `:862`; dry-run default, `--no-dry-run`/`--write` `:864-868,876`; emission `:1004-1010` | `patterns/<stem>.json` for each decoded pattern, `patterns/blend_test_vectors.json`, `patterns/pattern_decode_manifest.json` | **PASS — no collision** with I03 after the fix (I03 no longer writes `patterns/`). Ledger gaps: none of these names is in G1–G11; **G3/G4 have no current emitter** (§3). |
| I03 `decode_pattern_lib.py` | `DEFAULT_OUT = .../terrain_new/lib` (`:51`); `--out` `:1069`; dry-run default, `--write` `:1073-1078`; emission `:1103-1111` | **only** `lib/pattern_lib_index.json` (`:1059-1061`) | **PASS — no collision** (I02 emits no `pattern_lib_index.json`). **Conformance FAIL vs V11 G5 `:125`**, which pins `patterns/pattern_lib_index.json`; no on-disk COORD amendment found (§3). |
| I04 `decode_donor_masks.py` | `DEFAULT_OUT = .../terrain_new/masks` (`:46`); `--write` `:585-586,591`; emission `:496-499,611-614` | `masks/mask_index.json` (G6), `masks/height/<tree>/<shape>/<stem>.height.png` (G7, path built at `:228`) | **PASS — no collision.** Exact G6/G7 match. |
| I05 `build_terrain_new_atlas.py` | `DEFAULT_OUT = .../terrain_new/atlas` (`:79-80`); `--out` `:908`; dry-run default, `--write` `:917-927`; emission `:987-994` | `atlas/tile_index_atlas.png`, `atlas/tile_index_atlas.manifest.json`, `atlas/alpha.png`, `atlas/alphavert.png`, `atlas/seasons/tile_index_atlas_winter.png`, `atlas/seasons/tile_index_atlas_winter.manifest.json`, `atlas/seasons/winter_aliases.json`, `atlas/seasons/desert_aliases.json` (`:92-97,743-771`); optional root `terrain_new/manifest.json` only with `--emit-root-manifest` (`:921-922,992-994`) | **PASS — no collision.** G8/G9/G10 match; G11 `schemas/v1.schema.json` has no emitter. `--hires-local` writes outside `terrain_new` by design and is refused under it (`:912-914,935-950`). |
| I13 `terrain_qa_harness.py` | **no default** `--out` (`:1150`); all four inputs incl. `--out` required (`:1157-1161`); single write `:1177-1180` | exactly the caller-supplied report JSON (intended N18 `inbox/qa/terrain_qa_report.json`, but **not** literal in the tool) | **PASS — no collision.** Ledger gap: no default pins N18; COORD must pass the path. |
| I12 `t_terrain_donor.gd` | fixed `const OUT_PATH := "res://tests/results/t_terrain_donor.json"` (`:33`); write at `:150-153` | `variant3d/tests/results/t_terrain_donor.json` (result artefact) | **PASS — no collision.** Repo scan shows each result atom uses its own id-named file; no other donor file writes this path. Not registered in V11 N15/E3 (ledger gap). |
| I06/I07/I08/I09/composer/shader | no file emission | none — in-memory array writes only (`terrain_donor_gen.gd:1239`); I06/I08/I09/composer are read-only consumers (headers `:25-26`, `:33-36`, `:34-47`, `:61`) | **PASS — no output at all.** |

**[O] On-disk output inventory at this read** (`git status` shows `?? variant3d/assets/terrain_new/`):
only `cfg/` (3 files) and `patterns/` (713 `*.json`, plus `family_index.json` and a 64-file
`families/` directory) exist. `lib/`, `masks/`, `atlas/`, `schemas/`, root `manifest.json`,
`tests/results/t_terrain_donor.json` and `inbox/qa/terrain_qa_report.json` are **absent**. Presence
of `cfg/`, `patterns/` etc. proves only that some tool ran earlier; it is not a gate result.

---

## 3. V44 F-01 — verified FIXED in code; stale artefacts remain

**Verdict: [O]/[D] V44 F-01 is PASS at the source level. Two residual WARNs remain (stale outputs;
G5 path). No ownership amendment to V11 was found on disk, so this is a tool-side fix, not a
ledger-side re-assignment.**

Evidence (all re-read in P3–P8):

1. `decode_pattern_lib.py:20-29` declares the V44-driven output boundary: "emits ONLY ONE file,
   `lib/pattern_lib_index.json`"; explicitly excludes the I02-owned family index, per-family
   metadata and `terrain_new/patterns` root.
2. `decode_pattern_lib.py:51` — `DEFAULT_OUT = .../terrain_new/lib`, not `.../patterns`.
3. `decode_pattern_lib.py:761-767` — `build_lib_index_doc()` docstring: "I02 exclusively owns
   decoded per-`.pattern` products; none are emitted or referenced as outputs here".
4. `decode_pattern_lib.py:996-1002` — executable boundary checks
   `emitted == ["pattern_lib_index.json"]` and `no_per_pattern_binary_json`; V44's old lines
   `:1046,1048-1049` no longer exist.
5. `decode_pattern_lib.py:1059-1061` — the entire emission dict is
   `{"pattern_lib_index.json": json_bytes(ctx["lib_index_doc"])}`; `:1103-1111` writes exactly
   those keys. Second instrument (PowerShell `Select-String`, P5) found **zero** occurrences of
   `family_index` or `families/` in this file.
6. `decode_donor_pattern.py:1004-1010` — I02 emits per-pattern JSON + two indexes; grep and
   PowerShell scans both returned **zero** `family_index`/`families` matches. Neither tool now
   writes the same path.

**Residual WARN 1 — stale artefacts.** `variant3d/assets/terrain_new/patterns/family_index.json`
(55,507,231 B; `LastWriteTimeUtc 2026-11-26 08:59:43`) and `patterns/families/` (64 JSON files) are
still on disk. Their content header still carries the old combined description seen in V44. The
current `decode_pattern_lib.py` source was written at `09:02:26` (hash
`DDFB86885B7DBF82802A385ABAF1BC9E0B51236EBA95E73F85DA501386840320`), i.e. **after** those outputs:
[D] they are pre-fix leftovers, not evidence of a live second writer. `lib/pattern_lib_index.json`
does not exist, so the fixed tool has not yet been run with `--write`. No file was deleted or
rewritten by V64.

**Residual WARN 2 — V11 G5 path mismatch.** V11 G5 (`:125`) pins I03's output to
`terrain_new/patterns/pattern_lib_index.json`; the fixed tool emits `terrain_new/lib/pattern_lib_index.json`.
Downstream, `terrain_donor_props.gd:59-60` still reads
`res://assets/terrain_new/patterns/pattern_lib_index.json` (and the now-unowned
`patterns/family_index.json`), so even a successful I03 write would not be found by the consumer
without a COORD decision. This is a **conformance/interface gap, not an output collision**.

**COORD actions required (not taken by V64):** (a) decide whether G3/G4 are retired or reassigned
and quarantine/delete the stale `family_index.json` + `families/` under file-scoped backup rules;
(b) reconcile G5 with `lib/` and update `props.gd:59` or the tool, never both silently (V28 Q1);
(c) add a shared write-collision guard to both decoders if concurrent `--write` runs remain possible.

---

## 4. Non-owned repo edits and `app/**`

| Check | Result |
|---|---|
| Python tools writing a literal non-owned repo path | **PASS** — every literal write root is V11-owned: `cfg` (`:775-779`), `patterns` (`:87`), `lib` (`:51`), `masks` (`:46`), `atlas` (`:79-80`). Broad mutation scan (P6) found no `shutil`, `unlink`, `rename`, `copy`, `rmtree` or hidden `write`. |
| `app/**` written by Python tools | **PASS** — `build_terrain_new_atlas.py:70,215,222` names `app/shots/g32_dump.json` strictly as a **read-only** input (docstring `:12,16`); `terrain_qa_harness.py:608` only *reads* `git status --short -- app/`. No Python write target resolves under `app/`. |
| Harness `RESTORE_COMMANDS` literal writes | **PASS** — `terrain_qa_harness.py:177-190` is a data tuple emitted into the report at `:978`; `:1114-1119` self-checks that no subprocess import/call exists. These commands (including the `manifest.json` rewrite at `:180`) are **not executed** by the harness. |
| GDScript/shader writes | **PASS** — no `ResourceSaver`, `FileAccess.WRITE`, `DirAccess.make_*`, `remove`, `rename` or `OS.execute` in I06/I07/I08/I09/composer or the shader; `FileAccess.file_exists` / `get_file_as_string` in `terrain_donor_mesh.gd:364`, `terrain_donor_props.gd:384-397,512-553` are reads. The only write is the I12 result atom (`t_terrain_donor.gd:33,150-153`). |
| I11-SEAM writes | **PASS** — `git diff --unified=0` shows only the four additive `main.gd` hunks (`:125`, `:188-191`, `:593-594`, `:1112-1113`) and the world3d hunks (`:117-118`, `:143-145`, `:218-224`, `:624` ternary, `:645`, `:705-707`). Pre-existing runtime writes in `main.gd` (`user://` at `:1427,1438,1446,1669`; project/capture writes at `:1845,1851`) are **unchanged legacy lines**, not I11 additions. `git status --short -- app/` is empty. |
| I12 manifest registration (E3) | **WARN (not a collision)** — `variant3d/tests/manifest.json` has **40** tests, last id `t_select_rect`, zero `t_terrain_donor` entries (V11 E3 `:80` expects 41 last). The test source is present but unregistered; no gate result is implied. |

---

## 5. PASS / FAIL per file (four required dimensions)

A = source path vs V11 canonical · B = output-path collision with another ticket ·
C = edits a non-owned repo file · D = touches `app/**`. WARN items are recorded but do not turn a
clean four-dimension audit into a false FAIL.

| File | A | B | C | D | Verdict / exact anchor |
|---|---|---|---|---|---|
| `variant3d/tools/decode_donor_cfg.py` | PASS | PASS | PASS | PASS | **PASS** — N1 `:93`; outputs `:860-869`; WARN unregistered `cfg/manifest.json` |
| `variant3d/tools/decode_donor_pattern.py` | PASS | PASS | PASS | PASS | **PASS** — N2 `:94`; outputs `:1004-1010`; WARN G3/G4 unemitted |
| `variant3d/tools/decode_pattern_lib.py` | PASS | PASS | PASS | PASS | **PASS on F-01 / conformance WARN** — N3 `:95`; `:20-29,51,996-1002,1059-1061,1103-1111`; V11 G5 `:125` mismatch; stale artefacts §3 |
| `variant3d/tools/decode_donor_masks.py` | PASS | PASS | PASS | PASS | **PASS** — N4 `:96`; outputs `:228,496-499,611-614` |
| `variant3d/tools/build_terrain_new_atlas.py` | PASS | PASS | PASS | PASS | **PASS** — N5 `:97`; outputs `:743-771,987-994`; app read-only `:70,215-222`; WARN G11 unemitted |
| `variant3d/tools/terrain_qa_harness.py` | PASS | PASS | PASS | PASS | **PASS** — N16 `:108`; only write `:1177-1180`; data-only restores `:177-190,978`; WARN no default N18 path |
| `variant3d/scripts/terrain_donor_data.gd` | PASS | PASS | PASS | PASS | **PASS** — N8 `:100`; no file IO (header `:25-26`) |
| `variant3d/scripts/terrain_donor_gen.gd` | PASS | PASS | PASS | PASS | **PASS** — N9 `:101`; no disk write (header `:7`, in-memory `:1239`) |
| `variant3d/scripts/terrain_donor_mesh.gd` | PASS | PASS | PASS | PASS | **PASS** — N11 `:103`; header `:3-6`; read-only atlas refs `:57-61` |
| `variant3d/scripts/terrain_donor_props.gd` | PASS | PASS | PASS | PASS | **PASS** — N12 `:104`; header `:5-9`; read-only feeds `:59-60` (WARN: feeds point at retired paths) |
| `variant3d/scripts/terrain_donor_world.gd` | PASS | PASS | PASS | PASS | **PASS** — N14 `:106`; header `:3-13`; module paths `:30-36`; no sim/disk write `:61` |
| `variant3d/shaders/terrain_donor_shader.gdshader` | PASS | PASS | PASS | PASS | **PASS** — canonical N13 `:105` (alias absent); stale alias in comment `:5` only |
| `variant3d/tests/t_terrain_donor.gd` | PASS | PASS | PASS | PASS | **PASS** — N15 `:107`; sole result write `:33,150-153`; WARN unregistered in manifest |
| `variant3d/scripts/main.gd` | PASS | PASS | PASS | PASS | **PASS** — E1 `:78`; additive-only diff; legacy write sites unchanged |
| `variant3d/scripts/world3d.gd` | PASS | PASS | PASS | PASS | **PASS** — E2 `:79`; additive-only seam `:117-118,624,705-707` |
| `variant3d/scripts/terrain_donor_tiles.gd` | N/A | N/A | N/A | N/A | **ABSENT** — V11 N10 `:102`; no file exists to audit |

**No active two-writer output collision was found among the audited implementation files.**
The only historical collision was V44 F-01; its emitter is fixed in source, with the stale
outputs and the G5 path decision left to COORD (§3).

---

## 6. Handoff summary (5 lines)

1. **Verdict:** all 15 present implementation files match their exact V11 canonical source paths
   (shader rename accounted for); N10 `terrain_donor_tiles.gd` remains absent. No current output-path
   collision and no non-owned repo edit or `app/**` write was found.
2. **F-01:** source-level PASS — `decode_pattern_lib.py:20-29,51,996-1002,1059-1061,1103-1111`
   emits only `lib/pattern_lib_index.json`; zero `family_index`/`families` tokens (two independent
   scans). V44's cited lines no longer exist.
3. **Residuals:** stale pre-fix `patterns/family_index.json` + 64 `patterns/families/*.json` remain
   on disk (written 08:59:43 before the 09:02:26 source fix); V11 G5 still pins `patterns/` while
   the tool writes `lib/`, and `props.gd:59-60` still reads the old path.
4. **Ledger gaps (no collision):** `cfg/manifest.json`, I02's per-pattern JSONs, I12's result JSON
   and the harness `--out` path are unregistered; G3/G4 and G11 have no current emitter; I12's
   manifest entry is absent (40 tests, no `t_terrain_donor`).
5. **Guards:** 8 multi-pass readings recorded; no code edit, git mutation, Godot job, donor access,
   gate or capture; **no donor parity claim** — parity stays UNVERIFIED / PORT APPROXIMATION.

*End of V64 report. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V64_ownership_final.md`); no source, shader, config, asset, test, backup, git, queue, runner, Godot, donor or `app/` state changed.*
