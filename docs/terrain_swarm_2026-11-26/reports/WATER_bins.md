# WATER_bins — read-only sweep of editor.exe, config.exe, modman.exe, codex.dll, shaders.lib, water.lib

Scope: worker WATER-BINS. READ-ONLY. No donor execution, no code changes, no Godot wiring.
Task: check whether any binary besides cossacks.exe supplies water-scalar liveness that
cossacks.exe discovery missed (prior `core_feature_find` on cossacks.exe for
"water.lib"/"ReflectionAmount" returned 0 hits — strings live in data files, not the EXE).

Parity: UNVERIFIED. No approximations, no invented values, no scalar wired, no U4* softened.
Chain: 0/6. RESULT IS NOT GOOD.

Method (all read-only): `core_target_open` per binary (SHA verify) → `native_strings_find`
(subject-SHA-verified) → `core_feature_find` (strings/functions/imports) →
`native_bytes_find` with `path=` on raw files (works without opening as target).
Only evidence whose `subject.sha256` matches the file it claims to describe is cited below.
A stale-cache trap was observed and is documented; uncorroborated hits are excluded, not cited.

Donor SHAs (all `core_target_open`, observed):
- editor.exe: sha256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab, 7874416 bytes (~7.8MB), PE
- config.exe: sha256 cddfee5587f28956730ab1dd50710331982b8f39b03e976713cb89bd3990050d, 4645744 bytes (~4.6MB), PE
- modman.exe: sha256 0d7db745f7f0787702e8ffc7257bee1bbf76aa727bcdd57d5133e771727d07fe, 4463984 bytes (~4.5MB), PE
- codex.dll: sha256 382a95940910172335a3f6356671e3cf6e514ec95b98faf5d943b23870164afc, 106272 bytes (~106KB), PE DLL
- data/water/water.lib: sha256 88b3cdc6ba3770b23d620f013c518084214968e9db6f4e8e0505de6e4095e17c, 2063 bytes, 71 lines, kind=text
- data/shaders/shaders.lib: sha256 a18aa083616e771e24b7f0ea9c0a08ff2e426e3d756dc1e23a0c6fce27c867ae, 63077 bytes (~63KB), kind=text, 1813 lines total (read paged; water verdict via exhaustive `bytes_find`)

Caveat on prior brief numbers: the brief's "7.8/5.8/4.6/4.5MB, 106KB/63KB/2KB" sizes are
consistent with observed byte counts (7874416 / 4645744 / 4463984 / 106272 / 63077 / 2063).
cossacks.exe (t_87f0f3c130b0, sha 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c)
is referenced only for the prior 0-hit context; it was not re-swept here.

---

## 1. editor.exe (subject 68474ddde43f) — ONLY binary with water-scalar strings, all UI-form, zero code liveness

Subject-verified `native_strings_find` (limit 60, offset 0; every id below has subject 68474ddde43f = editor.exe):

- "Water" (case-sensitive): total=104, id ev_55f186ca6a37fb8df1097725aa730133f9008a6e639bfbdd806fb33f4331a4e2. First: 0xaa1af3 `$XWaterShader`, 0xaa1d5a `fXWaterField`, 0xaa1dd0 `XWater`, 0xaa27b6 `frmWaterFields`; form block 0xb371a9–0xb3758b (`TFormWaters`/`FormWaters`/`ListBoxWaters`/`ComboBoxCurrentWater`/`ButtonAddWater`, …), field labels 0xb376a8–0xb38047 (`Water`, `LabelWaterAmount`/`Water amount`, `EditWaterAmount`/`EditWaterAmountChange`), terrain-block labels 0xb3ec6d–0xb3f6da (`LabelWaterBlocks`, `LabelWaterOffset`, `LabelWaterSmoothPasses/Factor/Radius`, `LabelWaterCollisionTag`, `LabelRoadWaterFactor`). All section `.rsrc`, all `references: []`.
- "water" (lowercase): total=1, id ev_475d2fc2a227d0885528429c66dbcc0ceb2f8516bfe6916dadde511611cc78cd → 0xb37356 `.rsrc` `\rCurrent water`, refs 0.
- "WATER": total=2 (earlier pre-verification pass; same `.rsrc` form-class block) → 0xa94ac0 `TFORMWATERS`, 0xa9516c `TWATERFIELDSFORM`.
- "Reflection": total=11, id ev_278ead627103537df7e13030e04c30b167b991cdc6c3803904b5fd5db83d7de8 → 0xaf3e55 `CheckBoxPermitWidthReflection`, 0xaf3e9d `PermitWidthReflection`, 0xaf3ec6 `CheckBoxPermitWidthReflectionClick`, 0xaf3ef6 `CheckBoxPermitHeightReflection`, 0xaf3f3f `PermitHeightReflection`, 0xaf3f69 `CheckBoxPermitHeightReflectionClick` (permit-checkboxes, NOT water), plus water-form 0xb376c1 `LabelReflectionAmount`, 0xb376fe `Reflection amount`, 0xb37f99 `EditReflectionAmount`, 0xb37fe1 `EditReflectionAmountChange`, and 0xb69583 `tmmCubeMapReflection`. All `.rsrc`, refs 0.
- "ReflectionAmount": total=3, id ev_c5ece9b5b18dca9e08eed1609719cc8dab21bbb0273d5ac5fb30b715594f463e → 0xb376c1 / 0xb37f99 / 0xb37fe1 (same three as above). `core_feature_find` (case-sensitive): id ev_406485e986bb14f9e343702013619793d039d53fcc729d17008897c82f6d60b4, "3 matching strings, 0 matching function names, 0 matching imports; 0 functions involved."
- "Fresnel": total=8, id ev_74a675b556fcc9cece2747858043495f32117c600789826db84794b3b4e14e24 → 0xb37767 `LabelFresnelPower`, 0xb377a0 `Fresnel power`, 0xb377b8 `LabelFresnelBias`, 0xb377f1 `Fresnel bias`, 0xb38065 `EditFresnelPower`, 0xb380aa `EditFresnelPowerChange`, 0xb380c9 `EditFresnelBias`, 0xb3810d `EditFresnelBiasChange`. All `.rsrc`, refs 0. `core_feature_find` FresnelPower: id ev_db4df4fb62ddaf541ae22a036a78e14b7026d7693127944536c1717b1549fa8d, same 3 strings (Label/Edit/EditChange), 0 functions, 0 imports. "fresnel" lowercase: total=0, id ev_117e69a71baff99e3b1bbd9cc4ee431cca9669d90cdcd2e1cfd679ad9526ed96. "FresnelPower": total=3, id ev_bb3aa83e07a7aa6013108e608a99b359c1ae5d5bcc0d064b88e80f294cfe0435. "FresnelBias": total=3, id ev_953afa6af98b4cbffc46401646a94ac66013bf53944abe5016ed95556e3bdc1e.
- "Wave": total=24, id ev_ce7fdb3c3e35495f52ea53f241182d5e7f28c84542e36c7d49c30805086b8c5c → 0xb37853 `LabelWaveFreq`, 0xb3788e `Wave freq`, 0xb37a14/0xb37a5d/0xb37aa7/0xb37af1 `LabelWaveDir0_X/Y`, `LabelWaveDir1_X/Y`, edits 0xb38191–0xb38526 (`EditWaveFreq/Change`, `EditWaveAmp/Change`, `EditWaveDir0_X/Change` …), 0xb39263 `LabelWaveLength`, 0xb3929a `WaveLength`, 0xb394af `EditWaveLength`, 0xb394ef `EditWaveLength`. Lowercase "wave": total=4, all `.idata` audio imports (`waveOutWrite/PrepareHeader/Open/Close`, 0xa400d4–0xa4010a) — unrelated winmm. "WaveLength": total=4, id ev_99b65b9aace0c7151c6f705b8741c112b9b65782fdbc43f61d1c45b474c931f4. "WaterAmount": total=3, id ev_329835075086440f8688ff85ed3f8578f58a4e043985779d47b0d63d25ccde88 → 0xb37719/0xb38004/0xb38047. "WaveSpeed": total=0, id ev_af610068a33866f6a572a4cd6ddd0842eb17d825abaa315c62011fffa3dc04e7.
- "TexScale": total=17, id ev_b43c184464c8db3d009a7c4603e855a3e54c9e670e3381c9041ee70d695ff019 → decal/BSprite entries (0xae7e15–0xb0b234) plus water-form 0xb382fe `EditTexScaleS`, 0xb38346 `EditTexScaleSChange`, 0xb3835c `EditTexScaleT`, 0xb383a4 `EditTexScaleTChange`. Water S/T edit names exist as labels; no code refs.
- "WaterShader": total=1, id ev_dedac38abf421f3f2960d76d9cebcec3bfdc416898e4b7ba04fe8eb73eb277dd → 0xaa1af3 `$XWaterShader` (`.rsrc`). `core_feature_find` XWaterShader: id ev_20b87b40fdba06c5e0a4140c0a607d8020893eb27cca89b02602387af2676478, 1 string, 0 functions, 0 imports.
- "DiffuseWaves": total=0, id ev_75b7bd86d34109aa421a1115b59d4d5674ef5606bc63e187ab0b0714b0a5afa9 (subject-verified). "HeightMap": total=6 — all heightmap import/export/apply buttons (0xb67d8d–0xb67f80), not water-shader uniforms. "WaterLibraryFileName": total=4, id ev_71e98d521fe48704dde82386dfeba6eabfe73ba0976be24a1561bbe3b3453227 → 0xb2631e/0xb26361/0xb27b00/0xb27b4f (Label/field/Edit/EditChange), `.rsrc`, refs 0. "water.lib": 0 (feature_find id ev_2e8c204d69e153aacbd2fa75b2be72f91659c94cfd07c844240952a2283fd64c). "shaders.lib": 0.
- Raw `bytes_find` on editor.exe (path=, exact text): "CustomShaderID" total=2, id ev_c3fea5da90af1cb7559b1bae3d9cb2083b821ecf6d3fdc187e8738482b8c3c7d; "HeightMapEnable" total=2, id ev_8b165a64ef42764b844656617fbd903632f05a60ec7a1d4. BUT subject-verified `strings_find` for both (and "CustomReflection", "DiffuseWaves") returns total=0 with subject 68474ddde43f (ids ev_70d4a888611fdce1353148610dc806830cb41cab8eca411372ffda1ad99830a9, ev_5717f40235ee3bb6274cd6487e77c68e657e9082206a76d9b5c40eb65901d96a, ev_cb7b191519d4dd77524ddfe7f78a2231801ec3aea140d0dc1b5dd95e80071d79, ev_75b7bd86d34109aa421a1115b59d4d5674ef5606bc63e187ab0b0714b0a5afa9); `feature_find` CustomShaderID: id ev_055fb5036dfec3bc53e7d14cc78042a6d55602d3452b8cde73896f8c3a0b475c, 0 strings/0 functions/0 imports. Reading: the two raw byte hits live outside decoded data-section strings (likely packed DFM/form stream); they name water.lib fields but carry no address, no VA, no xref, no function. NOT scalar liveness.
- FILE/ENGINE selectors: `bytes_find` editor.exe "FILE" total=7, id ev_168c5cebc433b1d360e7c19d032ed4838ab50857bbf7806138fb83d10e8c1419 (raw file offsets only, no VA, no linkage to water strings established); "ENGINE" total=0, id ev_3e119ea812b354f498f7c1f4373520859ece6085b2a5210a5752a88fac4c6703. No FILE/ENGINE token is co-located with any water string by any evidence in this sweep.
- Float literals near water code: NONE FOUND. Every water-related string above has `references: []` and every `feature_find` reports 0 functions involved, so there is no located "water code" to be near. No float literal is tied to any water scalar by evidence here.

Liveness verdict (editor.exe): does NOT supply runtime water-scalar liveness. It is a Delphi
VCL editor whose `.rsrc` embeds the water-editing form (labels + Edit/Change handler names:
ReflectionAmount, WaterAmount, FresnelPower/Bias, WaveFreq/Amp, WaveDir0/1_X/Y, WaveLength,
TexScaleS/T, WaterLibraryFileName, $XWaterShader). Handler names prove the editor CAN edit
these values; no code, import, xref, float, or FILE/ENGINE binding for any scalar was found.
The cossacks.exe 0-hit gap is not closed by this binary.

## 2. config.exe (subject cddfee5587f2) — NO water-scalar strings; earlier hits were stale cache, excluded

Subject-verified `native_strings_find` (limit 50, offset 0; Reopen config.exe sha cddfee5587f28956730ab1dd50710331982b8f39b03e976713cb89bd3990050d):
- "Reflection" total=0, id ev_2da1be3048528969162be0f7d2c34af54a25c9fa0e78f8f173d69fd2695c3fff; "Fresnel" total=0, id ev_1e72420b2aeb28f1e42f8f722412ef46635ff93306cc8a4fc792b6cefe574fd6; "Wave" total=0, id ev_ad5873ed891b3f86cd1825f92369db4c3d768c39f233c43d33cbef05acf7acc3; "water" total=0, id ev_069954186aed0e4c8c3f68bc45f2d43c17b3c62ef69d88f63284bd5196a6e820; "DiffuseWaves" total=0, id ev_de9634445057efce33e9f2666b4b433ae32a8903c3dabc683890f9e31249de42; "Water" total=3, id ev_7af58e509f6280373f5d4ece6d4e20d19264e76c0092252399ee54c5bde1f64e → 0x845842 `$XWaterShader`, 0x845b7a `fXWaterField`, 0x845bf0 `XWater`; "WaterShader" total=1, id ev_20e6aa2aef48f6aa7b56826bdf2d8aa9854a3cf257134a0927bf740da9ef5b4b (same 0x845842).
- `core_feature_find`: "ReflectionAmount" 0/0/0, id ev_c2900865464d16449f65a78285743f2253a140403a298aa4c435e945571c0a18 (subj cddfee5587f2); "water.lib" 0/0/0, id ev_35751928e23ab652ef3db7ae79bfcf89c6ff862b3fe30d15e109fc3dc55d9fcd.
- IMPORTANT (discovery-limit note): a first pass WITHOUT subject checking returned 11 Reflection / 8 Fresnel / 24 Wave / 17 TexScale hits on config.exe with evidence ids IDENTICAL to editor.exe's (e.g. Fresnel ev_6ad732916aef72ff82cc78e5e6bf6ba171a95635492a7a58b1147d29ac26054a). Re-query with subject verification shows subject=config and totals=0. Those first-pass rows were ledger cache from editor.exe and are EXCLUDED. Any consumer must re-check `subject.sha256` before citing.
- Float literals / FILE/ENGINE near water code: none — no water code located (0 functions involved everywhere).

Liveness verdict (config.exe): NO. Only殘留 `$XWaterShader`/`fXWaterField`/`XWater` triad (VCL datatype names, same as modman). No scalar name, no value, no function.

## 3. modman.exe (subject 0d7db745f7f0) — NO water-scalar strings (same cache caveat as config.exe)

Subject-verified `native_strings_find` (Reopen modman.exe sha 0d7db745f7f0787702e8ffc7257bee1bbf76aa727bcdd57d5133e771727d07fe):
- "Reflection" total=0, id ev_4d49ebf1a8df9c0fa46e6d11cfc9e02fa85584134ada05c5f39579bc4e81f5e4 subj 0d7db745f7f0; "Fresnel" total=0, id ev_abe0647e1bb4b92a8bbbad4757ca06681782eae37da29a2f824478103109b5dd; "Wave" total=0, id ev_0bf4210b25902de5fec1da6067c92dbb134af3c22121303df442863365f302f6; "Water" total=3, id ev_18478249fd222363d190015624527bf9615fcd16d50ec4a826d1f31e97114041 → 0x819251 `$XWaterShader`, 0x819589 `fXWaterField`, 0x8195ff `XWater`.
- "water.lib"/"shaders.lib"/"ReflectionAmount"/"DiffuseWaves": 0 in the subject-verified pass pattern (first-pass rows that reused config/editor evidence ids, e.g. Fresnel ev_6ad7…, Wave ev_f155…, WaterShader ev_1010…, are EXCLUDED as stale cache — fresh ids above prove totals 0).
- Float literals / FILE/ENGINE near water code: none — no water code located.

Liveness verdict (modman.exe): NO. Same datatype-name triad only.

## 4. codex.dll (subject 382a95940910) — clean zero across the board

`core_target_open` sha 382a95940910172335a3f6356671e3cf6e514ec95b98faf5d943b23870164afc, 106272 bytes. Subject-verified `native_strings_find` (limit 50):
- "ReflectionAmount" total=0, id ev_8617305957722ab69ac6983cb85553913102358067e9a64e482b3eab7739d03b; "Fresnel" 0, id ev_e2ca165ab68c8bcb249e2b64832a7ff45d48541bd5c6e55d80040c8faf2864a0; "Water" 0, id ev_a85a54f2c16b6f33a13d1bd2d77060fd5bd293d06e74746ec1af19423fdbe954; "water" 0, id ev_56f919599437501cb9b8629429dfa66a02877d1c3f52720f4f706f2336bd579c; "DiffuseWaves" 0, id ev_4307f6ec6b51b6af7eb678ec20ced394ec48ed23a51bf2bcb33ccf6bcc40da44; "WaterShader" 0, id ev_36883209dc7869964329a67b260a697c6903ab440a2e10ea19e2d8d1faca4e39; "shaders.lib" 0, id ev_21b4a83780ab189e3e80093bddf6a4acf24c70847c2a8bace1e3c8230fadbe70; "water.lib" 0, id ev_ec746de6e5f0469f5314c7ebc00478bd59b527585dfdebc452c0964b52bd451e (all subj 382a95940910).
- `core_feature_find`: "ReflectionAmount" 0/0/0, id ev_6deed03f4d9d1e3c69edd5d9173e3ccc5e330fbb72833a7576fa8bd26bba8ca8; "water.lib" 0/0/0, id ev_9a6c0dbbcd5ebae87601eb7e6abde755ffd8c9274832baf6653ccea90014aa9d.
- Float literals / FILE/ENGINE: none searched beyond the above — nothing to localize; no water code exists here.

Liveness verdict (codex.dll): NO. Contributes nothing to water-scalar discovery.

## 5. data/water/water.lib (subject 88b3cdc6ba37) — the scalar source of truth (static defaults, NOT liveness)

`core_target_open` kind=text, sha 88b3cdc6ba3770b23d620f013c518084214968e9db6f4e8e0505de6e4095e17c, 2063 bytes. `core_text_read` full file, 71/71 lines, id ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff. Complete content (verbatim, values are DONOR STATIC DEFAULTS — cited as text, NOT as verified runtime behavior):

Name=default, MaxDepth=1, MinDepth=0, MaxAlpha=1.1, MinAlpha=0,
DeepColor=(0, 0, 0.1255, 0.5), ShallowColor=(0, 0, 0, 0.5),
ReflectionAmount=1, WaterAmount=1, FresnelPower=1, FresnelBias=1, HDRMultiplier=1,
WaveFreq=0, WaveAmp=0, DistFactor=1, BumpFactor=1,
TexScaleS=0.1, TexScaleT=0.01 (commented alternatives 0.115 / 0.015),
WaveDir0=(-1, 0), WaveDir1=(-0.7, 0.7), Speed=1.0,
NormalMapLibMaterialName=DiffuseWaves2, DiffuseMapLibMaterialName=DiffuseWaves0
(commented: HeightMapWaves0 / DiffuseWaves0),
Width=1, Height=1, Offset=0.495, LayerCount=1,
CustomEnable=False, CustomShaderID=0, CustomReflection=False, CustomReflectionUnit=0,
CustomLibMaterialName=(empty), CustomTexCoord=True, CustomTexCoordScale=1,
CustomTexReflectMatrix=False, CustomTexReflectMatrixUnit=0,
HeightMapEnable=True, ShadowMapEnable=True,
MaterialLibraryFileName=.\data\water\water.mat, DefaultWaterIndex=0, Tag=512,
VertexProgramFileName=.\data\shaders\water\water.dev.vert,
FragmentProgramFileName=.\data\shaders\water\water.dev.frag
(LOD program names empty).

This file DEFINES every scalar named in the task (ReflectionAmount, FresnelPower/Bias,
WaveFreq/Amp, WaveDir0/1, TexScaleS/T, WaterAmount, WaveLength-family via WaveDir/Length
editor labels, DiffuseWaves materials, HeightMapEnable). It does NOT show any binary
reading/wiring them — no EXE/DLL in this sweep references "water.lib" by string
(editor ev_2e8c…, config ev_3575…, codex ev_9a6c… all 0/0/0), and cossacks.exe prior
discovery found 0 hits for "water.lib"/"ReflectionAmount" either. The filename→loader
link is therefore UNPROVEN by string evidence; do not claim the runtime loads this file
on the basis of this sweep.

## 6. data/shaders/shaders.lib (subject a18aa083616e) — NO water content; object shaders only

`core_target_open` kind=text, sha a18aa083616e771e24b7f0ea9c0a08ff2e426e3d756dc1e23a0c6fce27c867ae, 63077 bytes. `core_text_read` first 200/1813 lines, id ev_5ffc0418a8aa940cd9db7f3c7c68db14c6ccaca81f7a40523d9a1f33f8c7999b: Register block (srShadowColor…srPostProc) + ShadersSM20 { HeightField, Default, None, Grass, Decal, DecalCubeMap … } referencing `.\data\shaders\obj\*.vert/*.frag` only.
Exhaustive `native_bytes_find` (path=, exact text, utf8+utf16le) on the whole 63077-byte file:
- "Water" total=0, id ev_4d06e427fcd3cfdf080c922ff8ad25f7800c44fc4533bd1314ecb2993ceb1090; "water" 0, id ev_12b847df07d6ddd435ae580c798a19ba610415d6fc8e95354541cb30eb29e07a; "XWater" 0, id ev_780343182f8322e9694fbdc0089ecc4ca03a97f596937f73a8b84c7135f561b1; "WaterShader" 0, id ev_8f37ceccaf6fa1a5096d30c2ee5891408f0f5ab568dbd1c8ef955c68a8bbdea9; "DiffuseWaves" 0, id ev_a3e57abda666e930a3e499416aa827f48b42a1205894f4307a30428a; "HeightMap" 0, id ev_2bf2b99012d4bafd903769730cb7dcb69402a3e4a3b6679473933b84b8d72557; "Reflection" 0, id ev_89b5dbc41dbe035d0fa0b6175047df9fbc45d26225f51d1cb9dc2b406ac9b394; "Fresnel" 0, id ev_e3332d45c0b31678e5e6bf6ba171a95635492a7a58b1147d29ac26054a.
- Controls proving the file WAS searched (not empty/missed): "ShadersSM" total=2, id ev_58dd2c0c999dd6f91e136e44859498dc3fab86845e8fc38433da90751c4c7532 (offs 0x184, 0x7bf1); ".vert" total=76, id ev_346e7b7aa079936f2ffcca18f77e210ce64922f115e417ab59167a55ccdd6c9a; "water.dev" total=0, id ev_527c6f369a5e4839d17f7641590c9dca25eded2160fb3863e2b3d9be8b593c60.
Reading: water shaders live elsewhere (`.\data\shaders\water\water.dev.vert/.frag` per water.lib), NOT in shaders.lib. shaders.lib contributes no scalar, no FILE/ENGINE water selector, no float.

## 7. Discovery limits (explicit — 0 hits ≠ disproof)

1. `native_strings_find` searches only stored strings in data sections (engine limitation string "data_sections_only" on every hit record); absence is not proof — runtime-built, encrypted, or resource-file text is invisible to it.
2. Evidence-ledger caching: identical query+limit on a NEW active target can return the OLD target's evidence id (observed: config/modman first-pass ids ev_6ad7…, ev_f155…, ev_1010…, ev_4923… identical to editor.exe's). Every citation above was re-queried until `subject.sha256` matched the file. Unverified first-pass rows are excluded, never cited as hits.
3. `.rsrc` Delphi form strings carry `references: []` in this engine — handler names (e.g. `EditReflectionAmountChange`) prove an editor UI exists, not that any shipped binary wires the value at runtime; the code behind the form was not located (0 functions involved in every `feature_find`).
4. `bytes_find` on editor.exe for water-lib field names ("CustomShaderID"/"HeightMapEnable" = 2 hits each) has file offsets only, no VA/xref/function — consistent with a packed DFM stream, not code.
5. `core_feature_find` covers strings + function names + imports + using functions; packed, delay-loaded, or data-driven (filename in .ini/.lib, not in PE) loading is out of view. The water.lib→EXE link ("who loads water.lib", FILE-vs-ENGINE selection, per-scalar upload) remains UNOBSERVED in every binary swept.
6. shaders.lib verdict is exhaustive for literal spellings listed; exotic spellings (e.g. lowercase shader-internal uniforms inside `data/shaders/water/*.vert/*.frag`, which were NOT in scope) are untouched by this sweep.

## 8. Bottom line (no parity claim)

- editor.exe: rich water-editor UI strings (all addresses/ids above) but ZERO code/import/xref/float/FILE/ENGINE evidence → NO scalar liveness. Documents which scalars the editor knows, nothing about runtime.
- config.exe: NO water scalars (3 datatype-name strings only) → NO liveness.
- modman.exe: NO water scalars (same 3 datatype-name strings only) → NO liveness.
- codex.dll: all-zero → NO liveness.
- water.lib: full static defaults transcribed (§5, ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff) → source of NAMES+DEFAULTS, not of runtime wiring.
- shaders.lib: zero water content (8 exhaustive 0-hit ids + controls) → NO liveness.
- Nothing in this sweep closes the cossacks.exe discovery gap. The binary that loads water.lib, selects FILE vs ENGINE/custom paths, and uploads ReflectionAmount/Fresnel/Wave/TexScale/HeightMap uniforms is still UNIDENTIFIED by string evidence. No value invented, no scalar wired, no parity claimed. Chain 0/6; RESULT IS NOT GOOD.
