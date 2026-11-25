---
id: A08
ticket: "TERRAIN-SWARM-2026-11-25 / A08"
task: "Consolidate the donor-grounded truth about terrain appearance already in this repo"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "One report written. No code/asset/config/test/git edit; no runner job; donor inspected READ-ONLY only."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3\\data (READ-ONLY; Python bytes/latin-1 + struct headers; no donor file copied/executed/rendered)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
visual_parity_claim: false
---

# A08 — Donor-grounded truth about terrain appearance (consolidation)

## 0. Mandate and evidence discipline

This report does not discover new facts; it consolidates donor-grounded facts that
already exist in this repo, and separates **OBSERVED** (literal donor text/byte/pixel
read, or a port fact read directly) from **UNVERIFIED** (not provable from readable
donor data). Per `docs/terrain_swarm_2026-11-25/CHARTER.md:55-69,122-131`:
donor parity stays **UNVERIFIED** because no donor GPU A/B frame exists; every
substitute is labelled **PORT APPROXIMATION**; no synthetic dither/noise field is
endorsed (decision S-25-09).

Sources consolidated (all read in full this task):
`docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md`,
`TERRAIN2_06_tileindex_architecture.md`, `DEEPDEC_02_terrain_render.md`,
`DEEPDEC_04_fog_light_sky.md`;
`docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md`,
`DTRN_02_donor_terrain_geometry.md`, `DTRN_06_donor_grass_decals.md`,
`RV_TRN_01_texgen_mask_reverify.md`, `RV_TRN_02_smoothing_rules.md`,
`DALPHA_01_alpha_subrect.md`, `DALPHA_02_patch_mapping.md`;
plus direct read-only donor plaintext reads listed in §2 (all paths below are
relative to `C:\Games\Cossacks 3\data\` unless stated otherwise).

**One-line model (OBSERVED):** the donor does not render ground as a splat, a noise
field, or vertex-colour blending. It stores **one integer tile id per grid cell**
(`scripts\dmscript.global:2026-2035`), chooses that id from height/slope-aspect/
shore/road rules and two detail bitmaps, resolves seams with **3 passes of weighted
neighbour compatibility rewriting**, and at draw time samples a repeated 1024² DXT1
tile with **eye-plane projected UVs** and a **second alpha-atlas texture** blended via
`bmTransparency` (`DTRN_01:522-534`).

---

## 1. How donor ground avoids tiling (OBSERVED mechanism, not a noise field)

The donor still repeats art — 1024² DDS tiles are sampled many times across the
map. It avoids *visible* tiling by making the repeated unit small, varied and
organically bounded, never by adding a luminance/noise overlay:

1. **Discrete per-cell id, many families.** `TMapTerrainDataTile{height:Float,
   tex:Integer, collision:Integer[4]}` on a 640² cap grid
   (`dmscript.global:2026-2035,78-81`; DTRN-01 C1). `terrain.presets:2-6,134-138`
   gives 124 Summer + 124 Winter names (grass1..10, grass_ground1..3, grass_rock1,
   grass_sand1/2, ground1, rock1..9, sand1..9, sandrock1..6, sandsea1..6,
   test0..25, desert1..12, *_winter). One id repeated = one atlas cell repeated;
   variety comes from id diversity, not per-pixel noise (DTRN-01 C4/C5).
2. **Detail-bitmap variety pass at 1–6 cell scale.** `tile_lowground.bmp` /
   `tile_highground.bmp` (320×320×24) are sampled per cell; `h<0.1` selects the low
   bitmap, `tex = floor(r*255) div 2`, applied only where the id is still 0
   (`loadtextureterrainfrombitmap.inc:4,8-9,25-41` — **verified directly**, all
   lines `;`-commented). Measured patch runs are 1–6 cells wide (median 2/1, p90
   6/3), shifting-difference saturating at d≈8/d≈4 (DTRN-06 C07/C08). The selected
   ids are grass1/test7/8/9/12/14 — **mottling is expressed as tile identity, not
   as a luminance delta**.
3. **3-pass weighted compatibility smoothing.** `smoothtiles.inc:191-237` calls
   `SmoothTileMap(...,3)`: horizontal sweep then vertical, weighted roulette over
   `tilesmooth_scripts.cfg` (DTRN-01 C8/C9; RV-TRN-02 §4.4). The cfg was parsed in
   full: 22 Items × 130 lists (118 active), 86 distinct active tile names
   (RV-TRN-02 §3, §7). Authored grass rule: `grass1/grass2/test8` each Prob=1,
   `grass7/test12/test13/test14` each 0.25; sea rule `sandsea1..4` each 1,
   `sandsea5` 0.7, `sandsea6` 0.3 (`tilesmooth_scripts.cfg:5-35,155-190` — first
   rule **verified directly**). Δ=1 compatible; Δ=2 midpoint roulette; >2 pull one
   step; all-zero lists are hard separators (RV-TRN-02 §4.3/§3.5). This is what
   produces organic, non-lattice boundaries.
4. **Authored alpha feather at seams**, not a repeat-hiding filter (§2.2).
5. **Eye-plane projected UVs on full-resolution art.** `hf.pvl.sm.vert:25-32`
   computes `s = dot(realpos, EyePlaneS[0])`, `t = dot(realpos, EyePlaneT[0])`,
   then `gl_TextureMatrix[0]`; `texGen=true` (`shaders.lib:30`); DDS tiles are
   1024² with 11 mips, `maNearest`/`miNearestMipmapLinear`/`tfIsotropic`
   (`reftile.mat:24-49`; DTRN-01 C3/C16).

**UNVERIFIED — do not pretend these are solved:** the runtime `gl_EyePlaneS/T[0]`
and `gl_TextureMatrix[0]` values are engine-bound and absent from all readable
sources (RV-TRN-01 verdict A = **CONFIRMED_UNVERIFIED**); the port's world-XZ
projection and any `uv_repeat` value are **PORT APPROXIMATION**, never donor literals
(TERRAIN2-06 §6 #1, DTRN-01 §8 Q2). Donor metres-per-cell is likewise UNVERIFIED;
port `TILE_M=2.0` is port-only (DTRN-01 C6; DTRN-02 C20).

---

## 2. Exact role of alpha transitions (OBSERVED structure / UNVERIFIED selection)

The second sampler (`texUnit1`) supplies **mask intensity only**; it is not a colour
layer, a height ramp, a distance field, or a noise source.

- **Binding and blend:** `reftile.mat:6` `Texture2Name = alpha`, `:17`
  `BlendingMode = bmTransparency`; `reftilealpha.mat:30-37` binds `alpha.bmp` with
  `imagealpha=tiaAlphaFromIntensity`, `tfAlpha`, `maNearest`/`miNearest`, `twBoth`.
  The fragment reads `color.rgb = texture2D(texUnit0, ...).rgb` and
  `color.a = texture2D(texUnit1, ...).a` (`hf.pvl.smx3.frag:13-14` — **verified
  directly**). Only `alpha0a/b/c` override to `alphanull` (`tiles.mat:347-360`;
  DTRN-06 C13).
- **Atlas geometry (RESOLVED by pixels):** `alpha.bmp` is 512×256, 8 bpp, data @1070,
  and is an **8 columns × 4 rows grid of 64×64 organic feather masks**; seam
  discontinuities occur only at x/y multiples of 64 (RV-TRN-01 §4.1; DALPHA-01
  §3.2), matching the commented `AlphaRows=8/AlphaCols=4/AlphaTileSize=64`
  (`reftile.lib:10-12` — **verified directly**). All 245 `tiles.lib` sections share
  this atlas; no tile overrides alpha geometry (DALPHA-01 §2.2/§5 verdict 2).
  `alphanull.bmp` is all-zero → deliberate "no transition" mask (DTRN-06 C16;
  RV-TRN-01 §4.1).
- **Complement structure (PARTIAL):** only four *exact* complements exist, all
  constant-255 vs constant-0 sentinels; graded masks are only approximately
  complementary (best MAD 9.77), with a derived `(r,c)↔(3−r,3−c)` counterpart in
  the same 4-column half (DALPHA-01 §3.3, verdict 3). DTRN-06 C15's "exact
  complementary pairs" is narrowed to the sentinels (DALPHA-01 §7 #1).
- **Cliff alpha is a different projection:** `verticalfront`/`verticalside` swap to
  `alphavert.bmp` with `TextureScale=0.125`, `mappingmode=tmmEyeLinear`, front
  S=(1,0,0,0)/T=(0,0,1,0), side S=(0,1,0,0)/T=(0,0,1,0)
  (`reftile.mat:120-169` — **verified directly**; RV-TRN-01 verdict C recovered these
  as donor literals).
- **Decal alpha is a separate meaning:** `decals.mat:1-37` + `dec.pvl.smx3.frag:10-14`
  give coverage/opacity (`color.a = tex0.a * material.diffuse.a`) on DXT5,
  `bmTransparency`, linear filtering, `moIgnoreFog=True`; scorch alphas never reach
  255 and `envfieldd/w` share byte-identical alpha (DTRN-06 C18–C21).

**UNVERIFIED / CONFIRMED_UNVERIFIED:** the exact `tile_id + boundary_direction →
patch (u,v)` rule. The alpha UV comes from per-vertex `gl_MultiTexCoord1`
(`hf.pvl.sm.vert:34`), written by the engine mesh builder; no script, material or
config computes a patch index, and byte scans of 17,237 files / 11 binaries found no
matcher function (DALPHA-01 §4, §5 verdict 5; RV-TRN-01 verdict B). `tsDouble` /
`ttExtended` / `TileXOffset=0.1` / `TileYOffset=0.2` are active values
(`reftile.lib:3-6`) whose arithmetic is UNVERIFIED. The 64² sub-rect sampling is
donor-grounded geometry; the tile→patch choice and exact complement remain
**PORT APPROXIMATION** (DALPHA-02 §2, §5). The `bmTransparency` pass count is
**CONFIRMED_UNVERIFIED** (RV-TRN-01 verdict D) — a single Godot `blend_mix` is an
approximation, not parity.

---

## 3. Grass detail blocks and large-scale colour variation (OBSERVED)

**Four discrete stages, no translucent albedo stack** (DTRN-06 §3.1):
L1 base tile (`grass1` = index 0, `terrain.presets:4,6`); L2 detail-bitmap variety
(§1.2 above); L3 3-pass compatibility smoothing; L4 render modulation (alpha mask +
lighting + 3/9-tap PCF + fog, decals as a separate pass).

- Grass blocks are 1024² DXT1, 11 mips, opaque; `grass1` RGB ≈ (76.0, 82.5, 30.4),
  L 74.62 (DTRN-06 C04). Detail blocks `test7/8/9` have L 71.63/70.75/69.93 — only
  **≈3–5 L below grass1** (DTRN-06 §3.2). So donor mottling is tonally subtle and
  tile-identity-based; `grass6` (L 47.4) is a dark shadow block and is **not** a
  donor patch layer despite an older piece recipe using it (DTRN-06 §3.2, D1 gate).
- **Large-scale colour variation is not a synthetic colour field.** It comes from
  (a) the tile-family swaps above; (b) aspect/shore/rock families — 8×45° sector for
  `sandsea1/5/6` (`texturemap.inc:474-511`) and 6-sector + `|h|>2.7→rock8`,
  `>2.4→rock4`, `<0.1→none` for cliffs (`:557-611`; RV-TRN-02 §5.2/§5.3);
  (c) relief shading and placed 3D props (§4); (d) shadow PCF; (e) season swap
  (`terrain.lib:12-15`, Winter 124 names at `terrain.presets:134-263`). The high
  luminance std of the "mottled" JPEG crop (37.55) is dominated by rock/explosions
  in that crop, not by grass gain (DTRN-06 §3.2, A3 gate std 8–14).

**UNVERIFIED:** full realism of large-scale variation cannot be claimed without a
donor GPU A/B; whether the port's `_assign_tileblocks` statistically reproduces the
donor's 1–6 cell patch runs was not measured (DTRN-06 Q7).

---

## 4. Relief / cliffs (OBSERVED; promotion rule UNVERIFIED)

- Height is a centred per-cell float grid: `h = -1.1*fb*(1+3.5*fr) + class(fr)` with
  `cPlateauHeight=2.964`, `cHillHeight=2.964/2.25=1.31733…`, `cRavineHeight=-2.964`
  (`generatemap.inc:4-7,552-577`; DTRN-02 C1/C4). Baked maps are float32 clamped to
  ±2.964 (DTRN-02 C10). Classification uses `cWaterHeight=-0.25`,
  `cWaterShoreHeight=-0.1`, `cMaxHeight=2.96` (`texturemap.inc:29-31`).
- Relief is **authored**, not analytic: `.pattern` files embed a w×h float32 height
  grid with `HeightFieldScale/Min/Max/Smooth` in `pattern.lib` (DTRN-02 C6/C7), and
  mountains/plateaus instantiate real 3D props `terrainmesh1..4.osm` /
  `terrainplateau1..4.osm` (2,177–2,662 vertices each; `actors.lib:1200-1225`,
  `dogenerate.inc` patterns — DTRN-02 C8/C9; TERRAIN2-01 E48/E52).
- Cliff *art* is oriented family art: `rock1vf {AngleX=0, AngleZ=25}` /
  `rock1vs {AngleX=25, AngleZ=0}` (36 vf + 36 vs pairs overall,
  `tiles.lib:119-296,543-719`) bound to `verticalfront`/`verticalside` in
  `tiles.mat:142-213`, reusing the base rock DDS (RV-TRN-01 verdict C, corrected
  from the earlier `rockNs` typo and narrower range).

**UNVERIFIED:** the rule that *promotes* a base tile to `vf/vs`, and how `25°` is
applied (geometry tilt vs texgen vs atlas orientation) — those names occur in only
three data files and never in a script (RV-TRN-01 verdict C). Engine normal formula
is UNVERIFIED (DTRN-02 C14); height-grid→mesh LOD/chunking is UNVERIFIED
(TERRAIN2-01 §2.3, DTRN-02 C19). Do not assert one vertex per cell as a donor fact.

---

## 5. Fog / light (OBSERVED values; effective runtime binding UNVERIFIED)

- One parallel light: Ambient (0.1960784, 0.1843137, 0.1294118), Diffuse
  (0.8117647, 0.7803922, 0.6941177), Specular (0.2784314, 0.2666667, 0.2117647),
  `lsParallel`, Position (−0.3447312, 0.9387015, 0, 1)
  (`light.cfg:2-31` — **verified directly**; TERRAIN2-01 E63). Static sun —
  `DateTimeEnable=False`, no day/night, no rain (DEEPDEC-04 T7/T15).
- Heightfield shading is **per-vertex Blinn–Phong** with `gl_Normal` transformed by
  `gl_NormalMatrix` (`hf.pvl.sm.vert:9-23`), fragment combines
  `color.xyz*ambient+diffuse + specular`, applies 3-tap (`of=1/512`, `/3`) or 9-tap
  (`/9`) `sampler2DShadow` PCF, then LINEAR/EXP/EXP2 fog with `1.442695`
  (`hf.pvl.smx3.frag:13-47` — **verified directly**; `hf.pvl.smx9.frag`;
  `shaders.lib:15-52,914-951`; DEEPDEC_02 §3.2). Fog distance is `length(eyePos)`
  except `abs(z)` on ATI (`hf.pvl.sm.vert:42-46`).
- Default palette: `Fog=(60,100,150,1)`, `FogStart=390`, `FogEnd=490`, `FogMode=0`,
  `FogDepthFactor=0.8` (`colors.lib:23,34-43` — **verified directly**). Dark
  palette uses `FogMode=2`, start 90/end 490 (`colors.lib:83-92`). Camera
  `DynFogDepth=False` in gameplay (`camera.cfg:59`); screenshot `True` block is
  commented out (DEEPDEC-04 T12/T13, item 4).

**Report conflict, preserved not resolved:** TERRAIN2-01 §2.5 and DTRN-01 C20 read
`FogMode=0` as "fog off by default", so port `fog_mode=0` is correct; DEEPDEC-04
§2.1/§3 shows scene fog as **ACTIVE** (config loaded, GL state writer
`sub_4d0cb4` in the frame path, `FogMode=0` → `GL_LINEAR`). Both are OBSERVED facts;
the bridge from `colors.lib FogMode` to the shader `fogMode` uniform (0-based RTTI
vs 1-based shader) is **UNVERIFIED** (DEEPDEC-04 item 6). Practical rule: **do not
enable fog unconditionally**; expose it as an opt-in layer gated by palette/camera.

---

## 6. WHAT WE SHOULD COPY — authoritative checklist (path:line evidence)

Every item is donor-faithful where labelled OBSERVED; any value the engine owns is
explicitly APPROX. No code was changed by this ticket.

| # | Copy this | Evidence (donor `path:line` unless noted) | Label / caveat |
|---:|---|---|---|
| 1 | One integer tile id per cell; never a splat/noise field as the visible path | `dmscript.global:2026-2035`; `terrain.presets:2-6,134-138`; DTRN-01 C1/C26 | OBSERVED; port dump already carries ids |
| 2 | Base fill from `tile_low/highground.bmp`, `h<0.1`, `tex=floor(r*255) div 2`, only where id=0 | `loadtextureterrainfrombitmap.inc:4,8-9,25-41` | OBSERVED text; runtime activity UNVERIFIED (`;`-commented) |
| 3 | Authorized detail families `test7/8/9/12/14` (not `grass6`/`grass10`) at 1–6 cell scale | `terrain.presets:84-91`; DTRN-06 C07/C08, §3.2, gates D1/D2 | OBSERVED/derived; tonal delta only ≈3–5 L |
| 4 | Parse **all** 118 active smoothing lists (22 Items); 3 horizontal+vertical passes; preserve `0.64/0.0028/0.36` anomaly and Prob=0 separators | `smoothtiles.inc:4-6,42-80,126-180,197-237`; `tilesmooth_scripts.cfg:5-35,155-190,451-452`; RV-TRN-02 §3/§4/§7 | OBSERVED text; runtime UNVERIFIED |
| 5 | Aspect/shore/rock/road selection (8×45° sectors, `|h|>2.7→rock8`, `>2.4→rock4`, `<0.1→none`, roads 0.5/0.375/0.125) | `texturemap.inc:474-511,557-611,627-642`; RV-TRN-02 §5 (corrected road odds) | OBSERVED text; `RandomExt` semantics UNVERIFIED |
| 6 | 8×4×64² complementary organic alpha feather masks at tile seams; `alphanull` for no-transition | `reftile.lib:10-12`; `reftile.mat:6,17`; `reftilealpha.mat:30-37`; alpha.bmp pixels @1070 (RV-TRN-01 §4.1; DALPHA-01 §3.2/§3.3) | Geometry RESOLVED; tile→patch index UNVERIFIED → APPROX |
| 7 | Face alpha projection literals: scale 0.125, front S=(1,0,0,0)/T=(0,0,1,0), side S=(0,1,0,0)/T=(0,0,1,0) | `reftile.mat:120-169` | OBSERVED; promotion rule UNVERIFIED |
| 8 | 25° `vf/vs` face blocks + `rock8/rock4` height overrides | `tiles.lib:119-296,543-719`; `tiles.mat:142-213`; `texturemap.inc:594-601` | Literals OBSERVED; engine application UNVERIFIED |
| 9 | Eye-plane projected UVs and full 1024²/11-mip art, nearest-mag / nearest-mipmap-linear-min, `tfIsotropic` art (no anisotropy) | `hf.pvl.sm.vert:25-32`; `shaders.lib:30`; `reftile.mat:24-49`; DTRN-01 C3/C16 | UV *method* OBSERVED; actual plane values UNVERIFIED → APPROX |
| 10 | Exact Blinn–Phong split, 3/9-tap PCF `of=1/512`, fog 1/2/3 math with `1.442695`; gate fog off by default | `hf.pvl.sm.vert:9-23,42-46`; `hf.pvl.smx3.frag:13-47`; `shaders.lib:15-52`; `colors.lib:34-36,83-92` | Equations OBSERVED; uniform binding UNVERIFIED |
| 11 | Donor parallel light rig (exact ambient/diffuse/specular/position) | `light.cfg:2-31` | OBSERVED; already largely in port |
| 12 | Authored relief float grids + placed `terrainmesh*`/`terrainplateau*` props; rock art gated by collision tag | `pattern.lib` via DTRN-02 C6/C7; `actors.lib:1200-1225`; `texturemap.inc:557-611` | Grids/props OBSERVED; blend math + LOD UNVERIFIED |
| 13 | Height-aware water shore (2×2 fields at −0.5, per-fragment discard, coastfade 0.57 / deepfade 1.07), **not** a flat quad | `generatemap.inc:646-708`; `water.dev.vert:16-18`; `water.dev.frag:167-232`; DTRN-01 C21/C23 | OBSERVED; `hmapTex` binding UNVERIFIED |
| 14 | Winter/Desert tile-*set* swap (grain changes), not a tint | `terrain.lib:12-15`; `terrain.presets:134-263`; `tiles.season:1-4` | OBSERVED text; item-selection binding UNVERIFIED |

---

## 7. WHAT WE MUST NOT ADD (binding negatives)

| # | Do not add | Why (evidence) |
|---:|---|---|
| 1 | **No terrain normal map.** | Heightfield shader `tangentSpace=false`, uses `gl_Normal`/`gl_NormalMatrix` (`shaders.lib:19,918`; `hf.pvl.sm.vert:15`); relief props reserve tangent/binormal texcoords but `TangentSpace` is commented out (`refmountain.actor:34-40`); `tiles.mat` has only `Material.Texture.image` (DTRN-01 C18). A normal slot would be invented. |
| 2 | **No dither / Bayer / quantiser / synthetic luminance or noise "beauty" field.** | Recursive byte scan of donor found 0 `dither`, 0 `mottle`, no Bayer matrices (Bayer hits are German locale words) — DTRN-06 C22. Any gain grid re-creates the documented 2D checkerboard regression (`TERRAIN_CHECKERBOARD_TRIAGE`; DTRN-01 M10, DTRN-06 M10; CHARTER §3). |
| 3 | **No foam image as "donor-faithful".** | No foam/surf/shore image exists under `data\` (DTRN-01 C15). Shoreline look = `sandsea1-6` + procedural `nautic()`/`particles()` in `water.dev.frag:106-127,227`. Any foam art is port art. |
| 4 | No anisotropic filtering claimed as donor parity. | `filteringquality=tfIsotropic` (`reftile.mat:24-49`; DTRN-01 C16). |
| 5 | No invented donor constants: eye-plane values, `TILE_M=2.0`, alpha sub-rect table, blend pass count. | All CONFIRMED_UNVERIFIED / port-only (RV-TRN-01 verdicts A–D; DTRN-01 §8; DALPHA-01 §5). Label **PORT APPROXIMATION**. |
| 6 | No unconditional depth fog, no day/night cycle, no rain, no visible lens flare. | Palette/camera gating (`colors.lib:36`; `camera.cfg:59`; DEEPDEC-04 §3, items 4/9/10). |

---

## 8. UNVERIFIED register (do not promote; no guessing)

1. Donor metres-per-cell / world-unit scale; port `TILE_M=2.0` is port-only.
2. Runtime `gl_EyePlaneS/T[0]` + `gl_TextureMatrix[0]` for ground texgen — **CONFIRMED_UNVERIFIED** (packed `.bind`, entropy 7.96).
3. Cell→alpha patch index and exact complement; `tsDouble`/`ttExtended`/`TileXOffset/TileYOffset` arithmetic — **CONFIRMED_UNVERIFIED**.
4. Face-promotion rule and how `AngleX/AngleZ=25°` enters geometry/texgen.
5. `bmTransparency` pass count / blend equation — **CONFIRMED_UNVERIFIED**.
6. Height-grid→mesh topology, LOD, chunking, draw-call count; exact engine normal formula.
7. Runtime activity of the `;`-commented `.inc` scripts (generator/smoothing/detail) — authoritative *intent*, not proven activity.
8. Water `hmapTex`/`hmapW/H/Min/Max` binding; `heightmapwaves0.tga` is **not** that binding.
9. Effective runtime `fogMode` uniform / `colors.lib`→shader bridge; scene-fog ACTIVE vs "off by default" conflict preserved in §5.
10. **Visual parity — none.** No donor GPU A/B frame exists (CHARTER §3); every visual claim here is structural.

---

## 9. Bottom line

The donor's ground looks organic because it is **discrete tile identity chosen by
authored rules and smoothed by authored weights, with alpha-atlas feathering and
full-resolution projected art** — not because of a noise field, a normal map, foam,
or an invented eye-plane constant. The port already owns most of the representation
(tile ids, 124-name dictionary, 118 smoothing rules, 112 block PNGs, alpha masks,
shader equations); the remaining visible gap is blend structure, UV calibration,
real smoothing data, mips and relief props — all of which must be executed as
labelled donor-grounded work or **PORT APPROXIMATION**, never presented as verified
donor parity.

*End of A08. One report written. No donor file copied/executed; no code, asset,
config, test, git or Godot-runner state changed. Visual parity not claimed.*
