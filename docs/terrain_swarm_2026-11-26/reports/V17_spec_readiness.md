---
id: V17
ticket: TERRAIN-SWARM-2026-11-26 / V17 — assembled-SPEC readiness audit (READ-ONLY)
agent: V17 (spec-coherence worker; donor-first terrain swarm 2026-11-26)
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_SPEC_EDIT__NO_CODE_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/V17_spec_readiness.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; this audit judges only internal coherence and implementation readiness of the assembled SPEC. Every port consequence is PORT APPROXIMATION / [U]."
scope: "Read CHARTER.md, SWARM_BOARD.md, IMPLEMENTATION_PLAN.md, spec/README.md and all spec files 00–14 present at read; cross-read the cited reports (A01, A02, D05, D06, D07, F03, F04, P06, V01, V05, V11, V12, V16, X03, plus V04/V06) with multiple passes on every section disagreement. No spec/report/source/asset/test/git change."
snapshot_note: "Reports D02, D03, F07, V01, V16, X08 and spec files 02 and 03 LANDED during this audit. Verdicts are point-in-time at the final directory read; COORD must re-check the register before dispatch."
---

# V17 — Assembled SPEC readiness audit

## 0. Executive summary

1. **[O] No section of the assembled SPEC is unconditionally READY for implementation dispatch in the strict sense of `IMPLEMENTATION_PLAN.md:3` ("Do not start until the cited spec sections are marked READY")**: `spec/00_EVIDENCE_INDEX.md` does not exist, and none of the section files carries a READY marker. `spec/09_EDITOR_PARAMETERS.md` is the only section whose cited content is internally complete for its ticket scope (I01). All other sections are NEEDS_WORK for either a missing report, an un-integrated landed report, or an unresolved cross-section conflict.
2. **[O] The ten coherence checks requested by COORD resolve as follows.** §01/§04/§05/§07/§09/§10/§12/§13 largely agree at the *fact* level, but three of them contain stale or contradictory *status*: (a) §04 §6 ([O] D05 blend math) vs §10 §2/§4 (still `[U]` blend math); (b) §07 §1/§2 and §10 §2 vs V12/V01 (food-rect claim refuted; `mapsize>2` is the 256-cell tiny map, not the current band); (c) §12 §12.1/§12.4 vs §13 §4/§14 §5 (stale git/seam premise). §05's three water levels agree with §01 §3 and §10 §2 on −1.1/−0.25/−0.1, with §05 adding the −0.5 generated-field Y. §07's ring bands agree with §10 §2 "indexed by round" but inherit the gating mislabel.
3. **[O] §03 (landed mid-audit) introduces a NEW cross-section conflict**: F04 measured R=0/G=0 on every non-start pixel of all 1,331 vanilla masks and `h = −1.1·B/255` (`reports/F04_masks.md §5–§6`), while §01 §3, §04 §3 and §10 §2 still treat R/G relief-class codes as donor-confirmed live semantics. §03 §1 demotes them to `[U]` pending V16/X19; V16-22 is **OPEN**, and V16/X19/X18 are cited as reconcilers (V16 has landed; X18/X19 have not).
4. **[O] Orphan claims to reports that do not exist**: `X12` (§04 §6/§7 native-stamp verification), `X09` (§07 §1/§4/§6 start presets/masks), `X18`/`X19` (§03 §1/§5 channel verification), `V03` (§13 §4 open-item resolution). `V12`, `V11`, `V06`, `V01`, `V16`, `D08`, `F04`, `F08`, `F07`, `D02`, `D03`, `D09` have all landed on disk but are **not integrated into the spec text** — they are stale citations, not orphans.
5. **[D] Every ticket I01–I13 has at least one spec dependency that is NEEDS_WORK in the strict sense; none is a clean GO today.** Recommended dispatch is I01 → I03 → I06 → I04/I05 → I02(after F01) → I07(critical-path, NO-GO) → I08/I09/I10 → I11 → I12 → I13, with COORD integration of V12/V01/V16/V11/V06 and creation of spec §00 as Pass 0. No parity claim is made or implied by any readiness verdict.

## 1. Evidence table (multiple passes recorded)

| # | Source re-read | Passes | Establishes | Label |
|---|---|---|---|---|
| E1 | `CHARTER.md §2,§4,§6`; `SWARM_BOARD.md §7–78`; `IMPLEMENTATION_PLAN.md §7–37` | 1 full + 1 targeted re-read | Mandatory labels, no-parity rule, one-report ownership, ticket dependencies, authoritative seam C1 | [O] |
| E2 | `spec/README.md`; all 15 spec files present at final read | 2 (initial glob + final glob; §02/§03 re-read after landing) | §00 missing; §02/§03 landed mid-audit; no READY marker anywhere | [O] |
| E3 | `spec/01_WORLD_DATA_MODEL.md §1–§5`; `reports/A01_data_model.md §0,§2–§9` | 2 | Core SoA triple [O]; stride/collision width/row sign/TILE_M/owner/resource_id [U]; A01 §8 assigns D01–D08 | [O]/[U] |
| E4 | `spec/04_PATTERN_STAMPING.md §1–§7`; `reports/D05_relief_stamp.md §F2–F6, UNVERIFIED register` | 2 (§3 `[U]` vs §6 `[O]` re-read before verdict) | D05 blend math authoritative; §3 stale `[U]`; row-flip/global clamp/rotation `[U]`; X12 orphan | [O]/[U] |
| E5 | `spec/05_WATER_SHORE.md §1–§8`; `reports/D06_water_shore.md §3–§11` | 2 | Four literal levels (−1.1, −0.5, −0.25, −0.1) + shader plane Y `[U]`; §05 agrees with §01/§10 on three shared levels | [O]/[U] |
| E6 | `spec/07_RESOURCES.md §1–§6`; `reports/D07_resources_bin.md §3.2–3.11`; `reports/V12_resource_spec.md §0–§6` | 3 (spec → V12 → raw donor citations via D07) | Ring bands [O]; V12 landed with corrections (C-V1…C-V9); spec §07 still says "V12 pending"; X09 orphan | [O]/[D] |
| E7 | `spec/09_EDITOR_PARAMETERS.md §1–§6`; `reports/F03_gen_config.md §0,§4,§9` | 2 | Two donor contradictions (6 vs 3; cfg path vs script) preserved; F03 complete; D09 landed but not integrated | [O]/[D] |
| E8 | `spec/10_STAGE_ORDER.md §1–§5`; `reports/X03_dscript_corpus.md §1,§2b,§6`; `reports/V01_unverified_resolution.md §0–§2` | 3 (§2 table vs §5 X03, then V01) | 11+3 reseed sites; 5 A1–A5 contradictions; A02's 5-site list stale; V01 resolves 10/16 `[U]` but not integrated | [O]/[D] |
| E9 | `spec/12_QA_AND_INTEGRATION.md §12.1–12.7`; `reports/V05_seam_reconciliation.md §4–§6`; `reports/V11_ownership_ledger.md §2–§7`; `reports/V04_tree_conflicts.md §1,§5`; `reports/V06_gate_remediation.md §0,§4` | 4 (seam authority re-read in spec, V05, V11, V04) | Authoritative two-file seam [D] confirmed; ownership paper-resolved; git state stale in §12.1/§13/§14; V06 remediation not integrated | [O]/[D]/[U] |
| E10 | `spec/13_PRIOR_WAVE_MEMORY.md §1–§5`; `reports/P06_prior_wave_distill.md §§1A–§8`; `spec/14_CURRENT_PIPELINE.md §1–§5` | 3 | 4-stage maze relay, 12 ranked rejections, 28 open items agree; §13 §4 "3 uncommitted changes" stale; §14 §5 "V05 when landed" stale | [O]/[D] |
| E11 | `spec/03_MASK_TO_HEIGHT.md §1–§5`; `reports/F04_masks.md §5–§11`; `reports/V16_contradiction_register.md §2 V16-22/O5` | 3 (§03 → F04 → V16) | F04 pixel facts [O]; R/G class semantics conflict is OPEN; X18/X19 absent | [O]/[U] |
| E12 | `spec/02_SEED_AND_RNG.md §1–§5`; `reports/D02_seed_rng.md`; V01 §1 item 3 | 2 | LCG exact; key derivation is *donor-absent* (V01), so §02 §1 `[U]` must be reworded, not implemented | [O]/[D] |
| E13 | Directory globs of `reports/*.md` and `spec/*.md` at start and at end of audit | 2 | No X09/X12/X18/X19/V03 file; no `00_EVIDENCE_INDEX.md`; D02/D03/F07/V01/V16/X08/§02/§03 landed mid-audit | [O] |

## 2. Per-section readiness table

Legend: **READY** = internally coherent, no missing dependency for the cited ticket scope; **NEEDS_WORK** = file exists but a named report/ integration/open conflict blocks dispatch; **PENDING** = file absent. "Report to land" distinguishes *MUST LAND* (file absent) from *LANDED → COORD INTEGRATE*.

| § | File / topic | Status | Exact reason (spec file:section) | Report that must land / action |
|---|---|---|---|---|
| 00 | `00_EVIDENCE_INDEX.md` | **PENDING** | File absent; `spec/README.md:16` still PENDING; no consolidated evidence-id index exists. | COORD assembly (no worker report). Blocking only the final sign-off, not individual decoders. |
| 01 | World data model | **NEEDS_WORK** | Core triple coherent (`spec/01 §1`, §4 dump contract), but `[U]` field order/stride, collision width, 2× grid, owner, row sign, TILE_M, resource_id; §5 cross-check queue omits D03/D05 row-sign assignment and still lists F04 as pending although F04 landed. §3 "mask R=terrain class, G=forest" now conflicts with F04 pixel facts. | **D04 MUST LAND** (absent) for stride/collision/owner; D03/D05 landed → integrate; V16-22/F04 resolution for mask channels. |
| 02 | Seed and RNG | **NEEDS_WORK** | LCG and 11+3 reseed sites coherent (`spec/02 §2,§4`). §1 "key derivation `[U]`" is now contradicted by V01: no donor derivation function exists (all stages restart `randkey1` verbatim). Save-map key bytes / instance class identities `[U]` unassigned. | **V01 LANDED → integrate**; D02 key→state `[U]` accepted with label; no report must land for I07's ledger. |
| 03 | Mask → height | **NEEDS_WORK** | §1 F04 vs A02 R/G contradiction explicitly OPEN (`spec/03 §1`, V16-22). §5 cites X18/X19 (absent) and V16 (landed, not integrated). D03 landed but § header still says "D03 pending"; forest/stone density `[U]` (§4) relies on F08 (landed, not integrated). | **X18/X19 MUST LAND or be retired**; D03/V16/F08 integrate; V16 O5 owner = F04 now landed. |
| 04 | Pattern stamping | **NEEDS_WORK** | §3 still calls blend math `[U]` while §6 (D05) is `[O]` and authoritative; `m_swamp_12_old` `[U]` (§1,§4) unreconciled; float-plane start ±24–160 B (D05 U5); row-flip/global clamp/rotation `[U]` cited to **X12** (absent); V16 OPEN O1 header policy. | **F01 MUST LAND** (exact `.pattern` byte layout); X12 retire; V16 O1 assign to I02/I03; D05/V16 integrate. |
| 05 | Water and shore | **NEEDS_WORK** | Fact core coherent and corroborated by §09 §4, §10 §2, V16-06. Unassigned `[U]`: −0.5 runtime, bmTransparency factors/pass count, ford rule, hmapTex binding/FBO, shader plane Y, metres-per-cell (D06 register items 1–10 no named ticket). X11 landed but not integrated; V16 O11 OPEN. | **D08 + COORD decision** for missing water stages (V16 O11); V16/X11 integrate; no orphan report blocks the three-level table itself. |
| 06 | Tile and atlas | **NEEDS_WORK** | §1–§4 coherent (124 ids, no remap, mill fields as decals). §5 cross-check queue still lists F03/F06 as pending although both landed and integrated in §09/§05; live selection rules `[U]` depend on **D08 (landed, not integrated)**; D04 tile ids `[U]`; F10 desert aliases absent. | **D08/F10** integrate/land; D04 MUST LAND for `.map` tile records; V16-05 alphanull 86/110/123 fold-in. |
| 07 | Resources | **NEEDS_WORK** | D07 ring bands [O] agree with §10 §2 "by round", but §1 header says "V12/X09 pending" although V12 landed with corrections; §1 "current band v≥80, mapsize>2" is now reversed by V01 (`mapsize>2` = 256 tiny); §3 shore citation `:1557-1564` corrected by V12 to `:1568-1581`; "ring 4/5 skipped" vs V12 `continue`; deposit amount `[U]` assigned to **X09** (absent). | **V12 LANDED → integrate**; **V01 LANDED → integrate**; **X09 MUST LAND or retire**; F08 (landed) integrate. |
| 08 | Fields and props | **NEEDS_WORK** | Three-channel finding (§1) coherent with §04/§06. §4 field/mine placement still PORT APPROX "until F07/F08/D07 land" — F07/F08 **landed**, not integrated; V07 (landed) not integrated; X07/A04 still-domain distinction OPEN in V16-12; V01 §1 item 6 clarifies `envfieldd` decal binding. | **F07/F08/V07/V01/V16 integrate**; no report must land for silhouette props. |
| 09 | Editor parameters / cfg | **READY** | F03 complete and internally consistent: 20 global keys, 13 local keys, two preserved donor contradictions (`spec/09 §4`) that exactly match `spec/05 §2` and SWARM_BOARD C2/C3 and V16-02/03. I01's cited scope needs no other report. | D09 (landed) only affects the optional editor-UI map, not I01. COORD mark READY. |
| 10 | Stage order | **NEEDS_WORK** | Canonical 12-item order and 11 re-seed sites correct (`§5`), but §2 determinism row still uses A02's 5/7-site subset; §2 "guaranteed food rects in SetupStartingResources" refuted by V12 C-V4/D07; §2/§4 still `[U]` blend math refuted by D05; §4's "16 `[U]` → V01" report has landed (10 resolved, 3 partial, 3 remain). | **V01/V12/D05/V16 LANDED → integrate**; V16 O8–O10 named; X03 already integrated. |
| 11 | Asset conversion | **NEEDS_WORK** | Shape/invariants coherent (`§11.1`), but §3 relief grid/object tail `[U]` owned by F01 (absent) and D05 (landed); desert season F10 (absent); atlas downsample `[U]` unassigned; V16 O26 `terrain_new_assets.gd` unowned. | **F01 MUST LAND**; **F10** for desert; V16 O6 owner decision (COORD/I06). |
| 12 | QA and integration | **NEEDS_WORK** | Authoritative seam §12.1 matches V05 exactly; §12.4 matches V04. But §12.1 still says "V04 report pending", §12.4 "V11 is assigning one owner per file" (V11 landed with ledger); V06 remediation (3 unacked failures, stale JSONs) not integrated; PLAN I11 wording narrower than the two-file seam; V16 fold-in not done. | **V04/V05/V06/V11/V16 LANDED → integrate**; V16 O3/O4/O14 decision; COORD confirmation of `COORD-I11`. |
| 13 | Prior-wave memory | **NEEDS_WORK** | Root-cause chain and rejected approaches agree with §10 §3 and §14 §4. §4 "3 uncommitted changes" is the stale premise V04/V05/V11/V16-10 supersede; 28 open items cite V03 (absent). | **V03 MUST LAND or be retired**; V04/V16 integrate. |
| 14 | Current pipeline | **NEEDS_WORK** | P01 legacy trace [O] sound. §5 still says "V05 is reconciling … see report when landed" although V05 landed and §12 §12.1 is authoritative. Integration debt only. | **V05/V16 integrate**; no report must land. |

## 3. Cross-section conflicts (multiple-pass verdicts)

Each conflict below was re-read in **both** spec sections **and** the cited report before a verdict was recorded. "Stale integration" means the fact is correct but the spec text was not updated after the report landed. "Conflict" means two live section statements cannot both be implemented as written.

| # | Sections / reports (passes) | Conflict | Verdict | Required resolution |
|---|---|---|---|---|
| X1 | §04 §3 vs §04 §6; §10 §2/§4; D05 E11 (3 passes) | A02 blend math `[U]` vs D05 `[O]` three-branch math (Min pivot, Max unused, Offset additive). | **Conflict (stale)**. §04 §6 is authoritative; §04 §3 and §10 §2/§4 must be relabelled superseded. Not a donor contradiction. | COORD fold V16-15 into §10; keep row-flip/global clamp `[U]`. |
| X2 | §07 §2; §10 §2; V12 C-V4; D07 §3.6; V01 §1 item 6 (3 passes) | §10 §2 "Starting resources … | port food rects" vs §07 §2 and V12: **no food rects** in `SetupStartingResources`; fields are mill-seeded. | **Conflict (stale)**. D07/V12/V01 authoritative; §10 §2 row must be struck or relabelled `[U]`/refuted. V12 red gate G9. | COORD integrate V12; §10 §2 correction before I07. |
| X3 | §07 §1/§3; D07 §3.3; V12 §3.2; V01 P4/EV08 (3 passes) | §07 calls `v≥80, mapsize>2` the "current band"; V01 shows `mapsize>2` = mapsize 3 = **256 tiny** (`donewgame.inc:46`); default 320/480/640 maps use `mapsize<=2` rows. "Ring 4/5 skipped" vs V12 "continue consumes name draw". | **Conflict (new, unresolved in spec)**. §07 §1 mislabels the active band; V12 §3.2 avoids the semantic label but still calls it "large-map row" in §5.1. | COORD: record numeric gate literally, attach V01 enum, label both rows by actual map size; apply V12 C-V7 continue semantics. |
| X4 | §07 §3; V12 C-V2 (2 passes) | Shore-prefill citation `dogenerate.inc:1557-1564` vs V12/D06/X03 `:1568-1581`. | **Conflict (citation)**. V12/D06/X03 authoritative; §07 §3 mis-citation. | Fix citation in §07 §3; V12 §6 item 4. |
| X5 | §01 §3, §04 §3, §10 §2 vs §03 §1; F04 §5–§6; V16-22/O5 (3 passes) | R/G relief-class codes treated as live donor semantics vs F04 observed R=G=0 on all 1,331 vanilla non-start pixels, `h=−1.1·B/255`. | **Conflict (OPEN)**. Both are true at different layers: script *intent* (`generatemap.inc:454-485`) vs shipped *pixel data*. §03 demotes class semantics to `[U]`; §01/§10 do not. | V16 O5/F04: store raw R with `ENGINE/UNVERIFIED`; never map R→height for shipped masks; COORD align §01 §3/§10 §2 wording with §03 §1. |
| X6 | §12 §12.1 ("V04 report pending"), §12 §12.4 ("V11 is assigning"), §13 §4 ("3 uncommitted changes"), §14 §5 ("V05 when landed") vs V04/V05/V11/V16-10/23 (4 passes) | Stale git/seam status repeated in four places; V04/V05/V11 agree HEAD `e234ac9b`, tree clean, seam unapplied, one owner assigned on paper. | **Conflict (stale integration)**. V04/V05/V11 authoritative; §12 §12.4 is already labelled "V04 supersedes the stale premise" but §12.1, §13 and §14 were not updated. | COORD doc update per V16-23; reserve `COORD-I11`; do not re-apply Y08b/Y10/Y11. |
| X7 | `IMPLEMENTATION_PLAN.md:19` (I11 = `world3d.gd` seam only) vs §12 §12.1 (two files) and V11 CR2 (4 passes) | Ticket board names one file; spec/authoritative seam requires `main.gd` + `world3d.gd`. | **Conflict (plan vs spec)**. V11 CR2 resolves in favour of spec (`§12` governs); PLAN text not updated. | COORD widen I11 to I11-SEAM and add I11-COMPOSER (N14) before dispatch. |
| X8 | §05 §1/§2 vs §01 §3, §10 §2; D06 §3.1; V16-06 (2 passes) | "Three water levels" vs four literals + shader plane Y. | **No conflict** (all true): −1.1 basin / −0.5 field / −0.25 water / −0.1 shore; shader plane Y `[U]`. §01/§10 omit −0.5 (harmless omission). §05 §4 `∨` notation is sloppy but equivalent to D06's `elif` chain (union = h<−0.1). | Record five rows in §01/§10 per V16-06; no algorithm change. |
| X9 | §09 §4 vs §05 §2 vs SWARM_BOARD C2/C3 vs V16-02/03 (2 passes) | `TileSmoothPasses=6`/`tilesmooth.cfg` vs script `3`/`tilesmooth_scripts.cfg`. | **No conflict — preserved donor contradiction**, coherent across all sections. Use script; carry literals as provenance. | Keep as anomaly; never promote `6` to donor truth. |
| X10 | §07 ring bands vs §10 §2 "mines indexed by round" vs V16-07; §13 §2 vs §10 §3 rejected lists (2 passes) | Ring-vs-ore grouping; 12 vs "12 hacks" lists. | **No conflict**: ring grouping authoritative; §13 §2 names 6 of P06 §6's 12 (full list cited), §10 §3 enumerates 12 — same policy set, differing granularity. Minor: §13 says H03/H05/H04 refutations (3), §10 §3 says H03/H05 (2). | No action except optional wording harmonisation. |

## 4. Orphan claims and stale citations

| Claim (spec file:section) | Cited report | On disk? | Class | Action |
|---|---|---|---|---|
| §04 §6 "X12 is independently verifying the function"; §4 §7 cross-check queue | `X12` | **No** — absent from reports/ and SWARM_BOARD | **ORPHAN** | Retire or assign a named worker; do not let row-flip/global-clamp `[U]` sit on a phantom ticket. |
| §07 §1/§4/§6 "V12 will recommend", "X09 investigates", cross-check queue | `V12`, `X09` | V12 **yes**; X09 **no** (not on board) | **Stale + ORPHAN** | Integrate V12; retire X09 or open a named ticket for start presets / `mapsize` enum. |
| §03 §1/§5 "V16/X19 must reconcile", "X18 (independent channel verification), X19 (port decoder gap)" | `V16`, `X18`, `X19` | V16 **yes**; X18/X19 **no** | **Stale + ORPHAN** | V16-22 is OPEN with owner F04 (now landed); retire X18/X19 or assign. |
| §13 §4 "see `V03_open_items_resolution.md`" | `V03` | **No** (not on board) | **ORPHAN** | Retire or assign one owner for the 28 P06 items. |
| §12 §12.1 "V04 report pending"; §12 §12.4 "V11 is assigning" | `V04`, `V11` | Both **yes** | **STALE** | COORD integrate; V16-23 fold-in. |
| §01 §5 cross-check queue lists F04/F03 as pending; §06 §5 lists F03/F06 pending | `F04`, `F03`, `F06` | All **yes** | **STALE** | Update queue text; no new report needed. |
| §10 §4 "16 `[U]` → V01" | `V01` | **Yes** | **STALE** | V01 resolves 10, partial 3, leaves 3 `[U]`; integrate table. |

## 5. UNVERIFIED assignment audit (COORD check 4)

**Verdict [O]: not every UNVERIFIED item in the spec is assigned to a named worker or ticket.** The following are unassigned or assigned to a non-landed ticket; labelled items are excluded.

| Spec location | `[U]` item | Current assignee in spec | Gap |
|---|---|---|---|
| §01 §1/§3/§5 | field order, struct stride, collision tag width, 2× grid, owner, row sign, TILE_M, resource_id/prop_index | D04 (partial); row sign/TILE_M only in A01 §8, **not** in §01 §5 | D04 absent; row sign/TILE_M **unassigned in spec** |
| §04 §6/§7; §10 §4 | row-sign flip, global setter clamp, rotation rounding; 16 A02 constants | X12 (orphan); V01 (landed) | Assign X12 queue to D03/D05 or retire; integrate V01's 3 residual `[U]` |
| §05 §1/§7/§8; D06 register 1–10 | −0.5 runtime, bmTransparency factors/pass count, ford rule, hmapTex FBO/binding, shader plane Y, metres-per-cell | F06/F05/D06 named as sources, **no implementation owner** | All six **unassigned**; V16 O11 partially covers hmapTex |
| §06 §3/§5 | live tile-selection rules, cliffs/covers 0-byte stubs, bmTransparency factors, desert winter reuse | D08/F03/F06/F10 ("cross-check queue") | D08/F03/F06 landed; F10 absent; no ticket for live-rule promotion |
| §07 §1/§4; §10 §2 | deposit amount, `mapsize` enum → "tiny", `gDataVersion`, DScript local-init, family→ore `[I]` | X09 (orphan); V12/V01 (landed) | X09 gap; V01 resolves gDataVersion=92; VM semantics remains `[U]` unassigned |
| §08 §4; §11 §3 | relief grid/object tail, desert season set, atlas downsample, field/mine placement | D05/F01/F10/F07/F08 (queue) | F01/F10 absent; atlas downsample **unassigned** |
| §09 §4/§5; F03 §4 | cfg key meanings `[I]/[U]` (Size, CellsResolution, castle keys) | D09 (landed, not integrated) | No implementation owner; harmless provenance-only |
| §12 §6/§7; V06 §6 | donor numeric ranges → advisory policy, 3 unacked failures, stale Z07 atom, `stats`-dict snapshot risk | V06/V04/V05 (no named executor) | V16 O3/O4/O14 assign COORD/I13 — fold into spec |
| §13 §4 | 28 open items V-01…V-28 | V03 (orphan) | Assign named owner or retire |
| §02 §1/§5 | save-map key bytes, instance class identities, key→state internals | D02 (landed) | V01 says no derivation function; reword §1; D02 engine-internals `[U]` accepted |

## 6. Ticket go/no-go dispatch order

Strict reading of `IMPLEMENTATION_PLAN.md:3` makes every ticket NO-GO until COORD marks its spec sections READY; the table therefore gives the **conditional GO after Pass 0**, ordered by dependency. "Critical path" marks the ticket whose unreadiness blocks the runtime wave.

| Order | Ticket | Go / No-Go | Spec dependency status | Concrete gate before dispatch |
|---|---|---|---|---|
| Pass 0 | COORD spec integration | **GO now** | §00 absent; V12/V01/V16/V11/V06/D08/F04/F07/F08/D03/D02/D09 landed but unintegrated | Write §00; resolve X1–X7; update §02/§03/§04/§07/§10/§12/§13/§14; mark sections READY; decide V16 O1/O3–O7/O11/O14; widen PLAN I11. |
| 1 | I01 cfg decoder | **CONDITIONAL GO** | §09 READY; §11 NEEDS_WORK only outside I01 scope | Mark §09 READY; emit `constants.json` with donor path:line; include V01 `gDataVersion:=92`; no writes into donor root. |
| 2 | I03 pattern.lib decoder | **CONDITIONAL GO** | §04 §1–§2 READY (F02/X05); §4 unresolved header policy | Apply V16 O1 quarantine (binary 18×23 authority, no abort); use X05 corrected section ends; read flags, invent nothing. |
| 3 | I06 data container | **CONDITIONAL GO** | §01 core SoA + dump contract READY; `[U]` fields labelled | Resolve D04 stride/collision/owner or keep `[U]`; align §01 §3 with F04; decide V16 O6 (`terrain_new_assets.gd`). |
| 4 | I04 mask decoder | **CONDITIONAL GO** | §03 assembled but NEEDS_WORK (X5 conflict OPEN) | Resolve V16 O5: preserve raw R with `ENGINE/UNVERIFIED`; `h=−1.1·B/255`, water B≥58; honour TGA descriptor bit 0x20 and no-alpha; D03 landed → integrate. |
| 5 | I05 atlas builder | **CONDITIONAL GO** | §06 NEEDS_WORK (D08 landed, D04 absent); §11 atlas route READY | Keep 124 ids/16×8/no remap; alphanull 86/110/123; mip fix; desert aliases F10 label UNVERIFIED. |
| 6 | I02 `.pattern` decoder | **NO-GO** | §04/§11 float-plane start ±24–160 B `[U]`; X12 orphan | **F01 MUST LAND** (exact byte layout). Until then emit decoded fields only, `null`+`label:"UNVERIFIED"` elsewhere (`spec/11 §11.1`). |
| 7 | I07 stage pipeline | **NO-GO — CRITICAL PATH** | §02 NEEDS_WORK; §03 NEEDS_WORK; §04/§05/§07/§10 NEEDS_WORK | After X1–X5 resolved, V12/V01/V16 integrated, X09 retired, §07 map-size gating corrected, V16 O7 two-file ownership decided. Per-stage ledger must **restart the same stream**, not derive independent keys (V01 §1 item 3). |
| 8 | I08 mesh | **CONDITIONAL GO** | §01 + §06 NEEDS_WORK (same as I06/I05) | Land after I06; one ArrayMesh, UV2=(tex,face), water bind; no face promotion/HEIGHT_SCALE/manual dither. |
| 9 | I09 props | **CONDITIONAL GO** | §08 NEEDS_WORK until F07/F08/V07 integrated | Reuse committed Z08 `terrainmesh1..4` + `TerrainmeshProps_*` read-only; 49-node mill field; no generic entity path. |
| 10 | I10 shader | **NO-GO** | §05/§06 NEEDS_WORK; "only if needed" | After §05/§06 READY and I08 demonstrates need; no invented constants, no second water plane, no Fresnel/current grid. |
| 11 | I11 seam + composer | **NO-GO (COORD only)** | §12 NEEDS_WORK; seam itself READY; V16 O6/O7 open | Create N14 `terrain_donor_world.gd` **before** the seam; confirm `COORD-I11`; one owner for `main.gd`+`world3d.gd`; parse-before-switch; default `"legacy"`. |
| 12 | I12 determinism atom | **NO-GO** | §12 NEEDS_WORK; V06 remediation unexecuted | Fresh 29/29, 17/17, `t_render_mode`, CLEAN with unique ids (V06 §4.1–4.2); manifest append LAST with `.bak-I12`; strengthen Z07 atom, never lower expectation. |
| 13 | I13 QA / capture | **NO-GO** | §12 NEEDS_WORK; §00 missing; V16 O3/O4 | All prior tickets landed; explicit 240²/320² overlays; frozen baselines; verdict wording "gates green / parity UNVERIFIED"; no parity claim. |

## 7. "SPEC READY" checklist for COORD

- [ ] **C0** `spec/00_EVIDENCE_INDEX.md` created; every spec claim resolves to a landed report/evidence id (X12, X09, X18, X19, V03 retired or assigned).
- [ ] **C1** §09 marked READY (first section); §01/§02/§03/§04/§05/§06/§07/§08/§10/§11/§12/§13/§14 each carry an explicit READY marker after X1–X7 are closed.
- [ ] **C2** Blend-math conflict X1 closed: §04 §3 and §10 §2/§4 relabelled superseded by §04 §6 (D05/V16-15); row-flip/global clamp stay `[U]`.
- [ ] **C3** Resource stage X2–X4 closed: V12 corrections integrated into §07; food-rect claim struck from §10 §2; `mapsize>2` = 256 tiny per V01; citation `:1568-1581`; `continue` semantics.
- [ ] **C4** Mask-channel conflict X5 closed: §01 §3/§10 §2 aligned with §03 §1/F04/V16-22; raw R preserved with `ENGINE/UNVERIFIED`; no R→height for shipped masks.
- [ ] **C5** Git/seam staleness X6–X7 closed: §12.1 "V04 pending" removed; §13/§14 point-in-time notes updated; PLAN I11 widened to two files; N14 composer owned; `COORD-I11` reserved.
- [ ] **C6** V01 table folded into §10 (10 resolved / 3 partial / 3 `[U]`); X03's 11+3 reseed sites replace A02's 5 everywhere; §02 "key derivation `[U]`" reworded to "no donor derivation".
- [ ] **C7** V16 register folded into spec contradiction table (`spec/README.md` register is still the placeholder row): 14 RESOLVED, 9 PRESERVED, 4 OPEN with named owners; O1–O14 signed off or carried explicitly.
- [ ] **C8** Every UNVERIFIED item has a named owner (§5 gap list closed, including row sign/TILE_M, −0.5 runtime, bmTransparency factors, atlas downsample, 28 P06 items).
- [ ] **C9** F01 and F10 either land or are explicitly out-of-scope with reason; D04 either lands or all struct-stride-dependent fields remain `[U]` in I06.
- [ ] **C10** Fresh gate baseline exists (V06 §4.1–4.4 executed by COORD); no PASS/parity claim without a real donor GPU A/B frame.

## 8. Risks

1. **[D] Silent resolution of preserved contradictions** (X9, V16-02/03/04/05) would produce a plausible but non-donor pipeline: adopting `6` passes, the plain `tilesmooth.cfg`, `Max` as a clamp, or per-ore mine radii. Mitigation: keep both literals in spec and implementation comments.
2. **[D] Spec drift from concurrent landings** is the top operational risk: eight reports and two spec files changed during this audit. V16's own final glob was 30 reports; the current tree has more. COORD must re-run pairwise checks before dispatch.
3. **[D] I07 is a hard blocker** (`IMPLEMENTATION_PLAN.md:15` depends on six sections, none READY). Starting I08/I09 before I07 is safe only as contract-level coding against I06; an integrated runtime cannot be claimed until I07 lands.
4. **[O] Seam double-apply remains live**, even though V11 resolved ownership on paper (`world3d.gd:108,609` still unmodified). Two workers touching it would duplicate `set_terrain_backend()` and `stats` keys.
5. **[U] Epistemic ceiling**: no donor GPU A/B frame exists. Every "closer to donor" statement in this audit is a citation-level or structural judgement; none is a visual-parity claim.

## 9. Open questions

1. **COORD:** Will X09/X12/X18/X19/V03 be assigned to named workers, or retired with an explicit out-of-scope reason? (Blocks C0/X1/X5.)
2. **COORD + I02/I03:** Confirm V16 O1 policy for `m_swamp_12_old` — quarantine with warning, binary 18×23 as geometry authority — before I03 emits the 680-record index.
3. **COORD:** Confirm V01's `mapsize>2 = 256 tiny` reversal and update §07 §1's "current band" wording; does the 14/32/70 row apply to any shipped default (320/480/640)?
4. **COORD:** Does I06 absorb `terrain_new_assets.gd` (V16 O6), and may I07 own both `terrain_donor_gen.gd` and `terrain_donor_tiles.gd` (V16 O7)? Both are dispatch prerequisites.
5. **COORD + I13:** Pin canonical 240²/320² overlays and the fresh-gate order (V16 O3/O4); which structural bands, if any, may ever move from advisory to red?
6. **D03/D05:** Assign an owner to row-sign, global-setter clamp and rotation rounding so §04 §7 stops citing the non-existent X12.
7. **Owner:** Can a donor GPU A/B frame ever be produced? Until yes, every verdict here stays a value/line/count adjudication, never a parity claim.

## 10. Five-line summary

1. **[O] No spec section is unconditionally READY for dispatch**: §00 is absent, §09 is READY for I01 scope, and §01–§08/§10–§14 are NEEDS_WORK for missing reports (D04, F01, F10, X09/X12/X18/X19/V03) or un-integrated landed ones (V12, V01, V16, V11, V06, D08, F04, F07/F08).
2. **[O] Requested coherence checks pass at fact level but fail at status level**: §04 §6 vs §10 blend math, §07/§10 food rects and map-size gating, §03 vs §01/§10 mask R/G semantics, and §12 vs §13/§14 git/seam status are the four material conflicts; three-water-levels, two cfg contradictions and the 11+3 reseed sites agree.
3. **[O] Orphan citations are real**: X12 (§04), X09 (§07), X18/X19 (§03), V03 (§13) point to reports that do not exist; V12/V11/V06/V01/V16/D08/F04/F07/F08 landed but were not folded in.
4. **[D] Dispatch**: Pass 0 COORD integration, then I01/I03/I06/I04/I05 conditional GO; I02 NO-GO until F01; I07 NO-GO/critical path; I08/I09 conditional; I10/I11/I12/I13 NO-GO until their gates close.
5. **[U] Not every UNVERIFIED item has a named owner** (row sign/TILE_M, water `[U]` set, atlas downsample, 28 P06 items are the main gaps); no parity claim is made — donor parity stays UNVERIFIED without a real GPU A/B frame.

*End of V17 report. Exactly one repo file written; no spec, source, asset, test, git, Godot or runner state changed. PORT APPROXIMATION / UNVERIFIED throughout; no donor visual parity claimed.*
