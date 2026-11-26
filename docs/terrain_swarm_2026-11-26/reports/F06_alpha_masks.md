---
id: F06
task: "Decode donor alpha / alphavert / bmTransparency mask system exactly"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTED__NO_DONOR_BINARY_COPIED
scope: "Analysis only. One report file written. Donor at C:\Games\Cossacks 3 read-only (bytes + Pillow/numpy + text); no donor binary run, copied or committed; no source/shader/asset/test/git edit; no Godot runner job."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY)"
owner_file: "docs/terrain_swarm_2026-11-26/reports/F06_alpha_masks.md"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
evidence_ids: [F06-E1..F06-E18]
donor_parity_claim: false
---

# F06 — Donor alpha / alphavert mask system

## 0. Executive summary

1. **[O] The donor mask system is one HeightField shader with TWO sampler inputs and ONE fragment output alpha — not a shader-side blend.** `hf.pvl.smx3.frag:13-17` reads RGB from `texUnit0`, reads mask intensity into `color.a` from `texUnit1`, multiplies RGB by packed lighting, and writes `gl_FragColor=color` at `:50`. `hf.pvl.sm.vert:34` passes the mask UV straight through as `gl_TexCoord[1] = gl_MultiTexCoord1`. There is **no** mask arithmetic, neighbour fetch, threshold or blend equation in any donor shader source.
2. **[O] The blend is fixed-function `BlendingMode = bmTransparency`** (`reftile.mat:6,17`; `reftilealpha.mat:17,126,235`). `bmTransparency` is enum index **1** in the RTTI enum at `cossacks.exe:949234` (family `bmOpaque`=0, `bmTransparency`=1, `bmAdditive`=2, `bmAlphaTest50`=3, `bmAlphaTest100`=4, `bmModulate`=5). Exact GL blend factors and the number of fixed-function passes are **UNVERIFIED** — no readable donor source carries them (RV-TRN-01 verdict D; 46 text hits, all enum/`BlendingMode =`).
3. **[O] `alpha.bmp` is 512×256, 8 bpp indexed (data @1070), and really is 8 columns × 4 rows of 64² patches** — 32 patches; seam jumps only at x/y multiples of 64. The commented `AlphaRows=8 / AlphaCols=4 / AlphaTileSize=64` (`reftile.lib:10-12`) has row/col labels transposed relative to the pixel grid. Exactly four patches are constant: `(0,0)`/`(4,0)` = 255 and `(3,3)`/`(7,3)` = 0.
4. **[O] `alphavert.bmp` is a different animal:** 1024×512, 24 bpp near-grey RGB, sampled by **eye-linear projection** on cliff refkeys `verticalfront`/`verticalside` with `TextureScale=0.125` and donor planes S=X/T=Z (front), S=Y/T=Z (side) (`reftile.mat:120-169`). It is not a 64² patch atlas and is not used for flat ground.
5. **[O] `alphanull.bmp` is an all-zero 512×256 8 bpp mask bound to exactly three donor tile ids — `alpha0a` (86), `alpha0b` (110), `alpha0c` (123)** (`tiles.mat:346-359`; ids from `terrain.presets`). **[D/PORT APPROX] The port's 8 "constant-zero ids" (15, 31, 47, 63, 64, 80, 96, 112) are an artifact of the port's `id mod 64` patch decomposition, not a recovered donor rule**; the current shader neutralises them at `:419`.

**No donor parity or visual A/B is claimed.** Labels: **[O]** observed byte/pixel/source, **[D]** derived arithmetic, **[I]** inference, **[U]** UNVERIFIED.

---

## 1. Evidence register

| ID | Evidence (donor path:line/offset unless marked port) | Label |
|---|---|---|
| **F06-E1** | `data\terrain\ref\reftile.mat:6` `Texture2Name = alpha`; `:17` `BlendingMode = bmTransparency`; `:18` `FaceCulling = fcCull` | [O] |
| **F06-E2** | `data\terrain\ref\reftilealpha.mat:17,126,235` = `bmTransparency` on `alpha`, `alphavert`, `alphanull` materials | [O] |
| **F06-E3** | `data\terrain\ref\reftilealpha.mat:30-37`: `image=…\alpha.bmp`, `imagealpha=tiaAlphaFromIntensity`, `magfilter=maNearest`, `minfilter=miNearest`, `mappingmode=tmmUser`, `textureformat=tfAlpha`, `texturemode=tmModulate`, `twBoth`, S/T=(1,0,0,0) | [O] |
| **F06-E4** | `data\shaders\obj\hf.pvl.smx3.frag:13-14,17,50` (quoted §4); `hf.pvl.smx9.frag:13-14,17,55` identical mask lines | [O] |
| **F06-E5** | `data\shaders\obj\hf.pvl.sm.vert:34` `gl_TexCoord[1]=gl_MultiTexCoord1;`; `:30-32` texGen only for `gl_TexCoord[0]` | [O] |
| **F06-E6** | `data\shaders\shaders.lib:16-51` (SM20 HeightField) / `:914-950` (SM30): `texUnit0`→unit 0, `texUnit1`→unit 1, `texGen=true`, `tangentSpace=false` | [O] |
| **F06-E7** | `data\terrain\tiles\textures\alpha.bmp` header at bytes 0..53: `BM`, DIB40, **512×256, 8 bpp, BI_RGB, data offset 1070, 254 declared palette colours**; palette at 54..1069 | [O] |
| **F06-E8** | Pillow/numpy decode of E7: palette `B=G=R`, fourth byte 255 for indices 0–253, 0 for 254/255; index→intensity `0..3→0`, `i∈[4,253]→i−3`; max index used 253; 23,658 pixels index 0, 39,427 index 253, 254/255 unused | [O] |
| **F06-E9** | Seam deltas (mean abs neighbour difference, top-left-origin array): `x=63|64:126.70`, `127|128:64.33`, `191|192:184.83`, `255|256:184.83`, `319|320:126.94`, `383|384:64.27`, `447|448:183.09`; `y=63|64:123.34`, `127|128:121.77`, `191|192:192.56`; interiors ≲1 | [O] |
| **F06-E10** | 32 patch means/min/max/std/zeros/255s computed from E7; table §3.2. Four constant cells verified | [O] |
| **F06-E11** | `data\terrain\tiles\textures\alphavert.bmp` header: DIB40, **1024×512, 24 bpp, data @54**; Pillow RGB. Mean R/G/B = 77.3761/77.3756/77.3756; `R==G` 94.28 %, `G==B` 94.25 %; max |R−G|=12, |G−B|=13, |R−B|=15; 56.32 % pixels =0, 16.41 % =255 | [O] |
| **F06-E12** | `data\terrain\ref\reftile.mat:120-169`: `verticalfront`/`verticalside` → `Texture2Name=alphavert`, `TextureScale=0.125`, `mappingmode=tmmEyeLinear`; front S=(1,0,0,0) T=(0,0,1,0) (`:130-141`), side S=(0,1,0,0) T=(0,0,1,0) (`:156-167`) | [O] |
| **F06-E13** | `data\terrain\tiles\tiles.mat:142-148` face tiles reuse base rock art (`rock1vf/vs` → `rock1.dds`); `:346-359` `alpha0a/b/c` → `Texture2Name=alphanull` | [O] |
| **F06-E14** | `data\terrain\tiles\textures\alphanull.bmp` bytes 0..25: BITMAPCOREHEADER (12 B), 512×256, 1 plane, 8 bpp, data @794; all pixel indices 0, converted L unique = {0} | [O] |
| **F06-E15** | `cossacks.exe:949234`: length-prefixed enum names `bmOpaque`, `bmTransparency`, `bmAdditive`, `bmAlphaTest50`, `bmAlphaTest100`, `bmModulate`; copies at `:953108`, `:4711020`. `glBlendFunc`/`glBlendFuncSeparate` are imported (`:737376`, `:741792`, `:741808`) but no factor table tied to the enum | [O] + [U] for factors |
| **F06-E16** | `data\terrain\ref\reftile.lib:3-6` `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`; `:10-12` commented alpha geometry. RTTI field names at `cossacks.exe:1323550,1323586,1323622` | [O]; arithmetic [U] |
| **F06-E17** | Recursive text scan: `bmTransparency` appears **only** in `reftile.mat:17`, `reftilealpha.mat:17,126,235`, `decals*.mat:17` and four unrelated script effect lines (`data\scripts\lib\unit.script:6760` etc.). **Zero** occurrences in `data\shaders\**`. No blend-factor/pass-count table | [O] (absence) |
| **F06-E18** | PORT: `variant3d\shaders\terrain_tileindex.gdshader:365-378` id→patch; `:397-419` face/flat mask; `:427` `rgb = rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular`; `:475` `ALPHA=1.0`; `world3d_terrain.gd:662-675` R→A repack; `:1332-1350` face promotion | [O] (port) |

---

## 2. Inventory and exact material/shader chain

### 2.1 Every `bmTransparency` carrier relevant to terrain [O]

```
data\terrain\ref\reftile.mat:6       Texture2Name = alpha
data\terrain\ref\reftile.mat:17      BlendingMode = bmTransparency
data\terrain\ref\reftilealpha.mat:17      (alpha material)
data\terrain\ref\reftilealpha.mat:126     (alphavert material)
data\terrain\ref\reftilealpha.mat:235     (alphanull material)
```

No `bmTransparency` string exists anywhere under `data\shaders\**` (F06-E17): the mode is **material state consumed by the engine**, not shader code. The four `data\scripts\**` hits are effect behaviour (`SetBehaviourIntProperty(effHnd, 'BlendingMode', 1); // bmTransparency`) for units/balloons, not terrain.

### 2.2 The donor fragment math, quoted verbatim [O]

`data\shaders\obj\hf.pvl.smx3.frag` (SM20 profile selected at `shaders.lib:17-18`; SM30 twin at `:917` + `hf.pvl.smx9.frag`):

```
13:    color.rgb=texture2D(texUnit0, gl_TexCoord[0].xy).rgb;
14:    color.a=texture2D(texUnit1, gl_TexCoord[1].xy).a;
16:    // lighting operations
17:    color.xyz=color.xyz*gl_TexCoord[4].xyz+gl_TexCoord[5].xyz;
...
50:    gl_FragColor=color;
```

`data\shaders\obj\hf.pvl.sm.vert`:

```
30:       gl_TexCoord[0].s=dot(realpos, gl_EyePlaneS[0]);
31:       gl_TexCoord[0].t=dot(realpos, gl_EyePlaneT[0]);
32:       gl_TexCoord[0]=gl_TextureMatrix[0]*gl_TexCoord[0];
34:    gl_TexCoord[1]=gl_MultiTexCoord1;
```

**Consequences [O/D]:** only `gl_TexCoord[0]` is texGen-driven; the mask coordinate comes from the mesh's texture-coordinate channel 1. The shader never reads a neighbour tile, never thresholds `color.a`, and never mixes two RGB samples. The only numeric threshold in the whole shader is the **shadow** test `r<0.999` (`:26-28`); it is unrelated to the mask. `texUnit0`/`texUnit1` are bound to units `0`/`1` at `shaders.lib:34-49` (SM20) and `:933-948` (SM30).

### 2.3 Where the seam blend actually happens [D/I, exact factors U]

**[D] Structural conclusion:** the mask value written to `gl_FragColor.a` is a **coverage weight**; the combination of an already-drawn base tile with the current textured tile is performed by the fixed-function blender selected by `bmTransparency`. This explains why the donor can feather a seam between two neighbouring tile ids with one fragment program and one mask sample. The enum name `tsDouble` (`reftile.lib:3`, RTTI `cossacks.exe:1322769`) supports a two-tile scheme but its arithmetic is **UNVERIFIED**.

**[I, DO NOT TREAT AS DONOR TRUTH] Conventional src-alpha form** would be `src.rgb * src.a + dst.rgb * (1 - src.a)`, but **no donor literal recovered it**. `bmAlphaTest50`/`bmAlphaTest100` exist as *separate enum values* at `cossacks.exe:949234` (indices 3 and 4); the terrain selects index 1, so those 50/100 alpha-test thresholds are **not** used here [O].

**Pass count [U]:** one compiled shader program / one fragment invocation per fragment with two samplers is [O]; the number of fixed-function *draw passes* that `bmTransparency` emits is **CONFIRMED_UNVERIFIED** (no pass-count table in 16k-file scans; packed `.bind`, entropy 7.96 — RV-TRN-01 verdict D, DTRN-01 M7). Do not encode "two passes" or "one pass" as donor fact.

---

## 3. `alpha.bmp`: grid, packing, representative pixels

### 3.1 Header / channel packing [O]

- `alpha.bmp` = **512×256**, BITMAPINFOHEADER (40 B), **8 bpp**, BI_RGB, **pixel data @ byte offset 1070**, 254 declared palette entries (256 slots × 4 B = 1024 B).
- Palette entries are grey: `(B,G,R,0..253)` = `(v,v,v,255)`; entries 254/255 have fourth byte 0.
- Measured index→intensity: `0,1,2,3 → 0`; `4 → 1`; …; `253 → 255` (i.e. `v = max(0, index−3)` for used indices). Highest index present = **253**; **254 distinct indices**; index 0 occurs 23,658 times, index 253 occurs 39,427 times; indices 254/255 never occur.
- **There is no multi-channel packing**: the mask is a single 8-bit intensity, converted by the donor material via `imagealpha=tiaAlphaFromIntensity`, `textureformat=tfAlpha` (`reftilealpha.mat:31,35`). The exact `tiaAlphaFromIntensity` function is engine-side **[U]**.

### 3.2 Grid proof and all 32 patch statistics [O]

512/64 = 8 columns, 256/64 = 4 rows. Neighbour-difference seams occur **only** at x ∈ {64,128,192,256,320,384,448} and y ∈ {64,128,192} (F06-E9), confirming 64² patches. (The commented labels `AlphaRows=8, AlphaCols=4` are transposed: 8 across, 4 down.)

Patch `(c,r)` = x∈[64c,64c+64), y∈[64r,64r+64), top-left origin (BMP rows stored bottom-up; Pillow flips).

| row | c0 | c1 | c2 | c3 | c4 | c5 | c6 | c7 |
|---|---|---|---|---|---|---|---|---|
| r0 | **255.0** /0/0 | 52.3 /0.355 /0.034 | 50.5 /0.339 /0.056 | 132.4 /0.122 /0.321 | **255.0** /0/0 | 77.7 /0.394 /0.071 | 72.7 /0.407 /0.088 | 154.1 /0.227 /0.333 |
| r1 | 56.5 /0.448 /0.056 | 136.3 /0.169 /0.268 | 157.9 /0.098 /0.105 | 213.5 /0.048 /0.578 | 58.3 /0.390 /0.027 | 157.7 /0.210 /0.382 | 180.1 /0.095 /0.270 | 206.4 /0.049 /0.312 |
| r2 | 45.6 /0.349 /0.049 | 153.5 /0.075 /0.086 | 134.2 /0.150 /0.268 | 210.0 /0.045 /0.630 | 82.8 /0.374 /0.052 | 174.5 /0.111 /0.271 | 143.1 /0.235 /0.229 | 199.9 /0.060 /0.473 |
| r3 | 136.9 /0.149 /0.334 | 210.1 /0.051 /0.640 | 216.4 /0.049 /0.622 | **0.0** /1.000 /0 | 152.2 /0.203 /0.252 | 196.7 /0.061 /0.412 | 203.3 /0.054 /0.408 | **0.0** /1.000 /0 |

Entries are `mean / fraction==0 / fraction==255`; all non-constant patches span min 0 … max 255 and hold 234–251 distinct levels (consistent with DALPHA-01 §3.2). The four constant cells are `(0,0)`, `(4,0)` = all 255 and `(3,3)`, `(7,3)` = all 0.

### 3.3 Actual pixels: 16×16 ASCII of representative cells [O]

Downsampled by 4×4 block means. Ramp `chars = " .:-=+*#%@"`: space ≈0 … `@` ≈255.

**(0,0) constant 255** — `mean=255.0, std=0`:
```
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
```

**(3,3) constant 0** — `mean=0.0, std=0` (same for (7,3)):
```
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
```

**(2,0)** — `mean=50.5, std=86.3, frac0=0.339, frac255=0.056`; the graded cell with the closest 180° complement. Dark upper-left corner, bright lower-right → "NW corner" role [D]:
```
                
                
                
                
                
                
  ..            
::::            
*++-..          
%%#+:.          
@@%*=:..        
@@@#*==:.       
@@@%%#*=-.      
@@@@@@%*=:      
@@@@@@@*-.      
@@@@@@@*:       
```

**(0,1)** — `mean=56.5, std=90.2, frac0=0.448`; dark LEFT edge, bright right → "full W edge" role [D]:
```
       :*%@@@@@@
     ..:+%@@@@@@
    .:-+#%@@@@@@
    ..-+*%@@@@@@
     .:-+*#%%@@@
       .:-+#%%@@
        ..:=*#%%
         ..:=+**
           .:--:
            ... 
                
                
                
                
                
                
```

**(3,0)** — `mean=132.4, std=112.7, frac0=0.122, frac255=0.321`; dark TOP half, bright bottom → "full N edge" role [D]:
```
                
                
                
                
            ..  
  .:.     .:.:  
  :-......:---  
:-==-::----==+-:
*##**=++***####*
@@@%%#%%%%%@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
```

**(0,3)** — `mean=136.9`; mirror in y of (3,0), "full S edge" [D]:
```
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@
@@%%%%@%@###%@@@
*###+####*==**#*
:-=+=+*+=-::-*=:
 .:-=-+=: ..:=: 
  .:---:.  .:-. 
   .:...    ..  
    ..          
                
                
                
```

**(1,2)** — `mean=153.5, std=89.9`; organic lobes with no single dominant edge, illustrating why per-cell repetition reads as blotches [O]:
```
@@@@@@@*-       
@@@@@@@%+-.     
@@@@%%##*=:.    
@@@%####*-:.    
@@@%###**=-..   
@@@@#####*=-:.. 
%@@@%%###**+--:.
**%%%%%%%##*+==-
-=*#%@@@%%#*****
.:=*%@@@%%##%%%%
 .-+#%%%%##%%%@@
  :=+**####%%%@@
  .:-=+*#*##%%%@
   .:-=*#%%%%%%@
    .:-*%@@@@@@@
       -*@@@@@@@
```

### 3.4 Complement structure, recomputed here [O/D]

Mean absolute error of `255 − (A+B)` for the 180°-rotated partner inside the same 4-column half:

- Left half: `(2,0)+(1,3)` **9.77**, `(0,2)+(3,1)` **9.91**, `(0,1)+(3,2)` **13.83**, `(1,0)+(2,3)` **15.81**, `(3,0)+(0,3)` **17.64**; the sentinel pair `(0,0)+(3,3)` = **0.00**.
- Right half: only the sentinel `(4,0)+(7,3)` = 0.00; graded partners range **26.06 … 104.50** (e.g. `(5,0)+(6,3)` 37.56, `(5,2)+(6,1)` 104.50).

**[D] Conclusion:** exact complementarity exists only for the four constant pairs; graded masks are approximate, and the left half is markedly more complementary than the right. Derived row semantics (darkest edge → N/W/E/S for rows 0/1/2/3) match DALPHA-01 §3.4; the tiles themselves do not encode a donor row enum **[U]**.

---

## 4. `alphavert.bmp` and cliff faces

### 4.1 Pixels [O]

- Header: DIB40, **1024×512, 24 bpp**, data @54, near-grey RGB (F06-E11).
- Channel means essentially identical (77.3761 / 77.3756 / 77.3756); 94.28 % of pixels have R=G and 94.25 % have G=B; max channel differences ≤15. The conversion to one 8-bit intensity (port `build_tile_index_atlas.py:242-250`) discards that ≤15 difference **[D]**.
- Histogram bins of 32 (0–31 … 224–255): `327699, 12446, 11498, 11220, 12250, 14484, 16997, 117694` — bimodal: **56.32 % exactly 0**, **16.41 % exactly 255**, mean 77.38, std 107.16.
- 32×16 ASCII of the whole image (same ramp) shows a repeated motif with ~512 px horizontal period and four vertical bands, with hard 0/255 plateaus:
```
@@@@            @@@@            
@@@@            @@@@            
@@@@        .   @@@@            
@@@@   --   #***@@@@   --   ****
   -   * .*@  .#   -  .# .*@   *
       *:#@%  -%       %:%@%  :%
       *#@#: -#@       #%@*: -*@
       +@=. #%@@       *@=. +#@@
=   #-  +   +   +   %-  +   =   
    *@+.=   %:      *@*.*.  #:  
    .*@++   %#-.    :#@+#.  @+. 
      +@+   @@%#      +@*.  @@%#
%%###@@@@@@%    #*+*#@@@@@@%    
 .  .=%@@%+:        .+%@@%*:    
      -%@=.           =%%=.     
      .*#:             **.      
```
- Large column jumps at x≈128/256/512/768/896 (e.g. `127|128:95.97`, `511|512:155.76`, `895|896:122.34`) and `127|128:136.14` in y, but **no uniform 64² seam lattice** like `alpha.bmp` — consistent with a projected continuous mask, not a patch atlas **[O/D]**.

### 4.2 Donor cliff-face binding [O]

`reftile.mat:120-144` (`verticalfront`) and `:146-170` (`verticalside`) are refkey overrides that set `Texture2Name = alphavert`, `TextureScale = 0.125` in X/Y/Z, `mappingmode = tmmEyeLinear`, and planes:

```
front:  S=(1,0,0,0)  T=(0,0,1,0)   (reftile.mat:130-141)
side:   S=(0,1,0,0)  T=(0,0,1,0)   (reftile.mat:156-167)
```

(Quoted verbatim: side `mappingscoordinates X=0, Y=1, Z=0, W=0`.) Donor world is Z-up, so T is height. `tiles.mat:142-148` confirms face tiles reuse the **same base rock DDS** as the flat cliff tile (`rock1vf`/`rock1vs` → `rock1.dds`) — the face refkey changes the *mask projection*, not the RGB art. Winter faces follow the same pattern (`tiles.mat` 18 `verticalfront` + 18 `verticalside` sections; DALPHA-01 §2.3).

### 4.3 Port approximation for faces [O/PORT APPROX]

`terrain_tileindex.gdshader:404-407` computes `mask_uv = (face==1) ? vec2(v_eye.x, v_eye.y)*0.125 : vec2(v_eye.z, v_eye.y)*0.125` and samples `alphavert_atlas.a`. The `0.125` and the choice of X/Y vs Y/Z are donor-grounded structure; the **donor Z-up → Godot Y-up axis swap, the omission of `gl_TextureMatrix[1]`, and the use of eye-space `v_eye` are PORT APPROXIMATION** (shader comment `:400-403`). `world3d_terrain.gd:1332-1350` promotes slope cells to face 1/2 and selects `rockNvf/vs` names, also labelled PORT APPROX (`:1337-1339`).

---

## 5. Sentinel / zero-mask tile ids

### 5.1 Donor-faithful zero mask [O]

`tiles.mat:346-359` sets `Material.Texture2Name = alphanull` for exactly three sections: `alpha0a`, `alpha0b`, `alpha0c`, all using `grass1.dds` as RGB. `alphanull.bmp` is all-zero (F06-E14) and its material is `bmTransparency` (`reftilealpha.mat:235`). In the shipped preset order those are **tile ids 86, 110 and 123** (`terrain.presets` / `variant3d/assets/terrain/structs/presets_summer.json` index 86/110/123; DALPHA-01 §2.2 lib idx 86/110/244). This is the only donor tile-id→zero-mask association recovered from readable data.

The atlas cells `(3,3)`/`(7,3)` being constant 0 is [O]; **interpreting them as "full cut" and `(0,0)`/`(4,0)` as "no transition" is [I]**, not a recovered tile mapping (DALPHA-01 §6.4 / §8 Q4).

### 5.2 Port's id-derived sentinel selection [PORT APPROXIMATION]

`terrain_tileindex.gdshader:365-378` decomposes the single per-vertex `UV2.x` tile id (no neighbour id exists in the port mesh):

```
id = floor(abs(tile)); dir=id%4; variant=(id/4)%4;
half=(id/16)%2; opposite=(id/64)%2;
row = mix(dir, 3-dir, opposite);
variant = mix(variant, 3-variant, opposite);
cell = (half*4+variant, row); uv = (cell + clamp(local,1/128,127/128)) / (8,4);
```

Applying this to the 124 donor preset ids (port `presets_summer.json`, donor `terrain.presets:2-6`) yields **[D]**:

| Port cell | Count | Ids → donor name |
|---|---:|---|
| `(3,3)`/`(7,3)` constant **0** | **8** | 15 `grass_ground2`, 31 `sand6`, 47 `sand7f`, 63 `rock6vf`, 64 `rock6vs`, 80 `test9`, 96 `sandsea4`, 112 `desert2` |
| `(0,0)`/`(4,0)` constant **255** | **7** | 0 `grass1`, 16 `grass_ground3`, 32 `sand7`, 48 `sand7s`, 79 `test8`, 95 `sandsea3`, 111 `desert1` |

These are **PORT APPROX** ids only: **[U]** no donor evidence maps any of them to a constant patch. Note also that ids 63/64 are face tiles: when `world3d_terrain.gd:1332-1350` promotes a cell to face 1/2, the shader takes the `alphavert` branch (`:397-407`) and never samples the `alpha` sentinel — so the previously warned "black cliff faces via sentinel" (A02 §2) is **not** predicted for promoted face cells in the current shader **[D]**.

The current guard at `:419` is:

```
a = mix(mix(1.0, clamp(a, 0.35, 1.0), 0.5), 1.0, step(2.5, scol)*step(2.5, srow));
```

**[D]** For non-sentinel cells the effective factor is confined to **[0.675, 1.0]**; for the 8 sentinel ids it is **1.0**. Neither the 0.35 floor, the 0.5 strength, nor the `step(2.5,…)` test has a donor counterpart — all are **PORT APPROX** (A02-P1/P4). The donor authored graded masks reach 0 exactly (e.g. (2,0) has 33.9 % zero pixels); the port can no longer express a full cut on flat ground.

---

## 6. Donor-faithful vs PORT APPROXIMATION

| Aspect | Donor (label) | Port (label) |
|---|---|---|
| Mask carriers | 3 BMPs, 3 `bmTransparency` materials; `alpha` bound via `Texture2Name` on base material [O] | 3 PNGs (L mode), bound to 3 samplers in one `ShaderMaterial` [O] |
| Mask colour space | `alpha.bmp` 8 bpp palette intensity; `alphavert.bmp` 24 bpp near-grey; `tiaAlphaFromIntensity`→`tfAlpha` [O]; exact formula [U] | `im.convert("L")` (`build_tile_index_atlas.py:242-250`) then R→A repack (`world3d_terrain.gd:662-675`) — **PORT APPROX** for channel choice and formula |
| Sampling geometry | 8×4×64² patch atlas for `alpha`; eye-linear projection for `alphavert` [O] | 64² sub-rect UV `((c+u)/8,(r+v)/4)` for `alpha` [DONOR-GROUNDED]; eye-linear-like face UV [PART APPROX] |
| Per-patch UV source | engine-written `gl_MultiTexCoord1` (`hf.pvl.sm.vert:34`) [O]; rule [U] | id bits `mod 4 / /4 / /16 / /64` + 180° mirror; `fract(v_alpha_uv)` phase — **PORT APPROX** |
| Mask input to fragment | `color.a = texture2D(texUnit1,…).a`, framebuffer alpha written [O] | `.a` sampled then **folded into RGB** at `:427`, final `ALPHA=1.0` at `:475` — **PORT APPROX** |
| Seam blend | fixed-function `bmTransparency` over base tile; factors/pass count [U] | one `blend_mix`, opaque terrain, no second base-tile pass — **PORT APPROX** |
| Thresholds | **none** on mask in donor shader; `bmAlphaTest50/100` are unused sibling modes [O] | `clamp(a,0.35,1.0)`, `0.5` strength, `step(2.5,…)` sentinel guard, `mask_to_alpha` knob — **PORT APPROX** |
| Filtering | `maNearest`/`miNearest`/`twBoth` on both masks [O] | `filter_nearest, repeat_enable` on both mask samplers — faithful intent [O] |
| Sentinel roles | constant cells exist [O]; semantic roles [I] | 8 constant-0 ids / 7 constant-255 ids; guard neutralises zero — **PORT APPROX** |

---

## 7. Implications for the donor-first port

1. **Spec/toolchain:** convert `alpha.bmp` to one 512×256 L intensity PNG preserving the exact index→intensity mapping (`max(0, idx−3)`), keep the 4 constant cells byte-exact; convert `alphavert.bmp` to 1024×512 L but record the ≤15 inter-channel spread as lost information. Do not invent a tile→patch table — keep it labelled APPROX until D08 binary work resolves `gl_MultiTexCoord1`.
2. **Fresh terrain module:** the donor's stage order is "engine mesh builder writes two UV sets and per-tile refkey → one HeightField fragment writes RGB+mask alpha → fixed-function blend". A faithful module therefore needs a **neighbour-aware mask UV per cell/vertex** and a two-layer composite (base tile + mask-weighted neighbour tile), not a single RGB multiply. Until that data exists, keep the existing shader behind the switch and label the crossfade **PORT APPROX**.
3. **Cliff faces:** implement `alphavert` as a separate eye-linear projected mask per face orientation with the donor `0.125` scale; do not reuse flat-alpha patches on faces. Axis mapping must remain explicitly PORT APPROX until D06/D08 settle the Z-up→Y-up transform.
4. **Zero mask:** the donor-faithful no-transition binding is `alphanull` on ids 86/110/123. If a fresh module needs a "no blend" path, prefer that donor-authored binding over a synthetic sentinel guard; label any id-based sentinel selection APPROX.
5. **QA:** any A/B must hold `mask_to_alpha` fixed and report the histogram of mask factors; the current port can only produce factors in [0.675,1] on flat ground, so a donor-style full cut cannot be A/B-matched without changing the binding structure.

---

## 8. Risks

- **R1 — False parity by name.** "8×4×64²" and "bmTransparency" are recovered, but the tile→patch rule and blend factors are not. Implementation reports must not upgrade these to donor truth.
- **R2 — Sentinel regression.** The 3 donor zero-mask ids and the 8 port decomposition ids are different sets; conflating them would mis-wire "no transition" behaviour.
- **R3 — Guard hides full cuts.** `:419`'s floor+guard makes every flat cell ≥0.675, so genuine authored 0-valued seam regions are erased; this may be a contributing cause of the flat/olive appearance, but only a controlled A/B can attribute it (no such frame exists).
- **R4 — Channel loss.** `alphavert` is not perfectly grey; 5.7 % of pixels differ across channels by up to 15. If `tiaAlphaFromIntensity` uses a specific channel or luminance weighting, the L conversion is not bit-exact **[U]**.
- **R5 — Pass-count guessing.** "Two passes" is a plausible reading of `tsDouble`, not a recovered fact. Any toolchain that hard-codes a two-pass composite must label it APPROX.

---

## 9. UNVERIFIED register

| # | Item | Status | What would resolve it |
|---|---|---|---|
| U-F06-1 | Arithmetic converting `tsDouble`/`ttExtended`/`TileXOffset=0.1`/`TileYOffset=0.2` + two neighbouring tile ids into a `(row,col)` patch and `MultiTexCoord1` values | **CONFIRMED_UNVERIFIED** (F06-E16; DALPHA-01 §5 #5) | Binary decode of the engine mesh builder / donor GPU trace; never execution of donor binary under this charter |
| U-F06-2 | `bmTransparency` GL blend factors, equation and draw-pass count | **CONFIRMED_UNVERIFIED** (F06-E15/E17; RV-TRN-01 verdict D) | Packed `.bind` decode or GL trace |
| U-F06-3 | Exact `tiaAlphaFromIntensity` intensity formula and whether `tfAlpha` uses R, luminance or a lookup | **UNVERIFIED** (F06-E3/E11) | Engine decode |
| U-F06-4 | Whether constant 255/0 patches are authored "no blend"/"full cut" roles or unused atlas slack | **INFERRED** (F06 §5.1) | Donor GPU frame of seam transitions |
| U-F06-5 | Whether graded mask pairs were authored as exact complements (best measured MAD 9.77, right half 26–104) | **UNVERIFIED** (F06 §3.4) | Authoring-tool/palette quantisation evidence |
| U-F06-6 | Ground `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]/[1]` numeric values | **CONFIRMED_UNVERIFIED** (RV-TRN-01 verdict A) | Engine decode; do not invent values |
| U-F06-7 | Which donor tile ids actually select which of the 32 patches in a live map | **UNVERIFIED** | D08 binary lane + A/B frame |

---

## 10. Open questions

1. Does the engine emit one draw with a second texture stage, or two draws, for `bmTransparency`? (U-F06-2)
2. Is the right 4-column half a second organic variant set or a different scheme (MAD 26–104 vs 9.8–17.6)?
3. Are `alpha0a/b/c` used in shipped skirmish maps, or only as editor placeholders? (Donor binding is [O]; usage frequency [U].)
4. Does the donor ever bind `alphanull` to face tiles, or is `alphavert` unconditional for `vf`/`vs`?
5. Can the port carry a genuine neighbour id in `UV2`/`UV3` without breaking the mesh invariants, so the crossfade becomes donor-shaped (not donor-parity)?

---

## 11. Declarations

- Donor was opened **read-only**; no donor executable was run, no donor binary was copied into the repository, no donor file was modified.
- Exactly one file was written: this report. No source, shader, asset, config, test, git state or Godot runner job was touched.
- Every numeric donor claim above is either a direct byte/pixel read (with path/offset) or labelled **[D]** arithmetic on those reads. **No donor visual parity is claimed**; no donor A/B GPU frame exists.

*End of F06.*
