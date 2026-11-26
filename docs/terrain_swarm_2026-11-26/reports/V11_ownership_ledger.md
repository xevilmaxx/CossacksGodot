---
id: V11
ticket: "TERRAIN-SWARM-2026-11-26 / V11 — definitive implementation ownership ledger before I01–I13 dispatch"
agent: "V11 (read-only ownership-ledger subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V11_ownership_ledger.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V11_ownership_ledger.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor data, donor frame, Godot process, runner job, capture or gate was used. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Nothing below is a PASS or parity claim."
scope_guard: "Read-only: only git read commands, PowerShell Get-FileHash/certutil/Test-Path/Get-Content/Select-String/Get-ChildItem and file reads were used. No .bak file, source file, git state, queue entry or app/ byte was changed."
multiple_passes: true
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V11 — definitive implementation ownership ledger (I01–I13)

## Executive summary

1. **[O] Live tree at this read:** `HEAD=e234ac9b` (`2026-11-26 08:56:33 +0100`, `step`); `git status --short -- variant3d/` and `-- app/` are empty; `git diff --exit-code -- variant3d/` returns 0. Only `docs/terrain_swarm_2026-11-26/**` is dirty (3 modified docs + untracked reports/specs, including V04, V05, A06 and the untracked `IMPLEMENTATION_PLAN.md`). This independently confirms V04 §1/§2 and V05 §0/§6.
2. **[O] The seam is still unapplied.** `world3d.gd:108` holds only `const TERRAIN_SCRIPT := "res://scripts/world3d_terrain.gd"`, `:609` holds only `terrain = _instantiate(TERRAIN_SCRIPT)`; `Select-String` for `terrain_backend`, `TERRAIN_DONOR_SCRIPT`, `_terrain_locked` returns nothing in `world3d.gd`, and `main.gd:587,1104` still have bare `world = make_world3d()` with no setter. This is the V04 C8 / SWARM_BOARD C1 double-apply risk, still open.
3. **[D] One owner resolves it:** the seam has exactly **one COORD-named owner** ("I11-SEAM") for both `main.gd` and `world3d.gd`, with one backup suffix `COORD-I11`. A06 §2.1:89-120, V05 §4.2/§5:129-205 and `spec/12 §12.1:12-20` are the authoritative control-flow spec; `IMPLEMENTATION_PLAN.md:19` is expanded from "world3d.gd seam only" to the two-file seam because `spec/12 §12.1:13-16` already governs. No implementation worker other than this owner may touch either file.
4. **[D] A second ownership hole is closed:** the seam constant points at `variant3d/scripts/terrain_donor_world.gd` (A06 N1 `:143`; V05 §4.2 item 3 `:140`; V05 patch `:181`), but no I01–I13 ticket creates it and the file does not exist. V11 assigns it to the **same COORD owner as a new integration/composer file** ("I11-COMPOSER"), composing the disjoint I06/I07/I08/I09 modules. Without this file the seam would load a missing script.
5. **[D] All other multi-claim paths are canonicalised to the COORD ticket board:** PLAN tool names win over A03's `*_new.py` aliases; `variant3d/assets/terrain_new/**` wins over A06's `assets/terrain/donor_derived/**` and PLAN's shorthand `terrain_new/...`; I09 wins over A06 N5 for props; I10's `terrain_donor_shader.gdshader` wins over A06 N7's `terrain_donor.gdshader`; I07 owns the V09/A06-N4 `terrain_donor_tiles.gd`; I12 owns `t_terrain_donor.gd`; I13/COORD owns A05's `terrain_qa_harness.py` (absorbing A06 N9). **No donor parity claim is made or implied.**

> [!IMPORTANT]
> Labels: **[O]** literal read/output, **[D]** deterministic consequence of [O], **[I]** inference, **[U]** UNVERIFIED, **PORT APPROXIMATION** for port-authored substitutes. Hashes are SHA-256 of **working-tree bytes** (PowerShell `Get-FileHash`, cross-checked with `certutil -hashfile`); git blob ids are quoted separately because `core.autocrlf=true` (V04 §0 P6). No gate was run.

---

## §0 Multiple-pass log (owner directive, CHARTER.md:85-93)

No hash/path contradiction was accepted after a single reading. Every anomaly below was re-read with a second (and where useful third) instrument.

| Pass | Instrument(s) | Result | Effect on verdict |
|---|---|---|---|
| P1 | `git rev-parse --short HEAD`; `git log -1`; `git status --short` | `e234ac9b`; only `docs/...` modified/untracked | Matches V04 E01/E02 and V05 §0; stale A06 E12/E13 (`0e9783f2`, three dirty source files) confirmed stale again |
| P2 | `git status --short -- variant3d/`; `-- app/`; `git diff --exit-code -- variant3d/`; `git diff --name-only` | all scoped status empty; exit 0; diff list = 3 docs | Confirms P1 is not a diff-filter artefact |
| P3 | `Get-FileHash -Algorithm SHA256` over 11 port files; second `Get-FileHash` run over 4 key files; `certutil -hashfile ... SHA256` for `main.gd`/`world3d.gd`/`manifest.json`; `git hash-object` vs `git rev-parse HEAD:<path>` for 3 files | Working-tree hashes equal V04 §2 values for every overlapping file; both hash instruments agree; blob ids equal HEAD (`manifest.json` `d92f3f73…`, `world3d.gd` `638f33e6…`, `main.gd` `30262b23…`); `core.autocrlf=true` | No hash drift; CRLF difference explained, not a contradiction |
| P4 | `Select-String` on `world3d.gd`/`main.gd` for seam symbols; second `Select-String` for anchors | `world3d.gd:108,609,614,629`; `main.gd:124,587,1037,1104`; zero `terrain_backend`/`TERRAIN_DONOR_SCRIPT`/`set_terrain_backend` hits | Seam unapplied; V04 C8 still live |
| P5 | `Test-Path` over 22 candidate NEW paths; `git ls-files | Select-String`; `Get-ChildItem variant3d -Recurse -Filter '*terrain_donor*'` | All candidate paths absent; no tracked `terrain_donor*`/`decode_donor*`/`terrain_new` entries; no donor module exists | All ledger NEW rows are genuinely NEW, not re-creations |
| P6 | `git ls-files inbox/backup`; `Test-Path` for 10 proposed backup names | Many historical `.bak-*`, but `A06INT`/`COORD-I11`/`I12`/`V04` seam names absent | Backup suffixes in §4 are free; no overwrite |
| P7 | Re-read A06 §2.1/§2.2, V05 §4/§5, `IMPLEMENTATION_PLAN.md:7-21`, `spec/12 §12.1-12.4`, A03 §2.2, V09 §5, A05 §7 | Path contradictions enumerated (composer, shader, tool aliases, output root, tiles, QA harness) | Resolved by one-owner canonicalisation in §4; unresolved items moved to §9 as [U] |

**[O] No anomaly was silently skipped.** Remaining unknowns are listed in §9.

---

## §1 Evidence table (current tree, [O] unless labelled)

| ID | Source (file:line / command) | Observation | Consequence |
|---|---|---|---|
| E01 | `git rev-parse --short HEAD`; `git log -1` (P1) | `e234ac9b`, 2026-11-26 08:56:33 +0100 | V04/V05 audit baseline is current; A06 E12's `0e9783f2` is stale |
| E02 | `git status --short -- variant3d/`, `-- app/`, `git diff --exit-code` (P2) | empty, empty, exit 0 | Every EDIT file below is at committed baseline; no pre-existing worker edit to preserve |
| E03 | `Get-FileHash` + `certutil` (P3) | `main.gd` `3859B605…`; `world3d.gd` `44EE96C0…`; `config.gd` `160F08C0…`; `tests/manifest.json` `408F4C83…`; legacy files match V04 §2 | Exact EDIT baseline SHAs for ledger |
| E04 | `variant3d/scripts/world3d.gd:108,609,614,629`; `main.gd:124,185,587,1037,1104` (P4) | one `TERRAIN_SCRIPT`, no `terrain_backend`, two bare `make_world3d()` sites | Seam must be applied once, at both sites, by one owner |
| E05 | `spec/12 §12.1:12-20` | "Exactly two files are edited, additively" — `main.gd` 4 inserts, `world3d.gd` const/var/setter/ternary `:609`/stats; default `"legacy"` | Authoritative seam against which the ledger is built |
| E06 | `A06_integration.md:89-120,141-154` | A06 claims `main.gd`+`world3d.gd` seam and N1–N11 new files (`terrain_donor_world.gd`, `terrain_donor_mask/height/tiles/props/water.gd`, `terrain_donor.gdshader`, `terrain_donor_compile.py`, `terrain_donor_verify.py`, `donor_derived/**`, `t_terrain_donor.gd`) | Origin of most conflict flags |
| E07 | `V05_seam_reconciliation.md:129-140,156-205,259` | Same two-file seam; patch sketch text-only; V05 Q1/Q2/Q3 open; V05 §4.3 `:145-149` forbids legacy edits and stage-2 manifest edit | Confirms one-owner requirement and timing constraint |
| E08 | `IMPLEMENTATION_PLAN.md:7-21,34-38` | I01–I13 paths; I11 = `world3d.gd` seam only; I12 registers in manifest LAST; I13 = COORD QA; ordering I01–I05 → I06–I10 → I11–I12 → I13 | COORD ticket paths are canonical where they exist |
| E09 | `V04_tree_conflicts.md:25,148-164,167-175` | C8 seam HIGH risk; all port files clean; `.bak-*` are committed baselines; V04 Q2 asks for one owner | Ledger answers V04 Q1–Q3 by reserving one owner/suffix |
| E10 | `spec/11 §11.1:8-12, §11.4:40-55, §11.7:75-91`; `A03_asset_pipeline.md:88-98,274-279` | Canonical output root `variant3d/assets/terrain_new/**`; A03 tool names carry `_new` suffix and several tools are unassigned by I01–I13 | Alias resolution in §4 CR5/CR6 |
| E11 | `V09_2d_order_transplant.md:431-458` | V09 asks to create `variant3d/scripts/terrain_donor_tiles.gd`; A06 N4 `:146` names the same path | Two design claimants, one implementation owner assigned (I07) |
| E12 | `A05_qa_harness.md:242-243,321-338`; spec/12 §12.6:96-97 | Planned `variant3d/tools/terrain_qa_harness.py`, `spec/terrain_qa_spec.json`, `terrain_qa_report/1` with `parity.status="UNVERIFIED"` | I13/COORD owns these; no parity claim by construction |
| E13 | `A01_data_model.md:208,358`; `A03_asset_pipeline.md:254,345` | A01 proposes `terrain_donor_data.gd` skeleton; A03 proposes `terrain_new_assets.gd` "owned by another worker" | Design claims, not implementation owners; resolved in §4 |
| E14 | P5/P6 (this report) | 22 NEW candidate paths absent; proposed backup names absent; all 4 QA/generated paths absent | Ledger is a pre-dispatch creation ledger, not a description of existing files |
| E15 | `CHARTER.md:26-30,66-94`; parity_guard above | Read-only donor, labels mandatory, no invented constants, no fake A/B, multiple passes required | **[U]** No parity verdict and no gate result in this report |

---

## §2 Ownership ledger — EDIT files (SHA-256 of working-tree bytes at `e234ac9b`)

One row = one file = one owner. Backup names are **reserved, not created** by V11.

| # | Exact path | Kind | Owner (single) | SHA-256 at read | Baseline backup (reserved) | Other claimants / conflict flag | Per-file verification command |
|---|---|---|---|---|---|---|---|
| E1 | `variant3d/scripts/main.gd` | EDIT (4 additive inserts) | **COORD seam owner (I11-SEAM)** | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` | `inbox/backup/main.gd.bak-COORD-I11` | A06 §2.1 `:91-102`; V05 §4.2 item 1 `:129-132`, §5 `:156-169`; `spec/12 §12.1:13-14`; IMPLEMENTATION_PLAN `:19` (I11, world3d-only wording). **FLAG: HIGH — C8** | `Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\main.gd'; Select-String -LiteralPath 'variant3d\scripts\main.gd' -Pattern 'terrain_backend\|set_terrain_backend'` (pre-edit: hash above, **no hits**; post-edit: 1 var + 1 read + 2 setter calls) |
| E2 | `variant3d/scripts/world3d.gd` | EDIT (const + 2 vars + setter + ternary `:609` + `_terrain_locked` + 2 stats keys) | **COORD seam owner (I11-SEAM)** | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` | `inbox/backup/world3d.gd.bak-COORD-I11` | A06 §2.1 `:103-117`; V05 §4.2 item 2 `:133-139`, §5 `:179-204`; `spec/12 §12.1:15-16`; PLAN I11 `:19`; CHARTER `:60-61`; V04 C8 `:159`. **FLAG: HIGH — C8** | `Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\world3d.gd'; Select-String -LiteralPath 'variant3d\scripts\world3d.gd' -Pattern 'TERRAIN_SCRIPT\|TERRAIN_DONOR_SCRIPT\|terrain_backend'` (pre-edit: only `:108,:609`; post-edit: exactly one const, one ternary, one setter, 2 stats keys) |
| E3 | `variant3d/tests/manifest.json` | EDIT (append-only, LAST entry only) | **I12 (test owner)** | `408F4C83A5EC5DDD018880611657DB1297D3878B1D842DC4806AE87D5F9AD64B` | `inbox/backup/tests_manifest.json.bak-I12` | PLAN I12 `:20` ("registers in manifest LAST"); A06 N11 `:153` and §3.3 `:314-316` (append-only, manifest owner); V05 §4.3 `:146` says zero manifest edits **at stage 2**. **FLAG: MEDIUM — timing** (stage 3 only) | `Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\tests\manifest.json'; (Get-Content -Raw 'variant3d\tests\manifest.json' \| ConvertFrom-Json).tests.Count` (pre: hash above, count **40**; post: 41, last id `t_terrain_donor`) |
| E4 | `variant3d/scripts/config.gd` | EDIT — **conditional stage 4 only**, not part of I01–I13 dispatch | **Deferred config owner (COORD-STAGE4)** | `160F08C098CF2F29172EAD66E4414A0C0291D7E338DB1798A41D8A777DE8F1A3` | `inbox/backup/config.gd.bak-COORD-STAGE4` | A06 §2.4 `:219-223` and §3.1 `:278-284` (proposed `.bak-A06INT`); V05 §4.2 item 4 `:141`, Q5 `:262`; `spec/12 §12.3:40` gate 5. **FLAG: MEDIUM — conditional; zero edits at stage 2** | `Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\config.gd'; Select-String -LiteralPath 'variant3d\scripts\config.gd' -Pattern 'backend'` (pre: hash above, no `backend` key; stage 4 only with owner ticket) |

**[O] Ambiguity resolved:** A06's generic `manifest.json.bak-A06INT` would collide with `variant3d/assets/models/manifest.json`; V11 reserves the unambiguous `tests_manifest.json.bak-I12` for E3. **[O] No `.bak-COORD-I11`, `.bak-I12`, `.bak-COORD-STAGE4` or `.bak-V04` name exists at this read (P6).**

---

## §3 Ownership ledger — NEW files (creation ledger; rollback = delete, no pre-edit backup)

Every path below returned `Test-Path = False` in P5/P6. `N/A` backup = new file, not an edit; rollback is deletion by owner plus removal of the single manifest entry where applicable.

| # | Exact path | Kind | Owner (single) | SHA-256 | Backup | Other claimants / conflict flag | Per-file verification command |
|---|---|---|---|---|---|---|---|
| N1 | `variant3d/tools/decode_donor_cfg.py` | NEW | **I01** | N/A | N/A (creation) | A03 `decode_donor_cfg_new.py` `:90,275`; P04 `:82,132`; spec/11 §11.7 `:75-78`. **FLAG: MEDIUM — alias** | `Test-Path -LiteralPath 'variant3d\tools\decode_donor_cfg.py'` (False → True) |
| N2 | `variant3d/tools/decode_donor_pattern.py` | NEW | **I02** | N/A | N/A | A03 `decode_donor_pattern_new.py` `:88,274`; P04 `:87,132`. **FLAG: MEDIUM — alias** | `Test-Path -LiteralPath 'variant3d\tools\decode_donor_pattern.py'` |
| N3 | `variant3d/tools/decode_pattern_lib.py` | NEW | **I03** | N/A | N/A | F02 pattern.lib spec + X05 prototype are research claims, not file owners. **FLAG: LOW** | `Test-Path -LiteralPath 'variant3d\tools\decode_pattern_lib.py'` |
| N4 | `variant3d/tools/decode_donor_masks.py` | NEW | **I04** | N/A | N/A | A03 `decode_donor_mask_new.py` `:92,276`; P04 `:85,112,132`. **FLAG: MEDIUM — alias** | `Test-Path -LiteralPath 'variant3d\tools\decode_donor_masks.py'` |
| N5 | `variant3d/tools/build_terrain_new_atlas.py` | NEW | **I05** | N/A | N/A | A03 `:93,277`; spec/11 §11.7 `:86`. **FLAG: LOW — path already canonical** | `Test-Path -LiteralPath 'variant3d\tools\build_terrain_new_atlas.py'` |
| N6 | `variant3d/tools/build_terrain_new_manifest.py` | NEW (secondary tool, [D] V11 resolution) | **I05** | N/A | N/A | A03 `:216,278`; unassigned by PLAN. **FLAG: LOW — A03 tool folded into I05** | `Test-Path -LiteralPath 'variant3d\tools\build_terrain_new_manifest.py'` |
| N7 | `variant3d/tools/validate_terrain_new.py` | NEW ([D] V11 resolution) | **I13 / COORD** | N/A | N/A | A03 `:279,286`; unassigned by PLAN. **FLAG: LOW — folded into I13** | `Test-Path -LiteralPath 'variant3d\tools\validate_terrain_new.py'` |
| N8 | `variant3d/scripts/terrain_donor_data.gd` | NEW (SoA + additive `fields`) | **I06** | N/A | N/A | A01 `:208,358` proposes a skeleton in this exact path. **FLAG: MEDIUM — design claim** | `Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_data.gd'` |
| N9 | `variant3d/scripts/terrain_donor_gen.gd` | NEW (stage pipeline + RNG ledger) | **I07** | N/A | N/A | A06 N2 `:144` (`terrain_donor_mask.gd`) and N3 `:145` (`terrain_donor_height.gd`) overlap by role, not path. **FLAG: MEDIUM — role overlap** | `Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_gen.gd'` |
| N10 | `variant3d/scripts/terrain_donor_tiles.gd` | NEW ([D] V11 resolution of two claimants) | **I07** (secondary module) | N/A | N/A | A06 N4 `:146`; V09 `:431-458`. **FLAG: HIGH — two external claimants, one owner** | `Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_tiles.gd'` |
| N11 | `variant3d/scripts/terrain_donor_mesh.gd` | NEW (one ArrayMesh, UV2, water bind) | **I08** | N/A | N/A | A06 N1 `:143` has the composer build the mesh (different path). **FLAG: LOW — I08 owns mesh only** | `Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_mesh.gd'` |
| N12 | `variant3d/scripts/terrain_donor_props.gd` | NEW | **I09** | N/A | N/A | A06 N5 `:147` claims this **exact path**. **FLAG: HIGH — resolved to I09** | `Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_props.gd'` |
| N13 | `variant3d/shaders/terrain_donor_shader.gdshader` | NEW (only if needed) | **I10** | N/A | N/A | A06 N7 `:149` claims `terrain_donor.gdshader`. **FLAG: HIGH — path conflict, resolved to PLAN path** | `Test-Path -LiteralPath 'variant3d\shaders\terrain_donor_shader.gdshader'` |
| N14 | `variant3d/scripts/terrain_donor_world.gd` | NEW — **single COORD integration/composer file** | **COORD seam owner (I11-COMPOSER)** | N/A | N/A | A06 N1 `:143`; V05 §4.2 item 3 `:140`, patch `:181`, Q6 `:263`; **absent from PLAN**. **FLAG: HIGH — seam const depends on it** | `Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_world.gd'`; must exist before E1/E2 are applied |
| N15 | `variant3d/tests/t_terrain_donor.gd` | NEW (determinism + telemetry atom) | **I12** | N/A | N/A | A06 N11 `:153` same path. **FLAG: MEDIUM — resolved to I12** | `Test-Path -LiteralPath 'variant3d\tests\t_terrain_donor.gd'` |
| N16 | `variant3d/tools/terrain_qa_harness.py` | NEW ([D] canonical QA tool) | **I13 / COORD** | N/A | N/A | A05 §7 `:242-243`, §5 `:321-338`; A06 N9 `:151` `terrain_donor_verify.py` is an alias. **FLAG: MEDIUM — one QA tool only** | `Test-Path -LiteralPath 'variant3d\tools\terrain_qa_harness.py'` |
| N17 | `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | NEW (QA thresholds, advisory → red only after signed spec) | **I13 / COORD** | N/A | N/A | A05 `:323`; spec/12 §12.6 `:82-84`. **FLAG: LOW** | `Test-Path -LiteralPath 'docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json'` |
| N18 | `inbox/qa/terrain_qa_report.json` | NEW (generated, `terrain_qa_report/1`, `parity.status="UNVERIFIED"`) | **I13 / COORD** | N/A | N/A | A05 §7 `:242-276`; no path pinned there ([D] V11 chooses this exact path). **FLAG: LOW** | `Test-Path -LiteralPath 'inbox\qa\terrain_qa_report.json'` |
| N19 | `inbox/qa/captures/` | NEW (generated 240²/320² captures, COORD-owned) | **I13 / COORD** | N/A | N/A | A05 visual layer `:85-91`; PLAN I13 `:21`. **FLAG: LOW** | `Test-Path -LiteralPath 'inbox\qa\captures'` |

---

## §4 Ownership ledger — generated derived assets (NEW, regenerable; no donor binary)

Canonical root is **`variant3d/assets/terrain_new/`** (`spec/11 §11.1:8-12`, §11.4 `:40-50`; A03 `:43`). All paths below were absent at P5. Wildcards denote donor-driven name sets; the **directory + filename pattern** is the exact ledger entry and the emitted names must be recorded in the root manifest.

| # | Exact path / pattern | Kind | Owner | Backup | Other claimants / conflict flag | Per-file verification command |
|---|---|---|---|---|---|---|
| G1 | `variant3d/assets/terrain_new/cfg/constants.json` | NEW output | **I01** | N/A (regenerate) | PLAN `:9` says `terrain_new/cfg/constants.json`; A03 `:275`/spec/11 `:49` say `assets/terrain_new/cfg/constants.json`. **FLAG: MEDIUM — root spelling, resolved** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\cfg\constants.json'` |
| G2 | `variant3d/assets/terrain_new/cfg/config_strings.json` | NEW output | **I01** | N/A | PLAN `:9`; A03 `:275`; spec/11 `:49`. **FLAG: MEDIUM — root spelling** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\cfg\config_strings.json'` |
| G3 | `variant3d/assets/terrain_new/patterns/family_index.json` | NEW output | **I02** | N/A | A03 `:274` / spec/11 `:47`. **FLAG: LOW** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\patterns\family_index.json'` |
| G4 | `variant3d/assets/terrain_new/patterns/families/<family>.json` | NEW output set | **I02** | N/A | A03 `:274` / spec/11 `:47`. **FLAG: LOW** | `Get-ChildItem -LiteralPath 'variant3d\assets\terrain_new\patterns\families' -Filter '*.json'` |
| G5 | `variant3d/assets/terrain_new/patterns/pattern_lib_index.json` | NEW output ([D] V11 disambiguation from G3) | **I03** | N/A | PLAN I03 `:11`; F02 report (data spec). **FLAG: LOW — exact name is V11 choice** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\patterns\pattern_lib_index.json'` |
| G6 | `variant3d/assets/terrain_new/masks/mask_index.json` | NEW output | **I04** | N/A | A03 `:276` / spec/11 `:48`. **FLAG: LOW** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\masks\mask_index.json'` |
| G7 | `variant3d/assets/terrain_new/masks/height/<shape>/*.height.png` | NEW output set | **I04** | N/A | A03 `:276` / spec/11 `:48`. **FLAG: LOW** | `Get-ChildItem -LiteralPath 'variant3d\assets\terrain_new\masks\height' -Recurse -Filter '*.height.png'` |
| G8 | `variant3d/assets/terrain_new/atlas/{tile_index_atlas.png,tile_index_atlas.manifest.json,alpha.png,alphavert.png}` | NEW outputs | **I05** | N/A | A03 `:277`; spec/11 `:46`; PLAN I05 `:13`. **FLAG: LOW** | `Get-ChildItem -LiteralPath 'variant3d\assets\terrain_new\atlas' -File \| Select-Object Name` |
| G9 | `variant3d/assets/terrain_new/atlas/seasons/` | NEW output set (winter aliases) | **I05** | N/A | A03 `:277`; spec/11 `:46`. **FLAG: LOW** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\atlas\seasons'` |
| G10 | `variant3d/assets/terrain_new/manifest.json` | NEW output (provenance/pack) | **I05** (via N6) | N/A | A03 `:216,278`; spec/11 `:44`. **FLAG: LOW** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\manifest.json'` |
| G11 | `variant3d/assets/terrain_new/schemas/v1.schema.json` | NEW output | **I05** | N/A | spec/11 `:45`. **FLAG: LOW** | `Test-Path -LiteralPath 'variant3d\assets\terrain_new\schemas\v1.schema.json'` |

**[D] Explicitly not owned / not created:** `variant3d/assets/terrain/donor_derived/**` (A06 N10 `:152`) is retired in favour of G1–G11; `variant3d/scripts/terrain_new_assets.gd` (A03 `:254,345`) has **no implementation owner** in I01–I13 and must not be silently created — see Q4.

---

## §5 Conflict resolutions (one owner per file)

| # | Conflict | Claimants | Resolution (binding for dispatch) | Label |
|---|---|---|---|---|
| CR1 | Seam double-apply (`world3d.gd:108,609`, `main.gd:587,1104`) | A06 §2.1; V05 §4/§5; `spec/12 §12.1`; PLAN I11; V04 C8 | **One owner: COORD seam owner (I11-SEAM)** edits E1+E2 in one integration commit; default `"legacy"`; eight anchors only; backup suffix `COORD-I11`. No other worker may edit either file (§6). | [D] |
| CR2 | PLAN I11 says "`world3d.gd` seam only" but spec/12/A06/V05 require `main.gd` too | PLAN `:19` vs `spec/12 §12.1:13-16` | `spec/12` governs; I11 is widened to cover both files and renamed in the ledger as I11-SEAM. | [D] |
| CR3 | Composer path `terrain_donor_world.gd` claimed by A06/V05 but absent from PLAN | A06 N1 `:143`; V05 `:140,181,263` | **N14 created by the same COORD owner** as I11-COMPOSER, before the seam; it composes I06/I07/I08/I09, owns one mesh/water/environment and the six-method public surface. No second composer. | [D] |
| CR4 | Props file double ownership | I09 vs A06 N5 `:147` | **I09 sole owner** of `terrain_donor_props.gd`; reuse committed Z08 `world3d_relief.gd` and `TerrainmeshProps_*` read-only (`world3d_relief.gd:3-8,206-253`; V04 E11/C3); no second silhouette layer. | [D] |
| CR5 | Shader path `terrain_donor_shader.gdshader` (I10) vs `terrain_donor.gdshader` (A06 N7) | PLAN `:18` vs A06 `:149` | **I10 path canonical**; A06 N7 alias retired; legacy `terrain_tileindex.gdshader` absolutely frozen (V04 E08). New shader only if §06/§05 prove it necessary. | [D] |
| CR6 | Tool name aliases `decode_donor_cfg.py` vs `decode_donor_cfg_new.py`, etc. | PLAN I01–I04 vs A03 `:88-98,274-279` / P04 `:132` / spec/11 §11.7 | **PLAN names canonical** (N1–N4); A03 `_new.py` names are aliases, not separate files. A03's unassigned `build_terrain_new_manifest.py` → I05 (N6); `validate_terrain_new.py` → I13 (N7). A06 N8 `terrain_donor_compile.py` is folded into I01–I04. | [D] |
| CR7 | Output root: PLAN shorthand `terrain_new/cfg/...`; A03 `assets/terrain_new/**`; A06 `assets/terrain/donor_derived/**` | PLAN `:9`; spec/11 `:8-12,40-50`; A06 N10 `:152` | **Single root `variant3d/assets/terrain_new/**`** (G1–G11). No `assets/terrain/donor_derived/` directory is created. Legacy `assets/terrain/**` read-only. | [D] |
| CR8 | `terrain_donor_tiles.gd` claimed twice, absent from PLAN | A06 N4 `:146`; V09 `:436` | **I07 sole owner** (N10) as a secondary disjoint module; V09's `assign_tileblocks(brng)` recipe is the implementation input; I08 consumes tile ids, never reassigns them. | [D] |
| CR9 | QA tool duplication: A05 `terrain_qa_harness.py` vs A06 N9 `terrain_donor_verify.py` vs I12 atom | A05 `:242-243`; A06 `:151`; PLAN I12/I13 | **N16 is the one Python QA tool** (I13/COORD); A06 N9 alias retired. N15 `t_terrain_donor.gd` is a distinct Godot atom owned by I12; no second determinism tool. | [D] |
| CR10 | Manifest registration timing | PLAN I12 `:20`; A06 N11 `:153`; V05 §4.3 `:146` (no stage-2 manifest edit) | I12 appends **one entry, LAST, in stage 3 only**; E3 backup taken immediately before; rollback removes that one id, never restores the whole file. | [D] |
| CR11 | Backup suffix collision (`A06INT`/`A06MOD`, `V04`, generic `<TICKET>`, V05 Q3) | A06 §3 `:265-316`; V04 §7 `:178-208`; PLAN `:5`; V05 Q1 `:258` | Reserve **`COORD-I11`** for E1+E2, **`I12`** for E3, **`COORD-STAGE4`** for E4 (conditional). V11 created none; never overwrite an older `.bak`. | [D] |
| CR12 | Git-state premise drift | A06 E12/E13; P06 §5.1; V05 §0; V04 §0 | All agree after 2–6 passes that edits are committed at `e234ac9b`; treat as landed baseline, no re-apply, no broad restore. **[U]** a new commit could invalidate line numbers — re-read before applying. | [O]/[U] |

---

## §6 Edit-freeze rule (binding on every I01–I13 worker)

1. **[D] Absolute freeze — zero edits by any implementation worker:** `variant3d/scripts/game.gd` (`B4E4E875…`), `variant3d/scripts/world3d_terrain.gd` (`983DA45F…`), `variant3d/scripts/world3d_relief.gd` (`9368D7DF…`), `variant3d/shaders/terrain_tileindex.gdshader` (`F5286125…`), `variant3d/shaders/water3d.gdshader`, `variant3d/scripts/water3d.gd` (`BEEF3B66…`), `variant3d/project.godot` (`FA2E4F5C…`), `variant3d/tests/t_*.gd`, `variant3d/assets/terrain/**`, legacy tools under `variant3d/tools/**`, and **all of `app/**`**. Rationale: V04 §3.1-§3.6/§4 C1-C7, V05 §4.3 `:145-149`, A06 §2.6 `:255-259`, CHARTER `:26-30,83-84`. New modules are read-only consumers of the dump contract (`spec/01 §4:55-66`; `A06 §2.3:174-192`); no `height[]`/`tileblock`/RNG/`pattern_stamps` writes.
2. **[D] Conditioned freeze:** `main.gd` and `world3d.gd` may be edited **only by the COORD seam owner (I11-SEAM)**, in one integration commit, using V05 §5's patch shape. No other ticket may add a const, a var, a setter call, a ternary or a stats key to those two files. `config.gd` may be edited only by the deferred stage-4 config owner after a separate owner decision (E4); `tests/manifest.json` only by I12 as the last append (E3).
3. **[D] Forbidden operations during any implementation or rollback:** `git reset --hard`, `git checkout -- .`, `git clean -fd`, `Copy-Item <(git show HEAD:...)>`, or any blanket restore — uncommitted docs work (E01/E02) would be destroyed (V04 §7.4; A06 §3.4; CHARTER `:73-75`). Use only file-scoped `Copy-Item inbox/backup/<name>.bak-<TICKET>` with SHA verification.
4. **[D] Pre-edit gate:** before E1/E2/E3/E4 are touched, re-run P1–P4; if any EDIT hash differs from §2 or any seam symbol already exists, **STOP** and re-audit (V04 §7.1 acceptance rule). If `app/` is dirty, stop.
5. **[D] Parse-before-switch:** N14 and its composed modules N8–N13 must exist and parse before E1/E2 are applied (A06 §2.2 ordering `:156-158`; V05 R1/R6). A partial land must never flip a gate onto a half-built backend.

---

## §7 Exact order of application

```
Pass 0  COORD preflight (read-only): P1–P6; spec sections READY; reserve backups §2;
        confirm no implementation worker is inside the freeze (§6). No file written yet.
Stage A I01 → I02 → I03 → I04 → I05 → N6 (manifest)     [tools + G1–G11 derived assets]
        Dry-run default; --out refuses the donor root; no asset under assets/terrain/**.
Stage A' I13/COORD runs N7 validate_terrain_new.py --strict + A05 harness preflight;
        records hashes/labels; no Godot job yet unless COORD grants one unique --id.
Stage B I06 → I07 (+N10 tiles) → I08 → I09 → I10 (only if needed) → N14 (COORD composer)
        All new files; no seam file touched; read-only on all sim state.
Stage C E1+E2 by COORD seam owner in ONE commit (main.gd 4 inserts; world3d.gd const/
        vars/setter/ternary :609/_terrain_locked/2 stats keys); verify §2 commands.
Stage C' I12 creates N15 then appends E3 LAST; verify count 40 → 41 and id order.
Stage D I13/COORD: gates + N16/N17/N18/N19 (240²/320² capture); honest parity verdict
        UNVERIFIED unless a real donor GPU A/B frame exists (it does not at this read).
Deferred E4 config.gd stage-4 default flip: separate owner ticket, separate backup,
        separate commit; never in the module-landing commit (A06 §2.4:219-223).
Rollback reverse order: remove E3 entry → restore E2/E1 from .bak-COORD-I11 →
        delete N14 → delete N10–N13 modules → delete N15 → keep inert tools/assets
        (A06 §3.2-§3.3:286-316). Never delete .bak files.
```

**[D] This matches IMPLEMENTATION_PLAN.md:34-38 (I01–I05 → I06–I10 → I11–I12 → I13) with N14 inserted at the head of the integration step and I13's Python tooling split out as Stage A′/D.**

---

## §8 Verification commands (copy/paste from repo root; no job is run by V11)

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
# V11 preflight — must be identical to §0 P1-P6
git rev-parse --short HEAD
git status --short -- variant3d/; git status --short -- app/
git diff --exit-code -- variant3d/
Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\main.gd','variant3d\scripts\world3d.gd','variant3d\scripts\config.gd','variant3d\tests\manifest.json' | Format-Table -AutoSize
certutil -hashfile "variant3d\scripts\world3d.gd" SHA256
Select-String -LiteralPath 'variant3d\scripts\world3d.gd' -Pattern 'TERRAIN_SCRIPT|TERRAIN_DONOR_SCRIPT|terrain_backend|_terrain_locked'
Select-String -LiteralPath 'variant3d\scripts\main.gd' -Pattern 'terrain_backend|set_terrain_backend'
# NEW-file check (repeat with each N/G path from §3/§4)
Test-Path -LiteralPath 'variant3d\scripts\terrain_donor_world.gd'
Test-Path -LiteralPath 'variant3d\tests\t_terrain_donor.gd'
Test-Path -LiteralPath 'variant3d\shaders\terrain_donor_shader.gdshader'
# reserved backups must not pre-exist
Test-Path -LiteralPath 'inbox\backup\main.gd.bak-COORD-I11','inbox\backup\world3d.gd.bak-COORD-I11','inbox\backup\tests_manifest.json.bak-I12','inbox\backup\config.gd.bak-COORD-STAGE4'
# post-edit seam sanity (exactly one of each expected)
Select-String -LiteralPath 'variant3d\scripts\main.gd' -Pattern 'set_terrain_backend\(' | Measure-Object
Select-String -LiteralPath 'variant3d\scripts\world3d.gd' -Pattern 'TERRAIN_DONOR_SCRIPT' | Measure-Object
(Get-Content -Raw 'variant3d\tests\manifest.json' | ConvertFrom-Json).tests.Count
# freeze check: zero diff on the absolute-freeze set
git diff --exit-code -- variant3d/scripts/game.gd variant3d/scripts/world3d_terrain.gd variant3d/scripts/world3d_relief.gd variant3d/shaders/terrain_tileindex.gdshader variant3d/project.godot app/
```

**Acceptance:** pre-edit hashes equal §2; `terrain_backend` hits = 0; `app/` empty; after landing, one const/setter/ternary and two `set_terrain_backend()` call sites; manifest count 41 with `t_terrain_donor` last; freeze diff exit 0. Gates (selftest 29/29, uitest 17/17, `t_render_mode` 10/10 `seam_missing=false`, `assert_clean CLEAN`) are **COORD/I13-owned and were not run by V11**.

---

## §9 Risks

| # | Risk | Label | Mitigation / evidence |
|---|---|---|---|
| R1 | Two workers apply the seam → duplicate `set_terrain_backend()` and `stats` keys | [D] HIGH | §6 rule 2; one COORD owner, one commit, backup `COORD-I11` (V04 C8; V05 R2/R7) |
| R2 | Seam const points at a file nobody creates → missing script at runtime | [D] HIGH | N14 owned by same COORD owner and created before Stage C (CR3) |
| R3 | Two tools with `_new`/non-`_new` names, or two QA tools, land together | [D] MEDIUM | CR6/CR9 canonical names; `git ls-files` + `Test-Path` before dispatch |
| R4 | Two derived-asset roots (`terrain_new` vs `donor_derived`) with duplicate silhouettes | [D] MEDIUM | CR7 single root; legacy `assets/terrain/**` read-only |
| R5 | Manifest append by two owners or whole-file restore loses 40 existing entries | [D] MEDIUM | CR10; backup `tests_manifest.json.bak-I12`; id-level removal on rollback |
| R6 | Stage-4 config flip bundled into module landing makes rollback ambiguous | [D] MEDIUM | E4 deferred ticket; A06 §2.4 `:219-223` |
| R7 | Stale A06/P06 git register drives a destructive restore | [O]/[D] MEDIUM | P1–P3 re-check; §6 rule 3 forbidden list |
| R8 | New module writes sim state or adds RNG draws → seed replay / 2D gates drift | [D] HIGH | read-only guard (`world3d_relief.gd:3-8`); A05 determinism layer; no threshold lowered |
| R9 | Two water planes / two `WorldEnvironment` nodes | [D] HIGH | exclusivity at `world3d.gd:609`; one mesh/water/environment in N14 (V05 R1; A06 §2.5) |
| R10 | Stale Z07 `t_relief_props_qa.gd` atom (`expected_pre_fix_failure: true`) is "fixed" by lowering expectation | [U]/PORT APPROX LOW | V04 E13/C10; strengthen only, no fake PASS; owner still open (V04 Q5) |
| R11 | CRLF (`core.autocrlf=true`) makes SHA-256 look different from git blob id | [O] LOW | report both instruments; §2 uses working-tree bytes only (V04 §0 P6) |
| R12 | Any visual "improvement" is mistaken for donor parity | [U]/PORT APPROX HIGH | no donor frame used by V11; A05 schema pins `parity.status="UNVERIFIED"`; CHARTER `:43-44,125` |
| R13 | Line numbers drift with a new commit before dispatch | [U] MEDIUM | all anchors are `e234ac9b`-only; P1–P4 re-run immediately before E1/E2 |

---

## §10 Open questions for COORD

1. **Q1.** Confirm CR1/CR2: I11-SEAM is the sole owner of `main.gd`+`world3d.gd` and `COORD-I11` is the reserved suffix (closes V04 Q2/Q3, V05 Q1/Q3, A06 Q1).
2. **Q2.** Confirm CR3: N14 `terrain_donor_world.gd` is folded into I11 as I11-COMPOSER (or name a different single owner) before any seam edit; V05 Q6 and A06 N1 then close.
3. **Q3.** Confirm CR5/CR6: shader path `terrain_donor_shader.gdshader` and PLAN tool names are canonical; A03 `_new.py`, A06 N7/N8 and A06 N9 aliases are retired, not created.
4. **Q4.** Who owns `variant3d/scripts/terrain_new_assets.gd` (A03 `:254,345`)? V11 leaves it **unowned on purpose**; I01–I13 have no slot for it. Does I06 absorb it or is a new ticket required?
5. **Q5.** Confirm CR8: I07 owns both `terrain_donor_gen.gd` and `terrain_donor_tiles.gd`. If "one owner file per worker" is enforced literally (`IMPLEMENTATION_PLAN.md:5`), split N10 into a new ticket rather than assigning a second file to I07.
6. **Q6.** Confirm N16/N17/N18/N19 paths and the `inbox/qa/` root for I13 outputs; A05 pins no exact output path ([D] V11 choice).
7. **Q7.** Confirm E3 timing: manifest append in stage 3 (V05 §4.3) and not during stage 2; confirm `tests_manifest.json.bak-I12` over A06's ambiguous `manifest.json.bak-A06INT`.
8. **Q8.** [U] V05 E25/Q2 and `spec/13` still describe V04 as "not landed"; V04's report now exists (untracked). COORD integrates that contradiction register update; V11 does not edit those files.

---

## §11 Handoff summary (5 lines)

1. **Verdict:** `HEAD=e234ac9b`, all port files clean, seam still unapplied (`world3d.gd:108,609`); one COORD seam owner (I11-SEAM) owns both `main.gd` and `world3d.gd`, with one backup suffix `COORD-I11` — V04 C8 resolved on paper.
2. **Ledger:** 4 EDIT files (SHAs `3859B605…`, `44EE96C0…`, `408F4C83…`, `160F08C0…` conditional), 19 NEW source/tool/test files and 11 regenerable derived-asset entries, each with one owner, a reserved backup or creation ledger, and a per-file verification command.
3. **Conflict resolutions:** COORD integration file `terrain_donor_world.gd` (I11-COMPOSER) closes the missing-composer hole; I09/I12/I10 canonical paths beat A06 aliases; A03 `_new.py` tools alias into I01–I04; single derived root `variant3d/assets/terrain_new/**`.
4. **Freeze/order:** absolute freeze on `game.gd`/`world3d_terrain.gd`/`world3d_relief.gd`/shaders/`app/**`; apply I01–I05 → I06–I10+N14 → seam → I12 → I13, rollback in reverse with file-scoped `Copy-Item` only.
5. **Guards:** 7 multi-pass readings (hash instrument cross-checks, path existence, backup absence) recorded; no donor frame, Godot job, gate or git mutation; **no donor parity claim** — parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

*End of V11 report. Exactly one report written; no source, shader, config, asset, test, backup, git, queue, runner, Godot, donor or `app/` state changed.*
