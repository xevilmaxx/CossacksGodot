# 11 — Asset conversion pipeline (from A03)

Source: `reports/A03_asset_pipeline.md` (design-only, no donor read this pass).
All claims inherit that report's labels. **PORT APPROXIMATION; no donor parity claim.**

## 11.1 Shape of the compiler [D]

One-way, offline compiler: donor install is an input argument only; **all writes
go to a new disjoint root `variant3d/assets/terrain_new/**`**. Legacy
`variant3d/assets/terrain/**` is read as converted input, never edited. No donor
byte is copied, executed or committed. Same bytes + tool version + `--pack` ⇒
byte-identical outputs (stable sort, no timestamps, sha256 in manifest).

Invariants binding on implementers (A03 §2.0):
1. No tool writes under `$COSSACKS3_DIR`; `--out` inside donor root is refused.
2. Undecodable field = `null` + `label:"UNVERIFIED"` — never a guessed constant.
3. Every manifest carries `"visual_parity_claim": false`.
4. Dry-run default: print `source path:offset → output → sha256 → label`.

## 11.2 Proven conversion routes already on disk [O]

| Route | Evidence (A03 E-ids) |
|---|---|
| TGA → PNG masks (R relief / G forest-stone / B water / white starts), `nowater2` distinct from `land` | E6 `variant3d/tools/import_donor_masks.py:1-9,31-36,78-104`; E7 `assets/terrain/masks/manifest.json:1-29` |
| `*.pattern` occupancy + `generator.cfg` family weights → JSON (41 stamped families) | E1 `tools/donor_gen.py:44-45,74-85,97-129`; E2 `tools/export_donor_patterns.py:27-38,83-103,139-158`; E3 `assets/terrain/patterns/donor_patterns.json:1` |
| Block PNG → 16×8 index atlas + alpha masks; winter = one-for-one rename | E8 `tools/build_tile_index_atlas.py:84-100,136-178,181-221,224-265`; E9 `tools/build_winter_atlas.py:20-39` |
| `pattern.lib` 112 `terrainmeshN` object records (Scaling/Position/Direction), placement not mesh | E4 `CREDITS.md:119-124`; E5 `assets/terrain/mountain_props.json:1-17` |
| Three atlas modes + path overrides already exist in Godot loader | E11 `scripts/tile_atlas_loader.gd:62-77,99-118,174-200` |
| Mip chain must be generated on CPU (`generate_mipmaps(false)` before `ImageTexture.create_from_image`) or `filter_linear_mipmap` has no levels | E12 `B02_atlas_impl.md:63-75,81-162,168-179` |

## 11.3 Still UNVERIFIED (must not be guessed)

- Relief float grid and object-record tail of each `.pattern`: prior decoders stop
  at `int32 w,h + w*h` occupancy bytes (A03 E1). Owned by **D05 / F01**.
- full `pattern.lib` record boundary map beyond `terrainmeshN` (**F02**).
- all `data/gen/*.cfg` constants as raw donor bytes (**F03**).
- desert season asset set (**F10**).
- whether downsampled atlas cells preserve donor texel detail (`APPROX_ATLAS_DOWNSAMPLE`).

## 11.4 Output layout (A03 §2.2)

```
variant3d/assets/terrain_new/
├── manifest.json                    # provenance + schema + pack id
├── schemas/v1.schema.json
├── atlas/{tile_index_atlas.png, .manifest.json, alpha.png, alphavert.png, seasons/}
├── patterns/{family_index.json, families/<family>.json}
├── masks/{mask_index.json, height/<shape>/*.height.png}
└── cfg/{constants.json, config_strings.json}
```

Atlas sizing [D]: keep the 124-name index and 16×8 grid; commit default
`--cell 128` (2048×1024, ≈8 MB raw); `--cell 1024` only as local uncommitted
high-res capture tier. **No index remapping** (A03 §2.2.1, E8). The 179,912,941 B
shipped atlas and split parts stay uncommitted/LFS (E10).

Per-family pattern JSON carries `occupancy_cells` [O], `relief_float_grid: null`
until D05/F01 decode [U], `object_list` from `terrainmeshN` [D], and explicit
labels (A03 §2.2.2).

## 11.5 Licence guard (E10/E18)

Donor `.osm/.oss/.dds/.aaf` stay read-only in the private install; only derived
assets are emitted; never redistribute. Donor binaries are never committed.

## 11.6 Validation checklist (14 byte-compares, A03 §5)

Confirm: occupancy prefix against `donor_gen.py`; family weights against
`generator.cfg`; mask channel decode against `import_donor_masks.py`; start dots;
atlas cell count/index map; level-0 byte identity; winter index rename one-for-
one; mip presence; `terrainmeshN` object counts; sha256 manifest; no donor bytes
in outputs; `--dry-run` writes nothing; determinism across two runs; parity flag
false.

---
*Integrated by COORD from A03. Contradictions with F01/F02/F03/D05 reports will be
resolved in the contradiction register in `spec/README.md`.*
