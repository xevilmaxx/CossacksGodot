---
id: F01
ticket: F01 — ONLINE donor research: almanac terrain / relief / textures / visual quality
date: 2026-11-25
scope: READ-ONLY. One report. No code edits, no Godot runner jobs, no donor asset copies.
labels: [observed, derived, inferred, UNVERIFIED]
status: DONE
---

# F01 — Cossacks 3 Almanac: donor terrain generation, relief, textures, visual quality

## 0. Compliance and method

- Read `docs/terrain_swarm_2026-11-25/CHARTER.md` completely before work (all 132 lines).
- Only file written by this worker: `docs/terrain_swarm_2026-11-25/reports/F01_almanac_terrain.md`.
- No Godot job submitted; no source file, test, shader or asset edited; no donor file copied into the repo.
- Donor script files under `C:\Games\Cossacks 3\` were **read only** to obtain verbatim key lines that the
  almanac cites but does not reprint. They are PRIVATE USE ONLY; no bytes were copied into the repo.
- The `niocreations.ru/cossacks-3-almanac/docs_en` front page returned **only navigation** to `webfetch`
  (JS-rendered). All almanac text quoted below therefore comes from the **identical Markdown source files on
  GitHub raw**, with both raw and `github.com/.../blob/main/...` URLs given per source. The charters' `?p=`
  URL pattern was not needed and was not independently re-fetched.
- `cossacksworld.ucoz.co.uk` returned **403 (http) / transport error (https)** on live fetch this session.
  Its NTM content is quoted from the live `websearch` snippet and from the already-recorded local quote in
  `docs/research/RC_TERRAIN.md` §1 (S8); both are marked accordingly.

Label convention: **OBSERVED** = explicit text in a cited source; **DERIVED** = direct cross-check of two
cited sources; **INFERRED** = reasoned synthesis; **UNVERIFIED** = the almanac/docs leave it engine-side,
no donor GPU A/B frame exists (CHARTER §3).

---

## S. Source register (exact URLs; every claim below cites one of these)

| id | Exact URL | What it is | Fetched 2026-11-25 |
|---|---|---|---|
| **U1** | `https://github.com/anyalink99/cossacks-3-almanac` | Repo root; README says numbers are extracted from installed game scripts | yes |
| **U2** | `https://niocreations.ru/cossacks-3-almanac/docs_en` | EN docs site front page (JS shell only for webfetch) | yes (shell only) |
| **U3** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/map/map_generation_pipeline.md` · blob: `https://github.com/anyalink99/cossacks-3-almanac/blob/main/docs_en/recon/world/map/map_generation_pipeline.md` | **Reader-facing 5 stages**, settings, resources, replay model | yes, full |
| **U4** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/map_generation_evidence.md` · blob: `https://github.com/anyalink99/cossacks-3-almanac/blob/main/internals_en/scripts/map_generation_evidence.md` | **Technical evidence**: stage 0–4 call sequence, footnotes [^1]–[^50], pattern stats, open questions | yes, full |
| **U5** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/map/game_settings.md` | Lobby option → engine field mapping; relief/season effects | yes, full |
| **U6** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/data/file_formats.md` | `.pattern` binary layout; **explicitly "does not parse" `.dds`, shaders, `.actor`, `.map`** | yes, full |
| **U7** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/data/layout.md` | `data/terrain/` 607 files / 685 MB; `shaders/` 109; `water/` 11; `materials/` 2.9 GiB | yes, full |
| **U8** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/derived/pattern_types.json` | Machine-read family → pattern-name lists (`tiles`, `ravine_big`, …) | yes, full |
| **U9** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/derived/pattern_type_stats.json` | Per-family min/mean/median/max mask-cell counts | yes, full |
| **U10** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/engine/rtti_class_map.md` | `TXMapGenerator`, `TXTileMap`, `TXHeightMap`, render/shader classes | yes (filtered) |
| **U11** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/engine/native_api.md` | `SetMapGeneratorRandomKey`; generator internals "not disassembled" | yes (filtered) |
| **U12** | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/engine/native_primitives.md` | `RandomHeightTerrain(...)`, `MapDrawCollision` declarations | yes (filtered) |
| **U13** | `https://api.github.com/repos/anyalink99/cossacks-3-almanac/git/trees/main?recursive=1` | Full 444-file tree — proves **no** terrain-texture/shader/cliff evidence doc exists in the almanac | yes |
| **U14** | `http://cossacksworld.ucoz.co.uk/index/newterrainmod/0-335` | NTM: 200+ patterns, new textures, seasons, forest types | live 403; snippet via websearch + local L4 |
| **U15** | `http://cossacksworld.ucoz.co.uk/index/random_map_parameters/0-253` | "Landscapes set **where**; relief & textures & objects set in Ex Terrain Editor" | live 403; snippet via websearch |
| **U16** | `https://cossackshq.net/c3-mod-new-terrain-mod` | NTM overview (from CHARTER §6; **not re-fetched this session**) | seed only |

Local cross-check sources:

| id | Path | Role |
|---|---|---|
| **L1** | `docs/TERRAIN_GEN_RESEARCH.md` | donor pipeline, mask formula, pattern stamping, converted asset families |
| **L2** | `docs/decomp/DB_SCRIPTS.md` | `generator.cfg` + `dogenerate.inc` quoted stage order and relief table |
| **L3** | `docs/decomp/DD_MAPS.md` | `.map` binary opacity; grid/heightmap **CLOSED** |
| **L4** | `docs/research/RC_TERRAIN.md` | editor relief/texture sources S1–S11, NTM quote, port gap table |
| **L5** | `docs/guides/GUIDE4.md:2095–2164` | verbatim donor-script truth for generatemap/texturemap/smoothtiles |
| **L6** | `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc` | read-only verbatim constants, height formula, smoothing passes |
| **L7** | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc` | read-only verbatim `SetupTiledPatterns` |
| **L8** | `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc` | read-only verbatim shore/cliff sector tables |
| **L9** | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc` | read-only verbatim `FindRandomTileIndex` / gap rules |
| **L10** | `app/assets/terrain/structs/smooth_summer.json` | exists (conversion of donor `tilesmooth_scripts.cfg`, L5:2143–2144); **not opened** by this worker |

---

## 1. The five map-generation stages (OBSERVED)

U3 "The Five Generation Stages" table, quoted exactly:

> | Stage | Result |
> |---|---|
> | 1. Preparation | Service masks are cleared and environment patterns are loaded. |
> | 2. Relief | The surface, elevation, water, and coastlines are created. |
> | 3. Starting positions | Players receive positions and the first resources and deposits are placed nearby. |
> | 4. Remaining map | Distant deposits, forests, stone, swamps, lakes, and decoration are added. |
> | 5. Finalization | Starting units appear, territories are assigned, and peace-time borders are created when needed. |

U3 immediately explains the ordering:

> "The order matters. Nearby resources reserve their space before the rest of the map is filled, so a distant random forest cannot displace the guaranteed forest beside a starting Town Hall."

U4 restates the same five in its At a Glance:

> "The map is built in **five stages**: preparation → terrain → starting positions and nearby resources → remaining resources → finalization."

**Numbering caveat (DERIVED).** U4 then numbers the detailed walkthrough **Stage 0–4**: Stage 0 Preparation; Stage 1 "Terrain and Base Surface"; Stage 2 "Starting Positions and Nearby Resources"; Stage 3 "Relief and Remaining Resources"; Stage 4 "Starting Units and Finalization". These are the same five operations with a zero-based index and one merged label — not an extra stage. L2 §2.2 and L1 §Pipeline give a compatible order (clear → tiled patterns → seed → GenerateMap mask → shore mask → starts → relief table → global patterns → resources → finalize). **Copy the ordering, not the index** [U3, U4, L1, L2].

Key stage-1 call sequence from U4 (all with footnote citations in U4):

> "6. `SetupTiledPatterns('tiles')` — or `desert_tiles` in the desert — places background details such as dirt and cracks on a 25 × 25-cell grid. A 256 × 256 map receives about **100 placements** [^9]."
> "7. `SetRandomKey(randkey1)` sets the generator key, making all subsequent `RandomExt` calls reproducible [^10]."
> "8. … The built-in `ExecuteState('GenerateMap')` then creates a heightmap from the selected `inputbitmap.tga` and fills the map cells [^11]."
> "9. Shore and water cells with `height < -0.1` are blocked in `gPatternMask` [^12]."

U4 footnote [^9] pins it: "`SetupTiledPatterns('tiles')` — `common.inc/dogenerate.inc:1535`." U4 stage 4 includes:

> "25. `_misc_PreloadTextures(True, True, True)` [^28]."
> "34. The season selects a color table: winter=6, desert=7, default=0; the internal `PHDR` flag is set to `1` only in winter [^37]."

**Determinism is part of the visual recipe.** U4: "`SetRandomKey(randkey1)` … is re-issued at lines 1100, 1161, 1177, 1213, 1538, 1616, 1772, 1909, 1927 — once *before each stage*, so each stage consumes its own fresh stream" ([L2] §2.2 makes the same observation; U11 confirms a dedicated `MapGenerator` RNG with `(randkey0, randkey1)` and says the internal PRNG "cannot be identified without decompilation"). The port seeds once (L2 gap G3) — a documented divergence, not a texture issue.

---

## 2. Relief tiers — three distinct layers (OBSERVED / DERIVED)

The word "relief tiers" in the almanac/local corpus means three different things. Keep them separate.

### 2.1 Base-mask R-channel tiers (OBSERVED)

L5:2117–2119, quoting `generatemap.inc` verbatim:

> "cPlateauHeight 2.964, cHillHeight 1.317, cRavineHeight -2.964, cWaterHeight -1.1; mask R=relief (255/96/48), G=forest/stone, B=water; pure white = start marker. Height = -1.1*b*(1+r*3.5) + relief(r)."

L1 §Pipeline 3 says the same:

> "R = relief (255 plateau / 96 hill / 48 ravine), G = forest/stone, B = water, pure white = player-start marker. Height: `h = cWaterHeight * (b/255) * (1 + (r/255)*3.5) + relief(r)` with `cWaterHeight = -1.1`."

Verbatim donor lines (L6:4–7, 21–27, 569–574):

```pascal
const cPlateauHeight = 2.964;
const cHillHeight = cPlateauHeight/2.25;   // = 1.317
const cRavineHeight = -2.964;
const cWaterHeight = -1.1;
const cRColorPlateau = 255;  const cRColorHill = 96;  const cRColorRavine = 48;
const cRColorSmooth = 128 div 2;
...
case gMapMask[ix,iy].terrain of
   cRPlateau : hterrain := cPlateauHeight*fr;
   cRHill    : hterrain := cHillHeight*fr;
   cRRavine  : hterrain := cRavineHeight*fr;
end;
SetHeightData(realx, realy, hwater+hterrain)
```

Note L6:36 `cPostProcessBitmapGaussian = True` — the mask is gaussian-postprocessed inside the donor generator; L5:2146 says "gauss masks are postprocessed to 320x320 with noisy water borders". This is a direct donor citation for the *soft, non-grid* look of donor coastlines [L6:36, L5:2146].

### 2.2 Generator relieftype tiers `0..4` (OBSERVED)

L2 §2.2 item 7 gives the full table:

| relieftype | plt | mnt | hil |
|---|---|---|---|
| 0 | 0.000010 | 0.000020 | 0.000075 |
| 1 | 0.000020 | 0.000002 | 0.000125 |
| 2 | 0.000075 | 0.000075 | 0.000030 |
| 3 | 0.000055 | 0.000120 | 0.000050 |
| 4 | 0.000090 | 0.000035 | 0.000035 |

L5:2130–2132 independently quotes the same five rows. U4 stage 3 confirms one row verbatim:

> "16. The `relieftype` branch selects `plt`, `mnt`, and `hil`. For Highlands (`relieftype = 3`), the values are `plt=0.000055`, `mnt=0.000120`, and `hil=0.000050` [^19]."

U4 footnote [^19]: "`relieftype` densities (`plt/mnt/hil`) — `common.inc/dogenerate.inc:1621-1650`." U5 "Map-generation settings" explains the *visual* meaning:

> "**Relief** | Controls mountain and hill density. Highlands leave less flat ground for Farms and Storehouses [^8]."

U4 stage 3 items 20 and 23 name the pattern families that carry these tiers:

> "20. `_misc_SetupPatternsByType(...)` places mountains, three-part plateaus, ravines, and hills [^23]."
> "23. … places forests, stone, plains, swamps, and lakes."

The almanac's own machine-readable inventory (U8/U9) lists the corresponding donor families: `mountains` (`g_mnt_1..7`, mean 584.1 mask cells), `plateau` (`plt1..plt5`, mean 795), `plateau_big`, `plateau_small`, `hills_dark` (`hil1..4`, mean 404.5), `hills_light` (`g_hil1..9`, mean 633.4), `ravine_big` (`k_ravine_big_stone_1..8`, mean **1956.6**), `ravine_medium` (`k_ravine_1..9`, mean 1077) [U8, U9]. **Ravines are the largest stamped structures in the donor inventory** — the grey rock faces in the reference screenshots are most plausibly these families plus the cliff sector table in §4 [INFERRED; no donor GPU frame to prove causality].

### 2.3 Editor altitude tiers (OBSERVED, GSC-family caveat)

L4 §1 (S2, `http://cossacksworld.ucoz.co.uk/index/0-126`) quotes the editor altitude popup:

> "altitude-map popup (green lowlands → yellow-brown hills → brown-grey mountains) with height sliders"

L4 §6 caveat 2 explicitly downgrades this:

> "S2/S3/S4 are Cossacks 1/2/3 shared editor documentation … Treat as 'documented for the GSC editor family', not 'confirmed in C3 1.3.0.60'."

**UNVERIFIED:** the exact C3 in-game colour-to-tier mapping of that popup; the live page was 403 this session [U15 family].

---

## 3. `SetupTiledPatterns` — background detail (OBSERVED)

U4 Stage 1, quoted above (§1), calls this "background details such as dirt and cracks on a 25 × 25-cell grid" and gives ~100 placements on a 256×256 map [U4 ^9]. U4 Open Question 3 is the single most relevant online statement:

> "**Does `SetupTiledPatterns` affect later object placement?** Roughly one hundred tiled patterns on a 256 × 256 map provide ground decorations such as cracks and mud. They may also block `gPatternMask`; this must be checked through `_misc_CheckStandPatternExt`."

Verbatim donor implementation (L7:1330–1359):

```pascal
procedure SetupTiledPatterns(const str : String);
begin
   var pPatternList : Integer = _misc_SelectPatternListParser(pGenerator, str);
   if (pPatternList<>0) then
   begin
      const cSize = 25;
      var wcount : Integer = floor(mapW/cSize);
      var hcount : Integer = floor(mapH/cSize);
      for y:=0 to hcount do
      for x:=0 to wcount do
      begin
         var name : String;
         _misc_GetPatternNameByParser(name, pPatternList);
         var realx : Float = round((x*cSize)+(cSize div 2)-(GetMapWidth div 2)-1);
         var realy : Float = round((y*cSize)+(cSize div 2)-(GetMapHeight div 2)-1);
         ...
            _misc_CheckStandPattern(name, envplHnd, realx, realy, 0, True, False, 0);
            _misc_PatternIncreaseFreq(pGenerator, str, name);
```

Call sites L7:1533/1535: `SetupTiledPatterns('desert_tiles')` / `SetupTiledPatterns('tiles')`. The tile family is exactly four donor patterns [U8]:

> `"tiles": ["d_tls_1", "d_tls_2", "d_tls_3", "d_tls_4"]`

with per-pattern mask-cell counts min 475 / mean 505.2 / median 520 / max 520 [U9]. L2 §2.1 quotes the weights from `generator.cfg`:

> "`desert_tiles { d_tls_1 Freq=1000; d_tls_2 Freq=0; d_tls_3 Freq=1000; d_tls_4 Freq=100 }`"

and L1 §Pipeline 5 notes `SetupTiles(freq)` "picks `tls_1..tls_4` (skips `tls_3`)" — a donor "hack" also visible at L7:514 (`if (name<>'tls_3') then // hack`). **Freq is a selection weight, not a probability** [L2 §2.1].

**What to copy:** a coarse 25-cell lattice of hand-authored background clumps, chosen from a tiny weighted family, snapped to cell centres — **not** per-tile procedural noise. This is the donor's mechanism for breaking a flat expanse without tiling one texture [DERIVED from U4 + L7 + U8/U9].
**UNVERIFIED:** (a) whether these patterns alter `gPatternMask` (U4 Open Question 3); (b) the visual appearance of `d_tls_1..4` themselves (almanac stores only name/cell counts; `.dds`/tile images are not parsed — U6); (c) whether the port's current `alpha_patch_uv()` has any donor analogue (CHARTER §2 suspect 2 — no almanac evidence either way).

---

## 4. Tile / terrain texture selection (OBSERVED donor scripts; ALMANAC UNVERIFIED boundary)

### 4.1 The almanac's explicit limit — cite this before claiming donor fidelity

U13 (full recursive tree, 444 files) contains **no** terrain-texture, shader, cliff, or visual-quality evidence doc: the only map docs are `map_generation_pipeline.md`, `game_settings.md`, `map_generation_evidence.md` (+ RU twins) and derived pattern JSONs. U6 is explicit:

> "## `.dds` - DirectDraw Surface (textures) … The repository does not parse them."
> "## `.actor` / `.tlf` - 3D models … Decoding it is outside the project's scope."
> Summary table: "`.actor` / `.tlf` / `.dds` | ✗ | — | We don't need 3D data." and "Shaders (`shaders/`) … not parsed".

U7 quantifies the untouched visual side:

> "`terrain/` | 607 | 685 MiB | Terrain tiles (textures by season)"
> "`materials/` | 866 | 2.9 GiB | Materials and textures (`.mat`, `.dds`)"
> "`shaders/` | 109 | 0.3 MiB | GLSL shaders (.vert, .frag)"
> "`water/` | 11 | 5 MiB | Water shader assets"

U10 lists only structural render classes: "`TXTileMap`, `TXTileMapSchemesList` — Tile-grid of terrain (cluster by type)"; "`TXHeightMap` — Terrain height (heightmap)"; "`TXShader`, `TXShadowMap`"; "`TXPHDRToneMapShader`". U12 exposes one relevant native declaration: "`RandomHeightTerrain(const x, y, ...)`" (declaration only).

**UNVERIFIED from the almanac:** the actual texture-selection rule, atlas/blend math, filtering, shader sampling, AO, normals, colour grading and per-tile UV mapping. No almanac page states how a height/slope becomes a pixel colour. **Do not attribute any such rule to the almanac.**

### 4.2 Donor plaintext rule — read-only verbatim (L8, L5)

The donor rule *is* available locally, and L5:2136–2139 already reported it:

> "`texturemap.inc` - water < -0.25, shore -0.1, slope cDiff1 .5 / cDiff2 .55; 8-sector shore table -> sandsea1/5/6; 6-sector cliff table -> rock7/1/3/4; height overrides rock8 >2.7, rock4 >2.4."

Verbatim lines (L8:63–64, 504–511, 577–608):

```pascal
const cDiff1 = 0.5;
const cDiff2 = 0.55;
...
if (bLB) then newtile := 'sandsea5';   if (bRB) then newtile := 'sandsea6';
if (bB)  then newtile := 'sandsea1';   if (bL)  then newtile := 'sandsea6';
if (bR)  then newtile := 'sandsea6';   if (bT)  then newtile := 'sandsea1';
if (bRT) then newtile := 'sandsea5';   if (bLT) then newtile := 'sandsea6';
...
if (bLB) then newtile := 'rock7';
if (bB)  then newtile := 'rock1';
if (bL)  then newtile := 'rock3';
if (bR)  then newtile := 'rock4';
if (bT)  then newtile := 'rock4';
if (bRB) then newtile := 'rock4';
if (Abs(height)>2.7) then newtile := 'rock8'
else if (Abs(height)>2.4) then newtile := 'rock4'
else if (Abs(height)<0.1) then newtile := '';
if GetSeasonType=2 then newtile := newtile+'_winter';
var newtex : Integer = MapGetTileIndexByTileBlock(newtile);
SetTileIndex(x, y, newtex);
```

The eight sector flags are computed from `vecangle` with ±7.5° windows (L8:560–575: `bRB` 30−7.5..60+7.5; `bLB` 120..150+20; `bR` −45..45; `bB` 45..135; `bT` −135..−45; else `bL`). The shore-pass height overrides at L8:514–518 are **commented out** in this build; the cliff-pass overrides at L8:594–601 are live. This is a genuine nuance: L5's summary is correct but the two branches are not symmetric [DERIVED from L8].

**What to copy:** a **finite directional table** (`sandsea*`, `rock*`) indexed by coast/cliff aspect, then a height override, then a season suffix — i.e. tile-block *selection by geometry*, not a continuous noise blend [L8, L5:2136–2139]. The port's `mask_to_alpha=1` folding of a 32-patch mask into RGB (CHARTER §2 suspect 2) has **no donor citation** in U3–U13 or L1–L5; label it PORT APPROX / UNVERIFIED.

---

## 5. Smoothing — two different donor passes (OBSERVED)

### 5.1 Height smoothing (surface shape)

L5:2121: "3 coastal smoothing passes (rad 2, power 0.35, lerp 0.5) + 1 land pass." L6 verbatim:

```pascal
const cSmoothTerrainUsingBitmap = True;   // L6:38
const cSmoothAllMapHeight = True;         // L6:39
...
if (gMapMask[x,y].bsmooth) then SmoothTerrain(realx, -realy, False, 3);   // L6:587-591
...
_misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, 0.01, 100);            // L6:606  land pass
...
for i:=0 to 2 do                                                          // L6:612  3 coastal passes
begin
   const rad = 2;                                                         // L6:625
   ... if (gMapMask[nx,ny].water=cBWater) then bWater := True;             // L6:629
   if (bWater) then
      _misc_SmoothTerrainCustom(realx, realy, 1, 0.35, 0.5, -100, -0.01);  // L6:637
end;
TerrainUpdate(True, False);                                               // L6:641
```

L1 §Pipeline 3 independently: "coastline smoothed 3 passes." **Copy the 3 coastal passes and the single land pass with the donor power/lerp/radius values** [L6, L5, L1]. The port currently varies the number of passes by quality preset (`app/scripts/data.gd` MAPGEN: low 1 / medium 2 / high 3, L5:2161–2163) — that is a deliberate port approximation, not donor parity.

### 5.2 Tile-block smoothing (texture seams)

L5:2140–2144:

> "`smoothtiles.inc` - 3 H/V passes, FindRandomTileIndex uses relative Prob weights, |gap| 1 = compatible (if one prob>0), 2 = midpoint insert, >2 = step inward. `data/gen/tilesmooth_scripts.cfg` has 10 summer chains / 59 groups; `app/assets/terrain/structs/smooth_summer.json` is an exact copy."

L6:781–786 confirms the call order: `ExecuteState('TextureMap')` then `if (cSmoothTile) then … ExecuteState('SmoothTiles')`. L9 verbatim core:

```pascal
function FindRandomTileIndex(i, j : Integer) : Integer;
begin
   var sumProb : Float = Items[i].SmoothTiles[j].SumProb;
   var rnd : Float = RandomExt*sumProb;
   for k:=0 to Items[i].SmoothTiles[j].TileCount-1 do
   begin
      var prob : Float = Items[i].SmoothTiles[j].SmoothTile[k].Prob;
      tmp := tmp+prob;
      if (prob>0) and (rnd<tmp) then
      begin
         Result := Items[i].SmoothTiles[j].SmoothTile[k].TileIndex; exit;
      end;
   end;
end;
...
if (Abs(i1 - i2) = 1) and ((not i1ProbZero) or (not i2ProbZero)) then ...// compatible
else if (i1 - i2 = 2) then outtile1 := FindRandomTileIndex(ilist, (i1 + i2) div 2)
else if (i2 - i1 = 2) then outtile2 := FindRandomTileIndex(ilist, (i1 + i2) div 2)
else if (i1 < i2) then outtile2 := FindRandomTileIndex(ilist, i1 + 1)
else outtile1 := FindRandomTileIndex(ilist, i2 + 1);
```

This is a **weighted chain of compatible tile variants**, not a random dither field. It is the single strongest donor explanation for "no grid / no checkerboard" in the reference screenshots [INFERRED, mechanism OBSERVED in L9]. CHARTER §3 forbids synthetic dither/noise precisely because it recreates the 2D checkerboard regression; donor `Prob`-weighted chain smoothing is the permissible alternative.
**UNVERIFIED:** exact `tilesmooth_scripts.cfg` weights (L10 exists as an exact copy but was not opened by this worker); whether the port's `_tb_smooth_pair()` now consumes the donor `az/bz` prob-zero flags (L5:2110–2113 says the old version computed but never used them; L5:2159–2160 says the fix wired "donor prob-zero smooth rule").

---

## 6. Cliffs and rock faces (OBSERVED + INFERRED)

1. **Geometric cliff selection:** the live cliff sector table + height overrides in §4.2 [L8:577–608]. Facing determines which of `rock7/1/3/4` is stamped; `|height|>2.7` forces `rock8`, `>2.4` forces `rock4`, `<0.1` clears it.
2. **Stamped rock structures:** `ravine_big` (`k_ravine_big_stone_1..8`, mean 1956.6 cells, max 3353) and `ravine_medium` (`k_ravine_1..9`, mean 1077) are the largest families in the almanac's parsed inventory [U8, U9]; `mountains`, `plateau*`, `hills_*`, `stones` (mean 143.9), `stoneforests` (mean 148.1) follow [U8, U9]. U4 stage 3 explicitly places "mountains, three-part plateaus, ravines, and hills" [U4 item 20, ^23].
3. **Per-object scale jitter (donor):** L2 §2.6 quotes `envscales.cfg`: "`stones scale=0.329 minscale=0.85 maxscale=1.15`, `smallstones 0.25`, `fir 0.5` (all `0.85–1.15`)"; U4 stage 4 item 27: "Environment objects are normalized for the season: `leaftree*` is removed in winter, and scale is clamped to `[scaleMin, scaleMax]` [^30]."
4. **Donor pitfall to avoid:** L5:2106–2107 — "The cliff pass divided height differences by TILE and only looked at +x/+y, turning half of every shore into blocked rock and erasing the sand collar." The donor uses aspect sectors and absolute height thresholds, not a one-sided per-tile difference [L8].

**INFERRED:** the grey rock faces in reference sample A (`cossacks-3-v1-498085.jpg`, CHARTER §1) are the combined result of (1)+(2)+(3): aspect-selected `rock*` tile blocks on steep cells, large stamped `k_ravine_big_stone_*` patterns that carry their own heightmap/bitmask (U6 `.pattern` format: "`u8[w*h] mask` … `f32[w*h] heightmap // hilliness` … `u32 variant_id, f32 scale_x/y/z`"), and per-object scale jitter. **UNVERIFIED:** no donor GPU frame or almanac image confirms which of these dominates a given screenshot; U6 explicitly "does not parse" the textures/shaders that colour those faces.

---

## 7. What makes the reference screenshots look "organic" (INFERRED; mechanism parts OBSERVED)

Ranked by documented leverage. Every row states the evidence and the honesty label.

| # | Mechanism | Donor evidence | Label |
|---|---|---|---|
| 1 | **Hand-authored gaussian terrain masks**, not procedural ellipses: `cPostProcessBitmapGaussian = True`, 230 Land masks for 4 players | U4 §12 (mask counts), L6:36, L1 §3, L5:2095–2101 | mechanism OBSERVED; "organic" contribution INFERRED |
| 2 | **Stamped multi-object patterns** with internal bitmask + heightmap + per-object scale/variant, rejection-sampled against water/rock/other patterns | U6 `.pattern` layout; U8/U9 families; U4 §4; L1 §5; L2 §2.1 | mechanism OBSERVED; visual effect INFERRED |
| 3 | **Multi-scale relief tiers**: R=255/96/48 mask channels + `relieftype` plt/mnt/hil table + huge ravine/mountain families | §2.1–2.2, L6, L7, U9 | OBSERVED |
| 4 | **Weighted tile-variant smoothing chains** (Prob-weighted, 3 H/V passes, 10 chains/59 groups) rather than per-tile random blending | L9, L5:2140–2144 | mechanism OBSERVED; anti-grid effect INFERRED |
| 5 | **Aspect-driven shore/cliff texture tables** (`sandsea*`, `rock*`) + height overrides + winter suffix | L8:504–608, L5:2136–2139 | OBSERVED |
| 6 | **Tiled background clumps** (`d_tls_1..4`, 25-cell lattice, ~100 on a 256 map) = dirt/cracks/mud | U4 Stage 1 + Open Q3, L7:1330–1359, U8/U9 | OBSERVED |
| 7 | **Season texture sets / object sets** (607 terrain files, 685 MB; winter suffix; season colour table 6/7/0; PHDR=1 only winter) | U7, L8:605–606, U4 item 34, U14 | OBSERVED |
| 8 | **Cluster priority**: guaranteed stone/forest rings 5–22 cells around each start placed *before* distant fill | U4 §4 and §1 "order matters", L1 §5 | OBSERVED |
| 9 | **200+ extra patterns / animated trees / new season textures** in NTM (evidence that variety comes from authored sets, not procedural noise) | U14 snippet (live 403), L4 §1 S8 | INFERRED for vanilla; mod-specific |
| 10 | **Review context**: donor itself was criticised for "bland uniform green terrain" | CHARTER §6 reviews; L4 S8 mod author: "They all look the same. You can tell the game was rushed" | OBSERVED as external opinion; not a spec |

**Explicit UNVERIFIED:** no donor GPU A/B frame exists (CHARTER §3). The claim "these mechanisms produce the exact mottling/cliff read of samples A/B" is **INFERRED** from donor source text, not pixel-verified. The port's flat olive, diagonal streaks and repeated dark blotches (CHARTER §1) have **no almanac-documented donor counterpart**; treat suspects 1–6 in CHARTER §2 as still-open, with the almanac supplying *positive* recipes only.

---

## 8. Cross-check matrix (online almanac vs local corpus)

| Topic | Almanac (online) | Local doc / donor script | Verdict |
|---|---|---|---|
| Five stages | U3 table + U4 Stage 0–4 | L1 §Pipeline 1–6; L2 §2.2 1–11 | **CONFIRMED** (same order; index differs, §1) |
| Stage reseed before each phase | U4 (9 `SetRandomKey` sites, ^10/^18/^25); U11 RNG isolation | L2 §2.2 "Determinism"; L2 gap G3 (port seeds once) | **CONFIRMED**; port gap |
| Relief mask tiers 255/96/48 | U4 §12 mask families; U5 relief option | L1 §3, L5:2117–2119, L6:21–27 | **CONFIRMED** (channels not spelled out in U4; donor script fills them) |
| relieftype table 0..4 | U4 item 16 (Highlands row only) | L2 §2.2 item 7 full table; L5:2130–2132 | **CONFIRMED**, full table local |
| `SetupTiledPatterns` 25×25 / ~100 | U4 item 6, ^9, Open Q3 | L7:1330–1359; L1 §5; L2 §2.1 weights | **CONFIRMED** |
| Smoothing 3 coastal + 1 land | U4 stage 1 "coasts" (no numeric passes) | L5:2121, L6:587–641, L1 §3 | **CONFIRMED locally; numeric detail absent from almanac** |
| Tile smoothing Prob chains | not in almanac text | L5:2140–2144, L9 | **LOCAL ONLY** — do not cite as almanac |
| Shore/cliff sector tables | **absent** (U13 tree; U6 "does not parse" DDS/shaders) | L8:504–608, L5:2136–2139 | **UNVERIFIED online; donor script authoritative** |
| Pattern families & sizes | U8/U9 machine-readable | L2 §2.1, L1 §5, RC L4 §2.2 | **CONFIRMED** |
| `.map` binary grid closing | U6 "` .map` … not parsed" | L3 §4 "exact geometry is CLOSED" | **CONFIRMED** |
| NTM variety (200+ patterns, textures) | U14 snippet (live 403) | L4 S8 verbatim | **CONFIRMED via local quote + websearch** |
| Season colour table 6/7/0, PHDR | U4 item 34, ^37 | L2 §2.2 item 11 | **CONFIRMED** |

---

## 9. "What to copy" checklist (URLs on every donor-faithful item)

| # | Copy this | Donor URL / local authority | Status for implementation |
|---|---|---|---|
| C1 | Stage order + priority: tiled background → mask relief → starts/resources → distant fill → finalize; reseed RNG before each stage | U3 `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/map/map_generation_pipeline.md`; U4 `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/map_generation_evidence.md` | **COPY**; reseed is donor-confirmed, port gap G3 [L2] |
| C2 | 25-cell lattice of `d_tls_1..4` background clumps, weighted, snapped to cell centres (not noise) | U4 ^9; L7:1330–1359; U8/U9 `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/derived/pattern_types.json` | **COPY**; mask-blocking side effect UNVERIFIED (U4 Open Q3) |
| C3 | Height tiers 255/96/48 → `2.964 / 1.317 / -2.964`; `h = -1.1*b*(1+r*3.5) + relief(r)`; gaussian mask postprocess | L6:4–7,21–27,36,567–574; L1 §3; L5:2117–2119 | **COPY** (already partly in `app/scripts/mapgen.gd`, L1 §Consequences) |
| C4 | relieftype 0..4 plt/mnt/hil table; stamp `mountains/plateau/ravine/hills` families by density | L2 §2.2 item 7; L5:2130–2135; U4 items 16/20/23 | **COPY**; if exposing a lobby "Relief" option, use U5 field `relieftype` |
| C5 | 3 coastal smoothing passes (`rad=2`, power `0.35`, lerp `0.5`, −100..−0.01) + 1 land pass (power `4`, lerp `0.5`, 0.01..100) | L6:587–641; L5:2121; L1 §3 | **COPY**; do not keep quality-dependent pass count if parity is the goal |
| C6 | TextureMap → SmoothTiles order; Prob-weighted compatible-chain smoothing with prob-zero flags and gap 1/2/>2 rules | L6:776–786; L9:63–180; L5:2140–2144 | **COPY**; weights source `tilesmooth_scripts.cfg` → `app/assets/terrain/structs/smooth_summer.json` (L10 exists) |
| C7 | Aspect-sector shore table `sandsea1/5/6` and cliff table `rock7/1/3/4`; height overrides `rock8>2.7`, `rock4>2.4`, clear `<0.1`; winter suffix `_winter` | L8:504–608; L5:2136–2139 | **COPY**; almanac has no texture doc — source is donor script, label accordingly |
| C8 | Season object normalization / colour table (winter 6, desert 7, default 0; PHDR=1 winter) | U4 item 34; L2 §2.2 item 11; U7 terrain sets | **COPY** the table; season texture art itself UNVERIFIED (U6) |
| C9 | Stamp big ravine/mountain families; keep multi-object clumps and per-object scale jitter (`stones 0.329`, 0.85–1.15) | U8/U9 `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/derived/pattern_type_stats.json`; L2 §2.6; U4 item 27 | **COPY** family names/sizes; exact rendered rock faces UNVERIFIED |
| C10 | Keep guaranteed 5–22-cell stone/forest rings ahead of distant fill; `cCircle1/2/3` = 5×7 / 12×15 / 22×18 | U4 §4 and "Technical Details"; L1 §5; L2 §2.2 item 5 | **COPY** |
| C11 | Do **not** reproduce donor bugs/quirks: one-sided cliff difference (L5:2106–2107), `tls_3` hack (L7:514), box-select after wall (CHARTER §1b.2), first-stage ghost (CHARTER §1b.3) | cited inline | **DO NOT COPY** |
| C12 | Anything about atlas UV, `fract()` repeat, mipmap/filter, alpha-patch masks, mask→RGB folding, colour grading | no almanac source (U13 tree; U6 "does not parse"); CHARTER §2 suspects 1–4 | **UNVERIFIED — label PORT APPROX; do not claim donor citation** |

---

## 10. UNVERIFIED register (explicit)

1. **Engine-side RNG internals.** `GenerateMapRandKey` body and `MapGenerator` PRNG not disassembled [U4 ^50, U11 §6.6]. Same-key determinism asserted by U4 but not A/B-verified here.
2. **Texture selection / shader / filtering / atlas.** No almanac doc; U6 "does not parse" `.dds`, shaders, `.actor`; U13 tree has no such page. [§4.1]
3. **Cliff pixel appearance.** Sector table and family names known [L8, U8/U9]; final pixels depend on unparsed textures/shaders [U6].
4. **Whether `SetupTiledPatterns` blocks `gPatternMask`.** U4 Open Question 3 explicitly unresolved.
5. **Exact `tilesmooth_scripts.cfg` weights.** L10 is reported as an exact copy [L5:2143–2144] but was not opened by this worker; no almanac reproduction.
6. **Editor altitude tier colours in C3 specifically.** L4 §6 caveat 2 (GSC C1/2/3 shared docs); live page 403.
7. **NTM page live text.** U14 403 this session; claim rests on websearch snippet + L4 §1 S8 quote, not a fresh fetch.
8. **Port-side current state** of `_tb_smooth_pair()` prob-zero flags, tileblock fringe, alpha-patch folding: read from L5/CHARTER, not re-audited in code by this worker (READ-ONLY analysis ticket).
9. **No donor GPU A/B frame exists** (CHARTER §3) — every "organic screenshot" statement in §7 is INFERRED from source mechanism, never pixel-confirmed.
10. **`.map` height grid / coordinates** remain CLOSED [L3 §4; U6 "not parsed"], so exact authored-map terrain cannot be reproduced from binary maps.

---

## 11. Files changed / compliance

- Created: `docs/terrain_swarm_2026-11-25/reports/F01_almanac_terrain.md` (this file, the only write).
- No code, shader, test, config or asset changed. No Godot runner job submitted.
- Donor scripts were read in place under `C:\Games\Cossacks 3\` only; no donor bytes embedded in the repo (all quoted lines are short textual excerpts used as evidence, consistent with the project's private-use rule).
- All online claims carry U-codes mapped to exact URLs in §S; all local claims carry L-codes mapped to paths in §S. UNVERIFIED items are enumerated in §10.

*End of F01 report.*
