---
id: LINKS-01
title: "LINKS-01 — do all report paths cited by the living docs exist?"
area: documentation QA / read-only
owner: LINKS-01 (documentation micro-worker)
session: ses_dedd0b77affePHsOgnl49CI27l
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Exactly one new file: docs/coord_swarm_2026-11-25/reports/LINKS_01.md. All 14 living docs were read; every backticked .md token was extracted and existence-tested with Python 3.14. No doc, code, config, test, asset, backup, report or runner job was created or edited by this task."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot: "Final citation-table pass ~2026-11-25 11:21 local; on-disk report count 113 at ~11:24. SWARM_BOARD.md and reports/ were being edited concurrently by other workers during this pass - line numbers and the missing/orphan lists are point-in-time, not permanent."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
swarm: "docs/coord_swarm_2026-11-25/"
counts: "250 unique backticked .md tokens; 205 exist (146 explicit + 59 implicit-folder); 15 no file on disk; 20 stale old-doc paths; 10 glob/template tokens"
python: "python (3.14), not python3"
---

# LINKS-01 — report-path existence audit

## Sources (all read, read-only)

All paths below are relative to `docs/coord_swarm_2026-11-25/` unless printed in full.

1. `README.md` (390 lines) — entry point, pointer index, folder map.
2. `PROGRESS.md` (194 lines) — coordinator log, decisions S-25-01…S-25-15.
3. `SWARM_BOARD.md` (≈254 lines at final read) — ticket table, owners, states, output paths.
4. `GAPS.md` (67 lines) — exists/missing/how-to-fix, failure watchlist.
5. `CORRECTIONS.md` (170 lines) — 57-row corrections index.
6. `PLAN_IMPLEMENTATION.md` (74 lines) — atomic implementation tickets.
7. `TEST_MATRIX.md` (75 lines) — P0→C4→S1→FINAL ladder.
8. `CONFIG_PIPELINE.md` (340 lines) — 21-getter status freeze.
9. `CONFIG_COUNT_RECONCILED.md` (237 lines) — reconciled 11/2/2/6 count.
10. `CAPTURE_RECHECK.md` (281 lines) — second-agent re-check protocol.
11. `RUN_GUIDE.md` (143 lines) — owner-facing launch/verify guide.
12. `VIDEO_QA_PROTOCOL.md` (56 lines) — frame-sequence protocol.
13. `decomp/README.md` (54 lines) — decomp lane charter.
14. `decomp/SUMMARY.md` (389 lines) — consolidated decomp findings.

*Observed:* `GAPS.md` contains **zero** backticked `.md` paths — it cites tickets by ID only, so it contributes no rows to the table below. `VIDEO_QA_PROTOCOL.md` contributes exactly one (`reference/videos.md`).

## Method

- **Extraction (regex pass 1):** Python 3.14, `re` over each of the 14 docs; first find every single-backtick span containing `.md`, then find every `.md`-terminated token inside it. Optional `:line`, `:a-b,c` anchors were stripped before existence tests. Tokens containing `*` `<` `>` `{` `}` `[` `]` or `…` were classified as patterns/templates, not concrete paths. [observed]
- **Resolution rules (from the docs' own source conventions):** explicit `docs/...` → repo root; `reports/...` and `decomp/...` → swarm folder; `../...` inside `decomp/` → swarm folder; bare living-doc names → swarm root; bare report names in `CONFIG_PIPELINE.md` / `CONFIG_COUNT_RECONCILED.md` / `CAPTURE_RECHECK.md` / `RUN_GUIDE.md` → `reports/` (their frontmatter says so); bare `DEC_0x`/`SUMMARY`/`EVIDENCE_INDEX` in `decomp/` → `decomp/`. `Path.exists()` decided each row. [observed]
- **Second verification pass:** for every non-existing token, a repo-wide basename index (`Path.rglob("*.md")`, excluding `.git`) was searched to separate "genuinely absent" from "stale path outside today's folder". A manual sample re-counted six orphan candidates and three stale-claim names directly with `str.count()` over the 14 docs (see §Manual sample). [observed]
- **Count reconciliation:** 1,027 unique `(doc, line, raw-token)` citations at the 11:19:56 pass → 250 unique raw tokens in the frozen table below. The two counts differ because the same token is cited many times (e.g. `SWARM_BOARD.md` 50+ times, `TEST_MATRIX.md` 70+). Both passes were run twice with identical class assignment for the paths in the table; only the *number* of citations drifted (1,017 → 1,024 → 1,027) because other agents were editing `SWARM_BOARD.md` and landing reports during the audit. [derived; concurrency observed]
- **Labels:** `observed` = literal regex/disk result; `derived` = classification, counts, owner lookup from `SWARM_BOARD.md`; `inferred` = likely intent of a notation; `UNVERIFIED` = cannot prove from the docs (e.g. whether a RUNNING report will land).

### Manual sample (second verification of counts)

Direct `str.count()` over the 14 living docs confirmed:

| Sampled token | Hits in living docs | Regex-pass result |
|---|---|---|
| `TEST_P1_report.md`, `TEST_P2_report.md`, `TEST_C2_report.md`, `TEST_C3_report.md`, `SP_05_loader_override.md`, `TRN_DATA_implementation.md` | 0 each | all six absent from living docs -> orphans |
| `CONFIG_WIRE_RELIEF.md` | 4 (`SWARM_BOARD.md` 1; `CONFIG_COUNT_RECONCILED.md` 3) | cited, file exists |
| `TERRAIN_DARK_FIX.md` | 1 (`SWARM_BOARD.md`) | cited, file exists (but README calls it "no report" at :299) |
| `GDIGNORE_01.md` | 3 (README, SWARM_BOARD, RUN_GUIDE) | cited, file exists (RUN_GUIDE:139 says the opposite) |
| `RECHECK_<ROW>.md` forms | protocol templates | pattern, not a concrete file |
| Backtick spans containing `.md`, per doc | README 236, SWARM_BOARD 116, CORRECTIONS 157, CONFIG_PIPELINE 121, CAPTURE_RECHECK 152, RUN_GUIDE 120, decomp/SUMMARY 58, decomp/README 20, PROGRESS 22, CONFIG_COUNT 35, PLAN_IMPLEMENTATION 4, TEST_MATRIX 2, VIDEO_QA_PROTOCOL 1, GAPS 0 | totals consistent with pass 1 |

## Citation table — 250 unique backticked `.md` tokens

`exists?` YES means `Path.exists()` returned true at the frozen pass. "implicit-folder" means the doc printed only a basename but the file exists in the folder documented by that doc's own `source_convention`. `NO` in the stale-dir table means "not at the resolved path", **not** "file missing from the repo". Citations are shown as `doc:line`; `+N` means N further citations of the same token.

### A. Existing paths — explicit (146 tokens)

| cited path | citing doc(s) | exists? | note |
|---|---|---|---|
| `decomp/SUMMARY.md` | README.md:48, 133, 141, 173, 193 +6 | YES | exact |
| `decomp/EVIDENCE_INDEX.md` | README.md:48, 135, 174, 304, SWARM_BOARD.md:218 +3 | YES | exact |
| `reports/DEFAULTS_VERIFY_01.md` | README.md:61, 112, 203, 206, 321 +5 | YES | exact |
| `reports/S1_INPUT_FIX.md` | README.md:66, 189, 202, 273, 318 +1 | YES | exact |
| `reports/QA_AUDIT_01_implementation_claims.md` | README.md:69, 143, 203, 320, 385 +2 | YES | exact |
| `reports/ASSET_IMPORT_01.md` | README.md:77, 208, 276, SWARM_BOARD.md:192, RUN_GUIDE.md:139 | YES | exact |
| `reports/MOTION_ANIM_01.md` | README.md:78, 94, 208, 353, SWARM_BOARD.md:117 | YES | exact |
| `reports/TERRAIN_DARK_01.md` | README.md:79, 296, SWARM_BOARD.md:185 | YES | exact |
| `reports/LIGHT_02_light_space.md` | README.md:80, 200, 253, 297, SWARM_BOARD.md:119 | YES | exact |
| `reports/P0_GATE_01.md` | README.md:87, 200, 298, 318, SWARM_BOARD.md:154 | YES | exact |
| `reports/VID_AN_01_motion_analysis.md` | README.md:90, 190, 352, SWARM_BOARD.md:116 | YES | exact |
| `reports/SP_04_winter_atlas.md` | README.md:101, 192, 210, 252, 341 +1 | YES | exact |
| `reports/LFS_PLAN_01.md` | README.md:103, 210, 345, SWARM_BOARD.md:254 | YES | exact |
| `reports/DMAPGEN_01_skirmish_options.md` | README.md:109, 359, SWARM_BOARD.md:160, CORRECTIONS.md:101 | YES | exact |
| `decomp/README.md` | README.md:132, 172, 304, PROGRESS.md:76, SWARM_BOARD.md:46 | YES | exact |
| `reports/SP_06_renderer_hook.md` | README.md:151, SWARM_BOARD.md:175 | YES | exact |
| `reports/WEATHER_DRIVER_01.md` | README.md:152, SWARM_BOARD.md:228 | YES | exact |
| `reports/AUDIO_SEL_02.md` | README.md:153, SWARM_BOARD.md:226 | YES | exact |
| `reports/QA_WINTER_01.md` | README.md:154, SWARM_BOARD.md:243 | YES | exact |
| `reports/GDIGNORE_01.md` | README.md:154, SWARM_BOARD.md:249 | YES | exact |
| `reports/CAM_RV_01_view_rect_runtime.md` | README.md:188, 268, 319, SWARM_BOARD.md:124 | YES | exact |
| `reports/FINAL_GATE_PLAN_01.md` | README.md:203, 205, 322, 389, SWARM_BOARD.md:238 +1 | YES | exact |
| `reports/DSEL_01_donor_selection_rectangle.md` | README.md:258, SWARM_BOARD.md:18 | YES | exact |
| `reports/DSEL_02_donor_pick_math.md` | README.md:260, SWARM_BOARD.md:19 | YES | exact |
| `reports/V3D_01_selection_rectangle_audit.md` | README.md:262, SWARM_BOARD.md:26 | YES | exact |
| `reports/V2D_01_2d_selection_logic.md` | README.md:263, SWARM_BOARD.md:28 | YES | exact |
| `reports/RV_SEL_01_selection_reverify.md` | README.md:264, SWARM_BOARD.md:57, CORRECTIONS.md:29, 52, 80 +2 | YES | exact |
| `reports/RV_CAM_01_fov_resolution.md` | README.md:265, SWARM_BOARD.md:58, CORRECTIONS.md:30, 52, 53 +5 | YES | exact |
| `reports/SEL_01_implementation.md` | README.md:267, 365, SWARM_BOARD.md:87 | YES | exact |
| `reports/CAM_01_view_rect.md` | README.md:267 | YES | exact |
| `reports/CAM_02_view_rect_shift.md` | README.md:268 | YES | exact |
| `reports/HUD_01_minimap.md` | README.md:270, 370 | YES | exact |
| `reports/UITEST_ANCHOR.md` | README.md:270, 370 | YES | exact |
| `reports/MMJUMP_01_minimap_jump.md` | README.md:271, SWARM_BOARD.md:136 | YES | exact |
| `reports/MMJUMP_02_minimap_jump.md` | README.md:272, SWARM_BOARD.md:135 | YES | exact |
| `reports/TEST_S1_report.md` | README.md:274, 313 | YES | exact |
| `reports/DTRN_01_donor_terrain_pipeline.md` | README.md:280, SWARM_BOARD.md:20, CORRECTIONS.md:34, 56, 57 +7 | YES | exact |
| `reports/DTRN_02_donor_terrain_geometry.md` | README.md:281, SWARM_BOARD.md:21, CORRECTIONS.md:34, 82, 103 | YES | exact |
| `reports/DTRN_03_donor_shore_water.md` | README.md:282, SWARM_BOARD.md:22, CORRECTIONS.md:35, 71, 72 +1 | YES | exact |
| `reports/DTRN_04_donor_trees.md` | README.md:283, SWARM_BOARD.md:23 | YES | exact |
| `reports/DTRN_05_donor_mines.md` | README.md:283, SWARM_BOARD.md:24 | YES | exact |
| `reports/DTRN_06_donor_grass_decals.md` | README.md:284, SWARM_BOARD.md:25, CORRECTIONS.md:89 | YES | exact |
| `reports/V3D_02_terrain_render_audit.md` | README.md:285, SWARM_BOARD.md:27, TEST_MATRIX.md:36 | YES | exact |
| `reports/V2D_02_2d_terrain_logic.md` | README.md:286, SWARM_BOARD.md:29 | YES | exact |
| `reports/RV_TRN_01_texgen_mask_reverify.md` | README.md:287, SWARM_BOARD.md:54, CORRECTIONS.md:30, 86, 87 +7 | YES | exact |
| `reports/RV_TRN_02_smoothing_rules.md` | README.md:288, SWARM_BOARD.md:55, CORRECTIONS.md:31, 83, 84 +1 | YES | exact |
| `reports/RV_TRN_03_water_bindings.md` | README.md:289, SWARM_BOARD.md:56, CORRECTIONS.md:31, 71, 72 +3 | YES | exact |
| `reports/DALPHA_01_alpha_subrect.md` | README.md:291, 379, SWARM_BOARD.md:133, CORRECTIONS.md:32, 86 +4 | YES | exact |
| `reports/DPATTERN_01_relief_grids.md` | README.md:292, 379, SWARM_BOARD.md:138, CORRECTIONS.md:103 | YES | exact |
| `reports/DENV_01_environment.md` | README.md:293, 377, SWARM_BOARD.md:193, CORRECTIONS.md:33, 74 +3 | YES | exact |
| `reports/PIXEL_01_p0_capture_review.md` | README.md:294, CAPTURE_RECHECK.md:247 | YES | exact |
| `reports/METRIC_01_dark_rows.md` | README.md:295, CAPTURE_RECHECK.md:247 | YES | exact |
| `decomp/DEC_01_binaries_rtti.md` | README.md:305, SWARM_BOARD.md:37, CORRECTIONS.md:28, 47, 48 +4 | YES | exact |
| `decomp/DEC_08_ui_strings.md` | README.md:305, SWARM_BOARD.md:44, CORRECTIONS.md:28, 92, 93 +2 | YES | exact |
| `reports/DBIND_01_wus_bind.md` | README.md:306, 378, SWARM_BOARD.md:141, CORRECTIONS.md:32, 47 +6 | YES | exact |
| `reports/DANIM_01_action_ranges.md` | README.md:307, 355, 378, SWARM_BOARD.md:140, CORRECTIONS.md:33 +3 | YES | exact |
| `reports/DFORM_01_formations_morale.md` | README.md:308, SWARM_BOARD.md:143 | YES | exact |
| `reports/TEST_01_smallmap_harness.md` | README.md:311, SWARM_BOARD.md:30 | YES | exact |
| `reports/TEST_HARNESS_report.md` | README.md:311 | YES | exact |
| `reports/TEST_P0_report.md` | README.md:312, CAPTURE_RECHECK.md:247 | YES | exact |
| `reports/TEST_C1_report.md` | README.md:312 | YES | exact |
| `reports/TEST_RUN_01_ladder_log.md` | README.md:314, SWARM_BOARD.md:95 | YES | exact |
| `reports/ATOM_REPAIR_report.md` | README.md:315, SWARM_BOARD.md:96 | YES | exact |
| `reports/HARNESS_01_cast_fix.md` | README.md:315, SWARM_BOARD.md:97 | YES | exact |
| `reports/TEST_RUN_02_ladder_log.md` | README.md:316, SWARM_BOARD.md:155 | YES | exact |
| `reports/INT_REGISTRY_implementation.md` | README.md:317, 371 | YES | exact |
| `reports/CONFIG_PLAN_01.md` | README.md:325, SWARM_BOARD.md:182 | YES | exact |
| `reports/CONFIG_CORE_01.md` | README.md:326, SWARM_BOARD.md:183 | YES | exact |
| `reports/QA_CONFIG_01_getters.md` | README.md:329, SWARM_BOARD.md:231, CONFIG_COUNT_RECONCILED.md:26 | YES | exact |
| `reports/CONFIG_WIRE_SEL.md` | README.md:330, SWARM_BOARD.md:188 | YES | exact |
| `reports/CONFIG_UI_01.md` | README.md:331, SWARM_BOARD.md:184 | YES | exact |
| `reports/SEASON_PLAN_01.md` | README.md:336, SWARM_BOARD.md:147 | YES | exact |
| `reports/SP_01_season_enum.md` | README.md:336 | YES | exact |
| `reports/SP_02_winter_dictionary.md` | README.md:339 | YES | exact |
| `reports/SP_03_desert_remap.md` | README.md:340 | YES | exact |
| `reports/ATLAS_01_transport.md` | README.md:343, SWARM_BOARD.md:163, CORRECTIONS.md:100 | YES | exact |
| `reports/VID_CAP_01_capture.md` | README.md:351, SWARM_BOARD.md:115 | YES | exact |
| `decomp/DEC_04_anim_formats.md` | README.md:355, SWARM_BOARD.md:40, CORRECTIONS.md:60, 61, 98 | YES | exact |
| `reports/CFG_01_skirmish_defaults.md` | README.md:366, SWARM_BOARD.md:64, RUN_GUIDE.md:139 | YES | exact |
| `reports/CFG_02_no_menu_defaults.md` | README.md:367, SWARM_BOARD.md:65, CORRECTIONS.md:105 | YES | exact |
| `reports/TRN_SHADER_implementation.md` | README.md:368 | YES | exact |
| `reports/TRN_WATER_implementation.md` | README.md:368 | YES | exact |
| `reports/TRN_GEOM_implementation.md` | README.md:369 | YES | exact |
| `reports/DECOR_01_implementation.md` | README.md:369 | YES | exact |
| `reports/DOC_01_all_docs_synthesis.md` | README.md:374, SWARM_BOARD.md:31, CORRECTIONS.md:26, 95, 132 | YES | exact |
| `reports/DFX_01_pfx_effects.md` | README.md:376, SWARM_BOARD.md:139 | YES | exact |
| `docs/RESUME.md` | PROGRESS.md:22, decomp/README.md:53 | YES | exact, repo root |
| `docs/SWARM_OPS.md` | PROGRESS.md:22 | YES | exact, repo root |
| `docs/variant3d/README.md` | PROGRESS.md:22, RUN_GUIDE.md:14, 18, 19, 27 +7 | YES | exact, repo root |
| `docs/variant3d/STATUS_WAVE7_PHASE2.md` | PROGRESS.md:23, RUN_GUIDE.md:53 | YES | exact, repo root |
| `decomp/DEC_02_scripts.md` | SWARM_BOARD.md:38, CORRECTIONS.md:62, 63, 65, 67 +1 | YES | exact |
| `decomp/DEC_03_configs.md` | SWARM_BOARD.md:39, CORRECTIONS.md:64-67 +2 | YES | exact |
| `decomp/DEC_05_terrain_formats.md` | SWARM_BOARD.md:41, CORRECTIONS.md:56, 57, 69, 70 +1 | YES | exact |
| `decomp/DEC_06_map_formats.md` | SWARM_BOARD.md:42, CORRECTIONS.md:50, 57, 58, 59 +1 | YES | exact |
| `decomp/DEC_07_cameras_shaders.md` | SWARM_BOARD.md:43, CORRECTIONS.md:52, 53, 76, 77 +2 | YES | exact |
| `reports/FX_IMPACT_01.md` | SWARM_BOARD.md:118 | YES | exact |
| `reports/AUDIO_SEL_01.md` | SWARM_BOARD.md:121 | YES | exact |
| `reports/DALPHA_02_patch_mapping.md` | SWARM_BOARD.md:134 | YES | exact |
| `reports/FX_WEATHER_01.md` | SWARM_BOARD.md:137 | YES | exact |
| `reports/RELIEF_01_stamping.md` | SWARM_BOARD.md:145 | YES | exact |
| `reports/RELIEF_02_stamp_marker.md` | SWARM_BOARD.md:146 | YES | exact |
| `reports/CLEAN_01_variant_clean.md` | SWARM_BOARD.md:156, RUN_GUIDE.md:139 | YES | exact |
| `reports/CLEAN_02_variant_gate.md` | SWARM_BOARD.md:157 | YES | exact |
| `reports/DUNIT_01_unit_roster.md` | SWARM_BOARD.md:158 | YES | exact |
| `reports/DAUDIO_01_sound_events.md` | SWARM_BOARD.md:159, CORRECTIONS.md:102 | YES | exact |
| `reports/DBUILD_01_building_stages.md` | SWARM_BOARD.md:161 | YES | exact |
| `reports/TERRAIN_DARK_FIX.md` | SWARM_BOARD.md:186 | YES | exact |
| `reports/CONFIG_WIRE_WATER.md` | SWARM_BOARD.md:189 | YES | exact |
| `reports/CONFIG_WIRE_HUD.md` | SWARM_BOARD.md:190 | YES | exact |
| `reports/CONFIG_WIRE_CAM.md` | SWARM_BOARD.md:191 | YES | exact |
| `reports/README_UPDATE_01.md` | SWARM_BOARD.md:217 | YES | exact |
| `reports/INVENTORY_01_counts.md` | SWARM_BOARD.md:219, 242, CORRECTIONS.md:107-109 | YES | exact (landed during this audit) |
| `reports/CONFIG_WIRE_RELIEF.md` | SWARM_BOARD.md:227 | YES | exact (landed during this audit) |
| `reports/QA_2D_GATES_01.md` | SWARM_BOARD.md:241 | YES | exact (landed during this audit) |
| `reports/DSEASON_01_season_visuals.md` | SWARM_BOARD.md:245 | YES | exact (landed during this audit) |
| `reports/QA_DOCS_01.md` | SWARM_BOARD.md:251 | YES | exact |
| `reports/DONAVAL_01.md` | SWARM_BOARD.md:252 | YES | exact |
| `reports/QA_ATOM_RESULTS_01.md` | SWARM_BOARD.md:253 | YES | exact (landed during this audit) |
| `docs/decomp/DA_PE.md` | CORRECTIONS.md:47 | YES | exact, repo root (old lane) |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` | CONFIG_PIPELINE.md:49 | YES | exact |
| `docs/audit/CONFIG_EFFICIENCY.md` | CONFIG_PIPELINE.md:50 | YES | exact, repo root |
| `docs/audit/CONFIG_VERIFY.md` | CONFIG_PIPELINE.md:50 | YES | exact, repo root |
| `docs/coord_swarm_2026-11-24/reports/W55_visual_ab.md` | CONFIG_PIPELINE.md:51 | YES | exact, repo root |
| `docs/COMMANDS.md` | RUN_GUIDE.md:14, 18, 33, 37, 55 +6 | YES | exact, repo root |
| `reference/videos.md` | VIDEO_QA_PROTOCOL.md:49 | YES | exact, repo root |
| `../reports/RV_SEL_01_selection_reverify.md` | decomp/README.md:45, decomp/SUMMARY.md:210 | YES | exact |
| `../reports/RV_CAM_01_fov_resolution.md` | decomp/README.md:46 | YES | exact |
| `../reports/RV_TRN_01_texgen_mask_reverify.md` | decomp/README.md:47 | YES | exact |
| `../reports/RV_TRN_02_smoothing_rules.md` | decomp/README.md:48 | YES | exact |
| `../reports/RV_TRN_03_water_bindings.md` | decomp/README.md:49 | YES | exact |
| `../CORRECTIONS.md` | decomp/SUMMARY.md:22, 177, 188, 192, 195 +13 | YES | exact |
| `../reports/DANIM_01_action_ranges.md` | decomp/SUMMARY.md:88, 192, 290 | YES | exact |
| `../reports/DBIND_01_wus_bind.md` | decomp/SUMMARY.md:183, 230, 299 | YES | exact |
| `../reports/DFORM_01_formations_morale.md` | decomp/SUMMARY.md:196, 317 | YES | exact |
| `../reports/DENV_01_environment.md` | decomp/SUMMARY.md:198, 199, 308 | YES | exact |
| `../reports/DALPHA_01_alpha_subrect.md` | decomp/SUMMARY.md:200, 257 | YES | exact |
| `../reports/DMAPGEN_01_skirmish_options.md` | decomp/SUMMARY.md:202, 345 | YES | exact |
| `../reports/DAUDIO_01_sound_events.md` | decomp/SUMMARY.md:203, 335 | YES | exact |
| `../reports/DPATTERN_01_relief_grids.md` | decomp/SUMMARY.md:204, 270 | YES | exact |
| `../reports/ATLAS_01_transport.md` | decomp/SUMMARY.md:205, 376 | YES | exact |
| `../reports/LIGHT_02_light_space.md` | decomp/SUMMARY.md:206, 364 | YES | exact |
| `../reports/DFX_01_pfx_effects.md` | decomp/SUMMARY.md:279 | YES | exact |
| `../reports/DUNIT_01_unit_roster.md` | decomp/SUMMARY.md:326 | YES | exact |
| `../reports/DBUILD_01_building_stages.md` | decomp/SUMMARY.md:354 | YES | exact |
| `../GAPS.md` | decomp/SUMMARY.md:385 | YES | exact |
| `../PLAN_IMPLEMENTATION.md` | decomp/SUMMARY.md:385 | YES | exact |

### B. Existing paths — implicit folder (59 tokens)

| cited path | citing doc(s) | exists? | note |
|---|---|---|---|
| `CHARTER.md` | README.md:23, 117, 138, 162, PROGRESS.md:20 +1 | YES | -> swarm root |
| `GAPS.md` | README.md:35, 120, 122, 139, 165 +6 | YES | -> swarm root |
| `PROGRESS.md` | README.md:35, 71, 126, 141, 143 +10 | YES | -> swarm root |
| `SWARM_BOARD.md` | README.md:45, 75, 108, 123, 145 +45 | YES | -> swarm root |
| `CORRECTIONS.md` | README.md:49, 50, 118, 138, 168 +4 | YES | -> swarm root |
| `VIDEO_QA_PROTOCOL.md` | README.md:88, 132, 138, 144, 170 +9 | YES | -> swarm root |
| `CONFIG_PIPELINE.md` | README.md:96, 128, 140, 147, 169 +13 | YES | -> swarm root (NOT `reports/`) |
| `TEST_MATRIX.md` | README.md:131, 139, 166, 202, PROGRESS.md:21 +67 | YES | -> swarm root |
| `PLAN_IMPLEMENTATION.md` | README.md:132, 139, 167, PROGRESS.md:55, 178 | YES | -> swarm root |
| `README.md` | README.md:171, PROGRESS.md:33, SWARM_BOARD.md:162, 217, 236 +1 | YES | -> swarm root |
| `README_UPDATE_01.md` | README.md:176 | YES | -> `reports/` |
| `ASSET_IMPORT_01.md` | README.md:277, RUN_GUIDE.md:44, 55, 101, 108 +3 | YES | -> `reports/` |
| `DALPHA_02_patch_mapping.md` | README.md:291 | YES | -> `reports/` |
| `TEST_P3_report.md` | README.md:312 | YES | -> `reports/` |
| `TEST_C4_report.md` | README.md:313 | YES | -> `reports/` |
| `CONFIG_WIRE_CAM.md` | README.md:330, CONFIG_PIPELINE.md:44, 85, 242, 282 +3 | YES | -> `reports/` |
| `CONFIG_WIRE_WATER.md` | README.md:330, CONFIG_PIPELINE.md:44, 86, 87, 109 +8 | YES | -> `reports/` |
| `CONFIG_WIRE_HUD.md` | README.md:331, CONFIG_COUNT_RECONCILED.md:101-103, 149 +4 | YES | -> `reports/` |
| `SP_08_season_test.md` | README.md:336 | YES | -> `reports/` |
| `EVIDENCE_INDEX.md` | PROGRESS.md:78, decomp/README.md:54, decomp/SUMMARY.md:17, 384 | YES | -> `decomp/` |
| `CONFIG_COUNT_RECONCILED.md` | SWARM_BOARD.md:235 | YES | -> swarm root |
| `CAPTURE_RECHECK.md` | SWARM_BOARD.md:240 | YES | -> swarm root |
| `RUN_GUIDE.md` | SWARM_BOARD.md:250 | YES | -> swarm root |
| `DSEL_01_donor_selection_rectangle.md` | CORRECTIONS.md:80 | YES | -> `reports/` (name-only citation) |
| `SUMMARY.md` | CORRECTIONS.md:163, decomp/README.md:44 | YES | -> `decomp/` |
| `CONFIG_PLAN_01.md` | CONFIG_PIPELINE.md:42, 91, 93, 106, 118 +31 | YES | -> `reports/` |
| `CONFIG_CORE_01.md` | CONFIG_PIPELINE.md:43, 64, 67, 74, 80 +14 | YES | -> `reports/` |
| `CONFIG_WIRE_SEL.md` | CONFIG_PIPELINE.md:44, 244, 249, 261, 287 +4 | YES | -> `reports/` |
| `CONFIG_UI_01.md` | CONFIG_PIPELINE.md:45, 89, 90, 100, 213 +11 | YES | -> `reports/` |
| `CONFIG_WIRE_RELIEF.md` | CONFIG_COUNT_RECONCILED.md:94, 205, 220 | YES | -> `reports/` (docs still call it absent) |
| `QA_CONFIG_01_getters.md` | CONFIG_COUNT_RECONCILED.md:129, 165, 178, 233 | YES | -> `reports/` |
| `DEFAULTS_VERIFY_01.md` | CONFIG_COUNT_RECONCILED.md:178, RUN_GUIDE.md:57, 113, 117, 118 +5 | YES | -> `reports/` |
| `TEST_RUN_02_ladder_log.md` | CAPTURE_RECHECK.md:34, 35, 45, 49, 50 +12 | YES | -> `reports/` |
| `TEST_RUN_01_ladder_log.md` | CAPTURE_RECHECK.md:34, 49, 51, 256, 258 | YES | -> `reports/` |
| `PIXEL_01_p0_capture_review.md` | CAPTURE_RECHECK.md:35 | YES | -> `reports/` |
| `METRIC_01_dark_rows.md` | CAPTURE_RECHECK.md:35, RUN_GUIDE.md:133 | YES | -> `reports/` |
| `FINAL_GATE_PLAN_01.md` | CAPTURE_RECHECK.md:35, 37, 45, 50, 54 +28 | YES | -> `reports/` |
| `P0_GATE_01.md` | CAPTURE_RECHECK.md:36, 75, 95, 108, 109 +8 | YES | -> `reports/` |
| `S1_INPUT_FIX.md` | CAPTURE_RECHECK.md:54, 221, 225, 226, 264 +2 | YES | -> `reports/` |
| `TEST_P0_report.md` | CAPTURE_RECHECK.md:95, 99, 101, 105, 260 | YES | -> `reports/` |
| `TERRAIN_DARK_01.md` | CAPTURE_RECHECK.md:262, RUN_GUIDE.md:133 | YES | -> `reports/` |
| `CLEAN_02_variant_gate.md` | RUN_GUIDE.md:55, 100, 103, 139 | YES | -> `reports/` |
| `CLEAN_01_variant_clean.md` | RUN_GUIDE.md:55, 100 | YES | -> `reports/` |
| `QA_AUDIT_01_implementation_claims.md` | RUN_GUIDE.md:57 | YES | -> `reports/` |
| `VID_CAP_01_capture.md` | RUN_GUIDE.md:68, 82, 92, 98, 102 +3 | YES | -> `reports/` |
| `CFG_01_skirmish_defaults.md` | RUN_GUIDE.md:117, 120, 121, 123 | YES | -> `reports/` |
| `GDIGNORE_01.md` | RUN_GUIDE.md:139 | YES | -> `reports/` (guide says the opposite) |
| `DEC_01_binaries_rtti.md` | decomp/README.md:34 | YES | -> `decomp/` |
| `DEC_02_scripts.md` | decomp/README.md:35 | YES | -> `decomp/` |
| `DEC_03_configs.md` | decomp/README.md:36 | YES | -> `decomp/` |
| `DEC_04_anim_formats.md` | decomp/README.md:37 | YES | -> `decomp/` |
| `DEC_05_terrain_formats.md` | decomp/README.md:38 | YES | -> `decomp/` |
| `DEC_06_map_formats.md` | decomp/README.md:39 | YES | -> `decomp/` |
| `DEC_07_cameras_shaders.md` | decomp/README.md:40 | YES | -> `decomp/` |
| `DEC_08_ui_strings.md` | decomp/README.md:41 | YES | -> `decomp/` |
| `RV_CAM_01_fov_resolution.md` | decomp/SUMMARY.md:211 | YES | -> `reports/` |
| `RV_TRN_01_texgen_mask_reverify.md` | decomp/SUMMARY.md:212, 268 | YES | -> `reports/` |
| `RV_TRN_02_smoothing_rules.md` | decomp/SUMMARY.md:214 | YES | -> `reports/` |
| `RV_TRN_03_water_bindings.md` | decomp/SUMMARY.md:215 | YES | -> `reports/` |

### C. Missing paths — no file anywhere in repo (15 tokens)

| cited path | citing doc | exists? | class | note / owner from board |
|---|---|---|---|---|
| `TEST_RUN_02_selection_log.md` | README.md:202 | NO | (b) never landed | README itself says "not landed"; Batch G :98 RESERVED with no session. Superseded by `TEST_RUN_02_ladder_log.md` (DONE, :155) and `S1_INPUT_FIX.md`. |
| `reports/MAP_SMALL_01_report.md` | SWARM_BOARD.md:66 | NO | (a) in flight | MAP-SMALL-01 RUNNING, `ses_dee1ffa4dffeNE1DyOlFaHFllL`; code landed as `f9dd8d16` but report absent; README :206 and QA-AUDIT :18 agree. |
| `reports/TEST_RUN_02_selection_log.md` | SWARM_BOARD.md:98 | NO | (b) never landed | Same artifact as above; RESERVED, no session id. |
| `reports/MINIMAP_QUAD_01.md` | SWARM_BOARD.md:120 | NO | (a) in flight | MINIMAP-QUAD-01 RUNNING, `ses_dedf02a90ffdT7nAiMWDUbpMQj`. |
| `reports/LINKS_01.md` | SWARM_BOARD.md:220 | NO at pass time | (a) in flight -> landed | This report; created by this task. |
| `reports/QA_PARITY_01.md` | SWARM_BOARD.md:230 | NO | (a) in flight | QA-PARITY-01 RUNNING, `ses_dede47f21ffeN0cMxpshIcpAOZ`. |
| `reports/MAPSIZE_01.md` | SWARM_BOARD.md:233 | NO | (a) in flight | MAPSIZE-01 RUNNING, `ses_dede3a392ffe6P3B6Ttaon7o44`. |
| `reports/PERF_3D_01.md` | SWARM_BOARD.md:237 | NO | (a) in flight | PERF-3D-01 RUNNING, `ses_deddede28ffePAlAptFGEy4kzn`. |
| `reports/DARKROW_ALL_01.md` | SWARM_BOARD.md:239 | NO | (a) in flight | DARKROW-ALL-01 RUNNING, `ses_deddb4a21ffeMNC2rRgf4X3t4F`. |
| `reports/SEASON_TEST_PATH_01.md` | SWARM_BOARD.md:244 | NO | (a) in flight | SEASON-TEST-PATH-01 RUNNING, `ses_dedd5c6b9ffebY8CjZ2LHhmm8U`; owns the `tile_index_*` path fix. |
| `reports/DESERT_REMAP_02.md` | SWARM_BOARD.md:246 | NO | (a) in flight | DESERT-REMAP-02 RUNNING, `ses_dedc825e3ffeCybE4oju7Ds2Az` (board row landed mid-audit). |
| `reports/PROP_W_PLAN_01.md` | SWARM_BOARD.md:247 | NO | (a) in flight | PROP-W-PLAN-01 RUNNING, `ses_dedc825dfffe65At77RG2CJO98`. |
| `reports/SP8_STATUS_01.md` | SWARM_BOARD.md:248 | NO | (a) in flight | SP8-STATUS-01 RUNNING, `ses_dedc825deffegTIEqiL78uxsGw`. |
| `reports/RECHECK_P0.md` | CAPTURE_RECHECK.md:247 | NO | (a) in flight/future | Protocol example; second-agent re-check report not yet authored; no owner assigned in board. |
| `reports/RECHECK_S1.md` | CAPTURE_RECHECK.md:247 | NO | (a) in flight/future | Same protocol example. |

### D. Stale old-doc paths — concrete file exists elsewhere in repo (20 tokens)

These are **(d) stale old-doc paths outside today's folder as written** (bare basename does not resolve relative to the swarm or repo root, but a same-named file exists elsewhere). Most occur in `CORRECTIONS.md`'s "Old source" column, where `CORRECTIONS.md` §Goal explicitly says the old source is named only to describe what was superseded — so **intentional historical reference** is `inferred`, resolvability as a cold-readable path is `observed: NO`.

| cited path | citing doc(s) | exists? as written | class | found at |
|---|---|---|---|---|
| `SWARM_OPS.md` | README.md:234, PROGRESS.md:170, CORRECTIONS.md:95 | NO | (d) | `docs/SWARM_OPS.md` |
| `DA_PE.md` | CORRECTIONS.md:48, 50 | NO | (d) | `docs/decomp/DA_PE.md` |
| `DECOMP_04_strings_config.md` | CORRECTIONS.md:64 | NO | (d) | `docs/coord_swarm_2026-11-24/reports/DECOMP_04_strings_config.md` |
| `CONFIG_EFFICIENCY.md` | CORRECTIONS.md:64, CONFIG_PIPELINE.md:292 | NO | (d) | `docs/audit/CONFIG_EFFICIENCY.md` |
| `DB_SCRIPTS.md` | CORRECTIONS.md:65, 66 | NO | (d) | `docs/decomp/DB_SCRIPTS.md` |
| `RB_MECHANICS.md` | CORRECTIONS.md:67 | NO | (d) | `docs/research/RB_MECHANICS.md` |
| `TERRAIN_PORT_HILLS.md` | CORRECTIONS.md:82, 103 | NO | (d) | `docs/audit/TERRAIN_PORT_HILLS.md` |
| `PIECES/plateau.md` | CORRECTIONS.md:82, 103 | NO | (d) | `docs/audit/PIECES/plateau.md` |
| `TERRAIN_DONOR_PIPELINE.md` | CORRECTIONS.md:83, 84 | NO | (d) | `docs/audit/TERRAIN_DONOR_PIPELINE.md` |
| `RE_VISUAL.md` | CORRECTIONS.md:92, decomp/SUMMARY.md:161 | NO | (d) | `docs/research/RE_VISUAL.md` |
| `DE_AUDIO_UI.md` | CORRECTIONS.md:93 | NO | (d) | `docs/decomp/DE_AUDIO_UI.md` |
| `V717_hud3d_adapter.md` | CORRECTIONS.md:94 | NO | (d) | `docs/coord_swarm_2026-11-24/reports/V717_hud3d_adapter.md` |
| `AGENT_PROTOCOL.md` | CORRECTIONS.md:95 | NO | (d) | `variant3d/tools/AGENT_PROTOCOL.md`, `app/tools/AGENT_PROTOCOL.md` |
| `QA_REPORT.md` | CORRECTIONS.md:95 | NO | (d) | `docs/QA_REPORT.md` |
| `TERRAIN_SMALL_maps.md` | TEST_MATRIX.md:33 | NO | (d) | `docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md` |
| `CONFIG_VERIFY.md` | CONFIG_PIPELINE.md:221, 292 | NO | (d) | `docs/audit/CONFIG_VERIFY.md` |
| `W55_visual_ab.md` | CONFIG_PIPELINE.md:282, CAPTURE_RECHECK.md:237, 266, 275 | NO | (d) | `docs/coord_swarm_2026-11-24/reports/W55_visual_ab.md` |
| `STATUS_WAVE7_PHASE2.md` | RUN_GUIDE.md:44, 57, 98 | NO | (d) | `docs/variant3d/STATUS_WAVE7_PHASE2.md` |
| `CLEAN_GATE.md` | RUN_GUIDE.md:55, 57, 100, 103, 129, 135 | NO | (d) | `variant3d/tools/CLEAN_GATE.md`, `app/tools/CLEAN_GATE.md` |
| `AUDIT3D_TRIAGE.md` | RUN_GUIDE.md:98 | NO | (d) | `docs/coord_swarm_2026-11-24/AUDIT3D_TRIAGE.md` |

### E. Globs and templates — not concrete paths (10 tokens)

| cited path | citing doc(s) | exists? | note |
|---|---|---|---|
| `DEC_0x_*.md` | README.md:134, 193, PROGRESS.md:75, decomp/SUMMARY.md:17, 385 | N/A | glob for the 8 DEC reports; all resolve under `decomp/` |
| `decomp/DEC_0x_*.md` | README.md:175 | N/A | same glob, explicit folder |
| `reports/<TICKET>.md` | README.md:176, PLAN_IMPLEMENTATION.md:59, CONFIG_PIPELINE.md:255 | N/A | naming template |
| `RECHECK_<ROW>.md` | SWARM_BOARD.md:240, CAPTURE_RECHECK.md:240, 247-249 | N/A | protocol output template |
| `reports/RECHECK_<ROW>.md` | CAPTURE_RECHECK.md:89, 276 | N/A | template |
| `docs/coord_swarm_2026-11-25/reports/RECHECK_<ROW>.md` | CAPTURE_RECHECK.md:247 | N/A | template, full path |
| `DE_AUDIO_UI}.md` | decomp/README.md:24 | N/A | brace-list tail (`{DA_PE,DB_SCRIPTS,DC_FORMATS,DD_MAPS,DE_AUDIO_UI}.md`) |
| `handoff}.md` | decomp/README.md:25 | N/A | brace-list tail (`{brief,findings,hypotheses,plan,handoff}.md`) |
| `../reports/DTRN_*.md` | decomp/README.md:52 | N/A | glob |
| `DSEL_*.md` | decomp/README.md:52 | N/A | glob |

## Orphan reports — on disk but no living doc cites them

Manual second pass (direct `str.count()` over all 14 living docs) confirmed zero exact-name hits for each of these six. Their topics are from each report's own frontmatter. [observed]

| report on disk | topic | why uncited / note |
|---|---|---|
| `reports/SP_05_loader_override.md` | SP-05: optional atlas `manifest_path` override in `tile_atlas_loader.gd` (season hook) | README :336 cites `SP_01…SP_08` as an ellipsis range, never `SP_05_loader_override.md` explicitly; board SP-5 row lists only the owned `.gd` file. Cited by other reports (`LFS_PLAN_01`, `SP_06_renderer_hook`) but not by any of the 14 living docs. |
| `reports/TEST_P1_report.md` | TEST-P1: 64² terrain+trees isolated atom, authoring only | README :312 cites `TEST_P0_report.md … TEST_P3_report.md` as a range; P1 name never printed. |
| `reports/TEST_P2_report.md` | TEST-P2: 64² terrain+shore isolated atom, authoring only | Same range citation. |
| `reports/TEST_C2_report.md` | TEST-C2: trees+mines combo atom, 32 checks authored | README :312 cites `TEST_C1_report.md … TEST_C4_report.md` as a range; C2 name never printed. |
| `reports/TEST_C3_report.md` | TEST-C3: shore+mines combo atom, 16 checks authored | Same range citation. |
| `reports/TRN_DATA_implementation.md` | TRN-DATA: 118/118 smoothing lists + 282 TileName in `game.gd`, FULL_SELFTEST_AMBER | **True omission:** README :368-370 lists the other Batch H implementation reports but not this one; board :111 marks TRN-DATA DONE and the report exists. `QA_DOCS_01.md` and `FINAL_GATE_PLAN_01.md` (reports, not living docs) cite it. |

No orphan decomp files: all 11 `decomp/*.md` files are cited by a living doc. Root swarm docs cited: all except `CHARTER.md`? No — `CHARTER.md` is cited (implicit). All 13 non-this-report swarm-root docs are cited. [observed]

## Ranked issues (recommended fix tickets; no doc edited here)

1. **P1 — Stale "report absent" claims now contradicted by files on disk.** `CONFIG_COUNT_RECONCILED.md:94,205,220` and `CONFIG_PIPELINE.md:223,247,266,311` still say `CONFIG_WIRE_RELIEF.md` is absent while the report exists; `README.md:299` says TERRAIN-DARK-FIX is "RUNNING with no report on disk" while `reports/TERRAIN_DARK_FIX.md` exists; `RUN_GUIDE.md:139` says "There is **no** `GDIGNORE_01.md`" while `reports/GDIGNORE_01.md` exists; `decomp/SUMMARY.md:256` says `DSEASON_01`/`DONAVAL_01` were absent while both reports exist; `SWARM_BOARD.md` marked QA-ATOM-RESULTS-01, QA-2D-GATES-01, INVENTORY-01 RUNNING/absent while their reports landed during this audit. Class (d), stale facts rather than broken file links. **Ticket: DOC-STALE-STATUS-01 (COORD / README-UPDATE-02): re-read `reports/` and sync README / CONFIG_* / decomp/SUMMARY / board State column; do not edit a report to hide the drift.** [observed]
2. **P1 — 15 concrete paths with no file (§C).** 11 are (a) in flight with a named RUNNING owner on `SWARM_BOARD.md` (including this report, LINKS-01); 2 (`TEST_RUN_02_selection_log.md` and its `reports/` twin) are (b) never landed, explicitly declared "not landed" by README :202 and RESERVED with no session at board :98, while the related ladder log landed under a different name; 2 are CAPTURE-RECHECK protocol examples. **Ticket: LINKS-FILL-01 (COORD): at drain, either land each in-flight report or delete its path from the board; decide explicitly whether the S1 selection log is obsolete given `S1_INPUT_FIX.md`.** [derived from board rows]
3. **P2 — 20 stale bare old-doc paths (§D).** They resolve neither to the swarm nor repo root; same-named files exist in `docs/audit/`, `docs/decomp/`, `docs/research/`, `docs/coord_swarm_2026-11-24/`, `docs/variant3d/`, `variant3d/tools/`/`app/tools/`. In `CORRECTIONS.md` they are probably deliberately the "old source" column, but a cold reader cannot follow them. **Ticket: LINKS-PREFIX-01 (DOC worker): print full repo-root paths, e.g. `docs/audit/TERRAIN_PORT_HILLS.md`, without changing the corrections' substance.** [observed + inferred intent]
4. **P2 — 6 orphan reports (§Orphan).** Five are hidden behind ellipsis ranges in README §6; `TRN_DATA_implementation.md` is a genuine omission from the implementation list. **Ticket: LINKS-ORPHAN-01 (README-UPDATE-02): add explicit `reports/...` pointers for all six (SP-05, TEST-P1/P2, TEST-C2/C3, TRN-DATA).** [observed]
5. **P3 — 10 template/glob tokens (§E).** They are intentional naming patterns, not defects. Keep, but do not count them as existing reports when quoting "N reports". [derived]
6. **P3 — (c) name-mismatch family outside the `.md` path set:** README :105-107 and :210 and GAPS :42 record that renderer/test constants use `tile_index_winter_atlas.*` while the built artifacts are `tile_index_atlas_winter.*` (`SP_04_winter_atlas.md` §7.2; `LFS_PLAN_01.md:152-160`). QA-WINTER-01 aligned SP-6's source (`world3d_terrain.gd:272-273`) but the SP-8 atom still uses the swapped name. This is the same class as a broken citation but concerns asset names, not `.md` paths — listed here because the task named it explicitly. **Ticket: SEASON-TEST-PATH-01 (already RUNNING, `ses_dedd5c6b9ffebY8CjZ2LHhmm8U`): align SP-8 atom constants and re-verify.** [observed]
7. **P3 — conflicting TEST-RUN-02 records:** board :98 RESERVED "execute S1 … selection log" vs board :155 DONE "restart P0→C4 ladder" with a different output path, plus README :202 "not landed". Both are about the same ticket id but different artifacts. **Ticket: LINKS-TESTLOG-01 (COORD): rename/merge the rows so one ticket has one output path.** [observed]

## Open questions

1. Will the 11 RUNNING in-flight reports land before COORD's final gate? [UNVERIFIED — board is a moving snapshot; three new RUNNING rows appeared during this audit]
2. Did any `RECHECK_<ROW>.md` actually get authored after this pass? [UNVERIFIED — none on disk at pass time; only the protocol template exists]
3. Are the bare old-doc names in `CORRECTIONS.md`'s "Old source" column intentionally historical shorthand? [inferred yes from §Goal; not stated per row]
4. Is `reports/LINKS_01.md` now cited by a living doc? Only `SWARM_BOARD.md:220` cites it, and that is the board's own target cell; no §6 pointer index entry exists yet. [observed]
5. Exact report count at this instant: 113 observed at ~11:24, up from 108 at ~11:16 — the delta is concurrent landings, not a counting error. Re-run the extraction before acting on counts. [observed]
6. No donor, runtime, or gate claim was checked here — path existence says nothing about a report's truth or PASS status. [observed]

## Summary

- **Read:** all 14 living docs. **Extracted:** 250 unique backticked `.md` tokens (1,027 unique doc/line/token citations at the 11:19:56 pass). [observed]
- **Exist:** 205/250 (146 explicit paths + 59 basenames resolved via each doc's stated folder convention). All 8 `DEC_0x` reports and both decomp index/summary files exist. [observed]
- **Do not exist as written:** 15 concrete paths (11 in-flight with named owners, 2 never-landed selection-log paths, 2 protocol examples) and 20 stale old-doc paths that exist elsewhere in the repo. [derived]
- **Not concrete:** 10 glob/template tokens. [observed]
- **Orphans:** 6 on-disk reports with no living-doc citation (SP-05, TEST-P1/P2, TEST-C2/C3, TRN-DATA). [observed]
- **Highest-value fix:** sync the stale "report absent" claims and add the six orphan pointers; the 13 in-flight paths should be resolved by their owners, not by this QA worker. [inferred]
- **No visual-parity, gate, test or code claim is made by this report.** Donor parity remains UNVERIFIED; this is a path-existence audit only.
- **Scope statement:** no file other than `docs/coord_swarm_2026-11-25/reports/LINKS_01.md` was created or edited. The three analysis scripts used for the regex/disk passes live outside the repo in `%LOCALAPPDATA%\Temp\opencode\` (`links01_extract.py`, `links01_resolve.py`, `links01_final.py`, `links01_md.py`, `links01_manual.py`); no runner job was submitted.
