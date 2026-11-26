# SWARM BOARD — 2026-11-26 donor-first terrain port

Status key: `QUEUED` → `RUNNING` → `LANDED` → `INTEGRATED`. COORD updates this
file when a report lands. Workers never edit this file. At least 30 workers are
kept active; finished slots are immediately recycled into verification tasks.

**Board refresh by V45 (COORD-delegated board owner) — filesystem-authoritative.**
Method: four independent `Get-ChildItem` listings of `reports/**` plus explicit
`Test-Path` checks of implementation/QA files; the report set **grew between
passes** (X28, V33, V34, V36, X26 appeared in later passes), so the frozen
authority is the **4th listing** used below. Status rule applied uniformly:
a report file on disk ⇒ `LANDED`; `INTEGRATED` only where the report is named
in an on-disk completion/integration annotation (`*Integrated by COORD from …*`
lines in `spec/01`–`spec/14`); no report file ⇒ `RUNNING`. No separate session
completion-message ledger was available to this worker — the spec annotations
are the integration evidence used. `INTEGRATED` is a **documentation** state:
it is **not** a gate pass, not a spec-READY marker and not a donor-parity claim.
This worker ran no Godot job, no gate, no capture, no git command; `app/**` was
not re-verified here. No parity claim is made anywhere in this board. Counts in
that V45 note are a point-in-time snapshot; see the V74 refresh below.

**Board refresh by V74 (COORD-delegated reconciler) — filesystem-authoritative.**
Method: two independent full `Get-ChildItem` listings of `reports/**` (identical),
a third count-parse pass, then repeated re-globs because the set kept growing
(92 → 102 → 103 → 113 → 117 → 124 files) during the passes and even during this
edit. Authority = the **final 124-file glob**; every count here is point-in-time and
must be re-globbed before use. Status rule unchanged: a report file on disk ⇒
`LANDED` (**file presence only**); `INTEGRATED` only where an on-disk spec
integration annotation names the report; no file ⇒ `RUNNING`. V56 reported 8
false "no report" rows and 6 missing rows; the fresh V74 glob finds **11** false
"no report" rows (X16, X23, X24, X25, X29, X31, X33, V38, V42, V44, I16) and
**37** report ids with no row at first measurement (V47–V49, V52, V53, V55–V60,
V61–V67, V72, V76, V81, V83, V87, V90, V98, X34–X37, X39, X44, X49, X51,
X54–X57). These are the additional ids landed after V56's read, with twenty-one
more arriving mid-edit. All are reconciled
below; any later landing needs another row, and the swarm was still landing
reports at the final read (see the snapshot caveat under the table).
`reports/V47_final_contradictions.md` **has landed** and is now the single
canonical contradiction register (§Contradiction register). No gate was run, no
capture was taken, and no Godot job or git command was issued by this worker;
`app/**` was not re-verified. Parity stays `UNVERIFIED`.

| ID | Wave | Assignment (one report each) | Owner file | Status |
|---|---|---|---|---|
| D01 | Binary | RTTI `X*` class → concrete CODE function anchor map | `reports/D01_rtti_function_anchors.md` | LANDED |
| D02 | Binary | Seed (`randkey1/2`) + `RandomExt` RNG algorithm | `reports/D02_seed_rng.md` | **INTEGRATED** → §02 |
| D03 | Binary | Terrainmask TGA load → blur → smoothing chain | `reports/D03_mask_pipeline.md` | **INTEGRATED** → §03 |
| D04 | Binary | `.map` / `TMapTerrainDataTile` binary layout | `reports/D04_map_format.md` | LANDED |
| D05 | Binary | Relief stamp: pattern grid → height, blend order | `reports/D05_relief_stamp.md` | **INTEGRATED** → §04 |
| D06 | Binary | Water level, shore smooth, water bindings | `reports/D06_water_shore.md` | **INTEGRATED** → §05 |
| D07 | Binary | Resource placement: mines, stone, forest | `reports/D07_resources_bin.md` | **INTEGRATED** → §07 |
| D08 | Binary | Tile id → atlas → shader selection | `reports/D08_tile_select_bin.md` | LANDED |
| D09 | Binary | `editor.exe` terrain forms/handlers + parameter map | `reports/D09_editor_binary.md` | LANDED |
| F01 | Data | `.pattern` binary format full spec + decoder | `reports/F01_pattern_format.md` | **INTEGRATED** → §04/§11 |
| F02 | Data | `pattern.lib`: plaintext DB, 680 records, line map | `reports/F02_pattern_lib.md` | **INTEGRATED** → §04 |
| F03 | Data | Gen cfg constants (7 files, hashes, full grammar) | `reports/F03_gen_config.md` | **INTEGRATED** → §09 |
| F04 | Data | Terrainmask TGA channels, inventory/counts | `reports/F04_masks.md` | **INTEGRATED** → §03 |
| F05 | Data | `reftile.mat`/tile id → block PNG mapping | `reports/F05_tile_mapping.md` | **INTEGRATED** → §06 |
| F06 | Data | `alpha.bmp`/`alphavert`, `bmTransparency` | `reports/F06_alpha_masks.md` | **INTEGRATED** → §05/§06 |
| F07 | Data | Mill / field / pump assets and families | `reports/F07_mill_fields.md` | **INTEGRATED** → §08 |
| F08 | Data | Forest / stone / mine families, weights | `reports/F08_flora_minerals.md` | **INTEGRATED** → §08 |
| F09 | Data | `editor.inc` + `editor.aix` DScript terrain API | `reports/F09_editor_script.md` | LANDED |
| F10 | Data | DLC / expansion terrain additions | `reports/F10_dlc_terrain.md` | LANDED |
| P01 | Port | Current terrain pipeline end-to-end | `reports/P01_pipeline_audit.md` | **INTEGRATED** → §14 |
| P02 | Port | Donor-derived terrain asset inventory | `reports/P02_asset_inventory.md` | LANDED |
| P03 | Port | Tests / gates / capture tooling readiness | `reports/P03_gates_capture.md` | LANDED |
| P04 | Port | Existing decoder tools reuse audit | `reports/P04_tool_audit.md` | **INTEGRATED** → §11 |
| P05 | Port | 2D `app/` donor-derived reusable pieces | `reports/P05_2d_reuse.md` | LANDED |
| P06 | Port | Prior-wave root causes + rejected approaches | `reports/P06_prior_wave_distill.md` | **INTEGRATED** → §13 |
| A01 | Design | Donor-faithful terrain data model | `reports/A01_data_model.md` | **INTEGRATED** → §01 |
| A02 | Design | Donor-faithful generation algorithm | `reports/A02_algorithm.md` | **INTEGRATED** → §03/§04/§05/§07/§10 |
| A03 | Design | Asset conversion pipeline | `reports/A03_asset_pipeline.md` | **INTEGRATED** → §11 |
| A04 | Design | Landscape props (all classes) | `reports/A04_landscape_props.md` | **INTEGRATED** → §08 |
| A05 | Design | QA / A-B harness | `reports/A05_qa_harness.md` | **INTEGRATED** → §12 |
| A06 | Design | Integration + rollback plan | `reports/A06_integration.md` | **INTEGRATED** → §12 |
| X01 | Binary | Bulk pseudo-C corpus of `cossacks.exe` | `reports/X01_decomp_corpus.md` | LANDED |
| X02 | Binary | Bulk pseudo-C corpus of `editor.exe` | `reports/X02_editor_corpus.md` | LANDED |
| X03 | Data | Verbatim donor DScript corpus by stage | `reports/X03_dscript_corpus.md` | **INTEGRATED** → §02/§07/§10 |
| X04 | Data | Extra donor text corpus | — (no report file on disk) | RUNNING |
| X05 | Data | Validate `pattern.lib` decoder prototype | `reports/X05_pattern_lib_validation.md` | LANDED |
| X06 | Data | Atlas contact-sheet / id visual audit | `reports/X06_atlas_visual_audit.md` | **INTEGRATED** → §06 |
| X07 | Data | Visual reference index | `reports/X07_visual_reference_index.md` | LANDED |
| X08 | Binary | Tile-smooth engine decode | `reports/X08_tile_smooth_engine.md` | LANDED |
| X09 | Data | Starting settings / presets | `reports/X09_starting_settings.md` | LANDED |
| X10 | Data | Extra donor schema | — (no report file on disk) | RUNNING |
| X11 | Data | Water translation | `reports/X11_water_translation.md` | LANDED |
| X12 | Binary | Stamp verification at opcode level | `reports/X12_stamp_verification.md` | **INTEGRATED** → §04 |
| X13 | Data | Blend test vectors | `reports/X13_blend_test_vectors.md` | **INTEGRATED** → §04 |
| X14 | Data | Evidence index | — (no report file; `spec/00_EVIDENCE_INDEX.md` is X14-owned and present) | RUNNING |
| X15 | Data | Asset manifest skeleton | `reports/X15_asset_manifest_skeleton.md` | LANDED |
| X16 | Data | Donor BaseName→converted mesh coverage ledger | `reports/X16_prop_mesh_coverage.md` | LANDED |
| X17 | Binary | `bmTransparency` blendfunc verification | `reports/X17_blendfunc_verification.md` | LANDED |
| X18 | Data | Mask channel verification | `reports/X18_mask_channel_verification.md` | **INTEGRATED** → §03 |
| X19 | Data | Mask decoder gap | `reports/X19_mask_decoder_gap.md` | **INTEGRATED** → §03 |
| X20 | Data | cfg decoder prototype | `reports/X20_cfg_decoder_prototype.md` | LANDED |
| X21 | Binary | RNG vectors | `reports/X21_rng_vectors.md` | LANDED |
| X22 | Data | Field sowing translation | `reports/X22_field_sowing_translation.md` | LANDED |
| X23 | Data | Corrected relief-grid byte verification (F01 5/5) | `reports/X23_corrected_relief_grids.md` | LANDED |
| X24 | Data | Editor parameter verification | `reports/X24_editor_param_verification.md` | LANDED |
| X25 | Data | Relief silhouette reference | `reports/X25_relief_silhouette_reference.md` | LANDED |
| X26 | Binary | Blend formula verification | `reports/X26_blend_formula_verification.md` | LANDED |
| X27 | Data | Decode coverage | `reports/X27_decode_coverage.md` | LANDED |
| X28 | Data | Shore tile vectors | `reports/X28_shore_tile_vectors.md` | LANDED |
| X29 | Data | Map placement semantics | `reports/X29_map_placement_semantics.md` | LANDED |
| X30 | Data | Season texture spec | `reports/X30_season_texture_spec.md` | LANDED |
| X31 | Binary | Packed-stub closeout (`.bind`/WUS1 coverage) | `reports/X31_packed_stub_closeout.md` | LANDED |
| X32 | Data | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| X33 | Data | Donor text coverage | `reports/X33_donor_text_coverage.md` | LANDED |
| V01 | Verify | Resolve A02's 16 UNVERIFIED constants | `reports/V01_unverified_resolution.md` | **INTEGRATED** → §07 |
| V02 | Verify | Resolve P06's open items | — (no report file on disk) | RUNNING |
| V03 | Verify | Resolve P06's 28 open items | `reports/V03_open_items_resolution.md` | LANDED |
| V04 | Verify | Working-tree conflicts / hashes / rollback | `reports/V04_tree_conflicts.md` | LANDED |
| V05 | Verify | Reconcile P01 vs A06 integration seams | `reports/V05_seam_reconciliation.md` | LANDED |
| V06 | Verify | Gate/capture remediation (stale JSON, unacked) | `reports/V06_gate_remediation.md` | LANDED |
| V07 | Verify | Relief asset readiness ledger | `reports/V07_relief_asset_readiness.md` | LANDED |
| V08 | Verify | Donor↔port coordinate/scale contract | `reports/V08_coordinate_scale.md` | LANDED |
| V09 | Verify | 2D order transplant | `reports/V09_2d_order_transplant.md` | LANDED |
| V10 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V11 | Verify | Ownership ledger (N-tickets) | `reports/V11_ownership_ledger.md` | LANDED |
| V12 | Verify | Resource spec corrections G1–G13 | `reports/V12_resource_spec.md` | **INTEGRATED** → §07 |
| V13 | Verify | Stale QA references | `reports/V13_stale_qa_refs.md` | LANDED |
| V14 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V15 | Verify | Acceptance without reference | `reports/V15_acceptance_without_reference.md` | LANDED |
| V16 | Verify | Contradiction register (27 clusters) | `reports/V16_contradiction_register.md` | LANDED |
| V17 | Verify | Spec readiness | `reports/V17_spec_readiness.md` | LANDED |
| V18 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V19 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V20 | Verify | Smoothing reconciliation | `reports/V20_smoothing_reconciliation.md` | LANDED |
| V21 | Verify | Gate register (52 rows) | `reports/V21_gate_register.md` | LANDED |
| V22 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V23 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V24 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V25 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V26 | Verify | Resolve V17's four material spec conflicts | `reports/V26_spec_conflicts_resolved.md` | LANDED |
| V27 | Verify | UNVERIFIED owners | `reports/V27_unverified_owners.md` | LANDED |
| V28 | Verify | Code review R1 | `reports/V28_code_review_r1.md` | LANDED |
| V29 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V30 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V31 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V32 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V33 | Verify | Do-not-do checklist | `reports/V33_do_not_do_checklist.md` | LANDED |
| V34 | Verify | Doc consistency | `reports/V34_doc_consistency.md` | LANDED |
| V35 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V36 | Verify | Integration checklist | `reports/V36_integration_checklist.md` | LANDED |
| V37 | Verify | Minor conflicts | `reports/V37_minor_conflicts.md` | LANDED |
| V38 | Verify | Code review R2 | `reports/V38_code_review_r2.md` | LANDED |
| V39 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V40 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V41 | Verify | Reserved (no evidence) | — (no report file on disk) | RUNNING |
| V42 | Verify | Gate commands | `reports/V42_gate_commands.md` | LANDED |
| V43 | Verify | Spec live re-verify notes (no report file; notes in spec/12,13,14) | — (no report file on disk) | RUNNING |
| V44 | Verify | Code review R3 | `reports/V44_code_review_r3.md` | LANDED |
| V45 | Verify | Board-refresh note (no report file) | — (no report file on disk) | RUNNING |
| I01 | Impl | cfg decoder | `variant3d/tools/decode_donor_cfg.py` (present) | RUNNING |
| I02 | Impl | `.pattern` decoder | `variant3d/tools/decode_donor_pattern.py` (present) | RUNNING |
| I03 | Impl | `pattern.lib` decoder | `variant3d/tools/decode_pattern_lib.py` (present) | RUNNING |
| I04 | Impl | mask decoder | `variant3d/tools/decode_donor_masks.py` (present) | RUNNING |
| I05 | Impl | atlas compiler | `variant3d/tools/build_terrain_new_atlas.py` (present) | RUNNING |
| I06 | Impl | SoA data container | `variant3d/scripts/terrain_donor_data.gd` (present) | RUNNING |
| I07 | Impl | stage pipeline | `variant3d/scripts/terrain_donor_gen.gd` (present; `terrain_donor_tiles.gd` absent) | RUNNING |
| I08 | Impl | mesh | `variant3d/scripts/terrain_donor_mesh.gd` (present) | RUNNING |
| I09 | Impl | props | `variant3d/scripts/terrain_donor_props.gd` (present) | RUNNING |
| I10 | Impl | shader ("only if needed") | `variant3d/shaders/terrain_donor_shader.gdshader` (present) | RUNNING |
| I11 | Impl | seam (I11-SEAM, two files) | `variant3d/scripts/main.gd` + `variant3d/scripts/world3d.gd` (both modified; `.bak-COORD-I11` present) | RUNNING |
| I12 | Impl | determinism test atom | `variant3d/tests/t_terrain_donor.gd` (present; not run) | RUNNING |
| I13 | Impl | QA/capture by COORD | `variant3d/tools/terrain_qa_harness.py` (N16, present) + `spec/terrain_qa_spec.json` (N17, present) + `inbox/qa/**` (N18/N19, pending) | RUNNING |
| I14 | Impl | No ticket definition found on disk | — (no report/ticket file found; do not invent an owner) | RUNNING |
| I15 | Impl | No ticket definition found on disk | — (no report/ticket file found; do not invent an owner) | RUNNING |
| I16 | Impl | Missing QA fixtures | `reports/I16_qa_fixtures.md` | LANDED (file presence; fail-closed report, no gate run) |
| V47 | Verify | FINAL single canonical contradiction register (43 rows) | `reports/V47_final_contradictions.md` | LANDED — canonical register |
| V48 | Verify | Paste-ready fix plan for V36's four hard API breaks | `reports/V48_api_fix_plan.md` | LANDED |
| V49 | Verify | Licence / CREDITS / private-use compliance audit | `reports/V49_licence_credits.md` | LANDED |
| V52 | Verify | Owner Q&A — what is decoded/built vs unproven | `reports/V52_owner_qa.md` | LANDED |
| V56 | Verify | Final read-only doc consistency check | `reports/V56_final_doc_check.md` | LANDED |
| V57 | Verify | FINAL parity statement (paste-ready) | `reports/V57_final_parity_statement.md` | LANDED — parity_claim=false |
| V58 | Verify | Read-only audit of I07 generator vs donor truth | `reports/V58_i07_audit.md` | LANDED |
| V59 | Verify | Read-only audit of I09 props vs donor truth | `reports/V59_i09_audit.md` | LANDED |
| V61 | Verify | Composer/API re-audit after fixes + shader rename | `reports/V61_composer_api_audit.md` | LANDED |
| V62 | Verify | Generated asset pack vs fresh-module load paths | `reports/V62_asset_completeness.md` | LANDED |
| X34 | Data | Independent 710/710 verification of F01 size law + grid offset | `reports/X34_size_law_verification.md` | LANDED |
| X35 | Data | Donor lighting/environment constants | `reports/X35_lighting_env_spec.md` | LANDED |
| X36 | Data | Second visual recheck: mountains/shore/mines | `reports/X36_mountain_visual_recheck.md` | LANDED |
| X39 | Data | Feasibility of a real donor GPU A/B frame | `reports/X39_ab_feasibility.md` | LANDED — no A/B frame exists |
| X49 | Data | Read-only audit of I02 grids vs X23 canonical tables | `reports/X49_i02_grid_audit.md` | LANDED |
| X54 | Data | One-page donor ground-truth card | `reports/X54_ground_truth_card.md` | LANDED |
| V53 | Verify | CLI reconciliation snapshot of the `terrain_new` asset pack | `reports/V53_cli_reconciliation.md` | LANDED |
| V60 | Verify | Audit of I04 mask decoder vs 9-point contract | `reports/V60_i04_audit.md` | LANDED |
| V63 | Verify | FINAL GO/NO-GO verdict for running Godot gates | `reports/V63_go_no_go.md` | LANDED — report only, no gate run |
| V64 | Verify | FINAL ownership / output-collision audit (I01–I13) | `reports/V64_ownership_final.md` | LANDED |
| V65 | Verify | Read-only verification of V48 caller-side patches | `reports/V65_patch_verification.md` | LANDED |
| V66 | Verify | FINAL asset-gap ledger for the fresh terrain module | `reports/V66_asset_gap_final.md` | LANDED |
| V76 | Verify | FINAL read-only gate preflight audit | `reports/V76_gate_preflight.md` | LANDED — no gate run |
| V81 | Verify | FINAL owner decision packet | `reports/V81_owner_decision_packet.md` | LANDED |
| X51 | Binary | FINAL pass closing remaining `[U]` items | `reports/X51_close_unknowns_pass.md` | LANDED |
| X56 | Data | Plateau generator DScripts — editor-authoring, deferred | `reports/X56_plateau_generator.md` | LANDED |
| V67 | Verify | Honesty check of owner-facing answer set | `reports/V67_owner_answer_check.md` | LANDED |
| V72 | Verify | FINAL decision memo for COORD / owner | `reports/V72_final_decision_memo.md` | LANDED |
| V83 | Verify | FINAL forbidden-construct scan of implementation tree | `reports/V83_final_forbidden_scan.md` | LANDED |
| X37 | Data | Golden blend vectors at F01 offsets, X26 formula (25 f32) | `reports/X37_golden_blend_vectors.md` | LANDED |
| V55 | Verify | Python-only preflight self-checks of six `terrain_new` tools | `reports/V55_python_preflight.md` | LANDED — Python checks, not gates |
| V87 | Verify | FINAL swarm statistics (launches/reports/assets/concurrency) | `reports/V87_swarm_statistics.md` | LANDED |
| V90 | Verify | FINAL static syntax seal on implementation files | `reports/V90_static_syntax_seal.md` | LANDED |
| V98 | Verify | FINAL CREDITS / .gitignore / donor-commit hygiene check | `reports/V98_credits_final.md` | LANDED |
| X44 | Data | Evidence-id integrity audit of spec/00–14 vs ledger | `reports/X44_evidence_integrity.md` | LANDED |
| X55 | Data | `postpatterns.cfg` decode — authored-map only, deferred | `reports/X55_postpatterns_decode.md` | LANDED |
| X57 | Data | `env.objects` / `objects.lib` / `envscales.cfg` decode | `reports/X57_env_objects_decode.md` | LANDED |

`RUNNING` on the I-wave follows the board's report-file rule: I01–I15 still have
no `reports/I*.md`; I16 now has one and is `LANDED`. Presence of an implementation
file is recorded, but does **not** make a ticket `LANDED`/`PASS`; see the gates
checklist below. `X04/X10/X14/X32` and `V02/V10/V14/V18–V19/V22–V25/V29–V30/
V32/V35/V39–V41/V43/V45` remain `RUNNING` solely because no report file exists
at the V74 glob — no assignment text is inferred beyond the filename evidence.
X14 has `spec/00_EVIDENCE_INDEX.md` but no `reports/X14*.md`; V43/V45 have
annotation/note evidence but no report file. At the final glob all 124 report
files then present had a board row and no board row named a missing file.
`LANDED` = file presence only: not READY, not a gate PASS, not donor parity.

**Snapshot caveat:** the 30-agent swarm continued to land reports throughout
this reconciliation. Any report id not in the table above landed *after* the
final glob and is not represented here; COORD must re-glob and add a row before
relying on "all landed". No such late row implies a gate result or parity.

## Landed reports → spec integration log

**All fifteen spec section files §00–§14 are present on disk** (V74 re-verified
by directory listing, consistent with V56's glob). This is a file-presence
statement only. `spec/README.md` still shows listed sections as `PENDING` and
V17/V26/V34 review reports remain point-in-time blockers — **no section is
marked READY by this board**, and no completion message in this log certifies a
gate result or donor parity. Below, every section §00–§14 is named explicitly,
and the late/correction reports V43, V46, X23, X26 and V47 are accounted for.

- §00 evidence index ← X14 (`spec/00_EVIDENCE_INDEX.md`, present; snapshot note says 56 landed reports at its read — now grown).
- §01 world data model ← A01 (+ V47-43 rejection of legacy height/albedo/face-promotion approaches).
- §02 seed/RNG ← D02 + X03 (V47-08/-40: verbatim identity re-seeds, `key0` discarded).
- §03 mask→height ← F04 + A02/X03/D06 + D03/X18/X19 (V47-09/-42: shipped B channel only, `B>=58` excluding white starts).
- §04 pattern stamping ← F02 + A02 + D05 + F01 + X12 + X13 + **X23** + **X26** + X34 (V47-22/-24 three-branch stamp and in-place post-pass; V47-39 `G=8+(w−1)(h−1)`; X23 confirms F01 5/5 and marks X13's 19 vectors stale).
- §05 water/shore ← D06 + F06 + A02 (V47-10/-32: five distinct water rows; X11's MISSING chain retained).
- §06 tile/atlas ← F05 + F06 + X06 (V47-36/-37: recovered blend factors; pass count `[U]`).
- §07 resources ← D07 + V01 + V12 (+ A02/X03/F02; V47-07/-11/-34: enum, shared ring bands, no food-rect stage).
- §08 fields/props ← A04 + F08 + F07 (V47-20/-21: evidence tiers, `i_mnt_*` scope; X16 mesh ledger landed).
- §09 editor parameters ← F03 (D09/F09 landed, not integrated into §09 text; V47-38: **19** flat keys, never invent a 20th).
- §10 stage order ← A02 + X03 (V47-19: 2D smooth→detail order; omit `_noise2` dither).
- §11 asset conversion ← A03 + P04 (F01/F02/F03/D05 contradictions preserved; V47-25/-26 section ends and `HeightFieldScale=0.65`).
- §12 QA/integration ← A05 + A06 (P03, V04/V05/V06/V11/V16 landed, not folded in; **V47** canonical register points here; V48/V61 API-fix audits landed, not applied).
- §13 prior-wave memory ← P06 (V47-18/-30: git/seam state is point-in-time, never paste "clean/unapplied").
- §14 current pipeline ← P01 (V47-43: legacy `HEIGHT_SCALE`/face promotion/`rgb*a` approaches rejected).
- **Correction/audit reports accounted for here (documentation only, no source/spec edit by this worker):** **V43** — live re-verify notes in `spec/12:24`, `spec/13:36`, `spec/14:35`; **no report file**. **V46** — HANDOFF refresh note; **no report file**. **X23** — `reports/X23_corrected_relief_grids.md`, F01 grids confirmed 5/5. **X26** — `reports/X26_blend_formula_verification.md`, three-branch stamp opcode pass. **V47** — `reports/V47_final_contradictions.md`, 43-row canonical deduplicated register (C9 upgraded OPEN → RESOLVED). V47's O-P re-adjudication trigger fired when X23 landed; the grid verdict is unchanged (F01 authority), but COORD/F01 own that check. None of these creates a gate PASS.
- Still to fold in (landed, no integration annotation): D01/D04/D08/D09, F09/F10, P02/P03/P05, V03–V17 (except V01/V12), V20/V21/V26/V27/V28/V33/V34/V36/V37/V38/V42/V44/V47–V90/V98, X01/X02/X05/X07–X11/X15/X17/X20–X22/X27–X31/X33–X37/X39/X44/X49/X51/X54–X57.
- **No pending spec *file*: §00–§14 all exist. Pending *work*: READY marking, stale-text reconciliation (V17/V26/V34/V36), V47 §5's 19 named OPEN items, and gate/capture evidence.**

## Contradiction register (COORD)

**Canonical register:** `reports/V47_final_contradictions.md` — the FINAL
deduplicated, single authoritative register (V47-01…V47-43). It supersedes the
old C1–C9 table, V16's 27 clusters, V26's 4 resolutions, V37's 3 minor conflicts
and V03 §4's 16 items; those are now historical navigation only. V47 **has
landed** (V56 found no V47 file; it landed afterwards). Verdict counts: **33
RESOLVED, 4 PRESERVED DONOR CONTRADICTION, 2 IMPLEMENTATION DECISION, 4
UNVERIFIED**, plus **19 genuinely OPEN items with named owners** in V47 §5. C9
is upgraded OPEN → RESOLVED (V47-09: authored DScript intent vs shipped mask
pixels). No cluster claims donor visual parity.

**Pointer chain:** canonical = V47 §3/§5 · paste-ready patch log =
`reports/V26_spec_conflicts_resolved.md` §2–§5 · `[U]` owner appendix =
`reports/V27_unverified_owners.md` §4.2 · gate map =
`reports/V21_gate_register.md`. COORD repoints; no worker edits another worker's
file. X23 has since landed and confirms F01's grids 5/5 (V47-39/O-P), so X13's
19 vectors are stale; no value was invented here.

**Top-5 (priority, not parity) from V47 §4 — rows that most change visible
relief / tile / field / water output:**

1. **V47-22 + V47-23** — the three-branch stamp (`cossacks.exe:0x755f30`, x87 `0x756607–0x7566d2`) drives every height write; **no `[Min,Max]` clamp**. Row-sign flip, global setter clamp and x87 80-bit residue stay `[U]`.
2. **V47-39** — grid authority is F01 `G=8+(w−1)(h−1)` (`hil1` 968); X13's shifted offsets are stale; X23 confirmed F01 5/5.
3. **V47-24** — in-place post-pass `sub_755db4` (hardcoded `/4.0`, 8-neighbour gate); double-buffer is `PORT APPROXIMATION`.
4. **V47-09 + V47-42** — shipped mask B is the only real height channel (`h=−1.1·B/255`); integer `B>=58` excluding white starts fixes the water boundary; never map R→height.
5. **V47-10** — four/five distinct water levels (`generatemap.inc:7,688`; `texturemap.inc:29-31`); collapsing them destroys basin/field/shore readability.

All port consequences remain `PORT APPROXIMATION`; parity `UNVERIFIED`. No gate
PASS is implied by any resolution above.

## Integration gates (COORD only)

**No gate has been run by this worker. No fresh capture exists. No parity claim
is made.** Every checkbox below is unchecked; a present file is evidence of
existence only, never of correctness, validation or PASS. The I11 seam switch
stays at default `"legacy"` (donor path opt-in only); nothing here flips it.

- [ ] **All reports landed and contradictions resolved.** Not met: at the V74
      final glob **124 report files** existed under `reports/**` and each had a
      board row; 11 former "no report" rows were corrected to `LANDED` and 37
      missing rows were added (125 → 162 board rows). File presence is not
      resolution: V47 §5 lists 19 OPEN items with named owners; V47-02/03/04/05
      stay PRESERVED and must not be silently "fixed". Counts are point-in-time
      — re-glob before relying on them.
- [ ] **Spec sections marked READY.** Not met: §00–§14 files all exist, but
      `spec/README.md` still says PENDING and V17 found no unconditional READY
      section; V26/V34/V36 identify stale text to reconcile. Nothing marked
      READY here.
- [ ] **Decoder tools landed and validated against donor bytes.** Partial:
      I01/I02/I03/I04/I05 decoder/compiler files are on disk; X23/X34/V49
      independently verified donor tables and the size law, but **no fresh byte
      validation run of the port tools exists** and no gate result was produced.
- [ ] **Fresh terrain module composed; gates green; `app/` unchanged.** Partial,
      unverified: I06/I07/I08/I09/I10/I12 modules, the I11 **two-file** seam and
      the N14 composer are on disk, with `main.gd`/`world3d.gd` at default
      `"legacy"`; no gate was run, `t_terrain_donor.gd` was not run, V58/V59/V61/
      V62 audits landed but are not applied fixes, and `app/**` was not
      re-verified (no git action by this worker).
- [ ] **Owner-facing capture + honest parity verdict.** Not met: no admissible
      240²/320² windowed capture; `inbox/qa/terrain_qa_report.json` and
      `inbox/qa/captures/` are absent (only PENDING markers exist). Parity
      status stays `UNVERIFIED`; no donor GPU A/B frame exists (X39 is a route
      audit only, not a frame).

### Filesystem inventory — implementation files (verified with `Test-Path`, multiple passes)

PRESENT: `variant3d/tools/decode_donor_cfg.py` (I01), `decode_donor_pattern.py`
(I02), `decode_pattern_lib.py` (I03), `decode_donor_masks.py` (I04),
`build_terrain_new_atlas.py` (I05), `terrain_qa_harness.py` (N16);
`variant3d/scripts/terrain_donor_data.gd` (I06), `terrain_donor_gen.gd` (I07),
`terrain_donor_mesh.gd` (I08), `terrain_donor_props.gd` (I09),
`terrain_donor_world.gd` (N14 composer), `main.gd` + `world3d.gd` (I11 seam);
`variant3d/shaders/terrain_donor_shader.gdshader` (I10);
`variant3d/tests/t_terrain_donor.gd` (I12); `inbox/backup/main.gd.bak-COORD-I11`
and `world3d.gd.bak-COORD-I11`; `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json`
(N17), `spec/00_EVIDENCE_INDEX.md` (X14); `inbox/qa/` directory with PENDING
markers only; **124 report files** under `reports/**` at the V74 final glob
(point-in-time — re-glob). Also PRESENT: **`variant3d/assets/terrain_new/` with
780 `.json` files**, including `cfg/manifest.json`, `cfg/constants.json` and
`patterns/family_index.json` (`cfg/` + `patterns/` tiers; **no `atlas/` tier**).
These are derived outputs: existence only, **no validation run, no byte check,
no gate PASS**.

ABSENT: `variant3d/tools/terrain_qa_spec.json` (the variant-local copy; N17 lives
in `spec/`), `variant3d/tools/validate_terrain_new.py` (N7),
`variant3d/scripts/terrain_donor_tiles.gd` (I07 second file, ownership still
undecided per V47-33), `variant3d/shaders/terrain_donor.gdshader` (the actual
present shader is `terrain_donor_shader.gdshader`), `inbox/qa/terrain_qa_report.json`
(N18), `inbox/qa/captures/` (N19), and **`variant3d/assets/terrain_new/atlas/`**
(the rendered tier — NOT the whole `terrain_new/**` tree, which is present but
unverified). No gate result JSON was verified fresh by this worker; do not read
any stale 2026-11-25 green JSON as current. No capture, no gate run, default
`"legacy"` seam, and no donor-parity claim.

## VISUAL WAVE (2026-11-26) — DOC-BOARD refresh

**Method / authority.** Filesystem-authoritative, read-only: two independent
`Get-ChildItem`/glob passes plus explicit `Test-Path` checks, then a third
re-check immediately before this edit. The set **grew between passes** —
`reports/PREP_VIDEO_assembly.md` was absent in passes 1–2 and present in pass 3 —
so the final re-check below is the frozen authority. Status rule: the listed
report/owner file on disk ⇒ `LANDED`; no file ⇒ `RUNNING`. `LANDED` here means
**file presence only** — not a gate PASS, not spec READY, not donor parity, not
an integration annotation. Findings are one-liners drawn from each file's
frontmatter / executive summary; nothing below is re-measured or re-run by this
worker. This worker ran no Godot job, capture, gate, git command or donor
execution; `app/**` was not re-verified.

| ID | Wave | Assignment / owner file | Status | Finding (frontmatter / executive summary) |
|---|---|---|---|---|
| W01 | VISUAL | `reports/W01_capture_visual_diff.md` | LANDED | Both 240b/240c are admissible nonblank 1280×720 GPU captures; 240b flat olive, 240c blocky terraced — direction-of-movement only, parity UNVERIFIED. |
| W02 | VISUAL | no report file on disk | RUNNING | — |
| W03 | VISUAL | `reports/W03_terrace_root_cause.md` | LANDED | Compound failure: wrong mask/grid size (320² mask for a 240² run) plus 2 m eye-space tile repeat/fract bands; alpha cleared, relief families never stamped. |
| W04 | VISUAL | no report file on disk (shader bytes read-only in HANDOFF §9.3) | RUNNING | — |
| W05 | VISUAL | `reports/W05_video_capture.md` | LANDED | Planned only: current `--seq` reads root viewport and can emit an 800×600 CPU map; SubViewport capture seam required; no capture run. |
| W06 | VISUAL | `reports/W06_performance_audit.md` | LANDED | Only clean donor baseline is ticket 636 at 45.555 s; JSON parse dominates startup; proposed port-internal ≤30 s median target, no valid FPS measurement. |
| W07 | VISUAL | `reports/W07_props_visual_audit.md` | LANDED | `_try_feed` never walks `sections[].blocks[].records[]` and rejects live `Stamp` Objects → 0 props; no donor light rig → black silhouettes. |
| W08 | VISUAL | `reports/W08_visual_acceptance_criteria.md` | LANDED | Tier-2 self-consistent visual criteria with G0-a…e admissibility; terraces/bands/silhouettes are FAIL artifacts; no donor A/B frame. |
| W09 | VISUAL | `reports/W09_usability_audit.md` | LANDED | Donor backend not usability-ready: 240² SIM vs 256² render grid, no light rig, picking/off-grid mismatch; camera constants donor-shaped but FOV is `PORT APPROXIMATION`. |
| W10 | VISUAL | `reports/W10_regression_status.md` | LANDED | Fresh ACKs + `t_map_variety` 638 5/5, but donor atom 639 FAIL 22/25 (vertex/triangle counts, synthetic-noise field); 240c stale after the 11:15:54 shader edit. |
| FIX-HEIGHT | VISUAL | no report/owner file on disk (COORD/I17 + I07, in flight) | RUNNING | — |
| FIX-PROPS | VISUAL | no report/owner file on disk (in flight) | RUNNING | — |
| CAP-VIDEO | VISUAL | no report/owner file on disk (in flight; atom planned in W05 §4.2) | RUNNING | — |
| FIX-ATOM | VISUAL | no report/owner file on disk | RUNNING | — |
| DOC-VIS | VISUAL | `HANDOFF.md` §9 (written by DOC-VIS) | LANDED | §9 records 240b flat / 240c terraced, the mask-size override and relief-grid key mismatch, no family placement, fixes in flight, parity UNVERIFIED. |
| VERIFY-HEIGHT | VISUAL | `reports/VERIFY_HEIGHT_fix.md` — absent on both passes | RUNNING | — |
| FIX-CONFIG | VISUAL | `reports/FIX_CONFIG_shape.md` | LANDED | W03 P2 confirmed: overlay sets `map_type=land` but omits `terrain_type`, so effective I17 shape is `mediterranean`; add `gameplay.terrain_type = "land"`. |
| PREP-VIDEO | VISUAL | `reports/PREP_VIDEO_assembly.md` (landed mid-refresh) | LANDED | Planned only: ffmpeg/ffprobe/Pillow present, exact MP4/contact-sheet packet; no capture and no MP4 assembled; exit-code-only MP4 check is a trap. |
| DOC-BOARD | VISUAL | `SWARM_BOARD.md` (this file, §VISUAL WAVE) | LANDED | This read-only board refresh: VISUAL WAVE rows plus the honest status box below; no gate result or parity claim asserted. |

### Current honest status (DOC-BOARD, point-in-time 2026-11-26)

> - **[O] Two donor-backend captures exist:** `cap_donor_240b.png` (flat olive field, black silhouettes) and `cap_donor_240c.png` (large blocky **terraced/stepped** surface with diagonal bands). Both are real nonblank 1280×720 GPU frames; 240c is **stale after the 11:15:54 shader edit** — direction of movement only, never a sign-off capture.
> - **[I]/[U] Diagnostic (owner/COORD-reported, not re-run here):** requested grid silently overridden by native mask size (64²→256²; same defect class at 240²), **relief-grid key mismatch** (`relief_float_grid` vs `grid`) that drops decoded stamp grids, and **no donor family placement** (`_setup_patterns_by_type()` draws names but never calls `_stamp_pattern()`), so relief contributes no height. Field-name seam needs re-verification against the captured build.
> - **[O] Fixes are in flight:** FIX-HEIGHT / FIX-PROPS / CAP-VIDEO / FIX-ATOM have **no landed owner file** at this pass; FIX-CONFIG and PREP-VIDEO have read-only reports only. No fix is certified by this board.
> - **[U] No donor A/B frame exists.** No donor GPU reference frame, no donor-match threshold, no parity score; **parity stays `UNVERIFIED`** and all claims are `PORT APPROXIMATION` / port-internal. No new gate result is claimed here — the fresh RED donor atom (639, 22/25) is reported by W10, not produced or re-adjudicated by this worker, and no §4 cell is filled.
> - **Rule reminder:** `LANDED` above = file presence only. It is not a gate PASS, not spec READY, not integration, and not donor fidelity. Re-glob before relying on the row set; reports were still landing during this edit.
