---
id: RV-TRN-03
task: "Independently re-verify donor WATER bindings (hmapTex, wave textures, shore constants) for the 3D terrain+shore piece test T2"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_EXECUTION__NO_CODE_EDITS
scope: "Read-only donor bytes/latin-1 + read-only port file reads. ONE report written; no code, asset, config, test, runner or git edit; no donor binary run/copied; no Godot process started."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY). cossacks.exe sha256 87f0f3c130b027e7c4e72dc2… (matches DEEPDEC-03 prefix 87f0f3c130b0…e16c); codex.dll sha256 382a9594091017…"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/RV_TRN_03_water_bindings.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 2
visual_parity_claim: false
---

# RV-TRN-03 — Third-pass donor WATER binding re-verification

## 0. Goal

Independently re-verify, from donor bytes only, which water shader bindings are
**explicitly assigned in readable donor text**, which are **commented only**, and
which are **engine/implicit and therefore UNVERIFIED**. Resolve (or confirm
unresolvable) the specific question of whether `heightmapwaves0.tga` is bound to
`hmapTex`. Verify all water constants and the exact fragment step order, then
compare read-only against `variant3d/shaders/water3d.gdshader` and
`variant3d/scripts/water3d.gd` so the terrain+shore piece test T2 can label every
claim correctly.

Donor truth is primary. Every important claim was checked **twice by different
means** (§1.2). Labels: **observed** (literal byte/line read), **derived**
(deterministic arithmetic/control-flow from observed lines), **inferred**
(interpretation with a caveat), **UNVERIFIED** (not provable from readable data).

---

## 1. Sources

### 1.1 Prior reports read first (all read in full this session)

| # | Path | Role |
|---|---|---|
| O1 | `docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md` | §2 C21/C22/C23, §5.3 water fragment, §8 Q10 |
| O2 | `docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md` | donor fragment ledger, port approximation ledger, UNVERIFIED list |
| O3 | `docs/audit/TERRAIN_DONOR_WATER.md` | water asset table, constants, claim table, §8 Q1 |
| O4 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_03_water.md` | descriptor/defaults, full shader path, binary string tables |
| O5 | `docs/coord_swarm_2026-11-25/PLAN_IMPLEMENTATION.md`, `TEST_MATRIX.md`, `reports/V3D_02_terrain_render_audit.md` | T2 acceptance criteria (grep, read-only) |

### 1.2 Two independent verification passes

- **V1 — line-numbered text pass.** Helper
  `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rvtrn03_dump.py` performed
  `path.read_bytes().decode('latin-1').split('\n')` and printed 1-based numbered
  lines. Used on `water.dev.frag` (262 lines), `water.dev.vert` (30),
  `water.lib` (71), `water.mat` (106), `texturemap.inc`, `generatemap.inc`,
  `colors.lib`, plus direct `repr()` reads for exact CRLF/comment prefixes.
- **V2 — independent byte/binary pass.** Three separate scripts:
  (a) `rvtrn03_textscan.py` — case-insensitive byte search over **6,177** donor
  text files (`.inc/.lib/.mat/.cfg/.frag/.vert/.script/.txt/.lng/.actor/.pattern/
  .prop/.presets/.objects/.palette/.map/.aaf/.aix/.acl/.tlf/.ref/.cur/.removed/
  .global/.ini/.xml/.shader/.hlsl/.fx/.glsl`), counting files and extracting
  excerpts;
  (b) `rvtrn03_binscan2.py` — case-insensitive ASCII **and** UTF-16LE scans of
  `cossacks.exe` (5,768,048 B) and `codex.dll` (106,272 B);
  (c) `rvtrn03_whole_search.py` — byte search for `heightmapwaves`,
  `heightmapwaves0`, `hmaptex` across **all** donor files except the 4.87 GB of
  `.map` and 3.77 GB of `.dds` binary payload sets (image/height-data payloads,
  not configs). Additionally: direct `struct`-free byte-pattern decode of the
  Delphi assignment instruction in `cossacks.exe`.
  Where V1 and V2 disagree, the raw byte read wins. No donor file written.

### 1.3 Donor files re-read this session (all under `C:\Games\Cossacks 3`)

| File | Bytes | Lines | Purpose |
|---|---:|---:|---|
| `data\shaders\water\water.dev.frag` | 8,928 | 262 | shipped fragment (pinned by `water.lib:68`) |
| `data\shaders\water\water.dev.vert` | 928 | 30 | shipped vertex passthrough |
| `data\shaders\water\water.frag` | 8,284 | — | alternate fragment (NOT selected by `water.lib`) |
| `data\shaders\water\water.vert.bak` / `water.frag.bak` | 1,699 / 1,844 | — | legacy pair (embedded in binary, §6) |
| `data\water\water.lib` | 2,063 | 71 | active water descriptor + shader selection |
| `data\water\water.mat` | 2,899 | 106 | wave/height texture material definitions |
| `data\scripts\common.inc\texturemap.inc` | 48,954 | 963 | shore classification constants |
| `data\scripts\common.inc\generatemap.inc` | — | — | generation-basin constants |
| `data\env\colors\colors.lib` | — | — | fog colour / FogMode default |
| `cossacks.exe`, `codex.dll`, `config.cdx`, `editor.exe`, `modman.exe`, … | — | — | engine name tables + embedded GLSL |

Port files read read-only: `variant3d/shaders/water3d.gdshader` (235 lines),
`variant3d/scripts/water3d.gd` (264 lines), `variant3d/scripts/world3d_terrain.gd`
(lines 505–549, 752–786).

---

## 2. Binding verdict table

Verdict classes: **TEXT-EXPLICIT** = an asset/value is assigned in readable donor
text; **COMMENTED** = present only behind `//` or `;`; **ENGINE/IMPLICIT** =
declared as a shader uniform and present in engine name tables, but the texture
unit / FBO / numeric value is never assigned in readable data → **UNVERIFIED**.

| Binding | Exact evidence (`path:line` / `path:offset`) + excerpt | Class | Verdict |
|---|---|---|---|
| **`hmapTex`** | `shaders\water\water.dev.frag:18` `uniform sampler2D hmapTex; //sampler2DRect`; `:72-73` `vec4 v=texture2D(hmapTex, p); float h=hmapMin+v.w*(hmapMax-hmapMin);`; alternate `water.frag:8`, `:246` `texture2D(hmapTex, gl_TexCoord[3].xy)`. Binary: `cossacks.exe:0x452DFF` `wstHMapTex`, `:0x45320C` `hmapTex`, `:0x453D41` `fHMapTex` (VA +`0x400C00` = `0x853E0C` etc.); `config.exe/config.cdx/editor.exe/modman.exe` carry the same table. `cossacks.exe:0x452FDB (VA 0x853BDB)`: `8d 43 54 ba 0c 3e 85 00 e8 6c 18 bb ff` = `lea eax,[ebx+0x54]; mov edx,0x853e0c; call 0x405454`. | ENGINE/IMPLICIT | **UNVERIFIED** — only a Delphi **string-key** assignment to descriptor field `+0x54` is proven (V2 independently re-decoded instruction + call target `0x405454`); **no texture lookup, sampler unit or source file is assigned anywhere**. **NOT `heightmapwaves0.tga`** (see last row). |
| **`hmapMin` / `hmapMax`** | `water.dev.frag:19-20` declarations; `:73` `hmapMin+v.w*(hmapMax-hmapMin)`; `water.frag:9-10,:247`. Binary `cossacks.exe:0x452E43/0x452E57` `wstHMapMin/wstHMapMax`, `:0x45323C/0x45324C` `hmapMin/hmapMax`, `:0x453D7D/0x453D91` `fHMapMin/fHMapMax`. No external numeric assignment in any text file. | ENGINE/IMPLICIT | **UNVERIFIED** for donor runtime values. Port's `±max_height` (±2.96) is a **derived port approximation**, not a recovered binding. |
| **`hmapW`** (and `hmapH`) | `water.dev.frag:21` `uniform int hmapW;`; `:187` `pos=uv*15./texScaleS*(hmapW/128.0)+vec2(iglobaltime*.01)`. `water.dev.vert:2-3` `uniform int hmapW; uniform int hmapH;`; `:16-17` `gl_MultiTexCoord0.x/hmapW-0.5`, `.y/hmapH-0.5`. Binary `cossacks.exe:0x452E13` `wstHMapWidth`, `:0x45321C` `hmapW`, `:0x453D55` `fHMapWidth`. No text value. | ENGINE/IMPLICIT | **UNVERIFIED** engine value. Port substitutes `map_size.x/.y` (`water3d.gd:166`, `:261`; `water3d.gdshader:166`). |
| **`waveMap`** | Shader: `water.dev.frag:5`, `:67` `texture2D(waveMap, p*vec2(1./256.)).x`, `:80`. Binary: `cossacks.exe:0x453088` `waveMap`, `:0x45462A` embedded `uniform sampler2D waveMap;`, `:0x454848/0x454882` embedded `texture2D(waveMap,…)`. **Text assignment:** `water.lib:44` `DiffuseMapLibMaterialName = DiffuseWaves0`; `water.mat:7` `Image = .\data\water\textures\diffusewaves0.bmp`, `:11` `TextureFormat = tfLuminance`, `:15` `Name = DiffuseWaves0`. | TEXT-EXPLICIT (asset) + ENGINE (unit) | **OBSERVED** asset binding (`diffusewaves0.bmp`, 256², luminance). GPU sampler-unit binding remains engine-side, but the source asset is unambiguous in text. |
| **`DiffuseWaves` family** | `water.lib:43` `NormalMapLibMaterialName = DiffuseWaves2` **active**; `:44` `DiffuseMapLibMaterialName = DiffuseWaves0` **active**; `:45` `//NormalMapLibMaterialName = HeightMapWaves0` **commented**; `:46` `//DiffuseMapLibMaterialName = DiffuseWaves0` **commented duplicate**. `water.mat:7,15` DiffuseWaves0 active; `:32-39` DiffuseWaves2 active (`Image = …diffusewaves2.bmp`, `:35`); `:23-31` DiffuseWaves1 and `:41-84` DiffuseWaves3-7 behind `//`; `:86-106` HeightMapWaves0 behind `//`. | MIXED | DiffuseWaves0/2 **TEXT-EXPLICIT active**; waves 1/3-7 and HeightMapWaves0 **COMMENTED**. Caveat: `.dev` fragment has **no normal-map sampler**; `DiffuseWaves2`'s GPU upload is UNVERIFIED (O4 §5, O2 §4). |
| **`reflectionMap`** | `water.dev.frag:6`, `:207-210` `vec3 refuv=gl_TexCoord[0].xyw; refuv.xy-=wavejitter*refuv.z; vec4 refcol=texture2DProj(reflectionMap, refuv); refcol.xyz*=(…)*hdrMultiplier;`. Binary `cossacks.exe:0x453070` `reflectionMap`, `:0x453BA0` `fReflectTex`, `:0x454666` embedded declaration, `:0x454A80` embedded `texture2DProj`. No text file assigns an image/FBO to it. | ENGINE/IMPLICIT | **UNVERIFIED** FBO / projective coord binding. `materials\ref\refcubemap.mat` exists but has no plaintext link to this uniform (O3 §3c). |
| **`watercolor`** | `water.dev.frag:45` `vec3 watercolor = vec3(0.1, 0.24, 0.24);`, `:46` `watercolor2 = vec3(0, 0.025, 0.05);`, used `:201,213,223-229`. Binary ASCII hits `0x454BE8/0x454C3E/0x454C88` belong to the **embedded legacy** `waterColor` (different constants), not this shader. | TEXT-EXPLICIT (GLSL local) | **OBSERVED** — shader-local literal, no engine binding needed. |
| **`coastfade`** | `water.dev.frag:37` `coast2water_fadedepth = 0.57`; `:168` `deepwater_fadedepth=0.5+coast2water_fadedepth` (=1.07, **derived**); `:198-199` `coastfade=clamp((level-height)/coast2water_fadedepth,0.,1.)`, `coastfade2=clamp((level-height)/deepwater_fadedepth,0.,1.)`; `:227,:229-230` uses. No binary ASCII hits (`coastfade`: 0 in both binaries) — it is a shader-local. | TEXT-EXPLICIT (GLSL local) | **OBSERVED**. Shore classification constants are separate: `texturemap.inc:30-31` `-0.25`/`-0.1` (**COMMENTED** script lines; active execution UNVERIFIED). |
| **`nautic`** | `water.dev.frag:106-117` `float nautic(vec2 p){p*=18.; … return pow(1.-f,5.);}`, `:227` foam term. Binary: 0 hits. Text scan also hit `locale\en\missions\netmis2.lng:1` / `.txt:54` — the substring in "nautical miles", **unrelated**. | TEXT-EXPLICIT (GLSL function) | **OBSERVED** procedural foam; no foam texture asset exists. |
| **`particles`** | `water.dev.frag:119-127` `float particles(vec2 p){p*=200.; … return pow(f*.35,7.)*particle_amount;}`, `:227`. **Disambiguation:** 45 binary hits and `env\env.cfg:24-25`, `env\pfx\particles.lib:14` belong to a **separate PFX subsystem**, not water foam. | TEXT-EXPLICIT (GLSL function) | **OBSERVED** water foam function; unrelated PFX hits must not be cited as water bindings. |
| **`fogEnabled`** | `water.dev.frag:23` `uniform int fogEnabled;`; `:239-249` modes 1/2/3. Case-insensitive text scan finds this token in **exactly one** donor text file (`water.dev.frag`); the alternate `water.frag` has no `fogEnabled` uniform. The **embedded legacy `.bak`** shader does declare it (`cossacks.exe:0x454003`). Engine tables: `cossacks.exe:0x452DE7` `wstFogEnabled`, `:0x4531F8` `fogEnabled`, `:0x453D2D` `fFogEnabled`. Palette default `env\colors\colors.lib:36` `FogMode = 0`, `:23` `Fog = 60,100,150,1`. | ENGINE/IMPLICIT (uniform) + TEXT palette default | **OBSERVED** declaration and default palette; **UNVERIFIED** runtime uniform value (engine maps palette → int). Port's `fog_enabled=0` (`water3d.gd:165`) is faithful to the default. |
| **`heightmapwaves0.tga`** | `water.mat:92` `//         Image = .\data\water\textures\heightmapwaves0.tga` — **all 21 lines `water.mat:86-106` begin with `//`** (byte-verified `repr`). `water.lib:45` `//NormalMapLibMaterialName = HeightMapWaves0`. Whole-tree byte scan: **exactly these 2 occurrences, both commented**; `heightmapwaves0` = **0 hits** in `cossacks.exe`, **0 hits** in `codex.dll`, 0 hits in every other donor file. | COMMENTED ONLY | **RESOLVED — NOT `hmapTex`.** No readable datum supports the identification; the binding block is fully commented and the asset name is absent from both binaries. |

**Summary verdict.** Only `waveMap` has a text-explicit source asset. `hmapTex`,
`hmapMin/Max`, `hmapW/H`, `reflectionMap` and `fogEnabled` are engine/implicit and
remain **UNVERIFIED**. `watercolor`, `coastfade`, `nautic`, `particles` are
shader-local and fully readable. `DiffuseWaves2` is active config but has no
matching `.dev` sampler. `heightmapwaves0.tga` is commented-only and is **not**
`hmapTex`.

---

## 3. Constants table

### 3.1 `water.dev.frag:37-47` — verbatim (observed, V1; re-found by V2 byte scan)

```glsl
37: float coast2water_fadedepth  = 0.57;
38: float large_waveheight       = 0.50; // change to adjust the "heavy" waves
39: float large_wavesize         = 2.;   // factor to adjust the large wave size
40: float small_waveheight       = .5;   // change to adjust the small random waves
41: float small_wavesize         = .5;   // factor to ajust the small wave size
42: float water_softlight_fact   = 170.;  // range [1..200] (should be << smaller than glossy-fact)
43: float water_glossylight_fact = 120.;  //120.; // range [1..200]
44: float particle_amount        = 30.;  //70.;
45: vec3  watercolor             = vec3(0.1, 0.24, 0.24); // 'transparent' low-water color (RGB)
46: vec3  watercolor2            = vec3(0, 0.025, 0.05); // deep-water color (RGB, should be darker than the low-water color)
47: vec3  water_specularcolor    = vec3(0.4, 0.4, 0.4);    // specular Color (RGB) of the water-highlights
```

Note: `//120.;` and `//70.;` are **inline commented alternatives**, not active
values — active exponents are 170 and 120, active particle amount 30.
`:48` `light = vec3(lightVector.x, lightVector.y, lightVector.z)`.

### 3.2 Other fragment literals (observed)

| Constant | Value | `water.dev.frag` line |
|---|---|---|
| `m` (FBM rotation/scale) | `mat2(0.72, -1.60, 1.60, 0.72)` | 83 |
| coarse octave weights | `0.6000`, `0.2500`, `0.1666` | 92–94 |
| swell args | `p2=p*2`; `sin(p2.x*0.622+p2.y*0.622+shift2.x*4.269)*0.5*f*h²` | 87, 95 |
| shifts | `0.001*(t*320, t*240)`; `0.001*(t*380, -t*260)` | 88–89 |
| small waves | `p*=0.5`; 9 iterations; `p=m*p*0.947`; `amp*=0.59`; `s*=-1.329`; `return wave+f*0.5` | 97–103 |
| `nautic` | `p*=18`; 3 iterations; `m*p*1.2`; `amp*=0.5`; `s*=-1.227`; `pow(1-f,5)` | 109–114 |
| `particles` | `p*=200`; `s=1.5`; 3 iterations; `pow(f*0.35,7)*30` | 121–126 |
| `deepwater_fadedepth` | `0.5+0.57 = 1.07` | 168 |
| `waveheight` | `clamp(WATER_LEVEL*3.-1.5, 0., 1.)` | 174 |
| `level` | `WATER_LEVEL + .2*water_map(uv*15.+vec2(iglobaltime*.1), waveheight)` | 175 |
| wave UV scale | `uv*15./texScaleS*(hmapW/128.0)+vec2(iglobaltime*.01)` | 187 |
| `dif`, normal Z | `vec2(.0,.01)`, `0.15` | 186, 192 |
| `wavejitter` | `normwater.xy*texScaleT*(level-height)` | 193 |
| bed colour | `vec3(0.175,.1375,.1)+texture2D(waveMap,p*8.).rgb*.25` | 80 |
| luma weights | `.2126`, `.7152`, `.0722` | 200 |
| glint | `pow(grad,170)`, `pow(grad,120)`, `pow(gradpos,5)` | 218–221 |
| shade/gain | `*2.2+shade`; `(.2+.8*shade)*((grad-1)*.5+spec)*.25`; `/ (1.+specular1*1.25)` | 223–225 |
| foam tints | `(.5,.6,.7)`, `(1,1,1)` | 227 |
| fog | `1.442695` | 246, 249 |
| shadow PCF | `of=1/shadowSize`, 3 taps, `.r<0.999`, `/3`, `shadowColor.x*0.7` | 134–140 |

### 3.3 `water.lib` values (observed, verbatim)

| Constant | Value | Line | Constant | Value | Line |
|---|---|---|---|---|---|
| `MaxDepth` / `MinDepth` | 1 / 0 | 5 / 6 | `MaxAlpha` / `MinAlpha` | 1.1 / 0 | 7 / 8 |
| `DeepColor` | (0,0,0.1255,0.5) | 9–14 | `ShallowColor` | (0,0,0,0.5) | 15–20 |
| `ReflectionAmount` / `WaterAmount` | 1 / 1 | 21 / 22 | `FresnelPower` / `FresnelBias` | 1 / 1 | 23 / 24 |
| `HDRMultiplier` | 1 | 25 | `WaveFreq` / `WaveAmp` | 0 / 0 | 26 / 27 |
| `DistFactor` / `BumpFactor` | 1 / 1 | 28 / 29 | `TexScaleS` | **0.1** (`//0.115` at :30) | 32 |
| `TexScaleT` | **0.01** (`//0.015` at :31) | 33 | `WaveDir0` / `WaveDir1` | (−1,0) / (−0.7,0.7) | 34–41 |
| `Speed` | 1.0 | 42 | `Width` / `Height` / `Offset` / `LayerCount` | 1 / 1 / 0.495 / 1 | 47–50 |
| `CustomEnable` / `CustomReflection` | False / False | 51 / 53 | `CustomTexCoord` | True | 56 |
| `HeightMapEnable` / `ShadowMapEnable` | True / True | 60 / 61 | shaders | `water.dev.vert/.frag` | 67–68 |

### 3.4 Shore / generation / fog constants (observed text; script lines are `;`-commented)

| Constant | Value | Source | Label |
|---|---|---|---|
| `cMaxHeight` | 2.96 | `scripts\common.inc\texturemap.inc:29` `;const cMaxHeight = 2.96;` | observed text; active execution UNVERIFIED |
| `cWaterHeight` (classification) | −0.25 | `texturemap.inc:30` | as above |
| `cWaterShoreHeight` | −0.1 | `texturemap.inc:31` | as above |
| `cBColorWater`, `cBWater` | 255, 1 | `texturemap.inc:27`, `:14` | observed |
| `cPlateauHeight`, `cHillHeight`, `cRavineHeight` | 2.964, 2.964/2.25, −2.964 | `generatemap.inc:4-6` | observed; distinct script |
| `cWaterHeight` (generation basin) | −1.1 | `generatemap.inc:7` | observed; **not** a plane literal |
| `Fog` / `FogStart` / `FogEnd` / `FogMode` | (60,100,150,1) / 390 / 490 / **0** | `env\colors\colors.lib:23,34-36` | observed default |

No numeric descriptor default (0.495, 0.57, 2.96, −0.1) is provable as a float
in `cossacks.exe` (O4 §2.3; the `0x853eb8` f32 `1.99999988` is an enable bitmask).
This report did not re-derive that negative-result claim; it is cited from O4.

---

## 4. Fragment step order

**Exact `water.dev.frag` order (observed, V1; cross-checked against O1 §5.3,
O2 §3, O4 §4.3):**

1. `:165` `uv = fragCoord.xy` (`fragCoord = gl_TexCoord[1].xy`, set at `:258`).
2. `:167` `WATER_LEVEL = gl_TexCoord[1].z` — plane Y carried by `water.dev.vert:18`
   (`gl_TexCoord[1].z=pos.y`); **not** the legacy constant 1.5.
3. `:168` `deepwater_fadedepth = 0.5 + 0.57 = 1.07` (**derived**).
4. `:170` `height = height_map(uv)` — `hmapMin + hmapTex.w*(hmapMax-hmapMin)` (`:70-75`).
5. `:174-175` `waveheight = clamp(WATER_LEVEL*3-1.5,0,1)`; `level = WATER_LEVEL + 0.2*water_map(uv*15+time*0.1, waveheight)`.
6. `:176-183` **land discard:** `if (height>level) { fragColor=vec4(0.0); return; }`.
7. `:186-194` **wave:** `dif=(0,.01)`; `pos=uv*15/texScaleS*(hmapW/128)+time*.01`;
   4 `water_map` taps; `normwater=normalize(vec3(h3-h4,h1-h2,0.15))`;
   `wavejitter=normwater.xy*texScaleT*(level-height)`; `uv+=wavejitter`.
8. `:196` `rescolor = CalcTerrain(uv,height)` — bed colour + 4 height taps +
   `col*=grad+grad^8` + 3-tap PCF shadow (`:145-160`).
9. `:198-201` **coastfade:** `coastfade=(level-height)/0.57`, `coastfade2=(level-height)/1.07`,
   Rec.709 `intensity`, `watercolor=mix(watercolor*intensity, watercolor2, smoothstep(0,1,coastfade2))`.
10. `:203-213` **reflection:** Fresnel block `:203-206` and water/reflection `mix`
    `:211-212` are **commented**; live: `refuv=gl_TexCoord[0].xyw`,
    `refuv.xy-=wavejitter*refuv.z`, `texture2DProj(reflectionMap,refuv)`,
    `refcol.xyz*=(R+G+B)*hdrMultiplier`, `watercolor+=refcol.xyz`.
11. `:215-226` **specular:** `rd=normalize(light-vec3(uv,WATER_LEVEL))`;
    `grad=dot(normwater,rd)`; `pow(grad,170/120)`; corona `smoothstep(0,1,pow(gradpos,5))`;
    `watershade=test_shadow(uv,level)`; `watercolor*=2.2+watershade`;
    `+=(.2+.8*watershade)*((grad-1)*.5+specular)*.25`; `/=1+specular1*1.25`;
    `+=watershade*specular2*(0.4,0.4,0.4)`.
12. `:227` **foam:** `+= watershade*coastfade*(1-coastfade2)*((.5,.6,.7)*nautic(uv)+(1,1,1)*particles(uv))`.
13. `:229-230` **mix/alpha:** `rescolor=mix(rescolor,watercolor,coastfade)`; `resalpha=coastfade2`.
14. `:232` `fragColor=vec4(rescolor,resalpha*1.0)`; `:259-261` `main` calls `fogmap` then `gl_FragColor`.

**Fog handling (`:237-253`, observed).** `fogmap(fragcolor)` is applied **after**
the composite: `if (fogEnabled>0) { f=1; mode 1 LINEAR clamp((gl_Fog.end-fogFragCoord)*gl_Fog.scale,0,1); mode 2 EXP clamp(exp2(-density*w*1.442695),0,1); mode 3 EXP2 clamp(exp2(-pow(density*w,2)*1.442695),0,1); fragcolor.xyz=mix(gl_Fog.color.xyz,fragcolor.xyz,f); }`. `fogFragCoord` from `water.dev.vert:23-27` (ATI `abs((MV*pos).z)`, else `length(MV*pos)`). Default `FogMode=0` (`colors.lib:36`) → fog off; this is why the port's `fog_enabled=0` is faithful.

**Note on the requested shorthand.** The task's "level → height → discard → …"
ordering compresses steps 2–5: jittered `level` (`:175`) is computed **after**
`height` (`:170`), while the raw `WATER_LEVEL` (`:167`) precedes it. O1 §5.3
already reflects the exact source order; no correction is needed to O1.

---

## 5. Port comparison (read-only)

### 5.1 Faithful (donor-grounded)

| Donor | Port | Label |
|---|---|---|
| `water.dev.frag:37-47,168` constants 0.57/1.07/170/120/30/colours | `water3d.gd:19-29`; `water3d.gdshader:27-36` | **observed** |
| `water.lib:25,32-33` HDR=1, TexScale 0.1/0.01 | `water3d.gd:24-26,153-155`; shader `:29-30,37` | **observed** |
| `waveMap` → `diffusewaves0.bmp` (`water.lib:44`, `water.mat:7,11`) | `water3d.gd:81,172-177` binds shipped `diffusewaves0.png`; shader `:41,64-67` | **observed** |
| `water_map` 9-octave fBm, `nautic`, `particles` (`:83-127`) | shader `:62,79-131` (structure/M literals verbatim) | **observed** |
| fragment order steps 2–13 above | shader `:149-220` in the same order | **observed** |
| `texture2DProj(reflectionMap,…)` + HDR gain (`:207-213`) | shader `:184-189` equation (mechanism substituted, §5.2) | **observed** (equation) |
| shadowed≠1 → `watershade=1` (`:129-143`) | shader `:201-203` `watershade=1.0` | **observed** (donor branch) |
| `resalpha=coastfade2` (`:230`) | shader `:220` `ALPHA=coastfade2` | **observed** |
| fog modes 2/3 + `1.442695` (`:245-249`), default off (`colors.lib:36`) | shader `:222-231`; `water3d.gd:70-71,163-165` | **observed** |
| legacy `.bak` Fresnel **not** from `.dev` (`:203-206` commented) | shader does not wire Fresnel | **observed** for `.dev`; see §6 |
| flat passthrough vertex (`water.dev.vert:14-29`, no displacement) | `water3d.gd:181-204` 4-vertex plane | **observed** |
| height-aware integration: `bind_height_grid()` | `world3d_terrain.gd:528-544,762-764` builds one `WaterPlane`, binds live `height[]` | **observed** (port) |

### 5.2 Substitutions / port-only

| Donor binding or equation | Port substitute | Evidence | Label |
|---|---|---|---|
| `hmapTex` engine sampler + `hmapMin/Max` | `height_tex` from port height grid; `-max_height + a*2*max_height`; neutral 1×1 α=0 fallback | shader `:44,69-76`; `water3d.gd:113-121,248-264` | **UNVERIFIED** donor binding; port substitute |
| `hmapW`/`hmapH` | `map_size.x/.y` | shader `:53,166`; `water3d.gd:166,261` | **UNVERIFIED** donor value |
| `texture2DProj(reflectionMap, gl_TexCoord[0].xyw - wavejitter*w)` | `SCREEN_UV + wavejitter`, gated `reflection_enabled=0` | shader `:181-189`; `water3d.gd:168,178` | **UNVERIFIED** FBO; port approximation |
| `CalcTerrain` 4 height taps + `col*=grad+grad^8` + 3-tap PCF (`:145-160,196`) | only bed colour `terrain_map` kept | shader `:133-139` | port omission |
| `test_shadow()` 3-tap PCF (`:129-143`) | `watershade=1.0` (donor unshadowed branch) | shader `:201-203` | **UNVERIFIED** sampler; donor branch used |
| `pow(grad,N)` domain | `max(grad,0)` / `max(gradpos,0)` guards | shader `:194-200` | port guard |
| foam `nautic+particles` only | extra `shore_prox = 1-smoothstep(water_level,shore_height,level)` multiplier | shader `:209-217` | **PORT ART** (donor fragment never reads −0.1) |
| fog mode 1 LINEAR (`gl_Fog.end/scale`) | not ported; `v_fog_depth=-view_pos.z` substitutes for view-space w | shader `:222-231`, `:141-145` | port omission/substitute |
| `large_waveheight` term with `waveheight=clamp(-0.25*3-1.5,0,1)=0` | kept at 0 (not retuned) | shader `:153-157`; `water3d.gd:229-231` | **derived donor-faithful consequence** |
| metres per cell | `TILE_M=2.0` | `water3d.gd:74` | port-only (donor UNVERIFIED) |

**Derived note on `shore_prox`:** with donor literals `waveheight=0`, `water_map`
returns `0 + f*0.5` where `f` is a sum of non-positive terms, so `level ≤ -0.25`.
Since `shore_prox = 1 - smoothstep(-0.25, -0.1, level)` and `level ≤ -0.25`,
`shore_prox = 1` for every rendered fragment. The port-art multiplier is
therefore **inert** under the shipped constants and cannot by itself explain a
T2 foam difference. (**derived** from shader `:156-157,214` + donor `:95,100-103`.)

---

## 6. Corrections to prior docs

1. **O3 §2 / O3 §8 Q1 / O1 §8 Q10 / O2 §8 #1 — `hmapTex` binding.** Strength
   from "UNVERIFIED" to **negatively resolved for the `heightmapwaves0.tga`
   hypothesis**. Whole-tree byte search finds the asset name only at
   `water.mat:92` and `water.lib:45`, both commented; 0 hits in `cossacks.exe`
   and `codex.dll`. There is no readable datum that identifies
   `heightmapwaves0.tga` as `hmapTex`. The **engine binding itself** stays
   UNVERIFIED — absence of evidence is not evidence of a different source.
2. **O1 C22 / O2 §4 — "DiffuseWaves2 not bound" imprecision.** `DiffuseWaves2`
   is **actively configured** (`water.lib:43`, `water.mat:32-39`), not commented.
   Correct wording: configured as `NormalMapLibMaterialName` but **no matching
   sampler in `water.dev.frag`**; GPU upload UNVERIFIED. DiffuseWaves1/3-7 are
   the genuinely commented ones.
3. **O2 §8 #3 / O4 §6.4 — "Fresnel commented out" is too broad.** It is true for
   the shipped `water.dev.frag:203-206`, but `cossacks.exe` **embeds the legacy
   `.bak` water shader source** at file offsets `0x453F00-0x454E1F` (VA
   +`0x400C00`), where `fresnel = clamp(fresnelBias+pow(facing,fresnelPower),0,1)`
   at `0x45494C` and `reflecColor = mix(waterColor,reflecColor,fresnel)*reflectionAmount`
   at `0x454C28` are **live**, and vertex waves use `waveFreq/waveAmp/waveDir0/1`
   with `NWAVES 2` (`0x454117-0x45421F`). The embedded source matches
   `water.vert.bak`/`water.frag.bak` (byte-compared). `water.lib:67-68` pins the
   `.dev` pair, so the port's non-wiring of Fresnel remains correct for the
   selected config; the claim must simply be scoped to that pair.
4. **O3 §3c — binary offsets.** O4's VA values (`hmapTex` key `0x853e0c`) map to
   file offsets by subtracting **0x400C00** (independently verified: key string at
   `0x45320C`; instruction at `0x452FDB` = VA `0x853BDB`; `call` target decodes
   to `0x405454`). No error in O4; recorded to make re-verification reproducible.
5. **`waves1/3-7` file existence.** All eight `diffusewaves*.bmp` and
   `heightmapwaves0.tga` exist on disk; "not bound" refers to config/comments,
   not to missing files (directory census confirms sizes 196,662 / 786,486 /
   258,506 B).
6. **`water.frag` alternate is materially different.** `water.frag:246` samples
   `hmapTex` at `gl_TexCoord[3].xy` (the shadow coord) and `:3` uses
   `iglobaltime=time*3.0`, with different watercolor literals (`:29-30`
   `(0.43,0.60,0.66)` / `(0.06,0.07,0.11)`). It is **not** pinned by `water.lib`;
   do not mix its constants into the `.dev` ledger.

No correction was needed to the numeric constants of O1 C23, O2 §3, O3 §3c or
O4 §6.2 — all re-read verbatim and matched.

---

## 7. Implications for terrain+shore piece test T2

T2 acceptance (O5): exactly one height-aware water plane; shore tile ids in the
UV2 histogram; water pixel band + alpha coverage; **full-width dark rows = 0**;
two frames 1 s apart show animation; land above water not tinted; donor literals
−0.25/−0.1/2.96 read back.

1. **Binding labels in the T2 capture.** `water3d.gd:223-231` already reports
   `height_aware`, `hmap_min_max` = "PORT APPROXIMATION", and
   `waveheight_from_donor_literal` = 0. T2 should assert these strings, and must
   **not** report the height grid as a recovered donor `hmapTex` binding. (**observed**)
2. **Height awareness is mandatory for "land above water not tinted".** Donor
   discards where `height>level` (`water.dev.frag:176-183`); port `discard` at
   shader `:158-160` only engages if `bind_height_grid()` ran. Integration does
   call it (`world3d_terrain.gd:538`), and the neutral fallback (`water3d.gd:118-121`,
   α=0 → `hmapMin`) would give full coverage and re-create the dark/green row
   artifact. T2 should assert `stats["height_aware"] == true` and
   `stats["wave_tex_path"]` resolves. (**observed/derived**)
3. **Animation will be low-amplitude but non-zero.** `waveheight=0` zeroes the
   coarse swell term (`water.dev.frag:95`); fine 9-octave `shift1/shift2`,
   `nautic` and `particles` still advance with `time` (`water3d.gd:95-99`). A
   two-frame delta test should pass, but a "big rolling swell" is **not** donor
   fidelity at −0.25; do not retune `water_level` to the 2D app's 1.0. (**derived**)
4. **Shore alpha/foam band.** `alpha=coastfade2` reaches 0 at the waterline and 1
   at 1.07 m (`frag:199,230`); foam occupies only `coastfade*(1-coastfade2)`
   (`frag:227`). Port implements both (`shader:176-177,216-220`). The extra
   `shore_prox` is inert under donor literals (§5.2), so any visible shore
   over-brightness must be sought elsewhere (e.g. reflection off, PCF absent),
   not in that multiplier. (**derived**)
5. **No foam image.** Donor foam is procedural; do not add a foam texture to T2
   as "donor-faithful" (whole-tree texture census: no foam asset). (**observed**)
6. **One plane only.** `_make_water3d()` renames `WaterPlane3D` → `WaterPlane`
   and replaces the old quad; the flat `StandardMaterial3D` quad is a fallback
   only (`world3d_terrain.gd:760-764`). T2 should still assert a single water
   mesh instance because both code paths exist. (**observed**)
7. **No reflection / no shadows in T2.** `reflection_enabled=0` (`water3d.gd:168`)
   and `watershade=1.0` are faithful to the *selected* `.dev` config's
   unshadowed branch, but they are not full engine parity. Do not read a missing
   glint/contact shadow as a regression of the constants. (**observed**)
8. **Fog off is correct for the default palette.** `colors.lib:36 FogMode=0`;
   T2 should keep `fog_enabled=0` and not treat absent LINEAR fog as a defect.
   (**observed**)

---

## 8. Open questions

1. **Which texture is actually uploaded to `hmapTex` by the engine?** The
   `+0x54` string-key assignment and `fHMapTex` uniform slot are proven; the
   texture/unit bind is not. `heightmapwaves0.tga` is disproved as a *text*
   candidate but an engine-generated height surface remains plausible
   (**inferred**, **UNVERIFIED**).
2. **Runtime `hmapMin`, `hmapMax`, `hmapW`, `hmapH` values.** No numeric defaults
   in binary; no text assignment. Port ±2.96 is a labelled approximation.
3. **`reflectionMap` source** — projected FBO vs cube map vs legacy path; three
   different water shader families exist (`.dev`, alternate `water.frag`,
   embedded `.bak`). Which family ships in a given scene is **UNVERIFIED** even
   though `water.lib:67-68` pins `.dev`.
4. **Whether `DiffuseWaves2` is uploaded at all** — active config, no `.dev`
   sampler. (**UNVERIFIED**)
5. **Whether `texturemap.inc:29-31` / `generatemap.inc:4-7` commented branches
   execute in the retail build** — text intent only. (**UNVERIFIED**)
6. **Exact engine mapping palette `FogMode` → `fogEnabled` int** — the default
   0 is text-proven; the mapping is engine-side. (**UNVERIFIED**)
7. **Visual parity** — no GPU A/B capture was taken by this lane; all port
   judgements are structural. (**UNVERIFIED**)

---

## 9. Summary

Donor text is decisive for the wave asset and shader math, and silent for the
engine bindings. `waveMap` is explicitly sourced from `diffusewaves0.bmp`
(`water.lib:44` + `water.mat:7,11`); `DiffuseWaves2` is actively configured as a
normal-map library material but has no `.dev` sampler; DiffuseWaves1/3-7 are
commented. `watercolor`, `coastfade`, `nautic` and `particles` are fully readable
GLSL locals/functions. `hmapTex`, `hmapMin/Max`, `hmapW/H`, `reflectionMap` and
`fogEnabled` appear only as shader uniforms plus engine name tables and a
Delphi string-key assignment at `cossacks.exe` VA `0x853BDB` — their texture/FBO
and numeric bindings are **UNVERIFIED**.

The `heightmapwaves0.tga = hmapTex` hypothesis is **resolved negatively** for
readable data: the filename exists only in the fully commented `water.mat:86-106`
block (all 21 lines byte-verified to start with `//`) and the commented
`water.lib:45`, with **zero** occurrences in `cossacks.exe` or `codex.dll`. The
port's height-grid `hmapTex` substitute is correctly labelled; it is not a
recovered donor binding.

All constants in `water.dev.frag:37-47`, `water.lib` and `texturemap.inc:29-31`
were re-read verbatim and match the prior ledgers. Fragment order is
`WATER_LEVEL → height → waveheight/level → discard → wave normals/jitter →
CalcTerrain → coastfade/depth tint → commented-Fresnel reflection → specular →
foam → mix/alpha → fog`, with fog applied **after** composite and off by default
(`FogMode=0`).

For T2 the port is structurally faithful, with three labelled deviations: the
height-grid `hmapTex`/`map_size` substitutes, the inert `shore_prox` port-art
multiplier, and omitted reflection/PCF/LINEAR-fog paths. None of these is a new
donor constant; none should be reported as one.

*End of RV-TRN-03. One report written; no donor binary executed/copied; no code,
asset, config, test, runner or git state changed; visual parity not claimed.*
