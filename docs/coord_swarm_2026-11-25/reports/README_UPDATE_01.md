---
id: README-UPDATE-01
title: "README refresh after the late-wave findings — sections changed and sources"
date: 2026-11-25
owner: README-UPDATE-01 (documentation micro-worker)
status: DELIVERED__DOC_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Exactly two files touched: docs/coord_swarm_2026-11-25/README.md (targeted edits) and this report. No code, config, test, asset, backup, git or runner state was changed."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION, snapshot]
source_convention: "Paths are relative to docs/coord_swarm_2026-11-25/ unless prefixed. All citations are to the file:line values read at this snapshot."
---

# README-UPDATE-01 — late-wave README refresh

## 1. Task and discipline

Refresh the swarm README with the findings that landed after DOC-03 authored it, using
targeted section edits rather than a whole-file rewrite. Read set per task:
`README.md`, `PROGRESS.md` (including the OWNER RUNTIME REPORT), `SWARM_BOARD.md`,
`GAPS.md`, `CORRECTIONS.md`, `CONFIG_PIPELINE.md`, `VIDEO_QA_PROTOCOL.md`,
`decomp/SUMMARY.md`, and a full listing of `reports/`. Additional reports were opened
only to source the new claims (listed in §3). No donor binary was executed or copied;
no gate was run; no visual-parity claim is made by this report.

## 2. Sections changed in `README.md`

| Section | Change | Why |
|---|---|---|
| Frontmatter | Added `refreshed_by: README-UPDATE-01` + `snapshot:` line; kept DOC-03 as `author` and `status: living`. | Preserve authorship and label the new read time (`README.md:1-13`). |
| §0 TL;DR | Updated the stale `TRN-DATA` "still RUNNING" claim to DONE (`SWARM_BOARD.md:111`); corrected the corrections-index count to **57**; rewrote the "all atoms authored, not passed" claim into measured results (P0 stops at jobs 321/404, S1 23/23, CAM-RV-01 20/20, integrated selftest 26/29 HEAD / 28/29 worktree). | Task asked to replace "not yet run" claims that have since been measured (`README.md:37-69`). |
| §0 TL;DR — 6 new bullets | Added: OWNER runtime errors + owner-assigned fixes; P0 dark-terrain root cause and replacement gate; muse-spark motion findings and routed fixes; config pipeline status; winter atlas + LFS plan; donor map-size mismatch. Each bullet carries a report path and/or `file:line`. | Late-wave coverage required by the task; kept brief and cold-readable (`README.md:70-113`). |
| §1 resume order | Corrected 50→57 rows; added `CONFIG_PIPELINE.md` as step 6; added `decomp/SUMMARY.md` pointer; expanded the snapshot caveat to flag three stale sources: `PROGRESS.md:188` vs QA-AUDIT-01, `VIDEO_QA_PROTOCOL.md:54-56` queue, and board-stale CONFIG tickets. | A cold reader must not trust superseded snapshots (`README.md:115-148`). |
| §2 folder map | Added `CONFIG_PIPELINE.md`; corrected rows/state labels; report count 53→99 on disk (including this report). | Folder map was missing the config status doc (`README.md:150-168`). |
| §3 gate tables | Green table: qualified per-job 29/29; CLEAN honest NOT-CLEAN verdict; added S1 23/23, VID-CAP 10/10, atlas structural checks, FX smoke, 440 uitest. Pending table: rewrote P0, S1, integrated selftest, CFG-02/MAP-SMALL-01, TRN-DATA, owner errors, config pipeline, winter/LFS, running tickets. Strengthened the honesty guard: atom PASS ≠ whole-system PASS. | `README.md:170-209`. |
| §5 failure register | Added four guards: no "globally configurable" claim without a `features` JSON section; parse-only smokes ≠ runtime proof; no Winter-art claim while path constants disagree; do not revert the correct light-axis swap. | `README.md:232-245`. |
| §6 pointer index | Corrected the S1 and TEST-RUN-02 entries; added four new topic groups: P0 darkness diagnosis/gate (inside Terrain), Config pipeline, Season/atlas/LFS, Motion/video QA, Map sizes/defaults; added late-wave gate reports under Tests. | `README.md:247-354`. |
| Bottom line | Replaced the "five authority docs / restarted ladder" close with the late-wave prerequisite list: F0 A/B, P0→C4→S1 ladder, integrated 29/29+17/17+CLEAN re-verification, owner-error fixes; kept the final-gate and parity guard verbatim in substance. | `README.md:375-382`. |

## 3. Sources used for each new claim

| Claim in README | Source(s) |
|---|---|
| OWNER runtime errors and owner-assigned fixes | `PROGRESS.md:104-115`; `SWARM_BOARD.md:120,192`; `reports/ASSET_IMPORT_01.md:9,123-141`; `reports/MOTION_ANIM_01.md:191-230` |
| P0 dark root cause, correct axis swap, `SUN_LIGHTVEC` gap | `reports/TERRAIN_DARK_01.md`; `reports/LIGHT_02_light_space.md:212-246,267-275`; `GAPS.md:35,42` |
| Replacement luma gate and job 421 expected failure | `reports/P0_GATE_01.md:124-174,176-224`; `reports/METRIC_01_dark_rows.md`; `reports/PIXEL_01_p0_capture_review.md` |
| Muse-spark motion verdicts and routed fixes | `VIDEO_QA_PROTOCOL.md:11-15,30-52`; `reports/VID_CAP_01_capture.md`; `reports/VID_AN_01_motion_analysis.md:101-125,127-153`; `reports/MOTION_ANIM_01.md:20-35,107-147,191-230`; `SWARM_BOARD.md:115-117` |
| 56→57 correction rows | `CORRECTIONS.md:100-105,107-129,159-170` (row 57 added by DEFAULTS-VERIFY-01; see §4) |
| 21 getters / 7 WIRED / 2 READER_ONLY / 2 UI_ONLY / 10 PENDING; 34 headline vs 39+4 rows; Snow PORT-UI-ONLY; no `features` in JSON; parse-only smokes | `CONFIG_PIPELINE.md:63-104,118-129,211-230,278-315,319-338`; `reports/QA_CONFIG_01_getters.md`; `reports/CONFIG_CORE_01.md`; `reports/CONFIG_UI_01.md` |
| Winter atlas build (124,463,306 B, 16/16 + 8/8), LFS option (a), path mismatch, silent Summer fallback, no git action | `reports/SP_04_winter_atlas.md:101-144,146-166,171-185,203-208`; `reports/LFS_PLAN_01.md:152-190`; `reports/ATLAS_01_transport.md:158-193`; `SWARM_BOARD.md:169-176` |
| Donor map sizes 256/320/480/640 vs port 240/320/400/480; defaults resolve; raw `land` trap | `reports/DMAPGEN_01_skirmish_options.md:59-75,212-270`; `reports/DEFAULTS_VERIFY_01.md:89-118`; `SWARM_BOARD.md:224` |
| S1 23/23, CAM-RV-01 20/20, integrated selftest not green, final-gate plan | `reports/S1_INPUT_FIX.md:141-206`; `reports/CAM_RV_01_view_rect_runtime.md:179-197`; `reports/QA_AUDIT_01_implementation_claims.md:45-119`; `reports/DEFAULTS_VERIFY_01.md:92`; `reports/FINAL_GATE_PLAN_01.md:53-105`; `reports/CLEAN_01_variant_clean.md`; `reports/CLEAN_02_variant_gate.md`; `SWARM_BOARD.md:154-157` |
| Decomp lane closed / consolidated record | `decomp/SUMMARY.md:1-15,184-214`; `decomp/README.md`; `decomp/EVIDENCE_INDEX.md` |

## 4. Discrepancies found and how they were handled

1. **Corrections index count.** The task brief named a "56-row" index; the file itself
   has **57** numbered rows (`CORRECTIONS.md:100-105`) and its own summary says
   "57 indexed corrections" (`:159-170`). Row 57 (DEFAULTS-VERIFY-01 refuting the
   CFG-02 / QA F-05 refutation) landed later. The README now reports 57 and notes the
   DOC-03 base was 50; no report or correction row was edited.
2. **`PROGRESS.md` gate table conflict.** `:188` claims "29/29 repeatedly" while
   `reports/QA_AUDIT_01_implementation_claims.md:47-57` measures 26/29 at HEAD and 28/29
   in the worktree. The README cites the measured artifact and labels the per-job 29/29
   as job-scoped; `PROGRESS.md` was not edited (not owned by this task).
3. **Board staleness.** `SWARM_BOARD.md` still marks CONFIG-UI-01/CONFIG-WIRE-SEL,
   MOTION-ANIM-01 and FINAL-GATE-PLAN-01 RUNNING although reports have landed;
   `CONFIG_PIPELINE.md:213-214,308-311` records the same conflict. The README flags
   these rather than changing the State column (COORD-only).
4. **Protocol staleness.** `VIDEO_QA_PROTOCOL.md:54-56` still lists VID-CAP-01 and
   VID-AN-01 as a queue; both are DONE. The README marks the queue stale; the protocol
   file was not edited (not owned by this task).
5. **Missing vs newly landed reports.** Disk listing was checked twice: `MINIMAP-QUAD-01`,
   `TERRAIN-DARK-FIX`, `MAPSIZE-01` and `QA-PARITY-01` have **no report on disk**;
   `ASSET_IMPORT_01.md`, `FINAL_GATE_PLAN_01.md` and the updated `MOTION_ANIM_01.md`
   landed during the read (10:56–10:59). The README cites only paths that exist, or
   explicitly says "RUNNING with no report on disk"; no non-existent path is presented
   as evidence.
6. **Report count / moving target.** 98 Markdown reports were on disk at the first
   listing; this report made 99, and further tickets landed during the edit (104 at final
   check). The README folder map is labelled "99 at this README edit" with an explicit
   drift warning. Newly landed `SP-06`, `WEATHER-DRIVER-01`, `AUDIO-SEL-02`, `QA-WINTER-01`
   and `GDIGNORE-01` reports are noted in the README's post-snapshot paragraph; none is
   promoted to PASS, because their own frontmatter says no gates / pending smoke or
   validation / audit-only.

## 5. Honesty guard preserved

- Reports authored ≠ tests passed. Atom-level PASS values (S1 23/23, CAM-RV-01 20/20,
  VID-CAP 10/10, atlas 16/16) are labelled as scoped to their own scenario/build check.
- Donor visual parity remains **UNVERIFIED** everywhere; no donor GPU A/B exists
  (`CORRECTIONS.md:122`); motion smoothness is never treated as donor faithfulness.
- The final whole-system gate has **not** been run; the ordered prerequisites are cited
  to `reports/FINAL_GATE_PLAN_01.md:53-105` and remain COORD-only.
- PORT APPROXIMATION labels are preserved for FOV 17.27°, world-XZ texgen, `/4,/2` light
  compression, replacement luma thresholds, yaw clamp and Winter atlas packing.

---

*End of README-UPDATE-01. Two documentation files only; no code edit, no runner job, no
git operation, no donor access. The refreshed `README.md` is the main output.*
