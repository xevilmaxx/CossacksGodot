---
id: BLD-03
ticket: "BLD-03 — ready-to-apply fix proposals: (a) mine ghost/indicator footprint, (b) builder trapped in building mesh"
swarm: terrain_swarm_2026-11-25
wave: BLD
date: 2026-11-25
status: PROPOSAL_ONLY__READ_ONLY__NO_CODE_EDIT__NO_RUNNER__NO_PARITY_CLAIM
owner: "BLD-03 (read-only proposal subagent)"
output: "docs/terrain_swarm_2026-11-25/reports/BLD_03_fix.md"
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md"
wave_charter: "docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md#wave-bld"
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (Wave BLD lines 171-184; standing rule 1 line 31)
  - docs/terrain_swarm_2026-11-25/CHARTER.md (guardrails §3, §1b.3, §5)
  - docs/terrain_swarm_2026-11-25/reports/BLD_01_mine_footprint.md (LANDED — folded into fix (a))
  - docs/terrain_swarm_2026-11-25/reports/BLD_02_builder_trap.md (LANDED — §7 minimal fix folded into fix (b))
  - docs/terrain_swarm_2026-11-25/reports/B06_ghost_impl.md (B06 ghost diff + invariants)
  - docs/terrain_swarm_2026-11-25/reports/F2_04_mine_snap.md (F2-04 snap design)
  - docs/terrain_swarm_2026-11-25/reports/F2_02_donor_fields_mines.md (donor mine footprint/snap truth)
  - docs/terrain_swarm_2026-11-25/reports/G09_footprint.md (footprint honesty; no .prop mask)
  - variant3d/scripts/world3d_fx.gd
  - variant3d/scripts/world3d.gd
  - variant3d/scripts/world3d_entities.gd
  - variant3d/scripts/game.gd
  - variant3d/scripts/world.gd
  - variant3d/scripts/selftest.gd
  - variant3d/scripts/input_controller.gd
  - variant3d/main.gd (render_mode default)
  - variant3d/tests/t_ghost_final_stage.gd
  - variant3d/tests/t_mines_place.gd
  - variant3d/tests/unified_mine_test.gd
  - variant3d/assets/models/manifest.json (mine bboxes)
bld01_bld02_status: "BOTH LANDED at update time (COORD follow-up) — BLD_01_mine_footprint.md and BLD_02_builder_trap.md read in full and folded in. §§A/B below are reconciled with them; BLD-02 §7 is the source of fix (b)'s hunks."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT_APPROXIMATION]
proposed_owner_files:
  - variant3d/scripts/game.gd         # fix (b) primary — BLD-02 §7 hunks; fix (a) alternative also lives here
  - variant3d/scripts/world3d_fx.gd   # fix (a) visual indicator (COORD decision pending)
cross_wave_files_mentioned:
  - variant3d/scripts/world.gd        # 2D indicator — NOT proposed for edit
  - variant3d/scripts/world3d_entities.gd # true mesh-extent source / construction stages — NOT proposed for edit
  - variant3d/scripts/nav.gd          # verified correct — NO change needed
  - variant3d/scripts/selftest.gd     # probe companion — optional, separate grant
---

# BLD-03 — ready-to-apply fix proposals (no edit applied)

## 0. Guardrails honoured

**OBSERVED** — no Godot process, no runner job, no capture, no test edit and no
source edit were made by this agent. The only new artifact is this report.
Standing rule (WAVE_G_CHARTER.md:31): only G04 runs Godot. Backups before any
edit (CHARTER.md:66). No donor-parity claim; no threshold lowered; no assertion
deleted (CHARTER.md §3). Donor citations are inherited as text only.

Line numbers are **current-tree** at 2026-11-25 (post-B03/B05/B06, post-F2-02).
Sibling agents still edit the tree: the applying owner MUST re-confirm each hunk
context before applying. Each diff is written as a small named block so rollback
is by the listed backup copy.

**What changed in this update:** BLD-01 and BLD-02 landed. BLD-02's two *confirmed*
faults and its §7 "Minimal fix proposal" replace my earlier inferred fix (b);
BLD-01 materially reframes fix (a) — the 3D ghost is **not** 2× the placed mine,
so fix (a) is now flagged as a COORD decision (§A1a) and its diff is a
visual-only indicator change.

---

## 1. Owner mandate and the two defects

WAVE_G_CHARTER.md:173 (Wave BLD owner directive):

> *"when building mine it ± should be same size of mine on the map — now it's
> about twice; and during building it traps builders inside and they cannot
> finish it — avoid builders being trapped in the building mesh during build;
> they can walk only around."*

The "±" is the owner's "approximately" qualifier: the mine placement indicator
is about 2× the mine on the map. The parent ticket refines fix (a) to
*"halve the ~2x radius, keep can_place and deposit snapping intact"* — a
**visual-only** change; the sim radius and the F2-04 snap stay byte-identical.

---

# FIX (a) — mine ghost/indicator footprint sized to the placed mine

## A1. Evidence chain (OBSERVED code reads, some inherited from BLD-01)

| # | Site | Read |
|---|---|---|
| A1 | `world3d_fx.gd:597-598` `draw_ghost()` | `var r = _building_radius(s)` → `_ghost_mesh.scale = Vector3(r*2,1,r*2)`. `Footprint` is `BoxMesh(1,0.05,1)` (`:909-913`) → ground square 2r × 2r; `r = def.radius = 1.6` for mines (`data.gd:1342-1347`). |
| A2 | `world3d_fx.gd:628-632` `_ghost_swap_building_mesh()` | `_ghost_mesh.visible = false` whenever a finished mesh resolves. Mine base OBJs exist (`manifest.json:1316-1370`), so for a mine the 3.2 m box is **hidden**. |
| A3 | `world3d_fx.gd:630`, `:640-694` | the visible 3D hologram is `_ghost_building.mesh` at `scale = Vector3.ONE`, resolved from the **same** baked mesh the placed building wears (`world3d_entities.gd:1660-1682`). BLD-01 §3: 3D ghost vs placed 3D mesh is **1.00×, not 2×**. |
| A4 | `world.gd:3513,3533,3536-3537` | the red "blocked" cross is **2D-only**: X spans ±`gr` with `gr = def.radius*view_scale = 1.6 m` (3.2 m), ring rx = 1.45·1.6 = 2.32 m. `world3d_fx.gd` contains no cross. `main.gd:124` defaults `"2d"`. |
| A5 | `game.gd:19` `MINE_SITE_RADIUS = 4.0 m` | the mine legality/snap radius: `can_place` `:4038-4061` (early `{ok:true}`), `resolve_mine_sid` `:3129`, `place_building` `:4153-4157`. Its **8 m ring diameter is exactly 2× the 4 m 2D mine marker** (`world.gd:2817`); BLD-01 §6 row 1. |
| A6 | `manifest.json:1323-1330`, `world3d_entities.gd:1126-1130,1054-1107` | placed mine mesh 15.03 × 15.82 m (env factor 1.0 for `kind=="building"`); collision radius 1.6 m → mesh ~4.7× collision. |
| A7 | `F2_02_donor_fields_mines.md:103-105,243-256` | donor built-mine mask 5×5 cells (10 m), deposit visual ~4.7 m; donor built ≈2.1× deposit. |

## A1a. BLD-01 landing — the "2×" premise is reframed (read before applying)

BLD-01 §1/§3/§6 states, with code evidence:

- The **only** ~2.00× relation in the tree is `MINE_SITE_RADIUS` ⌀ 8 m vs the
  4 m 2D mine marker (`world.gd:2817`). BLD-01 §9 names `game.gd:19` as the
  radius to examine first (donor value 3 m, F2-02:262).
- If the owner meant "the **ghost** is ~2× the placed mine", **no code path
  supports it**: the 3D ghost mesh is the identical 15 m mesh (1.00×), and the
  only other indicator (the 3.2 m `Footprint` box) is hidden for mines.
- The cross the ticket called a `world3d_fx.gd` indicator is a 2D `world.gd`
  artifact, and it is red/blocked-only.

**Conflict with the parent constraint:** halving `MINE_SITE_RADIUS` *would*
change `can_place()` verdicts and the F2-04 snap, which the parent explicitly
forbade ("keep can_place and deposit snapping intact"). BLD-01 §9 likewise warns
not to touch `can_place()`/`bld_rm()` without a fresh gate plan.

**Resolution proposed here (visual-only, no sim change):** make the mine ghost
carry an **honest, visible footprint indicator** sized to the placed mine's
*visible* footprint — the bbox half-extent ~7.9 m (`manifest.json:1323-1330`),
labelled PORT APPROX — shown alongside the finished hologram. This satisfies
"indicator same size as the placed mine" without touching `MINE_SITE_RADIUS`,
`can_place()`, the snap, or B06's mesh selection. **COORD decision required:**
if the owner's "about twice" specifically means the 8 m green/red legality
ring, that is a *separate* ticket (visualise a 4 m ring without changing the
legality constant); BLD-03 does not change a sim radius.

## A2. Exact unified diff (proposed — NOT applied)

Owner file: **`variant3d/scripts/world3d_fx.gd`** (B06's file; no concurrent
owner after B06 landed). Backup:
`inbox/backup/world3d_fx.gd.bak-BLD03A`.

```diff
diff --git a/variant3d/scripts/world3d_fx.gd b/variant3d/scripts/world3d_fx.gd
--- a/variant3d/scripts/world3d_fx.gd
+++ b/variant3d/scripts/world3d_fx.gd
@@ -595,8 +595,15 @@ func draw_ghost(sid, pos, ok: bool) -> void:
 	_ghost_root.position = p3
 	_ghost_root.visible = true
-	var r: float = _building_radius(s)
+	# BLD-03: mine indicator sized to the PLACED mine's visible footprint
+	# (bbox half-extent ~7.9 m, manifest.json:1323-1330), not the estimated
+	# sim radius. Visual only: can_place()/bld_rm()/MINE_SITE_RADIUS and the
+	# F2-04 deposit snap stay byte-identical. PORT APPROXIMATION (donor .prop
+	# mask not decoded in repo; G09 §1), NOT donor parity.
+	var r: float = _ghost_indicator_radius(s)
 	_ghost_mesh.scale = Vector3(r * 2.0, 1.0, r * 2.0)
 	# Swap the transparent building mesh on sid change; footprint BoxMesh stays
 	# ONLY as the no-art fallback (labelled). The provider mesh is already
@@ -628,7 +635,10 @@ func _ghost_swap_building_mesh(s: String) -> void:
 	if mesh != null:
 		_ghost_building.mesh = mesh
 		_ghost_building.scale = Vector3.ONE
 		_ghost_building.visible = true
-		_ghost_mesh.visible = false
+		# BLD-03: for mines the honest footprint is the only size cue the
+		# player has (no nation ink box). Show the box UNDER the finished
+		# mesh; non-mine sids keep B06's hide behaviour (E04 check 7 on
+		# "hou" unaffected). Shared _ghost_mat keeps green/red tint.
+		_ghost_mesh.visible = s.begins_with("mine_")
 	else:
 		_ghost_building.mesh = null
 		_ghost_building.visible = false
@@ -1555,6 +1565,14 @@ func _building_radius(sid: String) -> float:
 		if d is Dictionary and d.has("radius"):
 			return maxf(0.25, float(d.radius))
 	return 1.5
+
+# BLD-03: footprint radius for the ground indicator ONLY. Non-mines return the
+# exact _building_radius value; mines return the mesh bbox half-extent so the
+# indicator matches the placed mine (BLD-01 §5). Never called by can_place(),
+# bld_rm() or the sim. PORT APPROXIMATION - NOT DONOR PARITY (G09 §1).
+func _ghost_indicator_radius(sid: String) -> float:
+	if sid.begins_with("mine_"):
+		return 7.91  # max(|x|,|z|) half-extent, manifest.json:1323-1330
+	return _building_radius(sid)
```

**Net effect:** +18 lines, -2 lines in one file. No `game.gd`, `data.gd`,
`world3d.gd`, `world.gd`, `input_controller.gd` or test change. BoxMesh geometry
and the `Vector3(r*2,1,r*2)` expression are byte-identical; only the mine radius
source and the mine-only visibility change.

**If COORD instead chooses the literal "halve the ~2× radius" reading** from the
parent directive, change only the constant in `_ghost_indicator_radius()` from
`7.91` to `_building_radius(sid) * 0.5` (0.8 m) — the visibility hunk stays.
Record which option was chosen; do not apply both.

## A3. Backup / apply order (governance; COORD applies, this agent did not)

```powershell
Get-FileHash variant3d\scripts\world3d_fx.gd -Algorithm SHA256
Copy-Item variant3d\scripts\world3d_fx.gd inbox\backup\world3d_fx.gd.bak-BLD03A
Get-FileHash inbox\backup\world3d_fx.gd.bak-BLD03A -Algorithm SHA256
# apply §A2 verbatim, then: git diff --check
# rollback = Copy-Item inbox\backup\world3d_fx.gd.bak-BLD03A variant3d\scripts\world3d_fx.gd
```
Do not run Godot from this ticket (G04 owns the runner).

## A4. Invariant proof (static derivation — not a PASS verdict)

| Invariant | Why it holds |
|---|---|
| **B06 ghost final-stage mesh** | `_ghost_resolve_mesh()` (`:640-694`) and `GhostBuildingFinished` (`:922`) untouched; `_ghost_building.mesh` and `scale = Vector3.ONE` at `:629-630` unchanged. Only the sibling `_ghost_mesh.visible`/radius change, mine sids only. `stats["ghost_mesh_source"]` unchanged; no stage-"1" request. |
| **F2-04 snap / `can_place`** | No edit to `world3d.gd:_sync_build_ghost()` (`:463-498`) or `game.gd`. `_ghost_root.position = world_pos(pos)` at `:595` untouched. `MINE_SITE_RADIUS`, `can_place()`, `resolve_mine_sid()`, `place_building()` byte-identical (BLD-01 §9 requirement). |
| **B05 selection** | `input_controller.gd` byte-identical. |
| **E04/G02 check 7** | Atom SID is `"hou"` (`t_ghost_final_stage.gd:40`): `begins_with("mine_")` false → `_ghost_mesh.visible == false` and radius unchanged. No expectation flipped/weakened. |
| **nav / tests / stages** | No sim, nav, test or `world3d_entities.gd` edit; construction stages byte-identical. |
| **2D port** | `world.gd` untouched (CHARTER §5 gate). |

## A5. Acceptance gates (runner owner only; none run here)

1. **Mine indicator:** with `build_ghost_sid = "mine"` over a deposit,
   `Footprint.visible == true` while `GhostBuildingFinished.mesh != null`, and
   `Footprint` world X/Z size ≈ 15.8 × 15.8 m (or 1.6 m under the alternative
   halving option) — record which option was applied.
2. **Non-mine control:** `"hou"` → `Footprint.visible == false`, radius 3.0 m
   (byte-for-byte old behaviour).
3. **Snap control:** ghost root ≈ `fx.world_pos(dep.pos)` within 0.01 m.
4. **B06 control:** `stats["ghost_mesh_source"]` still `finished_base|…` /
   `last_stage_4|…`; `t_ghost_final_stage.gd` unchanged.
5. **Regression:** selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean`
   CLEAN; `t_mines_place.gd`, `unified_mine_test.gd`, `t_mine_build.gd`,
   `building_block_test.gd` unchanged.
6. **Visual:** windowed before/after capture required; until then UNVERIFIED.

## A6. PORT APPROX / residual

`7.91` comes from donor bbox text (inherited citation), not a decoded `.prop`
mask — **UNVERIFIED** on screen. BLD-01 §8: which on-screen pair the owner's
"about twice" refers to is UNVERIFIED without a capture. The 8 m legality ring
is deliberately untouched; visualising it is a separate ticket.

---

# FIX (b) — builder perimeter slots + walk-around pathing

## B1. Two CONFIRMED faults (BLD-02 §1, §4, §6; OBSERVED/DERIVED)

BLD-02 refutes three hypotheses: **spawn offset** (no builder is spawned inside
a building — inverse mechanism only: site snapped onto deposit where peasants
stand, `game.gd:4153-4157`/`:5606`), **missing construction collision** (the full
`block_r` circle is stamped at `spawn()` for unfinished sites, `:2481-2489`, and
unchanged on finish, `:2513-2536`), and **nav ignoring the unfinished building**
(nav reads the same `blocked` grid, `nav.gd:154-243`, and A* cannot append a
blocked goal, `game.gd:4784-4786`). No change to `nav.gd` or
`world3d_entities.gd` is needed (BLD-02 §7).

**Fault 1 — inside the mesh (collision-vs-art radius mismatch).** Unfinished
sites stamp only `block_r`; for mines `block_r = def.radius = 1.6 m`
(`game.gd:1883-1888`, `data.gd:1342-1347`) while the base mesh reused for every
construction stage is ~15 × 15 m (`manifest.json:1323-1330`;
`world3d_entities.gd:1872-1881`, `scale = 1.0` at `:1126-1130`). Work slots at
`ring_r = 2.3 / 2.65 / 3.0 m` (`game.gd:5191` → `_work_slot` `:4899-4909`)
sit **inside the ~7.5–7.9 m visual radius**. The quantized mine block is a
4 × 4 m square (BLD-02 §3.2), not a 1.6 m disc; mines have no ink rect
(`bld_block_rect_for` empty, no `buildings.json` mine key).

**Fault 2 — snap-to-centre → stall chain.** `_work_slot` ends with
`return center` at `game.gd:4909`. When both ring trials land on blocked cells
it returns the **building origin**. Deterministic golden-angle scan over ids
1…60: **10/60 ids snap to the origin** (BLD-02 §4.2). Then:
`game.gd:5193` sees `d > 0.6` → `:5195` calls `_step_move(..., giveup=false)` →
`:4798-4799` keeps the blocked destination → A* `nav.gd:80-102` snaps the *path*
goal to a perimeter cell and `game.gd:4784-4786` refuses the raw blocked target →
arrival measured against the raw centre at `:4849-4850` never satisfies `:5193`
or `:4850` → all 13 probes at `:4865-4872` point back into the square →
`:4891-4893` grows `stuck_t` → order cancelled at `stuck_t > 8.0`
(`:5196-5199`) with `site.progress`/`hp` never advanced (`:5204-5217`).
Intermittent because the fallback is id/angle dependent.

## B2. Exact unified diff — fold of BLD-02 §7 (proposed — NOT applied)

Owner file: **`variant3d/scripts/game.gd`**. Backup:
`inbox/backup/game.gd.bak-BLD03B`.
**Ownership warning:** `game.gd` is also the proposed file of F2-03 (mill fields)
and F2-04 (`snap_mine_pos`), and fix (a)'s alternative lives there too. COORD
must grant one owner and apply in the serial order in §6; re-confirm line
numbers after any F2 integration.

**Hunk 1 — remove `return center`; 16-direction outward scan with a neutral
probe; add optional `footprint_r`** (BLD-02 §7 Hunk 1; replaces
`game.gd:4896-4909`):

```diff
diff --git a/variant3d/scripts/game.gd b/variant3d/scripts/game.gd
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -14,6 +14,12 @@ var _nav_tick_budget := NAV_PER_TICK
 const TILE := 2.0
+# BLD-03 / BLD-02 §7: visual half-extent of the placed mine
+# (manifest.json:1323-1330, max(|x|,|z|) ~= 7.9 m). Used ONLY to place builder
+# work slots OUTSIDE the mesh; NEVER used by can_place(), bld_rm(), spawn() or
+# blocked[]. PORT APPROXIMATION - donor mask is not decoded (G09 §1).
+const MINE_VISUAL_R := 7.9
 # How close to an ore deposit the build cursor must be for a mine to be legal
 # (and for the unified "Mine" button to pick that deposit's type).
 const MINE_SITE_RADIUS := 4.0
@@ -4896,14 +4902,27 @@ func _step_move(e: Dictionary, target: Vector2, speed: float, dt: float, arrive :=
 # Deterministic slot around a work point (tree, rock, build site): golden-angle
 # spiral so N workers fan into a ring instead of stacking. Same unit always
 # takes the same slot, so orders are stable and neighbours do not jitter.
-func _work_slot(e: Dictionary, center: Vector2, ring_r: float) -> Vector2:
-	var ang := float(e.id) * 2.399963 + center.x * 0.13 + center.y * 0.07
-	var rr := ring_r + float(e.id % 3) * 0.35
-	var p := center + Vector2(cos(ang), sin(ang)) * rr
-	if in_bounds(p) and not is_blocked(p):
-		return p
-	# blocked side of the ring: try the opposite side
-	var p2 := center - Vector2(cos(ang), sin(ang)) * rr
-	if in_bounds(p2) and not is_blocked(p2):
-		return p2
-	return center
+# BLD-03: the old `return center` snapped ~10/60 ids to the blocked building
+# origin (BLD-02 §4.2), which A* refuses and the work gate never reaches.
+# Scan outward with a NEUTRAL probe (no build order): the site's own ink rect
+# stays solid, so no slot can land inside it. `footprint_r` is the visual
+# perimeter; default keeps every other caller byte-identical in behaviour.
+func _work_slot(e: Dictionary, center: Vector2, ring_r: float, footprint_r := -1.0) -> Vector2:
+	var probe: Dictionary = {"def": e.get("def", {}), "order": {},
+		"player": e.get("player", 0)}   # neutral: no build-target skip
+	var fr: float = maxf(footprint_r, ring_r - 0.7)
+	var phase := float(e.id) * 2.399963
+	for k in 16:
+		var a := TAU * float(k) / 16.0 + phase
+		for ext in [0.0, 1.0, 2.0, 4.0]:
+			var rr: float = maxf(fr + 0.6, ring_r) + ext + float(e.id % 3) * 0.35
+			var p: Vector2 = center + Vector2(cos(a), sin(a)) * rr
+			if in_bounds(p) and p.distance_to(center) >= fr + 0.6 \
+				and not _blocked_for(probe, p):
+				return p
+	return center + Vector2(1.0, 0.0) * (fr + 4.0)   # never the origin
```

**Hunk 2 — pass the VISUAL footprint radius to the work ring** (BLD-02 §7 Hunk
2; replaces `game.gd:5191`; zero data-model change — no `footprint_r` field in
`spawn()`, so `blocked[]`/entity schema stay byte-identical):

```diff
@@ -5188,7 +5207,10 @@ func _tick(e: Dictionary, dt: float) -> void:
 			# each builder takes its own slot around the site so the crew
 			# rings the foundations instead of stacking on one point
-			var slot_b := _work_slot(e, site.pos, float(site.get("block_r", site.def.radius)) + 0.7)
+			var fr_site: float = float(site.get("block_r", site.def.radius))
+			if str(site.get("sid", "")).begins_with("mine_"):
+				fr_site = MINE_VISUAL_R   # ~7.9 m visual, not 1.6 m collision
+			var slot_b := _work_slot(e, site.pos, fr_site + 0.7, fr_site)
 			var d: float = e.pos.distance_to(slot_b)
```

**Hunk 3 (OPTIONAL, recommended) — narrow the own-site ink-rect skip so builders
walk around** (BLD-02 §7 Hunk 3; `game.gd:227-230`). Land ONLY after hunks 1-2:
Hunk 1 guarantees builders start outside, so removing the free pass cannot
freeze an inside builder. I narrow rather than delete: keep it as an escape
hatch for a builder already inside its site.

```diff
@@ -227,7 +227,16 @@ func _blocked_for(e: Dictionary, p: Vector2) -> bool:
 	var build_target: int = 0
 	var ord: Dictionary = e.get("order", {})
 	if str(ord.get("type", "")) == "build":
 		build_target = int(ord.get("target", 0))
+	# BLD-03 (optional): own-site skip is now an ESCAPE hatch only. A builder
+	# outside sees the site as solid, so _nav_line_clear / A* walk AROUND the
+	# mesh. Finished buildings were never skipped - this narrows, never widens.
+	if build_target != 0:
+		var tgt: Dictionary = by_id.get(build_target, {})
+		if not tgt.is_empty():
+			var bre: Rect2 = tgt.get("block_rect", Rect2())
+			var inside: bool = (bre.has_area() and bre.has_point(e.pos)) \
+				or e.pos.distance_to(tgt.pos) <= float(tgt.get("block_r", tgt.def.radius))
+			if not inside:
+				build_target = 0
 	# Buildings are solid 2D blocks: the drawn sprite's ink box stays impassable
```

**Net effect:** hunks 1-2 = +25 lines, -8 lines; hunk 3 = +9 lines, -0. No change
to `spawn()`, `set_blocked_circle`, `can_place()`, `bld_block_r()`, `nav.gd`,
`world3d_entities.gd` or any test. Construction stages and the B06 ghost are
untouched by fix (b).

## B3. Companion probe (optional — DIFFERENT owner, do not fold into BLD-03B)

`selftest.gd:_spot()` (`:160-181`) calls `_work_slot(builder, p, slot_ring)` with
3 args — the new default `footprint_r = -1.0` keeps it compiling and makes its
reachability probe **stronger** (outward scan, no centre fallback). No edit is
strictly required. If COORD wants the probe to use the mine visual radius too,
that is a separate test-file grant with its own backup
(`inbox/backup/selftest.gd.bak-BLD03B`); no pass criterion changes.

## B4. Backup / apply order (governance; COORD applies, this agent did not)

```powershell
Get-FileHash variant3d\scripts\game.gd -Algorithm SHA256
Copy-Item variant3d\scripts\game.gd inbox\backup\game.gd.bak-BLD03B
Get-FileHash inbox\backup\game.gd.bak-BLD03B -Algorithm SHA256
# apply §B2 hunks 1-2 (and optionally 3), after §6 serial arbitration, then:
git diff --check
# rollback = Copy-Item inbox\backup\game.gd.bak-BLD03B variant3d\scripts\game.gd
```
Do not run Godot from this ticket.

## B5. Invariant proof (static derivation — not a PASS verdict)

| Invariant | Why it holds |
|---|---|
| **`blocked[]` / collision byte-identical** | No edit to `spawn()` (`:2481-2498`), `set_blocked_circle()` (`:544-557`), `is_blocked()` (`:529-532`), `can_place()` (`:4032-4104`) or `bld_block_r()`. `MINE_VISUAL_R` is a read-only constant consulted only inside build-slot assignment; it never feeds `blocked`. The site still stamps `block_r = 1.6` exactly as today. |
| **F2-04 mine snap** | `MINE_SITE_RADIUS`, `resolve_mine_sid` (`:3129`) and the `:4153-4157` snap loop untouched. Site creation/position unchanged. |
| **B06 ghost / construction stages** | No edit to `world3d_fx.gd` or `world3d_entities.gd`; `_sync_building_stages()` and `GhostBuildingFinished` byte-identical. |
| **B05 selection** | `input_controller.gd` byte-identical. |
| **nav** | `nav.gd` byte-identical (BLD-02 §7: no change needed). `_nav_repath`, `_nav_smooth`, `_step_move`, `_snap_free_point` bodies unchanged; only the *slot destination* becomes free, so the existing A*/steering path logic can succeed. |
| **Other `_work_slot` callers** | `repair` (`:5152`), `resow` (`:5132`), `gather` (`:5606`), `selftest._spot` (`:179`) keep 3-arg calls; the added parameter has a default and `fr = ring_r - 0.7` reproduces the old ring radius for them. Removing `return center` can only move a previously-blocked slot outward, never into a blocked cell. |
| **Give-up safety net** | `stuck_t > 8.0` clear (`:5196-5199`) retained; with a free perimeter destination it should not fire. |
| **No RNG / determinism** | 16 fixed angles + deterministic `id` phase and `id%3` offset; same seed → same slots. `_snap_free_point` unchanged. |
| **Build legality / economy** | `build_cost`, `can_afford`, `pay_cost`, `place_building`, `cmd_build` untouched. |
| **Tests not weakened** | No test file edited in §B2; §B3 is optional and strengthens the probe. |

## B6. Acceptance gates (runner owner only; none run here)

1. **No centre fallback:** with a mine site centred on a tile corner, none of
   ids 1…60 yields `slot_b == site.pos`; every slot satisfies
   `p.distance_to(site.pos) >= MINE_VISUAL_R + 0.6` (~8.5 m) unless the outward
   scan exhausted all 64 candidates (then the fallback is `pos + (fr+4)·X`,
   still never the origin). BLD-02 §4.2's 10/60 failure disappears.
2. **Outside the mesh:** every settled builder position passes
   `_blocked_for(neutral_probe, pos)` and is outside the ~7.9 m visual radius
   for mines; for sprite buildings the ring uses `block_r` (BLD-02 §7 Hunk 2).
3. **Walk-around (hunk 3):** with hunk 3 applied, `_blocked_for(build_e, p)` is
   true for an outside builder probing the site's ink rect/circle and remains
   false for a builder already inside (escape hatch). Path contains a detour.
4. **Completion:** scripted build with the same 25 s window used by
   `selftest.gd` finishes for `hou` **and** `mine_gold`: `site.finished == true`,
   `post_event("done", …)` observed, no builder cancels at `stuck_t > 8.0`.
5. **Regression:** variant selftest 29/29, uitest 17/17, `t_render_mode`,
   `assert_clean` CLEAN; `t_mine_build.gd` (can_place_mine, snapped_to_deposit,
   builder_ordered, completion, B/B2/C interruptions), `unified_mine_test.gd`
   (preview/legal/build/no_deposit_rejected), `t_mines_place.gd`,
   `building_block_test.gd` unchanged; repair/gather/resow paths unchanged.
6. **No-parity gate:** "walks around" is PORT APPROX / UNVERIFIED visually until
   a windowed capture lands.

## B7. PORT APPROX / residual

`MINE_VISUAL_R = 7.9` derives from donor bbox text (`manifest.json:1323-1330`,
inherited via BLD-02 §7) — not a decoded `.prop` mask, **UNVERIFIED** on screen.
BLD-02 §7 offers the equivalent stored-scalar alternative (`footprint_r` in
`spawn()`); the call-site constant is chosen here to guarantee zero entity/data
change. A mesh-exact perimeter would need `world3d_entities.gd:_bbox` ownership
(§6).

**Residual (record, do not silently fix):** BLD-02 §3.4 — the circle check at
`:221-222` is unconditional, so a builder genuinely inside a site still cannot
cross the blocked square; hunk 3 only narrows the ink-rect skip. This
pre-existing edge remains UNVERIFIED.

---

## 6. Cross-wave ownership and serial order (COORD arbitration)

| File | Other claimants | BLD-03 edit? | Serial order |
|---|---|---|---|
| `variant3d/scripts/game.gd` | F2-03 (fields), F2-04 (`snap_mine_pos`), fix (a) alternative | **YES — fix (b)** (and possibly fix (a) alternative) | Grant one owner. Recommended: **F2-04 snap → F2-03 fields → BLD-03B**. Fix (b) adds one const + rewrites one helper + one call site; re-base on the integrated file. If fix (a)'s `MINE_SITE_RADIUS` option were ever chosen (NOT proposed here), it must land in the same file grant and needs its own gate plan. |
| `variant3d/scripts/world3d_fx.gd` | B06 landed; G09 proposes a follow-up | **YES — fix (a)** | Apply BLD-03A after G04 gates as the B06 follow-up. If G09 is also accepted, integrate its `bld_rm` radius source and BLD-03A's mine indicator in **one** edit to this file. |
| `variant3d/scripts/world.gd` | 2D owner / G11 monitor | NO | The literal 8 m legality ring and the 2D cross live here — separate 2D ticket if a capture confirms the owner meant them (BLD-01 §6/§9). Do not cross the 2D/3D line here. |
| `variant3d/scripts/world3d_entities.gd` | P11 (draw calls), M03 (mill rotor) | NO | Only for a mesh-exact perimeter later; new ticket after P11/M03 land. Construction stages stay byte-identical. |
| `variant3d/scripts/nav.gd` | P-10/nav owners | NO | BLD-02 §7 verified no change needed. |
| `variant3d/scripts/selftest.gd` | COORD / test wave | OPTIONAL (§B3) | Separate grant only; no expectation flipped. |
| `variant3d/scripts/input_controller.gd` | B05 landed | NO | Untouched (B05 invariant). |

## 7. Ledger

| Question | Answer | Label |
|---|---|---|
| Confirmed builder faults | (1) 1.6 m collision vs ~15 m base mesh → slots at 2.3-3.0 m inside it; (2) `return center` (`:4909`) snaps ~10/60 ids to blocked origin → A* refuses → arrival fails → cancel at 8 s. BLD-02 §1/§4. | OBSERVED / DERIVED |
| Refuted causes | spawn offset, missing collision, nav ignoring building (BLD-02 §6). | OBSERVED |
| Fix (b) | Remove centre fallback + 16-dir outward scan with neutral probe; pass visual radius ~7.9 m; optional narrow own-site skip. BLD-02 §7 folded. | DERIVED |
| Fix (a) reframe | 3D ghost = placed mesh (1.00×); exact 2× = 8 m `MINE_SITE_RADIUS` ring vs 4 m 2D marker (BLD-01 §6). Parent forbids changing it → visual-only indicator diff; COORD decision. | OBSERVED / DERIVED |
| Owner files | `game.gd` (b), `world3d_fx.gd` (a). | DERIVED |
| Verified by this agent? | **No** — no Godot, no capture, no edit. §A5/§B6 are acceptance definitions, not results. | UNVERIFIED |

*End of BLD-03 update. Ready-to-apply proposals only; no code, test, config,
asset, git or runner state changed; no donor-parity claim. BLD-01 and BLD-02
findings folded in per COORD follow-up.*
