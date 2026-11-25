---
id: RCODE-DEEP-01
title: "Donor relief R-code decode vs port mapgen.gd:relief() — 3-pass read-only deep dive"
agent: "RCODE-DEEP-01 (donor deep-dive worker, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY__NO_PARITY_CLAIM
scope: "ONE new file only: this report. Donor READ-ONLY (C:\\Games\\Cossacks 3); donor never executed/copied; no repo source/asset/config/test/shader/git edit; no Godot runner job; no ladder change."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
labels: [observed, derived, inferred, UNVERIFIED]
output: docs/coord_swarm_2026-11-25/reports/RCODE_DEEP_01.md
verdict: DONOR_R_CODE_TABLE_RECOVERED__PORT_BAND_MAPPING_DIVERGES_ON_6_OF_8_CODES_INCLUDING_SIGN_FLIP_ON_SMOOTH_RAVINE_88
visual_parity_claim: false
---

# RCODE-DEEP-01 — donor relief R-codes decoded and compared to `variant3d/scripts/mapgen.gd:63-73 relief()`

> [!IMPORTANT]
> Donor is truth. Every claim is labelled **observed** (literal donor/port source
> line, or decoded byte/grid value), **derived** (arithmetic or control-flow
> consequence of observed lines), **inferred** (attribution without a pixel-aligned
> donor A/B), or **UNVERIFIED**. Nothing was edited; no Godot process was run;
> no donor binary was copied or executed. **No donor parity claim** is made.
> All donor paths below are `C:\Games\Cossacks 3\...`; all port paths are relative
> to the repo root. Three passes: (1) source decode, (2) real donor bitmap/`.map`
> byte decode, (3) port cross-read plus quantitative divergence measurement.

---

## 0. Mandate and boundary

Decode the R-channel colour codes declared at donor
`data/scripts/common.inc/texturemap.inc:16-31`, trace **every** consumer in
`generatemap.inc`, `dmscript.global` and the `.map` parsers, derive what each
code means (especially how `smooth R` differs from hard plateau/hill/ravine),
verify with **real** donor bitmap and `.map` bytes, then identify the exact
mismatch against the port's `relief()` and give a minimal, donor-grounded fix
recipe with a named owner file. No code edit, no runner job.

---

## 1. Sources (all read-only)

### 1.1 Donor text (three passes over the same files)

| # | File | Lines read | What it supplied |
|---|------|-----------|------------------|
| D1 | `data/scripts/common.inc/texturemap.inc` | `:1-140` (focus `:16-31`), grep of all `.r`/`cRColor*`/`cRPlateau*` occurrences | R-code constants; confirms texturemap **declares** codes but consumes only baked height + mask B |
| D2 | `data/scripts/common.inc/generatemap.inc` | `:1-120`, `:120-299`, `:300-479`, `:495-534`, `:530-669`, `:810-825`; grep of all `cRColor*` and `bsmooth` | class/smooth decode, height formula, smoothing passes, pattern-mask suppression |
| D3 | `data/scripts/common.inc/postprocess.inc` | `:1-90`, grep `:411-413` | second copy of the same code constants; editor post-process collapses all relief classes to R=255 |
| D4 | `data/scripts/dmscript.global` | `:2015-2044`, grep `cR*`/`TMapTerrainDataTile` | in-memory terrain record `{height, tex, collision[4]}` — no R field |
| D5 | `data/scripts/lib/classes.script` | `:4848-4865` | `TGeneratorBitmapMask = class r,g,b,terrain,water,forest,bsmooth,broad` |
| D6 | `data/scripts/lib/misc.script` | grep `:3120-3124` | `UserProfileLoadMap` is an engine call; no R-code parse in script |
| D7 | `data/gen/bitmap/bitmapsrc.bmp` | PIL byte decode, 320×320, SHA-256 `93985b6d…6e59e1` | **real** R-code grid with all 8 codes present |
| D8 | `data/gen/terrainmasks/**` (`*gauss.tga`) and `terrainmasks.src/**` | PIL decode of samples from all 8 shipped categories | **real** random-map masks: R=0 everywhere except pure-white starts (no relief) |
| D9 | `data/maps/missions/bonmis1.map`, `engmis4.map`, `battle1.map` | read-only decode via repo tool (see P1) | **real** baked float32 height grid + 37-byte tile records |

### 1.2 Prior reports read (context, not new evidence)

- `docs/research/RC_TERRAIN.md:75-78` — supplies the port's one-line rule
  `h = -1.1*b*(1+r*3.5) + relief(r)`; it **omits** the class×R scaling and all
  smooth codes.
- `docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md:1-211` — 64² probe
  and capture; no donor A/B, no relief measurement.
- `docs/coord_swarm_2026-11-25/reports/TRN_DATA_implementation.md:20-64,83-90` —
  donor smoothing **tile** rules embedded in `game.gd`; explicitly states the
  live tileblock histogram is UNVERIFIED and no parity is claimed.
- `docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_DIAG_01.md:83-165,271-289,
  344-369` — live height trace; at that time donor grids were "undecoded".
  The current working tree has since gained `RELIEF-LIVE-FIX-01` donor-grid tables
  in `game.gd:71-83`, so its exact line anchors are stale; its causal conclusion
  (live height is built in `game.gd`, flag is dump-only) was re-checked against
  current `game.gd:1107-1230` and is not re-litigated here.
- `docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md:95-116,
  120-168,308-322,389-392` — claim table and the prior statement that
  `relief()` is wrong for smooth R codes; this report supplies the raw code
  table, real-byte evidence and exact per-code deltas it did not include.
### 1.3 Port files (read-only)

| # | File | Lines | Role |
|---|------|-------|------|
| P1 | `variant3d/tools/import_donor_map.py` | `:113-174`, `:186-236` | read-only `.map` parser used for the dumps below (height grid + 37-byte tile records) |
| P2 | `variant3d/scripts/mapgen.gd` | `:1-30`, `:63-73`, `:154-210` | **owner of the R-code decode**; `relief()` and its sole call at `:187` |
| P3 | `variant3d/scripts/game.gd` | `:44-83`, `:1107-1133`, `:1148-1167`, `:1200-1230` | consumes `C3MapGen.build()`; no R-code logic; later clamp + analytic domes |
| P4 | `app/scripts/mapgen.gd` | `:63-73` | sibling 2D tree carries the identical `relief()` body |

---

## 2. R-code table (derived from D1/D2, arithmetic verified against D7)

**Observed constants** — `texturemap.inc:16-22` and `generatemap.inc:21-27`
are byte-identical:

```
cRColorPlateau       = 255
cRColorHill          = 96
cRColorRavine        = 48
cRColorSmooth        = 128 div 2                    = 64
cRColorPlateauSmooth = (255 div 2) + 64             = 191
cRColorHillSmooth    = (96  div 2) + 64             = 112
cRColorRavineSmooth  = (48  div 2) + 64             = 88
```

Class constants are `cRNone=0, cRPlateau=1, cRHill=2, cRRavine=3`
(`generatemap.inc:9-12`, `texturemap.inc:4-7`).

**Observed decode** — `generatemap.inc:342-344` and `:444-446` compute
`ir = floor(fr*255)` from the float channel; `:352-370` and `:454-472` map `ir`
to `terrain` and `bsmooth`; `:569-574` turns class × `fr` into height.
`classes.script:4852-4859` stores `terrain` and `bsmooth` alongside `r,g,b`.

| R byte (`ir`) | Donor constant (`path:line`) | `gMapMask.terrain` | `bsmooth` | `hterrain` source (`generatemap.inc`) | Numeric at `fr=R/255` | Class meaning |
|---:|---|---|:---:|---|---:|---|
| **0** | `cRNone` (no colour const; else branch `:365-369`, `:467-471`) | `cRNone` | false | no case → 0 (see UNVERIFIED Q2) | `0.000000` | no relief |
| **48** | `cRColorRavine` `:23` | `cRRavine` | false | `cRavineHeight*fr` `:572` | `-0.557929` | hard ravine, full class amplitude at `fr=1` |
| **64** | `cRColorSmooth` `:24` | `cRNone` | **true** | else branch → 0 | `0.000000` | flat land, **smoothed only** |
| **88** | `cRColorRavineSmooth` `:27` | `cRRavine` | **true** | `cRavineHeight*fr` `:572` | `-1.022871` | smooth ravine: lower amplitude + smoothing |
| **96** | `cRColorHill` `:22` | `cRHill` | false | `cHillHeight*fr` `:571` | `+0.495937` | hard hill |
| **112** | `cRColorHillSmooth` `:26` | `cRHill` | **true** | `cHillHeight*fr` `:571` | `+0.578593` | smooth hill |
| **191** | `cRColorPlateauSmooth` `:25` | `cRPlateau` | **true** | `cPlateauHeight*fr` `:570` | `+2.220094` | smooth plateau |
| **255** | `cRColorPlateau` `:21` | `cRPlateau` | false | `cPlateauHeight*fr` `:570` | `+2.964000` | hard plateau, cap |

Constants: `cPlateauHeight=2.964` (`generatemap.inc:4`),
`cHillHeight=2.964/2.25=1.31733…` (`:5`), `cRavineHeight=-2.964` (`:6`),
`cWaterHeight=-1.1` (`:7`).

### 2.1 How `smooth R` differs from hard plateau/hill/ravine — exact semantics

**Observed / derived.** Four distinct differences, all at cited lines:

1. **Amplitude is `class × fr`, not `class` at full value.** Hard codes reach
   the full class amplitude only because their byte normalises to 1.0
   (`255/255`) or to the authored byte (`96/255`, `48/255`). Smooth variants are
   deliberately *half-byte offset* codes (`R/2 + 64`), so `fr` is ~0.345–0.749:
   they produce a **lower** relief amplitude of the same class
   (`generatemap.inc:569-573`, constants `:21-27`).
2. **`bsmooth` triggers a separate terrain-smoothing operator after the height
   write.** `generatemap.inc:587-592` calls
   `SmoothTerrain(realx, -realy, False, 3)` for every cell with `bsmooth=true`.
   Hard codes set `bsmooth=false`; the three smooth variants and code 64 set it
   true (`:354,358,362,367` and `:456,460,464,469`). So the smooth variants blur
   the class edge; hard codes keep the sharp authored step.
3. **Code 64 is not "gentle plateau" — it is *no class*.** `:367/:469` set
   `terrain := cRNone` and `bsmooth := (ir=64)`: `hterrain` is 0, only the
   smoothing operator acts. A port `×0.5 plateau ramp` for R=64 invents relief
   the donor does not have.
4. **Smoothed cells are flagged out of later free-pattern placement.**
   `generatemap.inc:818` adds `bsmooth` to the `gPatternMask=True` condition,
   suppressing pattern stamps on those cells (often redundant with the
   non-black pixel test at `:389-393`, but a real second consumer).

Two further observations that matter for interpretation:

- **Only exact bytes are classed.** The `case ir of` at `:352-370/:454-472`
  matches exact integers; `D7` has **196 distinct R bytes**, most of them
  intermediate (e.g. 111, 108, 94, 70). Any non-listed byte → `cRNone`,
  `bsmooth=false`. A port `±12` band therefore classes 783 cells in the port's
  hill band and 1,113 cells in its ravine band **that the donor classes as
  no-relief** (derived from D7 byte counts; see §5).
- **R is not stored in the shipped `.map`.** `dmscript.global:2026-2035` defines
  `TMapTerrainDataTile{height:Float, tex:Integer, collision:Integer[4]}`;
  the engine loader is `UserProfileLoadMap` (`misc.script:3122-3124`) and the
  repo's read-only parser decodes only height + 37-byte tile records
  (`import_donor_map.py:113-174,186-236`). The R-code semantics are baked into
  `height[]` by `generatemap.inc:563-574` and then further modified by the
  smoothing passes (`:580-644`) and pattern stamps. **[derived]**

### 2.2 Other consumers checked (negative results, all observed)

- `texturemap.inc`: declares the same constants at `:4-7,16-22` but never reads
  `gMapMask[].r`; its water test uses `gMapMask[ix,iy].b > 0` at `:68` and its
  collision uses the **baked** `GetHeightData()` at `:66,76-80,88-129`.
- `postprocess.inc`: same constants `:16-22`; its editor mask rebuild collapses
  **all** relief classes to `ir := cRColorPlateau` (`:43`, comment
  "all colors raise to max") and rescales class magnitudes at `:411-413`.
- `.map` parsers: no R field (see §2.1).

---

## 3. Real donor data — R-code grid (pass 2, no script-name inference)

### 3.1 `bitmapsrc.bmp` — the donor's own default generator bitmap

`generatemap.inc:57` sets `inputbitmap := '.\data\gen\bitmap\bitmapsrc.bmp'`.
Decoded read-only with PIL (320×320 RGB, SHA-256 `93985b6d…6e59e1`). **[observed]**

| R byte | count | share |
|---:|---:|---:|
| 0 | 83,980 | 82.01% |
| 48 | 29 | 0.028% |
| 64 | 3,490 | 3.41% |
| 88 | 18 | 0.018% |
| 96 | 1,163 | 1.14% |
| 112 | 2,707 | 2.64% |
| 191 | 112 | 0.11% |
| 255 | 2,590 | 2.53% |
| any other of 196 distinct bytes | 8,311 | 8.12% |

**Real 12×12 R-code window**, `x=256..267, y=104..115` (selected as the window
with the widest coverage of canonical codes):

```
       x=256 257 258 259 260 261 262 263 264 265 266 267
y=104     63  66  63  41   1   0   0   0   0   0   0   0
y=105     41  41  41   3   0   0   0   0   0   0   0   0
y=106      3   3   3   0   0   0   0   0   0   0   0   0
y=107      0   0   0   0   0   0   0   0   0   0   0   0
y=108      0   0   0   0   0   0   0   0   0   0   0   0
y=109      0   0   0   0   0   0   0   0   0   0   0   0
y=110      0   0   0   2  32  62  64  64  64  64  17   0
y=111      0   8  42  63  64  64  64  64  64  64  64  17
y=112      8  59  64  64  65  88 111 112 112  77  64  17
y=113     59  64  70  96 112 112 112 112 100  64  64  17
y=114     64  69 108 112 112 112 112 112  79  64  48   0
y=115     64  94 112 112 112 112 112 112  65  64  21   0
```

**[derived]** The window contains all of `64, 88, 96, 112, 48` plus many
intermediate bytes (63, 65, 70, 77, 79, 94, 100, 108, 111). Under
`generatemap.inc:352-370`, only the exact codes get a class; e.g. the `111` at
(262,112) is one byte off `112` and is classed `cRNone`, while the adjacent
`112` is `cRHill + bsmooth`.

### 3.2 Code→height verified from real RGB bytes (pass 2)

First occurrence of each code in `bitmapsrc.bmp`, with the donor formula
`hwater=-1.1*fb*(1+fr*3.5)`, `hterrain=class(fr)`, evaluated on those bytes
(`generatemap.inc:563-574`): **[observed bytes + derived arithmetic]**

| R | at (x,y) | RGB | `fr` | `fb` | `hwater` | `hterrain` | `h = hw+ht` | `bsmooth` |
|---:|---|---|---:|---:|---:|---:|---:|:---:|
| 0 | (0,0) | (0,64,0) | 0.000000 | 0 | 0.000000 | +0.000000 | +0.000000 | false |
| 48 | (218,31) | (48,64,0) | 0.188235 | 0 | 0.000000 | -0.557929 | -0.557929 | false |
| 64 | (246,3) | (64,64,0) | 0.250980 | 0 | 0.000000 | +0.000000 | +0.000000 | **true** |
| 88 | (204,63) | (88,64,0) | 0.345098 | 0 | 0.000000 | -1.022871 | -1.022871 | **true** |
| 96 | (248,52) | (96,64,0) | 0.376471 | 0 | 0.000000 | +0.495937 | +0.495937 | false |
| 112 | (220,33) | (112,64,0) | 0.439216 | 0 | 0.000000 | +0.578593 | +0.578593 | **true** |
| 191 | (288,223) | (191,64,0) | 0.749020 | 0 | 0.000000 | +2.220094 | +2.220094 | **true** |
| 255 | (318,179) | (255,64,0) | 1.000000 | 0 | 0.000000 | +2.964000 | +2.964000 | false |

This is the requested real-data verification of the code→meaning mapping: the
amplitudes are exactly the class×R lattice of §2, and code 64 lands on **zero**
relief with only the smoothing flag set. **[derived]**

### 3.3 Two real donor `.map` files — baked height + tile grids

Decoded with the repo's read-only parser (`import_donor_map.py:113-174,186-236`);
inputs were never written and no donor code was executed. Tile ids are
`tiles.lib` ordinals resolved through
`variant3d/assets/terrain/structs/tileblocks.json` (`import_donor_map.py:211-219`).

**`bonmis1.map`** — SHA-256 `5b7a83c59261843ee961b7ddee82503fc6e72cb84197b005bdb3954ecb69c4ea`,
W=320, 102,400 cells, height grid at `0xa68acd`, tile records at `0xacd4c9`.
10×10 window at (x=0,y=0), `H` = baked float32 height, `T0` = tile index at
record byte 8: **[observed]**

```
 y= 0 H: -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100
       T0:   0     79    79    79     0     0     0     0     0     0
 y= 1 H:  0.000 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100
       T0:  79    79    79     0    79     0     0     0     0    80
 y= 2 H:  0.000  0.000 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100
       T0:  79    14    79    79     0     0     0     1     1    80
 y= 3 H:  0.000  0.000  0.000 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100
       T0:  14    25    16    84     0     0     0     0    78    80
 y= 4 H:  0.000  0.000  0.000  0.000 -1.100 -1.100 -1.100 -1.100 -1.100 -1.100
       T0:  14    25    14    84     0     0     0     0    79    79
 y= 5 H:  0.000  0.000  0.000  0.000  0.000 -1.100 -1.100 -1.100 -1.100 -1.100
       T0:  79    14    84    84    84    84    84     0    85    79
 y= 6 H:  0.000  0.000  0.000  0.000  0.000  0.000 -1.100 -1.100 -1.100 -1.100
       T0:  79    84    84    84    16    84    84     7    85    85
 y= 7 H:  0.006  0.000  0.000  0.000  0.000  0.000  0.000 -1.100 -1.100 -1.100
       T0:  79    79    79    14    25    16     1     7    85    85
 y= 8 H:  0.094  0.031  0.005  0.000  0.000  0.000  0.000  0.000 -1.100 -1.100
       T0:   0    78    79    79    16    25    14    85    85    85
 y= 9 H:  0.271  0.162  0.085  0.039  0.009  0.000  0.000  0.000  0.000 -1.100
       T0:   0    79    78    14    25    16    79    85    85    85
```

Height lattice over all cells (`|h-k|<1e-5`): `0.0` **30,351**;
`-1.1` **15,361**; `+2.964` **2,411**; `-2.964` **364**.
Top tile ids: `0 grass1` 25,030; `79 test8` 12,187; `78 test7` 9,864;
`25 sand9` 7,305; `98 sandsea6` 5,135; `1 grass2` 4,538; `14 grass_rock1` 4,529.

**`engmis4.map`** — SHA-256 `f079af79f78703faddcfe75da81486491f7396058e311bb0320ee44e5dae9bce`,
W=320, 102,400 cells, height grid at `0xa3353c`, tile records at `0xa97f38`.
10×10 window at (x=0,y=0): **[observed]**

```
 y= 0 H: 2.964 2.964 2.964 2.964 2.964 2.964 2.964 2.964 2.964 2.964
       T0:  10    73    72    78     0     0     0     0     0     0
 y= 1 H: 0.000 2.964 2.964 2.964 2.964 2.964 2.964 2.964 2.964 2.964
       T0:  10    10    73    74    78    78     0     0     0     0
 y= 2 H: 0.000 0.000 2.964 2.964 2.964 2.964 2.964 2.964 2.964 2.964
       T0:  73    73    10    73    72    72    78     1     1     4
 y= 3 H: 0.000 0.000 0.000 2.964 2.964 2.964 2.964 2.964 2.964 2.964
       T0:  74    74    73    74    72    73    72    78     1     0
 y= 4 H: 0.000 0.000 0.000 0.000 2.964 2.964 2.964 2.964 2.964 2.964
       T0:  78    78    72    72    73    10    73    72    78     0
 y= 5 H: 0.000 0.000 0.000 0.000 0.000 2.964 2.964 2.964 2.964 2.964
       T0:  79     1    78    78    74    73    74    73    74    78
 y= 6 H: 0.000 0.000 0.000 0.000 0.000 0.000 2.964 2.964 2.964 2.964
       T0:  79    84    84    84    78    74    73    10    73    72
 y= 7 H: 0.000 0.000 0.000 0.000 0.000 0.000 0.000 2.964 2.964 2.964
       T0:  79    79    79    84    84    78    72    73    73    73
 y= 8 H: 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 2.964 2.964
       T0:   0    78    79    79    79    79    78    72    73    10
 y= 9 H: 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 2.964
       T0:   0    79    78    79    79    79    79    78    74    73
```

Height lattice: `0.0` **63,901**; `-1.1` **87**; `+2.964` **7,981**;
`-2.964` **2**. Top tile ids: `0 grass1` 19,606; `79 test8` 9,243;
`78 test7` 9,032; `25 sand9` 8,133; `10 ground1` 6,227; `93 sandsea1` 5,512;
`1 grass2` 4,425; `80 test9` 4,007.

**[derived]** Both maps independently land on the donor lattice:
`0.0` (no relief, no water), `-1.1` (`cWaterHeight`, water bed), `+2.964`
(`cPlateauHeight`, R=255 cap), `-2.964` (`cRavineHeight` ceiling after pattern
clamp). **[inferred]** The *intermediate* base amplitudes `0.495937`,
`0.578593`, `-0.557929`, `-1.022871`, `+2.220094` have essentially no survivors
(0–46 cells at 1e-3 tolerance across all 38 shipped mission maps) — consistent
with the all-land smoothing at `generatemap.inc:598-609` and pattern height
clamps overriding non-flat base samples. No 8×8 window in either map contains
three of the four lattice values: plateau, water and ravine regions are
spatially separated in these two maps. This does **not** weaken the code table:
the R bytes themselves were read from D7, and the lattice heights were read
from D9.

---

## 4. Donor algorithm — pseudocode (observed lines, derived flow)

```
# A. decode the authored source bitmap (generatemap.inc:285-294, :342-352 / :444-454)
(srcbitmap, srcwidth, srcheight) = LoadBitmap(source_path)   # BMP for editor maps,
                                                            # TGA for random maps (:139-208)
for each generator cell (x,y):
    (fr,fg,fb,fa) = GetBitmapPixel(srcbitmap, floor(x/W*srcW), floor(y/H*srcH))  # :541-543
    ir = floor(fr*255)                                       # :342-344 / :444-446
    mask[x,y].r = fr; .g = fg; .b = fb; .broad = (fa>0)      # :345-351 / :447-453

    # class + smooth flag  (:352-370 / :454-472)
    if ir in (255,191): terrain=cRPlateau; bsmooth=(ir==191)
    elif ir in (96,112): terrain=cRHill;    bsmooth=(ir==112)
    elif ir in (48,88):  terrain=cRRavine;  bsmooth=(ir==88)
    else:                terrain=cRNone;    bsmooth=(ir==64)

# B. base height  (:563-574)
    if random_map and fr==1 and fb==1: continue              # skip pure-white starts (:565-566)
    hwater = -1.1 * fb * (1 + fr*3.5)                        # :567
    hterrain = { +2.964*fr   if terrain=cRPlateau            # :570
               { +1.31733*fr if terrain=cRHill               # :571
               { -2.964*fr   if terrain=cRRavine             # :572
               { 0           otherwise                       # var uninitialised, see UNVERIFIED Q2
    SetHeightData(floor(lx+x), floor(ty+y), hwater+hterrain) # :574; lx=-(W div 2)

# C. smoothing  (:580-644)
    if bsmooth: SmoothTerrain(realx, -realy, False, 3)       # :587-592  <-- SMOOTH codes only
    all land:   _misc_SmoothTerrainCustom(x,y,1,4,0.5,0.01,100)          # :606
    3 passes:   coastal cells -> _misc_SmoothTerrainCustom(...,0.35,0.5,-100,-0.01) # :611-640

# D. downstream consumers
    pattern placement skips bsmooth cells                    # :818
    texturemap.inc classifies water from B and bakes collision from height  # :68-75, :88-129
    dmscript.global TMapTerrainDataTile stores {height, tex, collision[4]} # :2026-2035
    .map serialises that baked grid; NO R code survives      # import_donor_map.py:113-174
```

**[derived]** Hard codes therefore differ from smooth codes by *three* things:
class amplitude at `fr`, the `SmoothTerrain(...,3)` operator, and the pattern
suppression flag. Code 64 has no class at all. Nothing in the port reproduces
the middle two.

---

## 5. Port mismatch — `variant3d/scripts/mapgen.gd:63-73`

**Observed port code:**

```
63  static func relief(v: float) -> float:
64      # v is the mask's red channel in 0..255 (plateau/hill/ravine colour codes).
65      if v >= 250.0:            return C_PLATEAU            # 2.964
67      if absf(v - 96.0) <= 12.0: return C_HILL              # 1.31733
69      if absf(v - 48.0) <= 12.0: return C_RAVINE            # -2.964
71      if v > 0.0: return C_PLATEAU * (v / 255.0) * 0.5       # arbitrary half ramp
73      return 0.0
```

Sole call: `mapgen.gd:186-187`
`hw = C_WATER*(cb/255)*(1+(cr/255)*3.5); height[i] = hw + relief(cr)`.
`game.gd:1131-1133` calls `C3MapGen.build()` and uses the returned `height`;
`game.gd:44-83` stores amplitude constants but contains **no R-code decode**
(`grep` of `game.gd` found no `relief(` call and no `191/112/88` relief logic).
The sibling `app/scripts/mapgen.gd:63-73` is byte-identical.

### 5.1 Per-code mismatch table (derived from §2 + observed port lines)

| R | Donor `hterrain` | Port `relief(v)` | Port branch | Δ (port−donor) | Verdict |
|---:|---:|---:|---|---:|---|
| 0 | 0.000000 | 0.000000 | `:73` | 0.000000 | match |
| 48 | -0.557929 | -2.964000 | `:69-70` hard band | **-2.406071** | 5.3× too deep |
| 64 | 0.000000 | +0.371953 | `:71-72` half ramp | **+0.371953** | invents relief on a flat/smoothed cell |
| 88 | -1.022871 | +1.317333 | `:67-68` hill band | **+2.340204** | **sign flip**: smooth ravine read as hill |
| 96 | +0.495937 | +1.317333 | `:67-68` hard band | **+0.821396** | 2.66× too high |
| 112 | +0.578593 | +0.650918 | `:71-72` half ramp | +0.072324 | wrong branch, near miss by luck |
| 191 | +2.220094 | +1.110047 | `:71-72` half ramp | **-1.110047** | exactly half the donor value |
| 255 | +2.964000 | +2.964000 | `:65-66` | 0.000000 | match |

**Additional mismatch classes (derived):**

| # | Port behaviour | Donor behaviour | Evidence |
|---:|---|---|---|
| M1 | `±12` bands class 84–108 as hill and 36–60 as ravine | only exact 96/112 and 48/88 are classed; all other bytes → `cRNone` | `mapgen.gd:67-70`; `generatemap.inc:352-370,454-472` |
| M2 | no `bsmooth` flag, no `SmoothTerrain(...,3)` anywhere in `mapgen.gd` | every smooth code triggers a 3-call smoothing operator | `mapgen.gd:191-208` has coastal passes only; `generatemap.inc:587-592` |
| M3 | `v>=250` classes 250–254 as plateau | donor classes only 255; 250–254 → none | `mapgen.gd:65`; `generatemap.inc:352-370` |
| M4 | ×0.5 fallback is an invented port constant | no such multiplier exists in donor text | `mapgen.gd:72`; `generatemap.inc:569-574` |
| M5 | port `relief()` returns class amplitude, not `class × fr` | donor multiplies by the normalised byte | `mapgen.gd:63-73`; `generatemap.inc:570-572` |

**Quantified over real bytes (pass 3, derived):** applying both formulas to all
102,400 pixels of `bitmapsrc.bmp` (D7) gives **15,830 cells (15.46%)** with a
different base relief, mean absolute difference `0.088615`, max `2.964000`,
and **18 cells with a sign flip** — all 18 are R=88 (smooth ravine → port hill).
This is the concrete form of DTRN-02's note
`DTRN_02_donor_terrain_geometry.md:319-322` ("`relief()` is wrong for smooth R
codes"), still present at `variant3d/scripts/mapgen.gd:63-73` and mirrored at
`app/scripts/mapgen.gd:63-73`.

**Scope caveat (observed + derived):** the 56 port-exported random-map masks
under `variant3d/assets/terrain/masks/**` mirror donor `*gauss.tga`: R=0 on
102,396 cells and R=255 on only the 2–4 pure-white start markers, which
`mapgen.gd:173-175` skips. Therefore the mismatch is **latent for shipped
skirmish masks** (mostly R=0) but active whenever a relief-bearing bitmap is
decoded — the editor/BMP path D7 evidences, the `postprocess.inc` output, and
any future mask that actually carries relief codes. This is *not* a claim that
live skirmish hills are currently caused by `relief()`; the live stamp path is
owned by `game.gd` (`RELIEF_LIVE_DIAG_01.md:344-369`, current `game.gd:1200-1230`).

---

## 6. Minimal donor-grounded fix recipe (no edit made)

**Owner file: `variant3d/scripts/mapgen.gd`** — specifically `relief()`
(`:63-73`) and its single call site (`:186-187`). This is the sole R-code
decoder in the live map path; `game.gd` consumes the resulting `height[]` and
owns a *different* concern (stamp/clamp), so it must not be edited for this
ticket. Mirror the same change to `app/scripts/mapgen.gd:63-73` only if the 2D
tree remains in scope.

1. **Replace `relief()` with the exact 8-code decode** from §2, no bands, no
   half ramp:
   - `255 or 191 → C_PLATEAU * (v/255.0)`,
   - `96 or 112 → C_HILL * (v/255.0)`,
   - `48 or 88 → C_RAVINE * (v/255.0)`,
   - everything else (including 64, 250–254, and all intermediate bytes) → `0.0`.
   Keep `C_WATER/C_PLATEAU/C_HILL/C_RAVINE` constants at `:25-28` unchanged and
   keep the `hw` formula at `:186` unchanged — it already matches
   `generatemap.inc:567`. **[donor-grounded: `generatemap.inc:21-27,342-370,454-472,563-574`]**
2. **Add a sibling `relief_smooth(v) -> bool`** returning true for
   `{64,191,112,88}` and plumb that flag out of `build()` alongside `height`.
   In `build()` (`:160-209`), after the height assignment loop, apply a
   3-pass local smoothing to flagged cells before the existing coastal passes
   (`:191-208`). Label it **PORT APPROXIMATION**: the donor engine's
   `SmoothTerrain(x,-y,False,3)` kernel is not readable from the shipped scripts
   (`UNVERIFIED`, same caveat as `RELIEF_LIVE_DIAG_01.md:337-340`). Do not
   invent a new kernel shape. **[donor-grounded: `generatemap.inc:587-592`]**
3. **Keep the pure-white start skip** at `:173-175` and the water classification
   at `:189-190` exactly as they are (donor `:565-566`, `texturemap.inc:30-31`).
4. **Unit-test the seven codes plus 0 before wiring** (DTRN-02 step 3,
   `DTRN_02:389-392`), using the real sample bytes of §3.2 as fixtures. Assert:
   `R=88 → -1.022871` (not +hill), `R=191 → +2.220094` (not halved),
   `R=64 → 0.0`, `R=250..254 → 0.0`, and any non-listed byte → `0.0`.
5. **Do not change `game.gd` in this ticket.** Its clamp at `game.gd:1211-1230`
   may cap donor-grid values above +2.964; that is the separate stamp/clamp
   owner identified in `RELIEF_LIVE_DIAG_01.md:344-369` and DTRN-02 step 2,
   not part of the R-code decode fix. Record the interaction as an open
   question rather than silently altering the cap.
6. No new asset, no donor binary in the repo, no synthetic noise or fabricated
   hill amplitude; numbers only, transcribed from observed donor constants.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Is `hterrain` zero-initialised for `cRNone` cells? `generatemap.inc:568`
   declares `var hterrain : Float;` without assignment and the `case` at
   `:569-573` has no `else`. The baked map lattice (`0.0` dominant) is
   consistent with zero-init, but the interpreter's local-float semantics are
   not provable from the text (also RV-TRN-02 §8 Q2).
2. Does the donor engine ever execute these `.inc` states at runtime? Every
   code line is `;`-commented in the shipped build (TRN-DATA
   `TRN_DATA_implementation.md:87`). The authored algorithm and constants are
   real; runtime activity is UNVERIFIED.
3. What is the exact kernel of `SmoothTerrain(x,-y,False,3)`
   (`generatemap.inc:591`)? Only the call site is readable, so M2's fix can be
   labelled but not proven equivalent.
4. Can a specific shipped `.map` be tied to a specific source BMP/TGA and seed?
   The mission `<name>.bmp` files are editor inputs that go through
   `PostProcess` → `ext/bitmaptrg.bmp` (`generatemap.inc:507-521`), which is not
   shipped; a direct pixel-for-pixel BMP→`.map` identity test on `ausmis1`
   matched only 54.0% of cells (58.9% for the best of 8 flips/transposes), so no
   code→height pairing is claimed for the
   `.map` dumps in §3.3. They are used only for the baked-height lattice.
5. Would fixing `relief()` change any live skirmish frame, given §5's scope
   caveat? No runner job was submitted; this is UNVERIFIED and explicitly not
   claimed.
6. Does the ×0.5 fallback in `mapgen.gd:72` represent an older donor build or a
   deliberate port tuning? No donor text supports it; provenance UNVERIFIED.

---

## 8. Summary

- **[observed]** Donor R codes are exactly `0, 48, 64, 88, 96, 112, 191, 255`
  (`texturemap.inc:16-22`, `generatemap.inc:21-27`). Class is decoded from
  **exact** `floor(fr*255)` bytes (`generatemap.inc:342-370,454-472`);
  height is `class × fr` (`:569-574`); smooth variants set `bsmooth` and get
  `SmoothTerrain(x,-y,False,3)` (`:587-592`) plus pattern suppression (`:818`).
  Code 64 is flat land with smoothing, not a relief class.
- **[observed]** Real donor bytes confirm all eight codes exist in
  `bitmapsrc.bmp` (196 distinct R values; counts in §3.1), and real donor
  `.map` height grids cluster on the resulting lattice (`0.0`, `-1.1`,
  `±2.964`) in two independently decoded files.
- **[derived]** Port `relief()` (`variant3d/scripts/mapgen.gd:63-73`, mirrored
  in `app/scripts/mapgen.gd:63-73`) diverges on **6 of 8** codes: hard ravine
  5.3× too deep, hard hill 2.66× too high, smooth plateau exactly halved,
  smooth hill on the wrong branch, code 64 given invented relief, and **R=88
  sign-flipped from smooth ravine to hill**. 15.46% of real bitmap cells get a
  different base relief; no `bsmooth` equivalent exists in the port.
- **[derived]** The mismatch is latent for shipped skirmish masks (R=0) and
  active for relief-bearing bitmaps; it is upstream of, and distinct from, the
  live stamp/clamp owner `game.gd`.
- Minimal fix: exact 8-code decode in **`variant3d/scripts/mapgen.gd`** plus a
  labelled `bsmooth` flag — no code was edited, no runner job was submitted,
  and **no donor parity claim** is made.

---

*End of RCODE-DEEP-01. One report written; no source, asset, config, test,
shader, JSON, PNG, git or donor file created/modified; no Godot process run;
no donor file copied or executed.*
