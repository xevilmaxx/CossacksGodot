---
id: QA-DOCS-02
title: "QA-DOCS-02 — read-only verification that the three QA-DOCS-01 BLOCKER governance findings are closed"
date: 2026-11-25
owner: QA-DOCS-02 (read-only verification worker)
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT_ONLY
scope: "This report is the ONLY file written by this worker. No code, config, test, asset, git, queue or runner state touched; no Godot job submitted; no living doc edited."
labels: [observed, derived, inferred, UNVERIFIED]
audit_mode: read-only verification of already-applied edits; findings are not fixes
snapshot: "Board/doc evidence read 2026-11-25 11:25:32–11:27:12 local; the swarm was still landing report files during the verification (139 *.md at 11:25:32 → 142 at 11:26:46). All 'remaining' counts are therefore lower bounds, not final."
---

# QA-DOCS-02 — verification of QA-DOCS-01 BLOCKER closures

## 1. Method, label key, sources

- **observed** — read directly from the named file:line, or returned by a read-only shell/Python enumeration during this pass.
- **derived** — arithmetic or cross-check over observed items (e.g. "7 of the 10 C6-named tickets changed state").
- **inferred** — judgement about cold-reader risk or about which edit is needed; never asserted as fact about intent.
- **UNVERIFIED** — not checked: no job was re-run, no runner result re-executed, no donor file read, no claim of runtime truth made.

Every count was verified **twice**: (pass 1) manual line-by-line read of the full `SWARM_BOARD.md`, `CORRECTIONS.md`, the `PROGRESS.md` gate section and the C1/C2/C3/C4/C6/C9 rows of `QA_DOCS_01.md`; (pass 2) independent PowerShell `Select-String`/regex enumeration plus a `python` 3.14 `Path.rglob`/`Test-Path` existence check. Both passes are reported where they differ only because the swarm landed new files **between** them (see §3).

**Sources read (all under `docs/coord_swarm_2026-11-25/`):**

| Source | Used for |
|---|---|
| `reports/QA_DOCS_01.md` | C1 at `:97`; C2 `:98`; C3 `:99`; C4 `:100`; C6 `:102`; C9 `:105`; B1/B2/B3 at `:127-129` |
| `PROGRESS.md` | gate table `:184-200`, integrated-state log `:100-103`, decisions `:181-182` |
| `SWARM_BOARD.md` | State column `:11`, authoritative rows `:64/:119/:232`, removal comments `:88/:187/:229`, all RUNNING rows (18 at snapshot) |
| `CORRECTIONS.md` | uniqueness charter `:15-20`, rows `:47-109`, duplicate notice `:111-115`, summary `:169-180` |
| Report frontmatter of 11 landed-but-RUNNING reports | report-side status used to qualify the precise remaining board edit (§3) |
| `README.md` | residual stale cross-references `:142`, `:194` (§4) |

## 2. Per-blocker verification table

| Blocker / finding | Requested check | Verdict | Exact line evidence |
|---|---|---|---|
| **B1 / C1** — `PROGRESS.md` LIVE gate table contradicted by integrated 26/29 / 28/29 | gate table no longer claims "LIVE"; per-job artifacts explicitly separated from integrated state | **CLOSED** | `PROGRESS.md:184` heading is now `## Gates status (PER-JOB artifacts vs INTEGRATED state — audit-corrected, 2026-11-25)` — no `LIVE` claim; grep pass 2 for `\*\*LIVE|LIVE —|LIVE -` returned **zero** matches (the only "live" left is `:36` "Total live swarm"). `PROGRESS.md:186-190` governance note states verbatim: `"LIVE" was too strong`, "per-job results below are real … but the **integrated** `variant3d/selftest.json` was separately measured at 26/29 (HEAD) / 28/29 (worktree) by the same audit. A per-job 29/29 does not imply the integrated tree is green". Corroborated by `PROGRESS.md:100-103`. **(observed)** |
| **B2 / C2** — duplicate CFG-01 row | no duplicate CFG-01 row | **CLOSED** | `SWARM_BOARD.md:64` single authoritative CFG-01 row, state **DONE**; `:88` `<!-- CFG-01 duplicate row removed (2026-11-25 docs audit C2): authoritative DONE row above. -->`. Grep pass 2 found exactly one live CFG-01 row plus that removal comment. **(observed)** |
| **B2 / C3** — duplicate LIGHT-02 row | no duplicate LIGHT-02 row | **CLOSED** | `SWARM_BOARD.md:119` single authoritative LIGHT-02 row, state **DONE**; `:187` `<!-- LIGHT-02 duplicate row removed (docs audit C3): authoritative DONE row above. -->`. Grep pass 2: one live LIGHT-02 row plus the removal comment (`:186` is TERRAIN-DARK-FIX, which merely mentions LIGHT-02 in its evidence text). **(observed)** |
| **B2 / C4** — duplicate CONFIG-DOC-01 row | no duplicate CONFIG-DOC-01 row | **CLOSED** | `SWARM_BOARD.md:232` single authoritative CONFIG-DOC-01 row, state **DONE** (32 KB); `:229` `<!-- CONFIG-DOC-01 duplicate row removed (docs audit C4): authoritative DONE row above. -->`. Grep pass 2: one live CONFIG-DOC-01 row. **(observed)** |
| **B2 / C6** — 12 RUNNING tickets with reports on disk | no report-landed ticket still marked plain RUNNING | **PARTIAL** | Of the 10 named tickets in `QA_DOCS_01.md:102`, 7 are no longer plain RUNNING: `:117` MOTION-ANIM-01 **REPORT DELIVERED**, `:147` SEASON-PLAN-01 **DONE**, `:174` SP-4 **DONE**, `:175` SP-6 **REPORT DELIVERED**, `:184` CONFIG-UI-01 **DONE**, `:186` TERRAIN-DARK-FIX **REPORT DELIVERED**, `:188` CONFIG-WIRE-SEL **DONE**. But 3 remain plain RUNNING with reports on disk: `:226` AUDIO-SEL-02, `:228` WEATHER-DRIVER-01, `:236` README-UPDATE-01. Fresh landings added more (§3): at 11:26:46 **11** RUNNING rows have a report on disk, up from **7** at 11:25:32. **(observed + derived)** |
| **B3 / C9** — duplicate correction chains and count | duplicate-chain notice for rows 14/51 and 28/52; summary count matches actual max row id | **CLOSED** | `CORRECTIONS.md:111-115`: `**Duplicate-chain notice (QA-DOCS-01 C9):** rows **14/51** (frame-0 bind pose) and **28/52** (FogMode/sky labels) … Row **51** and row **52** are the authoritative, later statements; rows 14 and 28 remain as the original claim trail and must not be cited as separate corrections.` The duplicated rows are still present (`:60` row 14, `:98` row 51; `:74` row 28, `:99` row 52) but are now explicitly chained — QA-DOCS-01's open question 2 (`QA_DOCS_01.md:157`) is resolved in favour of "visible reversal chain with cross-link", not physical merge. Count: `CORRECTIONS.md:171` says **60 indexed corrections**; grep pass 2 over `^\| (\d+) \|` gives `COUNT=60 MIN=1 MAX=60`, no missing ids, no duplicate ids — manual pass 1 agrees (rows 1–60 at `:47-109`). **(observed + derived)** |
| **(d)** — new inventory rows 58–60 | all three rows exist | **CLOSED** | `CORRECTIONS.md:107` row 58 (root files **24**, not 22; `reports/INVENTORY_01_counts.md` C1); `:108` row 59 (map field-4 **55/32**, not 53/27; C2); `:109` row 60 (`.inc` **455** whole-donor vs 313 under `data/`; C3). Cross-referenced by `SWARM_BOARD.md:242` (`→ CORRECTIONS rows 58–60`). Counts verified twice (manual read + grep). **(observed)** |

**Blocker roll-up (derived):** B1 **CLOSED**; B2 **PARTIAL** (its C2/C3/C4 duplicate sub-findings are CLOSED, its C6 sub-finding is not); B3 **CLOSED**. Therefore **2 of 3 BLOCKERs are closed; one remains partially open.**

## 3. Remaining report-landed tickets still marked plain RUNNING (C6 detail)

Enumeration method: every `SWARM_BOARD.md` table row containing `RUNNING` was extracted (18 rows at 11:26:46), its `reports/…` output cell parsed, and `Test-Path` run against the reports directory. Second, manual-read pass over the same rows agrees. Report-side status was read from each report's YAML frontmatter (lines 2–8). **No report or board file was edited.**

| Board line | Ticket | Report path (board cell) | Board State | Report frontmatter status |
|---:|---|---|---|---|
| 120 | MINIMAP-QUAD-01 | `reports/MINIMAP_QUAD_01.md` | RUNNING | `IMPLEMENTED__PARSE_REPAIR_CLEAN__NO_GATES` |
| 219 | INVENTORY-01 | `reports/INVENTORY_01_counts.md` | RUNNING | `COMPLETE — read-only` |
| 220 | LINKS-01 | `reports/LINKS_01.md` | RUNNING | `COMPLETE__READ_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS` |
| 226 | AUDIO-SEL-02 | `reports/AUDIO_SEL_02.md` | RUNNING | `PENDING_VALIDATION` |
| 227 | CONFIG-WIRE-RELIEF | `reports/CONFIG_WIRE_RELIEF.md` | RUNNING | `DONE — one owned source file + this report` |
| 228 | WEATHER-DRIVER-01 | `reports/WEATHER_DRIVER_01.md` | RUNNING | `PENDING_SMOKE_RESULT` |
| 230 | QA-PARITY-01 | `reports/QA_PARITY_01.md` | RUNNING | `COMPLETE__GATES_NOT_EXECUTED__INTEGRATED_PARTIAL` |
| 246 | DESERT-REMAP-02 | `reports/DESERT_REMAP_02.md` | RUNNING | `DELIVERED__DATA_ONLY__…` |
| 248 | SP8-STATUS-01 | `reports/SP8_STATUS_01.md` | RUNNING | `DELIVERED__READ_ONLY__…` |
| 251 | QA-DOCS-01 | `reports/QA_DOCS_01.md` | RUNNING | `DELIVERED__READ_ONLY__…` — QA-DOCS-01's own C20, expected to self-resolve once COORD flips it |
| 253 | QA-ATOM-RESULTS-01 | `reports/QA_ATOM_RESULTS_01.md` | RUNNING | `DONE__REPORT_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS` |

Additionally, `SWARM_BOARD.md:236` **README-UPDATE-01** is plain RUNNING, has no report path in its own row, but `reports/README_UPDATE_01.md` is on disk with frontmatter `DELIVERED__DOC_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB`; its report path appears in the duplicate DONE row at `:217`. It is counted in C6's original list and is still unfixed.

The remaining 7 RUNNING rows have **no** report on disk at the 11:26:46 snapshot (`:66` MAP-SMALL-01, `:233` MAPSIZE-01, `:237` PERF-3D-01, `:239` DARKROW-ALL-01, `:244` SEASON-TEST-PATH-01, `:247` PROP-W-PLAN-01 and the code-file-only `:169` SP-1 is not in the RUNNING set at this snapshot — verified by grep). These are legitimately RUNNING and are **not** C6 findings.

## 4. Remaining state issues, ranked

1. **[BLOCKER-residual] C6 board State column still lags delivered reports.** 11 report-landed tickets are plain RUNNING (§3), plus README-UPDATE-01 at `:236`. Precise remaining edit, **not made by this worker**: in `SWARM_BOARD.md`, COORD-only State column (`SWARM_BOARD.md:11`) should change those RUNNING cells to a state matching each report's frontmatter — e.g. `:227` → **DONE**, `:220`/`:219`/`:253` → **DONE (read-only report landed)**, `:226` → **REPORT DELIVERED (PENDING_VALIDATION)**, `:228` → **REPORT DELIVERED (PENDING_SMOKE_RESULT)**, `:230` → **REPORT DELIVERED (PARTIAL)**, `:117`-style **REPORT DELIVERED** for the implementation reports, `:251` → **DONE** (self-resolving C20). Do not upgrade a `PENDING_*` report to an unconditional DONE — that would create a new truth mismatch. **(derived + inferred)**
2. **[MEDIUM] Duplicate ticket ids other than the three audited.** `README-UPDATE-01` appears at `:217` **DONE** and `:236` **RUNNING** with the same session id `ses_deddede29ffep3WHPBG8kRHQYW`; `INVENTORY-01` at `:219` **RUNNING** and `:242` **DONE** with the same session id `ses_dedd0b783ffeXGxtcSZa3SbA9o`; `TEST-RUN-02` at `:98` **RESERVED** and `:155` **DONE — STOPPED AT P0** with different scopes (QA-DOCS-01 C5, `QA_DOCS_01.md:101`). These are **not** CFG-01/LIGHT-02/CONFIG-DOC-01, so they do not reopen C2–C4, but they keep the board's "freshest per-ticket status" claim unreliable. Remaining edit: `SWARM_BOARD.md` — apply the same `<ticket> duplicate row removed (docs audit …)` comment pattern used at `:88/:187/:229`, keeping one authoritative row per ticket id and a unique id for the second TEST-RUN-02 scope. **(observed)**
3. **[MEDIUM] README still states the superseded numbers.** `README.md:194` says `| \`CORRECTIONS.md\` published | **57** indexed corrections, duplicate chains merged (\`:100-105,159-170\`) |` while `CORRECTIONS.md:171` now says **60** and the chain notice is at `:111-115`. Remaining edit: `README.md:194` → "60 indexed corrections" with citations `:111-115,171`. `README.md:142` still says the `PROGRESS.md` gate table is "explicitly contradicted" by QA-AUDIT-01; after `PROGRESS.md:184-190` that caution is stale — reword to "reconciled as per-job vs integrated". **(observed + inferred)**
4. **[LOW] PROGRESS gate table's bold row still reads "29/29 repeatedly".** `PROGRESS.md:194` retains `**29/29 repeatedly**`, even though `:186-190` scopes it as per-job only. This does **not** reopen C1 (the governance note is explicit and appears immediately above the table), but a cold reader who jumps straight to the table may still stop at the bold figure. Remaining edit, optional: add a "Scope" column or inline `per-job only; integrated 26/29 HEAD / 28/29 worktree` to `:194`. **(inferred)**
5. **[MEDIUM, out of the three-blocker scope] QA-DOCS-01's own non-blocker residuals were not part of this task and were not re-verified here** — e.g. `PROGRESS.md:199` "TEST-RUN-02 restarted" (C14), `PROGRESS.md:144` "Donor truth still pending" (C15), `GAPS.md` rows (C10–C13). **UNVERIFIED** in this pass; not claimed closed or open.

## 5. Open questions

1. Is C6 to be judged against QA-DOCS-01's original 12-ticket list (7 of 10 named tickets fixed → PARTIAL) or against the live board at read time (11 landed-but-RUNNING tickets → OPEN)? This report uses the live read and labels the finding PARTIAL because the specific duplicate blockers C2–C4 are closed and 7 original rows were corrected. **UNVERIFIED** — no written closure criterion found.
2. Should a `PENDING_VALIDATION` / `PENDING_SMOKE_RESULT` report be flipped to a plain DONE, or only from RUNNING to `REPORT DELIVERED`? `SWARM_BOARD.md:11` grants only the State column to COORD, but no state vocabulary is written down. **inferred**: use `REPORT DELIVERED (<frontmatter status>)`, matching `:117/:175/:186`.
3. Will the late-wave landings (11:25–11:27) keep growing after this report is written? The count rose from 139 to 142 `*.md` files in 74 seconds. **UNVERIFIED**: any later reader must re-run the `Test-Path` enumeration rather than trust §3's row list.
4. Are the duplicate pairs 14/51 and 28/52 to be physically merged later? `CORRECTIONS.md:111-115` says "Future edits should merge them rather than add a third row", resolving QA-DOCS-01's open question 2 in favour of the visible chain; the summary count (60) therefore includes both pairs. **UNVERIFIED** whether a future merge will reduce the headline to 58.

## 6. Summary

- **B1 / C1 — CLOSED.** `PROGRESS.md:184-190` removes the "LIVE" claim and explicitly separates per-job 29/29 artifacts from the integrated 26/29 HEAD / 28/29 worktree measurement. Verified twice (manual read + zero-match grep for a LIVE claim).
- **B2 — PARTIAL.** C2/C3/C4 are **CLOSED**: one authoritative row each at `SWARM_BOARD.md:64/:119/:232`, with removal comments at `:88/:187/:229`. C6 is **not closed**: at the 11:26:46 snapshot 11 tickets with reports on disk remain plain RUNNING, plus README-UPDATE-01 at `:236`. Of the original 10 named tickets, 7 were corrected and 3 remain.
- **B3 / C9 — CLOSED.** `CORRECTIONS.md:111-115` carries the required duplicate-chain notice for rows 14/51 and 28/52; `:171` says 60, and grep + manual read both give exactly rows 1–60 with no gaps or duplicate ids.
- **Rows 58–60 — CLOSED.** All three inventory-mismatch rows exist at `CORRECTIONS.md:107-109` and are cross-referenced by `SWARM_BOARD.md:242`.
- **Confidence labels:** structural findings above are **observed**; "7 of 10 fixed", "60 = max row id" and "2 of 3 blockers closed" are **derived**; cold-read risk and the precise suggested State-column edits are **inferred**; runtime truth of every cited gate job and any donor claim is **UNVERIFIED** (no job run, no donor read).
- The swarm was still landing files during verification; all residual counts are lower bounds at the stated snapshot.

**File-edit statement:** no file other than `docs/coord_swarm_2026-11-25/reports/QA_DOCS_02.md` was edited, created or deleted by this worker. No runner job was submitted; no code, config, test, asset, git, queue or runner state was touched by this worker.
