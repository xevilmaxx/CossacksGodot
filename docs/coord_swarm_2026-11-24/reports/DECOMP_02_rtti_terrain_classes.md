---
id: DECOMP-02
title: Donor Delphi metadata name table — terrain/texture/rendering names deep dive
area: donor / decompilation / terrain research
owner: DECOMP-02 (subagent)
date: 2026-11-24
status: AUDIT DONE — names and offsets proven; implementation UNVERIFIED
tools: Craft Anything 0.6.1, native toolset, Deep mode, clean_room=false; read-only Python byte check
target: cossacks.exe, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, target id t_87f0f3c130b0
---

# Scope and method

Read-only static audit of the donor `C:\Games\Cossacks 3\cossacks.exe` (already open as
`t_87f0f3c130b0`; **no** `core_target_open`, no runtime unpacking, no instrumentation,
no source/asset/git edits). All Craft Anything calls were made in Code Mode with
`document:"t_87f0f3c130b0"`. Native toolset enable / target list: idempotent setup call.

Evidence used as anchors:

| What | Evidence id |
|---|---|
| Target identity / SHA-256 | `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` (from DECOMP-01) |
| Section map (`.rsrc` VA `0x94c000`, raw `0x53d200`, size `0x1f400`, entropy 5.08; `.bind` entropy 7.96) | `ev_d5b51af0808dd609842ab36f411ca6cbd51212d8de038e641acfd28d3198239f` |
| 6,800-byte window `0x958320..0x959d00`, from which 438 metadata records were parsed | `ev_0d268a37cb40b5033673865b0f0f50d8d568142a32d36a1aa11044642c2d4f54` |
| `.rsrc` browse, 4,090 strings | `ev_0d268a37…` window plus `native_strings_browse` (section `.rsrc`) |

VA→file mapping in `.rsrc` is **`file_offset = VA − 0x40EE00`**
(`0x94c000 − 0x53d200 = 0x40ee00`; per-address confirmations below).
A read-only Python `latin-1` byte check at those offsets independently reproduced
the decoded names (see §2).

# 1. Key correction to DECOMP-01: the leading byte is NOT part of the name

`native_strings_find` / `native_strings_browse` report the address of a **metadata flag
byte**, not of the first name character. Parsing the record stream shows the layout

```
<name ASCIIZ>  00 10 <flag byte> <next name ASCIIZ>  00 10 <flag byte> ...
```

for most entries (some core units use `00 00` instead of `00 10`, e.g.
`SysConst 00 00 c7 System 00 00 81 SysInit`). Raw check at `0x549310`:

```
... db 'engine' 00 10 0d 'frmConfig' 00 10 29 'XWideStrUtils' 00 10 16 'Math'
    00 10 9d 'SysConst' 00 00 c7 'System' 00 00 81 'SysInit' 00 00 02 'SysUtils'
```

Therefore the **decoded name begins at `browse_address + 1`**, and the character that
DECOMP-01 read as part of the name is a varying tag byte. Confirmed by
`native_data_show(type:"cstring")` at `0x958aa3` → `"XHeightField"`,
evidence `ev_f724796822d4da9adb433cf1e9b3ca0683c238bbfdfd2da00a3331bd224e661d`.
Independent Python read at `0x549ca3` returned `b'XHeightField'`; at `0x549849`
returned `b'EXTerrain'` (flag `0x45` + `XTerrain`); at `0x549862` returned
`b'LXShaderLOD'` (flag `0x4c` + `XShaderLOD`).

| DECOMP-01 / browse text | Decoded name | Flag byte | Name VA | File offset |
|---|---|---|---|---|
| `EXTerrain` | `XTerrain` | `0x45` | `0x95864a` | `0x54984a` |
| `HXHeightField` | `XHeightField` | `0x48` | `0x958aa3` | `0x549ca3` |
| `LXShaderLOD` | `XShaderLOD` | `0x4c` | `0x958663` | `0x549863` |
| `?XMap` | `XMap` | `0x3f` | `0x958ab2` | `0x549cb2` |
| `<XTerrainBorders` | `XTerrainBorders` | `0x3c` | `0x9593b4` | `0x54a5b4` |
| `%OSWTexture` | `OSWTexture` | `0x25` | `0x9586cf` | `0x5498cf` |
| `sXTerrainData` | `XTerrainData` | `0x73` | `0x958b76` | `0x549d76` |
| `dXTileSeason` | `XTileSeason` | `0x64` | `0x9593a6` | `0x54a5a6` |
| `tXMapCover` | `XMapCover` | `0x74` | `0x959424` | `0x54a624` |
| `DXPatternMask` | `XPatternMask` | `0x44` | `0x9593c6` | `0x54a5c6` |

The names DECOMP-01 reported without a visible prefix (`XTerrainDataLite`, `XBrush`,
`XWorld`, `XTile`, `XColorTable`, `XTileSmooth`, `XMapGenerator`) were correct: their
flag bytes happen to be non-printable (`0xf9`, `0xdd`, `0xa2`, `0xd6`, `0x1a`, `0xdd`,
`0xba`).

# 2. Evidence table — primary requested names

Offsets are per-address `native_address_offset_show` results; the name-string
evidence ids come from exact `native_strings_find` calls (which return the flag-byte
address, i.e. name VA − 1).

| Decoded name | Name VA | File offset | String evidence id | Offset evidence id |
|---|---|---|---|---|
| `XTerrain` | `0x95864a` | `0x54984a` | `ev_dfc557ef7ce1650d193a03912f7714e140a4c7af348013c94cbf88d2c2c933ec` | `ev_e6803641c10cb678fd0857623c400410e0dd7563c0022eeb7dd3f8d8ab71fc83` |
| `XTerrainDataLite` | `0x9587c3` | `0x5499c3` | `ev_6aee1b0589fe6356c52dd8e1550b1b4561aba16997981c315b36b215e3a286da`, `ev_35f1d569c7eaa19fc5617ca5e7a61523fa92b1d0f35dcbadf9ef6335104e4910` | `ev_d84ea44909357dc8805335eb3754494bbd06d85b19d89f42b6e83074cfdd38b3` |
| `XTerrainData` | `0x958b76` | `0x549d76` | `ev_ab064aeaa88e31f704b8b2ab4e17e3dbdef1d90ee889fe409ff0ba85b4408fcd` | `ev_5def7bb36e1341cc3e28079e35c862fa79293a6f20851b0075e09e8b5aff84b3` |
| `XTerrainBorders` | `0x9593b4` | `0x54a5b4` | `ev_80cf77304f260097f9382aa0d45f8c7ccc9f2c75a9bd5a20daf3be7f3fd71f60`, `ev_adc8617b9fbdea79acc02c250281953ff4f0837cfd55883f98bcaafb70f37c0f` | `ev_b882a6e8c812cf072612ef5752e19ff4421b47cf14843900e9fba7e74159aae8` |
| `XHeightField` | `0x958aa3` | `0x549ca3` | `ev_75a95ea13892feaa82741eeebbbce7501101bcfac3b340767c2d7d4cfa00e51f`, `ev_b22ab3b609d3e36230fd61b20a903f32be528cc4619e93c4c769500ad0b62825` | `ev_323f070019e8c6a361e4f12a821fa491f796add5b3a371cba37ea9326381a455` (flag), `ev_56e741b0f73ec5ac82f2da0583feddeb03a27e8348df2806b24db54007d6c338` (name) |
| `XMap` | `0x958ab2` | `0x549cb2` | `ev_5db368ed3c62f2649dbc5e4a52c4559b272dde58b6f295d9090a4f7dcf4febad`, `ev_c8921cfce33718b22cfdf2da042e0e06de7c4956ef1c7a9eb9b15868c2e39257` | `ev_f44bbbe2cd8ec770cb2aaa0c43dbdb612262a067a3b85c8a6557fe69dd0abbd3` (flag), `ev_51a06b5704c58a233382b21ce4e388de416fc11c5d25fcd8f07e3c97b3526c28` (name) |
| `XTile` | `0x9589e9` | `0x549be9` | `ev_3d02ea4bbbf2eac467ed3d535ccb55d0752d5748d021e932f4d8a93036936b50`, `ev_c840402a0efcfdd19f379769845bc083afd86faa84575f17f4c922116c7f3373` | `ev_a5989170f6de538b70bdd732b5c9daac5d359a395dbe5877c8c621f44b8c6f6b` |
| `XWorld` | `0x9589e0` | `0x549be0` | `ev_405e8d8c65833d4dc903f9660cd1d252a1bde2dda06bc2f3cc59e4bbe00671e6`, `ev_c5c90eb8957597cac02b52073c975ac6ffe8f9dfd170158f03ddf7dd9a169007` | `ev_7bf93e5f10c7fc5f5b9f81a0da7459957733903b52c09475250dec727c487789` |
| `XColorTable` | `0x958ab9` | `0x549cb9` | `ev_a2b37d828da344908d4d7437b740198f7a4ef5cd007381631c7f8299a713e1aa`, `ev_71acb141f836bf1c0f9707c5d9c14aad9765303f3b44d52955ef30c694d8d470` | `ev_93559cf6c7ad458a09c84b5f854b1c5afca4567a797d49be649f224e6dbb384f` |
| `XBrush` | `0x9587d6` | `0x5499d6` | `ev_b97e081e297a3fc1ea3f4c6f1a7dc6e95ecd98b7eb779692eb69e11371711864`, `ev_4db80c23136901e4f227660e8f6067ec37da7e95ea51c883ba64443ebd64c87a` | `ev_c12ca1102b6dcc417577d4abb9f9d23dcc1c156ba26d55f7ccb7d19df68df428` |
| `OSWTexture` | `0x9586cf` | `0x5498cf` | `ev_3f5b4cc8b9bbb2837ccf1b2963accb1699739a1b5f7f855d7b929b8e126b50e4`, `ev_e1815cfb73a93dfd682130f7c43b6bee80d52d6ffcd1c669eea9e9ad87ca5876` | `ev_4308224b935e196929749662e8a338d9b98e9c6c6c5841991aa8608c5a168a39` |
| `XShaderLOD` | `0x958663` | `0x549863` | `ev_4b21ac8bc94a25315c86c5652030405cca83443e97fb8210bc54482b6634876d`, `ev_0e57fdef9a446d3bd7a83f1f32b489883cf36eaac4d6b3fa54c52b57fb80c700` | `ev_5fa72166bddf67b109b1d5e437566660a544a15de5941b71985749f4076e446d` (flag), `ev_b8656bba87a6a65a3597e28b9ce023b7449c798cfd3c2a9e754a4819987eb445` (name) |
| `XRenderPool` | `0x958655` | `0x549855` | `ev_dd61c8d0f0fe822f53d76ef868b9aec6087f7267cea7b60923311c61f8f60042`, `ev_f061a61aac12e081bd14a177bfe3942ce42f8996e7f3b7a4064fac88680a89cf` | record in window `ev_0d268a37…` |
| `XTileSeason` | `0x9593a6` | `0x54a5a6` | `ev_b76adfdffe9293ad41dc11d84e8e5a283345a0a4254f23c9bf5673bee2a80583`, `ev_ea4e27b0e5a7ab954a8f551a3645c2c1efd66e9a650215dee6177e5e2e9523bd` | `ev_ffa66feb1f2167f2295a9abdb0b93525f9c47989fec2b55e6e8c52dd8551a9b8` |
| `XTileSmooth` | `0x959416` | `0x54a616` | `ev_dfafdccd498f3aaa945519cc268dabd5f7263a78560a33acd7d3be4229f929f8`, `ev_d49b4730e47d971faf3f346342324441b85c251b5f7f487378c51c702997759d` | `ev_28bd64298b878e764104f2e68182db1910ad8c86feae18ce69bbd85d57545fec` |
| `XMapCover` | `0x959424` | `0x54a624` | `ev_f8a1521d7ae85940a18c1f4f7a77adbb4ac866734c699dbca9d47d667e66caab`, `ev_c035f02f0befc1b30b9fbe4c2d77b1599db316406e60adcee299f52c2ebd6ab7` | `ev_6221439711676c86d4236296d02eacc00bfe265fe30e4a13a60fe67e09d6eba5` |
| `XMapGenerator` | `0x959430` | `0x54a630` | `ev_2c6b0ddc1c2a5b2f2e947a21b7d71ed4134b0a2324ba34cf76aad3872d2e8d1d`, `ev_4cb67cefa8731c9c1c778a49d56186d4e9260841aee32d8e7394200061af2748` | `ev_a6559b998b8ac3c075ab280b1a490b4a793966937e4af84f67d25cd19a29eb23` |

# 3. Full decoded terrain / texture / rendering name set

All rows come from the same byte-window parse (`ev_0d268a37…`); the 438-record table in
that window spans VAs `0x958320..0x959d00`, file offsets `0x549320..0x54aa00`.
Meanings are **INFERENCE from the name only** — no implementation was recovered.

| Decoded name | VA | File offset | INFERENCE from name |
|---|---|---|---|
| `OSWGeometry` | `0x95860f` | `0x54980f` | Geometry/math primitives for the OSW engine layer. |
| `XTerrain` | `0x95864a` | `0x54984a` | Root terrain object/unit. |
| `XRenderPool` | `0x958655` | `0x549855` | Pooled render resources. |
| `XShaderLOD` | `0x958663` | `0x549863` | Shader detail level / LOD selection. |
| `OSWTexture` | `0x9586cf` | `0x5498cf` | Texture object. |
| `OSWTextureImageEditors` | `0x9586dc` | `0x5498dc` | Editor-side image/texture tooling. |
| `OSWOpenGL` | `0x958758` | `0x549958` | OpenGL backend unit. |
| `OSWGraphicsFormats` | `0x958764` | `0x549964` | Image format codecs (DDS/jpeg etc.). |
| `OSWXOpenGL` | `0x95878a` | `0x54998a` | Extended OpenGL layer. |
| `OSWGraphics` | `0x9587aa` | `0x5499aa` | Core graphics types. |
| `OSWState` | `0x9587b8` | `0x5499b8` | Render-state management. |
| `XTerrainDataLite` | `0x9587c3` | `0x5499c3` | Lightweight terrain data representation. |
| `XBrush` | `0x9587d6` | `0x5499d6` | Terrain/editor brush base. |
| `XMaterialLibraryInterface` | `0x95884e` | `0x549a4e` | Material library abstraction. |
| `XCollisionMask` | `0x9589c7` | `0x549bc7` | Collision/terrain passability mask. |
| `XWorld` | `0x9589e0` | `0x549be0` | World container. |
| `XTile` | `0x9589e9` | `0x549be9` | Map tile primitive. |
| `XMaterialLibraryContainer` | `0x9589f1` | `0x549bf1` | Material storage implementation. |
| `XCollisionTags` | `0x958a13` | `0x549c13` | Collision classification tags. |
| `XLightShader` | `0x958a87` | `0x549c87` | Lighting shader. |
| `XShadowMap` | `0x958a96` | `0x549c96` | Shadow-map rendering. |
| `XHeightField` | `0x958aa3` | `0x549ca3` | Heightfield data structure. |
| `XMap` | `0x958ab2` | `0x549cb2` | Map data object. |
| `XColorTable` | `0x958ab9` | `0x549cb9` | Palette / colour lookup table. |
| `XLightPatterns` | `0x958ac7` | `0x549cc7` | Light pattern definitions. |
| `XAir`, `XStars` | `0x958ad8`, `0x958adf` | `0x549cd8`, `0x549cdf` | Atmospheric/sky elements. |
| `XPHDR*` (`XPHDRToneMapShader`, `XPHDRFilterShader`, `XPHDRGaussShader`) | `0x958af0`, `0x958b05`, `0x958b19` | `0x549cf0`, `0x549d05`, `0x549d19` | HDR post-processing shaders. |
| `OSWARBProgram` | `0x958b2c` | `0x549d2c` | ARB (OpenGL) vertex/fragment program wrapper. |
| `XLightSourceManager` | `0x958b3c` | `0x549d3c` | Light source bookkeeping. |
| `XSkyDome` | `0x958b52` | `0x549d52` | Sky dome mesh/rendering. |
| `XEnvironment` | `0x958b5d` | `0x549d5d` | Environment rendering. |
| `XCamera` | `0x958b6c` | `0x549d6c` | Camera. |
| `XTerrainData` | `0x958b76` | `0x549d76` | Full terrain data representation (contrast with Lite). |
| `XMeshObjectsLibrary` | `0x958b97` | `0x549d97` | Mesh asset library. |
| `OSWBaseMeshSilhouette`, `OSWMeshUtils`, `OSWGeometryBB`, `OSWOctree`, `OSWMesh` | `0x958bc4`, `0x958bdc`, `0x958beb`, `0x958bfb`, `0x958c07` | `0x549dc4`, `0x549ddc`, `0x549deb`, `0x549dfb`, `0x549e07` | Mesh / bounding-volume / spatial indexing utilities. |
| `XWaterShader` | `0x958c11` | `0x549e11` | Water rendering shader. |
| `OSWTextureCombiners` | `0x958c20` | `0x549e20` | Multi-texture combining logic. |
| `XTopology` | `0x958ca7` | `0x549ea7` | Spatial topology relationships. |
| `XViewFrustum` | `0x958cc8` | `0x549ec8` | Frustum culling. |
| `XHorizonRender` | `0x958cf1` | `0x549ef1` | Horizon/sky-line rendering. |
| `XMiniMap` | `0x958d02` | `0x549f02` | Minimap rendering. |
| `XFOWRender` | `0x958d0d` | `0x549f0d` | Fog-of-war rendering. |
| `XSeasonType` | `0x959110` | `0x54a310` | Seasonal terrain variant enum/type. |
| `XStretchBrush`, `XArrowBrush`, `XSelectionBrush` | `0x9590c6`, `0x959129`, `0x958d56` | `0x54a2c6`, `0x54a329`, `0x549f56` | Editing brushes. |
| `OSWProcTextures` | `0x95916f` | `0x54a36f` | Procedural texture generation. |
| `XPattern`, `XPatternMask`, `XPatternFreqs` | `0x959371`, `0x9593c6`, `0x9593ef` | `0x54a571`, `0x54a5c6`, `0x54a5ef` | Texture/pattern masking and frequency control. |
| `XWaterField`, `XWater` | `0x95937c`, `0x95938a` | `0x54a57c`, `0x54a58a` | Water surfaces / water field data. |
| `XSeason`, `XTileSeason` | `0x959393`, `0x9593a6` | `0x54a593`, `0x54a5a6` | Seasonal tile variants. |
| `XCliff` | `0x95939d` | `0x54a59d` | Cliff terrain feature. |
| `XTerrainBorders` | `0x9593b4` | `0x54a5b4` | Terrain border blending. |
| `XGlobalMap`, `XGlobalCover`, `XMapCover`, `XCover` | `0x9593e2`, `0x9593ff`, `0x959424`, `0x95950f` | `0x54a5e2`, `0x54a5ff`, `0x54a624`, `0x54a70f` | Global map / ground-cover overlays. |
| `XTileSmooth` | `0x959416` | `0x54a616` | Tile smoothing pass. |
| `XMapGenerator` | `0x959430` | `0x54a630` | Procedural map generation. |
| `XWorldViewer`, `XRenderer` | `0x959440`, `0x9594df` | `0x54a640`, `0x54a6df` | Viewing/rendering front ends. |
| `XDScriptMap`, `XEditorBrushes` | `0x959573`, `0x959633` | `0x54a773`, `0x54a833` | Script-exposed map API and editor brushes. |

The raw framing around the mesh records (flag bytes `0x35`, `0x03`, `0x2b`, `0x50`,
`0x71`) is in evidence `ev_545573445f5882d7c5b744c7f862ea82ddc920e47916251933df980169311e90`;
browse strings `POSWOctree` / `qOSWMesh` decode to `OSWOctree` / `OSWMesh` exactly as
shown in the row above.

# 4. Code / function linkage: **none found** (explicit negative result)

For every primary name, `core_feature_find` returned **0 function names, 0 imports,
0 functions involved**, with string hits only (each string carried an empty
`references` list). Evidence ids:

| Query | Evidence id | Result |
|---|---|---|
| `XTerrain` | `ev_630911443b3a2706805743089e54c9001e2b4649eb1ace1103f50b04ab105165` | 4 strings, 0 functions |
| `XTerrainData` | `ev_b218360cfc5cea8f1d3bc9bd99346f27ab8d6be30d3d432f5cbf0d0e58c1c374` | 2 strings, 0 functions |
| `XTerrainBorders` | `ev_70066c87f9ec9ea62ec66563b3a10b805a94cd12896f36957dc8ce607c6f3299` | 1 string, 0 functions |
| `XHeightField` | `ev_687a966325942abb0fea609b9879d48b26355dcf5b8413454f5c0974b4f8f22f` | 1 string, 0 functions |
| `XMap` | `ev_f17f012d79c7131b593df2bc37cba1196ddcd4acee9b9db2d22a1ea6d23b1faa` | 3 strings, 0 functions |
| `XWorld` | `ev_ee9632364877605d451c5bec93bf3d397859943e82d4a87b8e0ecbd051f35cf5` | 2 strings, 0 functions |
| `XTile` | `ev_736bc1b2bedad5242b271b3d15e270545f7714060366db6d162798cceb825538` | 3 strings, 0 functions |
| `XColorTable` | `ev_32b31f588762936f845aa4d8fb452bf06e73c98f4e2b2d84004040edf0e2b72f` | 1 string, 0 functions |
| `XBrush` | `ev_a6f9287e77d6f52741df89e90803b0c754650d3a962778f8c32eea12b847e913` | 1 string, 0 functions |
| `OSWTexture` | `ev_ee0ef76d9c265e12a134fb47591bb5e04d4a325da4b7bc8da81ee3364f519fb6` | 3 strings, 0 functions |
| `XShaderLOD` | `ev_d08211754d40f07c2deef779eefdd6ffa0201e186bb107562e15f9219c2b3d31` | 1 string, 0 functions |
| `XRenderPool`, `XHorizonRender`, `XFOWRender`, `XShadowMap` | `ev_dd61c8d0…`, `ev_0b234c76…`, `ev_6a94cc5c…`, `ev_784b2d2e…` | 1 string each, 0 functions |
| `XTileSeason`, `XTileSmooth`, `XPatternMask`, `XMapCover`, `XMapGenerator` | `ev_b76adfd…`, `ev_dfafdcc…`, `ev_9dd14007…`, `ev_f8a1521d…`, `ev_2c6b0ddc…` | 1 string each, 0 functions |

Cross-checks:

- `native_xrefs_list` at `0x958649`, `0x95864a`, `0x9587c3`, `0x958aa2`, `0x958aa3`,
  `0x9593b3`, `0x9593b4` → **0 references to, 0 from** for each. Evidence ids:
  `ev_f89dfd928f2b10687f744104e3da4068d0eb99f9d9403c3dd2812c17659ccf31`,
  `ev_1ae8ae26f62c49f82b61bee1d6fb0237737fc82d80018400b3df0476bc59a06e`,
  `ev_3e4ccc34140d8a0353b56dd37f57208fd1d26f1bd64975c7c8a3c9a3b03fd846`,
  `ev_b2112f0edd22ae1d13bc0d9606b08a7258bbc72078075d53f7972e931ee3b5ca`,
  `ev_5e74ff1b47c0c32e5ad32b86c60601a7e465105120f03c2d92909f82f27b22f8`,
  `ev_109a75ae7e8a41214242c72d78c337eb17cff922b3a1d113fd21e1bf6eb1af35`,
  `ev_b94256af16b70beb9b02b8d07089d9f83ff28e7200482d06addb1f240267f4ee`.
  Limitation stated by the tool: references through computed runtime pointers are not
  seen.
- `native_address_show` at the same addresses reports "not in executable code" / no
  names / no bookmarks; ids `ev_b35fe1f8…`, `ev_abcb8ddd…`, `ev_8f00f700…`,
  `ev_90fe57f3…`, `ev_4f2fc09d…`, `ev_a19ed95a…`, `ev_fb64591e…`.
- Raw 32-bit little-endian pointer search for the decoded name VAs
  (`4a 64 95 00`, `c3 87 95 00`, `a3 8a 95 00`, `b2 8a 95 00`, `b4 93 95 00`,
  `63 86 95 00`, `cf 86 95 00`, `ea 89 95 00`) → **0 matches for each**:
  `ev_13c9b605788014acebe2ac67de03c97d1007cb56f11919a0abe81544491ee2d2`,
  `ev_87ab5e9f291aeed1f096440d7cd519be53baeb46812d9189f5c85bf1898784e3`,
  `ev_f752b2ce6ed3fe7c83e2d44b82c58513d26f68d0deef8ab949f84e5bc88b0233`,
  `ev_8c83fb2b1df02274e5656190f6335c45fd2cd2a6210654fd1c858dbe01c45f81`,
  `ev_498274d482fa9495c312708a74ad48414b8d78246dbda13ce30678ca7ef772fe`,
  `ev_82d1bc97eb9bb6a623af86b7ef8448a80d3108480a3b95c346605b3dd9d2539a`,
  `ev_1c76fcfdfac83884c8ec6e2b10bd8260dca167b39cb3d4126c9015a69e9c0da1`,
  `ev_3520d1744ee476fb0c496f8b7347f397d2d691508f83b616f6c835d3b15f9f2e`.
- The lifter itself works: `native_function_study(detail:"summary")` on PE entry
  `0x8f1a08` gave 18 blocks / 166 instructions / 34 callees and **0 referenced
  strings**, evidence `ev_deb2a847852bb677495cc382f81c91c3e25629b454a1383adfd3b99bde21b80c`.
  This is a control check only; it is **not** linked to any terrain name. No
  terrain-related function was found, so **no pseudo-C was generated and none is
  claimed**.

# 5. Proven vs UNVERIFIED

**PROVEN (observation of file bytes):**
- The names in §2/§3 exist as printable ASCIIZ strings in `.rsrc` at the listed VAs and
  file offsets; the record framing (`00 10 <tag>`), the flag-byte correction, and the
  VA→offset delta `0x40ee00` are independently confirmed by Craft Anything and a
  read-only Python byte check.
- The table mixes Delphi RTL/VCL units (`System`, `SysUtils`, `Classes`, `Forms`,
  `Mapi`…), OSW engine units (`OSWGeometry`, `OSWTexture`, `OSWOpenGL`…) and project
  units (`XTerrain`, `XTile`, `XMap`…) — 438 records in the parsed window.
- Static code-link searches and raw pointer searches for these names returned zero
  results (ids in §4).

**UNVERIFIED / INFERENCE:**
- Whether each name is a *unit* name, a *class* name, or both: **INFERENCE** from the
  table layout and Delphi naming style only. The tag byte's semantics were not
  recovered.
- All "what it suggests" column entries are **INFERENCE from spelling only**.
- No field layout, method list, vtable address, algorithm, file format or call site
  for any terrain class was recovered. No function was decompiled for these names.
- No conclusion about visual parity, shader source, or external data files follows.
  (`hmap`, `diffusewave`, `texturemap`, `water.dev` remain absent from the executable
  per DECOMP-01 evidence; absence there is not proof of absence in the game.)

# 6. Implications for our terrain port

1. The donor engine genuinely names a heightfield, terrain-data (full and "Lite"),
   tile, tile-season, tile-smooth, terrain-borders, map-cover, map-generator,
   color-table, brush and shader-LOD concepts. **INFERENCE:** our heightfield/tile
   decomposition is structurally aligned with the donor's own vocabulary.
2. The split `XTerrainData` vs `XTerrainDataLite`, `XTileSeason`, `XTileSmooth`,
   `XMapCover` and `XPatternMask`/`XPatternFreqs` suggests the donor separates raw
   height/terrain data from appearance/season/cover layers. **INFERENCE:** our port
   should keep data and visual-layer concerns separable rather than baking one into
   the other.
3. `XColorTable`, `OSWTextureCombiners`, `OSWProcTextures` and `XShaderLOD` suggest
   palette and shader-LOD driven appearance. **INFERENCE:** exact visual parity will
   likely depend on external scripts/shader/palette assets, not on code recoverable
   from this name table.
4. Because **no code references** were found, these names cannot be used as anchors
   for decompilation, and must not be presented as recovered implementations.
5. Remaining route to implementation evidence would require either static analysis
   of the unpacked image or runtime instrumentation. Both were out of scope for this
   audit and were **not performed**; they need explicit consent.

# Handoff

Top 10 terrain names with decoded-name addresses: `XTerrain` `0x95864a`,
`XTerrainDataLite` `0x9587c3`, `XTerrainData` `0x958b76`, `XTerrainBorders` `0x9593b4`,
`XHeightField` `0x958aa3`, `XMap` `0x958ab2`, `XTile` `0x9589e9`, `XWorld` `0x9589e0`,
`XColorTable` `0x958ab9`, `XBrush` `0x9587d6`.
Full name/address/offset inventory is in §3, anchored by `ev_0d268a37…`.
