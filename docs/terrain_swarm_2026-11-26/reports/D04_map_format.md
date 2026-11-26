---
id: D04
title: "D04 — donor `.map` / terrain-tile binary layout, read/write functions, and byte verification"
wave: Binary
date: 2026-11-26
status: RESEARCH_COMPLETE__LAYOUT_RECOVERED
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
scope: "READ-ONLY. Donor `C:\\Games\\Cossacks 3` was never executed, copied into the repo or committed. No source/Godot/git edits. Only this report was written."
target: "Craft Anything active target `cossacks.exe` (PE32, sha256 87f0f3c130b0…, deep mode). `core_target_open`/`core_target_select` were NOT called; the already-active target was used."
---

# D04 — `.map` / terrain tile format in the donor binary

## Executive summary (5 lines)

1. **[O]** The donor terrain serializer is `sub_739d3c` (`cossacks.exe` CODE `0x739d3c`) and its loader is `sub_73a0b8` (`0x73a0b8`); both use a length-prefixed stream API and the `TerrainMapBegin … TerrainMapEnd` markers.
2. **[D]** The terrain block is: `u32 W, u32 H, u8 sub=4, u32` → `(2W)×(2H)` u32 tag grid → 41-byte gap → `u32 W, u32 H` → `f32` height grid → `W×W` 37-byte tile records → MergeCamera/MergeModules sub-streams.
3. **[O]** Each 37-byte cell is a 24-byte record plus a 13-byte record: bytes 8–11 are four `u8` tile indices, bytes 16–31 are four `1.0f` weights, byte 12 is a per-cell byte; invariants hold for **all** 102,400 (bonmis1) and 147,456 (battle1) records.
4. **[O]/[U]** Height is little-endian `f32` clamped to ±2.964 (`cMaxHeight=2.96`, `texturemap.inc:29`); the on-disk count from grid header to tile records is `(W+1)^2−2` floats in three maps, while the binary writer loop issues `(W+1)^2` — the two-float shortfall is **UNVERIFIED** after six passes.
5. **[U]** No per-tile collision flags[4], owner/visibility byte or resource pointer was found inside the 37-byte record; collision-like tags are a separate `(2W)²` grid, owner lives in `GameObject` player records. **No donor parity claim is made.**

---

## 1. Method, passes and anomaly log (owner directive: multiple passes, no silent skips)

| # | Pass | Result | Accepted / rejected and why |
|---:|---|---|---|
| P1 | `native_strings_find` for `.map`, `TerrainMapBegin`, `TMapTerrainDataTile`, `MapGetTileIndex*`, `GameMapRecordBegin` | 0 matches for every pattern (`ev_fc0d0281…`, `ev_0d23acef…`, `ev_df34754b…`, `ev_aaf3845f…`, `ev_2db235d5…`) | **Rejected as absence evidence**: tool limitation `data_sections_only`. The literals are *in CODE* (inline operands), not in DATA. |
| P2 | `native_bytes_find` on the raw exe file | 8 `.map` CODE literals (`ev_5c678e52…`); 2 `TerrainMapBegin` literals (`ev_1c68a76f…`); `OSWMap13`/`GameMapRecordBegin` strings at file `0x30fffc`, `0x311c00` | **Accepted**. Raw-byte search is the correct pass for this Delphi binary. |
| P3 | Naive VA arithmetic `file_offset + 0x400000` for file `0x339428` → `0x739428` | `native_data_show` at `0x739428` returns garbage; disassembly there is the middle of an unrelated call | **Rejected**. Tool-reported address `0x73a028` (`native_bytes_find`) resolves to `TerrainMapBegin` with one xref from `0x739d56` (`sub_739d3c`). Address mapping in this PE is not a single constant delta for all file offsets; only tool-reported VAs were used afterwards. |
| P4 | `native_function_find(0x73a6b4)` | Returns `sub_73a6b4`, 8 instructions of nonsense (`push esp; jb …; popad; imul …`) — those bytes *are* the second string literal | **Rejected** as a false function boundary. Xref pass gives the real owner: reference from `0x73a10c` inside `sub_73a0b8`. |
| P5 | `native_function_pseudocode("0x739d3c")` | Ghidra output with `WARNING: Instruction at 0x739d3f overlaps instruction at 0x739d3e`, self-contradictory loop | **Rejected**. Used `native_function_disassemble` (`ev_d4bcdab5…`, 230 real instructions) instead. Pseudocode was only trusted where it agreed with assembly/bytes. |
| P6 | `native_objdump_run`, `native_rizin_command_run` | `engine_missing` (neither engine installed) | **Unavailable**, not a finding. |
| P7 | Transient `function_not_found` for `0x73a0b8` / `0x8305a0` | First calls failed; retries (after `native_function_find`) succeeded with 467 / valid listings | **Accepted on retry**; recorded because the tool state is inconsistent across the shared session. |
| P8 | Height-grid length: prior port `W×W + 639 floats` vs binary loop `(W+1)×(H+1)` vs actual bytes | Bytes give `(W+1)^2−2` floats (103,039 for W=320; 148,223 for W=384) in 3 maps; tested shifted tile-record start (+8 B) → record invariants fail | **Observed count accepted for decoding**; root cause **[U]** (see §7). Port's "post-grid gap" is really the tail of the height grid, not a separate structure. |
| P9 | First tag-grid offset `marker+35` | Produced u32 histogram of float-like bit patterns (`0x3F800000`, …) | **Rejected** (off by 4). Correct start `marker+31` (after the 15-byte marker + 16-byte header) gives only 7 distinct u32 values — internally consistent. |
| P10 | 37-byte record: prior flat 37-byte struct vs binary 24-byte (`stride 0x18`) + 13-byte (`stride 0xd`) arrays | Both describe the same bytes; the binary split explains why byte 36 is forced 0 on save/1 on load and why four `1.0f` weights straddle offset 24 | **Accepted binary split**, flat byte map retained for the decoder. |

Evidence ids created in the shared session: `fnd_30` (serializer pair + stream framing), `fnd_31` (grid/record layout), `fnd_32` (height-count anomaly). No investigation brief or plan was reset.

---

## 2. Evidence table

| id / source | What it establishes |
|---|---|
| `ev_fc0d02811f821e942df1969a7bce6935f7e91a1048464988f6a5189cc8f70958`, `ev_0d23acef69656ba3a20e4213cc13a7e50e281736d03039fa3dc2ce1fac36f5f1` | `native_strings_find`: no `.map`/`TerrainMapBegin` strings in DATA sections (limitation, not absence) |
| `ev_5c678e52f7944c654bf128e597f3821cf01f9b7eb1b08914e08dc4efa24935c6` | 8 raw `.map` literals in CODE at file `0x3372ec…0x337dc0` |
| `ev_1c68a76f128cf9115a6af9043d0b9effda118a138c49d580f3c13f0052448b9c` | 2 raw `TerrainMapBegin` literals; tool VAs `0x73a028`, `0x73a6b4` |
| `ev_9d48142a36cf1ce610362182f93519c1a1bf7273b02af76daf2e90fea4e35e15` | `0x739d56` is inside save function `sub_739d3c` (+0x1a) |
| `ev_d4bcdab5b8533801e235e4d2fe00f7111cebe94c15f0cbc07ec3979e575142d3` | 230-instruction disassembly of save function `sub_739d3c` |
| `ev_e71dcabc46c6f0570089a5b403188c2192adb9b76a58571b5b7c17b3fe3905f6`, `ev_b6b94712741d4f482f394ae64a70b709334ffb197510a4f5428377213a48caf8`, `ev_1b70cd0be9b8cb8288c2b78772063881f6ec5e106f2e2d7fce7cf4578e17b10f` | xref and 467-instruction disassembly / study of load function `sub_73a0b8` |
| `ev_506fc7eddfd0203e59df2543b1b04aaa49482d98e1aa457b725d1df276ec0cc0` | Raw `Terrain` CODE occurrences (from prior pass) |
| Read-only Python (no evidence id; exact file offsets below) | All map-byte decodes, histograms, invariant counts and struct-format test |
| Donor text (no evidence id; path:line) | `data/scripts/common.inc/texturemap.inc:29` (`cMaxHeight = 2.96`); `dogenerate.inc:1576–1579` (`cWaterShoreHeight = -0.1`; `GetHeightData` returns `Float`); `data/gui/menu.inc/onmousedown.inc:0x32ec` (collision grid snapped to 0.5 units) |
| `cossacks.exe` CODE strings (raw file offsets) | `0x287304` `GetMapCollisionTag(x, y : Float; buselayers: Boolean): Integer`; `0x288c28`/`0x288c78` tile-index↔name APIs; `0x2a22c8`/`0x2a2308` `GetTileIndex`/`SetTileIndex`; `0x2a30ae` `GetHeightData(const x,y:Integer): Float`; `0x19a9d9` `XTerrainDataLite`, `0x42c909` `XTerrainData` |
| Prior art (read, not re-proven here) | `docs/coord_swarm_2026-11-24/reports/DECOMP_06_map_format.md`, `DEEPDEC_05_map_serialization.md`, `docs/decomp/DD_MAPS.md`, `variant3d/tools/import_donor_map.py`, `extract_map.py` |

Specimens (all read-only): `data/maps/missions/bonmis1.map` (23,447,543 B, W=320), `engmis4.map` (29,429,271 B, W=320), `battle1.map` (56,117,715 B, W=384). DLC `.map` files were not re-scanned in this pass.

---

## 3. Stream primitives and the two serialized functions

### 3.1 Stream API (observed in disassembly)

The `.map` is one flat Delphi/OSW stream. From `FUN_00846a88`, `FUN_00846c40`, `FUN_00846c08`, `FUN_00846c28` and the vtable calls in `sub_739d3c`/`sub_73a0b8`:

| vtable slot | Purpose | Evidence |
|---|---|---|
| `+0x0` | position / size query | `sub_846c40` loop |
| `+0xc` | **read** `ecx` bytes into `edx` | `sub_73a0b8` at `0x73a18f`, `0x73a214` |
| `+0x10` | **write** `ecx` bytes from `edx` | `sub_739d3c` at `0x739d6e`, `0x739df0` |
| `+0x18` | skip/seek | `sub_73a0b8` pseudocode |

- `FUN_00846a88(stream, s)` = write `u32 len` + ASCII bytes (**length-prefixed string**).
- `FUN_00846c40(stream, expected)` = read `u32 len` + bytes, compare to expected, skip on mismatch.
- `FUN_00846c08(stream, default)` = read one `u32` (version fields).
- `FUN_00846c28(stream, value)` = write one `u32`.

All integers are **little-endian** (x86; confirmed by `u32 320` = `40 01 00 00` in real maps).

### 3.2 Save: `sub_739d3c` / `FUN_00739d3c` (`ev_d4bcdab5…`)

Annotated reconstruction (assembly pass; pseudocode rejected per P5):

```c
// this = ebx; stream = esi; called with a terrain-map object
write_lp_string(stream, "TerrainMapBegin");        // 0x739d56, edx=0x73a028
write_u32(stream, *(this+8));                       // W
write_u32(stream, *(this+0xc));                     // H
write_u8 (stream, *(byte*)(this+0x14));             // sub-division = 4 in all maps
write_u32(stream, *(this+0x1c));                    // mode/flags (value 0 in specimens)
for (y = 0; y < *(int*)((*(this+4))+8); y++)        // 2*H = 640 / 768
  for (x = 0; x < *(int*)((*(this+4))+4); x++)      // 2*W = 640 / 768
    write_u32(stream, grid[y][x].field_0x1c);       // (2W)*(2H) u32 tag grid
write_u32(stream, 7);  FUN_007e6010(stream, obj);   // sub-stream
write_u32(stream, 4);  FUN_0080fb2c(obj, stream);   // W,H + heights + tiles (see 3.4)
write_lp_string(stream, "MergeCameraBegin"); ... "MergeCameraEnd";
write bytes/flags at this+0x8c, +0x8d, +0x54..+0x58;
write_lp_string(stream, "MergeModulesBegin"); ... "MergeModulesEnd";
write_u32(stream, count_from_point); write_u32(stream, 1);
sub_73ba20(obj, stream);
write_lp_string(stream, "TerrainMapEnd");
```

`FUN_00739a04` (call from loader `0x73a1d7`) sets `this+8=W`, `+0xc=H`, `+0x14=sub` and calls `FUN_007d7ccc(obj, 2*H, 2*W)` — **the `(2W)×(2H)` loop bounds in the serializer are derived, not guessed** (`sqrt(sub)=2` in the assembly at `0x739a46…0x739a78`).

### 3.3 Load: `sub_73a0b8` / `FUN_0073a0b8` (`ev_b6b947…`, `ev_e71dcab…`)

```c
expect_lp_string(stream, "TerrainMapBegin");        // 0x73a10c; failure -> 0x73a60a
if (!fast_mode) { clear/reset camera, resources; }
read_u32(&W); read_u32(&H); read_u8(&sub); read_u32(&flags);  // +0x183…+0x1b0
if (!fast_mode) FUN_00739a04(map, W, H, flags, sub);
for (y = 0; y < 2*H; y++)
  for (x = 0; x < 2*W; x++)
    read_u32(&grid[y][x].field_0x1c);               // 0x73a208…0x73a235
version = FUN_00846c08(stream, default);            // 0x846c08, default 4 in caller
if (!fast_mode) FUN_0080faac(obj, stream, version);
sub_7d8a14(obj, map);
if (expect_lp_string(stream, "MergeCameraBegin")) { ... expect "MergeCameraEnd"; }
if (expect_lp_string(stream, "MergeModulesBegin")) { version-dependent branches ... }
read_u32(&n); ... expect_lp_string(stream, "TerrainMapEnd");
```

`FUN_00846c40` is a tolerant marker check: it reads a length-prefixed string and skips it when it differs, so the format is forward/backward tolerant around sub-sections.

### 3.4 Height + tile writer / reader

`FUN_008305a0(obj, stream)` (called by `sub_80fb2c`) and `FUN_008302b0(obj, stream, version)` (called by `sub_80faac`) are the exact height/tile serializers:

```c
write_u32(stream, W); write_u32(stream, H);                 // 2nd W,H header
for (y = 0; y <= W; y++)
  for (x = 0; x <= H; x++)
    write_bytes(stream, &height[(W+1)*y + x], 4);            // f32 grid
for (y = 0; y < W; y++)
  for (x = 0; x < H; x++) {
    write_bytes(stream, &records24[y][x], 0x18);             // 24 bytes
    records13[y][x].byte12 = 0;
    write_bytes(stream, &records13[y][x], 0x0d);             // 13 bytes -> 37 total
  }
```

Reader `FUN_008302b0` allocates grids with strides **4, 0x18, 0xc, 0xd** via `FUN_00406d50(...)` and then reads them in the same order. For version ≥ 3 it replaces the 24-byte record's bytes 8–23 with a global template (`PTR_DAT_008fc33c`, relocated target `0x8f6164`): four u32 = `1.0f, 1.0f, 1.0f, 1.0f` at offsets +8/+0xc/+0x10/+0x14. For version 0 it reads the 24 bytes verbatim and sets byte 36 = 1 after the 13-byte read. This explains the invariant `1.0f` quad and the last-byte flag.

---

## 4. On-disk layout of the terrain block (byte-verified)

All offsets below are **file offsets** in `bonmis1.map`; the same structure appears in `engmis4.map` and `battle1.map` at different absolute offsets. `mk = 0x8d8a7d` = first byte of `"TerrainMapBegin"`; `int32 15` prefix at `mk-4`.

| Offset / expression | Size | Field | Label |
|---:|---:|---|---|
| `mk-4` | 4 | `u32 15` + `"TerrainMapBegin"` | [O] length-prefixed marker (`import_donor_map.py` checks this) |
| `mk+15` | 4 | `u32 W` = 320 (384 in battle1) | [O] width |
| `mk+19` | 4 | `u32 H` = 320 / 384 | [O] height |
| `mk+23` | 4 | `u32 4` | [O] sub-division (`byte[0x14]` in binary); [I] 2×2 subtiles |
| `mk+27` | 4 | `u32 64` | [O] tile pixel size (matches `tiles.lib TileSize=64`); [I] label |
| `mk+31` | `(2W)*(2H)*4` | `u32[(2W)×(2H)]` tag grid = 1,638,400 B (2,359,296 for W=384) | [O] size/order; [I] collision/mask semantics |
| `mk+31+(2W)^2*4` | 41 | `u32 256` + 37 zero bytes | [O] gap; producer **[U]** (several small sub-streams in save) |
| `mk+0x190048` (`0xa68ac5`) | 8 | `u32 W, u32 H` second header | [O] |
| `grid_off = 0xa68acd` | `((W+1)^2−2)*4` = 412,156 B | **height grid**, LE `f32` | [O] count in 3 maps; [U] 2-float shortfall |
| `tile_off = 0xacd4c9` | `W*H*37` = 3,788,800 B | 37-byte tile records | [O] |
| after tile grid | variable | `MergeCameraBegin/End`, `MergeModulesBegin/End`, count, named `xNyM` records | [O] from prior DEEPDEC-05 + binary marker order |
| `TerrainMapEnd` | 4+13 | `u32 13` + string | [O] |

`find_tile_grid()` in `variant3d/tools/import_donor_map.py` anchors on the first four consecutive `1.0f` values (`00 00 80 3f` ×4) after the height grid and takes `record0 = pos−16`. This anchor was **re-verified** against all records (§5).

### 4.1 Height grid

- [O] Little-endian `f32`, row-major as stored (index = `y*stride + x`; stride is 321 for W=320).
- [O] Values clamp at **±2.9639999866**; dominant `0.0`, `−1.1`, `+2.964` (bonmis1/engmis4). `−1.1` sentinel semantics **[U]**.
- [O] Donor unit evidence: `cossacks.exe` signature `GetHeightData(const x, y: Integer): Float` at file `0x2a30ae`; `texturemap.inc:29` `const cMaxHeight = 2.96`; `dogenerate.inc:1576–1579` treats `height < -0.1` as water/shore.
- [D] Units are donor world units; port calls them "metres" by convention (**PORT APPROXIMATION** — no in-engine scale A/B was performed).
- [D] The old port reading `W*W` floats + "639-float post-grid run" is the same byte region interpreted as `W` full rows + a partial final row; decoder must use the observed length or re-anchor with `find_tile_grid`.

### 4.2 The `(2W)²` tag grid

- [O] `bonmis1` at `0x8d8a9c`: 409,600 u32 values; only 7 distinct: `0`, `0x5700`, `0x6500`, `0x6E00`, `0x6D00`, `0x0A00`, `0x0700` (low bytes 87/101/110/109/10/7). `engmis4`: same value set, different counts; battle1: same set, 589,824 cells.
- [I] Half-cell resolution (2 samples per map cell per axis) and DScript `GetMapCollisionTag(x,y:Float,buselayers):Integer` plus `onmousedown.inc:0x32ec` (`px := floor(px*2)/2+0.25`) suggest this is the collision/mask tag grid consumed by that API. **Not proven**: the low bytes are ASCII-like (`W/e/n/m`), not small enum tags; no per-cell tag enum table was recovered.
- [U] Per-edge "collision flags[4]" were **not** found as four flags in this grid or in the 37-byte record.

### 4.3 The 37-byte tile record

Binary split: 24-byte array (stride `0x18`) then 13-byte array (stride `0xd`). Flat byte map (all offsets relative to record start):

| Offset | Type | Observed value | Label |
|---:|---|---|---|
| 0–4 | `u8[5]` | `00` in 100% of records | [O] zero/reserved |
| 5–6 | `u16` LE | `FFFF` in 102,399/102,400 and 147,455/147,456; zero only in record 0 | [O] valid/initialised marker; meaning **[U]** |
| 7 | `u8` | `00` 100% | [O] zero |
| 8–11 | `u8[4]` | e.g. rec0 `(0,79,79,79)`, rec1 `(79,79,79,79)`; 43–50 distinct ids depending on map | [O] tile indices; [D] ordinals into donor `tiles.lib` (prior DEEPDEC-05 §3 + `MapGetTileIndexByTileBlock` signature at `cossacks.exe:0x288c78`) |
| 12 | `u8` | all 256 values, near-uniform (bonmis1 rec0=`0xB2`, rec1=`0x59`) | [O] per-cell byte; [U] variation/seed/checksum |
| 13–15 | `u8[3]` | `00` 100% | [O] zero |
| 16–31 | `f32[4]` | `1.0f,1.0f,1.0f,1.0f` in **every** record | [O] equal weights; [D] four subtiles (2×2), binary template `PTR_DAT_008fc33c+8..+0x14` = four 1.0f |
| 32–35 | `u8[4]` | `00` 100% | [O] zero |
| 36 | `u8` | `00` on disk 100%; loader sets `1` in memory | [O] from binary save/load + bytes |

Invariant counts: bonmis1 102,400/102,400, battle1 147,456/147,456 for zero-prefix, byte7, bytes13–15, weight quad and zero tail; `FFFF` marker 1 record short in each (record 0).

**Texture index encoding:** four *u8 ordinals* per cell, one per 2×2 subtile; names resolved by `MapGetTileBlockByTileIndex(index)` / `MapGetTileIndexByTileBlock(tile)` (`cossacks.exe` CODE `0x288c28`, `0x288c78`) and by `tiles.lib` order. The weights are always equal, so no weighting rule needs inventing (**PORT APPROXIMATION** if the port picks one subtile).

**Owner / visibility / resource pointer:** no such fields were observed inside the 37-byte record. Owner strings (`player0`…) occur in `GameObjectBegin` records (DEEPDEC-05 §5), resources in `ResourceBegin…ResourceEnd`; per-tile owner/visibility/resource pointer **[U]**.

### 4.4 Compression and endianness

- [O] No decompression step exists in either serializer: arrays are written/read directly through the stream vtable. Within the terrain block the bytes are plain LE integers/floats.
- [U] The rest of the 23–142 MB file was not exhaustively scanned for compressed sub-streams in this pass; prior `DD_MAPS.md` found no gzip/ZIP/zstd markers in first/last 4 KiB.

---

## 5. Python struct format and decoder recipe

Tested (read-only) against `bonmis1.map`; `struct.calcsize == 37`.

```python
import struct

TILE_FMT = "<5BH1B4B1B3B4f5B"   # 37 bytes; unpack returns 24 values
# fields: [0:5] zero5; [5] u16 flag; [6] u8;
#        [7:11] u8 tile_ids[4]; [11] u8 variation;
#        [12:15] u8 zero3; [15:19] f32 weights[4]; [19:24] u8 zero5

def decode_map(data: bytes) -> dict:
    mk = data.find(b"TerrainMapBegin")
    assert mk >= 4 and struct.unpack_from("<I", data, mk - 4)[0] == 15
    W, H, sub, tilepx = struct.unpack_from("<4I", data, mk + 15)
    assert W == H and sub == 4

    # 1) (2W)x(2H) u32 tag grid
    tag_off = mk + 31
    tag = struct.unpack_from("<%dI" % ((2*W)*(2*H)), data, tag_off)

    # 2) second W,H header (robust: search just after the tag grid)
    pair = struct.pack("<II", W, H)
    h2 = data.find(pair, tag_off + (2*W)*(2*H)*4 - 64)
    grid_off = h2 + 8

    # 3) height grid: OBSERVED count (W+1)^2-2; reader loop says (W+1)^2 [U]
    nh = (W + 1) ** 2 - 2
    heights = struct.unpack_from("<%df" % nh, data, grid_off)

    # 4) tile records: anchor on the invariant four 1.0f weights, then validate
    quad = struct.pack("<4f", 1.0, 1.0, 1.0, 1.0)
    pos = data.find(quad, grid_off + nh * 4)
    tile_off = pos - 16
    assert data[tile_off + 5 : tile_off + 7] in (b"\xff\xff", b"\x00\x00")
    records = [struct.unpack_from(TILE_FMT, data, tile_off + 37*i)
               for i in range(W * H)]
    assert all(r[15:19] == (1.0, 1.0, 1.0, 1.0) for r in records)
    return {"W": W, "tag": tag, "heights": heights,
            "tile_ids": [r[7:11] for r in records], "variation": [r[11] for r in records]}
```

Recipe notes: read the marker with its `u32 15` prefix; never hard-code 320 (battle1 is 384). The height stride is `W+1`; the extra tail belongs to the height grid, not to a separate 639-float structure. Reject a tile anchor whose record-0/record-1 `FFFF` marker and weight quad fail.

---

## 6. Implications for the port (all PORT APPROXIMATION unless marked [O]/[D])

1. **Reader upgrade:** `variant3d/tools/import_donor_map.py` currently emits `tileblock` as zero placeholders. The donor tile ids at record bytes 8–11 are **[O]** and can be emitted directly; choose one subtile index or carry all four with the constant weights (no invented weighting rule).
2. **Height ingestion:** keep the existing LE `f32` dump schema, but read `(W+1)^2−2` values (or locate the tile grid by its weight quad) instead of `W*W`; the current 2,556-byte "gap" is decoded as terrain height.
3. **Tag grid:** expose the `(2W)²` u32 array as a separate layer for navigation/collision experiments, labelled **[I]**; do not map its raw u32 values to boolean passability without a donor enum table.
4. **World scale:** do not change `TILE_M` on this report. The ±2.96 height bound and 0.5-unit tag-cell hint are evidence for a scale study, not an A/B result.
5. **Stage order for a fresh module:** header → tag grid → height grid → tile records → camera/modules → entities. This order is **[O]** from the two serializers and should be mirrored by any donor-shaped importer.

---

## 7. UNVERIFIED register and open questions

| # | Claim | Status | Passes attempted |
|---:|---|---|---|
| U1 | Cause of `(W+1)^2−2` height floats vs writer loop `(W+1)^2` | **[U]** | P5 pseudocode, P7 retry, P8 byte tests on 3 maps, shifted-record hypothesis rejected, grid-row analysis (last row has 319 values) |
| U2 | Meaning of `FFFF` at record bytes 5–6 and byte 12 variation | **[U]** | Binary reader branches, template pointer, 256-value histogram; no donor enum found |
| U3 | Tag-grid value semantics (`0x57/0x65/0x6E/0x6D/0x0A/0x07`) | **[U]** | Corrected-offset histogram, DScript signature, editor snap-to-0.5 script; no enum table |
| U4 | Per-edge collision flags[4], per-tile owner/visibility, resource pointer | **[U]** / no evidence in record | 37-byte field census, GameObject/Resource marker prior art |
| U5 | 41-byte gap producer (`u32 256` + 37 zeros) | **[U]** | Save call sequence inspected; sub-stream `FUN_007e6010` internals not decoded |
| U6 | `−1.1` height sentinel | **[U]** | Value histogram; prior reports also unresolved |
| U7 | Row orientation / world metre scale | **[U]** | No GPU A/B; no donor landmark check |
| U8 | Version-dependent 24-byte template path (≥3) actually used by any shipped map | **[U]** | Observed maps all carry varied bytes 8–12, consistent with the raw path |
| U9 | Compression deeper in non-terrain sections | **[U]** | Terrain arrays decoded directly; whole-file scan out of scope |

Open questions for other workers: D05 should reconcile the height loop bound with the observed count; D06 should test whether the `(2W)²` grid is the collision/water tag source; D08 should confirm tile-ordinal→atlas resolution at runtime. F01/F02 can cross-check `tiles.lib` ordinals used in record bytes 8–11.

---

## 8. Compliance statement

No donor file was executed, copied into the repository or committed. No target was opened or selected (the already-active `cossacks.exe` was used); no brief, plan, source, shader, config, asset, test or git change was made. This is the sole report authored by D04. No donor visual parity is claimed; all port statements are labelled **PORT APPROXIMATION** or inferred.
