# PORT1TO1 — Terrain/landscape wave final synthesis 2 (owner-facing, read-only)

- id: PORT1TO1-WAVE-SYNTH2-2026-11-27
- worker: WAVE-SYNTH2 (read-only final synthesis, full 1:1 Cossacks 3 donor port)
- date: 2026-11-27
- scope: final synthesis of the terrain/landscape wave only. No code/Godot/git/donor-execution; no other edits.
- sources folded (all read-only, all parity-UNVERIFIED):
  `PORT1TO1_terrain_completeness.md` (TERRAIN-COMPLETE),
  `PORT1TO1_terrain_assets.md` (TERRAIN-ASSETS),
  `PORT1TO1_terrain_gap_packet.md` (TERRAIN-GAPPACKET),
  `PORT1TO1_asset_gap_a.md` (TERRAIN-GAPA),
  `PORT1TO1_asset_gap_b.md` (TERRAIN-GAPB),
  `PORT1TO1_claim_recheck13.md` (CLAIM-RECHECK13),
  `DEC_U_b10_resid.md`, `DEC_U_b11_ai.md`, `DEC_U_b12_peace.md`,
  `DEC_U_d4_floats.md`, `DEC_U_b6_g0_density.md`,
  `DEC_U_speed_consumers.md`, `DEC_U_cam_derive.md`
- former pending workers — [CORRECTED by COORD 2026-11-27: all three artifacts have since landed; plan rows 305–307 DONE; no claim or value changed]:
  TERRAIN-STATVERIFY — LANDED (`PORT1TO1_terrain_statverify.md`; 22 static items checked, AN-1/AN-5 misclassified, NG-4 resolved),
  GRASS-BASENAME — LANDED (`DEC_U_grass_basename.md`; donor props exist, port skip is a real [U] gap with P0-2/P0-8 manifest work open),
  DEATH-OBJ-BYTES — LANDED (`PORT1TO1_death_obj_bytes.md`; 48/48 OBJ+MTL present, 4/4 stubs verified, donor bytes [U]-G2)
- parity: UNVERIFIED. No parity claim. No approximations.
- chain: 0/6 CLOSED. Nine P0 OPEN. `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.
- files written: exactly one — this report. No other edits.

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.
> No donor GPU A/B frame exists; this synthesis certifies neither donor fidelity nor a gate pass.

## 1. What the completeness audits actually verified on disk vs reported-only vs absent

### 1.1 Verified on disk [V] — existence only, never correctness/parity/gate-PASS

Live-tree file-existence + content reads (exact paths; sizes point-in-time):

- Runtime modules (IMPLEMENTED files, runtime UNVERIFIED):
  `variant3d/scripts/terrain_donor_data.gd` (25,545 B),
  `variant3d/scripts/terrain_donor_gen.gd` (194,275 B),
  `variant3d/scripts/terrain_donor_mesh.gd` (117,535 B),
  `variant3d/scripts/terrain_donor_props.gd` (78,742 B),
  `variant3d/scripts/terrain_donor_inputs.gd` (67,498 B),
  `variant3d/scripts/terrain_donor_world.gd` (22,919 B),
  `variant3d/scripts/water3d.gd` (66,088 B),
  `variant3d/scripts/world3d_entities.gd` (233,211 B),
  `variant3d/scripts/world3d_fx.gd` (135,482 B),
  `variant3d/scripts/world3d_terrain.gd` (83,687 B),
  `variant3d/scripts/world3d_relief.gd` (14,056 B),
  `variant3d/scripts/anim3d.gd` (T1–T26 state table).
- Shaders (IMPLEMENTED files, visual UNVERIFIED):
  `variant3d/shaders/water3d.gdshader` (36,383 B),
  `variant3d/shaders/water_overlay.gdshader` (15,779 B),
  `variant3d/shaders/terrain_donor_shader.gdshader` (19,805 B, V37 canonical).
- Tools (IMPLEMENTED files, behaviour/contract verdicts not made here):
  `variant3d/tools/decode_donor_cfg.py`, `decode_donor_pattern.py`,
  `decode_pattern_lib.py`, `decode_donor_masks.py`, `build_terrain_new_atlas.py`
  (DRY-RUN by default, `--write` unconfirmed),
  `variant3d/tools/terrain_qa_harness.py` (61,675 B, 52 rows, `--policy advisory`, not run),
  `import_donor_masks.py`, `import_donor_map.py`, `export_donor_patterns.py`,
  `copy_assets.py`, `convert_models.py`, `convert_skins.py`,
  `terrain_blend_test.py`, `terrain_compare.py`, `terrain_geometry_verify.py`,
  `terrain_ab_metric.py` (SMOKE-only, no ARI), `compare_shots.py`
  (candidate-vs-candidate determinism only).
- Derived asset tiers (IMPLEMENTED files, byte-validation/gate UNVERIFIED):
  `variant3d/assets/terrain_new/` — 5339 files / 383,192,189 B (dual-listed this wave);
  `patterns/*.json` ~713 + `pattern_decode_manifest.json` (287,042 B);
  `lib/pattern_lib_index.json` (55,784,815 B class);
  `cfg/constants.json` (1,276,466 B) + `cfg/config_strings.json` (2,285,595 B) + `cfg/manifest.json` (13,341 B);
  `masks/mask_index.json` (11,680,098 B) + `masks/height/` tier (4466 `.height.png`);
  `atlas/tile_index_atlas.png` (4,211,707 B) + `atlas/tile_index_atlas.manifest.json` (149,449 B)
  + `atlas/alpha.png` (55,242 B) + `atlas/alphavert.png` (167,954 B) + `atlas/seasons/`;
  `schemas/v1.schema.json` (2,438 B); root `manifest.json` (6,450,422 B);
  `props/props_index.json` (record_count 39783, distinct_basenames 235, section_count 668,
  family_count 77) + `props/families/*.json` 77;
  `skin/index.json` (count 66, skipped 7 naval, 40 action names) + `skin/attach/*.json` 63
  (= 9 peasant sids × 7 tools; 57/66 `attach: None`);
  `assets/terrain/blocks/` 224 entries (112 PNG + 112 `.import`);
  `assets/terrain/deco_png/` 14 entries; tile grass/ground/rock PNGs
  (`grass1..10`, `grasssand1-2`, `ground1-3`, `rock1-3`, `rockgrass1`, `dirt1`, each + `.import`);
  `assets/models/obj/shared/terrain/` 353 entries (bush/fern/flower/plantain/reed triples PRESENT);
  `assets/models/tex/shared/terrain/` 216 entries;
  `assets/models/buildings/models/*death*.obj` 48/48 PRESENT (12 stems × 4) + `.mtl` sidecars;
  `BLD_DEATH_STEMS` 12/12 in `world3d_entities.gd:375`;
  `assets/terrain/mountain_props.json` (66,519 B, relief-only census);
  `assets/terrain/prop_winter_materials.json` (36,024 B, data-only);
  `assets/fx/` tier (`models/`, `tex/`, `manifest.json`); `world3d_fx.gd` spatial FX layer;
  `inbox/qa/captures/**` populated (PNG/MP4 + `*_20261113`/`*_20261127` run dirs)
  alongside still-present `terrain_qa_report.json.PENDING`, `PENDING_N19_captures.md`,
  `PENDING_N7_validate_terrain_new.md`;
  `spec/terrain_qa_spec.json` (5,913 B, SCHEMA-ONLY, all bands `value:null`, `signed:false`).
- Static literals verified as text (shape only, live behaviour UNVERIFIED):
  four water literals (−1.1/−0.5/−0.25/−0.1), shore ids 93/97/98 + 8×45° table,
  relief dual-read `terrain_donor_gen.gd:3001-3005` + `terrain_donor_inputs.gd:1113-1114`,
  collision write path `terrain_donor_gen.gd:2082-2147` via I06 `set_collision`,
  fail-closed water gates (`water3d.gd:679-682/:746-747/:721-723/:785`),
  G-enum/colour constants `generatemap.inc:13-17,28-31`,
  22× `.speed :=` / 11× `rotatespeed :=` / 5× `speedperc` census,
  camera wrapper `control.script:619-664` + 9 call sites,
  12 `SetObjBuildingBaseSettings` rows, 9 startid 5–13 sextuples.

### 1.2 Reported-only / stub [C/U] — carried citations, not re-proven live

- Smoothing kernel: `terrain_donor_gen.gd:573-577` `[U]` native kernel not recovered,
  `bsmooth_kernel` NULL, `:581-590` SKIPPED + telemetry (V20/D03/X08 rule REPORTED-ONLY).
- Mask contract defect: X19 two-decoder no-shared-contract, `B > 58` vs `B >= 58`,
  white-start water counting (REPORTED-ONLY; tier now present, mapping still unproven).
- Water scalars: FILE (water.lib :21-40) vs ENGINE (ctor §2.4) both enumerated,
  `_water_scalar_source = UNSET`, `build()` refuses until FILE/ENGINE selected (U4*).
  Reflection FBO provenance [U12], height-object identity [U3], waveMap
  `diffusewaves0.png` missing ⇒ hard fail. No neutral/grey fallback (intentional).
- Vegetation/props activation: dense authored clumps, `Freq` roulette ×0.2 damping,
  `foreststype:=0` override, stone `stn1=0.00016/stn2=0.00012` scale 0.329 ±15%,
  mine scale 0.3152 + 5×5 dirt plate, ring→ore→256 tries, `m_swamp_small_1` 16×13 rule,
  mill `_unit_DoSeedWheat` 49-node translation, `[*] = ;` commented callers —
  all REPORTED-ONLY; no QA atom result; `matched_stamps=0/props_total=0` predicted.
- AAF/FX/tool/death: 194+52 AAF census, 56 attach `.oss`, per-sid row sets,
  orphan `attack2before/after`, `death0/1/2`, `trans*/prepare*/unprepare*`,
  blend 6/8 vs `0,0`, T6/T7/T23-T25 `partial`, T18-T20/T22/T26 `no` — carried.
- Economy/peace/AI/speed/camera laws: DLT/`floor`/rational-push operator order [D],
  `Float` width/rounding/N1 engine semantics [U]; peace enum/60×/lobby/init/expiry [O-text];
  upgrade setter/frames/pack-500/overwrites/charge/cancel/gate/preempt/dispatch [O-text];
  resbalance/mine bands/think 2.4 s/stagger/anti-collision [O-text];
  speed divisor chain/turn table [O-text]; camera target/height/smoothing text chain [O-text] —
  every live behaviour stays [U].

### 1.3 Absent / missing (re-confirmed, do not claim)

- `variant3d/scripts/terrain_donor_tiles.gd` — no file found (I12 optional; V16-27 governs).
- `variant3d/tools/validate_terrain_new.py` — no file found.
- `variant3d/tools/terrain_qa_spec.json` — no file found (spec copy only).
- Retired alias `variant3d/shaders/terrain_donor.gdshader` — no file found (intentionally retired).
- Grass-dedicated donor generator/mesh/shader tier — no file found; tile grass ≠ prop grass.
- Fresh runner result JSONs / determinism dumps / frozen 240²+320² baselines labelled by
  actual size — no file found.
- Donor GPU A/B frame (matched seed/camera/map-size) — no file found anywhere in this wave.
- Matched camera derivation — none (CAM-derive/CAM-0 stay [U]).
- COORD ruling (ownership/acks/tickets/scope) — none on file in this wave.

## 2. Gaps RESOLVED vs OPEN this wave (report ids; static narrowing ≠ parity closure)

### 2.1 RESOLVED in the static-narrowing sense only (existence/definition corrected; [U] tails remain)

- AN-1/G1 — 668-vs-680 sections: RESOLVED as count-definition difference
  (`PORT1TO1_asset_gap_a.md` §1: 680 `section.begin` pairs vs 668 with-`Objects` by index
  `record_rule`; 618+37+9+3+1=668, 12 object-less, 668+12=680 exact).
  OPEN tail: [U]-G1 per-name 12-section cross-check (0/12 in index, no duplicate-collapse).
- AN-2/G2 existence half — death-OBJ listing: SUPERSEDED on existence
  (`PORT1TO1_asset_gap_a.md` §2: 48/48 death OBJs on disk, 12/12 stems in script).
  OPEN tail: [U]-G2 byte/vert/bbox verification + manifest rows
  (DEATH-OBJ-BYTES worker PENDING).
- AN-4/G3 label — `desert_frt_un` mislabel: CORRECTED
  (`PORT1TO1_asset_gap_a.md` §3: `desert_frt_un` resolved under its own name, 12/12 patterns;
  genuinely deferred item is sibling `desert_forests_big` naming).
  OPEN tail: [U]-G3 engine-normalisation-vs-quarantine ruling.
- Gap-B grass split + action-set difference: CLARIFIED, stays OPEN
  (`PORT1TO1_asset_gap_b.md`: tile-block grass IMPLEMENTED vs 21 prop-grass BaseNames ABSENT
  with explicit skip; 40-minus-T = empty, T-minus-40 = non-AAF names only).
  OPEN tails: [U]-GRASS (GRASS-BASENAME worker PENDING), [U]-ACT-COVERAGE.
- B10 static tables: NARROWED (`DEC_U_b10_resid.md` §§1-3: protection 32+1 and weapon 78
  re-counts with explicitly no residual; 12 building-score rows + 9 startid 5–13 sextuples
  transcribed [O]); T1-tail (~120 `SetObjBaseWeapon` calls), price rows, Q1, R1, S-tail stay [U].
- B11/B12/D4/B6-G0/speed/camera: NARROWED to exact text shape, all live halves stay [U]
  (`DEC_U_b11_ai.md`, `DEC_U_b12_peace.md`, `DEC_U_d4_floats.md`,
  `DEC_U_b6_g0_density.md`, `DEC_U_speed_consumers.md`, `DEC_U_cam_derive.md`).
- Stale-snapshot corrections: V62/HANDOFF/REPORT_INDEX atlas/masks/lib/schema/manifest
  "absent" and "no captures" lines are stale as presence findings
  (tiers + `captures/**` now present); V87 file-count shape matches better.
  Correction is presence-only — validation/gate/verdict still absent.
- CLAIM-RECHECK13: C1–C6 unguarded-parity sweep NONE found; C7 29 footnotes intact;
  C8 no new false verbatim; no static-[D]-to-behavioural promotion found
  (`PORT1TO1_claim_recheck13.md` §§3-7). Label-only G-1/G-2/G-3 stale-status items carried.

### 2.2 OPEN (blocking; nothing below is closed by static work)

- MW-1/AP-9 donor frame; MW-2/MW-11 gates + signed verdicts; MW-3 N7/spec-copy/atlas `--write`;
  MW-4 grid-size seam; MW-5 relief feed + float windows; MW-6 native kernels/blend-alpha;
  MW-7 water U12/U3/U4*; MW-8 props feed (`matched_stamps>0`); MW-9 swamp/lake/mine/field
  bindings + quarantines (`m_swamp_12_old`, `lake_big`); MW-10 contradictions/ownership/tickets
  (V16 O1–O14 / V47 O-A…O-S 19 OPEN, I03 F-01, I14/I15 absent, spool 575/582/585 unacked);
  NG-1…NG-6 readiness/absence rows
  (`PORT1TO1_terrain_gap_packet.md` §§1-2; `PORT1TO1_terrain_completeness.md` §§6-7).
- Asset P0-1…P0-9: I09 feed path/shape, 235-row mesh+material manifest, death-OBJ glob rows,
  66×40 action matrix + orphan captures, T-A/T-B + G/R captures, N7 validator + `pack_id`,
  season/desert reconciliation, grass/winter/desert swaps, donor frame decision
  (`PORT1TO1_terrain_assets.md` §4; `PORT1TO1_terrain_gap_packet.md` §4).
- Domain tails: B10 T1-tail/Q1/G1-tail/A1-tail/R1/S-tail/V1/V2/F1/E1/O1-tail;
  B11 U-B11-1…U-B11-5; B12 TIME/COST/GATE/PREEMPT/DISP/LOSS/PEACE + D4 U6-T/DLT/O1;
  G0 C-G0a/b/c; speed T-SPEED/T-BASE/T-TURN/T-ACCEL/T-TERRAIN/T-FORM/T-CARRY/T-UPG/T-WALK;
  CAM-derive/CAM-0; [U]-G1/G2/G3, [U]-GRASS, [U]-ACT-COVERAGE, [U]-T-A/T-B, [U]-G/R.

## 3. Governing counts (wave-invariant)

- Open unknowns: **71 open [U]** (A42/B14/C5/D10) — carried from CLAIM-RECHECK13 §7/§10.
- P0 rows: **9 P0 OPEN** (asset/terrain P0-1…P0-9; packet MW/AP rows feed them).
- Six-condition chain: **0/6 CLOSED** (conditions 2 and 6 PARTIAL port-internal only;
  1/3/4/5 BLOCKED per recheck13 §10 and cam-derive §6).
- Donor GPU A/B frame: **none** (no file found; HANDOFF GR-C08/V15 §2/V57/X39).
- Matched camera: **none** (CAM-derive/CAM-0 [U]; port `0.75` is PORT CHOICE, screenshot
  `0.75` is a min-height, `SetGUIMinimapZoom(1)` is unrelated).
- COORD ruling: **none** in this wave (ownership V16-27/V16-26, I03 F-01, V47 19 OPEN,
  spool acks, I14/I15 tickets, scope/frame rule-out all unrruled).
- Register total: **71 rows** (U-base-speed is a split of counted T-SPEED, not a 72nd row).

## 4. Owner-correctness statement (binding)

- The owner is correct: **the port is not full.** Presence of 5339 derived files,
  39783 records / 235 basenames / 668 sections / 77 families, 66+7 skin sids, 63 tool skins,
  48 death OBJs, 40 action names, atlas/mask/lib/schema/manifest tiers, and populated
  `captures/**` is **existence evidence only** — never correctness, never a gate PASS,
  never donor fidelity, never donor parity.
- **No audit or report in this wave declares completeness or parity.**
  Completeness `:13` ("Nothing below is a completeness or parity declaration"),
  assets `:167` ("No completeness declared"), gap_a `:97`, gap packet `:12`
  ("No item in this packet is a parity closure"), recheck13 §§2-4/10, and every
  DEC_U verdict (`UNVERIFIED`, `RESULT IS NOT GOOD`) refuse completeness/parity explicitly.
- Static `[D]` facts, deterministic repeats, ROI metrics, SMOKE metrics, hashes, and
  file counts **never promote to parity** and never close a class-A value/behaviour item.

## 5. Prioritized next actions (split by who can execute)

### A. WORKER-EXECUTABLE-STATIC (no GPU/runtime, no donor execution)

1. Per-name [U]-G1 cross-check: name the 12 object-less sections from
   `lib/pattern_lib_index.json`; confirm 0/12 keys in `props_index.json`.
2. Death-OBJ existence matrix (supports PENDING DEATH-OBJ-BYTES): 12×4 PRESENT/ABSENT +
   `.mtl` + lengths; do not hash-compare to donor binaries.
3. Per-BaseName mesh+material manifest skeleton (235 rows: OBJ PRESENT/ABSENT + bytes,
   PNG PRESENT/ABSENT + W×H, winter PRESENT/ABSENT); grass 21-row proof bundle
   (grass-OBJ-zero glob + `map_Kd.*grass` zero grep) — supports PENDING GRASS-BASENAME.
4. Per-sid 40-action gap matrix skeleton (66×40 PRESENT/ABSENT from `skin/index.json`
   frame lists joined to T-table emitter list); no coverage closure.
5. Static re-verification of `:3001-3005` + `:1113-1114` against the exact captured build;
   byte-verify atlas/masks/lib/schemas/root-manifest tiers + record hashes
   (no DRY-RUN claimed as output); index `captures/**` (admissibility review itself is owner).
6. Write N7 `validate_terrain_new.py` + populate every `terrain_qa_spec.json` band +
   land the `variant3d/tools/` copy; reconcile season/desert path shape (ruling itself is owner).
7. Fold landed-but-unfolded reports into spec §§01–14 with READY marks; keep V16/V47
   register current; never invent I14/I15, donor bytes, densities, heights, or prices.

### B. OWNER-GPU-RUNTIME (workers submit no Godot jobs; donor/GPU runs here only)

1. Produce or formally rule out the genuine matched-seed donor GPU A/B frame (GR-C08).
2. Run fresh gate sequence A′-0…A′-3 then D-0…D-6 with unique job ids; fill every TODO(COORD).
3. Terminating byte probes: grid-size seam (64²/240²/320² exact end-to-end + frozen baselines);
   relief feed (`relief_float_grid` → `_stamp_pattern` on all fixed seeds + float windows);
   collision cliff TAG + 2x-view engine consumption; water U12/U3/U4* bindings;
   props `matched_stamps>0` with carried transforms and no double-instancing;
   G0 C-G0a/b/c; D4 U6-T 36-float + DLT 600-tick; B12 TIME/COST/GATE/PREEMPT/DISP/LOSS/PEACE;
   speed T-SPEED/T-BASE/T-TURN/…; CAM-derive/CAM-0 matched-camera captures;
   T-A/T-B/G/R and orphan R-captures (fixed-camera, zero-mismatch).
4. Reviewer verdict per capture in `inbox/qa/captures/**` (admissible/stale/excluded);
   W06 perf adjudication; no metric overrides the visual read.

### C. OWNER-DECISION (work stops until ruled)

1. I03 F-01 ownership breach; V16-26/V16-27 feed ownership; GR-A24 atom repoint;
   `terrain_donor_tiles.gd` ownership (I12 optional).
2. FILE-vs-ENGINE water scalar winner (U4*) + fail-closed scope memo if water stays undrawable;
   native-kernel accept-open ruling if SmoothTerrain/blend unknowns are parked.
3. Engine-normalisation-vs-quarantine ruling for `desert_forests_big` ([U]-G3);
   per-section rulings for any of the 12 object-less sections that cannot be named;
   `set_season()` canonical-shape ruling; `m_swamp_12_old`/`lake_big` quarantine re-affirmation.
4. Spool 575/582/585 evidence-backed acks (never `--ignore-history`); I14/I15 ticket
   definitions or recorded absence; market/AI/score/peace scope exclusions if any value
   is declared out of scope (until ruled, D4/B11/B12 stay blocking).
5. Owner-signed capture/criteria verdicts per class (MW-11) — the only verdict step that,
   combined with MW-2 gates, can move a P0 row to closed.

## 6. Canonical verdict

- Parity UNVERIFIED. Chain 0/6. Nine P0 OPEN. 71 open [U] (A42/B14/C5/D10).
  No donor GPU A/B frame. No matched camera. No COORD ruling.
- No audit/report here declares completeness or parity; the owner is correct the port is not full.
- RESULT IS NOT GOOD while `blocking_unverified` is non-empty.

*End of PORT1TO1_wave_synth2. Read-only; exactly one file written; parity UNVERIFIED;
no approximations, no parity claim.*
