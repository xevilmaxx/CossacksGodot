# PORT1TO1 — Terrain Final Owner Brief (read-only, <=2 pages)

- id: PORT1TO1-terrain-brief-2026-11-27
- worker: FINAL-TERRAIN-BRIEF (read-only)
- date: 2026-11-27
- parity: UNVERIFIED. No parity claim. No approximations.

## 1. Honest one-line header

The terrain port (entire landscape stack) is NOT full and parity is UNVERIFIED for every subdomain — RESULT IS NOT GOOD.

## 2. Landscape subdomain table (existence only, never correctness/parity/gate-PASS)

| Subdomain | IMPLEMENTED (files on disk [V]) | REPORTED-ONLY / STUB | ABSENT / MISSING |
|---|---|---|---|
| Map generation | `variant3d/scripts/terrain_donor_data.gd` (25,545 B), `terrain_donor_gen.gd` (194,275 B), `terrain_donor_inputs.gd` (67,498 B), `decode_pattern_lib.py`, `decode_donor_pattern.py`, `decode_donor_cfg.py`, `decode_donor_masks.py`; `patterns/*.json` ~713 + `pattern_decode_manifest.json` (287,042 B); `lib/pattern_lib_index.json` (55,784,815 B class); `cfg/constants.json` (1,276,466 B) + `config_strings.json` (2,285,595 B); relief dual-read `terrain_donor_gen.gd:3001-3005` + `terrain_donor_inputs.gd:1113-1114`; collision write path `terrain_donor_gen.gd:2082-2147` | Stage pipeline, stamp blend Replace/ReplaceForWater/Smooth, row_sign/height_unit (`:843-844`), mask B-channel law `h=-1.1*B/255`, RNG LCG shape + `randkey1` single-draw, `Freq` roulette x0.2, stone/mine scales — all carried citations, runtime UNVERIFIED (completeness §1) | `terrain_donor_tiles.gd` no file found; smoothing kernel STUB (`:573-577` NULL/SKIP); grid-size seam open (64->256 observed); RNG live state [U]; frozen 240²+320² baselines no file found |
| Water | `variant3d/scripts/water3d.gd` (66,088 B); `terrain_donor_mesh.gd` (117,535 B; `WATER_SURFACE_Y=-0.25` PORT APPROX `:92`); `shaders/water3d.gdshader` (36,383 B) + `water_overlay.gdshader` (15,779 B); 4 literals -1.1/-0.5/-0.25/-0.1 + shore ids 93/97/98 | Shore smoother 3x power 0.35, foam 0.535, `bmTransparency` SRC_ALPHA/ONE_MINUS_SRC_ALPHA — REPORTED-ONLY (D06/X11) | Donor GPU A/B frame no file found; U12 reflection (hard-fail `:679-682`), U3 hmapTex substitute, U4* scalar UNSET (hard-fail `:746-747`), `diffusewaves0.png` missing hard-fail — water undrawable on those paths by design |
| Vegetation / forests | `terrain_donor_props.gd` (78,742 B); `props/props_index.json` (39783 records / 235 basenames / 668 sections / 77 families [V]); `props/families/*.json` 77; tile grass `grass1..10`, `grasssand1-2`, `ground1-3`, `rock1-3`, `rockgrass1`, `dirt1` PRESENT | Forest families/footprints to 86x92, `foreststype:=0` override — REPORTED-ONLY (F08); mill `_unit_DoSeedWheat` 49-node translation REPORTED-ONLY (X22); `[*] = ;` callers commented text | Grass-dedicated donor generator/mesh/shader tier no file found; forest OBJ transform export 0 hits in `mountain_props.json`; winter textures unconverted (X16 A5) |
| Stones / props | Same props module; `patterns/k_rock*.json`, `k_ravine*.json`, `str_*.json`, `m_swamp*.json`, `l_lake_*.json`, `mng/mni/mnc*.json` PRESENT; `assets/terrain/blocks/` 224 entries (112 PNG); `models/obj/shared/terrain/` 353 entries | Stone `stn1=0.00016/stn2=0.00012` scale 0.329 ±15%; mine 0.3152 + 5x5 plate; ring->ore->256 tries; `m_swamp_small_1` 16x13 — REPORTED-ONLY | No river/ford generator (out of scope); 63/141 BaseNames no converted OBJ (X16); `matched_stamps=0/props_total=0` predicted (W07); `family_index.json` unusable by `_try_feed` (V66-F1) |
| Death art / AAF | `models/buildings/models/*death*.obj` 48/48 PRESENT + 48 MTL; `BLD_DEATH_STEMS` 12/12 (`world3d_entities.gd:375`); `skin/index.json` count 66 + 7 naval skipped + 40 action names; `skin/attach/` 63 (=9x7); `anim3d.gd` T1-T26; `world3d_fx.gd` + `assets/fx/` tier PRESENT | 194+52 AAF census, 56 attach `.oss`, per-sid row sets, orphan `attack2before/after`, blend 6/8 vs `0,0` — carried, live proof [U] | 11-family death byte/vert/bbox manifest rows open ([U]-G2); 66x40 PRESENT/ABSENT matrix no file found ([U]-ACT-COVERAGE); T-A/T-B, G/R captures open |
| Assets / tools | `terrain_new/` 5339 files / 383,192,189 B [V]; `atlas/` (tile_index_atlas.png 4,211,707 B + manifest + alpha/alphavert + seasons), `masks/` (mask_index 11,680,098 B + 4466 height PNG), `schemas/v1.schema.json` (2,438 B), root `manifest.json` (6,450,422 B) PRESENT; `terrain_qa_harness.py` (61,675 B, 52 rows, advisory) PRESENT not run; `terrain_donor_world.gd` (22,919 B), `terrain_donor_shader.gdshader` (19,805 B) PRESENT | I01-I05 self-checks, atlas `--write` provenance, X15 A2.4 keys, E08 block census — REPORTED-ONLY | `validate_terrain_new.py` no file found; `tools/terrain_qa_spec.json` no file found (spec copy SCHEMA-ONLY, all `value:null`, `signed:false`); retired shader alias no file found (intentional); runner JSONs/dumps no file found |

## 3. This wave: RESOLVED (static-narrowing only) vs OPEN

RESOLVED (definition/existence corrected; [U] tails remain — none closes P0/parity):
- 668+12=680: count-definition difference, arithmetic closed (618+37+9+3+1=668, 12 object-less, 668+12=680 exact) — gap_a §1; statverify AN-1.
- Death OBJ existence 48/48: 12 stems x `_death1/_death2/_death1a/_death2a` + MTL sidecars on disk, 12/12 stems — gap_a §2; death_obj_bytes §§1-2 (4/4 stubs honest near-empty, 0 MISMATCH on checkable half).
- `desert_frt_un` wiring: mislabel corrected — resolved under its own name (12/12 patterns, family bundle with records); genuinely deferred item is sibling `desert_forests_big` — gap_a §3; statverify AN-5.
- 40-action wiring: 40-minus-T = EMPTY (every action has a T row); T-minus-40 = non-AAF names only (`walk1` donor-dead, `walk2`/`turn`/`collide` vocabulary-only, 8 tool child-swap names, alias `attack`) — gap_b §§2.2-2.5.

OPEN (blocking): grass prop BaseNames ([U]-GRASS-MESH/MANIFEST/WINTER — gap_b §1, grass_basename §4); byte-level fidelity [U]-G2 ([U]-G2-BYTE/-STUB/-HOU-BLA — death_obj_bytes §4); CAM-derive/CAM-0 matched camera none (cam_derive); water U12/U3/U4* (gap packet MW-7); smoothing native kernel NULL/SKIP (MW-6); RNG live state/key→state internals (HANDOFF §1); deferred sibling aliases `desert_forests_big`/`n_desert_frt_big_1..17`, `k_pump_`, `plant*` bodies uncited ([U]-G3, G1 per-name [U]-G1, grass_basename §3); MW-1..MW-11, NG-1..NG-6, AP-1..AP-9 tails per gap packet §§1-2 / statverify §§1-2.

## 4. Authoritative next actions (report ids)

WORKER-STATIC (no GPU/donor run): [U]-G1 per-name 12-section check (0/12 keys, 668+12=680); [U]-G2 manifest rows + port-side byte/vert/bbox ledger (donor decode itself is owner-side); [U]-GRASS 21-row manifest + grass-OBJ-zero glob + `map_Kd.*grass` zero grep; 66x40 matrix skeleton; N7 `validate_terrain_new.py` write + populate every `terrain_qa_spec.json` band + land `tools/` copy; atlas/masks/lib/schemas byte-verify + hash list; re-verify `:3001-3005`/`:1113-1114` against captured build; season/desert path-shape reconciliation draft; fold landed reports into spec §§01-14 (gap packet MW-3/5/6/8/9/10 worker halves; synth2 §5A; statverify §1).
OWNER-GPU-RUNTIME: matched-seed donor GPU A/B frame or signed rule-out (MW-1/AP-9, GR-C08); fresh gates A'-0..A'-3 then D-0..D-6 with unique job ids + TODO(COORD) (MW-2); grid-size terminating probe + frozen 240²+320² baselines (MW-4); relief feed proof + float windows (MW-5); kernel trace/GL capture (MW-6); water U12/U3/U4* bindings (MW-7); `matched_stamps>0` live proof (MW-8); swamp/lake/mine/field activation (MW-9); per-capture verdicts + W06 perf (MW-11/NG-2).
OWNER-DECISION: I03 F-01 ownership; V16-26/V16-27 feed ownership; GR-A24 repoint; `terrain_donor_tiles.gd` ownership; FILE-vs-ENGINE scalar winner (U4*) + fail-closed scope memo; kernel accept-open ruling; `desert_forests_big` normalisation-vs-quarantine + `set_season()` canonical shape + `m_swamp_12_old`/`lake_big` quarantine re-affirmation; spool 575/582/585 acks (never `--ignore-history`); I14/I15 tickets or recorded absence; signed capture/criteria verdicts per class (MW-10/MW-11; synth2 §5C).

## 5. Verification status

Deterministic repeats (`compare_shots.py`, `roi_metrics_*` run dirs) are port-internal candidate-vs-candidate only and never promote parity; `terrain_ab_metric.py` SMOKE-only (no ARI); no metric overrides the visual read (gap packet §0 rules 2-3; recheck14 §§3-4). 14 ROI metrics UNVERIFIED (no reviewer verdict, no gate PASS). MCP 6/6 preserved as tooling checks only, not parity evidence. Preserve hashes: point-in-time identities only (`manifest.json`, `lib/pattern_lib_index.json` class sizes, per-OBJ lengths/SHA where recorded) — existence evidence, never donor fidelity.

## 6. Canonical verdict (verbatim)

Parity UNVERIFIED. Chain 0/6. Nine P0 OPEN. RESULT IS NOT GOOD while blocking_unverified is non-empty.
