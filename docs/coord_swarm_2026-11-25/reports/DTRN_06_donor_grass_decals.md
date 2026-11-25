---
id: DTRN-06
task: "Donor grass / mottling / decal / alpha-blending details that make terrain look good"
date: 2026-11-25
owner: DTRN-06
status: DELIVERED__RESEARCH_ONLY__NO_DONOR_BINARY_EXECUTED
scope: "Read-only donor data research + read-only variant3d shader/atlas comparison. This report is the ONLY file written; no code, asset, config, test, git or Godot change."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use; Python 3.14 bytes/latin-1 + struct headers + Pillow/Numpy pixel reads; nothing copied, executed or rendered)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 3
visual_parity_claim: false
output: "docs/coord_swarm_2026-11-25/reports/DTRN_06_donor_grass_decals.md"
---

# DTRN-06 — Donor grass / mottling / decal / alpha-blending detail layers

## 0. Goal

Extract the *fine* donor detail that makes ground read as grass rather than flat olive, and turn it
into an actionable recipe for a **terrain-only (no trees / shore / mines)** piece test:

1. exactly which donor textures are grass layers, and how a cell chooses among them;
2. what produces mottling, at what spatial scale, and what constants drive it;
3. how decals are alpha-blended over terrain, and the alpha arbitration rules;
4. how close-zoom detail is supplied (resolution, mips, filtering) — and what is *not* used
   (no synthetic luminance noise, no Bayer/dither, no quantiser);
5. what the variant3d terrain shader/atlas gets wrong or omits today;
6. a concrete fix recipe and measurable acceptance gates.

**Donor is truth; the 2D port is secondary corroboration only.** Every donor fact below carries a
donor `path:line` (or binary path + byte offset), a label, and a second verification. No GPU frame
was captured; all visual effects are predictions, not parity claims. Companion lane DTRN-01
(`docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md`) owns the *broad* render
pipeline; this report owns the *detail-layer* evidence and the piece test.

---

## 1. Sources

### 1.1 Orientation documents (read in full this session)

| # | Path | Use |
|---|---|---|
| O1 | `docs/audit/PIECES/grass_plain.md` | donor block palette, mandated stack warning, A1–A10 gates |
| O2 | `docs/audit/PIECES/grass_mottled.md` | mottled reference crop, §2.2 gain-driver finding, T6 renderer verdict |
| O3 | `docs/audit/PIECES/decal_alpha_arbitration.md` | port PNG IHDR colorType 2 vs donor DXT5 alpha; conversion ticket |
| O4 | `docs/audit/PIECES/rock_striation_arbitration.md` | rock8/rock1 metric arbitration (out of scope for terrain-only) |
| O5 | `docs/audit/PIECES/verdict_grass_relief.md` | renderer-proxy upgrade verdict; residual defects |
| O6 | `docs/audit/TERRAIN_BEAUTY_TRIAGE.md` | ranked root causes, TB-B tickets |
| O7 | `docs/audit/TERRAIN_CHECKERBOARD_TRIAGE.md` | the synthetic `_grass_gain` checkerboard regression and donor-faithful replacement spec |
| O8 | `docs/coord_swarm_2026-11-24/reports/V782_splat_detail.md` | 4-texels/cell splat approximation (1/256 of 2D grain) |
| O9 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_04_gap_recipe.md` | donor-grounded gap recipe, P0/P1 ranks |
| O10 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_05_leftovers.md` | DF-02 register; no-duplicate rule |
| O11 | `docs/audit/RENDER_ARCH_SHADERS.md` | 2D canvas vs 3D donor shading paradigm |
| O12 | `docs/audit/PIECES/donor_decals_and_masks.md` | decal/mask census, `.mat` semantics, U1–U6 |
| O13 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_02_donor_textures.md` | donor texture inventory, P1–P13 port mapping |
| O14 | `docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md` | peer broad-pipeline audit (read to avoid duplication) |

### 1.2 Donor files opened directly (all read-only under `C:\Games\Cossacks 3\`)

Text was decoded with `open(path,'rb').read().decode('latin-1')`; line numbers are 1-based.
Binary facts used `struct.unpack_from` on headers and Pillow/Numpy on decoded pixels. Temp probe
scripts (`dtrn06_*.py`) and all decoded previews lived **only** in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.

| File | Why read |
|---|---|
| `data\terrain\tiles\terrain.lib`, `tiles.lib` (909 lines), `tiles.mat` (1,019), `terrain.presets` (264), `tiles.season` | tile registry, sub-tile/face metadata, index→name, season policy |
| `data\terrain\ref\reftile.lib`, `reftile.mat`, `reftilealpha.mat` | blend flags, filtering, alpha-atlas and eye-linear face-mask bindings |
| `data\terrain\decals\decals.lib` (2,217), `decals.mat` (1,997), `decals.presets` | decal template, season pairs, footprint, `bmTransparency` |
| `data\scripts\common.inc\loadtextureterrainfrombitmap.inc`, `smoothtiles.inc`, `texturemap.inc`, `postprocess.inc` | per-cell detail selection, compatibility smoothing, noise/blur constants |
| `data\gen\tilesmooth_scripts.cfg` (1,863 lines), `tilesmooth.cfg` | exact authored transition weights |
| `data\shaders\shaders.lib`, `obj\hf.pvl.sm.vert`, `hf.pvl.smx3.frag`, `gr.pvl.sm.vert`, `gr.pvl.smx1.frag`, `dec.pvl.sm.vert`, `dec.pvl.smx3.frag` | ground/decal sampler and blend equations |
| `data\terrain\tiles\textures\grass1..10.dds`, `grass_ground*.dds`, `test2/5..14.dds`, `ground1.dds`, `alpha.bmp`, `alphavert.bmp`, `alphanull.bmp` | headers + pixel statistics |
| `data\gen\bitmap\ext\tile_lowground.bmp`, `tile_highground.bmp` | per-cell detail-driver bitmaps |
| `data\terrain\decals\env\envfieldd/w.dds`, `christmastreed.dds`, `pfx\groundexp0..3.dds` | DXT5 alpha payloads |
| `data\gui\menu.inc\eventsettings.inc:152`, `showsettings.inc:555`, `config.cdx` (strings) | donor texture-detail-level option |

### 1.3 Port files read only (comparison)

`variant3d\shaders\terrain_tileindex.gdshader`, `variant3d\scripts\world3d_terrain.gd`,
`variant3d\scripts\tile_atlas_loader.gd`, `variant3d\assets\terrain\atlas\alpha.png`,
`alphavert.png`, `app\tools\heightmap_splat.py`, plus the reports V785/V786/V792/O8/O13.

### 1.4 Verification protocol (three passes)

- **P1 — independent text/header read** in this session (helper `dtrn06_dump.py`, `dtrn06_probe*.py`).
- **P2 — different measurement method or independent source**: pixel probes used a second statistic
  (e.g. alpha-atlas grid means *and* 64-px boundary jumps; decal alpha histograms *and* correlation
  with luma/radius; bitmap patch runs *and* shifted differences); donor text claims cross-checked
  against O1–O14 written by other lanes; `\tilesmooth.cfg` vs `\tilesmooth_scripts.cfg`.
- **P3 — byte-identity checks** where possible: donor BMP → variant3d mask PNG (MAD 0.0), and
  donor DDS block statistics vs O1's independently decoded port-PNG statistics (max ΔL 0.01).

Where a donor script's code lines are `;`-commented in the shipped file, the fact is labelled
**observed (text) / active runtime UNVERIFIED** — this is a real limitation, not a hedge.

---

## 2. Claim table

`D:` below means `C:\Games\Cossacks 3\data\`. "Verify" column names the passes that agree.

| # | Claim | Donor evidence (`D:path:line` / binary) | Method | Label | Verify |
|---|---|---|---|---|---|
| C01 | Ground is one integer TileBlock index per cell (`TMapTerrainDataTile.height/tex/collision[4]`), not splat weights | `scripts\dmscript.global:2026-2035`; `shaders\obj\hf.pvl.smx3.frag:13-14` | text read | observed | P1+P2(O14 C1) |
| C02 | Summer set starts `grass1` at index 0, then `grass2..grass10` at 1–9; `DefaultIndex=0`; Winter mirrors with `*_winter` | `terrain\tiles\terrain.presets:2-6,6-15,133-138` | text read + regex index parse | observed | P1+P2(O14 C5) |
| C03 | `test7/test8/test9/test12/test14` are indices 78/79/80/83/85 in the Summer dictionary; donor detail bitmaps reference exactly those values | `terrain.presets:84,85,86,89,91`; `gen\bitmap\ext\tile_*.bmp` R-channel histogram | text + pixel histogram | derived | P1+P2 |
| C04 | Grass blocks are 1024² DXT1, 11 mips, opaque; `grass1` RGB (76.0,82.5,30.4), L 74.62, hifreq 6.36 | DDS `@12/@16/@28/@84`; Pillow stats | header + pixels | observed | P1+P2(O1 §1.2) |
| C05 | Grass-family roles are distinct: `grass_ground1-3` indices 14–16, `grass_rock1` 13, `grass_sand1/2` 11–12; `ground1`/`test2/3` are road/dirt choices | `terrain.presets:13-22`; `texturemap.inc:617-646` | text read | observed | P1+P2(O13 D2) |
| C06 | Detail-bitmap pass: `h<0.1 → tile_lowground`, else `tile_highground`; `tex = floor(r*255) div 2`; only fills cells whose index is 0 | `scripts\common.inc\loadtextureterrainfrombitmap.inc:4-9,25-41` | text read | observed (text); runtime UNVERIFIED (all lines `;`-commented) | P1+P2(O14 C11) |
| C07 | `tile_lowground.bmp`/`tile_highground.bmp` are 320×320×24; R∈[0,170]/[2,170], 12/10 unique values; `R div 2` yields the grass1/test7/8/9/12/14 set | BMP header + Numpy histogram | header + pixels | observed/derived | P1+P2 |
| C08 | Donor per-cell patches are irregular, 1–6 cells wide: row-run median 2 (low) / 1 (high), p90 6 / 3; shifted |ΔR| saturates by d=8 / d=4 | same BMPs, run-length + shifted-diff | derived | P1+P2 |
| C09 | Compatibility smoothing = 3 passes, horizontal then vertical, weighted roulette over `tilesmooth_scripts.cfg` lists | `scripts\common.inc\smoothtiles.inc:5,35-59,63-80,191-237`; `gen\tilesmooth_scripts.cfg:1-35` | text read | observed (text); runtime UNVERIFIED | P1+P2(O14 C8/C9) |
| C10 | Authored grass transition weights: `grass1/grass2/test8` each Prob=1; `grass7/test12/test13/test14` each Prob=0.25 | `gen\tilesmooth_scripts.cfg:155-190` | text read | observed | P1+P2 |
| C11 | Tile atlas is sampled by eye-plane texgen: `s=dot(realpos,EyePlaneS[0])`, `t=dot(realpos,EyePlaneT[0])`, `texGen=true` | `shaders\obj\hf.pvl.sm.vert:26-33`; `shaders.lib:30,929` | text read | observed | P1+P2(O11 E5) |
| C12 | Heightfield fragment takes RGB from texUnit0 and **alpha from texUnit1**, then `rgb*ambient+diffuse + specular`, 3-tap PCF (`of=1/512`), fog, final colour | `hf.pvl.smx3.frag:13-17,20-30,34-50`; `shaders.lib:34-49` | text read | observed | P1+P2(O14 C17/C19) |
| C13 | Flat-tile second sampler is `alpha.bmp` via `Texture2Name=alpha`, `bmTransparency`, `tmModulate`, `imagealpha=tiaDefault`; only `alpha0a/b/c` override to `alphanull` | `terrain\ref\reftile.mat:6,17,31,36`; `terrain\tiles\tiles.mat:1-4,347-360` | text read | observed | P1+P2 |
| C14 | `alpha.bmp` is 512×256, 8-bpp palette (254 greys), intensity→alpha (`tiaAlphaFromIntensity`, `tfAlpha`), nearest min/mag, `twBoth` | `terrain\ref\reftilealpha.mat:30-37`; BMP header + Pillow | text + header + pixels | observed | P1+P2(O13 D19) |
| C15 | `alpha.bmp` is an **8 columns × 4 rows grid of 64×64 organic feather masks**: 64-px boundary jumps 64–185 vs interior 8.13; exact complementary pairs exist (e.g. (0,0)+(3,3)=255) | same BMP, Numpy grid + complement search + boundary analysis | pixel analysis | derived | P1(grid means)+P2(boundary/complement) |
| C16 | `alphanull.bmp` is constant 0 across the whole 512×256 atlas → a deliberate "no transition" mask | BMP pixels (mean 0, unique 1); `reftilealpha.mat:248-255` | pixels + text | observed | P1+P2(O14 C24) |
| C17 | Vertical faces swap the second sampler to `alphavert.bmp` with `TextureScale=0.125`, `tmmEyeLinear`, S/T planes from X/Y and world Z; `rockNvf/vs` reuse the base rock DDS | `reftile.mat:120-169`; `tiles.mat:142-157`; `tiles.lib:119-136` | text read | observed | P1+P2(O13 D9) |
| C18 | Decals use `bmTransparency`, `imagealpha=tiaDefault`, `tmModulate`, maLinear/miLinearMipmapLinear, `moIgnoreFog=True`; DXT5 alpha is coverage/opacity, not a data ramp | `decals.mat:1-37`; `decals.lib:1-35`; `dec.pvl.smx3.frag:10-14` | text + shader | observed | P1+P2(O12 §2.3) |
| C19 | Decal fragment: `color = tex0 * lighting`, `color.a = tex0.a * material.diffuse.a` — alpha multiplies through, RGB is modulated, not replaced | `dec.pvl.smx3.frag:10-14`; `dec.pvl.sm.vert:21` | shader text | observed | P1+P2(O11 E) |
| C20 | `envfieldd`/`envfielddw` share byte-identical DXT5 alpha: mean 148.12, 256 levels, bbox(a>8)=(17,19,494,494), corr(A,luma)=0.069, corr(A,radius)=−0.606 | DDS header + Numpy decode | pixels | observed/derived | P1+P2(O3 §3, O12 §3) |
| C21 | `groundexp0..3` alpha never reaches 255 (max 236–250), 54–60% interior pixels, corr(A,luma) −0.27…−0.54 → darker core more opaque | same DDS decode + Numpy | pixels | derived | P1+P2(O12 §3) |
| C22 | No dither/Bayer/quantiser token exists in any donor byte; `postprocess.inc` uses random recursive 8-neighbour noise (`cNoiseProb=0.5`, power 1–3, diag ×0.5, depth ≤10) then Gaussian blur r=0.925 | full recursive byte scan (0 `dither`, 0 `mottle`); `postprocess.inc:63-82,126-225,307-347,349-441` | scan + text | observed | P1+P2 |
| C23 | Donor texture detail is supplied by full mip chains + nearest-mag / nearest-mipmap-linear-min + tfIsotropic; project option `DDSDetailLevel` exists | DDS `@28` (11 mips); `reftile.mat:24-49`; `gui\menu.inc\eventsettings.inc:152`; `config.cdx` strings | header + text | observed; option values UNVERIFIED | P1+P2(O13 D18) |
| C24 | No donor terrain normal map: `tangentSpace=false`, `hf.pvl.sm.vert:15` uses `gl_Normal`; `materials\env\detail.dds` is a named env material, terrain role UNVERIFIED | `shaders.lib:19`; `tiles.mat:2-141`; `env.mat:637-638` | text | observed / UNVERIFIED(role) | P1+P2(O13 D20/UNV-2) |
| C25 | Grass grain magnitude (native donor block): grass1 hifreq 6.36, d1 7.69 → d12 9.29 (near white-noise); reference JPEG is patch-dominated (d1 2.24 → d12 4.39) | DDS pixels; O1 §1.1 | pixels + prior doc | derived | P1+P2(O1 §1.2) |
| C26 | Port deco PNGs are **RGB colorType 2, no alpha band**; donor RGB byte-identical but full DXT5 alpha dropped; the committed converter cannot have produced them | O3 §2–§5 + `copy_assets.py:44-57,121-127` | prior independent read | observed (port) | P2(O3)+P3(file list) |
| C27 | variant3d masks `alpha.png`/`alphavert.png` are byte-identical to donor BMP intensities (MAD 0.0) — the mask *data* is faithful even where its mapping is not | donor BMP vs `variant3d\assets\terrain\atlas\*.png` | Numpy equality | observed | P1+P2(V785 §4) |
| C28 | variant3d atlas has 124/121 filled 1024² cells, grid 16×8; top ids `14:28535, 0:15993, 16:15962, 79:7667, 78:6691` | V785 §6; `g32_dump.json` histogram | prior measurement + this read | observed (port) | P2(V785)+P2(V792) |

**Not promoted:** exact donor metres-per-cell, eye-plane/texgen matrix values, face-promotion rule,
`bmTransparency` pass count, active execution of the `;`-commented scripts, and `detail.dds` terrain
role — all UNVERIFIED and explicitly carried into §7.

---

## 3. Donor detail-layer algorithm and constants

### 3.1 The four real "layers" of grass detail

The donor does **not** layer translucent albedo maps inside a tile. The visible grass is produced by
four discrete stages:

| Stage | Mechanism | Donor evidence | Detail contributed |
|---|---|---|---|
| L1 **base tile** | One `tileblock` index per cell; summer index 0 = `grass1` for unassigned cells | `terrain.presets:4,6`; `tiles.mat:2-4`; `loadtextureterrainfrombitmap.inc:37-42` | 1024² authored grain, hue, luma |
| L2 **variety tiles** | `tile_lowground`/`tile_highground` red channel → `tex = R div 2`, only where index still 0; picks `test7/8/9/12/14` on detail patches | `loadtextureterrainfrombitmap.inc:4-9,25-41`; bitmap pixels; `terrain.presets:84-91` | per-cell mottling at 1–6 cell scale |
| L3 **seam resolution** | 3-pass neighbour compatibility rewriting with authored `Prob` weights | `smoothtiles.inc:191-237`; `tilesmooth_scripts.cfg:155-190` | organic boundaries; no square lattice |
| L4 **render modulation** | tile RGB × second alpha-atlas sampler, lighting, shadow, fog; decals drawn as a separate `bmTransparency` pass on top | `reftile.mat:6,17`; `reftilealpha.mat:30-37`; `hf.pvl.smx3.frag:13-17`; `dec.pvl.smx3.frag:10-14` | soft tile transitions, decals, relief cue |

### 3.2 L2 constants — the donor's mottling driver (measured)

`tile_lowground.bmp` / `tile_highground.bmp` are 320×320×24, R channel only (G=B=0). Histogram:

| Bitmap | R range | Dominant R → tile id → name | Patch scale |
|---|---|---|---|
| `tile_lowground.bmp` | 0–170, 12 unique | 0 → idx 0 `grass1` (50.3%); 158 → 79 `test8` (19.3%); 156 → 78 `test7` (10.6%); 2 → idx1 `grass2` (7.4%); 166/170 → 83/85 `test12`/`test14` | row-run median 2, p90 6; shifted |ΔR| saturates at d≈8 |
| `tile_highground.bmp` | 2–170, 10 unique | 156 → 78 `test7` (34.0%); 158 → 79 `test8` (16.8%); 160 → 80 `test9` (14.3%); 170 → 85 `test14` (12.7%); 14 → 7 `grass8` (7.4%) | row-run median 1, p90 3; saturates at d≈4 |

At the port's `TILE_M = 2.0` (`world3d_terrain.gd:93`, **port constant, not donor**), this is
roughly **2–12 m** patch diameter — the donor-scale mottling, expressed as *tile identity*, not as a
luminance delta. `test7/8/9` block means are L 71.63 / 70.75 / 69.93 versus `grass1` L 74.62
(difference ≈ 3–5 L), so donor mottling from L2 is **tonally subtle**; the large standard deviation
seen in the "mottled" reference crop (`grass_mottled.md` §1.1, std 37.55) comes from relief shading,
rocks and explosions in that crop, not from a ±30 L grass gain.

**Correction to prior piece recipes:** `grass_mottled.md` used `grass6` (L 47.4) and `grass10`
(L 69.1) as overlay blocks, but the donor's own detail bitmaps never select them. `grass6` is a
dark shadow block (`grass_plain.md` §1.2); using it as a patch layer is port art, not donor truth.

### 3.3 L3 constants — anti-checkerboard

- `smoothtiles.inc:5` loads `data\gen\tilesmooth_scripts.cfg`; `:42-59` sums `Prob`, `:63-80`
  roulette-selects a replacement; `:197-234` applies horizontal then vertical sweeps; `:237` calls
  `SmoothTileMap(..., 3)`.
- Authored grass rule (`tilesmooth_scripts.cfg:155-190`): list {`grass1`, `grass2`, `test8`} each
  `Prob=1`; next list {`grass7`, `test12`, `test13`, `test14`} each `Prob=0.25`. Sea rule
  (`:3-36`): {`sandsea1..4`} `Prob=1`, {`sandsea5` 0.7, `sandsea6` 0.3}.
- `postprocess.inc:63-82,126-225,307-347`: random recursive noise on *class masks* (relief/water)
  with `cMinDropPower=1`, `cMaxDropPower=3`, `cNoiseProb=0.5`, `cMinNoise=cMaxNoise=1`,
  `cTryNoiseNearestProb=0.6`, recursive `0.99`, `cMaxDeep=10`, diagonal `modpower=0.5`;
  `:349-441` Gaussian blur (`r=0.925`, radius `round(2.57r+0.5)`) before saving `bitmaptrg.bmp`.
  Those output BMPs are **not shipped**, so this pass is editor/authoring-side; runtime activity
  UNVERIFIED (all script lines `;`-commented).
- **No dither exists in the donor**: recursive byte scan of the whole install found 0 `dither`,
  0 `mottle`, 0 genuine Bayer matrices (`bayer` hits are German locale words "Bayern"; `checker`
  hits are `CheckErrors`). Dither/quantisation is a *port* invention (`TERRAIN_CHECKERBOARD_TRIAGE`
  §6: `GRASS_HARD_LEVELS/DITHER/SPT`, 4-px NEAREST squares), not donor practice.

### 3.4 L4 alpha arbitration — exact rules

1. **Tile transition alpha (flat ground).** `reftile.mat:6` binds a second texture `alpha`;
   `:17` `bmTransparency`; `:31` `imagealpha=tiaDefault` on the *tile*; `:36` `tmModulate` (RGB
   multiplied into ground). `reftilealpha.mat:30-37` binds `alpha.bmp` as `tfAlpha` with
   `imagealpha=tiaAlphaFromIntensity`, `maNearest`/`miNearest`, `twBoth`. The fragment reads
   `color.rgb = texUnit0.rgb`, `color.a = texUnit1.a` (`hf.pvl.smx3.frag:13-14`).
   All 112 tile materials inherit this; only `alpha0a/b/c` override to `alphanull`
   (`tiles.mat:347-360`), whose pixels are all zero → no transition.
2. **Measured atlas structure.** `alpha.bmp` 512×256 = **8 columns × 4 rows of 64×64** masks
   (matches the commented `AlphaRows=8, AlphaCols=4, AlphaTileSize=64` at `reftile.lib:10-12`).
   Boundary-to-boundary mean |Δalpha| is 64–185 (discrete masks); interior mean |Δ| is 8.13
   (smooth organic gradients). ASCII inspection shows ragged, non-axis-aligned edges, and pairs
   are complementary — e.g. tile (0,0)+(3,3)=255 exactly. **This is the donor's feathering
   primitive: authored complementary organic masks, never a radial gradient or a dither matrix.**
   `alphavert.bmp` is the same idea at 1024×512 = 8×4×128² for faces (`reftile.mat:120-169`).
3. **Decal alpha.** `decals.mat:1-37` sets `bmTransparency`, `imagealpha=tiaDefault`,
   `tmModulate`, linear mag/mipmap-linear min, `moIgnoreFog=True`, on all decals including
   `envfieldd/w` (`:110-120`) and `groundexp0..3` (`:1247-1261`). The decal shader multiplies the
   decal RGB by lighting and sets `color.a = tex0.a * gl_FrontMaterial.diffuse.a`
   (`dec.pvl.smx3.frag:10-14`). So decal alpha is a coverage/opacity multiplier applied by the
   blender; it must be preserved byte-for-byte from DXT5.
4. **Arbitration rule (derived, strongly supported):** alpha is *either* a transition intensity
   (tile BMPs) *or* decal coverage/opacity (DXT5) — never a distance field, height ramp, or noise
   source. Evidence: `envfieldd` alpha is uncorrelated with luma (0.069) and only moderately
   centre-weighted (corr with radius −0.606), while `groundexp` alpha is *inversely* correlated
   with luma (−0.27…−0.54) and never fully opaque (max 236–250). A "clean radial ramp" would be a
   port invention; use the donor bytes.
5. **Season pair rule:** `envfieldd` and `envfielddw` share identical alpha; only RGB changes
   (`decals.lib:38-44`; byte-equal alpha measured). Blend once, recolour twice.

### 3.5 Close-zoom detail

- Every grass DDS is 1024² DXT1 with **11 mip levels** (`@28`) and `filteringquality=tfIsotropic`,
  `magfilter=maNearest`, `minfilter=miNearestMipmapLinear` (`reftile.mat:24-37`). At close zoom the
  full-resolution texel is shown with nearest magnification (crisp authored grain: grass1 hifreq
  6.36); at distance mipmaps keep it stable. Donor has a `DDSDetailLevel`/`TextureFilteringQuality`
  project option (`menu.inc\eventsettings.inc:152`; `config.cdx` strings), but numeric option
  values are **UNVERIFIED** in readable text.
- The grass/grass-decal shader families are single-sampler: `Grass` uses one `texUnit0`
  (`shaders.lib:105-129`), `Decal` one `texUnit0` (`:131-155`). There is **no second grass albedo
  layer, no detail texture, no bump** in the ground path. `tangentSpace=false` (`shaders.lib:19`)
  and `hf.pvl.sm.vert:15` uses `gl_Normal`; the named `detail.dds` 2048² env material
  (`materials\env\env.mat:637-638`) is not bound to terrain (role UNVERIFIED).
- Therefore "more detail at close zoom" in the donor = **more true texels per world unit**, not
  more procedural layers. The port's 2D path chose 64 px/cell (`world.gd:877-880`), which is the
  right direction; the 3D splat at `n=1` (one mean RGB per cell, `heightmap_splat.py:191-208`) and
  even V7-82's `n=4` (V782 §3: 1.233/255 in-cell deviation, ~1/256 of 2D detail) are approximations.

---

## 4. What exists / is missing / is wrong in the variant3d terrain shader + atlas

### 4.1 What exists (and is donor-grounded)

| Item | Port evidence | Status |
|---|---|---|
| One integer tile id per cell, from the live game buffer | `variant3d\scripts\world3d_terrain.gd:650-708`; V792 §2 | donor representation present |
| 124-cell / 16×8 atlas of donor block PNGs; 31 shipped ids in range 0–85 | V785 §6, §3 | art and ids donor-derived |
| Donor alpha/alphavert BMPs converted and byte-identical; repacked into alpha | `world3d_terrain.gd:253-296`; §2 C27 | data faithful, mapping approximate |
| Tile-index shader transcribes donor eye-plane texgen, Blinn–Phong, 3/9-tap PCF, fog | `terrain_tileindex.gdshader:239-375`; V786 §1 | equations present, bindings approximate |
| Face mode derived from `cDiff1/cDiff2` | `world3d_terrain.gd:347-382,691-708` | PORT APPROXIMATION, not donor promotion |
| Water module and donor light rig wired | V792 §2 | out of terrain-only scope |

### 4.2 Missing / wrong (ranked by effect on terrain quality)

| # | Defect | Port evidence | Donor truth | Effect |
|---|---|---|---|---|
| M1 | **The donor's two-pass transparency is replaced by one `blend_mix` pass with the mask re-applied as framebuffer ALPHA**; ground becomes semi-transparent over sky | `terrain_tileindex.gdshader:24-26,375`; `world3d_terrain.gd:316-324` (A/B measured luma 42.735→38.425 when removed) | `reftile.mat:17` + `hf.pvl.smx3.frag:13-14` blend a *second* tile pass | Washed/darkened, sky-dependent colour; biggest single visual wrongness. PORT APPROXIMATION, deliberately not fixed. |
| M2 | **Eye-plane / texture-matrix uniforms are never bound**: shader defaults are identity-like, `uv_repeat=(1,1)` gives a 1 m repeat period in Godot space while cells are `TILE_M=2.0` | `terrain_tileindex.gdshader:103-105,185-187`; `_tileindex_material()` at `world3d_terrain.gd:303-325` sets only 5 parameters | `hf.pvl.sm.vert:30-32`, `shaders.lib:30` + engine-bound planes | Block art repeats at the wrong scale/phase; looks like tiled wallpaper rather than donor ground. Exact donor planes UNVERIFIED, so calibrate, don't guess. |
| M3 | **Mask UV is `fract(v_st)`**, not donor `gl_MultiTexCoord1`; no 64² sub-rect selection from `alpha.bmp` | `terrain_tileindex.gdshader:189-194,265,323`; V785 §7.2 | `hf.pvl.smx3.frag:14`; `reftile.lib:7-12` (commented atlas values) | The 8×4 complementary feather masks are sampled as one whole atlas lookup, so seams do not fade the way the donor's do. |
| M4 | **No mipmaps generated on the atlas texture** although the sampler hint requests nearest-mipmap | `tile_atlas_loader.gd:272,378` (`ImageTexture.create_from_image`, no `generate_mipmaps()`); shader `:54` | 11 mips in every grass DDS; `reftile.mat:32-33` | Distant grass aliases/shimmers; close-up grain is crisp but unstable. |
| M5 | **Grass mottling is reduced to tile swaps from a proxy `_assign_tileblocks`**, not donor `tile_low/highground` + authored `tilesmooth_scripts.cfg` weights | V785 §6 histogram; O7 §7.2; `gen\tilesmooth_scripts.cfg:155-190` unread by runtime | §3.2/§3.3 | The correct *families* are present (79/78 are top ids) but boundary statistics/weights differ → irregularity looks different from donor. |
| M6 | **Decals have no alpha in the port** and no 3D terrain decal pass; donor DXT5 coverage is gone | O3 §2–§5; O12 §4; `app\tools\gen_variant_maps.py:188-190` (preview only) | `decals.mat:17,31`; `dec.pvl.smx3.frag:14` | Field/scorch/burn plates cannot blend; if drawn, they are hard rectangles. |
| M7 | **Shadow PCF disabled and fog off by default**; donor has `shadowed=true` (`shaders.lib:26`) and fog modes | shader `:151,169`; `world3d_terrain.gd:580-588` (`shadow_enabled=false`) | `hf.pvl.smx3.frag:20-46`; `shaders.lib:26` | Missing relief/shadow cue that makes donor grass read as 3D. Shadow matrix/projection UNVERIFIED. |
| M8 | **Face tiles promoted by a port slope test; 25° `AngleX/AngleZ` never applied**, `alphavert` projected with port axis conversion | `world3d_terrain.gd:360-382`; shader `:315-318,370-372`; `tiles.lib:119-136` | donor `tiles.mat:142-157`, `reftile.mat:120-169` | Rock/grass rims lack donor fluted character. Mostly out of terrain-only scope. |
| M9 | **V7-82 splat fallback still one averaged RGB per cell (or 4²), 1/256 of 2D grain** | `heightmap_splat.py:191-208,230-297`; V782 §3 | full 1024² donor grain | If atlas load fails, quality collapses; do not treat fallback as parity. |
| M10 | **Any synthetic luminance/noise "beauty" field re-creates the 2D checkerboard** | `TERRAIN_CHECKERBOARD_TRIAGE` §6–§7: 1.05/2.55 c/tile sampled at 1 sample/tile, 4-px NEAREST quantisation, 4-chunk mirror beat | donor uses tile ids + organic 64² alpha + 3-pass smoothing, no dither | Hard no-go: do not fix M1–M5 by adding a gain field, Bayer matrix or extra noise octave. |

**Verdict:** the variant3d path now has the right *representation* (tile ids, atlas, donor equations)
but not the donor's *blend structure, UV calibration, mask sub-rects, or mips*. The biggest visible
sins are M1 (transparent ground over sky) and M2/M3 (wrong repeat phase / whole-atlas mask lookup).

---

## 5. Fix recipe

### 5.1 For the terrain-only piece (primary deliverable of this task)

Build the piece from **donor-chosen blocks and donor-derived coverage**, not from a luminance field:

1. **Base:** `grass1` (donor index 0), mirror-tiled as in `world.gd:713-732` `_mirror_tileable`;
   do not start from `grass6` (L 47.4, shadow block).
2. **Patch layers:** use the donor's own detail set —
   `test7` (L 71.63), `test8` (70.75), `test9` (69.93), and optionally `test12`/`test14` —
   at ceilings derived from the measured bitmap frequencies (lowground: `grass1` 50%,
   `test8` 19%, `test7` 11%, `test12/14` 7%; highground: `test7` 34%, `test8` 17%, `test9` 14%).
   Sample the donor `tile_lowground.bmp`/`tile_highground.bmp` at the piece's cell scale (320²→cell
   grid) instead of inventing random blobs. This corrects the prior `grass6`/`grass10` overlay choice.
3. **Coverage feather:** resample the donor `alpha.bmp` 8×4×64² masks (converted, byte-identical) as
   the patch opacity; choose complementary pairs so total coverage remains 1. Do not use radial
   gradients, Gaussians alone, or binary masks.
4. **No exposure invention inside the block stack:** apply a single, declared sun lift at the end to
   reach L≈86 if matching the JPEG reference (O1 §3.1). Donor art is pre-lighting; the lift is a
   piece-pipeline step, not a donor constant.
5. **No dither, no quantisation, no synthetic gain field** (M10). Preserve the donor's fine grain;
   downsample only at the final 512² with LANCZOS.
6. **Tileability:** mirror-symmetric patch grids (O5 §7.7) keep the seam within 1.5× interior.
7. **Scope mask:** exclude `sandsea*`, `water*`, `rock*`, tree sprites and mine aprons entirely;
   the piece is grass + donor-mandated dirt patches only.

Suggested spec shape (names donor-derived; numbers are *piece* targets, not donor constants):

```json
{
  "name": "grass_terrain_only",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "grass1", "tile": true},
    {"type": "block", "name": "test8", "opacity": 0.20, "coverage": "donor:tile_lowground:R=158"},
    {"type": "block", "name": "test7", "opacity": 0.12, "coverage": "donor:tile_lowground:R=156"},
    {"type": "block", "name": "test9", "opacity": 0.10, "coverage": "donor:tile_highground:R=160"},
    {"type": "feather", "source": "donor:alpha.bmp", "grid": [8,4], "tile_px": 64, "complementary": true}
  ],
  "post": {"sun_lift_luma": 8, "final_resample": "LANCZOS", "dither": false}
}
```

### 5.2 For variant3d (follow-up, separate ownership)

1. **M1:** add a real base-tile pass under the alpha-modulated pass (or make the ground opaque and
   apply the donor mask only at tile seams). Keep `mask_to_alpha` as a diagnostic only; the measured
   A/B (luma 42.735→38.425) shows the current value is compensating for sky, not reproducing donor.
2. **M2/M3:** bind calibrated eye-plane/texture-matrix uniforms and map `alpha.bmp` **sub-rects**
   per tile pair (64² cells), replacing `fract(v_st)` for the mask UV. Calibrate against a donor
   frame; do not invent plane values or claim parity without an A/B.
3. **M4:** call `generate_mipmaps()` on the atlas texture (or import it with mips) and keep
   `filter_nearest_mipmap`; verify at two camera distances.
4. **M5:** parse `tilesmooth_scripts.cfg` weights and the two authoring BMPs into the generator's
   `_apply_detail_pass` so per-cell patch statistics match the donor's 1–6 cell runs.
5. **M6:** regenerate `deco_png` through the alpha-preserving path (`copy_assets.py:53`, O3 §6) and
   add a terrain decal pass that consumes DXT5 alpha; never flatten to RGB.
6. **M7:** re-enable shadows only with a bounded donor-grounded frustum and A/B; fog stays mode 0
   unless the palette/camera calls for it (DTRN-01 C20).
7. **No splat fallback as "done":** keep V7-82 explicitly labelled PORT APPROXIMATION; never let a
   failed atlas load silently ship a 1-texel/cell surface.

---

## 6. Terrain-only piece test — measurable criteria

Scope: 512² RGB PNG, no trees, no shore/water/sandsea, no mines/rock faces. Measure with Pillow
12.1.1 as in O1/O2 (L = ITU-R 601-2; hifreq = mean |L − GaussianBlur(5)|; 8×32 histogram; circular
HSV hue over sat>0.12/val>0.1). Gates A1–A10 are inherited from O1 §4; D1–D7 are new donor-fidelity
gates. No threshold was weakened to fit the mandated `grass6+grass9@0.3` stack (L 54.7, fails A1/A2/A10).

| # | Criterion | Target | Pass band | Method |
|---|---|---|---|---|
| A1 | Mean luminance | 86 | 78–95 | `ImageStat(L).mean` |
| A2 | Luminance bins | `[1,12,62,22,3,0,0,0]` | ≥3 bins ≥3%; bin2 45–75%; bin3 8–35% | 8×32 histogram |
| A3 | Luminance std | 10 | **8–14** (NOT 30–40 — that crop includes rock/explosions) | `ImageStat(L).stddev` |
| A4 | Hi-freq | 5 | 3–9, hard fail >12 | mean abs(L − blur5) |
| A5 | Hue | 63° | 58–68° | circular mean HSV |
| A6 | Sat / value | 0.55 / 0.35 | 0.45–0.65 / 0.30–0.40 | HSV means |
| A7 | Palette anchors | all top-6 in `#4A501D`–`#767448` | ≥1 bin in `#5C5E28`–`#767448` | MEDIANCUT 16 |
| A8 | Noise scale | d1 3–7, d5 4–9, d12 5–10 | monotone rise, patch 2–12 px at piece scale | shifted-image L diff |
| A9 | Tile seam | ≤1.5× interior | edge diff / neighbour diff | edge profile |
| A10 | Dark-base guard | L > 70 | fail if L < 70 | same as A1 |
| D1 | Patch blocks are donor-selected | `{test7,test8,test9,test12,test14}` (+ grass1 base) | no `grass6`/`grass10` patch layer; spec names match donor ids 78/79/80/83/85 | spec audit + `terrain.presets:84-91` |
| D2 | Coverage derives from donor bitmaps | piece coverage field correlates with resampled `tile_lowground/highground` R | Spearman ρ ≥ 0.6 against the donor R field at matching cell grid; no RNG-only blobs | Numpy correlation |
| D3 | Feather uses donor 64² alpha masks | 8×4 grid, ≥32 unique alpha levels, complementary pairs | nonzero mask interior >50%; no radial-only/2-level masks | PNG level count + complement test |
| D4 | No dither / quantiser | distinct L levels ≥32; no 4-px NEAREST squares | 16-px block-mean variance fraction ≤0.45; 128-px ≤0.20 (clean ref 0.437/0.177; checkerboard 0.760/0.230, O7 §3) | block-mean variance |
| D5 | No synthetic gain field | spec contains no `patches`/`gain`/`dither` layer; no luminance grid | grep spec; verify A3 still in band | spec + stats |
| D6 | Scope purity | no sand/blue/rock/tree pixels | sand/water hue pixels <0.5%; bright rim (L>160) <1%; manifest lists no `sandsea*`/`rock*`/tree | colour classifier + manifest |
| D7 | Donor palette distance | ΔRGB ≤6 from `#4E5221` (field) or `#656435` (sunlit) | hue 58–66°; no grey/white tail | box means vs donor DDS |

**Failure signatures (reject):**
- L < 70 or bins collapsed to 1–2 → the `grass6` dark-base regression (O1 §1.3).
- std 30–40 with blobby 40–80 px patches → the `grass_mottled` gain-driver target imported from a
  crop that contained rock/explosions (O2 §1.1 caveat); not valid for terrain-only.
- 16-px block-mean fraction ≥0.7 or grid_peak ≥0.20 → checkerboard / grid beat (O7 §3; O2 T6 C).
- Any 4-px square contours → NEAREST-upscaled quantised gain (O7 §6 item 2).
- Blue/tan/white pixels >1% → shore or rock leaked into the terrain-only piece.

**Variant3d structural gates (companion, no GPU A/B claimed here):** atlas/sampler/mask repack
counts as in V792 §3 (20/20); mips generated on `tile_atlas`; `mask_to_alpha` behaviour documented;
eye-plane uniforms either bound from a calibrated source or explicitly flagged APPROX in `stats`;
`shadow_enabled` state recorded; no decal alpha loss. A donor GPU A/B is still required before any
visual-pass claim (DF-01, O10 §2).

---

## 7. Open questions

1. Are the `;`-commented scripts (`texturemap.inc`, `loadtextureterrainfrombitmap.inc`,
   `smoothtiles.inc`, `postprocess.inc`) actually executed in the shipped donor build? They are
 authoritative *intent* text; the authoring outputs (`bitmaptrg.bmp`) are absent, so runtime
 activity is UNVERIFIED. Do not claim bit-exact donor generation from them.
2. What are the engine-bound `gl_EyePlaneS/T[0]` and `TextureMatrix[0]` values for flat tiles and
   each face refkey? Without them, M2 cannot be calibrated to parity (V786 §6 #1).
3. What is the exact `tsDouble`/`ttExtended` sub-rect mapping of `alpha.bmp` to a tile pair?
   `reftile.lib:7-12` is commented; the port's whole-atlas lookup is an APPROX (V785 §7.2).
4. How many `bmTransparency` passes does the donor actually use, and can one Godot pass plus a real
   base pass reproduce it? Needs a donor GPU A/B (V786 §6 #8).
5. Is `materials\env\detail.dds` (2048²) ever used as a terrain micro-detail overlay? Named
   material only; no terrain binding observed (O13 UNV-2). Do not add it on speculation.
6. What numeric values were available under the donor `DDSDetailLevel` option in the reference
   screenshots? Strings exist in `config.cdx`/menu scripts; values UNVERIFIED.
7. Do the port's `_assign_tileblocks` detail pass and 3-pass smoothing reproduce the donor's
   *statistical* patch runs (median 1–2 cells, p90 3–6)? Not measured here.
8. Does the terrain-only piece need the +8…+15 L sun lift at all, or should it match the donor DDS
   pre-lighting palette (L≈74.6) exactly? Reference crops are post-lighting JPEG (O1 §5), so this
   is a review decision, not a donor fact.
9. Exact donor metres-per-cell and face-promotion rule remain UNVERIFIED; `TILE_M=2.0` is port-only.

---

## 8. Summary

- **Donor grass is not a layered albedo shader.** It is one integer tile index per cell, a bitmap-
  driven choice among `grass1` and the `test7/8/9/12/14` detail blocks, 3 passes of weighted
  neighbour compatibility rewriting, and a second *alpha-atlas* sampler blended with
  `bmTransparency`. Fine detail comes from 1024² DXT1 art with 11 mips, nearest magnification and
  nearest-mipmap-linear minification — not from procedural noise, dither or a luminance gain.
- **Mottling scale is 1–6 cells (≈2–12 m at the port's 2 m/cell), tonal difference only ≈3–5 L**
  between `grass1` and the donor's detail blocks. Large std in the "mottled" JPEG crop is relief,
  rock and explosions, not grass gain. Prior grass piece recipes used the wrong overlay family.
- **Alpha has two donor meanings only:** authored 8×4×64² complementary organic feather masks for
  tile seams, and DXT5 coverage/opacity for decals. `envfieldd/w` share one alpha; scorch alphas
  never reach full opacity. All must be preserved byte-for-byte; no radial ramp synthesis.
- **No dither exists in the donor install** (0 byte hits for `dither`/`mottle`; Bayer hits are
  locale words). Donor anti-checkerboard = organic masks + weighted smoothing + Gaussian blur of
  class masks; any port luminance grid/quantiser is the documented checkerboard regression.
- **variant3d has the right representation but the wrong blend/UV calibration:** single-pass
  mask-as-framebuffer-alpha, unbound identity eye planes, `fract()` mask UV with no 64² sub-rects,
  no atlas mipmaps, decal alpha lost in conversion. Fix those before adding any "beauty" layer.
- **Terrain-only piece test:** `grass1` base + donor-selected `test7/8/9` patches, donor alpha-mask
  feather, no dither/gain, L 78–95, std 8–14, hifreq 3–9, ≥3 histogram bins, seam ≤1.5× interior,
  plus new D1–D7 donor-fidelity gates. No donor binary was copied or executed; visual parity is not
  claimed.

*End of DTRN-06. One report written; no donor binary copied/executed; no Godot run; no code, asset,
config, test or git state changed.*
