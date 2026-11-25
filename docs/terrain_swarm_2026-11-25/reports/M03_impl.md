---
id: M03-IMPL
ticket: "WAVE M / M03-IMPL — apply the 4 validated mill-rotor hunks"
owner: M03 implementation subagent (EXCLUSIVE owner of variant3d/scripts/world3d_entities.gd for this tranche)
created: 2026-11-25
status: LANDED__NO_GODOT__NO_RUNNER__DISJOINT_FROM_P11_AND_F2_03
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md + WAVE_G_CHARTER.md read first"
prereads: [WAVE_G_CHARTER.md, CHARTER.md, M01_mill_rotor_audit.md, M02_donor_mill.md, M03_mill_fix_proposal.md, P11_impl.md, F2_03_fields_fix.md]
parity_guard: "Hub/axis GEOMETRY is donor-grounded by M03's read-only byte probe of eurmilanim.oss; the sail stand-in, spin SIGN and all pixels remain PORT APPROX / UNVERIFIED. No donor GPU A/B frame exists. No Godot launched, no runner job submitted, no capture taken."
outputs: [variant3d/scripts/world3d_entities.gd, docs/terrain_swarm_2026-11-25/reports/M03_impl.md, inbox/backup/world3d_entities.gd.bak-M03]
---

# M03 — implementation report: donor-grounded hub + fixed axle

## 0. Verdict in one paragraph

**OBSERVED:** the four hunks from `M03_mill_fix_proposal.md` §6 were applied byte-for-byte to
`variant3d/scripts/world3d_entities.gd` by `git apply` (the post-P11 tree; hunk offsets
+3/+56/+55/+56), producing `1 file changed, 51 insertions(+), 27 deletions(-)` and a
78-line changed-lines body **identical** to the validated proposal patch. The hub moved from
local `(0.173, 5.235, 0)` to the donor axle tip `(-0.176408, +5.626281, +1.894729)` m, the
stale billboard comment was rewritten, and the camera-facing basis was replaced by a fixed
local-Z axle (`Basis().rotated(Vector3.FORWARD, rotor_spin)` unchanged). **No whole-mill yaw
was added** — donor yaw is documented as 0 and `_xf()` is byte-identical. P11's cache/adaptive
capacity hunks, the mine disc, construction stages, ghost provider APIs, field art and all
tests are confirmed byte-identical. **UNVERIFIED:** pixels — no Godot, no runner, no capture,
per `WAVE_G_CHARTER.md:31,67-70` (only G04 runs jobs).

---

## 1. Backup and SHA verification (BEFORE the first edit)

Taken from the clean, post-P11 working tree:

```powershell
Copy-Item -LiteralPath "variant3d\scripts\world3d_entities.gd" `
          -Destination "inbox\backup\world3d_entities.gd.bak-M03" -Force
```

| Item | Value |
|---|---|
| `git rev-parse HEAD` | `3418d1e116ea163c87bbb692735249ebc13eff8b` |
| HEAD blob (`HEAD:variant3d/scripts/world3d_entities.gd`) | `35103220d0b546c556993411bab4f69c1c06158d` |
| Pre-edit `git hash-object` (working tree) | `35103220d0b546c556993411bab4f69c1c06158d` — **matches HEAD exactly** (clean file) |
| Pre-edit file SHA-256 | `6E1B32D708C4CFAFBD87EA52395717954C963F5280F19BA4D1763D9F24E7300B` |
| `inbox/backup/world3d_entities.gd.bak-M03` SHA-256 | `6E1B32D708C4CFAFBD87EA52395717954C963F5280F19BA4D1763D9F24E7300B` — **identical** |
| Backup size / lines / endings | 109,643 bytes / 2,363 lines / LF-only (0 CR) |
| Post-edit file SHA-256 | `DB20C179C1F0A289792652BC85C39215B7BAA1FBE1E9CA929F576C8FE2094EDC` |
| Post-edit `git hash-object` | `390fe934140bffe1c3e056b275a16cec6b02165d` |
| Post-edit size / lines / endings | 111,988 bytes / 2,387 lines / LF-only (0 CR) |

**Verification chain:** HEAD blob == pre-edit `git hash-object` == backup bytes (same SHA-256)
⇒ the backup snapshots exactly the post-P11 revision being patched; no earlier landed fix is
rolled back. The pre-edit SHA-256 equals P11's reported **post-edit** SHA-256
(`P11_impl.md:49`), proving the file handed over was precisely P11's landed state.

**Line-ending note:** as in P11 (`P11_impl.md:52`), this repo has `core.autocrlf=true`, so
`git apply` initially rewrote the working copy with CRLF. It was normalised back to the
original LF-only form; Git's diff is unaffected and `git diff --check HEAD` is clean (only the
benign "LF will be replaced by CRLF next time Git touches it" warning).

---

## 2. Exact diff applied

`git -c core.autocrlf=false diff HEAD -- variant3d/scripts/world3d_entities.gd` (the four
validated hunks, with post-P11 `@@` line numbers; git widened hunk 2's context by five lines
and shortened hunk 4's leading context by one — the **changed** lines are unchanged):

```diff
diff --git a/variant3d/scripts/world3d_entities.gd b/variant3d/scripts/world3d_entities.gd
index 35103220..390fe934 100644
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -265,6 +265,22 @@ const ROTOR_FALLBACK_STATUS: String = PORT_LABEL + " — rotor texture unavailab
 # .oss spin direction itself remains UNVERIFIED: this is a PORT APPROX
 # correction against the only readable donor-rotor proxy, not donor parity.
 const ROTOR_SPIN_AXIS_STATUS: String = PORT_LABEL + " — screen-clockwise spin axis aligned to the donor-derived 2D bake; donor .oss 3D direction UNVERIFIED"
+# M03 (2026-11-25) — DONOR-PROVEN 3-D axle, read-only byte probe of the shipped
+# donor attach `eurmilanim.oss` (k=251, fps=30, b=1, v=1098): raw Z-up vertex
+# bbox x[-2.996233,2.996233] y[-1.897957,-1.040952] z[2.627196,8.619664] m.
+# Disc plane is donor XZ (slab only 0.857 m thick in donor Y) -> spin axis
+# donor Y -> Godot local Z. Disc centre donor (0, -1.469455, 5.623430);
+# axle TIP (front face of slab) donor y=-1.897957. Tower `eurmil.osm` bbox
+# is in manifest.json:1209-1216. `_bake_mesh()` (:1079-1081) maps donor
+# (x,y,z) -> ((x-cx), (z-z0), -(y-cy)) at scale 1.0 for buildings, so the
+# axle tip is local (-0.1764, +5.6263, +1.8947) m: on the tower's +Z face,
+# which is the default Camera3D side (camera3d.gd:262-282). Body yaw 0 is
+# therefore donor-grounded; no whole-mill rotation is applied.
+const MILL_ROTOR_HUB_DONOR := Vector3(0.0, -1.4694546, 5.6234299)
+const MILL_ROTOR_AXLE_TIP_DONOR_Y: float = -1.8979570865631104
+const MILL_TOWER_BBOX_LO := Vector3(-2.425523519515991, -2.4005842208862305, -0.002850709017366171)
+const MILL_TOWER_BBOX_HI := Vector3(2.778339147567749, 2.3941283226013184, 5.914005756378174)
+const ROTOR_MOUNT_STATUS: String = PORT_LABEL + " — hub/axis geometry DONOR-GROUNDED from eurmilanim.oss via _bake_mesh() to the local +Z tower face; fixed axle, body yaw 0; spin SIGN and the 2D-bake-on-quad stand-in stay PORT APPROX, visual UNVERIFIED"
 
 # MILLFIX F2: field stage tints/scale are the EXACT 2D numbers from
 # app/scripts/world.gd:2588-2613; sow spacing is game.gd:2120 (1.6981 m,
@@ -1742,13 +1758,16 @@ func add_building(e) -> void:
 		_attach_rotor(id, mi)
 
 
-# MILLFIX F1 — donor-derived face-on rotor bake on a billboarded cutout quad.
-# Hub mapping (all donor numbers, no inventions):
-#   world.gd:651  hub = tl + sz*MILL_HUB, where tl = p - sz*(cx, foot)
-#   buildings.json ukr_mil:579,584-585,587 -> cx=0.4989, foot=ink[3]/cell=1.0
-#   => local X = (MILL_HUB.x - cx)*ortho = +0.173 m,
-#      local Y = (foot - MILL_HUB.y)*ortho = +5.235 m (tower cap; mesh is 5.917 m),
-#      local Z = 0 (billboard plane through tower centre).
+# MILLFIX F1 / M03 — donor-derived face-on rotor bake on a FIXED-AXLE cutout quad.
+# Superseded 2D-sheet hub (hx=+0.173, hy=+5.235, hz=0) is kept only in the
+# MILL_HUB/MILL_TOWER_* constants for the historical M04 atom; M01 §2.2/D1
+# showed hz=0 puts the sail plane through the tower mid-depth. M03 reads the
+# donor 3-D attach instead: eurmilanim.oss axle tip donor y=-1.897957 maps
+# through _bake_mesh() (:1079-1081) to local z=+1.8947 on the +Z tower face;
+# disc centre donor (0,-1.469455,5.623430) maps to local x=-0.1764, y=+5.6263.
+# Donor front is donor -Y -> local +Z = the default camera side, so NO whole-
+# mill yaw is added (M01 §2.4's -90 deg yaw is rejected: bake_mill_rotor.py:8-12
+# says the donor +X view is the EDGE-ON view, not the front).
 # Quad span = MILL_ROTOR_ORTHO (6.352 m), i.e. the full baked cell, NOT half.
 func _rotor_mesh() -> Mesh:
 	var half := MILL_ROTOR_ORTHO * 0.5
@@ -1827,9 +1846,17 @@ func _attach_rotor(id: int, parent: MeshInstance3D) -> void:
 	var rotor_mat := _rotor_material()
 	rotor.material_override = rotor_mat
 	rotor.set_meta("rotor_texture_status", rotor_mat.get_meta("rotor_texture_status", "?"))
-	var hx := (MILL_HUB.x - MILL_TOWER_CX) * MILL_TOWER_ORTHO
-	var hy := (MILL_TOWER_FOOT - MILL_HUB.y) * MILL_TOWER_ORTHO
-	rotor.position = Vector3(hx, hy, 0.0)
+	# M03 donor axle tip: disc centre from eurmilanim.oss, axle tip at the
+	# slab's donor -Y face so the quad clears the tower (tower face at hub
+	# height is donor y~-1.784 -> local z~+1.781; tip local z=+1.8947).
+	# _bake_mesh() mapping at :1079-1081, tower bbox at manifest.json:1209-1216.
+	var tower_ctr := (MILL_TOWER_BBOX_LO + MILL_TOWER_BBOX_HI) * 0.5
+	rotor.position = Vector3(
+		MILL_ROTOR_HUB_DONOR.x - tower_ctr.x,
+		MILL_ROTOR_HUB_DONOR.z - MILL_TOWER_BBOX_LO.z,
+		-(MILL_ROTOR_AXLE_TIP_DONOR_Y - tower_ctr.y))
+	rotor.set_meta("hub_source", ROTOR_MOUNT_STATUS)
+	rotor.set_meta("hub_local_m", [rotor.position.x, rotor.position.y, rotor.position.z])
 	rotor.set_meta("visual_status", ROTOR_STATUS)
 	rotor.set_meta("donor_source", ROTOR_TEX_PATH)
 	rotor.set_meta("donor_meta", ROTOR_META_PATH)
@@ -2212,35 +2239,32 @@ func sync(dt: float) -> void:
 	# rotation stays the authoritative angle: angle = _anim_t * MILL_SPIN,
 	# i.e. exactly the donor 0.75 rad/s of world.gd:204/652.
 	var rotor_spin := _anim_t * MILL_SPIN
-	var vp: Variant = get_viewport()
-	var cam: Variant = null
-	if vp != null and vp.has_method("get_camera_3d"):
-		cam = vp.call("get_camera_3d")
 	for id in _rotors.keys():
 		var rotor = _rotors[id]
 		if not is_instance_valid(rotor):
 			_rotors.erase(id)
 			continue
-		var face := Basis()
-		if cam != null:
-			var delta: Vector3 = cam.global_position - rotor.global_position
-			if delta.length_squared() > 0.0001:
-				var d := delta.normalized()
-				if absf(d.dot(Vector3.UP)) < 0.999:
-					var rx := Vector3.UP.cross(d).normalized()
-					var ry := d.cross(rx).normalized()
-					face = Basis(rx, ry, d)   # local +Z faces the camera
-		# MOTION-ANIM-01/ROTOR: local +Z (FORWARD) makes a positive spin screen-
-		# clockwise, matching the donor-derived 2D bake at world.gd:640-654.
-		# BACK spun the sail the other way; donor .oss 3D direction UNVERIFIED.
+	# M03: FIXED AXLE — no camera billboard. The donor attach mesh mounts the
+	# sail on donor -Y -> local +Z, which is the default Camera3D side
+	# (camera3d.gd:262-282); a camera-following basis would swing the sail
+	# through the tower when viewed from behind. Keep body yaw 0 (donor-
+	# grounded); do NOT apply M01 §2.4's -90 deg yaw. Spin axis stays local Z
+	# (donor slab thin in donor Y -> Godot Z: DONOR-PROVEN axis); the SIGN is
+	# PORT APPROX vs the 2D bake proxy. Do NOT flip to Vector3.BACK: M01 D3
+	# shows MOTION_ANIM_01.md:240's justification was wrong but the code right.
 		rotor.transform = Transform3D(
-			face * Basis().rotated(Vector3.FORWARD, rotor_spin), rotor.position)
+			Basis().rotated(Vector3.FORWARD, rotor_spin), rotor.position)
 		var re = _refs.get(int(id))
 		rotor.visible = re is Dictionary and bool((re as Dictionary).get("finished", true))
 	stats["mill_rotor_angle_rad"] = rotor_spin
 	stats["mill_rotor_count"] = _rotors.size()
 	stats["mill_rotor_label"] = ROTOR_STATUS
 	stats["mill_rotor_spin_axis_label"] = ROTOR_SPIN_AXIS_STATUS
+	stats["mill_rotor_mount_label"] = ROTOR_MOUNT_STATUS
+	stats["mill_rotor_hub_local_m"] = [
+		MILL_ROTOR_HUB_DONOR.x - (MILL_TOWER_BBOX_LO.x + MILL_TOWER_BBOX_HI.x) * 0.5,
+		MILL_ROTOR_HUB_DONOR.z - MILL_TOWER_BBOX_LO.z,
+		-(MILL_ROTOR_AXLE_TIP_DONOR_Y - (MILL_TOWER_BBOX_LO.y + MILL_TOWER_BBOX_HI.y) * 0.5)]
 	stats["mill_rotor_texture_fallback_used"] = _rotor_fallback_warned
```

---

## 3. Mechanical verification

| Check | Result |
|---|---|
| `git apply --check --verbose` | 4 hunks succeeded at 265 (offset 3), 1761 (offset 56), 1846 (offset 55), 2236 (offset 56) — offsets are exactly P11's line shift |
| `git apply --verbose` | "Applied patch ... cleanly" — all 4 hunks |
| `git diff --stat HEAD` | 1 file changed, 51 insertions(+), 27 deletions(-) (= 78 changed lines) |
| Changed-lines identity vs `M03_mill_fix_proposal.md` §6 | **78/78 lines byte-identical** (Python `difflib`, `+`/`−` lines only, UTF-8) |
| `git diff --check HEAD` | CLEAN (no whitespace error) |
| Derived hub from the new constants | `(-0.176408, 5.626281, +1.894729)` — matches M03 §6.1 acceptance values exactly (`tower_ctr=(0.1764078, -0.0032279)`) |
| New symbols (final file) | constants `:279-283`; `tower_ctr`/hub `:1853-1859`; metas `:1858-1859`; stats keys `:2263-2267` |

**Spin/axis/yaw guards:** `get_viewport` and `get_camera_3d` no longer occur in the `sync()`
rotor block; `face * Basis().rotated(...)` is gone; `Basis().rotated(Vector3.FORWARD,
rotor_spin)` and `MILL_SPIN = 0.75` are unchanged; `Vector3.BACK` is not used for rotor spin.
`_xf()` (the yaw source) is byte-identical — no whole-mill yaw was added. Rotor `visible =
e.finished` and `_rotors` lifecycle are untouched.

---

## 4. Disjointness proof vs P11 and F2-03

Method: byte-compare protected region bodies between the backup (post-P11, pre-M03) and the
final file (post-P11+M03) using exact anchor strings (line-number-independent), and check
whether any P11/F2-03 landmark line falls in M03's changed-line set. M03's change ranges in
the final file are: `new[268-283]`, `new[1761-1770]`, `new[1849-1859]`, `new[2242-2241]`,
`new[2247-2254]`, `new[2256-2256]`, `new[2263-2267]` (final-file 1-based).

### 4.1 vs P11 (`P11_impl.md`, `world3d_entities.gd.bak-P11`)

| P11 protected region | Lines checked | Backup vs final |
|---|---|---|
| `BATCH_INITIAL_CAPACITY` constant | 1 | **IDENTICAL** |
| `_tint_shader` / `_tint_material_cache` vars | 2 | **IDENTICAL** |
| `bind()` cache clear | 3 | **IDENTICAL** |
| `_tinted_material()` cache key + cache store | 20 | **IDENTICAL** |
| `_new_batch()` initial capacity | 5 | **IDENTICAL** |
| `_grow_batch()` body | 25 | **IDENTICAL** |
| `_acquire()` grow call | 3 | **IDENTICAL** |
| P11 stats telemetry block | 8 | **IDENTICAL** |

P11 landmarks at final lines 119, 368, 386, 998, 1441, 1471, 1511, 2334 — **none** is in
M03's changed-line set. Moreover, P11's edit is already committed in HEAD (`HEAD` blob equals
the pre-M03 backup); the only working-tree diff against HEAD is M03's four hunks, so no P11
byte could have been altered without appearing as an extra hunk. **Conclusion: fully
disjoint.**

### 4.2 vs F2-03 (`F2_03_fields_fix.md` §5.2 protected regions)

| F2-03 protected region | Lines checked | Backup vs final |
|---|---|---|
| Field constants (`FIELD_STEP_M`, `FIELD_SPAN_M`, decal paths, `FIELD_STATUS`) | 8 | **IDENTICAL** |
| Field visual pass (`:2190-2270` equivalent; tint/scale/`_field_visual`/stats) | 64 | **IDENTICAL** |

M03 hunk 1 inserts its comment/constants **immediately before** the `# MILLFIX F2:` field
constant block without touching it; hunk 4 inserts its two stats keys after
`mill_rotor_spin_axis_label` and before the field pass. The F2-03 alias plan
(`FIELD_SPAN_M = FIELD_QUAD_SPAN_M`) and P11's `_field_visual[...]["color"]` consumer remain
valid. **Conclusion: fully disjoint.**

---

## 5. Regions preserved byte-identical (all verified)

| Region | Result |
|---|---|
| Mine disc / band mask (`MINE_DISC_STATUS`, `ENV_SCALE.mine`, scissor materials) | IDENTICAL |
| Construction stages (`_build_progress01`, `_build_stage_suffix`, `_stage_mesh_info`, `_sync_building_stages`, `_xf()`-adjacent call site) | IDENTICAL (88 + 15 + 14 + 32 lines) |
| Ghost provider APIs (`_mesh_info`, `_stage_mesh_info`) | IDENTICAL (53 + 32 lines) |
| Field art (decal paths, tints, scale path, stats) | IDENTICAL (64 lines) |
| Rotor texture paths, `_rotor_material()`, `_rotor_mesh()` import/fallback | IDENTICAL (8 + 40 + 28 lines) |
| `add_building()` body, `_xf()` body (yaw source), public API signatures | IDENTICAL (38 + 45 lines) |
| `anim3d.gd`, `data.gd`, `game.gd`, `app/**`, all tests, config, assets | **Not edited** — `git status --short` shows no test file change by this ticket |

Only `_attach_rotor()` (hunk 3), the rotor comment block (hunk 2), the constants block
(hunk 1) and the rotor loop/stats (hunk 4) changed.

---

## 6. Gate list — to be run by **G04 only** (none run by M03)

Standing rule `WAVE_G_CHARTER.md:31,67-70`: only G04 submits runner jobs. M03 ran **no** Godot,
**no** runner and produced **no** capture. All rows are **NOT RUN / PENDING G04**.

| # | Gate | Expected / acceptance | Status |
|---|---|---|---|
| 1 | `t_mill_logic` (`mill_logic_test.gd`) | 6/6 (or current baseline); `game.gd` byte-identical so sim values unchanged | PENDING G04 — NOT RUN |
| 2 | variant selftest (`selftest.json`) | **29/29**, `passed=true`, `SCRIPT ERROR=0`; rotor presentation-only, no assertion/threshold changed | PENDING G04 — NOT RUN |
| 3 | uitest | **17/17** fresh (note P11 `P11_impl.md:271`: on-disk 17/17 is stale; G04 must re-run, not cite stale) | PENDING G04 — NOT RUN |
| 4 | `t_entities3d.gd` (`v734_entities3d`) | structural gate green: `api_surface`, `node_count_grows/shrinks`, `remove_below_baseline`, `no_sprite_sheet_loads`, `no_internal_errors`; peak=6 unchanged | PENDING G04 — NOT RUN |
| 5 | M04 atom (`t_mill_rotor_probe`, when authored) | **co-update first** per `M03_mill_fix_proposal.md` §7 (old hub `0.173,5.235,0`, billboard dot `>0.98`, facing `>0.95` now assert the wrong behaviour). After co-update: hub `(-0.176,5.626,+1.895)`, `p.z>1.5 && p.z<2.3`, `distance<=0.02`, fixed local-Z axis, `mill_yaw_rad==0`, `to_camera.z>0.8`. Do not weaken headless branch / `POS_TOL` / thresholds | PENDING — atom not authored; M03 did not touch it |

Additional gates from M03 §5 still required by G04: `t_render_mode` green, `assert_clean`
CLEAN, `t_mill_rotor` baseline, 2D `app/` + `game.gd` hash byte-identical, and a fresh windowed
P0 / real-map capture (the only honest evidence for the moved hub; do **not** reuse a pre-fix
frame). Read `stats["mill_rotor_hub_local_m"]` from the result to confirm
`[-0.176408, 5.626281, 1.894729]`.

**No threshold lowered, no assertion deleted, no `expected_pre_fix_failure` flipped.** The
`mill_rotor.png` `.ctex` debt stays OPEN.

---

## 7. UNVERIFIED / parity guard

- **UNVERIFIED:** rendered pixels, occlusion of the fixed sail from behind, whether
  `mill_rotor.png` binds or degrades to the white fallback. No capture exists and none was taken.
- **PORT APPROX:** the sail stand-in (2D bake on a quad, not the donor `.oss` lattice mesh) and
  the spin **sign**. Hub/axis **geometry** alone is DONOR-GROUNDED from the read-only
  `eurmilanim.oss` byte probe; no donor GPU A/B frame exists.
- **M04 co-update is outstanding** (`M03_mill_fix_proposal.md` §7) — a design task for the atom
  author, not a test weakening; M03-IMPL's grant is the source file only.
- No donor file was copied; no git operation beyond `git apply`/`git diff`/`git status` was made.

---

## 8. Scope statement

Only `variant3d/scripts/world3d_entities.gd` was edited; backup taken first and SHA-verified
against HEAD. One report written (`M03_impl.md`). No Godot process, runner job, capture, donor
file access, test/tool/config edit or other agent's file was touched. Other files showing as
modified in `git status` belong to other owners (P10, P12, C01ASSET, Y01) and were not touched
by this ticket. **M03-IMPL stays available for COORD follow-up.**

*End of M03 implementation report.*
