# 05 — Water and shore (from D06 + F06 + A02)

Source: `reports/D06_water_shore.md` (431 lines, 22-pass multi-method ledger),
`reports/F06_alpha_masks.md`, `reports/A02_algorithm.md`. **No donor parity claim.**

## 1. Three distinct water levels [O] — must not be conflated

| Constant | Value | Donor source | Role |
|---|---:|---|---|
| `cWaterHeight` (generation) | **−1.1** | `generatemap.inc:7` | basin depth, *not* plane Y |
| `cOffsetY` (water field) | **−0.5** | `generatemap.inc:688,704` | newly recovered; Y passed to `WaterFieldAdd` per 2×2 field |
| `cWaterHeight` (tile classify) | **−0.25** | `texturemap.inc:29-30,466-467` | cell → `bWater` |
| `cWaterShoreHeight` | **−0.1** | `texturemap.inc:31,463-472` | shore band |

The shader compares per-pixel terrain height to an engine plane Y plus animated
perturbation (`water.dev.frag:167,170-176`). Runtime execution of the
`−0.5` constant is `[U]` (comment-prefixed GSC text).

## 2. Shoreline height smoothing — exact 3-pass chain [O]

`generatemap.inc:580-643` (+ helper `:218-245`):
1. `SmoothTerrain(..., radius 3)` on mask `bsmooth` cells;
2. one whole-map `_misc_SmoothTerrainCustom(power=4, lerp=0.5, h∈[0.01,100])`;
3. **3 passes** of `power=0.35, lerp=0.5, h∈[−100,−0.01]` on any cell whose
   5×5 neighbourhood (radius 2) contains water.

Coastal smoothing is gated by **mask B + height band** (C4), not a height-only
threshold — the port's `mapgen.gd:179-196` is wrong (A02 E10).

Tile smoothing is a separate 3-pass horizontal/vertical sweep
(`smoothtiles.inc:191-237`) despite `globalparams.cfg:9` advertising 6 —
**preserved contradiction**, skirmish follows the script (F03/D06).

## 3. `hmapTex` is a parameter key, NOT a texture [O] — D06 §4

Deep Ghidra decompiled `FUN_00853ad4` at VA `0x853ad4` (file `0x453ad4`):
30 string keys assigned into `[obj+0x04…+0x78]`, `hmapTex` at `+0x54`,
`hmapW +0x58`, `hmapH +0x5C`, `hmapMin +0x60`, `hmapMax +0x64`, global f32
`1.99999988` into `+0x7c`. **No texture lookup / sampler / GPU bind.**
Shader uses `hmapTex.w` only for per-pixel depth test (`water.dev.frag:70-75,
170,176-199`); `heightmapwaves0.tga` has alpha 255 on all 65,536 pixels and is
commented out (`water.mat:86-106`) — it cannot be `hmapTex`. Built-in discovery
and xrefs failed at this region; 22 passes recorded with accept/reject reasons.

## 4. Shore / cliff tile selection [O]

- Shore tiles are **`sandsea1/5/6` only**, selected by an 8×45° height-gradient
  sector table on cells with `mask.b>0 ∧ (h<−0.25 ∨ h<−0.1)`
  (`texturemap.inc:463-528`). Smoothing weights `sandsea5=0.7`, `sandsea6=0.3`,
  `rock9/rock8/rock5=0.0` (`tilesmooth_scripts.cfg:5-66`).
- Cliff path is a different asymmetric 6-branch table: `|h|>2.7→rock8`,
  `>2.4→rock4`, `<0.1→none` (`texturemap.inc:559-609`); `cDiff1/cDiff2=0.5/0.55`
  (`:63-64`). These are **art gates**, not a height substitute — do not force
  them (P06 rejected approaches).

## 5. Shader constants [O] — re-read verbatim

Coast fade 0.57, deep fade 1.07, exponents 170/120, particle 30, colours
`(0.1,0.24,0.24)` / `(0,0.025,0.05)` / `(0.4,0.4,0.4)`,
`m=mat2(0.72,−1.60,1.60,0.72)`, shifts `(0.32t,0.24t)` / `(0.38t,−0.26t)`,
foam peak 0.535 m. Fresnel and DeepColor/ShallowColor are **commented out** in
the shipped fragment; `shaders.lib` has zero water/fresnel/current/glint
matches (water shaders load directly via `water.lib:67-68`). No river-current
grid or brush glint mechanic in the shipped skirmish path.

## 6. Bridges [O]

Explicit objects + collision painting, not a terrain tile class:
`_misc_CreateBridge` (`misc.script:5271-5346`) uses `cScale=1.15`,
`cBaseHeightOffset=0.4876`, block width `2.81*scale`, end widths `1.78*scale`,
offsets `1.07*scale`, collision radius 3, step 2, tag 10; water-border collision
radius `gc_WaterBorderSize=3` (`dmscript.global:819`). `fordtyp` is a **squad
formation-type field**, not a terrain ford — no ford-generation rule found `[U]`.

## 7. Alpha / transparency [O] — F06

Donor fragment does no mask math: RGB from `texUnit0`, mask intensity → `a`
from `texUnit1` (`hf.pvl.smx3.frag:13-17,50`); blend is fixed-function
`bmTransparency` (enum 1, `cossacks.exe:949234`); factors/pass count `[U]`.
`alpha.bmp` is 8×4 patches of 64²; `alphavert.bmp` is an eye-linear cliff
projection (`TextureScale=0.125`, `reftile.mat:120-169`); `alphanull` binds ids
86/110/123. See spec §06 §5.

## 8. Cross-check

X11 (Godot translation spec), F06 (alpha), C4 mask-gate (A02),
`variant3d/shaders/water3d.gdshader` comparison.

---
*Integrated by COORD from D06 + F06 + A02.*
