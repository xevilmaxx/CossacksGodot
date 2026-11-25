---
id: P12-HUD-FIX-PROPOSAL
ticket: P12 (WAVE P / performance)
title: "P12 — exact low-risk per-frame HUD / minimap cost reduction (PROPOSAL ONLY, do not apply yet)"
owner: P12 read-only subagent
date: 2026-11-25
status: READ_ONLY_PROPOSAL__NO_CODE_EDITS__NO_RUNNER_JOB__NO_GODOT
scope: "Exactly one repo file written: this report. variant3d/scripts/hud.gd and hud3d_adapter.gd were READ ONLY; no backup was created, no patch applied, no Godot process or runner job submitted."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
---

# P12 — per-frame HUD / minimap cost reduction (proposal, not landed)

## 0. Authority and preconditions

- `WAVE_G_CHARTER.md:31,67` — **only G04 runs Godot / runner jobs.** P12 ran none.
- `WAVE_G_CHARTER.md:85-87` — P12's exclusive ownership is `variant3d/scripts/hud.gd` +
  `variant3d/scripts/hud3d_adapter.gd`; backups `inbox/backup/<name>.bak-P12` are required
  **before** any edit. This report is the only write; **COORD must grant ownership before the
  hunks in §4 are applied**, and G04 is running gates in the meantime.
- `CHARTER.md:55-69` — observed / derived / inferred / UNVERIFIED separation; no test
  weakening; disjoint file ownership; backups before edits.
- **P04 status (observed):** `reports/P04_hud_cost.md` is **NOT present** in
  `docs/terrain_swarm_2026-11-25/reports/` at the time of this read (glob `reports/P0*`
  and `reports/P1*` returned no files). The earlier `docs/coord_swarm_2026-11-24/reports/
  P04_tooling_perf.md` is a *different* P04 (tooling/startup recon) and is not the HUD audit.
  All findings below are therefore **P12's own direct source reads** of the current tree,
  not a restatement of a landed P04 report.

**No FPS number is claimed.** Every performance statement here is code-derived; actual FPS
impact is **UNVERIFIED** because no capture, run or runner job was made (§7).

## 1. Cost inventory (observed source, derived cost)

| # | file:line | What happens every rendered frame today | Cost class | Patch |
|---:|---|---|---|---|
| C1 | `hud.gd:1454-1504` | `for i in 6` builds `str(Data.RES_NAMES[i])`, `str(stock)`, `"(%d-%d)" % [...]`, `"%s  %s" % [...]`, `"idle %d"`, `"slots %d"`, `"units %d/%d score %d %s" % [...]` — **~15 string formats + 6 dict lookups + 2 dictionary reads per frame**, even though `_recompute_eco()` already runs only on `eco_t <= 0.0` (0.5 s). The *assignments* are dirty-flagged (`:1465-1470,1482-1495,1502-1504`), but the formatting is not. | **derived** — allocation/format churn, not an engine measurement | H1 |
| C2 | `hud.gd:1516` → `hud.gd:1673,1688` | `_draw_minimap_viewport_box()` is called every frame. The final `box == _mm_box_last` gate (`:1697-1698`) already suppresses the *pixel repaint + `minimap_tex.update()`* when the camera is still, but `get_viewport()` is looked up twice per frame and the camera ray-casting happens **before** that gate. | **derived** | H2, H3 |
| C3 | `hud.gd:1680` → `hud3d_adapter.gd:73-94,103-137` → `camera3d.gd:397-404` | In 3D (shipped mode) each box poll calls `_hud3d_adapter.get_minimap_box()` → `get_minimap_corners()` → `cam.get_viewport_corners()`, which performs **four `screen_to_world()` ray casts** (each `project_ray_origin` + `project_ray_normal`), allocates an `Array` and a `PackedVector2Array`, then re-reads `hud.get("game")` / `int(g.MAP_W)` / `int(g.MAP_H)` twice. On a still camera this is pure waste. | **derived** | H3, H4 |
| C4 | `hud3d_adapter.gd:74-76,105-107` | Repeated dynamic reads of `hud.game` and `int(g.MAP_W/MAP_H)` on every box poll. | **derived** (minor) | H4 |
| C5 | `hud.gd:1443-1523` | `fps` text (`:1446-1448`), `_recompute_eco()` (`:1450-1452`), minimap tick (`:1509-1512`), `_update_dynamic()` (`:1519-1523`) are **already** cadenced — do not change them. | observed | none |

**Explicit negative finding (observed):** neither file contains a `get_node()` call. The
hot-path lookups that correspond to the ticket's "avoid `get_node` in hot paths" instruction
are `get_viewport()` / `get_camera_2d()` (`hud.gd:1673,1688,1613`) and the adapter's
`hud.get("game")` (`:74,105`). `get_tree().get_first_node_in_group("c3_input")` at
`hud.gd:658,664,1622` is **event-driven**, not per-frame, and is deliberately left untouched.

**Already-landed prior work that must not be undone** (observed): `T-PERF-RENDER` dirty flags
(`hud.gd:89-94,1465-1470,1482-1495,1502-1504`), `_cached_ucount` (`:31-33,1453,1497`),
fog-base caching (`:59-62,1978-1989`), res/building blip revision caches (`:63-88,1992-1994,
2024-2026`), the box border-only repaint (`:1663-1704`), and `show_hint()`'s no-op guard
(`:1342-1346`). This patch adds **no new allocation** in the per-frame path; it only removes
work.

## 2. Design rules for the patch

1. **No layout, geometry or config change.** `_layout_top()` (`hud.gd:513-595`),
   `_mm_size/_mm_inset/_mm_corner` (`:283-299`) and every one of their call sites
   (`:331,344,1566,1585,1595`) are byte-untouched. UI-TOPBAR-01's responsive bar and
   CONFIG-WIRE-HUD's three getters keep their exact behaviour.
2. **No test weakening.** No threshold, assertion, expected count or fixture is edited.
3. **Behaviour-preserving gates.** H1 reuses the *existing* 0.5 s `eco_t` poll instead of
   inventing a new timer. H2/H3 keep the same-frame F3 contract: input handlers move the
   camera *before* calling `_draw_minimap_viewport_box()`, so a changed transform always
   passes the gate; `force=true` from `_update_minimap()` (`:2035`) bypasses it entirely.
4. **Self-healing.** Even if a camera property outside the signature changed, the 0.25 s
   default `Data.MINIMAP_INTERVAL` (`data.gd:154`) forces a full redraw through
   `_draw_minimap_viewport_box(true)` (`hud.gd:2035`), bounding any staleness.

## 3. Expected savings (DERIVED — impact on FPS UNVERIFIED)

- H1: ~15 `%`/`str()` operations and ~10 dictionary/property reads **per frame** reduced to
  **2 Hz**. Rendered strings are identical because the inputs are already polled at that
  cadence (`worker_counts`/`upkeep_workers`/`gold_deficit`/`ammo_blocked` from
  `_recompute_eco()`; `_cached_ucount` from the same branch).
- H3: four engine ray casts + two dynamic property reads + two packed-array allocations
  per frame → zero on frames where the 3D camera transform and `fov` are unchanged. This is
  the largest single minimap win in this patch.
- H2/H4: two `get_viewport()` lookups per frame removed; adapter map-size reads cached.

**UNVERIFIED:** none of the above has been timed. No FPS, frame-time, CPU/GPU utilisation or
capture number is asserted by this report; a real capture/run by the runner owner is required
before any claim (P09/G04 territory).

## 4. Exact patch (unified diff — DO NOT APPLY UNTIL COORD GRANTS OWNERSHIP)

Apply with `git apply --recount` so line-count drift is tolerated; both files are plain LF
as read from the working tree. The two diffs below are complete: no other hunk is needed.

### 4.1 `variant3d/scripts/hud.gd`

```diff
--- a/variant3d/scripts/hud.gd
+++ b/variant3d/scripts/hud.gd
@@ -89,10 +89,19 @@
 # T-PERF-RENDER: last pushed texts — Label.text assignment costs a relayout
 # even when the string is identical, so every per-frame label is dirty-flagged.
 var _last_res_text: Array = []
 var _last_eco_text := ""
 var _last_mines_text := ""
 var _last_status_text := "\n"
+# P12: the CanvasLayer viewport is stable for the HUD's lifetime; cache it at
+# bind() instead of calling get_viewport() on every _process frame.
+var _vp: Viewport = null
+# P12: minimap-box change gate. The 3D adapter ray-casts four camera corners
+# per call, so a still camera must not pay that cost every frame. Sentinels
+# force the first draw; _on_vp_resize()/bind_3d() invalidate on projection or
+# camera changes. force=true (minimap ticks) always bypasses the gate.
+var _mm_box_cam_xform := Transform3D()
+var _mm_box_cam_fov := -1.0
+var _mm_box_cam2_pos := Vector2.INF
+var _mm_box_cam2_zoom := Vector2.ZERO
 var fps_label: Label
 var fps_t := 0.0
 var fps_ema := 60.0
@@ -174,6 +174,7 @@
 func bind(g: C3Game, w) -> void:
 	game = g
 	world = w
+	_vp = get_viewport()  # P12: cached for the per-frame minimap box painter
 	ui_us = _calc_us()
 	icons_tex = load("res://assets/ui/icons.bmp")
 	units_tex = load("res://assets/ui/iconsunits.bmp")
@@ -218,4 +218,7 @@
 	_hud3d_adapter.bind(cam, self)
 	_bound_cam3d = cam
 	_render_mode_3d = true
+	# P12: a rebound camera invalidates the minimap box change signature.
+	_mm_box_cam_fov = -1.0
+	_mm_box_cam2_pos = Vector2.INF
 
@@ -273,5 +273,8 @@
 func _on_vp_resize() -> void:
 	ui_us = _calc_us()
 	_apply_scale()
+	# P12: projection size changed even if the camera transform did not.
+	_mm_box_cam_fov = -1.0
+	_mm_box_cam2_pos = Vector2.INF
 
 # CONFIG-WIRE-HUD: minimap geometry now reads the global feature config through
@@ -1445,11 +1461,14 @@
 	fps_t -= dt
 	if fps_t <= 0.0 and fps_label != null:
 		fps_t = 0.5
 		fps_label.text = "%03d" % int(Performance.get_monitor(Performance.TIME_FPS))
 	eco_t -= dt
-	if eco_t <= 0.0:
+	# P12: all formatted read-outs below are polled on this existing 0.5 s
+	# cadence instead of being rebuilt (and dirty-checked) every frame.
+	var readouts_due := eco_t <= 0.0
+	if readouts_due:
 		eco_t = 0.5
 		_recompute_eco()
 		_cached_ucount = game.unit_count(0) + game.queue_count(0)
-	for i in 6:
+	for i in (6 if readouts_due else 0):  # P12: no string work on idle frames
 		var rname: String = str(Data.RES_NAMES[i])
@@ -1481,5 +1500,5 @@
-	if eco_label != null:
+	if readouts_due and eco_label != null:
 		var et := "idle %d" % idle_count
 		if et != _last_eco_text:
 			_last_eco_text = et
 			eco_label.text = et
@@ -1491,5 +1510,5 @@
-	if mines_btn != null:
+	if readouts_due and mines_btn != null:
 		var mt := "slots %d" % free_slots_count
 		if mt != _last_mines_text:
 			_last_mines_text = mt
 			mines_btn.text = mt
@@ -1497,8 +1516,8 @@
-	var ucount := _cached_ucount  # throttled on eco_t (~0.5 s); other fields stay live
+	var ucount := _cached_ucount  # P12: refreshed with the read-out poll (~0.5 s)
 	# the hint line carries placement text; the status line keeps units/score
-	if hint_label == null or hint_label.text == "":
+	if readouts_due and (hint_label == null or hint_label.text == ""):
 		var st := "units %d/%d    score %d    %s" % [ucount, game.players[0].farm_cap,
 			game.players[0].score, ("PAUSED" if game.paused else "")]
 		if st != _last_status_text:
 			_last_status_text = st
 			status_label.text = st
@@ -1611,4 +1632,6 @@
 	if _render_mode_3d and _minimap_jump_3d(ev, world_pos):
 		return
-	var cam := get_viewport().get_camera_2d() as C3Camera
+	# P12: reuse the viewport cached at bind() (event-driven path).
+	var vp_node: Viewport = _vp if _vp != null and is_instance_valid(_vp) else get_viewport()
+	var cam := vp_node.get_camera_2d() as C3Camera
 	if ev is InputEventMouseButton and ev.pressed:
@@ -1667,29 +1688,58 @@
 	if minimap_img == null or minimap_view_img == null or minimap_tex == null or game == null:
 		return
+	# P12: the viewport does not change between frames; the old code called
+	# get_viewport() twice per frame here and looked up the 2D camera even in 3D.
+	var vp_node: Viewport = _vp if _vp != null and is_instance_valid(_vp) else get_viewport()
+	var cam = null
+	if not _render_mode_3d and vp_node != null:
+		cam = vp_node.get_camera_2d()
 	var x0 := 0
 	var y0 := 0
 	var x1 := game.MAP_W - 1
 	var y1 := game.MAP_H - 1
-	var cam := get_viewport().get_camera_2d()
 	if _render_mode_3d and _hud3d_adapter != null:
+		# P12: get_minimap_box() casts four camera rays (camera3d.gd:397-404).
+		# An unchanged camera transform + fov cannot change the box, so skip the
+		# adapter call on still frames. force=true (minimap ticks) and every
+		# input-driven jump still recompute.
+		var cam3: Object = _bound_cam3d
+		var has_cam3 := cam3 != null and is_instance_valid(cam3)
+		var xf: Variant = null
+		var fv := -1.0
+		if has_cam3:
+			xf = cam3.get("global_transform")
+			fv = float(cam3.get("fov"))
+		if has_cam3 and not force:
+			if xf == _mm_box_cam_xform and is_equal_approx(fv, _mm_box_cam_fov):
+				return
+		if has_cam3:
+			_mm_box_cam_xform = xf
+			_mm_box_cam_fov = fv
 		# V7-53: 3D seam. The box source is the V7-17 adapter ONLY; the minimap
 		# image, its data/orders and _mm_paint_box below are unchanged.
 		# get_minimap_box(): position = inclusive (x0,y0), end = EXCLUSIVE.
 		# Convert to the inclusive Vector4i the existing painter expects
 		# (V717 report §2 / hud.gd:1423-1433), re-clamping to the map bounds.
 		var b3: Rect2 = _hud3d_adapter.get_minimap_box()
 		x0 = clampi(int(b3.position.x), 0, game.MAP_W - 1)
 		y0 = clampi(int(b3.position.y), 0, game.MAP_H - 1)
 		x1 = clampi(int(b3.end.x) - 1, 0, game.MAP_W - 1)
 		y1 = clampi(int(b3.end.y) - 1, 0, game.MAP_H - 1)
 	elif cam != null and world != null:
+		# P12: same gate for 2D — position + zoom fully determine the box.
+		var cp: Vector2 = cam.global_position
+		var cz: Vector2 = cam.zoom
+		if not force and cp == _mm_box_cam2_pos and cz == _mm_box_cam2_zoom:
+			return
+		_mm_box_cam2_pos = cp
+		_mm_box_cam2_zoom = cz
 		# view_rect is canvas pixels (metres * view_scale); screen = canvas * zoom
 		var pxm: float = Data.TILE_M * world.view_scale
-		var vp: Vector2 = get_viewport().get_visible_rect().size
+		var vp: Vector2 = vp_node.get_visible_rect().size
 		var extent: Vector2 = vp / maxf(cam.zoom.x, 0.0001)
 		var view_pos: Vector2 = cam.global_position - extent * 0.5
 		var view_end: Vector2 = view_pos + extent
 		x0 = clampi(int(view_pos.x / pxm), 0, game.MAP_W - 1)
 		y0 = clampi(int(view_pos.y / pxm), 0, game.MAP_H - 1)
 		x1 = clampi(int(view_end.x / pxm), 0, game.MAP_W - 1)
 		y1 = clampi(int(view_end.y / pxm), 0, game.MAP_H - 1)
```

Notes on the H1 hunk (derived):
- `readouts_due` is computed from the same `eco_t` that was already tested one line above, so
  the first `_process()` frame still populates all six labels (needed by
  `hud_report():2037-2056`, `t_hud_fidelity.gd:73-77,132-134` and selftest `:353-356`).
- `for i in (6 if readouts_due else 0):` uses the same GDScript integer-iteration form as the
  original `for i in 6`, so no new `range()` allocation is introduced on due frames and zero
  iterations on idle frames.
- `eco_label.disabled`, `mines_btn.disabled`, the two colour overrides and the dirty flags
  stay inside their original blocks — only their enclosing condition changes.

### 4.2 `variant3d/scripts/hud3d_adapter.gd`

```diff
--- a/variant3d/scripts/hud3d_adapter.gd
+++ b/variant3d/scripts/hud3d_adapter.gd
@@ -59,11 +59,27 @@
 var cam: Object = null
 var hud: Object = null
+# P12: the game ref and MAP_W/MAP_H are fixed for a HUD's lifetime. Snapshot
+# them once at bind() so each camera-change box poll does no repeated dynamic
+# MAP_W/MAP_H reads. _sync_game() refreshes if hud.game is ever replaced.
+var _game: Object = null
+var _mw := 0
+var _mh := 0
 
 
 func bind(p_cam, p_hud) -> void:
 	cam = p_cam
 	hud = p_hud
+	_sync_game()
 
 
+func _sync_game() -> void:
+	var g = hud.get("game") if hud != null else null
+	if g == _game:
+		return
+	_game = g
+	_mw = int(g.MAP_W) if g != null else int(Data.MAP_W)
+	_mh = int(g.MAP_H) if g != null else int(Data.MAP_H)
+
+
 # Rect2 in MINIMAP PIXEL (tile) space.
 # position = inclusive (x0,y0); end = EXCLUSIVE (x1+1,y1+1).
@@ -73,6 +89,6 @@
 func get_minimap_box() -> Rect2:
-	var g = hud.get("game") if hud != null else null
-	var mw := int(g.MAP_W) if g != null else int(Data.MAP_W)
-	var mh := int(g.MAP_H) if g != null else int(Data.MAP_H)
+	_sync_game()  # P12: cached game + map size (same values as before)
+	var mw := _mw
+	var mh := _mh
 	if mw <= 0 or mh <= 0:
 		return Rect2()
@@ -103,7 +119,7 @@
 func get_minimap_corners() -> PackedVector2Array:
 	var out := PackedVector2Array()
-	var g = hud.get("game") if hud != null else null
-	var mw := int(g.MAP_W) if g != null else int(Data.MAP_W)
-	var mh := int(g.MAP_H) if g != null else int(Data.MAP_H)
+	_sync_game()  # P12: cached game + map size (same values as before)
+	var mw := _mw
+	var mh := _mh
 	if mw <= 0 or mh <= 0:
 		return out
```

**Binding-order evidence (observed):** `main.gd:622-624` does `add_child(hud)` then
`hud.bind(game, world)`; `main.gd:643` calls `_apply_3d_hooks(...)`, whose `main.gd:1071-1072`
calls `p_hud.bind_3d(p_cam)`. Therefore `hud.game` is already set when the adapter's `bind()`
snapshots it. On a scene reload / new game a fresh HUD and fresh adapter are created, so no
stale cache survives; `_sync_game()` covers any in-place `hud.game` replacement.

**Untouched adapter contracts:** `get_minimap_box()`'s inclusive→exclusive conversion and
clamps (`:82-94`), `get_minimap_corners()`'s centred-world formula (`:115-137`),
`stroke_minimap_quad()` / `_plot_quad_line()` (`:164-207`), `screen_to_world()` (`:210-219`)
and all donor/PORT-APPROX header comments (`:3-55`) are byte-identical.

## 5. Backup / application instructions (Windows, `python` not `python3`)

**Do not run these until COORD grants P12 ownership and G04's gate run is accounted for.**

1. Verify the target files are the ones this diff was derived from (read-only):
   ```powershell
   Get-FileHash -Algorithm SHA256 "variant3d\scripts\hud.gd"
   Get-FileHash -Algorithm SHA256 "variant3d\scripts\hud3d_adapter.gd"
   ```
2. Take the two required backups **before** the first edit (`WAVE_G_CHARTER.md:87`,
   `CHARTER.md:66`). Both destinations were absent at the time of this read:
   ```powershell
   Copy-Item -LiteralPath "variant3d\scripts\hud.gd" -Destination "inbox\backup\hud.gd.bak-P12" -Force
   Copy-Item -LiteralPath "variant3d\scripts\hud3d_adapter.gd" -Destination "inbox\backup\hud3d_adapter.gd.bak-P12" -Force
   Get-FileHash -Algorithm SHA256 "inbox\backup\hud.gd.bak-P12"
   Get-FileHash -Algorithm SHA256 "inbox\backup\hud3d_adapter.gd.bak-P12"
   ```
   Record the four hashes in the landing report (`P12_hud_fix.md`) alongside the byte counts.
3. Save §4.1 / §4.2 into a single patch file outside the repo (e.g. under
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p12\`) and check first:
   ```powershell
   git apply --recount --check <patch-file>
   ```
   Then apply: `git apply --recount <patch-file>`. If either hunk fails, **stop** — do not
   hand-force it; re-read the file and re-derive the hunk.
4. Static smoke (parse only) and gates must be submitted **by G04 only**, with unique ids,
   e.g. `p12-checkonly-hud` / `p12-checkonly-adapter`:
   ```powershell
   python variant3d\tools\godot_runner.py run --id p12-checkonly-hud --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/hud.gd
   python variant3d\tools\godot_runner.py run --id p12-checkonly-adapter --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/hud3d_adapter.gd
   ```
   P12 did **not** submit these; they are a request to the runner owner.
5. Rollback (restores the exact pre-patch bytes):
   ```powershell
   Copy-Item -LiteralPath "inbox\backup\hud.gd.bak-P12" -Destination "variant3d\scripts\hud.gd" -Force
   Copy-Item -LiteralPath "inbox\backup\hud3d_adapter.gd.bak-P12" -Destination "variant3d\scripts\hud3d_adapter.gd" -Force
   ```

## 6. Regression checklist (all results UNVERIFIED until re-run by G04 / owner)

| Gate | Required result | Why this patch must not break it | Status |
|---|---|---|---|
| variant **selftest** `variant3d/selftest.json` | fresh **29/29**, `passed:true`, `SCRIPT ERROR == 0` | `selftest.gd:353-356` reads `hud.hud_report()`; H1 still fills all six labels and the status line on frame 1, and `:2037-2056` is untouched. | **UNVERIFIED** (no run by P12) |
| **uitest** `variant3d/uitest.json` | **17/17**, step `minimap_frustum` detail **"minimap bottom-right: yes"** (UITEST-ANCHOR `minimap_panel.anchor_left == 1.0`) | `_mm_corner()` / `_build_minimap()` anchors (`:1585-1599`) are not in any hunk; `uitest.gd:120` reads `hud_report()` only. | **UNVERIFIED** |
| **t_hud_layout** (windowed, 1024×576 / 1280×720 / 1920×1080) | **62/62 evaluated, 3 recorded skips**, 0 unclipped offenders | `_layout_top()` (`:513-595`) byte-identical; `_on_vp_resize()` (`:273-275`) gains only two cache-sentinel writes; the harness calls it explicitly at `t_hud_layout.gd:278-279`. Re-check `six_resource_entries_*` (`:390-409`), `minimap_declared_240_*` / `minimap_square_*` / `minimap_bottom_right_*` / `minimap_no_topbar_overlap_*` (`:444-488`) and containment (`:488-513`). | **UNVERIFIED** |
| **t_hud_fidelity** | 6 non-empty labels, bracketed worker counts, deficit colours | `t_hud_fidelity.gd:73-77` forces `hud.eco_t = 0.0` before `hud._process(0.0)` → `readouts_due == true` → the text/colour pass runs exactly as before; `hud.set_process(false)` at `:118` is unaffected. | **UNVERIFIED** |
| **t_render_mode** / 3D minimap seam | `result=PASS`, `seam_missing=false`, `SCRIPT ERROR == 0` | The 3D box still comes from `_hud3d_adapter.get_minimap_box()`; no change to the adapter's AABB (`:73-94`) or to `_cam3d_jump()` (`:1647-1658`). | **UNVERIFIED** |
| CAM-RV-01 AABB atom (if re-run) | `(12,11,40,34)` assertion unchanged | `get_minimap_box()` still returns the same inclusive→exclusive `Rect2`; `_sync_game()` returns the same `MAP_W/MAP_H`. | **UNVERIFIED** |
| CONFIG-WIRE-HUD | `_mm_size()==240`, `_mm_inset()==-8`, `_mm_corner()=="bottom_right"`; all getter call sites intact | No hunk touches `:283-299,331,344,1566,1585,1595`; defaults and `ConfigScript.active` call style unchanged. | **UNVERIFIED** |
| UI-TOPBAR-01 | compact/tiny/ultra thresholds `1500/1100/800`, single `OptionButton`, FPS/messages present | `_layout_top()` untouched; FPS label (`:458-477`) untouched. | **UNVERIFIED** |
| 2D `app/**` | zero edits | P12 owns only the two variant3d scripts; diff has no `app/` paths. | **OBSERVED (no edit)** |

## 7. Honesty / risk statement

- **FPS claims: UNVERIFIED.** No capture, telemetry, frame-time sample, CPU/GPU counter or
  runner job was produced by P12. Section 3 lists *expected* work removed, derived purely from
  source control flow; it is not a measured speed-up. Any FPS number must come from a real
  run by the runner owner.
- **Derived behaviour changes (bounded, require owner awareness):**
  1. Top-bar stock numbers, idle/slot buttons and the status line refresh at most **2 Hz**
     instead of every rendered frame; the strings themselves are unchanged because their
     inputs are already polled at 2 Hz. A build/trade that changes `res[]` between polls
     appears on the next poll (≤0.5 s). `t_hud_fidelity` and the selftest force/observe the
     poll, not the frame cadence.
  2. The status line yields to a live hint line on the 0.5 s poll rather than the very next
     frame after `show_hint("")` — bounded by the same 0.5 s.
  3. The minimap viewport box is recomputed only when the 3D camera `global_transform` /
     `fov` (or 2D `global_position` / `zoom`, or viewport size) changes, or every minimap tick
     via `force=true`. Input-driven jumps move the camera before the redraw call
     (`hud.gd:1619,1628,1639,1643`), so the F3 same-frame contract is preserved. Projection
     properties outside those signatures would self-heal on the next ≤0.25 s minimap tick.
- **Inferred / UNVERIFIED:** whether these changes translate to a perceptible FPS gain on the
  MX130 machine depends on how much frame time the HUD path actually consumes relative to the
  terrain shader, anim sampling and entity draws (P01/P02/P03/P05 territory). No ranking is
  claimed here.
- **No donor parity claim.** No donor GPU A/B exists; all donor citations in the two files
  remain read-only provenance comments (`hud3d_adapter.gd:6-55`).
- **No test weakening, no synthetic dither/noise, no invented donor constants, no gates, no
  Godot process, no code edit beyond this report.** P12 did not touch `hud.gd`,
  `hud3d_adapter.gd`, any backup, test, config, fixture, PNG or queue state.

*End of P12 proposal — ready for COORD ownership grant; apply §4 only after G04's gate run is settled.*
