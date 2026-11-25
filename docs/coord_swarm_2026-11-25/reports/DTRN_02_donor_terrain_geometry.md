---
id: DTRN-02
title: "Donor terrain GEOMETRY — heightmap→mesh, relief authoring, hills/plateaus/ravines, LOD, collision"
agent: DTRN-02 (micro-worker, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — read-only donor bytes + read-only port code; no donor file run/copied; no repo code edit
scope: singleplayer skirmish terrain geometry, independent of textures/art
donor: C:\Games\Cossacks 3 (private use, read-only; Python bytes + latin-1, struct; never executed or copied)
output: docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md
verdict: DONOR_TRUTH_RECOVERED__PORT_SOURCE_HEIGHTS_AND_RELIEF_PROPS_ARE_THE_PRIMARY_GEOMETRY_GAPS
verification: 2–3 independent passes per important claim (see "Verification passes" in claim table)
---

# DTRN-02 — Donor terrain geometry

> [!IMPORTANT]
> Donor is truth. Every donor fact below cites **donor `path:line`** or a decoded
> binary header/grid with the byte offsets stated. Labels: **observed** (literal
> line / decoded bytes / measured value), **derived** (arithmetic or control-flow
> consequence of observed lines), **inferred** (best reading with caveat),
> **UNVERIFIED** (not provable from the files read). No Godot process was run;
> no donor binary was executed or copied into the repo; no code was edited.

---

## 0. Goal

Answer, from the donor installation directly (2–3 passes), how terrain **geometry**
is produced and displayed:

1. how heightmap samples map to world coordinates and heights;
2. height scale / quantisation;
3. grid resolution vs tile/cell size;
4. triangle construction, normals;
5. how hills / plateaus / ravines / mountains are **authored** (not just textured);
6. LOD / tessellation;
7. collision / walkability vs the visual mesh;

then state exactly what is **wrong / missing** in `variant3d/scripts/world3d_terrain.gd`
and `variant3d/scripts/heightmap_world3d.gd` (shape and quality **independent of
textures**), and give a geometry-only fix recipe on the smallest map.

---

## 1. Sources

### 1.1 Donor plaintext (read in place, bytes→latin-1)

| # | Donor path | Lines/size | Role |
|---|---|---|---|
| D1 | `data\scripts\common.inc\generatemap.inc` | 1,059 | height constants, bitmap→height-grid sample, class→height formula, smoothing |
| D2 | `data\scripts\common.inc\texturemap.inc` | 963 | water/shore/collision constants, `MapDrawCollision`, rock-tile aspect rules |
| D3 | `data\scripts\common.inc\dogenerate.inc` | 2,103 | pattern stamping; `terrainmesh` object scale exemption |
| D4 | `data\pattern\pattern.lib` | 1,172,416 lines / 680 sections | **HeightFieldScale / Min / Max / Smooth / TerrainScale / CollisionStand per relief pattern** |
| D5 | `data\game\var\generator.cfg` | 2,366 | relief family membership and `Freq` weights |
| D6 | `data\scripts\lib\miscext2.script` | 4,743 | map size → grid size (320/480/640/256) |
| D7 | `data\scripts\lib\misc.script` | 7,013 | `_misc_GetMapLeftTopPos` (centred coordinate origin) |
| D8 | `data\scripts\dmscript.global` | 2,400 | `gc_MaxMapWidth=640`, `gc_MaxColMapWidth=2*W`, `TMapTerrainDataTile` |
| D9 | `data\shaders\obj\hf.pvl.sm.vert` | 50 | per-vertex normal transform / lighting |
| D10 | `data\shaders\shaders.lib` | 949 | `ShadersSM20/30.HeightField` configuration |
| D11 | `data\terrain\ref\reftile.mat`, `data\terrain\tiles\tiles.lib`, `tiles.mat` | — | cliff/vertical-face materials, 25° tilt pairs |
| D12 | `data\actors\env\terrainmesh{1,2,3,4}.actor`, `data\actors\actors.lib`, `data\actors\ref\refmountain.actor` | — | relief LOD prop binding |
| D13 | `data\objects\env\terrainmesh*.prop`, `terrainplateau*.prop` | — | placed relief props |
| D14 | `data\gen\terrainmasks.src\**\*.tga` | 2,000+ files | hand-authored terrain masks (the *only* height source bitmaps) |

### 1.2 Donor binaries decoded read-only (bytes + struct, never run/copied)

| # | Path | What was decoded |
|---|---|---|
| B1 | `data\actors\env\terrainmesh{1,2,3,4}.osm`, `terrainplateau{1,2,3,4}.osm` | 68-byte IDP2 header, vertex/UV/triangle sections, bboxes |
| B2 | `data\pattern\plt1.pattern`, `hil1.pattern`, `g_hil1.pattern`, `k_ravine_1.pattern`, `k_ravine_7.pattern`, `plt2/3`, `f_plt_big_1`, `g_mnt_1`, `big_hill_1` | `int32 w,h` + `w*h` u8 mask + **w×h float32 height grid** (see C6) |
| B3 | `data\maps\missions\bonmis1.map`, `engmis4.map` | baked `float32[W*H]` height grid (via read-only `variant3d/tools/import_donor_map.py:113-174`) |

### 1.3 Project documents read for orientation (not new donor evidence)

`docs/audit/TERRAIN_DONOR_PIPELINE.md`, `docs/audit/TERRAIN_PORT_HILLS.md`,
`docs/audit/PIECES/{hill_ridge,plateau,ravine_face,verdict_grass_relief}.md`,
`docs/coord_swarm_2026-11-24/reports/{G31_donor_3d_truth,G32_heightmap_world,G33_heightmap_capture,G34_heightmap_splat,DEEPDEC_02_terrain_render}.md`,
`docs/decomp/DC_FORMATS.md:66-95`.

### 1.4 Port files read only (no edit)

`variant3d/scripts/world3d_terrain.gd` (903 lines),
`variant3d/scripts/heightmap_world3d.gd` (266 lines),
`variant3d/scripts/game.gd:858-1100`, `variant3d/scripts/mapgen.gd:63-73`,
`variant3d/tests/t_smallmap_terrain.gd:1-26`.

---

## 2. Claim table

"Verification passes" records how many independent reads/decodes agree
(prior docs count only when they quote the same literal).

| # | Claim | Evidence (donor `path:line` / decoded grid) | Verdict | Passes |
|---|---|---|---|---|
| C1 | Height constants `cPlateauHeight=2.964`, `cHillHeight=2.964/2.25=1.31733…`, `cRavineHeight=-2.964`, `cWaterHeight=-1.1` | `generatemap.inc:4-7` | **observed** | 3 (D1 direct ×2, TERRAIN_DONOR_PIPELINE §3.1) |
| C2 | R terrain codes `255/96/48`; smooth variants `191/112/88`; `cRColorSmooth=128 div 2=64` | `generatemap.inc:9-27` | **observed** | 2 |
| C3 | Height→world sample: generator cell `(x,y)` → engine grid `realx=floor(lx+x)`, `lx=-(W div 2)`; `SetHeightData(realx,realy,hwater+hterrain)`; mask sampled by `floor(x/W*trgW)` | `generatemap.inc:541-543,559-574`; `misc.script:68-72` | **observed** | 2 |
| C4 | Height formula `h = -1.1*fb*(1+fr*3.5) + class(fr)`; class from decoded R code (plateau/hill/ravine); white start pixels skipped | `generatemap.inc:563-574`, `:565-566` | **observed** | 3 |
| C5 | Grid = map grid: 320/480/640/256 by mapsize, cap 640; **collision grid is 2× the height grid** | `miscext2.script:19-26,45`; `dmscript.global:132-135`; `texturemap.inc:133-134` | **observed** | 3 |
| C6 | Relief `.pattern` files contain a per-cell **float32 height grid** (`w*h` values after the `w*h` u8 occupancy mask) whose min/max equal the pattern's `HeightFieldMin/Max` in `pattern.lib` | B2: `k_ravine_1` grid min/max `-2.9636276 / 3.1398201` = `pattern.lib:549585-549586`; `plt2` `-0.0732549/3.6134117` = `:6805-6806`; `hil1` `0/3.8613024` = `:33111-33112`; ravine cross-section `-0.0009,-0.0312,-0.2194,-0.5609,-0.9415,-1.2995,-1.5860,-1.8178,-2.0101,-2.1903,-2.3606` | **observed** (grid), **derived** (start offset ≈ `8+w*h`, exact byte alignment within ±16 B UNVERIFIED) | 3 |
| C7 | Relief patterns carry height sculpt config: `HeightFieldStand`, `HeightFieldScale`, `HeightFieldMin/Max`, `HeightFieldSmooth/Radius/Factor/Offset`, `TerrainScale`, `CollisionStand` — **donor DOES sculpt height from stamps** (contradicts prior "plaintext never adds height from a stamp") | `pattern.lib:8-21` (brush_plt), `:328-353` (plt1), `:549562-549587` (k_ravine_1), `:357950-357975` (g_hil1), `:337468-337493` (g_mnt_1) | **observed**; engine blend math (`Replace`/`Smooth`) **UNVERIFIED** | 3 |
| C8 | Mountains/plateaus place **real 3D prop meshes** (`terrainmesh1..4.osm`, `terrainplateau1..4.osm`) as game objects inside mountain patterns | `pattern.lib:338482` (`g_mnt_1`→`terrainmesh4`), `:344362` (`g_mnt_3`→`terrainmesh1`), `:348758` (`g_mnt_5`), `:356906` (`g_mnt_7`); `actors.lib:1200-1213`; `terrainmesh1.actor:1-5`; `dogenerate.inc:1984` (scale exemption) | **observed** | 3 |
| C9 | Decoded relief props: `terrainmesh1` 2,662 v / 5,305 f, bbox x[-14.021,13.888] y[-13.524,13.446] z[0.070,7.449]; mesh2 2,272/4,532 z≤8.035; mesh3 2,177/4,323 z≤9.550; mesh4 2,509/5,002 z≤6.933; plateaus 231–655 v, z -5.35…10.93 | B1 IDP2 header + section closure `ou+nu*8=ot; ot+nt*24=of; of+16+nv*16=filesize` (matches `DC_FORMATS.md:90`) | **observed** | 2 (decode + G31 counts) |
| C10 | Baked donor map heights are float32, clamped to `[-2.964,+2.964]`; water bed at exactly `-1.1`; dominant flat land at `0.0` | B3: bonmis1 320² min `-2.9639999866`, max `+2.9639999866`, mean `-0.072741`; 31.97% at 0.0, 21.69% at -1.1, 4.18% at +2.964, 0.48% at -2.964; engmis4 mean `+0.252345`, 64.31% at 0.0, 9.07% at +2.964 | **observed** | 2 (two maps) |
| C11 | No `terrain/heightmap` directory exists; only heightmap-named file is `data\water\textures\heightmapwaves0.tga` (water, not terrain) | recursive filesystem scan of `data\**` | **observed** (negative) | 2 |
| C12 | Collision from the SAME height field, on 2× grid: water tag where mask B>0 & h<-0.25; terrain tag where `|dh|>0.5` cardinal or `>0.55` diagonal; drawn at 0.5-cell offsets | `texturemap.inc:66-129` (`cDiff1=0.5`:63, `cDiff2=0.55`:64), `:133-134` | **observed** | 3 |
| C13 | Rock tile art is gated by collision tag + 8-sector height-gradient aspect; `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→no tile` | `texturemap.inc:433-447` (dirX=lh-rh, dirY=th-bh), `:557-575`, `:592-601`; `cMaxHeight=2.96`:29 | **observed** | 2 |
| C14 | Donor normals are per-vertex `gl_Normal` transformed by `gl_NormalMatrix`, produced by a height-field object callback `THeightFieldGetHeightEvent(x,y,z,out color,out texPoint)`; **exact engine normal formula UNVERIFIED** | `hf.pvl.sm.vert:15`; DEEPDEC-02 evidence `ev_4e4eeb88…` (RTTI at `0x54198b…0x541b57`) | **observed** (shader+RTTI), **UNVERIFIED** (producer math) | 2 |
| C15 | Cliff/vertical-face materials use eye-linear texgen planes + `TextureScale=0.125` + 25° tile tilt; triangle submission indexed `GL_UNSIGNED_INT`, no VBOs, per-vertex normal/pos + 2 UV streams; object-identity of the submitter UNVERIFIED | `reftile.mat:111-169`; `tiles.lib:121,131,141… AngleZ=25`; DEEPDEC-02 §3.1–3.3 (evidence ids) | **observed** (text), **UNVERIFIED** (binding) | 2 |
| C16 | `.map` stores a baked `float32[W*H]` height grid after a repeated `u32 W,u32 W` header; W/H 320 for bonmis1/engmis4, 384 for battle1 | `variant3d/tools/import_donor_map.py:113-174` (DECOMP-06/DEEPDEC-05), B3 decode | **observed** | 2 |
| C17 | Port mesh: one shared vertex per cell centre; `(w-1)(h-1)*2` triangles; central-difference normals over `2*TILE_M`; UV 0..1 map-wide; no LOD, no extruded walls, no collision shape | `variant3d/scripts/world3d_terrain.gd:664-729`, `:385-399`, `:623-660`; `heightmap_world3d.gd:183-225` | **observed** | 2 |
| C18 | Port source heights are procedural: gaussian mask ramp + analytic ellipse/dome/ravine profiles, NOT the donor pattern float grids | `variant3d/scripts/mapgen.gd:63-73` (`relief()` approximation), `game.gd:858-981` (analytic `_shape_stamp_relief`), `game.gd:1024-1043` (parabolic domes) | **observed** | 2 |
| C19 | Donor height-grid→surface-mesh tessellation / distance LOD remains UNVERIFIED; only the 4 relief props are explicitly listed as `LODActorName` | `actors.lib:1200-1213`; `refmountain.actor:34-40` (no distance thresholds); G31 §2b | **UNVERIFIED** (surface LOD), **observed** (props) | 2 |
| C20 | Port `TILE_M=2.0` m/cell and `HEIGHT_SCALE=1.0` are port facts; donor metres-per-cell is UNVERIFIED | `world3d_terrain.gd:93-95`; `heightmap_world3d.gd:31-33`; DEEPDEC-02 gap #11 | **observed** (port), **UNVERIFIED** (donor) | 2 |

---

## 3. Donor height → world formula (derived from C3, C5, C7)

Donor generator uses **centred integer coordinates**. For a map of width `W`,
height `H` (cells), with `lx = -(W div 2)`, `ty = -(H div 2)`:

```
# 1. sample the authored terrain mask (C3, generatemap.inc:541-543)
bitmap_x = floor( generator_x / W * trgW )
bitmap_y = floor( generator_y / H * trgH )
(fr, fg, fb, fa) = GetBitmapPixel(mask, bitmap_x, bitmap_y)   # 0..1

# 2. terrain class from mask R decode (generatemap.inc:352-370 / :454-472,
#    C1/C2) -> cRPlateau / cRHill / cRRavine, or smooth variants, or none
# 3. height in DONOR HEIGHT UNITS (C4, generatemap.inc:567-574):
hwater   = -1.1 * fb * (1 + fr*3.5)
hterrain = { +2.964*fr        if class = plateau (R=255/191)
           { +1.31733*fr      if class = hill    (R=96/112)
           { -2.964*fr        if class = ravine  (R=48/88)
           { 0                otherwise (R=0/64)
h        = hwater + hterrain
realx    = floor(lx + generator_x)        # centred engine-grid X
realy    = floor(ty + generator_y)        # centred engine-grid Y
SetHeightData(realx, realy, h)            # generatemap.inc:574

# 4. per-cell height is then stamped/overwritten by relief patterns:
#    h_final ≈ clamp( h + grid_value * HeightFieldScale + HeightFieldOffset,
#                     HeightFieldMin, HeightFieldMax )       [INFERRED blend]
#    grid_value = float32 from <pattern>.pattern at (u,v), u,v in 0..w-1/0..h-1
#    pattern.lib supplies HeightFieldScale/Min/Max/Smooth* (C7)

# 5. smoothing passes (generatemap.inc:587-592, :606, :611-640)
#    bsmooth cells: SmoothTerrain(x,-y,False,3)
#    all land:      _misc_SmoothTerrainCustom(1, power=4, lerp=0.5,
#                                            minh=0.01, maxh=100)
#    coastal underwater: 3 passes rad=2, power=0.35, lerp=0.5, h in [-100,-0.01]

# 6. engine-grid cell -> world position (port analogue, donor metre scale UNVERIFIED)
world_x = ( realx + W/2 + 0.5 ) * CELL_METRES      # donor Y-up Z-up swap below
world_z = ( realy + H/2 + 0.5 ) * CELL_METRES      # port uses TILE_M = 2.0 (C20)
world_y = h_final * HEIGHT_SCALE                   # port HEIGHT_SCALE = 1.0
# donor is Z-up (hf shader / water lightVector), Godot is Y-up:
#   (donor X, donor Y, donor Z=height) -> (Godot X, Godot Y=height, Godot Z)
```

**Storage/indexing**: the shipping `.map` bakes the final grid as row-major
`float32[idx]` with `idx = y*W + x` over the centred domain
(`import_donor_map.py:88,133-169`, C16). The port's dump uses the identical
recipe (`main.gd:688-695`); the port's `(x+0.5-w/2)*TILE_M` vertex layout is
therefore the correct *structure*, but the *values* fed into it are wrong (§6).

---

## 4. Constants table (donor literals, with citations)

| Constant | Donor value | Donor source | Meaning |
|---|---|---|---|
| `cPlateauHeight` | `2.964` | `generatemap.inc:4` | plateau amplitude at R=255 |
| `cHillHeight` | `2.964/2.25 = 1.31733…` | `generatemap.inc:5` | hill amplitude at R=96 |
| `cRavineHeight` | `-2.964` | `generatemap.inc:6` | ravine amplitude at R=48 |
| `cWaterHeight` (height gen) | `-1.1` | `generatemap.inc:7` | deep-water bed term |
| `cWaterHeight` (classify) | `-0.25` | `texturemap.inc:30` | water test for collision/tiles |
| `cWaterShoreHeight` | `-0.1` | `texturemap.inc:31` | shore test |
| `cMaxHeight` | `2.96` | `texturemap.inc:29` | nominal ceiling |
| R codes plateau/hill/ravine | `255/96/48` | `generatemap.inc:21-23` | mask R terrain class |
| R smooth codes | `191/112/88`; none-smooth `64` | `generatemap.inc:24-27` | class + `bsmooth` flag |
| R multiplier in `hwater` | `3.5` | `generatemap.inc:567` | `-1.1*fb*(1+fr*3.5)` |
| `cDiff1` / `cDiff2` | `0.5` / `0.55` | `texturemap.inc:63-64` | cardinal / diagonal collision gates |
| Map sizes | `320/480/640/256`, else `320` | `miscext2.script:19-26` | height grid side length |
| `gc_MaxMapWidth/Height` | `640` | `dmscript.global:132-133` | cap |
| `gc_MaxColMapWidth/Height` | `2*640 = 1280` | `dmscript.global:134-135` | 2× collision grid |
| `gc_terraindata_collision` | `4` | `dmscript.global:80` | 4 collision tags per terrain tile |
| `TMapTerrainDataTile` | `{height:Float, tex:int, collision:int[4]}` | `dmscript.global:2026-2030` | per-cell terrain record |
| Rock tile thresholds | `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→none` | `texturemap.inc:594-601` | height-driven rock art |
| Cliff tile tilt | `AngleX=25`/`AngleZ=25` | `tiles.lib:121,131,141,…` | 25° face pairs |
| Cliff texture repeat | `TextureScale=0.125` (1/8) | `reftile.mat:124-127` | eye-linear tiling |
| Relief stamp scale | `HeightFieldScale` (mostly 1.0; sets `±0.925`, `1.5`, `0.65` for brush/plt) | `pattern.lib:14,332-334,33094` | per-pattern height multiplier |
| Relief stamp clamp | `HeightFieldMin/Max` e.g. plateau `[-0.0949,3.4967]`, hill `[0,3.8613]`, ravine `[-2.9636,3.1398]` | `pattern.lib:351-352, 33111-33112, 549585-549586` | per-pattern authored amplitude |
| Relief smoothing | `HeightFieldSmooth` + Radius `2/3`, Factor `4`, Offset `0/2` | `pattern.lib:18-21,339-341,549572-549575` | stamp-local smoothing |
| Cell size in metres | **UNVERIFIED** (port uses `TILE_M=2.0`) | `world3d_terrain.gd:93`; DEEPDEC-02 gap #11 | world scale |

---

## 5. Geometry pipeline pseudocode (donor, reconstructed)

```
# --- A. BASE HEIGHT GRID (skirmish / random map) ---
mask = choose(data/gen/terrainmasks.src/<type>/*.tga)       # D14; generatemap.inc:537-547
for gy in 0..H-1:
  for gx in 0..W-1:
     mask_px = mask[floor(gx/W*Wmask), floor(gy/H*Hmask)]     # :541-543
     R,G,B = decode(mask_px)                                  # :352-383 / :454-472
     if random_map and R==1 and B==1: continue                # start pixel :565
     h = -1.1*B*(1+R*3.5) + class_height(R)                   # :567-573
     SetHeightData(gx-W/2, gy-H/2, h)                         # :574, misc.script:68-72

for cell in grid:
  if bsmooth(cell): SmoothTerrain(x,-y,False,3)               # :587-592
  else: SmoothTerrainCustom(x,y,1,power=4,lerp=.5,.01,100)    # :606
  coastal_underwater_3_passes(rad=2,power=.35,lerp=.5)        # :611-640

# --- B. RELIEF STAMPS (dogenerate.inc stage 9, D1:1621-1770) ---
for family in [mountains, plateau_big, plain_huge, ravine_big,
               plateau, plateau_small, hills_dark, hills_light]:
    freq = relieftype_table[family] * problarge               # TERRAIN_DONOR_PIPELINE §3.5
    for each accepted placement (x,y):
        pat = weighted_pick(family)                           # generator.cfg Freq
        # engine-side stamp consuming BOTH payloads in <pat>.pattern:
        #   (a) w*h u8 occupancy mask  -> placement / object footprint
        #   (b) w*h f32 height grid    -> per-cell height delta      [C6]
        # config from pattern.lib [C7]:
        #   HeightFieldScale, HeightFieldMin/Max, HeightFieldSmooth*
        h[cell] = clamp(h[cell] + grid[cell]*scale + offset,
                        HeightFieldMin, HeightFieldMax)        # blend INFERRED
        if pat is mountain: instantiate terrainmeshN.osm prop  # C8, C9
        freq *= 0.2  (floor 1e-4)                              # self-limiting

# --- C. COLLISION + TILE ART from the SAME FIELD (texturemap.inc) ---
for cell in grid:
  if mask.B>0 and h<-0.25: MapDrawCollision(..., tag_water)    # :68-86
  if |h-h(left/right/top/bottom)|>0.5: MapDrawCollision(tag_terrain)  # :88-115
  if |h(br)-h(rb)|>0.55 or |h-rbh|>0.55: ...                   # :116-129
  # drawn on 2x collision grid at 0.5-cell offsets (:133-134)
  dirX,dirY = h(left)-h(right), h(top)-h(bottom)              # :438-439
  sector = quantise_8(dirX,dirY)                             # :445-447, :560-575
  if collision_tag>0: tile = rock_by_sector; if abs(h)>2.7: rock8; ... # :592-601

# --- D. RENDER ---
# one lit heightfield surface (shader HeightField; normals from height-field
# object), PLUS placed 3D relief props; cliff faces use verticalfront/side
# materials with eye-linear texgen and 25° tile tilts.               [C14,C15]
# submitted as indexed GL_TRIANGLES with per-vertex normal + 2 UV streams;
# cached in GL display lists keyed by object fields (DEEPDEC-02 §3.1).
```

---

## 6. Bbox / volume sanity numbers

**Donor map grids decoded (B3, 2 maps, read-only):**

| Map | W×H | cells | h min | h max | span | mean | `h=0` | `h=-1.1` | `h=+2.964` | `h=-2.964` |
|---|---|---|---|---|---|---|---|---|---|---|
| bonmis1 | 320² | 102,400 | −2.96399999 | +2.96399999 | 5.928 | −0.072741 | 31.97% | 21.69% | 4.18% | 0.48% |
| engmis4 | 320² | 102,400 | −2.96399999 | +2.96399999 | 5.928 | +0.252345 | 64.31% | 0.48% | 9.07% | 0.02% |

Derived, at port `TILE_M=2.0` m/cell: 320² map = **640×640 m**, height span
**5.928 m** (relief/width ≈ 0.9%). Volume above the −1.1 water bed:
`102,400 cells × 4 m² × (mean+1.1)` = **≈4.21×10⁵ m³** (bonmis1) /
**≈5.54×10⁵ m³** (engmis4). Full-column envelope between min and max planes
= `102,400×4×5.928 ≈ 2.43×10⁶ m³`. These are sane and explain the flat local
view: over a 640 m map the average gradient is well under 1%.

**Decoded relief props (B1):** each `terrainmesh*.osm` spans ≈26–28 donor
units in X/Y and rises 6.9–9.6 units in Z; `terrainplateau1` spans
x[-10.9,11.3] y[-12.3,11.3] z[-5.35,5.35] (a symmetric cut/gorge form),
`terrainplateau2` rises to z=10.93. If 1 donor unit ≈ 1 cell ≈ 2 m, these are
≈52–56 m wide props with 14–22 m relief — i.e. **donor mountains are mostly
explicit 3D props**, not heightfield bumps.

**Smallest-map cases (for the fix recipe):**

| Map | cells | shared vertices | triangles `(W-1)²×2` | area @2 m/cell |
|---|---|---|---|---|
| port fixture 64² (`t_smallmap_terrain.gd:3`) | 4,096 | 4,096 | 7,938 | 128×128 m |
| donor minimum 256² (`miscext2.script:23`) | 65,536 | 65,536 | 130,050 | 512×512 m |
| port default 320² (G32 measured) | 102,400 | 102,400 | 203,522 | 640×640 m |

---

## 7. What exists / is missing / is wrong in our port

### 7.1 Structurally correct (keep)

- One indexed `ArrayMesh`, one surface, one draw call over the full grid —
  `world3d_terrain.gd:664-729`; this is a sound fix for the old M0.6 flat-quad
  terracing (G31 §3).
- Cell-centre vertex mapping and row-major decode match the donor `.map`
  layout (C3/C16, `world3d_terrain.gd:685-690`).
- Normal computation from height gradients (`world3d_terrain.gd:385-399`) is a
  plausible analogue of the donor's per-vertex normals (C14) — flagged as port
  analogue, not parity.
- Donor collision thresholds (`cDiff1=0.5/cDiff2=0.55`) are reused for both
  `blocked[]` (`game.gd:1106-1118`) and the shader face mode
  (`world3d_terrain.gd:360-382`), and relief shaping runs **before** collision
  (`game.gd:1080`, `:1106`) — ordering is correct.
- Height is now clamped to `[-2.964,+2.964]` (`game.gd:981,1096-1097`), matching
  the donor ceiling observed in B3.

### 7.2 Wrong / missing — geometry only (no texture claims)

1. **Source heights are not donor relief.** The port's `height[]` comes from a
   blurred/gaussian terrain mask plus `mapgen.gd:63-73 relief()` bands and
   analytic ellipse/dome/ravine profiles (`game.gd:858-981`), whereas the donor
   embeds **authored per-cell float32 relief grids** in `.pattern` files (C6)
   with per-pattern scale/clamp/smoothing (C7). Consequence: the donor's
   asymmetric ravine cross-sections (e.g. `k_ravine_1` depth ramp to −2.36
   before clamp), plateau caps and hill crests are replaced by smooth symmetric
   analytic functions. This is the primary shape gap, and it is upstream of the
   mesh — a better mesh cannot invent missing samples (G31 §3).
2. **`relief()` is wrong for smooth R codes.** Port maps R=191/112/88/64
   through a ±12 band + `×0.5` fallback; donor uses the exact class×R formula
   (C2/C4). Confirmed divergence in `TERRAIN_DONOR_PIPELINE.md` C3; still
   present at `mapgen.gd:63-73`.
3. **No 3D relief props.** Donor mountain/plateau patterns instantiate
   `terrainmesh{1..4}.osm` / `terrainplateau{1..4}.osm` real meshes (C8/C9);
   the port has no such geometry at all. For "hills/mountains look flat", this
   is arguably a bigger gap than the grid itself: the donor's visible mountain
   silhouette is a 7–10-unit-tall mesh, not a grid bump.
4. **No cliff/vertical-face geometry.** The donor renders `verticalfront` /
   `verticalside` faces with 25° tilt and eye-linear projected UVs (C15, D11);
   the port's surface is one continuous heightfield with `CULL_DISABLED`
   (`world3d_terrain.gd:328-344`) and no extrusion. Steep cells are sloped
   triangles, not faces. (Face *art* is out of scope here; the missing *face
   geometry* is in scope.)
5. **Normals over-smoothed.** `2*TILE_M` central differences
   (`world3d_terrain.gd:389-399`) smooth a 2-cell-wide step; donor normals come
   from the height-field object (C14) and can be face-sharp. No test measures
   this today.
6. **No LOD / tessellation.** The whole grid is always full-resolution; the
   donor has explicit relief LOD props (C8/C19). Height-grid LOD itself is
   UNVERIFIED in the donor, so do **not** invent a donor LOD scheme.
7. **Collision/walkability is not mesh-linked.** In Godot there is no
   `CollisionShape3D`/trimesh from `world3d_terrain.gd`; `blocked[]` is a
   separate 1-per-cell byte in `game.gd`, while the donor applies collision on
   a 2× grid at 0.5-cell offsets from the same field (C12). The port's visible
   steep slope can be walkable or blocked inconsistently at sub-cell edges.
8. **Cell size unvalidated.** `TILE_M=2.0` and `HEIGHT_SCALE=1.0` (C20) make
   relief ≤1% of map width; without a donor metre constant, a visually flat
   map may be a scale error rather than a shape error. Explicitly UNVERIFIED.

### 7.3 Directly refutes prior doc claims

- `TERRAIN_PORT_HILLS.md:167-169` and `PIECES/plateau.md:41-46` state "the
  plaintext scripts never add height from a stamp / per-cell height fields
  undecoded". **Corrected**: `pattern.lib` (C7) and the `.pattern` float grids
  (C6) are the missing half. The port comment at `game.gd:862-864`
  ("donor's per-cell height fields are undecoded") is now stale.
- `G31_donor_3d_truth.md` Q2 / G32 Q2 ("height-grid→mesh LOD UNVERIFIED")
  remains UNVERIFIED (C19); DTRN-02 adds no connector, only the prop list.

---

## 8. Concrete fix recipe — geometry only, smallest map first

Target: **64×64 fixture** (`variant3d/tests/t_smallmap_terrain.gd:3`) with a
single relief stamp of each class; then repeat at donor minimum **256²**.
No texture, shader, HUD, or asset changes.

**Step 0 — baseline dump (before any edit).**
`python variant3d/tools/godot_runner.py run --id dtrn02_base64 -- --headless --path variant3d -- --config <abs>/small_map_64.json --dump-map <temp>/dtrn02_64.json`
Record `height[]` min/max, plateau/ravine fractions, mesh vertex/triangle counts.

**Step 1 — export donor relief grids (read-only, temp output only).**
Parse `pattern.lib` into `{name: {Width,Height,HeightFieldScale,Min,Max,Smooth*,TerrainScale,CollisionStand}}`.
For each relief pattern, read `data\pattern\<name>.pattern`: `w,h = int32[0:2]`,
mask = `w*h` bytes at offset 8, height grid = `w*h` float32 starting at/near
offset `8+w*h` (verify `min/max ≈ HeightFieldMin/Max`; C6). Emit a **derived
JSON** (numbers only — no donor binary copied) into `variant3d/assets/terrain/structs/`.

**Step 2 — replace analytic profiles with donor grids.**
In `game.gd:_shape_stamp_relief()` (`858-981`), for each stamp:
- iterate occupied `(u,v)` cells of the exported grid (not the dilated ellipse);
- map `u,v` to map tiles with the existing `s = MAP_W/160` scale, clamped to
  the 64² map — at 64² only compact patterns fit (`brush_plt_*`, `hil1..4`,
  `k_ravine_2/4`); `f_plt_big_*` (81×93) must be skipped or windowed;
- `height[i] = clamp(h_base + grid[cell]*scale + offset, MN, MX)` using the
  exported `HeightFieldScale/Min/Max`; expose the unknown engine blend
  (`Replace`/`Smooth`) as a flag, default additive, labelled `PORT APPROXIMATION`.

**Step 3 — fix the base relief decode.** Replace `mapgen.gd:63-73 relief()`
with the exact R-code→class→amplitude mapping of C2/C4
(`255/191→+2.964*R/255`, `96/112→+1.31733*R/255`, `48/88→−2.964*R/255`,
`64→0` with `bsmooth`); unit-test the 7 codes before wiring.

**Step 4 — add relief props (biggest visual win for mountains).**
Bake `terrainmesh1..4.osm` and `terrainplateau1..4.osm` to glTF with the
existing read-only `.osm` reader (`DC_FORMATS.md:66-95`); instantiate at
mountain/plateau stamp centres with **authored scale** (`dogenerate.inc:1984`
excludes these from random scaling). On 64² place at most 1 prop of each kind.
No donor `.osm` in the runtime asset tree — only derived glTF.

**Step 5 — mesh/normal fidelity.**
In `world3d_terrain.gd`:
- compute normals with a **1-cell** stencil (`dx = TILE_M`, not `2*TILE_M`) so a
  1-cell cliff step is not averaged away (keeps donor-like sharp relief);
- optionally emit steep cells (`|dh|>0.5`) as duplicated-vertex vertical quads
  with a face-mode attribute (the shader work is decoupled — geometry only);
- expose `stats["height_source"]`, `stats["relief_grid_cells"]`,
  `stats["prop_count"]` for measurement.

**Step 6 — collision parity.** Keep relief shaping before `blocked[]` (already
true at `game.gd:1080`/`:1106`). Add an optional 2× sub-cell collision sampler
(`texturemap.inc:133-134`) so a steep 1-cell step cannot be walked through at
edges; gate it behind a config flag on the 64² test.

**Step 7 — acceptance gates on 64² (then 256²).**
- `height` min/max inside `[−2.964, +2.964]` exactly (donor B3 behaviour);
- ≥1 contiguous elongated `h>0.5` component with bbox aspect ≥1.4 when a hill
  stamp is placed (`hill_ridge.md` M1);
- ravine stamp produces at least one cell with `h < −2.0` and a depth profile
  whose first 8 cells are monotonically decreasing (donor `k_ravine_1` ramp);
- `mesh_vertices = 4096`, `mesh_triangles = 7938`, `mesh_surfaces = 1`;
- no `blocked[]` cell inside C1/C2 around any start;
- prop count = expected stamps, each within map bounds;
- re-run `t_smallmap_terrain.gd` + 29/29 selftest + 2D gates before any combo.

Do **not** attempt to assert a donor LOD tessellation formula (C19 UNVERIFIED),
and do **not** tune textures, sky, fog or water in this ticket (terrain shape
only), per owner directive "piece before whole".

---

## 9. Open questions

1. **Engine blend math for height stamps** — `HeightFieldReplace`,
   `HeightFieldReplaceForWater`, `HeightFieldSmooth` semantics are config-only;
   no plaintext consumer found. Step 2 uses an inferred additive clamp.
2. **Exact byte offset of the float grid** in `.pattern` — matched min/max at
   offsets within ±16 B of `8+w*h`; per-pattern alignment/count header not
   proven (C6). DEC-05 (sibling) may close this.
3. **Height-grid surface tessellation / LOD** — still UNVERIFIED (C19).
4. **Donor metres per cell / height unit** — UNVERIFIED (C20); blocks any
   absolute "donor is flatter/steeper than port" claim.
5. **Which `terrainmeshN` is chosen at runtime** for a given mountain stamp —
   `pattern.lib` lists several per family; selection rule engine-side.
6. **`HeightFieldScale=±0.925` on `brush_plt_*`** — sign convention could invert
   small plateau edits; needs a stamp-level probe before copying.
7. **2× collision grid consumption at runtime** — the donor writes it
   (`texturemap.inc:133-134`) but how units query it is engine-side.
8. **Cross-check with DEC-05** (sibling: terrain formats) — this report decodes
   only what geometry needs; do not duplicate its tile/blend conclusions.

---

## 10. Summary

- **Donor truth (observed/decoded, 2–3 passes):** terrain height is a centred
  per-cell float grid (256/320/480/640²), sourced from authored terrain-mask TGA
  bitmaps via an exact class×R formula, then **sculpted by relief patterns that
  embed their own w×h float32 height grids** with per-pattern scale/clamp/
  smoothing in `pattern.lib`, then smoothed (3 passes), and finally **baked into
  `.map` files clamped to ±2.964**. Collision uses the same field on a 2× grid
  with `0.5/0.55` height-delta gates; rock art is gated by that collision tag.
  Mountains/plateaus additionally instantiate real 3D relief props
  (`terrainmesh1..4.osm`, 2,177–2,662 verts each) as part of the stamp.
  Surface-mesh LOD is UNVERIFIED; the prop `LODActorName` list is observed.
- **Port:** mesh structure and ordering are sound, but the **source heights are
  procedural/analytic rather than the donor's authored relief grids**, the
  smooth R-code mapping is wrong, there are **no 3D mountain/plateau props**,
  no cliff-face geometry, over-smoothed normals, no LOD, and collision is a
  separate 1× array rather than the donor's 2× grid. These are shape/quality
  defects independent of textures and are the correct targets for DTRN follow-up.
- **Smallest first:** 64² dump → export donor relief grids → exact R decode →
  one stamp per class → 1 prop per kind → 1-cell normals → 64² acceptance gates;
  only then 256², then combos. No donor binary copied, no Godot run, no code edit.
