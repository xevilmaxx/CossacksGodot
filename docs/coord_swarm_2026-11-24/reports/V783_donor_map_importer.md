---
id: V7-83
title: "V7-83 — read-only donor .map relief importer -> heightmap_splat.py dump JSON"
owner: V7-83
scope: "ONE NEW tool (variant3d/tools/import_donor_map.py) + this report ONLY. Donor path read-only; no donor binary copied/executed; no .gd, splat tool, app/, config, test or git changes."
date: 2026-11-24
status: PASS__DONOR_VERIFY_2_MAPS__SPLAT_CONSUMED__TEMP_DELETED__NO_VISUAL_CLAIM
followup: "DEEPDEC-05 extension in §8: v1.1.0 adds W/H-generalised parsing, 4-index tile histogram and GameObject placement sampling; verified on bonmis1/engmis4/battle1."
verdict: "A standalone stdlib-only importer locates TerrainMapBegin, validates the SECOND 320x320 header after it and decodes the raw float32[320x320] elevation grid into the exact JSON shape heightmap_splat.py::load_dump() consumes. Measured on bonmis1.map and engmis4.map: 102,400 cells each, bounds exactly -2.964000/+2.964000 m, zero bounds delta against app/shots/g32_dump.json; exact cell matches 16,274 and 40,327 (strict float32 equality), max abs error 5.928000 m and 5.302495 m. Generated JSON was consumed by heightmap_splat.py (dry-run and a real 320x320 RGBA render into a temp dir outside the repo; temp dir deleted). Tile-index and named-coordinate structures are parsed as opaque counts only and labelled SEMANTICS UNVERIFIED. No visual parity claim."
---

# V7-83 — donor `.map` relief importer

## 1. Deliverable and scope

| Item | Path | State |
|---|---|---|
| New tool | `variant3d/tools/import_donor_map.py` | NEW, stdlib-only, read-only on donor |
| Report | `docs/coord_swarm_2026-11-24/reports/V783_donor_map_importer.md` | NEW |
| Everything else | — | untouched; no git operations |

The donor map is opened once with `Path.read_bytes()`. No donor code is run,
no donor file is copied into the repo, and no donor byte is committed. Output
is stdout by default; an explicit `--out` is refused if it resolves inside the
repository (`ROOT = Path(__file__).resolve().parents[2]`).

## 2. Evidence used (read first, as instructed)

| Source | Path:line / offset | Fact carried into the importer |
|---|---|---|
| `DECOMP_06_map_format.md` | `:17-24`, `:126-140` | raw uncompressed LE `float32[320*320]`, 409,600 B, ±2.964 m, drop-in for `heightmap_splat.py` |
| `DECOMP_06_map_format.md` | `:100-124`, `:128` | `TerrainMapBegin` anchor; take the **second** `40 01 00 00 40 01 00 00` after it, grid starts +8 |
| `DECOMP_06_map_format.md` | `:59,65,68,69` | donor offsets `bonmis1`: marker `0x8d8a7d`, header2 `0xa68ac5`; `engmis4`: marker `0x8a34ec`, header2 `0xa33534` |
| `DECOMP_06_map_format.md` | `:103-119`, `:153-171`, `:175-190` | tile-index grid, named-coordinate records, and gaps; all marked INFERENCE/UNVERIFIED there |
| `TERRAIN2_01_donor_pipeline.md` | `E07` (`generatemap.inc:4-7`), `E24` (`texturemap.inc:29-31`) | `cPlateauHeight=2.964`, `cWaterHeight=-1.1`, `cMaxHeight=2.96` — the ±2.964 clamp is donor-grounded |
| `TERRAIN2_01_donor_pipeline.md` | `E03`, `E21-E23`, `§6:1,7` | no donor metres-per-cell constant; mesh connector and `.map` body semantics UNVERIFIED |
| `variant3d/tools/heightmap_splat.py` | `:8-21`, `:93-104`, `:122-176`, `:363-391` | exact schema: `map_w`, `map_h`, `height` (base64 LE f32), **required `tileblock`**, optional `terrain`/`blocked`, `meta`; `load_dump()` validates both `height` and `tileblock` |

### 2.1 Measured donor evidence (this pass, read-only)

| Donor file (`C:\Games\Cossacks 3\data\maps\missions\`) | Size (B) | SHA-256 | `TerrainMapBegin` (int32 prefix) | header #1 / header #2 | height grid | `TerrainMapEnd` ASCII (prefix) |
|---|---:|---|---|---|---|---|
| `bonmis1.map` | 23,447,543 | `5b7a83c59261843ee961b7ddee82503fc6e72cb84197b005bdb3954ecb69c4ea` | `0x8d8a7d` (15) | `0x8d8a8c` / `0xa68ac5` | `0xa68acd` | `0xeaf4af` (13) |
| `engmis4.map` | 29,429,271 | `f079af79f78703faddcfe75da81486491f7396058e311bb0320ee44e5dae9bce` | `0x8a34ec` (15) | `0x8a34fb` / `0xa33534` | `0xa3353c` | `0xe8bb48` (13) |

Both second headers decode to `(320, 320)`; both grids end 409,600 B later.
Validation also checks exactly one begin/end marker and the 15/13 byte length
prefixes. **Correction to DECOMP-06:119:** the int32 immediately before
`"TerrainMapEnd"` is **13** (the string length), not 16 — the `10 00 00 00`
quoted there is the prefix of the following string. The tool enforces 13.

## 3. Importer schema and CLI

```
python variant3d/tools/import_donor_map.py MAP [--out PATH] [--tileblock zero|omit] [--survey]
python variant3d/tools/import_donor_map.py MAP --verify [--dump PATH]
python variant3d/tools/import_donor_map.py --schema
```

Emitted JSON (default `tileblock=zero` so `heightmap_splat.py::load_dump()`
accepts it with no edits to that tool):

```json
{
  "map_w": 320,
  "map_h": 320,
  "seed": 0,
  "height": "<base64 ASCII, validate=True, 409,600 B = LE float32[102400]>",
  "tileblock": "<base64 ASCII, 102,400 zero bytes>",
  "meta": {
    "importer": "import_donor_map.py",
    "importer_version": "1.0.0",
    "source_map": "bonmis1.map",
    "source_map_sha256": "...",
    "source_size_bytes": 23447543,
    "terrain_map_begin_offset": "0x8d8a7d",
    "terrain_map_end_offset": "0xeaf4af",
    "grid_header_offset": "0xa68ac5",
    "height_grid_offset": "0xa68acd",
    "height_bytes": 409600,
    "height_min_m": -2.9639999866485596,
    "height_max_m": 2.9639999866485596,
    "height_mean_m": -0.072741,
    "tileblock_origin": "NEUTRAL_ZERO_PLACEHOLDER",
    "tileblock_note": "Donor tile-index semantics UNVERIFIED ... zeros only satisfy load_dump",
    "height_row_orientation": "UNVERIFIED; row-major y*320+x as stored on disk",
    "donor_data_written": false
  }
}
```

- `tileblock` zeros are a **neutral placeholder**, never donor-derived tile
  data; the donor tile semantics are UNVERIFIED (§5). `--tileblock omit`
  removes the key for a pure height document (then `load_dump()` needs a
  caller-supplied tileblock).
- `seed = 0` is not donor-derived. `map_w/map_h/height` are the only
  donor-grounded payload fields.
- `--verify` writes **nothing** (ignores `--out` with a stderr note) and
  compares against `app/shots/g32_dump.json` by default, or `--dump PATH`.
- `--survey` prints opaque structure counts to stderr; no field is emitted
  and no meaning is assigned.

## 4. Measured verification

Local reference: `app/shots/g32_dump.json`, SHA-256
`79f93c2c1c69c816006e73b122bb9d3b0ad16b1797387b6b6c4262b67963f3de`,
320×320 / 102,400 cells, bounds −2.964000 / +2.964000 m, mean +0.566362 m.

| Donor map | Cells | Donor min / max / mean (m) | Exact matches (strict f32 `==`) | Max abs error (m) | Bounds delta (m) |
|---|---:|---|---:|---:|---|
| `bonmis1.map` | 102,400 | −2.964000 / +2.964000 / −0.072741 | **16,274 / 102,400 (15.8926%)** | 5.928000 | min 0.000000000, max 0.000000000 |
| `engmis4.map` | 102,400 | −2.964000 / +2.964000 / +0.252345 | **40,327 / 102,400 (39.3818%)** | 5.302495 | min 0.000000000, max 0.000000000 |

Interpretation: same **format and clamp bounds**, different **map values** —
neither mission is the source of the G32 dump. This is consistent with
DECOMP-06:147-151 (no visual/identity claim). DECOMP-06 quotes 17,354 /
41,496 exact matches; this tool uses strict float32 bit-value equality, while
the earlier numbers appear tolerance-sensitive (on `bonmis1`, rounding to 3
decimals gives 17,717 and `|Δ|<1e-4` gives 17,549). Read both as "mostly shared
zeros and clamps", not as a precise identity metric.

### 4.1 `--survey` structure counts (parsed, SEMANTICS UNVERIFIED)

| Map | 37-byte grid: first / end / records | quad check | Named records: first / end / count | observed total sizes (B) |
|---|---|---|---|---|
| `bonmis1.map` | `0xacd4c9` / `0xe6a4c9` / 102,400 | 102,400/102,400 trailing `1.0f`×4 | `0xe6d616` / `0xeaf4ab` / 8,777 | 30×2,455; 31×5,981; 32×341 |
| `engmis4.map` | `0xa97f38` / `0xe34f38` / 102,400 | 102,400/102,400 trailing `1.0f`×4 | `0xe76b60` / `0xe8bb44` / 2,832 | 29×117; 30×1,570; 31×1,145 |

The tile grid starts `height_grid_end + 2556` in both maps. Named records are
variable length `int32 L | "xNNNyNNN" | 5*f32` = `24+L` bytes: **31 bytes is the
common case (7-character name)**, not a fixed stride; the walk terminates
exactly at the `TerrainMapEnd` prefix in both maps. No index, coordinate or
tile meaning is asserted here.

### 4.2 `heightmap_splat.py` consumption (temp dir OUTSIDE the repo)

1. Generated `bonmis1_height.json` (683,658 B) into
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v783_test\`.
2. `--dry-run`: parsed 320×320 = 102,400 cells, seed 0, 124 preset names,
   used id `{0 -> grass1}`, no missing PNGs.
3. Real run wrote `splat.png` (320×320 RGBA, 41,891 B) plus
   `splat.manifest.json` (1,150 B) in the same temp dir; manifest reports
   `height_min_m = -2.9639999866485596`, `height_max_m = 2.9639999866485596`.
4. Repo-write guard tested with `--out` pointing at
   `variant3d/tools/should_not_exist.json`: refused, file not created.
5. Temp dir recursively deleted; `Test-Path` → `False`. Only the new tool and
   this report remain in the workspace.

No visual parity is claimed: this proves schema compatibility only, not that
a rendered splat matches a donor frame.

## 5. Parsed but SEMANTICS UNVERIFIED (do not invent semantics)

1. **4-byte tile-index grid** (37-byte records, bytes 8..11; DECOMP-06:153-171):
   four small integers per cell, plausibly sub-tile indices. Parsed as opaque
   record counts only; **not** mapped to `tileblock` or any block name.
2. **Named coordinate records** (DECOMP-06:175-190): `xNyN` names, constant
   `2.0/2.0/−0.5` prefix and two trailing floats obeying `world = 2*index−159`
   in the earlier sample. Parsed for structure/count only; the world mapping,
   `~1 m` per cell vs port `TILE_M=2.0`, and the row orientation stay
   UNVERIFIED (TERRAIN2-01 §6:1; DECOMP-06 §6:2-5).
3. **−1.1 sentinel** meaning (water/void?) UNVERIFIED.
4. **Block header / gaps** (~1.63 MB pre-grid, ~2,556 B and ~13 KB gaps)
   undecoded; the 2,556 B offset is used as an anchor, not as an explanation.
5. Which donor mission produced G32 — unknown.

## 6. Commands used (all read-only on donor)

```powershell
python variant3d/tools/import_donor_map.py --schema
python variant3d/tools/import_donor_map.py --verify "C:\Games\Cossacks 3\data\maps\missions\bonmis1.map"
python variant3d/tools/import_donor_map.py --verify "C:\Games\Cossacks 3\data\maps\missions\engmis4.map" --survey
python variant3d/tools/import_donor_map.py "C:\Games\Cossacks 3\data\maps\missions\bonmis1.map" --survey > $null
python variant3d/tools/import_donor_map.py "C:\Games\Cossacks 3\data\maps\missions\bonmis1.map" --out "$tmp\bonmis1_height.json"
python variant3d/tools/heightmap_splat.py --dump "$tmp\bonmis1_height.json" --out "$tmp\splat.png" --dry-run
python variant3d/tools/heightmap_splat.py --dump "$tmp\bonmis1_height.json" --out "$tmp\splat.png"
python variant3d/tools/import_donor_map.py "C:\Games\Cossacks 3\data\maps\missions\bonmis1.map" --tileblock omit --out "$tmp\height_only.json"
Remove-Item -Recurse -Force $tmp
```

`$tmp = C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v783_test`.

## 7. Open questions / handoff

- Confirm donor tile-index bytes against `terrain.presets` before ever
  replacing the zero placeholder with real tile ids.
- Confirm grid row orientation and world scale against a known donor landmark
  or an in-engine A/B before touching `TILE_M` or mesh normals.
- Decide whether a future importer should emit a real `tileblock` (separate
  task, separate evidence); this tool deliberately does not.
- No donor binary, dump copy or generated JSON is present in the repo; no
  source/asset/config/test/git state changed.

---

## 8. DEEPDEC-05 extension — tile indices and placement samples (follow-up)

Read first: `DEEPDEC_05_map_serialization.md` (`:99-143` tile record, `:145-203`
named records, `:205-250` entities, `:290-300` reader anchors). Tool bumped to
`TOOL_VERSION = 1.1.0`; the original height dump JSON and `--verify` results are
unchanged (re-measured below).

### 8.1 What changed in `variant3d/tools/import_donor_map.py`

| Change | Evidence | Behaviour |
|---|---|---|
| W/H no longer hard-coded | DEEPDEC-05 `:95-97`, `:290-300` | first repeated `u32 W,u32 W` after `TerrainMapBegin`, then its SECOND occurrence; 320/320 and 384/384 both parse. `--verify` still requires a 320×320 dump and refuses 384 with a clear error. |
| Tile grid located by invariant | DEEPDEC-05 `:90`, `:101-123` | find the first record with four `1.0f` at +16 and `FF FF` at +5; measured gaps: 2,556 B (320 maps), **3,068 B (battle1)** — not hard-coded. |
| Four tile indices decoded | DEEPDEC-05 `:99-131`, `:46` | bytes 8..11 → u8 ordinals; names from repo `tileblocks.json` (DEEPDEC-05:46: donor `tiles.lib` order mirror). `--survey` emits full histogram, per-position distinct counts, `unresolved_ids`. |
| Named records count-prefixed | DEEPDEC-05 `:145-170` | read `u32 count` immediately before first `xNyM`, walk variable strides `24+nameLen`, assert declared == parsed. |
| Placements sampled | DEEPDEC-05 `:205-228`, `:281-287` | `--export-placements --limit N`: `int32 15 + GameObjectBegin`, category/type lp strings, first float triplet, four following lp strings, first `.mesh` string within 2,048 B. |
| Output discipline | original V7-83 contract | `--verify` writes nothing; all other output goes to stdout or `--out` outside the repo (guard retained). |

### 8.2 Measured tile-index histograms

Counts are over **all four sub-tile positions** (`4 × W × H` values);
`id:name` comes from the `tiles.lib` ordinal mirror, not invented.

| Map (W×H) | Tile grid | distinct ids | range | 1.0f quads | unresolved |
|---|---|---:|---|---:|---:|
| `bonmis1.map` (320²) | `0xacd4c9..0xe6a4c9`, gap 2,556 | **43** | 0..98 | 102,400/102,400 | 0 |
| `engmis4.map` (320²) | `0xa97f38..0xe34f38`, gap 2,556 | **50** | 0..101 | 102,400/102,400 | 0 |
| `battle1.map` (384²) | `0x1fb291a..0x24e691a`, gap 3,068 | **14** | 10..121 | 147,456/147,456 | 0 |

`bonmis1` (`id:count`, 409,600 values):
`0:100034 1:18200 10:176 14:18056 15:216 16:10838 17:2500 19:2616 2:460 20:11822 21:6476 23:2356 24:6790 25:29170 28:12 29:56 4:4246 5:304 6:600 7:5922 71:24 72:48 74:44 75:112 76:36 77:1390 78:39641 79:48788 8:36 80:12934 82:160 83:11360 84:3746 85:13315 86:3032 87:2180 88:1844 89:3088 9:338 90:2848 93:14944 97:8304 98:20538`
Top: `0 grass1`, `79 test8`, `78 test7`, `25 sand9`, `98 sandsea6`.

`engmis4` (`id:count`, 409,600 values):
`0:78512 1:17766 10:24903 100:312 101:6200 14:14228 15:704 16:8288 17:760 18:670 19:478 2:3532 20:4068 21:1230 22:52 23:440 24:2026 25:32494 3:1348 32:44 33:524 4:13474 5:616 6:2840 7:6381 71:108 72:3466 73:6432 74:7166 75:1324 76:1092 77:2752 78:36249 79:36953 8:3312 80:16020 82:124 83:8016 84:2852 85:9134 86:416 87:1208 88:906 89:3854 9:752 90:1524 93:22020 97:7840 98:8218 99:5972`
Top: `0 grass1`, `79 test8`, `78 test7`, `25 sand9`, `10 ground1`.

`battle1` (`id:count`, 589,824 values):
`10:308 32:24 87:3226 89:24678 92:8832 93:28850 97:251930 98:31228 106:13122 107:29568 112:4376 114:716 116:31890 121:161076`
Top: `97 sandsea5`, `121 ground1_winter`, `116 grass6_winter`, `98 sandsea6`, `107 test23`.
Winter ordinals appear in `battle1` and resolve against the same `tiles.lib`
mirror; the V7-85 summer preset atlas (124 names) is **not** the right dictionary
for those ids.

**On the "31 distinct ids" expectation:** V7-85 `:44,225-236` measures **31
distinct ids in the shipped `g32_dump.json`** (range 0..85) — a different map
from these three donor missions. The donor maps measured here have 43 / 50 / 14
distinct ids. No parity between the shipped dump and any donor mission is
claimed.

### 8.3 Named-coordinate and GameObject counts (cross-check against DEEPDEC-05)

| Map | count prefix | declared / parsed named | record-size histogram (B) | `GameObjectBegin` count | first offset |
|---|---:|---:|---|---:|---|
| `bonmis1.map` | `0xe6d612` | 8,777 / 8,777 | 30×2,455; 31×5,981; 32×341 | **7,742** | `0xebd0ec` |
| `engmis4.map` | `0xe76b5c` | 2,832 / 2,832 | 29×117; 30×1,570; 31×1,145 | **12,711** | `0xe9966c` |
| `battle1.map` | `0x24ef77c` | 11,279 / 11,279 | 28×100; 29×1,800; 30×4,627; 31×3,393; 32×1,359 | **10,118** | `0x2550de1` |

All three match DEEPDEC-05 `:38,74,166-170` exactly. `battle1.map` = 56,117,715 B,
SHA-256 `f9a70198e2127cf630976d2f365601e76bf2cc6cac1290256264b392b0898b1a`;
its height grid (`0x1f21d1e`, 147,456 cells) measures −1.100000 / +2.371200 m.

### 8.4 First five decoded placements per map

Offsets are the `int32 15` prefix before `GameObjectBegin`. Floats are raw LE
`f32[0..2]`; roles of the four strings are the DEEPDEC-05 §5 reading
(instance / repeated type / category / owner), not independently re-proven.

| Map | Offset | Category | Type | f32[0..2] | Strings after floats | Mesh hint |
|---|---|---|---|---|---|---|
| bonmis1 | `0xebd0ec` | buildings | polcen | −23.75, 0.0, −140.75 | polcen0.15978 / polcen / buildings / player0 | `polcen.mesh` @`0xebd426` |
| bonmis1 | `0xebda57` | buildings | ukrsta | 106.75, 0.0, −138.75 | ukrsta0.16248 / ukrsta / buildings / player0 | `ukrsta.mesh` |
| bonmis1 | `0xebe3c2` | buildings | eurmil | −13.25, 0.0, −127.25 | eurmil0.16256 / eurmil / buildings / player0 | `eurmil.mesh` |
| bonmis1 | `0xebf05f` | units | peapol | −18.7435, 0.0, −138.4953 | peapol0.16697 / peapol / units / player0 | `peapol.mesh` |
| bonmis1 | `0xebfa9b` | units | peapol | −19.4623, 0.0, −138.0697 | peapol0.16698 / peapol / units / player0 | `peapol.mesh` |
| engmis4 | `0xe9966c` | buildings | engcen | −49.25, 0.0, 17.25 | engcen0.107 / engcen / buildings / player0 | `engcen.mesh` @`0xe999b8` |
| engmis4 | `0xe99fed` | buildings | engart | −65.25, 0.0, 19.25 | engart0.113 / engart / buildings / player0 | `engart.mesh` |
| engmis4 | `0xe9a96e` | buildings | eurmar | −44.25, 0.0, 23.75 | eurmar0.115 / eurmar / buildings / player0 | `eurmar.mesh` |
| engmis4 | `0xe9b2ef` | buildings | enghou | −50.25, 0.0, −14.25 | enghou0.119 / enghou / buildings / player0 | `enghou.mesh` |
| engmis4 | `0xe9bc70` | buildings | enghou | −77.25, 0.0, −6.75 | enghou0.121 / enghou / buildings / player0 | `enghou.mesh` |
| battle1 | `0x2550de1` | units | pikeman | −66.6852, −0.0331, −83.0658 | pikeman0.20844 / pikeman / units / player0 | `pikeman.mesh` @`0x2551298` |
| battle1 | `0x255165e` | units | pikeman | −67.0047, −0.0809, −86.079 | pikeman0.20845 / pikeman / units / player0 | `pikeman.mesh` |
| battle1 | `0x2551edb` | units | pikeman | −66.9299, −0.1056, −87.3654 | pikeman0.20846 / pikeman / units / player0 | `pikeman.mesh` |
| battle1 | `0x2552758` | units | pikeman | −66.131, −0.0868, −87.4127 | pikeman0.20847 / pikeman / units / player0 | `pikeman.mesh` |
| battle1 | `0x2552fd5` | units | pikeman | −66.3335, −0.0782, −86.8416 | pikeman0.20848 / pikeman / units / player0 | `pikeman.mesh` |

DEEPDEC-05 §5 quotes −138.75 as the first bonmis1 float; the bytes at
`0xebd116` decode to **−140.75** (`00 00 be c1`). This tool reports the decoded
bytes; the difference is noted rather than silently reconciled.

### 8.5 Verification of unchanged behaviour and commands

- `--verify bonmis1.map`: 16,274 / 102,400 exact (15.8926%), max abs error
  5.928000 m, bounds delta 0 — identical to §4. `engmis4.map`: 40,327 /
  102,400, max abs error 5.302495 m. `battle1.map` refuses with
  `--verify compares against a 320x320 dump; this map is 384x384`.
- Regenerated `bonmis1_height.json` in `%TEMP%\opencode\v783b\` and ran
  `heightmap_splat.py --dump ... --dry-run`: 320×320 / 102,400 cells, 124
  presets, used id `{0}` only, no missing PNGs. No splat output was written
  during this follow-up; every JSON/PNG from the earlier V7-83 run was deleted
  with the temp dirs (`Test-Path` → `False`).
- Commands (all donor reads read-only; `$tmp =
  C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v783b`):

```powershell
python variant3d/tools/import_donor_map.py MAP --survey
python variant3d/tools/import_donor_map.py MAP --export-placements --limit 5 --out "$tmp\$m.placements.json"
python variant3d/tools/import_donor_map.py MAP --verify
python variant3d/tools/import_donor_map.py "C:\Games\Cossacks 3\data\maps\missions\bonmis1.map" --out "$tmp\bonmis1_height.json"
python variant3d/tools/heightmap_splat.py --dump "$tmp\bonmis1_height.json" --out "$tmp\splat.png" --dry-run
Remove-Item -Recurse -Force $tmp
```

### 8.6 UNVERIFIED / open questions after the extension

1. Float-triplet world meaning, rotation fields and all bytes after the four
   strings in a `GameObject` record — **UNVERIFIED** (DEEPDEC-05 §8:1-4). The
   `.mesh` string is a bounded search hint, not a proven binding.
2. Runtime meaning of four tile indices per cell and the four `1.0f` weights;
   byte 12 and the `FF FF` marker remain opaque (DEEPDEC-05 §8:2-3).
3. Winter ordinal mapping is decoded from the `tiles.lib` mirror, but the
   V7-85 summer atlas has no winter art; no winter-name provenance is asserted.
4. Named-record consumer, height-grid row orientation, `TILE_M`, and visual
   parity remain **UNVERIFIED** / unclaimed. No GPU A/B was run.
5. No donor data, generated JSON, PNG or bytecode was left in the repository;
   no source/asset/config/test/git state changed in this follow-up.
