---
id: DEC-VIS-01
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-VIS-01"
title: "Donor terrain UV, tsDouble subcell, alpha-mask and sampling pipeline — native producer recovery"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__BLOCKING_ALPHA_RULE_RECOVERED
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_VIS_01_uv_mapping.md
targets:
  - "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0"
  - "C:\\Games\\Cossacks 3\\editor.exe — t_68474ddde43f"
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor executable run, copied, committed or modified. No repo code/shader/config/asset/test/git edit. No Godot job. Exactly one repo file written: this report."
---

# DEC-VIS-01 — donor terrain UV / alpha / sampling pipeline

## 0. Executive summary

1. **[D] The blocking black-ground mechanism is now identified at native-code level: the port's tile-id → alpha-patch decomposition is not the donor rule.** The donor producer uses **four per-cell corner tile tags**, reduces them to a **4-bit occupancy mask**, sorts the distinct tags, and emits **one UV quad per distinct tag**. The alpha patch comes from a 16-entry byte lookup at `cossacks.exe:0x8f5d00`, indexed by `mask*2 + (randomByte & 1)`, not by `tile_id mod 4 / /4 / /16 / /64`. The same producer emits both texture-coordinate pairs per vertex through the unit-0/unit-1 multi-texture coordinate path. Evidence: `ev_58d741…` (`sub_812e34`), `ev_e9694d…` (`FUN_00812ccc`), `ev_224b85…` (lookup bytes), `ev_696bc5…` (`sub_818428`).

2. **[D] Donor RGB terrain is an 8×8 subcell matrix for the shipped `tsDouble` / `ttExtended` ground material, not one bitmap repeated every map cell.** Native defaults are `Rows=8`, `Cols=8`, `TileSize=64`, `AlphaRows=8`, `AlphaCols=4`, `AlphaTileSize=64`. For `tsDouble`, the producer chooses the RGB subcell from **world cell coordinates modulo 8**, with the map-half offset. One subcell spans one 2 m map cell, but adjacent cells select adjacent/different art; the full 8×8 selection period is **8 cells × 2 m = 16 m**. The port's `fract(worldXZ * 0.5)` repeats the same art every **2 m**, which is the direct structural explanation for the regular grid. Evidence: `ev_1d5e6e…`, `ev_b2e664…`, `ev_58d741…`.

3. **[D] `TileXOffset=0.1` and `TileYOffset=0.2` are real normalized alpha-UV insets, not RGB repeat factors.** The native producer applies them only to the first/base alpha layer: `u += 0.1` on the left and `u -= 0.1` on the right; `v += 0.2` on the top and `v -= 0.2` on the bottom. Transition layers use zero inset. Evidence: `sub_812e34` at `0x813330–0x813345` plus `FUN_00812ccc` at `0x812ccc`.

4. **[D] The native terrain record is multi-tile.** The 24-byte record begins with four `u8` corner tags and a random byte; the following four `u32` values are consumed as the DScript `collision[4]` field, not proven blend weights. A separate 13-byte record carries four corner values, four 0/1 flags, an override/variant byte and auxiliary flags. Therefore a single `UV2.x` tile id is an incomplete port model. Evidence: reader `FUN_008302b0` (`ev_aacd86…`), writer `FUN_008305a0` (`ev_81b6d7f…`), accessors `sub_82ec5c` / `sub_82ebc0`.

5. **[D] The reported 28,235 `UV2.x != tex` violations do not by themselves prove texture corruption.** The current renderer deliberately replaces raw `tileblock` ids for cliff faces, shore sectors and desert remapping before writing `UV2.x` (`world3d_terrain.gd:1324–1407`), while the atom compares `UV2.x` against raw `traw` (`t_terrain_donor.gd:639–645`). The invariant is testing the wrong contract for those overridden cells. The black image is nevertheless consistent with the independently proven wrong alpha selector.

6. **[U] One runtime-binding contradiction remains open:** `hf.pvl.sm.vert` uses eye-plane texgen when `texGen=true`, while the native mesh producer emits explicit per-vertex UV0 subrects. The producer arithmetic is proven; whether the shipped runtime consumes those UV0 values directly, bakes them into resources, or bypasses them through `texGen` is not proven. This does not affect the alpha-channel result: `gl_TexCoord[1] = gl_MultiTexCoord1` is unconditional in the donor vertex shader.

**No donor parity claim is made.**

---

## 1. Target discipline and method

- Every native call used an explicit `document:` pin: `t_87f0f3c130b0` for `cossacks.exe`, `t_68474ddde43f` for `editor.exe`.
- No target-open/select call was made. The global active target was not changed.
- Donor binaries were inspected as bytes/disassembly only. They were never executed or copied.
- Read first: visual-wave charter, D08, F06, X17, donor-video analysis, the current `terrain_donor_shader.gdshader`, and HANDOFF §9.10–9.12. No standalone `FIX-GROUND-GRID` completion note exists on disk; HANDOFF records the COORD-supplied `uv_repeat=1.0 + LOD inset` fix and the still-visible olive grid.

### Multi-pass ledger

| Lead | Pass 1 | Pass 2 | Pass 3 | Result |
|---|---|---|---|---|
| Runtime terrain record | Deep reader `FUN_008302b0` / writer `FUN_008305a0` | Native accessors `sub_82ec5c`, `sub_82ebc0`, `sub_82ed00` | DScript `TMapTerrainDataTile` + renderer consumers | 24 B = four corner tags + random + collision[4]; 13 B = separate corner/flag record. |
| `tsDouble` defaults | `reftile.lib` text | Deep `FUN_0054428c` constructor | Deep `FUN_00544548` loader + disassembly | `8×8 / 64`; alpha `8×4 / 64`; commented `16×16` is not active. |
| Alpha patch selector | `sub_812e34` Deep pseudocode | Full disassembly `ev_58d741…` | Raw lookup bytes `0x8f5d00` + editor.exe identical bytes | Exact mask table recovered; port id-bit rule rejected. |
| UV producer / per-vertex vs per-cell | `sub_8177f0` callback installation | `sub_812e34` writes 0x48-byte per-layer records | `sub_818920` expands 0x50-byte quads; `sub_818428` emits unit0/unit1 coords | Per-cell topology, expanded to four vertices per layer. |
| RGB subcell / period | `FUN_00812b4c` | `sub_812e34` tsDouble branch disassembly | 2 m donor cell scale from `gc_meters_to_tile=2` | 8×8 world-coordinate subcell selection; 16 m macro period. |
| Eye planes / texture matrix | Donor vertex shader | `sub_4ec3f0` Deep + disassembly | Constructor matrix bytes at `0x8f4b44`; plane floats at `0x8f4aa4…` | Equations/defaults proven; effective runtime values still [U]. |
| Strange addresses `0x543b74`, `0x543eb8`, `0x4c74f0` | Initially looked like functions/VMT methods | Raw bytes + instruction reads | Deep failure / disassembly | Rejected as data/misaligned RTTI, not silently accepted as code. |
| Missing built-in functions `0x8302b0/0x8305a0`, `0x812b4c/0x812ccc` | Built-in `function_not_found` | Deep Ghidra made-on-demand / `+1` entry | Caller disassembly and byte tables | Accepted only where independent bytes/callers agree. |

---

## 2. Evidence register

| Evidence id | Label | Source | Claim |
|---|---|---|---|
| `ev_aacd864e183666698d11a5ed1240d86d386792a5f47e591acf7da11fa5002e2c` | [O]/[D] | Deep `FUN_008302b0` | Reader allocates 24 B and 13 B arrays; reads 24 B then 13 B per cell. |
| `ev_81b6d7f69bfab58ffb072f599682c9ba8d09fb8ae611a4aafb5e2adcf1b25a82` | [O]/[D] | Deep `FUN_008305a0` | Writer emits the same 24 B + 13 B record order; clears tail flag before write. |
| `ev_1448daf1ad44f13b0a25cc51de466337042c1a6d16bb11ae5a76cbe5c1f39439` | [O] | `sub_82ec5c` | Copies the 24 B record, stride `0x18`. |
| `ev_a0fffbc44358b8a5f1ba5a91989641647cf547b6668b23de19bd60183bb7a0fb` | [O] | `sub_82ebc0` | Reads four `u32` at record `+8..+0x17`. |
| `ev_723448b3c04d6ac6203e9d435fc63d5afb85fbb67b95efdb77bb73226cc43055` | [O] | `sub_82ed00` | Copies the 13 B record, stride `0x0d`. |
| `ev_1d5e6e860588fbda27d4e2ddf2dbcb81c186e9671e05860b9bfdd4110eeb367d` | [O] | Deep `FUN_0054428c` | Constructor defaults: scheme/type=1, `8×8`, tile 64, alpha `8×4`, alpha tile 64. |
| `ev_3793db5ae460039b455a8af394166e0b02da315bd2eb985d704e5b63ae9525f5` | [O] | `sub_54428c` disassembly | Byte-exact default stores. |
| `ev_b2e664174e17999a7e990a22fcbd872ac88c7f39a259053d684bbf0859075438` | [O] | Deep `FUN_00544548` | Loader enum/default arithmetic and field assignments. |
| `ev_27273f211f58501415e5d06d75b18600ffd2195c5ea69264fe8eedd2ff88880e` | [O] | `sub_544548` disassembly | `4×4`, `8×4`, `8×8` scheme table; offset defaults; 64 defaults. |
| `ev_58d7418c2dc5d46b793f64c408ea8a2f834ee5020be74b51d7c80968ff420221` | [O]/[D] | `sub_812e34`, 516 insns | Native per-cell layer/UV producer; distinct-tag mask; RGB/alpha subrect selection. |
| `ev_6f767eede169f5e551f3e6d87ba59232f3797a7f9a051eed0af1dbeee1757755` | [D] | Deep `FUN_00812b4c` | Writes four RGB UV corners. |
| `ev_e9694d0da085e0a3c3dcb0fb2d19548bbbdcffc6c3ac5fbbfad22c7e153b05db` | [D] | Deep `FUN_00812ccc` | Writes four alpha UV corners with asymmetric offsets. |
| `ev_70c790f9e5559ac103f7f30d4e7377be7f708044936848acffaaaa0d0879ffca` | [D] | Deep `FUN_0050db08` | RGB mask/full-variant lookup. |
| `ev_d7e71e035e95ceaa9d011e3701bf6a2bfddb75cf69d7555b8edfe17c511bf207` | [D] | Deep `FUN_0050daec` | Alpha mask/parity lookup. |
| `ev_20dda658684bf8ec249eb874e1a2ee6edad6daeda4bacaee1a54af8c3a46ab5f` | [O] | `cossacks.exe:0x8f5cd7`, 64 B | RGB LUT bytes and full-variant tables. |
| `ev_224b851c846058c075204f4c3fc2ae2aa3ae859c662eb86e5fa4d9202dc7a6b2` | [O] | `cossacks.exe:0x8f5d00`, 64 B | 16 mask pairs for alpha patch indices. |
| `ev_9ce28a175195244ffda016162111989dc79fcdc8ba278074ed6e01ea075d14b7` | [O] | `sub_8177f0` | Installs `sub_812e34` as terrain-cell callback and invokes mesh builder. |
| `ev_ec93f0af1fb49a1db65615047d264009071a024bf9acd83e8870e7a2b8e11b91` | [O]/[D] | `sub_818920` | Expands per-cell records into display-list quads. |
| `ev_696bc518d0ab6b3b28c3d5997b93c734f980524c68d7230ca5cbd2153cd30417` | [O]/[D] | `sub_818428` | Calls the two-float multi-texture coordinate dispatch for units `0x84c0/0x84c1`, then `glVertex4f`. |
| `ev_8ed2a80907087fdcae0827b6762cf5dab2be63c64e25b5a53335560b9a60c4ff` | [O] | `sub_81831c` | Single-UV vertex path; cross-check for two-UV path. |
| `ev_97d7b6610065914af91a1a1c9aeb0d7f944c0a3f24d9cb2c257248eda84100a5` | [D] | Deep `FUN_004ec3f0` | Texgen mode switch; cases 1/2/7. |
| `ev_1a116a59b56b1e9492cca43e3c456eb7b5e53bede9b4206a0107e6188bfd627f` | [O] | `cossacks.exe:0x8f4b44`, 64 B | Default texture matrix is identity. |
| `ev_bfb3fda2816d1b5d8b58b42cb9df9f28c06e26246ed2ba302e1116011ea91c14` | [O] | pointer `0x8fc984 → 0x8f4b44` | Constructor copies the identity matrix. |
| `ev_c253ba60923db6225e596eea45302cd225848b5baf6cf767c1ada51ce2f94d74` | [O] | `editor.exe:0x55806e` | Byte-identical constructor defaults. |
| `ev_0e2c2919ff1e4dfff645a7aac6333ce6f55c8b31d58b7e3c92bfa668822a2d8c` | [O] | `editor.exe:0xa29e37` | Byte-identical RGB LUT. |
| `ev_5563aa2409b700baa26c53ee6d54f68ffe419b5a4eac39bc227849a3d082ebd5` | [O] | `editor.exe:0xa29e60` | Byte-identical alpha LUT. |
| `ev_127a685b602cd247192383290bc7d4892981d8c323b7861fcd88e792ec7f2ad1` | [O] | `hf.pvl.smx3.frag:13–17,50` | RGB from unit0, alpha from unit1; no mask→RGB multiply. |
| `ev_99c2c38913e612e8c12857f20cf61ac7f9f4318f4afec0a320cd78a933fb8dbb` | [O] | `hf.pvl.sm.vert:25–34` | Eye-plane equations; `gl_TexCoord[1]=gl_MultiTexCoord1`. |
| `ev_5447b688fc4109ed3cfc0d671069b2637ace8b80270b7f2c848cd2f700e25931` | [D] | Deep `FUN_004ef810` | `bmTransparency` case calls blend setter with `(6,7)`. |
| `ev_ef6544a26ac25cf88283eff4dc8c3135ef91975d03393c59481e72ee111b7758` | [O] | factor table `0x8fb1c4` | `770 = GL_SRC_ALPHA`. |
| `ev_4d202b29454dccf08d3a658c163f2de7930ce714e4c34ceeb1865f5fd2855a51` | [O] | factor table `0x8fb1c8` | `771 = GL_ONE_MINUS_SRC_ALPHA`. |

---

## 3. Runtime terrain record: four corners, not one tile

### 3.1 Reader / writer

Deep Ghidra recovered both previously missed functions:

```c
FUN_008302b0(terrain, stream, version):
    allocate height grid                         // +0x18, (W+1)×(H+1) f32
    allocate record24 grid                       // +0x14, W×H, stride 0x18
    allocate record13 grid                       // +0x20, W×H, stride 0x0d
    ...
    for y in 0..W-1:
      for x in 0..H-1:
        read 0x18 bytes -> record24[x][y]
        read 0x0d bytes -> record13[x][y]
        record13[x][y][0x0c] = 1
```

```c
FUN_008305a0(terrain, stream):
    write W,H
    write height grid
    for y in 0..W-1:
      for x in 0..H-1:
        write 0x18 bytes -> record24[x][y]
        record13[x][y][0x0c] = 0
        write 0x0d bytes -> record13[x][y]
```

**[D] Corrected field interpretation.** The earlier `fnd_31` shorthand called bytes 16–31 “four 1.0f weights.” Native accessor `sub_82ebc0` reads record24 `+8..+0x17` as four `u32` values, and donor DScript declares `TMapTerrainDataTile.collision = Integer[4]` (`dmscript.global:2026–2030`). The recurring on-disk `0x3f800000` pattern is therefore **not proven to be blend weights**; it is consistent with a collision/tag field template. This report does not use those words as evidence of alpha weighting.

### 3.2 Proven record layout

| Record | Offset | Proven use |
|---|---:|---|
| 24 B (`+0x14`) | `+0..+3` | Four `u8` corner tile/material tags. |
| 24 B | `+4` | Per-cell random/variant byte; fed to both RGB and alpha LUTs. |
| 24 B | `+5..+7` | Reserved/sentinel bytes; exact semantics [U]. |
| 24 B | `+8..+0x17` | Four `u32` collision/tag values. |
| 13 B (`+0x20`) | `+0..+3` | Four corner values; min/normalise helpers read these four bytes. |
| 13 B | `+4..+7` | Four 0/1 corner flags; inspected as a 2×2 bitmap. |
| 13 B | `+8` | Override/variant byte returned by `FUN_00830818`. |
| 13 B | `+9..+0xb` | Auxiliary flags; exact semantics [U]. |
| 13 B | `+0xc` | Loaded/dirty flag: reader sets 1, writer clears 0. |

The exact native expansion from a single DScript `tex` value into the four corner tags remains **[U]**. The renderer-side consumption of four tags is proven.

---

## 4. Exact `tsDouble` / `ttExtended` defaults

`reftile.lib` activates:

```text
TileScheme = tsDouble
TileType   = ttExtended
TileXOffset = 0.1
TileYOffset = 0.2
```

The commented `Rows=16 / Cols=16` values are **not** the runtime defaults.

### 4.1 Constructor `FUN_0054428c` / `sub_54428c`

```c
scheme = 1;                 // tsDouble
type   = 1;                 // ttExtended
Rows   = 8;
Cols   = 8;
TileSize = 64;
AlphaRows = 8;
AlphaCols = 4;
AlphaTileSize = 64;
TileXOffset = 0.001953125f; // 0x3b000000, usual default
TileYOffset = 0.00390625f;  // 0x3b800000, usual default
```

`reftile.lib` then overrides the offsets to `0.1f` and `0.2f`.

### 4.2 Loader `FUN_00544548`

| Scheme | Type | Rows | Cols |
|---|---|---:|---:|
| `tsSingle` | `ttUsual` | 4 | 4 |
| `tsSingle` | `ttExtended` | 8 | 4 |
| `tsDouble` | either | 8 | 8 |

Alpha geometry is independently defaulted to `AlphaRows=8`, `AlphaCols=4`, `AlphaTileSize=64`.

**[D] Effective RGB cell size.** The producer normalises by `Rows*TileSize` and `Cols*TileSize`; `TileSize` cancels. A 1024×1024 DDS with `Rows=Cols=8` therefore has **128×128 effective RGB subcells**, not 64×64. The alpha BMP remains 512×256 with 64×64 patches.

---

## 5. Native producer of `gl_MultiTexCoord1`

### 5.1 Call chain

```text
sub_8177f0(terrainRenderer, x, y)
  installs callback FUN_00812e34 at renderer+0x12c/+0x40
  calls sub_81ac98(...)
  calls sub_81ae94 / sub_81aeac
  calls sub_818920(...)

sub_812e34(terrainRenderer, x, y, outRecord, ...)
  reads four corner tags + random byte
  sorts distinct tags ascending
  for each distinct tag:
      builds a 0x48-byte layer record
      FUN_00812b4c(...) -> four RGB UV corners
      FUN_00812ccc(...) -> four alpha UV corners

sub_818920(...)
  expands each 0x48-byte layer record into a 0x50-byte quad
  emits four vertices

sub_818428(...)
  glMultiTexCoord2f(unit0, uv0)
  glMultiTexCoord2f(unit1, uv1)
  glVertex4f(...)
```

**[D] Granularity:** topology and patch choice are **per cell**; coordinates are finally emitted **per vertex**, four vertices per distinct-tag layer. This is the concrete native producer of the donor's mesh UV channel 1.

### 5.2 Four-corner mask

Let the four resolved corner tags after native override/neighbour handling be `t[0..3]`. For each distinct tag `id`:

```c
mask = 0;
if (id == t[0]) mask |= 8;
if (id == t[2]) mask |= 4;
if (id == t[1]) mask |= 2;
if (id == t[3]) mask |= 1;
```

Distinct tags are sorted ascending. The first/lowest tag is the base layer. If there is only one distinct tag, or this is the first layer, the alpha mask is forced to zero. A transition layer whose mask is `0xf` is also converted to zero before the alpha LUT.

### 5.3 Exact alpha LUT

`FUN_0050daec(mask, randomByte)` returns:

```c
alphaPair = *(u16*)(0x8f5d00 + mask*2);
return (randomByte & 1) ? alphaPair >> 8 : alphaPair & 0xff;
```

The 16 little-endian pairs are:

| Mask | Pair bytes | parity 0 | parity 1 |
|---:|---|---:|---:|
| 0 | `00 10` | 0 | 16 |
| 1 | `02 12` | 2 | 18 |
| 2 | `01 11` | 1 | 17 |
| 3 | `03 13` | 3 | 19 |
| 4 | `08 18` | 8 | 24 |
| 5 | `0a 1a` | 10 | 26 |
| 6 | `09 19` | 9 | 25 |
| 7 | `0b 1b` | 11 | 27 |
| 8 | `04 14` | 4 | 20 |
| 9 | `06 16` | 6 | 22 |
| 10 | `05 15` | 5 | 21 |
| 11 | `07 17` | 7 | 23 |
| 12 | `0c 1c` | 12 | 28 |
| 13 | `0e 1e` | 14 | 30 |
| 14 | `0d 1d` | 13 | 29 |
| 15 | `0f 1f` | 15 | 31 |

The parity-1 value is exactly parity-0 + 16.

### 5.4 Exact alpha UV arithmetic

For patch index `p` returned by the LUT:

```c
x = (p % 4) * 64;
y = (p / 4) * 64;

u0 = x / 512.0;
v0 = y / 256.0;
u1 = (x + 64) / 512.0;
v1 = (y + 64) / 256.0;
```

For the base/first layer only:

```c
u0 += 0.1;  u1 -= 0.1;    // TileXOffset
v0 += 0.2;  v1 -= 0.2;    // TileYOffset
```

Transition layers use no inset. The four corners are then rotated by the cell's rotation metadata and optionally V-flipped.

**[D] Repeat consequence.** Adding 16 to `p` adds exactly `1.0` to `v`. The alpha material uses `twBoth`; therefore the parity half is repeat-equivalent unless another runtime unit-1 transform changes that coordinate. The code and table are exact; the effective runtime transform remains [U].

**This is the rule the port must implement.** It is categorically different from `dir=id%4`, `variant=(id/4)%4`, `half=(id/16)%2`, `opposite=(id/64)%2`.

---

## 6. Exact RGB subcell selection and world-space period

### 6.1 `tsSingle`: mask-selected RGB cell

For `tsSingle`, `FUN_0050db08(mask, randomByte, tileType)` selects an RGB subcell. For masks `0..14`, the table at `0x8f5cd7` is:

```text
mask:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14
index:46  4  8 12  1  5  9 13  2  6 10 14  3  7 11
```

For mask `15`, the full-cell variant depends on `randomByte`:

```c
if (randomByte < 0x88)
    return [0,15,16,17,18,19][randomByte % 6];
if (((randomByte + 0x78) & 0xff) < 0x44)
    return [20,21,22,23][randomByte & 3];
if (((randomByte + 0x34) & 0xff) < 0x22)
    return [24,25,26,27][randomByte & 3];
if (((randomByte + 0x12) & 0xff) < 0x12)
    return [28,29,30,31][randomByte & 3];
return 0;
```

### 6.2 `tsDouble`: world-coordinate 8×8 selection

The shipped ground is `tsDouble`, so the native producer does **not** use the mask table for RGB. It computes:

```c
xpx = (Round(cellX + mapWidth  / 2) mod Rows) * TileSize;
ypx = (Round(cellY + mapHeight / 2) mod Rows) * TileSize; // Rows, as written

u0 = xpx / (Rows * TileSize);
v0 = ypx / (Cols * TileSize);
u1 = (xpx + TileSize) / (Rows * TileSize);
v1 = (ypx + TileSize) / (Cols * TileSize);
```

`Round` is x87 `fistp` (`sub_4a6a5c`), i.e. the process rounding mode, normally nearest.

For the default `Rows=Cols=8`, this is an **8×8 art matrix indexed by map-cell coordinates**. With donor `gc_meters_to_tile=2`:

- one selected subcell covers one 2 m map cell;
- the RGB selection repeats after `8 × 2 = 16 m`;
- adjacent 2 m cells generally contain different authored art.

**[D] Why the donor has no regular square grid:** the donor changes art subcell every cell and varies transition topology per cell. The port samples the same atlas cell every 2 m. That creates a true 2 m lattice. Increasing/decreasing `uv_repeat` or adding a LOD inset cannot create the missing 8×8 art selection.

---

## 7. Texture offsets, rotation and filtering

### 7.1 Offsets and corner order

Base RGB corner order before rotation:

```text
(x,y), (x+64,y), (x+64,y+64), (x,y+64)
```

The helper at `FUN_00812b14` / `FUN_00812c94` applies:

```c
corner = (corner + cellRotation) & 3;
if (cellFlip) corner = 3 - corner;
```

and the V coordinate is flipped when the cell flip flag is set. The exact runtime source of `cellRotation/cellFlip` is not recovered here.

### 7.2 Magnification, minification, mips and wrap

Scale constants are separate from the subcell selector:

- `terrain.lib`: `TextureScale=(1,1,1,1)`.
- `reftile.mat` normal ground: `TextureScale=(1,1,1)`.
- `reftile.mat` face overrides: `TextureScale=(0.125,0.125,0.125)`.
- `dmscript.global`: `gc_pixels_to_meter=26.6666666`, `gc_meters_to_tile=2`, `gc_pixels_to_tile=53.3333333`, `gc_tiles_to_pixels=0.01875`.

No donor literal equivalent to the port's `uv_repeat=0.5` was found; the native 8×8 subcell arithmetic above is the recovered RGB topology.

Donor material text is exact:

| Resource | Mag | Min | Quality | Wrap |
|---|---|---|---|---|
| Ground RGB `reftile.mat` | `maNearest` | `miNearestMipmapLinear` | `tfIsotropic` | `twBoth` |
| Flat alpha `reftilealpha.mat` | `maNearest` | `miNearest` | — | `twBoth` |
| `alphavert` | `maNearest` | `miNearest` | — | `twBoth` |

`grass1.dds` is 1024×1024 DXT1 with 11 mip levels. In GL terms, the material enum order gives `maNearest → GL_NEAREST (0x2600)`, `miNearestMipmapLinear → GL_NEAREST_MIPMAP_LINEAR (0x2702)`, flat-alpha `miNearest → GL_NEAREST (0x2600)`, and `twBoth → GL_REPEAT (0x2901)` on S/T. `tfIsotropic` does not request anisotropic filtering. Native upload helpers such as `sub_5d2ad4` hardcode `GL_LINEAR` (`0x2601`) for some dynamic texture paths, but those calls are **not proven to be the terrain DDS path** and must not override the material evidence.

**[PORT APPROXIMATION]** The current shader's `textureGrad` and LOD-dependent atlas inset are packing workarounds. They do not reproduce the donor's per-block 8×8 subcell selection and cannot by themselves remove the grid.

---

## 8. Eye-plane texgen and texture matrix

### 8.1 Shader equations

```glsl
realpos = gl_ModelViewMatrix * gl_Vertex;
if (texGen == 0)
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
else {
    gl_TexCoord[0].s = dot(realpos, gl_EyePlaneS[0]);
    gl_TexCoord[0].t = dot(realpos, gl_EyePlaneT[0]);
    gl_TexCoord[0]   = gl_TextureMatrix[0] * gl_TexCoord[0];
}
gl_TexCoord[1] = gl_MultiTexCoord1;
```

### 8.2 Native defaults

- Plane floats: S=`(1,0,0,0)`, T=`(0,1,0,0)`, R=`(0,0,1,0)`, Q=`(0,0,0,1)` at `0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4`.
- Texture matrix at `0x8f4b44` is the 4×4 identity; constructor `sub_4eb9c0` copies it to texture object `+0x94`.
- `sub_4ec3f0` handles `tmmObjectLinear`, `tmmEyeLinear`, `tmmEyePlane`; ground `reftile.mat` is `tmmUser`, so that switch does not itself set the ground planes.

**[U] Effective runtime values.** The per-frame values passed through computed pointers remain unrecovered. The current shader's world-XZ fallback is therefore a port approximation.

**[U] UV0 / texGen contradiction.** The native producer emits explicit UV0 subrects, but `shaders.lib` sets `texGen=true` for HeightField. Whether runtime uses the explicit UV0 path, a prebuilt resource path, or a different uniform binding is unresolved. The alpha UV path is not ambiguous: the vertex shader always forwards `gl_MultiTexCoord1`.

---

## 9. Alpha blend and layer order

The native producer sorts distinct tags ascending and emits the lowest tag first, followed by transition layers. Each layer carries both RGB and alpha UVs.

The blend state is independently verified:

```c
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
// default GL_FUNC_ADD
dst.rgb' = src.rgb * src.a + dst.rgb * (1.0 - src.a);
```

The donor fragment writes `color.a = texture2D(texUnit1, gl_TexCoord[1].xy).a` and never multiplies RGB by the mask.

**[D] Producer-level layer count:** one quad per distinct corner tag, therefore 1–4 quads per cell in this native builder. **[U] Final runtime draw-pass count and global material-group order** remain unproven; display-list grouping can reorder quads across cells.

---

## 10. Why the current port grids and why tile variety went black

### 10.1 RGB grid

Current `terrain_donor_shader.gdshader`:

- `uv_repeat=(0.5,0.5)` at `:134`;
- `v_st` is world XZ at `:258–262`;
- `tile_rgb()` uses `fract(st_scaled)` at `:321`;
- `textureGrad` at `:357`.

This repeats one art cell every 2 m. Donor `tsDouble` selects an 8×8 art subcell by cell coordinates, with a 16 m macro period. The port therefore has the wrong sampling topology even when its mip handling is clean.

### 10.2 Black tile-variety capture

Current alpha code:

- `v_alpha_uv = v_st * uv_repeat` at `:270`;
- `alpha_patch_uv()` at `:369–381`;
- id-bit decomposition at `:371–376`;
- flat sampling at `:409–417`;
- `ALPHA=a` at `:447`.

New detail ids are arbitrary members of the 124-id preset space. The port's id-bit formula assigns them transition patches without knowing the four corner tags. Some land cells therefore sample zero/near-zero transition masks and blend toward the dark clear/background. This exactly matches the reported black-ground failure.

**[I] The black capture is consistent with this proven mechanism.** No new runtime frame was produced by this worker.

### 10.3 The 28,235 UV2 violations

`t_terrain_donor.gd:639–645` compares final `UV2.x` with raw `traw[i]`. But `world3d_terrain.gd` changes `tid` before `UV2.x`:

- cliff promotion / `vf`/`vs` id at `:1340–1354`;
- shore-sector replacement at `:1355–1385`;
- desert remap at `:1393–1405`.

Thus `UV2.x != raw tex` is expected for those cells. The atom should compare against the **final resolved id** or record an override reason. The count alone is not evidence that the texture coordinate producer is broken.

---

## 11. Concrete fix recommendation

### 11.1 Immediate containment — not parity

1. **Delete/disable `alpha_patch_uv()`'s id-bit selector.** Until four-corner data exists, flat terrain must not infer a transition mask from tile id.
2. For a diagnostic capture, force flat-ground `ALPHA=1.0` (or bypass alpha) while retaining the RGB tile id. This is a **PORT APPROXIMATION** containment, not a donor implementation.
3. Correct the atom contract: compare `UV2.x` with the final resolved tile id, or separately count face/shore/desert overrides.

### 11.2 Donor-shaped implementation

1. Carry per cell:
   - four corner tile tags;
   - the random/variant byte;
   - rotation/flip metadata if available.
2. Sort distinct tags ascending. Emit the lowest tag as the base layer, then one overlay per remaining distinct tag.
3. Compute the 4-bit mask exactly as in §5.2.
4. Use the exact alpha LUT in §5.3 and the UV arithmetic in §5.4. Do not clamp, floor, guard or neutralise authored mask values.
5. Put mask alpha in `ALPHA`; keep RGB unmodulated; use `blend_mix` over the base layer.
6. Replace same-cell world repeat with per-tile 8×8 RGB subcell selection:
   - `col = Round(cellX + W/2) mod 8`;
   - `row = Round(cellY + H/2) mod 8`;
   - sample the corresponding 1/8×1/8 subrect of the donor block.
7. Preserve block overrides (`sand1..4` 2×2, `test10` 16×16, `test11` 32×32) rather than forcing every block to 8×8.
8. Keep the existing packed 16×8 id atlas explicitly labelled `PORT APPROXIMATION`; it cannot represent the recovered per-block subcell topology without a new packing/layout.

### 11.3 Verification after implementation

- Base grass cells must have constant/full coverage; no arbitrary detail id may select a transition patch by itself.
- A cell with four different corner tags must produce four ordered layer records.
- RGB subcell selection must cycle through 8×8 art, not repeat one cell every 2 m.
- A pinned pan must show no 2 m checkerboard and no alpha-driven black land.
- Report runtime plane/matrix values separately if recovered; do not silently substitute world-XZ texgen.

---

## 12. UNVERIFIED register

| ID | Item | Status / next resolving evidence |
|---|---|---|
| DEC-U1 | Whether shipped runtime consumes explicit UV0 subrects or bypasses them via `texGen=true` | **[U] CONFIRMED_UNVERIFIED.** Need runtime shader-uniform binding or decoded mesh resource. |
| DEC-U2 | Effective `gl_EyePlaneS/T/R/Q` and `gl_TextureMatrix[0]` at ground draw time | **[U] CONFIRMED_UNVERIFIED.** Defaults are proven; runtime values are not. |
| DEC-U3 | Exact expansion from one source `tex` into four corner tags | **[U].** Reader/renderer consumption proven; setter implementation not recovered. |
| DEC-U4 | Full semantics of 13-byte record `+9..+0xb` | **[U].** Accesses observed; field names/meaning not recovered. |
| DEC-U5 | Global runtime draw order / final pass count | **[U].** Per-cell producer order is proven; material grouping may reorder. |
| DEC-U6 | Physical authoring intent of normalized `0.1/0.2` alpha insets | **[U].** Arithmetic is exact; visual intent is inferred. |
| DEC-U7 | Effective unit-1 texture transform and parity-half repeat behaviour | **[U].** `twBoth` suggests parity +16 repeats, but runtime matrix was not captured. |
| DEC-U8 | Donor visual parity | **[U].** No donor GPU A/B frame; no parity claim. |

---

## 13. Bottom line

The donor does **not** choose an alpha patch from tile-id bits. It builds a **per-cell, four-corner, distinct-tag layer stack**, computes a 4-bit occupancy mask, indexes a fixed 16-pair alpha LUT with a random parity bit, and emits explicit UV0/UV1 pairs for every layer vertex. Its `tsDouble` RGB path selects an **8×8 world-coordinate art matrix**, giving a 16 m macro period instead of the port's 2 m same-cell repeat.

That recovered topology explains both live symptoms:

- **regular olive grid:** the port repeats one RGB art cell every 2 m instead of walking the donor's 8×8 subcell matrix;
- **black tile-variety ground:** the port invents transition masks from tile-id bits, so ordinary detail ids sample alpha patches that belong only to specific four-corner transition topologies.

The immediate safe correction is to stop using the id-bit alpha selector. The donor-shaped correction is to carry four corner tags plus the random byte, emit sorted distinct-tag layers, use the exact mask LUT/UV arithmetic, and sample per-block RGB subcells. **No parity claim is made.**

*End of DEC-VIS-01. Files written: this report only. Donor read-only; no binary executed/copied; no code, shader, config, asset, test, git or Godot state changed.*
