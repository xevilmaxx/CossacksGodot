---
id: LINKS-FIX-01
title: "LINKS-FIX-01 — corrected stale absent/not-landed report claims in four owned living docs"
area: documentation repair / links
owner: LINKS-FIX-01 (documentation repair subagent)
date: 2026-11-25
status: COMPLETE__DOC_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Four owned living docs edited (RUN_GUIDE.md, CONFIG_COUNT_RECONCILED.md, CONFIG_PIPELINE.md, decomp/SUMMARY.md) plus this new report. README.md, SWARM_BOARD.md, all code/config/assets and all pre-existing reports untouched."
labels: [observed, derived, inferred, UNVERIFIED]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
swarm: "docs/coord_swarm_2026-11-25/"
python: "python (3.14), not python3"
snapshot: "Point-in-time re-read on 2026-11-25. QA_LINKS_02.md was itself a moving snapshot; line numbers quoted as 'before' come from that report and from the pre-edit reads, 'after' line numbers from this pass. Board State rows and other workers' files may still be moving."
source_of_truth: "reports/QA_LINKS_02.md (stale-claim table §71-80, orphan table §58-69, ranked blockers §90-97)"
---

# LINKS-FIX-01 — stale "absent / not landed" claim repair

## 0. What was verified first

Every report named below was checked on disk before any edit (PowerShell `Test-Path` /
`Get-ChildItem`, 2026-11-25). All exist in `docs/coord_swarm_2026-11-25/reports/`: [observed]

| Report | Lines | Frontmatter status (quoted, not promoted) |
|---|---:|---|
| `reports/CONFIG_WIRE_RELIEF.md` | 142 | `status: DONE — one owned source file + this report; one variant-runner parse check`; `verdict: CONFIG_GATE_ADDED__DEFAULT_OFF_PRESERVES_BEHAVIOUR__PLT2_MAPPING_UNCHANGED__K_RAVINE_1_STILL_BLOCKED` |
| `reports/GDIGNORE_01.md` | 106 | `status: AUDITED__REPORT_ONLY__NO_EDITS`; runtime/export items remain UNVERIFIED in the report |
| `reports/DONAVAL_01.md` | 219 | `status: COMPLETE — truth captured, 7 corrections logged, port gaps ranked; NO parity claim` |
| `reports/DSEASON_01_season_visuals.md` | 200 | `status: DELIVERED__READ_ONLY_DONOR_AUDIT__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY`; `visual_parity_claim: false` |
| `reports/SP_05_loader_override.md` | 201 | exists (orphan list) |
| `reports/TEST_P1_report.md` | 169 | exists (orphan list) |
| `reports/TEST_P2_report.md` | 162 | exists (orphan list) |
| `reports/TEST_C2_report.md` | 247 | exists (orphan list) |
| `reports/TEST_C3_report.md` | 180 | exists (orphan list) |
| `reports/TRN_DATA_implementation.md` | 77 | exists (orphan list) |

Nothing in this task asserts that any of these is a PASS, a green gate, or a done ticket;
only that the **path** is on disk. Report verdicts are left to the reports themselves. [observed]

## 1. Per-file before → after

Line numbers are 1-based; `:before → :after` shows a shift only where text was inserted.

### 1.1 `docs/coord_swarm_2026-11-25/RUN_GUIDE.md` (143 lines, unchanged length)

- **:139 → :139** (§8 "Where to report new findings")
  - before: "There is **no** `GDIGNORE_01.md` in this folder or `reports/` at writing time (directory listing, 2026-11-25) — any `.gdignore` verdict is **UNVERIFIED**; the only landed import evidence is `ASSET_IMPORT_01.md:123-141`."
  - after: "At writing time there was **no** `GDIGNORE_01.md` here; a later re-read (LINKS-FIX-01, 2026-11-25) finds the report-only audit on disk at `reports/GDIGNORE_01.md` — see that report's own verdict, and note its runtime/export consequences stay **UNVERIFIED** there. The import evidence cited here is `ASSET_IMPORT_01.md:123-141`."
  - Evidence: `reports/GDIGNORE_01.md` frontmatter (`AUDITED__REPORT_ONLY__NO_EDITS`) and §7 Summary/UNVERIFIED list; QA_LINKS_02.md:79.
  - The historical "at writing time" qualifier was kept so the original snapshot is not rewritten; no `.gdignore` verdict was upgraded.

### 1.2 `docs/coord_swarm_2026-11-25/CONFIG_COUNT_RECONCILED.md` (237 lines, unchanged length)

- **:9 → :9** (frontmatter `snapshot:`): appended one sentence — "Post-snapshot re-read (LINKS-FIX-01, 2026-11-25): `reports/CONFIG_WIRE_RELIEF.md` is now on disk while board `:218` still says RUNNING; the 11/2/2/6 count and all verdicts are unchanged by that file landing." The original HEAD/worktree caveat is untouched. Evidence: `reports/CONFIG_WIRE_RELIEF.md` on disk; report frontmatter status DONE.
- **:94 → :94** (row 10, `terrain.relief_stamps`, evidence cell)
  - before: "**report `CONFIG_WIRE_RELIEF.md` absent, smoke UNVERIFIED, board `:218` RUNNING** — see §6"
  - after: "**`reports/CONFIG_WIRE_RELIEF.md` now on disk (report status DONE; smoke UNVERIFIED at runtime), board `:218` still RUNNING** — see §6"
  - Evidence: `reports/CONFIG_WIRE_RELIEF.md:1-14` (status/verdict/smoke fields).
- **:144 → :144** (crosswalk row 10, last cell)
  - before: "call + `main.gd.bak-CONFIGWIRER` present by QA time; report still absent; board `:218` RUNNING"
  - after: "call + `main.gd.bak-CONFIGWIRER` present by QA time; report now on disk (`reports/CONFIG_WIRE_RELIEF.md`); board `:218` RUNNING"
- **:205 → :205** (§6 in-flight table, row 10)
  - before: `SWARM_BOARD.md:218` **RUNNING** | … report `CONFIG_WIRE_RELIEF.md` **absent** | If the gate is reverted, 11 → **10 WIRED**; if the report lands, status stays WIRED but UNVERIFIED clears
  - after: `SWARM_BOARD.md:218` **RUNNING** (stale) | … report `reports/CONFIG_WIRE_RELIEF.md` **on disk** (re-read 2026-11-25) | If the gate is reverted, 11 → **10 WIRED**; the report has landed, so the remaining caveats are the board State and the lack of a runtime probe, not a missing report
  - The 11 WIRED count and the revert scenario were not changed.
- **:220 → :220** (§7 open question 1)
  - before: "Will `CONFIG_WIRE_RELIEF.md` land, or will the `main.gd` gate be reverted? Row 10's WIRED status rests on a call site with no report. [UNVERIFIED]"
  - after: "`reports/CONFIG_WIRE_RELIEF.md` has landed — will the `main.gd` gate be reverted? Row 10's WIRED status rests on a call site that now has a report, but its board row still says RUNNING and no runtime probe proves a non-default value. [UNVERIFIED]"
  - Evidence: QA_LINKS_02.md:77 (four stale claims) and the on-disk report.

### 1.3 `docs/coord_swarm_2026-11-25/CONFIG_PIPELINE.md` (340 → 365 lines, net +25: 31 added / 6 removed)

- **:11 → :11** (frontmatter `snapshot:`): appended one sentence — "Post-snapshot re-read (LINKS-FIX-01, 2026-11-25): `reports/CONFIG_WIRE_RELIEF.md` is now on disk although board `:218` still says RUNNING; the 7/2/2/10 freeze, the file-ownership table and all verdicts are unchanged by that path landing." Original board-staleness caveat untouched.
- **:53-55 → :53-57** (§1 Sources read, closing note)
  - before: "No other `CONFIG*` file exists in `reports/` (directory listing checked): only the six files above. The two `docs/audit/CONFIG_*` files are older 2D audits and are **not** additional 3D pipeline reports. Label: observed."
  - after: "At snapshot time the `CONFIG*` set was the six files above; a later re-read (LINKS-FIX-01, 2026-11-25) also finds `reports/CONFIG_WIRE_HUD.md` and `reports/CONFIG_WIRE_RELIEF.md` on disk. That is a path fact only — it does not promote either ticket to DONE/PASS. The two `docs/audit/CONFIG_*` files are older 2D audits and are **not** additional 3D pipeline reports. Label: observed."
  - This was in scope as the same "no file exists" stale-status class as the assigned RELIEF claim; the directory now contains eight `CONFIG_*.md` files. [observed — `Get-ChildItem -Filter "CONFIG*"`]
- **new :59-78** (§1.1 "Additional report pointers (added by LINKS-FIX-01, 2026-11-25)"): explicit six-row pointer list satisfying the orphan citation requirement —
  `reports/SP_05_loader_override.md`, `reports/TEST_P1_report.md`, `reports/TEST_P2_report.md`,
  `reports/TEST_C2_report.md`, `reports/TEST_C3_report.md`, `reports/TRN_DATA_implementation.md`.
  The section states it is a pointer list only (no gate/verdict/status promotion) and cites the
  2026-11-25 directory listing plus `reports/QA_LINKS_02.md` Table B as evidence.
- **:310-311 → :331-336** (§7 honesty constraint 4, "Board vs reports")
  - before: "Conversely CONFIG-WIRE-HUD, CONFIG-WIRE-RELIEF and WEATHER-DRIVER-01 have **no landed report** and are not claimed as done here. [observed]"
  - after: "Conversely CONFIG-WIRE-HUD and WEATHER-DRIVER-01 have **no landed report** at this snapshot and are not claimed as done here. `reports/CONFIG_WIRE_RELIEF.md` was absent then but is on disk at the LINKS-FIX-01 re-read (2026-11-25); no done/PASS claim is made for it here. [observed]"
  - Only the RELIEF member of the sentence was corrected; the HUD and WEATHER-DRIVER text was preserved except for the point-in-time qualifier. Evidence: QA_LINKS_02.md:77.

### 1.4 `docs/coord_swarm_2026-11-25/decomp/SUMMARY.md` (386 → 388 lines, net +2: 4 added / 2 removed)

- **:6 → :6** (frontmatter `refreshed_with:`)
  - before: "…; DSEASON-01 / DONAVAL-01 not landed"
  - after: "…; DSEASON-01 / DONAVAL-01 were not landed at refresh time, but their reports are on disk as of the LINKS-FIX-01 re-read (2026-11-25) — see §13 note"
  - Evidence: `reports/DSEASON_01_season_visuals.md`, `reports/DONAVAL_01.md` (both on disk).
- **:253-255 → :253-256** (§13 intro)
  - before: "`DSEASON_01` and `DONAVAL_01` were not present in `../reports/` at refresh time and are **not** summarised — do not infer their contents. For reversals, `../CORRECTIONS.md` (57 rows) is authoritative. **No donor visual-parity claim is made.**"
  - after: "`DSEASON_01` and `DONAVAL_01` were not present in `../reports/` at refresh time; a later re-read (LINKS-FIX-01, 2026-11-25) finds both on disk at `../reports/DSEASON_01_season_visuals.md` and `../reports/DONAVAL_01.md`. They are still **not** summarised here — do not infer their contents from this section. For reversals, `../CORRECTIONS.md` (57 rows) is authoritative. **No donor visual-parity claim is made.**"
  - The "not summarised" guard and the no-parity claim were deliberately kept; no donor claim was added. Evidence: QA_LINKS_02.md:80.

## 2. Files edited (exact list)

1. `docs/coord_swarm_2026-11-25/RUN_GUIDE.md`
2. `docs/coord_swarm_2026-11-25/CONFIG_COUNT_RECONCILED.md`
3. `docs/coord_swarm_2026-11-25/CONFIG_PIPELINE.md`
4. `docs/coord_swarm_2026-11-25/decomp/SUMMARY.md`
5. `docs/coord_swarm_2026-11-25/reports/LINKS_FIX_01.md` (this new report)

**Not edited:** `README.md` (README-FINAL-01 owns it), `SWARM_BOARD.md` (COORD owns it), all
pre-existing reports, and all code/config/asset/backup files. No runner job was submitted.

## 3. Constraints observed

- Only stale **path/status** statements were changed. Counts (11/2/2/6 and 7/2/2/10),
  vote vocabularies, ownership tables, gate results and donor claims were left intact.
- No report was promoted to PASS/DONE-by-citation; each edited sentence explicitly says
  "path fact only" / "no done/PASS claim" or defers to the report's own verdict. [observed]
- The historical point-in-time wording ("at writing time", "at snapshot time",
  "at refresh time", the `49aa81f7` chronology row at `CONFIG_COUNT_RECONCILED.md:165`) was
  retained so the old snapshot is not silently rewritten. [observed]

## 4. Open questions / handoffs

1. **TERRAIN-DARK-FIX not fixed here.** QA_LINKS_02.md:78 locates the stale claim in
   `README.md:299` ("RUNNING with no report on disk") — a file outside this task's exclusive
   ownership. `reports/TERRAIN_DARK_FIX.md` is on disk (224 lines, status
   `DELIVERED__ONE_SHADER_EDITED__SMOKE_GREEN__P0_GATES_PASS__NO_DONOR_PARITY`). Handoff to
   README-FINAL-01 required. [observed]
2. **Board State rows remain stale** for several landed reports (QA_LINKS_02.md:93). SWARM_BOARD.md
   is COORD-owned and was not touched. [observed]
3. **Other uncited-landed pairs left as-is** because they are outside the four-report assignment:
   `CONFIG_PIPELINE.md:243,265` (HUD "no report") and `CONFIG_COUNT_RECONCILED.md:147,169`
   (WEATHER-DRIVER "no report"). `reports/CONFIG_WIRE_HUD.md` and `reports/WEATHER_DRIVER_01.md`
   are on disk; a follow-up ticket should decide whether those stale claims are repaired and
   whether the board rows are synced. [observed]
4. **README.md §6 ellipsis ranges remain**; the six orphans are now cited in
   `CONFIG_PIPELINE.md §1.1` instead of in README (which this task may not edit). [observed]
5. Whether any of the newly landed reports changes a gate verdict was **not** checked; no
   such claim is made. [UNVERIFIED]

## 5. Summary

- Verified 10 on-disk paths (4 stale-claim reports + 6 orphans) before editing. [observed]
- Corrected 4 assigned stale claims in the 4 owned docs: GDIGNORE_01 (:139), CONFIG_WIRE_RELIEF
  (CONFIG_COUNT :94/:144/:205/:220 and CONFIG_PIPELINE :310→:331-336), DSEASON_01/DONAVAL_01
  (SUMMARY :6/:253-255). Snapshot caveats were updated in both CONFIG docs. [observed]
- Added an explicit 6-report pointer section at `CONFIG_PIPELINE.md:59-78`, so all six orphans
  from QA_LINKS_02.md Table B are now cited by a living doc. [observed + derived]
- No factual claim beyond the stale status changed; no PASS promotion; no README/SWARM_BOARD/code
  edit. [observed]
