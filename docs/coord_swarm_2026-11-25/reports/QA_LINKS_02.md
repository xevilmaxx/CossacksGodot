---
id: QA-LINKS-02
title: "QA-LINKS-02 — did the concrete missing/stale LINKS-01 citations get resolved?"
area: documentation QA / read-only
owner: QA-LINKS-02 (read-only QA subagent)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_DOC_OR_CODE_EDITS__NO_RUNNER_JOBS
scope: "Exactly one new file: docs/coord_swarm_2026-11-25/reports/QA_LINKS_02.md. Re-tested the 15 §C concrete missing paths and 6 orphan reports from LINKS_01 on disk, checked citations in the five named living docs, and re-read the four stale 'absent' claims. No report, living doc, code, config, asset, backup or runner job was created or edited by this task."
labels: [observed, derived, inferred, UNVERIFIED]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
swarm: "docs/coord_swarm_2026-11-25/"
python: "python (3.14), not python3"
snapshot: "Point-in-time read; other workers were still landing reports and editing SWARM_BOARD.md during this pass. The board grew from ~254 lines at LINKS_01 to 298 lines here, and reports/ from 113 to 122 .md files, so all line numbers below are from this pass only."
verdict: "PARTIAL — 7 of 15 concrete paths now exist and are cited, but 8 remain absent, all 6 orphans remain uncited by the living docs, and all four stale 'absent' claims are unchanged."
---

# QA-LINKS-02 — resolution check of LINKS-01's concrete findings

## Sources (all read, read-only)

1. `docs/coord_swarm_2026-11-25/reports/LINKS_01.md` (386 lines) — the audit being re-checked; §C (15 missing paths), §D (20 stale old-doc paths), §Orphan (6 orphans), §Ranked issues (stale-claim ticket), §Manual sample.
2. `docs/coord_swarm_2026-11-25/README.md` (390 lines) — entry point / §6 pointer index / §3 pending table.
3. `docs/coord_swarm_2026-11-25/PROGRESS.md` (200 lines) — coordinator log, decisions S-25-01…S-25-15.
4. `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` (298 lines in this pass) — authoritative ticket State/Output table.
5. `docs/coord_swarm_2026-11-25/GAPS.md` (67 lines).
6. `docs/coord_swarm_2026-11-25/CORRECTIONS.md` (180 lines).

Supporting living docs read for the "absent"-claim and protocol-template checks only (not in the five named above): `CONFIG_PIPELINE.md`, `CONFIG_COUNT_RECONCILED.md`, `RUN_GUIDE.md`, `CAPTURE_RECHECK.md`, `decomp/SUMMARY.md`, plus `README.md`/`SWARM_BOARD.md`. [observed]

Path resolution used the same conventions as LINKS_01: `reports/…` and `decomp/…` → swarm folder; bare report name → `reports/`; `docs/…` → repo root. Existence decided by Python `Path.exists()`; citation by exact-basename search over the five named docs, with a second pass over every swarm `.md` for the orphans. [observed]

Labels: `observed` = literal disk/regex result; `derived` = classification and count; `inferred` = likely intent; `UNVERIFIED` = cannot prove from available evidence.

## Table A — the 15 concrete missing paths from LINKS_01 §C

`LINKS_01 status` is the frozen §C verdict. `now` is this pass. "Path resolved" means the file exists on disk **and** a living doc cites it; it does **not** mean the ticket is DONE or that any gate passed. [derived]

| path | LINKS_01 status | now | authoritative doc | resolved? |
|---|---|---|---|---|
| `TEST_RUN_02_selection_log.md` (bare → `reports/`) | §C: NO — "never landed"; README :202 "not landed"; RESERVED, no session | still NO on disk; cited by README.md:202 and SWARM_BOARD.md:121 | README.md:202 + SWARM_BOARD.md:121 (two conflicting records of one ticket) | **NO** — unresolved (observed) |
| `reports/MAP_SMALL_01_report.md` | §C: NO — in flight, MAP-SMALL-01 RUNNING | still NO; board row now :89, still RUNNING; README.md:206 still "REPORT MISSING" | SWARM_BOARD.md:89 (`Output` cell) | **NO** — unresolved (observed) |
| `reports/TEST_RUN_02_selection_log.md` | §C: NO — "never landed", twin of row 1 | still NO; cited by SWARM_BOARD.md:121 (RESERVED) + README.md:202 | SWARM_BOARD.md:121 | **NO** — unresolved (observed) |
| `reports/MINIMAP_QUAD_01.md` | §C: NO — in flight, MINIMAP-QUAD-01 RUNNING | **YES on disk**; cited SWARM_BOARD.md:143, but that row still says RUNNING | SWARM_BOARD.md:143 | **Path YES / state stale** (observed) |
| `reports/LINKS_01.md` | §C: NO at pass time — "landed by this task" | **YES on disk** (LINKS_01 itself); cited SWARM_BOARD.md:243, whose State still says RUNNING | SWARM_BOARD.md:243 | **Path YES / state stale** (observed) |
| `reports/QA_PARITY_01.md` | §C: NO — in flight, QA-PARITY-01 RUNNING | **YES on disk**; cited SWARM_BOARD.md:274, State still RUNNING | SWARM_BOARD.md:274 | **Path YES / state stale** (observed) |
| `reports/MAPSIZE_01.md` | §C: NO — in flight, MAPSIZE-01 RUNNING | **YES on disk**; cited SWARM_BOARD.md:277, State still RUNNING | SWARM_BOARD.md:277 | **Path YES / state stale** (observed) |
| `reports/PERF_3D_01.md` | §C: NO — in flight, PERF-3D-01 RUNNING | still NO; SWARM_BOARD.md:281 RUNNING and :29 still BUSY | SWARM_BOARD.md:281 | **NO** — unresolved (observed) |
| `reports/DARKROW_ALL_01.md` | §C: NO — in flight, DARKROW-ALL-01 RUNNING | still NO; SWARM_BOARD.md:283 RUNNING | SWARM_BOARD.md:283 | **NO** — unresolved (observed) |
| `reports/SEASON_TEST_PATH_01.md` | §C: NO — in flight, SEASON-TEST-PATH-01 RUNNING | still NO; SWARM_BOARD.md:288 RUNNING and :25 still BUSY | SWARM_BOARD.md:288 | **NO** — unresolved (observed) |
| `reports/DESERT_REMAP_02.md` | §C: NO — in flight, DESERT-REMAP-02 RUNNING | **YES on disk**; cited SWARM_BOARD.md:290, State still RUNNING | SWARM_BOARD.md:290 | **Path YES / state stale** (observed) |
| `reports/PROP_W_PLAN_01.md` | §C: NO — in flight, PROP-W-PLAN-01 RUNNING | **YES on disk**; cited SWARM_BOARD.md:291, State still RUNNING; board :26/:29 still calls its session BUSY | SWARM_BOARD.md:291 | **Path YES / state + session stale** (observed) |
| `reports/SP8_STATUS_01.md` | §C: NO — in flight, SP8-STATUS-01 RUNNING | **YES on disk**; cited SWARM_BOARD.md:292, State still RUNNING | SWARM_BOARD.md:292 | **Path YES / state stale** (observed) |
| `reports/RECHECK_P0.md` | §C: NO — CAPTURE-RECHECK protocol example, no owner | still NO on disk; **no citation in any of the five named living docs**; only `CAPTURE_RECHECK.md:247` names it as an example | `CAPTURE_RECHECK.md:247` (living doc, but not one of the five named) | **NO** — unresolved, but probably intentional template (inferred) |
| `reports/RECHECK_S1.md` | §C: NO — same protocol example | still NO on disk; no citation in the five named living docs; only `CAPTURE_RECHECK.md:247` | `CAPTURE_RECHECK.md:247` | **NO** — unresolved, but probably intentional template (inferred) |

**Derived count:** 7/15 now exist and are cited (MINIMAP-QUAD-01, LINKS-01, QA-PARITY-01, MAPSIZE-01, DESERT-REMAP-02, PROP-W-PLAN-01, SP8-STATUS-01); 8/15 still have no file. Repo-wide basename search found no copy of any of the 8 elsewhere (only the 7 landed ones returned a hit). All 7 landed paths still carry a RUNNING State in the board's authoritative State column — the file exists but the cold reader is told the ticket is still running. [observed + derived]

## Table B — the 6 orphan reports from LINKS_01 §Orphan

All six still exist on disk. None is cited by any of the five named living docs; README.md §6 still uses ellipsis ranges (`SP_01…SP_08` at :336, `TEST_P0…TEST_P3` and `TEST_C1…TEST_C4` at :312) and still omits TRN-DATA from the implementation list at :368-371. A second pass over every swarm `.md` found citations only in **other reports** (SP-05 → `CONFIG_PLAN_01`, `LFS_PLAN_01`, `SP_06_renderer_hook`; TEST-P1/P2 → `TEST_C1_report`; TRN-DATA → `FINAL_GATE_PLAN_01`, `QA_AUDIT_01`, `QA_DOCS_01`) and in `LINKS_01.md:55,349-354` itself — reports are not living docs, so the orphan condition is unchanged. [observed]

| report on disk | LINKS_01 status | now | authoritative doc | resolved? |
|---|---|---|---|---|
| `reports/SP_05_loader_override.md` | orphan — hidden behind `SP_01…SP_08` range | EXISTS; still uncited by the five living docs | README.md:336 (§6 pointer index) | **NO** — unresolved (observed) |
| `reports/TEST_P1_report.md` | orphan — hidden behind `TEST_P0…TEST_P3` range | EXISTS; still uncited by the five living docs | README.md:312 | **NO** — unresolved (observed) |
| `reports/TEST_P2_report.md` | orphan — same range | EXISTS; still uncited by the five living docs | README.md:312 | **NO** — unresolved (observed) |
| `reports/TEST_C2_report.md` | orphan — hidden behind `TEST_C1…TEST_C4` range | EXISTS; still uncited by the five living docs | README.md:312 | **NO** — unresolved (observed) |
| `reports/TEST_C3_report.md` | orphan — same range | EXISTS; still uncited by the five living docs | README.md:312 | **NO** — unresolved (observed) |
| `reports/TRN_DATA_implementation.md` | orphan — "true omission" from README §6 implementation list | EXISTS; still uncited by the five living docs | README.md:368-371 | **NO** — unresolved (observed) |

## Stale "absent" claims — re-check

All four report files exist on disk. None of the four claims has been corrected in this pass; each still asserts a file is absent while the file (and in three cases the board's DONE/REPORT DELIVERED State) is present. [observed]

| claim | LINKS_01 finding | current text | corrected? |
|---|---|---|---|
| CONFIG_WIRE_RELIEF | `CONFIG_COUNT_RECONCILED.md:94,205,220` and `CONFIG_PIPELINE.md:223,247,266,311` call the report absent | `CONFIG_COUNT_RECONCILED.md:94` "report `CONFIG_WIRE_RELIEF.md` absent"; `:144` "report still absent"; `:205` report **absent**; `:220` "Will `CONFIG_WIRE_RELIEF.md` land?"; `CONFIG_PIPELINE.md:310` lists CONFIG-WIRE-RELIEF among those with "no landed" [note: line numbers shifted from LINKS_01] | **NO** — `reports/CONFIG_WIRE_RELIEF.md` EXISTS; board :275 still RUNNING (observed) |
| TERRAIN_DARK_FIX | README.md:299 "RUNNING with no report on disk" | README.md:299 is unchanged: "`TERRAIN-DARK-FIX` is **RUNNING with no report on disk** (`SWARM_BOARD.md:186`)" | **NO** — `reports/TERRAIN_DARK_FIX.md` EXISTS; board :209 says REPORT DELIVERED (observed) |
| GDIGNORE_01 | RUN_GUIDE.md:139 "There is **no** `GDIGNORE_01.md`" | RUN_GUIDE.md:139 unchanged: "There is **no** `GDIGNORE_01.md` in this folder or `reports/` at writing time" | **NO** — `reports/GDIGNORE_01.md` EXISTS (138 lines); board :297 DONE (observed) |
| DONAVAL_01 | `decomp/SUMMARY.md:256` says DSEASON_01/DONAVAL_01 absent | `decomp/SUMMARY.md:6` frontmatter "DSEASON-01 / DONAVAL-01 not landed"; `:253` "`DSEASON_01` and `DONAVAL_01` were not present in `../reports/`" (LINKS_01 cited :256; text now at :253) | **NO** — both `reports/DONAVAL_01.md` and `reports/DSEASON_01_season_visuals.md` EXIST; board :293/:300 DONE (observed) |

## Secondary observation — the 20 stale old-doc paths (§D)

Not part of the mandatory table, but spot-checked because the task named them. They remain largely as LINKS_01 found them: bare names in `CORRECTIONS.md`'s "Old source" column (e.g. `DA_PE.md`, `DB_SCRIPTS.md`, `RB_MECHANICS.md`, `TERRAIN_PORT_HILLS.md`, `RE_VISUAL.md`, `QA_REPORT.md`) and in `CONFIG_PIPELINE.md`/`RUN_GUIDE.md`/`TEST_MATRIX.md`. One partial prefix fix is visible: `CORRECTIONS.md:47` row 1 now prints `docs/decomp/DA_PE.md` in full while row 2 at `:48` still prints bare `DA_PE.md`. LINKS_01's inference that these are intentional historical references is unchanged; a cold reader still cannot follow most of them as paths. [observed + inferred]

## Verdict

**PARTIAL — no fix ticket from LINKS_01 §Ranked issues appears to have been executed.** The concrete path gap improved by 7 files, but every other class of finding is unchanged: 8 concrete paths still absent, 6 orphans still uncited, 4 stale "absent" claims still wrong, and the 7 newly landed reports still show RUNNING in the authoritative State column. [derived]

Remaining blockers, ranked:

1. **P1 — all four stale "absent" claims remain.** Four files exist on disk and three have DONE/REPORT DELIVERED board rows, yet README.md:299, RUN_GUIDE.md:139, CONFIG_COUNT_RECONCILED.md:94/144/205/220, CONFIG_PIPELINE.md:310 and decomp/SUMMARY.md:6/253 still say absent/not landed. This is LINKS_01's own top-ranked blocker (DOC-STALE-STATUS-01) and it was not actioned. [observed]
2. **P1 — authoritative board State is stale for 7 landed reports.** MINIMAP-QUAD-01 (:143), LINKS-01 (:243), QA-PARITY-01 (:274), MAPSIZE-01 (:277), DESERT-REMAP-02 (:290), PROP-W-PLAN-01 (:291), SP8-STATUS-01 (:292) all have a report on disk while State = RUNNING. PROP-W-PLAN-01 is additionally listed as a BUSY session at board :26/:29. A cold reader cannot trust the State column even for paths that do resolve. [observed]
3. **P1 — 8 of 15 concrete paths still have no file.** 4 are in-flight with named owners (MAP-SMALL-01 :89, PERF-3D-01 :281, DARKROW-ALL-01 :283, SEASON-TEST-PATH-01 :288), 2 are the never-landed TEST-RUN-02 selection-log pair with conflicting README/board records (:202 vs :121), and 2 are CAPTURE-RECHECK protocol examples with no owner. [derived from board rows]
4. **P2 — all 6 orphan reports remain uncited by the living docs.** README §6 still relies on ellipsis ranges; TRN-DATA is still omitted from the implementation list. No `LINKS-ORPHAN-01` fix is visible. [observed]
5. **P2 — 20 stale old-doc paths largely unchanged** (one partial prefix fix in CORRECTIONS.md row 1). Cold-readability defect persists, though intent is probably historical. [observed + inferred]
6. **P3 — no `RECHECK_<ROW>.md` has landed.** Both protocol examples remain examples; whether any ladder row was actually re-checked is UNVERIFIED. [observed + UNVERIFIED]

No visual-parity, gate, test-result, code or donor claim was checked here. File existence and citation do not imply a PASS verdict. [observed]

## Open questions

1. Will the 4 in-flight report paths (MAP-SMALL-01, PERF-3D-01, DARKROW-ALL-01, SEASON-TEST-PATH-01) land before COORD's final gate? [UNVERIFIED — board is a moving snapshot]
2. Were DOC-STALE-STATUS-01 / LINKS-FILL-01 / LINKS-PREFIX-01 / LINKS-ORPHAN-01 / LINKS-TESTLOG-01 ever assigned? No ticket row for them exists on the current board. [observed + UNVERIFIED]
3. Are `RECHECK_P0.md` / `RECHECK_S1.md` intentionally templates only (so their absence is not a defect)? [inferred yes from CAPTURE_RECHECK.md:247; UNVERIFIED]
4. Why is PROP-W-PLAN-01's session still called BUSY at board :26/:29 while its report exists at :291? [UNVERIFIED — report may have landed before session termination]
5. Is `reports/LINKS_01.md` meant to gain a §6 pointer-index entry, or remain cited only by its own board target cell? [inferred not yet; UNVERIFIED]
6. Did any of the 7 newly landed reports change a gate verdict? Not checked; no claim made. [UNVERIFIED]

## Summary

- **Read:** LINKS_01 plus the five named living docs; six further living docs for the claim/protocol checks. [observed]
- **15 concrete paths:** 7 now exist and are cited; 8 still absent. Repo-wide search found no hidden copies of the 8. [observed + derived]
- **6 orphans:** all 6 still exist, all 6 still uncited by the living docs; citations exist only in other reports. [observed]
- **4 stale "absent" claims:** 0 of 4 corrected; all contradicted by files on disk (and mostly by the board's own DONE/REPORT DELIVERED State). [observed]
- **Board State:** 7 landed reports still marked RUNNING. [observed]
- **Highest-value next action (not performed here):** execute DOC-STALE-STATUS-01 and sync the board State column, README, RUN_GUIDE, CONFIG_* and decomp/SUMMARY to the files already on disk. [inferred]
- **Scope:** no file other than `docs/coord_swarm_2026-11-25/reports/QA_LINKS_02.md` was created or edited. The three analysis scripts used live outside the repo in `%LOCALAPPDATA%\Temp\opencode\` (`links02_check.py`, `links02_claims.py`, `links02_claims2.py`, `links02_final.py`); no runner job was submitted.
