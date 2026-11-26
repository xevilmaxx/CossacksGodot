# 13 — Prior-wave memory: root causes, rejected approaches, confirmed mechanisms

Source: `reports/P06_prior_wave_distill.md` (distillation of ~200 prior reports).
**No donor parity claim.** This is the "do not repeat / build on this" memory the
fresh module must respect.

## 1. Root-cause chain [O]/[D]

- **Concentric rock "maze" is a 4-stage relay:** gradient `terrain=5` → detail-pass
  tile ids → stale smoothing guards → spot-id alpha patches (Y01/Y02/L03/Y01b/
  Y07/Y08). It is not a single bad line; removing only one stage leaves rings.
- **Flat relief** = amplitude-vs-footprint scale + no relief props + unfirable
  cliff-face gates (A05/Z02/Z03). Height *is* in the mesh; it simply cannot read.
- **Shore / mill / mine gaps** = donor-binding and unit-mismatch issues
  (G26/F2-02/M02), not missing shader math alone.

## 2. Do NOT repeat (12 ranked rejected approaches)

Led by: B04 face promotion, `HEIGHT_SCALE` fudge, S-25-09 noise/dither field,
tile-art relief, forced cliff art, and the heightmap-as-albedo hypothesis
(refuted three times: H03/H05/H04). Full ranked list with evidence in P06 §.

## 3. Build on this — donor mechanisms already confirmed [O]

- 124-cell donor-indexed tile atlas (F05, B02).
- `.a`-only alpha crossfade; no height layer is bound as albedo (H05).
- Donor height grids + detail bitmaps + 3-pass smoothing order (DTRN_01/02).
- Donor water shader equations (water3d report).
- Tileindex geometry path: one ArrayMesh, UV2=(tile id, face) (V785/V786/H01/H06).
- 112 relief-prop records in `pattern.lib` (V784/Z06) — silhouette comes from
  instanced objects, **not** from a height bump.

## 4. State a fresh module must coexist with [O]

- P06 registers **28 open items (V-01…V-28)**; resolution status is point-in-time (V03 may close some) — re-check before claiming any closed.
- **Stale git premise [O→D]:** P06 §5.1 (`:194-204`) and A06 E12/E13 listed three *uncommitted* source edits (Y08b `game.gd`, Y10 shader, Y11 `project.godot`) at `0e9783f2`. V04/V05/V11/V16 verified they are **committed in `e234ac9b`**; do not re-apply them. At the V26 read HEAD is still `e234ac9b` but new uncommitted I11-SEAM edits and untracked donor files are present — re-read live status before any edit (V11 §6 rule 4). Committed Z08/C01/Y08 machinery is the baseline to build on, not a patch set. *(V26 C4; confirmed live at V43 read)*

## 5. Ranked priority for the fresh implementation [D]

1. Donor stage order + per-stage RNG (spec §10) — the structural cause.
2. Donor pattern relief grids / object lists (spec §04) — the silhouette cause.
3. Donor tile ids + alpha crossfade (spec §06) — the visual-pattern cause.
4. Relief props (spec §08) — the missing hills/mountains silhouette.
5. Shore/water binding and mill-field decals (spec §05/§08).

---
*Integrated by COORD from P06.*
