---
id: V7-83
title: "V7-83 — read-only donor .map relief importer -> heightmap_splat.py dump JSON"
owner: V7-83
scope: "ONE NEW tool (variant3d/tools/import_donor_map.py) + this report ONLY. Donor path read-only; no donor binary copied/executed; no .gd, splat tool, app/, config, test or git changes."
date: 2026-11-24
status: PASS__DONOR_VERIFY_2_MAPS__SPLAT_CONSUMED__TEMP_DELETED__NO_VISUAL_CLAIM
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
