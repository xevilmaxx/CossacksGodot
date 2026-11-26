---
id: D08
ticket: "TERRAIN-SWARM-2026-11-26 / D08"
title: "Donor tile selection, atlas addressing, smoothing rules, detail bitmaps, bmTransparency and eye-plane texgen"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY
owner_file: docs/terrain_swarm_2026-11-26/reports/D08_tile_select_bin.md
target_used: "C:\\Games\\Cossacks 3\\cossacks.exe, target t_87f0f3c130b0, sha256 87f0f3c130b0… (already active; core_target_open NOT called)"
secondary_target: "C:\\Games\\Cossacks 3\\editor.exe, target t_68474ddde43f, RTTI enum strings only, read-only"
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
scope_guard: "Donor read-only. No donor binary executed, copied or committed. No repo source/shader/config/asset/test/git edit. No Godot runner job. Temp analysis scripts only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\."
---

# D08 — Tile selection → atlas → shader, decoded from the donor

## 0. Executive summary

1. **[D] Tile id space is the season preset index, not a pixel index.** `data/terrain/tiles/terrain.presets:2-125,129-252` defines **124 Summer ids (0..123)** and **124 Winter ids (0..123 in the active Winter set)**; `DefaultIndex = 0` (`grass1`). The resolution chain is `tile id → preset.TileBlock name → tiles.mat Material.Texture.image (.dds)`; `tiles.lib` supplies per-name geometry overrides (`Rows/Cols/TileSize`, `AngleX/AngleZ=25`). The donor ships **112 separate DDS block files**, not one atlas image: `grass1.dds` is **1024×1024, DXT1, 11 mip levels** (header bytes read directly). The 16×8 / 1024² atlas in `variant3d` is **PORT APPROXIMATION** (`tile_index_atlas.manifest.json:labels=APPROX_ATLAS_PACKING`); donor `tsDouble`/`ttExtended` packing is engine-side and **[U] UNVERIFIED**.
2. **[O] Smoothing is fully specified by donor text.** `data/scripts/common.inc/smoothtiles.inc:1-246` loads `data/gen/tilesmooth_scripts.cfg` (1863 lines), parses **22 Items / 118 active weighted lists / 282 tile entries / 86 distinct names**, and runs **3 passes**, each **horizontal sweep then vertical sweep**, in place. `FindRandomTileIndex` uses `rnd = RandomExt*SumProb` with an in-order cumulative test. The separate `data/gen/tilesmooth.cfg` holds **8 unweighted 3–4-name compatibility groups**; it is not the 118-rule set.
3. **[O] The detail-bitmap pass exists only as commented DScript intent.** `data/scripts/common.inc/loadtextureterrainfrombitmap.inc:4-49`: two **320×320 ×24bpp** BMPs, `h < 0.1 → low`, `tex = floor(r*255) div 2`, applied **only where `GetTileIndex(x,y)=0`** and the resolved name is non-empty. Measured R values map to ids `0,1,6,7,77..85` (low) and `1,7,8,9,78..85` (high), i.e. `grass1/2/7/8/9/10` and `test6..test14`.
4. **[D] `bmTransparency` blend math recovered from CODE, not guessed.** `cossacks.exe:0x88fb78` is the cached `glBlendFunc` setter; material-state switch `sub_4ef810` case 1 passes enum indices `dl=6, cl=7`; the factor table at `0x8fb1ac` gives `GL_SRC_ALPHA` (770) and `GL_ONE_MINUS_SRC_ALPHA` (771). The RTTI enum order in `editor.exe` (file offset `0xF9722`) shows `bmOpaque=0, bmTransparency=1, bmAdditive=2, bmAlphaTest50=3, bmAlphaTest100=4, bmModulate=5`, corroborated by cases 3/4 setting `GL_GEQUAL` ref 0.5/1.0. Exact result: `dst.rgb = src.rgb*src.a + dst.rgb*(1-src.a)` with default `GL_FUNC_ADD`. **The alpha mask is a framebuffer crossfade weight, not an albedo multiplier**; the port's single-pass `rgb *= mask` is **PORT APPROXIMATION**.
5. **[O]/[U] Eye-plane texgen equations are exact; runtime plane values are not.** `data/shaders/obj/hf.pvl.sm.vert:25-32` computes `s=dot(realpos, gl_EyePlaneS[0])`, `t=dot(realpos, gl_EyePlaneT[0])`, then `gl_TextureMatrix[0]*…`. Binary `sub_4ec3f0` maps `tmmObjectLinear=1`, `tmmEyeLinear=2`, `tmmEyePlane=7` to `glTexGeni/glTexGenfv` calls with default planes read from `0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4`: **S=(1,0,0,0), T=(0,1,0,0), R=(0,0,1,0), Q=(0,0,0,1)**. Face materials override to `TextureScale=0.125` with eye-linear S/T on X/Z or Y/Z (`reftile.mat:120-169`). Actual per-frame eye planes and texture matrix are **[U] CONFIRMED_UNVERIFIED** after six binary passes.
6. **No donor-parity claim.** Every substitute is labelled; no donor asset was copied into the repo.

## 1. Evidence table

| Ev id | Label | Source (donor path:line / exe address) | Claim |
|---|---|---|---|
| `ev_e742a78dec8f173dfe6e16a07a5d9c340d8b0a1e9bcb73689b74b783e51852eb` | [O] | `data/terrain/tiles/terrain.presets:1-263` | 124 Summer + 124 Winter `TileBlock` names, `DefaultIndex=0`. |
| `ev_d77d8ef5283af0cb3b19494fac2c02bab05c147fd6a6ea7da9f79202198ca829` | [O] | `data/terrain/tiles/tiles.lib:1-909` | 245 sections; `grass1` first; `sand1..4` `TileSize=64, Rows=2, Cols=2`; 72 `vf/vs` entries with `AngleX/AngleZ=25`. |
| shell read (no ev id) | [O] | `data/terrain/tiles/tiles.mat:2-4,142-213,346-360,1000-1019`; `tiles.season:1-4`; `terrain.lib:1-14` | name→`Material.Texture.image`, refkey `normal/verticalfront/verticalside`; `alpha0a/b/c` use `grass1.dds` + `alphanull`; season map Summer/Winter. |
| shell read (no ev id) | [O] | `data/terrain/tiles/textures/grass1.dds` header (0..128) | DDS magic, 1024×1024, DXT1, pitch 524288, **mips=11**. |
| `ev_5290720ccc5de1cd29d83da402582f564ec70e2780554654e3e3e92c2915b53a` | [O] | `data/terrain/ref/reftile.lib:1-13` | `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`; `TileSize=64/Rows=16/Cols=16/AlphaRows=8/AlphaCols=4/AlphaTileSize=64` are **commented out**. |
| `ev_27661ad31d177b3e546ccbb7b676091f73fc4ecc823d410d31334f28fe40959f` | [O] | `data/terrain/ref/reftile.mat:1-170` | `Texture2Name=alpha`, `BlendingMode=bmTransparency`, minfilter `miNearestMipmapLinear`, mag `maNearest`, `tfIsotropic`, `twBoth`; face overrides `alphavert`, scale `0.125`, eye-linear planes. |
| shell read (no ev id) | [O] | `data/terrain/ref/reftilealpha.mat:1-37,110-159,219-268` | `alpha.bmp` / `alphavert.bmp` / `alphanull.bmp` bound with `imagealpha=tiaAlphaFromIntensity`, `textureformat=tfAlpha`, nearest min/mag, `bmTransparency`. |
| `ev_9b3ca2f71167b25e760f247f3f10a3f6b2ec519ef238b64cd7a7199e51bcff46` | [O] | `data/scripts/common.inc/texturemap.inc:1-963` | tile-selection constants, 8×45° sectors, shore/rock/road rules, `_winter` suffixing. |
| `ev_58552bae6226d2c3de4d5eee847ec05c8a1e5260199faaba3f1514d4442baef6` | [O] | `data/scripts/common.inc/smoothtiles.inc:1-246` | exact smoothing algorithm and `SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3)`. |
| `ev_de3fdab7fe79bd91a5d2e46040012bc8d88e00b56cd684b9991d459a8482616a` | [O] | `data/gen/tilesmooth_scripts.cfg:1-1863` | 22 Items, 118 active lists, weights and ordered membership (§4.3 table). |
| `ev_6c695743fac333b983c6f7e411176844cb8f54a484ca73517664625cfb22af51` | [O] | `data/gen/tilesmooth.cfg:1-129` | 8 unweighted compatibility groups (§4.3). |
| `ev_e6f506430c087eef585bfab67b46033ec20d078093d04e6719f072242fbb082d` | [O] | `data/scripts/common.inc/loadtextureterrainfrombitmap.inc:1-49` | detail-bitmap pass, all lines `;`-commented. |
| shell read (no ev id) | [O] | `data/gen/bitmap/ext/tile_lowground.bmp`, `tile_highground.bmp` | 320×320, 24bpp, data @54; R values → ids listed in §4.4. |
| shell read (no ev id) | [O] | `data/terrain/tiles/textures/alpha.bmp`, `alphavert.bmp`, `alphanull.bmp` | alpha 512×256 8bpp palette (data @1070, 254 colors); alphavert 1024×512 24bpp; alphanull BITMAPCOREHEADER 512×256, all data bytes 0. Patch means in §4.5. |
| `ev_64eb217c56f50781fe8dfcea998a4d1ea16b97b00ec9d1ac9ad380cf95cfdee0` | [O] | `data/shaders/obj/hf.pvl.sm.vert:1-50` | eye-plane texgen and lighting varyings. |
| `ev_04c9b397886535cbd2c09ea91d1c9de4bb640d4836cf67d904893a1cca9f969a` | [O] | `data/shaders/obj/hf.pvl.smx3.frag:1-51` | `color.rgb=tex0.rgb`, `color.a=tex1.a`, lighting/shadow/fog, `gl_FragColor=color`. |
| `ev_c419c0083dd0641e84dce6d78845887824dc43cfb6f9dfe637e5d12af30599b8` | [D] | `cossacks.exe:0x88fb78` (study) | cached blend setter, table lookup at `0x8fb1ac`, calls `glBlendFunc`. |
| `ev_b23046977bdcacb7641e754a4470a366ec870b35126afbc2ac0e5351ae65df6b` | [D] | Deep Ghidra `FUN_0088fb78` | same function, named params, `glBlendFunc()`. |
| `ev_5071f34e67c6214d7a00cc21b9e1eec5596477010b3e42b4f2deaf886017cfde` | [O] | `cossacks.exe:0x88fb78` disassembly | push order proves `sfactor=table[dl]`, `dfactor=table[cl]`. |
| shell read (no ev id) | [D] | `cossacks.exe:0x8fb1ac` u32 table | idx `6→770=GL_SRC_ALPHA`, `7→771=GL_ONE_MINUS_SRC_ALPHA` (GL enum values cross-checked against OCCT `OpenGl_GlCore11.hxx`). |
| `ev_1f47eb2f2b1a9a849e526ebdb85e76028c5b1bc63667a039b98ba77b4313fac5` | [O] | `editor.exe` RVA `0xB01D72`, file `0xF9722` | RTTI enum order `bmOpaque/bmTransparency/bmAdditive/bmAlphaTest50/bmAlphaTest100/bmModulate`. |
| shell read (no ev id) | [D] | `cossacks.exe:0x4ef942` jump table, `0x4ef97a-0x4ef995` | case 1 sets blend enum `(6,7)`; cases 3/4 alpha-test refs 0.5/1.0. |
| `ev_da1b30dd125e226e04ee145e537a608fd440a759ec5110791c01df0cd7b7fe45` | [O] | `cossacks.exe:0x88fb34` disassembly | alpha-func setter, table `0x8fb18c`, idx7=`GL_GEQUAL`. |
| `ev_97d7b6610065914af91a1a1c9aeb0d7f944c0a3f24d9cb2c257248eda84100a5` | [D] | Deep Ghidra `FUN_004ec3f0` | texgen switch on mapping mode; cases 1/2/7 build S/T(/R/Q) planes. |
| shell read (no ev id) | [D] | `cossacks.exe:0x4ec451-0x4ec731` disassembly | literal GL enums: mode `0x2500`, object plane `0x2501`, eye plane `0x2502`, object-linear `0x2401`, eye-linear `0x2400`. |
| shell read (no ev id) | [O] | `cossacks.exe:0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4` f32 | default planes S=(1,0,0,0), T=(0,1,0,0), R=(0,0,1,0), Q=(0,0,0,1). |
| `ev_79fc1710f7640c1e8e0e7e177c227c0ba735667ba9f8c4cdc569d11934ab1f9c` | [O] | `cossacks.exe:0x4be364` disassembly | activates `GL_TEXTURE0_ARB` (0x84C1), `glTexGenfv`, restores `GL_TEXTURE1_ARB` (0x84C0) — per-frame plane setter; argument values runtime-owned. |
| `ev_8e59d910a63701954f57fee010a819235ac6357c1d912560434928c289b03df9`, `ev_dfafdccd498f3aaa945519cc268dabd5f7263a78560a33acd7d3be4229f929f8`, `ev_34c38c70d55f95dc30fc77a0f766ae471b8ca68cf06309e0034e3f9bdb47cccc` | [U] | `native_strings_find` / `core_feature_find` / `native_xrefs_list` | no tile-selection API strings or XTileSmooth code xrefs (string only in `.rsrc` @0x959416, 0 refs). |

Findings recorded in Craft Anything: `fnd_22` (id→art chain), `fnd_23` (smoothing), `fnd_24` (detail pass), `fnd_25` (blend math), `fnd_26` (texgen).

## 2. Method and multi-pass log

**Target handling.** `core_session_show`/`core_targets_list` showed `cossacks.exe` already active; I used it **without calling `core_target_open`**. A concurrent worker opened `editor.exe`, so from the blend investigation onward every native call passed `document: "t_87f0f3c130b0"` explicitly. One early `native_name_xrefs_list(glBlendFunc)` returned a result whose subject was `editor.exe` (shared-session race); it was **discarded** and re-run pinned, producing `ev_c4086bd0…`. `editor.exe` was used **only** for RTTI enum-name strings, never as a source of runtime behaviour.

**Text/data passes.** `core_text_read` for all named cfg/inc/mat/lib/shader files; Python/latin-1 or UTF-8 byte parsing for full-file structure counts, BMP/DDS headers, palette and patch luminance. Temp scripts: `%TEMP%\opencode\d08_parse_smooth.py`, `d08_rules_table.py`, `d08_bmp.py` (outside repo).

**Binary passes (owner directive: multiple passes before skipping anything strange/garbled).**

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4+ | Verdict |
|---|---|---|---|---|---|
| Tile selection / `XTileSmooth` / DScript APIs | `native_functions_search` for `Tile`, `Terrain`, `Smooth`, `MapGet`, `RandomExt` → **0 functions**; engine reports `function discovery stopped after 6000000 instructions` (incomplete list) | `native_strings_find` for `MapGetTileIndexByTileBlock`, `SetTileIndex`, `tileblock`, `reftile` on **both** exes → 0 in `cossacks.exe` (`data_sections_only` caveat) | `core_feature_find("XTileSmooth")` → 1 `.rsrc` string, 0 functions/imports; `native_xrefs_list(0x959416)` → 0 references | — | Engine-side selection is not statically anchored; **donor `.inc` text is authoritative**, engine lookups `[U]`. Not silently skipped. |
| `bmTransparency` blend | `native_name_xrefs_list(glBlendFunc)` (pinned) → sole caller `sub_88fb78` | `native_function_study` Deep+clean-room (`ev_c419…`) → cached setter + factor table | `native_function_pseudocode` Deep (`ev_b230…`) confirmed signature `(param_1,param_2,param_3)`; clean-room lifter misread regs (`eax/dl/cl` as locals) — **Deep version accepted**, clean-room kept as cross-check | disassembly (`ev_507…`) + u32 dump of `0x8fb1ac` + RTTI enum in `editor.exe` + `sub_4ef810` jump table + alpha-func table `0x8fb18c` (case refs 0.5/1.0 corroborate enum order) | **[D] accepted**, exact GL factors recovered. |
| Eye-plane / texgen | donor vertex+fragment shader read | `native_name_xrefs_list(glTexGenfv/glTexGeni/glMatrixMode)` → `sub_4ec3f0`, `sub_4be364`, others | Deep pseudocode of `sub_4ec3f0` (`ev_97d7…`) + clean-room study (184 insns, 50 callees) | disassembly literals `0x2500/0x2501/0x2502/0x2400/0x2401`; f32 dump of plane defaults; `sub_4be364` disasm shows per-frame setter with runtime args | texgen **method/defaults `[D]/[O]` accepted**; effective per-frame `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` remain **[U]** (computed pointers, runtime state). |
| Alpha tile→patch index | `alpha.bmp` bytes: 8×4×64² geometry and patch means measured | prior `A08_donor_truth_local.md:94-139`, `A02_alpha_pattern.md:36-46` cross-checked (row order bottom-up explains row reversal) | `native_strings_find` for `AlphaRows`, `TileXOffset`, `bmTransparency` in `cossacks.exe` → 0; `reftile.lib:8-10` values are commented | — | geometry `[O]`, tile→patch rule **[U]**; no silently skipped lead. |

## 3. Findings

### 3.1 Tile-id space and where each id's bitmap comes from

**[O] Id dictionary.** `terrain.presets:2-125` (Summer) and `:129-252` (Winter) each contain 124 ordered `[*].TileBlock` entries with `DefaultIndex = 0`. First ids and notable ones (Summer; same positions in Winter carry `_winter` names except the three alpha ids):

| id | name | material image (`tiles.mat`) | note |
|---:|---|---|---|
| 0 | `grass1` | `textures\grass1.dds` | `DefaultIndex`; also alpha0a/b/c RGB |
| 10 | `ground1` | `ground1.dds` | road family |
| 17–25 | `sand1..sand9` | `sand*.dds` | `sand1..4` have `TileSize=64, Rows=2, Cols=2` |
| 26–34 | `rock1..rock9` | `rock*.dds` | cliff family |
| 35–52 | `rock1vf/vs … rock9vf/vs` | **same** `rockN.dds` | `refkey=verticalfront/side`; `AngleX/AngleZ=25` in `tiles.lib` |
| 53–70 | `sand1f/s … sand9f/s` | same `sandN.dds` | `refkey=normal/normalside` |
| 78–85 | `test7,test8,test9,test10,test11,test12,test13,test14` | `test*.dds` | detail-bitmap targets |
| 86 / 110 / 123 | `alpha0a` / `alpha0b` / `alpha0c` | `grass1.dds` + `Texture2Name=alphanull` (`tiles.mat:346-360`) | zero-alpha crossfade-to-framebuffer tiles |
| 87–98 | `sandrock1..6`, `sandsea1..6` | respective `.dds` | smoothing families |
| 99–109 | `test15..test25` | `test*.dds` | |
| 111–219 / 220–243 | Winter equivalents / `desert1..12` | `*_winter.dds` / `desert*.dds` | season/desert sets |

**[O] Art resolution.** `tiles.mat` is a name→material table: `Material.Name = grass1` → `Material.Texture.image = .\data\terrain\tiles\textures\grass1.dds` (`tiles.mat:2-4`). Face ids reuse the base DDS with a different `refkey` (`tiles.mat:142-213`), so `rock1vf`/`rock1vs` are **the same bitmap with different projection/material**, not new art. `tiles.lib:1-909` has **245** sections (more than 124) because it also lists face/side/desert variants; it is a geometry/override library, while the **preset list is the id dictionary**.

**[O] Art format.** `grass1.dds` header: `DDS `, header size 124, 1024×1024, pitch 524288, DXT1 fourcc, **11 mip levels**. `reftile.mat:24-49` requests `maNearest` mag / `miNearestMipmapLinear` min / `tfIsotropic` / `twBoth`.

**[O] Donor geometry parameters.** `reftile.lib:3-12`: `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`; `TileSize=64`, `Rows=16`, `Cols=16`, `AlphaRows=8`, `AlphaCols=4`, `AlphaTileSize=64` are **commented out**. Their arithmetic is **[U]** (no code found in three passes). `terrain.lib:5-11`: `TextureScale=(1,1,1,1)` and `seasons.Summer=Summer`, `Winter=Winter`.

**[PORT APPROXIMATION] Atlas cell.** The donor does not ship a packed atlas; `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` packs the 124 Summer ids in preset order into a **16×8 grid of 1024² cells** (`cell_xy=(id%16, floor(id/16))`), 121 filled / 3 empty, and explicitly labels itself `APPROX_ATLAS_PACKING`. This is a port choice, not a recovered donor layout.

### 3.2 Tile-id selection in the generator (`texturemap.inc`)

**[O] Constants** (`texturemap.inc:14-38`): `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`, `cDiff1=0.5`, `cDiff2=0.55`, `cAngle=45`, slope gate `len>0.01`, `cTextureTerrain=True`.

**[O] Stage A — shore aspect** (`:433-530`): sample `lh/rh/th/bh` around `realx/realy`; `dirX=lh-rh`, `dirY=th-bh`; normalize when `len>0.01`; `vecangle=VectorAngle(1,0,0,dirX,0,dirY)`, negated if `dirY<0`; for water/shore cells add `180`. Eight 45° sectors (centred at 0,45,…,315), assigned in an if/else chain where later sector tests overwrite earlier ones: `LB→sandsea5`, `RB→sandsea6`, `B→sandsea1`, `L→sandsea6`, `R→sandsea6`, `T→sandsea1`, `RT→sandsea5`, `LT→sandsea6`. Then `if GetSeasonType=2 → name+'_winter'`; `MapGetTileIndexByTileBlock(name)` → `SetTileIndex(x,y,newtex)`.

**[O] Stage B — cliff/edge aspect** (`:557-611`): for map edge or `GetMapCollisionTagInRadius(realx,realy,0,False)>0`, sectors (30–60 RB, 120–150+20 LB, ±45 R, 45–135 B, −135..−45 T, else L) choose `rock7/rock6/rock1/rock3/rock4/rock4`; then overrides `|h|>2.7→rock8`, `>2.4→rock4`, `|h|<0.1→none`; winter suffix as above.

**[O] Stage C — roads** (`:617-646`): where `gMapMask[x,y].broad`, `RandomExt>0.5→ground1`, else `RandomExt>0.25→test2`, else `test3`; winter suffix applied.

**[O] Stage D** (`:648-652`) begins with `var istage; exit;` — everything after is dead code; a later rock/water block at `:900-955` is likewise unreachable. Only the live A/B/C paths above feed the tile map.

**[O] Stage order** (`generatemap.inc:770-798`): `SetRandomExtKey64(randkey0, randkey1)` → `ExecuteState('TextureMap')` → `ExecuteState('SmoothTiles')` → `ExecuteState('LoadTextureTerrainFromBitmap')`. Initial ids are zeroed in `generatemap.inc:266-268` (`SetTileIndex(x,y,0)`), which is why the detail pass tests for id 0.

### 3.3 Smoothing rules: exact syntax, counts and evaluation order

**[O] File syntax.** `tilesmooth_scripts.cfg` is a nested parser tree:

```
TileSmoothLists : struct.begin
  [*] : struct.begin                       // one Item  (22 of them)
    SmoothTiles : struct.begin
      [*] : struct.begin                   // one ordered list (118 active)
        TileNames : struct.begin
          [*] : struct.begin
             TileName = <block name>
             Prob = <float>               // 0 = separator
          struct.end
        struct.end
      struct.end
    struct.end
  struct.end
struct.end
```

Lines beginning `//` are excluded by the parser; several lines contain a *commented* `//Prob = 0.36` followed by an active `Prob = 0.64` — the active value wins (e.g. `tilesmooth_scripts.cfg:1850-1858`).

**[D] Full parse** (Python, this agent): **22 Items** (lines 3, 97, 193, 285, 397, 518, 627, 732, 780, 816, 880, 933, 1027, 1123, 1215, 1327, 1448, 1557, 1662, 1710, 1746, 1810), **118 active lists** (items 10 and 21 are fully commented → 0 lists), **282 tile entries**, **86 distinct names**. Prob histogram: `1.0×122, 0.16×40, 0.25×16, 0.4×14, 0.6×14, 0.5×12, 0.36×10, 0.7×8, 0.3×8, 0×8, 0.2×8, 0.64×6, 0.0028×6, 0.9×4, 0.1×4, 0.28×2`. Items 0–9 are Summer, 11–20 Winter; 10/21 are their empty commented counterparts.

**Ordered lists** (`[name]` = Prob 1; `name:p` otherwise; brackets are list boundaries in file order):

```
ITEM 0  (line 3):    [sandsea1,sandsea2,sandsea3,sandsea4] [sandsea5:0.7,sandsea6:0.3] [rock9:0,rock8:0,rock5:0] [rock1:0.16,rock2:0.16,rock3:0.16,rock6:0.16,rock7:0.16,rock4:0.2]
ITEM 1  (line 97):   [sandsea1,sandsea2,sandsea3,sandsea4] [sandsea5:0.7,sandsea6:0.3] [sandrock1:0.4,sandrock3:0.6] [sandrock4:0.6,sandrock2:0.4] [grass1,grass2,test8] [grass7:0.25,test12:0.25,test13:0.25,test14:0.25]
ITEM 2  (line 193):  [sandsea1,sandsea2,sandsea3,sandsea4] [sandsea5:0.7,sandsea6:0.3] [sandrock1:0.4,sandrock3:0.6] [sandrock4:0.6,sandrock2:0.4] [grass1,grass2,test8] [test7,grass8,test6]
ITEM 3  (line 285):  [sandsea1,sandsea2,sandsea3,sandsea4] [sandsea5:0.7,sandsea6:0.3] [sandrock1:0.4,sandrock3:0.6] [sandrock4:0.6,sandrock2:0.4] [grass1,grass2,test8] [grass9] [test9] [grass3] [grass4:0.9,grass10:0.1]
ITEM 4  (line 397):  [rock1:0.16,rock2:0.16,rock3:0.16,rock6:0.16,rock7:0.16,rock4:0.2] [rock8:0.5,rock5:0.5] [rock9] [grass_ground1:0.64,grass_ground2:0.0028,grass_ground3:0.36] [grass1,grass2,test8] [grass9] [test9] [grass3] [grass4:0.9,grass10:0.1]
ITEM 5  (line 518):  [rock1:0.16,rock2:0.16,rock3:0.16,rock6:0.16,rock7:0.16,rock4:0.2] [rock8:0.5,rock5:0.5] [rock9] [grass_ground1:0.64,grass_ground2:0.0028,grass_ground3:0.36] [grass1,grass2,test8] [test7] [grass8] [test6]
ITEM 6  (line 627):  [rock1:0.16,rock2:0.16,rock3:0.16,rock6:0.16,rock7:0.16,rock4:0.2] [rock8:0.5,rock5:0.5] [rock9] [grass_ground1:0.64,grass_ground2:0.0028,grass_ground3:0.36] [grass1,grass2,test8] [grass7:0.25,test12:0.25,test13:0.25,test14:0.25]
ITEM 7  (line 732):  [rock9,test8:0] [grass5] [grass6]
ITEM 8  (line 780):  [rock9] [grass5] [grass_ground1:0.36,grass_ground2:0.28,grass_ground3:0.36]
ITEM 9  (line 816):  [ground1] [test2] [test1,test3] [test8:0.4,test7:0.6] [grass1,grass2,test8]
ITEM 10 (line 880):  (empty — all lists commented)
ITEM 11 (line 933):  [sandsea1_winter,sandsea2_winter,sandsea3_winter,sandsea4_winter] [sandsea5_winter:0.7,sandsea6_winter:0.3] [rock9_winter:0,rock8_winter:0,rock5_winter:0] [rock1_winter:0.16,rock2_winter:0.16,rock3_winter:0.16,rock6_winter:0.16,rock7_winter:0.16,rock4_winter:0.2]
ITEM 12 (line 1027): [sandsea1_winter..sandsea4_winter] [sandsea5_winter:0.7,sandsea6_winter:0.3] [sandrock1_winter:0.4,sandrock3_winter:0.6] [sandrock4_winter:0.6,sandrock2_winter:0.4] [grass1_winter,grass2_winter,test8_winter] [grass7_winter:0.25,test12_winter:0.25,test13_winter:0.25,test14_winter:0.25]
ITEM 13 (line 1123): [sandsea1_winter..sandsea4_winter] [sandsea5_winter:0.7,sandsea6_winter:0.3] [sandrock1_winter:0.4,sandrock3_winter:0.6] [sandrock4_winter:0.6,sandrock2_winter:0.4] [grass1_winter,grass2_winter,test8_winter] [test7_winter,grass8_winter,test6_winter]
ITEM 14 (line 1215): [sandsea1_winter..sandsea4_winter] [sandsea5_winter:0.7,sandsea6_winter:0.3] [sandrock1_winter:0.4,sandrock3_winter:0.6] [sandrock4_winter:0.6,sandrock2_winter:0.4] [grass1_winter,grass2_winter,test8_winter] [grass9_winter] [test9_winter] [grass3_winter] [grass4_winter:0.9,grass10_winter:0.1]
ITEM 15 (line 1327): [rock1_winter:0.16,rock2_winter:0.16,rock3_winter:0.16,rock6_winter:0.16,rock7_winter:0.16,rock4_winter:0.2] [rock8_winter:0.5,rock5_winter:0.5] [rock9_winter] [grass_ground1_winter:0.64,grass_ground2_winter:0.0028,grass_ground3_winter:0.36] [grass1_winter,grass2_winter,test8_winter] [grass9_winter] [test9_winter] [grass3_winter] [grass4_winter:0.9,grass10_winter:0.1]
ITEM 16 (line 1448): [rock1_winter:0.16,...rock4_winter:0.2] [rock8_winter:0.5,rock5_winter:0.5] [rock9_winter] [grass_ground1_winter:0.64,grass_ground2_winter:0.0028,grass_ground3_winter:0.36] [grass1_winter,grass2_winter,test8_winter] [test7_winter] [grass8_winter] [test6_winter]
ITEM 17 (line 1557): [rock1_winter:0.16,...rock4_winter:0.2] [rock8_winter:0.5,rock5_winter:0.5] [rock9_winter] [grass_ground1_winter:0.64,grass_ground2_winter:0.0028,grass_ground3_winter:0.36] [grass1_winter,grass2_winter,test8_winter] [grass7_winter:0.25,test12_winter:0.25,test13_winter:0.25,test14_winter:0.25]
ITEM 18 (line 1662): [rock9_winter,test8_winter:0] [grass5_winter] [grass6_winter]
ITEM 19 (line 1710): [rock9_winter] [grass5_winter] [grass_ground1_winter:0.36,grass_ground2_winter:0.28,grass_ground3_winter:0.36]
ITEM 20 (line 1746): [ground1_winter] [test2_winter] [test1_winter,test3_winter] [test8_winter:0.4,test7_winter:0.6] [grass1_winter,grass2_winter,test8_winter]
ITEM 21 (line 1810): (empty — all lists commented)
```

**[O] Second cfg.** `data/gen/tilesmooth.cfg:1-129` holds **8** unweighted groups (no `Prob`): `0:[ground1,test1,grass1]`, `1:[ground1,test1,grass2]`, `2..7:[rockN,rock9,grass_ground1,grass1]` for N=1,2,3,4,6,7. This file is **not** read by `smoothtiles.inc` (which reads only `tilesmooth_scripts.cfg`); its consumer is **[U]** (the commented `MapGeneratorSmoothTiles` call at `generatemap.inc:784` is a plausible but unproven link).

**[O] Algorithm, transcribed from `smoothtiles.inc:31-242`:**

```
load tilesmooth_scripts.cfg -> TileSmoothLists
Items[i].SmoothTiles[j].TileCount, .Prob, .TileName, .TileIndex (MapGetTileIndexByTileBlock), .SumProb
atilemap[x,y] = GetTileIndex(x,y) for all cells

FindRandomTileIndex(i,j):                    // item i, list j
   rnd = RandomExt * Items[i].SmoothTiles[j].SumProb
   tmp = 0                                   // [I] DScript local assumed zero-initialised
   for k in 0..TileCount-1:
       prob = Prob[k]
       tmp += prob
       if (prob > 0) and (rnd < tmp) return TileIndex[k]   // NOTE: test uses current prob>0, not rnd-tmp
   return -1

GetNeighbourTiles(t1,t2) -> (out1,out2):
   ilist=-1; mindist=MaxInt; i1=i2=-1; i1ProbZero=i2ProbZero=False
   name1 = MapGetTileBlockByTileIndex(t1); name2 = ...
   for each Item i in file order:
      ind1=ind2=-1; ind1ProbZero=ind2ProbZero=False
      for each list j, each tile k:
         if name == name1: ind1=j; ind1ProbZero=(Prob[k]==0)
         if name == name2: ind2=j; ind2ProbZero=(Prob[k]==0)
      // lines 122-123: rock5/rock2 special case is `ind2ProbZero := ind2ProbZero` — a NO-OP
      if (ind1<>ind2) and (ind1>-1) and (ind2>-1) and (Abs(ind1-ind2)<mindist):
          mindist=round(Abs(ind1-ind2)); i1=ind1; i2=ind2; ilist=i; save ProbZero flags
   if ilist==-1: return (-1,-1)                 // no shared Item -> unchanged
   if |i1-i2|==1 and (not i1ProbZero or not i2ProbZero): return (-1,-1)   // compatible
   if i1-i2==2: return (FindRandomTileIndex(ilist,(i1+i2)/2), -1)
   if i2-i1==2: return (-1, FindRandomTileIndex(ilist,(i1+i2)/2))
   if i1<i2:    return (-1, FindRandomTileIndex(ilist,i1+1))
   else:        return (FindRandomTileIndex(ilist,i2+1), -1)

SmoothTileMap(0,0,w,h,3):
   for pass in 0..2:
      for i=0..w-1: for j=0..h:            // horizontal, in place, reads updated neighbours
          compare (i,j) with (i+1,j); apply out1/out2 if >-1
      for j=0..h-1: for i=0..w:            // vertical, in place
          compare (i,j) with (i,j+1); apply out1/out2 if >-1
write all atilemap[x,y] back with SetTileIndex
```

**Key consequences [D]:** probability **0** acts as a hard separator only via the `|Δ|=1` check and by exclusion from the roulette; `grass_ground2:0.0028` is an intentionally near-zero third state; the `(i1+i2) div 2` midpoint is **list-index** midpoint, not a colour/height blend; ties in `mindist` keep the **first** Item in file order; the huge roulette sums are **not normalised** (`RandomExt*sumProb`, cumulative `tmp`), so all entries in a list are selected in file order with their raw weights; the commented-out zero-prob rewrite block at `smoothtiles.inc:150-160` is **inactive**.

### 3.4 Detail-bitmap pass

**[O] `loadtextureterrainfrombitmap.inc:4-49` (every code line prefixed `;`):**

```
cLowHeight = 0.1
bitmapLow  <- .\data\gen\bitmap\ext\tile_lowground.bmp
bitmapHigh <- .\data\gen\bitmap\ext\tile_highground.bmp
GetBitmapSize(bitmapLow,width,height); _misc_GetMapLeftTopPos(lx,ty)
for y=0..Min(GetMapHeight,height); for x=0..Min(GetMapWidth,width):
    realx=floor(lx+x); realy=floor(ty+y)
    h=GetHeightData(realx,realy)
    bitmap = bitmapLow if h<cLowHeight else bitmapHigh
    GetBitmapPixel(bitmap, Min(x,width-1), Min(y,height-1), fr,fg,fb,fa)
    r=floor(fr*255); tex = r div 2
    if GetTileIndex(x,y)=0:
        tile = MapGetTileBlockByTileIndex(tex)
        if tile<>'' then SetTileIndex(x,y,tex)
```

**[O] Byte check of the two BMPs** (this agent): both are `BM`, **320×320, 24bpp, BI_RGB, data offset 54, stride 960**.

- `tile_lowground.bmp` red-channel distinct values and counts: `0:51517, 158:19787, 156:10849, 2:7598, 166:3531, 170:3530, 160:2678, 168:1380, 14:765, 154:530, 12:156, 164:79` → `tex = r div 2 ∈ {0,1,6,7,77,78,79,80,82,83,84,85}` = Summer ids `grass1,grass2,grass7,grass8,test6,test7,test8,test9,test11,test12,test13,test14`.
- `tile_highground.bmp`: `156:34838, 158:17167, 160:14619, 170:12975, 166:8853, 14:7592, 2:3766, 168:2063, 18:479, 16:48` → `tex ∈ {1,7,8,9,78,79,80,83,84,85}` = `grass2,grass8,grass9,grass10,test7,test8,test9,test12,test13,test14`.
- The author deliberately encodes **tile identity**, not a luminance delta: all selected ids are near-neutral grass/test blocks (consistent with `A08_donor_truth_local.md:66-67`).
- **[U]** Runtime activity: the whole routine is commented out in the shipped `.inc`; it is authoritative *generator intent*, not proven execution. Loop uses `<= Min(...)`, and writes at `(x,y)` rather than `(realx,realy)` — preserve this exact off-by-one/index choice in a faithful port.

### 3.5 Alpha masks and exact `bmTransparency` blend math

**[O] Shader inputs.** `hf.pvl.smx3.frag:12-16`:

```
color.rgb = texture2D(texUnit0, gl_TexCoord[0].xy).rgb;   // DDS block
color.a   = texture2D(texUnit1, gl_TexCoord[1].xy).a;     // alpha atlas intensity
color.xyz = color.xyz*gl_TexCoord[4].xyz + gl_TexCoord[5].xyz;   // ambient+diffuse, then specular
```

`gl_TexCoord[1] = gl_MultiTexCoord1` (`hf.pvl.sm.vert:34`) is **mesh-supplied**; no donor text computes a tile-id→alpha-patch index (three passes, see §2).

**[O/D] Blend state recovered from CODE.** `cossacks.exe:0x4ef942` switches on material byte `[ebx+0x20]` (6 cases via jump table at `0x4ef949`). Case 1 → `0x4ef97a`:

```
0x4ef98e  mov eax,[esi+0x64]   // GL context
0x4ef991  mov cl,7             // destination enum
0x4ef993  mov dl,6             // source enum
0x4ef995  call sub_88fb78      // glBlendFunc setter
```

`sub_88fb78` (`ev_c419…`, `ev_507…`) caches the two bytes at `+0x130/+0x132`, then pushes `table[cl]` and `table[dl]` before `glBlendFunc`. `table = 0x8fb1ac` maps index `6 → 770 = GL_SRC_ALPHA`, `7 → 771 = GL_ONE_MINUS_SRC_ALPHA`. `glBlendEquation` is **not imported**; default `GL_FUNC_ADD` applies. RTTI enum order in `editor.exe` (`0xF9722`): `bmOpaque=0, bmTransparency=1, bmAdditive=2, bmAlphaTest50=3, bmAlphaTest100=4, bmModulate=5`; cases 3/4 of the same switch set `glAlphaFunc(GL_GEQUAL, 0.5/1.0)` (table `0x8fb18c`, idx7=518=`GL_GEQUAL`), independently confirming the enum indexing.

**[D] Exact equation.** With `src` = shaded tile fragment, `dst` = framebuffer:

```
src.a = alphaAtlas(gl_TexCoord[1].xy)              // intensity -> alpha via tiaAlphaFromIntensity
dst.rgb' = src.rgb * src.a + dst.rgb * (1 - src.a)
dst.a'   = src.a*src.a + dst.a*(1-src.a)           // GL default alpha factors, typically unused
```

Therefore the donor alpha atlas is a **per-fragment crossfade against an already-drawn layer**, not a multiply on one tile's albedo. A single Godot `blend_mix` over one opaque pass (the current port) cannot reproduce this; it also explains why dark patches in the port read as black blotches rather than soft transitions. The **number of bmTransparency passes** (how many tile layers are composited per cell) remains **[U] CONFIRMED_UNVERIFIED** (prior `RV_TRN_01` verdict D).

**[O] Mask geometry and pixels.** `reftile.lib:10-12` (commented) declares `AlphaRows=8, AlphaCols=4, AlphaTileSize=64`; `alpha.bmp` is **512×256, 8bpp, 254 palette colours, data @1070** — exactly an 8×4 grid of 64² patches. Measured patch means (bottom-up BMP order; top visual row last):

```
BMP row0: [136.9,210.1,216.4,0.0,152.2,196.7,203.3,0.0]
BMP row1: [45.6,153.5,134.2,210.0,82.8,174.5,143.1,199.9]
BMP row2: [56.5,136.3,157.9,213.5,58.3,157.7,180.1,206.4]
BMP row3: [255.0,52.3,50.5,132.4,255.0,77.7,72.7,154.1]
```

(matches `A02_alpha_pattern.md:39`). `alphanull.bmp` uses a 12-byte BITMAPCOREHEADER, 512×256 8bpp, **all 131074 pixel bytes = 0** → `src.a=0` → tile contributes nothing to `dst` (the `alpha0a/b/c` ids, `tiles.mat:346-360`). `alphavert.bmp` is **1024×512, 24bpp, data @54**; `reftilealpha.mat:110-217` binds it as `tfAlpha`, nearest, `bmTransparency`. `reftile.mat:120-169`: face materials `Texture2Name=alphavert`, `TextureScale=(0.125,0.125,0.125)`, `mappingmode=tmmEyeLinear`, front S=(1,0,0,0)/T=(0,0,1,0), side S=(0,1,0,0)/T=(0,0,1,0).

**[I] Interpretation:** the four BMP rows encode directional edge feathers (top/bottom/left/right) with organic interior lobes; the constant-255/constant-0 patches are deliberate "full" / "none" sentinels. The **exact tile-id+direction → patch** rule is **[U]**; the port's `dir=id%4; variant=(id/4)%4; half=(id/16)%2; opposite=(id/64)%2` mapping is **PORT APPROXIMATION** inherited from `DALPHA-02`.

### 3.6 Eye-plane UV and tiling scale

**[O] Vertex shader** (`hf.pvl.sm.vert:8-34`):

```
realpos = gl_ModelViewMatrix * gl_Vertex;         // EYE space
if (texGen == 0) gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
else {
    gl_TexCoord[0].s = dot(realpos, gl_EyePlaneS[0]);
    gl_TexCoord[0].t = dot(realpos, gl_EyePlaneT[0]);
    gl_TexCoord[0]   = gl_TextureMatrix[0] * gl_TexCoord[0];
}
gl_TexCoord[1] = gl_MultiTexCoord1;               // alpha patch UV, mesh supplied
gl_FogFragCoord source: abs(realpos.z) on ATI else length(realpos)
```

`shaders.lib:15-51` binds this `HeightField` shader with `texGen = true`, `texUnit0 → unit 0`, `texUnit1 → unit 1`.

**[D] Binary texgen state machine** (`cossacks.exe:0x4ec3f0`, `ev_97d7…` + disassembly). `mappingmode` enum from `editor.exe` RTTI (file `0xF8B56`): `0=tmmUser, 1=tmmObjectLinear, 2=tmmEyeLinear, 3=tmmSphere, 4=tmmCubeMapReflection, 5=tmmCubeMapNormal, 6=tmmCubeMapLight0, 7=tmmEyePlane, 8=tmmCubeMapCamera`. Cases:

| value | name | calls | planes |
|---:|---|---|---|
| 1 | `tmmObjectLinear` | `glTexGeni(GL_S/T, GL_TEXTURE_GEN_MODE, 0x2401=GL_OBJECT_LINEAR)`; `glTexGenfv(GL_S/T, 0x2501=GL_OBJECT_PLANE, …)`; enable `GL_TEXTURE_GEN_S/T` | S from `0x8fc1b8`, T from `0x8fc030` |
| 2 | `tmmEyeLinear` | same but mode `0x2400=GL_EYE_LINEAR`; plane pname still `GL_OBJECT_PLANE` (GL transforms it to eye space at call time) | same two defaults |
| 7 | `tmmEyePlane` | mode `GL_OBJECT_LINEAR` on S/T/R/Q; `glTexGenfv(GL_S/T/R/Q, 0x2501, …)`; enable four gens | S,T,R,Q defaults |
| 0 | `tmmUser` (ground `reftile.mat`) | **no texgen calls here** | shader's `texGen=true` still evaluates `gl_EyePlaneS/T[0]` |

**[O] Default plane constants (f32 in `cossacks.exe`)**: `0x8f4aa4 = (1,0,0,0)`, `0x8f4ab4 = (0,1,0,0)`, `0x8f4ac4 = (0,0,1,0)`, `0x8f4ad4 = (0,0,0,1)`; they are fetched lazily by `sub_4ec2a0/2e0/320/360` into object fields `+0x38/+0x3c/+0x40/+0x44`. `sub_4be364` (`ev_79fc…`) switches to texture unit 0 (`0x84C1`), calls `glTexGenfv` with a caller-supplied plane, then restores unit 1 (`0x84C0`) — the effective per-frame plane is computed at runtime and is **[U]**.

**[O] Scale constants.** `dmscript.global:170-173`: `gc_pixels_to_meter=26.6666666`, `gc_meters_to_tile=2`, `gc_pixels_to_tile=53.3333333`, `gc_tiles_to_pixels=0.01875`. `terrain.lib:5-9` `TextureScale=(1,1,1,1)`; `reftile.mat:12-17` normal tile `TextureScale=(1,1,1)`; face override `0.125`. **No donor literal equivalent to the port's shader `uv_repeat=(0.5,0.5)` was found**; the port value is derived from `gc_meters_to_tile=2` and is **PORT APPROXIMATION** (`A01_shader_tiling.md:50`, `A06_filtering_aliasing.md:57`). `TileXOffset=0.1`, `TileYOffset=0.2` are active donor values whose arithmetic is **[U]**.

## 4. Stage-ordered pipeline (donor, with labels)

| # | Stage | Exact operation / constants | Label / evidence |
|---:|---|---|---|
| 1 | Reset ids | `SetTileIndex(x,y,0)` over the map | [O] `generatemap.inc:266-268` |
| 2 | Seed RNG | `SetRandomExtKey64(randkey0,randkey1)` before `TextureMap` | [O] `generatemap.inc:774` |
| 3 | Base tile selection | shore aspect 8×45°, edge/cliff aspect, roads; thresholds `2.96/-0.25/-0.1/0.5/0.55/2.7/2.4`, road odds `0.5/0.25`; winter suffix | [O] `texturemap.inc:415-646` |
| 4 | Smoothing | load 22×118 weighted lists; 3 passes H then V; roulette `RandomExt*sumProb`; Δ1 compatible, Δ2 midpoint, >2 step one list | [O] `smoothtiles.inc`, `tilesmooth_scripts.cfg` |
| 5 | Detail bitmap | 320×320 24bpp, `h<0.1→low`, `tex=floor(r*255) div 2`, only where id==0 | [O text / U runtime] `loadtextureterrainfrombitmap.inc` |
| 6 | Tile→art binding | id → `terrain.presets` name → `tiles.mat` DDS (1024² DXT1, 11 mips); face ids reuse base DDS with `vf/vs` refkey | [O] presets/tiles.lib/tiles.mat; atlas packing **PORT APPROX** |
| 7 | Vertex texgen | eye-space `realpos`; `dot(realpos, gl_EyePlaneS/T[0])`; `gl_TextureMatrix[0]`; alpha uv = `gl_MultiTexCoord1` | [O] shader; plane values **[U]** |
| 8 | Fragment | `rgb=tex0.rgb`, `a=tex1.a`; Blinn–Phong `rgb*ambient+diffuse+specular`; 3/9-tap PCF; fog; `gl_FragColor` | [O] `hf.pvl.sm*.frag`, `shaders.lib` |
| 9 | Blend | `bmTransparency` → `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`, default FUNC_ADD → crossfade to framebuffer | [D] `cossacks.exe:0x4ef995/0x88fb78` |

## 5. Implications for the port

1. **Build the id dictionary from `terrain.presets`, not from `tiles.lib` section order** (the two orders differ at ids 10–17 and elsewhere). Keep both Summer and Winter sets; the id is stable across seasons while the block name changes. `alpha0a/b/c` are ids 86/110/123 in **both** sets.
2. **Ship derived art, not donor binaries.** Convert the 112 DDS files by name through `tiles.mat`; reuse one DDS for `vf/vs`/`f/s` ids. Any atlas layout is explicitly **PORT APPROXIMATION** until donor packing is recovered; do not present a 16×8 cell lookup as donor truth.
3. **Reimplement smoothing verbatim**: preserve 22-item order, raw (unnormalised) weights, cumulative test `(prob>0)&&(rnd<tmp)`, zero-prob separators, the `rock5/rock2` no-op, first-item tie-break, and the in-place H-then-V sweep repeated 3 times. Reordering items or renormalising probabilities changes output and the RNG stream (D02 owns the stream contract).
4. **Do not multiply the alpha mask into albedo.** To approximate `bmTransparency`, render a base layer then a second alpha-weighted layer with `blend_mix` (or equivalent) so `src.a` crossfades to the framebuffer. Until that exists, any `mask_to_alpha` experiment is a **PORT APPROXIMATION**; keep `alpha0a/b/c` as explicit zero-coverage ids (`alphanull`).
5. **Detail pass is identity-based.** If enabled, derive ids from BMP red channels, not from a luminance overlay; restrict to id 0; preserve the commented routine's exact bounds/selection.
6. **Eye-plane UV remains an approximation.** A Godot world-XZ `fract(uv*0.5)` projection is not donor eye-space texgen; label it and do not invent plane constants. Face materials need the separate `alphavert` projection (scale `0.125`, S/T on X/Z or Y/Z) rather than the ground mask path.
7. **No synthetic noise/dither** (charter guardrail): the donor produces organic boundaries through the 118 weighted lists and authored alpha patches, not a colour field.

## 6. Risks

- **Wrong id dictionary** (`tiles.lib` vs `terrain.presets`) silently shifts every tile by up to several ids.
- **RNG divergence**: the roulette consumes `RandomExt` in list order; any extra call or normalisation desynchronises later generation (seed replay contract).
- **Probability edge cases**: `0.0028` must survive float parsing; `Prob=0` entries must remain in the list for the compatibility test but never be selected.
- **In-place sweep order**: horizontal edits affect the immediately following vertical pass and the next pass; a double-buffer implementation is **not** equivalent.
- **Alpha semantics**: folding `src.a` into RGB produces black blotches and cannot reproduce feathered transitions; pass count is still open.
- **Runtime-vs-text gap**: `texturemap.inc`, `smoothtiles.inc` and the detail pass are all commented-out DScript. They are authoritative *authored intent*; actual runtime execution was not observed (no donor binary run, by rule).
- **Shared Craft Anything session**: another worker changed the active target mid-investigation; all cited binary results were re-run with an explicit `document` id.

## 7. UNVERIFIED register (with passes attempted)

1. **Runtime tile-selection implementation inside `cossacks.exe`** — passes: `native_functions_search` (0, discovery 6M-instruction cap), `native_strings_find` both exes (0 DScript API names), `core_feature_find`/xrefs on `XTileSmooth` (0 refs). Donor `.inc` text accepted instead.
2. **`MapGetTileIndexByTileBlock` / `SetTileIndex` semantics and 0-based indexing proof** — same three passes; **[U]**.
3. **`tsDouble` / `ttExtended` / `TileXOffset=0.1` / `TileYOffset=0.2` arithmetic and donor atlas packing** — passes: `reftile.lib` read, binary string search (0), xrefs from face-material functions not resolved to these constants; **[U]**.
4. **Tile-id + boundary-direction → alpha patch (u,v)** — passes: alpha BMP geometry/means measured, prior reports cross-checked, donor string/code search (0 matchers); **[U]**. Port mapping **PORT APPROX**.
5. **`bmTransparency` layer/pass count and draw order** — passes: blend setter + enum + factor table recovered, but no compositing loop recovered; **[U] CONFIRMED_UNVERIFIED**.
6. **Effective `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` at draw time** — passes: shader text, `glTexGen*` xrefs, Deep pseudocode, disassembly literals, default plane floats, `sub_4be364` per-frame setter (runtime args through computed pointer); **[U] CONFIRMED_UNVERIFIED**.
7. **Runtime activity of the commented generator/smoothing/detail scripts** — read-only rule; no donor execution permitted; **[U]**.
8. **Face `vf/vs` promotion rule and how `AngleX/AngleZ=25` is applied** — donor names/values are [O], promotion code not found; **[U]**.
9. **`tilesmooth.cfg` consumer** — 8 groups [O], only `tilesmooth_scripts.cfg` is read by `smoothtiles.inc`; **[U]**.
10. **Visual parity** — no donor GPU A/B frame; every visual consequence here is structural, not proven.

## 8. Open questions

- Does the engine compose more than one `bmTransparency` tile layer per cell at seams, and in what order relative to depth? (D06 / A05 capture needed.)
- Are `gl_EyePlaneS/T[0]` set once per camera or per material/draw call, and is `gl_TextureMatrix[0]` identity for ground? (`sub_4be364` callers via `sub_4bebc8` function pointer table are the next binary lead.)
- Which module consumes `tilesmooth.cfg` (8 unweighted groups) — a built-in generator path or editor-only preview?
- Can `tsDouble`/`ttExtended` be recovered from the packed `.bind` resources (prior work reports entropy 7.96) rather than CODE?
- Does the detail pass run in shipped skirmish generation, or only when a specific generation flag/campaign path is active?
- Exact season switch binding: does Winter reuse the same numeric ids with a different preset set (assumed [D] from `terrain.lib` + two presets), or does the engine offset ids by 124? No direct evidence found.

## 9. Bottom line

The donor's tile path is **discrete ids → authored weighted smoothing → identity-based detail bitmaps → full-resolution DDS art with eye-plane texgen → alpha-atlas crossfade via `glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)`**. I recovered the exact id dictionary chain, all 118 weighted rules and their evaluation order, both detail BMP formats/value sets, the exact blend factors from CODE, and the texgen mode/plane defaults. What remains genuinely unknown is engine-side atlas packing, the alpha patch selector, the compositing pass count, and the runtime plane/matrix values — all registered as **[U]** with the passes attempted. **No donor visual parity is claimed.**

*End of D08. Files written: this report only. Temp analysis scripts live outside the repo. No donor file executed, copied or committed; no source/shader/config/test/git/Godot state changed.*
