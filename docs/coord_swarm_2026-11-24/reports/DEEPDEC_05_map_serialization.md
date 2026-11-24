---
id: DEEPDEC-05
title: "DEEPDEC-05 — donor `.map` complete section grammar, tile grid, coordinate records and entity data"
area: donor / file format / serialization / skirmish port
owner: DEEPDEC-05
date: 2026-11-24
status: RESEARCH_COMPLETE__ENTITY_DATA_CONFIRMED
verdict: "The donor `.map` is a flat Delphi/OSW length-prefixed stream with 22 unique `…Begin`/`…End` delimiters in one fixed order. Beyond the already-decoded height grid it contains: a 102,400-record × 37-byte tile-index grid whose four u8 tile ids are ordinals into `tiles.lib` (the values written by `MapGetTileIndexByTileBlock`/`SetTileIndex`); a count-prefixed array of VARIABLE-length `int32 len + 'xNyM' + 5×float32` coordinate records (the earlier 'fixed 31-byte' reading only holds for 7-char names); and a large `Players`/`GameObject` section with 7,742–12,711 typed, named, player-owned entity placements. Resource, AI and start-position SCHEMA fields are present; fog/explored data was NOT found. No donor bytes or target state were modified."
tools: "Craft Anything 0.6.1 native_bytes_find (whole-file, `path=`) + core_text_read (donor text); bounded read-only Python hexdumps/ASCII scans in the approved temp dir"
scope: "AUDIT ONLY — no donor copies, no source/asset/config/test/git edits, no target opened or selected, no runtime tools."
---

# DEEPDEC-05 — donor `.map` serialization beyond the height grid

## 0. Method and evidence discipline

Inputs read first: `DEEPDEC_CHARTER.md`, `reports/DECOMP_06_map_format.md`.
Specimens (all read-only, none copied into the repo): `bonmis1.map` (23,447,543 B),
`engmis4.map` (29,429,271 B), `battle1.map` (56,117,715 B) under
`C:\Games\Cossacks 3\data\maps\missions`.

* Craft Anything `native_bytes_find` was run **whole-file** with `path=` on `bonmis1.map`
  (no target open/select) for `GameObjectBegin`, `PlayerBegin`, `startx`,
  `TerrainMapBegin` and the little-endian pattern `49 22 00 00`.
* Craft Anything `core_text_read` was used on donor text files
  `data\scripts\common.inc\texturemap.inc` and `data\terrain\tiles\tiles.lib`.
* Read-only Python scanned int32-length-prefixed ASCII strings (the file's primitive),
  decoded record fields with `struct.unpack_from`, and printed bounded hexdumps/histograms.
  Scripts live in `%TEMP%\opencode\`, never in the repository.
* Every claim is tagged **OBS** (byte-level), **INFER** (labelled interpretation), or
  **UNV** (unproven). Evidence ids below are from this pass; DECOMP-06 ids are reused
  where they already cover a finding.

## 1. Evidence table

| id / source | Tool | Offset / path | Finding |
|---|---|---|---|
| `ev_394ceeba1d5688ac7076f6ba56ee9b26b1ba91a48c943ca1c6bbfd7acbe4f5f2` | `native_bytes_find` (whole file) | `bonmis1.map`, first `0xEBD0F0` (prefix `0xEBD0EC`) | **7,742** UTF-8 `GameObjectBegin` matches → entity placement records |
| `ev_4a062d402f1bc29c56fab6afe5e1037a6094bbab42dbe25134c046cebc3ad035` | `native_bytes_find` | `bonmis1.map`, first `0xEBCEBE` | **11** `PlayerBegin` matches |
| `ev_448d9842cff6c10de4540d8c0160b9fd91980794e6bbf1e01135339b2147cfd0` | `native_bytes_find` | `bonmis1.map` `0x18295E` | `startx` schema field (1 match) |
| `ev_b8f0b7144e694ff879386a9a88d4a4799f1a7f46b5ac17d15e7b512f9a8b6a75` | `native_bytes_find` | `bonmis1.map` `0x8D8A7D` | `TerrainMapBegin` (from DECOMP-06, re-confirmed) |
| `ev_3542d63c76dd62ced49e1369b122b8edb67dd5bdc04feda6579bb17c31ee5785` | `native_bytes_find` (pattern) | `bonmis1.map` `0xE6D612` | `49 22 00 00` = **8,777**, the named-coordinate array count prefix |
| `ev_008f0a5704e55c254bd82c8edd2bd11ac9b563857a4a524d144b7569847b4418` | `core_text_read` | `texturemap.inc:414–543` | `dirX=lh-rh`, `dirY=th-bh`, 8×45° sectors → `sandsea1/5/6`; `MapGetTileIndexByTileBlock(newtile)` → `SetTileIndex(x,y,newtex)`. Lines carry `;` comment prefix |
| `ev_410c0badb8fffe77cbbbbba7a3a8616f7ecdfc16b28b44c1caf0b3f7bd820f67` | `core_text_read` | `tiles.lib:1–220` | Ordered `TileBlockName` list; `sand1..sand4` and `rockNvf/vs` carry `Rows=2, Cols=2, TileSize=64` |
| Python (no id) | read-only scan | all three maps | delimiter enumeration, field histograms, record parse — offsets listed below |
| Repo file (no id) | read | `variant3d/assets/terrain/structs/tileblocks.json` | 245 entries; ordinal index == position. Mirrors donor `tiles.lib` order |

## 2. Complete section grammar (OBS)

The file is one flat stream of `int32 LE length + ASCII bytes` primitives; every major
block is bracketed by length-prefixed `…Begin` / `…End` strings. All three specimens
contain the **same 22 unique delimiters in the same order**; only offsets and repetition
counts differ.

| # | Delimiter | bonmis1 | engmis4 | battle1 | Notes |
|---:|---|---|---|---|---|
| 1 | `GameMapSnapShotBegin` | `0x5D` | `0x5D` | `0x5D` | 1× each; tiny |
| 2 | `GameMapSnapShotEnd` | `0x79` | `0x79` | `0x79` | 1× |
| 3 | `GameMapRecordBegin` | `0x8F` | `0x8F` | `0x8F` | 1×; ~1.58 MB heterogeneous record stream |
| 4 | `GameMapRecordEnd` | `0x1820D9` | `0x1434D1` | — | 1× |
| 5 | `GameMapBegin` | `0x1820ED` | `0x1434E5` | — | 1×; player names, `project.main.prj`, type schemas |
| 6 | `ResourceBegin` | `0x8D839A` | `0x8A2E03` | — | 1×; `.\data\resources\resource.lib` at `+0x1D` |
| 7 | `ResourceEnd` | `0x8D8A6A` | `0x8A34D9` | — | 1× |
| 8 | `TerrainMapBegin` | `0x8D8A79` | `0x8A34E8` | `0x1CE1CCA` | 1×; string starts `+4` |
| 9 | `MergeCameraBegin` | `0xE6A4D1` | `0xE34F40` | `0x24E6920` | 1×; **inside** terrain block |
| 10 | `MergeCameraEnd` | `0xE6A6B9` | `0xE350B6` | — | 1× |
| 11 | `MergeModulesBegin` | `0xE6A7D8` | `0xE351D5` | `0x24E6BB4` | 1×; contains `zone0..zoneN` + `_scenario_AIRegionOnInclude/OnDeclude` scripts |
| 12 | `MergeModulesEnd` | `0xE6D5EF` | `0xE76B39` | — | 1× |
| 13 | `TerrainMapEnd` | `0xEAF4AB` | `0xE8BB44` | `0x2543151` | 1× |
| 14 | `EnvironmentBegin` | `0xEAF4BC` | `0xE8BB55` | `0x2543162` | 1×; clouds.weather + `soft1/2/3` grid |
| 15 | `EnvironmentEnd` | `0xEBCE81` | `0xE99407` | — | 1× |
| 16 | `PlayersBegin` | `0xEBCE93` | `0xE99419` | — | 1× |
| 17 | `PlayerBegin` / `PlayerEnd` | 11 / 11; first `0xEBCEBA` | 11 / 11; first `0xE99440` | 13 / 13 | one per faction/slot incl. extra neutral slots |
| 18 | `GameObjectBegin` / `GameObjectEnd` | **7,742 / 7,742** | **12,711 / 12,711** | **10,118 / 10,118** | entity placements (§5) |
| 19 | `PlayersEnd` | `0x165C77A` | `0x1C10D9A` | — | 1× |
| 20 | `GameMapEnd` | `0x165C7E9` | `0x1C10E09` | — | 1×; file ends soon after |

Terrain block sizes (string-to-string): bonmis1 **6,122,034 B**, engmis4 **6,194,780 B**,
battle1 **8,787,079 B**. Players block (bonmis1 `0xEBCE93..0x165C77A`) ≈ **7.98 MB** —
this, not the terrain block, dominates the file and is where most entities live.

### 2.1 Terrain block internal order (bonmis1; engmis4 mirrors it)

| Region | bonmis1 offsets | Size | Status |
|---|---|---:|---|
| `int32` header: width=320, height=320, sub-tiles=4, tile-size=64 | `0x8D8A8C..0x8D8A97` | 16 B | OBS (first two); INFER (labels of 4/64) |
| Sparse / near-zero region | `0x8D8A9C..0xA68AC4` | 1,638,441 B (90.6 % zero bytes) | **UNV** |
| 2nd `int32 320,320` header | `0xA68AC5..0xA68ACC` | 8 B | OBS |
| `float32[102400]` height grid | `0xA68ACD..0xACCACC` | 409,600 B | OBS (DECOMP-06) |
| Post-grid float run (639 f32, −1.1…+2.964) | `0xACCACD..0xACD4C8` | 2,556 B | **UNV** |
| 102,400 × 37 B tile records | `0xACD4C9..0xE6A4C8` | 3,788,800 B | OBS (§3) |
| `MergeCamera` + `MergeModules` block | `0xE6A4D1..0xE6D5EF` | ~0x131 B + large bodies | OBS |
| named-coordinate array (count + variable records) | `0xE6D612..0xEAF4AA` | 274,249 B | OBS (§4) |

Grid dimensions: bonmis1/engmis4 = **320×320** (two `40 01 00 00 40 01 00 00` headers);
battle1 = **384×384** (headers `80 01 00 00` at `0x1CE1CDD` and `0x1F21D16`). Readers must
not hard-code 320 — read the first repeated dimension pair after `TerrainMapBegin`.

## 3. The 37-byte tile/attribute record — full decode (OBS + INFER)

102,400 records, stride 37, starting immediately after the height grid
(bonmis1 `0xACD4C9`, engmis4 `0xA97F38`). Per-byte histograms over all 102,400 records:

| Bytes | Type | Observed values | Read |
|---:|---|---|---|
| 0–4 | 5×u8 | constant `00` in **all** records | OBS; reserved/zero |
| 5–6 | 2×u8 | `FF FF` in 102,399/102,400; zero only in record 0 | OBS; INFER "valid/initialised" marker |
| 7 | u8 | constant `00` | OBS |
| 8–11 | 4×u8 | 43 distinct values in bonmis1 (0–98), 50 in engmis4 (0–101); identical byte set in all four positions | OBS; **tile indices** (below) |
| 12 | u8 | all 256 values, near-uniform (top `0xE0` ×475) | OBS; INFER per-cell variation/seed/checksum |
| 13–15 | 3×u8 | constant `00` | OBS |
| 16–31 | 4×float32 LE | `1.0f,1.0f,1.0f,1.0f` in **every** record (1 distinct quad) | OBS; INFER equal 4-subtile blend weights |
| 32–36 | 5×u8 | constant `00` | OBS |

Concrete records:

```
bonmis1 rec[0] @0xACD4C9: 00 00 00 00 00 00 00 00 00 4F 4F 4F B2 00 00 00
                          00 00 80 3F ×4  00 00 00 00 00
                          → tile ids (0,79,79,79) = grass1, test8, test8, test8; byte12=0xB2
bonmis1 rec[1] @0xACD4EE: ids (79,79,79,79) = test8×4; byte12=0x59
engmis4 rec[0] @0xA97F38: ids (10,73,10,10) = ground1, test2, ground1, ground1; byte12=0x79
```

**Index → tile name mapping is OBSERVED, not guessed.** The ordina positions of
`TileBlockName` in donor `tiles.lib` (mirrored by repo `tileblocks.json`) match every
index seen: `0=grass1, 10=ground1, 25=sand9, 26=rock1, 78=test7, 79=test8, 86=alpha0a,
93=sandsea1, 97=sandsea5, 98=sandsea6, …`. Top bonmis1 values: `0`×25,030,
`79`×12,187, `78`×9,864, `25`×7,305. No winter (`_winter`) tile name appears in either
specimen — consistent with summer missions; the mapping is unproven for winter maps.

### 3.1 Relation to `texturemap.inc` (INFER, grounded in OBS)

`texturemap.inc:426–445` computes a per-cell aspect vector (`dirX=lh-rh`, `dirY=th-bh`,
normalise, `VectorAngle`, sign flip on `dirY<0`); `:474–511` folds it into 8×45° sectors
and picks `sandsea1/5/6`; `:557–608` picks `rockN` on cliff cells; each branch ends
`MapGetTileIndexByTileBlock(newtile)` → `SetTileIndex(x,y,newtex)`. The four u8 indices in
bytes 8–11 are therefore **the stored output of that pipeline**: ordinals returned by
`MapGetTileIndexByTileBlock`, one per 2×2 sub-tile (header field `4`; `tiles.lib`
`Rows=2, Cols=2, TileSize=64` for the affected families). The four constant `1.0f`
weights are consistent with equal blending of the four sub-tiles. **The runtime meaning of
"four indices per cell" and of the weights is INFERRED**; only the index→name ordinal
mapping and the byte layout are proven here.

## 4. Named coordinate records — variable length (OBS; correction to DECOMP-06)

DECOMP-06 described "8,777 records × 31 bytes". That is only true for 7-character names.
The real grammar is:

```
int32 count                       // e.g. 0x2249 = 8777 at bonmis1 0xE6D612
repeat count times:
    int32 nameLen                 // 3..8 observed
    ASCII name  "x<idx>y<idx>"    // exactly nameLen bytes
    float32 f0 = 2.0              // constant in every record of all 3 maps
    float32 f1 = 2.0              // constant
    float32 f2 = -0.5             // constant
    float32 worldX                // = 2*idxX - (N-1)
    float32 worldY                // = 2*idxY - (N-1)
    // record size = 4 + nameLen + 20  => 27..32 bytes, NOT fixed 31
```

`native_bytes_find` pattern evidence: count prefix `49 22 00 00` at `0xE6D612` (id above).
Counts verified by variable-stride parse ending exactly at `TerrainMapEnd`:

| Map | count prefix offset | count | name lengths | record strides | N (coarse grid) |
|---|---|---:|---|---|---:|
| bonmis1 | `0xE6D612` | 8,777 | 6/7/8 (`2455/5981/341`) | 30/31/32 | 160 |
| engmis4 | `0xE76B5C` | 2,832 | 5/6/7 (`117/1570/1145`) | 29/30/31 | 160 |
| battle1 | `0x24EF77C` | 11,279 | 3/4/5/6/7 | 28–32 | 192 |

Twenty concrete records (bonmis1, first 20; offsets are the `int32 nameLen` field):

| # | offset | name | (f0,f1,f2) | worldX, worldY |
|---:|---|---|---|---|
| 0 | `0xE6D616` | x129y19 | (2.0,2.0,−0.5) | 99, −121 |
| 1 | `0xE6D635` | x130y19 | " | 101, −121 |
| 2 | `0xE6D654` | x131y19 | " | 103, −121 |
| 3 | `0xE6D673` | x132y19 | " | 105, −121 |
| 4 | `0xE6D692` | x133y19 | " | 107, −121 |
| 5 | `0xE6D6B1` | x136y19 | " | 113, −121 |
| 6 | `0xE6D6D0` | x137y19 | " | 115, −121 |
| 7 | `0xE6D6EF` | x138y19 | " | 117, −121 |
| 8 | `0xE6D70E` | x139y19 | " | 119, −121 |
| 9 | `0xE6D72D` | x140y19 | " | 121, −121 |
| 10 | `0xE6D74C` | x141y19 | " | 123, −121 |
| 11 | `0xE6D76B` | x128y20 | " | 97, −119 |
| 12 | `0xE6D78A` | x129y20 | " | 99, −119 |
| 13 | `0xE6D7A9` | x130y20 | " | 101, −119 |
| 14 | `0xE6D7C8` | x131y20 | " | 103, −119 |
| 15 | `0xE6D7E7` | x132y20 | " | 105, −119 |
| 16 | `0xE6D806` | x133y20 | " | 107, −119 |
| 17 | `0xE6D825` | x134y20 | " | 109, −119 |
| 18 | `0xE6D844` | x135y20 | " | 111, −119 |
| 19 | `0xE6D863` | x136y20 | " | 113, −119 |

Cross-map examples: engmis4 `x122y0 @0xE76B60 → (85,−159)`; battle1 `x0y0 @0x24EF780 →
(−191,−191)`, `x1y0 @0x24EF79C → (−189,−191)`. The identity
`worldX = 2*idxX − (N−1)`, `worldY = 2*idxY − (N−1)` holds for **all** records in all three
maps (0 mismatches). **No flag field was observed** beyond the constant triplet; the
records are a sparse subset of the N×N coarse grid (bonmis1 first rows x≈114–150, y≈19–23).
INFER: a coarse (half-resolution) coordinate/anchor layer for editor or environment
placement; exact consumer UNVERIFIED.

## 5. Entity, resource, start and AI data in `.map` (OBS unless marked)

**Entity placements: YES — high confidence.** The `Players` block holds
`GameObjectBegin … GameObjectEnd` pairs with typed, named, player-owned content.
Category histogram of the first string after each `GameObjectBegin`:

| Map | `env` | `units` | `buildings` | `misc` |
|---|---:|---:|---:|---:|
| bonmis1 | 7,306 | 396 | 39 | 1 |
| battle1 | 4,295 | 5,821 | 0 | 2 |

First bonmis1 object `@0xEBD0EC` (hexdump `0xEBD0E4..0xEBD214`) decodes as:
`GameObjectBegin`, `buildings`, `polcen`, `polcen0.15978`, `polcen`, `buildings`,
`player0`, followed by float32 fields (`−23.75`, `0.0`, `−138.75` at `0xEBD114..0xEBD120`)
and a mesh-name string `polcen.mesh @0xEBD426`. Other examples: `ukrsta0.16248`,
`eurmil0.16256`, and `units/peapol/peapol0.16697/player0 @0xEBF05F`. These are directly
usable as skirmish entity seeds; per-field semantics beyond category/type/instance/owner
are **INFER** until the object serializer is decoded.

Additional coordinate-bearing records exist in the `GameMapRecord` section: 17-byte
units `int32 26 | u8 0 | float32 x | float32 y | int32 id` (2,968 occurrences of the
`1A 00 00 00 00` prefix in bonmis1, first at `0x255`: x=−70.038, y=−86.873, id=7138;
687 in engmis4, first at `0x162`). INFER: a heterogeneous object/placement stream; the
meaning of type 26 and the id is UNVERIFIED.

**Resources: YES.** `ResourceBegin @0x8D839A … ResourceEnd @0x8D8A6A` (bonmis1) references
`.\data\resources\resource.lib @0x8D83B7`. Schema strings `resourcestart @0x1826E3`,
`resourcemines @0x182703`, `resources @0x185B35`; entity strings `minegold` from
`0x15A6CDD` onward, `smallstones*` around `0x14F13F7`. Actual resource amounts are not
isolated here (UNVERIFIED).

**Starting positions: schema YES, concrete values UNVERIFIED.** `TMapPlayer[8]` fields
`startx` (float) `@0x18295E`, `starty` (float) `@0x182971`, plus `aidifficulty`
`@0x182988`, `bexists`, `bai @0x1829C1`, `bhuman`, `bclosed`, `bready` are defined in the
`GameMap` type block. The values themselves sit in the opaque `GameMapRecord` stream and
were not separated from its many other float pairs (5,440 candidate pairs in `[-200,200]`;
e.g. `0x27C → (−66.577,−86.922)`). Do not treat any single pair as a start position
without decoding the record header.

**AI data: YES.** `TAiData @0x1834A9`, `ailist @0x183722`, `aiunit @0x183952`,
`TAIBuildingProject[12] @0x1839A8`, `TAiProtectedBuildingList @0x183449`, `bai`,
`aidifficulty`, `bhumanai @0x183A9B`, `difficulty` (several). Inside `MergeModules` there
are explicit scenario-AI trigger zones: `zone0..zoneN` each with `OnInclude` /
`OnDeclude` and scripts `_scenario_AIRegionOnInclude` / `_scenario_AIRegionOnDeclude`
(battle1 first at `0x24E6BB7`/`0x24E7441`). This is a ready-made AI region layer for the
port; its executable semantics are UNVERIFIED.

**Fog / explored: NOT FOUND (UNVERIFIED for binary).** Whole-file length-prefixed string
enumeration returned **0** matches containing `fog`, `Fog`, `explor`, `Explor`. No
per-cell explored mask was identified in the 1.64 MB sparse pre-grid region or the two
gaps; absence of the text does not prove absence of a binary fog grid.

## 6. Importer schema (concrete, with confidence labels)

```
map ::= lp("OSWMap13...") lp(uid)                         OBS
        "GameMapSnapShotBegin" data "GameMapSnapShotEnd"  OBS
        "GameMapRecordBegin"  placement_stream  "GameMapRecordEnd"  OBS / payload INFER
        "GameMapBegin"        player_names, type_schema  "GameMapEnd"(later)  OBS
        "ResourceBegin"       resource.lib ref  "ResourceEnd"       OBS
        "TerrainMapBegin"
            u32 W, u32 H, u32 subTiles/*4*/, u32 tilePx/*64*/        OBS/OBS/INFER/INFER
            unknown[byteLen(0x..)]                                   UNV
            u32 W, u32 H                                             OBS
            f32[W*H] height                                          OBS
            f32[639] border/unknown (bonmis1)                        UNV
            tile_record[W*H]:
                u8[5] zero; u8[2] flag/*0xFFFF*/; u8 zero;
                u8[4] tileIndex  -> tiles.lib ordinal               OBS + INFER(label)
                u8 variation/seed; u8[3] zero;
                f32[4] weights/*1.0f*/; u8[5] zero                   OBS
            MergeCameraBegin/End, MergeModulesBegin/End             OBS
            u32 namedCount; named[namedCount]:
                u32 nameLen; ascii name "xNyM"; f32[3]/*2,2,-0.5*/; f32 wx, wy  OBS
        "TerrainMapEnd"
        "EnvironmentBegin/End"                                       OBS
        "PlayersBegin"
            repeat playerCount: "PlayerBegin" entities... "PlayerEnd"
                entity: "GameObjectBegin"
                        lp(category) lp(type) lp(instance) lp(type) lp(owner)
                        f32[] position/rotation; strings (mesh etc.)
                        "GameObjectEnd"                              OBS (fields partly INFER)
        "PlayersEnd" "GameMapEnd"
```

Practical anchors for a future reader: `TerrainMapBegin` string → first repeated
`u32 W,u32 W` pair → **second** such pair → height grid at `+8`; 37-byte grid starts at
height-grid end; named array count is the `u32` immediately before the first `xNyM` name.

## 7. Port implications

1. **Immediate win:** the four u8 tile ids are real donor tile ids, not placeholders. A
   reader can emit a `tileblock` grid from `bytes 8..11` and name each id with
   `tileblocks.json`; this is stronger than the port's current inferred block ids.
   Choose one sub-tile (e.g. byte 8) or all four with the (constant) weights; do not
   invent a weighting rule.
2. **Entity seeds:** `Players/GameObject` records supply typed placements
   (`env`/`units`/`buildings`), instance names, owner and world floats — usable for
   skirmish initial unit/building setup and for environment props. Cross-check the float
   triplets against the coarse world scale before using them.
3. **Scale evidence:** named-record coordinates span `±159` for 320 maps and `±191` for
   384 maps with step 2 over a half-resolution grid → ~1 world unit per height cell.
   This *supports* DECOMP-06's warning that port `TILE_M = 2.0` may be 2× large, but is
   still INFER; do not change mesh scale without an in-engine A/B.
4. **AI regions** in `MergeModules` are a donor-authored trigger layer worth porting as
   data even before the script language is understood.
5. **No fog data found** — the port must keep its own fog/explored model.

## 8. UNVERIFIED / BLOCKED

1. Meaning of the 1,638,441 B sparse pre-grid region (90.6 % zero) and the 2,556 B
   post-grid float run; whether either holds fog/explored or mask channels.
2. Byte 12 of the 37-byte record (per-cell variation/seed/checksum?) and bytes 5–6
   (`0xFFFF` marker).
3. Runtime semantics of four tile indices per cell and the four `1.0f` weights.
4. `type=26` 17-byte GameMapRecord placements: object class and id meaning; the concrete
   `startx/starty` values for the 8 players.
5. Named-coordinate record consumer: what places/uses these sparse coarse-grid anchors;
   whether the `2.0,2.0,-0.5` triplet is scale/offset or something else.
6. Fog/explored binary representation (no string evidence; no grid identified).
7. Winter-tile ordinal mapping (no `_winter` indices observed in the two summer maps).
8. Height-grid row orientation and the final metre scale (`TILE_M` question).
9. Whether the donor scripts in `texturemap.inc` are active in this build — all relevant
   lines carry the `;` comment prefix (as noted by TERRAIN2-03/06); the on-disk tile ids
   are OBS regardless.

## 9. Next atomic tasks (suggestions only — no edits made here)

1. Decode the `GameObject` field layout past `player0` (one full hexdump per category:
   `env`, `units`, `buildings`) and emit a concrete record schema with offsets.
2. Type-tag census of the `GameMapRecord` stream: histogram of the leading `int32`
   at each 17-byte-aligned position to isolate `startx/starty`, resources and AI blobs.
3. Verify the sparse pre-grid region against known mask TGAs (R/G channels from
   TERRAIN2-02) to test the fog/mask hypothesis.
4. Build a read-only `.map` importer that emits height + tile-id grid + entity list,
   and A/B one donor mission against `g32_dump.json` before changing any scale constant.

## 10. Handoff statement

No donor file was copied into the repository; no target was opened or selected; no
donor code was executed; no source/config/asset/git change was made. All Python ran
from `%TEMP%\opencode\` against read-only donor paths. This is the sole report authored
by DEEPDEC-05.
