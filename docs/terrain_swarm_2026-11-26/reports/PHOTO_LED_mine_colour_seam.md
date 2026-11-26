# PHOTO-LED — terrain colour seam around mines

Date: 2026-11-26  
Candidate-only measurement; donor parity **UNVERIFIED**.

## 1. Measurement from `cap_donor_240n.png`

| ROI | Box (x0,y0,x1,y1) | Mean RGB | Saturation |
|---|---|---:|---:|
| Mine disc | (430,330)-(530,410) | `[83.9, 85.0, 35.9]` | 0.590 |
| Mine halo | (390,300)-(570,440) | `[76.3, 78.4, 25.4]` | 0.686 |
| Global grass left | (0,450)-(300,700) | `[72.0, 74.4, 20.3]` | 0.727 |
| Global grass top | (0,40)-(600,200) | `[73.0, 75.7, 20.5]` | 0.731 |
| Field area | (1000,230)-(1280,450) | `[71.7, 71.9, 18.7]` | 0.757 |

Difference from global grass to mine disc is roughly **+12 R, +11 G, +16 B**; to mine halo **+4 R, +4 G, +5 B**. The donor video grass direction is approximately `[78,80,36]`, much closer to the mine disc than to global grass.

## 2. Interpretation

The mine props and their immediate ground are already visually acceptable; the seam is caused by the **terrain shader not sharing the prop light-rig calibration**. Scene props use the donor-derived colours with `AMBIENT_ENERGY=1.40`, `SUN_ENERGY=2.00`, shadows off; the terrain shader currently applies unscaled light colours directly. This is a port lighting-consistency seam, not a tile-art defect and not a reason to retint the mine.

Native evidence (`DEC_SMALL_light_products.md`) recovers material Ambient `0.15686`, Diffuse `0.78125`, and `sceneColor` via `glLightModelfv` but leaves the runtime sceneColor value `[U]`. Therefore this correction is explicitly labelled a **PORT consistency calibration**, not a recovered donor constant or parity claim.

## 3. Acceptance cue for the next capture

After the light-match change, re-measure the exact ROIs:

- global grass should move toward `[76–79, 78–81, 25–36]`;
- mine disc/halo should not become noticeably overbright or lose texture;
- saturation of global grass should fall from ~0.73 toward the donor direction ~0.56–0.60;
- no shadows, AO, noise or emissive fill may be introduced.

If the global grass overshoots the mine halo, revert the flag rather than adding another fudge.

No donor GPU A/B frame exists; all values are candidate-internal or direction-only.
