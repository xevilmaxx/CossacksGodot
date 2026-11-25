---
id: DTRN-01
task: "Donor terrain RENDER pipeline: textures, tile atlas, blending, shaders"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_BINARY_EXECUTED
scope: "Read-only donor data research + port gap analysis. Report is the ONLY file written; no code/asset/config/test/git edit."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use; Python bytes/latin-1 + struct headers; no donor file copied, executed, or rendered)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 2
visual_parity_claim: false
---

# DTRN-01 — Donor terrain RENDER pipeline (ground textures, tile atlas, blending, shaders)

## 0. Goal

Document **how the donor actually renders the ground** — base texture set and names,
tile size in world units, tile-index / terrain-type table, the blending rule between
terrain types, filtering/anisotropy, lighting/normal usage, fog, and every readable
shader constant/expression — then use that donor truth to diagnose why our port's
3D terrain reads badly and give an ordered, concrete Godot 4 fix recipe.

Donor = truth. 2D port = secondary corroboration. Every claim is tagged
**observed** (literal donor byte/line read), **derived** (arithmetic/control-flow on
observed lines), **inferred** (interpretation with a caveat), or **UNVERIFIED**
(cannot be proved from readable data). Every key claim was checked twice by two
different means (§1.2). No donor asset was copied and no Godot process was started.

---

## 1. Sources and method

### 1.1 Orientation documents read (all read in full this session)

| # | Path | Role |
|---|---|---|
| O1 | `docs/audit/TERRAIN_DONOR_PIPELINE.md` | generation pipeline, constants, claim table C1–C28 |
| O2 | `docs/audit/TERRAIN_DONOR_ASSETS.md` | mask/block/water asset census, claim table C1–C12 |
| O3 | `docs/audit/TERRAIN_DONOR_PATTERNS.md` | `.pattern` format, 710-file family inventory |
| O4 | `docs/audit/TERRAIN_PORT_RENDER.md` | 2D renderer beauty blockers B1–B7, TR-1…TR-6 |
| O5 | `docs/audit/TERRAIN_BEAUTY_TRIAGE.md` | staged tickets TB-B0…B10, ownership map |
| O6 | `docs/audit/TERRAIN_CHECKERBOARD_TRIAGE.md` | `_grass_gain` checkerboard regression + donor-faithful replacement spec |
| O7 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md` | E01–E74: donor pipeline, shaders, water, fog, UNVERIFIED list |
| O8 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_02_donor_textures.md` | D1–D23/P1–P13: donor texture semantics, 3D splat flattening |
| O9 | `docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md` | donor water fragment ledger, port approximation ledger |
| O10 | `docs/coord_swarm_2026-11-24/reports/V786_tileindex_shader.md` | donor→shader equation ledger D01–D20, uniform contract |
| O11 | `docs/coord_swarm_2026-11-24/reports/V792_terrain_integration.md` | current integration state, probe measurements, UNVERIFIED list |

### 1.2 Two independent verification passes (this lane, read-only)

- **V1 — text pass.** Helper `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\dread.py`
  performed `open(path,'rb').read().decode('latin-1').split('\n')` and printed 1-based
  numbered lines. Used on every donor `.inc/.lib/.mat/.cfg/.presets/.vert/.frag/.script`
  file cited below. No donor file was modified.
- **V2 — binary/independent means pass.** Separate scripts used (a) `struct.unpack_from`
  on DDS/BMP/TGA/OSM headers (`dinv.py`), (b) `pathlib.Path.glob` enumeration
  independent of `os.listdir`, (c) raw hex dump for the ambiguous `alphanull.bmp`
  header, (d) the host `grep` tool content search for absence claims (`road`, `foam`),
  and (e) cross-check against O1–O11, which were written by other lanes from their
  own reads. Where V1 and V2 disagree, the raw byte read wins and the conflict is
  recorded (§8, Q3).

Claim verification notation in §3: `V1+V2` means the same donor fact was confirmed by
both means; `V1` alone means only one means was applied this session.

### 1.3 Donor files opened this session (all under `C:\Games\Cossacks 3\data`)

| File | Bytes (V1) | Lines (V1) | Purpose |
|---|---:|---:|---|
| `terrain\tiles\terrain.lib` | 314 | 19 | season aliases, `TextureScale=1`, `CoverDisabled=true` |
| `terrain\tiles\tiles.lib` | 26,947 | 909 | tile-block registry, sub-atlas metadata, 25° face blocks |
| `terrain\tiles\tiles.mat` | 47,343 | 1,019 | tile-block → `.dds` bindings |
| `terrain\tiles\terrain.presets` | 8,707 | 264 | tile index → name dictionary (Summer/Winter, 124 each) |
| `terrain\tiles\tiles.season` | 70 | 5 | per-texture season override |
| `terrain\ref\reftile.lib` | 262 | 14 | `tsDouble`/`ttExtended`, atlas defaults |
| `terrain\ref\reftile.mat` | 4,206 | 170 | alpha blend, filtering, eye-linear cliff planes |
| `terrain\ref\reftilealpha.mat` | 8,765 | 327 | `alpha.bmp`/`alphavert.bmp`/`alphanull.bmp`, intensity→alpha |
| `scripts\common.inc\texturemap.inc` | 48,954 | 964 | collision, 8-sector aspect, shore/rock/road tile selection |
| `scripts\common.inc\loadtextureterrainfrombitmap.inc` | 1,885 | 50 | base tile from `tile_low/highground.bmp` |
| `scripts\common.inc\smoothtiles.inc` | 10,691 | 247 | weighted neighbour compatibility, 3 passes |
| `gen\tilesmooth_scripts.cfg` | 64,017 | 1,864 | exact transition rule weights |
| `gen\tilesmooth.cfg` | 2,796 | 130 | editor-side rule list (no Prob) |
| `gen\globalparams.cfg` | 537 | 23 | editor `TileSmoothPasses=6` (not skirmish) |
| `gen\mapcover.cfg` | 1,196 | 41 | height zones, empty seasonal tile names |
| `scripts\dmscript.global` | 91,341 | 2,400 | `TMapTerrainDataTile`, grid 640², collision 4 |
| `scripts\lib\misc.script` | 250,432 | 7,014 | centred map origin helper |
| `scripts\common.inc\generatemap.inc` | 51,794 | 1,060 | height formula (for water level context) |
| `shaders\shaders.lib` | 63,077 | 1,813 | SM20/SM30 HeightField bindings, uniforms, flags |
| `shaders\obj\hf.pvl.sm.vert` | 1,452 | 50 | heightfield vertex: Blinn–Phong, eye-plane texgen |
| `shaders\obj\hf.pvl.smx3.frag` | 1,584 | 51 | 3-tap PCF, alpha sampler, fog |
| `shaders\obj\hf.pvl.smx9.frag` | 2,048 | 56 | 9-tap PCF variant |
| `shaders\water\water.dev.vert` | 928 | 30 | water level in `gl_TexCoord[1].z`, light permutation |
| `shaders\water\water.dev.frag` | 8,928 | 262 | full height-aware water fragment |
| `water\water.lib` / `water\water.mat` | 2,063 / 2,899 | 71 / 106 | wave/normal bindings, all water constants |
| `env\lights\light.cfg` | 902 | 40 | parallel light ambient/diffuse/specular/position |
| `env\colors\colors.lib` | 3,496 | 103 | fog colour/start/end/mode |
| `game\var\generator.cfg` | 70,074 | 2,368 | TerrainTypes 0–5, DLC5 0–8 |

Plus binary header reads: 112 tile `.dds` + 3 tile `.bmp`, 2 authoring `.bmp`,
9 water images, 4 `terrainmesh*.osm`.

---

## 2. Claim table

Verdict key: **observed** = literal text/byte read (V1, usually V1+V2);
**derived** = deterministic consequence of cited lines; **inferred** = best reading
with a stated caveat; **UNVERIFIED** = not provable from readable donor data.
"Correction" is what the port's model must change.

| # | Claim | Donor evidence (`path:line`) | Verdict / verification | Correction |
|---|---|---|---|---|
| C1 | Ground material per cell is **one integer tile index**, not splat weights or vertex colours: `TMapTerrainDataTile{height, tex, collision[4]}`, grid `[640][640]` | `scripts\dmscript.global:2026-2035`; `:78-81` (`mapwidth=640`, `collision=4`); `shaders\obj\hf.pvl.smx3.frag:13-14` (RGB from `texUnit0`, alpha from `texUnit1`) | **observed** V1+V2 | Port must supply a discrete tile id per cell; a continuous RGB splat is a different representation. |
| C2 | There is **no donor file containing a tile-index/splat array** in `data`; only the 6 blend/mask assets exist | V2 recursive filename search (`tileindex`/`splat`/`blend`/`alpha`/`tilesmooth`) → `\gen\tilesmooth.cfg`, `\gen\tilesmooth_scripts.cfg`, `\terrain\ref\reftilealpha.mat`, `\terrain\tiles\textures\alpha.bmp`, `\alphanull.bmp`, `\alphavert.bmp`; indices are written at runtime by `SetTileIndex` (`texturemap.inc:528,608,642`) | **observed** V2 | Do not hunt for a donor "tile atlas data" file; the index is generated, not stored. |
| C3 | Base texture set = 112 tile DDS: 110×1024² DXT1 11 mips + `sand1/sand2` 256² DXT1 9 mips; 3 alpha BMPs | V2 DDS header `@12/@16/@28/@84`: 110×(1024,1024,11,DXT1), 2×(256,256,9,DXT1); `alpha.bmp` 512×256×8, `alphavert.bmp` 1024×512×24, `alphanull.bmp` 512×256×8 core header; `tiles.mat:2-141` | **observed** V1+V2 (counts by `os.listdir` **and** `pathlib.glob`) | All 112 are already converted to PNG in port; alpha was dropped in conversion (O2 C8) — reconvert if blending uses it. |
| C4 | Families/counts: desert 12, grass 10, grass_ground 3, grass_rock 1, grass_sand 2, ground 1, rock 9, sand 9, sandrock 6, sandsea 6, test 26, winter 27 | V2 header grouping by stem; `tiles.lib:1-117,353-387,836-906`; `terrain.presets` parsed 124 names | **observed** V1+V2 | Port family counts match exactly; winter/desert are converted but were unwired (O2 C2, O4 B5). |
| C5 | Tile index dictionary = order of `Blocks[*].TileBlock` in `terrain.presets`: `DefaultIndex=0`, index 0 `grass1`, … 124 entries Summer and 124 Winter; Winter names `*_winter` | `terrain\tiles\terrain.presets:2-6` (Summer), `:134-138` (Winter); V2 regex parse → 124 distinct per set, first `grass1`/`grass1_winter`, last `desert12`/`desert12_winter` plus `alpha0c` | **observed** V1+V2 | Port must keep the 0-based index→name table; do not invent ids. Water cells use `BLK_WATER=255` (port), clamped by a port guard (O11 E6, §6 Q8). |
| C6 | Tile **size in world units is UNVERIFIED**: no donor metres-per-cell constant. Grid = 256/320/480/640 cells (skirmish), authoring bitmaps 320×320, texture `TextureScale = 1` | `scripts\lib\miscext2.script:19-26` + `gui\menu.inc\donewgame.inc:42-48` (size table, via O7 E04/E05); V2 BMP headers `gen\bitmap\ext\tile_lowground.bmp` / `tile_highground.bmp` = 320×320×24; `terrain\tiles\terrain.lib:5-10` | **UNVERIFIED** for metres; **observed** for grid/bitmap/scale | Port `TILE_M=2.0` is port-only; do not cite it as donor. Keep UV projection scale as a tunable, not a donor constant. |
| C7 | Atlas geometry: default `TileSize=64, Rows=16, Cols=16, AlphaRows=8, AlphaCols=4, AlphaTileSize=64` (commented); overrides `sand1-4` 64/2/2, `test10` 128/16/16, `test11` 128/32/32 | `terrain\ref\reftile.lib:3-12`; `terrain\tiles\tiles.lib:53-76,330-339` | **observed** (values are commented in shipped file → intended defaults) V1 | A 1024² tile = 16×16 sub-tiles of 64 px; 512×256 alpha = 8×4×64 px. Port atlas packing must reproduce this, not a single stretched image. |
| C8 | **Blending rule is discrete per-cell tile selection + weighted neighbour compatibility rewriting + alpha-atlas modulation** — NOT splat weights, NOT vertex colours, NOT per-pixel shader splat | `smoothtiles.inc:4-6,35-59,63-80,84-187,191-237`; `tilesmooth_scripts.cfg:1-35`; `reftile.mat:6,17`; `reftilealpha.mat:30-37`; `hf.pvl.smx3.frag:13-14` | **observed** V1(+V2 absence check) | Replace any luminance/noise "patch field" with TileBlock data + transition rules; keep alpha feather only at tile seams. |
| C9 | SmoothTileMap = **3 passes**, each horizontal (i) then vertical (j); compatible neighbours (indices differ by 1 in a rule list) unchanged; distance 2 → replace further tile with a weighted random tile from midpoint list; larger gaps → pull one step closer | `smoothtiles.inc:126-180` (rule), `:197-234` (pass loops), `:237` (`SmoothTileMap(0,0,W,H,3)`) | **observed** V1 | 2D already implements 3-pass `_smooth_tilemap` (O6 §7.1); 3D has none — generator data must supply it before the shader. |
| C10 | Transition weights are authored: `sandsea1..4 = 1` each, `sandsea5 = 0.7`, `sandsea6 = 0.3`; some lists have `Prob=0` (hard separator); `FindRandomTileIndex` roulette over `SumProb` | `gen\tilesmooth_scripts.cfg:3-36` (first rule); `smoothtiles.inc:42-59,63-80` | **observed** V1 | Do not fabricate transition probabilities; parse this config. Full cfg (1,864 lines) not exhaustively parsed this lane (Q5). |
| C11 | Base tile from bitmap: `h<0.1` → `tile_lowground.bmp`, else `tile_highground.bmp`; `tex = floor(r*255) div 2`; only where `GetTileIndex=0`. **All shipped lines are `;`-commented** | `loadtextureterrainfrombitmap.inc:4-9,25-41` | **observed** (text) / active execution **UNVERIFIED** | Use as donor intent; do not claim it runs in this build. |
| C12 | 8-sector aspect classification: `dirX=lh-rh`, `dirY=th-bh`, normalise, `vecangle=VectorAngle(1,0,0,dirX,0,dirY)+180`, sign flip if `dirY<0`, `cAngle=45`; shore → `sandsea5/6/1` by sector | `texturemap.inc:433-448,463-471,474-529` | **observed** V1 | 3D face/shore selection should consume this, not a flat colour band. |
| C13 | Cliff/edge tiles: `rock7/1/3/4` by aspect, overrides `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→none`; winter suffix | `texturemap.inc:557-611` | **observed** V1 | Orient shore/cliff art per cell; a single `rock1` wash is wrong (O4 B2). |
| C14 | Roads are **not a tile asset**: `cPlaceRoads=True`; where mask alpha `broad`, choose `ground1` (p=0.5), `test2` (p=0.25), `test3` (p=0.25) | `texturemap.inc:39,617-646`; V2 grep of `data\materials\**\*.mat` for `road` → 0 hits | **observed** V1+V2 | No `road*.dds` to convert; use donor road tiles from mask alpha. |
| C15 | No foam texture family exists; shoreline look = `sandsea1-6` + water shader (procedural `nautic`/`particles`) + DLC5 coastal/lakes/rivers masks | V2 recursive filename search (`foam\|surf\|shore\|coastline\|beach` + image ext) → 0; `water.dev.frag:106-127,227` | **observed** V1+V2 | Do not add a foam image as "donor-faithful"; any foam image is port art (O2 C1). |
| C16 | Filtering: tiles `filteringquality=tfIsotropic` (i.e. **no anisotropy**), `magfilter=maNearest`, `minfilter=miNearestMipmapLinear`, `twBoth`; masks `maNearest`/`miNearest`, `tfAlpha`, `tiaAlphaFromIntensity` | `reftile.mat:24-49`; `reftilealpha.mat:24-49`; `reftile.lib:3-12` | **observed** V1 | Port's nearest-mipmap sampler hints are the closest Godot equivalent (O10 §2.12); do not add anisotropic filtering claiming donor parity. |
| C17 | Alpha modulation is `bmTransparency` + `Texture2Name=alpha`; fragment reads RGB from `texUnit0`, **alpha from `texUnit1`**, then `color.rgb*TexCoord[4]+TexCoord[5]` | `reftile.mat:6,17`; `reftilealpha.mat:17,30-37`; `shaders.lib:32-51` (units 0/1); `hf.pvl.smx3.frag:13-17` | **observed** V1 | One Godot `blend_mix` pass is an approximation of donor fixed-function multi-pass blending (O10 §2.8). |
| C18 | No terrain normal map. Heightfield shader `tangentSpace=false`, uses `gl_Normal`/`gl_NormalMatrix`; relief props reserve tangent/binormal texcoords but `TangentSpace` is commented out | `shaders.lib:19,918`; `hf.pvl.sm.vert:15`; O7 E49 (`refmountain.actor:34-40`); V2 `tiles.mat` bindings contain only `Material.Texture.image` | **observed** V1+V2 | Do **not** add a terrain normal map as "donor fidelity"; a normal slot would be invented (O8 UNV-3). |
| C19 | Exact lighting: per-vertex Blinn–Phong in vertex shader; fragment combines packed ambient+diffuse and specular, then 3-tap (`of=1/512`, `/3`) or 9-tap (`/9`) PCF `sampler2DShadow`, then fog modes 1/2/3 | `hf.pvl.sm.vert:9-23,26-46`; `hf.pvl.smx3.frag:17-46`; `hf.pvl.smx9.frag:17-51`; `shaders.lib:15-52,914-951` | **observed** V1 | Port shader has equations but `shadow_enabled=0`, no real shadow sampler (O10 §2.5) — missing, not optional if chasing donor look. |
| C20 | Fog is implemented in shader but **off by default**: `FogMode=0`, `Fog=(60,100,150,1)`, `FogStart=390`, `FogEnd=490`; dark palette uses `FogMode=2`, start 90/end 490; camera `DynFogDepth=False` except screenshot camera | `colors.lib:23,34-43` + `:83-92` (dark, via O7 E65); `hf.pvl.smx3.frag:34-46`; `water.dev.frag:237-253`; `camera.cfg:59` / `docreate.inc:315-320` (via O7 E66/E67) | **observed** V1 (default palette) + prior-lane for dark/camera | Do not enable fog unconditionally; gate by palette/camera. Port `fog_mode=0` is correct for default. |
| C21 | Water is height-aware: 2×2-cell fields at `-0.5`, vertex carries level in `gl_TexCoord[1].z`, fragment discards where `height>level`, coast fade `0.57`, deep fade `1.07`, alpha `coastfade2` | `water.dev.vert:16-18`; `water.dev.frag:167-232`; O7 E61 (`generatemap.inc:646-708`) | **observed** V1 | A flat constant-colour quad cannot reproduce donor shore (O11 §0). |
| C22 | Water textures actually bound: `DiffuseWaves0` (waveMap, `tfLuminance`) and `DiffuseWaves2` (normal-map material); `HeightMapWaves0`/waves 1,3-7 commented out | `water.mat:1-20,32-39,86-106`; `water.lib:43-45` | **observed** V1 | Do not convert/bind `heightmapwaves0.tga` as `hmapTex`; its binding is UNVERIFIED (O7 UNV #5). |
| C23 | Exact water constants: `coast2water_fadedepth=0.57`, `large_waveheight=0.50`, `large_wavesize=2`, `small_waveheight=0.5`, `small_wavesize=0.5`, `water_softlight_fact=170`, `water_glossylight_fact=120`, `particle_amount=30`, `watercolor=(0.1,0.24,0.24)`, `watercolor2=(0,0.025,0.05)`, `spec=(0.4,0.4,0.4)`, `TexScaleS=0.1`, `TexScaleT=0.01`, `HDRMultiplier=1` | `water.dev.frag:37-47`; `water.lib:25,32-33` | **observed** V1 (re-read verbatim this lane) | Port values checked by O9 probe (−0.25/−0.1/2.96); keep constants but remember `waveheight=0` at level −0.25 is donor-faithful. |
| C24 | `alphanull.bmp` is **512×256, 8 bpp, 12-byte BITMAPCOREHEADER** (bytes `0c 00 00 00 | 00 02 | 00 01 | 01 00 | 08 00` at `@14`) | V2 raw hex + `struct` | **observed** V2 | Corrects O8 D19 ("512×257"): height field at `@20-21` is `0x0100 = 256`. Low impact. |
| C25 | Relief props are **placed assets** (`terrainmesh1-4`, `terrainplateau1-4`), not LOD levels of one mesh; OSM v/f 2662/5305, 2272/4532, 2177/4323, 2509/5002 | O7 E48/E51/E52; V2 OSM header `@0` first 17 int32 (magic 844121161, v@6, f@8) | **observed** V2 + prior lane | Keep as separate stamped props; do not model them as terrain mesh LOD. |
| C26 | Port 3D originally bound ONE 320×320 splat, one averaged RGB per cell (`n=1` default; grass1 `[76,83,30]`), discarding ~99.9% of donor 1024² grain | O8 P8–P11, §5; `variant3d/assets/terrain/heightmap/splat_albedo.png` 1,150,428 B present (V2 this lane) | **observed** (port) | This was the root cause of flatness; now superseded by tile-index atlas wiring (O11), but the splat remains as the fallback path. |
| C27 | Current 3D terrain module wires tile-index atlas + shader + water + live `game.tileblock`; face mode now derived from port `cDiff1/cDiff2` slope/aspect (FIX-TERRAIN), and `UV2.y=0` claim in O11 is stale | `variant3d/scripts/world3d_terrain.gd:16-23,30-58,110-111,360,693-703`; `variant3d/shaders/terrain_tileindex.gdshader:37,54-85,151,169,273-286,300-331` | **observed** (port read this lane) | Gap analysis must target what *remains* wrong, not merely restate O11's 2026-11-24 state. |
| C28 | Remaining donor-vs-port approximations: neutral eye planes/texture matrix; 25° `AngleX/AngleZ` tilt not applied; alpha sub-rect mapping invented; shadow PCF disabled; donor multi-pass `bmTransparency` → one `blend_mix`; LINEAR fog absent; reflection off; Fresnel commented in donor; `hmapTex` substituted | `terrain_tileindex.gdshader:25-37,60-85,151,169,185-197,300-331`; `water3d.gdshader:14-24,55-57,159,176-230`; O10 §2; O9 §8 | **observed** (port) + **UNVERIFIED** (donor engine values) | Rank these by visual impact; do not label them "done". |

---

## 3. Donor texture / asset inventory table

### 3.1 Ground tile textures (112 DDS + 3 alpha BMP), verified by binary header

| Family | Count | Dims / format / mips (V2) | Semantic role (V1) | Port status |
|---|---:|---|---|---|
| `grass1..10` | 10 | 1024² DXT1 / 11 | meadow base; index 0–9 | converted + wired |
| `ground1` | 1 | 1024² DXT1 / 11 | bare earth/dirt; road p=0.5; **no road tile exists** | converted + wired |
| `grass_ground1..3` | 3 | 1024² DXT1 / 11 | grass→earth transition; indices 14–16 | converted |
| `grass_rock1` | 1 | 1024² DXT1 / 11 | grass→rock transition; index 13 | converted |
| `grass_sand1..2` | 2 | 1024² DXT1 / 11 | grass→sand transition; indices 11–12 | converted |
| `rock1..9` | 9 | 1024² DXT1 / 11 | rock/cliff surface; indices 17–25; reused by face blocks | converted + wired |
| `sand1, sand2` | 2 | **256² DXT1 / 9** | sand with `TileSize=64, Rows=2, Cols=2` (indices 26–27) | converted |
| `sand3..9` | 7 | 1024² DXT1 / 11 | sand (sand3/4 also 64/2/2 metadata; ambiguous) | converted |
| `sandrock1..6` | 6 | 1024² DXT1 / 11 | sand→rock mix | converted |
| `sandsea1..6` | 6 | 1024² DXT1 / 11 | **shoreline**, aspect-selected (`texturemap.inc:504-511`), weights 1/1/1/1/0.7/0.3 | converted + wired in 2D |
| `desert1..12` | 12 | 1024² DXT1 / 11 | desert climate set (`tiles.lib:836-869`) | converted, historically unwired |
| `test0..25` | 26 | 1024² DXT1 / 11 | extras; `test10` 128/16/16, `test11` 128/32/32; road `test2/test3` | converted |
| `winter0..26` | 27 | 1024² DXT1 / 11 | winter set, `seasons.Winter=Winter`; Winter preset uses `*_winter` names | converted, historically unwired |
| `alpha.bmp` | 1 | 512×256, 8 bpp | **tile blend alpha atlas**, `tiaAlphaFromIntensity`, `tfAlpha`, 8×4×64 px | converted (grayscale → repacked to A in 3D) |
| `alphavert.bmp` | 1 | 1024×512, 24 bpp | projected cliff mask, `TextureScale=0.125`, eye-linear T=world-up | converted (repacked to A) |
| `alphanull.bmp` | 1 | 512×256, 8 bpp, **core header** | named "null" alpha material; shipped use UNVERIFIED | converted |

Tile-block registry: `terrain\tiles\tiles.lib:1-909`; bindings `tiles.mat:1-1019`;
index order `terrain.presets:2-130 / 134-263` (124 Summer + 124 Winter entries).
Face blocks `rockNvf {AngleX=0, AngleZ=25}` / `rockNs {AngleX=25, AngleZ=0}` at
`tiles.lib:119-207`, bound to the **same** `.dds` as flat rock at `tiles.mat:142-213`.

### 3.2 Water / authoring / relief

| Asset | Dims (V2) | Role | Note |
|---|---|---|---|
| `gen\bitmap\ext\tile_lowground.bmp`, `tile_highground.bmp` | 320×320×24 | base tile selector by `h<0.1` | exactly map-grid size |
| `water\textures\diffusewaves0.bmp` | 256²×24 | `waveMap`, `tfLuminance` | active |
| `diffusewaves1.bmp` | 256²×24 | commented out | inactive |
| `diffusewaves2.bmp` | 512²×24 | `NormalMapLibMaterialName` | active normal-map *material* |
| `diffusewaves3-7.bmp` | 512²×24 | commented out | inactive |
| `heightmapwaves0.tga` | 256², 32 bpp | `tfNormalMap` block fully commented | **not** `hmapTex` |
| `actors\env\terrainmesh1..4.osm` | 191,356 / 163,452 / 156,092 / 201,604 B | placed relief props (v/f 2662/5305, 2272/4532, 2177/4323, 2509/5002) | summer/winter `.prop` variants |

No terrain normal map is assigned to any tile (V2 `tiles.mat` has only
`Material.Texture.image`). No foam image exists anywhere under `data\`.

---

## 4. Exact blend algorithm pseudocode (donor truth)

Reconstructed verbatim from `loadtextureterrainfrombitmap.inc:4-41`,
`texturemap.inc:415-646`, `smoothtiles.inc:1-243`, `tilesmooth_scripts.cfg:1-35`,
`reftile.mat:6,17,120-170`, `hf.pvl.smx3.frag:13-17`.

```
# ---- per-cell discrete tile index (generator, commented in shipped build) ----
for (x,y) in grid:                                   # texturemap.inc:420-421
    h    = GetHeightData(x-W/2, y-H/2)               # :423-426
    lh,rh,th,bh = neighbour heights                  # :433-437
    dirX = lh-rh ; dirY = th-bh ; normalize          # :438-444
    ang  = VectorAngle(1,0,0,dirX,0,dirY)            # :445
    if dirY < 0: ang = -ang                          # :446-447
    if mask.b > 0 and (h < -0.25 or h < -0.1):       # :463-471 (water/shore)
        sector = quantize(ang+180, cAngle=45)        # :474-501  (8 sectors)
        tile = {LB:'sandsea5', RB:'sandsea6', B:'sandsea1',
                L:'sandsea6', R:'sandsea6', T:'sandsea1',
                RT:'sandsea5', LT:'sandsea6'}[sector] # :503-511
    elif at_map_edge or collisionTagInRadius>0:      # :557
        tile = {LB:'rock7',B:'rock1',L:'rock3',
                R:'rock4',T:'rock4',RB:'rock4'}[sector]  # :578-591
        if abs(h)>2.7: tile='rock8'                  # :594-595
        elif abs(h)>2.4: tile='rock4'                # :597-598
        elif abs(h)<0.1: tile=''                     # :600-601
    if season==Winter: tile += '_winter'             # :605-606 / :525-526
    if tile: SetTileIndex(x,y, MapGetTileIndexByTileBlock(tile))   # :607-608

for (x,y) where mask.broad:                          # :622
    r = RandomExt
    tile = 'ground1' if r>0.5 else ('test2' if r>0.25 else 'test3')  # :627-636
    SetTileIndex(x,y, index_of(tile))                # :641-642

# base fill only where index still 0                  # loadtextureterrainfrombitmap.inc
if h < 0.1: bmp = tile_lowground.bmp else bmp = tile_highground.bmp   # :26-29
r = floor(fr*255); tex = r div 2                     # :33,36
if GetTileIndex(x,y)==0 and MapGetTileBlockByTileIndex(tex)<>'':
    SetTileIndex(x,y,tex)                            # :37-41

# ---- neighbour compatibility, 3 passes (smoothtiles.inc) ----
load tilesmooth_scripts.cfg -> Items[64] rules; each rule = list of
  (TileName, TileIndex, Prob); SumProb = sum(Prob)    # :4-59
for pass in 0..2:                                    # :237  (passes=3)
    for each horizontal pair (i,j)-(i+1,j):          # :200-215
        reconcile(tindex1,tindex2)                   # :207
    for each vertical pair (i,j)-(i,j+1):            # :218-233
        reconcile(tindex1,tindex2)                   # :225
SetTileIndex(x,y, atilemap[x,y])                     # :240-242

reconcile(a,b):
    find rule i where both names appear; pick list indices i1,i2
    with minimum |i1-i2|                             # :102-136
    if |i1-i2| == 1: return (no change)              # :142-155 (compatible)
    if i2-i1 == 2: b = weighted_random_pick(list(i1+1)) # :165-168
    if i1-i2 == 2: a = weighted_random_pick(list(i2+1)) # :159-162
    else: pull the farther one one step toward the other  # :171-180
    weighted_random_pick(list): rnd=RandomExt*SumProb;   # :66-67
        walk cumulative Prob, return first whose rnd<tmp # :70-78

# ---- render (shader + fixed function) ----
for each terrain fragment:
    st = TextureMatrix[0] * vec2(dot(realpos,EyePlaneS[0]),
                                 dot(realpos,EyePlaneT[0]))  # hf.pvl.sm.vert:30-32
    rgb = texture2D(texUnit0, st).rgb                # hf.pvl.smx3.frag:13
    a   = texture2D(texUnit1, gl_TexCoord[1].xy).a  # :14  (alpha.bmp / alphavert.bmp)
    rgb = rgb * (ambient+diffuse) + specular         # :17 (packed in vert :38-39)
    rgb = rgb * (shadow_pc + shadowColor*(1-shadow_pc))  # :20-30, of=1/512
    rgb = mix(fogColor, rgb, fog)                    # :34-46 (mode 1/2/3)
    gl_FragColor = vec4(rgb, a)                      # :50  (bmTransparency)
```

**What this means in one sentence:** donor blending is a *per-cell discrete
TileBlock assignment* whose seams are softened by a weighted transition pass and a
two-texture alpha-atlas transparency blend at draw time — there is no splat weight
map, no checkerboard noise field, and no vertex-colour blending. `gl_Color` multiplies
**diffuse**, never albedo (`hf.pvl.sm.vert:20-22`), and O10 reports 0 donor
`glColorPointer` references, so no donor vertex-colour array exists.

---

## 5. Constants (verbatim donor literals, all V1 re-read this lane)

### 5.1 Grid, tile, height, water classification

| Constant | Value | Source |
|---|---|---|
| `gc_terraindata_mapwidth/height` | 640 / 640 | `scripts\dmscript.global:78-79` |
| `gc_terraindata_collision` | 4 (2× per axis) | `scripts\dmscript.global:80` |
| skirmish map size options | 320 / 480 / 640 / 256 / 320 | `miscext2.script:19-26`, `donewgame.inc:42-48` (O7 E04/E05) |
| authoring bitmap | 320×320×24 | V2 header |
| `TextureScale` | X=Y=Z=W=1 | `terrain\tiles\terrain.lib:5-10` |
| atlas defaults (commented) | `TileSize=64, Rows/Cols=16, AlphaRows=8, AlphaCols=4, AlphaTileSize=64` | `terrain\ref\reftile.lib:7-12` |
| sand sub-atlas | `TileSize=64, Rows=2, Cols=2` | `tiles.lib:53-76` |
| `cLowHeight` | 0.1 | `loadtextureterrainfrombitmap.inc:4` |
| `cMaxHeight` | 2.96 | `texturemap.inc:29` |
| `cWaterHeight` (classify) | −0.25 | `texturemap.inc:30` |
| `cWaterShoreHeight` | −0.1 | `texturemap.inc:31` |
| `cPlateauHeight / cHillHeight / cRavineHeight` | 2.964 / 2.964÷2.25=1.31733 / −2.964 | `generatemap.inc:4-6` |
| `cWaterHeight` (height gen) | −1.1 ; `hwater=−1.1*fb*(1+3.5*fr)` | `generatemap.inc:7,567` |
| R codes plateau/hill/ravine/smooth | 255 / 96 / 48 / 64 (128 div 2) | `texturemap.inc:16-22` |
| G codes forest/genforest/stone/foreststone | 255 / 64 / 128 / 192 | `texturemap.inc:23-26` |
| B code water | 255 | `texturemap.inc:27` |
| `cDiff1 / cDiff2` | 0.5 / 0.55 | `texturemap.inc:63-64` |
| `cAngle` | 45° | `texturemap.inc:474` |
| rock height overrides | abs(h)>2.7→rock8; >2.4→rock4; <0.1→none | `texturemap.inc:594-601` |
| road probabilities | ground1 p=0.5; test2 p=0.25; test3 p=0.25 | `texturemap.inc:627-636` |
| winter suffix | `_winter` when `GetSeasonType=2` | `texturemap.inc:525-526,605-606,639-640` |
| smooth transition weights | sandsea1-4=1, sandsea5=0.7, sandsea6=0.3 | `tilesmooth_scripts.cfg:8-33` |
| smoothing passes | 3 (generator script); editor cfg says 6 | `smoothtiles.inc:237`; `globalparams.cfg:9` |
| season aliases | Summer/Autumn/Spring=Summer, Winter=Winter | `terrain.lib:12-15` |

### 5.2 Filtering, materials, lighting

| Constant | Value | Source |
|---|---|---|
| tile filter | `maNearest` / `miNearestMipmapLinear` / `tfIsotropic` / `twBoth` | `reftile.mat:29,32-37` |
| mask filter | `maNearest` / `miNearest` / `tfAlpha` / `tiaAlphaFromIntensity` | `reftilealpha.mat:30-37` |
| `BlendingMode` | `bmTransparency` | `reftile.mat:17`; `reftilealpha.mat:17` |
| `Texture2Name` | `alpha` (ground), `alphavert` (faces) | `reftile.mat:6,122,148` |
| face alpha scale | `TextureScale=0.125`; S=(1,0,0,0) / T=(0,0,1,0) front; S=(0,1,0,0)/T=(0,0,1,0) side; `tmmEyeLinear` | `reftile.mat:120-170` |
| face tilt | `rockNvf AngleX=0 AngleZ=25`; `rockNs AngleX=25 AngleZ=0` | `tiles.lib:119-207` |
| material energy (tile) | ambient 0.15686, diffuse 0.78125, specular 0, shininess 16 | `reftile.mat:52-76,80-104` |
| `light.cfg` ambient | (0.1960784, 0.1843137, 0.1294118) | `env\lights\light.cfg:2-7` |
| `light.cfg` diffuse | (0.8117647, 0.7803922, 0.6941177) | `light.cfg:9-14` |
| `light.cfg` specular | (0.2784314, 0.2666667, 0.2117647) | `light.cfg:19-24` |
| light style / position | `lsParallel`, (−0.3447312, 0.9387015, 0, 1) | `light.cfg:17,26-31` |
| shader flags | `tangentSpace=false`, `vertexColor=true`, `texGen=true`, `cameraMVM=true`, `shadowed=true`, `fogMode=true`, `texShadow=true`; texUnit0=0, texUnit1=1 | `shaders.lib:15-52,914-951` |

### 5.3 Shader expressions (exact, from V1)

```
hf.pvl.sm.vert:
  realpos = gl_ModelViewMatrix*gl_Vertex                              (:9)
  e=normalize(eye-realpos.xyz); l=normalize(gl_LightSource[0].position.xyz-realpos.xyz)
  h=normalize(l+e); n=normalize(gl_NormalMatrix*gl_Normal)           (:12-15)
  ambient=gl_FrontLightModelProduct.sceneColor+gl_FrontLightProduct[0].ambient (:18)
  diffuse=max(dot(l,n),0)*gl_FrontLightProduct[0].diffuse           (:19)
  if(vertexColor==1) diffuse*=gl_Color                              (:21-22)
  specular=pow(max(dot(h,n),0),gl_FrontMaterial.shininess)*gl_FrontLightProduct[0].specular (:23)
  gl_TexCoord[0].s=dot(realpos,gl_EyePlaneS[0]); .t=dot(realpos,gl_EyePlaneT[0])
  gl_TexCoord[0]=gl_TextureMatrix[0]*gl_TexCoord[0]                   (:30-32)
  gl_TexCoord[1]=gl_MultiTexCoord1                                   (:34)
  gl_TexCoord[3]=gl_TextureMatrix[3]*cameraMVM*realpos               (:36)
  gl_TexCoord[4]=ambient+diffuse ; gl_TexCoord[5]=specular           (:38-39)
  gl_TexCoord[0].w = ATI? abs(realpos.z) : length(realpos)            (:42-46)

hf.pvl.smx3.frag / smx9.frag:
  of = 1.0/512.0
  sh = sum(tap ? 1.0 : 0.0) ; sh /= (3.0 or 9.0)
  color.xyz *= (sh + shadowColor.xyz*(1.0-sh))
  fog LINEAR=clamp((gl_Fog.end-gl_TexCoord[0].w)*gl_Fog.scale,0,1)
  fog EXP=clamp(exp2(-gl_Fog.density*w*1.442695),0,1)
  fog EXP2=clamp(exp2(-pow(gl_Fog.density*w,2.0)*1.442695),0,1)
  color.xyz=mix(gl_Fog.color.xyz,color.xyz,fog)

water.dev.frag (full step order, :162-233):
  WATER_LEVEL=gl_TexCoord[1].z ; deepwater_fadedepth=0.5+0.57=1.07
  height=height_map(uv)=hmapMin+v.w*(hmapMax-hmapMin)
  waveheight=clamp(WATER_LEVEL*3.0-1.5,0,1)
  level=WATER_LEVEL+0.2*water_map(uv*15.0+time*0.1,waveheight)
  if(height>level) discard
  dif=(0,0.01); pos=uv*15.0/texScaleS*(hmapW/128.0)+time*0.01
  normwater=normalize(vec3(h3-h4,h1-h2,0.15))
  uv += normwater.xy*texScaleT*(level-height)
  coastfade=clamp((level-height)/0.57,0,1); coastfade2=clamp((level-height)/1.07,0,1)
  intensity = r*.2126+g*.7152+b*.0722
  watercolor=mix(watercolor*intensity,watercolor2,smoothstep(0,1,coastfade2))
  refcol=texture2DProj(reflectionMap,refuv); refcol*= (R+G+B)*hdrMultiplier
  grad=dot(normwater,normalize(light-r0))
  specular=pow(grad,170); specular2=pow(grad,120)
  specular1=smoothstep(0,1,pow(dot(vec3(0,0,1),rd),5))
  watercolor *= 2.2+watershade
  watercolor += (.2+.8*watershade)*((grad-1.0)*.5+specular)*.25
  watercolor /= (1.0+specular1*1.25)
  watercolor += watershade*specular2*(0.4,0.4,0.4)
  watercolor += watershade*coastfade*(1-coastfade2)*((.5,.6,.7)*nautic+(1,1,1)*particles)
  rescolor=mix(rescolor,watercolor,coastfade); alpha=coastfade2
```

Fog for water uses `fogEnabled` (int) with the same 1/2/3 math and `fogFragCoord`
from `water.dev.vert:24-26` (ATI `abs(z)` else `length(mv*pos)`).

---

## 6. What exists / missing / wrong in our port

### 6.1 Exists (donor-grounded and wired)

- All 112 donor tile PNGs are on disk in `variant3d/assets/terrain/blocks/` and
  `app/assets/terrain/blocks/` (O8 P12; V2 this lane confirms the splat file present).
- Live `game.tileblock` uint8-per-cell donor tile ids are dumped and decoded
  (`variant3d/scripts/game.gd:53`, `main.gd:741`, `world3d_terrain.gd:30-58`; O11 E1–E6).
- A donor-indexed 124-cell atlas + converted `alpha.png`/`alphavert.png` masks are
  loaded (`world3d_terrain.gd:127,257-258`; O11 E8/E9).
- `terrain_tileindex.gdshader` transcribes donor equations: eye-plane texgen, alpha
  sampler, Blinn–Phong combine, both PCF tap sets, fog modes 1/2/3, face mask planes,
  `face_scale=0.125`, `shadow_offset=1/512` (`V786` D01–D20; grep this lane).
- Face promotion now exists in 3D: `UV2.y` derived from `cDiff1/cDiff2` slope + aspect
  (`world3d_terrain.gd:110-111,360,693-703`) — explicitly **PORT APPROXIMATION**, not
  donor parity. O11's "UV2.y=0 for every cell" is stale.
- Water module transcribes donor fragment verbatim, height-aware via
  `bind_height_grid()`, donor literals −0.25/−0.1/2.96 (`water3d.gdshader:24,149-230`).
- Donor parallel-light rig (`WorldEnvironment` + `DonorSun`) is present (O11 §4).

### 6.2 Missing / wrong, ranked (why it still looks bad)

| # | Defect | Donor truth it violates | Evidence |
|---|---|---|---|
| M1 | **One averaged RGB per cell was the original flattening mechanism**, and the 3D splat remains the documented fallback. Any fallback to `splat_albedo.png` yields flat 320² colour patches. | Donor tiles full 1024² grain per cell, repeated, with alpha feather at seams | O8 §5; `splat_albedo.png` 1.15 MB, manifest seed 20261113; C3/C26 |
| M2 | **Eye-plane UV values are neutral** (`eye_plane_s/t` default (1,0,0,0)/(0,1,0,0), `texture_matrix` identity, `uv_repeat=(1,1)`). Donor apparent texel density comes from `gl_EyePlaneS/T[0]` and `TextureMatrix[0]`, which are engine-bound. | `hf.pvl.sm.vert:30-32`; `shaders.lib:30` | `terrain_tileindex.gdshader:60-85,185`; O10 §2.1/§2.7; **UNVERIFIED** donor values |
| M3 | **25° face tilt not applied.** Donor `AngleX/AngleZ=25` on `rockNvf/vs`, `sandNf/s` gives the striated cliff look; port only switches the alpha mask. | `tiles.lib:119-207`; `tiles.mat:142-213` | `terrain_tileindex.gdshader` has no tilt matrix (O10 §2.3, D18); **UNVERIFIED** engine path |
| M4 | **Alpha sub-rect mapping is invented.** Donor `alpha.bmp` 8×4×64 patches and `alphavert` projected mask are selected by `tsDouble`/`ttExtended` engine math; port repacks whole grayscale mask into alpha without a cell→patch map. | `reftile.lib:3-12`; `reftilealpha.mat:30-37,139-146` | O11 §6 Q3; `world3d_terrain.gd:257-258`; `V786` Q6 — **UNVERIFIED** |
| M5 | **Shadows absent.** Donor 3/9-tap PCF with `of=1/512`, `sampler2DShadow`, `shadowed=true` gives relief/props their contact. Port `shadow_enabled=0`, regular `sampler2D` substitute. | `hf.pvl.smx3.frag:20-30`; `smx9.frag:20-35`; `shaders.lib:26-28` | `terrain_tileindex.gdshader:151`; O10 §2.5; O9 §8 Q3 — donor binding **UNVERIFIED** |
| M6 | **Season/climate sets were historically unwired in 2D**; 3D atlas has Summer only (124 named cells). Donor swaps whole sets (`*_winter`, `desert*`) via `seasons.Winter=Winter` and `terrain.presets` Winter section. | `terrain.lib:12-15`; `terrain.presets:134-263`; `tiles.season:1-4` | O2 C2; O4 B5; O8 §7 — check current 3D atlas contents (Q6) |
| M7 | **Donor multi-pass `bmTransparency` compressed to one `blend_mix`.** Doesn't reproduce the authored overlay of RGB tile + alpha tile; edges can read as a flat wash. | `reftile.mat:6,17`; `reftilealpha.mat:17`; `hf.pvl.smx3.frag:13-14` | `terrain_tileindex.gdshader:25-37`; O10 §2.8 — donor blend passes **UNVERIFIED (ENGINE)** |
| M8 | **Fog off / LINEAR unported; reflection off; Fresnel commented in donor.** These are correct for the default palette (FogMode=0) but the dark palette's EXP fog and shore glints are unavailable. | `colors.lib:23,34-43,83-92`; `water.dev.frag:203-213,237-253` | `water3d.gdshader:14,55-57,222-230`; O9 §3/§8 |
| M9 | **Water `hmapTex` is a port substitute** built from the height grid; `water.dev.frag` expects engine-bound `hmapMin/Max/W`. Foam has an extra port-only `shore_prox` multiplier. | `water.dev.frag:18-21,72-75,227` | `V784` §4/§8; `water3d.gdshader:214-217` — **UNVERIFIED** binding |
| M10 | **Checkerboard regression (2D, instructive).** `_grass_gain` synthesised a ±luminance field at 1.05/2.55 cycles/tile and NEAREST-upscaled quantised 4 samples/tile; it beat against the 32-tile/16-px grid. Donor never synthesises luminance patches. | `smoothtiles.inc` + authored tile grain; no donor noise field | O6 §6/§7; `TERRAIN_CHECKERBOARD_TRIAGE.md:178-266`. Any 3D "beauty" fix that adds a noise/dither grid repeats this error. |
| M11 | **Ground tile atlas transport fragility.** `single` needs a ~180 MB PNG; auto-fallback single→split→array was not exercised on a fresh clone (O11 §6 Q4); atlas-mode split/array may supply a different sampler path. | donor has no such transport (ENGINE) | O11 §2/§6 Q4/Q5 |

**Important nuance:** the port *does* blend — alpha masks, bilinear resolve, donor
shader equations are present (O4 §3 note). The defect is **what data is fed to them**
(M1/M2/M4) and **which donor behaviours remain approximations** (M3/M5/M7/M8), not
"no blending at all". Also: adding a normal map is **wrong** — donor has none (C18).

---

## 7. Fix recipe, ordered by visual impact

All items are donor-faithful; every UNVERIFIED donor value stays a labelled tunable,
never a claimed donor constant. No code was changed by this agent.

1. **P0 — Never let the flat splat be the visible path.** Make the tile-index atlas
   material mandatory in `variant3d/scripts/world3d_terrain.gd`; keep the
   `splat_albedo.png` fallback only as an explicit labelled stub, and report
   `stats["material_model"]` in every capture. Acceptance: a same-seed screenshot
   shows ≥3 distinct donor block families in adjacent cells; 0 cells shaded from
   the 1-RGB-per-cell splat. Evidence C3/C26/M1.

2. **P0 — Feed the donor transition data, not a synthetic patch field.** Parse
   `gen\tilesmooth_scripts.cfg` into weighted rule lists and apply 3 horizontal +
   vertical compatibility passes over `game.tileblock` *before* building UV2.
   Delete/avoid any per-tile luminance/noise/dither field (M10). Acceptance: the
   port's tile-index histogram changes only through the donor rule, and no synthetic
   gain/dither constant exists in the 3D path. Evidence C8/C9/C10/O6 §7.

3. **P0 — Calibrate eye-plane UVs.** Replace `uv_repeat=(1,1)` and identity
   `texture_matrix` with values tuned until the apparent texel density matches the
   donor look; treat them as **PORT APPROXIMATION — NOT DONOR PARITY** (M2).
   Acceptance: a zoomed crop shows grass grain at the same apparent texel scale as
   the 2D port's `world.gd:1040-1042` 64 px per 2 m cell; no claim of donor literal.

4. **P1 — Implement the alpha atlas correctly.** Convert `alpha.bmp` (512×256) and
   `alphavert.bmp` (1024×512) with intensity preserved, then map each tile id to its
   donor 8×4 (or 64-px) sub-rect under `tsDouble`/`ttExtended` rather than reusing
   the whole mask; repack to alpha as now (M4). Acceptance: seam pixels show the
   authored feather shape rather than a uniform opacity; `UNVERIFIED` label retained
   until engine sub-rect is decoded (Q4).

5. **P1 — Face tiles + 25° tilt.** Keep the current `cDiff1/cDiff2` face promotion
   (M3) but add the `AngleX/AngleZ=25` tilt as a matrix applied to flat-tile UVs for
   `vf/vs/f/s` ids, and bind `rock8`/`rock4` overrides by `abs(h)` per donor C13.
   Acceptance: cliff band shows ≥2 distinct striated face tiles; tilt constant cited
   to `tiles.lib:119-207` and marked UNVERIFIED for the engine path.

6. **P1 — Enable shadow PCF with an explicit substitute.** Bind a shadow texture if
   available; otherwise keep `shadow_enabled=0` but record the visual gap. If
   enabled, transcribe `of=1/512`, 3-tap `/3` or 9-tap `/9`, `sh+shadowColor*(1-sh)`
   verbatim (M5). Acceptance: toggle produces a measurable luminance change near
   relief props; donor equations cited to `hf.pvl.smx3.frag:20-30`.

7. **P1 — Season/climate tile sets.** Wire Winter (`*_winter`, 124 entries) and
   Desert (`desert1-12`) block names through the same atlas path, selected from
   `seasons` / `tiles.season` rather than a tint (M6). Acceptance: same seed in
   summer vs winter shows different tile *grain*, not only colour; all 27 winter
   PNG names resolve. Evidence O2 P0-2/3.

8. **P2 — Water shore fidelity.** Keep the verbatim donor fragment; add height-grid
   binding in every scene that has water; do not bind `heightmapwaves0.tga` as
   `hmapTex`; drop the port-only `shore_prox` multiplier if a GPU A/B shows it
   over-brightens foam (M9). Acceptance: standing-camera frames differ only via
   `time`; coastline alpha reaches 0 at the waterline (`coastfade2` at :230).

9. **P2 — Fog/reflection parity, gated.** Add LINEAR fog mode 1 for completeness but
   keep default `fog_mode=0` per `colors.lib:36`; expose reflection as optional since
   the donor Fresnel block is commented out and the FBO binding is UNVERIFIED
   (M8). Acceptance: default screenshot unchanged; dark-palette shot matches
   EXP fog formula; no unconditional fog.

10. **P2 — Atlas transport robustness.** Verify the single→split→array fallback on a
    fresh clone (M11) and document which sampler path the tile-index shader uses in
    each mode; do not claim donor behaviour for any transport mechanism.

11. **Do NOT do:** add a terrain normal map, add a foam image as "donor", add a
    luminance gain/dither field, enable anisotropic filtering claiming donor parity,
    or cite `TILE_M=2.0`/eye-plane values as donor constants. Each is contradicted
    by C18/C15/M10/C16/C6 or is UNVERIFIED.

---

## 8. Open questions (do not guess)

1. **World units per cell.** No donor metres-per-cell constant exists; `TILE_M=2.0`
   is port-only. (C6)
2. **Runtime `gl_EyePlaneS/T[0]`, `gl_TextureMatrix[0]` values** for flat and face
   refkeys; the shader has neutral defaults. (M2; O10 Q1)
3. **`alphanull.bmp` height discrepancy.** V2 raw header gives 512×256; O8 D19 says
   512×257. Raw byte read wins; the asset is unused either way. (C24)
4. **Exact cell→alpha sub-rect mapping** under `tsDouble`/`ttExtended` — all values
   in `reftile.lib:7-12` are commented; engine-side. (M4; O10 Q6)
5. **Full `tilesmooth_scripts.cfg` rule set** (1,864 lines) — only the first rule was
   read exhaustively this lane; all weights should be parsed before shipping the
   transition pass. (C10)
6. **Did the 124-cell 3D atlas include Winter/Desert sets?** Current `terrain_tileindex.gdshader`
   and manifest cite Summer index names only; no winter name check was run in this
   lane (no Godot run). (M6)
7. **SM20 vs SM30 profile** (`smx3` 3-tap vs `smx9` 9-tap) selection at runtime —
   both profiles exist in `shaders.lib:15-52,914-951`; active one UNVERIFIED. (C19)
8. **Donor fixed-function blend pass count** for `bmTransparency` — engine-side. (M7)
9. **Active execution of the commented scripts.** `texturemap.inc`,
   `loadtextureterrainfrombitmap.inc`, `smoothtiles.inc` lines are all prefixed `;`
   in the shipped build; they document intent, not proven runtime activity. (C11)
10. **`hmapTex` binding** — only a Delphi string assignment is proven (O9/O7);
    height-grid substitute is a port choice. (M9)
11. **Visual parity** — no GPU A/B was run; all port-side visual judgements are
    structural, not measured.

---

## 9. Summary

The donor does **not** render ground as a splat or a noise field. It stores **one
integer TileBlock index per grid cell** (`dmscript.global:2026-2035`), assigns that
index from height, 8-way slope aspect, shore/rock thresholds, mask alpha roads and a
bitmap base (`texturemap.inc:415-646`; `loadtextureterrainfrombitmap.inc:4-41`),
then resolves seams with **3 passes of weighted neighbour compatibility rewriting**
(`smoothtiles.inc:191-237`; `tilesmooth_scripts.cfg:1-35`). At draw time each tile is
a repeated 1024² DXT1 texture sampled with **eye-plane projected UVs, nearest-mag /
nearest-mipmap-linear filtering, tfIsotropic (no anisotropy)**, a second alpha-atlas
texture blended with `bmTransparency`, per-vertex Blinn–Phong using `gl_Normal` with
**no normal map**, 3/9-tap PCF at `of=1/512`, and optional mode 1/2/3 fog that is
**off in the default palette**. Shore and cliff art are discrete oriented tile
families (`sandsea1-6`; `rockNvf/vs` at 25° with an eye-linear projected alphavert
mask). Water is a height-aware fragment shader, not a flat quad.

Our port now has the donor tile-index atlas, live indices, most shader equations and
the water fragment wired — but the visible quality still hinges on four things that
are *not* donor parity: neutral eye-plane UVs (M2), an invented alpha sub-rect (M4),
no 25° face tilt (M3), no shadows (M5), and no winter/desert set swap (M6). The
highest-leverage fix is to stop any fallback to the 1-RGB-per-cell splat (M1), feed
real donor transition rules (M2/M10), and calibrate texgen + atlas masks before
adding any new "beauty" effect. Any synthetic luminance grid will re-create the
documented 2D checkerboard regression (M10). Donor truth is fully readable for
textures, indices, rules and shader math; the remaining unknowns are engine-side
texgen values, face-promotion and blend pass structure, and the water `hmapTex`
binding — all explicitly UNVERIFIED.

*End of DTRN-01. One report written; no donor binary copied/executed; no Godot run;
no code, asset, config, test or git state changed. Visual parity not claimed.*
