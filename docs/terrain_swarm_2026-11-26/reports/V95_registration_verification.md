---
id: V95
ticket: "TERRAIN-SWARM-2026-11-26 / V95 — static verification of COORD's B2 (I12 manifest registration) and B3 (GR-A24 literal repoint)"
agent: "V95 (read-only verification worker, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_GATE_RUN__NO_RUNNER__NO_GODOT__NO_SOURCE_EDIT__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V95_registration_verification.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V95_registration_verification.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner subcommand, gate, capture or result JSON was produced by V95. Every PASS below is a filesystem/static verdict on the working tree, NOT a gate result and NOT a donor-parity claim. Parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125)."
scope_guard: "Read-only: file reads, two independent greps (ripgrep via grep tool + PowerShell Select-String), read-only python -B json.load / difflib / subprocess git show (no bytecode written), git read commands (status, diff, diff --name-only), Test-Path, Get-FileHash and certutil. No .bak, source, shader, asset, test, manifest, config, queue, app/, git state or Godot state touched."
multiple_passes: true
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V95 — registration verification (B2 + B3 fixes, static only)

## 0. Verdict in one line

**5/5 PASS (static)** — `manifest.json` is valid JSON with 41 tests and the I12 entry last;
`t_relief_props_qa.gd:30` is the only changed line and no assertion/threshold moved; no other
manifest entry changed; `app/**` is byte-clean; both `.bak-COORD-I11` files are SHA-exact.
**No gate was run, no result is asserted, and no donor-parity claim is made.**

## 1. Method and labels

Read first: `docs/terrain_swarm_2026-11-26/CHARTER.md` (guardrails §4, esp. :66-94),
`reports/V76_gate_preflight.md` (B2 `:62`, B3 `:63`, baselines `:51-52`),
`reports/V11_ownership_ledger.md` (E3 `:80`, backups `:78-79`, acceptance `:219`,
CR10 `:150`), `reports/V13_stale_qa_refs.md` (S1 `:51`, remediation R-S1 `:78`),
`variant3d/tests/manifest.json`, `variant3d/tests/t_relief_props_qa.gd` and
`variant3d/tests/t_terrain_donor.gd` (presence check only).

Labels: **[O]** = literal command output / file:line; **[D]** = deterministic consequence of [O];
**[U]** = not establishable without an engine run. Mandatory two instruments per item
(CHARTER.md:85-93). Every count is point-in-time at the final pass; this is a live concurrent tree.

### Multi-pass log

| Pass | Instrument(s) | Result | Effect |
|---|---|---|---|
| P1 | `python -B -c "json.load(...)"` (read-only) + PowerShell `ConvertFrom-Json` | Both: 41 tests, last `t_terrain_donor`, same six-field entry | JSON validity and shape confirmed twice |
| P2 | Two independent greps: (A) ripgrep over `t_relief_props_qa.gd` and `manifest.json`; (B) PowerShell `Select-String` over the same two files | A and B agree on `manifest.json:333` and `t_relief_props_qa.gd:30,41,42,158` | No grep-only artefact accepted |
| P3 | `git diff -- variant3d/tests/manifest.json` + read-only `python -B` deep compare of `git show HEAD:...` vs live JSON | Only an 8-line append after `t_select_rect`; HEAD 40, live 41; first 40 identical; non-`tests` keys identical | Item 3 settled |
| P4 | `git diff -- variant3d/tests/t_relief_props_qa.gd` + read-only `python -B difflib` over 795 lines of HEAD vs live | Exactly one non-equal opcode `('replace',29,30,29,30)` ⇒ changed lines `[30]` only; rest byte-identical | Item 2 settled |
| P5 | `git status --short -- app/`, `git diff --exit-code -- app/`, `git diff --name-only`, freeze-set diff | 0 status lines, exit 0, no `app/` in name list, freeze diff exit 0 | Item 4 settled |
| P6 | `Get-FileHash -Algorithm SHA256` + `certutil -hashfile ... SHA256` on both backups | Both instruments return the V11/V76 baselines | Item 5 settled |

**[O] No anomaly was silently skipped.** The two noteworthy observations are recorded in §4.

## 2. Item-by-item verdicts (PASS/FAIL with exact file:line)

| # | Check | Verdict | Instrument A | Instrument B (independent) |
|---|---|---|---|---|
| 1 | `manifest.json` valid JSON, 41 tests, `t_terrain_donor` appended **last** with exact I12 fields | **PASS** | `python -B -c "json.load(...)"` → `JSON_VALID=True`, `TEST_COUNT=41`, `LAST_ID=t_terrain_donor`, `TDONOR_OCCURRENCES=1`, `DUPLICATE_IDS=[]`; entry at `variant3d/tests/manifest.json:332-339`: `id :333`, `path :334`, `feature :335`, `status :336`, `owner :337`, `timeout :338`; test file present (`Test-Path=True`) | PowerShell `ConvertFrom-Json` → `PS_COUNT=41`, `PS_LAST_ID=t_terrain_donor`, `PS_LAST_FIELDS=feature,id,owner,path,status,timeout`; two greps both hit `"id": "t_terrain_donor"` at `manifest.json:333` (ripgrep A, `Select-String` B). `.tests` opened at `:5`. |
| 2 | `t_relief_props_qa.gd:30` repointed to live `mountain_props.json`; **no** assertion/threshold changed (V13 description) | **PASS** | `variant3d/tests/t_relief_props_qa.gd:30` = `const PROP_MANIFEST := "res://assets/terrain/mountain_props.json"  # V13: live file; old terrainmesh_props.json absent`; `git diff` shows exactly one `-`/`+` pair at `:30`; `python -B difflib`: `HEAD_LINES=795`, `LIVE_LINES=795`, `NON_EQUAL_OPCOUNT=1`, `CHANGED_OLD_LINES=[30]`, `CHANGED_NEW_LINES=[30]`, `REST_IDENTICAL=True` | Two greps: (A) ripgrep and (B) `Select-String` both return `:41 BBOX_TOL := 0.05`, `:42 SCALE_WANT := 1.0`, `:43 SCALE_TOL := 0.02`, `:158 "expected_pre_fix_failure": true`; `Test-Path` → `mountain_props.json=True`, `terrainmesh_props.json=False`. Full-file read confirms V13's other anchors intact: interface-gap comment `:7-14`, `DONOR_H` `:57-60`, `check()` `:89-93`, `prop_manifest_loaded` `:284-311`, donor-prop checks `:337-439`, clearance checks `:518-528`, windowed A/B checks `:710-731`. V13's R-S1 (`:78`) prescribed exactly this single-literal repoint with `:89-93/:286-311/:337-439/:518-528/:710-731` preserved — done. |
| 3 | No other manifest entry retyped/removed (append-only, LAST) | **PASS** | `git diff -- variant3d/tests/manifest.json`: one hunk `@@ -328,6 +328,14 @@`, only `+` lines after `t_select_rect`'s `"windowed": true` at `:330`; no `-` line anywhere | Read-only `python -B` compare with `git show HEAD:variant3d/tests/manifest.json`: `HEAD_COUNT=40`, `LIVE_COUNT=41`, `FIRST_40_IDENTICAL=True`, `NON_TESTS_IDENTICAL=True`, `APPENDED_ONLY=True`. Matches V11 E3 `:80` / CR10 `:150` and spec/12 `:38` (append LAST, stage 3 only). |
| 4 | `app/**` still byte-clean | **PASS** | `git status --short -- app/` → 0 lines; `git diff --exit-code -- app/` → `APP_DIFF_EXIT=0` | `git diff --name-only` lists `.gitignore`, 5 docs, `variant3d/CREDITS.md`, `main.gd`, `world3d.gd`, `manifest.json`, `t_relief_props_qa.gd` — **no** `app/` path. Extra freeze-set diff (game.gd, world3d_terrain.gd, world3d_relief.gd, terrain_tileindex.gdshader, project.godot, app/) → `FREEZE_DIFF_EXIT=0`. |
| 5 | `.bak-COORD-I11` backups still SHA-exact | **PASS** | `Get-FileHash -Algorithm SHA256`: `inbox/backup/main.gd.bak-COORD-I11 = 3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8`; `inbox/backup/world3d.gd.bak-COORD-I11 = 44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` | `certutil -hashfile ... SHA256` (independent binary) returns the same two digests, case-normalised. Both equal V11 §2 E1/E2 (`:78-79`), V76 §2 row 8 (`:51`) and V26 pass 4 (`:185`) baselines. |

### Exact I12 entry as landed (`manifest.json:332-339`)

```json
{
  "id": "t_terrain_donor",
  "path": "res://tests/t_terrain_donor.gd",
  "feature": "fresh donor terrain determinism + structural/telemetry gates (I12)",
  "status": "ready",
  "owner": "I12",
  "timeout": 240
}
```

**[O]** Six fields, in the same key order and same field set as the manifest's established test-entry
schema; no `windowed` key (correct — the atom is a headless structural/telemetry test, cf. V42 `:152,242`).
**[D]** No separate doc-defined literal field template for this entry exists on disk: V11 `:80` and `:219`,
V36 `:172`, V52 `:307` and V42 `:190` all require only the **id-level append LAST / 40→41**; the full
observed dict is quoted above so COORD can compare it against the intended patch without inference.

## 3. Consequence

**[D]** B2 (V76 `:62`) and B3 (V76 `:63`) are closed **statically**: D-0's manifest precondition
(V11 `:219`; V42 `:190`) now reads 41/last `t_terrain_donor`, and the GR-A24 atom's hard-fail path
(V13 `:18,51`) now resolves to an on-disk file. **[U]** Whether the atom goes green, whether the
documented Z07/Z08 interface gaps (`:7-14`) still fail, and whether any gate result changes remain
unknown: V95 ran no Godot process and no runner subcommand. **No gate result is claimed.**

## 4. Anomalies / observations (outside the five-item brief; no verdict change)

1. **[O]** `inbox/backup/tests_manifest.json.bak-I12` is **absent** (`Test-Path=False`) even though the
   append has landed. V11 CR10 `:150`, V36 `:172` and V52 `:306-308` require that backup *before* the
   append and forbid whole-file restore on rollback. V95 does not judge it here (not in the brief) —
   COORD should decide whether to record an explicit exception or take a file-scoped backup now.
   Rollback must remain **id-level removal only** (V11 `:160,184`; V42 `:343`).
2. **[O]** Git emits `LF will be replaced by CRLF` warnings for `t_relief_props_qa.gd` and several
   docs (`core.autocrlf=true`, V11 R11 `:237`). The warning is not a diff: `git diff` and the
   line-by-line comparison both show exactly one changed line (`:30`).

## 5. What V95 did NOT do

No Godot process, no `godot_runner.py` subcommand (not even `status`), no gate, capture, determinism
dump, result JSON, no donor access, no source/shader/asset/config/test/manifest/backup/git mutation.
The only repo file written is this report. Python calls were `json.load`, `difflib.SequenceMatcher`
and `subprocess.check_output(['git','show',...])` with `-B` (no bytecode written). **No donor-parity
claim**: parity stays `UNVERIFIED` / `PORT APPROXIMATION` (CHARTER.md:43-44,125).

## 6. Five-line summary

1. **PASS** — `variant3d/tests/manifest.json:1-341` is valid JSON (`python -B json.load` + `ConvertFrom-Json`), 41 tests, `t_terrain_donor` once and last at `:333`, six I12 fields at `:333-338`.
2. **PASS** — `t_relief_props_qa.gd:30` now names live `mountain_props.json`; `git diff` and difflib agree that line 30 is the *only* changed line of 795, with `BBOX_TOL :41`, `SCALE_WANT :42`, `expected_pre_fix_failure :158` and every V13-cited assertion block unchanged.
3. **PASS** — manifest diff is append-only (`@@ -328,6 +328,14 @@`); HEAD's 40 entries and all non-`tests` keys are byte/structurally identical to the live file's first 40.
4. **PASS** — `app/**` status 0 lines, diff exit 0, no `app/` in `git diff --name-only`; freeze-set diff exit 0.
5. **PASS** — both `.bak-COORD-I11` SHA-256 digests match V11/V76 baselines by `Get-FileHash` and `certutil`. **Static verification only — no gate, no runner, no parity claim.**

---

*End of V95 report. Exactly one repo file written; no gate, runner, Godot, donor, source, manifest, backup, `app/` or git state change.*
