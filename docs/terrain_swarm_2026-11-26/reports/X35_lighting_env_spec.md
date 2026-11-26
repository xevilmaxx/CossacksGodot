---
id: X35
wave: DONOR-FIRST terrain swarm 2026-11-26
ticket: "Decode donor lighting/environment constants affecting terrain shading (I10/I08 check)"
agent: "X35 (READ-ONLY subagent; no code edits, no Godot jobs, donor read only)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
labels_used: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
---

# X35 — Donor lighting / environment constants for terrain shading

## 1. Executive summary

1. **[O] The active donor light rig is a single static file, not a preset/time-of-day system.** `env.cfg:22` loads `.\data\env\lights\light.cfg`; the richer `light.ref` / `light.presets` patterns exist but the whole skirmish switching block is comment-prefixed (`dogenerate.inc:2075-2098`, `:2090 //SetLightPattern(lid)`), day/night is explicitly disabled (`init.script:99 SetDateTimeManagerEnabled(false)`; `light.ref:116 DateTimeEnable = False`). So `light.cfg` is the authoritative skirmish sun/palette; `light.ref` and `light.presets` are *inactive templates*. This was resolved in two passes (§3, C1).
2. **[O] The donor-cited sun, ambient, diffuse, specular (light colour) and shininess values in I10 and `world3d_terrain.gd:137-141` are byte-exact copies of `light.cfg` / `reftile.mat`.** No replacement is needed for those literals. The one *material-level* contradiction is specular: `light.cfg:20-23` is nonzero but the terrain material sets `Specular = 0` (`reftile.mat:70-74,98-102`), so the donor's effective terrain specular product is zero (`hf.pvl.sm.vert:23`). I10's `specular_rgb = vec3(0.2784,…)` is therefore a **PORT APPROXIMATION**; the donor-faithful replacement for the normal refkey is `vec3(0.0)` (§5).
3. **[O] Fog is a real donor mechanism but its runtime state is not in a single file.** The palette defaults are `colors.lib:23,34-38,40,43` (`Fog = 60,100,150`, `FogStart = 390`, `FogEnd = 490`, `FogMode = 0` = **OFF**, `HFogMode = 2` = EXP, `HFogStart = 200`); the fragment implements OFF/LINEAR/EXP/EXP2 (`hf.pvl.smx3.frag:34-47`); camera dynamic fog keys are `camera.cfg:59-64`. **I10 has no fog code at all** (`terrain_donor_shader.gdshader:43`) — a defensible omission only because the default palette has `FogMode = 0`; any enabled-fog claim is **[U]/PORT APPROXIMATION**. Note the ticket premise: I10 does **not** hardcode a `fogMode` uniform (verified by full read + grep, §3 C4).
4. **[O] Donor terrain shadows are 3-tap PCF (SM2.0) or 9-tap PCF (SM3.0)** (`shaders.lib:15-31` → `hf.pvl.smx3.frag:22-30`; `shaders.lib:914-930` → `hf.pvl.smx9.frag:22-35`), with `of = 1/512`, `shadowed`/`shadowColor`/`texShadow` uniforms and palette `ShadowBlendingDiffuse = 140,140,140,128` (`colors.lib:33`). **I10 has no shadow sampler** (`:43`). This removes a depth cue but is not the dominant cause of the owner's complaint (§7).
5. **[D]/[I] Lighting cannot by itself produce the owner's "flat olive" complaint.** On flat ground the donor sun gives `dot(l,n) = 0.9387` (LIGHT-02 §4 row A), a strong, near-uniform diffuse. Z02 measured ~1° slopes, H05 refuted the hidden-height-layer hypothesis, F05/X06 located the diagonal lattice and flat cliffs in the *visible tile art / alpha* channel, and F06 R3 showed the port's mask floor erases full cuts. Secondary lighting divergences (nonzero specular, no shadow PCF, no fog, port energies `EXPOSURE=1.45`/`SUN_ENERGY=1.7`) modulate brightness but do not create olive albedo or veins. **No donor GPU A/B frame exists; no parity claim is made.**

## 2. Evidence table

All donor paths below are under `C:\Games\Cossacks 3` and were read read-only (text bytes, never executed/copied). Port paths are under the repo root.

| # | Source (path:line) | Literal / observation | Label |
|---|---|---|---|
| E1 | `data/env/env.cfg:22` | `LightSourceManager.LoadFromFile = .\data\env\lights\light.cfg` | [O] |
| E2 | `data/env/env.cfg:15-21,23-25` | Loaders: time.cfg, colors.lib, skydome.cfg, clouds.weather, clouds.cfg, flares, (Moon empty), PFX | [O] |
| E3 | `data/env/lights/light.cfg:3-6` | Ambient R=.196078434586525 G=.184313729405403 B=.129411771893501 A=1 | [O] |
| E4 | `light.cfg:9-13` | Diffuse R=.811764717102051 G=.780392169952393 B=.694117665290833 A=1 | [O] |
| E5 | `light.cfg:20-23` | Specular R=.278431385755539 G=.266666680574417 B=.211764708161354 A=1 | [O] |
| E6 | `light.cfg:26-30` | Position X=-0.344731152057648 Y=0.938701450824738 Z=0 W=1 | [O] |
| E7 | `light.cfg:8,15-18,25,32-38` | ConstAttenuation=1; Linear=0; Quadratic=0; `LightStyle=lsParallel`; `Shining=true`; SpotCutOff=180; SpotDirection=(0,0,-1,0); SpotExponent=0 | [O] |
| E8 | `data/env/lights/light.ref:12-17,30-48,116,120` | Inactive reference: Position=(16629.392578125,11111.4052734375,0,1); neutral Ambient/Diffuse/Specular (.549/.941/.502); `LightStyle=lsParallel`; `DateTimeEnable=False`; `CloudsBlockFogDensity=0.00092` | [O] |
| E9 | `data/env/lights/light.presets:3-137` | light0…lightN templates with `DateTimeHour = 20/11/19` and alternate sun positions | [O] (inactive) |
| E10 | `data/scripts/lib/init.script:99` | `SetDateTimeManagerEnabled(false);` | [O] |
| E11 | `data/scripts/common.inc/dogenerate.inc:2075-2098` | Entire season/colour-table/light-pattern switch is `[*] = ;` comment-prefixed; `:2090 //SetLightPattern(lid)` | [O] |
| E12 | `data/shaders/obj/hf.pvl.sm.vert:9,12-15,18-23` | eye-space `l=normalize(gl_LightSource[0].position.xyz-realpos.xyz)`; `n=normalize(gl_NormalMatrix*gl_Normal)`; `ambient=sceneColor+ambient product`; `diffuse=max(dot(l,n),0)*Ld`; `specular=pow(max(dot(h,n),0),gl_FrontMaterial.shininess)*Lsp` | [O] |
| E13 | `hf.pvl.sm.vert:20-22,35-36,38-39,41-46` | optional vertex-colour multiply; shadow texcoord `gl_TexCoord[3]=gl_TextureMatrix[3]*cameraMVM*realpos`; packed `gl_TexCoord[4]=ambient+diffuse`, `[5]=specular`; fog depth `length(realpos)` (ATI: `abs(realpos.z)`) | [O] |
| E14 | `data/shaders/obj/hf.pvl.smx3.frag:1-7,13-17,20-31,34-50` | `texShadow`, `fogMode`, `shadowed`, `shadowColor` uniforms; `color=tex0.rgb*packed+spec`; 3 PCF taps `of=1/512`; fog 1/2/3; `gl_FragColor=color` | [O] |
| E15 | `data/shaders/obj/hf.pvl.smx9.frag:22-35` | 9 PCF taps, `of=1/512`, `sh/9`, same `shadowColor` blend | [O] |
| E16 | `data/shaders/shaders.lib:2-14` | Aliases `srShadowColor=shadowColor`, `srFogMode=fogMode`, `srShadowed=shadowed`, `srTexShadow=texShadow`, `srShadowSize=shadowSize` | [O] |
| E17 | `shaders.lib:15-31` / `:914-930` | `ShadersSM20.HeightField` → `hf.pvl.smx3.frag` (`:18`), shadowColor=true `:22`, fogMode=true `:25`, shadowed=true `:26`, texShadow=true `:28`, shadowSize=false `:31`; `ShadersSM30.HeightField` → `hf.pvl.smx9.frag` (`:917`), same flags `:921-930` | [O] |
| E18 | `data/env/colors/colors.lib:17-44` | statictable[0] `default`: `Fog=60,100,150,1` `:23`; `Ambient=255,255,255` `:24`; `LSAmbient=140,140,140` `:27`; `LSDiffuse=240,240,240` `:28`; `LSSpecular=128,128,128` `:29`; `ShadowBlendingDiffuse=140,140,140,128` `:33`; `FogStart=390` `:34`; `FogEnd=490` `:35`; `FogMode=0` `:36`; `HFogStart=200` `:37`; `HFogMode=2` `:38`; `FogDepthFactor=0.8` `:39`; `FogBack=60,100,150,2` `:40`; `FogExpDepthFactor=0` `:43` | [O] |
| E19 | `colors.lib:68-93,94-100` | `dark` table: `Fog=64,128,255`, `FogStart=90`, `FogEnd=490`, `FogMode=2`, `FogDepthFactor=0.7`, `FogExpDepthFactor=0.7`; `winter`/`desert` only override `ShadowBlendingDiffuse` | [O] |
| E20 | `data/cameras/camera.cfg:59-64` | `DynFogDepth=False`, `DynFogStart=0.25`, `DynFogEnd=0.025`, `DynFogDensity=2.0`, `DynFogPower=0.85`, `DynFogOffset=0` | [O] |
| E21 | `data/gui/menu.inc/docreate.inc:315-322` | `SetCameraDynFog*` 0.125/0.625/0.5/0.001 and `SetShadowMapLightDepth(400)` are all comment-prefixed (screenshot-camera block) | [O] |
| E22 | `data/env/clouds/clouds.cfg:6` | `fogdensity = 0.000920000020414591` (cloud subsystem, not terrain fog) | [O] |
| E23 | `data/terrain/ref/reftile.mat:52-62,80-90` | normal refkey material `Ambient=0.15686`, `Diffuse=0.78125` (Back+Front) | [O] |
| E24 | `reftile.mat:70-76,98-104` | normal refkey `Specular=(0,0,0,1)`, `Shininess=16` (Back+Front) | [O] |
| E25 | `data/env/skydome/skydome.cfg:7-26,27-46` | up band horizon `(0.6,0.7764706,0.9921569)`, top `(0,0.1411765,0.8078431)`; down band both horizon colour | [O] |
| E26 | `variant3d/shaders/terrain_donor_shader.gdshader:43,50,151,154,156,158,163,218-226,299` | `render_mode blend_mix, unshaded, cull_disabled`; no fog/shadow sampler; hardcoded sun/ambient/diffuse/specular/shininess; `rgb*v_packed+v_specular` | [O] (port) |
| E27 | `variant3d/scripts/world3d_terrain.gd:137-141,149-151` | `SUN_POS`, `SUN_LIGHTVEC`, `DONOR_AMBIENT/DIFFUSE/SPECULAR` equal E3-E6; `EXPOSURE=1.45`, `AMBIENT_ENERGY=1.10`, `SUN_ENERGY=1.7` are port compensation | [O] (port) |
| E28 | `docs/coord_swarm_2026-11-25/reports/LIGHT_02_light_space.md:13,159-177,194-210,212-246` | Independent verdict: config Y is up; `sun_world=normalize(P.xyz)`, flat-ground `dot=0.938701`, tilt-invariant; `(x/4,z/2,y)` → `dot=0` (black) | [D] (prior report) |
| E29 | `docs/terrain_swarm_2026-11-25/reports/Z02_hills_invisible.md:27,47-60` | ±2.964 m over ~126×164 m ⇒ ~1° slopes; no shadow/AO; donor sun changes shading only a few percent; missing `terrainmeshN` silhouettes | [O]/[D] (prior report) |
| E30 | `docs/terrain_swarm_2026-11-25/reports/H05_refutation.md:43-60` | Veins are visible atlas art + alpha crossfade; hidden height/selection layer hypothesis REFUTED | [O]/[D] (prior report) |
| E31 | `docs/terrain_swarm_2026-11-26/reports/F05_tile_mapping.md:347-359`; `reports/X06_atlas_visual_audit.md` (in `spec/06 §7`) | face reuse drops orientation/mask → plausible "flat relief/no cliffs" [I]; real diagonal lattice in rock ids 17-19/22-23 FFT 24.7-30.6, 27/112 blocks ≥5 | [O]/[I] |
| E32 | `docs/terrain_swarm_2026-11-26/reports/F06_alpha_masks.md:361,387,395` | port mask factor confined to [0.675,1]; authored full cuts erased — "may be a contributing cause of the flat/olive appearance" [I] | [O]/[I] |

### 3. Multiple-pass contradiction adjudication (owner directive, CHARTER.md:85-93)

| # | Contradiction | Pass 1 | Pass 2 / second instrument | Accepted reading |
|---|---|---|---|---|
| C1 | Which light rig is active: `light.cfg` (small, warm, unit) vs `light.ref`/`light.presets` (large, neutral, time-of-day)? | Read `light.cfg` + `light.ref` + `light.presets` → two incompatible suns/colour triples. | Re-read `env.cfg:22` (loader), `init.script:99`, `light.ref:116`, `dogenerate.inc:2075-2098` (comment prefix on *every* switching line). | **[O]** `light.cfg` is the only active skirmish rig; `light.ref`/presets are inactive templates. Neutral `.549/.941/.502` triple is *not* the active terrain light. |
| C2 | `hf.pvl.sm.vert:13` subtracts `realpos` from the light position although `light.cfg:17` says `lsParallel`. | Take shader literally → per-vertex directional variation. | Cross-check LIGHT-02 §3.1.4/§7 Q1: engine `glLightfv` submission is invisible in 1,675-file text scan; `light.ref` radius 20000 makes the subtraction negligible; active `light.cfg` is unit-length. | **[D]** direction equals config XYZ for flat ground; engine `w`/modelview binding **[U]**. I10's dropping of the subtraction is **PORT APPROXIMATION**, not a recovered GL state. |
| C3 | `water.dev.vert:22` `(x/4,z/2,y)` read by earlier waves as "donor Z-up→Y-up" vs LIGHT-02 as a *water-local* conversion. | Earlier shader comments (`world3d_terrain.gd:121-126` legacy text) treat it as an axis map. | LIGHT-02 §3.3 (water Z-up local normal `:192`, `r0=vec3(uv,WATER_LEVEL)` `:215`, `dot(vec3(0,0,1),rd)` `:220`) + §4 rows A/B/C. | **[D]** config Y maps directly to Godot Y (identity); `/4,/2` are water art scales, not world axes. I10's `normalize(donor_sun_position)` (`:218`) is the donor-faithful row A. |
| C4 | Ticket premise "I10 hardcodes a fog mode" vs shader text. | Read I10 fully: only `// no … fog` at `:43`; no `fogMode` uniform. | grep `fogMode\|fog` over `terrain_donor_shader.gdshader` and `terrain_tileindex.gdshader` → no fog uniform in either (legacy reference also has none). | **[O]** I10 encodes **no fog mode**; donor fog mode lives in `hf.pvl.smx3.frag:4,34-47` and `colors.lib:36,38`. Premise corrected, not silently accepted. |
| C5 | `world3d_terrain.gd:138` `SUN_LIGHTVEC` flagged un-swapped by LIGHT-02 §6.1 (`:138` then = `(x/4,z/2,y)`). | LIGHT-02 report says stale/un-swapped. | Fresh re-read of current `world3d_terrain.gd:138` → `Vector3(SUN_POS.x, SUN_POS.y, SUN_POS.z)` with LIGHT-02 verdict comment. | **[O]** contradiction **resolved in current tree**: port module now uses donor-faithful identity map. LIGHT-02's §6.1 is a snapshot of the older file. |
| C6 | `SetCurrentColorTableIndex(6/7/0)` in `dogenerate.inc` (R10 claim 3 treats it as active season switching) vs literal prefix. | R10 §2.4 claim 3: "season switches colour table + PHDR" (winter 6 / desert 7 / else 0). | Byte re-read `dogenerate.inc:2075-2098`, `onloadfull.inc:71-89` → every line prefixed `[*] = ;`. | **[O]** season→static-table switching is **commented out** in shipped skirmish scripts. Which statictable the engine applies at runtime is **[U]**; default `[0]` values are the only readable statics. |
| C7 | Fog "density" from `colors.lib` vs `camera.cfg` vs `clouds.cfg`. | `FogStart/End`, `FogMode`, `HFogMode` in palette; `DynFogDensity=2.0` in camera. | Third source `clouds.cfg:6` `fogdensity=0.00092` = `light.ref:120 CloudsBlockFogDensity` (cloud layer), `docreate.inc:315-320` DynFog setters commented. | **[O]** three distinct mechanisms; **do not conflate**. `gl_Fog.density` value is **[U]**; `DynFog*` are dynamic camera params, not palette fog constants. |
| C8 | Shadow PCF 3-tap vs 9-tap. | `hf.pvl.smx3.frag:26-29` → 3 taps. | `shaders.lib:15-31` (SM20) vs `:914-930` (SM30) → both profiles bound to `HeightField`; `hf.pvl.smx9.frag:25-33` → 9 taps. | **[O]** both are donor; active profile depends on GPU capability **[U]**. Port has neither (I10 `:43`). |

## 4. Donor constants table

Byte literals are **[O]**; normalized/decimal conversions are **[D]**. "Effective" columns account for the fixed-function material product (`hf.pvl.sm.vert:18-23`).

| Constant | Donor literal (path:line) | Normalized / effective value | Label |
|---|---|---|---|
| Active sun direction (position, `lsParallel`) | `light.cfg:27-29` `X=-0.344731152057648, Y=0.938701450824738, Z=0`, `:30 W=1`; `:17 lsParallel` | unit vector (‖P‖≈0.99999999); flat-ground `dot(l,n)=0.938701` after VIEW rotation | [O]+[D] |
| Light style / shining | `light.cfg:17,18` | directional-equivalent; specular enabled flag | [O] |
| Attenuation | `light.cfg:8,15,16` | Const=1, Linear=0, Quadratic=0 (no falloff) | [O] |
| Spot | `light.cfg:25,32-37,38` | `SpotCutOff=180`, direction `(0,0,-1,0)`, exponent 0 (no cone) | [O] |
| Ambient (light colour) | `light.cfg:3-5` | `.1960784346 / .1843137294 / .1294117719` (=50/47/33 over 255) | [O] |
| Diffuse (light colour) | `light.cfg:10-12` | `.8117647171 / .7803921700 / .6941176653` (=207/199/177) | [O] |
| Specular (light colour) | `light.cfg:20-22` | `.2784313858 / .2666666806 / .2117647082` (=71/68/54) | [O] |
| **Effective terrain specular** | `reftile.mat:70-74,98-102` `Specular=(0,0,0,1)` × `light.cfg:20-22` via `hf.pvl.sm.vert:23` | **`vec3(0)`** for the normal refkey | [D] |
| Shininess | `reftile.mat:76,104` | `16` | [O] |
| Material ambient | `reftile.mat:53-55,81-83` | `0.15686` (grey) | [O] |
| Material diffuse | `reftile.mat:59-61,87-89` | `0.78125` (grey) | [O] |
| Fog colour (default statictable) | `colors.lib:23` `Fog=60,100,150,1` | `.235294 /.392157 /.588235` (÷255) | [O]+[D] |
| Fog start / end | `colors.lib:34-35` | `390 / 490` (world distance units) | [O] |
| Fog mode | `colors.lib:36` | `0` = OFF (shader tests `fogMode>0`, `hf.pvl.smx3.frag:34`) | [O] |
| Heightfield fog | `colors.lib:37-38` | `HFogStart=200`, `HFogMode=2` = EXP | [O] |
| Fog depth factor / exp depth factor | `colors.lib:39,43` | `0.8 / 0` | [O] |
| Fog back colour | `colors.lib:40` | `60,100,150,2` | [O] |
| Fog equations | `hf.pvl.smx3.frag:38-46` | 1=LINEAR `(end−d)*scale`; 2=EXP `exp2(−density*d*1.442695)`; 3=EXP2 `exp2(−(density*d)²*1.442695)`; `mix(fogColor,color,fog)` | [O] |
| Dynamic camera fog | `camera.cfg:59-64` | `DynFogDepth=False`, Start=.25, End=.025, Density=2.0, Power=.85, Offset=0 | [O] |
| Cloud fog density (separate) | `clouds.cfg:6`; `light.ref:120` | `0.000920000020414591` | [O] |
| Shadow sampler / flag / colour uniform | `hf.pvl.smx3.frag:3,5,6`; `shaders.lib:3,7,9,22,26,28` | `texShadow`, `shadowed=true`, `shadowColor` registered | [O] |
| Shadow PCF | `hf.pvl.smx3.frag:23,26-30` (SM20); `hf.pvl.smx9.frag:22,25-35` (SM30) | 3 taps / 9 taps, `of=1/512`, blend `color*=(sh+shadowColor*(1−sh))` | [O] |
| Shadow blend colour (palette) | `colors.lib:33` | `140,140,140,128` → `.549020,.549020,.549020`, α `.501961` — binding to the `shadowColor` uniform is **[U]** | [O]+[U] |
| Shadow map light depth | `docreate.inc:322` | `400`, **comment-prefixed** (inactive screenshot block) | [U] |
| Sky bands | `skydome.cfg:11-13,17-19,31-33,37-39` | horizon `(0.6,.776471,.992157)`, top `(0,.141176,.807843)` | [O] |
| Day/night | `init.script:99`; `light.ref:116`; `dogenerate.inc:2075-2098` | disabled / switching commented | [O] |

## 5. I10 comparison and exact replacement values

Source shader: `variant3d/shaders/terrain_donor_shader.gdshader` (I10, read-only to X35). Companion: `variant3d/scripts/world3d_terrain.gd:137-141`.

| I10 symbol (line) | I10 value | Donor value (path:line) | Verdict | Exact replacement / action |
|---|---|---|---|---|
| `donor_sun_position` `:151` | `vec3(-0.344731152057648, 0.938701450824738, 0.0)` | `light.cfg:27-29` identical | **[O] MATCH** | **None.** Keep. `world3d_terrain.gd:137` `SUN_POS` and `:138` `SUN_LIGHTVEC` (current identity map) also match; LIGHT-02 row A. |
| Sun transform `:218-219` | `normalize(donor_sun_position)`, then `VIEW_MATRIX` rotation | `hf.pvl.sm.vert:13` subtracts `realpos`; `lsParallel` `light.cfg:17` | **PORT APPROXIMATION** (engine GL state [U], §3 C2) | No literal replacement. Retain VIEW rotation (tilt-invariant, LIGHT-02 §3.2); document the dropped `realpos` subtraction. |
| `ambient_rgb` `:154` | `vec3(.1960784346,.1843137294,.1294117719)` | `light.cfg:3-5` identical | **[O] MATCH** (light colour) | **None** for the uniform. Donor also adds `gl_FrontLightModelProduct.sceneColor` and multiplies by material ambient `0.15686` (`hf.pvl.sm.vert:18`; `reftile.mat:53-55`) — the shader's single additive term is **PORT APPROXIMATION**, not a constant fix. `world3d_terrain.gd:139` matches. |
| `diffuse_rgb` `:156` | `vec3(.8117647171,.7803921700,.6941176653)` | `light.cfg:10-12` identical | **[O] MATCH** (light colour) | **None** for the uniform. Donor multiplies by material diffuse `0.78125` and optional vertex colour (`hf.pvl.sm.vert:19-22`; `reftile.mat:59-61`) — **PORT APPROXIMATION**. `world3d_terrain.gd:140` matches. |
| `specular_rgb` `:158` | `vec3(.2784313858,.2666666806,.2117647082)` | light colour `light.cfg:20-22` identical **but** effective terrain product `vec3(0)` (`reftile.mat:70-74,98-102`; `hf.pvl.sm.vert:23`) | **PRESERVED CONTRADICTION / PORT APPROXIMATION** | **Donor-faithful replacement for the normal refkey: `vec3(0.0)`** (= legacy reference shader `terrain_tileindex.gdshader:160`). If I08/COORD intend light-only specular, keep the current literal but label it `PORT APPROXIMATION` and cite `light.cfg:20-22` only. `world3d_terrain.gd:141` stores the light colour, not the effective product. |
| `shininess` `:163` | `16.0` | `reftile.mat:76,104` | **[O] MATCH** | **None.** Note it is inert if specular is set to zero. |
| Fog mode | **absent** (`:43` "no fog") | `colors.lib:36 FogMode=0` (OFF); shader modes 1/2/3 `hf.pvl.smx3.frag:34-47`; heightfield `HFogMode=2` `colors.lib:38` | **[O] omission defensible only for default table**; any enabled fog **PORT APPROXIMATION/[U]** | If fog is added: `fog_mode = 0` (default), `fog_color = vec3(60.0/255.0, 100.0/255.0, 150.0/255.0)` (`colors.lib:23`), `fog_start = 390.0`, `fog_end = 490.0` (`colors.lib:34-35`), heightfield `fog_density` **[U]** (no literal; `camera.cfg:62 DynFogDensity=2.0` is a *different* mechanism — do not substitute). |
| Shadows | **absent** (`:43` "no shadow sampler / PCF") | SM20 3-tap `hf.pvl.smx3.frag:23,26-30`; SM30 9-tap `hf.pvl.smx9.frag:22,25-35`; `of=1/512`; `colors.lib:33` | **PORT APPROXIMATION** (mechanism omitted) | No scalar replacement. If added: 3-tap for `gl_compatibility`-equivalent baseline, `of=1/512`, `shadow_color=vec3(140/255,140/255,140/255)`, α `128/255` **[U] binding**. Do **not** fabricate a shadow map texture. |
| `world3d_terrain.gd:149-151` energies | `EXPOSURE=1.45`, `AMBIENT_ENERGY=1.10`, `SUN_ENERGY=1.7` | no donor literal | **PORT COMPENSATION**, not donor | Leave labelled; note I10 is `unshaded` (`:50`), so these affect scene objects, **not** terrain pixels. Do not present as donor values. |

## 6. Implications for spec §05 (water/shore) and §06 (tile/atlas)

1. **§05 §5 "Shader constants"** (coast fade 0.57, deep fade 1.07, exponents 170/120, foam peak 0.535, colours `(0.1,0.24,0.24)` etc.) are *water* shader constants and are **not** affected by the light rig. This report adds one cross-check: the water vertex takes its sun from `gl_LightSource[0].position` via `(x/4,z/2,y)` (`water.dev.vert:22`), which LIGHT-02 §3.3 classified as a **water-local** Z-up conversion. Therefore the water shader's specular direction is **not** a second authoritative sun for the terrain and must not override `light.cfg:27-29` in I10/I08. **[D]**
2. **§05 §7 / §06 §5 alpha** (RGB from `texUnit0`, mask → `a`, no mask math, `bmTransparency`) is untouched by lighting. The terrain fragment multiplies albedo by packed lighting *after* sampling (`hf.pvl.smx3.frag:17`), matching I10 `:299` — so alpha crossfade stays in ALPHA only. **[O]**
3. **§05 §1-2 water levels** (−1.1/−0.5/−0.25/−0.1) are tile-classification/geometry values, not shading constants; no lighting replacement applies. The shore tile ids `sandsea1/5/6` inherit the same sun/palette as all land tiles; no separate "shore light" exists in `light.cfg`/`colors.lib`. **[O]/[I]**
4. **§06 §2/§7 atlas and visual validation**: fog and shadows, if ever enabled, must be applied **after** atlas lookup and tile-id selection, never used to invent/adjust tile ids. Because donor fog is OFF by default (`colors.lib:36`) and I10 is `unshaded`, the current absence of fog does not justify changing the 16×8 atlas, the 36 face-reuse cells or the 3 `alphanull` holes. **[D]**
5. **§06 cross-check with X06/F05**: the observed anisotropy is in the art, not in illumination (§7). Any future lighting fix must keep `UV2.x`/`UV2.y` and mask wiring fixed; do not tune light constants to hide vein patterns. **[D]**

## 7. Can lighting produce the owner's "flat olive" complaint?

**Verdict: [D]/[I] No — not as the primary cause. The dominant cause is tile art + relief/props; lighting is a secondary modulator.**

- **[D]** With donor sun `(-0.3447,0.9387,0)` (`light.cfg:27-29`) and flat-ground normal, `dot(l,n)=0.938701` (LIGHT-02 §4 row A) — a strong, *uniform* diffuse. Z02 (`Z02_hills_invisible.md:27,47-60`) measured ±2.964 m over ~126×164 m footprints ⇒ ~1° slopes, so the Blinn-Phong dot changes only a few percent. A near-uniform warm-lit field can read "flat", but it cannot **create** olive albedo or diagonal veins.
- **[O]/[I] F05/X06**: face-reuse cells preserve source pixels but drop donor orientation and alphavert mask (`F05:347-353`) → "flat relief / no readable cliffs" [I]. X06 measured real FFT anisotropy 24.7-30.6 in rock ids 17-19/22-23 and ≥5 in 27/112 blocks (`spec/06 §7`) — the lattice is baked into tile art, not lighting.
- **[O]/[D] H05**: the diagonal/vein patterns are visible atlas albedo + alpha crossfade; the "hidden height/selection layer" hypothesis is **REFUTED** (`H05_refutation.md:43-60`). Z02 additionally shows donor hill silhouettes come from `terrainmeshN` props the port never shipped — a geometry/props gap.
- **[O]/[I] F06 R3**: the port mask floor+guard confines factors to `[0.675,1.0]`, erasing authored full cuts; F06 itself calls it "a contributing cause of the flat/olive appearance" — but only an A/B can attribute it, and none exists.
- **Secondary lighting divergences** that can *modulate* the symptom, none of which create olive/veins: I10's nonzero specular vs donor material zero (§5); no shadow PCF / no AO (removes depth cues, Z02); no fog (donor default OFF, so low impact); port energies `1.45/1.10/1.7` (not donor). **[D]/[I]**
- **No donor GPU A/B frame exists**; the above is a code/measurement-derived attribution, **not** a parity claim (CHARTER.md:43-44,125).

## 8. UNVERIFIED register

| ID | Item | Why unverified | Evidence / passes attempted |
|---|---|---|---|
| U-X35-1 | Engine GL binding: whether `light.cfg` `W=1` + `lsParallel` is submitted as `w=0` direction or distant point; exact modelview used by `gl_LightSource[0]`; significance of `realpos` subtraction at `hf.pvl.sm.vert:13` | no readable `glLightfv`/`SetLight` call in donor text (1,675-file scan per LIGHT-02) | LIGHT-02 §7 Q1; §3 C2 above |
| U-X35-2 | Runtime `gl_Fog.mode`, `gl_Fog.color`, `gl_Fog.density`, `gl_Fog.start/end` actually bound for terrain | palette statics and camera DynFog keys are readable, but the engine's binding is not; three distinct fog sources | E18/E20/E22; §3 C7 |
| U-X35-3 | Which statictable index is active in shipped skirmish (season switching is commented out) | `dogenerate.inc:2075-2098` fully `[*] = ;`; no active setter found | §3 C6; R10 claim 3 (treated literals as active) |
| U-X35-4 | `shadowColor` uniform value and `shadowed` flag at runtime; which PCF profile (SM20 3-tap vs SM30 9-tap) is chosen | palette `ShadowBlendingDiffuse` is readable but its binding is not; profile depends on GPU capability | E17/E19; §3 C8 |
| U-X35-5 | `SetShadowMapLightDepth(400)` and `SetCameraDynFog*` in `docreate.inc` — screenshot-only, comment-prefixed | no active call site | E21 |
| U-X35-6 | Whether `light.ref`/`light.presets` patterns are ever activated by editor or DLC paths (skirmish path confirmed inactive) | skirmish scripts read only; editor binary not decompiled here | E8-E11 |
| U-X35-7 | Whether fixing specular to zero / adding fog or shadows changes the owner's perceived olive tone | no donor GPU A/B frame; no runner job permitted | §7; CHARTER.md:125 |
| U-X35-8 | `hf.pvl.smx9.frag` `shadowSize` registration vs hardcoded `of=1/512` (shaders.lib:930 sets `shadowSize=false` even in SM30) | contradictory-looking; no runtime value | E15/E17 |

## 9. Open questions

1. **I08/COORD decision:** set I10 `specular_rgb` to `vec3(0.0)` (donor material-faithful, `reftile.mat:70-74,98-102`) or keep the light colour and retain the `PORT APPROXIMATION` label? The legacy reference shader already uses zero.
2. Should I10 gain a labelled fog path at all, given `colors.lib:36 FogMode=0` (OFF) for the default table? If yes, confirm `fog_color` normalization (÷255) and refuse to substitute `camera.cfg:62 DynFogDensity=2.0` for `gl_Fog.density`.
3. Is any port-side shadow representation in scope for V7-9 (`scenes/**`, `shaders/**`, environment) — and if so, can `gl_compatibility` support a donor-shaped 3-tap PCF without fabricating a shadow map? Z02 says shadow absence is a depth-cue gap, not the root cause.
4. Should `world3d_terrain.gd:149-151` (`EXPOSURE=1.45`, `AMBIENT_ENERGY=1.10`, `SUN_ENERGY=1.7`) be reconciled with the unshaded I10 terrain so scene lighting and terrain pixels agree? LIGHT-02 §6.5 already flagged a sibling inconsistency that has since been partially fixed (§3 C5).
5. COORD should confirm whether spec §05/§06 need an explicit note that the water shader's `(x/4,z/2,y)` light vector is **not** a terrain sun authority (§6 #1), to prevent a future worker re-introducing the pre-fix `dot=0` mapping.
6. Does the `dark` static table (`colors.lib:68-93`, FogMode=2) ever become active (e.g. editor/DLC), which would make I10's missing fog a real visual divergence rather than a default-off no-op?

---

*End of X35. READ-ONLY: no repo file other than this report was written; no Godot runner job was submitted; no donor binary was run or copied. All donor material is private use. No donor parity claim.*
