# DEC DEEP — Donor Water Color (cossacks.exe t_87f0f3c130b0) — READ ONLY

Target: `C:\\Games\\Cossacks 3\\cossacks.exe` (t_87f0f3c130b0). Donor READ-ONLY. No parity claim.

Context: 4K `map_overview_4k.png` shows 4 large grey water blobs (should be blue water) with props inside.

Function-pass budget: max 5 passes per function. Used: FUN_00853ad4 (VA 0x853ad4) — 1 pass (Deep Ghidra pseudocode only). No disassemble/study/xref passes consumed on water functions. All other water evidence is data-file / bytes-show reads.

---

## [O] Water actor / material / shader identity

- Engine classes registered in `.rsrc`: `$XWaterShader` at VA 0x958c10 (between `OSWMesh` and `OSWTextureCombiners`), `fXWaterField` at VA 0x95937b and `XWater` at VA 0x95938a (between `XPattern` and `XSeason`) — ev_70f06a4b4a30620d42c1ffae156975abc6111bc37d375be3d6463676e20c4fc4 (128 B at 0x959360), ev_82ed89d5ac1523dd70ac69da3633b26fa8e090f3697e4c301a7902db6e03019b (128 B at 0x958bf0), ev_54343a6e8779cd812ffe14ed35d7942aa4ed9b91ea12e785d510fad59e542fd6 / ev_6dae3ae13da997184b928905f94f4cd6fa3ea5a06af08532ae016ae033dc759f / ev_b4437608975792ca8e6ad26f8378a231c8483b2c8d177978370cc0798e1742f1.
- CODE key strings: `XWaterShader` at VA 0x8537f4, 0x853807, 0x85381e (file offsets 0x452bf4/07/1e) — ev_b497c8c213af55cab09a41169ddf11e6fc9c8f8dde41c9db94e8cf37e027d63c. `hmapTex` at VA 0x853e0c (file offset 0x45320c), `hmapW` at VA 0x853e1c — ev_35d13c0c3611db1b19607beae9a3a105c4d2caef3677c2c30b95576da182d997, ev_950c8a4b9851edd17ba76e15b9e3dbdc0c5d04c6315d1c4cec434d8ff8b09a0b.
- 30-key param block at 0x8537e0–0x853c98 (observed via bytes-show, ASCII verbatim): `wstReflectTex, wstWaveTex, wstTime, wstEyePos, wstDeepColor, wstShallowColor, wstReflectAmount, wstWaterAmount, wstFresnelPower, wstFresnelBias, wstHdrMultiplier, wstWaveFreq, wstWaveAmp, wstDistFactor, wstBumpFactor, wstTexScaleS, wstTexScaleT, wstWaveDir0, wstWaveDir1, wstFogEnabled, wstHMapTex, wstHMapWidth, wstHMapHeight, wstHMapMin, wstHMapMax, wstShadowed, wstShadowTex, wstShadowSize, wstShadowColor, wstCameraModel` + value keys `reflectionMap, waveMap, time, eyePosition, deepColor, shallowColor` — ev_116683896d284b4ecbd4f6a8a73a6afc80055399c171a42ae0854d46fceaa365 (512 B at 0x8537e0), ev_0252559d8237ab95aa4db446d978f3c6e7522b1f73da2fcbda7135d4ea60b360 (512 B at 0x8539e0).
- Initializer pseudocode (Deep Ghidra, 1 pass):

```c
void FUN_00853ad4(int param_1)
{
  FUN_00405454(param_1 + 4,\"reflectionMap\");
  FUN_00405454(param_1 + 8,\"waveMap\");
  FUN_00405454(param_1 + 0xc,&DAT_00853c98);
  FUN_00405454(param_1 + 0x10,\"eyePosition\");
  FUN_00405454(param_1 + 0x14,\"deepColor\");
  FUN_00405454(param_1 + 0x18,\"shallowColor\");
  FUN_00405454(param_1 + 0x1c,\"reflectionAmount\");
  FUN_00405454(param_1 + 0x20,\"waterAmount\");
  FUN_00405454(param_1 + 0x24,\"fresnelPower\");
  FUN_00405454(param_1 + 0x28,\"fresnelBias\");
  FUN_00405454(param_1 + 0x2c,\"hdrMultiplier\");
  FUN_00405454(param_1 + 0x30,\"waveFreq\");
  FUN_00405454(param_1 + 0x34,\"waveAmp\");
  FUN_00405454(param_1 + 0x38,\"distFactor\");
  FUN_00405454(param_1 + 0x3c,\"bumpFactor\");
  FUN_00405454(param_1 + 0x40,\"texScaleS\");
  FUN_00405454(param_1 + 0x44,\"texScaleT\");
  FUN_00405454(param_1 + 0x48,\"waveDir0\");
  FUN_00405454(param_1 + 0x4c,\"waveDir1\");
  FUN_00405454(param_1 + 0x50,\"fogEnabled\");
  FUN_00405454(param_1 + 0x54,\"hmapTex\");
  FUN_00405454(param_1 + 0x58,\"hmapW\");
  FUN_00405454(param_1 + 0x5c,\"hmapH\");
  FUN_00405454(param_1 + 0x60,\"hmapMin\");
  FUN_00405454(param_1 + 100,\"hmapMax\");
  FUN_00405454(param_1 + 0x68,\"shadowed\");
  FUN_00405454(param_1 + 0x6c,\"shadowMap\");
  FUN_00405454(param_1 + 0x70,\"shadowSize\");
  FUN_00405454(param_1 + 0x74,\"shadowColor\");
  FUN_00405454(param_1 + 0x78,\"cameraModel\");
  *(undefined4 *)(param_1 + 0x7c) = DAT_00853eb8;
  return;
}
```
  — ev_4ddab2aaf1927d0c86177156a5a33b574679cd493b0eb4d053a95f779c2268f6 (prior fnd_6; sets key NAMES only, float 1.99999988 at 0x853eb8 into +0x7c).
- `data/water/water.lib` defaults (verbatim): `Name=default, MaxDepth=1, MinDepth=0, MaxAlpha=1.1, MinAlpha=0, DeepColor (0,0,0.1255,0.5), ShallowColor (0,0,0,0.5), ReflectionAmount/WaterAmount/FresnelPower/Bias/HDRMultiplier=1, WaveFreq/WaveAmp=0, DistFactor/BumpFactor=1, TexScaleS/T=0.1/0.01, WaveDir0 (-1,0), WaveDir1 (-0.7,0.7), Speed=1.0, NormalMap=DiffuseWaves2, DiffuseMap=DiffuseWaves0, Width/Height=1, Offset=0.495, HeightMapEnable/ShadowMapEnable=True, shaders water.dev.vert/frag` — ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff (fnd_73).
- `data/water/water.mat`: base material `DiffuseWaves0` only active; `DiffuseWaves2` active via refkey; `DiffuseWaves1/3/4/5/6/7` + `HeightMapWaves0` commented out; Texture `tfLuminance/tmReplace/tmmUser/twBoth`, `FaceCulling=fcCull`, textures `diffusewaves0.bmp` + `diffusewaves2.bmp` — ev_c4134ca57358820fd8051a741ba9de271ce46baa69882643d982fa1a7998e351 (fnd_75).

## [O] Water color / alpha / fog (shader text)

- `data/shaders/water/water.frag` color constants (verbatim): `watercolor=(0.43,0.60,0.66)` low-water RGB, `watercolor2=(0.06,0.07,0.11)` deep-water RGB, `water_specularcolor=(1.3,1.3,0.9)`, `WATER_LEVEL=1.5`, `coast2water_fadedepth=0.10`, `deepwater_fadedepth=0.5+coast`, `large_waveheight=0.50, large_wavesize=2.0, small_waveheight=0.6, small_wavesize=0.5, water_softlight_fact=15.0, water_glossylight_fact=120.0, particle_amount=70.0` — ev_b89475b624cbf63ecea79507143b497846635738acb7bf8d5b57d35721a9e841 (fnd_76).
- `water.vert` varyings (verbatim): `alphaDepth=gl_Color.r; gl_TexCoord0=gl_MultiTexCoord0*texScaleS; gl_TexCoord1=realpos*texScaleS+time*0.02; gl_TexCoord2=realpos*texScaleT+time*0.02; gl_TexCoord3.xy=gl_MultiTexCoord0.xy/hmapW/H-0.5; gl_TexCoord3.z=gl_Vertex.y; eyeVector from LightSource; fogFragCoord=length(realpos) (ATI: abs(realpos.z)); ftransform` — ev_2615d91d4c68fbeeac9ee62652a31c0f2c4851535b0cd4090d40ffb78b333444 (fnd_78).
- `water.frag:main` discard rule (verbatim tail): `fragColor=texture2D(hmapTex, gl_TexCoord3.xy); h=hmapMin+w*(hmapMax-hmapMin); if (gl_TexCoord3.z>h) mainImage(...); gl_FragColor=fragColor;` final `fragColor=vec4(col,1.0)` opaque; active `terrain_map()=vec3(0)`, `height_map()=0`, `nautic()=1`, `particles`/`test_shadow()=1` stubs — ev_fb3fefcb2e3e89d92528db1a31f89e4fdfe527e1ca09dc859f35a1cf9b27e40b (fnd_77).
- Coast blend (verbatim): `coastfade=(level-height)/0.10 clamp, coastfade2=(level-height)/deepwater clamp, intensity=col.r*0.2126+g*0.7152+b*0.0722, watercolor=mix(watercolor*intensity, watercolor2, smoothstep(coastfade2)), col=mix(col, watercolor, coastfade)` plus soft/glossy specular and `watercolor*=2.2+watershade` — same ev.

## [O] WaterFieldAdd / cOffsetY / plane Y vs basin

- `data/scripts/common.inc/generatemap.inc` water placement (comment-prefixed GSC, runtime UNVERIFIED): `WaterFieldsClear; const cOffsetY=-0.5; const cWaterFieldSize=2; const cWaterMapArrSize=(640 div 2); bWaterMap[wmx,wmy]:=True where (gMapMask[x,y].b>0) and ((r<1) or (b<1)); mapsizemod=(cWaterMapArrSize/((640/mapheight)*2))*cWaterFieldSize; tx=wmx*2-mapsizemod, tz=wmy*2-mapsizemod, bx=(wmx+1)*2-mapsizemod, bz=(wmy+1)*2-mapsizemod; WaterFieldAdd('x..y..',tx,tz,bx,bz,cOffsetY)` — ev_21e884bff74f3f4acd8c3563eabe752439963b53be5f654e0104c0cdebac0553 (fnd_79), ev_7b4f355fa98e76b177e77bb51c80c4c97809cbdaa7250d8c51999ae94b1357f1 (WaterFieldAdd anchor at file offset 0x7de1).
- D03-F3 basin (prior [O] fnd_14): `hwater=-1.1*(fb*(1+fr*3.5))`, terrain ±2.964 terms; so water basin floor ≈ −1.1..−4.95 before smoothing; water plane at `cOffsetY=-0.5` sits ~0.6 above deepest basin and above `-0.25/-0.1` shore-tile thresholds (texturemap.inc, fnd_9/16). `Offset=0.495` in water.lib is layer param, not Y.
- No `WaterFieldAdd/cOffsetY` strings in cossacks.exe CODE (core_feature_find 0 matches, ev_5e805250e975cec546ad5999076ecb1aa614b5016559d3e2234a6222cf15abfa / ev_29daa9ef11d3ee595cff95feb37ddabbb043520ebf4ca050fb039dd27c9fd0dc): placement lives in DScript text, not native.

## [D] Why our water renders grey

- Donor blue is NOT `DeepColor (0,0,0.1255)`. That lib value is near-black blue and only one uniform input; the visible blue in screenshots comes from `water.frag` `watercolor/watercolor2` mix + `waveMap/reflectionMap` sampling + specular/fog path (fnd_81: ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff + ev_b89475b624cbf63ecea79507143b497846635738acb7bf8d5b57d35721a9e841).
- Grey flat quads with props inside match a missing-shader / missing-texture / unlit-material fallback: opaque `vec4(col,1.0)` path not executed, `DiffuseWaves0/2` luminance BMPs not bound, or `hmapTex/hmapMin/Max` discard misconfigured so `mainImage` never runs and the heightmap texel (grey) shows. Check port for: (a) fragment shader not assigned (water.dev.frag vs water.frag), (b) `reflectionMap/waveMap/hmapTex` uniforms unbound, (c) `alphaDepth=gl_Color.r` varying dropped, (d) fog overriding blue.
- Props inside water are EXPECTED donor behavior when `bWaterMap` gate uses `(r<1 or b<1)` — shallow/grey-border cells still stamp patterns; grey blobs ≠ water-mask bug alone. Do not move props to fix color.

## [U] Unverified / traps

- Runtime values of `hmapMin/Max/W/H`, `fogEnabled`, `shadowed/Size/Color`, `cameraModel`, `1.99999988` (+0x7c) not recovered; `FUN_00405454` string-setter semantics UNVERIFIED beyond key assignment.
- `water.dev.vert/frag` vs `water.vert/frag(.bak)` active pair UNVERIFIED; port must confirm which pair the engine loads (`water.lib` points to `water.dev.*`).
- `WATER_LEVEL=1.5` in `water.frag` vs `cOffsetY=-0.5` vs basin −1.1 relationship is script-vs-shader naming, not proven same coordinate frame; do not equate without owner-run calibration.
- `fXWaterField` vs `XWater` actor roles (field quad vs system) UNVERIFIED from .rsrc names alone.

## Port fix recommendation (no edit — for water3d.gd / terrain_donor_mesh.gd owner)

1. `water3d.gd`: bind donor shader pair `data/shaders/water/water.dev.vert` + `water.dev.frag` (not `.bak`); set uniforms from `water.lib`: `deepColor=(0,0,0.1255,0.5)`, `shallowColor=(0,0,0,0.5)`, `texScaleS/T=0.1/0.01`, `waveDir0/1`, `reflectionAmount/waterAmount/fresnelPower/Bias/hdrMultiplier=1`, `waveFreq/Amp=0`; bind `waveMap/diffuse=diffusewaves0.bmp`, `reflectionMap/normal=diffusewaves2.bmp` (luminance), `hmapTex` = heightmap texture with `hmapMin/Max/W/H`.
2. `water3d.gd`: implement `water.vert` varyings exactly: `TEX0=MTex0*0.1`, `TEX3.xy=MTex0.xy/(W,H)-0.5`, `TEX3.z=vertex.y`, `alphaDepth=COLOR.r`, `fog=length(realpos)`; implement `water.frag` discard `if (TEX3.z>hmapMin+w*(hmapMax-hmapMin)) mainImage else keep hmap texel`; hardcode donor constants `watercolor #6E99A8 (0.43,0.60,0.66)`, `watercolor2 #0F121C (0.06,0.07,0.11)`, `specular (1.3,1.3,0.9)`, `WATER_LEVEL 1.5`, fades `0.10/0.60`; force opaque alpha 1.0.
3. `terrain_donor_mesh.gd`: set water quad Y to `cOffsetY=-0.5` (not −0.25); keep terrain basin from donor heights (−1.1 basin) so `TEX3.z(−0.5) > h(−1.1..)` passes inside blobs and fails on shore; generate one 2×2 m quad per `bWaterMap` cell (`cWaterFieldSize=2`, `mapsizemod` formula above); do NOT recolor terrain grey under water — donor ground stays sand/grass and shows through `coastfade`.
4. Verify: blobs turn blue-green gradient (light `#6E99A8` at coast → dark `#0F121C` deep), specular glints move with light, props remain visible above water; if still grey, capture which uniform/texture bind failed (most likely `hmapTex` or `waveMap`).

---

*Addresses: $XWaterShader CODE 0x8537f4/807/81e, .rsrc 0x958c10; fXWaterField .rsrc 0x95937b; XWater .rsrc 0x95938a; hmapTex CODE 0x853e0c (file 0x45320c); hmapW 0x853e1c; param block 0x8537e0/0x8539e0/0x853be0; FUN_00853ad4 VA 0x853ad4; global 0x853eb8=1.99999988. Passes: FUN_00853ad4 pseudocode ×1.*
