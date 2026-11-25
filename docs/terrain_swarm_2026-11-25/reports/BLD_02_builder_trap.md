---
id: BLD-02
owner: BLD-02 (Wave BLD — builder-trap audit)
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
status: COMPLETE — READ-ONLY audit; no code edits, no runner jobs, no Godot launch
scope: "Trace builder assignment + work-slot pathing during construction in variant3d and identify why a peasant ends up inside the building mesh and stalls. One output file only."
labels: [OBSERVED, DERIVED, UNVERIFIED]
inputs:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (Wave BLD)
  - docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md
  - docs/coord_swarm_2026-11-25/reports/DBUILD_02.md
  - docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md
output: "this report only"
---

# BLD-02 — Why construction traps its builders inside the mesh and stalls

Owner report (WAVE_G_CHARTER.md:173): *"during building it traps builders inside and they
cannot finish it — avoid builders being trapped in the building mesh during build; they
can walk only around."*

All line numbers below are from the current tree. No Godot run, no runner submission, no
file other than this report was written. Donor facts are carried from DBUILD-01/02 and are
**not** re-derived here; every port claim cites a file:line.

---

## 1. Bottom line (DERIVED from code + arithmetic)

There are **two distinct faults**, both in `variant3d/scripts/game.gd`, and neither is a
"missing collision for the construction stage":

1. **Inside the mesh** — the sim blocks a building at `spawn()` with a circle of
   `block_r` (game.gd:2481-2489), but for **mines** `block_r = def.radius = 1.6 m**
   (data.gd:1342-1347; game.gd:1883-1888) while the 3D mine mesh is **~15 × 15 m**
   (manifest.json:1323-1330; world3d_entities.gd:1110-1153, `_bake_mesh` :1054-1107).
   The 3D stage implementation reuses the **full base mesh** during construction
   (BUILD_STAGES_01.md:19-24, :84-93; world3d_entities.gd:1872-1881). Every builder work
   slot (game.gd:5191 → `_work_slot` :4899-4909, ring radius 2.3–3.0 m) therefore sits
   **well inside the drawn mesh**. "Inside the mesh" is a collision-vs-art radius
   mismatch, not an absent collision.

2. **Stall / cannot finish** — `_work_slot` has a `return center` fallback at
   game.gd:4909. When both trial ring points land on blocked cells it returns the
   **building origin**. The build order then walks toward that blocked centre with
   `giveup = false` (game.gd:5195), so `_step_move` never snaps the destination
   (game.gd:4798-4799), A* snaps the *path* goal to a perimeter cell and refuses to
   append the blocked target (game.gd:4784-4786; nav.gd:80-102), arrival is measured
   against the raw centre (game.gd:4849-4850), build hits never fire (game.gd:5193,
   :5204-5217), and after 8 s of "boxed in" the order is cancelled (game.gd:4891-4893,
   :5196-5199). The peasant is left walking around the footprint with an unfinished
   site. This is intermittent because the fallback is angle/id dependent (DERIVED:
   ~1 in 6 builder ids at a mine centred on a tile corner).

---

## 2. Build-start → builder assignment (the `_unit_OrderBuild` analogue)

| Step | Code | Label |
|---|---|---|
| Ghost validity; mine must be on a deposit | `game.gd:4032-4104` `can_place`; mines short-circuit at `:4038-4061` | OBSERVED |
| Mine site is **snapped to the deposit centre** | `game.gd:4153-4157` — `pos = n.pos` when `n.pos.distance_to(pos) < MINE_SITE_RADIUS` (`MINE_SITE_RADIUS = 4.0`, `:19`) | OBSERVED |
| Human site requires ≥1 selected peasant; no auto-sweep | `game.gd:4161-4171` | OBSERVED |
| Site entity created unfinished | `game.gd:4181` `spawn(sid, player, pos, false)` | OBSERVED |
| Builders assigned (max `MAX_BUILDERS_SENT = 8`, data.gd:51) | `game.gd:4192-4201` → `cmd_build(u, b)` | OBSERVED |
| Order analogue of `_unit_OrderBuild` | `game.gd:3353-3358` `cmd_build`: `_leave_building(e)`, `e.order = {"type":"build","target":site.id}`, `e.moving = true` | OBSERVED |
| Secondary path: gathering at a deposit whose mine is unfinished is converted to a **build order**, not a gather-wait | `game.gd:3323-3329` (T-MINE-BUILD fix); old behaviour froze the site at ~80 % build time | OBSERVED |
| Separate "wait for builders" gather path has a 60 s timeout | `game.gd:5537-5546` | OBSERVED |

**On the "spawn offset" hypothesis:** no builder is spawned inside a building. What
*does* happen is the inverse — the site is snapped onto the deposit (`game.gd:4155-4157`)
where peasants may already be standing at `_work_slot(node.pos, node.radius + 1.1)`
(`game.gd:5606`). Once the site appears, those peasants are inside its drawn footprint.
Label: **DERIVED** (both code paths observed; no capture).

---

## 3. Collision and nav during construction

### 3.1 Collision is present from the first tick (refutes "missing construction collision")

- `game.gd:2428-2506` `spawn()` is shared by finished and unfinished buildings.
- `game.gd:2481-2489`: `bld_block_r(e)` → `e["block_r"]` → `set_blocked_circle(pos, br, true)`
  is executed **unconditionally** on `finished`.
- `game.gd:2490-2498`: a "taller 2D ink box" `block_rect` is also stored for every
  sprite-drawn building (not stamped into `blocked`; consulted dynamically).
- `game.gd:2513-2536` `_on_building_finished()` changes no radius and re-stamps nothing —
  only `bld_dirty += 1`. So the construction footprint **equals** the finished footprint.

Label: **OBSERVED**.

### 3.2 The circle is quantized to a square; mines have no ink box

- `game.gd:16` `TILE = 2.0`; `game.gd:529-532` `is_blocked(p)` tests one tile;
  `game.gd:544-557` `set_blocked_circle` marks a tile when its **centre** is within `r_m`.
- For a mine (`r = 1.6`, centre at a tile corner) only the four cells centred at
  `(±1, ±1)` are marked, i.e. a **4 × 4 m blocked square**, not a 1.6 m disc.
- `game.gd:1883-1888` `bld_block_r`: mines/walls/gates/procedural fallbacks have
  `bld_rm() = 0`, so `block_r = def.radius = 1.6` (data.gd:1342-1347).
- `game.gd:1890-1928` `bld_block_rect_for` requires a `buildings.json` key; that file has
  **no `mine` key** (verified by literal scan, 215,874 chars), so a mine's `block_rect`
  is empty → no ink rect, and `_nav_gate_cells` adds nothing for mines
  (`game.gd:4697-4722`, `live_blds` includes unfinished sites).

Label: **OBSERVED** (code + file scan); 4 × 4 m square is **DERIVED** arithmetic.

### 3.3 Nav does *not* ignore the unfinished building

- `nav.gd:154-243` `find_path` uses the shared `blocked` array plus `extra` cells; both
  include the unfinished site. `nav.gd:80-102` `_nearest_open` snaps a blocked goal to the
  nearest open cell.
- `game.gd:4756-4791` `_nav_repath`: line-clear short-circuit is skipped when the goal is
  blocked; otherwise A* runs and the raw target is appended **only if** it is free and
  line-clear (`:4784-4786`).
- `game.gd:4793-4894` `_step_move`: destination snapping `dest = _snap_free_point(...)`
  happens **only when `giveup == true`** (`:4798-4800`). The 13-direction probe loop
  (`:4865-4890`) uses `_blocked_for`, and "boxed in" increments `stuck_t` (`:4891-4893`).

Label: **OBSERVED**. The "nav ignoring unfinished building" hypothesis is **REFUTED**:
nav sees it; the problem is that the work slot itself is placed inside/onto it.

### 3.4 The one nav exception — builder vs its own ink rect

`game.gd:214-251` `_blocked_for`:

- `:221-222` — `is_blocked(p)` (the circle) is checked **first and unconditionally**;
- `:227-230` — `build_target` is read from the unit's `build` order;
- `:237-244` — for that one building's `block_rect`, `continue` (i.e. the builder may
  walk through its **own site's ink box**).

Consequences (**DERIVED**):
- the circle is **never** skipped, so a builder cannot enter the blocked square;
- for nation/sprite buildings the ink box extends beyond the circle, and the skip lets a
  builder cross into the visible mesh; `_nav_line_clear` (`:4728-4739`) uses `_blocked_for`,
  so the A* short-circuit at `:4770` can authorise a straight walk through that mesh.

---

## 4. The work slot and the stall chain

### 4.1 `_work_slot` (game.gd:4896-4909)

```gdscript
var ang := float(e.id) * 2.399963 + center.x * 0.13 + center.y * 0.07
var rr := ring_r + float(e.id % 3) * 0.35
var p := center + Vector2(cos(ang), sin(ang)) * rr
if in_bounds(p) and not is_blocked(p): return p
var p2 := center - Vector2(cos(ang), sin(ang)) * rr
if in_bounds(p2) and not is_blocked(p2): return p2
return center                       # <-- line 4909: snap to the building origin
```

`is_blocked` here is the **circle/tile grid only** — it does not test the ink box and does
not use `_blocked_for`. Label: **OBSERVED**.

### 4.2 Concrete mine calculation (DERIVED, arithmetic only — no Godot)

With centre at origin, `r = 1.6`, `TILE = 2`, `ring_r = 1.6 + 0.7 = 2.3`:

- candidate radii are 2.30 / 2.65 / 3.00 m (`id % 3`);
- diagonal candidates at 2.30–2.65 m fall back into the marked `(0,0)` / `(-1,-1)`
  cells; the opposite candidate is also blocked; **`return center` fires**;
- deterministic golden-angle scan over ids 1…60: **10/60 ids snap to the building
  origin**, the rest get a ring point at 2.3–3.0 m.

So the "snap-to-centre" hypothesis is **CONFIRMED in code and reachable in arithmetic**,
but it is **id/angle dependent**, which explains why the bug looks intermittent.

### 4.3 Stall sequence (DERIVED from :5184-5218 + :4793-4894 + nav.gd:80-102)

1. `game.gd:5191` computes `slot_b = _work_slot(e, site.pos, site.block_r + 0.7)`;
   for the unlucky ids `slot_b == site.pos` (§4.2).
2. `game.gd:5193` sees `d > 0.6`; `:5195` calls `_step_move(e, slot_b, speed, dt, 0.35)`
   with **default `giveup = false`**.
3. `game.gd:4798-4799` therefore keeps `dest = slot_b` (blocked centre).
4. `game.gd:4770` line-clear fails; A* runs; `nav.gd:166-167` `_nearest_open` moves the
   goal to a perimeter cell; `game.gd:4784-4786` refuses to append the blocked raw
   target. The path ends **outside** the footprint.
5. The peasant reaches that perimeter cell, but `d_goal` in `game.gd:4849` is measured to
   the **raw centre**, so arrival never satisfies `:4850` or the 0.6 m work gate at
   `:5193`.
6. Every one of the 13 probes at `game.gd:4865-4872` points back into the blocked square
   → `:4891-4893` sets `e.moving = false` and grows `stuck_t`.
7. `game.gd:5196-5199` cancels the build order at `stuck_t > 8.0`. `site.progress` and
   `site.hp` were never advanced (`game.gd:5204-5217`). The site stays unfinished and
   the peasant is left walking around it — exactly the owner's description.

Note: `game.gd:5206-5211` deliberately speeds progress (`BUILD_PROGRESS_PER_HIT * 1.5`,
`data.gd:63`) so a single peasant can finish in the scripted window. That tuning cannot
compensate for a builder that never reaches the 0.6 m work gate. Label: **DERIVED**.

---

## 5. Why the peasant is *visually* inside the mesh

- `world3d_entities.gd:1551-1593` `_xf()` places every entity at `_world_pos(ed.pos)` —
  **no offset and no snap-to-centre** between sim origin and mesh origin. `add_building()`
  at `:1645-1683` uses that transform for the `Building_<sid>_<id>_STATIC_POSE` node.
  Label: **OBSERVED** (the "mesh offset" hypothesis is **REFUTED**).
- `world3d_entities.gd:1851-1934` `_sync_building_stages()` swaps `mi.mesh` for the
  stage mesh but never changes the transform; the scaffold child has identity local
  transform (`:1906-1913`). BUILD_STAGES_01.md:19-24, :84-93 states that **no stage or
  scaffold OBJ exists on disk**, so every unfinished building displays its **full base
  mesh** (`source = "base_mesh_port_approximation"`, `world3d_entities.gd:1880`).
  Label: **OBSERVED**.
- `manifest.json:1316-1330` mine bbox X `[-7.14, +7.88]`, Z `[-7.91, +7.91]`; the OBJ
  vertex range was independently read as the same numbers (1,065 verts).
  `world3d_entities.gd:1126-1130`: for `kind == "building"` the env factor is **1.0**, so
  `scale = 1.0`; `_bake_mesh` (`:1054-1107`) only re-centres X/Z and grounds Y. The drawn
  mine is therefore ~15 × 15 m, centred on `e.pos`.
- Sim collision for that same mine is a 4 × 4 m blocked square (§3.2). Builder work slots
  at 2.3–3.0 m, and unlucky ids at 0 m, are all inside the ~7.5 m visual radius.
  Label for geometry: **OBSERVED**; for the comparison: **DERIVED**.
- Visual result on screen: **UNVERIFIED** — no capture, no Godot run (G04 owns the runner).

---

## 6. Verdict on the four candidate causes

| Candidate | Verdict | Evidence |
|---|---|---|
| Spawn offset | **NOT the cause** (as stated). Inverse mechanism only: the site is snapped onto the deposit where peasants stand. | `game.gd:4153-4157`, `:5606`; DERIVED |
| Missing collision for construction stage | **REFUTED**. Full footprint is stamped at `spawn()` for unfinished sites and unchanged on finish. The defect is collision **too small for the art** on mines (1.6 m vs ~7.5 m). | `game.gd:2481-2489`, `:2513-2536`, `:1883-1888`; manifest.json:1323-1330 |
| Nav ignoring unfinished building | **REFUTED**. Nav reads the same `blocked` grid, which includes the site. Only the builder's own *ink rect* is skipped, never the circle. A* also cannot append a blocked goal. | `nav.gd:154-243`, `:80-102`; `game.gd:214-251`, `:4756-4791` |
| Snap-to-centre | **CONFIRMED** — `_work_slot` `return center` at `game.gd:4909`; reachable for ~1/6 mine builder ids; produces the stall chain in §4.3. | `game.gd:4899-4909`, `:5191-5199`; arithmetic §4.2 |

Cross-ticket note: the ~2× mine *ghost* footprint mismatch is BLD-01's scope; this report
only measures the placed construction mesh vs the builder work radius.

---

## 7. Minimal fix proposal (NOT applied — for BLD-03 / COORD grant)

Goal: every builder stops **outside** the drawn footprint and A*/steering walks it
**around**, with no change to art, data, or completion logic.

**Hunk 1 — remove the snap-to-centre and search outward.** `game.gd:4899-4909`
`_work_slot()`: replace the two-point trial + `return center` with an outward ring scan
that validates against a **neutral probe** (no `build` order, so the `build_target` skip at
`:241-242` cannot admit a point inside the site's own ink box):

```gdscript
func _work_slot(e: Dictionary, center: Vector2, ring_r: float, footprint_r := -1.0) -> Vector2:
	var probe: Dictionary = {"def": e.def, "order": {}}   # neutral: own-site rect stays solid
	var fr: float = maxf(footprint_r, ring_r - 0.7)
	for k in 16:
		var a := TAU * float(k) / 16.0
		for ext in [0.0, 1.0, 2.0, 4.0]:
			var rr: float = maxf(fr + 0.6, ring_r) + ext + float(e.id % 3) * 0.35
			var p: Vector2 = center + Vector2(cos(a), sin(a)) * rr
			if in_bounds(p) and p.distance_to(center) >= fr + 0.6 and not _blocked_for(probe, p):
				return p
	return center + Vector2(1.0, 0.0) * (fr + 4.0)   # never the origin
```

**Hunk 2 — give the work ring the *visual* radius, not `block_r`.** At `game.gd:5191`
(and the repair analogue at `:5152` if desired), pass the footprint:

```gdscript
var slot_b := _work_slot(e, site.pos, float(site.get("block_r", site.def.radius)) + 0.7,
		float(site.get("footprint_r", site.get("block_r", site.def.radius))))
```

with `footprint_r` recorded once in `spawn()` (`game.gd:2481-2489`) as `bld_block_r(e)`
for sprite-drawn buildings and, for mines, the manifest-bbox half-extent
(`max(|x|, |z|) ≈ 7.9 m` from manifest.json:1323-1330). This is a stored scalar only —
it does **not** alter `blocked`, `can_place`, or the ghost. (If COORD prefers zero data
changes, a mine-specific constant at the call site is equivalent; label it PORT APPROX.)

**Hunk 3 (recommended, optional) — stop letting a builder cross its own site.**
Narrow/remove the `build_target` `continue` in `_blocked_for` (`game.gd:227-242`) now that
Hunk 1 guarantees builders start outside. Then A* and the 13-probe steering treat the
unfinished site as a normal obstacle and literally "walk around" it. Do **not** do this
alone: without Hunk 1 it would freeze any builder already inside.

No change needed in `nav.gd`: `_nearest_open` (`nav.gd:80-102`) already routes a blocked
goal to a perimeter cell once the work slot is outside. No change needed in
`world3d_entities.gd`: the mesh is correctly centred on the sim origin.

---

## 8. Labels and open questions

- **OBSERVED** — all cited file:line reads, the manifest/OBJ bbox, the `buildings.json`
  "no mine key" scan, the 1.6 m mine radius, the 2.0 m tile, and the unconditional
  collision stamping in `spawn()`.
- **DERIVED** — the 4 × 4 m quantized blocked square; the ~1/6 id snap-to-centre rate;
  the stall chain of §4.3; the ~7.5 m visual radius vs 2.3–3.0 m work ring; all fix
  consequences.
- **UNVERIFIED** — on-screen appearance of the trap; whether the ~15 m visual mine is
  intended art (the BLD-01 footprint ticket owns that question); runtime F2 ordering of
  `set_build_ghost_pos()` vs `world.sync()` carried from DBUILD-01 §8 Q5; any donor parity
  claim. **No Godot run, no runner job, no donor execution** occurred for this ticket.

*End of BLD-02 report. Read-only audit; the only repository file written is this report.*
