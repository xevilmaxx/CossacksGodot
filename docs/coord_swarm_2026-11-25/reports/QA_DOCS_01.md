---
id: QA-DOCS-01
title: "QA-DOCS-01 — cold-readability and evidence-discipline audit of the 2026-11-25 report set"
date: 2026-11-25
owner: QA-DOCS-01 (read-only documentation QA worker)
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT_ONLY
scope: "This report is the ONLY file written. No code, config, test, asset, git, queue or runner state touched; no Godot job submitted; no donor file accessed."
labels: [observed, derived, inferred, UNVERIFIED]
audit_mode: read-only; findings are not fixes
snapshot: "Inventory verified at 2026-11-25 ~11:07:45 local; the swarm was still landing files during the audit"
---

# QA-DOCS-01 — report-set QA (cold readability + evidence discipline)

## 0. Method and label key

- **observed** — counted/read directly this pass (shell enumeration, Python enumeration, file reads with line numbers).
- **derived** — arithmetic over observed counts/statuses (e.g. 57 indexed rows minus 2 duplicate pairs).
- **inferred** — judgement about a cold reader's likely misreading; stated as such, never asserted as fact about intent.
- **UNVERIFIED** — not checked (e.g. runtime truth of any claim; no job was run and no donor was read).

Evidence discipline: every finding below names a file:line (or a shell/Python command result) as the authority. No PASS result is claimed by this audit; where PASS appears it is quoted from a cited report with its job id. Counts were verified twice by two independent enumerations, plus a read-sample of 40+ reports.

## 1. Inventory counts

Two independent enumerations of `docs/coord_swarm_2026-11-25/**/*.md`:

| Snapshot | Method | Total files | Total bytes | Root | `reports/` | `decomp/` |
|---|---|---:|---:|---:|---:|---:|
| Start of audit (pre-late-wave) | PowerShell `Get-ChildItem -Recurse -Filter *.md` + `Measure-Object Length -Sum` | **120** | **2,842,965** | 11 / 212,503 B | 98 / 2,176,559 B | 11 / 453,903 B |
| Start of audit (cross-check) | `python` 3.14 `Path.rglob("*.md")` + `stat().st_size` | **120** | **2,842,965** | — | — | — |
| Final, 2026-11-25 11:07:45 local | `python` 3.14 `Path.rglob("*.md")` + PowerShell re-run | **127** | **2,991,215** | 13 / 280,955 B | 103 / 2,256,357 B | 11 / 453,903 B |
| Post-write, 2026-11-25 11:11:52 local (includes this report) | `python` 3.14 `Path.rglob("*.md")` | **131** | **3,075,468** | — | — | — |

**observed:** the two start-of-audit methods agree exactly (120 / 2,842,965). **derived:** the +7-file / +148,250-byte delta during this audit came from late-wave landings: root `CAPTURE_RECHECK.md`, `RUN_GUIDE.md`; reports `QA_WINTER_01.md`, `AUDIO_SEL_02.md`, `MOTION_ANIM_01.md` (final edit), `WEATHER_DRIVER_01.md`, `GDIGNORE_01.md`, `SP_06_renderer_hook.md`, `README_UPDATE_01.md`; plus growth of `README.md` (16,150 → 30,308 B) and `SWARM_BOARD.md` (47,396 → 50,014 B). Counts above **exclude this report**; once `QA_DOCS_01.md` lands the total is +1 file. **inferred:** any hard-coded count in a living doc will be stale within minutes during this swarm — counts should carry a clock time, not only a date.

**Second verification (read sample):** all 99 reports present at the first full scan had YAML frontmatter (opening `---` and a closing delimiter) and at least one evidence-style citation (`file:line`, `file:0xoffset`, or an evidence id such as `D1E02`/`N11`/`C1`). The four later arrivals (`SP_06_renderer_hook.md`, `README_UPDATE_01.md`, `WEATHER_DRIVER_01.md`, `GDIGNORE_01.md`) were read individually and also have frontmatter and citations. **UNVERIFIED:** no attempt was made to re-run any cited job or open donor data.

## 2. Sampled-report table (34 reports, all categories)

Legend: FM = frontmatter present; Lab = evidence labels `observed/derived/inferred/UNVERIFIED` used in body/frontmatter; Cite = `path:line`/evidence ids present; PASS = PASS claims carry a job/ticket id or are explicitly non-run/static; Sole = explicit "one file / no other file edited" where relevant; OQ = open questions present. `Y`/`N` are observed from reading the named file, not inferred from the board.

| # | Category | Report | FM | Lab | Cite | PASS / job | Sole | OQ | QA note (authority) |
|---:|---|---|:-:|:-:|:-:|---|:-:|:-:|---|
| 1 | Donor deep dive | `reports/DTRN_01_donor_terrain_pipeline.md` | Y | Y (`:10`) | Y (138) | N/A — audit only | Y (`:6`) | Y (§8) | Model example: two verification passes at `:51-66`, claim table label key `:108-110` |
| 2 | Donor deep dive | `reports/DSEL_01_donor_selection_rectangle.md` | Y | Y | Y (146) | N/A | Y | Y | 4-pass native predicate stays UNVERIFIED |
| 3 | Donor deep dive | `reports/DALPHA_01_alpha_subrect.md` | Y | Y | Y (+ids) | N/A | Y (`:6`) | Y (§8) | Two decoders; tile→patch CONFIRMED_UNVERIFIED |
| 4 | Donor deep dive | `reports/DANIM_01_action_ranges.md` | Y | Y | Y (89) | N/A | Y (`:624`) | Y | Frontmatter closing delimiter is beyond 1,200 chars — naive parsers may miss it |
| 5 | Donor deep dive | `reports/DBIND_01_wus_bind.md` | Y | Y | Y (`0x…` offsets) | N/A | Y (`:6`) | Y | Negative proof cited byte-range; not "no evidence" |
| 6 | Donor deep dive | `reports/DENV_01_environment.md` | Y | Y | Y (130) | N/A | Y (`:6`) | Y | FogMode ambiguity correctly not upgraded to fact |
| 7 | Donor deep dive | `reports/DFX_01_pfx_effects.md` | Y | Y | Y (91) | N/A | Y (`:39`) | Y | No construction-dust claim explicitly bounded |
| 8 | Donor deep dive | `reports/DBUILD_01_building_stages.md` | Y | Y | Y (95) | N/A | Y (`:287`) | Y | End note restates read-only discipline |
| 9 | Donor deep dive | `reports/DAUDIO_01_sound_events.md` | Y | Y | Y (185) | N/A | Y | Y | 325/325 clip mapping; selection sounds non-positional |
| 10 | Decomp | `decomp/DEC_01_binaries_rtti.md` | Y | Y | Y (`D1E*`) | N/A | Y | Y | Evidence ids indexed in `decomp/EVIDENCE_INDEX.md` |
| 11 | Decomp | `decomp/DEC_02_scripts.md` | Y | Y | Y (ids) | N/A | Y | Y | Board `:38` still says "agent finalizing" though lane CLOSED (`:46`) |
| 12 | Decomp | `decomp/DEC_05_terrain_formats.md` | Y | Y | Y (`N11` etc.) | N/A | Y | Y | Donor `gc_meters_to_tile=2` cited by id |
| 13 | Decomp | `decomp/DEC_07_cameras_shaders.md` | Y | Y | Y | N/A | Y | Y | §8.1/§8.3 refuted by RV-CAM/RV-SEL; correction chain indexed in `CORRECTIONS.md:52-55` |
| 14 | Decomp | `decomp/EVIDENCE_INDEX.md` | Y | N (index, not claims) | Y | N/A | N/A | **N** | Index has no open-questions section — acceptable for an index, noted for completeness |
| 15 | Decomp | `decomp/SUMMARY.md` | Y | Y | Y | N/A | Y | Y | `CORRECTIONS.md:152-153` flags its still-stale DEC-04 frame-0 claim |
| 16 | Implementation | `reports/SEL_01_implementation.md` | Y | Y | Y (18) | Y — probe 329/326, gates 337/318 (`:89-96`) | Y (`:93`) | Y | PASS rows carry job ids |
| 17 | Implementation | `reports/TRN_DATA_implementation.md` | Y | Y | Y (8) | Y — job 423 (report §verification; board `:111`) | Y | Y | Status honestly "FULL_SELFTEST_AMBER" |
| 18 | Implementation | `reports/TRN_SHADER_implementation.md` | Y | Y | Y (37) | Y — smoke 342 | Y | Y | PORT APPROX texgen labelled |
| 19 | Implementation | `reports/DECOR_01_implementation.md` | Y | **N** (`:7` domain labels only; `UNVERIFIED` at `:8` is status, not a label) | Y (9) | Y — ticket 358 (`:10`) | Y (`:6`) | Y | Evidence-label gap (MEDIUM-1) |
| 20 | Implementation | `reports/CONFIG_WIRE_SEL.md` | Y | **N** (`:13` domain labels only) | Y (39) | Y — tickets 430/438 (`:12`) | Y (`:7`) | Y | Evidence-label gap |
| 21 | Implementation | `reports/SP_01_season_enum.md` | Y | Y | Y (29) | Y — `sp01-smoke` (`:167`) | Y | Y | No donor parity claimed |
| 22 | Implementation | `reports/SP_05_loader_override.md` | Y | Y | Y (16) | N/A | Y | Y | Default fallback byte-identical (report claim, UNVERIFIED at runtime) |
| 23 | Implementation | `reports/HUD_01_minimap.md` | Y | Y | Y (26) | N/A | Y | Y | Bottom-right 240×240 with donor citations |
| 24 | Implementation | `reports/AUDIO_SEL_02.md` | Y | partial (UNVERIFIED only) | Y (16) | Y — status `PENDING_VALIDATION`, no job id on claim line `:138` | Y (`:28`) | Y (`:131`) | Report landed; board `:217` still RUNNING |
| 25 | Test atom | `reports/TEST_P0_report.md` | Y | Y | Y (92) | Frontmatter `NOT RUN`; PASS column is assertion design (`:74-107`) | Y (`:7`) | Y | Model authoring report: no PASS claim without job |
| 26 | Test atom | `reports/TEST_C1_report.md` | Y | Y | Y (79) | `NOT RUN`; PASS column is design | Y | Y | Status `AUTHORED__NOT_RUN__NO_GODOT` |
| 27 | Test atom | `reports/TEST_HARNESS_report.md` | Y | Y | Y (33) | N/A — no Godot runs | Y | Y | `AUTHORED__NO_GODOT_RUNS__NO_RUNNER_JOBS` |
| 28 | Test atom | `reports/ATOM_REPAIR_report.md` | Y | partial (UNVERIFIED only) | Y (19) | Y — jobs 364–375 | Y (scope `:7`) | Y | Uses `scope:` rather than "no other file" phrase |
| 29 | Test atom | `reports/SP_08_season_test.md` | Y | Y | Y (89) | PASS is verdict-rule text (`:111,141-144`), not a run | Y | Y | `PENDING_DEP`; no fake PASS |
| 30 | Re-verification | `reports/RV_TRN_01_texgen_mask_reverify.md` | Y | Y | Y (28) | N/A | Y | Y | Eye planes CONFIRMED_UNVERIFIED, not silently promoted |
| 31 | Re-verification | `reports/RV_SEL_01_selection_reverify.md` | Y | Y | Y (66) | N/A | Y | Y | 4th pass; `[*]=;` live-code proof |
| 32 | Re-verification | `reports/RV_CAM_01_fov_resolution.md` | Y | Y | Y (28) | PASS mentions are rebuttals of prior claims, not new runs | Y (`:7`) | Y | FOV CONFIRMED_UNVERIFIED |
| 33 | Re-verification | `reports/DEFAULTS_VERIFY_01.md` | Y | Y | Y (91) | N/A — static verification | Y (`:7`) | Y | Refutes CFG-02/QA-AUDIT F-05 with `config.gd:545` |
| 34 | Docs / synthesis | `reports/QA_AUDIT_01_implementation_claims.md` | Y | **N** (`:9` uses `CONFIRMED/PARTIAL/REFUTED`, not evidence labels) | Y (10) | N/A — no job run | Y (`:7`) | Y | Findings carry job-artifact ids; label gap is stylistic |
| 35 | Docs / synthesis | `reports/P0_GATE_01.md` | Y | Y | Y (17) | Y — job 421 / `p0gate01-run` in frontmatter `validation:` | stated (`:228`) | Y | Expected-to-fail job honestly logged |
| 36 | Docs / synthesis | `reports/FINAL_GATE_PLAN_01.md` | Y | Y | Y (168) | N/A — plan only | Y | Y | `:60` flags TERRAIN-DARK-FIX has no landed report |
| 37 | Docs / synthesis | `reports/ATLAS_01_transport.md` | Y | Y | Y (17) | **N** — ~17 static PASS rows (`:72-88`) have no job id; frontmatter says `NO_RUNNER_JOB` | Y (`:7,220`) | Y (`:204`) | Static hash checks are labelled as such in prose, not per-row (MEDIUM-2) |
| 38 | Docs / synthesis | `reports/SP_04_winter_atlas.md` | Y | Y | Y (8) | **N** — 12 static tool PASS rows (`:121-139`), no runner job by design | Y (`:7`) | **N** | Add "static PASS (no runner job)" prefix; add open questions |
| 39 | Docs / synthesis | `reports/QA_WINTER_01.md` | Y | Y | Y | N — 14 hash PASS rows, no runner job by design | Y (`:151`) | Y (`:137`) | Second-agent verification of SP-04 artifacts |
| 40 | Video / QA | `reports/VID_CAP_01_capture.md` | Y | Y | Y (31) | Y — job 408 / `vidcap01-frames` (`:14`) | stated | Y | 16 distinct frames, no analysis claim |
| 41 | Video / QA | `reports/VID_AN_01_motion_analysis.md` | Y | Y | Y (3 frame paths) | **N** — PASS rows `:109-110` lack the upstream job id 408 (`NO_RUNNER_JOB` in `:7`) | Y (`:8`) | Y (`:155`) | NICHE: verdict rows should cite the source capture job |
| 42 | Re-verification / fix | `reports/S1_INPUT_FIX.md` | Y | Y | Y (23) | Y — job 414 / `s1inputfix-run2` (`:12,156`) | Y | Y | PASS 23/23 is atom-scoped, not ladder PASS |
| 43 | Docs / synthesis | `reports/README_UPDATE_01.md` | Y | Y | Y | N/A | Y (`:7`) | Y | Late README refresh; "99 on disk" count already stale at 11:07 |

**Summary of sample:** frontmatter and evidence citations are near-universal (43/43 sampled; 99/99 in the full automated scan). The recurring weaknesses are **evidence-label vocabulary in 5–6 implementation/QA reports**, **static PASS rows without a job id or "no runner job" tag on the row**, and **missing open-questions sections in 3 reports**. Donor claims are consistently cited with `path:line`/`path:0xoffset` or evidence ids; no donor claim in the sample was found floating uncited.

## 3. Contradiction table (living docs)

Each row gives the stale/contradictory text, the authoritative source and severity. Line numbers refer to the file state at the 11:07:45 snapshot (the swarm was still editing).

| # | File:line — inconsistent text | Authoritative source | Severity |
|---:|---|---|---|
| C1 | `PROGRESS.md:184` heading "Gates status (**LIVE — supersedes the earlier snapshot**)" and `:188` "29/29 repeatedly" | `README.md:141-144` calls this table explicitly contradicted; `reports/QA_AUDIT_01_implementation_claims.md:47-57` measures 26/29 HEAD / 28/29 worktree; `reports/DEFAULTS_VERIFY_01.md:92` | **BLOCKER** |
| C2 | `SWARM_BOARD.md:88` CFG-01 RUNNING, while `:64` CFG-01 **DONE**, same session id `ses_dee421bccffeq8fPJi27IKDgF1` | `:64` + `reports/CFG_01_skirmish_defaults.md` + `README.md:55-62` | **BLOCKER** |
| C3 | `SWARM_BOARD.md:187` LIGHT-02 RUNNING, while `:119` LIGHT-02 **DONE**, same session id `ses_dedec4470ffeHwtSyDtjqStFu4` | `:119` + `reports/LIGHT_02_light_space.md` | **BLOCKER** |
| C4 | `SWARM_BOARD.md:220` CONFIG-DOC-01 RUNNING, while `:223` same ticket/session/output **DONE** | `:223` + `CONFIG_PIPELINE.md` on disk | **BLOCKER** |
| C5 | `SWARM_BOARD.md:98` TEST-RUN-02 RESERVED (`TEST_RUN_02_selection_log.md`, file absent) vs `:155` TEST-RUN-02 **DONE — STOPPED AT P0** | `reports/TEST_RUN_02_ladder_log.md` + `:155`; one ticket id used for two distinct scopes | MEDIUM |
| C6 | `SWARM_BOARD.md` marks 12 tickets RUNNING although their report is on disk: `:117` MOTION-ANIM-01, `:147` SEASON-PLAN-01, `:174` SP-4, `:175` SP-6, `:184` CONFIG-UI-01, `:186` TERRAIN-DARK-FIX (report landed 11:1x), `:188` CONFIG-WIRE-SEL, `:217` AUDIO-SEL-02, `:219` WEATHER-DRIVER-01, `:227` README-UPDATE-01 (plus C2–C4 duplicates) | each report's frontmatter status (e.g. `SP_06_renderer_hook.md:4` DELIVERED, `README_UPDATE_01.md:5` DELIVERED, `MOTION_ANIM_01.md` LANDED) and shell file-existence check | **BLOCKER** (board is declared "freshest per-ticket status" at `README.md:121-123`) |
| C7 | `README.md:203` "Late-wave RUNNING tickets" still lists `SEASON-PLAN-01`, `SP-1`, `SP-4`, `AUDIO-SEL-02` although reports landed | `reports/SEASON_PLAN_01.md`, `reports/SP_01_season_enum.md`, `reports/SP_04_winter_atlas.md`, `reports/AUDIO_SEL_02.md` frontmatter; `SWARM_BOARD.md:233` QA-WINTER-01 DONE for SP-4 artifacts | MEDIUM |
| C8 | `README.md:168` "**99 on disk** at this snapshot" | shell enumeration: 103 reports at 11:07:45 (and still rising); `README_UPDATE_01.md` is now present, so that part of the sentence is current | MEDIUM |
| C9 | `CORRECTIONS.md:15-19` "Duplicated corrections … are merged into a single row" and `README.md:186` "duplicate chains merged" | `CORRECTIONS.md:60` (row 14) and `:98` (row 51) repeat the frame-0 bind-pose correction; `:74` (row 28) and `:99` (row 52) repeat FogMode/sky labels — 57 rows include both pairs | **BLOCKER** for the canonical-index rule (`CORRECTIONS.md:135-142`: cite one authority row) |
| C10 | `GAPS.md:23` "Automated coverage: **NONE** … new `t_drag_rect3d.gd`" | `reports/S1_INPUT_FIX.md:153-176` — job 414, PASS 23/23 windowed real input; `SWARM_BOARD.md:148` TEST-S1 authored | MEDIUM |
| C11 | `GAPS.md:25` "port minimap 200 px bottom-left; `camera3d.gd:354` comment contradicts `:435-436`" | `SWARM_BOARD.md:113-114` HUD-01/UITEST-ANCHOR DONE, bottom-**right** 240×240, uitest 17/17 job 440; `README.md:260-262` | MEDIUM |
| C12 | `GAPS.md:35` says TERRAIN-DARK-FIX applied the axis-correct mapping while `SWARM_BOARD.md:186` still marks it RUNNING | `reports/TERRAIN_DARK_FIX.md:5,13-15` (landed 11:1x: status DELIVERED, smoke 436, P0 job 441) and job-441 metrics at `:140-148`; `reports/FINAL_GATE_PLAN_01.md:60` was authoritative before that landing | MEDIUM |
| C13 | `GAPS.md:6` frontmatter `status: draft — awaiting Batch A / A-decomp` | `SWARM_BOARD.md:18-44` all Batch A/A-decomp DONE; `README.md:47` decomp lane CLOSED | NICHE |
| C14 | `PROGRESS.md:193` "TEST-RUN-02 restarted" (implies a run is pending) | `SWARM_BOARD.md:155` DONE — STOPPED AT P0; `reports/TEST_RUN_02_ladder_log.md` job 404 | MEDIUM |
| C15 | `PROGRESS.md:144` "Donor truth still pending (`DSEL-01/02`, `DEC-07`)" | `SWARM_BOARD.md:18-19,43` all DONE; `CORRECTIONS.md:52-55` arbitrated | NICHE |
| C16 | `VIDEO_QA_PROTOCOL.md:54-56` "Current queue — VID-CAP-01 … (reserved)" | `SWARM_BOARD.md:115-116` both DONE; `README.md:144-145` already flags the queue stale | MEDIUM |
| C17 | `README.md:137` "Every living doc has frontmatter `updated: 2026-11-25` with **no clock time**" | `README.md:9` itself carries `snapshot: "… ~11:00 local"` (a clock time) | NICHE |
| C18 | `README.md:10` authority chain ends "`… → SWARM_BOARD.md → PROGRESS.md`" while `:141-144` says the PROGRESS gate table is contradicted | internal to `README.md`; QA-AUDIT findings at `reports/QA_AUDIT_01_implementation_claims.md:47-57` | NICHE |
| C19 | `SWARM_BOARD.md` table shape: Batch B/I/M headers have 5 columns but rows have 6 cells (e.g. `:54-58`, `:133-146`, `:182-193`); `:121` AUDIO-SEL-01 has 7 cells for a 6-column header; `:193` DENV-01 has a trailing extra cell | the header rows themselves (`SWARM_BOARD.md:52,131,180,106`) | NICHE |
| C20 | `SWARM_BOARD.md:238` QA-DOCS-01 RUNNING with report path absent | this report, `reports/QA_DOCS_01.md`, once landed — COORD should flip the State column (COORD-only per `SWARM_BOARD.md:11`) | Expected, self-resolving |
| C21 | `README.md:192` still says P0 "NOT PASS" with `mean_luma=13.271 / max_luma=27.413` (job 421) even though a fresh P0 gate job passed both replacement gates | `reports/TERRAIN_DARK_FIX.md:140-148` — job 441, `mean_luma=98.680`, `max_luma=172.139`, both `ground_*` gates PASS, atom PASS 22/22 evaluated (1 skipped). The P0 **ladder row** still has no green rerun, so README's caution about the ladder is right but its gate numbers are stale | MEDIUM |

**Observed during the audit (not an error):** `README.md` and `SWARM_BOARD.md` were edited mid-audit (11:05–11:08) and several earlier inconsistencies were fixed — the old README snapshot's "50 corrections", "TEST-RUN-02 RUNNING", "TRN-DATA RUNNING" and "53 reports" claims are gone. **Inferred:** a single-point-in-time audit of a live board cannot be authoritative for more than a few minutes; C2–C6 should be re-checked at read time.

## 4. Ranked issues and recommended owners

### BLOCKER

| ID | Issue | Recommended owner / ticket |
|---|---|---|
| B1 | `PROGRESS.md` gate table labelled LIVE while its 29/29 conflicts with the integrated 26/29 HEAD / 28/29 worktree (C1). A cold reader could authorize the reserved FINAL gate on a false green. | COORD + `DOC-03`/`README-UPDATE-02` — ticket "reconcile PROGRESS gate table; mark stale or replace with QA-AUDIT numbers" |
| B2 | `SWARM_BOARD.md` State column contradicts itself (CFG-01, LIGHT-02, CONFIG-DOC-01) and marks 12 tickets RUNNING with reports on disk (C2–C6); duplicate TEST-RUN-02 ID with different scopes (C5). Board is declared freshest source. | COORD only (owns State column per `SWARM_BOARD.md:11`) — ticket "board state reconciliation + unique ticket ids" |
| B3 | Canonical `CORRECTIONS.md` promises merged duplicate chains but rows 14/51 and 28/52 duplicate them (C9); the "cite one authority row" rule is broken and the 57-row count double-counts. | `DOC-02` + COORD — ticket "merge or cross-link duplicate correction rows; restate count" |

### MEDIUM

| ID | Issue | Recommended owner / ticket |
|---|---|---|
| M1 | Evidence-label vocabulary missing in `DECOR_01:7`, `CONFIG_WIRE_SEL:13`, `ASSET_IMPORT_01:1-13`, `CFG_02:1-6`, `CLEAN_02:1-7`, `HARNESS_01:1-11`; `QA_AUDIT_01:9` uses a different scale. Conflicts with binding rule `README.md:227-228`. | Each owning worker via COORD — ticket "backfill evidence labels in 7 reports" |
| M2 | Static PASS rows without a job id or per-row "no runner job" tag: `ATLAS_01_transport.md:72-88`, `SP_04_winter_atlas.md:121-139`, `QA_WINTER_01.md:77-90`, `VID_AN_01_motion_analysis.md:109-110` (upstream job 408 not on the verdict row). | ATLAS/SP-4/QA-WINTER/VID-AN owners — ticket "label static PASS rows and cite upstream job ids" |
| M3 | `GAPS.md` stale selection/minimap/dark-frame rows (C10–C12), stale frontmatter status (C13), and `README.md:192` P0 gate numbers stale after job 441 (C21). | COORD / GAPS maintainer + `README-UPDATE-02` — ticket "refresh GAPS §1–§2 and README P0 gate row from landed reports" |
| M4 | `VIDEO_QA_PROTOCOL.md:54-56` queue still says reserved (C16). | Video protocol owner — ticket "close VID-CAP/VID-AN queue entries" |
| M5 | `README.md:168` hard-coded "99 on disk", `:203` stale RUNNING list (C7–C8). | `README-UPDATE-02` — ticket "timestamp counts; derive count at read time" |
| M6 | `PROGRESS.md:193` "TEST-RUN-02 restarted" contradicts its own stop evidence (C14). | COORD — ticket "correct ladder-status sentence" |

### NICHE

| ID | Issue | Recommended owner / ticket |
|---|---|---|
| N1 | No explicit open-questions section in `SP_04_winter_atlas.md`, `CLEAN_01_variant_clean.md`, `CFG_02_no_menu_defaults.md` (and `decomp/EVIDENCE_INDEX.md`, where it is reasonable for an index). | Report owners — "add Open questions or `None` heading" |
| N2 | Malformed board tables (C19) — cold readers may misalign State and Evidence cells. | COORD — "normalise table column counts" |
| N3 | `README.md:137` "no clock time" self-contradiction (C17); `:10` authority chain terminates at a doc it flags as contradicted (C18). | `README-UPDATE-02` — "snapshot caveat + authority wording" |
| N4 | `SWARM_BOARD.md:38-39` DEC-02/DEC-03 "REPORT DELIVERED (agent finalizing)" while the lane is CLOSED at `:46`. | COORD — "close DEC-02/03 rows" |
| N5 | `PROGRESS.md:144` still calls DSEL/DEC-07 donor truth "pending" (C15). | COORD — "update key-synthesis paragraph" |

No issue above was fixed by this worker.

## 5. Open questions (this audit)

1. Should "static PASS" rows (hash/manifest/self-check) count as PASS claims under the `README.md:203-205` honesty rule, or is an explicit exemption with a per-row "no runner job" tag acceptable? **UNVERIFIED** — no written policy found.
2. Should CORRECTIONS rows 14/51 and 28/52 be merged (changing the 57-row headline) or retained as a visible reversal chain with explicit "see row N" cross-links? The index currently does neither.
3. Which snapshot is canonical for living-doc counts: start-of-audit 120/2,842,965 or 11:07:45 127/2,991,215? Most docs stamp only a date, so a count cannot be validated later. **inferred:** add a clock time to every count.
4. Is `GAPS.md` still a live "draft — awaiting Batch A", or has it been overtaken by `CORRECTIONS.md`/`README.md`? Its stale rows (C10–C13) suggest the latter, but ownership is not recorded.
5. Will COORD flip `SWARM_BOARD.md:238` QA-DOCS-01 to DONE when this report lands? Until then the board will show one more RUNNING row with a report on disk — exactly the C6 pattern.

## 6. Summary

- **Evidence discipline inside reports is strong.** All 99 full-scan reports (plus 4 later arrivals checked individually) have frontmatter, evidence citations and explicit scope/label language; donor claims cite `path:line`/`path:0xoffset`/evidence ids; runner PASS claims name job ids (`P0_GATE_01` job 421, `S1_INPUT_FIX` job 414, `VID_CAP_01` job 408, `SEL_01` jobs 329/337/318). This is **observed**.
- **The failures are in state propagation, not in report internals.** The three BLOCKERs are all living-doc governance: a LIVE gate table contradicted by audit artifacts, a board State column that contradicts itself and reality, and a canonical corrections index that violates its own uniqueness rule. **derived** from C1–C9.
- **Cold-read risk:** a reader following `README.md:10`'s authority chain ends at the one gate table the README itself says is stale, and a reader trusting `SWARM_BOARD.md`'s State column will find at least 12 RUNNING tickets with delivered reports. **inferred**.
- **Not verified:** no job was re-run, no donor file was read, no code/config/test/asset was changed, and no living doc was edited — this is a read-only audit with one output file.

**File-edit statement:** no file other than `docs/coord_swarm_2026-11-25/reports/QA_DOCS_01.md` was edited, created or deleted by this worker. No runner job was submitted; no code, config, test, asset, git or queue state was touched.
