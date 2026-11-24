---
id: DECOMP-01
title: Craft Anything decompilation pass on the Cossacks 3 donor binaries
area: donor / decompilation / terrain research
owner: coordinator
date: 2026-11-24
status: INITIAL PASS DONE — deep dives delegated
tools: Craft Anything 0.6.1, native toolset enabled, Deep mode, clean_room=false
---

# What was actually run

Until this pass, donor scanning was direct read-only text extraction
(Python bytes/latin-1 on donor script/config files). At the user's suggestion I
enabled Craft Anything's `native` toolset and ran a static triage/overview on
the donor executables. **No donor binary was copied into the repository, and no
game process was launched or unpacked.** All operations were read-only.

## Targets and their locations

| Target | Absolute path | Size | SHA-256 / evidence |
|---|---|---|---|
| Game executable | `C:\Games\Cossacks 3\cossacks.exe` | 5,768,048 B | `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`; triage `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` |
| Editor | `C:\Games\Cossacks 3\editor.exe` | 7,874,416 B | triage `ev_2544b87d85fe54c4eb886af829754548105a51a175e5c7f0f8c5fbe8eb0cc67c` |
| Config tool | `C:\Games\Cossacks 3\config.exe` | 4,645,744 B | triage `ev_9e39e5c8ef1bc8256794bb3db45b9ac3b15655428e004b2f508437f6d7c58ee1` |

`cossacks.exe` was opened as the active target with id `t_87f0f3c130b0`.

# What Craft Anything found (and where)

## 1. Binary identity and packing — `ev_e7533ff3…`, `ev_60b49743…`

- PE (Windows), **x86 32-bit**, entry point `0x8f1a08`, section `.bind`.
- Imports: `d3d9.dll`, `opengl32.dll`, `glu32.dll`, `winmm.dll`, `wsock32.dll`,
  `wininet.dll` among 18 libraries — consistent with a Direct3D/OpenGL RTS.
- Toolchain hint: **Delphi / C++Builder** (weak, marker-based).
- Packer hint: section `.bind` entropy **7.96 bits/byte** (weak heuristic) —
  i.e. the real code may be compressed/encrypted until run time.
- Symbols are **stripped**; most functions get generated `sub_…` names.
- Overview counted **18,918 functions, 12,073 strings, 746 imports**, but function
  discovery **stopped at 6,000,000 instructions**, left **1,238 indirect jumps
  unresolved**, and explicitly warns that absence of a function is not proof.
  Evidence `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4`.
- `editor.exe` (entropy 7.96) and `config.exe` (7.97) show the same packing hint.

## 2. Terrain-related strings — `ev_c2b1eeee…`, `ev_fbedd832…`

Literal search in `cossacks.exe` found exactly four `terrain`-matching strings,
all in the `.rsrc` section:

| Address | String |
|---|---|
| `0x958649` | `EXTerrain` |
| `0x9587c3` | `XTerrainDataLite` |
| `0x958b75` | `sXTerrainData` |
| `0x9593b3` | `<XTerrainBorders` |

`hmap`, `diffusewave`, `texturemap`, `generatemap` and `water.dev` produced
**0 matches**; this is expected because those names live in external text data
files (`data/**`), not in the executable. Absence in the binary is **not** proof
of absence in the game. Evidence: `ev_1de8519d…`, `ev_d4f23220…`,
`ev_9e42e02b…`, `ev_a9414ccc…`, `ev_19016788…`.

## 3. String → code linking failed — `ev_b218360c…`

`core_feature_find("XTerrainData")` returned the two strings but **0 functions,
0 imports, 0 code references**. That is consistent with (a) the names being
Delphi RTTI/resource metadata rather than live string literals, (b) packing,
and/or (c) the 1,238 unresolved indirect jumps. No function dossier was produced.

## 4. VA → file offset and the Delphi class/unit table — `ev_d84ea449…`

`0x9587c3` maps to file offset `0x5499c3` (5,544,387) in `.rsrc`.
A read-only byte window around that offset (Python latin-1, ±900 B) shows a
**Delphi unit/class name table**, including names highly relevant to terrain:

`OSWGeometry`, `OSWVectorTypes`, `OSWUtils`, `EXTerrain`, `XRenderPool`,
`LXShaderLOD`, `OSWSerializer`, `OSWTexture`, `OSWTextureImageEditors`,
`OSWOpenGL`, `OSWGraphicsFormats`, `XTerrainDataLite`, `XBrush`, `XProperty`,
`XGameObject`, `XWorld`, `XTile`, `XMaterialLibraryInterface`,
`XCollisionMask`, `HXHeightField`, `XMap`, `XColorTable`, `XLightShader`,
`XShadowMap`, `XPHDR`, … plus Indy networking units.

This is an **observation about metadata**, not a decompiled implementation. It
nevertheless confirms the donor engine has explicit `HeightField`, `Tile`,
`TerrainDataLite`, `ColorTable`, `Map`, `Brush`, `MaterialLibrary` and shader
objects — so our heightfield direction is structurally plausible, while the
*appearance* logic lives in external scripts/shaders that Craft Anything string
search cannot see in the executable.

# Limits and what was NOT done

- No function was successfully decompiled to pseudo-C. `core_feature_find`
  found no code references, and the packing/pointer issues explain why.
- No runtime unpacking, sandbox execution, memory dump or Frida instrumentation
  was attempted — those would run donor code and need explicit user consent.
- No donor binary or extracted bytes were added to the repository.
- No visual parity claim results from this pass.

# Handoff

See `DECOMP_02_*`…`DECOMP_06_*` for delegated deep dives. Every finding there
must cite an evidence id or an exact file offset/address; anything unreadable
stays `UNVERIFIED`.
