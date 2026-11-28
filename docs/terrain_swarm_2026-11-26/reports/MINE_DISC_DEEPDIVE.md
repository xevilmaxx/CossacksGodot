# Mine ground-disc deep dive — read-only (OPEN visual observation)

Date: 2026-11-28. No code/asset change, no donor execution, no parity claim.
Follow-up to Muse Spark 1.3 finding #3 in `ENEMY_VIDEO_MUSESPARK.md`
("resource nodes as neon discs").

## Observation

Zoomed crop of the enemy still
(`%TEMP%\opencode\v42\enemy_video\disc_crop.png`, original region
x 680..900 / y 220..360 enlarged 6×) shows a flat, hard-edged olive-green oval
beneath each mine rubble mesh. The oval is much brighter/flatter than the
surrounding mottled grass; the rubble mesh above it carries red ore speckles.

## Read-only evidence

- `world3d_entities.gd:220` `MINE_DISC_STATUS` already records the governing
  fact: **no separate deposit-disc asset exists** under `assets/terrain/**`
  (BLOCKED). The donor olive/beige cracked disc is the **low-Z region of the
  converted 2048² albedo** `assets/models/tex/shared/buildings/mine_<ore>.png`,
  applied to the mine mesh by `_default_material()` (`:1157-1175`). No separate
  terrain apron PNG was invented.
- Alpha census of the three converted albedos (`mine_gold/iron/coal.png`):
  each 2048×2048 RGBA, **alpha = 255 for 100% of pixels**, exactly one alpha
  value. There is no transparent or feathered boundary in the donor-derived
  texture — the hard oval edge is baked art, not a port alpha-scissor/blend
  mistake.
- Mine aprons in the simulation (`game.gd:2753-2830`) are tile IDs
  (`ground1`/`BLK_WATER` guards), i.e. terrain tile art, not a shader disc.
  `terrain_donor_mesh.gd:742-757` supplies donor-derived RGB UVs; no divisor or
  blend constant was changed here.

## Conclusion

The "neon disc" is the donor-derived mine albedo's low-Z region rendered as
flat baked art. It is consistent with the existing BLOCKED/SKIPPED label;
there is no donor-grounded feathering or tint value available under the
read-only charter, so **no fix is applied** and no value is invented. If the
owner supplies a matched donor frame showing a different disc, that frame —
not a guessed alpha ramp — determines any future change.

Status: **OPEN visual observation**, no parity claim.
