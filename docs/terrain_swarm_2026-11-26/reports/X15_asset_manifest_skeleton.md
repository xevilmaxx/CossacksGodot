---
id: X15
ticket: "TERRAIN-SWARM-2026-11-26 / X15 — provenance manifest skeleton + SHA-256 census for I05"
owner: X15 (donor-first terrain swarm, read-only worker)
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_WRITE__NO_GODOT_JOB__NO_GIT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Read first: docs/terrain_swarm_2026-11-26/{CHARTER,SWARM_BOARD}.md, docs/terrain_swarm_2026-11-26/spec/11_ASSET_CONVERSION.md, reports/{P02_asset_inventory,A03_asset_pipeline}.md. Then read-only on-disk SHA-256 census of legacy converted terrain assets that a fresh I05 module will reuse."
outputs: "Exactly one repo file: docs/terrain_swarm_2026-11-26/reports/X15_asset_manifest_skeleton.md. Scratch JSON/probes are confined to C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/asset_manifest/ (outside the repo; never committed)."
parity_guard: "No donor GPU A/B frame was produced, no donor binary was executed and no donor file was written. 'Donor-derived' denotes inherited file/byte provenance only, never a rendered-look claim. All conversion behaviour is PORT APPROXIMATION and every emitted manifest carries visual_parity_claim:false."
---

# X15 — provenance manifest skeleton + SHA-256 census (for I05)

## 0. Executive summary

1. **[D]** I05 must emit `variant3d/assets/terrain_new/manifest.json` with schema `terrain_new/manifest/v1`: root keys `schema, version, pack, pack_id, generator, generator_version, tool_versions, labels, labels_used, donor_root_policy, inputs_never_committed, atlas_manifest_v7_85_keys, entries, asset_index, counts, census_reference, commit_policy, validation, visual_parity_claim`. The **entry tuple is exactly** `source:offset → output → source_sha256 → output_sha256 → label → decoder → visual_parity_claim:false`, sorted by `(source, offset, output)`; `version`/`labels` are added here from the V7-85 key set, all other keys are inherited from A03 §2.2.5 (`docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md:210-238`).
2. **[O]** The concrete atlas sub-manifest under `terrain_new/atlas/` must reuse the V7-85 top-level keys verbatim — `version, generator, labels, atlas, index_dictionary, layout, unused_shipped_blocks, unused_note, masks, shipped_tileblock, visual_parity_claim` — and the `atlas{}` sub-keys `file, size, cell_size, grid, slots, named_cells, filled_cells, empty_cells, upscaled_sources, packing_label`, plus the A03 §2.2.1 additive `resolution_tier` (observed in `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:1-46,3049-3165` and `docs/coord_swarm_2026-11-24/reports/V785_tile_atlas.md:48-57`).
3. **[O] Three-pass SHA-256 census: 214 files / 713,843,557 bytes**, zero mismatches between an independent Python `hashlib` pass and a PowerShell `Get-FileHash -Algorithm SHA256` pass. Groups: 112 block PNGs (174,122,611 B), 4 atlas PNGs (304,599,443 B), 4 atlas JSON (240,947 B), 5 split-atlas files (180,139,198 B), 3 provenance tables (1,067,145 B), 56 mask PNGs (838,488 B), 12 relief files (32,542,912 B), 6 mine files (16,181,736 B), 8 wave sheets (2,743,445 B), 4 field cut-outs (1,367,632 B).
4. **[D]** Deterministic pack id: `terrain_new_v1-` + first 16 hex digits of `sha256(canonical_json(seed))` where the seed is the sorted entry tuple + tool versions + counts + `visual_parity_claim:false`; no timestamps, no mtimes, no absolute donor root, `/` separators only. Same donor bytes + same tool versions + same `--pack` ⇒ byte-identical outputs (A03 §2.0.4).
5. **[O/D] Commit guard:** the 179,912,941 B summer atlas, the 124,463,306 B winter atlas (both > GitHub's 100 MB file limit) and the two split parts (90,000,000 + 89,912,941 B, a lossless byte split of the same summer art) must stay uncommitted/LFS. Safe to commit: compact `--cell 128` atlas, its V7-85 manifest, alpha/alphavert, all derived JSON, height tiles, tool source and validation logs (`A03 §2.4`, `variant3d/assets/terrain/atlas_parts/split_manifest.json:12-19,64-77`).
6. **[O]** A read-only hash of `C:\Games\Cossacks 3\data\pattern\pattern.lib` (30,309,138 B) equals `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0`, the `source_sha256` recorded in `variant3d/assets/terrain/mountain_props.json:4`. This is the one donor byte anchor independently re-verified this pass; all other donor facts remain second-hand.
7. **[U]** The `.pattern` relief float grid and object-list tail, full `pattern.lib` record map, `data/gen/*.cfg` semantics, mask→height mapping, alpha intensity formula, donor atlas packing, desert season scope and all visual fidelity are UNVERIFIED. I05 must emit `null` + `label:"UNVERIFIED"` for those slots, never a guessed constant. **No donor parity claim anywhere in this report or the emitted manifest.**

## 1. Method and evidence table

Label key: **[O]** literal file:line / on-disk count / hash computed this pass; **[D]** deterministic consequence of observed data; **[I]** reasonable reading without an engine run; **[U]** cannot be proven without donor-byte proof or a Godot/GPU run; **PORT APPROXIMATION** = explicit port substitute.

| # | Evidence (path:line / artifact) | Fact | Label |
|---|---|---|---|
| E1 | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-44,64-69,82,84,94` | Donor read-only; labels mandatory; no parity without A/B; multiple passes on contradictions; analysis workers submit no Godot job | [O] |
| E2 | `docs/terrain_swarm_2026-11-26/spec/11_ASSET_CONVERSION.md:8-18,40-59,61-73` | One-way compiler, disjoint `terrain_new/**`, 14 checks, 179,912,941 B atlas + split parts uncommitted/LFS | [O] |
| E3 | `docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md:74-80,100-137,139-141,210-238,258-268,284-301` | Root manifest schema, output layout, atlas sizing, licence guard, 14 byte-compares | [O] |
| E4 | `docs/terrain_swarm_2026-11-26/reports/P02_asset_inventory.md:43-61,65-98,141-160` | Family counts/bytes, pixel-vs-byte duplicates, 121/121 atlas cells, 27 unused winter blocks, dormant decals | [O inherited] |
| E5 | `docs/coord_swarm_2026-11-24/reports/V785_tile_atlas.md:48-57` and `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:1-46,3049-3165` | V7-85 exact key set and four output hashes | [O] |
| E6 | `variant3d/assets/terrain/atlas_parts/split_manifest.json:12-19,22-37,46-63,64-77,83` | Split sources/parts/mask hashes, `matches:true`, zip ratio 0.998, no parity claim | [O] |
| E7 | `variant3d/assets/terrain/masks/manifest.json:1-5` | 7 mask types; R=relief, G=forest/stone, B=water, white=start | [O] |
| E8 | `%TEMP%/opencode/asset_manifest/{census_pass1.json,verify_pass2.json,pass3_reconcile.json,census_tables.md}` | 3-pass census, 214/214 hash agreement, embedded-hash cross-checks, sidecar byte accounting | [O] |
| E9 | `variant3d/assets/terrain/mountain_props.json:1-17` + read-only `data\pattern\pattern.lib` hash | `source_sha256` anchor verified this pass; object-list selection is PORT APPROX | [O]/[D] |
| E10 | `variant3d/assets/terrain/atlas/winter_aliases.json` (`entries`=124), `desert_remap.json` (`remap`=38, `unverified`=6) | Season data exists; desert scope still carries internal UNVERIFIED list | [O]/[U] |
| E11 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:27-30` + `layout[].kind` tally (85 DIRECT + 36 FACE_BASE_REUSE + 3 EMPTY, `alpha0a/b/c`) | 128 slots = 124 named + 4 unnamed; 124 named = 121 filled + 3 EMPTY | [O] |
| E12 | `variant3d/assets/terrain/blocks/*.png` (112) and `variant3d/assets/terrain/masks/**/*.png` (56) enumerations | Exact stem prefixes and 7×8 type structure; two 256² sand blocks | [O] |

## 2. Exact schema for `terrain_new/manifest.json`

### 2.1 Root manifest key order and types [D]

| Key | Type | Source of the key | Rule |
|---|---|---|---|
| `schema` | string literal `terrain_new/manifest/v1` | A03 §2.2.5 | validated by `terrain_new_assets.gd` before any load |
| `version` | int `1` | V7-85 atlas manifest | bumps with schema file; frozen in `schemas/v1.schema.json` |
| `pack` | string `terrain_new_v1` | A03 §2.2.5 | bumps on schema field or decoder change |
| `pack_id` | string `terrain_new_v1-<16hex>` | X15 deterministic rule (§2.3) | recomputed by `--check`; mismatch aborts |
| `generator` / `generator_version` | string | V7-85 / A03 | `variant3d/tools/build_terrain_new_manifest.py`, `1.0.0` |
| `tool_versions` | map tool→semver | A03 §2.2.5 | every decoder named; part of pack-id seed |
| `labels` / `labels_used` | string arrays | V7-85 `labels` + A03 `labels_used` | `[O] [D] [I] [U] PORT APPROXIMATION NO_VISUAL_PARITY_CLAIM` |
| `donor_root_policy`, `inputs_never_committed` | string / array | A03 §2.2.5 | no absolute private path in committed bytes |
| `atlas_manifest_v7_85_keys` | object | V7-85 manifest | contract for `atlas/tile_index_atlas.manifest.json` |
| `entries` | ordered array | A03 §2.2.5 | tuple in §2.2; sorted by `(source, offset, output)` |
| `asset_index`, `counts` | objects | A03 §2.2.5 | `counts` extended with reused legacy counts (112/56) |
| `census_reference` | object | X15 | points at the out-of-repo census, never at a committed file |
| `commit_policy`, `validation` | objects | A03 §2.4/§2.6 | guard + 16 assertions |
| `visual_parity_claim` | **boolean `false`** | A03 §2.0.5, V7-85 | mandatory in every emitted JSON |

### 2.2 Entry tuple (the `source:offset → output → sha256 → label` chain) [D]

`source` (donor-relative path, never an absolute install path) · `offset` (byte range `0xNN..0xMM`, or `path:line` until F02 publishes record boundaries) · `output` (`res://`-relative path, optional `#field` suffix meaning *hash of the containing file*) · `source_sha256` (raw donor bytes actually consumed; `null` if none) · `output_sha256` (sha256 over emitted file bytes, 1 MiB streaming chunks per `pack_tile_atlas_split.py:76-85`) · `label` (`[O]`, `[D]`, `[I]`, `[U]`, `PORT APPROXIMATION`) · `decoder` (name + version) · `visual_parity_claim:false`. A `null` output/output_sha256 is legal **only** with a label containing `UNVERIFIED`.

### 2.3 Deterministic pack id [D]

```
canonical_json(o) = json.dumps(o, sort_keys=True, separators=(",", ":"),
                               ensure_ascii=False) + "\n"      # UTF-8
seed   = {schema, version, pack, generator, generator_version, tool_versions,
          entries: sorted(entries, key=(source, offset, output)),
          counts, visual_parity_claim: false}
pack_id = pack + "-" + sha256(canonical_json(seed)).hexdigest()[:16]
```
Excluded from the seed by construction: wall-clock times, file mtimes, `\` vs `/`, `$COSSACKS3_DIR` value, `--out` destination, Python dict insertion order, hash-map iteration order, RNG state. `--check` recomputes the id from the committed manifest and refuses to emit if it differs. Two clean runs with identical donor bytes + tool versions must compare **byte-for-byte** (not merely semantically equal).

### 2.4 V7-85 atlas manifest key contract [O]

Top level: `version, generator, labels, atlas, index_dictionary, layout, unused_shipped_blocks, unused_note, masks, shipped_tileblock, visual_parity_claim`. `atlas{}`: `file, size, cell_size, grid, slots, named_cells, filled_cells, empty_cells, upscaled_sources, packing_label`. `layout[i]`: `index, name, cell_xy, cell_px, source_png, kind, donor_evidence, status, upscaled, source_size, source_sha256`. Additive (A03 §2.2.1): `resolution_tier: "commit_default" | "local_hires"`. Observed values that must be preserved, not recomputed: `grid=[16,8]`, `slots=128`, `named_cells=124`, `filled_cells=121`, `empty_cells=3`, `cell_size=[1024,1024]` for the legacy source; the commit tier changes only `size` and `cell_size` (`[2048,1024]` / `[128,128]`).

### 2.5 Manifest skeleton (scratch copy: `%TEMP%/opencode/asset_manifest/manifest_skeleton.json`)

```json
```json
{
  "schema": "terrain_new/manifest/v1",
  "version": 1,
  "pack": "terrain_new_v1",
  "pack_id": "terrain_new_v1-<16 lowercase hex digits; see pack_id_algorithm>",
  "pack_id_algorithm": "sha256( canonical_json(seed) )[:16]; seed = {schema, version, pack, generator, generator_version, tool_versions, entries:[{source,offset,output,source_sha256,output_sha256,label} sorted by (source, offset, output)], counts, visual_parity_claim:false}; canonical_json = json.dumps(seed, sort_keys=true, separators=(',',':'), ensure_ascii=false) + '\\n', UTF-8; no absolute donor root, no timestamps, no mtimes, path separators normalised to '/'.",
  "generator": "variant3d/tools/build_terrain_new_manifest.py",
  "generator_version": "1.0.0",
  "tool_versions": {
    "decode_donor_pattern_new.py": "1.0.0",
    "decode_donor_cfg_new.py": "1.0.0",
    "decode_donor_mask_new.py": "1.0.0",
    "build_terrain_new_atlas.py": "1.0.0",
    "build_terrain_new_manifest.py": "1.0.0",
    "validate_terrain_new.py": "1.0.0"
  },
  "labels": ["[O]", "[D]", "[I]", "[U]", "PORT APPROXIMATION", "NO_VISUAL_PARITY_CLAIM"],
  "labels_used": ["DONOR_OCCUPANCY", "DONOR_OBJECT_LIST", "DONOR_CHANNEL", "DONOR_INDEX", "DONOR_ART", "UNVERIFIED", "UNVERIFIED_EMPTY_CELLS", "APPROX_ATLAS_PACKING", "APPROX_ATLAS_DOWNSAMPLE", "APPROX_SAND_UPSCALE", "APPROX_ALPHA_INTENSITY_FORMULA", "PORT APPROXIMATION"],
  "donor_root_policy": "$COSSACKS3_DIR (value NOT recorded as an absolute path in committed output)",
  "inputs_never_committed": [
    "data/pattern/pattern.lib",
    "data/pattern/*.pattern",
    "data/gen/terrainmasks/**/*.tga",
    "data/terrain/ref/*.bmp",
    "data/terrain/tiles/textures/*.dds",
    "data/game/var/generator.cfg",
    "data/gen/*.cfg"
  ],
  "atlas_manifest_v7_85_keys": {
    "top_level": ["version", "generator", "labels", "atlas", "index_dictionary", "layout", "unused_shipped_blocks", "unused_note", "masks", "shipped_tileblock", "visual_parity_claim"],
    "atlas_keys": ["file", "size", "cell_size", "grid", "slots", "named_cells", "filled_cells", "empty_cells", "upscaled_sources", "packing_label"],
    "layout_entry_keys": ["index", "name", "cell_xy", "cell_px", "source_png", "kind", "donor_evidence", "status", "upscaled", "source_size", "source_sha256"],
    "additive_key": "resolution_tier: commit_default | local_hires (A03 §2.2.1)"
  },
  "entries": [
    {
      "source": "data/pattern/pattern.lib",
      "offset": "<F02 record line/byte range; line until F02 publishes>",
      "output": "patterns/families/<family>.json#patterns.<name>.objects",
      "source_sha256": "f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0",
      "output_sha256": "<sha256 of emitted file bytes>",
      "label": "[O] DONOR_OBJECT_LIST (terrainmeshN Scaling/Position/Direction)",
      "decoder": "decode_donor_pattern_new.py v1.0.0",
      "visual_parity_claim": false
    },
    {
      "source": "data/pattern/hil1.pattern",
      "offset": "0x00..0x07",
      "output": "patterns/families/hills_dark.json#patterns.hil1.w_h",
      "source_sha256": "<sha256 of the 8 donor bytes>",
      "output_sha256": "<sha256 of emitted file bytes>",
      "label": "[O] DONOR_OCCUPANCY_PREFIX",
      "decoder": "decode_donor_pattern_new.py v1.0.0",
      "visual_parity_claim": false
    },
    {
      "source": "data/pattern/hil1.pattern",
      "offset": "0x08..<8+w*h>",
      "output": "patterns/families/hills_dark.json#patterns.hil1.occupancy_cells",
      "source_sha256": "<sha256 of donor occupancy bytes>",
      "output_sha256": "<sha256 of emitted file bytes>",
      "label": "[O] DONOR_OCCUPANCY",
      "decoder": "decode_donor_pattern_new.py v1.0.0",
      "visual_parity_claim": false
    },
    {
      "source": "data/pattern/hil1.pattern",
      "offset": "<tail: UNVERIFIED until F01/D05>",
      "output": "patterns/families/hills_dark.json#patterns.hil1.relief_float_grid",
      "source_sha256": null,
      "output_sha256": null,
      "label": "[U] UNVERIFIED — null field, no guessed layout",
      "decoder": "decode_donor_pattern_new.py v1.0.0",
      "visual_parity_claim": false
    },
    {
      "source": "data/game/var/generator.cfg",
      "offset": "<path:line of Name=/Pattern=/Freq=>",
      "output": "patterns/family_index.json#families.<name>",
      "source_sha256": "<sha256 of donor cfg bytes>",
      "output_sha256": "<sha256 of emitted file bytes>",
      "label": "[O] DONOR_CFG_FREQ (first definition wins)",
      "decoder": "decode_donor_cfg_new.py v1.0.0",
      "visual_parity_claim": false
    },
    {
      "source": "data/gen/terrainmasks/land/4pl_mask_land_0_gauss.tga",
      "offset": "<R-channel byte range per decoded TGA header>",
      "output": "masks/height/land/4pl_mask_land_0_gauss.height.png",
      "source_sha256": "<sha256 of donor TGA bytes>",
      "output_sha256": "<sha256 of emitted PNG bytes>",
      "label": "[O] DONOR_CHANNEL R; [U] height mapping ENGINE (D03/D05)",
      "decoder": "decode_donor_mask_new.py v1.0.0",
      "visual_parity_claim": false
    },
    {
      "source": "data/terrain/ref/reftilealpha.mat:30-37",
      "offset": "alpha.bmp bind (intensity formula ENGINE/UNVERIFIED)",
      "output": "atlas/alpha.png",
      "source_sha256": "a5b9dda1dd5aaf87e485b6343880d026b87f798e2b19ec7d316285d3ff42a9f8",
      "output_sha256": "<sha256 of emitted PNG bytes>",
      "label": "[O] DONOR_ALPHA_INTENSITY; [U] exact formula",
      "decoder": "build_terrain_new_atlas.py v1.0.0",
      "visual_parity_claim": false
    }
  ],
  "asset_index": {
    "atlas": "atlas/tile_index_atlas.png",
    "atlas_manifest": "atlas/tile_index_atlas.manifest.json",
    "alpha": "atlas/alpha.png",
    "alphavert": "atlas/alphavert.png",
    "season_aliases": "atlas/seasons/winter_aliases.json",
    "pattern_families": "patterns/family_index.json",
    "height_tiles": "masks/mask_index.json",
    "cfg": "cfg/constants.json"
  },
  "counts": {
    "named_cells": 124,
    "season_variants": 2,
    "families": 41,
    "height_tiles": 0,
    "legacy_block_pngs_reused": 112,
    "legacy_mask_pngs_reused": 56
  },
  "census_reference": {
    "author": "X15",
    "date": "2026-11-26",
    "location": "%TEMP%/opencode/asset_manifest/census_pass1.json (outside repo, not committed)",
    "file_count": 214,
    "total_bytes": 713843557,
    "instrument_passes": 3,
    "mismatches": 0
  },
  "commit_policy": {
    "safe_to_commit": ["compact --cell 128 atlas + V7-85 manifest", "atlas/alpha.png", "atlas/alphavert.png", "patterns/**/*.json", "masks/height/**/*.height.png", "cfg/*.json", "schemas/v1.schema.json", "manifest.json", "tool source", "validation logs"],
    "never_commit": ["179,912,941 B summer atlas", "124,463,306 B winter atlas", "atlas_parts/tile_index_atlas.part000/.part001", "any donor .lib/.pattern/.tga/.bmp/.dds/.exe/.cfg verbatim", "any file whose bytes equal an inputs_never_committed source"]
  },
  "validation": {
    "checks": [
      "pattern.lib source_sha256 == f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0",
      "occupancy round-trip == donor_patterns.json patterns[name].cells",
      "family weights == donor_patterns.json families",
      "relief_float_grid is null unless F01/D05 byte proof exists",
      "atlas geometry: grid [16,8], slots 128, named 124, filled 121, empty 3",
      "index dictionary == presets_summer.json:2-125",
      "alpha.png 512x256 L; alphavert.png 1024x512 L",
      "winter aliases 124 entries; carrier indices 86/110/123 EMPTY",
      "provenance closure: every entry has source+offset+output+output_sha256+label",
      "recomputed sha256 of every emitted file == manifest value",
      "no source resolves to a committed file",
      "every null field labelled UNVERIFIED; visual_parity_claim false everywhere",
      "pack_id recomputed from canonical seed equals committed pack_id",
      "--dry-run writes zero bytes; two runs -> byte-identical outputs",
      "gates unchanged (COORD): selftest 29/29, uitest 17/17, t_render_mode, assert_clean CLEAN, app/ byte-identical",
      "parity remains UNVERIFIED: no donor GPU A/B frame"
    ],
    "parity": false
  },
  "visual_parity_claim": false
}
```
```

## 3. SHA-256 census of reusable converted assets

**Method / passes.** Pass 1: Python 3.14 `glob` enumeration + streaming `hashlib.sha256` (1 MiB chunks) over raw file bytes, output `%TEMP%/opencode/asset_manifest/census_pass1.json`. Pass 2: independent PowerShell `Get-FileHash -Algorithm SHA256` + `Get-Item.Length`, re-checking **all 214 files — 0 mismatches** (`verify_pass2.json`). Pass 3: cross-check against hashes embedded in V7-85/split manifests, extension-level sidecar accounting, donor `pattern.lib` anchor and stem structure (`pass3_reconcile.json`). No repo asset was modified; no Godot job was submitted.

### 3.1 Group totals [O]

| Group | Files | Bytes | Commit class |
|---|---:|---:|---|
| A — 112 block PNGs (`terrain/blocks/*.png`) | 112 | 174,122,611 | safe (derived input) |
| B — atlas PNGs (summer, winter, alpha, alphavert) | 4 | 304,599,443 | summer/winter **never**; alpha/alphavert safe |
| C — atlas JSON manifests + alias tables | 4 | 240,947 | safe (labels) |
| D — split atlas parts + mask copies + split manifest | 5 | 180,139,198 | **never** (parts are the same donor art) |
| E — `mountain_props.json`, `donor_patterns.json`, `masks/manifest.json` | 3 | 1,067,145 | safe with inherited labels |
| F — mask PNGs (7 types × 8) | 56 | 838,488 | safe |
| G — `terrainmesh1..4` OBJ + MTL + albedo | 12 | 32,542,912 | safe |
| H — `mine_gold/iron/coal` OBJ + albedo | 6 | 16,181,736 | safe |
| I — `water_png/diffusewaves0..7.png` | 8 | 2,743,445 | safe |
| J — field cut-outs (`field.obj/.png`, `envfieldd/w.png`) | 4 | 1,367,632 | safe |
| **TOTAL** | **214** | **713,843,557** | — |

**[D] Overlap note.** The 5 split files include `alpha.png`+`alphavert.png` byte-identical copies of group B (223,196 B) and `.part000`+`.part001` are a lossless split of the summer atlas (179,912,941 B). Physical-file total 713,843,557 B; excluding the duplicated mask copies = 713,620,361 B; excluding both the mask copies and the split parts = 533,707,420 B of distinct art. Do not sum all three transports into a planned repo size.

**[O] Structure.** 112 blocks = `grass`10 + `desert`12 + `winter`27 + `test`26 + `sand`9 + `sandrock`6 + `sandsea`6 + `rock`9 + `grass_ground`3 + `grass_sand`2 + `grass_rock`1 + `ground`1; 110 are 1024² RGB and `sand1`/`sand2` are 256² RGB (`APPROX_SAND_UPSCALE` in the atlas). 56 masks = 7 types (`continent, continents, islands, land, mediterranean, nowater2, peninsulas`) × 8. 124 atlas named cells = 121 filled + 3 EMPTY (`alpha0a/b/c`); 4 slots beyond the 124 names are unnamed.

### 3.2 Exhaustive per-file census (214 rows)

### E_tables — 3 files / 1,067,145 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 1 | `variant3d/assets/terrain/mountain_props.json` | 66,519 | `d21237f43d2fd95ddd8fcd7a3ad14290c789df1f1f3881df8f35676053a0e500` |
| 2 | `variant3d/assets/terrain/patterns/donor_patterns.json` | 982,264 | `c9a6a08952b765d758be796c87a8b8eac48caca91c33a2b251fff25a07f122ba` |
| 3 | `variant3d/assets/terrain/masks/manifest.json` | 18,362 | `ce72a858cc72474c793b4c22afe0ccfea746eb400843720d78b980d5f3b1e7e4` |

### C_atlas_json — 4 files / 240,947 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 4 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | 60,677 | `112e9ff5ed632dd36bb526a7b7fe2b19083d251745cf0c2705f551f7f3583bda` |
| 5 | `variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json` | 79,837 | `ef4ab26e35650c20d57517974fbb4715ffae5252a0175c2218151195f95afba0` |
| 6 | `variant3d/assets/terrain/atlas/winter_aliases.json` | 81,335 | `ece3d51b01fe3a2b2988e3561979ecdbc6c901cf66621df96ff43058752b6b1d` |
| 7 | `variant3d/assets/terrain/atlas/desert_remap.json` | 19,098 | `e33135c09e4e327f69939f9c99ddc1051b035fae066e54da728bb0ac574cfb1f` |

### B_atlas_png — 4 files / 304,599,443 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 8 | `variant3d/assets/terrain/atlas/tile_index_atlas.png` | 179,912,941 | `a1f123a1072e07eb28f416a9d8541aae5ffd23891a1836904b3cb05eb84dcfbd` |
| 9 | `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` | 124,463,306 | `5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` |
| 10 | `variant3d/assets/terrain/atlas/alpha.png` | 55,242 | `dfaf78d0c285920cd2009f74476a8d4647f3666efb7c6dcf0bfd1b44487b8ef7` |
| 11 | `variant3d/assets/terrain/atlas/alphavert.png` | 167,954 | `c916ea98ddb7f8ccc9a4898f324540335d4d74ee5250f4774b9769c762afd245` |

### D_split — 5 files / 180,139,198 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 12 | `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000` | 90,000,000 | `019f0f9d7ea1430131189881db58e3f3fa138eb76209d643d53e698b73dd525f` |
| 13 | `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part001` | 89,912,941 | `295a527ce8c402d8c8c80775538a6a0c0e6859fa94a758194cc096db0faba1be` |
| 14 | `variant3d/assets/terrain/atlas_parts/alpha.png` | 55,242 | `dfaf78d0c285920cd2009f74476a8d4647f3666efb7c6dcf0bfd1b44487b8ef7` |
| 15 | `variant3d/assets/terrain/atlas_parts/alphavert.png` | 167,954 | `c916ea98ddb7f8ccc9a4898f324540335d4d74ee5250f4774b9769c762afd245` |
| 16 | `variant3d/assets/terrain/atlas_parts/split_manifest.json` | 3,061 | `7453b52cc6038373376ee9ca7513333bc334903283706b1de2618945a1c21c03` |

### F_masks — 56 files / 838,488 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 17 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_0_gauss.png` | 12,267 | `420fea69e7f4d56fe0768cb22ba29f6d98665195a87ff6eb2e8359bac45792b3` |
| 18 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_23_gauss.png` | 12,872 | `818fc50a85d08b9cefbb388489d2df0fe299c0dd0f4fc747d8b3c12b57d2f929` |
| 19 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_37_gauss.png` | 9,819 | `a560ce8bf62954de56a5be44a439b97c23b1985c496702d34af6239d7c158051` |
| 20 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_50_gauss.png` | 11,122 | `09d591a6c37c48c2c7783102a68ff73befa25a55b3a43fa18a7622100d8e6aa8` |
| 21 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_64_gauss.png` | 10,620 | `fdf26a9a5028a96945e7f6370591762b263fa395b9c307c69d5713b80baf7ad0` |
| 22 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_78_gauss.png` | 11,614 | `846d8612700776d2247a01fcefc9be563c980895f0b47445926a18b69627e413` |
| 23 | `variant3d/assets/terrain/masks/continent/4pl_mask_continent_91_gauss.png` | 10,261 | `8c7a66465302d6aa5f6fd8295d4cbd1052a66a9114e7b1cf30393a908796e4eb` |
| 24 | `variant3d/assets/terrain/masks/continent/7pl_mask_continent_14_gauss.png` | 23,485 | `b9a519c0080843b9216517bb3014f99cdca75567a978fc5ac20040d304f67e28` |
| 25 | `variant3d/assets/terrain/masks/continents/2pl_mask_continents_0_gauss.png` | 21,673 | `ef851b57ed18b22058036a4c829b0833a4ba69d978f888855108f2b5d30c076c` |
| 26 | `variant3d/assets/terrain/masks/continents/2pl_mask_continents_30_gauss.png` | 27,541 | `88480ecadee41db5165537302cac839810bfa65adf548f685efb880b49d3f3fb` |
| 27 | `variant3d/assets/terrain/masks/continents/3pl_mask_continents_15_gauss.png` | 29,411 | `30c77501a16a17b43f027405e8be036a94e2384f418f4c5291d0abc54599ab93` |
| 28 | `variant3d/assets/terrain/masks/continents/4pl_mask_continents_0_gauss.png` | 25,603 | `7453004bcde3ec26209936ee6adf52bfcef03921ea9870aaa8f0712bc045568c` |
| 29 | `variant3d/assets/terrain/masks/continents/4pl_mask_continents_30_gauss.png` | 28,812 | `6c7d48b8178bed6a26ed4eeb3647252aa87740d6adb3ce5276658740d77899a0` |
| 30 | `variant3d/assets/terrain/masks/continents/4pl_mask_continents_51_gauss.png` | 21,515 | `293e690b54f624c34c835e2057c535b8ffb74cacb0090f50cd6388395168a988` |
| 31 | `variant3d/assets/terrain/masks/continents/4pl_mask_continents_72_gauss.png` | 27,681 | `9ed3643c1ce1b8112500d5176579e05276f8267c1a8919a7a20328b28a127609` |
| 32 | `variant3d/assets/terrain/masks/continents/4pl_mask_continents_93_gauss.png` | 28,522 | `54d20eed75fa34c68fdd4d367f47df279c078f1f3534d7d6c9cfdea73e9400b7` |
| 33 | `variant3d/assets/terrain/masks/islands/2pl_mask_islands_0_gauss.png` | 29,197 | `c444c8b63bf84747b81d42dd92d0773ab86f5924fb20e7141074df8d4f73f620` |
| 34 | `variant3d/assets/terrain/masks/islands/2pl_mask_islands_46_gauss.png` | 30,735 | `a4830ab5fa6109fc4e4e75b9dfae20fd0940193e8112c8e3d926d6a4318c5c5e` |
| 35 | `variant3d/assets/terrain/masks/islands/2pl_mask_islands_82_gauss.png` | 34,994 | `ed0183010ee3e067e0435133f58b2237db5a4843161e611e8da6a0de03ea9794` |
| 36 | `variant3d/assets/terrain/masks/islands/3pl_mask_islands_28_gauss.png` | 30,725 | `28c2302d98a1fc6729863bd2957e7f51b0c12f881d9f0cd98f7258e8992f0abd` |
| 37 | `variant3d/assets/terrain/masks/islands/3pl_mask_islands_64_gauss.png` | 22,190 | `005bb27efb1c94119b8d8170156be8239bcf134a1a4f9ded330664a7fae9525e` |
| 38 | `variant3d/assets/terrain/masks/islands/4pl_mask_islands_10_gauss.png` | 19,205 | `39641cac588ee5354ca1a49700ec5f15389d9e4efcd1dc14adab88cbd5a1a10f` |
| 39 | `variant3d/assets/terrain/masks/islands/4pl_mask_islands_47_gauss.png` | 16,986 | `e0892bbcc1bd6a973fa7df4b32edf8c70e62612acf245008ea2d35a5c70002a3` |
| 40 | `variant3d/assets/terrain/masks/islands/4pl_mask_islands_83_gauss.png` | 16,707 | `e2173e79464c572b2ef608874a45f14fb92ed5db13eef7d31dad19d31dd7b16e` |
| 41 | `variant3d/assets/terrain/masks/land/4pl_mask_land_0_gauss.png` | 2,762 | `3c3174d98b1798ac114f64cc96e71c9bacf9c5a0236d35901cd94bb41f3e4439` |
| 42 | `variant3d/assets/terrain/masks/land/4pl_mask_land_125_gauss.png` | 8,620 | `fb71a7aad5b5c1510ad9c5eeac4ae50a8bdaa3c217b8da2c0af4c0e6acaff97e` |
| 43 | `variant3d/assets/terrain/masks/land/4pl_mask_land_150_gauss.png` | 393 | `9a7c5566af3520de0b9185810b374ebbb41cfb883764ca0b52723714ee6ed33e` |
| 44 | `variant3d/assets/terrain/masks/land/4pl_mask_land_176_gauss.png` | 393 | `9a7c5566af3520de0b9185810b374ebbb41cfb883764ca0b52723714ee6ed33e` |
| 45 | `variant3d/assets/terrain/masks/land/4pl_mask_land_200_gauss.png` | 393 | `9a7c5566af3520de0b9185810b374ebbb41cfb883764ca0b52723714ee6ed33e` |
| 46 | `variant3d/assets/terrain/masks/land/4pl_mask_land_38_gauss.png` | 9,580 | `2bb0e22b78e988f4f764532e1825044c9cd92518aca455c13c46fa0d63c9511f` |
| 47 | `variant3d/assets/terrain/masks/land/4pl_mask_land_63_gauss.png` | 9,467 | `3ecd17829410649dcd0dc9329ee9172aea1c2df51e4e4ea78d1f1fc667dd8538` |
| 48 | `variant3d/assets/terrain/masks/land/4pl_mask_land_89_gauss.png` | 12,457 | `a72ecaf31c2acd53ea2ec0b58118bc89257859e109987314607efd1fc8d44e6a` |
| 49 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_0_gauss.png` | 12,787 | `0a291b52fdb5b22fdeaf7b0351991f8013b5803e5a743636c14585ff432adf3a` |
| 50 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_22_gauss.png` | 12,474 | `5f73c0fef9e7f7e3902055946570f9443f378a24004695f3a2980aab0c89e2b6` |
| 51 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_35_gauss.png` | 12,882 | `e87690523424bb77f21a5a0abad9a8db835b9cfb27932764fa204dfe5bc0ef73` |
| 52 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_48_gauss.png` | 8,240 | `6f772d55ebf5469c3cf69881200d40c8b529d453ace166bae0782578eb61f2af` |
| 53 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_60_gauss.png` | 23,707 | `700fc22a6892bfbf327042126a03fb283cb1347ee701b292747c63d88639c276` |
| 54 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_73_gauss.png` | 21,944 | `ed70e75f47be2c2c756710ca8c46f82f274dacdb5a48e6808f039fdc6d250dae` |
| 55 | `variant3d/assets/terrain/masks/mediterranean/4pl_mask_mediterranean_88_gauss.png` | 10,339 | `23b81c6d7537a1f6c45eb0717ae7525ac03dc422b79b650de1cec6a4c67e53b9` |
| 56 | `variant3d/assets/terrain/masks/mediterranean/7pl_mask_mediterranean_10_gauss.png` | 8,231 | `f028283f08396909032310ff6caa685ff0a62e30a1b24dbf42d2e227507488c8` |
| 57 | `variant3d/assets/terrain/masks/nowater2/4pl_mask_nowater_170_gauss.png` | 390 | `362c8521fb806e0cb658f1bf0ef19f14511f6bf1c979def4a30272bb99d9590b` |
| 58 | `variant3d/assets/terrain/masks/nowater2/4pl_mask_nowater_174_gauss.png` | 394 | `0c4dd7778051a8ae61aa2dfcf185aeb58559d25cd9eaf7462a34cd7066f75256` |
| 59 | `variant3d/assets/terrain/masks/nowater2/4pl_mask_nowater_178_gauss.png` | 393 | `9657fc9d17e527dd164eda615ddd7d454422c974a0d60cf4b42d2df78788cda2` |
| 60 | `variant3d/assets/terrain/masks/nowater2/5pl_mask_nowater_0_gauss.png` | 398 | `b83b101ada5be60feadeeb79bc4460cc532f97fe4544e2d2249411c08c6eafca` |
| 61 | `variant3d/assets/terrain/masks/nowater2/6pl_mask_nowater_0_gauss.png` | 398 | `47adf724f94eeb433354fc29497da57ef97530b858d7997af99c44a4d6dd445f` |
| 62 | `variant3d/assets/terrain/masks/nowater2/6pl_mask_nowater_2_gauss.png` | 397 | `8c903c8d0c8a1eebf4a3b08ac5e0615ad5a895074aa7559cf9ef30b557a8a409` |
| 63 | `variant3d/assets/terrain/masks/nowater2/6pl_mask_nowater_6_gauss.png` | 401 | `5102aff49a89efa87bd928f7ecc508e53f9f7621732318a351fe5ca907d6cc7a` |
| 64 | `variant3d/assets/terrain/masks/nowater2/7pl_mask_nowater_0_gauss.png` | 404 | `fa58392a67d3c2ec2a7dbdd0d1dfcdc33f8435fed8acd8205729cacdd05860cd` |
| 65 | `variant3d/assets/terrain/masks/peninsulas/2pl_mask_peninsulas_0_gauss.png` | 13,757 | `3adddcbaa8d0191a12aaae24840b9e95480e851d6e74df6ee807e921c7b0f1b1` |
| 66 | `variant3d/assets/terrain/masks/peninsulas/2pl_mask_peninsulas_41_gauss.png` | 21,779 | `dfa014c31742ca96d9d25d0a35e33ef2bfa80a7ee8a350a931a73057b503b672` |
| 67 | `variant3d/assets/terrain/masks/peninsulas/2pl_mask_peninsulas_73_gauss.png` | 21,398 | `b8d9d16cf04ed359761f5d8a951b3965a49e5730a16ec6eadd1d48e613cac43c` |
| 68 | `variant3d/assets/terrain/masks/peninsulas/3pl_mask_peninsulas_37_gauss.png` | 22,219 | `b4dde40f37a81d39a05954189fe4d537dfbd239294290dd1f3fb17a063062bde` |
| 69 | `variant3d/assets/terrain/masks/peninsulas/3pl_mask_peninsulas_69_gauss.png` | 21,656 | `0e57c3507d489cf95b33cdfc1a27b20ad0fcea88d831a25d6102072f8e172c41` |
| 70 | `variant3d/assets/terrain/masks/peninsulas/4pl_mask_peninsulas_10_gauss.png` | 29,600 | `99874fd271bb4114baabe97f7540f6514d03c32557dd181c82097c42178eb7eb` |
| 71 | `variant3d/assets/terrain/masks/peninsulas/4pl_mask_peninsulas_42_gauss.png` | 19,843 | `3275ad869a2d9cfc48cdb3e23e8c73fbc309f56b327ff921093571972e9ea864` |
| 72 | `variant3d/assets/terrain/masks/peninsulas/4pl_mask_peninsulas_74_gauss.png` | 16,835 | `6a1701a2f9d2136c9a8680b1bcdb33f6f42999671f6fd23ac13767ec6321e64f` |

### A_blocks — 112 files / 174,122,611 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 73 | `variant3d/assets/terrain/blocks/desert1.png` | 1,688,394 | `c4f8d99c2d9be289d97e0e7121174222a8489cc25924e4a8b80578f042ce1a51` |
| 74 | `variant3d/assets/terrain/blocks/desert10.png` | 1,322,120 | `94552049ac59e37027d25b31024a73096b8b8d1d35c41302983b82b6f5070a61` |
| 75 | `variant3d/assets/terrain/blocks/desert11.png` | 1,611,945 | `96705c4af810e55dbb55229a19e5256da034cb3df4aca5e0b3c98448baff6c84` |
| 76 | `variant3d/assets/terrain/blocks/desert12.png` | 1,566,364 | `20df2ac3c0c37e101401b1be72b1e5dbf549f0b42383227af4d87359939d2560` |
| 77 | `variant3d/assets/terrain/blocks/desert2.png` | 1,277,602 | `b625bf03fa85c0e45e5a11cbdc97b2283cee0e2b7be3c4a560ec5d545be932e4` |
| 78 | `variant3d/assets/terrain/blocks/desert3.png` | 1,234,725 | `1abd86923806a16c09109cd4f03b938b3599f8966e08c8279c3edbeb209e8cd2` |
| 79 | `variant3d/assets/terrain/blocks/desert4.png` | 1,217,440 | `899ac58e32df607f56014260d0a43f2215a924618d975b460fd2de018f6c8716` |
| 80 | `variant3d/assets/terrain/blocks/desert5.png` | 1,209,148 | `5ab5f759136a54000d926f2f3c35c541303cd0895c7dd04e6712d97712f9de26` |
| 81 | `variant3d/assets/terrain/blocks/desert6.png` | 1,471,641 | `8aeec4135c4e5c94f24f4fc0989b966073bf7d068ff1340c4d317f15656cd378` |
| 82 | `variant3d/assets/terrain/blocks/desert7.png` | 1,560,623 | `1c817419b217ab35fb7f6e1ab0bdc4ef103056b62d3c2003af2c2b963a553eb3` |
| 83 | `variant3d/assets/terrain/blocks/desert8.png` | 1,800,449 | `2f63801867004bc1c1f108555d3d1563ac507d94d6d5be331f54b4c9c2cd1132` |
| 84 | `variant3d/assets/terrain/blocks/desert9.png` | 1,687,926 | `818d838657a5d471a9b8e677f0b2280956c400a5fb3e797a968b777b05668d9a` |
| 85 | `variant3d/assets/terrain/blocks/grass1.png` | 1,355,043 | `28e617b1f72233f91335f3020c02599678673eff12de390ce8f6084e87a8019a` |
| 86 | `variant3d/assets/terrain/blocks/grass10.png` | 1,633,086 | `1ab142963d2fcc43588dbd9e73f0a2324d2f74be64bf3a2df6a6b774662151fd` |
| 87 | `variant3d/assets/terrain/blocks/grass2.png` | 1,442,501 | `cdbbb30f23a32a0ad5984095b9008b612f57e2c2426631b0ff4e8a1370ee579c` |
| 88 | `variant3d/assets/terrain/blocks/grass3.png` | 1,726,790 | `8cc9399c11671b0fa94c55d114fdc19fddcd0bb734f51f1a11259dbdce849376` |
| 89 | `variant3d/assets/terrain/blocks/grass4.png` | 1,493,365 | `bb9e2b324b886e6576e417dfa5d6011f01486449f139d7a6fb0f5df9557b3ef9` |
| 90 | `variant3d/assets/terrain/blocks/grass5.png` | 1,726,973 | `ff2c732dd94e84ab1c4160f649b2d8b7154fd8846fca5e6128bd190915541c02` |
| 91 | `variant3d/assets/terrain/blocks/grass6.png` | 1,588,321 | `0c34bea286800d06bc12d0f40fe4cd3641b8ed82987540c95c9bbe902832b20d` |
| 92 | `variant3d/assets/terrain/blocks/grass7.png` | 1,577,813 | `aa94c98d6c97f95873c068804e20a5ba2137f1e46b614759d68929646202abfe` |
| 93 | `variant3d/assets/terrain/blocks/grass8.png` | 1,561,623 | `26b2edb974721b8d0ce00eed8ebc37216bef7326b7c101ab2808ee3c0b1b7d5e` |
| 94 | `variant3d/assets/terrain/blocks/grass9.png` | 1,703,575 | `144acce46381fd7712fb7526f028243025b04dcab05e0111b0c2a5571619f5ab` |
| 95 | `variant3d/assets/terrain/blocks/grass_ground1.png` | 1,788,486 | `93a5ad238d5c72f91aaa46e0621dee2d329449f12b4e6f746cdd6f4e8ff6d3eb` |
| 96 | `variant3d/assets/terrain/blocks/grass_ground2.png` | 1,836,020 | `eb66ca47e09f9ac2b337fc6637c42afbac5b4a5961e1dbede654a7021dd8556e` |
| 97 | `variant3d/assets/terrain/blocks/grass_ground3.png` | 1,790,801 | `781677072f628ca66bea2c67a5607ceef8a02cbbe6c6c95de07d7e99a6ce9228` |
| 98 | `variant3d/assets/terrain/blocks/grass_rock1.png` | 1,554,530 | `472ed8daa22a992434103e3d36e771b8676159dfa0a8ea34c99d2905fec07a7b` |
| 99 | `variant3d/assets/terrain/blocks/grass_sand1.png` | 1,537,989 | `6fb324fefcb1ac6f29f5b9b8c431dea7ca02aa07594b2da8c1af1308301109fe` |
| 100 | `variant3d/assets/terrain/blocks/grass_sand2.png` | 1,740,785 | `6f80ebdb0f5d347eedc46ea496336cbce0f649f59d579d1623e5ae7cdae91b24` |
| 101 | `variant3d/assets/terrain/blocks/ground1.png` | 1,805,315 | `075d6c67ad42c93dd105f1e6cfaf7f034e5cb8906b3864a971a1d3289d5758cc` |
| 102 | `variant3d/assets/terrain/blocks/rock1.png` | 1,534,297 | `1799e7c7b12381150fde6d02744013424eb9fea4b9eb3ec0c1a14f1b2541f24f` |
| 103 | `variant3d/assets/terrain/blocks/rock2.png` | 1,525,046 | `96daa694aa956e0bfb12b472035d75fd9df34bcdfc0c43f98bf09ff4c23686fb` |
| 104 | `variant3d/assets/terrain/blocks/rock3.png` | 1,523,049 | `9f0a6014c4148c2cac0c144802367b327c4d675686c95a2a3e92dcf1cf4951f6` |
| 105 | `variant3d/assets/terrain/blocks/rock4.png` | 1,484,445 | `174f4bbde0d6ec1848ed808dcfb2e27c8e5aaf440e0f01fbea59e31004d6e794` |
| 106 | `variant3d/assets/terrain/blocks/rock5.png` | 1,699,233 | `9e0f14d72af1c66ba5e41920db4b1019a808c9e5447bfbf6944ce2054bddf734` |
| 107 | `variant3d/assets/terrain/blocks/rock6.png` | 1,507,887 | `2b0415e02d9c7d5a049b8001f0ab6487577b7c00fa7eee117aa091ced798910f` |
| 108 | `variant3d/assets/terrain/blocks/rock7.png` | 1,558,813 | `ff594832efbce38c445eee3f4c56d39dda64301df1c1e37adb223addade001c9` |
| 109 | `variant3d/assets/terrain/blocks/rock8.png` | 1,674,211 | `d33435c41d7474d1544c01323e0cbf2739a0e0a20f7b404cad44377b13393939` |
| 110 | `variant3d/assets/terrain/blocks/rock9.png` | 1,736,528 | `ba5f539c5819cb00c811afa16732c6d6de33a04eb1a0f987431358e752739dcc` |
| 111 | `variant3d/assets/terrain/blocks/sand1.png` | 107,243 | `2b02d8f92e4bb0fd97dbaecf6eb32d074e12c696185508079c4aca4c14316f86` |
| 112 | `variant3d/assets/terrain/blocks/sand2.png` | 114,425 | `5b12476837f161e4f1db5252f09d3265eceb3fbddcf282ad8f68b65052fc52b7` |
| 113 | `variant3d/assets/terrain/blocks/sand3.png` | 1,544,799 | `33887e0747585c750718c0c4aef6d14f2f8676c75b37f8d51046569ce27869ee` |
| 114 | `variant3d/assets/terrain/blocks/sand4.png` | 1,543,335 | `37d5a9e2b7e08ba1c268e5601c5101f38f4293705796fb3547f1f2ae55d11da6` |
| 115 | `variant3d/assets/terrain/blocks/sand5.png` | 1,679,469 | `00f7ee4e3a0d190da0a183a11b16e44ba476c6a0b562be6ee4bae33bc75117f8` |
| 116 | `variant3d/assets/terrain/blocks/sand6.png` | 1,732,199 | `4c7ca8e8ae36263fc2dba3ce8efa7ccbdf1636b0a7064c1d348bd43e4c94fa4f` |
| 117 | `variant3d/assets/terrain/blocks/sand7.png` | 1,884,634 | `97aabe2cfa9beb5434f77ada4f0931d8e61fc99785e97a6509763313e28293cc` |
| 118 | `variant3d/assets/terrain/blocks/sand8.png` | 877,455 | `787437b9c8d3243ddf47eadc19720c879dd9f2adfed43f5ffc3e175bcabdfa3c` |
| 119 | `variant3d/assets/terrain/blocks/sand9.png` | 1,662,080 | `b1d392fbbb31c17c3b178be607f87524a196f62474b0172a9c7445435b9c4e77` |
| 120 | `variant3d/assets/terrain/blocks/sandrock1.png` | 1,681,726 | `063bc72945e09f39e904438541aea0f6f3aa39ab64ba61d3d0e8e65efeac93b9` |
| 121 | `variant3d/assets/terrain/blocks/sandrock2.png` | 1,723,104 | `69d95c9fe2b368ad5fc6d56f4e4c85e7658108d304215666f728ee30ffbc33db` |
| 122 | `variant3d/assets/terrain/blocks/sandrock3.png` | 1,892,359 | `4582398c12f08074af772462ba69a2cbaeb7c34a61ba2e024afac58c90d7df30` |
| 123 | `variant3d/assets/terrain/blocks/sandrock4.png` | 1,875,881 | `19b3fe98476b8c4c5a3a210e329c83dd4e021aa3ccd571f65b11ec1fccf88c2c` |
| 124 | `variant3d/assets/terrain/blocks/sandrock5.png` | 1,271,242 | `692b90cf69c3212731a216a013a93113447ea20bc6af8a12e6434a66de2fa7e9` |
| 125 | `variant3d/assets/terrain/blocks/sandrock6.png` | 1,045,592 | `eea8891ab965d188183b59e2c15640f25c3a2eb3f431b2eecd048fc1f8465019` |
| 126 | `variant3d/assets/terrain/blocks/sandsea1.png` | 1,652,351 | `32fac1e7de30cf7568c2676601b8fefbf36f9deb7bea991049acdcbeaf37140d` |
| 127 | `variant3d/assets/terrain/blocks/sandsea2.png` | 1,662,940 | `b988cb1554abbc415be0efe6d9040bcd69d8c9dab4d609c6abdcbfade9c6ad9e` |
| 128 | `variant3d/assets/terrain/blocks/sandsea3.png` | 1,497,244 | `c5d941575a7fc37935e2e4a764ff014087fdbe388dbba69d4b76c9ec3aaf92fc` |
| 129 | `variant3d/assets/terrain/blocks/sandsea4.png` | 1,497,924 | `f38419c5d22915999af2618aa82b543e89eed8986f14b88cc671cc68ea6c1b52` |
| 130 | `variant3d/assets/terrain/blocks/sandsea5.png` | 1,567,495 | `dfde5ce1c8e24ca56e8646b6c5c1d257ea0b5927c8c73cc8db29092b174e64c5` |
| 131 | `variant3d/assets/terrain/blocks/sandsea6.png` | 1,600,792 | `3ef8a7aaf0187681a49304a5b6c8527451a59e36a13f043e956a83f83fe45c3b` |
| 132 | `variant3d/assets/terrain/blocks/test0.png` | 1,561,623 | `26b2edb974721b8d0ce00eed8ebc37216bef7326b7c101ab2808ee3c0b1b7d5e` |
| 133 | `variant3d/assets/terrain/blocks/test1.png` | 1,748,156 | `eb6ab2bdea40d795f356eb66d5548c8e381be2699eaafb9906fd97072a29606e` |
| 134 | `variant3d/assets/terrain/blocks/test10.png` | 1,355,043 | `28e617b1f72233f91335f3020c02599678673eff12de390ce8f6084e87a8019a` |
| 135 | `variant3d/assets/terrain/blocks/test11.png` | 1,355,043 | `28e617b1f72233f91335f3020c02599678673eff12de390ce8f6084e87a8019a` |
| 136 | `variant3d/assets/terrain/blocks/test12.png` | 1,459,162 | `2735962fdf2fbf0883c272ace87347a94e9cf4f2409f73358e8f1dac8dc345bc` |
| 137 | `variant3d/assets/terrain/blocks/test13.png` | 1,443,592 | `10bf13adb9ecbf9566d1790e2d35d1a00a19daadf7db4ab23d1fe303be592a28` |
| 138 | `variant3d/assets/terrain/blocks/test14.png` | 1,411,534 | `059bc55bf9f318bd9390e353cb75875cd86e5ecd935bd0c0ef6d31e5ccf82f13` |
| 139 | `variant3d/assets/terrain/blocks/test15.png` | 1,753,451 | `c86f7f4c0383061676da2fba8a4be741bd20c028837fde7ed299c136da3cfff8` |
| 140 | `variant3d/assets/terrain/blocks/test16.png` | 1,943,357 | `abedceda8c6e374ea8ed5a2f1e27efcf74dc78730496d5c5661969dbd95377dc` |
| 141 | `variant3d/assets/terrain/blocks/test17.png` | 998,200 | `34c937d97d58c0ac0723edc689b1a7430c9e796e5088b9f7bb4d54d1206e94fb` |
| 142 | `variant3d/assets/terrain/blocks/test18.png` | 1,782,661 | `013525a8f6168a50c326d0e9f42bc2eb312cce7c9dd7b0ec9eb543059f8e700c` |
| 143 | `variant3d/assets/terrain/blocks/test19.png` | 1,750,219 | `4e0e5e8d18a12bbbb0bf4f9cdc8e16737f67fde10dda860dc9b66451eb212fc9` |
| 144 | `variant3d/assets/terrain/blocks/test2.png` | 2,092,621 | `13c82463ec1ea9d30841ac1b19629503dea094990e41ec1654ad9cb4f9702ed6` |
| 145 | `variant3d/assets/terrain/blocks/test20.png` | 1,561,378 | `2690841ed3ac05c84cc065502b60829f07c6a642edb8d636e8168f01f0dc2615` |
| 146 | `variant3d/assets/terrain/blocks/test21.png` | 1,816,584 | `9d5602afd9a776c40a657f5921c9de09f21001e851e592e6e9a7c815ff76b214` |
| 147 | `variant3d/assets/terrain/blocks/test22.png` | 1,744,926 | `645641dda0a4d9632ecf158bacecd192d52322f80a0d4f52377acafea4836662` |
| 148 | `variant3d/assets/terrain/blocks/test23.png` | 1,620,721 | `ee037f26e71d06685b141ec48eca96c74d4b54b46bddbb2ae3140e4589544b46` |
| 149 | `variant3d/assets/terrain/blocks/test24.png` | 1,638,390 | `b74e3d7973224b7dc7fd2cc07af542dbdd8f024a671f7db9d5b24f7aec82b27d` |
| 150 | `variant3d/assets/terrain/blocks/test25.png` | 1,657,029 | `74d290ddd993bacbda1d043918647176ea6049de5ee523baea49682c51c564d1` |
| 151 | `variant3d/assets/terrain/blocks/test3.png` | 2,085,799 | `3cbf263c70b01e3202bd94b375181e100338a25b19702b36f90b306ea6c7c86a` |
| 152 | `variant3d/assets/terrain/blocks/test4.png` | 1,983,831 | `f574b4279d20b08a75d931f84eab769e661f2f9347ad89936ac5651f3661de51` |
| 153 | `variant3d/assets/terrain/blocks/test5.png` | 1,927,156 | `221139de7a7fee0b26ee43a042874ddcd6b78c28a6f2f7116cf4b01e33ec1e32` |
| 154 | `variant3d/assets/terrain/blocks/test6.png` | 1,492,296 | `f20ccd6c4827bde70b346f0bfa996996086f978d2bb55bd96f172aca26c8c3cf` |
| 155 | `variant3d/assets/terrain/blocks/test7.png` | 1,596,286 | `6321a6f05946e08deda7f3bc113368c8466d09256af92bca4cd0d059b3378b10` |
| 156 | `variant3d/assets/terrain/blocks/test8.png` | 1,784,860 | `6106facd2601621a27432ad6c8f5c51a94fd0768ef1f0466bd4df1271d1d512a` |
| 157 | `variant3d/assets/terrain/blocks/test9.png` | 1,745,790 | `3a9721cfe722dde80c4ccaeafee1fac593aa171411c93697774fa8aec3acc671` |
| 158 | `variant3d/assets/terrain/blocks/winter0.png` | 858,677 | `06e40cd68c15276c90691e945a2d77ca2bf7dba87161d12e191fb2357e07bd57` |
| 159 | `variant3d/assets/terrain/blocks/winter1.png` | 1,012,339 | `0a171a2fd94f6ca0662112a0033a68b52cc60d718ef7ac5bfd411f98287cb0da` |
| 160 | `variant3d/assets/terrain/blocks/winter10.png` | 1,086,894 | `9bb1aa06465b63b211a503bddccdce9b509da80b630c4d850e816f772d18f81d` |
| 161 | `variant3d/assets/terrain/blocks/winter11.png` | 1,966,411 | `a83e3cd8784ffd16b2097d14c5d08f03a88c9fa3f86be214bd4c66103868d26f` |
| 162 | `variant3d/assets/terrain/blocks/winter12.png` | 1,939,422 | `70cd09a8ba5b8515f5d642a5272af66253b61c81b3732d6accdcb73c8d165cac` |
| 163 | `variant3d/assets/terrain/blocks/winter13.png` | 1,893,479 | `b7d194e9ab6b55ac5f43f4e9bf94a4e6ad5c95e0d720e0b9ec024141f5960a18` |
| 164 | `variant3d/assets/terrain/blocks/winter14.png` | 1,783,597 | `df12de72ce0582d4a107fcf006daef3f6567855ae8d1cff1ab762918893d5bbf` |
| 165 | `variant3d/assets/terrain/blocks/winter15.png` | 1,780,211 | `c788a118989f4e71d1a86ea8726a67fac8b6ce5158df28d92ee845ccaf718594` |
| 166 | `variant3d/assets/terrain/blocks/winter16.png` | 1,827,471 | `579dae72bd087e238068d1b771d48fac3352760df5a7950f5dd808256053e0f9` |
| 167 | `variant3d/assets/terrain/blocks/winter17.png` | 1,787,433 | `420dadbe3ea7346c0213d619dafa1c8d951a09b40d835649a71658905cb305d6` |
| 168 | `variant3d/assets/terrain/blocks/winter18.png` | 748,808 | `81505716e537ae0aa4efb8d43246e78b315e43b4f3a62cc766d7dd9787b7f2ba` |
| 169 | `variant3d/assets/terrain/blocks/winter19.png` | 1,123,214 | `15e4b44e3c55d2163b373df7b73eb5915f9ffcdfe56ab9aea115bf3a1dca05f2` |
| 170 | `variant3d/assets/terrain/blocks/winter2.png` | 1,268,022 | `0466cd5d92b849728cc0a2ed832a76a92e06996f31e19689ba69bf5203971940` |
| 171 | `variant3d/assets/terrain/blocks/winter20.png` | 1,623,862 | `41bc8f8c3f20d6ef86a9c3afbe097683423e8043db23d53d7a5b6ed17b402d68` |
| 172 | `variant3d/assets/terrain/blocks/winter21.png` | 577,492 | `1985ba852cd408dba1e008ac91aa1d794014c6e8a5ee0d30562220d9a5d8f186` |
| 173 | `variant3d/assets/terrain/blocks/winter22.png` | 1,888,129 | `7a0366d060cafc4173658466e8010cf1b25d50e3a44106e808bdcaa40e73c5b7` |
| 174 | `variant3d/assets/terrain/blocks/winter23.png` | 1,750,219 | `4e0e5e8d18a12bbbb0bf4f9cdc8e16737f67fde10dda860dc9b66451eb212fc9` |
| 175 | `variant3d/assets/terrain/blocks/winter24.png` | 1,750,219 | `4e0e5e8d18a12bbbb0bf4f9cdc8e16737f67fde10dda860dc9b66451eb212fc9` |
| 176 | `variant3d/assets/terrain/blocks/winter25.png` | 1,750,219 | `4e0e5e8d18a12bbbb0bf4f9cdc8e16737f67fde10dda860dc9b66451eb212fc9` |
| 177 | `variant3d/assets/terrain/blocks/winter26.png` | 1,750,219 | `4e0e5e8d18a12bbbb0bf4f9cdc8e16737f67fde10dda860dc9b66451eb212fc9` |
| 178 | `variant3d/assets/terrain/blocks/winter3.png` | 1,475,788 | `11941960763cf6e566191f62e74c85d80151a11d1e1701d1d213d3c05cbf64af` |
| 179 | `variant3d/assets/terrain/blocks/winter4.png` | 1,357,548 | `563f4db78f9fe0d57922932081d295e6efda547d9890b7d247d7fbb559655191` |
| 180 | `variant3d/assets/terrain/blocks/winter5.png` | 1,310,280 | `3060c857195bdab4add51f5443dfb1189bbfa3f3cf042266bb33abaffc0c05c1` |
| 181 | `variant3d/assets/terrain/blocks/winter6.png` | 1,766,304 | `8dba024695eac99a75b9be14c23220bba0647286f1a13e246ced2417a9d86e8d` |
| 182 | `variant3d/assets/terrain/blocks/winter7.png` | 1,951,362 | `782f6ae74b841675dc3bbb359fba01b85468404040ac65e0c5aa5bf7bd91b67a` |
| 183 | `variant3d/assets/terrain/blocks/winter8.png` | 1,588,758 | `b2a23f379ef64a0f4afdaed69887333b4b431bc835c221b0aa970fcdfb43d9db` |
| 184 | `variant3d/assets/terrain/blocks/winter9.png` | 1,327,335 | `974069381acb4939e511e4be6e53b67743d312e6709fdb01560e67c5e20b2d4d` |

### G_relief — 12 files / 32,542,912 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 185 | `variant3d/assets/models/obj/shared/terrain/terrainmesh1.obj` | 302,651 | `73ae92c1c58df20f11fcbdfaf614496866f73e10e608d926f4bcd36a317c3242` |
| 186 | `variant3d/assets/models/obj/shared/terrain/terrainmesh1.mtl` | 77 | `626b1275ee890932dd8e719e5fdf5b504d187bcf784e04fc3e40b40babafffd1` |
| 187 | `variant3d/assets/models/tex/shared/terrain/terrainmesh1.png` | 7,758,343 | `feb4f587bb37f6376af33b67894fca5c87936bc18d8c87bc7ad0712ef07294a6` |
| 188 | `variant3d/assets/models/obj/shared/terrain/terrainmesh2.obj` | 256,005 | `c16cfbf1225aaace77d742bd9922861e6b58ff863789aa599263a57f11d00e90` |
| 189 | `variant3d/assets/models/obj/shared/terrain/terrainmesh2.mtl` | 77 | `773f246aa0e40aa49dbd64744e4f015acab46ddd3e2f4f2380a7a76c54708f92` |
| 190 | `variant3d/assets/models/tex/shared/terrain/terrainmesh2.png` | 7,780,004 | `0e3cd1244c4b480fcc70b02adcccf50978272a163db60ada48255358ec128783` |
| 191 | `variant3d/assets/models/obj/shared/terrain/terrainmesh3.obj` | 244,123 | `d01146bba704bc31000c10c657d6e4fbd43dcb1ef7dbea02311a47cbe8ead7f6` |
| 192 | `variant3d/assets/models/obj/shared/terrain/terrainmesh3.mtl` | 77 | `c1a28d5b725db796fb0f7fa46cc182e9f3ef9a4fd930561aedbf79965ca8e242` |
| 193 | `variant3d/assets/models/tex/shared/terrain/terrainmesh3.png` | 7,853,483 | `68552509372f07bd21f727a023202a7372e66ef3efbcde1fb592efed952608cb` |
| 194 | `variant3d/assets/models/obj/shared/terrain/terrainmesh4.obj` | 342,497 | `983c34352c8aea8b5806c320fe72e2efd58c954466e8108649b5eb86f32ade19` |
| 195 | `variant3d/assets/models/obj/shared/terrain/terrainmesh4.mtl` | 77 | `fd6e7c853958e1d27900bb53e08f567bbd37152a2bfeba27742e731cc6623c5f` |
| 196 | `variant3d/assets/models/tex/shared/terrain/terrainmesh4.png` | 8,005,498 | `982c65b08730af48d384053026fb2d002454bba60e8d4317d08d99f3130c53e4` |

### H_mines — 6 files / 16,181,736 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 197 | `variant3d/assets/models/obj/shared/buildings/mine_gold.obj` | 91,920 | `cd1c2d9f381dab76d59c6b8df5b24e5e1739f9d5fc7f7cc22c6fdeca13824a43` |
| 198 | `variant3d/assets/models/tex/shared/buildings/mine_gold.png` | 5,306,512 | `3deceee2227c5762a076ba1b717db5ad791c806cf8da2940342ea988be888a53` |
| 199 | `variant3d/assets/models/obj/shared/buildings/mine_iron.obj` | 91,920 | `8b3d45b11b5e65cb8b655b48baa5b135a84e32ffbbc6c9c173f8b2c8947fda88` |
| 200 | `variant3d/assets/models/tex/shared/buildings/mine_iron.png` | 5,270,454 | `a8f4b671ad02319d42d8bc40cfb5af81700be1dd4ad2437023a1285e2564eac6` |
| 201 | `variant3d/assets/models/obj/shared/buildings/mine_coal.obj` | 91,920 | `2a3b99402e5a06194d8bf0e1a15fc8371050982fa979da8a512e4d41d15919bf` |
| 202 | `variant3d/assets/models/tex/shared/buildings/mine_coal.png` | 5,329,010 | `236164d390166b02f78756b6eaa54f4fd7deb9a79e44741c327d8603c2047afa` |

### I_waves — 8 files / 2,743,445 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 203 | `variant3d/assets/terrain/water_png/diffusewaves0.png` | 106,943 | `f194e5ed401dd3d1e65e1ecca7e07e51b9808bed8a499d560ed695fb6cfc07f3` |
| 204 | `variant3d/assets/terrain/water_png/diffusewaves1.png` | 169,108 | `ae20e5f5aa52e2b97960d2c7b361d14aadc76d539731727a7bb0f31954b0b058` |
| 205 | `variant3d/assets/terrain/water_png/diffusewaves2.png` | 405,187 | `90f9f43c87b9ef5fcb333dc1c4252320a4e97ac7f897820c8c8df58035408142` |
| 206 | `variant3d/assets/terrain/water_png/diffusewaves3.png` | 365,743 | `3d6e3f18edd8f2635306ab1ade2e5f54538146ff03fb4c0ecae4e4fdd6e747cd` |
| 207 | `variant3d/assets/terrain/water_png/diffusewaves4.png` | 517,341 | `e46ccaa81627eae80fe5748bf229dc472cafdeaf70faf8407d3502f2e8c706ca` |
| 208 | `variant3d/assets/terrain/water_png/diffusewaves5.png` | 626,483 | `01967393c2464918f4e8428dc8bacb8c5c440bda6ade217945ec1ee9cc2cbc48` |
| 209 | `variant3d/assets/terrain/water_png/diffusewaves6.png` | 148,094 | `b229d7071d31bc21bbe34dc53983f63633b95c7134bac857b6bda6a30175dde3` |
| 210 | `variant3d/assets/terrain/water_png/diffusewaves7.png` | 404,546 | `3818015951785c03fc3c8099ab86e947f2cbbc44ec9069ebfa72b6b3ba4fac07` |

### J_field — 4 files / 1,367,632 bytes

| # | File (repo-relative) | Bytes | SHA-256 |
|---:|---|---:|---|
| 211 | `variant3d/assets/models/obj/shared/terrain/field.obj` | 44,551 | `7824a2dd8b77e1a807604bcb2e4d63dc2be1974bc307a59b90b4f8c37d3f5139` |
| 212 | `variant3d/assets/models/tex/shared/terrain/field.png` | 48,365 | `8eee403df4ab56f0c32fbbb3fab707eeba3127618e56c8df42004e0e72c3c8ef` |
| 213 | `variant3d/assets/terrain/deco_png/envfieldd.png` | 615,507 | `3f944af89656fbb6203496fdbbeb8a6a1508e0d36b5e7930cc51f8f31e66b0c3` |
| 214 | `variant3d/assets/terrain/deco_png/envfielddw.png` | 659,209 | `dd41540a1bf350be0656822699882b65c228f501847d1ccb643941e949ee1932` |

## 4. Multiple passes on contradictions — resolutions

| # | Apparent contradiction | Pass 1 | Pass 2 | Pass 3 / final reading | Label |
|---|---|---|---|---|---|
| C1 | P02 `blocks/**` = 174,228,604 B vs 112-PNG census 174,122,611 B | PNG-only total 174,122,611 | 112/112 hashes agree | 112 `.import` sidecars = 105,993 B; 174,122,611+105,993 = **174,228,604**. Not a contradiction. | [O]/[D] |
| C2 | P02 `masks/**` = 913,631 B vs 838,488 B | PNG-only 838,488 | 56/56 hashes agree | 56 `.import` = 56,781 B + `manifest.json` 18,362 B = 75,143; sum **913,631**. | [O]/[D] |
| C3 | P02 `atlas/**` = 304,844,245 B vs 4-PNG 304,599,443 B | 4 PNGs 304,599,443 | 4/4 hashes agree | 4 `.import` = 3,855 B + 4 JSON = 240,947 B; sum **304,844,245**. | [O]/[D] |
| C4 | P02 `atlas_parts/**` = 180,141,102 B vs 5-file 180,139,198 B | 5 files 180,139,198 | 5/5 hashes agree | 2 `.import` = 1,904 B; sum **180,141,102**. | [O]/[D] |
| C5 | P02 `water_png/**` = 2,751,186 B vs 8-PNG 2,743,445 B | 8 PNGs 2,743,445 | 8/8 hashes agree | 8 `.import` = 7,741 B; sum **2,751,186**. | [O]/[D] |
| C6 | A03 E8 says "124 named + 4 empty slots" vs manifest `slots=128, named=124, filled=121, empty=3` | direct key read | V7-85 report §2 confirms 121 filled cells over 124 names | `layout[]` has 124 entries: 85 DIRECT + 36 FACE_BASE_REUSE + 3 EMPTY. The "4" = `128−124` **unnamed** slots, not empty named cells. Accepted reading: 4 unnamed slots **and** 3 EMPTY cells. | [O] |
| C7 | P02 F1 "root PNGs pixel-duplicates of blocks but byte-different" vs atlas manifest `source_sha256` per cell | raw hash of `blocks/grass1..5` matches atlas manifest | independent `Get-FileHash` agrees | Additional pass: `terrain/grass1..5.png` raw hashes all differ from `blocks/grass1..5.png`. Pixel equality (Pillow `tobytes`) and byte equality are different predicates; no contradiction. | [O]/[D] |
| C8 | Split parts vs single atlas: two different byte sets claiming same art | part hashes `019f0f9d…`, `295a527c…` | part sizes 90,000,000 + 89,912,941 | `split_manifest.json:64-69` `verification.matches=true`; concatenation hash = `a1f123a1…`. Lossless split, not new art. | [O] |

All eight were re-run with at least two instruments before an accepted reading was recorded (CHARTER.md:94). No anomaly was silently skipped.

## 5. Commit / licence guard

| Class | Exact objects | Rule | Label |
|---|---|---|---|
| **Never commit — donor bytes** | `data/pattern/pattern.lib`, `*.pattern`, `data/gen/terrainmasks/**/*.tga`, `data/terrain/ref/*.bmp`, `data/terrain/tiles/textures/*.dds`, `*.exe`, verbatim `*.cfg` | read-only private install; no donor byte copied, executed or committed; hash-check outputs against this list | [O] `CHARTER.md:67-69`; `A03 §2.4`; `CREDITS.md:125-130` |
| **Never commit — large derived art** | `atlas/tile_index_atlas.png` 179,912,941 B, `atlas/tile_index_atlas_winter.png` 124,463,306 B, `atlas_parts/tile_index_atlas.part000` 90,000,000 B, `.part001` 89,912,941 B | uncommitted or LFS; split parts are the **same art** and must be treated identically; reassembly to `user://` only | [O]/[D] E6, `spec/11 §11.4`, `P02 F6` |
| **Safe to commit — compact tier** | `atlas/tile_index_atlas.png` at `--cell 128` (2048×1024, ≈8 MB raw), V7-85 manifest with `resolution_tier:"commit_default"`, `alpha.png` 55,242 B, `alphavert.png` 167,954 B | derived from already-converted block PNGs; no donor path embedded; no new index mapping | [D] `A03 §2.2.1/§2.4` |
| **Safe to commit — derived data** | `patterns/family_index.json`, `families/*.json`, `masks/mask_index.json`, `masks/height/**/*.height.png`, `cfg/constants.json`, `config_strings.json`, `schemas/v1.schema.json`, `manifest.json`, tool source, `inbox/` validation logs | labels required; `null`+UNVERIFIED for undecoded fields; `visual_parity_claim:false` | [D] `A03 §2.4` |
| **Safe to commit — reused converted assets** | the 112 block PNGs, 56 mask PNGs, `terrainmesh1..4` OBJ/MTL/albedo, 3 mine meshes/albedos, 8 wave sheets, 4 field cut-outs, the 3 provenance tables | already tracked derived art; I05 should reference them, not copy donor bytes; inherited provenance labels stay | [O]/[D] census §3; `P02 §4` |
| **Never claim** | any "parity achieved" text or donor GPU capture presented as proof | no A/B frame exists (CHARTER.md:41,125) | [U] |

## 6. Validation checklist for I05 (byte-compares)

Inherited from `A03 §2.6` / `spec/11 §11.6`; X15 ran **no** Godot job and executed none of these engine checks.

1. [O] `pattern.lib` decoder `source_sha256` == `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0` (verified read-only this pass; abort on mismatch).
2. [O] Occupancy round-trip: decoded `occupancy_cells` == `donor_patterns.json:patterns[name].cells` in order; `w*h` == `8+len(raw)` at `0x00..0x07`.
3. [O] Family weights == `donor_patterns.json` families; `k_ravine_2→K_ravine_2` alias and dropped entries logged.
4. [U] `relief_float_grid` stays `null` until F01/D05 publish byte-proven offset+stride and a known-value table; no silent fallback.
5. [O] `objects[].base_name` matches `mountain_props.json` `by_pattern`; scaling stays raw donor units.
6. [O] Atlas geometry `grid=[16,8], slots=128, named=124, filled=121, empty=3`; `filled+empty==named`, `named+unnamed==slots`.
7. [O] Index dictionary `layout[i].name == presets_summer.json[i]`; all shipped tileblock ids resolvable; `sand1/sand2` flagged `upscaled`.
8. [O] `alpha.png` 512×256 mode `L`; `alphavert.png` 1024×512 mode `L`; donor BMP bpp 8/24.
9. [O] Height tiles: R-channel PNG size == donor TGA size; `starts`/`water_fraction` match `masks/manifest.json`; `nowater2` never merged into `land`.
10. [O] Winter aliases = 124, index order identical; carrier indices 86/110/123 EMPTY/transparent.
11. [O] Provenance closure: every `entries[]` has non-null `source`, `offset`, `output`, `output_sha256`, `label` **or** a `UNVERIFIED` label with nulled hashes.
12. [O] Recomputed sha256 of every emitted file == manifest value; `pack_id` recomputed from canonical seed == committed value.
13. [O] No `source` resolves to a committed file; no absolute donor path in committed bytes.
14. [O] Every `null` field carries `UNVERIFIED`; every JSON carries `visual_parity_claim:false`; `--dry-run` writes zero bytes; two clean runs byte-identical.
15. [O] COORD-only gates unchanged: selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN, `app/` byte-identical (CHARTER.md:63-64,125).
16. [U] Visual parity stays UNVERIFIED; no donor GPU A/B frame exists. Do not convert a green check into a parity claim.

## 7. UNVERIFIED register — must not be claimed donor-faithful

| # | Asset / field | Why UNVERIFIED | Owning wave |
|---|---|---|---|
| U1 | `.pattern` relief float grid + object-list tail (`donor_patterns.json` per pattern) | prior decoders stop at `int32 w,h + w*h` occupancy; `relief_float_grid` must be `null` | F01 / D05 (A03 §11.3) |
| U2 | Full `pattern.lib` record boundary map beyond `terrainmeshN` | only the 112 `BaseName=terrainmeshN` records are parsed; `offset` remains `path:line` | F02 |
| U3 | `data/gen/*.cfg` constants and `generator.cfg` non-TerrainTypes sections | raw donor bytes not decoded this pass; emit observed strings only | F03 |
| U4 | Mask R channel → metres, gauss blur, 3-pass smoothing | channel names inherited from `masks/manifest.json:4`; mapping engine-side | D03 / D05 |
| U5 | `alpha.png`/`alphavert.png` `tiaAlphaFromIntensity` formula and cell↔sub-rect mapping | donor BMP bind observed; formula engine-side | V7-85 E6/E7, F06 |
| U6 | Donor atlas packing (`tsDouble`/`ttExtended`) and empty-cell art | `APPROX_ATLAS_PACKING`, `UNVERIFIED_EMPTY_CELLS`, `UNVERIFIED_ALPHA_SUBRECT_MAPPING` in V7-85 manifest `labels` | V7-85 / F05 |
| U7 | Commit-tier cell downsampling preserves donor texel detail | no A/B frame; label `APPROX_ATLAS_DOWNSAMPLE` | A05 / F05 |
| U8 | `terrainmesh1..4` OBJ/albedo meshes: donor byte provenance, yaw sign, metres-per-unit, engine stamp selection | converted assets and counts [O] this pass; mesh source and selection PORT APPROX / [U] | D05 / A04 |
| U9 | `mine_gold/iron/coal` albedos (olive/beige disc baked in) and separate mine apron | binding inherited from P02/E02; no separate donor apron asset proved | D07 / F08 |
| U10 | `diffusewaves1..7` donor mapping and 3D use | only `diffusewaves0` reaches `water3d.gd:97`; six sheets dormant | D06 / F07 |
| U11 | Field UVs / `deco_png/envfieldd|w.png` as 3D decal | 3D UV mapping explicitly UNVERIFIED in P02 §F5 and `:444-449` | D07 / A04 |
| U12 | `desert_remap.json` season completeness / DLC terrain additions; `winter_aliases.json` donor path citation | file has 38 remap entries and 6 internal `unverified` items; donor path facts in aliases were second-hand | F10 |
| U13 | `dmask/d_*.png` 24-step alpha ramp, `structs/smooth_summer.json`, `water.json`, `tileblocks.json` | converted but no runtime consumer; generation `[I]` from `tools/copy_assets.py:222`; constants [U] | F03 / F06 |
| U14 | Any visual fidelity / "looks like donor" statement | no donor GPU A/B frame; no runtime `load()` was executed | A05 / COORD |

## 8. Open questions

1. **I05 / COORD:** approve the added root keys `version`, `labels`, `pack_id`, `atlas_manifest_v7_85_keys`, `census_reference`, `commit_policy`, `validation` as additive to A03 §2.2.5, or keep the A03 key set strictly minimal?
2. **I05:** should the census JSON itself be emitted under `terrain_new/` as a committed file (small, hashes only) rather than living only in `%TEMP%`? X15 did not write any repo asset.
3. **COORD:** confirm pack family `terrain_new_v1` and the 16-hex pack-id truncation; longer prefix if collision policy is desired.
4. **F01/D05:** publish offset+stride and the known-value table before any `relief_float_grid` may leave `null`.
5. **F02:** replace `path:line` offsets in `entries[]` with byte ranges once the record map lands.
6. **F10:** is `desert_remap.json` complete, or must I05 emit the empty `desert_aliases.json` with `status:"UNVERIFIED"` as A03 §2.2.4 specifies?
7. **COORD:** choose one atlas transport for the fresh module: compact `single` commit tier, or LFS single + uncommitted split parts. Carrying all three duplicates ~360 MB of the same art.

## 9. Attestation

- **Read-only:** no repo asset, source, config, test, `.import`, manifest or Git state was modified. No donor file was written or executed; the only donor read was a SHA-256 hash of `data\pattern\pattern.lib`. No Godot process or runner job was started.
- **One repo file written:** `docs/terrain_swarm_2026-11-26/reports/X15_asset_manifest_skeleton.md`. All probe scripts, census JSON and the manifest skeleton live in `%TEMP%/opencode/asset_manifest/` (outside the repo).
- **Labels used:** [O] / [D] / [I] / [U] / PORT APPROXIMATION throughout; **no donor parity claim**.

*End of X15 report.*
