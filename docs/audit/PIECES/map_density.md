---
title: T2 PIECE — map density (whole-map forest/rock/resource census vs donor)
owner: T2-DENSITY
date: 2026-11-21
scope: research-only — quantify the port/donor density gap, rank root causes, propose minimal generator changes; no code edits, no Godot run, no donor copies
status: DONE (research)
---

# T2 DENSITY — whole-map census and the forest-coverage gap

**Only file written:** this document. All scratch decoders/crops live under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (`density_probe.py`,
`density_probe2.py`, `density_probe3.py`). The donor
(`C:\Games\Cossacks 3`) was read **read-only**; nothing from it was copied into the repo.
No Godot process was started — the existing `app/shots/full_map_dump.json` was decoded
directly with the same decoder the tool uses (`app/tools/full_map_shot.py:191-227`).

Evidence tags: **observed** (read/decoded directly), **derived** (deterministic arithmetic
on observed values), **inferred** (best reading without direct proof), **UNVERIFIED**
(could not be confirmed read-only).

---

## 1. Sources

| Source | Lines / field | Role |
|---|---|---|
| `app/shots/full_map_dump.json` | `terrain`, `tileblock`, `height`, `res`, `starts`, `blocked`, `clusters`, `meta` | Primary measurement (seed 20261113, 320×320, mask `land/4pl_mask_land_176_gauss.png`, water=0, summer, quality=high) |
| `app/tools/full_map_shot.py` | 95-96, 187-227, 305-348 | Dump schema + terrain code map + resource-cell collapse |
| `app/shots/full_map_320x320_tile1.json` | `compose.terrain_histogram` | Sidecar cross-check of the same dump |
| `app/scripts/pattern_gen.gd` | 9-36, 71, 109-186, 201-289, 291-366 | Port recipe counts, `area_scale`, occupancy, `needed=floor(W*H*freq)` relief analogue |
| `app/scripts/game.gd` | 280, 386-430, 494-599, 866-879, 948-977 | Stamp→terrain paint, forest core-disc cap, groves, start keep-clear |
| `app/scripts/world.gd` | 16, 1463-1516 | 1-3 trees per forest cell at 32 px/tile → trees/MP conversion |
| `app/scripts/data.gd` | 23 (`TILE_M=2.0`) | 16 px/m × 2 m = 32 px per in-game tile |
| `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc` (D1) | 1688-1693, 1712-1739, 1757-1765, 1774-1778, 1836-1907 | Donor base freqs, size modifier, foreststype=0 family calls |
| `C:\Games\Cossacks 3\data\scripts\lib\misc.script` (D9) | 3615, 3681-3727, 3878-3941 | `SetupPatternsByType` `needed`/`trycount`, Freq×0.2 damping, free-mask constants |
| `C:\Games\Cossacks 3\data\game\var\generator.cfg` (D8) | 60 families / 467 names (per `TERRAIN_DONOR_PATTERNS.md:44`) | Family inventory and per-member `Freq` |
| `app/assets/terrain/patterns/donor_patterns.json` | `families`, `patterns` | Mean footprint cells of the converted forest families |
| `docs/audit/TERRAIN_REFERENCE_IMAGES.md` (TS-1) | 100-104, 176 | Tree-density targets 20-60 / 150-250 / 650-1000 trees/MP |
| `docs/audit/PIECES/forest_conifer.md` | 113-120 | Port per-cell detail density ≈1953 trees/MP (2-3× donor dense) |
| `docs/audit/TERRAIN_DONOR_PIPELINE.md` | §3.4, §3.5, C15/C16 | Donor `needed`/`trycount`/prob model, cross-check |
| `docs/audit/TERRAIN_DONOR_PATTERNS.md` | 37-44 | 710 `.pattern` files, 60 cfg families |

---

## 2. Measurement — the port whole-map dump (observed)

Decoded `terrain[]` (1 byte/cell; codes `0=grass,1=road,2=forest,3=water,4=sand,5=rock`
per `full_map_shot.py:96`) and `res[]` directly. The dump is 102,400 bytes of terrain,
102,400 of tileblock, 409,600 of height (float32), 828 resource nodes, 4 starts.

**Map-area units used below.** Two raster scales exist in this project, so both are reported:
- `tile_px=1` compact diagnostic: 320×320 px = **0.1024 MP** (1 MP = 10⁶ px).
- `tile_px=64` canonical confrontation texture: 20480×20480 = **419.43 MP**
  (`full_map_shot.py:10-18`, `full_map_20480x20480_tile64.json`).
- The **in-game** visually relevant tile is 32×32 px (`data.gd:23 TILE_M=2.0` × `world.gd:16`
  16 px/m), which is the scale TS-1's trees/MP must be compared at (see §4).

### 2.1 Terrain and resource census

| Class | Cells | % of 102,400 | per MP (tile_px=1) | per MP (tile_px=64) |
|---|---:|---:|---:|---:|
| Grass (code 0) | 97,766 | 95.47 % | 954,746 | 233.09 |
| Rock (code 5) | 2,768 | 2.70 % | 27,031 | 6.60 |
| Forest (code 2) | 964 | **0.94 %** | 9,414 | 2.30 |
| Road (code 1) | 902 | 0.88 % | 8,809 | 2.15 |
| Water / sand (3/4) | 0 | 0.00 % | 0 | 0 |

| Resource field | Count | per MP (tile_px=1) | Notes |
|---|---:|---:|---|
| `res[]` nodes (all) | 828 | 8,086 | collapse to 106 distinct cells in compositor (`resources_drawn=106`) |
| wood | 266 | 2,598 | harvestable tree nodes from `_scatter_forest` + forest stamps |
| bush | 243 | 2,373 | decor |
| food | 173 | 1,689 | wheat/farms |
| stone | 123 | 1,201 | quarry nodes |
| gold / iron / coal | 8 / 8 / 7 | 78 / 78 / 68 | ore deposits |
| `blocked[]` set cells | 3,013 | 29,422 | 2.94 % of map |
| `clusters[]` entries | 9 | — | 7 with `r=88` (44 tiles), 2 with `r=8` (start clusters) |

### 2.2 Spatial structure (4-neighbour connected components, derived)

| Class | Components | Largest sizes (cells) | ≥10 cells | Singletons |
|---|---:|---|---:|---:|
| Forest | 10 | 249, 211, 193, 193, 21, 21, 21, 21, 21, 13 | 4 | 0 |
| Rock | 41 | 1839, 145, 129, 115, 110, 105, 96, 87, 58, 31, … | 11 | several |

**Observed:** the four big forest blobs are the only real patches; the six 13-21 cell blobs
are the small pine cores. Total forest canopy covers **0.94 %** of the map. The dominant rock
component (1,839 cells) is the ravine/cliff band.

### 2.3 Start adjacency / fairness (observed)

Starts are in world metres (TILE=2 m ⇒ 1 tile = 2 m; `pattern_gen.gd:81-82` divides by 2.0).
Radii below are converted from tiles to metres.

| Radius | start0 (601,43) | start1 (71,581) | start2 (80,80) | start3 (560,560) |
|---|---:|---:|---:|---:|
| forest cells ≤7 tiles (14 m) | 0 | 0 | 0 | 0 |
| forest cells ≤12 tiles (24 m) | 39 | 42 | 0 | 0 |
| forest cells ≤22 tiles (44 m) | 301 | 311 | 0 | 0 |
| forest cells ≤30 tiles (60 m) | 404 | 442 | 0 | 0 |
| all `res[]` ≤60 m | 198 | 208 | 14 | 16 |
| all `res[]` ≤28 m (14 tiles) | 7 | 9 | 6 | 6 |

Two facts:
1. **RELIEF-1 ring holds** — zero forest cells within 7 tiles of *every* start, consistent
   with `_gen_finish`'s `_clear_area(st, 14.0*TILE)` (`game.gd:956`) plus the C1/C2 ellipses
   (`pattern_gen.gd:201-202, 268-269`). Any density fix must preserve this.
2. **Severe start asymmetry** — starts 0/1 carry 404/442 forest cells within 30 tiles and
   ~200 nodes within 60 m; starts 2/3 carry 0 and 14-16. The per-start ratio is ≥14× for
   resources and unbounded for forest cells. Which of these four mask markers are the
   *active* player starts is **UNVERIFIED** (`game.gd:731-747` snaps starts off water and
   only uses `starts[0..1]` for the road); do not "fix" until confirmed.

---

## 3. Donor expected stamp counts at 320×320 (derived)

### 3.1 Formula (literal donor code)

`SetupPatternsByType` (`misc.script:3681-3727`):
```
mapsizeoptimise = (320*320) / (W*H)          ; :3686
if mapsizeoptimise < 1: mapsizeoptimise *= 0.65
needed   = floor(W*H*freq)  (round-to-1 if freq>0 but floor==0)   ; :3695-3703
trycount = floor(256 * mapsizeoptimise)                          ; :3704
```
At W=H=320: `mapsizeoptimise=1`, `trycount=256`, `needed=floor(102400*freq)`.
Each successful placement multiplies that **pattern member's** Freq by 0.2, floor 0.0001
(`misc.script:3615-3618`) — this limits repetition *within* a family, it does **not** change
the family's `needed` count.

Base freqs (`dogenerate.inc:1688-1693`):
`frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `dcr=0.0005`,
`stn1=0.00016`, `stn2=0.00012`. Scaled at `:1774-1778` by `probsmall/probmid/problarge`,
then by the **literal 320-map size modifier** `640/((320+320)/2)=2.0` at `:1718-1725`.
`prob{small,mid,large,huge}` are empirically sampled at runtime
(`misc.script:3931-3941`: constants 340/182/74/55; `:3878-3927`: 32,000 greedy probes ×4).
They cannot be re-derived read-only, so the table gives two columns: **prob=1, modifier=1**
(pure freq literals) and **modifier×2** (the literal 320 calibration with prob≈1).

### 3.2 Vanilla foreststype=0 family calls (`dogenerate.inc:1836-1898`)

| Family (D1 call) | Freq expression | freq (prob=1) | needed (prob=1) | needed (mod×2) |
|---|---|---:|---:|---:|
| `forests_pinefir_big` | `frs_big/8` | 0.00011250 | 11 | 23 |
| `forests_spruce_big` | `frs_big/8` | 0.00011250 | 11 | 23 |
| `forests_pine_big` | `frs_big/8` | 0.00011250 | 11 | 23 |
| `forests_pine_big_2` | `frs_big/8` | 0.00011250 | 11 | 23 |
| `forests_spruce_medium` | `frs_mid/6` | 0.00015000 | 15 | 30 |
| `forests_pinefir_medium` | `frs_mid/6` | 0.00015000 | 15 | 30 |
| `forests_pine_medium` | `frs_mid/6` | 0.00015000 | 15 | 30 |
| `forests_pinefir_small` | `frs_small/4` | 0.00013500 | 13 | 27 |
| `forests_pine_small` | `frs_small/4` | 0.00013500 | 13 | 27 |
| **All forest families** | — | — | **115** | **236** |
| `stones` (stn1 call) | `stn1` | 0.00016 | 16 | 32 |
| `stones` (stn2 call) | `stn2` | 0.00012 | 12 | 24 |
| `plain_big` (×2 calls) | `pln_large=0.00005` | 0.00005 | 10 | 20 |
| `plain_medium` (×2 calls) | `pln_mid=0.0001` | 0.0001 | 20 | 40 |
| `plain_small` | `pln_small=0.0003` | 0.0003 | 30 | 61 |
| `swamp_big/medium/small` | `plain*problarge/2*probmid/6*probsmall` | 0.00005/0.0001/0.0003 | 5/10/30 | 10/20/61 |
| `lake_big`, `lake_small` | `plain*2*0`, `plain*0` | 0 | 0 | 0 (hard-zeroed, D1:1735-1736) |

Relief (relieftype=0 "plains", `dogenerate.inc:1625-1629,1757-1765`, same `needed` rule):
`mountains` 2/4, `plateau_big` 1/1, `plain_huge` 5/10, `ravine_big` 1/1, `plateau` 1/1,
`plateau_small` 1/1, `hills_dark` 3/7, `hills_light` 3/7 (prob=1 / mod×2).
These are *upper bounds*: `trycount=256` plus the no-overlap test cause a documented
shortfall (`TERRAIN_DONOR_PIPELINE.md:149,253`).

### 3.3 Coverage implied by the donor footprints (derived, assumption-tagged)

Mean stand-cell counts per pattern from `donor_patterns.json` (port copy of the donor masks):
`pinefir_big` 879, `spruce_big` 554, `pine_big` 154, `pine_big_2` 184;
`spruce_medium` 450, `pinefir_medium` 306, `pine_medium` 68;
`pinefir_small` 161, `pine_small` 38.

- prob=1 column: `11×(879+554+154+184) + 15×(450+306+68) + 13×(161+38) = 34,428` footprint
  cells ≈ **33.6 %** of a 320×320 map before rejection.
- mod×2 column: `23×… + 30×… + 27×… = 70,826` ≈ **69.2 %** before rejection.
- **Inferred** (50-70 % placement success under `trycount=256`/overlap): donor target forest
  coverage ≈ **17-48 %**. **UNVERIFIED** — no donor map was generated; prob values are
  unresolved (§6). Even the low end is ~18× the port's 0.94 %.

---

## 4. Donor vs port density table

| Metric (320×320) | Donor expected | Port actual | Ratio / verdict |
|---|---|---|---|
| Global forest-family stamps | 115 (prob=1) … 236 (mod×2), §3.2 | **4** (`pattern_gen.gd:279`, base 1 × `area_scale` 4) | 29-59× too few |
| Near-start forest-family stamps | full C1/C2/C3 sequence (`D1:732-769`) | 8 `pine_small` + 4 `mixed_medium` (`pattern_gen.gd:266-267`) | partial |
| **Total forest stamps** | ≥115 | **16** (4 global + 12 near-start) | ≥7× too few |
| Stamp footprint retained | donor mask (~38-879 cells ×s²) | `core_r=clamp(cext*0.25, 3 m, 9 m)` → ≤4.5-tile radius, **≤~64 cells** (`game.gd:523`) | dominant coverage loss |
| Forest cells on map | ~17-48 % coverage (§3.3, inferred) | **964 cells = 0.94 %** | ~18-50× gap |
| Trees/MP inside forest (32 px/tile) | 650-1000 dense, 150-250 rim, 20-60 plain (TS-1 §5:176) | **1-3 trees/1024 px² = 976-2929, mean ≈1953/MP** (`forest_conifer.md:119-120`) | per-cell **2-3× too dense** |
| Trees/MP whole map (2 trees/cell) | — | 1,928 trees / 419.43 MP = **4.60/MP** | below even sparse-plain 20-60 |
| Stone stamps | 28 (16+12) | 12 global + 8 near-start = 20 | ~0.7× |
| Relief stamps (plains) | 17-26 | hills 8+8=16, no plateau/ravine/plain family | family set incomplete |
| Start-min forest cells ≤30 tiles | symmetric in donor (per-start SetupStartingResources) | 404/442 vs 0/0 | **fairness FAIL** (§2.3) |

**Central paradox:** the port's *per-cell* forest detail is 2-3× denser than donor dense
forest, but the map has **18-50× too few forest cells**. The density gap is a **coverage**
gap, not a per-tree gap. Adding trees to each existing cell would make the per-MP mismatch
worse; the fix must add forest *cells/clumps* and thin per-cell detail.

---

## 5. Root-cause ranking

| # | Cause | Evidence | Effect |
|---|---|---|---|
| **1** | Global forest recipe collapsed to one family, base weight 1 | `pattern_gen.gd:273-279`; comment `:274-278` says painting all 7 families gave "~38 extra cores (patches 42, target 8-14)", so they kept `forests_pine_small` only | 4 global stamps vs donor 115-236; "8-14 patches" is a port-invented target, not donor-derived |
| **2** | Forest footprint discarded: `core_r = clampf(cext*0.25, 1.5*TILE, 4.5*TILE)` | `game.gd:516-537`, cap at `:523` | every stamp paints ≤4.5-tile radius (≈64 cells); donor masks (scaled ×s²=4) are thrown away; single largest coverage multiplier |
| **3** | No donor freq model for forests/stones/plains/swamps | `pattern_gen.gd:272-289` vs `D1:1688-1907`, `D9:3681-3704` | no `floor(W*H*freq)`, no `prob*` scaling, no ×2 size modifier, no Freq×0.2 damping; `area_scale`+`maxi(1,…)` is a coarse stand-in that does not scale forest at all at 320 |
| **4** | Per-cell detail already 2-3× donor dense | `world.gd:1482` `count=1+bucket(...,3)`; `forest_conifer.md:119-120` | raising trees/cell is the wrong lever; will overshoot 650-1000/MP |
| **5** | Shared occupancy + start ellipses + RELIEF-1 clear ring | `pattern_gen.gd:109-118,201-202,268-269`; `game.gd:956` `_clear_area(st,14*TILE)` | keeps starts walkable (required) but, with only 4 global stamps, leaves two starts with **zero** forest within 30 tiles; new stamps must use a separate grid or be placed symmetrically |
| **6** | Near-start groves are wood *resource nodes*, not forest cells | `_scatter_forest` only calls `_add_res("wood")` (`game.gd:405-430`); terrain painting is a separate small disc at `game.gd:876-879` | start groves do not show up in the forest-cell count; explain part of the start asymmetry (rest UNVERIFIED) |

Secondary (not density-driving but relevant to any fix): tile grid step 120 instead of
donor 25 (`pattern_gen.gd:204-205`; `TERRAIN_DONOR_PIPELINE.md` C9), static `pick` weights
(`pattern_gen.gd:128-147`, C14), missing shore/G-code mask prefill (C13).

---

## 6. Fix proposals (targets, not applied)

All proposals are **minimal** and assume the active-start question in §2.3 is resolved first.
They respect the RELIEF-1 start flatten ring: no proposal writes `terrain=2` or clears
`blocked[]` inside 7 tiles of any start.

### F1 — Restore donor forest stamp counts (`pattern_gen.gd:273-289`)
Replace the single `["forests_pine_small",1,"forest"]` global recipe with the seven
foreststype=0 families driven by `needed=floor(W*H*freq)` using the same relief-style loop
already at `pattern_gen.gd:358-366` (table §3.2). Keep the near-start
`SetupStartingResources` block (`pattern_gen.gd:263-269`) byte-identical for fairness.
Use a **separate forest occupancy grid** (as relief does at `:297-331`) so tile/mine/stone
stamps cannot starve the new forest pass, and delete the P-46 "8-14 patches" cap comment.

- **Acceptance A1:** at seed 20261113 the dump contains ≥100 forest stamps (baseline 16)
  and ≥15,000 forest cells (≥15 % coverage; baseline 964).
- **Acceptance A2:** ≥40 forest components of ≥10 cells (baseline 4); no two forest
  stamps share a footprint cell (overlap count 0).

### F2 — Stop discarding the stamped footprint (`game.gd:516-537`, cap at `:523`)
Change `core_r = clampf(cext*0.25, 1.5*TILE, 4.5*TILE)` to paint the **scaled donor cells**
(or their filled convex extent) with a generous cap, e.g.
`clampf(cext*0.5, 1.5*TILE, 12.0*TILE)`. The existing `if tt==3 or 4 or 5: continue`
guard (`:533-534`) already protects sand/water/rock; keep it. Never write into a start
keep-clear ring (F1 constraint).

- **Acceptance A3:** mean painted forest cells per forest stamp ≥150 for big families and
  ≥40 for small families (baseline ≈60 overall).
- **Acceptance A4:** rock cells 2,768 ±1 % and `blocked[]` count 3,013 ±1 % after
  `_gen_finish`; zero forest cells inside 7 tiles of any start (unchanged from §2.3).

### F3 — Thin per-cell detail as coverage rises (`world.gd:1482`)
Do **not** increase trees per cell. Move from `count=1+bucket(...,3)` (1-3, mean 2) toward
1 tree/cell plus a hash-gated second tree (~30-35 %), so a filled patch lands in the donor
650-1000 trees/MP band at 32 px/tile. Keep the three size buckets of `forest_conifer.md §2.1`.

- **Acceptance A5:** within ≥3 sampled solid patches, trees/MP ∈ [650,1000] by the TS-1
  100 px-grid method; ≥3 size buckets still present.
- **Acceptance A6:** whole-map tree count ≥3× the current 1,928-implied level while
  per-MP patch density stays in band (i.e. gap closed by coverage, not by per-cell density).

### F4 — Donor Freq damping (`pattern_gen.gd:128-147`)
Seed family member weights from the parsed `generator.cfg` counts
(`TERRAIN_DONOR_PIPELINE.md §3.6`) and apply `freq*=0.2` (floor 0.0001) after each placement
(`misc.script:3615`). Variety only; no count change.

- **Acceptance A7:** over 1,000 stamps of `forests_pine_big`, no single pattern chosen >25 %
  of the time; name sequence identical for the same seed across two runs.

### F5 — Start-fairness guard (`pattern_gen.gd:263-269`, `game.gd:948-977`)
After confirming active starts, mirror the full `D1:732-769` sequence for **every** active
start and re-measure §2.3.

- **Acceptance A8:** for every active start, forest cells ≤30 tiles ≥80 % of the median
  across starts, and `res[]` nodes ≤60 m within 80 % of the median (max/min ≤1.5);
  baseline max/min is 14×+ and must not worsen even if active-start confirmation fails.
- **Acceptance A9:** zero forest cells inside 7 tiles of any start (RELIEF-1 unchanged).

### F6 — Gate preservation (documentation/QA, no code change)
Re-run `--dump-map` seed 20261113 through `app/tools/full_map_shot.py --gen-dump` (the only
legal Godot path) plus the existing selftest/scan suites.

- **Acceptance A10:** `app/selftest.json` `passed=true` and every step green; scan-gate
  metrics (relief/height/shore family) unchanged or explicitly re-baselined;
  `terrain_histogram_by_code` water/sand counts remain 0; no new blocked cells in start rings.

---

## 7. Claim table

| # | Claim | Evidence | Method | Verdict | Caveat / correction |
|---|---|---|---|---|---|
| 1 | Dump is 320×320 = 102,400 cells, no water/sand | `full_map_dump.json` terrain bytes | base64 decode + Counter | **observed** | mask water=0; matches sidecar histogram |
| 2 | Forest 964 cells (0.94 %), rock 2,768 (2.70 %), road 902, grass 97,766 | same | decode + Counter | **observed** | exactly 102,400 total |
| 3 | Forest = 10 components; only 4 ≥25 cells | same | 4-neighbour flood fill | **derived** | component sizes 249/211/193/193 + 21×5 + 13 |
| 4 | 828 resource nodes (wood 266, bush 243, food 173, stone 123, ore 23) | `res[]` | Counter | **observed** | compositor draws 106 distinct cells |
| 5 | Zero forest cells within 7 tiles of all four starts | dump + TILE=2 m | radius filter | **derived** | RELIEF-1 ring holds |
| 6 | Start asymmetry: forest 404/442 vs 0/0 within 30 tiles; resources ~200 vs 14-16 within 60 m | dump + starts | radius filter | **observed** | active-start identity **UNVERIFIED** |
| 7 | Donor `needed=floor(W*H*freq)`, `trycount=256` at 320, Freq×0.2 | `misc.script:3686-3704,3615`; `D1` | direct read | **observed** | mapsizeoptimise=1 at 320 |
| 8 | Donor forest families need 115 (prob=1) / 236 (mod×2) stamps at 320 | `D1:1688-1693,1774-1778,1836-1898` | arithmetic | **derived** | prob values not re-derived |
| 9 | Donor forest coverage ≈17-48 % vs port 0.94 % | §3.3 footprint means + 50-70 % success assumption | arithmetic + assumption | **inferred** | 50-70 % success **UNVERIFIED** |
| 10 | Port global forest stamps = 4; total forest stamps = 16 | `pattern_gen.gd:279,266-267`; `area_scale=4` | read + arithmetic | **derived** | P-46 comment confirms deliberate cut |
| 11 | Each forest stamp paints ≤~64 cells because of the 4.5-tile radius cap | `game.gd:523` | arithmetic on TILE=2 | **derived** | cap is literal |
| 12 | Per-cell port detail = 976-2929 trees/MP (mean 1953), 2-3× donor dense | `world.gd:1482`; `forest_conifer.md:119-120` | prior derived + 32 px/tile | **derived** | crown overlap ±25 % (TS-1 §7) |
| 13 | Whole-map port tree density ≈4.6 trees/MP (2 trees/cell) | 964 cells × 2 / 419.43 MP | arithmetic | **derived** | mixing scales; use §4 per-biome comparison instead |
| 14 | TS-1 targets 20-60 / 150-250 / 650-1000 trees/MP | `TERRAIN_REFERENCE_IMAGES.md:176` | direct read | **observed** | ±25 % crown-count error |
| 15 | Fix must add cells, not trees-per-cell | causes #1-4 | inference from 12 + 2 | **inferred** | depends on active-start confirmation |
| 16 | Donor maps place 8 forest families globally at 320 | `D1:1836-1898` | direct read | **observed** | foreststype forced to 0 at `D1:5-6` |
| 17 | Port's 8-14 "patch target" is donor-faithful | `pattern_gen.gd:275-276` | — | **UNVERIFIED / rejected** | no donor source; donor `needed` counts are 115-236 |

---

## 8. Open questions / unknowns

1. **Which of the four mask starts are active players?** `game.gd:731-747` snaps starts and
   uses only `starts[0..1]` for the road; the dump carries 4. This decides whether §2.3's
   asymmetry is a real fairness defect or an artifact. (Blocks F5 enforcement.)
2. **`prob{small,mid,large,huge}` values** are measured at runtime from the free mask
   (`misc.script:3878-3941`); they were not re-derived read-only. §3.2's mod×2 column assumes
   prob≈1; real counts could be higher or lower.
3. **Donor placement success rate** under `trycount=256` + no-overlap was not measured
   (no donor generation permitted); §3.3's 50-70 % is an assumption.
4. **`foreststype`**: `D1:5-6` forces 0 (pine/fir/spruce) in vanilla; the port also stamps
   `forests_mixed_medium` near starts (`pattern_gen.gd:267`) — non-vanilla, but it does not
   drive the global gap.
5. **Seed coverage**: all numbers are seed 20261113; a 10-seed sweep should be run
   before locking acceptance thresholds (targets in F1/A1-A2 are for this seed).
6. **Selective per-biome split** (plain/rim/dense) of the port forest cells was not measured:
   the dump has only a single `terrain=2` class, so rim-vs-dense density must be inferred
   from patch geometry (component size / edge ratio).

---

## 9. Bottom line

The port's whole-map dump is **0.94 % forest** with **16 forest stamps** and **1,953 trees/MP
inside those cells** (2-3× donor dense). The donor, by its own frequency table, would stamp
**115-236 forest families** and cover roughly **17-48 %** of a 320×320 map. The gap is
overwhelmingly a **coverage** gap created by (1) collapsing seven global forest families to
one and (2) shrinking every stamp to a ≤4.5-tile core disc. The minimal fix is to restore
the donor family counts with a separate occupancy grid, stop discarding the stamped
footprint, and thin per-cell detail from 2 trees to ~1 so newly added patches land in the
650-1000 trees/MP band — while holding the 7-tile start ring clear and re-checking the
start-fairness and selftest/scan gates.
