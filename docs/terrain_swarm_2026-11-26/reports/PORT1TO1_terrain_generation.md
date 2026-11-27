---
id: PORT1TO1-terrain-generation
ticket: "TERRAIN-SWARM-2026-11-26 / NO-APPROXIMATION donor port / worker PORT1TO1-GEN"
title: "Complete 1:1 Cossacks 3 terrain-generation specification — donor truth and exact port diff"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_REPORT__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_generation.md
targets:
  - "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (PRIMARY)"
  - "t_68474ddde43f — C:\\Games\\Cossacks 3\\editor.exe, 7,874,416 B, sha256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab (CROSS-CHECK)"
labels: [O, D, U, "PORT APPROXIMATION"]
scope_guard: "Donor READ ONLY; no donor binary executed or copied. No repo code/asset/config/Godot/git edit. Exactly one repo file written: this report. Global active target was restored to t_87f0f3c130b0 after opening editor.exe; every analysis call pinned `document`."
parity_claim: false
---

# PORT1TO1_terrain_generation — implementation bible

## 0. How to read this document

- **[O]** = observed donor bytes / donor text line / Ghidra instruction re-read in this ticket, or carried verbatim from a cited prior report with its evidence id.
- **[D]** = deterministic arithmetic or control-flow consequence of [O].
- **[U]** = UNVERIFIED — do not implement as fact; exact functions/addresses and what was tried are recorded.
- **PORT APPROXIMATION** = what `variant3d/scripts/terrain_donor_gen.gd` / `terrain_donor_inputs.gd` do instead. These are divergences, not equivalence.
- **No donor GPU A/B frame exists. No parity claim is made anywhere in this document.**

Donor text citations use the convention `D1`=`dogenerate.inc`, `D2`=`generatemap.inc`, `D3`=`initmapgen.inc`, `D4`=`texturemap.inc`, `D5`=`smoothtiles.inc`, `D6`=`smoothforestborders.inc`, `D7`=`postprocess.inc`, `D8`=`generator.cfg`, `D9`=`misc.script`; all under `C:\Games\Cossacks 3\data\scripts\common.inc\` except D8 (`data\game\var\`) and D9 (`data\scripts\lib\`). Line numbers are **1-based as read**; `core_text_read` offsets in this ticket are 0-based and are noted where used. Every donor `.inc`/`.script` line carries the literal `[*] = ;` prefix: the text is [O], its **runtime activation is [U]**.

Starting points re-read, NOT treated as final answers: `DEC_LANDSCAPE_hills_water.md`, `DEC_LANDSCAPE_item_placement.md`, `DEC_DEEP_corner_tags.md`, `DEC_DEEP_placement_755f30.md`, `D03`, `D05`, `D07`, `F04`, `F08`, `X03`, `X28`, `spec/03`–`spec/10`, `terrain_donor_gen.gd`, `terrain_donor_inputs.gd`.

### 0.1 Fresh evidence recorded this ticket (all pinned)

| Evidence id | Target | What it establishes |
|---|---|---|
| `ev_9c9f2b2ae714c469109e43629c05501763c8236c636cf2244f04acdf0e122625` | cossacks | 192 bytes at `0x8326b8` — complete setter loop (prologue, two `0x50fba0` bounds calls, corner store, RNG call, variant store, `0x83276c` notify, 2×2 loops, `ret 4`), file offset `0x4308c0` |
| `ev_1448daf1ad44f13b0a25cc51de466337042c1a6d16bb11ae5a76cbe5c1f39439` | cossacks | Ghidra `FUN_0082ec5c` — 24-byte getter, 6 dwords, stride `0x18`, OOB default `PTR_008fc33c` |
| `ev_f80b566f65384e901fc3f691eead991c72db8812a14a9b375588b4af935ce52e` | cossacks | `sub_82ec5c` 80 B / 7 blocks; `ev_4e3f7f49…` 10 direct callers |
| `ev_65baa8fc53d8e99d98611ccc5c39209946e391722b372f9fc549686a8cb18db7` | cossacks | Ghidra `FUN_00830818` — 13-byte render override, `param_3*0xd+8`, `0x80` gate, 3×3 signed scan, `0xffffffff` |
| `ev_666ed368e2268cd1543b6392308fe30332edaad273c6f80de284c21f78a97539` | cossacks | `sub_830818` 207 B / 15 blocks; `ev_df537d1c…` `sub_83276c` 23 B / 3 blocks |
| `ev_53d609561593da8b01ac1d8c23e4c7776d24665f901dba2bef2dfb5283705734` | cossacks | 320 bytes at `0x8305a0` — 24-byte write `ecx=0x18` at `+0x14`, 13-byte write `ecx=0x0d` at `+0x20`, `mov [eax+0xc],0` |
| `ev_f3f3421b9fe10d1c80f766b3daccb0738270e2b7fb78ffb7dc0c88c6612f1bca` | cossacks | 96 bytes at `0x8302b0` — symmetric read, `ff 53 0c` / `+0x14` / `+0x20` |
| `ev_497e682213b1bc4c26dae28110be65ca90442247a5f79010f00cb159c1edea67` | cossacks | 16 bytes at `0x8fc33c` — default-record pointer table, first entry `0x008f6164` |
| `ev_7a6055152b97b88cc783a4108c651e1bd1ee8e8302554b28c91009b897f286f6` | cossacks | 24 bytes at `0x8f6164` = `00*8 \| f32(1.0)×4` (record24 default) |
| `ev_2f7258e1a51ff16ee58824152380109b3d2f8322defd8e9742f937acb2c1aae7`, `ev_b9a8a9c21e0af7a8ede79f29e69a91c04a0bd5ed6cee2bfdc29518c04059df90`, `ev_73440e5e…` | cossacks | 32/13 bytes at `0x8fab6c` — **correction**: record13 default = `00*10 FF 00 00` |
| `ev_bde23e2d0d27f183b0f5a3a80ee13ce26048370767b85005b3a48b8cb1d5ebdf` | cossacks | 8 bytes at `0x8f2008` = `00 00 00 00 02 8d 40 00` (Delphi RNG state slot, image 0) |
| `ev_be530cd5c928b32e48735dcd2a1e93c5cef0d31b9cbc71efce07711083d500eb` | cossacks | `sub_403a0c` 15 discovered callers (the undiscovered `0x8326b8` site is absent) |
| `ev_53371d3950b998a56bcb88350b3657bac8a05d46e487f58b194e8754aef1bd06` | editor | `sub_8c5b78` = 25,175 B / 234 blocks / 6,751 insns / 662 calls — structural mirror of cossacks `sub_755f30` |
| `ev_ac3dca236a0645096df7fb8011c0154681fe29b9847309d7fa71000d8b57cf7d`, `ev_9aaf1b17…`, `ev_ade0f2c6…`, `ev_84a65f72…` | editor | record24 default at `0xa28be0` (`00*8 + f32(1.0)×4`), 7 relocated copies; `SetTileIndex` string 0 hits (data-sections only); cossacks-specific RNG global pattern 0 hits (relocation) |
| `ev_e59bcd9b345f182cc63b77297d95e1f27b3e5e028b7e0c66c9f2801e5cc4fb33` | cossacks text | `misc.script:3686–3731` — **uniform centred placement draw** `x=floor(x0+RandomExt*mapwidth)`, `y=floor(y0+RandomExt*mapheight)` |
| `ev_b513bbf7c99cf666661bf993155f7be235aac48043057577cbf4afd787549499`, `ev_11a953b2ee853461d830cf9466ee9e378eaabd265c24b466a69d8748e8eab185` | cossacks text | `generatemap.inc:797–854` — whole water/bsmooth/broad/collision pre-mark is under `if (cPlaceFreeForests) and (not bRandomMap)` (editor-only) |
| `ev_be93fd30…`, `ev_e5fcc12f…`, `ev_10cd66ca…`, `ev_b443c8e3…` | cossacks text | `generatemap.inc` constants, height loop, smoothing chain, water-field `tx/tz/bx/bz` |
| `ev_2e0c8614…`, `ev_4f566666…`, `ev_d4986b9b…`, `ev_cd093212…`, `ev_60ef364f…`, `ev_6c62fa55…`, `ev_70f757d0…`, `ev_36c421b2…`, `ev_b239e088…` | cossacks text | `dogenerate.inc` all 11 reseed sites + 12-stage call order independently re-read |
| `ev_8087656e4a70ca5bca1bc0a6e121d8919b8b2b908a595536c3efefe86811c54e` | cossacks text | `tilesmooth_scripts.cfg:1–120` — exact live probabilities |

### 0.2 Multi-pass discipline for strange decompiles

Per owner rule, ≤5 passes per oddity. What was tried:

1. **High-VA setter/serializer functions undiscovered** (`0x8326b8`, `0x8302b0`, `0x8305a0`, `0x830754`, `0x830d8c`): pass 1 `native_function_find` → "not inside any discovered function"; pass 2 raw `native_bytes_show` → clean prologue/loops; pass 3 `native_instruction_show` stepping each critical address → exact mnemonics; pass 4 `native_function_callers_list` on the *discovered* helpers (`0x82ec5c`, `0x403a0c`) → fan-out census; pass 5 editor.exe cross-check. **Accepted as [O] from bytes/instructions**; the discovery failure is a tool limitation, not absence.
2. **Record13 default disagreement** (prior `DEC_DEEP_corner_tags` said `00*10 FF FF 00`): pass 1 13-byte read, pass 2 32-byte read to see the following structure boundary, pass 3 `native_data_show` type check → prior doc is **wrong at +11**. Corrected [O] above.
3. **Editor mirror**: pass 1 `native_strings_find` `SetTileIndex` → 0 (data-sections only), pass 2 `native_bytes_find` for `00 00 80 3f ×4` → 7 relocated DATA hits, pass 3 `native_function_show 0x8c5b78` → identical 234/6751/662 shape, pass 4 48-byte read of the editor record24 default. Shared schema accepted [O]; exact editor setter VA stays [U] (no string xref).
4. **Apparent contradiction about the `generatemap.inc:818` pre-mark** (prior D07/X03 said "editor-only", DEC_LANDSCAPE_item_placement cited it as generic): pass 1 read `generatemap.inc:811–854`, pass 2 read `:797–814` to find the enclosing guard → resolved: the **whole block** is inside `if (cPlaceFreeForests) and (not bRandomMap)`. D07/X03 are correct; the generic-premark reading is refuted for skirmish.
5. **`_misc_SetupPatternsByType` draw form** (port uses a 25-cell lattice): pass 1 X03 §3.13 summary, pass 2 verbatim `misc.script:3686–3731`, pass 3 cross-check with D07 §3.7 → uniform centred draw confirmed [O].

---

## A. Exact stage order from process start to finished map (task item 1)

### A.1 Pre-`DoGenerate` (D3, `initmapgen.inc`) [O]

| # | Stage | Donor lines | RNG site | Stream |
|---|---|---|---|---|
| 0a | `CreatePlayers()` — fill 8 game players + `_player_AddServicePlayers` (neutral env/nature player) | D3:4–19 | — | — |
| 0b | `gRecordGeneratorVersion := gDataVersion` (fresh game) or `ParserGetIntValueByKeyByHandle(pGen,'ver')` (record/replay) | D3:57, :72 | — | — |
| 0c | `SetRandomKey(gMap.settings.gen.randkey1)` | D3:99 | **reseed #1** | RandomExt (`SetRandomKey`) |
| 0d | `SetRandomKey(gMap.settings.gen.randkey1)` | D3:146 | **reseed #2** | RandomExt |
| 0e | `ExecuteState('DoGenerate')` | D3:232 | — | inherits state from #2 |

### A.2 `DoGenerate` — canonical 12 stages [O]

Fresh re-read of D1 confirms the order at D1:1530–2100 (evidence ids in §0.1). The precise sequence and which RNG site/stream governs each stage:

| # | Stage | Donor line(s) | Reseed consumed at stage entry | RNG draws in stage | Output |
|---|---|---|---|---|---|
| 1 | Clear `gPatternMask` (fixed `cMapSize=640`), reset pattern map, destroy player objects, `MapDrawCollision(0,0,0,r*2-2,False)` with `r=(H div 2)-1` | D1:444–481 | inherits D3:146 | none | empty mask/objects/collision |
| 2 | `SetupTiledPatterns('tiles')` / `('desert_tiles')`: `cSize=25`, `wcount=floor(W/25)`, `hcount=floor(H/25)`, loops `0..count` **inclusive**, centre `round(x*25+12-W/2-1)` (Y likewise), `_misc_CheckStandPattern(...,doStand=True,angle=0)`, `PatternIncreaseFreq`; dead `SetupTiles()` at :499–519 / :1593 | D1:499–519(dead), :1330–1359, :1530–1536 | inherits D3:146 | one name draw + (on success) one damping update per cell; no position draw (grid) | base tile stamps + occupancy |
| 3 | **Reseed** `SetRandomKey(randkey1)` | D1:1538 | **reseed #3** | — | — |
| 4 | Settings: `relieftype`, `terraintype` (random `floor(RandomExt*6)` if `v<91`, else `*gc_MaxTerrainTypeCount`), `minesdensity>2 → floor(RandomExt*3)`, path→`StringRegister0`, `ExecuteState('GenerateMap')` | D1:1542–1565, :1586–1590 | inherits #3 | 0–2 draws (conditional) | settings |
| 5 | **`GenerateMap`** (D2) — see A.3 | D2:139–798 | — | — | height/tiles/water/collision |
| 6 | Shore exclusion: for unoccupied cell, `height<-0.1` → `gPatternMask=True` | D1:1568–1581 | inherits #3 | none | shore ban |
| 7 | Starts: `foreststype:=floor(RandomExt*3); foreststype:=0` at D1:5–6 (draw actually consumed in stage 0 init in D3 scope); `_misc_FillPatternMaskMapBorder(3)` at :1613; `RandomStartingPoints(spcount,minesdensity)` at :1615 with internal reseeds at :1100 (v<61), :1161 (teams), :1177 (v>77 per team), :1213 (scattered); each `CreateStartPoint` stamps ellipse 5×7 at `(x,z+2)`, `SetupMines(...,0,1,...)`, `SetupStartingResources` | D1:407–416, :980–988, :1090–1229, :1586–1615 | **reseeds #4–#7** at :1100/:1161/:1177/:1213 (branch-conditional) | v61 branch `floor(RandomExt*(maxind+1))`; scattered branch `for j:=0..i+8: RandomExt`; per start: near mines + 128×3 resource probes | starts, ellipses, near mines |
| 8 | **Reseed** `SetRandomKey(randkey1)` | D1:1616 | **reseed #8** | — | — |
| 9 | Relief: `relieftype>4 → floor(RandomExt*5)`; probability table; `plain:=0.0001/2`; `mnt/plt/hil × problarge`; `_misc_SetupPatternsByType` for mountains/plateau_big/plain_huge/ravine_big/plateau/plateau_small/hills_dark/hills_light (desert variants instead); then **global mines** per start `SetupMines(arrStartPos[i].x,arrStartPos[i].y,1,0,...)` | D1:1621–1770 | inherits #8 | 1 relieftype draw + `needed` name draws + up to `needed×trycount` ×2 position draws per family + per-start global mine draws | stamped relief height + objects + mines |
| 10 | **Reseed** `SetRandomKey(randkey1)` | D1:1772 | **reseed #9** | — | — |
| 11 | Forest/stone/decor: `frs_big/mid/small × prob*`, `stn1/2 × probsmall`, desert halves `frs_*`, conifer-only branch (`foreststype=0`), big/mid/small forest families, stones, swamp/lake/plain, event gates | D1:1774–1907 | inherits #9 | as stage 9 | forests/stones/decor objects |
| 12 | **Reseed** `SetRandomKey(randkey1)` | D1:1909 | **reseed #10** | — | — |
| 13 | Peasants: `CreateStartPointPeasants` 18/player at `cUnitR=0.75`; `_misc_PreloadTextures`; object scale jitter (midpoint-lerp, 5% dead-band, skip `terrainmesh`/`stones`, winter delete `leaftree`) | D1:1914–2027, :1231–1281 | inherits #10 | per-peasant `(0.5-RandomExt)*0.25` ×2; object-scale RNG stream [U] | units + final object transforms |
| 14 | **Reseed** `SetRandomKey(randkey1)` | D1:1927 | **reseed #11** | — | — |
| 15 | `FillOwnerMap(spcount)` — 160² wavefront BFS, 4-neighbour, `owner=-1`, `dist=-1`; then peace-only `SetupBorderObjects` | D1:1361–1428, :2059–2065 | inherits #11 | none | ownership grid + border markers |
| 16 | Finalize: `_misc_SetShoresCollision`, `_misc_FixCollisionInertiaObjectsInOnePoint`, colour tables 6/7/0, PHDR 1/0, `TimeLog('Generation finished...')` | D1:2068–2100 | inherits #11 | none | final collision/colour state |

### A.3 D2 internal order inside stage 5 [O]

| Sub-stage | D2 lines | Reseed | Notes |
|---|---|---|---|
| Mask folder/pick | :139–216 | `SetRandomExtKey64(randkey0,randkey1)` at **:216** (ext-reseed #1) | `rndind := floor(RandomExt*count)` at :190 runs **before** :216, on the stream inherited from D1:1538 (or whatever `GenerateMapRandKey` set) — [U] exact seed |
| Editor postprocess | :507–533 | `SetRandomExtKey64` at **:513** (ext-reseed #2) | guarded `if (not bRandomMap)` — skipped in skirmish; `trgbitmap := srcbitmap` at :531 |
| Height decode | :552–578 | inherits :216 | `cLoadHeightDataFromTexture` gate [U] |
| Smoothing S0/S1/S2 | :580–644 | inherits :216 | `TerrainUpdate(True,False)` at :641 |
| Water fields | :646–709 | inherits :216 | `WaterFieldsClear`; `WaterFieldAdd(...)` |
| TextureMap | :770–776 | `SetRandomExtKey64` at **:774** (ext-reseed #3) | `IntRegister0 := forestType`, `ExecuteState('TextureMap')` |
| SmoothTiles | :781–786 | inherits :774 | `ExecuteState('SmoothTiles')` |
| LoadTextureTerrainFromBitmap | :791–798 | inherits :774 | routine is commented text [U] |

### A.4 Post-`DoGenerate` (D3) [O]

`MapWorldUpdateTerrainData(0,0)` (D3:235) → `TopologyBuild` (:237) → `_misc_BuildIslandsGrid` (:239); record-manager cleanup at :245–254. The port's `generate()` models only stages 1–16 and does not model the D3 wrapper/topology calls — [U] engine-side.

### A.5 RNG contracts [O]/[D] (spec/02, D02, X21)

- `RandomExt`: `s = (s * 0xFC0D + 0x3C6EF35F) mod 2^32`; output `f32(s / 2^32)`; code at `0x60f64c`–`0x60f698`. [O]
- `SetRandomKey(randkey1)` and `SetRandomExtKey64(randkey0,randkey1)`: **only the low word `randkey1` seeds**; `key0` is discarded mod 2^32; `s=0` advances to the increment (no absorbing fixed point). [D] X21 §4.3/§4.5. Exact donor key-derivation `GenerateMapRandKey` is [U].
- Delphi `Random(256)` (`sub_403a0c`, state `DAT_008f2008`): `state = (state*0x8088405 + 1) mod 2^32`, return `(256*state)>>32 = state>>>24`. **Separate stream**, used for the tile variant byte (§E) and object-scale jitter — [O] raw instructions `0x403a0c/0x403a0f/0x403a19/0x403a20/0x403a22` freshly re-read.
- Native per-object RNG instances (e.g. `0x7281bc`) are [U] — no direct draw assignment proven.

**Total reseed sites: 11 × `SetRandomKey(randkey1)` + 3 × `SetRandomExtKey64(randkey0,randkey1)`.** The port's `RESEED_SITES`/`EXT_KEY_SITES` arrays (`terrain_donor_gen.gd:122–126`) match this exactly [O]. The port's assignment of the 3 ext-reseeds to a *separate* `map_generator` stream (`_stage_begin` at :721–723) is **[I]** — donor `SetRandomExtKey64` and `SetRandomKey` feed the same `RandomExt` generator (X21); treat the port's 4-stream split as a labelled approximation.

---

## B. Exact mask decode (task item 2)

### B.1 Load path and format [O]

`generator.cfg:2–28`: `TerrainTypes[0].path = .\data\gen\terrainmasks\nowater2` is the **live** Land shape (`land` is commented out); then mediterranean, peninsulas, islands, continents, continent. `D1:1560–1564` → `StringRegister0 := path`, `ExecuteState('GenerateMap')`; `D2:171–191`: `folderpath := StringRegister0`, enumerate `*.tga`, choose first `<plcount>pl*.tga` family with `count>0`, `rndind := floor(RandomExt*count)`. All shipped final masks are **320×320, 24 bpp, RLE truecolour (type 10), BGR, descriptor 0x00 = bottom-left origin**; `.src` masters are 256×256, descriptor 0x20 = top-left. **No alpha byte exists in any of the 4,466 masks** (F04 full census). [O]

### B.2 Channel → struct decode (verbatim `D2:444–495`) [O]

Let `fr,fg,fb,fa ∈ [0,1]` be `GetBitmapPixel` floats; `ir=floor(fr*255)`, `ig=floor(fg*255)`, `ib=floor(fb*255)`.

**R → `gMapMask[x,y].terrain` and `.bsmooth`:**
| `ir` | class | `bsmooth` | constant |
|---:|---|---|---|
| 255 | `cRPlateau` | `False` | `cRColorPlateau` |
| 191 | `cRPlateau` | `True` | `(255 div 2)+64` |
| 96 | `cRHill` | `False` | `cRColorHill` |
| 112 | `cRHill` | `True` | `(96 div 2)+64` |
| 48 | `cRRavine` | `False` | `cRColorRavine` |
| 88 | `cRRavine` | `True` | `(48 div 2)+64` |
| 64 | `cRNone` | `True` | `128 div 2`, "smooth me, no class" |
| else | `cRNone` | `False` | — |

Smooth codes are exactly `(base code div 2)+64`; `bsmooth = (ir ∈ {191,112,88,64})`. [D]

**G → `.forest`:**
| `ig` | class |
|---:|---|
| 255 | `cGForest` |
| 127 (`255 div 2`) | `cGForest` **only if** `terrain ∈ {cRPlateau,cRHill,cRRavine}`, else unchanged |
| 64 | `cGGenForest` |
| 128 | `cGStone` |
| 192 | `cGForestStone` |
| else | `cGNone` |

**B → `.water` (per-cell enum):** `ib == cBColorWater(255)` → `cBWater`, else `cBNone`. This is a **discrete class**, distinct from the continuous water bed `fb`. [O]

**alpha/`fa` → `.broad`:** `if (fa>0) then broad:=True else False` (D2:450–453). With 24-bit TGAs there is no alpha byte, so `fa` is a loader default and the whole road branch is **[U]** on shipped data. [O text / U runtime]

**`gPatternMask` prefill (random-map branch, D2:491–495):** `False` iff `(ir=0 ∧ ig=0 ∧ ib=0) ∨ (ir=255 ∧ ig=255 ∧ ib=255)`, else `True`. [O] The separate layer-by-layer prefill at `D2:811–850` is **editor-only** (guard `if (cPlaceFreeForests) and (not bRandomMap)` at `D2:799`) — freshly resolved [O], refutes applying it to skirmish.

### B.3 Start markers [O]

Detection: `fr=1 ∧ fg=1 ∧ fb=1` (exact normalized white, byte 255/255/255) at D2:413 and D2:325; recorded as start, then `fr:=fg:=fb:=0` at D2:440–443 **before** class/height decode. Dedup: scaled branch `srcwidth>mapwidth` compares only the *immediately previous* accepted start (D2:329/419–435); equal-size branch compares against all previously accepted starts (D2:417–435). No minimum-distance rule exists in mask extraction. Full corpus: exactly 5,125 vanilla / 7,616 DLC5 white pixels; six near-duplicate masks (1–2 px, §F04). [O]

One asymmetry to preserve [O]: the **height** pass skips starts on `(bRandomMap) and (fr=1) and (fb=1)` (D2:565) — it ignores `fg`. A pixel with R=B=1, G≠1 is skipped by height but not by extraction; no such pixel occurs in shipped data [U].

### B.4 Integer boundaries [O]/[D]

- Water bed from shipped masks (`fr=0` off starts): `h = -1.1·B/255`. Water tag `h<-0.25 ⇔ B > 0.25·255/1.1 = 57.95 ⇔ integer B≥58`. Shore band `h<-0.1 ⇔ B > 0.1·255/1.1 = 23.18 ⇔ integer B≥24`. [D]
- Water **class** is `B==255` only; do not use that as the tile/height gate.
- B is continuous in the final `_gauss` masks (all 256 values). The offline gauss (D7, editor only) is `rs=Round(r*2.57+0.5)`, `w=Exp(-dsq/(2r²))/(PI·2r²)`, clamp-to-edge, `Round(255*val/wsum)/255`, `Clamp(0,1)`, two passes `r=0.00001 (rs=1)` then `r=0.925 (rs=3)`; it is already baked into shipped assets. [O]

---

## C. Exact height formula and every smoothing pass (task item 3)

### C.1 Height (verbatim `D2:559–574`, freshly re-read) [O]

```
for y:=0 to mapheight do
  for x:=0 to mapwidth do            // BOTH loops INCLUSIVE
    realx := floor(lx+x); realy := floor(ty+y)
    ix := ClampInt(x,0,mapwidth-1); iy := ClampInt(y,0,mapheight-1)
    fr := gMapMask[ix,iy].r;  fb := gMapMask[ix,iy].b
    if bRandomMap and (fr=1) and (fb=1): continue
    hwater   := cWaterHeight*(fb*(1+fr*3.5))       // -1.1*(fb*(1+3.5*fr))
    case gMapMask[ix,iy].terrain of
      cRPlateau: hterrain := cPlateauHeight*fr     // 2.964*fr
      cRHill:    hterrain := cHillHeight*fr        // (2.964/2.25)*fr = 1.317333…*fr
      cRRavine:  hterrain := cRavineHeight*fr      // -2.964*fr
      // no else: hterrain stays 0
    SetHeightData(realx,realy, hwater+hterrain)
```

Constants [O] `D2:4–7` freshly re-read: `cPlateauHeight=2.964`, `cHillHeight=cPlateauHeight/2.25`, `cRavineHeight=-2.964`, `cWaterHeight=-1.1`; `R` multiplier `3.5`. Effective per class at `R`=255/191/112/96/88/48/64: plateau +2.964/+2.220, hill +0.578/+0.521, ravine −1.023/−2.964, smooth-only 0. [D] On all shipped masks `fr=0` off starts, so the observed field is exactly `h=-1.1·B/255 ∈ [−1.1,0]`; ±2.964 comes from stamp stage (§F.5), not the mask. [D]

### C.2 Helper `_misc_SmoothTerrainCustom(x,y,times,power,lerp,minh,maxh)` — `D2:218–245` [O]

```
if power=0: exit
for i:=0 to times-1:
  if (x>minx) and (x<mapwidth div 2) and (y>miny) and (y<mapwidth div 2):
     lt:=GetHeightData(x-1,y-1); rt:=GetHeightData(x+1,y-1)
     lb:=GetHeightData(x-1,y+1); rb:=GetHeightData(x+1,y+1)
     h :=GetHeightData(x,y)
     if (h<>lt) or (h<>rt) or (h<>lb) or (h<>rb):
       if (h>=minh) and (h<=maxh):
         z1:=(lt+rt)/2; z2:=(lb+rb)/2
         res := h + ((z1+z2)/2 - h)/power
         res := Lerp(h, res, lerp)
         SetHeightData(x,y,res)
```

- **Neighbour order:** lt `(x-1,y-1)`, rt `(x+1,y-1)`, lb `(x-1,y+1)`, rb `(x+1,y+1)` — four **diagonals**, not cardinals. [O]
- **Gates:** interior `x>minx, x<W/2, y>miny, y<W/2` (note `mapwidth` used for the **y** bound too — literal donor anomaly, harmless on square maps; X03 A5); any-diagonal-differs; `minh ≤ h ≤ maxh`. [O]
- **No clamp, no rounding** inside the helper (height is float). [O]
- Effective step coefficient `lerp/power`: **land `0.5/4 = 0.125`**, **coast `0.5/0.35 = 10/7 ≈ 1.428571`** (overshoots the diagonal mean — deliberately not clamped). [D]

### C.3 Stage order of smoothing (`D2:580–644`, freshly re-read) [O]

| Pass | Trigger | Exact call | Count | Update point |
|---|---|---|---|---|
| **S0** | every cell with `gMapMask[x,y].bsmooth` | `SmoothTerrain(realx, -realy, False, 3)` — note **negated Y**, radius/param `3` | once per bsmooth cell | native kernel writes height [U] |
| **S1** | whole map, all cells `0..mapH-1 × 0..mapW-1` | `_misc_SmoothTerrainCustom(realx,realy,1,4,0.5,0.01,100)` | **1** | `SetHeightData` per cell |
| **S2** | cells where self OR any neighbour in clamped Chebyshev square `rad=2` has `gMapMask[nx,ny].water=cBWater`; `for [MAIN]ny:=ClampInt(y-rad,0,mapwidth-1) to ClampInt(y+rad,0,mapwidth-1)`, `nx` with `mapwidth-1`; first water hit → `break(MAIN)` | `_misc_SmoothTerrainCustom(realx,realy,1,0.35,0.5,-100,-0.01)` | **3 passes** (`for i:=0 to 2`) over full `0..mapwidth/0..mapheight` loops | after all 3 passes: `TerrainUpdate(True,False)` at D2:641 |

The commented negative land-range line `D2:607` is **dead** — do not implement. [O] `SmoothTerrain` is an engine-registered DScript native (string at `0x6a395a`/`0x6a394e`, signature `procedure MapGeneratorSmoothTerrain(x,y,passes;radius:Float)` at `0x6a3930`); its internal kernel is **[U]** — built-in function discovery misses the high VAs (`ev_970aa935…`, `ev_1ec21295…` carried). [O/U]

---

## D. Shore / cliff tile classification, sector math, tile smoothing (task item 4)

### D.1 Gate and precondition (`D4:426–472`) [O]

```
lh=GetHeightData(x-1,y); rh=GetHeightData(x+1,y)
th=GetHeightData(x,y-1); bh=GetHeightData(x,y+1)
rbh=GetHeightData(x+1,y+1)                 // only 5 of 8 neighbours are read
dirX=lh-rh; dirY=th-bh
len=VectorLength(dirX,0,dirY)
if len <= 0.01: NO TILE              // wraps the whole selection block
vec_pre = VectorAngle(1,0,0,dirX,0,dirY); if dirY<0: vec_pre := -vec_pre
bWater      = (gMapMask.b>0) and (h < -0.25)
bWaterShore = (gMapMask.b>0) and (not bWater) and (h < -0.1)   // ELSE at D4:468
if bWater or bWaterShore -> SHORE PATH
else if (map edge) or GetMapCollisionTagInRadius(realx,realy,0,False)>0 -> CLIFF PATH
else -> NO TILE
```

Strict `<` at both bounds: `h=-0.25` is `bWaterShore`, `h=-0.1` is dry. [D] X28 vectors 11/13. Three water levels must stay distinct: basin `−1.1` (D2:7), field Y `−0.5` (D2:688/704), classify `−0.25` (D4:30), shore `−0.1` (D4:31). [O] The plane Y is engine-side [U].

### D.2 Shore 8×45° sector table (`D4:474–528`) [O]

`vec_post = vec_pre + 180` at D4:476 (inside the shore branch only). Windows are a first-match **if/else chain** on `vec_post`:

| Face | Window on `vec_post` | Donor line | Tile (summer) | F05 id | Atlas cell |
|---|---|---|---|---:|---|
| `bR` | `[−22.5, 22.5)` | :479–480 | `sandsea6` | 98 | (2,6) |
| `bRB` | `[22.5, 67.5)` | :482–483 | `sandsea6` | 98 | (2,6) |
| `bB` | `[67.5, 112.5)` | :485–486 | `sandsea1` | 93 | (13,5) |
| `bLB` | `[112.5, 157.5)` | :488–489 | `sandsea5` | 97 | (1,6) |
| `bL` | `[157.5, 202.5)` | :491–492 | `sandsea6` | 98 | (2,6) |
| `bLT` | `[202.5, 247.5)` | :494–495 | `sandsea6` | 98 | (2,6) |
| `bT` | `[247.5, 292.5)` | :497–498 | `sandsea1` | 93 | (13,5) |
| `bRT` | **catch-all `else`** — the `vecangle>=337.5` bound at :500 is commented out | :500–501 | `sandsea5` | 97 | (1,6) |

Then independent `if`s write `bLB→sandsea5`, `bRB→sandsea6`, `bB→sandsea1`, `bL→sandsea6`, `bR→sandsea6`, `bT→sandsea1`, `bRT→sandsea5` (D4:503–511). Exactly **three live shore textures** `sandsea1/5/6`; `sandsea2/3/4` survive only in smoothing lists. Cliff-path `|h|>2.7→rock8` / `>2.4→rock4` at D4:514–519 are `{…}`-commented — inert. [O] Winter: `GetSeasonType=2 → newtile+='_winter'` (D4:525–526), same numeric id. `SetTileIndex(x,y,MapGetTileIndexByTileBlock(newtile))` at D4:528. Do **not** use `floor(...)%8` — X28 vector 9 (post=350°) distinguishes the catch-all. [O/D]

### D.3 Cliff 6-branch table (`D4:556–608`) [O]

Cliff is in the **`else`** of the shore block, so **`:476` never runs**: windows apply to `vec_pre`, not `vec_post`. First-match if/else:

| Face | Window on `vec_pre` | Tile | id |
|---|---|---|---:|
| `bRB` | `[22.5, 67.5]` | `rock4` | 20 |
| `bLB` | `[120, 170]` | `rock7` | 23 |
| `bR` | `[−45, 45]` | `rock4` | 20 |
| `bB` | `[45, 135]` | `rock1` | 17 |
| `bT` | `[−135, −45]` | `rock4` | 20 |
| `bL` | `else` | `rock3` | 19 |

Note the asymmetric `120..170` (not `112.5..157.5`, D4:564 — X03 A13). Overlaps resolved by order (`pre=45` → `bRB`; `pre=135` → `bLB`). Live overrides **after** face choice (D4:594–601): `Abs(h)>2.7→rock8 (24)`, else `>2.4→rock4 (20)`, else `Abs(h)<0.1→no tile`. `cDiff1=0.5`, `cDiff2=0.55` (D4:63–64) are **upstream collision gates** painting `gc_collisiontag_terrain` (D4:88–129), which feeds the cliff trigger — they are not tile-selection thresholds. [O]

### D.4 Tile smoothing (`smoothtiles.inc:4–242`) [O]

- `SmoothTileMap(mini,minj,maxi,maxj,passes)`: per pass, **horizontal sweep** `for i:=mini..maxi-1` (outer x), `for j:=minj..maxj` (inner y), then **vertical sweep** `for j:=minj..maxj-1` (outer y), `for i:=mini..maxi` (inner x). [O]
- `GetNeighbourTiles` selects the compatibility chain with minimum index distance `abs(i1-i2)`; distance 1 with at least one nonzero-prob tile → **no-op**; distance 2 → midpoint list via `FindRandomTileIndex`; larger gap → step toward water. D5:124–125 `ind2ProbZero := ind2ProbZero` is a literal no-op; `sumProb` initialisation is [U]. [O/U]
- `FindRandomTileIndex(i,j)`: `rnd := RandomExt*sumProb`, first cumulative `prob>0 ∧ rnd<tmp` wins (D5:63–76). [O]
- Live call: `SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3)` — **3 passes**, horizontal then vertical, write-back once at D5:240–242. [O] `globalparams.cfg:9 TileSmoothPasses=6` has no readable consumer — preserved contradiction; skirmish follows the script's **3**. [U]
- Probabilities freshly re-read from `tilesmooth_scripts.cfg:1–120` [O]: chain 1 group 0 `sandsea1/2/3/4 = 1` each; group 1 `sandsea5=0.7, sandsea6=0.3`; (commented sandrock group inactive); group 2 `rock9/rock8/rock5 = 0.0`; group 3 `rock1/rock2/rock3/rock6/rock7 = 0.16` each, `rock4 = 0.20`.

---

## E. Exact 24-byte / 13-byte record writer (task item 5) — RESOLVED [O]

The task asked: "how four corner tags + variant byte are produced from tile ids and neighbours; if still [U], identify exact functions/addresses and run more passes." Five fresh passes were run (§0.2). Result: **fully [O]**. There is **no neighbour comparison, no face-direction branch, no mask/sort/LUT, and no derivation from `tile_id` bits** at write time.

### E.1 The setter `0x8326b8` (fresh bytes + instruction stepping) [O]

Prologue/param capture: `ecx = param A` (native `r`) → `[ebp-8]`; `edx = param B` (native `c`) → `[ebp-4]`; `eax = terrain object` → `esi`. Outer `a=[ebp-0x10]=0`, inner `b=ebx=0`.

```
0x8326d3  sub edi,[ebp-0x10]       ; edi = c-a
0x8326d9  sub eax,ebx              ; eax = r-b
0x8326e6  call 0x50fba0            ; bounds helper, ecx=[esi+4]-1 (W-1), eax=c-a
0x8326eb  test al,al / je skip     ; second call with [esi+8] (H), [ebp-0xc]=r-b
0x832701  mov eax,[esi+0x14]       ; row-pointer table
0x832704  mov eax,[eax+edi*4]      ; row (c-a)
0x83270a  lea edx,[edx+edx*2]      ; *3
0x83270d  lea eax,[eax+edx*8]      ; + (r-b)*24
0x83271c  mov dl,[ebp+8]           ; tile u8 (narrowed Integer, no [0,123] check)
0x83271f  mov [eax+ebx],dl         ; *** corner store: record[a*2+b] = tile ***
0x832722  mov eax,0x100
0x832727  call 0x403a0c            ; *** Delphi Random(256) ***
0x83272f  mov [edx+4],al           ; *** variant byte = random draw ***
0x832739  call 0x83276c            ; TerrainChanged notification (not a record13 writer)
0x83273e  inc ebx / cmp ebx,2 / jne 0x8326d0        ; b loop 0..1
0x832744  inc [ebp-0x10] / cmp ...,2 / jne 0x8326ce ; a loop 0..1
```

- Bounds helper `0x50fba0` = `0<=idx<=max` (`cmp ecx,edx; jl fail; cmp eax,edx; jl fail; cmp ecx,eax; jge ok`). Only the **target cell** is bounded; no clamping/wrapping, no neighbour read. [O]
- Stride `*3*8 = 24` confirms the 24-byte record; corner index = `a*2+b`. [D]
- For one source vertex `(r,c)` the four targets are `(r-a,c-b)`, `a,b ∈ {0,1}`, in **a-outer/b-inner order**. [O]

### E.2 Resulting four tags [D]

For a finished cell, with source scalar field `T` produced by the earlier script stages (§D tile ids, cliff ids, desert remap, smoothing write-back, detail bitmap):

```
cell[r,c].t0 = T[r,c]       // a=0,b=0
cell[r,c].t1 = T[r,c+1]     // a=0,b=1
cell[r,c].t2 = T[r+1,c]     // a=1,b=0
cell[r,c].t3 = T[r+1,c+1]   // a=1,b=1
```

`[T,T,T,T]` is the interior uniform-region case (all four covering source vertices carry `T`) — **not** a setter rule. Tags differ exactly when the covering vertices carried different scalar ids; the two middle rows are symmetric "one step back in one axis" (no code distinguishes which axis). [O/D]

### E.3 Variant byte [O]

`0x403a0c` (fresh instructions): `imul edx,[ebx+0x8f2008],0x8088405` → `inc edx` → `mov [ebx+0x8f2008],edx` → `mul edx` → `mov eax,edx`. With `eax=0x100`: `state=(state*0x8088405+1) mod 2^32`, `byte=(256*state)>>32 = state>>>24`. One draw per **accepted** target cell; final `variant` is the **last writer's** draw. 15 discovered callers (`ev_be530cd5…`); the `0x8326b8` caller is high-VA-undiscovered so absent from that list — tool limitation, not absence. `0x81272f` is **not** the source: it disassembles as `add [ecx+edi*4],cl` (garbage), per `DEC_DEEP_corner_tags` §6.2. [O] Generation-time seed/stream position is **[U]**.

### E.4 Getter, serializer, render override [O]

- **`FUN_0082ec5c`** (fresh Ghidra, `ev_1448daf1…`): bounds `param_2<0 ∨ *(param_1+4)<=param_2 ∨ param_3<0 ∨ *(param_1+8)<=param_3` → OOB copy default from `PTR_008fc33c`; else row table `*(param_1+0x14)`, stride `param_3*0x18`, 6 dwords (24 B). 10 callers incl. renderer `sub_812e34` (`ev_4e3f7f49…`). `GetTileIndex` returns only `+0` or `0` OOB. [O]
- **Serializer `0x8305a0` (save) / `0x8302b0` (load)** (fresh bytes, undiscovered high VAs but step cleanly): write loop at row table `+0x14` with `ecx=0x18` (24 B), then `+0x20` with `ecx=0x0d` (13 B) and `mov byte [eax+0xc],0` (clear dirty). Read side symmetric (`ff 53 0c` vtable read). Full height grid `(W+1)²` floats first; interleaved **37-byte records** per cell; anchors `quad_pos-8`. [O]
- **`FUN_00830818`** (fresh Ghidra, `ev_65baa8fc…`): bounds via `0x50fba0`; `bVar1 = *(byte *)(rowTable[param_2] + 8 + param_3*0xd)` = record13 **override byte** at `+8`; if `<0x80` return it; else scan 3×3 neighbours for a signed byte `>=0`; else `0xffffffff`. `0x830754` applies the returned byte only when `cmp [eax+0xa4],0` (object-active gate) fires. So **13-byte flags never create tags; they can substitute one corner at render time** under the object override gate. [O]

### E.5 13-byte tail layout and defaults [O]

```
+0..+3   s8 corner values
+4..+7   u8 corner flags (index (subrow&1)*2+(subcol&1))
+8       override tile id
+9       override random
+10      signed mode/control
+11      signed threshold/control
+12      dirty/loaded flag (reader sets 1, writer clears 0)
```

Fresh bytes: `record24@0x8f6164 = 00*8 | f32(1.0)×4` (`ev_7a605515…`); `record13@0x8fab6c = 00 00 00 00 00 00 00 00 00 00 FF 00 00` (`ev_2f7258e1…`, `ev_b9a8a9c2…`) — **+11 is 0x00, not 0xFF**; the prior `DEC_DEEP_corner_tags` §7.1 text `00*10 ff ff 00` is corrected by fresh reads. `PTR_008fc33c → 0x008f6164` (`ev_497e6822…`). `0x8326b8` touches only corner value, `variant+4`, and notifies; no `+8/+9/+12` store. [O]

### E.6 What the port must implement [D]

```text
set_tile(r,c,tile):
  for a in 0..1:
    for b in 0..1:
      rr=r-a; cc=c-b
      if 0<=rr<W and 0<=cc<H:
        cell[rr,cc].tags[a*2+b] = tile & 0xff
        cell[rr,cc].variant = delphi_random(256)   # SEPARATE LCG stream
        mark_dirty(rr,cc)
get_tile(r,c): return tags[0] or 0 if OOB
```

Importer: anchor `quad_pos-8`, read `(W+1)²` heights, stride 37 B, preserve all `+5..+7`, collision words and all 13 tail bytes verbatim. Alpha layers come from sorted distinct final tags + occupancy mask (`t0=8,t2=4,t1=2,t3=1`) + variant-selected patch (LUT `0x8f5d00`); **never** from `tile_id` bits. [D]

---

## F. Exact pattern / prop placement (task item 6)

### F.1 Pre-mark that actually runs in skirmish [O]

- **Generic blanket** `D2:491–495`: every non-black/non-white mask cell → occupied (see §B.2). [O]
- **Shore band** `D1:1568–1581`: `height<-0.1` for unoccupied cells → occupied. Runs **after** `GenerateMap` smoothing, **before** starts. [O]
- **Border** `_misc_FillPatternMaskMapBorder(3)` at `D1:1613`: cells with `x<3 ∨ x>W-3 ∨ y<3 ∨ y>H-3` → occupied. [O]
- **Three start ellipses** `5×7`, `12×15`, `22×18` centred `(x,z+2)` at `D1:984/:769/:947`; `IsDotInElipse`: `sqr(x-x0)/sqr(rx)+sqr(y-y0)/sqr(ry) <= 1`, loop `i=-round(ry)..floor(ry*2)-1`, `j=-round(rx)..floor(rx*2)-1` (D1:8–29). [O]
- The `generatemap.inc:811–850` water/bsmooth/broad/collision pre-mark is **editor-only** (freshly resolved §0.2 item 4) — it does **not** pre-mark skirmish water. The `gc_WaterBorderSize=3` ring belongs to `_misc_SetShoresCollision` at **finalize** (D1:2068), i.e. after all placement. [O]
- Water/shore "rejection" is therefore **emergent** from occupancy; `_misc_CheckStandPattern` has no water/collision/topology test inside. [O/D]

### F.2 `_misc_CheckStandPattern(Ext)` (`D9:3384–3521`) [O]

Predicate only: `(maskValue and maskStand) or ((not maskValue) and maskInvStand)` → reject if out-of-map or `gPatternMask[indJ,indI]` set. Fast path when `not doStand and angle=0`: `step=4` sampling (D9:3441); full path over whole mask box. `Ext` = test (`doStand=False`) then atomic stamp (`doStand=True`); all generator call sites pass `angle=0`, so the rotated branch is dead. Stand branch writes `gPatternMask=True` only for stand-cells. Native mask primitives: `sub_755168` (stamp, `+0xa0=W,+0xa4=H,+0xa8=row table` → `sub_764e04`), `sub_7550f8` (pure bounds `-halfW<dx<+halfW` etc.), `sub_75505c` (test+stamp, `+0x65` auto/collide, `+0x1c` occupant), `+0x80 & maskByte` required-stand gate. Out-of-range cells are silently skipped (no wrap/clamp). [O]

### F.3 Mines — `SetupMines` (`D1:522–717`) [O]

```
trycount=256
rounds = 3/4/5 for minesdensity 0/1/2; if maxround>0 and rounds>maxround: rounds:=maxround
for i:=minround to rounds-1:                 // RING
  for j:=0..2: str := mng|mni|mnc (desert_ prefix if bDesert)   // ORE
    for k:=0..255:                            // ANGLE ATTEMPTS
      _misc_GetPatternNameByParser(name,pPatternList)           // roulette
      // version/size/player-count case assigns dst (map CELLS, 1:1)
      angle := RandomExt*360
      VectorRotateY(dst,0,0,angle) -> px,pz
      if CheckStandPatternExt(envplHnd,name,round(newpointx+px),round(newpointy+pz),True,...):
        PatternIncreaseFreq; break            // first success
```

Rings, not ore-specific radii [O] (refutes "gold 14–22, iron 32–42, coal 70–82"). Bands are `dst = base + span*RandomExt` in **map cells** (`gc_meters_to_tile=2` is a separate horizontal unit [U]):

| Condition | ring0 | ring1 | ring2 | ring3 | ring4 |
|---|---|---|---|---|---|
| `v<70` | `14+8R` | `38+8R` | `130+40R` | `52+8R` | `26+5R` |
| `v>=70, mapsize>2, v<77` | `14+8R` | `36+12R` | `50+12R` | `22+16R` | skip |
| `v>=70, mapsize>2, v<80` | `14+8R` | `32+10R` | `50+12R` | `22+16R` | skip |
| **`v>=80, mapsize>2`** | **`14+8R`** | **`32+10R`** | **`70+12R`** | **`22+16R`** | skip |
| `mapsize<=2, spcount<=4, v<75` | `14+8R` | `36+12R` | `88+18R` | `50+12R` | `24+9R` |
| `spcount<=4, v<77 / <80 / >=80` | `14+8R` | `36/32+12/10R` | **no case** | `50/70+12R` | `22+16R`, ring5 skip |
| `spcount>4` | `14+6R` | `23+10R` | `39+9R` | `33+9R` | skip |

**[O] real anomaly:** the four `spcount<=4` bands label `0,1,3,4 (,5:continue)` — ring 2 has **no assignment** and inherits stale/uninitialised `dst` (D1:617–645). [U] VM local-init semantics. Far-ring relocation at D1:658–697: `i=2, spcount<=4, mapsize>2, v>=90` snaps centre to quadrant corner `±(maphW-24), ±(maphH-24)` in centred coords; wrong-position logs `SetupMines wrong position. check it`. Near call `(minround=0,maxround=1)` at D1:985; global call `(1,0)` at D1:1769–1770. [O]

Weighting: `_misc_GetPatternNameByParser` `freqrnd=RandomExt*FreqSum`, first `freqrnd<Freq` (D9:3634–3653); on success `Freq:=max(old*0.2,0.0001)` (D9:3588–3629); missing `Freq` defaults 1; first family block wins on duplicate names. [O]

### F.4 Starting resources (`D1:720–947`) [O]

`trycount=128`, `trycount2=3`, `mindst=Min(5,7)=5`; `dst=mindst+RandomExt*3+(i+j)*0.5`, `angle=RandomExt*360`, first accept via `CheckStandPatternExt` + `break(MAIN)`. Order: (1) `stoneforests` ×1 at `mindst=5`; **stamp ellipse 12×15** at `(x,z+2)`; (2) `stones` ×1 `mindst=12`; (3) forest ×2 `mindst=12` — `foreststype` hard-forced 0 at D1:5–6, so `floor(RandomExt*7)` chooses among `forests_pinefir_medium, forests_spruce_medium, forests_pine_medium, forests_pinefir_big, forests_spruce_big, forests_pine_big, forests_pine_big_2`; (4) `stones` ×1 `mindst=16` (`+2R`); (5) forest ×1 `mindst=16`; **stamp ellipse 22×18** at `(x,z+2)`. **No food/field rects** in this function. Max reach [D]: 135.5 / 142.5 / 145.5 cells; typical acceptance near inner bound. [O]

### F.5 Relief stamps — native `sub_755f30` (`0x755f30`–`0x75c187`) [O]

- 234 blocks / 6,751 insns / 662 callees / 5 callers (fresh editor mirror `sub_8c5b78` has identical 234/6751/662 — §0.1). Lazy init gates `+0x89→sub_75ca34`, `+0x8a→sub_75cf6c`, `+0x8b→sub_75cfb8`, `+0x8c→sub_75d004`. [O]
- Caller fork at `sub_723748`: `+0x41==0 → sub_75c228` (wraps `sub_755f30(90.0f,0,...)`), else `sub_755f30(*(+0x38),*(+0x34),...)`. [O]
- Stamp frame: load `rotangle=[ebp+0x10]`; normal-centre `C=(standx+OffsetX(+0x74), standz+OffsetZ(+0x78))`; half-extents `(W-1)>>1`, `(H-1)>>1` with arithmetic-shift negative correction; per-cell rotate by `cos/sin` (`0x403404/0x40342c`), **divide by 2.0** (`0x75c1a4`, 252 xrefs), **add 0.5** (`0x75c1a8`), add centre; floor via `sub_4a6aa0`. [O]
- Loader `sub_75ca34` reads only `N=(W-1)(H-1)` mask bytes; `sub_755f30` builds a **WxH vertex mask**, copies N bytes to top-left and **blocks last row and column** (`0x7561d0`–`0x756220`). [O]
- Three blend paths from raw x87 opcodes `0x7563e8`–`0x7566e9` (D05 F4 / X26):
  - `ReplaceForWater=true` (`+0x3b`): `new = g*Scale + HeightFieldOffset`
  - `Replace=true` (`+0x3a`): `new = base_h + (g−Min)*Scale + Min + Offset`
  - default **Smooth**: `new = h1 + (base_h−h0)*TerrainScale + (g−Min)*Scale + Min + Offset` (two `getHeight` reads `0x7566a0`/`0x7566c7`; `base_h` bilinear at centre via `0x810498`)
  `Min` is a **pivot**; `HeightFieldMax` (`+0x60`) is **never read** (0/6,751); no `[Min,Max]` clamp. Negative `Scale` (e.g. `−0.925`) inverts grid/pivot, not world height. [O]
- **Smooth post-pass** `sub_755db4` runs after blend when `Stand && Smooth` (**including** `ReplaceForWater` paths such as `g_mnt_*`/`g_hil4`): boundary condition is **outer cell OR clear cell touching a blocked neighbour** (raw `0x757081`–`0x757161`, duplicated right / omitted left neighbour list); radial remap `target = centre + (cell−centre)*(Radius−Offset)/d` with **0.4 only on Z** (`0x75c1b8`); `Factor` = iteration count; circle test `< Radius²`; 4-neighbour mean divided by hardcoded **4.0** (`0x755ee4`); **in-place** (X26 `ev_aba9f17d…`), with the donor's target-axis swap. [O]
- Field→offset map from `sub_75c314` (P7/P8, editor cross-check): `Replace=+0x3a`, `ReplaceForWater=+0x3b`, `Scale=+0x48`, `Smooth=+0x4c`, `Min=+0x5c`, `Max=+0x60`, `Offset=+0x64`, `TerrainScale=+0x68`, `OffsetX/Z=+0x74/+0x78`, `PatternMaskStand/ReverceStand/CollisionStand=+0x80/+0x81/+0x82`. [O]
- **No RNG in the stamp**: 662-callee list has no `RandomExt`/Delphi `Random`; object loops visit every record in order. Per-instance variation is authored via record bytes + `sub_755bc8` permute + `sub_755578` fixups. [O/D]
- Object record streams: `+0x2c` 24 B (`rep movsd ecx=6`, `sub_755bc8` then 8-way `sub_59b8a4` dispatch), `+0x30` 16 B (`sub_755d1c`/`sub_755920`→`sub_59b854`), `+0x34` 13 B (`sub_755c6c`/`sub_755010`). Final submit `sub_7cca74 → sub_4cb27c`. [O] Concrete mesh names live in `pattern.lib Objects[]`, not CODE strings. [U]

### F.6 `_misc_SetupPatternsByType` placement (fresh verbatim) [O]

```
x0 := -(mapwidth div 2);  y0 := -(mapheight div 2)
needed := floor(mapwidth*mapheight*freq)
neededround := round(mapwidth*mapheight*freq)
if needed=0 and freq>0: needed := neededround
trycount := floor(256*mapsizeoptimise)      // optimise=320²/(W*H); ×0.65 if <1
for i:=0..needed-1:
  _misc_GetPatternNameByParser(name,pPatternList)
  for j:=0..trycount-1:
    x := floor(x0 + RandomExt*mapwidth)     // TWO draws per attempt, X then Y
    y := floor(y0 + RandomExt*mapheight)
    if CheckStandPatternExt(envplHnd,name,x,y,True,pRMHnd):
      PatternIncreaseFreq; break
```

Global rates `D1:1688–1693`: `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `dcr=0.0005`, `stn1=0.00016`, `stn2=0.00012`; modifiers `frs_big*=probsmall`, `frs_mid*=probmid`, `frs_small*=problarge`, `stn*=probsmall`; desert halves `frs_*`; non-desert `lake_*=0`, desert `desert_lake` at `plain*35`. [O] Free-mask modifier denominators 340/182/74/29 (`D9:3931–3941`); size modifier `640/((W+H)/2)` (`D1:1718–1724`). [O] `probsmall/mid/large/huge` producer values are engine-computed [U].

### F.7 Water fields and borders [O]

Field raster freshly re-read (`D2:646–709`): `cWaterFieldSize=2`, `cWaterMapArrSize=(640 div 2)=320`; for each 2×2 block `y:=wmy*2 to Min((wmy+1)*2, mapH-1)` **inclusive**, `x` likewise, flag `bWaterMap[wmx,wmy]:=True; break(CELL)` iff `gMapMask[x,y].b>0 and (gMapMask[x,y].r<1 or gMapMask[x,y].b<1)`, with two `ErrorLog` bounds guards (`x/y` vs `gc_terraindata_map{width,height}`; `wmx/wmy` vs `cWaterMapArrSize`). Then `WaterFieldsClear`; `cOffsetY=-0.5`; `mapsizemod=(cWaterMapArrSize/((640/mapheight)*2))*cWaterFieldSize` (float division; integer-div variant commented); for each true field `tx=wmx*2-mapsizemod`, `tz=wmy*2-mapsizemod`, `bx=(wmx+1)*2-mapsizemod`, `bz=(wmy+1)*2-mapsizemod`, `WaterFieldAdd('x'+wmx+'y'+wmy, tx,tz,bx,bz, -0.5)`. The neighbour-fill block at D2:678–685 is `{…}`-commented. Native registration `function WaterFieldAdd(name;tx,tz,bx,bz,offsety:Float)` at `0x602980`, sole ref `0x6029b2` in `sub_601d3c`; runtime Y/class binding [U]. [O/U]

Borders: water/waterborder/landborder/bridge tags + `gc_WaterBorderSize=3`; bridge `cScale=1.15`, `cBaseHeightOffset=0.4876`, block `2.81*scale`, ends `1.78*scale`, offsets `1.07*scale`, collision radius 3 step 2 tag 10; `fordtyp` is a squad formation field, not terrain ford. Runtime plane Y is [U] — keep distinct from classification levels. [O/U]

### F.8 Other placement stages [O]

- **Peasants** D1:1255/1258: 18 per player, `cUnitR=0.75`, `px=pointx+(i div 3)*0.75+(0.5-RandomExt)*0.25-...`, `pz` likewise `(i mod 3)`. [O]
- **Object scale jitter** D1:1990–2021: `scaleMin/Mid/Max = x*minfact / x*((minfact+maxfact)/2) / x*maxfact`; if `(scaleMax-scaleMid)>scaleMid*0.05`, clamp into `[min,mid]` or `[mid,max]` with a fresh random; skip `terrainmesh`/`stones`; winter deletes `leaftree`. TextureMap/editor use the `cDiffKoefMin/Max=0.875/0.95,1.04/1.08` variant (D4:391–405) with those lines commented in D1 — **two live variants, stage-specific**. [O]
- **Forest objects** D4:180–413: the 16-retry `frt_*` branch is **unreachable** (`for try0:=1 to 1`, D4:222); only `n_small_frt_lite_*`/`n_small_frt_*` at D4:316–319 run. `cLiteProb=0.6`. [O]
- **Forest borders** D6:36–148: `count=floor(1+RandomExt*16)` but unconditional `break` at :151 → **one stamp per eligible cell**; `rad=1.5`, `pind=floor(1+RandomExt*53)`, corner `fb_*`; tile decals `grass5`/`rock9` with `_winter` suffix. [O]
- **Owner BFS** D1:1361–1428: 160² wavefront over `dist`, 4-neighbour, `owner=-1/dist=-1/fChecked=false`, seeds from `arrStartPosBusy[i]`; no terrain/collision test. [O]
- **Mill fields are NOT a generation stage**: `_unit_DoSeedWheat` 7×7=49 nodes, step `1.6981` cells, rotated 45°, snap `2.401476`, 25-cell collision probe, `5` gold each, **no RNG draw in the sow routine**; triggered on mill completion/production (activation [U]). [O/U]

---

## G. Line-by-line donor ↔ port diff (task item 7)

Every row: donor rule (with citation), port file:line, current behaviour, label, **required replacement**. "PORT APPROXIMATION" = not donor-equivalent.

### G.1 RNG / stage order (`terrain_donor_gen.gd`)

| Donor [O] | Port lines | Current behaviour | Label | Required replacement |
|---|---|---|---|---|
| 11 `SetRandomKey` + 3 `SetRandomExtKey64` (§A.5) | :122–126 | identical site arrays | [O] | keep |
| `SetRandomExtKey64` seeds the **same** RandomExt generator (X21) | :721–723 | assigns 3 ext-reseeds to separate `_rng_map` stream | [I]/PORT APPROX | route ext-reseeds through the same `RandomExt` stream; keep `map_generator` only as a labelled diagnostic |
| D1:1538 reseed **after** base tiles | :854–876, :883 | `_stage_base_tiles` runs under D3:146 stream; `:1538` reseed at :883 — correct | [O] | keep |
| D1:1613 border mask fill **before** `RandomStartingPoints` (:1615) | :1724 vs :1717–1723 | border fill called **after** the start loop | PORT APPROX | move `_fill_map_border(3)` before the `for s in starts` loop |
| D3:232 / :235–239 wrapper + topology | `generate()` :511–596 | not modelled | [U] | expose as labelled engine-side hook, do not invent |
| No RNG draw in `sub_755f30` stamp | :2102–2415 | no draws in `_stamp_pattern` | [O] | keep |

### G.2 Mask decode / height (`terrain_donor_gen.gd`)

| Donor [O] | Port lines | Current behaviour | Label | Required replacement |
|---|---|---|---|---|
| White start = exact `fr=fg=fb=1` (D2:413) | :940 (`>=0.999`) | tolerance-based detection | PORT APPROX | use exact equality (or byte 255) |
| Start dedup by exact coord (D2:417–435) | :934–949 | none — records every white pixel | MISSING | implement scaled-branch prev-only and equal-size full dedup |
| Height skip on `fr=1 ∧ fb=1` (D2:565, G ignored) | :940 (all three) | a R=B=1,G≠1 pixel would get `h=-4.95` | [U]/MISSING | add the literal `b_random_map && fr==1 && fb==1` skip at the height write |
| `h=-1.1*fb*(1+3.5*fr) + class*fr` (D2:567–574) | :985–991 | exact match | [O] | keep; do NOT flip relief sign (X19 refutes stale claim) |
| Water integer boundary `B≥58` (D) | :148–149 | `C_WATER_BYTE=58` | [O] | keep |
| `gPatternMask` blanket + editor-only layer premark (§B.2) | :1627–1683 | `_apply_water_premark` applies water/bsmooth/collision **unconditionally** + radius-3 disc | PORT APPROX | gate behind `not b_random_map` (or delete for skirmish); retain only D1:1568 shore band + D2:491–495 blanket + D1:1613 border + ellipses |
| `broad` from `fa>0`, no alpha in shipped masks | `_channel` :1004–1034, no broad array | omitted | [U] | keep omitted with label; do not invent |

### G.3 Smoothing (`terrain_donor_gen.gd`)

| Donor [O] | Port lines | Current behaviour | Label | Required replacement |
|---|---|---|---|---|
| S0 `SmoothTerrain(realx,-realy,False,3)` on bsmooth cells | :342–346, :1043–1048 | **skipped** when hook null (default) | MISSING [U kernel] | implement donor kernel or keep explicit [U] hook; at minimum mark stage as skipped in telemetry (already done) |
| S1 land pass interior gate `x>minx, x<W/2, y>miny, y<W/2` | :1068–1072 | smooths all cells | MISSING GATE | add literal bounds gate (`minx/miny` [U] — expose hook, do not invent) |
| S2 coastal neighbour y-bound uses `mapwidth-1` (D2:626, A5) | :1092 (`_grid_h-1`) | "fixed" to height | PORT APPROX | for 1:1 use `clamp(...,0,_grid_w-1)` for BOTH axes; document anomaly |
| Four **diagonal** neighbours, any-differs gate, `minh≤h≤maxh` | :1077–1085 | exact match | [O] | keep |
| Effective coast coefficient `0.5/0.35≈1.4286` | :1060–1061 | telemetry only | [O] | keep |
| `TerrainUpdate(True,False)` after 3 coastal passes | — | not emitted (engine-side [U]) | [U] | expose hook |

### G.4 Water fields / tiles (`terrain_donor_gen.gd`)

| Donor [O] | Port lines | Current behaviour | Label | Required replacement |
|---|---|---|---|---|
| `tx/tz/bx/bz = (wmx/wmy)*2 - mapsizemod` passed to `WaterFieldAdd` | :1107–1135 | stores only `{name,y,size}`; no coordinates or call | MISSING | compute `mapsizemod=(320/((640/H)*2))*2` and the four coords; pass to a labelled `WaterFieldAdd` hook |
| Field loop upper bound `Min((wmy+1)*2, mapH-1)` **inclusive** | :1115–1116 | `range(..., mini((wmy+1)*2, _grid_h))` exclusive | PORT APPROX | use inclusive `min((wmy+1)*2, H-1)` |
| `x/y` and `wmx/wmy` `ErrorLog` bounds guards | :1115–1116 | absent | MISSING | add guard with labels |
| Gate `b>0 ∧ (r<1 ∨ b<1)` | :1118 | exact | [O] | keep |
| Shore/cliff literal if/else + catch-all + 6 cliff faces + `|h|` overrides | :1440–1516 | exact match to X28 | [O] | keep |
| Cliff trigger `GetMapCollisionTagInRadius(...,0,...)>0` | :1468–1480 | single-cell tag only | PORT APPROX | implement radius-0 neighbourhood as donor (or label) |
| Road/broad tiles `RandomExt>0.5→ground1, >0.25→test2 else test3` (D4:622–636) | none | omitted | [U] | keep omitted with label (no alpha in shipped masks) |
| Tile smoothing probabilities include rock group `rock1/2/3/6/7=0.16`, `rock4=0.20` | :1162–1164 | telemetry lists only sandsea + rock9/8/5 | [D partial] | expand telemetry to the full freshly-read table; logic already uses caller chains |
| `FindRandomTileIndex` `sumProb` uninitialised [U] | :1608–1618 | `sum_prob=0.0` | [U] | label as donor-unknown; keep deterministic zero |

### G.5 Placement (`terrain_donor_gen.gd`)

| Donor [O] | Port lines | Current behaviour | Label | Required replacement |
|---|---|---|---|---|
| `_misc_SetupPatternsByType` uniform centred draw: `x=floor(-W/2+R*W)`, `y=floor(-H/2+R*H)` (fresh evidence) | :2600–2614 | strict **25-cell tiled lattice** `next_int(wc+1)`, `rx=gx*25+11` | **MAJOR PORT APPROX** | replace with two uniform `next_f()` draws centred (`floor(-W/2+R*W)` etc.); remove the 25-cell lattice from this function (keep it only for `SetupTiledPatterns`) |
| Global mines called **per start** `SetupMines(arrStartPos[i].x,arrStartPos[i].y,1,0,...)` (D1:1769–1770) | :2582 | called **once** at map centre | **MAJOR MISSING** | loop over all starts |
| Start forests: `floor(RandomExt*7)` picks **one** of 7 families, then roulette within it | :2424–2431, :1945–1995 | `forest0` union of all 7 families, **one** roulette draw | PORT APPROX | implement the 7-way family draw then family-local roulette (extra draw changes stream — label and replay) |
| `_misc_CheckStandPattern` fast step-4 path when `angle=0` (D9:3441) | :2052–2099 | no fast path | PORT APPROX [D] | add step-4 test sweep before full test |
| Stand mask = `GetPatternMaskStand`/`InvStand` bitmasks | :2001–2049 | raw decoded `(h-1)*(w-1)` nonzero lattice, polarity [U] | PORT APPROX | expose stand/inv masks from decoded assets; keep nonzero lattice only as labelled fallback |
| Near mines `(0,1)`, global `(1,0)`, 256 angle tries, bands | :1768–1928 | exact | [O] | keep, incl. missing-case-i=2 flag |
| `foreststype := floor(RandomExt*3); foreststype:=0` consumes a draw | :822–832 | one `next_int(3)` consumed, forced 0 | [O] | keep |
| Object scale jitter (midpoint-lerp, 0.05 dead-band) | :2718–2731 | hook default **skip** | MISSING [U stream] | wire labelled object RNG hook; keep skip explicit |
| Stamp blend three paths + in-place smooth + `(W-1)(H-1)→WxH` blocked mask | :2102–2415 | exact | [O] | keep |
| `base_h` bilinear tap placement 0.5 | :2255–2268 | `-0.5` shift, taps [U] | [U] | keep hook, do not claim parity |
| FillOwnerMap seeds use `arrStartPosBusy[i]` (team index) | :2751–2759 | `owner=i & 0xFF` (player index) | PORT APPROX | seed with `arrStartPosBusy[i]` from decoded input |

### G.6 Inputs (`terrain_donor_inputs.gd`)

| Donor [O] | Port lines | Current behaviour | Label | Required replacement |
|---|---|---|---|---|
| `randkey0/randkey1` are two independent 32-bit settings (`donewgame.inc:16,33–37`) | :407–444 | single 32-bit seed split into high/low words | PORT APPROX [U derivation] | consume two seed words from config; keep `[U]` label on derivation |
| Mask pick = `floor(RandomExt*count)` consuming an RNG draw before D2:216 | :531–574 (`:571`) | `_hash32("%d|%s") % pool.size()` — **no RNG draw** | PORT APPROX | call `next_int(count)` at the correct reseed boundary and record the draw in the ledger |
| Nearest-pixel sample `floor(x/W*srcW)` (D2:409–411/541–542) | :600–626 | Godot **bilinear** resize preferred; nearest only fallback | PORT APPROX | make nearest the default; keep bilinear only as an explicit comparison hook |
| Live Land shape = `nowater2` (`generator.cfg:5–6`) | :471–519, :531–574 | shape from game config (`map_type="land"`) may select `terrainmasks/land` | PORT APPROX | canonical alias `land → nowater2` before `_apply_mask` |
| All 56 port PNGs pixel-identical to donor `_gauss` (F04) | :590–597, :629–686 | gray8 `.r` channel → mask_b | [O] | keep; verify byte-identity on any reconversion |
| `foreststype=0` conifer-only | `_target_family` :939–951 | includes forest families via substring match | PORT APPROX | gate leaf/mixed behind explicit option |
| Compact pattern bundle carries only `{w,h,grid,flags,occupancy}`; **`pattern.lib Objects[]` not exported** | :954–1025 | no `BaseName/Position/Direction/Up/Scaling` records | MISSING | export per-pattern `Objects[]` and add an instancer (single largest fidelity gain, F08 §7.1) |

### G.7 Explicitly forbidden / do-not-repeat (spec/10 §3)

Dither/noise fields, face promotion, `HEIGHT_SCALE` fudge, tile-art relief, uniform free scatter **as a substitute for the 25-cell base-tile grid**, post-collision height writes, forced cliff art, heightmap-as-albedo, shadow/AO fakery, synthetic mottling, lowered gates, invented donor constants. The port currently violates **"uniform free scatter"** in the opposite direction (it uses the base-tile grid for family stands, where the donor uses uniform draws) — §G.5 row 1.

---

## H. UNVERIFIED register (do not implement as fact)

| ID | Item | Status / what was tried |
|---|---|---|
| U1 | Runtime activation of all `[*] = ;` DScript text | [U] — donor binary never executed; no GPU A/B frame |
| U2 | `SmoothTerrain(x,-y,False,3)` native kernel | [U] — strings/function-find/xrefs attempted; high-VA undiscovered |
| U3 | Native `CreateBitmapTGA` / RLE-TGA decoder identity | [U] — strings, bytes, float scan, feature-find, xrefs (D03 U1) |
| U4 | Exact generation-time Delphi RNG seed/stream position for the tile variant byte | [U] — algorithm/addresses [O], state image 0, runtime QPC reseed |
| U5 | `GenerateMapRandKey` key-derivation formula | [U] — no plaintext consumer; port uses single 32-bit seed |
| U6 | `gc_MaxTerrainTypeCount`, shipping `gRecordGeneratorVersion`, `mapsize` enum | [U] — branch choice changes mine radii |
| U7 | `minx/miny` in `_misc_SmoothTerrainCustom` | [U] — not present in readable text |
| U8 | `fa`/`broad` for a 24-bit TGA; road tile branch | [U] — no alpha in shipped masks |
| U9 | `probsmall/mid/large/huge`, `minesdensity` runtime values | [U] — engine-computed |
| U10 | `HeightFieldMax` consumers outside `sub_755f30`, global setter clamp `sub_0059b934`, file-row sign, rotated sub-cell rounding | [U] — D05/X26 |
| U11 | `minangle/maxangle` field offsets, WithAngle arg use | [U] — 6751-insn pass did not isolate |
| U12 | Concrete `pattern.lib Objects[] → mesh` index binding; `.N` suffix → mesh index | [U] — data/engine-side |
| U13 | Water runtime plane Y, bridge/waterborder class binding, `VectorAngle` convention | [U] — X28 §6 |
| U14 | Cliff collision-tag numeric value in readable text | [U] — port leaves tag clear and labels steep cells |
| U15 | `TileSmoothPasses=6` consumer | [U] — script uses 3 |
| U16 | Donor visual parity | [U] — **no claim** |

---

## I. Bottom line

The donor is a **12-stage `DoGenerate` pipeline** bracketed by 11 `SetRandomKey(randkey1)` and 3 `SetRandomExtKey64` reseeds (§A), plus a separate Delphi LCG for the tile variant byte (§E). The mask supplies **only B (water bed) and white starts** on all shipped data; relief amplitude comes from native `sub_755f30` stamps (§F.5), not mask R (§B/C). Tiles are selected by literal if/else sector tables with an **unguarded `bRT` catch-all** and a **pre-angle** cliff table (§D). Each `SetTileIndex` fans one scalar vertex id into four cell corners in a-outer/b-inner order and refreshes a 24-byte record's `+4` variant from a Delphi LCG (§E); the 13-byte tail only substitutes a corner at render time under an object-active gate.

The current port reproduces the height formula, blend math, sector tables and mine-band arithmetic, but diverges in at least **ten** places that must be replaced for a 1:1 rewrite: editor-only water premark applied to skirmish, missing S0 and the S1 interior gate, missing `WaterFieldAdd` coordinates, uniform-vs-25-cell family placement, global mines at map centre instead of per start, forest-family union instead of 7-way draw, FNV hash instead of an RNG draw for mask pick, bilinear instead of nearest resample, `land→nowater2` alias, and absent `Objects[]` instancing (§G). None of this is a parity claim; runtime activation and all U-items remain explicitly open.

*End of PORT1TO1_terrain_generation. Exactly one repo file written. Donor READ ONLY; no donor binary executed or copied; no code/asset/config/Godot/git edit; no parity claim.*
