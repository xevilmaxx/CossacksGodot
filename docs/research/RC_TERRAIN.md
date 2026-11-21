# RC_TERRAIN — donor map/terrain/generator feature gap analysis

Research agent RC (Research lane, `SWARM_OPS.md` §5b). Date 2026-11-21.
Research + documentation only: no Godot runs, no game-code edits, no donor assets
copied. This is the ONLY file written by this agent.

Scope: find map/terrain/generator features the port may miss, using public
sources plus read-only inspection of the port. "Port" below means the current
working tree, not the older snapshot described in GUIDE4 (the port has since
gained `C3MapGen` donor-mask sampling — see `app/scripts/MAPGEN_STATUS.md`).

---

## 1. Sources used

Public web sources (all fetched 2026-11-21):

| # | URL | What it supplied | Reliability |
|---|-----|------------------|-------------|
| S1 | https://cossacks3.fandom.com/wiki/Editor | Standalone Steam "Launch Game Editor"; default map size 256, editor range 192..1024 square; snow tool; Layer→Terrain / brush / factor; Advanced→Players; Ctrl+W peace time, Ctrl+F fog; **in-menu editor "largely non-functional"** | Direct wiki text; sparse |
| S2 | http://cossacksworld.ucoz.co.uk/index/0-126 | **Relief Editing** full tool list: raise-hills brush (L raise / R lower, drag = ridge/ravine), flat-summit elevation mode, area levelling (R adds irregularity), smoothing (R creates ledges), polygon select with **Cubic / Squad / Smooth / Road1 / Road2 / Road3**, altitude-map popup (green lowlands → yellow-brown hills → brown-grey mountains) with height sliders | GSC editor manual mirrored for C1/2/3 (see §6 caveat) |
| S3 | http://cossacksworld.ucoz.co.uk/index/0-125 | **Creating Landscapes**: relief-generation window, 3-channel BMP import (contours grey / rivers blue / trees green) via `UserTerrain`, hills white, water blue, slopes red, forest green specks + density, hill-height brush, Generate | Same caveat as S2 |
| S4 | http://cossacksworld.ucoz.co.uk/index/texturing/0-127 (served "Water Editing") | **Water Editing**: draw/remove water, brush size + surface-line width, sunlight glints + glint deletion, **current/direction arrows on a grid** (river flow) | Same caveat; C1/2/3 shared editor |
| S5 | http://cossacksworld.ucoz.co.uk/index/map_options/0-351 | **Adding New Map Options**: `gMap.settings.*` structure; option groups named Map Shape, Start Options, Resource options, Peace Time; files `generator.cfg`, `terrainmasks`, `startingsettings.cfg`, `showcustomgame.inc` | C3 modding guide, concrete file paths |
| S6 | http://cossacksworld.ucoz.co.uk/index/map_size/0-352 | **Changing Map Size**: shipped combo `0→320, 1→480, 2→640, 3→720(mod)`; grids (`idlegrid`, `scangrid`, `terraindata`, `resgrid`, `soundgrid`) and `gc_MaxMapWidth/Height` must all scale; "Took a long time to generate… Especially the forest stage" | C3 modding guide |
| S7 | http://cossacksworld.ucoz.co.uk/index/new_random_map_mask_samples/0-333 | **EMOM v2.7.7.1 map masks**: 3 new map shapes (lakes, coastal, river), 2 new terrain types (desert, arctic), 736 new masks, counts per shape/player-count, start-point spacing rules (≥0.7 cm to water/edges, ≥1.5–2 cm between starts), breakout of land/lake/coastal/river/continent/island/peninsula/med mask counts | Mod author's change log; specific mask families |
| S8 | https://cossackshq.net/c3-mod-new-terrain-mod | **New Terrain Mod (NTM)**: new landscape options Lakes/Rivers/Coastal (360+ masks); seasons **Spring/Autumn**; forest types **Countryside / Taiga / Black forest / temperate**; map sizes **tiny 256, normal 320, medium 400, large 480, very large 560, huge 640**; 200+ patterns; animated trees; animals; desert moved from Season to Landscape; "landscape type 'plain' now is plain and no longer has hills generating on them. Hills generate hills not plateaus/mountains" | Mod description, C3-specific |
| S9 | https://cossacks3.pl/rules.php | Actual skirmish/lobby setting names: **Season, Map Shape, Terrain Type, Starting Resources, Minerals, Map Size, Start Options, Balloon Options, Cannons, Peace Time, 18th Century Options, Capture, Dip. Center & Market, Allies, Limit of Population, Game Speed, Adviser Assistant**; values Season=Summer, Map Shape=Land, Terrain Type=Plain, Minerals=Rich/Poor, Map Size=Tiny, Starting Resources=Thousands/Normal, Allies=Nearby | Competitive rule set; good for option names/values |
| S10 | https://cossackshq.net/c3-news-season-clash-1-details-start-on-next-week , https://cossackshq.net/c3-news-new-union-one-day-blitz-tournament , https://cossackshq.net/c3-news-kr-s-clan-tournament-on-10th-11th-of-march | Corroborate the same 6 core map options: Season (Summer), Map Shape (Land), Terrain type (Plains / Highland / Highlands), Minerals (Rich), Map size (Tiny / small), plus "Hills are…" sub-setting | Tournament notices |
| S11 | https://cossackshq.net/c3-news-patch-notes-18 | Patch note: "Normal – the size used in Cossacks 3 by default. Large – x2 times bigger than Standard in C3 and x3.52 times…" (map-size scaling note, snippet only) | Snippet; low weight |

Port sources read (read-only):

- `docs/guides/GUIDE4.md` (L1–L8 + Appendices A–E), esp. L6 `PORT-RANDOM-TODAY`,
  Appendix A01/A09, Appendix B02.
- `docs/TERRAIN_GEN_RESEARCH.md` (donor pipeline, pattern stamping, mask counts).
- `app/scripts/data.gd` (MAP_TYPES, START_OPTIONS, MAPGEN budget, BIOME, MAP_W/H).
- `app/scripts/game.gd` (`_generate_map`, `_gen_base`, `_gen_forests`, `height_at`).
- `app/scripts/mapgen.gd`, `app/scripts/pattern_gen.gd`, `app/scripts/MAPGEN_STATUS.md`.
- `app/tools/scan_map.py`.
- `app/scripts/world.gd` (grep for season/biome texture use), `app/scripts/config.gd`,
  `app/scripts/main.gd` (config wiring).

A Steam "Map Editor Guide" surfaced in search (id 1599319598) turned out to be a
**Tooth and Tail** guide, not Cossacks 3. It is **discarded**, not used as evidence.

---

## 2. Donor option catalogue (full lists found)

### 2.1 Skirmish "map options" — the six the port is missing (S9, S10, GUIDE4 B02)

| Option | Donor values (vanilla unless noted) | What it does |
|--------|--------------------------------------|--------------|
| **Season** | Summer, Winter, Desert (vanilla); Spring, Autumn (NTM S8) | Swaps ground/building/prop texture sets; Desert also selects `desert_*` pattern families. NTM moved Desert to *Landscape* and darkened winter textures. |
| **Map Shape** | Land (nowater2), Mediterranean, Peninsulas, Islands, Continents, Continent (vanilla `generator.cfg` TerrainTypes); + Lakes, Coastal, River (DLC5/EMOM S7), + Desert, Arctic (NTM/EMOM S7/S8) | Selects the `data/gen/terrainmasks/<shape>/` folder; hand-authored RGB masks (R relief, G forest/stone, B water, white = start markers). A seed picks one mask by `floor(RandomExt*count)`. |
| **Terrain Type** (a.k.a. Relief / Landscape) | Plain, Highland(s), Mountains (S9/S10/S8); NTM separates Plain / Hills / Mountains so "plain" no longer generates hills (S8) | Controls the relief generator's height envelope and which hill/mountain pattern families are stamped. |
| **Minerals / Richness / Deposits** | Poor, Normal, Rich (S9); generator deposit richness 0–3 with 3 = random (GUIDE4 L6 `DONOR-RANDOM`) | Scales gold/iron/coal deposit amounts and richness of stone/forest placement. |
| **Map Size** | Tiny 256, Normal 320, Medium 400, Large 480, Very large 560, Huge 640 (S8); modded Gigantic 720 (S6/S7); shooter combo Normal 320 / Large 480 / Huge 640 (S6); editor 192–1024 square, default 256 (S1) | Global grid size. Requires scaling `idlegrid`/`scangrid`/`terraindata`/`resgrid`/`soundgrid`, `gc_MaxMapWidth/Height`, pattern counts and flood-fill arrays (S6). |
| **Teams / Allies** | "Nearby" in rule sets (S9); editor Faction 0/1/2/3 define start order, team games reorder starts by team (S1 + editor guides) | Determines start-marker grouping: teammates clustered, enemies spread. Multi-player masks exist for 2–8 players (S7). |

Also present in the lobby but outside terrain scope: Starting Resources
(Normal/Thousands), Start Options (Default, small/medium/large army, towers,
cannons — port has these), Cannons, Balloon, Peace Time, 18th Century, Capture,
Dip. Center & Market, Population limit, Game Speed, Adviser (S9).

### 2.2 Generator internals (from `docs/TERRAIN_GEN_RESEARCH.md`, GUIDE4 App. A, S5)

- **Seed**: `randkey1/2` 64-bit pair; every later random call `RandomExt`; same
  keys + same mask = byte-identical replay.
- **Mask families / counts** (4-player counts from GUIDE4 A09, almanac recon):
  continent 121, continents 187, islands 320, land 230, med 122, nowater 42,
  nowater2 33, peninsulas 280. EMOM adds 736 masks incl. 151 lake, 57 coastal,
  157 river, 100 new med (S7).
- **Relief channels**: R = relief (255 plateau / 96 hill / 48 ravine), G =
  forest/stone density (port uses as forest field), B = water; white = starts.
  `h = -1.1*b*(1 + r*3.5) + relief(r)`; water < -0.25, shore < -0.1; coastline
  smoothed in 3 passes.
- **Pattern families** (`generator.cfg:Patterns`): `mng/mni/mnc` (+`desert_*`)
  deposits; `forests_pine_big/med/small`, `pinefir_*`, `spruce_big/med`,
  `mixed_big/med`, `leaf_big/med/small`, `pinedrygreen`; `stoneforests`
  old/new, `stones d_stn_*`; `hills_dark hil1-4`, `hills_light g_hil1-9`,
  `mountains g_mnt_1-7`; `decor dcr1-3`, `decor_big big_hill_1`;
  `tiles d_tls_1-4`; `swamp_small/big/medium`, `lake_small/big`, `pump
  k_pump_*`; `desert_*` (plain/plateau/mountains/lake/stones/forests);
  `christmas new_year6-10`. Each has weighted `Freq`.
- **Relief-gen params R1–R6** (GUIDE4 L5 DONOR-EDITOR / editor popup S2): height,
  radius, passage width, furrow count/depth/phase.
- **Stamping pipeline**: `SetupTiledPatterns` on a strict 25×25 cell grid;
  `SetupMines` (gold 14–22, iron 32–42, coal 70–82 donor units, 256 attempts);
  `SetupStartingResources` (guaranteed food rects, stone/forest rings);
  `FillOwnerMap` flood-fill from starts then `SetupBorderObjects` lines borders.
  Rejection test `_misc_CheckStandPattern(Ext)` against water, rock, other
  patterns and 3 elliptical keep-clear zones per start (inner army / mid
  stone+forest gap / outer resources).
- **Editor-only tools that affect authored/skirmish maps** (S1–S4): snow tool;
  peace time Ctrl+W; fog Ctrl+F; blockade toggle Q (deep forest impassable until
  cleared); UserTerrain BMP import; roads along polygon; water current arrows;
  glint placement; mineral/farm/campfire placement (fragile — most custom-map
  crashes come from these).

---

## 3. Port baseline (read-only findings)

- **Fixed size** `MAP_W = MAP_H = 160` tiles (`data.gd:33-34`), 320×320 m; no size
  option. `scan_map.py` scales patch-size targets by `(map_w/160)^2` but the
  generator never varies the size.
- **6 terrain ids** only: 0 grass / 1 dirt / 2 forest floor / 3 water / 4 sand /
  5 rock. GUIDE4 E01: "never add terrain id 6 — masks/hlv assume 0..5".
- **6 map shapes** in `MAP_TYPES` (`data.gd:193-200`) with only a `water_frac`
  scalar; real shape now comes from exported donor masks via `C3MapGen.build()`
  (`game.gd:536`, `mapgen.gd`). No Coastal/Lakes/River/Desert/Arctic masks.
- **Biome = partial**: `Data.BIOME` exists (`summer`/`winter`/`desert`), is read
  from config (`main.gd:217`, `config.gd` via `cfg.biome`), and is passed to
  `C3PatternGen.build` (`game.gd:441`); `pattern_gen.gd:125-128` switches to
  `desert_*` families when `biome == "desert"`. **No season texture swap in
  `world.gd`** (grep found only `_prop_tex`, no winter/snow/biome branch).
  `winter0..26` PNGs are converted (`docs/TERRAIN_GEN_RESEARCH.md:73`) but
  unwired. No spring/autumn.
- **Relief = procedural domes**, count from quality budget `MAPGEN.domes`
  (2/3/4 for low/medium/high, `data.gd:119-126`); no Plain/Hills/Mountains
  choice, no R1–R6 parameters, no plateau/ravine/furrow controls.
- **Richness = none**: `DEPOSITS` is a fixed dict (`data.gd:38,797`); no
  Poor/Normal/Rich setting.
- **Teams = none**: port has `PLAYER_NAMES` of 2 and `_start_positions()` corners;
  no team/ally option found in reviewed code (mark: low-confidence, menu not
  fully audited).
- **Start options = present** (6 entries, `data.gd:204-211`).
- **Decor**: bushes/stumps are rendered (`world.gd:965,973`) per GUIDE4 L3/L4;
  full donor decor families (dcr1-3, big_hill_1, swamp/lake/pump, christmas,
  NTM flowers/graves/ruined buildings/animals) not implemented.
- **Water**: flat blue + sparkle from mask height; no river current arrows,
  brush glints, or direction (S4).

---

## 4. Donor feature table

`Status` values: **YES** implemented, **PARTIAL** partly wired, **NO** absent,
**UNVERIFIED** could not confirm from reviewed files.

| Feature | Donor behaviour | Port status | Evidence |
|---|---|---|---|
| Map shapes: Land/Med/Peninsulas/Islands/Continents/Continent | `generator.cfg` TerrainTypes → mask folder, seed picks mask | **PARTIAL** (6 entries but only `water_frac` scalar; real masks from `C3MapGen`) | data.gd:193-200; game.gd:536; S5 |
| Map shapes: Lakes/Coastal/River/Desert/Arctic | DLC5/EMOM/NTM extra families (736 masks) | **NO** | S7, S8 |
| Relief / Terrain Type Plain/Hills/Mountains | height envelope + hill/mountain pattern sets | **NO** (procedural domes only) | game.gd:552-566; S8-S10 |
| Seasons Summer/Winter/Desert | texture-set swap + `desert_*` patterns | **PARTIAL** (desert patterns only; no texture swap) | data.gd:161; pattern_gen.gd:125; world.gd grep; S9 |
| Seasons Spring/Autumn | NTM texture sets + palette | **NO** | S8 |
| Richness Poor/Normal/Rich (0–3) | deposit amounts, stone/forest density | **NO** | data.gd:38,797; S9, GUIDE4 L6 |
| Map Size Tiny..Huge (+Gigantic; editor 192–1024) | grid + all sub-grids + pattern-count scaling | **NO** (fixed 160) | data.gd:33-34; S1,S6,S8 |
| Teams / Allies Nearby + 2–8 player masks | start grouping, teammate clustering | **UNVERIFIED→likely NO** | S7,S9; port code reviewed has no team option |
| Forest types Taiga/Countryside/Black/temperate | alternate tree species/deciduous mix | **NO** | S8 |
| Decor families dcr1-3, big_hill_1, flowers, graves, ruined bldgs, animals | multi-object patterns, some animated | **PARTIAL** (bush/stump only) | world.gd:965,973; S8; GUIDE4 App.A12 |
| Terrain mask families (R relief/G forest/B water/white starts) | hand-authored gauss-blurred TGAs, 3 smoothing passes | **YES (vanilla 6)** | mapgen.gd:1-8,176-199; MAPGEN_STATUS |
| Relief params R1–R6 (height, radius, passage, furrows) | editor popup sliders | **NO** | S2; GUIDE4 L5 |
| River currents / water glints | direction arrows, reflection controls | **NO** | S4 |
| Start-point spacing rules (≥0.7 cm to water/edge, ≥1.5–2 cm apart) | enforced in masks; EMOM fixed many bad masks | **PARTIAL** (port snaps starts off water only, `game.gd:640-655`) | game.gd:640-655; S7 |
| Building placement rules (mines on deposits, walls chain, flat ground) | ghost colour + reason | **YES/PLANNED** (GUIDE4 L8 `can_place`) | GUIDE4 L8 |
| Blockade Q / Peace Time Ctrl+W / Fog Ctrl+F / Snow | editor + match flags | **PARTIAL** (fog + capture flags exist; no blockade/snow/peace-time UI verified) | S1,S2; data.gd:45,47 |
| UserTerrain BMP import (contour/river/tree channels) | hand-author any landscape | **NO** | S3 |
| Reproducible seed (randkey pair) | same mask + keys = same map | **PARTIAL** (single seed wired; `scan_map.py` checks determinism) | GUIDE4 L6; scan_map.py |
| Mass quality scan (water%, patches, purity, clearance, cliff, reach) | not in donor; port-side test harness | **YES** (tool exists) | scan_map.py:1-17,171-253 |

---

## 5. GAP LIST (each gap = suggested ticket scope + worker-ticket estimate)

Estimates assume SWARM_OPS "small, independently assignable tickets" (one donor
family / one file each). Counts are planning estimates, not commitments.

| ID | Gap | Suggested ticket scope | Tickets |
|----|-----|-------------------------|---------|
| **G1** | Map-size scaling | `data.gd` MAP_W/H + config validation; `world.gd` chunk LRU/grid budget; `game.gd` start fractions + pattern scale; AI/minimap; config/menu field; `scan_map.py` thresholds | **6** |
| **G2** | Relief / Terrain Type (Plain/Hills/Mountains) | option table in `data.gd`; config + menu; `game.gd` dome count/height envelope per type; `mapgen.gd` plateau/ravine channel weighting; screenshot acceptance | **4** |
| **G3** | Seasons (Summer/Winter/Desert, + Spring/Autumn) | `data.gd` season table; `world.gd` per-biome texture pools (wire existing `winter0..26`); `pattern_gen.gd` family selection; config/menu; QA screenshots per season | **5** |
| **G4** | Richness / Minerals (Poor/Normal/Rich) | `data.gd` deposit multiplier; `game.gd` mine deposit amounts + stone/forest density; config/menu; acceptance via `scan_map.py` | **3** |
| **G5** | Teams / Allies + multi-start (2–8 players) | option + player-count config; `game.gd` `_start_positions` grouping; player colours/AI; menu; verify start spacing rule from S7 | **5** |
| **G6** | Extra map-shape mask families (Lakes/Coastal/River/Desert/Arctic) | export/convert mask PNGs per family (one ticket each), `mapgen.gd` manifest entries, `data.gd` MAP_TYPES entries, menu; do not copy donor binaries into repo without licence check | **6** |
| **G7** | Pattern/decor family expansion | one ticket per family group: forest species, stoneforests, hills_light/mountains, dcr1-3 + big_hill_1, swamp/lake/pump, desert_* sets, christmas, NTM flowers/graves/animals | **8** |
| **G8** | River currents / water glints | `game.gd` water metadata (flow vector), `world.gd` glint/current rendering, editor/menu only if authored maps are in scope | **3** |
| **G9** | Relief generator params R1–R6 | `data.gd` param table; `game.gd` dome/ridge/furrow math; config + menu sliders | **3** |
| **G10** | Editor-only features affecting skirmish | blockade Q (deep-forest impassable until cleared), peace-time flag, snow tool, UserTerrain BMP import path; menu hooks where match-relevant | **4** |
| **G11** | Terrain-id / biome-pool architecture decision | decide "keep ids 0..5 with per-biome texture pools" (recommended, matches GUIDE4 E01) vs new ids; document + one refactor ticket | **2** |
| **G12** | QA/tooling for new sizes/seasons/shapes | `scan_map.py` targets per size/shape/season; 20-seed × N-shape sweep; determinism byte-diff gate | **2** |
| **G13** | Determinism & 8-player start symmetry | multi-start RNG discipline; fix `pattern_gen.gd:240-245` CIRCLE2 asymmetry flagged in MAPGEN_STATUS; replay test | **3** |
| **G14** | Forest-type option (Taiga/Countryside/Black/temperate) | `data.gd` table; `pattern_gen.gd` family weights; config/menu; screenshot per type | **2** |
| | | **Total** | **56** |

### Top 10 gaps (ranked by skirmish-fidelity impact)

1. **G1 Map-size scaling** (6 tickets) — donor default is 256–640; port 160 is ~1/1.6 of the smallest option. Blocks large battles and all macro layout.
2. **G3 Seasons** (5) — most visible missing feature; assets already converted but unwired.
3. **G2 Relief / Terrain Type** (4) — the "Terrain type: Plains/Highlands" flag used in every tournament rule set is absent.
4. **G5 Teams + multi-start** (5) — 2–8 player masks exist in donor; port is effectively 1v1.
5. **G4 Richness** (3) — Poor/Rich is a standard lobby option and directly changes economy.
6. **G6 Extra map shapes** (6) — Lakes/Coastal/River/Desert/Arctic account for most of the donor's 736+ masks.
7. **G7 Pattern/decor families** (8) — largest single family of work, but each ticket is small and independent.
8. **G12 Scan/QA tooling** (2) — prerequisite for trusting any of G1–G7; cheap, high leverage.
9. **G14 Forest-type option** (2) — cheap, strongly changes map read.
10. **G10 Editor-only/match flags** (4) — lower priority because the in-menu editor is "largely non-functional" (S1) and these mostly affect authored maps; blockade/peace-time are the skirmish-relevant parts.

Top-10 subtotal: **45 worker tickets**. Full backlog including G11/G13/G8/G9: **56**.

---

## 6. Unverifiable / caveated claims (do not treat as fact without re-check)

1. **No dedicated Fandom wiki pages named Terrain / Relief / Richness / Season /
   Size / Teams were found.** The six-option list is reconstructed from cossacks3.pl
   tournament rules (S9), cossackshq notices (S10) and GUIDE4 B02 — not from a
   single authoritative wiki page. Mark the *exact in-game label strings* as
   unverified.
2. **S2/S3/S4 are Cossacks 1/2/3 shared editor documentation** hosted on
   cossacksworld.ucoz.co.uk. Tool names/behaviour are very likely inherited by
   C3, but I did not verify them against a running C3 build (no donor access in
   this lane). Treat as "documented for the GSC editor family", not "confirmed in
   C3 1.3.0.60".
3. **Teams is UNVERIFIED for the port.** I read `data.gd`, `game.gd`, `config.gd`,
   `main.gd` and `MAPGEN_STATUS.md`, but not every menu scene; a team option could
   exist in a scene file I did not open. G5's estimate stands either way.
4. **Exact mask counts** (continent 121, islands 320, land 230, etc.) come from
   GUIDE4 A09's "almanac recon", not from a public page fetched this session.
   They are inherited project knowledge, not independently re-verified here.
5. **S11 patch-note snippet** about map-size multipliers is truncated in search
   output; the numeric multipliers are not reliable. Use S6/S8 sizes instead.
6. **Port status of `START_OPTIONS` army scaling** was not functionally tested;
   the table exists, but whether `army_mult` is applied on all paths is
   unverified (outside this task's terrain scope).
7. **Donor assets must not be downloaded/copied by workers** (SWARM_OPS §3.5).
   G6/G7 tickets must use already-converted `app/assets/terrain/...` PNGs or go
   through the existing donor-conversion tools under private-use rules; this
   research did not copy anything.

---

## 7. Files changed

- `docs/research/RC_TERRAIN.md` — **new** (this file). No other file touched.
