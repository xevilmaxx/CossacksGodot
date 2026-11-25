---
id: README-COUNT-01
title: "README-COUNT-01 — sync README corrections count to 63 and refresh the CORRECTIONS row pointers"
date: 2026-11-25
owner: README-COUNT-01 (documentation repair worker)
status: DELIVERED__DOC_ONLY__NO_CODE_OR_RUNNER_JOB__NO_OTHER_FILE_EDITED
scope: "Exactly five targeted edits in README.md (count 60 → 63 and CORRECTIONS row/line pointers). No other file edited, created or deleted; no code, config, asset, test, git-index or runner change; no donor access; no report promoted to PASS."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
target: "docs/coord_swarm_2026-11-25/README.md"
output: "docs/coord_swarm_2026-11-25/reports/README_COUNT_01.md"
authority: "docs/coord_swarm_2026-11-25/CORRECTIONS.md (63 rows; summary at :174-176); reports/CORRECTIONS_REFRESH_01.md §2/§3/§6; reports/QA_DOCS_02.md §2 B3 (`:44`), §4 item 3 (`:75`), §6 (`:90`)."
labels: [observed, derived, inferred, UNVERIFIED]
---

# README-COUNT-01 — README corrections count synced to 63

## 0. Label key and discipline

- **observed** — literal file content read from the four assigned sources in this pass.
- **derived** — deterministic count / line-number checks computed with `python` (3.14).
- **inferred** — interpretation only (open questions §4).
- **UNVERIFIED** — carried-forward report labels; not re-run, not promoted.

Only `README.md` was edited. Line numbers below are **final (post-edit) 1-based** numbers;
none of the five edits changed the line count of the file, so the pre-edit numbers are the same.

---

## 1. Sources read (all under `docs/coord_swarm_2026-11-25/`)

| # | File | Role |
|---|---|---|
| S0 | `README.md` | Sole in-place edit target. |
| S1 | `CORRECTIONS.md` | Authority for the current truth: 63 rows (ids 1–63), tally 46 RESOLVED / 15 PARTIAL / 1 CONFIRMED_UNVERIFIED / 1 CONFIRMED_INFEASIBLE (`:174-176`); row 61 at `:110`, 62 at `:111`, 63 at `:112`; duplicate-chain notice `:114-118`; summary `:172-185`. |
| S2 | `reports/CORRECTIONS_REFRESH_01.md` | Records E4–E6 = new rows 61–63 (Winter LFS pointer, donor Y-up light space, naval stale-doc refutations) and E8's `63 indexed corrections` summary. |
| S3 | `reports/QA_DOCS_02.md` | Point-in-time audit that still reports the old count (60) and proposed the README count repair at its §4 item 3. |
| S4 | This report | Created by this worker. |

**Exclusive ownership respected:** README-FINAL-01 was terminated before this task; its
pre-existing uncommitted changes to `README.md` were preserved verbatim and were neither
re-authored nor reverted here. No file other than `README.md` was edited by this worker.

---

## 2. Per-edit before → after

### Edit 1 — `README.md:49-52` (§0, "Donor decompilation" bullet)

| | Text |
|---|---|
| **Before** | `` `CORRECTIONS.md` is the canonical index: **60 rows** (DOC-03 snapshot 50; rows 51–60 landed since — `CORRECTIONS.md:98-109`; summary `:169-180`, duplicate-chain notice `:111-115`), with the status legend at `:38-41` and the 8-value UNVERIFIED section at `:117-139`. `` |
| **After** | `` `CORRECTIONS.md` is the canonical index: **63 rows** (DOC-03 snapshot 50; rows 51–63 landed since — `CORRECTIONS.md:98-112`; rows 61–63 = Winter LFS pointer, donor Y-up light space, naval stale-doc refutations; summary `:172-185`, duplicate-chain notice `:114-118`), with the status legend at `:38-41` and the 8-value UNVERIFIED section at `:120-142`. `` |

Effect: count 60 → 63; landed range 51–60 → 51–63; **added the requested rows 61–63
pointer with all three topics**; refreshed the four derived `CORRECTIONS.md` line ranges.
The adjacent "Three engine-side values are CONFIRMED_INFEASIBLE (`DBIND_01`)" sentence,
the lane-CLOSED claim and the UNVERIFIED parity bullet are untouched.

### Edit 2 — `README.md:199-200` (§1, read-order item 2)

| | Text |
|---|---|
| **Before** | `` 2. `CORRECTIONS.md` — the **60-row** donor corrections index (rows 1–60 at `:47-109`, duplicate-chain notice `:111-115`, summary `:169-180`); cite the authority row, never the superseded claim; keep `PORT APPROXIMATION` labels. `` |
| **After** | `` 2. `CORRECTIONS.md` — the **63-row** donor corrections index (rows 1–63 at `:47-112`, duplicate-chain notice `:114-118`, summary `:172-185`); cite the authority row, never the superseded claim; keep `PORT APPROXIMATION` labels. `` |

Effect: count 60 → 63 and three derived line ranges refreshed. The citation discipline and
`PORT APPROXIMATION` instruction are preserved verbatim.

### Edit 3 — `README.md:263` (§2, folder-map row for `CORRECTIONS.md`)

| | Text |
|---|---|
| **Before** | `` | `CORRECTIONS.md` | Canonical **60-row** donor corrections index; status legend `:38-41`, rows `:47-109`, duplicate chain `:111-115`, summary `:169-180`. | `` |
| **After** | `` | `CORRECTIONS.md` | Canonical **63-row** donor corrections index; status legend `:38-41`, rows `:47-112`, duplicate chain `:114-118`, summary `:172-185`. | `` |

Effect: count 60 → 63 and row/summary ranges refreshed; status legend range unchanged.

### Edit 4 — `README.md:289` (§3, green/recorded table row "`CORRECTIONS.md` published")

| | Text |
|---|---|
| **Before** | `` | `CORRECTIONS.md` published | **60** indexed corrections (rows 1–60 at `:47-109`), duplicate chains merged (`:111-115`), summary `:171` | `` |
| **After** | `` | `CORRECTIONS.md` published | **63** indexed corrections (rows 1–63 at `:47-112`, incl. rows 61–63: Winter LFS pointer / donor Y-up light space / naval stale-doc refutations), duplicate chains merged (`:114-118`), summary `:174` | `` |

Effect: count 60 → 63, second placement of the rows 61–63 topic pointer, line ranges
refreshed (the summary count line moved from `:171` to `:174`). No gate verdict or PASS
claim was changed in this table row.

### Edit 5 — `README.md:518-519` (§6, "Final reconciliation" pointer to QA-DOCS-02)

| | Text |
|---|---|
| **Before** | `` - `reports/QA_DOCS_02.md:35-47,71-76,86-93` — corrections count **60**, three QA-DOCS-01 BLOCKERs (2 closed, 1 partial), remaining README/board stale items. `` |
| **After** | `` - `reports/QA_DOCS_02.md:35-47,71-76,86-93` — corrections count **63** (the report predates rows 61–63), three QA-DOCS-01 BLOCKERs (2 closed, 1 partial), remaining README/board stale items. `` |

Effect: stale 60 → 63. The parenthetical keeps the pointer honest: QA-DOCS-02 is a
point-in-time snapshot (its §2 B3 at `:44` and §6 at `:90` still say 60), so the README
attributes 63 to the current `CORRECTIONS.md` while marking that report as predating
rows 61–63. The blocker tally and all other descriptor text are unchanged.

### Deliberately NOT changed

- Honesty guard at `README.md:312-321` (anchor `**Honesty rule:**` at `:312`) — preserved verbatim.
- FINAL verdict: `README.md:301` `**NOT_READY — DO NOT RUN**`, `:319` `current verdict is **NOT_READY**`, `:533` `**FINAL = NOT_READY**` — preserved.
- All gate numbers, atom PASS scopes, UNVERIFIED / PORT APPROX labels, report statuses and
  every other claim in the README — untouched. No report was promoted to PASS.
- `CORRECTIONS.md` itself and its reports — read only, not edited.

---

## 3. Verification

Method: `python` 3.14 `Path('README.md').read_text(encoding='utf-8')`, line split, literal
substring / line-number scan; plus `Test-Path` for cited paths. Console mojibake in the
PowerShell output was display-only — the files are UTF-8 and the `edit` tool matched exact text.

| Check | Result |
|---|---|
| Stale count patterns `**60**`, `60-row`, `60 rows`, `rows 1–60`, `rows 51–60`, `57-row`, `57 indexed`, old ranges `:100-105,159-170`, `:169-180`, `:111-115`, `:117-139`, `:98-109`, `summary :171` | **PASS — zero hits** for every pattern. |
| Correction count 63 present | **PASS** — lines 49, 50, 199, 263, 289, 519. |
| Rows 61–63 pointer with the three topics | **PASS** — lines 49–51 (Winter LFS pointer, donor Y-up light space, naval stale-doc refutations) and 289. |
| Refreshed ranges match current `CORRECTIONS.md` | **PASS** — row 61 `:110`, 62 `:111`, 63 `:112`; duplicate-chain notice `:114-118`; `## Summary` `:172`, `63 indexed corrections` `:174`, status tally `:176`; UNVERIFIED section `:120-142`. |
| Honesty guard preserved | **PASS** — `**Honesty rule:**` still at `:312`; guard body `:312-321` byte-identical to pre-edit. |
| FINAL NOT_READY preserved | **PASS** — `:301`, `:319`, `:533` unchanged; no PASS promotion. |
| Cited paths exist (all under `docs/coord_swarm_2026-11-25/`) | **PASS** — `CORRECTIONS.md`, `reports/QA_DOCS_02.md`, `reports/CORRECTIONS_REFRESH_01.md`, `reports/QA_WINTER_01.md`, `reports/LFS_PLAN_01.md`, `reports/LIGHT_02_light_space.md`, `reports/TERRAIN_DARK_FIX.md`, `reports/DONAVAL_02.md`, `reports/GATE_READY_01.md`. |
| Line count preserved | **PASS** — each edit replaced the same number of lines; no downstream line shifted. |

Note on `git diff` against HEAD: it also shows the earlier, pre-existing README-FINAL-01
working-tree edits (HEAD's README still said 57 / had the older gate wording). Those edits
were already present when this task started; they were preserved and are not attributed to
this worker. The five 60 → 63 edits above are the only changes made here.

---

## 4. Open questions

1. **UNVERIFIED / owner decision:** QA-DOCS-02 is a snapshot that reported 60. Edit 5 keeps
   the pointer useful while flagging that it predates rows 61–63. If the coordinator prefers
   the pointer to quote the report's own snapshot (60) verbatim, only edit 5 needs reverting;
   the current-count claims at `:49`, `:199`, `:263` and `:289` remain correct.
2. **UNVERIFIED / drift:** the refreshed line ranges (`:98-112`, `:47-112`, `:114-118`,
   `:172-185`, `:120-142`, summary `:174`) are read from `CORRECTIONS.md` as it stands now;
   that file has `status: living`, so the ranges may drift again without another README edit.
3. **UNVERIFIED / minor discrepancy:** `reports/CORRECTIONS_REFRESH_01.md:56` describes the
   duplicate-chain notice as "S0 lines 111–115", while the current file has it at `:114-118`.
   The README follows the current file, not that older report's snapshot.
4. **UNVERIFIED / no re-run:** no gate, runner job or donor read was performed; every UNVERIFIED
   and PORT APPROX label cited in the README stays exactly as found.
5. **Inferred / policy:** the README's §3 table row calls the 63 corrections "published".
   This is an index-publication claim only; it does not imply any new gate result or parity
   claim, and the FINAL gate remains NOT_READY.

---

## 5. Summary

- Five minimal targeted edits in `README.md` only: §0 count/ranges plus the rows 61–63
  pointer (`:49-52`), §1 read-order item (`:199-200`), §2 folder map (`:263`), §3 green-table
  row (`:289`), §6 QA-DOCS-02 pointer (`:518-519`).
- All corrections-count figures now read **63**; no `57` or `60` corrections count remains
  anywhere in the file (verified by literal scan).
- The honest status picture is preserved: the three new rows are indexed as Winter LFS
  pointer (RESOLVED, git-state only), donor Y-up light space (PARTIAL) and naval stale-doc
  refutations (RESOLVED, with caveats UNVERIFIED) — no verdict was promoted and no report
  was marked PASS.
- Honesty guard (`README.md:312-321`) and FINAL **NOT_READY** (`:301`, `:319`, `:533`) are intact.
- **No other file was edited, created or deleted by this worker.** `CORRECTIONS.md` and the
  reports were read only; the pre-existing README-FINAL-01 working-tree edits were preserved.
  No code, config, asset, test, git-index or runner state was touched; no donor access and
  no new parity claim was made.

*End of README-COUNT-01.*
