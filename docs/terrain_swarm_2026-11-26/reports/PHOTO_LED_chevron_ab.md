# PHOTO-LED — close-frame chevron root-cause A/B

Date: 2026-11-26  
Scope: candidate captures only; donor parity **UNVERIFIED**.

## 1. Inputs and observations

| Image | Observation |
|---|---|
| `video/donor_64_final/frame_0012.png` | Large nested diagonal chevrons/stairsteps cover the relief/shore area; clean grass outside is textured. |
| `video/donor_64_facegate/frame_0012.png` | Same chevrons after gating face promotion on collision tags. Telemetry `face_hist={0:4096,1:0,2:0}` — gate worked. |
| `video/donor_64_nosub/frame_0012.png` | Same chevrons after forcing `donor_rows=1`, `donor_cols=1` — 8×8 subcell selection is not the generator. |
| `diag/tileblock.raw` at 64² | 3,585/4,096 tile 0; remaining 511 cells are ids 87,88,89,90,93,97,98 — all shore/sandsea families. |
| `diag/height.raw` at 64² | 350 unique heights, range `[-0.59597, +0.22404]`; no two-valued cliff field here. |
| `diag/tile_id_map.png` / `heightmap.png` | Four discrete water/shore spots; no large two-valued plateau. |

## 2. Rejected hypotheses

1. **Face-mode promotion — rejected.** After the donor collision gate, all 4,096 cells are face 0 and the chevrons are visually unchanged.
2. **8×8 subcell selection — rejected.** Forcing the selector to 1×1 leaves the same nested bands and only changes fine blockiness.
3. **Two-valued relief geometry — rejected for this frame.** The close diagnostic has 350 unique heights and a small range; the chevrons correlate instead with shore-family tile ids.

## 3. Supported hypothesis

The chevrons are **shore tile art and its UV/alpha projection** around water bodies. Donor tiles 87–98 are sandsea families selected by the active 8×45° sector rule in `texturemap.inc:433-530`; the port's packed-atlas cells, stub alpha rule and cell-centre triangulation turn those rings into repeated nested stripes. This is a tile/UV problem, not a cliff-face problem.

## 4. Quantified photo metrics

| ROI / image | mean luma std | gradient | autocorrelation 24/48 | anisotropy |
|---|---:|---:|---:|---:|
| close final f12 full | 14.27 | 3.63 | 0.559 / 0.445 | 0.954 |
| V1 ridge 300 s (direction only) | 13.75 | 2.68 | 0.387 / 0.345 | 0.367 |
| V2 mine 1200 s (direction only) | 25.72 | 9.18 | 0.288 / 0.254 | 0.175 |

The candidate anisotropy is roughly 2.6–5.4× the donor reference values. Donor video frames are direction references only; no donor GPU A/B frame exists.

## 5. Next work

- Small decomp: recover the exact shore-sector → tile-id and UV/alpha behavior around water.
- Hard fix: adjust the port shore tile/UV path with donor-grounded rules; no synthetic smoothing or tint.
- Re-capture the same close camera after each change and compare these exact ROIs.

No parity claim.
