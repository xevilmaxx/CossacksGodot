# PORT1TO1 — REVIEW-GEN: read-only completeness review, generation/terrain domain

- id: PORT1TO1-review-gen-2026-11-27
- worker: REVIEW-GEN (read-only completeness review, generation/terrain)
- date: 2026-11-27
- scope: donor-derived generation/terrain elements vs port files: `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, `terrain_donor_inputs.gd`, `terrain_donor_world.gd`, `terrain_donor_tiles.gd` (absent), `terrain_donor_data.gd` (container, cited only), shader files, water files, mask/decoder tools, `assets/terrain_new` tiers
- governing spec: `docs/terrain_swarm_2026-11-26/spec/01_WORLD_DATA_MODEL.md`, `02_SEED_AND_RNG.md`, `03_MASK_TO_HEIGHT.md`, `04_PATTERN_STAMPING.md`, `05_WATER_SHORE.md`, `06_TILE_AND_ATLAS.md`, `07_RESOURCES.md`, `08_FIELDS_AND_PROPS.md`, `09_EDITOR_PARAMETERS.md`, `10_STAGE_ORDER.md`, `11_ASSET_CONVERSION.md`, `14_CURRENT_PIPELINE.md`
- prior audits compared: `reports/PORT1TO1_terrain_completeness.md` (id `PORT1TO1-terrain-completeness-2026-11-27`, TERRAIN-COMPLETE) and `reports/PORT1TO1_terrain_gap_packet.md` (id `PORT1TO1-terrain-gap-packet-2026-11-27`, TERRAIN-GAPPACKET)
- parity: **UNVERIFIED. No parity claim. No approximations.**
- chain: **0/6. `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.**
- method: read-only file-existence + content checks of the live tree. No code/Godot/git/donor execution. No gate run. Exactly one file written (this report); no other edits.

## 1. Honest verdict (read first)

- Parity UNVERIFIED for every generation/terrain element below. Presence on disk is existence only — never correctness, never a gate PASS, never donor fidelity.
- The prior completeness audit (`PORT1TO1_terrain_completeness.md`) and gap packet (`PORT1TO1_terrain_gap_packet.md`) already cover the large majority of this domain (seed/RNG ledger, mask law, stamp blend math, smoothing SKIP, water fail-closed gates, atlas/masks/lib tiers, props feed, N7/spec-copy absences, `terrain_donor_tiles.gd` absence). §3 of this report lists only what is **NOT already listed there**; §4 cross-references the already-listed items so they are not double-counted.
- New findings are small in count but load-bearing for a 1:1 claim: one donor stage output with **no port implementation at all** (bridges, G-NEW-1), one editor-domain mapping with **no file found** (D09/F09 UI→cfg, G-NEW-5), one consumer/producer contract whose wiring is unproven (tile_smooth_chains, G-NEW-4), plus three PARTIAL implementations whose missing halves are named (corner relocation already coded but runtime-unverified is actually IMPLEMENTED-code; jitter/leaftree explicitly skipped; legacy tools without per-file disposition).

## 2. Element ledger (donor-derived element → port status + exact path+label)

Status words: IMPLEMENTED = code/bytes present (runtime still UNVERIFIED throughout); PARTIAL = part present, missing half named; ABSENT = "no file found".

### 2.1 Canonical 12-stage order (spec/10 §1, X03 §5)

| # | Donor stage | Status | Port evidence (exact path + label) |
|---|---|---|---|
| 1 | init/seed | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:1291` `func _stage_init` |
| 2 | clear | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:1307` `func _stage_clear` |
| 3 | base tiled patterns | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:1323` `func _stage_base_tiles` |
| 4 | settings branch | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:1351` `func _stage_settings` |
| 5 | GenerateMap (mask→height→water→tiles→smooth) | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:1373` `func _stage_generate_map`, with `func _mask_to_height` (`:1408`), `func _smooth_chain` (`:1580`), `func _smooth_custom` (`:1618`), `func _water_fields` (`:1673`) |
| 6 | shore exclusion mask | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:2378` `func _stage_shore_exclusion` + `:2421` `func _shore_collision_ring` |
| 7 | starts + border keep-clear | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:2456` `func _stage_starts`, `func _start_to_cell` (`:2497`) |
| 8 | relief pattern passes | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:3402` `func _stage_relief`, `func _setup_patterns_by_type` (`:3464`), `func _stamp_pattern` (`:2958`), smooth post-pass `func _stamp_smooth_post` (`:3208`) |
| 9 | forest/stone/decor passes | IMPLEMENTED (code, stubbed tails) | `variant3d/scripts/terrain_donor_gen.gd:3543` `func _stage_forest_stone`; `:3614` `func _stage_forest_borders` labelled NULL stub ("P-PLACE-11/N17: labelled NULL stub, no props", `:902`) |
| 10 | units + scale | PARTIAL (see G-NEW-3) | `variant3d/scripts/terrain_donor_gen.gd:3634` `func _stage_units_scale`; jitter recorded at `:3643` but application skipped at `:3648` |
| 11 | FillOwnerMap + border objects | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:3661` `func _stage_owner_map` |
| 12 | finalize | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:3741` `func _stage_finalize` |
| — | dispatch order | IMPLEMENTED (code) | `variant3d/scripts/terrain_donor_gen.gd:816` `func generate`, stage calls `:887-904` |

### 2.2 Seed/RNG (spec/02)

IMPLEMENTED (structure) / live-state [U] — already listed (completeness §1, gap MW-5/MW-6). Port evidence re-verified this pass, no change: LCG `s←s·0xFC0D+0x3C6EF35F mod 2³²` (`terrain_donor_gen.gd:34-36,714`); `randkey0=0 CONSTANT`, `randkey1=Random($7FFFFFFF)` single draw (`:118-123,178-189,488-508`); 11 `SetRandomKey` + 3 `SetRandomExtKey64` sites (`:169-185,1049-1170`); `func reseed_from_key` / `func reseed_from_key64` (`:695,702`); `GetRandom(n)=floor(RandomExt*n)` + `GetRandomRange` equivalents `func next_int` / `func next_range` (`:727,730`). Delphi `Random(256)` stream `func next_u8` (`:720-722`, "state>>>24"). Three-stream separation (dscript-global / per-object / Delphi LCG) noted at spec/02 §3; per-object generator RNG stream (`sub_7281bc`, state `+0x18/+0x1c`) has no port counterpart found — folded into G-NEW-3 (same skipped object-RNG family).

### 2.3 Mask→height (spec/03)

IMPLEMENTED (decoder) with KNOWN CONTRACT DEFECT — already listed (completeness §1, gap MW-5; X19 BUG-1 `B>58` vs `B>=58`, BUG-2 white starts as water; `import_donor_masks.py:98`). Port evidence: `variant3d/tools/decode_donor_masks.py` PRESENT; `variant3d/tools/import_donor_masks.py` PRESENT; `variant3d/assets/terrain_new/masks/mask_index.json` + `masks/height/` tier PRESENT. Donor law `h=−1.1·B/255`, water `B>=58`, shore `B>=24` cited in mask_index labels (`terrain_donor_inputs.gd:797` forest-density [U] label cites `mask_index.json:76-77`). Coastal gate = mask B + height band (spec/03 §3): port `_smooth_chain` gates — content not re-verified beyond prior audit; no change.

### 2.4 Pattern stamping (spec/04 §6, D05/X12/X13)

IMPLEMENTED (code) / runtime UNVERIFIED — already listed (completeness §1, gap MW-5/MW-6). Port evidence re-verified: three blend paths ReplaceForWater/Replace/Smooth with `Min`-pivot, no clamp (completeness §1 telemetry cites `:822,928,1848,1946,1975`); relief dual-read `pat.get("grid")` → `pat.get("relief_float_grid")` (`:3001-3005`); primary key `relief_float_grid` (`terrain_donor_inputs.gd:1113-1114`); `HeightFieldMax` non-use preserved (`:1004` "U-MAX"); minangle/maxangle + WithAngle accept-with-warning stub (`:994` "U-ANG"); compact bundle validation of `relief_float_grid`/`occupancy_cells` (`terrain_donor_inputs.gd:359-381,1139-1149`). `m_swamp_12_old` 17×20 vs 18×23 quarantine preserved — already listed (gap MW-9); no change.

### 2.5 Water and shore (spec/05)

Already listed in full (completeness §2, gap MW-7/NG-5). Port evidence re-verified, no change: four literals −1.1 / −0.5 / −0.25 / −0.1 (`terrain_donor_mesh.gd:2050` telemetry; `terrain_donor_world.gd:442-443`); `WATER_SURFACE_Y=-0.25` PORT APPROX (`terrain_donor_mesh.gd:92`); sentinel 255 PORT APPROX (`:96`); `shore_prox` REMOVED (`:2321-2323`); `water3d.gd` constants `COAST_FADE=0.57` (`:69`), `DEEP_FADE=1.07` (`:70`), `SPEC_SOFT=170.0` (`:74`), `SPEC_GLOSSY=120.0` (`:75`), DEV colours `(0.1,0.24,0.24)/(0,0.025,0.05)` (`:82` ff), FILE/ENGINE scalar table + `_water_scalar_source=UNSET` hard-fail (`:71-72,103-141,210-291,721-747`), reflection/hmap/waveMap hard-fails; `water3d.gdshader` + `water_overlay.gdshader` PRESENT. `WaterFieldAdd(name,tx,tz,bx,bz,-0.5)` (D2:646-709): coordinates recorded, native call HOOK-only (`terrain_donor_gen.gd:632-656,1706-1726`, "no call") — covered by gap MW-7 U-items; no change.

### 2.6 Tiles, atlas, alpha (spec/06)

IMPLEMENTED (files) / art-gate rules UNVERIFIED — already listed (completeness §5, gap NG-1/AP-6/AP-7). Port evidence: `tile_index_atlas.png` + manifest + `alpha.png`/`alphavert.png` + `seasons/` (with `tile_index_atlas_winter.png` + manifest, `winter_aliases.json`, `desert_aliases.json` — verified present this pass via tier glob); `TILE_SMOOTH_PASSES=3` with preserved-contradiction label (`terrain_donor_gen.gd:245`); shore ids + sandsea/rock names (`:261-264`); cliff constants `cDiff`/thresholds cited via tile-classify stage. G-NEW-4 (chain wiring) and G-NEW-6 (tileindex shader) are the only new items here.

### 2.7 Resources: mines, starting resources, owner (spec/07)

- Mine ring bands (shared-by-ore `14+8R/32+10R/70+12R/22+16R`, rounds 3/4/5 for minesdensity 0/1/2, 256 tries/ore/ring, desert prefix, missing `case i=2` zero-init dst): IMPLEMENTED (code) — `func _setup_mines` (`terrain_donor_gen.gd:2535-2586`), `func _mine_band`/`func _band_id` (`:2589-2595,2598` ff), `C_TRYCOUNT_MINES=256` (`:271`), `C_BROKEN_GENERATOR_VERSION=92` (`:289`), gap reproduce `ring2_dst_mode` telemetry (`:2579-2581`). Already listed in substance (completeness §4, gap MW-9); per-attempt order cite P-PLACE-08 (`:2550-2553`) re-verified.
- Far-ring corner relocation (v>=90, D1:658-702): IMPLEMENTED (code) / runtime UNVERIFIED — **NEW (G-NEW-2)**: `func _mine_centre` (`terrain_donor_gen.gd:2702-2713`) gates `i==2, spcount<=4, mapsize_gt2, version>=90` and maps to `±(W-24/H-24)` corners with centred→grid conversion note (`:2708-2710`); call-site at `:2564-2565`.
- Starting resources (6 placements, 128×3 tries, ellipses 5×7/12×15/22×18, no food rects): IMPLEMENTED (code) — `func _setup_starting_resources` (`:2716` ff), `C_TRYCOUNT_START=128` (`:272`); `C_START_FOREST_FAMILIES` + desert 7-way→`floor(RandomExt*2)` replacement (`:306-319`). Already listed (gap MW-8/MW-9); no change.
- Owner fill (4-neighbour BFS, 160×160 scan grid, late after peasants + SetupBorderObjects + shore collision): `func _stage_owner_map` (`:3661`) — already listed; `SetupBorderObjects`/peace-marker content not separately verified — folded into G-NEW-1-adjacent (no bridge/border-object builder found).
- Deposit amounts: none set by generator (`res.script` hp rules) — already listed (gap MW-9); no change.

### 2.8 Fields and props channels (spec/08)

Already listed (completeness §§3–4, gap MW-8/MW-9/AP-1/AP-2/AP-8). `func sow_field` (`terrain_donor_gen.gd:1068`) + `func field_sowing_hook_info` (`:1119`) exist with "NOT called from generate()" label (`:1060`) — no change. Three-channel split (height windows / Objects props / tile-decal-shader) restated, no new finding except G-NEW-3 (scale application).

### 2.9 Editor parameters and cfg (spec/09)

- cfg decode: IMPLEMENTED (tool + tiers) — `decode_donor_cfg.py` PRESENT; parses `tilesmooth_scripts.cfg` 22 chains / 130 groups / 310 entries (self-checks C06/C07 at `:480-486`); `cfg/constants.json` carries `Size/Sharpness/TileChangeFactor/FrequencyFactor/CellsResolution/FailStandCount/DefaultMapSize/TileSmoothPasses/CastlePlateauFactor/HillPointsDensity/SmoothLevel/SmoothFactor` with donor path:line (verified this pass). 19-key globalparams census (V37) — already listed; no change.
- Editor UI→cfg mapping (D09/F09, spec/09 §6 "should map UI controls to these keys"): **ABSENT — NEW (G-NEW-5)**: glob `variant3d/{scripts,tools}/*editor*` → no file found.

### 2.10 Composer/world/mesh/inputs (spec/12–14 via reports)

IMPLEMENTED (files) — already listed (completeness §5, V36/V61/V65 STATIC-only). Re-verified: `terrain_donor_world.gd` binds I06/I07/I08/I09 + canonical I10 shader first + labelled alias fallback (`:31-36,239`); `visual_parity_claim=false` (`:28,475,516`); `terrain_donor_mesh.gd` donor-RGB/alpha-face constants (`:82-148`, `DONOR_FACE_SCALE=0.125` at `:257`), season setter (`:377-379`), collision ingest (`:511-516`); `terrain_donor_inputs.gd` compact-bundle gates (`:195-385`), `mask_resample_mode="nearest"` (`:109`), `SHAPE_ALIASES land→nowater2` (`:74`).

## 3. NEW gaps — not listed in `PORT1TO1_terrain_completeness.md` or `PORT1TO1_terrain_gap_packet.md` (prioritised)

### G-NEW-1 — Bridge generation has no port implementation (only tag constants)
- Donor element: `_misc_CreateBridge` (`misc.script:5271-5346`): `cScale=1.15`, `cBaseHeightOffset=0.4876`, block width `2.81·scale`, end widths `1.78·scale`, offsets `1.07·scale`, collision radius 3, step 2, tag 10; water-border collision radius `gc_WaterBorderSize=3`; spec/05 §6. `fordtyp` is a formation field, not a ford generator.
- Port status: ABSENT — no file found implementing bridge objects + collision painting. Only constants exist: `C_TAG_BRIDGE=10` (`variant3d/scripts/terrain_donor_gen.gd:164`) and `C_WATERBORDER_RAD=3` (`:167`). No `CreateBridge`/`SetupBorderObjects` builder found in `terrain_donor_gen.gd` (stage list §2.1 has no bridge stage; `_stage_owner_map` `:3661` covers owner fill, border-object content unverified).
- Governs: spec/05 §6; spec/10 §1 items 11 (`SetupBorderObjects`, peace-mode markers).
- Next action: static — record bridge literal ledger (all eight constants + tag/radius already have two) and mark runtime activation [U]; runtime proof is OWNER-GPU-RUNTIME. Acceptance: ledger row per constant with cite, or signed scope ruling; zero-mismatch = no invented bridge geometry.
- P0 effect: narrows only.

### G-NEW-2 — Mine corner relocation is code-present but runtime-unverified (ledger-only new item)
- Donor element: D1:658-702 far-ring corner relocation (v>=90, big map, i=2, sp<=4) → corners `±(maphW-24)` centred coords.
- Port status: IMPLEMENTED (code) / runtime UNVERIFIED: `func _mine_centre` (`variant3d/scripts/terrain_donor_gen.gd:2702-2713`) implements the gate and the centred→grid conversion (`+corner→W-24`, `-corner→24`, `:2708-2712`); call-site at `:2564-2565`. Prior audits cite ring bands and the `case i=2` gap but never this relocation body — it is not double-counted.
- Governs: spec/07 §1; V12; X03.
- Next action: OWNER-GPU-RUNTIME probe that the v>=90 branch selects corners on a qualifying seed; static part needs nothing. Acceptance: observed relocation on/off across the v90 boundary; zero-mismatch = exact ±24-cell corners, no second W/2 (V58).
- P0 effect: narrows only.

### G-NEW-3 — Object-scale 3-branch application explicitly skipped (jitter + terrainmesh/stone skip + winter leaftree delete)
- Donor element: `dogenerate.inc:1990-2021` three branches — 5% dead-band scale jitter, skip terrainmesh/stones, winter `leaftree` delete.
- Port status: PARTIAL — constant present (`C_SCALE_DEADBAND=0.05`, `variant3d/scripts/terrain_donor_gen.gd:284`); per-unit record carries `e["scale_jitter"]=r` (`:3643`); but application is an explicit NULL skip: `_note("object scale jitter skipped: separate object RNG [U] D1:1990-2021; future hook must also skip terrainmesh/stones and delete leaftree in winter (TODO D01/D07)", "unverified")` (`:3648`). Missing half: the separate object-scale jitter RNG stream (spec/02 §3, second stream family) + the two companion branches.
- Governs: spec/10 §2 (props row); spec/02 §3 (stream 2); D07.
- Next action: static — ledger the three branches + TODO(D01/D07) ownership already named in-file; runtime proof OWNER-GPU-RUNTIME. Acceptance: hook applies all three branches together (in-file rule `:3650-3651`); zero-mismatch = no jitter-only partial application.
- P0 effect: narrows only.

### G-NEW-4 — `tile_smooth_chains` consumer/producer contract wiring unproven
- Donor element: tile smoothing 3-pass horizontal/vertical sweep (`smoothtiles.inc:191-237`), weighted chains from `tilesmooth_scripts.cfg` (22 chains / 130 groups / 310 entries, spec/09 §1).
- Port status: PARTIAL — consumer exists (`terrain_donor_gen.gd:1883-1889`: reads `p.get("tile_smooth_chains", [])`, skips with `_note("tile_smooth_chains absent — tile smoothing skipped; TODO(I01) decoder")` when empty; consumes caller chains verbatim at `:1933-1934` via `func _smooth_tiles` `:2266` with `TILE_SMOOTH_PASSES=3`); producer parses the source (`decode_donor_cfg.py:80-85,117,390-396,424,473-486`: C05 30 `TileName`, C06 22 chains, C07 130 groups self-checks). Missing half: proof that the decoder emits the `tile_smooth_chains` key in exactly the `Array[Array[Array[Dictionary]]]` shape the consumer reads (spec/10 declares the param shape at `:810`), end-to-end on one seed.
- Governs: spec/06 §8 (D08/X08/X17/V20/I05); spec/09 §4 (script-over-cfg rule).
- Next action: WORKER-EXECUTABLE-STATIC — emit→consume shape proof on one decoded cfg; OWNER-GPU-RUNTIME for the smoothed-tile gate run. Acceptance: non-empty chains flow caller→gen→`_smooth_tiles` with zero skipped notes; zero-mismatch = no silent skip, no cfg-6-pass confusion (contradiction preserved: script 3 wins for skirmish).
- P0 effect: narrows only.

### G-NEW-5 — Editor UI→cfg-key mapping has no file
- Donor element: D09 editor binary + F09 editor script → UI controls bound to `globalparams.cfg`/`localparams.cfg` keys (spec/09 §6: "editor-parameter mapping (D09) should map UI controls to these keys").
- Port status: ABSENT — glob `variant3d/{scripts,tools}/*editor*` returns no file found. `decode_donor_cfg.py` decodes the cfg literals (G-§2.9) but no port file maps editor/brush UI controls to them; `terrain_donor_inputs.gd` handles masks/patterns/compact bundles only. `brush_plt_*` family cites exist in gen (`terrain_donor_gen.gd:336-339,443`) as family data, not as editor bindings.
- Governs: spec/09 §6; D09; F09.
- Next action: WORKER-EXECUTABLE-STATIC ledger (control→key rows, all [U] until captured) or signed out-of-scope ruling. Acceptance: mapping file PRESENT or ruled-absent with link; zero-mismatch = no invented control binding.
- P0 effect: narrows only.

### G-NEW-6 — Legacy tile shader `terrain_tileindex.gdshader` not inventoried in prior audits
- Element: `variant3d/shaders/terrain_tileindex.gdshader` — live legacy-path terrain shader with donor citations (`BlendingMode = bmTransparency`, `reftile.mat:17`; face `TextureScale 0.125`; alpha/alphavert samplers; `UV2.x=tile id / UV2.y=face`; PORT APPROX labels at `:328,:345`).
- Port status: IMPLEMENTED (file existence) / content UNVERIFIED — PRESENT on disk but named in neither completeness §5 (which inventories only the I10 `terrain_donor_shader.gdshader`) nor the gap packet tool/shader lists. Legacy path per spec/14 (P01), so donor-gen scope impact is containment, not correctness: confirm it is unreachable when `terrain_backend=="donor"`.
- Governs: spec/06 §5 (alpha semantics); spec/14 (legacy coexistence, no edits to six legacy files).
- Next action: WORKER-EXECUTABLE-STATIC — one-line containment ledger (loader + backend gate cite); no shader edit. Acceptance: reachability row recorded; zero-mismatch = no legacy shader cited as donor proof.
- P0 effect: narrows only.

### G-NEW-7 — Legacy tool dispositions per spec/11 §11.7 not recorded per file
- Elements: `variant3d/tools/build_tile_index_atlas.py`, `build_winter_atlas.py`, `donor_gen.py` (DO NOT PORT), `gen_variant_maps.py`, `heightmap_splat.py`, `scan_map.py`, `import_donor_map.py` (KEEP/PORT LOGIC but zero-tileblock placeholder at `:450,462-465`), `tile_atlas_loader.gd` (three atlas modes + overrides) — all PRESENT (verified via tools/scripts globs this pass); `donor_gen.py` stops at the `w*h` occupancy prefix (`:74-85`) and synthesises the rest (P04 F1/F2).
- Port status: PARTIAL — files present; per-file KEEP/PORT/DO-NOT-PORT/RETIRE disposition ledger (spec/11 §11.7 table) has no port-side record found, and the gap packet names only six importer tools (completeness §5) without these seven. Missing half: per-file disposition rows + the `import_donor_map.py` zero-tileblock caveat carried into any `.map` work (D04 owns full format).
- Governs: spec/11 §§11.2/11.7; P04; D04.
- Next action: WORKER-EXECUTABLE-STATIC ledger only; `app/tools/**` mirror stays byte-untouched. Acceptance: disposition row per tool; zero-mismatch = `donor_gen.py` never cited as a compiler, zero-tileblock dumps never cited as tile truth.
- P0 effect: narrows only.

## 4. Already-listed items (re-verified, not new — no action beyond prior packets)

- 11+3 RNG re-seed sites, shared-stream inheritance, `U-SEED`/`N17-G9` probes → gap MW-6.
- Mask B-law, BUG-1/BUG-2, `masks/height/` tier, start dots → gap MW-5.
- Relief dual-read, stamp blend telemetry, row-sign/height-unit [U], N17-G5/G11/G16 hooks → gap MW-5/MW-6.
- `SmoothTerrain(radius 3)` SKIP + NULL `bsmooth_kernel` hook, tile 3-pass H-then-V rule → gap MW-6.
- Grid-size seam (`_apply_mask` `:729` override, 64²→256²) → gap MW-4.
- `pattern.lib`/`pattern`/`cfg` ingestion tiers (55.7 MB lib index, 1.28 MB constants) → completeness §1; X24/X34/X49/X05 vectors REPORTED-ONLY.
- `terrain_donor_tiles.gd` absent; `validate_terrain_new.py` absent; `variant3d/tools/terrain_qa_spec.json` copy absent → gap NG-6/MW-3.
- Water fail-closed gates (U12/U3/U4*/waveMap), four level literals, shore ids + 8×45° sectors + 3× power-0.35 smoother, `bmTransparency` factors [U] → gap MW-7/NG-5.
- Props feed zero-proof (`matched_stamps=0` trace), `BaseName.value`/Scaling/Position.Y drops, double-instance risk, GR-A24 repoint → gap MW-8.
- Mines/mills/swamps/lakes activation + `MINE_RECORD_BINDING` + `m_swamp_12_old`/`lake_big` quarantines → gap MW-9.
- Atlas/masks/lib/schemas/manifest tiers PRESENT-but-UNVERIFIED; captures populated-but-unadjudicated; collision write-path PRESENT/tag-consumption OPEN → gap NG-1/NG-2/NG-4.
- `sow_field` NOT-called-from-generate label; food-rect refutation → gap MW-9.
- Spec/toolchain readiness (V16/V47 19 OPEN, I03 F-01 breach, I14/I15 undefined, spool acks) → gap MW-10.

## 5. Close-out

- Parity **UNVERIFIED** for every element in §§2–3. Chain **0/6**; `blocking_unverified` non-empty (no fresh gate verdicts, no owner-signed capture verdict, no donor GPU A/B frame) ⇒ **RESULT IS NOT GOOD**.
- Seven new items (§3: one ABSENT implementation G-NEW-1, one ABSENT mapping G-NEW-5, five PARTIAL/inventory G-NEW-2/3/4/6/7). None closes any class-A value/behaviour item; static work narrows only.
- No approximations, no parity claim. Read-only; exactly one file written.

*End of report. Parity UNVERIFIED. Chain 0/6, RESULT IS NOT GOOD while `blocking_unverified` is non-empty.*
