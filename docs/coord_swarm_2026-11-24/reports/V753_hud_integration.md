---
agent: V7-53
role: integration builder — route the 3D minimap viewport box through hud3d_adapter
date: 2026-11-24
status: DONE (parse PASS, inherited HUD fidelity 6/6 PASS, 3D-config full selftest 29/29 PASS after bind-type regression fix; 3D box pixel value not measured here)
owns: "variant3d/scripts/hud.gd + this report only; no other edits"
runner_jobs: ["v753-hud-parse", "v753-hud-fidelity", "v753-hud-bindfix-parse", "v753-hud-bind3d-fix"]
regression: "ticket 69 v-launcher-config3d-selftest failed on C3HUD.bind(arg2: C3World) rejecting Node3D world3d; fixed by relaxing world typing (see §3b)"
scope: "SINGLEPLAYER SKIRMISH (D-12); TABS; no RNG; no called-symbol renames; no donor binaries; app/** untouched"
backup: "inbox/backup/hud.gd.bak-V753 (Copy-Item, 73202 bytes, taken before first edit)"
handoff_to: "V7-50 (main.gd owner) — call hud.bind_3d(cam3d) from the render_mode == \"3d\" branch"
---

# V7-53 — `variant3d/scripts/hud.gd` 3D minimap-box integration

## 1. What changed (exactly)

Only `variant3d/scripts/hud.gd` was edited. Three contiguous additions; **no
existing line was deleted or renamed**. The 2D camera-derived box block is
byte-identical — its only alteration is the guarding keyword `if` → `elif`.

| # | New location (file:line) | Addition |
|---|---|---|
| 1 | `variant3d/scripts/hud.gd:46-53` | State block: `_render_mode_3d := false`, `_hud3d_adapter: Object = null`, `_bound_cam3d: Object = null`. Defaults leave the 2D path untouched. |
| 2 | `variant3d/scripts/hud.gd:189-208` | Public `func bind_3d(cam) -> void:` — lazily `load("res://scripts/hud3d_adapter.gd")` + `.new()` (no `class_name` was registered by V7-17), keeps the adapter alive on `self`, calls `adapter.bind(cam, self)`, sets `_render_mode_3d = true`. Guards: missing script / API mismatch → `push_warning` and stay on the 2D/default (full-map) box. Re-call with a new camera rebinds in place (no allocation). |
| 3 | `variant3d/scripts/hud.gd:1431-1442` | In `_draw_minimap_viewport_box()`: new 3D-first branch computing `x0/y0/x1/y1` from `_hud3d_adapter.get_minimap_box()`; original 2D block becomes `elif cam != null and world != null:`. |

### Exact seam diff

```diff
--- a/inbox/backup/hud.gd.bak-V753
+++ b/variant3d/scripts/hud.gd
@@ -43,6 +43,14 @@ var _mm_box_last := Vector4i(-1, -1, -1, -1)  # x0,y0,x1,y1 of last drawn box
 var minimap_rect: TextureRect
 var minimap_panel: PanelContainer
 var mm_timer := 0.0
+# V7-53 (integration seam from V73_ATOMIC_CONTRACT.md:23): the 3D minimap
+# viewport-box source. Set ONLY by bind_3d(), which the main.gd owner (V7-50)
+# calls from its gameplay.render_mode == "3d" construction branch. In 2D these
+# stay at defaults, so the entire 2D path is unchanged. The minimap image, its
+# data/orders and _mm_paint_box are NOT touched — only the box source switches.
+var _render_mode_3d := false
+var _hud3d_adapter: Object = null
+var _bound_cam3d: Object = null
 # T-PERF-RENDER: fog-dimmed terrain cache. ...
...
@@ -178,6 +186,27 @@ func bind(...) -> void:
 		get_tree().root.size_changed.connect(_on_vp_resize)
 
+# V7-53 — public handoff for the main.gd owner (V7-50). ...
+func bind_3d(cam) -> void:
+	if _hud3d_adapter == null:
+		var adapter_script = load("res://scripts/hud3d_adapter.gd")
+		if adapter_script == null:
+			push_warning("hud.bind_3d: hud3d_adapter.gd unavailable; 3D box falls back to full map")
+			return
+		_hud3d_adapter = adapter_script.new()
+	if not _hud3d_adapter.has_method("bind") or not _hud3d_adapter.has_method("get_minimap_box"):
+		push_warning("hud.bind_3d: adapter API mismatch; 3D box falls back to full map")
+		return
+	_hud3d_adapter.bind(cam, self)
+	_bound_cam3d = cam
+	_render_mode_3d = true
+
 func atlas(src: Texture2D, region: Rect2) -> AtlasTexture:
...
@@ -1399,7 +1428,18 @@ func _draw_minimap_viewport_box(force: bool = false) -> void:
 	var x1 := game.MAP_W - 1
 	var y1 := game.MAP_H - 1
 	var cam := get_viewport().get_camera_2d()
-	if cam != null and world != null:
+	if _render_mode_3d and _hud3d_adapter != null:
+		# V7-53: 3D seam. The box source is the V7-17 adapter ONLY; ...
+		var b3: Rect2 = _hud3d_adapter.get_minimap_box()
+		x0 = clampi(int(b3.position.x), 0, game.MAP_W - 1)
+		y0 = clampi(int(b3.position.y), 0, game.MAP_H - 1)
+		x1 = clampi(int(b3.end.x) - 1, 0, game.MAP_W - 1)
+		y1 = clampi(int(b3.end.y) - 1, 0, game.MAP_H - 1)
+	elif cam != null and world != null:      # <-- the ONLY change to the 2D block
 		# view_rect is canvas pixels (metres * view_scale); screen = canvas * zoom
 		var pxm: float = Data.TILE_M * world.view_scale
 		... (unchanged) ...
```

Downstream of `var box := Vector4i(x0, y0, x1, y1)`
(`variant3d/scripts/hud.gd:1453-1461`), the change-gate, `_mm_box_last`,
`_mm_paint_box()` and `minimap_tex.update()` are **untouched**. The minimap
image, mine/entity blips, fog cache and `_on_minimap_input()` are **untouched**.

`get_viewport().get_camera_2d()` is still evaluated in 3D but is simply null
under a `Camera3D`; the 3D branch wins first. This preserves the 2D declaration
byte-for-byte.

## 2. Donor / port evidence

- Contract obligation: `docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:23`
  ("hud.gd owner: minimap box uses `hud3d_adapter.get_minimap_box()` when
  render_mode==3d; data/minimap image unchanged"); adapter API at `:16`.
- Adapter contract: `reports/V717_hud3d_adapter.md:37-76` — `get_minimap_box()`
  returns a `Rect2` in minimap-pixel space with **inclusive** `position` and
  **exclusive** `end`; §2 gives the exact conversion
  `Vector4i(int(b.position.x), int(b.position.y), int(b.end.x)-1, int(b.end.y)-1)`.
  This atom applies exactly that conversion (`:1437-1441`), then re-clamps to
  `[0, MAP_W-1] / [0, MAP_H-1]`.
- Port chain (inherited, not re-derived here): `app/scripts/hud.gd:1394-1412`
  (2D box), `:1423-1433` (inclusive painter), `app/scripts/data.gd:23`
  (`TILE_M := 2.0`), `app/scripts/game.gd:16`, `:459-460` (`tile_of`).
- Ground-corner projection lives in `camera3d.gd::get_viewport_corners()`
  (V7-11, contract `:10`); this atom does not duplicate it.
- No donor path:line exists for the 3D frustum box itself (V717 §3, V71
  `:160`/`:212` UNVERIFIED). No new 3D constant, no invented number.
- No RNG calls (`randf|randi|rand_range|RandomNumberGenerator|randomize`: 0
  matches); 0 space-indented lines, 0 trailing-whitespace lines; all new lines
  use TABs. No called symbol was renamed. `main.gd` / `camera3d.gd` untouched.

## 3. Verification — jobs and honest results

Both jobs went through **variant3d's own runner**
(`python variant3d\tools\godot_runner.py run ...`), spool
`variant3d/.godot_queue`.

| Job id | Ticket | Command tail | Result |
|---|---|---|---|
| `v753-hud-parse` | 50 | `--headless --path variant3d --check-only --script res://scripts/hud.gd` | **PASS**: `status=ok`, `exit=0`, run 4.37 s. stdout = Godot 4.7.2 banner only; `stderr.txt` length **0**. |
| `v753-hud-fidelity` | 55 | `--headless --path variant3d --script res://tests/t_hud_fidelity.gd` | **PASS**: `status=ok`, `exit=0`, run 13.23 s; `6/6` checks PASS; `stderr.txt` length **0**. Result JSON `passed: true` (six_resource_labels, worker_counts_brackets, idle_warning_text, idle_warning_colour, red_deficit_colouring, score_text). |

Notes on scope of proof:

- `t_hud_fidelity.gd` is an **inherited economy read-out test**; it binds
  `hud.bind(game, null)` and never calls `bind_3d()`. It therefore exercises
  the unchanged 2D/default path and is a **regression check only**. It does not
  assert the 3D box value — do not read 6/6 as 3D box verification.
- The test regenerated the tracked `variant3d/tests/results/t_hud_fidelity.json`
  (timestamp-only diff). It was restored to HEAD with `git checkout --` so no
  out-of-scope file remains modified.
- NOT done in the first pass: no live `Camera3D` box-value assertion, no
  pixel/screenshot comparison, no full-config selftest. The selftest was added
  in the regression fix below (§3b).

## 3b. Regression fix — 3D-config selftest (ticket 69 → 71)

**Reported failure** (ticket 69, `v-launcher-config3d-selftest`, `status=failed`,
`exit=1`, run 123.20 s, watchdog forced exit):

```
SCRIPT ERROR: Invalid type in function 'bind' in base 'CanvasLayer (C3HUD)'.
  The Object-derived class of argument 2 (Node3D (world3d.gd)) is not a subclass
  of the expected argument class.
   at: _setup_full_game (res://scripts/main.gd:1043)
```

**Root cause (in my owned file):** `C3HUD.bind()` declared arg 2 as `w: C3World`
and the member as `var world: C3World`. `C3World` is the 2D `Node2D` world;
`make_world3d()` returns a `Node3D` (`world3d.gd`), so Godot rejected the typed
argument at `main.gd:1043`. The minimap-box changes from §1 were not the cause,
but the 3D path could never reach them.

**Fix (only `variant3d/scripts/hud.gd`, minimal):**

```diff
-var world: C3World
+# V7-53: relaxed to untyped (main.gd:60 uses the same pattern for its world).
+# C3World is a Node2D; the 3D world is a Node3D (world3d.gd), so a static
+# C3World annotation rejects it in bind(). Both worlds expose the same duck-
+# typed contract (view_scale / fog_explored / fog_vis / fog_revision), so all
+# member reads below stay dynamic and behave identically in 2D and 3D.
+var world
...
-func bind(g: C3Game, w: C3World) -> void:
+func bind(g: C3Game, w) -> void:
```

`main.gd:60` already declares its `world` untyped for this same reason; this
mirrors that established pattern. Untyped (Variant) rather than a `Node`
annotation is required because HUD reads duck-typed fields
(`view_scale`, `fog_explored`, `fog_vis`, `fog_revision`) that are not members of
`Node` — a `Node` annotation would turn those reads into static-analysis errors.
No world member access, no 2D logic and no called symbol changed; `bind(game,
world)` behaves byte-for-byte as before in 2D.

**Whole-file scan for other world/camera typed params/casts:** the only other
world type was the two annotations above (both fixed). The single remaining
`as C3Camera` at `variant3d/scripts/hud.gd:1405` casts
`get_viewport().get_camera_2d()` only, which is a `Camera2D` or `null` even in
3D mode — it never receives the `Camera3D`, so it needs no relaxation and was
left untouched to keep the 2D path unchanged. `bind_3d(cam)` was already untyped.
`game: C3Game` is correct in both modes (3D still uses `C3Game`).

**Verification jobs (variant3d runner, exact results):**

| Job id | Ticket | Command tail | Result |
|---|---|---|---|
| `v753-hud-bindfix-parse` | 70 | `--headless --path variant3d --check-only --script res://scripts/hud.gd` | **PASS**: `status=ok`, `exit=0`, run 5.33 s. |
| `v753-hud-bind3d-fix` | 71 | `--headless --path variant3d -- --self-test variant3d/selftest.json` | **PASS / no watchdog**: `status=ok`, `exit=0`, run 132.24 s (limit 300 s). stdout contains `self-test report: .../variant3d/selftest.json`. Regenerated `selftest.json`: `passed: true`, **29/29 steps passed**, `sim_seconds 366.53125`. |

**Honest stderr note (out of my ownership):** ticket 71's `stderr.txt` still
contains a pre-existing `world3d.gd` warning and five
`SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor.` at
`world3d.gd:207` in `_sync_selection()` (called from `world3d.gd:282` ←
`main.gd:1551`), plus an ObjectDB/resource leak warning at exit. The `int(id)`
call at `world3d.gd:207` receives `game.get_selected()` entries that are
Dictionaries, not ids. These are in the world3d integration owner's file, not
`hud.gd`; they did **not** stop the selftest, which completed and reported
`passed: true`. I did not edit those files. The selftest run rewrote the tracked
`variant3d/selftest.json` (normal test artifact); no git operations were used
for this regression fix.

## 4. Handoff — V7-50 (`main.gd` owner)

The HUD has no `Camera3D` reference in 2D and must not import one, so the
`render_mode == "3d"` condition is delivered as an explicit call:

```gdscript
# in main.gd, ONLY inside the gameplay.render_mode == "3d" construction branch,
# after cam3d (V7-11) and hud exist and hud.bind(game, world) has run:
if hud.has_method("bind_3d"):
	hud.bind_3d(cam3d)
```

- Call it **after** `hud.bind(game, world)` so `game`/`world` are live; the
  adapter reads `hud.game` for `MAP_W/MAP_H`.
- The HUD owns and keeps the adapter alive; V7-50 needs no extra node, no
  `class_name`, and no `load()` of `hud3d_adapter.gd`.
- Re-call with a different camera to rebind (e.g. camera recreated on restart).
- 2D path: do nothing. `_render_mode_3d` stays `false`, so the original
  `get_camera_2d()` block runs verbatim.
- **`camera3d.gd` was not edited** (V7-11 landed). Its
  `get_viewport_corners()->Array` must return metre-space ground corners; if it
  returns canvas px / minimap px, the adapter's `TILE_M` division must be
  revisited (V717 open Q1).
- Minimap **left-click camera jump** still uses `get_camera_2d()` in
  `_on_minimap_input()` (`hud.gd:1371-1386`) and is null under `Camera3D`. This
  atom deliberately left it alone ("only the box source switches"). Right-click
  `ictl.minimap_order(world_pos)` is unchanged. A separate owner decision is
  needed if 3D minimap camera-jump is wanted.

## 5. Open questions

1. **Render_mode signal discipline (needs V7-50).** `bind_3d()` is the
   authoritative switch. If `main.gd` sets `render_mode = "3d"` but does not
   call `bind_3d()`, the HUD quietly uses the full-map default box (no crash).
   Please confirm the call is placed in the 3D branch at integration time.
2. **3D minimap click-to-move (out of scope here).** Left-click/drag on the
   minimap cannot move a `Camera3D` with the current unchanged handler; route
   through `cam3d` in a follow-up owned by V7-50 or a new atom.
3. **3D → 2D reset (no `unbind_3d`).** No runtime unbind was added. Returning
   to a 2D skirmish needs a fresh HUD instance (or a follow-up atom adding an
   explicit reset). Leaving `_render_mode_3d` set on a reused HUD would keep the
   3D source; the adapter falls back to the full map when unbound, so the
   failure mode is benign.
4. **Frustum fidelity (inherited from V717 §6 Q2).** The adapter returns the
   axis-aligned bounding box of four projected ground corners; no re-read donor
   path:line establishes whether the donor box rotates with camera yaw.
   UNVERIFIED — no substitute constant invented.
5. **Box runtime value unmeasured.** No stub-camera assertion of
   `position/end == int(corner/TILE_M)` was run in this atom. The V7-31…V7-37
   test atoms should cover it once their modules are registered/landed.
6. **Corner unit/type (inherited V717 Q1).** Adapter assumes metres and accepts
   `Vector2`, `Vector3(x,z)`, or `Array[2]`. Confirm against V7-11's actual
   `get_viewport_corners()` output.

## 6. Files changed / backup

- EDITED: `variant3d/scripts/hud.gd` (only code file; +29 lines for the 3D box
  seam, plus the §3b bind-type relaxation: `var world: C3World` → `var world`,
  `bind(..., w: C3World)` → `bind(..., w)`).
- NEW: `docs/coord_swarm_2026-11-24/reports/V753_hud_integration.md` (this report).
- BACKUP: `inbox/backup/hud.gd.bak-V753` — pre-edit copy, 73202 bytes.
- NOT touched: `main.gd`, `camera3d.gd`, `hud3d_adapter.gd`, `app/**`,
  `variant3d/tests/**`, manifest, any other report. Result-JSON timestamp
  artifact from the test run was reverted (see §3).
