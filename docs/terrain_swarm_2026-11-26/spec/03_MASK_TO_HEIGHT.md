# 03 — Mask → height (from F04 + A02/X03; D03/X19 pending)

**PORT APPROXIMATION on port substitutes; no donor parity claim.** F04 read all
4,466 masks read-only; X19 is auditing the port decoder; D03 (binary mask
pipeline) has not landed.

## 1. Donor mask truth (F04) [O]

- **4,466 masks in 3 trees**; all RLE truecolour 24-bit TGA, no alpha.
  Vanilla `_gauss` masks are 320² bottom-left origin; `.src` masks are 256²
  top-left origin.
- In **all 1,331 vanilla masks**, R and G are **0 on every non-start pixel**; the
  only 255 values are **5,125 single-pixel white starts**. B spans all 256 values.
- **B really encodes negative height:**
  `h = −1.1 * B / 255` (B=0 → 0 m; B=255 → −1.1 m; water at B≥58).
  Masks alone **cannot** yield ±2.964 m — relief amplitude comes from stamped
  `.pattern` grids (spec §04), not from the mask.
- All **56 port PNGs are pixel-identical** to donor masks (F04 E).
  Start spacing ≈0.20–0.27 of map width; six duplicate-start masks.

**Authoritative skirmish statement [O]:** across all 1,331 shipped vanilla `_gauss` masks (independently re-verified by X18 and X19), R and G are **0 on every non-start pixel**; the only 255 values are 5,125 single-pixel white starts (R=G=B=255). B is the only continuous channel and `h = −1.1·B/255` (B=0→0 m, B=255→−1.1 m; water `h<−0.25` ⇔ integer **B≥58**, shore `h<−0.1` ⇔ B≥24; `generatemap.inc:4-7,567-574`, `texturemap.inc:29-31`). Mask pixels alone cannot yield ±2.964 m — relief amplitude comes from pattern stamps (spec §04, D05), not mask R; forest/stone comes from placement (spec §07/§08), not mask G.

The R→class / G→forest-stone code table at `generatemap.inc:21-32,454-485` is **authored donor intent `[O]` text**, inert on all shipped final masks (the second-pass sampler even leaves `.g` unassigned at `generatemap.inc:545`). Keep the R/G enum decode as schema intent, preserve raw R unchanged with an `ENGINE/UNVERIFIED` label, and **never map R→height for shipped masks**. What stays `[U]`: runtime execution of the `[*] = ;` DScript text; R/G semantics on `.src`, custom/modded or editor-authoring masks; any forest/stone **density** derivation from G; native `SmoothTerrain`/`_misc_SmoothTerrainCustom` kernels; stamp-vs-smoothing stage order; `fa`/`broad` for a 24-bit TGA. No donor visual parity claim. *(V26 C3)*

## 2. Height formula class map (A02/X03) [O] donor-intent, INERT on shipped masks

The class×R formula below is donor-intent text (`generatemap.inc:4-7,567-574`, X03 D2:4/570), **not a live shipped-mask rule** — on all vanilla `_gauss` masks R=0 off starts, so `hterrain=0` and §1's `h=−1.1·B/255` is the observed fact. Do not flip the port's `relief()` sign or add a per-code amplitude bump: X19 C-F shows `mapgen.gd:63-85` already matches the donor codes. Genuine I07 work is the B≥58 off-by-one, the coastal gate, the missing land/bsmooth passes and the manifest contract (X19 G1/G3/G13–G16). *(V26 C3)*

Donor `generatemap.inc:4-7`:
`h = −1.1*fB*(1 + 3.5*fR) + {2.964/1.31733…/−2.964}*fR`
with R smooth codes (`:24-27, :352-370`). The port's `mapgen.gd:51-61` uses a
wrong-sign `relief()` (A02 E08) — a concrete bug for I07 to fix.

## 3. Smoothing chain (D06/A02) [O]

- `SmoothTerrain(radius 3)` on `bsmooth` cells; whole-map
  `_misc_SmoothTerrainCustom(power=4, lerp=0.5, h∈[0.01,100])`; then 3 passes
  `power=0.35, lerp=0.5, h∈[−100,−0.01]` on cells with water in a 5×5
  neighbourhood (`generatemap.inc:580-643`).
- Coastal gate = **mask B + height band**, not height threshold (C4).

## 4. Forest/stone density [U]

If G is zero on all vanilla non-start pixels, forest/stone density must come
from pattern stamping (F08: `foreststype` hard-forced to 0, pass rates
0.0009/0.0009/0.00054), **not** from mask G. Confirm with D03/F08/X19.

## 5. Port decoder bugs — DO NOT REPEAT (from X19) [O]

- `import_donor_masks.py:98` uses `B>58` (≥59) instead of donor `B>=58`, and
  counts white start dots as water (med/22: 0.213643 vs 0.213857) — use
  `B>=58` and exclude starts from water fraction.
- `mapgen.gd:126` gate `height<0.8` is **always true** → global, not coastal
  smoothing; coastal gate is mask B + height band.
- `land` reads the wrong donor folder (G4).
- `mapgen.gd:212-213` matches `h=-1.1*B/255` **exactly** at 320² — spec §2's
  "wrong-sign `relief()`" claim is **STALE/REFUTED**; do NOT flip the sign.
- Three distinct thresholds: `B==255` class / `h=-1.1*B/255` bed /
  `B>0 ∧ h<-0.25` tag. X19 supplies V1–V7 numeric vectors.

## 6. Cross-check queue (updated)

D03 ✓ (blur/smoothing constants and order; full 1,331-mask census confirms
R/G zero), X18 ✓ (numpy+Pillow re-verified all 1,331 masks, 5,125 starts;
`peninsulas_5` is NOT a near-duplicate; F04 E4 mis-parsed the RLE header as a
pixel), X19 ✓, V16/V03 (C-B mask R supersedes O5).

---
*Integrated by COORD from F04 + A02/X03/D06 + D03/X18/X19.*


---
*Integrated by COORD from F04 (+ A02/X03/D06).*
