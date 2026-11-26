---
id: VIDEO-BUILDER-STANDS
swarm: TERRAIN-SWARM-2026-11-26 / DONOR-TERRAIN VISUAL WAVE
role: WORKER VIDEO-BUILDER-STANDS — donor construction-stand video analysis
owner_file: docs/terrain_swarm_2026-11-26/reports/VIDEO_BUILDER_STANDS.md
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists. Third-party video frames are direction-of-appearance references only. No similarity score, donor threshold, parity claim or gate PASS is made."
scope_guard: "Exactly one repo file written (this report). No source/asset/config/test/shader/fixture/git/runner state touched; no Godot job submitted; no donor binary executed; no donor material copied into the repo. Donor frames read-only under %TEMP%\\opencode\\donor_videos\\selected\\."
temp_roots:
  - "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\donor_videos\\selected\\cZW0AEupCaI\\"
  - "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\donor_videos\\selected\\ljlCn4KSSU4\\"
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DONOR_VIDEO_analysis.md
  - docs/terrain_swarm_2026-11-26/reports/REVIEW3_latest.md
  - variant3d/scripts/game.gd
  - variant3d/scripts/data.gd
  - variant3d/scripts/world3d_entities.gd
---

# VIDEO-BUILDER-STANDS — where donor peasants stand around an unfinished building

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.**

## 0. Executive answer

1. **[O] Donor peasants work from OUTSIDE the unfinished footprint, never under/inside the scaffold.** Verified on 7 construction frames across both videos (§1).
2. **[O] Distribution is an arc / 2+ sides when several workers are present, single-side when one worker remains — never a full closed ring, never stacked on one point.** Best multi-worker frame: V1 00:01:00 (~5 peasants on front + east side of the blacksmith site). Best single-worker frames: V1 00:02:00, V2 00:05:00, V2 00:10:00 (1 peasant at the west/south edge, ~1 body-width outside the wall stubs).
3. **[O] Stand-off distance is small: on / just outside the stone paving edge, about one peasant-width beyond the wall line.** No worker is inside the wall rectangle or under the scaffold poles/planks.
4. **[O] Worker count is small: 1 per small site (tower/mine), up to ~4–5 on the large blacksmith site at 00:01:00.** Nothing in the sampled frames shows 8 workers on one site.
5. **[D] The current port CAN place a builder under the site.** `game.gd:_work_slot` (lines 5195–5205) falls back to `return center` when both the primary and opposite ring points are blocked, and the `"build"` tick (lines 5480–5496) then walks the peasant to the site centre. That is the trapped/under-scaffold case. Fix is game.gd-only (§3).

## 1. Frame evidence (all files read-only, viewed at 1280×720)

Root V1: `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\`
Root V2: `%TEMP%\opencode\donor_videos\selected\ljlCn4KSSU4\`

| ID | Video time | File | [O] construction read |
|---|---|---|---|
| V1-060 | 00:01:00 | `t_60.png` | **Strongest multi-worker frame.** Unfinished blacksmith on stone platform right of town hall (tooltip "Blacksmith (L)"). ~5 peasants stand **on the paving, outside the low wall stubs**, spread over **front/south edge + east side** (an arc, not a full ring, not one point). None inside the wall rectangle, none under scaffold poles. |
| V1-120 | 00:02:00 | `t_120.png` | Same yard, site more walled. **1 peasant west/left of the scaffold**, clearly outside the foundation on grass/paving edge. Rest of crew has walked off. Worker faces the site; gap ≈ 1 body-width. |
| V1-900 | 00:15:00 | `t_900.png` | Small unfinished site centre-frame (open wall stubs). **1 peasant south of it**, outside the footprint. Red-flagged mine site bottom-right has no worker under it. |
| V1-1200 | 00:20:00 | `t_1200.png` | **Multiple concurrent unfinished sites** (left + centre wall stubs, red ghost church). No peasant resolved inside any wall rectangle; the visible peasant (bottom-left panel "Peasant - England") is off-site. Confirms sites sit as open stubs/scaffold, not filled with workers. |
| V2-060 | 00:01:00 | `t_60.png` | Top-left unfinished mine pit: **~4 peasants spaced around the rim**, outside the dark pit, on grass. Distributed around circumference, not stacked. |
| V2-300 | 00:05:00 | `t_300.png` | Unfinished tower foundation centre-bottom (open octagon). **1 peasant at west edge**, outside the wall, on the dirt rim. Not inside, not under anything. |
| V2-600 | 00:10:00 | `t_600.png` | Two tower foundations (bottom-left, centre). **1 peasant each, SW/outside the wall line**, on grass. Infantry column nearby is separate, not building. |
| V2-1200 | 00:20:00 | `t_1200.png` | Centre unfinished tower with visible **scaffold frame; interior is empty**, no worker under it. Long wall segment right has peasants **alongside/outside**, not on the wall line. |

Negative checks: V1 `t_300.png` (00:05:00, mountains) and V2 `t_900.png` (00:15:00, market/mills) contain no active construction and were not counted. No sampled frame shows a peasant standing inside a wall rectangle or under scaffold planks. Counts are visual (small figures at 720p); "≈5" and "1" carry that resolution caveat but the inside/outside classification is unambiguous at full-frame + crop scale.

Summary table:

| Question | Donor answer [O] |
|---|---|
| Ring vs single side | Arc when crew >1 (V1-060: 2+ sides); single side when 1 worker (V1-120, V2-300, V2-600, V1-900) |
| Distance | On/just outside paving/dirt rim, ~1 peasant-width beyond wall stubs |
| Under scaffold / overlap footprint | **Never observed** in 8 construction frames |
| How many | 1 typical (tower/mine); ~4 (V2 mine rim); ~5 (V1 blacksmith, largest site) |

## 2. Current port behavior (from source, not from play)

- **Assignment:** `game.gd:place_building` (4434–4498) refuses a human site with zero builders, then sends up to `Data.MAX_BUILDERS_SENT = 8` (`data.gd:51`) selected peasants via `cmd_build` (3649–3654: sets `order={type:build,target:site.id}` only, no slot chosen there).
- **Per-tick stand:** `"build"` tick (`game.gd:5480–5514`) computes per builder per tick `slot_b = _work_slot(e, site.pos, block_r + 0.7)` (line 5487), walks until `d <= 0.6` (line 5489), then faces site and hammers (`BUILD_HIT_INTERVAL = 1.25`, `BUILD_PROGRESS_PER_HIT` at `data.gd:63–64`). Comment at 5485–5486 intends the crew to "ring the foundations".
- **Slot hash:** `_work_slot` (5195–5205):
  ```gdscript
  var ang := float(e.id) * 2.399963 + center.x * 0.13 + center.y * 0.07
  var rr := ring_r + float(e.id % 3) * 0.35
  var p := center + Vector2(cos(ang), sin(ang)) * rr
  if in_bounds(p) and not is_blocked(p): return p
  var p2 := center - Vector2(cos(ang), sin(ang)) * rr   # opposite side
  if in_bounds(p2) and not is_blocked(p2): return p2
  return center   # <-- walks builder INTO the site centre
  ```
  The golden-angle hash (`id * 2.399963`) is **deterministic, no RNG draw** — that property must be kept (seed-byte stability). The `id % 3` term staggers 3 sub-rings. So the port already spreads builders around the full circle (more ring-like than the donor arc), which is acceptable directionally.
- **Blocking inputs:** `spawn` (2662–2685) stores `block_r` from `bld_block_r` (1884–1889: visual-ink radius when known, else `def.radius`) as a stamped circle, plus the full sprite ink box as `block_rect` (1894–1929, stored 2676–2679) consulted as a dynamic obstacle by `_blocked_for`/A* — but `_work_slot` tests only `is_blocked(p)` (terrain grid), **not** `_blocked_for` with the building rect. A slot can therefore test "free" while standing inside the drawn footprint/scaffold.
- **Failure mode [D]:** when both `p` and `p2` test blocked (common on a large ink rect: opposite side is also inside/behind the rect), the fallback `return center` orders the peasant onto `site.pos` itself — i.e. **inside the walls / under the scaffold**, exactly what no donor frame shows. Secondary effect: per-tick recompute with the same hash means a builder whose slot is momentarily judged blocked oscillates; and because the check ignores `block_rect`, a builder can be told to stand where the drawn scaffold is.
- **Presentation only:** `world3d_entities.gd:360–379` builds stage meshes (`floor(progress*4)` → suffix 1..4) plus a stage-synced scaffold auto-child (`<sid>a`); mirrors only, never written back to the sim. Standing "under the scaffold" is therefore a **sim slot** defect, not a scaffold-art defect. No change needed there.

## 3. Smallest game.gd-only recommendation (preserves RNG and gameplay)

Constrain to `_work_slot` + its call context; no `data.gd`, no `world3d_entities.gd`, no RNG/plumbing change:

1. **Keep the primary candidate exactly as-is** (golden-angle hash + `(id % 3) * 0.35` stagger at `block_r + 0.7`): preserves deterministic per-builder spread and default-seed byte stability. Still call it with the existing `block_r + 0.7` argument from the `"build"` tick and the repair tick (line 5448).
2. **Test candidates with the same obstacle query the pathfinder uses** — replace `is_blocked(p)` with `_blocked_for(probe, p)` using a peasant probe (`{"def":{},"order":{}}` as in `_spawn_slot`), so `block_rect` + stamped circle both reject interior slots. This alone moves stands off the drawn scaffold without touching radii.
3. **Delete the `return center` fallback.** Replace with a bounded deterministic outward scan reusing existing helpers: 16 angles × rings `rr, rr+1.0, rr+2.0 …` (same fixed 16-direction lattice as `_snap_free_point`, 5209–5219), first candidate passing `_blocked_for`; absolute last resort is the builder's current position (stay, do not enter). No new RNG: iterate angles starting from the builder's own hash angle so distribution is unchanged when the primary is free.
4. **Do not change:** `MAX_BUILDERS_SENT`, `BUILD_HIT_INTERVAL`, `BUILD_PROGRESS_PER_HIT`, `block_r`/`block_rect` computation, scaffold/stage art, or the per-tick recompute. Donor shows ≤5 workers but the cap of 8 is a gameplay allowance, not a visual defect — leave it.

Expected result: builders occupy distinct points on/just outside the footprint on whatever sides their hash assigns (arc-to-ring spread, consistent with V1-060's multi-side spread and V1-120/V2-300's single-side single-worker cases which fall out naturally when only one builder is sent); no builder is ever ordered inside the wall rectangle or under the scaffold; seed behavior unchanged because no RNG call is added or removed.

## 4. UNVERIFIED / open items

| ID | Item | Why unresolved |
|---|---|---|
| VB-U1 | Exact donor stand-off in metres | Third-party 720p video; unknown map/camera/zoom; pixel gaps are direction only |
| VB-U2 | Donor slot-assignment rule (clocked vs free) | Video shows positions, not the assignment algorithm; port hash is a PORT APPROXIMATION |
| VB-U3 | Whether donor caps builders per site | Max seen here is ~5 (V1-060); absence of 8 is not proof of a cap |
| VB-U4 | Wall/gate (`wal`/`gat`) unfinished stands | Sampled frames show houses/towers/mines; wall-line stands not sampled |

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Donor builders stand outside the footprint, never under scaffold | [O] — §1 frames |
| 2 | Multi-worker sites use 2+ sides/arc; single workers stand on one side ~1 width out | [O] — V1-060 vs V1-120/V2-300/V2-600 |
| 3 | Counts: 1 typical, ~4–5 max observed in samples | [O] — resolution caveat noted |
| 4 | Port `_work_slot` can return site centre (trapped/under-scaffold) | [O] — game.gd:5195–5205 |
| 5 | Port slot test ignores building `block_rect` | [O] — `is_blocked` vs `_blocked_for` |
| 6 | Recommended fix is game.gd-only, RNG-preserving | [D] |
| 7 | No donor parity, threshold or gate PASS is claimed | [U] |

*End of VIDEO-BUILDER-STANDS. Exactly one repository file written: this report.*
