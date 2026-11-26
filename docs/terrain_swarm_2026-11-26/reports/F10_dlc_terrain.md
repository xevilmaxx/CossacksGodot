---
id: F10-DLC-TERRAIN-2026-11-26
title: "DLC / expansion terrain additions relevant to shipped skirmish — donor READ-ONLY inventory"
owner: F10 (worker)
created: 2026-11-26
status: LANDED
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
scope_note: "Analysis only. No donor binary executed, no donor binary copied, no source/gate/asset edits. One report written: this file."
---

# F10 — DLC / expansion terrain additions relevant to skirmish

**Donor target:** `C:\Games\Cossacks 3` (read-only, private use). All paths below are
relative to that root unless stated. Prior art read first:
`docs/research/RC_TERRAIN.md` (S7/S8 mask families), `docs/research/RD_DLC.md`
(folder→DLC inference, port gap estimate), and the already-landed swarm reports
`F03_gen_config.md`, `F04_masks.md`, `F08_flora_minerals.md` (cross-referenced,
not overwritten). No donor-parity claim is made anywhere in this report.

---

## 0. Executive summary

1. **[O] The `dlcs/` tree contains no terrain-generation assets at all.** 67 files
   in 7 folders = 49 huge `.map` files + 18 tiny DScript `.aix` files, 3,089,187,248
   bytes (2.877 GiB). There is not a single `.tga`, `.dds`, `.pattern`, `.osm`,
   `.prop`, `.cfg`, `.inc` or manifest anywhere under `dlcs/**`. The .aix files
   only set `gPlayer[*].farm` / call `_misc_SetCampaignAch` (e.g.
   `dlcs/dlc3/data/maps/missions/turmis1.aix:1-16`). **[D] DLC "terrain" is baked
   campaign-map content, not new skirmish-generation logic.** These are DLC-only
   missions; they cannot be surfaced by cloning generator code.

2. **[O] The new skirmish map shapes do not live in `dlcs/`.** They live in the
   base install at `data/gen/terrainmasks.dlc5/**` (+1,856 TGA, 4 `.removed`, 1
   `moddersread.txt`; 70.21 MiB) and are selected by
   `data/game/var/generator.cfg:29-66` (`TerrainTypesDLC5`, 9 entries).
   `data/scripts/common.inc/dogenerate.inc:1542-1565` chooses that table for
   `gRecordGeneratorVersion>=91` and passes the chosen folder to `GenerateMap`
   with `BoolRegister0 := True` (random-map / skirmish path).
   `data/images/cached/news.cfg:30` advertises "New random map types: Coastal,
   Lakes, Rivers" as a **patch** feature. `showcustomgame.inc:141-157` exposes
   all 9 shapes with **no DLC entitlement check**. **[D] Coastal/Lakes/Rivers
   are shipped skirmish features in this donor, not DLC-only.**

3. **[O] Exact new-mask inventory:** coastal 57, lakes 151, rivers 157 = **365
   brand-new TGA masks**; mediterranean 207 vs 118 vanilla TGA (+89); continent
   167 vs 121 (+46), continents 196 vs 187 (+9), islands 330 vs 320 (+10),
   peninsulas 286 vs 280 (+6). Total delta vs `terrainmasks/`: **+525 TGA**,
   +20.14 MiB. 31 same-named masks (8 continent + 23 mediterranean) are
   *modified*, not just added. `terrainmasks.src/**` has only the 8 old shapes —
   **no source masks for coastal/lakes/rivers**.

4. **[D] Channel semantics in the final `_gauss` masks:** B = water bed
   (0..255 blurred, −1.1·B/255 height), R = relief-class code (255 plateau,
   96 hill, 48 ravine, smooth variants) but is 0 on almost all shipped gauss
   masks, G = forest/stone class (0 on shipped gauss masks), and pure white
   (R=G=B=255) = start marker; white-pixel count equals the `Xpl_` prefix.
   `.src` masks carry binary B=water + white starts. Full decode is F04's
   ownership; this report supplies the DLC delta and cross-checks the semantics.

5. **[O] Seasons are DLC-gated in the shipped skirmish UI:** winter (`season=2`)
   requires `gc_lastknowndlc_dlc2` or deluxe, desert (`season=3`) requires
   `gc_lastknowndlc_dlc3` or deluxe (`showcustomgame.inc:43-54,178-201`;
   `dmscript.global:1642-1645,237`). The assets themselves are base-install:
   27 `winter*.dds` block textures, 12 `desert*.dds`, 121 `*_winter` tile blocks,
   `terrain.presets:134-136` `Winter/Winter` set, `tiles.season:1-4`. Swap is by
   name suffix (`texturemap.inc:525-527`), material `detail`→`detailw`
   (`miscext.script:1589-1596`), leaftree destruction (`miscext.script:1568-1575`),
   alpha tile `alpha0a`→`alpha0b` (`:1609-1626`) and colour table 6/PHDR 1
   (`onloadfull.inc:70-79`). **[D] Winter = DLC2 skirmish feature; summer =
   vanilla baseline.**

6. **[D] No DLC-only pattern family exists.** `generator.cfg` holds 64 `Name =`
   families, all in the base install, including `christmas` (`new_year6..10`,
   :1603-1627), `pump` (`k_pump_1..15`, :1538-1602) and ~20 `desert_*` families.
   The event switches `gc_halloween`/`gc_christmas` are hard-coded `-1` in
   `dmscript.global:1668-1669`, so those decorations are dormant in the shipped
   skirmish. DLC maps merely *bake* base props (palm/desert trees,
   `stonesdesert*`, `minegold/mineiron/minecoal`, `field*`) into their binary.

7. **[I] Scope recommendation (PORT APPROXIMATION):** clone today the
   shipped-skirmish path — 9-entry shape table + full `terrainmasks.dlc5` mask
   corpus + B-channel water/height decode + season swap plumbing; defer all 49
   baked DLC `.map` files, event decorations, and any attempt to infer a DLC
   manifest. No parity claim: no donor GPU A/B frame was produced.

---

## 1. Evidence table

| # | Donor path:line / offset | Observation | Label |
|---|---|---|---|
| E1 | `dlcs/**` full recursive listing (67 files) | Only `data/maps/missions/*.map` (49) and `*.aix` (18); no other extension, no manifest | [O] |
| E2 | `dlcs/dlc1/.../polmis1.aix:1-16`, `dlcs/dlc3/.../turmis1.aix:1-16`, `dlcs/winter/.../celmis1.aix:1-16` | DScript only sets farm values / achievement; no terrain, season or generator calls | [O] |
| E3 | `dlcs/**/*.map:0x00-0x80` | Header `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, `UID<digits>`, `GameMapSnapShotBegin/End`, `GameMapRecordBegin`; opaque binary thereafter | [O] |
| E4 | `data/game/var/generator.cfg:2-28` | Legacy `TerrainTypes` = 6 shapes; live Land path is `terrainmasks\nowater2` (`:6`), `terrainmasks\land` commented out (`:5`) | [O] |
| E5 | `data/game/var/generator.cfg:29-66` | `TerrainTypesDLC5` = 9 shapes; indices 6/7/8 = Coastal/Lakes/Rivers pointing at `.\data\gen\terrainmasks.dlc5\{coastal,lakes,rivers}` | [O] |
| E6 | `data/scripts/dmscript.global:236` | `gc_MaxTerrainTypeCount = 9` | [O] |
| E7 | `data/scripts/common.inc/dogenerate.inc:1542-1565` | `<91` → legacy 6-shape table, random `floor(RandomExt*6)`; `>=91` → `TerrainTypesDLC5`, random over 9; `BoolRegister0 := True` then `ExecuteState('GenerateMap')` | [O] |
| E8 | `data/gui/menu.inc/showcustomgame.inc:141-157` | Combo box filled for `i=0..gc_MaxTerrainTypeCount-1`; labels `i>=6` resolved through `_misc_GetNewTextLocale`; no DLC gate; `text.random` appended as last item | [O] |
| E9 | `data/locale/en/gui.txt:423-434,855-862` | Shape labels 0..5 = Land..Single Continent; `.6=Lakes`, `.7=Coast`, `.8=Rivers`, `.9=Without water` | [O] |
| E10 | `data/images/cached/news.cfg:30` | In-game news: "4. New random map types: Coastal, Lakes, Rivers." | [O] |
| E11 | `data/gen/terrainmasks.dlc5/moddersread.txt:1-10` | `Xpl_` = number of starts; `_gauss` = postprocessed from `terrainmasks.src`; 320×320 output vs 256×256 source; gauss = "smooth with noised water borders" | [O] |
| E12 | recursive file census of the three mask folders | vanilla 1,331 TGA +4 `.removed`+1 txt = 1,336 files / 50.97 MiB; dlc5 1,856 TGA +4 `.removed`+1 txt = 1,861 files / 70.21 MiB; src 1,279 TGA +2 root txt = 1,281 files / 6.75 MiB | [O]/[D] |
| E13 | per-shape counts in `terrainmasks.dlc5/**` | coastal 57 (2pl17/3pl8/4pl10/6pl13/8pl9); lakes 151 (2pl31/3pl18/4pl27/5pl15/6pl19/7pl15/8pl26); rivers 157 (2pl32/3pl17/4pl25/5pl17/6pl17/7pl17/8pl32) | [O] |
| E14 | SHA-256 comparison `terrainmasks/<shape>` vs `terrainmasks.dlc5/<shape>` | 230 land, 42 nowater, 33 nowater2 byte-identical; 320/320 islands, 280/280 peninsulas, 187/187 continents; **8/121 continent + 23/122 mediterranean differ** | [O] |
| E15 | `terrainmasks.dlc5/lakes/2pl_mask_lakes_0_gauss.tga:0x00-0x11` and full RLE payload | TGA type 10, 24 bpp, 320×320, descriptor 0; byte0 (B) = 0..255 water ramp (mean 0.086), byte1 (G)=0, byte2 (R)=0 except 2 white pixels at (267,159),(56,160) | [O] |
| E16 | `terrainmasks.dlc5/rivers/8pl_mask_rivers_7_gauss.tga` decoded | 8 white start markers at (289,23),(25,24),(261,118),(108,127),(227,210),(116,237),(26,296),(290,296); mean B = 0.053 | [O] |
| E17 | `terrainmasks.dlc5/coastal/6pl_mask_coastal_0_gauss.tga` decoded | 6 white starts; mean B = 0.060; water coverage higher than lakes but lower than mediterranean (0.172 sample mean) | [O]/[D] |
| E18 | `terrainmasks.src/islands/2pl_mask_islands_0.tga:0x12+` | 256×256, descriptor 0x20 (top-left), byte0(B)=255 on 40,785 px (water), byte2(R)=0 except 2 white starts | [O] |
| E19 | `data/scripts/common.inc/generatemap.inc:21-32` | R codes 255/191/96/112/48/88; G codes 255/127/64/128/192; B water code 255 | [O] |
| E20 | `generatemap.inc:159-192` | Mask bucket search: `for i:=plcount to gc_MaxPlayerCount-1`, `ParserGetFilesInRoot(folder+'\'+IntToStr(i)+'pl*.tga')`, first non-empty bucket, `floor(RandomExt*count)` | [O] |
| E21 | `generatemap.inc:311-395,444-495` | White pixel (fr=fg=fb=1) = start; R→terrain/smooth class, G→forest class, B→water class | [O] |
| E22 | `generatemap.inc:537-577` | `hwater = cWaterHeight*(fb*(1+fr*3.5))`, `cWaterHeight = -1.1`; `hterrain` from R class; `SetHeightData(hwater+hterrain)` | [O] |
| E23 | `data/scripts/common.inc/postprocess.inc:43-50,418-442` | Gauss pipeline copies relief to R and water to B, noise, two blur passes (r=0.00001 then 0.925), writes `bitmaptrg.bmp` | [O] |
| E24 | `data/gui/menu.inc/showcustomgame.inc:43-54,178-203` | `bAllowWinter` = dlc2 or deluxe; `bAllowDesert` = dlc3 or deluxe; season combo filters i=1 (winter) / i=2 (desert); tags 0/2/3 | [O] |
| E25 | `data/scripts/dmscript.global:1642-1645,1668-1669,237` | DLC bit flags; `gc_halloween = -1`, `gc_christmas = -1`; `gc_MaxSeasonCount = 3` | [O] |
| E26 | `data/locale/needloc/new.txt:219-224` | Season labels: "Season", "Summer", "Winter" (new-text locale = post-base strings) | [O] |
| E27 | `data/terrain/tiles/terrain.presets:2-4,134-136,261-263` | Two sets: `Summer/WaterSet=Summer` and `Winter/WaterSet=Winter`, 121 blocks each; last block `alpha0c` | [O] |
| E28 | `data/terrain/tiles/textures/**` | 115 files / 75.08 MiB: 27 `winter*.dds`, 12 `desert*.dds`, 23 `sand*.dds`, 16 `grass*.dds`, 16 `rock*.dds`, 26 `test*.dds` | [O] |
| E29 | `data/terrain/tiles/tiles.lib` and `tiles.mat` | 121 / 124 distinct `*_winter` tile-block tokens (incl. `alpha0a/b/c_winter`, `desert1..12_winter`) | [O] |
| E30 | `data/scripts/common.inc/texturemap.inc:525-527`, `:605-607`, `:639-641`, `:927-951` | On `GetSeasonType=2`, tile block name gains `_winter` before `MapGetTileIndexByTileBlock` | [O] |
| E31 | `data/scripts/lib/miscext.script:1547-1627` | `_misc_SetSeason`: destroys `leaftree` props in winter, swaps child material `detail`→`detailw`, swaps alpha0a↔alpha0b | [O] |
| E32 | `data/scripts/common.inc/onloadfull.inc:70-79`, `dogenerate.inc:2075-2084` | Winter → colour table 6 + PHDR 1; desert → table 7; otherwise table 0 + PHDR 0 | [O] |
| E33 | `dogenerate.inc:4,1532-1535,1589-1590` | `bDesert = (season=3)`; `SetupTiledPatterns('desert_tiles')` vs `('tiles')`; `_misc_SetDesert(False,False)` before stamping | [O] |
| E34 | `data/game/var/generator.cfg:1603-1627,1538-1602` | `christmas` family = `new_year6..10`; `pump` family = `k_pump_1..15` | [O] |
| E35 | `data/scripts/dmscript.global:1668-1669`; `dogenerate.inc:1848-1851` | Pump patches only when `gc_halloween>0 and season<>2`; Christmas patches only when `gc_christmas>0`; both constants are −1 | [O] |
| E36 | `data/pattern/**` census | 710 `.pattern` + `pattern.lib` (30,309,138 B). `new_year1..10`, `k_pump_01..15`, 153 `desert*`, 23 `l_lake*`, 32 `m_swamp*`, 0 `snow*`/`ice*`/`palm*` pattern files | [O] |
| E37 | `dlcs/dlc3/.../turmis1.map:0x2804095` (`palm`), `:0x2c66105` (`desert3`), `:0x2c9f0ca` (`stonesdesert10`), `:0x27e8459` (`minegold`), `:0x10ffd8` (`field`), `:0x2cb9afc` (`grassdesert`) | Baked prop/tile names inside DLC map binary (ASCII scan) | [O] |
| E38 | `dlcs/winter/.../celmis1.map:0x32aaaed` (`stonessea5`), `:0x2b4e5ea` (`grassforest`), `:0x324ba14` (`minegold`), `:0x9a7089` (`field`) | Winter-event map still bakes summer-named tile/block strings; no `winter` token anywhere in this map | [O] |
| E39 | `dlcs/dlc4/.../netmis1.map:0x825f0c7` (`palm`), `:0x825f484` (`desert5`), `:0x8259d6b` (`minecoal`) | Golden Age Brazil mission reuses base desert/palm assets | [O] |
| E40 | `data/actors/env/palm.actor`, `palm1..5.osm`, `palmsmall*.osm`, `desert1..5.actor/.1..3.osm`, `objects/env/minegold.prop`, `materials/env/palm1w.dds`, `minegoldw.dds` | All "DLC-looking" trees/rocks/mines are base-install assets with winter material variants | [O] |
| E41 | `docs/research/RC_TERRAIN.md:26-27,73,146` (S7/S8 prior art) | EMOM/NTM claims 736 extra masks, 151 lakes/57 coastal/157 rivers, 100 new med, plus Spring/Autumn, Taiga/Black Forest, new sizes — these are **mod** claims, not donor-install facts; donor has 525 extra TGA and no Spring/Autumn season options | [O] prior art + [D] comparison |
| E42 | `docs/research/RD_DLC.md:59-73` | Folder→DLC name mapping is inferred (no manifest); retained as [U], not re-derived here | [U] |

---

## 2. Finding F1 — what `dlcs/**` actually contains

### 2.1 Exact file census [O]

Read-only recursion over `C:\Games\Cossacks 3\dlcs` (every file, no binaries run):

| Folder | Files | `.map` | `.aix` | Bytes | MiB | DLC name (inferred, RD_DLC.md §2) | Terrain-generation content |
|---|---:|---:|---:|---:|---:|---|---|
| `dlc1` | 20 | 10 (`polmis1-5`, `scemis1-5`) | 10 | 573,394,374 | 546.9 | Days of Brilliance | none |
| `dlc2` | 13 | 13 (`prumis1-5`, `scemis6-8`, `swemis1-5`) | 0 | 707,889,596 | 675.2 | Rise to Glory | none |
| `dlc3` | 14 | 10 (`spamis1-5`, `turmis1-5`) | 4 | 582,925,795 | 555.8 | Path to Grandeur | none |
| `dlc4` | 11 | 9 (`netmis1-5`, `scemis9-12`) | 2 | 798,232,020 | 761.3 | The Golden Age | none |
| `exp1` | 5 | 5 (`scomis1-5`) | 0 | 285,374,874 | 272.1 | Highlands / Scotland | none |
| `summer` | 2 | 1 (`celmis2`) | 1 | 87,382,209 | 83.4 | Summer Holiday event | none |
| `winter` | 2 | 1 (`celmis1`) | 1 | 53,988,380 | 51.5 | Winter Holiday event | none |
| **Total** | **67** | **49** | **18** | **3,089,187,248** | **2,877.0** | — | **none** |

Map bytes = 3,089,178,735; `.aix` bytes = 8,513. Every `.aix` is 393–833 bytes
and contains only farm-value constants plus an `ach` state that calls
`_misc_SetCampaignAch(StringRegister0)` (E2). There is no `SetSeasonType`,
`GenerateMap`, `TerrainTypes`, mask path, pattern family or terrain call in any
`.aix`.

### 2.2 Map binary evidence [O]/[D]

All 49 maps share the header at offset `0x00`: length-prefixed
`OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, a `UID<digits>` token,
then `GameMapSnapShotBegin` / `GameMapSnapShotEnd` / `GameMapRecordBegin`
(E3). The terrain/tile payload after that is opaque to this worker (D04
ownership). Read-only ASCII scans reveal baked object names (E37–E39) and the
serialised *type* record `TMapSettingsGen` with fields `randkey0/1`, `mapsize`,
`terraintype`, `relieftype`, `resourcestart`, `resourcemines`, `season`
(e.g. `dlcs/dlc2/.../prumis1.map:0x9033fe-0x90350b`). **No actual season value
was decoded** (see U1). The string `winter` occurs **0 times** in every DLC
map, including `dlcs/winter/.../celmis1.map`; the only `season` strings are the
type definition and `.\data\terrain\tiles\tiles.season` resource path
(`celmis1.map:0x2111c32`).

**[D] Implication:** the DLC contribution to terrain is *content*, not
*algorithm*: hand-/generator-baked maps whose terrain was frozen into the
`.map` binary. Cloning the skirmish generator will not reproduce any DLC
mission, and cloning the DLC folders cannot add a skirmish feature.

### 2.3 Folder→DLC mapping [U]

As RD_DLC.md:69-73 already records, the folder names are opaque and contain no
manifest. No new evidence was found. The mapping in the table is inherited
prior art, not an observation of this worker.

---

## 3. Finding F2 — new map shapes: Coastal / Lakes / Rivers

### 3.1 Donor wiring [O]

`data/game/var/generator.cfg:2-28` defines legacy `TerrainTypes` (6 shapes),
with live Land path `.\data\gen\terrainmasks\nowater2` (`:6`) and the more
obvious `terrainmasks\land` commented out (`:5`).
`generator.cfg:29-66` defines `TerrainTypesDLC5` with 9 entries:

| idx | hint | path (all under `.\data\gen\terrainmasks.dlc5\`) |
|---:|---|---|
| 0 | Land | `nowater2` |
| 1 | Mediterranean | `mediterranean` |
| 2 | Peninsulas | `peninsulas` |
| 3 | Islands | `islands` |
| 4 | Continents | `continents` |
| 5 | Continent | `continent` |
| 6 | Coastal | `coastal` |
| 7 | Lakes | `lakes` |
| 8 | Rivers | `rivers` |

`dogenerate.inc:1542-1565` selects the table by replay/generator version:
`<91` uses the 6-shape table and `floor(RandomExt*6)`; `>=91` uses
`TerrainTypesDLC5` and `floor(RandomExt*gc_MaxTerrainTypeCount)` (9). It then
sets `BoolRegister0 := True` and `StringRegister0 := path`, and calls
`ExecuteState('GenerateMap')`. **[O]** `BoolRegister0=True` is the `bRandomMap`
flag consumed at `generatemap.inc:61`, i.e. this is the skirmish path.

`showcustomgame.inc:141-157` fills the shape combo from `i=0` to
`gc_MaxTerrainTypeCount-1` with no entitlement test; labels for `i>=6` come
from `_misc_GetNewTextLocale`, consistent with post-base "new text" locale
entries. `data/images/cached/news.cfg:30` explicitly calls the three shapes a
patch feature. **[D] Conclusion: Coastal/Lakes/Rivers are shipped skirmish
content in this install, available even without any DLC entitlement.**

### 3.2 Exact counts, player prefixes and deltas [O]

All counts below are files in `data/gen/terrainmasks.dlc5/<shape>/`;
`*.removed` files are excluded from TGA counts.

| Shape | TGAs in dlc5 | TGAs in vanilla | Delta | `Xpl_` breakdown (dlc5) | Byte total |
|---|---:|---:|---:|---|---:|
| coastal | 57 | 0 | **+57** | 2pl 17, 3pl 8, 4pl 10, 6pl 13, 8pl 9 | 1,187,825 |
| lakes | 151 | 0 | **+151** | 2pl 31, 3pl 18, 4pl 27, 5pl 15, 6pl 19, 7pl 15, 8pl 26 | 3,019,057 |
| rivers | 157 | 0 | **+157** | 2pl 32, 3pl 17, 4pl 25, 5pl 17, 6pl 17, 7pl 17, 8pl 32 | 9,202,951 |
| mediterranean | 207 (+4 `.removed`) | 118 (+4) | +89 | 2pl 57, 4pl 102, 7pl 20, 8pl 32 | 6,835,134 |
| continent | 167 | 121 | +46 | 2pl 32, 4pl 100, 7pl 20, 8pl 15 | 5,365,617 |
| continents | 196 | 187 | +9 | 2pl 40, 3pl 29, 4pl 97, 7pl 20, 8pl 10 | 11,902,142 |
| islands | 330 | 320 | +10 | 2pl 100, 3pl 99, 4pl 100, 7pl 20, 8pl 11 | 18,489,912 |
| peninsulas | 286 | 280 | +6 | 2pl 75, 3pl 99, 4pl 85, 7pl 20, 8pl 7 | 14,297,710 |
| land / nowater / nowater2 | 230 / 42 / 33 | same | 0 | unchanged | 3,027,532 / 164,676 / 129,336 |
| **Total TGAs** | **1,856** | **1,331** | **+525** | — | **73,622,741 B incl. txt/removed** |

**[O] Byte-level comparison** (SHA-256 over every same-named file): all 230
`land`, 42 `nowater`, 33 `nowater2`, 320 `islands`, 280 `peninsulas` and 187
`continents` masks are byte-identical between vanilla and dlc5. 113/121
`continent` and 99/122 `mediterranean` are identical; the remaining **8
continent + 23 mediterranean masks were replaced**. Examples:
`terrainmasks/continent/4pl_mask_continent_78_gauss.tga` 25,940 B →
`terrainmasks.dlc5/continent/4pl_mask_continent_78_gauss.tga` 25,944 B;
`terrainmasks/mediterranean/4pl_mask_mediterranean_79_gauss.tga` 11,354 B →
dlc5 11,358 B. **[I]** these are likely start-spacing / shore fixes (S7 mentions
EMOM fixed bad masks), but no per-pixel semantic diff was performed here.

**[O] `terrainmasks.src/**` contains only 7 source folders** (continent,
continents, islands, land, mediterranean, nowater, peninsulas; 1,279 TGA + 2
root txt). There are **no `coastal`, `lakes`, `rivers` or `nowater2` source
masks**, so a source→gauss rebuild of the new shapes is not possible from donor
data alone. `convert_rle.bat` (170,764 B) lists only the old shapes' BMP→RLE TGA
conversions.

### 3.3 Water-bed statistics per new shape [O]/[D]

Full RLE decode, 320×320 pixels, 10 randomly sampled masks per shape (seed 42),
B-channel mean /255 and fraction B>128:

| Shape | mean(B)/255 | frac(B>128) | Interpretation [D] |
|---|---:|---:|---|
| nowater2 | 0.000 | 0.000 | dry baseline |
| lakes | 0.079 | 0.078 | small inland water fraction |
| rivers | 0.102 | 0.099 | linear water network |
| coastal | 0.142 | 0.142 | edge water, more than lakes |
| mediterranean | 0.172 | 0.172 | largest old-shape fraction among these |
| peninsulas | 0.393 | 0.392 | — |
| continents | 0.511 | 0.509 | — |
| islands / continent | 0.652 / 0.641 | 0.650 / 0.640 | water-dominated |

These are sample statistics, not full-corpus claims; F04 has the exhaustive
histograms. **[D]** The three new shapes are distinguished by *water fraction
and topology*, not by new mask channels or new pixel formats.

### 3.4 Player-count fallback [O]/[D]

`generatemap.inc:159-192` counts existing non-spectator players, then scans
`for i:=plcount to gc_MaxPlayerCount-1` for the first `<i>pl*.tga` bucket and
picks `floor(RandomExt*count)` within it. `gc_MaxPlayerCount = 12`
(`dmscript.global:97`), but mask prefixes stop at `8pl`; an explicit guard at
`generatemap.inc:165-169` logs "8th player not yet supported" and clamps when
`plcount>=12`.

**[D]** Consequences for the new shapes: a 5-player game on Coastal (no `5pl`
bucket) falls back to the `6pl` bucket; a 7-player game on Coastal falls back to
`8pl`; Lakes/Rivers have explicit `5pl`,`6pl`,`7pl`,`8pl` buckets and need no
fallback. Coastal has **no `7pl` mask at all**, contrary to
`moddersread.txt:4` ("all folders should have at least one `7pl_*`").

### 3.5 UI label mismatch [O] + [I]

`generator.cfg:55-64` maps index 6→Coastal, 7→Lakes, 8→Rivers, but
`locale/en/gui.txt:855-860` maps `.6=Lakes`, `.7=Coast`, `.8=Rivers`.
`showcustomgame.inc:153` stores the loop index `i` as combo item data and
`miscext2.script:2627` assigns that integer straight to
`map.settings.gen.terraintype`, so **[I] the visible labels for Coastal and
Lakes appear swapped relative to the mask folders**. UNVERIFIED visually (no
donor binary run); recorded as U2.

---

## 4. Finding F3 — mask channel semantics (DLC delta cross-check)

Full bit-level decode is F04's deliverable; this section restates only what is
needed to understand the new folders and flags one correction to prior art that
this worker verified.

- **[O] Source masks** (`terrainmasks.src/**`, e.g.
  `islands/2pl_mask_islands_0.tga:0x12+`): TGA type 10, 24 bpp, 256×256,
  descriptor `0x20` (top-left). Byte order is B,G,R. B is binary 0/255 water
  (40,785 of 65,534 non-start pixels = 255 in the cited file); R and G are 0
  except exactly `X` white pixels for `Xpl_`.
- **[O] Final masks** (`terrainmasks.dlc5/**`, e.g.
  `lakes/2pl_mask_lakes_0_gauss.tga:0x00-0x11`): TGA type 10, 24 bpp, 320×320,
  descriptor `0x00` (bottom-left). B is a 0..255 blurred water bed; G is 0; R
  is 0 except white start markers. Decoded starts match the filename prefix
  exactly: 2 in `2pl_mask_lakes_0_gauss.tga` at (267,159)/(56,160); 8 in
  `8pl_mask_rivers_7_gauss.tga`; 6 in `6pl_mask_coastal_0_gauss.tga`; 4 in
  `4pl_mask_nowater_170_gauss.tga`.
- **[O] Script semantics** (`generatemap.inc:21-32,311-395,454-495`): R class
  codes 255 plateau / 191 plateau-smooth / 96 hill / 112 hill-smooth / 48
  ravine / 88 ravine-smooth, else `cRNone`; G codes 255 forest / 127 half /
  64 generated forest / 128 stone / 192 forest+stone; B=255 → water class;
  alpha>0 → `broad`; white → start marker; `gPatternMask` false for all-black
  or all-white pixels.
- **[O] Height conversion** (`generatemap.inc:563-574`):
  `hwater = -1.1 * fb * (1 + 3.5*fr)`; `hterrain` from R class; sum is written to
  `SetHeightData`. With final-mask `fr≈0` on most pixels, height is essentially
  `−1.1·fb`, so the B ramp is the operative water/shore field.
- **[O] Postprocess** (`postprocess.inc:43-50,418-442`): source relief is raised
  to `cRColorPlateau`, water copied to B, noise added, then two Gaussian passes
  (`r=0.00001`, `r=0.925`) produce `bitmaptrg.bmp`; `moddersread.txt:6,8`
  describes the same 256→320 px gauss step.

**[D] Correction note:** a naive first pass over a single lakes mask can
mistake the blurred B ramp for the relief channel because TGA stores B in byte
0. The verified mapping is **B=water bed, R=relief class, G=forest/stone**, in
agreement with F04 (`F04_masks.md:176-242,448-493`). No road-mask channel is
claimed; F04 explicitly leaves that undefined (`F04_masks.md:187`).

---

## 5. Finding F4 — season texture sets, DLC gating and swap

### 5.1 Entitlement [O]

| Season value | UI option | Gate | Donor evidence |
|---:|---|---|---|
| 0 | Summer | none (vanilla) | `showcustomgame.inc:182-183`; `needloc/new.txt:221-222` |
| 2 | Winter | `gc_lastknowndlc_dlc2` **or** `gc_lastknowndlc_deluxe` | `showcustomgame.inc:43,49-50,185-186,190-191` |
| 3 | Desert | `gc_lastknowndlc_dlc3` **or** deluxe | `showcustomgame.inc:44,52-53,187-188,192-193` |

`gc_MaxSeasonCount = 3` (`dmscript.global:237`); DLC bits at
`dmscript.global:1642-1645`. `SetMapFromName` also forces season back to 0 if
the entitlement is missing (`showcustomgame.inc:47-54`). **[D] Winter is a
DLC2 skirmish feature; desert is DLC3; both assets ship in the base install.**

### 5.2 Texture sets [O]

- `data/terrain/tiles/textures/`: 115 files / 78,835,714 B, of which
  **27 `winter*.dds`**, **12 `desert*.dds`**, 23 `sand*.dds`, 16 `grass*.dds`,
  16 `rock*.dds`, 26 `test*.dds`.
- `data/terrain/tiles/terrain.presets:2-4` = `SetName=Summer`,
  `WaterSet=Summer`, `DefaultIndex=0`; `:134-136` = `SetName=Winter`,
  `WaterSet=Winter`, `DefaultIndex=0`; 121 `TileBlock` entries each; final
  block `alpha0c` at `:261`.
- `data/terrain/tiles/tiles.lib` has 121 `*_winter` tokens, `tiles.mat` 124
  (adds `alpha0a_winter`, `alpha0b_winter`, `alpha0c_winter`).
- `data/terrain/tiles/tiles.season:1-4`: `TexName=grass1`, `Summer=grass1` — the
  resource path embedded in every DLC map (`celmis1.map:0x2111c32`).
- `data/terrain/tiles/terrain.lib:2-15`: `Default=Summer`;
  `seasons.Summer=Summer`, `seasons.Autumn=Summer`, `seasons.Winter=Winter`,
  `seasons.Spring=Summer`. **[D]** Autumn/Spring alias Summer; only Winter is a
  real second set. This contradicts the mod claims in `RC_TERRAIN.md:27` (S8
  NTM Spring/Autumn) — those are mod-only, not donor-install.
- `data/water/water.lib` has a single `default` water record; no separate
  Winter water definition. `WaterSet=Winter` is a preset pointer whose
  resolution is **UNVERIFIED** (U3).

### 5.3 Swap mechanics [O]

1. **Tile names:** `texturemap.inc:525-527,605-607,639-641,927-951` append
   `_winter` to the computed tile-block name before `MapGetTileIndexByTileBlock`
   when `GetSeasonType=2`; `smoothforestborders.inc:138-139` and
   `loadenvironmentfrombitmap.inc:71-72` do the same.
2. **Props:** `_misc_SetSeason` (`miscext.script:1547-1627`) destroys every
   object whose base name contains `leaftree` in winter (`:1568-1575`), swaps
   building child material `detail`→`detailw` (`:1585-1597`), and flips tile
   `alpha0a`↔`alpha0b` (`:1609-1626`). `dogenerate.inc:1975-1981` repeats the
   leaftree destruction during generation.
3. **Palette:** winter → `SetCurrentColorTableIndex(6)` +
   `SetCurrentPHDRIndex(1)`; desert → table 7; otherwise table 0 / PHDR 0
   (`onloadfull.inc:70-79`, `dogenerate.inc:2075-2084`).
4. **Desert is a different pipeline:** `bDesert=(season=3)`
   (`dogenerate.inc:4`); `SetupTiledPatterns('desert_tiles')` vs `('tiles')`
   (`:1532-1535`); `_misc_SetDesert(False,False)` (`:1589-1590`) rewrites tile
   names grass→sand/desert/test and rocks→desert variants
   (`miscext.script:1447-1479`).
5. **Event decorations:** `dogenerate.inc:1848-1851` stamps `pump` family only
   if `gc_halloween>0` and season≠2, and `christmas` family only if
   `gc_christmas>0`; both constants are `-1` in `dmscript.global:1668-1669`, so
   **[D] dormant in the shipped skirmish unless a mod/event sets them**
   (U4: no script assignment found).

### 5.4 DLC maps vs the season system [O]/[D]

`dlcs/winter/celmis1.map` contains **zero** `winter` ASCII tokens; its props are
`grassforest*`, `stonessea*`, `minegold`, `field` (E38). Its season integer is
not decodable with the information recovered here (U1). **[D]** The "winter
map" is not a texture-set switch stored as a name in the map; whatever season
it uses is either a numeric setting or the campaign's environment handling.
Do not infer "winter tiles" from the folder name.

---

## 6. Finding F5 — pattern families, trees, rocks, mines, fields

### 6.1 Family inventory [O]

`generator.cfg` contains **64 `Name =` records** (some duplicated:
`desert_mng/mni/mnc` and `plain_medium` appear twice — F03 notes shadowing).
Semantic groups [I]: relief (`plain_*`, `ravine_*`, `plateau*`, `mountains`,
`hills_*`, `decor*`, `tiles`, `desert_*` relief), mines/stone (`stones`,
`stoneforests`, `desert_stones`, `desert_stoneforests`), forests (`forests_*`,
`desert_forests_*`), water (`lake_*`, `swamp_*`, `desert_lake`, `pump`),
market/start (`mng/mni/mnc`), seasonal (`christmas`, `pump`).
Exact counts and offsets are F03's (`F03_gen_config.md:667,740-741,761`); F10
confirms **none of these families originates inside `dlcs/**`**.

### 6.2 Pattern files [O]

`data/pattern/`: 710 `.pattern` + `pattern.lib` (30,309,138 B). Relevant
prefixes: `new_year1..10` (10), `k_pump_01..15` (15), `desert*` (153),
`l_lake*` (23), `m_swamp*` (32), `g_mnt_*` (7); **zero** `snow*` / `ice*` /
`palm*` pattern files (palm trees are props inside `desert_*` patterns, F08:142-145).
There is no "arctic" family in the donor install — `RC_TERRAIN.md:26,146`
attributes Arctic to EMOM/NTM **mods**, not to the shipped game.

### 6.3 What the DLC maps bake [O]

Read-only ASCII token scans of the map binaries (counts are token occurrences,
not unique object counts — binary noise is filtered by requiring known name
prefixes):

| DLC map | Evidence (path:offset) | Baked families |
|---|---|---|
| `dlc3/.../turmis1.map` | `0x2804095` `palm`, `0x2c66105` `desert3`, `0x2c9f0ca` `stonesdesert10`, `0x27e8459` `minegold`, `0x10ffd8` `field`, `0x2cb9afc` `grassdesert` | desert trees (`desert1..5`, `palmsmall*`, `palm1..5`), desert stones, gold/iron/coal mines, fields, desert grass tiles |
| `dlc4/.../netmis1.map` | `0x825f0c7` `palm`, `0x825f484` `desert5`, `0x8259d6b` `minecoal` | same base families reused for Brazil |
| `winter/.../celmis1.map` | `0x32aaaed` `stonessea5`, `0x2b4e5ea` `grassforest`, `0x324ba14` `minegold`, `0x9a7089` `field` | sea stones, forest grass, mines, fields |
| `dlc4/.../netmis3.map` | `0x29f1b2c` `coastal_patrol` | scenario object name, not a terrain asset |
| every DLC map | `~0x1c.../0x2x...` type records | `TMapSettingsGen` fields but no new asset names |

The underlying assets are base-install: `data/actors/env/palm.actor`,
`palm1..5.osm`, `palmsmall*.osm`, `desert1..5.actor/.1..3.osm`,
`data/objects/env/minegold.prop`, `data/materials/env/palm1w.dds`,
`minegoldw.dds`, etc. **[D] No new tree/rock/mine/field asset family is added
by any DLC folder.** F08 already documents the pattern→prop→actor→mesh chains,
winter material swaps and ore scales (`F08_flora_minerals.md:100-104,187-209`);
this report confirms the DLC maps only consume them.

---

## 7. Coverage table

Legend: **IN** = present in shipped skirmish path of this donor; **DLC** =
entitlement-gated skirmish option; **MAP** = baked into DLC mission `.map`
only; **MOD** = claimed by EMOM/NTM prior art, absent from donor install;
**UNVERIFIED** = not decidable with recovered evidence.

| Feature | Donor anchor | Status | Skirmish relevance | Clone today? |
|---|---|---|---|---|
| 6 legacy shapes (Land/Med/Pen/Islands/Continents/Continent) | `generator.cfg:2-28`, `dogenerate.inc:1547-1551` | IN | yes (legacy replay path) | yes — cheap, reuses same masks |
| 9 DLC5 shapes incl. Coastal/Lakes/Rivers | `generator.cfg:29-66`, `dogenerate.inc:1553-1565`, `news.cfg:30` | IN | **yes, primary target** | **yes** |
| 365 new-shape masks + 89 med + 46/9/10/6 old-shape additions | `terrainmasks.dlc5/**`, E12-E14 | IN | yes | **yes** (derived PNG/height assets only; no donor binaries) |
| 31 replaced old masks | E14 | IN | yes | yes — prefer dlc5 versions for the 9-shape path |
| Mask B=water ramp / R relief / G forest / white starts | `generatemap.inc:21-32,311-495,563-574`; F04 | IN | yes | **yes** |
| Player-count bucket fallback (`Xpl`) | `generatemap.inc:159-192`, `moddersread.txt:3-4` | IN | yes | yes |
| Summer baseline tile set | `terrain.presets:2-4`, `tiles.season:1-4` | IN | yes | yes |
| Winter texture set + swap | `terrain.presets:134-136`, `texturemap.inc:525`, `miscext.script:1547-1627`, `onloadfull.inc:70-79` | DLC2 | yes when dlc2 present | **yes** (option + assets; gate can be a setting) |
| Desert texture/pattern pipeline | `dogenerate.inc:4,1532-1535,1589-1590`, `miscext.script:1447-1479` | DLC3 | yes when dlc3 present | yes (second phase) |
| Spring/Autumn seasons, Taiga/Black Forest trees, 256..640 sizes | `RC_TERRAIN.md:27` (S8 NTM) | MOD | no | **no — mod-only** |
| Arctic shape / new arctic tiles | `RC_TERRAIN.md:26,146` | MOD | no | **no — mod-only** |
| `christmas` (`new_year6..10`) / `pump` (`k_pump_1..15`) events | `generator.cfg:1538-1627`, `dmscript.global:1668-1669` | IN but disabled | only if flags >0 | defer (flags −1 shipped) |
| 153 `desert*` patterns / palm / stonesdesert / mines | `data/pattern/**`, `data/actors/env/**`, F08 | IN (desert) / baked in DLC maps | yes for desert season | yes for desert; maps themselves no |
| 49 DLC mission `.map` files (2.877 GiB) | `dlcs/**` | MAP / DLC-only | **no** (campaign, closed format) | **no** |
| 18 DLC `.aix` scripts | `dlcs/**` | MAP / DLC-only | no | no |
| Folder→DLC name manifest | none | UNVERIFIED | no | no |
| Per-DLC-map season value | `*.map` settings binary | UNVERIFIED | low | no |
| UI label/index swap (Coastal↔Lakes) | gui.txt:855-860 vs generator.cfg:55-60 | UNVERIFIED [I] | cosmetic | decide after U2 |

---

## 8. Implications and scope recommendation

### 8.1 In scope for cloning today (vanilla skirmish first) — PORT APPROXIMATION

1. **Shape table.** Implement the 9-entry `TerrainTypesDLC5` order with
   `gc_MaxTerrainTypeCount=9` and the version branch (`<91` legacy 6). This is
   the exact shipped skirmish selector (`generator.cfg:29-66`,
   `dogenerate.inc:1542-1565`). Copy the *order*, not any DLC entitlement.
2. **Mask corpus.** Convert all 1,856 dlc5 TGAs (or at minimum the 365 new-shape
   ones + 89 new med + the 31 replaced masks) into derived, labelled assets;
   prefer dlc5 versions wherever names collide. F04 has a working decoder and
   a subset already converted to PNG; do not copy donor binaries into the repo.
   Preserve `Xpl_` prefix and start-pixel coordinates exactly.
3. **Mask→height/water.** Use `hwater = -1.1*fb*(1+3.5*fr)` with B as the
   operative channel; R only for class codes; white starts excluded from
   height (`generatemap.inc:563-566`). Treat B ramp as continuous water bed, not
   a binary flag. This is a **PORT APPROXIMATION** until an A/B frame exists.
4. **Player-count fallback.** Reproduce the `plcount..11` bucket search and
   `floor(RandomExt*count)` selection, with Coastal's missing `5pl`/`7pl`
   buckets handled by fallback to `6pl`/`8pl` (`generatemap.inc:159-192`).
5. **Season plumbing.** Wire `season 0/2/3`, `_winter` tile-block suffix,
   leaftree removal, `detailw` material, alpha tile flip and colour table
   6/7/0. Assets exist in base install; entitlement can be a config option
   rather than Steam DLC state.
6. **Desert pattern families** can be a second phase, after the 9-shape summer
   path is deterministic.

### 8.2 Deferred (with reasons)

- **All 49 DLC `.map` files.** Closed binary, 2.877 GiB, campaign-specific,
  no generator delta; D04 owns the format and RD_DLC.md G3 already rates mimic
  as the only feasible route. No cloning value for skirmish.
- **18 `.aix` files.** Farm values and achievements only; no terrain calls.
- **Christmas/Halloween event families.** Flags are −1 in shipped scripts;
  stamping them would be invention relative to the shipped skirmish.
- **EMOM/NTM extras** (Arctic, Spring/Autumn, Taiga, 640/720 sizes, 736 masks):
  mod claims, absent from donor install; out of donor-first scope.
- **DLC manifest / per-map season decode.** UNVERIFIED; no evidence found.

### 8.3 Cross-worker dependencies

- F04 owns mask decode and full channel histograms — use its numbers, not the
  10-mask samples in §3.3.
- F03 owns generator.cfg constants and family shadowing; F08 owns pattern/prop
  chains; D04 owns `.map` binary; D03 owns gauss/smooth kernels; D02 owns
  `RandomExt` seeding. This report adds the DLC delta only.
- No gate weakening and no `app/` edits were made or recommended here.

---

## 9. Risks

1. **Label-order trap (R vs B).** TGA byte 0 is blue; a channel swap would make
   water read as relief and produce flat/land-only terrain. Verified mapping in
   §4 must be used (`E15`, `E18`, `F04_masks.md:176-242`).
2. **Wrong table.** Selecting legacy `TerrainTypes` (6 shapes) drops the three
   new shapes and uses `nowater2` as Land; version threshold is `>=91`
   (`dogenerate.inc:1547-1558`). Current `gDataVersion` value is UNVERIFIED
   (U5), but shipped news + dlc5 assets imply ≥91.
3. **Label/index mismatch.** UI says "Lakes" at index 6 while the folder is
   `coastal`; blindly trusting labels produces the wrong shape (U2).
4. **Season gating vs availability.** Assets are base-install but options are
   DLC-gated; a port that ignores this is not faithful to shipped UI, while a
   port that hard-gates them may block local replication. Record as a setting.
5. **Source masks absent for new shapes.** Any "regenerate gauss from src"
   pipeline will silently skip coastal/lakes/rivers (`E13`, `terrainmasks.src`
   listing). Use final `_gauss` TGAs directly.
6. **DLC map bait.** The 2.877 GiB of `.map` files look like terrain data but
   are frozen campaign snapshots; treating them as generation input is a dead
   end.
7. **Start-marker corruption.** White pixels are starts, not plateau; failure
   to exclude them creates phantom mountains and misplaced starts
   (`generatemap.inc:325-341,413-443,565-566`).
8. **No parity claim.** No donor GPU frame was captured; any visual similarity
   remains a PORT APPROXIMATION.

---

## 10. UNVERIFIED register

| ID | Question | Evidence gap | What would resolve it |
|---|---|---|---|
| U1 | Season integer stored in each DLC `.map` | `TMapSettingsGen` field names present (e.g. `prumis1.map:0x9033fe`), values not decoded; no `winter` token in any map | D04 `.map` record-layout decode; read the `season` field instance |
| U2 | Whether the Lakes/Coast UI label swap is visible in-game | gui.txt:855-860 vs generator.cfg:55-60; combo data is raw index (`showcustomgame.inc:153`, `miscext2.script:2627`) | Donor screenshot of the shape dropdown; no donor binary run here |
| U3 | How `WaterSet=Winter` resolves (`terrain.presets:135`) | `water.lib` has only a `default` record; no Winter record found | Deeper water/material resolution trace (X11 water translation) |
| U4 | Anything that sets `gc_christmas`/`gc_halloween` above −1 | Only assignments found are `dmscript.global:1668-1669` = −1 | Full script/engine string sweep (binary constants may be native) |
| U5 | Current `gDataVersion` / `gRecordGeneratorVersion` in this install | Native value; script only stores/reads it (`initmapgen.inc:57,62,72`) | Ghidra/native anchor (D01/D09) |
| U6 | Folder→DLC name mapping | No manifest anywhere; inherited from RD_DLC.md:69-73 | Steam manifest / installer metadata, not present in donor |
| U7 | Whether the 31 replaced masks changed start spacing or shoreline semantically | Byte diffs listed in E14, no per-pixel diff computed | Dedicated diff of the 31 pairs (F04 could extend) |
| U8 | Whether `8pl` masks are actually usable in skirmish | `generatemap.inc:165-169` logs "8th player not yet supported"; mask prefixes exist up to 8pl | Binary/RTTI trace of `gc_MaxPlayerCount` handling |
| U9 | Exact per-shape full-corpus water statistics | §3.3 is 10-mask samples | F04 exhaustive histograms (already partly recorded) |
| U10 | Any DLC-only terrain content hidden inside `.osm`/`.dds` with DLC-like names | `dlcs/**` has none; base assets reused | None needed — negative result from full listing |
| U11 | Whether campaign maps force a season independently of `settings.gen.season` | Campain environment scripts not traced | F09/dogenerate path trace for mission loading |

---

## 11. Open questions

1. Should the port expose Coastal/Lakes/Rivers unconditionally (as this donor's
   skirmish UI does) or mirror the DLC entitlement bits for Winter/Desert only?
2. Should the 31 replaced masks be treated as DLC5-only overrides globally, or
   only on the 9-shape path (the legacy 6-shape path keeps `terrainmasks/**`)?
3. How should a 7-player Coastal game behave given no `7pl` bucket — exact donor
   fallback to `8pl`, or a new curated mask? (Recommendation: exact fallback;
   curating would be new donor data = invention.)
4. Is the UI label/index mismatch a donor bug worth reproducing byte-for-byte,
   or should COORD document-and-fix it as a deliberate deviation?
5. Does the port need the `christmas`/`pump` families at all if the shipped
   flags are −1? (Recommendation: no for today.)
6. Who will reconcile this report's mask deltas with F04's exhaustive corpus and
   F03's family shadowing before the spec is frozen?

---

*End of F10 report. Only this file was written; no donor executable was run and
no donor binary was copied into the repository.*
