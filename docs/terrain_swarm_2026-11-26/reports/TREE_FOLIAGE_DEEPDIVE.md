# Tree foliage defect — read-only deep dive (OPEN)

Date: 2026-11-27. No code change, no donor execution, no parity claim.
Follow-up to Muse Spark 1.3 finding #2 in `ENEMY_VIDEO_MUSESPARK.md`.

## Evidence gathered

- QA 64×64 map resource census (runner ticket 244):
  `res_nodes n=209 kinds={gold:4, iron:7, coal:4, wood:181, stone:3, food:10}`.
  The "sticks" are therefore **wood resource nodes**, not a stump category;
  `wood_sids={ "?": 181 }` because `world3d_entities.gd:4058-4072` maps
  `wood -> _pick_sid(POOL_TREE, pos)` (position-deterministic, no RNG).
- Converted donor assets exist for every tree sid:
  `assets/models/obj/shared/terrain/tree_*.obj` and
  `assets/models/tex/shared/terrain/tree_*.png`.
  `tree_spruce1.png` is RGBA 512×512 with real cut-out alpha
  (`extrema (0,255)`, mean 107.8) — the foliage texture is present, not missing.
- `tree_spruce1.obj`: 863 vertices / 1060 faces; UV range
  `u [-1.12,1.86] v [-0.02,1.75]` — cross-plane mirrored tiling, unlike the
  building OBJs sampled (`gat`/`mar`/`eurmilanim` all within [0,1]).
  Sampling face-centre UVs against the PNG alpha: **64.7% of faces land on
  opaque pixels with texture wrap, 34.3% with clamp**. Godot's default is wrap,
  so alpha geometry should survive on most faces.
- Import settings: `mipmaps/generate=false`, `process/fix_alpha_border=true`,
  `process/premult_alpha=false`; OBJ import `generate_lods=true`.
- Material path `world3d_entities.gd:1157-1175` applies donor albedo with
  `TRANSPARENCY_ALPHA_SCISSOR 0.5`, `CULL_DISABLED`; donor `alphaMode` is
  UNVERIFIED (V7-2 Table B1), so this remains a labelled PORT APPROXIMATION.

## Discriminating capture (tickets 245-246, `t_tree_closeup.gd`)

Fixed-camera close-up of a real wood node at sim `(59,49)`; camera target
settled `(58.40,48.40)`, height `21.54 m`, 1280×720 windowed capture:
`%TEMP%\opencode\v42\enemy_video\tree_closeup.png`. Ticket 245 showed the
capture viewport exists only in windowed mode (`is_headless` skips
`_setup_screenshot_window()`); ticket 246 reran windowed with 0 errors.

Muse Spark 1.3 ruled on this image:
- Foliage **is present** on all ~8 trees — none is a bare stick.
- Crowns are narrow, thin/see-through (ground visible through them), with
  dark-green / yellow-green / muddy-brown variants; two broadleaf crowns are
  denser but small.
- **Ruling: hypothesis (a) trunk-only LOD is REFUTED; (b) cross-plane /
  mirrored-UV sparse foliage is SUPPORTED** (inference). The sparseness is
  intrinsic to the converted mesh, not a distance LOD switch.
- Additional observations: desaturated grey-purple terrain blotches, faint
  straight tile seams / horizontal banding, **no tree shadows** on the ground,
  and two bottom trees with dark-gray wispy / flat-star alpha artifacts
  (inference: alpha-sort bug rather than a shadow).
  The missing shadows are explainable by the donor-backed rig itself:
  `terrain_donor_world.gd:199` sets `_sun.shadow_enabled = false` (part of the
  "no shadows/AO" port decision at `:68/:179`), while the legacy rig
  `heightmap_world3d.gd:141` enables them. No donor shadow scalar was recovered,
  so this is not changed here.
- The faint terrain banding is consistent with the donor-derived UV layout:
  `terrain_donor_mesh.gd:742-757` `_rgb_uv_corners_tsdouble()` wraps both axes
  with `rows = DONOR_RGB_ROWS` (8), producing an 8-cell repeat. No divisor was
  changed; this is recorded as an observation, not promoted to a defect.
- Zoomed crop (`...\enemy_video\tree_closeup_crop.png`, 820..1280 × 470..720
  enlarged 3×) resolves the "flat star / dark wispy" artifacts: they are
  cross-plane billboards seen nearly **edge-on**, projecting as thin radial
  green spokes around the trunk rather than a crown. This is consistent with
  `world3d_entities.gd:218` `TREE_YAW_STATUS` — res nodes carry no authored yaw
  (`game.gd:_add_res` sets only id/kind/type/pos/hits/max_hits/radius) and the
  port keeps yaw 0, "no rotation invented". Donor billboard yaw is engine-side
  and UNVERIFIED, so no yaw value may be invented here.

## Conclusion

No missing asset, no missing alpha, and no trunk-only LOD. The defect is the
**intrinsic sparse cross-plane crown** of the converted tree meshes plus an
alpha-sort artifact; donor tree rendering is engine-side, so no donor-grounded
replacement value is available under the read-only charter. No mesh, texture,
material or shader value was changed.

Next admissible step remains an owner-supplied matched donor frame (or a
permitted donor GL trace) before any foliage/density constant is touched.

Status: **OPEN visual defect**, no fix applied, no parity claim.
