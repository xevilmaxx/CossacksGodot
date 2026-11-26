---
id: P04
ticket: "Wave P / P04 — existing decoder tools reuse audit"
title: "P04 — donor-faithful terrain compiler: reuse/retire audit of variant3d/tools/**"
owner: P04 (port baseline audit subagent)
created: 2026-11-26
status: COMPLETE__READ_ONLY__NO_DONOR_READ__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
files_created:
  - docs/terrain_swarm_2026-11-26/reports/P04_tool_audit.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:41,125). Every tool output described here is a derived PORT APPROXIMATION until F/D-wave byte proofs and a real capture land. No donor-parity claim is made anywhere in this report."
scope: "Read-only audit of the named Python tools in variant3d/tools/** (app/tools/** inspected read-only for drift). No source, shader, config, asset, test, git or donor file was edited or opened; no donor binary was read this pass; no Godot/runner job was submitted."
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md
  - docs/terrain_swarm_2026-11-26/reports/F05_tile_mapping.md
  - docs/terrain_swarm_2026-11-25/reports/P06_loading_path.md
  - docs/terrain_swarm_2026-11-25/reports/P08_quality_knobs.md
  - docs/coord_swarm_2026-11-25/reports/STAGE_IMPORT_01.md
  - docs/terrain_swarm_2026-11-25/reports/H03_heightmap_hypothesis.md
  - docs/terrain_swarm_2026-11-25/reports/H01_donor_layers.md
  - docs/terrain_swarm_2026-11-25/reports/Z05_relief_prop_conversion.md
  - docs/terrain_swarm_2026-11-25/reports/Z06_prop_placement.md
  - docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md
  - docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md
---

# P04 — existing decoder tools: reuse / retire audit

> **Label key.** **[O]** = literal file:line / hash / on-disk count observed in this
> read-only pass or in cited prior art. **[D]** = deterministic consequence of
> observed code. **[I]** = plausible reading without a byte proof. **[U]** =
> UNVERIFIED; needs a donor-byte decode, a Godot run or an owner decision.
> Everything that reproduces donor behaviour stays **PORT APPROXIMATION** until a
> real donor GPU A/B frame exists (CHARTER.md:41,44,125).

## 0. Executive summary

1. **[O]** The tool tree already contains **one genuine donor-binary decoder**
   (`import_donor_map.py`) and **four working donor-data conversion routes** (mask
   TGA→PNG, `.pattern` occupancy→JSON, `generator.cfg` families→JSON, block
   PNG→atlas+alpha). All are read-only and private-use by their own docstrings
   (`import_donor_map.py:4-7`; `import_donor_masks.py:15`;
   `build_tile_index_atlas.py:48-50`; `convert_models.py:18-19`).
2. **[O]** None of these tools decodes the two payloads the donor-first compiler
   actually needs: the **`.pattern` relief float grid + object records** (every
   reader stops after `w*h` occupancy bytes — `donor_gen.py:74-85`,
   `export_donor_patterns.py:139-147`; H03-E14 at
   `docs/terrain_swarm_2026-11-25/reports/H03_heightmap_hypothesis.md:65`) and the
   **donor tile ids** (the default `.map` dump writes a *zero placeholder*
   `import_donor_map.py:450,462-465`). **[U]** Both tails remain F01/F02/D05/D04
   scope; no tool here may be mistaken for a complete decoder.
3. **[O]** Several tools are deliberately approximate or synthesised, not donor
   behaviour: `donor_gen.py:25-27,62-71,191,240,357-374` (synthesised objects,
   authored relief constants, Python RNG, thinned tile pass), `gen_variant_maps.py:57-85,478-489,686-733` (blob noise + hand-written recipes), `heightmap_splat.py:244-278` (neighbour blend + height-normalised alpha), `build_tile_index_atlas.py:34-37,220,243-259` (atlas packing, upscale and alpha-intensity approximations). Their outputs are **PORT APPROXIMATION**, not donor decodes.
4. **[D]** The correct disposition is **not to edit the legacy tools in place**:
   A03 already freezes them as read-only cross-checks
   (`docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md:280`). Reuse their
   *proven algorithms* by copying the logic into the new `*_new.py` tools under
   `variant3d/tools/` (A03:274-279); keep the originals byte-identical.
5. **[O]** `app/tools/**` is a stale/duplicate mirror: 12 named tools, all 16 `t6_*.py` pieces and all 21 `piece_specs/*.json` are byte-identical to their `variant3d/tools/**` counterparts; three tools exist only in `variant3d/tools/` (`import_donor_map.py`, `build_tile_index_atlas.py`, `pack_tile_atlas_split.py`) and `convert_models.py` differs (the `variant3d` copy carries the additive relief/nation tables, `convert_models.py:499-611`). **[D]** `app/` must stay byte-untouched (CHARTER.md:28-30,125); only the `variant3d` copies are referenced below.
6. **[O]** No tool in this tree copies a **raw donor binary** into the repository.
   The licence flags below distinguish `DERIVED-ART` (donor pixels/vertices embedded in a converted container), `DERIVED-DATA` (numbers/strings only) and `NONE` (no donor write). All remain private-use derived material; none is a parity proof.

## 1. Method and snapshot

- **[O]** Every named Python file was read in full: `parse_terrain.py` (12 lines), `extract_map.py` (157), `import_donor_map.py` (553), `import_donor_masks.py` (118), `donor_gen.py` (499), `export_donor_patterns.py` (165), `build_tile_index_atlas.py` (377), `pack_tile_atlas_split.py` (349), `heightmap_splat.py` (434), `build_missions.py` (159), `convert_models.py` (748), `compute_ortho.py` (172), `scan_map.py` (514), `gen_variant_maps.py` (876), `t6_registry.py` (855), `terrain_piece_render.py` and all 16 `pieces/t6_*.py`. All 21 `piece_specs/*.json` filenames and the documented schema (`terrain_piece_render.py:21-50`) were checked; `shore_sand.json` was read for donor-evidence fields (`:2-6,76-81`).
- **[O]** SHA-256 prefix comparison (this pass): identical in both trees — `parse_terrain.py` `596F71436380`, `extract_map.py` `DF9BA3B417B9`, `import_donor_masks.py` `60F6DA8EAF7C`, `donor_gen.py` `566D8DC1E9E5`, `export_donor_patterns.py` `20756A6D8DAB`, `heightmap_splat.py` `297AA8CEE2D2`, `build_missions.py` `A63D197F07B4`, `compute_ortho.py` `246D4ED167BB`, `scan_map.py` `06047B793061`, `gen_variant_maps.py` `7DE86DE244B3`, `t6_registry.py` `6EFB951EE1B9`, `terrain_piece_render.py` `5401B2EB0894`; 16/16 pieces and 21/21 specs identical; 0 spec and 0 piece hash differences. Different: `convert_models.py` variant3d `F37EE627F3C6` vs app `D28EAC8E7DD1` (consistent with Z05 §2 / R12).
- **[O]** Prior-art anchors used: `P06_loading_path.md:130-147` (legacy atlas runtime path); `P08_quality_knobs.md:30-44,101-102` (map-size/camera knobs); `STAGE_IMPORT_01.md:85-107,174-179` (import sidecars are not runtime proof); `H03_heightmap_hypothesis.md:63-65,129,155`; `A04_tile_diversity.md:160-195`; `Z05_relief_prop_conversion.md:13,133`; `Z06_prop_placement.md:201,219,232`; `G07_relief_plan.md:284-288,351`.

## 2. Evidence and reuse table

Donor-byte flag legend: **RAW** = verbatim donor binary committed (none found); **ART** = donor pixels/vertices embedded in a derived container; **DATA** = donor-derived numbers/strings only; **NONE** = no donor write to repo. Labels in the "Correct vs approximation" column apply to the *tool's own output*, not to the donor game.

| # | Tool (variant3d/tools/…) | Purpose / input → output | Donor paths it reads | Copies donor bytes? (licence flag) | Correct donor decode vs approximation (file:line) | Reuse disposition |
|---:|---|---|---|---|---|---|
| 1 | `parse_terrain.py` | Text diagnostic: prints bytes `35000:37200` of one donor include to stdout; no file output (`parse_terrain.py:1-12`) | `data/scripts/common.inc/generatemap.inc` (`:10`) | **NONE** — stdout text only (`:11-12`) | Raw donor text slice is **[O]** literal bytes; no parsing, no semantics; any rule read into it is **[I]** | **RETIRE** as compiler input; keep only as a read-only peek. Replace with F03 cfg/script extractor (`decode_donor_cfg_new.py`, A03:275) |
| 2 | `extract_map.py` | Donor `.map` → `assets/maps/<stem>.json` + `_summary.json`: header/UID/markers/placement strings, nation counts, block offsets (`extract_map.py:56-111,114-153`) | `data/maps/missions/*.map` (`:129`) or `--map` (`:117,125-126`) | **DATA** — ASCII names/header strings copied into JSON (`:97-111,143`); no binary | Header/UID/markers/placement regexes are **[O]** string readings (`:42-47,69-86`); heightmap/tile grid explicitly **undecodable** by this tool (`:5-6,108-110`); nation/kind buckets **[I]** (`:49-53,74-84`) | **RETIRE** from terrain compiler; keep as mission/scenario placement inventory only (`DD_MAPS.md:157`; `AUDIT3D_08_donor_coverage.md:70`). Superseded for height by #3 |
| 3 | `import_donor_map.py` | `.map` → dump JSON with base64 LE `float32[W*H]` height + **zero** tileblock, meta offsets/sha256; also `--survey` tile histogram, `--export-placements`, `--verify` (`import_donor_map.py:18-31,74-90,222-304,309-377,445-469,489-551`) | Positional donor `.map` (`:494,525`); port mirror `tileblocks.json` (`:65,211-219`); local dump only for `--verify` (`:64,402-422`) | **DATA** — decoded floats/offsets/hash in JSON; **no donor bytes written**; refuses any path inside the repo (`:4-7,472-486`) | Height grid anchors (`TerrainMapBegin`, repeated `u32 W,W`, validated grid end) are **[O]** decodes (`:113-174`, provenance `:18-25`); 37-byte tile records, 4×u8 ids and 1.0f quad weights **[O]** in `--survey` only (`:186-209,230-237,286-295`); default dump tileblock is a **zero placeholder with explicit caveat** (`:450,462-465`) — NOT donor tile data; named records partial **[O]** (`:239-267`); GameObject field semantics beyond strings/first float triplet **[U]** (`:30-31,354,372-376`); row orientation **[U]** (`:466`); `seed:0` invented (`:77,448`) | **KEEP / PORT LOGIC** into the new donor-map decoder: reuse `_locate`/`read_donor`/`find_tile_grid` as validation anchors, but new tool must emit decoded tile ids + placements, never the zero tileblock. D04 owns the full format |
| 4 | `import_donor_masks.py` | Donor RGB TGA → PNG + `masks/manifest.json` with `{file,starts,water}` (`:31-37,40-64,67-118`) | `data/gen/terrainmasks/<type>/*pl*_gauss.tga`, 7 folders (`:31-32,78-86`) | **ART** — donor RGB pixel values preserved in PNG (`:92-98`); private-use note `:15` | TGA RGB decode **[O]** (`:92-93`); channel semantics R/G/B/white from docstring (`:4-9`) **[O]** per H03-E12 (`H03_heightmap_hypothesis.md:63`), but the "gauss R/G are zero except starts" claim (`:7-9`) conflicts with "R channel is genuine height data" (same report `:129`) — **[U]**; water heuristic `B>58` (`:98`) **[I]**; white connected-component starts (`:40-64`) **[I]**; `PER_TYPE=8` subsample (`:37,85-86`) drops most donor masks — not a full inventory (F04 scope) | **KEEP / EXTEND** into `decode_donor_mask_new.py` (A03:276): reuse TGA open + start-dot BFS, but store the raw R relief channel (not just water fraction) and cover every mask; F03/D03/D05 own the height mapping |
| 5 | `donor_gen.py` | Preview engine: donor mask + `.pattern` occupancy + `generator.cfg` → in-memory `DonorMap` (height/type/trees/stones/mines/wheat/bushes) (`:185-267,474-481`); no runtime asset | `data/pattern/*.pattern` (`:44,74-85`), `data/game/var/generator.cfg` (`:45,97-129`), port mask PNGs (`:211-220`); scripts cited in docstring (`:6-12`) | **NONE** — preview only; donor read-only via `$COSSACKS3_DIR` (`:43-45`) | `.pattern` prefix `int32 w,h` + `w*h` occupancy bytes **[O]** (`:74-85`), but float grid at byte `8225` **not decoded** (H03-E14 `:65`); `Name/Pattern/Freq` cfg lines **[O]** (`:97-115`); constants `C_WATER=-1.1`, `C_PLATEAU=2.964`, circles/rings, `DONOR_UNITS=160` **[I]** source-cited (`:48-59`; A03 E13 `:65`); `relief()` thresholds authored (`:62-71`); object contents **synthesised per family** (`:25-27`); coastline 3-pass smoothing port reading (`:251-260`); Python `random.Random` **(191)** is not the donor RNG (D02); tile pass deliberately thinned (`:357-374`) and never reaches the live tileblock (`A04_tile_diversity.md:180-185`); whether the cited `dogenerate.inc` lines execute is **[U]** (`A04:193-195`) | **DO NOT PORT AS COMPILER.** Keep read-only as a stage-order/constant reference and A05 evidence (`A05_qa_harness.md:71` E06); replace with F01/D05 byte-proven pattern tables and D02 donor RNG |
| 6 | `export_donor_patterns.py` | `.pattern` + `generator.cfg` → `donor_patterns.json`: 41 curated families with weights and centred occupancy cells (`:83-103,139-158`); alias/drop log (`:131-138`) | via `donor_gen` `PATTERNS`/`GENERATOR_CFG` (`:15-16,32-39,45,75-81`) | **DATA** — centred `(dx,dy)` lists + weights; no raw bytes (`:139-158`) | Real-file resolution of cfg names **[O]** (`:32-72`); alias/zero-pad candidates **[I]** but gated by real `.pattern` existence (`:65-72`); `WANTED` is a 41-family subset (A03 E2 `:54`), not the full catalogue; output holds **only occupancy cells** — no relief float grid, no object transforms (H03-E14 `:65`; `Z06_prop_placement.md:232`; `Z05_relief_prop_conversion.md:133`); centring `x-w//2` is a port convention (`Z06:201`) **[I]** | **KEEP read-only cross-check** for family weights and occupancy round-trip (A03:280,289); **REPLACE** with `decode_donor_pattern_new.py` (A03:274) that emits float grids + object lists under `terrain_new/` |
| 7 | `build_tile_index_atlas.py` | Shipped `presets_summer.json` + port block PNGs + donor BMPs → `tile_index_atlas.png` (16×8×1024²), manifest, `alpha.png`, `alphavert.png` (`:1-10,84-100,181-221,224-265,317-377`) | `data/terrain/tiles/terrain.presets:2-6` (`:14-18,347`), `tiles.mat:142-148,206-220` (`:19-20,168-169`), `reftilealpha.mat:30-37,139-146` (`:22-24,95-100`), `reftile.mat:120-169` (`:25-28`), `data/terrain/tiles/textures/{alpha,alphavert}.bmp` (`:91,228`) | **ART** — donor BMP pixels → intensity PNG (`:242-250`); port block PNGs pasted into atlas (`:181-208`); raw donor BMP never committed (`:48-50`) | Index order / 124 names **[O]** from shipped mirror (`:136-143`; F05 E12 `F05_tile_mapping.md:116`); face-base reuse from `tiles.mat` **[O]** (`:130-133,162-170`); uniform 16×8 packing = `APPROX_ATLAS_PACKING`, donor `tsDouble/ttExtended` engine-side **[U]** (`:34-35,220`); NEAREST sand upscale **APPROX** (`:36-37,193-200`); `convert("L")` is an **APPROX** of `tiaAlphaFromIntensity` (`:243-259`); no cell↔tile sub-rect mapping invented **[U]** (`:26-28`); 3 EMPTY cells **UNVERIFIED** (`:38-40,172-175`); `shipped_ids()` still reads legacy `app/shots/g32_dump.json` (`:76,268-287`) | **KEEP read-only `--check` cross-check (A03:280); DO NOT EDIT.** Port index/face/alpha-header logic into `build_terrain_new_atlas.py` (A03:277) with a new root and compact cell; F05/F06/D08 own authoritative tile/alpha mapping |
| 8 | `pack_tile_atlas_split.py` | Derived atlas PNG → ordered ≤90 MB parts + `split_manifest.json` + copied masks; `--check` reassembles and verifies sha256 (`:1-10,110-180,183-219,242-277,311-331`) | None directly; only evidence strings `reftilealpha.mat:30-37,139-146` (`:62-65`); source is derived atlas (`:53`) | **NONE** for donor; copies **port** mask PNGs (`:222-239`); lossless split of derived PNG (`:67-73`) | No donor decode — lossless byte split/hash is **[D]** (`:110-219`); ZIP ratio 0.998 **[O]** measured (`:11-16,88-107`); inherits `APPROX_ATLAS_PACKING` and `NO_VISUAL_PARITY_CLAIM` (`:71-72`) | **RETIRE from fresh compiler** if the new atlas is commit-sized (A03 `--cell 128`:277, R3:317); keep `--check`/`--measure-zip` as legacy cross-check (A03:280). Reuse the `user://` + sha256 reassembly contract (`:260-264`) only if split mode is still needed |
| 9 | `heightmap_splat.py` | Dump JSON (`height`/`tileblock` base64 or arrays) + `presets_summer.json` + block PNGs → RGBA splat PNG + manifest (`:1-51,137-176,230-297,300-338`) | **NONE** — explicitly port-assets-only (`:4-6`); no donor path | **NONE** — port assets + derived dump only; records dump sha256 (`:320`) | Base64/array dump decode **[O]** deterministic (`:107-176`); id→name table **[O]** donor-derived (`:23-26,179-221`); neighbour RGB blend is **PORT APPROX** (`:244-275`); A = normalised height is **PORT APPROX** of elevation (`:277-278`); roughness proxy explicitly **not donor data** (`:36-38,77-91`); tileblock ids in a dump are **port-generated**, not donor tile ids | **KEEP** the deterministic dump reader (`_as_bytes`/`load_dump`) for QA ingest; **REPLACE** blend/alpha/id logic with the donor tile+atlas+`bmTransparency` path (F05/F06/D08). Do not feed legacy splat into `terrain_new` |
| 10 | `build_missions.py` | CFG text → `assets/missions.json` (nations, map types, start options, campaigns, battles) (`:1-17,135-155`); regex parsers (`:57-106`) + hardcoded fallbacks (`:122-133`) | `data/game/var/{campaigns,battles,generator,startingsettings}.cfg` (`:4-9,117-120`); `country.script` cited (`:142`) | **DATA** — parsed names + hardcoded lists in JSON (`:135-149`) | Regex `Name =` readings **[O]** (`:65-106`); campaign grouping heuristic **[I]** (`:70-94`); nations/map_types/start_options are **hardcoded** (`:28-54`) and fallback lists invented (`:122-133`) — PORT APPROX, not donor decodes | **RETIRE** from the terrain pipeline (menu/scenario only; `AUDIT3D_08:64`); F03 owns real cfg constants. No terrain asset is emitted here |
| 11 | `convert_models.py` | Donor `.oss`/`.osm`/`.dds` → OBJ + MTL + PNG + manifest (bbox/verts/faces) (`:48-158,632-744`); additive opt-in nation/relief tables (`:499-611`) | `data/actors/{units,buildings,buildings/<nat>,env}/*.oss`/`*.osm` (`:165-243,246-297,300-381,384-409,412-496,512-611`); `data/materials/**/*.dds` (same tables); `data/objects/env/<base>.prop` cited for material names (`:416-418`) | **ART** — donor vertices/faces/UVs written verbatim to OBJ (`:114-130`), donor DDS pixels to PNG (`:140-158`); no raw donor binary in repo (`:18-19`) | `.oss`/`.osm` header + array readers **[O]** exact-size closure (`N07_all_nations_assets.md:84-91`); **static bind pose only** — weights/bones/anim discarded, `.osm` first frame (`:21-24,48-99`); raw donor units, **no per-placement Scaling/Direction** from `pattern.lib` (`:591-596`; `Z05:13`; `Z06:232`); `.prop` used only for material names, mask bytes not read (`G09_footprint.md:43`); MTL backslash path hazard (`FOLD_01_folder_split.md:483` R10) | **KEEP** readers/writers read-only for relief, forest, stone, mine and field props (`:412-496,582-611`); **REPLACE** placement/transform logic with F01/F02/F07/F08 object records. Never edit the `app/tools` copy (stale — Z05 §2/R12) |
| 12 | `compute_ortho.py` | Donor `.oss` + `.aaf` + port anim index → stdout audit lines; no writes (`:1-11,105-172`) | `data/actors/units/<base>.oss` (`:109`), `data/animations/aaf/<base>.aaf` (`:110`) | **NONE** — stdout only (`:171-172`) | `.oss` reader duplicates `convert_models.read_oss` **[O]** (`:47-59`); CPU skinning **[D]** (`:74-96`); 8-azimuth/32° ortho **[I]** (`:145-160`); explicitly **audit-only**, `bake_sprites.py` owns index (`:2-5,172`) | **RETIRE** from the terrain pipeline; keep only as unit-art QA (`N04_nation_fix.md:117`). Emits no terrain asset |
| 13 | `scan_map.py` | Directory of dump JSONs → per-seed metrics + gates, exit 1 if any red (`:1-23,420-510`) | None directly; donor evidence cited from `docs/audit/PIECES/map_density.md` (`:57-65`) | **NONE** — QA tool | Dump base64 decode **[O]** (`:86-97`); stamp/coverage targets are **DERIVED** from prior-wave docs (`:57-83`), not a donor binary; water ±5 pp / purity=100 / clear=100 / coast≥90 / cliff≥80 / tileflow≥99 / reach gates (`:478-493`) are **port QA assertions [I]**; `reachability` divides dump coords by 2 (`:349-353,362,412`) — coupled to the port's 2-cells-per-unit scale and will break on a donor-coordinate dump | **EXTEND** as the A05 QA harness with the new dump schema; re-derive every gate from fresh donor evidence and **never lower a threshold**; keep legacy gates only for legacy dumps |
| 14 | `gen_variant_maps.py` | `donor_gen` engine **or** invented blob engine + port PNGs → 3 preview PNGs, contact/comparison sheets, `spec.json` (`:1-23,831-872`) | None directly (uses `donor_gen` and port assets, `:35,96-193`); reference JPEGs from `~/Downloads/c3` (`:45,776-811`) | **NONE** — derived preview PNGs; reference images read in place (`:779-784`) | `--engine donor` simply delegates to `donor_gen` (`:852-854`) and inherits its approximations; `blob` engine uses invented `Noise`/`fbm` (`:57-85`) and authored recipes (`:686-733`) — **PORT APPROXIMATION**; field decal is offline only (`F2_01_mill_fields_audit.md:85`) | **RETIRE as compiler**; KEEP as labelled visual A/B preview input for A05. New pipeline must never use the blob engine |
| 15 | `t6_registry.py` | `docs/t6/**` tickets/reports/manifests → dashboard markdown (`:35-36,226-488,665-818`) | None | **NONE** | Markdown/text parsing **[O]**; no donor decode at all | **RETIRE** from terrain pipeline — project-management tool, not a compiler |
| 16 | `pieces/t6_*.py` (16 files) | Headless deterministic 512² single-piece render proxies from port PNGs; optional read-only donor DDS/JPEG for compare/verify; output PNG + manifest (`terrain_piece_render.py:1-20`; per-piece docstrings) | `envfieldd.dds` (`t6_field_crops.py:49,147`); donor tiles dir (`t6_stones_rocks.py:85,485-504`); `winterN.dds` (`t6_winter_variant.py:384-394,674`); `g_hil1.pattern` cited but raw bytes never copied (`t6_hill_ridge.py:16-19`); reference screenshots elsewhere | **ART / REFERENCE-ONLY** — donor files read in place; derived PNGs carry port art + measured donor anchors; no raw donor binary committed | Measured anchors embedded as numbers (`t6_field_crops.py:60-70`; `t6_stones_rocks.py:459-468`); `t6_water.py:6-29` is a CPU analogue of the donor fragment shader with explicit non-donor terms; `t6_plateau.py:12-30` height model is a **port profile**, not a decoded donor heightfield; `t6_hill_ridge.py:16-19` uses a **derived envelope**, not raw occupancy; all acceptance metrics **PORT APPROX** | **KEEP** as per-landscape-class visual acceptance fixtures for A04/A05 (hills/plateau/ravine/shore/water/forest/stone/mines/fields/seasons). Never treat as runtime decoders or donor-parity evidence |
| 17 | `piece_specs/*.json` (21 files) | JSON layer recipes consumed by `terrain_piece_render.py` (schema `:21-50`) and 4 pieces (`t6_shore_sand.py:42,87`; `t6_stones_rocks.py:80,280`; `t6_desert_variant.py:76,235`); 6 have no dedicated piece | Donor evidence paths as **strings**, e.g. `shore_sand.json:76-81` | **NONE** — text spec only | Donor evidence citations **[O]** as text; reference boxes and visual thresholds **[I]** chosen crops/proxies | **KEEP** as QA fixture inputs; do not feed the compiler. F05/F06/D08 own authoritative tile and alpha mapping |

## 3. Findings

### F1 — The one real donor decoder throws away the part the compiler needs ([O]/[U])

`import_donor_map.py` is the strongest artifact in the tree: it validates `TerrainMapBegin`/`End` length prefixes, locates the **second** repeated `u32 W,u32 W` header and unpacks a measured `float32[W*H]` grid without hard-coding W/H (`import_donor_map.py:113-174`; provenance `:18-25`). Its `--survey` even decodes the 37-byte tile records and the four u8 tile indices (`find_tile_grid` `:186-209`, `survey` `:222-237,286-295`). **But the default dump wires `tileblock` to `base64.b64encode(bytes(cells))` — all zeros — with a caveat that donor tile semantics are UNVERIFIED** (`:450,462-465`). A fresh compiler that ingests this dump would get donor height but **no donor tile ids** — exactly the failure mode the owner complained about ("flat relief / wrong tiles"). **[D]** The new decoder must keep the height anchors but emit the surveyed ids instead of the placeholder; D04 owns the complete format. Row orientation (`:466`) and placement field semantics (`:354,372-376`) remain **[U]**.

### F2 — Pattern readers stop at the occupancy prefix ([O]/[U])

Both `donor_gen.parse_pattern()` (`donor_gen.py:74-85`) and `export_donor_patterns.py` (`export_donor_patterns.py:75-81,139-147`) read only `int32 w,h` plus `w*h` occupancy bytes. Prior art measured the float grid at byte offset **8225** of `k_ravine_big_stone_1.pattern` (`H03_heightmap_hypothesis.md:65`), and the object list / `pattern.lib` records remain **[U]** (A03:44,288). Everything downstream of the prefix — `relief()` (`donor_gen.py:62-71`), the height formula (`:240`), synthesised objects (`:25-27`) and the per-family callbacks (`:427-447`) — is **PORT APPROXIMATION**, not a donor decode. `export_donor_patterns.py` is nevertheless correct for what it does: aliases are checked against real `.pattern` files (`:32-72`) and unresolvable cfg names are dropped rather than silently stamped (`:119-124`).

### F3 — Mask conversion preserves pixels but not the compiler contract ([O]/[I]/[U])

`import_donor_masks.py` copies RGB channels losslessly TGA→PNG (`:92-98`) and records start points from pure-white connected components (`:40-64`). Its manifest stores *water fraction* computed by `B>58` (`:98`) and only **8 masks per terrain type** (`:37,85-86`). A donor-faithful compiler needs the raw R relief field for every type; A03 already specifies `decode_donor_mask_new.py` (A03:276) and validation that decoded R-channel size equals the donor TGA (A03:296). **[U]** There is a live contradiction: the tool docstring says gauss variants carry water only with R/G zero except starts (`:7-9`, repeated as **[O]** in A03:92), while H03-E12/H03 state the R channel is genuine height data (`H03_heightmap_hypothesis.md:63,129`). F04 must resolve before any R-channel mapping is frozen.

### F4 — Atlas/alpha conversion is correct on identity, approximate on layout ([O]/[U])

`build_tile_index_atlas.py` gets the important part right: index *i* = `presets_summer.json[i]`, which mirrors donor `terrain.presets:2-6` (`:136-143,343-348`; F05 E12 `F05_tile_mapping.md:116`). Face presets with no PNG are filled from their base tile via `tiles.mat` (`:130-133,162-170`), and donor BMPs are header-validated before `convert("L")` (`:113-127,237-259`). What is **not** donor: the uniform 16×8 packing (`:34-35,220`), NEAREST sand upscale (`:36-37,193-200`), the exact alpha-intensity formula (`:243-259`), and the missing cell↔tile sub-rect mapping (`:26-28`). Three preset names have no shipped PNG and get transparent cells (`:38-40,172-175`). Its `shipped_ids()` cross-check is still tied to `app/shots/g32_dump.json` (`:76,268-287`) — a legacy coupling the fresh tool must drop.

### F5 — Props/meshes are faithfully converted but carry no placement data ([O]/[U])

`convert_models.py` readers are exact binary decodes (`:48-107`; N07:84-91), and `relief_models()`/`env_models()` already derive the donor relief, tree, rock, mine and field meshes under private-use terms (`:412-496,582-611`). But meshes are static bind poses (`:21-24`), OBJ vertices stay in raw donor units and per-placement `Scaling/Position/Direction` from `pattern.lib` are deliberately not applied (`:591-596`; `Z05:13`), and `.prop` bytes are not read — only material names (`:416-418`; `G09_footprint.md:43`). **[D]** The prop *geometry* route is reusable; the prop *placement* route must be rebuilt from F01/F02/F07/F08 output.

### F6 — QA/preview tools are calibrated, not donor-derived ([O]/[I])

`scan_map.py` targets are explicitly derived from `docs/audit/PIECES/map_density.md` stamp counts and a coverage band (`:57-83`) and its thresholds are port assertions (`:478-493`); the reachability check's `//2.0` coordinate conversion is tied to the port scale (`:349-353,362,412`). `gen_variant_maps.py`'s `blob` engine invents fbm fields and hand-written recipes (`:57-85,686-733`) and its `donor` engine just calls `donor_gen` (`:852-854`). A03 freezes all legacy tools as read-only cross-checks (A03:280); A05 uses `donor_gen.py:49-59,62-71` as evidence for constants (A05:71), not as runtime code. **[D]** These are useful as acceptance harnesses, never as compiler stages.

## 4. Recommended disposition — keep / extend vs retire

| Class | Tools | Decision (binding on implementers) |
|---|---|---|
| **Keep unchanged, read-only cross-checks** | `build_tile_index_atlas.py`, `pack_tile_atlas_split.py`, `export_donor_patterns.py`, `donor_gen.py`, `import_donor_masks.py` | Exactly A03:280 — never edit in this wave; run `--check` only. They are the byte-reference for occupancy, family weights, atlas layout, mask pixels and split hashes |
| **Keep as QA / visual fixtures** | `scan_map.py`, `gen_variant_maps.py`, `t6_registry.py`? **no** (see retire), `pieces/t6_*.py` (16), `piece_specs/*.json` (21), `terrain_piece_render.py`, `heightmap_splat.py` (dump reader only) | Feed the fresh dump into `scan_map.py` after re-deriving gates; keep t6 pieces/specs as per-class acceptance fixtures; reuse `heightmap_splat._as_bytes/load_dump` (`:107-176`) for ingest, replace the blend/alpha stage |
| **Port logic into new `*_new.py` tools** (copy, do not edit originals) | `import_donor_map.py` anchors/survey (`:113-174,186-209,222-304`); `donor_gen.py:74-85,97-129` prefix+cfg parse; `import_donor_masks.py:40-64,92-103` TGA+starts; `build_tile_index_atlas.py:113-127,136-178,224-265` BMP/index/face logic; `pack_tile_atlas_split.py:76-85,183-219` hash/reassembly; `convert_models.py:48-158` mesh/texture conversion | New tools: `decode_donor_pattern_new.py`, `decode_donor_cfg_new.py`, `decode_donor_mask_new.py`, `build_terrain_new_atlas.py`, `build_terrain_new_manifest.py`, `validate_terrain_new.py` (A03:274-279) |
| **Retire from the terrain compiler** | `parse_terrain.py`, `extract_map.py` (terrain role only), `build_missions.py`, `compute_ortho.py`, `t6_registry.py`, `gen_variant_maps.py` as a generator, `heightmap_splat.py` as a splat producer, `pack_tile_atlas_split.py` as a compiler stage | Retain only the explicitly labelled side uses in the table (mission inventory, unit QA, project dashboard, visual preview, legacy atlas cross-check). No new terrain asset may be produced by these paths |
| **Must be replaced outright** | `donor_gen.py` synthesis/relief/RNG/tile pass (`:25-27,62-71,191,240,357-374`); `import_donor_map.py` zero tileblock (`:450`); `export_donor_patterns.py` cell-only pattern output (`:139-147`); `gen_variant_maps.py` blob noise (`:57-85`); `heightmap_splat.py` blend/alpha (`:244-278`) | Block on F01/F02/D05 for pattern tails, D02 for RNG, D04 for full `.map`, F05/F06/D08 for tile/alpha mapping. Emit `null`+`UNVERIFIED` rather than guessing (A03:291,315) |

## 5. Implications for the fresh pipeline

1. **[D]** The compiler can be assembled from *proven fragments* today (height anchors, occupancy, cfg families, mask pixels, preset index, alpha BMPs, mesh conversion) but **cannot be donor-complete** until F01/F02/D05/D04 resolve the float-grid, object-record and tile-id tails. A03's `UNVERIFIED`-slot design (A03:291,315) is the correct container for this audit's gaps.
2. **[D]** The zero-tileblock default (`import_donor_map.py:450`) must never be fed to a "donor-faithful" module; the fresh dump needs a distinct schema (`terrain_new`, A03:43) so a legacy dump cannot be mistaken for donor data.
3. **[D]** `app/tools/**` being byte-identical for 29 of 32 named artifacts means a "reuse" patch applied to the wrong copy would either touch the forbidden 2D app or silently miss the variant3d build; `convert_models.py` is the one real drift point (Z05 §2/R12). All work must target `variant3d/tools/**` only.
4. **[D]** Runtime loading is a separate concern from decoding: P06 shows the legacy atlas path is a synchronous 180 MB PNG decode + mip build (`P06_loading_path.md:130-147,223-242`); A03:46,306 says the fresh module can reuse `TileAtlasLoader` overrides without editing it. Tool choice here does not fix loading cost — that stays UNVERIFIED without a run.
5. **[D]** No threshold may be weakened: `scan_map.py` gates (`:478-493`) and `t_render_mode`/selftest 29/29/uitest 17/17/`assert_clean` remain the acceptance frame (CHARTER.md:63-64; A03:300). Re-deriving gates from new donor evidence is a design act, not a permission to relax them.

## 6. Risks

| # | Risk | Evidence / label | Mitigation |
|---:|---|---|---|
| R1 | A tool is mistaken for a complete `.pattern` decoder and fabricated relief is emitted | `donor_gen.py:74-85` proves only the prefix; H03-E14 `:65`; A03:291 **[U]** | Emit `null` + `UNVERIFIED`; block non-null float grids on F01/D05 known-value table |
| R2 | Donor tile ids stay zero → "flat/wrong tiles" persists | `import_donor_map.py:450,462-465` **[O]** | New dump schema must carry surveyed ids; validation compares histogram to `--survey` output |
| R3 | Donor pixels/vertices leak into a committed asset | ART flags in rows 4,7,11; CREDITS private-use note (`convert_models.py:18-19`) | Only converted PNG/OBJ under `terrain_new/`; per-field provenance + sha256 (A03:298); never commit donor binaries |
| R4 | Atlas packing/alpha approximations are promoted to "donor parity" | `build_tile_index_atlas.py:34-37,220,243-259` **[O]/[U]** | Keep `APPROX_*` labels in every derived manifest; F06/D08 must resolve before any claim |
| R5 | Legacy QA gates applied to a new dump with different coordinate scale | `scan_map.py:349-353,362,412` **[O]/[D]** | New dump adapter; re-derive gates; never lower thresholds |
| R6 | `app/tools/**` accidentally edited or stale copy reused | hash comparison §1; Z05 R12; CHARTER.md:28-30 | Work only in `variant3d/tools/**`; final `assert_clean` + `app/` byte-identity gate |
| R7 | Mask R-channel contradiction freezes the wrong height rule | `import_donor_masks.py:7-9` vs `H03_heightmap_hypothesis.md:63,129` **[U]** | F04 decides; until then store raw R with ENGINE/UNVERIFIED label (A03 R7:321) |
| R8 | Tool-name collision with legacy tools | A03:274-279 names new `*_new.py`; A03:280 freezes legacy | Implement new files only; no in-place edits; COORD integrates |

## 7. UNVERIFIED register

| ID | Claim that must not be asserted yet | Evidence |
|---|---|---|
| U-1 | `.pattern` relief float grid offset/stride/endianness | `donor_gen.py:74-85` stops at occupancy; H03-E14 `H03_heightmap_hypothesis.md:65`; A03:291 |
| U-2 | `.pattern` object-record and `pattern.lib` full record layout | A03:44,288,316; `Z05:133`; `Z06:232` |
| U-3 | Donor height-grid row orientation | `import_donor_map.py:466` |
| U-4 | Semantics of tile indices beyond `tiles.lib` ordinal mirroring | `import_donor_map.py:294-295`; F05/D08 pending |
| U-5 | GameObject fields beyond category/type/instance/owner + first float triplet | `import_donor_map.py:30-31,354,372-376` |
| U-6 | Whether gauss terrainmasks carry relief in R or R/G are zero except starts | `import_donor_masks.py:7-9` vs `H03_heightmap_hypothesis.md:63,129` |
| U-7 | Whether the cited `dogenerate.inc` stamp lines execute in the shipped donor build | `A04_tile_diversity.md:193-195` |
| U-8 | Donor atlas packing (`tsDouble`/`ttExtended`) and cell↔tile sub-rect mapping | `build_tile_index_atlas.py:26-28,34-35,220` |
| U-9 | Exact `tiaAlphaFromIntensity` / `bmTransparency` formula | `build_tile_index_atlas.py:243-259`; F06 scope |
| U-10 | Per-placement `Scaling/Position/Direction` and deposit amounts for props/mines | `convert_models.py:591-596`; `Z05:13`; `Z06:232` |
| U-11 | Any donor GPU A/B frame / visual parity | CHARTER.md:41,125; `STAGE_IMPORT_01.md:174-179,205-212` |
| U-12 | Whether t6 piece metrics correspond to a rendered donor frame | piece docstrings (e.g. `t6_water.py:22-29`, `t6_plateau.py:27-30`) |

## 8. Open questions

1. **To F01/D05:** Does the float grid at `.pattern` offset 8225 use a fixed stride for all families, and where does the object list begin? (U-1, U-2)
2. **To D04:** Can `--survey`'s tile ids be emitted into the dump with donor offsets preserved, and is the row orientation resolvable from donor binary evidence? (U-3, U-4)
3. **To F04:** Which of U-6's two channel readings is correct for `*_gauss.tga` specifically? Until answered, should the new mask decoder store raw R for all types?
4. **To D02:** Which donor RNG replaces `random.Random` (`donor_gen.py:191`), and can A05's seed-replay gate assert byte-identical output across 240² and 320²? (CHARTER.md:121)
5. **To F05/F06/D08:** Which atlas/alpha rules supersede the `APPROX_*` labels in `build_tile_index_atlas.py:34-37,220,243-259`, and does the fresh module need `alphavert` at all? (U-8, U-9)
6. **To COORD:** Is the zero-tileblock dump (`import_donor_map.py:450`) still consumed by any live gate? If yes, the new tool must use a different schema name to avoid mixed semantics.
7. **To A05:** Will `scan_map.py`'s gates be re-derived for `terrain_new`, and who owns the coordinate adapter for `//2.0` (`:349-353,362,412`)?
8. **To A03 implementers:** Confirm that the five frozen legacy tools (A03:280) stay byte-identical after implementation — P04 recommends no edits to them at all.

## 9. Summary for COORD

- P04 found **one real donor decoder** (`import_donor_map.py`) whose default dump discards the donor tile ids (`:450`); no tool decodes the `.pattern` float grid or object records (`:74-85`; H03-E14 `:65`).
- **Five legacy converters are byte-reference material only** (A03:280): masks, patterns, atlas, split, donor_gen — copy their algorithms into new `*_new.py` tools, never edit them in place.
- **Props/meshes** (`convert_models.py`) are faithful static conversions but carry no donor placement transforms (`:591-596`; Z05:13); **t6 pieces/specs and `gen_variant_maps.py`** are labelled PORT APPROXIMATION visual fixtures, not compiler stages.
- Retire from the terrain path: `parse_terrain.py`, `extract_map.py` (terrain role), `build_missions.py`, `compute_ortho.py`, `t6_registry.py`, blob engine and legacy splat producer; keep their labelled side uses only.
- **`app/tools/**` stays byte-untouched** (29/32 artifacts identical, `convert_models.py` drifted); all work targets `variant3d/tools/**`, all gaps stay `UNVERIFIED` until F/D-wave proofs and a real donor GPU A/B frame — no parity claim.

*End of P04 report.*
