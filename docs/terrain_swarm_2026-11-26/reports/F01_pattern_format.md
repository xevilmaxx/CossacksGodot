---
id: F01
ticket: TERRAIN-SWARM-2026-11-26 / F01 (DONOR DATA FORMAT)
title: "F01 — Full binary format of Cossacks 3 data/pattern/*.pattern (710/710 byte closure), corrected relief-grid offsets, and pattern.lib linkage"
agent: "F01 (donor data worker, read-only)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__READ_ONLY_DONOR_BYTES__NO_SOURCE_NO_GODOT_NO_COMMIT
scope: "Exactly one file written: this report. No source, shader, config, asset, test, git, Godot or queue edit. Donor at C:\\Games\\Cossacks 3 read only; no donor binary executed or copied."
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). All port consequences are labelled PORT APPROXIMATION; no parity claim."
sources:
  - "C:\\Games\\Cossacks 3\\data\\pattern\\*.pattern (710 files, Python bytes/struct/numpy read-only)"
  - "C:\\Games\\Cossacks 3\\data\\pattern\\pattern.lib (30,309,138 B, latin-1, 680 top-level sections)"
prior_art:
  - docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md
  - docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md
  - docs/terrain_swarm_2026-11-25/reports/Z04_height_only_design.md
  - docs/audit/TERRAIN_DONOR_PATTERNS.md
  - variant3d/tools/parse_terrain.py
verdict: "FORMAT_CLOSED: size = 8 + 4*w*h + 54*(w-1)*(h-1) holds for 710/710 files; five regions recovered with exact offsets. The true relief-grid offset is 8 + (w-1)*(h-1), NOT the offsets used in DPATTERN_01 (17/29 of its audited offsets are shifted); its four Appendix A tables are reproducible only from the shifted windows. semantics of the u8 id, the 4-byte record tail, the int32 weight array and the 13-byte tail array remain UNVERIFIED."
---

# F01 — `.pattern` binary format, fully byte-accounted

## 0. Mandate and label key

Decode every byte of `C:\Games\Cossacks 3\data\pattern\*.pattern`, work concrete
small and large examples, verify the 8×10 relief tables of DPATTERN-01, document
the `pattern.lib` linkage, and give a `struct` spec + JSON parser pseudocode.
This report is the **only** file written. Donor bytes were read with Python
`bytes`/`struct`/`numpy` only; no donor executable was run; no donor file was
copied into the repo.

Labels: **[O]** observed literal byte/line, **[D]** derived arithmetic or
control-flow consequence, **[I]** inference without engine proof, **[U]** UNVERIFIED.
Every port consequence is **PORT APPROXIMATION**. **No donor parity claim.**

---

## 1. Executive summary

- **[O]+[D] Master closure (new):** every `.pattern` file satisfies exactly
  `filesize = 8 + 4*w*h + 54*N`, where `N = (w-1)*(h-1)`. Verified **710/710**
  files, zero residual bytes (§4.1). The earlier "mystery record count" is
  simply the lattice-cell count of a `(w-1)×(h-1)` grid, not an object count.
- **[O] Five regions:** `int32 w,h` (8 B) → `u8 mask[N]` → `float32 height[w*h]`
  (4wh B) → `u8[4] PRE` + `N × 24 B` records → `int32[4N-1]` weight block
  (16N−4 B) → `N × 13 B` tail records (§4.2).
- **[O]+[D] Correct height-grid offset:** `G = 8 + N = 8 + (w-1)*(h-1)`.
  Decoding 30 named patterns at `G` reproduces `pattern.lib`
  `HeightFieldMin/Max` bit-exactly for 678/680 sections (§4.4, §4.9).
- **[D] DPATTERN-01 offset correction:** 17 of the 29 offsets in
  `DPATTERN_01_relief_grids.md §3` are shifted by +12…+252 B (or −8/−252 B).
  Its published 8×10 tables (Appendix A) are exact block means of the
  **shifted** windows, not of the true grid. Corrected tables are given in §4.10.
- **[O] `pattern.lib` linkage:** section `Name` → `<Name>.pattern`; 679/680
  exact filenames plus one case-only mismatch (`k_ravine_2` → `K_ravine_2.pattern`);
  31 files have no section (§4.9). Config `HeightFieldMin/Max` are grid extrema,
  not an independent sculpt parameter.
- **[U] Record semantics:** the `int32 id` (0…255), four `1.0f` values, the
  4-byte record tail, the `int32` weight block (0/99/100/101/200) and the tail
  record's `int16`/`u8` flags are structurally proven but semantically
  unidentified. No model/path/scale/position field is proven.

---

## 2. Evidence table

| # | Evidence (donor path:offset / line) | Label | What it establishes |
|---:|---|---|---|
| E1 | `data\pattern\fb_1.pattern` @`0x0000` | [O] | `08 00 00 00 09 00 00 00` → `w=8,h=9`. |
| E2 | `data\pattern\*.pattern` headers, 710/710 | [O] | All begin with two LE `int32` `(w,h)`; `w*h` ∈ 16…9116. |
| E3 | `fb_1.pattern` size 3320; `k_ravine_big_stone_1` 477326; etc. | [O] | Sizes listed in task brief confirmed exactly. |
| E4 | size closure `8+4wh+54(w−1)(h−1)` over 710 files | [D] | Zero residual bytes; determines `N` without any heuristic. |
| E5 | `fb_1` mask @`0x0008..0x003F` (56 B) | [O] | Values exclusively 0/1; 7 rows × 8 cols; 41 ones. |
| E6 | all 710 masks @`0x08` | [O] | **0/1 only in all files**; the "non-0/1 tail" of prior reports came from reading `w*h` bytes instead of `N`. |
| E7 | `fb_1` float plane @`0x0040..0x015F` (288 B = 72 f32) | [O] | All 72 floats 0.0; `HeightFieldStand=False` (`pattern.lib:533104`). |
| E8 | `hil1.pattern` @`0x03C8=968` (G) | [O] | 1025 f32; min 0.0 / max 3.8613023758 = `pattern.lib:33111-33112`. |
| E9 | `k_ravine_1.pattern` @`0x0AEE=2798` (G) | [O] | 2898 f32; min −2.9636275768 / max 3.1398200989 = `pattern.lib:549585-549586`. |
| E10 | `k_ravine_big_stone_1.pattern` @`0x2021=8225` (G) | [O] | 8400 f32; min −2.9636273384 / max 0.1738648713 = `pattern.lib:730045-730046`. |
| E11 | 678/680 sections decoded at `G=8+N` | [O]+[D] | Exact float32 min/max match; 2 exceptions documented in §4.9. |
| E12 | `fb_1.pattern` @`0x0160` | [O] | PRE = `00 00 00 00`; first record @`0x0164`: id `e1`=225, four `1.0f`, tail `00000000`. |
| E13 | 550,908 records across 710 files | [O] | `id` ∈ 0…255, 4×`0x3F800000` exactly, no violation. |
| E14 | `fb_1.pattern` @`0x06A0..0x0A1F` (892 B) | [O] | Weight block all zero; length `16N−4 = 4N−1` int32. |
| E15 | weight values over all files | [O] | Only `{0,100,101,99,200}` plus float-looking values ≈2.8e7 in 4 files. |
| E16 | `fb_1.pattern` @`0x0A20..0x0CFF` (56×13 B) | [O] | `00×10 ff ff 01` repeated; `d_tls_*` use `ff 00` instead of `ff ff`. |
| E17 | tail fields over 550,908 records | [O] | `u8[10]=0` in 100%; `i16` ∈ {−1 (547,967), 255 (2,941)}; `u8` ∈ {0 (494,076), 1 (56,832)}. |
| E18 | `pattern.lib:533097-533135` (`fb_1`) | [O] | Section includes `Width=8, Height=9`, sculpt flags, `Objects : struct`. |
| E19 | `pattern.lib` 680 sections; 710 files | [O] | 679 exact name matches, 1 case mismatch, 31 orphan files. |
| E20 | `pattern.lib` object counts vs binary N | [O]+[D] | e.g. `hil1` lib 58 objects vs binary N=960 — **not** the same population. |
| E21 | `DPATTERN_01 §3` offsets vs `8+N` | [D] | 12/29 correct, 17 shifted; full delta table §4.10. |
| E22 | recomputed block means at `G=8+N` vs DPATTERN Appendix A | [D] | Appendix A reproduced exactly only with the shifted offsets. |

---

## 3. Method

1. Read the charters and prior art (`DPATTERN_01`, `G07`, `Z04`,
   `TERRAIN_DONOR_PATTERNS`, `variant3d/tools/parse_terrain.py`) in full.
2. For each of the 710 donor `.pattern` files, read bytes only; decode header
   `(w,h)` with `struct.unpack_from('<2i', …)`.
3. Search for the longest run of the 16-byte signature
   `b'\x00\x00\x80\x3f'*4` at stride 24 (the four `1.0f` values); record the
   first signature offset `S`. Empirically `S = 12 + N + 4wh`, hence
   `N = S − 12 − 4wh` and `filesize = S + 24N + 16N − 4 + 13N`.
4. Substitute `N=(w−1)(h−1)`; verify closure over 710/710 files with zero
   residual (E4). This removes the ±24…160 B ambiguity of DPATTERN-01 §2.2.
5. Decode the grid at `G = 8+N` and compare float32 min/max with `pattern.lib`
   literals parsed from top-level sections (indent exactly three spaces).
6. Decode every region as `struct` fields; check invariants over all 550,908
   lattice records; inspect exceptions (`d_tls_*`, `k_plain_mid_12`,
   `m_swamp_12_old`).
7. Recompute the 8×10 block means with DPATTERN's rule
   (`rows [j*h/8,(j+1)*h/8)`, `cols [i*w/10,(i+1)*w/10)`, integer floor) at
   both the old and corrected offsets.
8. Write only this report. No donor binary run, no file copied, no repo edit.

---

## 4. Findings — exact layout

### 4.1 Master closure [O]+[D]

```
N = (w-1) * (h-1)                         # lattice cells
filesize = 8 + 4*w*h + 54*N               # 710/710, residual 0
```

Check examples [O]:

| file | w×h | wh | N=(w−1)(h−1) | predicted size | actual size |
|---|---:|---:|---:|---:|---:|
| `fb_1.pattern` | 8×9 | 72 | 56 | 8+288+3024 = 3320 | 3320 |
| `mni_1.pattern` | 8×10 | 80 | 63 | 8+320+3402 = 3730 | 3730 |
| `k_rock_1.pattern` | 19×18 | 342 | 306 | 8+1368+16524 = 17900 | 17900 |
| `hil1.pattern` | 25×41 | 1025 | 960 | 8+4100+51840 = 55948 | 55948 |
| `g_mnt_1.pattern` | 43×38 | 1634 | 1554 | 8+6536+83916 = 90460 | 90460 |
| `big_hill_1.pattern` | 51×56 | 2856 | 2750 | 8+11424+148500 = 159932 | 159932 |
| `k_ravine_big_stone_1.pattern` | 84×100 | 8400 | 8217 | 8+33600+443718 = 477326 | 477326 |

The `54` decomposes as `1 + 4 + 4 + 24 + 16 + 13 = 54` bytes per lattice cell
(mask + float-grid-per-cell + PRE + record + weights + tail); the float grid
contributes `4*w*h` globally, hence the compact formula. **[D]**

### 4.2 Region table [O]

| Region | Start | Length | Type | Notes |
|---|---:|---:|---|---|
| header | `0x00` | 8 | `<2i` | `w`, `h` little-endian |
| mask | `0x08` | `N` | `u8[N]` | row-major `(h−1)×(w−1)`, values 0/1 only |
| height | `0x08+N` | `4wh` | `<f4[wh]` | row-major `h×w`; `idx=v*w+u` |
| PRE | `0x08+N+4wh` | 4 | `u8[4]` | default/initial tail value (see §4.6); 130 distinct values over 710 files |
| records | `PRE+4` | `24N` | `N × Rec24` | §4.5 |
| weights | `records+24N` | `16N−4` | `<i4[4N−1]` | §4.7 |
| tail | `size−13N` | `13N` | `N × Tail13` | §4.8 |

Offsets for the worked examples [D]:

| file | mask | height G | PRE | records | weights | tail |
|---|---|---:|---:|---:|---:|---:|
| `fb_1` | 8…63 | 64 | 352 | 356…1699 | 1700…2591 | 2592…3319 |
| `mni_1` | 8…70 | 71 | 391 | 395…1906 | 1907…2910 | 2911…3729 |
| `k_rock_1` | 8…313 | 314 | 1682 | 1686…9029 | 9030…13921 | 13922…17899 |
| `hil1` | 8…967 | 968 | 5068 | 5072…28111 | 28112…43467 | 43468…55947 |
| `g_mnt_1` | 8…1561 | 1562 | 8098 | 8102…45397 | 45398…70257 | 70258…90459 |
| `big_hill_1` | 8…2757 | 2758 | 14182 | 14186…80185 | 80186…124181 | 124182…159931 |
| `k_ravine_big_stone_1` | 8…8224 | 8225 | 41825 | 41829…239036 | 239037…370504 | 370505…477325 |

### 4.3 Header and mask [O]

`int32 w,h` at `0x00`. The mask is exactly `N=(w−1)(h−1)` bytes, **not** `w*h`.
This resolves the long-standing "first non-0/1 byte at mask index N" observation
of `TERRAIN_DONOR_PATTERNS:126-132` and `DPATTERN_01:93-99`: those bytes belong
to the *height plane* beginning at `8+N`; the earlier reports scanned `w*h`
bytes and inevitably ran into float bytes.

`fb_1` mask, 7 columns × 8 rows [O] (`0x08`):

```
1111111
1111001
1110001
1000111
1000111
1100111
1100111
1111111
```

41 of 56 cells occupied. **[D]** Mask occupancy does not equal object-record
count (`fb_1` 41 vs 56), nor pattern.lib `Objects` count (`fb_1` 3 at
`pattern.lib:533135+`); its semantic role is **UNVERIFIED**.

### 4.4 Height plane and the DPATTERN offset error [O]+[D]

The height plane is `w*h` little-endian float32 values at
`G = 8 + N`, row-major; `height[v*w+u]`. Verification: 678/680 `pattern.lib`
sections reproduce `HeightFieldMin`/`HeightFieldMax` as exact float32 equality
at `G` (§4.9).

DPATTERN-01 chose its offsets by scanning byte positions until min/max matched.
Because most patterns have long zero runs at the plane border, many shifted
windows also match min/max; DPATTERN therefore recorded shifted windows for
17/29 audited patterns. Deltas (`G_DPATTERN − G_true`), computed from its §3 table:

| pattern | DPATTERN G | true G=8+N | delta (bytes) | delta (floats) |
|---|---:|---:|---:|---:|
| `k_ravine_1` | 2866 | 2798 | +68 | +17 |
| `k_ravine_6` | 3190 | 3198 | −8 | −2 |
| `k_ravine_9` | 4481 | 4733 | −252 | −63 |
| `k_ravine_big_1` | 9037 | 8933 | +104 | +26 |
| `plt1` | 1972 | 1932 | +40 | +10 |
| `plt2` | 2266 | 2222 | +44 | +11 |
| `plt3` | 3622 | 3542 | +80 | +20 |
| `plt4_fixed` | 2304 | 2208 | +96 | +24 |
| `plt5` | 2368 | 2328 | +40 | +10 |
| `f_plt_big_1` | 7536 | 7368 | +168 | +42 |
| `d_plt1` | 3124 | 3108 | +16 | +4 |
| `hil1` | 1000 | 968 | +32 | +8 |
| `hil2` | 1515 | 1443 | +72 | +18 |
| `g_hil1` | 1793 | 1713 | +80 | +20 |
| `g_hil2` | 1712 | 1632 | +80 | +20 |
| `g_hil4` | 1912 | 1864 | +48 | +12 |
| `g_hil9` | 1557 | 1545 | +12 | +3 |

The remaining 12 audited patterns (`k_ravine_2/3/4/5/7/8`,
`k_ravine_big_stone_1`, `hil3`, `hil4`, `g_mnt_1`, `g_mnt_3`, `i_mnt_big_1`)
have delta 0 and are correct. **[D]** Consequence: the port tables transcribed
from DPATTERN Appendix A (`Z04:164-188`, `G07:158-200`, `game.gd`
`RELIEF_GRID_*`) are spatially shifted versions of the donor shape; e.g.
`hil1` max moves from column 9 (shifted table) to column 8 (true grid), and
the `k_ravine_1` trough moves ~17 cells. **PORT APPROXIMATION**; the corrected
tables in §4.10 are still derived block means, not the donor engine blend.

### 4.5 24-byte object record [O]

At `R = 0x08 + N + 4wh + 4`, `N` records at stride 24:

```c
struct Rec24 {
    int32   id;        // +0, observed 0..255 in 550,908/550,908 records
    float   f[4];      // +4, exactly 0x3F800000 (1.0f) ×4 in all records
    uint8   tail[4];   // +20, e.g. 00 00 00 00 / 01 01 01 01 / 61 61 61 61
};
```

`fb_1` first records [O] @`0x0164`, `0x017C`:

```
0164: e1 00 00 00 | 00 00 80 3f 00 00 80 3f 00 00 80 3f 00 00 80 3f | 00 00 00 00
017c: 42 00 00 00 | 00 00 80 3f 00 00 80 3f 00 00 80 3f 00 00 80 3f | 00 00 00 00
      id=225                  4 × 1.0f                                     tail
```

PRE [O] @`0x0160` = `00 00 00 00`; its value distribution matches the
per-record `tail[4]` distribution across the corpus (130 distinct values).
**[D]** PRE is plausibly an authored default for `tail[4]`, but no plaintext
consumer exists — **[U]** for semantics. `id` range 0…255 suggests a byte-sized
index into an engine table; no path/model string exists inside any `.pattern`
(confirmed by `TERRAIN_DONOR_PATTERNS:134-146` — 710-file scan). Do **not**
map `id` to a prop name.

### 4.6 PRE field [O]

4 bytes at `0x08+N+4wh`; 338/710 files `00 00 00 00`, 122 `74 74 74 74`,
69 `61 61 61 61`, 9 `01 01 01 01`, etc. Values are byte-uniform or byte-pairs
(e.g. `59 5b 59 5b`), consistent with the `tail[4]` field type. **[U]** exact
meaning; **[I]** it is an initial/default value of the record tail.

### 4.7 Weight block [O]

`16N−4` bytes at `W = R + 24N`, i.e. exactly `4N−1` little-endian `int32`.
Values over all files [O]: `0` (2,003,511), `100` (107,097), `101` (90,371),
`99` (1,703), `200` (8), plus 942 float-looking values ~2.8e7
(28242632…28766360) confined to a few patterns. **[D]** These look like
percent-style per-corner weights on the `(w−1)×(h−1)` lattice; **[U]** whether
they encode passability, water, material blend or terrain-type percentages.
Correlation observed [O]: in `k_ravine_big_stone_1`, 3249 of 3275 `100` values
land on lattice cells whose top-left height is negative — a hint, not a proof.
`fb_1` weights are all zero (892 B).

### 4.8 13-byte tail record [O]

`13N` bytes at `T = filesize − 13N`:

```c
struct Tail13 {
    uint8  zero[10];   // +0  observed 0x00 in all 550,908 records
    int16  code;       // +10 observed -1 (547,967 records) or 255 (2,941, all in d_tls_*)
    uint8  flag;       // +12 observed 0 (494,076) or 1 (56,832)
};
```

`fb_1`: 56 identical records `00 00 00 00 00 00 00 00 00 00 ff ff 01`.
**[U]** semantics of `code` and `flag`; **[I]** per-cell collision/stand flags.
The earlier "parallel `int16 0xffff` array at 13-byte stride"
(`TERRAIN_DONOR_PATTERNS:112-116`) is this array, now fully framed.

### 4.9 `pattern.lib` linkage [O]+[D]

- Top-level `section.begin … section.end` count = **680**; each has
  `Name`, `Width`, `Height`, 34 sculpt fields, and an `Objects : struct` list.
- Lookup: `Name` → `data\pattern\<Name>.pattern`. 679/680 exact case matches;
  `k_ravine_2` (`pattern.lib:…`) resolves case-insensitively on Windows to
  `K_ravine_2.pattern`. 31 `.pattern` files have no section (orphans/other stage).
- The binary header `(w,h)` equals section `Width`/`Height` for 679/680;
  exception `m_swamp_12_old` (`pattern.lib:905524-905525`: 17×20 vs file 18×23)
  is a stale config.
- `HeightFieldMin/Max` equal the decoded float grid extrema bit-exactly for
  **678/680** sections. Exceptions: `k_plain_mid_12`
  (`pattern.lib:707882+`, file min −0.89059/max 0.08678 vs config
  −0.87975/0.60074 — stale values), and the dimension-stale `m_swamp_12_old`.
  **[D]** `HeightFieldMin/Max` are authored/derived grid bounds; the engine
  blend that consumes them is still **[U]** (no plaintext consumer; DPATTERN §5.2).
- `HeightFieldStand=False` for `fb_1` (`pattern.lib:533104`) and its grid is
  all zero [O] — consistent with "no height payload" **[I]**.
- `pattern.lib` `Objects` counts do **not** equal binary `N`: `fb_1` 3 vs 56,
  `mni_1` 14 vs 63, `hil1` 58 vs 960, `g_mnt_1` 99 vs 1554,
  `k_ravine_big_stone_1` 381 vs 8217. **[D]** The binary records are
  per-`(w−1)(h−1)`-lattice data, not the explicit prop list; prop selection
  remains F08/D07 scope.
- No field in any section names a `.pattern` file; the name itself is the
  implicit key (field inventory: 54 distinct keys, zero "File"/"Pattern" key).

### 4.10 DPATTERN 8×10 verification and corrected tables [D]

Rule (DPATTERN Appendix A, `:595-600`): row band `j` covers
`[j*h/8, (j+1)*h/8)`, col band `i` covers `[i*w/10, (i+1)*w/10)` with integer
floor division; value = arithmetic mean of the enclosed floats.

At the **shifted** DPATTERN offsets, all four published tables reproduce to
3 dp exactly (verified programmatically). At the **correct** `G=8+N`, the
tables differ. Corrected tables (derived numeric data, **PORT APPROXIMATION**
as debug/preview aids only — stamp from full grids):

**`k_ravine_1` (G=2798):**
```
 0.000 -0.000 -0.000 -0.002 -0.156 -0.320 -0.194 -0.018 -0.345 -1.454
-0.000 -0.003 -0.864 -2.062 -2.146 -2.164 -1.648 -0.114 -0.017 -0.184
-0.000 -0.138 -1.517 -2.680 -2.957 -2.928 -2.846 -0.873 -0.002 -0.000
 0.000  0.442 -0.074 -2.506 -2.885 -2.075 -1.888 -0.508 -0.001 -0.000
 0.000  0.742  2.421  0.198  0.132  2.101  0.266  0.002  0.000  0.000
 0.000  0.163  1.986  2.924  2.904  2.551  1.281  0.021  0.000  0.000
 0.000  0.000  0.104  0.947  0.891  0.283  0.051  0.000  0.000  0.000
 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000
```

**`plt2` (G=2222):**
```
-0.000 -0.003 -0.003  0.056  0.055  0.053  0.011 -0.003 -0.002 -0.000
-0.001 -0.004  0.374  1.731  2.508  1.932  0.826  0.365  0.115  0.012
 0.002  0.091  1.340  3.145  3.248  2.897  2.265  0.933  0.148  0.018
 0.004  0.077  0.400  1.726  3.336  3.403  3.174  1.035  0.088  0.001
-0.000  0.086  1.470  2.922  3.216  3.007  1.957  0.662  0.081  0.004
 0.011  0.172  0.793  1.824  2.895  3.063  1.148  0.199  0.035  0.000
 0.002  0.023  0.099  0.436  1.320  1.313  0.353  0.102  0.004  0.000
 0.000 -0.000 -0.000  0.011  0.019  0.035  0.018  0.006  0.000  0.000
```

**`hil1` (G=968):**
```
 0.000  0.000  0.052  0.250  0.206  0.029  0.000  0.000  0.000  0.000
 0.000  0.005  0.057  0.450  0.740  0.527  0.183  0.047  0.000  0.000
 0.018  0.092  0.198  1.006  1.546  1.131  0.659  0.255  0.000  0.000
 0.133  0.581  1.501  2.461  2.891  2.121  1.591  0.717  0.055  0.000
 0.220  0.796  1.880  3.133  3.283  2.362  1.796  0.725  0.067  0.000
 0.025  0.331  0.775  1.630  1.675  1.164  0.711  0.293  0.005  0.000
 0.000  0.174  0.421  0.959  0.823  0.307  0.028  0.000  0.000  0.000
 0.000  0.014  0.100  0.236  0.101  0.014  0.000  0.000  0.000  0.000
```

**`g_hil4` (G=1864):**
```
 0.000  0.000  0.001  0.030  0.152  0.126  0.007  0.000  0.000  0.000
 0.000  0.004  0.192  0.487  0.773  0.433  0.119  0.074  0.054  0.012
 0.000  0.370  0.998  1.262  1.188  0.478  0.326  0.292  0.212  0.073
 0.000  0.393  0.341  0.957  1.780  1.360  0.565  0.349  0.216  0.071
 0.000  0.002  0.046  0.274  1.175  1.616  1.279  0.802  0.359  0.048
 0.000  0.000  0.027  0.276  1.033  1.151  0.780  0.496  0.201  0.033
 0.000  0.000  0.041  0.289  0.837  0.645  0.520  0.403  0.235  0.055
-0.000 -0.000  0.024  0.171  0.301  0.345  0.336  0.265  0.166  0.052
```

**`k_ravine_big_stone_1` (G=8225, DPATTERN offset was already correct — G07 Tier 1):**
```
 0.000  0.000 -0.000 -0.000 -0.000 -0.000 -0.020 -0.095 -0.002 -0.559
 0.000 -0.000 -0.000 -0.000 -0.000 -0.000 -1.448 -1.844 -0.296 -0.653
 0.000 -0.000 -0.000 -0.000 -0.008 -0.411 -2.649 -2.530 -0.217 -0.000
 0.000 -0.000 -0.000 -0.000 -1.563 -2.832 -2.953 -2.959 -2.027 -0.086
 0.000 -0.000 -0.057 -0.133 -1.644 -2.944 -2.711 -1.576 -0.960 -0.018
 0.000 -0.017 -2.275 -2.798 -2.948 -2.463 -0.846 -0.000 -0.000 -0.568
 0.000 -0.002 -0.682 -1.776 -2.741 -2.043 -0.103 -0.000 -0.079 -2.006
 0.000  0.000 -0.006 -0.113 -0.306 -0.126 -0.000 -0.000 -0.022 -0.494
```

---

## 5. Full byte accounting for one small file — `fb_1.pattern` (3320 B) [O]+[D]

| Region | Bytes | Length | Content |
|---|---:|---:|---|
| header | 0…7 | 8 | `08 00 00 00 09 00 00 00` → w=8,h=9 |
| mask | 8…63 | 56 | 7×8 u8 0/1 grid, 41 ones (shown §4.3) |
| height | 64…351 | 288 | 72 × f32, **all 0.0**; matches `HeightFieldMin=Max=0`, `HeightFieldStand=False` (`pattern.lib:533104,533127-533128`) |
| PRE | 352…355 | 4 | `00 00 00 00` |
| records | 356…1699 | 1344 | 56 × Rec24; ids 225,66,48,151,46,89,177,239,…; all `f[4]=1.0`; tails `00000000` |
| weights | 1696…2591 | 892 | 223 int32, **all 0** (`4N−1=223`) |
| tail | 2592…3319 | 728 | 56 × `00×10 ff ff 01` |
| **total** | **0…3319** | **3320** | **no unaccounted byte** |

Annotated hexdump (byte offsets in first column):

```
00000000  08 00 00 00 09 00 00 00 01 01 01 01 01 01 01 01  | header w,h | mask row 0
00000008  01 01 01 01 01 01 01 01 01 01 01 00 00 01 01 01  | mask rows 1-2
00000020  00 01 01 01 01 00 00 00 01 01 01 01 01 00 00 01  | mask rows 3-4
00000040  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  | height plane: 72 zero floats
   ...     (0x40..0x15F = 288 bytes of 0x00, 72 × 0.0f)
00000150  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  | last height row
00000160  00 00 00 00 e1 00 00 00 00 00 80 3f 00 00 80 3f  | PRE| rec0 id=225, f[0..1]=1.0
00000164  e1 00 00 00 00 00 80 3f 00 00 80 3f 00 00 80 3f  | rec0 id + three 1.0f
00000178  00 00 00 00 42 00 00 00 00 00 80 3f 00 00 80 3f  | rec0 tail | rec1 id=66
0000017c  42 00 00 00 00 00 80 3f 00 00 80 3f 00 00 80 3f  | rec1 (stride 24 from 0x164)
   ...     55 further Rec24 entries, all f[4]=1.0f, tail=00000000
00000690  00 00 80 3f 00 00 80 3f 00 00 80 3f 00 00 80 3f  | last record's four 1.0f
000006a0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  | weights block begins (all zero)
   ...     892 bytes = 223 int32, all zero
00000a20  00 00 00 00 00 00 00 00 00 00 ff ff 01 00 00 00  | tail[0]: 0×10, i16=-1, flag=1
   ...     55 more Tail13 records
00000cf0  00 00 00 00 00 ff ff 01                          | tail[55] ends at EOF 0xCF8
```

`mni_1`, `k_rock_1`, `hil1`, `g_mnt_1`, `big_hill_1` and
`k_ravine_big_stone_1` close identically by region (§4.2 table); their
nonzero weight/tail variations are described in §4.7/§4.8.

---

## 6. Parser spec (`struct`) and JSON emitter pseudocode [D]

```python
import json, struct

PATTERN = struct.Struct("<2i")     # w, h
RECOFF  = 24                        # int32 id, 4×float32, uint8[4]

def parse_pattern(path: str) -> dict:
    b = open(path, "rb").read()
    w, h = PATTERN.unpack_from(b, 0)               # O: 710/710
    wh, N = w*h, (w-1)*(h-1)
    assert len(b) == 8 + 4*wh + 54*N               # O: 710/710 closure

    m0 = 8
    g0 = m0 + N                                    # TRUE height offset (corrected)
    p0 = g0 + 4*wh
    r0 = p0 + 4
    w0 = r0 + 24*N
    t0 = len(b) - 13*N

    mask = list(b[m0:m0+N])                        # u8[N], row-major (h-1)x(w-1)
    grid = list(struct.unpack_from("<%df" % wh, b, g0))
    pre  = list(b[p0:p0+4])

    recs = []
    for k in range(N):
        o = r0 + k*RECOFF
        recs.append({
            "k": k, "u": k % (w-1), "v": k // (w-1),
            "id": struct.unpack_from("<i", b, o)[0],                  # [U] meaning
            "f4": list(struct.unpack_from("<4f", b, o+4)),            # [O] all 1.0
            "tail4": list(b[o+20:o+24]),                              # [U] meaning
        })

    weights = list(struct.unpack_from("<%di" % (4*N-1), b, w0))       # [U] meaning

    tails = []
    for k in range(N):
        o = t0 + 13*k
        tails.append({
            "zero10": list(b[o:o+10]),                                # [O] all zero
            "i16": struct.unpack_from("<h", b, o+10)[0],              # -1 or 255
            "flag": b[o+12],                                          # 0 or 1
        })

    return {
        "source": path, "w": w, "h": h, "N": N,
        "offsets": {"mask": m0, "height": g0, "pre": p0,
                    "records": r0, "weights": w0, "tail": t0},
        "mask": mask,
        "height": {"layout": "row-major h x w", "values": grid,
                   "min": min(grid), "max": max(grid)},
        "pre": pre, "records": recs, "weights": weights, "tails": tails,
        "labels": {"record_id": "UNVERIFIED", "record_tail4": "UNVERIFIED",
                   "weights": "UNVERIFIED", "tail_i16_flag": "UNVERIFIED",
                   "height_blend": "PORT_APPROXIMATION"},
    }
```

Emission is plain `json.dump(parse_pattern(path), fp)`; no donor bytes are
copied into the repo — only numbers and labels. Validation gate: `min(grid)`
and `max(grid)` must equal `float32(HeightFieldMin/Max)` from the matching
`pattern.lib` section (678/680 pass; exceptions in §4.9).

---

## 7. Implications for the port (all **PORT APPROXIMATION**)

1. **Fix the table producer, not just the tables.** Any tool exporting relief
   numeric data must use `G = 8 + (w−1)*(h−1)` and derive `N` from dimensions,
   never scan for min/max. `variant3d/tools/parse_terrain.py` currently only
   prints generator text; the prior `donor_gen.py` mask reader reads `w*h`
   bytes and therefore absorbs the first `w*h−N` float bytes.
2. **Correct the already-transcribed grids.** `RELIEF_GRID_K_RAVINE_1`,
   `RELIEF_GRID_PLT2`, `RELIEF_GRID_HIL1`, `RELIEF_GRID_G_HIL4` in `game.gd`
   (via `DPATTERN_01 Appendix A`) are shifted; §4.10 gives replacements.
   `k_ravine_big_stone_1` (G07 Tier 1) was already at the correct offset.
3. **Export full grids, not 8×10 means, when silhouette matters.** The 8×10
   tables are only debug/preview aids (DPATTERN `:595-600`); the true payload
   is `w*h` float32. A derived numeric JSON table (no donor binary) is safe.
4. **Do not invent prop mapping.** `id` is a byte-sized opaque index; the
   `.pattern` files contain no asset names. Linking `id` → `BaseName` requires
   separate donor engine/RTTI evidence (F08/D07/D01), not a guess.
5. **Collision/stand behaviour is not in the height plane alone.** The
   `(w−1)×(h−1)` mask, int32 weight block and 13-byte tail carry per-cell flags
   whose meanings are UNVERIFIED; a port using only the mask/height is a
   labelled approximation, not donor behaviour.
6. **Mountains remain prop-driven.** `g_mnt_1`/`g_mnt_3` have all-zero grids at
   the correct `G` (E11); DPATTERN §4.6 conclusion stands, and is strengthened
   by the exact closure proof.

---

## 8. Risks

| # | Risk | Label | Mitigation |
|---:|---|---|---|
| 1 | Corrected grids change stamp shape vs the currently gated 8×10 tables | [D] | Re-run gates; stage one id at a time; do not lower thresholds. |
| 2 | 2 stale `pattern.lib` sections give wrong min/max | [O] | Gate on binary grid extrema; log config mismatch; never "fix" config silently. |
| 3 | Weight/tail semantics guessed as collision/stand | [U] | Keep field bytes in derived JSON under `labels: UNVERIFIED`; do not wire to gameplay until D07/D06 evidence lands. |
| 4 | Case-only filename mismatch (`K_ravine_2`) | [O] | Case-fold lookup explicitly in any exporter. |
| 5 | No donor GPU A/B frame | [U] | No parity claim; every visual expectation INFERRED. |

---

## 9. UNVERIFIED register

1. **[U]** Meaning of Rec24 `id` (0…255): model index, tile index, colour byte
   or RNG seed — no donor plaintext consumer.
2. **[U]** Meaning of Rec24 `tail[4]` and PRE; distribution only.
3. **[U]** Meaning of the four `1.0f` fields (likely scale/alpha defaults — inference only).
4. **[U]** Meaning of `int32[4N−1]` weight values 0/99/100/101/200 and their
   float-looking exceptions.
5. **[U]** Meaning of Tail13 `i16` (−1/255) and `flag` (0/1).
6. **[U]** Why the weight region is `16N−4` (one int32 short of `4N` groups) —
   byte accounting is exact, sub-field framing beyond `int32[4N−1]` is not proven.
7. **[U]** Engine blend order (`Replace`, `ReplaceForWater`, `Smooth`, clamp,
   `HeightFieldScale` sign) — no plaintext consumer (DPATTERN §5.2, §9 Q2).
8. **[U]** File-row → map-row sign of the height grid (`row_flip`).
9. **[U]** Runtime selection among pattern.lib `Objects` and whether the
   binary per-cell records are consumed at all for a given `TilesStand`/
   `GameObjectsStand`/`DecalsStand` combination.

---

## 10. Open questions

1. Can D01's RTTI/CODE lift identify the loader struct that reads
   `mask[N], float[wh], Rec24[N], i32[4N−1], Tail13[N]` and confirm field names?
2. Does `id` index a global object table, and if so where is that table?
3. Are the four `1.0f` values authored scale/rotation defaults, and why never
   varied in 550,908 records?
4. Do `int32` weights encode terrain-material percentages per lattice corner?
5. Are Tail13 `flag=1` cells the "standable"/collision set used by
   `CollisionStand=True` patterns?
6. Why do `d_tls_*` use `i16=255` instead of `−1`?
7. Should the two stale sections (`k_plain_mid_12`, `m_swamp_12_old`) be treated
   as donor bugs or as evidence of a second file version?

---

## 11. Five-line summary

1. **Format closed:** `filesize = 8 + 4*w*h + 54*(w−1)*(h−1)`, verified 710/710 donor files with zero residual.
2. **Five regions with exact offsets:** `u8 mask[N]`, `float32 grid[w*h]` at `8+N`, 4-byte PRE, `N×24` records, `int32[4N−1]` weights, `N×13` tail.
3. **DPATTERN-01 offset error found:** 17/29 audited grid offsets shifted; corrected 8×10 tables for `k_ravine_1`, `plt2`, `hil1`, `g_hil4` (+ correct `k_ravine_big_stone_1`) are provided.
4. **`pattern.lib` linkage resolved:** section `Name` → `<Name>.pattern`, 679 exact + 1 case mismatch, 678/680 min/max matches; object counts are a different population.
5. **Still UNVERIFIED:** semantics of `id`, record tail, weights and tail flags; engine blend and row flip — all port use remains PORT APPROXIMATION, no donor parity claim.

*End of F01. One report written; no donor file copied, executed or modified; no repo source, asset, config, test, Godot or git state changed.*
