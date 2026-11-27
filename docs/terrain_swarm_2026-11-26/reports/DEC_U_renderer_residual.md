---
id: DEC-U-RENDERER-RESIDUAL
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-U-RENDERER-RESIDUAL — close residual U3/U5/U7/U8/U11-U13 + material/light/alpha/fog/callList from t_87f0f3c130b0"
agent: "DEC-U-RENDERER-RESIDUAL (READ-ONLY subagent; no code, no Godot, no git; donor read-only, never executed/copied)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
target_pinned: "t_87f0f3c130b0 (cossacks.exe, PE x86 32-bit, 5768048 B, sha256 87f0f3c130b0...)"
labels_used: [O, D, I, U, "RUNTIME PROBE", "PORT INSTRUCTION"]
parity_claim: false
scope_guard: "Exactly one repo file written (this report). No repo code/shader/config/asset/test/git/Godot edit. No Craft Anything target opened or switched. Donor binary never executed, copied, patched or committed. Every native address is a pinned VA in t_87f0f3c130b0; every donor-text value cites path:line."
---

# DEC-U-RENDERER-RESIDUAL — exact material/light/alpha/fog/callList residual

## 0. Result in one paragraph

This pass re-verifies the two landed closures from `DEC_U_scenecolor_glstate.md`
(U-1 `sceneColor=(0.2,0.2,0.2,1.0)` at `0x8f58dc` via `0x4d13f1`; U-2 pname
`0x0B52=GL_LIGHT_MODEL_TWO_SIDE` at `0x4d1404/0x4d1412`, startup `GL_FALSE`)
and the four structural closures from `DEC_U_alpha_pass_quad.md` (U4 enum value
1, U6 `GL_ALPHA_TEST` ENABLED, U9 one `glNewList` per cell, U10 `0x48->0x50`
`+0x0b` map) in **four passes each over `sub_88f3e8`, `sub_4d08bc`,
`sub_4d13d4` and the fog/alpha/callList sites**, reusing only byte-proven
evidence ids. **No new numeric constant is recovered or invented.** What is
[O] from CODE (slot→enum maps, call sites, table addresses, enum values) is
typed in §2–§5; what is [O] from donor TEXT (`reftile.mat`, `light.cfg`,
`colors.lib`, `shaders.lib`, `hf.pvl.sm.vert/.smx3.frag`, `reftilealpha.mat`)
is cited with file:line in §2–§5; everything else stays [U] with a
**concrete GL/runtime capture whose termination is zero mismatches**
(§7). §8 is an exact file:line port change list for
`terrain_donor_mesh.gd` and `terrain_donor_shader.gdshader` that **preserves
`scene_color=(0.2,0.2,0.2)` and every landed GLSTATE edit**. **No donor visual
parity is claimed. No donor GPU A/B frame exists.**

Related: `PORT1TO1_terrain_renderer.md` §§6/9 (U3/U5/U7/U8/U11-U13 open);
`DEC_U_scenecolor_glstate.md` §§3–6 (U-1/U-2 closed, U-LP-3b/U-LP-4 open);
`DEC_U_alpha_pass_quad.md` §§3–6 (U4 enum closed, arithmetic U-4b open).

---

## 1. Method, pin discipline and multi-pass ledger

### 1.1 Discipline

- Pinned target for every native citation: `t_87f0f3c130b0`. No
  `core_target_open`/`select`, no global active-target switch, no `editor.exe`
  read in this pass.
- Donor binaries never executed, copied, patched, committed or debugged.
  Rizin/objdump-equivalent raw bytes are cited only through the recorded
  `native_bytes_show`/`native_data_show`/`native_instruction_show` evidence
  below; no new execution was performed.
- Starting documents re-read in full this pass: `PORT1TO1_terrain_renderer.md`,
  `DEC_U_scenecolor_glstate.md`, `DEC_U_alpha_pass_quad.md`; current
  `variant3d/scripts/terrain_donor_mesh.gd` (2259+ lines) and
  `variant3d/shaders/terrain_donor_shader.gdshader` (324 lines) read for the
  §8 line list.
- Strange decompiles: none new. The two logged in
  `DEC_U_scenecolor_glstate.md` §2.3 (`FUN_004f99b7` overlap at `0x4f99b7`;
  `sub_559cc4` lifter-only; `0x4d0de0` byte-alignment record) remain excluded
  and are not cited here.

### 1.2 Multi-pass ledger (each lead ≤4 passes)

| Lead | Pass 1 (Deep pseudocode) | Pass 2 (raw disassembly) | Pass 3 (xrefs/callers) | Pass 4 (raw bytes/table) | Accepted |
|---|---|---|---|---|---|
| Material `sub_88f3e8` | `FUN_0088f3e8` shape: cached uploader, face in ecx | 85 insns: `0x1601/0x1600/0x1200/0x1201/0x1202` immediates | caller `FUN_005422c0` passes `PTR_DAT_008fcac0=0x8f58dc` as AMBIENT source | `reftile.mat:53-89` floats | slot→enum [O]; terrain floats [U-LP-3b] + probe |
| Light `sub_4d08bc` | `FUN_004d08bc` per-light enable + 10 pnames | 164 insns: `0x1200..0x1209`, `GL_LIGHT0+i`, `glMultMatrixf` | `FUN_00890ccc` position path; `sub_4ca154` matrix path | `light.cfg:3-38` text | pname path [O]; w+modelview [U-LP-4] + probe |
| Prologue `sub_4d13d4` | `FUN_004d13d4` state prologue | 87 insns: `0x0B53/0x0B52/0x0BA1/0x0B71/0x0B44/0x0B50/0x0B60/0x0D54/0x0BD0/0x0201/0x0C50/0x1D01/0x1D00` | 2 callers `0x4d10c8@0x4d121e`, `0x4d24d8@0x4d25de` | `0x8f58dc` 16 B `cdcc4c3e×3+0000803f`; `0x4d0ef0=5` | U-1/U-2 preserved [O]/[D] |
| Alpha `tiaAlphaFromIntensity` | RTTI `TOSWTextureImageAlpha` 9 names | 0 static xrefs on `0x4e6e58/0x4e9344` strings | property candidates `0x4ec07c/0x4ec0a0` refuted (=`ImageBrightness+0x2c`) | `reftilealpha.mat:31,139,248` value 1 | enum [O]; arithmetic [U-4b] + probe |
| Fog | `hf.pvl.smx3.frag` 4 modes + `shaders.lib` HeightField binding | `colors.lib:23,34-38` + `shaders.lib` text | no CODE fog uploads re-derived here | `FogMode=0/HFogMode=2/HFogStart=200` text | equation [O] text; effective mode [U-FOG] + probe |
| CallList | `FUN_00818920` `glNewList/EndList;ret` | 17 `glCallList` xrefs incl. 4 in `sub_7829a4` | 1 caller of `0x818920` (`0x8177f0@0x8179b6`) | `0x81937c/0x819b65/0x819b6a` raw tail | 1 list/cell [O]/[D]; call count [U-9b] + probe |

---

## 2. Evidence register (all `document: t_87f0f3c130b0` unless a donor path is shown)

Reused verbatim from the two parent DEC-U passes — no id is re-minted, no
address is moved:

| Evidence id | Operation | Establishes (pinned VA) |
|---|---|---|
| `ev_45d056bab2e241cc8f7ba1e1fdf699eba9ea626dec3d81809916b722efbfd` | raw `sub_88f3e8`, 85 insns | **material slot→enum**: `glMateriali 0x1601=GL_SHININESS`; `glMaterialfv 0x1600=GL_EMISSION, 0x1200=GL_AMBIENT, 0x1201=GL_DIFFUSE, 0x1202=GL_SPECULAR`; face arg1 (`0x0404=GL_FRONT` at caller) |
| `ev_b44f26b3…` (full `ev_b44f26b38e7f63961b71e1fdf699eba9ea626dec3d81809916b722efbfd`) | raw `sub_4d08bc`, 164 insns | **light slot→enum** `0x1200..0x1209` + per-light `glEnable(GL_LIGHT0+i)`/`glDisable`; `glMultMatrixf` before `GL_POSITION` at `0x4d0963` |
| `ev_39378c31c7258e7508e81325dcbb3e8503abd0b1cf43ada54de88bee37b9538f` | raw `sub_4d13d4`, 87 insns | prologue immediates incl. `0x4d13ec push 0xb53`, `0x4d1404/0x4d1412 push 0xb52`, `0x4d13f1 glLightModelfv` |
| `ev_76af8a18833c310d9e856ccf0fff9a47c326e29c708a27cb50c5d85d1c9dd8` | Deep `FUN_004d0de8` | renderer constructor: `+0x11c` colour object, `+0x123=DAT_004d0ef0` |
| `ev_0cb2b604f01084a08bf5f9fd532a946bf7408cf1c4e666986739aa24fc14ef` | bytes `0x8f58dc`, 16 B | `cdcc4c3e cdcc4c3e cdcc4c3e 0000803f` = `(0.2f,0.2f,0.2f,1.0f)` |
| `ev_b11e6a798ab4c1f0cc7ef8248bcd5265d96d72c3cb72c3cd92e5b5` | bytes `0x4d0ef0` | `05 00 00 00` → `byte[+0x123]=5`, `5&8==0` → `GL_FALSE` |
| `ev_7c5705141f44eeaa7e627bcdbb50a4e1a882c667e22b5da94b18eb6f0b7d9961` | `native_bytes_find` `tiaAlphaFromIntensity` | 2 CODE hits `0x4e6e58`, `0x4e9344` |
| `ev_5b7d6d88066e28d4eba9215c91fafba3fdf8e939e6ff8a1a2d8feab86c2019a` | bytes `0x4e6d80`, 384 B | RTTI 9 names; value 1 = `tiaAlphaFromIntensity` |
| `ev_3c3c92b18c10c8fb880ec99b616cbc7f1392aa3661a07e9ec72c24c7bbc94ee1` | xrefs `0x4e6e58` | 0 static xrefs |
| `ev_c6b5ab46f70762cbf2274a9f42811ce6c00629dfe47c3d2b34c78e5eda98cf16` | raw `sub_4ef810`, 224 insns | case 1 `0x4ef97d/0x4ef987` both `call sub_88f0f0` (cached ENABLE); `0x4ef995 glBlendFunc(0x302,0x303)`; cases 3/4 `glAlphaFunc(GL_GEQUAL,0.5/1.0)` |
| `ev_27eae37720f7f09c0bd487732270af4754c33d68bdef8959df834eaae98c56a17` | bytes `0x8fb0dc`, 256 B | cap table `[0]=0x0BC0 GL_ALPHA_TEST`, `[2]=0x0BE2 GL_BLEND` |
| `ev_8abea4014b499704b471a31daf78188556d46e543cccd8cdcc551c825922b9ec` | raw `sub_818920`, 1650 insns | `0x81937c glNewList(...,0x1300)`, `0x819b65 glEndList`, `0x819b6a ret`; `0x50` quad field offsets; `GL_QUADS=5` |
| `ev_56c5a3d724300e0daafc0ef4f475ed9e70a12fb6a6c0a83da7b57c1b6b84fa9` | `glCallList` xrefs | import `0x907cdc`, thunk `0x4afc7c`, 17 call sites (4 in `sub_7829a4`) |
| `ev_66723f092a1b3404abd5d2509b12512cd716b919368a84820788ed238f14` | callers of `0x818920` | exactly 1 direct caller `0x8177f0@0x8179b6` |
| `ev_ed96da32e89d1b6529a69d7c6e8f0a4b79181ac906da32cda4f34ea147a83` | `C:\Games\Cossacks 3\data\light.cfg` text | sun `(-0.344731152057648,0.938701450824738,0,W=1)` `lsParallel`; ambient/diffuse/specular floats |
| `ev_fadb2880f0f4e7dd3f2c25aae03687964c0a399ae644726c72d1c8e7c7d00b96cd` | `C:\Games\Cossacks 3\data\terrain\ref\reftile.mat` text | material `ambient 0.15686 / diffuse 0.78125 / emission 0 / specular 0 / shininess 16`, both faces; filters; face refkeys |
| `ev_c949cdfcb7df3b8fa8c96fee7b152c5cde66cd077cf64e9566927a954e5dcb` | `reftilealpha.mat` text | `ImageAlpha=1` for `alpha.bmp/alphavert.bmp/alphanull.bmp` |
| `ev_83d90ad0d5cfc53c272e6c79d18ea537016d4f900c4c386d77e3f9c04c7c52c` | `hf.pvl.sm.vert` text | `:18 sceneColor+ambient`, `:19 diffuse`, `:23 specular×shininess`, `:41-42 TexCoord[4]/[5]` |
| `ev_1122470077454cdfb1fc1c5b9ac1b953c2f0411d98738d9ce64207a779f18e4f` | `hf.pvl.smx3.frag` text | `:13 texUnit0.rgb`, `:14 texUnit1.a`, `:17 packed×spec`, 3-tap PCF, 4 fog modes `:34-46`, `:50 FragColor` |
| `ev_d6da102c8c9cdd531fb3cb180a63be12766d7322c61be88bda8bc2c0744d5b52` | `colors.lib` text | `FogMode=0`, fog `60,100,150/390/490`, `HFogMode=2/HFogStart=200`, shadow `140,140,140,128` |
| `ev_80043e7bf61b2f008364d06cdb5087c0688f644725190e9415c155c4b` | `shaders.lib` text | HeightField `texUnit0=0,texUnit1=1,texGen=true` |

Donor-text numbers reused without alteration: `light.cfg:3-38`, `reftile.mat:53-89,120-169`,
`reftilealpha.mat:30-37,139,248`, `reftile.lib` (`tsDouble/ttExtended`, insets
`0.1/0.2`), `colors.lib:23,34-38`, `shaders.lib:34-49`.

---

## 3. Terrain material — what is [O] and what stays [U]

### 3.1 Slot→enum map [O] (CODE, `sub_88f3e8`)

From `ev_45d056ba…` (85 insns, face in `ecx` passed as arg1):

| Site | Call | Immediate | GL name |
|---|---|---:|---|
| `0x88f418` | `glMateriali` | `0x1601` | `GL_SHININESS` |
| `0x88f446` | `glMaterialfv` | `0x1600` | `GL_EMISSION` |
| `0x88f474` | `glMaterialfv` | `0x1200` | `GL_AMBIENT` |
| `0x88f4a2` | `glMaterialfv` | `0x1201` | `GL_DIFFUSE` |
| `0x88f4d0` | `glMaterialfv` | `0x1202` | `GL_SPECULAR` |

One concrete caller, `FUN_005422c0`, passes `PTR_DAT_008fcac0 = 0x8f58dc`
(the same `0.2` grey vector as `sceneColor`) as the `GL_AMBIENT` source for
*a* material — so the `0.2` vector is reused both as light-model ambient and
as at least one material ambient. That binding is [O]; the terrain-draw
binding below is not.

### 3.2 Material floats [O] from TEXT, [U] at GL upload

Donor text (not CODE) gives the only numeric material source for terrain:

- `reftile.mat:53-55,81-83` ambient `0.15686` grey, both faces.
- `reftile.mat:59-61,87-89` diffuse `0.78125` grey, both faces.
- `reftile.mat:70-76,98-104` emission `0`, specular `0`, `shininess 16`.
- `reftile.mat:24-49` filters `maNearest/miNearestMipmapLinear`, wrap `twBoth`.

**Residual [U-LP-3b]:** which four float vectors the terrain HeightField draw
actually passes to the five `glMaterialfv/i` slots above. No static trace from
a terrain material refkey to `sub_88f3e8` arg2 was run under this charter, and
none is asserted. In particular the port must keep the **effective specular
product `vec3(0)`** (material `0 × light`) and must not substitute the bare
`light.cfg` specular `(0.278431,0.266667,0.211765)`.

Probe **P-MAT** (§7.1) terminates this [U] with zero mismatches.

### 3.3 Port status (already landed — PRESERVE)

`terrain_donor_mesh.gd:156-157` (`DONOR_MATERIAL_AMBIENT/DIFFUSE`),
`:1590-1596` (`material_ambient/diffuse/shininess/specular_rgb=0`,
`material_specular_rgb=0`); `terrain_donor_shader.gdshader:106-121,258-265`
(two-term ambient + diffuse, `specular_rgb×material_specular_rgb`,
`shininess=16.0`). These lines are correct and must not be renumbered into a
folded single ambient or a nonzero specular.

---

## 4. Light position/direction/w and modelview — what is [O] and what stays [U]

### 4.1 Submission path [O] (CODE, `sub_4d08bc` + prologue)

From `ev_b44f26b3…` (164 insns), per light index `i`:

- `glEnable(GL_LIGHT0+i)` when `byte[light+0xbc]` set, else
  `glDisable(GL_LIGHT0+i)`; unused slots `>= count` explicitly disabled.
- Enabled lights issue, in order: `0x4d0963 GL_POSITION (0x1203)` via
  `FUN_00890ccc(light+0xa4 or +0x44)` after `sub_4ca154`/`glMultMatrixf`;
  `0x4d09aa GL_AMBIENT (0x1200)`; `0x4d09c7 GL_DIFFUSE (0x1201)`;
  `0x4d09e4 GL_SPECULAR (0x1202)`; `0x4d0a1b GL_SPOT_DIRECTION (0x1204)`;
  `0x4d0a33 GL_SPOT_EXPONENT (0x1205)`; `0x4d0a4b/0x4d0a63 GL_SPOT_CUTOFF
  (0x1206)` or literal `0x43340000=180.0f` when non-positional;
  `0x4d0a7b/0x4d0a93/0x4d0aab GL_CONSTANT/LINEAR/QUADRATIC_ATTENUATION
  (0x1207/0x1208/0x1209)`.
- `hf.pvl.sm.vert:13` consumes
  `normalize(gl_LightSource[0].position.xyz - realpos.xyz)` with
  `realpos = gl_ModelViewMatrix × gl_Vertex (:9)`, `GL_NORMALIZE` enabled at
  `0x4d1426`, shade model `GL_SMOOTH` (`+0x125=0` → `0x4d14dd`).

### 4.2 Light numbers [O] from TEXT, [U] at GL upload

`light.cfg` text (`ev_ed96da32…`): active sun position
`(-0.344731152057648, 0.938701450824738, 0, W=1)`, `lsParallel`,
`Shining=true`, no attenuation/spot; ambient
`(0.19607843,0.18431373,0.12941177)`; diffuse
`(0.81176472,0.78039217,0.69411767)`; specular
`(0.27843139,0.26666668,0.21176471)`.

**Residual [U-LP-4]:** the `w` component and the modelview matrix actually
active when `glLightfv(GL_POSITION)` executes at `0x4d0963` (the
`sub_4ca154`/`FUN_00890ccc`/`glMultMatrixf` chain output). Because `w`
selects directional (`w=0`) vs positional (`w=1`) semantics in
`hf.pvl.sm.vert:13`, no port may hard-code "directional, no subtraction" as a
donor CODE fact — `lsParallel` is a text hint only.

Probe **P-LIGHT** (§7.2) terminates this [U].

### 4.3 Port status (already landed — PRESERVE)

`terrain_donor_mesh.gd:222-225` (`DONOR_AMBIENT/DIFFUSE/SPECULAR/SUN_POS`),
`:1592-1598` (`ambient_rgb/diffuse_rgb/specular_rgb=0/donor_sun_position`);
`terrain_donor_shader.gdshader:110-114,250-255` (`donor_sun_position`,
view-space `l`, `GL_NORMALIZE` analogue). Keep the `material_specular_rgb=0`
multiply at `:264-265`; never bind the bare light specular.

---

## 5. Alpha `tiaAlphaFromIntensity`, fog equation, callList count

### 5.1 U-4 `tiaAlphaFromIntensity` — enum [O], arithmetic [U-4b]

- Enum `TOSWTextureImageAlpha` at `0x4e6e28` (`ev_f438caef…`): `tkEnumeration`,
  21-byte name, flag `0x80000000`, max value `8`, table `0x4e6e24`. Name pages
  `0x4e6d80`/`0x4e9280` (`ev_5b7d6d88…`, `ev_c8049f68…`) give 9 values in
  order `0 tiaDefault, 1 tiaAlphaFromIntensity, 2 tiaSuperBlackTransparent,
  3 tiaLuminance, 4 tiaLuminanceSqrt, 5 tiaOpaque,
  6 tiaTopLeftPointColorTransparent, 7 tiaInverseLuminance,
  8 tiaInverseLuminanceSqrt`. `reftilealpha.mat:31,139,248` selects **value 1**
  for `alpha.bmp/alphavert.bmp/alphanull.bmp`.
- Both string copies have **0 static xrefs**; accessor candidates
  `0x4ec07c/0x4ec0a0` are refuted (they touch `+0x2c = ImageBrightness`).
  Function search hits the 6M-insn cap: coverage-limited negative, not proof
  of absence. Identity `A=intensity` is **[I] only**.

Probe **P-ALPHA** (§7.3): `glTexImage2D` upload dump for `GL_ALPHA (0x1906)`
`512×256`/`1024×512`, byte-compared to `V(idx)=max(0,idx-3)`.

### 5.2 Fog — equation [O] text, effective mode [U-FOG]

- Fragment `hf.pvl.smx3.frag:34-46` (`ev_11224700…`) implements 4 fog modes;
  `shaders.lib` binds HeightField `texUnit0/1 + texGen`; `colors.lib`
  (`ev_d6da102c…`) gives `FogMode=0` (OFF), fog colour `60,100,150`,
  `Start=390/End=490`, `HFogMode=2/HFogStart=200`, shadow `140,140,140,128`.
- `sub_4d13d4` at `0x4d1482` calls `sub_4d139c(byte[r+0x111],7,0x0B60)`;
  constructor leaves `+0x111=0`, so **`GL_FOG` is OFF at startup** [O]. Whether
  any later HeightField draw enables it is **[U-FOG]**.

Probe **P-FOG** (§7.4). Port keeps `fog_mode=0.0` / `shadow_enabled=0.0`
(`terrain_donor_mesh.gd:1605-1606`); no fog factor, no shadow sampler, no
`imagebrightness=1` deviation (`reftile.mat` identity).

### 5.3 Final `glCallList` count per cell — structure [O]/[D], count [U-9b]

- `FUN_00818920` builds **exactly one `glNewList(...,0x1300=GL_COMPILE)` per
  cell call** at `0x81937c` and **returns after the first qualifying layer
  descriptor** (`glEndList;ret 0x819b65/0x819b6a`); all layer quads are emitted
  inside that one list (`glBegin 5=GL_QUADS` per quad) in ascending quad-array
  order (base first). One caller only (`0x8177f0@0x8179b6`).
- `glCallList` import `0x907cdc`/thunk `0x4afc7c` has 17 generic call sites
  (`ev_56c5a3d7…`, 4 in `sub_7829a4` for material slots
  `+0xc8/+0xd0/+0xdc/+0xe4…`); none is proven to be the HeightField-list call.
  **Do not assert one or two `glCallList` per cell.**

Probe **P-CALL** (§7.5) counts executions of the HeightField list id per cell.

---

## 6. Remaining PORT1TO1 unknowns U3/U5/U7/U8/U11/U12/U13 (no invention)

| ID | Unknown | Why static read cannot close it here | Probe (see §7) |
|---|---|---|---|
| U-3 | Delphi LCG generation-time seed (`DAT_008f2008`, `FUN_00403a0c/004033b8`) | reseed path from `QueryPerformanceCounter/GetTickCount` not traced; stream sharing with other `Random` calls unknown | P-SEED: caller/xref trace + first-draw capture |
| U-5 | 13-byte record default template VA in loaded DATA | `0x8fab6c` is pointer-like (`ev_d12329f0…`); only `.rsrc` 9× `00*10 ff ff 00` hits (`ev_ff4fffbe…`); reader/writer `0x8302b0/0x82ed00` OOB branch not byte-read here | P-REC13: disassemble OOB branch + dump 13 B |
| U-7 | Effective `gl_EyePlaneS/T[0]` + `gl_TextureMatrix[0]` at ground draw | `sub_4be364` switches `0x84c1→0x84c0` around `glTexGenfv` (D08 §3.6); caller-supplied plane pointers + defaults `0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4` + matrix `0x8f4b44` not resolved to the HeightField caller | P-EYE: `0x4be364` caller-graph + plane/matrix dump |
| U-8 | Z-up→Y-up remap for `alphavert` face planes + normals | donor planes in `reftile.mat:120-169`; engine modelview/material transform before `glTexGenfv` (`FUN_004ec3f0`) not traced | P-FACE: `glTexGenfv` xref + transform capture |
| U-11 | Setter callers beyond DScript `0x6b1d50` | built-in xrefs report 0 for high VAs; Rizin `axt @ 0x8326b8` + `E8`-relative call-encoding scan not run under this charter | P-SETTER: byte scan + caller list or documented negative |
| U-12 | `record13 +4..+7` flag names, `+10/+11` controls | callers `0x80ec30/0x830d8c/0x830c68` + `value_flow` classification not run | P-FLAGS: per-corner clear/threshold trace + RTTI name match |
| U-13 | Visual parity | needs a donor GPU A/B frame; **not closeable** under read-only charter | stays OPEN, never waived |

U-R1 (runtime write to `0x8f58dc`/renderer copy), U-R2 (`byte[+0x123]` bit-3
toggle), U-6b (`GL_GEQUAL` leak into case 1), U-10b (`0x48→0x50` copy site at
`renderer+0x40` callback) from the parent reports remain open with the probes
already specified there and repeated in §7 for completeness.

---

## 7. Exact termination probes (authorised-trace hand-off; DO NOT RUN here)

General rule: **zero mismatches on the stated byte dump, or the [U] stays
open.** No threshold, lift, or LUT may be baked into the port before its probe
terminates.

### 7.1 P-MAT — terrain `glMaterialfv/i` values

1. With authorisation, break on the five sites in `sub_88f3e8`
   (`0x88f418/0x88f446/0x88f474/0x88f4a2/0x88f4d0`).
2. Filter on the terrain HeightField draw (list id from `FUN_0081a8e4`,
   material refkey `reftile.mat` normal path, both faces).
3. Dump `(face, pname, 4 floats / 1 int)` per hit across one skirmish frame.
4. Terminate when the dumped vectors equal the port uniforms
   (`ambient 0.15686, diffuse 0.78125, emission 0, specular 0, shininess 16`)
   with **zero float mismatches**, or emit the captured vectors and amend §3.2.

### 7.2 P-LIGHT — position `w` + modelview

1. Break on `0x4d0963 glLightfv(GL_POSITION)`; read `FUN_00890ccc` output and
   the `sub_4ca154`/`glMultMatrixf` matrix.
2. Dump `(x,y,z,w)` + 16-float modelview per terrain light setup.
3. Terminate when `(x,y,z,w)` matches `light.cfg:26-29` transformed by the
   dumped matrix with zero mismatches, fixing `w=0` vs `w=1` and whether the
   `hf.pvl.sm.vert:13` subtraction is live. Until then keep the port's
   view-space `l` labelled `[U engine]`
   (`terrain_donor_shader.gdshader:252-253`).

### 7.3 P-ALPHA — `tiaAlphaFromIntensity` arithmetic (repeats DEC_U_alpha §3.3)

After `reftilealpha.mat` parse assert `ImageAlpha==1`: break on
`glTexImage2D` with `format==GL_ALPHA (0x1906)` and `512×256`/`1024×512`;
dump pixels (131072/524288 B); compare to `V(idx)=max(0,idx-3)`:
`A==V` → identity; `A==255-V` → complement;
`A==round(255·sqrt(V/255))` → sqrt; else emit 256-entry `idx→A` LUT.
Terminate on zero mismatches on both textures with sentinels `p=0,16→255`,
`p=15,31→0`. No identity assumption before then
(`terrain_donor_mesh.gd:2180-2188` already labels this [U]).

### 7.4 P-FOG — effective fog at terrain draw

GL-trace `glEnable(GL_FOG)` / `glFogfv/glFogi` vs `sub_4d13d4` case
`0x4d1482` order in a live frame; read the fragment uniform/mode actually
active at the HeightField draw. Terminate when the observed
`(mode, colour, start, end)` matches `FogMode=0` (no fog) with zero mismatches
or captures the enabling draw. Port keeps `fog_mode=0.0` until then.

### 7.5 P-CALL — `glCallList` count per cell

Break/trace `glCallList` thunk `0x4afc7c` filtered on the list id returned by
`FUN_0081a8e4` for the HeightField record; count executions per cell with
material-state order. Terminate on a counted calls-per-cell number with the
state order attached. The two Godot surfaces stay labelled a state
translation regardless of the count.

### 7.6 Remaining probes (one line each; full instruments in parent reports)

- **P-SEED (U-3):** callers of `FUN_004033b8` + xrefs of `DAT_008f2008`;
  decompile the reseed path; terminate with seed source + first draw index.
- **P-REC13 (U-5):** disassemble `0x8302b0/0x82ed00` OOB branch; dump the 13 B
  template VA; reject `.rsrc` hits.
- **P-EYE (U-7):** study `0x4be364` + caller graph to the HeightField draw;
  dump `EyePlaneS/T + TextureMatrix`; terminate with VA + 4 floats per plane.
- **P-FACE (U-8):** xrefs of `glTexGenfv` + `FUN_004ec3f0`; capture the
  S/T transform; terminate with the matrix applied to front/side planes.
- **P-SETTER (U-11):** Rizin `axt @ 0x8326b8` + `E8`-relative encoding scan;
  terminate with a caller list or a documented negative.
- **P-FLAGS (U-12):** callers `0x80ec30/0x830d8c/0x830c68` + value-flow per
  corner; terminate with RTTI enum names if present.
- **P-R1/R2/6b/10b:** as specified in `DEC_U_scenecolor_glstate.md` §7 and
  `DEC_U_alpha_pass_quad.md` §8 (hardware watch on `0x8f58dc` /
  `renderer+0x123`, `glAlphaFunc` vs case-1 order, `renderer+0x40` callback
  copy loop).

---

## 8. Exact port change list (SPEC ONLY — no file edited by this worker)

**Preservation guard (do not touch):** `scene_color = vec3(0.2,0.2,0.2)`
(`terrain_donor_shader.gdshader:122`; `terrain_donor_mesh.gd:101-102,1597,2199-2203`),
two-sided `GL_FALSE` telemetry (`mesh:103-107,2204-2208`; `shader:129-132`),
`GL_ALPHA_TEST ENABLED` comments (`shader:93-99`; `mesh:1838-1848`),
one-list-per-cell comments (`shader:47-49`; `mesh:2002-2006,2162-2170`),
`0x48/0x50/+0x0b` constants (`mesh:112-121,1869-1897`; `shader:23-27`), and
the `material_specular_rgb=0` multiply (`shader:264-265`; `mesh:1594-1595`).
Any edit below must keep these lines byte-identical in meaning.

| # | File:line (current) | Change (spec; owner applies) | Donor basis | Behaviour |
|---|---|---|---|---|
| R-1 | `terrain_donor_mesh.gd:106-110` after `DONOR_TWO_SIDE_GL_FALSE` | ADD `const DONOR_MAT_SLOTS := {"SHININESS": 0x1601, "EMISSION": 0x1600, "AMBIENT": 0x1200, "DIFFUSE": 0x1201, "SPECULAR": 0x1202}` + `const DONOR_LIGHT_SLOTS := [0x1203,0x1200,0x1201,0x1202,0x1204,0x1205,0x1206,0x1207,0x1208,0x1209]` as **telemetry constants only** (no binding change) | `ev_45d056ba…`, `ev_b44f26b3…` §3.1/§4.1 | none; documents the landed uploader map |
| R-2 | `terrain_donor_mesh.gd:2190-2210` `_donor_lighting` dict | ADD keys `"material_slots": "0x1601(i)+0x1600/0x1200/0x1201/0x1202(fv) (ev_45d056ba)"`, `"light_position_site": "0x4d0963 GL_POSITION(0x1203) after sub_4ca154/glMultMatrixf [U-LP-4 w+modelview]"`, `"light_model_ambient_site": "0x4d13f1 GL_LIGHT_MODEL_AMBIENT(0x0B53) [O] (0.2,0.2,0.2,1.0)"` | parent §7 U-LP-3b/U-LP-4 | telemetry only |
| R-3 | `terrain_donor_mesh.gd:2180-2188` `_donor_alpha` | KEEP the [U-4b] text verbatim; ADD `"probe": "P-ALPHA §7.3 (GL_ALPHA 512×256/1024×512 dump, zero-mismatch LUT)"` | `ev_5b7d6d88…` enum=1 | telemetry only |
| R-4 | `terrain_donor_mesh.gd:1605-1606` (`shadow_enabled/fog_mode`) | KEEP `0.0/0.0`; ADD comment `# [U-FOG] P-FOG §7.4: GL_FOG off at startup (0x4d1482, +0x111=0); HFogMode=2/HFogStart=200 text only` | `ev_d6da102c…`, `0x4d1482` | none |
| R-5 | `terrain_donor_mesh.gd:1709` (`terrain_draw_calls_expected`) | KEEP value; EXTEND comment to `"Godot surfaces only; ONE donor glNewList/cell [O]/[D] U-9 (0x81937c/0x819b65/0x819b6a); [U-9b] P-CALL §7.5 glCallList@0x4afc7c count open"` | `ev_8abea401…`, `ev_56c5a3d7…` | none |
| R-6 | `terrain_donor_shader.gdshader:110-114` | KEEP all five uniforms; ADD comment `# P-LIGHT §7.2: w+modelview at 0x4d0963 [U-LP-4]; lsParallel is text-only` | `ev_ed96da32…` | none |
| R-7 | `terrain_donor_shader.gdshader:119-121` | KEEP `material_ambient/diffuse/shininess`; ADD comment `# P-MAT §7.1: terrain glMaterialfv vectors [U-LP-3b] at 0x88f446/474/4a2/4d0; effective specular stays vec3(0)` | `ev_45d056ba…`, `ev_fadb2880…` | none |
| R-8 | `terrain_donor_shader.gdshader:122-128` | KEEP `scene_color = vec3(0.2,0.2,0.2)` **exactly**; no fold, no `0.0`, no `light.cfg`/*colors.lib* substitution | `ev_0cb2b604…` U-1 CLOSED | none (guard) |
| R-9 | `terrain_donor_shader.gdshader:250-255` | KEEP `l` computation; KEEP `[U engine]`/`[U normal matrix]` labels (P-LIGHT/P-EYE) | §4.1 | none |
| R-10 | No other lines | NO other mesh/shader edit. In particular: no `rgb*=a`, no `alpha_scissor`/`discard` threshold, no `textureGrad`/LOD inset, no `sampler2DArray` migration, no fog/shadow/gamma fill, no second brightness constant | PORT1TO1 §8.6, X17 §3.2 | preserves landed behaviour |

Applying R-1..R-9 changes **zero pixels**: all are constants/comments/
telemetry. Any numeric port change before its §7 probe terminates would be a
PORT APPROXIMATION and must be labelled as such, never as a donor recovery.

---

## 9. Delta versus the starting reports / bottom line

| Prior claim | This pass | Status |
|---|---|---|
| PORT1TO1 U-1/U-2 open | preserved as CLOSED [O]/[D] from `DEC_U_scenecolor_glstate` §§3–4; re-cited with VAs `0x8f58dc/0x4d13f1/0x4d1404/0x4d1412` | **Preserved, not re-proven** |
| PORT1TO1 U-4/U-6/U-9/U-10 open | preserved as enum-[O]/ENABLED-[O]/1-list-[O]/map-[O] from `DEC_U_alpha_pass_quad` §§3–6 with residuals U-4b/U-6b/U-9b/U-10b | **Preserved** |
| `DEC_SMALL` U-LP-3 slot→enum half | re-typed as 5-row table (§3.1); terrain float binding stays [U-LP-3b] + P-MAT | **Half closed, half probed** |
| `DEC_SMALL` U-LP-4 path | re-typed as 10-pname table (§4.1); `w`+modelview stays [U-LP-4] + P-LIGHT | **Path closed, values probed** |
| U3/U5/U7/U8/U11/U12/U13 | no static closure claimed; each gets a named probe with zero-mismatch termination (§§6–7) | **All stay [U], none waived** |
| Current mesh/shader GLSTATE lines | verified line-by-line; §8 preserves every landed edit | **No behaviour change proposed** |

**Bottom line.** The fixed-function material uploader (`0x1601/0x1600/0x1200/
0x1201/0x1202`), the per-light uploader (`0x1200..0x1209` + `GL_LIGHT0+i` +
`glMultMatrixf`), the light-model prologue (`0x0B53` + `0x0B52/GL_FALSE` +
`GL_NORMALIZE`/`GL_SMOOTH`), the `tiaAlphaFromIntensity=1` enum, the
4-mode fog equation with startup-OFF state, and the one-`glNewList`-per-cell
structure are all byte- or text-proven and already landed in the port. The
terrain `glMaterialfv` floats, the light `w`/modelview, the
intensity→alpha arithmetic, the effective fog at terrain draw, the final
`glCallList` count per cell, and U3/U5/U7/U8/U11/U12/U13 remain [U], each
with an exact authorised-trace probe above that terminates only on zero
mismatches. **No approximation is presented as donor fact and no donor visual
parity is claimed.**

*End of DEC-U-RENDERER-RESIDUAL. READ-ONLY: one repo file written (this
report); no binary executed/copied; no code, shader, config, asset, test, git
or Godot state changed. Active target unchanged: `t_87f0f3c130b0`.*
