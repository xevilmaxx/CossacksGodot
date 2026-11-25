---
id: QA-SKIN-REGEN-01
title: "QA-SKIN-REGEN-01 — verify the regenerated skin JSON actually contains the `construct` frames"
date: 2026-11-25
agent: QA-SKIN-REGEN-01 (read-only QA subagent)
status: DELIVERED__JSON_EXPORT_LEVEL_PASS__NO_VISUAL_PASS__NO_PARITY_CLAIM__BUILD_SKIN_02_NOT_LANDED
scope: "Read-only QA. No code, config, asset, test, scene, git or runner-job change; this report is the only file written. Generated skin JSON was read with Python 3.14 json.load; donor touched only as a read-only byte split; no converter invocation, no Godot, no runner, no donor binary executed or copied."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
targets:
  - "variant3d/assets/models/skin/index.json"
  - "variant3d/assets/models/skin/peasant.json"
  - "docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_01.md"
  - "docs/coord_swarm_2026-11-25/reports/QA_SKIN_CONSTRUCT_01.md"
  - "C:\\Games\\Cossacks 3\\data\\animations\\aaf\\peaukr.aaf (READ-ONLY)"
output: "docs/coord_swarm_2026-11-25/reports/QA_SKIN_REGEN_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
governing_rule: "Cite donor path:line; separate observed / derived / inferred / UNVERIFIED; never claim donor parity from data-level evidence (DANIM_01 frontmatter :12; BUILD_ANIM_DIAG_01 frontmatter :12; BUILD_SKIN_01 frontmatter :12; QA_SKIN_CONSTRUCT_01 frontmatter :19)."
verdict: "JSON EXPORT-LEVEL PASS. The generated assets WERE regenerated: peasant.json.actions.construct = {first:186, last:198, kind:'morph', donor:'data/animations/aaf/peaukr.aaf:17', frames:[186,188,191,193,196,198]} and index.json peasant entry carries the same six frames; actions_requested is the original seven with construct appended as the eighth. All nine checks PASS; the original five peasant actions and all schema/label fields are unchanged. BUILD_SKIN_02.md has NOT landed, so the regen owner/ticket is UNVERIFIED. There is NO visual PASS and NO donor-parity claim; runtime `_unit_action()` build→construct branch and capture remain outstanding."
---

# QA-SKIN-REGEN-01 — verify regenerated skin JSON contains construct frames

## 0. Label key and discipline

- **observed** — literal file/byte content read in this pass (JSON fields via `json.load`, file metadata, donor line, git status, report text).
- **derived** — deterministic comparison/computation over observed content (list equality, baseline diff, set containment, SHA-256).
- **inferred** — interpretation with an explicit caveat; not a literal read by this QA.
- **UNVERIFIED** — cannot be settled from read-only evidence; carried forward, never promoted.

Only `docs/coord_swarm_2026-11-25/reports/QA_SKIN_REGEN_01.md` was written. **No generated skin JSON, code, config, test, scene or git state was changed; the converter was not invoked against `--out`; no runner job, Godot, Blender or donor binary was executed.** The probe script lived in the approved temp folder (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\qa_skin_regen_probe.py`) and wrote no pyc or repo file.

---

## 1. Sources

All paths are relative to the repo root unless marked donor/absolute.

| # | Source | Role in this verification |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_01.md` (177 lines, read in full) | Owner's landed change: `construct` appended to `DEFAULT_ACTIONS` (`:69-81`); regeneration hand-off ticket `BUILD-SKIN-02` proposed at `:110-127`; expected `donor = "data/animations/aaf/peaukr.aaf:17"`, `first=186,last=198` (`:78-79`, **derived** at that time). |
| S2 | `docs/coord_swarm_2026-11-25/reports/QA_SKIN_CONSTRUCT_01.md` (113 lines, read in full) | Prior QA baseline: code-level PASS but export-level FAIL — `index.json` requested 7 actions, `peasant.json` had 5 actions and no 186..198 (`:20,72-76,109`); baseline action/frame tables at `:72-73` used as the comparison floor; remaining-work list at `:82-91`. |
| S3 | `BUILD_SKIN_02.md` | **NOT PRESENT.** Read attempt returned "File not found"; it also does not appear in `git status --short` under `docs/coord_swarm_2026-11-25/reports/`. Therefore the regen owner/ticket and its report are **UNVERIFIED**; no owner claim is made here. |
| S4 | `variant3d/assets/models/skin/index.json` (line 1, full object via `json.load`) | Generated index: `schema`, `frames_per_action`, `actions_requested`, `count`, `entries[]` incl. the `peasant` entry action table and frame union. |
| S5 | `variant3d/assets/models/skin/peasant.json` (line 1, full object via `json.load`) | Generated per-sid asset: `actions{}` with per-action `first/last/kind/donor/frames`, and the global `frames[]` union. |
| S6 | Donor `data/animations/aaf/peaukr.aaf:17` (read-only bytes, CRLF split, latin-1 decode) | Fresh donor truth: `"construct",186,198,morph` — confirms the citation **written into the JSON** corresponds to a real donor row. No parity claim. |
| S7 | `git status --short` + `git log -1` (read-only) | Both skin JSONs show `M` (modified) against HEAD `83b77eaabc00c0dffef5919786863cc92bf029be`; `convert_skins.py` still `M` from S1. |
| S8 | In-memory Python 3.14 probe: `json.load`, `os.stat`, `hashlib.sha256`, list/set comparison | All checks below; no file writes. |

**Timing note (observed):** `index.json` mtime `2026-11-25T11:05:47Z`, `peasant.json` mtime `2026-11-25T11:05:36Z`; both ctimes are `2026-11-24T12:48:0xZ`. S7 shows both as modified relative to the 11:40 commit. This is consistent with an offline converter re-export on 11/25 after the S2 snapshot; the exact actor and command are **UNVERIFIED** (S3).

---

## 2. JSON verification table

Expected values come from S1 `:78-79,103` and S2 `:70,87` (baseline from QA-SKIN-CONSTRUCT-01 `:72-73`). All results are from S4/S5/S8 unless noted.

| # | Check | Method (Python 3.14 `json.load`) | Result | Label |
|---|---|---|---|---|
| C1 | `peasant.json actions.construct.frames` exact | list equality | **PASS** — `[186,188,191,193,196,198]` | observed + derived |
| C2 | `peasant.json actions.construct.donor` exact | string equality | **PASS** — `"data/animations/aaf/peaukr.aaf:17"` | observed |
| C3 | `construct first/last/kind` | field read | **PASS** — `first=186`, `last=198`, `kind="morph"` | observed |
| C4 | `index.json actions_requested` = original 7 + `construct` appended | list equality vs `['idle','idle0','walk','walk0','death','attack0','attack1']` | **PASS** — `['idle','idle0','walk','walk0','death','attack0','attack1','construct']`; original order and values preserved | observed + derived |
| C5 | `index.json` peasant entry `actions.construct` exact | list equality | **PASS** — `[186,188,191,193,196,198]` | observed + derived |
| C6 | Original 5 peasant actions unchanged | per-action `frames` vs S2 baseline | **PASS** — idle `[64,74,84,93,103,113]`, idle0 `[64,74,84,93,103,113]`, walk `[1,5,9,12,16,20]`, death `[115,122,129,135,142,149]`, attack0 `[237,240,244,247,251,254]`; donors remain `:3,:4,:5,:6,:7` | observed + derived |
| C7 | Frame union gains all six, loses none | superset + membership vs S2 24-frame baseline | **PASS** — 24 → 30 frames; six new values inserted in sorted order; no old frame removed | derived |
| C8 | Schema / labels unchanged | field read | **PASS** — `schema="c3_skin_v1"` in both; `label="PORT APPROXIMATION — NOT DONOR PARITY"`; `visual="UNVERIFIED"` in both | observed |
| C9 | Index inventory stable | field read | **PASS** — `count=55`, `len(entries)=55`, `frames_per_action=6`; exactly 1 entry (`peasant`) carries `construct` | observed |

**Aggregate: 9/9 PASS (`ALL_CHECKS_PASS = true`).**

Notes on scope of "unchanged where expected" (C4/C6):
- The original `DEFAULT_ACTIONS` 7-tuple is `idle, idle0, walk, walk0, death, attack0, attack1` (S1 `:69-81`). At index level all seven remain, with `construct` appended as the eighth (C4).
- At per-sid peasant level only **five** of those seven were ever exported (peasant AAF lacks `walk0`/`attack1` — S2 `:73`). Those five retain identical frames and donors; the sixth action is the new `construct` (C6). So the "7/5 → 8/6" transition is additive only; no original action's data was replaced.

### 2.1 File hashes and mtimes (S8, observed)

| File | Size (bytes) | SHA-256 | mtime (UTC) | ctime (UTC) |
|---|---|---|---|---|
| `variant3d/assets/models/skin/index.json` | 34018 | `0EF8085D09A2908B3777E3D3B3FA5DFBFB2C9C1F713830D96B0765A02FE4A137` | `2026-11-25T11:05:47.022167+00:00` | `2026-11-24T12:48:05.453996+00:00` |
| `variant3d/assets/models/skin/peasant.json` | 64393 | `D5372047862AF9CB4D4AFC7B92E143AA8912FBE47E80D3A5A7C1A0EB627D4F4F` | `2026-11-25T11:05:36.915536+00:00` | `2026-11-24T12:48:04.345204+00:00` |

(Windows `ctime` is creation time; the later mtimes are the regeneration signal. Hashes are of the current on-disk bytes and are **observed**, not compared to any owner-declared expected hash — S3 is absent.)

### 2.2 Donor cross-check (S6, observed)

Read-only byte split of `C:\Games\Cossacks 3\data\animations\aaf\peaukr.aaf`, line 17 (1-based) = `"construct",186,198,morph`. This matches the `first/last/kind` and the `:17` citation embedded in `peasant.json` (C2/C3). This confirms the **citation string and range are real donor data**, not a hand-invented table; it does **not** establish visual equivalence. No parity claim.

### 2.3 Derived/inferred observation on coverage

Only `peasant` among the 55 shipped sids has `construct` in the generated index (C9, observed). S1 cites donor `construct` in 8 AAF files (via DANIM_01); whether the other seven are outside the 55-sid shipped set or lack the action is **UNVERIFIED** here — this QA did not enumerate those AAFs. **Inferred** (caveat: no owner report landed): regeneration was limited to, or only surfaced `construct` for, the peasant sid.

---

## 3. Verdict

**JSON EXPORT-LEVEL PASS — regenerated skin assets contain the construct frames.** The exact frame vector `[186,188,191,193,196,198]`, donor citation `data/animations/aaf/peaukr.aaf:17`, `first=186/last=198/kind=morph`, index-level `actions_requested` with `construct` appended, and the preserved original action data are all present and verified via `json.load`. This closes the export-level FAIL recorded in QA-SKIN-CONSTRUCT-01 `:20,72-76,109`.

Explicit non-claims:
- **No visual PASS.** No capture, no runtime probe, no rendered pose was produced (S3 absent; none run here).
- **No donor-parity claim.** All evidence is data-level; `PORT APPROXIMATION — NOT DONOR PARITY` and `visual="UNVERIFIED"` remain as generated (C8).
- **`BUILD_SKIN_02.md` not landed (S3).** The identity of the regen owner, the exact command used, and whether a regeneration report will follow are **UNVERIFIED**; this QA only asserts the on-disk result.
- The donor `construct` frame range is re-derived from AAF at export time by the tool, not hard-coded (S1 `:73-86`); this QA verified the emitted values, not the tool's internals.

---

## 4. Remaining runtime integration (all UNVERIFIED — none done by this QA)

1. **Presentation-layer branch.** Per S2 `:88` / S1 `:124-127`, the 3D `world3d_entities.gd:_unit_action()` build→`construct` branch is a separate ticket and was not re-read or changed here. Its current state and whether it is assigned remain **UNVERIFIED**. The presence of frames in JSON alone does not make the runtime request them.
2. **Capture discriminator before any visual PASS.** S2 `:89` (S5 §6): Layer A must show `pose_for(...,"construct", f/30)` yielding `[186,188,191,193,196,198]` with `pose_source == "donor_flat_root_morph"` and `visual == "UNVERIFIED"`, never 149/237; Layer B build-order sync capture must show `|aconstruct|` batches and zero builder idle frames. None of this was run.
3. **Hammer `.oss` / `buildsmoke` PFX.** Donor switches a separate single-bone hammer `.oss` (`unit.script:7008`) and construction smoke is a site PFX family; neither is exported by this change. Spawn policy and 3D presentation remain **UNVERIFIED** (S1 `:131-135`).
4. **Loop/blend semantics.** AAF has no loop flag; `construct` loop policy is authored in ACL/scripts and engine semantics are **UNVERIFIED** (S1 `:141-143`).
5. **Stage art and rendered A/B.** OBJ stage loading and donor-equivalent build pose remain **UNVERIFIED** (S1 `:136-140`).

---

## 5. Open questions

1. `BUILD_SKIN_02.md` has not landed (S3). Which owner ran the regeneration, with which exact command, and will a report be filed? **UNVERIFIED.**
2. Why does only the `peasant` index entry carry `construct` (C9) when S1 cites `construct` in 8 donor AAFs? Are the other seven sids outside the shipped 55, or intentionally skipped? **UNVERIFIED** — this QA did not enumerate those AAFs.
3. Does the current runtime (Godot scene/`world3d_entities.gd`) actually select the `construct` action on build orders, or is the branch still outstanding (§4.1)? **UNVERIFIED.**
4. Has any Layer A/B capture been run against the regenerated assets? None found here; **UNVERIFIED** and no visual PASS.
5. Are the current `index.json`/`peasant.json` hashes the ones the regen owner intends to ship (no owner-declared expected hash exists in S3 to compare)? **UNVERIFIED.**
6. Regeneration modified two tracked JSONs (S7); is there a review/conflict policy with other asset workers (S1 open question 3)? Owner decision, **UNVERIFIED**.

---

## 6. Summary

- **Regeneration confirmed (observed):** both `index.json` and `peasant.json` were modified on 11/25 (S4/S5/S7) and now contain `construct`. This reverses the export-level FAIL of QA-SKIN-CONSTRUCT-01.
- **Exact expected data (derived/observed):** `peasant.json.actions.construct` = `{first:186, last:198, kind:"morph", donor:"data/animations/aaf/peaukr.aaf:17", frames:[186,188,191,193,196,198]}`; index peasant entry carries the same six frames; donor line 17 freshly re-read as `"construct",186,198,morph` (S6).
- **Original data intact (derived):** original seven requested actions preserved with `construct` appended eighth; the five exported peasant actions keep their frames/donors; frame union 24 → 30 with no losses; `count=55`, `frames_per_action=6`, schema and labels unchanged.
- **9/9 checks PASS.** Hashes and mtimes recorded in §2.1.
- **BUILD_SKIN_02.md NOT landed** — regen owner/ticket **UNVERIFIED**.
- **No visual PASS, no parity claim.** Runtime build→construct branch, capture, hammer/PFX, loop/blend and stage art all remain outstanding/UNVERIFIED (§4).
- **Only this report was written.** No code, asset, config, test, scene or git change; no runner job; no donor binary executed or copied.

*End of QA-SKIN-REGEN-01 report.*
