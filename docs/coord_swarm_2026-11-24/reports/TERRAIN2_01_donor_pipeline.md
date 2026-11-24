---
id: TERRAIN2-01
scope: "How the donor actually builds and renders terrain: map/height data -> mesh -> tile selection -> shading -> water. Text/data audit only."
date: 2026-11-24
status: DELIVERED__AUDIT_ONLY__NO_DONOR_BINARY_EXECUTED
donor: "C:\Games\Cossacks 3 (READ-ONLY private use; Python bytes + latin-1; no file copied/executed)"
output: "docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md"
governing_rule: "docs/coord_swarm_2026-11-24/TERRAIN2_CHARTER.md:6-15 — donor path:line for every fact; OBSERVATION vs INFERENCE; UNVERIFIED where unreadable; no invented constants."
---

# TERRAIN2-01 — Donor terrain pipeline from source text

## 0. Method and evidence discipline

- Read first: `TERRAIN2_CHARTER.md:1-39`; cross-checks `G31_donor_3d_truth.md`,
  `G32_heightmap_world.md`, `V71_mechanics_inventory.md` — each independently
  re-verified against donor bytes below, not trusted as authority.
- All donor reads: `open(path,'rb').read()` decoded latin-1, line numbers 1-based
  from `split('\n')`; binary headers via `struct.unpack_from`. No donor file was
  modified, executed, or copied. No port source/asset/config/test was edited.
- Labels: **OBS** = literal donor line / byte-decoded header; **DERIVED** =
  arithmetic/control-flow consequence of cited lines; **INFER** = reading with a
  stated caveat; **ENGINE** = behaviour that must live in the closed binary and
  is not specified by readable data; **UNVERIFIED** = not provable from text.
- Paths below are relative to `C:\Games\Cossacks 3\` unless prefixed otherwise.
  Port citations are relative to the workspace root.

## 1. Evidence table (all facts carry donor `path:line`)

| # | Evidence (path:line) | Observation / derivation | Label |
|---:|---|---|---|
| E01 | `data\scripts\dmscript.global:78-81` | `gc_terraindata_mapwidth=640`, `mapheight=640`, `collision=4` | OBS |
| E02 | `data\scripts\dmscript.global:132-135` | `gc_MaxMapWidth/Height=640`; collision grid `2*640=1280` per axis | OBS |
| E03 | `data\scripts\dmscript.global:2026-2035` | `TMapTerrainDataTile = {height:Float, tex:Integer, collision:Integer[4]}`; array `[640][640]` | OBS |
| E04 | `data\scripts\lib\miscext2.script:19-26,45` | mapsize 0/1/2/3/else -> w = 320/480/640/256/320; `SetMapNeeded(filename,zone,preset,w,w,...)` | OBS |
| E05 | `data\gui\menu.inc\donewgame.inc:42-48,166` | same size table on skirmish creation; `GenerateMapNeededExtBorder(...,genMapSize,genMapSize,genCells,...)` | OBS |
| E06 | `data\gen\globalparams.cfg:8` | `DefaultMapSize = 256` | OBS |
| E07 | `data\scripts\common.inc\generatemap.inc:4-7` | `cPlateauHeight=2.964`, `cHillHeight=cPlateauHeight/2.25`, `cRavineHeight=-2.964`, `cWaterHeight=-1.1` | OBS |
| E08 | `generatemap.inc:9-32` | terrain classes 0..3 (plateau/hill/ravine); source-bitmap colour codes R=255/96/48, G=255/64/128/192, B=255 | OBS |
| E09 | `generatemap.inc:35-44` | generation switches: reset height, gaussian postprocess, `cLoadHeightDataFromTexture=True`, two smoothing passes, place water/forest, texture terrain, smooth tile, load texture | OBS |
| E10 | `generatemap.inc:57,71,285-292` | default input `.\data\gen\bitmap\bitmapsrc.bmp`; editor asks for size `320-640`; `LoadBitmap(srcbitmap,srcbitmappath)` then `GetBitmapSize` | OBS |
| E11 | `generatemap.inc:295-300` | if source bitmap dimensions differ from map grid, code only comments out the error — no resample here | OBS |
| E12 | `generatemap.inc:315-324,397-412` | source bitmap resized by `floor((x/mapwidth)*srcwidth)` sampling; RGBA floats `fr,fg,fb,fa` read per cell | OBS |
| E13 | `generatemap.inc:413-449` | pure white source pixel = player start; R/G/B/A stored in `gMapMask[x,y]`; alpha = road flag | OBS |
| E14 | `generatemap.inc:454-472` | R byte 255/128 -> plateau, 96/80 -> hill, 48/88 -> ravine, else none; sets `bsmooth` | OBS |
| E15 | `generatemap.inc:473-480` (+ `classes.script:4852-4859`) | G byte -> forest class; `TGeneratorBitmapMask = {r,g,b:Float; terrain,water,forest:Integer; bsmooth,broad:Boolean}` | OBS |
| E16 | `generatemap.inc:537-547` | target bitmap resampled into `gMapMask[x,y].r` and `.b` (R and blue channel) | OBS |
| E17 | `generatemap.inc:552-577` | **height formula**: `hwater=cWaterHeight*(fb*(1+fr*3.5))`; `hterrain=cPlateauHeight*fr` / `cHillHeight*fr` / `cRavineHeight*fr` by class; `SetHeightData(realx,realy,hwater+hterrain)` | OBS |
| E18 | `generatemap.inc:218-245` | `_misc_SmoothTerrainCustom`: 4-neighbour + diagonal average, `res=h+((z1+z2)/2-h)/power`, then `Lerp(h,res,lerp)`; border-clamped | OBS |
| E19 | `generatemap.inc:580-596` | bitmap-driven smoothing: `SmoothTerrain(realx,-realy,False,3)` on `bsmooth` class-transition cells (note `-realy`) | OBS |
| E20 | `generatemap.inc:598-643` | global smoothing: `power=4, lerp=0.5, range [0.01,100]`; then 3 passes of water-adjacent smoothing `power=0.35,lerp=0.5,range[-100,-0.01]` within radius 2 | OBS |
| E21 | `data\scripts\lib\misc.script:66-72` | `_misc_GetMapLeftTopPos`: `x=-(GetMapWidth div 2)`, `y=-(GetMapHeight div 2)` — cell indices are centred on world origin | OBS |
| E22 | `scripts\editor.inc\savemapterraindata.inc:11-19` | editor snapshot stores per cell `height=GetHeightData`, `tex=GetTileIndex`, 4 collision tags at `realx+(colind div 2)*0.5, realy+(colind mod 2)*0.5` | OBS |
| E23 | `scripts\editor.inc\loadmapterraindata.inc:26-37` | restore applies the same triple; confirms 2× collision resolution | OBS |
| E24 | `data\scripts\common.inc\texturemap.inc:29-31` | `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` | OBS |
| E25 | `texturemap.inc:53-129` | collision tags from height differences `cDiff1=0.5`, `cDiff2=0.55` against 4/8 neighbours | OBS |
| E26 | `texturemap.inc:426-445` | per-cell height `h` and 4 neighbour heights; `dirX=lh-rh`, `dirY=th-bh`; normalise, `vecangle=VectorAngle(1,0,0,dirX,0,dirY)` with sign on `dirY<0` | OBS |
| E27 | `texturemap.inc:463-471` | water/shore classification only where source B>0: `h<cWaterHeight` water, `h<cWaterShoreHeight` shore | OBS |
| E28 | `texturemap.inc:474-511` | aspect quantised to 8 sectors of `cAngle=45°` (+180°), booleans bR/bRB/bB/bLB/bL/bLT/bT/bRT; picks `sandsea1..6` | OBS |
| E29 | `texturemap.inc:557-610` | collision/edge cells: aspect -> `rock1/3/4/7`; `Abs(h)>2.7 -> rock8`, `>2.4 -> rock4`, `<0.1 -> none`; winter suffix; `MapGetTileIndexByTileBlock` -> `SetTileIndex` | OBS |
| E30 | `texturemap.inc:617-646` | roads: `ground1`/`test2`/`test3` by `RandomExt` where source A>0 | OBS |
| E31 | `data\scripts\common.inc\loadtextureterrainfrombitmap.inc:4-42` | base tile from `tile_lowground.bmp` if `h<0.1`, else `tile_highground.bmp`; `tex=floor(r*255) div 2`; applies only where `GetTileIndex=0` | OBS |
| E32 | `data\scripts\common.inc\smoothtiles.inc:1-80` | loads `.\data\gen\tilesmooth_scripts.cfg`; per-rule weighted random `TileIndex` substitution using neighbouring tile names | OBS |
| E33 | `data\gen\tilesmooth_scripts.cfg:1-35` | exact weights: `sandsea1..4` each `Prob=1`, `sandsea5=0.7`, `sandsea6=0.3` | OBS |
| E34 | `data\terrain\tiles\terrain.presets:2-5,6-129,133-137,138-261` | Summer/Winter block index order; vf/vs/alpha blocks inlined; `DefaultIndex=0` | OBS |
| E35 | `data\terrain\tiles\tiles.lib:1-2,119-136,209-217` | `rock1vf {AngleX=0, AngleZ=25}`, `rock1vs {AngleX=25, AngleZ=0}`; same for sand1f/s | OBS |
| E36 | `data\terrain\tiles\tiles.mat:1-8,142-156,346-359` | each tile block -> `.\data\terrain\tiles\textures\*.dds`; vf/vs use refkeys `verticalfront`/`verticalside`; alpha blocks add `Texture2Name=alphanull` | OBS |
| E37 | `data\terrain\ref\reftile.lib:1-12` | `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`; commented `TileSize=64/Rows=16/Cols=16/AlphaRows=8/AlphaCols=4/AlphaTileSize=64` | OBS |
| E38 | `data\terrain\ref\reftile.mat:6,17,29,32-37,120-169` | `Texture2Name=alpha`, `BlendingMode=bmTransparency`, nearest mag / nearest-mipmap-linear min, isotropic; vertical variants: `Texture2Name=alphavert`, `TextureScale=0.125`, `mappingmode=tmmEyeLinear`, S from X or Y, T from Z | OBS |
| E39 | `data\terrain\ref\reftilealpha.mat:3,30-35,112,139-144,221,248-253` | alpha materials: `alpha.bmp`, `alphavert.bmp`, `alphanull.bmp`; `textureformat=tfAlpha`, `imagealpha=tiaAlphaFromIntensity` | OBS |
| E40 | `data\terrain\tiles\terrain.lib:3,5-15,17` | `Default=Summer`; seasons Autumn/Spring=Summer, Winter=Winter; `TextureScale X/Y/Z/W=1`; `CoverDisabled=true` | OBS |
| E41 | `data\gen\mapcover.cfg:5-18` | `HeightTileZones[0] = HeightZone0, MinHeight=0, MaxHeight=100` with all seasonal tile names empty; `PatternCovers` empty | OBS |
| E42 | `data\pattern\pattern.lib:8-33` | every brush: `HeightFieldStand=True`, `HeightFieldReplace`, `HeightFieldReplaceForWater`, `HeightFieldSmooth/Radius/Factor/Offset`, `HeightFieldMin/Max/Offset`, `TerrainScale=1` (:15) | OBS |
| E43 | `data\shaders\shaders.lib:15-52` | `ShadersSM20.HeightField`: vert `hf.pvl.sm.vert`, frag `hf.pvl.smx3.frag`, `tangentSpace=false`, `boneMatrices=false`, `cameraMVM/fogMode/shadowed/vertexColor/texShadow/texGen=true`, two samplers bound to 0 and 1 | OBS |
| E44 | `data\shaders\obj\hf.pvl.sm.vert:9-15,17-23,25-39,41-49` | eye-space position `realpos`, `n=normalize(gl_NormalMatrix*gl_Normal)`, per-vertex Blinn–Phong, eye-plane texgen `dot(realpos, gl_EyePlaneS/T[0])`, shadow coord, lighting into TexCoord[4]/[5], fog distance into TexCoord[0].w | OBS |
| E45 | `hf.pvl.smx3.frag:13-17,20-30,34-47` | RGB from `texUnit0`, alpha from `texUnit1`; `color.xyz*ambient+diffuse+specular`; 3-tap `sampler2DShadow` PCF with `of=1/512`; fog LINEAR/EXP/EXP2 | OBS |
| E46 | `hf.pvl.smx9.frag:22-35` | 9-tap PCF with same `of=1/512` | OBS |
| E47 | `data\shaders\obj\def.pvl.sm.vert:29-35` | non-heightfield shader uses plain `gl_MultiTexCoord0` — eye-plane texgen is specific to HeightField | OBS + DERIVED |
| E48 | `data\actors\env\terrainmesh1.actor:1-4` (+2/3/4 analogous) | each relief mesh bound via `ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile=...*.osm` | OBS |
| E49 | `data\actors\ref\refmountain.actor:34-40` | `TangentSpace` commented out; `BinormalsTexCoordIndex=1`, `TangentsTexCoordIndex=2`, weight/mat indices 4/5 configured | OBS |
| E50 | `data\objects\env\terrainmesh1.prop:9-18` | `LODActorName/LastDefaultMeshName`, summer `terrainmesh1`, winter `terrainmesh1w` | OBS |
| E51 | `data\actors\actors.lib:1200-1225` | relief actor list: terrainmesh1..4 **and** terrainplateau1..4 | OBS |
| E52 | byte decode `data\actors\env\terrainmesh{1..4}.osm` @ offset 0 (17×int32) and `ofs_frames` | magic 844121161; v/f = 2662/5305, 2272/4532, 2177/4323, 2509/5002; 1 frame, 1 skin; bbox approx x/y ±13, z 0..9.55 | OBS (binary) |
| E53 | `data\scripts\common.inc\dogenerate.inc:1626-1648,1703-1708,1757-1765` | relief/plateau/hill placement probabilities per climate (e.g. `mnt=0.000020` at :1627, `0.000120` at :1642) multiplied by area/probability modifiers; placed via `_misc_SetupPatternsByType` | OBS |
| E54 | `data\game\var\generator.cfg:581-675` | pattern groups `plateau`, `plateau_small`, `plateau_big`, `mountains` list pattern names + Freq | OBS |
| E55 | `data\water\water.lib:4-68` | MaxDepth=1, MinDepth=0, MaxAlpha=1.1, MinAlpha=0; DeepColor `(0,0,0.1255,0.5)`, Shallow `(0,0,0,0.5)`, Reflection/WaterAmount=1, Fresnel 1/1, HDRMultiplier=1, WaveFreq/Amp=0, DistFactor/BumpFactor=1, TexScaleS=0.1, TexScaleT=0.01, WaveDir0 (-1,0), WaveDir1 (-0.7,0.7), Speed=1, NormalMap=DiffuseWaves2 (HeightMapWaves0 commented), DiffuseMap=DiffuseWaves0, Width/Height=1, Offset=0.495, LayerCount=1, `HeightMapEnable=True`, `ShadowMapEnable=True`, vert/frag `water.dev.vert/.frag` | OBS |
| E56 | `data\shaders\water\water.dev.vert:14-29` | `gl_TexCoord[0]=TextureMatrix[0]*pos`; `gl_TexCoord[1].xy=MultiTexCoord0.xy/(hmapW,hmapH)-0.5`, `.z=pos.y` (water level); shadow coord; eye/light vectors; `lightVector=(LightSource[0].x/4, .z/2, .y)`; ATI uses `abs(view z)` else `length(view)` for fog | OBS |
| E57 | `water.dev.frag:37-48,70-75,85-104` | `hmapTex` -> `hmapMin+w*(hmapMax-hmapMin)` (range 0.57 depth fade, wave parameters, water colours `(0.1,0.24,0.24)` / `(0,0.025,0.05)` / spec `(0.4,0.4,0.4)`); 9-iteration noise water_map | OBS |
| E58 | `water.dev.frag:145-160,167-232` | **per-fragment shoreline**: `WATER_LEVEL=gl_TexCoord[1].z`; `if(height>level) => fragColor=vec4(0.0)`; coastfade/depth fade, wave jitter, projected reflection, 3-tap shadow, soft/glossy specular, nautic foam + particles, final `mix(rescolor, watercolor, coastfade)` and alpha=coastfade2 | OBS |
| E59 | `water.dev.frag:237-261` | same LINEAR/EXP/EXP2 fog math with `fogEnabled` uniform, applied before output | OBS |
| E60 | `data\water\water.mat:1-20,32-39,86-105` | `DiffuseWaves0 = diffusewaves0.bmp` (tfLuminance), `DiffuseWaves2 = diffusewaves2.bmp`; `HeightMapWaves0` block fully commented | OBS |
| E61 | `generatemap.inc:646-708` | **water field construction**: 2×2-cell blocks from source B>0 and not all-white; `WaterFieldAdd(name, tx,tz,bx,bz, cOffsetY=-0.5)`; `WaterFieldsClear` first; max 320² blocks for 640 map | OBS |
| E62 | `texturemap.inc:463-471`, `miscext.script:1515-1520` | generator water/shore tags; runtime `RayCastWater(realx,realy,waterheight)` used to suppress height modification over water | OBS |
| E63 | `data\env\lights\light.cfg:2-38` | Ambient (.1961,.1843,.1294), Diffuse (.8118,.7804,.6941), Specular (.2784,.2667,.2118), ConstAttenuation=1, Linear/Quadratic=0, `LightStyle=lsParallel`, `Shining=true`, Position (-0.344731,0.938701,0,1) | OBS |
| E64 | `data\env\env.cfg:15-25` | loader list: time, colors.lib, skydome, clouds weather/cfg, flares, light.cfg, particles | OBS |
| E65 | `data\env\colors\colors.lib:23,34-43,83-92` | default palette Fog `(60,100,150,1)`, `FogStart=390`, `FogEnd=490`, `FogMode=0` (off), `HFogMode=2`, `FogDepthFactor=0.8`; dark palette `FogMode=2`, `FogStart=90`, `FogExpDepthFactor=0.7` | OBS |
| E66 | `data\cameras\camera.cfg:51-64` | `PowerDOF=0.5`, DOF lengths 128/256/256; `DynFogDepth=False`, `DynFogStart=0.25`, `DynFogEnd=0.025`, `DynFogDensity=2`, `DynFogPower=0.85`, `DynFogOffset=0` | OBS |
| E67 | `data\gui\menu.inc\docreate.inc:296-320` | the `SetCameraDynFogDepth(False)...` override at :315 is inside the **screenshot camera / free-zoom** branch (`gbool_gui_screenshotcamera or gProfile.bfreezoom` at :299) | OBS |
| E68 | byte decode `data\gen\bitmap\ausmis1.bmp` @14 | BMP DIB 320×320, 32 bpp | OBS (binary) |
| E69 | byte decode `data\gen\bitmap\battle1.bmp` @14 | BMP DIB 384×384, 32 bpp | OBS (binary) |
| E70 | byte decode `data\gen\bitmap\ext\tile_lowground.bmp` @14 | BMP DIB 320×320, 24 bpp | OBS (binary) |
| E71 | byte decode `data\gen\terrainmasks\land\4pl_mask_land_0_gauss.tga` @12 | TGA 320×320, 24 bpp, 0 alpha bits | OBS (binary) |
| E72 | byte decode `data\water\textures\heightmapwaves0.tga` @12 | TGA 256×256, 32 bpp, 8 alpha bits | OBS (binary) |
| E73 | byte decode `data\terrain\tiles\textures\rock1.dds` @12/@28 | DDS 1024×1024, 11 mip levels | OBS (binary) |
| E74 | byte decode `data\maps\missions\ausmis1.map` @4, first 4 MiB | ASCII header `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`; no `Terrain/Height/Tile/Water` ASCII keys found | OBS (binary) |

## 2. Findings

### 2.1 Elevation: a decoded 2D mask, not a baked heightfield image

**OBS.** The height grid is the map grid (E01-E06): 256²/320²/480²/640² cells,
max 640², with a 2× collision grid. `TMapTerrainDataTile` literally stores
`height` as a Float **per cell** and a single integer `tex` per cell (E03).

**OBS.** The source is a **per-map raster**, not an image the GPU samples. The
generator loads `bitmapsrc.bmp` (E10), checks it against map size (E11), reads
RGBA floats per cell (E12), classifies R into plateau/hill/ravine and G into
forest (E13-E15), then samples a *second* target bitmap into `gMapMask.r/.b`
(E16). The height itself is computed at E17:

```
hwater   = -1.1 * (fb * (1 + 3.5*fr))
hterrain = { 2.964*fr (plateau) | 1.3173*fr (hill) | -2.964*fr (ravine) | 0 }
height   = hwater + hterrain
```

**DERIVED.** `cHillHeight = 2.964/2.25 = 1.31733…`. The port's dumped height
span ±2.964 (`G32_heightmap_world.md:139`) is therefore **the donor plateau/
ravine constants**, not an accident and not "metres" by donor evidence.

**OBS.** This decoded grid is then smoothed twice: a class-mask-driven
`SmoothTerrain(...,3)` pass (E19) and a global kernel `power=4, lerp=0.5`
followed by three water-adjacency passes `power=0.35, lerp=0.5` in radius 2
(E18, E20). So the final heightfield is a *processed* raster, not the raw BMP.

**OBS.** Cell→world mapping: `_misc_GetMapLeftTopPos` returns `-W/2, -H/2`
(E21), and collision is drawn at `realx+0.5, realy+0.5` (E22) — the grid is
centred at origin with integer cell coords. **UNVERIFIED (ENGINE):** the number
of world units per cell. The port's `TILE_M = 2.0`
(`variant3d/scripts/world3d_terrain.gd:50`) is a **port** constant; no donor
text yields a cell size in metres.

**OBS.** Two different water constants deliberately coexist: the *height
generation basin* uses `-1.1` (`generatemap.inc:7`), while the *render/texture
classification* uses `-0.25` with shore `-0.1` (`texturemap.inc:29-31`). The
port's `WATER_DEEP=-0.25`/`WATER_SHORE=-0.1`
(`variant3d/scripts/mapgen.gd:29-30`) are donor-grounded after all — the stale
"donor literal UNVERIFIED" comment at `world3d_terrain.gd:30-31,52` is
**incorrect** for the generator threshold (runtime water-plane binding remains
UNVERIFIED, §2.4).

### 2.2 Textures: one integer tile index per cell, alpha-masked 2-layer tiles, aspect-classified face art

**OBS.** There are **no splat weights** in the readable donor data. Each cell's
render material is a single `tex` integer (E03, E22-E23); the generator writes
it with `MapGetTileIndexByTileBlock(name) -> SetTileIndex(x,y,index)`
(E26-E30).

The actual selection chain is:

1. **Base tile from height + two tile bitmaps** (E31): `h<0.1` picks
   `tile_lowground.bmp`, else `tile_highground.bmp`; tile index = `floor(r*255) div 2`;
   applied only where the current index is 0.
2. **Slope aspect → 8 compass sectors** (E26-E29): compute
   `dirX=lh-rh`, `dirY=th-bh`, normalise, `vecangle=VectorAngle(1,0,0,dirX,0,dirY)+180`
   (sign flip for `dirY<0`), quantise with `cAngle=45°`. Water/shore cells pick
   `sandsea1..6` by sector; collision/edge cells pick `rock1/3/4/7` by sector
   with height overrides `|h|>2.7 -> rock8`, `>2.4 -> rock4`, `<0.1 -> none`.
   Winter adds `_winter` to the block name.
3. **Roads** from source A channel (E30): `ground1`/`test2`/`test3` by `RandomExt`.
4. **Probabilistic neighbour smoothing** (E32-E33): `smoothtiles.inc` loads
   `tilesmooth_scripts.cfg`, finds a rule whose `TileNames` contain both
   neighbouring tiles and substitutes a weighted random tile from that rule
   (e.g. `sandsea1..4` weight 1 each, `sandsea5` 0.7, `sandsea6` 0.3). This is
   where the donor's varied, non-grid-aligned texture transitions come from.
5. **Climate remap / season swap** (E34; `miscext.script:1447-1512`, `:1609-1626`)
   rewrites whole tile sets for desert and winter.

**OBS — the cliff face mechanism.** `tiles.lib:119-136` defines `rockNvf`
(`AngleX=0, AngleZ=25`) and `rockNvs` (`AngleX=25, AngleZ=0`); `sandNf/s`
have the same 25° angles (E35). `tiles.mat:142-156` binds them to refkeys
`verticalfront`/`verticalside`, and `reftile.mat:120-169` shows exactly what
those refkeys do: swap the second texture to `alphavert.bmp`, scale UVs by
`0.125`, set `tmmEyeLinear`, take S from X (front) or Y (side) and T from Z
(height). Base tiles use `alpha.bmp` (`reftile.mat:6`, `reftilealpha.mat:30-35`).
`BlendingMode = bmTransparency` (`reftile.mat:17`) means the second texture's
alpha is the blend factor. In the shader, `texUnit0` supplies RGB and `texUnit1`
supplies alpha (E45); the actual fixed-function blend is **ENGINE** and the
exact rule that promotes a base tile to its `vf/vs/f/s` variant is **UNVERIFIED**
(no readable script names those blocks — see §5).

**OBS.** Tile blocks are atlas-like, not full-map textures: `reftile.lib:3-12`
declares `tsDouble`/`ttExtended`, offsets `0.1/0.2`, and commented
`TileSize=64, Rows=16, Cols=16, AlphaRows=8, AlphaCols=4` — i.e. a 16×16
sub-tile atlas with a separate alpha atlas. Content textures are 1024×1024 DDS
with 11 mip levels (E73). Filtering is deliberately nearest/nearest-mipmap-
linear with anisotropy (E38) — crisp tile art, not a smoothed colour field.

**DERIVED — why our splat looks flat.** Our terrain uses one 320×320 RGBA
albedo sampled by 0..1 UVs (`variant3d/scripts/world3d_terrain.gd:14-16,100-105`).
That is a *different representation* from the donor's per-cell tile index +
8-way aspect classification + 25° tilted alpha-masked face variants + weighted
transition pass. No amount of splat resolution reproduces `rock1vf`'s
`AngleZ=25` eye-linear projection, because that projection is geometry/texture
coordinate behaviour in the engine, not a colour value.

### 2.3 Vertex data, normals, tangents, LOD/chunking, draw calls

**OBS.** The heightfield shader takes `gl_Normal` through `gl_NormalMatrix`
(E44) and is declared `tangentSpace=false`, `boneMatrices=false` (E43); there
is **no normal map on the heightfield surface** and no per-vertex tangent stream
for it. A separate shader `tbn.env.sm.id5.vert` exists for other objects but is
not bound to `HeightField` (`shaders.lib:15-52`).

**OBS.** Relief props use a different path: `refmountain.actor:34-40` reserves
texcoord slots 1 (binormals) and 2 (tangents) but leaves `TangentSpace` commented
out — tangent-space shading is *configured but disabled by default*.

**OBS.** Four `terrainmesh*.osm` and four `terrainplateau*.osm` actors exist
(E48, E51), each with one `LODList.Items[0]` entry (that is **one LOD slot per
distinct prop**, not four LODs of one mesh — a correction to `G31:103-105`).
Counts decoded from the IDP2 headers (E52): 2662/5305, 2272/4532,
2177/4323, 2509/5002 vertices/faces. Placement is by generator pattern groups
(E53-E54) with small per-cell probabilities (~1e-5..1e-4), not by a height
threshold in readable text. Desert variants reuse the same meshes with
different materials (`objects\env\terrainmeshdesert*.prop:9-18`).

**UNVERIFIED (ENGINE).** The connector from `SetHeightData`/`SetTileIndex` cells
to the emitted heightfield triangles is absent from all readable text. No
script or config states one-vertex-per-cell, a decimated grid, chunk size, or
draw-call count. RTTI names `HXHeightField`/`XTile` are reported in
`G31:56-58,105` but are binary strings, not a readable pipeline. The only
concrete draw-related facts in text are the shader binding (E43-E46) and the
relief mesh actor bindings (E48-E52). **Do not claim donor chunking or a donor
draw-call budget.**

### 2.4 Water: many height-aware fields + per-fragment shoreline, not one flat quad

**OBS.** Water fields are constructed in the generator (E61): for each 2×2 cell
block where source B>0 and not all-white, `WaterFieldAdd(name, tx,tz,bx,bz,-0.5)`
is called; fields are cleared first. Therefore the donor water surface is a
**patchwork of small rectangles following the source water mask**, centred by
`mapsizemod`, each offset `-0.5` in Y.

**OBS.** The shipping fragment program is `water.dev.frag` (`water.lib:67-68`),
and it is **terrain-height aware**: `height=height_map(uv)` from `hmapTex`
(E57); `WATER_LEVEL=gl_TexCoord[1].z` comes from the water vertex's Y
(E56); fragments with `height>level` are discarded (`fragColor=vec4(0)`, E58);
coastfade and deep-fade are computed from `level-height` with `coast2water_fadedepth=0.57`
and `deepwater_fadedepth=1.07` (E57-E58). Shoreline is therefore resolved
**per fragment**, with wave-jittered UVs, projected reflection, `test_shadow`
3-tap PCF, `nautic()` foam and `particles()` spray (E58).

**OBS.** Wave/detail texture binding: `waveMap = DiffuseWaves0`
(`diffusewaves0.bmp`, luminance) and `NormalMapLibMaterialName=DiffuseWaves2`
(`diffusewaves2.bmp`), while the `HeightMapWaves0` normal-map material is
commented out in both `water.lib:45` and `water.mat:86-105` (E55, E60). The
`hmapTex` in E57 is thus **not** `heightmapwaves0.tga`; its literal engine
binding is **UNVERIFIED** (consistent with `G31:106-109,269`).

**OBS (editor-only caveat).** `scripts\editor.inc\generatewaterfields.inc:4-16,42-68`
contains a separate 128×128 water utility with `cWaterHeightVisible=-0.834`,
`cWaterHeight=-0.314`; it explicitly errors unless map size is 128
(`:17-21`), so it is **not** the skirmish path. Do not quote those numbers as
the skirmish water level.

### 2.5 Lighting, fog, shader inputs

**OBS.** `light.cfg` (E63) gives a single parallel light with the exact ambient/
diffuse/specular colours already used by the port (`world3d_terrain.gd:59-60`),
attenuation (1,0,0) and position (-0.344731, 0.938701, 0). The vertex shaders
use `gl_LightSource[0].position` as a **positional** light in eye space
(E44, E56), so the cfg position is a direction-like vector, not a world point.
`water.dev.vert:22` permutes it to `(x/4, z/2, y)`; the port's Godot Y-up
conversion (`world3d_terrain.gd:57-58`) is **INFERRED** from that line, not an
explicit donor constant.

**OBS.** Terrain fragment shader computes `ambient+diffuse` and `specular` in
the vertex shader (E44) and combines them in the fragment shader (E45), then
applies 3-tap PCF (`smx3`) or 9-tap PCF (`smx9`, E46) with `shadowColor` and
`shadowSize` uniforms registered in `shaders.lib:3-13,22-31`.

**OBS.** Fog math is present in both heightfield and water fragment shaders
(E45, E59): modes 1 LINEAR, 2 EXP, 3 EXP2 using `gl_Fog.end/scale/density/color`
and the eye-space distance packed into `gl_TexCoord[0].w` (E44). But the *data*
turns it off for the normal view: default palette has `FogMode=0`
(`colors.lib:36`), and the main camera has `DynFogDepth=False` (`camera.cfg:59`).
The dark palette uses `FogMode=2` with start 90/end 490 (`colors.lib:83-92`).
`docreate.inc:315-320` overrides dynamic fog only for the screenshot/free-zoom
camera (E67). **INFERRED:** a standard skirmish on the default palette likely
renders with fogMode 0 (no depth fog); a palette switch would enable it. The
engine's actual uniform value is **UNVERIFIED**.

## 3. Concrete donor recipe (data-faithful, step by step)

These are the steps the donor *data* specifies. Steps marked ENGINE cannot be
reproduced from text alone.

1. **Choose grid size** 256/320/480/640 from `mapsize`
   (`miscext2.script:19-26`; skirmish `donewgame.inc:42-48`) and call
   `SetMapNeeded(..., w, w, ...)` at `:45`.
2. **Load a per-map source bitmap** (`generatemap.inc:57,285-292`); its pixel
   dimensions are expected to equal the grid (`ausmis1.bmp` is 320×320×32, E68).
   Decode R=terrain class, G=forest, B=water weight, A=road (`:413-480`).
3. **Load a target/gaussian bitmap** (`:505-547`; masks are 320×320×24, E71)
   and read its R/B into `gMapMask.r/.b`.
4. **Compute height per cell** with E17's formula and constants from `:4-7`;
   write with `SetHeightData(realx,realy,h)`, where `realx=x-W/2` (E21).
5. **Smooth**: class-mask `SmoothTerrain(...,3)` (`:580-596`), then global
   kernel power 4 / lerp 0.5 (`:598-609`), then three water-adjacency passes
   power 0.35 / lerp 0.5 within radius 2 (`:611-640`), then `TerrainUpdate(True,False)`
   at `:641`.
6. **Build water fields**: 2×2-cell blocks from source B>0, `WaterFieldAdd(...,-0.5)`
   (`:646-708`). Engine owns the surface geometry (ENGINE).
7. **Assign base tile indices** from `tile_lowground.bmp`/`tile_highground.bmp`
   by `h<0.1` and `r div 2` (`loadtextureterrainfrombitmap.inc:4-42`).
8. **Compute collision tags** from neighbour height differences `0.5/0.55`,
   four per cell on a 2× grid (`texturemap.inc:53-129`).
9. **Smooth tiles** via `tilesmooth_scripts.cfg` weighted neighbour rules
   (`smoothtiles.inc:1-80`, `tilesmooth_scripts.cfg:1-35`).
10. **Apply slope-aspect/height/winter/road tile overrides** with the
    `cAngle=45°`, `|h|>2.7/2.4`, `<0.1` rules (`texturemap.inc:415-646`).
11. **Place relief props** (`terrainmesh*`, `terrainplateau*`) via generator
    patterns, not by an engine height threshold (`dogenerate.inc:1757-1765`,
    `generator.cfg:581-675`).
12. **Render**: for each cell, HeightField shader (E43) takes `gl_Normal`
    transformed by `gl_NormalMatrix`, computes Blinn–Phong with `LightSource[0]`,
    derives albedo UVs from **eye planes** when `texGen=1`, samples `texUnit0`
    RGB and `texUnit1` alpha, applies `bmTransparency` blending of the alpha
    tile, then 3/9-tap PCF and optional fog (E44-E46, E38). ENGINE owns cell
    culling, batching and draw-call count.
13. **Render water**: water vertices carry `pos.y` as level and
    `MultiTexCoord0/(hmapW,hmapH)-0.5` as UV (E56); fragment discards where
    terrain height exceeds level, then blends height-aware colour, reflection,
    specular, foam/particles, shadow and fog (E57-E59). The `hmapTex` binding is
    ENGINE/UNVERIFIED.
14. **Lighting/fog inputs**: `light.cfg` parallel light + `colors.lib` palette;
    default palette fog off, dark palette EXP fog; main camera dynamic fog off
    (E63-E67).

## 4. Cross-check of prior evidence (independent verdicts)

| Prior claim | This audit | Corrective detail |
|---|---|---|
| `G31:67-72,230` height bitmap → grid → smoothing | **CONFIRMED** + refined | exact formula `hwater+hterrain` with constants -1.1/2.964/1.3173/-2.964 (`generatemap.inc:4-7,552-577`) |
| `G31:229` grid = map grid 256/320/480/640 | **CONFIRMED** | file bitmaps are 320²/384² (E68-E69); `TMapTerrainDataTile` per cell (E03) |
| `G31:36,105,265` height→mesh LOD UNVERIFIED | **CONFIRMED UNVERIFIED** | no connector in any readable text (§2.3) |
| `G31:97-105` "4 discrete LOD relief props" | **PARTLY CORRECTED** | they are four distinct relief **props**, each with one LOD slot; plus four plateau props (`actors.lib:1200-1225`) |
| `G31:106-109` water `hmapTex` UNVERIFIED | **CONFIRMED UNVERIFIED** | but shader behaviour is fully readable (E57-E58); `heightmapwaves0.tga` is not that binding (`water.mat:86-105`) |
| `G31:38` water height literal UNVERIFIED | **CORRECTED** | generator water threshold `-0.25`, shore `-0.1` are literal (`texturemap.inc:29-31`); runtime plane binding still UNVERIFIED |
| `G31:150-152` "donor verticalfront/verticalside 25° face art" | **CONFIRMED + explained** | `tiles.lib:119-136`, `reftile.mat:120-169` give exact 25° angles and eye-linear alpha mapping |
| `G32:117-120` cell size/height units UNVERIFIED | **CONFIRMED** | no donor metres-per-cell constant in text |
| `G32:68` water quad at -0.25 | **CORRECTED representation** | -0.25 is a generator threshold; donor water is height-aware fields with per-fragment discard (E58, E61) |
| `V71:162,167` water/fog partial | **UPGRADED** | exact water constants and full fog math are readable; engine bindings partly are not |

## 5. Ranked, donor-grounded recommendations (no edits made)

- **P0 — replace flat splat albedo with per-cell tile classification.** Port the
  E31→E32→E26-E30 chain: base tile from `tile_lowground/highground.bmp`, weighted
  `tilesmooth_scripts.cfg` transitions, then 8-sector aspect + `|h|` overrides.
  Sources: `loadtextureterrainfrombitmap.inc:4-42`, `smoothtiles.inc:1-80`,
  `tilesmooth_scripts.cfg:1-35`, `texturemap.inc:415-646`. This is the single
  biggest visual difference from our one-albedo mesh.
- **P0 — implement 25° face variants.** Add `vf/vs/f/s` materials with
  `AngleX/Z=25` and eye-linear S/T mapping + `alphavert` mask
  (`tiles.lib:119-136`, `reftile.mat:120-169`). Exact engine promotion rule is
  UNVERIFIED; treat the sector classification in E28-E29 as the best readable
  proxy, not as proven engine behaviour.
- **P1 — eye-plane texture coordinates for terrain albedo.** Use
  `dot(eyePos, eyePlaneS/T)` (`hf.pvl.sm.vert:26-33`, `shaders.lib:30`) instead
  of 0..1 map UVs; this changes apparent texel density and is likely a large
  part of the "donor look".
- **P1 — height-aware water shoreline.** Replace the constant quad with 2×2-cell
  water patches (`generatemap.inc:646-708`) and per-fragment discard/blend
  against terrain height, coast fade, foam and reflection (`water.dev.frag:167-232`).
  Do **not** bind `heightmapwaves0.tga` as `hmapTex`.
- **P1 — lighting/shadow/fog parity.** Use the exact parallel light and palette
  (E63-E65), Blinn–Phong split + 3/9-tap PCF (E43-E46), and implement fog modes
  1/2/3 but gate them by palette/camera flags (E66-E67) instead of adding fog
  unconditionally.
- **P2 — relief props and tile atlas fidelity.** Add the four `terrainmesh*`
  and four `terrainplateau*` props with summer/winter 1024² DDS variants
  (E48-E52, E73); keep them as *placed props*, not LOD levels of one mesh.

## 6. UNVERIFIED list (do not guess)

1. **Cell size in world units / metres** — no donor constant; port `TILE_M=2.0`
   is port-only (`world3d_terrain.gd:50`; `G32:117-120`).
2. **Height-field mesh topology, LOD, chunking, draw-call count** — no readable
   connector between `SetHeightData`/`SetTileIndex` and emitted triangles
   (§2.3). Do not assert one vertex per cell for the donor.
3. **Exact engine rule promoting a base tile to `vf/vs/f/s`** — no script names
   those blocks; only the materials/angles are readable (E35-E38).
4. **Number of alpha-blend passes / fixed-function blend equation** —
   `bmTransparency` + two samplers are readable (E38, E45), the multi-pass draw
   structure is ENGINE.
5. **Literal engine binding of `hmapTex`, `hmapW/H`, `hmapMin/Max`** — shader
   declares them (E56-E57), but no config maps them to a file or grid;
   `heightmapwaves0.tga` material is commented out (E60).
6. **Runtime water-plane Y value** — generator thresholds -0.25/-0.1 are
   verified (E24); the plane actually submitted to the GPU is from water
   vertices (`water.dev.vert:18`) with ENGINE binding.
7. **`.map` file terrain encoding** — only the header string is readable
   (E74); no `Terrain/Height/Tile/Water` keys in first 4 MiB; binary body not
   decoded. Do not claim the map stores a raw height array.
8. **Donor absolute FOV/sensor** — only focal 400/tilt -32 are readable
   (`camera.cfg:32-35,44-45`); unchanged from `G31:227,262-263`.
9. **Effective runtime `fogMode` value per palette/session** — cfg values are
   readable (E65-E67), the engine's uniform binding is not.
10. **Whether relief props are ever animated/LOD-switched at runtime** — only
    static actor bindings are readable (E48-E52).
11. **Exact alpha-atlas sub-rect mapping** — `reftile.lib:7-11` values are
    commented out; `tsDouble/ttExtended` semantics live in the engine.

---

**End of report. Audit only: no donor file copied/executed; no repo source,
asset, config, test or git state changed. Visual parity is not claimed;
comparative screenshots still require a GPU A/B.**
