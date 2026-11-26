---
id: DEC-VIS-03
ticket: "TERRAIN-VISUAL-WAVE-2026-11-26 / DEC-VIS-03"
title: "Donor field/crop rendering pipeline, stage machine, native material state, and alpha-scissor assessment"
owner: "DEC-VIS-03 (read-only worker reporting to COORD)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE__NO_GODOT__NO_GIT
labels: [O, D, I, U, "PORT APPROXIMATION"]
visual_parity_claim: false
scope: "Exactly one repository file written: this report. No source, asset, config, test, shader, fixture, result JSON, git or Godot state changed. Donor files were read only; no donor binary was executed or copied."
donor_root: "C:\\Games\\Cossacks 3\\data (READ ONLY)"
native_targets:
  cossacks: "t_87f0f3c130b0 / cossacks.exe / SHA-256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
  editor: "t_68474ddde43f / editor.exe / SHA-256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab"
---

# DEC-VIS-03 — donor field/crop rendering pipeline

> **NO DONOR PARITY CLAIM.** No donor GPU A/B frame exists and no Godot job was run.
> Third-party donor video establishes only the direction of appearance: fields read as
> golden, textured parcels. Exact final donor pixels remain UNVERIFIED.

## 0. Executive summary

1. **[O] F07/X22's “no time-based crop stages” conclusion is refuted.** The donor has an
   explicit food-resource state machine in `env/env.inc/nothing.inc` and material swaps in
   `env/env.inc/ontagstates.inc`: four growth stages over **87.5 s**, mature material
   **`field`**, harvest/regrowth materials **`field5`/`field6`**, first-depletion material
   **`field7`**, and winter twins with **`w`** suffixes.
2. **[O] Donor stage variety is not random material selection.** `field.prop:48` says
   `RandomMaterialName = False`; the state machine chooses the material. Only the crop mesh
   is random (`RandomMeshName = True`, three meshes).
3. **[O] Exact crop material state:** inherited `bmAlphaTest50`, `fcNoCull`, `tmModulate`,
   `tmmUser`, wrap both, linear/linear-mipmap filtering. Native code implements
   `bmAlphaTest50` as **blend off + alpha test on + `glAlphaFunc(GL_GREATER, 0.5)`**.
   The port's `ALPHA_SCISSOR` at `0.5` matches the intent and no-blend state, with an
   equality-boundary caveat.
4. **[O] Exact authored material constants:** `field`/`fieldw` Emission is
   `(232,218,195)/255`; `field1..7`/winter twins use neutral `200/255`; all field crop
   materials set Ambient and Diffuse RGB to zero. **No emission-energy scalar exists.**
   The port's `0.22` energy is a PORT APPROXIMATION.
5. **[O]/[D] Important shader correction:** `field.actor` inherits `reftree.actor`
   **ShaderID 6**, i.e. `tree.pvl.id6.vert/frag`, not the `Default` shader assumed by
   FCOL-02/03. That shader computes `tex0*(ambient+diffuse)+specular` and never reads
   `gl_FrontMaterial.emission`. Native state code does call `glMaterialfv(GL_EMISSION, ...)`,
   but whether the runtime injects that value into the custom-shader path is **[U]**.
6. **[O] A donor field is two layers:** the alpha-tested crop mesh **and** an attached
   `envfieldd`/`envfielddw` ground decal. The decal uses angle `45`/`225`, size multiplier
   `1.3`, UV scale `1.3`, and UV offset `-0.15`. The legacy 3D port records decal paths in
   telemetry but never renders the decal.
7. **[D] Why the legacy port showed black squares:** the bound `field1.png` is a cut-out
   whose transparent background is black; the old material rendered it opaque, so those
   texels became black squares. The port also uses growth-stage art (`field1`) for every
   state and omits the mature `field` art and the ground-decal layer. COORD's alpha-scissor
   patch fixes the square-background mechanism, **not** the remaining stage-art, decal,
   shader, tint, or scale differences.
8. **[O] Native contradiction corrections:** direct table bytes and assembly refute the
   earlier D08/FCOL-02 claims that `bmTransparency` uses source-alpha factors and that the
   alpha comparator is `GEQUAL`. The recovered generic state is
   `GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA` and `GL_GREATER`. A decal-specific override is
   still [U]; the crop itself does not use blending.

---

## 1. Method, labels, and pass ledger

- **[O]** literal donor/repo bytes, source lines, or native instructions read here.
- **[D]** deterministic arithmetic or control-flow derivation from [O].
- **[I]** interpretation without a donor/port same-camera A/B.
- **[U]** unresolved after the passes below.
- **PORT APPROXIMATION** means port-authored behavior, not donor truth.

| Pass | Instrument | Scope and result |
|---|---|---|
| 1 | Read-only file reads | Charter, F07, X22, FCOL-01/02/03, HANDOFF fix/follow-up, donor video analysis, current `world3d_entities.gd`, `terrain_donor_props.gd`, OBJ/MTL, donor materials/props/scripts/shaders. |
| 2 | Targeted corpus grep | `field`, `worktransorm`, `gc_FieldMaxHP`, stage tags, material suffixes, shader IDs, and native enum/string anchors. This exposed the crop state machine missed by the earlier static asset scans. |
| 3 | Full decisive source reads | `env.inc/nothing.inc`, `ontagstates.inc`, `initial.inc`, `field.prop`, `refbase.mat`, `env.mat`, `field.actor`, `reftree.actor`, ShaderID6 and decal shaders. |
| 4 | Craft Anything Deep native analysis | Decompilation/disassembly of `cossacks.exe` material state, GL thunks, enum tables, blend/alpha tables, texture-mode tables, and material-property setters. Every native call pinned `document: t_87f0f3c130b0`; editor calls pinned `t_68474ddde43f`. Global active target was not changed. |
| 5 | Contradiction recheck | Re-ran the stage, emission, blend, comparator, and black-square conclusions against a second independent source or raw table/assembly. Results are in §9. |

**Encoding note:** donor `.script`/`.inc` text contains non-UTF-8 Cyrillic comments elsewhere.
The decisive numeric/code ranges are ASCII and were cross-read with the normal read tool and
Craft Anything text evidence. Line numbers below are 1-based.

---

## 2. End-to-end donor pipeline

### 2.1 Creation and placement

`_unit_DoSeedWheat` creates a `field` object at each accepted lattice node
(`unit.script:6468-6570`; evidence `ev_4361afffb28afbce18982dc2e13f2fe2b74b6441d64062a2da6c11ed5ff57a3f`).
The existing F07/X22 placement derivation remains valid and is not repeated here.

The object prop supplies:

| Property | Donor value | Source |
|---|---|---|
| Mesh actor | `field.actor` → `field1/2/3.osm` | `field.actor:1-11` |
| Mesh selection | `RandomMeshName = True`, all three usable | `field.prop:30-38` |
| Material selection | `RandomMaterialName = False`; stage machine overrides | `field.prop:41-76` |
| Season selection | `UseSeasonMaterial = True` | `field.prop:58,87,112` |
| Scale | `(0.03605085, 0.03605085, 0.03605085)`, no random scale | `field.prop:139-146` |
| Roll | `DefaultRollAngle = 45` | `field.prop:148-150` |
| Ground attachment | inherited `AutoOffset = True`, `OffsetCollideOption = ocoTerrain` | `refenv.prop:284-298` |

Evidence: `ev_293916abac66d18e7397d0ea6610169db1742e9daeab1309b000e81f58d0b222`,
`ev_5cbad35a82f734781efe0c5e14fb840778f3e4c0b3246912b623cb84e18e8d38`.

### 2.2 Dressing: crop mesh plus ground decal

`WriteNewP` creates the field object and calls `_misc_PlaceFieldDecal` with scale `60` and
angle `45` or `225`, selected by `random > 0.5`
(`writenewp.inc:20-29`; `ev_99021784ab0082a89ccfaf1d6d1231d6b7b4bf6fc3ae655d5915124a6d633dd5`).

`_misc_PlaceFieldDecal` (`misc.script:4284-4306`;
`ev_824a8adcb1ebeb26f9d4dc854397652a9a9260c048270270b9dfcbc61891b020`) sets:

```text
decalname = envfieldd
goScale = GetGameObjectScaleXByHandle(field)
w = h = 60 * goScale * 1.3
texScale0 *= 1.3
texScale1 *= 1.3
texOff0 = texOff1 = -(1.3 - 1)/2 = -0.15
```

The descriptor supplies `width = height = 2`, summer `envfieldd`, winter `envfielddw`,
default epsilon `0.01`, UV rotation/scale/offset enabled, vertical flip enabled
(`decals.lib:1-44`; `ev_52c03176f45e976fdb26fa442b9b5e704e5f64bf166c77a06e653851d18f0436`).

**[D]** `60 * 0.03605085 * 1.3 = 2.812` in the decal API's units. Those units remain
**[U]**; do not silently call this metres. The crop mesh's native X span is about
`58.518572 * 0.03605085 = 2.1096` in donor object units.

---

## 3. Exact crop growth, harvest, regrowth, and material rules

This is the decisive correction to F07 §4.1 and X22 §6/§8.

### 3.1 Initialization

`env/env.inc/initial.inc:42-104` identifies `field` as food and sets:

```text
restype = gc_resource_type_food
states = essential_birth | visual_stage_0
hp = 0
brised = False
timetransormlast = GetGameTime()
worktransorm = 1
```

Evidence: `ev_f9815a7b00ee2b722b897cee2938785316e2bddbb45dc75156182b97ba2c098e`.
Global constants: `gc_FieldMaxHP = 25000`, visual stages are bits 21..24
(`dmscript.global:26-29,128`; `ev_0e6fc3cc88880ff39e6361f9879acba22a78f3cf1e96b14fa89cca7d00758e35`).

### 3.2 Growth stages

`env/env.inc/nothing.inc:38-57`:

```text
cFieldGrowTime = 4 * 21.875 = 87.5
progress = (GetGameTime() - timetransormlast) / 87.5
stage = floor(progress * 4)
visual_stage = stage_0 .. stage_3
on change: states = essential_birth | visual_stage
when growtime > 87.5:
    states = essential_none | visual_stage_0
```

`env/env.inc/ontagstates.inc:126-139` maps birth stages to material names:

| Visual state | Summer material | Winter material | Authored Emission RGB |
|---|---|---|---|
| `visual_stage_0` | `field1` | `field1w` | `(200,200,200)/255` |
| `visual_stage_1` | `field2` | `field2w` | `(200,200,200)/255` |
| `visual_stage_2` | `field3` | `field3w` | `(200,200,200)/255` |
| `visual_stage_3` | `field4` | `field4w` | `(200,200,200)/255` |

At maturity, `essential_none | visual_stage_0` enters the other branch in
`ontagstates.inc:107-123`: suffix is empty for stage 0, HP becomes `25000`, `brised = True`,
and the material becomes **`field`/`fieldw`**, whose authored Emission is warm
`(232,218,195)/255`.

| Approximate growth interval | Material |
|---|---|
| `0 <= t < 21.875` | `field1`/`field1w` |
| `21.875 <= t < 43.75` | `field2`/`field2w` |
| `43.75 <= t < 65.625` | `field3`/`field3w` |
| `65.625 <= t <= 87.5` | `field4`/`field4w` |
| `t > 87.5` | mature `field`/`fieldw` |

The source uses strict `>` at the 87.5 s maturity check and `floor(progress*4)` below it.
An exact floating-point boundary can produce stage 4 with no matching `case` arm; that edge
is **[U]** and should not be “fixed” by inventing a donor rule.

Evidence: `ev_82ce8c0ec78d96f8ff8aabfdd8e4a0faf6678fc643a759d49d3fa0f225ba0429`,
`ev_8ffcf086c5a6a9a904372576efcfdffe568eb4d1d0f05637ca9cf9198a514dd7`.

### 3.3 Harvested and regrowing states

When `brised = True`, `nothing.inc:59-90` chooses the visual state from HP:

| HP | Visual state | Material via `ontagstates.inc:112-123` |
|---:|---|---|
| `hp >= 13000` | `visual_stage_0` | `field`/`fieldw` |
| `5000 <= hp < 13000` | `visual_stage_1` | `field5`/`field5w` |
| `0 <= hp < 5000` | `visual_stage_2` | `field6`/`field6w` |

If `hp < 25000`, the field is in visual stage 0, and more than **31.25 s** has elapsed:

```text
hp = Min(hp + Floor(25000 * random * 0.1), 25000)
timetransormlast = GetGameTime()
```

The random term is `0..0.1` of max HP; zero gain is possible. There is no continuous tint
or scale interpolation in the donor script.

### 3.4 Depletion, one regrowth, and destruction

When `hp < 0` (`nothing.inc:63-69`):

- `worktransorm = 1` → `essential_death | visual_stage_0`.
  `ontagstates.inc:82-95` sets `hp = 0`, records the time, decrements `worktransorm` to 0,
  and selects **`field7`/`field7w`**.
- After **21.875 s** in death (`nothing.inc:29-34`), the field returns to
  `essential_birth | visual_stage_0` and grows again through `field1..4` to `field`.
- On the next depletion with `worktransorm = 0` → `essential_death | visual_stage_1`:
  the object executes `OnDestroy`, becomes invisible/non-playable, and is destroyed after
  `gc_unit_deathtime_3 = 4` s (`ontagstates.inc:96-105`; `dmscript.global:190`).

**Conclusion:** the donor has growth and regrowth stages. `field5/6/7` are not “unreferenced”;
the earlier static scan missed dynamically constructed names (`basename + '7'`, suffixes
`'5'`/`'6'`). The port's four labels are conceptually similar but its colors, alpha, scales,
60 s regrow, and state thresholds are not the donor rules.

---

## 4. Exact material and native render-state constants

### 4.1 Authored material table

All crop materials inherit `refbase.mat` and override only texture and lighting RGB.
`refbase.mat:17-38,52-106` supplies:

| State | Donor value |
|---|---|
| Blending | `bmAlphaTest50` |
| Face culling | `fcNoCull` |
| Shader field | `[nil]` in the material; actor ShaderID selects the object shader (§5) |
| Fog / no-lighting options | `moIgnoreFog = False`, `moNoLighting = False` |
| Texture brightness / gamma | `1` / `1` |
| Alpha mode | `tiaDefault` |
| Texture combine | `tmModulate` |
| Mapping | `tmmUser` |
| Wrap | `twBoth` |
| Filters | `maLinear`, `miLinearMipmapLinear` |
| Diffuse/specular alpha | `1`; specular RGB `0` |
| Shininess | `16` |

`env.mat` then sets, for both front and back:

| Materials | Ambient RGB | Diffuse RGB | Emission RGB |
|---|---|---|---|
| `field`, `fieldw` | `0` | `0` | `0.909803926944733, 0.854901969432831, 0.764705896377563` = `(232,218,195)/255` |
| `field1..7`, `field1w..7w` | `0` | `0` | `0.78125, 0.78125, 0.78125` = `(200,200,200)/255` |

Evidence: `ev_148480a89b31e600f2742414e397f75bf5babb5e0c4897f0830be69c1354c465`,
`ev_d1bc1129d71f9a2306cad636ec4a0838177f7610b539276015cc3290803643ed`,
`ev_de2e371fcd66ed8db9227f11e55a58be45cbd59387ed2b786535f1af4d9c7523`.

**There is no separate emission energy field.** Native `sub_88f3e8` sends the four RGBA
floats directly to `glMaterialfv(face, GL_EMISSION, value)`. Any scalar energy in the port is
not a donor constant.

### 4.2 Native enum order and alpha-test implementation

Raw RTTI bytes in `cossacks.exe` at `0x4e87a0..0x4e8910` give:

```text
bmOpaque=0, bmTransparency=1, bmAdditive=2,
bmAlphaTest50=3, bmAlphaTest100=4, bmModulate=5
fcBufferDefault=0, fcCull=1, fcNoCull=2
moIgnoreFog=0, moNoLighting=1
```

Evidence: `ev_c541581878dbd56af0abc4ab5b8af9128ae505c046f87c0be856bdd3675e0f61`.

Material state is applied by `sub_4ef810` (`0x4ef810`). Its blend jump table at `0x4ef949`
maps mode 3 to `0x4ef9c1`. The decisive instructions are:

```asm
0x4ef9c4  mov dl, 2
0x4ef9c6  call sub_88f148       ; glDisable(table[2]) = GL_BLEND
0x4ef9ce  xor edx, edx
0x4ef9d0  call sub_88f148       ; glDisable(table[0]) = GL_ALPHA_TEST
0x4ef9d8  xor edx, edx
0x4ef9da  call sub_88f0f0       ; glEnable(table[0])  = GL_ALPHA_TEST
0x4ef9df  push 0x3f000000       ; 0.5f
0x4ef9e7  mov dl, 7
0x4ef9e9  call sub_88fb34       ; glAlphaFunc(table[7], 0.5f)
```

The alpha-function table at `0x8fb18c` has `table[7] = 0x204 = GL_GREATER`.
Therefore:

```text
donor bmAlphaTest50 = GL_BLEND off, GL_ALPHA_TEST on,
                     glAlphaFunc(GL_GREATER, 0.5f)
                     i.e. keep alpha > 0.5
```

Evidence: `ev_c6b5ab46f70762cbf2274a9f42811ce6c00629dfe47c3d2b34c78e5eda98cf16`,
`ev_2cbc210c940a45eb799e796a833175b8f5c1941fdbb5727a6c875b9f4cfed8ee`,
`ev_778088da1636eb21993ba4fe26056dd297cea11dbb42bbad19b6a54a2b78fb6e`.

`fcNoCull = 2` follows the no-cull/back-material path in `sub_4ef810`; the port's
`CULL_DISABLED` is the correct translation.

### 4.3 Native blend correction for `bmTransparency` / `envfieldd`

`sub_88fb78` caches and applies blend factors. Assembly, not the lossy pseudo-C, is
decisive:

```asm
0x88fba2  mov al, cl
0x88fba4  mov eax, [eax*4+0x8fb1ac]
0x88fbab  push eax                 ; destination factor
0x88fbae  mov al, dl
0x88fbb0  mov eax, [eax*4+0x8fb1ac]
0x88fbb7  push eax                 ; source factor
0x88fbb8  call glBlendFunc@thunk
```

Mode 1 loads `dl=6`, `cl=7`. Raw table `0x8fb1ac` maps:

```text
index 4 -> 0x302 GL_SRC_ALPHA
index 5 -> 0x303 GL_ONE_MINUS_SRC_ALPHA
index 6 -> 0x304 GL_DST_ALPHA
index 7 -> 0x305 GL_ONE_MINUS_DST_ALPHA
```

`glBlendFunc@thunk` at `0x4afb14` is a direct jump to the imported `glBlendFunc`.
Thus the generic material-state result is:

```text
bmTransparency: glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA)
result: dst.rgb = src.rgb * dst.a + dst.rgb * (1 - dst.a)
        (source alpha is not the blend factor in this generic state)
```

Evidence: `ev_5071f34e67c6214d7a00cc21b9e1eec5596477010b3e42b4f2deaf886017cfde`,
`ev_4992d0018f1302c53068a8f6e1cd0da4137f72b508647a3008bbe770bdc0fc6d`,
`ev_0287c1001da10a3c5084f81af87c00d2c3948289ad97d06f3c885ce7d52cba73`.

This refutes the earlier D08/FCOL-02 source-alpha reading. It does **not** affect the crop
patch, because `bmAlphaTest50` disables blending. Whether the decal renderer overrides the
generic state remains [U] (§11).

---

## 5. Shader path and the emission caveat

### 5.1 Field actor selects ShaderID 6

`field.actor:1` inherits `reftree.actor`. `reftree.actor:1-5` sets both `ShaderID` and
`ShaderIDNoBones` to **6**. `shaders.lib:531-557` binds ID6 to:

```text
tree.pvl.id6.vert
tree.pvl.id6.frag
```

Evidence: `ev_5cbad35a82f734781efe0c5e14fb840778f3e4c0b3246912b623cb84e18e8d38`,
`ev_5b02fe60d1b3dd6f85878edde1eac971f76383138b3c91d9b7010087431de990`.

The readable ShaderID6 formula is:

```glsl
ambient  = gl_FrontLightModelProduct.sceneColor + gl_FrontLightProduct[0].ambient;
diffuse  = max(dot(l,n),0.0) * gl_FrontLightProduct[0].diffuse;
specular = pow(max(dot(h,n),0.0), shininess) * gl_FrontLightProduct[0].specular;
if (vertexColor == 1) {
    diffuse *= gl_Color * 2.5;
    ambient *= gl_Color * 2.5;
    // postProc[4] luminance floor follows
}
color.rgb = tex0.rgb * (ambient + diffuse) + specular;
color.a   = tex0.a * gl_FrontMaterial.diffuse.a;
```

Evidence: `ev_b2275dd7f7cba7dca3bcfa6fccbe408edae75b602495665441e66b81e4746d94`,
`ev_9f74e5ce6f28cea071e028224cbdd845e948e734bc826add22927e6eb926ba07`.

**No shader source reads `gl_FrontMaterial.emission`.** Native `sub_88f3e8` does set
`GL_EMISSION` (`0x1202`) from the material, but the readable ShaderID6 path does not sample
it. Consequently:

- **[O]** the material contains warm/neutral Emission constants;
- **[O]** the native fixed-function setter uploads them;
- **[U]** the runtime custom-shader binding may transform or inject state not visible in
  these sources;
- **[D]** FCOL-02/03's claim that emission is demonstrably multiplied into the crop through
  the `Default` shader is not established and uses the wrong shader for `field.actor`.

With authored Ambient/Diffuse/Specular zero and no demonstrated vertex-color/luminance
input, the readable ShaderID6 formula predicts black crop RGB. That makes the ground decal
and/or unobserved runtime state essential to the visible golden parcel. Do not “fix” this by
declaring the port's additive emission donor-exact.

### 5.2 Ground-decal shader

`decals.mat:1-37,110-115` defines `envfieldd/w` as:

| Property | Value |
|---|---|
| Blending | `bmTransparency` |
| Culling | `fcCull` |
| Fog | `moIgnoreFog = True` |
| Lighting | `moNoLighting = False` |
| Ambient RGB | `0.15686` |
| Diffuse RGB | `0.78125`, alpha `1` |
| Emission / Specular | `0` |
| Shininess | `16` |
| Brightness / Gamma | `1` / `1` |
| Texture mode / mapping | `tmModulate`, `tmmUser` |
| Filters / wrap | linear, linear-mipmap-linear, both |

The decal shader uses `gl_TextureMatrix[0] * gl_MultiTexCoord0`, then:

```glsl
color.rgb = tex0.rgb * (ambient + diffuse) + specular;
color.a   = tex0.a * gl_FrontMaterial.diffuse.a;  // diffuse.a = 1
```

Evidence: `ev_7888568829a607a344016cd63f6c215ddef2e4aa48482a0de8a9794a2c2b36c0`,
`ev_e1ec76795576e770b7195350dc891938d8311c2f6fcebfa5d4d3f81592f29c5a`,
`ev_7b259c8d7515cff5569e80022e50264625bb0d25e90bc3d3554619bd77ce5b69`.

---

## 6. UVs, mesh, and placement details

- **Crop UVs:** `tmmUser` is mapping-mode enum 0. Native `sub_4ec3f0` jump table
  `0x4ec428` maps 0 to the no-texture-generation case, so the mesh's authored UVs are used.
  `TextureScale = 1`, `TextureOffset = 0`, wrap both.
  Evidence: `ev_14416f797672daedec7cfc2d0630555a9f975225884cd5b940e3d46e2e4f316b`,
  `ev_30048a763498d0a95d77c41f8275060214a1f5d2a1d4267b20d0dcd9d0d864aa`.
- **Converted OBJ:** `field.obj` has 546 vertices, 573 UVs, 544 faces, no `vn` records and
  no `usemtl`; UV v slightly exceeds `[0,1]` (about `-0.004148..1.003365`), which donor
  `twBoth` accommodates. `field.mtl` has white `Kd` and a relative `map_Kd` path that does
  not resolve beside the OBJ, so explicit texture binding is required.
  Evidence: `ev_c36b4b85aba623440d236917c513b8b7de82b58afdc3cb0b7f0a700c56c6c450`,
  `ev_08d0451cda5f93e0380d0c7d1ecb94d32a3802e17054ff8a901c9565465253c3`.
- **Crop placement:** uniform prop scale `0.03605085`, roll `45°`, one of three meshes,
  terrain auto-offset. No donor stage scale change was found.
- **Decal placement:** attached to the field object, angle `45°` or `225°`, size and UV
  multiplier `1.3`, offset `-0.15`. The exact world size remains [U] because the decal API
  unit is undocumented.

---

## 7. Why donor fields read golden while the legacy port read black squares

### 7.1 What is established

1. **[O] Mature donor fields use different art from the port.** Donor maturity selects
   `field.dds` plus `field` material. The port always binds `field1.dds`/`field.png`, the
   first growth-stage art, even when its gameplay state says `ripe`.
2. **[O] Donor fields include a ground-decal layer.** The port's 3D field path never draws
   `envfieldd/w`; the constants are telemetry only.
3. **[D] The black-square mechanism is deterministic.** FCOL-01's read-only pixel/UV probe
   found 72.8% of face-center samples on alpha `<=8`/black texels. With an opaque material,
   those texels cannot be discarded and become black square backgrounds. Emission does not
   discard them; only alpha test/blend can.
4. **[O] Donor crop coverage is alpha-tested, not blended.** That is the state COORD's
   patch now translates to Godot alpha scissor.

### 7.2 What is not established

The exact reason donor reference frames reach golden L≈112–118 is still **[U]**. The raw
summer decal is dark olive (`#4D442E` opaque mean), the crop textures are dark, the readable
ShaderID6 crop path does not consume Emission, and the recovered generic decal blend factors
are not conventional source-alpha. A same-camera donor GPU frame or runtime state trace is
required before assigning a numeric golden multiplier.

**Therefore:** “donor fields are golden textured parcels” is a valid reference observation;
“warm Emission × 0.22 reproduces donor gold” is not.

---

## 8. Does COORD's alpha-scissor patch match `bmAlphaTest50`?

### 8.1 Verdict

**Yes in the decisive rendering intent; no as a complete donor material match.**

| Donor fact | Current patch | Assessment |
|---|---|---|
| Transparent background must not paint | `TRANSPARENCY_ALPHA_SCISSOR` | Correct mechanism |
| Threshold 0.5 | `alpha_scissor_threshold = 0.5` | Correct value |
| Exact comparator | Donor `GL_GREATER` keeps `alpha > 0.5` | Godot's exact equality behavior is [U]; for 8-bit alpha, exact normalized `0.5` is not representable, so no practical difference is expected for current art [D] |
| Blending | Donor blend off for `bmAlphaTest50` | Alpha-scissor opaque pipeline matches |
| Culling | Donor `fcNoCull` | `CULL_DISABLED` matches |
| Coverage source | Donor `tex0.a * diffuse.a`, diffuse alpha 1 | Port instance-color alpha may also participate in scissor; hazard below |
| Stage appearance | Donor swaps `field1..7` textures/materials | Port still uses one texture plus arbitrary tints/scales; not matched |
| Emission | Authored RGBA constants; ShaderID6 consumption [U] | Port additive warm emission × `0.22` is not established as donor-equivalent |

### 8.2 Immediate hazard in the current patch

`world3d_entities.gd:2386-2403` writes per-instance alpha values including:

- ripe at low growth: `0.42`;
- growing at low growth: `0.45`;
- regrowing: as low as `0.40 * 0.75 = 0.30`;
- depleted: `0.60`.

With `vertex_color_use_as_albedo = true`, Godot's normal material path can multiply texture
alpha by instance-color alpha before the scissor test. If so, values below `0.5` discard the
whole instance rather than merely tinting it. This is an engine inference **[I]** until a
capture, but it is a concrete regression risk introduced by combining the patch with the
old stage-alpha table.

**Required follow-up:** keep instance alpha at `1.0`; express stage state through material/
texture selection, not coverage alpha.

---

## 9. Current port comparison and contradiction register

### 9.1 Current port implementations

`world3d_entities.gd:1494-1527` currently creates a shaded `StandardMaterial3D` with:

- `field.png` (`field1.dds`) albedo;
- roughness 1, metallic 0, cull disabled;
- alpha scissor 0.5;
- vertex/instance color as albedo;
- additive warm Emission `(232,218,195)/255` × energy `0.22`.

`world3d_entities.gd:2354-2412` then applies port stage RGBA and relative scale. The decal
paths are never rendered.

Evidence: `ev_1cce14d9ddf8ff2fb47eaea05b34af41b642ce94bf9d1b303021826e742ad5ac`,
`ev_880104a491e01659595e64d3a85891a605fe2d4ca1c419c8b69e97d3524fcb59`.

`terrain_donor_props.gd:997-1012,1087-1114` has a second field material path: lit
`StandardMaterial3D`, alpha scissor 0.5, cull disabled, plus the same additive warm
Emission × `0.22`. It has no stage material swaps. Since donor fields are script-sown and
not pattern records, this branch is not the normal mill-field path, but it is a divergent
fallback that should not survive as a separate definition of “field material.”

Evidence: `ev_5909942ea3f85af0a6a6ca167fbb1da003ea6f161970d936c9fe2c14eca8be83`.

### 9.2 Multi-pass contradiction register

| Contradiction | Pass 1 | Pass 2 | Final verdict |
|---|---|---|---|
| F07/X22: no time-based crop stages | Earlier report text | Full `nothing.inc` + `ontagstates.inc` + `initial.inc` + global constants | **[O] Refuted.** Explicit growth/regrowth machine exists. Runtime activation of all `[*] = ;` text remains [U]. |
| F07: `field5/6/7` unreferenced | Static filename/reference scan | Dynamic string construction `basename+'7'`, suffix `'5'`/`'6'` in food state code | **[O] Refuted.** They are depletion/regrowth materials. |
| F07/X22: random crop materials | `UseableMaterials` lists | `field.prop:48` says `RandomMaterialName=False`; state code selects material | **[O] Refuted.** Mesh is random; material is state-driven. |
| FCOL-02/03: `Default` shader carries Emission into crop | Material has Emission; default shader source | `field.actor` → `reftree.actor` ID6 → `tree.pvl.id6`; no emission read | **[O] Corrected.** Authored constants exist, custom-shader consumption is [U]. |
| FCOL-03: emission stops black squares | Proposal wording | Alpha=0 black texels + old opaque material + native alpha-test state | **[D] Refuted.** Alpha scissor/test removes squares; emission only affects RGB. |
| D08/FCOL-02: `bmTransparency` = source-alpha blend | Pseudo-C/table interpretation | Raw table bytes + push order + direct import thunk | **[O] Refuted for generic state.** Actual pair is dst-alpha/one-minus-dst-alpha. Decal-specific override [U]. |
| D08: alpha comparator is `GEQUAL` | Earlier secondary claim | Alpha table index 7 = `0x204` = `GL_GREATER` | **[O] Refuted.** Exact donor comparator is `GL_GREATER`. |
| Donor gold is explained by raw art alone | Raw art measurements | Donor video + readable shader/state analysis | **[U].** Raw art is dark; final render-time lift is not recovered. |

---

## 10. Precise implementation recommendation

### P0 — keep the alpha fix, remove its new hazard

1. Keep `TRANSPARENCY_ALPHA_SCISSOR`, threshold `0.5`, and `CULL_DISABLED` for the crop.
2. Set every field instance color's **alpha to 1.0**. Do not let gameplay opacity drive the
   cut-out. If exact `alpha > 0.5` semantics are required, use a tiny custom shader; for the
   current 8-bit art the 0.5 scissor is expected to be pixel-equivalent [D], runtime [U].
3. Do not describe this as full donor material parity. It is the correct coverage fix.

### P1 — implement the donor stage table instead of invented tint/scale rules

Map field state to these material/texture names:

```text
growth 0..3       -> field1, field2, field3, field4
mature            -> field
harvested HP high -> field
harvested HP mid  -> field5
harvested HP low  -> field6
first depletion   -> field7
winter            -> append w to every name
```

Use donor timings/HP if the gameplay layer is being made donor-grounded: max HP 25000,
87.5 s growth, 31.25 s regrowth tick, 21.875 s rest, HP thresholds 13000/5000, one regrowth.
Remove the port's `Color(3.3,...)`, alpha modulation, pulse, and relative stage scales from
the donor-rendering path, or retain them only as explicitly labelled PORT APPROXIMATION.

### P1 — restore the second, ground-parcel layer

Add a terrain-conforming `envfieldd/w` decal per field with:

```text
angle = 45 or 225 degrees
w = h = 60 * goScale * 1.3
uvScale = 1.3
uvOffset = -0.15
epsilon = 0.01
```

Keep crop and decal materials separate: crop is alpha-tested/no-cull; decal is lit/culled
and blended. Do not silently substitute conventional source-alpha and call it exact: the
generic native state is dst-alpha based. If Godot cannot reproduce the donor destination-
alpha behavior, use conventional alpha blend only as a labelled PORT APPROXIMATION until a
donor A/B or renderer trace settles it.

### P2 — centralize the crop material and handle Emission honestly

There are two distinct targets:

- **Literal readable donor path:** use the ShaderID6 formula and material constants. It does
  not sample Emission. With Ambient/Diffuse/Specular zero, the readable formula predicts a
  black crop detail layer; the visible parcel then depends on the decal/runtime state. Do
  not add an “emission energy” and label it donor.
- **Visual PORT APPROXIMATION until the decal path lands:** if a readable crop is required,
  use an **unshaded albedo texture multiplied by the stage's authored emission color**, not
  additive emission. This is closer to the apparent authoring intent but remains an
  approximation because ShaderID6 consumption is unproven. No donor energy value exists.

Use one shared field-material builder for `world3d_entities.gd` and
`terrain_donor_props.gd`; the latter must not retain a conflicting lit/additive definition.

### P2 — close the art gap through the asset owner

The current port has only `field1.osm`/`field1.dds`. Donor-grounded stages additionally need
`field.dds`, `field2..7.dds`, all winter twins, and `field2/3.osm`. This worker did not copy
or convert any donor asset.

### P3 — validation

Capture one pinned field+mill shot before/after each change and record separately:

- alpha-scissor silhouette (no black square background);
- correct mature vs growth texture;
- decal presence/UV footprint;
- stage transitions and winter suffix;
- instance-alpha regression check;
- crop RGB formula and final golden appearance.

No numeric donor-parity threshold is available. Keep parity `UNVERIFIED`.

---

## 11. UNVERIFIED register

1. **[U] Runtime activation** of the `[*] = ;`-prefixed donor state scripts and sowing callers.
2. **[U] Emission consumption in ShaderID6.** Native state uploads it; readable shader does
   not read it. Settle with a shader-uniform/state trace or controlled donor frame.
3. **[U] Exact final golden multiplier/tone-map.** Raw art is dark; reference video is not a
   calibrated donor frame.
4. **[U] Decal-specific blend path.** Generic `bmTransparency` state is recovered, but an
   `OXDecal`/`XDecalSet` override was not proven.
5. **[U] Godot scissor equality and instance-alpha interaction** until a capture/shader probe.
6. **[U] Decal API world units** and therefore exact crop/decal overlap at 3.3962 m donor spacing.
7. **[U] Exact 87.5 s boundary behavior** when `floor(progress*4)` yields stage 4.
8. **[U] Donor random mesh selection distribution/RNG stream position.**
9. **[U] Donor/port same-camera A/B.** No parity claim is made.

Open unknowns recorded in Craft Anything: `unk_dc4b363949a870be` (Emission/ShaderID6) and
`unk_2453155327e8b49e` (decal blend path).

---

## 12. Evidence catalog

### 12.1 Donor text and shader evidence

| Evidence ID | Source | Establishes |
|---|---|---|
| `ev_82ce8c0ec78d96f8ff8aabfdd8e4a0faf6678fc643a759d49d3fa0f225ba0429` | `env/env.inc/nothing.inc:1-103` | Growth/rest/regrowth timers, HP thresholds, stage selection |
| `ev_8ffcf086c5a6a9a904372576efcfdffe568eb4d1d0f05637ca9cf9198a514dd7` | `env/env.inc/ontagstates.inc:1-146` | Material suffix/stage mapping, depletion/destruction |
| `ev_f9815a7b00ee2b722b897cee2938785316e2bddbb45dc75156182b97ba2c098e` | `env/env.inc/initial.inc:1-121` | Food type, initial state, HP/worktransorm |
| `ev_293916abac66d18e7397d0ea6610169db1742e9daeab1309b000e81f58d0b222` | `objects/env/field.prop:1-157` | Mesh/material/season/scale/roll properties |
| `ev_5cbad35a82f734781efe0c5e14fb840778f3e4c0b3246912b623cb84e18e8d38` | `actors/env/field.actor:1-12` | Three crop meshes, reftree inheritance |
| `ev_5b02fe60d1b3dd6f85878edde1eac971f76383138b3c91d9b7010087431de990` | `actors/ref/reftree.actor:1-5` | ShaderID 6 |
| `ev_148480a89b31e600f2742414e397f75bf5babb5e0c4897f0830be69c1354c465` | `materials/ref/refbase.mat:1-109` | Alpha/cull/blend/texture defaults |
| `ev_d1bc1129d71f9a2306cad636ec4a0838177f7610b539276015cc3290803643ed` | `materials/env/env.mat:46-225` | Summer field/field1..7 constants |
| `ev_de2e371fcd66ed8db9227f11e55a58be45cbd59387ed2b786535f1af4d9c7523` | `materials/env/env.mat:856-1045` | Winter field/winter stage constants |
| `ev_b2275dd7f7cba7dca3bcfa6fccbe408edae75b602495665441e66b81e4746d94` | `shaders/obj/tree.pvl.id6.vert:1-58` | Crop vertex lighting/UV formula |
| `ev_9f74e5ce6f28cea071e028224cbdd845e948e734bc826add22927e6eb926ba07` | `shaders/obj/tree.pvl.id6.frag:1-48` | Crop fragment formula; no Emission read |
| `ev_824a8adcb1ebeb26f9d4dc854397652a9a9260c048270270b9dfcbc61891b020` | `scripts/lib/misc.script:4281-4315` | Decal size/UV 1.3/-0.15 |
| `ev_99021784ab0082a89ccfaf1d6d1231d6b7b4bf6fc3ae655d5915124a6d633dd5` | `writenewp.inc:1-40` | Field creation and 45/225 decal call |
| `ev_52c03176f45e976fdb26fa442b9b5e704e5f64bf166c77a06e653851d18f0436` | `decals.lib:1-60` | Decal descriptor/season/epsilon/UV flags |
| `ev_7888568829a607a344016cd63f6c215ddef2e4aa48482a0de8a9794a2c2b36c0` | `decals.mat:1-130` | Decal blend/cull/light/brightness constants |
| `ev_e1ec76795576e770b7195350dc891938d8311c2f6fcebfa5d4d3f81592f29c5a` | `dec.pvl.sm.vert:1-37` | Decal texture matrix and lighting |
| `ev_7b259c8d7515cff5569e80022e50264625bb0d25e90bc3d3554619bd77ce5b69` | `dec.pvl.smx3.frag:1-46` | Decal color/alpha formula |
| `ev_0e6fc3cc88880ff39e6361f9879acba22a78f3cf1e96b14fa89cca7d00758e35` | `dmscript.global:1-210` | Stage bits, FieldMaxHP, death time |

### 12.2 Native evidence (all `cossacks.exe`, document `t_87f0f3c130b0`)

| Evidence ID | Address/function | Establishes |
|---|---|---|
| `ev_4be05ed625eccacc761730f5454535dbc65f34e9c4745c0a98d2bab94357bd3f` | `sub_88f3e8` @ `0x88f3e8` | `glMaterialfv` ambient/diffuse/specular/emission upload |
| `ev_c6b5ab46f70762cbf2274a9f42811ce6c00629dfe47c3d2b34c78e5eda98cf16` | `sub_4ef810` @ `0x4ef810` | Material/cull/blend/alpha state assembly |
| `ev_2cbc210c940a45eb799e796a833175b8f5c1941fdbb5727a6c875b9f4cfed8ee` | jump table `0x4ef949` | Blend enum → case mapping |
| `ev_778088da1636eb21993ba4fe26056dd297cea11dbb42bbad19b6a54a2b78fb6e` | alpha table `0x8fb18c` | Index 7 = `GL_GREATER` |
| `ev_4992d0018f1302c53068a8f6e1cd0da4137f72b508647a3008bbe770bdc0fc6d` | blend table `0x8fb1ac` | Index 6/7 = dst-alpha factors |
| `ev_5071f34e67c6214d7a00cc21b9e1eec5596477010b3e42b4f2deaf886017cfde` | `sub_88fb78` @ `0x88fb78` | Blend push order and caching |
| `ev_0287c1001da10a3c5084f81af87c00d2c3948289ad97d06f3c885ce7d52cba73` | `glBlendFunc@thunk` @ `0x4afb14` | Direct import, no argument reversal |
| `ev_c541581878dbd56af0abc4ab5b8af9128ae505c046f87c0be856bdd3675e0f61` | RTTI bytes `0x4e87a0..` | Blend/cull/material-option enum order |
| `ev_14416f797672daedec7cfc2d0630555a9f975225884cd5b940e3d46e2e4f316b` | RTTI bytes `0x4e7b80..` | Mapping/texture-mode enum order |
| `ev_30048a763498d0a95d77c41f8275060214a1f5d2a1d4267b20d0dcd9d0d864aa` | mapping jump table `0x4ec428` | `tmmUser` = no texture generation |

### 12.3 Port evidence

| Evidence ID | Source | Establishes |
|---|---|---|
| `ev_1cce14d9ddf8ff2fb47eaea05b34af41b642ce94bf9d1b303021826e742ad5ac` | `world3d_entities.gd:1489-1533` | Current alpha-scissor/additive-emission material |
| `ev_880104a491e01659595e64d3a85891a605fe2d4ca1c419c8b69e97d3524fcb59` | `world3d_entities.gd:2351-2425` | Current stage RGBA/scale rules |
| `ev_5909942ea3f85af0a6a6ca167fbb1da003ea6f161970d936c9fe2c14eca8be83` | `terrain_donor_props.gd:991-1120` | Divergent field material fallback |
| `ev_c36b4b85aba623440d236917c513b8b7de82b58afdc3cb0b7f0a700c56c6c450` | `field.mtl:1-3` | White Kd, relative texture path |
| `ev_08d0451cda5f93e0380d0c7d1ecb94d32a3802e17054ff8a901c9565465253c3` | `field.obj:1116-1155` | Authored UV face references |

---

## 13. Scope statement

Exactly one repository file was written: this report. No code, Godot scene, shader, asset,
config, test, fixture, result JSON, git or runner state was changed. Donor binaries were
never executed or copied. Craft Anything remained in Deep mode; native analysis pinned the
cossacks/editor document IDs and did not switch the global active target.

**No donor-parity claim.**
