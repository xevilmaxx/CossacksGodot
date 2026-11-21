# TERRAIN_DONOR_PATTERNS — donor `.pattern` format, full family inventory, and port gap audit

Research / deep-dive lane (TDR-2), 2026-11-21.
**Read-only lane.** No donor file was copied into the repo, no Godot run was made, no
project code or asset was edited. Only this document was written.

Evidence labels used throughout:

- **observed** — read directly from bytes / files this session, with a citation or hex.
- **derived** — computed deterministically from observed data (counts, sizes, ratios).
- **inferred** — a best reading of donor conventions; plausible but not proven here.
- **UNVERIFIED** — could not be confirmed; do not treat as fact without re-check.

Donor path (private use only, never redistribute):
`C:\Games\Cossacks 3`. Project root: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.

---

## 1. Sources / sample files inspected

### 1.1 Donor binaries opened as raw bytes (read-only)

All in `C:\Games\Cossacks 3\data\pattern\`. Hex was produced with Python 3.14
`struct` + byte dumps (no file modification).

| Sample | Size (B) | Why chosen |
|---|---:|---|
| `d_frt_big_1.pattern` | 120,560 | big pine/fir forest; explicitly named in task |
| `g_hil1.pattern` | 99,246 | light hill family; named in task |
| `mng_1.pattern` | 3,730 | gold mine; smallest useful sample, named in task |
| `dcr1.pattern` | 24,536 | decor; named in task |
| `k_lake_1.pattern` | 47,336 | lake; named in task |
| `big_hill_1.pattern` | 159,932 | `decor_big`; named in task |
| `d_stn_1.pattern`, `d_tls_1.pattern`, `k_rock_1.pattern` | 18,890 / 77,622 / 17,900 | stones, tiles, extra rocks |
| `n_small_frt_1.pattern`, `fb_1.pattern`, `m_swamp_1.pattern`, `str_new_1.pattern`, `new_year6.pattern`, `l_lake_big_1.pattern` | 2,852 / 3,320 / 36,586 / 20,870 / 15,920 / 45,650 | orphan / unstamped families |

All **710** files were passed through a header/mask validator (`§2.1`), a 710-file
ASCII-string scan (`§2.5`), and a full name inventory (`§3`).

### 1.2 Donor text / metadata (read-only)

| Source | What it gave |
|---|---|
| `data/game/var/generator.cfg` | **60** generator families, **467** referenced pattern names — the authoritative family list and weights (observed). |
| `data/scripts/common.inc/dogenerate.inc` | pattern-stamping pipeline (already documented in `docs/TERRAIN_GEN_RESEARCH.md:34-57`). |
| `data/scripts/common.inc/texturemap.inc:209-216,305-320,823-834` | `n_small_frt_*` / `n_small_frt_lite_*` are placed in the per-cell **forest detail** pass, not from `generator.cfg`. |
| `data/scripts/common.inc/smoothforestborders.inc:110-123` | `fb_1..fb_53` chosen by `floor(1+RandomExt*53)` when `forestType=cForestTypePineFirSpruce`; i.e. **forest-border** clumps. |
| `data/objects/env/*.prop` (e.g. `christmastree.prop`) | text INI-like props: `DefaultMeshName = christmastree.mesh` → resolved to `data/actors/env/christmastree.osm`. |
| `data/actors/env/` | **273** `.osm` environment meshes (observed) — the real renderable asset pool. |

### 1.3 Port files read (read-only)

- `app/tools/donor_gen.py:74-85` — existing `parse_pattern()` (header + bool mask only).
- `app/tools/donor_gen.py:25-27` — explicit comment: object contents are *synthesised*; "the binary object records are engine-specific".
- `app/tools/export_donor_patterns.py:22-36,48-55` — `WANTED` family list; writes only `{"w","h","cells"}`.
- `app/assets/terrain/patterns/donor_patterns.json` — 37 families / 218 named patterns / 266 family entries.
- `app/scripts/pattern_gen.gd:64-83,104-128,203-265` — footprint scaling, family `home()`, and the actual stamp recipes.
- `app/tools/convert_models.py:214-243` — `env_models()` hardcodes only 6 env meshes.
- `app/tools/render_models.py:1-17`, `app/tools/bake_sprites.py:1-9` — sprite bakers.
- `app/scripts/world.gd:219,236,1133-1185` — tree/rock/stump/bush sprite rendering.
- Prior context: `docs/TERRAIN_GEN_RESEARCH.md`, `docs/research/RC_TERRAIN.md:130-133,179-181`.

---

## 2. Format decode

### 2.1 Header and occupancy mask — CONFIDENCE: HIGH (**observed**)

Every `.pattern` begins with two little-endian `int32`:

```
mng_1.pattern @0x00: 08 00 00 00 0a 00 00 00   -> w=8,  h=10
d_frt_big_1  @0x00: 26 00 00 00 39 00 00 00   -> w=38, h=57
big_hill_1   @0x00: 33 00 00 00 38 00 00 00   -> w=51, h=56
```

Immediately after is a grid of `w*h` bytes interpreted as occupancy (nonzero =
occupied). `mng_1 @0x08`: `01 01 01 01 01 01 01 01 01 00 00 00 01 01 01 00 …`
First 16 cells: 9 occupied, 3 empty, 3 occupied, 1 empty.

**Validation, all 710 files:** header+mask length consistent in **710/710**;
`w*h` range 16..9,116; file size 558..518,422 B; mask occupancy ratio
0.196..0.938, mean 0.393 (**derived** from `validate_all.py`). This is exactly
what `donor_gen.py:80-84` already implements, and what `export_donor_patterns.py:50-55`
exports as centred `(dx,dy)` cells. **Footprint confidence: HIGH.**

### 2.2 Beyond the mask: a layered / record-structured object section — CONFIDENCE: MEDIUM (**observed** structure, **UNVERIFIED** semantics)

`donor_gen.py:26` admits the object records are not decoded. Raw bytes show they
are nevertheless highly regular:

**(a) 24-byte records with an id and four float32 fields.** In `mng_1`, starting
at byte `0x18b`, records repeat at a strict 24-byte stride:

```
REC0 @0x18b: a1 00 00 00 | 00 00 80 3f | 00 00 80 3f | 00 00 80 3f | 00 00 80 3f | 00 00 00 00
REC1 @0x1a3: df 00 00 00 | 00 00 80 3f | 00 00 80 3f | 00 00 80 3f | 00 00 80 3f | 00 00 00 00
             ^ int32 161    ^ 1.0f × 4 (0x3f800000)                                  ^ 4 bytes
```

`0x3f800000` = `1.0f` little-endian. Same 24-byte stride is the dominant stride
in **every** dissected pattern (e.g. `d_frt_big_1` 2,071/2,072 consecutive groups;
`big_hill_1` 2,749/2,750; `g_hil1` 1,704/1,705) (**derived**).

**(b) Record "id" field is a byte-sized value, not a proven model ID.** Values
observed range 0..255, with up to 256 distinct values in large patterns
(`d_frt_big_1`, `g_hil1`: 256 distinct). Sample ids for `mng_1`:
`161, 223, 175, 255, 192, 226, 85, 199, …`. **UNVERIFIED** whether this is a
prop/model index, terrain texture index, colour byte or something else. Do **not**
assume it is a mesh reference.

**(c) Parallel int16 flag array.** In `mng_1`, `ff ff` (`-1` as int16 / `65535`
as uint16) occurs 63 times, first at `0xb69`, uniformly 13 bytes apart. For most
dissected patterns the count of `0xffff` values equals the 24-byte-record count
(`mng_1` 63/63, `dcr1` 420/420, `g_hil1` 1706/1705); `d_tls_1` is an exception
(461 flags vs 1,333 records). Semantics **UNVERIFIED**.

**(d) Float planes / additional per-cell arrays.** Chunking `big_hill_1
- header` into 56 blocks of `w*h = 2856` bytes gives:
block 0 = the 0/1 mask; blocks 1-4 = 256-distinct byte planes; blocks 5-27 =
float32 planes whose majority value is `1.0f` (`… 00 00 80 3f 00 00 80 3f …`);
blocks 29-42 = all zero; blocks 43-55 = int16-looking planes with values
`0000`, `ffff`, `0100` (observed). This is consistent with a *structure-of-arrays*
serialisation of per-cell attributes, but the field names are **UNVERIFIED**.

**(e) Mask-length subtlety.** For 9/9 tested samples, the first **N** bytes after
the header are clean 0/1, where N = number of 24-byte records; the tail of the
`w*h`-byte region the port reads contains non-0/1 float bytes
(e.g. `big_hill_1` first non-0/1 at mask index 2750 = N, `k_lake_1` at 812 = N,
`d_tls_1` at 1337 ≈ N=1333). Effects: the port's `bool()` mask adds a few spurious
occupied cells at the tail when `N < w*h`. Magnitude and impact **UNVERIFIED**;
the port's footprint is still directionally correct. Noted as an open question.

### 2.3 No external mesh/texture paths are embedded — CONFIDENCE: HIGH (**observed**)

A scan of all **710** files for:
- asset-extension-like strings (`.mdl|.tga|.png|.dds|.bmp|.jpg|.obj|.3ds|.max|.x|.wav|.avi`) → **0 hits**;
- pure alphabetic runs ≥ 6 chars → **0 hits**;
- path-like strings → 80 hits, all random byte sequences containing `\` or `/`
  (e.g. `d6/yc6Uu` in `desert_plain_2.pattern`), none a real path.

**Therefore a `.pattern` file does not name any mesh, texture or `.prop` asset.**
Any eventual faithful render must resolve the numeric ids through donor engine
tables / `.prop` → `.actor` → `.osm` chains; that chain is **inferred** from
`data/objects/env/christmastree.prop` → `data/actors/env/christmastree.osm`, not
proven for the numeric values in pattern records.

### 2.4 Parser sketch (pseudo-code / Python) — only the HIGH/MEDIUM-confidence parts

```python
def parse_pattern(path):
    b = open(path, "rb").read()
    w, h = struct.unpack_from("<ii", b, 0)          # CONFIRMED, 710/710
    wh = w * h
    # CONFIRMED footprint: w*h bytes, nonzero = occupied.  Port already does this.
    raw = b[8:8 + wh]
    cells = [(x - w//2, y - h//2)
             for y in range(h) for x in range(w) if raw[y*w + x]]

    # MEDIUM confidence: locate 24-byte records by their four 1.0f fields.
    FOUR = b"\x00\x00\x80\x3f" * 4
    first = b.find(FOUR)
    recs = []
    if first >= 4:
        o = first - 4
        while o + 24 <= len(b):
            f = struct.unpack_from("<4f", b, o + 4)
            if not all(abs(v - 1.0) < 1e-6 for v in f):
                break                              # record layout diverges -> stop
            recs.append({"id": struct.unpack_from("<i", b, o)[0],
                         "floats": f, "tail": b[o+20:o+24]})
            o += 24
    # id/floats semantics UNVERIFIED; do not map id -> asset name.
    return {"w": w, "h": h, "cells": cells, "records": recs}
```

### 2.5 Confidence summary

| Item | Label |
|---|---|
| `int32 w`, `int32 h` header; `w*h` byte occupancy mask | **observed / HIGH** |
| Record-like region with 24-byte stride, `int32` + `4×float32(1.0)` | **observed / MEDIUM** |
| `int16 0xffff` parallel flags, float planes, int16 value planes | **observed / MEDIUM** |
| Meaning of record id / floats / flags (model? position? scale? collision?) | **UNVERIFIED** |
| External asset paths inside `.pattern` | **absent / HIGH** (710-file scan) |
| Prop→actor→mesh chain for ids | **inferred / UNVERIFIED** |

---

## 3. Full family taxonomy (all 710 files)

Classification is by filename prefix, mutually exclusive, and sums to 710
(**derived** from a full directory inventory). "Visual role" is **inferred** from
the prefix + `generator.cfg` family membership + donor prop/mesh names; where the
family is not in `generator.cfg` it is marked **orphan** (not stamped by the
vanilla random-map generator this session). "Referenced assets" lists the donor
asset families that the clump's objects would resolve to (**inferred** from
`data/objects/env/*.prop` and `data/actors/env/*.osm`; the `.pattern` files
themselves contain no names — §2.3). "Port status": **ENCODED** = present in
`donor_patterns.json`; **STAMPED** = actually used by a `pattern_gen.gd` recipe;
**MISSING** = absent from the JSON.

| Prefix family | Count | Visual role | Referenced donor assets (inferred) | Port status |
|---|---:|---|---|---|
| `k_plain_*`, `k_small_*` | 80 | bare-earth / small plain scatter decals | `terrainplateau`, `grass`, `smallstones` | **MISSING** |
| `desert_frt_*` (non-`n_`) | 72 | desert forest variants (big/m/s/unique) | `palm`, `palmsmall`, `desertstump`, `drytree`, `burch` | ENCODED (`desert_forests_unique` only; 17 big/m/s unused → **orphan**) |
| `n_desert_frt_*` | 60 | NTM/New-terrain desert forest big/med/small | `palm`, `desert1..5`, `desertstump` | ENCODED (big family **broken**, see §5 C4; med/small 43/43 resolve) |
| `fb_1..fb_53` | 53 | forest-border clumps, pine/fir/spruce (`smoothforestborders.inc:113-114`) | `pine*`, `fir*`, `spruce*` | **MISSING** — **orphan** from cfg, placed by a different script |
| `n_small_frt_*`, `n_small_frt_lite_*` | 41 | per-cell small forest detail (`texturemap.inc:215,317-319,830`) | `pinesmall`, `firsmall`, `burchsmall` | **MISSING** — **orphan** from cfg, placed by texturemap |
| `plt*`, `d_plt*`, `f_plt*`, `j_big_plt*`, `brush_plt*` | 34 | plateau / raised-ground & vegetation patches | `terrainplateau`, `terrainmesh`, `grass`, `burdock`, `fern` | **MISSING** |
| `m_swamp_*`, `k_swamp_*` | 34 | swamp clumps, small/medium/big | `reed`, `lily`, `pinedryswamp`, `pump`, `mud` decals | **MISSING** |
| `frt_b_*`, `frt_m_*`, `frt_s_*`, `f1_from_big3` | 25 | pine forests big/medium/small | `pine*`, `pinesmall*`, `pinestump*` | ENCODED (small **STAMPED** at `pattern_gen.gd:242,255`) |
| `l_lake_*`, `k_lake_*` | 25 | lake edges / water decor clumps | `rocksea`, `smallstonessea`, `reed` | **MISSING** |
| `mng*`, `mni*`, `mnc*` | 18 | gold / iron / coal mines | `minegold`, `mineiron`, `minecoal` (+`*s` small) | ENCODED + **STAMPED** (`pattern_gen.gd:203-237`) |
| `desert_mng*`, `desert_mni*`, `desert_mnc*` | 18 | desert mine props | `minegold`, `mineiron`, `minecoal` | ENCODED (used via `home()` for desert) |
| `k_ravine_*`, `K_ravine_*` | 18 | ravines, incl. big stony variants | `terrainmesh`, `rocks`, `smallstones` | **MISSING** |
| `k_rock_1..18` | 18 | standalone rock outcrops | `rocks`, `landstone`, `stonessea` | **MISSING** — **orphan** (no cfg family) |
| `d_frt_big/mid/small_*` | 17 | pine/fir forests (the `pinefir_*` families) | `pine*`, `fir*` | ENCODED (`d_frt_big_1` dissected; not stamped by rest recipe) |
| `g_mnt_*`, `i_mnt_*` | 17 | mountains (g_mnt in cfg; i_mnt big/long **orphan**) | `terrainmesh`, `rocks`, `stonessea` | **MISSING** |
| `str_new_*`, `str_*`, `b_str_*` | 16 | stoneforests (trees among rocks), new + old | `stones`, `smallstones`, `pine*` | ENCODED (`str_new_*` **STAMPED** `:257`) |
| `desert_plain_*` | 15 | desert plain scatter | `desert1..5`, `smallstonesdesert` | **MISSING** |
| `k_pump_*` | 15 | water pump / well decor | `pump` | **MISSING** — cfg name mismatch (`k_pump_1..9` vs files `k_pump_01..09`) |
| `desert_mnt_*` | 13 | desert mountains / dunes | `terrainmesh`, `desertstump` | ENCODED `desert_mountains` (13/15 resolve; 14/15 missing) |
| `desert_lake_*` | 12 | desert lake / oasis edges | `palm`, `smallstonessea` | **MISSING** |
| `desert_stn_*` | 12 | desert stones | `stonesdesert`, `smallstonesdesert` | ENCODED `desert_stones` |
| `desert_plt_*` | 11 | desert plateaus | `terrainplateau`, `desert1..5` | ENCODED but **BROKEN** (4/4 names missing, §5 C4) |
| `new_year1..10` | 10 | Christmas trees / festive decor (6..10 in cfg) | `christmastree`, `christmastreea`, `gift*` | **MISSING** (1..5 orphan from cfg) |
| `g_frt_*` | 10 | leaf / deciduous forests | `oak*`, `leaftree*`, `burch*` | ENCODED (not stamped) |
| `e_frt_*` | 9 | mixed forests | `pine*`, `oak*`, `burch*` | ENCODED (not stamped) |
| `g_hil1..9` | 9 | light hills | `terrainmesh`, `grass`, `smallstones` | ENCODED (`g_hil1` dissected; **STAMPED** `:259`) |
| `n_desert_mng/mni/mnc_*` | 9 | NTM desert mines | `minegold/iron/coal` | **MISSING** — **orphan** |
| `d_frt_spr_*` | 8 | spruce forests big/medium | `spruce*` | ENCODED (not stamped) |
| `d_stn_1..7` | 7 | stones | `stones`, `smallstones` | ENCODED + **STAMPED** (`:241,256`) |
| `gift1..5` | 5 | gift-box decor (festive) | `gift` | **MISSING** — **orphan** |
| `d_frt_pinedry_*` | 4 | dry-green pine forest | `pinedry*` | ENCODED (not stamped) |
| `hil1..4` | 4 | dark hills | `terrainmesh`, `rocks` | ENCODED + **STAMPED** (`:258`) |
| `d_tls_1..4` | 4 | ground tiles / cracked-earth decals | `terrain` tile textures (already ported to `assets/terrain/blocks/`) | ENCODED + **STAMPED** (`:180-201`) |
| `dcr1..3` | 3 | general decor (bushes / stumps / flowers) | `bushes*`, `flowers`, `plantain`, `pinestump` | ENCODED + **STAMPED** (`:260-261`) |
| `b_frt_b_p_*` | 3 | alternate big pine forest | `pine*` | ENCODED (`forests_pine_big_2`) |
| `big_hill_1` | 1 | large decor hill (`decor_big`) | `terrainmesh`, `rocks` | ENCODED (not stamped by rest recipe) |

**Totals (derived):** 36 prefix families, 710 files.
`generator.cfg` references 467 distinct names in 60 families; **285 of 710 files
are not referenced by any cfg family** (`fb_*`, `n_small_*`, `n_desert_mng/mni/mnc`,
plain `desert_frt_*`, `desert_mng/mni/mnc_1..3`, `desert_plt_*`, `k_rock_*`,
`k_lake_*`, `k_pump_01..09`, `i_mnt_*`, `j_big_plt_*`, `brush_plt_*`, `gift*`,
`new_year1..5`, `K_ravine_2`, etc.) — these belong to other stages (texturemap,
forest-border smoothing) or to DLC/editor content. Conversely **40 cfg names have
no exact file** (naming mismatches like `n_desert_frt_big1` vs `n_desert_frt_big_1`,
`k_pump_1` vs `k_pump_01`, `desert_plt2` vs `desert_plt_2`, plus `desert_mnt_14/15`
and `k_plain_mid_12a/b` which have no file at all).

### 3.1 Port cross-reference summary

**Families encoded in `donor_patterns.json` (37):** mng, mni, mnc, desert_mng/mni/mnc,
tiles, desert_tiles, stones, stoneforests, desert_stones, desert_stoneforests,
hills_dark, hills_light, decor, decor_big, dcr1, dcr2, dcr3, 12 forest families,
desert_forests_big/medium/small/unique, desert_plateau, desert_mountains.

**Families actually stamped by `pattern_gen.gd` (7 + mines + tiles):**
`forests_pine_small`, `stones`, `stoneforests`, `hills_dark`, `hills_light`,
`decor`, `dcr1` (`:249-265`), `tiles` (`:180-201`), `mng/mni/mnc` (`:203-237`),
and the desert aliases via `home()` (`:125-128`) — 11 distinct family names
actually placed. The other **26 of 37** encoded families are **data without a
placement recipe**.

**Families missing entirely (23 cfg families):** `plain_small`, `plain_medium`,
`plain_big`, `plain_huge`, `ravine_big`, `ravine_medium`, `plateau`,
`plateau_small`, `plateau_big`, `mountains`, `stoneforests_old`, `swamp_small`,
`swamp_big`, `swamp_medium`, `lake_small`, `lake_big`, `pump`, `christmas`,
`desert_plain_small`, `desert_plain_big`, `desert_plateau_small`,
`desert_plateau_big`, `desert_lake`. Plus all **orphan** families in §3.

---

## 4. Representative pattern dissections

`N` = number of 24-byte record-like structures found (§2.2); "mask occ" = occupied
bytes / `w*h`. Footprint is `w × h` donor map cells (~1 m/cell: donor map 320 cells
= 160 units, `donor_gen.py:59`). All numbers **observed/derived** this session.

| Pattern | w × h cells | Mask occ | N records | File bytes | Implied visual content (**inferred**) |
|---|---:|---:|---:|---:|---|
| `d_frt_big_1` | 38 × 57 | 920 / 2,166 (42.5%) | 2,072 | 120,560 | large pine/fir forest clump; tall irregular canopy, gaps for paths |
| `g_hil1` | 32 × 56 | 725 / 1,792 (40.5%) | 1,705 | 99,246 | light hill ridge, elongated N–S; decorated with grass/small stones |
| `mng_1` | 8 × 10 | 32 / 80 (40.0%) | 63 | 3,730 | compact gold-mine cluster: pit headframe + ore props + small rubble |
| `dcr1` | 22 × 21 | 184 / 462 (39.8%) | 420 | 24,536 | medium decor scatter — bushes, stumps, flowers, small rocks |
| `k_lake_1` | 30 × 29 | 301 / 870 (34.6%) | 812 | 47,336 | lake / pond edge with reeds and shore stones; irregular holes in mask |
| `big_hill_1` | 51 × 56 | 1,153 / 2,856 (40.4%) | 2,750 | 159,932 | biggest `decor_big` hill; broad plateau-like mass, dense props |
| `n_small_frt_1` | 9 × 7 | 35 / 63 (55.6%) | 48 | 2,852 | tiny per-cell forest detail clump (texturemap stage), dense |
| `fb_1` | 8 × 9 | 41 / 72 (56.9%) | 56 | 3,320 | forest-border edge clump, pine/fir/spruce fringe |
| `new_year6` | 18 × 17 | 131 / 306 (42.8%) | 272 | 15,920 | Christmas/festive clump — trees + gifts |
| `d_stn_1` | 20 × 18 | 125 / 360 (34.7%) | 323 | 18,890 | stone scatter cluster, sparse mask |
| `d_tls_1` | 32 × 44 | 560 / 1,408 (39.8%) | 1,333 | 77,622 | large ground-tile / cracked-earth decal patch |

**Cross-pattern observation (derived):** mask occupancy clusters tightly around
40% (range 19.6–93.8% over all 710; mean 39.3%), i.e. clumps are deliberately
porous rather than solid blocks — consistent with the rejection-sampling intent
documented in `docs/TERRAIN_GEN_RESEARCH.md:33-57`.

**Caution:** the "implied visual content" column is **inferred** from family name
+ generator.cfg membership + donor prop names. It was **not** verified by
rendering a donor pattern (no donor run in this lane), and the numeric record ids
could not be resolved to specific props (§2.2b, §2.3).

---

## 5. Claim table

| # | Claim | Evidence | Method | Verdict | Correction / caveat |
|---|---|---|---|---|---|
| C1 | `.pattern` = `int32 w,h` + `w*h` byte occupancy mask | 710/710 header/mask valid; `donor_gen.py:80-84`; hex `08 00 00 00 0a 00 00 00` | Python `struct` + full inventory | **CONFIRMED** | None |
| C2 | Asserted in task brief: "~711 `.pattern` files" | Directory count = **710** | `Get-ChildItem -Filter *.pattern \| Measure-Object` + Python `os.listdir` | **CORRECTED** | Use **710**, not 711 |
| C3 | Files embed model/texture paths | 710-file scan: 0 asset-extension strings, 0 alpha runs ≥6 | regex over all bytes | **REFUTED** | No path strings; numeric ids only, semantics UNVERIFIED |
| C4 | Port encodes all desert families correctly | `donor_patterns.json`: `desert_forests_big` 17/17 names missing (`n_desert_frt_big1` vs file `n_desert_frt_big_1`); `desert_plateau` 4/4 missing (`desert_plt2` vs `desert_plt_2`); `desert_mountains` 2/15 missing | JSON cross-check with filesystem | **CORRECTED** | 23/266 family entries point to non-existent patterns; those picks fail at `pattern_gen.gd:137-138` |
| C5 | Port uses the full 60-family donor set | JSON has 37 families; recipe stamps 7 + mines/tiles | JSON + `pattern_gen.gd:249-265` | **CORRECTED** | 23 cfg families missing; 26 of the 37 encoded families have no stamp recipe |
| C6 | `n_small_frt_*` / `fb_*` are generator.cfg families | Not in cfg; found in `texturemap.inc:215,317-319,830` and `smoothforestborders.inc:113-114` | text search of all donor scripts | **CORRECTED** | Different pipeline stages; not stamped by dogenerate.inc |
| C7 | Object records hold position/scale/rotation | 24-byte stride `[int32 0..255][4×1.0f][4B]` observed; floats all exactly 1.0; no position-like values seen | hex + `struct.unpack` | **UNVERIFIED** | Do not claim position/scale/rotation; field meaning unknown |
| C8 | `.pattern` collision flags exist and are decoded by the port | Occupancy mask is used as collision/footprint (`donor_gen.py:288-300`, `pattern_gen.gd:85-103`); extra `int16 0xffff` array observed but undecoded | code read + bytes | **PARTIAL** | Footprint collision YES; any separate collision flag field UNVERIFIED |
| C9 | Record count ≈ `w*h` and mask region is exactly `w*h` | First N mask bytes clean 0/1 where N = record count; non-0/1 bytes appear at index N in `w*h` region for `big_hill_1`, `k_lake_1`, `d_tls_1` | byte scan | **PARTIAL / UNVERIFIED** | Port's `bool()` mask may pick up a few spurious tail cells; impact unmeasured |
| C10 | 711 patterns are all used by the generator | 285/710 files unreferenced by any cfg family | cfg vs filesystem set diff | **REFUTED** | 285 are orphan/other-stage/DLC assets |

---

## 6. Recommendations — concrete build tickets

All tickets are **private-use conversion only**. Never copy a donor binary into
the repo; run the existing tools against the installed game to produce derived
`.obj`/`.png`/`.json` in `app/assets/`.

| Ticket | Scope / file to change | Acceptance criteria (measurable) |
|---|---|---|
| **T1 — Fix broken family name resolution** | Extend `app/tools/export_donor_patterns.py` (or add a normalisation step) so cfg names are mapped to the actual filenames: `n_desert_frt_bigN`→`n_desert_frt_big_N`, `desert_pltN`→`desert_plt_N`, `k_pump_N`→`k_pump_0N` (01..09), `k_ravine_2`→`K_ravine_2`. Regenerate `donor_patterns.json`. | `sum(1 for fam,entries in json['families'].items() for n,_ in entries if n not in json['patterns']) == 0` (currently 23). `desert_forests_big` resolves ≥17 patterns. |
| **T2 — Extend the env-model conversion table** | `app/tools/convert_models.py:224-243` `env_models()` — currently 6 entries. Add families in priority order: (a) `spruce*`, `pinedry*`, `pinesmall*`, `firsmall*`, `pinestump*`; (b) `stones*`, `smallstones*`, `landstone*`, `rocksea*`; (c) `bushes*`, `flowers*`, `plantain*`, `fern*`, `reed*`; (d) `christmastree*`, `gift*`; (e) `pump*`, `desert1..5`, `palm*`. Then run `render_models.py` for sprites. | `app/assets/models/manifest.json` contains ≥40 env `sid`s (currently ~9 total env-ish); `sprites_hi/<sid>.png` exists for each new `sid`; a screenshot shows distinct spruce vs pine vs dry-pine silhouettes. |
| **T3 — Decode object records properly (research follow-up)** | New private tool under `app/tools/` (e.g. `probe_pattern_records.py`) implementing §2.4, with an optional donor-side correlated probe (place one pattern in donor editor, compare screen props to record ids). | For ≥10 patterns, a stable field layout is documented with byte offsets and at least one field is *proven* (not inferred) to map to a prop/mesh; result appended to this doc with `observed` label. Until then keep records synthesised. |
| **T4 — Wire the missing terrain families into placement** | `app/scripts/pattern_gen.gd` `recipes` (`:249-265`) and `home()`: add `mountains`, `g_mnt_*` families, `plain_small/medium/big/huge`, `swamp_*`, `lake_*`, `pump`, `ravine_*`, `christmas`, `stoneforests_old`. Add cfg family entries to `donor_patterns.json` via `WANTED` in `export_donor_patterns.py:22-36` if needed. | `donor_patterns.json` families ≥ 55/60; `pattern_gen.gd` stamps ≥ 12 distinct families (currently 7 + mines/tiles); a 20-seed `scan_map.py` sweep shows no determinism regressions. |
| **T5 — Wire the other-stage pattern families** | New GDScript stage (or extend `mapgen.gd`) implementing `texturemap.inc` small-forest pass (`n_small_frt_*`) and `smoothforestborders.inc` (`fb_*`) analogous to `pattern_gen.gd` stamps. | ≥1 `fb_*` pattern placed on every pine/fir/spruce forest edge in a screenshot; `n_small_frt_*` placed on ≥30% of forest-mask cells; both use the existing footprint test. |
| **T6 — Stone/rock silhouette variety** | Uses T2 assets; `world.gd:1181-1223` `_prop_tex` pools extended with `rocksea*`, `landstone*`, `smallstones*` variants chosen by pattern id or position hash. | ≥4 visually distinct rock silhouettes appear in one screenshot; sprite count in `assets/models/sprites_hi/` for `rock*` ≥ 4. |
| **T7 — Christmas / gift seasonal clumps** | T2 assets + `pattern_gen.gd` family `christmas` + `data.gd` season flag stub. | With `season=christmas`, ≥3 `new_year6..10` stamps appear in a 320×320 map and render with `christmastreed`/`gift` sprites; no donor file copied. |
| **T8 — Documentation / gate** | Add a `scan_patterns.py` check to `app/tools/test_all.py` that fails when `donor_patterns.json` family entries reference missing patterns (T1) and prints family coverage. | `python app/tools/test_all.py` passes; coverage report lists 60 cfg families with ENCODED/STAMPED/MISSING status matching this doc. |

**Suggested order:** T1 (cheap, fixes silent no-op stamps) → T2 (unlocks visuals) →
T4/T5 (placement) → T6/T7 (polish) → T3 (deep decode) → T8 (gate).

---

## 7. Open questions

1. **Record semantics (highest priority).** What exactly are the 24-byte records'
   `int32` (0..255), four `1.0f` floats, and 4-byte tail? Position/scale/rotation
   was *not* observed — the floats are uniformly 1.0. Are they colour/alpha or
   per-cell defaults? Needs a donor-side correlated experiment or decompiler pass
   (T3).
2. **Mask length N vs `w*h`.** Is the true mask array length N (record count),
   `w*h`, or something else? The port reads `w*h`; for 9/9 samples N < `w*h` and the
   mask tail contains float bytes. Quantify how many spurious footprint cells this
   creates on a 160×160 port map.
3. **The `int16 0xffff` array.** Stride 13 in `mng_1`, count usually = N. Is it a
   parent/owner index, LOD flag, or collision bit? Why 13 bytes?
4. **Orphan families.** Are `k_rock_*`, `i_mnt_*`, `j_big_plt_*`, `brush_plt_*`,
   `gift*`, `new_year1..5`, `n_desert_mng/mni/mnc` used by a DLC config, a map
   editor, or dead content? Only `fb_*` and `n_small_*` were resolved to another
   script this session.
5. **Naming mismatches.** Are `n_desert_frt_big1` (cfg) and `n_desert_frt_big_1`
   (file) the same logical pattern with a cfg typo, or did the game load both via
   some alias table? Same for `k_pump_1` vs `k_pump_01`.
6. **Footprint units.** Confirmed the port treats one mask cell as one donor map
   cell (~1 m). UNVERIFIED against the donor engine's `gPatternMask` index space;
   the ~40% occupancy statistic is consistent across families but not proof.
7. **Asset resolution chain.** The `.prop`→`.actor`→`.osm` chain was observed for
   `christmastree` only. It is **inferred**, not proven, that the numeric ids in
   pattern records index that chain. T3 should test this on a forest pattern.
8. **Collision.** The port uses the occupancy mask as the collision/footprint
   gate. Any *additional* per-object collision flag in the 24-byte records is
   **UNVERIFIED**.

---

*End of document. No donor asset was copied into the repository; all donor paths
above are references for private-use conversion tooling only.*
