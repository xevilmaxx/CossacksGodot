---
id: DMAPGEN-01
title: "DMAPGEN-01 — donor skirmish options (size / type / richness / relief / season / teams / AI difficulty) truth"
owner: DMAPGEN-01
date: 2026-11-25
ticket: "coord_swarm_2026-11-25 donor deep-dive micro-worker"
status: RESEARCH_COMPLETE
scope: "AUDIT ONLY. Donor C:\\Games\\Cossacks 3 opened READ-ONLY (Python 3.14 bytes/latin-1); no donor binary run or copied; no Godot/runner job; no repo file edited except this report. Port menu.gd/config.gd/data.gd read-only."
labels: "OBSERVED = literal donor text read directly; DERIVED = arithmetic/enumeration over observations; INFERRED = labelled interpretation; UNVERIFIED = not proven from plaintext."
verification: "Every option list below was read twice (independent sources cited per row); counts cross-checked against dmscript.global constants and the GUI combo population code."
---

# DMAPGEN-01 — donor skirmish options truth

## 1. Sources

All donor paths are relative to `C:\Games\Cossacks 3`; all port paths to
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`. Reader was
`Path.read_bytes().decode('latin-1')` with 1-based line numbers; helper scripts
lived in `%TEMP%\opencode\` and were not committed.

| # | File | Role |
|---|------|------|
| D1 | `data\gui\menu.inc\donewgame.inc` | seed intake, mapsize enum→W, season random gate, `GenerateMapNeededExtBorder` call |
| D2 | `data\gui\menu.inc\initmapsettings.inc` | all settings defaults to 0; `GenerateMapRandKey` |
| D3 | `data\gui\menu.inc\showcustomgame.inc` | combo population (`FillComboBox*`) = the authoritative enumerated option lists + labels |
| D4 | `data\gui\menu.inc\eventcustomgame.inc` | season random gate, AI difficulty `tag-1` write-back |
| D5 | `data\scripts\dmscript.global` | enum counts `gc_Max*Count`, player difficulty ids, mapsettings constants |
| D6 | `data\locale\en\gui.txt`, `data\locale\en\gui.lng` | English label text for map shape / relief / minerals / starting resources / AI / allies |
| D7 | `data\locale\needloc\new.txt`, `data\locale\needloc\new.lng` | English labels for map size / season |
| D8 | `data\game\var\generator.cfg` | `TerrainTypes` 0..5 paths, `TerrainTypesDLC5` 0..8 paths |
| D9 | `data\gen\globalparams.cfg` | generator globals (`DefaultMapSize=256`, `Size=512`) |
| D10 | `data\gen\mapcover.cfg` | climatic-zone/tile schema; **no** enumerated skirmish options |
| D11 | `data\scripts\common.inc\dogenerate.inc` | stage gates, 9 `SetRandomKey(randkey1)` calls, version gates, random-option resolution |
| D12 | `data\scripts\common.inc\initmapgen.inc` | 2 more `SetRandomKey` calls, version gates, resourcestart case |
| D13 | `data\scripts\common.inc\generatemap.inc` | `SetRandomExtKey64` reseeds before postprocess / texture stages |
| D14 | `data\scripts\lib\map.script` | quickplay/default overrides + `GenerateMapRandKey` |
| D15 | `data\scripts\lib\control.script`, `data\scripts\lib\misc.script` | checked for seed-function definitions; none found (seed primitives are engine-native) |

Prior docs read in pass 1: `DEC_06_map_formats.md` (seed chain/TLV), `DEC_03_configs.md`
(config census + confidence vocabulary), `docs/research/RC_TERRAIN.md` (§2 option
catalogue, S1/S6/S8/S9), `docs/decomp/DB_SCRIPTS.md` (§2 stage order, §3 gap G3),
`docs/audit/DONOR_RECRUIT_MODIFIERS.md` (read for cross-lane consistency; not
option-relevant), `docs/coord_swarm_2026-11-24/reports/I01_agronom_upgrade.md`
(not option-relevant), and port `variant3d/scripts/menu.gd`, `config.gd`, `data.gd`.

**Script-text convention (important).** In donor `.inc` files the literal prefix
`[*] = ;` is the OSW serialization wrapper: the Pascal-like text *after* it is
**ACTIVE script**. It is not a comment marker. Intent-only / inactive text is
marked by `//` inside the statement (e.g. `donewgame.inc:25-26`) or `{ }` blocks
(e.g. `dogenerate.inc:467-470,1929-1935`). In `.cfg` files `//` lines are ordinary
comments (e.g. `generator.cfg:5`). Every line cited below as a donor option value
is ACTIVE script text unless explicitly labelled otherwise.

---

## 2. Donor option tables (all twice-verified)

### 2.1 Map size — 4 entries, no Random [OBSERVED, verified 3×]

| Stored id | UI label | Resulting `genMapSize` | Evidence (enum) | Evidence (GUI + label) |
|---:|---|---:|---|---|
| `0` | Normal | **320** | `donewgame.inc:42-43` | `showcustomgame.inc:244`, `new.lng map.size.normal=Normal` |
| `1` | Large 2x | **480** | `donewgame.inc:44` | `showcustomgame.inc:245`, `new.lng map.size.large=Large 2x` |
| `2` | Huge 4x | **640** | `donewgame.inc:45` | `showcustomgame.inc:246`, `new.lng map.size.huge=Huge 4x` |
| `3` | Tiny | **256** | `donewgame.inc:46` | `showcustomgame.inc:243`, `new.txt:347-348` (`map.size.tiny=Tiny`) |
| *else* | — | 320 (fallback) | `donewgame.inc:47-48` | combo created with exactly **4** items: `showcustomgame.inc:820` |

* Default selection in the combo is item index 1 → id `0` → **Normal 320**
  (`showcustomgame.inc:247`; `initmapsettings.inc:10` sets `mapsize := 0`).
* DERIVED: labels "Large 2x" / "Huge 4x" are relative to *Tiny 256*, not Normal
  (480 = 2×256, 640 = 2×320 = 2.5×256). The labels are donor strings, the
  arithmetic is our observation; do not reinterpret them.
* `globalparams.cfg:8` `DefaultMapSize = 256` is the generator/editor default,
  a separate value from the skirmish default 320.

### 2.2 Map Shape / Climate (`terraintype`) — 9 real + Random [OBSERVED, verified 3×]

| Stored id | UI label (`en/gui.lng`) | Mask path (`generator.cfg`) | Evidence |
|---:|---|---|---|
| 0 | Land | `.\data\gen\terrainmasks\nowater2` | `showcustomgame.inc:146-153`; `generator.cfg:3-7`; `gui.txt:423-424` |
| 1 | Mediterranean | `...\mediterranean` | `generator.cfg:8-11`; `gui.txt:425-426` |
| 2 | Peninsulas | `...\peninsulas` | `generator.cfg:12-15`; `gui.txt:427-428` |
| 3 | Islands | `...\islands` | `generator.cfg:16-19`; `gui.txt:429-430` |
| 4 | Several Continents | `...\continents` | `generator.cfg:20-23`; `gui.txt:431-432` |
| 5 | Single Continent | `...\continent` | `generator.cfg:24-27`; `gui.txt:433-434` |
| 6 | Lakes / Coastal¹ | `terrainmasks.dlc5\...` | `generator.cfg:29-45`; `gui.txt:855-858` vs `needloc/new.lng` |
| 7 | Coast / Lakes¹ | `terrainmasks.dlc5\...` | `gui.txt:857-860`; `needloc/new.lng:47` |
| 8 | Rivers | `terrainmasks.dlc5\...` | `gui.txt:859-862`; `needloc/new.lng:48` |
| 9 | Random (UI); `gui.txt:861` also defines `terraintype.9=Without water` | — | `showcustomgame.inc:155` adds Random with tag `gc_MaxTerrainTypeCount=9` |

* `dmscript.global:236` `gc_MaxTerrainTypeCount = 9` — independent count check.
* Combo default index 1 → id 1 **Mediterranean** (`showcustomgame.inc:156`).
* IDs 6..8 are the `TerrainTypesDLC5` block and require DLC5; DLC gating for the
  *season* is explicit (`donewgame.inc:97-98`), for shapes it is via
  `_country_IsCountryAvailable`/locale presence (INFERRED from `showcustomgame.inc:149-152`).
* ¹ UNVERIFIED label conflict: `en/gui.lng` says 6=Lakes, 7=Coast; `needloc/new.lng`
  says 6=Coastal, 7=Lakes. Both are donor files; do not claim a single canonical
  label pair. The `terraintype.9=Without water` string is not used by this combo
  (the tag-9 item is `text.random`) — likely a stale/other-mode string.
* Resolution at generation: `dogenerate.inc:1547-1557` — if `terraintype >
  gc_MaxTerrainTypeCount-1` (i.e. 9 = Random) then `floor(RandomExt*6)` when
  `gRecordGeneratorVersion<91`, else `floor(RandomExt*gc_MaxTerrainTypeCount)`
  (`*9`). Old-version replays therefore never roll DLC5 shapes.

### 2.3 Relief / "Terrain Type" (`relieftype`) — 5 real + Random [OBSERVED, verified 3×]

| Stored id | UI label (`en/gui.lng`) | Evidence |
|---:|---|---|
| 0 | Plain | `showcustomgame.inc:164-168`; `gui.txt:449-450` |
| 1 | Low Mountains | `gui.txt:451-452` |
| 2 | High Mountains | `gui.txt:453-454` |
| 3 | Highlands | `gui.txt:455-456` |
| 4 | Plateaus | `gui.txt:457-458` |
| 5 | Random (UI) | `showcustomgame.inc:169` adds `text.random` with tag `gc_MaxReliefTypeCount` |

* `dmscript.global:238` `gc_MaxReliefTypeCount = 6-1` = **5** — count confirmed.
* Combo default index 1 → id 1 **Low Mountains** (`showcustomgame.inc:170`).
* `gui.lng randommap.relieftype.5=Desert` is **reused as the season-3 label**
  in `showcustomgame.inc:195-198`; it is *not* a 6th relief (INFERRED from the
  `gc_MaxReliefTypeCount=5` constant and the combo population loop).
* The 5×3 relief envelope table (`plt/mnt/hil` per id) is quoted in
  `docs/decomp/DB_SCRIPTS.md:57-64` from `dogenerate.inc`; `dogenerate.inc:1621-1622`
  resolves `relieftype>4` → `floor(RandomExt*5)`.

### 2.4 Minerals / richness (`resourcemines`, aka `minesdensity`) — 3 + Random [OBSERVED, verified 3×]

| Stored id | UI label (`en/gui.lng`) | Generation effect | Evidence |
|---:|---|---|---|
| 0 | Poor | `SetupMines` rounds = 3 | `showcustomgame.inc:224-228`; `gui.txt:435-436`; `dogenerate.inc:528` |
| 1 | Medium | rounds = 4 | `gui.txt:437-438` |
| 2 | Rich | rounds = 5 | `gui.txt:439-440` |
| 3 | Random (UI) | `floor(RandomExt*3)` → 0/1/2 | `showcustomgame.inc:229` (tag `gc_MaxResourceMinesCount=3`); `dogenerate.inc:1586-1587` |

* `dmscript.global:240` `gc_MaxResourceMinesCount = 3` — count confirmed.
* Combo default index 1 → id 1 **Medium** (`showcustomgame.inc:230`).
* `dogenerate.inc:1544` `var minesdensity := gMap.settings.gen.resourcemines`;
  `:1586-1587` resolves the random tag. `SetupMines` uses `trycount=256` and
  three resource families `mng/mni/mnc` (+`desert_` variants) — corroborated by
  `docs/decomp/DEC_06_map_formats.md:386-405` and `DB_SCRIPTS.md:67`.

### 2.5 Starting resources (`resourcestart`) — 4 + Random [OBSERVED, verified 2×]

| Stored id | UI label | Amount per resource per player | Evidence |
|---:|---|---:|---|
| 0 | Normal | 1000 | `showcustomgame.inc:210-214`; `gui.txt:441-442`; `initmapgen.inc:167-172` |
| 1 | Rich | 4000 | `gui.txt:443-444`; `initmapgen.inc:173-177` |
| 2 | Thousands | 5000 | `gui.txt:445-446`; `initmapgen.inc:178-182` |
| 3 | Millions | 1000000 (via `else`) | `gui.txt:447-448`; `initmapgen.inc:183-188` |
| 4 | Random (UI) | `else` → 1000000 in this script | `showcustomgame.inc:215` (tag `gc_MaxResourcesCount=4`) |

* `dmscript.global:239` `gc_MaxResourcesCount = 4` — count confirmed.
* UNVERIFIED: whether an upstream step resolves tag 4 to 0..3 before
  `initmapgen.inc`; the visible `case` puts 3 and 4 in the same `else` branch.
  Do not claim "Random gives 1M" as intended behaviour.

### 2.6 Season (`season`) — 3 selectable + Random [OBSERVED, verified 3×]

| Stored id | UI label | Gating | Evidence |
|---:|---|---|---|
| 0 | Summer | always | `showcustomgame.inc:178-188,198-199`; `new.txt:221-222` |
| 2 | Winter | DLC2 or Deluxe | `donewgame.inc:97,110-116`; `eventcustomgame.inc:335,348-353`; `new.txt:223-224` |
| 3 | Desert | DLC3 or Deluxe | `donewgame.inc:98,118-124`; `eventcustomgame.inc:336,356-361` |
| -1 | Random (UI tag) | always | `showcustomgame.inc:201` (tag `-1`), `:202` default item 0 |

* `dmscript.global:237` `gc_MaxSeasonCount = 3` — count confirmed.
* The GUI loop maps UI index `i=0,1,2` → stored tag `0,2,3`
  (`showcustomgame.inc:182-188`); **there is no selectable `season=1`** in the
  shipped custom-game UI. The `new.lng randommap.season.1=Winter` label belongs
  to UI index 1, whose stored tag is 2 — a deliberate id/label offset, not a
  fourth season.
* Random resolution (`donewgame.inc:95-127`, duplicated in
  `eventcustomgame.inc:333-363`): both DLC → `>0.66`=0, `>0.33`=2, else 3;
  winter-only → `>0.5`=0 else 2; desert-only → `>0.5`=0 else 3; neither → 0.
  These `RandomExt` calls occur **after** `SetRandomExtKey64` (`donewgame.inc:33`),
  so they consume the same 64-bit stream as later generation.

### 2.7 Teams — two distinct options [OBSERVED, verified 2× each]

**(a) Per-player Team column:** `showcustomgame.inc:117-128` — first item `'-'`
with tag `0`, then `for i:=1 to 4` items labelled `1..4` with tag `i`.
DERIVED: 5 entries = **no team + teams 1..4**, i.e. max **4 teams**. Corroborated
by `dogenerate.inc:1127` `var teams : array [0..4] of TIntegerList` (index 0 =
unassigned, 1..4 = real teams) and `:1137` (`team>4` treated as unassigned).
Quickplay sets `team := 1` / `2` (`map.script:267-270`).

**(b) Global "Allies":** `gMap.settings.additional.teams` with only two ids —
`gc_mapsettings_teams_default = 0` → "Default", `gc_mapsettings_teams_nearby = 1`
→ "Nearby" (`dmscript.global:1086-1087`; labels `gui.txt:849-854`).
`dogenerate.inc:1131` shows that `Nearby` triggers team-clustered start placement.

These are **not** the same field: (a) is `gMap.players[i].team` (per slot), (b) is
`gMap.settings.additional.teams` (match option).

### 2.8 AI difficulty [OBSERVED counts; tag/id reconciliation UNVERIFIED]

| Source | Values |
|---|---|
| Constants `dmscript.global:781-786` | `none=-1, easy=0, normal=1, hard=2, veryhard=3, impossible=4` (6 ids) |
| GUI `showcustomgame.inc:73-86` + `gui.lng` | 5 items, tags 0..4: `None, Normal, Hard, Very Hard, Impossible` (`gc_MaxAIDifficultyCount=4`, `dmscript.global:235`) |
| Write-back `eventcustomgame.inc:127-140` | `aidifficulty := tag-1` for tags >0; tag 0 resets the slot to human |
| Display `showcustomgame.inc:647,651` | combo index = `aidifficulty+1` |

UNVERIFIED conflict: the GUI omits an "Easy" item even though constant `easy=0`
exists, and `tag-1` maps the four visible tiers to stored ids 0..3 rather than
1..4. Singleplayer quickplay explicitly uses `gc_player_difficulty_easy`
(`map.script:244`). Report both facts; do not resolve the off-by-one without a
running donor.

---

## 3. Seed → RNG → generation chain (fresh-read, path:line)

### 3.1 Primitive functions

`GenerateMapRandKey`, `SetRandomExtKey64`, `GetRandomKey`, `SetRandomKey` and
`RandomExt` are **engine-native**: called throughout the donor text but never
defined in any `.inc`/`.script` (searched all of `data\` — see §1 D15; only
`RandomExt` *call-sites* appear in `misc.script:1718-1719,3639,3714-3715,3906-3907`).
Their internal algorithm is therefore **UNVERIFIED**; do not reconstruct one.

### 3.2 Pseudocode (all references ACTIVE ` [*] = ;` text)

```
# ---- key creation (donewgame.inc / initmapsettings.inc / map.script) ----
if not IsLanGame and not gbool_gui_donewgamerestart:
    GenerateMapRandKey(gMap.settings.gen.randkey0,
                       gMap.settings.gen.randkey1)      # donewgame.inc:16
                                                       # initmapsettings.inc:8
                                                       # map.script:322
# INTENT-ONLY: donewgame.inc:25 "//randkey0:=0; randkey1:=1" (commented override)
# INTENT-ONLY: donewgame.inc:26 "//ExecuteState('InitMapSettings')" (commented)

SetRandomExtKey64(randkey0, randkey1)                   # donewgame.inc:33
SetMapGeneratorRandomKey(randkey0, randkey1)            # donewgame.inc:34
SetGlobalMapGeneratorRandomKey(randkey0, randkey1)      # donewgame.inc:35

genMapName = 'game_v'+gDataVersion+'k'+GetRandomKey+'.map'  # donewgame.inc:37

# size gate (§2.1)                                       # donewgame.inc:42-49
genMapSize = {0:320, 1:480, 2:640, 3:256}[mapsize] else 320

# season random gate (§2.6) — consumes the 64-bit stream  # donewgame.inc:95-127
if season < 0: season = roll_by_dlc(RandomExt)

GenerateMapNeededExtBorder(genMapName,'Default','Default',
    genMapSize,genMapSize,1, randkey0,randkey1, 0, season, 0,
    '',...,'.\data\gui\menu.cfg','','light0','','InitMapGen',False)
                                                        # donewgame.inc:166

# ---- InitMapGen: version gate + 2 reseeds ----
gRecordGeneratorVersion = replay ? parser['ver'] : gDataVersion
                                                        # initmapgen.inc:57,72
maxCountryCount = (ver<53) ? ReleaseCount : FullCount    # initmapgen.inc:78-81
SetRandomKey(randkey1)                                  # initmapgen.inc:99
# random countries consumed here (:106,:114,:118,:128) with version gates
#   <53 / <63 / <68 / else                              # initmapgen.inc:103-128
SetRandomKey(randkey1)                                  # initmapgen.inc:146
# version gates <53 delete player 8; <89 delete players 9..11
                                                        # initmapgen.inc:273-285

# ---- DoGenerate: stage gates = one fresh randkey1 stream per stage ----
bDesert = (season==3)                                   # dogenerate.inc:4
# foreststype = floor(RandomExt*3) then IMMEDIATELY overridden to 0
                                                        # dogenerate.inc:5-6 (active, neutralised)
ClearMapMaskAndObjects (cMapSize=640)                   # dogenerate.inc:444-451
SetupTiledPatterns('desert_tiles'|'tiles')              # dogenerate.inc:1532-1535
SetRandomKey(randkey1)                                  # dogenerate.inc:1538   [G1]
# terrain-type random resolution (version gate <91)     # dogenerate.inc:1547-1557
if terraintype > 8: terraintype = floor(RandomExt*(ver<91 ? 6 : 9))
SetRandomKey(randkey1)                                  # dogenerate.inc:1100  [G2 old path]
SetRandomKey(randkey1)                                  # dogenerate.inc:1161  [G3 team]
SetRandomKey(randkey1)  if ver>77                       # dogenerate.inc:1175-1177 [G4]
SetRandomKey(randkey1)                                  # dogenerate.inc:1213  [G5 rest]
SetRandomKey(randkey1)                                  # dogenerate.inc:1616  [G6]
# minerals random + relief random                       # dogenerate.inc:1586-1587,1621-1622
if minesdensity > 2: minesdensity = floor(RandomExt*3)
if relieftype  > 4: relieftype  = floor(RandomExt*5)
# relief table case relieftype 0..4                     # dogenerate.inc:1624+
SetupMines(...)  per start point                        # dogenerate.inc:1770
SetRandomKey(randkey1)                                  # dogenerate.inc:1772  [G7]
# forest/stone/swamp/lake/plain pattern passes          # dogenerate.inc:1774-1907
SetRandomKey(randkey1)                                  # dogenerate.inc:1909  [G8]
CreateUniqueStartingUnits / CreateStartPointPeasants    # dogenerate.inc:1914-1923
SetRandomKey(randkey1)                                  # dogenerate.inc:1927  [G9]
# INTENT-ONLY: dogenerate.inc:467-470 {if BoolRegister5...}, :1929-1935 {...}
```

* Generation-map reseeds in `generatemap.inc`: `SetRandomExtKey64` at `:216`
  (after bitmap selection `floor(RandomExt*count)` at `:190`), `:513` (before
  `PostProcess` when `cPostProcessBitmapGaussian`), `:774` (before `TextureMap`).
  These are separate from the `SetRandomKey` stage gates above.
* `dmscript.global:781-786` also supplies the per-slot `aidifficulty` ids used
  at `initmapgen.inc:132-133` (`gPlayer[i].difficulty := gMap.players[i].aidifficulty`).
* Version gates observed (fresh): `<53, <61, <63, <68, <70, <75, <77, >77, <80,
  <89, <90, <91` across `dogenerate.inc` and `initmapgen.inc`; plus `<55` in
  `readtimespeed.inc:6`, `>66/>75/>81/>70` DLC gates in `country.script:4247-4265`.
  Exact affected behaviour per gate is inherited from `DB_SCRIPTS.md:71` and
  individually visible in the cited lines.

---

## 4. Donor → port parity matrix (port read-only)

Rank: **H** = changes generated map/economy and is wrong; **M** = approximation
or id offset that changes behaviour in some cases; **L** = cosmetic/naming;
**OK** = equivalent.

| # | Option | Donor truth | Port (variant3d, read-only) | Rank | Evidence |
|---:|---|---|---|---|---|
| 1 | Map size numeric | Tiny 256 / Normal 320 / Large 480 / Huge 640 | Tiny 240 / Normal 320 / Large 400 / Huge 480 | **H** | `donewgame.inc:43-46`; `menu.gd:699` |
| 2 | Map size default | 0 = Normal 320 | 240 (Tiny) in menu + config defaults | **H** | `initmapsettings.inc:10`, `showcustomgame.inc:247`; `menu.gd:60`, `config.gd:73-74` |
| 3 | Starting-resource amounts | uniform 1000/4000/5000/1000000 | multipliers 1/4/**25**/1000/0 over non-uniform `{food800,wood800,stone400,gold200,iron150,coal150}` | **H** | `initmapgen.inc:167-188`; `data.gd:340-343`, `config.gd:86` |
| 4 | Seed pipeline | 64-bit `randkey0/1`, 3 setters, 9+2 stage reseeds, version gates | single int seed `RANDOM_SEED=20261113`, menu SpinBox 0..99999999, no stage reseed/version gate in these files | **H** | `donewgame.inc:16,33-37`; `dogenerate.inc:1538..1927`; `initmapgen.inc:99,146`; `data.gd:35`, `menu.gd:741-748`, `config.gd:409` |
| 5 | Season values | 0/2/3 + Random(-1); no `season=1` selectable | string ids summer/desert/winter; no Random entry in skirmish Season row | **M** | `showcustomgame.inc:178-202`; `menu.gd:695` |
| 6 | Map shape | 6 base + 3 DLC5 + Random, each a real mask folder | 9 shapes + random, but DLC5 ids approximate (`coastal→mediterranean`, `lakes→islands`, `rivers→peninsulas`) | **M** | `generator.cfg:2-45`; `data.gd:315-326,311-314` |
| 7 | Relief | 5 ids with 3-parameter `plt/mnt/hil` table | 6 string ids mapped onto 3 sim tiers (`low_mountains→hills`, `highlands→hills`, `plateaus→mountains`) | **M** | `DB_SCRIPTS.md:57-64`; `dogenerate.inc:1621-1624`; `data.gd:331-338` |
| 8 | Per-player team stored id | `0` = no team, `1..4` = teams | `-1` = no team, `0..3` = teams (off-by-one; max stored 3) | **M** | `showcustomgame.inc:123-125`; `menu.gd:459-463` |
| 9 | AI difficulty | 6 constants + 5 GUI entries with `tag-1` write-back | per-player 5 ids none/normal/hard/veryhard/impossible; global 5 ids easy..impossible | **M / UNVERIFIED** | `dmscript.global:235,781-786`; `eventcustomgame.inc:136,140`; `menu.gd:468-479`; `config.gd:19` |
| 10 | Minerals | 0 Poor / 1 Medium / 2 Rich / 3 Random | low/med/rich/random, labels Poor/Medium/Rich/Random | **OK (L ids)** | `showcustomgame.inc:224-230`; `menu.gd:701`, `data.gd:344` |
| 11 | Allies | `teams` 0 Default / 1 Nearby | `allies` default/nearby | **OK** | `dmscript.global:1086-1087`; `menu.gd:703` |
| 12 | Team preset (port-only UI) | no global team-count option; per-slot only | `ffa/2/3/4` preset spreads teams | **L (port extension)** | `showcustomgame.inc:117-128`; `menu.gd:504-507,578-582` |
| 13 | Globalparams / mapcover | `DefaultMapSize=256`, `Size=512`, climatic-zone tile schema only | not represented as skirmish options | **L** | `globalparams.cfg:2,8`; `mapcover.cfg:1-40` |

* Rank justification: #1/#2 alter every generated map's extents; #3 alters the
  economy by 5× for "Thousands"; #4 breaks donor replay determinism outright
  (already logged as gap G3 in `DB_SCRIPTS.md:137`). #5-#9 are reachable but
  off-by-one/approximated; #10/#11 match.

---

## 5. Corrections to prior docs

1. **RC_TERRAIN §2.1 "Map Size Tiny 256 … Huge 640 (S8)"** — confirmed for
   *vanilla donor* by `donewgame.inc:43-46` (256/320/480/640). S8's
   256/320/400/480/560/640 and S6's modded `3→720` are **mod values**, not donor
   defaults. The port's 240/320/400/480 matches neither set exactly.
2. **DEC_06 §7.1 mapsize enum** — confirmed verbatim (`0→320,1→480,2→640,3→256`);
   add that the GUI order is Tiny(3),Normal(0),Large(1),Huge(2)
   (`showcustomgame.inc:243-246`), which DEC_06 did not record.
3. **RC_TERRAIN §2.1 season "Summer, Winter, Desert (vanilla)"** — refined: stored
   ids are **0 / 2 / 3**, Random is `-1`, and **no `season=1`** is selectable
   (`showcustomgame.inc:182-201`). `season=1` remains UNVERIFIED as an internal value.
4. **RC_TERRAIN "Relief Plain/Highland(s)/Mountains"** — donor actually has
   **5** ids (Plain, Low Mountains, High Mountains, Highlands, Plateaus) plus
   Random; label "Terrain Type" belongs to relief, "Map Shape" to terraintype
   (`gui.txt:413-416`). The port's 6-entry table is label-compatible.
5. **`random.cfg` is not the seed** — re-confirmed: only `field = fax`
   (`DEC_06 §6.9`). Seed lives in `gMap.settings.gen.randkey0/1`.
6. **DB_SCRIPTS §2.2 stage order** — its nine `SetRandomKey` lines are confirmed
   exactly (`1100,1161,1177,1213,1538,1616,1772,1909,1927`); add the version-91
   terrain-type random gate (`dogenerate.inc:1547-1557`) and version-77 team
   reseed gate (`:1175-1177`), which DB_SCRIPTS summarized but did not locate.
7. **AI tiers** — prior port comment `config.gd:16-19` calls the six ids "donor
   lobby ids"; the lobby GUI actually shows **five** labels and writes `tag-1`.
   The reconciliation with `easy=0` is UNVERIFIED, not a settled donor truth.

---

## 6. Open questions

1. Are `SetRandomKey/SetRandomExtKey64/GetRandomKey/RandomExt` truly engine
   natives with no textual algorithm? Searched all `data\**\*.inc/*.script`; none
   defined. Needs binary/engine evidence (out of scope, donor binaries not run).
2. Why does the AI combobox omit "Easy" while `gc_player_difficulty_easy=0`
   exists, and does `tag-1` really make visible "Impossible" store id 3?
3. Is `resourcestart=4` (Random) resolved upstream to 0..3, or does the visible
   `else → 1000000` (`initmapgen.inc:183-188`) actually ship?
4. Canonical label pair for DLC5 terraintype 6/7 (`en/gui.lng` vs
   `needloc/new.lng` disagree); and the unused `terraintype.9=Without water`.
5. Exact per-gate behaviour of `gRecordGeneratorVersion <70/<75/<77/<80/<90`
   in `SetupMines` radius selection — observed, not fully re-derived this pass.
6. Whether the port's `game.gd`/`mapgen.gd` consume the emitted `mapsize`/`season`/
   `relieftype` keys at runtime (this pass audited menu/config/data only).
7. Byte-to-field mapping of `randkey0/1` in saved `.map` files remains as
   `DEC_06 §8.1` (version-7 maps UNVERIFIED).

---

## 7. Summary

* Donor skirmish exposes **four map sizes** (256/320/480/640), **nine real map
  shapes + Random** (6 base + 3 DLC5 mask folders), **five relief tiers + Random**,
  **three mineral densities + Random**, **four starting-resource amounts + Random**,
  **three seasons (0/2/3) + Random**, **per-player teams 0..4** plus a separate
  **Default/Nearby Allies** flag, and **five visible AI difficulty labels** backed
  by six constants. All lists were read twice and cross-checked against
  `dmscript.global` counts.
* The seed is a **64-bit pair** (`randkey0/1`) installed into three engine RNG
  entry points and then **re-seeded from `randkey1` before each generation stage**
  (11 sites across `dogenerate.inc`/`initmapgen.inc`), with replay-compatibility
  branches gated on `gRecordGeneratorVersion` (<53 … <91). The random-valued
  options (`season<0`, `terraintype=9`, `relieftype>4`, `resourcemines>2`) are
  resolved from `RandomExt` at defined points in that chain.
* Highest-ranked port mismatches are map-size numbers/default, starting-resource
  multipliers ("Thousands" 25× vs donor 5×), and the absence of stage reseeding /
  generator version — these are the first fixes for donor-faithful skirmish parity.
  Minerals and Allies already match.
* No donor file was copied or executed; no repo file other than this report was
  written; no runner job was started.
