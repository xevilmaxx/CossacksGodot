---
id: TERRAIN2-03
scope: "Donor WATER / WEATHER / FOG / SKY-CLOUDS versus variant3d flat water quad + per-tile fog overlay; app 2D animated water shader as reference"
date: 2026-11-24
status: AUDIT ONLY — read-only donor research; no source/asset/config/test/git edits; no binary copy
owner: TERRAIN2-03
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use)"
method_note: "Every claim carries donor path:line or port path:line. OBSERVATION = text read directly; INFERENCE = reasoned from that text; UNVERIFIED = engine/binary binding or ambiguous data. Prior evidence reports (WATER_REPORT.md, RENDER_ARCH_SHADERS.md, G31, V71) cited only as secondary pointers, never as a substitute for a donor read."
---

# TERRAIN2-03 — Donor water, weather, fog and sky vs our 3D water quad

## 0. Method and scope guards

- Donor text/config files read read-only; image **headers** read as bytes (dimensions only). No donor binary was run, disassembled or copied. No donor `.bmp`/`.tga`/`.dds` payload was imported into the port by this agent.
- "E19/E20" in this report are the **shader evidence IDs** in `docs/audit/RENDER_ARCH_SHADERS.md:150-151` (view-space fog math, view-space fog depth), as cited by `V71_mechanics_inventory.md:166`. They are **not** the unrelated `main.gd` journey-camera E19 (`V775_pick_caller.md:155-165`). Two distinct lineages share the label; do not merge them.
- Per charter (`TERRAIN2_CHARTER.md:6-14`), no visual-parity claim is made. Any parity statement needs a GPU A/B capture, which this audit does not perform.

---

## 1. Evidence table

Legend: **OBS** = direct text/header read; **INF** = inference from cited text; **UNV** = unverified.

| # | Area | Donor path:line (or port path:line) | What it establishes | Class |
|---|---|---|---|---|
| D1 | Active water shaders | `data\water\water.lib:67-68` | `VertexProgramFileName = .\data\shaders\water\water.dev.vert`, `FragmentProgramFileName = ...water.dev.frag` — the shipped pair is `water.dev.*`, not `water.vert/.frag` | OBS |
| D2 | Water shader binding | `data\water\water.lib:60-61` | `HeightMapEnable = True`, `ShadowMapEnable = True` | OBS |
| D3 | Water wave textures | `data\water\water.mat:7,11,13,15` | `diffusewaves0.bmp`, `TextureFormat = tfLuminance`, `twBoth`, material `DiffuseWaves0` | OBS |
| D4 | Other wave sheets inactive | `data\water\water.mat:26,35,37` | `diffusewaves1.bmp` is commented out; `diffusewaves2.bmp` / `DiffuseWaves2` is active as the second library material (it is **not** the `waveMap` the shader samples — see D5/D9) | OBS |
| D5 | Normal-map asset inactive | `data\water\water.mat:86-106` (`96`, `100`); `data\water\water.lib:43-45` | `heightmapwaves0.tga` declared `tfNormalMap` / `HeightMapWaves0` but the whole section is commented; `water.lib:43-44` selects `DiffuseWaves2` (normal-map slot) and `DiffuseWaves0` (diffuse slot), `:45` `HeightMapWaves0` commented out | OBS |
| D6 | Texture dimensions (headers) | `data\water\textures\diffusewaves0.bmp` (BMP header @18/22/28), `diffusewaves1.bmp`, `diffusewaves2.bmp`, `heightmapwaves0.tga` (TGA header @12/14/2/16) | 256×256×24bpp; 256×256×24bpp; 512×512×24bpp; 256×256×32bpp RLE (imgType=10) respectively. Loaded as luminance per D3 for the sampled sheet | OBS |
| D7 | Water tex scales | `data\water\water.lib:32-33` | `TexScaleS = 0.1`, `TexScaleT = 0.01` (the `:30-31` `0.115/0.015` values are commented) | OBS |
| D8 | Water library constants | `data\water\water.lib:5-13,21-29,42,49-50,56` | MaxDepth=1, MinDepth=0, MaxAlpha=1.1, DeepColor=(0,0,0.1255,0.5), ShallowColor=(0,0,0,0.5), ReflectionAmount=1, WaterAmount=1, FresnelPower=1, FresnelBias=1, HDRMultiplier=1, WaveFreq=0, WaveAmp=0, DistFactor=1, BumpFactor=1, Speed=1, Offset=0.495, LayerCount=1, CustomTexCoord=True | OBS |
| D9 | Vertex stage is flat-plane passthrough | `data\shaders\water\water.dev.vert:14-18,20-22,29` | `pos=gl_Vertex`; `TexCoord[0]=TextureMatrix[0]*pos` (projected reflection coord); `TexCoord[1].xy` from `MultiTexCoord0/hmapW,hmapH - 0.5`; **`TexCoord[1].z = pos.y`** (water-plane height carried per vertex); shadow coord; `eyeVector=pos.xyz-eyePosition.xyz`; `lightVector=(L.x/4,L.z/2,L.y)`; `gl_Position=ftransform()`. No vertex displacement | OBS |
| D10 | Water height source | `data\shaders\water\water.dev.frag:18-21,70-75` | `hmapTex`, `hmapMin`, `hmapMax`, `hmapW`; `height_map()` samples `texture2D(hmapTex,p).w` and decodes `hmapMin + w*(hmapMax-hmapMin)` | OBS |
| D11 | Water plane height in fragment | `water.dev.frag:167-175` | `WATER_LEVEL = gl_TexCoord[1].z` (from vertex Y, D9); `deepwater_fadedepth = 0.5 + 0.57 = 1.07`; `waveheight = clamp(WATER_LEVEL*3 - 1.5, 0, 1)`; `level = WATER_LEVEL + 0.2*water_map(...)` | OBS |
| D12 | Shoreline / alpha | `water.dev.frag:176-183,198-201,229-232` | Land (`height > level`) → `vec4(0.0)` (discard-equivalent); `coastfade = clamp((level-height)/0.57,0,1)`; `coastfade2 = clamp((level-height)/1.07,0,1)`; depth tint `mix(watercolor*intensity, watercolor2, smoothstep(0,1,coastfade2))`; `resalpha = coastfade2` (alpha 0 at shoreline, 1 at 1.07 m) | OBS |
| D13 | Wave algorithm | `water.dev.frag:37-47,83-104` | Constants `coast2water_fadedepth=0.57`, `large_waveheight=0.5`, `large_wavesize=2`, `small_waveheight=0.5`, `small_wavesize=0.5`, `water_softlight_fact=170`, `water_glossylight_fact=120`, `particle_amount=30`, `watercolor=(0.1,0.24,0.24)`, `watercolor2=(0,0.025,0.05)`, `water_specularcolor=(0.4,0.4,0.4)`; `m=mat2(0.72,-1.60,1.60,0.72)`; `water_map()` = 3-octave fBm + crossing sine swell + 9-octave ridged loop, time-shifted | OBS |
| D14 | Noise sampler | `water.dev.frag:5,65-68` | `waveMap` is the **only** noise sampler: `noise(p) = texture2D(waveMap, p*(1./256.)).x`; 256² matches `diffusewaves0.bmp` (D6) | OBS + INF |
| D15 | Finite-difference normals and reflection | `water.dev.frag:186-194,207-213` | Four `water_map` taps → `normwater`, `wavejitter = normwater.xy*texScaleT*(level-height)`; `refuv = gl_TexCoord[0].xyw; refuv.xy -= wavejitter*refuv.z; refcol=texture2DProj(reflectionMap,refuv); refcol *= sum(rgb)*hdrMultiplier; watercolor += refcol.xyz` | OBS |
| D16 | Specular / foam / shadow | `water.dev.frag:106-127,129-143,215-227` | `nautic()`/`particles()` procedural foam; 3-tap PCF `shadow2DProj`; soft/glossy `pow(grad,170/120)`, corona divisor `1+specular1*1.25`, foam band `coastfade*(1-coastfade2)` | OBS |
| D17 | Water fog path | `water.dev.frag:10,23,237-261` | `fogFragCoord` varying; `fogEnabled` uniform; `fogmap()` implements mode 1 LINEAR, 2 EXP, 3 EXP2 with `1.442695`; applied to water colour in `main()` | OBS |
| D18 | Legacy water pair | `data\shaders\water\water.frag:55-78,135-158,177-238`; `water.vert:21-26` | Debug/prototype: hard-coded `WATER_LEVEL=1.5`, procedural `height_map()`, `test_shadow()` returns 1, no reflection/fog; **not** the shipped pair (D1). Secondary: `docs/audit/RENDER_ARCH_SHADERS.md:39,72,323` | OBS |
| D19 | Donor water thresholds | `data\scripts\common.inc\texturemap.inc:14,27,29-31,66-87` | `cBWater=1`, `cBColorWater=255`, `cMaxHeight=2.96`, **`cWaterHeight=-0.25`**, **`cWaterShoreHeight=-0.1`**; cells below these get `gc_collisiontag_water`. Lines carry the script comment prefix `;` so *active use* is unproven (see UNV-4) | OBS (literal), UNV (active use) |
| D20 | Sun / palette | `data\env\lights\light.cfg:3-6,9-13,17,19-23,25,26-30` | Ambient (0.196,0.184,0.129), Diffuse (0.812,0.780,0.694), Specular (0.278,0.267,0.212), `lsParallel`, `SpotCutOff=180`, Position (-0.3447,0.9387,0,1) | OBS |
| D21 | Env loader chain | `data\env\env.cfg:15-22` | `time.cfg`, `colors.lib`, `skydome.cfg`, `clouds.weather`, `clouds.cfg`, `flares/default.cfg`, `lights/light.cfg`, PFX | OBS |
| D22 | Skydome geometry/colours | `data\env\skydome\skydome.cfg:6-26,27-46,47-55` | Up band angle −5..90°, start (0.6,0.776,0.992) → stop (0,0.141,0.808), 32 slices × 32 stacks, UV angle 256→90; down band −90..−5°, constant start/stop (0.6,0.776,0.992), 32×8, UV 270→256; `ScaleFactor=(1,0.8,1)`, `CamInvarianceMode=cimPosition` | OBS |
| D23 | Skydome material flags | `data\env\skydome\skydome.mat:20-22,30,36` | `moIgnoreFog=True`, `moNoLighting=True`, `menu.dds`, `tmModulate` — sky is unlit/unfogged gradient | OBS |
| D24 | Clouds draw mode | `data\env\clouds\clouds.mat:3-17,20-37,58-75,115-132,172-189`; `clouds.cfg:2-9` | Twelve cloud materials `soft1-3`, `volume1-3`, `dark1-3`, `storm1-3` from `clouds/textures/*.dds`, all `bmTransparency`, `fcNoCull`, `moNoLighting=1`; `horizont=5000`, `height=0`, `fogdensity=0.00092`, `speedfactor=10` | OBS |
| D25 | Cloud presets / weather bands | `data\env\clouds\clouds.presets:2-17,55-71,109-125,163-179` | Each preset carries min/max height, width, `minweather`/`maxweather` (soft 10–50, volume 50–60, dark 60–80, storm 70–99), `billboardfactor=3000..5000`, `alphalerpdistance=1..100`, `season=2`; `clouds.cfg:10-33` count/delay ladders | OBS |
| D26 | Weather state + wind | `data\env\clouds\clouds.weather:2-12`; `light.ref:124-127` | `Active=True`, `Weather=40`, `WeatherTarget=40`, `WeatherRandom=False`; WindVector (−0.7421,0,−0.8673) | OBS |
| D27 | Static time / no day-night | `data\env\time.cfg:2-9`; `data\env\lights\light.ref:110-116`; `data\env\flares\default.cfg:20` | Hour 10, speed 8; **`DateTimeEnable=False`**; lens flare `visible=False`. Secondary: `V71_mechanics_inventory.md:165` (`init.script:99 SetDateTimeManagerEnabled(false)`) | OBS |
| D28 | **Fog depth: gameplay** | `data\cameras\camera.cfg:51-64` (`59`) | **`DynFogDepth = False`**; other DynFog keys present: Start 0.25, End 0.025, Density 2.0, Power 0.85, Offset 0; DOF 128/256 | OBS |
| D29 | **Fog depth: debug** | `data\cameras\cameradebug.cfg:57-62` | `DynFogDepth = False` (same values) | OBS |
| D30 | **Fog depth: screenshot/cinematic** | `data\cameras\camerascreenshot.cfg:53-66` (`61`) | **`DynFogDepth = True`** — same DynFog numbers, flag flipped on | OBS |
| D31 | Donor fog math | `data\shaders\obj\pvl.smx3.id0.frag:29-43`; `data\shaders\obj\def.pvl.sm.vert:37-42`; `shaders.lib:4-13,17-27` | `fogMode>0`: LINEAR `clamp((end-w)*scale,0,1)`, EXP `exp2(-density*w*1.442695)`, EXP2 `exp2(-pow(density*w,2)*1.442695)`, `mix(gl_Fog.color, color, fog)`; `w = abs(realpos.z)` (ATI) else `length(realpos)`; `fogMode` is a registered shader capability flag | OBS |
| P1 | 3D water quad | `variant3d/scripts/world3d_terrain.gd:17,52,175-202` | One flat 4-vertex quad at `WATER_LEVEL=-0.25`, full map extent; `StandardMaterial3D` albedo (0.19,0.245,0.255,0.45), alpha transparency, roughness 0.35, cull disabled; UV 0..1; **no wave sampler, no depth, no reflection, no foam, no fog** | OBS |
| P2 | 3D water level provenance | `variant3d/scripts/world3d_terrain.gd:30-31,52,379` | Port comment says "donor literal UNVERIFIED" while citing `texturemap.inc:30` — the literal is in fact readable there (D19), though the script line is commented | OBS |
| P3 | 3D fog overlay | `variant3d/scripts/world3d_fog.gd:3-4,19-31,38-44,147-165,168-215` | Per-tile fog-**of-war** quads, alpha ladder 0.78/0.30/0.00 (port state encoding), `FOG_Y_OFFSET=0.03`, spatial shader only passes `COLOR` through. Explicitly **not** donor view-depth fog; donor binding to `fog_explored`/`fog_vis` is UNVERIFIED | OBS |
| P4 | 3D sky rig | `variant3d/scripts/world3d_terrain.gd:205-243` (`211-223`) | `ProceduralSkyMaterial` with port-tuned colours (top 0.18/0.30/0.42, horizon 0.36/0.44/0.38, ground 0.09/0.12/0.07), no clouds, environment colours not taken from `skydome.cfg`; sun from `light.cfg` via `water.dev.vert:22` transform | OBS |
| P5 | 2D animated water | `app/scripts/world.gd:83,86-87,97,923-925,945-1010,2085`; `app/shaders/water_overlay.gdshader:1-2,39,50-68,102-139,142-174,176-278` | A `canvas_item` shader transcribing donor equations: one `wave_noise` (= `diffusewaves0.png`), donor constants (0.57, 1.07, 0.1, 0.01, 170, 120, 30, colours), per-tile depth mask in R/G/B, procedural `nautic()`/`particles()` foam, alpha = coverage*coastfade2. `water_level=1.0` at `world.gd:968` is a **port choice**, not donor | OBS |
| P6 | 3D shader copy unused | `variant3d/shaders/water_overlay.gdshader:1-2` | A `canvas_item` copy exists in the 3D project but the quad at P1 uses `StandardMaterial3D`, so it is not wired to the 3D water surface | OBS |

---

## 2. Donor recipe

### 2.1 Water surface — how it is actually built

**OBSERVATION.** The shipped water is a **flat plane with a per-pixel depth-aware fragment shader**, not a displaced wave mesh and not a per-tile sprite:

1. `water.lib:67-68` selects `water.dev.vert` + `water.dev.frag`.
2. `water.dev.vert:14-18,29` passes vertices straight through (`ftransform()`), deriving a projected-reflection texcoord and a heightmap UV from `MultiTexCoord0`, and stores the plane height in `TexCoord[1].z = pos.y`.
3. `water.dev.frag:167-175` reads that height back as `WATER_LEVEL`, decodes terrain height from `hmapTex`, and perturbs the water level with `0.2*water_map(...)`.
4. `water.dev.frag:176-183` discards fragments where terrain is above water (`vec4(0.0)`); `:198-201,229-230` fades shallow→deep colour and alpha over `0.57 m` / `1.07 m`.
5. `water.dev.frag:85-104` synthesises waves procedurally from one luminance noise sheet; `:186-194` derives normals by four finite differences of that same function.
6. `water.dev.frag:207-213` projects a **reflection render target** with wave jitter and adds it with an HDR multiplier; `:215-227` adds sun glints, shadow and procedural foam.

**INFERENCE.** Because no water mesh asset is referenced by `water.lib`/`water.mat` and the vertex stage does no displacement, the geometry is a world-aligned flat plane (one or a few large quads) whose *appearance* comes entirely from the fragment stage. This is directly relevant to the port: our 3D quad's **shape is structurally correct**; the missing part is the shading.

**Textures and parameters actually driving shipped water:**

| Role | Donor source | Notes |
|---|---|---|
| Noise / wave field | `diffusewaves0.bmp`, 256²/24bpp (`water.mat:7`; header @18/22/28), sampled as `tfLuminance` (`water.mat:11`) | Only sampler in `water.dev.frag:5,65-68` |
| Terrain height | `hmapTex` + `hmapMin/hmapMax/hmapW` (`water.dev.frag:18-21,70-75`) | Engine-supplied; see UNV-1 |
| Reflection | `reflectionMap` (`water.dev.frag:6,207-213`) | Projected FBO; binding engine-side, UNV-2 |
| Shadow | `sampler2DShadow shadowMap`, `shadowed`, `shadowSize`, `shadowColor` (`water.dev.frag:25-28,129-143`) | `ShadowMapEnable=True` (`water.lib:61`) |
| Scales / colours / glints | `water.lib:32-33,5-13`; `water.dev.frag:37-47` | See D7, D8, D13 |
| Sun direction | `light.cfg:26-30` → `water.dev.vert:22` transform `(x/4, z/2, y)` | ⇒ donor vector (−0.08618, 0, 0.93870) Z-up |

**Not used by shipped water** (important for asset reuse): `diffusewaves1.bmp` is commented at `water.mat:26`; `diffusewaves2.bmp` is a live *library material* (`water.mat:35-37`, selected into the normal-map slot at `water.lib:43`) but the shipped fragment shader has only `waveMap`, `reflectionMap`, `hmapTex` (`water.dev.frag:5-6,18`); `heightmapwaves0.tga` (256², 32bpp RLE) is declared only in the commented `HeightMapWaves0` section (`water.mat:86-106`) and commented at `water.lib:45`. Do **not** bind `heightmapwaves0.tga` as `hmapTex` (see UNV-1; `G31_donor_3d_truth.md:106-109`).

**Foam / shoreline.** There is no foam texture asset in `data\water\textures`: foam is `nautic()` and `particles()` procedural noise (`water.dev.frag:106-127`) gated by the shallow band `coastfade*(1-coastfade2)` (`:227`). The shoreline itself is a *height-contour* fade via `level-height` (`:198-201`), not a tile mask.

### 2.2 Sky and clouds

- **Sky:** a two-band gradient dome, built from angles and colours rather than a panoramic texture: up band −5..90° with start (0.6, 0.776, 0.992) → stop (0, 0.141, 0.808) at 32×32 slices/stacks; down band −90..−5° constant (0.6,0.776,0.992) at 32×8 (`skydome.cfg:7-46`). `ScaleFactor=(1,0.8,1)` and `CamInvarianceMode=cimPosition` (`skydome.cfg:47-55`). Material flags `moIgnoreFog=True`, `moNoLighting=True` (`skydome.mat:20-22`) — the sky is deliberately outside fog and lighting. A `menu.dds` texture exists for the menu variant (`skydome.mat:30`).
- **Clouds:** twelve unlit transparent billboard materials (`clouds.mat:3-228`) — `soft1-3`, `volume1-3`, `dark1-3`, `storm1-3` — spawned by weather-band presets (`clouds.presets:2-215`: soft 10–50, volume 50–60, dark 60–80, storm 70–99) on a horizontal plane at `horizont=5000`, `height=0` (`clouds.cfg:4-6`), drifting with `WindVector=(-0.7421,0,-0.8673)` (`clouds.weather:7-12`). Cloud count/delay ladders at `clouds.cfg:10-33`.
- **State:** `Weather=40`, `WeatherRandom=False` (`clouds.weather:3-6`) and `DateTimeEnable=False` (`light.ref:116`), hour fixed at 10 (`time.cfg:5`). Lens flare configured but `visible=False` (`default.cfg:20`). **INFERENCE:** the skirmish path shows one static weather preset and one static sky, not a day/night cycle or rain (consistent with `V71_mechanics_inventory.md:165`; rain is not a donor skirmish feature).

### 2.3 What fog actually does — gameplay vs cinematics

**OBSERVATION — the V71 claim is true for gameplay but not universally:**

| Camera config | `DynFogDepth` | Evidence |
|---|---|---|
| Gameplay / skirmish | **False** | `data\cameras\camera.cfg:59` |
| Debug | **False** | `data\cameras\cameradebug.cfg:57` |
| Screenshot / cinematic | **True** | `data\cameras\camerascreenshot.cfg:61` |

All three carry identical numeric keys (`DynFogStart=0.25`, `End=0.025`, `Density=2.0`, `Power=0.85`, `Offset=0`: `camera.cfg:60-64`, `cameradebug.cfg:58-62`, `camerascreenshot.cfg:62-66`). The **only** difference relevant here is the boolean. So: dynamic view-depth fog is **disabled in gameplay/debug** and **enabled in screenshot/cinematic** mode. V71's `camera.cfg:51-64` citation (`V71_mechanics_inventory.md:166`) is correct for the gameplay camera but does **not** cover the screenshot camera — that is the missing half of the story.

**What the fog code does when enabled:** `pvl.smx3.id0.frag:29-43` applies LINEAR / EXP / EXP2 in view space, with per-vertex depth `w = abs(realpos.z)` (ATI) or `length(realpos)` (`def.pvl.sm.vert:37-42`), then `mix(gl_Fog.color, color, fog)`. `fogMode` is a per-shader capability flag (`shaders.lib:4-13`), enabled on every lit family (`shaders.lib:17-27` etc.). Water has its own equivalent `fogmap()` with the same three modes (`water.dev.frag:237-261`). Clouds/skydome are explicitly unfogged (`clouds.mat:14,33,...` `moNoLighting`; `skydome.mat:20` `moIgnoreFog`).

**Critical distinction:** donor *view-depth atmospheric fog* and the port's *fog-of-war coverage overlay* are **two different mechanics**. The port's `world3d_fog.gd:3-4,26-31` says so explicitly and refuses to invent a mapping; `V71_mechanics_inventory.md:166` marks the donor fog↔`fog_explored`/`fog_vis` binding UNVERIFIED. Do not "fix" port fog by replacing its alpha ladder with donor depth fog, and do not enable donor depth fog in gameplay because a screenshot camera has it on.

---

## 3. Current 3D comparison

| Aspect | Donor (evidence) | variant3d 3D (evidence) | 2D app (reference) |
|---|---|---|---|
| Water geometry | Flat plane, no vertex displacement (`water.dev.vert:14-18,29`) | Flat 4-vertex quad full map extent (`world3d_terrain.gd:175-192`) — **structurally matches** | `Sprite2D` mask quad (`world.gd:1001-1010`) |
| Water surface shading | Per-pixel fBm waves, 4-tap normals, glints, procedural foam, projected reflection, depth tint/alpha (`water.dev.frag:85-104,186-227`) | `StandardMaterial3D` constant albedo (0.19,0.245,0.255,0.45), roughness 0.35 (`world3d_terrain.gd:193-201`) — **no donor equation wired** | Full donor equation transcription (`water_overlay.gdshader:50-68,107-174,176-278`) |
| Depth / shoreline | `height_map()` from `hmapTex`; fade over 0.57/1.07 m (`water.dev.frag:70-75,167-175,198-201,230`) | None; uniform alpha 0.45 and full-map quad | Per-tile depth mask R/G/B (`world.gd:979-1000`, `water_overlay.gdshader:8-10,176-184`) |
| Wave texture | `diffusewaves0.bmp` 256² luminance (`water.mat:7,11`) | None | `diffusewaves0.png` (`world.gd:924,972`) |
| Reflection | Projected `reflectionMap` + HDR multiplier (`water.dev.frag:207-213`) | None | Explicitly excluded (`water_overlay.gdshader:14`) |
| Water level | From vertex Y (`water.dev.vert:18`); classification literals −0.25/−0.1 (`texturemap.inc:30-31`) | `WATER_LEVEL=-0.25` constant (`world3d_terrain.gd:52`); 3D shader's `waveheight` analogue absent | `WATER_LEVEL=-0.25` classification (`world.gd:97`); shader `water_level=1.0` is a port choice (`world.gd:968`) |
| Atmosphere fog | View-depth LINEAR/EXP/EXP2, on only in screenshot camera (`pvl.smx3.id0.frag:29-43`, `camera.cfg:59` vs `camerascreenshot.cfg:61`) | Not implemented; port fog is per-tile state overlay (`world3d_fog.gd:3-4,147-165`) | CPU-baked `ImageTexture` fog (`V71:166`, `RENDER_ARCH_SHADERS.md:165`) |
| Sky | Gradient dome 2 bands, unlit/unfogged (`skydome.cfg:7-46`, `skydome.mat:20-21`) | Port-tuned `ProceduralSkyMaterial` colours (`world3d_terrain.gd:211-223`) — no donor colours | N/A (2D) |
| Clouds | 12 weather-banded billboard materials + wind (`clouds.mat`, `clouds.presets`, `clouds.weather:7-12`) | None | N/A (2D) |
| Sun | `light.cfg:26-30` → `water.dev.vert:22` transform | Same transform + donor colours (`world3d_terrain.gd:54-60,234-243`) | `sun_dir` from donor mapping (`world.gd:962`) |

**Net:** the 3D variant already has the right *geometry* for water and the right *sun derivation*, and it has donor-grounded sky/sun rig values, but it lacks every donor water *surface* effect and all sky/cloud/fog atmosphere. The 2D app already contains a near-verbatim donor water equation set in `water_overlay.gdshader` — that is the cheapest donor-grounded source to adapt, with the caveats in §4.

---

## 4. Ranked donor-grounded improvements

All items reuse **readable donor constants / equations / asset names**; none invents a value. Prior art (`app/shaders/water_overlay.gdshader`) is a port file, not a donor source, so donor citations are given for every constant.

**P0-1 — Wire a donor-equation water shader onto the existing 3D quad.**
Replace `StandardMaterial3D` (`world3d_terrain.gd:193-201`) with a `shader_type spatial; render_mode blend_mix` material that ports `water_map()` (`water.dev.frag:85-104`), 4-tap normals (`:186-194`), depth tint/alpha (`:198-201,229-230`), glints (`:215-226`) and foam (`:106-127,227`). Use donor literals from `water.dev.frag:37-47` and scales from `water.lib:32-33`. Source equation reference: `app/shaders/water_overlay.gdshader:50-68,107-174,176-278`. **Do not** copy the port's calibrated `SHALLOW_LIN`/`DEEP_BED_SUB`/`FOAM_GAIN`/`SLOPE_GAIN` (`water_overlay.gdshader:77-100`) as if they were donor; they are port art. Plane geometry stays as-is (`world3d_terrain.gd:175-192`).

**P0-2 — Feed real depth and wave texture into that shader.**
The donor water is defined by `level-height` (`water.dev.frag:170,175,198-201`). Provide a height texture from the existing dump height[] grid (`world3d_terrain.gd:258-346`) and a noise texture converted from `diffusewaves0.bmp` (256², `water.mat:7,11`; already present as `app/assets/terrain/water_png/diffusewaves0.png`, loaded at `world.gd:924`). Sample wave as `.r`/luminance (`water.dev.frag:67`). This replaces the uniform alpha 0.45 and gives a height-contour shoreline. Note the donor `hmapW/hmapH` uniforms (`water.dev.vert:2-3`) are engine-bound (UNV-1); in the port, map-width is an explicit, declared substitute (`water_overlay.gdshader:194-197`) — keep it labelled as a port choice.

**P1-1 — Height-aware shading is already 90% of the visible gap; add projected reflection only after P0.**
Donor reflects a projected target with jitter (`water.dev.frag:207-213`) and multiplies by `hdrMultiplier` (`water.lib:25`). In Godot this means a mirrored `Camera3D` into a `SubViewport` + `hint_screen_texture`/projected UV. Exact donor FBO binding is binary-only (UNV-2), so treat the *equation* as donor-grounded and the capture mechanism as an inferred implementation. Secondary: `RENDER_ARCH_SHADERS.md:153,315-316`.

**P1-2 — Sky and clouds from donor configs, static.**
Replace port-tuned sky colours (`world3d_terrain.gd:211-223`) with the two-band gradient from `skydome.cfg:7-46` (angles, 4 RGB triples, slices/stacks, `ScaleFactor`), rendered unlit/unfogged (`skydome.mat:20-21`). Add a single weather-banded cloud layer using `Weather=40` (`clouds.weather:3-4`) → `soft*` presets 10–50 (`clouds.presets:2-53`), billboarded transparent materials (`clouds.mat:3-56`) and donor wind (`clouds.weather:7-12`). Keep `DateTimeEnable=False` (`light.ref:116`) — **no** day/night cycle, **no** rain.

**P1-3 — Keep port fog-of-war; optionally add donor view-depth fog as a separate, opt-in layer.**
`world3d_fog.gd:3-4,26-31,147-165` is correct to remain a state overlay. If atmospheric fog is wanted, port the exact LINEAR/EXP/EXP2 math from `pvl.smx3.id0.frag:29-43` with depth `abs(z)`/`length()` from `def.pvl.sm.vert:37-42`, and gate it by camera preset: **off** for gameplay/debug (`camera.cfg:59`, `cameradebug.cfg:57`), **on** for screenshot/cinematic (`camerascreenshot.cfg:61`). Use `camera.cfg:60-64` numbers; do not invent start/end/density. Do **not** rebind it to `fog_explored`/`fog_vis` (UNV-3).

**P2-1 — Foam/glint A/B, not a blind copy.**
Donor foam amounts (`particle_amount=30`, spec exponents 170/120, colours `water.dev.frag:42-47`) are constants, but a 3D spatial path has different tone mapping than the 2D path (the 2D report calibrated alternatives at `water_overlay.gdshader:63-100`). Keep donor values as the baseline and A/B only against donor, recording any deviation as port art — never relabel it donor.

**P2-2 — Asset provenance cleanup.**
Correct the citing comment at `world3d_terrain.gd:30-31,52,379`: the −0.25 literal **is** readable at `texturemap.inc:30` (script line commented, active use UNV), so "donor literal UNVERIFIED" is too strong. Conversely, keep UNVERIFIED for `hmapTex` and the reflection FBO (§5).

---

## 5. Open questions / UNVERIFIED list

- **UNV-1 — `hmapTex` binding.** `water.dev.frag:18-21,70-75` declares it, but no script binds it; `water.lib:60,45` and `water.mat:86-106` only expose/comment material names. Engine-supplied height texture is the working hypothesis; `G31_donor_3d_truth.md:106-109` and `WATER_REPORT.md §2.2` agree it is **UNVERIFIED**. Do **not** bind `heightmapwaves0.tga` as a substitute.
- **UNV-2 — `reflectionMap` / `hdrMultiplier` / `waveMap` → texture-unit binding.** Only `water.mat`/`water.lib` material names are plaintext; the sampler-to-unit wiring sits in `cossacks.exe`. `RENDER_ARCH_SHADERS.md:338` (C7) marks this UNVERIFIED. The *equations* at `water.dev.frag:207-213` are observed; the capture mechanism is inferred.
- **UNV-3 — donor fog ↔ `fog_explored`/`fog_vis` binding.** Not readable; `V71_mechanics_inventory.md:166,176`, `world3d_fog.gd:23-31`. No port fog rule may be claimed as donor.
- **UNV-4 — active use of `cWaterHeight=-0.25` / `cWaterShoreHeight=-0.1`.** The lines at `texturemap.inc:30-31` carry the `;` script-comment prefix, so the literal is observed but whether the shipped script executes this branch is UNVERIFIED. The same values appear in port code (`world3d_terrain.gd:52`, `world.gd:97`) — likely donor-derived, but the exact runtime connector is unproven.
- **UNV-5 — water plane topology.** Flat plane is inferred from the passthrough vertex shader (`water.dev.vert:14-18,29`) and absence of a water mesh asset; whether it is one world quad, a few strips, or camera-following geometry is engine-side and **UNVERIFIED**.
- **UNV-6 — time-of-day override of the static sun.** `time.cfg:5`, `light.ref:116` show a fixed date/hour and disabled manager; whether another mode overrides `light.cfg:26-30` is UNVERIFIED (also flagged `V71_mechanics_inventory.md:164`).
- **UNV-7 — cinematic fog *appearance*.** `camerascreenshot.cfg:61` flips `DynFogDepth=True`, but the actual fog colour/start/end are supplied by engine state (`gl_Fog.color/start/end` in `pvl.smx3.id0.frag:34-42`), not a readable config. We can verify the flag, **not** the rendered result, without a GPU capture.
- **UNV-8 — cloud/sky texture bytes.** `clouds/textures/*.dds`, `skydome/textures/menu.dds`, `flares/textures/cloudy.hdr*.tga` were not decoded; only their config references (`clouds.mat:4`, `skydome.mat:30`, `env.cfg:20`) and one header size note are available. Cloud sprite appearance and HDR flare content are **UNVERIFIED** (cf. `RENDER_ARCH_CRAFT_ANYTHING_REPORT.md:46` on `cloudy.hdr.tga` being unrecognised).
- **UNV-9 — `diffusewaves1/2` and `heightmapwaves0` actual use.** `water.mat:26` comments `diffusewaves1`; `diffusewaves2`/`HeightMapWaves0` sit in commented/normal-map slots (`water.mat:35,86-106`, `water.lib:43-45`) with no matching sampler in the shipped fragment shader. Any claim that the shipped water samples them is **UNVERIFIED** and contradicted by `water.dev.frag:5-6,18`.

---

## 6. Top 5 corrective findings (summary for coordinator)

1. **Our 3D water quad's geometry is right; its material is empty.** Donor water is *also* a flat plane (`water.dev.vert:14-18,29`) with all detail in the fragment stage (`water.dev.frag:85-104,186-227`); our quad uses a constant-colour `StandardMaterial3D` (`world3d_terrain.gd:193-201`). Port the donor equations onto it — P0-1.
2. **Active shader is `water.dev.*`, and only `diffusewaves0.bmp` is really sampled.** `water.lib:67-68`, `water.dev.frag:5,65-68`, `water.mat:7,11,26,35,86-106`, `water.lib:43-45`. `heightmapwaves0.tga`, `diffusewaves1/2` are not shipped water inputs; do not bind them.
3. **Water threshold −0.25 is a real donor literal, and shoreline is height-contour-based.** `texturemap.inc:29-31` (−0.25 / −0.1), `water.dev.frag:170,175,198-201,229-230` (0.57/1.07 m fades, alpha 0 at shoreline). Our uniform alpha 0.45 quad (`world3d_terrain.gd:194`) must be replaced with depth-driven shading; the port comment calling the literal UNVERIFIED (`world3d_terrain.gd:30-31,52`) should be refined, not the value changed.
4. **Fog: V71 is right for gameplay, incomplete for cinematics.** `DynFogDepth=False` at `camera.cfg:59` **and** `cameradebug.cfg:57`, but **`True` at `camerascreenshot.cfg:61`** — same DynFog numbers. Donor fog math is LINEAR/EXP/EXP2 view-depth (`pvl.smx3.id0.frag:29-43`, `def.pvl.sm.vert:37-42`). Our fog overlay (`world3d_fog.gd:3-4,26-31,147-165`) is a different fog-of-war mechanic; keep it, never conflate, never invent a mapping (UNV-3).
5. **Sky/clouds are static donor configs, not the port's tuned gradient.** Donor: unlit/unfogged two-band gradient dome (`skydome.cfg:7-46`, `skydome.mat:20-21`) + 12 weather-banded transparent cloud billboards with fixed `Weather=40` and wind (`clouds.mat:3-228`, `clouds.presets:2-215`, `clouds.weather:3-12`, `light.ref:116`). Port: port-tuned `ProceduralSkyMaterial` with no clouds (`world3d_terrain.gd:211-223`). Translate the donor bands/presets; add no day-night cycle and no rain.

---

*End of report. No source, asset, config, test or git state was modified by this agent.*
