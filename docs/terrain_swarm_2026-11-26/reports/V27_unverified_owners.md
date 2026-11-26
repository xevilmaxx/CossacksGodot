---
id: V27
ticket: "TERRAIN-SWARM-2026-11-26 / V27 — assign OWNER + DISPOSITION to every remaining [U] item (close V17's last gap)"
agent: "V27 (read-only verification subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_SPEC_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/V27_unverified_owners.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; no donor binary was executed and no capture was run. 'Owner' means a named ticket/worker for a value/line/count, never a visual-fidelity sign-off. Every port consequence is PORT APPROXIMATION / [U]."
scope: "Read CHARTER.md, SWARM_BOARD.md, IMPLEMENTATION_PLAN.md, spec/README.md, spec/00_EVIDENCE_INDEX.md and spec files 01–14; cross-read V17_spec_readiness.md (§5 UNVERIFIED assignment audit), P06_prior_wave_distill.md (§4 register V-01…V-28), V16_contradiction_register.md (§2/§4 OPEN O1–O14), X03_dscript_corpus.md (§8 U1–U16), V01_unverified_resolution.md (§3/§6), V11_ownership_ledger.md, V21_gate_register.md, V06/V07, D02/D03, X08/X09/X11/X12/X17/X19, and the spec sections that carry the [U] claims. LATE LANDINGS re-read before sign-off: V03_open_items_resolution.md (was an orphan at V17's read; now landed with 1 CLOSED_TODAY / 16 PARTIALLY_CLOSED / 11 STILL_OPEN), F01_pattern_format.md (710/710 `.pattern` byte closure), D04_map_format.md, X13_blend_test_vectors.md, X21_rng_vectors.md, spec/00_EVIDENCE_INDEX.md. No source/shader/config/asset/test/git/spec change; exactly one report written."
multiple_passes: true
---

# V27 — UNVERIFIED owner / disposition register

## 0. Executive summary

1. **[O] V17's gap is real and is now closed on paper.** `reports/V17_spec_readiness.md:93-108` found that "not every UNVERIFIED item in the spec is assigned to a named worker or ticket"; its §5 lists ten unresolved rows. This report gives each remaining `[U]` item an **id, exact claim, reason, named owner, disposition and affected gate**. No donor value was invented to close any row.
2. **[D] Three dispositions are used, with strict meaning.** **RESOLVE_BEFORE_IMPLEMENTATION** = a named worker/ticket must act before the cited I-ticket may be dispatched (e.g. F01 for the `.pattern` byte boundary, D04 for the SoA stride, COORD at I03 for the swamp-header policy). **ADVISORY_AT_QA** = the port may ship a labelled `PORT APPROXIMATION` and V21 class-B/C gate stays advisory until V17 marks READY (`reports/V21_gate_register.md:129-135`). **DOCUMENT_ONLY** = no worker can recover a donor value today, or no port value is needed; the item is recorded as `[U]` with the passes attempted and is **not** a gate blocker.
3. **[O] V03 landed during this ticket and is read.** `reports/V03_open_items_resolution.md` (final glob of 53 reports) disposes V-01…V-28 as **1 CLOSED_TODAY (V-15), 16 PARTIALLY_CLOSED, 11 STILL_OPEN**; no hard-evidence item (GPU frame, fresh dump, fresh runner JSON) closed. Its §5.2 owner list is reconciled with §4.4 below; V17's "orphan" citation is therefore obsolete but the items are not all closed.
4. **[D] Several `[U]` labels are already stale, not unresolved.** X17 pinned the `bmTransparency` factors (`GL_SRC_ALPHA`/`GL_ONE_MINUS_SRC_ALPHA`); V01 resolved `gDataVersion=92`, `gc_MaxTerrainTypeCount=9`, `mapsize>2 = 256 tiny`, the mill-field decal rule and the `cstartoffset` vestige; X19 resolved the R/G intent-vs-pixels contradiction; D05+X12 resolved the three blend branches. **Late landings add three more fold-ins**: F01 closed the `.pattern` byte accounting (`filesize = 8+4wh+54(w−1)(h−1)`, 710/710; true grid `G=8+(w−1)(h−1)`) so the ±24–160 B ambiguity is gone; D04 closed the `.map` 37-byte record (V-15 CLOSED_TODAY per V03); X13 supplied 19+4 stamp vectors (only donor-flag path is ReplaceForWater) and X21 supplied 20 RNG vectors with the correction that `key0` never seeds the state. These are **DOCUMENT_ONLY fold-ins** (COORD spec edits), not new donor values.
5. **[U] Nothing here is a parity verdict.** Items whose answer would require a donor GPU frame, an executed script trace or an external editor manual (R1–R6 numeric ranges, start-spacing centimetres, `GenerateMapRandKey` body, saved-map key bytes, composite pass count, currents/glints, post-pass update order, x87 exactness) are **DOCUMENT_ONLY or advisory with reason** — no worker can resolve them under the read-only charter and no port value is needed to implement the stage.

## 1. Evidence table (read-only, multiple passes where a source disagreed)

| # | Source re-read (path:section / line) | Passes | Establishes | Label |
|---|---|---|---|---|
| E1 | `CHARTER.md:32-44,66-94`; `SWARM_BOARD.md:62-75`; `IMPLEMENTATION_PLAN.md:3-21` | full + targeted | Mandatory labels, no-parity rule, one report per worker, ticket dependencies, contradiction register C1–C9 | [O] |
| E2 | `reports/V17_spec_readiness.md:93-108` (§5), `:131-143` (§7 C8) | 2 | Gap list: row sign/TILE_M, water `[U]` set, atlas downsample, 28 P06 items, engine RNG internals all unassigned or on absent tickets | [O] |
| E3 | `spec/01_WORLD_DATA_MODEL.md:23-36,44-46,68-78`; `spec/02_SEED_AND_RNG.md:13,70-79`; `spec/03_MASK_TO_HEIGHT.md:21-26,43-52` | 2 | Exact `[U]` wording for row sign, TILE_M, owner/resource_id, key derivation, key→state/save-map bytes, R/G semantics, forest density | [O] |
| E4 | `spec/04_PATTERN_STAMPING.md:24-25,46-49,60-61,88-95`; `spec/05_WATER_SHORE.md:15-17,33-43,73-79`; `spec/06_TILE_AND_ATLAS.md:36-38,55-60`; `spec/07_RESOURCES.md:49-55`; `spec/09_EDITOR_PARAMETERS.md:60-70`; `spec/10_STAGE_ORDER.md:40-43,65-69,103-104`; `spec/11_ASSET_CONVERSION.md:31-38,57-59`; `spec/12_QA_AND_INTEGRATION.md:96-139`; `spec/13_PRIOR_WAVE_MEMORY.md:33-38` | 2 | Claims `blend math [U]`, `−0.5 [U]`, `bmTransparency factors/pass count [U]`, `hmapTex [U]`, `ford rule [U]`, `live selection [U]`, `deposit amount [U]`, `atlas downsample [U]`, `16 [U] → V01`, `28 items → V03` | [O]/[U] |
| E5 | `reports/V16_contradiction_register.md:52-85,106-123`; `SWARM_BOARD.md:71` | 3 | 27 clusters (14 RESOLVED / 9 PRESERVED / **5 OPEN rows O1,O2,O3,O5,O6,O7 in §2; board C6 names four** O1/O2/O3/O5), each with a one-line owner; §4 lists O1–O14 | [O]/[D] |
| E6 | `reports/X03_dscript_corpus.md:1259-1278` (§8 U1–U16), `:1223-1239` (§6 A1–A13) | 2 | X03's 16-item `[U]` register with a "resolution owner" column; 13 multi-pass anomalies all resolved as donor text | [O] |
| E7 | `reports/V01_unverified_resolution.md:142-160,494-507` | 2 | 10 of A02's 16 resolved, 3 partial, 3 still `[U]`; remaining R1–R9 each name a worker | [O]/[D] |
| E8 | `reports/P06_prior_wave_distill.md:147-189` (§4 V-01…V-28) | 2 | Exact 28-item register with closing evidence; V-01 parity, V-02 gates, V-28 mine snap/field quad | [O] |
| E9 | `reports/D02_seed_rng.md:226-236,343-353`; `reports/X03_dscript_corpus.md:183,893` | 2 | `GenerateMapRandKey` body `[U]`; LCG state update recovered exactly; saved-map byte mapping and instance class identities `[U]` | [O]/[D]/[U] |
| E10 | `reports/D03_mask_pipeline.md:180-203,287-298`; `reports/X19_mask_decoder_gap.md:139-141,382-394` | 3 | Custom smoothing kernel recovered; native `SmoothTerrain` kernel still `[U]`; all shipped R/G zero off starts; smoothing stage order `[U]` | [O]/[U] |
| E11 | `reports/X11_water_translation.md:407-438,502-524`; `reports/X17_blendfunc_verification.md:164-178,225-233` | 2 | Five water levels; −0.5 GSC-commented; `hmapTex` key no bind; plane Y `[U]`; `bmTransparency` factors pinned, composite pass count CONFIRMED_UNVERIFIED after six passes | [O]/[D]/[U] |
| E12 | `reports/X12_stamp_verification.md:118-177`; `reports/V07_relief_asset_readiness.md:152-183` | 2 | Three blend branches survive opcode verification; `.pattern` float-plane boundary and full-grid coverage still `[U]`; Z07 QA atom stale | [O]/[U] |
| E13 | `reports/V11_ownership_ledger.md:72-111,137-152`; `reports/V06_gate_remediation.md:22-30,231-247`; `reports/V21_gate_register.md:70-123,202-222` | 2 | One-owner ledger, 3 unacked 575/582/585, stale JSONs, gate classes A/B/C and every advisory `[U]` gate id | [O]/[D] |
| E14 | `reports/V03_open_items_resolution.md:16-23,80-111,166-183`; `reports/V17_spec_readiness.md:88` | 2 (read + glob) | V03 was an orphan at V17's read but **landed during this ticket**: 1 CLOSED_TODAY (V-15), 16 PARTIALLY_CLOSED, 11 STILL_OPEN; §13's citation is no longer an orphan | [O] |
| E15 | Glob of `reports/*.md` and `spec/*.md` at start and end of this ticket | 2 | V17/V21/V03 arrived after the earlier audits; final glob also shows late F01/D04/X13/X21/X18/V20/X15/X20/X22 and `spec/00_EVIDENCE_INDEX.md` | [O] |
| E16 | `reports/F01_pattern_format.md:41-59,123-168,546-560`; `reports/D04_map_format.md:14-20,185-205,271-285`; `reports/X13_blend_test_vectors.md:14-48,261-275`; `reports/X21_rng_vectors.md:38-73,452-465`; `spec/00_EVIDENCE_INDEX.md:16-21` | 2 | `.pattern` byte closure and true grid offset closed; `.map` 37-byte record closed (V-15); stamp vectors and RNG vectors landed with fresh `[U]` registers; §00 now exists but section READY markers still absent at final read | [O]/[D]/[U] |

## 2. Method and disposition key

Labels: **[O]** literal report/spec/source line re-read · **[D]** deterministic consequence of cited lines · **[I]** interpretation with caveat · **[U]** UNVERIFIED (no donor value recovered) · **PORT APPROXIMATION** for port substitutes. Multiple passes were used wherever two reports disagreed (e.g. V16 exec "4 OPEN" vs §2 five OPEN rows; spec/04 §3 `[U]` vs §6 `[O]` blend math; spec/05 "factors/pass count `[U]`" vs X17 instruction-level factors). No donor binary was run; no donor frame exists.

**Owner column** accepts exactly three forms, per ticket: a **worker id** (D02/D03/D04/D05/F01/F10/I0x/I13/COORD as a named ticket owner), **"COORD decision at Ixx"** (a policy/dispatch decision, not a donor value), or **"owner-facing UNVERIFIED — no port value needed"** (no worker can recover a value today and the port does not need one). The last form is a *documented* owner of the `[U]` label, not an invented value.

**Disposition column**: **RESOLVE_BEFORE_IMPLEMENTATION** / **ADVISORY_AT_QA** / **DOCUMENT_ONLY**. A DOCUMENT_ONLY row always carries its reason in the "why unresolved" cell; it is never silently promoted to a PASS or a red gate.

**Gate column** cites the concrete I-ticket dependency from `IMPLEMENTATION_PLAN.md:7-21` and/or a V21 gate id (`GR-A*`, `GR-B*`, `GR-C*`).

### 2.1 Point-in-time correction — late landings (read before sign-off)

The swarm kept landing reports while this audit ran. Four changes affect dispositions below:
- **F01 landed**: `.pattern` format is byte-closed (710/710, zero residual) at `G=8+(w−1)(h−1)` (`reports/F01_pattern_format.md:43-59,123-168`). CORE-17/CORE-18 and P06-V05/V13 **no longer block I02 on an absent report**; they become fold-ins plus labelled residual semantics (`id`, 4-byte tail, weights, tail flags) and `row_flip`.
- **D04 landed**: the 37-byte `.map` record is recovered (bytes 8–11 = four `u8` tile ids) and V03 marks P06-V15 **CLOSED_TODAY** (`reports/V03_open_items_resolution.md:98`). The per-tile `collision[4]`, owner/resource pointer and byte-12 semantics are explicitly **not found** (`reports/D04_map_format.md:205,271-284`) → CORE-40/CORE-41 become DOCUMENT_ONLY, not "D04 MUST LAND".
- **X13 landed** (`reports/X13_blend_test_vectors.md`): 19 blend vectors + 4 smooth snapshots; D05 F4 accepted as authoritative; 8 donor-flag (ReplaceForWater) vectors are bit-exact, 11 synthetic-flag vectors are advisory; `row_flip`, rotation rounding, global clamp, x87 exactness and **in-place vs double-buffer post-pass order** stay `[U]` (X13 U1–U10).
- **X21 landed** (`reports/X21_rng_vectors.md`): 20 exact RNG vectors; `key0` is **discarded** (correction to D02), output requires float32 rounding; `GenerateMapRandKey`, saved-map bytes, DScript numeric promotion and a signed first-draw edge case stay `[U]` (X21 XU1–XU8).
- **V03 landed** and **spec/00** exists (X14). The 28 P06 items therefore have a resolution report with owner list; §4.4 reconciles with `reports/V03_open_items_resolution.md:166-183`. Section READY markers were still absent at final read, so CORE-39 retains its RESOLVE disposition with §00 now complete.

## 3. Compact summary table — owner / disposition by group

| Group | Rows | Dominant disposition | Gate surface |
|---|---|---|---|
| Core scope [U] (row sign, RNG, water, atlas, stamp, resources) | §4.1: 42 + §4.1a: 7 late items | 9 RESOLVE_BEFORE_IMPLEMENTATION · 10 ADVISORY_AT_QA · 30 DOCUMENT_ONLY | I02/I03/I04/I06/I07/I10; GR-A18/A24, GR-B01…B16 |
| V16 OPEN register O1–O14 | §4.2: 14 | 5 RESOLVE · 5 ADVISORY · 4 DOCUMENT_ONLY | I02/I03/I06/I07/I10/I12/I13; GR-B09/B11/B15, GR-A24 |
| X03 16-item register U1–U16 | §4.3: 16 | 1 RESOLVE · 2 ADVISORY · 13 DOCUMENT_ONLY | I01/I02/I04/I05/I07/I09; GR-A18/A19, GR-B10 |
| P06 28-item register V-01…V-28 | §4.4: 28 | 3 RESOLVE · 13 ADVISORY · 12 DOCUMENT_ONLY | I02/I06/I07/I09/I12/I13; GR-A24, GR-B*, GR-C* |

## 4. Full owner / disposition table

### 4.1 Core scope `[U]` items (V17 §5 gap list + the named scope items)

| Id | Exact `[U]` claim | Why unresolved | Named owner | Disposition | Gate affected |
|---|---|---|---|---|---|
| CORE-01 | `spec/01 §2`: "Row sign **UNVERIFIED**" (file-row `v` → signed world-y flip) | D05 P6 and X12 U1 verified row→`+0x28` grid indexing but not file-row→centre sign; D03 did not study it (`reports/V01_unverified_resolution.md:502`; V16 O10) | D05 + D03 (binary follow-up) | RESOLVE_BEFORE_IMPLEMENTATION | I02 `.pattern` decoder; I07 stage pipeline (`spec/04 §7`) |
| CORE-02 | `spec/01 §2`: "`TILE_M=2.0` is port-only, **UNVERIFIED**" | Spec text stale: V01 U15 recovered donor `gc_meters_to_tile=2` and refuted donor-160; no new value needed | COORD decision at I06 (fold V01 U15 into §01) | DOCUMENT_ONLY — value already recovered; only a spec doc update remains | I06/I08 scale contract |
| CORE-03 | `spec/05 §1`: runtime execution of `−0.5` (`cOffsetY`) is `[U]` | `generatemap.inc:688,704` is GSC-commented; X11 re-grep found no compiled consumer (`reports/X11_water_translation.md:414`) | D08 + COORD (V16 O11) | ADVISORY_AT_QA | I07 water-field stage; V21 GR-B03 |
| CORE-04 | `spec/05 §3`, X11 §10 #1: `hmapTex` FBO/texture binding `[U]` | Descriptor `FUN_00853ad4 +0x54` assigns a key only; no texture bind; `heightmapwaves0.tga` disproved (D06 P18, X11 §3.4) | D08 + COORD (V16 O11) | ADVISORY_AT_QA | I08 mesh water bind / I10 shader; GR-B11, GR-C05 |
| CORE-05 | X11 §10 #11: shader plane Y `gl_TexCoord[1].z` numeric value `[U]` | Engine-supplied; only readable number is the `−0.25` classification literal, which is a different role (`reports/X11_water_translation.md:417`) | owner-facing UNVERIFIED — no port value needed (port keeps a labelled `−0.25` placeholder) | ADVISORY_AT_QA | I10; GR-B12 |
| CORE-06 | V21 GR-B12: `gl_EyePlaneS/T[0]`, `gl_TextureMatrix[0]`, `TileXOffset/YOffset` arithmetic `[U]` | Equations observed in text/CODE; runtime plane values not recovered without a GPU trace (`reports/V21_gate_register.md:108`) | D08 (binary re-check) + COORD decision at I10 | ADVISORY_AT_QA | I10; GR-B12 |
| CORE-07 | `spec/05 §7`, `spec/06 §5`: `bmTransparency` **factors** `[U]` | Stale label: X17 pinned `glBlendFunc(770,771)` at VA `0x4ef991`/`0x88fbb0`/`0x88fbb7` (`reports/X17_blendfunc_verification.md:19,3.1`) | COORD decision at I10 (fold X17 `[D]` into §05/§06) | DOCUMENT_ONLY — factors are already `[D]`; no new value to invent | I10; GR-B11 |
| CORE-08 | `spec/05 §7`, `spec/06 §5`: `bmTransparency` **pass count** `[U]` | X17 U-X17-1 **CONFIRMED_UNVERIFIED** after six independent passes; `tsDouble=1` is suggestive only, no loop recovered (`reports/X17_blendfunc_verification.md:164-178`) | owner-facing UNVERIFIED — no port value needed (two-layer Godot is explicitly PORT APPROX) | DOCUMENT_ONLY — no worker can resolve under read-only charter; no port value needed | I10; GR-B11 advisory |
| CORE-09 | `spec/05 §5`: "no river-current grid or brush glint mechanic" | D06 §5 and X11 §3.4 give a **negative** donor finding (`shaders.lib` zero current/glint matches); nothing to recover | owner-facing UNVERIFIED — no port value needed (do not invent a current grid) | DOCUMENT_ONLY — negative finding; adding a current/glint would violate CHARTER §4 | I10 (forbidden invention) |
| CORE-10 | `spec/05 §6`: ford-generation rule `[U]` | `fordtyp` is a squad formation field; no generation rule found; only DLC5 `rivers` mask path (`reports/V16_contradiction_register.md:77`, V16 O2) | COORD + F10 (scope decision) | DOCUMENT_ONLY — record `OUT_OF_SCOPE` with citation; invent no ford threshold | GR-B15 advisory |
| CORE-11 | P06 V-16: donor metres-per-cell / mesh LOD / exact engine normal formula `[U]` | V01 U15 recovered `gc_meters_to_tile=2`; LOD and normal formula are engine internals with no donor literal needed by the port | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — no port value needed beyond the recovered 2 | I08 mesh |
| CORE-12 | `spec/02 §1`: `GenerateMapRandKey` `[U]` | D02 Anomaly D: declaration strings at `0x29e852`/`0x29e902`, no body, no code xref, only call sites (`reports/D02_seed_rng.md:226-233`) | owner-facing UNVERIFIED — no port value needed (all stages re-seed `randkey1` verbatim) | DOCUMENT_ONLY — seed *derivation* affects UI-seed parity only, not replay fidelity | I07 RNG ledger; GR-A16 |
| CORE-13 | `spec/02 §5`: engine key→state / `RandomExt` internals `[U]` | D02 §4.2 and X21 re-derived the 32-bit LCG exactly (20 vectors); X21 corrects that `key0` is discarded; residual U3/U6/U7 are class identity and setter bodies, which do not change the numeric stream (`reports/X21_rng_vectors.md:38-52,452-465`) | D02 / X01 (class identity only) | DOCUMENT_ONLY — recovered LCG is sufficient for determinism; no port value needed | GR-A01 determinism |
| CORE-14 | `spec/02 §6`: saved-map key bytes `[U]` | D02 U2 / X21 XU2: byte-to-field mapping in version-7 `.map` blobs; no known-key generated map shipped; D04 landed but did not resolve key-byte positions (`reports/D04_map_format.md:271-284`) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — replay of saved maps is out of scope; no port value needed | I07 advisory |
| CORE-15 | `spec/02 §3/§6`: instance class identities of the three RNG owners `[U]` | D02 U3/U6; X21 XU6 found 5 LCG instances in `cossacks.exe` / 6 in `editor.exe` but no setter-body anchors or code xrefs to RTTI (`reports/X21_rng_vectors.md:360-362,461`) | D02 / X01 | DOCUMENT_ONLY — class labels do not change seeded output | none (I07 telemetry only) |
| CORE-16 | `spec/04 §3`: blend-flag engine math `[U]` (stale vs §6) | D05 + X12 verified three branches, `Min` pivot, `Max` unused; V01 U3/U4/U5 resolved (`reports/X12_stamp_verification.md:118-136`) | COORD decision at I02/I07 (relabel §04 §3 and §10 §2/§4 as superseded) | DOCUMENT_ONLY — math is donor-derived `[O]`; only spec fold-in remains | I02/I07 |
| CORE-17 | `spec/04 §6/§7`: `.pattern` float-plane byte boundary ±24–160 B `[U]` (**stale after F01**) | F01 closed byte accounting: `filesize = 8+4wh+54(w−1)(h−1)` (710/710, zero residual) and `G = 8+(w−1)(h−1)`; 678/680 sections decode bit-exactly (`reports/F01_pattern_format.md:43-59,123-168`) | COORD decision at I02 (fold F01 into §04; relabel §04 §6/§7 and §11.3) | DOCUMENT_ONLY — F01 landed; no new value to invent, only a spec fold-in | I02 layout gate now satisfiable; residual field semantics labelled in decoder |
| CORE-18 | V01 R6 / V07 E16: full `w×h` grids for every donor-active relief id `[U]` | F01 supplies the exact grid offset for all 710 files; residual gaps are semantic (`Rec24 id`, 4-byte tail, `int32[4N−1]` weights, `Tail13 flags`) and `row_flip` (`reports/F01_pattern_format.md:546-560`) | I02 (emit full grids) + COORD at I02 (label semantics `UNVERIFIED`) | DOCUMENT_ONLY — decoder can emit decoded grids plus `null`+`UNVERIFIED` for semantics; coverage no longer blocks I02 | I02 emit path; GR-B06 advisory |
| CORE-19 | `spec/04 §1/§4`, SWARM_BOARD C4: `m_swamp_12_old` lib 17×20 vs binary 18×23 `[U]` | X05 A4 and F01 §4.9 both confirm a stale config, not a decoder defect (V16-04) | I02/I03 + COORD sign-off at I03 (quarantine + warning; binary 18×23 as geometry authority) | RESOLVE_BEFORE_IMPLEMENTATION — policy must be signed before the 680-record index is emitted | I03; GR-B15 |
| CORE-20 | `spec/11 §11.3`: `APPROX_ATLAS_DOWNSAMPLE` — whether downsampled cells preserve donor texel detail `[U]` | X06 verified 121/121 cells pixel-exact to declared PNGs at source tier, not at the commit-safe downsample tier (`spec/06 §7`) | COORD decision at I05 (tier) + I13 (capture) | ADVISORY_AT_QA — PORT APPROX tier is a port choice, not a donor value | I05; GR-B14 advisory |
| CORE-21 | `spec/06 §3`: live tile-selection rules `[U]` (all `texturemap.inc` lines `;`-commented) | D08/X08 read authoritative intent only; X08 U1/U9 confirms no live consumer (`reports/X08_tile_smooth_engine.md:537-552`) | owner-facing UNVERIFIED — no port value needed (do not invent a live rule) | DOCUMENT_ONLY — donor text is intent; runtime activation cannot be proven read-only | I07 texture stage / I10 |
| CORE-22 | `spec/06 §3`: `cliffs/**` and `covers/**` 0-byte stubs `[U]` | Donor stub files contain no data; X03 §3 stage 10 records only intent | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — nothing to decode | I10 |
| CORE-23 | `spec/06 §4`: desert winter tile reuse awaits F10 `[U]` | F10 landed during this ticket; V01 U14 resolved index-preserving `_winter` rename for vanilla, not desert aliases — COORD must re-check landed F10 before freezing the alias rule | F10 / COORD decision at I05 (re-check landed report) | ADVISORY_AT_QA — label desert aliases UNVERIFIED or out-of-scope | I05; GR-B14 |
| CORE-24 | `spec/07 §4`: deposit amount `[U]` (spec's "X09 investigates" label is stale) | X09 landed and V12 C-V9 / V21 GR-A14: no finite deposit capacity; `_res_Init hp:=0` | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — no capacity value exists; do not assert one | GR-A14 (red: any asserted capacity fails) |
| CORE-25 | `spec/07 §1`: "`v≥80, mapsize>2` is the current band" `[U]` label | V01 EV08 resolved `mapsize>2` = enum 3 = **256-cell tiny**; spec/07 wording stale (`reports/V01_unverified_resolution.md:78`) | COORD decision at I07 (relabel numerics, not "small/large") | DOCUMENT_ONLY — enum recovered; doc update only | I07; GR-B09 advisory |
| CORE-26 | X03 A12/U13: DScript local-variable initialisation (`count`, `sumProb`, `fbcount`, `arrfb`) `[U]` | Engine VM semantics; X08 models `sumProb`/`tmp` as 0 = PORT APPROX (`reports/X08_tile_smooth_engine.md:445`) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — affects ring-2 `dst` trace only, not a value | GR-B10 advisory |
| CORE-27 | `spec/07 §5`: family→ore interpretation `[I]`/`[U]` | V16-07 resolved: bands are ring radii shared by all three ores, not per-ore radii (`reports/V16_contradiction_register.md:60`) | COORD decision at I07 (use ring grouping; never per-ore radii) | DOCUMENT_ONLY — grouping resolved; doc update only | GR-A05/A06 red |
| CORE-28 | V01 U10/R3: exact start-spacing numbers 0.7 cm / 1.5–2 cm `[U]` | Donor has relative nearest/farthest ranking only (`dogenerate.inc:1048-1084`); numbers come from a modder changelog (`reports/V01_unverified_resolution.md:153`) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — no donor literal; inventing a threshold violates CHARTER §4 | I07 stage 7 (no numeric gate) |
| CORE-29 | V01 U12/R4: R1–R6 relief-generator numeric ranges `[U]` | P8/V01: zero donor-text and zero decomp hits; `GUIDE4.md:653-654` names parameters only (`reports/V01_unverified_resolution.md:155`) | owner-facing UNVERIFIED — no port value needed (D09/X02 may check editor UI labels but cannot assert a range) | DOCUMENT_ONLY — external manual only; no donor numbers | I09; GR-B02 advisory |
| CORE-30 | V01 U8: shipping `gRecordGeneratorVersion` `[U]` (stale in spec/07) | V01 EV03 resolved `gDataVersion:=92`, `gRecordGeneratorVersion := gDataVersion` for new maps | COORD decision at I07 (fold into §07) | DOCUMENT_ONLY — value recovered; doc update only | GR-B09 advisory |
| CORE-31 | `spec/09 §6`: cfg key meanings `[I]`/`[U]` (`Size`, `CellsResolution`, castle keys) | F03 §5: no consumer found for those keys; D09 landed but not integrated | COORD decision at I01 (emit `config_strings.json` labelled) | DOCUMENT_ONLY — provenance-only; harmless to I01 | I01 |
| CORE-32 | V06 §0/§6: 3 unacked runner failures 575/582/585 | V06 §4.1 supplies evidence-backed `ack --reason` strings; no ack executed yet (`reports/V06_gate_remediation.md:27,83-98`) | COORD decision at I12 (runner `ack`, never `--ignore-history`) | RESOLVE_BEFORE_IMPLEMENTATION — GR-A00 CLEAN must pass at V21 A′-0 | GR-A00; I12 stage A′ |
| CORE-33 | V13/V07/V16 O14: stale `t_relief_props_qa.gd:30` atom (`terrainmesh_props.json` vs live `mountain_props.json`) | V07 E05/M3/M6; atom stale on path, node type, scale and fixture (`reports/V07_relief_asset_readiness.md:43-53`) | I13 / G04 (QA owner) | RESOLVE_BEFORE_IMPLEMENTATION — strengthen, never lower `SCALE_WANT`/count | GR-A24 (currently hard FAIL), GR-C11 |
| CORE-34 | V06 §0: all five gate JSONs stale (`passed=true`, mtime 2026-11-25) | V06 §3 two-pass mtime check; stale, not fabricated (`reports/V06_gate_remediation.md:24-26`) | COORD decision at I13 (unique-id regeneration, mtime-after-START) | ADVISORY_AT_QA — execution is owner-only; no PASS claimed today | GR-A02/A03; V21 D-5 |
| CORE-35 | V21 class B: donor numeric ranges (height deciles, water/shore fractions, histograms, families) `[U]`/`[I]` | Spec slots empty; V21 keeps `--policy advisory` until V17 READY + N17 evidence + COORD sign-off (`reports/V21_gate_register.md:129-131`) | COORD decision at I13 (policy flip) | ADVISORY_AT_QA | GR-B01…B16 |
| CORE-36 | V16-23 / `spec/12 §12.1`: stale git/seam status + `stats`-dict snapshot risk | V04/V05/V11 supersede the stale premise; seam still unapplied (`world3d.gd:108,609`) | COORD seam owner (I11-SEAM) | ADVISORY_AT_QA | GR-A22/A23; GR-A00 |
| CORE-37 | V16-20/O3: canonical map size 240² vs 320² `[U]` | Both literals exist (`config.json:75-76` = 240²; `small_map_64.json` claims 320²) | COORD + I13 | ADVISORY_AT_QA | GR-B01, GR-C02 |
| CORE-38 | V21 U2/GR-C09: `X13_blend_test_vectors.md` absent → no blend vector gate (**superseded**) | X13 landed with 19+4 vectors: 8 donor-flag ReplaceForWater vectors bit-exact, 11 synthetic-flag vectors advisory; **no donor pixel frame** (`reports/X13_blend_test_vectors.md:14-48,214-228`) | X13 / I07 (replay hook) + I13 (capture) | ADVISORY_AT_QA — formula-level vectors only; never promote a synthetic-flag vector to donor fact | GR-C09, GR-B11; I07 stamp unit replay |
| CORE-39 | V17 §0/§7: no spec section carried a READY marker; `spec/00_EVIDENCE_INDEX.md` absent **at V17's read** | `IMPLEMENTATION_PLAN.md:3` blocks every ticket until sections READY (`reports/V17_spec_readiness.md:18,48`); §00 has since landed (X14) but no READY marker was seen at final read | COORD decision at Pass 0 (spec integration, §00 now present, X1–X7) | RESOLVE_BEFORE_IMPLEMENTATION — only the READY markers still block dispatch | all I-tickets |
| CORE-40 | V17 §5 row 1: struct field order / stride / collision tag width / 2× grid / owner / resource_id `[U]` | D04 landed: 37-byte record = 24 B + 13 B, bytes 8–11 = four `u8` tile ids, `(2W)²` tag grid; but per-tile `collision[4]`, owner/visibility and resource pointer were **not found** (`reports/D04_map_format.md:185-205,271-284`) | COORD decision at I06 (emit recovered tile ids; keep absent fields `[U]`) | DOCUMENT_ONLY — no donor value exists for owner/resource_id; do not invent a per-tile field | I06 data container |
| CORE-41 | `spec/01 §5`: height count `(W+1)²−2` vs binary loop `(W+1)²` `[U]` | D04 §7 U1: six passes, observed count accepted for decoding, root cause still `[U]` (`reports/D04_map_format.md:275`) | owner-facing UNVERIFIED — no port value needed (decoder uses observed count) | DOCUMENT_ONLY — no worker can resolve the writer shortfall today; no port value needed | I06/I08 |
| CORE-42 | V16 O6 / V11 Q4: `terrain_new_assets.gd` has no implementation owner | A03 claims it; V11 leaves it unowned on purpose (`reports/V11_ownership_ledger.md:133,248`) | COORD + I06 | RESOLVE_BEFORE_IMPLEMENTATION — decide fold-into-I06 or new ticket before dispatch | I06 |

### 4.1a Late-landing `[U]` items (X13/X21 registers not in V17's §5 gap list)

| Id | Exact `[U]` claim | Why unresolved | Named owner | Disposition | Gate affected |
|---|---|---|---|---|---|
| LATE-01 | X13 U2: exact rounding of rotated sub-cell coordinates | All X13 vectors use `RotationAngle=0`; `fdiv [0x75c1a4]` observed but integer rounding rule not proven (`reports/X13_blend_test_vectors.md:265-267`) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — preserve literal expression; no radius value invented | I02 stamp; GR-A01 (determinism risk) |
| LATE-02 | X13 U4: true x87 80-bit result | X13 ran double and f32 models only; 5/19 vectors differ by 1 ULP (`reports/X13_blend_test_vectors.md:235-241`) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — use `D05-d` column; a 1-ULP gap is not a bug until x87 is emulated | I02/I07 unit replay; GR-A01 |
| LATE-03 | X13 U6: smooth post-pass in-place vs double-buffer update order | All 4 iterations diverge between the two models; D05 F5 pseudocode does not settle it (`reports/X13_blend_test_vectors.md:193-198,270`) | X12 / D05 follow-up (binary second pass) | ADVISORY_AT_QA — I07 must choose and document one; do not call either donor-verified | I07 stamp post-pass; GR-A01 |
| LATE-04 | X13 U7: `HeightFieldSmooth` mask gating / full radial remap | Harness exercises one remapped window and a synthetic patch, not the 8-neighbour occupancy test (`reports/X13_blend_test_vectors.md:271`) | D05 + I02 | DOCUMENT_ONLY — no donor value needed; preserve `Stand && Smooth` gate literally | I02 |
| LATE-05 | X13 U8: `HeightFieldMax` unused by *all* engine paths | D05 E15 proves absence only inside `sub_755f30`; editor/brush paths unchecked (`reports/X13_blend_test_vectors.md:272`) | D05 / X12 follow-up | DOCUMENT_ONLY — no port value needed; stamp never clamps to `[Min,Max]` | I02 |
| LATE-06 | X21 XU4: DScript numeric promotion for `floor(RandomExt*n)` | Both f32-product and f64-product floors supplied; no script-runtime type recovery (`reports/X21_rng_vectors.md:459`) | I07 (choose and label) + D02 | ADVISORY_AT_QA — X21 vectors are the fixture; no donor promotion value invented | I07 RNG ledger; GR-A01 |
| LATE-07 | X21 XU5: first draw for arbitrary nonzero `key0` whose product high word has bit 31 set | Signed path in `sub_4067b8` derived; no known such key and no donor run (`reports/X21_rng_vectors.md:437-444`) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — normal skirmish keys take the positive path; no port value needed | I07 telemetry |

### 4.2 V16 OPEN register (O1–O14; board C6 names O1/O2/O3/O5 as the "4 OPEN clusters")

| Id | Exact `[U]` claim / OPEN item | Why unresolved | Named owner | Disposition | Gate affected |
|---|---|---|---|---|---|
| V16-O1 | V16-04 `m_swamp_12_old` header policy (17×20 lib vs 18×23 binary) | Donor inconsistency confirmed by byte decode; policy not yet signed off | I02/I03 + COORD sign-off at I03 | RESOLVE_BEFORE_IMPLEMENTATION | I03; GR-B15 |
| V16-O2 | V16-19 DLC5 rivers scope; no ford rule | Mask path cited (`generator.cfg:62-64`) but no placement rule; `fordtyp` is a formation field | COORD + F10 | DOCUMENT_ONLY — `OUT_OF_SCOPE` with citation; invent no ford threshold | GR-B15 advisory |
| V16-O3 | V16-20 canonical map size 240² vs 320² | Both literals exist; no canonical overlay pinned | COORD + I13 | ADVISORY_AT_QA | GR-B01, GR-C02 |
| V16-O4 | V16-21 fresh gate baseline execution | V06 plan exists; no unique-id job executed; 575/582/585 unacked | COORD (runner jobs only) | ADVISORY_AT_QA | GR-A00/A03 |
| V16-O5 | V16-22 mask R-channel semantics (class data vs zero) | X19 C-A/C-G resolved intent-vs-pixels; spec/01 §3 / spec/10 §2 still call it `[U]` | COORD decision at I04 (fold X19; store raw R with `ENGINE/UNVERIFIED`) | DOCUMENT_ONLY — contradiction resolved; no R→height mapping for shipped masks | I04; GR-B... |
| V16-O6 | V16-26 unowned `variant3d/scripts/terrain_new_assets.gd` | A03 claimant only; no I01–I13 slot | COORD + I06 | RESOLVE_BEFORE_IMPLEMENTATION | I06 |
| V16-O7 | V16-27 I07 assigned two NEW files (`terrain_donor_gen.gd`, `terrain_donor_tiles.gd`) | "One report/file per worker" convention conflicts with V11 N9/N10 | COORD | RESOLVE_BEFORE_IMPLEMENTATION | I07; I11-COMPOSER (N14) |
| V16-O8 | V16-08 key-mixing function / stage stream derivation | V01 resolved identity re-seed; engine key→state remains `[U]` (CORE-13) | D02 / X01 | DOCUMENT_ONLY — no mix64; no port value needed | GR-A16 |
| V16-O9 | V16-07 mine band gate (`gRecordGeneratorVersion`, `mapsize>2` meaning) | Version=92 and tiny-map enum resolved by V01; which shipped branch ships still `[U]` | D02 + F03 (+ X09) | ADVISORY_AT_QA — record branch in `gen_trace`; no PASS verdict | GR-B09 advisory |
| V16-O10 | V16-15 row-flip / global setter clamp | Row sign not verified; global `sub_0059b934` unstudied (X12 R4, V01 R7) | D05 + D03 (row flip) + owner-facing UNVERIFIED (clamp) | RESOLVE_BEFORE_IMPLEMENTATION for row flip; DOCUMENT_ONLY for clamp (no port value needed) | I02/I07; no clamp in stamp |
| V16-O11 | V16-25 missing water stages / `hmapTex` bind (`CalcTerrain`, `test_shadow`, fog 1) | X11 §4.4 lists MISSING stages; engine samplers/FBO `[U]` | D08 + COORD | ADVISORY_AT_QA — either port explicitly or record accepted gap | GR-B11, GR-C05; I10 |
| V16-O12 | V16-11 forest-interior family choice (two donor-authored lists) | Both lists are donor text (`P05:111`, `V09:422`); no runtime selector found | COORD + D07/F08 | ADVISORY_AT_QA — keep both behind a flagged switch; no silent choice | GR-B07, GR-A21 |
| V16-O13 | V16-12 no donor visual reference for five classes | X07 stills-only; A04 donor-data; V15 three-tier vocabulary reconciles them | COORD / owner | DOCUMENT_ONLY — tiers 1+2 only; parity stays UNVERIFIED | GR-C05, GR-C08 |
| V16-O14 | Z07 `t_relief_props_qa.gd` stale atom | See CORE-33 | I13 / G04 (QA owner) | RESOLVE_BEFORE_IMPLEMENTATION — strengthen, never lower | GR-A24, GR-C11 |

### 4.3 X03 16-item UNVERIFIED register (§8 U1–U16)

| Id | Exact `[U]` claim (X03 §8) | Why unresolved | Named owner | Disposition | Gate affected |
|---|---|---|---|---|---|
| X03-U1 | `RandomExt`/`SetRandomKey` key-mixing algorithm | Script side identity re-seed; engine state update recovered by D02; class identity residual (CORE-13) | D02 / X01 | DOCUMENT_ONLY — no port value needed for determinism | GR-A01; I07 |
| X03-U2 | Engine height-blend operation, clamp/scale order, `HeightFieldScale=-0.925` sign, `row_flip` | D05/X12 resolved blend/sign; `row_flip` remains CORE-01 | D05 (fold-in) + D03 (row flip) | DOCUMENT_ONLY for math; RESOLVE_BEFORE_IMPLEMENTATION for row flip | I02; GR-A18 |
| X03-U3 | `SmoothTerrain` internal power/lerp for `bsmooth` pass | D03 §5.5 recovered the *custom* kernel; native `SmoothTerrain` handler still `[U]` (D03 U3, V01 R1) | D03 (native handler) | DOCUMENT_ONLY — shipped `bsmooth` flags are all false (X19 §0.5); no kernel value needed | I04/I07 (do not invent a kernel) |
| X03-U4 | `tilesmooth_scripts.cfg` `TileNames`/`Prob` contents | F03/X08 parsed all 22 chains/282 entries; X08 V1–V11 vectors derived | COORD decision at I07 (fold X08 §5.5/§7) | DOCUMENT_ONLY — data recovered; doc/vector fold-in only | GR-A18/A19 red |
| X03-U5 | `gc_MaxTerrainTypeCount` value | V01 U9 resolved `=9` (`dmscript.global:236`) | COORD decision at I01/I07 | DOCUMENT_ONLY — value recovered | I01; GR-A16 |
| X03-U6 | Per-shape mask counts 121/187/320/230/122/42/33/280 | V01 U1 resolved with correction: mediterranean **118 selectable / 122 files** | COORD decision at I04 | DOCUMENT_ONLY — value recovered | I04 |
| X03-U7 | Shipping `gRecordGeneratorVersion` | V01 U8 resolved `=92` | COORD decision at I07 | DOCUMENT_ONLY — value recovered | GR-B09 |
| X03-U8 | Exact start-spacing acceptance (0.7 / 1.5–2 cm) | = CORE-28; modder changelog only | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY | I07 stage 7 |
| X03-U9 | R1–R6 relief-generator numeric parameters | = CORE-29; exhaustive negative in donor text and decomp reports | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY | I09; GR-B02 |
| X03-U10 | Standalone mill-field decoration stage / tile rule | V01 U11 resolved: runtime per-field decal (`envfieldd`, 45/225, scale 60, 1.3×), no generation stage | COORD decision at I09 | DOCUMENT_ONLY — premise corrected; doc fold-in only | I09 |
| X03-U11 | Donor units → port tile scale denominator (160 vs 320) | V01 U15 refuted donor-160; only `gc_meters_to_tile=2` is donor-grounded | COORD decision at I06/I08 | DOCUMENT_ONLY — negative finding recovered | I06/I08 |
| X03-U12 | `cstartoffset=60` / `cstartoffsetrnd=25` meaning | V01 U16 resolved: no consumer; vestigial (P9 pass) | COORD decision at I01 (omit or record as declared-unused) | DOCUMENT_ONLY — nothing to implement | I01 |
| X03-U13 | DScript local-variable initialisation semantics | = CORE-26; engine VM lane | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY | GR-B10 advisory |
| X03-U14 | Full `w×h` relief grids and pattern footprint/collision data | = CORE-17/18; F01 landed: byte closure 710/710 and `G=8+(w−1)(h−1)`; residual semantics (`Rec24 id`, weights, tail flags) and `row_flip` `[U]` (`reports/F01_pattern_format.md:546-560`) | COORD at I02 (fold F01) + I02 (`null`+`UNVERIFIED` labels) | DOCUMENT_ONLY — layout closed; only semantic labels remain | I02 emit path; GR-B06 |
| X03-U15 | Winter tile-name availability/mapping beyond `_winter` suffix | V01 U14 resolved vanilla 124/124 index-preserving; desert winter needs F10 | F10 / COORD decision at I05 | ADVISORY_AT_QA — desert aliases labelled UNVERIFIED | I05; GR-B14 |
| X03-U16 | Whether D9 `misc.script` ranges are stable across builds | This install matches cited ranges; total line count differs (7,013 vs 6,765) | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — citation-level only; re-verify before use | none |

### 4.4 P06 28-item register V-01…V-28 (V03 landed; dispositions cross-checked against `reports/V03_open_items_resolution.md §3/§5.2`)

| Id | Exact `[U]` claim / closing evidence required | Why unresolved | Named owner | Disposition | Gate affected |
|---|---|---|---|---|---|
| P06-V01 | Donor GPU parity (hue, silhouette, grain, luma, shore, animation) | No donor GPU A/B frame exists; nothing substitutes (`reports/P06_prior_wave_distill.md:155`; V03 §3/§5.2) | COORD (owner of capture + parity verdict) | DOCUMENT_ONLY — parity ceiling, not a gate blocker | GR-C08 |
| P06-V02 | All integrated gates on landed tree (29/29, 17/17, `t_render_mode`, CLEAN, `app/` byte-identical) | V06/V21 plan exists; no fresh unique-id job executed | COORD decision at I12/I13 | ADVISORY_AT_QA — execution pending; no PASS today | GR-A00/A03 |
| P06-V03 | Matched-camera reviewed post-fix captures incl. water-bearing frame and 64² P0 | No capture lane executed; no fresh 240²/320² baseline | COORD / I13 | ADVISORY_AT_QA | GR-C01/C02 |
| P06-V04 | Shipped 240² default's actual height grid (`--dump-map` + §2 metrics) | No 240² dump on disk (Z01 §4.1); V06 §4.4 recipe planned, not run | COORD / I13 | ADVISORY_AT_QA | GR-B01, GR-C02 |
| P06-V05 | Relief shape classes actually reaching height (`k_ravine_big_stone_*`, `hil1`, `g_hil4`) | V03: PARTIALLY_CLOSED — F01 now supplies exact grids and X13 bit-exact vectors; still no dump showing `applied_cells>0`/height-hash change and no reviewed capture (`reports/V03_open_items_resolution.md:88`) | I02/I03 decoder + COORD/I13 capture | ADVISORY_AT_QA — donor layout closed; visual/dump evidence still open | I02/I07; GR-C02 |
| P06-V06 | Face-promotion rule / 25° `AngleX/AngleZ` entry | Face vocab 0/1/2 and 25° metadata only (V786; V16-13); art gate, not height | D08/X01 (binary) | DOCUMENT_ONLY — no port value needed; never force face promotion | I10; GR-A21 |
| P06-V07 | `mask_to_alpha=0` A/B at identical camera | Requires real `set_shader_parameter` binding + additive config key; never produced | COORD / I13 | ADVISORY_AT_QA | GR-B11 |
| P06-V08 | Live tile histogram on the current frame | No post-Y08/Y10/Y11 dump on disk | COORD / I13 | ADVISORY_AT_QA | GR-B05 |
| P06-V09 | Relief-prop silhouette / placement (props ON/OFF A/B, `matched_stamps>0`) | V07 E05: atom stale on 4 interfaces; no result JSON, no fixture, no capture | I09 + I12/I13 (QA owner) | RESOLVE_BEFORE_IMPLEMENTATION — repoint/strengthen atom first | GR-A24, GR-C11 |
| P06-V10 | Water surface Y, `hmapTex` binding, reflection FBO, foam band width | = CORE-03/04/05; engine bindings `[U]` | D08 + COORD (V16 O11) | ADVISORY_AT_QA | GR-B11, GR-C05 |
| P06-V11 | Tile-id→alpha-patch rule and `bmTransparency` pass count/blend equation | V03: PARTIALLY_CLOSED — X17 factors/equation `[D]`, X13 stamp vectors cover the separate blend formula; composite pass count and patch selector still `[U]` (`reports/V03_open_items_resolution.md:94`) | X17 / D08 (pass count, patch rule) | DOCUMENT_ONLY — no port value needed; do not guess a layer count | GR-B11 advisory |
| P06-V12 | Eye planes `gl_EyePlaneS/T[0]`, `gl_TextureMatrix[0]` numerics | = CORE-06; no runtime trace allowed | D08 | ADVISORY_AT_QA | GR-B12 |
| P06-V13 | Full `w×h` float grids, blend order/sign, `row_flip` | V03: PARTIALLY_CLOSED — blend/math closed (D05/X13), F01 grid offset closed; `row_flip`, global clamp and full active-id semantics still `[U]` (`reports/V03_open_items_resolution.md:96`) | D03 + D05 (row sign) + I02 + X13 follow-up | RESOLVE_BEFORE_IMPLEMENTATION for row sign (CORE-01); DOCUMENT_ONLY for closed math/byte boundary | I02/I07 |
| P06-V14 | Runtime activity of every `[*] = ;`-prefixed `.inc` script | No donor execution permitted; all rules are authoritative *intent* only | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — cannot be closed under the charter | GR-B16 advisory |
| P06-V15 | Which `.map` 37-byte record field is authoritative `tex`; byte +33 meaning | **V03: CLOSED_TODAY** — D04 §4.3: bytes 8–11 = four `u8` tile indices (authoritative `tex`); bytes 32–35 always 0 (byte +33 reserved) (`reports/V03_open_items_resolution.md:98`) | D04 (landed) + COORD decision at I06 (fold into §01) | DOCUMENT_ONLY — donor-structure item closed; only doc fold-in remains | I06 stride |
| P06-V16 | Donor metres-per-cell, mesh LOD/tessellation, exact normal formula | = CORE-11; metres=2 recovered, LOD/normal are engine internals | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY | I08 |
| P06-V17 | `StandPatternWithAngle` transform math, N prop records, scale/yaw/winter/desert props | X12 corrected the native call chain; transform math still `[U]`; prop placement is PORT APPROX | X12 + I09 | DOCUMENT_ONLY — no donor value needed for a render-only consumer | GR-C05; I09 |
| P06-V18 | Mill field 3D decal `w` unit, 49-node survival, record-id→prop binding | F07/V01 recovered 49 nodes @1.6981 cells and `texscalefix=1.3`; 3D UV and `w` unit `[U]` | I09 + I10 | ADVISORY_AT_QA — 49-node rule donor-grounded; UV/port decision labelled | GR-C05 |
| P06-V19 | Rotor world-space spin sense, per-map overrides, editor "R" hotkey | M02: 0.751 rad/s local-Y rotation, no in-game rotation; sense needs a frame | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY | I09 |
| P06-V20 | Season/biome runtime activity, fog mode 1 vs "off by default", SM20/SM30 | Text-only; X11 §4.4 lists fog mode 1 as MISSING (default 0 inert) | F10 / D08 | DOCUMENT_ONLY — no port value needed for skirmish default | I10 |
| P06-V21 | Exact post-B03/post-Y08 tileblock dump for the captured frame | No matching dump for any captured frame | COORD / I13 | ADVISORY_AT_QA | GR-A03; GR-C01 |
| P06-V22 | Which edit changed the rings' colour; quantitative maze share | Legacy diagnosis only; fresh module does not inherit the Y08 final-authority path | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — out of scope for fresh module | none |
| P06-V23 | Post-fix mask-vs-atlas streak share, sentinel black cells, mip seam LOD spikes | No live capture/metric; port's sentinel/mip handling is PORT APPROX | I10 + I13 | ADVISORY_AT_QA | GR-B14, GR-C07 |
| P06-V24 | Colour B/G and b* bands, low-frequency BV32 deficit (~28.6×) | Offline replay is not a live histogram; metrics are hints only | I13 / COORD | ADVISORY_AT_QA | GR-C07 (SMOKE only) |
| P06-V25 | Runner hygiene, backup byte identity, static parse, season atlas consistency | V06 §4.1–4.3 plans; not executed | COORD / I12 | ADVISORY_AT_QA | GR-A00, GR-A22 |
| P06-V26 | Loading stall S3/S4 and G17 cost ratios | Analysis only, never profiled; out of scope today | owner-facing UNVERIFIED — no port value needed | DOCUMENT_ONLY — no port value needed; analysis-only item | none |
| P06-V27 | Anisotropy A/B (Y10/Y11 APPLIED_NOT_CAPTURED) | No matched-camera capture; `array` atlas transport has no mips so hint is inert | COORD / I13 | ADVISORY_AT_QA | I10; GR-C01 |
| P06-V28 | Mine magnetic snap and four-patch field quad are proposals only | F2-03/F2-04 proposals; owner must choose donor 49-node count or labelled PORT APPROX quad | COORD + I09 | DOCUMENT_ONLY — owner-facing policy; no donor value invented | GR-C05 |

### 4.5 Cross-check: V17 §5 ten rows → entries above

| V17 §5 row | Covered by |
|---|---|
| §01 field order/stride/collision/owner/resource_id; row sign/TILE_M | CORE-01, CORE-02, CORE-40, CORE-41 |
| §04/§10 row-sign flip, global clamp, rotation rounding; 16 A02 constants | CORE-01, CORE-16, CORE-17, V16-O10, X03-U2, X03-U3 |
| §05 −0.5 runtime, bmTransparency factors/pass count, ford, hmapTex FBO/bind, plane Y, metres-per-cell | CORE-03…CORE-11, V16-O2/O11 |
| §06 live selection, cliffs/covers stubs, bmTransparency factors, desert winter | CORE-07, CORE-08, CORE-21…CORE-23, X03-U15 |
| §07 deposit amount, mapsize enum, `gDataVersion`, local-init, family→ore | CORE-24…CORE-30 |
| §08/§11 relief grid/object tail, desert season, atlas downsample, field/mine placement | CORE-17/18/20/23, P06-V18 |
| §09 cfg key meanings | CORE-31 |
| §12 donor numeric ranges, unacked failures, stale Z07 atom, stats-dict | CORE-32…CORE-36, V16-O14 |
| §13 28 open items V-01…V-28 | §4.4 + `reports/V03_open_items_resolution.md:80-111,166-183` (V03 landed during this ticket) |
| §02 save-map key bytes, instance identities, key→state | CORE-12…CORE-15 |

## 5. Priority list A — must resolve before I07 (and the named I0x/I12 gate that owns each)

1. **CORE-39** — COORD Pass 0: `spec/00_EVIDENCE_INDEX.md` has landed (X14); remaining work is closing X1–X7 and explicitly marking sections READY. Blocks every ticket by `IMPLEMENTATION_PLAN.md:3`.
2. **CORE-40 / CORE-41 / P06-V15** — **D04 and V03 have landed**: fold the recovered 37-byte `.map` record (bytes 8–11 = tile ids), the observed height count and the absent per-tile owner/collision/resource fields into §01; no report must land, only the COORD/I06 doc decision.
3. **CORE-17 / CORE-18 / X03-U14 / P06-V05 / P06-V13** — **F01 has landed**: the `.pattern` byte boundary is closed (`G=8+(w−1)(h−1)`, 710/710). I02 may proceed; COORD must relabel §04 §6/§7 and §11.3 and require `null`+`UNVERIFIED` for the still-unidentified record semantics.
4. **CORE-01 / V16-O10 (row-flip half) / X03-U2 / P06-V13** — **D05 + D03**: file-row→world-y sign. Blocks I02 stamp translation and I07 stage order.
5. **CORE-19 / V16-O1** — **COORD sign-off at I03**: quarantine `m_swamp_12_old`, use binary 18×23 as geometry authority, never abort the 680-record parse.
6. **CORE-42 / V16-O6** — **COORD decision at I06**: fold or ticket `terrain_new_assets.gd`; do not create it by implication.
7. **V16-O7 / CORE-38** — **COORD decision at I07**: confirm I07 owns both `terrain_donor_gen.gd` and `terrain_donor_tiles.gd`, and that N14 composer exists before the seam.
8. **CORE-25 / CORE-30 / V16-O9** — **COORD at I07**: fold V01's `mapsize>2 = 256 tiny`, `gDataVersion=92`, ring→ore grouping into §07/§10 before the stage pipeline is written.
9. **CORE-32** — **COORD at I12 stage A′**: `ack --reason` 575/582/585, then plain CLEAN, before any fresh gate result can be claimed.
10. **CORE-33 / V16-O14 / P06-V09** — **I13/G04 QA owner**: repoint and strengthen `t_relief_props_qa.gd` (path, node type, scale, stamp count, fixture) before I12 sign-off; never lower an expectation.

## 6. Priority list B — may stay advisory at QA (labelled PORT APPROXIMATION, no donor value needed to implement)

- **Water/binding set**: CORE-03 (`−0.5` runtime), CORE-04 (`hmapTex` FBO/bind), CORE-05 (plane Y), CORE-06 (eye planes), V16-O11 (missing `CalcTerrain`/`test_shadow`/fog 1), P06-V10, P06-V12. Gates GR-B03/B11/B12, GR-C05.
- **RNG internals that do not affect the numeric stream**: CORE-13 (class identity), CORE-15, V16-O8, X03-U1, P06-V01 (parity ceiling); LATE-06 (DScript floor promotion) and LATE-07 (signed `key0` edge) use X21's vectors/labels.
- **Coverage/tier gaps**: CORE-20 (atlas downsample tier), CORE-23/X03-U15 (desert winter aliases — re-check landed F10), P06-V18 (3D field decal UV), LATE-03 (in-place vs double-buffer post-pass order — document the choice).
- **Scope/policy switches**: V16-O9 (which mine branch ships — record in `gen_trace`), V16-O12 (two forest-interior lists), CORE-37/V16-O3 (240² vs 320² overlays).
- **Gate-policy `[U]` bands**: CORE-34 (stale JSON regeneration), CORE-35 (GR-B01…B16), CORE-36 (seam/stats snapshot), CORE-38 (X13 landed: formula vectors only, never a pixel gate), V16-O4, P06-V02…V04, V06-V07…V08, V10, V21, V23…V25, V27.
- **Capture-only items**: P06-V03/V04/V07/V08/V21/V24/V27 (owner-only runner jobs; no analysis-worker job).

## 7. Priority list C — document only (no worker can resolve today / no port value needed)

| Id | Reason it is DOCUMENT_ONLY |
|---|---|
| CORE-02, CORE-17, CORE-18, CORE-25, CORE-27, CORE-30, CORE-31, CORE-40, CORE-41, CORE-07, CORE-16, X03-U2 (math half), X03-U4…U7, X03-U10…U12, V16-O5, P06-V15 | Value/layout already recovered by F01/D04/V03/V01/V11/X17/X19/D05/X12/D03; only a COORD spec fold-in remains — no new donor value may be invented. |
| CORE-08, CORE-09, CORE-10, CORE-11, CORE-12, CORE-13, CORE-14, CORE-15, CORE-21, CORE-22, CORE-24, CORE-26, CORE-28, CORE-29, CORE-38 (V16-O2), X03-U1/U3/U8/U9/U13/U16, V16-O8, LATE-01/02/04/05/07, P06-V06/V11/V14/V16/V17/V19/V20/V22/V26/V28 | No donor value exists or is recoverable under the read-only charter (negative findings, modder changelog, external manual, engine VM/GPU internals/x87 exactness, owner policy). Recording `[U]` with the passes attempted is the only honest closure. |
| V16-O13, P06-V01 | Parity ceiling: no donor GPU A/B frame; tier-2 self-consistency only. |

## 8. Risks

1. **[D] Invented-value risk is the main hazard.** R1–R6 numeric ranges, start-spacing centimetres, `GenerateMapRandKey` derivation, saved-map key bytes and composite pass count have all had exhaustive negative passes; any "plausible" number would violate `CHARTER.md:84` and create a false donor claim.
2. **[D] Stale `[U]` misread as open.** CORE-07/16/25/30 are already resolved in X17/V01/D05/X12; implementing from the stale spec text could reintroduce the additive-clamp model, per-ore mine radii, donor-160 scaling or a `>58` water off-by-one.
3. **[O] "4 OPEN" undercounts.** `SWARM_BOARD.md:71` names V16 O1/O2/O3/O5, but `reports/V16_contradiction_register.md:108-123` records O6 and O7 as OPEN too — both are dispatch prerequisites for I06/I07. Treating only four as open would leave two unowned tickets.
4. **[O] V03 no longer an orphan, but most items stay open.** V03 landed with 1 CLOSED_TODAY / 16 PARTIALLY_CLOSED / 11 STILL_OPEN; `spec/13 §4` should be updated by COORD. Treating the 28 items as "resolved" because a report now exists would violate P06 §4's hard-evidence rule (GPU frame / fresh dump / fresh runner JSON).
5. **[D] Advisory hardening.** V21 class-B bands must not flip to `red` before V17 READY + N17 donor evidence + COORD sign-off (`reports/V21_gate_register.md:129-131`); a green metric is never parity.
6. **[U] Spec drift.** V17/V21/X08/X12/X17/X19 landed after the earlier audits; line numbers in `spec/03 §32-33` and `spec/05 §28` are stale (X19 C-F/C-C). Re-read before any edit.
7. **[D] `owner-facing UNVERIFIED — no port value needed` is a label, not a worker.** COORD must explicitly accept this form as satisfying the "named owner" requirement of V17 C8; otherwise every DOCUMENT_ONLY row needs a human owner reassignment.
8. **[U] Epistemic ceiling.** No donor GPU A/B frame exists; every verdict here is a value/line/count adjudication, never a visual-parity claim.

## 9. Open questions

1. **COORD:** accept the three-form owner vocabulary (worker id / COORD decision at Ixx / owner-facing UNVERIFIED — no port value needed) as closing V17 C8?
2. **COORD:** sign V16 O1 (swarm header quarantine) and O7 (I07 two-file ownership) before I03/I07 dispatch?
3. **COORD:** confirm the F01/D04 fold-ins (`.pattern` grid offset and `.map` record) into §04/§01, and that I02/I06 keep `null`+`UNVERIFIED` for the still-unidentified record semantics under `spec/11 §11.1`?
4. **COORD:** adopt V03's §5.2 owner list for the 28 P06 items, with §4.4 above as the disposition cross-check; update `spec/13 §4` accordingly?
5. **COORD at I10:** fold X17's `[D]` blend factors into §05/§06 while keeping pass count `[U]` and refusing to invent a two-pass layer count?
6. **COORD/I12:** accept V06 §4.1's three `ack --reason` strings verbatim and regenerate all five stale JSONs with unique ids?
7. **Owner:** can a donor GPU A/B frame ever be produced? Until yes, every item in §7's parity rows stays DOCUMENT_ONLY.

## 10. Five-line summary

1. **[O] V17's last gap is closed on paper**: every remaining `[U]` item now has an id, exact claim, reason, named owner (worker id / COORD decision at Ixx / owner-facing UNVERIFIED — no port value needed), disposition and affected gate (§4.1, §4.1a, §4.2–§4.4).
2. **[D] 8 items must resolve before I07/dispatch**: COORD Pass 0 READY markers (§00 landed), D03/D05 row sign, COORD sign-off at I03/I06/I07, and I12/I13 gate remediation (acks + Z07 atom). F01/D04/V03/X13/X21 landed during this ticket and are now fold-ins, not missing reports.
3. **[D] 11 items may stay advisory at QA**: water/bindings (`−0.5`, `hmapTex`, plane Y, eye planes), atlas downsample tier, mine-branch and forest-family switches, post-pass update order, DScript floor promotion, and all V21 class-B/C bands — all labelled PORT APPROXIMATION.
4. **[U] 30 items are DOCUMENT_ONLY with reason**: already-resolved labels (fold in F01/D04/V03/V01/X17/X19/X21/D05 values), exhaustive-negative donor internals (R1–R6, start-spacing cm, `GenerateMapRandKey`, saved-map bytes, composite pass count, x87 exactness), and the parity ceiling; no value was invented to close any of them.
5. **[U] No parity claim**: no donor GPU A/B frame exists; V03 landed with 1 CLOSED_TODAY / 16 PARTIALLY_CLOSED / 11 STILL_OPEN and its owners are cross-checked in §4.4; nothing here certifies donor fidelity.

*End of V27 report. Exactly one repo file written; no spec, source, shader, config, asset, test, git, Godot, runner or donor state changed. PORT APPROXIMATION / UNVERIFIED throughout; no donor visual parity claimed.*
