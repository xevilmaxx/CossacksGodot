# SEQ_CLOSE — 24-frame close-sequence analysis after neutral alpha (shorealpha2)

Date: 2026-11-26
Scope: READ-ONLY image-sequence analysis. No code/Godot/git. One report file only.
Donor parity UNVERIFIED throughout. Donor video frames are direction-only references.

## 1. Inputs

Candidate 64² close pan (deterministic smoothstep, x 79→91 sim-m at y=93, h=20 m,
pitch −32°, FOV 17.27°, zoom 2.9, seed 20261113 — identical in all three
`capture.json` files):

- `donor_64_shorealpha2/frame_0000.png` … `frame_0023.png` (24 frames, current)
- `donor_64_shorealpha/frame_0012.png` (v1 neutral-alpha intermediate)
- `donor_64_final/frame_0012.png` (pre-alpha baseline)
- `inbox/qa/captures/contact_close-shorealpha.png` — CAUTION: built from
  shorealpha (v1) frames 0/4/8/12/16/20/23, NOT from shorealpha2. It overstates
  the current edge artifact. Re-generate from shorealpha2 before any gate use.
- Prior reports: `PHOTO_LED_chevron_ab.md`, `DEC_SMALL_shore_rings.md`,
  `PHOTO_SEQUENCE_review.md`, `DONOR_VIDEO_analysis.md`.
- Donor direction frames: V1 `t_60` (field+mill), `t_300` (ridge),
  `t_1200` (mine+forest); V2 `t_300` (integrated mine), `t_600` (forest town).

Method: Pillow/NumPy on temp outputs only. ROIs on 1280×720 frames:
`interior = x[330,950] y[40,330]` (sand body), `edge = x[100,1180] y[380,540]`
(sand↔grass transition band), `grass = x[100,1180] y[580,710]` (clean grass).
`dark%` = luma<40 share; `blk8` = mean |Δ| of 8 px block means (blockiness);
`ac48` = horizontal autocorrelation at 48 px; `aniso` = diagonal/axial gradient
ratio. Motion-compensated stability via FFT phase-correlation shift + residual.

## 2. What neutral alpha changed (f12, same camera, same seed)

| ROI | final f12 | shorealpha (v1) f12 | shorealpha2 f12 |
|---|---|---|---|
| interior std / grad / dark% | 36.71 / 8.17 / 35.8% | 17.34 / 3.75 / 1.67% | 16.68 / 3.69 / 1.31% |
| interior ac24 / ac48 | 0.311 / 0.281 | 0.143 / 0.009 | 0.134 / 0.011 |
| interior blk8 | 14.20 | 9.58 | 9.43 |
| edge std / grad / dark% | 29.65 / 9.83 / 33.2% | 30.12 / 9.77 / 30.0% | 26.44 / 5.58 / 9.41% |
| edge ac48 / aniso / blk8 | 0.085 / 1.235 / 14.50 | 0.136 / 1.240 / 14.66 | 0.311 / 1.311 / 13.54 |
| grass (all three identical) | 9.53 / 1.63 / 1.65% | same | same |

Read:

1. **Interior nested chevrons are gone.** v1 already removed them (interior
   dark% 35.8→1.7); shorealpha2 holds the gain (1.3%) and halves the gradient
   again vs final. Interior ac48 ≈ 0.01 = no periodic repeat banding. This
   confirms the DEC_SMALL mechanism: the id-hash alpha modulation was the
   chevron amplifier, and neutralising it (plus keeping the donor-exact sector
   table) leaves flat sand photographs at uniform brightness.
2. **v1 fixed the interior only.** Edge dark% stayed at 30.0% in v1 ≈ final
   33.2%. shorealpha2 cuts it to 9.4% with gradient nearly halved (9.77→5.58).
   The v1→v2 delta therefore lives on the 87–90 transition ring, not in the
   93/97/98 body.
3. **Grass is untouched** (bit-identical metrics all three builds) — the alpha
   work did not leak outside the shore path. Good containment.

## 3. Remaining artifacts (exact frames / ROIs)

A. **Outer shore-edge thin stripes — present in all 24 shorealpha2 frames.**
   ROI `edge x[100,1180] y[380,540]`: parallel dark hairlines along the
   sand↔grass boundary, visually 1–3 px wide, cell-quantised stairsteps 1 cell
   tall. f12: std 26.44, grad 5.58, dark 9.41%, ac48 0.311, aniso 1.311 (highest
   anisotropy of any ROI — directional striping). Time series (fixed screen
   ROI, content drifts with pan): dark% f00 5.87 → f09–f14 peak 8.9–9.6 →
   f23 7.48; grad 3.89 → 5.6 → 4.93. Stripes never disappear; mid-pan frames
   9–14 show them worst because the edge band fills the frame. Per DEC_SMALL
   §6.2 these are the ids 87–90 (`sandrock1–4`) transition cells, whose origin
   remains [U] and which still receive id-hash alpha modulation + the
   `0.125·sin/cos` warp in `tile_rgb`.
B. **Blockiness on the edge ring.** blk8: edge 13.54 vs grass 5.68; interior
   9.43. Adjacent ring cells still get visibly different brightness steps
   (per-cell flat fills). Interior speckle at 9.43 is close to photographic
   sand grain + 8×8 subcell quantisation; the edge value is artifact.
C. **Trees: sparse, dark, unpinned layout change between builds.** 3–5 trees
   visible per frame (central pine, dead trunks, one leafy crown right). In a
   fixed screen ROI `x[1050,1280] y[0,200]`: final f00 dark 45.6% vs
   shorealpha/shorealpha2 f00 6.12% — same camera, same map seed. Prop layout
   or prop shading changed between the final and shorealpha builds (RNG stream
   or render path); cause [U]. Do NOT use tree ROIs for cross-build A/B until
   the prop seed is pinned. Within shorealpha2, shift-compensated tree tests
   favour ground-locked bases + normal crown parallax (comp mad < unshifted in
   both tests), consistent with PHOTO_SEQUENCE_review obs. 5; exact base-pixel
   tracks not pinned, so this stays a visual read, not a number.
D. **Stones: nothing to report.** No stones/rock clusters are visible in any
   of the 24 close frames — stone behavior, contact shadow and mine
   integration cannot be scored from this sequence (see §5 for donor
   direction).
E. **Flicker / stability: clean.** FFT shift on grass ROI is pure horizontal,
   dy=0 every tested pair, magnitudes 5/42/58 px matching the smoothstep
   profile (slow ends, fast mid-pan). Motion-compensated residual mad 0.10
   (f00→f01, f22→f23) to ~1.0 luma level (f11→f12, f12→f13) — world-locked,
   no shimmer, crawl, brightness pulse or LOD snap. Interior stat drift across
   frames (std 14.5–19.5) is world content entering the fixed screen ROI under
   the pan, not temporal noise. No motion aliasing from the atlas.

## 4. Direction-only comparison to donor close content

No donor GPU A/B frame exists; this is art-direction contrast, not parity.

- **Mill/field (V1 t_60, t_1200; V2 t_900):** donor shows closed golden/green
  parcels with readable crop rows, hard edges, windmill centred on parcel,
  stone paving and contact shadows. Candidate close scene has no field class
  at all — bare flat sand with photographic grain, no rows, no parcel edge,
  no structure. Gap is a missing content class, not a tuning delta.
- **Mine/stone (V1 t_1200; V2 t_300, t_600):** donor minehead sits inside a
  clustered rock outcrop on continuous grass; no geometric base. Candidate
  close scene contains no mine and no rock cluster, so integration cannot be
  compared here — but the wide2 plates (DONOR_VIDEO §3) remain the contrast
  case: pale circular/square bases vs donor's continuous ground.
- **Forest (V1 t_600; V2 t_600):** donor shows dense irregular mixed stands,
  individual lit/shaded canopies, glades, long shadows. Candidate shows
  isolated dark crowns/trunks on bare sand, no canopy modelling, no shadow
  side (consistent with REVIEW3 rank 8 sparsity call).
- **Relief (V1 t_300, t_2100):** multi-peak rocky ridge with shaded faces and
  forested fringe. Candidate close scene is flat (interior height range per
  PHOTO_LED §1 is only 0.82 units over 350 unique values) — no ridge content
  to compare; the former suspicion of "relief chevrons" in this scene is now
  resolved as tile-art chevrons (§2.1).

## 5. Five safest concrete tweaks, ranked (expected evidence each)

1. **Delete the `0.125·sin/cos` warp in `tile_rgb`** (`terrain_tileindex.gdshader`
   `:334`; keep donor-grounded `fract(v_st*0.5)` 2 m repeat + half-texel inset).
   No donor counterpart (`reftile.mat:29-37` is nearest/mipmap-linear).
   Expected: edge stripe edges straighten, edge grad falls toward ~4, stripe
   wobble gone; interior metrics and the 87–90/93/97/98 id histogram unchanged.
   Evidence: re-capture same pan, f12 edge ROI grad/ac48 + stripe-row count.
2. **Extend the 93/97/98 neutral-alpha bypass to ids 87–90** (compare
   `floor(abs(v_tile))` against manifest ids already resolved in GDScript; no
   new id invented): opaque donor base RGB on the transition ring, same rule
   as the shore body. Expected: edge dark% 9.4→~1–2%, edge std toward interior
   level; stripes collapse to flat sandrock photographs. Evidence: re-capture,
   f12 edge ROI dark%/std/grad; ids 87–90 histogram unchanged.
3. **Narrow the flat deep-water PORT-APPROX fallback** (`world3d_terrain.gd`
   `:1371-1379`): when the aspect guard returns empty (donor `len≤0.01`,
   `texturemap.inc:442`), keep a single `sandsea1` fill and never
   re-sectorise by neighbour gradients. No new literal. Expected: no new rings
   in deep interiors; interior ac48 stays ~0 across all 24 frames. Evidence:
   interior ROI ac24/ac48 time series + id histogram.
4. **Measure before touching topology:** after (1)+(2), re-capture and count
   residual stripe rows/widths in `edge x[100,1180] y[380,540]` per frame
   before considering vertex-sampled heights or diagonal-flip changes.
   Cell-centre triangulation is load-bearing geometry work; the two shader/
   bypass tweaks above are strictly safer and may leave nothing worth the
   risk. Expected: a stripe census table that either closes the item or scopes
   it with numbers.
5. **Change nothing for trees/props in this track.** Within-sequence props are
   ground-locked with normal parallax and zero flicker (§3.E); sparsity is a
   placement-scope item (REVIEW3 rank 8), and the final→shorealpha layout shift
   (§3.C) must be root-caused (pin prop RNG stream) before any prop A/B is
   meaningful. Expected evidence: none from this tweak — deliberately; file
   the prop-seed question to the placement owner instead.

No code edits made. No parity claim made. All frame paths, ROIs and numbers
above are candidate-internal diagnostics reproducible from `%TEMP%\opencode\
v42\video\donor_64_shorealpha2\` plus the two `frame_0012.png` baselines.
