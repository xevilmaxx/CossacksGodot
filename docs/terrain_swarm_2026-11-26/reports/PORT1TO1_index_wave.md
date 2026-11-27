---
id: PORT1TO1-INDEX-WAVE-2026-11-27
title: "Full 1:1 Cossacks 3 donor port - delta index wave (read-only, post-final3)"
worker: INDEX-WAVE (read-only subagent; exactly one repo file written)
wave: PORT1TO1 / terrain_swarm_2026-11-26
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_index_wave.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_index_wave.md]
files_edited: []
created: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
scope_guard: "Repo file/line reads plus point-in-time glob/grep/read-only filesystem listing only. No source, shader, config, asset, test, fixture, manifest, result JSON, backup, queue, git state, Godot process, runner job, gate, capture, ROI metric, donor binary or donor GPU frame was created, modified, executed, copied or hashed. Exactly one repository file written: this report."
supplements:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_index_final3.md (33-row delta; this wave lists ONLY reports absent from it and prior indexes)
labels: [O, D, U, PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD, NO_GATE_PASS, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED (condition 6 PARTIAL port-internal only); no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# PORT1TO1 — index wave delta (post-final3, read-only)

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **PARITY IS UNVERIFIED.** `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`. **Index presence implies no claim and no gate PASS**: every row below is evidence of file existence and of the named report's own text only. No `[O]`/`[D]` one-liner is re-derived or validated here; every `[U]` is the cited report's own classification. `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation is endorsed, no `[U]` is closed, no metric is promoted, and no donor GPU A/B frame is asserted by this document.

> **READ-ONLY DELTA.** This index enumerates **ONLY** report files not already present in `PORT1TO1_index_final3.md` (and prior indexes/supplements where cross-listed). It does not re-list or re-adjudicate any already-indexed report. A later report does **not** make an earlier claim true. Two named items are **PENDING by artifact absence** (no file observed at this read) and are marked PENDING, not described.

## 0. Enumeration basis

- This wave covers the ~25 landed reports since final3: the 17-report decomp wave, the terrain/asset wave, claim rechecks 12–13 (+14 PENDING), `wave_sync`, and the pending GAP-CORRECT revision to `terrain_gap_packet`.
- `PORT1TO1_index_final3.md` text was grepped for every name below: **zero matches** (none of these rows appears in final3). Prior-index spot-checks (original 300-row index, addendum, deep supplement, deep index 2, bundle index) likewise show no match for the wave names (only an incidental `V66_asset_gap_final` substring on the word `asset_gap`).
- **30 reports landed and are listed exactly once below; 2 further items are PENDING by artifact absence** (`PORT1TO1_claim_recheck14.md` — no file; GAP-CORRECT revision to `terrain_gap_packet` — only the `.bak-GAPCORRECT` pre-image observed, no revised packet landed).

**Reading key:** each row gives report file / frontmatter id, a one-line `[O]`/`[D]`/`[U]` recovery pointer plus status, and a relative evidence pointer. Statuses are the cited reports' own frontmatter strings.

## A. Decomp wave (17)

| Report file | id | One-line `[O]`/`[D]`/`[U]` recovery + status | Evidence pointer |
|---|---|---|---|
| `DEC_U_b1_glcopy_callers.md` | DEC-U-B1-GLCOPY-CALLERS-2026-11-26 | `[O]` both copy imports have zero discovered users; `0x4afb3c` = container `sub_4aff8c` 0 callers + 1 DATA ref; `0x4ed44c` in undiscovered gap. `[D]` only chain `sub_6760a0→sub_7744cc→sub_7715f4→sub_4ed28c→glTexImage2D@thunk`, NO copy call; bind chain disjoint. `[U]` reflection identity/scalar tuple/frame timing. Status DELIVERED, RESULT IS NOT GOOD, 0/6. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b1_glcopy_callers.md) |
| `DEC_U_b2_ureg_callers.md` | DEC-U-B2-UREG-CALLERS-2026-11-26 | `[O]` 3/4 targets absent from xref DB; `sub_739bf8` = 7-insn getter `[obj+0xb4]`, not a `+0x50`/`+0x200` writer. `[D]` structural negatives only (zero `+0x200`, zero gate/GL reachability). `[U]` live target/name/w/h + 4-tuple. Status DELIVERED, 0/6. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b2_ureg_callers.md) |
| `DEC_U_b3_callback_sweep.md` | DEC-U-B3-CALLBACK-2026-11-27 | `[O]/[D]` L1/L2 Delphi LCG + QPC/GTC seeder, 15 `Random` sites, shared registrar `sub_706880`, global slots `+0x108/+0x10c`. `[U]` all live timing/value (U-INVOKE/U-KEY/U-MAP/U-SS/U-ONLY/U-TIME/reseed/copy-values). Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b3_callback_sweep.md) |
| `DEC_U_b4_smooth_native.md` | DEC-U-B4-SMOOTH-NATIVE-2026-11-27 | `[O]` zero `SmoothTerrain`/`MapGenerator` candidate functions; `sub_608238` = 331-indirect-call registrar ending `al=1`, no height loop/float. `[D]` none recovered. `[U]` kernel VA/radiusFloat/loop bounds/`mb`-consumer stay `[U]`. Status DELIVERED, 0/6. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b4_smooth_native.md) |
| `DEC_U_b5_ver_residual.md` | DEC-U-B5-VER-RESIDUAL-2026-11-27 | `[O]` 17 version/envelope literals 0 hits; indexed versions RTTI + PE-file-version only; `0x710be0` data-as-code; `0x71c0b4` 922-insn data-as-code. `[D]` none. `[U]` selector/defaults/53-vs-92 binding + liveness. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b5_ver_residual.md) |
| `DEC_U_b8_coll_los.md` | DEC-U-B8-COLL-LOS | `[O]` 369 building / 140 unit `.prop` census, 0 Rotate/Reflect overrides, 18 `objprop.radius` overrides, 4 ctpo consumers, 12-float LOS set. `[D]` static inventory only. `[U]` live radius/mask/footprint/ctpo/LOS-math/FOW-edge/inertia/raycast. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b8_coll_los.md) |
| `DEC_U_b13_dsp_code_sweep.md` | DEC-U-B13-DSP-CODE-SWEEP-2026-11-26 | `[O]/[D]` `0x68xxxx–0x6axxxx` prototype-run CODE-table extension; static loop-bound/stage literals only. `[U]` live stage order/timing. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b13_dsp_code_sweep.md) |
| `DEC_U_b14_fow_native.md` | DEC-U-B14-FOW-NATIVE | `[O]/[D]` UpdateFOW/victorystate/GetFOWLOSData/FOWBuildFull + XFOWRender/TLOS*/FOWRender RTTI-layout static sweep; structure/call-graph/absence facts only. `[U]` P0-3/F-GRID/persistence/F1-NUM/tint/live ordering. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b14_fow_native.md) |
| `DEC_U_dsp_stage_order.md` | DEC-U-DSP-STAGE-ORDER-2026-11-26 | `[O]/[D]` per-frame call-sequence angle vs B13 26-call registration order `sub_706880` (`0x686cbc→0x68b7d8→0x69a70c`); static bytes only. `[U]` live tick order. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_dsp_stage_order.md) |
| `DEC_U_cam_derive.md` | DEC-U-CAM-DERIVE | `[O]` text-only sweep: start→camera wire `doprogress.inc:41`, producer `dogenerate.inc:1939`, Home `onshortcut.inc:1000`, origin `docreate.inc:297`; zoom `0.75` = PORT CHOICE. `[D]` path-scope supersession carried. `[U]` CAM-derive/CAM-0 (final target/height, time=0 smoothing). Status DELIVERED, NO PARITY CLAIM. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_cam_derive.md) |
| `DEC_U_d4_floats.md` | DEC-U-D4-FLOATS-2026-11-27 | `[O]` static donor-text sweep: dlt transfer / market-price computation, 36-float table. `[D]` none promoted. `[U]` D4/U6-T/DLT price semantics stay `[U]`/blocking unless excluded. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_d4_floats.md) |
| `DEC_U_b6_g0_density.md` | DEC-U-B6-G0-DENSITY-2026-11-26 | `[O]/[D]` static fixed-seed mask check for `fdens==0` off-starts (density angle). `[U]` G0 stays `[U]`/blocking. Status DELIVERED, chain 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b6_g0_density.md) |
| `DEC_U_speed_consumers.md` | DEC-U-SPEED-CONSUMERS-2026-11-26 | `[O]/[D]` full-tree `.speed :=` / `rotatespeed :=` / `speedperc` re-sweep; live vs commented vs definition-only; U-base-speed split (not a 72nd row). `[U]` live speed values. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_speed_consumers.md) |
| `DEC_U_b11_ai.md` | DEC-U-B11-AI (title-row; no frontmatter id block) | `[O]/[D]` `ProgressEconomicAI` vs `ProgressWarAI` split, resbalance mine levels, officer-wait/squad timing, 37 `ExecuteState` sites, `[*] = ;` container D-rows (static reads only). `[U]` all AI timing/behaviour values. Status DELIVERED read-only static, parity UNVERIFIED. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b11_ai.md) |
| `DEC_U_b12_peace.md` | DEC-U-B12-PEACE-2026-11-27 | `[O]` S-MKT/Q2/VIC/PEACE static sweep (market prices NOT redone; upgrade law/rows + peace chain carried). `[D]` none promoted. `[U]` B12 values stay `[U]`. Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b12_peace.md) |
| `DEC_U_b10_resid.md` | DEC-U-B10-RESID | `[O]` residual re-read: `SetObjBaseProtection` 33 hits = 1 def + 32 calls, no residual; `unit/weapon/player.script` + `startingsettings.cfg` + write/read field order, zero-fill omissions. `[D]` static literals only. `[U]` all live skirmish behaviour. Status DELIVERED, parity UNVERIFIED. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_b10_resid.md) |
| `DEC_U_grass_basename.md` | DEC_U_GRASS_BASENAME | `[O]` donor DOES ship standalone grass prop records (`grass[.1–5]`, `grasschamomile`, `grassdesert/forest/leafforest`, `horseradish[1–3]` with `.prop`+`BaseName`+`.actor`+`.osm`); tile-block grass is a SEPARATE namespace — conflation refused. `[U]` every port-side resolution (no `grass*.obj`, no `map_Kd.*grass`, no manifest). Status DELIVERED, parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/DEC_U_grass_basename.md) |

## B. Terrain completeness (1)

| Report file | id | One-line `[O]`/`[D]`/`[U]` recovery + status | Evidence pointer |
|---|---|---|---|
| `PORT1TO1_terrain_completeness.md` | PORT1TO1-terrain-completeness-2026-11-27 | `[O]/[D]` full-stack landscape audit (map-gen/water/vegetation/props/assets/tools); two prior snapshot claims corrected live (§6) but still UNVERIFIED at runtime. `[U]` every subdomain; nine P0 OPEN. Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD; existence-only. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_completeness.md) |

## C. Assets (5 landed + grass correction carried in A)

| Report file | id | One-line `[O]`/`[D]`/`[U]` recovery + status | Evidence pointer |
|---|---|---|---|
| `PORT1TO1_terrain_assets.md` | PORT1TO1-TERRAIN-ASSETS | `[O]/[D]` landscape-asset coverage audit ([V] verified-this-pass vs [C] carried); forests/trees/grass/fields/stones/props/AAF-FX/death/tool-skins. `[U]` coverage gaps stay open. Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD; no completeness declared. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_assets.md) |
| `PORT1TO1_asset_gap_a.md` | PORT1TO1-ASSET-GAP-A | `[O]/[D]` static attack on 668-vs-680 sections, death-OBJ bytes, `desert_frt_un` gaps. `[U]` gaps stay open. Status DELIVERED, parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_a.md) |
| `PORT1TO1_asset_gap_b.md` | PORT1TO1-ASSET-GAP-B | `[O]/[D]` grass-material wiring + 40-action vs T1–T26 set-difference attack; both flags OPEN, no mismatch asserted. `[U]` [U]-GRASS + action-set residuals (see supersession flag S-2: grass gap now REAL per `grass_basename`). Status DELIVERED, parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_b.md) |
| `PORT1TO1_terrain_gap_packet.md` | PORT1TO1-terrain-gap-packet-2026-11-27 | `[O]/[D]` owner-facing work packet: 11 missing-work items (MW/NG/AP) with WORKER-EXECUTABLE-STATIC vs OWNER-GPU-RUNTIME vs OWNER-DECISION binding rules. `[U]` nothing closed; nine P0 OPEN. Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. **GAP-CORRECT revision: LANDED** (`docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_gap_packet.md` — 15 label-only line changes vs `.bak-GAPCORRECT` pre-image with byte-exact revert proof; see flag S-5). | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_gap_packet.md) |
| `PORT1TO1_terrain_statverify.md` | PORT1TO1-terrain-statverify-2026-11-27 | `[O]/[D]` static verification of WORKER-EXECUTABLE-STATIC packet items; all STILL OPEN (disk checks cited); owner-only items out of scope. `[U]` every item. **Correction: AN-1/AN-5 misclassifications recorded here** (see flag S-1). Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_statverify.md) |
| `PORT1TO1_death_obj_bytes.md` | PORT1TO1-DEATH-OBJ-BYTES | `[O]` 48 derived death OBJs exist (existence RESOLVED, supersedes gap_a G2 existence question). `[D]` port OBJ text-parse counts only. `[U]` byte/vert/bbox verification stays `[U]` — no donor-specified port byte/vert/bbox exists (binary-OSM vs text-OBJ, NOT-RECOVERABLE by construction). Status DELIVERED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_death_obj_bytes.md) |

## D. Audits / synthesis (6 landed + 1 pending)

| Report file | id | One-line `[O]`/`[D]`/`[U]` recovery + status | Evidence pointer |
|---|---|---|---|
| `PORT1TO1_wave_synth.md` | (wave synthesis; id per title row) | `[O]/[D]` interim synthesis of 11 landed static reports incl. B1/B2/B3/B4/B5/B8 tables (byte-proven `[D]` vs surviving `[U]` per report). `[U]` no P0 row retired, no class-A item closed; all static narrowings only. Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_wave_synth.md) |
| `PORT1TO1_wave_synth2.md` | PORT1TO1-WAVE-SYNTH2-2026-11-27 | `[O]/[D]` final terrain/landscape-wave synthesis folding completeness/assets/gap-packet/gap-a/gap-b/recheck13 + B10/B11/B12/D4/G0/speed/cam rows. `[U]` wave closes nothing. Note: its §-pending labels for STATVERIFY/GRASS-BASENAME/DEATH-OBJ-BYTES were **stale at this read** — all three artifacts have since landed (rows above); **CORRECTED by COORD** (plan rows 305–307 DONE, label-only, no claim/value change). Parity UNVERIFIED, 0/6. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_wave_synth2.md) |
| `PORT1TO1_video_internal_review.md` | (Video-Internal Review; no frontmatter id) | `[O]` port-internal deterministic-frame defect detection only (recomputed sizes/hashes/channel stats; `byte_identical=TRUE` = port-internal repeatability, condition 6 PARTIAL). `[U]` parity; explicit negatives: no donor A/B, no matched camera, no COORD ruling. Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_video_internal_review.md) |
| `PORT1TO1_claim_recheck12.md` | PORT1TO1-CLAIM-RECHECK12-2026-11-27 | `[O]/[D]` 14-worker decomp-wave parity-claim/supersession/false-verbatim/closing re-sweep over all current reports + HANDOFF + plan + live `variant3d/`. `[U]` closes nothing. Status DELIVERED, 0/6, nine P0 OPEN, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck12.md) |
| `PORT1TO1_claim_recheck13.md` | PORT1TO1-CLAIM-RECHECK13-2026-11-27 | `[O]/[D]` terrain/landscape-wave parity-claim re-sweep (completeness + assets + gap_a + gap_packet vs plan + live `variant3d/`). `[U]` closes nothing. Status DELIVERED, 0/6, nine P0 OPEN, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck13.md) |
| `PORT1TO1_claim_recheck14.md` | — | **LANDED** (`docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck14.md` — verified 5 reports + GAP-CORRECT packet clean; parity UNVERIFIED, chain 0/6, RESULT IS NOT GOOD). | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck14.md) |
| `PORT1TO1_wave_sync.md` | (Wave Sync; title-row id) | `[O]/[D]` read-only plan internal-consistency audit of the 20-worker decomp wave (298-row current tree at its read; numbering 1..N PASS). `[U]` closes nothing; plan-vs-reports consistency only. Parity UNVERIFIED, 0/6, RESULT IS NOT GOOD. | [report](docs/terrain_swarm_2026-11-26/reports/PORT1TO1_wave_sync.md) |

---

## Supersessions / corrections (flags, not resolutions)

A later report does **not** make an earlier claim true. Every flag below is carried as a status label only; no `[U]` is closed, no value is wired, no gate is passed.

| # | Subject | Exact reading in this delta | Status |
|---|---|---|---|
| S-1 | **AN-1 / AN-5 misclassifications (STATVERIFY correction)** | `PORT1TO1_terrain_statverify.md` records corrected classifications for packet items AN-1 and AN-5 (see its verification table §1, Corrected-classification column). The packet's prior labels stand corrected by this report; the underlying gaps remain STILL OPEN. | **CORRECTION CARRIED, LABEL-ONLY.** No item closed, no parity consequence. |
| S-2 | **Grass prop gap now REAL (grass_basename supersedes asset_gap_b unresolved state)** | `PORT1TO1_asset_gap_b.md` §§ left `[U]-GRASS` unresolved (material-wiring angle, both flags OPEN). `DEC_U_grass_basename.md` §§0–1 byte-proves donor standalone grass/horseradish prop records exist and separates the prop-grass namespace from tile-block grass, converting the gap from "unresolved whether gap" to **REAL gap** (port side: no `grass*.obj`, no `map_Kd.*grass`, no manifest). | **SUPERSESSION: unresolved → REAL gap.** Port resolution stays `[U]`; no parity claim. |
| S-3 | **Death OBJ existence RESOLVED, bytes `[U]`** | `PORT1TO1_asset_gap_a.md` G2 questioned 48/48 death-OBJ existence. `PORT1TO1_death_obj_bytes.md` §§ resolves **existence** (48 derived OBJs on disk) but keeps **byte/vert/bbox `[U]`**: no donor-specified port byte/vert/bbox exists (donor binary OSM vs port text OBJ), NOT-RECOVERABLE by construction. | **PARTIAL SUPERSESSION (existence only).** Bytes stay `[U]`; no gate PASS. |
| S-4 | **wave_synth2 pending labels stale** | `PORT1TO1_wave_synth2.md:17-20` marks TERRAIN-STATVERIFY / GRASS-BASENAME / DEATH-OBJ-BYTES as PENDING by artifact absence at its write. At this read all three artifacts exist (rows in B/C above); the PENDING labels were therefore **stale status labels**, not current state; **CORRECTED by COORD** (plan rows 305–307 DONE, label-only). The underlying `[U]`s those reports carry are unchanged. | **STALE-LABEL FLAG CORRECTED by COORD, NOT A CLOSURE.** |
| S-5 | **GAP-CORRECT revision: label-only, PENDING** | Only `PORT1TO1_terrain_gap_packet.md.bak-GAPCORRECT` (pre-image, same id `PORT1TO1-terrain-gap-packet-2026-11-27`) was observed at this read; GAP-CORRECT has since **LANDED** (15 label-only line changes with byte-exact revert proof). The revision is **label-only** per task brief and changes no parity state. | **LANDED, LABEL-ONLY.** Revised packet text stands; pre-image preserved. |
| S-6 | **Claim-recheck chain continuity** | `PORT1TO1_claim_recheck12.md` (14-worker decomp wave) and `PORT1TO1_claim_recheck13.md` (terrain/landscape wave) each end 0/6, nine P0 OPEN, 71 open `[U]` (A42/B14/C5/D10), RESULT IS NOT GOOD. They supersede nothing; they re-sweep and re-affirm the guard. Recheck-14 has since **LANDED** (row above). | **CARRIED / REAFFIRMED, NO CLOSURE.** |

## Global parity statement

`parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`. No donor GPU A/B frame exists under the read-only rule; no admissible matched capture, no demonstrated donor geometry-byte equality and no explicit COORD ruling exists. The six-condition chain remains **0/6 CLOSED** (condition 6 **PARTIAL**, port-internal repeatability only). `blocking_unverified` is non-empty (nine P0 rows OPEN plus the `[U]` tails carried by the rows above, including G0/D4/price/grass/death-bytes), so **`RESULT IS NOT GOOD`** for acceptance. Nothing in this delta closes a `[U]`, promotes a metric, accepts an approximation or upgrades any report to a gate PASS. Index presence implies no claim and no gate PASS; every listing, recovery one-liner and status cell above is a reproducible navigation aid only. No approximation is made and no parity claim is made.

*End of PORT1TO1-INDEX-WAVE. Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_index_wave.md`. No source, shader, config, asset, test, fixture, result JSON, backup, queue, git, Godot, runner, gate, capture, ROI metric, donor binary or donor GPU frame was created, modified or executed.*
