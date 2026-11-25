# MAPGEN-RECON-01 — donor-grounded improvement plan for RANDOM MAP GENERATION (variant3d)

- id: MAPGEN-RECON-01 · date: 2026-11-25 · agent: MAPGEN-RECON-01 (read-only analysis worker)
- scope: `variant3d/` only. No code/config/asset/test edit, no Godot run, no git op, no donor binary read beyond text/data files (bytes + latin-1).
- labels: **observed** = literal source/donor bytes read this pass · **derived** = arithmetic/control-flow consequence · **inferred** = attribution without donor A/B · **UNVERIFIED** = not established. No donor GPU A/B exists; **no parity claim**.
- verdict: Maps look flat for five compounding, separately fixable reasons: (1) relief attempt counts are port-invented and tier-insensitive at ship sizes; (2) only 1 of ~40 relief ids stamps a (coarse, capped) donor grid; (3) a ~34-tile start-flatten ring suppresses relief near towns; (4) mountains stamp analytic bumps instead of donor props; (5) seed variety is coupled through one shared RNG stream. The "maze" is donor-faithful tile art + mask modulation (pale-cyan subset was sky bleed, fixed 84% in MASK-ALPHA-FIX-01); test\* on flat cells is **not** a bug.

## 1. Evidence table (path:line)

| # | Finding | Evidence | Label |
|---|---|---|---|
| E1 | Presets `plains {plt:1e-5,mnt:2e-5,hil:7.5e-5}`, `hills {2e-5,2e-6,1.25e-4}`, `mountains {5.5e-5,1.2e-4,5e-5}`; 8 recipes with divisors 1/3/12/1.5/3/3/2/2 | `variant3d/scripts/pattern_gen.gd:19-36` | observed |
| E2 | `needed = int(W*H*freq/div)` clamped `≥1`; relief has own `relief_occ` grid, 512-attempt rejection, `relief_stand` marks occupancy | `variant3d/scripts/pattern_gen.gd:541-549,480-539` | observed |
| E3 | Shared RNG `seed=(seed^0x5F356495)+(W*31+H)`; stream order tile→mine-replay→near-start→forest→recipes→relief; relief draws are deepest in stream | `variant3d/scripts/pattern_gen.gd:69-70,206-277,407-472,515-549` | observed |
| E4 | Only family `plateau` can emit `plt1..5`; `plt2` pick = 1/5 equal-weight; `ravine_medium` absent from recipes and `donor_patterns.json` | `variant3d/scripts/pattern_gen.gd:27-36,132-151`; `RELIEF_02_stamp_marker.md:68-84` (prior) | observed |
| E5 | Donor truth: `relieftype 0..4 → plt/mnt/hil` | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1621-1650` | observed |
| E6 | Donor truth: size modifier `640/((W+H)/2)` scales `probsmall/mid/large/huge`; `plt*=problarge` etc.; families `mountains mnt`, `plateau_big plt/3`, `plain_huge pln_huge`, `ravine_medium //`-disabled, `ravine_big plt/1.5`, `plateau plt/3`, `plateau_small plt/3`, `hills_dark/light hil/2` | `dogenerate.inc:1712-1765` | observed |
| E7 | Donor truth: `plateau plt1..5 Freq=1` incl. `plt2`; `plateau_big` Freq 3/3/3/2/2; `mountains g_mnt_1..7 Freq=1`; `hills_dark hil1..4`, `hills_light g_hil1..9` Freq=1; `ravine_medium k_ravine_1..9` Freq=1 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:540-753` (plateau `:580-604`, plt2 `:587-589`) | observed |
| E8 | Donor `SetRandomKey(randkey1)` re-issued before every stage | `dogenerate.inc:1616,1772`; `docs/decomp/DB_SCRIPTS.md:71` (full list `:1100,1161,1177,1213,1538,1616,1772,1909,1927`) | observed |
| E9 | Port P-31 partial: `gen_rng`, `GEN_STAGES`, `_reseed_stage()`; calls at terrain/starts/forests; `pattern_gen.build` still single-stream | `variant3d/scripts/game.gd:138-144,257-259,1125,1127,1286` | observed |
| E10 | Live relief: id-gated donor branch (`plt2`/`k_ravine_1` coarse 8×10 + `HeightFieldMin/Max`) before analytic fallback; audit ledger `candidates/applied_cells` | `variant3d/scripts/game.gd:937-1110` (gate `:974-984`, donor write `:1039-1055`, ledger `:1101-1110`) | observed |
| E11 | Start-flatten ring `protect=CIRCLE2*map_scale*1.5` skips stamping near starts | `variant3d/scripts/game.gd:955-966,1037-1038` | observed |
| E12 | Global clamp: donor cells single `±2.964` port bound; others dither-capped; **comment states no donor clamp exists** | `variant3d/scripts/game.gd:1216-1237` (donor branch `:1219-1229`) | observed |
| E13 | Legacy constants `RELIEF_PLATEAU/HILL/RAVINE = 2.964 / 2.964/2.25 / -2.964` kept for fallback only; comments mark R=96/R=48 truth as `+0.496/-0.558` | `variant3d/scripts/game.gd:74-83` | observed |
| E14 | Collision `\|dh\|>0.5` cardinal / `>0.55` diagonal → rock+blocked; skips water/sand | `variant3d/scripts/game.gd:1238-1262` | observed |
| E15 | Detail pass: `h<0.1` → lowground else highground, `tex=R div 2`, only block-0 cells change | `variant3d/scripts/game.gd:1911-1935` | observed |
| E16 | Smoothing lists contain `test8/test7` (Prob 1.0), `test9`, `rock4/rock8` incl. all-zero separator lists | `variant3d/scripts/game.gd:1560-1598` | observed |
| E17 | Cliff gates `abs(h)>2.7→rock8, >2.4→rock4, <0.1→none` + 8-sector orientation | `variant3d/scripts/game.gd:2077-2110` | observed |
| E18 | Base map: `relief()` exact 8-code decode (RCODE fix LANDED); `relief_smooth()` flag exposed | `variant3d/scripts/mapgen.gd:75-94` | observed |
| E19 | Mask pick `(seed^type.hash())+104729`, `randi()%N`; coastal smooth 1–3 passes by quality; `relief_smooth` flag NOT consumed downstream | `variant3d/scripts/mapgen.gd:51-61,92-94,145-238` | observed |
| E20 | Consumer: coarse `RELIEF_COARSE 10×8` tables only; footprint default 10×8; `dump["relief_stamps"]` reader; re-hmin/max on apply | `variant3d/scripts/world3d_terrain.gd:185-243,465-557,1189-1199` | observed |
| E21 | Mesh: `verts=(x+0.5-cx)*TILE_M, height*HEIGHT_SCALE`; face thresholds `cDiff1=0.5/cDiff2=0.55`; rock gates 2.7/2.4/0.1; shore `-0.1` | `variant3d/scripts/world3d_terrain.gd:1253-1255,153-162,177-183` + `variant3d/scripts/data.gd:23` (`TILE_M=2.0`) | observed |
| E22 | Producer marker `relief_stamps=[{plt2,cx,cy}]`, gated on `feature_terrain_relief_stamps()`; shipped `config.json` sets it `true`, code default `false` | `variant3d/scripts/main.gd:777-803`; `variant3d/scripts/config.gd:59,448-449`; `variant3d/config.json:29` | observed |
| E23 | Effective default tier is `hills` (config `apply()` overwrites `data.gd` `plains` default; shipped json has no `relief` key) | `variant3d/scripts/config.gd:548`; `variant3d/config.json:77-114`; `variant3d/scripts/data.gd:235` | observed/derived |
| E24 | `plt2` grid `min -0.0733 / max +3.6134, scale 1`; mountains grids all-zero → relief is `terrainmesh*` props; full grids on disk `data\pattern\*.pattern` (plt1/3/4_fixed/5, hil1-4, g_hil1 confirmed present) | `DPATTERN_01_relief_grids.md:142,154,168-169,271-285` + glob of `C:\Games\Cossacks 3\data\pattern\` | observed |
| E25 | Seed 20261150 (64²/plains) → `plt2@(54,33)`, `applied_cells=443`; default 20261113 → none; height min/max unchanged (`-1.1/+2.964`) | `RELIEF_SEED_PROBE_01.md:29-46,151-162` | observed (prior runtime) |
| E26 | Pale-cyan attribution REFUTED for dominant pixels (89% two cyans, 0 occurrences in 112 block PNGs); fix cut near-white 44,381→6,989, 0 exact-cyan below sky strip | `QA_WHITE_PIX_02.md:98-100`; `MASK_ALPHA_FIX_01.md:164-172` | observed (prior) |
| E27 | `test7/8/9` ≈15.7% offline is donor-bitmap-driven; reducing further needs replacing donor data (forbidden) | `TRN_DATA_implementation.md:58-64` | observed (prior) |
| E28 | No consumers of `feature_terrain_texgen_mode/m_per_tile/lighting/alpha_patch_mode/tile_diversity` found in `variant3d/scripts` (defs only in `config.gd`) | grep `feature_terrain_*` over `variant3d/scripts` | observed-negative |

## 2. Q1 — presets vs donor truth + faithful counts

Port formula (E2): per recipe `needed=int(W·H·freq/div)`, min 1. Donor (E5–E6): probability `p=freq/div·problarge·sizemod` fed to **native** `_misc_SetupPatternsByType`; count semantics are engine-side (**UNVERIFIED**), and `problarge`/`areamod` values are engine-computed (**UNVERIFIED**). The port comment (`pattern_gen.gd:15-18`) cites `misc.script:3686-3704` "freq>0 → at least one" — that rule's applicability to this path is **UNVERIFIED**. Treating `E[count]=W·H·p` with `problarge=sizemod=1` as a scale reference (derived, NOT donor counts):

| Tier | Family recipe (freq/div) | 240² (57,600): donor-ref / port | 320² (102,400): donor-ref / port |
|---|---|---|---|
| plains (plt=1e-5) | plateau, plateau_big, plateau_small (3.33e-6) | 0.19 / **1** | 0.34 / **1** |
| plains | ravine_big (6.67e-6) | 0.38 / **1** | 0.68 / **1** |
| plains | plain_huge (~4.2e-6*) | 0.24 / **1** | 0.43 / **1** |
| plains (mnt=2e-5) | mountains (2e-5) | 1.15 / **1** | 2.05 / **2** |
| plains (hil=7.5e-5) | hills_dark/light (3.75e-5) | 2.16 / **2** | 3.84 / **3** |
| hills (plt=2e-5) | plateau fam. (6.67e-6) | 0.38 / **1** | 0.68 / **1** |
| hills (mnt=2e-6) | mountains | 0.12 / **1** | 0.21 / **1** |
| hills (hil=1.25e-4) | hills (6.25e-5) | 3.60 / **3** | 6.40 / **6** |
| mountains (plt=5.5e-5) | plateau fam. (1.83e-5) | 1.06 / **1** | 1.88 / **1** |
| mountains (mnt=1.2e-4) | mountains | 6.91 / **6** | 12.29 / **12** |
| mountains (hil=5e-5) | hills (2.5e-5) | 1.44 / **1** | 2.56 / **2** |

\* `pln_huge=(plain/2)·probhuge`, `plain=5e-5` (`dogenerate.inc:1727-1731`); `probhuge` UNVERIFIED, shown with `probhuge=1/6`-style placeholder — do not use. **Derived, UNVERIFIED where starred.**

Consequences (derived): (a) the `≥1` clamp makes plateau counts tier- and size-insensitive (always 1/recipe at 64²–320²) — a 240² plains map attempts 3 plateau-family stamps where donor-ref expects ~0.6 total; (b) only 1/5 of `plateau` attempts is `plt2`, and only `plt2` has a donor grid — so most seeds stamp **zero** donor-grid cells (E25 default seed confirms); (c) port ignores the donor `640/((W+H)/2)` size modifier (E6) — at 240² the donor scales probabilities up ×2.67 while the port's `int()` truncates them down to the clamp; (d) `mountains` family at hills-tier expects 0.12–0.21 but port forces 1 analytic bump — wrong-tier mountains are over-represented while carrying zero donor shape (E24: mountain grids are all-zero).

## 3. Q2 — game.gd answers

(a) **±2.964 cap is port-only, not donor-grounded** (E12 + `RELIEF_LIVE_FIX_01.md:117-123`: donor `generatemap.inc` has no height clamp; baked `.map`s merely lie inside; `cMaxHeight=2.96` is a tile-class constant). Donor `.pattern` grids carry up to `+4.74` (plt3 raw; ×0.8 → 3.79 effective) and down to `-3.07` (k_ravine_4); donor `.map` baked relief lattice is `{0, -1.1, ±2.964}` (`RCODE_DEEP_01.md:317-328`). `plt2` max `+3.6134` is therefore truncated 0.65 m by the port cap while its sub-cap shape is already coarse-blocky — double flattening. Fix direction (P0-2): clamp donor-grid cells to verbatim `HeightFieldMin/Max` only (already done at stamp time, E10) and decide the global cap by donor `.map` maxima, not by an asserted clamp.
(b) **test\* on flat cells is donor-faithful, not a port bug.** Detail bitmaps write `R div 2` onto block-0 cells gated only by `h<0.1` (E15, donor `loadtextureterrainfrombitmap.inc`); smoothing rule lists author `test8/test7/test9` at Prob 1.0 (E16). The pale-*cyan* marks were sky bleed through framebuffer alpha, refuted as tile art and fixed 84% (E26; 6,989 near-white px remain, only 55 below sky strip). Residual "maze" = donor transition art + RGB-folded mask steps — expected while the exact donor patch rule stays CONFIRMED_UNVERIFIED.
(c) **Only `plt2` (+BLOCKED `k_ravine_1`) has a decoded grid in-port** (E10,E20,E24). All other relief ids (plt1/3/4_fixed/5, hills_dark/light, mountains, ravines) stamp donor footprints with **invented analytic profiles** (`game.gd:985-1099`). Full float32 grids live on disk at `C:\Games\Cossacks 3\data\pattern\*.pattern` with byte offsets/scales in `DPATTERN_01 §3` — exportable as derived numeric tables per `DPATTERN_01 §8` (numbers only, no binary copy).

## 4. Q3–Q6 — mapgen / consumer / config / seed variety

- **mapgen gaps vs donor:** R-code decode is now exact (E18, fix landed — do not redo). Remaining: no `640/((W+H)/2)` size modifier (E6 vs `mapgen.gd` — no such term, observed); `relief_smooth` flag computed but never consumed (E19 — no smoothing applied to flagged cells, no pattern-suppression on them per `generatemap.inc:587-592,818`); mask-pick stream `(seed^hash)+104729` is deterministic but not the donor's seed-direct pick (minor; donor: seed picks mask, `HEIGHT_GEN_DEEP_01 §3.2`).
- **world3d_terrain consumer (E20–E21):** stamps only the coarse 8×10 tables over a 10×8-cell footprint — not the full `w×h` grids, not donor-scaled extents. Full-grid stamping requires: per-pattern numeric tables (`w,h,scale,min/max` + float array), footprint = scaled donor `w×h` (cf. `game.gd` bbox mapping `:1044-1048`, itself a PORT APPROX), bilinear sample over the full grid, row-flip decision (UNVERIFIED). Height→mesh scale is internally consistent (`HEIGHT_SCALE=1.0`, `TILE_M=2.0` port constant); normals/face promotion smooth the field (V3D_02 P8) — mesh density is a modelling gap, not a scale bug.
- **config (E22,E28):** wired = `relief_stamps` only (producer gate). Dead knobs = `texgen_mode`, `m_per_tile` (Data.TILE_M used), `lighting`, `alpha_patch_mode` (shader uses own uniform), `tile_diversity` (behaviour unconditional). Either wire or delete; dead flags invite false A/B conclusions.
- **seed variety:** relief draws sit deepest in one shared stream (E3) behind up-to-256-attempt mine-replay loops, so seeds vary—but chaotically, not tier-controlled. P-31 is half-landed: stage reseeds exist in `game.gd` (E9) but `pattern_gen.build` never receives a stage key. Donor reseeds with the same key before every stage (E8); the port adaptation (per-stage derived keys, legacy stream untouched) is the sanctioned pattern — just not extended to pattern placement yet.

## 5. Ranked fix list (disjoint owners; each: change, donor cite, effect, cheap verify)

**P0-1 — Faithful relief attempt counts + size modifier (owner: `variant3d/scripts/pattern_gen.gd` ONLY)**
Change: replace `needed=int(W·H·freq/div)≥1` with stochastic rounding of `E=W·H·(freq/div)·(640/((W+H)/2))` (donor `dogenerate.inc:1718-1725,1737-1739`), documented `problarge≡1` placeholder (UNVERIFIED); when `E<1`, place 1 stamp with probability `E`, else 0. Keep `Freq` weights verbatim (E7). Do NOT touch grids/clamps/consumer.
Effect (derived): 240² plains plateau attempts 3 forced → ~0.6 expected; `plt2`-capable stamps become rare-but-real instead of always-1-never-`plt2`; hills-tier mountains 1→~0.1 (kills wrong-tier analytic bumps).
Verify: `--dump-map` × N seeds at 240²: `meta.stamp_counts` distribution + `relief_stamps` hit rate; assert `plateau` family name histogram ≈ uniform over 5 ids (χ² eyeball, no runner ladder).

**P0-2 — Full-grid donor stamping + cap reconciliation (owner: `variant3d/scripts/game.gd` ONLY)**
Change: add derived numeric tables for plt1/3/4_fixed/5 + hil1-4 + g_hil1/2/4/9 (offsets/scales/min-max from `DPATTERN_01 §3` table; scale applied per-sample, e.g. hil1 ×0.65, plt3 ×0.8); stamp over scaled donor `w×h` footprint; keep analytic profile ONLY for mountains (grids all-zero, E24) pending props; clamp donor cells to pattern `Min/Max` alone, move the `±2.964` global bound to non-donor cells (extends E12 pattern).
Effect: `plt2` range `-0.07→+2.96` becomes `-0.07→+3.61`; stamped cells gain true crest/rim shape vs 80-cell block means; `applied_cells` 443 → full-footprint coverage (~700–900 at 64²).
Verify: same-seed dump diff: `applied_cells`, height SHA-256, `height_max` ≈ pattern max; assert no `SCRIPT ERROR`, tileblock delta confined to footprint bbox.

**P0-3 — Consumer full-grid path + footprint parity (owner: `variant3d/scripts/world3d_terrain.gd` + shader ONLY)**
Change: mirror P0-2 tables in consumer; `footprint_w/h` default = scaled donor `w×h` instead of 10×8; sample full grid (bilinear); keep row-flip flag labelled. No placement/markup logic changes.
Effect: dump-path stamps stop rendering as 10×8 flat caps (TERRAIN_MARKS rank-3 mechanism retired); height_min/max in `stats` reflect true grid.
Verify: `--dump-map` (seed 20261150) → terrain-module `stats.relief_grid.applied>0` + height-range shift vs flag-off; windowed capture frame-wide luma variance delta (not pixel A/B).

**P1-1 — Stage-keyed RNG for pattern placement (owner: `variant3d/scripts/pattern_gen.gd` — same builder as P0-1, sequenced after)**
Change: accept a stage-seed argument (from `game.gd:_reseed_stage("patterns")`, E9) for the relief sub-stream; keep tile/mine/forest draws on the legacy stream (byte-identical). Donor cite E8 + `DB_SCRIPTS.md:71`.
Effect: changing `random_seed` re-rolls relief independently; tier actually controls relief mix instead of stream position.
Verify: two seeds differing only in relief tier → identical `terrain/height` base, different `pattern_stamps`; same seed → byte-identical dumps.

**P1-2 — Retire the start-flatten excess (owner: `variant3d/scripts/game.gd` — same builder as P0-2, sequenced after)**
Change: shrink `protect` (E11: currently `15·1.5·1.5≈33.8` tiles at 240²) to `CIRCLE1`-based radius, and skip-flatten (not skip-stamp) so relief shapes survive outside the buildable core. Donor cite: keep-clear contract `dogenerate.inc:407-414` (radii 5–22, not 34).
Effect: relief stops being erased across ~30% of a 240² map near starts; mid-map hills survive.
Verify: dump `applied_cells` up at fixed seed; start-reachability probe unchanged (no enclosed starts).

**P1-3 — Wire or remove dead feature flags (owner: `variant3d/scripts/config.gd` + `variant3d/config.json` ONLY)**
Change: either consume `texgen_mode/m_per_tile/lighting/alpha_patch_mode/tile_diversity` at their call sites or delete the keys + accessors (E28). `relief_stamps` stays (E22).
Effect: no behavioural change today; kills an entire class of false "I toggled X and nothing happened" reports.
Verify: grep zero defs-without-consumers; `--dump-config` round-trips.

**P2-1 — Mountain props instead of bumps (owner: new asset-pipeline ticket; files: tools + `world3d_entities`/docs — research first, BLOCKED on art import)**
Donor truth: mountain relief is 1–5 `terrainmeshN` prop instances per stamp (E24; `pattern.lib` `Objects`, `actors.lib:1200-1213`, bboxes to z≈9.55). No grid bump may reproduce this. Park until prop import exists; explicitly forbid raising analytic `mnt` amplitude as a substitute.

**P2-2 — `bsmooth` consumption + pattern suppression (owner: `variant3d/scripts/mapgen.gd` + `variant3d/scripts/game.gd` ledger — needs both builders, so split: mapgen exposes flag application, game reads it; coordinate, no overlapping edits)**
Donor cite `generatemap.inc:587-592,818`. Label kernel PORT APPROXIMATION.

## 6. Proposed ownership split (no overlap)

| Builder | Files | Tickets |
|---|---|---|
| A | `variant3d/scripts/pattern_gen.gd` | P0-1, then P1-1 |
| B | `variant3d/scripts/game.gd` | P0-2, then P1-2 |
| C | `variant3d/scripts/world3d_terrain.gd` + `variant3d/shaders/terrain_tileindex.gdshader` | P0-3 |
| D | `variant3d/scripts/config.gd` + `variant3d/config.json` | P1-3 |
| parked | tools/docs/prop pipeline | P2-1, P2-2 (coordination required) |

## 7. Open questions / UNVERIFIED (do not invent)

1. Native count semantics of `_misc_SetupPatternsByType` from probability (E6 engine-side) — `E[count]=W·H·p` is a scale reference, not donor truth.
2. `problarge/areamod` engine values; whether the `{plt/0.85}` areamod block (`dogenerate.inc:1695-1708`) is live or commented (brace semantics UNVERIFIED).
3. Engine sculpt blend order (`Replace/Smooth/clamp/scale`, `HeightFieldScale=-0.925` sign) — additive-clamp stays labelled PORT APPROXIMATION.
4. File-row→map-row flip; stamp extent/placement vs `st.cells` bbox; `TerrainScale` (always 1, E24 — safe).
5. Runtime selection among multiple `terrainmeshN` in one stamp's `Objects` list (native).
6. Exact donor `gl_EyePlane`/texture-matrix values (V3D_02 open Q1) — shader texgen stays APPROX.
7. Whether shipped 240² masks carry any R≠0 relief codes at all (masks mirror start-marker `*gauss.tga`; if all R=0, base relief comes only from stamps — strengthens P0-1 priority).
8. Residual 55 below-sky near-white px + ~6,989 total (E26) — tile art vs partial blend, needs per-region isolation, not another global knob.

*End of MAPGEN_RECON-01. Read-only; one deliverable; no donor parity claimed.*
