# COORD — terrain ugliness root cause, native evidence and current correction wave

Date: 2026-11-26  
Status: `PORT APPROXIMATION`; donor parity **UNVERIFIED**; no donor GPU A/B frame.

## 1. Executive finding

The poor terrain was not caused by one bad light or one bad texture. The port had
replaced several distinct donor systems with simpler approximations:

1. **One repeated tile every 2 m** instead of the donor `tsDouble` 8×8 authored
   subcell matrix (16 m selection period).
2. **A tile-id-bit alpha-patch formula** instead of the donor four-corner-tag /
   4-bit-mask / parity-LUT producer for `gl_MultiTexCoord1`.
3. **A single interpolated tile id per terrain vertex** instead of per-cell
   corner tags and per-distinct-tag layer quads.
4. **An entirely commented donor detail-bitmap routine enabled by default**,
   which painted editor/test tiles (`test6..test14`) as large terraced mazes.
5. **Incomplete field art/state handling**: one dark cut-out stage, opaque black
   background before the alpha fix, no mature/harvest/regrowth stage swaps, and
   no `envfieldd` ground decal.
6. **Relief prop placement/material approximations**: missing MTL binding caused
   white plinths; the square itself is real donor OSM geometry and must remain.
7. **A two-valued height interpretation** from decile telemetry led to the wrong
   diagnosis. The raw field has 9,164 unique heights; hard plates came from
   ignoring the `(W-1)×(H-1)` occupancy lattice and losing Smooth parameters.
   The donor zero-grid mountain interior is intentional and is integrated by
   boundary smoothing plus the terrainmesh grass-margin base.

## 2. Decisive donor evidence

### 2.1 RGB terrain is an 8×8 art matrix

`reports/DEC_VIS_01_uv_mapping.md` recovers native defaults `Rows=Cols=8`,
`TileSize=64`, `AlphaRows=8`, `AlphaCols=4`, `AlphaTileSize=64`. For the shipped
`tsDouble/ttExtended` material the producer computes:

```text
xpx = (Round(cellX + mapWidth/2) mod 8) * 64
ypx = (Round(cellY + mapHeight/2) mod 8) * 64
u0 = xpx / (8*64); v0 = ypx / (8*64)
u1 = (xpx+64)/(8*64); v1 = (ypx+64)/(8*64)
```

One selected subcell covers one 2 m map cell, but adjacent cells select different
authored art. The full selection period is **16 m**, not 2 m.

Evidence: `ev_1d5e6e860588fbda27d4e2ddf2dbcb81c186e9671e05860b9bfdd4110eeb367d`,
`ev_b2e664174e17999a7e990a22fcbd872ac88c7f39a259053d684bbf0859075438`,
`ev_58d7418c2dc5d46b793f64c408ea8a2f834ee5020be74b51d7c80968ff420221`.

### 2.2 Alpha is a four-corner mask, not tile-id arithmetic

The native producer reads four corner tags plus a random byte per cell, sorts the
distinct tags, forms a 4-bit occupancy mask, and uses the 16-entry byte-pair LUT at
`cossacks.exe:0x8f5d00`, indexed by `mask*2 + (randomByte & 1)`. It emits one quad
per distinct tag and writes both unit-0 and unit-1 coordinates per vertex.

The old port rule (`dir=id%4`, `variant=(id/4)%4`, `half=(id/16)%2`,
`opposite=(id/64)%2`) is therefore not donor semantics. Base alpha UVs use the
recovered `0.1` horizontal and `0.2` vertical insets; transition layers use zero
inset.

Evidence: `ev_58d7418c2dc5d46b793f64c408ea8a2f834ee5020be74b51d7c80968ff420221`,
`ev_e9694d0da085e0a3c3dcb0fb2d19548bbbdcffc6c3ac5fbbfad22c7e153b05db`,
`ev_224b851c846058c075204f4c3fc2ae2aa3ae859c662eb86e5fa4d9202dc7a6b2`,
`ev_696bc518d0ab6b3b28c3d5997b93c734f980524c68d7230ca5cbd2153cd30417`.

### 2.3 Runtime terrain records are multi-tile

The native reader/writer uses 24-byte plus 13-byte records per cell. The 24-byte
record starts with four corner tags and a random/variant byte. The following four
`u32` values are consumed as collision/tag data; the earlier shorthand calling
them blend weights is **not accepted**.

Evidence: `ev_aacd864e183666698d11a5ed1240d86d386792a5f47e591acf7da11fa5002e2c`,
`ev_81b6d7f69bfab58ffb072f599682c9ba8d09fb8ae611a4aafb5e2adcf1b25a82`,
`ev_a0fffbc44358b8a5f1ba5a91989641647cf547b6668b23de19bd60183bb7a0fb`.

### 2.4 Detail bitmaps are commented donor source

`loadtextureterrainfrombitmap.inc` is entirely comment-prefixed. Its bitmap ids
are editor/test art. A capture with the pass enabled produced the large regular
maze; alpha bypass restored ground visibility and isolated the maze as authored
bitmap output, not shader noise. The pass is now explicit opt-in
`features.terrain.detail_bitmap=true`, default **false**.

### 2.5 Fields have stages and a decal layer

`reports/DEC_VIS_03_fields.md` recovers `field1..4` growth, mature `field`,
`field5/6` harvest/regrowth, `field7` depletion, winter twins, and an
`envfieldd/envfielddw` decal. Crops inherit `bmAlphaTest50`, `fcNoCull`, and use
`ShaderID6`; the old port emission-energy scalar `0.22` is not a recovered donor
constant.

### 2.6 Relief squares are real geometry

`reports/DEC_VIS_02_terrainmesh.md` confirms `terrainmesh1..4` are real OSM meshes
with broad triangulated bases, lit two-sided alpha-tested materials, and
grass-margin albedo. White plinths were consistent with missing MTL binding.
Donor placement rotates record XZ by `pi-rotangle`, scales by `ObjectsScale`, adds
the stamp centre, then applies height/snap and final orientation.

## 3. Candidate A/B evidence

- `cap_donor_240j.png`: detail-bitmap output plus wrong alpha selector produced
  near-black ground.
- `ground-grid-ab/alpha-bypass3/frame_0000.png` and `frame_0023.png`: alpha bypass
  restored terrain and exposed the regular editor/test-tile maze.
- `cap_donor_240k.png`: after default-disabling the commented detail pass, the
  maze is gone; ordinary grass is visible and fields are no longer black squares.
  A regular grass sampling lattice remains, matching the missing 8×8 subcell
  selection.
- `ground-grid-ab/tile-flat/frame_0000.png`: flat tile-id output does not contain
  the grass RGB lattice, supporting sampling/repetition as the cause rather than
  generator tile-id boundaries.
- `ground-grid-ab/lod0/frame_0000.png`: finest-LOD sampling still shows the relief
  geometry/lighting problem; LOD alone is not the complete fix.

All images are candidate-internal evidence. They are not donor A/B frames.

## 4. Corrections in flight

| Worker | Scope | Purpose |
|---|---|---|
| `FIX-TERRAIN-SUBCELLS` | `terrain_donor_mesh.gd`, `terrain_donor_shader.gdshader` | Per-cell tile map texture + exact 8×8 RGB subcell selection + corrected mip derivatives |
| `FIX-FIELD-DONOR` | `world3d_entities.gd` | Donor field stage art, exact material constants, `envfieldd` decal |
| `FIX-RELIEF-STAMP` | `terrain_donor_gen.gd` | Exact donor height stamp/blend/smoothing order; remove two-valued mesa output only with proven math |
| `DEC-VIS-04` | read-only native decode | Recover how `SetTileIndex` expands one id into four corner tags + random byte |

### Landed during this wave

- `FIX-TERRAIN-SUBCELLS` is implemented and the donor atom passes. A new capture
  (`cap_donor_240l.png`) confirms the old 2 m full-tile grass lattice is gone.
  Ground is currently darker/less varied than the donor target; this is now a
  lighting/art-response question, not the former repeat-grid mechanism.
- `FIX-FIELD-DONOR` is implemented. Stage selection, exact authored RGB values,
  alpha scissor and `envfieldd` decals are present. Missing converted `field2..7`
  art is being restored by `FIX-FIELD-ASSETS`; until then stage meshes retain a
  labelled `field1` fallback.
- `FIX-FIELD-ASSETS` has now converted all 16 summer/winter crop textures and the
  field2/3 mesh variants with pixel/topology equality. Godot import and random
  mesh selection remain follow-ups.
- `FIX-RELIEF-STAMP` is implemented: `(W-1)×(H-1)` vertex-mask expansion and the
  native clear-boundary Smooth pass are restored. Raw heights were never
  literally two-valued; decile bins had hidden the intermediate values.
- Compact props now retain all **39,783** donor Objects records, including the
  three formerly excluded inline records. See
  `COMPACT_PROPS_all_records.md`.
- A new compact pattern bundle reduces the full decoded pattern/family corpus
  from **238,224,162 B to 7,525,961 B (96.841% reduction)** while preserving all
  710 available pattern grids/flags/occupancy arrays and 64 family definitions.
  Runtime integration is in progress.

## 6. Remaining unverified items

- Effective runtime eye-plane/texture-matrix binding versus explicit UV0 values.
- Exact `SetTileIndex` → four-corner-tag expansion (active `DEC-VIS-04`).
- Alpha composite pass count and full runtime layer ordering.
- Donor GPU frame parity, shore/water appearance, and runtime performance.
- Three inline prop records excluded by the compact feed policy (39,780 vs
  39,783); no silent data-loss acceptance.

No synthetic noise, dither, warp, `HEIGHT_SCALE` fudge, face promotion, weakened
test, or donor-parity claim is part of this correction wave.
