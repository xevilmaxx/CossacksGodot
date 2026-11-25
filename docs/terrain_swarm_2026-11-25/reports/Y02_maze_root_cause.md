---
id: Y02
ticket: "OWNER CLARIFICATION wave — Y02, independent second opinion (maze root cause)"
date: "2026-11-25"
status: DELIVERED__READ_ONLY__NO_GODOT__NO_RUNNER__NO_CODE_EDIT
scope: "ONE report written. No runner job, no Godot process, no source/asset/config/test/git edit. Y01's conclusion was NOT read until after this verdict was formed (agreement note appended last)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). NO DONOR PARITY CLAIM. All donor statements are structural citations from prior reports; all port statements are code reads."
owner_claim_under_test: "The maze patterns have always been there; only the colour changed; positions are the same."
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md (REVERTED)
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/terrain_swarm_2026-11-25/reports/A05_relief_visibility.md
  - docs/terrain_swarm_2026-11-25/reports/H01_donor_layers.md
  - docs/terrain_swarm_2026-11-25/reports/H02_port_layers.md
  - docs/terrain_swarm_2026-11-25/reports/H03_heightmap_hypothesis.md
  - docs/terrain_swarm_2026-11-25/reports/H05_refutation.md
  - docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_DIAG_01.md, RELIEF_VISUAL_01.md
  - "IMAGE: C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\g04\\realmap.png (read directly)"
  - variant3d/scripts/game.gd (current tree, lines 730-899, 930-1119, 1215-1284, 1975-2039, 2120-2179; grep for terrain=5 / _relief_donor_mask)
  - variant3d/scripts/world3d_terrain.gd (grep for height consumers; B04's _relief_face_at confirmed absent)
---

# Y02 — Root cause of the maze/contour patterns (independent second opinion)

## 0. Evidence discipline

**[O]** observed (literal current source line, or a pixel read directly from the named PNG);
**[D]** derived (deterministic control-flow/arithmetic consequence of [O]); **[I]** inferred
(attribution without a pixel-aligned donor A/B); **[U]** UNVERIFIED. **No donor-parity claim.**
No Godot was launched, no runner job submitted, no source file edited. Y01's verdict was not
consulted until §7 was appended.

---

## 1. [O] Direct read of `realmap.png`

Path: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\realmap.png` (1280×720,
opened with the image tool). What is actually in the frame:

- **Subject:** a large dark-roof town hall at centre, two thatched huts immediately left and
  right of it, ~6 infantry figures and small reddish resource clusters nearby; sparse conifers
  along the right edge and lower-left; olive-green grass with fine grain.
- **The artifact:** the whole ground is overlaid with **dense nested stepped concentric rings —
  a topographic-contour / labyrinth "maze"**. The lines are 1–2 cells wide, grey-brown / dark
  olive, and form elongated rectangular-to-octagonal closed loops, often several loops nested
  one inside another. They are not fine noise and not a within-cell vein: they span tens of
  cells and are aligned to the tile grid.
- **Placement:** distinct rings **encircle the town hall and both huts**, sitting just outside
  each building's clear area; isolated small hexagonal rings sit around the small resource
  clusters; long meandering nested contour bands run through the open fields (upper-left,
  lower-centre, right side). There is **no hill silhouette, ridge shading or self-shadow** —
  the rings read as flat art, not geometry.
- Some pale tan/grey checkerboard patches near the resource clusters (worked-ground/mine-apron
  ids) are a different symptom and are not the maze.

**Corroboration that the geometry predates this colour:** `RELIEF_VISUAL_01.md:141-157` [O, cited]
describes an earlier *real generated map* frame with "bright, almost-white and pale-tan stepped,
grid-aligned bands with concentric/nested outlines", including "an isolated pale hexagonal ring",
and explicitly says they are "flat-looking, repeatable tile/step patterns (transition art), not
terrain relief" and "no hills are visible". **Derived:** the same nested-ring geometry is present
in both frames; what differs is the palette (near-white/pale-tan then, grey-brown/olive now).
That is consistent with the owner's statement — **positions stable, colour changed** [D]. No
flag-off A/B exists, so the causal claim about *which* edit changed the colour is **[U]**.

---

## 2. [O] The current source chain that turns relief height into visible rings

```
_shape_stamp_relief()  game.gd:937-1113
  :951-966   near_start protection disc around EVERY start (radius `protect`)
  :1037      `if terrain==3 or terrain==4 or near_start[i]!=0: continue`
  :1055      donor-grid cell: height[i] written ONLY  (_relief_donor_mask[i]=1 at :1065)
  :1102      analytic fallback cell: height[i] written ONLY
  --> no tileblock / terrain write anywhere in this function [O]
global clamp/dither      game.gd:1219-1239  -> terraces; plateau tops saturate at 2.964
collision pass           game.gd:1240-1264
  :1250-1261 |dh|>0.5 cardinal / >0.55 diagonal
  :1263      terrain[i] = 5      <-- height gradient becomes a VISIBLE TERRAIN ROLE
  :1264      set_blocked_tile(x,y,true)
tile assignment          game.gd:1984-2031
  :2013-2025 terrain 5 -> rock1/rock2/rock3/rock6/rock7/rock4 ids
shore/cliff pass         game.gd:2127-2173
  :2133-2134 dir_x/dir_y from the SAME height neighbours
  :2154-2157 |h|>2.7 -> rock8, >2.4 -> rock4, <0.1 -> none
  :2170-2173 terrain 5 -> oriented cliff id
3-pass donor smoothing   game.gd:2039+ -> transition ids spread around the rock cells
atlas + shader           shader :417/:427 -> alpha patch folded into albedo (colour only)
```

**[D]** The rings are contours of `height[]` at the collision threshold. Around buildings the
contour is the `near_start` disc boundary (relief suppressed inside, applied immediately
outside → a one-cell step of up to ≈2.964 m, `game.gd:81-83,1102,1239`), plus overlapping
stamp footprints; in open fields they are the plateau/hill stamp terraces. Because the height
producer is deterministic for a fixed seed, the contours are **position-stable across runs** —
exactly the owner's observation. **[U]** no GPU probe was run to measure this frame's actual
tile-id histogram.

**Negative [O] (important):** grep of `game.gd` finds `_relief_donor_mask` only at `:73,956-957,
1065,1231`; the relief stamps write **no** tile id and no `terrain` value. The **only** route
from relief height to visible tile ids is through the collision pass at `:1263` and the
height-gradient cliff pass at `:2127-2173`. `world3d_terrain.gd` consumes `height[]` at
`:1311` (vertex Y), `:1387` (normals via `_normal_at`) and `:1332` (`_face_mode_at`); B04's
`_relief_face_at()` is **absent** (revert confirmed), so no face-promotion path contributes to
the current frame.

---

## 3. Ranked verdict on the five candidates

| Rank | Candidate | Verdict | Evidence |
|---:|---|---|---|
| **1** | **(b) height-gradient rock painting, `game.gd:1240-1264`** | **PRIMARY — the maze producer** **[O]+[D]** | `:1250-1261` gradient test; `:1263` `terrain[i]=5`; consumed at `:2013-2025` (rock ids) and `:2127-2173` (oriented cliff ids). Rings around buildings trace the `near_start` boundary at `:951-966`/`:1037`. This is the only current code that converts relief height into a visible art role. |
| **2** | **(c) relief height stamps feeding tile ids** | **CONTRIBUTING UPSTREAM, not an independent painter** **[O]+[D]** | `_shape_stamp_relief()` `:1055`/`:1102` writes height only; no `tileblock`/`terrain` write. Its only route to ids is rank 1 and `_cliff_tile_for()`. Calling this a separate "height stamps paint ids" bug would be wrong; it is the *data source* of rank 1. |
| **3** | **(d) atlas art** (incl. B03's `grass_ground*` redirect `game.gd:2197-2209`, B01/B02 filtering/mips) | **SECONDARY — colour/texture only** **[O]+[D]** | Atlas cells supply the grey-brown rock and transition cells along the contour; they cannot create map-scale, building-centred nested geometry. Best explanation for "only colour changed" (B03 art redirect at `:2205-2209`; B04 revert removed cliff-face art) — but which edit actually changed this frame's colour is **[U]** (no post-B03 histogram / A/B). |
| **4** | **(a) hill/stone stamp `terrain=5`, `game.gd:846-852`** | **REAL BUT MINOR — cannot explain the maze** **[O]+[D]** | `dc := distance from stamp centre` (`:811`); hill paints only footprint cells with `dc<=2.2` (`:851-852`), stone `dc<=3.2 -> terrain=1` (`:842-843`) and `dc<=1.6 -> terrain=5` (`:844-845`). That is a ≤2–3-tile disk at a stamp centre, not frame-wide nested contours. It can add small rock dots, not the rings. |
| **5** | **(e) alpha mask** (`shader:417`, folded at `:427`, `mask_to_alpha=1`) | **RULED OUT as geometry producer** **[O]+[D]** | A per-cell 8×4 grid of 64² feather patches sampled with `fract(v_alpha_uv)` and multiplied into albedo. It modulates brightness *within* cells; it has no map-space coordinate input and cannot produce building-centred concentric bands. Colour contributor only. |

**Single most likely root cause:** **(b)** — `game.gd:1240-1264`, the height-gradient collision
pass, with the `near_start` hard step at `game.gd:951-966`/`:1037` as its principal ring
generator. **[I]** attribution at frame level (no GPU A/B); the code path itself is **[O]**.

**Agreement with prior reports:** H03/H05 **[O, cited]** correctly refute the literal claim that
a *donor height layer is mis-bound as albedo*, and rank 5 of `RELIEF_LIVE_DIAG_01` **[O, cited]**
correctly says `rock8`/`rock4` cannot mark genuinely flat cells. My verdict extends them: the
mis-route is not a donor layer at all — it is the port's **collision-derived `terrain=5` art**
fed by port-analytic relief. H03's "streaks = 2 m atlas repeat" and H05's "vein art" explain
the *fine* streaks, not the *nested contour maze* in this frame **[D]**. No parity claim either way.

---

## 4. MINIMAL change that makes relief height-only

**Goal [D]:** relief must keep affecting geometry (vertex Y, normals, face gates) and movement
(collision), but must stop selecting rock/cliff **art**. Preserve `terrain[]`, `blocked[]`, the
`cDiff1/cDiff2` thresholds, the donor smoothing tables and every existing gate.

**Recommended (art-only guard — smallest change with zero gameplay surface):**

1. In `_shape_stamp_relief()` (`game.gd:937-1113`), add one `PackedByteArray` relief-stamp mask
   (e.g. `_relief_art_mask`), set it at the two existing height writes — `:1055` (donor grid) and
   `:1102` (analytic) — over the same cells that receive `height[i]`. Optionally also mark the
   immediate outside of the `near_start` disc generated at `:951-966`, since that hard step is
   the dominant ring source. **No height value, RNG stream or stamp placement changes.**
2. In `_assign_tileblocks()`, guard the `terrain==5` rock-id selection at `game.gd:2013-2025`:
   if `_relief_art_mask[i] != 0`, keep the ordinary terrain-role id instead of a rock id.
3. In `_apply_shore_cliffs()`, guard `game.gd:2170-2173` the same way, so `_cliff_tile_for()`
   (`:2127-2160`) is not called on relief-stamp cells.

**Invariants preserved [D]:** `set_blocked_tile(x,y,true)` at `:1264` stays unconditional →
collision/navigation/slope checks (`game.gd:2287-2300`, `:4831`) unchanged; `terrain[]` roles stay
byte-identical so resource/mine/scan filters (`:400,:695,:788,:884,:2357,:2370,:2524,:2770,:2882`)
are untouched; donor `cDiff1=0.5`/`cDiff2=0.55` rule still applies to every non-relief cell;
`tileblock` size/type, `UV2.x` contract and the `mask_to_alpha` A/B remain intact; the 3-pass
smoothing still reconciles the new borders.

**One-line alternative (smaller, less safe):** at `game.gd:1263` change to
`if _relief_art_mask[i] == 0: terrain[i] = 5`, leaving `:1264` untouched. It keeps collision but
*does* change the terrain role on relief-steep cells, which the filters above read — so it must
not be chosen without a full gate run. **[U]** no such run was performed (read-only ticket).

**Donor-rule honesty:** donor `texturemap.inc:557-591` paints rock from collision tags, so
suppressing rock art on port-analytic relief cells is a **PORT APPROXIMATION**, not donor parity
— it applies only to cells whose steepness was created by our analytic/generic relief stamping,
never to donor-authored terrain. **[U]** whether the result matches donor visually: no donor GPU
A/B exists, and G04 owns the only Godot/runner.

**What NOT to do [D]:** do not fold the alpha mask or a detail bitmap into `height[]` (H02 §5,
H05 §5 — wrong layer, breaks mesh/height invariants); do not re-enable B04's face promotion
(B04 §3 — reverted for exactly this contour regression); do not raise relief amplitude (A05 §3.2
— non-donor-grounded).

---

## 5. Is this the same layer the owner suspected in the heightmap hypothesis?

**No — same symptom, different layer.** **[O]/[D]**

- The owner's Wave-H hypothesis (WAVE_G_CHARTER `:107-109`) was: *"one of the terrain layers … should
  not be visible but used for heightmap only."* H03/H05/H01/H02 **[O, cited]** tested the plausible
  layers (terrainmask R, `.pattern` grids, detail bitmaps, alpha/alphavert) and found **no** donor
  height source that our port draws as albedo; the literal hypothesis was **REFUTED**.
- The layer identified here is **not** a donor heightmap layer at all. It is a **port-only derived
  field**: `terrain=5` written by the collision pass at `game.gd:1263` from our *own* relief height
  gradients, then expressed as rock/cliff tile ids at `:2013-2025`/`:2170-2173`. The relief data
  itself was already height-only (`_shape_stamp_relief()` writes `height[]` only) — the leak is
  one pass **downstream**, in the collision→art conversion.
- So the owner was directionally right that "relief is leaking into visible pattern", but wrong
  about *which* layer: there is no hidden height texture to hide; the fix is to decouple the
  **collision-derived rock role** from port-analytic relief, not to re-route an atlas/mask layer.

**No parity claim.** This report attributes a code path, not donor equivalence.

---

## 6. Boundary / UNVERIFIED register

- **[U]** Which specific edit changed the rings' colour (no post-B03/post-revert tile histogram
  or A/B frame exists; G15 §0 records every on-disk dump is pre-B03).
- **[U]** Quantitative share of maze pixels attributable to rock ids vs transition ids vs alpha
  fold in this frame (no tile-id histogram on `realmap.png`).
- **[U]** Whether the recommended guard visually matches donor (no donor GPU A/B; CHARTER §3).
- **[U]** No Godot run, no runner job, no queue mutation, no git operation by Y02.
- Only one file written: this report. Source tree left untouched.

---

## 7. Agreement / disagreement with Y01 (appended after the verdict above was written)

**[O]** After writing §§1-6, a repo-wide glob for `**/reports/Y0*.md` found **only this Y02
report** — no Y01 file (under any name) exists on disk at this time. Therefore **no
agreement/disagreement statement with Y01 can honestly be made**. [U] If Y01 lands later, the
decisive comparison points are: (1) whether Y01 also names `game.gd:1240-1264` /
`:1263 terrain[i]=5` as the maze producer rather than `game.gd:846-852`, the atlas art or the
alpha fold; (2) whether Y01 treats `_shape_stamp_relief()` as already height-only (it is —
`:1055`/`:1102` write height, no tile ids); and (3) whether Y01 separates the stable ring
*geometry* from the changed *colour*. This Y02 verdict stays **(b) PRIMARY** regardless of that
comparison, because it is grounded in the current source lines and the direct image read above.

*End of Y02. One report written. No code, Godot, runner, queue or git change. No donor parity claim.*
