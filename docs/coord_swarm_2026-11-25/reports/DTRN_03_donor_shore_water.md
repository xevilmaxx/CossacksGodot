---
id: DTRN-03
task: "Donor SHORE + WATER transition (part of the terrain quality problem)"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_BINARY_EXECUTED
scope: "Read-only donor research + variant3d gap analysis. This report is the ONLY file written; no code/asset/config/test/git edit."
donor: "C:\\Games\\Cossacks 3\\data (READ-ONLY, private use; Python 3.14 bytes/latin-1 + Pillow headers/stats; no donor file copied, run, unpacked or rendered)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 3
visual_parity_claim: false
---

# DTRN-03 — Donor SHORE + WATER transition

## 0. Goal

Document **exactly how the donor distinguishes shallow from deep water, how wide the
shore mask / transition is, how sand vs rock shore tiles are selected, every water
colour / alpha / Fresnel / glint constant, the animation/flow terms, how the water
surface height relates to terrain height, and what happens at the exact shoreline**.
Then compare with the current variant3d (`water3d.gd`, `water3d.gdshader`,
`world3d_terrain.gd`, `game.gd`, `terrain_tileindex.gdshader`) and state what exists,
what is missing, and what is wrong. Finish with a concrete fix recipe and the numeric
criteria for testing **terrain + shore as a separate piece on the smallest map**.

Donor = truth. 2D port = secondary helper only. Every claim is tagged
**observed** (literal donor byte/line/pixel read), **derived** (arithmetic or control
flow on observed lines), **inferred** (interpretation with a caveat), or
**UNVERIFIED** (binding lives in `cossacks.exe` or is otherwise unreadable). All key
claims were checked in three independent passes (§1.3). No Godot process was started
and no donor asset was copied.

---

## 1. Sources and method

### 1.1 Orientation documents read in full this session

| # | Path | Role |
|---|---|---|
| O1 | `docs/audit/TERRAIN_DONOR_WATER.md` | TDR-4: donor water asset/constant/shader tables, W-1…W-7 |
| O2 | `docs/audit/WATER_REPORT.md` | independent re-derivation; resolves `.dev` pair, `hmapTex`, reflection, glint constants |
| O3 | `docs/audit/WATER_PERF.md` | strategy A/E, perf gates, asset provenance |
| O4 | `docs/audit/WATER_PORT_FIX.md` | pixel measurements of port water; D1–D7, P1–P11 |
| O5 | `docs/audit/PIECES/shore_sand.md` | 8×45° sandsea table, band widths, donor DDS means |
| O6 | `docs/audit/PIECES/shore_rock.md` | rock tile means, cliff aspect/height overrides, rim criteria |
| O7 | `docs/audit/PIECES/shore_water_transition.md` | 3-band profile sandbox→water, donor plaintext anchors |
| O8 | `docs/audit/PIECES/water_shallow.md` | shallow palette, coast fade, ripple/glint constants |
| O9 | `docs/audit/PIECES/water_deep.md` | deep palette, alpha/depth behaviour, wave-sheet stats |
| O10 | `docs/audit/PIECES/water_glints.md` | glint constants, sun mapping, port speckle defect |
| O11 | `docs/audit/PIECES/verdict_shore.md`, `verdict_water.md` | renderer verdicts; real in-engine defects still open |
| O12 | `docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md` | donor→`water3d.gdshader` equation ledger, UNVERIFIED list |
| O13 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_03_water_weather.md` | D1–D30 donor water/weather, P1–P6 port state |
| O14 | `docs/coord_swarm_2026-11-25/TEST_MATRIX.md`, `reports/V3D_02_terrain_render_audit.md` | smallest-map ladder, T0–T4 piece criteria |

### 1.2 Donor files opened read-only this session

All paths are relative to `C:\Games\Cossacks 3\data\`:

| File | Used for |
|---|---|
| `water\water.lib` (71 lines) | active shader pair, texture scales, all descriptor literals |
| `water\water.mat` (106 lines) | `DiffuseWaves0/2` slots, commented `HeightMapWaves0`, filtering |
| `shaders\water\water.dev.frag` (262 lines) | **shipped** fragment: every constant/equation below |
| `shaders\water\water.dev.vert` (30 lines) | flat plane, height UV, surface Y, light transform |
| `shaders\water\water.frag` (255 lines), `*.bak`, `water.vert.bak` | inactive/debug contrast cases |
| `env\lights\light.cfg` (40 lines) | sun position/colours |
| `scripts\common.inc\texturemap.inc` (963 lines) | shore thresholds, 8-sector sandsea selection, cliff rock selection |
| `scripts\common.inc\generatemap.inc` (1,059 lines) | generation water height, near-water smoothing |
| `scripts\common.inc\dogenerate.inc` (2,103 lines) | second independent `-0.1` shore threshold |
| `scripts\common.inc\postprocess.inc` (466 lines) | water-mask border detection constants |
| `terrain\tiles\textures\*.dds` (Pillow) | shore/rock tile dimensions, means, std, alpha |
| `water\textures\*.bmp/.tga` (Pillow) | wave-sheet dimensions/stats, `heightmapwaves0.tga` alpha |

### 1.3 Three verification passes

1. **V1 — numbered text pass.** Helper
   `%LOCALAPPDATA%\Temp\opencode\_dtrn_read.py` did `open(path,'rb').read().decode('latin-1')
   .splitlines()` and printed 1-based numbered lines for every donor file cited. The
   active fragment was read end-to-end (262 lines) and again in overlapping windows.
2. **V2 — independent means pass.** `%LOCALAPPDATA%\Temp\opencode\_dtrn_grep.py`
   walked `data\scripts` with a regex for `cWaterHeight|cWaterShoreHeight|cBWater|
   sandsea|rock9|waterlevel|...`, and `_dtrn_img.py` used Pillow `Image.open` +
   `ImageStat` on the DDS/BMP/TGA files. This independently reproduced every
   threshold occurrence (§3.2) and proved the TGA alpha is constant.
3. **V3 — derivation/numeric pass.** `_dtrn_derive.py` recomputed `coastfade`,
   `coastfade2`, foam band and `waveheight` from the observed literals (§3.3); the
   port side was cross-checked by direct numbered reads of `water3d.gd`,
   `water3d.gdshader`, `world3d_terrain.gd` and `game.gd`.

Discrepancies between passes are called out in §7. Nothing was promoted to donor
truth on the strength of a prior report alone.

---

## 2. Claim table

| # | Claim | Evidence (donor `path:line` unless noted) | Method | Label | Caveat / correction |
|---|---|---|---|---|---|
| C01 | Shipped water shaders are `water.dev.vert` + `water.dev.frag` | `water\water.lib:67-68` | V1 read | **observed** | Literal binary load UNVERIFIED; no other selector found in prior grep (O2 §2.1) |
| C02 | Water geometry is a flat plane; no vertex displacement in the shipped pair | `water.dev.vert:14-18,29` | V1 read | **observed** | Legacy `.vert.bak:38-58` *does* displace by two sines but `WaveFreq/WaveAmp=0` (`water.lib:26-27`) disables it |
| C03 | Water surface height is the vertex world Y (`TexCoord[1].z`) | `water.dev.vert:18`; `water.dev.frag:167` | V1 read | **observed** | Actual Y value engine-supplied → **UNVERIFIED** |
| C04 | Shore thresholds are `-0.25` (water) and `-0.1` (wet shore), gated by mask-B | `texturemap.inc:29-31,463-472`; `dogenerate.inc:1576-1579` | V1+V2 read | **observed** | Script lines carry the GSC `;` prefix; runtime execution of that branch **UNVERIFIED** (O13 UNV-4) |
| C05 | Wet-shore band is `0.15` height units wide | arithmetic on C04 | V3 | **derived** | `-0.1 − (−0.25) = 0.15` |
| C06 | Shallow/deep are distinguished solely by `(level − height)` against `0.57` / `1.07` m | `water.dev.frag:37,168,198-199` | V1 read + V3 | **observed/derived** | No separate shallow/deep texture or tile flag in the shader |
| C07 | Final alpha is `coastfade2` (0 at waterline → 1 at 1.07 m) | `water.dev.frag:199,230,232` | V1 read + V3 | **observed/derived** | Port's `mix(0.35,1.0,…)` floor is wrong |
| C08 | Land above the instantaneous level is discarded (`vec4(0)`) | `water.dev.frag:176-183` | V1 read | **observed** | `level` includes a small animated perturbation (`:175`) |
| C09 | At the exact shoreline (depth 0) foam = 0 and colour = refracted terrain bed | `water.dev.frag:227,229` with `coastfade=0` | V1 + V3 | **derived** | No white rim exactly at the waterline |
| C10 | Procedural foam band peaks at depth ≈ `0.535 m`, zero at 0 and ≥1.07 m | `water.dev.frag:227`; V3 arithmetic | V3 | **derived** | `band=(d/0.57)(1−d/1.07)`; peak value ≈ 0.469 |
| C11 | Shallow/deep/spec colours are `(0.1,0.24,0.24)`, `(0,0.025,0.05)`, `(0.4,0.4,0.4)` | `water.dev.frag:45-47` | V1 read | **observed** | These are **linear pre-composite inputs**, not final pixel colours (`:200-226`) |
| C12 | Fresnel is declared in `water.lib` but commented out in the shipped fragment | `water.lib:21-24`; `water.dev.frag:8-16,203-206` | V1 read | **observed** | Live Fresnel exists only in inactive `.frag.bak:25-45`. Correctly not ported |
| C13 | Sun mapped to water is `(-0.08618, 0, 0.93870)` Z-up | `env\lights\light.cfg:26-30`; `water.dev.vert:22` | V1 + V3 | **derived** | Normalised ≈ 5.2° off +Z; no evidence of time-of-day override (O13 UNV-6) |
| C14 | Wave field = 3-octave fBm + crossing sine + 9-octave ridged loop, one 256² noise sheet | `water.dev.frag:83-104,65-68` | V1 read | **observed** | `m=mat2(0.72,−1.60,1.60,0.72)` at `:83` |
| C15 | Shifts are `(0.32t,0.24t)` and `(0.38t,−0.26t)` | `water.dev.frag:88-89` × `iglobaltime=time` (`:34`) | V1 + V3 | **derived** | Plus `pos += 0.01t` (`:187`) and level sample `uv*15 + 0.1t` (`:175`) |
| C16 | Large swell amplitude is proportional to `waveheight²`; `waveheight=clamp(WATER_LEVEL*3−1.5,0,1)` | `water.dev.frag:95,174-175` | V1 + V3 | **observed/derived** | **Zero for any surface Y ≤ 0.5**; only reaches 1 at Y ≥ 0.8333 |
| C17 | `waveMap` = `diffusewaves0.bmp`, 256², `tfLuminance`, mipmapped, `twBoth` | `water.mat:7-15`; `water.lib:44`; `water.dev.frag:65-68`; Pillow | V1+V2 | **observed** | Only sampler used for noise in the shipped fragment |
| C18 | `DiffuseWaves2` is live in the *normal-map slot* but has no sampler in the shipped fragment | `water.lib:43`; `water.mat:32-39`; `water.dev.frag:5-6,18,26` | V1 read | **observed/derived** | A 512² luminance BMP; not a true normal map |
| C19 | `heightmapwaves0.tga` is disabled and its alpha is constant 255 → cannot be `hmapTex` | `water.mat:86-106`; `water.lib:45`; Pillow `(255,255)` | V2 | **observed/derived** | Refutes the old "alpha carries height" inference (O5 C5, O2 §2.2) |
| C20 | `hmapTex` is the engine-supplied terrain height field, height in alpha, indexed by world pos/`hmapW` | `water.dev.frag:18-21,70-75`; `water.dev.vert:16-17`; `water.lib:60` | V1 + V2 | **derived** | The literal C++ sampler binding is **UNVERIFIED** (DECOMP-04 §8 evidence ids in O12 §1) |
| C21 | Reflection is a projected texture (`texture2DProj`) multiplied by `(R+G+B)*hdrMultiplier`, `hdrMultiplier=1` | `water.dev.frag:6,207-213`; `water.lib:25` | V1 read | **observed** | The cube map in `materials\ref\refcubemap.mat:24-33` is **not** bound to water (UNVERIFIED, inferred object reflection) |
| C22 | Foam is procedural (`nautic()` ×3 octaves `pow(1−f,5)`; `particles()` ×3 octaves `pow(f*0.35,7)*30`), no foam texture exists | `water.dev.frag:106-127,44,227`; `water\textures\` listing | V1 + V2 | **observed** | Both use `waveMap` at ×18 / ×200 |
| C23 | Live shore tiling paints oriented `sandsea1/5/6` on masked water **and** wet-shore cells | `texturemap.inc:463-472,474-511,525-528` | V1 + V2 | **observed** | Gate is `mask.b>0 AND (h<−0.25 OR h<−0.1)`; exactly 3 live tiles (2/3/4 only in comments) |
| C24 | The `rock9` (shore) / `sand1` / `sand2` replacement block is commented out | `texturemap.inc:934-954` | V1 read | **observed** | Do not treat `rock9` as an active shoreline tile; elsewhere it is forest-border decor (`loadenvironmentfrombitmap.inc:37-65`, `smoothforestborders.inc:135-136`) |
| C25 | Cliff rock selection is aspect-driven with height overrides `>2.7→rock8`, `>2.4→rock4`, `<0.1→none` | `texturemap.inc:559-609` | V1 read | **observed** | Donor cliff sector function is the **asymmetric 6-branch** form at `:559-575`, not the uniform 8×45° shore table |
| C26 | Generated terrain height under water = `−1.1 * mask_b * (1 + mask_r*3.5) + terrain_component`, then smoothed 3× near water | `generatemap.inc:7,567,574,621-637` | V1 read | **observed/derived** | Deep water scales with mask B and relief R; `−1.1` is a *generation* constant, distinct from `−0.25` |
| C27 | variant3d has a donor-equation water module, wired and height-aware | `water3d.gd:138-264`; `world3d_terrain.gd:528-545,762-764` | port V1 read | **observed (port)** | Integration landed (V7-92); old constant quad is fallback-only |
| C28 | variant3d `waveheight` is 0 because it feeds `-0.25` as the surface Y | `water3d.gd:19,231`; `water3d.gdshader:156` | port V1 + V3 | **derived (port)** | The donor's large swell term is therefore absent in the port |
| C29 | variant3d adds a `shore_prox` foam multiplier absent from the donor fragment | `water3d.gdshader:209-217` | port V1 read | **observed (port)** | Explicitly labelled PORT ART in the shader; ≈1 in practice |
| C30 | Water cells (`BLK_WATER=255`) are clamped to atlas tile 0 (`grass1`), so near-transparent water reveals grass | `game.gd:52`; `world3d_terrain.gd:697-702` | port V1 read | **observed/derived (port)** | Matching V3D-02 P6 "full-width dark rows" defect |
| C31 | variant3d paints sandsea only on the land-side strip `[-0.25,−0.1)` and keeps water cells as water | `game.gd:1055-1073,1774-1785` | port V1 read | **observed (port)** | Deliberate 2D-derived fix of an older defect; **diverges from donor C23** (which paints wet sand on water cells too) |
| C32 | 2D port has a near-verbatim water equation set but uses three sheets and `diffusewaves2` as foam source | `WATER_REPORT.md:253-282`; `WATER_PERF.md:22-34` (prior reads) | prior report | **observed (secondary)** | 2D is helper only; its calibrated colours are port art (O13 §4) |

---

## 3. Donor constants and formulas

### 3.1 Active pipeline and texture bindings (`observed`)

- `water.lib:67-68`: `water.dev.vert` / `water.dev.frag`. The non-`.dev` pair contains
  a debug `iMouse` control (`water.frag:12-15,183-187`) and a hard-coded
  `WATER_LEVEL=1.5` (`water.frag:182`, comment `0.94`) — a tuning build, not the shipped
  path. The `.bak` pair uses vertex sine displacement (`water.vert.bak:38-58`) but
  `WaveFreq=0`, `WaveAmp=0` (`water.lib:26-27`) disable it.
- `water.mat:7-15`: `diffusewaves0.bmp`, 256² RGB read as `tfLuminance`, `twBoth`,
  `MinFilter=miLinearMipmapLinear`, name `DiffuseWaves0`. Pillow: 256×256, mean ≈63.3,
  σ≈48, a dark cellular/caustic field. `water.dev.frag:65-68` samples it at `p/256`.
- `water.lib:43-44`: normal-map slot = `DiffuseWaves2` (512², Pillow mean ≈198.8, σ≈58.5,
  near-white dither), diffuse slot = `DiffuseWaves0`. The shipped fragment declares
  only `waveMap`, `reflectionMap`, `hmapTex`, `shadowMap` (`water.dev.frag:5-6,18,26`),
  so `DiffuseWaves2` is **not sampled** by the active shader (`derived`).
- `water.mat:86-106` / `water.lib:45`: `heightmapwaves0.tga` (Pillow 256² RGBA, R 111–220,
  G 167–255, B 58–178, **alpha constant 255**) is commented out. If bound raw as
  `hmapTex`, `height_map()` would return a constant `hmapMax` and every fragment would
  be discarded (`water.dev.frag:70-75,176-183`) — therefore it is not the height source
  (`derived`, refutes O5's old "alpha-height" inference).

### 3.2 Shore mask and transition width (`observed` + `derived`)

| Quantity | Value | Source |
|---|---|---|
| Water classification threshold | `cWaterHeight = −0.25` | `texturemap.inc:29-31,466-470`; `texturemap.inc:70-74` |
| Wet-shore classification threshold | `cWaterShoreHeight = −0.1` | `texturemap.inc:31,469-470`; independent `dogenerate.inc:1576-1579` |
| Mask gate | `gMapMask[ix,iy].b > 0` | `texturemap.inc:464` |
| Wet-sand band (height units) | **0.15** | `derived`: −0.1 − (−0.25) |
| Generation water constant | `cWaterHeight = −1.1` | `generatemap.inc:7` |
| Generated height under water | `−1.1 * fb * (1 + fr*3.5) + hterrain` | `generatemap.inc:567,574` |
| Near-water smoothing | 3 passes, radius 2, `SmoothTerrainCustom(...,0.35,...)` | `generatemap.inc:621-637` |
| Mask noise thresholds | `cIsWaterMin=0.1`, `cIsWaterMax=0.95`, `IsBorderBlackWater*` | `postprocess.inc:81-82,95-114,330-343` |

`derived`: the script-level shore band (0.15 height units) and the shader-level visual
fade (0.57 m / 1.07 m) are **two different widths**: the first selects which tileblock
is painted, the second controls per-pixel colour/alpha. Only the second is a distance
in metres in the fragment shader. `UNVERIFIED`: active runtime execution of the
comment-prefixed GSC lines (O13 UNV-4).

### 3.3 Shallow vs deep, alpha, and the exact shoreline (`observed` + `derived`)

Verbatim chain from `water.dev.frag`:

```
height = height_map(uv)                       :170     // hmapMin + .w*(hmapMax-hmapMin)  :70-75
WATER_LEVEL = gl_TexCoord[1].z                :167     // water-plane vertex Y
level = WATER_LEVEL + 0.2*water_map(uv*15 + 0.1*t, waveheight)  :175
if (height > level) { fragColor = vec4(0); return; }                        :176-183
coastfade  = clamp((level-height)/0.57, 0, 1)                               :198
coastfade2 = clamp((level-height)/1.07, 0, 1)  // 0.5+0.57                  :168,199
intensity  = dot(rescolor, (0.2126,0.7152,0.0722))                          :200
watercolor = mix(shallow*intensity, deep, smoothstep(0,1,coastfade2))        :201
rescolor   = mix(rescolor, watercolor, coastfade)                            :229
resalpha   = coastfade2                                                      :230
fragColor  = vec4(rescolor, resalpha*1.0)                                    :232
```

Numeric evaluation (V3, `derived` from `:37,:168,:198-199,:227,:229-230`):

| Depth `d = level−height` (m) | `coastfade` | `coastfade2` = alpha | foam band `cf*(1−cf2)` | rendered colour |
|---:|---:|---:|---:|---|
| 0.000 (exact waterline) | 0.000 | **0.000** | 0.000 | **bed only** (`terrain_map`/`CalcTerrain`) |
| 0.050 | 0.088 | 0.047 | 0.084 | 8.8 % water tint |
| 0.150 | 0.263 | 0.140 | 0.226 | 26 % water tint |
| 0.250 | 0.439 | 0.234 | 0.336 | 44 % water tint |
| 0.535 | 0.939 | 0.500 | **0.469 (peak)** | ~94 % water tint |
| 0.570 | 1.000 | 0.533 | 0.467 | full shallow colour mix |
| 1.000 | 1.000 | 0.935 | 0.065 | nearly deep |
| 1.070+ | 1.000 | **1.000** | 0.000 | full deep colour, opaque |

- **Shallow vs deep is a continuous depth ramp**, not two discrete states: `0.57 m` is
  where the water colour mix saturates; `1.07 m` is where alpha and the deep tint
  saturate. At `d=0.57`, `smoothstep(0,1,cf2)=0.549` — deep tint is only half applied
  there (`derived`).
- **Exact shoreline**: for `height > level` the fragment is discarded (`:176-183`); for
  `height == level` the fragment runs but `coastfade=coastfade2=0`, so the foam term
  (`× coastfade`) is zero, the water tint contribution (`mix(...,0)`) is zero and alpha
  is zero — i.e. the underlying terrain/bed shows through with **no white rim at the
  mathematical waterline** (`derived` from `:227,:229-230`). Foam appears only once the
  cell is submerged, peaking ~0.535 m in (`derived`).
- The water plane is drawn over the terrain; the discarded/transparent fragments
  reveal whatever the terrain mesh renders there. Donor bed colour is
  `vec3(0.175,0.1375,0.1) + waveMap(p*8).rgb*0.25` (`water.dev.frag:77-81`), with
  per-pixel terrain normal lighting `col *= grad + pow(grad,8)` and 3-tap PCF shadow
  (`:145-160,196`) — omitted in the port (§5).

### 3.4 Water colour, alpha, Fresnel and glints (`observed`)

| Constant | Value | Donor line | Role / state |
|---|---|---|---|
| `coast2water_fadedepth` | `0.57` | `:37` | shallow→full-colour distance |
| `deepwater_fadedepth` | `0.5+0.57 = 1.07` | `:168` | alpha / deep-tint distance |
| `watercolor` | `(0.1,0.24,0.24)` | `:45` | shallow **linear input**, multiplied by bed luma `:200` |
| `watercolor2` | `(0,0.025,0.05)` | `:46` | deep linear input |
| `water_specularcolor` | `(0.4,0.4,0.4)` | `:47` | neutral grey glint tint |
| `water_softlight_fact` | `170` (comment range 1..200) | `:42` | soft `pow(grad,170)` |
| `water_glossylight_fact` | `120` | `:43` | glossy `pow(grad,120)` |
| `particle_amount` | `30` | `:44` | foam sparkle gain |
| `large_waveheight / large_wavesize` | `0.50 / 2.0` | `:38-39` | crossing swell |
| `small_waveheight / small_wavesize` | `0.5 / 0.5` | `:40-41` | 9-octave ridged chop |
| `m` | `mat2(0.72,−1.60,1.60,0.72)` | `:83` | fBm rotation/scale |
| `normwater` | `normalize(vec3(h3−h4, h1−h2, 0.15))`, `dif=(0,0.01)` | `:186-192` | 4-tap wave normal, z=0.15 |
| `wavejitter` | `normwater.xy * 0.01 * (level−height)` | `:193-194` | depth-scaled refraction of bed and reflection UVs |
| `DeepColor/ShallowColor` (descriptor) | `(0,0,0.1255,0.5)` / `(0,0,0,0.5)` | `water.lib:9-20` | **not wired** — commented at `water.dev.frag:8-16` |
| `FresnelPower/Bias` | `1 / 1` | `water.lib:23-24` | **not wired** — commented at `water.dev.frag:12-13,203-206` |
| `ReflectionAmount/WaterAmount` | `1 / 1` | `water.lib:21-22` | **not wired** (`:10-11,211-212`) |
| `DistFactor/BumpFactor` | `1 / 1` | `water.lib:28-29` | **not wired** (`:15-16,203-206`) |
| `HDRMultiplier` | `1` | `water.lib:25`; `water.dev.frag:14,210` | live, applied to reflection |
| `TexScaleS/T` | `0.1 / 0.01` | `water.lib:32-33` | live noise scale / refraction strength |
| `Speed`, `WaveDir0/1`, `Offset` | `1.0`, `(−1,0)`, `(−0.7,0.7)`, `0.495` | `water.lib:34-49` | descriptor only; no live vertex-wave path |

Glint composite, verbatim (`water.dev.frag:215-226`):

```
r0 = vec3(uv, WATER_LEVEL); rd = normalize(light - r0)      // per-pixel ray  :215-216
grad = dot(normwater, rd)                                                     :217
specular  = pow(grad, 170);  specular2 = pow(grad, 120)                       :218-219
gradpos = dot(vec3(0,0,1), rd); specular1 = smoothstep(0,1,pow(gradpos,5))    :220-221
watershade = test_shadow(uv, level)          // 3-tap PCF, 1.0 when unshadowed :129-143,222
watercolor *= 2.2 + watershade                                                :223
watercolor += (.2+.8*watershade)*((grad-1.)*.5+specular)*.25                  :224
watercolor /= (1. + specular1*1.25)            // corona DARKENS               :225
watercolor += watershade*specular2*water_specularcolor                        :226
```

`derived`: brightest possible specular add ≈ `0.25 + 0.4 = 0.65` linear at one aligned
pixel; glints are grey, coherent (smooth 9-octave normal) and sun-position dependent,
not white 1-px speckles. **There is no `×8`/`×4`, no broad `pow(grad,24)` sheen, and
the corona divides rather than multiplies.**

Reflection (`water.dev.frag:207-213`): `refuv = gl_TexCoord[0].xyw` from
`gl_TextureMatrix[0]*pos` (`water.dev.vert:15`); `refuv.xy -= wavejitter*refuv.z`;
`refcol *= (r+g+b)*hdrMultiplier`; `watercolor += refcol`. It is a projected render
target (`inferred`, exact FBO binding **UNVERIFIED**), not the static cube map.

### 3.5 Animation / flow (`observed` + `derived`)

- `iglobaltime = time` (`water.dev.frag:34`); `speed=1.0` (`water.lib:42`).
- `shift1 = 0.001*(t*160*2, t*120*2) = (0.32t, 0.24t)` (`:88`);
  `shift2 = 0.001*(t*190*2, −t*130*2) = (0.38t, −0.26t)` (`:89`) — direction ratios
  **+4:3** and **−1.46:1** (`derived`).
- Level sample scrolls by `0.1t` (`:175`); normal-sample position by `0.01t` (`:187`).
- Foam octaves inject `iglobaltime*s` inside the noise (`:113,125`), so foam animates.
- Legacy vertex scroll was `time*0.02` (`water.vert.bak:57-58`) but that build is
  disabled by `WaveFreq/Amp=0`.
- Filtering: donor uses `miLinearMipmapLinear` (`water.mat:10`) — the port's converted
  PNGs have `mipmaps/generate=false` (`WATER_PERF.md:34`, prior read).

### 3.6 Water surface height vs terrain height (`observed` + `derived` + `UNVERIFIED`)

- Surface Y is supplied by geometry (`water.dev.vert:18` → `water.dev.frag:167`). The
  actual numeric Y is **UNVERIFIED**; `RayCastWater()` returns it at runtime
  (`scripts\lib\miscext.script:1515-1517`) but no plaintext assigns it. The inactive
  debug shader uses `1.5` with comment `0.94` (`water.frag:182`) — a hint, not proof.
- Terrain height comes from the engine height texture in **alpha**
  (`water.dev.frag:70-75`), indexed by world-coordinate/hmapW (`water.dev.vert:16-17`);
  `HeightMapEnable=True` (`water.lib:60`). The literal sampler binding is in the binary
  (DECOMP-04 §8.2 evidence ids, O12 §1) → **UNVERIFIED**.
- Consequence: the only comparison that decides wet/dry is the per-fragment
  `height > level` test (`:176-183`), with `level` perturbed by up to ±~0.1 m by the
  animated wave term (`:175`). The script thresholds `-0.25/-0.1` classify tiles for
  collision/painting; they are **not** the water plane Y.
- **Critical derived consequence**: `waveheight = clamp(WATER_LEVEL*3−1.5,0,1)` (`:174`)
  multiplies the large swell (`:95`). For any surface Y ≤ 0.5 the swell is exactly
  zero; it reaches 1 at Y ≥ 0.8333. Feeding the classification literal `-0.25` as the
  surface Y (as the port does) therefore silently deletes the donor's coarse swell.

### 3.7 Sand / rock shore texture selection (`observed`)

Active path in `texturemap.inc`:

1. Gate: `gMapMask.b>0 AND (height<−0.25 → bWater else height<−0.1 → bWaterShore)`
   (`:463-472`).
2. Orientation: neighbour heights `lh,rh,th,bh` (`:433-436`), `dirX=lh−rh`, `dirY=th−bh`
   (`:438-439`), normalise if `len>0.01` (`:441-444`), `vecangle = VectorAngle(1,0,0,dx,0,dy)`
   and **if `dirY<0` then `vecangle := −vecangle`** (`:445-447`), then `+180` (`:476`).
3. 8 uniform 45° sectors (`cAngle=45`, `:474,479-501`); final `else` is `bRT`.
4. Tile choice (`:503-511`): `bLB→sandsea5`, `bRB→sandsea6`, `bB→sandsea1`,
   `bL→sandsea6`, `bR→sandsea6`, `bT→sandsea1`, `bRT→sandsea5`, `bLT→sandsea6`.
   **Exactly three textures — `sandsea1/5/6`** (`derived`; 2/3/4 survive only as
   commented alternatives on the same lines). Winter appends `_winter` (`:525-528`).
5. The `rock9` (wet-shore) / `sand1` / `sand2` block at `:934-954` is **commented out**
   (`observed`), so `rock9` is not an active shoreline tile. Its other uses are forest
   border décor (`loadenvironmentfrombitmap.inc:37-65`, `smoothforestborders.inc:135-136`).

Rock/cliff path is a separate block (`:559-609`) with its **own asymmetric 6-branch
angle table** (`:559-575`), not the uniform shore table: `bLB→rock7` (`:578`),
`bB→rock1` (`:580`), `bL→rock3` (`:581`), `bR→rock4` (`:583`), `bT→rock4` (`:590`),
`bRB→rock4` (`:591`); `rock2`/`rock6` are commented (`:579,582`). Height overrides:
`|h|>2.7→rock8` (`:594-595`), `>2.4→rock4` (`:597-598`), `<0.1→no tile` (`:600-601`).

Pillow measurements (`observed`, 1024² RGBA, alpha 255 except where noted):

| Tile | Mean RGB | Hex | σ RGB | Role |
|---|---|---|---|---|
| `sandsea1` | (128.5,119.5,85.8) | `#807856` | (13.9,13.9,13.3) | active wet sand, bB/bT |
| `sandsea5` | (122.9,114.0,82.4) | `#7B7252` | (11.3,11.9,11.0) | active wet sand, bLB/bRT |
| `sandsea6` | (125.1,115.6,86.2) | `#7D7456` | (13.1,13.3,13.7) | active wet sand, 4 sectors |
| `sand3` | (122.7,116.7,87.3) | `#7B7557` | (15.5,14.4,13.0) | dry beach (not in live shore table) |
| `sand1/2` | 256², means (72.7,76.9,32.1)/(95.9,94.4,56.0) | — | — | commented shore replacement |
| `rock9` | (75.3,71.0,34.0) | `#4B4722` | (17.6,18.3,14.2) | commented shore / forest décor |
| `rock4` | (70.8,61.5,49.9) | `#463E32` | (16.6,14.9,12.4) | cliff + `>2.4` |
| `rock8` | (72.9,65.7,37.9) | `#494226` | (16.0,16.3,13.6) | high face `>2.7` |

`derived`: the sandsea tiles are near-uniform warm tan with no baked water band; the
"wet/wash" read comes from the water shader and the *placement* on submerged cells
(`texturemap.inc:463-472`), not from a dark strip inside the tile.

---

## 4. What exists / missing / wrong in variant3d (read-only comparison)

### 4.1 Exists and is donor-faithful

| Feature | Port evidence | Donor anchor |
|---|---|---|
| One flat water plane, 4 vertices, height-aware | `water3d.gd:181-204`; `world3d_terrain.gd:528-545,762-764` | `water.dev.vert:14-18,29` (flat plane) |
| Donor literals wired as uniforms | `water3d.gd:19-29,148-168` | `texturemap.inc:29-31`; `water.dev.frag:37,42-47,168`; `water.lib:25,32-33` |
| Wave/noise art is the correct donor sheet | `water3d.gd:77-81,172-177` binds `diffusewaves0.png` | `water.mat:7-15`; `water.lib:44`; `water.dev.frag:65-68` |
| `water_map()` 3+9 octave fBm, `m`, shifts, foam loops | `water3d.gdshader:79-131` | `water.dev.frag:83-127` |
| Per-pixel ray glints with 170/120, corona divisor, grey spec | `water3d.gdshader:191-207` | `water.dev.frag:215-226` |
| Depth tint/alpha `coastfade`/`coastfade2` | `water3d.gdshader:176-179,219-220` | `water.dev.frag:198-201,229-230` |
| Height grid fed into alpha channel of `height_tex` | `water3d.gd:248-264`; `world3d_terrain.gd:538` | `water.dev.frag:70-75` (height in `.w`) |
| Per-frame `time` | `water3d.gd:95-99` | `water.dev.frag:1,34` |
| Donor sun mapping | `water3d.gd:67-69`; `world3d_terrain.gd:100-101` | `light.cfg:26-30`; `water.dev.vert:22` |
| Fresnel deliberately absent | `water3d.gd:50-53`; shader header `:10-14` | commented in donor `:8-16,203-206` |
| `diffusewaves0` only wave sampler | `water3d.gdshader:41-43,65-67` | donor fragment has no other noise sampler |

### 4.2 Missing

1. **The donor's coarse swell is switched off in practice** (`water3d.gd:19,231`,
   `water3d.gdshader:156`): `WATER_LEVEL=-0.25` ⇒ `waveheight=0` ⇒ the `sin(...)*0.5*f*
   height²` term (`water.dev.frag:95`) contributes nothing. **derived**.
2. **Underwater bed lighting and shadow**: `CalcTerrain`'s 4 height taps,
   `col *= grad+pow(grad,8)`, and 3-tap PCF (`water.dev.frag:129-160,196`) are omitted;
   `terrain_map()` alone is used (`water3d.gdshader:133-139,175`). **observed**.
3. **Real `hmapTex` semantics**: `hmapMin/hmapMax = ±2.96` is a port approximation and
   `map_size.x/128` substitutes for engine `hmapW` (`water3d.gd:228-231`;
   `water3d.gdshader:69-75,164-166`). **observed / UNVERIFIED donor binding**.
4. **Reflection is disabled by default** (`water3d.gd:168`) and uses `SCREEN_UV +
   wavejitter` rather than a projected matrix (`water3d.gdshader:181-189`). Donor FBO
   binding is UNVERIFIED, so this is a declared port approximation, not a parity bug.
5. **Shadow on water** (`watershade=1`, `water3d.gdshader:201-203`) uses the donor's
   unshadowed branch — legitimate, but no donor shadow is reproduced.
6. **Donor LINEAR fog mode** (`:242-243`) is not ported; modes 2/3 are
   (`water3d.gdshader:222-230`), and fog is off by default (`colors.lib:36 FogMode=0`).
7. **Wet-sand tiling on water cells** (donor `texturemap.inc:463-472,503-511`) is not
   reproduced: variant3d keeps those cells as `BLK_WATER` and paints sandsea only on the
   land-side strip (`game.gd:1055-1073,1774-1785`). **observed divergence** (§4.3).
8. **No visual A/B parity evidence**: `water3d.gd:14-16`, `world3d_terrain.gd:57-58`
   explicitly make no parity claim; V3D-02 P15 confirms no pixel gate exists.

### 4.3 Wrong / likely causing the bad shore read

| # | Defect | Port evidence | Donor truth | Label |
|---|---|---|---|---|
| W1 | Classification threshold used as surface Y kills the swell and biases `level` downward (the 9-octave term is ≤0, so `level` typically sits **below** −0.25) | `water3d.gd:19,231`; `water3d.gdshader:156-157` | `water.dev.vert:18` surface Y; `:174-175` waveheight/swell | **derived (port)** |
| W2 | Water cells clamp to atlas id 0 (`grass1`), so near-transparent water and the exact waterline show **grass** instead of wet bed/sand | `game.gd:52`; `world3d_terrain.gd:697-702` | donor bed `(0.175,0.1375,0.1)+waveMap*0.25` (`:77-81`) and sandsea on masked cells (`texturemap.inc:463-472`) | **observed/derived**; matches V3D-02 P6 "full-width dark rows" |
| W3 | Extra `shore_prox` foam multiplier (≈1 but not donor) | `water3d.gdshader:209-217` | foam `× watershade*coastfade*(1−coastfade2)` only (`water.dev.frag:227`) | **observed (port art)** |
| W4 | `map_size.x/128` factor inflated on a 320-cell grid (×2.5); donor `hmapW` engine value UNVERIFIED | `water3d.gdshader:166`; `water3d.gd:166,261` | `water.dev.frag:187` `uv*15/texScaleS*(hmapW/128)` | **derived / UNVERIFIED** |
| W5 | Height grid quantised to 8-bit alpha over 5.92 m (≈0.023 m/step) → visible stair-steps in the 0.57 m fade | `water3d.gd:253-259` | donor `hmapTex.w` likely also 8-bit; exact precision UNVERIFIED | **derived / UNVERIFIED** |
| W6 | Near-shore alpha floor absent in 3D (good) but substrate wrong (W2); 2D port's `mix(0.35,1.0,…)` floor is the opposite error | `water3d.gdshader:220` vs 2D `water_overlay.gdshader:88` (O8) | `resalpha = coastfade2` (`water.dev.frag:230`) | **observed** |
| W7 | Shore tile ids reach the atlas, but the land-strip-only rule leaves the water side with no wet-sand tile | `game.gd:1055-1073,1774-1785`; `world3d_terrain.gd:697-702` | `texturemap.inc:463-472,503-511` | **derived divergence** |

**2D secondary check (helper only).** The 2D `app/shaders/water_overlay.gdshader`
contains a near-verbatim donor equation set but uses three independent sheets and
`diffusewaves2` as both `wave2` and foam source, plus invented `×8`/`×4` glints and a
`pow(grad,24)` sheen (`WATER_REPORT.md:253-282`; `WATER_PORT_FIX.md:99-131`). The
headless piece verdicts (`verdict_shore.md`, `verdict_water.md`) explicitly say those
PASSes are renderer depictions, not in-engine fixes. Do **not** import the 2D palette
constants (`SHALLOW_LIN`, `FOAM_GAIN`, …) into 3D as if they were donor.

---

## 5. Concrete fix recipe (ordered, small diffs, no donor copying)

All targets are variant3d files; this agent changed none of them. Keep one water
plane, keep the 2-chunk/piece discipline, and re-verify with the §6 gates.

1. **F1 — decouple surface Y from the classification literal** (`water3d.gd:19,148`,
   `water3d.gdshader:156`). Add a separate `water_surface_y` uniform, default `-0.25`
   (the only donor-readable literal), expose an A/B value from the inactive debug
   shader's `1.5`/`0.94` (`water.frag:182`) **labelled PORT APPROX / UNVERIFIED**. Keep
   `shore_height=-0.1` for classification. Acceptance: `waveheight` reads 0 with the
   donor literal (correct) and >0 in the A/B; the coarse swell visibly returns only in
   the labelled A/B, never presented as recovered donor truth.
2. **F2 — fix the underwater substrate before touching shader colours**
   (`game.gd:52`; `world3d_terrain.gd:697-702`). Do not clamp `BLK_WATER` to tile 0
   (`grass1`). Either (a) assign a wet-sand tileblock to masked water cells as the
   donor does (`texturemap.inc:463-472,503-511`), or (b) add an explicit donor-bed
   sampler/colour `vec3(0.175,0.1375,0.1)+waveMap(p*8)*0.25`
   (`water.dev.frag:77-81`) for water cells. This removes the grass-coloured rim that
   shows through alpha≈0 at the waterline. Prefer (a) for donor fidelity.
3. **F3 — remove the port-art foam multiplier** (`water3d.gdshader:209-217`): set foam
   to `watershade * coastfade * (1−coastfade2) * (vec3(.5,.6,.7)*nautic + particles)`
   verbatim (`water.dev.frag:227`). Verify foam = 0 at depth 0 and ≥1.07 m, peak at
   0.535 m (§3.3 table).
4. **F4 — keep the correct alpha** (`water3d.gdshader:220`): `ALPHA = coastfade2`, no
   0.35 floor (donor `:230`); never copy the 2D shader's floor.
5. **F5 — height-texture hygiene** (`water3d.gd:248-264`): preserve the alpha encode
   (`.a` ↔ donor `.w`); record `hmapMin/Max` and `map_size.x/128` as PORT
   APPROXIMATION in `stats`; if visible terracing appears in the 0.57 m band, consider
   a higher-precision or higher-resolution height texture as a labelled port choice,
   not a donor claim.
6. **F6 — shore/rock tile selection**: keep the uniform 8×45° shore table and `dirY<0`
   fold (`game.gd:1729-1737`) — it matches `texturemap.inc:474-511`. Keep the cliff
   function's **6-branch** table (`game.gd:1749-1772`) — it matches `texturemap.inc:559-609`;
   do not "fix" it to 8×45°. Add sandsea on the water-side masked cells (F2a) and
   confirm `sandsea1/5/6` all appear on the small map; leave `rock9` out of the active
   shore until the commented donor block (`texturemap.inc:934-954`) is proven active.
7. **F7 — reflection / shadow / fog stay as declared approximations**: keep
   `reflection_enabled=0`, `watershade=1`, modes 2/3 only, until the binary bindings
   (UNVERIFIED list §7) are proven. Do not bind `heightmapwaves0.tga` or `DiffuseWaves2`
   as `hmapTex`.
8. **F8 — perf/structure**: never add a second water plane (`world3d_terrain.gd:762-764`),
   no per-frame geometry or texture rebuild; `time` remains the only per-frame update
   (`water3d.gd:95-99`).

---

## 6. Shore-piece test criteria ("terrain + shore" on the smallest map)

Run the existing harness only: `variant3d/tests/fixtures/small_map_64.json` (64×64,
seed 20261113, `TEST_MATRIX.md:29-46`), `Screenshot3DViewport`, 1280×720, fixed camera,
capture after ~10 frames. No new harness, no trees/mines/FX/fog overlay, **one Godot at
a time** via `python variant3d\tools\godot_runner.py run --id <ticket>-t2 ...`.

### 6.1 Structural assertions (cheap, must all hold)

| # | Assertion | Source / anchor |
|---|---|---|
| S1 | Exactly **one** water plane named `WaterPlane`; `height_aware == true`; old constant quad not also present | `world3d_terrain.gd:528-545,762-764`; `TEST_MATRIX.md:42` |
| S2 | Donor literals read back: `water_level=-0.25`, `shore_height=-0.1`, `max_height=2.96`, `coast_fade=0.57`, `deep_fade=1.07`, `texScaleS/T=0.1/0.01` | `water3d.gd:19-29,214-222`; `V784` probe §7 |
| S3 | `wave_noise` bound to `diffusewaves0.png`; `height_tex` replaced by `bind_height_grid()`; no `heightmapwaves0` / `diffusewaves2` as height | `water3d.gd:77-81,172-179,248-264`; `water.mat:7-15,86-106` |
| S4 | Baseline mesh unchanged: 4,096 verts / 7,938 tris / 1 surface / 4,096 UV2; `atlas_grid=(16,8)`; `shadow_enabled=0` | `TEST_MATRIX.md:33-34`; `V3D_02` T0 |
| S5 | UV2 histogram contains at least one of `sandsea1/5/6` and **zero** water cells mapped to tile 0 after F2 | `texturemap.inc:503-511`; `world3d_terrain.gd:697-702` |

### 6.2 Donor-grounded pixel/depth metrics (measure, do not assert parity yet)

| # | Metric | Target from donor | How to measure |
|---|---|---|---|
| M1 | Alpha at the exact waterline | `resalpha = 0` when `height == level` (`water.dev.frag:230`) | Sample pixels where height grid ≈ level; mean alpha ≤ 0.02 |
| M2 | Alpha saturation depth | alpha = 1 at `d ≥ 1.07 m`; ≈0.5 at `d = 0.535 m` | Pair each water pixel with `d = level − height[]`; plot alpha vs d, fit slope; check half-alpha at 0.535±0.1 m |
| M3 | Colour fade depth | shallow tint fully mixed at `d = 0.57 m`; deep tint half-applied at `d=0.57` (`smoothstep` factor 0.549, V3) | Sample mean RGB in bands `d∈[0,0.2]`, `[0.5,0.6]`, `≥1.07`; shallow band measurably brighter/less blue than deep (Δ ≥ 20/255 in ≥1 channel) |
| M4 | Foam confinement | foam = 0 at `d=0` and `d≥1.07`; peak near `d≈0.535` (`water.dev.frag:227`) | A/B toggle `particle_amount=0`; count changed pixels per depth bin; 0 changes beyond 1.07 m |
| M5 | Grass-under-water artifact | **0** full-width dark/green rows; no water pixel showing `grass1` substrate | V3D-02 P6; compare T0 (terrain only) with T2 by region subtraction |
| M6 | Land not tinted | no water alpha where `height > level` (`water.dev.frag:176-183`) | discard coverage check: alpha≈0 for all cells with height grid > level+ε |
| M7 | Animation | two captures 1 s apart, camera fixed → non-zero water-only pixel delta; `time` advanced | `water3d.gd:95-99`; `TEST_MATRIX.md:42` |
| M8 | Shore tile variety | all three active tiles represented where the strip exists (`texturemap.inc:503-511`); 8×45° uniform sectors with `dirY<0` fold (`:445-447,474-501`) | UV2 histogram + synthetic height-gradient fixture if needed |
| M9 | No stacked surfaces / draw-call budget | exactly one water MeshInstance; total draw calls recorded | `TEST_MATRIX.md:42-44` |

**Gate:** every S1–S5 and M1–M9 must be recorded with a screenshot; M1–M4 are
**donor-derived numbers**, so a PASS here means "matches the donor's readable
equations", *not* visual parity. Per `TEST_MATRIX.md:56-60`, a second agent must
re-check the capture, and no parity claim is allowed until a fixed-camera donor A/B
exists (F0).

**Do not use as 3D gates:** `tests/t_shore_smoke.gd`, `t_water.gd`,
`tools/terrain_piece_render.py`, `app/tools/pieces/t6_*` — these are 2D `app/` tooling
(`TEST_MATRIX.md:48-51`). Their graded band / foam / 3-tile ideas are useful reference
art only.

---

## 7. Open questions / UNVERIFIED

1. **Exact water surface Y** (`water.dev.vert:18`): engine-supplied; only inactive
   debug hints (`water.frag:182` = 1.5, comment 0.94). Controls whether the donor swell
   exists (`water.dev.frag:174-175,95`). **UNVERIFIED**.
2. **`hmapTex` literal binding**: only a Delphi string assignment is proven in the
   binary (DECOMP-04 §8.2, evidence ids in O12 §1); functional conclusion (engine height
   in alpha) is `derived`. **UNVERIFIED** at binding level.
3. **`hmapMin/hmapMax` and `hmapW` values**: engine uniforms (`water.dev.frag:19-21`);
   port uses ±2.96 and `map_size.x/128`. Numeric descriptor defaults in the binary are
   not provable; `1.99999988` is an enable bitmask, not a shader float (O12 §6).
4. **`reflectionMap` FBO**: projected coordinate observed (`:207-213`), exact target
   (planar reflection vs screen copy) **UNVERIFIED**; cube map binding not proven.
5. **Active execution of the GSC script literals** `-0.25/-0.1` (comment-prefixed
   lines, `texturemap.inc:30-31,466-470`): text observed, runtime branch **UNVERIFIED**
   (O13 UNV-4), though `dogenerate.inc:1576-1579` independently repeats `-0.1`.
6. **Wet-sand on water cells at runtime**: donor script paints it (`texturemap.inc:
   463-472,503-511`), port deliberately does not (`game.gd:1055-1073`); whether the
   retail renderer also overlays a separate foam/sand band is **UNVERIFIED** (O1 Q6).
7. **`DiffuseWaves2` / `heightmapwaves0` actual use**: live normal-map slot but no
   sampler in shipped fragment; TGA has constant alpha. Any claim that shipped water
   samples them is contradicted by `water.dev.frag:5-6,18` (O13 UNV-9).
8. **Donor tile size in metres**: port `TILE_M=2.0` is port-only (G32 §3), so the
   screen-space width of the 0.57 m / 1.07 m fades cannot be fixed in pixels without a
   camera calibration. Use depth-space metrics M1–M4 first.
9. **2D palette conflict** (`#C3D1CA` clean shallow vs inherited contaminated
   `#696B65`): unresolved owner decision (O8 §1.1, O11 §2.1); do not seed 3D gates
   from either until a donor GPU capture exists.
10. **Foam appearance at native resolution**: all reference widths come from a
    512×288 JPEG (±25%); donor foam itself is procedural, so no exact band width in
    pixels is donor-provable.

---

## 8. Summary

- The donor shore/water transition is **one flat water plane + a per-pixel depth
  shader**, not a water tile collar: a flat quad (`water.dev.vert:14-18,29`), the
  terrain height read from an engine height texture in alpha (`water.dev.frag:70-75`),
  a per-fragment `height > level` discard (`:176-183`), and two depth fades —
  **0.57 m** for colour and **1.07 m** for alpha/deep tint (`:37,168,198-199,229-230`).
  The exact waterline is **transparent and foam-free**; foam peaks ~0.535 m in
  (`derived`).
- Sand/rock shore selection is script-side: masked water/wet cells (mask B > 0 and
  height < −0.25 / −0.1) get oriented `sandsea1/5/6` via an 8×45° height-gradient
  sector table (`texturemap.inc:463-472,474-511`); `rock9`/`sand1`/`sand2` are commented
  (`:934-954`); cliffs use a separate 6-branch table with `>2.7→rock8`, `>2.4→rock4`
  (`:559-609`).
- Glints are grey, sun-linked, coherent and weak (`pow(grad,170/120)`, corona divides,
  `(0.4,0.4,0.4)`, `:215-226`); Fresnel/DeepColor/ShallowColor descriptors are
  **commented out** in the shipped fragment; foam is procedural and confined to the
  coast band; `DiffuseWaves2` and `heightmapwaves0.tga` are not shipped water inputs.
- variant3d already has a structurally faithful port wired and height-aware
  (`water3d.gd:138-264`, `world3d_terrain.gd:528-545,762-764`). The concrete remaining
  faults are: surface Y = classification literal ⇒ swell zero (F1), water cells clamped
  to `grass1` beneath near-zero alpha (F2), an extra port-art foam multiplier (F3),
  and approximation labels that must not be mistaken for donor values (F4–F8).
- The immediate shore-piece work is F1+F2+F3, verified on the 64×64 fixture with the
  depth-space metrics §6 — **not** a whole-scene visual claim. Highest-risk unknowns
  (surface Y, `hmapTex` binding, reflection FBO) stay explicitly UNVERIFIED.

*End of DTRN-03. Read-only: no donor binary executed, no donor asset copied, no Godot
process started, no code/asset/config/test/git state modified.*
