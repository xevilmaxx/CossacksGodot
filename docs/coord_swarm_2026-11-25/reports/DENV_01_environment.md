---
id: DENV-01
task: "Donor environment / season / sky / weather truth for terrain visual fidelity"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_COPY__NO_CODE_EDIT
scope: "Read-only donor data research + port-gap analysis. This report is the ONLY file written; no code/asset/config/test/git edit, no runner job, no donor binary run/copied."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python bytes + latin-1; never executed, unpacked or copied)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md"
labels: "observed = literal donor/port bytes read directly | derived = arithmetic/control-flow from observed | inferred = plausible reading with caveat | UNVERIFIED = not provable from readable data"
verification_passes: 2
visual_parity_claim: false
---

# DENV-01 — Donor environment / season / sky / weather truth

## 0. Goal

Produce the donor-authoritative record for **everything that colours and clothes the world above
and around the ground** — `data\env\**` (light, colours/palettes, sky dome, stars, clouds, weather,
time, flares, particles), the season/climate files (`terrain.lib`, `tiles.season`, `terrain.presets`,
`mapcover.cfg`, generator enums and the `_misc_SetDesert` / `_misc_SetSeason` swap functions) — then
decide which values are **active by default** versus dormant alternatives, and rank what is still
missing or wrong in `variant3d/scripts/world3d_terrain.gd` and the `data.gd`/`config.gd` season
settings. No port file was edited and no Godot job was run.

Motivation (from the spawning brief): DEC-03 found light/sky colours were not imported into the
port; TRN-GEOM has since imported the `light.cfg` constants and the two sky-band colours. The
sky/season/weather side still needs a deeper donor record before further port work.

---

## 1. Sources and method

### 1.1 Prior documents read (all read in full this session)

| Doc | Role / claim tested |
|---|---|
| `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` | exact `env.cfg`/`light.cfg`/`time.cfg`/`stars.cfg`/`clouds.cfg`/`skydome.cfg`/`particles.snow.cfg` values; §4.2–4.4 re-verified here |
| `docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shaders.md` | shader/fog sections §4.1, §4.3–4.5, §5; camera `DynFog*` block |
| `docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md` | C20 "fog off by default"; C28 remaining gaps; §9 summary |
| `docs/coord_swarm_2026-11-24/reports/TERRAIN2_03_water_weather.md` | D20–D31 env/sun/sky/cloud/fog ledger, P1–P6 port comparison |
| `docs/coord_swarm_2026-11-24/reports/DEEPDEC_04_fog_light_sky.md` | binary fog/light consumers, RTTI enums, active-vs-inactive table §3 |
| `docs/audit/PIECES/winter_variant.md` | winter alias map, palette, `dogenerate.inc` tree rule, port gap G1–G7 |
| `docs/audit/PIECES/desert_variant.md` | desert palette, `generator.cfg` weights, port flat-tint gap |

### 1.2 Two verification passes (read-only)

- **Pass 1 — numbered text.** `python` 3.14: `open(path,'rb').read().decode('latin-1').split('\n')`,
  printed with 1-based line numbers. Used on every donor file cited below.
- **Pass 2 — independent extraction + digests.** A separate regex/key extractor re-read the same
  files and emitted canonical `key = value` lines plus SHA-256 prefixes (§1.3). Where pass 1 and
  pass 2 agree, values are marked **observed, verified twice**. Prior-lane reads (DEC-03,
  DEEPDEC-04, TERRAIN2-03) provide a third, independent provenance check; all important numbers
  agree with them unless a correction is recorded in §9.
- No donor file was modified, executed, unpacked or copied into the repo. No Godot process was
  started. Port files were read only.

### 1.3 Fresh donor file inventory — `data\env\**` (observed, pass 1)

| Path (relative to donor `data\`) | Bytes | Role |
|---|---:|---|
| `env\env.cfg` | 976 | env root: load chain, lens flare / moon constants |
| `env\time.cfg` | 163 | clock: fixed date/time, speed factors |
| `env\lights\light.cfg` | 902 | **active parallel light** (sun) colours/vector |
| `env\lights\light.ref` | 4,518 | light-pattern[0] world-scale sun + duplicated sky/weather/date |
| `env\lights\light.presets` | 4,631 | light0..light3 alternative patterns |
| `env\colors\colors.lib` | 3,496 | 8 static colour tables — **fog colour/start/end/mode live here** |
| `env\colors\0.palette` … `11.palette` | 6,576 each | 12 palette data files — **all byte-identical** (§3.7) |
| `env\skydome\skydome.cfg` | 1,454 | two-band gradient dome geometry/colours |
| `env\skydome\skydome.mat` | 2,789 | sky material flags |
| `env\skydome\stars.cfg` | 161 | star field |
| `env\skydome\textures\menu.dds` | 524,416 | menu sky texture (not the skirmish gradient) |
| `env\clouds\clouds.cfg` | 713 | cloud block: horizon/height/fogdensity/speed/count ladders |
| `env\clouds\clouds.weather` | 510 | weather=40, wind vector |
| `env\clouds\clouds.presets` | 4,134 | 12 weather-banded cloud presets |
| `env\clouds\clouds.mat` | 6,318 | 12 unlit transparent cloud materials |
| `env\clouds\textures\soft{1-3}.dds`, `volume{1-3}.dds`, `dark{1-3}.dds`, `storm{1-3}.dds` | 87,536 each | 12 cloud sprite sheets |
| `env\flares\default.cfg` | 10,394 | lens flare definition — `visible=False` |
| `env\flares\textures\*.tga/.bmp` | 49,196–262,198 | day01..05 / morning / evening / moon flare art |
| `env\pfx\particles.lib` | 307 | particle cube manager: snow |
| `env\pfx\particles.mat` | 10,772 | particle materials |
| `env\pfx\particles.snow.cfg` | 3,557 | 4 snow particle blocks |
| `env\pfx\textures\snow{1-4}.bmp` | 4,152 each | snow sprite sheets |

**Fog is not a key in `env.cfg`** (confirmed pass 2). Three different "fog" mechanisms exist in
the donor and must never be merged — see §3.9.

SHA-256 prefixes (pass 2, first 16 hex): `env.cfg b29c94ac4a2ddb22`,
`time.cfg 37113b2dc9ba9680`, `lights\light.cfg 923940d1cd5658e8`,
`lights\light.ref 72de10836e8ac2b6`, `clouds\clouds.cfg 6a1ed1315ee4c74a`,
`clouds\clouds.weather 1e5a23d7f24ff774`, `skydome\skydome.cfg 884ab6473394561e`,
`skydome\stars.cfg cb61c65daeb04545`, `colors\colors.lib 5f7ea22d86e7828b`,
`terrain\tiles\terrain.lib ce6631c0b1cb7ffd`, `terrain\tiles\tiles.season 1868b5316e0a41e4`,
`gen\mapcover.cfg ff0a7bf43314af53`.

---

## 2. Donor env value tables (all observed, verified twice unless labelled)

### 2.1 `env.cfg` — load chain and flare/moon constants

| Key | Value | path:line | Meaning / confidence |
|---|---|---|---|
| `Visible` / `Active` | `True` / `True` | `env.cfg:2-3` | environment rendered/updated — observed |
| `LensFlareSunriseHour` / `LensFlareDawnHour` | `7` / `23` | `:4-5` | flare window — inferred |
| `LensFlareOrbitRadius` | `20000` | `:6` | orbit radius — inferred |
| `LensFlareZOffset` / `LensFlareAngle` | `0.3` / `30` | `:7-8` | flare bias/cone — inferred |
| `lensflaretextured` | `false` | `:9` | flat flare colours — observed; but flare `visible=False` (§2.10) |
| `MoonSunriseHour` / `MoonDawnHour` | `23` / `7` | `:10-11` | moon window — inferred |
| `MoonOrbitRadius` / `MoonZOffset` / `MoonAngle` | `20000` / `0.3` / `30` | `:12-14` | moon rig — inferred |
| `DateTimeManager.LoadFromFile` | `.\data\env\time.cfg` | `:15` | clock source — observed |
| `ColorTableInterface.LoadFromFile` | `.\data\env\colors\colors.lib` | `:16` | **palette/fog source** — observed |
| `SkyDome.LoadFromFile` | `.\data\env\skydome\skydome.cfg` | `:17` | sky source — observed |
| `Air.LoadFromFile` | `.\data\env\clouds\clouds.weather` | `:18` | weather source — observed |
| `CloudsBlock.LoadFromFile` | `.\data\env\clouds\clouds.cfg` | `:19` | cloud source — observed |
| `LensFlare.LoadFromFile` | `.\data\env\flares\default.cfg` | `:20` | flare source — observed |
| `Moon.LoadFromFile` | *(empty)* | `:21` | no moon config — observed |
| `LightSourceManager.LoadFromFile` | `.\data\env\lights\light.cfg` | `:22` | **sun source (active)** — observed |
| `ParticleCubeManager.LoadFromFile` | `.\data\env\pfx\particles.lib` | `:24` | particle library — observed |
| `ParticleCubeManager.MaterialLibraryInterface.LoadFromFile` | `.\data\env\pfx\particles.mat` | `:25` | particle materials — observed |

`resource.lib:18` (`EnvironmentFileName = .\data\env\env.cfg`) makes this chain **active**;
`resource.lib:50` selects `camera.cfg`; `:66` `tiles.season`; `:67` `light.presets`;
`:14` `terrain.presets`; `:15` `terrain.lib`; `:70` `mapcover.cfg` — all observed, uncommented.

### 2.2 `time.cfg` and `stars.cfg`

| Key | Value | path:line | Label |
|---|---|---|---|
| `year` / `month` / `day` | `2001` / `7` / `1` | `time.cfg:2-4` | observed |
| `hour` / `minute` / `second` | `10` / `0` / `0` | `time.cfg:5-7` | observed (fixed 10:00) |
| `speedfactor` / `normalspeedfactor` | `8` / `10` | `time.cfg:8-9` | observed; meaning inferred |
| `Visible` / `Active` / `Twinkle` | `True` ×3 | `stars.cfg:2-4` | observed |
| `Radius` | `1` | `stars.cfg:5` | observed |
| `MaxStarsCount` | `5000` | `stars.cfg:6` | observed |
| `StartHour` / `EndHour` | `21` / `7` | `stars.cfg:7-8` | observed; visible-window meaning inferred |

`light.ref:110-116` duplicates the date and adds **`DateTimeEnable = False`** (observed) — so the
10:00 sun is static; no day/night cycle (also DEEPDEC-04 T7/T15, TERRAIN2-03 D27).

### 2.3 `lights\light.cfg` — active sun (exact constants)

| Key | Value | path:line | Derived meaning / label |
|---|---|---|---|
| `Ambient.Red/Green/Blue/Alpha` | `0.196078434586525` / `0.184313729405403` / `0.129411771893501` / `1` | `light.cfg:3-6` | ≈50/47/33 per 255 — observed |
| `ConstAttenuation` | `1` | `:8` | observed |
| `Diffuse.Red/Green/Blue/Alpha` | `0.811764717102051` / `0.780392169952393` / `0.694117665290833` / `1` | `:10-13` | ≈207/199/177 per 255 — observed |
| `LinearAttenuation` / `QuadraticAttenuation` | `0` / `0` | `:15-16` | observed |
| `LightStyle` | `lsParallel` | `:17` | directional — observed + inferred |
| `Shining` | `true` | `:18` | observed |
| `Specular.Red/Green/Blue/Alpha` | `0.278431385755539` / `0.266666680574417` / `0.211764708161354` / `1` | `:20-23` | ≈71/68/54 per 255 — observed |
| `SpotCutOff` | `180` | `:25` | full sphere for parallel light — derived |
| `Position.X/Y/Z/W` | `-0.344731152057648` / `0.938701450824738` / `0` / `1` | `:27-30` | observed |
| `SpotDirection.X/Y/Z/W` | `0` / `0` / `-1` / `0` | `:33-36` | observed (unused for parallel) |
| `SpotExponent` | `0` | `:38` | observed |
| `Name` | *(empty)* | `:39` | observed |

Derived Z-up light vector (port already uses this): `water.dev.vert:22` applies
`(x/4, z/2, y)` → **(-0.0861828, 0, 0.9387015)** — derived, verified twice (DEC-03 §4.3,
TERRAIN2-03 §2.1). The port's `SUN_LIGHTVEC` (`world3d_terrain.gd:116`) matches.

### 2.4 `lights\light.ref` — alternative world-scale sun + duplicated sky/weather

| Key | Value | path:line | Label |
|---|---|---|---|
| `lightpatterns[0].LensFlareFile` | `.\data\env\flares\default.cfg` | `light.ref:8` | observed |
| `lights[0].Position` | `(16629.392578125, 11111.4052734375, 0, 1)` | `:12-17` | observed — **world-scale**, not the unit vector |
| `lights[0].SpotDirection` | same components, `W=0` | `:18-23` | observed |
| `lights[0].Ambient` | `(0.549019634723663 ×3, 1)` | `:30-35` | observed |
| `lights[0].Diffuse` | `(0.941176474094391 ×3, 1)` | `:36-41` | observed |
| `lights[0].Specular` | `(0.501960813999176 ×3, 1)` | `:42-47` | observed |
| `LightStyle` / `Shining` / attenuations / `SpotCutOff` | `lsParallel` / `True` / `1,0,0` / `180` | `:26-48` | observed |
| `MainIndex` / `ShadowIndex` / `LensFlareIndex` / `MoonIndex` / `Attached` | `0` / `0` / `-1` / `-1` / `True` | `:51-55` | observed |
| `SkyVisible` / `SkyActive` | `True` / `True` | `:57-58` | observed |
| `SkyUpStartAngle` / `SkyUpStopAngle` | `-5` / `90` | `:59-60` | observed |
| `SkyUpStartColor` / `SkyUpStopColor` | **both `(0,0,0,1)`** | `:61-72` | observed — conflicts with the blue `skydome.cfg` (§9) |
| `SkyUpSlices` / `SkyUpStacks` | `32` / `32` | `:73-74` | observed |
| `SkyUpStartAngleUV` / `SkyUpStopAngleUV` | `256` / `90` | `:75-76` | observed |
| `SkyDownStartAngle` / `SkyDownStopAngle` | `-90` / `-5` | `:77-78` | observed |
| `SkyDownStartColor` / `SkyDownStopColor` | both `(0,0,0,1)` | `:79-90` | observed |
| `SkyDownSlices` / `SkyDownStacks` | `32` / `8` | `:91-92` | observed |
| `SkyDownStartAngleUV` / `SkyDownStopAngleUV` | `270` / `256` | `:93-94` | observed |
| `SkyStarsVisible/Active/Twinkle` | `True` ×3 | `:95-97` | observed |
| `SkyStarsRadius` / `MaxStarsCount` / hours | `1` / `5000` / `21`→`7` | `:98-101` | observed |
| `SkyScaleFactor` | `(1, 0.800000011920929, 1)` | `:102-106` | observed |
| `SkyFocalLength` | `50` | `:107` | observed — **`skydome.cfg:52` says `1`** (unverified precedence) |
| `SkySceneScaleX/Y` | `1` / `1` | `:108-109` | observed |
| Date / `DateTimeEnable` | `2001/7/1 10:00:00` / `False` | `:110-116` | observed |
| `CloudsBlockHorizon` / `Height` / `SpeedFactor` / `FogDensity` | `5000` / `0` / `10` / `0.000920000020414591` | `:117-120` | observed |
| `CloudsBlockVisible` / `Active` | `True` / `True` | `:121-122` | observed |
| `AirActive` | `True` | `:123` | observed |
| `AirWeather` / `AirWeatherTarget` | `40` / `40` | `:124-125` | observed |
| `AirWeatherIntervalTarget` / `WeatherRandom` / random range | `1` / `False` / `0..99` | `:126-129` | observed |
| `AirWindRandom` | `False` | `:130` | observed |
| `AirWindVector` / `Target` | `(-0.742116451263428, 0, -0.867265641689301, 1)` | `:131-142` | observed |
| `AirWindIntervalTarget` | `5482` | `:143` | observed |

`light.presets` defines `light0` (base), `light1` (`DateTimeHour=20`), `light2` and `light3`
(with second `lsSpot` lights at hour 11 and 19) — `light.presets:4-134`, all **alternative**
patterns; no active script selects one (DEEPDEC-04 T12).

### 2.5 `colors\colors.lib` — fog / palette tables (the missing env file)

Schema: `statictables[0..7]`; entries `[1..4]`, `[6]`, `[7]` inherit via
`{refkey=.statictables[N]}`. Full observed table (pass 1 + pass 2 agree):

| # | Name / refkey | SkyHorizon | SkyTop | Fog RGBA | Ambient | LSAmbient | LSDiffuse | LSSpecular | ShadowBlendingDiffuse | FogStart | FogEnd | FogMode | HFogStart | HFogMode | FogDepthFactor | FogBack | FogExpDepthFactor | line |
|---|---|---|---|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---:|---|
| 0 | **default** | `0,0,0,255` | `0,0,0,255` | `60,100,150,1` | `255,255,255,255` | `140,140,140,255` | `240,240,240,255` | `128,128,128,255` | `140,140,140,128` | **390** | **490** | **0** | 200 | 2 | 0.8 | `60,100,150,2` | 0 | `:18-43` |
| 1 | yellow ← `[0]` | inherited | inherited | inherited | `255,200,128,255` | `240,180,140,255` | `255,255,240,255` | inherited | `140,140,220,128` | inherited | inherited | inherited | inherited | inherited | inherited | inherited | inherited | `:45-51` |
| 2 | red ← `[0]` | — | — | — | `255,200,200,255` | `255,128,128,255` | `255,240,240,255` | — | inherited | — | — | — | — | — | — | — | — | `:52-57` |
| 3 | blue ← `[0]` | — | — | — | `200,200,255,255` | `200,200,255,255` | `200,200,255,255` | — | `140,140,180,128` | — | — | — | — | — | — | — | — | `:58-64` |
| 4 | gray ← `[0]` | *(no overrides)* | | | | | | | | | | | | | | | | `:65-67` |
| 5 | **dark** (full) | `0,0,0,255` | `0,0,0,255` | `64,128,255,1` | `200,200,255,255` | `200,200,255,255` | `200,200,255,255` | `128,128,128,255` | `150,150,255,128` | **90** | **490** | **2** | 200 | 2 | 0.8 | `64,128,255,1` | **0.7** | `:68-93` |
| 6 | **winter** ← `[0]` | inherited | inherited | inherited | inherited | inherited | inherited | inherited | **`180,180,200,128`** | inherited | inherited | inherited | inherited | inherited | inherited | inherited | inherited | `:94-97` |
| 7 | **desert** ← `[1]` (yellow) | inherited | inherited | inherited | `255,200,128,255` (via yellow) | `240,180,140,255` (via yellow) | `255,255,240,255` (via yellow) | inherited | **`140,140,180,128`** | inherited | inherited | inherited | inherited | inherited | inherited | inherited | inherited | `:98-101` |

Also observed at `colors.lib:19,21`: the blue sky alternatives `SkyDomeHorizon=0,35,205,255`
and `SkyDomeTop=150,200,250,255` are **commented out**; the active values are black (`:20,:22`).
`CloudFogColor`/`CloudColor`/`CloudFogBackColor` = `48,48,48,255` in both default and dark
(`:25-26,:41` / `:74-75,:90`). Moon Ambient/Diffuse/Specular = `128,128,128,255` in both
(`:30-32` / `:79-81`). `SpaceHeightScale=1` (`:42` / `:91`). `colortable[0..11]` maps to the
12 `.palette` files (`:3-14`).

### 2.6 `skydome\skydome.cfg` and `skydome.mat`

| Key | Value | path:line | Label / meaning |
|---|---|---|---|
| `materiallibrary.loadfromfile` | `.\data\env\skydome\skydome.mat` | `skydome.cfg:2` | observed |
| `libmaterialname` | *(empty)* | `:3` | observed |
| `visible` / `active` | `True` / `True` | `:4-5` | observed |
| `stars.loadfromfile` | `.\data\env\skydome\stars.cfg` | `:6` | observed |
| `upskydomeband.startangle` / `stopangle` | `-5` / `90` | `:8-9` | observed — start = **horizon**, stop = **zenith** |
| `upskydomeband.startcolor` | `(0.600000023841858, 0.776470601558685, 0.992156863212585, 1)` | `:11-14` | observed — **pale HORIZON blue** |
| `upskydomeband.stopcolor` | `(0, 0.141176477074623, 0.807843148708344, 1)` | `:17-20` | observed — **deep ZENITH blue** |
| `upskydomeband.slices` / `stacks` | `32` / `32` | `:22-23` | observed |
| `upskydomeband.startangleuv` / `stopangleuv` | `256` / `90` | `:24-25` | observed; meaning inferred |
| `downskydomeband.startangle` / `stopangle` | `-90` / `-5` | `:28-29` | observed |
| `downskydomeband.startcolor` / `stopcolor` | both `(0.600000023841858, 0.776470601558685, 0.992156863212585, 1)` | `:31-40` | observed — uniform pale lower band |
| `downskydomeband.slices` / `stacks` | `32` / `8` | `:42-43` | observed |
| `downskydomeband.startangleuv` / `stopangleuv` | `270` / `256` | `:44-45` | observed; meaning inferred |
| `ScaleFactor` | `(1, 0.800000011920929, 1)` | `:47-50` | observed — dome flattened in Y |
| `FocalLength` | `1` | `:52` | observed (vs `light.ref:107 = 50` — §9) |
| `SceneScaleX/Y` | `1` / `1` | `:53-54` | observed |
| `CamInvarianceMode` | `cimPosition` | `:55` | observed; dome tracks camera position inferred |

`skydome.mat`: `BlendingMode=bmOpaque` (`:17`), `FaceCulling=fcNoCull` (`:18`),
**`moIgnoreFog=True`, `moNoLighting=True`** (`:20-21`), texture `menu.dds` (`:30`), `tmModulate`
(`:36`) — observed. Sky is deliberately outside fog and lighting.

### 2.7 `clouds\clouds.cfg`, `clouds.weather`, `clouds.presets`, `clouds.mat`

`clouds.cfg` (observed, verified twice):

| Key | Value | path:line |
|---|---|---|
| `visible` / `active` | `True` / `True` | `:2-3` |
| `horizont` / `height` | `5000` / `0` | `:4-5` |
| `fogdensity` | `0.000920000020414591` | `:6` |
| `speedfactor` | `10` | `:7` |
| `materiallibraryinterface.loadfromfile` | `.\data\env\clouds\clouds.mat` | `:8` |
| `cloudscollection.loadfromfile` | `.\data\env\clouds\clouds.presets` | `:9` |
| `cloudscount[0..9]` | `1,5,10,15,20,25,30,30,30,30` | `:11-20` |
| `deltacreatetime[0..9]` | `10` (all ten) | `:23-32` |

`clouds.weather` (observed): `Active=True` (`:2`), `Weather=40` (`:3`), `WeatherTarget=40`
(`:4`), `WeatherIntervalTarget=1` (`:5`), `WeatherRandom=False` (`:6`),
`WindVector=(-0.742116451263428, 0, -0.8672656416893, 1)` (`:7-12`),
`WindVectorTarget` identical (`:13-18`), `WindIntervalTarget=5482` (`:19`), `WindRandom=False`
(`:20`), `weatherrandomstart=0`, `weatherrandomend=99` (`:21-22`) — lowercase keys confirmed in
`clouds.weather`; `light.ref:131-143` carries the same vector at higher precision
(`Z=-0.867265641689301`) with `Air*` key names.

`clouds.presets` — 12 presets, every one `season=2`, `speedfactor=1`, `billboardfactor` as shown:

| Preset | weather band | min/max height | min/max width | min/max upheight | priority | billboardfactor | alphalerpdistance | line |
|---|---|---:|---:|---:|---:|---:|---:|---|
| `soft1` | 10–50 | 300–500 | 300–500 | 100–200 | 50 | 5000 | 1 | `:2-16` |
| `soft2` | 10–50 | 250–500 | 250–500 | 100–200 | 50 | 5000 | 100 | `:20-34` |
| `soft3` | 10–50 | 250–500 | 250–500 | 100–200 | 25 | 5000 | 100 | `:38-52` |
| `volume1` | 50–60 | 250–500 | 250–500 | 10–100 | 1 | 5000 | 100 | `:56-70` |
| `volume2` | 50–60 | 200–400 | 200–400 | 10–100 | 1 | 5000 | 100 | `:74-88` |
| `volume3` | 50–60 | 150–400 | 300–500 | 10–100 | 5 | 5000 | 100 | `:92-106` |
| `dark1` | 60–80 | 400–800 | 400–800 | 10–100 | 1 | 5000 | 100 | `:110-124` |
| `dark2` | 60–80 | 400–800 | 400–800 | 10–100 | 2 | 5000 | 100 | `:128-142` |
| `dark3` | 60–80 | 250–500 | 250–500 | 10–100 | 1 | **3000** | 100 | `:146-160` |
| `storm1` | 70–99 | 400–800 | 400–800 | 10–100 | 3 | **3000** | 100 | `:164-178` |
| `storm2` | 70–99 | 400–800 | 400–800 | 10–100 | 2 | **3000** | 100 | `:182-196` |
| `storm3` | 70–99 | 450–900 | 450–900 | 10–100 | 1 | **3000** | 100 | `:200-214` |

With `Weather=40`, only the **three `soft*` presets** fall inside the active band; the other nine
are configured but not selected — **derived** from `:8-9,:26-27,:44-45` vs `clouds.weather:3`.
The `season=2` field's meaning relative to `GetSeasonType=2` (winter) is **UNVERIFIED**; if it were
a direct season index it would make clouds winter-only, which is implausible — do not encode that
assumption.

`clouds.mat` — 12 materials `soft1-3`, `volume1-3`, `dark1-3`, `storm1-3`, each:
`Image = .\data\env\clouds\textures\<name>.dds`, `ImageAlpha=tiaDefault`, `Disabled=false`,
`TextureMode=tmModulate`, `MagFilter=maLinear`, `MinFilter=miLinearMipmapLinear`,
`Compression=tcHighSpeed`, `BlendingMode=bmTransparency`, `FaceCulling=fcNoCull`,
`MaterialOptions.moNoLighting=1`, `Name=<name>`, `Tag=10/11/12` — observed at
`clouds.mat:2-17,20-37,39-56,58-75,77-94,96-113,115-132,134-151,153-170,172-189,191-208,210-227`.

### 2.8 `pfx\particles.lib` and `pfx\particles.snow.cfg`

`particles.lib`: `Name=snow`, `Visible=True`, `Active=True`, `Width/Height/Depth=1`,
`Position=(1,2,3)`, `AutoOffsetFromCamera=True`,
`ParticleCollectionFileName=.\data\env\pfx\particles.snow.cfg` — `particles.lib:2-14`, observed.

Four snow blocks, identical schema; per-block differences observed (verified twice):

| Block | line | `Height`=`Width` | `Rotation` | `SpiralRotatingRadius` | `SpiralRotatingSpeed` | `Speed` | `Count` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `snow1` | `:2-38` | `0.00150000012945384` (`:4-5`) | `62048.2890625` (`:12`) | `0.100000001490116` (`:14`) | `20` (`:15`) | `0.040999997407198` (`:36`) | `100` (`:37`) |
| `snow2` | `:42-78` | `0.0020000000949949` (`:44-45`) | `66374.140625` (`:52`) | `0.100000061094761` (`:54`) | `15` (`:55`) | `0.0610000006854534` (`:76`) | `100` (`:77`) |
| `snow3` | `:82-118` | `0.00251000002026558` (`:84-85`) | `73513.21875` (`:92`) | `0.100000001490116` (`:94`) | `13` (`:95`) | `0.0800000056624413` (`:116`) | `100` (`:117`) |
| `snow4` | `:122-158` | `0.00300000025890768` (`:124-125`) | `122149.078125` (`:132`) | `0.100000098347664` (`:134`) | `13` (`:135`) | `0.100000001490116` (`:156`) | `200` (`:157`) |

Shared per block (observed): `LibMaterialName=Name`, `AlphaChannel=0.5`, `NoZWrite=True`,
`Mirroru/Mirrorv=False`, `WindInteraction=False`, `WeatherInteraction=False`,
`RotationSpeed=0`, `BillboardType=btBillboard`,
`CreatingCubeStart=(+0.5,+0.5,+0.5)`, `CreatingCubeEnd=(-0.5,-0.5,-0.5)`,
`MoveDirection=(0,-1,0)`, **`WeatherStart=70`, `WeatherEnd=100`**, `MonthStart=1`,
`MonthEnd=12`, `CameraSpeedFactor=0.100000001490116`. With `Weather=40` the snow blocks' band
70–100 is **not reached** — derived; snow art is configured, not active in the default weather.

### 2.9 `flares\default.cfg`

`size=400`, `seed=400`, `squeeze=1`, `numstreaks=4`, `streakwidth=2`, `streakangle=0`,
`numsecs=4`, `resolution=64`, `autoztest=True`, `flareisnotoccluded=True`,
`feGlow/feRing/feRays/feSecondaries=True`, `feStreaks=False`, `dynamic=True`,
**`visible=False`** (`:2-20`). Gradients: glow `(1,1,0.8,0.502)→(1,0.2,0,0)` (`:21-34`),
ring `(0.5,0.2,0,0.1)→(0.5,0.4,0,0.1)` (`:35-48`), streaks `(1,1,1,0.2)→(0.2,0,1,0)`
(`:49-62`), rays `(1,0.8,0.5,0.05)→(0.5,0.2,0,0)` (`:63-76`), secondaries (`:77-…`);
`texturedvisible=True` (`:95`). All observed. **Lens flare is visually inactive by default**;
do not port it as visible (DEEPDEC-04 T15).

### 2.10 Fog crosswalk — four distinct mechanisms (decisive)

| Mechanism | Source | Default value | State | Label |
|---|---|---|---|---|
| **A. Scene/environment fog** | `colors.lib:23,34-36` via `env.cfg:16` | `Fog=(60,100,150,1)`, `FogStart=390`, `FogEnd=490`, `FogMode=0` | Config active; binary writes `GL_FOG_*` in the lighting-enabled frame path (`DEEPDEC-04` B3/B6/B9). **Mode ambiguity below.** | observed (config+binary), mapping UNVERIFIED |
| **B. Cloud-layer fog density** | `clouds.cfg:6`, `light.ref:120` | `0.000920000020414591` | active with clouds | observed |
| **C. Camera `DynFog*`** | `camera.cfg:59-64`, `cameradebug.cfg:59-64`, `camerascreenshot.cfg:61-66` | gameplay/debug `DynFogDepth=False`; screenshot `True`; `Start=0.25`, `End=0.025`, `Density=2.0`, `Power=0.85`, `Offset=0` | parser `sub_7ab704` proven; **no render consumer found**; screenshot loader commented and self-cancelling | observed keys, effect UNVERIFIED |
| **D. Fog-of-war** | `player.script:451-464` → `AddFOWPlayers`/`ClearFOWPlayers` | game state | active as state; shader binding absent from static analysis | observed state, binding UNVERIFIED |

**Mode ambiguity (important correction).** Donor RTTI `TFogMode=(fmLinear,fmExp,fmExp2)` is
**0-based** (`DEEPDEC-04` B8, `0x4c883e`), and the GL writer maps byte 0/1/2 →
`GL_LINEAR/GL_EXP/GL_EXP2` (B3). Therefore `FogMode=0` on the default palette means **LINEAR fog
enabled**, not "off". The shader `fogMode` uniform is **1-based** (`1=LINEAR,2=EXP,3=EXP2`,
`if(fogMode>0)` — `DEC-07 §4.3`, `DEEPDEC-04` T14), so `0` there means off. The `+1` bridge from
`colors.lib` to the shader uniform is **UNVERIFIED**. Consequence: the widely repeated claim
"fog is off by default (`FogMode=0`)" is only true for the shader reading; the fixed-function path
evidence favours LINEAR fog at 390–490 world units. Do not enable port fog unconditionally, but
also do not record "donor fog off by default" as settled — see §9 C4 and §11 Q1.

---

## 3. Season / climate files and the swap chain

### 3.1 `terrain\tiles\terrain.lib` — the season alias table (observed, verified twice)

| Key | Value | path:line |
|---|---|---|
| `Name` / `Default` | `Default` / `Summer` | `:2-3` |
| `TextureScale.X/Y/Z/W` | `1` / `1` / `1` / `1` | `:5-10` |
| `seasons.Summer` | `Summer` | `:12` |
| `seasons.Autumn` | `Summer` | `:13` |
| `seasons.Winter` | `Winter` | `:14` |
| `seasons.Spring` | `Summer` | `:15` |
| `CoverDisabled` | `true` | `:17` |

So **Summer, Autumn and Spring are the same set**; only Winter differs. `resource.lib:15`
(`SeasonSetLibraryFileName`) loads this file — active.

### 3.2 `terrain\tiles\tiles.season` — stub

`TexName=grass1`, `Summer=grass1` (`:2-3`, 70 bytes total, observed). Loaded by
`resource.lib:66`. There is **no Winter/Desert entry**: this file does not implement the swap;
the preset set name in `terrain.lib` does.

### 3.3 `terrain\tiles\terrain.presets` — the two 124-entry sets

| Section | `SetName` | `WaterSet` | `DefaultIndex` | TileBlock lines | path:line |
|---|---|---|---:|---|---|
| Summer | `Summer` | `Summer` | `0` | 124 names `grass1 … desert12, alpha0c` | `:2-4`, blocks `:6-129` |
| Winter | `Winter` | `Winter` | `0` | 124 names `grass1_winter … desert12_winter, alpha0c` | `:134-136`, blocks `:138-261` |

Observed + prior-lane parsed twice (`winter_variant.md` §1.1–1.2). The Winter section is a 1:1
rename with `_winter` appended, **except** `alpha0a/alpha0b/alpha0c` are shared. `tiles.mat`
resolves the 124 aliases to 35 unique textures: 23 `winter*.dds` + all 12 `desert*.dds` reused
unchanged (`desertN_winter → desertN.dds`) — observed in `winter_variant.md §1.2`, not re-parsed
here. `winter18/23/24/26` have no alias. `resource.lib:14` loads this file — active.

### 3.4 `gen\mapcover.cfg` — climatic zones are EMPTY by default (observed)

| Key | Value | path:line |
|---|---|---|
| `ClimaticZones[*].Name` | `Default` | `:4` |
| `HeightTileZones[*].Name` | `HeightZone0` | `:6` |
| `MinHeight` / `MaxHeight` | `0` / `100` | `:7-8` |
| `Tiles[*].Frequency` | `1.0` | `:11` |
| `SummerTileName` / `AutumnTileName` / `WinterTileName` / `SpringTileName` | **all empty** | `:12-15` |
| `PatternCovers` | empty struct | `:19-20` |
| `LocalPresets[*].Name` | `Default` | `:23` |
| `ItemName` / `MapFrequency` / `BorderFrequency` | `0` / `1` / `1` | `:26-28` |
| `OnMap` / `OnBorder` | `True` / `True` | `:29-30` |
| `LightPatterns` | empty struct | `:35-36` |

`resource.lib:70` loads it, but `resource.lib:36-37,42` (`GenClimaticZonesFileName`,
`GenMapObjectsSettingsFileName`, `ZoneTilesFileName`) are **empty** — so climate-zone overrides
are not wired in the shipped resource set. This is a concrete "don't invent a climate system"
finding.

### 3.5 Generator season enum and desert weights

| Key / code | Value | path:line | Label |
|---|---|---|---|
| `map.settings.gen.season` default | `0` | `scripts\lib\map.script:250` | observed, uncommented |
| `gc_MaxSeasonCount` | `3` | `scripts\dmscript.global:237` | observed; **0/1/2** implied, value 1 UNVERIFIED |
| `season : Integer` field | — | `scripts\lib\classes.script:82` | observed |
| winter test | `GetSeasonType=2` | `texturemap.inc:525,605,639,927,950`; `dogenerate.inc:1848,1951,1975,2075`; `onloadfull.inc:70`; `miscext.script:1568,1589,1592,1617` | observed (all donor script lines carry `;` comment prefix — activity UNVERIFIED) |
| desert test | `gMap.settings.gen.season=3` | `dogenerate.inc:4`; `dogenerate.inc:2079`; `onloadfull.inc:74` | observed |
| UI season toggle | `season=2 → _misc_SetSeason(0)` else `_misc_SetSeason(2)` | `miscext2.script:3318-3323` | observed; only 0↔2 |
| `desert_tiles` weights | `d_tls_1=1000` (×2 entries), `d_tls_2=0` (disabled), `d_tls_3=1000` (×2), `d_tls_4=100` | `generator.cfg:1629-1655` | observed |

### 3.6 The two swap functions (observed lines; activity of callers UNVERIFIED)

**`_misc_SetSeason`** — `scripts\lib\miscext.script:1547-1625+`:
1. `SetSeasonType(season)` (`:1549`).
2. In winter, destroy every game object whose basename contains `leaftree` (`:1568-1576`);
   conifer families (`fir`, `spruce`, `pine`, `pinebroken`) survive. Same rule restated in
   `dogenerate.inc:1975-1982`.
3. For non-essential buildings with children, swap child material `detail → detailw` in winter
   and back to `detail` otherwise (`:1578-1599`).
4. Swap alpha mask tiles `alpha0a ↔ alpha0b` (`:1609-1625`).

**`_misc_SetDesert`** — `scripts\lib\miscext.script:1429-1543`, called where `gen.season=3`:
per-cell tile-name remap, e.g. `grass1→sandsea5`, `grass7/grass8→desert6`, `ground1→test16`,
`grass2/test7/test8→desert11`, `rock1→desert2`, `rock7→desert4`, `rock9→test23`,
`alpha0a→alpha0c` (`:1447-1502`); `rock8` with `0.1<h<2.9` and (`h>1.8` or `h<1`) → `desert2`
(`:1504-1505`); height scale `koef=0.8` for dry land (`:1513-1520`); mines get basename suffix
`s` (`minegold→minegolds`, `:1531-1534`); all other env objects except `stones*`/`field` are
destroyed (`:1536-1537`). This is a **data remap, not a palette swap**.

### 3.7 Palette files are identical (new finding, observed)

`env\colors\0.palette` … `11.palette`: 6,576 bytes each, **one distinct SHA-256**
(`13012f3de5bcf68e…`) across all 12; 24 non-empty rows of 68 comma-separated integers (17 RGBA
groups) per file, row 1 = `0,0,0,255, 0,0,0,255, 60,100,150,1, 255,255,255,255, 48,48,48,255, …`.
Therefore selecting colour table 6 (winter) or 7 (desert) does **not** change the `.palette` bytes;
the seasonal lighting difference comes solely from `colors.lib` `statictables[6]/[7]`
(`ShadowBlendingDiffuse` overrides + deserter's yellow inheritance). Verified by full-file hash,
twice conceptually (hash + row compare).

### 3.8 Active-vs-alternative matrix

| Element | Active by default | Alternative / dormant | Evidence | Label |
|---|---|---|---|---|
| Sun light | `light.cfg` unit vector + colours | `light.ref` world-scale sun/brighter colours; `light.presets` light0–3 | `env.cfg:22`, `resource.lib:67`, `dogenerate.inc:2087-2098` (commented selector) | observed config; precedence UNVERIFIED |
| Sky gradient | `skydome.cfg` blue two-band dome | `light.ref:61-94` all-black sky; commented blue values `colors.lib:19,21`; `menu.dds` for menus | `env.cfg:17`, T6/T8 conflict | observed; precedence UNVERIFIED |
| Scene colours/fog | `colors.lib[0] default` | `[1..7]` including dark/winter/desert | `env.cfg:16`; selector calls commented (`dogenerate.inc:2075-2084`, `onloadfull.inc:70-79`) | observed |
| Clouds | `clouds.cfg` + `clouds.weather` `Weather=40` → `soft1-3` only | volume/dark/storm presets (9) | `env.cfg:18-19`, `clouds.presets:8-9` etc. | derived |
| Snow PFX | configured | inactive at `Weather=40` (band 70–100) | `particles.snow.cfg:32-33,72-73,112-113,152-153` | derived |
| Stars | configured (`stars.cfg`) | visible window 21:00–07:00 vs fixed hour 10 / `DateTimeEnable=False` | `stars.cfg:7-8`, `light.ref:113,116` | derived; exact gating UNVERIFIED |
| Lens flare | `visible=False` | gradients/textures present | `flares/default.cfg:20`, `env.cfg:9` | observed |
| Camera DynFog | gameplay/debug `False` | screenshot `True` but loader commented | `camera.cfg:59`, `cameradebug.cfg:59`, `camerascreenshot.cfg:61`, DEEPDEC-04 T12 | observed; effect UNVERIFIED |
| Season | `gen.season=0` / Summer set | Winter=2 (`GetSeasonType=2`), Desert=3; value 1 UNVERIFIED | `map.script:250`, `terrain.lib:12-15` | observed |
| Climate zones | empty `mapcover.cfg`, empty resource filenames | authored zones possible but unwired | `mapcover.cfg:12-15`, `resource.lib:36-37,42` | observed |

---

## 4. Season swap chain — what actually changes

| Step | Summer/Autumn/Spring (default, season 0) | Winter (season 2) | Desert (season 3) |
|---|---|---|---|
| Season alias | `terrain.lib:12,13,15 → Summer` | `:14 → Winter` | not a `terrain.lib` season; `gen.season=3` |
| Terrain set | `terrain.presets:2-130` (`SetName=Summer`, `WaterSet=Summer`) | `:134-263` (`SetName=Winter`, `WaterSet=Winter`); 124 `*_winter` names | Summer names remapped in place by `_misc_SetDesert`; **no separate preset section** |
| Tile art | `grass1..10`, `rock*`, `sandsea1-6`, `desert1-12` | 23 `winter*.dds` + 12 reused `desert*.dds`; `winter18/23/24/26` unused; `winter25` is green grass | 12 `desert*.dds` (4 tonal families), `desert_tiles` weights 1000/0/1000/100 |
| Tile-name mechanism | identity | append `_winter` at `texturemap.inc:525-526,605-606,639-640,927-928,950-951` | `miscext.script:1447-1502` explicit case table |
| Alpha mask tile | `alpha0a` | `alpha0b` (`miscext.script:1609-1625`) | `alpha0a→alpha0c` (`:1501`) |
| Props/materials | `UseableSummerMaterials` (`UseSeasonMaterial=True`) | `UseableWinterMaterials`, suffix **`w`** e.g. `fir1→fir1w` (`grass.prop:36-42`, `fir.prop:33-43`, `leaftree.prop:33-43`, `field.prop:58-76`, `palm.prop:34-44`, `desert1.prop:32-42`) | `desert*` props + `desert` frequency keys in generator patterns |
| Trees | all families | `leaftree` destroyed, conifers survive (`miscext.script:1568-1576`, `dogenerate.inc:1975-1982`) | `desert_frt_*` (palm/drytree/desertstump) pattern families |
| Building child material | `detail` | `detailw` (`miscext.script:1589-1596`) | unchanged |
| Height | unchanged | unchanged | dry land scaled by `koef=0.8` (`miscext.script:1513-1520`) |
| Colour table | 0 (default) | 6 (winter), PHDR 1 (`dogenerate.inc:2075-2077`) | 7 (desert ← yellow), PHDR 0 (`dogenerate.inc:2079-2083`) |
| Palette bytes | 0.palette | 6.palette — **identical bytes** | 7.palette — **identical bytes** |
| Fog | default `Fog=(60,100,150,1)`, start 390, end 490, mode 0 | inherited from default (table 6 refkey `[0]`) | inherited from yellow/default (table 7 refkey `[1]`) |
| Sky/weather | unchanged by season in readable data | unchanged | unchanged |

**Two distinct suffixes — do not conflate:** tile preset aliases append `_winter`
(`terrain.presets:138`), prop materials append `w` (`fir1w`, `field1w`, `plantsatlasw`). The
cloud preset field `season=2` does **not** map cleanly to either (§2.7, UNVERIFIED).

---

## 5. Port comparison (read-only snapshot, 2026-11-25)

> **Volatility note:** `variant3d/scripts/world3d_terrain.gd` is being edited concurrently by
> TRN-GEOM (the brief says light constants are being imported now). Two reads this session placed
> the `light_cols` stats block at lines 1132 and 1149 respectively. Line numbers below are from
> the latest read; re-grep before acting on them.

### 5.1 What the port now has (donor-grounded)

| Port site | Value | Donor source |
|---|---|---|
| `world3d_terrain.gd:115` `SUN_POS` | `(-0.344731152057648, 0.938701450824738, 0)` | `light.cfg:26-29` |
| `:116` `SUN_LIGHTVEC` | `(x/4, z/2, y)` then Z-up→Y-up | `water.dev.vert:22` |
| `:117-119` ambient/diffuse/specular | exact `light.cfg` triples | `light.cfg:3-6,10-13,20-23` |
| `:124-125` `DONOR_SKY_HORIZON/TOP` | `(0.6,0.7764706,0.9921569)` / `(0,0.1411765,0.8078431)` | `skydome.cfg:11-20` |
| `:371-373` shader uniforms | ambient/diffuse/specular bound into `terrain_tileindex.gdshader` | same |
| `:377` `donor_sun_position` | raw `SUN_POS` bound | same |
| `:744-795` environment rig | `WorldEnvironment` + `ProceduralSkyMaterial` + `DirectionalLight3D("DonorSun")` | translated from unwired `heightmap_world3d.gd:114-147` |
| `:768-769` ambient | donor colour, energy 1.10 (port art) | `light.cfg:3-6` |
| `:781-782` sun | donor diffuse colour, energy 1.7 (port art) | `light.cfg:10-13` |
| `terrain_tileindex.gdshader:195-206,426-435` | fog modes 1/2/3 implemented; `fog_mode=0`, `fog_color=(60,100,150)/255` | `colors.lib:23,36`; `hf.pvl.smx3.frag:34-46` |

### 5.2 Port season settings

| Port site | Current value | Donor truth |
|---|---|---|
| `variant3d/scripts/data.gd:199` | `BIOME := "summer"` | default `gen.season=0` (`map.script:250`) ✓ |
| `data.gd:219-225` | `TERRAIN_TINT` = summer `(1,1,1)`, winter `(0.86,0.91,1.0)`, desert `(1.0,0.90,0.70)`; `terrain_tint()` returns a flat colour | donor winter/desert are **tile-set swaps + lighting table**, not a tint |
| `variant3d/scripts/config.gd:82` | `"season": "summer"` default | ✓ |
| `config.gd:430` | `Data.BIOME = text("gameplay.season", text("gameplay.biome","summer"))` | string-only; never maps to 0/2/3 or `GetSeasonType` |
| `world3d_terrain.gd` | no `winter`/`desert` literal in the 3D terrain path; atlas contract cites `presets_summer.json` only (`:208`, `:863`) | donor has two 124-entry preset sets |
| `variant3d/assets/terrain/structs/presets_summer.json` | 124 Summer names incl. `desert1..12` at `:113-124`; no `presets_winter.json` | donor Winter section at `terrain.presets:134-263` |
| `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | desert1..12 packed as indices **111–122** (`:2710-2987`); `unused_shipped_blocks` lists all 27 `winterN.png` with note "intentionally not packed" (`:3019-3048`) | answers DTRN-01 Q6: Desert art reachable, Winter art not packed |
| `world3d_fog.gd` | per-tile fog-of-war overlay | donor FOW state is real but shader binding UNVERIFIED (DEEPDEC-04 B12/T16) |

### 5.3 Port gap ranking — exact missing/wrong values, by visual impact

| Rank | Gap | Missing/wrong donor value | Port evidence | Donor evidence | Label |
|---:|---|---|---|---|---|
| 1 | **No winter set swap** | Winter 124 `*_winter` names, `WaterSet=Winter`, `alpha0a→alpha0b`, `detail→detailw`, `leaftree` deletion, colour table 6, `koef` height | flat tint `Color(0.86,0.91,1.0)` (`data.gd:221`); no preset_winter.json; 27 winter PNGs marked unused (`manifest:3019-3048`) | `terrain.lib:14`, `terrain.presets:134-263`, `miscext.script:1568-1625`, `dogenerate.inc:2075-2077` | **observed** both sides |
| 2 | **No desert set swap** | `desert_tiles` weights 1000/0/1000/100; `_misc_SetDesert` remap table; colour table 7 (yellow inheritance); `koef=0.8` remap; height 0.8 | desert art packed at atlas 111–122 but no `BIOME` branch emits `desertN`; flat `Color(1,0.90,0.70)` (`data.gd:222`) | `generator.cfg:1629-1655`, `miscext.script:1429-1543`, `colors.lib:98-101` | **observed** both sides |
| 3 | **No clouds / weather layer** | `horizont=5000`, `height=0`, `fogdensity=0.00092`, `speedfactor=10`, `Weather=40`→`soft1-3`, `billboardfactor=5000`, `alphalerpdistance=1/100`, wind `(-0.74211645,0,-0.86726564)` | nothing in `world3d_terrain.gd` | `clouds.cfg:2-32`, `clouds.weather:2-22`, `clouds.presets:2-52` | **observed** donor, absent port |
| 4 | **Sky is a 2-colour gradient approximation** | 32×32 up band −5..90°, 32×8 down band −90..−5°, `ScaleFactor=(1,0.8,1)`, `FocalLength=1`, `cimPosition`, unlit/unfogged material | exact colours imported, but `ProceduralSkyMaterial` with `sky_curve=0.18`, `ground_curve=0.10`, `background_color=(0.62,0.70,0.66)`, `EXPOSURE=1.45` are port-tuned (`:747,753,757-760,127`) | `skydome.cfg:8-55`, `skydome.mat:17-36` | observed + **PORT APPROX** |
| 5 | **Scene fog unresolved / inert** | `Fog=(60,100,150,1)`, `FogStart=390`, `FogEnd=490`, `FogMode=0` (LINEAR per RTTI); dark palette `Fog=(64,128,255,1)`, start 90, mode 2 | shader implements modes 1/2/3 but `fog_mode=0`, `fog_density=0`, `fog_end=0`, `fog_scale=0` (`terrain_tileindex.gdshader:195-203; world3d_terrain.gd:384`) — flipping the flag alone would do nothing useful | `colors.lib:23,34-43,72,83-92`; DECOMP binary B3/B6 | observed; mode mapping **UNVERIFIED** |
| 6 | **Star field absent** | `Visible/Active/Twinkle=True`, `Radius=1`, `MaxStarsCount=5000`, 21:00–07:00 | no star rig | `stars.cfg:2-8` | observed donor, absent port |
| 7 | **Lens flare / moon absent (correct for default)** | `visible=False`; flare orbit 20000, moon 23:00–07:00 | absent | `flares/default.cfg:20`, `env.cfg:4-14` | observed; **do not add as visible** |
| 8 | **Snow PFX absent (correct for default weather)** | `WeatherStart/End=70..100` vs active `Weather=40` | no particle rig | `particles.snow.cfg:32-33` etc., `clouds.weather:3` | derived |
| 9 | **Sun rig energies are port art** | donor has no "energy" scalar; `light.cfg` colours are imported | `AMBIENT_ENERGY=1.10`, `SUN_ENERGY=1.7`, `EXPOSURE=1.45` (`:127-129`); `shadow_enabled=false` (`:790`, explicit user decision) | `light.cfg:3-23` | observed + labelled port art |
| 10 | **Fog-of-war vs atmosphere still separate** | donor FOW state active; atmosphere fog separate | `world3d_fog.gd` overlay retained; no atmospheric layer | `player.script:451-464`, DEEPDEC-04 B12 | observed; do not conflate |

**Not a gap (do not "fix"):** `lensflaretextured=false` + `visible=False`, day/night cycle, rain,
`light.ref` black sky precedence, and `DynFog*` — all inactive or UNVERIFIED in the donor.
Adding them would invent behaviour.

---

## 6. Corrections to prior docs

**C1 — DEC-03 §4.4 sky band labels are inverted (values correct).** DEC-03 line 231 calls
`upskydomeband.startcolor` "pale zenith blue" and line 232 calls `stopcolor` "saturated blue at
horizon". The angles are `startangle=-5` and `stopangle=90` (`skydome.cfg:8-9`), so `startcolor`
is at the **horizon** and `stopcolor` at the **zenith**. The port constants
`DONOR_SKY_HORIZON=(0.6,0.776,0.992)` / `DONOR_SKY_TOP=(0,0.141,0.808)` use the correct mapping.
**Correction:** swap the semantic labels in DEC-03; do not swap the numbers.

**C2 — DEC-03 §4.2 "no fog key exists in env.cfg" is true but incomplete.** It names only cloud
`fogdensity` and camera `DynFog*`. The **active scene fog** is in `colors.lib:23,34-43`, loaded by
`env.cfg:16`, and is not in DEC-03's 77-file `.cfg/.ini` inventory (`.lib` files excluded).
This report adds the full table (§2.5).

**C3 — DEC-03 §4.4 snow `SpiralRotatingRadius≈0.1` hides four distinct literals.**
`:14=0.100000001490116`, `:54=0.100000061094761`, `:94=0.100000001490116`,
`:134=0.100000098347664` — observed, verified twice.

**C4 — DTRN-01 C20 / TERRAIN2-03 "fog off by default (`FogMode=0`)" is only the shader reading.**
Donor `TFogMode` is 0-based (`fmLinear=0`) and the GL writer maps 0→`GL_LINEAR` (DEEPDEC-04 B3/B8),
so the fixed-function path has LINEAR fog active at `FogStart=390`/`FogEnd=490`. The shader
`fogMode` is 1-based and 0 means off; the bridge is UNVERIFIED. Keep port `fog_mode=0` for now,
but record the conflict instead of asserting donor fog is off (see §2.10).

**C5 — DEC-07 §3.3 "DynFogDepth=True — depth fog on (screenshot/cinematic)" overstates.**
`camerascreenshot.cfg:61` really is `True`, but its loader at `docreate.inc:301-302` is commented
and `:315-320` would force `False` with different numbers (DEEPDEC-04 T12/finding 4). Correct
wording: "config value True, dormant; no render consumer proven". Also `DynFogStart=0.25` >
`DynFogEnd=0.025` and these are not the same units as scene `FogStart=390`/`FogEnd=490` —
DEC-07 §3.1 lists them without that warning.

**C6 — TERRAIN2-03 D22 and DEEPDEC-04 T8 are numerically correct; no change.** Both list the
blue `skydome.cfg` bands accurately. The black `light.ref` duplicate (T6) and `FocalLength`
conflict (1 vs 50) remain UNVERIFIED, as those docs already say.

**C7 — Port citation drift.** `world3d_terrain.gd:117-118` cite `light.cfg:3-8` for ambient and
`light.cfg:11-16` for diffuse; the actual structs are `:3-6` and `:10-13` (observed twice).
Low impact, but citations should match the donor lines.

**C8 — Palette selection is not a colour difference.** All 12 `.palette` files are byte-identical
(§3.7). Any future "winter palette" work must edit `colors.lib` statictables, not `6.palette`.

**C9 — DTRN-01 Q6 answered.** The 3D atlas *does* pack `desert1..12` (indices 111–122), and
explicitly lists all 27 `winterN.png` as `unused_shipped_blocks`
(`tile_index_atlas.manifest.json:3019-3048`). DTRN-01's "check current 3D atlas contents" is
resolved: Desert art reachable, Winter art not.

---

## 7. Open questions (do not guess)

1. **Does `colors.lib FogMode=0` drive the shader `fogMode` (+1 bridge) or only fixed-function GL?**
   Binary proves the GL mapping; no static binding to the shader uniform was found. Until resolved,
   keep port fog off but do not claim "donor fog off".
2. **Sky precedence:** `skydome.cfg` blue dome (active via `env.cfg:17`) vs `light.ref` black sky
   fields (`:61-94`); also `FocalLength=1` vs `50`. UNVERIFIED.
3. **Sun precedence:** `light.cfg` unit vector vs `light.ref:12-47` world-scale brighter light.
   No active pattern selector. UNVERIFIED.
4. **What does `season=2` on all 12 cloud presets mean?** If it is `GetSeasonType`, clouds would be
   winter-only — implausible. Do not encode it.
5. **What is season value `1`?** Observed: 0 (default), 2 (winter), 3 (desert);
   `gc_MaxSeasonCount=3` implies 0/1/2, so 1 is likely an alias-only season. UNVERIFIED.
6. **Do the `;`-prefixed swap scripts execute in the shipped build?** All `texturemap.inc`,
   `dogenerate.inc`, `onloadfull.inc` season lines carry the donor comment prefix. The literal
   values are observed; runtime activity is UNVERIFIED (same caveat as DTRN-01 Q9).
7. **Palette file semantics:** 24 rows × 17 RGBA — likely time-of-day colour ramps, but no
   consumer was decoded; UNVERIFIED. Their identity across all 12 slots is observed.
8. **`HFogStart=200`/`HFogMode=2`/`FogDepthFactor=0.8`/`FogExpDepthFactor=0.7` equations** are
   not readable; keys and values observed, meaning UNVERIFIED (DEEPDEC-04 §4).
9. **Cloud/sky/flare texture appearance** — `.dds`/`.tga` pixel payloads were not decoded; only
   config references and sizes are observed.
10. **Port line numbers** — `world3d_terrain.gd` is being edited concurrently; re-verify before
    any follow-up edit.

---

## 8. Summary

The donor's world environment is a **static, configuration-driven rig**, not a dynamic day/night
system: a fixed 10:00 clock (`time.cfg:5`), `DateTimeEnable=False` (`light.ref:116`), one active
parallel sun (`light.cfg:3-36`), one two-band unlit/unfogged sky gradient (`skydome.cfg:8-55`),
and a `Weather=40` cloud state that selects only the three `soft*` presets out of twelve
(`clouds.weather:3`; `clouds.presets:8-9,26-27,44-45`). Snow particles, lens flare and camera
`DynFog` are configured but not active in the default state. Fog exists in four distinct forms —
scene/fixed-function, cloud density, camera parser-only, and fog-of-war — and the default
`FogMode=0` means LINEAR in the donor's 0-based enum, not necessarily "off" (§2.10).

The season system is a **set swap**, not a tint: `terrain.lib:12-15` aliases Summer/Autumn/Spring
to one set and Winter to another; `terrain.presets` holds two 124-entry tables;Winter appends
`_winter` to tile names while props append `w` to material names; desert is a separate
`gen.season=3` path that remaps tile names in place and scales dry height by 0.8. The
`colors.lib` winter/desert tables override only `ShadowBlendingDiffuse`, and all 12 `.palette`
files are byte-identical.

The port has already imported the exact `light.cfg` colours and `skydome.cfg` band colours, and
`fog_mode=0` is correct as a safe default — but the **three highest-impact remaining gaps are the
winter set swap, the desert set swap and the entire cloud/weather layer**. The sky is a documented
two-colour approximation, and atmospheric fog is implemented in the shader but inert because
`fog_end/fog_scale/fog_density` are 0. No code was changed; this report is the sole output.

*End of DENV-01. One report written; no donor binary copied/executed; no Godot job; no code,
asset, config, test or git state changed. Visual parity not claimed.*
