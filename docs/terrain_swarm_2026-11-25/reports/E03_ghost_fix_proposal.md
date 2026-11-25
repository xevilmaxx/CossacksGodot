---
id: E03
ticket: TERRAIN-SWARM-2026-11-25 / Wave E — BUILDING GHOST FINAL STAGE (fix proposal)
owner: E03 (read-only proposal subagent)
created: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
output: docs/terrain_swarm_2026-11-25/reports/E03_ghost_fix_proposal.md
scope: "Read-only. No .gd/.json/asset/test edited, no Godot/runner job, no donor file opened. This report is the only file written. Line numbers are given for the PRE-FIX baseline (HEAD / E01-E02 snapshot) and, where they moved, for the CURRENT worktree read this pass."
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
charter_refs: "CHARTER.md §1b.3 (ghost = LAST/finished stage, green valid / red blocked, pixel-honest footprint), §3 guardrails, §5.3 gates"
---

# E03 — Smallest concrete fix: ghost shows the LAST (finished) build stage

## 0. Answer in one line

**Change one file only — `variant3d/scripts/world3d_fx.gd`, function `_ghost_resolve_mesh()`.**
Replace the stage-`"1"` (first foundation) request with the **finished base mesh
`_mesh_info(sid, "building")` first**, the **last construction stage `"4"`
`_stage_mesh_info(sid, "4", false)` as fallback**, and reorder the standalone
fallback the same way. Nothing in `world3d_entities.gd` or `input_controller.gd`
needs to change.

> **Concurrency note (OBSERVED this pass).** The shared worktree already contains
> an equivalent edit by B06 (`git diff -- variant3d/scripts/world3d_fx.gd` shows
> `_ghost_building.name = "GhostBuildingFinished"`, `ghost_mesh_source` keys
> `finished_base|` / `last_stage_4|`, backup `inbox/backup/world3d_fx.gd.bak-B06`).
> The unified diff in §5 is therefore the **proposal against the pre-fix baseline**;
> do not re-apply it blindly — verify with the two greps in §6 first. E03 made no
> edit and ran no job.

---

## 1. Evidence base (all read-only)

| # | Source | What it establishes | Label |
|---|---|---|---|
| S1 | `CHARTER.md:81-84` | Owner requirement: ghost shows LAST/completed stage, translucent hologram, green valid / red blocked, pixel-honest footprint | OBSERVED (directive) |
| S2 | `docs/terrain_swarm_2026-11-25/reports/F02_almanac_building_ghost.md` §1-§5 | Donor base `<sid>.osm` = finished (`ActorList.Items[0]`), stages `<sid>1..4.osm`, completion selects base; ghost-preview convention green/red + "lying ghost" pitfall; **donor C3 ghost's own mesh UNVERIFIED** | OBSERVED (report), donor parity UNVERIFIED |
| S3 | `docs/terrain_swarm_2026-11-25/reports/E01_ghost_audit.md` §3-§4 | Defect at `world3d_fx.gd:645` (`suffix "1"`) and `:662` (`<sid>1.obj`); tint/alpha and cleanup already correct | OBSERVED + DERIVED |
| S4 | `docs/terrain_swarm_2026-11-25/reports/E02_final_stage_assets.md` §3, §5-§6 | Mesh inventory: 12/19 sids have base + stages 1..4; 7 have base only or nothing; loaders `_mesh_info` / `_stage_mesh_info` already public | OBSERVED |
| S5 | `variant3d/scripts/world3d_fx.gd` (pre-fix `:634-678`, current `:640-694`) | The exact resolver to change | OBSERVED |
| S6 | `variant3d/scripts/world3d_entities.gd:1790-1844,1851-1936` | Construction selector: suffix `"1"`=`[0,.25)`, `"4"`=`[.75,1)`; **finished buildings use the base mesh** (`:1867-1871`) | OBSERVED + DERIVED |
| S7 | `variant3d/scripts/world.gd:742-753,3516-3519` | The 2D ghost *already* previews finished art (`"finished": true, "progress": 1.0`); internal port precedent for the fix | OBSERVED |
| S8 | `variant3d/scripts/world3d.gd:463-498`; `world3d_fx.gd:141-142,580-598,1008-1016,1491-1501` | Validity green/red, material/tint, footprint, draw path — all already correct, leave alone | OBSERVED |

**Labels.** "Last stage = finished structure" is an **owner product decision**
(CHARTER §1b.3), not a verified Cossacks-3 ghost behaviour: F02 §3.1 explicitly
could not find donor evidence that the C3 placement ghost shows finished art.
No donor GPU A/B frame exists, so **visual parity stays UNVERIFIED** everywhere
below. Donor collision-mask values (`gc_collision_size = 0.5`, `.prop` vs
`CustomBoundingAABB`) are engine-side → **PORT APPROX** in our port.

---

## 2. Exact file / function — and why the ticket's guess is corrected

| Candidate from ticket | Verdict | Reason |
|---|---|---|
| `variant3d/scripts/world3d_entities.gd` | **Do NOT change** | `_build_stage_suffix()` / `_stage_mesh_info()` / `_sync_building_stages()` (`:1785-1936`) are the *construction* pipeline and already match the donor progress→visual-stage→mesh rule. Only the ghost's *choice* of mesh is wrong. |
| `variant3d/scripts/input_controller.gd` | **Do NOT change** | It only sets/clears `hud.build_ghost_sid` (`:744-747`, `:858-860`, `:1153-1158`, `:1201-1212`) and hands off the cursor point (`:1360-1362`). Sid state and validity are correct. |
| **`variant3d/scripts/world3d_fx.gd`** | **THE file** | `_ghost_resolve_mesh()` (pre-fix `:634-678`) hard-codes `provider.call("_stage_mesh_info", sid, "1", false)` at `:645` and the direct-load list starts with `<sid>1.obj` at `:662`. `_ensure_roots()` also bakes the wrong assumption into the node name `GhostBuildingStage0` (pre-fix `:904`). |

Secondary, optional (cosmetic only, no behaviour): rename that node to
`GhostBuildingFinished` in `_ensure_roots()`. `variant3d/tests/t_fx3d.gd:165,218-221`
asserts the **API surface** (`draw_ghost`, `draw_rally`), not the node name, so the
rename is safe; it must still be re-run (§7).

---

## 3. Exact mesh to use

**Primary: the finished base mesh `<sid>.obj`**, resolved read-only by
`provider.call("_mesh_info", sid, "building")`.

* Donor: base `<sid>.osm` is the completed building registered in
  `ActorList.Items[0]` (F02 §1; E02 §2). The numbered `1..4` meshes are
  construction stages, not the final structure.
* Port: this is the exact baked, bbox-normalised mesh a **finished** building
  wears — `_sync_building_stages()` keeps `_mesh_info(sid,"building")` for
  `finished=true` (`world3d_entities.gd:1867-1871`). Using it makes the hologram
  pixel-honest about the *final* silhouette.
* 2D parity: the sibling 2D ghost already requests the finished sprite
  (`world.gd:3517`). This fix removes the 2D/3D inconsistency.

**Fallback: the last construction stage `<sid>4.obj`** via
`provider.call("_stage_mesh_info", sid, "4", false)` — only if the base mesh
cannot be resolved. Suffix `"4"` is donor `floor(progress*4)→visual_stage_3`
(`ontagstates.inc:240-251`); walls fold to `"1"/"2"` (`ontagstates.inc:247-248`),
but no wall stage OBJ exists on disk, so base `wal.obj` always wins and no wall
special-case is needed.

**Never** request suffix `"1"` or `<sid>1.obj` from the ghost path.

| Sid class (E02 §3) | Ghost mesh after fix | Fallback |
|---|---|---|
| 12 art-bearing (`cen, hou, bar, sta, bla, aca, art, dip, sto, mil, mar, tow`) | `<sid>.obj` (finished base, manifest bbox `_bbox[sid]`) | `<sid>4.obj` if base absent |
| `wal`, `gat`, `mine_gold/iron/coal` | base `<sid>.obj` (no stage art) | `donor_bbox_proxy` / flat `Footprint` |
| `bar18`, `dock` | no OBJ anywhere → proxy/footprint | unchanged labelled PORT APPROX |

Spot-check (OBSERVED `manifest.json:1069-1084,3525-3543`): `hou` base bbox
`(-4.809, 5.973, -4.038, 4.136)` vs `hou4` `(-4.809, 5.973, -4.038, 4.076)` —
the finished base and last stage share essentially the same footprint, so the
base choice cannot "shrink" the preview.

---

## 4. Things that must stay byte-identical

### 4.1 Tint / alpha / hologram look — no change

* `GHOST_OK = Color(0.20, 1.00, 0.30, 0.45)` green,
  `GHOST_BAD = Color(1.00, 0.25, 0.20, 0.45)` red (`world3d_fx.gd:141-142`,
  port precedent `world.gd:3509`). Exact donor shade is engine-side → **PORT APPROX**;
  green/red *semantics* are the generic convention (F02 §3, S4).
* `_material()` (current `:1008-1016`): `TRANSPARENCY_ALPHA`, `UNSHADED`,
  emission 0.35, `CULL_DISABLED`; ghost-specific
  `depth_draw_mode = DEPTH_DRAW_DISABLED` (`:908`), `cast_shadow = OFF`
  (`:915`/`:922` region), shared `material_override` on both ghost nodes.
* `_update_ghost()` (current `:1491-1501`) keeps the pulse
  `c.a *= 0.85 + 0.15*sin(_time*4.0)` → effective alpha ≈ **0.38–0.45**, and
  writes `albedo_color` + `emission` from `GHOST_OK/GHOST_BAD`.
* Consequence: swapping the mesh needs **no new material, no surface tint pass**.
  The base mesh's donor band-mask tint (world3d_entities.gd FIX-COLOR) is *not*
  applied to the ghost — the hologram stays flat green/red by design, matching
  the 2D ghost's flat tint (`world.gd:3519`). Do not add per-surface tint here.

### 4.2 Pixel-honest footprint — no change

Keep `world3d_fx.gd:591-592` (footprint `BoxMesh` scaled to `_building_radius(s)`)
and `:1535-1540` (reads `Data.BUILDINGS[sid].radius`) — the **same** radius source
as `game.gd:3932-3986 can_place()`. Never derive the footprint from the mesh
silhouette: the donor checks a `.prop` collision mask, separate from
`CustomBoundingAABB`/visual bounds (F02 §2.5; **PORT APPROX**, engine-side values).
When a mesh resolves, the flat footprint is deliberately hidden (`:632`/`:637`);
honesty then comes from the ghost mesh using the same manifest bbox as the placed
finished building. Residual risk: no donor per-cell mask overlay or partial
validity (e.g. wall crossing a rock) is drawn — unchanged, UNVERIFIED parity.

### 4.3 Cancel / place cleanup — no change

| Trigger | Site (input_controller.gd) | Effect |
|---|---|---|
| Successful place (no Shift) | `:744-747` | `hud.build_ghost_sid = ""`, select the new site |
| Right-click cancel | `:858-860` | `hud.build_ghost_sid = ""` |
| Escape cancel | `:1153-1158` | sid cleared, menu closed, "no resources spent" hint |
| Other mode engaged | `:446-451` | `_clear_pending_modes()` clears sid |

Next FX frame: `world3d.gd:471-473` calls `fx.draw_ghost("", Vector2.ZERO, false)` →
`world3d_fx.gd:577-580` sets `_ghost_active=false`, hides `BuildGhost3D`;
`_update_ghost()` (`:1476-1477`) also hides when inactive; `clear_all()`
(current `:779-793`) hides the root. The `MeshInstance3D` nodes and
`_ghost_mesh_cache` are intentionally **retained and reused**, not freed — a
cached mesh is now the finished mesh, so re-entry with the same sid is still
correct. Do not add a `queue_free()` for the ghost nodes; that would change
lifetime semantics outside this ticket.

---

## 5. Ready-to-apply unified diff

Applies to the **pre-fix baseline** (HEAD / E01-E02 line numbers). Paths relative
to `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`. Tabs inside
`.gd` are preserved below.

```diff
diff --git a/variant3d/scripts/world3d_fx.gd b/variant3d/scripts/world3d_fx.gd
--- a/variant3d/scripts/world3d_fx.gd
+++ b/variant3d/scripts/world3d_fx.gd
@@ -268,11 +268,17 @@ var stats: Dictionary = {
 var _root: Node3D = null
 var _ghost_root: Node3D = null
 var _ghost_mesh: MeshInstance3D = null
-# B-GHOST-FIX — transparent stage-0 building preview (PORT APPROXIMATION, NOT DONOR PARITY).
+# E03 / OWNER REQUIREMENT §1b.3 — transparent FINISHED-building hologram.
+# The port's 2D ghost already previews finished art (world.gd:3517
+# `_bld_tex({... "finished": true, "progress": 1.0 ...})`); this module now
+# matches it by resolving the completed base mesh FIRST, with the last
+# construction stage ("4") as fallback. "Donor ghost shows the finished stage"
+# is UNVERIFIED (F02 §3.1) — this is a product decision, not donor parity.
 # `_ghost_mesh` (Footprint BoxMesh) is kept ONLY as a fallback when the sid has
-# no stage-0/base art. The primary node below shows the actual building mesh
+# no base/last-stage art. The primary node below shows the actual building mesh
 # resolved through the entities module's baked provider (read-only call, no edit
 # to world3d_entities.gd); ghost tint/pulse/transparency come from _ghost_mat.
+# Whole ghost visual = PORT APPROXIMATION — NOT DONOR PARITY.
 var _ghost_building: MeshInstance3D = null
 var _ghost_building_sid: String = ""
 var _ghost_mesh_cache: Dictionary = {}
@@ -636,32 +642,42 @@ func _ghost_resolve_mesh(sid: String) -> Mesh:
 		return null
 	if _ghost_mesh_cache.has(sid):
 		return _ghost_mesh_cache[sid] as Mesh
-	# 1) Read-only call into the sibling entities module: already-baked,
-	# bbox-normalised stage-0 mesh. Stage-0 = suffix "1" (donor
-	# floor(progress*4), DBUILD_01 §2.2 carried cite); resolver at
-	# world3d_entities.gd:1796-1821, suffix rule at :1782-1788.
+	# E03 / OWNER REQUIREMENT §1b.3: preview the FINISHED structure, never the
+	# first foundation. The generic "translucent hologram, green valid / red
+	# blocked" convention is documented (F02 §3), but that the donor C3 ghost
+	# itself shows finished art is UNVERIFIED (F02 §3.1). Our own 2D ghost
+	# already previews the finished building (world.gd:3517, `finished:true`);
+	# the 3D path now follows that same established port policy.
+	# PORT APPROXIMATION — NOT DONOR PARITY.
 	var provider = _ghost_entities_provider()
+	# 1) Completed / base mesh FIRST: the exact baked, bbox-normalised mesh a
+	#    FINISHED building wears (world3d_entities.gd:1110-1160 `_mesh_info`,
+	#    applied at :1869-1877). Its own base-sid bbox keeps the hologram's
+	#    footprint honest against the placed building (E02 §5).
+	if provider != null and provider.has_method("_mesh_info"):
+		var base_info: Dictionary = provider.call("_mesh_info", sid, "building")
+		if not base_info.is_empty() and base_info.get("mesh") is Mesh:
+			_ghost_mesh_cache[sid] = base_info["mesh"]
+			stats["ghost_mesh_source"] = "finished_base|" + str(base_info.get("source", "base_obj"))
+			return base_info["mesh"] as Mesh
+	# 2) Last construction stage "4" ONLY when no base art resolves. E02 §3:
+	#    12/19 buildable sids have `<sid>4.obj`; the other 7 (wal/gat/mines/
+	#    bar18/dock) keep their safe base/proxy/footprint fallback. No stage
+	#    "1" is ever requested by this ghost path.
 	if provider != null and provider.has_method("_stage_mesh_info"):
-		var stage_info: Dictionary = provider.call("_stage_mesh_info", sid, "1", false)
+		var stage_info: Dictionary = provider.call("_stage_mesh_info", sid, "4", false)
 		if not stage_info.is_empty() and stage_info.get("mesh") is Mesh:
 			_ghost_mesh_cache[sid] = stage_info["mesh"]
-			stats["ghost_mesh_source"] = str(stage_info.get("source", "stage_obj"))
+			stats["ghost_mesh_source"] = "last_stage_4|" + str(stage_info.get("source", "stage_obj"))
 			return stage_info["mesh"] as Mesh
-		# Fallback within the provider: finished base mesh
-		# (world3d_entities.gd:1087-1137, MeshInstance3D at :1638-1640).
-		if provider.has_method("_mesh_info"):
-			var base_info: Dictionary = provider.call("_mesh_info", sid, "building")
-			if not base_info.is_empty() and base_info.get("mesh") is Mesh:
-				_ghost_mesh_cache[sid] = base_info["mesh"]
-				stats["ghost_mesh_source"] = str(base_info.get("source", "base_obj"))
-				return base_info["mesh"] as Mesh
-	# 2) Standalone fallback (no provider, e.g. isolated parse probe):
-	# minimal mesh-file lookup duplicated from world3d_entities.gd:1111-1127
-	# (GLB dir :85, OBJ dir :84). No Z-up->Y-up bake is duplicated here, so
-	# this path is PORT APPROXIMATION and UNVERIFIED vs the baked mesh.
-	for path in ["res://assets/models/obj/" + sid + "1.obj",
-			"res://assets/models/obj/" + sid + ".obj",
-			"res://assets/models/glb/" + sid + ".glb"]:
+	# 3) Standalone fallback (no provider, e.g. isolated parse probe):
+	# same policy — completed base first, last stage only if base is absent.
+	# Minimal mesh-file lookup duplicated from world3d_entities.gd:1110-1160
+	# / :1819-1844 (GLB dir :85, OBJ dir :84). No Z-up->Y-up bake is duplicated
+	# here, so this path is PORT APPROXIMATION and UNVERIFIED vs the baked mesh.
+	for path in ["res://assets/models/obj/" + sid + ".obj",
+			"res://assets/models/glb/" + sid + ".glb",
+			"res://assets/models/obj/" + sid + "4.obj"]:
 		if ResourceLoader.exists(path):
 			var loaded = load(path)
 			var m: Mesh = null
@@ -898,10 +914,12 @@ func _ensure_roots() -> void:
 		_ghost_mesh.material_override = _ghost_mat
 		_ghost_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 		_ghost_root.add_child(_ghost_mesh)
-		# Primary ghost node: actual stage-0 building mesh, transparent via the
-		# shared _ghost_mat (GHOST_OK/GHOST_BAD + pulse in _update_ghost).
+		# Primary ghost node: FINISHED building mesh (E03 / owner §1b.3),
+		# transparent via the shared _ghost_mat (GHOST_OK/GHOST_BAD + pulse in
+		# _update_ghost). Name changed from the old Stage0 to prevent a stale
+		# stage-1 label surviving in probes/reports.
 		_ghost_building = MeshInstance3D.new()
-		_ghost_building.name = "GhostBuildingStage0"
+		_ghost_building.name = "GhostBuildingFinished"
 		_ghost_building.material_override = _ghost_mat
 		_ghost_building.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 		_ghost_root.add_child(_ghost_building)
```

**Absolute-minimum alternative (COORD option).** If "LAST build stage" is to be
read literally as the numbered stage mesh rather than the completed base, the
semantic diff shrinks to two lines — `provider.call("_stage_mesh_info", sid,
"1", false)` → `"4"` (`:645`) and `sid + "1.obj"` → `sid + "4.obj"` (`:662`).
That also removes stage 1 and shows the last construction mesh, but it is
**not** F02/E02's donor-aligned reading of "finished" and is therefore *not* the
recommendation here.

---

## 6. Backup and apply instructions (for the implementing agent)

1. **Check first — the tree may already have the change** (B06 landed concurrently):
   ```
   Select-String -Path variant3d\scripts\world3d_fx.gd -Pattern 'GhostBuildingFinished','finished_base\|','_stage_mesh_info", sid, "1"'
   ```
   If `GhostBuildingFinished` and `finished_base|` are present and there is no
   `"1"` stage call, **do nothing** — the proposal is already applied.
2. **Backup before any edit** (CHARTER §3 / AGENT_PROTOCOL §0). Do not overwrite
   the existing B06 backup:
   ```
   Copy-Item variant3d\scripts\world3d_fx.gd inbox\backup\world3d_fx.gd.bak-E03
   ```
3. Apply §5 with tabs preserved. Keep every other file byte-identical.
4. Windows: use `python`, never `python3`; PowerShell `;`, not `&&`.
5. **E03 ran no Godot and submitted no runner job.** The implementer must use the
   serialized runner only, with a unique id, e.g.:
   ```
   python variant3d\tools\godot_runner.py run --id e03-selftest --timeout 180 -- --headless --path variant3d -- --self-test variant3d/selftest.json
   python variant3d\tools\godot_runner.py run --id e03-uitest --timeout 180 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
   ```
   Query `python variant3d\tools\godot_runner.py status` before submitting; one
   Godot at a time (CHARTER §3). Never invoke `godot` directly.

---

## 7. Tests that must stay green

**Mandatory release gates (CHARTER §5.3):**

| Gate | Command / check | Required verdict | Why this change touches it |
|---|---|---|---|
| Variant selftest | runner `--self-test variant3d/selftest.json` | `"passed": true`, **29/29** (verified on disk this pass) | includes the `build` step "house built in 3.1 s" — construction pipeline must not regress |
| Variant uitest | runner `--ui-test variant3d/uitest.json` | **17/17** (verified on disk this pass) | `variant3d/scripts/uitest.gd:160-167` covers ghost sid → site → builders |
| `t_render_mode` | `... --script res://tests/t_render_mode.gd` | all checks pass | ghost is fed per-frame only in 3D (`input_controller.gd:1360-1362`, `world3d.gd:682-687`) |
| Clean gate | `python variant3d\tools\assert_clean.py` | **CLEAN**, no orphaned Godot | runner hygiene, not a visual claim |
| 2D port | no edit under `app/` | untouched | guardrail §5.3 |

**Atomic tests directly on the changed surface (registry `variant3d/tests/manifest.json`):**

| Test id | File | Checks that must still pass |
|---|---|---|
| `t_fx3d` | `tests/t_fx3d.gd` | `API_SURFACE` (5 methods), `GHOST_RALLY_CALLS` (uses `GHOST_SID = "peasant"`, a no-stage-art sid → exercises the new base-first/proxy fallback), `NO_2D_SPRITE_SHEET_LOADS`, `NO_ERRORS`. Node rename is not asserted; re-run anyway. |
| `t_entities3d` | `tests/t_entities3d.gd` | Stage/base mesh resolution and the structural gate at `:215-234` (no `anim/` substring) — the construction selector was deliberately left untouched. |
| `t_build_flow` | `tests/building_block_test.gd` | Building placement/blocking (`game.gd:3932-3986` radius path) — footprint honesty must not change. |
| `t_mine_unified` | `tests/unified_mine_test.gd` | `mine_*` has no stage art; new fallback order must still resolve the base/proxy. |
| `t_camera3d`, `t_pick3d` | `tests/t_camera3d.gd`, `tests/t_pick3d.gd` | Cursor→world ghost handoff (`input_controller.gd:1360-1362` → `world3d.gd:784-786`) unchanged. |

**Add one E03-specific telemetry assertion (recommended, in the implementing ticket's own test/probe, not by E03):**
* For an art-bearing sid (e.g. `hou`) after `fx.draw_ghost("hou", wp, true)` with
  the sibling entities provider bound: `stats["ghost_mesh_source"]` must start
  with `finished_base|` and must **not** contain `stage_obj` or suffix `"1"`.
* For `wal` / `mine_*`: source must resolve to the base/proxy path, never a
  fabricated `<sid>1.obj` / `<sid>4.obj`.
* Source-string check: no `_stage_mesh_info(..., "1", ...)` and no
  `sid + "1.obj"` remain in `world3d_fx.gd`.

The full registry (`variant3d/tools/test_all.py` in the variant tree) is QA's final
suite; this proposal does not ask the implementer to duplicate it.

---

## 8. Label ledger and open questions

* **OWNER DIRECTIVE:** ghost = LAST/finished structure (CHARTER §1b.3). Implemented
  as "completed base mesh first", the donor-aligned reading of "finished" (F02 §1,
  E02 §2, S6/S7).
* **GENERIC CONVENTION (F02 §3 / S4):** translucent hologram, green valid / red
  blocked, pixel-honest footprint. Exact Cossacks-3 ghost mesh/colour is **UNVERIFIED**.
* **PORT APPROXIMATION:** the whole 3D hologram (procedural material, alpha/pulse,
  radius-square footprint); donor engine-side mask values are not reproduced.
  No donor parity from a GPU A/B frame exists.
* **Open Q1:** if COORD prefers literal `<sid>4.obj` over the completed base, use
  the two-line alternative in §5 — but record the decision explicitly.
* **Open Q2 (non-blocking):** in the standalone fallback, GLB precedes
  `<sid>4.obj`. No registered sid has that combination (E02 §3), so no behavioural
  difference today; leave as-is unless a future sid needs it.
* **Open Q3:** `_ghost_mesh_cache` is keyed by sid only; flipping the policy inside
  one process requires a restart (or a future cache clear). Not needed for this fix.

*End of E03 report. Read-only: no code/config/asset/test edited; no Godot job submitted.*
