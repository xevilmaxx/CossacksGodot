---
id: DECOMP-06
title: "DECOMP-06 — donor .map relief/terrain byte layout (Craft Anything file/format audit)"
area: donor / file format / terrain fidelity
owner: DECOMP-06
date: 2026-11-24
status: RESEARCH_COMPLETE__RELIEF_READABLE
verdict: "DONOR .map RELIEF IS RECOVERABLE, CONTRARY TO THE EARLIER 'UNREADABLE' MARKING. Inside a delimited TerrainMapBegin/TerrainMapEnd section there is a plain, uncompressed float32[320*320] height grid (409,600 B) with exact ±2.964 m bounds — the same bound as the port dump and donor cMaxHeight=2.96. Craft Anything does NOT recognise .map as a container (core_packed_files_list refuses it), but its byte-search tools locate the section markers and headers; the grid itself was decoded by read-only Python. Confidence HIGH for the height grid; other fields remain partially UNVERIFIED."
tools: "Craft Anything 0.6.1 (formats + native toolsets enabled), read-only shell + Python"
scope: "AUDIT ONLY — no source, asset, test or git edits; no donor file copied into the repo; no donor code run/unpacked; no target opened or selected (shared session)."
---

# DECOMP-06 — donor `.map` relief readability

## 0. Headline answer

**`.map` relief IS readable.** The earlier "UNREADABLE" verdict is wrong for the
height grid: the donor stores a raw, uncompressed `float32[320][320]` elevation
array inside a clearly delimited `TerrainMapBegin … TerrainMapEnd` stream section.
Two independent donor mission maps (`bonmis1.map`, `engmis4.map`) show the same
layout at different offsets, with min/max exactly **−2.964 / +2.964 m** — matching
donor `cMaxHeight=2.96` (`texturemap.inc`, TERRAIN2-04 E15) and the port dump's
`height` bound of ±2.964 (TERRAIN2-04 E12). No decompression, decryption, runtime
unpacking or donor execution is needed to read it.

Important nuance: Craft Anything's *generic format triage* does not parse the
file (`kind: unknown`; `core_packed_files_list` rejects it — it is not a ZIP/PE/
Godot/Unity/etc. container). The markers and headers were found with Craft
Anything's `native_bytes_find`; the grid layout and values were then decoded with
read-only Python. So "readable" means **parseable from the on-disk bytes with a
small purpose-built reader**, not "openable by a stock format tool".

## 1. Candidates examined (all read-only, none copied into the repo)

| File | Size (B) | SHA-256 | Why chosen |
|---|---:|---|---|
| `C:\Games\Cossacks 3\data\maps\missions\bonmis1.map` | 23,447,543 | `5b7a83c5…c69c4ea` | Smallest of 38 donor `.map` files — primary specimen |
| `C:\Games\Cossacks 3\data\maps\missions\engmis4.map` | 29,429,271 | `f079af79…9b0320ee` | Independent cross-check of the layout |
| `C:\Games\Cossacks 3\data\maps\missions\bonmis1.aix` | 393 | `e16db4eb…bae6` | Tiny sidecar; confirmed to be mission-trigger script text, not terrain |
| All `C:\Games\Cossacks 3` | — | — | `game_archives_list` found **no** Unreal/Unity/Godot archive holding maps |

38 `.map` files and 30 `.aix` files exist; all `.map` files are 23–126 MB.
`terrainmesh*.osm` (156–202 KB) are separate actor/mesh props (TERRAIN2-04 E22),
not the relief grid, and were not the target of this pass.

## 2. Evidence table

Every Craft Anything analysis call is cited by evidence id. Offsets are file
offsets (0-based), hex.

| Evidence id | Tool | Path / subject | Offsets / result |
|---|---|---|---|
| `ev_929a8fca68b283624d6efe4cfb1e9ffd10cf0ee081c871eed6096ba88f1e56be` | `core_target_triage` | `bonmis1.map` | `kind: unknown`, size 23,447,543; "A file we don't recognise yet" |
| `ev_78f563f43438f735b66b0304ef57094833b36551c7f914ef65c44ac49df3c110` | `core_target_triage` | `engmis4.map` | `kind: unknown`, size 29,429,271 |
| `ev_1e473223c9de5d5475d94c64a8a3766e6bc3bcd46697e9d2f2c6896813ac7d62` | `core_archive_show` | `bonmis1.map` | 1 entry, `kind: source-map`, **no nested containers** |
| (rejected, no id) | `core_packed_files_list` | `bonmis1.map` (also with `contains:"terrain"`) | `not_supported`: "This file doesn't carry files in any way we recognise." Readers offered: bun_program, node_sea, dotnet_bundle, godot_pck, pyinstaller, pyinstaller_pyz |
| `ev_a3860031dd80c930f0d039402a69dc776cc774b33ab19308df27af0ef70f8ea0` | `game_archives_list` | `C:\Games\Cossacks 3` | `archives: []`, `engine: none` |
| `ev_78377df1a9583b0e18551a8d098b799a2c7a0419f60a37cfb463254160af3447` | `core_text_read` | `bonmis1.aix` | UTF-8, 21 lines; `section.begin / Name = Initial / Code : struct.begin` — mission triggers only |
| `ev_b8f0b7144e694ff879386a9a88d4a4799f1a7f46b5ac17d15e7b512f9a8b6a75` | `native_bytes_find` (text) | `bonmis1.map` | `TerrainMapBegin` at `0x8d8a7d` (1 match) |
| `ev_ea38b46b4de5679ee343f855075b133f6d879f6ace68661a5a8108ec7a386899` | `native_bytes_find` (text) | `bonmis1.map` | `TerrainMapEnd` at `0xeaf4af` (1 match) |
| `ev_bb95b20ead683775d3a22029ac2957d5972ba86277faeddfd6b3b69ac12797db` | `native_bytes_find` (text) | `bonmis1.map` | `Terrain` ×2: `0x8d8a7d`, `0xeaf4af` (the two section markers) |
| `ev_454d9bbead3248cb018c5445bb9088385163b6d3bc34fbd7a2f8586948b529e0` | `native_bytes_find` (text) | `bonmis1.map` | `Height` — **0 matches** (field is unnamed/binary) |
| `ev_daa649ac48d05107daa858e5794b648a84e71b39f37d28e1f0a4960b6e8f2dc6` | `native_bytes_find` (text) | `bonmis1.map` | `hmap` — **0 matches** |
| `ev_ed4b853eea26285793f7ec79db404dc926244716dca49e7b2e5d02e6e4a37272` | `native_bytes_find` (text) | `bonmis1.map` | `SnapShot` ×2: `0x68`, `0x84` (header sections) |
| `ev_f0ad4c0ff905be9ee551aa68eb32d68b4c3d3088e480863bafbe7f63cb638cf1` | `native_bytes_find` (pattern) | `bonmis1.map` | `40 01 00 00 40 01 00 00 CD CC 8C BF` at `0xa68ac5` — **the 320×320 height-grid header** (1 match) |
| `ev_292ec93467ef75381338d3ab813e40d3f1027ccbb87047e64a14a1dc6f900e35` | `native_bytes_find` (pattern) | `bonmis1.map` | 4× `CD CC 8C BF` (−1.1f) starting `0xa68acd`; 128 matches total |
| `ev_28725aaf11079af4e1a404ce5eb75c173a63bbf532b55f25767e743935019b10` | `native_bytes_find` (pattern) | `bonmis1.map` | 4× `00 00 80 3F` (1.0f) starting `0xacd4d9`, stride 37 (≥100,000 matches) — the tile-record grid |
| `ev_b6704c9b154adec099d5b86e45be568a462d31d86c846a98ac85cdb31345256d` | `native_bytes_find` (text) | `engmis4.map` | `TerrainMapBegin` at `0x8a34ec` |
| `ev_4c0e2c9328c45f3f6269f0659e6c009fd3e5975fdb1525b64942193b8e736abc` | `native_bytes_find` (pattern) | `engmis4.map` | `40 01 00 00 40 01 00 00 2D B2 3D 40` at `0xa33534` — same height-grid header, different first value (+2.964f) |
| `ev_53da01a7c968bae8e421a14fa9208f9edabfdbe1fcd6d1436be7517a31584ca6` | `native_bytes_find` (pattern) | `engmis4.map` | 4× `CD CC 8C BF` at `0xa33724` (58 matches) |
| `ev_c336cdf4ad031ec21b3ff769325ef75089bcfc86b78f8ae74f62dfcd096dcf4c` | `native_bytes_find` (pattern) | `engmis4.map` | 4× `00 00 80 3F` starting `0xa97f48` — tile-record grid present in second map too |

Read-only Python (no evidence id, exact file offsets) was used for: header
hexdumps, length-prefixed string enumeration, float-array decoding, record-stride
detection, and histogram/statistics. All decoded offsets are listed below.

## 3. Byte-layout findings

### 3.1 The file is one Delphi/OSW serialized stream, not an archive

`bonmis1.map` begins with an **int32 length prefix + ASCII string** scheme:

```
0x0000  35 00 00 00  "OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]"  (53 B)
0x0039  ... UID423630422816850 ...
0x0064  14 00 00 00  "GameMapSnapShotBegin"
0x0080  12 00 00 00  "GameMapSnapShotEnd"
0x0094  12 00 00 00  "GameMapRecordBegin"
...
0x165c7e9 "GameMapEnd"  (near EOF at 0x165c7f7)
```

Strings are stored as little-endian `int32 length` followed by exactly that many
ASCII bytes. Section names (`…Begin` / `…End`) bracket every major block.
`OSWMap13` matches the `OSW*` Delphi unit family seen in `DECOMP-01` §4.
`core_archive_show` and `core_packed_files_list` confirm there is **no embedded
archive** to unpack: the whole 23 MB is a single flat stream. This is why a stock
FILE/FORMAT tool calls it "unknown" while a purpose-built reader can parse it.

Terrain section markers (bonmis1): `TerrainMapBegin` at `0x8d8a7d`,
`TerrainMapEnd` at `0xeaf4af` → **6,122,034-byte delimited block**.

### 3.2 Terrain block layout (bonmis1; engmis4 mirrors it at different offsets)

| Relative to `TerrainMapBegin` | Absolute (bonmis1) | Content | Confidence |
|---|---|---|---|
| `+0x00` | `0x8d8a79` | `int32 15` + `"TerrainMapBegin"` | OBSERVED |
| `+0x0F` | `0x8d8a8c` | `int32 320` (width) | OBSERVED |
| `+0x13` | `0x8d8a90` | `int32 320` (height) | OBSERVED |
| `+0x17` | `0x8d8a94` | `int32 4` — plausibly sub-tiles/cell (see §3.5) | INFERENCE |
| `+0x1B` | `0x8d8a98` | `int32 64` — plausibly tile size in px (donor `tiles.lib TileSize=64`) | INFERENCE |
| `+0x1F … +0x19002C` | `0x8d8a9c … 0xa68ac4` | ~1.63 MB of sparse/structured binary (mostly zero; a `00 57 00 00` run near `0x8d8b…`; a higher-entropy band around `0xac…`); not decoded | UNVERIFIED |
| `+0x19002D` | `0xa68ac5` | `int32 320`, `int32 320` (second header) | OBSERVED |
| `+0x190035` | `0xa68acd` | **`float32[102400]` height grid, 409,600 B**, ends `0xACCACD` | OBSERVED, decoded |
| `+0x1F4000-ish` | `0xaccacd … 0xacd4c8` | ~2.5 KB gap (undecoded) | UNVERIFIED |
| `+0x1F4A2D` | `0xacd4c9` | **102,400 records × 37 B** = 3,788,800 B tile/attribute grid (see §3.4) | OBSERVED, decoded |
| — | `0xe6a0c9 … 0xe6d615` | ~13.6 KB gap (undecoded) | UNVERIFIED |
| — | `0xe6d616 … 0xeaf4ab` | **8,777 records × 31 B** sparse named coords (see §3.5) | OBSERVED, decoded |
| — | `0xeaf4ab` / `0xeaf4af` | `int32 16` + `"TerrainMapEnd"` | OBSERVED |

Exactly **two** `40 01 00 00 40 01 00 00` (320,320) headers occur in each map:
the block header at `0x8d8a8c` (`0x8a34fb` in engmis4) and the height-grid header
at `0xa68ac5` (`0xa33534` in engmis4). That is a reliable anchor for a reader:
**find `TerrainMapBegin`, then take the second 320×320 header after it**.

### 3.3 The relief grid — the decisive finding

Decoded `float32[320*320]` at `0xa68acd` (bonmis1) and `0xa3353c` (engmis4):

| Map | Grid offset | Cells | Min (m) | Max (m) | Mean (m) | Dominant values |
|---|---|---:|---:|---:|---:|---|
| `bonmis1.map` | `0xa68acd` | 102,400 | **−2.964** | **+2.964** | −0.0727 | 0.0 ×30,723; −1.1 ×18,794; +2.964 ×3,202 |
| `engmis4.map` | `0xa3353c` | 102,400 | **−2.964** | **+2.964** | +0.2523 | 0.0 ×64,205; +2.964 ×8,628 |
| `app/shots/g32_dump.json` | base64 f32 LE | 102,400 | **−2.964** | **+2.964** | +0.5664 | 0.0 ×66,161; +2.964 ×9,418; +2.934 ×5,686 |

`heightmap_splat.py` already documents exactly this wire format at lines 12, 97
and 145–172: `"height": "<base64 of little-endian float32[map_w*map_h]>"`,
decoded with `struct.unpack_from(f"<{need}f", ...)`. The donor grid is therefore
**drop-in compatible with the port's dump schema** — no resampling, no byte-swap,
no scale factor is needed to feed the existing tool.

Spatial behaviour is heightfield-like: bonmis1 mean |Δx| = 0.0634 m,
mean |Δy| = 0.0858 m (max 3.128 m at cliffs/edges); row 319 is a constant
+2.964 border. The frequent value −1.1 is a plausible water/void sentinel —
semantics UNVERIFIED.

Exact cell-for-cell comparison with `g32_dump.json`: **17,354 / 102,400**
(bonmis1) and **41,496 / 102,400** (engmis4) — mostly shared zeros and clamped
values. **Neither donor mission is the source of the g32 dump**; do not claim
parity from this report. The dump appears to come from a different/procedurally
generated map, but the format and bounds are proven identical.

### 3.4 The 37-byte record grid (terrain appearance data, not elevation)

102,400 records at 37-byte stride, starting `0xacd4c9`; every record has an
identical trailing float quad of four `1.0f` values. Example record:

```
00 00 00 00 00 FF FF 00 61 61 5D 5D 89 00 00 00 00 00 80 3F ... 00 00 00 00 00
│── bytes 0–4 ──│5-6│7│── 8–11 ──│12│13-15│── 16–31: 4×1.0f ──│32–36│
```

- bytes 0–4: constant 0; bytes 5–6: `FF FF` (except first record);
- bytes 8–11: **four tile-index bytes** from a set of 43 distinct values (0–98;
  top values 0, 79, 78, 25). This is consistent with header field `4`
  (sub-tiles/cell) and donor `tiles.lib` `Rows=2, Cols=2, TileSize=64`
  (TERRAIN2-04 E17). INFERENCE, not proven;
- byte 12: 0–255, near-uniform — likely a per-cell variation/checksum;
- bytes 16–31: four `1.0f` weights (all 102,400 records identical);
- bytes 32–36: zero.

This grid plausibly supplies the port's `tileblock` grid directly — a second,
independent improvement over the currently inferred block ids.

### 3.5 Sparse named records (engine-placed cell props)

8,777 consecutive records of exactly **31 bytes** from `0xe6d616` to
`0xeaf4ab`:

```
int32 7 | "x21y159" | float 2.0 | float 2.0 | float −0.5 | float −117.0 | float 159.0
```

Every record has the first three floats fixed at `2.0, 2.0, −0.5`; the last two
are world coordinates obeying **`world = 2*index − 159`** exactly (e.g. x=21 →
−117, y=159 → +159). Names span x=0..159, y=19..159 — i.e. a coarser 160×160
grid, plausibly every second height cell. INFERENCE: height-grid index maps to
world ≈ `index − 159` (≈1 m/cell, ~320 m span), which would make the port's
`TILE_M = 2.0` / 640 m span **2× too large**. This is a hypothesis only: verify
against a known donor landmark before changing any mesh scale.

## 4. Verdict on `.map` relief readability

| Question | Verdict |
|---|---|
| Is relief present in the on-disk donor `.map`? | **YES — OBSERVED** (raw f32 320×320 grid, exact ±2.964 m) |
| Is it compressed/encrypted/engine-runtime-only? | **NO** — plain little-endian float32, no container, no unpacking |
| Can we read it without running donor code? | **YES** — read-only byte parse; Craft Anything byte-search supplies the anchors |
| Does it match the port dump schema? | **YES** — identical shape, encoding and clamp bound (`heightmap_splat.py` lines 12/97/145–172) |
| Does it match the g32 dump values? | **NO** — different map; only shared zeros/clamps |
| Confidence | **HIGH** for grid location/format/range (two maps, independent offsets, exact bounds); **MEDIUM** for tile-record semantics; **LOW/UNVERIFIED** for the ~1.6 MB pre-grid region, the two gaps, the −1.1 sentinel meaning, row orientation and world scale |

The previous `.map = UNREADABLE` classification should be revised to
**READABLE (custom reader required)**. What remains genuinely UNVERIFIED is the
*rendered* relief: TERRAIN2-04 F3 stands — the port's mesh connector and metre
scale are unproven, and don't infer donor visual fidelity from having the numbers.

## 5. Smallest next step for the splat/terrain tool

1. **Add a read-only donor-map importer** (no donor bytes committed): given an
   absolute `.map` path, locate `TerrainMapBegin`, then the **second**
   `40 01 00 00 40 01 00 00` after it, read `float32[102400]`, and emit a
   dump-shaped JSON `{"map_w":320,"map_h":320,"height":<base64 LE f32>}`.
   `heightmap_splat.py::load_dump()` (lines 145–172) already consumes exactly
   that shape; no change to the tool's core is required.
2. **Then run the existing tool** with `--texels-per-cell 2` (probe) or `4`
   against that derived dump to regenerate donor-grounded albedo — the P0-1
   recommendation of TERRAIN2-04, but now with *actual donor relief* instead of
   a re-used captured dump. Keep the LINEAR-filter fix noted there.
3. **Optional second step:** export the 37-byte grid's four tile-index bytes as
   a `tileblock`-shaped grid and feed it to `heightmap_splat.py` via its already
   parsed `tileblock` path (line 164–165 currently parses then discards
   `terrain`; the tool does use `tiles`). That replaces inferred block ids with
   donor tile ids. Do not do this before confirming bytes 8–11 are tile indices.
4. **Do not** change `TILE_M`, mesh scale or normals on the basis of §3.5's world
   coordinate inference without an in-engine A/B (AUDIT3D-09 lane).

## 6. UNVERIFIED / open questions

1. Meaning of the ~1.63 MB region between the block header and the height-grid
   header, and the two smaller gaps (13.6 KB / ~2.5 KB).
2. Whether bytes 8–11 of the 37-byte records are genuinely tile indices, and
   what byte 12 encodes.
3. Semantics of −1.1 in the height grid (water sentinel? void? cliff base?).
4. Height-grid row/column orientation (north-up vs south-up) — must be confirmed
   against a known donor map landmark or the game's renderer.
5. World scale (`~1 m` per height cell inferred in §3.5 vs port `TILE_M=2.0`).
6. Which donor mission (if any) corresponds to the captured G32 frame.
7. Any visual parity: no GPU A/B frame was captured; all visual statements in
   TERRAIN2-04 remain predictions.

## 7. Handoff

- No donor file was copied into the repository; no target was opened/selected;
  no donor code was executed; no source/config/asset/git changes were made.
- The exact anchor offsets for all 38 donor `.map` files can be found with the
  same two byte patterns: `TerrainMapBegin` (text) and
  `40 01 00 00 40 01 00 00` (pattern), then read 409,600 bytes from +8.
- Coordinate with TERRAIN2-04 P0-1/P1-3: the importer in §5 supersedes reusing the
  captured `g32_dump.json` as the *only* source of relief, but does not by itself
  prove donor visual parity.
