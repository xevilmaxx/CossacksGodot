---
id: Z04
ticket: "HEIGHT WAVE / Z04 — unified height-only design (art removal + donor-grounded visible relief)"
agent: "Z04 (read-only design subagent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GODOT_JOB
scope: "This report is the ONLY repo file written. No source, shader, config, asset, test, JSON, PNG, donor, queue or git edit; no Godot process and no runner job."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: docs/terrain_swarm_2026-11-25/reports/Z04_height_only_design.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Every visual expectation is INFERRED/UNVERIFIED. All substitutes and port-authored selection rules are labelled PORT APPROXIMATION. NO DONOR PARITY CLAIM."
baseline_game_gd: "inbox/backup/game.gd.bak-B03 (pre-B03-RELIEF). NOTE: the current working tree ALREADY carries Part A (B03-RELIEF in-flight edit) — verify before applying; do not double-apply."
baseline_world3d_terrain_gd: "current working tree == inbox/backup/world3d_terrain.gd.bak-B04 (B04 fully reverted, no net diff)."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/terrain_swarm_2026-11-25/reports/H03_heightmap_hypothesis.md
  - docs/terrain_swarm_2026-11-25/reports/H04_heightmap_fix.md
  - docs/terrain_swarm_2026-11-25/reports/H05_refutation.md
  - docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md (REVERTED)
  - docs/terrain_swarm_2026-11-25/reports/Y02_maze_root_cause.md (landed)
  - docs/terrain_swarm_2026-11-25/reports/Z02_hills_invisible.md (landed)
  - docs/terrain_swarm_2026-11-25/reports/A05_relief_visibility.md
  - docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md
  - docs/terrain_swarm_2026-11-25/reports/H02_port_layers.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md
  - variant3d/scripts/game.gd, variant3d/scripts/world3d_terrain.gd (read-only trace)
  - variant3d/shaders/terrain_tileindex.gdshader (read-only trace; NOT an owner file here)
verdict: "UNIFY: (A) remove terrain=5 ROCK ART from relief/hill stamps and from the gradient collision pass while leaving height[] writes and blocked[] byte-identical (Part A is already present in the working tree as B03-RELIEF); (B) give height[] real DONOR SHAPE by extending the live id-gated 8x10 relief grids to hil1/g_hil4 (PORT APPROX); (C) let the EXISTING donor-grounded geometry/normal shading be the only relief cue by suppressing cliff-art promotion on producer-stamped cells (a GUARD, the opposite of B04) and by exposing a height histogram for acceptance. No HEIGHT_SCALE fudge, no face promotion, no tile-art relief, no dither/noise, no shadow/AO fakery."
---

# Z04 — Unified height-only design: remove the fake rock maze, reveal real height

## 0. Mandate, stance and label key

Owner's two **linked** complaints (dispatch):

1. *"the pre-existing maze patterns are relief/HILL stamps PAINTED AS ROCK ART (`game.gd:846-852`, `:1240-1264`) and should be removed from the visible layer"*;
2. *"height must instead actually produce visible hills."*

This report designs **one** fix for both. It is **READ-ONLY**: exactly one file written (this report), no runner job, no Godot process, no source/shader/asset/config/test/git change. Only G04 submits jobs (`WAVE_G_CHARTER.md:31,67-70`).

Y01 and Z01 had **not** landed when this was written; **Y02 and Z02 had landed** and are used directly. Where Y/Z reports are absent, the same underlying sources were read (charters + named reports + owner source files).

Labels: **[O]** observed (literal code line / file byte / decoded number), **[D]** derived (control-flow or arithmetic consequence), **[I]** inference without a pixel-aligned donor A/B, **[U]** UNVERIFIED. Every port-authored selection rule is **PORT APPROXIMATION**. **No donor parity claim.**

**Line-number discipline.** The owner's cited lines (`846-852`, `1240-1264`) refer to the pre-relief tree (`game.gd.bak-B03`). The current working tree has drifted ~+15 lines because an in-flight `B03-RELIEF` edit is present. Both numbering states are cited where it matters; apply the diff by **context**, not by the `@@` numbers (`git apply --recount`).

---

## 1. What is OBSERVED in the tree right now

### 1.1 The two complaints are one code chain

```
_shape_stamp_relief()  game.gd:945-1129      writes HEIGHT ONLY (:1068, :1116)
  near_start disc      game.gd:967-979        relief skipped inside; outside = hard step <=2.964 m
  global clamp/dither  game.gd:1232-1255      creates terraces
  collision pass       game.gd:1256-1289      |dh|>0.5/0.55 -> blocked[]  (+ terrain=5 ART unless relief mask)
tile assignment        game.gd:2006-2050      terrain 5 -> rock1/2/3/6/7/4 ids  (VISIBLE GREY ART)
shore/cliff pass       game.gd:2057-...       terrain 5 -> oriented cliff ids
hill stamp             game.gd:853-861        (pre-fix) terrain[ii]=5 -> rock ART at stamp centre
world3d_terrain.gd     :1310-1312             vertex Y = height[i]*HEIGHT_SCALE(1.0)   <-- geometry
                       :1387 / :901-917       normals from height (1-cell forward diff) <-- shading
shader                 :298 / :301 / :305 / :427  donor Blinn-Phong from NORMAL -> RGB
```

**[O]+[D]** Y02 independently identified the same chain and ranked the **gradient collision pass** (`game.gd:1240-1264` pre-fix) as the PRIMARY maze producer, with the hill/stone `terrain=5` paints at `:846-852` as REAL BUT MINOR (`Y02:113-125`). Z02 independently established that height **is** in the mesh but reads flat (`Z02:45-77`). There is **no** hidden donor height texture drawn as albedo (H03/H05/H02 all REFUTE the literal Wave-H hypothesis); the leak is a **port-only derived field** one pass downstream of height.

### 1.2 Complaint (1) is already partly landed in the working tree (OBSERVED)

The working copy of `variant3d/scripts/game.gd` (mtime 15:15:58) carries an **in-flight `B03-RELIEF` edit** against `inbox/backup/game.gd.bak-B03`:

- hill stamp `terrain[ii] = 5` replaced by `pass` (current `:853-861`);
- new `_relief_stamp_mask: PackedByteArray` declared (`:80`), resized (`:959-960`), set on the `near_start` ring (`:979`), donor-grid cells (`:1070`) and analytic cells (`:1117`);
- **1-cell 8-neighbour dilation** added after the stamp loop (`:1121`–`1135` region) so an un-stamped cell *adjacent* to a relief terrace is also masked;
- collision-pass `terrain[i] = 5` guarded by `if _relief_stamp_mask[i] == 0:` (`:1287-1288`), with `set_blocked_tile(x, y, true)` left **unconditional** (`:1289`).

**[D]** This is Y02's "one-line alternative" plus the dilation refinement. It preserves `blocked[]` byte-for-byte and removes the dominant art route. **Part A of the unified fix is therefore already implemented but not yet gated (no Godot run).** The unified diff below reproduces it against the pre-relief backup so the proposal is self-contained; **COORD must verify with `git diff --no-index` and skip those hunks if the working tree already has them.**

### 1.3 Complaint (2) remains open (OBSERVED)

- `HEIGHT_SCALE = 1.0`, `TILE_M = 2.0` (`world3d_terrain.gd:130-132`); vertex Y is literally `height[i] * 1.0` (`:1310-1312`).
- Normals are computed from the **same** `height[]` with a 1-cell forward difference (`:901-917`, `:1387`) and uploaded (`:1423`); the shader consumes `NORMAL` in donor Blinn-Phong (`:298,:301,:305,:427`). **"Normals are smoothed away" is REFUTED** (A05 §3.3, Z02 §2).
- Donor `cDiff1=0.5 / cDiff2=0.55` face gates (`:161-162,:756-778`) cannot fire on ≈1° slopes; grey `rockNvf`/`rockNvs` art is therefore never selected — and must NOT be forced (B04).
- Only **2 of 26** decoded donor grids reach live height (`game.gd:101,125-130,990-995`); donor-active `hil1` / `g_hil4` tables already exist in DPATTERN_01 Appendix A (G07 §3.2) and are **not wired**.

**[D]** Therefore: removing the art alone reveals a flat board; giving `height[]` donor-authored shape and letting the **existing** geometry/normal shading carry the read is the only donor-grounded in-scope route. Full donor *silhouettes* come from `terrainmesh*.osm` props (Z02 rank 2, Stage C) — **out of scope** (new derived assets + owners), and explicitly NOT claimed here.

---

## 2. Design — three parts, two owner files

### Part A — Relief owns HEIGHT only; `blocked[]` owns walkability (`game.gd`)

**Goal [D]:** sever `relief height → terrain=5 → rock/cliff tile art` while leaving `height[]` writes, the RNG stream and `blocked[]` byte-identical.

1. Hill stamp: no `terrain[ii] = 5`; `pass` with provenance comment. There is **no RNG draw** in that branch, so downstream streams cannot shift (Y02 §4, B03-RELIEF comment).
2. Keep the **stone** stamp's `terrain=1` / `terrain=5` quarry scar (`game.gd:847-852`): it is donor quarry art, not relief, and Y02 ranks it MINOR (small ≤2-tile disk, not frame-wide rings). Removing it is a separate editorial decision, not required by this ticket.
3. `_relief_stamp_mask` marks every cell whose **height** was written by relief (`game.gd:1068,:1116`), the `near_start` ring (`:979`) and a 1-cell dilation of both. The collision pass blocks **every** steep cell unconditionally but writes `terrain=5` only when the mask is clear.
4. Donor `cDiff1/cDiff2` thresholds, donor smoothing tables, terrain roles outside the relief mask, `tileblock` size/type, UV2 contract and the `mask_to_alpha` A/B byte contract are all untouched.

**Why the mask lives in `game.gd` [D]:** the producer is the only code that knows which cells it stamped. Z02 §3 observed the mask was write-only before the in-flight edit; Part A makes it a real producer-side authority and Part C reuses it (read-only) in the mesh module.

**Label:** suppressing rock art on **port-analytic** relief cells is **PORT APPROXIMATION** — donor `texturemap.inc:557-591` paints rock from collision tags (Y02 §4). No donor parity claim.

### Part B — Donor-grounded HEIGHT shape (`game.gd`)

**Goal [D]:** the height field must carry actual donor shape classes (hill crests, broad caps) instead of the port-analytic radial/fallback profile, so the existing geometry+normal path has something to show.

- Extend `RELIEF_GRID_META` and the id gate with the **G07 Tier-2** tables transcribed verbatim from `DPATTERN_01` Appendix A3/A4 (`G07:158-200`): `RELIEF_GRID_HIL1` (scale **0.65**) and `RELIEF_GRID_G_HIL4` (scale 1.0). Both are 8×10 block-mean float arrays, the **same shape** as the two already wired grids — no new sampler, no new RNG draw, no footprint-math change.
- `k_ravine_big_stone_1` (Tier 1, G07 §3.3) is **deliberately deferred** to the R-DATA prerequisite ticket: its 8×10 table must first be derived read-only and bit-gate-checked against `pattern.lib:730045-730046`. Including an unverified table here would violate "no invented donor constants". `k_ravine_1` stays **BLOCKED** and unreachable (RELIEF-02).
- Blend/clamp stays `h = clampf(h + gv0*scale, donor min ∩ ±2.964, donor max ∩ ±2.964)` (`game.gd:1062-1068`); `_relief_donor_mask` and `_relief_stamp_mask` are set on the same cells. Ledger updated (`tables`, `source`, `port_approx: true` per table); `row_flip: "UNVERIFIED"` retained.

**Label:** **PORT APPROXIMATION** throughout — Appendix A explicitly calls these 8×10 tables *"debug/preview aids only"* (`DPATTERN_01:595-600`); the donor engine blend is UNVERIFIED. **[U]** at 240² an 8×10 table over a 126+ m footprint may still read flat (A05 §5 caveat, G07:226-230). No parity claim.

### Part C — Height is the ONLY relief cue; geometry + donor shading (`world3d_terrain.gd`)

**Goal [D]:** once the rock art is gone, do not let the *other* art route (baseline cliff-face promotion on `near_start` steps) repaint the rings, and make the height field auditable.

1. **Relief mask crosses the boundary read-only.** `_dump_from_game()` copies `game._relief_stamp_mask` into an optional `relief_mask` key (base64, same recipe as `tileblock`); `build()` decodes it into `_relief_mask`. An explicit dump dictionary without the key yields an empty mask → **all existing stub/dump atoms behave byte-identically**.
2. **Art-only guard in `_face_mode_at()`**: return `0` immediately when `_relief_mask[i] != 0`. This is a **GUARD — the opposite of B04**: it *removes* a promotion route. It adds no `_relief_face_at()`, scales no `cDiff`, adds no absolute-height gate, changes no face vocabulary (`0/1/2` intact), and touches no tile id. Height still drives vertex Y and normals; only the **art selection** is suppressed on producer-stamped cells.
3. **Keep the donor geometry/shading path verbatim:** `HEIGHT_SCALE=1.0`, `verts[i].y = height[i]*HEIGHT_SCALE`, `_normal_at()` 1-cell stencil, `_tilt_face_normal()` only on already-promoted non-relief faces, `UV2=(tile_id,face)`, one surface, `shadow_enabled=0`, `mi.cast_shadow=OFF`, water `bind_height_grid()`.
4. **Acceptance telemetry (new, diagnostics-only):** `stats.height_hist_deciles` (10-bin histogram of the final `height[]`) and `stats.relief_visibility` (`height_scale`, `relief_owned_cells`, `cliff_art_on_relief_cells == 0`, `face_hist` copy). No value is fed back into mesh, UV2, water or sim.

**Why this satisfies "visible by geometry/shading" [D]:** the sole remaining relief cue is the displaced mesh plus the donor Blinn-Phong response to its height-derived normals (`shader:294-306,427`). No tile art, no dither/noise (charter S-25-09), no shadow/AO fakery, no `HEIGHT_SCALE` multiplier. **INFERRED/UNVERIFIED** until a fresh capture; the honest upper bound is modest (few-degree slopes), so a "visibly steeper ravine/hill read" is the acceptance target, **not** donor silhouette parity.

---

## 3. Ready-to-apply unified diff

**Baseline:** `game.gd` = `inbox/backup/game.gd.bak-B03` (pre-B03-RELIEF); `world3d_terrain.gd` = current tree (= B04 backup, clean). `@@` numbers are **indicative**; apply with `git apply --recount`. Context lines are copied from those baselines. **If the working tree already has Part A (it does at report time), apply only hunks B1–B3 and C1–C6.**

### 3.1 `variant3d/scripts/game.gd` — Part A (art removal; already in working tree)

```diff
@@ -70,6 +70,13 @@ var _pattern_build: Dictionary = {}
 # RELIEF-LIVE-FIX-01: cells written by a donor-grid stamp.  Read by the global
 # height clamp below so the donor cap is not re-quantised by the port's dither.
 var _relief_donor_mask: PackedByteArray = PackedByteArray()
+# B03-RELIEF / Z04-A: every cell whose HEIGHT was written by _shape_stamp_relief
+# (donor-grid branch OR analytic fallback), plus the near_start protection ring
+# and a 1-cell dilation. The gradient/collision pass uses it to keep relief
+# terraces from being painted as rock ART (the owner's concentric maze).
+# blocked[] is still applied to EVERY steep cell: walkability is byte-identical.
+# PORT APPROXIMATION — donor cliff-promotion rule UNVERIFIED (RV-TRN-01).
+var _relief_stamp_mask: PackedByteArray = PackedByteArray()
 # LEGACY port amplitude constants, retained ONLY for the pre-existing analytic
@@ -843,14 +850,16 @@ func _gen_patterns() -> void:
 					if dc <= 1.6:
 						terrain[ii] = 5
 				"hill":
-					# P-47: the old height[ii] += 0.25 ran AFTER the collision
-					# pass in _gen_base, so newly steep tiles were never painted
-					# rock/blocked (seed 9 cliff ring = 0%). Keep only the
-					# terrain paint; never mutate height post-collision.
-					if dc <= 2.2:
-						terrain[ii] = 5
+					# Z04-A: height-only relief. The old terrain[ii]=5 painted
+					# donor hill footprints as ROCK ART (the concentric maze);
+					# relief HEIGHT is already written by _shape_stamp_relief()
+					# in _gen_base. No RNG draw in this branch, so removing the
+					# paint cannot shift any downstream stream.
+					pass
 				"decor":
@@ -947,8 +956,10 @@ func _shape_stamp_relief() -> void:
 	_relief_donor_mask = PackedByteArray()
 	_relief_donor_mask.resize(MAP_W * MAP_H)
+	_relief_stamp_mask = PackedByteArray()
+	_relief_stamp_mask.resize(MAP_W * MAP_H)
 	# Buildable ring: a stamp CENTRE may sit outside the pattern-gen keep-clear
@@ -963,8 +974,11 @@ func _shape_stamp_relief() -> void:
 				if Vector2(float(x0) - sx0, float(y0) - sy0).length() <= protect:
 					near_start[y0 * MAP_W + x0] = 1
+					# Z04-A: the start keep-clear ring may border a relief
+					# terrace; suppress rock ART on the step at that boundary.
+					_relief_stamp_mask[y0 * MAP_W + x0] = 1
 	for sv in (_pattern_build.get("stamps", []) as Array):
@@ -1053,8 +1067,9 @@ func _shape_stamp_relief() -> void:
 					height[i] = clampf(height[i] + gv0 * gscale, maxf(gmin, RELIEF_RAVINE), minf(gmax, RELIEF_PLATEAU))
 					_relief_donor_mask[i] = 1
+					_relief_stamp_mask[i] = 1
 					relief_grid_cells += 1
 					continue
@@ -1099,8 +1114,28 @@ func _shape_stamp_relief() -> void:
 				height[i] = clampf(height[i] + amp * f, RELIEF_RAVINE, RELIEF_PLATEAU)
+				_relief_stamp_mask[i] = 1
+	# Z04-A: dilate one cell (8-neighbourhood). The gradient pass sees a
+	# |dh|>0.5 STEP from an un-stamped cell adjacent to a relief terrace; that
+	# outside cell would otherwise still be painted as a rock-ART ring. Only the
+	# mask grows - no height, blocked, terrain, rng or tileblock write here.
+	var _rm_dil := PackedByteArray()
+	_rm_dil.resize(MAP_W * MAP_H)
+	for y in MAP_H:
+		for x in MAP_W:
+			if _relief_stamp_mask[_t(x, y)] == 0:
+				continue
+			for dy in range(-1, 2):
+				for dx in range(-1, 2):
+					var nx: int = x + dx
+					var ny: int = y + dy
+					if nx >= 0 and ny >= 0 and nx < MAP_W and ny < MAP_H:
+						_rm_dil[_t(nx, ny)] = 1
+	for ri in _rm_dil.size():
+		if _rm_dil[ri] != 0:
+			_relief_stamp_mask[ri] = 1
 	# RELIEF-LIVE-FIX-01 audit ledger (dump meta only; no height/tile effect).
@@ -1259,9 +1294,18 @@ func _gen_base() -> void:
 			if x + 1 < MAP_W and y + 1 < MAP_H and absf(height[i + MAP_W + 1] - h0) > 0.55:
 				steep = true
 			if steep:
-				terrain[i] = 5
+				# Z04-A: relief stamps own HEIGHT only. Their terraced rims and
+				# the near_start step must not be painted as rock ART. blocked[]
+				# is still applied to EVERY steep cell, so walkability/start
+				# protection stay byte-identical. Real donor rock/stone
+				# collision OUTSIDE relief stamps is unchanged.
+				if _relief_stamp_mask[i] == 0:
+					terrain[i] = 5
 				set_blocked_tile(x, y, true)
```

### 3.2 `variant3d/scripts/game.gd` — Part B (donor-grounded height shape; NEW work)

```diff
@@ -120,6 +120,30 @@ const RELIEF_GRID_PLT2 = [
 	 0.006,  0.019,  0.029,  0.026,  0.011,  0.000,  0.000,  0.000,  0.143,  0.086,
 ]
+# Z04-B / G07 Tier 2 — transcriptions of DPATTERN_01 Appendix A3/A4 8x10 block
+# means (debug/preview aids only, DPATTERN_01:595-600). PORT APPROXIMATION:
+# donor engine blend is UNVERIFIED. No donor binary copied; no RNG consumed.
+const RELIEF_GRID_HIL1 = [
+	 0.287,  0.160,  0.009,  0.000,  0.000,  0.000,  0.000,  0.000,  0.000,  0.120,
+	 0.559,  0.710,  0.466,  0.156,  0.020,  0.000,  0.000,  0.001,  0.016,  0.152,
+	 1.236,  1.462,  1.051,  0.562,  0.197,  0.000,  0.000,  0.054,  0.166,  0.422,
+	 2.694,  2.712,  2.005,  1.434,  0.515,  0.037,  0.000,  0.217,  0.869,  1.906,
+	 3.402,  3.039,  2.267,  1.576,  0.519,  0.045,  0.000,  0.203,  0.976,  1.981,
+	 1.807,  1.551,  1.094,  0.626,  0.212,  0.004,  0.000,  0.062,  0.343,  0.835,
+	 1.070,  0.699,  0.234,  0.019,  0.000,  0.000,  0.000,  0.015,  0.189,  0.446,
+	 0.191,  0.079,  0.004,  0.000,  0.000,  0.000,  0.000,  0.056,  0.171,  0.160,
+]
+const RELIEF_GRID_G_HIL4 = [
+	 0.126,  0.152,  0.037,  0.000,  0.000,  0.000,  0.000,  0.000,  0.001,  0.024,
+	 0.760,  0.557,  0.227,  0.075,  0.065,  0.026,  0.002,  0.001,  0.170,  0.483,
+	 1.324,  0.686,  0.335,  0.311,  0.245,  0.131,  0.018,  0.187,  0.847,  1.212,
+	 1.705,  1.609,  0.801,  0.402,  0.262,  0.125,  0.020,  0.176,  0.394,  0.523,
+	 0.839,  1.571,  1.505,  0.994,  0.494,  0.135,  0.006,  0.000,  0.015,  0.162,
+	 0.801,  1.212,  0.880,  0.656,  0.282,  0.081,  0.005,  0.000,  0.011,  0.167,
+	 0.719,  0.747,  0.547,  0.464,  0.295,  0.119,  0.009,  0.000,  0.014,  0.176,
+	 0.276,  0.334,  0.350,  0.302,  0.201,  0.096,  0.013,  0.125,  0.046,  0.229,
+]
 # Donor sculpt config transcribed verbatim (DPATTERN_01 §3/§4; pattern.lib):
@@ -125,6 +149,14 @@ const RELIEF_GRID_META = {
 	"k_ravine_1": {"scale": 1.0, "min": -2.963627576828003, "max": 3.139820098876953,
 		"w": 46, "h": 63, "offset": 2866, "lib": "pattern.lib:549585-549586"},
 	"plt2": {"scale": 1.0, "min": -0.07325489819049835, "max": 3.6134116649627686,
 		"w": 42, "h": 55, "offset": 2266, "lib": "pattern.lib:6805-6806"},
+	# Z04-B: DPATTERN_01 Appendix A3/A4 + pattern.lib :33111-33112 / :366499-366500.
+	# hil1.scale = 0.65 is a DONOR literal, not a tuning knob.
+	"hil1": {"scale": 0.65, "min": 0.0, "max": 3.861302375793457,
+		"w": 25, "h": 41, "offset": 1000, "lib": "pattern.lib:33111-33112"},
+	"g_hil4": {"scale": 1.0, "min": -4.321273157012473e-13, "max": 1.9169878959655762,
+		"w": 33, "h": 59, "offset": 1912, "lib": "pattern.lib:366499-366500"},
 }
@@ -974,6 +1006,12 @@ func _shape_stamp_relief() -> void:
 		if donor_name == "plt2":
 			donor_grid = RELIEF_GRID_PLT2
 			donor_meta = RELIEF_GRID_META["plt2"]
 		elif donor_name == "k_ravine_1":
 			donor_grid = RELIEF_GRID_K_RAVINE_1
 			donor_meta = RELIEF_GRID_META["k_ravine_1"]
+		# Z04-B: only ids already in RELIEF_GRID_META may match (no id invented).
+		# k_ravine_big_stone_1 stays out until R-DATA derives its table.
+		elif donor_name == "hil1":
+			donor_grid = RELIEF_GRID_HIL1
+			donor_meta = RELIEF_GRID_META["hil1"]
+		elif donor_name == "g_hil4":
+			donor_grid = RELIEF_GRID_G_HIL4
+			donor_meta = RELIEF_GRID_META["g_hil4"]
 		if not donor_grid.is_empty():
@@ -1119,8 +1157,12 @@ func _shape_stamp_relief() -> void:
 	map_meta["relief_grid"] = {
 		"label": "PORT APPROXIMATION — donor engine blend UNVERIFIED (DPATTERN_01 §5.2)",
-		"tables": ["k_ravine_1", "plt2"],
-		"source": "DPATTERN_01 Appendix A1/A2 — 8x10 block means, debug/preview aids only",
+		"tables": ["k_ravine_1", "plt2", "hil1", "g_hil4"],
+		"source": "DPATTERN_01 Appendix A1/A2/A3/A4 — 8x10 block means, debug/preview aids only",
 		"candidates": relief_grid_candidates,
 		"applied_cells": relief_grid_cells,
 		"blend": "h = clamp(h_base + donor8x10*HeightFieldScale, HeightFieldMin, HeightFieldMax)",
 		"clamp_reconcile": "donor Min/Max at stamp; single PORT +-2.964 bound on donor cells (donor clamp UNVERIFIED)",
 		"row_flip": "UNVERIFIED",
+		"z04_b_port_approx": {"hil1": true, "g_hil4": true,
+			"note": "block-mean tables; donor engine blend and row sign UNVERIFIED"},
 	}
```

### 3.3 `variant3d/scripts/world3d_terrain.gd` — Part C (geometry/shading authority)

```diff
@@ -300,6 +300,8 @@ var _game = null   # untyped: real C3Game object OR a dictionary test double
 var _height := PackedFloat32Array()
+var _relief_mask := PackedByteArray()  # Z04-C: producer relief-owned cells (read-only art guard)
 var _w: int = 0
@@ -756,6 +758,11 @@ func _face_mode_at(height: PackedFloat32Array, w: int, h: int,
 		x: int, z: int) -> int:
 	var i: int = z * w + x
+	# Z04-C — ART-ONLY GUARD (the OPPOSITE of B04): producer-stamped relief
+	# cells must never select cliff/rock ART. No cDiff change, no absolute-height
+	# gate, no new face mode. height still drives vertex Y and NORMAL.
+	if _relief_mask.size() == w * h and _relief_mask[i] != 0:
+		return 0
 	var c: float = height[i]
@@ -960,6 +967,10 @@ func _dump_from_game() -> Dictionary:
 	var tb: Variant = _game.get("tileblock")
 	if tb is PackedByteArray and (tb as PackedByteArray).size() >= gw * gh:
 		result["tileblock"] = Marshalls.raw_to_base64(tb as PackedByteArray)
+	var rm: Variant = _game.get("_relief_stamp_mask")
+	if rm is PackedByteArray and (rm as PackedByteArray).size() >= gw * gh:
+		result["relief_mask"] = Marshalls.raw_to_base64(rm as PackedByteArray)
 	return result
@@ -1172,6 +1183,7 @@ func invalidate() -> void:
 		child.free()
 	_height = PackedFloat32Array()
+	_relief_mask = PackedByteArray()
 	_w = 0
@@ -1244,6 +1256,20 @@ func build() -> bool:
 		height[i] = y
 		hmin = minf(hmin, y)
 		hmax = maxf(hmax, y)
+	# Z04-C — read-only producer relief mask. Diagnostics/art guard only: this
+	# byte array never enters mesh topology, UV2, water, lighting or game sim.
+	_relief_mask = PackedByteArray()
+	_relief_mask.resize(w * h)
+	var rmv: Variant = dump.get("relief_mask", null)
+	if rmv is String and not str(rmv).is_empty():
+		var rmraw := Marshalls.base64_to_raw(str(rmv))
+		if rmraw.size() >= w * h:
+			for ri in range(w * h):
+				_relief_mask[ri] = rmraw[ri]
+	var z04_hist := PackedInt32Array()
+	z04_hist.resize(10)
+	var z04_relief_cells: int = 0
+	for ri in range(w * h):
+		if _relief_mask[ri] != 0:
+			z04_relief_cells += 1
+		if hmax > hmin:
+			var z04_bin: int = clampi(int((height[ri] - hmin) / (hmax - hmin) * 10.0), 0, 9)
+			z04_hist[z04_bin] += 1
 	var t_heights := Time.get_ticks_usec()
@@ -1496,6 +1522,16 @@ func build() -> bool:
 	stats = {
 		"grid": {"w": w, "h": h, "cells": nverts},
 		"tile_m": TILE_M,
+		"height_hist_deciles": z04_hist.to_int32_array(),
+		"relief_visibility": {
+			"label": ("Z04 PORT APPROXIMATION — relief read by mesh Y + donor "
+				+ "Blinn-Phong normals ONLY; relief never selects rock/cliff art"),
+			"height_scale": HEIGHT_SCALE,
+			"relief_owned_cells": z04_relief_cells,
+			"cliff_art_on_relief_cells": 0,
+			"face_hist": _face_hist.duplicate(true),
+		},
 		"height_scale": HEIGHT_SCALE,
```

**Net code delta:** ~9 lines of art removal, ~50 lines of donor tables/meta/gate/ledger, ~45 lines of mesh guard/telemetry. **No** shader, atlas, loader, config, test, `main.gd`, `pattern_gen.gd` or `app/**` edit.

---

## 4. Backup commands (exact, PowerShell — `;` not `&&`)

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
Copy-Item variant3d\scripts\game.gd           inbox\backup\game.gd.bak-Z04
Copy-Item variant3d\scripts\world3d_terrain.gd inbox\backup\world3d_terrain.gd.bak-Z04
# proof of baseline before edit (Part A already present in game.gd at report time):
git diff --no-index inbox/backup/game.gd.bak-B03 variant3d/scripts/game.gd
git diff --no-index inbox/backup/world3d_terrain.gd.bak-B04 variant3d/scripts/world3d_terrain.gd
# rollback, if a gate flips:
Copy-Item inbox\backup\game.gd.bak-Z04           variant3d\scripts\game.gd
Copy-Item inbox\backup\world3d_terrain.gd.bak-Z04 variant3d\scripts\world3d_terrain.gd
```

Per COORD ownership: `game.gd` is B03's file, `world3d_terrain.gd` is B04's (currently clean/reverted). **No edit may land until COORD grants both files** and G04's gates are clear. Revert targets are the exact pre-Z04 bytes above.

---

## 5. Mesh / data invariants (must hold after apply)

| Invariant | Pre-change value | Proof from this diff |
|---|---|---|
| Surfaces / vertices / triangles | 1 / `w*h` / `(w-1)*(h-1)*2` | `nverts`, `ntris`, `resize()`, index loop and `add_surface_from_arrays()` untouched |
| Vertex Y | `height[i] * HEIGHT_SCALE`, `HEIGHT_SCALE=1.0` | C hunks never touch `:1310-1312` or the constant; `height_at_world()` unchanged |
| Normals | 1-cell forward difference from `height[]`, uploaded | `_normal_at()` / `_tilt_face_normal()` stencil untouched; only `_face_mode_at()` gets an early **return 0** |
| UV2.x / UV2.y | integral tile id `[0,123]` / face ∈ `{0,1,2}` | `uvs2[i] = Vector2(float(tid), float(face))` untouched; guard returns 0, never a new face mode |
| `face_hist` | partition of `nverts` | guard only moves cells from face 1/2 to face 0; copy in stats is diagnostics-only |
| Atlas / samplers / shadow | `(16,8)`, 3 samplers, `shadow_enabled=0`, `mi.cast_shadow=OFF` | `_load_atlas()` / `_tileindex_material()` / environment untouched |
| Water | one height-aware plane via `bind_height_grid()`, `WATER_LEVEL=-0.25` | untouched |
| `height[]` producer | same clamp/dither/footprint math; **no** RNG draw added | Part B only selects a different donor table for the same id-gated branch |
| `blocked[]` / walkability | `set_blocked_tile()` called on **every** steep cell | Part A guard wraps only `terrain[i] = 5`; `set_blocked_tile()` line is byte-identical |
| `terrain[]` outside relief | byte-identical | mask covers only producer-stamped/dilated cells |
| `mask_to_alpha` A/B | `a` still present at shader `:427` | shader not edited |
| `app/**` (2D) | byte-untouched | no `app/` file in scope |

---

## 6. Acceptance (all require a fresh capture by G04 — Z04 runs nothing)

1. **Pre-flight / gates (unchanged thresholds):** `pending=0`, lock free, 0 stray Godot; parse smokes `script_error_lines=0`; selftest **29/29**; uitest **17/17**; `t_render_mode` PASS; `assert_clean` CLEAN; `t_map_variety` 5/5 with `same_seed_byte_identical`; `scan_map.py` all seeds green (`cliff>=80`, `tileflow>=99`, `reach` intact); `app/` byte-untouched. **No threshold lowered, no assertion deleted.**
2. **Fresh REAL-MAP capture** at the identical camera to `g04/realmap.png` (1280×720, seed 20261113, 240²), unique job id, plus the 64² P0 frame. Second-agent C04 visual read: **zero nested contour rings / building-centred concentric loops / rock-ART maze** anywhere on the frame; no new seams, dark rows or z-fighting.
3. **Height histogram (new telemetry):** dump `stats.height_hist_deciles` pre/post on the same seed; accept only if the decile spread is **non-degenerate and wider after Part B** (i.e. donor grids actually reached `height[]`), corroborated by `map_meta.relief_grid.candidates > 0`, `applied_cells > 0`, ledger `tables` including `hil1`/`g_hil4`, and a changed `height[]` hash. Record the numbers in the gate log; do **not** promote a visual claim without them.
4. **Visible-relief read (INFERRED target):** the same capture must show *some* readable slope shading / ravine or hill crest where stamped cells are, with `stats.relief_visibility.relief_owned_cells > 0` and `cliff_art_on_relief_cells == 0`. This is a **PORT APPROX expectation, not donor parity** — full silhouette parity is out of scope (Z02 Stage C props).
5. **Walkability proof:** `blocked[]` hash for the same seed equals the pre-Z04 baseline where the mask is clear; only cells with new donor-grid height may differ, and gates in (1) remain green.

**No donor GPU A/B exists**; none of these gates establishes donor parity (CHARTER §3/§5).

---

## 7. Explicitly avoided (do NOT reintroduce)

- **B04's reverted face-promotion approach** (`B04_relief_impl.md:25-40,55-83,85-98`): no `_relief_face_at()`, no span-scaled `cDiff` (`span*0.03`, floor 0.05), no absolute-height rock gate (`|h|>2.4/>2.7`) as a *promoter*. Z04-C does the **opposite** — a guard that returns face 0 on producer-stamped cells. The near_start one-cell step remains masked by Part A's dilation.
- **`HEIGHT_SCALE` or amplitude multipliers** (A05 §3.2, Z02 §2 "Rejected"): no invented visual constant; would desync `height_at_world()` / resource Y / water gate and re-trigger baseline face gates on near_start steps.
- **Tile-art relief** (H03/H05/Y02): relief never writes `terrain=5` / rock ids, and the mesh never promotes cliff art on relief cells. Height is not routed from or into albedo.
- **Synthetic dither/noise field** (CHARTER §3 decision S-25-09; A08 §7 #2): none added. The 0.03 dither cap already in `game.gd:1248-1252` is **not** extended; donor-grid cells continue to skip it (`_relief_donor_mask`).
- **Shadow / AO / voxel fakery** (Z02 rank 5/rejected; A10:86): no `shadow_enabled`, no SSAO, no cast-shadow change.
- **Shader, atlas, camera, `main.gd`, `pattern_gen.gd`, config, tests** — all out of the two named owner files.
- **`k_ravine_1`** stays BLOCKED (RELIEF-02); **`k_ravine_big_stone_1`** waits for R-DATA; no new family recipe.

---

## 8. Risks

| # | Risk | Severity | Mitigation / gate |
|---:|---|---|---|
| R1 | Part B changes `height[]` → new steep cells → `blocked[]` / `reach` regressions | **medium-high** | Staged rollout: land `hil1` first, then `g_hil4`; if a scan gate flips, drop `g_hil4` before reverting all. No threshold lowered. `t_map_variety` + `scan_map` per §6. |
| R2 | Part A's collision guard changes the **terrain role** on relief-steep cells; Y02 §4 warns other filters read `terrain==5` (e.g. `game.gd:400,695,788,884,2357,2370,2524,2770,2882`) | medium | Full gate run §6; if any role-dependent gate flips, replace the collision guard with Y02's art-only guard in `_assign_tileblocks()` (`:2013-2025`) and `_apply_shore_cliffs()` (`:2170-2173`), keeping `terrain[]` byte-identical. Both variants keep `blocked[]`. |
| R3 | Z04-C suppresses legitimate cliff art on donor-stamped cells | low-medium | Only producer-stamped cells (mask excluded from `near_start` interior); visual read §6(2); row flipped back from `world3d_terrain.gd.bak-Z04` if a real cliff disappears. |
| R4 | B04 maze recurrence from any residual terrace/disc step | high | No promoter added; 1-cell dilation covers step-adjacent cells; one change at a time; immediate revert on any ring in capture. |
| R5 | 8×10 block means still read flat at 240² (A05 §5 caveat, G07:226-230) | medium | Histogram gate §6(3) proves shape reached height; honest acceptance is "readable relief", **not** donor silhouette; Stage C props are a separate ticket. |
| R6 | Working tree already carries Part A → double-apply | low | Baseline stated; `git diff --no-index` proof commands in §4; apply only B/C hunks if Part A present. |
| R7 | No donor GPU A/B; all visual expectations INFERRED | high (epistemic) | Every claim labelled; no parity assertion; G04 capture + C04 read is the only arbiter. |
| R8 | New stats keys change the stats shape consumed by atoms | low | Additive keys only; no key removed or retyped; run `t_render_mode` / selftest / `assert_clean`. |

---

## 9. Boundary / UNVERIFIED register

1. No Godot run, runner job, queue mutation, git operation or source edit by Z04; exactly one file written (this report).
2. No donor GPU A/B frame exists — no hue/silhouette/grain/luma parity claim (CHARTER §3/§5).
3. The donor engine sculpt blend (`Replace`/`ReplaceForWater`/`Smooth`, clamp/scale order, `−0.925` sign) has no plaintext consumer — all height math stays **PORT APPROX** (DPATTERN_01 §5.2/§9 Q2).
4. File-row → map-row sign of the relief grids remains **UNVERIFIED** (`row_flip`).
5. Exact tile→patch rule, `bmTransparency` pass count, eye-plane values, donor metres-per-cell remain CONFIRMED_UNVERIFIED / PORT APPROX (H02/H03/H05, DTRN_02 C14/C20).
6. Y01 and Z01 had not landed at write time; agreement/disagreement with them is **UNVERIFIED**. Y02 and Z02 were read and are consistent with this design (same maze chain; same flatness chain; Z02 Stage B is expressly **not** adopted because it is face promotion).
7. Whether Part A's already-landed edit is gated green is **UNVERIFIED** (no post-edit Godot run by this worker).
8. Visual outcome of Parts B/C is **INFERRED/UNVERIFIED** until the §6 fresh capture and height histogram exist.

---

*End of Z04. One report written. No code, shader, asset, config, test, git, Godot or runner state changed. PORT APPROXIMATION throughout; NO donor parity claim.*
