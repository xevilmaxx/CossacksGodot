---
id: F2-03
ticket: "WAVE F2 — mill-field enlargement + four-patch quad layout + reject-on-overlap"
swarm: TERRAIN-SWARM-WAVE-G / WAVE F2
owner: F2-03 read-only proposal subagent
created: 2026-11-25
status: PROPOSAL ONLY — READ-ONLY — NO CODE EDIT, NO RUNNER, NO GODOT
outputs: [docs/terrain_swarm_2026-11-25/reports/F2_03_fields_fix.md]
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
parity_guard: "PORT APPROXIMATION — NON-DONOR spacing constants below are port choices. No donor GPU A/B frame exists. Donor parity stays UNVERIFIED (CHARTER §3)."
owner_directives:
  - "'mill fields, make them bigger so they come in contact with each other'"
  - "'also mill fields, dispose them in quad all around the mill'"
  - "'if some mill fields overlap with existing buildings or maybe stones, just avoid spawning them at all'"
---

# F2-03 — mill-field quad layout, enlargement and rejection gate (ready-to-apply proposal)

## 0. Verdict in one paragraph

**OBSERVED:** `_sow_field_ring()` (`variant3d/scripts/game.gd:2528-2566`) still sows a
7×7 rotated lattice and rejects candidates within `1.5 * TILE = 3.0 m`
(`:2554`) of **any** `food` node — including fields sown earlier in the same loop.
F2-01 (`:103-108`) derived that this leaves a 3.3962 m minimum centre spacing while
the 3D footprint is only 2.4015 m (`world3d_entities.gd:266-273`, `:2199-2202`,
`:2242-2247`), so fields cannot touch; and the per-stage `rel` factor
(`:2223-2239`) shrinks XZ further whenever growth < 1. **PROPOSED (PORT APPROX):**
replace the 49-site lattice with **exactly four patches at fixed N/E/S/W offsets
of 7.2 m** from the mill centre, each an axis-aligned **7.3 m square** (a 0.10 m
square overlap = 0.141 m along the 45° contact line at each inner corner); keep
the footprint at full span for **every** growth stage and let only stalk height
follow `rel`. **PROPOSED hard rule:** a candidate whose footprint touches a live
building `block_rect`, a stone/wood/ore/food node, a blocked/rock/water/shore/road
tile, or the rotor/mill central clearing is **skipped outright** — never nudged,
never shrunk. No RNG draw is added anywhere. **UNVERIFIED:** no visual result —
this ticket ran no Godot and produced no capture; every pixel claim is a gate for
G04/F2-05, not a measured outcome.

---

## 1. Authority, scope and file ownership

- Read first: `docs/terrain_swarm_2026-11-25/CHARTER.md` (§3 guardrails, §5 gates)
  and `WAVE_G_CHARTER.md` (standing rule :31 — **only G04 runs Godot**; Wave F2
  :126-141 — all F2 read-only until COORD grants ownership).
- Sibling reports read: `F2_01_mill_fields_audit.md`, `M01_mill_rotor_audit.md`,
  `F2_05_qa.md`, `F2_04_mine_snap.md`, and — landed while this report was being
  authored — `F2_02_donor_fields_mines.md`. Donor field geometry below is
  reconciled with F2-02 §3.3/§5 (see §9 item 3): F2-02 reports a donor-grounded
  **49-node 7×7 cluster** with `size = 1.6981` *map cells*, `1.3×` decal scale
  and `1.528`-cell food clearance. The owner's quad directive overrides the
  node count; the four-patch decomposition is therefore explicitly **PORT APPROX**.
- **Live-tree warning:** `variant3d/scripts/game.gd` was edited by another owner
  while this report was authored; all `game.gd` line numbers below were re-checked
  against the tree *at final-write time* (P-50 block now `:2517-2526`, sower
  `:2528-2566`). Re-verify with `grep -n "func _sow_field_ring"` before applying;
  if the line numbers have moved again, use the context lines, not the `@@` offsets.
- **This report is the only file written.** No `.gd`, asset, config, test, fixture,
  gate or result JSON was edited. No `inbox/backup/*` was created (no edit occurred).
- **Files COORD must grant exclusively after G04 finishes:**
  1. `variant3d/scripts/game.gd` — F2-03 owns the sim seeding function and the new
     helper. **F2-04 also proposes `game.gd` (mine snap at `place_building`
     `:4136-4160` in the current tree); the hunks are disjoint (`:2517-2566` vs
     `:4136-4160`) but COORD must serialise the two grants, not run them
     concurrently.**
  2. `variant3d/scripts/world3d_entities.gd` — F2-03 owns only constants
     `:266-273` and the field part of `sync()` `:2190-2253`. This file is a shared
     contest with **M03** (rotor: `:247-253`, `:1685-1782`, `:2153-2188`) and **P11**
     (batches: `:1400-1472`, `:1506`, `:2271`). F2-03 does **not** touch any rotor
     or batch line; COORD merges, with `FIELD_SPAN_M` kept as an alias so P11's
     `_field_visual["color"]` consumer stays valid (P11 proposal :185-192).
- **Explicitly NOT owned / NOT edited:** `variant3d/scripts/winter_field_decal.gd`
  (authoring-only, inert — `:1-5`), `variant3d/scripts/world.gd`,
  `app/scripts/**` (2D `app/` gate stays untouched), `manifest.json`, all tests.
- **No donor parity claim.** All new spacing numbers are labelled PORT APPROX.

---

## 2. Evidence used (all read-only)

| # | Fact | Source | Label |
|---|---|---|---|
| E1 | Field nodes are `food` resources created **only** by `_sow_field_ring`; 7×7 rotated sites, `step = 1.6981 * TILE * 0.5 = 1.6981 m`, clash `1.5 * TILE = 3.0 m` vs `food/wood/stone` | `game.gd:2517-2566`, `:575-587` | OBSERVED |
| E2 | Minimum accepted spacing 3.3962 m vs 3D footprint 2.4015 m → ~0.995 m gap; growth `rel` makes it worse | F2-01 `:103-108` + `world3d_entities.gd:270`, `:2223-2242` | DERIVED |
| E3 | Donor field mesh bbox x span **58.51857 m**, y span 51.92523 m; `field` exempt from env scaling | `variant3d/assets/models/manifest.json:1601-1615`, `world3d_entities.gd:1127-1129` | OBSERVED |
| E4 | 3D scale = `FIELD_SPAN_M / native_span * rel`, uniform on X/Y/Z; ripe `rel=1` → 2.4015 m | `world3d_entities.gd:2199-2202`, `:2242-2247`, MILLFIX report `:94` | OBSERVED + DERIVED |
| E5 | Mill body has **no yaw**, donor front points local +X; rotor hub local `(0.173, 5.235, 0)` is mid-depth; billboarded sail half-span 6.352 m, local X extent `[-3.003, +3.349]` m | M01 `:20-34`, `:77-90`, `:139-148` | OBSERVED + DERIVED |
| E6 | Mill sim radius 2.0 m; `blocked` circle stamped at build; buildings also carry authored `block_rect` (mill `ukr_mil` ortho 6.627, ink `[44,18,277,320]`, cx 0.4989, foot 1.0) | `data.gd:1330`, `game.gd:2465-2468` (build stamp), `:1881-1909` | OBSERVED |
| E7 | Authoritative footprint sets: `_block_rects` `[Rect2,id]` cached by `bld_dirty`; `blocked` byte grid; `tileblock` names incl. road `test1/test2/test3`, `BLK_WATER=255`; resource spatial hash `_res_grid` | `game.gd:160-194`, `:43`, `:52-53`, `:523-566`, `:3084-3098`, `:1979-1980` | OBSERVED |
| E8 | `can_place` already refuses buildings on food/stone/wood (`"Cornfield - pick open dirt."`, `"Stone field - pick open dirt."`) and uses `my_r + n.radius` / `+0.3` | `game.gd:4030-4102` (esp. `:4080`, `:4086-4088`, `:4095`) | OBSERVED |
| E9 | Roads are walkable `terrain=1` + road tileblock; water `terrain=3`, shore `4`, cliff `5`; `_sow_field_ring` skips 3/4/5 but **not** roads | `game.gd:2368-2389`, `:2011-2020`, `:2547-2550`, F2-01 `:64`, `:68` | OBSERVED |
| E10 | No RNG draw in `_sow_field_ring`; `rng` is one continuous stream seeded once (`:259`); determinism-sensitive passes explicitly avoid extra draws | `game.gd:2528-2566`, `:259`, `:841-851` | OBSERVED |
| E11 | Donor screenshot shows a **rotated rectangular field with a square dirt clearing cut out for the mill**; decal alpha bbox 477×475 inside 512² (~93%), summer/winter pair existing on disk | `docs/audit/PIECES/field_crops.md:43-52`, `:90-97`, `:31-41`, `winter_field_decal.gd:64-68` | OBSERVED (screenshot/pixels) |
| E12 | QA atom A currently asserts ≥7 fields, min pairwise span ∈ [1.5, 3.6] m, `pairs >= 7` — incompatible with a four-patch quad | `F2_05_qa.md:88-92`, `:122-124`, `:448-449`, `:481-483` | OBSERVED (proposal text) |
| E13 | Mill mesh 3D half-extents ≈2.602 m (X) / 2.397 m (Z) after bbox centring | M01 `:79`, `:141-144`; `manifest.json:1202-1218` | DERIVED |
| E14 | `FIELD_MILL_RADIUS = 18.0 m` governs regrow adoption, not size | `game.gd:212`, `:2596-2610`; F2-01 `:117` | OBSERVED |
| E15 | F2-02 donor truth: 49 nodes at `size = 1.6981` **map cells**, 45° rotation, `1.3×` decal scale, food clearance `1.528` cells < spacing; one contiguous rectangle with a square mill clearing | `F2_02_donor_fields_mines.md:98-99`, `:198-220`, `:388-396` | OBSERVED (donor text / image crop) |

**INFERRED:** the owner's "quad all around the mill" matches E11's central dirt
clearing — four patches leave that clearing as a literal square hole. The
decomposition into four equal axis-aligned patches is a **port presentation
choice**, not a donor rule; donor 3-D field placement is **UNVERIFIED**.

---

## 3. Quad geometry — exact placement, contact, clearances

All numbers are in **sim metres** (`TILE = 2.0`, `game.gd:16`; sim `+X/+Y` map to
world `+X/+Z`, `world3d_fx.gd:809-818`). Mill centre = `mill.pos`.

| Patch | Centre offset from `mill.pos` | Footprint (axis-aligned) |
|---|---|---|
| South (toward default camera) | `(0, -7.2)` | x ∈ [−3.65, 3.65], y ∈ [−10.85, −3.55] |
| East | `(+7.2, 0)` | x ∈ [3.55, 10.85], y ∈ [−3.65, 3.65] |
| North | `(0, +7.2)` | x ∈ [−3.65, 3.65], y ∈ [3.55, 10.85] |
| West | `(−7.2, 0)` | x ∈ [−10.85, −3.55], y ∈ [−3.65, 3.65] |

Fixed evaluation/commit order is **S, E, N, W** (no RNG, no candidate search).

**DERIVED arithmetic (over the proposed constants):**

1. Patch side `S = 7.3 m`, half `h = 3.65 m`; offset `D = 7.2 m`.
2. Adjacent patch centres are `(±D, ±D)` apart → distance `√2·D = 10.182 m`.
   Opposite centres are `2D = 14.4 m` apart.
3. Combined half-extent along a 45° contact direction `u` is
   `2 · h(|u.x|+|u.y|) = 7.3·√2 = 10.325 m`.
   **Signed edge gap = 10.182 − 10.325 = −0.141 m** (i.e. a **0.10 × 0.10 m
   overlap square** at each inner corner, e.g. x,y ∈ [3.55, 3.65] between the
   north and east patches). Negative = contact with no visible seam.
4. Central dirt clearing = square of half-width `D − h = 3.55 m`.
5. Rotor clearance: `3.55 − 3.349 = 0.201 m` beyond the billboarded sail's
   ground projection (E5); mill 3-D mesh clearance `3.55 − 2.602 = 0.948 m`,
   `3.55 − 2.397 = 1.153 m` (E13). Mill `blocked` circle is 2.0 m (E6) → 1.55 m
   clear. The owning mill is excluded from the building `block_rect` test because
   that clearing is deliberate (E11); all **other** buildings are rejected.
6. Outermost extent `D + h = 10.85 m < FIELD_MILL_RADIUS 18.0 m`, so every patch
   still qualifies for regrow adoption and `cmd_sow` restoration (E14).
7. Growth independence: XZ scale stays `FIELD_SPAN_M / 58.51857` for ripe,
   growing, regrowing **and** depleted; only Y uses `rel` (`0.148…1.0`). This is
   what makes contact hold at *all* growth stages rather than only at `g=1` (E2).

### PORT APPROX label table — every non-donor spacing constant

| Constant | Value | Label | Basis / caveat |
|---|---|---|---|
| `FIELD_QUAD_OFFSET_M` | `7.2` | **PORT APPROX — NON-DONOR spacing** | chosen to clear the rotor ground projection (3.349 m) plus the 3.65 m half-patch; no donor metre value |
| `FIELD_QUAD_SPAN_M` | `7.3` | **PORT APPROX — NON-DONOR spacing** | h = 3.65 m gives a 0.10 m corner overlap; donor field bbox 58.51857 m is only the *source mesh*, not this span |
| `FIELD_QUAD_MARGIN_M` | `0.3` | **PORT APPROX** (reused, not invented) | mirrors `can_place`'s `+0.3` at `game.gd:4095` |
| `FIELD_QUAD_ROTOR_CLEAR_M` | `3.35` | **PORT APPROX** | derived from the donor-baked sail half-span 3.349 m (M01 `:144`); native 3-D axle geometry UNVERIFIED |
| `FIELD_STEP_M` | `1.6981` | **DONOR-CITED** (provenance only) | `unit.script:6475-6477` via F2-02 `:98`, `:176-179`; no longer drives placement |
| `SOW_ROW`, `SOW_GOLD` | `7`, `5` | **DONOR-CITED** | `unit.script:1691-1694`, `:6470-6570`; kept for cost/provenance |
| decal paths `envfieldd/w.png` | existing | **DONOR-CITED art, already shipped** | `decals.lib:37-44`, `decals.mat:110-115`, `winter_field_decal.gd:64-68`; no new art |

---

## 4. Rejection gate (owner hard rule) — order, data sources, determinism

`_field_quad_clear(mill, p, rect)` is a **pure read**. A patch that fails any
step is skipped: no position nudge, no size shrink, no gold charge, no `next_id`
consumption. Exact check order (also the order in the diff):

1. **Bounds** — both `rect.position` and `rect.end` via `in_bounds()` (`game.gd:523-524`)
   and a tile-index guard against `_t()` overflow.
2. **Central clearing / rotor** — constant `inner = 7.2 − 3.65 = 3.55 m` must be
   ≥ `FIELD_QUAD_ROTOR_CLEAR_M` (3.35). This is a pure constant test; the sail is
   never moved (M03 owns that separately).
3. **Per-cell terrain / water / shore / road / blocked** — iterate every tile
   overlapped by the 7.3 m rect via `tile_of()` (`:526-527`). Reject `terrain ∈
   {3,4,5}` (water / sand-shore / cliff, `:2549`), `blocked[i] != 0` (rock, forest,
   building circles; `:529-532`, `:544-557`, `:2465-2468`), `tileblock[i] ==
   BLK_WATER` (`:52`) or any road id resolved from `tbl_idx` for
   `test1/test2/test3` (`:1758`, `:1979-1980`, `:2011-2020`, `:2368-2389`).
   Road IDs are only compared when `tbl_idx` contains the name, so a stub with an
   empty name table cannot reject everything.
4. **Buildings** — `_block_rects_ensure()` (`:176-194`) then every non-dead
   `[Rect2,id]`; skip **only** `id == mill.id`; reject if
   `br.grow(0.3).intersects(rect)`. For any building with no authored `block_rect`
   (walls/gates/mines), fall back to a rect-vs-circle test with
   `block_r + 0.3` (`:1881-1888`, `:4095`). Nothing in `can_place`,
   `bld_block_rect` or `_block_rects` is written.
5. **Resources / stones** — `_res_grid_ensure()` (`:3084-3098`) over cells within
   `h + 2.5` m; skip `bush`/`stump` and depleted `max_hits!=0` nodes exactly as
   `can_place` does (`:4078-4082`). Reject any live `stone`, `wood`, ore
   (`max_hits==0`) or other mill's `food` whose radius + 0.3 intersects the rect
   (`:4080-4088`). Same-mill `food` nodes are skipped so a re-sow at an existing
   quad centre stays idempotent. **Stone is checked in the same pass as every
   other resource — the outcome is one boolean reject with no partial
   acceptance and no fallback size.**
6. **Gold** — only after all geometry checks; `pay_cost(...)` and `_add_res(...)`
   at `:2559-2562`.

**Deterministic RNG behaviour:** `_sow_field_ring()` and the helper contain **zero**
calls to `rng`, `gen_rng`, `randi*`, `randf*` or any seeded helper. The cached
`_res_grid_ensure()` / `_block_rects_ensure()` rebuilds also draw nothing
(`:176-194`, `:3084-3098`). A rejected candidate therefore leaves `rng.state`,
`gen_rng.state`, `next_id`, `res_nodes` and gold untouched — identical across
seeds for identical maps. `next_id` does shift **between builds** (four commits
instead of ~18), but deterministically; no parity with the old build is claimed.
A QA atom can assert `game.rng.get_state()` before and after
`_on_building_finished(mill)` is unchanged — see §7 gate 8.

---

## 5. Ready-to-apply unified diff (NOT applied)

Paths are relative to the workspace root. hunks use current-tree line numbers.

### 5.1 `variant3d/scripts/game.gd`

```diff
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -2517,10 +2517,17 @@
 # P-50: donor _unit_DoSeedWheat (unit.script:6470-6570). cRow=7 -> 7x7 grid
 # rotated 45 degrees (up to 49 tiles), size 1.6981 donor units; collision,
 # water and nearby resource skips (unit.script:6504-6548). Each field costs
 # 5 gold (unit.script:1691-1694) - paid per field here, no lump-sum inference.
 const SOW_ROW := 7
 const SOW_GOLD := 5
+# F2-03 PORT APPROX, NON-DONOR spacing (owner directive): four patches in a
+# fixed quad around the mill; a blocked patch is SKIPPED, never nudged/shrunk.
+const FIELD_QUAD_COUNT := 4
+const FIELD_QUAD_OFFSET_M := 7.2        # PORT APPROX: centre offset N/E/S/W
+const FIELD_QUAD_SPAN_M := 7.3          # PORT APPROX: axis-aligned patch side
+const FIELD_QUAD_MARGIN_M := 0.3        # PORT APPROX: mirrors can_place :4095
+const FIELD_QUAD_ROTOR_CLEAR_M := 3.35  # PORT APPROX: donor bake half-span 3.349 (M01 :144)
 # T-MILL-CORE: hard cap of mill-owned fields. The 7x7 rotated ring holds at
 # most SOW_ROW*SOW_ROW tiles; the clash check enforces it geometrically, but
 # the explicit cap keeps repeated 60 s re-seeds from ever stacking fields.
-const MAX_FIELDS_PER_MILL := 49
+const MAX_FIELDS_PER_MILL := FIELD_QUAD_COUNT
@@ -2528,39 +2535,104 @@
 func _sow_field_ring(mill: Dictionary) -> int:
 	if mill.is_empty() or str(mill.sid) != "mil" or not bool(mill.get("finished", false)):
 		return 0
 	var owned := 0
 	for n in res_nodes:
 		if n.has("mill") and int(n.mill) == int(mill.id):
 			owned += 1
 	if owned >= MAX_FIELDS_PER_MILL:
 		return 0
 	var player: int = int(mill.player)
 	var made := 0
-	var step := 1.6981 * TILE * 0.5
-	for r in SOW_ROW:
-		for c in SOW_ROW:
-			var rr := r - SOW_ROW / 2
-			var cc := c - SOW_ROW / 2
-			var p: Vector2 = Vector2(mill.pos) + Vector2(float(cc - rr), float(cc + rr)) * step
-			if not in_bounds(p) or is_blocked(p):
-				continue
-			var ti := _t(int(p.x / TILE), int(p.y / TILE))
-			var tt: int = terrain[ti]
-			if tt == 3 or tt == 4 or tt == 5:
-				continue
-			var clash := false
-			for n in res_nodes:
-				if n.type == "food" or n.type == "wood" or n.type == "stone":
-					if n.pos.distance_to(p) < 1.5 * TILE:
-						clash = true
-						break
-			if clash:
-				continue
-			if players[player].res[3] < float(SOW_GOLD):
-				break
-			pay_cost(player, {"gold": SOW_GOLD})
-			_add_res("food", p, 50, 0.6)
-			var f: Dictionary = res_nodes[res_nodes.size() - 1]
-			f["mill"] = mill.id
-			made += 1
+	# F2-03: exactly four patches, one per side, in a FIXED order. No rng draw
+	# and no candidate nudge: a rejected patch is skipped outright (owner rule).
+	var offsets: Array[Vector2] = [
+		Vector2(0.0, -FIELD_QUAD_OFFSET_M),
+		Vector2(FIELD_QUAD_OFFSET_M, 0.0),
+		Vector2(0.0, FIELD_QUAD_OFFSET_M),
+		Vector2(-FIELD_QUAD_OFFSET_M, 0.0),
+	]
+	var half := FIELD_QUAD_SPAN_M * 0.5
+	for off in offsets:
+		var p: Vector2 = Vector2(mill.pos) + off
+		var rect := Rect2(p - Vector2(half, half), Vector2(FIELD_QUAD_SPAN_M, FIELD_QUAD_SPAN_M))
+		if not _field_quad_clear(mill, p, rect):
+			continue
+		if players[player].res[3] < float(SOW_GOLD):
+			break
+		pay_cost(player, {"gold": SOW_GOLD})
+		_add_res("food", p, 50, 0.6)
+		var f: Dictionary = res_nodes[res_nodes.size() - 1]
+		f["mill"] = mill.id
+		made += 1
 	return made
+
+
+# F2-03 rejection gate for ONE quad patch. READ-ONLY: no terrain, blocked,
+# resource, building or rng state is written; a skip cannot shift the seed
+# stream. Fixed order: bounds -> rotor clearing -> tiles -> buildings ->
+# resources. The owning mill is excluded from the building test because the
+# central square clearing is deliberate (field_crops.md :90-97).
+func _field_quad_clear(mill: Dictionary, p: Vector2, rect: Rect2) -> bool:
+	if not in_bounds(rect.position) or not in_bounds(rect.end):
+		return false
+	var inner := FIELD_QUAD_OFFSET_M - FIELD_QUAD_SPAN_M * 0.5
+	if inner < FIELD_QUAD_ROTOR_CLEAR_M:
+		return false
+	var t0 := tile_of(rect.position)
+	var t1 := tile_of(rect.end)
+	if t0.x < 0 or t0.y < 0 or t1.x >= MAP_W or t1.y >= MAP_H:
+		return false
+	var road_ids: Array[int] = []
+	if tileblock.size() == MAP_W * MAP_H:
+		for rn in ["test1", "test2", "test3"]:
+			if tbl_idx.has(rn):
+				road_ids.append(int(tbl_idx[rn]))
+	for y in range(t0.y, t1.y + 1):
+		for x in range(t0.x, t1.x + 1):
+			var i := _t(x, y)
+			var tt: int = terrain[i]
+			if tt == 3 or tt == 4 or tt == 5:
+				return false
+			if blocked[i] != 0:
+				return false
+			if tileblock.size() == MAP_W * MAP_H:
+				var tb: int = tileblock[i]
+				if tb == BLK_WATER or road_ids.has(tb):
+					return false
+	_block_rects_ensure()
+	for br in _block_rects:
+		if int(br[1]) == int(mill.id):
+			continue
+		if (br[0] as Rect2).grow(FIELD_QUAD_MARGIN_M).intersects(rect):
+			return false
+	for b in live_blds:
+		if b.dead or int(b.id) == int(mill.id):
+			continue
+		var rr := float(b.get("block_r", (b.get("def", {}) as Dictionary).get("radius", 1.0))) + FIELD_QUAD_MARGIN_M
+		if not (b.get("block_rect", Rect2()) as Rect2).has_area():
+			var bp: Vector2 = b.pos
+			var q := Vector2(clampf(bp.x, rect.position.x, rect.end.x),
+				clampf(bp.y, rect.position.y, rect.end.y))
+			if q.distance_to(bp) <= rr:
+				return false
+	_res_grid_ensure()
+	var half := FIELD_QUAD_SPAN_M * 0.5
+	var fr := half + 2.5
+	var fc0 := Vector2i(int((p.x - fr) / RES_GRID_M), int((p.y - fr) / RES_GRID_M))
+	var fc1 := Vector2i(int((p.x + fr) / RES_GRID_M), int((p.y + fr) / RES_GRID_M))
+	for fcy in range(fc0.y, fc1.y + 1):
+		for fcx in range(fc0.x, fc1.x + 1):
+			for n in (_res_grid.get(Vector2i(fcx, fcy), []) as Array):
+				if str(n.get("type", "")) in ["bush", "stump"]:
+					continue
+				if int(n.get("hits", 0)) <= 0 and int(n.get("max_hits", 0)) != 0:
+					continue
+				if str(n.get("type", "")) == "food" and int(n.get("mill", -1)) == int(mill.id):
+					continue  # already-sown quad centre; idempotent re-sow
+				var nr := float(n.get("radius", 0.5)) + FIELD_QUAD_MARGIN_M
+				var np: Vector2 = n.pos
+				var q2 := Vector2(clampf(np.x, rect.position.x, rect.end.x),
+					clampf(np.y, rect.position.y, rect.end.y))
+				if q2.distance_to(np) <= nr:
+					return false
+	return true
```

### 5.2 `variant3d/scripts/world3d_entities.gd`

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -266,8 +266,11 @@
-# MILLFIX F2: field stage tints/scale are the EXACT 2D numbers from
-# app/scripts/world.gd:2588-2613; sow spacing is game.gd:2120 (1.6981 m,
-# diagonal neighbour sqrt(2)*step) replacing the 58.5 m donor field bbox.
-const FIELD_STEP_M: float = 1.6981
-const FIELD_SPAN_M: float = FIELD_STEP_M * 1.41421356237
+# MILLFIX F2: stage tints are the EXACT 2D numbers from app/scripts/world.gd:2588-2613.
+# F2-03 PORT APPROX, NON-DONOR spacing (owner directive): four patches in a quad
+# around the mill; offsets/span are port choices, NOT donor parity. The donor sow
+# step stays only as provenance (F2-02 :176-179; the old game.gd:2120 cite was stale).
+const FIELD_STEP_M: float = 1.6981                # donor cRow step, unit.script:6477 via F2-02
+const FIELD_QUAD_OFFSET_M: float = 7.2            # PORT APPROX: centre offset N/E/S/W
+const FIELD_QUAD_SPAN_M: float = 7.3              # PORT APPROX: axis-aligned patch side
+const FIELD_SPAN_M: float = FIELD_QUAD_SPAN_M     # alias: existing stats key unchanged
 const FIELD_DECAL_SUMMER: String = "res://assets/terrain/deco_png/envfieldd.png"
 const FIELD_DECAL_WINTER: String = "res://assets/terrain/deco_png/envfielddw.png"
-const FIELD_STATUS: String = PORT_LABEL + " — stage tint/scale from game.field_state()/field_growth01(); donor decal 3D UV mapping UNVERIFIED"
+const FIELD_STATUS: String = PORT_LABEL + " — F2-03 quad offsets/span are PORT APPROX non-donor spacing; stage tint from game.field_state()/field_growth01(); donor decal 3D UV mapping UNVERIFIED"
@@ -2190,6 +2193,7 @@
 	# MILLFIX F2: per-field visual state, read-only on the sim. game.field_state()
 	# / field_growth01() are the SAME methods the HUD and 2D renderer use
 	# (game.gd:2210-2228, world.gd:2550-2559). Tints and relative scales below
 	# are copied verbatim from the 2D stage rules (world.gd:2588-2613); the
-	# footprint replaces the 58.5 m donor bbox with the sow-step span
-	# (game.gd:2120). No res_nodes mutation, no res_dirty bump, no new node.
+	# footprint replaces the 58.5 m donor bbox with the PORT APPROX quad patch
+	# span (FIELD_QUAD_SPAN_M; sites at game.gd:2503). No res_nodes mutation,
+	# no res_dirty bump, no new node. XZ stays fixed; only Y follows `rel`.
@@ -2242,12 +2246,18 @@
-			var s := field_scale * rel
+			# F2-03: footprint stays at the full 7.3 m patch span at EVERY stage,
+			# so the four patches keep their shared contact while growing;
+			# only stalk height (Y) follows the 2D stage factor `rel` (:2223-2239).
+			var sxz := field_scale
+			var sy := field_scale * rel
 			var xf: Transform3D = _xf(fid)
-			xf.basis = xf.basis.scaled(Vector3(s, s, s))
+			xf.basis = xf.basis.scaled(Vector3(sxz, sy, sxz))
 			xforms[i] = xf
 			mm.set_instance_transform(i, xf)
 			mm.set_instance_color(i, col)
-			_field_visual[fid] = {"state": st, "color": col, "scale": s}
+			_field_visual[fid] = {"state": st, "color": col, "scale": sy, "scale_xz": sxz}
 	stats["field_visual_states"] = field_states
 	stats["field_visual_count"] = field_total
 	stats["field_visual_span_scale"] = field_scale
 	stats["field_visual_target_span_m"] = FIELD_SPAN_M
+	stats["field_visual_quad_offset_m"] = FIELD_QUAD_OFFSET_M
+	stats["field_visual_quad_span_m"] = FIELD_QUAD_SPAN_M
 	stats["field_visual_label"] = FIELD_STATUS
```

**Diff notes for the applier:** `field_scale` at `:2199-2202` is intentionally
unchanged — it reads the `FIELD_SPAN_M` alias, which now equals
`FIELD_QUAD_SPAN_M`. `_xf()` (`:1551-1593`) leaves resource yaw at 0, so the
independent XZ/Y basis scaling cannot introduce rotation. Keep both
`FIELD_QUAD_*` constant sets (game.gd and world3d_entities.gd) in sync; COORD is
the single integrator.

---

## 6. Backup and application instructions (NOT executed)

Before applying, from the workspace root (PowerShell, `python` not `python3`,
no `&&`):

```powershell
Copy-Item variant3d\scripts\game.gd inbox\backup\game.gd.bak-F2-03
Copy-Item variant3d\scripts\world3d_entities.gd inbox\backup\world3d_entities.gd.bak-F2-03
```

If COORD additionally decides to author the F2-05 atom deltas of §7, back up
`variant3d/tests/t_f2_mill_fields.gd` (if already created) as
`inbox\backup\t_f2_mill_fields.gd.bak-F2-03B` **before** changing its thresholds.
Backups must precede the first edit; this ticket created none because it made no
edit. Verify with `git diff --check` and by reading each hunk's context before
saving. **Do not run Godot in this step** — G04 owns the runner.

---

## 7. Acceptance checks (visual + gates)

### 7.1 Visual gate — windowed 64² and real-map captures (COORD/G04 only)

1. Finished mill shows **exactly four** crop patches N/E/S/W with a square dirt
   clearing around the tower; no 7×7 scatter remains.
2. Adjacent patches **touch**: at each inner corner the rendered decals overlap
   (measured signed gap ≈ −0.141 m); no green seam wider than 0.15 m is visible.
3. Patches keep the same footprint at ripe, growing, regrowing and depleted
   stages — only colour/stalk height changes (diff §5.2).
4. No patch overlaps a building (mill + deliberate house trap), stone/ore, road,
   water, shore or cliff; the central clearing shows bare ground, not crop.
5. The rotor sail is not obscured by crop decals; its clearance is ≥0.20 m from
   the inner patch edge (M01 `:144`). This F2-03 diff does **not** move the rotor;
   M03 handles that separately.
6. Summer and winter captures show the **same four positions**; winter tints
   neutral (`#756F61`-class) with no new art. `winter_field_decal.gd` stays inert;
   `envfieldd/w.png` are the only decal assets referenced (no synthetic art).
7. Verdict labelled **PORT APPROX — donor parity UNVERIFIED**; no donor A/B
   frame is claimed.

### 7.2 Gate checks (existing suites, unchanged thresholds)

| # | Gate | Expected |
|---|---|---|
| 1 | `variant3d` selftest | 29/29, `resow` step green (`mill_fields.size() > 0`, `manual > 0`, `restored`) — `selftest.gd:692-707` |
| 2 | `t_mill_logic` | 6/6: `mill_sows_ring` fields > 0 (cap now 4), gather/resow/regrow use `fields[0..2]` — `mill_logic_test.gd:48-93` |
| 3 | `t_mill_rotor` / `t_render_mode` / uitest | unchanged; 17/17 uitest; no `SCRIPT ERROR` in stderr |
| 4 | `assert_clean` | CLEAN |
| 5 | 2D `app/` | byte-identical (hash gate); **F2-03 is 3-D only**, so cross-variant sim hash parity is intentionally NOT claimed (record as a known divergence) |
| 6 | `t_forest_bake` | `res_dirty`/`fields_anim` stability unchanged (`:125-132`) |
| 7 | `t_entities3d` / `t_terrain_mines` structural gates | unchanged; no `anim/` substring introduced, no forbidden `field` sid change |
| 8 | RNG determinism atom | `game.rng.get_state()` and `gen_rng.get_state()` identical before/after `_on_building_finished(mill)`; repeat on seeds 9 and 1004 → identical field-centre list |
| 9 | Rejection atom | with a real `hou` placed on a quad centre and a `gold/iron/coal` deposit / `stone` node inside another, `fields.size()` drops to 2 with **no shifted centre**; `can_place` and `blocked` unchanged |
| 10 | Building/placement regression | `can_place` still refuses "Cornfield - pick open dirt." / "Stone field - pick open dirt." (`game.gd:4043-4044`); walls/gates/mines placement unchanged |

### 7.3 Required F2-05 atom deltas (author-only proposal; NOT applied here)

`F2_05_qa.md`'s Atom A was written for the 7×7 lattice. When COORD authors
`variant3d/tests/t_f2_mill_fields.gd`, apply **exactly** these edits so the test
gates the quad instead of forbidding it:

- `:122` `const MIN_FIELDS := 7` → `const MIN_FIELDS := 4` (and `:364` check
  message "≥4").
- `:120` `EPS_EDGE := 0.25` → `0.15` (tighter decisive contact gate; our signed
  gap is −0.141 m).
- `:448-449` `lattice_span_measured`: range `[1.5, 3.6]` → `[9.5, 11.0]`,
  message "adjacent quad centres = sqrt(2)*7.2 = 10.182 m".
- `:481-483` `pairs >= MIN_FIELDS` stays, now 4; `worst_gap <= EPS_EDGE` stays.
- `:339-357` house trap: place `hou` at one **quad centre**
  (`mill + Vector2(7.2, 0)`) instead of a 7×7 lattice cell; its distance from
  mill is 7.2 m ≥ 4.5 m, so `can_place` remains legal, and the rejection gate
  must drop exactly that patch.
- Add two checks: `field_count_is_four` (`_fields.size() == 4` on clear ground)
  and `rng_state_unchanged_by_sow` (gate 8 above).
- `:88-92` pre-fix provenance table: mark `adjacent_fields_touch` and
  `fields_clear_of_buildings` as `expected_pre_fix_failure` still; **do not**
  lower or delete any assertion.

F2-05's Atom B (mine snap) is unaffected by this ticket.

---

## 8. Invariants explicitly preserved

- **Building collision/placement:** no edit to `_block_rects_ensure()`,
  `bld_block_r`, `bld_block_rect_for`, `can_place`, `place_building`,
  `set_blocked_circle` or `nav_version`. New code only *reads* those structures.
- **Roads / water / shore:** no write to `terrain`, `tileblock`, `mine_mask`,
  `blocked` or `_draw_road`; road/water/shore cells are additionally *rejected*
  by the new gate.
- **Season swap:** no edit to `_season_key()`, `SEASON_ATLAS`, `world3d_terrain.gd`
  season selection, `_field_decal_paths` or decal tint logic. Both donor decal
  paths stay recorded exactly as before; no new texture, mesh or generated art.
- **Rotor:** no edit to `ROTOR_*` constants, `_attach_rotor`, `_rotor_mesh`,
  `_rotor_material` or the rotor loop; M03 remains the sole owner of that fix.
- **Stages / batches:** `_sync_building_stages`, `_new_batch` `use_colors`,
  `_grow_batch` (P11) and all test `expected_pre_fix_failure` flags untouched.
  `_field_visual` gains an additive `scale_xz` key only; P11's `color` consumer
  (proposal :185-192) is unaffected.
- **Sim API:** `cmd_sow`, `_restore_field`, `field_state`, `field_growth01`,
  `field_counts_for_mill`, `_tick_fields` and `FIELD_REGROW_TIME` untouched.
- **No synthetic art:** existing donor `field.obj` mesh and the two shipped
  `envfieldd/w.png` decals only; `winter_field_decal.gd` remains inert.

---

## 9. UNVERIFIED / open register

1. No Godot run, no capture, no donor A/B: every visual statement in §3/§7 is a
   prediction, not a measured frame (WAVE_G_CHARTER :31).
2. Donor 3-D field placement rule / exact 7.2 m × 7.3 m patch size: **UNVERIFIED**;
   the only donor anchor is the screenshot's central clearing (`field_crops.md
   :90-97`) and the decal bbox — exact sizes are PORT APPROX.
3. F2-02 had not landed; if it reports a donor cSeedWheat spacing/footprint,
   COORD must reconcile it with §3 before applying.
4. The 2-D `block_rect` of the mill extends to −6.254 m in sim Y
   (`game.gd:1878-1881`, E6); the south patch is deliberately allowed because the
   owning mill is excluded. Physical 3-D clearance is 1.15 m (E13), but the
   2-D ghost/placement semantics around that exclusion are **UNVERIFIED** without
   a capture — gate 4/§7.1 must look at it.
5. Road tile ids are resolved from `tbl_idx`; if a map variant omits
   `test1/test2/test3`, road rejection is not active (documented limitation,
   not a silent fallback). `tileblock` road painting is observed at
   `game.gd:1986-1995`.
6. Cross-variant sim hash parity breaks by design (3-D only fix); accept as a
   tracked divergence, not a regression hidden by a weakened test.
7. F2-04 also owns `game.gd`; M03/P11 also own `world3d_entities.gd`. Both grants
   and merge order are COORD's decision and are **UNVERIFIED** at authoring time.

---

## 10. Scope statement

No code, asset, config, test, fixture, gate, result JSON or git state was edited.
No backup was created (no edit occurred). No Godot process was started and no
runner job submitted. All numbers were derived by arithmetic from the cited
files; observations, derivations, inferences and unverified items are separated
per `CHARTER.md:55-69`. Every non-donor spacing constant carries a PORT APPROX
label (§3 table). The diff in §5 is **ready to apply by COORD only after G04
finishes and ownership is granted** (§1).

*End of F2-03 report.*
