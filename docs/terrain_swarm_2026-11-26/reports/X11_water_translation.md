---
id: X11
wave: X (design / translation spec; spawned into the 30-agent DONOR-FIRST terrain swarm)
ticket: "Implementation-ready donor→Godot translation spec for water/shore, from D06 verbatim evidence"
date: 2026-11-26
status: DELIVERED__DESIGN_ONLY__NO_CODE_OR_ASSET_EDIT__NO_GODOT_JOB
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; private use; no donor binary executed, no donor file copied into repo, no git/source/Godot edit)"
target_used: "None. All donor facts are transcribed from reports/D06_water_shore.md (verbatim evidence, its Evidence table and path:line citations) and re-verified by direct READ-ONLY text reads of data/shaders/water/water.dev.frag, water.dev.vert and data/water/water.mat this ticket. No Craft Anything target opened or changed."
prior_art_read: "CHARTER.md, SWARM_BOARD.md, reports/D06_water_shore.md, spec/README.md (05 pending), spec/06_TILE_AND_ATLAS.md, variant3d/shaders/water3d.gdshader, variant3d/scripts/water3d.gd"
multi_pass: true
visual_parity_claim: false
---

# X11 — donor water shader translation spec (2026-11-26)

## 0. Scope and authority

This report is **design only**. It writes exactly one file (this one). No source,
shader, config, asset, test, Godot job or git state was touched. The donor is
read-only; no donor binary was executed. Every donor claim carries a donor
`path:line` citation; the D06 evidence ids are carried through as the chain of
custody. **No donor visual parity is claimed** — there is no donor GPU A/B frame.

Label key (charter §4): `[O]` observed bytes/lines/instructions · `[D]` derived
arithmetic/control-flow · `[I]` interpretation · `[U]` UNVERIFIED ·
`PORT APPROXIMATION`.

---

## 1. Executive summary

1. **[O] The shipped donor pair is `water.dev.frag` + `water.dev.vert`, pinned by `data/water/water.lib:67-68` (D06 §2, P17).** I re-read both files verbatim this ticket. Every constant and equation the task asks for is present at a concrete line; §3 below quotes them with line numbers. The descriptor initializer `FUN_00853ad4` (`cossacks.exe` VA `0x853ad4`) assigns 30 uniform **key names**, with `hmapTex` at `+0x54`, and **performs no texture lookup** (D06 §5.1, P4–P13). `hmapTex` is therefore a *parameter key* whose engine binding is `[U]`, not a recovered texture.
2. **[O]/[D] The port (`variant3d/shaders/water3d.gdshader`, `water3d.gd`) is a close structural port of the donor fragment**: coast/deep fades 0.57/1.07, exponents 170/120, particle 30, three colours, `mat2(0.72,-1.60,1.60,0.72)`, both shift vectors, the 9-octave chop, nautic/particles, specular corona divides and alpha ramp are all present at the donor's numeric values (§4, faithful rows). The structural differences are explicitly labelled in-file and almost all reduce to three classes: (a) **PORT APPROXIMATION** substitutes for `[U]` engine bindings (`height_tex`, `map_size`, `water_surface_y`, `reflection_map`, `SCREEN_UV`), (b) **PORT GUARD** additions the donor does not have (`water_cell` alpha gate, `pow` domain `max()`, foam fast-path), and (c) **MISSING** donor stages (`CalcTerrain` 4-tap normal/`grad+grad^8`, 3-tap `test_shadow`, fog mode 1, tile-side shore painting, tile-smoothing passes).
3. **[O] `heightmapwaves0.tga` cannot be `hmapTex`**: alpha is 255 on all 65,536 pixels (D06 P18) and its entire material block is commented (`water.mat:86-106`, verified this ticket: lines 86–106 all begin `//`). The fresh module must keep `hmapTex` as an open parameter key and **never bind a wave texture to it**. The only donor wave sampling is `waveMap` at `water.dev.frag:5,65-68`, whose donor asset is `diffusewaves0.png` (`water.mat:7,11`, already shipped in the port).
4. **[O] Three distinct water levels must stay separate** (D06 §3.1): `−1.1` basin (`generatemap.inc:7`), `−0.5` generated field Y (`generatemap.inc:688,704`), `−0.25/−0.1` tile classification (`texturemap.inc:29-31,463-472`), plus the shader plane Y `gl_TexCoord[1].z` (`water.dev.vert:18`) whose numeric runtime value is `[U]`. The port correctly decouples the shader plane from the `-0.25` classification literal (`water3d.gd:36`, `water3d.gdshader:32,161`).
5. **[U] `TileSmoothPasses=6` vs `SmoothTileMap(...,3)` is a preserved, multi-passed contradiction** (§7.2): my three independent read-only passes this ticket reproduce D06 P22 — config says 6 (`globalparams.cfg:9`), the only live script call says 3 (`smoothtiles.inc:237`), the C++ path is commented (`generatemap.inc:784`), and no readable consumer of the config key exists. Follow the script for skirmish (SWARM_BOARD C2) but do **not** promote 6 to donor truth.

The remainder gives the verbatim quote set (§3), the line-by-line port comparison (§4), Godot shader pseudocode for the fresh module (§5), GDScript pseudocode for shore/cliff tile selection (§6), the water-level/contradiction ledger (§8), and the inputs to pending `spec/05_WATER_SHORE.md` (§9).

---

## 2. Evidence table

All donor reads this ticket were direct, read-only text reads (no target open, no binary run). D06 ids are the original chain of custody.

| Source (authoritative citation) | D06 evidence id | What it establishes |
|---|---|---|
| `data/shaders/water/water.dev.frag:1-110` (read this ticket) | `ev_642dcfbb…` (frag `:1-50`), `ev_a22c66b4…` (frag `:61-105`) | Sampler/uniform block, commented Fresnel/DeepColor inputs, coast fade 0.57 (:37), exponents 170/120 (:42-43), particle 30 (:44), colours (:45-47), `noise` (:65-68), `height_map` (:70-75), `terrain_map` (:77-81), `mat2` (:83), `water_map` shifts (:88-89) and 9-octave loop (:100-103). |
| `water.dev.frag:111-260` (read this ticket) | `ev_99fde295…` (frag `:165-234`) | `nautic`/`particles` (:106-127), `test_shadow` (:129-143), `CalcTerrain` (:145-160), `mainImage` plane Y / discard / fades / normals / reflection / glints / foam / alpha (:167-232), `fogmap` (:237-253). |
| `data/shaders/water/water.dev.vert:1-30` (read this ticket) | `ev_532af483…` | Flat passthrough, hmap UVs `MultiTexCoord/hmapW-0.5` (:16-17), `gl_TexCoord[1].z = pos.y` (:18), `lightVector` (:22); **no displacement**. |
| `data/water/water.mat:86-106` (read this ticket) | `ev_2c666225…` (`:1-106`) | `HeightMapWaves0` block fully commented (all 21 lines begin `//`); `Image = heightmapwaves0.tga` (:92), `TextureFormat = tfNormalMap` (:96), `Name = HeightMapWaves0` (:100). |
| `data/water/water.lib:67-68` (via D06 §2/P17) | `ev_53377109…` | Pins the shipped pair `water.dev.vert`/`.frag`. |
| `cossacks.exe` VA `0x853ad4` file `0x453ad4` (D06 §5.1, P4–P13) | `ev_4ddab2aa…`, `ev_ac379e04…`, `ev_5a3356c0…` | 30 string-key assignments; `hmapTex` at `+0x54`, key pointer `0x853E0C` referenced once (`lea eax,[ebx+0x54]; mov edx,0x853e0c; call 0x405454`); f32 `1.99999988` at `+0x7c`; **no bind**. |
| `heightmapwaves0.tga` TGA decode (D06 P18) | — | 256×256, 32 bpp, type 10 RLE, alpha min=max=255 over 65,536 px. |
| `generatemap.inc:7,218-245,560-574,580-707` (D06 §3–§4) | `ev_f4f0e5d0…` | Three levels, `_misc_SmoothTerrainCustom` passes S0/S1/S2. |
| `texturemap.inc:426-447,463-529,557-610` (D06 §7) | `ev_461b4b9d…` | Shore gate, 8×45° sectors (`sandsea1/5/6`), cliff 6-branch table and `|h|` overrides. |
| `tilesmooth_scripts.cfg:5-36` (D06 §4.3) | `ev_f5d967c5…` | Smoothing Prob: `sandsea1-4=1`, `sandsea5=0.7`, `sandsea6=0.3`, `rock9/8/5=0`. |
| `globalparams.cfg:9`, `smoothtiles.inc:191,237`, `generatemap.inc:784` (re-grepped this ticket) | `ev_bcc394ee…`, `ev_d1d7ea48…` | `TileSmoothPasses=6` (only occurrence), `SmoothTileMap(...,3)` live, `MapGeneratorSmoothTiles` commented; no consumer of the config key. |
| `variant3d/shaders/water3d.gdshader:1-279`, `variant3d/scripts/water3d.gd:1-321` (read this ticket) | — | Port implementation audited line-by-line in §4. |

---

## 3. Donor constants and equations — verbatim quotes with line numbers

### 3.1 Uniform block and live constants (`water.dev.frag`) `[O]`

```
:5   uniform sampler2D waveMap;
:6   uniform sampler2D reflectionMap;
:8-16 //uniform vec4 deepColor; //uniform vec4 shallowColor; //uniform float reflectionAmount;
      //uniform float waterAmount; //uniform float fresnelPower; //uniform float fresnelBias;
      uniform float hdrMultiplier; //uniform float distFactor; //uniform float bumpFactor;
:18  uniform sampler2D hmapTex; //sampler2DRect
:19  uniform float hmapMin;
:20  uniform float hmapMax;
:21  uniform int hmapW;
:23  uniform int fogEnabled;
:37  float coast2water_fadedepth  = 0.57;        // COAST FADE
:38  float large_waveheight       = 0.50;
:39  float large_wavesize         = 2.;
:40  float small_waveheight       = .5;
:41  float small_wavesize         = .5;
:42  float water_softlight_fact   = 170.;        // SOFT exponent
:43  float water_glossylight_fact = 120.;        // GLOSSY exponent
:44  float particle_amount        = 30.;         // PARTICLE 30
:45  vec3  watercolor             = vec3(0.1, 0.24, 0.24);
:46  vec3  watercolor2            = vec3(0, 0.025, 0.05);
:47  vec3  water_specularcolor    = vec3(0.4, 0.4, 0.4);
```

`[D]` The eight `//`-prefixed uniforms at `:8-16` are declared-but-inactive in the
shipped fragment; wiring them would invent donor behaviour (D06 §6.2).

### 3.2 Core equations `[O]`

```
:65-68  float noise(vec2 p){ return texture2D(waveMap, p*vec2(1./256.)).x; }
:70-75  float height_map(vec2 p){
            vec4 v=texture2D(hmapTex, p);                 // HMAP DEPTH TEST source
            float h=hmapMin+v.w*(hmapMax-hmapMin);
            return h;
        }
:77-81  vec3 terrain_map(vec2 p){
            return vec3(0.175, .1375, .1)+texture2D(waveMap, p*8.).rgb*.25;
        }
:83     const mat2 m=mat2(0.72, -1.60,  1.60,  0.72);     // ROTATION/SCALE
:87     vec2 p2=p*large_wavesize;                         // = p*2
:88     vec2 shift1=0.001*vec2(iglobaltime*160.0*2.0, iglobaltime*120.0*2.0); // (0.32t, 0.24t)
:89     vec2 shift2=0.001*vec2(iglobaltime*190.0*2.0, -iglobaltime*130.0*2.0); // (0.38t, -0.26t)
:92-94  float f=0.6000*noise(p); f+=0.2500*noise(p*m); f+=0.1666*noise(p*m*m);
:95     float wave=sin(p2.x*0.622+p2.y*0.622+shift2.x*4.269)*large_waveheight*f*height*height;
:97-103 p*=small_wavesize; f=0.; amp=1.0; s=.5;
        for(i=0;i<9;i++){ p=m*p*.947; f-=amp*abs(sin((noise(p+shift1*s)-.5)*2.));
                          amp=amp*.59; s*=-1.329; }
        return wave+f*small_waveheight;
:109-114 nautic: p*=18.; 3 iters (p=m*p*1.2; amp*=.5; s*=-1.227); return pow(1.-f, 5.);
:121-126 particles: p*=200.; 3 iters (same 1.2/.5/-1.227); return pow(f*.35, 7.)*particle_amount;
:129-143 test_shadow(): 3-tap shadow2DProj PCF, shadowColor.x*0.7 blend
:145-160 CalcTerrain(): terrain_map + 4 hmap taps -> norm; col*=grad+pow(grad,8.); shadow mix
```

`[D]` `:88` evaluates to `(0.32t, 0.24t)` and `:89` to `(0.38t, −0.26t)`; the port
re-expresses them as `0.001*vec2(time*160*2, time*120*2)` (shader `:89`) and
`0.001*vec2(time*190*2, -time*130*2)` (shader `:90`) — identical constants.

### 3.3 `mainImage()` wet/dry, fades, composite (`water.dev.frag:162-232`) `[O]`

```
:165  vec2 uv=fragCoord.xy;
:167  float WATER_LEVEL=gl_TexCoord[1].z;              // plane Y from VERT :18
:168  float deepwater_fadedepth=0.5+coast2water_fadedepth;  // DEEP FADE 1.07
:170  float height=height_map(uv);                     // HMAP DEPTH TEST
:174  float waveheight=clamp(WATER_LEVEL*3.-1.5, 0., 1.);
:175  float level=WATER_LEVEL+.2*water_map(uv*15.+vec2(iglobaltime*.1), waveheight);
:176-183 if (height>level) { fragColor=vec4(0.0); return; }   // discard
:186  vec2 dif=vec2(.0, .01);
:187  vec2 pos=uv*15./texScaleS*(hmapW/128.0)+vec2(iglobaltime*.01);
:188-192 h1..h4 = water_map(pos±dif, waveheight); normwater=normalize(vec3(h3-h4,h1-h2,0.15));
:193  vec2 wavejitter=normwater.xy*texScaleT*(level-height);
:198  float coastfade=clamp((level-height)/coast2water_fadedepth, 0., 1.);      // 0.57
:199  float coastfade2=clamp((level-height)/deepwater_fadedepth, 0., 1.);       // 1.07
:200  float intensity=rescolor.r*.2126+rescolor.g*.7152+rescolor.b*.0722;
:201  watercolor=mix(watercolor*intensity, watercolor2, smoothstep(0.,1.,coastfade2));
:207-213 reflection: texture2DProj(reflectionMap, refuv); refcol.xyz*=(r+g+b)*hdrMultiplier; watercolor+=refcol.xyz;
:215-221 r0=vec3(uv,WATER_LEVEL); rd=normalize(light-r0); grad=dot(normwater,rd);
        specular=pow(grad, water_softlight_fact); specular2=pow(grad, water_glossylight_fact);
        gradpos=dot(vec3(0,0,1),rd); specular1=smoothstep(0.,1.,pow(gradpos,5.));
:222-226 watershade=test_shadow(uv,level); watercolor*=2.2+watershade;
        watercolor+=(.2+.8*watershade)*((grad-1.0)*.5+specular)*.25;
        watercolor/=(1.+specular1*1.25); watercolor+=watershade*specular2*water_specularcolor;
:227  watercolor+=watershade*coastfade*(1.-coastfade2)*(vec3(.5,.6,.7)*nautic(uv)+vec3(1,1,1)*particles(uv));
:229  rescolor=mix(rescolor, watercolor, coastfade);
:230  resalpha=coastfade2;
:232  fragColor=vec4(rescolor, resalpha*1.0);
:237-253 fogmap(): mode 1 (gl_Fog.end/scale), 2 (exp2(-d*f*1.442695)), 3 (exp2(-pow(d*f,2)*1.442695)); default 0.
```

Vertex (`water.dev.vert`) `[O]`: `:2-3` `hmapW/hmapH`, `:16-17` `gl_TexCoord[1].xy =
MultiTexCoord/hmapW-0.5`, `:18` `.z = pos.y`, `:21-22` eye/light vectors, `:29`
`ftransform()`. **No hmap-driven displacement.**

### 3.4 `water.mat:86-106` bindings `[O]`

```
86: //section.begin        92: // Image = .\data\water\textures\heightmapwaves0.tga
87: //   Material : struct.begin   96: // TextureFormat = tfNormalMap
88: //      Texture : struct.begin  100: // Name = HeightMapWaves0
... (all 21 lines 86-106 are comment-prefixed) ...
106: //section.end
```

`[D]` Combined with D06 P18 (alpha 255 everywhere) and P15 (0 byte hits in both
binaries), this disproves any `heightmapwaves0.tga → hmapTex` binding. The live
wave asset is `DiffuseWaves0` (`water.mat:7,11`, `tfLuminance`), as the port already
uses (`water3d.gd:97`).

---

## 4. Port comparison — line by line

### 4.1 Donor-faithful (numeric/structural match) `[O]/[D]`

| Donor | Port | Status | Note |
|---|---|---|---|
| `frag:37` 0.57 | `gdshader:35,162,208`, `gd:38` | faithful | coast fade |
| `frag:168` 0.5+0.57=1.07 | `gdshader:36,162,209`, `gd:39` | faithful | deep fade |
| `frag:42-43` 170/120 | `gdshader:42-43,229-230`, `gd:43-44` | faithful | glint exponents |
| `frag:44` 30 | `gdshader:44,138`, `gd:45` | faithful | particle amount |
| `frag:45-47` colours | `gdshader:39-41`, `gd:80-82` | faithful | `(0.1,0.24,0.24)`/`(0,0.025,0.05)`/`(0.4,0.4,0.4)` |
| `frag:83` mat2 | `gdshader:70`, `gd`:— | faithful | `mat2(0.72,-1.60,1.60,0.72)` |
| `frag:88-89` shifts | `gdshader:89-90` | faithful `[D]` | re-expressed as `0.001*(t*160*2,…)` = same constants |
| `frag:65-68` noise | `gdshader:73-75` | faithful `[D]` | `fract` dropped; `repeat_enable` wrap; sampler is donor-derived `diffusewaves0.png` |
| `frag:85-104` water_map | `gdshader:87-109` | faithful | weights 0.6000/0.2500/0.1666, 9 iters, 0.947/0.59/−1.329, 0.622, 4.269 |
| `frag:106-127` nautic/particles | `gdshader:112-139` | faithful | 18/200, 3 iters, 1.2/0.5/−1.227, `pow(1-f,5)`, `pow(f*.35,7)*30` |
| `frag:77-81` terrain_map colour | `gdshader:145-147` | faithful | `vec3(0.175,0.1375,0.1)+waveMap(p*8).rgb*0.25` |
| `frag:174-175,176-183` waveheight/level/discard | `gdshader:169,180,181-183` | faithful | `clamp(3Y-1.5,0,1)`, `+0.2*water_map`, `height>level→discard` |
| `frag:186-194` normal/jitter | `gdshader:195-205` | faithful | dif (0,0.01), 4 taps, z 0.15, jitter |
| `frag:198-201,215-226,229-230` fades/composite/alpha | `gdshader:208-211,223-239,259,264` | faithful | luma, `mix`, corona divides, `alpha=coastfade2` |
| `frag:227` foam | `gdshader:253-257` | faithful `[D]` | `vec3(particles)` broadcast ≡ `vec3(1,1,1)*particles`; `shore_prox` removed correctly |
| `frag:242-250` fog modes 2/3 | `gdshader:269-275` | faithful | `1.442695`; mode 1 deliberately unported |
| `vert:12-30` flat passthrough | `gdshader:149-153` | faithful `[D]` | no displacement |
| `light.cfg:26-29`+`vert:22` sun | `gd:83-85` | faithful `[D]` | `(-0.0861828,0.9387015,0)` Y-up conversion |

### 4.2 PORT APPROXIMATION — known `[U]` donor bindings substituted

| Donor | Port | Why approximation |
|---|---|---|
| `frag:18,70-75` `hmapTex` bind | `gdshader:52,82` `height_tex` (neutral 1×1 alpha=0 by default); `gd:129-137,305-321` binds a normalised height grid into alpha | Donor key at descriptor `+0x54` has **no texture bind** (D06 §5.1). Port `height_tex` is a labelled substitute; `hmapMin/hmapMax = ±MAX_HEIGHT` from `texturemap.inc:29` span is also PORT APPROX. |
| `frag:19-21` `hmapMin/hmapMax/hmapW/hmapH` UNVERIFIED | `gdshader:37,61` `max_height=2.96`, `map_size` | Values are donor text literals, not proven shader uniforms. |
| `vert:18` plane Y `gl_TexCoord[1].z` UNVERIFIED | `gdshader:32,161` `water_surface_y`, `gd:36` `-0.25` placeholder | Only donor-readable number is the `-0.25` *classification* literal; A/B Y is labelled, never recovered truth. |
| `frag:207-209` projective `reflectionMap` | `gdshader:216-221` `SCREEN_UV`, `reflection_map` neutral, disabled by default | FBO provenance/GPU unit `[U]` (D06 §11 #5). |
| `frag:129-143,222` `test_shadow` | `gdshader:235` `watershade=1.0` | No shadow sampler; unshadowed donor branch taken. |
| `frag:145-160` `CalcTerrain` normal + `grad+grad^8` + shadow mix | `gdshader:145-147` bed colour only | Engine sampler/FBO bindings `[U]`; 4-tap hmap normal and contrast term not ported. |
| `vert:16-17` hmap UV space `MultiTexCoord/hmapW-0.5` | `gdshader:150` `v_height_uv = UV` (0..1) | Port uses plane UVs; donor height-UV space not reproduced. |
| `frag:187` `hmapW/128` | `gdshader:198` `map_size.x/128` | Port substitute for UNVERIFIED engine `hmapW`. |
| `render_mode unshaded` | `gdshader:21` | Donor assembles final colour; Godot lighting must not re-shade ALBEDO — structural port adaptation. |

### 4.3 PORT GUARD additions — not in the donor fragment (deliberate, labelled)

- `gdshader:192` `water_cell = 1.0 - step(water_level, height)` and `gdshader:264` `alpha = coastfade2 * water_cell`: confines alpha to masked water cells so low land is not tinted (port bug "full-width dark rows", P6/F6). Donor ramp is bit-exact **inside** water cells (D06 I1). `[D]` No donor equivalent; do not present as donor.
- `gdshader:177` early dry discard (`waveheight<=0 && height>WATER_LEVEL`), `gdshader:228` `max(grad,0.0)` pow-domain guard, `gdshader:253-257` `if (foam_band>0)` skip: performance/domain guards, output-equivalent under shipped constants (D06 I8). `[D]` PORT APPROXIMATION fast paths, not parity.

### 4.4 MISSING from the port (must be supplied by the fresh module or another owner)

1. **`CalcTerrain` 4-tap terrain normal, `col*=grad+pow(grad,8.)`, shadow mix** (`frag:145-160`) — only flat bed colour survives (`gdshader:145-147`). `[O]` MISSING / labelled PORT APPROX.
2. **3-tap `test_shadow()` PCF** (`frag:129-143`) — absent (`gdshader:235`). `[O]` MISSING.
3. **Fog mode 1** (`frag:242-243`) — needs `gl_Fog.end/scale`, unported. `[O]` MISSING (default mode 0 makes it inert in skirmish).
4. **True `hmapTex` engine binding** — `[U]`; not statically recoverable.
5. **Shore tile painting** (`sandsea1/5/6`, `texturemap.inc:463-529`) — **not in `water3d.gd`**; the module only holds a cross-owner note (`gd:296-304`) asking the terrain owner to remap masked water cells off atlas tile 0. `[O]` MISSING from the water path; D06 I5 → spec §06/§05 seam.
6. **Tile smoothing passes** (`smoothtiles.inc:191-237`) — **not implemented anywhere in `water3d.gd`**; belongs to the terrain/tile owner. Contradiction preserved (§7.2).
7. **`bind_height_grid()` integration** (`gd:283-294`) is documented but **not wired** by this module — it cannot edit `world3d_terrain.gd`; until wired, neutral full-coverage height texture remains. `[D]` MISSING integration.

**Verdict:** `[D]` The port is a faithful *fragment-equation* clone with explicitly labelled substitute bindings; it is **not** a complete donor water/shore chain. No parity claim (no A/B frame).

---

## 5. Godot shader pseudocode — fresh module (donor constants only)

Rules applied: every numeric literal below is donor-cited in §3; `hmapTex` stays an
**open parameter key** (not a texture lookup to be invented); `waveMap`/`reflectionMap`
are the only donor samplers; the height field arrives as an external parameter whose
source is `[U]`; no synthetic noise/dither field, no wave-texture binding.

```gdshader
shader_type spatial;
# Donor assembles a final colour; do not let Godot re-shade ALBEDO.
render_mode blend_mix, cull_disabled, unshaded;           # PORT adaptation

# --- donor uniform KEYS (water.dev.frag:1-33; FUN_00853ad4 +0x04..+0x78) ---
uniform sampler2D waveMap;        # frag:5  — donor asset diffusewaves0.png (water.mat:7,11)
uniform sampler2D reflectionMap;  # frag:6  — FBO provenance [U]
uniform sampler2D hmapTex;        # frag:18 / descriptor +0x54 — KEY ONLY, binding [U]
                                  # NEVER bind heightmapwaves0.tga (water.mat:86-106 commented; alpha=255)
uniform float hmapMin;            # frag:19 — runtime value [U]
uniform float hmapMax;            # frag:20 — runtime value [U]
uniform int   hmapW;              # frag:21 / vert:2 — runtime value [U]
uniform float time;               # frag:1 / iglobaltime :34
uniform float texScaleS;          # frag:2  (0.1, water.lib:32)
uniform float texScaleT;          # frag:3  (0.01, water.lib:33)
uniform float hdrMultiplier;      # frag:14 (1, water.lib:25)
uniform int   fogEnabled;         # frag:23 (0 default, colors.lib:36)
uniform float PLANE_Y;            # SLOT for gl_TexCoord[1].z (vert:18) — numeric [U]

# --- donor constants verbatim (§3) ---
const float COAST = 0.57;                       # frag:37
const float DEEP  = 0.5 + COAST;                # frag:168 -> 1.07
const float LWH   = 0.50; const float LWS = 2.0;  # frag:38-39
const float SWH   = 0.5;  const float SWS = 0.5;   # frag:40-41
const float SOFT  = 170.0; const float GLOSSY = 120.0; # frag:42-43
const float PARTICLE = 30.0;                    # frag:44
const vec3  WCOLOR = vec3(0.1,0.24,0.24);       # frag:45
const vec3  WCOLOR2= vec3(0.0,0.025,0.05);      # frag:46
const vec3  WSPEC  = vec3(0.4,0.4,0.4);         # frag:47
const mat2  M = mat2(vec2(0.72,-1.60), vec2(1.60,0.72)); # frag:83

float noise(vec2 p){ return texture(waveMap, p*(1.0/256.0)).x; } # :65-68
float height_map(vec2 p){ vec4 v=texture(hmapTex,p);            # :70-75
                          return hmapMin + v.w*(hmapMax-hmapMin); }
vec3 terrain_map(vec2 p){ return vec3(0.175,0.1375,0.1)         # :77-81
                          + texture(waveMap,p*8.0).rgb*0.25; }

float water_map(vec2 p, float height){                          # :85-104
  vec2 p2 = p*LWS;                                   # :87
  vec2 shift1 = 0.001*vec2(time*160.0*2.0, time*120.0*2.0); # :88 (0.32t,0.24t)
  vec2 shift2 = 0.001*vec2(time*190.0*2.0,-time*130.0*2.0); # :89 (0.38t,-0.26t)
  float f = 0.6000*noise(p) + 0.2500*noise(p*M) + 0.1666*noise(p*M*M); # :92-94
  float wave = sin(p2.x*0.622+p2.y*0.622+shift2.x*4.269)*LWH*f*height*height; # :95
  p *= SWS; f = 0.0; float amp=1.0, s=0.5;           # :97-99
  for (int i=0; i<9; i++){ p=M*p*0.947;              # :100-101
     f -= amp*abs(sin((noise(p+shift1*s)-0.5)*2.0)); amp*=0.59; s*=-1.329; }
  return wave + f*SWH;                               # :103
}
# nautic()/particles() verbatim :106-127 (p*=18 / p*=200; 3 iters;
#   p=M*p*1.2; amp*=0.5; s*=-1.227; pow(1-f,5.0) / pow(f*0.35,7.0)*PARTICLE)

void fragment(){
  float WATER_LEVEL = PLANE_Y;                       # :167 (vert:18) [U]
  float height = height_map(UV);                     # :170  <-- hmap depth test
  float waveheight = clamp(WATER_LEVEL*3.0-1.5, 0.0, 1.0); # :174
  float level = WATER_LEVEL + 0.2*water_map(UV*15.0+vec2(time*0.1), waveheight); # :175
  if (height > level) { discard; }                   # :176-183 (fragColor=vec4(0))

  vec2 dif = vec2(0.0,0.01);                         # :186
  vec2 pos = UV*15.0/texScaleS*(float(hmapW)/128.0)+vec2(time*0.01); # :187
  vec3 normwater = normalize(vec3(
      water_map(pos-dif.yx,waveheight)-water_map(pos+dif.yx,waveheight),
      water_map(pos-dif,waveheight)-water_map(pos+dif,waveheight), 0.15)); # :188-192
  vec2 uv = UV + normwater.xy*texScaleT*(level-height); # :193-194

  vec3 rescolor = terrain_map(uv);                   # :196 (CalcTerrain :145-160 is [U]/MISSING)
  float coastfade  = clamp((level-height)/COAST, 0.0, 1.0); # :198
  float coastfade2 = clamp((level-height)/DEEP,  0.0, 1.0); # :199
  float intensity = dot(rescolor, vec3(0.2126,0.7152,0.0722)); # :200
  vec3 watercolor = mix(WCOLOR*intensity, WCOLOR2, smoothstep(0.0,1.0,coastfade2)); # :201
  # reflection (:207-213): projective texture2DProj(reflectionMap, refuv);
  #   refcol.xyz *= (r+g+b)*hdrMultiplier; watercolor += refcol.xyz;  [U] bind
  # glints (:215-226): grad=dot(normwater,rd); pow(grad,SOFT)/pow(grad,GLOSSY);
  #   specular1=smoothstep(0,1,pow(dot(vec3(0,0,1),rd),5));
  #   watercolor*=2.2+watershade;
  #   watercolor+=(.2+.8*watershade)*((grad-1.0)*.5+specular)*.25;
  #   watercolor/=(1.0+specular1*1.25);
  #   watercolor+=watershade*specular2*WSPEC;
  watercolor += watershade*coastfade*(1.0-coastfade2)
              * (vec3(0.5,0.6,0.7)*nautic(uv) + vec3(particles(uv))); # :227
  rescolor = mix(rescolor, watercolor, coastfade);   # :229
  # fogmap (:237-253): mode 2/3 via exp2(-d*f*1.442695); mode 1 needs gl_Fog.*
  ALBEDO = rescolor;
  ALPHA  = coastfade2;                               # :230 (no floor; no water_cell gate invented here)
}
```

`[D]` Note the deliberate **absence** of: Fresnel (`:8-13,203-206` commented in
donor), a current/direction grid (no donor uniform; `WaveDir0/1` are descriptor-only,
D06 §6.2), a wave texture bind to `hmapTex`, and any 2D `shore_prox`/alpha-floor
term. The fresh module exposes `hmapTex` as a parameter key; the integrating GDScript
binds the decoded height grid (a labelled derived asset), **not** `heightmapwaves0.tga`.

---

## 6. GDScript pseudocode — shore tile selection and cliff path

### 6.1 Wet-sand rim (`texturemap.inc:426-447,463-529`) `[O]`

```gdscript
# --- gradient (texturemap.inc:426-447) ---
lh = h(x-1,y); rh = h(x+1,y); th = h(x,y-1); bh = h(x,y+1)   # :426-429
dirX = lh-rh; dirY = th-bh                                   # :430-431
vecangle = 0.0
if VectorLength(dirX,0,dirY) > 0.01:                          # :432
    dirX/=len; dirY/=len
    vecangle = VectorAngle(1,0,0, dirX,0,dirY)                # :434
    if dirY < 0: vecangle = -vecangle                         # :435

# --- gate + 8x45° sectors (texturemap.inc:463-529) ---
if mask[x,y].b > 0:                                           # :463
    if h < -0.25:   bWater = true                              # :466-467 cWaterHeight
    elif h < -0.1:  bWaterShore = true                        # :469-470 cWaterShoreHeight
if bWater or bWaterShore:                                     # :472
    vecangle += 180.0                                         # :475
    cAngle = 45.0                                             # :476
    sector = int(floor((vecangle+22.5)/45.0)) % 8             # :479-501 equivalent
    # D06 §7.1 tile table — exactly THREE live textures:
    SECTOR_TILE := { "bR":"sandsea6", "bRB":"sandsea6", "bB":"sandsea1",
                     "bLB":"sandsea5", "bL":"sandsea6", "bLT":"sandsea6",
                     "bT":"sandsea1", "bRT":"sandsea5" }      # :503-511
    newtile = SECTOR_TILE[sector_name(sector)]                # sandsea1/5/6 only
    if GetSeasonType == 2: newtile += "_winter"               # :512+
    SetTileIndex(x,y, MapGetTileIndexByTileBlock(newtile))    # :528
```

Smoothing probabilities (`tilesmooth_scripts.cfg:5-36`, D06 §4.3) `[O]`:
`sandsea1/2/3/4 = 1`, **`sandsea5 = 0.7`**, **`sandsea6 = 0.3`**,
`rock9/rock8/rock5 = 0`. `[D]` The 0.7/0.3 pair is the only live wet-sand
smoothing split; `sandsea2/3/4` are smoothing intermediates only; `rock9` is
excluded both from live selection (`:934-954` commented) and smoothing (Prob 0).

### 6.2 Cliff path — separate rule (`texturemap.inc:557-610`) `[O]`

```gdscript
# Trigger: map edge OR collision tag in radius > 0            # :557-560
if is_map_edge(x,y) or GetMapCollisionTagInRadius(x,y,0,false) > 0:
    # asymmetric SIX-branch angle table (NOT the 8x45° shore sectors):
    if   in(bRB, 22.5, 67.5):  face = "bRB"                   # :563-570
    elif in(bLB, 120.0,170.0): face = "bLB"
    elif in(bR, -45.0, 45.0):  face = "bR"
    elif in(bB,  45.0,135.0):  face = "bB"
    elif in(bT,-135.0,-45.0):  face = "bT"
    else:                      face = "bL"
    FACE_TILE := {"bLB":"rock7","bB":"rock1","bL":"rock3",
                  "bR":"rock4","bT":"rock4","bRB":"rock4"}     # :573-590
    tile = FACE_TILE[face]
    # |h| overrides (height, not angle)                        # :559-609
    if abs(h) > 2.7:  tile = "rock8"
    elif abs(h) > 2.4: tile = "rock4"
    elif abs(h) < 0.1: tile = ""        # no tile
    if tile != "":
        if GetSeasonType == 2: tile += "_winter"
        SetTileIndex(x,y, MapGetTileIndexByTileBlock(tile))
```

`[D]` Do **not** merge the cliff 6-branch table with the shore 8×45° table; they
are distinct donor rules. `rock6/rock2` alternatives are commented (`texturemap.inc:579,582`).

---

## 7. Water levels and the pass-count contradiction

### 7.1 Three distinct water levels `[O]` (D06 §3.1)

| Name | Value | Donor source | Role |
|---|---:|---|---|
| Generation basin | `−1.1` | `generatemap.inc:7` | basin depth, **not** plane Y |
| Generated water field | `−0.5` | `generatemap.inc:688,704` | `WaterFieldAdd(...,cOffsetY)` — GSC-commented ⇒ runtime `[U]` |
| Tile classification | `−0.25` | `texturemap.inc:29-30,466-467` | `bWater` |
| Wet-shore classification | `−0.1` | `texturemap.inc:31,469-470` | `bWaterShore`; band width `[D]` 0.15 |
| Shader plane Y | `gl_TexCoord[1].z` | `water.dev.vert:18`, `frag:167` | engine-supplied, numeric `[U]` |
| Inactive debug Y | `1.5 /*0.94*/` | `water.frag:182` | not pinned by `water.lib:67-68` |

`[D]` With shipped constants, `waveheight = clamp(3Y−1.5,0,1)` is 0 for `Y ≤ 0.5`;
at the recovered `−0.5`/`−0.25` levels the coarse swell (`frag:95`) is **exactly
zero**, so no visible swell can be claimed from donor text alone (D06 §3.3).

### 7.2 `TileSmoothPasses=6` vs script `3` — MULTIPLE PASSES `[U]`

Per charter §4 (owner directive) the contradiction was attacked from independent
angles; D06 P22 is reproduced and extended by my own read-only passes:

| Pass | Instrument / input | Result | Accepted? |
|---|---|---|---|
| M1 | D06 P22 whole-tree scan (`reports/D06_water_shore.md:57`) | Only `globalparams.cfg:9` = 6; only `smoothtiles.inc:237` = 3; `generatemap.inc:784` commented | Accepted as `[U]` contradiction |
| M2 | `grep TileSmoothPasses` over `C:\Games\Cossacks 3\data` (this ticket) | **1 match** — `gen/globalparams.cfg:9: TileSmoothPasses = 6`. No consumer anywhere in `data/**`. | Accepted: config key has no readable reader |
| M3 | `grep SmoothTileMap\|MapGeneratorSmoothTiles` over donor `data` (this ticket) | `smoothtiles.inc:189,191` (procedure), `:237` live call `SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3)`; `generatemap.inc:784` `//MapGeneratorSmoothTiles` commented | Accepted: **3** is the only live pass count |
| M4 | SWARM_BOARD contradiction register C2 (`.md:67`) | "Preserved as donor contradiction; follow script for skirmish" | Accepted as COORD policy |

`[D]` Resolution for implementation: use **3 passes** for skirmish, carry `6` as a
documented donor-config contradiction; **do not** promote 6 to donor truth and
do not silently discard it. Status `[U]` — no compiled consumer of the key was found.

---

## 8. Implications for pending `spec/05_WATER_SHORE.md`

`spec/README.md:21` assigns §05 to `D06 + F06` and lists "water level, shore
smoothing, wave binding, tile selection". This report is an implementation-ready
input; COORD should land §05 with at least:

1. **Water-level table** (§7.1) with all five rows, each path:line cited; explicit
   warning not to use `−0.25/−0.1` as plane Y (D06 I1).
2. **Height-smooth chain S0/S1/S2** (D06 §4.1): radius-3 `SmoothTerrain`; 1×
   power 4 / lerp 0.5 / `h∈[0.01,100]`; **3×** power 0.35 / lerp 0.5 /
   `h∈[−100,−0.01]` with 5×5 (radius 2) water-neighbourhood detection
   (`generatemap.inc:218-245,580-643`). `[O]` numbers; `[U]` runtime execution.
3. **Wave binding section**: `hmapTex` = descriptor key at `+0x54`, **no texture
   bind**; `heightmapwaves0.tga` disproved (alpha 255, `water.mat:86-106` commented);
   `hmap` used for per-pixel depth/wet-dry/fades only, flat vertex, normals from
   `waveMap` (`frag:70-75,167,186-192`). Port `height_tex` = PORT APPROXIMATION
   (D06 I7).
4. **Shader constant/equation table** (§3) — 0.57/1.07, 170/120, 30, three colours,
   mat2, both shifts, 9-octave loop, foam peak depth `0.535` (D06 §6.1 `[D]`),
   alpha ramp `d/1.07`, **no** live Fresnel/current grid/foam texture (D06 I8/I9).
5. **Tile rules** (§6): 8×45° `sandsea1/5/6`, Prob 0.7/0.3, `rock9=0`, winter
   suffix; separate cliff 6-branch table with `|h|>2.7→rock8`, `>2.4→rock4`,
   `<0.1→none` (D06 I5/I6). Cross-link to `spec/06_TILE_AND_ATLAS.md:33` which
   currently says water has "no tile id — port sentinel 255"; the seam is that
   water cells must be painted shore tiles, not atlas 0 (see `water3d.gd:296-304`).
6. **Contradiction ledger**: `TileSmoothPasses=6` vs script `3` = `[U]`, 3 for
   skirmish (§7.2, SWARM_BOARD C2); C3 `tilesmooth.cfg` vs `tilesmooth_scripts.cfg`
   remains preserved.
7. **Boundary with §03/§06**: water levels/smoothing are inputs from §03
   (mask→height); tile ids/atlas from §06. §05 should not re-derive those.

`[I]` `F06` (alpha masks) contributes the `bmTransparency`/alphanull semantics
(`spec/06:55-70`) but does not change the water shader's own alpha ramp — §06
already records the port's 0.35/0.5/step guards as PORT APPROXIMATION.

---

## 9. Risks

1. **GSC comment prefixes.** Almost every generation/shore rule lives behind `;`;
   text is `[O]`, runtime execution `[U]`. Porting numbers is safe; parity is not.
2. **Tool disagreement.** Built-in function discovery/xrefs fail on
   `FUN_00853ad4`; only Ghidra pseudocode + raw bytes recover `+0x54`. A later
   worker using only built-in tools may wrongly conclude "no function" (D06 §10.2).
3. **`hmapTex` mis-binding.** Binding `heightmapwaves0.tga` would produce constant
   `hmapTex.w` (alpha 255) ⇒ constant height or universal discard. The fresh
   module must keep the key open and label the engine binding `[U]`.
4. **Two binaries.** `hmapTex`/`waveMap` absent from `codex.dll` is not proof of
   disuse elsewhere (D06 P15).
5. **Names are not semantics.** `XWater*` are RTTI strings with no code xref;
   `fordtyp` is a *formation type*, not a ford (D06 §8.2).
6. **Scale uncertainty.** Donor metres-per-cell `[U]`; only depth-space numbers
   (0.57/1.07/0.535) are assertable, not screen-space widths.
7. **No visual evidence.** No donor GPU A/B frame; all visual readings `[I]`.
8. **Translation-specific:** the port's `water_cell`/`max(grad,0)`/foam fast-path
   guards are PORT APPROX and must not be presented as donor equations; the
   unported `CalcTerrain`/`test_shadow` stages are a genuine visual gap.

---

## 10. UNVERIFIED register (do not promote)

1. Runtime `hmapMin/hmapMax/hmapW/hmapH` and the literal texture/FBO bound to
   `hmapTex` — key names and offsets proven, binding not (D06 §11.1). Port `±2.96`
   and `map_size/128` are PORT APPROXIMATION.
2. Class identity of the descriptor object (`$XWaterShader` RTTI has no code xref).
3. Runtime execution of `generatemap.inc`/`texturemap.inc` GSC blocks, including
   the `−0.5` field Y.
4. Whether `TileSmoothPasses=6` is consumed by compiled code (no readable consumer);
   active script hardcodes 3.
5. `reflectionMap` provenance and GPU sampler-unit numbers.
6. Whether `DiffuseWaves2` (active in `water.mat`, no `.dev` sampler) is uploaded.
7. `FogMode` → `fogEnabled` int mapping; default `0` is text-observed only.
8. Any ford-generation / shallow-crossing threshold.
9. Donor metres-per-cell and screen-space shore-band width.
10. Visual parity of any port water/shore frame — no A/B capture exists.
11. Numeric runtime value of `gl_TexCoord[1].z` (shader plane Y) — the port's
    `-0.25` is a labelled placeholder, not recovered truth.
12. Mapping from the 8 sector names (`bR/bRB/bB/bLB/bL/bLT/bT/bRT`) to concrete
    `sector` integers — the equivalence `floor((vecangle+22.5)/45)` is D06 `[D]`;
    the literal GSC windows are at `texturemap.inc:479-501` and should be re-read
    before wiring a `SECTOR_TILE` lookup table.

---

## 11. Open questions

1. Can a later Deep session attach `FUN_00853ad4` to its caller and find the generic
   routine turning key `+0x54` into a uniform/sampler bind — the last static route
   to an `hmapTex` texture identity?
2. Is `globalparams.cfg:TileSmoothPasses=6` read by compiled C++, or is 3 the true
   retail pass count?
3. Does the retail skirmish generator call `WaterFieldAdd(...,−0.5)`, or do scenario
   `.map` files supply a different plane Y?
4. Are `rockNvf/vs` face tiles ever applied to the water-side rim by a compiled path
   not in `texturemap.inc`?
5. Is there a ford/bridge placement rule in DLC/expansion data (F10 scope)?
6. Can a donor GPU frame with fixed camera be captured (owner decision) to convert
   depth-space foam metrics to pixel metrics?
7. Will the terrain/tile owner repaint masked water cells to `sandsea1/5/6` rather
   than atlas 0 (`water3d.gd:296-304`), and wire `bind_height_grid()` (`:283-294`)?
8. Should the fresh module port `CalcTerrain`/`test_shadow` (§4.4) now, or wait until
   their engine samplers/FBOs are recovered — and is that gap acceptable for §05 QA?

---

## 12. Summary

- Quoted verbatim, with donor `path:line`, every requested constant/equation: coast
  fade 0.57 (`water.dev.frag:37`), deep fade 1.07 (`:168`), exponents 170/120
  (`:42-43`), particle 30 (`:44`), the three colours (`:45-47`), `mat2(0.72,-1.60,1.60,0.72)` (`:83`), shifts `(0.32t,0.24t)/(0.38t,-0.26t)` (`:88-89`), the hmap depth test (`:70-75,167,170,176-199`), and the fully-commented `water.mat:86-106` block.
- Classified the port line-by-line: faithful donor equations, PORT APPROXIMATION
  bindings (`height_tex`, `map_size`, `water_surface_y`, `reflection_map`), explicit
  PORT GUARD additions, and MISSING stages (`CalcTerrain`, `test_shadow`, fog mode 1,
  shore/cliff tile painting, tile smoothing, height-grid wiring).
- Produced implementation-ready Godot shader and GDScript pseudocode using **only
  donor-cited constants**, keeping `hmapTex` as an open parameter key and never
  binding a wave texture to it.
- Preserved three distinct water levels and the `6` vs `3` pass-count contradiction
  with four independent passes; status `[U]`, follow script (3) for skirmish.
- **No donor visual parity claimed; no donor binary executed; no source, shader,
  config, asset, test, Godot job or git state touched.**

*End of X11 report. Exactly one file written: `docs/terrain_swarm_2026-11-26/reports/X11_water_translation.md`.*
