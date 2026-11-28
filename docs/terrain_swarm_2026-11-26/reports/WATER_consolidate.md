# WATER_consolidate — definitive answer to "all code is there, look at every exe/dll"

Worker: WATER-CONSOLIDATE. READ-ONLY consolidation. No code/Godot/git/donor-execution; no other edits.
Parity: UNVERIFIED. No approximations. No parity claim. Chain 0/6. RESULT IS NOT GOOD.

Donor pins [D]: cossacks.exe t_87f0f3c130b0, 5768048 B, sha256
87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c;
editor.exe t_68474ddde43f, 7874416 B, sha256
68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab;
config.exe sha cddfee5587f2…, modman.exe sha 0d7db745f7f0…,
codex.dll sha 382a95940910…, water.lib sha 88b3cdc6ba37… (2063 B, 71 lines),
shaders.lib sha a18aa083616e… (63077 B).

## 1. Per-report [D] facts and [U] residuals

### WATER_liveness (cossacks.exe FILE-vs-ENGINE sweep)
[D] byte-proven:
- `sub_851bdc` ENTRY is 0x851bdc (not an interior gate); 17 insns
  (ev_25b86263204c696…, ev_712828488c58…). Gate insn `test eax,eax @0x851be4`
  (bytes 85c0): `param_2==0 -> call 0x856080` (ENGINE-default writer),
  `param_2!=0 -> call 0x852f5c` (bulk field copier). Ghidra FUN_00851bdc
  concurs (ev_67a5083d1de168…).
- Feed chain: `sub_851c5c` (13 insns, ev_14e8fda2dc703…) calls
  `sub_853530` @0x851c67 then `sub_851bdc` @0x851c70 with the RETURN value —
  no null-test in `sub_851c5c` itself.
- `sub_853530` (20 insns, ev_cb7dbb8e46d723…) is a generic bounds-checked
  container getter: `param_2<0 -> 0`; `count=*(*(p+4)+0xc)` via 0x8534c4;
  `element=*(*(p+4)+8)[index]` via sub_89df30; else 0. Only caller is
  `sub_851c5c` (ev_add91eb6c…; `address_taken:0` caveat).
- `sub_851bdc` has exactly 2 direct callers (`sub_8519f4` @0x851c48,
  `sub_851c5c` @0x851c70, ev_72c4d19b94dac…); `sub_851c5c` has 4
  (`sub_603c0c`, `sub_7130a0`, `sub_852068`, `sub_85208c`, ev_06da56bcc0c841…).
  Index provenance: virtual-call result (FUN_00852068), object field +0x10
  (FUN_0085208c), opaque stack slot (FUN_00603c0c). `sub_8519f4` is
  mis-decoded garbage (ev_856276abca5c…) — no conclusion from it.
- ENGINE float block is byte-proven CODE: raw bytes @0x856080 (256 B,
  ev_74d0132ff4d508…) and @0x856106 `cd cc cc 3d` (ev_92b080a96e96…)
  match Ghidra FUN_00856080 immediates (ev_5aaec0315458ec…); identical block
  in `sub_852c68` (ev_4c1f49d1b4b6dc…). Decoded: 1.0, 0.0, ~0.4, ~0.3, 4.0,
  0.1, 0.5, ~0.05, 2.0, ~0.02, ~0.8, 50.0 + `Tex0:=Tex1*Tex0;\r\nTex1:=Tex0+Col;`.
- Negative byte-proven absences on cossacks.exe: `ReflectionAmount`,
  `Fresnel`, `MaxDepth/MinDepth`, `Max/MinAlpha`, `Deep/ShallowColor`,
  `TexScale`, `WaveDir/Freq/Amp`, `HeightMap`, `CustomReflection`,
  `WaterAmount`, `HDRMultiplier`, `Dist/BumpFactor` = 0 matches each;
  `water/Water/WATER` = 3 hits all in .rsrc with `references: []`
  (0x958c10 `$XWaterShader`, 0x95937b `fXWaterField`, 0x95938a `XWater`,
  ev_6dae3ae13da997…, ev_77319dd1b0892e…); `.lib`=0, `data\water`/`water.lib`/
  `water\`=0, `section.begin`/`struct.begin`=0, `.vert`=0, `water.mat`=0;
  `CreateFileW` import @0x90800a has `total_to: 0` (ev_469f519ecc1aef…) —
  no file-open-to-water caller chain proven.
- FILE `MaxAlpha=1.1` (`CD CC 8C 3F`): 7 hits, NONE in 0x85xxxx water
  cluster (ev_5b1633f27ff219…); ENGINE block has 1.0 where FILE has 1.1.
  FILE `TexScaleT=0.01` (`0A D7 23 3C`): 14 hits, NONE in water cluster;
  ENGINE slot carries ~0.02 instead. `0.1f` water-cluster hits (0x852d14,
  0x856106) belong to the ENGINE initializers, not a FILE load.
- `FUN_00856080` reads no file/registry/config; `FUN_00852f5c` is a pure
  field copier with no literal floats/pathnames/keys (ev_513eeafe38634…).
[U] residuals: whether the container is EVER populated from water.lib; what
writes `*(obj+8)`/count/elements; what `param_2` MEANS; whether null = "no
FILE" vs bad-index vs uninitialized vs engine override; any computed-pointer
/ encrypted / resource-loaded name invisible to static strings/xrefs.

### WATER_build2 (cossacks<->editor pairing)
[D] byte-proven:
- 18918/22384 functions paired to 5719 (5580 unchanged, 139 changed,
  537 ambiguous groups, 144 structural guesses; ev_4c90d4…/ev_a83ddc…/
  ev_6d5aa2…/ev_5ff6d2…/ev_5f325c…).
- 0x851bdc and 0x851c5c are `only_left` singletons (ev_6d5aa2… browse);
  pairs-match total 0. 0x853530/0x856080/0x852f5c/0x852284/0x8534c4 total 0
  in only_left/only_right/pairs — undiscovered bodies (discovery_capped), not
  pairing misses.
- Editor `core_feature_find`: water 107 strings / 0 funcs (ev_b4df8d…);
  fresnel 8/0 (ev_d05a2c…); texScale 21/0 (ev_5bc602…); reflection 11/0
  (ev_28332f…); wave 28 strings + 1 WinMM-audio thunk false positive, 0 water
  funcs (ev_c402a7…). Cossacks water = 3 strings / 0 funcs (ev_77319d…).
  Same-VA probes in editor.exe are `function_not_found` (rebasing, proves
  nothing). No pair or editor-only function with water-referenced
  strings/calls found; all water strings `references: []`, 0 functions
  involved; xrefs on $XWaterShader/UI labels all 0-from (ev_6c222e…,
  ev_66b3c6…, ev_b368ef…, ev_732b18…, ev_6acbc0…, ev_3b933b…, ev_b70ba8…).
- Water-chain assemblies re-proven integers-only: 0x851bdc 17 insns / 0
  floats / 0 strings; 0x851c5c 13 insns; 0x853530 20 insns + 3-insn leaf
  sub_89df30 (318 callers, ev_8e1a5a…); 0x852f5c/0x852284/0x8534c4/0x856080
  `function_not_found` in built-in DB (discovery gap).
[U] residuals: computed-pointer/resource-table/undiscovered-bytes bindings;
form-edit numerics (Delphi DFM); layer-pointer return value; water.lib parse
state. Nothing softens U4*.

### WATER_bins (editor/config/modman/codex/shaders.lib/water.lib sweep)
[D] byte-proven:
- editor.exe is the ONLY binary with water-scalar strings, all UI-form
  `.rsrc` with `references: []`: Water 104 hits (0xaa1af3 $XWaterShader,
  form block 0xb371a9–0xb3758b, labels 0xb376a8–0xb38047,
  ev_55f186ca6a37…); ReflectionAmount 3 (0xb376c1/0xb37f99/0xb37fe1,
  ev_c5ece9b5b18d…); Fresnel 8 (0xb37767…0xb3810d, ev_74a675b556…);
  Wave 24 + winmm audio lowercase set (ev_ce7fdb3c3e354…); TexScale 17 incl.
  water-form 0xb382fe–0xb383a4 (ev_b43c184464c8…); WaterLibraryFileName 4
  (0xb2631e/0xb26361/0xb27b00/0xb27b4f). `bytes_find` CustomShaderID=2 /
  HeightMapEnable=2 have file offsets only, no VA/xref/function (packed DFM
  stream, not code); subject-verified `strings_find` for both = 0
  (ev_70d4a888611f…, ev_5717f40235ee…). FILE/ENGINE: `FILE` raw 7 hits no
  water linkage (ev_168c5cebc433…), `ENGINE` 0 (ev_3e119ea812b3…).
- config.exe: Water triad only ($XWaterShader 0x845842 / fXWaterField /
  XWater, ev_7af58e509628…); Reflection/Fresnel/Wave/water/DiffuseWaves = 0
  subject-verified. First-pass 11/8/24/17-hit rows reusing editor evidence
  ids were stale ledger cache — EXCLUDED.
- modman.exe: same triad only (0x819251/0x819589/0x8195ff, ev_18478249fd22…);
  all scalar names 0 subject-verified; stale-cache rows EXCLUDED.
- codex.dll: clean zero (ReflectionAmount/Fresnel/Water/water/WaterShader/
  shaders.lib/water.lib all 0, ev_861730595772… ff.).
- water.lib: full 71-line text read (ev_6fcb07113a5beb30f…) — NAMES+DEFAULTS
  source, not wiring: no exe/dll references `water.lib` by string
  (editor ev_2e8c…, config ev_3575…, codex ev_9a6c… all 0/0/0).
- shaders.lib: exhaustive 0 for Water/water/XWater/WaterShader/DiffuseWaves/
  HeightMap/Reflection/Fresnel (ev_4d06e427fcd3… ff.); controls
  ShadersSM20=2, `.vert`=76 prove the file WAS searched; `water.dev`=0 —
  water shaders live in `data/shaders/water/`, not here.
[U] residuals: data-section-only string limitation; packed/delay-loaded/
data-driven loading; DFM-stream numerics; `.vert/.frag` uniforms in
`data/shaders/water/` (out of scope); who loads water.lib / selects
FILE-vs-ENGINE / uploads uniforms — UNIDENTIFIED by string evidence.

### WATER_ledger (water.lib:1-71 FILE scalar ledger + port cross-ref)
[D] byte-proven (FILE TEXT ONLY — every value read byte-for-byte):
Name=default(:4); MaxDepth=1(:5); MinDepth=0(:6); MaxAlpha=1.1(:7);
MinAlpha=0(:8); DeepColor=(0,0,0.1255,0.5)(:9-14);
ShallowColor=(0,0,0,0.5)(:15-20); ReflectionAmount=1(:21);
WaterAmount=1(:22); FresnelPower=1(:23); FresnelBias=1(:24);
HDRMultiplier=1(:25); WaveFreq=0(:26); WaveAmp=0(:27); DistFactor=1(:28);
BumpFactor=1(:29); //TexScaleS=0.115 INACTIVE(:30); //TexScaleT=0.015
INACTIVE(:31); TexScaleS=0.1(:32); TexScaleT=0.01(:33);
WaveDir0=(-1,0)(:34-36); WaveDir1=(-0.7,0.7)(:38-40); Speed=1.0(:42);
NormalMap=DiffuseWaves2(:43); DiffuseMap=DiffuseWaves0(:44);
//HeightMapWaves0 INACTIVE(:45); Width=1(:47); Height=1(:48);
Offset=0.495(:49); LayerCount=1(:50); CustomEnable=False(:51);
CustomShaderID=0(:52); CustomReflection=False(:53);
CustomReflectionUnit=0(:54); CustomLibMaterialName=empty(:55);
CustomTexCoord=True(:56); CustomTexCoordScale=1(:57);
CustomTexReflectMatrix=False(:58); CustomTexReflectMatrixUnit=0(:59);
HeightMapEnable=True(:60); ShadowMapEnable=True(:61);
MaterialLibraryFileName=.\data\water\water.mat(:64);
DefaultWaterIndex=0(:65); Tag=512(:66);
VP=water.dev.vert(:67); FP=water.dev.frag(:68); LOD names empty(:69-70).
Port transcription column cites exact `water3d.gd` lines or `not present`;
`config_donor_capture.json:34-38` surface_y/alpha_confine/shore_prox are
PORT-ONLY (no donor backing). Commented lines are INACTIVE, never candidates.
[U] residuals: liveness of EVERY diverging scalar (U4*); Speed convergent
value but writer/accumulation U5; reflection texture identity U12
(reflectionMap FBO provenance unrecovered; Custom* keys do not resolve it).

### Earlier (WATER_static_scalars + WATER_deep2 — already consolidated shape)
[D]: gate topology + zero-float-literal/zero-string/zero-static-writer
statements re-verified with full bytes/disassembly/Ghidra/xrefs/call-graphs
(ev_d1b3…/ev_25b8…/ev_ca45…/ev_9452…/ev_f023…/ev_b32c…/ev_0092…/call-graph
ev_b1ee…/ev_a696…/xrefs ev_ae4c…/ev_e72b…/ev_fed8…/ev_6f41…/ev_0157…).
[I]: static binding is impossible-in-principle here (runtime pointer branch,
atomic whole-block arms, unenumerated ENGINE waveDirs, no selection rule in
text). Kept as inference, not byte fact.

## 2. What the donor statically proves
(1) Gate: runtime pointer null-test `test eax,eax @0x851be4` inside ENTRY
`sub_851bdc`; `0 -> ENGINE writer 0x856080`, `!=0 -> copier 0x852f5c`;
pointer = return of generic bounds-checked getter `sub_853530` via
`sub_851c5c`; followed by `call 0x852284` status byte -> `[edx+0x130]`.
(2) ENGINE defaults: hardcoded immediates 0.1 / ~0.02 / ~0.05 / 0.3 / 0.4 /
0.5 / ~0.8 / 1.0 / 2.0 / 4.0 / 50.0 (+ shader-combiner string), written
unconditionally by the null arm and `sub_852c68`. Nothing else byte-proven.

## 3. What the FILE values are and why they are NOT proven live
FILE values = the §1-ledger list above (water.lib:21-70, ev_6fcb07113a5beb…).
They are proven as PLAINTEXT FILE BYTES ONLY. They are NOT proven live
because: no `water.lib` pathname, no FILE key name, no `section/struct.begin`
token, no `.vert`/water.mat path, and no FILE float (1.1 / 0.01 / 0.1255 /
0.495 / -1 / -0.7 / 0.7) is tied by bytes/xrefs to the 0x85xxxx water path in
any swept binary; the container-fill edge `file read -> *(obj+8)/count/
elements` was never found; both writer arms contain no key compare/pathname.

## 4. Does any exe/dll/data-lib supply the missing liveness or reflection identity?
No. editor.exe adds UI LABELS (+ handler names) with 0 code/import/xref/float/
FILE/ENGINE bindings — documents scalar NAMES, not values or selection.
config.exe / modman.exe add only the `$XWaterShader/fXWaterField/XWater`
datatype triad. codex.dll is all-zero. water.lib supplies names+defaults, not
wiring (nothing references its filename). shaders.lib has zero water content
(water shaders live under `data/shaders/water/`). Reflection texture
identity/provenance is unrecovered everywhere (U12); no FBO edge in any sweep.

## 5. The exact single missing piece (and why static work cannot supply it)
GPU + file-trace observation, owner-only: break `sub_851bdc @0x851bdc`,
record the layer pointer (0 vs nonzero) and its provenance (which
`sub_851c5c` caller/index path), dump `C+0x88..+0xc4/+0xb4/+0xbc` on both
arms, hook the uniform upload (`glUniform1f/2f`) over 2 frames + camera move
with 0-ULP/0-mismatch (U4* packet), plus capture the live reflection texture
binding. No amount of static decompilation can supply it because the selector
is a RUNTIME DATA VALUE (return of a bounds-checked lookup over runtime table
state), both arms are unconditional whole-block writers with no per-scalar
static path, the ENGINE waveDir slots are unenumerated (any "assume" invents
vectors), and static string/xref coverage is data-section-only (computed,
encrypted, packed-DFM, or data-driven loads are invisible by construction).

## 6. Required behaviour — U4* hard-fail stays, nothing wired
`water_scalar_source` stays UNSET; no water drawn; no FILE value and no ENGINE
value wired; BUILTIN_TEX_SCALE_S/T stay labelled embedded-source-default,
never live; ENGINE-dir null-guard kept; no fallback, no default, no invention.
Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD.
