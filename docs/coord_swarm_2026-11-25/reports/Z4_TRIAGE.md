# Z4-TRIAGE — RUNNING-row disposition (read-only)

owner: Z4-BOARD-TRIAGE (read-only; no code/edit/runner/git/board-State edits)
scope: one file only — `docs/coord_swarm_2026-11-25/reports/Z4_TRIAGE.md`
labels: observed = read verbatim; derived = consequence; inferred = best reading + caveat; UNVERIFIED = no proof
method: board `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:1-466` (observed) vs
reports-dir listing `docs/coord_swarm_2026-11-25/reports/` (observed, 251 entries this pass) +
`git diff --stat HEAD -- variant3d` → empty + `git status --porcelain` → empty (observed, this pass) +
`docs/coord_swarm_2026-11-25/PROGRESS.md:104-121` + `docs/coord_swarm_2026-11-25/FINAL_CHECKLIST.md:482-515` +
`docs/coord_swarm_2026-11-25/reports/FINAL_AUDIT_01.md:19-22,235-252`

> Governance (observed): State column is COORD-only (`SWARM_BOARD.md:11,122`); sessions not verified
> BUSY in a fresh DB query are TERMINATED (`SWARM_BOARD.md:23-33`); batch H/S-25-12 targeted smoke only,
> full gates COORD-only last (`PROGRESS.md:224` = S-25-12).

## A. RUNNING-row disposition (COORD to apply State)

`git diff/stat` empty (observed) ⇒ **zero** rows qualify as IN-FLIGHT-UNVERIFIED (c): no owned-file
diff vs HEAD exists to conflict. Every row below is therefore (a) report-landed → propose DONE, or
(b) no exact-filename report → propose TERMINATED-ABANDONED (safe to re-dispatch).
Mtime/verdict-line re-checks are UNVERIFIED (this worker did not stat each report; board carries no per-row verdict line).

| Board row (State RUNNING, observed) | Promised report (observed board text) | On-disk match (observed listing) | Proposed State + one-line evidence |
|---|---|---|---|
| MAP-SMALL-01 `SWARM_BOARD.md:87` | `reports/MAP_SMALL_01_report.md` | `reports/MAP_SMALL_01_report.md` PRESENT | **DONE (REVERTED)** — `FINAL_CHECKLIST.md:104-113` records landed + both files restored (derived) |
| MINIMAP-QUAD-01 `SWARM_BOARD.md:141` | `reports/MINIMAP_QUAD_01.md` | `MINIMAP_QUAD_01.md` PRESENT | **DONE** — report landed; parse-error fix ownership was this row (`PROGRESS.md:144-155`, observed) |
| MOTION-ANIM-01 `SWARM_BOARD.md:138` REPORT DELIVERED | `reports/MOTION_ANIM_01.md` | PRESENT | **DONE** — rotor-texture fallback + rotation check routed here (`PROGRESS.md:144-155`, observed) |
| TERRAIN-DARK-FIX `SWARM_BOARD.md:207` REPORT DELIVERED | `reports/TERRAIN_DARK_FIX.md` | PRESENT | **DONE** — job 441 P0 PASS cited at `FINAL_CHECKLIST.md:307` (observed) |
| SP-6 `SWARM_BOARD.md:196` REPORT DELIVERED | `reports/SP_06_renderer_hook.md` | `SP_06_renderer_hook.md` PRESENT | **DONE** — sun-hook + smoke queued note (observed board text) |
| Batch S (19 rows) `SWARM_BOARD.md:235-258` | scope-only, no Output col (observed) | see note | **DONE where file matches; else TERMINATED-ABANDONED** — detail below |
| RECHECK-P0-01 `:238`, RECHECK-S1-01 `:239` | second-agent re-checks | `RECHECK_P0.md`, `RECHECK_S1.md`, `RECHECK_P0_FINAL.md` PRESENT | **DONE** — 3 files confirm `FINAL_CHECKLIST.md:327-337`; P0 CONFIRMED_PASS (`FINAL_AUDIT_01.md:43`, E7) |
| QA-BOARDLIVE-01 `:241` | live-session list | `QA_BOARDLIVE_01.md` PRESENT | **DONE** — snapshot method at `SWARM_BOARD.md:14-27` (observed) |
| QA-LINKS-02 `:242` | LINKS missing/stale re-check | NO `LINKS_02*` in listing (observed) | **TERMINATED-ABANDONED** — safe re-dispatch; `LINKS_01.md` only |
| DBUILD-02 `:243`, DONAVAL-02 `:245` | donor verification | `DBUILD_02.md`, `DONAVAL_02.md` PRESENT | **DONE** — both files present (observed) |
| QA-ATOM-STALE-02 `:246` | stale result JSONs | `QA_ATOM_STALE_02.md` PRESENT | **DONE** (observed) |
| BUILD-STAGES-01 `:247` | construction stages | `BUILD_STAGES_01.md` PRESENT | **DONE** — board Batch T `:264` already marks DONE/stage logic smoke 503 (observed) |
| FIELD-WINTER-01 `:248` | winter decal module | `FIELD_WINTER_01.md` PRESENT | **DONE** (observed) |
| MORALE-PLAN-01 `:249` | remove invented morale | `MORALE_PLAN_01.md` PRESENT | **DONE** (observed) |
| FINAL-CHECKLIST-01 `:250` | sign-off checklist | `FINAL_CHECKLIST.md` PRESENT (top-level, not `reports/`) | **DONE** — 34/12/16 counters (`FINAL_CHECKLIST.md:495`, observed) |
| QA-CLEAN-02 `:251` | variant CLEAN re-check | `QA_CLEAN_02.md` PRESENT | **DONE** (observed) |
| DENV-02 `:252`, DANIM-02 `:253` | FogMode/sky; AAF/frame-0 | `DENV_02.md`, `DANIM_02.md` PRESENT | **DONE** — DANIM-02 also closed at Batch O `:401` 335/335 (observed) |
| QA-DOCLIVE-01 `:254` | living docs | NO `*DOCLIVE*` in listing (observed) | **TERMINATED-ABANDONED** — safe re-dispatch |
| GATE-FAIL-01 `:255` | banner-only startup diag | `GATE_FAIL_01.md` PRESENT | **DONE** (observed) |
| README-FINAL-01 `:256`, SESSION-STATUS-FINAL-01 `:258` | README; live count | `README_FINAL_01.md`, `SESSION_STATUS_FINAL_01.md` PRESENT | **DONE** (observed) |
| Batch T RUNNING `SWARM_BOARD.md:259-289` | mixed | mostly PRESENT | **DONE except 2 ABANDONED** — see sub-rows |
| LOAD-ASYNC-01 `:271` | non-blocking load `main.gd` | `LOAD_ASYNC_01.md` PRESENT | **DONE** — landing unverified visually; needs QA ticket (see §B) |
| HUD-LAYOUT-01 `:272` | `t_hud_layout.gd` atom | `HUD_LAYOUT_01.md` PRESENT | **DONE (authoring)** — run result is separate row (observed) |
| QA-FINAL-02 `:275`, UITOP-DONOR-01 `:276` | audit checklist; donor speed truth | `QA_FINAL_02.md`, `UITOP_DONOR_01.md` PRESENT | **DONE** (observed) |
| P3-RESULT-CLEAN-01 `:278` | quarantine false-green P3 JSON | `P3_RESULT_CLEAN_01.md` PRESENT | **DONE** (observed) |
| FAULT-DOC-01 `:279` | owner-fault index, no filename given | NO `FAULT_DOC*` in listing (observed) | **TERMINATED-ABANDONED** — superseded by `OWNER_FAULTS_UPDATE_01/02.md` PRESENT (derived) |
| MORALE-02 `:280`, RUNNER-FIX-01 `:281` | morale labels; runner patch | `MORALE_02.md`, `RUNNER_FIX_01.md` PRESENT | **DONE** — patch APPLIED per `PROGRESS.md:123-131` (observed) |
| BUILD-ART-01 `:283`, SEASON-DESERT-01 `:284` | stage OBJs; desert re-baseline | `BUILD_ART_01.md`, `SEASON_DESERT_01.md` PRESENT | **DONE** (observed) |
| CLEAN-ACK-PLAN-01 `:287`, BUILD-STEP-FIX-01 `:288` | ack cmds; `build` step | `CLEAN_ACK_PLAN_01.md`, `BUILD_STEP_FIX_01.md` PRESENT | **DONE** — CLEAN exit 0 signed (`PROGRESS.md:111-116`) |
| Batch U `SWARM_BOARD.md:290-300` | owner faults | ALL PRESENT | **DONE (diagnosis/model), fix PARTIAL** — `TERRAIN_MARKS_01.md`, `NATION_FLOW_01.md`, `NATION_MODEL_01.md`, `BUILD_ANIM_DIAG_01.md`, `BUILD_ANIM_01.md` PRESENT (observed); NATION-DONOR-01 already DONE-TERMINATED `:295` |
| Batch V RUNNING `SWARM_BOARD.md:301-317` | verification/planning | ALL PRESENT | **DONE** — `QA_PATCH_VERIFY_01.md`, `QA_GATE_READY_02.md`, `NATION_DATA_01.md`, `NATION_SPAWN_01.md`, `NAVAL_NATION_01.md`, `QA_UI_FIXES_01.md`, `QA_RELIEF_ON_01.md`, `QA_LADDER_01.md`, `BUILD_ART_BATCH_01.md`, `README_COUNT_01.md` PRESENT (observed) |
| Batch X RUNNING `SWARM_BOARD.md:319-336` | impl/runtime checks | ALL PRESENT | **DONE (report-level)** — `NATION_SPAWN_IMPL_01.md`, `HUD_LAYOUT_RUN_01.md`, `LOAD_PROBE_RUN_01.md`, `RELIEF_VISUAL_01.md`, `QA_DESERT_FIX_01.md`, `BUILD_STAGE_INTEGRATION_01.md`, `QA_SPEED_01.md`, `STAGE_IMPORT_01.md`, `NATION_DATA_IMPL_01.md`, `RELIEF_LIVE_DIAG_01.md`, `QA_CONFIG_RESTORE_01.md`/`CONFIG_RESTORE_01.md` PRESENT (observed); runtime PASS claims stay UNVERIFIED per `FINAL_AUDIT_01.md:143-156` |
| Batch Y RUNNING `SWARM_BOARD.md:338-354` | targeted verify | ALL PRESENT | **DONE (report-level)** — `QA_RELIEF_LIVE_01.md`, `QA_NATION_IMPL_01.md`, `QA_CONFIG_JSON_02.md`, `QA_SPEED_ALIGN_01.md`, `OWNER_FAULTS_UPDATE_01/02.md`, `HUD_LAYOUT_REPAIR_01.md`, `LOAD_PROBE_REPAIR_01.md`, `FINAL_CHECK_REFRESH_02.md`, `WHITE_MARKS_PIX_01.md`, `QA_WHITE_MARKS_01.md` PRESENT (observed) |
| Batch W RUNNING `SWARM_BOARD.md:355-364` | asset/fault verify | ALL PRESENT | **DONE (report-level)** — `DESERT_CONSUMER_FIX_01.md`, `QA_BUILD_ART_01.md`, `QA_SKIN_REGEN_01.md`, `SESSION_COUNT_05.md` PRESENT (observed); QA-RELIEF-DUMP-01 already DONE-TERMINATED/RUNTIME UNVERIFIED `:361` |
| LINKS-01 `SWARM_BOARD.md:372` RUNNING | `reports/LINKS_01.md` | PRESENT | **DONE** — file exists (observed); board State stale (derived) |
| Batch O RUNNING `SWARM_BOARD.md:375-409` | small tickets | ALL PRESENT | **DONE (report-level)** — `AUDIO_SEL_02.md`, `CONFIG_WIRE_RELIEF.md`, `WEATHER_DRIVER_01.md`, `QA_PARITY_01.md`, `DARKROW_ALL_01.md`, `SEASON_TEST_PATH_01.md`, `DESERT_REMAP_02.md`, `PW_VERIFY_01.md`, `SP8_STATUS_01.md`, `QA_ATOM_RESULTS_01.md` PRESENT (observed) |
| Batch AA RUNNING `SWARM_BOARD.md:440-452` | fix verify | ALL PRESENT | **DONE (report-level)** — `QA_RELIEF_FIX_01.md`, `QA_HUD_REPAIR_01.md`, `SELFTEST_ALL_FIX_01.md` PRESENT (observed) |
| Batch Z RUNNING `SWARM_BOARD.md:453-463` | deep dives | ALL PRESENT | **DONE** — `HEIGHT_GEN_DEEP_01.md`, `PATTERN_STAMP_DEEP_01.md`, `RCODE_DEEP_01.md`, `PALE_TILES_DEEP_01.md`, `QA_NATION_MODEL_01.md` PRESENT (observed); RELIEF-LIVE-FIX-01 already DONE-TERMINATED `:461` |

Net (derived): ~60 RUNNING rows have landed reports ⇒ propose DONE; 3 rows (QA-LINKS-02, QA-DOCLIVE-01, FAULT-DOC-01) have no exact-filename match ⇒ TERMINATED-ABANDONED; 0 rows IN-FLIGHT-UNVERIFIED (clean diff/stat, observed). Per-row mtime + verdict-line = UNVERIFIED (not statted here).

## B. Owner-fault status + re-dispatch (disjoint grants, one builder/file-set, backups mandatory)

| # | Owner fault | Current State (observed) | Re-dispatch? (derived) |
|---|---|---|---|
| (i) | mapgen/relief/hills + white marks | PARTIAL: `RELIEF_VISUAL_01.md` reproduced 44,381 near-white px + no hills (`FINAL_CHECKLIST.md:436-449`); `MASK_ALPHA_FIX_01.md` −84.25% frame-wide only (`FINAL_AUDIT_01.md:147-149`); relief cell-CONFIRMED but visual UNVERIFIED (`FINAL_AUDIT_01.md:150-151`); `PALE_TILES_DEEP_01.md` DONE-TERMINATED `:431`; `TERRAIN_MARKS_01.md` landed (§A) | YES — T1 windowed relief A/B (seed 20261150 `plt2` 443 cells, `RELIEF_SEED_PROBE_01.md:147-158` cited in audit E18) + second-agent image read; owner `world3d_terrain.gd` only; backup first |
| (ii) | nation unit/building/ship art (NATION-*) | PARTIAL: `NATION_DONOR_01.md` DONE-TERMINATED `:295` (rus/bav rule); `NATION_DATA_IMPL_01.md` DONE-TERMINATED `:466` (+1 line, mesh proof UNVERIFIED); `NATION_MODEL_01.md` DONE-TERMINATED `:464` (+205/−3, buildings/naval BLOCKED 0 nation-keyed OBJs); NATION-FLOW/SPAWN/DATA reports landed (§A) | YES — T2a `data.gd` NATION_UNITS completion; T2b `world3d_entities.gd` building/naval hookup only after art lands (0/172 OBJs per NATION-DONOR-01 evidence); T2c naval layer ticket (no naval entity layer, `DONAVAL_01.md` DONE `:407`) |
| (iii) | peasant build animation wrong | PARTIAL: `BUILD_ANIM_DIAG_01.md` + `BUILD_ANIM_01.md` landed (§A); `BUILD_SKIN_02.md` DONE-TERMINATED `:317` (construct frames `[186,188,191,193,196,198]`); `BUILD_STAGES_01.md` DONE `:264` smoke 503; `BUILD_ART_C_01.md` DONE-TERMINATED `:465` probe 14/14 | YES — T3 runtime visual A/B of construct branch (`NATION_MODEL_01.md` build→construct branch, observed `:464`); owner `world3d_entities.gd` only if hookup missing |
| (iv) | `hud3d_adapter.gd:172-173` parse + `mill_rotor` .ctex | PARTIAL: owner report at `PROGRESS.md:144-155` (observed); MINIMAP-QUAD-01 report landed (§A) but typed-fix landing UNVERIFIED here; `ASSET_IMPORT_01.md` DONE `:213` yet target ctex still absent (`.gdignore` root cause, observed); MOTION-ANIM-01 REPORT DELIVERED `:138` (rotor fallback) | YES — T4a verify `:172-173` explicit types + smoke; T4b asset relocation out of `.gdignore` (do NOT re-run import alone); disjoint: adapter vs models dir |
| (v) | selection marquee (SEL-01) | **DONE — CONFIRMED, no re-dispatch**: SEL-01 DONE `SWARM_BOARD.md:108` (yellow 1px, ε 0.005m, 29/29 job 337 + 17/17 job 318 + 12/12 probe 329); CAM-RV-01 20/20 `:145`; S1 atom 23/23 job 414 (`FINAL_CHECKLIST.md:315`) | NO — keep closed; S1 ladder row re-run is §C business, not a fix |
| (vi) | top-bar overflow + speed dropdown + loading freeze | PARTIAL: `UI_TOPBAR_01.md` DONE-TERMINATED `:270` (+179/−34, smoke 513) but 17/17 UNVERIFIED (observed); `SPEED_PLAN_01.md` DONE-TERMINATED `:331`; `QA_SPEED_01.md`+`QA_ATOM_RUNS_01.md` evidence §A; `LOAD_ASYNC_01.md` + `LOAD_PROBE_RUN_01.md` landed; probe is MEASUREMENT_ONLY (`FINAL_AUDIT_01.md:154-155`); HUD atom 62/62 structural only (E19) | YES — T5a `hud.gd` top-bar visual A/B at 1024/1280/1920 (62/62 ≠ visual, E19); T5b speed label/factor alignment impl (blocked note at `:331`); T5c `main.gd` async-load usability run with real Start click (UNVERIFIED items a/d/e, E20) |
| (vii) | ladder P1–C4 + re-checks + FINAL gate | OPEN ladder, GREEN functional gates (observed): ladder stopped at P0 (`SWARM_BOARD.md:118,178`); P0 CONFIRMED_PASS but PNG predates 11:57:42 shader (`FINAL_AUDIT_01.md:100-102`); P1–C4 stale/absent incl. P3 JSON ABSENT (E9); S1 no-PNG + provenance ambiguity (E10); RECHECK P1–C4 absent (E11); FINAL reserved; gates 29/29 t568 + 17/17 t569 + CLEAN exit 0 signed (`PROGRESS.md:104-116`; `FINAL_CHECKLIST.md:196-213,238-269`) | YES — COORD-ONLY sequence per `FINAL_AUDIT_01.md:161-179` B1/B2/B4: fresh windowed P0→S1 one ticket/row + `RECHECK_<ROW>.md` each, then 29/29+17/17+CLEAN FINAL last; targeted smoke only until then (S-25-12) |

## C. Top-10 next-ticket order (gate: targeted smoke only per S-25-12; full gates COORD-only last)

| # | Ticket (one builder, one file-set) | Depends on / gate |
|---|---|---|
| 1 | T1 relief/white-marks visual A/B — `world3d_terrain.gd` + shader only; seed 20261150; second-agent read | After §B(i); smoke 6/6 + PNG; no donor parity claim |
| 2 | T4a adapter `:172-173` typed fix verify — `hud3d_adapter.gd` only | Smoke SCRIPT ERROR 0; closes owner parse error |
| 3 | T4b rotor asset relocation — models dir only (out of `.gdignore`) + sidecar | Import job ok + `.ctex` present; closes C-4 28/29 root |
| 4 | T2a NATION units completion — `data.gd` only | Smoke parse; then T2b |
| 5 | T2b building/naval mesh hookup — `world3d_entities.gd` only | After art lands (0-OBJ BLOCKER, §B(ii)); probe 14/14 pattern |
| 6 | T3 construct-anim visual confirm — atom + `anim3d.gd` read-only verify first | Windowed capture; donor `peaukr.aaf:17` cite |
| 7 | T5a top-bar A/B 1024/1280/1920 — `hud.gd` only | `t_hud_layout` windowed PASS; no uitest weakening |
| 8 | T5c async-load usability — `main.gd` only | `t_load_usability` real-click run; MEASUREMENT_ONLY → PASS criteria pre-declared |
| 9 | T0 doc sweep — COORD applies §A DONE/ABANDONED States; refresh board lines + `/FINAL_CHECKLIST.md` stale-line pass | No code; unblocks ladder |
| 10 | COORD FINAL — ladder P0→C4→S1 windowed + RECHECKs + 29/29 (t568-class) + 17/17 (t569-class) + CLEAN exit 0, in that order | LAST; one Godot at a time; stop at first fail |

Contested-file collisions (derived — do NOT staff both sides concurrently): `world3d_entities.gd` =
NATION-MODEL-01 vs BUILD-STAGE-INTEGRATION-01 vs DECOR-01-closed vs T2b/T3; `game.gd` = TRN-DATA-closed vs
RELIEF-LIVE-FIX-01-closed vs NATION-DATA-IMPL-01-closed vs NATION-SPAWN-IMPL-01 vs RELIEF-LIVE-DIAG-01;
`hud.gd` = HUD-01-closed vs UI-TOPBAR-01 vs CONFIG-WIRE-HUD-closed vs MINIMAP-TIP-01-closed vs T5a;
`main.gd` = RELIEF-02-closed vs CONFIG-WIRE-RELIEF vs LOAD-ASYNC-01 vs BLANK-CHECK-01-closed vs T5c;
`world3d_terrain.gd` = TRN-GEOM-closed vs SP-6 vs DESERT-CONSUMER-FIX-01 vs T1; `data.gd` = NATION-DATA-IMPL-01 vs T2a;
`camera3d.gd`/`hud3d_adapter.gd` = CAM-02/MMJUMP-02-closed vs MINIMAP-QUAD-01 vs T4a. One owner per file at a time; backups per `SWARM_BOARD.md:232-234`.
