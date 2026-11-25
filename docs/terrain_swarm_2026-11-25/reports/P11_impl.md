---
id: P11-IMPL
ticket: "Wave P / P11 — IMPLEMENT: world3d_entities.gd draw-call / instance reduction"
owner: P11 (exclusive owner of variant3d/scripts/world3d_entities.gd for this tranche)
created: 2026-11-25
status: LANDED__NO_GODOT__NO_RUNNER_JOB__DISJOINT_FROM_M03_F2_03
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
source_read_first: [WAVE_G_CHARTER.md, CHARTER.md, P01_frame_hotspots.md, P02_draw_calls.md, P11_entities_fix_proposal.md, L04_perf_integration.md, M03_mill_fix_proposal.md, F2_03_fields_fix.md, G04_gate_log.md]
parity_guard: "No Godot process was launched, no runner job submitted, no capture taken and no FPS/draw-call/frame-time measurement made (only G04 runs Godot: WAVE_G_CHARTER.md:31,67-70). Every gain below is an INFERRED structural expectation; measured FPS stays UNVERIFIED. No donor-parity claim; all PORT APPROXIMATION labels unchanged."
outputs: [variant3d/scripts/world3d_entities.gd, docs/terrain_swarm_2026-11-25/reports/P11_impl.md, inbox/backup/world3d_entities.gd.bak-P11]
---

# P11 — implementation report: `world3d_entities.gd` adaptive MultiMesh + shared tint material

## 0. What was done (and what was deliberately not)

Applied **exactly** the validated unified diff from `P11_entities_fix_proposal.md` §3, byte-for-byte, using `git apply --check` then `git apply`. The hunk bodies of the applied `git diff HEAD` are **identical** to the proposal patch (139/139 body lines; verified by `difflib`/regex header normalisation — §3 below). No hunk was retyped by hand.

The applied change consists of four mechanisms from the validated proposal:

1. **One shared `Shader` + per-`(sid, kind, tint RGBA, base-material-instance-id)` `ShaderMaterial` cache** (`_tint_shader`, `_tint_material_cache`), cleared on `bind()` — implements P02's honourable mention (`P02_draw_calls.md:192-194`) and removes the per-batch/per-stage-swap `Shader.new()` + `ShaderMaterial.new()` churn at old `:989-992`. Same uniforms, same donor band mask, same `custColor` per player slot; no art/tint/label value changed.
2. **Adaptive MultiMesh capacity**: `BATCH_INITIAL_CAPACITY = 64` (new), double-on-demand to the unchanged `BATCH_CAPACITY = 4096` ceiling through `_grow_batch()` (new). `_new_batch()` allocates 64 slots instead of 4096; `_acquire()` calls `_grow_batch()` only when the buffer is full. `_grow_batch()` restores every existing transform from the authoritative CPU `xforms` mirror and, for `res|field`, restores per-instance colours from `_field_visual` — so slot indices, node names, batch keys, `visible_instance_count`, teleport positions and field stage colours survive a resize.
3. **Additive stats keys only**: `batch_instance_slots_allocated`, `batch_instance_slots_ceiling`, `tint_materials_shared`, `batch_optimization_label`. No existing key renamed, removed or re-valued; no assertion, threshold, fixture or `expected_pre_fix_failure` touched.
4. **Nothing else.** No mill rotor, no field geometry, no construction-stage, no mine-disc, no ghost/provider, no teleport/rebind, no test change.

**Explicitly NOT applied — the "idle instance full-Transform3D push"**: the request asked to eliminate that push *only where the proposal marks it safe*. The proposal marks the opposite: `P11_entities_fix_proposal.md:71` lists "Dirty-flag Pass-2 transform rewrite" as **OUT OF SCOPE — "Leave to P01 owner; not duplicated here"**, and `L04_perf_integration.md:109,331` state that P01-F1/F2 has **no landed implementation proposal** and "must not be smuggled into P11's grant". The P11 §3 diff therefore contains no change to `_xf()` (old `:1551-1593`) or the Pass-2 `mm.set_instance_transform()` loop. Adding such a change here would contradict the validated diff, cross into P01's ungranted work and touch teleport/rebind semantics the proposal promises to keep byte-identical (P11 §4). It is left for its own ticket + fresh backup, exactly as L04 orders. This is a **deliberate omission with citations**, not an oversight.

No Godot process, no runner job, no `python variant3d\tools\godot_runner.py run` submission, no capture, no donor file access, no test/tool/config/result edit by this agent.

## 1. Backup and SHA verification (BEFORE the first edit)

Taken at the ownership handover, from the untouched working tree:

```
Copy-Item -LiteralPath "variant3d\scripts\world3d_entities.gd" `
          -Destination "inbox\backup\world3d_entities.gd.bak-P11" -Force
```

| Item | Value |
|---|---|
| `git rev-parse HEAD` | `032f2678833f623af4b0774d670e6b83764aee9c` (`step`) |
| HEAD blob for the file (`git rev-parse HEAD:variant3d/scripts/world3d_entities.gd`) | `65b6a2be07047442f63e6b9216c307b7e9f550d9` |
| `git hash-object` of working-tree file **before** edit | `65b6a2be07047442f63e6b9216c307b7e9f550d9` — **matches HEAD exactly** (file was clean in `git status`) |
| Pre-edit file SHA-256 | `0ed26bf174a8762915ecf6de98bda0f9a270383898251fb9a046f38d55829ecb` |
| Pre-edit file size / lines / endings | 106,234 bytes / 2,299 lines / LF-only (0 CRLF) |
| `inbox/backup/world3d_entities.gd.bak-P11` SHA-256 | `0ed26bf174a8762915ecf6de98bda0f9a270383898251fb9a046f38d55829ecb` — **identical to pre-edit file** |
| Post-edit file SHA-256 | `6e1b32d708c4cfafbd87ea52395717954c963f5280f19ba4d1763d9f24e7300b` |
| Post-edit file size / lines / endings | 109,643 bytes / 2,363 lines / LF-only (0 CRLF) |

**Verification chain**: HEAD blob == pre-edit `git hash-object` == backup byte content (same SHA-256) ⇒ the backup snapshots exactly the revision being patched; no earlier landed fix is rolled back. (Note: this repo has `core.autocrlf=true`; `git apply` initially rewrote the working copy with CRLF, so the file was normalised back to its original LF-only ending form. Git's own diff was unaffected; the final file is LF-only like the backup.)

## 2. Exact diff applied

Verified with `git apply --check --verbose` ("Checking patch ...") followed by `git apply --verbose` ("Applied patch ... cleanly"). `git diff --stat HEAD -- variant3d/scripts/world3d_entities.gd` reports **1 file changed, 69 insertions(+), 5 deletions(-)**.

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

`git diff --check` reports no whitespace problem in this file (the only `--check` warnings in the tree came from another agent's `B03_diversity_impl.md`, outside this ticket).

## 3. Mechanical verification

Run with a read-only Python script against the backup (pre-edit) and final file (both LF-decoded):

- **[1] Hunk-body identity**: after normalising git's trailing hunk context (`@@ -114,6 +114,9 @@ const TILE_M: float = 2.0` → `@@ -114,6 +114,9 @@`), the 139 body lines of `git diff HEAD` equal the 139 body lines extracted verbatim from the P11 proposal §3 fenced block. Result: **True**.
- **[2] Byte-level changed regions (backup → final, old file 1-based)** — every change is either a pure insertion or a 1–2 line replacement:

  | Op | old lines | new lines | delta |
  |---|---|---|---|
  | insert | after 117 | 117-119 | +3 |
  | insert | after 360 | 363-370 | +8 |
  | insert | after 373 | 384-386 | +3 |
  | insert | after 984 | 998-1003 | +6 |
  | replace | 989-990 | 1009-1011 | -2/+3 |
  | replace | 992 | 1013 | -1/+1 |
  | insert | after 996 | 1017 | +1 |
  | replace | 1417 | 1439-1442 | -1/+4 |
  | replace | 1438 | 1463-1491 | -1/+29 |
  | insert | after 1456 | 1509-1511 | +3 |
  | insert | after 2274 | 2330-2337 | +8 |

  The five replaced old lines are exactly: `var sh := Shader.new()`, `sh.code = TINT_SHADER_CODE`, `m.shader = sh`, `mm.instance_count = BATCH_CAPACITY`, `"key": key, "morph": is_morph}`. All are inside the P11 §3 diff; no other old line was deleted or altered.

## 4. Disjointness proof vs M03 / F2-03 / construction stages

The check compares the **old-file** changed-line set above with each claimant's old-file range from `L04_perf_integration.md:129-144`, `M03_mill_fix_proposal.md:196-310` and `F2_03_fields_fix.md:374-427`:

| Protected region (old file) | Overlap with P11 changes |
|---|---|
| M03 `:262-278` (mill/rotor constants + insertion zone), `:1689-1720`, `:1772-1800`, `:2153-2188` (rotor loop + stats) | **NONE** |
| F2-03 `:266-273` (field constants), `:2190-2253` (field visual pass + field stats) | **NONE** |
| Construction stages `:275-294`, `:379-380`, `:1785-1936`, `:2148-2151` | **NONE** |

A second, independent check extracted each protected byte block from the backup and confirmed **every old line in it falls inside an `equal` opcode** of the backup→final diff (no change at all):

| Region | Result |
|---|---|
| mill/rotor constants + M03 insertion zone `:258-278` | IDENTICAL |
| field constants `:266-273` | IDENTICAL |
| construction-stage constants `:275-294` | IDENTICAL |
| stage call + rotor loop `:2148-2188` | IDENTICAL |
| field visual pass `:2190-2253` | IDENTICAL |
| mine-disc `ENV_SCALE` `:119-123` | IDENTICAL |
| ghost provider area `:1110-1160` | IDENTICAL |
| teleport/rebind + `_xf()` `:1475-1593` | IDENTICAL |

**Conclusion**: M03 and F2-03 can take the file next with their validated hunks re-derived against the post-P11 bytes (L04:136-144: `git apply --recount --3way` or re-read + re-derive; fresh `.bak-M03` / `.bak-F2-03` at their handover). P11 makes no hunk in any region they own. The new P11 comment at old `:996` inside `_grow_batch()` mentions `MILLFIX F2` only as a read-only consumer of `_field_visual[...]["color"]` — it does not edit the field constants, the field visual pass or `FIELD_SPAN_M`, so the F2-03 alias plan (`FIELD_SPAN_M = FIELD_QUAD_SPAN_M`) keeps this consumer valid (F2-03 §8; L04:143-144).

## 5. Invariants preserved (P11 §4 contract)

- **Public API**: `bind(game)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`, `add_resource(n)`, `remove(id)` — signatures and behaviour untouched.
- **Ghost provider**: `_mesh_info(sid, kind)` / `_stage_mesh_info(sid, suffix, scaffold)` — no edit; `world3d_fx.gd` sees the same Dictionary keys (`mesh`, `source`, `sid`, `kind`, `bbox_sid`).
- **Construction stages**: `BUILD_STAGE_*`, `_build_stage_suffix()`, `_stage_mesh_info()`, `_sync_building_stages()` and all `set_meta` calls untouched. Stage-swap tint re-application (old `:1882-1890`) now reuses a cached material with the identical `custColor`.
- **Mine disc / decor**: `ENV_SCALE.mine = 0.3152`, envscale ladder, jitter bands, `_resource_sid()` and the three mine scissor materials byte-identical.
- **Teleport / rebind**: `_release()` swap-remove, `_xf()` live-position read, the frozen-frame `mm.mesh` rebind and the `world3d.gd` feed untouched; `_grow_batch()` rewrites every existing transform from the CPU mirror so a resize cannot lose a teleported position.
- **Field colour path**: `use_colors` is still toggled while `instance_count == 0` before any allocation (old `:1406-1417`, Godot 4.7 constraint); stage colours and `mm.set_instance_color()` in `sync()` unchanged; `_grow_batch()` restores colours from `_field_visual` for `res|field` only.
- **Rotor / mill**: no changed line in `_attach_rotor()`, `_rotor_mesh()`, `_rotor_material()`, the rotor loop, or any `MILL_ROTOR_*`/`ROTOR_*` constant.
- **Labels / tests**: no PORT APPROX string, donor citation, assertion, threshold or `expected_pre_fix_failure` changed. The only new `stats` keys are additive telemetry.
- **Mass-army contract**: `BATCH_CAPACITY = 4096` remains the hard ceiling; the 4096 warning and `return -1` path in `_acquire()` are untouched.

## 6. G04 gate list — to be run by G04 only, none run by P11

Standing rule: **only G04 submits runner jobs** (`WAVE_G_CHARTER.md:31,67-70`). P11 submits nothing. The following are the gates to execute/verify after this landing (from `G04_gate_log.md` §5, P11 proposal §6 and `L04_perf_integration.md` §5):

| # | Gate / atom | Expected / acceptance |
|---|---|---|
| 1 | variant selftest (`g04-selftest`, `selftest.json`) | fresh **29/29**, `passed=true`, `SCRIPT ERROR=0`, no new script errors, no `batch full` warning at normal load |
| 2 | uitest (`g04-uitest`) | **fresh 17/17 required**. G04 log §5.1 records the two attempts as `timed-out/-9` and `failed/1` (watchdog forced exit at 138 s), and the on-disk 17/17 as **stale** — L04 T0 requires a COORD decision before any HUD/speed/loader acceptance; do not cite stale 17/17 as a pass |
| 3 | `t_render_mode` (`g04-rendermode`) | `result=PASS`, `seam_missing=false`, 10/10, `SCRIPT ERROR=0` |
| 4 | `assert_clean` | **CLEAN** — no new warning/error; the P11 comment/member additions use literals only |
| 5 | `t_entities3d.gd` (`v734_entities3d`) | `api_surface`, `node_count_grows`, `node_count_shrinks`, `remove_below_baseline`, `no_sprite_sheet_loads` (new code introduces none of the forbidden patterns), `no_internal_errors`; structural peak=6 unchanged |
| 6 | `t_terrain_trees.gd` | `tree_instance_count`, `Batch_res_<sid>_STATIC_POSE` names, CPU transform-mirror Y/water checks; windowed PNG silhouettes unchanged vs the pre-P11 anchor within the existing threshold |
| 7 | `t_combo_trees_mines.gd`, `t_combo_shore_mines.gd`, `t_combo_all.gd` | `instances` / batch counts unchanged (15 batches / 29 resources in the recorded result), `visible_instance_count` unchanged, no batch-name classification change |
| 8 | `t_terrain_mines.gd` | `ENV_SCALE.mine = 0.3152`, mine counts and albedo-disc rendering unchanged |
| 9 | `t_motion_capture.gd` | morph frame sequence, teleport/rebind continuity, no frozen-frame mesh mismatch |
| 10 | `t_ghost_final_stage.gd` (G02) | ghost still resolves the finished base mesh through `_mesh_info()` / `_stage_mesh_info()`; ghost material/transparency unchanged |
| 11 | Construction-stage probes | `stats["build_stage_counts"]`, `build_stage_obj_hits`, `build_stage_scaffolds`, `build_stage_label/visual`, stage tint re-application on real mesh swap |
| 12 | Windowed P0 + real-map captures (G04 only, fixed seed 20261113) | 1280×720 non-blank, `full_width_dark_rows=0`, `SCRIPT ERROR=0`; fixed-seed A/B against the pre-P11 anchor; no black rows, new seams or silhouette change; `grid_peak` unchanged |
| 13 | New structural stats (read-only) | `batch_instance_slots_allocated <= batch_instance_slots_ceiling`; `tint_materials_shared > 0` once key colours load and units/buildings appear; `batches`, `units`, `resources`, `buildings` unchanged at equal sim state |
| 14 | 2D `app/` hash / shared `game.gd` hash | byte-identical — P11 edited no 2D or sim file |

**Stop rules** (`L04:302-305`): any failing gate, `SCRIPT ERROR`, new seam/dark row, changed `expected_pre_fix_failure` or donor-parity claim → stop and restore `inbox/backup/world3d_entities.gd.bak-P11` in full; never hand-patch a hunk to force green.

## 7. UNVERIFIED register

| Item | Status |
|---|---|
| FPS / frame-time delta | `[U]` UNVERIFIED — no runner, no windowed capture, no profiler by P11 |
| Draw-call count delta | `[U]` UNVERIFIED — Tier 1 keeps the same number of draw calls; Tier 2 building batching explicitly deferred (P11 proposal §2) |
| `sync_ms` improvement | `[U]` UNVERIFIED — prior 276.77/272.56 ms figures describe the unmodified tree |
| Bytes/VRAM saved by 64-slot initial capacity | `[U]` UNVERIFIED — depends on Godot's internal MultiMesh buffer layout and real batch cardinality; use the new stats keys in a G04 telemetry run |
| Shader-parse / material-allocation saving | `[U]` UNVERIFIED — code shape is O(1) cache hit vs fresh `Shader.new()` per call; no profiler measurement |
| Visual parity | **NONE CLAIMED** — all donor labels remain PORT APPROXIMATION; visual UNVERIFIED until a fresh G04 capture |
| "Eliminate idle-instance Transform3D push" | **NOT APPLIED** — proposal marks it OUT OF SCOPE (`P11:71`), L04 forbids bundling (`L04:109,331`); its own ticket required |
| M03 / F2-03 post-P11 application | UNVERIFIED by P11 — later owners must re-derive their hunks and take fresh backups per L04 |

*End of P11 implementation report. One source file edited; backup verified against HEAD; no Godot, no runner, no test change; available for COORD follow-up.*
