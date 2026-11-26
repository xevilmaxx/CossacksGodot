---
id: P01
ticket: "TERRAIN-SWARM-2026-11-26 / Wave P / P01 — current variant3d terrain pipeline, end-to-end read-only trace"
agent: "P01 (read-only port audit subagent)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_RUNNER__NO_GODOT_JOB__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/P01_pipeline_audit.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor binary was opened, no donor GPU A/B frame was read, no Godot/runner job was submitted. Every donor statement is cited from prior read-only reports; all visual effects are INFERRED/UNVERIFIED. NO DONOR PARITY CLAIM."
version_note: "git HEAD e234ac9b (2026-11-26 08:56:33 +0100); `git status --short` for all audited pipeline files returned EMPTY. All file:line numbers below are the clean current working tree, not stale pre-B03/B04 backups cited in 2026-11-25 reports."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md; docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-25/reports/P16_terrain_geometry.md; Z04_height_only_design.md; Y02_maze_root_cause.md; Z02_hills_invisible.md; Y08_checkerboard.md; G26_water_shore.md
  - docs/variant3d/README.md
  - variant3d/config.json, scripts/{config,data,main,game,mapgen,pattern_gen,world3d,world3d_terrain,world3d_relief,water3d}.gd, shaders/terrain_tileindex.gdshader
---

# P01 — Definitive end-to-end trace of the CURRENT `variant3d` terrain pipeline

## 0. Evidence discipline / scope

Labels: **[O]** observed (literal current source line / decoded JSON value), **[D]** derived
(deterministic control-flow or arithmetic consequence of [O]), **[I]** inference without a
pixel-aligned donor A/B, **[U]** UNVERIFIED, **PORT APPROXIMATION** (explicit port substitute
for an unrecovered donor rule). Exactly one file written (this report); no code, shader,
config, asset, test, queue, git or donor state changed. No Godot process or runner job.

**Version correction [O]:** `git rev-parse --short HEAD` = `e234ac9b`, last commit
`2026-11-26 08:56:33 +0100`; `git status --short` over `game.gd`, `mapgen.gd`,
`pattern_gen.gd`, `world3d_terrain.gd`, `terrain_tileindex.gdshader`, `water3d.gd` was empty.
P16 §0 and Z04 §1.2 describe *uncommitted B03/B04 edits*; those descriptions are **stale**.
This audit traces the committed tree; where a prior report cites different line numbers,
this report's numbers govern.

---

## 1. Executive summary

1. **[O] The pipeline is two disjoint producers plus one renderer.** A sim producer
   (`config.json` → `Data` → `game.gd` → `mapgen.gd` → `pattern_gen.gd`) writes
   `terrain[]`, `blocked[]`, `height[]`, `tileblock[]`, `mine_mask[]`, `res_nodes`,
   `map_starts`, `map_meta`; a render consumer (`world3d.gd` → `world3d_terrain.gd` →
   shader → `water3d.gd`) reads only `height[]` and `tileblock[]` from a synthesized dump
   (`world3d_terrain.gd:926-963`). `terrain[]`/`blocked[]` **never cross into the mesh**.
2. **[O] `_generate_map()` is dead code** (`game.gd:918-925`): no production caller exists
   (repo grep finds only its definition and a stale note in `scripts/MAPGEN_STATUS.md:18`).
   The live path is `game.setup()` (`game.gd:361-370`) or the staged loader
   (`main.gd:559-581`) which calls the same stage functions in the same order.
3. **[O] There are five independent RNG streams, and one is dead.** `game.rng`,
   `C3MapGen.pick`'s local RNG, `C3PatternGen.rng`, `C3PatternGen.mine_rng`, and the
   tileblock `brng`; `game.gen_rng` is seeded eight times by `_reseed_stage()` but **never
   read** (`game.gd:149,264-266` and the eight call sites). Donor `SetRandomKey` stage
   reseeds are therefore **PORT APPROXIMATION** in this tree.
4. **[D] Relief is height-only at the producer and geometry-only at the consumer.** The
   height gradient produces **collision only** (`game.gd:1297-1310`); no `terrain=5` is
   written there any more. The mesh consumes height at vertex Y (`world3d_terrain.gd:1310-1312`)
   and normals (`:1387`, `:901-917`) and re-derives face mode from height (`:1332`,
   `:756-778`). The Y02 maze chain is **partly severed** (the collision→`terrain=5` link is
   gone; the height→face→cliff-art link remains).
5. **[O] The donor-faithful `relief_stamps` and Z04 relief-mask seams are not wired into the
   live 3D path.** `main.gd:791-803` can emit `relief_stamps` when `config.json:25` enables
   it, but `_dump_from_game()` copies only `map_w/map_h/height/tileblock`
   (`world3d_terrain.gd:955-963`), so `_apply_relief_stamps_from_dump()` (`:532-567`) is a
   no-op in live gameplay; `_relief_stamp_mask` never crosses the boundary.
6. **[O] The final `tileblock` authority is a deliberate flattening.** All ordinary land
   cells are collapsed to one meadow id `test8` after smoothing, spots, borders and mine
   apron (`game.gd:2144-2161`), and the detail pass overwrites its own donor-bitmap result
   with the same id (`game.gd:1982-2008`). This is the documented Y08 **PORT APPROXIMATION**,
   not donor tile variety.
7. **[I] Minimal seam:** a new donor-faithful module can be composed as a sibling at
   `world3d.gd:609-645` behind a switch, using the already-proven `world3d_relief.gd`
   pattern (`bind(game, terrain)`; no producer edits). It can read the public game fields and
   `Data` statics directly, implement the four-method terrain contract, and own its own
   stage pipeline and mesh; the legacy module is skipped rather than edited. No change to
   `game.gd`, `mapgen.gd`, `pattern_gen.gd`, `world3d_terrain.gd`, the shader or `water3d.gd`
   is required for composition (only the `world3d.gd` seam, which the charter reserves to
   COORD).

---

## 2. Evidence table

| ID | Source (file:line) | Observation / claim | Label |
|---|---|---|---|
| E01 | `config.json:77`, `:75-76`, `:107`; `config.gd:513-515,535-538`; `data.gd:35,229-235` | Seed `20261113`, grid `240×240`, `map_type="land"`, season `summer`, richness `med`, relief `hills` (from `config.gd:538` fallback because config has no `relief` key). | [O] |
| E02 | `main.gd:179-190`; `game.gd:416` | Config loaded/applied before generation; CLI `--seed`/random override; `rng.seed = Data.RANDOM_SEED`. | [O] |
| E03 | `data.gd:327-334`, `:42-45`; `game.gd:1171-1186` | Six map types with `water_frac`; generator version 91 makes every `<` gate false, so `mtype` is taken directly from `Data.MAP_TYPE`. | [O]/[D] |
| E04 | `game.gd:361-370`, `:918-925`; `main.gd:563-578` | `setup()` and staged loader call the stages; `_generate_map()` has no caller. | [O] |
| E05 | `mapgen.gd:34-61`, `:75-95`, `:145-238` | Mask manifest/pick, exact 8-code relief decode, `bsmooth` flag, RGB → height/forest/water, 1/2/3 coastal passes. | [O] |
| E06 | `mapgen.gd:214-215`; `game.gd:1179-1180`; repo grep | `forest` and `relief_smooth` outputs have **no downstream reader**. | [O] |
| E07 | `pattern_gen.gd:76-760` | Own RNG/mine RNG, occupancy grids, tiles/mines/starting resources/forest/stone/decor/relief stamp families; final authoritative mine relocation. | [O] |
| E08 | `pattern_gen.gd:80-83`; `game.gd:149,264-266` | `stage_seed` unused; `gen_rng` seeded but never read → dead stage stream. | [O] |
| E09 | `game.gd:946-1148` | `_shape_stamp_relief()` writes **height only**, plus two provenance masks; 8×10 donor-grid path for `plt2`/`k_ravine_1`, analytic fallback otherwise; 1-cell mask dilation. | [O] |
| E10 | `game.gd:1254-1274`, `:2542-2560` | Non-donor cells clamped to `[-2.964, +2.964]` with a seed-derived hash dither of at most 0.03; donor-grid cells skip the global clamp. | [O]/[D] |
| E11 | `game.gd:1278-1310`, `:2562-2567` | Cardinal `|dh|>0.5` / diagonal `>0.55` → `set_blocked_tile()` only; **no** `terrain=5` write. | [O] |
| E12 | `game.gd:740-916` | Stamp realisation: forest core discs + wood, stone quarry scar, decor bushes, mine deposits; hill branch is `pass`. | [O] |
| E13 | `game.gd:2015-2170`, `:2172-2249`, `:2251-2510` | Base roles → shore/cliff ids → detail bitmap → tile decals → grass spots → 3-pass smoothing → forest borders → mine apron → final meadow collapse → winter name alias. | [O] |
| E14 | `world3d.gd:604-661`; `main.gd:586-589` | `world3d.gd.bind()` composes terrain/entities/fx/fog/anim/relief; terrain built once; relief props bound after terrain. | [O] |
| E15 | `world3d_terrain.gd:926-963`; `main.gd:791-803` | Live dump is `map_w/map_h/height(base64)/tileblock(base64)` only; headless dump additionally has seed/terrain/blocked/starts/meta and optional `relief_stamps`. | [O] |
| E16 | `world3d_terrain.gd:573-721`, `:1220-1464` | Atlas/season load, mask R→A repack, tileblock decode/provenance, one full-grid mesh, normals, UV2, material, water/env. | [O] |
| E17 | `terrain_tileindex.gdshader:43,274-326,329-338,365-378,388-476` | `blend_mix, unshaded, cull_disabled`; donor-equation vertex Blinn-Phong; world XZ texgen; atlas cell lookup; alpha patch decomposition; mask folded into RGB; `ALPHA=1.0`. | [O] |
| E18 | `water3d.gd:24-45,154-280,305-321` | Flat 4-vertex plane, donor literals, `height_tex` alpha substitute, surface-Y placeholder `-0.25`; no donor binding proof. | [O] |
| E19 | `world3d_terrain.gd:1515-1517` | Stats explicitly list `"mountain terrainmesh props"` and `"exact donor engine blend"` as `not_done`. | [O] |
| E20 | `docs/terrain_swarm_2026-11-25/reports/Y02_maze_root_cause.md:113-125`; `Z02_hills_invisible.md:125-135`; `Y08_checkerboard.md:143-150`; `G26_water_shore.md:89-117` | Prior reports rank maze, flat-hill, checkerboard and water divergences; their line numbers are pre-current-tree. | [O, cited] |

---

## 3. Stage diagram and stage table

```
config.json ──> C3Config.apply ──> C3Data statics ──> main._ready / staged loader
                                                          │
                                             game.setup_begin()  [game.gd:410-467]
                                                          │
   ┌──────────────────────────────────────────────────────┘
   ▼
 game._gen_base() [1150-1331]
   ├─ C3MapGen.build()       [mapgen.gd:145-238]      mask → height/forest/smooth/starts
   ├─ analytic domes         [game.gd:1194-1210]      height +=
   ├─ terrain role from h    [game.gd:1217-1231]      terrain = 3/4/0
   ├─ C3PatternGen.build()   [pattern_gen.gd:76-760]  stamps (cached in _pattern_build)
   ├─ _shape_stamp_relief()  [game.gd:946-1148]       height +=, masks
   ├─ clamp / dither         [game.gd:1254-1274]      height
   ├─ collision pass         [game.gd:1278-1310]      blocked only
   ├─ start snap / roads     [game.gd:1311-1331]      map_starts, terrain=1
   ▼
 game._gen_patterns() [740-916] ──> terrain/blocked/res_nodes (wood/stone/ore/bush)
 game._gen_forests / _gen_resources / _gen_finish [1333-1595]
   ▼
 game._assign_tileblocks() [2015-2170]
   base → shore/cliff [2238-2249] → detail [1959-2010] → decals → spots [2377-2462]
   → smooth×3 [2348-2355] → borders [2357-2369] → mine apron → Y08 collapse [2144-2161]
   ▼
 world3d.gd.bind() [604-661] ──> world3d_terrain.bind(game) → build()
   _dump_from_game [926-963] → height/tileblock base64
   build [1220-1709] → mesh/normals/UV2/material + water3d + env + stats
   ▼
 terrain_tileindex.gdshader [43,274-476] → final RGB; water3d.gdshader ← height_tex
```

| # | Stage | Entry point (file:line) | Writes | RNG consumed | Divergence / label |
|---:|---|---|---|---|---|
| 1 | Config/seed | `config.json:72-109` → `config.gd:479-600` → `data.gd:32-45,229-247` | `Data.MAP_W/H/RANDOM_SEED/MAP_TYPE/BIOME/RICHNESS/RELIEF`; `GENERATOR_VERSION=91` | none | [O] defaults are port-authored menu values; 6 map types vs donor 9+Random shapes (`data.gd:342-358`) — PORT APPROX. |
| 2 | Sim bootstrap | `main.gd:172-190,559-581`; `game.gd:361-370,410-467` | resize/zero `terrain/blocked/height/mine_mask`; `nav.configure`; player slots | `rng.seed` `:416` | [O] `_generate_map()` `:918-925` unused — [D] no caller. |
| 3 | Mask decode | `mapgen.gd:34-61,96-238` | `height`, `forest`, `smooth`, `starts`, `water`, `mask` | local `r` seeded `(seed^type.hash())+104729` `:59-61` | [O] exact 8-code decode `[I]`; smoothing kernel substituted `:87-95,225-235` PORT APPROX; `forest`/`smooth` dead `[O]`. |
| 4 | Pattern stamping | `pattern_gen.gd:76-760` (called `game.gd:1245-1246`) | `stamps`, `occupied` (cached in `game._pattern_build`) | `rng` `:90-91`; `mine_rng` `:317-318` | [O] frequencies/weight multipliers PORT APPROX `:18-52`; final mine layout port fairness pass `:591-758`. |
| 5 | Relief stamps | `game.gd:946-1148` | `height`, `_relief_donor_mask`, `_relief_stamp_mask`, `map_meta.relief_grid` | none | [O] 2 of 26 grids; 8×10 block means PORT APPROX, `row_flip: UNVERIFIED` `:1147` (Z02 rank 6). |
| 6 | Clamp/collision | `game.gd:1254-1274`, `:1278-1310` | `height` clamped/dithered; `blocked` via `set_blocked_tile` | `_noise2` is seed-derived hash, not a draw `:2542-2560` | [O] donor `cDiff` literals used for **collision only**; donor clamp UNVERIFIED; maze's `terrain=5` route removed (Y02/L03). |
| 7 | Stamp realisation | `game.gd:740-916` | `terrain`, `res_nodes` (wood/stone/bush/ore), `mine_mask` | `game.rng` `:833,863,869,872` | [O] hill branch `pass` `:853-861` (Z04-A); stone quarry scar `:847-852`. |
| 8 | Finish | `game.gd:1333-1595` | `terrain`, `blocked`, `res_nodes.left`, `map_starts` | `game.rng` `:653,682-683,702,704` | [O] richness/mine guarantee passes are port rules; no wild food (T-FOOD-1). |
| 9 | Tileblock | `game.gd:2015-2170` | `tileblock`, `mine_mask` read-only, `winter_tile_names` | `brng` seeded `seed+7` `:2027-2028` | [O] Y03/Y08/Y08b/L01/B03-P3 PORT APPROX substitutions; donor tables embedded verbatim `:1604-1770`. |
| 10 | Composition | `world3d.gd:604-661`; `main.gd:586-589` | node instances, one terrain build, relief props | none | [O] terrain path is a dynamic script constant `:108`; relief sibling proves no-producer-edit seam `:113-116,649-650`. |
| 11 | Dump/boundary | `world3d_terrain.gd:926-963,969-1049` | `_tile_indices`, hist/provenance (stats only) | none | [O] `relief_stamps`/`terrain`/`blocked`/mask never reach live renderer; dump-only prov `:1008-1014`. |
| 12 | Mesh build | `world3d_terrain.gd:1220-1464` | `verts`, `norms`, `uvs`, `uvs2`, indices, one `ArrayMesh`, mat, water, env, `stats` | none | [O] `HEIGHT_SCALE=1.0`, `TILE_M=2.0`, `UV2=(tile_id,face)`; face promotion PORT APPROX `:1334-1359`; Z04 guard absent. |
| 13 | Shader | `terrain_tileindex.gdshader:43,274-476` | final `ALBEDO`, `ALPHA=1` | none | [O] unshaded donor-equation port; `bmTransparency` multi-pass → one `blend_mix` PORT APPROX `:27-43,235-246`. |
| 14 | Water | `water3d.gd:24-45,154-321`; `world3d_terrain.gd:1089-1106` | 4-vertex plane, uniforms, `height_tex` alpha grid | none | [O] surface Y placeholder, hmapTex substitute (G26 register); waveheight 0 under shipped literals. |

---

## 4. Stage-by-stage trace (exact writes and RNG)

### 4.1 Config → seed → map types

- **[O]** `config.json:75-77` sets `map_width_tiles=240`, `map_height_tiles=240`,
  `random_seed=20261113`; `config.json:107` sets `map_type="land"`; `features.terrain.relief_stamps`
  is `true` at `:24-26`. `config.gd:513-515` applies W/H/seed; `:535-538` resolves
  `MAP_TYPE` from `terrain_type` → `map_type` → `"mediterranean"` (so the on-disk file yields
  `"land"`), `BIOME="summer"`, `RICHNESS="med"`, `RELIEF="hills"`; `:595-600` resolves donor-id-only
  configs. Defaults are declared at `config.gd:117-133`; `data.gd:35,229-235` are the statics.
- **[O]** `main.gd:179-190`: CLI `--seed`/`--seed-random` overrides `Data.RANDOM_SEED` after
  `cfg.apply()`; `game.gd:259` (`_init`) and `:416` (`setup_begin`) seed the legacy `rng`.
- **[O]** `data.gd:327-334` lists the six map types; `data.gd:342-358` maps nine donor shapes
  onto them (`PORT APPROXIMATION`). `data.gd:42-45` + `game.gd:1171-1173` mean all legacy
  generator gates are false at version 91 **[D]** so `mtype` is the raw config value.
- **[O]** `game.gd:918-925` `_generate_map()` duplicates `setup()` stages but is **never
  called**; `scripts/MAPGEN_STATUS.md:18` claiming otherwise is stale.

### 4.2 `mapgen.gd` — mask decode and `C3MapGen.build()`

- **[O]** `manifest()`/`types()`/`mask_count()`/`pick()` at `:34-49`; `pick` uses an
  independent RNG `(seed ^ type.hash()) + 104729` (`:59-61`) and falls back to `"land"`.
- **[O]** `relief(v)` at `:75-85` decodes **only** codes 255/191 → `C_PLATEAU*(code/255)`,
  96/112 → `C_HILL*(code/255)`, 48/88 → `C_RAVINE*(code/255)`, everything else 0. Comment
  `:63-74` records that the disabled `//*(255/cRColor*)` multipliers make live amplitudes
  ≈+0.496/−0.558, not ±1.317/±2.964. `relief_smooth()` `:92-94` carries the donor `bsmooth`
  flag as data only; `:152-154,214,238` allocate/fill it.
- **[O]** `build()` `:145-238`: loads the chosen mask PNG through `ResourceLoader` (`:166`),
  converts to RGB8 (`:180-184`), averages each port cell over its source rectangle
  (`:186-210`), skips pure-white start markers (`:199-201`), then
  `height[i] = C_WATER*(b/255)*(1+3.5*r/255) + relief(r)` (`:212-213`), `forest[i]=g/255`
  (`:215`), water fraction counted with `WATER_DEEP=-0.25` (`:216-217`).
- **[O]** Coastal smoothing `:218-235`: `passes=3` (`low=1`, `medium=2` per `:221-224`),
  `_near_water()` `:119-143` marks cells `<0.8` or within 2 cells of `<-0.1`, and each pass
  blends the mean of four diagonal neighbours at 0.5. **[I]/PORT APPROXIMATION:** the donor
  kernel is UNVERIFIED (`:87-94`); this is a substituted operator.
- **[D] Dead outputs:** `forest` and `relief_smooth` are assigned to `_st_forest`
  (`game.gd:1179-1180`) and never read (repo grep); the donor G-channel and smoothing flag
  therefore have **no effect** on the current generated terrain.

### 4.3 `game.gd::_gen_base()` — analytic domes, relief stamps, clamp, collision

- **[O]** `_gen_base()` `:1150-1331`; stage reseeds `:1163-1165` (terrain/legacy starts),
  `:1187-1189` (starts/team). `C3MapGen.build()` call `:1174-1175`; results copied to
  `height`/`map_meta`/`map_starts` `:1176-1186`.
- **[O]** Analytic domes `:1194-1210`: `domes = budget.domes + RELIEF_DOME_DELTA[relief]`
  (budget from `data.gd:168-178`; default `high` → 4 domes, `hills` adds 1), three `rng`
  draws per dome (`:1198-1200`), `height += (1-dd)^2 * (2.964/2.25) * relief_scale`.
  This is a **port-analytic** shape on top of the donor-mask base.
- **[O]** Terrain roles from height `:1217-1231`: `h<-0.25 → terrain=3` + `set_blocked_tile(true)`;
  `-0.25..-0.1 → terrain=4`; else 0. Water/sand blockers are purposely not written by the
  later collision pass (`:1278-1282`).
- **[O]** `C3PatternGen.build()` is invoked here at `:1245-1246` **before** relief shaping,
  cached in `_pattern_build`, and reused by `_gen_patterns` (`:744-748`) so stamp placement
  is computed once.
- **[O]** `_shape_stamp_relief()` `:946-1148`: builds `near_start` disc using
  `CIRCLE2*map_scale*1.5` (`:966-980`) and marks it in `_relief_stamp_mask`; for each
  relief stamp, donor id selects one of two 8×10 grids (`:988-996`); per-cell branch
  `:1053-1073` writes `height[i] = clamp(h + grid*scale, max(min,RELIEF_RAVINE), min(max,RELIEF_PLATEAU))`,
  sets both masks; analytic fallback `:1074-1118` writes `height[i] = clamp(h+amp*f,-2.964,2.964)`;
  `:1119-1137` dilates the mask one cell; `:1139-1148` writes audit `map_meta`.
- **[O]** Clamp/dither `:1254-1274`: water (`terrain==3`) skipped; donor-grid cells skipped
  (`:1257-1266`); all other land cells get `clamp(h,-2.964, 2.964 or 2.934)` where the cap
  comes from `_noise2(hx*0.31+3, hy*0.31-7) < 0.58` (`:1270-1273`). `_hash2` folds
  `Data.RANDOM_SEED` (`:2542-2547`) — **[D]** deterministic per-seed quantization, not an
  RNG draw; no new synthetic field is introduced here (pre-existing S-25-09 constraint).
- **[O]** Collision `:1278-1310`: 8-neighbour test with the donor literals 0.5/0.55; steep
  cells call `set_blocked_tile(x,y,true)` (`:1310`), which writes `blocked[]` and bumps
  `nav_version` (`:2562-2567`). **[O]** There is **no** `terrain[i]=5` assignment in this
  pass (contrast Y02's pre-fix `:1263`); only genuine stone stamps (`game.gd:847-852`) still
  write `terrain=5`. **[D]** The Y02 maze route `height→terrain=5→rock art` is severed; the
  `height→face→cliff art` route (§4.6) survives.
- **[O]** Start snap `:1311-1327` and two `_draw_road()` calls `:1330-1331`; road writes
  `terrain=1` and clears `blocked` on its corridor (`:2569-2598`).

### 4.4 `pattern_gen.gd` — stamping

- **[O]** `build()` `:76-760`. RNG: shared `rng.seed=(seed^0x5f356495)+map_w*31+map_h`
  (`:90-91`); `mine_rng.seed=(seed^0x7a3c91ef)+map_w*13+map_h` (`:317-318`);
  `stage_seed` hook unused (`:80-83`). `s = map_w/160` (`:92`).
- **[O]** Footprint scaling `scale_cells` `:110-128`; `can_stand`/`stand` `:132-151`;
  weighted `pick` `:153-172`; biome family resolution `:174-177`; generic `stamp_family`
  `:179-211`. Start keep-clear ellipses `:213-229`.
- **[O]** Stage order inside `build`: `SetupTiles` decals `:230-251`; legacy mine rejection
  replay `:253-298` (consumes shared `rng`, discards stamps, preserved for stream parity);
  `SetupMines` clusters `:300-426` (uses `mine_rng`); `SetupStartingResources` `:428-436`
  (stone×2 + one pine forest per start); global forest families `:438-482` (own `forest_occ`,
  counts scaled by area and a `map_w<=160` clamp `:480-481`); stone/decor/hill recipes
  `:483-493`; relief stamps `:495-589` (own `relief_occ`; `needed=floor(W*H*freq)` from
  donor presets `:24-52,562-589`; PORT APPROX multipliers `RELIEF_PROBLARGE/PROBHUGE=1`);
  final mine-layout authority `:591-758` (relocates the same stamps, never changes count,
  with 11-tile centre separation `MINE_MIN_SEP_TILES` mirrored in `game.gd:34`).
- **[O]** Return `{"stamps","occupied","scale"}` `:760`; `game.gd` stores it in
  `_pattern_build` (`:1245`) and exposes stamps to `world3d_relief.gd:120-129`.

### 4.5 `game.gd::_gen_patterns()` — stamp realisation

- **[O]** `:740-916`; uses cached `_pattern_build` (`:744-748`), records `map_meta.stamp_counts`
  (`:750-754`), builds `start_pts` in metres (`:755-759`).
- **[O]** Forest stamps paint a filled core disc (`:772-807`) with radius
  `clamp(cext*0.25,14*TILE,22*TILE)*size_k`; per-cell `rng.randf()<0.30` up to 14 wood nodes
  (`:820-844`, T-FOREST-DENSE). `tile` stamps are `pass` (`:845-846`). `stone` paints
  `terrain=1` within 3.2 cells and `terrain=5` within 1.6 (`:847-852`); `hill` is `pass`
  (`:853-861`, Z04-A); `decor` adds bushes at `rng.randf()<0.10` (`:862-865`).
- **[O]** Post-pass: stone quarry stones `rng.randi_range(4,7)` + `rng.randi_range(0,n)`
  (`:867-876`); mine deposits nudged to a clear site then `_add_res` + `_paint_terrain`
  (`:877-911`); cluster claims (`:915-916`).
- **[D]** RNG stream order matters: the short-circuit "once cap reached, stop drawing"
  (`:821-833`) is deliberately preserved; any extra draw shifts downstream stone/mine
  placement (comment `:822-832`).

### 4.6 `game.gd` tileblock chain

- **[O]** `_assign_tileblocks()` `:2015-2170`: `brng.seed=Data.RANDOM_SEED+7` `:2027-2028`.
- **[O]** Base loop `:2037-2089`: one `brng.randf()` per cell (`:2041`); terrain 1 →
  ground1/test2/test3 with a second draw (`:2043-2053`); terrain 2 → donor forest family
  `DONOR_FOREST_BASE` (`:2054-2066`); terrain 3 → `BLK_WATER=255` (`:2067-2068`); terrain 4 →
  sand1/2/7 (`:2069-2070`); terrain 5 → six rock ids (`:2071-2083`); mine apron overrides
  to `ground1` (`:2084-2088`).
- **[O]** Shore/cliff pass `:2091` calls `_apply_shore_cliffs()` `:2238-2249`: terrain 4
  gets `_shore_tile_for()` (8-sector donor table `:2172-2201`); terrain 5 gets
  `_cliff_tile_for()` (`:2203-2236`, with `|h|>2.7→rock8`, `>2.4→rock4`, `<0.1→none`).
  **[D]** This is the surviving height→visible-art route identified by Y02/Z04.
- **[O]** Detail pass `:2097` calls `_apply_detail_pass(brng)` `:1959-2010`: donor
  `tile_lowground`/`tile_highground` bitmaps `:1949-1957`; block `0` cells read `R div 2`,
  h<0.1 selects low bitmap (`:1975-1981`); two `_tb_pick` re-rolls deliberately consume the
  same draws (`:1982-1996`); then **all** outputs are overwritten with `_blk("test8")`
  (`:1997-2008`) — Y03 port substitution.
- **[O]** Tile decals `:2109-2121` paint donor `tls_*` cells `ground1`; grass spots `:2130`
  (`_stamp_grass_spots` `:2377-2462`, donor weights repurposed as run-length/polarity/light-id
  rules — L01 PORT APPROX, Y08's checkerboard trigger); 3-pass smoothing `:2134`
  (`_smooth_tilemap` `:2348-2355`, `_tb_smooth_pair` `:2285-2346`, `_tb_pick` `:2251-2283`);
  forest borders `:2137` (`:2357-2369`); mine apron final authority `:2141-2143`.
- **[O]** Final flattening `:2144-2161`: every non-water, non-road/water/shore/rock role
  cell becomes `meadow_id=_blk("test8")`; winter names alias at `:2166-2170`.
  **[D]** The donor's 118-rule transition output (`DONOR_SMOOTH_RULES` `:1604-1763`) is
  computed and consumed for RNG parity but largely erased from the final art.

### 4.7 Composition, dump, mesh, shader, water

- **[O]** `world3d.gd:108` picks `world3d_terrain.gd`; `:609-614` instantiates modules;
  `:642-650` binds terrain, calls `build()` when `_has_height_source(game)` (`:231-238`),
  then binds relief props; `main.gd:586-589` chooses this world for `render_mode=="3d"`.
- **[O]** `_dump_from_game()` `world3d_terrain.gd:926-963`: prefers an existing
  `dump`/`map_dump`/`self_base` dictionary with `height` (`:929-932`); otherwise synthesizes
  `map_w/map_h/height/tileblock` from live `game` fields (`:933-963`). **[D]** It copies
  neither `terrain`, `blocked`, `mine_mask`, `map_meta`, `relief_stamps` nor
  `_relief_stamp_mask`; the headless `--dump-map` producer (`main.gd:791-803`) *can* emit
  `relief_stamps` (config `true`, `main.gd:789-790,802-803`) but that dictionary is not the
  live gameplay one.
- **[O]** `build()` `:1220-1709`: `invalidate()` `:1170-1216`; dump decode `:1223-1243`;
  opt-in relief stamps `:1246-1256` (no-op under current dump); `_decode_tile_indices()` `:1259`,
  which also builds dump-only neighbour provenance `:1008-1049`; `_load_atlas()` `:1260`
  (season paths `:580-596`, loader `:597-659`, mask R→A repack `:662-675`, uniform binding
  `:682-721`); tile-name dictionary `:1267-1275`.
- **[O]** Mesh `:1288-1428`: one vertex per cell, `verts[i].y=height[i]*HEIGHT_SCALE`
  (`:1310-1312`), cell-centre UV (`:1313-1314`); tile id + water sentinel + shore gate
  (`:1324-1329`); `face = 0 if shore_gate else _face_mode_at()` (`:1332`, thresholds
  `:161-162`, stencil `:756-778`); cliff vf/vs art swap `:1340-1354`; shore sector swap
  `:1355-1385`; normals `_tilt_face_normal(_normal_at(...), face)` `:1387`; desert remap
  `:1401-1405`; `UV2=(float(tid),float(face))` `:1407`; indices `:1408-1418`; one surface
  `:1420-1428`.
- **[O]** Material `:1434-1446` (shader when tileblock+atlas available, else splat fallback
  `:724-740`); `MeshInstance3D "HeightmapTerrain"` with `cast_shadow=OFF` `:1447-1456`;
  `_make_water3d()` `:1089-1106` (fallback `_make_water()` `:1054-1081`); environment/sun
  `:1114-1166` with `shadow_enabled=false` `:1160`; stats `:1492-1708`.
- **[O]** Shader `terrain_tileindex.gdshader`: `blend_mix, unshaded, cull_disabled` `:43`;
  four samplers `:60-83`; `atlas_grid` `:91`; world-XZ planes `:120-122`; donor light/fog
  `:150-206`; `uv_repeat=0.5` `:214`; `mask_to_alpha=1.0` `:235-246`; vertex Blinn-Phong and
  `UV2` transport `:274-326`; atlas cell `:329-338`; alpha-patch decomposition `:365-378`;
  `rgb = rgb * mix(1,a,mask_to_alpha) * v_packed + v_specular` `:427`, `ALPHA=1.0` `:475`.
- **[O]** Water `water3d.gd`: classification literals `:24-25`, surface-Y placeholder `:36`,
  donor colours/literals `:37-87`; `build()` `:154-280` binds uniforms (`:176-199`), wave
  PNG `:203-210`, 4-vertex plane `:212-237`, stats `:240-279`; `bind_height_grid()` `:305-321`
  quantizes height to alpha over ±`MAX_HEIGHT` — a **PORT SUBSTITUTE** for donor `hmapTex`
  (`water3d.gd:283-294`).

---

## 5. RNG ledger (where randomness is actually consumed)

| Stream | Seeded at | Consumed at | Effect |
|---|---|---|---|
| `Data.RANDOM_SEED` | `config.json:77` → `config.gd:515` → `data.gd:35`; CLI override `main.gd:187-190` | all streams below | single deterministic root. |
| `game.rng` | `game.gd:259,416` | `:653,682-683,702,704` (forest/bush scatters), `:833` (wood fill), `:863` (decor), `:869,872` (stones), `:1198-1200` (domes) | legacy continuous stream; order-sensitive. |
| `game.gen_rng` | `game.gd:266` via `_reseed_stage` at `:741,1163-1165,1187-1189,1334,1353,1551` | **nowhere** | [O] dead stage stream; donor per-stage `SetRandomKey` behaviour not reproduced. |
| `C3MapGen.pick` local `r` | `mapgen.gd:59-61` | `:61` | mask family choice only. |
| `C3PatternGen.rng` | `pattern_gen.gd:90-91` | `:163` (weighted family pick), `:188-189` (stamp centre), `:284,287-288` (mine replay), `:541,544-545` (relief stamp placement) | all stamp locations except final mine relocation. |
| `C3PatternGen.mine_rng` | `pattern_gen.gd:317-318` | `:329`, `:375-405`, `:412-426`, `:675-755` | mine clusters + authoritative relocation; deliberately isolated from other streams. |
| tileblock `brng` | `game.gd:2027-2028` (`seed+7`) | `:2041,2047,2070`, `:1990,1994` (detail re-rolls), `:2437,2445,2472,2488,2504` (spots), `:2261` (smoothing), `:2369` (borders) | all tile art draws; deterministic separate stream. |
| `_hash2`/`_noise2` | `game.gd:2544` (seed folded into hash) | `:1272` (height cap dither), `:2575,2595` (road path) | [D] seed-derived deterministic field, **not** an RNG draw. |
| `C3MapGen` mask average | none | `mapgen.gd:196-205` | [D] multi-pixel averaging is a port approximation of donor single-pixel sampling (`:72-74`). |

---

## 6. Divergences from donor behaviour already documented in prior reports

| # | Current-tree evidence | Prior report verdict | Label |
|---:|---|---|---|
| 1 | Base relief amplitudes `mapgen.gd:75-85` (+0.496/−0.558 at R=96/48) | Z02 rank 8 — correctness refactor makes grid flatter. | [O]+[D] |
| 2 | Coastal smoothing kernel `mapgen.gd:225-235`; flag data only `:87-94` | Donor 3-pass kernel UNVERIFIED; port substitution. | PORT APPROX / [U] |
| 3 | `forest`/`relief_smooth` dead: `mapgen.gd:214-215`, `game.gd:1179-1180` | Donor G-channel and `bsmooth` drive forests/stone; no port consumer. | [O] (new finding) |
| 4 | Only `plt2`/`k_ravine_1` grids wired: `game.gd:988-996`, 2-row `RELIEF_GRID_META:125-130` | Z02 rank 6 / Z04 Part B: 2 of 26 grids; donor-active families absent; Z04-B tables **not landed** in current tree. | [O]+[D] |
| 5 | Analytic domes `game.gd:1194-1210`, clamp+dither `:1254-1274` | Z02: no donor-generated domes/clamp; port shape, donor clamp UNVERIFIED. | PORT APPROX |
| 6 | No `terrain=5` in collision `game.gd:1297-1310`; `blocked[]` still written | Y02 `:113-125` originally named `:1263 terrain=5` the maze producer; L03/Z04-A removed it — **documented divergence from the older chain**. | [O] |
| 7 | Hill stamp `pass` `game.gd:853-861`; stone scar remains `:847-852` | Z04 Part A: art removal on donor hill footprints is PORT APPROX (donor paints rock from collision tags). | PORT APPROX |
| 8 | Face/cliff art still height-derived `world3d_terrain.gd:1332,1340-1354` | Z04 Part C guard (return 0 when `_relief_stamp_mask[i]!=0`) is **not present** in current tree. | [O] (new finding) |
| 9 | Maze residue via detail/spots/rock ids `game.gd:1982-2008,2357-2462,2071-2083` | Y01/Y02/Y07/Y08: rings and checkerboard survive through art routes, not height. | [I, cited] |
| 10 | Y08 collapse `game.gd:2144-2161`; detail neutralisation `:1997-2008` | Y08: intentional single-id flattening to kill checkerboard; not donor tile variety. | PORT APPROX |
| 11 | `DONOR_SMOOTH_RULES` 118 rules embedded `game.gd:1604-1763`, consumed by `brng` but erased by final collapse | TRN-DATA donor tables are verbatim; final art substitution is port-level. | [O]/[D] |
| 12 | Mine clusters/relocation `pattern_gen.gd:369-426,591-758` | T-MINES-FIX fairness/layout pass is port-authored; replay preserves count/stream. | PORT APPROX |
| 13 | `relief_stamps` seam: producer `main.gd:802-803`, reader `world3d_terrain.gd:532-567`, but live dump `:926-963` omits it | RELIEF-01/02 documented opt-in; in current live 3D it is inert. | [O]+[D] (new finding) |
| 14 | `stats.relief_grid.not_done` `world3d_terrain.gd:1515-1517` | Z02: full grids / mountain props / exact engine blend absent. | [O] |
| 15 | Face tilt/vf-vs `world3d_terrain.gd:885-893,1340-1354` vs shader `:469-471` (no 25° rotation) | RV-TRN-01 verdict C: promotion engine path UNVERIFIED; internal port inconsistency in convention. | PORT APPROX / [I] |
| 16 | Water substitute `water3d.gd:36,305-321`, `world3d_terrain.gd:1089-1106` | G26: waveheight 0, hmapTex UNVERIFIED, soft wash cut aligned to `-0.25`. | PORT APPROX / [U] |
| 17 | `bmTransparency` → one `blend_mix`, mask folded into RGB `shader:27-43,235-246,427` | Prior A/B: removing mask darkens; donor multi-pass engine semantics UNVERIFIED. | PORT APPROX |
| 18 | `gen_rng` dead `game.gd:149,264-266` | Donor `SetRandomKey` per stage; port stage reseeds are inert. | [O] (new finding) |

---

## 7. Minimal seam for a NEW donor-faithful module (no legacy edits)

**Observed seams [O]:**

1. `world3d.gd:108` dynamic terrain script constant; `:609` `_instantiate(TERRAIN_SCRIPT)`;
   `:642-645` `terrain.bind(game)` / `terrain.build()`; `:649-650` a **sibling** module
   (`world3d_relief.gd`) is already composed without touching any producer.
2. `world3d_relief.gd:86-92,97-183` proves a donor-derived module can read
   `game.pattern_stamps`, `MAP_W/MAP_H` and `terrain.height_at_world()` read-only, keep its
   own `stats`, and add no RNG draws.
3. The producer arrays are public: `game.gd:42-70` (`terrain`, `blocked`, `height`, `tileblock`,
   `mine_mask`, `map_starts`, `pattern_stamps`, `map_meta`); config/seed are public statics
   (`data.gd:35,229-235`). A new module can use the same duck-typed `game.get(...)` pattern as
   `world3d_terrain.gd:929-963` and `world3d.gd:231-238`.
4. `world3d_terrain.gd` exposes a four-method contract used by `world3d.gd` and atoms:
   `bind` `:349`, `build` `:1220`, `invalidate` `:1170`, `height_at_world` `:1722`
   (plus `has_chunk_or_fallback` `:1714`) — cited as the integration contract in P16 §1.4.
5. The headless dump (`main.gd:791-803`) already exports `seed/terrain/blocked/height/tileblock/
   starts/meta` and optionally `relief_stamps`, giving a QA seam that needs no producer edit.

**Proposed composition [I] / [D]:**

- Add a new `variant3d/scripts/terrain_donor_*.gd` (+ optional shader/asset decoder outputs)
  implementing the same `bind/build/invalidate/height_at_world/has_chunk_or_fallback` surface.
- Add **one** `const DONOR_TERRAIN_SCRIPT` and a switch in `world3d.gd.bind()` (`:609`,
  `:642-645`) that instantiates and binds the new module **instead of** the legacy one when
  selected. This is the only legacy file touched, and the charter (`CHARTER.md:57-61`) already
  reserves it to COORD.
- The new module should own its *entire* donor stage pipeline internally (mask decode →
  relief stamp → smooth → water/shore → tile ids → props) and feed its own mesh/water nodes,
  so it does **not** inherit the port substitutions listed in §6. It may consume the seed and
  map type from `Data`/config and derived donor assets, but should not read legacy
  `height[]`/`tileblock[]` if it claims donor fidelity.
- **Do not edit** `game.gd`, `mapgen.gd`, `pattern_gen.gd`, `world3d_terrain.gd`,
  `terrain_tileindex.gdshader` or `water3d.gd`; do not weaken gates. Keep the legacy path
  behind the switch for rollback and A/B (charter §3 item 3, §4).
- **[D] Stacked-node hazard:** `world3d_terrain.gd:1447-1464` adds the terrain mesh, water and
  environment as children; a parallel donor module must not let both branches build in the
  same `world3d.gd.bind()` call, or two meshes/two water planes/two `WorldEnvironment` nodes
  will be submitted.

---

## 8. Implications for the rest of the swarm

- **D/F workers** should target the *donor* stage order, not the port's: in the current tree
  pattern stamps are generated before relief height (`game.gd:1245-1247`) but realised after
  the collision pass (`:740-916`); donor `dogenerate.inc` stage order must be recovered before
  claiming a mismatch **[U]**.
- **A05/QA**: seed determinism is spread over five streams (§5); a byte-identical replay must
  fix all of them, including `brng` and `_hash2`, even though `gen_rng` is inert.
- **A03/assets**: the port's only height-shape assets are two 8×10 block-mean tables
  (`game.gd:99-130`, `world3d_terrain.gd:198-247`); full donor float grids and `terrainmesh*.osm`
  props are explicitly `not_done` (`world3d_terrain.gd:1515-1517`, Z02 rank 2).
- **A06/integration**: the clean switch point is `world3d.gd:609/642-650`; the existing relief
  props module (`world3d_relief.gd`) can be reused or bypassed by a donor module that renders
  its own silhouette geometry.
- **Visual verdict**: any "readable hills/shore" expectation remains **[I]/[U]** until a fresh
  capture exists; the charter forbids a parity claim without a donor GPU A/B frame.

---

## 9. Risks

| # | Risk | Severity | Evidence / mitigation |
|---:|---|---|---|
| R1 | New module stacks a second mesh/water/environment with the legacy branch | high | `world3d_terrain.gd:1447-1464`; make the `world3d.gd` switch exclusive. |
| R2 | `brng`/`rng` stream drift breaks seed replay or gates | high | §5 ledger; new module must own a separate stream; no edits to legacy draw order. |
| R3 | Donor arrays not exposed on live `game` for new-stage provenance | medium | `_dump_from_game()` `:926-963` omits terrain/blocked/relief masks; read public fields directly or use headless dump. |
| R4 | Y02/Y08 artefacts return if the new module reinstates `terrain=5` or per-id detail | medium | `game.gd:1297-1310,1997-2008,2144-2161`; fresh capture + histogram required. |
| R5 | Gate breakage from new stats keys / node names | low-medium | `world3d_terrain.gd:1492-1708` stats shape is asserted by atoms; keep additive-only. |
| R6 | Donor constants remain unrecovered (blend, kernel, vf/vs promotion, hmapTex, surface Y) | high (epistemic) | label PORT APPROX/[U]; do not invent values (charter §4). |
| R7 | Prior reports' line numbers are stale | medium | version note §0; re-read before applying any proposal. |
| R8 | `relief_stamps` config flag `true` in `config.json` may mislead QA into thinking live 3D uses it | medium | `config.json:25`, `main.gd:802-803` vs `world3d_terrain.gd:926-963`. |

---

## 10. UNVERIFIED register

1. **No donor binary/data was opened and no donor GPU A/B frame was read** by P01; all donor
   claims are cited from prior reports. No visual parity claim of any kind.
2. No Godot process, runner job, queue mutation, git operation or source edit was performed;
   all runtime effects below are static reads.
3. Donor mask sampling (single pixel vs port 4-point average), gauss/`bsmooth` kernel,
   `Replace`/`ReplaceForWater`/`Smooth` relief blend, row-flip sign, height clamp and scale
   are **UNVERIFIED** ( cited `mapgen.gd:63-94`, `game.gd:1053-1073,1147`).
4. `terrainmesh*.osm` silhouettes, exact tile→atlas mapping, `bmTransparency` multi-pass
   semantics, face vf/vs promotion, water `hmapTex` binding and surface Y are **UNVERIFIED**
   (`world3d_terrain.gd:1515-1517`, shader `:112-118,469-471`, `water3d.gd:283-294`).
5. Whether the final Y08 meadow collapse visually matches donor tile variety is **UNVERIFIED**;
   it is an explicit port substitution (`game.gd:2144-2161`, Y08 report).
6. Whether the removed `terrain=5` gradient pass changes donor rock placement is **UNVERIFIED**
   without a donor frame; the code change itself is [O].
7. `Data.TILE_M=2.0`, relief grid physical scale and 240²/320² visual equivalence remain
   **PORT APPROXIMATION** (Z02 §5, G26 §117).
8. The proposed `world3d.gd` switch is a **design inference [I]**; it is not present in the
   current tree and has not been gated.

---

## 11. Open questions

1. Did donor `dogenerate.inc` generate relief heights *before* or *after* collision tagging?
   Current port order is stamps → height → collision → stamp realisation
   (`game.gd:1245-1247,1278-1310,740-916`); donor order is **[U]**.
2. Which donor mask code/byte actually drives the `forest` G channel and `bsmooth` flag, given
   the port computes both and uses neither (§4.2)?
3. Should the new donor module consume the existing `world3d_relief.gd` props or own its own
   `terrainmesh` equivalents? Selection rule is engine-side and UNVERIFIED (Z02 §4.4/Z08).
4. Does the `relief_stamps` opt-in path ever fire in a real session? It requires a dump
   dictionary on `game`; the live 3D bind path synthesizes one without the marker (§4.7).
5. What is the authoritative donor tile id → atlas cell → patch rule? The shader's id
   decomposition (`terrain_tileindex.gdshader:365-378`) is a derived stand-in.
6. How should 240² and 320² maps share donor frequencies? Port uses `size_mod=640/((W+H)/2)`
   (`pattern_gen.gd:562-589`) — donor multiplier UNVERIFIED.
7. Who owns the `world3d.gd` switch and the A/B capture? COORD/G04 per charter §4/§5.

---

## 12. Handoff summary (5 lines)

1. **Trace:** config/seed → `game.setup`/`main` stages → `mapgen.gd` mask height → `pattern_gen.gd` stamps → `_shape_stamp_relief` → clamp/collision → `_gen_patterns` → `_assign_tileblocks` → `world3d_terrain` dump/mesh → shader → water, all with exact file:line above.
2. **Writes:** sim owns `terrain/blocked/height/tileblock/mine_mask/res_nodes/maps`; renderer reads only `height`+`tileblock`; `terrain`/`blocked`/relief masks never cross the boundary.
3. **RNG:** five live streams (`rng`, mask `r`, pattern `rng`, `mine_rng`, tile `brng`) plus seed-derived `_hash2`; `gen_rng` reseeds are dead.
4. **Divergence:** donor smoothing/blend/tile-variety/relief-props/water bindings are PORT APPROX or UNVERIFIED; Y02 maze route is severed but the height→face→cliff-art route and Y08 flattening remain.
5. **Seam:** compose a fresh `terrain_donor_*.gd` behind a COORD-owned switch at `world3d.gd:609/642-645`, reusing the `world3d_relief.gd` sibling pattern; no edits to the six legacy pipeline files; no parity claim.

*End of P01. One report written. No source, shader, config, asset, test, git, donor, Godot or runner state changed. PORT APPROXIMATION / UNVERIFIED throughout; NO donor parity claim.*
