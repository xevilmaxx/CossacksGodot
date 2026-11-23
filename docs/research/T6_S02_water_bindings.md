# T6-S02 — Water shader sampler → texture-unit bindings in the live engine

**Ticket:** T6-S02 (LANE RESEARCH, read-only). **Executed by:** T6-RESEARCH parent
directly (no child session; SWARM_OPS.md §7.2 confirms `subagent` is unavailable
inside child sessions). **Date:** 2026-11-23.
**Boundaries:** private use only; donor never executed; no donor asset copied into
the repo; no Godot job; no code/asset edit.

**Labels:** `observed` / `derived` / `inferred` / `UNVERIFIED` as in T6-S01.
A sampler name read from a shader is `observed as text`; what feeds it at runtime
is `derived` or `UNVERIFIED` and is labelled separately.

**Baselines read first:** `docs/audit/WATER_REPORT.md`,
`docs/audit/RENDER_ARCH_REFLECTION.md`, `docs/audit/RENDER_ARCH_SHADERS.md`.
Baseline open questions O1/O2/C7/C12/C13 are the target of this ticket.

---

## 1. Question

Which texture is bound to each sampler of the shipped water shader in the live
engine — specifically **`reflectionMap`** (the projected reflection source) and
the sampler that supplies **wave height** (`waveMap` / `hmapTex`) — and to which
texture unit? Prior audits resolved the *functional* identity from plaintext
but left the literal engine binding `UNVERIFIED` because it lives in
`cossacks.exe`.

---

## 2. What was done

1. Re-read donor `data\water\water.lib`, `water.mat`,
   `data\shaders\water\water.dev.vert/.frag` (the shipped pair per
   `water.lib:67-68`), `materials\ref\refcubemap.mat`, `shaders.lib`,
   `eventsettings.inc` — see baselines for the full transcription.
2. Opened `cossacks.exe` read-only in a new Craft Anything session
   (target `t_87f0f3c130b0`, sha256
   `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`,
   Deep mode, no execution) and ran deterministic string / import / function /
   byte searches. Evidence ids below.
3. Re-derived the shader-side binding chain and recorded what static analysis
   can and cannot prove.

---

## 3. Craft Anything evidence (this session)

| Evidence id | Query / result |
|---|---|
| `ev_dbe6f2c9a00b6ff047b27e1589be054566d2831b231eba360943c857fd102e2d` | string `reflectionMap` → **0** matches in the whole file |
| `ev_e5d25c3fe1d5789abb7fa64f05800008e7125a1d8ee9a377e3818d0188c1add5` | string `waveMap` → **0** |
| `ev_ecc91ecaeac5b127b6c4cd458bf1b1dc2bea93481736acdcf7b9fee664f212c2` | string `hmapTex` → **0** |
| `ev_10bcdfc5c5e2ee4ed8ad4157d54e86150070f8dbcc66e48874b5be2e05142b99` | string `WaterReflection` → **0** (the option name lives in `eventsettings.inc`, not the exe) |
| `ev_c1d3250cb8d96ee8d7c62fb9f62c3be3b4c9179b5e4ee54e18cefdd780d552cf` | string `FocalLength` → **0** (all camera keys are external scripts) |
| `ev_295cc3f6db57fecd33762936324fd9a15e1ffa055840603d895fa8563cfbbcd0` | import/function `glGetUniformLocation` → **0** |
| `ev_c60b0cc236f0e76ae01163f088e196d9a89574c1016e9e4d3a7cbd071ab6325e` | `glUniform1i` → **0** |
| `ev_f416d86880a1d8e6bd7df88eb32eb3624f7efb9d07c0c30ecfd18508d1118094` | `glActiveTexture` → **0** |
| `ev_9ae975060f18e8c12098b737818c4d0cbc15f9cb990a511daa34f1a545dec81c` | `glGetUniformLocationARB` → **0** |
| `ev_4bec4f735f7243a8b305cdeeea683a8fdecc54cc389b929cfc304b0f5c911337` | `glUniform1iARB` → **0** |
| `ev_419b8358d678f393c19656020412ed0ca437602b0ee9d72fca3bf7c8ae2f6f12` | `glActiveTextureARB` → **0** |
| `ev_64136820e92198243bfd1b2a7bbf5a01d852316f161ce5daac09749b6c2d6553` | any function/import named `*Shader*` → **0** |
| `ev_90b77e2ea84a58a7ffd697c43d5a0d6ab179dd3de3342e08d5e0408cddb85ded` | `wglGetProcAddress` → **1 import** (`opengl32.dll`) |
| `ev_de636fad525f9e4cd6762d39dab881eedd54a333464cc13aedc55482d476fa46` | all 264 `gl*` names: fixed-function 1.x only (texture/vertex/matrix), **no shader/uniform entry points** |
| `ev_2129d492859a27238b398d6335a2aec3266a7c7c5dc35704371b451c4a05352b` | `glBindTexture` import + thunk exists |
| `ev_5acf3de99c577de5c3b7efa08be58d3d880890011acf980f702e316adaf34703` | RTTI string `XWaterShader` exists (engine has a dedicated water-shader class) |
| `ev_bdf22ca0e953332c76b3e84158668d9aef0cd2ace26b77bf5af4e5b9e61f7cfe` | string `glOrtho` (context only; see S01) |

Caveats recorded by the tool: string searches cover **data sections of the file
only** (absence is not proof of runtime absence); function discovery stopped
after 6,000,000 instructions, so *function* results are partial — but the
**import table is complete**, which is what the "no shader API imported" claim
rests on.

---

## 4. Findings

### 4.1 Why the literal binding cannot be recovered statically (new evidence)

- The sampler names `reflectionMap`, `waveMap`, `hmapTex` and the option name
  `WaterReflection` are **not present anywhere in `cossacks.exe`**
  (`ev_dbe6f2c9…`, `ev_e5d25c3f…`, `ev_ecc91eca…`, `ev_10bcdfcf…`). They exist
  only in the external GLSL files (`water.dev.frag:5,6,18`) and script files.
- The import table contains **no shader-program or uniform API at all** — no
  `glCreateShader`, `glShaderSource`, `glGetUniformLocation`, `glUniform1i`,
  `glActiveTexture` and none of their ARB forms (`ev_295cc3f6…`,
  `ev_c60b0cc2…`, `ev_f416d868…`, `ev_9ae97506…`, `ev_4bec4f73…`,
  `ev_419b8358…`, `ev_64136820…`). Instead `wglGetProcAddress` is imported
  (`ev_90b77e2e…`), so all shader/uniform entry points are resolved **at runtime
  through dynamically obtained function pointers**, with sampler *names*
  supplied by strings parsed out of the external shader source at load time.
- Therefore no static xref can connect `water.dev.frag`'s `reflectionMap` to a
  `glUniform1i(location, unit)` call or to a specific `glBindTexture` call in
  the file. **The literal sampler→unit binding is UNVERIFIED by construction,
  not merely not-yet-searched.** This is a stronger, evidence-backed reason than
  the baseline's "binding is in the binary" statement.

`inferred`: the engine likely builds the uniform→unit mapping from the
`water.mat` material-library names and its own fixed slot convention, then
binds via the dynamically resolved uniforms; the exact convention is unknown.

### 4.2 Sampler-by-sampler answer

| Sampler (shader decl) | What feeds it | Status | Evidence |
|---|---|---|---|
| `waveMap` (`water.dev.frag:5`; sampled at `p/256` in `noise()`, frag:65-68) | **`DiffuseWaves0`** = `diffusewaves0.bmp`, 256², `TextureFormat=tfLuminance` (`water.mat:7,11,15`; `water.lib:44`) | **derived (strong)** | config name match + 1/256 scale matches 256² sheet (WATER_REPORT §2.2) |
| `hmapTex` (`frag:18`; height in `.w`, `h = hmapMin + w*(hmapMax-hmapMin)`, frag:70-75; UV = world/`hmapW`, vert:16-17) | **engine-supplied terrain height texture**, because `water.lib:60 HeightMapEnable = True`; **not** `heightmapwaves0.tga` (its material section is commented at `water.mat:86-106` and its alpha is constant 255) | **derived (strong)**; literal engine call **UNVERIFIED** | WATER_REPORT §2.2 + this session |
| `reflectionMap` (`frag:6`; `texture2DProj(reflectionMap, refuv)`, frag:207-210; UVW from `gl_TextureMatrix[0]*pos`, vert:15) | a **projected texture**. Whether it is (a) a mirrored-camera planar FBO, (b) a previous-frame screen copy, or (c) another render target is **UNVERIFIED**; it is **not** the static cubemap (`materials/ref/refcubemap.mat` is used by object `env`/`DecalCubeMap` shaders, `shaders.lib:157-194,1056-1093`) | **form observed**; provenance **UNVERIFIED** | RENDER_ARCH_REFLECTION §3.1–3.3; `WaterReflection` toggle at `eventsettings.inc:155,533-537` |
| `shadowMap` (`frag:26`, `sampler2DShadow`; 3-tap `shadow2DProj`) | the engine shadow map, enabled by `water.lib:61 ShadowMapEnable = True` | **derived** | WATER_REPORT §3.4 |
| `DiffuseWaves2` (`water.lib:43 NormalMapLibMaterialName`, 512²) | bound in the legacy NormalMap slot, but `water.dev.frag` has **no normal-map sampler** → slot unused in the shipped shader | **derived** | WATER_REPORT §2.2 |

### 4.3 Texture-unit numbers

- The object shader registry explicitly binds `texUnit0 → 0`, `texUnit1 → 1`
  (`shaders.lib:176-191` for `DecalCubeMap`, `:1225-1242` for `env`).
- The water shaders are loaded **directly** by `water.lib:67-68`, not via
  `shaders.lib`; `water.mat` contains only named material libraries
  (`DiffuseWaves0`, `DiffuseWaves2`) and **no `TexIndex`/unit field**
  (read of all 106 lines). `water.lib:53-59` has
  `CustomReflection=False`, `CustomReflectionUnit=0`,
  `CustomTexReflectMatrix=False`, `CustomTexReflectMatrixUnit=0` — these are
  *custom* override slots (disabled), **not** the default water unit numbers.
- **Conclusion:** the default water sampler→unit numbering is **UNVERIFIED**.
  Do not claim "reflectionMap is unit 1" or "hmapTex is unit 2" — no plaintext
  or static binary evidence supports a number. RENDER_ARCH_REFLECTION's C13
  (`TexIndex=2` vs `texUnit1=1`) remains an unresolved object-shader convention,
  not a water fact.

### 4.4 What would settle the UNVERIFIED items (not done — donor run forbidden)

1. A Craft Anything Deep xref from the engine's dynamically resolved
   `glGetUniformLocation`/`glUniform1i` function pointers to the sampler-name
   strings **as loaded from `water.dev.frag`** (the strings are external, so the
   xref target is the shader-loader's string buffer, not a file string).
2. An instrumentation trace of a donor frame (forbidden by charter) showing the
   FBO bound before `reflectionMap` is sampled.
3. A decompile of `XWaterShader` methods (RTTI string `ev_5acf3de9…`) around
   texture setup — possible in principle but the function list is incomplete
   (6M-instruction cap) and no named method was found in this session.

---

## 5. Claim table

| # | Claim | Evidence | Method | Status |
|---|---|---|---|---|
| 1 | `waveMap` = `DiffuseWaves0` (256² luminance BMP) | `water.mat:7,11,15`, `water.lib:44`, `frag:65-68` | config + scale match | **derived** |
| 2 | `hmapTex` = engine terrain height texture, not `heightmapwaves0.tga` | `water.lib:60`, `frag:70-75`, `vert:16-17`, `water.mat:86-106`, Pillow alpha (baseline) | read + Pillow | **derived**; engine call **UNVERIFIED** |
| 3 | `reflectionMap` is a projected 2D texture (not a cubemap) | `frag:6,207-210`, `vert:15`; `refcubemap.mat` used by object shaders | read | **observed (form)** |
| 4 | Reflection provenance (planar FBO vs screen copy) | — | — | **UNVERIFIED** |
| 5 | Sampler names absent from `cossacks.exe` | `ev_dbe6f2c9…`, `ev_e5d25c3f…`, `ev_ecc91eca…` | string search | **observed** (file data sections) |
| 6 | No shader/uniform API in import table; `wglGetProcAddress` present | `ev_295cc3f6…`, `ev_c60b0cc2…`, `ev_f416d868…`, `ev_90b77e2e…`, `ev_de636fad…` | import census | **observed** |
| 7 | Literal sampler→unit binding therefore not statically recoverable | #5 + #6 | chained | **derived (strong)** |
| 8 | Default water texture-unit numbers | — | — | **UNVERIFIED** — do not assert |
| 9 | `CustomReflectionUnit=0` etc. are disabled override slots, not default units | `water.lib:53-59` | read | **derived** |
| 10 | `DiffuseWaves2` normal-map slot unused by shipped shader | `water.lib:43` vs `frag:5-6,18,26` | read | **derived** |
| 11 | `XWaterShader` engine class exists | `ev_5acf3de9…` | RTTI string | **observed** |
| 12 | Object shaders bind `texUnit0→0`, `texUnit1→1` | `shaders.lib:176-191,1225-1242` | read | **observed** (not a water binding) |

---

## 6. Hand-off / port implication

- **Guaranteed donor truth for builders:** bind wave noise to one 256²
  `diffusewaves0` sheet; take height from the terrain height field (alpha);
  sample reflection as a **projected** texture. Those three are safe to port.
- **Do not spend a ticket chasing the literal unit numbers** — the evidence
  shows they are dynamically bound and not statically discoverable. Use the
  screen-space projected proxy already recommended in
  `RENDER_ARCH_REFLECTION.md §6` (A/B gate `reflection_enabled`) and label it
  "form-faithful, provenance UNVERIFIED".
- Keep `WaterReflection` toggle semantics; the option name exists in
  `eventsettings.inc:155,533-537` even though it is absent from the exe strings.
- This resolves baseline **C7** and **O1/O2** as far as static evidence allows:
  C7 "binding is in cossacks.exe" is refined to "binding is through
  dynamically resolved uniforms with external shader-name strings —
  statically unrecoverable"; O1 (planar FBO vs screen copy) stays open and is
  now demonstrably not answerable without a donor trace.

No donor asset was copied; no donor executable was run; no code was changed.
