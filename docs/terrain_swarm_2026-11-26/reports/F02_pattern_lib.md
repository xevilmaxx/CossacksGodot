---
id: F02
title: "`pattern.lib` decoded — text section database, 680 records, family catalogue, line/byte offset map"
agent: "worker F02 (DONOR-FIRST terrain swarm, 2026-11-26)"
date: 2026-11-26
status: REPORT LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; bytes + latin-1, no donor binary executed/copied)"
scope: "data/pattern/pattern.lib container layout, record boundaries, name↔file↔family mapping, numeric metadata, cross-check vs *.pattern bytes"
verdict: "TEXT_DATABASE_NOT_BINARY_CONTAINER__680_SECTIONS__KNOWN_OFFSETS_ARE_1_BASED_LINE_NUMBERS__12_GRID_CROSS_CHECKS_BIT_EXACT__NO_PARITY_CLAIM"
---

# F02 — `pattern.lib` reverse-engineering

## Executive summary

1. **[O] `pattern.lib` is NOT a binary container.** It is a 30,309,138-byte
   plaintext `section.begin`/`section.end` database with CRLF (`0D 0A`) line
   endings, 1,172,417 split lines, **680 top-level sections**, 680 unique
   `Name` values, 205,571 matched `struct.begin`/`struct.end` pairs and one
   blank CRLF line between sections. There is **no binary header, no record
   count field, no index table, no string table and no packed data blocks** in
   the file. The "record count" is implicit: count column-0 `section.begin`.
   (`C:\Games\Cossacks 3\data\pattern\pattern.lib:1-39`, `:1171115-1172415`,
   byte 0..30309138; verified by full-file scan.)
2. **[O] Fixed 37-field prologue.** Every section begins with the *same* 37
   keys in the *same* order at lines `section.begin+1 … +37` (680/680). The
   variable part is one or more nested struct blocks (`Objects`, `Waters`,
   `Decals`) followed by column-0 `section.end`. `HeightFieldMin` is always
   `+30`, `HeightFieldMax` always `+31` from the section start line.
3. **[D] All five "known byte offsets" from prior work are 1-based LINE
   numbers, not byte offsets.** `pattern.lib:730045-730046`, `:33111-33112`,
   `:366499-366500`, `:6805-6806`, `:549585-549586` land exactly on
   `HeightFieldMin`/`HeightFieldMax` pairs of five sections. Their byte starts
   are 18,877,479; 854,933; 9,458,861; 173,669; 14,196,248 respectively (§5.2).
4. **[O] Name→file is 680/680** (case-insensitive exact match to
   `data\pattern\*.pattern`), but the donor has **710 `.pattern` files**: 30
   files have no `pattern.lib` section (§5.3).
5. **[O] Family membership lives in `data\game\var\generator.cfg`, not in
   `pattern.lib`.** Its `Patterns : struct.begin` tree has **64 `Name =`
   family groups** and **493 `Pattern =` / `Freq =` refs**; 452 refs match a
   section by exact name, 489/493 after a documented normaliser (§5.3), 426 /
   463 unique sections respectively. 217 sections remain outside any family
   (editor brushes, `i_mnt_*`, `j_big_plt_*`, `fb_*`, `n_small_frt_*`, …).
6. **[O] "Mines" are not a family**: no section name contains "mine". Instead
   `mng/mni/mnc` sections embed object props `minegold`, `mineiron`,
   `minecoal` (winter `minegolds/minecoals/mineirons` in `desert_m*`) at
   `pattern.lib:713410`, `:715244`, `:716910`, `:1170134`, `:1171156`,
   `:1168944`. **[I] `mng/mni/mnc` read as mine-gold / mine-iron / mine-coal.**
7. **[O] Twelve independent cross-checks against `.pattern` bytes pass**:
   `Width`/`Height` equals the binary `int32 w,h` header for 679/680 sections
   (one mismatch, `m_swamp_12_old`) and all 12 audited float grids reproduce
   `HeightFieldMin/Max` bit-exactly as float32 (§5.8). No donor-parity claim:
   engine-side use of these values is **UNVERIFIED**.

---

## Evidence table

| # | Evidence (donor path : line / byte) | Observation / label | Used for |
|---|---|---|---|
| E1 | `pattern.lib:1` byte 0 — `section.begin\r\n` | [O] file starts with plaintext marker, not magic bytes | container type |
| E2 | `pattern.lib:1-39`, `:41-79`, `:1171115-1172415`, byte 0..30309138 | [O] 680 column-0 `section.begin`/`section.end` pairs, 679 two-byte gaps, trailing `\r\n` | record count / byte arithmetic |
| E3 | `pattern.lib:2-38` (plt1), `:322-358`, all 680 sections | [O] identical 37 keys at fixed relative lines 1..37 | prologue layout |
| E4 | `pattern.lib:351-352` byte 8,856/8,897 | [O] `plt1` min/max literals | offset mapping, grid check |
| E5 | `pattern.lib:33111-33112` byte 854,933/854,956 | [O] `hil1` min/max | given offset |
| E6 | `pattern.lib:366499-366500` byte 9,458,861/9,458,904 | [O] `g_hil4` min/max | given offset |
| E7 | `pattern.lib:549585-549586` byte 14,196,248/14,196,285 | [O] `k_ravine_1` min/max | given offset |
| E8 | `pattern.lib:6805-6806` byte 173,669/173,710 | [O] `plt2` min/max | given offset |
| E9 | `pattern.lib:730045-730046` byte 18,877,479/18,877,518 | [O] `k_ravine_big_stone_1` min/max | given offset |
| E10 | `pattern.lib:338482` byte 8,733,756 | [O] `BaseName = terrainmesh4` inside `g_mnt_1` | mountain props |
| E11 | `pattern.lib:359-387` byte 9,340 … (plt1) | [O] `Objects : struct.begin` → `[*]` → `RaceName`,`BaseName`,`Position`,`Direction`,`Up`,`Scaling` (X,Y,Z,W) | nested record layout |
| E12 | `pattern.lib:638257-638286` (k_lake_1) | [O] `Waters : struct.begin` → `[*]` → `Name = x25y32`, `Width`, `Height`, `Position` | water records |
| E13 | `generator.cfg:67-154`, `:69`, `:98`, `:127` | [O] `Patterns` tree, `Name = mng/mni/mnc`, `Pattern = …`, `Freq = …` | family source |
| E14 | 64 `Name =` groups at `generator.cfg:69 … :2314` | [O] 64 families, 493 refs, 4 duplicate family names | family table |
| E15 | `pattern.lib:713410`, `:715244`, `:716910` | [O] `BaseName = minegold/mineiron/minecoal` in `mng_1/mni_1/mnc_1` | mines |
| E16 | `mng_4.pattern` etc. header @byte 0..7; `k_ravine_1.pattern` grid @G=2866 | [O] `int32 w,h` and bit-exact float grid min/max (12 entries) | cross-check |
| E17 | `m_swamp_12_old.pattern` byte 0..7 vs `pattern.lib:905523+2..+3` | [O] lib `17×20` vs binary `18×23` | mismatch / risk |
| E18 | `pattern.lib` full scan of `         BaseName = ` lines | [O] 39,780 object records, 235 distinct BaseName; no `mine*` in section *names* | object catalogue |

Prior art read (not new donor evidence): `DPATTERN_01_relief_grids.md` §2/§3/§8,
`G07_relief_plan.md:190-224`, `CORRECTIONS.md:82,103`,
`EVIDENCE_INDEX.md:61`, `H01_donor_layers.md:124-145`. Their offsets were
independently re-derived here; **F01 (concurrent) was not consulted.**

---

## Method

1. Read `pattern.lib` as raw bytes with Python `open(...,'rb')`, split on
   `b'\r\n'`, build a prefix-sum table `offs[i] = byte start of line i+1`.
   No donor file was modified, executed or copied into the repo.
2. Detect records as lines exactly equal to `b'section.begin'` /
   `b'section.end'` at column 0 (`\r\n` line endings confirmed: 1,172,416
   CRLF, zero bare LF/CR).
3. Extract the 3-space-indented `Key = Value` prologue; verify the ordered key
   tuple is identical across all 680 sections (1 distinct order).
4. Extract 3-space nested block starts (`Objects`, `Waters`, `Decals`) and
   6-space `[*]` records; count 39,780 object records.
5. Parse `generator.cfg` by indentation (9-space `Name =` = family,
   15-space `Pattern =` / `Freq =` = member) to build family→patterns.
6. Cross-check each section's `Name` against the 710 `.pattern` filenames and
   `Width`/`Height` against the binary header `struct.unpack('<ii', b[:8])`.
7. For 12 named entries, decode `w*h` float32 values at the offsets used by
   prior work and compare `min`/`max` to float32-cast literals; also scan a
   ±256-byte window to test boundary uniqueness.
8. All scripts lived in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode`
   (outside the repo); the only repo file written is this report.

---

## Findings — exact layout, offsets and structs

### 5.1 Container layout (no binary header/index)

**[O] Global layout:**

```
byte 0        : "section.begin\r\n"            ; line 1, column 0
byte 16       : "   Name = <latin-1 string>\r\n" ; line 2
...           : 37 fixed "   Key = Value\r\n" lines (lines 2..38)
line 39       : optional "   Objects : struct.begin\r\n" (nested, 3-space)
                 optional "   Waters : struct.begin\r\n"
                 optional "   Decals[*] : struct.begin\r\n"
last line     : "section.end\r\n"               ; column 0
next line     : "\r\n"                          ; 2-byte separator (679 of them)
byte 30309136 : final section.end end; 2 trailing bytes -> 30309138
```

**[D] Byte arithmetic closure:** sum of 680 section spans = 30,307,778 B;
679 separators × 2 = 1,358 B; trailing 2 B; total = 30,307,778 + 1,358 + 2 =
30,309,138 B = file size. **[O] Gap distribution:** all 679 gaps are exactly
2 bytes. There is no header word, no count field, no offset table: **[O] the
only "index" is linear scan order plus the `Name` string.**

**[O] Fixed prologue** (key, relative line from `section.begin`, present count):

| +line | Key | type (observed literal form) | +line | Key | type |
|---:|---|---|---:|---|---|
| 1 | `Name` | string | 20 | `HeightFieldSmoothOffset` | int |
| 2 | `Width` | int | 21 | `PatternMaskStand` | bool |
| 3 | `Height` | int | 22 | `PatternMaskReverceStand` | bool (sic) |
| 4 | `TilesStand` | bool | 23 | `CollisionStand` | bool |
| 5 | `GameObjectsStand` | bool | 24 | `OffsetX` | int |
| 6 | `DecalsStand` | bool | 25 | `OffsetZ` | int |
| 7 | `HeightFieldStand` | bool | 26 | `ObjectsOffset` | bool |
| 8 | `HeightFieldReplace` | bool (False 680/680) | 27 | `ObjectsHeightOffset` | bool |
| 9 | `HeightFieldReplaceForWater` | bool (True 85) | 28 | `IgnoreMatrix` | bool (False 680/680) |
| 10 | `HeightFieldUseRndScale` | bool (False 680/680) | 29 | `ObjAutoOffset` | bool (False 680/680) |
| 11 | `HeightFieldMinScale` | int 1 (680/680) | 30 | **`HeightFieldMin`** | float literal |
| 12 | `HeightFieldMaxScale` | int 1 (680/680) | 31 | **`HeightFieldMax`** | float literal |
| 13 | `HeightFieldScale` | float (1 in 669/680) | 32 | `HeightFieldOffset` | int 0 (680/680) |
| 14 | `TerrainScale` | int 1 (680/680) | 33 | `NativeSeason` | `Summer` (680/680) |
| 15 | `ObjectsScale` | int 1 (680/680) | 34 | `Summer` | True 680/680 |
| 16 | `RotationAngle` | int 0 (680/680) | 35 | `Autumn` | True 680/680 |
| 17 | `HeightFieldSmooth` | bool (True 41) | 36 | `Winter` | True 680/680 |
| 18 | `HeightFieldSmoothRadius` | int (2:427, 3:248, 1:5) | 37 | `Spring` | True 680/680 |
| 19 | `HeightFieldSmoothFactor` | int 4 (680/680) | | | |

**[O] Variable nested records** (block-type counts over 680 sections):
`Objects` only 618; `Objects`+`Waters` 37; none 12; `Objects`+`Decals[*]` 9;
`Objects[*]` 3; `Objects`+`Decals` 1. Object record skeleton
(`pattern.lib:360-387`):

```
   Objects : struct.begin                  ; 3 spaces
      [*] : struct.begin                   ; 6 spaces
         RaceName = env                    ; 9 spaces
         BaseName = <prop name>            ; 9 spaces
         Position : struct.begin           ; 9 spaces
            X = <float> ; Y ; Z ; W        ; 12 spaces
         struct.end
         Direction / Up / Scaling : struct.begin  (same X,Y,Z,W)
      struct.end
   struct.end
```

`Waters` records differ: `Name = x25y32`, `Width`, `Height`,
`Position{X,Y,Z}` only (`pattern.lib:638257-638266`). Totals: **39,780**
object records, **235** distinct `BaseName` strings.

### 5.2 The five "known offsets" — they are line numbers, not byte offsets

**[O/D]** Every cited pair resolves to `HeightFieldMin`/`HeightFieldMax` of a
section. Byte offsets below are starts of the corresponding line (CRLF file).

| Prior citation | Section (lines) | Byte span of section | Field lines → byte starts |
|---|---|---|---|
| `pattern.lib:6805-6806` | `plt2` (6775..13507) | 172,901..344,605 | 6805→173,669; 6806→173,710 |
| `pattern.lib:33111-33112` | `hil1` (33081..34745) | 854,149..1,008,612 | 33111→854,933; 33112→854,956 |
| `pattern.lib:366499-366500` | `g_hil4` (366469..369365) | 9,458,091..9,881,235 | 366499→9,458,861; 366500→9,458,904 |
| `pattern.lib:549585-549586` | `k_ravine_1` (549555..555363) | 14,195,473..15,714,652 | 549585→14,196,248; 549586→14,196,285 |
| `pattern.lib:730045-730046` | `k_ravine_big_stone_1` (730015..740723) | 18,876,693..20,907,169 | 730045→18,877,479; 730046→18,877,518 |

Other prior citations checked: `:328` = `plt1` `HeightFieldStand` (line
`section.begin+7`, byte 8,223); `:351-352` = `plt1` min/max (byte 8,856/8,897);
`:542627-542628` = `k_ravine_big_1` min/max; `:583073-583074` = `k_ravine_7`
min/max; `:338482` = `g_mnt_1` object `BaseName = terrainmesh4` (byte
8,733,756). **[I] Prior citations should be rewritten as `pattern.lib:L`
(line), with optional `byte B`, to avoid future mis-parsing.** Byte offset of
a field is *not* constant relative to section start, because earlier literals
vary in length (e.g. `HeightFieldMin` byte delta: `plt1` 768, `hil1` 784,
`k_ravine_1` 775, `g_hil4` 770, `k_ravine_big_stone_1` 786).

### 5.3 Name ↔ `.pattern` file ↔ family

* **[O]** 680/680 section `Name` values match a `.pattern` filename
  case-insensitively (e.g. section `K_ravine_2` spelling variants resolved by
  `.lower()`). 710 `.pattern` files exist: 30 orphans with no section —
  `desert_mng_1..3`, `desert_mni_1..3`, `desert_mnc_1..3`,
  `n_desert_mng_1..3`, `n_desert_mni_1..3`, `n_desert_mnc_1..3`,
  `k_plain_midl_{1..7,9..12}` (the last group includes `k_plain_midl_.pattern`).
* **[O] Family source** = `generator.cfg:67-2367`, `Patterns : struct.begin`
  tree; `Name =` at 9 spaces, `Pattern =`/`Freq =` at 15 spaces
  (`generator.cfg:69-95`). 64 groups / 493 refs; duplicate group names at
  `:156`, `:1658` (`desert_mng`), `:173`/`:1683`, `:190`/`:1708`,
  `:288`/`:1762` (`plain_medium`) → family name alone is not a key.
* **[O] Exact-name join:** 452/493 refs resolve to a section; 426/680 unique
  sections covered. **[D] Normaliser** (`.lower()`, delete `_`, strip leading
  zeros from digit runs) resolves 489/493; 463 unique sections covered;
  **collisions** `mng4`/`mng_4`, `mni4`/`mni_4`, `mnc4`/`mnc_4`; 4 unresolved
  refs: `desert_mnt_14`, `desert_mnt_15`, `k_plain_mid_12a`,
  `k_plain_mid_12b`. **[I] Use exact join first; treat the normaliser as a
  PORT APPROXIMATION for the 37 near-miss refs** (e.g. `desert_plt2` →
  `desert_plt_2`, `n_desert_frt_big1` → `n_desert_frt_big_1`,
  `k_pump_1` → `k_pump_01`).
* **[O] Mines:** no section name contains `mine/gold/iron/coal`; the props are
  nested objects: `minegold` in `mng4`,`mng_1..5`; `mineiron` in `mni4`,
  `mni_1..5`; `minecoal` in `mnc4`,`mnc_1..5`
  (`pattern.lib:315620`, `:713410`, `:715244`, `:716910`); winter names
  `minegolds`/`mineirons`/`minecoals` in `desert_mng_1_a`, `desert_mni_*_a`,
  `desert_mnc_*_a` (`:1170134`, `:1168944`, `:1171156`).
* **[O] Christmas:** `christmas` family refs 5 (`new_year6..10`,
  `generator.cfg:1604`), but 10 `new_year*` sections exist (`:923275..:931651`)
  — 5 editor/unused sections uncovered.
* **[O] Mountains:** `g_mnt_1` section embeds `terrainmesh4` at `:338482`;
  mountain grids decode all-zero (F01/DPATTERN cross-check), so props, not
  height, carry mountains.

### 5.4 Family catalogue — all 64 `generator.cfg` groups

Counts = sections joined by exact name; byte range = min `byte_start` .. max
`byte_end` of those sections; line range = section line numbers.
`@N` = `generator.cfg` line of the family `Name =`.

| Family @cfg line | Records | Byte range | Line range |
|---|---:|---|---|
| mng @69 | 6 | 8,145,809..18,498,217 | 315,551..715,145 |
| mni @98 | 6 | 8,172,444..18,540,577 | 316,587..716,811 |
| mnc @127 | 6 | 8,158,347..18,582,238 | 316,041..718,449 |
| desert_mng @156 | 3 | 30,248,847..30,276,136 | 1,170,037..1,171,113 |
| desert_mni @173 | 3 | 30,220,020..30,248,845 | 1,168,903..1,170,035 |
| desert_mnc @190 | 3 | 30,276,138..30,309,136 | 1,171,115..1,172,415 |
| plain_small @207 | 19 | 15,848,127..16,052,747 | 612,891..620,967 |
| plain_medium @288 | 24 | 15,877,555..16,188,349 | 614,067..626,287 |
| plain_big @389 | 11 | 17,830,775..18,310,416 | 689,415..707,879 |
| plain_huge @446 | 13 | 2,204,989..17,830,773 | 86,113..689,413 |
| ravine_big @503 | 8 | 18,876,693..20,907,169 | 730,015..807,573 |
| ravine_medium @540 | 9 | 14,195,473..15,714,652 | 549,555..607,667 |
| plateau @581 | 5 | 8,088..2,204,987 | 321..86,111 |
| plateau_small @606 | 6 | 2,293,383..3,268,958 | 89,459..127,341 |
| plateau_big @635 | 5 | 7,009,740..8,145,807 | 272,109..315,549 |
| mountains @660 | 7 | 8,707,445..9,235,119 | 337,461..357,941 |
| hills_dark @693 | 4 | 854,149..1,008,612 | 33,081..39,183 |
| hills_light @714 | 9 | 9,235,121..9,881,235 | 357,943..382,651 |
| decor @755 | 3 | 1,008,614..1,047,099 | 39,185..40,653 |
| decor_big @772 | 1 | 2,204,989..2,293,381 | 86,113..89,457 |
| tiles @781 | 4 | 5,235,599..5,239,551 | 203,265..203,423 |
| stoneforests @802 | 8 | 18,582,240..18,876,691 | 718,451..730,013 |
| stoneforests_old @839 | 8 | 1,047,101..1,933,229 | 40,655..75,695 |
| stones @876 | 7 | 5,239,553..5,390,831 | 203,425..209,289 |
| forests_pinefir_big @909 | 6 | 3,268,960..6,793,562 | 127,343..263,721 |
| forests_pinefir_medium @938 | 6 | 3,841,838..4,159,204 | 149,253..161,599 |
| forests_pinefir_small @967 | 6 | 4,159,206..4,320,232 | 161,601..167,843 |
| forests_spruce_big @996 | 4 | 4,320,234..4,606,732 | 167,845..178,931 |
| forests_spruce_medium @1018 | 4 | 4,606,734..4,877,084 | 178,933..189,431 |
| forests_pinedrygreen_small @1040 | 4 | 4,877,086..5,235,597 | 189,433..203,263 |
| forests_pine_small @1062 | 6 | 1,229,878..1,274,505 | 47,851..49,669 |
| forests_pine_medium @1091 | 10 | 1,274,507..1,417,651 | 49,671..55,409 |
| forests_pine_big @1136 | 8 | 1,417,653..1,994,206 | 55,411..78,061 |
| forests_pine_big_2 @1174 | 3 | 1,746,015..1,870,353 | 68,431..73,259 |
| forests_mixed_big @1191 | 3 | 5,390,833..7,009,738 | 209,291..272,107 |
| forests_mixed_medium @1208 | 5 | 6,014,872..6,541,139 | 233,483..253,935 |
| forests_leaf_big @1233 | 2 | 8,355,500..8,707,443 | 323,713..337,459 |
| forests_leaf_medium @1247 | 2 | 8,184,353..8,355,498 | 317,049..323,711 |
| forests_leaf_small @1261 | 6 | 8,476,328..8,609,464 | 328,431..333,637 |
| swamp_small @1290 | 11 | 23,643,731..23,804,821 | 913,979..920,235 |
| swamp_big @1339 | 2 | 20,907,171..21,208,581 | 807,575..819,025 |
| swamp_medium @1352 | 20 | 22,984,305..23,643,729 | 888,905..913,977 |
| lake_small @1437 | 12 | 22,040,457..22,984,303 | 851,955..888,903 |
| lake_big @1490 | 11 | 21,208,583..22,040,455 | 819,027..851,953 |
| pump @1539 | 6 | 23,851,133..23,880,464 | 922,099..923,273 |
| christmas @1604 | 5 | 23,909,166..24,092,405 | 924,449..931,651 |
| desert_tiles @1629 | 4 | 5,235,599..5,239,551 | 203,265..203,423 |
| desert_mng @1658 | 5 | 18,450,976..18,498,217 | 713,285..715,145 |
| desert_mni @1683 | 5 | 18,498,219..18,540,577 | 715,147..716,811 |
| desert_mnc @1708 | 5 | 18,540,579..18,582,238 | 716,813..718,449 |
| desert_plain_small @1733 | 6 | 25,928,664..26,149,751 | 1,002,773..1,011,227 |
| plain_medium @1762 | 7 | 25,759,831..26,232,850 | 996,263..1,014,419 |
| desert_plain_big @1795 | 2 | 25,575,747..25,759,829 | 989,207..996,261 |
| desert_plateau @1808 | 0 (4 refs unresolved) | — | — |
| desert_plateau_small @1829 | 0 (4 refs unresolved) | — | — |
| desert_plateau_big @1850 | 0 (3 refs unresolved) | — | — |
| desert_mountains @1867 | 13 | 28,132,669..28,404,446 | 1,087,549..1,098,173 |
| desert_stoneforests @1932 | 4 | 27,471,834..27,582,064 | 1,062,035..1,066,345 |
| desert_stones @1953 | 12 | 27,419,594..27,582,064 | 1,059,991..1,066,345 |
| desert_forests_big @2006 | 0 (17 refs unresolved) | — | — |
| desert_forests_medium @2079 | 23 | 29,235,033..29,845,074 | 1,130,473..1,154,257 |
| desert_forests_small @2176 | 20 | 29,845,076..30,220,018 | 1,154,259..1,168,901 |
| desert_forests_unique @2261 | 12 | 25,140,311..25,575,745 | 972,295..989,205 |
| desert_lake @2314 | 12 | 27,582,066..28,132,667 | 1,066,347..1,087,547 |

**[O] The file is essentially ordered by family**: consecutive families have
adjacent byte ranges (e.g. `plateau` ends 2,204,987; `decor_big` starts
2,204,989; `plain_huge` ends 17,830,773; `plain_big` starts 17,830,775).
**[I] This makes byte range a usable coarse family index for the port.**

**Task-level category rollup** (exact-name join; categories overlap):

| Category | cfg families | refs | unique sections | byte span |
|---|---:|---:|---:|---|
| mng/mni/mnc (mines) | 3 | 18 | 18 | 8,145,809..18,582,238 |
| forests (`forests_*`) | 15 | 75 | 75 | 1,229,878..8,707,443 |
| stones/stoneforests | 5 | 39 | 35 | 1,047,101..27,582,064 |
| hills (`hills_*`) | 2 | 13 | 13 | 854,149..9,881,235 |
| mountains (`*mountains`) | 2 | 22 | 20 | 8,707,445..28,404,446 |
| decor (`decor*`) | 2 | 4 | 4 | 1,008,614..2,293,381 |
| mines (family named "mine") | **0** | 0 | 0 | — (props only, see §5.3) |
| lakes/swamps/pump | 7 | 83 | 74 | 20,907,171..28,132,667 |
| deserts (`desert*`) | 20 | 164 | 128 | 5,235,599..30,309,136 |
| christmas | 1 | 5 | 5 | 23,909,166..24,092,405 |
| relief (plateau/ravine/plain) | 15 | 128 | 115 | 8,088..26,232,850 |
| tiles | 2 | 10 | 4 | 5,235,599..5,239,551 |

### 5.5 Numeric metadata actually stored

**[O] In `pattern.lib` (all 680 sections):** `Width`, `Height` (int);
`HeightFieldMin`, `HeightFieldMax`, `HeightFieldScale` (float literals);
`HeightFieldMinScale`, `HeightFieldMaxScale`, `TerrainScale`, `ObjectsScale`,
`RotationAngle`, `HeightFieldSmoothRadius`, `HeightFieldSmoothFactor`,
`HeightFieldSmoothOffset`, `OffsetX`, `OffsetZ`, `HeightFieldOffset`
(int/float); 17 boolean flags + `NativeSeason`. Noteworthy observed
non-unity values: `HeightFieldScale` = −0.925 (4 sections), +0.925 (3),
1.175 (1), 0.8 (1), 1.5 (1), 1 otherwise (669);
`HeightFieldSmooth=True` 41/680; `CollisionStand=True` 625/680;
`PatternMaskReverceStand=True` 662/680.
**[O] In `generator.cfg`, not in `pattern.lib`:** per-member `Freq`
(493 values; e.g. `mng4 Freq = 0`, `mng_1 Freq = 1` at `generator.cfg:72-77`).
**[U] No `min/max/scale/freq` field beyond the above was found**; no separate
binary numeric block exists.

### 5.6 Decoder prototype (validated: 680 sections, 64 families, 679 headers OK)

```python
"""F02 donor pattern.lib decoder prototype (read-only; no donor bytes copied)."""
import os, re, struct
from collections import defaultdict

LIB    = r"C:\Games\Cossacks 3\data\pattern\pattern.lib"
PATDIR = r"C:\Games\Cossacks 3\data\pattern"
GEN    = r"C:\Games\Cossacks 3\data\game\var\generator.cfg"
SEP    = b"\r\n"
NUMERIC = {"Width","Height","HeightFieldMinScale","HeightFieldMaxScale",
           "HeightFieldScale","TerrainScale","ObjectsScale","RotationAngle",
           "HeightFieldSmoothRadius","HeightFieldSmoothFactor",
           "HeightFieldSmoothOffset","OffsetX","OffsetZ","HeightFieldMin",
           "HeightFieldMax","HeightFieldOffset"}
BOOLS = {"TilesStand","GameObjectsStand","DecalsStand","HeightFieldStand",
         "HeightFieldReplace","HeightFieldReplaceForWater","HeightFieldUseRndScale",
         "HeightFieldSmooth","PatternMaskStand","PatternMaskReverceStand",
         "CollisionStand","ObjectsOffset","ObjectsHeightOffset","IgnoreMatrix",
         "ObjAutoOffset","Summer","Autumn","Winter","Spring"}
KEY = re.compile(r"^   ([A-Za-z_][A-Za-z0-9_]*) = (.*)$")

def line_table(path):
    raw = open(path, "rb").read()
    lines, off, pos = raw.split(SEP), [], 0
    for ln in lines:
        off.append(pos); pos += len(ln) + len(SEP)
    return raw, lines, off

def generator_families(path):
    """64 ordered (family, cfg_line, [(pattern, freq, cfg_line)]) groups."""
    fams, cur = [], None
    for n, ln in enumerate(open(path, "rb").read().split(b"\r\n"), 1):
        m = re.match(rb"^         Name = (.+)$", ln)
        if m:
            cur = (m.group(1).decode("latin-1"), n, []); fams.append(cur); continue
        m = re.match(rb"^               Pattern = (.+)$", ln)
        if m and cur: cur[2].append((m.group(1).decode("latin-1"), None, n))
        m = re.match(rb"^               Freq = (.+)$", ln)
        if m and cur and cur[2]: cur[2][-1] = (cur[2][-1][0], float(m.group(1)), n)
    return fams

def entries(lib=LIB, gen=GEN, patdir=PATDIR, crosscheck=True):
    raw, lines, off = line_table(lib)
    fams = generator_families(gen)
    pat2fam = defaultdict(list)
    for fi, (fam, fl, plist) in enumerate(fams):
        for p, freq, pl in plist: pat2fam[p.lower()].append((fam, fi, fl, pl, freq))
    byfile = defaultdict(list)
    for fn in os.listdir(patdir):
        if fn.lower().endswith(".pattern"): byfile[fn[:-8].lower()].append(fn)
    out, start = [], None
    for n, ln in enumerate(lines, 1):
        if ln == b"section.begin": start = n
        elif ln == b"section.end" and start is not None:
            a, b = start, n
            f, obj_count, in_objects = {}, 0, False
            for i in range(a + 1, b):
                s = lines[i - 1]
                m = KEY.match(s.decode("latin-1"))
                if m: f[m.group(1)] = m.group(2)
                elif s in (b"   Objects : struct.begin", b"   Objects[*] : struct.begin"):
                    in_objects = True
                elif s == b"   struct.end" and in_objects:
                    in_objects = False
                elif in_objects and s.startswith(b"      [*] : struct.begin"):
                    obj_count += 1
            name = f.get("Name", "")
            e = dict(name=name, family=[x[0] for x in pat2fam[name.lower()]],
                     freq=[x[4] for x in pat2fam[name.lower()]],
                     line_start=a, line_end=b,
                     byte_start=off[a-1], byte_end=off[b-1]+len(lines[b-1])+2,
                     size=(off[b-1]+len(lines[b-1])+2)-off[a-1],
                     objects=obj_count,
                     meta={k: (float(v) if k in NUMERIC
                               else v == "True" if k in BOOLS else v)
                           for k, v in f.items()})
            if crosscheck and byfile[name.lower()]:
                with open(os.path.join(patdir, byfile[name.lower()][0]), "rb") as fh:
                    w, h = struct.unpack("<ii", fh.read(8))
                e["pattern_file"] = byfile[name.lower()][0]
                e["pattern_w"], e["pattern_h"] = w, h
                e["header_ok"] = (w == e["meta"]["Width"] and
                                  h == e["meta"]["Height"])
            out.append(e); start = None
    return out, fams

if __name__ == "__main__":
    es, fs = entries()
    print("sections", len(es), "families", len(fs),
          "headers ok", sum(e.get("header_ok", False) for e in es),
          "with family", sum(1 for e in es if e["family"]))
```

**Validated output:** `sections 680 families 64 headers ok 679 with family 426`;
`plt1` → family `plateau`, byte 8,088, size 164,811, meta 38×53,
min −0.0949411764740944, max 3.49669814109802, 229 objects;
`mng_1` → families `[mng, desert_mng]`, byte 18,450,976, size 8,851,
min=max=0, 11 objects.

### 5.8 Cross-check — 12 entries against `.pattern` bytes

Grid decode: `w,h = struct.unpack_from('<ii', b, 0)`; float window at byte
`G` with `w*h` little-endian float32, `min`/`max` compared to `float32(literal)`.
`MATCH` = exact float32 equality on both. Candidate count = number of offsets
in `[nominal-256, nominal+32]` (nominal = `8+w*h`) giving the same min/max.

| Pattern (lib lines) | lib W×H | binary W×H | lib min / max (literal) | G (bytes) | decoded min / max | MATCH | candidates |
|---|---|---|---|---:|---|---|---:|
| `plt1` (321..6773) | 38×53 | 38×53 | −0.0949411764740944 / 3.49669814109802 | 1,972 | −0.09494117647409439 / 3.4966981410980225 | YES | 72 |
| `plt2` (6775..13507) | 42×55 | 42×55 | −0.0732548981904984 / 3.61341166496277 | 2,266 | −0.07325489819049835 / 3.6134116649627686 | YES | 73 |
| `hil1` (33081..34745) | 25×41 | 25×41 | 0 / 3.86130237579346 | 1,000 | 0.0 / 3.861302375793457 | YES | 72 |
| `g_hil4` (366469..369365) | 33×59 | 33×59 | −4.32127315701247E−13 / 1.91698789596558 | 1,912 | −4.321273157012473e−13 / 1.9169878959655762 | YES | 58 |
| `k_ravine_1` (549555..555363) | 46×63 | 46×63 | −2.963627576828 / 3.13982009887695 | 2,866 | −2.963627576828003 / 3.139820098876953 | YES | 73 |
| `k_ravine_7` (583043..590643) | 68×73 | 68×73 | −2.96362733840942 / 2.96362495422363 | 4,832 | −2.963627338409424 / 2.963624954223633 | YES | 73 |
| `k_ravine_big_stone_1` (730015..740723) | 84×100 | 84×100 | −2.96362733840942 / 0.173864871263504 | 8,225 | −2.963627338409424 / 0.17386487126350403 | YES | 21 |
| `f_plt_big_1` | 81×93 | 81×93 | 0 / 2.96362733840942 | 7,536 | 0.0 / 2.963627338409424 | YES | 72 |
| `d_plt1` | 51×63 | 51×63 | −0.620221674442291 / 3.3239107131958 | 3,124 | −0.6202216744422913 / 3.323910713195801 | YES | 72 |
| `g_mnt_1` (337461..340273) | 43×38 | 43×38 | 0 / 0 | 1,562 | 0.0 / 0.0 (all-zero grid) | YES | 5 |
| `i_mnt_big_1` | 51×55 | 51×55 | −0.641090035438538 / 0.464331328868866 | 2,708 | −0.6410900354385376 / 0.46433132886886597 | YES | 38 |
| `brush_plt_1x1` (201..239) | 4×4 | 4×4 | 3.20392155647278 / 3.20392155647278 | 17 | 3.2039215564727783 / 3.2039215564727783 | YES | 1 |

**[D] Boundary caveat:** 11/12 grids have many byte offsets producing the
same min/max (zeros padding), so the exact start of the float plane cannot be
proved from min/max alone; the `G` values above are the offsets used by prior
work and reproduce the report exactly. **[O] Header check:** 679/680 sections
have `Width`/`Height` equal to the binary header; the sole mismatch is
`m_swamp_12_old`: `pattern.lib:905523+2,+3` say 17×20, while
`m_swamp_12_old.pattern:0-7` decode to 18×23 (21,860-byte file).

---

## Implications for port

1. **[PORT APPROXIMATION]** A converter must parse `pattern.lib` as a
   line-oriented text DB (37-field prologue + nested structs), not as a packed
   archive. Emit one derived JSON/Asset entry per section keyed by exact
   `Name`, with `line_start/end`, `byte_start/end`, all 37 metadata fields and
   nested object records. No donor bytes are copied (only derived numbers).
2. **[PORT APPROXIMATION]** Family membership should be joined from
   `generator.cfg` by exact name first; a normaliser is needed for 37 of 493
   refs but must not be allowed to merge `mng4` with `mng_4` (different
   sections with different `Freq`). Keep `Freq` from the cfg, not from lib.
3. **[D]** Since the lib is ordered by family with contiguous byte ranges for
   most families, a byte-range index can accelerate conversion, but the
   authoritative record boundary is `section.begin`/`section.end`.
4. **[I]** Mines must be placed via nested object props: `mng* → minegold`,
   `mni* → mineiron`, `mnc* → minecoal` (winter variants in the desert
   families). A terrain generator that only reads family names will see
   *zero* mine families and silently omit mines.
5. **[D]** Mountains are encoded as `terrainmeshN` object props with all-zero
   height grids (`g_mnt_1`, `:338482`); stamping a taller bump cannot reproduce
   them. Lake families carry extra `Waters` records (`pattern.lib:638257`),
   which a generic object-only importer would drop.
6. **[PORT APPROXIMATION]** Min/max/scale metadata is usable verbatim from the
   lib (bit-exact cross-check), but the float-grid start offset and row flip
   remain UNVERIFIED; use the documented offsets as a starting point and
   validate min/max after decoding.

---

## Risks

* **R1 [O]** Prior "byte offsets" in the swarm corpus are line numbers; any
  tool written against them as bytes will read the middle of unrelated lines.
* **R2 [O]** 30 `.pattern` files have no lib section; importers that enumerate
  files instead of sections will generate 30 unreferenced patterns.
* **R3 [O]** 217 sections are not in any `generator.cfg` family (editor brushes,
  `i_mnt_*`, `j_big_plt_*`, `fb_1..53`, `new_year1..5`, …); they may be
  editor-only, but that is **UNVERIFIED**.
* **R4 [O]** One header mismatch (`m_swamp_12_old`) means a strict validator
  would abort; decide policy explicitly.
* **R5 [O]** Duplicate cfg family names and near-miss pattern names make the
  name join lossy; 4 refs are unresolved even after normalisation.
* **R6 [U]** The relation between the lib's nested object count and the
  `.pattern` file's 24-byte trailing records is unproven: e.g. `plt1` has 229
  lib object records but ~1,924 trailing 24-byte records from byte 9,992;
  `k_ravine_1` 206 vs ~2,790 from 14,394. They are not 1:1.
* **R7 [U]** No plaintext consumer of these fields was located in this pass;
  engine application (stamp order, blend, season swap) is outside F02.
* **R8 [I]** Family byte ranges are contiguous *in this build*; a DLC or patch
  changing section order would invalidate a byte-range shortcut.

---

## UNVERIFIED register

| ID | Claim | Status | Why not verified |
|---|---|---|---|
| U-F02-1 | Exact float-plane start byte for each pattern | UNVERIFIED | Many offsets give identical min/max (§5.8); needs binary-side definition (F01). |
| U-F02-2 | Row order / vertical flip of height grid | UNVERIFIED | No plaintext binds lib fields to map row sign. |
| U-F02-3 | Engine consumption of `HeightField*` keys | UNVERIFIED | No consumer found/read in this pass. |
| U-F02-4 | Meaning of trailing 24-byte `.pattern` records | UNVERIFIED | F01 scope; counts do not match lib objects. |
| U-F02-5 | Purpose of the 30 section-less `.pattern` files | UNVERIFIED | No cfg refs found. |
| U-F02-6 | Whether 217 uncovered sections are editor-only | UNVERIFIED | No script reference audit in this pass. |
| U-F02-7 | `Freq` semantics (weight vs count) | UNVERIFIED | Only literals observed (`generator.cfg:73`, `:77`). |
| U-F02-8 | Cause of `m_swamp_12_old` 17×20 vs 18×23 | UNVERIFIED | Possibly a legacy/renamed file; no proof. |
| U-F02-9 | Winter handling (All seasons True, `minegolds` variants) | UNVERIFIED | Season selection logic not read here. |

## Open questions

1. Is there an external index for `pattern.lib` (e.g. in `cossacks.exe` or a
   missing `.idx`)? None exists in the file itself.
2. Which native function reads `section.begin` and how are fields bound to
   placement (D03/D05/F01 should anchor this)?
3. What selects `mng4` (`Freq = 0`) versus `mng_1..5` (`Freq = 1`), given both
   have sections?
4. Are `desert_plt2`-style names a generator.cfg typo, or do they resolve via
   a different engine normaliser?
5. How are the `Waters` `x##y##` names related to map tile coordinates?
6. Should the port import all 680 sections or only the 463 family-reachable
   ones (and what breaks if the rest are skipped)?

---

*No donor binary was executed, no donor file was copied into the repository,
no source/Godot/git changes were made by this worker. No donor visual parity is
claimed; all port readings are labelled PORT APPROXIMATION.*
