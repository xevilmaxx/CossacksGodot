---
id: B04
ticket: TERRAIN-SWARM-2026-11-25 / B04 (IMPLEMENTATION, exclusive owner)
title: "REVERTED — relief/cliff-face promotion caused dense contour rings; source restored to pre-B04 backup"
owner: B04 (world3d_terrain.gd only)
created: 2026-11-25
status: REVERTED__OWNER_VISUAL_REGRESSION__SOURCE_IDENTICAL_TO_BACKUP__NO_GODOT_JOB__NO_RUNNER_JOB
backup: inbox/backup/world3d_terrain.gd.bak-B04
edited_file: variant3d/scripts/world3d_terrain.gd (RESTORED — no net diff vs HEAD)
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "PORT APPROXIMATION — no donor GPU A/B frame exists (CHARTER §3). No donor parity claim."
---

# B04 — REVERTED after owner visual regression

## 0. Verdict

**B04 is fully reverted.** `variant3d/scripts/world3d_terrain.gd` is now
byte-identical to `inbox/backup/world3d_terrain.gd.bak-B04` (verified with
`git diff --no-index` → no output; `git status --short` shows no `M` on the
source). The report below records what was attempted, the observed regression,
and why a "more conservative" variant was **not** safe to ship without a
runtime capture.

## 1. Owner visual verdict (OBSERVED)

Fresh real-map capture opened this pass:

`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\realmap.png`
(1280×720, read directly with the image tool).

Direct visual read:
- The ground is covered by **dense concentric topographic contour / maze
  patterns** — nested stepped rings across nearly the whole frame.
- Distinct concentric rings appear **around every building / start position**
  (centre town hall, two thatched huts, small resource clusters).
- This is a **severe regression** relative to the prior near-flat frame and is
  "utterly unlike the reference samples" (owner's words): the reference shows
  organic grass with occasional ravines/cliffs, not contour art.

No further capture was taken by this worker (no Godot / runner job, per order).

## 2. What was attempted (now removed)

The shipped-then-reverted change added `_relief_face_at()` to
`world3d_terrain.gd`, a second promotion path applied from `build()`:
- scaled the verbatim donor `cDiff1=0.5` / `cDiff2=0.55` by the decoded height
  span (`span × 0.03`, floor 0.05 m, capped at the donor literals); and
- added the donor absolute-height rock gates (`|h| > 2.4` / `> 2.7`,
  texturemap.inc:594-601) as an extra promotion condition.

The intent was A05 §6 Fix 2 (promotion reachability on 1-4° port slopes).
`_face_mode_at()` and all mesh/topology/UV2 code were left untouched.

## 3. Why it regressed (diagnosis, labelled)

- **OBSERVED (source):** `game.gd:951-966` marks a `near_start` protection disc
  around each start; `_shape_stamp_relief()` skips those cells
  (`game.gd:1037`: `if terrain[i]==3 or terrain[i]==4 or near_start[i]!=0:
  continue`). Relief is applied immediately outside the disc. The boundary is
  therefore a **one-cell height step of up to ≈2.964 m** (`game.gd:81,1102`).
- **DERIVED:** any face-promotion gate that fires on local height deltas will
  fire on that disc boundary, producing exactly the concentric rings around
  buildings seen in the capture. The rings are not in the baseline because the
  baseline `_face_mode_at()` uses the verbatim donor `cDiff` test on a field
  where the port's own collision pass already flags steep cells
  (`game.gd:1240-1263`) — the previous frame was flat but **clean**.
- **OBSERVED (source):** `game.gd:1232-1239` quantises/dithers the height cap
  by ~0.03 R-levels on non-donor cells; donor-derived coarse grids are 8×10
  block means (A05 §3.2). Both create numerous small height terraces.
- **DERIVED:** the absolute-height rock gate (`|h|>2.4`) promotes broad plateau
  interiors — whose mask shape is itself concentric — so the face art traces
  the plateau contours; the span-scaled `cDiff` gate promotes the terrace
  edges. Together they explain the dense maze.
- **INFERRED:** raising the gate to ~1.0 m (as suggested in the follow-up)
  would suppress the small terraces but **not** the `near_start` boundary
  steps, which can reach ~2.964 m in a single cell. The rings around the
  buildings would therefore persist. A runtime capture is the only way to
  confirm any new threshold, and this worker is forbidden from running one.
- **CONCLUSION:** no variant of the promotion path can be **guaranteed** clean
  under the current producer data without a fresh visual A/B. Per COORD's
  explicit instruction ("a flat-but-clean terrain is better than this"), the
  entire B04 change was reverted.

## 4. Revert proof and invariant status

| Check | Result |
|---|---|
| `git diff --no-index backup source` | **no output** — files identical |
| `git status --short variant3d/scripts/world3d_terrain.gd` | **no `M`** — source matches HEAD |
| Mesh topology (1 / 4096 / 7938 / 4096) | Pre-B04 code restored; unchanged |
| `_face_mode_at()` | Byte-identical to pre-B04 (flat-grid guard intact) |
| UV2.x / UV2.y semantics | Pre-B04 code restored |
| Atlas / sampler / shadow / water / sun literals | Pre-B04 code restored |
| Lighting view-dependence (F-8) | No B04 term remains |

The reverted source carries **no** `B04_` constants, no `_relief_face_at()`, no
`_relief_promoted_cells`, no `stats["b04_relief_promotion"]` and no B04 comments.

## 5. Handoff / recommendation to COORD

1. **Keep the revert.** Do not re-enable B04 on the current height producer.
2. **Sequence:** land B03 first (donor-active relief grids, especially
   `ravine_big`, in `game.gd` — separate owner). A05 §5/:273-278 identifies
   grid coverage, not face promotion, as the highest-leverage cause.
3. **Also fix the producer boundary** before any future promotion work: the
   `near_start` hard height step (`game.gd:951-966,1037`) must be tapered or
   the promotion gate must be fed an explicit producer-side relief mask (A05
   §6 Fix 2's first option) so a protection-disc edge cannot be mistaken for a
   cliff. Both are outside this ticket's file ownership.
4. **Only then** re-attempt promotion in `world3d_terrain.gd`, with one
   threshold at a time, a fresh windowed capture and a second-agent visual
   read. Until such evidence exists, the contour-regression record here stays
   OPEN and must not be flipped to PASS.
5. No donor parity claim: none of this establishes or refutes donor visual
   parity (no donor GPU A/B exists).

## 6. Boundary statement

- One source file was edited and then **fully restored**; no net source change.
- Backup `inbox/backup/world3d_terrain.gd.bak-B04` retained as the audit point.
- No shader, `game.gd`, atlas loader, test, config, asset or `app/**` edit.
- No Godot process, no runner job, no queue mutation, no git operation by B04.
- Available for follow-up: yes.

---

*End of B04. Attempted, visually regression-tested by the owner, and reverted. Flat-but-clean retained.*
