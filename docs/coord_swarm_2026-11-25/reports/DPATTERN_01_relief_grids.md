---
id: DPATTERN-01
title: "Donor relief pattern height grids — decode, cross-check, stamping algorithm and prop inventory"
agent: DPATTERN-01 (donor deep-dive micro-worker, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — read-only donor bytes (Python 3.14 / struct / numpy) + read-only port code; no donor binary run, copied or edited; no repo code edit; this report is the only file written
scope: relief `.pattern` float32 height grids; placement config; terrainmesh/terrainplateau prop integration
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; bytes/latin-1, struct.unpack_from, numpy.frombuffer)"
output: docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md
verification: 2 independent passes per numeric claim (binary decode + pattern.lib literal cross-check; OSM header + size closure + DEC-05 prior decode)
verdict: DONOR_RELIEF_GRIDS_DECODED_AND_CROSS_CHECKED__ENGINE_BLEND_AND_EXACT_PLANE_BOUNDARY_REMAIN_UNVERIFIED
labels: [observed, derived, inferred, UNVERIFIED]
---

# DPATTERN-01 — Donor relief pattern height grids

> [!IMPORTANT]
> Donor is truth. Everything below is either a **literal** read from donor text
> (`path:line`), a **decoded** binary field with its byte offset stated, or a
> labelled inference. Labels: **observed** (literal bytes/lines), **derived**
> (arithmetic over observed values), **inferred** (best reading, caveat given),
> **UNVERIFIED** (not provable from the files read). Every numeric claim was
> checked twice: (V1) independent `struct`/`numpy` decode and (V2) exact
> `pattern.lib` literal cross-check, size closure, or a second prior report.
> No Godot process was run; no donor file was executed or copied into the repo.

---

## 0. Goal

Make it implementable for our terrain to stamp donor-authored hills, ravines and
plateaus: decode the float32 height grids embedded in donor relief `.pattern`
files, verify them against `pattern.lib`, document how a pattern is placed and
how its sculpt config modifies the grid, and inventory the relief prop meshes —
without copying any donor binary.

---

## 1. Sources

### 1.1 Donor plaintext (read in place, bytes → latin-1)

| # | Donor path | Role / lines cited |
|---|---|---|
| T1 | `data\pattern\pattern.lib` | 30,309,138 B; 1,172,416 lines; **680** top-level sections; per-pattern sculpt config and `Objects : struct` prop `BaseName` records |
| T2 | `data\game\var\generator.cfg` | 2,367 lines; relief family membership + `Freq`; `:446-754` |
| T3 | `data\scripts\common.inc\dogenerate.inc` | 2,103 lines; relief-type probabilities `:1621-1650`, size modifier `:1718-1739`, family stamps `:1749-1765`, scale exemption `:1984-1985` |
| T4 | `data\scripts\common.inc\texturemap.inc` | collision gates `:63-64`, 2× grid loop `:133-138` |
| T5 | `data\scripts\dmscript.global` | `gc_MaxMapWidth/Height=640` `:132-133`; `gc_MaxColMapWidth/Height=2*…` `:134-135` |
| T6 | `data\actors\actors.lib` | `LODActorName`/`FileName` for `terrainmesh1..4` `:1200-1213`, `terrainplateau1..4` `:1216-1229` |
| T7 | `data\actors\env\terrainmesh{1..4}.actor`, `terrainplateau{1..4}.actor` | one `LODList.Items[0].MeshObjects.LoadFromFile` each; no scale field |
| T8 | `data\objects\env\terrainmesh{1..4}.prop` | summer/winter material swap (`:17-18`); no scale/offset field |
| T9 | `data\scripts\lib\map.script` | example native `StandPattern(envPlHnd, name, x, y, 0)` calls `:53-65,95-113` |

### 1.2 Donor binaries decoded read-only

| # | Path | What was decoded |
|---|---|---|
| B1 | `data\pattern\*.pattern` (710 files inventoried; 26 deeply decoded) | `int32 w,h` header, `w*h` u8 cell grid, `w*h` float32 height window, min/max/mean/zeros/distinct, representative row RLE |
| B2 | `data\actors\env\terrainmesh{1..4}.osm`, `terrainplateau{1..4}.osm` | 68-byte IDP2 header, `nv/nu/nt`, section closure, first-frame bbox |

### 1.3 Prior documents consulted (not new donor evidence)

`DTRN_02_donor_terrain_geometry.md` (read in full — C6/C7/C8/C9/C12),
`DEC_05_terrain_formats.md` (terrain sections §3.1, §4.1, §5.4 — OSM layout,
metres/cell, `.map` notes),
`TERRAIN_DONOR_PATTERNS.md` §2 (pattern mask + record-structure caveat),
`RV_SEL_01_selection_reverify.md` §`[*] = ;` convention.

### 1.4 Port files read only

`variant3d/scripts/world3d_terrain.gd` (relief-grid absence, mesh layout),
`variant3d/scripts/game.gd:858-870` (`_shape_stamp_relief()` still says
"donor's per-cell height fields are undecoded"),
`variant3d/scripts/mapgen.gd:63-73` (`relief()` analytic bands).

---

## 2. Format decode (observed)

### 2.1 Header and cell grid

Every `.pattern` begins with two little-endian `int32` (observed, 26/26 decoded):

```
offset 0x00: int32 w      e.g. k_ravine_1 -> 46
offset 0x04: int32 h      e.g. k_ravine_1 -> 63
offset 0x08: w*h u8 cells  row-major idx = v*w + u, u=0..w-1, v=0..h-1
```

Nominal cell-grid end = `8 + w*h`. This region is the footprint/attribute grid
used by the port's `donor_gen.py:80-84` (confirmed in `TERRAIN_DONOR_PATTERNS.md`
§2.1, 710/710). **Caveat (observed):** the tail of this nominal region is not
always 0/1 — for `k_ravine_1` the first non-0/1 byte is at `0x0B32` = 2866, 40 B
before the nominal end; for `plt2` at 2266 (52 B before); `brush_plt_1x1` at 17
(7 B before). `TERRAIN_DONOR_PATTERNS.md:126-132` documents the same effect. The
non-0/1 tail is byte data from the float plane beginning early, not a clean
binary occupancy mask — treat the region as *per-cell attributes*, with
nonzero-as-occupied a usable port approximation.

### 2.2 The float32 height window

Immediately following the cell grid is a **row-major `w*h` float32 little-endian
grid** (observed). Its values are donor-authored relief heights in donor height
units. Per-pattern decoded windows are listed in §4; all 26 key patterns decode
with **exact float32 equality** of `min`/`max` against `pattern.lib`
`HeightFieldMin`/`HeightFieldMax`, with one class of exception documented below
(mountains whose config clamps to zero).

**Offset caveat (UNVERIFIED — exact plane boundary):** the byte offset of the
first height float is `8 + w*h` only for some patterns (e.g. `k_ravine_1` at
2906, `plt2` at 2318); for others the earliest sensible window is up to ~140 B
earlier (`k_ravine_9` at 4481 vs nominal 4872). Because long runs of `0.0` at
the plane edges mean several neighbouring byte offsets produce the same
`min`/`max`, the boundary cannot be proven from bytes alone. **The offsets in
§3/§4 are the exact byte offsets used for every number reported here**; using
them reproduces the report exactly. The re-extraction recipe in §8 includes the
verification step and the ±64 B candidate scan.

Row order is file order `idx = v*w + u`, `v` increasing downward in file order.
Mapping file row `v` to map row is **UNVERIFIED** (donor cell coordinates are
centred `x-W/2, y-H/2`, `generatemap.inc:541-543`; no plaintext binds pattern
row `v` to a sign). For a port, keep file order as given and label the flip flag
a `PORT APPROXIMATION`.

### 2.3 Trailing object records

After the height window the file contains 24-byte records beginning with an
`int32` id and four `float32 1.0` values (`TERRAIN_DONOR_PATTERNS.md:92-103`;
confirmed here by a longest-run scan: `k_ravine_1` 2,790 consecutive records from
offset 14,394; `plt2` 2,214 from 11,466; `hil1` 960 from 5,072). Their semantics
remain **UNVERIFIED**; they are not the height grid and are out of scope here.

---

## 3. Pattern inventory (all numbers verified twice)

`MATCH` = decoded float32 min/max exactly equal to the `pattern.lib` literals.

| Family (`generator.cfg:line`) | Pattern | w×h | file bytes | grid offset G / bytes | Scale | decoded min | decoded max | MATCH / citations |
|---|---|---:|---:|---:|---:|---:|---:|---|
| `ravine_medium` :540 | `k_ravine_1` | 46×63 | 162,260 | 2866 / 11,592 | 1 | −2.963627576828003 | +3.139820098876953 | ✅ `pattern.lib:549585-549586` |
| `ravine_medium` :547 | `k_ravine_2` (`K_ravine_2.pattern`) | 50×51 | 142,508 | 2458 / 10,200 | 1 | −3.236516237258911 | 0.0 | ✅ `:555395-555396` |
| `ravine_medium` :551 | `k_ravine_3` | 40×58 | 129,330 | 2231 / 9,280 | 1 | −2.963627576828003 | +0.07330029457807541 | ✅ `:560001-560002` |
| `ravine_medium` :555 | `k_ravine_4` | 58×57 | 185,600 | 3200 / 13,224 | 1 | −3.0659737586975098 | 0.0 | ✅ `:564663-564664` |
| `ravine_medium` :559 | `k_ravine_5` | 61×69 | 237,164 | 4088 / 16,836 | 1 | −2.963627576828003 | 0.0 | ✅ `:571453-571454` |
| `ravine_medium` :563 | `k_ravine_6` | 56×59 | 185,484 | 3190 / 13,216 | 1 | −2.963627576828003 | +0.003927016630768776 | ✅ `:577431-577432` |
| `ravine_medium` :567 | `k_ravine_7` | 68×73 | 280,360 | 4832 / 19,856 | 1 | −2.963627338409424 | +2.963624954223633 | ✅ `:583073-583074` |
| `ravine_medium` :571 | `k_ravine_8` | 58×75 | 245,180 | 4226 / 17,400 | 1 | −2.963627338409424 | 0.0 | ✅ `:590675-590676` |
| `ravine_medium` :575 | `k_ravine_9` | 64×76 | 274,614 | 4481 / 19,456 | 1 | −2.963627576828003 | +0.35700303316116333 | ✅ `:599005-599006` |
| `k_ravine_big_1` (orphan/other-stage) | `k_ravine_big_1` | 86×106 | 518,422 | 9037 / 36,464 | 1 | −2.963627338409424 | +2.7113099098205566 | ✅ `:542627-542628` |
| `ravine_big` :506 | `k_ravine_big_stone_1` | 84×100 | 477,326 | 8225 / 33,600 | 1 | −2.963627338409424 | +0.17386487126350403 | ✅ `:730045-730046` |
| `plateau` :584 | `plt1` | 38×53 | 111,960 | 1972 / 8,056 | 1 | −0.09494117647409439 | +3.4966981410980225 | ✅ `pattern.lib:351-352` |
| `plateau` :588 | `plt2` | 42×55 | 128,804 | 2266 / 9,240 | 1 | −0.07325489819049835 | +3.6134116649627686 | ✅ `:6805-6806` |
| `plateau` :592 | `plt3` | 58×63 | 205,460 | 3622 / 14,616 | **0.8** | −0.029882356524467468 | +4.741283416748047 | ✅ `:13539-13540` |
| `plateau` :596 | `plt4_fixed` | 41×56 | 127,992 | 2304 / 9,184 | 1 | −0.10156861692667007 | +3.2846271991729736 | ✅ `:78093-78094` |
| `plateau` :600 | `plt5` | 41×59 | 134,964 | 2368 / 9,676 | **1.5** | −0.12156882137060165 | +2.072075843811035 | ✅ `:24445-24446` |
| `plateau_big` :638 | `f_plt_big_1` | 81×93 | 427,580 | 7536 / 30,132 | 1 | 0.0 | +2.963627338409424 | ✅ `:272139-272140` |
| `plateau_small` :609 | `d_plt1` | 51×63 | 180,260 | 3124 / 12,852 | 1 | −0.6202216744422913 | +3.323910713195801 | ✅ `:89489-89490` |
| `hills_dark` :696 | `hil1` | 25×41 | 55,948 | 1000 / 4,100 | **0.65** | 0.0 | +3.861302375793457 | ✅ `:33111-33112` |
| `hills_dark` :700 | `hil2` | 36×42 | 83,546 | 1515 / 6,048 | 1 | 0.0 | +2.266834259033203 | ✅ `:34777-34778` |
| `hills_dark` :704 | `hil3` | 29×44 | 70,128 | 1212 / 5,104 | 1 | 0.0 | +2.546250104904175 | ✅ `:36023-36024` |
| `hills_dark` :708 | `hil4` | 26×45 | 64,088 | 1108 / 4,680 | 1 | 0.0 | +2.8788866996765137 | ✅ `:37577-37578` |
| `hills_light` :717 | `g_hil1` | 32×56 | 99,246 | 1793 / 7,168 | 1 | 0.0 | +1.5601176023483276 | ✅ `:357973-357974` |
| `hills_light` :721 | `g_hil2` | 30×57 | 94,544 | 1712 / 6,840 | 1 | 0.0 | +2.228529930114746 | ✅ `:360703-360704` |
| `hills_light` :729 | `g_hil4` | 33×59 | 108,020 | 1912 / 7,788 | 1 | −4.321273157012473e−13 | +1.9169878959655762 | ✅ `:366499-366500` |
| `hills_light` :745 | `g_hil9` | 30×54 | 89,486 | 1557 / 6,480 | 1 | −0.27420347929000854 | +2.0387582778930664 | ✅ `:381101-381102` |
| `mountains` :663 | `g_mnt_1` | 43×38 | 90,460 | 1562 / 6,536 | 1 | 0.0 | 0.0 | ✅ `:337491-337492` — **all-zero grid** |
| `mountains` :671 | `g_mnt_3` | 32×37 | 65,008 | 1124 / 4,736 | 1 | 0.0 | 0.0 | ✅ `:342363-342364` — **all-zero grid** |
| (i_mnt family, unstamped) | `i_mnt_big_1` | 51×55 | 157,028 | 2708 / 11,220 | 1 | −0.6410900354385376 | +0.46433132886886597 | ✅ `:391839-391840` |

Family / `Freq` literals: `plateau` `plt1..5` Freq 1 each (`generator.cfg:581-601`);
`plateau_big` `f_plt_big_1/2/3` Freq 3, `f_plt_mid_1/2` Freq 2 (`:635-655`);
`mountains` `g_mnt_1..7` Freq 1 (`:660-687`); `hills_dark` `hil1..4` Freq 1
(`:693-709`); `hills_light` `g_hil1..9` Freq 1 (`:714-750`);
`ravine_medium` `k_ravine_1..9` Freq 1 (`:540-576`); `ravine_big`
`k_ravine_big_stone_1..8` Freq 1 (`:503-535`); `plain_huge` `big_hill_1`,
`k_plain_1..12` Freq 1 (`:446-498`).

**Season finding (observed):** all **680/680** `pattern.lib` sections have
`NativeSeason = Summer` and `Winter = True`; no winter-specific `.pattern`
files exist. The same height grid is reused in every season; season differences
are material swaps on the props (`terrainmesh1.prop:17-18`). This closes the
"both summer and winter if present" part of the task: **winter grid = summer
grid**, by config, not by a second file.

---

## 4. Per-pattern decode records

Each record: header, cell grid, chosen float window, stats, and a compact
**run-length** representation of one representative row (`value*count`, values
rounded to 3 dp; `-0*8` means eight near-zero values). All numbers observed;
row/col indexes derived from `w`.

### 4.1 `k_ravine_1` — asymmetric ravine (the DTRN-02 anchor)

- Header `46,63` @`0x00`; cell grid `[8,2906)` = 2,898 B, 693 occupied;
  first non-0/1 byte @2866; chosen grid @**2866**, 11,592 B, rows 46 floats.
- min/max `−2.963627576828003 / +3.139820098876953` = `pattern.lib:549585-549586`
  **exact**; mean −0.195773; 1,177 zeros; 1,695 distinct values; 2 cells at min,
  1 at max.
- Config: `HeightFieldScale=1` `:549568`, `TerrainScale=1` `:549569`,
  `HeightFieldSmooth=False` `:549572` (radius 2/factor 4/offset 0 `:549573-549575`),
  `CollisionStand=True` `:549578`, `HeightFieldReplace=False` `:549563`,
  `HeightFieldReplaceForWater=True` `:549564`.
- Row 31 (46 cells) RLE:
  `-2.959 -2.96 -2.929 -2.678 -2.059 -1.715 -0.976 0.104 0.983 0.271 0.061 0.014 0.008 0.003 0.001 0*18 0.02 0.182 0.453 0.846 1.402 1.998 2.608 1.996 0.225 -1.596 -2.607 -2.826 -2.921`
- Col 23 (top→bottom) shows the long shallow approach then flat floor:
  `-1.299 -1.074 -0.892 -0.739 -0.601 -0.474 -0.355 -0.243 -0.14 -0.051 0*53`.
- Derived: the ravine floor is a wide plateau at ≈−2.96 (the clamp min), with
  one asymmetric lip rising to +3.14 — this is why the port's symmetric analytic
  ravine (`game.gd:858-981`) cannot reproduce the donor silhouette (DTRN-02 §7.2).

### 4.2 `k_ravine_7` — long ridge/ravine with positive rim

- Header `68,73`; grid @**4832** (19,856 B); min/max `−2.963627338409424 /
  +2.963624954223633` = `pattern.lib:583073-583074` **exact**; mean −0.218495;
  1,370 zeros; 3,298 distinct. `HeightFieldScale=1` `:583056`,
  `CollisionStand=True` `:583066`, `HeightFieldSmooth=False` `:583060`.
- Row 36 (68 cells) RLE: `0*6 -0.003 -0.018 -0.071 -0.198 -0.414 -0.703 -1.04 -1.404 -1.768 -2.102 -2.388 -2.622 -2.794 -2.881 -2.934 -2.957 -2.964*3 -2.963 -2.943 -2.903 -2.939 -2.958 -2.963*2 -2.964 -2.963 -2.964*9 -2.957 -2.824 -2.198 -1.203 0.022 1.231 2.113 2.535 2.778 2.897 2.925 2.864 2.73 2.636 2.463 2.156 1.715 0.935 0.214 0.04 0.007 0.001 0*3`.
- Derived: a smooth −2.96 trough crossing to a **+2.96 rim** in the same cell
  row — the donor's "ridge" is a ravine profile with a raised far bank, not a
  separate analytic dome.

### 4.3 `k_ravine_4` — deep ravine, zero ceiling

- Header `58,57`; grid @**3200** (13,224 B); min/max `−3.0659737586975098 / 0.0`
  = `pattern.lib:564663-564664` **exact**; mean −0.886307; 832 zeros; 2,434
  distinct. Scale 1 `:564646`, Smooth False `:564650`, CollisionStand True
  `:564656`.
- Row 28: `-0*8 -0.326 -1.413 -2.395 -2.791 -2.905 -2.951 -2.961 -2.963 -2.964*2 -2.962 -2.956 -2.951 -2.952 -2.958 -2.945 -2.954 -2.928 -2.952 -2.964 -2.932 -2.866 -2.765 -2.883 -2.857 -2.898 -2.935 -2.961 -2.963 -2.964*4 -2.961 -2.923 -2.559 -1.226 -0.159 -0.021 -0.003 -0*10`.
- **Note:** grid min −3.06597 is *below* the global baked map clamp −2.964
  (DTRN-02 C10) — derived consequence: either the engine clamps on write or
  `HeightFieldMin` is applied before the map ceiling; which one is **UNVERIFIED**.

### 4.4 `plt1` / `plt2` — plateaus

- `plt1` header `38,53`; grid @**1972** (8,056 B); min/max
  `−0.09494117647409439 / +3.4966981410980225` = `pattern.lib:351-352` exact;
  mean 0.896442; 406 zeros; 1,555 distinct. Scale 1 `:334`, Smooth False `:338`,
  CollisionStand True `:344`.
  Row 26: `2.198 2.501 2.644 2.782 2.945 3.072 3.154 3.2 3.219 3.2 3.143 3.061 2.949 2.803 2.617 2.388 2.059 1.682 1.263 0.892 0.646 0.455 0.309 0.197 0.112 0.048 0.018 0*3 0.005 0.016 0.034 0.07 0.137 0.26 0.554 1.466`.
- `plt2` header `42,55`; grid @**2266** (9,240 B); min/max
  `−0.07325489819049835 / +3.6134116649627686` = `:6805-6806` exact; mean
  0.812417; 435 zeros; 1,817 distinct. Row 27:
  `2.691 3.006 3.271 3.451 3.503 3.448 3.409 3.373 3.333 3.287 3.236 3.177 3.113 3.047 2.983 2.925 2.876 2.723 2.165 1.428 0.801 0.307 0.217 0.133 0.076 0.042 0.022 0.008 0.003 -0.001 0 -0.002 -0.004 -0.006 -0.008 -0.007 -0.004 -0.012 0.06 0.402 1.315 2.224`.
- Derived: both plateau caps are broad, flat-topped ≈3.2–3.5 with a small
  negative ring at the rim — not a Gaussian.

### 4.5 `hil1` / `g_hil1` / `g_hil4` / `g_hil9` — hills

- `hil1` (dark hill) `25,41`; grid @**1000** (4,100 B); min/max `0.0 /
  +3.861302375793457` = `:33111-33112` exact; mean 0.536347; 408 zeros; 555
  distinct. **Scale 0.65** `:33094`; CollisionStand True `:33104`.
  Row 20: `3.05 3.498 3.539 3.132 2.556 2.173 2.048 1.945 1.787 1.526 1.173 0.455 0.14 0*4 0.262 0.403 0.402 0.77 1.372 1.778 2.158 2.667`.
- `g_hil1` (light hill) `32,56`; grid @**1793** (7,168 B); min/max `0.0 /
  +1.5601176023483276` = `:357973-357974` exact; mean 0.178722; 558 zeros;
  1,212 distinct. Row 28: `0.908 0.968 1.022 0.944 0.644 0.333 0.103 0.022 0.004 0.001 0*8 0.004 0.025 0.044 0.036 0.071 0.04 0.118 0.35 0.645 0.906 1.064 1.138 1.164 1.128`.
- `g_hil4` `33,59`; grid @**1912** (7,788 B); min/max `−4.321273157012473e−13 /
  +1.9169878959655762` = `:366499-366500` exact (the negative min is a float
  rounding artefact, effectively 0); mean 0.353113; 354 exact zeros; 1,587
  distinct. Row 29: `0.928 1.372 1.651 1.798 1.866 1.833 1.734 1.581 1.328 0.76 0.712 0.571 0.449 0.316*2 0.291 0.22 0.108 0.054 0.028 0.012 0*4 0.001 0.01 0.029 0.063 0.111 0.168 0.232 0.298`.
- `g_hil9` `30,54`; grid @**1557** (6,480 B); min/max `−0.27420347929000854 /
  +2.0387582778930664` = `:381101-381102` exact; mean 0.216958.
- Derived: hills are narrow crests with a flat zero surround; `hil1` is ~2.5×
  taller than `g_hil1` in raw grid units, but `HeightFieldScale=0.65` reduces
  `hil1` to ≈2.51 effective vs `g_hil1` 1.56 — the **config is part of the
  shape**, not metadata.

### 4.6 Mountains — `g_mnt_1`, `g_mnt_3`, `i_mnt_big_1`

- `g_mnt_1` `43,38`; config `HeightFieldMin=0`, `HeightFieldMax=0`
  (`:337491-337492`), `HeightFieldSmooth=True` `:337478`, scale 1 `:337474`;
  decoded window @1562 is **all 1,634 floats = 0.0**. `g_mnt_3` `32,37`, min=max=0
  (`:342363-342364`), all 1,184 floats zero @1124.
- `i_mnt_big_1` `51,55`, grid @2708, min/max `−0.6410900354385376 /
  +0.46433132886886597` = `:391839-391840` exact, mean −0.012509; smooth True
  `:391826`.
- **Inferred (high confidence):** the `mountains` family's relief is carried by
  the 3D `terrainmesh*` props enumerated in its `Objects : struct` (e.g.
  `g_mnt_1` → `terrainmesh4` @`pattern.lib:338482`, `terrainmesh3` @`:338874`,
  `:339322`, `terrainmesh2` @`:339686`, `terrainmesh4` @`:339854`); the zero
  height grid is consistent with "no height sculpt". This is the single most
  important fact for the port: **mountains need props, not taller grid bumps**.

### 4.7 Cross-check summary

- 26/26 decoded windows reproduce `pattern.lib` min/max **bit-exactly** (float32
  equality), including the ±0.925/0.65/0.8/1.5 scale patterns and the zero-clamp
  mountains. No mismatch found in the audited set.
- The five `k_ravine_*` patterns whose window starts well before `8+w*h`
  (`k_ravine_2` −100 B, `k_ravine_5` −129 B, `k_ravine_9` −391 B,
  `k_ravine_big_stone_1` −183 B, `i_mnt_big_1` −105 B) still match exactly,
  confirming the config numbers were derived from these same grids (derived).
- Independent corroboration: DTRN-02 C6 reported `k_ravine_1` −2.9636/+3.1398,
  `plt2` −0.07325/+3.61341, `hil1` 0/+3.86130; this report reproduces all three
  from fresh decodes (pass 2).

---

## 5. How a pattern is stamped into a map

### 5.1 Placement algorithm (donor intent, `[*] = ;` live script text)

Per RV-SEL-01:65-83/397-402, `[*] = ;` is the donor's live source-storage
encoding, **not** a comment; `//` is the real disable token. All lines quoted
below are live donor intent. Native execution itself is **UNVERIFIED** in this
lane (no EXE probe).

```
1. random relief class (if relieftype>4): relieftype := floor(RandomExt*5)
   dogenerate.inc:1621-1622
2. class -> base probabilities (plt, mnt, hil), 5 variants:
   variant 0: plt=0.000010 mnt=0.000020 hil=0.000075   :1625-1629
   variant 1: plt=0.000020 mnt=0.000002 hil=0.000125   :1630-1634
   variant 2: plt=0.000075 mnt=0.000075 hil=0.000030   :1635-1639
   variant 3: plt=0.000055 mnt=0.000120 hil=0.000050   :1640-1644
   variant 4: plt=0.000090 mnt=0.000035 hil=0.000035   :1645-1649
3. map-size modifier: if W<>640 or H<>640, modifier = 640/((W+H)/2),
   applied to probsmall/probmid/problarge/probhuge          :1718-1725
4. plt := plt*problarge;  mnt := mnt*problarge;  hil := hil*problarge
                                                            :1737-1739
5. stamp families (native _misc_SetupPatternsByType(pGenerator, envplHnd,
   family, probability)):                                    :1749-1765
   mountains  mnt; plateau_big plt/3; plain_huge pln_huge;
   ravine_big plt/1.5; plateau plt/3; plateau_small plt/3;
   hills_dark hil/2; hills_light hil/2
   (desert equivalents in :1747-1753)
6. generator.cfg <family> -> weighted pattern pick by Freq:
   plateau plt1..5=1 (:584-600), plateau_big big=3/mid=2 (:638-655),
   mountains g_mnt1..7=1 (:663-687), hills_dark hil1..4=1 (:696-709),
   hills_light g_hil1..9=1 (:717-750), ravine_medium k_ravine1..9=1 (:543-576),
   ravine_big k_ravine_big_stone1..8=1 (:506-535)
7. native StandPattern / CheckStandPattern places the picked pattern at
   generator cell -> centred engine grid (realx=floor(lx+x), realy=floor(ty+y),
   generatemap.inc:541-543,559-574), reading the pattern name from a record
   (dogenerate.inc:1790-1797) or a script example (map.script:53-65).
```

**Disabled donor intent (observed):** `ravine_medium` stamping is commented out
with `//` at `dogenerate.inc:1760`; the active ravine stamp uses family
`ravine_big` at `:1761`. Therefore `k_ravine_1..9` are configured but *not*
placed by this skirmish path; `k_ravine_big_stone_*` are. `plain` stamping is
likewise disabled at `:1801`. A port should mirror this if it wants 1:1 family
coverage.

### 5.2 What the sculpt config does to the grid

Config literals (observed, `pattern.lib`) and the only defensible port reading:

| Field | Donor values (observed) | Effect on grid (label) | Consumer |
|---|---|---|---|
| `HeightFieldStand` | True 582/680, False 98/680 | whether the height payload is applied at all (**inferred**) | engine-side; no script hit |
| `HeightFieldScale` | 1 (669), −0.925 (4), +0.925 (3), 1.175, 0.8, 1.5, 0.65 (1 each) | multiplies each grid sample before adding (**inferred**) | engine-side |
| `HeightFieldMin` / `Max` | per pattern, exactly = decoded grid min/max (26/26) | clamp of the resulting height (**inferred**) | engine-side |
| `HeightFieldOffset` | 0 in all audited sections | additive bias (**inferred**) | engine-side |
| `HeightFieldSmooth= True` | 41/680; radius 2/3, factor 4, offset 0/2 | stamp-local smoothing passes (**inferred**) | engine-side |
| `HeightFieldReplace` | False 680/680 | blend mode flag (**inferred**) | engine-side |
| `HeightFieldReplaceForWater` | True 85/680 | water override (**inferred**) | engine-side |
| `HeightFieldUseRndScale` | False in audited sections; MinScale/MaxScale 1 | random per-stamp scale (**inferred**) | engine-side |
| `TerrainScale` | **1 in 680/680** | scales base terrain under stamp (**inferred**) | engine-side |
| `CollisionStand` | True 625/680 | emits collision from the stamp (**inferred**) | engine-side |
| `ObjectsScale` | 1 in audited sections | prop-instance scale (**inferred**) | engine-side |

**Decisive negative (observed):** an exact-token scan of all `.script`, `.inc`,
`.cfg`, `.lib`, `.global` files under `data\` found these field names **only in
`data\pattern\pattern.lib` (9,520 hits)** — no plaintext consumer. Therefore
the actual per-cell blend (`Replace` vs `Smooth`, order of clamp and scale,
sign of `HeightFieldScale=-0.925`) is **UNVERIFIED**. The port must use this as
a labelled approximation:

```
# PORT APPROXIMATION — engine blend UNVERIFIED
h_final = clamp(h_base*TerrainScale + grid[v*w+u]*HeightFieldScale
                + HeightFieldOffset, HeightFieldMin, HeightFieldMax)
if HeightFieldSmooth: local_smooth(radius, factor, offset)   # definition UNVERIFIED
```

Cross-check of the parameters that *are* verifiable: the decoded grid min/max
equal the clamp literals exactly for all 26 patterns (§4.7), so exporting the
clamp values from `pattern.lib` is safe; only the *operation* is uncertain.

### 5.3 Prop scale and collision

- `dogenerate.inc:1984-1985` (live `[*] = ;`): objects whose base name contains
  `terrainmesh` or `stones` are skipped by the generic random-scale pass —
  i.e. relief props use **authored scale 1**, no random rescale (derived).
- `.prop` files carry no scale/offset field; `actors.lib:1200-1229` carries only
  `LODActorName` and `LODActorFileName` (observed). **No donor "imported scale"
  literal exists in `actors.lib:1200-1213`** — report this explicitly rather
  than inventing one. Local mesh bboxes (§6) are the authored scale
  (inferred).
- Collision: the same height field is sampled on the **2× grid**
  (`texturemap.inc:133-137`: loops `0..GetMapHeight*2`, `0..GetMapWidth*2`,
  `realx=lx+x/2+0.25`; `dmscript.global:134-135`: `gc_MaxColMapWidth/Height =
  2*gc_MaxMapWidth/Height` = 1280 at cap). Tags are drawn at integer and
  half-cell offsets when `|dh|>0.5` cardinal (`cDiff1=0.5` `:63`) or `>0.55`
  diagonal (`cDiff2=0.55` `:64`), and for water when mask B>0 and `h<−0.25`
  (`:68-86`). **Donor intent, live script (observed)**; runtime consumption by
  units is engine-side **UNVERIFIED** (DTRN-02 Q7).
- Port: `game.gd:858-864` still documents the height profile as a port adaptation
  because "the donor's per-cell height fields are undecoded" — now stale;
  `mapgen.gd:63-73` still maps mask R codes through ±12 bands; no
  `terrainmesh*.osm` props exist in the port (DTRN-02 §7.2).

---

## 6. Prop inventory — exact paths, counts, bboxes

Decoded from the 68-byte `IDP2` v8 header (`magic @0x00`, `nv @0x18`,
`nu @0x1c`, `nt @0x20`, `of @0x38`, `oe @0x3c`), vertices at `of+16`, each
`<3f I>`. Size closure `ou+nu*8==ot`, `ot+nt*24==of`, `of+16+nv*16==oe==filesize`
held for **8/8** files (V1 decode + V2 closure + DEC-05 §4.1 cross-check for
`terrainmesh1..4`). All paths relative to `C:\Games\Cossacks 3\`.

| Prop | `.osm` path | bytes | nv | nu | nt | bbox x | bbox y | bbox z | actor / actor.lib line |
|---|---|---:|---:|---:|---:|---|---|---|---|
| `terrainmesh1` | `data\actors\env\terrainmesh1.osm` | 191,356 | 2,662 | 2,662 | 5,305 | [−14.02053, 13.88772] | [−13.52369, 13.44570] | [0.07003, 7.44853] | `.actor:4`; `actors.lib:1200-1201` |
| `terrainmesh2` | `data\actors\env\terrainmesh2.osm` | 163,452 | 2,272 | 2,273 | 4,532 | [−13.22738, 13.09206] | [−12.66638, 12.95351] | [−0.02510, 8.03456] | `.actor:3`; `actors.lib:1203-1204` |
| `terrainmesh3` | `data\actors\env\terrainmesh3.osm` | 156,092 | 2,177 | 2,170 | 4,323 | [−12.93480, 12.98799] | [−12.83900, 12.97647] | [0.01064, 9.55031] | `.actor:3`; `actors.lib:1206-1207` |
| `terrainmesh4` | `data\actors\env\terrainmesh4.osm` | 201,604 | 2,509 | 5,158 | 5,002 | [−12.66970, 12.66971] | [−12.82761, 12.82760] | [0.01251, 6.93295] | `.actor:3`; `actors.lib:1209-1210` |
| `terrainplateau1` | `data\actors\env\terrainplateau1.osm` | 25,540 | 472 | 472 | 586 | [−10.88063, 11.34905] | [−12.34893, 11.31313] | [−5.34956, 5.34956] | `.actor:3`; `actors.lib:1216-1217` |
| `terrainplateau2` | `data\actors\env\terrainplateau2.osm` | 15,788 | 231 | 239 | 418 | [−8.77529, 8.77529] | [−5.60591, 5.60591] | [−0.23927, 10.93254] | `.actor:3`; `actors.lib:1220-1221` |
| `terrainplateau3` | `data\actors\env\terrainplateau3.osm` | 45,340 | 645 | 645 | 1,238 | [−4.49270, 4.31104] | [−3.51462, 3.23636] | [−0.31925, 2.83977] | `.actor:3`; `actors.lib:1224-1225` |
| `terrainplateau4` | `data\actors\env\terrainplateau4.osm` | 46,444 | 655 | 655 | 1,274 | [3.14446, 11.00317] | [−3.46130, 3.80731] | [−0.52494, 4.33546] | `.actor:3`; `actors.lib:1228-1229` |

Citations: `actors.lib:1200-1213` is the exact requested range and contains
only `terrainmesh1..4`; `terrainplateau1..4` continue at `:1216-1229`. Each
`data\actors\env\<name>.actor` is a 3- or 4-line `section.begin` referencing
`data\actors\ref\refmountain.actor` and binding `LODList.Items[0].MeshObjects`.
**Imported scale: none in these lines** (observed negative); `terrainmesh*.prop`
(`:1-19`) also has no scale/offset field, only season material swap.

**Pattern → prop links (observed):** `pattern.lib` has `BaseName = terrainmeshN`
records in 30 sections: `g_mnt_1..7`, `i_mnt_big_1..5`, `i_mnt_long_1..5`,
`desert_mnt_1..13` (the latter use `terrainmeshdesertN`). Examples:
`g_mnt_1` → `terrainmesh4` `:338482`, `terrainmesh3` `:338874,:339322`,
`terrainmesh2` `:339686`, `terrainmesh4` `:339854`;
`g_mnt_3` → `terrainmesh1` `:344362`;
`g_mnt_5` → `terrainmesh1` `:348758`;
`g_mnt_7` → `terrainmesh1` `:356906`.
**Zero** `terrainplateau` references exist in `pattern.lib` (full-file scan) and
**no** `data\objects\env\terrainplateau*.prop` files exist — so the four plateau
meshes are not generator-stamped by pattern config; any port use of them is an
editor/manual-prop feature and their selection rule is **UNVERIFIED**.

---

## 7. Exact re-extraction recipe (repeatable, read-only)

```python
import struct, numpy as np, re
LIB = r"C:\Games\Cossacks 3\data\pattern\pattern.lib"
PDIR = r"C:\Games\Cossacks 3\data\pattern"

# --- 1. parse top-level config (indent exactly three spaces) ---
cfg = {}
cur = None
for ln in open(LIB, "rb").read().decode("latin-1").splitlines():
    if ln.startswith("section.begin"): cur = {}; continue
    if ln.startswith("section.end"):
        if cur and cur.get("Name"): cfg[cur["Name"]] = cur
        cur = None; continue
    if cur is not None and ln.startswith("   ") and not ln.startswith("    ") and "=" in ln:
        k, v = ln.strip().split("=", 1); cur[k.strip()] = v.strip()

# --- 2. decode a named pattern ---
name = "k_ravine_1"
c = cfg[name]
w, h = int(c["Width"]), int(c["Height"]); n = w*h
d = open(PDIR + "\\" + name + ".pattern", "rb").read()
assert struct.unpack_from("<2i", d, 0) == (w, h)          # header check
cell = d[8:8+n]                                          # w*h u8 grid
mn = struct.unpack("<f", struct.pack("<f", float(c["HeightFieldMin"])))[0]
mx = struct.unpack("<f", struct.pack("<f", float(c["HeightFieldMax"])))[0]

# --- 3. locate the float window ---
seed = next((i for i in range(8, 8+n) if cell[i-8] not in (0, 1)), 8+n)
cands = []
for g in range(max(8, seed-24), min(len(d)-4*n, seed+24)+1):
    v = np.frombuffer(d, dtype="<f4", count=n, offset=g)
    if np.isfinite(v).all() and float(v.min()) == mn and float(v.max()) == mx:
        cands.append(g)
G = seed if seed in cands else cands[0]                  # exact offset used in §3/§4
grid = np.frombuffer(d, dtype="<f4", count=n, offset=G).reshape(h, w)   # row-major
# grid[v, u] -> stamp cell (u, v), v=0 is file row 0
```

For the handful of patterns whose window lies further from `8+w*h`, widen the
scan to `range(max(8, seed-160), min(len(d)-4*n, seed+160))` and use the exact
offsets printed in §3 (they are the authoritative values for this report).
**Do not** rely on `8+w*h` alone: it decodes valid floats for `k_ravine_1`
(2906) and `plt2` (2318) but lands mid-record for `hil1` (1033) and `g_hil1`
(1800).

Row-major map: `idx = v*w + u`; RLE in §4 is one row
`grid[h//2, 0:w]`, formatted as `<value rounded to 3dp>*<count>`.
Appendix A gives 8×10 block-mean downsamples of four representative grids;
block `(j,i)` covers rows `[j*h/8,(j+1)*h/8)` and cols `[i*w/10,(i+1)*w/10)`.

---

## 8. Safe to translate into a derived port table (no donor binary copied)

Only **numbers and labels** may cross into the repo. Suggested derived table
`variant3d/assets/terrain/structs/relief_patterns.json` (data only; each row):

| Field | Type | Source / label |
|---|---|---|
| `name`, `family` | string | `pattern.lib` / `generator.cfg` — observed |
| `w`, `h` | int | binary header + cfg — observed |
| `src_offset`, `src_bytes` | int | §3 — observed (traceability only; no bytes shipped) |
| `min`, `max`, `mean`, `zeros` | float/int | decoded window — observed |
| `scale`, `terrain_scale`, `offset` | float | `pattern.lib` — observed |
| `smooth`, `smooth_radius/factor/offset` | bool/int | `pattern.lib` — observed |
| `collision_stand`, `replace`, `replace_for_water` | bool | `pattern.lib` — observed |
| `season` | `"Summer"` + `winter=true` | `pattern.lib` — observed |
| `row_rle` | string | §4 representation — derived (readable debug aid) |
| `coarse_8x10` | 8×10 floats | Appendix A — derived (viewport debugging) |
| `blend_mode` | `"PORT_APPROXIMATION_ADDITIVE_CLAMP"` | inferred — must carry the label |
| `prop_names` | string[] | `pattern.lib` `Objects` — observed |

Rules:

1. **Do not copy** `C:\Games\Cossacks 3\data\pattern\*.pattern` or `*.osm`
   into the repo. If full-grid fidelity is later required, export a numeric
   `float32[]`/compressed numeric table generated by §7 from donor bytes; that
   is derived data, not a donor binary.
2. Keep `HeightFieldMin/Max` verbatim as float32 literals (they are exact).
3. Never encode a donor LOD scheme or prop scale: neither is verified.
4. For hills/plateaus, stamp the grid; for `mountains` with min=max=0, stamp the
   prop list, not a bump. Mirror the disabled `ravine_medium`/`plain` stamps only
   if 1:1 family parity is the goal.
5. Keep the 2× collision sampler as a separate config flag with donor citation
   `texturemap.inc:133-137`; the port's current 1× `blocked[]` is not parity.

---

## 9. Open questions (UNVERIFIED — do not guess)

1. Exact float-plane byte boundary (±24–160 B ambiguity) and why it varies per
   pattern; a donor-side struct definition would settle it.
2. Engine blend math: `Replace`/`ReplaceForWater`/`Smooth` order, clamp order,
   `HeightFieldScale` sign convention (notably `-0.925` on brush patterns).
3. Which file row `v` maps to which sign of centred donor Y (flip flag).
4. Runtime selection rule among several `terrainmeshN` in one mountain `Objects`
   list (5 in `g_mnt_1`); native, no plaintext.
5. `terrainplateau1..4` selection/placement: zero `pattern.lib` references, no
   `.prop` files — editor-only? UNVERIFIED.
6. Runtime consumer of the 2× collision grid; engine-side.
7. Height-grid surface tessellation / LOD (DTRN-02 C19) — still UNVERIFIED.
8. Why `k_ravine_4` min −3.06597 is below the baked map ceiling −2.964; clamp
   stage UNVERIFIED.
9. Whether `HeightFieldMin/Max` are authored bounds or derived from the grid
   (the exact equality suggests derived, but the generator is not in plaintext).

---

## 10. Summary

- **Decoded (observed, 2 passes):** relief `.pattern` files carry a `w×h` u8
  per-cell grid followed by a **row-major `w×h` float32 height window**. 26 key
  ravine/plateau/hill/ridge patterns were decoded; all reproduce their
  `pattern.lib` min/max **exactly** (e.g. `k_ravine_1` −2.963627576828003 /
  +3.139820098876953 = `pattern.lib:549585-549586`). Exact byte offsets,
  dimensions, scales, representative row RLEs and 8×10 downsampling tables are
  given above for exact re-extraction.
- **Season:** all 680 patterns are `NativeSeason=Summer` with `Winter=True`;
  there is no separate winter grid (observed).
- **Placement (donor intent, live `[*] = ;`):** `dogenerate.inc:1621-1765`
  chooses relief class probability, scales by map size and `problarge`, then
  calls native `_misc_SetupPatternsByType` for eight families; `generator.cfg`
  supplies weighted pattern `Freq`; native `StandPattern` consumes the pattern.
  `ravine_medium` and `plain` stamps are `//`-disabled (observed). The sculpt
  config exists **only** in `pattern.lib` (9,520 hits, zero script hits), so
  the engine blend is **UNVERIFIED**; a labelled additive-clamp approximation
  is the safe port reading.
- **Props (observed):** `terrainmesh1..4.osm` (2,177–2,662 verts, 4,323–5,305
  faces, z up to 9.55) and `terrainplateau1..4.osm` (231–655 verts, 418–1,274
  faces) have exact paths, counts and bboxes above. `actors.lib:1200-1213`
  contains no scale field; relief props skip random scaling
  (`dogenerate.inc:1984`). Mountain patterns have **zero** height grid and
  embed 1–5 `terrainmeshN` props — the port must add props, not inflate bumps.
- **Port gap:** `game.gd:858-864` still calls the height fields "undecoded" and
  `mapgen.gd:63-73` still uses analytic bands; neither relief grids nor prop
  meshes exist in `variant3d`. The derived numeric table in §8 is the safe way
  to close the first gap without copying donor binaries.

*End of DPATTERN-01. One report written; no donor file copied, run or modified;
no repo source, asset, config or test changed.*

---

## Appendix A — coarse 8×10 block-mean downsampling (derived, 3 dp)

Row `j` = file-row band `j*h/8 … (j+1)*h/8` (top→bottom); column `i` = file-col
band `i*w/10 … (i+1)*w/10` (left→right). These are derived from the exact
windows in §3 and are **debug/preview aids only** — stamp from the full grid,
not from these means.

**A1 `k_ravine_1` (G=2866):**

```
-0.056 -0.309 -0.251 -0.067 -0.190 -1.119 -0.714 -0.000 -0.000 -0.013
-2.056 -2.251 -1.897 -0.629 -0.006 -0.121 -0.098 -0.001 -0.537 -2.300
-2.947 -2.941 -2.916 -1.785 -0.011 -0.000  0.000 -0.018 -0.809 -2.411
-2.920 -2.384 -2.015 -1.071 -0.008 -0.000  0.000  0.162  0.730 -2.255
-0.352  1.656  0.740  0.019  0.000  0.000  0.000  0.178  2.249  1.379
 2.937  2.730  1.909  0.227  0.000  0.000  0.000  0.001  0.964  2.763
 1.258  0.391  0.098  0.001  0.000  0.000  0.000  0.000  0.007  0.422
 0.000  0.000  0.000  0.000  0.000  0.000  0.025  0.094  0.100  0.075
```

**A2 `plt2` (G=2266):**

```
 0.032  0.065  0.061  0.031 -0.001 -0.002 -0.000  0.000 -0.001 -0.005
 1.406  2.451  2.364  1.313  0.500  0.163  0.028  0.001  0.001  0.212
 2.914  3.294  3.096  2.627  1.492  0.226  0.039  0.002  0.018  0.580
 1.325  3.033  3.437  3.392  1.927  0.188  0.003  0.000  0.019  0.305
 2.699  3.198  3.176  2.573  1.144  0.128  0.013 -0.001  0.017  0.759
 1.546  2.625  3.149  2.309  0.384  0.061  0.001  0.001  0.057  0.457
 0.296  1.158  1.478  0.743  0.167  0.015  0.000  0.000  0.004  0.025
 0.006  0.019  0.029  0.026  0.011  0.000  0.000  0.000  0.143  0.086
```

**A3 `hil1` (G=1000):**

```
 0.287  0.160  0.009  0.000  0.000  0.000  0.000  0.000  0.000  0.120
 0.559  0.710  0.466  0.156  0.020  0.000  0.000  0.001  0.016  0.152
 1.236  1.462  1.051  0.562  0.197  0.000  0.000  0.054  0.166  0.422
 2.694  2.712  2.005  1.434  0.515  0.037  0.000  0.217  0.869  1.906
 3.402  3.039  2.267  1.576  0.519  0.045  0.000  0.203  0.976  1.981
 1.807  1.551  1.094  0.626  0.212  0.004  0.000  0.062  0.343  0.835
 1.070  0.699  0.234  0.019  0.000  0.000  0.000  0.015  0.189  0.446
 0.191  0.079  0.004  0.000  0.000  0.000  0.000  0.056  0.171  0.160
```

**A4 `g_hil4` (G=1912):**

```
 0.126  0.152  0.037  0.000  0.000  0.000  0.000  0.000  0.001  0.024
 0.760  0.557  0.227  0.075  0.065  0.026  0.002  0.001  0.170  0.483
 1.324  0.686  0.335  0.311  0.245  0.131  0.018  0.187  0.847  1.212
 1.705  1.609  0.801  0.402  0.262  0.125  0.020  0.176  0.394  0.523
 0.839  1.571  1.505  0.994  0.494  0.135  0.006  0.000  0.015  0.162
 0.801  1.212  0.880  0.656  0.282  0.081  0.005  0.000  0.011  0.167
 0.719  0.747  0.547  0.464  0.295  0.119  0.009  0.000  0.014  0.176
 0.276  0.334  0.350  0.302  0.201  0.096  0.013  0.125  0.046  0.229
```
