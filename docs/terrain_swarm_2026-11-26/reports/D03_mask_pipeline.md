---
id: D03
ticket: "D03 — donor terrainmask load → gauss/smoothing → height → water/shore → start markers"
wave: "Wave D (donor binary / Ghidra), 2026-11-26"
owner: "D03 (read-only research worker)"
status: DELIVERED__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_RUNNER_JOB__NO_PARITY_CLAIM
charter: docs/terrain_swarm_2026-11-26/CHARTER.md
board: docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
targets_used:
  - "cossacks.exe — target t_87f0f3c130b0, C:\\Games\\Cossacks 3, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (already open on shared session; not re-opened by D03)"
  - "editor.exe — target t_68474ddde43f, opened read-only by D03 as a SECOND binary cross-check (announced at the time); global active target was restored to cossacks.exe, then drifted again to editor.exe because Craft Anything is shared, so all later binary calls pinned document=t_87f0f3c130b0."
parity_guard: "Everything below is cited donor text/bytes or donor-binary static analysis. NO donor GPU A/B frame exists; no visual or behavioural parity is claimed."
---

# D03 — donor terrainmask pipeline, decoded

## 0. Executive summary

1. **[O] Exact load path recovered.** The shape folder comes verbatim from `data/game/var/generator.cfg` (`TerrainTypes[...].path` / `TerrainTypesDLC5[...].path`) → `dogenerate.inc:1560-1565` `StringRegister0 := path` → `generatemap.inc:171` `folderpath`. `generatemap.inc:173-191` enumerates `folderpath+'\*.tga'`, then filters to the first `<plcount>pl*.tga` family with `count>0`, and picks `inputbitmap := list[floor(RandomExt*count)]`. `generatemap.inc:285-290` selects `CreateBitmapTGA` when the name contains `.tga` and calls `LoadBitmap(srcbitmap, srcbitmappath)`. **The shipped masks are RGB TGA type 10 (RLE), 24 bpp, 320×320, BGR order, `TRUEVISION-XFILE.` footer**; source masks are 256×256.
2. **[O] The relief formula is real donor text, not a port invention** — `generatemap.inc:567-574`: `hwater := cWaterHeight*(fb*(1+fr*3.5))`, `hterrain := {2.964 / 1.317… / -2.964}*fr`, `SetHeightData(realx,realy,hwater+hterrain)`, with `fr,fb ∈ [0,1]` (so `cr/255`, `cb/255` in the port is the same arithmetic). **[D] It is NOT compiled into `cossacks.exe`**: none of `2.964, 1.317, -2.964, 3.5, 0.35, 0.925, 2.57, -0.1` occur as f32/f64 in either `cossacks.exe` or `editor.exe`, and no `terrainmask`/`_gauss`/`CreateBitmapTGA` strings exist. The formula lives in DScript text and is (allegedly) parsed at runtime — **runtime activity remains [U]**, as every donor code line is stored `[*] = ;…`.
3. **[O] The gaussian blur is fully specified in donor text, and it is an OFFLINE postprocess**, not a runtime per-map pass: `BitmapGaussBlur(..., r, bFinal)` uses `rs=Round(r*2.57+0.5)`, `w=Exp(-dsq/(2r²))/(PI*2r²)`, clamp-to-edge sampling, `Round(255*val/wsum)/255`, `Clamp(0,1)`, called twice with **r = 0.00001 (rs=1)** then **r = 0.925 (rs=3)**; `moddersread.txt` and `scripts/editor.inc/postprocesssaver.inc:584-601` confirm the `_gauss` 256→320 output. Runtime `PostProcess` (`generatemap.inc:509-521`) merely loads the pre-made `.\data\gen\bitmap\ext\bitmaptrg.bmp`.
4. **[O][D] IMPORTANT CORRECTION — the shipped `_gauss` masks do not carry relief/forest data.** A **full-corpus** RLE decode of all **1,331** shipped `terrainmasks/**/*.tga` files (and all 1,279 `terrainmasks.src` originals) gives exactly `Rnz = Gnz = white` in every folder: **5,125** non-zero R/G bytes in the shipped corpus, all at white start pixels. Only B (water) and the white starts carry data. The port header `R = relief, G = forest/stone` (`variant3d/scripts/mapgen.gd:3`) is a **PORT APPROXIMATION** inherited from prior research, not a property of the shipped masks.
5. **[O] Smoothing chain has three distinct stages**: (a) per-mask `SmoothTerrain(realx,-realy,False,3)` on `bsmooth` cells, (b) one land pass `_misc_SmoothTerrainCustom(1,4,0.5,0.01,100)`, (c) **three** coastal passes `_misc_SmoothTerrainCustom(1,0.35,0.5,-100,-0.01)` on cells with a mask-water neighbour in a clamped 5×5 (Chebyshev radius 2) window. The custom kernel is `h + ((avg_of_4_diagonals - h)/power)` then `Lerp(h,res,lerp)` ⇒ effective step coefficient `lerp/power` = **0.125 land, ≈1.428571 coastal** — the port's coastal `0.5` omits the division by `0.35`.
6. **[O] Water/shore thresholds verified** exactly: `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`, `cMaxHeight=2.96` (`texturemap.inc:29-31`), applied **only when `gMapMask[ix,iy].b>0`** (`texturemap.inc:68-75`). Start extraction is pure-white `fr=fg=fb=1`, deduplicated by coordinate, cleared to 0 before height decode; there is **no explicit minimum-distance rule** in mask extraction — spacing is authored into the mask, enforced indirectly by the `Xpl_` filename family filter, and team grouping uses nearest-neighbour selection later in `dogenerate.inc:999-1075`.

## 1. Evidence table

| Ref | Source (donor path:line / binary addr / evidence id) | Observation | Label |
|---|---|---|---|
| E01 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:1-50`, id `ev_0a09d5c4f21b8b28206ffa7e8ed61fb1c07977d4dff9e9aff3f3eaec0b72aa73` | `TerrainTypes[0..5].path`: nowater2 ("Land"), mediterranean, peninsulas, islands, continents, continent; `land` path commented out. `TerrainTypesDLC5[0..8]` adds coastal/lakes/rivers etc. | [O] |
| E02 | `data\gen\terrainmasks\moddersread.txt:1-10`, id `ev_4c82ba26d3eb2970c69e7fe7dd51b8e7b7728bcaf8d73e18c01a393f929ad9f0` | `Xpl_*_gauss.tga`, X = start-point count; `_gauss` = offline postprocess from `terrainmasks.src` via `PostProcessSaver` in `scripts\editor.aix`; 256²→320², "noised water borders"; 7pl required for up to 7 players. | [O] |
| E03 | `data\scripts\common.inc\dogenerate.inc:1542-1565` | `terraintype` → `TerrainTypes(5) / TerrainTypesDLC5(9)`; random type `floor(RandomExt*6|*gc_MaxTerrainTypeCount)`; `path` → `StringRegister0` → `ExecuteState('GenerateMap')`. | [O] |
| E04 | `generatemap.inc:159-208` (id `ev_6cda8d150b662b4a87cc54c5a5e849a3c97e0b2749ed1234bc68b9e98b7f42c2` covers 551-645; selection lines read via shell) | `folderpath := StringRegister0`; `ParserGetFilesInRoot(folderpath+'\*.tga')`; for `i:=plcount to 7` use `i+'pl*.tga'`; `rndind := floor(RandomExt*count)`. | [O] |
| E05 | `generatemap.inc:285-300, 302-394, 397-441` | `CreateBitmapTGA` vs `CreateBitmap`; `LoadBitmap`; `GetBitmapPixel` floats; scaling `floor(bitmapx/srcwidth*mapwidth)`; white detection; channel/terrain classification. | [O] |
| E06 | `generatemap.inc:4-38` (id `ev_2d298dd2ba7b3d3e7a6732a81c55546aa2892996e700e205e402cf8e636318d6`) | `cPlateauHeight=2.964`, `cHillHeight=2.964/2.25`, `cRavineHeight=-2.964`, `cWaterHeight=-1.1`; relief/water/forest colour codes; all 11 feature gates `True`. | [O] |
| E07 | `generatemap.inc:552-578`, id `ev_6cda8d150b662b4a87cc54c5a5e849a3c97e0b2749ed1234bc68b9e98b7f42c2` | `hwater := -1.1*(fb*(1+fr*3.5))`; class amplitudes × fr; `SetHeightData(hwater+hterrain)`; white-start skip only when `bRandomMap and fr=1 and fb=1`. | [O] |
| E08 | `generatemap.inc:218-245`, id `ev_2cd0004c9d109087aea981834a251d7dc2df6d1c04198e448b5943e8ef4311eb` | `_misc_SmoothTerrainCustom` exact body (4 diagonal neighbours, power/lerp, height-range gate). | [O] |
| E09 | `generatemap.inc:580-644`, same id as E07 | `SmoothTerrain(...,False,3)` on `bsmooth`; land pass `(1,4,0.5,0.01,100)`; 3 coastal passes `(1,0.35,0.5,-100,-0.01)`, radius `const rad=2`, `break(MAIN)`. | [O] |
| E10 | `data\scripts\common.inc\texturemap.inc:29-31, 66-75`, id `ev_694adcb828108c6bbc7d8f7b497a277b44e4494c58b86be3de764f98efa93952` | `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`; classification gated by `gMapMask.b>0`. | [O] |
| E11 | `data\scripts\common.inc\postprocess.inc:349-430, 437-441`, id `ev_67d271f20816e529e4166db7fec25c23491b598686f41e9b771537da85823587` | `BitmapGaussBlur` full kernel, quantization, `FindNearestTerrainType`, two radii 0.00001 / 0.925. | [O] |
| E12 | `scripts\editor.inc\postprocesssaver.inc:297-430, 472-601`, ids `ev_8485809805df438890d5e34c2cda5c1975dc77c0f2012c0fdf518769cba1afc4`, `ev_200e3149ec3d47a9f028e0f5fc27f6058febff1a77f5814467b3d0d6178fce11` | Fixed 320²; identical gauss procedure; radius-14 clear around white starts; re-add at `round(320*startx/256)`; save `<name>_gauss.bmp`. | [O] |
| E13 | `generatemap.inc:509-521` | Runtime `cPostProcessBitmapGaussian=True` → `ExecuteState('PostProcess')`, then `LoadBitmap(trgbitmap,'.\data\gen\bitmap\ext\bitmaptrg.bmp')`; for `bRandomMap`, `trgbitmap := srcbitmap` (`:529-533`). | [O] |
| E14 | `cossacks.exe` strings, ids `ev_59cfe17d…` (terrainmask=0), `ev_e98db75…` (`_gauss` bytes=0), `ev_f40477f…` (TRUEVISION=0), `ev_b5b5b3e…` (PostProcessSaver=0), plus `gauss`=1 → `.rsrc:0x958b19 XPHDRGaussShader` | No terrainmask/gauss-offline/TGA-footer strings in the native binary. | [O] |
| E15 | Python f32/f64 census of both binaries (temp script `d03_consts.py`; PE section table: CODE RVA 0x1000, RAW 0x400, .rsrc RVA/RAW 0x54c000/0x53d200) | `2.964/1.317/-2.964/3.5/0.35/0.925/2.57/-0.1`: **0** f32 and **0** f64 hits in both `cossacks.exe` and `editor.exe`; `-1.1f`: 2 hits each; `0.00001f`: 1 hit each. | [O]/[D] |
| E16 | `cossacks.exe:0x78bcbf`, ids `ev_d027c23e…` (function_find), `ev_b3163af…` (Deep study), `ev_dc7ecbd…` (Ghidra pseudocode), `ev_7db486b…` (builtin disassembly), `ev_de460b8…` (xrefs), `ev_f30dc08…`/`ev_cf584ba…` (callers/callees) | `c744241ccdcc8cbf mov dword [esp+0x1c],0xbf8ccccd` inside `sub_78b8a8`; function is a nearest-vector search; caller `sub_78ac04`; 100 callees; 0 xrefs to the immediate. | [O]/[D] |
| E17 | `data\gen\terrainmasks\land\4pl_mask_land_100_gauss.tga` header bytes `0x00..0x11`, footer last 26 bytes; Python RLE-24 decode ids `ev_c99fdb5…`, `ev_783ab62…` | Header `00 00 0a 00 … 40 01 40 01 18 00` = type 10 RLE, 24 bpp, 320×320, descriptor 0; footer `TRUEVISION-XFILE.\0`. Raw water triple `FF 00 00` in TGA BGR = B=255. | [O] |
| E18 | Full-corpus Python RLE decode of all `terrainmasks/**` (1,331 files; per folder: continent 121 Rnz=548, continents 187/703, islands 320/1046, land 230/966, mediterranean 118/538, nowater 42/212, nowater2 33/176, peninsulas 280/936) and all `terrainmasks.src/**` (1,279 files; 540/695/1038/910/546/156/928) | `Rnz = Gnz = white` in **every folder** — R/G non-zero only at white start pixels; B carries water and the blurred border gradient (e.g. land_100: B=255 on 10462 px, B=1 on 657 px, B=2 on 311 px). | [O]/[D, full census] |

**Finding ledger IDs recorded in the shared session:** `fnd_12` … `fnd_18` (D03-F1 … D03-F7); channel contradiction = `fnd_29` (D03-F8, sampled) and `fnd_33` (D03-F9, full-corpus confirmation). Shared-session IDs are not contiguous because other workers record concurrently.

## 2. Method and multi-pass acceptance

Sources: read-only Craft Anything native tools on `cossacks.exe` (deep mode) and `editor.exe`; `core_text_read` of donor `.cfg`/`.inc`/`.txt`; read-only Python byte decoding of donor TGA files and PE float scans. No donor binary was executed; no donor file copied into the repo; no repo source/asset/config/git edit.

**Mandatory multi-pass log (owner directive, 2026-11-26):**

| Contradiction / oddity | Pass 1 | Pass 2 | Pass 3 | Pass 4 | Acceptance reasoning |
|---|---|---|---|---|---|
| Port formula "exists in binary?" | `native_strings_find` for `relief/SmoothTerrain/SetHeightData/terrainmask` → 0 | `native_bytes_find` for `_gauss`, TRUEVISION → 0 | Python f32/f64 scan of both EXEs → distinctive constants = 0 | Donor text read (`generatemap.inc:567-574`) | Accept the **text** formula as [O]; accept "not a compiled native constant" as [D]; do **not** claim the text code runs (all lines `[*] = ;…`) ⇒ runtime [U]. Absence in binary is not proof of absence of behaviour, only of absence of those constants/strings. |
| A compiled `-1.1f` exists — is it the water constant? | `native_function_find(0x78bcc3…)` → `sub_78b8a8` | Deep `native_function_study` (68 blocks, 728 insns, 100 callees) | Ghidra `native_function_pseudocode`: `fStack_a0 = -1.1` used as initial comparison baseline in nearest-point loop; builtin `native_function_disassemble`: `mov [esp+0x1c],0xbf8ccccd` at `0x78bcbf` | `native_function_callers_list` (only `sub_78ac04`), `native_function_callees_list`, `native_xrefs_list` (0 refs to immediate) | **Refuted** as terrain water constant. It is a large-initial-distance/compare baseline in a vector nearest-neighbour routine. Same constant count in `editor.exe` and identical absent terrain constants = second-source agreement. |
| "R = relief, G = forest" from prior docs vs measured zeros | Python RLE-24 decode of `land/4pl_mask_land_100_gauss.tga` (R/G hist = {(0, 104396), (255, 4)}) | Raw-byte check: water triple `FF 00 00` → BGR ⇒ water in B, not mis-decoded channel order | Same decode on `terrainmasks.src` (256²) and dlc5/coastal/islands/med/nowater samples — R/G still zero except starts | Donor text: `postprocess.inc:42-50` raises *existing* terrain classes to R=255 but `gMapMask.terrain=cRNone` for R=0, so R stays 0; `moddersread.txt` describes water-only gauss masks | **Accept the contradiction**: shipped masks are water+starts only; relief/forest must be introduced by later stages (D05/D07/F01). Full-corpus census completed after the first draft and confirmed the result in every folder (E18). |
| `gauss` string exists (`XPHDRGaussShader`) — is that the mask blur? | `native_strings_find("gauss")` → single `.rsrc` resource string | `core_feature_find("XMapGenerator XTileSmooth")` → 0 functions | Location `0x958b19` in `.rsrc` (UI/shader resource area, same address in both EXEs), no xrefs to a blur | Donor blur code exists in text `postprocess.inc/postprocesssaver.inc`, not in binary | **Refuted** as relevant: resource name for a different shader, not terrainmask filter. |
| `0.00001f` exists in both EXEs — maybe the gauss first pass? | `native_bytes_find`/Python → 1 hit in DATA at file `0x4f4ec4` (cossacks), `0x629024` (editor) | No terrain strings near it; no caller study tying it to mask code | Donor uses `0.00001` only as the *script literal* at `postprocess.inc:437` | — | **UNVERIFIED [U]** whether that DATA float is the script constant cache; not used as evidence for the blur. |

Shared-session note: `core_target_open(editor.exe)` and `core_target_select(cossacks.exe)` were announced in-line; a later `core_session_show` showed the global active target had drifted back to `editor.exe` (another worker). All subsequent binary calls used explicit `document="t_87f0f3c130b0"`, so the evidence above is attributed correctly.

## 3. Findings

### 3.1 Load path and TGA decoder

**[O] Path chain** (`generator.cfg:1-50` → `dogenerate.inc:1542-1565` → `generatemap.inc:159-208`):

```pascal
pTerrainType := ParserSelectByHandleByIndex(pTerrainTypes, terraintype);
path := ParserGetValueByKeyByHandle(pTerrainType, 'path');   // dogenerate.inc:1560-1561
StringRegister0 := path; ExecuteState('GenerateMap');         // :1564-1565
// generatemap.inc
folderpath := StringRegister0;                               // :171
ParserGetFilesInRoot(folderpath+'\*.tga');                   // :174
for i:=plcount to gc_MaxPlayerCount-1 do begin
   ParserGetFilesInRoot(folderpath+'\'+IntToStr(i)+'pl*.tga');
   if (count>0) then break;                                  // :179-187 — first family with >= plcount starts
end;
rndind := floor(RandomExt*count);                            // :190
inputbitmap := ParserGetValueByIndexByHandle(pFileList, rndind); // :191
srcbitmappath := folderpath+'\'+inputbitmap;                  // :202
bTGA := True;                                                // :141 (else branch = random map)
if (bTGA) then srcbitmap := CreateBitmapTGA else srcbitmap := CreateBitmap; // :286-289
LoadBitmap(srcbitmap, srcbitmappath);                         // :290
GetBitmapSize(srcbitmap, srcwidth, srcheight);                // :292
```

**[O] Format**: donor files e.g. `terrainmasks\land\4pl_mask_land_100_gauss.tga` are 320×320, type 10 (RLE), 24 bpp, no colour map, descriptor 0 (BGR), `TRUEVISION-XFILE.\0` footer at file end. `terrainmasks.src` originals are 256×256; `moddersread.txt:6-10` documents the conversion and `_gauss` naming.

**[U] Native decoder identity**: no `CreateBitmapTGA`, `LoadBitmap` (DScript API), `.tga`, or `TRUEVISION` string/constant appears in either EXE; the import `LoadBitmapA` (GDI) is unrelated. The specific native function that decodes RLE TGA was **not anchored**. Attempted passes: strings on both targets, byte search, float scan, feature-find, xrefs. What would settle it: a pinned, data-driven xref from the DScript function-name registry or a debugger trace (forbidden here).

### 3.2 Channel → terrain quantity mapping

**[O] Authored semantics** (`generatemap.inc:19-32, 342-393`):

| Channel | Byte codes | Meaning in donor text |
|---|---|---|
| R | 255 / 191 = plateau (+smooth), 96 / 112 = hill (+smooth), 48 / 88 = ravine (+smooth), 64 = "smooth" flag w/o class | `terrain` class; `bsmooth := (ir in smooth code)`; `ir=floor(fr*255)`; else `cRNone`. Smooth codes are `(code div 2)+64` (`64 = 128 div 2`). |
| G | 255 forest, 64 generated forest, 128 stone, 192 forest+stone, 127 (=255 div 2) forest if class known | `forest` enum; else `cGNone`. |
| B | 255 water | `water := cBWater`; else `cBNone`. |
| alpha/`fa` | `fa>0` | `broad` flag. |
| all 0 or all 255 | — | `gPatternMask[x,y] := False` (no pattern stamping). |

**[O] Measured reality of shipped masks** (E18, full corpus): R and G are zero everywhere except the exactly `X` pure-white start pixels, in both 256² source and 320² `_gauss` outputs, in **all 8 shipped folders and all 7 source folders**. `[D]` Consequently for those files `gMapMask.terrain=cRNone`, `gMapMask.forest=cGNone`, `hterrain=0`, `forest=0`, and only B affects height. This is a **PORT APPROXIMATION flag**: the port's `mapgen.gd:3-6` header and `forest[i]=cg/255` are faithful to the *authored schema* but not to the shipped data. Relief and forest must come from other donor stages (D05/D07/F01/F08).

### 3.3 Gaussian blur / smoothing of the mask (offline postprocess)

**[O] `BitmapGaussBlur(bitmaptrg, w, h, r, bFinal)`** (`postprocess.inc:349-430`; identical copy in `postprocesssaver.inc:297-430`):

```pascal
cDoubleSQRR := 2*r*r;
rs := Round(r*2.57+0.5);
if rs<1 then ErrorLog('BitmapGaussBlur rs<1');
for i:=0 to h-1 do for j:=0 to w-1 do begin
   valR:=0; valG:=0; valB:=0; wsumR:=0; wsumG:=0; wsumB:=0;
   for iy:=i-rs to i+rs do for ix:=j-rs to j+rs do begin
      x := min(w-1, max(0, ix));  y := min(h-1, max(0, iy));  // CLAMP TO EDGE
      dsq := (ix-j)*(ix-j) + (iy-i)*(iy-i);                   // unbounded offsets
      wght := Exp(-dsq / cDoubleSQRR) / (PI*cDoubleSQRR);
      fr:=mask[x,y].r; fg:=mask[x,y].g; fb:=mask[x,y].b;
      valR+=fr*wght; wsumR+=wght;  valG+=fg*wght; wsumG+=wght; valB+=fb*wght; wsumB+=wght;
   end;
   resR := Round(255*valR/wsumR)/255;  // same for G,B
   resR := Clamp(resR,0,1);            // same for G,B
   maskTmp[j,i] := (resR,resG,resB);
end;
// second phase: for each pixel, ttype := gMapMask[j,i].terrain
//   else FindNearestTerrainType(j,i,rs);  water class from maskTmp.b*(255/255)
//   SetBitmapPixel(bitmaptrg,j,i,fr,fg,fb,1);
//   if bFinal then maskTmp[j,i].a := ttype;
if bFinal then for all pixels gMapMask[j,i].terrain := Round(maskTmp[j,i].a);
```

Key constants: **2.57** radius factor, **2r²** variance, `1/(PI·2r²)` normaliser (a true normal distribution, *then* renormalised by `wsum`), **8-bit quantisation via `Round(255·val/wsum)/255`**, `Clamp(0,1)`, clamp-to-edge sampling, inclusive window `2rs+1` squared.

**[O] Pass order / radii** (`postprocess.inc:437,441`; `postprocesssaver.inc:584,588`):

```pascal
PreprocessNoise;        // random border noise; constants below
PreprocessNoiseWater;
BitmapGaussBlur(bitmaptrg, width, height, 0.00001, False); // pass 1, rs=1
BitmapGaussBlur(bitmaptrg, width, height, 0.925,    True); // pass 2, rs=3, writes classes
```

`rs(0.00001) = Round(0.5000257) = 1` (donor comment `// 1`), `rs(0.925) = Round(2.87725) = 3`. Noise parameters in the same procedures: `cNoiseProb=0.5`, `cMinNoise=1`, `cMaxNoise=1`, `cMinDropPower=1`, `cMaxDropPower=3`, `cTryNoiseNearestProb=0.6`, `cTryNoiseNearestProbRecursive=0.99`, `cMaxDeep=10`, `cIsPlateauMin/Max=0.1/0.95`, `cIsWaterMin/Max=0.1/0.95`, `cPowerMinBreak/MaxBreak=0.1/0.9`. Full `PreprocessNoise*` recursion not decoded here → [U].

`FindNearestTerrainType(x,y,rad)` (`postprocesssaver.inc:225-251`): scan `j,i ∈ [-rad,rad]` where `(i=0) or (j=0)`, clamp coords, skip `cRNone`, pick the nearest non-None class by `VectorDistance` with strict `<` (first wins ties).

**[O] Where it runs**: `generatemap.inc:509-517` gates `cPostProcessBitmapGaussian=True` and calls `ExecuteState('PostProcess')` **only when `not bRandomMap`**; `:520` loads the already-produced bitmaptrg. `moddersread.txt` says the `_gauss` TGAs are produced in the editor from `terrainmasks.src`, not per skirmish map.

### 3.4 Relief formula — verification / refutation

**[O] Verbatim** (`generatemap.inc:4-7, 559-575`):

```pascal
const cPlateauHeight = 2.964;
const cHillHeight = cPlateauHeight/2.25;   // 1.317333…
const cRavineHeight = -2.964;
const cWaterHeight = -1.1;
...
fr := gMapMask[ix,iy].r;   fb := gMapMask[ix,iy].b;   // floats, 0..1
if (bRandomMap) and (fr=1) and (fb=1) then continue;   // start marker
hwater := cWaterHeight*(fb*(1+fr*3.5));
case gMapMask[ix,iy].terrain of
  cRPlateau : hterrain := cPlateauHeight*fr;
  cRHill    : hterrain := cHillHeight*fr;
  cRRavine  : hterrain := cRavineHeight*fr;
end;
SetHeightData(realx, realy, hwater+hterrain);
```

So the port's `h = -1.1*(cb/255)*(1+3.5*(cr/255)) + relief(cr)` is **arithmetically identical to the donor text** (with the port's `relief()` weighting class amplitude by `code/255`, matching `fr` only at exact codes). **[D] Refuted as a compiled native constant**: E15/E16. **[U]** not proven to execute in the shipped build (all donor code lines are `[*] = ;…`).

### 3.5 Height smoothing chain (numeric details)

**[O] `_misc_SmoothTerrainCustom(x,y,times,power,lerp,minh,maxh)`** (`generatemap.inc:218-245`):

```pascal
if power=0 then exit;
for i:=0 to times-1 do
 if (x>minx) and (x<mapwidth div 2) and (y>miny) and (y<mapwidth div 2) then begin
   lt:=GetHeightData(x-1,y-1); rt:=GetHeightData(x+1,y-1);
   lb:=GetHeightData(x-1,y+1); rb:=GetHeightData(x+1,y+1);
   h :=GetHeightData(x,y);
   if (h<>lt) or (h<>rt) or (h<>lb) or (h<>rb) then
   if (h>=minh) and (h<=maxh) then begin
     z1:=(lt+rt)/2; z2:=(lb+rb)/2;
     res := h + ((z1+z2)/2 - h)/power;
     res := Lerp(h,res,lerp);
     SetHeightData(x,y,res);
   end;
 end;
```

**Order** (`generatemap.inc:580-644`): (1) `SmoothTerrain(realx, -realy, False, 3)` for every `gMapMask[x,y].bsmooth` cell; (2) **one** land pass `custom(1,4,0.5,0.01,100)` **over the whole map**; (3) **three** coastal passes, each over `x,y ∈ [0,mapwidth]`, `custom(1,0.35,0.5,-100,-0.01)` only for cells where `gMapMask[nx,ny].water=cBWater` for any `nx,ny` in `Clamp(y±2,0,mapwidth-1) × Clamp(x±2,0,mapwidth-1)` (a clamped **square** 5×5, not Euclidean); (4) `TerrainUpdate(True,False)`. Note the commented-out negative land-range line `:607` — do not implement it.

**DERIVED effective coefficients**: `res = h + lerp·(avg-h)/power`, so land = `0.5/4 = 0.125`, coast = `0.5/0.35 ≈ 1.428571` (can overshoot beyond the 4-diagonal mean). No explicit clamp/round in this procedure (height is float); `GetHeightData/SetHeightData` precision is engine-side [U].

### 3.6 Water / shore thresholds

**[O] `texturemap.inc:29-31, 66-75`**: `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`; and:

```pascal
if (gMapMask[ix,iy].b>0) then begin
  if (height<cWaterHeight) then bWater:=True
  else if (height<cWaterShoreHeight) then bWaterShore:=True;
end;
```

Same literals re-used at `texturemap.inc:428-431, 466-469, 682-685, 858-861` and `dogenerate.inc:1576-1578`. **The mask-B gate matters**: a low height in a cell with B=0 is not classified water/shore. The coastal smoothing of §3.5 also keys off mask B, not off these height thresholds.

### 3.7 Start-marker extraction and spacing

**[O] Detection**: `fr=1 and fg=1 and fb=1` (`generatemap.inc:325`, `:413`; same in `postprocesssaver.inc:489`), i.e. pure white. Markers are **single pixels** in every shipped mask (full-corpus count of 5,125 white pixels = Rnz/Gnz, E18), because `PostProcessSaver:448-467` clears a radius-14 disc around each original white marker and `:590-596` writes one white pixel back at `round(320*startx/256), round(320*starty/256)`.

**[O] Dedup / spacing**:
- `srcwidth > mapwidth` branch (`generatemap.inc:329`): accept if `spInd=0` or the **immediately previous** accepted marker has different coordinates; otherwise skip. Not a full dedup.
- equal-size branch (`:417-435`): full `for i:=0 to spInd-1` comparison against all previously accepted markers (`bdubl`), then accept.
- On acceptance the pixel is zeroed (`:338-340`, `:440-…`) before `gMapMask` assignment, and `gPatternMask[x,y]:=False` for all-white/all-black cells (`:389-393`).
- **No explicit minimum-distance check exists in mask extraction** [O]. The count/family filter `i+'pl*.tga'` from `plcount` upward (`:179-187`) is the only mask-level "spacing/adequacy" rule. Later team placement (`dogenerate.inc:999-1075`, `GenerateTeamStartingPoints`) chooses the nearest unused `arrStartPos` to a picked team point — clustering logic, **not** a minimum separation. If a spacing rule exists elsewhere (e.g. `CreateStartPoint` keep-clear zones), it is outside D03's evidence → [U].

## 4. Reconstructed pipeline pseudocode (donor-faithful intent; **not** a runtime-equivalence claim)

```pascal
// 0. configuration / selection  (generator.cfg, dogenerate.inc:1542-1565, generatemap.inc:171-202)
folder := generator.TerrainTypes[terraintype].path;      // e.g. .\data\gen\terrainmasks\islands
files  := list(folder + '\*.tga');
for i := plcount to 7: if files_match(i+'pl*.tga') nonempty then break;
maskname := files[floor(RandomExt*count)];
bmp := CreateBitmapTGA(); LoadBitmap(bmp, folder+'\'+maskname);

// 1. analyse source pixels (generatemap.inc:302-441)
for each map cell (x,y): sample src at floor(x/mapwidth*srcwidth), floor(y/mapheight*srcheight);
  if (r=g=b=1): record start (dedup by rule above), set r=g=b=0;
  gMapMask[x,y] := class_from_R(floor(r*255)), forest_from_G(floor(g*255)),
                   water_from_B(floor(b*255)), bsmooth/broad;
  gPatternMask[x,y] := NOT(all_channels=0) AND NOT(all_channels=255);

// 2. offline/postprocess gauss (postprocess.inc / postprocesssaver.inc; editor-only for _gauss)
PreprocessNoise; PreprocessNoiseWater;
for pass in [(0.00001,False),(0.925,True)]: BitmapGaussBlur(target,320,320,pass.r,pass.final);
write single white start pixel per player; save <name>_gauss.bmp -> RLE TGA;

// 3. runtime height (generatemap.inc:552-575)
for y:=0..mapheight, x:=0..mapwidth:
  ix,iy := clamp(x,0,mapwidth-1), clamp(y,0,mapheight-1);
  if bRandomMap and r=1 and b=1: continue;
  hwater   := -1.1*(b*(1+3.5*r));
  hterrain := [2.964 | 1.317333 | -2.964 | 0] * r;   // by gMapMask.terrain
  SetHeightData(x,y,hwater+hterrain);

// 4. smoothing (generatemap.inc:580-644)
for cells with bsmooth: SmoothTerrain(x,-y,False,3);     // native kernel [U]
for all cells: custom(x,y,1,4,0.5,0.01,100);
repeat 3 times: for cells with mask-water in clamped 5x5:
                  custom(x,y,1,0.35,0.5,-100,-0.01);
TerrainUpdate(True,False);

// 5. classification (texturemap.inc:66-75)
if gMapMask.b>0: if height<-0.25 then water else if height<-0.1 then shore;
```

## 5. Implications for the port (all **PORT APPROXIMATION** unless cited as donor text)

1. **Do not treat imported `_gauss` R/G as relief/forest.** They are zero in shipped data; `variant3d/scripts/mapgen.gd:3-6` header overstates the schema. A donor-shaped pipeline must source relief from the relief stamp / pattern families (D05/F01) and forest/stone from resource placement (D07/F08), with mask B and white starts only from the masks.
2. **Fix the smoothing arithmetic, not just the pass count.** `mapgen.gd:226-235` computes `h + (avg-h)*0.5`; donor computes `h + Lerp(0, (avg-h)/power, 0.5)` ⇒ coastal coefficient `1/0.7 = 10/7 ≈ 1.4286`, land `0.125`. The current port's coast is ~3.5× too weak and has no land pass; it also varies pass count by quality (1/2/3) where the donor text uses exactly 3 coastal + 1 land.
3. **`SmoothTerrain(...,3)` on `bsmooth` cells is unimplemented in the port** (`mapgen.gd:87-94` intentionally exposes only the flag). Native kernel [U]; re-implementing it requires D06/D01 evidence, not invention.
4. **Offline gauss should be baked into converted assets, not re-run at load** if fidelity to shipped masks is the goal: donor `_gauss` TGAs already contain r=0.00001 + r=0.925 blur and the noise pass. If the conversion tool regenerates gauss, it must use `2.57`, `2r²`, clamp-to-edge, `Round(255·v/wsum)/255`, and the exact two radii.
5. **Start markers**: import one pixel per `Xpl_` marker; do not create blocks/rings. The port should reproduce the coordinate dedup rule and clear marker pixels before height decode (already at `mapgen.gd:199-201`, but note donor checks `fr=1,fb=1` only in the *height* skip, whereas extraction checks all three).
6. **Water/shore classification must be gated by mask B** (`texturemap.inc:68`), which the current port gate only approximates (`G26_water_shore.md:116`).
7. **Determinism contract**: mask choice consumes one `RandomExt` (`floor(RandomExt*count)`); seed replay must preserve that call position before all later RNG draws (D02).

## 6. Risks

- **Highest**: treating donor DScript text as executed runtime code. Every donor line is `[*] = ;…`; behaviour of the shipped build is **[U]** until a donor GPU A/B or an executed-script trace exists. This report deliberately says "donor-faithful intent", not "donor behaviour".
- Channel census is now full-corpus (E18), so risk of a hidden R/G-bearing shipped mask is low; DLC5 folders were sampled but not exhaustively counted (`terrainmasks.dlc5/**` shares the same gauss production path per `moddersread.txt`).
- Ghidra pseudo-C is a reading aid; `sub_78b8a8` identification rests on convergent deep study + clean-room lifter + bytes + xrefs + caller graph, not on a symbol.
- `Round`, `Lerp`, `Exp`, `PI` precision and `SetHeightData` quantisation are engine-side [U]; derived coefficients are exact rational arithmetic on donor literals, not measured runtime floats.
- Shared Craft Anything session: global target changed mid-session; all evidence attributed with target IDs above, but other workers' concurrent calls could affect un-pinned results (later calls were pinned).

## 7. UNVERIFIED register [U]

| ID | Question | Passes attempted | What would settle it |
|---|---|---|---|
| U1 | Native RLE-TGA decoder / `CreateBitmapTGA` function in `cossacks.exe` | strings ×2 binaries, byte search TRUEVISION/_gauss, function-name search, xrefs | DScript API registry xref or allowed dynamic trace |
| U2 | Do the `;`-prefixed donor generator scripts actually execute in the shipped game? | text reads of all relevant `.inc`, prior reports A08/H06/DTRN-01 flags | donor runtime trace / disassembly of script-loader path (not performed) |
| U3 | Native `SmoothTerrain(x,-y,False,3)` kernel | text call sites, strings | decompile the DScript native handler |
| U4 | ~~Full-corpus R/G zero census~~ **RESOLVED**: all 1,331 shipped + 1,279 source masks have `Rnz=Gnz=white` (E18) | `d03_census.py` completed; per-folder counts in E18 | — |
| U5 | Whether the single `0.00001f` DATA constant is the script literal cache | byte scan both binaries, no xref study | xref / data-type study |
| U6 | Exact `Round` tie behaviour (`rs=1` for 0.5000257) and `Lerp` precision | donor comment `// 1`, arithmetic check | engine math routine decompile |
| U7 | Whether a hard start-spacing rule exists outside mask extraction | `dogenerate.inc` start-point search read | search `CreateStartPoint` keep-clear zones (D07 scope) |
| U8 | TGA bitmaps actually shipped under `data/gen/bitmap/**` vs generated `ext/bitmaptrg.bmp` connection | directory listing + `generatemap.inc:520-521` | inspect `ext/` contents and its provenance |

## 8. Open questions

1. If shipped masks are water-only, what exact stage supplies `gMapMask.terrain` classes (and hence `hterrain`) for a random map: the offline `PostProcess` bitmap, or a later relief stamp? → D05/F01.
2. Does `bRandomMap` use `srcbitmap` directly as `trgbitmap` (`generatemap.inc:529-533`) with no gauss at all, making the shipped `_gauss` files an editor-only convenience? → reconcile with F03/F04.
3. What is the true `gc_MaxTerrainTypeCount` (9 for DLC5?) and how does the DLC setting alter the mask family filter? → F03/F10.
4. ~~Are there donor masks with non-zero R/G?~~ **Answered for shipped data** (E18: no). Remaining variant: custom/modded `terrainmasks.src` sets or DLC5-only folders not exhaustively counted → F04.
5. Can the two EXEs' shared `.rsrc` string table be tied to the DScript function registry to finally anchor `CreateBitmapTGA`/`LoadBitmap` natively? → D01.

*End of D03 report. No donor binary executed, no donor file copied into the repo, no source/asset/git edit, no donor-parity claim.*
