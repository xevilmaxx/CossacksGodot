---
id: A03
ticket: "Wave A / A03 — donor→runtime asset conversion pipeline (design only)"
title: "A03 — terrain_new asset pipeline: read-only donor decoders, provenance-labelled derived assets, Godot consumption"
owner: A03 (design subagent)
created: 2026-11-26
status: DESIGN_ONLY__NO_CODE_EDITS__NO_DONOR_READ_THIS_PASS
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
scope: "Exactly one report written: docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md. No .py/.gd/.json/.import/.cfg edit, no asset generated, no donor file opened this pass, no Godot / runner job."
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - variant3d/tools/build_tile_index_atlas.py
  - variant3d/tools/import_donor_masks.py
  - variant3d/tools/pack_tile_atlas_split.py
  - variant3d/tools/export_donor_patterns.py
  - variant3d/tools/donor_gen.py
  - variant3d/tools/build_winter_atlas.py
  - variant3d/scripts/tile_atlas_loader.gd
  - docs/terrain_swarm_2026-11-25/reports/B02_atlas_impl.md
  - docs/terrain_swarm_2026-11-25/reports/FOLD_01_folder_split.md
  - docs/terrain_swarm_2026-11-25/reports/FOLD_05_all_folders.md
  - docs/terrain_swarm_2026-11-25/reports/P02_draw_calls.md
  - variant3d/assets/terrain/patterns/donor_patterns.json
  - variant3d/assets/terrain/masks/manifest.json
  - variant3d/assets/terrain/mountain_props.json
  - variant3d/CREDITS.md
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:41,125). Every decoded value is a byte-derived PORT APPROXIMATION of donor data until F/D-wave byte proofs and a real capture land. No donor parity claim anywhere in this report."
donor_handling: "Read-only, private use, $COSSACKS3_DIR (default C:\\Games\\Cossacks 3). No donor binary is copied into the repo or executed. Only derived, provenance-labelled assets under variant3d/assets/terrain_new/**."
---

# A03 — donor→runtime asset conversion pipeline for `terrain_new`

> **Label key.** **[O]** = literal file:line / on-disk count / decoded byte read by a
> prior pass or this pass from repo files. **[D]** = deterministic consequence of
> observed data. **[I]** = reasonable design reading without a decoder run.
> **[U]** = UNVERIFIED; needs a donor-byte decode or Godot gate. Everything that
> reproduces donor behaviour is **PORT APPROXIMATION** until a real donor GPU A/B
> frame exists (CHARTER.md:41,44,125).

## 0. Executive summary

1. **[D]** The conversion pipeline is a **staged, one-way, offline compiler**: donor files are read-only inputs; every output is a *derived* asset under a **new, disjoint root** `variant3d/assets/terrain_new/**`. The legacy `variant3d/assets/terrain/**` tree stays byte-untouched; the fresh Godot terrain module (`terrain_donor_*.gd`, CHARTER.md:57-61) points only at `terrain_new`. No donor byte is ever copied, executed or committed.
2. **[O]** Prior art already proves three of the four conversion routes work and are safe: TGA→PNG masks (`tools/import_donor_masks.py:1-118`), `*.pattern` occupancy + `generator.cfg` family weights→JSON (`tools/export_donor_patterns.py:1-165`, `tools/donor_gen.py:74-85,97-129`), and block PNG→index atlas + alpha masks (`tools/build_tile_index_atlas.py:1-377`) with index-preserving winter variant (`tools/build_winter_atlas.py:1-41`). **[U]** What is *not* yet proven is the **relief float grid** and **object-record list** tail of each `.pattern` (prior decoders stop at the `w*h` occupancy mask: `donor_gen.py:74-85`), and the exact `pattern.lib` record layout beyond the `terrainmeshN` object parse reused by `assets/terrain/mountain_props.json:1-17`. A03 therefore specifies a *slot* for those tables with an explicit `[U]` label, never a guessed layout.
3. **[D]** Outputs are five asset classes: (a) small commit-safe atlas + alpha masks, (b) **per-family pattern JSON** with float grids + object lists, (c) **mask-derived height tiles**, (d) **season variants** (summer/winter/desert), (e) a single **provenance manifest** mapping `source donor path:offset → output path → output sha256 → label`.
4. **[D]** The Godot side needs **no loader rewrite to load the atlas**: `TileAtlasLoader` already accepts `single_atlas_path` and `manifest_path` overrides (`variant3d/scripts/tile_atlas_loader.gd:76-77,114-117`) and already implements the `single → split → array` fallback chain (`:186-200`). A thin new index script resolves patterns/heights/season from `terrain_new/manifest.json`. **[O]** Mip supply must follow B02: `Image.generate_mipmaps(false)` before `ImageTexture.create_from_image` (B02 §3 diff, `:140-146`), otherwise the `filter_linear_mipmap` hint has no levels (`B02_atlas_impl.md:63-75,170-175`).
5. **[O]** Licence guard is inherited, not invented: the 179,912,941-byte atlas must stay uncommitted or LFS (`tools/pack_tile_atlas_split.py:24-31,58`), donor binaries remain private (`CREDITS.md:125-130`), and any A/B parity claim is forbidden until a real capture exists. **PORT APPROXIMATION on the whole pipeline.**

## 1. Evidence table

| # | Evidence (path:line) | Fact | Label |
|---|---|---|---|
| E1 | `variant3d/tools/donor_gen.py:44-45,74-85,97-129` | Donor roots and the only *proven* pattern prefix: `int32 w,h` + `w*h` occupancy bytes; `generator.cfg` parsed via `Name =` / `Pattern =` / `Freq =` lines | [O] |
| E2 | `variant3d/tools/export_donor_patterns.py:27-38,83-103,139-158` | 41 stamped families (`WANTED`); name aliases (`k_ravine_2→K_ravine_2`); unresolvable entries dropped; output schema `{version,source,note,donor_units,families,patterns}` with centred cells | [O] |
| E3 | `variant3d/assets/terrain/patterns/donor_patterns.json:1` | Shipped derived JSON, `"donor_units":160.0`; family weights e.g. `plateau_big` `f_plt_big_1..3` weight 3.0, `f_plt_mid_1..2` 2.0 | [O] |
| E4 | `variant3d/CREDITS.md:119-124` | `pattern.lib` has 112 `BaseName=terrainmeshN` records carrying per-object `Scaling/Position/Direction`; those are **placement data**, not mesh data | [O] |
| E5 | `variant3d/assets/terrain/mountain_props.json:1-17` | `source_sha256 = f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0` for read `pattern.lib`; parsed `by_pattern` object lists; selection engine-side and `PORT APPROX` | [O] |
| E6 | `variant3d/tools/import_donor_masks.py:1-9,31-36,78-104` | `data/gen/terrainmasks/<type>/Xpl_mask_<type>_<n>_gauss.tga`; R=relief, G=forest/stone, B=water, white=start; RGB→PNG + `starts` + water fraction; `nowater2` kept distinct from `land` | [O] |
| E7 | `variant3d/assets/terrain/masks/manifest.json:1-29` | `{version,source,note,types}` schema; per-mask `{file,starts,water}`; start coords normalised floats | [O] |
| E8 | `variant3d/tools/build_tile_index_atlas.py:84-100,136-178,181-221,224-265` | 16×8 grid × 1024² cells, 124 named + 4 empty slots; donor index from `presets_summer.json:2-125` (`terrain.presets:2-6`); face-base reuse from `tiles.mat:142-148,206-220`; alpha 512×256 bpp8, alphavert 1024×512 bpp24 → mode `L`; `APPROX_ATLAS_PACKING`, `APPROX_SAND_UPSCALE`, empty cells UNVERIFIED | [O] |
| E9 | `variant3d/tools/build_winter_atlas.py:20-39` | Winter = 124-entry one-for-one rename at same preset index (`terrain.presets:134-263`); `texturemap.inc:525-526,605-606` appends `_winter` for `GetSeasonType=2`; masks shared, no donor read | [O] |
| E10 | `variant3d/tools/pack_tile_atlas_split.py:11-31,58-65,249-265` | Source atlas 179,912,941 B; zip ratio 0.998 so split is the only GitHub-safe packing; parts ≤90,000,000 B; reassembly into `user://` with sha256 check; must stay uncommitted or LFS | [O] |
| E11 | `variant3d/scripts/tile_atlas_loader.gd:62-77,99-118,174-200` | Three modes; ctor/config/ProjectSettings `terrain/tile_atlas_mode`; `single_atlas_path` + `manifest_path` overrides; fallback `single→split→array` | [O] |
| E12 | `docs/terrain_swarm_2026-11-25/reports/B02_atlas_impl.md:63-75,81-162,168-179` | Runtime texture bypasses `.import`; mip chain must be attached on CPU; level 0 byte-identical; masks keep `filter_nearest` | [O] |
| E13 | `variant3d/tools/donor_gen.py:49-59` | Donor constants as used by the shipped preview: `C_WATER=-1.1`, `C_PLATEAU=2.964`, `C_HILL=2.964/2.25`, `C_RAVINE=-2.964`; circles `(5,7),(12,15),(22,18)`, mine rings `(14,22),(32,42),(50,62)`, `DONOR_UNITS=160` | [O] source-cited (second-hand), **[U]** as raw donor bytes this pass |
| E14 | `variant3d/shaders/water3d.gdshader:26,33-34` | `water_level=-0.25` (`texturemap.inc:30`), `shore_height=-0.1` (`:31`), `max_height=2.96` (`:29`) | [O] source-cited, **[U]** raw |
| E15 | `variant3d/tools/donor_gen.py:21` + `CREDITS.md:38` | Generator mechanism resides in `data/scripts/common.inc/{generatemap.inc,dogenerate.inc}` and `data/game/var/generator.cfg` TerrainTypes; charter adds `gen/*.cfg` (globalparams/localparams/mapshot/tilesmooth) as F03 scope | [O]/[I] |
| E16 | `docs/terrain_swarm_2026-11-25/reports/FOLD_05_all_folders.md:212-228,244-247` | Organization precedent: derived assets get a deterministic bucket rule + manifest `assets` res:// map; resolver first, move second; **37/262** count arithmetic correction | [O]/[D] |
| E17 | `docs/terrain_swarm_2026-11-25/reports/P02_draw_calls.md:23-38,149-157` | Terrain is ONE indexed ArrayMesh / ONE draw call; do not chunk it; atlas texture is bound via one sampler | [O] |
| E18 | `variant3d/CREDITS.md:125-130` | All converted outputs are DERIVED; donor `.osm/.oss/.dds/.aaf` stay read-only in private install; private use only, never redistribute | [O] |

## 2. Design

### 2.0 Invariants (binding on whoever implements this)

1. **One-way.** Donor root is an input argument only. No tool writes under `$COSSACKS3_DIR`. No tool emits a donor file with donor bytes.
2. **Disjoint output.** All writes go under `variant3d/assets/terrain_new/**` (plus optional read-only `inbox/` validation logs). Legacy `terrain/` is read as *converted input* where noted, never edited.
3. **No fabrication.** A field that cannot be decoded is `null` + `label: "UNVERIFIED"`, never a guessed constant, never synthetic noise (CHARTER.md:84, S-25-09), never a lowered gate.
4. **Determinism.** Same donor bytes + same tool version + same `--pack` ⇒ byte-identical outputs. Stable sort, no timestamps in derived JSON, `ensure_ascii=False`, explicit newline, sha256 recorded.
5. **Parity guard.** Every manifest carries `"visual_parity_claim": false`.

### 2.1 (1) Donor inputs to read, and the read-only decoders needed

All paths are relative to `$COSSACKS3_DIR` (default `C:\Games\Cossacks 3`, `build_tile_index_atlas.py:90`). Read with `open(...,'rb')` / latin-1 text; **never execute**.

| Input | Purpose | Decoder / precedent | Proven layout status |
|---|---|---|---|
| `data/pattern/pattern.lib` (~112 `BaseName=terrainmeshN` records; ~30 MB family in charter) | Object lists: `BaseName`, `Scaling`, `Position`, `Direction` per object; terrainmesh selection | `variant3d/tools/decode_donor_pattern_new.py` (new); reuse the record walk behind `mountain_props.json:3-17` and `CREDITS.md:121-124` | Header/record fields **[O]** for `terrainmeshN`; full record boundary map **[U]** (F02 owns) |
| `data/pattern/<name>.pattern` (e.g. `hil1`, `g_mnt_3`, `f_plt_big_1`, `mng_1`) | (a) occupancy mask, (b) relief float grid to stamp into height, (c) object list | Same tool; prefix proven at `donor_gen.py:74-85`; float-grid/object tail **[U]** (F01/D05 own) | `int32 w,h + w*h` bytes **[O]**; tail **[U]** — decoder MUST refuse to guess and emit `UNVERIFIED` slots |
| `data/game/var/generator.cfg` | TerrainTypes, per-family `Freq`, family→pattern names | `decode_donor_cfg_new.py` (new); parser shape reused from `donor_gen.py:97-129` | `Name/Pattern/Freq` lines **[O]**; other sections **[U]** |
| `data/gen/*.cfg` (globalparams, localparams, mapcover, tilesmooth*) | thresholds, frequencies, counts | Same tool, `--cfg-dir data/gen`; all constants land in `cfg/constants.json` with per-line evidence | **[U]** until F03 decodes; emit observed key/value strings only |
| `data/gen/terrainmasks/<type>/Xpl_mask_<type>_<n>_gauss.tga` | R relief / G forest-stone / B water / white start | `decode_donor_mask_new.py` (new); RGB decode + start-dot connected components from `import_donor_masks.py:40-64,92-103` | Channels **[O]**; gauss variants carry water only (`import_donor_masks.py:7-9`) **[O]** |
| `data/terrain/ref/reftile.mat`, `reftilealpha.mat`, `reftile.lib` | Alpha carrier bindings, `bmTransparency`, face refkeys | `build_terrain_new_atlas.py` (new) reading the *converted* alpha PNGs per `build_tile_index_atlas.py:93-100,224-265` | Evidence lines **[O]**; donor packing engine-side/UNVERIFIED (`:35`) |
| `data/scripts/common.inc/{texturemap.inc,generatemap.inc,dogenerate.inc}` | season suffix rule, height thresholds, stamp/keep-clear constants | `decode_donor_cfg_new.py --scripts` (text-only regex, values recorded with line numbers) | Lines cited in E9/E13/E14 **[O]** second-hand; re-read **[U]** |
| `data/terrain/tiles/{terrain.presets,tiles.mat,textures/*.dds}` | index dictionary and block art | `build_terrain_new_atlas.py` consumes already-converted `variant3d/assets/terrain/blocks/*.png`; direct DDS read only if a block is missing → `UNVERIFIED` cell | `:136-178` **[O]** |
| donor screenshots / almanac | visual acceptance target only (not a decoder input) | read-only human comparison; no A/B claim | **[U]** |

**Read-only helper contract.** Every decoder exposes `--dry-run` (default) that prints `source path:offset → output path → sha256 → label` and writes nothing; writing requires explicit `--out`. All tools accept `--game`, `--pack terrain_new_v1`, `--check`, and refuse `--out` inside the donor root.

### 2.2 (2) Exact output assets under `variant3d/assets/terrain_new/**`

```
variant3d/assets/terrain_new/
├── manifest.json                          # root provenance + schema version + pack id
├── schemas/v1.schema.json                 # JSON-Schema for the four JSON classes below
├── atlas/
│   ├── tile_index_atlas.png               # compact, commit-safe (see §2.2.1)
│   ├── tile_index_atlas.manifest.json     # grid/layout/provenance (V7-85 schema)
│   ├── alpha.png                          # 512x256, mode L
│   ├── alphavert.png                      # 1024x512, mode L
│   └── seasons/
│       ├── winter_aliases.json
│       ├── tile_index_atlas_winter.png
│       ├── tile_index_atlas_winter.manifest.json
│       └── desert_aliases.json            # [U] until F10 confirms desert season set
├── patterns/
│   ├── family_index.json                  # family -> [pattern ids, weights, source line]
│   └── families/
│       ├── hills_dark.json                # float grids + object lists
│       ├── hills_light.json
│       ├── mountains.json
│       ├── plateau_big.json
│       ├── forests_pine_big.json
│       ├── mng.json / mni.json / mnc.json
│       └── ... (one file per stamped family in export_donor_patterns.py:84-103)
├── masks/
│   ├── mask_index.json                    # type -> mask entries + starts + water
│   └── height/
│       ├── land/4pl_mask_land_0_gauss.height.png       # 8-bit or 16-bit derived height tile
│       ├── land/....height.png
│       ├── nowater2/...
│       ├── mediterranean/...
│       └── peninsulas/...
└── cfg/
    ├── constants.json                     # donor literals + path:line evidence
    └── config_strings.json                # unparsed donor cfg lines, [U] where undecoded
```

#### 2.2.1 Atlas — sizing decision **[D]**

The shipped atlas is 16384×8192 / 179,912,941 B (E8/E10) and is **not commit-safe**. For `terrain_new` the default `--cell` is **256** with the **same 124-name index dictionary and 16×8 grid** (cell count unchanged), i.e. 4096×2048 RGBA ≈ 32 MB before PNG compression — still large. **[D]** Recommended committed default: `--cell 128` → 2048×1024 RGBA (≈8 MB raw, few MB deflated), with `--cell 1024` available as a *local, uncommitted* high-res regeneration for capture work. The atlas manifest keeps the V7-85 keys (`version, generator, labels, atlas{size,cell_size,grid,slots,named_cells,filled_cells,empty_cells,packing_label}, index_dictionary, layout[], masks, shipped_tileblock, visual_parity_claim`) and adds `"resolution_tier": "commit_default|local_hires"`. **The 124 names still map `index i → cell i`; no index remapping is invented** (E8). `[U]` Whether downsampled cells preserve donor texel detail is UNVERIFIED without A/B; label `APPROX_ATLAS_DOWNSAMPLE`.

#### 2.2.2 Per-family pattern JSON schema **[D]** (new; extends E2/E3)

```json
{
  "schema": "terrain_new/pattern-family/v1",
  "pack": "terrain_new_v1",
  "family": "hills_dark",
  "source": "C:/Games/Cossacks 3/data/pattern/*.pattern + data/game/var/generator.cfg",
  "source_sha256": "<sha256 of the concatenation policy documented in root manifest>",
  "donor_units": 160.0,
  "labels": ["DONOR_OCCUPANCY [O]", "DONOR_FLOAT_GRID [U until D05/F01 decode]",
             "DONOR_OBJECT_LIST [D from pattern.lib terrainmesh records]", "PORT APPROXIMATION"],
  "patterns": {
    "hil1": {
      "w": 0, "h": 0,
      "weight": 1.0,
      "occupancy_cells": [[-2, 0], [0, 1]],
      "relief_float_grid": null,
      "relief_grid_shape": null,
      "relief_label": "UNVERIFIED — tail layout not yet decoded",
      "objects": [
        {"base_name": "terrainmesh2", "position": [0.0,0.0,0.0],
         "scaling": [0.4531,0.4531,0.4531], "direction": [1.0,0.0,0.0],
         "source": "data/pattern/pattern.lib:<line|offset>", "label": "DONOR_OBJECT [O]"}
      ],
      "provenance": [
        {"source": "data/pattern/hil1.pattern", "offset": "0x00..0x07",
         "field": "w,h", "output_sha256": "<...>", "label": "[O]"},
        {"source": "data/pattern/hil1.pattern", "offset": "0x08..<8+w*h>",
         "field": "occupancy", "output_sha256": "<...>", "label": "[O]"},
        {"source": "data/pattern/hil1.pattern", "offset": "<tail>",
         "field": "relief_float_grid", "output_sha256": null, "label": "UNVERIFIED"}
      ]
    }
  },
  "weight_policy": "Freq from generator.cfg; first definition wins (donor_gen.py:115-117)",
  "visual_parity_claim": false
}
```

- `relief_float_grid` is a **row-major float array** `[float]` of length `grid_h*grid_w` plus `relief_grid_shape=[grid_h,grid_w]`; values are the raw decoded donor floats **with no scale factor invented**. If the decoder cannot prove the grid start/stride, both fields stay `null` and the label is `UNVERIFIED`. This is the deliberate hand-off slot for F01/D05.
- `occupancy_cells` reuse the centred `(dx,dy)` convention of E2 (`x - w//2`, `y - h//2`) so the Godot stamper can use the same footprint test.
- `objects` are kept as raw donor units (E4: scaling is placement data, never baked into meshes) with `base_name` resolved against `terrainmeshN` / `terrainmeshdesertN`; engine-side runtime selection stays `PORT APPROX` (E5).

#### 2.2.3 Mask-derived height tiles **[D]**

`masks/height/<type>/<stem>.height.png` — single-channel PNG, size = donor TGA size, value = decoded R relief channel *before* any blur/smooth (D03 owns the blur; A03 only *derives and labels* the tile). Producer writes a companion record in `mask_index.json`:

```json
{"type":"land","file":"land/4pl_mask_land_0_gauss.height.png",
 "source":"data/gen/terrainmasks/land/4pl_mask_land_0_gauss.tga",
 "source_sha256":"<...>","output_sha256":"<...>",
 "channel":"R","size":[0,0],
 "starts":[[0.65,0.12187]],"water_fraction":0.0199,
 "label":"DONOR_CHANNEL [O]; height mapping ENGINE/UNVERIFIED (D03/D05)",
 "visual_parity_claim":false}
```

G/The `water_fraction` and `starts` schema are inherited verbatim from E7 so the new module needs no new parser. **`nowater2` remains a separate type** (E6), never merged into `land`.

#### 2.2.4 Season variants **[D]/[O]**

- `summer` = default atlas (index-preserving 124-name dictionary, E8).
- `winter` = `winter_aliases.json` + `tile_index_atlas_winter.png` + manifest; one-for-one rename at the same preset index (E9); the shared alpha masks are reused unchanged; the three alpha carrier indices stay EMPTY/transparent exactly as in summer (E9).
- `desert` = `desert_aliases.json` with `desert_*` family patterns; **[U]** until F10/DLC scope confirms. If unconfirmed, emit an empty aliases object with `status:"UNVERIFIED — no season swap emitted"` and do **not** fabricate a texture.
- All seasons preserve `index → cell i`, so the shader's `floor(abs(tile))` patch rule needs no edit (E9).

#### 2.2.5 Root provenance manifest schema **[D]** (the core of requirement 3)

```json
{
  "schema": "terrain_new/manifest/v1",
  "pack": "terrain_new_v1",
  "generator": "variant3d/tools/build_terrain_new_manifest.py",
  "tool_versions": {"decode_donor_pattern_new.py": "1.0", "...": "1.0"},
  "donor_root_policy": "$COSSACKS3_DIR (value NOT recorded as an absolute path in committed output)",
  "inputs_never_committed": ["data/pattern/pattern.lib","data/pattern/*.pattern",
    "data/gen/terrainmasks/**/*.tga","data/terrain/ref/*.bmp","data/terrain/tiles/textures/*.dds",
    "data/game/var/generator.cfg","data/gen/*.cfg"],
  "entries": [
    {"source":"data/pattern/hil1.pattern","offset":"0x08..0x27",
     "output":"patterns/families/hills_dark.json#patterns.hil1.occupancy_cells",
     "source_sha256":"<...>","output_sha256":"<sha256 of emitted asset file>",
     "label":"[O] DONOR_OCCUPANCY","decoder":"decode_donor_pattern_new.py v1.0"}
  ],
  "asset_index": {"atlas":"atlas/tile_index_atlas.png",
    "atlas_manifest":"atlas/tile_index_atlas.manifest.json",
    "pattern_families":"patterns/family_index.json",
    "height_tiles":"masks/mask_index.json","cfg":"cfg/constants.json"},
  "counts": {"named_cells":124,"season_variants":2,"families":41,"height_tiles":0},
  "labels_used": ["[O]","[D]","[I]","[U]","PORT APPROXIMATION"],
  "visual_parity_claim": false
}
```

**Naming/versioning rule (DERIVED).** Filenames are lowercase ASCII, stem = donor stem, extension denotes the *converted* kind; no donor path is embedded in a filename. `pack` (`terrain_new_v1`, `v2`, …) bumps when a schema field or a decoder changes; schema files are frozen inside `schemas/vN.schema.json`. `output_sha256` is computed over the emitted file bytes (not the in-memory object) with 1 MiB streaming chunks (`pack_tile_atlas_split.py:76-85`), so a clone can verify without the donor. A manifest `output` pointing to `#field` is documented as "hash of the containing file" — field-level hashes are only recorded when a tool emits that field as its own file.

### 2.3 (4) How the Godot loader consumes `terrain_new` at runtime

1. **Atlas** — construct the existing loader with overrides; no new loader code needed for atlas I/O:
   ```gdscript
   var atlas := TileAtlasLoader.new({
       "tile_atlas_mode": "single",
       "single_atlas_path": "res://assets/terrain_new/atlas/tile_index_atlas.png",
       "manifest_path": "res://assets/terrain_new/atlas/tile_index_atlas.manifest.json"
   })
   atlas.load()
   ```
   (`tile_atlas_loader.gd:99-118` accepts a config dict; `:66-77` defines the override keys; `:174-205` is the stable entry point.) `ProjectSettings terrain/tile_atlas_mode` remains a last-resort config (`:110-113`). The material binds `get_atlas_texture()` to the `tile_atlas` sampler exactly as today (`B02_atlas_impl.md:46-50`); masks bind `alpha_atlas`/`alphavert_atlas` (`:48-50`).
2. **Fallback chain** — unchanged and observed: if `single` is missing (e.g. LFS clone), the loader warns and tries `split`, then `array` (`tile_atlas_loader.gd:186-200`). **[D]** For `terrain_new` the committed default is `single` with a compact atlas, so fallback should rarely fire; if `split` is used, reassembly must go to `user://` with sha256 verification (`pack_tile_atlas_split.py:260-264`) and never write `res://`. `array` mode must consume the **terrain_new** manifest layout (124 names × 16×8) rather than the legacy 121-layer array — **[U]** until an implementation pass updates `_load_array()`; until then `array` falls back to legacy layout with an explicit warning.
3. **Mips** — apply B02's `_prepare_atlas_image()` before `ImageTexture.create_from_image()` in both single and split paths (`B02_atlas_impl.md:113-119,149-162`); level 0 stays byte-identical, so the fallback and tile-index mapping are unchanged (`:169`, `:225-226`).
4. **Patterns / heights / cfg** — a thin new index script (design name `terrain_new_assets.gd`, implementation owned by another worker) loads `res://assets/terrain_new/manifest.json`, validates `schema == terrain_new/manifest/v1` and `pack`, then exposes `get_family(name) -> Dictionary`, `get_height_tile(type,stem) -> Image`, `get_constants() -> Dictionary`, `get_season_aliases(season) -> Dictionary`. It must skip any entry labelled `UNVERIFIED` rather than approximating it.
5. **Terrain mesh** — keep ONE indexed ArrayMesh / ONE draw call (E17); derived height tiles feed the vertex buffer, they do not create per-tile nodes.
6. **Season switch** — swap only the atlas manifest/aliases for the season; because the index dictionary is identical, no shader edit (E9).

### 2.4 (5) Licence guard — never commit vs safe

| Never commit (donor bytes or verbatim derivatives of donor art) | Safe to commit (derived, labelled) |
|---|---|
| `pattern.lib`, any `*.pattern`, `data/gen/**/*.tga`, `data/terrain/ref/*.bmp`, `data/terrain/tiles/textures/*.dds`, any donor `.exe`, donor `*.cfg` verbatim | `patterns/families/*.json` (decoded float grids + object lists + provenance), `patterns/family_index.json` |
| The **179,912,941-byte** `tile_index_atlas.png` (E10); its lossless `.partNNN` byte splits are the *same donor art* and must be treated identically — keep uncommitted or LFS, never reconstruct in `res://` at edit time | Compact commit-tier atlas + manifest + small alpha masks (derived from already-converted block PNGs per E8) |
| Any file whose bytes equal donor bytes (hash-check against `inputs_never_committed`); any absolute private install path recorded as a fact | `masks/height/*.height.png` (derived single-channel tiles), `mask_index.json`, `cfg/constants.json` with `path:line` evidence |
| Winters/desert donor DDS or unaliased donor PNGs; generated art for EMPTY cells (E8 `:38-40`) | `manifest.json` with source path:offset → sha256 → label, `schemas/v1.schema.json`, tool source code, validation logs under `inbox/` |
| A donor GPU capture presented as proof, or a "parity achieved" claim without one | Honest UNVERIFIED / PORT APPROXIMATION labels, validation checklists, `visual_parity_claim:false` |

Precedent: `CREDITS.md:125-130` — converted outputs are derived assets, donor binaries stay in the private install, private use only, never redistribute. No donor file is copied or executed (CHARTER.md:67-69).

### 2.5 Concrete Python tools and CLI signatures (design; no code written)

| Tool (new unless marked) | CLI | Writes |
|---|---|---|
| `variant3d/tools/decode_donor_pattern_new.py` | `python variant3d/tools/decode_donor_pattern_new.py --game PATH --out variant3d/assets/terrain_new/patterns --pack terrain_new_v1 [--only FAMILY] [--dry-run] [--check]` | `patterns/families/*.json`, `patterns/family_index.json` |
| `variant3d/tools/decode_donor_cfg_new.py` | `python variant3d/tools/decode_donor_cfg_new.py --game PATH --cfg data/game/var/generator.cfg --gen-cfg-dir data/gen [--scripts] --out variant3d/assets/terrain_new/cfg --pack terrain_new_v1 [--check]` | `cfg/constants.json`, `cfg/config_strings.json` |
| `variant3d/tools/decode_donor_mask_new.py` | `python variant3d/tools/decode_donor_mask_new.py --game PATH --out variant3d/assets/terrain_new/masks --pack terrain_new_v1 [--types land,nowater2,mediterranean,peninsulas,islands,continents] [--dry-run] [--check]` | `masks/height/**/*.height.png`, `masks/mask_index.json` |
| `variant3d/tools/build_terrain_new_atlas.py` | `python variant3d/tools/build_terrain_new_atlas.py --game PATH --out variant3d/assets/terrain_new/atlas --pack terrain_new_v1 --cell 128 [--season summer,winter] [--check]` | atlas PNG(s), manifests, alpha masks, season aliases |
| `variant3d/tools/build_terrain_new_manifest.py` | `python variant3d/tools/build_terrain_new_manifest.py --out variant3d/assets/terrain_new/manifest.json --pack terrain_new_v1 --inputs <decoder-log,...> [--check]` | root `manifest.json` |
| `variant3d/tools/validate_terrain_new.py` | `python variant3d/tools/validate_terrain_new.py --root variant3d/assets/terrain_new --manifest ... [--strict] [--emit inbox/terrain_new_validation.json]` | validation log only (no asset writes) |
| Reuse (unchanged, read-only) | `python variant3d/tools/build_tile_index_atlas.py --check`, `python variant3d/tools/pack_tile_atlas_split.py --check --measure-zip`, `python variant3d/tools/export_donor_patterns.py`, `python variant3d/tools/donor_gen.py`, `python variant3d/tools/import_donor_masks.py --game PATH` | legacy cross-checks only; never edit these tools in this wave |

All tools: `--game` defaults to `$COSSACKS3_DIR` or `C:\Games\Cossacks 3`; `--check` re-verifies hashes/sizes from committed manifests **without the donor**; `--dry-run` is the default for donor-touching tools; every write is under `variant3d/assets/terrain_new/` and refuses a donor-root destination.

### 2.6 Validation checklist — byte-compare decoded tables against known values

Run `python variant3d/tools/validate_terrain_new.py --strict`; each line is a concrete assertion. Values marked **[O]** are from repo files cited in §1; **[U]** rows must stay `UNVERIFIED` until the owning wave supplies donor bytes.

1. **[O] pattern.lib hash.** Decoder's `source_sha256` equals `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0` (`mountain_props.json:4`). Mismatch ⇒ abort; do not emit object lists.
2. **[O] occupancy round-trip.** For every family in `donor_patterns.json:1`, the decoded `occupancy_cells` list equals that file's `patterns[name].cells` (same order, same centred `(dx,dy)`), and `w*h` equals `8 + len(raw)` bytes read at `0x00..0x07` per `donor_gen.py:80-84`. Any deviation is a decoder bug, not a donor change.
3. **[O] family weights.** `family_index.json` weights equal `donor_patterns.json` families (e.g. `plateau_big` = `[[f_plt_big_1,3.0],[f_plt_big_2,3.0],[f_plt_big_3,3.0],[f_plt_mid_1,2.0],[f_plt_mid_2,2.0]]`); alias fixes `k_ravine_2→K_ravine_2` and dropped unresolvable entries logged (E2).
4. **[U] float grid.** `relief_float_grid` is `null` unless F01/D05 publish a byte-proven offset+stride; when non-null, compare decoded values against the D05 known-value table cell-by-cell (float32 little-endian assumed **only after** proof). No silent fallback.
5. **[O] object list.** `by_pattern` terrainmesh IDs in `mountain_props.json:18-50` equal the decoder's `objects[].base_name` for corresponding `desert_mnt_*` patterns; scaling values stay raw donor units (E4); `source_sha256` matches check 1.
6. **[O] atlas geometry.** `size == [COLS*cell, ROWS*cell]`, `grid == [16,8]`, `named_cells == 124`, `cell_size == [cell,cell]`, `filled+empty == slots == 128` (`build_tile_index_atlas.py:84-88,290-302`).
7. **[O] index dictionary.** Layout name at index `i` equals `presets_summer.json[i]` (`build_tile_index_atlas.py:136-143`); every id in the shipped tileblock histogram resolves (`:268-287`, `shipped_tileblock.all_resolvable == true`); `sand1`/`sand2` flagged `upscaled` when upscaling was applied (`:300-301`).
8. **[O] alpha masks.** `alpha.png` 512×256 mode `L`; `alphavert.png` 1024×512 mode `L`; donor BMP header bpp 8 / 24 respectively (`build_tile_index_atlas.py:95-100,237-255,302-309`).
9. **[O] height tiles.** For each mask entry, decoded R-channel PNG size equals donor TGA size; `starts` and `water_fraction` equal `masks/manifest.json` entries; `nowater2` not merged into `land` (E6/E7).
10. **[O] season swap.** Winter aliases count = 124, same index order as summer; alpha carrier indices 86/110/123 remain EMPTY/transparent (E9).
11. **[O] provenance closure.** Every `entries[]` has non-null `source`, `offset`, `output`, `output_sha256`, `label`; recomputed sha256 of every emitted file equals its manifest value; no `source` resolves to a committed file (licence guard §2.4).
12. **[O] no fabrication.** Every `null` field carries `label` containing `UNVERIFIED`; every dataset carries `visual_parity_claim:false`.
13. **[O] gates unchanged** (COORD only, not this agent): selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN, `app/` byte-identical (CHARTER.md:63-64,125).
14. **[U] parity.** No donor GPU A/B frame exists; visual verdict stays UNVERIFIED. Do not convert any of the above into a parity claim.

## 3. Implications

- **[D]** A03 is a **contract**, not an implementation: F01/F02/F03/F04 must resolve the `[U]` slots before the decoder can emit non-null float grids / cfg constants / object offsets. Until then, tools emit labelled holes — the pipeline is usable for the atlas and mask paths immediately, partial for patterns.
- **[D]** Because `TileAtlasLoader` already supports path overrides, the fresh module can be composed **without editing the atlas loader**, preserving B02's mip fix and the single→split→array fallback byte-for-byte (E11/E12). This reduces the integration blast radius to a new index script + module wiring (A06's scope).
- **[D]** Keeping `terrain_new` disjoint from legacy `terrain/` satisfies the charter's "fresh pipeline, not a patch" rule (CHARTER.md:119-121) and makes rollback a pointer switch (A06).
- **[D]** The compact commit-tier atlas changes only *resolution*, not the index dictionary, so tile ids/shader logic stay identical; visual fidelity is PORT APPROX and must be judged by a future capture, not assumed.
- **[D]** Provenance per field (not just per file) makes a licence audit mechanical: a single `--check` proves no donor bytes leaked into the committed pack.

## 4. Risks

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | `.pattern` float-grid / object tail guessed wrong → fabricated relief | `donor_gen.py:74-85` proves only the prefix; **[U]** tail | Emit `null`+UNVERIFIED; block on F01/D05; validation check 4 refuses non-null without a known-value table |
| R2 | `pattern.lib` 30 MB record boundaries misparsed | E4/E5 cover only `terrainmeshN` | F02 owns full map; keep `source_sha256` gate (check 1) + per-record line offsets |
| R3 | 180 MB atlas or split parts accidentally committed | E10 | `--cell 128` default; `.gitignore` guard on `*.partNNN` + `tile_index_atlas.png`; licence check 11 |
| R4 | Mip-less runtime texture reintroduces moiré | B02 §2 | Apply `_prepare_atlas_image()` in both single and split paths (B02 §3) |
| R5 | `array` mode reads legacy 121-layer layout | `tile_atlas_loader.gd:213-215` (121 layers), E11 | Explicit warning + `[U]` flag; A06/impl updates array mode to new layout before any array-mode use |
| R6 | Season/desert aliases fabricated | E9 covers winter only | Empty `desert_aliases.json` with UNVERIFIED status; F10 gate |
| R7 | Height mapping (R channel → metres) invented | E6 gives channels only; D03/D05 own mapping | Store raw decoded channel, label mapping ENGINE/UNVERIFIED, no metres-per-unit factor (E5) |
| R8 | Determinism broken by absolute paths / timestamps | FOLD-05 §6 resolver discipline | No timestamps in JSON; donor root value never recorded; stable sort; sha256 over emitted bytes |
| R9 | New tree consumed by legacy code by accident | E11 overrides are opt-in | Fresh module passes explicit paths; legacy `terrain/` defaults unchanged; COORD pointer switch only |
| R10 | Any parity claim creeping into reports/manifests | CHARTER.md:41,125 | `visual_parity_claim:false` in every emitted JSON; validation check 12 |

## 5. UNVERIFIED register

1. **[U]** Exact byte layout of the `.pattern` relief float grid and object-list tail (F01/D05).
2. **[U]** Full `pattern.lib` record boundary map beyond `terrainmeshN` (F02).
3. **[U]** `data/gen/*.cfg` (globalparams/localparams/mapshot/tilesmooth*) key semantics and constants (F03).
4. **[U]** Terrainmask channel→height mapping, gauss blur and 3-pass smoothing chain (D03).
5. **[U]** Whether the gauss TGA variants carry any R/G outside starts (prior art says no: E6) — re-verify from donor bytes.
6. **[U]** Whether downsampling to a commit-tier atlas preserves donor texel detail (no A/B).
7. **[U]** Desert season alias set / DLC terrain additions (F10).
8. **[U]** `array` mode with the new 124-name layout (no run).
9. **[U]** Any donor parity claim — no donor GPU A/B frame exists.
10. **[U]** Whether this design's tool names conflict with a file an implementation worker creates; COORD owns final naming.

## 6. Open questions

1. **COORD:** approve the new root name `variant3d/assets/terrain_new/` and pack id `terrain_new_v1` (or remap to an existing convention from FOLD-05 §3)?
2. **F01/D05:** publish the `.pattern` tail offsets and the known-value table needed for validation check 4 before the pattern decoder may emit non-null float grids.
3. **F02:** publish the `pattern.lib` record map so `offset` strings can be `path:byte-range` rather than `path:line`.
4. **F03:** decide whether `cfg/constants.json` stores raw strings only (safe) or typed values (needs decode proof).
5. **A06/COORD:** who owns `terrain_new_assets.gd` and the `_load_array()` layout update? A03 does not edit `.gd`.
6. **Owner:** commit-tier atlas cell size (128 recommended here) vs keeping the 180 MB atlas local-only at cell 1024? This is a repo-size/visual-fidelity trade-off **[I]**.
7. **COORD:** confirm `nowater2` stays a distinct mask type in `terrain_new` (A03 assumes E6's rule).
8. **A05:** confirm validation check 13's gate names/numbers are current at integration time (A03 cites CHARTER.md:63-64 without re-running).

## 7. Attestation

- Design only. **No code, asset, config, test, manifest, `.import`, shader or git edit.** No file was moved, copied or deleted.
- No donor file was opened this pass; all donor facts are **second-hand citations** from the cited repo files and are labelled accordingly.
- No Godot launched, no runner job submitted (CHARTER.md:82).
- Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md`.
- **No donor parity claim.** The pipeline, its assets and any future capture remain **PORT APPROXIMATION / UNVERIFIED** until byte proofs and a real donor GPU A/B frame land.

*End of A03 report.*
