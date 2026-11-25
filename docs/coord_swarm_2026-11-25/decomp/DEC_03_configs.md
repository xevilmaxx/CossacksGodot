# DEC-03 — Donor config truth: full parameter/key dump and meaning

**Lane:** decompilation micro-worker (DEC-03), coordinator swarm 2026-11-25.
**Donor:** `C:\Games\Cossacks 3` — private use only, READ-ONLY. No donor file was copied, executed or modified.
**Port read-only:** `app/scripts/config.gd`, `app/scripts/data.gd`, `app/scripts/world.gd`, `app/scripts/world3d.gd`, `app/scripts/game.gd`, `app/config.json`.
**Method:** PowerShell 5.1 `Get-Content -Encoding UTF8` / `[IO.File]::ReadAllBytes` (line numbers below are **1-based**, line 1 = first line), plus read-only script parsing for counts and cross-file diffs. Every important table was read twice: once as raw numbered text, once via an independent parser that counted/compared records. No code, board or other doc was edited.

Confidence vocabulary: **observed** = literal donor bytes read directly; **derived** = arithmetic/computed from observed values; **inferred** = meaning guessed from the key name or a cross-doc hint; **UNVERIFIED** = no plaintext evidence for the claimed meaning.

---

## 1. Goal

Produce donor-authoritative, non-truncated documentation of every `.cfg`/`.ini` in the donor root and `data\`, with exact values for `envscales.cfg`, `formations.cfg`, `hotkeys.cfg`, `light.cfg`, `env.cfg`, and a SECONDARY comparison against the port's config usage.

---

## 2. Prior docs read (all read before investigation)

| Doc | What it supplied / claim to test |
|---|---|
| `docs/decomp/DB_SCRIPTS.md` | fnd_22–26 baseline; claims "243 lines" hotkeys, "43 entries" with non-zero formation bonuses, envscales 869 lines, gap table G1–G6. |
| `docs/audit/CONFIG_VERIFY.md` | second-agent verdicts: 5 declared-but-unused settings, teams/opponents ignored, bench provenance UNVERIFIED, fog/minimap contradiction. |
| `docs/audit/CONFIG_EFFICIENCY.md` | 73 settings audit; H1 "243 donor bindings vs small set"; CFG-02..10 future tickets. |
| `docs/audit/DONOR_RECRUIT_MODIFIERS.md` | exact donor modifier-key arithmetic; **D15**: `hotkeys.cfg` 1–243 contains no recruit modifier binding. |
| `docs/coord_swarm_2026-11-24/reports/DECOMP_04_strings_config.md` | `SphereHeight`/`DynFogDepth` are look-up keys in `sub_7ab704`; `hmapTex` schema; warns zero-match ≠ disuse. |
| `docs/research/RB_MECHANICS.md` | wiki hotkey source S9 (patrol = **P**), formation bonus sources S11–S13, G-12 "confirm donor `hotkeys.cfg`". |
| `docs/audit/DONOR_RECRUIT_MODIFIERS.md` (same file, audited twice) | cross-check of D15. |
| `investigation.cany/investigation/findings.md` | shared findings fnd_1–fnd_4 (dmscript constants, income, damage, packed loader). |

---

## 3. Config file inventory (77 files, `C:\Games\Cossacks 3`)

Encoding scan: **74 files pure ASCII (no BOM, no NUL); 3 files contain non-ASCII bytes, still no BOM and no NUL** — `data\game\var\generator.cfg`, `data\images\cached\news.cfg`, `steam_emu.ini`. Non-ASCII bytes in Russian/Cyrillic captions render as `?` under Windows ANSI decoding; treat those as UTF-8/ANSI mixed legacy text, not UTF-16. Two files are **0 bytes**.

| # | Path (relative to donor root) | Bytes | Encoding | Section/key structure |
|---|---|---:|---|---|
| 1 | `cossacks.ini` | 161 | ASCII | `section.begin`…`section.end`; 5 flat keys |
| 2 | `editor.ini` | 451 | ASCII | one `section`; 18 flat keys incl. dotted `FixSize.*` |
| 3 | `steam_emu.ini` | 1712 | non-ASCII | INI `[Settings]`, `[Interfaces]`, `[DLC]`, `[Crack]` + `#` comments |
| 4 | `data\brushes\arrow.cfg` | 636 | ASCII | one section; nested `LineSetup` → `LineColor` |
| 5 | `data\brushes\selection.cfg` | 299 | ASCII | one section; `LineSetup` → `LineColor` |
| 6 | `data\brushes\stretch.cfg` | 2218 | ASCII | one section; 3 nested `BorderSetup`/`ArrowSetup`/`TargetArrowSetup` structs |
| 7 | `data\cameras\camera.cfg` | 1613 | ASCII | one section; `RestrictInfo`, `ElasticInfo`, `FreeRotationInfo` + ~40 flat keys |
| 8 | `data\cameras\cameradebug.cfg` | 1543 | ASCII | same schema as #7 |
| 9 | `data\cameras\camerascreenshot.cfg` | 1755 | ASCII | same schema as #7 |
| 10 | `data\env\clouds\clouds.cfg` | 713 | ASCII | one section; `cloudscount[0..9]`, `deltacreatetime[0..9]` |
| 11 | `data\env\env.cfg` | 976 | ASCII | one section; 22 flat keys, 1 `ParticleCubeManager` struct |
| 12 | `data\env\flares\default.cfg` | 10394 | ASCII | one section; 46 structs (flare elements + 10 colour/material blocks) |
| 13 | `data\env\lights\light.cfg` | 902 | ASCII | one section; `Ambient`, `Diffuse`, `Specular`, `Position`, `SpotDirection` structs |
| 14 | `data\env\pfx\particles.snow.cfg` | 3557 | ASCII | **4 consecutive** `section.begin` blocks (snow1–snow4) |
| 15 | `data\env\skydome\skydome.cfg` | 1454 | ASCII | one section; `upskydomeband`, `downskydomeband`, `ScaleFactor` structs |
| 16 | `data\env\skydome\stars.cfg` | 161 | ASCII | one section; 6 flat keys |
| 17 | `data\env\time.cfg` | 163 | ASCII | one section; 8 flat keys |
| 18 | `data\game\var\battles.cfg` | 47340 | ASCII | `battles : section`; 8 battles, 336 structs, 1290 lines |
| 19 | `data\game\var\campaigns.cfg` | 42925 | ASCII | `campaigns : section`; 117 structs, 1090 lines |
| 20 | `data\game\var\envscales.cfg` | 25612 | ASCII | `generator : section` → `EnvGroups` → **26** groups / **122** named objects, 869 lines |
| 21 | `data\game\var\formations.cfg` | 63886 | ASCII | `formations : section`; **149** records, 298 structs, 2307 lines |
| 22 | `data\game\var\generator.cfg` | 70074 | non-ASCII | `generator : section`; terrain types (6+9) + ~70 pattern families, 493 `Freq`, 2367 lines |
| 23 | `data\game\var\hotkeys.cfg` | 5316 | ASCII | one section; **55** `[*] : struct.begin` bindings, 243 lines |
| 24 | `data\game\var\objcustom.cfg` | 1564524 | ASCII | one section; 244 `sid` records, 7155 structs, 51586 lines (geometry) |
| 25 | `data\game\var\random.cfg` | 51 | ASCII | `random : section`; 1 key |
| 26 | `data\game\var\startingsettings.cfg` | 116920 | ASCII | `startingsettings : section`; 584 structs, 3424 lines; **19** `startid` values |
| 27 | `data\game\var\units.cfg` | 258 | ASCII | one section; 2 records (`ID`/`Hint`/`Icon`…) |
| 28 | `data\game\var\wallcustom.cfg` | 11884 | ASCII | one section; 17 `WallVariation` records, 139 structs |
| 29 | `data\gen\bitmap\postpatterns.cfg` | 269140 | ASCII | one section; `Missions` → `Patterns` (X/Y coords), 2014 structs, 9815 lines |
| 30 | `data\gen\globalparams.cfg` | 537 | ASCII | one section; 20 flat keys |
| 31 | `data\gen\localparams.cfg` | 508 | ASCII | `LocalTerrainParams` → 1 record, 13 keys |
| 32 | `data\gen\mapcover.cfg` | 1196 | ASCII | `ClimaticZones` → `HeightTileZones` → `Tiles` + `PatternCovers`/`LocalPresets`/`LightPatterns` |
| 33 | `data\gen\tilesmooth.cfg` | 2796 | ASCII | **10** consecutive sections, each `SmoothTiles` → 3–4 `TileName` |
| 34 | `data\gen\tilesmooth_scripts.cfg` | 64017 | ASCII | one section; 615 structs, `TileNames[*]` → `TileName`+`Prob` ×282 |
| 35 | `data\gui\menu.cfg` | 1002 | ASCII | one section; 27 state-machine keys |
| 36 | `data\gui\minimap.cfg` | 22749 | ASCII | one section; 152 structs, 33 `Name`/`CriticalScale` icon definitions |
| 37 | `data\hud\bar.load.game.cfg` | 7929 | ASCII | one section; `Setup[*]` → 3 GUI controls, 29 structs |
| 38 | `data\hud\bar.load.menu.cfg` | **0** | empty | no structure |
| 39 | `data\hud\bar.save.game.cfg` | **0** | empty | no structure |
| 40–47 | `data\hud\progressbar\bar.load.game.1024.{1..8}.cfg` | 7923 each | ASCII | same schema as #37, 1024-resolution variants |
| 48–55 | `data\hud\progressbar\bar.load.game.2160.{1..8}.cfg` | 7923 each | ASCII | same schema as #37, 2160-resolution variants |
| 56–63 | `data\hud\progressbar\bar.load.game.768.{1..8}.cfg` | 7921 each | ASCII | same schema as #37, 768-resolution variants |
| 64–71 | `data\hud\progressbar\bar.load.game.900.{1..8}.cfg` | 7921 each | ASCII | same schema as #37, 900-resolution variants |
| 72 | `data\images\cached\news.cfg` | 18433 | non-ASCII | one section; `news[*]` → date/locale/header/content/button, 36 structs |
| 73 | `data\images\cached\top100_season1.cfg` | 18434 | ASCII | cached image data, same family as #72 |
| 74 | `data\images\cached\top100_season2.cfg` | 18503 | ASCII | cached image data |
| 75 | `data\images\cached\top100_season3.cfg` | 20466 | ASCII | cached image data |
| 76 | `data\images\cached\top100_season4.cfg` | 20501 | ASCII | cached image data |
| 77 | `data\sounds\manager.cfg` | 241 | ASCII | one section; 9 flat keys |

---

## 4. Full parameter tables by file

### 4.1 Root INI files

`cossacks.ini` (relative path `cossacks.ini`):

| Key | Raw value | Derived meaning | path:line | Confidence |
|---|---|---|---|---|
| `GameSaveDirectoryPath` | `cossacks` | save folder under user documents | `cossacks.ini:2` | inferred |
| `LogFileEnabled` | `false` | logging off | `:3` | observed |
| `LogFileRoot` | `false` | no log in install root | `:4` | inferred |
| `LogFileName` | `cos` | log basename | `:5` | observed |
| `HideHelloScreen` | `true` | suppress splash/hello screen | `:6` | inferred |

`editor.ini`:

| Key | Raw value | Derived meaning | path:line | Confidence |
|---|---|---|---|---|
| `EditorMap` | *(empty)* | no default map | `editor.ini:2` | observed |
| `FullScreen` | `false` | windowed editor | `:3` | observed |
| `DisableDebug` | `false` | debug available | `:4` | inferred |
| `NoGUI` | `false` | editor GUI shown | `:5` | inferred |
| `FixSize` | `false` | don't pin window size | `:7` | inferred |
| `FixPos` | `false` | don't pin window position | `:8` | inferred |
| `FixSize.Width` / `.Height` / `.Left` / `.Top` | `800` / `600` / `50` / `50` | pinned window rect when Fix* true | `:9–12` | observed + inferred |
| `AutoRunState` | `OnAutoRunEditor` | state machine entry point | `:14` | inferred |
| `ConstLODFactor` | `1.0` | LOD multiplier | `:16` | inferred |
| `HideHelloScreen` | `true` | suppress splash | `:17` | inferred |
| `LogFileEnabled` / `LogFileRoot` / `LogFileName` | `false` / `false` / `cos` | as in `cossacks.ini` | `:19–21` | observed + inferred |
| `GameSaveDirectoryPath` | `cossacks` | save folder | `:23` | inferred |

`steam_emu.ini` (Steam emulator; **not game logic**, but part of the donor config surface):

| Section | Key | Raw value | Meaning | path:line | Confidence |
|---|---|---|---|---|---|
| `[Settings]` | `AppId` | `333420` | Cossacks 3 Steam app id | `steam_emu.ini:21` | observed |
| | `AccountId` | commented `#0` | random account id | `:25` | observed |
| | `UserName` | `CODEX` | emulated player name | `:29` | observed |
| | `Language` | `russian` | emulated UI language | `:33` | observed |
| | `LobbyEnabled` | `1` | lobby on | `:37` | observed |
| | `LobbyPort` | commented `#31183` | lobby port default | `:41` | observed |
| | `Overlays` | `1` | Steam overlay emulation on | `:45` | inferred |
| | `Offline` | `0` | online mode | `:49` | observed |
| `[Interfaces]` | `SteamClient` … `SteamUtils` | `SteamClient017` / `SteamController003` / `SteamGameServer012` / `SteamUser019` / `SteamUtils008` | emulated interface versions | `:56–60` | observed |
| `[DLC]` | `DLCUnlockall` | `1` | all DLC unlocked by emulator | `:67` | observed |
| `[Crack]` | 4 hash pairs | `da6acde2…=b7d5bc71…` etc. | crack table (not game data) | `:75–78` | observed |

### 4.2 `data\env\env.cfg` — environment root (fog/light/sky constants)

| Key | Raw value | Derived meaning | path:line | Confidence |
|---|---|---|---|---|
| `Visible` | `True` | environment rendered | `data\env\env.cfg:2` | observed |
| `Active` | `True` | environment updated | `:3` | observed |
| `LensFlareSunriseHour` | `7` | sun lens flare starts at 07:00 | `:4` | inferred |
| `LensFlareDawnHour` | `23` | sun lens flare ends at 23:00 | `:5` | inferred |
| `LensFlareOrbitRadius` | `20000` | flare orbit radius (world units) | `:6` | inferred |
| `LensFlareZOffset` | `0.3` | flare Z bias | `:7` | inferred |
| `LensFlareAngle` | `30` | flare cone angle (deg) | `:8` | inferred |
| `lensflaretextured` | `false` | flare uses flat colours, not textures | `:9` | observed |
| `MoonSunriseHour` | `23` | moon rise 23:00 | `:10` | inferred |
| `MoonDawnHour` | `7` | moon set 07:00 | `:11` | inferred |
| `MoonOrbitRadius` | `20000` | moon orbit radius | `:12` | inferred |
| `MoonZOffset` | `0.3` | moon Z bias | `:13` | inferred |
| `MoonAngle` | `30` | moon cone angle | `:14` | inferred |
| `DateTimeManager.LoadFromFile` | `.\data\env\time.cfg` | clock source | `:15` | observed |
| `ColorTableInterface.LoadFromFile` | `.\data\env\colors\colors.lib` | season colour tables | `:16` | observed |
| `SkyDome.LoadFromFile` | `.\data\env\skydome\skydome.cfg` | sky source | `:17` | observed |
| `Air.LoadFromFile` | `.\data\env\clouds\clouds.weather` | air/weather source | `:18` | observed |
| `CloudsBlock.LoadFromFile` | `.\data\env\clouds\clouds.cfg` | cloud source | `:19` | observed |
| `LensFlare.LoadFromFile` | `.\data\env\flares\default.cfg` | flare source | `:20` | observed |
| `Moon.LoadFromFile` | *(empty)* | moon has no external config | `:21` | observed |
| `LightSourceManager.LoadFromFile` | `.\data\env\lights\light.cfg` | light source | `:22` | observed |
| `ParticleCubeManager.LoadFromFile` | `.\data\env\pfx\particles.lib` | particle library | `:24` | observed |
| `ParticleCubeManager.MaterialLibraryInterface.LoadFromFile` | `.\data\env\pfx\particles.mat` | particle materials | `:25` | observed |

**No fog key exists in `env.cfg`.** Donor fog *constants* are: `clouds.cfg:6` `fogdensity = 0.000920000020414591` (cloud-layer fog) and `camera.cfg:59–64` `DynFogDepth/Start/End/Density/Power/Offset` (a **camera DOF/fog setting**, default `False` — cf. DECOMP_04 §8.3 `sub_7ab704`). Do not conflate these with fog-of-war.

### 4.3 `data\env\lights\light.cfg` — exact light constants

| Key | Raw value | Derived meaning | path:line | Confidence |
|---|---|---|---|---|
| `Ambient.Red` | `0.196078434586525` | ≈50/255 ambient R | `data\env\lights\light.cfg:3` | observed |
| `Ambient.Green` | `0.184313729405403` | ≈47/255 ambient G | `:4` | observed |
| `Ambient.Blue` | `0.129411771893501` | ≈33/255 ambient B | `:5` | observed |
| `Ambient.Alpha` | `1` | opaque | `:6` | observed |
| `ConstAttenuation` | `1` | constant light attenuation = 1 | `:8` | observed |
| `Diffuse.Red` | `0.811764717102051` | ≈207/255 sun R | `:10` | observed |
| `Diffuse.Green` | `0.780392169952393` | ≈199/255 sun G | `:11` | observed |
| `Diffuse.Blue` | `0.694117665290833` | ≈177/255 sun B | `:12` | observed |
| `Diffuse.Alpha` | `1` | opaque | `:13` | observed |
| `LinearAttenuation` | `0` | no linear falloff | `:15` | observed |
| `QuadraticAttenuation` | `0` | no quadratic falloff | `:16` | observed |
| `LightStyle` | `lsParallel` | directional (parallel) light | `:17` | observed + inferred |
| `Shining` | `true` | light enabled | `:18` | observed |
| `Specular.Red` | `0.278431385755539` | ≈71/255 specular R | `:20` | observed |
| `Specular.Green` | `0.266666680574417` | ≈68/255 specular G | `:21` | observed |
| `Specular.Blue` | `0.211764708161354` | ≈54/255 specular B | `:22` | observed |
| `Specular.Alpha` | `1` | opaque | `:23` | observed |
| `SpotCutOff` | `180` | full sphere (parallel light) | `:25` | derived |
| `Position.X/Y/Z/W` | `-0.344731152057648` / `0.938701450824738` / `0` / `1` | donor light vector (→ -0.086, 0, 0.939 in Z-up) | `:27–30` | observed + derived |
| `SpotDirection.X/Y/Z/W` | `0` / `0` / `-1` / `0` | direction (unused for parallel light) | `:33–36` | observed |
| `SpotExponent` | `0` | no spotlight falloff | `:38` | observed |
| `Name` | *(empty)* | unnamed light | `:39` | observed |

### 4.4 `data\env\time.cfg`, `stars.cfg`, `clouds.cfg`, `skydome.cfg`, `particles.snow.cfg`, `sounds\manager.cfg`

`time.cfg`:

| Key | Raw value | Meaning | path:line | Confidence |
|---|---|---|---|---|
| `year`/`month`/`day` | `2001`/`7`/`1` | simulated start date | `data\env\time.cfg:2–4` | observed |
| `hour`/`minute`/`second` | `10`/`0`/`0` | simulated start time 10:00 | `:5–7` | observed |
| `speedfactor` | `8` | game-time speed multiplier | `:8` | inferred |
| `normalspeedfactor` | `10` | normal-time reference multiplier | `:9` | inferred |

`stars.cfg`: `Visible=True` (`:2`), `Active=True` (`:3`), `Twinkle=True` (`:4`), `Radius=1` (`:5`), `MaxStarsCount=5000` (`:6`), `StartHour=21` (`:7`), `EndHour=7` (`:8`) — all **observed** except hour range meaning (**inferred**: visible 21:00–07:00).

`clouds.cfg`:

| Key | Raw value | Meaning | path:line | Confidence |
|---|---|---|---|---|
| `visible`/`active` | `True`/`True` | clouds on | `data\env\clouds\clouds.cfg:2–3` | observed |
| `horizont` | `5000` | cloud horizon distance | `:4` | inferred |
| `height` | `0` | cloud layer height | `:5` | inferred |
| `fogdensity` | `0.000920000020414591` | **fog constant** | `:6` | observed |
| `speedfactor` | `10` | cloud drift speed | `:7` | inferred |
| `materiallibraryinterface.loadfromfile` | `.\data\env\clouds\clouds.mat` | material source | `:8` | observed |
| `cloudscollection.loadfromfile` | `.\data\env\clouds\clouds.presets` | cloud presets | `:9` | observed |
| `cloudscount[0..9]` | `1,5,10,15,20,25,30,30,30,30` | cloud count by weather grade 0–9 | `:11–20` | observed + inferred |
| `deltacreatetime[0..9]` | `10` (all ten) | spawn interval per grade | `:23–32` | observed + inferred |

`skydome.cfg` (exact sky constants):

| Key | Raw value | Meaning | path:line | Confidence |
|---|---|---|---|---|
| `materiallibrary.loadfromfile` | `.\data\env\skydome\skydome.mat` | sky materials | `data\env\skydome\skydome.cfg:2` | observed |
| `libmaterialname` | *(empty)* | no override | `:3` | observed |
| `visible`/`active` | `True`/`True` | sky on | `:4–5` | observed |
| `stars.loadfromfile` | `.\data\env\skydome\stars.cfg` | star field | `:6` | observed |
| `upskydomeband.startangle/stopangle` | `-5` / `90` | upper band elevation range | `:8–9` | inferred |
| `upskydomeband.startcolor` | R `0.600000023841858`, G `0.776470601558685`, B `0.992156863212585`, A `1` | pale zenith blue | `:11–14` | observed + inferred |
| `upskydomeband.stopcolor` | R `0`, G `0.141176477074623`, B `0.807843148708344`, A `1` | saturated blue at horizon | `:17–20` | observed + inferred |
| `upskydomeband.slices/stacks` | `32` / `32` | dome tessellation | `:22–23` | observed |
| `upskydomeband.startangleuv/stopangleuv` | `256` / `90` | UV range (degrees) | `:24–25` | inferred |
| `downskydomeband.startangle/stopangle` | `-90` / `-5` | lower band elevation | `:28–29` | inferred |
| `downskydomeband.startcolor/stopcolor` | both `0.6/0.7764706/0.9921568/1` | lower band uniform pale blue | `:31–40` | observed |
| `downskydomeband.slices/stacks` | `32` / `8` | tessellation | `:42–43` | observed |
| `downskydomeband.startangleuv/stopangleuv` | `270` / `256` | UV range | `:44–45` | inferred |
| `ScaleFactor.X/Y/Z` | `1` / `0.800000011920929` / `1` | dome scale (flattened Y) | `:48–50` | observed |
| `FocalLength` | `1` | projection focal length | `:52` | observed |
| `SceneScaleX/Y` | `1` / `1` | scene scale | `:53–54` | observed |
| `CamInvarianceMode` | `cimPosition` | dome tracks camera position only | `:55` | inferred |

`particles.snow.cfg` — 4 blocks, identical key schema:

| Section (`section.begin` line) | `Name` | `Height`=`Width` | `Rotation` | `SpiralRotatingSpeed` | `Speed` | `Count` |
|---|---|---|---|---|---|---|
| `data\env\pfx\particles.snow.cfg:1` | `snow1` (`:2`) | `0.00150000012945384` (`:4–5`) | `62048.2890625` (`:12`) | `20` (`:15`) | `0.040999997407198` (`:36`) | `100` (`:37`) |
| `:41` | `snow2` (`:42`) | `0.0020000000949949` (`:44–45`) | `66374.140625` (`:52`) | `15` (`:55`) | `0.0610000006854534` (`:76`) | `100` (`:77`) |
| `:81` | `snow3` (`:82`) | `0.00251000002026558` (`:84–85`) | `73513.21875` (`:92`) | `13` (`:95`) | `0.0800000056624413` (`:116`) | `100` (`:117`) |
| `:121` | `snow4` (`:122`) | `0.00300000025890768` (`:124–125`) | `122149.078125` (`:132`) | `13` (`:135`) | `0.100000001490116` (`:156`) | `200` (`:157`) |

Shared per block (**observed**): `LibMaterialName` = same as `Name`; `AlphaChannel=0.5`; `NoZWrite=True`; `Mirroru/Mirrorv=False`; `WindInteraction=False`; `WeatherInteraction=False`; `RotationSpeed=0`; `SpiralRotatingRadius≈0.1`; `BillboardType=btBillboard`; `CreatingCubeStart=+0.5/+0.5/+0.5`; `CreatingCubeEnd=-0.5/-0.5/-0.5`; `MoveDirection=0/-1/0`; `WeatherStart=70`; `WeatherEnd=100`; `MonthStart=1`; `MonthEnd=12`; `CameraSpeedFactor=0.100000001490116`. Meaning of low-level visual fields is **inferred** (billboard snow particles, wind ignored).

`sounds\manager.cfg`: `Environment=seDefault` (`:2`, inferred), `MaxChannels=48` (`:3`), `OutputFrequency=44100` (`:4`), `UpdateFrequency=60` (`:5`), `DistanceFactor=1` (`:6`), `RollOffFactor=1` (`:7`), `DopplerFactor=1` (`:8`), `HeightFactor=0.0` (`:9`), `ScaleFactor=0.02` (`:10`) — values **observed**, audio meanings **inferred**.

### 4.5 `data\cameras\*.cfg` — all three variants side by side

| Key (section) | `camera.cfg` raw | `cameradebug.cfg` raw | `camerascreenshot.cfg` raw | Meaning | path:line (base file) | Conf. |
|---|---|---|---|---|---|---|
| `RestrictInfo.HeightTarget` | `1` | `1` | `1` | camera look-at height | `camera.cfg:3` | inferred |
| `RestrictInfo.HeightTargetMin` | `5` | `5` | `0.35` (old `0.2` commented `:4`) | min look-at height | `:4` | inferred |
| `RestrictInfo.SphereHeight` | `58` (`49` commented `:5`) | `19` | `13` | max camera sphere height | `:6` | observed |
| `RestrictInfo.SphereHeightMin` | `20` | `5` | `0.75` | min camera sphere height | `:7` | observed |
| `RestrictInfo.SphereLength` | `58` (`49` commented `:8`) | `19` | `13` | max camera distance | `:9` | observed |
| `RestrictInfo.SphereLengthMin` | `20` | `5` | `0.6` (old `0.35` commented `:9`) | min camera distance | `:10` | observed |
| `ElasticInfo.MoveVelocity` | `0.125` | `0.25` | `0.5` | pan speed | `:14` | inferred |
| `ElasticInfo.HeightVelocityFactor` | `0.05` | `0.05` | `1.25` | vertical pan factor | `:15` | inferred |
| `ElasticInfo.RotationVelocity` | `0.05` | `0.05` | `0.0500000007450581` | rotation speed | `:16` | inferred |
| `ElasticInfo.TargetOffset` | `0` | `0` | `0` | target bias | `:17` | inferred |
| `ElasticInfo.CameraOffset` | `0` | `0` | `0` | camera bias | `:18` | inferred |
| `ElasticInfo.IntervalTime` | `10` | `20` | `100` | elastic tick interval | `:19` | inferred |
| `ElasticInfo.StepTimeMove` | `0.00001` | `0.001` | `9.99999974737875E-5` | move step time | `:20` | observed |
| `ElasticInfo.StepTimeMoveDirection` | `1` | `1` | `1` | direction step | `:21` | observed |
| `ElasticInfo.StepTimeMoveAccel` | `0.00001` | `0.01` | `0` | acceleration step | `:22` | observed |
| `ElasticInfo.StepTimeMoveDecel` | `0.00001` | `0.01` | `1` | deceleration step | `:23` | observed |
| `ElasticInfo.StepTimeRotation` | `0.00001` | `0.001` | `0.00100000004749745` | rotation step | `:24` | observed |
| `ElasticInfo.StepTimeTargetRaycast` | `0.05` | `0.05` | `0.0500000007450581` | target raycast step | `:25` | observed |
| `ElasticInfo.StepTimeCameraRaycast` | `0.05` | `0.05` | `0.0500000007450581` | camera raycast step | `:26` | observed |
| `ElasticInfo.StepTimeCameraDistance` | `0.005` | `0.05` | `0.0500000007450581` | distance smoothing step | `:27` | observed |
| `FreeRotationMode` | `True` | `True` | `True` | free rotation enabled | `:30` | observed |
| `FreeRotationInfo.MinHeightMinAngle` | `-32` | `-30` | `-90` | **camera pitch** (port default −32) | `:32` | observed |
| `FreeRotationInfo.MinHeightMaxAngle` | `-32` | `-30` | `20` | max angle at min height | `:33` | observed |
| `FreeRotationInfo.MaxHeightMinAngle` | `-32` | `-48` | `-90` | min angle at max height | `:34` | observed |
| `FreeRotationInfo.MaxHeightMaxAngle` | `-32` | `-48` | `20` | max angle at max height | `:35` | observed |
| `FreeRotationInfo.AngleLerpPower` | `1` | `1` | `0.4` | angle interpolation | `:36` | inferred |
| `FreeRotationInfo.MinDistToTargetObject` | `1` | `1` | `0.5` | min target distance | `:37` | inferred |
| `FreeRotationInfo.MaxDistToTargetObject` | `10` | `10` | `10` | max target distance | `:38` | inferred |
| `FreeRotationInfo.MaxHeightLerpFactor` | `0.15` | `0.15` | `0.01` | height smoothing | `:39` | inferred |
| `Bounded` | `True` | `True` | `False` | camera bounds on/off | `:42` | observed |
| `DistToGroups` | `15` | `15` | `15` | group framing distance | `:43` | inferred |
| `MinFocalLength` | `400` | `86` | `95` (old `45` commented `:44`) | min focal length | `:44` | observed |
| `MaxFocalLength` | `400` | `100` | `95` (old `50` commented `:45`) | max focal length | `:45` | observed |
| `FocalLengthPower` | `1.0` | `1.0` | `0.5` | focal interpolation | `:46` | inferred |
| `ElasticTargetRaycastMode` | `false` | `true` | `true` | target raycast on/off | `:48` | observed |
| `ElasticCameraRaycastMode` | `false` | `true` | `true` | camera raycast on/off | `:49` | observed |
| `PowerDOF` | `0.5` | `0.5` | `0.5` | depth-of-field power | `:51` | inferred |
| `MinLengthDOF` / `MaxLengthDOF` | `128.0`/`128.0` | same | same | DOF length range | `:52–53` | observed |
| `MinNearDOF` / `MaxNearDOF` | `256.0`/`256.0` | same | same | DOF near range | `:54–55` | observed |
| `MinFarDOF` / `MaxFarDOF` | `256.0`/`256.0` | same | same | DOF far range | `:56–57` | observed |
| `DynFogDepth` | `False` | `False` | `True` | camera fog/DOF toggle (parsed by `sub_7ab704`) | `:59` | observed |
| `DynFogStart` / `DynFogEnd` | `0.25`/`0.025` | same | same | fog start/end | `:60–61` | observed |
| `DynFogDensity` / `DynFogPower` / `DynFogOffset` | `2.0`/`0.85`/`0` | same | same | fog density/power/offset | `:62–64` | observed |

This is the **external evidence** DECOMP_04 §8.3 lacked: the keys `SphereHeight`, `SphereHeightMin`, `MinHeightMinAngle`, `DynFogDepth` are real and have concrete values here.

### 4.6 `data\brushes\*.cfg`

`arrow.cfg` (all **observed**): `MaterialName=arrow` (`:2`); `ArrowWidth/Height=0.100000001490116`/`0.300000011920929` (`:3–4`); `ArrowThickBase/Middle/Top=0.0500000007450581` ×3 (`:5–7`); `ArrowMaterialWidth=1` (`:8`); `ArrowOffsetBase/Top=0.0500000007450581` (`:9–10`); `Procedural=True` (`:11`); `LineSetup.AntiAliased=False` (`:13`), `LineColor=1/0.325490206480026/0/1` (`:15–18`), `LinePattern=65535` (`:20`), `LineWidth=1` (`:21`), `Visible=True` (`:22`).

`selection.cfg`: `LineSetup.AntiAliased=False` (`:2–3`), `LineColor=1/1/0/1` (`:5–8`) yellow, `LinePattern=65535` (`:10`), `LineWidth=1` (`:11`), `Visible=True` (`:12`), `LineStep=1` (`:14`). Meaning inferred (selection marquee).

`stretch.cfg`: `DrawBorder=True`, `DrawArrow=True` (`:2–3`); `ArrowLength=1`, `ArrowOffset=0` (`:4–5`); `MatUnitPosName=stretch.arrow`, `MatDefName=stretch.brush.square`, `StretchArrMoveName=stretch.brush.move.arrow`, `StretchArrAttackName=stretch.brush.attack.arrow` (`:6–9`); `TargetArrowLength=1.5`, `TargetArrowOffset=0.100000001490116` (`:10–11`); `ArrowTestWidth/Height=2` (`:12–13`); `FadeTime=1` (`:14`); `MinTargetAngle=15` (`:15`); `BorderSetup.LineColor=0/0/0/0.4` (`:19–22`), `ArrowSetup`/`TargetArrowSetup` each repeat the arrow geometry with `Procedural=False`, `MaterialName=stretch.brush.move.arrow`, `LineColor=1/1/0/1` (`:28–75`). All raw values **observed**, semantic labels **inferred**.

### 4.7 `data\game\var\hotkeys.cfg` — ALL 55 bindings (243 lines)

Key syntax: `Key = <combo>`, `Action = <domain>|<action>`, optional `Repeat = True`, `AlternativeKey = <combo>`, `Up = True`. Empty `Key` = deliberately unbound. Domain `build` uses `build|%nat%<sid>` (nation building) or `build|%com%<sid>` (common building).

| # | Key (raw) | Action (raw) | Flags | Meaning (derived/inferred) | path:line | Conf. |
|---|---|---|---|---|---|---|
| 1 | `C` | `build|%nat%cen` | — | Town Hall | `hotkeys.cfg:4–5` | observed |
| 2 | `H` | `build|%nat%hou` | — | House | `:8–9` | observed |
| 3 | `L` | `build|%nat%bla` | — | Barracks | `:12–13` | observed |
| 4 | `B` | `build|%nat%bar` | — | Barn | `:16–17` | observed |
| 5 | `E` | `build|%nat%aca` | — | Academy | `:20–21` | observed |
| 6 | `S` | `build|%nat%sta` | — | Stable | `:24–25` | observed |
| 7 | `R` | `build|%nat%art` | — | Artillery depot | `:28–29` | observed |
| 8 | `D` | `build|%nat%dip` | — | Diplomatic building | `:32–33` | inferred |
| 9 | `K` | `build|%nat%ba2` | — | 18c barracks | `:36–37` | inferred |
| 10 | `J` | `build|%nat%tem` | — | Temple/church | `:40–41` | inferred |
| 11 | `I` | `build|%com%mil` | — | Mill (common) | `:44–45` | observed |
| 12 | `O` | `build|%com%sto` | — | Storehouse | `:48–49` | observed |
| 13 | `M` | `build|%com%mar` | — | Market | `:52–53` | observed |
| 14 | `N` | `build|%com%gol` | — | Gold mine | `:56–57` | observed |
| 15 | `N` | `build|%com%iro` | — | Iron mine (same key, context pick) | `:60–61` | observed |
| 16 | `N` | `build|%com%coa` | — | Coal mine (same key) | `:64–65` | observed |
| 17 | `P` | `build|%com%por` | — | Port/shipyard | `:68–69` | inferred |
| 18 | `T` | `build|%com%tow` | — | Tower | `:72–73` | observed |
| 19 | *(empty)* | `build|%com%wwa` | — | water wall, unbound | `:76–77` | observed |
| 20 | *(empty)* | `build|%com%swa` | — | stone wall, unbound | `:80–81` | observed |
| 21 | `A` | `unit|attack` | — | Attack move | `:85–86` | observed |
| 22 | `S` | `unit|standground` | — | Stand ground | `:89–90` | observed |
| 23 | `C` | `unit|nostandground` | — | Cancel stand ground | `:93–94` | observed |
| 24 | `F` | `squad|fill` | — | Form/top up squad | `:97–98` | inferred |
| 25 | *(empty)* | `squad|disband` | — | Disband squad, unbound | `:101–102` | observed |
| 26 | `G` | `unit|cancelguard` | — | Stop guard | `:105–106` | inferred |
| 27 | `G` | `unit|guard` | — | Guard (same key, toggle) | `:109–110` | inferred |
| 28 | `E` | `unit|enableattack` | — | Hold-fire: enable attack | `:113–114` | inferred |
| 29 | `D` | `unit|disableattack` | — | Hold-fire: disable attack | `:117–118` | inferred |
| 30 | `R` | `unit|attackpoint` | — | Attack ground point | `:121–122` | inferred |
| 31 | `J` | `squad|rank` | — | Line formation | `:125–126` | inferred |
| 32 | `K` | `squad|column` | — | Column formation | `:129–130` | inferred |
| 33 | `L` | `squad|square` | — | Square formation | `:133–134` | inferred |
| 34 | `Ctrl+S` | `unit|stop` | — | Stop | `:137–138` | observed |
| 35 | `U` | `unit|unloadall` | — | Unload all | `:141–142` | observed |
| 36 | `Alt+M` | `interface|minimap` | — | Toggle minimap | `:146–147` | observed |
| 37 | `Q` | `interface|viewcollision` | — | Show collision, **not patrol** | `:150–151` | inferred |
| 38 | `Ctrl+Alt+A` | `select|militaryunits` | `Repeat=True`, `AlternativeKey=Ctrl+Shift+A` | Select military | `:154–157` | observed |
| 39 | `Ctrl+A` | `select|allunits` | `Repeat=True` | Select all units | `:160–162` | observed |
| 40 | `Ctrl+Q` | `select|allships` | `Repeat=True` | Select all ships | `:165–167` | observed |
| 41 | `Ctrl+B` | `select|allbuildings` | `Repeat=True` | Select all buildings | `:170–172` | observed |
| 42 | `Ctrl+P` | `select|idlepeasants` | `AlternativeKey=\`` | Idle peasants | `:175–177` | observed |
| 43 | `Ctrl+\`` | `select|allpeasants` | `Repeat=True` | All peasants | `:180–182` | observed |
| 44 | `Ctrl+M` | `select|idlemines` | — | Idle mines | `:185–186` | observed |
| 45 | `Z` | `select|unitsofsametype` | `Repeat=True` | Same type (screen) | `:189–191` | inferred |
| 46 | `Shift+Z` | `select|addunitsofsametype` | `Repeat=True` | Add same type | `:194–196` | inferred |
| 47 | `Ctrl+Shift+Z` | `select|addallunitsofsametype` | `Repeat=True` | Add all same type (map) | `:199–201` | inferred |
| 48 | `Ctrl+Z` | `select|allunitsofsametype` | `Repeat=True` | All same type (map) | `:204–206` | inferred |
| 49 | `C` | `event|eventmainmenu|bcampaign` | `Up=True` | Campaign button | `:209–211` | inferred |
| 50 | `R` | `event|eventmainmenu|brandommap` | `Up=True` | Random map | `:214–216` | inferred |
| 51 | `S` | `event|eventmainmenu|bsettings` | `Up=True` | Settings | `:219–221` | inferred |
| 52 | `E` | `event|eventmainmenu|beditor` | `Up=True` | Editor | `:224–226` | inferred |
| 53 | `L` | `event|eventmainmenu|bloadgame` | `Up=True` | Load game | `:229–231` | inferred |
| 54 | `X` | `event|eventmainmenu|bexit` | `Up=True` | Exit | `:234–236` | inferred |
| 55 | `M` | `event|eventmainmenu|bmultiplayer` | `Up=True` | Multiplayer | `:239–241` | inferred |

Counts verified twice: **243 lines, 55 `struct.begin`, 55 `Key`, 55 `Action`, 9 `Repeat`, 2 `AlternativeKey`, 7 `Up`, 3 empty keys**. Breakdown 20 build + 15 unit/squad + 13 interface + 7 menu = 55; 52 are keyed.

### 4.8 `data\game\var\envscales.cfg` — ALL 122 objects in 26 groups

Schema (every record, **observed**): `name`, `scale`, `minscale`, `maxscale`. Raw values below are `scale / minscale / maxscale`. Meaning column gives the family; all family labels are **inferred** from the name + DB_SCRIPTS fnd_26 (the donor generator applies a per-object scale + jitter pass). Path is always `data\game\var\envscales.cfg`; line is the `name =` line.

| Group | Object key (`name`) | Raw value (scale/min/max) | Derived meaning | path:line | Conf. |
|---|---|---|---|---|---|
| field | `field` | `0.033 / 1 / 1` | field decoration base scale; no jitter | `:8` | observed + inferred |
| mines | `minecoal` | `0.3152 / 1 / 1` | coal mine; no jitter | `:19` | observed |
| mines | `minegold` | `0.3152 / 1 / 1` | gold mine; no jitter | `:25` | observed |
| mines | `mineiron` | `0.3152 / 1 / 1` | iron mine; no jitter | `:31` | observed |
| stones | `stones` | `0.329 / 0.85 / 1.15` | stone prop family | `:43` | observed |
| stones | `stones1` | `0.329 / 0.85 / 1.15` | stone variant | `:49` | observed |
| stones | `stones2` | `0.37 / 0.85 / 1.15` | stone variant | `:56` | observed |
| stones | `stones3` | `0.4 / 0.85 / 1.15` | stone variant | `:61` | observed |
| stones | `stones4` | `0.324 / 0.85 / 1.15` | stone variant | `:67` | observed |
| stones | `stones5` | `0.313 / 0.85 / 1.15` | stone variant | `:73` | observed |
| stones | `stones6` | `0.328 / 0.85 / 1.15` | stone variant | `:79` | observed |
| stones | `stones7` | `0.25 / 0.85 / 1.15` | stone variant | `:85` | observed |
| stones | `stones8` | `0.25 / 0.85 / 1.15` | stone variant | `:91` | observed |
| stones | `stones9` | `0.25 / 0.85 / 1.15` | stone variant | `:97` | observed |
| stones | `stones10` | `0.25 / 0.85 / 1.15` | stone variant | `:103` | observed |
| smallstones | `smallstones` | `0.25 / 0.85 / 1.15` | small stone | `:114` | observed |
| smallstones | `smallstones.1` | `0.209 / 0.85 / 1.15` | small stone variant | `:120` | observed |
| smallstones | `smallstones.2` | `0.209 / 0.85 / 1.15` | small stone variant | `:126` | observed |
| smallstones | `smallstones.3` | `0.236 / 0.85 / 1.15` | small stone variant | `:132` | observed |
| smallstones | `smallstones.4` | `0.25 / 0.85 / 1.15` | small stone variant | `:138` | observed |
| smallstones | `smallstones.5` | `0.25 / 0.85 / 1.15` | small stone variant | `:144` | observed |
| smallstones | `smallstones.6` | `0.25 / 0.85 / 1.15` | small stone variant | `:150` | observed |
| fir | `fir` | `0.5 / 0.85 / 1.15` | fir tree | `:161` | observed |
| fir | `fir1.1` | `0.5 / 0.85 / 1.15` | fir variant | `:167` | observed |
| fir | `fir2.2` | `0.5 / 0.85 / 1.15` | fir variant | `:173` | observed |
| fir | `fir3.3` | `0.5 / 0.85 / 1.15` | fir variant | `:179` | observed |
| fir | `fir4.4` | `0.5 / 0.85 / 1.15` | fir variant | `:185` | observed |
| firsmall | `firsmall1` | `0.5 / 0.85 / 1.15` | small fir | `:196` | observed |
| firsmall | `firsmall1.1` | `0.5 / 0.85 / 1.15` | small fir variant | `:202` | observed |
| firsmall | `firsmall2.2` | `0.5 / 0.85 / 1.15` | small fir variant | `:208` | observed |
| firsmall | `firsmall3.3` | `0.5 / 0.85 / 1.15` | small fir variant | `:214` | observed |
| firsmall | `firsmall4.4` | `0.5 / 0.85 / 1.15` | small fir variant | `:220` | observed |
| pine1 | `pine1` | `0.475 / 0.85 / 1.15` | pine | `:231` | observed |
| pine1 | `pine1.1` | `0.475 / 0.85 / 1.15` | pine variant | `:237` | observed |
| pine1 | `pine2.2` | `0.475 / 0.85 / 1.15` | pine variant | `:243` | observed |
| pine1 | `pine3.3` | `0.475 / 0.85 / 1.15` | pine variant | `:249` | observed |
| pine1 | `pine4.4` | `0.475 / 0.85 / 1.15` | pine variant | `:255` | observed |
| pinesmall1 | `pinesmall1` | `0.55 / 0.85 / 1.15` | small pine | `:266` | observed |
| pinesmall1 | `pinesmall1.1` | `0.535 / 0.85 / 1.15` | small pine variant | `:272` | observed |
| pinesmall1 | `pinesmall2.2` | `0.56 / 0.85 / 1.15` | small pine variant | `:278` | observed |
| pinesmall1 | `pinesmall3.3` | `0.61 / 0.85 / 1.15` | small pine variant | `:284` | observed |
| pinesmall1 | `pinesmall4.4` | `0.5 / 0.85 / 1.15` | small pine variant | `:290` | observed |
| pinebroken1 | `pinebroken1` | `0.64 / 0.85 / 1.15` | broken pine | `:301` | observed |
| pinebroken1 | `pinebroken1.1` | `0.82 / 0.85 / 1.15` | broken pine variant | `:307` | observed |
| pinebroken1 | `pinebroken2.2` | `0.69 / 0.85 / 1.15` | broken pine variant | `:313` | observed |
| pinebroken1 | `pinebroken3.3` | `0.55 / 0.85 / 1.15` | broken pine variant | `:319` | observed |
| pinebroken1 | `pinebroken4.4` | `0.5 / 0.85 / 1.15` | broken pine variant | `:325` | observed |
| pinebrokenmoss1 | `pinebrokenmoss1` | `0.64 / 0.85 / 1.15` | mossy broken pine | `:336` | observed |
| pinebrokenmoss1 | `pinebrokenmoss1.1` | `0.63 / 0.85 / 1.15` | mossy broken pine variant | `:342` | observed |
| pinebrokenmoss1 | `pinebrokenmoss2.2` | `0.705 / 0.85 / 1.15` | variant | `:348` | observed |
| pinebrokenmoss1 | `pinebrokenmoss3.3` | `0.742 / 0.85 / 1.15` | variant | `:354` | observed |
| pinebrokenmoss1 | `pinebrokenmoss4.4` | `0.5 / 0.85 / 1.15` | variant | `:360` | observed |
| spruce1 | `spruce1` | `0.5 / 0.85 / 1.15` | spruce | `:371` | observed |
| spruce1 | `spruce1.1` | `0.5 / 0.85 / 1.15` | spruce variant | `:377` | observed |
| spruce1 | `spruce2.2` | `0.5 / 0.85 / 1.15` | spruce variant | `:383` | observed |
| spruce1 | `spruce3.3` | `0.5 / 0.85 / 1.15` | spruce variant | `:389` | observed |
| spruce1 | `spruce4.4` | `0.5 / 0.85 / 1.15` | spruce variant | `:395` | observed |
| pinedry1 | `pinedry1` | `0.65 / 0.85 / 1.15` | dry pine | `:406` | observed |
| pinedry1 | `pinedry1.1` | `0.618 / 0.85 / 1.15` | dry pine variant | `:412` | observed |
| pinedry1 | `pinedry2.2` | `0.706 / 0.85 / 1.15` | dry pine variant | `:418` | observed |
| pinedry1 | `pinedry3.3` | `0.76 / 0.85 / 1.15` | dry pine variant | `:424` | observed |
| pinedry1 | `pinedry4.4` | `0.5 / 0.85 / 1.15` | dry pine variant | `:430` | observed |
| pinestump | `pinestump` | `0.91 / 0.85 / 1.15` | pine stump | `:441` | observed |
| pinestump | `pinestump.1` | `1 / 0.85 / 1.15` | stump variant | `:447` | observed |
| pinestump | `pinestump.2` | `0.817 / 0.85 / 1.15` | stump variant | `:453` | observed |
| pinestump | `pinestump.3` | `1.02 / 0.85 / 1.15` | stump variant | `:459` | observed |
| pinestump | `pinestump.4` | `0.817 / 0.85 / 1.15` | stump variant | `:465` | observed |
| leaftree | `leaftree` | `0.425 / 0.85 / 1.15` | leafy tree | `:476` | observed |
| leaftree | `leaftree.1` | `0.425 / 0.85 / 1.15` | leafy variant | `:482` | observed |
| leaftree | `leaftree.2` | `0.425 / 0.85 / 1.15` | leafy variant | `:488` | observed |
| leaftree | `leaftree.3` | `0.425 / 0.85 / 1.15` | leafy variant | `:494` | observed |
| leaftree | `leaftree.4` | `0.504 / 0.85 / 1.15` | leafy variant | `:500` | observed |
| burch | `burch` | `0.38 / 0.85 / 1.15` | birch | `:511` | observed |
| burch | `burch.1` | `0.374 / 0.85 / 1.15` | birch variant | `:517` | observed |
| burch | `burch.2` | `0.366 / 0.85 / 1.15` | birch variant | `:523` | observed |
| burch | `burch.3` | `0.341 / 0.85 / 1.15` | birch variant | `:529` | observed |
| burch | `burch.4` | `0.415 / 0.85 / 1.15` | birch variant | `:535` | observed |
| burch | `burch.5` | `0.434 / 0.85 / 1.15` | birch variant | `:541` | observed |
| burch | `burch.6` | `0.354 / 0.85 / 1.15` | birch variant | `:547` | observed |
| burchstump | `burchstump` | `0.807 / 0.85 / 1.15` | birch stump | `:558` | observed |
| burchstump | `burchstump.1` | `0.915 / 0.85 / 1.15` | stump variant | `:564` | observed |
| burchstump | `burchstump.2` | `0.807 / 0.85 / 1.15` | stump variant | `:570` | observed |
| burchstump | `burchstump.3` | `0.807 / 0.85 / 1.15` | stump variant | `:576` | observed |
| burchstump | `burchstump.4` | `0.807 / 0.85 / 1.15` | stump variant | `:582` | observed |
| grass | `grass` | `0.27 / 0.95 / 1.05` | grass tuft; **tight jitter band** | `:594` | observed |
| grass | `grass.1` | `0.27 / 0.95 / 1.05` | grass variant | `:600` | observed |
| grass | `grass.2` | `0.27 / 0.95 / 1.05` | grass variant | `:606` | observed |
| grass | `grass.3` | `0.27 / 0.95 / 1.05` | grass variant | `:612` | observed |
| grassforest | `grassforest` | `0.475 / 0.95 / 1.05` | forest grass | `:623` | observed |
| grassforest | `grassforest.1` | `0.475 / 0.95 / 1.05` | variant | `:629` | observed |
| grassforest | `grassforest.2` | `0.475 / 0.95 / 1.05` | variant | `:635` | observed |
| grassforest | `grassforest.3` | `0.475 / 0.95 / 1.05` | variant | `:641` | observed |
| fern | `fern` | `0.43 / 0.85 / 1.15` | fern | `:652` | observed |
| fern | `fern.1` | `0.43 / 0.85 / 1.15` | variant | `:658` | observed |
| fern | `fern.2` | `0.43 / 0.85 / 1.15` | variant | `:664` | observed |
| fern | `fern.3` | `0.43 / 0.85 / 1.15` | variant | `:670` | observed |
| fern | `fern.4` | `0.43 / 0.85 / 1.15` | variant | `:676` | observed |
| drybushes | `drybushes` | `0.5 / 0.85 / 1.15` | dry bush | `:687` | observed |
| drybushes | `drybushes.1` | `0.5 / 0.85 / 1.15` | variant | `:693` | observed |
| drybushes | `drybushes.2` | `0.5 / 0.85 / 1.15` | variant | `:699` | observed |
| drybushes | `drybushes.3` | `0.5 / 0.85 / 1.15` | variant | `:705` | observed |
| drybushes | `drybushes.4` | `0.5 / 0.85 / 1.15` | variant | `:711` | observed |
| burdock | `burdock` | `0.356 / 0.85 / 1.15` | burdock plant | `:722` | observed |
| burdock | `burdock.1` | `0.356 / 0.85 / 1.15` | variant | `:728` | observed |
| burdock | `burdock.2` | `0.356 / 0.85 / 1.15` | variant | `:734` | observed |
| burdock | `burdock.3` | `0.356 / 0.85 / 1.15` | variant | `:740` | observed |
| horseradish | `horseradish` | `0.369 / 0.85 / 1.15` | horseradish plant | `:751` | observed |
| horseradish | `horseradish.1` | `0.369 / 0.85 / 1.15` | variant | `:757` | observed |
| horseradish | `horseradish.1` **(duplicate name)** | `0.369 / 0.85 / 1.15` | almost certainly meant `.2`; donor typo | `:763` | observed + inferred |
| horseradish | `horseradish.3` | `0.369 / 0.85 / 1.15` | variant | `:769` | observed |
| chamomile | `chamomile` | `0.147 / 0.85 / 1.15` | chamomile flower | `:780` | observed |
| chamomile | `chamomile.2` | `0.147 / 0.85 / 1.15` | variant | `:786` | observed |
| chamomile | `chamomile.3` | `0.147 / 0.85 / 1.15` | variant | `:792` | observed |
| grasschamomile | `grasschamomile` | `0.3 / 0.95 / 1.05` | grass+chamomile mix | `:803` | observed |
| plantain | `plantain` | `0.412 / 0.85 / 1.15` | plantain | `:814` | observed |
| plantain | `plantain.1` | `0.417 / 0.85 / 1.15` | variant | `:820` | observed |
| plantain | `plantain.2` | `0.436 / 0.85 / 1.15` | variant | `:826` | observed |
| plantain | `plantain.3` | `0.384 / 0.85 / 1.15` | variant | `:832` | observed |
| flowers | `flowers` | `0.281 / 0.85 / 1.15` | flower patch | `:843` | observed |
| flowers | `flowers.1` | `0.263 / 0.85 / 1.15` | variant | `:849` | observed |
| flowers | `flowers.2` | `0.29 / 0.85 / 1.15` | variant | `:855` | observed |
| flowers | `flowers.3` | `0.29 / 0.85 / 1.15` | variant | `:861` | observed |

**Jitter bands (derived):** `1/1` for `field` + 3 mines (no wobble); `0.95–1.05` for `grass` (4), `grassforest` (4), `grasschamomile` (1) = 9 entries; `0.85–1.15` for the other **112** entries. Prior docs' blanket "all 0.85–1.15" is wrong for 12 entries.

### 4.9 `data\game\var\formations.cfg` — ALL 149 IDs

Schema per record: `id`, `symmetry`, `bonusdamage`, `bonusshield`, `bonusdamagehold`, `bonusshieldhold`, `mask[*]` rows. Mask glyphs: `*` = occupied cell, `.` = empty, `O` = officer position (**inferred**; RB_MECHANICS S2/S10 requires an officer for infantry formations). All 149 records below were parsed twice; 137 have `symmetry=1`, 12 have `symmetry=0`, **46 have at least one non-zero bonus**. Path is always `data\game\var\formations.cfg`; line = the `id =` line.

| ID | sym | bonus (dmg/shield/hold-dmg/hold-shield) | Mask rows (joined by ` / `) | path:line | Conf. |
|---|---:|---|---|---|---|
| `none` | 0 | 0/0/0/0 | `*` | `:3` | observed |
| `LINE3` | 1 | 0/0/0/0 | `*..*..*` | `:14` | observed |
| `LINE4` | 1 | 0/0/0/0 | `*..*..*..*` | `:25` | observed |
| `LINE5` | 1 | 0/0/0/0 | `*..*..*..*..*` | `:36` | observed |
| `LINE6` | 1 | 0/0/0/0 | `*..*..*..*..*..*` | `:47` | observed |
| `LINE7` | 1 | 0/0/0/0 | `*..*..*..*..*..*..*` | `:58` | observed |
| `LINE8` | 1 | 0/0/0/0 | `*..*..*..*..*..*..*..*` | `:69` | observed |
| `LINE9` | 1 | 0/0/0/0 | `*..*..*..*..*..*..*..*..*` | `:80` | observed |
| `LINE10` | 1 | 0/0/0/0 | `*..*..*..*..*..*..*..*..*..*` | `:91` | observed |
| `LINE3PUS` | 1 | 0/0/0/0 | `*.*.*` | `:102` | observed |
| `LINE4PUS` | 1 | 0/0/0/0 | `*.*.*.*` | `:113` | observed |
| `LINE5PUS` | 1 | 0/0/0/0 | `*.*.*.*.*` | `:124` | observed |
| `LINE6PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*` | `:135` | observed |
| `LINE7PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*` | `:146` | observed |
| `LINE8PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*` | `:157` | observed |
| `LINE9PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*` | `:168` | observed |
| `LINE10PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.*` | `:179` | observed |
| `LINE11PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.*.*` | `:190` | observed |
| `LINE12PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.* / ........... / *.*.*.*.*.*` | `:201` | observed |
| `LINE13PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.* / .....*..... / *.*.*.*.*.*` | `:214` | observed |
| `LINE14PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.* / ............. / *.*.*.*.*.*.*` | `:227` | observed |
| `LINE15PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.* / ......*...... / *.*.*.*.*.*.*` | `:240` | observed |
| `LINE16PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / ............... / *.*.*.*.*.*.*.*` | `:253` | observed |
| `LINE17PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .......*....... / *.*.*.*.*.*.*.*` | `:266` | observed |
| `LINE18PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.* / ................. / *.*.*.*.*.*.*.*.*` | `:279` | observed |
| `LINE19PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.* / ........*........ / *.*.*.*.*.*.*.*.*` | `:292` | observed |
| `LINE20PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.* / ................... / *.*.*.*.*.*.*.*.*.*` | `:305` | observed |
| `LINE21PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.* / .........*......... / *.*.*.*.*.*.*.*.*.*` | `:318` | observed |
| `LINE22PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.*.* / ..................... / *.*.*.*.*.*.*.*.*.*.*` | `:331` | observed |
| `LINE23PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:344` | observed |
| `LINE24PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.* / .*.*.*.....*.*.*. / *.*.*.*.*.*.*.*.*` | `:357` | observed |
| `LINE25PUS` | 1 | 0/0/0/0 | `.*.*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*.*.` | `:370` | observed |
| `LINE26PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.* / .*.*.*.......*.*.*. / *.*.*.*.*.*.*.*.*.*` | `:383` | observed |
| `LINE27PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.* / .*.*.*...*...*.*.*. / *.*.*.*.*.*.*.*.*.*` | `:396` | observed |
| `LINE28PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.* / .*.*.*.*...*.*.*.*. / *.*.*.*.*.*.*.*.*.*` | `:409` | observed |
| `LINE29PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*.*.*` | `:422` | observed |
| `LINE30PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / ............... / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:435` | observed |
| `LINE31PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*...*.*.*. / *......*......* / .*.*.*...*.*.*. / *.*.*.*.*.*.*.*` | `:450` | observed |
| `LINE32PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.............* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:465` | observed |
| `LINE33PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *......*......* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:480` | observed |
| `LINE34PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.....*.*.....* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:495` | observed |
| `LINE35PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.*....*....*.* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:510` | observed |
| `LINE36PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.*.*.....*.*.* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:525` | observed |
| `LINE37PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.*.*..*..*.*.* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:540` | observed |
| `LINE38PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.* / .*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*` | `:555` | observed |
| `LINE39PUS` | 1 | 0/0/0/0 | `*.*.*.*.*.*.*.*.* / .*.*.*.*.*.*.*.*. / *.*.....*.....*.* / .*.*.*.*.*.*.*.*. / *.*.*.*.*.*.*.*.*` | `:570` | observed |
| `LINE40PUS` | 1 | 0/0/0/0 | `*.*.*.*.*...*.*.*.*.* / .*.*.*.*.*.*.*.*.*.*. / .*.*.*.*.*.*.*.*.*.*. / *.*.*.*.*...*.*.*.*.*` | `:585` | observed |
| `LINE100PUS` | 1 | 0/0/0/0 | 7 rows, 29-wide lattice, centre row `...*.*.*...*` pattern | `:599` | observed |
| `LINEMORB5` | 1 | 0/0/0/0 | `*.*.*.*.*` | `:616` | observed |
| `LINEMORB6` | 1 | 0/0/0/0 | `*.*.* / ..... / *.*.*` | `:627` | observed |
| `LINEMORB7` | 1 | 0/0/0/0 | `*...* / .*.*. / *...*` | `:640` | observed |
| `LINEMORB8` | 1 | 0/0/0/0 | `*.*.* / .*.*. / *.*.*` | `:653` | observed |
| `LINEMORB9` | 1 | 0/0/0/0 | `*.*.*.* / ...*... / *.*.*.*` | `:666` | observed |
| `LINEMORB10` | 1 | 0/0/0/0 | `*.*.*.* / .*...*. / *.*.*.*` | `:679` | observed |
| `LINEMORB11` | 1 | 0/0/0/0 | `*.*.*.* / .*.*.*. / *.*.*.*` | `:692` | observed |
| `LINEMORB12` | 1 | 0/0/0/0 | `*.*.*.*.* / .*.....*. / *.*.*.*.*` | `:705` | observed |
| `LINEMORB13` | 1 | 0/0/0/0 | `*.*.*.*.* / .*..*..*. / *.*.*.*.*` | `:718` | observed |
| `LINEMORB14` | 1 | 0/0/0/0 | `*.*.*.*.* / .*.*.*.*. / *.*.*.*.*` | `:731` | observed |
| `LINEMORB15` | 1 | 0/0/0/0 | `*.*.*.*.*.* / ...*.*.*... / *.*.*.*.*.*` | `:744` | observed |
| `LINEMORB16` | 1 | 0/0/0/0 | `*.*.*.*.*.* / .*.*...*.*. / *.*.*.*.*.*` | `:757` | observed |
| `LINEMORB17` | 1 | 0/0/0/0 | `*.*.*.*.*.* / .*.*.*.*.*. / *.*.*.*.*.*` | `:770` | observed |
| `LINEMORB18` | 1 | 0/0/0/0 | `*.*.*.*.*.*.* / .*...*.*...*. / *.*.*.*.*.*.*` | `:783` | observed |
| `LINEMORB19` | 1 | 0/0/0/0 | `*.*.*.*.*.*.* / .*.*..*..*.*. / *.*.*.*.*.*.*` | `:796` | observed |
| `LINEMORB20` | 1 | 0/0/0/0 | `*.*.*.*.*.*.* / .*.*.*.*.*.*. / *.*.*.*.*.*.*` | `:809` | observed |
| `LINE15` | 1 | **2/2/7/7** | `............... / ............... / *************** / ............... / ...O.......O...` | `:822` | observed |
| `LINE36` | 1 | **2/2/7/7** | `****************** / ****************** / .................. / ....O........O....` | `:837` | observed |
| `LINE72` | 1 | **2/2/7/7** | `************************ / ************************ / ************************ / ........................ / ......O.........O.......` | `:851` | observed |
| `LINE120` | 1 | **2/2/7/7** | 6 rows, 30-wide bars; `..........O.........O.........` last | `:866` | observed |
| `LINE196` | 1 | **2/2/7/7** | 5 rows, 40-wide; edges `O****…****O` | `:882` | observed |
| `SQUARE36` | 1 | **2/2/7/7** | `****** / ****** / ****** / ****** / ****** / ****** / ...... / O....O` | `:897` | observed |
| `SQUARE72` | 1 | **2/2/7/7** | 10 rows, 8–9 wide; `..O...O..` last | `:915` | observed |
| `SQUARE120` | 1 | **2/2/7/7** | 13 rows, 11–12 wide; `...O...O...` last | `:935` | observed |
| `SQUARE196` | 1 | **2/2/7/7** | 16 rows, 14–15 wide; `....O....O....` last | `:958` | observed |
| `KARE36` | 1 | **2/2/7/7** | `********** / *........* … / *..O..O..* … / **********` (10 rows) | `:984` | observed |
| `KARE72` | 1 | **2/2/7/7** | 11 rows, hollow with `**..O.O..**` | `:1004` | observed |
| `KARE120` | 1 | **2/2/7/7** | 13 rows, hollow `***..O.O..***` | `:1025` | observed |
| `KARE196` | 1 | **2/2/7/7** | 16 rows, hollow `****..O..O..****` | `:1048` | observed |
| `ALONE` | 0 | 0/0/0/0 | `*` | `:1074` | observed |
| `ODIN` | 1 | 0/0/0/0 | `*` | `:1085` | observed |
| `SHIPS12` | 0 | 0/0/0/0 | 11 rows, 42-wide sparse ship lattice | `:1096` | observed |
| `SHIPS5` | 0 | 0/0/0/0 | `*.........*..........*..........*..........*` | `:1117` | observed |
| `SHIPSN5` | 0 | 0/0/0/0 | `*.......*.......*.......*.......*` | `:1128` | observed |
| `SHIPS8` | 0 | 0/0/0/0 | 3 rows, 35-wide | `:1139` | observed |
| `SHIPS3` | 0 | 0/0/0/0 | `*.........*.........*` | `:1152` | observed |
| `PACK20` | 0 | 0/0/0/0 | `***** / ***** / ***** / *****` | `:1163` | observed |
| `TRI_OLD` | 1 | **-10/9/95/-19** | 15 rows triangle, 35-wide base | `:1177` | observed |
| `TRI2_OLD` | 1 | 0/0/0/0 | 11 rows triangle | `:1202` | observed |
| `TRI3_OLD` | 1 | 0/0/0/0 | 7 rows triangle | `:1223` | observed |
| `PRUS_OLD` | 1 | **5/-5/-27/80** | 13 rows, 47-wide, alternating `*.*.` | `:1240` | observed |
| `PRUS2_OLD` | 1 | 0/0/0/0 | 8 rows hollow rectangle | `:1263` | observed |
| `PRUS3_OLD` | 1 | 0/0/0/0 | 5 rows hollow | `:1281` | observed |
| `SHER_OLD` | 1 | **2/1/2/1** | 7 rows, 40-wide solid rows | `:1296` | observed |
| `SHER2_OLD` | 1 | **1/1/1/1** | 5 rows, 30-wide | `:1313` | observed |
| `SHER3_OLD` | 1 | **0/1/1/0** | `******************** / .................... / ********************` | `:1328` | observed |
| `PRUS0_OLD` | 1 | **1/1/1/1** | 13 rows, same lattice as PRUS_OLD | `:1341` | observed |
| `TRI0_OLD` | 1 | **1/1/1/1** | 15 rows triangle | `:1364` | observed |
| `PRUS02_OLD` | 1 | 0/0/0/0 | 8 rows hollow | `:1389` | observed |
| `PRUS03_OLD` | 1 | 0/0/0/0 | 5 rows hollow | `:1407` | observed |
| `SHER0_OLD` | 1 | **2/1/2/1** | 7 rows solid | `:1422` | observed |
| `SHER02_OLD` | 1 | **1/1/1/1** | 5 rows | `:1439` | observed |
| `SHER03_OLD` | 1 | **0/1/1/0** | 3 rows | `:1454` | observed |
| `TRI02_OLD` | 1 | 0/0/0/0 | 11 rows triangle | `:1467` | observed |
| `TRI03_OLD` | 1 | 0/0/0/0 | 7 rows triangle | `:1488` | observed |
| `SQUARE15` | 0 | **2/2/7/7** | `.**** / .**** / .**** / OO***` | `:1505` | observed |
| `KARE15` | 0 | **2/2/7/7** | `***** / *O.** / *.O.* / *****` | `:1519` | observed |
| `TRI` | 1 | **1/1/1/1** | 8 rows triangle | `:1533` | observed |
| `TRI2` | 1 | **1/1/1/1** | 6 rows triangle | `:1551` | observed |
| `TRI3` | 1 | **1/1/1/1** | 4 rows triangle | `:1567` | observed |
| `PRUS` | 1 | **1/1/1/1** | 6 rows wedge | `:1581` | observed |
| `PRUS2` | 1 | **1/1/1/1** | 7 rows | `:1597` | observed |
| `PRUS3` | 1 | **1/1/1/1** | 4 rows | `:1614` | observed |
| `SHER` | 1 | **1/1/1/1** | 5 rows solid | `:1628` | observed |
| `SHER2` | 1 | **1/1/1/1** | 4 rows | `:1643` | observed |
| `SHER3` | 1 | **1/1/1/1** | 3 rows, `****.****.****` middle | `:1657` | observed |
| `TRI0` | 1 | **1/1/1/1** | 8 rows triangle | `:1670` | observed |
| `TRI02` | 1 | **1/1/1/1** | 6 rows | `:1688` | observed |
| `TRI03` | 1 | **1/1/1/1** | 4 rows | `:1704` | observed |
| `PRUS0` | 1 | **1/1/1/1** | 6 rows wedge | `:1718` | observed |
| `PRUS02` | 1 | **1/1/1/1** | 7 rows | `:1734` | observed |
| `PRUS03` | 1 | **1/1/1/1** | 4 rows | `:1751` | observed |
| `SHER0` | 1 | **1/1/1/1** | 5 rows | `:1765` | observed |
| `SHER02` | 1 | **1/1/1/1** | 4 rows | `:1780` | observed |
| `SHER03` | 1 | **1/1/1/1** | 3 rows | `:1794` | observed |
| `LINE2` | 1 | 0/0/0/0 | `*..*` | `:1807` | observed |
| `LINE2PUS` | 1 | 0/0/0/0 | `*.*` | `:1818` | observed |
| `LINEMORB2` | 1 | 0/0/0/0 | `*.*` | `:1829` | observed |
| `LINEMORB3` | 1 | 0/0/0/0 | `*.*.*` | `:1840` | observed |
| `LINEMORB4` | 1 | 0/0/0/0 | `*.*.*.*` | `:1851` | observed |
| `LINE400` | 1 | **3/3/7/7** | 9 rows, 50-wide; `..................O............O..................` last | `:1862` | observed |
| `SQUARE400` | 1 | **3/3/7/7** | 22 rows, 20-wide; `.......O....O.......` last | `:1881` | observed |
| `KARE400` | 1 | **3/3/7/7** | 22 rows, hollow 22-wide; `******...O..O...******` middle | `:1913` | observed |
| `LINE15NB` | 1 | 0/0/0/0 | same mask as LINE15 | `:1945` | observed + inferred |
| `LINE36NB` | 1 | 0/0/0/0 | same mask as LINE36 | `:1960` | observed + inferred |
| `LINE72NB` | 1 | 0/0/0/0 | same mask as LINE72 | `:1974` | observed + inferred |
| `LINE120NB` | 1 | 0/0/0/0 | same mask as LINE120 | `:1989` | observed + inferred |
| `LINE196NB` | 1 | 0/0/0/0 | same mask as LINE196 | `:2005` | observed + inferred |
| `LINE400NB` | 1 | 0/0/0/0 | same mask as LINE400 | `:2020` | observed + inferred |
| `SQUARE15NB` | 0 | 0/0/0/0 | same mask as SQUARE15 | `:2039` | observed + inferred |
| `SQUARE36NB` | 1 | 0/0/0/0 | same mask as SQUARE36 | `:2053` | observed + inferred |
| `SQUARE72NB` | 1 | 0/0/0/0 | same mask as SQUARE72 | `:2071` | observed + inferred |
| `SQUARE120NB` | 1 | 0/0/0/0 | same mask as SQUARE120 | `:2091` | observed + inferred |
| `SQUARE196NB` | 1 | 0/0/0/0 | same mask as SQUARE196 | `:2114` | observed + inferred |
| `SQUARE400NB` | 1 | 0/0/0/0 | same mask as SQUARE400 | `:2140` | observed + inferred |
| `KARE15NB` | 0 | 0/0/0/0 | same mask as KARE15 | `:2172` | observed + inferred |
| `KARE36NB` | 1 | 0/0/0/0 | same mask as KARE36 | `:2186` | observed + inferred |
| `KARE72NB` | 1 | 0/0/0/0 | same mask as KARE72 | `:2206` | observed + inferred |
| `KARE120NB` | 1 | 0/0/0/0 | same mask as KARE120 | `:2227` | observed + inferred |
| `KARE196NB` | 1 | 0/0/0/0 | same mask as KARE196 | `:2250` | observed + inferred |
| `KARE400NB` | 1 | 0/0/0/0 | same mask as KARE400 | `:2276` | observed + inferred |

**Non-zero bonus distribution (derived, 46 records):** 15× `(2,2,7,7)` — LINE15/36/72/120/196, SQUARE36/72/120/196, KARE36/72/120/196, SQUARE15, KARE15; 22× `(1,1,1,1)` — the 18 current TRI/TRI2/TRI3, PRUS/PRUS2/PRUS3, SHER/SHER2/SHER3 and their `0`-suffixed twins, plus 4 legacy `PRUS0_OLD`, `TRI0_OLD`, `SHER2_OLD`, `SHER02_OLD`; 3× `(3,3,7,7)` — LINE400/SQUARE400/KARE400; 2× `(2,1,2,1)` — SHER_OLD/SHER0_OLD; 2× `(0,1,1,0)` — SHER3_OLD/SHER03_OLD; 2 legacy outliers `TRI_OLD (-10,9,95,-19)` and `PRUS_OLD (5,-5,-27,80)`. Total 15+22+3+2+2+2 = **46**. All `NB` records are zero — the suffix is inferred to mean "no bonus".

### 4.10 Other `game\var` files

`random.cfg`: `random : section` → `field = fax` (`random.cfg:2`) — **observed**, meaning **UNVERIFIED** (likely a placeholder field name).

`units.cfg`: record 1 `ID=0`, `Hint=None`, `Icon=` empty (`:3–5`); record 2 `ID=1`, `Hint=Pikeman 17th century`, `Icon=`, `LocaleTable=`, `LocaleKey=` (`:8–12`) — **observed**; a 2-record stub.

`generator.cfg` (2367 lines): two terrain-type lists, exact paths:

| List | `hint` | `path` | path:line |
|---|---|---|---|
| `TerrainTypes` | `0.Land` | `.\data\gen\terrainmasks\nowater2` | `generator.cfg:4–6` |
| | `1.Mediterranean` | `.\data\gen\terrainmasks\mediterranean` | `:9–10` |
| | `2.Peninsulas` | `.\data\gen\terrainmasks\peninsulas` | `:13–14` |
| | `3.Islands` | `.\data\gen\terrainmasks\islands` | `:17–18` |
| | `4.Continents` | `.\data\gen\terrainmasks\continents` | `:21–22` |
| | `5.Continent` | `.\data\gen\terrainmasks\continent` | `:25–26` |
| `TerrainTypesDLC5` | 0–5 same hints | same six names under `.\data\gen\terrainmasks.dlc5\` | `:31–52` |
| | `6.Coastal` | `.\data\gen\terrainmasks.dlc5\coastal` | `:55–56` |
| | `7.Lakes` | `.\data\gen\terrainmasks.dlc5\lakes` | `:59–60` |
| | `8.Rivers` | `.\data\gen\terrainmasks.dlc5\rivers` | `:63–64` |

Pattern families begin at `:69` (`mng`), `:98` (`mni`), `:127` (`mnc`), `:156–190` desert variants, `:207` `plain_small`, `:288` `plain_medium`, `:389` `plain_big`, `:446` `plain_huge`, `:503` `ravine_big`, `:540` `ravine_medium`, `:581` `plateau`, `:606` `plateau_small`, `:635` `plateau_big`, `:660` `mountains`, `:693` `hills_dark`, `:714` `hills_light`, `:755` `decor`, `:772` `decor_big`, `:781` `tiles`, `:802` `stoneforests`, `:839` `stoneforests_old`, `:876` `stones`, `:909+` `forests_*`. Counts: **493 `Pattern` + 493 `Freq`** keys, 15 `hint`, 15 `path`, 64 `Name`, 5 `Description`; `Freq` is a **weight**, not probability (DB_SCRIPTS §2.1). Family names and weights are **observed**, weight semantics **derived** from `dogenerate.inc`.

`startingsettings.cfg` (3424 lines): 19 `startid` values — `-1 (:89), 0 (:183), 1 (:187), 2 (:314), 3 (:503), 4 (:720), 1 (:862), 2 (:989), 3 (:1178), 4 (:1396), 5 (:1540), 6 (:1701), 7 (:1826), 8 (:1989), 9 (:2178), 10 (:2350), 11 (:2526), 12 (:2830), 13 (:2973)`; key counts: `basename`/`countrysid`/`key`/`role` = 276 each, food 21, coal/iron/stone 21 each, gold 24, wood 24, `dataversionmin`/`max` 8 each. Example record: `startid=1`, `dataversionmin=60`, `dataversionmax=1000`, `addresources{food=1000, wood=0, stone=0, gold=0, iron=0, coal=0}` plus `countries[].allowedcountries[]` (`startingsettings.cfg:186–205`). `startid=10` (barrack17) adds `food=5000, wood=1000, stone=1000, gold=2500, iron=3000, coal=3000` (`:2349–2357`). All values **observed**; role/basename→unit lookup semantics **derived** from DB_SCRIPTS §2.3.

`battles.cfg`: 8 battle records; keys `Name`(8), `LocaleName`(168), `LocaleDescr`(8), `LocalePath`(8), `Preview`(8), `MapPath`(8), `MaxPlayers`(8), `LocalePositions`(8), `LocalePositionsPath`(8), `Count`(64), `X`/`Y`(160 each); first record `battle1`, `MapPath=.\data\maps\missions\battle1.map`, `MaxPlayers=8` (`battles.cfg:2–11`) — **observed**.

`campaigns.cfg`: 98 mission/campaign records; keys `Name`, `Enabled`, `Visible`, `RequireToVisible`, `LocaleName`, `LocaleDescr` (98 each), `LocalePath`(19), `MapPath`(79), `MapLocalePath`(79), `MapLocalePathExt`(75), `RequireDLC`(11), `RequireFile`(2), `RequireUnixTime`(1); first `tutcam`/`tutmis1` (`:2–18`) — **observed**.

`objcustom.cfg` (51,586 lines, 244 `sid`, 7155 structs): geometry keys `px/py/pz`, `nx/ny/nz` (5637 each), `x`(607)/`y`(580)/`z`(552), `angle`/`maxangle`/`minangle`/`offx`/`scale` (229 each), `bcustomdir`(162), `buse`/`maxx/y/z`/`minx/y/z`(9 each), `bcustomweaponind`/`weaponind`(5); first record `sid=ausbar`, `Decal.scale=16.0` (`objcustom.cfg:2–17`) — **observed**, geometry purpose **inferred**.

`wallcustom.cfg`: 17 `WallVariation` records; `x`/`y` 105 each; `BuilderPoints` coordinates (`:3–17`) — **observed**.

### 4.11 Generation, GUI and cached configs

| File | Keys (raw, representative) | Meaning | path:line | Conf. |
|---|---|---|---|---|
| `data\gen\globalparams.cfg` | `Size=512`, `Sharpness=0.6`, `TileChangeFactor=0.3`, `FrequencyFactor=0.000013`, `CellsResolution=1`, `FailStandCount=16`, `DefaultMapSize=256`, `TileSmoothPasses=6`, `TileSmoothListFileName=.\data\gen\tilesmooth.cfg`, `CastlesFileName=` empty, `PatternPlayerName=pattern`, `AddCastles=False`, `CastlePlateauFactor=5`, 6 other empty name/race keys | global heightmap generation constants | `:2–20` | observed + inferred |
| `data\gen\localparams.cfg` | `LocalTerrainParams[0]`: `Name=0`, `HillPointsDensity=0.00008`, `MaxHillsHeight=0`, `HillsHeightFactor=0.001`, `GlobalMixFactor=1`, `LocalMixFactor=1`, `OffsetRadius=0`, `SmoothLevel=0.008`, `SmoothPasses=1`, `SmoothFactor=0.15`, `MinHeight=0`, `MaxHeight=0.0001`, `CriticalPointsDist=0` | one local terrain parameter set | `:3–17` | observed |
| `data\gen\mapcover.cfg` | `ClimaticZones[0]`: `Name=Default`, `HeightZone0.MinHeight=0/MaxHeight=100`, tile struct `Frequency=1.0` + four empty seasonal tile names, `LocalPresets[0]` `MapFrequency=1/BorderFrequency=1/OnMap=True/OnBorder=True`, empty `PatternCovers`/`LightPatterns` | climate→tile zonation | `:3–37` | observed + inferred |
| `data\gen\tilesmooth.cfg` | 10 sections, each `SmoothTiles[*].TileName` = `ground1/test1/grass1`, `ground1/test1/grass2`, `rock1/rock9/grass_ground1/grass1`, `rock2…`, `rock3…`, `rock4…`, `rock6…`, `rock7…` | tile smoothing adjacency lists | `:1–129` | observed |
| `data\gen\tilesmooth_scripts.cfg` | 282 `TileName`/`Prob` pairs, e.g. `sandsea1/Prob=1`, `sandsea2/Prob=1`, `sandsea3/Prob=1` | weighted tile replacement | `:6–18` | observed |
| `data\gen\bitmap\postpatterns.cfg` | `Missions[*].MissionName=engmis1`, `Patterns[*]` `PatternName=g_hil8`, `X=-23`, `Y=136` etc.; 9815 lines, 2014 structs | **authored map pattern placements** (not runtime weights) | `:2–22` | observed |
| `data\gui\menu.cfg` | `StateMachineFileName=.\data\gui\menu.aix`, `StateCreateGUI=DoCreate`, `StateDestroyGUI=DoDestroy`, `StateUpdateGUI=`, `StateOnPressGUI=`, `StateOnUnPressGUI=`, `StateOnClickGUI=`, `StateOnMouseEnterGUI=OnMouseEnter`, `StateOnMouseLeaveGUI=OnMouseLeave`, `StateOnMouseMove=OnMouseMove`, `StateOnMouseDown=`, `StateOnMouseUp=`, `StateOnMouseWheel=OnMouseWheel`, `StateOnClearSelection=OnClear`, `StateOnProcessSelection=OnSelection`, `StateProgressGUI=DoProgress`, `StateResizeGUI=OnResize`, `StateOnHintGUI=OnHint`, `StateOnLanChange=OnLanEvent`, `StateOnGUIHookEvent=OnMouseHook`, `ProgressInterval=10`, `ProgressDeltaTime=0`, `ProgressEnabled=True`, `DefaultCursorIndex=0`, `KeyRepeatDelay=0.05`, `KeyDoubleDelay=0.5`, `HintWaitDelay=0.1` | menu state machine + input timing | `:2–34` | observed + inferred |
| `data\gui\minimap.cfg` | `ImageWidth=240`, `ImageHeight=240`, `FrustumVisible=True`, `Width=240`, `Height=240`, `VAlign=valBottom`, `HAlign=halLeft`, `Position=0/0/0/1`, 33 `Name`/`CriticalScale` icon definitions, 42 RGB triplets | minimap geometry + icon set | `:2–818` | observed + inferred |
| `data\hud\bar.load.game.cfg` | `Name=progressbar`, `FullScreen=true`, `Visible=true`, `HAlign=halMiddle`, `VAlign=valMiddle`, `Setup[*]` 3 controls (`background`, etc.) with `Width=1920`, `Height=1024`, font/colour/data fields | loading-screen GUI definition | `:2–18` | observed + inferred |
| `data\hud\bar.load.menu.cfg`, `bar.save.game.cfg` | *(0 bytes)* | empty stubs | — | observed |
| `data\hud\progressbar\*.cfg` (32 files) | same schema as `bar.load.game.cfg`, 7921–7923 bytes each, four resolution families 768/900/1024/2160 × 1–8 | resolution-specific loading bars | — | observed |
| `data\images\cached\news.cfg` | `news[*]`: `date=21-06-18`, `locale=en,ru,uk`, `keycheck=` empty, `notongog=True`, `header{en/ru/uk}`, `image.all=<URL>`, `image.filename=…`, `content.all[*]`, `buttontext/buttonlink/buttonexecute`; 5 news items | cached web news data, not game config | `:2–18` | observed |
| `data\images\cached\top100_season{1..4}.cfg` | same cached-data family, 18–20 KB each | leaderboard image cache | — | observed |

---

## 5. Corrections to prior docs

| # | Prior claim | Corrected donor truth | Evidence |
|---|---|---|---|
| C1 | `DECOMP_04_strings_config.md:129` / `CONFIG_EFFICIENCY.md:129`: "243 donor bindings" | **243 lines, 55 bindings** (52 keyed, 3 deliberately empty). The number 243 is a line count, not a binding count. | `hotkeys.cfg:1–243`; counted twice |
| C2 | `DB_SCRIPTS.md:93`: "43 entries carry non-zero bonuses" | **46** non-zero of 149. Values are **not** uniform `(2,2,7,7)`: 15×`(2,2,7,7)`, 22×`(1,1,1,1)`, 3×`(3,3,7,7)`, 2×`(2,1,2,1)`, 2×`(0,1,1,0)`, plus outliers `TRI_OLD(-10,9,95,-19)`, `PRUS_OLD(5,-5,-27,80)`. | parsed 149 records twice |
| C3 | `DB_SCRIPTS.md:129` envscales "all 0.85–1.15" | Only **112/122** use 0.85–1.15; 9 grass-family entries use **0.95–1.05**; `field` + 3 mines use **1/1** (no jitter). Also `horseradish.1` is duplicated at `:757` and `:763` (likely donor typo for `.2`). | `envscales.cfg:8–865` |
| C4 | `DB_SCRIPTS.md:80` startid 0–9 | File contains **19 values**, including `-1` and `10–13`. | `startingsettings.cfg:89–2973` |
| C5 | `DB_SCRIPTS.md:135` gap G1: port has only 5 formations, wiki bonuses | **Closed**: `data.gd:380–530` imports all 149 tuples (verified byte-for-byte, diff 0), `data.gd:534` exposes `formation_bonuses()`, `game.gd:3054,3082,3100` consumes it. The `FORMATIONS` shape table at `data.gd:368–374` is a separate visual abstraction. | port read-only |
| C6 | `DB_SCRIPTS.md:136` gap G2: `Data.HOTKEYS = {}` empty | **Partially closed**: `config.gd:135–174` + `config.json` define 26 scalar binds + 16 build binds = 42; applied at `config.gd:555–566`. Still below 52 keyed donor binds and missing flags. | port read-only |
| C7 | `DB_SCRIPTS.md:140` gap G6: no env scale table in port | **Partially closed**: `world.gd:216–235` imports 3 scale classes + the 0.85–1.15 jitter band, with mines explicitly exempt. Donor's 122-entry varied scales and the 0.95–1.05 band are absent. | port read-only |
| C8 | `RB_MECHANICS.md:225` G-12 "patrol P, port Q, confirm donor hotkeys.cfg" | Donor `hotkeys.cfg` has **no patrol binding at all**: `Q` = `interface|viewcollision` (`hotkeys.cfg:150–151`). Wiki S9 patrol=P remains **UNVERIFIED** from donor; port has both `patrol=Q` and `patrol_waypoints=P`, so Q is a donor mismatch. | `hotkeys.cfg:150`; `config.gd:140,167` |
| C9 | `DECOMP_04_strings_config.md` §4 "none of these keys had code references" | §8 already corrected this for `SphereHeight`/`DynFogDepth`; this report supplies the **external values** in `camera.cfg:6,59–64`, confirming the parser keys are live config look-ups. | `camera.cfg:6,59–64` |

---

## 6. Missing / wrong in port, ranked by visual or gameplay impact (SECONDARY)

1. **HIGH — camera/light/sky colour truth diverges.** Donor light `Diffuse≈(0.812,0.780,0.694)` (`light.cfg:10–12`) and `Ambient≈(0.196,0.184,0.129)` (`:3–5`) are not imported: `world3d.gd:435` uses `ambient_light_color = Color(0.86,0.88,0.82)` and no explicit sun colour (`:442–452`; only direction from `light.cfg Position` is ported). Sky: donor `upskydomeband.startcolor=(0.6,0.776,0.992)` → `stopcolor=(0,0.141,0.807)` (`skydome.cfg:11–20`); port `world3d.gd:417–418` uses `Color(0.18,0.30,0.42)` / `Color(0.36,0.44,0.38)` — visibly darker and green-tinted. **Visual impact: high.** Fixing requires mapping donor RGB → Godot light energy/colour with a documented tone curve; do not blindly copy floats (port already compensates exposure, `world3d.gd:26–28`).
2. **HIGH — hotkey binding set and semantics incomplete.** Missing donor binds: `ba2`(K), `tem`(J), `por`(P), three-mine `N` context group, `wwa`/`swa` (unbound anyway), `squad|disband`, `interface|viewcollision`, all **7 main-menu binds**, and donor's `Repeat`(9)/`AlternativeKey`(2)/`Up`(7) flags (none in port config). Wrong: port `bar18=K` but donor `K=ba2`; port `mine=N` but donor `N=gol/iro/coa`; port `patrol=Q` but donor `Q=viewcollision`. 42 port binds vs 52 keyed donor binds. Note port `CTRL+Alt+A`, `Ctrl+Q/Z/Shift+Z`, `Alt+M`, `Ctrl+P/B/M/\``, etc. **match** donor. **Gameplay impact: high for keyboard users.**
3. **MEDIUM — envscales collapsed from 122 to 3 classes.** Port `world.gd:222–224` has only `mine=0.3152`, `stone=0.329`, `tree=0.5`, jitter 0.85–1.15. Missing `field=0.033`, the 0.95–1.05 grass band, and per-variant scales (`stones2=0.37`, `smallstones=0.209`, `pinebroken1.1=0.82`, `chamomile=0.147`, …). Mines are correctly jitter-free (`world.gd:229–232`). **Visual impact: medium (prop size variety).**
4. **MEDIUM — camera geometry half-imported.** Port `config.gd:396–401` maps `MIN_HEIGHT=20`, `MAX_HEIGHT=58` (donor `SphereHeightMin=20`, `SphereHeight=58`, `camera.cfg:6–7`) and pitch −32 (`config.gd:61,395`; `camera.cfg:32–35`) — but `CAMERA_PITCH` is **declared-but-unused** (`CONFIG_VERIFY.md:67–84`; camera.gd reads only height/margins/speeds/zoom). Donor `SphereLength=58`, `FocalLength=400`, `DistToGroups=15`, `DynFog*` are absent. **Visual impact: medium; gameplay: low.**
5. **MEDIUM — time/weather constants absent.** `time.cfg:2–9` (start 2001-07-01 10:00, speed 8/normal 10) and `stars.cfg:6–8` (5000 stars, 21:00–07:00) have no port counterpart; `CONFIG_EFFICIENCY.md:103` already records no season/biome key. `particles.snow.cfg` has 4 tuned snow classes; port has generic weather. **Visual impact: medium.**
6. **LOW — camera fog/DOF constants absent.** `camera.cfg:59–64` `DynFogDepth/Start/End/Density/Power/Offset` (default `False`) not represented; note these are camera DOF, not fog-of-war or cloud fog. **Visual impact: low (disabled by default).**
7. **LOW — generator/starting-data constants only partly ported.** Port `MAP_TYPES` lacks donor mask paths + DLC5 Coastal/Lakes/Rivers; `startingsettings.cfg` startid 10–13 and `-1`, `dataversionmin/max` gates and country masks are not imported (DB_SCRIPTS G4/G5 remain open). **Gameplay impact: low–medium (map/setup variety).**
8. **INFO — no donor-derived recruit modifier in hotkeys.** Confirms `DONOR_RECRUIT_MODIFIERS.md` D15: the 55 binds contain no train/produce action; Ctrl/Shift click behaviour lives in GUI scripts.

---

## 7. Open questions

1. Is `horseradish.1` duplicated at `envscales.cfg:757` and `:763` a donor typo for `.2`? Both rows are byte-identical; if so the intended second scale may differ.
2. What does `random.cfg:2 field = fax` control? No plaintext consumer was found; label UNVERIFIED until a script reference is located.
3. Does the donor `O` mask glyph mean exactly "officer slot" (inferred from RB_MECHANICS S2/S10), or a different flag? No legend text found in any `.cfg`.
4. Why does `hotkeys.cfg` bind `N` three times (gol/iro/coa) and `G` twice (guard/cancelguard)? Context-sensitive dispatch is inferred, not proven.
5. Donor ` formations.cfg` negative bonuses (`TRI_OLD -10/9/95/-19`, `PRUS_OLD 5/-5/-27/80`) are imported verbatim by the port; are they legacy/dead data or reachable in old saved maps? Requires a version-gate check in `dogenerate.inc`, out of this ticket's scope.
6. Should the port import the full 122-entry envscales table, or is the 3-class approximation an accepted fidelity deviation? Owner call.
7. What is the correct Godot translation of donor light colours given the port's explicit exposure/tonemap compensation? Needs a render-parity measurement, not a float copy.

---

## 8. Evidence index

| ID | Source | Method / note |
|---|---|---|
| `E01` | All 77 donor paths + byte sizes + LastWriteTime | `Get-ChildItem -Recurse -Force -Include *.cfg,*.ini` |
| `E02` | Encoding: 74 ASCII / 3 non-ASCII / 0 BOM / 0 NUL; 2 zero-byte files | `[IO.File]::ReadAllBytes` full scan, twice |
| `E03` | `cossacks.ini`, `editor.ini`, `steam_emu.ini`, `env.cfg`, `light.cfg`, `time.cfg`, `stars.cfg` complete numbered text | `Get-Content -Encoding UTF8`, read twice |
| `E04` | `hotkeys.cfg` 243 numbered lines + counts (55/55/55/9/2/7/3) | full read + independent `Where-Object` count |
| `E05` | `envscales.cfg` 869 numbered lines; 26 groups / 122 names | full read + count |
| `E06` | `formations.cfg` 149 records parsed (id/sym/4 bonuses/all mask rows) + 149 id→line map | `parse_formations.ps1` (temp, outside repo) |
| `E07` | Port `data.gd:380–530` `FORMATION_BONUSES` parsed and diffed vs donor: `donor_count=149 port_count=149 diff_count=0` | `compare_formations.ps1` (temp, outside repo) |
| `E08` | Port `config.gd:135–174,555–566`; `config.json` controls.hotkeys (26 scalar + 16 build) | read-only |
| `E09` | Port `world.gd:216–235` ENV_SCALE/ENV_JITTER; `world3d.gd:19,26–28,409–452` sky/light; `game.gd:3054,3082,3100` formation consumption | read-only |
| `E10` | Structural survey of 12 large files (line counts, section/struct counts, distinct keys) | `survey_cfg.ps1` (temp, outside repo) |
| `E11` | `generator.cfg` terrain path table; `startingsettings.cfg` startid list + sample records | numbered grep + slice read |
| `E12` | Prior-doc evidence IDs cross-referenced: `ev_e350e534…` (hotkeys), `ev_2f2f15d9…`/`ev_24a1cc1a…` (formations), `ev_2c4d3cf4…` (envscales), `ev_c5eeb0c5…` (SphereHeight bytes), `ev_46954ad3…` (DynFogDepth bytes) | from DB_SCRIPTS.md / DECOMP_04 |

No Craft Anything document was written and no shared investigation memory was altered; the only file created by this worker is this report.

---

## 9. Summary

- 77 donor config/ini files inventoried; all are no-BOM, no-NUL text (74 ASCII, 3 with Cyrillic bytes), 2 empty stubs.
- Exact values documented for the 5 priority files: `envscales.cfg` (122 objects, 26 groups, **three** jitter bands), `formations.cfg` (149 IDs, 137 symmetric, **46** non-zero bonus records with exact tuples and masks), `hotkeys.cfg` (**55** bindings in 243 lines, not 243 bindings), `light.cfg` (full RGBA + attenuation + direction), `env.cfg` (all load paths and flare/moon constants).
- Donor fog constants live in `clouds.cfg:6` and `camera.cfg:59–64`; donor sky colours live in `skydome.cfg:11–40`; the binary key names from DECOMP_04 now have concrete external values in `camera.cfg`.
- Secondary port comparison: formation bonuses **fully and exactly imported** (diff 0); hotkeys **partially** imported (42 vs 52 keyed donor binds, flags absent, 3 wrong mappings); env scales **approximated** (3 classes vs 122 entries); light/sky colours **not imported**; camera min/max/pitch imported but pitch is a dead key.
- Highest-impact remaining gaps: donor light/sky colour fidelity, hotkey coverage/semantics, env scale variety.

**Files changed:** exactly one — `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md`. No code edits, no donor writes, no runner jobs.
