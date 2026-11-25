---
id: B06
ticket: "B06 — building-placement ghost shows the LAST / completed build stage"
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
status: IMPLEMENTED__NO_GODOT_JOB__NO_PARITY_CLAIM
owner: "B06 (exclusive implementation owner, COORD correction 2026-11-25)"
edited_source: "variant3d/scripts/world3d_fx.gd (only)"
untouched_source: "variant3d/scripts/world3d_entities.gd (construction stage selector left byte-identical)"
backup: "inbox/backup/world3d_fx.gd.bak-B06"
output: "docs/terrain_swarm_2026-11-25/reports/B06_ghost_impl.md"
labels: [observed, derived, UNVERIFIED, PORT APPROXIMATION]
---

# B06 — Ghost must show the finished building (implementation)

## 0. Result in one line

**OBSERVED (this edit):** the 3D placement ghost now resolves the **completed/base
mesh first** via `world3d_fx.gd:657-662`, falls back to the **last construction
stage suffix `"4"`** at `:667-672`, and **never requests stage `"1"`** again. The
stage-1 request at old `:645` and the stage-1 direct-load fallback at old `:662`
were removed. The stale node name `GhostBuildingStage0` became
`GhostBuildingFinished` (`:922`). All green/red validity, tint/alpha, footprint
fallback and cancel/place cleanup code is byte-identical. **No Godot job was run**;
the rendered result stays **UNVERIFIED**.

Scope note (COORD correction): the original ticket named `world3d_entities.gd`,
but A12 §3.1/E01/E02/F02 located the defect in `world3d_fx.gd`. Per the
correction, **only `world3d_fx.gd` was edited**; `world3d_entities.gd` needed no
change because its `_stage_mesh_info(sid, suffix, scaffold)` already accepts any
suffix and its `_sync_building_stages()` remains the sole construction-stage
selector.

---

## 1. Sources read (all read-only except the one edited file)

| # | Source | Use | Label |
|---|---|---|---|
| S1 | `docs/terrain_swarm_2026-11-25/CHARTER.md:81-84`, `:55-69` | Owner requirement §1b.3; backup/no-runner/ownership guardrails | OBSERVED |
| S2 | `docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md:134-140`, `:179` (K8 proposal) | Ghost defect location; K8 key deliberately **NOT** added | OBSERVED |
| S3 | `docs/terrain_swarm_2026-11-25/reports/E01_ghost_audit.md:18-23`, `:119-150`, `:204-245` | Root cause: literal `"1"` at `world3d_fx.gd:645` and `:662` | OBSERVED (report) |
| S4 | `docs/terrain_swarm_2026-11-25/reports/E02_final_stage_assets.md:61-81`, `:97-117`, `:127-147`, `:156-159` | Asset inventory; 12/19 sids have base + stage 4; loader map | OBSERVED (report) |
| S5 | `docs/terrain_swarm_2026-11-25/reports/F02_almanac_building_ghost.md:214-230`, `:271-284`, `:330-374`, `:382-386` | Donor research, 2D precedent, concrete recommendation | OBSERVED (report) / UNVERIFIED donor ghost |
| S6 | `docs/terrain_swarm_2026-11-25/reports/E04_ghost_qa.md:356-374`, `:435-488` | QA atom: mesh identity vs `_mesh_info`, no foundation, no stale `Stage0` name | OBSERVED (report) |
| S7 | `variant3d/scripts/world3d_fx.gd` (edited), `world3d_entities.gd`, `world3d.gd:463-498`, `world.gd:3516-3519`, `input_controller.gd:744-747,858-860,1153-1158`, `hud.gd:102` | Implementation, provider, validity gates, clear paths | OBSERVED |
| S8 | `variant3d/assets/models/manifest.json:1069-1085` (`hou`), `:3462-3541` (`hou1..hou4`); `variant3d/assets/models/obj/**` | On-disk mesh paths and bboxes | OBSERVED |
| S9 | `docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md` (via S3/S4/S5) | Donor stage-slot and suffix citations (`unit.script:6596`, `ontagstates.inc:240-251`, `engcen.prop:72-112`) | OBSERVED (inherited citation) |

---

## 2. Exact diff

Backup taken before edit: `inbox/backup/world3d_fx.gd.bak-B06` (67,530 bytes).
`git diff -- variant3d/scripts/world3d_fx.gd` (verbatim):

```diff
diff --git a/variant3d/scripts/world3d_fx.gd b/variant3d/scripts/world3d_fx.gd
index 2ad6daa4..ce93821a 100644
--- a/variant3d/scripts/world3d_fx.gd
+++ b/variant3d/scripts/world3d_fx.gd
@@ -268,11 +268,17 @@ var stats: Dictionary = {
 var _root: Node3D = null
 var _ghost_root: Node3D = null
 var _ghost_mesh: MeshInstance3D = null
-# B-GHOST-FIX — transparent stage-0 building preview (PORT APPROXIMATION, NOT DONOR PARITY).
+# B06 — transparent FINISHED-building hologram (OWNER REQUIREMENT §1b.3).
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
+	# B06 / OWNER REQUIREMENT §1b.3: preview the FINISHED structure, never the
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
+		# Primary ghost node: FINISHED building mesh (B06 / owner §1b.3),
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

`git status --short` after the edit shows `world3d_fx.gd` modified plus this
report and the backup (alongside unrelated concurrent swarm-agent files);
`variant3d/scripts/world3d_entities.gd` is **not** modified by B06.

---

## 3. Resolution order and mesh-path evidence

New `_ghost_resolve_mesh()` (post-edit lines 640-694):

| Step | Call / path | Source string written to `stats["ghost_mesh_source"]` | Evidence |
|---|---|---|---|
| 1 | `provider.call("_mesh_info", sid, "building")` (`:657-662`) | `finished_base|<provider source>` | `world3d_entities.gd:1110-1160` bakes GLB → OBJ → bbox proxy; completed buildings use this exact mesh at `:1869-1877`. `manifest.json:1069-1085` — `hou` → `.../obj/hou.obj`, donor mesh `...\ukr\ukrhou.osm`, bbox height 5.507 m. |
| 2 | `provider.call("_stage_mesh_info", sid, "4", false)` (`:667-672`) | `last_stage_4|<provider source>` | `world3d_entities.gd:1819-1844` builds `OBJ_DIR + sid + "4" + ".obj"` with per-stage manifest bbox. `manifest.json:3525-3541` — `hou4` → `.../obj/hou4.obj`, donor `...\ukr\ukrhou4.osm`, bbox `[-4.809,5.973; -4.038,4.076; -0.003,5.448]`. |
| 3 | Direct load, no provider (`:678-693`) | `direct_load_fallback_unbaked` (unchanged string) | `obj/<sid>.obj` → `glb/<sid>.glb` → `obj/<sid>4.obj`; **no `<sid>1.obj`**. Unbaked / UNVERIFIED vs the provider bake; PORT APPROXIMATION. |
| 4 | Flat `Footprint` box | — | `world3d_fx.gd:598` / `:910-916` unchanged (post-edit lines): `BoxMesh(1,0.05,1)` scaled by `Data.BUILDINGS[sid].radius` (`_building_radius`, `:1553`). Shown only when steps 1-3 yield no `Mesh` (`:628-637` unchanged). |

**DERIVED:** for the 12 art-bearing sids (`cen, hou, bar, sta, bla, aca, art,
dip, sto, mil, mar, tow`; E02 §3) step 1 wins, so the ghost and the completed
building share the **same `Mesh` instance** from `_mesh_info` (this is exactly
what E04's `ghost_mesh_is_final_finished` identity check asserts at
`E04_ghost_qa.md:456-464`). For the other 7 sids, step 1 degrades to the
existing base/proxy result and step 2 is a no-op when no stage art exists —
no fake mesh or invented sid is introduced.

---

## 4. Donor citations and PORT APPROX labels

- **Owner requirement (authoritative for this change):** CHARTER §1b.3 — ghost
  = last/completed stage, not first; translucent hologram, green valid / red
  blocked, pixel-honest footprint. Cited in the new comments as
  `OWNER REQUIREMENT §1b.3`, **not** as verified donor behaviour.
- **Donor build-stage truth (inherited citations, not re-read from donor):**
  `unit.script:6596` `stage = floor(progress*4)`; `ontagstates.inc:240-251`
  visual tag → mesh suffix `1..4`; `ontagstates.inc:247-248` wall fold
  `1 + stage div 3`; `engcen.prop:72-112` scaffold auto-child;
  `.actor` slot table `<sid>.osm` (finished) + `<sid>1..4.osm` + death stages
  (DBUILD_01 §2; F02 §1-§2; E02 §2). These justify why `"1"` is foundation and
  `"4"` is the last construction stage.
- **UNVERIFIED:** that the donor C3 in-game placement ghost itself displays the
  finished mesh. F02 §3.1 explicitly found no Cossacks-3-specific script line or
  screenshot for it; the generic hologram/green-red convention comes from a
  third-party page (F02 S4). There is **no donor GPU A/B frame**, so no visual
  parity claim is made (CHARTER §3/§6).
- **PORT APPROXIMATION — NOT DONOR PARITY:** the translucent ghost, its shared
  `_ghost_mat` tint/pulse, the radius-derived footprint square and the
  bbox-normalised converted OBJ meshes are all port-side art reuse. The port's
  radius model approximates the donor's 0.5-cell `.prop` collision mask
  (F02 §2.5/§4.3); the silhouette is **not** used as a legality mask. The
  effective policy change follows our own 2D ghost precedent
  (`world.gd:3517`, `finished:true`) — an internal port consistency argument,
  not donor proof.
- **No config key added:** A12's K8 (`features.ghost.stage_suffix`) is a proposal
  only. The change is a literal, minimal code edit with shipped default = new
  behaviour; no `config.gd`, JSON or runner was touched.

---

## 5. Explicitly preserved (regression list)

| # | Behaviour | Evidence it was not touched |
|---|---|---|
| R1 | Green valid / red blocked | `_ghost_ok = bool(ok)` assignment and `_update_ghost()` (`GHOST_OK`/`GHOST_BAD`, alpha pulse, shared `material_override`) are outside the diff; validity still comes from `world3d.gd:463-498` `can_place` + affordability. |
| R2 | Translucency / alpha / pulse / no depth write / no shadow | `_ghost_mat.depth_draw_mode = DEPTH_DRAW_DISABLED`, `_material()` and both `cast_shadow = OFF` lines unchanged; new mesh is attached to the **same** node/material (`:921-925`). |
| R3 | Footprint box fallback and radius source | `BoxMesh(1,0.05,1)` creation, `Footprint.scale = (r*2,1,r*2)` at `:598`, `_building_radius()` at `:1553` and show/hide at `:628-637` unchanged. Footprint is still hidden when a real mesh resolves, shown when none does. |
| R4 | Cancel / place cleanup | `input_controller.gd:744-747` (place), `:858-860` (right-click), `:1153-1158` (Escape), `:446-451` (mode change) and `world3d.gd:471-473` → `world3d_fx.gd:583-586` `draw_ghost("")` are untouched. Ghost nodes/cache keep the old reuse-not-free lifetime; no new node is allocated per frame. |
| R5 | Real construction stages after placement | `world3d_entities.gd` byte-identical: `_build_stage_suffix()` `:1805-1811`, `_stage_mesh_info()` `:1819-1844`, `_sync_building_stages()` `:1851-1936`, stage-1..4 art and scaffold child logic unchanged. The ghost's `"4"` call is a **read-only** provider call; it writes no sim/entity state. |
| R6 | Mesh cache and node identity | `_ghost_mesh_cache` reuse on unchanged sid (`:624-626`) and cache key by sid unchanged. Only the cached mesh's *source policy* changed. |
| R7 | Node-name consumers | Repo-wide grep for `GhostBuildingStage0` shows only reports/backups and the old `B_GHOST_FIX.md` history; no live code or test asserts the name. E04's `_find_building_ghost()` (`E04_ghost_qa.md:220-234`) is explicitly name-agnostic and its `no_foundation_mesh` check (`:476-488`) requires the stale name to be gone. |
| R8 | No runner / no other file | No Godot or runner job submitted by B06; no shader, test, `game.gd`, `input_controller.gd`, `world3d.gd`, `world.gd` or asset edit. |

**Residual UNVERIFIED risks (not regressions introduced here):**
1. No capture: the finished silhouette and its on-screen size at the live camera
   are unmeasured; COORD/Wave C must run E04's `e04-ghost-final` probe (status
   first) and the normal gates (variant selftest 29/29, uitest 17/17,
   `t_render_mode`, `assert_clean` CLEAN). This ticket explicitly did **not**
   run Godot.
2. The base mesh bbox (`hou` 10.78×8.17 m) is slightly larger than the stage-1
   foundation bbox (10.44×7.55 m) — the ghost now shows the honest completed
   footprint, but the `Footprint` square still uses the sim radius, not the
   donor `.prop` mask (F02 §4.3). Do not claim donor mask parity.
3. `bar18`/`dock` have no OBJ at all: `_mesh_info` returns a donor-bbox-derived
   proxy; the resulting ghost is a labelled placeholder, not finished art
   (E02 §3, no asset invented).
4. E04 records `expected_final_mesh_source` as `finished_base_mesh:<source>`;
   B06 writes `finished_base|<source>` into `stats["ghost_mesh_source"]`. These
   are different fields for different purposes; the E04 identity check uses
   `gm == _expected_final_mesh`, which the step-1 provider mesh satisfies.
   If QA prefers the telemetry string unified, that is a one-line follow-up,
   not a functional change.

---

*End of B06 report. Implementation is an owner-directed port policy change;
donor parity remains UNVERIFIED.*
