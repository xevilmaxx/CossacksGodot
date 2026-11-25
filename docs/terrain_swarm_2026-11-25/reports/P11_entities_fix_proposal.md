---
id: P11
owner: P11
wave: P
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
scope: READ-ONLY proposal — no game-code edits, no runner, no Godot invocation
status: PROPOSAL_ONLY — file untouched; COORD grant required after G04 gates + M03 landing
output: docs/terrain_swarm_2026-11-25/reports/P11_entities_fix_proposal.md
visual_parity: NONE CLAIMED — PORT APPROXIMATION labels unchanged; visual UNVERIFIED
---

# P11 — `world3d_entities.gd` draw-call / instance optimisation (proposal only)

## 0. Compliance and source status

- Read as instructed: `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave G, Wave P, Wave M),
  `docs/terrain_swarm_2026-11-25/CHARTER.md`, the landed Wave-P
  `docs/terrain_swarm_2026-11-25/reports/P02_draw_calls.md`, and the older 2026-11-24
  `docs/coord_swarm_2026-11-24/reports/P02_render_hotpaths.md` (**2D `world.gd`**, not the 3D file).
- `variant3d/scripts/world3d_entities.gd` is **UNTOUCHED** by this ticket: no edit, no backup created yet,
  no runner job, no Godot process, no screenshot. G04 remains sole runner owner.
- **Wave-P P02 report LANDED while this proposal was being written**:
  `docs/terrain_swarm_2026-11-25/reports/P02_draw_calls.md`. It was read in full and the diff in §3
  is reconciled against it. P02's three top-ranked wins (`A1` water early-out, `A2` selection-ring
  batching, `A3` zero-alpha fog quads) are **outside this ticket's file** and are routed to P05 /
  COORD / the FX owner (`P02_draw_calls.md:165-190`); P11 does not duplicate them.
- For this file P02 recommends exactly two small wins (`:192-197`): share one `Shader` instead of
  `Shader.new()` per call, and (optionally) flip the inert building `cast_shadow` flag; it also
  warns that batching buildings is test-sensitive (`t_entities3d.gd` peak=6). It ranks the 4096-slot
  MultiMesh reservation and batch proliferation as F5 (`:126-136`). §3 implements the Shader
  sharing **plus** a per-tint-material cache and on-demand instance buffers; the building batching
  and cast-flag items are explicitly deferred in §2 with reasons. The older 2D
  `P02_render_hotpaths.md` is **not** treated as a recommendation for this 3D file.
- Every claim below is labelled `[O]` observed source, `[D]` derived, `[E]` estimate/UNVERIFIED.
  **No FPS, draw-call-count or frame-time improvement is claimed.** The only existing 3D timing
  numbers (`docs/coord_swarm_2026-11-25/reports/PERF_3D_01.md:56-57,140-144`: `sync_ms` 276.77 /
  272.56 ms) are prior measurements of the *unmodified* tree; draw calls were explicitly BLOCKED
  there (`:47-48`, `:103`). All gains in §7 are `[E] UNVERIFIED`.

## 1. Evidence — current file, read only `[O]`

| # | What | File:line | Consequence |
|---|---|---|---|
| 1 | Units/resources already use one `MultiMeshInstance3D` per batch key; key is `(sid[,player][,action][,frame])` | `world3d_entities.gd:1400-1472`, `1625-1630`, `1978-1981`, `2094-2104` | Batching is already present; adding a second batching layer risks tint/frame correctness. No evidence of duplicate per-instance nodes. |
| 2 | **Every** batch allocates `instance_count = BATCH_CAPACITY` (4096) immediately, even a 1-instance tree/ore batch | `:116`, `:1417`, `:1456-1458` | `[D]` 15 batches for 29 resources in `tests/results/t_combo_trees_mines.json:189-200` = 61,440 reserved slots for 29 visible instances. Buffer allocation/upload is paid per node at creation. |
| 3 | `_tinted_material()` allocates a **new `Shader` + new `ShaderMaterial`** for every batch and every real building stage swap | `:976-996`, called from `:1015-1025`, `:1882-1890` | `[D]` repeated shader parse/uniform-object creation; building stage swaps invalidate material state. |
| 4 | Base albedo `StandardMaterial3D` is created once per sid/kind via `_bake_mesh`/`_default_material` and cached in `_mesh_cache` | `:582-600`, `:1053-1107`, `:1110-1160` | No per-instance base material churn; do not "fix" what is already shared. |
| 5 | Buildings are deliberately one `MeshInstance3D` each (`_nodes`), with per-node surface overrides | `:1645-1682`, `:1675-1678`, `:2267-2272` | `[D]` one draw call per building. Converting them to MultiMesh would touch construction-stage mesh swapping (`:1851-1936`), scaffold children (`:1898-1929`) and the mill rotor parent (`:1683-1686`) — deferred, see §2. |
| 6 | `res` cutout materials use `TRANSPARENCY_ALPHA_SCISSOR` (opaque pass + discard), not blended transparency; `cull_disabled` is deliberate | `:582-600` (`kind == "res" and sid != "field"`) | `[D]` No blend sorting/overdraw to remove here. Replacing scissor with opaque would change tree/bush silhouettes; probing every PNG alpha at `bind()` adds a new startup stall (G17 already flagged one). **NO_WIN in this ticket.** |
| 7 | Global sun has `shadow_enabled = false` | `world3d_terrain.gd:1225-1241`, `:1550-1555` | `[D]` `mi.cast_shadow = ON` at `world3d_entities.gd:1679` is inert today; changing cast flags would not reduce current draw calls and would overlap M03's `add_building` hunk. **NO_WIN here.** |
| 8 | Ghost provider API is the two by-name methods `_mesh_info(sid,"building")` and `_stage_mesh_info(sid,"4",false)` | `world3d_entities.gd:1110-1160`, `:1819-1844`; consumer `world3d_fx.gd:652-672` | Must remain callable with identical Dictionary keys (`mesh`, `source`, `sid`, `kind`, `bbox_sid`). Diff does not touch them. |
| 9 | Mine disc is the low-Z region of the donor albedo; `ENV_SCALE.mine = 0.3152`, no terrain apron asset | `:119-123`, `:185`, `:1939-1948` | Mine sid/kind/material path left byte-identical. |
| 10 | Teleport / rebind paths: O(1) swap-remove with CPU transform mirror, and frozen-frame `mm.mesh` rebind | `:1475-1513`, `:2099-2122`, `:2128-2146`, `_xf()` `:1551-1593`; feed `world3d.gd:329-410` | Diff preserves slot indices, `xforms`, `visible_instance_count` and rebind code; growth rewrites existing transforms from the mirror. |
| 11 | Rotor and construction-stage code occupies distinct line ranges | constants `:231-273`, rotors `:309`, `:377`, `:1683-1686`, `:1697-1782`, `:2153-2188`; stages `:275-294`, `:379-380`, `:1785-1936`, `:2148-2151` | Diff's changed lines are `:114-117`, `:357-365`, `:381-383`, `:995-1020`, `:1436-1490`, `:1506-1509`, `:2327-2336` — **no overlap** with mill/rotor or stage lines. |
| 12 | P02 F5: 4096-slot reservation per batch; ~36 possible resource sids ⇒ ~147k reserved slots (≈12 MB, DERIVED) | `P02_draw_calls.md:126-136`; source `world3d_entities.gd:116,1417-1418,173-179,1939-1953` | Tier 1B addresses the reservation without merging distinct donor sids (which P02 §5 `:204-205` forbids). |
| 13 | P02 F4 / honourable mention: per-building `MeshInstance3D` + fresh `Shader`/`ShaderMaterial` per surface | `P02_draw_calls.md:114-124,192-197`; source `world3d_entities.gd:1645-1682,976-996,1015-1025` | Tier 1A removes the shader/material churn. P02's claim that `_default_material()` allocates "each call" is narrowed by observation: calls happen once per `kind|sid` through the `_mesh_cache` at `:1053-1160`, so base materials are already shared. |
| 14 | P02 notes empty **morph** batches are kept alive on purpose | `P02_draw_calls.md:133-135`; source `world3d_entities.gd:1503-1512` | Rejected for this diff: those nodes have `visible_instance_count == 0` (zero draw calls) and V7-74 deliberately keeps them to avoid free/create churn on frame oscillation (`:1505-1507`). Changing that lifecycle would risk teleport/rebind continuity. |

## 2. Recommendation set

| Tier | Change | Mechanism | Draw calls | Risk | Status |
|---|---|---|---|---|---|
| 1A | Share one `Shader` and cache one `ShaderMaterial` per `(sid, kind, tint RGBA, base material)` — implements P02's honourable mention `P02_draw_calls.md:192-194` and extends it to the material object | `_tint_material_cache`, `_tint_shader` in `_tinted_material()` | Unchanged count; fewer shader parses/material allocations `[E]` | Low — same uniforms, same donor mask, same tint; cache key includes base material identity | **Apply-ready diff below** |
| 1B | Right-size MultiMesh instance buffers: allocate 64, double on demand, hard ceiling stays 4096 — addresses P02 F5 (`:126-136`) | `BATCH_INITIAL_CAPACITY`, `_grow_batch()`, `_acquire()` growth hook | Unchanged count; less reserved GPU/CPU instance storage `[E]` | Low — slot indices, node names, `visible_instance_count`, transforms and field colours preserved | **Apply-ready diff below** |
| 1C | Structural stats only (`batch_instance_slots_allocated`, `tint_materials_shared`, label) | additive `stats[...]` writes in `sync()` | None | None — no assertion/threshold changed | **Apply-ready diff below** |
| 2 | Batch buildings into MultiMesh keyed by (sid, stage, player) | would replace `_nodes` MeshInstance3D path | **Would actually reduce count** `[E]` | High — per-node stage mesh swap, scaffold parenting, rotor child, M03 co-ownership and `t_entities3d.gd` peak=6 (P02 `:195-197`) | **DEFERRED** to a separate post-M03 ticket; not in this diff |
| NO_WIN | Switch `res` scissor cutouts to opaque / alpha-probe at bind | `_default_material()` | None | Silhouette change or extra bind stall; P02 §5 `:202-203` also forbids removing `CULL_DISABLED` | Reject — §1 #6 |
| NO_WIN (this patch) | Flip `cast_shadow` flags | building `MeshInstance3D` at `:1679` | None today — wired sun has `shadow_enabled=false` (P02 `:39-45,194`) | The one-line edit sits inside M03's `add_building`/rotor hunk; P02 itself calls it inert | **Deferred to COORD merge** with M03, not in this disjoint diff |
| OUT OF SCOPE | P02 A1 water early-out / A2 selection-ring batching / A3 fog quad compaction | `water3d.gdshader`, `world3d_fx.gd`, `world3d_fog.gd` | Potentially large `[E]`, unmeasured | Different file owners | Route to P05 / COORD / FX owner (`P02_draw_calls.md:165-190`) |
| OUT OF SCOPE | Dirty-flag Pass-2 transform rewrite | P01 proposal `reports/P01_frame_hotspots.md:207-210` | None (CPU only) | Touches teleport/rebind semantics | Leave to P01 owner; not duplicated here |

## 3. Unified diff — exact, additive, disjoint from mill/rotor and construction stages

Apply against the current tree only **after** COORD grants ownership (G04 gates finished, M03 proposal landed).
The diff was generated from the untouched source with `difflib.unified_diff`; no file was modified in this ticket.

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -114,6 +114,9 @@
 const MAP_DEFAULT: float = 160.0  # game.gd:35-36 MAP_W/MAP_H default 160
 
 const BATCH_CAPACITY: int = 4096
+# P11: initial allocated instance slots per MultiMesh; grows by doubling.
+# BATCH_CAPACITY remains the unchanged hard ceiling (mass-army contract).
+const BATCH_INITIAL_CAPACITY: int = 64
 const HIDDEN_SCALE: float = 0.0001
 
 # Donor numbers, NOT port inventions: see header + V7-2 section 1.1.
@@ -357,6 +360,14 @@
 var _band_mask_cache: Dictionary = {}       # sid -> {"image":Image,"texture":ImageTexture}
 var _band_mask_stats: Dictionary = {}       # sid -> measured mask/vertex/face counts
 
+# P11 DRAW-CALL/INSTANCE: one Shader + one ShaderMaterial per
+# (sid, kind, tint RGBA, base material identity). _tinted_material() used to
+# create a NEW Shader and ShaderMaterial for every batch and every building
+# stage swap; sharing keeps custColor per player slot while removing repeated
+# shader parse/material allocation. No art, tint value or label is changed.
+var _tint_shader: Shader = null
+var _tint_material_cache: Dictionary = {}  # key -> ShaderMaterial (shared)
+
 
 # ---------------------------------------------------------------- bind / stats
 func bind(g) -> void:
@@ -370,6 +381,9 @@
 	_donor_texture_paths.clear()
 	_band_mask_cache.clear()
 	_band_mask_stats.clear()
+	# P11: shared materials belong to the previous game meshes; rebuild.
+	_tint_material_cache.clear()
+	_tint_shader = null
 	# MOTION-ANIM-01: per-unit presentation mirrors are rebuilt from the new game.
 	_motion_sample.clear()
 	_face_smooth.clear()
@@ -981,18 +995,26 @@
 	var bm: Material = base
 	if bm == null:
 		bm = _default_material(sid, kind)
+	# P11: key includes the base material identity so two sids/kinds or two
+	# distinct imported albedo materials can never share the wrong texture.
+	var ck := str(sid) + "|" + kind + "|" + str(tint.r) + "," + str(tint.g) \
+		+ "," + str(tint.b) + "," + str(tint.a) + "|" + str(bm.get_instance_id())
+	if _tint_material_cache.has(ck):
+		return _tint_material_cache[ck] as Material
 	var albedo: Texture2D = null
 	if bm is StandardMaterial3D:
 		albedo = (bm as StandardMaterial3D).albedo_texture
 	if albedo == null and ResourceLoader.exists(TEX_DIR + sid + ".png"):
 		albedo = load(TEX_DIR + sid + ".png") as Texture2D
-	var sh := Shader.new()
-	sh.code = TINT_SHADER_CODE
+	if _tint_shader == null:
+		_tint_shader = Shader.new()
+		_tint_shader.code = TINT_SHADER_CODE
 	var m := ShaderMaterial.new()
-	m.shader = sh
+	m.shader = _tint_shader
 	m.set_shader_parameter("albedo_tex", albedo)
 	m.set_shader_parameter("mask_tex", mask)
 	m.set_shader_parameter("custColor", tint)
+	_tint_material_cache[ck] = m
 	return m
 
 
@@ -1414,7 +1436,10 @@
 			var sm: Material = fmesh.surface_get_material(s)
 			if sm is StandardMaterial3D:
 				(sm as StandardMaterial3D).vertex_color_use_as_albedo = true
-	mm.instance_count = BATCH_CAPACITY
+	# P11: allocate only the initial buffer; use_colors is toggled above while
+	# instance_count is still 0, which Godot 4.7 requires.
+	var cap: int = mini(BATCH_INITIAL_CAPACITY, BATCH_CAPACITY)
+	mm.instance_count = cap
 	mm.visible_instance_count = 0
 	var mmi := MultiMeshInstance3D.new()
 	var is_morph: bool = not pose.is_empty()
@@ -1435,7 +1460,35 @@
 	# MultiMesh.get_instance_transform() return identity for every slot, so a
 	# mirror is needed for O(1) swap-removal and headless verification.
 	return {"node": mmi, "mm": mm, "ids": [], "xforms": [], "class": cls,
-		"key": key, "morph": is_morph}
+		"key": key, "morph": is_morph, "capacity": cap}
+
+
+# P11: grow the allocated instance buffer geometrically, never past the
+# unchanged BATCH_CAPACITY ceiling. Node name, batch key, slot indices,
+# visible_instance_count and the CPU xform mirror are all untouched; existing
+# slots are rewritten from the mirror because it is authoritative under the
+# headless dummy RenderingServer.
+func _grow_batch(b: Dictionary, needed: int) -> void:
+	var mm: MultiMesh = b["mm"]
+	var cap: int = int(b.get("capacity", BATCH_CAPACITY))
+	if needed <= cap or cap >= BATCH_CAPACITY:
+		return
+	var new_cap: int = cap
+	while new_cap < needed and new_cap < BATCH_CAPACITY:
+		new_cap = mini(new_cap * 2, BATCH_CAPACITY)
+	mm.instance_count = new_cap
+	b["capacity"] = new_cap
+	var xforms: Array = b["xforms"]
+	var ids: Array = b["ids"]
+	for i in range(xforms.size()):
+		mm.set_instance_transform(i, xforms[i])
+	# MILLFIX F2 field colours are read-only here: re-apply from the existing
+	# per-field mirror so a resize is byte-identical on the next render.
+	if str(b.get("key", "")) == "res|field":
+		for i in range(xforms.size()):
+			var fv = _field_visual.get(int(ids[i]))
+			if fv is Dictionary:
+				mm.set_instance_color(i, (fv as Dictionary).get("color", Color(1, 1, 1, 1)))
 
 
 # V7-65: `tint` / `player` are INTERNAL batching-key extensions only; the six
@@ -1453,6 +1506,9 @@
 			_apply_tint((b as Dictionary)["node"], info["mesh"], tint,
 				str(info.get("sid", "")), str(info.get("kind", cls)))
 	var ids: Array = b["ids"]
+	# P11: grow only when the allocated buffer is full; hard ceiling unchanged.
+	if ids.size() >= int((b as Dictionary).get("capacity", BATCH_CAPACITY)):
+		_grow_batch(b as Dictionary, ids.size() + 1)
 	if ids.size() >= BATCH_CAPACITY:
 		push_warning("world3d_entities: batch full " + key + " (cap " + str(BATCH_CAPACITY) + ")")
 		return -1
@@ -2271,6 +2327,14 @@
 	stats["tinted_batches"] = tinted_batches
 	stats["tinted_buildings"] = tinted_buildings
 	stats["batches"] = _batches.size()
+	# P11 structural telemetry (NOT a frame-time or draw-call measurement).
+	var allocated_slots := 0
+	for key in _batches.keys():
+		allocated_slots += int((_batches[key] as Dictionary).get("capacity", BATCH_CAPACITY))
+	stats["batch_instance_slots_allocated"] = allocated_slots
+	stats["batch_instance_slots_ceiling"] = BATCH_CAPACITY * _batches.size()
+	stats["tint_materials_shared"] = _tint_material_cache.size()
+	stats["batch_optimization_label"] = PORT_LABEL + " — P11 adaptive MultiMesh capacity + shared tint material; frame-time/draw-call gain UNVERIFIED"
 	stats["units"] = units
 	stats["resources"] = ress
 	stats["buildings"] = _nodes.size()
```

## 4. Invariants explicitly preserved

- **Public API** `bind(game)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`, `add_resource(n)`, `remove(id)` — signatures and behaviour untouched.
- **Ghost provider** `_mesh_info(sid, kind)` and `_stage_mesh_info(sid, suffix, scaffold)` keep their call signatures, cache keys and returned Dictionaries; `world3d_fx.gd:657-672` sees no change.
- **Construction stages** `BUILD_STAGE_*`, `_build_stage_suffix()`, `_stage_mesh_info()`, `_sync_building_stages()` and every stage/scaffold `set_meta` are unmodified; the stage-swap tint re-application at `:1882-1890` now reuses a cached material **with the same `custColor`** instead of creating a fresh one.
- **Mine disc / decor** ENV_SCALE, envscale ladder, jitter bands, `_resource_sid()` and the mine material path are untouched; the three mine sids keep `TRANSPARENCY_ALPHA_SCISSOR` as before.
- **Teleport / rebind** `_release()` swap-remove/indices, `_xf()` live-position read, the frozen-frame `mm.mesh` rebind and `world3d.gd` feed are untouched. `_grow_batch()` rewrites every existing transform from the CPU mirror, so a capacity resize cannot drop a teleported position; field instance colours are restored from `_field_visual`.
- **Field** `_new_batch()` still toggles `use_colors` while `instance_count == 0` before any allocation (Godot 4.7 constraint noted at `:1406-1417`); field stage colours and `mm.set_instance_color()` in `sync()` are unchanged.
- **Rotor / mill** no changed line is inside the rotor constants, `_attach_rotor()`, `_rotor_mesh()`, `_rotor_material()` or the rotor loop; M03 can apply its patch independently.
- **Labels / tests** no PORT APPROXIMATION string, donor citation, assertion, threshold or `expected_pre_fix_failure` is changed. The only new `stats` keys are additive telemetry.

## 5. Backup and application instructions (NOT executed by P11)

1. Wait for COORD's explicit post-G04/post-M03 ownership grant. P11 has **not** edited the file.
2. Create the required backup **before** the first edit (Windows `cmd`):

   ```
   copy /Y variant3d\scripts\world3d_entities.gd inbox\backup\world3d_entities.gd.bak-P11
   ```

   (`inbox/backup/` already holds B01-B06 backups; do not overwrite them.)
3. Check the patch applies cleanly, then apply it:

   ```
   git apply --check <P11.patch>
   git apply <P11.patch>
   ```

   Re-export the diff from §3 into the patch file verbatim; do not hand-retype it.
4. Confirm `git diff --stat` names **only** `variant3d/scripts/world3d_entities.gd`.
5. Do **not** run Godot from this lane. Submit gates only via G04 with unique runner ids.

## 6. Regression list (all assertions unchanged)

| Gate / atom | What to verify after the patch lands |
|---|---|
| variant selftest (`selftest.json`, 29/29) and uitest (17/17), `t_render_mode`, `assert_clean CLEAN` | Same pass counts; no new script errors; no `batch full` warning at normal load. |
| `t_entities3d.gd` (`v734_entities3d`) | `api_surface`, `node_count_grows`, `node_count_shrinks`, `remove_below_baseline`, `no_sprite_sheet_loads` (comment-stripped structural scan — the new code introduces none of the forbidden patterns), `no_internal_errors`. |
| `t_terrain_trees.gd` | `tree_instance_count`, `Batch_res_<sid>_STATIC_POSE` names, CPU transform mirror Y/water checks, windowed PNG diff vs P0 baseline (tree silhouettes pixel-identical within the existing threshold). |
| `t_combo_trees_mines.gd`, `t_combo_shore_mines.gd`, `t_combo_all.gd` | `instances` counts (15 batches / 29 resources in the recorded result), ore/tree/stone/field counts, `visible_instance_count` unchanged; no batch-name classification change. |
| `t_terrain_mines.gd` | `ENV_SCALE.mine = 0.3152`, mine instance counts and albedo-disc rendering unchanged. |
| `t_motion_capture.gd` | Morph frame sequence, teleport/rebind continuity; no frozen-frame mesh mismatch. |
| `t_ghost_final_stage.gd` (G02) | Ghost still resolves the finished base mesh through `_mesh_info()` / `_stage_mesh_info()`; ghost material/transparency unchanged. |
| Construction-stage probes | `stats["build_stage_counts"]`, `build_stage_obj_hits`, `build_stage_scaffolds`, `build_stage_label/visual`, stage tint re-application on real mesh swap. |
| Windowed P0 / real-map captures (G04 only) | No black rows, no new seams, no silhouette change; fixed-seed A/B against the pre-P11 frame; `grid_peak` unchanged. |
| New structural stats (read-only) | `batch_instance_slots_allocated <= batch_instance_slots_ceiling`; with key colours loaded, `tint_materials_shared > 0` after units/buildings appear; `batches`, `units`, `resources`, `buildings` unchanged at equal sim state. |

## 7. UNVERIFIED register

| Item | Status |
|---|---|
| FPS / frame-time delta from this diff | `[E] UNVERIFIED` — no runner, no windowed capture, no profiler. |
| Draw-call count delta | `[E] UNVERIFIED`. Tier 1 keeps the same number of draw calls; Tier 2 (building MultiMesh) is deferred and would need a windowed `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` probe. |
| `sync_ms` improvement | `[E] UNVERIFIED`. Prior 276.77/272.56 ms values (`PERF_3D_01.md`) describe the unmodified tree and are not attributable to P11. |
| Exact bytes/GPU saved by 64-slot initial capacity | `[E] UNVERIFIED` — depends on Godot's internal MultiMesh buffer layout and on real batch cardinality; needs a telemetry run with the new stats keys. |
| Shader-parse / material-allocation saving | `[E] UNVERIFIED` — code shape is O(1) cache hit vs fresh `Shader.new()` per call (`:989-992`), but no profiler measurement exists. |
| Visual parity | NONE CLAIMED. All donor-derived labels remain PORT APPROXIMATION; visual UNVERIFIED. |
| P02 fidelity | `[O]` reconciled with the landed `P02_draw_calls.md` (F4/F5 + honourable mention); no divergence on P11-owned items. `[E] UNVERIFIED` that the chosen subset delivers a measurable FPS/draw-call gain — P02's own ranking and all magnitudes are structural inferences with no windowed capture. |

*End of P11 proposal. No code was edited by P11.*
