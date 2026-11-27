# PORT1TO1 — Terrain brief check (read-only verification)

- id: PORT1TO1-BRIEF-CHECK-2026-11-27
- worker: BRIEF-CHECK (read-only verification)
- date: 2026-11-27
- target: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_brief.md` (id `PORT1TO1-terrain-brief-2026-11-27`, 45 lines)
- sources: `PORT1TO1_terrain_gap_packet.md` (257 lines, `PORT1TO1-terrain-gap-packet-2026-11-27`) as corrected by GAP-CORRECT and verified by `PORT1TO1_packet_reread.md` (31/31 PASS, `PORT1TO1-packet-reread-2026-11-27`); `PORT1TO1_terrain_completeness.md` (`PORT1TO1-terrain-completeness-2026-11-27`); `PORT1TO1_terrain_assets.md` (`PORT1TO1-TERRAIN-ASSETS`); `DEC_U_grass_basename.md` (`DEC_U_GRASS_BASENAME`); `PORT1TO1_death_obj_bytes.md` (`PORT1TO1-DEATH-OBJ-BYTES`); `PORT1TO1_asset_gap_a.md` (`PORT1TO1-ASSET-GAP-A`); `PORT1TO1_asset_gap_b.md` (`PORT1TO1-ASSET-GAP-B`); `PORT1TO1_wave_synth2.md` (`PORT1TO1-WAVE-SYNTH2-2026-11-27`)
- parity: UNVERIFIED. No parity claim. No approximations.
- chain: 0/6. Nine P0 OPEN. `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.
- method: read-only end-to-end read. No code/Godot/git/donor execution. Exactly one file written (this report); no other edits.

## 1. Subdomain rows — brief §2 (lines 14-21)

Verdict: PASS (all six rows).

- Generation (brief `:16`): IMPLEMENTED files/sizes (`terrain_donor_data.gd` 25,545 B; `terrain_donor_gen.gd` 194,275 B; `terrain_donor_inputs.gd` 67,498 B; decoders; `patterns/*.json` ~713 + `pattern_decode_manifest.json` 287,042 B; `lib/pattern_lib_index.json` 55,784,815 B class; `cfg/constants.json` 1,276,466 B + `config_strings.json` 2,285,595 B; dual-read `:3001-3005`/`:1113-1114`; collision `:2082-2147`) match completeness §1 (`:22-32`) and synth2 §1.1 (`:34-46,61-66,88-96`). REPORTED-ONLY column (stage pipeline, stamp blends, `:843-844`, B-channel law, RNG LCG + `randkey1`, `Freq` x0.2, stone/mine scales; runtime UNVERIFIED) matches completeness §§1-4 and packet MW-3..MW-6/MW-8/MW-9. ABSENT column (`terrain_donor_tiles.gd` no file; smoothing NULL/SKIP `:573-577`; 64→256 seam; RNG [U]; 240²+320² baselines no file) matches completeness §1 (`:28-32`) + §6.6 and packet NG-6. Classification exact. PASS.
- Water (brief `:17`): IMPLEMENTED (`water3d.gd` 66,088 B; `terrain_donor_mesh.gd` 117,535 B + `WATER_SURFACE_Y=-0.25` PORT APPROX `:92`; shaders 36,383/15,779 B; literals -1.1/-0.5/-0.25/-0.1 + shore 93/97/98) matches completeness §2 (`:38-47`) and synth2 §1.1. REPORTED-ONLY (smoother 3x/0.35, foam 0.535, `bmTransparency` SRC_ALPHA/ONE_MINUS_SRC_ALPHA) matches completeness §2 (`:45`) / D06/X11. ABSENT (donor GPU A/B frame no file; U12 hard-fail `:679-682`; U3 substitute; U4* UNSET `:746-747`; `diffusewaves0.png` missing) matches completeness §2 (`:42-47`) and packet MW-7 (`:64-69`) / NG-5. Classification exact. PASS.
- Vegetation/forests (brief `:18`): IMPLEMENTED (`terrain_donor_props.gd` 78,742 B; `props_index.json` 39783/235/668/77 [V]; 77 families; tile grass `grass1..10`, `grasssand1-2`, `ground1-3`, `rock1-3`, `rockgrass1`, `dirt1` PRESENT) matches assets §0 (`:27-41`) + §1.2 (`:51-55`) and gap_b §1.2 E4a (`:35`). REPORTED-ONLY (forest footprints to 86x92, `foreststype:=0`, mill 49-node X22, `[*] = ;` commented callers) matches completeness §3 (`:55-57`) and synth2 §1.2 (`:108-112`). ABSENT (grass-dedicated tier no file; forest OBJ transform 0 hits in `mountain_props.json`; winter unconverted X16 A5) matches completeness §3 (`:58`), assets §1.2c, gap_b §1.4. Classification exact. PASS.
- Stones/props (brief `:19`): IMPLEMENTED (same props module; `k_rock*`/`k_ravine*`/`str_*`/`m_swamp*`/`l_lake_*`/`mng/mni/mnc*` PRESENT; `assets/terrain/blocks/` 224 = 112 PNG; `models/obj/shared/terrain/` 353 entries) matches assets §§1.4-1.5/1.7-1.8 + §2 rows 8-9 and gap_b E4a (`:35`). REPORTED-ONLY (stone scales, mine 0.3152 + 5x5 plate, ring→ore→256, `m_swamp_small_1` 16x13) matches completeness §4 (`:67-70`) and synth2 §1.2. ABSENT (river/ford out of scope; 63/141 no converted OBJ X16; `matched_stamps=0/props_total=0`; `family_index.json` unusable V66-F1) matches completeness §4 (`:71-73`) and packet MW-8. Classification exact. PASS.
- Death art/AAF (brief `:20`): IMPLEMENTED (`*death*.obj` 48/48 + 48 MTL; `BLD_DEATH_STEMS` 12/12 `world3d_entities.gd:375`; `skin/index.json` 66 + 7 naval + 40 names; `skin/attach/` 63 = 9x7; `anim3d.gd` T1-T26; `world3d_fx.gd` + `assets/fx/` tier) matches assets §§1.9-1.12 + §2 rows 4-7 and death_obj_bytes §1 (`:29-32`). REPORTED-ONLY (194+52 AAF census; 56 `.oss`; per-sid rows; orphans; blend 6/8 vs `0,0`) matches assets §1.9b/1.10b and gap_b §2. ABSENT (11-family byte/vert/bbox rows [U]-G2; 66x40 matrix [U]-ACT-COVERAGE; T-A/T-B/G/R captures) matches death_obj_bytes §4 (`:101-103`), gap_b §§2.5/3. Classification exact. PASS.
- Assets/tools (brief `:21`): IMPLEMENTED (`terrain_new/` 5339 / 383,192,189 B [V]; atlas 4,211,707 B + manifest + alpha/alphavert + seasons; masks 11,680,098 B + 4466 height PNG; `schemas/v1.schema.json` 2,438 B; root `manifest.json` 6,450,422 B; `terrain_qa_harness.py` 61,675 B / 52 rows advisory PRESENT-not-run; `terrain_donor_world.gd` 22,919 B; `terrain_donor_shader.gdshader` 19,805 B) matches assets §1.13 + §2 row 1 and synth2 §1.1 (`:61-87`). REPORTED-ONLY (I01-I05 self-checks; atlas `--write`; X15 A2.4 keys; E08 census) matches completeness §5. ABSENT (`validate_terrain_new.py` no file; `tools/terrain_qa_spec.json` no file SCHEMA-ONLY copy; retired alias no file intentional; runner JSONs/dumps no file) matches completeness §6.6 and packet NG-6. Classification exact. PASS.

## 2. Resolved-vs-open — brief §3 (lines 25-31)

Verdict: PASS (all four resolved + all open tails).

- RESOLVED 668+12=680 (brief `:27`): arithmetic 618+37+9+3+1=668, 12 object-less, 668+12=680 exact — matches gap_a §1.3 (`:51-52`) and packet AN-1 (`:152-157`); reread AN-1 PASS (`:46`). [U]-G1 per-name tail kept open. PASS.
- RESOLVED death existence 48/48 (brief `:28`): 12 stems x `_death1/_death2/_death1a/_death2a` + MTL sidecars, 12/12 stems — matches gap_a §2 (`:61-64`) and death_obj_bytes §1-§2 (`:29-38`, 48 rows, 4/4 stubs VERIFIED honest near-empty, 0 MISMATCH on checkable half `:89`); packet AN-2/AP-3 (`:159-164,:201-206`); reread PASS (`:47,:58`). [U]-G2-BYTE/-STUB/-HOU-BLA tails kept open. PASS.
- RESOLVED `desert_frt_un` mislabel (brief `:29`): resolved under own name (12/12 patterns, family bundle with records); genuinely deferred sibling is `desert_forests_big` — matches gap_a §3 (`:74-85`); packet AN-5 (`:180-185`); reread PASS (`:50`). [U]-G3 tail kept open. PASS.
- RESOLVED 40-action wiring (brief `:30`): 40-minus-T = EMPTY (every action has a T row); T-minus-40 = non-AAF names only (`walk1` donor-dead, `walk2`/`turn`/`collide` vocabulary-only, 8 tool child-swap names, alias `attack`) — matches gap_b §2.3 (`:77-79`); packet AN-4/AP-4 (`:173-178,:208-213`); reread PASS (`:49,:59`). [U]-ACT-COVERAGE tail kept open. PASS.
- OPEN (brief `:31`): grass prop BaseNames ([U]-GRASS-MESH/MANIFEST/WINTER — gap_b §1, grass_basename §4); byte fidelity [U]-G2 ([U]-G2-BYTE/-STUB/-HOU-BLA — death_obj_bytes §4); CAM-derive/CAM-0 matched camera none (synth2 §§1.3/3); water U12/U4*/U3 (packet MW-7); smoothing native kernel NULL/SKIP (MW-6); RNG live state/key→state internals; deferred sibling aliases `desert_forests_big`/`n_desert_frt_big_1..17`, `k_pump_`, `plant*` bodies uncited ([U]-G3, per-name [U]-G1, grass_basename §3); MW-1..MW-11, NG-1..NG-6, AP-1..AP-9 tails per gap packet §§1-2 — all present with no dropped [U] vs reread §2 (`:75`, all tails live). Nothing closed by static work. PASS.

## 3. Next actions — brief §4 (lines 35-37)

Verdict: PASS (split exact, report ids correct).

- WORKER-STATIC (brief `:35`): [U]-G1 per-name 12-section check (0/12 keys, 668+12=680); [U]-G2 manifest rows + port-side byte/vert/bbox ledger (donor decode owner-side); [U]-GRASS 21-row manifest + grass-OBJ-zero glob + `map_Kd.*grass` zero grep; 66x40 matrix skeleton; N7 `validate_terrain_new.py` write + every `terrain_qa_spec.json` band + `tools/` copy; atlas/masks/lib/schemas byte-verify + hash list; re-verify `:3001-3005`/`:1113-1114`; season/desert path-shape draft; fold landed reports into spec §§01-14 (packet MW-3/5/6/8/9/10 worker halves; synth2 §5A = §5.A static list; statverify §1) — matches packet (c) WORKER-EXECUTABLE-STATIC rows (MW-3/MW-5/MW-6/MW-8/MW-9/MW-10, NG-1/NG-3/NG-4-static, AN-1/AN-2/AP-3/AP-2/AP-4/AP-6/AP-7/AP-8) and synth2 §5.A (`:220-236`). No GPU/donor run assigned to workers. PASS.
- OWNER-GPU-RUNTIME (brief `:36`): matched-seed donor GPU A/B frame or signed rule-out (MW-1/AP-9, GR-C08); fresh gates A'-0..A'-3 then D-0..D-6 with unique job ids + TODO(COORD) (MW-2); grid-size terminating probe + frozen 240²+320² baselines (MW-4); relief feed proof + float windows (MW-5); kernel trace/GL capture (MW-6); water U12/U3/U4* bindings (MW-7); `matched_stamps>0` live proof (MW-8); swamp/lake/mine/field activation (MW-9); per-capture verdicts + W06 perf (MW-11/NG-2) — matches packet (c) OWNER-GPU-RUNTIME rows and synth2 §5.B (`:239-249`). PASS.
- OWNER-DECISION (brief `:37`): I03 F-01 ownership; V16-26/V16-27 feed ownership; GR-A24 repoint; `terrain_donor_tiles.gd` ownership; FILE-vs-ENGINE scalar winner (U4*) + fail-closed scope memo; kernel accept-open ruling; `desert_forests_big` normalisation-vs-quarantine + `set_season()` canonical shape + `m_swamp_12_old`/`lake_big` quarantine re-affirmation; spool 575/582/585 acks never `--ignore-history`; I14/I15 tickets or recorded absence; signed capture/criteria verdicts per class (MW-10/MW-11; synth2 §5C = §5.C decision list) — matches packet (c) OWNER-DECISION rows (MW-6/MW-7/MW-8/MW-10/MW-11, NG-5/NG-6, AP-7/AP-9) and synth2 §5.C (`:252-264`). PASS.

## 4. Canonical verdict — brief §6 (line 45)

Verdict: PASS (verbatim).

- Brief `:45` reads: `Parity UNVERIFIED. Chain 0/6. Nine P0 OPEN. RESULT IS NOT GOOD while blocking_unverified is non-empty.` — exact canonical wording as tasked, consistent in substance with packet §5 (`:250-255`: parity UNVERIFIED every subdomain / chain 0/6 / nine P0 OPEN / blocking_unverified non-empty ⇒ RESULT IS NOT GOOD), reread §4 (`:83-89`), synth2 §6 (`:268-271`), completeness §0 (`:13-16`). Chain 0/6 stated; nine P0 OPEN stated (asset P0-1..P0-9 feed MW/AP rows). PASS.

## 5. No completeness or parity claim anywhere in the brief

Verdict: PASS.

- Brief `:6` (`parity: UNVERIFIED. No parity claim. No approximations.`), `:10` (port NOT full, parity UNVERIFIED every subdomain), §2 header (`existence only, never correctness/parity/gate-PASS`), §3 (`none closes P0/parity`), §5 (`candidate-vs-candidate only`, `SMOKE-only`, `never promote parity`, `no metric overrides the visual read`, `existence evidence, never donor fidelity`). Full §1-§6 re-read: no `COMPLETE`, no gate PASS, no donor-fidelity/parity promotion, no approximation endorsed. `RESOLVED` is used only in the packet's static-narrowing sense (existence/definition corrected, [U] tails kept open). `NOT full` is a negation, not a completeness claim. PASS.

## 6. Defects

None. No file:line defect found in the brief against the nine sources. No label-only remediation required.

## 7. Verdict (binding wording)

- Parity UNVERIFIED. No parity claim. No approximations.
- Chain 0/6. Nine P0 OPEN. `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.
- Static file presence, byte sizes, greps, and labels are existence only — never correctness, never a gate PASS, never donor fidelity. No static fact above promotes any class-A value/behaviour item.
- No completeness is declared; no parity is claimed; no approximation is made or endorsed in this report.
- Read-only; exactly one file written (this report).

*End of brief check.*
