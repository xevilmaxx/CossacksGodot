# SEQ-SNAPSHOT — three-snapshot sequence compare (mapreuse → palmdesert → nationmove)

Date: 2026-11-26
Role: READ-ONLY image-sequence analysis. No code / Godot / git. Donor files READ ONLY.
Scope: exactly one repository file written: this report.
Parity: **NO parity claim. Donor parity UNVERIFIED.** Donor video frames are direction-of-appearance references only (unknown build / map / camera / zoom / compression).

## 1. Inputs and sequence definition

Sequence order is the task input order (not file mtime):

- S1 = `inbox/qa/captures/cap_mapreuse.png` (763,684 B, 2026-11-26 16:12)
- S2 = `inbox/qa/captures/cap_palmdesert.png` (766,217 B, 16:15)
- S3 = `inbox/qa/captures/cap_nationmove.png` (760,128 B, 16:05)
- REF = `inbox/qa/captures/cap_donor_240_colorfield.png` (725,215 B, 15:48) — donor-240 still with mill + flat green checker to the east, different camera/seed; used only as field-class reference, not as sequence member.
- Context sheets (different scenes, stability context only): `contact_close-shorealpha.png`, `contact_shorealpha2.png`, `contact_wide-final.png`, `donor_compare_contact.png`.
- Donor direction frames (V1 `cZW0AEupCaI`, 1280×720): `t_120` (field+mill+pit), `t_300` (ridge), `t_600` (red building/rock), `t_1200` (minehead+rock apron, red church), `t_1800` (gold parcel+mill, mines on grass). Viewed read-only; no metrics transferred.

Labels: [O] directly seen, [D] deterministic read/rank from [O], [I] interpretation, [U] unresolved.

Method: direct side-by-side view of S1/S2/S3 at native 1280×720. Boxes are `[x0,y0,x1,y1)` locators for re-measurement, not measured constants. No new RGB statistics computed in this worker; all numbers are counts/presence reads.

## 2. Scene contract (common to S1–S3)

All three show the same town seed/camera: central wooden hall with red tower trim + cross, thatched house W + thatched house E with fences, two vertical dark troop columns E of the E house (~2×12 figures each), 4 mine/stone deposits (NW small grey, NE small, SW large gold/brown, E large red/black), SW + NE/E forest belts on flat olive grass. No mill, no parcel grid, no water, no ridge in any of the three.

## 3. Stability across S1 → S2 → S3

### 3.1 Ground [O] — stable, no checker, no seam line

- Flat olive grass fills >80% of every frame. No 2 m checkerboard, no 46–48 px periodic grid, no N–S/E–W straight colour-seam line, no striped shore band in S1/S2/S3.
- This matches `PHOTO_SEQUENCE_review.md` obs. 1 (no atlas crawl) and contrasts with old wide2 (`SEQ_WIDE` §2: chevron relief + sand plateau + `bv32 ≈ 2` flat grass). The ground defect in this sequence is flatness/monotony, not instability: the field does not change between S1, S2, S3.

### 3.2 Forest [O] — stable positions, sparse

- SW belt (`≈[0,430,320,720)`): ~18–22 crowns (mix of yellow-green leafy, bare sticks, dark conifers) in all three; trunk/crown centroids do not move S1→S2→S3.
- NE/E belt (`≈[980,20,1280,330)`): ~30–35 crowns, same composition and positions across all three (tall bare trunks + yellow-green crowns at top edge identical).
- No grove/stand structure, no canopy closure, no shadow side — consistent with REVIEW3 rank 8 and `SEQ_WIDE` §2.5 (sparse, ground-fixed). Stability verdict: world-locked, no pop-in/out between snapshots.

### 3.3 Buildings + troops [O] — bit-stable composition

- Hall + 2 houses + fences + troop columns are pixel-identical in layout across S1–S3: same roof thatch strokes, same red tower band, same fence angles, same troop file spacing.
- `NATION_MOVE_ukr_buildings.md` §verification (S3): hall + houses render with no missing-mesh proxy — confirmed here: no white/proxy box, no floating roof in any of the three. No regression S1→S3 from the `shared/buildings → ukr/buildings` move.

## 4. New understory presence [O]

- S1/S2/S3 all show a sparse low layer on the SW forest floor that REF lacks: ~6–10 small dark tufts/saplings between the larger crowns (e.g. `≈[120,460,320,700)` — short vertical strokes + dark blobs at grass level, distinct from tree trunks).
- REF (`colorfield`) SW quadrant (`≈[150,350,330,550)`) shows only ~8 isolated thin trunks on bare grass with no floor tufts.
- Read [D]: understory class is **present but thin** in the town sequence and stable across S1–S3 (same tuft positions, no growth/flicker between snapshots). Density is far below donor V1 `t_1200` / V2 `t_600` forest-floor language (grass tongues + saplings inside rock aprons, glades, multi-height fringe). Whether these tufts are `fern/bush/reed/plantain` instances or sapling LODs is [U] — no per-instance dump in this worker.

## 5. Palm / desert absence — binding still open [O]

- Zero palm crowns (single tall stem + fan) and zero desert-scrub rosettes in S1, S2, S3, and REF.
- Expected per `AUDIT_TERRAIN_ASSET_COVERAGE.md` §1–§3: `palm` (1,319) + `palmsmall`, `desert1..5`, `plantyellow` (~5,500 forest-class records) have **no converted mesh / no sid rule**; `terrainmeshdesert1..4` unresolved; desert families (`desert_frt_*`, `desert_plt/plain/mnt`) unconverted. The `palmdesert` snapshot name notwithstanding, this is a [D] binding-gap confirmation, not a placement regression: there is nothing to place yet.
- No winter tint in any frame; season path untouched.

## 6. Colour seam vs mine halo [O]

- **No straight colour seam.** None of S1–S3 shows the old tile-boundary line, sandrock stripe, or half-frame tint step. REF likewise shows no N–S seam; its E checker is a parcel grid (see §7), not a seam.
- **Mine halo persists unchanged S1→S2→S3.** Each of the 4 deposits carries a pale yellow-green elliptical annulus ~1.5–2× the rock-core radius, most legible on the E deposit (`≈[1060,360,1240,470)`) and SW deposit (`≈[240,440,390,530)`), fainter on the two small N deposits. Halo shape/opacity/extent are visually identical across the three snapshots — no attenuation between S1 and S3.
- This is the `PHOTO_LED_mine_colour_seam.md` / `VIDEO_MINE_FIELD.md` §2.3 class: pale annulus with no donor counterpart. Donor V1 `t_120` pit, V1 `t_1200` minehead+rock, V2 `t_300` stone pit all show grass/dirt/rock meeting the lip with dark contact, never a bleached ellipse. Per PHOTO_LED §2 the seam is a port lighting-consistency mismatch (props on donor-derived `AMBIENT 1.4 / SUN 2.0` rig, terrain on unscaled colours), not tile art — endorsed, not re-measured here. Exact 5-ROI re-measure (`disc/halo/global-left/global-top/field`) is left to the halo-fix re-shoot.

## 7. Field visibility [O]

- **S1/S2/S3: zero field parcels.** No gold crop, no green tuft grid, no dirt clearing, no parcel boundary in any of the three (expected: no mill in this seed/config; `AUDIT_FIELD_STAGE_TIMING` Branch A).
- **REF: field class present as flat green checker, not golden.** E block `≈[1040,220,1280,480)` holds ~15–20 closed light-green squares in a checkerboard with dark gaps, plus mill at `≈[1050,140,1210,290)`. No crop rows, no gold fill, no dirt square under the mill at this distance — consistent with REVIEW3 §4 rank 3 (dark-neutral parcels `~[51,48,41]`) and `VIDEO_MINE_FIELD.md` §4–§5 (Branch A/B config-or-decal question), rendered here in green rather than black by config/lighting.
- Donor direction (V1 `t_120`, `t_1800`): closed diamond parcels, parcel-full gold rows to the edge, square dirt clearing under a centred mill, peasants on the gold. Neither S1–S3 nor REF reaches this read; REF proves footprint, not material.

## 8. Ranked next 3 snapshot checks (same camera, same seed unless stated)

1. **Halo-attenuation re-shoot at the S1–S3 town camera.** Gate/hide the halo quad only; keep rock cores, positions, counts byte-identical. Re-measure the exact `PHOTO_LED` 5 ROIs: halo→global delta should collapse toward ~0 with disc texture preserved and no new axis-aligned edge. Settles whether the halo is the sole seam in this scene.
2. **Donor-fixture field re-shoot (`map_donor_240.json`, `demo_mill:true`) at the REF camera + one town-camera attempt.** Assert `field_visual_ripe_count > 0` in the log before reading pixels; then read REF ROI `≈[1040,220,1280,480)`: dark/green-flat mask should give way to gold row texture (grad rise, gold fraction donor-ward) with parcel edges staying closed and a dirt square under the mill. Distinguishes Branch A (config) from Branch B (decal/mip) per `VIDEO_MINE_FIELD.md` §5.
3. **Palm/desert binding probe on a desert-forest map (not the town seed).** After the A3 converter batch (`palm/palmsmall`, `desert1..5`) lands, shoot one pinned desert-stand frame and count palm/scrub instances vs the ~5,500-record backlog. Town S1–S3 must stay palm-free (correct for a non-desert map); the probe belongs on desert ground so absence there becomes meaningful.

## 9. UNVERIFIED register

| ID | Item | Why unresolved here | What would settle it |
|---|---|---|---|
| SS-U1 | Exact halo RGB/sat deltas in S1–S3 | No numeric ROI probe run in this worker; prior numbers are from `cap_donor_240n.png`, a different camera | Same-camera 5-ROI re-measure after check 1 |
| SS-U2 | Understory asset identity (fern/bush/sapling) | Image shows tufts, not material IDs | Per-instance material/LOD dump on the SW belt |
| SS-U3 | Palm/desert placement correctness | No converted art to place; town map would not show them anyway | Check 3 on desert ground after A3 conversion |
| SS-U4 | Field material vs config cause | Town seed has no mill; REF checker is a different config/camera | Check 2 with log asserts + same-camera pair |
| SS-U5 | Donor parity of any pixel | Third-party H.264, unknown build/map/camera/zoom/compression; no donor GPU A/B frame | Owner-controlled same-camera capture; still no parity assumption |

## 10. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Ground/forest/buildings/troops/deposits are stable across S1→S2→S3; no checker, seam line, pop or proxy regression | [O] |
| 2 | Sparse floor understory is present in S1–S3 and absent in REF; density far below donor forest-floor language; identity unverified | [O]/[U] |
| 3 | Zero palms / desert scrub in all inputs; binding gap still open per asset-coverage audit, not a regression | [O]/[D] |
| 4 | No colour seam line; mine halo persists unchanged on all 4 deposits; halo has no donor counterpart at the 5 viewed timestamps | [O] |
| 5 | Zero field parcels in S1–S3; REF shows flat green checker + mill (footprint without golden material) | [O] |
| 6 | No donor parity, similarity %, donor threshold, or gate PASS is claimed | [U] |

*End of SEQ_SNAPSHOT_compare. Exactly one repository file written: this report. No source, shader, config, asset, test, fixture, result JSON, git, Godot, or donor-binary change; donor frames viewed read-only; no donor parity claim.*
