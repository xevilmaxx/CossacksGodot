---
id: P05
ticket: "TERRAIN-SWARM-2026-11-26 / Wave P / P05 — 2D `app/` donor-derived terrain pieces reusable (read-only) in the fresh variant3d module"
agent: "P05 (port baseline audit subagent)"
owner_file: docs/terrain_swarm_2026-11-26/reports/P05_2d_reuse.md
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_APP_EDIT__NO_SOURCE_EDIT__NO_ASSET_EDIT__NO_GIT_WRITE__NO_RUNNER__NO_DONOR_ACCESS
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
scope: "Exactly one repo file written (this report). `app/**` was read only and stays byte-untouched. No .gd/.gdshader/.json/.cfg/.import/asset/test edit, no Godot process, no godot_runner.py job, no donor file opened, no git write."
prior_art_note: "Task named `V2D_02_2d_terrain_logic.md`; no such file exists under docs/terrain_swarm_2026-11-25/reports/. Substituted the three nearest prior reports actually present: H07_2d_reuse.md, G22_2d_vs_3d.md, H06_pass_order.md, plus G22's cited G22 §5.1-5.4."
parity_claim: false
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists, no donor binary was opened this pass. 'More donor-faithful' below means (a) literal agreement with a cited donor path:line in prior read-only reports, or (b) absence of a change that its own author labels PORT APPROXIMATION. Runtime behaviour and visual equivalence stay UNVERIFIED. Everything implemented from this report remains PORT APPROXIMATION until a real A/B frame lands (CHARTER.md:41,44,125)."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md; docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/guides/GUIDE4.md (L1/L2, asset census)
  - docs/research/RC_TERRAIN.md (§3-§4, stale season claim noted)
  - docs/terrain_swarm_2026-11-25/reports/H07_2d_reuse.md; G22_2d_vs_3d.md; H06_pass_order.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md; RV_TRN_02_smoothing_rules.md
  - docs/audit/PIECES/shore_sand.md; docs/audit/PIECES/winter_variant.md
  - docs/terrain_swarm_2026-11-26/reports/P01_pipeline_audit.md; A03_asset_pipeline.md
  - app/scripts/mapgen.gd, pattern_gen.gd, world.gd, game.gd
  - variant3d/scripts/mapgen.gd, pattern_gen.gd, world.gd, game.gd, world3d_terrain.gd
  - git diff --no-index of each of the four file pairs (current committed tree)
  - Python os.stat(st_dev, st_ino) hardlink census over app/assets/terrain vs variant3d/assets/terrain
---

# P05 — 2D `app/` donor-derived terrain logic reusable in variant3d (read-only)

## 0. Label key, evidence discipline, version

**[O]** observed (literal current line / on-disk fact). **[D]** derived (deterministic
consequence of [O]). **[I]** inference without a pixel-aligned donor A/B. **[U]** UNVERIFIED.
**PORT APPROXIMATION** = an explicit port substitute for an unrecovered donor rule.

- **[O] Version:** all `file:line` numbers below are the current working tree, cross-checked
  against `git diff --no-index` output generated this pass. P01 (`:29-34`) confirms HEAD
  `e234ac9b` and that the pipeline files were clean; where a 2026-11-25 report cites older
  numbers, this report's numbers govern.
- **[O] Read-only:** no donor path was opened by P05; every donor `path:line` is quoted
  second-hand from prior read-only reports (H06, DTRN_01, RV_TRN_02, shore_sand,
  winter_variant). All donor-script lines are `;`-commented in those reports, so authored
  intent is **[O] as text** and runtime activity is **[U]** (`H06_pass_order.md:64-68`).
- **[O] No asset copy was needed or made.** All terrain art under `app/assets/terrain/**`
  already exists in `variant3d/assets/terrain/**` as hardlinks (§3.9).

---

## 1. Executive summary

1. **[O]/[D] The transplant is logic-only, not assets.** A hardlink census found **685
   identical inode pairs** under `app/assets/terrain/` ↔ `variant3d/assets/terrain/`
   (672 PNG, 6 DDS, 7 JSON; §3.9). There is **no 2D-only terrain asset**: masks, season
   textures, detail bitmaps, donor block atlas art, dmask shapes, decor and water PNGs are
   all already reachable from `variant3d` at the same `res://` path. No donor byte is copied.
2. **[O]/[D] `mapgen.gd` and `pattern_gen.gd` are the wrong direction for 2D→3D reuse.**
   variant3d is *ahead* on mask relief decode (exact 8-code + `bsmooth` flag,
   `variant3d/scripts/mapgen.gd:75-94` vs `app/scripts/mapgen.gd:63-73`) and on relief stamp
   counts (tier presets 0-4, size modifier, floor/round rule,
   `variant3d/scripts/pattern_gen.gd:17-53,559-583` vs `app/scripts/pattern_gen.gd:15-36,543-548`).
   No app→3D transplant recommended there.
3. **[O]/[D] `game.gd` is where `app/` is closer to donor evidence.** 2D preserves verbatim
   donor detail-bitmap ids (`app/scripts/game.gd:1581-1605`), verbatim smooth-rule names and
   weights (`app/scripts/game.gd:1787-1867`, `1409-1421`), donor pass order smooth→detail
   (`app/scripts/game.gd:1681-1689`), and `ground1`/`grass1` worked-ground aprons
   (`app/scripts/game.gd:324-346,1673-1678,1693-1698`). Every corresponding 3D site carries
   an explicit **PORT APPROXIMATION** label and a substituted meadow id (`test8`) or an
   art redirect (§3.2-3.5).
4. **[O]/[D] Pass order is the highest-confidence donor-grounded difference.** H06 resolved
   the earlier UNVERIFIED using authored donor call sites: `TextureMap` → `SmoothTiles`
   (`generatemap.inc:786`) → `LoadTextureTerrainFromBitmap` (`generatemap.inc:795`). The 2D
   order matches; the 3D order is flipped (`H06_pass_order.md:36-39,141-147`).
5. **[O] `world.gd` has no terrain divergence.** The entire diff between
   `app/scripts/world.gd` and `variant3d/scripts/world.gd` is the FOLD-07 sprite-path
   resolver (110 diff lines); shore/cliff, block compositing, season swap and water overlay
   are identical. Nothing to transplant from `world.gd`.
6. **[O]/[U] Two 2D rules are conditional, not automatic transplants:** painting `terrain=5`
   on hill stamps and on steep cells (`app/scripts/game.gd:786-792,1098-1122`) is the literal
   donor cliff rule, but 3D removed it (`variant3d/scripts/game.gd:854-860,1297-1310`) because
   port-computed terraces produced the concentric "maze". Use only in the **fresh donor
   module with real donor height grids**, never as a patch to the legacy tree.
7. **[O] Anti-candidates:** the 2D height-cap dither (`app/scripts/game.gd:1090-1097`) is a
   synthetic `_noise2` field, forbidden by `CHARTER.md:60` / S-25-09; the 2D forest-floor
   roulette (`app/scripts/game.gd:1649-1655`) uses donor weights but a contested family
   mapping. Neither is recommended (§3.10).
8. **[U] No parity claim.** Donor parity stays UNVERIFIED for both trees; "closer to donor"
   is a citation-level statement only, and every transplanted behaviour is
   **PORT APPROXIMATION** until an A/B GPU frame exists.

---

## 2. Evidence table

| ID | Source (file:line) | Observation | Label |
|---|---|---|---|
| E01 | `app/scripts/mapgen.gd:1-8,25-30,124-211`; `variant3d/scripts/mapgen.gd:145-238` | Same mask pipeline: RGB channels, white start skip (`:173-175`), `h = -1.1*b*(1+r*3.5)+relief(r)` (`:186-187`), 1/2/3 coastal passes + `_near_water` (`:191-208`). | [O] |
| E02 | `app/scripts/mapgen.gd:63-73` vs `variant3d/scripts/mapgen.gd:75-94` + `:9-20` comment | 2D decodes bands (`v>=250`, `96±12`, `48±12`); 3D uses exact codes `255/191, 96/112, 48/88` with `class × fr`, cites `generatemap.inc:342-370,569-573`, and adds `relief_smooth` for donor code 64/88/112/191. 3D is closer. | [O]/[D] |
| E03 | `app/scripts/pattern_gen.gd:15-36,543-548` vs `variant3d/scripts/pattern_gen.gd:17-53,559-583` | 2D has 3 string presets and a hard `needed<1→1` clamp; 3D adds tier ids 0-4, `problarge/probhuge` placeholders, size modifier `640/((W+H)/2)`, and donor floor/round rule (`misc.script:3695-3700`). 3D is closer; its multipliers remain **PORT APPROXIMATION** (`:16-21,38-42`). | [O]/[D] |
| E04 | `app/scripts/pattern_gen.gd:60-70,88-130` (identical in 3D) | Deterministic stamp RNG, centred donor-cell scaling, occupancy `can_stand`/`stand` — the donor footprint test (`_misc_CheckStandPattern`, `misc.script:3384`). | [O] |
| E05 | `app/scripts/pattern_gen.gd:206-251,279-405,407-472,474-549,551-720` (identical in 3D except E03 region) | Donor `SetupTiles`, `SetupMines` (`D1:522-717`), `SetupStartingResources`, rest families, relief stage, final mine-layout authority; `CIRCLE1/2/3 = (5,7)/(12,15)/(22,18)`, `MINE_RINGS = (14,22)/(32,42)/(50,62)` (`:10-13`). | [O] |
| E06 | `app/scripts/game.gd:673-847` (identical in 3D except E10) | Stamp realisation: forest core fill + wood nodes, stone quarry scar + stones, mine deposit nudge + `ground1` apron, decor bushes, `_claim_cluster`. | [O] |
| E07 | `app/scripts/game.gd:858-982` vs `variant3d/scripts/game.gd:924-1138` | 2D height profile is analytic radial/taper (`app:861-863` comment "per-cell height fields are undecoded"); 3D carries donor-derived 8×10 block means `plt2`/`k_ravine_1` with `pattern.lib` Min/Max/Scale, labelled **PORT APPROXIMATION**. 3D is closer. | [O]/[D] |
| E08 | `app/scripts/game.gd:983-1144` (shared, 3D `:1060-1310`) | Donor stage order in comment (`:984-993`); water `< -0.25`, shore `< -0.1` (`:1055-1064`); height clamp (`:1087-1097`); collision (`:1098-1122`); start water snap (`:1123-1139`); roads (`:1140-1143`). | [O] |
| E09 | `app/scripts/game.gd:1098-1122` vs `variant3d/scripts/game.gd:1297-1310` | 2D writes `terrain[i]=5` **and** `set_blocked_tile` on |dh|>0.5/0.55; 3D writes collision only and documents the removed rock painting as the maze fix. | [O] |
| E10 | `app/scripts/game.gd:786-792` vs `variant3d/scripts/game.gd:854-860` | 2D hill stamp paints `terrain=5` for `dc<=2.2`; 3D branch is `pass` ("height-only relief"). | [O] |
| E11 | `app/scripts/game.gd:1610-1706` (`_assign_tileblocks`), `:1681-1682` smooth, `:1689` detail; `variant3d/scripts/game.gd:2097` detail, `:2134` smooth | 2D order = base → shore → **smooth(3)** → **detail** → borders → mine authority. 3D order = base → shore → detail → B03 tile stamps → L01 spots → smooth → borders → Y08 collapse. | [O] |
| E12 | `H06_pass_order.md:36-39,49-60,141-147`; donor `generatemap.inc:776,786,795`, `smoothtiles.inc:237`, `loadtextureterrainfrombitmap.inc:25-41` | Authored donor call order is smooth then detail; 2D matches, 3D is flipped. Runtime activity of these commented scripts is [U] (`H06:64-68`). | [O] as text / [U] runtime |
| E13 | `app/scripts/game.gd:1581-1605` vs `variant3d/scripts/game.gd:1959-2012` (esp. `:1982-2008`) | 2D writes `tex = int(pixel.r*255)/2` verbatim; 3D re-rolls `test7/test8` via donor lists (B03-P1) then collapses every output to `test8` (Y03). Both substitutions self-labelled **PORT APPROXIMATION**. | [O]/[D] |
| E14 | `app/scripts/game.gd:1787-1804` vs `variant3d/scripts/game.gd:2251-2283` | 2D `_tb_pick` returns the authored `name`; 3D redirects `grass_ground1/2/3 → grass9/test8/test7` (B03-P3, self-labelled **PORT APPROXIMATION** at `:2268-2271`). | [O] |
| E15 | `app/scripts/game.gd:1806-1867` vs `variant3d/scripts/game.gd:2285-2346` | 2D smoother applies donor group/weight rules unconditionally; 3D adds four `!= test8 && != grass9` guards (`:2333,2337,2341,2345`), a port-level art-protection rule. | [O] |
| E16 | `app/scripts/game.gd:1409-1421` (reads `smooth_summer.json`) vs `variant3d/scripts/game.gd:1596-1767,1780-1820` (embeds 118 rules) | Both donor-derived (`tilesmooth_scripts.cfg`, RV-TRN-02 §7). 3D's table is more complete (all 118 active lists, Summer + Winter); 2D's `smooth_summer.json` is the smaller 10-chain source. | [O]/[D] |
| E17 | `app/scripts/game.gd:1649-1655` vs `variant3d/scripts/game.gd:1770,2059-2065` | 2D forest-floor roulette `grass_ground1/2/3 = 0.64/0.0028/0.36` (donor Item 4/5/6 J=3, `RV_TRN_02:213,222,230`); 3D `DONOR_FOREST_BASE = grass7/test12/test13/test14 × 0.25` (Item 1 J=5, `cfg:171`). Both are donor-authored lists; which one maps to forest interior is [U]. | [O] + [U] |
| E18 | `app/scripts/game.gd:324-346,1673-1678,1693-1698` vs `variant3d/scripts/game.gd:382,388,398,2144-2161` | 2D mine apron and start plaza use `ground1`/`grass1` (donor worked ground / default tile); 3D uses `test8` and a final whole-disc meadow collapse (Y08/Y08b, self-labelled **PORT APPROXIMATION**). | [O]/[D] |
| E19 | `app/scripts/game.gd:1708-1785` (identical in 3D — diff empty); donor `texturemap.inc:433-511,557-611` via `DTRN_01:126-127`, `shore_sand.md:55-72` | 8-sector uniform 45° shore orientation with `dirY<0` fold, `sandsea1/5/6`, and cliff aspect + `abs(h)>2.7→rock8`, `>2.4→rock4`. Donor-derived in both trees. | [O] |
| E20 | `app/scripts/game.gd:1067-1075` (identical in 3D) and `:1055-1064` | Water cells stay `terrain=3` + `BLK_WATER`; only land `-0.25..-0.1` is sand collar. Matches donor gate `shore_sand.md:59-61` (sandsea on masked water/wet cells). | [O] |
| E21 | `app/scripts/game.gd:1424-1476`, `app/scripts/world.gd:1134-1172`; `variant3d/scripts/game.gd` same table, `variant3d/scripts/world.gd:1174-1212` | Winter alias map (124 names) and per-cell winter art swap exist in **both** trees; donor evidence `winter_variant.md:41-80`, `tiles.presets` Summer/Winter 124 entries. `RC_TERRAIN.md:117-118` ("no season texture swap in world.gd") is **stale**. | [O]; prior doc stale |
| E22 | Python `os.stat` census over `app/assets/terrain/**` ↔ `variant3d/assets/terrain/**` (this pass) | 685 hardlinked pairs: 672 PNG + 6 DDS + 7 JSON; 56 mask PNGs across 7 shape dirs + `masks/manifest.json`; 112 block PNGs incl. `winter0..26` (27) and `desert1..12` (12); `structs/{tile_lowground,tile_highground}.png` + 4 JSON; `patterns/donor_patterns.json`; `dmask/d_00..47.png` (24); `deco_png/` (7); `decals_png/` (462); `water_png/` (8); `heightmap/splat_albedo.png` + manifest. `.import`/`.uid` files are per-project and NOT hardlinked. | [O] |
| E23 | `app/scripts/game.gd:1090-1097` | Height-cap dither `hq = _noise2(x*0.31+3, y*0.31-7)` chooses `+2.964` vs `+2.934`; a synthetic field, explicitly forbidden by `CHARTER.md:60` / S-25-09. | [O] |
| E24 | `G22_2d_vs_3d.md:113,121`; `H07_2d_reuse.md:52` | Donor block/decal/dmask art already byte-identical in both trees; G22 explicitly rejects any asset copy. | [O] from prior |
| E25 | `P01_pipeline_audit.md:66-70` | Live 3D final `tileblock` authority is the Y08 `test8` flatten plus the Y03 detail collapse; these divergences are live, not dead code. | [O] from prior |
| E26 | `app/scripts/world.gd` ↔ `variant3d/scripts/world.gd` full `git diff --no-index` (110 lines, all FOLD-07) | Only additions are `AssetPaths`, `_mapped_sprite_path`, `_sprite_res_path`, `_sprite_flat_fallbacks`; no terrain function changed. | [O] |

---

## 3. Findings (by subsystem)

### 3.1 Mask decode — 3D ahead, no transplant [O]/[D]

`app/scripts/mapgen.gd:63-73` classifies mask red by tolerance bands and returns
`C_PLATEAU*(v/255)*0.5` for any other positive value; `variant3d/scripts/mapgen.gd:75-94`
matches only exact codes and exposes `relief_smooth`. The variant3d comment
(`:9-20`) cites `generatemap.inc:342-370,569-573` and notes that the disabled
`//*(255/cRColorHill)` suffixes make the live amplitudes `+0.495937 / -0.557929`, not the
legacy `+1.31733 / -2.964`. **[D]** The 2D band decoder is a coarser PORT APPROXIMATION;
the fresh module should take the 3D decoder. **Recommendation: none for app→3D.**

The shared remainder (`app/scripts/mapgen.gd:124-211` = `variant3d/scripts/mapgen.gd:145-238`)
is donor-derived and needs no transplant: white start markers skipped, `cWaterHeight=-1.1`,
`WATER_DEEP=-0.25`, `WATER_SHORE=-0.1`, and 3 coastal smoothing passes over `_near_water`
(E01). `variant3d` additionally carries the `bsmooth` flag as data without inventing a kernel
(`:43-50,211`) — **[I]** correct conservative choice for the fresh module.

### 3.2 Pattern stamping and prop placement — mostly shared, 3D ahead on counts [O]/[D]

`app/scripts/pattern_gen.gd:60-847` and its variant3d counterpart are byte-identical outside
the relief-count block. Donor-derived constants and passes already available to the fresh
module: `DONOR_UNITS=160`, `CIRCLE1/2/3`, `MINE_RINGS` (`:9-13`), footprint `can_stand`/`stand`
(`:88-130`), `SetupTiles` grid (`:206-251`), `SetupMines` with a separate `mine_rng`
(`:279-405`), `SetupStartingResources` (`:407-416`), rest families `stones/stoneforests/
hills_dark/hills_light/decor/dcr1` (`:463-472`), relief stamps (`:474-549`) and the final
footprint-safe mine layout (`:551-720`). `game.gd:_gen_patterns` realises those stamps into
wood/stone/mine/decor nodes (`app/scripts/game.gd:673-847`). **[D]** No app→3D transplant;
reuse the shared algorithm and the hardlinked `donor_patterns.json` (E22).

The relief-count divergence (E03) favours 3D: tier ids 0-4, `size_mod`, and the donor
`floor(W*H*freq)` rule with `round()` fallback; the 2D `needed<1→1` clamp over-places at
small grids. **[D]** Take the 3D rule; keep its `RELIEF_PROBLARGE/RELIEF_PROBHUGE = 1.0`
placeholders labelled **PORT APPROXIMATION** (`variant3d/scripts/pattern_gen.gd:16-21`).

### 3.3 Tile selection order — 2D matches donor call sites [O]/[D]

`app/scripts/game.gd:1681-1689` runs `_smooth_tilemap(brng,3)` at `:1682` **before**
`_apply_detail_pass()` at `:1689`; `variant3d/scripts/game.gd:2097` runs the detail pass
**before** `_smooth_tilemap(brng,3)` at `:2134`. H06 (`H06_pass_order.md:36-39,49-60`)
resolves donor authored order as `TextureMap` → `SmoothTiles`/3-pass `SmoothTileMap`
(`generatemap.inc:786`) → `LoadTextureTerrainFromBitmap` (`generatemap.inc:795`), and
concludes (`:141-147`) that 2D matches and 3D is flipped. **[D]** This is the strongest
2D→fresh-module transplant candidate (T1). **[U]** Donor script lines are commented, so
this is authored-intent fidelity, not proven runtime behaviour or a visual verdict.

### 3.4 Detail-bitmap and smoothing rules — 2D verbatim, 3D substituted [O]/[D]

- **Detail pass:** 2D `app/scripts/game.gd:1581-1605` is the donor algorithm
  (`loadtextureterrainfrombitmap.inc:4,8-9,25-29,33-41` per `H06:60`): only cells still on
  default id change, `h<0.1` picks low/high bitmap, `tex = R div 2`, written verbatim.
  3D `variant3d/scripts/game.gd:1982-2008` adds the B03-P1 `test7/test8` re-roll and the
  Y03 `tex = _blk("test8")` collapse. Both are self-labelled **PORT APPROXIMATION**
  (`:1982-1983,2003-2007`). **[D]** 2D is closer to donor (T2).
- **Pick:** 2D `app/scripts/game.gd:1787-1804` returns the authored tile `name`; 3D
  `variant3d/scripts/game.gd:2276-2281` redirects `grass_ground1/2/3` to `grass9/test8/test7`
  (B03-P3, **PORT APPROXIMATION** at `:2268-2271`). **[D]** 2D is closer (T3).
- **Pair smoothing:** 2D `app/scripts/game.gd:1806-1867` applies the donor compatibility
  rule (`absi(g1-g2)==1` rejected only if both are `prob<=0`; `==2` picks the middle group).
  3D `variant3d/scripts/game.gd:2333-2345` adds four art-protection guards against
  `test8`/`grass9`. **[D]** 2D is closer (T3).
- **Rule table:** 2D reads `app/assets/terrain/structs/smooth_summer.json` (10 chains,
  `app/scripts/game.gd:1409-1421`); 3D embeds all 118 active lists in
  `variant3d/scripts/game.gd:1604-1767` (`DONOR_SMOOTH_RULES`) and normalises `_winter`
  aliases at `:1800-1820`. **[D]** 3D is more complete; take the 3D table, not the 2D JSON,
  but keep the 2D verbatim *use* of names/weights.

### 3.5 Worked ground and start plaza — 2D uses donor ids [O]/[D]

`app/scripts/game.gd:324-346` paints mine apron `ground1` and start clearing `grass1`;
`:1673-1678,1693-1698` does the same before and after tile passes. `variant3d/scripts/game.gd:382,388,398,2144-2161`
uses `test8` for all of these and a final authority loop that flattens every ordinary land
cell (role 0/2) to `test8`, explicitly **PORT APPROXIMATION** (`:2144-2148`). P01
(`:66-70`) confirms this is the live behaviour. **[D]** 2D is closer to donor
`ground1`/`grass1` semantics (`GUIDE4:163,167`, `DTRN_01:118-119`) (T4).

### 3.6 Hill and steep-cell rock paint — donor rule vs maze history [O]/[U]

2D `app/scripts/game.gd:786-792` paints `terrain=5` for hill stamps and `:1098-1122` paints
`terrain=5` + blocks on steep cells (donor `cDiff1/cDiff2`, `texturemap.inc`). 3D
`variant3d/scripts/game.gd:854-860` and `:1297-1310` removed both paints, documenting that
the |dh| test fires on port 8-bit terraces and produces concentric grey rings. **[D]**
Literal donor rule favours 2D; **[I]** on port-derived height data it caused the reported
maze. **PORT APPROXIMATION / [U]:** transplant only into the fresh donor-shaped module whose
height comes from real donor grids; never re-enable it in the legacy tree (T7).

### 3.7 Water, shore and cliff — already identical and donor-derived [O]

`app/scripts/game.gd:1708-1737` (8-sector shore) and `:1739-1772` (cliff aspect + height
overrides) are byte-identical in 3D; the diff has no hunk there. Donor evidence:
`DTRN_01:126-127` (C12/C13), `shore_sand.md:55-72` (`texturemap.inc:474-511`, `cAngle=45`,
uniform 45° sectors including the `dirY<0` fold and 8-sector table). Water cells staying
`terrain=3` + `BLK_WATER` (`:1067-1075`) also matches the donor wet-cell gate
(`shore_sand.md:59-61`). **[D]** No transplant needed: the fresh module should *reuse this
algorithm verbatim*, and the donor water fragment is already transcribed in
`variant3d/shaders/water3d.gdshader` (`DTRN_01:135-137,391`). **[U]** No visual parity.

### 3.8 Seasons — shared alias map; prior claim stale [O]

`app/scripts/game.gd:1424-1476` defines the 124-name Summer→Winter alias and
`game.winter_tile_names`; `app/scripts/world.gd:1134-1172` consumes it with `_winter_art`
and a reduced winter tint (`strength=0.10` vs summer `0.34`, `:1127`), building the wash
from `_winter_art("sandsea6")` (`:1063,1326`) and face art `_winter_art("rock8"/"rock1")`
(`:1477,1488`). The same code exists in `variant3d/scripts/game.gd` and
`variant3d/scripts/world.gd:1174-1212`. Donor evidence: `winter_variant.md:41-80`
(`terrain.presets` 124 Winter aliases; `tiles.mat` resolves them to winter*.dds).
**[O]** `RC_TERRAIN.md:117-118` ("no season texture swap in world.gd") is stale.
**[U]** Whether `variant3d/scripts/world.gd` executes for the 3D terrain frame is
unproven (`G22_2d_vs_3d.md:126`); the 3D path uses `world3d_terrain.gd` + the tile-index
shader. No transplant needed; fresh module should read the alias data directly.

### 3.9 Asset inventory — no 2D-only terrain asset exists [O]

Hardlink census (E22): **685** inode-identical terrain files. Highlights:
terrain masks `app/assets/terrain/masks/**` → 56 `*_gauss.png` across
`continent, continents, islands, land, mediterranean, nowater2, peninsulas` (8 each) plus
`manifest.json` whose `source` is `C:/Games/Cossacks 3/data/gen/terrainmasks`; season
textures `blocks/winter0.png … winter26.png` (27, all hardlinked) and `desert1..12`;
detail bitmaps `structs/tile_lowground.png`, `tile_highground.png`; rule data
`structs/smooth_summer.json`, `tileblocks.json`, `presets_summer.json`, `water.json`;
pattern data `patterns/donor_patterns.json`; decor/masks `dmask/d_00..47.png`,
`deco_png/{christmastreed,envfieldd,envfielddw,groundexp0..3}.png`, `decals_png/` (462),
`decals/*.dds` (6), `water_png/diffusewaves0..7.png` (8), `heightmap/splat_albedo.png`.
**[D]** A fresh 3D module can reference every one of these at the same `res://` path
without copying or editing `app/`. `.import`/`.uid` files are intentionally per-project and
are not hardlinked.

### 3.10 Anti-candidates — do NOT transplant [O]/[U]

1. **Height dither:** `app/scripts/game.gd:1090-1097` uses `_noise2` to pick
   `+2.964` vs `+2.934` per cell. **[O]** synthetic field; `CHARTER.md:60` / S-25-09 forbids
   inventing noise/dither. Exclude from the fresh module.
2. **Forest-floor family:** `app/scripts/game.gd:1649-1655` uses donor weights
   `0.64/0.0028/0.36` (RV-TRN-02:213,222,230) but on terrain role 2; 3D uses donor Item 1
   J=5 `grass7/test12/13/14` at 0.25 each (`variant3d/scripts/game.gd:1770`). **[U]** both are
   donor-authored lists; the mapping to "forest interior" is unresolved. Do not decide by
   adjacency; register as Q3.
3. **Analytic relief domes:** `app/scripts/game.gd:858-982` is explicitly a port adaptation
   (`:861-863`); 3D's donor grid path supersedes it. Exclude.
4. **Legacy hill/steep painting:** see §3.6 — conditional only.
5. **Asset copies:** E24/G22:137 rejects any new donor copy; all needed art is hardlinked.

---

## 4. Transplant candidates (all into the **fresh** `variant3d` module, none into `app/`)

> Every row is a proposal only. P05 edits no target file. The receiving module is the
> charter's `variant3d/scripts/terrain_donor_*.gd` (`CHARTER.md:57-61`), composed behind a
> switch at the `world3d.gd` seam (`P01_pipeline_audit.md:71-78`). No legacy file is patched.

| # | Candidate (source `app/`) | Target behaviour in fresh module | Donor anchor / evidence | Label | Risk |
|---|---|---|---|---|---|
| T1 | `_assign_tileblocks` call order `app/scripts/game.gd:1681-1689` | base → shore/cliff → 3-pass smooth → detail → forest borders → mine authority | `generatemap.inc:776,786,795` via `H06:36-39,141-147` (E11/E12) | [O] as text, [U] runtime | RNG stream shift; changes `tileblock` bytes; A/B required |
| T2 | Verbatim detail pass `app/scripts/game.gd:1581-1605` | `h<0.1`, `tex=R div 2`, only default-id cells; **no** P1 re-roll, **no** Y03 `test8` collapse | `loadtextureterrainfrombitmap.inc:4,8-9,25-41` via `H06:60` (E13) | [D] closer to donor; PORT APPROX | Flat `grass1` field possible if atlas variety is not selected (G22:114) |
| T3 | Verbatim smooth rules `app/scripts/game.gd:1787-1867` + `structs/smooth_summer.json` use | Authored names/weights, no art redirects, no `test8/grass9` guards; combine with 3D's full 118-rule table (E16) | `tilesmooth_scripts.cfg` via `RV_TRN_02`; DTRN_01 C10 (E14/E15/E16) | [D] closer to donor; PORT APPROX | Donor `SumProb=1.0028` anomaly must be preserved (`RV_TRN_02:334-336`) |
| T4 | Mine apron + start plaza `app/scripts/game.gd:324-346,1673-1678,1693-1698` | `ground1` worked ground under mines; `grass1` start plaza; no whole-disc `test8` flatten | `GUIDE4:163,167`; donor `SetTileIndex(x,y,0)` analogy (`app:1625-1627`) (E18) | [D] closer to donor; PORT APPROX | Mine apron must survive smoothing (use 2D's final authority, not 3D's flatten) |
| T5 | Shore/cliff + water retention `app/scripts/game.gd:1067-1075,1708-1785` | Reuse verbatim: 8-sector `sandsea1/5/6`, cliff aspect + height overrides, water cells stay terrain 3 | `texturemap.inc:433-511,557-611` via `DTRN_01:126-127`, `shore_sand.md:55-72` (E19/E20) | [O] donor-derived | None identified; verify face/shader agreement on real height grid |
| T6 | Winter alias + art swap `app/scripts/game.gd:1424-1476`, `app/scripts/world.gd:1134-1172` | Read alias table directly in fresh module; use hardlinked `winter*.png`; keep winter tint 0.10 | `winter_variant.md:41-80`; `texturemap.inc:525-526,605-606` (E21) | [O] donor-derived; PORT APPROX for port tint | Must keep summer/winter index identity and desert remap invariants (H07:83) |
| T7 | Hill/steep rock paint `app/scripts/game.gd:786-792,1098-1122` | Paint rock **only** from real donor relief stamps / genuine donor height gradients | `texturemap.inc` cDiff1/cDiff2 via `app:1098-1100`; GUIDE4 L1.05 | [U] conditional; PORT APPROX | **High**: legacy version caused concentric maze; requires donor-grid height, A/B, gate check |
| T8 | Mask + stamp cores `app/scripts/mapgen.gd:124-211`, `app/scripts/pattern_gen.gd:60-720` | Reuse shared pipeline and hardlinked JSON/PNG assets; take 3D's exact relief decode and counts instead | E01/E04/E05 + E02/E03 | [O]/[D] | Do not transplant 2D's coarser `relief()` or `needed<1→1` clamp |

**Explicitly not transplanted:** E23 dither, E17 forest-floor choice (Q3), E07 analytic
domes, any asset copy (E24).

---

## 5. Risks

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | Reordering smooth/detail changes which `brng` draws land on which decision; tileblock bytes and later border draws change, though same-seed determinism is preserved by construction. | `H06:149-153` (E11/E12), [D] | Pin seed, camera, zoom, BIOME; A/B only one axis; compare tile histogram + capture. |
| R2 | Removing Y03/Y08 substitutions may expose artificial banding or the old checkerboard instead of donor mottling. | `Y08_checkerboard.md` via `H07:56`; E13/E18, [I]/[U] | Do not assume improvement; A/B decides; revert to backup if no metric movement. |
| R3 | Restoring `terrain=5` on port-derived terraces recreates the concentric maze. | E09/E10, `P01:55-60`, [O]/[I] | T7 only with donor-grid height and owner/COORD grant; never patch legacy. |
| R4 | 2D's `smooth_summer.json` is smaller than 3D's 118-rule table; copying only 2D data loses Winter/complete transition rules. | E16, [O]/[D] | Use 3D's table for data; use 2D's verbatim *application* semantics. |
| R5 | Donor call-site order is authored, commented text; shipped runtime activity is unknown. | `H06:64-68`, [U] | Keep "donor-faithful" narrow (call order only); no parity/equivalence wording. |
| R6 | Hardlinks mean a write through one tree would silently mutate the other. | E22, [O]/[D] | **Never write through a hardlinked path**; fresh module uses read-only `res://` loads; COORD owns any asset migration. |
| R7 | `.import`/`.uid` files are per-project, not hardlinked; changing a PNG's importer in one tree can diverge. | E22, [O] | Do not re-import or regenerate `.import`; keep current settings. |
| R8 | Season swap in `variant3d/scripts/world.gd` may not execute on the 3D path. | `G22:126`, [U] | Fresh module must read alias data itself; verify with capture before claiming season fidelity. |
| R9 | Donor parity remains UNVERIFIED; no donor GPU A/B exists. | `CHARTER.md:41,125`, [U] | Label every output PORT APPROXIMATION; no "closer by N%" verdict. |

---

## 6. UNVERIFIED register

| ID | Claim | Why UNVERIFIED | Needed |
|---|---|---|---|
| U1 | Donor generator scripts execute as authored at `generatemap.inc:786,795` | All lines `;`-commented (`H06:64-68`) | Binary/Ghidra anchor (D-wave) |
| U2 | 2D's band-based `relief()` is actually less faithful than 3D's exact-code decode at runtime | 3D matches the text of `generatemap.inc:342-370`; cell averaging is a port approximation (`variant3d/scripts/mapgen.gd:17-20`) | D03 byte proof + A/B |
| U3 | Forest interior should use `grass_ground1/2/3` (2D) vs `grass7/test12/13/14` (3D) | Both are donor-authored lists; mapping to terrain role 2 is not cited (`E17`) | RV-TRN/F05 family mapping + capture |
| U4 | Absence of Y08 `test8` flatten improves donor likeness | P01:66-70 confirms live flatten; no A/B of its removal | G04/COORD capture + metric |
| U5 | Hill/steep `terrain=5` painting is donor-correct on the port's height field | Donor rule literal, but caused maze (`E09/E10`, `P01:55-60`) | Fresh-module donor-grid A/B |
| U6 | `variant3d/scripts/world.gd` season swap executes for the 3D frame | `G22:126` | Render-mode trace/capture |
| U7 | Donor `bsmooth` / `SmoothTerrain` native kernel | `variant3d/scripts/mapgen.gd:43-47` exposes flag only | D03 binary decode |
| U8 | `RELIEF_PROBLARGE/RELIEF_PROBHUGE = 1.0` and `RELIEF_PLAIN_HUGE_FREQ = 5e-5` | Self-labelled placeholders (`variant3d/scripts/pattern_gen.gd:16-21,38-42`) | F03 cfg decode |
| U9 | Exact donor relief stamp blend order / row sign | 3D tables are 8×10 block means, "debug/preview aids only" (`variant3d/scripts/game.gd:91-99`) | D05/F01 full-grid decode |
| U10 | Whether 2D shore art is visually closer at a matched camera | G22's far-grass ROI is as flat as 3D (`G22:34-35,88`) | Matched-camera A/B |
| U11 | Hardlink validity across a future git checkout / CI clone | Hardlinks are a local filesystem property, not recorded by git | Re-run census after checkout |
| U12 | Any donor parity for either tree | No donor GPU A/B frame | Charter-defined capture |

---

## 7. Open questions

- Q1 — Should the fresh module copy 3D's embedded 118-rule smooth table verbatim and apply
  2D's unmodified name/weight semantics (T3), or does the donor require the
  `smooth_summer.json` 10-chain subset? Evidence: E16;UNVERIFIED U4.
- Q2 — Does restoring donor detail ids after smoothing (T1+T2) reproduce donor grass
  mottling, or does it reintroduce the Y08 checkerboard that the `test8` flatten was added
  to remove? Evidence: E11/E13/E18;UNVERIFIED U4.
- Q3 — Which donor family is authoritative for forest-interior tile ids — Item 4/5/6 J=3
  `grass_ground*` (2D) or Item 1 J=5 `grass7/test12/13/14` (3D)? Evidence: E17; U3.
- Q4 — Can the fresh donor-grid height path support `terrain=5` rock art without the concentric
  ring failure (T7)? Evidence: E09/E10; U5.
- Q5 — Does the fresh module need `world.gd`'s per-cell winter alias directly, or does the 3D
  atlas remap already cover it? Evidence: E21; U6.
- Q6 — Should `relief_smooth` flag finally drive a donor `SmoothTerrain` kernel, and is that
  kernel recoverable from the binary? Evidence: §3.1; U7.
- Q7 — Are the hardlinked assets stable backing for a committed new module, or should A03's
  `terrain_new/**` conversion root be the only reference? Evidence: E22, `A03_asset_pipeline.md:43-47`.
- Q8 — Can a single A/B isolate pass order (T1) from detail-id verbatimness (T2) and the
  `test8` flatten (T4), given all three change the same `tileblock` bytes? Evidence: R1/R2.

---

## 8. Guardrails and hand-off

- **No `app/` edit is recommended, requested, or performed.** Every row in §4 targets a new
  `variant3d/scripts/terrain_donor_*.gd`; COORD owns the `world3d.gd` switch
  (`CHARTER.md:57-61`, `P01:71-78`).
- Read-only this pass: no donor file opened, no Godot process, no runner job, no source / shader /
  config / asset / test / git mutation. One repo file written: this report.
- No donor parity claim anywhere; donor-faithful = agreement with cited authored donor text,
  and "closer" = absence of a self-labelled PORT APPROXIMATION. All outputs remain
  **PORT APPROXIMATION** until a real donor GPU A/B frame exists (`CHARTER.md:41,44,125`).
- Do not weaken any gate, add synthetic noise/dither, or add donor binaries (`CHARTER.md:60,66-69`).

### Hand-off summary (5 lines)

1. 2D `app/` has no exclusive terrain asset: 685 terrain files (672 PNG, 6 DDS, 7 JSON) are hardlinked into `variant3d`, including masks, `winter0..26` and the detail bitmaps.
2. `mapgen.gd` and `pattern_gen.gd` favour variant3d (exact relief codes, `bsmooth`, tier counts); no app→3D transplant there.
3. `game.gd` favours 2D: smooth→detail order matches donor call sites, detail ids and smooth rules are verbatim, mine/start tiles use `ground1`/`grass1` — all displaced in 3D by labelled `test8` PORT APPROXIMATION substitutions.
4. Shore/cliff 8-sector, water-cell retention, season alias and stamp placement are already identical and donor-derived; the fresh module should reuse them, not copy art.
5. Hill/steep `terrain=5` paint and the 2D height dither are NOT safe transplants; donor parity stays UNVERIFIED with no A/B frame.

*End of P05 report. Read-only; one report file; `app/` byte-untouched; no runner job; no donor parity claim.*
