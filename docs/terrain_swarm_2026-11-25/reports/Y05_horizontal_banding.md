---
id: Y05
ticket: "URGENT follow-up Y05 — horizontal light/dark banding in the post-Y03 real-map capture"
title: "Y05 — diagnosis of the screen-horizontal corrugation after Y03's single-tile detail pass"
agent: "Y05 (read-only analysis subagent)"
created: 2026-11-25
status: "APPLIED__Y05_IMPL_GRANT__ONE_LINE__NO_RUNNER__NO_GODOT__GATES_WITH_G04"
scope: "Exactly one new file — this report. No runner job, no Godot process, no .gd/.gdshader/asset/config/test/JSON/donor/git edit. Scratch PNGs and throwaway NumPy/Pillow/PowerShell arithmetic were written only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y05\\ (outside the repo). No donor file was opened for an attribution claim."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists (CHARTER §3/§5). All donor references are structural citations inherited from A01/A03/B01/Y03/Y04/Y06; every visual expectation here is internal consistency only."
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md
  - docs/terrain_swarm_2026-11-25/reports/B01_shader_impl.md
  - docs/terrain_swarm_2026-11-25/reports/Y03_detail_pass_fix.md
  - docs/terrain_swarm_2026-11-25/reports/A01_shader_tiling.md
  - docs/terrain_swarm_2026-11-25/reports/Y03_capture_log.md
  - docs/terrain_swarm_2026-11-25/reports/Y04_remaining_rings.md
  - docs/terrain_swarm_2026-11-25/reports/Y06_visual_verdict.md
  - docs/terrain_swarm_2026-11-25/reports/L02_chessboard_review.md
  - docs/terrain_swarm_2026-11-25/reports/B02_atlas_impl.md
  - "variant3d/shaders/terrain_tileindex.gdshader (complete relevant paths)"
  - "variant3d/scripts/game.gd:1959-2010, variant3d/scripts/world3d_terrain.gd:640-692, variant3d/scripts/tile_atlas_loader.gd:340-356"
  - "variant3d/assets/terrain/blocks/grass9.png, variant3d/assets/terrain/atlas/alpha.png (read-only pixel decodes)"
  - "IMAGES (after): C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y03\\realmap.png"
  - "IMAGES (before): ...\\l07c\\realmap.png, ...\\g04\\realmap.png, ...\\p0fresh01\\p0_final_formula.png"
---

# Y05 — horizontal banding after the Y03 single-tile detail pass

> **Labels:** **OBSERVED** = a literal source line, a decoded file byte, or a measurement
> made directly on the named image; **DERIVED** = an arithmetic/control-flow consequence of
> OBSERVED facts; **INFERRED** = attribution with a stated caveat; **UNVERIFIED** = cannot
> be proved with the available instruments. No Godot was run, no runner job was submitted,
> and no repository file but this report was written. **Donor parity stays UNVERIFIED.**

---

## 0. Mandate and short answer

COORD: the fresh post-Y03 frame
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03\realmap.png` shows long horizontal
light/dark bands across the open field. Rank the five named causes with code + pixel evidence
and give a minimal fix that keeps B01's anti-streak gains.

**Ranked verdict (detail in §5):**

1. **PRIMARY — (d) the 2 m verbatim atlas-cell repeat, now globally phase-coherent because
   Y03 collapsed every detail-pass id to one id (grass9).** Aliased through the shallow
   real-map camera into screen-horizontal lines. `terrain_tileindex.gdshader:214-218`, `:392`,
   `game.gd:2008`. This is A01 Rank 1 newly unmasked, not a new defect.
2. **STRONG CO-CAUSE — a candidate not on the ticket list: the alpha mask patch changed
   with the tile id.** Forcing id 8 also forces repacked alpha patch **(2,0)** on every
   detail cell — a dark, strongly structured patch (`alpha.png:1792-1855`, repacked by
   `world3d_terrain.gd:662-675`) — sampled on the **same** 2 m phase and folded into albedo at
   `terrain_tileindex.gdshader:417/:427`. This co-registers a second grating with the RGB one.
3. **(c) mipmap/anisotropy is a contributing condition, not the driver.** The mip chain and
   `filter_linear_mipmap` are present (`:60`, B02, `tile_index_atlas.png.import:26`); with the
   analytically predicted LOD (≈5.3) the field is smooth in simulation. Whether the GPU
   actually honours `textureGrad` at this camera is **UNVERIFIED** — no GPU A/B exists.
4. **(b) B01 continuous warp — RULED OUT as the driver.** Same-period simulation gives
   row/col std ratio **0.90 with warp ON vs 0.96 with warp OFF**; its world periods (≈48–90 m)
   cannot produce 2–35 px screen lines. It can only modulate the phase of Rank 1 secondarily.
5. **(a) grass9 anisotropy — RULED OUT.** A03 measured FFT-aniso 1.20; my direct profile
   gives row-std 1.44 < col-std 1.68 (no horizontal bias).
6. **(e) lighting/normals — RULED OUT for this frame.** Flat meadow → constant normals →
   constant `v_packed` (`:298-305`); the band ratio is hue-preserving/multiplicative.

**Minimal fix (§6):** one-line data change in `game.gd:2008` — force **test8 (idx 79)**
instead of grass9 (idx 8). test8 is an equally clean isotropic/seamless cell (A03 §4:
aniso 1.27, Sx 0.95, Sy 0.96) **whose alpha patch is the constant-1.0 no-op patch (0,0)**, so
the co-registered mask grating and the ~30 % mask darkening disappear while B01/B02's mips,
linear filtering, continuous warp, half-texel inset and `textureGrad` all stay untouched.
Verified as a pure data substitution with the same RNG/determinism invariants as Y03.
Port-level substitution; no donor parity claim.

---

## 1. Evidence index

| ID | Label | Evidence |
|---|---|---|
| E01 | OBSERVED | `y03/realmap.png` opened directly: 1280×720, fine screen-horizontal light/dark corrugation over most of the meadow; residual nested rings/checker patches as Y04/Y06 describe. |
| E02 | OBSERVED | `l07c/realmap.png`, `g04/realmap.png` opened directly: broad nested contour maze, **no** field-wide fine horizontal corrugation. Camera differs slightly from y03 (`Y03_capture_log.md:90-98`), so this is a comparative, not pixel-aligned, A/B. |
| E03 | OBSERVED | Row/col mean-luma profiles (Pillow/NumPy, whole frame): y03 row-std **7.004** vs col-std 3.639 (ratio **1.92**); l07c 4.324 vs 4.125 (1.05); g04 4.389 vs 4.060 (1.08). Clean open-field crop `(380,20)-(640,100)` in y03: row-std **10.24** vs col-std **1.55** — ratio **6.6**; same crop in l07c: 5.26 vs 3.63 — ratio 1.4. |
| E04 | OBSERVED | Micro crop `(500,30)-(540,60)`: rows alternate almost perfectly (luma 85/58/85/58…); detrended row-ACF lag1 = **−0.31**, lag2 = **−0.03**. The added large-scale cadence is measured by col-ACF peaks at **35, 71, 106 px** (≈35 px = one 2 m X cell at this camera) and row-ACF peaks at 14, 27, 32–34 px. Another clean crop `(850,0)-(1100,80)` gives col-ACF 34/68/102 px and row-ACF peaks at 2/4/6/8 px. |
| E05 | OBSERVED | Darkest vs lightest rows in y03 crop: mean RGB (63.9, 62.8, 18.6) vs (93.3, 91.7, 29.4) → light/dark ratio **(1.459, 1.459, 1.577)** — essentially a hue-preserving multiplicative factor of ≈1.46. l07c same crop: (81.6,76.0,34.6) vs (94.8,91.0,40.9), ratio ≈1.16–1.20. |
| E06 | OBSERVED | Y06's independent C01 run: y03 `tile_repeat 0.796493`, `tile_period_px 45`, `band_peak_deg 90`, `directional_gradient.coherence 0.311491` (≈2× the g04/l07c baseline `0.152/0.156`), `streak_angle_deg 176.12` (`Y06_visual_verdict.md:90-92,121-127,296-308`). In g04/l07c `band_peak_deg 0`, i.e. the dominant gradient direction **changed to horizontal** after Y03. |
| E07 | OBSERVED | `terrain_tileindex.gdshader:214-218` `uv_repeat=(0.5,0.5)`; `:311` world-XZ texgen; `:392` `tile_rgb(v_tile, fract(v_st*uv_repeat))`. One cell per 2 m, single global phase. |
| E08 | OBSERVED | `game.gd:1973-2010`: the detail pass touches every cell still on `grass1`; `:2008` (Y03 hunk) unconditionally sets `tex = _blk("grass9")` for all of them; the two `_tb_pick` draws at `:1989-1996` are retained (`Y03_detail_pass_fix.md §10.2/§10.3`). |
| E09 | OBSERVED | `world3d_terrain.gd:662-675` `_repack_mask_alpha()` sets the runtime mask **alpha = input R intensity**; `:690` binds it as `alpha_atlas`. The raw `alpha.png` A channel is uniformly 255, but the sampled `.a` is the repacked R, not that constant. |
| E10 | OBSERVED | Repacked mask-patch statistics (64×64, alpha=R/255): patch **(2,0)** = id 8's patch, mean **0.198**, std 0.338, row-std 0.200, col-std 0.188; patch **(0,0)** = constant **1.000**, std 0. Patch (2,0) is a dark soft-edge blob spanning 0→~0.49 with a systematic top-to-bottom gradient. |
| E11 | OBSERVED | `terrain_tileindex.gdshader:365-378` `alpha_patch_uv()` decomposition; id 8 → `(half*4+variant, row) = (2,0)`; id 79 → `(0,0)`. `world3d_terrain.gd:692` binds `atlas_grid=(16,8)` from the manifest (`tile_index_atlas.manifest.json atlas.grid=[16,8]`). |
| E12 | OBSERVED | `terrain_tileindex.gdshader:417` samples that patch with the **same** 2 m phase `fract(v_alpha_uv)`, `:419` applies A02-P4 compression, `:427` folds `a` into RGB with `mask_to_alpha=1.0` (`:235`). |
| E13 | OBSERVED | `terrain_tileindex.gdshader:334` `warp = 0.125*vec2(sin(dot(v_st,vec2(0.13,0.07))), cos(dot(v_st,vec2(0.09,0.11))))`; `:336` `uv = mix(inset,1-inset,fract(local_uv+warp))`; `:337` `textureGrad(...,dFdx(v_st*uv_repeat)/atlas_grid,dFdy(...))`; `:60` `filter_linear_mipmap`; B02 attaches a real chain (`tile_atlas_loader.gd:350-356`, `tile_index_atlas.png.import:26`). |
| E14 | OBSERVED | Direct pixel profile of `blocks/grass9.png`: row-mean std **1.443**, col-mean std **1.676**; 32-bin row profile ranges 70.98–76.18 — no authored horizontal banding. A03 §2 row: FFT-aniso **1.20 (0°)**, Sx 0.93, Sy 1.02, `ΔYy +0.78` — isotropic and seam-clean. |
| E15 | DERIVED | Numerical shader re-implementation (Pillow/NumPy, `y05_sim.py`, `y05_sim_full.py`) using the A01 camera model, grass9 art, repacked alpha, exact warp/inset/`textureGrad` LOD math: RGB-only row/col std ratio **0.90** (warp ON) vs **0.96** (warp OFF); with patch (2,0) mask ratio **1.12** (warp ON) / **1.31** (OFF); at analytic LOD ≈5.3 the field is smooth (row-std ≈1.2). No configuration produced the measured ratio 6.6 — see §7 for why this is not a disproof of Rank 1. |
| E16 | OBSERVED | `terrain_tileindex.gdshader:298-306`: `n` from mesh `NORMAL`, `v_packed=ambient+diffuse`; `game.gd` does not write NORMAL per frame and Y04 §2 records the meadow as flat/unshaded. |

---

## 2. What the pixels actually show

### 2.1 The artifact is horizontal, regular and new (OBSERVED)

Across clean meadow crops the row-mean profile varies **6.6× more** than the column-mean
profile (E03), so the energy is almost entirely in the vertical direction → screen-horizontal
lines. C01's independently computed `band_peak_deg 90` and
`directional_gradient.coherence 0.311` vs baseline `0.152` (E06) agree. In the pre-Y03 frames
the same statistic is ~1.0 or lower and `band_peak_deg 0` — the orientation itself changed.

### 2.2 Two superposed cadences (OBSERVED)

- a **2-row alternation** (luma 85↔58 in the micro crop, ACF lag1 −0.31, lag2 −0.03), and
- a **≈35 px cadence** (col-ACF peaks 35/71/106 px) that matches one 2 m world cell projected
  at this camera, with row-ACF peaks at the same scale (14/27/32–34 px).

The artifact is therefore **cell-locked**: it repeats at the 2 m grid cadence, with an
extra near-Nyquist (2 px) beat inside each cell. It is not an organic multi-scale field and
not a single camera-swimming streak.

### 2.3 The contrast is a multiplicative brightness factor (OBSERVED)

Light/dark RGB ratios are (1.459, 1.459, 1.577) (E05): R and G scale identically, B slightly
more. This is consistent with a scalar shading/mask factor multiplying the same albedo — not
with switching to a differently coloured atlas cell (which would shift hue differently) and
not with a directional light rotating (which would change the vector, not scale it uniformly).

---

## 3. Code trace — what Y03 actually changed relative to the banding

1. `game.gd:1973` — the detail pass only touches cells still on `grass1`.
2. `game.gd:1981` — reads a categorical tile id from `tile_lowground`/`tile_highground`.
3. `game.gd:1989-1996` — B03-P1 re-rolls test7/test8 (RNG draws retained by Y03).
4. `game.gd:2008` — **Y03: `tex = _blk("grass9")` for every touched cell.** This is the only
   executable delta of Y03 (`Y03_detail_pass_fix.md §10.2`), and the banding appears in the
   capture taken after it (`Y03_capture_log.md:37-51`). Before it, those cells carried a mix
   of ids from the detail bitmaps (Y01b §8: `{14,15,16,78,79,8,7,77}`), which broke the
   per-cell phase coherence of any single cell's repeat.
5. `terrain_tileindex.gdshader:392` — every such cell now samples **the same atlas cell 8**
   through the same `fract(v_st*0.5)` phase: a globally coherent 2 m grating (E07).
6. `terrain_tileindex.gdshader:417/:427` — the same id also selects **the same alpha patch
   (2,0)** on the same phase, co-registering a second, dark, gradient-bearing grating with
   the RGB one (E09–E12). Pre-Y03 the mix included ids whose patches are constant-1.0 no-ops
   (`test8`→(0,0), `grass_ground3`→(4,0)), so this second grating was spatially interrupted.

**DERIVED:** Y03 did not introduce a new artifact *ex nihilo*; it removed the tile-id variety
that was masking the pre-existing 2 m repeat (A01 Rank 1) and it simultaneously made the
alpha-patch modulation globally uniform. Both effects are direct consequences of one line.

---

## 4. Candidate-by-candidate verdict

### (a) grass9's own texture anisotropy — **RULED OUT** (OBSERVED)

A03 §2 measured FFT-aniso **1.20** for grass9 ("best: isotropic, seamless"); my independent
profile gives row-std 1.443 < col-std 1.676 (E14), i.e. no horizontal-energy excess. The
shader simulation with grass9 alone gives row/col ratio 0.90 (E15). An anisotropic texture
could not produce a 6.6:1 row/col contrast ratio.

### (b) B01's continuous sin/cos UV warp — **RULED OUT as driver; secondary phase modifier only** (DERIVED)

`warp.x = 0.125·sin(0.13X+0.07Z)`, `warp.y = 0.125·cos(0.09X+0.11Z)` (`:334`). Its world
periods are 2π/0.13 ≈ **48 m**, 2π/0.07 ≈ **90 m**, 2π/0.09 ≈ **70 m**, 2π/0.11 ≈ **57 m**
(B01 §5 item 1 already noted "≈48–90 m"). At the real-map camera that is hundreds of pixels,
not the measured 2–35 px cadence. The controlled simulation (E15) gives ratio **0.90 warp ON
vs 0.96 warp OFF** — the warp does *not* create horizontal banding and if anything very
slightly reduces it. The asymmetric x/y frequencies can only slowly modulate the phase of
Rank 1; they are not an independent source. **Keep the warp** — removing it would sacrifice
B01's anti-streak gain for no benefit.

### (c) mipmap / anisotropy at shallow camera — **CONTRIBUTING CONDITION, not cause** (DERIVED + UNVERIFIED)

`filter_linear_mipmap` (`:60`), a real generated chain (`tile_atlas_loader.gd:350-356`,
`tile_index_atlas.png.import:26`) and `textureGrad` with unwrapped derivatives (`:337`) are
all present. With the analytic footprint at the P0-like model camera (≈39–44 texels/pixel,
LOD ≈5.3, E15) the sampled field has row-std ≈1.2 — smooth. So a *correctly working*
minification path suppresses rather than creates the bands. Anisotropy is deliberately not
enabled (B02 §4, donor `tfIsotropic`), so at grazing angles the isotropic LOD is the larger
footprint — again blurring, not striping.

**UNVERIFIED and important:** the real-map capture camera (`Y03_capture_log.md:90`:
`camera_pos=(145.29,58,-87.39)`) is not the P0 model camera; the measured cell cadence is
≈35 px rather than the model's ≈59–74 px. Whether Godot 4.4 honours the explicit
`textureGrad` gradients through the `fract()` wrap at that pose (A06 §3.4's original concern),
and what LOD the hardware actually picks, cannot be determined without a GPU A/B. The
observed striping shows the residual alias is **not fully suppressed**, but the code alone
cannot prove whether the failure is in LOD selection, mip availability at capture time, or
the intrinsic near-Nyquist cadence of Rank 1.

### (d) the remaining 2 m cell repeat — **PRIMARY** (OBSERVED code + pixels; INFERRED causal share)

A01 Rank 1 established the world-XZ `fract(v_st*uv_repeat)` grating as the primary periodic
structure of this shader (`:214-218`, `:311`, `:392`). The measured ≈35 px cadence in y03 is
that grating (E04), and its row/col ratio jumped from ~1 to 6.6 exactly when Y03 removed the
tile-id mix that had been breaking its coherence (§3). Y04 §1.2 and Y06 R1/R2 independently
describe the new corrugation as consistent with an atlas repeat at a shallow camera while
correctly labelling the exact cause UNVERIFIED. The striping is **the 2 m repeat made
globally coherent by the single-tile detail pass, alias-sampled through the real-map camera**.

### A newly identified co-cause — the tile-id-coupled alpha patch — **STRONG** (OBSERVED + DERIVED)

This is not on the ticket's list but is a direct consequence of the same one-line change and
fits the pixel evidence better than any listed candidate alone:

- id 8 selects repacked patch (2,0) (E11), which is dark (mean 0.198) and has a systematic
  vertical gradient (row-std 0.200, E10) and edge steps 0→0.49.
- `:417` samples it on the *same* 2 m phase and `:427` folds it into albedo (E12).
- Pre-Y03 the mix included no-op patches (0,0)/(4,0) on a large share of detail cells, so the
  mask grating was interrupted; after Y03 it is uniform over the whole field.
- B01's contrast compression maps raw `a` to ≈0.675–0.745 for this patch (DERIVED from
  `:419`), a multiplicative factor whose max/min is ≈1.10 — too small by itself for the
  measured 1.46 ratio, but it supplies both the **per-cell vertical gradient** that reinforces
  the horizontal cadence and a field-wide darkening consistent with y03's lower mean luma
  (`Y06 §3`: 77.35 vs 83.83/83.86 in g04/l07c). Its exact captured-build value is
  **UNVERIFIED** (no post-Y03 dump, no GPU A/B).

### (e) lighting / normals — **RULED OUT for this frame** (OBSERVED + DERIVED)

`:298-306` derives `v_packed` from mesh `NORMAL`; the open meadow is flat (Y04 §2), so normals
are constant and `v_packed` cannot vary row-to-row. Y04 §2 already reached this conclusion.
Independently, the measured light/dark ratio is a near-uniform scalar 1.46 on R/G (E05), the
signature of a multiplicative albedo/mask factor, not of a changing light vector.

---

## 5. Ranked verdict

| Rank | Cause | Verdict | Decisive evidence | Kept/fixed by minimal fix? |
|---:|---|---|---|---|
| 1 | **(d) 2 m verbatim cell repeat, now globally coherent** | **PRIMARY** | E07/E08 code; E03/E04/E06 pixels (ratio 6.6, 35 px cadence, `band_peak_deg 90`); A01 Rank 1 | Not removed by §6 — requires the mip/phase work of §6 Part 2; warp/mips stay |
| 2 | **tile-id-coupled alpha patch (2,0)** | **STRONG CO-CAUSE** | E09–E12 code + decoded patch; E05 hue-preserving ratio; Y06 mean-luma drop | **Removed by §6** (id 79 → patch (0,0) no-op) |
| 3 | **(c) mip/aniso at shallow camera** | contributing condition; exact GPU LOD UNVERIFIED | E13/E15; B02; `Y03_capture_log.md:90` camera | Preserved and strengthened (verify, do not revert B01/B02) |
| 4 | **(b) B01 sin/cos warp** | **RULED OUT as driver** (secondary phase modifier) | E13; E15 ratio 0.90 ON vs 0.96 OFF; 48–90 m periods | **Kept** — it is an anti-streak gain |
| 5 | **(a) grass9 anisotropy** | **RULED OUT** | A03 §2 aniso 1.20; E14 rowstd < colstd | N/A |
| 6 | **(e) lighting/normals** | **RULED OUT for this frame** | E16; E05 scalar ratio; Y04 §2 | N/A |

**Overall (INFERRED, with caveat):** the field-wide horizontal corrugation is the **2 m
repeat made visible by Y03's single-tile collapse, with the tile-id-coupled alpha patch as a
co-registered amplifier**. Which of the two supplies the larger share of the measured 1.46
light/dark ratio is **UNVERIFIED** without a post-Y03 tile dump and a GPU A/B; the ranking
rests on code path + pixel cadence, not on a pixel-to-id mapping of this exact frame (the
camera is not pinned across captures — `Y03_capture_log.md:95-98`).

---

## 6. Minimal fix proposal — keeps the anti-streak gains

### 6.1 Part 1 (recommended, one line, highest confidence): neutralisation id 8 → 79

File `variant3d/scripts/game.gd`, Y03 hunk at **`:2008`**:

```diff
-			tex = _blk("grass9")
+			tex = _blk("test8")   # Y05 PORT APPROX: isotropic/seamless cell (A03 §4)
+			                      # whose alpha patch is the constant-1.0 no-op (0,0),
+			                      # so the 2 m mask grating stops co-registering with RGB.
```

Why this is minimal and safe (DERIVED from the applied hunk):

- **Art quality is preserved.** A03 §4 ranks test8 (idx 79) third-best: FFT-aniso 1.27,
  Sx 0.95, Sy 0.96, ΔYy +0.82, std 15.0 — the same isotropic, seam-clean class as grass9.
- **The co-cause is removed.** `alpha_patch_uv(79) = (0,0)` (E11) and patch (0,0) is constant
  1.0 (E10), so `:419` leaves `a = 1.0` and `:427` reduces to `rgb*1.0*v_packed+v_specular`
  on every neutralised meadow cell. The dark, vertically graded patch (2,0) is gone.
- **All anti-streak gains stay:** `:60` `filter_linear_mipmap`, B02's mip chain, `:334`
  continuous warp, `:335` half-texel inset, `:337` `textureGrad`, `:316/:417` fragment-stage
  wrap, the sentinel guard and P4 compression (now inert on these cells), all 31 uniforms and
  the `:478-502` A/B block are untouched. No lattice variant (L02 §4) and no synthetic
  dither/noise field (CHARTER §3 S-25-09) is introduced.
- **Invariants identical to Y03:** `_blk()` is a pure dictionary lookup, so the two `_tb_pick`
  draws at `:1989-1996` still consume the same `brng` draws in the same order;
  `_smooth_tilemap(brng,3)` (`:2125`) and `_stamp_forest_borders(brng)` (`:2330`) see the same
  stream; `terrain`/`height`/`blocked` are untouched; same seed → same bytes
  (`t_map_variety same_seed_byte_identical`). A frozen tileblock hash is not a valid gate.
- **Reversible:** a one-line edit back to `grass9`, with the same backup discipline
  (`inbox/backup/game.gd.bak-<TICKET>`) Y03 used.

Expected effect (INFERRED, not measured): the uniform 2 m mask grating and the field-wide
darkening are removed; the residual 2 m RGB repeat remains, so this alone may not clear R1.
It deliberately does **not** reintroduce height-following id variety (the Y01/Y03 maze).

### 6.2 Part 2 (only if R1 still fails after Part 1; A/B required, G04 owns the runner)

The remaining Rank-1 grating must be attacked at the phase/filter level, not by restoring a
per-cell lattice (forbidden by L02 §4) or a noise field (S-25-09):

1. **First verify the filter path**, not change it: capture with matched camera and check
   whether the ≈35 px cadence moves with camera/zoom. If it does not, the LOD/mip assumption
   in E15 is wrong and the fix belongs in `textureGrad` usage or B02's chain, not in tile data.
2. **If the grating is confirmed as the 2 m repeat**, the least invasive shader lever is
   A01 Option 2: decouple the mask phase from RGB at `:316`/`:417` (incommensurate scale +
   offset, PORT APPROX, no new sampler) — but after Part 1 the mask is a no-op, so the RGB
   phase itself must be decorrelated. Use the existing **continuous** warp as the vehicle
   (increase its amplitude modestly, keeping the same sin/cos form), never a
   `floor(v_st*uv_repeat)`-derived variant. Any such change needs a matched-camera A/B with
   `terrain_ab_metric.py` (`tile_repeat`, `coherence`) as movement indicators only.

**Do NOT:** re-enable the height-gradient `terrain=5` paint (`game.gd:1297-1310`), undo Y03's
neutralisation to bitmap ids, re-apply B04 face promotion, or reintroduce the B01 per-cell
mirror. All three are recorded regressions (Y03/Y04 §5.3, L02 §4, L03 §2).

---

## 7. Unknowns / UNVERIFIED register

1. **No post-Y03 tile dump.** The exact tile id at any banded pixel was not decoded; the
   id→patch attribution of §4 is a control-flow derivation from `game.gd:2008` plus the
   unchanged band geometry, not a measured histogram of this frame.
2. **Camera not pinned.** y03 `camera_pos=(145.29,58,-87.39)` vs l07c `(144.57,58,-88.11)`
   (`Y03_capture_log.md:90-98`), so the before/after comparison is direction-of-change only.
3. **GPU LOD / mip behaviour unverified.** E15 is a CPU re-implementation with a P0-like
   camera; it reproduced neither the measured 35 px cadence nor the 6.6 ratio at analytic
   LOD ≈5.3. It disproves (a) and (b) as *independent* sources under those assumptions but
   cannot prove what the GPU sampled at the real-map pose. No Godot run was performed.
4. **Exact captured-build shader state** (whether B01's P4 compression and B02's runtime mips
   were present at 16:04) is UNVERIFIED by this agent; G04's log says other writes during the
   run are COORD's concern (`Y03_capture_log.md:111-112`).
5. **Quantitative share** of Rank 1 vs the mask co-cause in the measured 1.46 light/dark
   ratio is INFERRED, not separated.
6. **Donor parity:** no donor GPU A/B frame exists. No donor image was opened for attribution
   in this ticket. Every visual judgement is internal consistency only.

---

## 8. Scope statement

Under this read-only Y05 ticket only this report was written. No runner job was submitted,
no Godot process launched, no queue/lock/counter mutated, no `.gd`/`.gdshader`/asset/config/
test/JSON/result/donor file edited. Temporary scratch PNGs and analysis scripts exist only
under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y05\`. The proposed §6 hunks are
**proposals only**, awaiting COORD's ownership grant and G04's runner. **No donor parity
claim is made.**

## 9. APPLIED — Y05-IMPL (COORD exclusive-ownership grant)

Status: **APPLIED**. Exactly **one line** of §6.1 Part 1 was applied at current
`variant3d/scripts/game.gd:2008`, inside `_apply_detail_pass()`. The §6.1 proposed two-line
comment was **not** added (the grant requires one line only), so the preceding Y03 comment
block is left verbatim as historical context. §6.2 Part 2 was **not** applied (it requires a
matched-camera A/B and G04's runner). No Godot process and no runner job were started.

### 9.1 Preconditions and backup (OBSERVED)

- Pre-edit `game.gd`: **256,611 bytes**, SHA-256
  `77DF5CE57E38A1B23A8EAD960895E8C01CA334DE3B2D807549A7B1468ACF11C3`. The tree already
  carried L01's spot pass and Y04's smoothing guards (166 insertions / 4 deletions vs HEAD);
  those were **not** touched.
- Backup created **before** the edit: `inbox/backup/game.gd.bak-Y05`, byte-identical to the
  pre-edit file (both 256,611 bytes, both SHA-256 `77DF5CE5…ACF11C3`). No existing backup was
  overwritten (`game.gd.bak-Y03`, `.bak-L01`, `.bak-B03*` all left intact).
- Post-edit `game.gd`: **256,610 bytes**, SHA-256
  `248160354F1762E97FD73E2CCE7879D947681DA8F27286FBA06964DCE5847CF2`. The one-byte shrink is
  `grass9` (6 chars) → `test8` (5 chars); no other byte changed.

### 9.2 Exact applied diff (verbatim `git diff --no-index <backup> <current>`)

```diff
diff --git "a/inbox\\backup\\game.gd.bak-Y05" "b/variant3d/scripts/game.gd"
index 5614673f..c183794d 100644
--- "a/inbox\\backup\\game.gd.bak-Y05"
+++ "b/variant3d/scripts/game.gd"
@@ -2005,7 +2005,7 @@ func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
 			# uses these ids for mottling; removing their variety is a port-level
 			# substitution, not donor parity (UNVERIFIED). L01's stamp-mask
 			# spots are the planned organic-variety follow-up.
-			tex = _blk("grass9")
+			tex = _blk("test8")
 			if tex >= 0 and tex < tbl_names.size():
 				tileblock[i] = tex
```

`git diff --no-index --numstat <backup> <current>` → **1 insertion, 1 deletion**. No other
repo file was changed by this implementation step.

### 9.3 Static sanity (DERIVED from the one-line diff)

- `test8` resolves to **idx 79** in `variant3d/assets/terrain/structs/presets_summer.json`
  (124 names, `test8` at index 79 — OBSERVED); `79 < tbl_names.size()` so the existing guard at
  `:2009` passes. `grass9` idx 8 → `test8` idx 79 is a valid in-atlas substitution (A03 §2/§4:
  test8 aniso 1.27, Sx 0.95, Sy 0.96, ΔYy +0.82 — same isotropic/seamless class as grass9).
- Its repacked alpha patch is **(0,0), constant 1.0** (E10/E11), so the co-registered dark
  mask grating of patch (2,0) is removed on every neutralised detail cell; `:427` reduces to
  `rgb * v_packed + v_specular` there (the sentinel guard and P4 compression stay in source,
  now inert on those cells).
- **No new token of any kind:** no `_hash2`, noise, dither, gain or luminance field; no new
  uniform, no new RNG draw, no new id outside the 124-name table. Bracket/quote balance
  unchanged (one string literal swapped).

### 9.4 Invariants (all verified OBSERVED after the edit)

| Invariant | Status | Evidence |
|---|---|---|
| RNG stream | **byte-identical** | `_tb_pick(2,5,brng)` at `:1990` and `_tb_pick(1,4,brng)` at `:1994` unchanged in value/order; `_blk()` is a pure dictionary lookup and draws no RNG. `brng` entering `_smooth_tilemap(brng,3)` and `_stamp_grass_spots(brng)` is bit-identical for a given seed. |
| Determinism | preserved | Same seed → same `brng` → same bytes; `t_map_variety same_seed_byte_identical` holds by construction. A frozen tileblock hash is not a valid gate (B03 R1 / TRN-DATA precedent); tileblock bytes are *expected* to change. |
| Y03 neutralisation structure | intact | `:1973` grass1-only eligibility, `:1981` bitmap read, `:1989-1996` P1 re-rolls and `:2009-2010` guarded write all unchanged; only the written id changed. |
| L01 spot pass | **untouched** | `_stamp_grass_spots(brng)` call at `:2130` and function at `:2359` verbatim; its `base_ids` at `:2365` already includes both `grass9` and `test8`, so it is agnostic to this swap. |
| Y04 smoothing guards | **untouched** | Four `!= _blk("grass9")` guards at `:2315/:2319/:2323/:2327` verbatim; they still target grass9 cells and are not widened or weakened. |
| B03 terrain=5 removal | intact | Grep over `game.gd` finds exactly one `terrain[…] = 5` write — the stone-quarry disc at `:852` (as Y04 §2 records); no gradient paint restored. |
| `tileblock` contract | intact | `PackedByteArray`, uint8 id 79 valid in the 124-name table; range guard at `:2009` unchanged; the pass still writes only cells whose current id is `grass1` (`:1973`), so `BLK_WATER=255` is never touched here. |
| `height` / `terrain` / `blocked` | untouched | No write added or removed in any of them; collision, start protection and walkability are byte-identical. |
| Shader / atlas / mesh / tests / config / `app/` / donor | untouched | One executable line in one file. All B01/B02 anti-streak gains (`filter_linear_mipmap`, mip chain, continuous warp, half-texel inset, `textureGrad`, A06 fragment wrap) remain in force. |
| Guardrails | honoured | No threshold lowered, no assertion deleted, no `expected_pre_fix_failure` flipped, no synthetic field, no donor-parity claim. **PORT APPROXIMATION.** |

### 9.5 Gate list for G04 (Y05 runs none — one Godot at a time)

Run on the post-Y05 tree with unique ids; no threshold or assertion may change:

1. `variant3d` selftest — expect **29/29**.
2. `variant3d` uitest — expect **17/17**.
3. `t_render_mode` — green.
4. `t_map_variety` — **5/5**, including `same_seed_byte_identical` (two runs of the same seed
   must match; a frozen tileblock hash must **not** be used).
5. `assert_clean` — **CLEAN**; 2D `app/` gates untouched and green.
6. `script_error_lines == 0`, `non_black_fraction == 1.0`, `full_width_dark_rows == 0`.
7. Matched-camera windowed seed-20261113 **real-map** capture with a unique id; C04/G05 R1–R6
   read. Primary check: `directional_gradient.coherence`, `band_peak_deg`, `tile_repeat` and
   row/col mean-luma ratio versus the Y03 frame — **movement indicators only**, not thresholds
   or parity claims. Expect the tile-id-coupled mask darkening/corrugation to fall; the
   residual 2 m RGB repeat (Y05 Rank 1) may remain and is §6.2 territory, not a gate failure.
8. Optional decisive probe (Y01b §8.5 / Y03 §10.4 recipe, new unique id): `--dump-map`, decode
   `tileblock`, confirm the neutralised meadow id is 79 (`test8`) and that no out-of-atlas id,
   `terrain=5` regression or `blocked[]` delta appeared.

### 9.6 Rollback

```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y05' -Destination 'variant3d\scripts\game.gd' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y05' -Algorithm SHA256
```

Both hashes must return to `77DF5CE57E38A1B23A8EAD960895E8C01CA334DE3B2D807549A7B1468ACF11C3`
(256,611 bytes). No other file needs rolling back.

### 9.7 Epistemic status

No Godot process, no runner job, no queue/lock/counter mutation, no donor file read or copied,
and no other source edit occurred in this implementation step. Whether the horizontal banding
actually decreases in the rendered frame is **UNVERIFIED** until G04's matched-camera capture
and the second-agent visual read; no donor parity claim is made (CHARTER §3/§5).

---

*End of Y05 — one line applied under grant; no runner, no donor-parity claim.*
