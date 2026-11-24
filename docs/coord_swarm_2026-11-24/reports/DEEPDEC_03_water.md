---
id: DEEPDEC-03
scope: "DONOR WATER — descriptor default values / field layout, full fragment shader logic, bound textures, variant3d recipe"
date: 2026-11-24
status: AUDIT DONE — read-only; no target open/select; no runtime tools; no source/asset/config/test/git edits
owner: DEEPDEC-03
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use); cossacks.exe sha256 87f0f3c130b0…e16c"
target: "t_87f0f3c130b0 (already open, shared; never opened/selected by this agent)"
---

# DEEPDEC-03 — Donor water: descriptor, defaults and full shader path

## 0. Method and scope guards

- Craft Anything 0.6.1, **deep** mode, shared target `t_87f0f3c130b0`; `enable_toolset({toolset:"native"})` called once (idempotent). No `core_target_open`, no `core_target_select`, no Frida/runtime instrumentation, no unpacking, no donor file copied into the repo.
- Binary reads: `native_bytes_show`, `native_data_show`, `native_instruction_show`, `native_address_show`, `native_address_offset_show`, `native_function_find`, whole-file `native_bytes_find` (UTF-8 + UTF-16LE, with VA/section), `core_evidence_browse` was checked for paging but all facets used here fit in one response.
- Donor text read read-only with `core_text_read` (evidence ids below) and cross-checked with line-numbered local reads (`path:line` citations are from the donor file as stored).
- Image **headers only** were read with a read-only Python `struct.unpack_from` (dimensions/bpp/imgType); no texture payload was imported.
- OBSERVATION = read directly; INFERENCE = reasoned from cited data; UNVERIFIED = no static evidence. No parity claim is made (charter: a GPU A/B capture would be required).

## 1. Evidence ledger

| Evidence id | Source | What it establishes |
|---|---|---|
| `ev_b284c02cf7c0727264d5d59d4ed3f2399566c0b1fb505da77f4852ab50fd3cc2` | donor `data\shaders\water\water.dev.frag` (262 lines) | Full fragment source; all shader constants/algorithm |
| `ev_5450bcc45aa5c0809d0158b65c91c3e8fc3fe63df2b57f230f95aa1d49ef0924` | donor `data\shaders\water\water.dev.vert` (30 lines) | Vertex passthrough + varyings |
| `ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff` | donor `data\water\water.lib` (71 lines) | Shipped water config values and shader/mat selection |
| `ev_b25d35234d67c04a37050632ab684047e8a7358b465cf4e7aa2d0d9d36e03875` | donor `data\water\water.mat` (106 lines) | Bound vs commented textures, formats |
| `ev_f27e2eed4f54a212363908e10dc40e960d04dcd7a22b10e36188c1dc6487758c` | donor `data\scripts\common.inc\texturemap.inc` (963 lines) | `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`, `cMaxHeight=2.96` (literal, commented script lines) |
| `ev_ac75afae1baf334ae7010dbe246fd8344a3050b96b93b3317767632874d45788` | donor `data\scripts\common.inc\generatemap.inc` (1059 lines) | Map-gen `cWaterHeight=-1.1`, `cPlateauHeight=2.964`, `cRavineHeight=-2.964` (distinct from texturemap.inc) |
| `ev_9918481e1585dc4c793328d7d2e5f2aaff883ff0c5397ca6c1eab5b195961a43` | `native_bytes_show(0x853800, 2560)` | `wst*` key strings; string-assignment block `0x853ad4–0x853c62`; 30 keys; 0.1/0.01 float patterns absent locally |
| `ev_d72effeb42845ae8d915377dafb874645ebeeded4f115137daa935ed7eebbcde` | `native_bytes_show(0x853b00, 512)` | `lea eax,[ebx+off]; mov edx,key; call 0x405454` 13-byte pattern |
| `ev_1dfd1d6721390812a596d17e230155795f7c68c4a28c6a9beec1ace391af6c61` | `native_bytes_show(0x853d00, 512)` | Config-key string headers (`waterAmount`…`cameraModel`) and the float at 0x853eb8 |
| `ev_a8abdbbcfc157068e2cabab9f45f1641640497edb506b653473abbf70e2987e4` | `native_bytes_find("cameraModel")` | `cameraModel` VA `0x853eac`, file offset `0x4532ac`, section CODE, 1 match |
| `ev_03eb161c90d6962781179abd247668f28b08f324e69e7a837b6dbd22c0ddb988` | `native_data_show(0x853eb8, f32)` | f32 = **1.9999998807907104** (bytes `ff ff ff 3f` = i32 `0x3FFFFFFF`) |
| `ev_65c9954da29a24e5ea5deeb24cf2e4e7b0273c917f739988aac6ef987e6b0f41` | `native_data_show(0x853eb8, i32)` | Same bytes as i32 = 1073741823; 0 xrefs |
| `ev_d94dda9482a38c5a0aa3322f1eb7ffddc2f812530d8886205613ad9b23d21319` | `native_instruction_show(0x853c5d)` | `mov eax, [0x853eb8]` (`a1 b8 3e 85 00`), reference list contains `0x853eb8` |
| `ev_9e9f28455cdcbf204f414184497a4085c96b7fba97ad71a0f2dd0095f943be3f` | `native_instruction_show(0x853c62)` | `mov [ebx+0x7c], eax` (`89 43 7c`) — the only numeric store in the initializer |
| `ev_4b10476458214c3feabc03d84ef5a2a3ad5a54f3d227e8f2bf252e9a91ee97c2` | `native_instruction_show(0x85405d)` | Config reader tests `byte [ebx+0x7c], 1` — confirms +0x7C is a flags field |
| `ev_d77442d03ae851db4276aaa2a623d27200eb02f0b39086f3dad8c5d4e1905222` | `native_instruction_show(0x8540eb)` | `test byte [ebx+0x7c], 0x40` — further bitmask use |
| `ev_975bed9a7fc480da8c15a6c5a7d3f1bd9af35e784db4248b95175aa10db23525` | `native_instruction_show(0x8540f1)` | `push dword [esi+0x88]` — fallback defaults are runtime object fields, not literals |
| `ev_a8d1ae7c099e253eba79b55d2e844f4b0a3caf03485d1d6cb8878a8ba04a64ed` | `native_bytes_show(0x854000, 2048)` | Config-reader body `0x854051…`; pushes `[esi+0x88..0xb0]`; `f*` uniform-name string header at end |
| `ev_389db76cda71cc69f3dccacd72054a6ba7ca088763471f0ead7dac8bf5c51700` | `native_bytes_show(0x854700, 768)` | `fWaterStates`, `fReflectTex`, … `fCameraModel` — engine shader-uniform name table |
| `ev_fecf269dc1bbfbdab6ed132301d3cf781185312a305671894062b4c9af44903d` | `native_address_show(0x853bde)` | "not inside any discovered function" |
| `ev_8fad1662b6762bb2ab4a9aea1fe7c1e8305b23a595825356d6db6b89ebdd270e` | `native_function_find(0x853ad4)` | initializer block has no containing function |
| `ev_2c564dc25c695e471de57ace7cf8a6c1bb327951c3ba7791629b06c465852108` | `native_function_find(0x854051)` | config-reader block has no containing function |
| `ev_877b1928ae1f6e5ec7fe1598ad5130ea1ffce2a267dcee1af3e31cf40da83e24` | `native_bytes_find("A4 70 FD 3E")` = f32 0.495 | **0** matches whole file |
| `ev_613c642599a3ccb789b5da01aba3f4d17be67a4a698080beda6ceb96d32a85f4` | `native_bytes_find("1F 85 B5 3E")` = f32 0.57 | **0** matches whole file |
| `ev_dce015dd8d015611baf19a318760c272af3d147f2829b49f7880c941584cacd2` | `native_bytes_find("A4 70 3D 40")` = f32 2.96 | **0** matches whole file |
| `ev_e8b122f7d14389d96f684c1011e6cfaf650799c31b7636b06272f8332c104f31` | `native_bytes_find("CD CC CC BD")` = f32 −0.1 | **0** matches whole file |
| `ev_4a76586153ac5b78609cb42e1baa8a59c8dd096a33d6cdee8e13527c50e297fd` | `native_bytes_find("00 00 80 BE")` = f32 −0.25 | 71 matches; **none** in `0x853000–0x855000` |
| `ev_b88bafb285bee3bfba0dcdcc68e988e0cc6524ff6408505312067f969e1c1bbf` | `native_bytes_find("CD CC 8C 3F")` = f32 1.1 | 7 matches; **none** in `0x853000–0x855000` |

Prior-session evidence reused (not re-derived): `ev_190898349c86f8d90a49007c79d2e593cc6278658a16928cb0c9371ae0dc6846` (`mov edx,0x853e0c` at 0x853bde), `ev_cf7b42dd86b0261abebcacb0ea646d12092da5b46c61dd33f6e9be552c3a11fb` (`call 0x405454`), `ev_9c4ff7ba1fa969cabab05fcedebdae7056860c44b7455c340e7e639b55516b1d` (callee pseudo-C = Delphi ref-counted string assignment), `ev_20196da6116c175f32b10c36cd5bc357788189fce04cdd886010608eae86bd68` (0x853dc0 window), from `DECOMP_04_strings_config.md §8`.

---

## 2. TASK 1 — Default values near the water descriptor

### 2.1 The initializer is a string-key assignment block, not a numeric-default block

**OBSERVATION.** From `0x853ad4` (`push ebx; mov ebx,eax`) the code is 30 repetitions of a 13-byte pattern:

```
8d 43 <field_off>  ba <key_va32>  e8 <rel32 → 0x405454>
```

i.e. `lea eax,[ebx+field_off]; mov edx,<AnsiString constant>; call 0x405454` (Delphi `System.@Assign`, copy-on-write string store). It ends at `0x853c5d` with the numeric store, then `pop ebx; ret` (`0x853c65–0x853c66`). Decoded field → key map (all keys resolved from the adjacent `ff ff ff ff` + length string headers; `ev_9918481e…`, `ev_1dfd1d67…`):

| field | key string | key VA | field | key string | key VA |
|---|---|---|---|---|---|
| +0x04 | reflectionMap | 0x853c70 | +0x40 | texScaleS | 0x853da8 |
| +0x08 | waveMap | 0x853c88 | +0x44 | texScaleT | 0x853dbc |
| +0x0C | time | 0x853c98 | +0x48 | waveDir0 | 0x853dd0 |
| +0x10 | eyePosition | 0x853ca8 | +0x4C | waveDir1 | 0x853de4 |
| +0x14 | deepColor | 0x853cbc | +0x50 | fogEnabled | 0x853df8 |
| +0x18 | shallowColor | 0x853cd0 | +0x54 | hmapTex | 0x853e0c |
| +0x1C | reflectionAmount | 0x853ce8 | +0x58 | hmapW | 0x853e1c |
| +0x20 | waterAmount | 0x853d04 | +0x5C | hmapH | 0x853e2c |
| +0x24 | fresnelPower | 0x853d18 | +0x60 | hmapMin | 0x853e3c |
| +0x28 | fresnelBias | 0x853d30 | +0x64 | hmapMax | 0x853e4c |
| +0x2C | hdrMultiplier | 0x853d44 | +0x68 | shadowed | 0x853e5c |
| +0x30 | waveFreq | 0x853d5c | +0x6C | shadowMap | 0x853e70 |
| +0x34 | waveAmp | 0x853d70 | +0x70 | shadowSize | 0x853e84 |
| +0x38 | distFactor | 0x853d80 | +0x74 | shadowColor | 0x853e98 |
| +0x3C | bumpFactor | 0x853d94 | +0x78 | cameraModel | 0x853eac |

This **reproduces and extends** DECOMP-04 §8.2 (`hmapTex` → `[EBX+0x54]`, key `0x853e0c`) and fixes the record layout: 30 consecutive 4-byte string-pointer slots `+0x04…+0x78`, then one 4-byte numeric slot `+0x7C`.

### 2.2 The one numeric default that IS provable

| Value | VA | File offset | Typed read | Assignment | Evidence |
|---|---|---|---|---|---|
| `0x3FFFFFFF` (i32) / **1.9999998807907104** (f32) | `0x853eb8` | `0x4532b8` | f32 `1.9999998807907104`; i32 `1073741823`; 0 data xrefs | `0x853c5d` `mov eax,[0x853eb8]` → `0x853c62` `mov [ebx+0x7c],eax` | `ev_03eb161c…`, `ev_65c9954d…`, `ev_d94dda94…`, `ev_9e9f2845…`, offset `0x4532b8` |

**OBSERVATION.** The config reader at `0x854051` then tests bits of that field: `test byte [ebx+0x7c],1` (`0x85405d`), `test byte [ebx+0x7c],0x40` (`0x8540eb`), etc. **INFERENCE:** `+0x7C` is a per-key enable bitmask (all 30 keys enabled by the `0x3FFFFFFF` default). Do **not** reinterpret 1.99999988 as a shader constant — no instruction uses it as a float operand; it is consumed as a bitmask.

### 2.3 Wave / fresnel / texScale numeric defaults: UNVERIFIED in the binary

**OBSERVATION.** No `mov [ebx+off], imm32` float store exists in the initializer; every numeric parameter is fetched at runtime by the undiscovered config-reader block `0x854051…`, which passes fallback defaults as `push dword [esi+0x88]`, `[esi+0x8c]`, … `[esi+0xb0]` (`ev_975bed9a…`, `ev_a8d1ae7c…`). Those are fields of a runtime object, not embedded literals. Whole-file byte searches for the distinctive shipped values returned:

- 0.495 → **0** (`ev_877b1928…`); 0.57 → **0** (`ev_613c6425…`); 2.96 → **0** (`ev_dce015dd…`); −0.1 → **0** (`ev_e8b122f7…`).
- −0.25 → 71 hits (`ev_4a765861…`), 1.1 → 7 hits (`ev_b88bafb2…`), but **none** in the water region `0x853000–0x855000` (all are generic CODE constants elsewhere; nearest is `0x85ab44`).

**Conclusion (per field):** `waveFreq`, `waveAmp`, `fresnelPower`, `fresnelBias`, `texScaleS`, `texScaleT`, `hdrMultiplier`, `waveDir0/1`, `hmapMin/Max`, `shadowSize/Color` — binary default **UNVERIFIED**. Their shipped values are readable in external text (`water.lib`, §6.2) and in the shader's own initialisers (`water.dev.frag:37–47`), which are the values a port should use.

---

## 3. TASK 2 — Containing function

**OBSERVATION.** `native_address_show(0x853bde)` → "not inside any discovered function" (`ev_fecf269d…`); `native_function_find(0x853ad4)` (`ev_8fad1662…`) and `native_function_find(0x854051)` (`ev_2c564dc2…`) both → `function: null`. This matches DECOMP-04 §8.2's 20+ failed `native_function_find` probes. `native_instruction_show` still decodes individual instructions because the tool decodes bytes at an address without requiring a function (`ev_d61ac7c4…`).

**Documented cleanly:** no dossier, no pseudo-C, no caller list exists for either block; function discovery misses the whole `0x853000–0x855000` region. The record layout in §2.1 and the uniform tables in §6.1 were therefore reconstructed from **byte windows + string headers + field offsets**, not from a decompiled function. INFERENCE: the likely owner is a Delphi `TXWaterShader`/`TXWaterUniforms` class (class names `XWaterShader`, `TXWaterUniforms`, `TXWaterShader` are byte-present in this region; `water.dev.vert:6` declares `cameraModel`, which the descriptor binds at `+0x78`).

---

## 4. TASK 3 — Full fragment algorithm, line by line

All citations are donor `data\shaders\water\water.dev.frag:<line>` (evidence `ev_b284c02c…`) unless prefixed `vert:` (`water.dev.vert`, `ev_5450bcc4…`).

### 4.1 Declarations and constants (lines 1–48)

- `1–3` uniforms `time`, `texScaleS`, `texScaleT`.
- `5–6` samplers `waveMap`, `reflectionMap`.
- `8–16` **commented-out** uniforms: `deepColor`, `shallowColor`, `reflectionAmount`, `waterAmount`, `fresnelPower`, `fresnelBias`, `distFactor`, `bumpFactor`. Only `hdrMultiplier` (`14`) is live. **Important:** despite `water.lib` defining those keys and the binary binding them, the shipped fragment shader does **not** use them.
- `18–21` `hmapTex`, `hmapMin`, `hmapMax`, `hmapW`; `23` `fogEnabled`; `25–28` `shadowed`, `shadowMap` (`sampler2DShadow`), `shadowSize`, `shadowColor`.
- `30–32` varyings `eyeVector`, `lightVector`, `fogFragCoord`; `34` `iglobaltime = time`.
- `37–47` shader-local constants: `coast2water_fadedepth=0.57`, `large_waveheight=0.50`, `large_wavesize=2.0`, `small_waveheight=0.5`, `small_wavesize=0.5`, `water_softlight_fact=170`, `water_glossylight_fact=120`, `particle_amount=30`, `watercolor=(0.1,0.24,0.24)`, `watercolor2=(0,0.025,0.05)`, `water_specularcolor=(0.4,0.4,0.4)`; `48` `light = lightVector.xyz`.

Vertex stage (`vert:14–29`): `pos=gl_Vertex`; `TexCoord[0]=TextureMatrix[0]*pos` (projected reflection coord); `TexCoord[1].xy = MultiTexCoord0.xy/(hmapW,hmapH) − 0.5`; **`TexCoord[1].z = pos.y`** (water plane height carried to fragment); `TexCoord[3]=TextureMatrix[3]*cameraModel*ModelView*pos` (shadow coord); `eyeVector=pos.xyz−eyePosition.xyz`; `lightVector=(L.x/4, L.z/2, L.y)`; `fogFragCoord=abs((ModelView*pos).z)` on ATI else `length(ModelView*pos)`; `gl_Position=ftransform()` — **no vertex displacement**.

### 4.2 Helper functions

| Lines | Pseudocode |
|---|---|
| `51–54` | `hash(n) = fract(sin(n) * 43758.5453123)` |
| `57–63` | `noise1(x)` — 2-D value noise: `p=floor(x); f=smoothstep(0,1,fract(x)); n=p.x+p.y*57; return mix(mix(hash(n),hash(n+1),f.x), mix(hash(n+57),hash(n+58),f.x), f.y)` (**dead code**: never called by the shipped path) |
| `65–68` | `noise(p) = texture2D(waveMap, p * (1/256)).x` — **the only noise sampler**; 256² matches `diffusewaves0.bmp` |
| `70–75` | `height_map(p) = hmapMin + texture2D(hmapTex,p).w * (hmapMax − hmapMin)` |
| `77–81` | `terrain_map(p) = vec3(0.175,0.1375,0.1) + texture2D(waveMap,p*8).rgb * 0.25` |
| `83` | `m = mat2(0.72, -1.60, 1.60, 0.72)` — rotation/scaling matrix reused by every octave loop |
| `85–104` | `water_map(p,height)`: `p2=p*2`; `shift1=0.001*(time*320, time*240)`; `shift2=0.001*(time*380, −time*260)`; coarse fBm `f = 0.6*noise(p) + 0.25*noise(p*m) + 0.1666*noise(p*m*m)`; crossing swell `wave = sin(p2.x*0.622 + p2.y*0.622 + shift2.x*4.269) * 0.5 * f * height²`; then `p*=0.5; f=0; amp=1; s=0.5; repeat 9× { p=m*p*0.947; f -= amp*abs(sin((noise(p+shift1*s)−0.5)*2)); amp*=0.59; s*=−1.329 }`; return `wave + f*0.5` |
| `106–117` | `nautic(p)`: `p*=18; f=0; amp=1; s=0.5; repeat 3× { p=m*p*1.2; f += amp*abs(smoothstep(0,1,noise(p+time*s))−0.5); amp*=0.5; s*=−1.227 }; return pow(1−f,5)` |
| `119–127` | `particles(p)`: `p*=200; f=0; amp=1; s=1.5; repeat 3× { p=m*p*1.2; f += amp*noise(p+time*s); amp*=0.5; s*=−1.227 }; return pow(f*0.35,7)*30` |
| `129–143` | `test_shadow(xy,height)`: `sh=1`; if `shadowed==1`: `of=1/shadowSize; sh=0; sh += 3× shadow2DProj(shadowMap, TexCoord[3] + {0,+of,−of} offsets).r < 0.999 ? 0 : 1; sh/=3; sh += shadowColor.x*0.7*(1−sh)` — **3-tap PCF** |
| `145–160` | `CalcTerrain(uv,height)`: `col=terrain_map(uv)`; 4 height samples at `uv±(0,0.01)`, `uv±(0.01,0)` → `norm=normalize(vec3(h3−h4, h1−h2, 1))`; `rd=normalize(light − vec3(uv,height))`; `grad=dot(norm,rd)`; `col *= grad + grad^8`; `shade=test_shadow`; `col = mix(col*0.25, col, shade)` |

### 4.3 `mainImage` (lines 162–235) — top 10 steps

1. **`162–165`** `uv = fragCoord.xy` where `fragCoord = gl_TexCoord[1].xy` (`258`).
2. **`167`** `WATER_LEVEL = gl_TexCoord[1].z` — vertex-plane Y (`vert:18`), not a constant 1.5 as in the legacy `water.frag`.
3. **`168–170`** `deepwater_fadedepth = 0.5 + 0.57 = 1.07`; `height = height_map(uv)`.
4. **`174–175`** `waveheight = clamp(WATER_LEVEL*3 − 1.5, 0, 1)`; `level = WATER_LEVEL + 0.2*water_map(uv*15 + time*0.1, waveheight)` — wave-jittered water level.
5. **`176–183`** **Land discard:** if `height > level`, `fragColor = vec4(0.0); return` (the commented-out alternative was `CalcTerrain`).
6. **`186–194`** **Wave normals / jitter:** `dif=(0,0.01)`; `pos = uv*15/texScaleS*(hmapW/128) + time*0.01`; four `water_map(pos±dif, pos±dif.yx)` taps; `normwater = normalize(vec3(h3−h4, h1−h2, 0.15))`; `wavejitter = normwater.xy * texScaleT * (level−height)`; `uv += wavejitter`.
7. **`196–201`** **Depth tint:** `rescolor=CalcTerrain(uv,height)`; `coastfade=clamp((level−height)/0.57,0,1)`; `coastfade2=clamp((level−height)/1.07,0,1)`; `intensity = 0.2126R+0.7152G+0.0722B`; `watercolor = mix(watercolor*intensity, watercolor2, smoothstep(0,1,coastfade2))`.
8. **`203–213`** **Reflection:** fresnel block (`203–206`) and water/reflection mix (`211–212`) are **commented out**; live code: `refuv=gl_TexCoord[0].xyw; refuv.xy -= wavejitter*refuv.z; refcol=texture2DProj(reflectionMap,refuv); refcol.xyz *= (R+G+B)*hdrMultiplier; watercolor += refcol.xyz`.
9. **`215–227`** **Specular / shadow / foam:** `rd=normalize(light − vec3(uv,WATER_LEVEL))`; `grad=dot(normwater,rd)`; `specular=pow(grad,170)`, `specular2=pow(grad,120)`; `gradpos=dot((0,0,1),rd)`; `specular1=smoothstep(0,1,pow(gradpos,5))` (dark corona); `watershade=test_shadow(uv,level)`; then `watercolor *= 2.2+watershade`; `watercolor += (0.2+0.8*watershade)*((grad−1)*0.5+specular)*0.25`; `watercolor /= 1+specular1*1.25`; `watercolor += watershade*specular2*(0.4,0.4,0.4)`; **foam** `watercolor += watershade*coastfade*(1−coastfade2)*((0.5,0.6,0.7)*nautic(uv) + (1,1,1)*particles(uv))`.
10. **`229–232`** **Composite:** `rescolor = mix(rescolor, watercolor, coastfade)`; `resalpha = coastfade2`; `fragColor = vec4(rescolor, resalpha)`.

### 4.4 Fog and entry (lines 237–262)

- `239–251` `fogmap(c)`: if `fogEnabled>0`, `f=1`; mode 1 LINEAR `clamp((gl_Fog.end−fogFragCoord)*gl_Fog.scale,0,1)`; mode 2 EXP `clamp(exp2(−density*fogFragCoord*1.442695),0,1)`; mode 3 EXP2 `clamp(exp2(−pow(density*fogFragCoord,2)*1.442695),0,1)`; `c.rgb = mix(gl_Fog.color.rgb, c.rgb, f)`.
- `255–262` `main`: `fragcoord = gl_TexCoord[1].xy`; `mainImage`; `fogmap`; `gl_FragColor = fragcolor`.

**INFERENCE.** The shoreline is a height-contour fade: alpha 0 at `level−height = 0` and 1 at `1.07` m; foam occupies only the band `coastfade*(1−coastfade2)`. The `eyeVector` varying is computed but does **not** feed the final colour because the fresnel/distFactor/bumpFactor block is commented out — a correction to any recipe that would wire Fresnel.

---

## 5. TASK 4 — Donor water textures: bound vs commented

Evidence `ev_b25d35234…` (`water.mat`), `ev_6fcb07113a…` (`water.lib`); header bytes read read-only this turn.

| File (exact donor name) | Size / format (header) | State | Role |
|---|---|---|---|
| `.\data\water\textures\diffusewaves0.bmp` | 196,662 B; BMP 256×256, 24 bpp | **ACTIVE** `water.mat:7`, material `DiffuseWaves0` (`:17`); `tfLuminance` (`:11`), `twBoth` (`:12`), `maLinear`/`miLinearMipmapLinear` (`:9–10`), `tcNone`, `tfIsotropic`, `tmReplace`, `fcCull` | Only sampled texture: `waveMap` (`frag:5,65–68`); selected as `DiffuseMapLibMaterialName = DiffuseWaves0` (`water.lib:44`) |
| `.\data\water\textures\diffusewaves1.bmp` | 196,662 B; BMP 256×256, 24 bpp | **COMMENTED** `water.mat:23–31` (`DiffuseWaves1`) | Not shipped water input |
| `.\data\water\textures\diffusewaves2.bmp` | 786,486 B; BMP 512×512, 24 bpp | **ACTIVE library material** `DiffuseWaves2` (`water.mat:35–41`), selected into `NormalMapLibMaterialName` (`water.lib:43`) | No matching sampler in `water.dev.frag` — actual GPU use UNVERIFIED |
| `diffusewaves3/4/5/6/7.bmp` | `diffusewaves3.bmp` exists, 512×512, 24 bpp | All **COMMENTED** `water.mat` | Not shipped |
| `.\data\water\textures\heightmapwaves0.tga` | 258,506 B; TGA imgType 10 (RLE), 256×256, 32 bpp | **COMMENTED** `water.mat:86–106`, material declared `tfNormalMap`; `water.lib:45` commented | Do **not** bind as `hmapTex` (engine height texture is a separate, UNVERIFIED binding) |

**No foam texture asset exists** under `data\water\textures` — foam is entirely procedural (`nautic`/`particles`).

---

## 6. TASK 5 — Donor water recipe for `variant3d` (PROVEN vs UNVERIFIED)

### 6.1 Uniform names and binding

**PROVEN — GLSL uniforms actually declared in the shipped fragment/vertex pair** (`water.dev.frag:1–28`, `water.dev.vert:1–6`):
`time`, `texScaleS`, `texScaleT`, `waveMap`, `reflectionMap`, `hdrMultiplier`, `hmapTex`, `hmapMin`, `hmapMax`, `hmapW`, `fogEnabled`, `shadowed`, `shadowMap`, `shadowSize`, `shadowColor`; vertex adds `eyePosition`, `hmapH`, `cameraModel`.
`deepColor`, `shallowColor`, `reflectionAmount`, `waterAmount`, `fresnelPower`, `fresnelBias`, `distFactor`, `bumpFactor` are declared **but commented** (`frag:8–16`) — do not wire them.

**PROVEN — engine-side name tables in the binary:**
- Config-key strings assigned to descriptor fields `+0x04…+0x78` (`ev_9918481e…`, table in §2.1): `reflectionMap, waveMap, time, eyePosition, deepColor, shallowColor, reflectionAmount, waterAmount, fresnelPower, fresnelBias, hdrMultiplier, waveFreq, waveAmp, distFactor, bumpFactor, texScaleS, texScaleT, waveDir0, waveDir1, fogEnabled, hmapTex, hmapW, hmapH, hmapMin, hmapMax, shadowed, shadowMap, shadowSize, shadowColor, cameraModel`.
- `wst*` strings at `0x853c70…` region (`ev_9918481e…`) and `f*` shader-binding strings at `0x854780…` (`ev_389db76c…`): `fWaterStates, fReflectTex, fWaveTex, fTime, fEyePos, fDeepColor, fShallowColor, fReflectAmount, fWaterAmount, fFresnelPower, fFresnelBias, fHdrMultiplier, fWaveFreq, fWaveAmp, fDistFactor, fBumpFactor, fTexScaleS, fTexScaleT, fWaveDir0, fWaveDir1, fFogEnabled, fHMapTex, fHMapWidth, fHMapHeight, fHMapMin, fHMapMax, fShadowed, fShadowTex, fShadowSize, fShadowColor, fCameraModel`. INFERENCE: these are the engine's uniform-slot names; the GLSL names above are their short forms.

### 6.2 PROVEN numeric values to port

**From `water.lib` (`ev_6fcb07113a…`):**
`MaxDepth=1`, `MinDepth=0`, `MaxAlpha=1.1`, `MinAlpha=0`; `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`; `ReflectionAmount=1`, `WaterAmount=1`, `FresnelPower=1`, `FresnelBias=1`, `HDRMultiplier=1`, `WaveFreq=0`, `WaveAmp=0`, `DistFactor=1`, `BumpFactor=1`; `TexScaleS=0.1` (`0.115` commented), `TexScaleT=0.01` (`0.015` commented); `WaveDir0=(-1,0)`, `WaveDir1=(-0.7,0.7)`; `Speed=1.0`; `Width=1`, `Height=1`, `Offset=0.495`, `LayerCount=1`; `CustomEnable=False`, `CustomShaderID=0`, `CustomReflection=False`, `CustomReflectionUnit=0`, `CustomTexCoord=True`, `CustomTexCoordScale=1`, `CustomTexReflectMatrix=False`, `CustomTexReflectMatrixUnit=0`; `HeightMapEnable=True`, `ShadowMapEnable=True`; `DefaultWaterIndex=0`, `Tag=512`; shaders `.\data\shaders\water\water.dev.vert/.frag`.

**From `water.dev.frag:37–47` (`ev_b284c02c…`):** `0.57`, `0.5`, `2.0`, `0.5`, `0.5`, `170`, `120`, `30`, `(0.1,0.24,0.24)`, `(0,0.025,0.05)`, `(0.4,0.4,0.4)`; matrix `m=(0.72,-1.60;1.60,0.72)` (`:83`); octave weights `0.6/0.25/0.1666`, `0.947`, `0.59`, `−1.329` (`:92–101`), `1.2`, `0.5`, `−1.227` (`:113,125`), fade depths `0.57`/`1.07` (`:168,198–199`), `0.2` level jitter (`:175`), `15`, `0.1`, `128` (`:187`), `0.15` normal Z (`:192`), `2.2`, `0.25`, `1.25`, foam tints `(0.5,0.6,0.7)`, `(1,1,1)` (`:223–227`), fog `1.442695` (`:246,249`).

**From scripts (PROVEN literal, commented script lines):** `texturemap.inc:29–31` `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` (`ev_f27e2eed…`); `generatemap.inc:5–7` `cPlateauHeight=2.964`, `cHillHeight=2.964/2.25`, `cRavineHeight=-2.964`, `cWaterHeight=-1.1` (`ev_ac75afae…`). **Distinct constants for distinct scripts — do not merge them.** Active execution of the commented branches remains UNVERIFIED (TERRAIN2-03 UNV-4).

### 6.3 Texture slots for a 3D spatial material

| Slot | Donor source | Port note |
|---|---|---|
| wave/noise | `diffusewaves0.bmp` → `tfLuminance` (256²) | Sample `.r`; `app/assets/terrain/water_png/diffusewaves0.png` already exists (TERRAIN2-03 P5) |
| height | `hmapTex` + `hmapMin/hmapMax/hmapW` | Engine-supplied in donor; **UNVERIFIED binding** — in 3D substitute from `height[]` grid, label as port choice |
| reflection | `reflectionMap` projected (`texture2DProj` + `wavejitter`) | **UNVERIFIED FBO binding**; equation is donor-grounded |
| shadow | `sampler2DShadow shadowMap`, `shadowed`, `shadowSize`, `shadowColor` | **UNVERIFIED binding**; 3-tap PCF equation is donor-grounded |
| unset | `DiffuseWaves2`, `HeightMapWaves0`, `diffusewaves1/3–7` | Not sampled by shipped shader; do not wire |

### 6.4 UNVERIFIED (must stay labelled)

1. Numeric defaults of every descriptor parameter in the binary (§2.3) — only external config/shader literals are PROVEN.
2. Containing function for the initializer and the config reader — none discovered (§3).
3. `hmapTex` / `reflectionMap` / `shadowMap` sampler→unit and FBO bindings.
4. Whether `DiffuseWaves2` is actually uploaded to a normal-map sampler.
5. Water-plane topology (one quad vs strips) — inferred from passthrough vertex stage only.
6. Active execution of the commented `texturemap.inc`/`generatemap.inc` water branches.
7. Meaning of the `f*`/`wst*` tables beyond being name pools (INFERENCE only).

---

## 7. Top 10 shader steps (reply summary)

> [!NOTE] CORRECTION by DEEPDEC-02 (`DEEPDEC_02_terrain_render.md`): the
> blanket "no GLSL source embedded in the EXE" claim is too broad. Terrain
> shader source names/source are external-only (0 hits for `hf.pvl.sm.*`,
> `gl_EyePlaneS`, `realpos`), but GLSL IS embedded for other families —
> post-FX at `0x5bc800` and water at `0x453000`. Uniform names and the
> `CustomShaderLib30p` schema/enums are embedded at `0x858808`. The water
> defaults and recipe above (from external `water.lib`) are unchanged.

1. height from `hmapTex` via `hmapMin + w*(hmapMax−hmapMin)` (`frag:70–75,170`).
2. `WATER_LEVEL = gl_TexCoord[1].z` from vertex Y; `deepwater_fadedepth = 1.07` (`167–168`, `vert:18`).
3. jittered `level = WATER_LEVEL + 0.2*water_map(...)`; `waveheight=clamp(WATER_LEVEL*3−1.5,0,1)` (`174–175`).
4. land discard `if height>level → vec4(0)` (`176–183`).
5. 4-tap `water_map` finite-difference normal + `wavejitter = norm.xy*texScaleT*(level−height)` (`186–194`).
6. base terrain colour + 3-tap PCF shadow (`129–143,145–160,196`).
7. `coastfade=(level−height)/0.57`, `coastfade2=(level−height)/1.07`; depth tint mix (`198–201`).
8. projected reflection with jitter + `(R+G+B)*hdrMultiplier` (`207–213`; fresnel commented).
9. specular `pow(grad,170/120)`, corona `1+specular1*1.25`, shadow, foam `nautic+particles` in `coastfade*(1−coastfade2)` (`215–227`).
10. `rescolor=mix(rescolor,watercolor,coastfade)`, alpha=`coastfade2`, fog LINEAR/EXP/EXP2, `gl_FragColor` (`229–232,237–262`).

## 8. Next atomic tasks

- Recover the function containing `0x853ad4` by scanning callers of `0x405454` with a `mov edx, 0x853e0c` immediate, or by widening function discovery around `0x853000` (may require a different analysis engine setting).
- Resolve `[esi+0x88..0xb0]` defaults by finding the constructor that writes them (candidate: undiscovered block near `0x854254`).
- A/B the donor-equation 3D shader against the 2D `app/shaders/water_overlay.gdshader` transcription before changing `world3d_terrain.gd` material (no parity claim without a GPU capture).

---

*End of report. No source, asset, config, test or git state was modified by this agent; no donor binary/texture/audio was copied into the repository.*
