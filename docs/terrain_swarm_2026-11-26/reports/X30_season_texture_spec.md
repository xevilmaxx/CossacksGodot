---
id: X30-SEASON-TEXTURE-SPEC-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X30 — implementation-ready season texture swap spec"
owner: X30 (worker; DONOR-FIRST read-only design swarm)
created: 2026-11-26
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_BINARY_RUN
donor_root: "C:\\Games\\Cossacks 3 (READ-ONLY; plaintext read only, no binary executed, no binary copied)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
visual_parity_claim: false
owner_file: "docs/terrain_swarm_2026-11-26/reports/X30_season_texture_spec.md (only file written)"
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/F10_dlc_terrain.md
  - docs/terrain_swarm_2026-11-26/reports/F05_tile_mapping.md
  - docs/terrain_swarm_2026-11-26/reports/A03_asset_pipeline.md
  - docs/terrain_swarm_2026-11-26/spec/06_TILE_AND_ATLAS.md
  - docs/terrain_swarm_2026-11-26/spec/09_EDITOR_PARAMETERS.md
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:41,44,125). Every reproduced value is a byte/text-derived PORT APPROXIMATION until a real capture lands. No parity claim anywhere."
---

# X30 — Season texture swap: implementation-ready spec

> **Label key (CHARTER.md:70-72).** **[O]** = literal donor file:line / on-disk
> count read this pass or by a cited prior worker. **[D]** = deterministic
> consequence of observed data. **[I]** = design reading without a decoder /
> runtime trace. **[U]** = UNVERIFIED. **PORT APPROXIMATION** = any port-side
> deviation from donor structure. No donor parity claim is made.
>
> **Task notation.** "D1:2075-2084" in the assignment is the swarm's shorthand
> for `data/scripts/common.inc/dogenerate.inc:2075-2084` (cf. `A02_algorithm.md:59`,
> which cites `D1:1530-1536` / `D1:1542-1565` for the same file). All quotes below
> use full donor paths.

---

## 0. Executive summary

1. **[O] The donor ships three real season values with two genuine art sets.**
   `gc_MaxSeasonCount = 3` (`dmscript.global:237`), `SEASON_ENUM`-equivalent donor
   integers are `0 = Summer`, `2 = Winter`, `3 = Desert`
   (`dogenerate.inc:4,2075-2084`; `Dogenerate`/`map.script` default 0). The port
   already mirrors this verbatim at `variant3d/scripts/data.gd:258`
   (`SEASON_ENUM := {"summer": 0, "winter": 2, "desert": 3}`) and `:259`
   (`SEASON_DEFAULT := 0`). **Season 1 is deliberately absent / [U]**
   (`data.gd:255-257`), and Spring/Autumn are *aliases of Summer*, not art sets
   (`terrain.lib:12-15`, F10 E27).

2. **[O] Winter is a *name* swap over an index-preserving 124-id space; Desert is
   a *different generation pipeline*, not a second atlas.** Winter appends
   `_winter` to the computed tile-block name (`texturemap.inc:525-526,605-606,639-640`),
   backed by a 124-entry `terrain.presets` Winter section (`:134-136`, blocks
   `:138-261`) that is a one-for-one rename of Summer (`:6-129`), F05 F05/E01.
   Desert instead selects `SetupTiledPatterns('desert_tiles')`
   (`dogenerate.inc:1532-1535`), calls `_misc_SetDesert(False,False)`
   (`:1589-1590`) to rewrite grass→sand/desert/test and rocks→desert names
   (`miscext.script:1447-1479`, F10 E33), and sets colour table 7
   (`dogenerate.inc:2079-2080`). **Do not model Desert as `season=3 → _desert`
   suffix: no such suffix rule exists in the donor.**

3. **[O] Entitlement is UI gating, not asset gating.** Winter (`season=2`)
   requires `gc_lastknowndlc_dlc2` **or** deluxe; Desert (`season=3`) requires
   dlc3 or deluxe (`showcustomgame.inc:43-54,178-203`; `dmscript.global:1642-1645`).
   The art itself is base-install: 27 `winter*.dds`, 12 `desert*.dds`
   (`F10 E28`), 121/124 `_winter` tile tokens (`F10 E29`), a Winter atlas
   already built in the port (`tile_index_atlas_winter.manifest.json`, F05 E14).
   **[U] Whether the shipped install actually carries the DLC entitlement at
   runtime is not decidable from donor text** — see U-1. Recommendation: expose
   an entitlement *setting*, never assume a Steam entitlement (F10 §8.1 item 5).

4. **[D] TODAY's fresh-module scope is Summer baseline + Winter swap only.**
   Both art sets already exist in the port (`blocks/*.png` 112 stems = donor DDS
   stems, F05 E14; `winter_aliases.json` 124/124, F05 F05; 56 port masks shared
   across seasons, `build_winter_atlas.py:257`). Desert is deferred **iff** its
   alias/prop assets are absent — the port already ships `desert_remap.json`
   (F05 E14) but A03 explicitly holds `desert_aliases.json` as `[U]` pending F10
   scope (A03 §2.2.4, `:115,207`). Event decor (`christmas`/`pump`) is shipped but
   disabled (`gc_halloween = gc_christmas = -1`, `dmscript.global:1668-1669`) and
   is deferred. NTM Spring/Autumn are mod-only (F10 E41) and out of scope.

5. **[D] The new backend needs no `config.gd` edit before COORD stage 4.** The
   season string already exists at `config.gd:129` (`gameplay.season = "summer"`)
   and is already applied to `Data.BIOME` at `config.gd:536`, with donor ints at
   `data.gd:258`. The fresh module reads `Data.BIOME` / `Data.SEASON_ENUM` and
   selects the atlas manifest/aliases + palette by that key (§6). `config.gd` is
   reserved to the deferred stage-4 config owner (`V11:159`, backup suffix
   `COORD-STAGE4`).

---

## 1. Evidence table

All paths are relative to `C:\Games\Cossacks 3` unless marked **PORT**. Every
line below was read this pass (verbatim donor quotes in §3) or is a cited
prior-worker observation (F05/F10/A03) — no donor binary was run.

| # | Donor / PORT path:line | Observation | Label |
|---|---|---|---|
| E1 | `texturemap.inc:525-526` | `if GetSeasonType=2 then newtile := newtile+'_winter'` in the shore/rock pass; every line carries the `;`-comment prefix | [O] intent; runtime [U] |
| E2 | `texturemap.inc:605-606` | same `_winter` append at the cliff/height-override pass | [O] intent; runtime [U] |
| E3 | `texturemap.inc:639-640` | same `_winter` append at the road pass (`ground1`/`test2`/`test3`) | [O] intent; runtime [U] |
| E4 | `dogenerate.inc:2075-2084` ("D1") | winter → colour table 6 + PHDR 1; `season=3` → table 7; else table 0 + PHDR 0 | [O] |
| E5 | `onloadfull.inc:70-79` | identical palette block on full load;PHDR 0 falls through for desert | [O] |
| E6 | `terrain.presets:133-136` | `SetName = Winter`, `WaterSet = Winter`, `DefaultIndex = 0`; Summer equivalent at `:2-4` | [O] |
| E7 | `terrain.presets:138-261` | 124 Winter `TileBlock` lines, first `grass1_winter`, one-for-one rename of `:6-129` | [O]; corroborated F05 E01/F05 |
| E8 | `miscext.script:1547-1628` | `_misc_SetSeason`: `SetSeasonType`, leaftree destroy, child mesh `actor+'a.mesh'` + material `detail`→`detailw`, alpha0a↔alpha0b flip | [O] |
| E9 | `miscext.script:1589-1593` | **verbatim `detailw` ref**: `if ((GetSeasonType=2) and (material<>'detailw')) or ((GetSeasonType<>2) and (material<>'detail')) then material := 'detail'; if GetSeasonType=2 then material := material+'w'` | [O] |
| E10 | `dogenerate.inc:1532-1535` | `if (bDesert) then SetupTiledPatterns('desert_tiles') else SetupTiledPatterns('tiles')` | [O] |
| E11 | `dogenerate.inc:4,1589-1590`; `miscext.script:1447-1479` (F10 E33) | `bDesert = (season=3)`; `_misc_SetDesert(False,False)` rewrites grass→sand/desert/test, rocks→desert variants | [O] second-hand for `:1447-1479` |
| E12 | `showcustomgame.inc:43-54,178-203`; `dmscript.global:1642-1645` | winter = dlc2/deluxe, desert = dlc3/deluxe; `SetMapFromName` forces season 0 when entitlement missing | [O] (F10 E24) |
| E13 | `dmscript.global:237,1668-1669` | `gc_MaxSeasonCount = 3`; `gc_halloween = -1`, `gc_christmas = -1` | [O] (F10 E25) |
| E14 | `terrain.lib:12-15`; `tiles.season:1-4` | `seasons.Summer/Autumn/Spring = Summer`, `seasons.Winter = Winter`; `TexName=grass1 / Summer=grass1` | [O] (F10 E27) |
| E15 | `terrain/tiles/textures/**` | 27 `winter*.dds`, 12 `desert*.dds` (+23 sand/16 grass/16 rock/26 test) | [O] (F10 E28) |
| E16 | `tiles.lib` / `tiles.mat` | 121 / 124 distinct `*_winter` tokens (incl. `alpha0a/b/c_winter`, `desert1..12_winter`); desert winter ids reuse summer desert DDS | [O] (F10 E29; F05 F05) |
| E17 | `dogenerate.inc:1848-1851`; `generator.cfg:1538-1627` | pump stamps only if `gc_halloween>0 and season<>2`; christmas only if `gc_christmas>0`; families `new_year6..10` / `k_pump_1..15` exist but flags are −1 | [O] (F10 E34/E35) |
| E18 | `dlcs/winter/celmis1.map` ASCII scan | zero `winter` tokens; bakes `grassforest*`, `stonessea*`, `minegold`, `field` | [O] (F10 E38) |
| E19 | **PORT** `assets/terrain/atlas/winter_aliases.json`, `tile_index_atlas_winter.manifest.json` | 124 entries index-preserving; 121 filled / 3 EMPTY (86/110/123); `desert_reuse=desertN_winter→desertN.dds` | [O] (F05 E14/F05) |
| E20 | **PORT** `tools/build_winter_atlas.py:33-39,156-208,257` | index `i → cell i`; alpha carriers stay EMPTY; `masks` copied unchanged from Summer; `winter18/23/24/26` deliberately unmapped | [O] |
| E21 | **PORT** `assets/terrain/masks/**` | 56 PNG = 7 types × 8; shared by all seasons (no winter mask set) | [O] (F04 §9; X15 §3; E20) |
| E22 | **PORT** `scripts/config.gd:129,536`; `scripts/data.gd:230,248-272` | `gameplay.season="summer"` → `Data.BIOME`; `SEASON_ENUM` 0/2/3; `TERRAIN_TINT` is a PORT APPROX flat tint, **not** the donor swap | [O]; PORT APPROX for tint |
| E23 | **PORT** `assets/terrain/atlas/desert_remap.json` | ships, but A03 holds `desert_aliases.json` `[U]` pending F10 | [O] + [U] |

---

## 2. Swap rules — verbatim donor selection chain

### 2.1 Tile-block selection (`GetSeasonType=2` → `_winter`)

All three lines are `;`-commented **authored intent** (F05 E08/G9; F10 §5.3).
**[U]** runtime activity of the whole `texturemap.inc`; do not assert it is
live. Quoted exactly, including the `[*] = ;` DScript comment prefix:

`data/scripts/common.inc/texturemap.inc:523-529` — shore/rock pass:
```
523:       [*] = ;               if (newtile<>'') then
524:       [*] = ;               begin
525:       [*] = ;                  if GetSeasonType=2 then
526:       [*] = ;                  newtile := newtile+'_winter';
527:       [*] = ;                  var newtex : Integer = MapGetTileIndexByTileBlock(newtile);
528:       [*] = ;                  SetTileIndex(x, y, newtex)
529:       [*] = ;               end;
```

`texturemap.inc:603-609` — cliff/height-override pass (`rock8` if `|h|>2.7`,
`rock4` if `>2.4`, clear if `<0.1` at `:594-601`):
```
603:       [*] = ;               if (newtile<>'') then
604:       [*] = ;               begin
605:       [*] = ;                  if GetSeasonType=2 then
606:       [*] = ;                  newtile := newtile+'_winter';
607:       [*] = ;                  var newtex : Integer = MapGetTileIndexByTileBlock(newtile);
608:       [*] = ;                  SetTileIndex(x, y, newtex);
609:       [*] = ;               end;
```

`texturemap.inc:637-643` — road pass (`ground1`/`test2`/`test3` at `:627-636`):
```
637:       [*] = ;            if (newtile<>'') then
638:       [*] = ;            begin
639:       [*] = ;            if GetSeasonType=2 then
640:       [*] = ;            newtile := newtile+'_winter';
641:       [*] = ;            var newtex : Integer = MapGetTileIndexByTileBlock(newtile);
642:       [*] = ;            SetTileIndex(x, y, newtex)
643:       [*] = ;         end;
```

**[D]** The suffix is applied *after* tile-block selection and *before*
`MapGetTileIndexByTileBlock`, so the integer id space is unchanged. This is the
donor reason the port's Winter atlas can be index-preserving (F05 F05;
`build_winter_atlas.py:33-34`: shader `floor(abs(tile))` needs no edit).

### 2.2 Winter preset block (`terrain.presets`)

`data/terrain/tiles/terrain.presets:133-139` (Summer twin at `:2-6`):
```
133: section.begin
134:    SetName = Winter
135:    WaterSet = Winter
136:    DefaultIndex = 0
137:    Blocks : struct.begin
138:       [*].TileBlock = grass1_winter
139:       [*].TileBlock = grass2_winter
```
**[O]** 124 Winter blocks at `:138-261` vs 124 Summer at `:6-129`; final Winter
block `alpha0c_winter` at `:261`, final Summer `alpha0c` at `:129`
(F05 E01/E14). **[U]** `WaterSet=Winter` resolution: `water.lib` has only a
`default` record (F10 §5.2/U3).

### 2.3 Colour table / PHDR (`dogenerate.inc:2075-2084`, "D1")

`data/scripts/common.inc/dogenerate.inc:2075-2084` (quoted verbatim):
```
2075:       [*] = ;if GetSeasonType=2 then begin
2076:       [*] = ;   SetCurrentColorTableIndex(6);
2077:       [*] = ;   SetCurrentPHDRIndex(1);
2078:       [*] = ;   end else begin
2079:       [*] = ;   if (gMap.settings.gen.season=3) then
2080:       [*] = ;   SetCurrentColorTableIndex(7)
2081:       [*] = ;   else
2082:       [*] = ;   SetCurrentColorTableIndex(0);
2083:       [*] = ;   SetCurrentPHDRIndex(0);
2084:       [*] = ;end;
```
`data/scripts/common.inc/onloadfull.inc:70-79` is byte-equivalent in meaning.
**[D]** Desert takes table 7 **and PHDR 0** (line 2083 executes after the
single-statement `if season=3`); Summer takes 0/0. `*Pass 2 note:* the nearby
commented `if (gc_christmas>0) then SetCurrentColorTableIndex(5)`
(`onloadfull.inc:80-81`, `dogenerate.inc:2085-2086`) is event-only and inactive
with the flags at −1 — do not wire it.`

### 2.4 Prop / material swap (`_misc_SetSeason`)

`data/scripts/lib/miscext.script:1547-1628`. Three distinct actions:

1. **Leaftree destruction** (`:1568-1575`) — winter only:
```
1568:                if (GetSeasonType=2) then // winter
1569:                begin
1570:                   if StrExists(basename, 'leaftree') then
1571:                   begin
1572:                      Log('winter : '+basename+' requested to destroy');
1573:                      GameObjectRequestToDestroyByHandle(goHnd);
1574:                      continue;
1575:                   end;
1576:                end;
```
   `dogenerate.inc:1975-1981` repeats the destruction during generation (F10 §5.3).
2. **Child mesh + `detailw` material** (`:1585-1597`) — building children only:
```
1585:                      var child : Integer = GetGameObjectGOHandleChildByHandle(goHnd, 0);
1586:                      var actor : String = GameObjectGetActorNameByHandle(goHnd);
1587:                      SetGameObjectActorNameByHandle(child, actor+'a.mesh');
1588:                      var material : String = GetGameObjectMaterialNameByHandle(child);
1589:                      if ((GetSeasonType=2) and (material<>'detailw')) or ((GetSeasonType<>2) and (material<>'detail')) then
1590:                      begin
1591:                         material := 'detail';
1592:                         if GetSeasonType=2 then
1593:                         material := material+'w';
1594:                         Log('winter : '+basename+' child material set to '+material);
1595:                         SetGameObjectMaterialNameByHandle(child, material);
1596:                         SetGameObjectVisibleByHandle(child, True);
1597:                      end;
```
   **[D]** Winter also substitutes actor mesh `<actor>a.mesh` (`:1587`); a
   material-only port swap is incomplete. **[I]** the port's
   `assets/terrain/prop_winter_materials.json` (P02:45) is the existing derived
   carrier for this — reuse, do not invent winter props.
3. **Alpha sentinel flip** (`:1609-1626`) — `alpha0a` (id 86) ↔ `alpha0b`
   (id 110) across the whole map in winter vs summer. **[D]** id 123 `alpha0c`
   is untouched; all three are EMPTY cells in the port (F05 E13).

### 2.5 Desert is a pipeline switch, not a suffix

`dogenerate.inc:1532-1535`:
```
1532:       [*] = ;   if (bDesert) then
1533:       [*] = ;   SetupTiledPatterns('desert_tiles')
1534:       [*] = ;   else
1535:       [*] = ;   SetupTiledPatterns('tiles');
```
Combined with `bDesert = (season=3)` (`dogenerate.inc:4`) and
`_misc_SetDesert(False,False)` (`:1589-1590`, rewrite at
`miscext.script:1447-1479`, F10 E33), **[D]** Desert changes (a) pattern family,
(b) tile *names*, (c) colour table 7, but **not** the atlas alias set. No
`_desert` or `_summer` suffix rule is present anywhere in the donor.

---

## 3. Exact swap table (Summer / Winter / Desert)

| Dimension | **Summer (`season=0`)** | **Winter (`season=2`)** | **Desert (`season=3`)** |
|---|---|---|---|
| Gate | none (vanilla baseline) — `showcustomgame.inc:182-183` | dlc2 **or** deluxe — `showcustomgame.inc:43,49-50,185-186,190-191` | dlc3 **or** deluxe — `showcustomgame.inc:44,52-53,187-188,192-193` |
| Preset / atlas source | `terrain.presets:2-4`, blocks `:6-129` = 124 ids; **PORT** `tile_index_atlas.manifest.json` (16×8, 124 named / 121 filled / 3 EMPTY) | `terrain.presets:134-136`, blocks `:138-261` = 124 `_winter` ids, one-for-one; **PORT** `tile_index_atlas_winter.manifest.json` + `winter_aliases.json`, same cell `i → i`; source art `winter0..26.dds` + 12 reused `desert*.dds` | **no separate preset/atlas**; tiles rewritten by `_misc_SetDesert` to `sand*/desert*/test*`; source `desert1..12.dds`, `sand*.dds`; **PORT** `desert_remap.json` exists, `desert_aliases.json` held `[U]` |
| Tile-name rule | base block name | append `_winter` at `texturemap.inc:525-526,605-606,639-640` | grass→sand/desert, rock→desert variants (`miscext.script:1447-1479`) |
| Id space | 0–123 (ids 35–52 sand faces, 53–70 rock faces, 86/110/123 alpha) | **identical** ids (F05 F05; `build_winter_atlas.py:33`); alpha carriers stay EMPTY | identical ids; no new id invented |
| Masks / height | 56 port masks shared, B=water / R=relief / G=forest / white=start (F10 E19-E22) | **same masks, unchanged** (`build_winter_atlas.py:257`) | same masks; DLC3 desert masks are baked DLC content, not skirmish generation (F10 §1) |
| Props — remove | — | every object whose basename contains `leaftree` (`miscext.script:1568-1575`; `dogenerate.inc:1975-1981`) | — |
| Props — materials | building child material `detail`, actor `<actor>.mesh` | building child material `detailw`, actor `<actor>a.mesh` (`miscext.script:1585-1597`) | base `detail`; desert props (palm, `stonesdesert*`, `minegold/iron/coal`, `field*`) are base-install assets baked into DLC maps (F10 E37/E40) |
| Alpha tile | `alpha0a` (86) | flip 86→`alpha0b` (110) (`miscext.script:1609-1626`) | base (86) |
| Colour table / PHDR | 0 / 0 (`dogenerate.inc:2082-2083`) | 6 / 1 (`dogenerate.inc:2076-2077`) | 7 / 0 (`dogenerate.inc:2079-2083`) |
| Pattern family | `SetupTiledPatterns('tiles')` (`dogenerate.inc:1535`) | same `tiles` + `_winter` names | `SetupTiledPatterns('desert_tiles')` (`dogenerate.inc:1533`) |
| Event decor | `pump` only if `gc_halloween>0` (never, flag −1) | suppressed (`season<>2` guard, `dogenerate.inc:1848-1851`) | `christmas` only if `gc_christmas>0` (never) |
| Port readiness (today) | blocks/atlas/masks present | aliases/atlas present; 27 winter PNG, 4 unmapped (`winter18/23/24/26`) | `desert_remap.json` present; `desert_aliases.json` `[U]`; no winter-prop materials beyond P02's JSON |

**Labels:** selection rules **[O]** as authored text but **[U]** at runtime;
port asset inventory **[O]**; readiness verdicts **[D]**; port atlas packing,
face cells and alpha holes **PORT APPROXIMATION** (F05 §4.2).

---

## 4. Multiple-pass contradiction adjudication (owner directive, CHARTER.md:86-93)

| # | Contradiction / anomaly | Pass 1 | Pass 2 (second instrument or cross-report) | Accepted reading |
|---|---|---|---|---|
| C1 | `gc_MaxSeasonCount = 3` suggests values 0/1/2, but Winter is 2 and Desert 3 (`dmscript.global:237` vs `dogenerate.inc:4,2079`) | Assume 0/1/2 | Read `dogenerate.inc:4,2079-2080` and `miscext.script:1549,1568`; port `data.gd:255-259` | **[O]** 0/2/3; value 1 absent and **[U]**; never emit a "season 1" mapping |
| C2 | `texturemap.inc` winter lines are all `;`-commented — are they live? | Treat as active rule | F05 E08/G9 and F10 §5.3 classify the whole script as authored intent; D03 §1 shows all donor code lines are `[*] = ;…` | **[O]** text, **[U]** runtime; spec cites as intent only, does not claim active |
| C3 | `dlcs/winter/celmis1.map` has **zero** `winter` tokens (F10 E38) yet is called the "winter map" | Infer winter tiles from folder name | ASCII scan + `.aix` census (F10 §2): only farm/achievement calls; season is numeric `TMapSettingsGen.season`, value undecoded (F10 U1) | **[D]** no name-based winter inference; winter tile set is chosen by `GetSeasonType`, never by map filename |
| C4 | Spring/Autumn season options claimed by mod prior art (`RC_TERRAIN.md:27`) vs donor `terrain.lib:12-15` | Consider implementing four seasons | Read `terrain.lib:12-15` + `tiles.season:1-4` + F10 E41 | **[O]** donor aliases Spring/Autumn→Summer; mod claims out of scope |
| C5 | Desert "winter" tiles = `desertN_winter` tokens (F10 E29) vs "desert uses summer desert DDS" (F05 F05) | Assume a separate `_desert` art set | `tiles.mat:954-998` (F05 F05) + absence of any `_desert` suffix rule in `texturemap.inc` | **[D]** desert winter tokens reuse summer `desert*.dds`; port `desert_reuse` alias is faithful; no new art |
| C6 | Colour table 7 for desert — does PHDR also change? | Assume PHDR 1 like winter | Re-read `dogenerate.inc:2078-2084`: `SetCurrentPHDRIndex(0)` is outside the inner `if` | **[D]** desert = 7 / 0; winter = 6 / 1 |
| C7 | Port 112 PNGs vs donor 124 ids; "56 winter masks" vs season swap | Treat 112 as id count | F05 E01/E11/F02 and X15 §3: 124 ids, 105 distinct hashes, 56 masks shared by all seasons | **[O]/[D]** masks are season-agnostic; only atlas aliases swap. No "winter mask set" exists or is needed |
| C8 | `WaterSet=Winter` (`terrain.presets:135`) implies a winter water set | Assume separate water texture | `water.lib` has one `default` record (F10 §5.2) | **[U]** resolution unresolved (F10 U3); keep summer water; do not fabricate |

**No silent skips.** Every anomaly above was re-read against a second donor file
or a second landed report; the accepted reading is carried into §3–§5.

---

## 5. In-scope / deferred table for the fresh module (TODAY)

Decision basis: **assets already exist in the port** ⇒ cheap and in scope;
assets absent or flags disabled ⇒ deferred. This is a **PORT APPROXIMATION**
scope choice, not a donor parity claim.

| Item | Scope | Reason (evidence) | Owner / gate |
|---|---|---|---|
| Summer baseline (vanilla skirmish) | **IN SCOPE** | default `season=0` (`config.gd:129`, `dogenerate.inc:2082-2083`); atlas + 56 masks + 112 blocks present (F05 E14, X15 §3) | I05 atlas / I07 tiles / I11 composer |
| Winter swap (`_winter` suffix, 124 index-preserving alias, leaftree removal, `detailw`, alpha flip, palette 6/1) | **IN SCOPE** | assets already exist (`winter_aliases.json`, `tile_index_atlas_winter.manifest.json`, `prop_winter_materials.json`, 27 winter PNG) — F05 E14/E19, P02:45 | I05 (atlas aliases), I09 (props/materials), I11 (season key + seam) |
| Entitlement flag for Winter | **IN SCOPE as a setting** | gate is UI-only (`showcustomgame.inc:43-54`); assets base-install (F10 §5.1) | COORD stage 4 owns `config.gd`; today expose via existing `Data.BIOME` (§6) |
| Desert (`season=3`) texture/pattern pipeline | **DEFERRED if assets absent** | `desert_remap.json` exists but `desert_aliases.json` held `[U]` (A03 §2.2.4, `:115,207`; X15 Q6); F10 confirms desert is a *different pipeline* (§2.5) | Re-open after F10/COORD confirms aliases; label `[U]` until then |
| Baked DLC campaign `.map` files (49, 2.877 GiB) | **DEFERRED** | closed binary, frozen campaign content, no generator delta (F10 §1, §8.2) | D04 owns format; no skirmish value |
| `christmas` / `pump` event decor | **DEFERRED** | shipped families but `gc_halloween = gc_christmas = -1` (`dmscript.global:1668-1669`); stamping them is invention (F10 E35, §8.2) | no script assignment found (F10 U4) |
| NTM Spring/Autumn, Arctic, Taiga, 640/720 sizes | **DEFERRED / OUT** | mod-only claims, absent from donor install (F10 E41; `terrain.lib:12-15` aliases Spring/Autumn→Summer) | not donor-first scope |
| Winter mask variants / "snow" patterns | **OUT — do not invent** | masks shared across seasons (`build_winter_atlas.py:257`); zero `snow*`/`ice*` pattern files (F10 E36) | no asset to convert |

---

## 6. How the backend exposes a season key **without editing `config.gd` until stage 4**

**[D] The key already exists end-to-end in the port; reuse it, do not add one.**

1. `variant3d/scripts/config.gd:129` — `DEFAULT.gameplay.season = "summer"`.
2. `variant3d/scripts/config.gd:536` —
   `Data.BIOME = text("gameplay.season", text("gameplay.biome", "summer"))`.
3. `variant3d/scripts/data.gd:230` — `static var BIOME := "summer"`.
4. `variant3d/scripts/data.gd:258-259` —
   `SEASON_ENUM := {"summer": 0, "winter": 2, "desert": 3}`,
   `SEASON_DEFAULT := 0`.

**Contract for the fresh module (implementation-ready):**

```gdscript
# In I11-COMPOSER / the fresh backend only — NO config.gd edit.
var season_key: String = Data.BIOME              # "summer" | "winter" | "desert"
var season_id: int = int(Data.SEASON_ENUM.get(season_key, Data.SEASON_DEFAULT))
# atlas + aliases + palette are picked by season_key:
#   summer -> tile_index_atlas.manifest.json          + colour 0 / PHDR 0
#   winter -> tile_index_atlas_winter.manifest.json   + colour 6 / PHDR 1
#   desert -> [U] no alias set today; hold, do not fabricate
```

- **[D]** Because the atlas index dictionary is identical across seasons
  (F05 F05, `build_winter_atlas.py:33-34`), the shader's integer-id path needs
  no season branch; only the atlas path, aliases, prop policy and palette key
  change. This keeps the I11 seam additive (`world3d.gd` ternary `:609`,
  default `"legacy"`, V11/V04).
- **[D]** Winter prop policy is a boolean derived from `season_id == 2`:
  suppress `leaftree*`, select `detailw` + `<actor>a.mesh`, flip 86→110.
  Desert (`== 3`) has no approved policy today ⇒ log `[U]` and keep Summer
  behaviour rather than guessing.
- **[D]** `Data.TERRAIN_TINT` (`data.gd:266-272`) is an explicit **PORT
  APPROXIMATION flat tint** (`data.gd:262-265`); it must **not** be used as the
  season swap. The donor swap is tile-set + prop + palette, not a colour multiply.
- **[D]** `config.gd` stays untouched until COORD's stage-4 config owner
  (`V11:159`; reserved backup `COORD-STAGE4`) adds a typed accessor if desired.
  Today's `C3Config.value()/text()` already returns the string, so no new key is
  required. **[U]** whether `Data.BIOME` is populated before the terrain build in
  the fresh pipeline — no runtime trace was run; the composer must read it at
  bind/generate time, not at `_ready()` of a stale node.
- **[U]** whether a shipped install actually holds dlc2/deluxe entitlement —
  expose as a *setting* with default Summer; never silently enable Winter on
  the assumption of entitlement (F10 §8.1 item 5, §9 risk 4).

---

## 7. Implications for I05 / I09 / I11

**[D] Ownership is from `IMPLEMENTATION_PLAN.md:13,17,19`, `V11_ownership_ledger.md:97-106,141-143`
and `spec/12 §12.1`. This worker edits no code; these are contracts for those owners.**

### I05 — `variant3d/tools/build_terrain_new_atlas.py` (atlas + season aliases)
- Emit Summer default atlas (124-name index dictionary, 16×8, **no index
  remapping**) and Winter via the existing `winter_aliases.json` one-for-one
  rename; keep cells 86/110/123 EMPTY/transparent (A03 validation check 10;
  `build_winter_atlas.py:284-285`). **Do not fabricate art for the 4 unmapped
  winter PNGs** (`winter18/23/24/26`, `build_winter_atlas.py:38-39`).
- Carry the alpha masks **shared** across seasons; masks are season-agnostic
  (`build_winter_atlas.py:257`), so no winter mask variant is required.
- `desert_aliases.json`: emit empty `status:"UNVERIFIED — no season swap emitted"`
  (A03 §2.2.4, `:207`) **unless** COORD/F10 supplies a decoded alias set; the
  existing `desert_remap.json` is a name-rewrite table, not a second atlas.
- Preserve `visual_parity_claim:false` and `APPROX_ATLAS_DOWNSAMPLE` on any
  commit-tier cell size (A03 §2.2.1; V27 CORE-20).
- Validation: 124 entries, indices 0…123 contiguous, name array equals
  `presets_summer.json` (`build_winter_atlas.py:129-151`).

### I09 — `variant3d/scripts/terrain_donor_props.gd` (props/materials stage)
- Implement the Winter prop policy of §2.4: destroy `leaftree*` props, select
  building child material `detailw` **and** actor `<actor>a.mesh`, flip alpha
  ids 86→110; source winter material carriers from existing
  `prop_winter_materials.json` (P02:45) — no new snow/ice/palm props (F10 E36).
- Reuse committed `terrainmesh1..4` / `TerrainmeshProps_*` read-only
  (`V11 CR4`); do not instantiate a second silhouette layer.
- Desert props are **deferred**: base-install palm/`stonesdesert*`/mine/field
  assets are baked into DLC maps (F10 E37/E40), so cloning them into skirmish
  placement would be invention until the desert pipeline is re-opened.
- Season input comes from the composer's `season_key`/`season_id` (§6), not a
  config.gd accessor I09 does not own.

### I11 — seam + `terrain_donor_world.gd` composer (`I11-SEAM` / `I11-COMPOSER`)
- Keep the two-file seam (`main.gd` 4 inserts + `world3d.gd` const/var/setter/
  ternary `:609`/stats) additive, single owner, default `"legacy"`
  (`V11 CR1/CR2`, `spec/12 §12.1`). Create the composer **before** the seam.
- Expose season exactly as §6: read `Data.BIOME` + `Data.SEASON_ENUM`; pick
  atlas manifest/aliases, prop policy, palette table by that key; no new const,
  var, setter or stats key beyond the seam's agreed eight anchors.
- Do **not** add a `gameplay.season`-typed accessor or new key to `config.gd` —
  that is stage 4 (`V11:159`, `COORD-STAGE4`).
- Log `[U]` and fall back to Summer for `season=3` and for any entitlement
  uncertainty; never enable a gated season silently.

---

## 8. UNVERIFIED register (do not promote)

| ID | Question | Evidence gap | Resolves with |
|---|---|---|---|
| U-1 | **Whether the shipped install holds dlc2/deluxe (or dlc3/deluxe) entitlement at runtime** | Gate is UI text only (`showcustomgame.inc:43-54`); no entitlement query was run and no Steam state is in the donor tree | Owner/COORD decision as a setting; never auto-assume |
| U-2 | Runtime activity of `texturemap.inc` winter suffix / whole tile-selection script | All lines `;`-commented (F05 E08/G9); donor code stored as DScript text (D03 §1) | D08 live selection recovery or donor GPU frame |
| U-3 | How `WaterSet=Winter` resolves (`terrain.presets:135`) | `water.lib` has one `default` record (F10 §5.2) | Deeper water/material trace (F10 U3) |
| U-4 | Season value stored inside each DLC `.map` | `TMapSettingsGen.season` field names seen, values undecoded; zero `winter` tokens (F10 E38/U1) | D04 `.map` record decode |
| U-5 | Season 1 semantics | `gc_MaxSeasonCount=3` implies 0/1/2 but no donor art/branch for 1 (data.gd:255-257) | D09/editor UI trace; do not encode |
| U-6 | Whether `gc_christmas`/`gc_halloween` are ever set above −1 | Only assignments found are `= -1` (`dmscript.global:1668-1669`; F10 U4) | Full script/binary string sweep |
| U-7 | Desert alias set / whether `desert_remap.json` is complete | `desert_aliases.json` held `[U]` (A03 §2.2.4; X15 Q6); no `_desert` suffix rule | F10/COORD decision at I05; emit empty+UNVERIFIED meanwhile |
| U-8 | Whether `Data.BIOME` is populated before terrain bind in the fresh pipeline | No runtime trace; config.gd:536 is design-time apply | I11 composer integration test |
| U-9 | Exact effect of `AngleX/AngleZ=25` face ids in winter and port atlas downsample fidelity | face cells are identity copies (F05 G2); no A/B (V27 CORE-20) | donor GPU A/B; keep PORT APPROX |
| U-10 | Whether donor ever samples `alpha0a/b/c` at runtime and what `alphanull` yields | port cells are EMPTY; donor binds grass1+alphanull (F05 F04) | runtime trace / A/B |
| U-11 | **All visual similarity** — no donor GPU A/B frame exists | CHARTER.md:41,44,125 | Real capture; until then everything visual is PORT APPROXIMATION |

---

## 9. Open questions

1. **COORD:** confirm the TODAY scope is `Summer + gated Winter` only, with
   Desert deferred until `desert_aliases.json` is either decoded or explicitly
   declared out-of-scope (A03 §2.2.4, X15 Q6).
2. **COORD / owner:** how should the entitlement setting be named and defaulted
   (Summer regardless of entitlement), given no runtime entitlement evidence
   (U-1)? Should Winter be opt-in even when the assets are present?
3. **I11-COMPOSER:** confirm the season key is read from `Data.BIOME` at
   bind/generate time (§6) and that no `config.gd` edit lands before stage 4
   (`V11:159`).
4. **I09:** will the existing `prop_winter_materials.json` (P02:45) cover the
   `detailw` + `<actor>a.mesh` swap, or is a second derived carrier needed?
   (Do not author new winter prop art.)
5. **I05:** should Winter keep the 3 EMPTY alpha cells transparent (faithful to
   current port) or fill them with `grass1`+`alphanull` semantics (F05 Q3)?
   Either is a labelled PORT APPROXIMATION until U-10 resolves.
6. **D08 / X03:** can the `_winter` suffix rule be confirmed as *live* rather
   than commented intent (U-2), and is there any donor branch for season 1 (U-5)?
7. **F10 / D04:** does any shipped `.map` record actually store `season=2`
   numerically (U-4), or is Winter purely a skirmish-UI selection? This decides
   whether map loading needs a season key at all.

---

*End of X30 report. Exactly one repo file was written: this report. No donor
executable was run, no donor binary was copied, no source/asset/config/test/git
file was edited, and no Godot runner job was submitted. No donor parity claim is
made; every reproduced behaviour remains **PORT APPROXIMATION / UNVERIFIED**
until byte proofs and a real donor GPU A/B frame land (CHARTER.md:41,44,125).*
