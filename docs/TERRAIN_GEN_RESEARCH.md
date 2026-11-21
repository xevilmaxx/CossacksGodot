# How Cossacks 3 actually generates a random map (research, 2026-11-21)

Sources, in order of authority:

1. **Donor plaintext scripts** (better than decompiling `cossacks.exe`):
   - `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc` (109 KB)
   - `...\common.inc\generatemap.inc` (52 KB) — relief/water from mask
   - `...\common.inc\initmapgen.inc` (13 KB) — players, seed
   - `...\common.inc\texturemap.inc` (49 KB) — shore/height thresholds
   - `...\common.inc\smoothtiles.inc`, `smoothforestborders.inc`, `postprocess.inc`
   - `C:\Games\Cossacks 3\data\game\var\generator.cfg` (70 KB) — TerrainTypes + Pattern families
2. Online: cossacks3.pl "How a Random Map Is Generated" (`mechaniki?doc=recon/world/map/map_generation_pipeline.md`),
   cossacksworld.ucoz.co.uk New Terrain Mod (NTM) / EMOM pages, Steam Workshop NTM.

## Pipeline (as read from the donor scripts)

1. **Seed** — `gMap.settings.gen.randkey1/2`; every later random call is `RandomExt`
   from that key. `initmapgen.inc:99,146` `SetRandomKey(randkey1)`.
2. **Clear** — `ClearMapMaskAndObjects()` zeroes `gPatternMask` and all objects;
   `MapDrawCollision` reset (`dogenerate.inc:444-481`).
3. **Relief from a hand-authored TGA mask** — `generator.cfg:2-28` maps
   TerrainTypes to `data/gen/terrainmasks/<type>` folders (nowater2, mediterranean,
   peninsulas, islands, continents, continent; DLC5 adds coastal, lakes, rivers).
   `generatemap.inc`: R = relief (255 plateau / 96 hill / 48 ravine), G = forest/stone,
   B = water, pure white = player-start marker. Height:
   `h = cWaterHeight * (b/255) * (1 + (r/255)*3.5) + relief(r)` with
   `cWaterHeight = -1.1`; water `< -0.25`, shore `< -0.1`; coastline smoothed 3 passes.
   This part is already ported in `app/scripts/mapgen.gd`.
4. **Start markers** become `arrStartPos[0..7]` on the mask; players pick the
   farthest/spread pair (`RandomStartingPoints`, `dogenerate.inc:1090-1229`;
   `CreateStartPoint(...)` at 980). Around each start, `SetupMines` and
   `SetupStartingResources` stamp the guaranteed resource rings.
5. **Everything else is STAMPED PATTERNS, not per-tile noise.** The unit of
   generation is a `.pattern` file: a small, hand-authored clump of trees / rocks /
   decor / mine props with its own footprint and collision. Placement is
   rejection sampling via `_misc_CheckStandPattern(Ext)` which checks the pattern
   footprint against water, rock, other patterns and the start exclusion zones:
   - `SetupTiles(freq)` `dogenerate.inc:499-519` — `needed = floor(mapW*mapH*freq)`,
     64 random attempts per placement, picks `tls_1..tls_4` (skips `tls_3`).
   - `SetupTiledPatterns(str)` `:1330-1359` — strict 25×25 cell grid, one pattern
     per cell (`d_tls_*` / biome tiled set). This is the base "cracked earth".
   - `SetupMines(pointx,pointy, minround,maxround, minesdensity, spcount)` `:522-717`
     — for each of 3 deposit kinds (patterns `mng`, `mni`, `mnc`; `desert_*` in
     desert) and 3–5 rounds, pick a random angle and a distance:
       gold ~14–22, iron ~32–42, coal ~70–82, extra rounds ~22–38 / 50–62,
       all in donor map units; 256 attempts each. `VectorRotateY` puts it on a ring.
   - `SetupStartingResources(pointx,pointy)` `:720-980` — guaranteed food rects,
     stone/forest rings, mines, farms inside `cCircle1Mask` around the start.
   - forest/stone/hill/decor families come from `generator.cfg:Patterns`:
     `forests_*` (big/med/small pine/fir/spruce/mixed/leaf), `stones`,
     `stoneforests`, `hills_dark/light`, `dcr1-3` decor, `mng/mni/mnc`,
     `desert_*`, swamp/lake/pump. Each has `Freq` weights; `_misc_GetPatternName`
     / `GetPatternNameByParser` pick by weight.
   - `FillOwnerMap` `:1370-1428` flood-fills from starts over `gScanGrid` to
     assign territory; `SetupBorderObjects` `:1430+` lines the borders with
     rocks/trees. This is why resources are clustered *per player side* rather
     than uniformly sprinkled.
6. **Finalize** — smooth forest borders, `postprocess.inc`, roads, balance.

## Consequences for our port

- Our `mapgen.gd` (mask → height/forest/starts) is faithful for stages 2–3.
- The macro layout (stage 4–5) currently uses **noise blobs** in
  `app/tools/gen_variant_maps.py` and the port's `game.gd:_generate_map`.
  Donor-faithful behaviour is **pattern stamping with rejection sampling** and
  per-family separation/claim rules, already sketched in GUIDE4 L3
  (`_claim_cluster`, paint-then-scatter, clear radius > paint radius).
- "Always clustered" in the original is a direct consequence of patterns being
  multi-object clumps. Do not replace them with uniform Poisson scattering.
- Full donor tile families are now converted into `app/assets/terrain/blocks/`:
  grass1..10, grass_ground1..3, ground1, grass_rock1, grass_sand1..2,
  rock1..9, sand1..9, sandsea1..6, sandrock1..6, desert1..12,
  **winter0..26** (added 2026-11-21, previously missing), test0..25.
  Donor water waves: `app/assets/terrain/water_png/diffusewaves0..7.png`.
  Donor field decals: `app/assets/terrain/deco_png/envfieldd|--w.png`.
- Online NTM notes confirm map-mask families (Lakes, Rivers, Coastal added by
  mod) and that vanilla "plain" still had hills generated on it — a known
  vanilla quirk the mod fixed.

## Open next step when a layout is chosen

Port the chosen layout recipe from `gen_variant_maps.py` into GDScript:
`app/scripts/mapgen.gd` (mask/height/forest/starts + stamped cluster list) and
`app/scripts/game.gd:_generate_map` (nodes with donor radii/hits), then render
with `app/scripts/world.gd` using the already-converted donor PNG families.
Keep `app/tools/gen_variant_maps.py` as the fast preview/iteration tool.
