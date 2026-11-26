---
id: TERRAIN-SWARM-2026-11-26-REPORT-INDEX
title: "One-page navigation index — donor-first terrain swarm, 2026-11-26"
agent: V50 (read-only index worker); V77 (post-index coverage/link maintenance only)
owner_file: docs/terrain_swarm_2026-11-26/REPORT_INDEX.md
status: READ_ONLY_SNAPSHOT__NO_GATE_RUN__NO_DONOR_AB_FRAME__NO_PARITY_CLAIM
labels: [O, D, I, U, "PORT APPROXIMATION"]
snapshot_note: "Five filesystem passes at V77: report count drifted 102 → 116 → 123 → 127 while this index was written (concurrent swarm); variant3d/assets/terrain_new/** had 780 derived .json at V49/V56/V62 and 5,256 files / 786 .json at the final pass (atlas/, masks/, lib/ tiers since added, per V87). Counts are point-in-time — re-glob before relying on them. No source/asset/config/git/Godot/donor change; no gate run, no donor A/B frame, parity UNVERIFIED. File presence is evidence of existence only."
---

# REPORT INDEX — one page, donor-first terrain swarm (2026-11-26)

> **Read-only snapshot, refreshed at V77.** Every "settles" line below is drawn from that report's frontmatter / executive summary, not invented. Presence of a file is evidence of existence only — never of correctness, a gate PASS, or donor fidelity. Reports that landed after the V50 snapshot are added in §8 with source-derived one-liners; absent ids get no invented owner or claim. No donor parity claim anywhere in this index.

## CURRENT HONEST VERDICT (read before anything else)

| Fact | Honest state |
|---|---|
| Implementation + derived assets | **PRESENT, not validated.** I01–I13/I16 owner files, N14 composer and the canonical shader are on disk (I14/I15 have no ticket definition). `variant3d/assets/terrain_new/**` held **780 derived `.json` files** at V49/V56/V62 (`cfg/`, `patterns/` only, untracked); the final pass sees **5,256 files / 786 `.json`** with `atlas/`, `masks/`, `lib/` tiers now present (V87) — still unverified. **File presence ≠ correctness**: no byte validation, no gate PASS. |
| Gates | **No gate has been run for today's tree.** All result JSONs stale (2026-11-25); `assert_clean --json` is `DIRTY` (575/582/585 unacked); `inbox/qa/**` is PENDING-only (no `captures/`, no `terrain_qa_report.json`); no fresh 240²/320² baseline. All gate verdicts remain `TODO(COORD)`; V63/V76/V83 preflight verdicts are **NO-GO** (prerequisites, not gate results). |
| Donor A/B frame | **None exists.** 12 third-party stills are direction-only (X36 recheck found no natural mountain/high-relief silhouette); no matched-seed donor GPU frame, so `parity.status = "UNVERIFIED"`, `parity.claim = NONE`. |
| Parity | **UNVERIFIED for every landscape class.** No tier above 2 in the V15 vocabulary; all port visuals are `PORT APPROXIMATION`. `blocking_unverified` is non-empty ⇒ `RESULT IS NOT GOOD`. |
| Backend | **`terrain_backend` defaults to `"legacy"`** (`main.gd:125`, `world3d.gd:144`); only exact `"donor"` opts in; late switch refused. V61's re-audit found no remaining V36 API break after caller-side patches (V65 re-verified all four patches). This is a **static contract PASS, NOT a gate PASS — no streams proven and no gate has run**. Stay legacy until fresh gates pass — no donor default flip. |
| Multi-pass / counts | **Five listing passes at V77: 102 → 116 → 123 → 127 report files while this index was written (V50's 77→80 snapshot is stale); counts are point-in-time, re-glob before relying on them. The board's 125 worker slots / at-least-30 rule is a staffing rule, **not proof of 30 simultaneously live assistant sessions**; `LANDED` = file presence only, `RUNNING` = no report file at that snapshot.** All post-snapshot landings are indexed in §8. Absent at the final pass, no owner or claim invented: X04/X10/X14/X32/X50/X52/X58/X59, V02/V10/V14/V18–V19/V22–V25/V29–V32/V35/V43/V45–V46/V50–V51/V54/V68–V71/V73–V75/V77–V80/V82, I14/I15. |

## 1. Start here

| Doc | What it settles |
|---|---|
| `CHARTER.md` | Donor-first rule ("understand first, build second"), four evidence sources, 4 deliverables, mandatory labels, multi-pass-on-anomaly rule. |
| `HANDOFF.md` | Owner-facing DRAFT: broad decode, partly-built default-legacy module, gate cells all `TODO(COORD)`, no parity claim. |
| `SWARM_BOARD.md` | V45 filesystem-authoritative worker table, spec integration log, C1–C9 navigation index only (canonical register = V47, see §7), all five integration gates unchecked. |
| `README.md` / `IMPLEMENTATION_PLAN.md` | Cold entry point + decode→spec→toolchain→module→gate sequence; I01–I13 ticket board, owner paths, non-negotiable invariants. |
| `spec/README.md` | Spec map (§00–§14), label key, "no parity without a real GPU A/B frame". |
| `REPORT_INDEX.md` | This index — navigation plus the honest verdict box above. |

## 2. Donor decoded

**2a. Binary / Ghidra:** D01–D09, X01/X02/X12/X17/X31… (X31 landed after the V50 snapshot — see §8; no claim carried over from the absent state).

| ID | What it settles |
|---|---|
| D01 | "0 code xrefs" resolved: `X*` are Delphi RTTI unit names; 1,182 VMTs; `TXMapGenerator` et al anchored. |
| D02 | RNG is 32-bit LCG `s←s·0xFC0D+0x3C6EF35F mod 2³²` from `randkey0/1`; no engine `RandomInt`/`RandomFloat`. |
| D03 | Exact mask load path + donor relief formula + offline Gaussian blur; shipped `_gauss` masks have R=G=0. |
| D04 | `.map` block layout: u32 W/H, tag grid, f32 height ±2.964, 37-byte tile records; 2-float shortfall `[U]`. |
| D05 | Stamp `sub_755f30`: `Min` is scale pivot, `Max` never read, `Offset` additive, three blend modes. |
| D06 | Four water literals (−1.1/−0.5/−0.25/−0.1), 3-pass shore smoothing; `hmapTex` is an open parameter key. |
| D07 | Refutes per-ore radii; placement is ring→ore→256 angle tries; `FillOwnerMap` is a 160² 4-neighbour BFS. |
| D08 | 124 tile ids/season, 22-chain/118-group smoothing in text, `bmTransparency` blend factors from CODE. |
| D09 | `editor.exe` DFM/VMT forms, generation orchestrator `0x87b7ec`, cfg-key ↔ Edit-control map. |
| X01 | 18,918/18,918 `cossacks.exe` pseudo-C corpus; terrain-term grep is a negative result. |
| X02 | 22,384/22,384 `editor.exe` corpus; 54.7% garbled; terrain strings have 0 code xrefs. |
| X08 | `tilesmooth_scripts.cfg` parse reproduced; snapshot once → 3 H-then-V passes. |
| X12 | Opcode-level confirmation of D05's three paths + field→offset map; D05's mid-call-chain rejected. |
| X17 | `bmTransparency = glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)`; port `rgb*=mask` is approximation; pass count `[U]`. |
| X21 | Independent D02 LCG confirmation + f32 vectors; `key0` never affects any draw. |
| X23 | Confirms F01's five corrected grids 5/5 after four passes; all 19 X13 vectors stale. |
| X26 | D05 F4 authoritative; X13 Replace objection upheld; literal task formula refuted; X13 offsets stale. |
| X27 | Honest coverage headline: high terrain *data*, medium *code*, near-zero runtime *activity*. |
| X31 | Landed after snapshot ([X31_packed_stub_closeout.md](reports/X31_packed_stub_closeout.md)); see §8. |

**2b. Data formats:** F01–F10, X05/X08/X18/X19…

| ID | What it settles |
|---|---|
| F01 | `.pattern` byte closure 710/710; size `8+4wh+54(w−1)(h−1)`; true grid offset `8+(w−1)(h−1)`. |
| F02 | `pattern.lib` is a 30.3 MB plaintext DB, 680 sections; "known offsets" are 1-based line numbers. |
| F04 | 4,466 terrainmask TGAs inventoried; shipped pixels R=G=0 off starts; `h=−1.1·B/255`. |
| F05 | 124 tile ids/season vs 112 DDS; three-file id→picture chain; port atlas is 16×8. |
| F06 | Shader carries mask alpha; `bmTransparency` enum 1; fixed-function blend; `alphavert` is eye-linear. |
| F07 | No field pattern family exists; 7×7=49-node mill→field rule; port field states are approximation. |
| F08 | Forest families are dense authored clumps; `Freq` is a roulette weight; `foreststype:=0` override. |
| F10 | `dlcs/` holds no terrain-generation assets; 365 new masks live elsewhere. |
| X05 | F02 confirmed 680/680, 5/5 offsets, 12/12 grids bit-exact; one donor header anomaly. |
| X06 | F05 mapping confirmed; 124/124 winter rename; diagonal-vein lattice is broad, not one family. |
| X11 | Donor water shader structurally ported; `heightmapwaves0.tga` cannot be `hmapTex`; levels kept separate. |
| X13 | 19 blend vectors + 4 smooth snapshots, grid bit-exact at old offsets (now superseded by X23/X26). |
| X15 | `terrain_new/manifest/v1` schema + deterministic pack id; 214-file SHA-256 census. |
| X18 | Independently confirms F04 channel/start/height finding and non-vanilla tree counts. |
| X19 | Port's two mask decoders share no contract; BUG-1/BUG-2; A03 `masks/height/**` path missing. |
| X28 | Shore rule pinned verbatim from `texturemap.inc:426-611` + 35 deterministic vectors. |

**2c. cfg / scripts:** F03/F09/X03/X30/X35…

| ID | What it settles |
|---|---|
| F03 | Seven cfg files decoded; 20 global + 13 local keys; two contradictions preserved (6 vs 3 passes; cfg path). |
| F09 | DScript is passive text; `.aix` handler registries; `dogenerate.inc`→`generatemap.inc` chain; BMP import recovered. |
| X03 | Verbatim stage-cited corpus; canonical order; 11 `SetRandomKey` + 3 `SetRandomExtKey64` reseeds. |
| X09 | `startingsettings.cfg`: 19 presets, 61 ASCII start stamps, 276 legend entries; `X` = peasant start. |
| X20 | `decode_donor_cfg.py` prototype: 7/7 hashes, 15/16 counts pass — donor has 19 global keys, not 20. |
| X22 | `_unit_DoSeedWheat` 49-node sow routine translated; no RNG in routine; all callers commented `[U]`. |
| X30 | Three season values, two art sets; winter is an index-preserving name swap; desert entitlement is UI gating. |
| X35 | Landed after snapshot ([X35_lighting_env_spec.md](reports/X35_lighting_env_spec.md)); see §8. |

## 3. Port audit: P01–P06, V04/V05/V11/V13/V36/V48…

| ID | What it settles |
|---|---|
| P01 | Current pipeline = two disjoint producers + one renderer; `_generate_map()` dead; five RNG streams. |
| P02 | Asset tree 2,358 files / ~2.23 GB; atlas wired, decals/dmask unconsumed; relief hills a ready win. |
| P03 | Gate commands specified but **not run**; green JSONs stale; capture tools hardcode `app/`; 3 unacked jobs. |
| P04 | One genuine donor decoder exists; neither `.pattern` nor `pattern.lib` payload is decoded by legacy tools. |
| P05 | 2D `app/` reuse is logic-only (685 hardlinks); `game.gd` is closer to donor; pass order differs. |
| P06 | Rock "maze" is a 4-stage relay; flat relief = amplitude/footprint + missing geometry; albedo hypothesis refuted. |
| V04 | Three "uncommitted" edits were already committed at `e234ac9b`; only `docs/**` dirty. |
| V05 | P01/A06 seams complementary; authoritative 2-file seam; A06 safer, P01 safer on file count. |
| V07 | `terrainmesh1..4` converted but never QA-run; relief float windows not exported. |
| V08 | Donor `W` is a real cell count; 1 generator unit = 2 m; `DONOR_UNITS=160` flagged. |
| V09 | 2D smooth/detail transplant into a new file; donor-grounded pass-order differences listed. |
| V11 | One owner (`I11-SEAM`) for both seam files + N14 composer; canonical N-ticket path ledger. |
| V12 | Implementation-ready resource spec G1–G13; ring-indexed mines; no food rects. |
| V13 | GR-A24 hard fail: `t_relief_props_qa.gd:30` points at absent `terrainmesh_props.json`; 84/87 false positives. |
| V36 | Seam landed, backups hash-correct; 11/13 tickets present. V36 found four hard API breaks at its 09:52 snapshot; V48's caller-side patches are present and V61/V65 give **static PASS** on six pairs — **not a gate PASS, no streams proven**. Keep the legacy default until fresh gates pass — not because the breaks remain. |
| V48 | Landed after snapshot ([V48_api_fix_plan.md](reports/V48_api_fix_plan.md)); its four caller-side patches are verified present by V61/V65, **static only** (not a gate PASS, no streams proven); see §8. |

## 4. Design / spec: A01–A06, spec/00–§14

| ID | What it settles |
|---|---|
| A01 | SoA core = height/tex/collision[4]; grid 256/320/480/640; dump extended additively. |
| A02 | Canonical `DoGenerate` stage order; per-stage re-seeding; relief stamped, not synthesized. |
| A03 | Staged one-way offline compiler into `assets/terrain_new/**`; five derived asset classes + provenance. |
| A04 | Three coupled channels H/P/T; mountain grids all-zero so `terrainmeshN` props must be instanced. |
| A05 | Determinism + donor-grounded structural + visual A/B gate design; no parity claim. |
| A06 | Integration/rollback: two-file seam, config-driven legacy default, file-scoped rollback. |
| spec/00 | Evidence index of ids/paths (present; snapshot note stale at 56 reports). |
| spec/01 | Mandatory per-cell core from A01; six extra arrays optional and labelled. |
| spec/02 | `randkey0/1` schema + exact 32-bit LCG (D02/X03). |
| spec/03 | Mask→height: shipped-pixel truth (F04) reconciled with DScript intent by V26. |
| spec/04 | `pattern.lib` + stamp: F02/A02/D05/F01/X12/X13; three blend paths. |
| spec/05 | Water/shore: four levels, smoothing, alpha/blend; `hmapTex` left open. |
| spec/06 | 124 ids, smoothing rule, tile→block mapping, alpha masks. |
| spec/07 | Resources: ring-indexed mines, no food rects, `mapsize>2` = 256-cell tiny map. |
| spec/08 | Fields/props three-channel coverage and conversion gaps. |
| spec/09 | cfg inventory/grammar from F03 — V17's only point-in-time READY section. |
| spec/10 | Ordered stage pipeline from A02/X03. |
| spec/11 | Asset-conversion compiler shape from A03 + P04. |
| spec/12 | QA/integration; authoritative two-file seam at §12.1; A05/A06 gates. |
| spec/13 | Prior-wave root causes and rejected approaches (P06). |
| spec/14 | Current pipeline file:line trace and ownership boundary (P01). |

## 5. Implementation: I01–I16 — exact owner paths

| ID | Owner path | Settles / state (fresh `Test-Path`, file existence only) |
|---|---|---|
| I01 | `variant3d/tools/decode_donor_cfg.py` | Present; read-only `--check` exits 0 (V44). |
| I02 | `variant3d/tools/decode_donor_pattern.py` | Present; not byte-gated. |
| I03 | `variant3d/tools/decode_pattern_lib.py` | Present; V44 F-01 ownership breach remains OPEN/MAJOR. |
| I04 | `variant3d/tools/decode_donor_masks.py` | Present; not validated. |
| I05 | `variant3d/tools/build_terrain_new_atlas.py` | Present; `variant3d/assets/terrain_new/**` now exists, unverified. |
| I06 | `variant3d/scripts/terrain_donor_data.gd` | Present; stored height units `[U]` per V44. |
| I07 | `variant3d/scripts/terrain_donor_gen.gd` | Present; `terrain_donor_tiles.gd` still ABSENT. V58 audited all 2,042 lines: 11+3 reseeds, 3-of-4 grid offsets, zero collision writes (no gate run). |
| I08 | `variant3d/scripts/terrain_donor_mesh.gd` | Present. |
| I09 | `variant3d/scripts/terrain_donor_props.gd` | Present; no executable `DONOR_UNITS` remains (V44). |
| I10 | `variant3d/shaders/terrain_donor_shader.gdshader` | Present (V37 canonical name); old `terrain_donor.gdshader` absent. |
| I11 | `variant3d/scripts/main.gd` + `variant3d/scripts/world3d.gd` | Two-file additive seam; both `.bak-COORD-I11` backups present. |
| I12 | `variant3d/tests/t_terrain_donor.gd` | Present; not run; no manifest entry. |
| I13 | `variant3d/tools/terrain_qa_harness.py` + `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | N16/N17 present; `inbox/qa/**` real outputs pending; COORD-only. |
| I14 | — | No ticket definition on disk; do not invent an owner. |
| I15 | — | No ticket definition on disk; do not invent an owner. |
| I16 | `reports/I16_qa_fixtures.md` + `inbox/qa/PENDING_*` placeholders | Report LANDED (see §8); fail-closed audit; real N7/N18/N19 outputs still absent (PENDING markers only). |
| N14 | `variant3d/scripts/terrain_donor_world.gd` | Composer present; V36's four hard API breaks were patched caller-side and V61/V65 give static PASS on six pairs (**not a gate PASS; no streams proven**). Keep legacy default until fresh gates pass; decoded donor inputs remain unwired (`gen_params={}`). |

## 6. QA / acceptance: V15/V21/V42/V49/V56/V57, A05, P03/V06, X39

| ID | What it settles |
|---|---|
| V15 | Three-tier vocabulary; five no-reference classes stay UNVERIFIED; `blocking_unverified` non-empty ⇒ not good. |
| V21 | 52-row gate register, three classes; "nothing green"; exact `A′→D-0…D-6` order. |
| V42 | Copy-paste gate/capture packet; ACK syntax and runner flags re-read from source; no result asserted. |
| V49 | Landed after snapshot ([V49_licence_credits.md](reports/V49_licence_credits.md)); see §8. |
| V56 | Landed after snapshot ([V56_final_doc_check.md](reports/V56_final_doc_check.md)); index links PASS (existence), contradiction consolidation FAIL — see §8. |
| V57 | Landed after snapshot ([V57_final_parity_statement.md](reports/V57_final_parity_statement.md)); terrain not cloned; parity_claim=false, parity_status=UNVERIFIED — see §8. |
| X39 | Landed after snapshot ([X39_ab_feasibility.md](reports/X39_ab_feasibility.md)); donor GPU frame necessary but not sufficient for parity; no A/B exists — see §8. |
| A05 | Determinism + structural + visual A/B harness design (see §4). |
| P03 | Gate/capture tooling inventory (see §3). |
| V06 | Remediation plan only: five fresh unique-id jobs, ack 575/582/585, local tool overrides, 240²/320² baselines. |
| X07 | 12 third-party stills indexed; no mountains/sea/rivers/swamps/iron-coal; "highlands" a two-pass false positive. |
| I16 | Fail-closed QA placeholders only (see §5). |

## 7. Contradiction / decision trail — canonical register is V47 (C1–C9 navigation only)

**Canonical register:** [V47_final_contradictions.md](reports/V47_final_contradictions.md). V47-06 declares it the single authoritative register: **43 rows (33 RESOLVED / 4 PRESERVED DONOR CONTRADICTION / 2 IMPLEMENTATION DECISION / 4 UNVERIFIED)**, de-duplicating C1–C9, V16's 27 clusters, V26's 4, V37's 3, V03's 16 §4 items and X26. The former C1–C9 table in this index is replaced by this pointer; C1–C9 are folded into V47 as navigation only. 19 genuinely OPEN items carry named owners in V47 §5 (O-A…O-S). No verdict here is promoted to a gate PASS or donor parity.

C1→V47-01 · C2→V47-02 · C3→V47-03 · C4→V47-04 (PRESERVED — binary 18×23 is geometry authority) · C5→V47-05 · C6→V47-06 · C7→V47-07 · C8→V47-08 · **C9→V47-09 (RESOLVED — authored intent vs shipped pixels; board/V16 "OPEN" is stale)**.

| ID | What it settles |
|---|---|
| V16 | Historical 27 clusters: 14 RESOLVED, 9 PRESERVED, 4 OPEN; O1–O14 named owners — superseded as register by V47. |
| V26 | Four V17 conflicts resolved paste-ready: both-stage blend, no food rects, shipped-pixel truth, stale git text. |
| V37 | 19 cfg keys not 20; canonical shader name chosen; F01 corrected grid offsets outrank X13. |
| V47 | LANDED after snapshot — canonical register, see pointer above. |
| V01 | 10/16 A02 UNVERIFIED resolved; no donor key-derivation function; `gDataVersion=92`. |
| V03 | 1 CLOSED / 16 PARTIAL / 11 OPEN; no hard-evidence item closed. |
| V17 | No section unconditionally READY; §09 only point-in-time READY; stale/contradictory status texts. |
| V20 | Smoothing settled: snapshot once → 3 in-place H-then-V passes; three count sets = one object. |
| V27 | Every remaining `[U]` gets id, exact claim and named disposition; several labels already stale. |
| V28 | R1 review: three MAJOR findings + four tautological self-checks; no source edit. |
| V33 | 19 rejected approaches → forbidden patterns + static scan; six benign hits. |
| V34 | Board/spec/docs stale: 71 reports vs 43 board rows; spec README still says PENDING. |
| V44 | R3 review: V28 F-02/F-03 PASS, F-01 (I03 ownership) FAIL/MAJOR; no gate PASS, no parity. |

## 8. Reports that landed after the V50 index — source-derived one-liners

Five listing passes at V77 found 102 → 116 → 123 → 127 report files — 26 reports landed while this section was being written. Every row below is a file that exists on disk but had no row (or a stale "no report file" row) in the V50 index; each one-liner is taken from that report's own frontmatter / executive summary. **LANDED = file presence only**, never a gate PASS or donor parity. Ids with no file at the final pass (see verdict box) get no row and no invented claim; re-glob before relying on any count.

| ID (source file) | What it settles (one line, source-derived) |
|---|---|
| [X16](reports/X16_prop_mesh_coverage.md) | Donor BaseName → converted mesh coverage ledger for forest/stone/mine and relief props; "converted" = derived OBJ/PNG with provenance, not a rendered donor match. |
| [X24](reports/X24_editor_param_verification.md) | Independently verifies D09's editor VMT→handler anchors, 11 handler→cfg assignments and 24/24 + 13/13 control names; editor stage order is not skirmish truth. |
| [X25](reports/X25_relief_silhouette_reference.md) | Quantitative OBJ/JSON silhouette reference (orthographic contact sheets) for relief/tree/mine props; geometric internal check only, no GPU A/B. |
| [X29](reports/X29_map_placement_semantics.md) | Re-verifies the 37-byte tile record in 37 maps; on-disk height count `(W+1)^2−2`; `GameObjectBegin` placements after `TerrainMapEnd`; packed state `[U]`. |
| [X31](reports/X31_packed_stub_closeout.md) | Packer is a 146,800-byte `.bind` tail; a partial static decoder recovers the OEP; packed bytes hide no terrain code, remaining payload opaque. |
| [X33](reports/X33_donor_text_coverage.md) | 371/403 core-text files opened (92.1% of files, 67.9% of bytes) but only 25 verbatim-quotable; 279/308 non-mask terrain-named files unopened; 457-line residual `[U]`. |
| [X34](reports/X34_size_law_verification.md) | Independent 710/710 verification of F01's `.pattern` size law and five-region layout; corrected grid offset `G=8+(w−1)(h−1)`; no parity claim. |
| [X35](reports/X35_lighting_env_spec.md) | `light.cfg` is the sole active skirmish rig; donor terrain specular product is zero; I10 has no fog or shadow sampler; lighting alone does not explain flat olive albedo. |
| [X36](reports/X36_mountain_visual_recheck.md) | Re-opens all 12 donor stills with 25 temp-only crops; no natural mountain/high-relief silhouette; X07's central verdict survives; no A/B frame. |
| [X39](reports/X39_ab_feasibility.md) | A real donor GPU frame is necessary but not sufficient for parity; route/owner procedure audited read-only, no frame produced or fabricated. |
| [X49](reports/X49_i02_grid_audit.md) | Audits I02's `.pattern` decoder vs X23 tables: 5/5 items pass; task brief has a 2222/8225 label swap; I03 concurrent edit observed; no parity claim. |
| [X54](reports/X54_ground_truth_card.md) | One-page donor ground-truth card: LCG, `h=−1.1·B/255`, three blend paths, corrected grid offsets, in-place post-pass, four water levels, blend factors; two-document cross-read. |
| [V38](reports/V38_code_review_r2.md) | R2 static review: 13/16 canonical files + N17 present, six findings need attention, seam clean/additive with default legacy; no gate run or donor access. |
| [V47](reports/V47_final_contradictions.md) | Final canonical contradiction register — 43 rows (33 RESOLVED / 4 PRESERVED / 2 DECISION / 4 UNVERIFIED), C9 RESOLVED, 19 OPEN items with named owners. |
| [V48](reports/V48_api_fix_plan.md) | Paste-ready, text-only fix plan for V36's four composer API breaks; patches explicitly NOT applied by V48; no gate result or parity claim. |
| [V49](reports/V49_licence_credits.md) | Licence/CREDITS audit: 780 derived JSONs (242,316,351 B), 714 embed the private donor path (compliance defect), all 780 carry `visual_parity_claim:false`; `app/` untouched. |
| [V52](reports/V52_owner_qa.md) | Owner Q&A from landed reports only — decoded ≠ built ≠ proven; three-tier V15 vocabulary; no gate result, donor frame or parity claim. |
| [V56](reports/V56_final_doc_check.md) | Final read-only doc consistency check: index links PASS (existence), contradiction consolidation FAIL; 93 reports at its own final pass; no parity claim. |
| [V57](reports/V57_final_parity_statement.md) | Final parity statement: "terrain is not cloned"; `parity_claim=false`, `parity_status=UNVERIFIED`; no admissible capture or gate; no upgrade without a donor A/B frame. |
| [V58](reports/V58_i07_audit.md) | File:line audit of I07's 2,042 lines: 11+3 reseeds, 3-of-4 grid offsets, zero collision writes, shore/cliff selection defects; static only, no Godot. |
| [V61](reports/V61_composer_api_audit.md) | Re-audit after caller-side patches: no remaining V36 API break at final read (static PASS on six pairs — **not a gate PASS, no streams proven**); pre-patch FAIL passes preserved; no gate, capture or parity claim. |
| [V62](reports/V62_asset_completeness.md) | Asset completeness: 780 files / 242,316,351 B in `cfg/` + `patterns/`; no `atlas/`, `masks/`, schemas or root manifest; untracked, no I09-compatible feed key. |
| [I16](reports/I16_qa_fixtures.md) | Fail-closed QA fixture audit: report plus four `inbox/qa/**` PENDING placeholders; real N7/N18/N19 outputs absent; no Godot, runner, git or donor access. |
| [V53](reports/V53_cli_reconciliation.md) | Verified CLI reconciliation: six tools have six different CLI shapes; six `--dry-run --check` self-checks exit 0 (no writes); A03's documented CLI is stale in 14 places; no generation command executed. |
| [V59](reports/V59_i09_audit.md) | I09 props audit (7 items): PASS on cell-space distances and deterministic ordering; FAIL on live Objects feed, stale UNVERIFIED labels and the `build()`/`bind()` API seam; no Godot or parity claim. |
| [V60](reports/V60_i04_audit.md) | I04 mask decoder audited against the 9-point contract: 9/9 PASS (all 4,466 masks, TGA flips, `h=−1.1·B/255`, `B>=58`, R/G unresolved, no parity claim) plus six non-blocking observations. |
| [V63](reports/V63_go_no_go.md) | Final go/no-go for Godot gates: **NO-GO** on six blockers (dirty runner history, spec not READY, missing runtime asset tiers, broken gate atoms); no gate run and no PASS is a gate PASS. |
| [V64](reports/V64_ownership_final.md) | Final ownership/output-collision audit of I01–I13: no I03 completion note on disk, prior V44 F-01 state plus live source re-audited; no code/git/Godot/donor change. |
| [V65](reports/V65_patch_verification.md) | Verifies COORD's four applied V48 caller patches: all present and STATIC PASS on type/arity/contract, no flagged new bug; runtime parse, gate and determinism remain `[U]`. |
| [V66](reports/V66_asset_gap_final.md) | Final asset-gap ledger: 780 files (cfg=3, patterns=777, families=64), no atlas/masks/lib/schemas/root manifest; finding V66-F1 — I03 index at I09 path still yields zero props with a false feed label. |
| [V67](reports/V67_owner_answer_check.md) | Honesty check of V52/V57/HANDOFF/index: six owner claims HONEST with stale sub-claims (inertness, X39 disclaimer, old repairs); no class upgraded, no gate result, five passes. |
| [V72](reports/V72_final_decision_memo.md) | Final COORD decision memo: V47 canonical register, V63 go/no-go authority, V66 asset-gap authority, V81 owner packet; every prerequisite double-read, no gate result or parity. |
| [V76](reports/V76_gate_preflight.md) | Final gate preflight: **NO-GO** — do not run the V42 packet unchanged (five blockers B1–B5); spool/seam/app/patches/forbidden state PASS as static readiness only; no gate run. |
| [V81](reports/V81_owner_decision_packet.md) | Single owner-facing decision packet: quotes V57's "terrain is not cloned", consolidates V61/V62/V65/X36; nothing green, no gate run, no donor frame, `parity_status=UNVERIFIED`. |
| [V83](reports/V83_final_forbidden_scan.md) | Final forbidden-construct scan of 13 implementation files: 13 of 14 patterns clean; absolute donor paths in generated JSON remain a LIVE defect (V28 F-07) ⇒ single verdict **NO-GO**; no parity claim. |
| [X51](reports/X51_close_unknowns_pass.md) | Final `[U]` pass: `GenerateMapRandKey` signature recovered but body absent; `hmapTex` is key-registration only; no fixed blend pass count (field-driven at `+0x54`); several `[U]` items remain honestly open. |
| [X56](reports/X56_plateau_generator.md) | Plateau scripts located under `scripts/editor.inc/**` (not `data/scripts/**`); `plateaugenerator2.inc` is an editor-authoring state, DEFERRED for skirmish; no parity claim. |
| [V55](reports/V55_python_preflight.md) | Python-only preflight: all six tool self-checks exit 0 on the final pass (cfg 19/19, pattern 30/30 + 710/710 closure, masks 18/18, atlas 21/21, harness 36/36); one transient I03 edit re-run, no gate. |
| [V87](reports/V87_swarm_statistics.md) | Final dual-pass swarm statistics: 117 reports / 117 distinct ids at freeze; derived assets grew 780 → 5,255 files; board 125 → 151 rows; all counts file-presence only, no gate or parity. |
| [V90](reports/V90_static_syntax_seal.md) | Final static syntax seal: 13/13 implementation files STATIC PASS (6/6 Python parse, 6/6 GDScript structure, 1/1 shader syntax); Godot parse/smoke explicitly NOT run. |
| [X37](reports/X37_golden_blend_vectors.md) | 25 golden relief-blend vectors regenerated at F01-correct offsets with X26's formula, emitted only to temp; 19/19 old outputs changed by the stale-grid fix; vectors outside the repo, no parity claim. |
| [X44](reports/X44_evidence_integrity.md) | Evidence-id integrity: 289 cited ids / 366 citations vs 1,191-record frozen ledger; 288 exact matches, one one-character typo in X17; three coverage divergences preserved as text-only fixes. |
| [X55](reports/X55_postpatterns_decode.md) | `postpatterns.cfg` decoded (51 missions / 1,911 placement records, four keys, no weights); sole consumer gated `(cPostStandPatterns) and (not bRandomMap)` ⇒ authored-map only, DEFERRED for skirmish. |
| [X57](reports/X57_env_objects_decode.md) | `env.objects` / `objects.lib` / `envscales.cfg` formats, record counts and call sites decoded read-only; donor `.inc` text is intent only, runtime activation UNVERIFIED; no parity claim. |
| [V86](reports/V86_final_go_no_go.md) | Final GO/NO-GO re-audit against CURRENT bytes (V63/V66/V76/V83 landed mid-read): each prerequisite re-read, no verdict inherited; PASS = static prerequisite only, no gate run. |
| [V95](reports/V95_registration_verification.md) | Static verification of COORD's B2/B3: 5/5 PASS — valid 41-test manifest with I12 last, only `t_relief_props_qa.gd:30` changed, no thresholds moved, `app/**` byte-clean; no gate. |
| [V98](reports/V98_credits_final.md) | Final CREDITS/`.gitignore`/donor-commit verification: V72's "CREDITS missing" state overtaken by a later write; read-only two-instrument re-check; no code, git, Godot or parity claim. |
| [X59](reports/X59_donor_bytes_seal.md) | Donor-bytes seal: 906 new/untracked + 20 other untracked + 5 modified + 4 legacy files hashed against 17,237 donor files (14,546 unique hashes) — zero identical; no raw donor binary copied today. |
| [X67](reports/X67_envscales_decode.md) | `envscales.cfg` located at `data/game/var/` (not `data/env/**`), decoded as 26 groups / 122 per-object prop-scale records; DEFERRED for terrain shading/I10; no parity claim. |

*End of V77 index update. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/REPORT_INDEX.md`). No source, shader, config, asset, test, result JSON, git, Godot or donor change; no gate run, no donor A/B frame and no donor-parity claim.*
