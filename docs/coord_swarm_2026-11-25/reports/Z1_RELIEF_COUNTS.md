---
id: Z1-RELIEF-COUNTS
title: "How many relief stamps should a random map place? Donor count algorithm vs port presets, grid inventory, donor-grounded proposal"
agent: "Z1-MAPGEN-RELIEF (read-only recon worker, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_ASSET_CONFIG_TEST_EDIT__NO_GODOT_RUN__NO_RUNNER_JOB__NO_GIT__NO_PARITY_CLAIM
scope: "One new file only: this report. variant3d/ read-only; app/ never touched. Donor C:\\Games\\Cossacks 3 read-only (text; no binary run/copy)."
output: docs/coord_swarm_2026-11-25/reports/Z1_RELIEF_COUNTS.md
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
label_key: "observed = literal port/donor line or JSON field read this pass | derived = arithmetic over observed literals | inferred = strong but indirect | UNVERIFIED = not measurable from plaintext/no donor run"
parity_guard: "NO DONOR GPU A/B EXISTS. Engine blend, mask packing and runtime multipliers are UNVERIFIED. No donor visual parity claim made anywhere."
---

# Z1-RELIEF-COUNTS — donor-grounded stamp counts

> [!IMPORTANT]
> Donor is truth. Every number below is either a literal `path:line` read or an
> explicitly labelled derivation. Donor files were opened in place only; no donor
> binary was run or copied. No Godot process or runner job was started by this
> worker. The verification commands in §5 are for COORD, not executed here.

## 1. Sources (all read-only)

| # | Path | Fact used |
|---|---|---|
| P1 | `variant3d/scripts/pattern_gen.gd:19-36,132-151,474-549` | Presets, recipes, `pick()`, count loop, 512-attempt placement. |
| P2 | `variant3d/assets/terrain/patterns/donor_patterns.json` (982,264 B) | 282 patterns; every record has exactly `w,h,cells`. |
| P3 | `variant3d/scripts/world3d_terrain.gd:185-244,458-511,1443-1451` | Only 2 coarse 8×10 tables; blend label; ledger. |
| P4 | `variant3d/config.json:29` | Shipped `features.terrain.relief_stamps = true` (observed). |
| D1 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:446-752` | Family memberships and every `Freq`. |
| D2 | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1621-1650,1695-1739,1747-1765` | 5 relief tiers, size modifier, family frequencies/divisors. |
| D3 | `C:\Games\Cossacks 3\data\scripts\lib\misc.script:3681-3737,3878-3940` | `needed` count algorithm and `probsmall/mid/large/huge` derivation. |
| C1 | `docs/.../reports/RELIEF_SEED_PROBE_01.md:29-36,147-162,189-195` | Runtime-confirmed seed 20261150: 1 `plt2`, `candidates=1`, `applied_cells=443`. |
| C2 | `docs/.../reports/DPATTERN_01_relief_grids.md:271-285,595-626` | Mountain grids all-zero; Appendix A coarse tables. |
| C3 | `docs/.../reports/DMAPGEN_01_skirmish_options.md:59-75,106-124,303-328` | Donor sizes 256/320/480/640; 5 relief ids; port size/tier mismatches. |
| C4 | `docs/.../reports/QA_RELIEF_DUMP_01.md:89` | 320² unbounded dump needed >180 s and was killed (cost warning). |

## 2. Q1 — port count arithmetic

**Observed formula** (`pattern_gen.gd:541-549`): for each of 8 recipes,
`freq = preset[key] / divisor`; skip if `<= 0`; `needed = int(W*H*freq)`; clamp to
`>= 1`; then `stamp_relief(family, needed, kind)`. `int()` truncates toward zero
= `floor` for positive values (**derived**). Each of the `needed` targets loops
up to 512 random placements and increments `done` only on a passing footprint
(`:515-539`); so `needed` is a target, and placed stamps `<= needed` (**derived**).
`pick()` (`:132-151`) is a weighted walk over family entries.

Preset literals (observed `pattern_gen.gd:19-23`) and recipe divisors (`:27-36`):

| Tier | plt | mnt | hil |
|---|---:|---:|---:|
| plains | 1e-5 | 2e-5 | 7.5e-5 |
| hills | 2e-5 | 2e-6 | 1.25e-4 |
| mountains | 5.5e-5 | 1.2e-4 | 5e-5 |

Recipes: `mountains`÷1, `plateau_big`÷3, `plain_huge`÷12, `ravine_big`÷1.5,
`plateau`÷3, `plateau_small`÷3, `hills_dark`÷2, `hills_light`÷2
(`pattern_gen.gd:28-35`).

**Derived `needed` per recipe (`mountains/plateau_big/plain_huge/ravine_big/plateau/plateau_small/hills_dark/hills_light`), total last:**

| Tier | 64² (4096) | 240² (57,600) | 320² (102,400) |
|---|---|---|---|
| plains | 1/1/1/1/1/1/1/1 = **8** | 1/1/1/1/1/1/2/2 = **10** | 2/1/1/1/1/1/3/3 = **13** |
| hills | 1/1/1/1/1/1/1/1 = **8** | 1/1/1/1/1/1/3/3 = **12** | 1/1/1/1/1/1/6/6 = **18** |
| mountains | 1/1/1/1/1/1/1/1 = **8** | 6/1/1/2/1/1/1/1 = **14** | 12/1/1/3/1/1/2/2 = **23** |

**Requested 240² arithmetic, plains `plt=1e-5` (derived):** `57600 × (1e-5/3)
= 0.192`; `int(0.192)=0` → clamp → **1 target per `plt/3` recipe**. There are
three such recipes (`plateau_big`, `plateau`, `plateau_small`, `pattern_gen.gd:29,32,33`)
→ **3 plateau-family targets**, but only the family literally named `plateau`
draws from `plt1..plt5` (D1 `:584-601`); the other two draw `f_plt_*` and `d_plt*`.
So exactly **1 `pick("plateau")` draw** per 240²/plains map. `plt2` has weight 1
of 5 equal weights (D1 `:584,588,592,596,600`) → `P(plt2)=1/5=20%` per draw
(**derived**); subject to 512-attempt footprint rejection (`:519-526`), expected
placed `plt2 <= 1` per map, i.e. **0.20 plt2 stamps/map** in expectation. The one
runtime-confirmed case is 64²/plains seed 20261150, which placed exactly one
`plt2` (C1 `:29-36,189-195`) — that is a measurement of the port, not donor parity.

## 3. Q2 — donor truth: how counts are computed

### 3.1 What `Freq` means (observed)

`generator.cfg` `Freq` is a **dimensionless relative weight for choosing a pattern
name inside one family**, not a stamp count. Evidence: `plateau` `plt1..plt5` each
`Freq = 1` (D1 `:584-601`); `plateau_big` `f_plt_big_1/2/3 = 3`, `f_plt_mid_1/2 = 2`
(D1 `:638-655`); `mountains` `g_mnt_1..7 = 1` (D1 `:663-688`); `hills_dark`
`hil1..4 = 1` (D1 `:696-709`); `hills_light` `g_hil1..9 = 1` (D1 `:717-750`);
`ravine_big` `k_ravine_big_stone_1..8 = 1` (D1 `:506-535`); `ravine_medium`
`k_ravine_1..9 = 1` (D1 `:543-576`); `plain_huge` `big_hill_1,k_plain_1..12 = 1`
(D1 `:449-498`). Equal `Freq=1` → equal 1/5 share for `plt2`.

### 3.2 The count algorithm (observed, D3)

`_misc_SetupPatternsByType(...,str,freq)` at `misc.script:3681`:
- `mapsizeoptimise = (320*320)/(W*H)`; if `<1`, multiply by `0.65` (`:3686-3688`).
- `needed := floor(W*H*freq)` (`:3695`); `neededround := round(W*H*freq)` (`:3696`);
  if `needed=0` and `freq>0`, `needed := neededround` (`:3697-3700`) — log text
  says "rounded to 1" (`:3702`) but the code uses `round()`, which can still be 0.
- `trycount := floor(256*mapsizeoptimise)` (`:3704`).
- For `i := 0 to needed-1` (`:3706`): pick name by weighted `Freq`
  (`_misc_GetPatternNameByParser`, `:3709`), try up to `trycount` random cells
  (`:3711-3715`), place on `_misc_CheckStandPatternExt` success, increment
  `realcount`, break (`:3717-3723`). Hence **actual placed <= needed** (**derived**).

**Freq units:** the `freq` argument is a **per-cell density** (expected stamps per
map cell), because `needed = floor(W*H*freq)` (`:3695`). Tier literals are
`1e-5 … 1.25e-4` cells⁻¹ (D2 `:1626-1648`).

### 3.3 Where the port matches, and where it does not

Donor relief tiers (observed D2 `:1624-1650`): id 0 `(plt,mnt,hil)=(1e-5,2e-5,7.5e-5)`
`:1626-1628`; id 1 `(2e-5,2e-6,1.25e-4)` `:1631-1633`; id 2 `(7.5e-5,7.5e-5,3e-5)`
`:1636-1638`; id 3 `(5.5e-5,1.2e-4,5e-5)` `:1641-1643`; id 4 `(9e-5,3.5e-5,3.5e-5)`
`:1646-1648`.

| Component | Port | Donor | Grade |
|---|---|---|---|
| Tier literals `plains/hills/mountains` | `pattern_gen.gd:20-22` | exact copies of donor ids 0/1/3 (D2 `:1626-1628,1631-1633,1641-1643`) | **FAITHFUL** (observed) |
| Missing tiers | 3 tiers only (`:19-23`) | 5 tiers (D2 `:1635-1639,1645-1649`) | **INCOMPLETE** (observed) |
| Divisors 7/8 | `:28-29,31-35` | `mnt`, `plt/3`, `plt/1.5`, `hil/2` (D2 `:1757-1758,1761-1765`) | **FAITHFUL** |
| `plain_huge` divisor 12 | `:26,30` | `pln_huge = plain*probhuge`, `plain=0.0001/2=5e-5` (D2 `:1727,1731`) | **INVENTED/APPROX** — no donor `12` literal (observed negative) |
| `×problarge` on `plt/mnt/hil` | absent | D2 `:1737-1739` | **MIS-SCALED** |
| `×probhuge` for `plain_huge` | absent | D2 `:1731` | **MIS-SCALED** |
| Non-640 size modifier | absent | `640/((W+H)/2)` applied to all four probs (D2 `:1718-1725`) | **MIS-SCALED** |
| `needed<1 → 1` clamp | `:547-548` | floor→round fallback, may stay 0 (D3 `:3695-3700`) | **MIS-SCALED** at tiny sizes |
| Name weights | `pick()` `:132-151`, family weights all 1.0 in P2 | equal `Freq` (D1 above) | **FAITHFUL** |
| `ravine_medium` omitted | not in recipes `:27-36` | `//`-disabled (D2 `:1760`) | **FAITHFUL** |
| 0.85 area modifier | absent | commented out (D2 `:1695-1709`) | **FAITHFUL** (both ignore) |

`problarge = _misc_GetFreePatternMaskCountModifier(24)/74`, `probhuge = count(29)/55`
(D3 `:3939-3940`; constants `:3933-3936`). The count modifier is a Monte-Carlo
packing estimate over `gPatternMask` (D3 `:3878-3927`) driven by donor-native
`RandomExt`, whose algorithm is engine-only (**UNVERIFIED**, C3 `:214-220`).
Therefore the numeric donor multiplier is **UNVERIFIED**: at 320² the omitted
size factor is `640/320 = 2.0`, at 240² `640/240 = 2.667`, at 64² `10`
(**derived** from D2 `:1718-1725`), times an unmeasurable `problarge` ≈ O(1)
(**inferred** only). Example of the clamp divergence: 64²/plains `plateau` gets
`4096×1e-5/3 = 0.0137` (**derived**) → donor floor 0, round 0 → **0 stamps**,
port clamps to **1** (`pattern_gen.gd:546-548`).

## 4. Q3 — decoded height grids vs analytic approximations

**Observed (P2):** `donor_patterns.json` has top-level keys
`version,source,note,donor_units,families,patterns`; `note` says cells are
centred donor-cell offsets; **all 282 pattern records have exactly the keys
`w,h,cells`** — no `height`, `grid`, `hgrid`, scale or clamp field. So **zero
relief ids have a real decoded height grid in `donor_patterns.json`**; it is a
footprint-only export.

**Observed (P3):** the only height numbers in `variant3d/` are two coarse 8×10
block-mean tables in `world3d_terrain.gd`: `RELIEF_K_RAVINE_1` (`:196-205`) and
`RELIEF_PLT2` (`:207-216`), registered in `RELIEF_TABLES` (`:222-241`). The file
states these are DEBUG/PREVIEW-GRADE means derived from DPATTERN-01 Appendix A,
that "the full `w*h` float32 grids are NOT copied into this file" (`:185-192`),
and carries `PORT APPROXIMATION — donor engine blend UNVERIFIED` (`:242-243`).
Mountain patterns have all-zero donor grids (C2 `:271-285`), so no height table
exists for them.

**Exact inventory (derived from P2 families + P3 tables):**

| Family (D1 lines) | Ids | Height data in port |
|---|---|---|
| `plateau` `:581-604` | `plt1,plt2,plt3,plt4_fixed,plt5` | only `plt2`: coarse 8×10 (P3 `:207-216`); other 4: footprint + analytic `game.gd:858-981` |
| `plateau_big` `:635-658` | `f_plt_big_1/2/3, f_plt_mid_1/2` | footprint only; analytic |
| `plateau_small` `:605-633` | `d_plt1..6` | footprint only; analytic |
| `mountains` `:660-691` | `g_mnt_1..7` | footprint only; donor grid all-zero (C2 `:271-285`), props absent |
| `hills_dark` `:693-712` | `hil1..4` | footprint only; analytic |
| `hills_light` `:714-753` | `g_hil1..9` | footprint only; analytic |
| `ravine_big` `:503-538` | `k_ravine_big_stone_1..8` | footprint only; analytic |
| `ravine_medium` `:540-579` | `k_ravine_1..9` | only `k_ravine_1`: coarse 8×10 (P3 `:196-205`), and donor stamp is `//`-disabled (D2 `:1760`) |
| `plain_huge` `:446-501` | `big_hill_1, k_plain_1..12` | footprint only; analytic |

## 5. Q4 — ranked verdict, proposal, predicted counts, verification

**Ranked verdict (derived/inferred, no parity claim):**
1. **MIS-SCALED (primary):** the port counts omit donor `×problarge` (D2 `:1737-1739`),
   `×probhuge` (`:1731`) and the non-640 size modifier (`:1718-1725`), and replace
   floor→round (D3 `:3695-3700`) with a hard `>=1` clamp (`pattern_gen.gd:547-548`).
   Net: under-counts relative to donor at normal sizes (≈2× at 320², ≈2.67× at
   240² before the UNVERIFIED `problarge`), over-places at tiny sizes.
2. **INVENTED:** `plain_huge ÷12` (`pattern_gen.gd:26,30`) has no donor literal;
   donor uses `5e-5 × probhuge` (D2 `:1727,1731`). Height grids: only 2 coarse
   tables; no decoded full grids exist in the repo (§4).
3. **FAITHFUL:** tier literals (ids 0/1/3), 7/8 divisors, Freq-based name weights,
   disabled `ravine_medium`, ignored 0.85 area block.

**Donor-grounded preset proposal (all literals cited; runtime multipliers UNVERIFIED):**

| Relief id (D2) | plt | mnt | hil |
|---|---:|---:|---:|
| 0 Plain `:1626-1628` | 1e-5 | 2e-5 | 7.5e-5 |
| 1 Low Mountains `:1631-1633` | 2e-5 | 2e-6 | 1.25e-4 |
| 2 High Mountains `:1636-1638` | 7.5e-5 | 7.5e-5 | 3e-5 |
| 3 Highlands `:1641-1643` | 5.5e-5 | 1.2e-4 | 5e-5 |
| 4 Plateaus `:1646-1648` | 9e-5 | 3.5e-5 | 3.5e-5 |

Count rule to replace `pattern_gen.gd:542-549`:
`freq_fam = tier_value × size_mod × problarge` (`:1737-1739,1718-1725`), with
`size_mod = 640/((W+H)/2)` when `W≠640 or H≠640` else `1` (`:1718-1725`);
`plain_huge freq = 5e-5 × probhuge × size_mod` (`:1727,1731`) — **not `plt/12`**;
`needed = floor(W*H*freq_fam)`, if 0 and positive use `round(W*H*freq_fam)`
(D3 `:3695-3700`); family divisors `mnt:1, plateau_big:3, ravine_big:1.5,
plateau:3, plateau_small:3, hills_dark:2, hills_light:2` (D2 `:1757-1765`).
`problarge`/`probhuge` values are mask/RNG-dependent and **UNVERIFIED** (D3
`:3878-3940`; C3 `:214-220`).

**Predicted current-port totals (from §2, derived from observed presets):** at
240² plains/hills/mountains = **10 / 12 / 14**; at 320² = **13 / 18 / 23**.

**Donor-grounded reference (derived, assumes `problarge=probhuge=1` — UNVERIFIED):**
plains 240² `mountains 3, plateau_big 1, plain_huge 7, ravine_big 1, plateau 1,
plateau_small 1, hills_dark 5, hills_light 5` = **24**; plains 320²
`4,1,10,1,1,1,7,7` = **32**. Compare port 10/13. The multiplier is the only
unverified term; the formula and literals are observed (D2/D3).

**Cheapest verification for COORD (NOT run by this worker).** 240² is cheapest;
320² unbounded dumps exceeded 180 s (C4 `:89`). Use three named seeds
`20261113` (baseline, C1 `:38-46`), `20261150` (confirmed plt2 at 64², C1 `:29-36`)
and `20261168` (second predicted plt2 seed, RELIEF_SEED_SCAN_01 `:215-219`).
Create each fixture OUTSIDE the repo under
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/` (template; change
only `random_seed`; relief `plains` inherited, flag already true at P4 `:29`):

```json
{
  "gameplay": {
    "render_mode": "3d",
    "random_seed": 20261113,
    "map_width_tiles": 240,
    "map_height_tiles": 240
  }
}
```

Then three commands from the repo root (Windows `python`, unique ids, quoted paths):

```
python variant3d\tools\godot_runner.py run --id z1relief-counts-240-20261113 --timeout 300 --max-wait 1800 -- --headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/s240_20261113.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/dump240_20261113.json"
python variant3d\tools\godot_runner.py run --id z1relief-counts-240-20261150 --timeout 300 --max-wait 1800 -- --headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/s240_20261150.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/dump240_20261150.json"
python variant3d\tools\godot_runner.py run --id z1relief-counts-240-20261168 --timeout 300 --max-wait 1800 -- --headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/s240_20261168.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z1relief/dump240_20261168.json"
```

Read from each dump: `meta.stamp_counts` (8 non-mine buckets + mine),
`relief_stamps`, `meta.relief_grid.candidates/applied_cells`. Compare the eight
non-mine buckets against §2's 240² column; any bucket above its target indicates
the clamp at `pattern_gen.gd:547-548` firing, and the whole-table shortfall versus
§5 donor reference measures the missing size/probability multiplier. Report job
tickets, `status`, `exit`, `SCRIPT ERROR` count and values verbatim; do not
upgrade any derived number without those dumps. No donor parity claim: donor
engine blend, silhouette and GPU appearance remain **UNVERIFIED** (P3 `:242-243`).

---

*End of Z1-RELIEF-COUNTS. One report written; game code/assets/config/tests, donor files, queue and git were READ-ONLY; no Godot process or runner job started.*
