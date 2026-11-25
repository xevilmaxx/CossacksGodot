---
id: DSEASON-01
task: "Donor winter / desert / field-crop visual truth for the season swap"
date: 2026-11-25
status: DELIVERED__READ_ONLY_DONOR_AUDIT__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use; Python 3.14 bytes/latin-1 + Pillow; never executed, unpacked or copied)"
output: "docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md"
verification_passes: 2
labels: [observed, derived, inferred, UNVERIFIED, ACTIVE_SCRIPT_TEXT, PLAIN_SCRIPT_ACTIVE, DISABLED_INTENT, INERT_DATA, PORT_APPROXIMATION]
visual_parity_claim: false
---

# DSEASON-01 — Donor winter / desert / field-crop visual truth

> **Scope guard.** This is the only file written. No `.gd`/`.gdshader`/`.json`/asset/config/test
> was edited; no Godot runner job was requested; no donor file was run, unpacked or copied into the
> repo. Donor access was read-only (`open(path,'rb').read().decode('latin-1')` and Pillow pixel reads
> on the original files). All line numbers below are 1-based and were re-read **this pass** unless
> explicitly marked `prior`. **No visual parity is claimed.**

## 1. Sources

### 1.1 Prior documents read in pass 1

| # | Doc | Role |
|---|---|---|
| A1 | `docs/audit/PIECES/winter_variant.md` | winter alias map, palette, `dogenerate.inc` tree rule, port gaps G1–G7, T6-T14 append |
| A2 | `docs/audit/PIECES/desert_variant.md` | 12 desert DDS palette, `generator.cfg` weights, port flat-tint gap |
| A3 | `docs/audit/PIECES/field_crops.md` | `envfieldd`/`envfielddw` DXT5 decals, alpha footprint, port gap |
| A4 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_03_water_weather.md` | water shader, sky/cloud/fog ledger D1–D31, port P1–P6 |
| A5 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | season/climate files, swap functions, active-vs-alternative matrix, gap ranking |
| A6 | `docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md` | relief grids season-neutral: all 680 patterns `NativeSeason=Summer`, `Winter=True` |
| A7 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | SP-1..SP-8 ticket plan, blockers, label set |
| A8 | `docs/coord_swarm_2026-11-25/reports/RV_SEL_01_selection_reverify.md` | **`[*] = ;` convention**: live source encoding, not a comment; `//` is the disable token (`:44-65`, `:397-402`) |
| A9 | `docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md` | `;`-prefixed `.inc` lines = donor intent; native execution UNVERIFIED (`:468-478`) |
| A10 | `docs/coord_swarm_2026-11-25/reports/SP_02_winter_dictionary.md`, `SP_03_desert_remap.md`, `SP_04_winter_atlas.md`, `SP_08_season_test.md` | port SP-2/3/4/8 artifacts and claims |

### 1.2 Fresh donor reads (pass 2, this task)

Path prefix `D:\` below means `C:\Games\Cossacks 3\data\`. Path prefix `P:\` means
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\`.

| File | What was read | Label |
|---|---|---|
| `D:\terrain\tiles\tiles.season` | all 4 lines | observed |
| `D:\terrain\tiles\terrain.lib` | all 19 lines | observed |
| `D:\terrain\tiles\terrain.presets` | both sections, all 248 `TileBlock` lines | observed |
| `D:\terrain\tiles\tiles.mat` | all 253 `Material.Name` → `Material.Texture.image` pairs | observed |
| `D:\terrain\tiles\textures\winter0..26.dds`, `desert1..12.dds` | 112 DDS headers (DXT1, 1024²) + 26 Pillow pixel samples at 200² | observed |
| `D:\objects\env\field.prop`, `fir.prop`, `terrainmesh1.prop` + 40+ prop files | `UseableWinterMaterials`, `UseSeasonMaterial`, decal property | observed |
| `D:\materials\env\env.mat` | winter material definitions (`fir1w`, `fieldw`, `field1w`, `stonesw`, …) + 4 texture mean comparisons | observed |
| `D:\terrain\decals\env\envfieldd.dds`, `envfielddw.dds` | DXT5 headers, alpha bbox, opaque means | observed |
| `D:\terrain\decals\decals.lib`, `decals.mat` | Summer/Winter decal material names | observed |
| `D:\gen\mapcover.cfg` | all 41 lines | observed |
| `D:\env\colors\colors.lib` | tables `[6]`/`[7]`, whole-file season scan | observed |
| `D:\env\colors\0.palette`…`11.palette` | full-file SHA-256 of all 12 | observed |
| `D:\env\**` (all `.cfg/.lib/.mat/.weather/.presets`) | season / winter / snow / weather token scan | observed |
| `D:\water\water.lib`, `D:\shaders\water\water.dev.frag` | water set table + colour constants | observed |
| `D:\scripts\common.inc\dogenerate.inc`, `texturemap.inc`, `onloadfull.inc` | season lines with byte prefixes | observed |
| `D:\scripts\lib\miscext.script` | `_misc_SetDesert` `:1429-1543`, `_misc_SetSeason` `:1547-1628` | observed |
| `P:\variant3d\assets\terrain\atlas\winter_aliases.json`, `desert_remap.json`, Winter atlas/manifest | on-disk existence + counts | observed |
| `P:\variant3d\scripts\world3d_terrain.gd`, `data.gd`, `tile_atlas_loader.gd`, `world3d_entities.gd` | season hook read-only | observed |

**Labels used below.** `OBS` = literal bytes/lines/pixels read this pass; `DER` = arithmetic over
observed values; `INF` = best reading with caveat; `UNV` = not provable from readable data.
Activity labels: `ACTIVE_SCRIPT_TEXT` = `[*] = ;`-prefixed `.inc` source line (live encoding per
A8; native execution still `UNV`); `PLAIN_SCRIPT_ACTIVE` = unprefixed `.script` procedure;
`DISABLED_INTENT` = `//` or `{ }`-wrapped; `INERT_DATA` = config bytes with no proven consumer.

---

## 2. Season matrix — exactly what changes visually

### 2.1 Top-level season selection and ground tiles

| Visual axis | Summer (default, season 0) | Winter (season 2) | Desert (season 3) | Evidence / label |
|---|---|---|---|---|
| Set selection | `seasons.Summer/Autumn/Spring = Summer`; `Default = Summer` | `seasons.Winter = Winter` | **not** a `terrain.lib` season; `gen.season=3` | `D:\terrain\tiles\terrain.lib:2-4,12-15`; `D:\scripts\common.inc\dogenerate.inc:2079` (`[*] = ;`). OBS |
| Preset table | `SetName=Summer`, `WaterSet=Summer`, 124 blocks at `:6-129` | `SetName=Winter`, `WaterSet=Winter`, 124 blocks at `:138-261`; end `:263` | Summer names remapped **in place**; no Desert preset section | `D:\terrain\tiles\terrain.presets:2-4,131,133-136,261,263`. OBS |
| Tile names | `grass1…`, `rock*`, `sandsea1-6`, `desert1-12` | 1:1 rename with `_winter` appended on **121/124** names; 3 alpha names shared | explicit name→name case table | `terrain.presets:138-261`; parse this pass found **0** rename mismatches vs that rule. OBS + DER |
| Art resolution | `grass1 → grass1.dds` etc. | 124 aliases → **35 unique textures**: 23 `winter*.dds` + 12 **unchanged** `desert*.dds`; `desertN_winter → desertN.dds` | 12 `desert*.dds`, 4 tonal families | `D:\terrain\tiles\tiles.mat:454` (`grass1_winter→winter10.dds`), `:522` (`rock1_winter→winter12.dds`), `:953` (`desert1_winter→desert1.dds`); 253-pair parse this pass. OBS |
| Alpha/mask tiles | `alpha0a/b/c → grass1.dds` | Winter preset uses **shared** `alpha0a/b/c` (`:224,:248,:261`), resolving to `grass1.dds`; `_winter` variants exist in `tiles.mat` but are **not** in the preset | `alpha0a → alpha0c` | `terrain.presets:224,248,261`; `tiles.mat:347,352,357`; `miscext.script:1501`, `:1609-1625`. OBS |
| Unaliased / trap art | — | `winter18/23/24/26` have no `tiles.mat` alias; `winter25` is **green grass** (0% snow), reached by `sand1s_winter`, `test21/23/25_winter` | `d_tls_2` Freq **0** (disabled) | `tiles.mat` winter-target parse this pass (23 distinct numbers: 0–17,19–22,25); `generator.cfg:1629-1655` via A2/A5 prior. OBS + OBS-prior |

**Fresh pixel truth (200² downsample, Pillow, snow test `R,G,B≥225 & B≥R`) — OBS, DER:**
`winter21` 98.86% snow, mean `#FCFDFD`; `winter19` 95.86%, `#F2F4F6`; `winter1` 93.5%,
`#F4F4F5`; `winter2` 93.6%, `#F0F0F0`; `winter10` 80.1%, `#F6F6F7`; `winter0` 81.3%,
`#F7F7F7`; `winter3` 45.0%, `#DFE0E2` (blue-grey); `winter11` 0%, `#9E897F` (tan gravel —
`ground1_winter`); `winter12` 0%, `#7E7A75`, `winter22` 0%, `#7A6969` (rock); `winter25/26`
0%, `#3C471D` (green grass). Desert: light sand `desert1/6/11/12` ≈`#7B7253` (mean L 113–124),
mid `desert9/10` ≈`#6E6546`, dark cracked `desert2/3` ≈`#5A4F31` (L≈90), dark scree
`desert4/5` ≈`#5C5233`. All 39 sampled files are 1024² **DXT1**, alpha `(255,255)` (OBS).
*Scale note:* the 200² resize lowers the measured snow fraction versus the full-resolution
numbers in A1 §1.2 (`winter10` 90.5%); the ordering and palette conclusions agree, the absolute
percentages are not interchangeable.

### 2.2 Props and ground clutter

| Visual axis | Summer | Winter | Desert | Evidence / label |
|---|---|---|---|---|
| Prop material | `UseableSummerMaterials` on every `.prop` | `UseSeasonMaterial=True` + `UseableWinterMaterials` with suffix **`w`**; art exists in donor | no `w` rule; `desert*` props + desert frequency keys | `D:\objects\env\fir.prop:33-43`, `field.prop:58-76`, `grass.prop:36-42`, `terrainmesh1.prop:16-18`, `miscext.script:1578-1599`. OBS |
| Concrete winter art | — | `fir1w/2w/3w`, `field1w…4w`, `fieldw`, `leaftree1w…3w`, `plantsatlasw`, `palm1w…3w`, `desert1w`, `stonesw`, `smallstonesw`, `rocksw`, `terrainmesh1w` — all defined in `D:\materials\env\env.mat:815-895` and backed by on-disk `.dds` | — | OBS |
| Measured winter-vs-summer art (raw texture mean, 100² sample) | `fir1` (29.1,26.2,11.5); `plantsatlas` (33.0,34.5,6.4); `stones` (53.1,44.3,32.9); `field1` (10.2,11.6,1.0) | `fir1w` (50.0,50.9,39.9); `plantsatlasw` (78.7,70.9,51.8); `stonesw` (98.9,99.2,96.4); `field1w` (28.5,29.5,23.6) — brighter, desaturated/frosted | — | `D:\materials\env\*.dds` pixel reads (OBS). Final screen colour also uses material emission (`env.mat:870-884`), so raw means are **not** screen colours (INF) |
| Trees | all families | every object whose basename contains `leaftree` is destroyed; conifers (`fir`, `spruce`, `pine`, `pinebroken`) survive | `desert_frt_*` palm/drytree/desertstump patterns; non-`stones*` / non-`field` env objects destroyed | `dogenerate.inc:1975-1982`; `miscext.script:1568-1576`, `:1536-1537`; A6 §3 (680/680 patterns season-neutral). OBS + OBS-prior |
| Terrain relief | same height grid | **same height grid** — season difference is prop material only (`terrainmesh1 → terrainmesh1w`) | dry land height `koef=0.8` (`miscext.script:1513-1520`); mines basename `+s` (`:1531-1534`) | `terrainmesh1.prop:16-18`; A6 §3 `pattern.lib` 680/680 `NativeSeason=Summer`/`Winter=True`. OBS + OBS-prior |
| Building children | `detail` material | `detail → detailw` (non-essential buildings with children) | unchanged | `miscext.script:1585-1597`. OBS |

### 2.3 Field crops (summer/winter decal pair)

| Visual axis | Summer | Winter | Evidence / label |
|---|---|---|---|
| Decal asset | `envfieldd.dds` — DXT5 512², alpha bbox `(17,19,494,494)`, opaque mean **`#4D442E`** | `envfielddw.dds` — DXT5 512², **identical alpha bbox**, opaque mean **`#756F61`** (desaturated grey) | fresh Pillow read, `D:\terrain\decals\env\*.dds` (OBS) |
| Season binding | `Decal.SummerLibMaterialName = envfieldd` | `Decal.WinterLibMaterialName = envfielddw` | `D:\terrain\decals\decals.lib:37-44`. OBS |
| Registration | `Material.Name = envfieldd → .\data\terrain\decals\env\envfieldd.dds` | `Material.Name = envfielddw → …envfielddw.dds` | `D:\terrain\decals\decals.mat:110-115`. OBS (corrects A3's byte-offset-only citation) |
| Prop spring point | `_misc_PlaceFieldDecal` uses `const decalname = 'envfieldd'`, `AddNewDecalByLibName` — decal library resolves the winter material | same call site; winter variant comes from `decals.lib`, not a second script branch | `D:\scripts\lib\misc.script:4284-4295`; `miscext2.script:772` (`ProjectLoadDecalMaterial('envfieldd')`). OBS |
| Disabled alternative | `//decalproperty … //DefaultDecalName = envfieldd` in `field.prop` — **disabled** | — | `D:\objects\env\field.prop:152-157` — `DISABLED_INTENT` |
| Gold colour | donor decal itself is olive/brown; gold is a render-time tint (A3 §1.1/§5) | grey decal, not gold | A3 prior + fresh means. INF |

### 2.4 Water colour, sky/light, fog

| Visual axis | Donor truth | Seasonal delta? | Evidence / label |
|---|---|---|---|
| Water colour | one water set only — `waters[*].Name = default`; `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`; shader `watercolor=(0.1,0.24,0.24)`, `watercolor2=(0,0.025,0.05)`, specular `(0.4,0.4,0.4)` | **No readable seasonal colour change.** Winter preset says `WaterSet=Winter` but no `Winter` entry exists in `water.lib`; the binding is engine-side | `D:\water\water.lib:2-65`; `D:\shaders\water\water.dev.frag:37-47`; `terrain.presets:3,135`. OBS; binding UNV |
| Sky | two-band unlit/unfogged gradient, fixed colours; **no `season`/`winter` token anywhere** in `skydome.cfg`/`skydome.mat`/`clouds.cfg` | unchanged by season in readable data | full-file scan of `D:\env\**` this pass; `skydome.cfg:8-55` via A5 §2.6. OBS |
| Light / colour table | table 0 `default`; winter table 6 `{refkey=.statictables[0]}` overriding **only** `ShadowBlendingDiffuse = 180,180,200,128` (`#B4B4C8`); desert table 7 ← yellow `[1]`, override `140,140,180,128`; all 12 `.palette` files byte-identical (1 distinct SHA-256 `13012f3d…`) | winter/desert differ **only** in shadow-blend tint + PHDR/palette selector; no new albedo | `D:\env\colors\colors.lib:94-101`; `dogenerate.inc:2075-2084`; `onloadfull.inc:70-79`; 12-file hash this pass. OBS |
| Clouds / weather | `Weather=40`, `WeatherRandom=False`; 12 cloud presets all have `season = 2` (meaning UNV); only `soft1-3` band 10–50 active | `season=2` **not** mappable to `GetSeasonType=2` without inventing behaviour | `D:\env\clouds\clouds.weather:3-6`; `clouds.presets:12,30,48,66,84,102,120,138,156,174,192,210`. OBS; semantics UNV |
| Snow particles | `snow1..4` configured, `WeatherStart=70`, `WeatherEnd=100` for all four | inactive at `Weather=40` — configured, not active | `D:\env\pfx\particles.snow.cfg:32-33,72-73,112-113,152-153`; `particles.lib:2-14`. OBS + DER |
| Fog | scene fog in table 0 (`Fog=(60,100,150,1)`, start 390, end 490, mode 0); winter `[6]` and desert `[7]` inherit via `refkey` → **fog unchanged**; `FogMode=0` ambiguity (0-based `fmLinear` vs 1-based shader off) per A5 §2.10 | no season-specific fog value; mode mapping UNV | `colors.lib:18-43,94-101`; A5 §2.10/§6 C4. OBS + OBS-prior; UNV |

---

## 3. Activity labels (RV-SEL-01 / RV-TRN-02 conventions)

| Donor site | Literal | Activity label | Why |
|---|---|---|---|
| `D:\scripts\common.inc\dogenerate.inc:1975-1982` | `[*] = ;if (GetSeasonType=2) … leaftree … GameObjectRequestToDestroyByHandle` | **ACTIVE_SCRIPT_TEXT** (native execution UNV) | A8 `:44-65,397-402`: `[*] = ;` is the live `Code`-struct storage encoding, not a comment; `//` is the real disable token |
| `dogenerate.inc:2075-2084` | `[*] = ;SetCurrentColorTableIndex(6/7/0)` + PHDR 1/0 | ACTIVE_SCRIPT_TEXT (UNV) | same encoding |
| `D:\scripts\common.inc\onloadfull.inc:70-79` | identical palette selection | ACTIVE_SCRIPT_TEXT (UNV) | same encoding |
| `D:\scripts\common.inc\texturemap.inc:525-526,605-606` | `[*] = ;if GetSeasonType=2 then newtile := newtile+'_winter'` | ACTIVE_SCRIPT_TEXT (UNV) | same encoding; this is the alias rule the port encodes |
| `dogenerate.inc:1951-1968` | `{if (GetSeasonType=2) … SetTileIndex(...,'grass1_winter') …}` | **DISABLED_INTENT** | whole block wrapped in `{ }`; shipping maps select per preset, not one flat tile |
| `dogenerate.inc:2085-2090`, `onloadfull.inc:80-84` | `//SetCurrentColorTableIndex(5)` (christmas), `//SetLightPattern(lid)` | DISABLED_INTENT | `//` prefix = real disable token per A8 |
| `D:\scripts\lib\miscext.script:1429-1543` | `_misc_SetDesert` — 38 active `case` entries | **PLAIN_SCRIPT_ACTIVE** | unprefixed `.script` procedure; no `[*] = ;`, no `//` on executed lines |
| `miscext.script:1547-1628` | `_misc_SetSeason(season)` — destroy `leaftree`, `detail→detailw`, alpha0a↔alpha0b | PLAIN_SCRIPT_ACTIVE | same |
| `miscext.script:1458-1460,1466-1467,1470,1478` | `//'grass2' … 'sandrock1'` etc. | DISABLED_INTENT | `//`-commented alternative cases |
| `D:\terrain\tiles\terrain.lib:12-15`, `terrain.presets:2-4,133-136`, `tiles.mat:454/522/953`, `colors.lib:94-101`, `decals.lib:37-44`, `field.prop:58-76` | config/material bytes | **INERT_DATA** (intent; consumer binding UNV) | values are real bytes; which engine path binds them is engine-side (A9 §4.6) |
| `D:\gen\mapcover.cfg:12-15` | four empty season names; **no** `DesertTileName` field | INERT_DATA / empty | `resource.lib:36-37,42` zone filenames empty (A5 §3.4) |
| `D:\terrain\tiles\tiles.season:2-3` | `TexName=grass1`, `Summer=grass1`; no Winter/Desert rows | INERT_DATA / stub | not the swap mechanism |
| `D:\env\clouds\clouds.presets:12…210` | `season = 2` on all 12 | INERT_DATA + UNV semantics | if read as `GetSeasonType=2` it would make clouds winter-only — implausible; do not encode (A5 Q4) |
| `D:\objects\env\field.prop:152-157` | `//DefaultDecalName = envfieldd` | DISABLED_INTENT | `//` prefix |

**Net activity statement.** The *winter tile suffix*, *leaf-tree deletion*, *palette selection* and
*alpha swap* are authored **active** donor intent (plain script or `[*] = ;` live source). The
correct residual caveat is **"native EXE execution is UNVERIFIED"** (A8/A9), **not** "the lines are
commented out". The winter/desert *differences themselves* are real on-disk art/config bytes.

---

## 4. Port gap ranking (read-only comparison to SP-2/SP-3/SP-4)

**What is already landed:** SP-1 `SEASON_ENUM` (`P:\variant3d\scripts\data.gd:227`); SP-2
`winter_aliases.json` (124 entries, 23 winter + 12 desert-reuse PNGs); SP-3 `desert_remap.json`
(`:53-65` 11 direct + `:66-78` 1 height-gated); SP-4 Winter atlas (124.5 MB PNG + manifest);
SP-5 `manifest_path` override (`tile_atlas_loader.gd:77,86,99-118,313,405`); SP-6 renderer hook
(`world3d_terrain.gd:269-282` season table, `:397-427` selection/fallback, `:1340-1344` desert
remap applied to `tid`). So the **tile-art swap is no longer a data gap** — this is a correction to
SP-08's stale §5 (which still reports SP-4/SP-6 absent). No `t_season_overlay.json` result exists
on disk (`P:\variant3d\tests\results\` checked this pass), so SP-6 has no recorded run/visual check.

| Rank | Missing / wrong visually | Donor evidence | Port evidence | Label |
|---:|---|---|---|---|
| **1** | **Desert remap covers only 11 of 38 donor cases.** 26 active source→target pairs are absent (`grass3`, `grass5`, `grass6`, `grass9/10`, `grass_ground1/2/3`, `rock3/4/5/8`, `sandrock2/3/4`, `test0/1/2/3/4/5/6/9/11/12/13/14`). Those families keep Summer grain in a desert scene. Also donor base `rock8→test22` (`:1477`) is missing; port has only gated `rock8→desert2`. | `miscext.script:1447-1502` — fresh parse found **38** active `case` entries | `desert_remap.json:53-65` — 11 direct; `:66-78` — 1 gated. Fresh set-difference: 26 donor pairs absent, 0 invented | OBS both sides; **top visual gap** |
| **2** | **No winter prop-art (`w`) in the port.** Conifers, plants, stones, field meshes and terrainmesh props stay Summer-textured; only 226 building `*_w.dds` decals exist, and the season prop hook (SP-7) is not landed. | `env.mat:815-895`; `fir.prop:33-43`, `field.prop:58-76`, `grass.prop:36-42`, `terrainmesh1.prop:16-18`; fresh check: `fir1w/field1w/plantsatlasw/stonesw/terrainmesh1w.dds` all present | repo-wide search found **0** files named `fir1w*`, `field1w*`, `plantsatlasw*`, `palm1w*`, `desert1w*`, `terrainmesh1w*`; `SEASON_PLAN_01.md:207` B1b; `world3d_entities.gd` has no `leaftree`/`fir1w` path | OBS both sides; **2nd visual gap** |
| **3** | **Winter/desert lighting table not represented.** No `#B4B4C8` shadow-blend override, no PHDR 1, no cool cast from light; the only season colour is the legacy flat `TERRAIN_TINT` glaze, which A5/A7 explicitly label **not** the donor mechanism. Scene fog remains `fog_mode=0` / inert. | `colors.lib:94-101`; `dogenerate.inc:2075-2084`; `onloadfull.inc:70-79` | `data.gd:231-241` (`TERRAIN_TINT` labelled legacy); `terrain_tileindex.gdshader` `fog_mode=0` via A5 §5.3 rank 5 | OBS donor; port OBS-prior |
| **4** | **Winter field-crop decal is recorded, not drawn.** `envfielddw` grey art exists in port PNG form, but alpha was flattened and the 3D mesh uses per-instance tint; winter fields do not show the donor grey stubble decal. | `decals.lib:37-44`; `envfielddw` opaque mean `#756F61` (fresh) | `world3d_entities.gd:244-245,328-333,430` — paths only in `field_visual_decals` stats; comment `:328-329` "3D UV mapping UNVERIFIED"; A3 §1.3 alpha flattened | OBS both sides |
| **5** | **Alpha mask swap not represented.** Donor winter flips `alpha0a→alpha0b` tile indices; port Winter atlas leaves the three alpha cells EMPTY/transparent (indices 86/110/123), while donor winter art resolves those names to `grass1.dds`. | `miscext.script:1609-1625`; `terrain.presets:224,248,261`; `tiles.mat:347,352,357` | SP-04 §3 / manifest: 3 EMPTY cells; `winter_aliases.json` flags `shared_alpha` but SP-4 leaves art unpacked | OBS donor + OBS-prior port; alpha subrect mapping UNV |
| **6** | **No water-season expression.** `WaterSet=Winter` has no readable definition and the shader colours are fixed, so there is nothing donor-grounded to port; the port's flat water quad also lacks all donor surface effects. | `water.lib:2-65`; `water.dev.frag:37-47`; `terrain.presets:3,135` | A4 P1/P5: 3D quad constant albedo; 2D shader has equations but `water_level=1.0` is a port choice | UNV (donor binding) + OBS port; **not a season-colour gap to invent** |
| **7** | **No verification of the landed season hook.** SP-8 atom authored with a stale dependency table and never run; no result JSON, no matched-camera capture, no donor A/B. | — | `SP_08_season_test.md:6,157-159` (claims SP-4/SP-6 absent); no `tests/results/t_season_overlay.json` on disk | OBS; process/verification gap, not a visual claim |

**Ranked summary:** 1 (desert remap 11/38) → 2 (prop `w` art absent) → 3 (lighting/fog table absent)
→ 4 (winter field decal unwired) → 5 (alpha mask swap) → 6 (water: UNV, do not invent) → 7 (no run/visual check).
The **winter ground-tile swap itself is landed** (SP-6 + SP-4) and is therefore *not* in the gap list.

---

## 5. Corrections to prior docs

| # | Prior claim | Fresh finding | Evidence / label |
|---:|---|---|---|
| C1 | A5 §7 Q6 / SP-02 Q5 / SP-03 §5: season lines "carry the donor comment prefix", so activity UNVERIFIED | **CORRECTED.** Per A8 (`:44-65,397-402`), `[*] = ;` is live source encoding, `//` is the disable token. The season lines are ACTIVE_SCRIPT_TEXT (native EXE execution remains UNV). Separate genuine disables are `{ }` at `dogenerate.inc:1951-1968` and `//` at `:2085-2090` | fresh reads; A8 |
| C2 | SP-08 §5: SP-4 atlas and SP-6 hook "absent" → PENDING_DEP | **STALE.** All artifacts/code are on disk now; SP-6 selects `tile_index_atlas_winter.*` | on-disk inventory + `world3d_terrain.gd:269-282,397-427`; no result JSON found |
| C3 | A1 §1.2 lists `alpha0a_winter/alpha0b_winter/alpha0c_winter` as the winter mask carriers | **CORRECTED.** The Winter **preset** uses shared `alpha0a/b/c` at `:224,:248,:261`, resolving to `grass1.dds` (`tiles.mat:347,352,357`). The `*_winter` alpha materials (e.g. `tiles.mat:798`) exist but are not referenced by the Winter preset | fresh reads |
| C4 | SP-02/SP-04 treat `alpha0a/b/c` `source_png` (`winter0/1`) as alias carriers and leave those atlas cells EMPTY | consistent with the manifest, but the port therefore does **not** reproduce the donor's `alpha0a→alpha0b` index swap or the `grass1.dds`-backed mask; label PORT APPROX / UNV | `miscext.script:1609-1625`; SP-04 §3 |
| C5 | SP-03 presents 11 direct + 1 gated pairs as "the donor remap" | **CORRECTED.** Donor has **38** active `case` entries at `miscext.script:1447-1502`; port covers 11 (26 pairs missing) | fresh parse this pass |
| C6 | A5 §4 records `WaterSet=Winter` as if a distinct water palette exists | **REFINED.** Only one `waters[*]` entry (`default`) exists in `water.lib`; shader colours are fixed; a Winter water set is UNV, not an established visual delta | `water.lib:2-65`; `water.dev.frag:37-47` |
| C7 | A5 §3.4 "mapcover.cfg seasonal names empty" | **CONFIRMED**, and stronger: there is no `DesertTileName` field at all — only Summer/Autumn/Winter/Spring at `:12-15` | fresh read |
| C8 | A3 cites `decals.mat` field entries by byte offset (~2863/~3007) | precise lines are `decals.mat:110-115`; names/pairs unchanged | fresh read |
| C9 | A1 snow-% numbers (e.g. `winter10` 90.5%) | measurement-scale note: fresh 200² downsample yields 80.1% for `winter10`; ordering/palette agree, absolute percentages are convention-dependent — **not a contradiction** | this pass vs A1 §1.2 |
| C10 | A5 §3.7 / A7 §7 palette identity | **CONFIRMED** fresh: all 12 `.palette` files share SHA-256 `13012f3d…` | this pass |

---

## 6. Open questions (do not guess)

1. **Do the `[*] = ;` season scripts execute in the shipped EXE?** Activity at the source-text level is settled (A8); native execution is still UNV. This report implements/describes **intent**, not proven runtime.
2. **What does cloud `season=2` mean?** All 12 presets carry it (`clouds.presets:12…210`). If it is `GetSeasonType=2`, clouds become winter-only — implausible. Do not encode.
3. **Where is the `WaterSet=Winter` definition?** `water.lib` has only `default`; engine-side or absent. No winter water colour may be invented.
4. **What does the donor render for `alpha0a/b/c` in winter** given the preset shares the names but `_misc_SetSeason` flips alpha0a→alpha0b? The `.dds` resolves to `grass1.dds`; alpha subrect behavior is engine-side (UNV).
5. **Should the port's missing 26 desert remap cases be added?** They are donor-active text but runtime-UNVERIFIED; a port change needs its own ticket and labels, not an assumption of parity.
6. **Can donor prop `w` art (`fir1w`, `field1w`, `plantsatlasw`, …) be converted for the port?** Availability/copyright and asset pipeline are out of scope here; currently zero such files exist in `variant3d/`.
7. **Was SP-6 actually run?** No `t_season_overlay.json` result and no matched-camera capture were found; the existing SP-08 report predates SP-4/SP-6. Needs a runner owner.
8. **Does the gold field tint survive winter?** Donor winter decal is grey `#756F61` but its prop material `field1w` uses emission (`env.mat:895+`); the render-time gold multiplier was not inspected. INF only.
9. **Are the winter tree differences scenario-vs-generated?** Generated maps delete `leaftree` (`dogenerate.inc:1975-1982`); authored scenarios can retain bare broadleaf. Same V1 mode caveat as A1.

---

## 7. Summary

The donor season swap is **set/name/material driven, not a tint**. Winter is a 124-entry preset whose
121 renamed aliases resolve to 23 `winter*.dds` snow/rock/gravel tiles plus the same 12 `desert*.dds`
used unchanged (`terrain.presets:133-263`; `tiles.mat:454,522,953`). Desert is a separate
`gen.season=3` in-place remap of 38 active summer-family names to sand/desert names, a 0.8 height
scale and mine `s` suffix (`miscext.script:1429-1543`). On top of the ground, the visible deltas are:
prop materials gain a `w` suffix with brighter, desaturated/frosted art (`fir.prop:33-43`,
`env.mat:815-895`), `leaftree` objects are destroyed while conifers survive (`dogenerate.inc:1975-1982`),
field crops switch from the olive `#4D442E` decal to the grey `#756F61` decal
(`decals.lib:37-44`), and only the **shadow-blending** colour changes in the lighting table
(`colors.lib:94-101`). Water colours, sky gradient, scene fog and cloud weather have **no readable
season-specific values**; snow particles are configured but inactive at `Weather=40`.

Activity convention: the `[*] = ;` lines are **live** source (A8), not comments; genuine disables are
`//` and `{ }`. Native EXE execution remains UNVERIFIED throughout.

Against the port: Winter tile art, alias dictionary and desert indices are now landed
(SP-2/3/4/5/6). The largest remaining **visual** gaps are the incomplete desert remap (11 of 38
donor cases), the total absence of winter prop `w` art, the missing winter lighting/fog table, and
the unwired grey winter field decal. The port's flat `TERRAIN_TINT` must not be mistaken for the
donor swap. No donor binary was copied or executed; no code was edited; no visual parity is claimed.

*End of DSEASON-01. One report written. No donor file copied, run or modified; no port source,
asset, config, test or git state changed; no Godot runner job; no test weakened.*
