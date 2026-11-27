---
id: DEC-U-WATER-SHADER-DEEP
worker: DEC-U-WATER-SHADER-DEEP (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\Games\Cossacks 3\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b0..."
labels: [O, D, I, U]
scope: "One file only. Read-only. No donor execution, no parity claim."
upstream: "DEC_U_water_runtime.md U1; DEC_U_water_lib_params.md CE/file-tuples"
---

# DEC-U-WATER-SHADER-DEEP — U1, new static angles (complete rewrite, 2026-11-26)

Prior disk version ended mid-table and is superseded by this file. Nothing below invents lost bytes; gaps are marked not recovered.

## 1. Method `[O]`

Pinned `t_87f0f3c130b0`, Deep mode. `native_bytes_find` (text + LE patterns), `native_bytes_show`, `native_xrefs_list`, absolute reads of `C:\Games\Cossacks 3\data\shaders\water\water.dev.vert/frag`, `water.vert/frag`. No Deep re-lift (built-in engine reports `function_not_found` for `FUN_00855b38/00856530/00854054`); prior Deep pseudocode re-cited only. No donor binary executed.

## 2. (a) CODE literal search `[O]` — table completed

| Literal | Result |
|---|---|
| `water.dev.vert` / `water.dev.frag` / `water1.frag` / `water2.frag` | 0 CODE hits each (prior ev family; exact ids not recovered, marked not recovered) |
| `mainImage` | 0 hits (`ev_5f4847ad57ba5faac2df3582594cf0111c70748b55635e4b96a3f3c07e6a5f76`) |
| `height_map` | 0 hits (`ev_e1d52b10160095193ec48400e671471ee173b6db7a1a4b551878c687f5be855b`) |
| `reflectionMap` | 5 CODE hits (`ev_22a4ce2ccee3122510be5e3d607d427959c669818c69f0992572e264c5dbf3a5`): `0x853c70` table; `0x855266/0x855297/0x855680/0x85572d` embedded FP |
| `hmapTex` | 1 CODE hit (`ev_1400d4ac2ff2e6d434878cf48a46530a595b088e33e1f8aa423c7b6580dda4d8`): `0x853e0c` table only, absent from embedded VP/FP |
| `alphaDepth` | 4 CODE hits (`ev_aaf3e1efef2f38c6933d57396d6552d60ee6a5a547d5bc468e1ae14e2ac1bead`): `0x854c39/0x8551ba/0x8553f4/0x8558b6` |
| `eyePosition` / `cameraModel` / `shadowMap` / `waveDir*` / `texScale*` / `fogEnabled` / `waveMap` | CODE hits present (exact per-literal counts not recovered, marked not recovered) |
| `WaterShaderVP - ` / `WaterShaderFP - ` | 1 hit each (`ev_0bf0e04d8f500a56522696158efdef43ec0d8041585e073eedaac265e4f6b9e0`): `0x855ce0/0x855cfc` |
| `XWaterShader` | 4 hits (`ev_97739b19317210a5bee49684153b5eefdeaac10f512b515cf4613e577bbc533b`): `0x8537f4/0x853807/0x85381e/0x958c11` |
| `wstReflectTex` table head | 1 hit (`ev_abfa6a2df3331e7b5a3751fed6557c58745395a7bb055a5843247473b0949d01`): `0x853834` |
| `.vert` / `.frag` generics at `0x8ecdb2/0x8ecdde` | Unrelated `obj\test.config` paths, not water (detail re-observed; ev id not recovered) |

`[D]` No water filename literal and no `mainImage`/`height_map` function name exists in CODE. `[I]` File pairs cannot be referenced by name from the image.

## 3. (b/c) Tables + fingerprint conclusion `[O]/[D]`

Two parallel 30-entry CODE tables: `wst*` (`wstReflectTex...wstCameraModel`) from `0x853834`, plain (`reflectionMap...cameraModel`) from `0x853c70` (`ev_502566...`; entry = name + 00-pad + `FF FF FF FF` + u32 len). `XWaterUniforms`/`XWaterShader` class block at `0x853700`.
Embedded CODE pair (`ev_63ad2ceebd97bf18b174603fa0992e4176f2b2355c3e1758902eb5c67cdb6303` at `0x854b00`): VP `eyePosition/time/waveFreq/waveAmp/texScaleS //0.01/texScaleT //0.02/waveDir0 //vec2(-1,0)/waveDir1 //vec2(-0.7,0.7)/fogEnabled/eyeVector/alphaDepth/fogFragCoord`, `NWAVES 2`, `gl_TexCoord[1/2]=P*texScaleS/T+time*0.02`, `alphaDepth=gl_Color.r`; FP `texture2DProj(reflectionMap`, `mix(shallowColor,deepColor`, `gl_FragColor.a=alphaDepth`, fog 1/2/3 chain.
Donor files: `water.dev.vert` (`hmapW/H`, `cameraModel`, `ftransform`), `water.dev.frag` (`mainImage`, `height_map`, `hmapTex/Min/Max`, coast `0.57`, commented-out deep/fresnel), `water.vert` (`hmapW/H`, `ftransform`), `water.frag` (`mainImage`, `height_map`, `WATER_LEVEL=1.5`).
`[D]` Embedded pair matches neither file pair: `hmapTex/Min/Max/mainImage/height_map/cameraModel` are absent from embedded; `alphaDepth/deepColor-live` are absent-as-live from DEV. The compiled program can only be the embedded BUILTIN pair; file pairs are not compiled from this image.

## 4. (d) Selector bytes conclusion `[O]/[D]`

`0x856530` bytes (`ev_4b8938285f66fdcb1ffb794eeab8c3b2583363c49e55dbd53d3d87e8d0e4aa8d` + 768 B re-read): `80 BB 84 01 00 00 00` + `0F 84 ...` + `A1 B8 C6 8F 00` + `80 38 00` + `0F 84 ...`, i.e. `CUSTOM = (C+0x184 != 0 AND [0x8fc6b8] != 0)`.
`[D]` `CustomEnable=False` forces `C+0x184=0` on both construction paths, so CUSTOM is unreachable. It does **not** force BUILTIN: BUILTIN-vs-LEGACY still needs `FUN_0085600c` triple + `[0x8fc6b8]`, both runtime globals. Compile-internal xrefs (`e0 5c 85 00` at `0x855bff` to VP error string; `fc 5c 85 00` at `0x855c6c` to FP error string, inside `FUN_00855b38`) tie the compile path to the embedded pair only. Built-in xref DB is otherwise empty, so no selector-to-source-address xref is claimed.

## 5. Still-`[U]` list — exact zero-mismatch captures (owner-authorised GPU session only)

| # | Item | Static state | Capture (break + dump + termination) |
|---|---|---|---|
| U1 | Live path DEV/BUILTIN/LEGACY | NOT-CUSTOM proven; BUILTIN likely, unproven | Hook `glShaderSource` + break `0x855b38/0x856530`; record `C+0x184/C+0x50/C+0xf0`, `[0x8fc6b8]`, `FUN_00855fe8` triple, source text + program hash. Terminate only on identical `(PATH, flags, program-hash)`, 0 mismatches, 2 draws + 1 camera move |
| U3 | `hmapW/H/Min/Max` + `hmapTex` identity | Sources = terrain `+8/+0xc`, getters on `+0x200` obj; gate `C+0xe0` (re-cited) | Break `FUN_00854054` bits `7e.10-7f.1`; record 4 values + `glActiveTexture/BindTexture` at unit `C+0xdc` + `glGetTexLevelParameteriv`. Terminate only on identical `(w,h,target,name)`, 0 differing bits, 2 frames + move |
| U4* | Which tuple live (file vs ctor) | Exactly two candidate tuples (re-cited) | Break `FUN_00851bdc`; record layer ptr + `C+0x88..0xc4` + `glUniform1f/2f` trace. Terminate only on bit-exact match to one tuple, 0 ULP, 2 frames + move |
| U5 | `C+0xc8` writer + live `time` | Formula `(float)(dbl[+0xc8]*dbl[+0xc4])`, `Speed=1.0`; writer unknown | Hook `glUniform1f(time)` >=3 frames over >=2 s; if non-constant, HW watchpoint on `+0xc8` to writer EIP. Terminate only on constant-`0.0` (10 s, watchpoint silent) or single writer EIP every frame with 0-ULP formula reproduction |
| U6 | Mesh UV/winding | Lives in generic vtable `+0x98`, not water code (re-cited) | Break `+0x98` from draw; dump position/UV/index arrays + `GL_CULL_FACE/FRONT_FACE`. Terminate only on bit-exact UV/index match, >=2 fields + move |
| U12 | Reflection provenance/size/matrix | Object `C+0x4c`, FBO names present, no water-specific creation found | Frame capture: bound FBO, attached texture `(name,w,h)`, sampler unit, `+0x60` matrix + viewport, waves-upload alias. Terminate only on identical tuple, 0 mismatches, 2 frames + move; else keep hard-fail, never neutral texture |

U7-U11/U13-U16: use `DEC_U_final_register.md` experiments verbatim; untouched by this worker.

## 6. Claim register

`[D]`: zero water filename/`mainImage`/`height_map` literals in CODE; two 30-key CODE tables; full embedded BUILTIN pair in CODE; file pairs mismatch embedded; CUSTOM excluded by `C+0x184=0`; compile tied to embedded via error-string xrefs. `[U]`: U1/U3/U4*/U5/U6/U12 per §5. No parity claim. No approximation substituted; port keeps explicit no-default params + hard-fail.

## 7. Verdict

U1 narrowed to NOT-CUSTOM with BUILTIN strongly implied but still `[U]`; no byte in this pass promotes any path, scalar, time source, UV, or reflection target to settled.

*End DEC-U-WATER-SHADER-DEEP (complete).*
