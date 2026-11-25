---
id: M03
ticket: "MILL WAVE M03 — ready-to-apply mill rotor fix proposal"
date: 2026-11-25
owner: M03 proposal subagent
status: PROPOSAL__READ_ONLY__NO_CODE_EDIT__NO_GODOT__NO_RUNNER_JOB__NO_BACKUP_TAKEN
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
owns:
  - "docs/terrain_swarm_2026-11-25/reports/M03_mill_fix_proposal.md"
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md + WAVE_G_CHARTER.md read first"
prereads:
  - "docs/terrain_swarm_2026-11-25/reports/M01_mill_rotor_audit.md (LANDED; folded in §2)"
  - "docs/terrain_swarm_2026-11-25/reports/M04_mill_qa.md (LANDED; must be co-updated, §7)"
  - "variant3d/scripts/world3d_entities.gd, anim3d.gd, data.gd"
  - "docs/coord_swarm_2026-11-24/reports/MILLFIX_rotor_fields.md, PLAY2_02_mill_fields.md"
scope: "One report only. No source/asset/test/config edit, no Godot process, no runner job, no git operation, no backup file created. COORD grants exclusive ownership of world3d_entities.gd only AFTER G04 finishes."
parity_guard: "Hub/axis GEOMETRY is donor-grounded by a read-only byte probe of the shipped donor mesh (§3). The SAIL VISUAL is still the 2D donor bake on a quad, spin SIGN and all pixels are PORT APPROX / UNVERIFIED; no donor GPU A/B frame exists."
---

# M03 — ready-to-apply mill rotor fix proposal

## 0. Status / boundary (read first)

- **Nothing was applied.** `variant3d/scripts/world3d_entities.gd` is byte-identical
  to the tree G04 is gating. No backup was taken (backups belong to the owner who
  actually applies the patch — instruction in §8). No `.gd` file, test, manifest,
  asset, config, result JSON or PNG was written. No Godot launch and no runner job
  (`WAVE_G_CHARTER.md:31` — only G04 submits jobs).
- The unified diff in §6 was **validated read-only** with `git apply --check` and a
  full `git apply` into a throwaway copy of the file under
  `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\m03_applycheck\` (all 4 hunks
  clean). The real source file was never touched.
- M01 landed during this ticket and is folded into §2. M02 did **not** land; its
  "donor truth" lane is answered here by a direct read-only probe of the shipped
  donor mesh (§3), which is stronger than the 2D proxies M01 had available.
- M04 landed as a **proposal** and currently asserts the **old** hub; it must be
  co-updated with this fix or it will go RED for the correct behaviour (§7).

---

## 1. Verdict

**OBSERVED:** the rotor child sits at local `(0.17296, 5.23533, 0)` m — X ≈ tower
centre, Y near the cap, **Z = 0 = exact mid-depth of the tower** — and the mill body
never receives yaw, while the only view-dependent code in the module is the rotor
billboard (`M01 §2.2/§2.4/§2.5`; source at `world3d_entities.gd:1774-1776, 1551-1593,
2159-2181`). `anim3d.gd` has **no** rotor path; all sail animation lives in
`world3d_entities.gd:sync()`.

**DONOR-GROUNDED (new, this ticket):** the shipped donor attach `eurmilanim.oss`
encodes the real axle. Its raw Z-up vertex bbox is
`x[-2.996233,2.996233] y[-1.897957,-1.040952] z[2.627196,8.619664] m` — a slab
thin in donor **Y**, i.e. disc plane = donor XZ, **spin axis = donor Y → Godot local
Z**. Disc centre donor `(0, -1.469455, 5.623430)`; **axle tip (front face) donor
`y = -1.897957`**. Because the attach is on donor **−Y**, and `_bake_mesh()`
(`:1079-1081`) maps donor `(x,y,z) → (x−cx, z−z0, −(y−cy))`, the axle lands on Godot
local **+Z** — **the default Camera3D side** (`camera3d.gd:262-282`).

**Fix (decisive, primary):**
1. Mount the sail at the **axle tip** local `(-0.1764, +5.6263, +1.8947)` m — not
   at Z=0, and not at the mid-depth. This clears the tower face at hub height
   (donor y≈−1.784 → local z≈+1.781) by ≈0.11 m.
2. **Drop the camera billboard**; keep a fixed axle (spin about local Z, pivot at
   the hub). From the default +Z view the sails are face-on; from behind, the
   tower occludes them. No camera-following sail swinging through the body.
3. **Do NOT rotate the whole mill.** The donor-grounded body yaw is **0 rad**: the
   donor front already maps to local/world +Z, which faces the default camera.
   M01 §2.4's suggested −90° yaw is rejected with the bake evidence in §4. `_xf()`
   stays byte-identical (it is shared with all units and buildings).
4. **Do NOT flip the spin axis** to `Vector3.BACK`. M01 D3 is right that
   `MOTION_ANIM_01.md:240`'s justification was wrong, but the shipped `FORWARD`
   code is correct; the donor slab proves the Z axis, and the 2D bake proves the
   screen-clockwise sign.

---

## 2. M01 findings folded in (agreement and one correction)

| M01 item | Folded into this proposal |
|---|---|
| M01 §2.2 / D1: hub Z=0 cuts the tower mid-depth; X≈centre; quad overhangs | Primary cause; fixed by hunk 3 (axle tip at local +Z 1.8947). Hunk 2 rewrites the stale "billboard plane through tower centre" comment. |
| M01 §2.4: mill body has yaw 0 forever; `_xf()` yaws only `class=="unit"`; `:1587-1588` invents none | Confirmed. We deliberately keep `_xf()` **byte-identical**; donor-grounded yaw for the mill is 0 (§4). |
| M01 §2.5: rotor billboard is the only view-dependent code | Displaced by hunk 4: fixed axle, no `get_viewport()`/`get_camera_3d()`/basis reconstruction. |
| M01 D3: do not revert `FORWARD`→`BACK` despite the bad rationale in `MOTION_ANIM_01.md:240` | Accepted. Spin axis local Z is now **donor-proven** (§3), sign stays a labelled PORT APPROX. Hunk 4 keeps `Basis().rotated(Vector3.FORWARD, rotor_spin)`. |
| M01 E11: `anim3d.gd` has no rotor logic | Accepted; this proposal edits **no** file other than `world3d_entities.gd`. Rotor animation remains entirely in `sync()`. |
| M01 §6 item 2: "give the body a donor-grounded yaw OR drop the billboard" | We do **both consistently**: drop the billboard and document the body yaw as donor-grounded 0. No rotation is applied. |
| M01 §2.4 / D2: "donor front points local/world +X (−90° yaw would align it)" | **Corrected here:** `bake_mill_rotor.py:8-12` says the donor **+X** view is where the rotor is **edge-on** — i.e. +X is the *side*, not the front. The attach mesh's donor −Y offset is front. The donor front maps to local +Z, already the camera side; a −90° yaw would move the axle to world +X (screen-right), i.e. **away** from the user. |
| M01 §5 item 2 / §6: no donor 3-D axle coordinate was read, so any hub is a PORT APPROX | Resolved by §3's read-only donor byte probe. The geometry is now **DONOR-GROUNDED**; only the sail stand-in, spin sign and pixels remain PORT APPROX / UNVERIFIED. |
| M01 E24: no mill capture on disk, no visual claim | Accepted. This proposal makes **no visual/PARITY claim**; M04's windowed atom (§7) is the gate. |

---

## 3. Donor byte evidence (OBSERVED — read-only, new in M03)

Read with the repo's own parser `variant3d/tools/convert_models.py:48-71,74-99`
(`read_mesh`) against the installed donor at `C:\Games\Cossacks 3`. **No donor file
was modified; no Godot was used.** Probe scripts lived in the approved temp folder
only.

| # | Source | Measurement | Kind |
|---|---|---|---|
| D1 | `data/actors/buildings/commoneur/attach/eurmilanim.oss` (55,388 B; header `k=251, fps=30, b=1, v=1098`) | raw Z-up vert bbox `x[-2.996233,2.996233]`, `y[-1.897957,-1.040952]`, `z[2.627196,8.619664]` m; slab thickness in Y = 0.857 m vs X/Z spans 5.992 m each | OBSERVED (bytes) |
| D2 | same | disc centre donor `(0.0, -1.469455, 5.623430)`; axle tip donor `y=-1.897957` (front face) | OBSERVED / derived (bbox centre & min) |
| D3 | `data/actors/buildings/commoneur/eurmil.osm` | tower bbox `x[-2.425524,2.778339] y[-2.400584,2.394128] z[-0.002851,5.914006]` m (agrees with `variant3d/assets/models/manifest.json:1209-1216`) | OBSERVED |
| D4 | `eurmil.osm` vert slice `z∈[5.3,5.9]` | tower surface at hub height reaches donor `y≈-1.784` → local `z≈+1.781`; the chosen axle tip local `z=+1.8947` is ≈0.11 m **outside** it | OBSERVED / derived |
| D5 | `eurmil.actor`, `attach/eurmilanim.actor` (read-only text) | `eurmilanim.oss` is the shipped rotor attach (`Animations.LoadFromFile = …/eurmilanim.aaf`); `eurmil.osm` is the finished tower mesh | OBSERVED |
| D6 | `variant3d/scripts/world3d_entities.gd:1053-1104`, `:1079-1081` | `local = ((x−cx)*s, (z−z0)*s, −(y−cy)*s)`, `s=1.0` for buildings | OBSERVED |
| D7 | `camera3d.gd:262-282` (`M01 E19`) | default camera at world +Z, pitch −32°, `look_at` toward −Z | OBSERVED |

**Derived local hub (arithmetic from D1–D3 through D6):**

```
cx = (−2.4255235 + 2.7783391)/2 = +0.1764078
cy = (−2.4005842 + 2.3941283)/2 = −0.0032279
z0 = −0.0028507

local X = 0.0        − cx  = −0.176408 m
local Y = 5.623430   − z0  = +5.626281 m
local Z = −(−1.897957 − cy) = +1.894729 m   ← axle TIP (front slab face)
   (disc centre would be +1.466227 m, i.e. ~0.32 m INSIDE the tower face at hub height)
```

The old 2D-derived hub `(0.173, 5.235, 0)` differs from the donor axle tip by
`ΔX ≈ −0.35 m`, `ΔY ≈ +0.39 m`, **`ΔZ ≈ +1.895 m`** — the last term is exactly the
"wrong side / in the middle" complaint.

**Why +Z needs no whole-mill yaw:** donor −Y maps to local +Z (D6); default camera
is at +Z (D7). `bake_mill_rotor.py:8-12` calls +X the *edge-on* view, so M01's
"front = +X" inference is a misreading of the bake-view comment. DONOR-GROUNDED
body yaw for this axle is therefore **0**.

**UNVERIFIED / PORT APPROX retained:** the rotor *visual* is still the 2D
`mill_rotor.png` bake on a quad (not the donor `.oss` sail mesh); spin **sign** is
derived from the 2D bake proxy, not from the AAF; no rendered frame or donor GPU
A/B exists. The `eurmilanim.oss` frame-0 bind pose is inferred from
`bake_mill_rotor.py:64-72`, not re-rendered here.

---

## 4. What is deliberately NOT changed (byte-identical)

The only file the diff touches is `variant3d/scripts/world3d_entities.gd`. Inside it,
these neighbours must stay **byte-identical** — the patch was written to avoid them:

| Region | Current lines | Why byte-identical |
|---|---|---|
| **Mine disc / band mask** | `:32`, `:123`, `:155-159`, `:183-185` (`MINE_DISC_STATUS`), `:273` (`FIELD_STATUS` neighbour), `:545-546`, `:573`, `:1583-1592`, `:2190-2270` field pass | Mine disc "no matching asset; donor disc is baked into the albedo; none invented" and field arrangement must not move. The sail fix is presentation-only and never reads `res`/mine state. |
| **Field arrangement (quad/ring around mill)** | `game.gd:2094-2095, 2098-2147` (`_sow_field_ring`), `game.gd:2210-2250` (field state API); `world3d_entities.gd:266-273` constants, `:949-960` `res\|field` batch setup, `:2190-2270` field visual pass | Sim is byte-identical across variants; no res mutation, no `res_dirty` bump, no field tint/scale change. The 7×7 ring and the `res\|field` MultiMesh stay untouched. |
| **Construction stages** | `:1785-1850` (`_build_progress01`, `_build_stage_suffix`, `_stage_mesh_info`), `:1851-1900` (`_sync_building_stages`), and the call at `:2148-2151` | BUILD-ART-C-01 stage/scaffold selector and its call site are **immediately adjacent** to hunk 4 but not edited. Hunk 4 starts at the MILLFIX comment on `:2153`. Don't reorder `_sync_building_stages()` vs the rotor pass. |
| **Ghost** | `world3d_fx.gd:269-288, 448-450, 518, 579-600…` (finished-stage ghost, B06/E04/G02); `world3d_entities.gd:1996` (the only "ghost" word — a `remove()` comment) | Ghost final-stage preview is owned by `world3d_fx.gd`; this patch does not import, call or alter it. Do not "fix" the ghost while here. |
| **Mill body mesh / tint / shadow** | `:1645-1682` (`add_building()` up to `mi.transform = _xf(id)`), `:1662` name `Building_<sid>_<id>_STATIC_POSE` | Parent stays the exact static donor mesh; only its child's local transform changes. |
| **Yaw source** | `:1551-1593` (`_xf()`), `:1587-1588` comment, `:1682`, `:2146` | Shared with all units/buildings; no yaw invented (M01 §2.4). Donor-grounded yaw for the mill is 0, so there is nothing to add here. |
| **Rotor spin rate / axis direction** | `:248` `MILL_SPIN = 0.75`, `:258-264` axis status, `:2158` clock, `Basis().rotated(Vector3.FORWARD, ...)` | M01 D3: do not flip to `BACK`. Axis is now donor-proven; sign is a labelled PORT APPROX. |
| **Rotor asset/import/fallback** | `:239-245` paths, `:1725-1762` `_rotor_material()` (`tex/` first, `Image.load()`, alpha scissor, white-quad fallback), `:491-498` stats | Import-cache fix from MOTION-ANIM-01 / ASSET_IMPORT_01 stays untouched. |
| **Public API** | `bind(game)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`, `add_resource(n)`, `remove(id)` | Six signatures unchanged; no new argument or return. |
| **`anim3d.gd`, `data.gd`, `app/**`, `game.gd`, tests, config** | whole files | M01 E11; sim hash gate; 2D `app/` gate. |

The diff adds **two stats keys and two node metas** (`hub_source`, `hub_local_m`,
`mill_rotor_mount_label`, `mill_rotor_hub_local_m`). These are *additive* only; no
existing key is renamed or removed, so G04/G05/M04 readers keep working.

---

## 5. Gate impact — what must stay green

COORD runs these; **M03 ran none**. The patch changes no threshold, no assertion, no
fixture and no sim value.

| Gate | Expected | Why this patch is safe |
|---|---|---|
| variant selftest | **29/29**, `passed:true` (`app/selftest.json`) | No sim/`game.gd`/`app/` change; rotor is presentation-only. Note the pre-existing open debt `mill_rotor.png` `.ctex` gap (`A10 §3`, `README.md:381`) must not be "fixed" by weakening. |
| uitest | **17/17** | No UI/input/selection code touched. |
| `t_render_mode` | green | `render_mode` untouched. |
| `assert_clean` | **CLEAN** | No new error/warning; new constants use literals only; no treated-as-error `INFERRED_DECLARATION` (`tower_ctr` is typed via `:=` from a `Vector3` expression, not a Variant-returning call). |
| `t_entities3d.gd:215-234` structural gate | green | No new `anim/` **string literal**; donor paths appear only in comments (as `eurmilanim.oss`, no slash form). Assembled legacy paths at `:239/:246` untouched. |
| `t_mill_logic` | **6/6** (or current baseline) | `game.gd` byte-identical. |
| `t_mill_rotor` | current baseline | 2D copied test; no rotor texture/path change. |
| 2D `app/` hash / shared `game.gd` hash | byte-identical | No file under `app/` or `game.gd` edited. |
| G04 windowed P0 + real-map captures | **must be re-run after the landing**, same protocol | Hub/axis change is visual; a fresh capture is the only honest evidence. Do not reuse the pre-fix frame as "after". |
| `t_mill_rotor_probe` (M04, if adopted) | **co-update first, then green** | Its current checks 7/8/9 assert the OLD hub and billboard axis; see §7. |

**No threshold is lowered, no assertion deleted, no `expected_pre_fix_failure`
flipped.** The `mill_rotor.png` `.ctex` debt stays OPEN.

---

## 6. The patch — unified diff (ready to apply; 4 hunks)

Verified with `git apply --check` + a full `git apply` into a temp copy: all four
hunks clean. New-start line numbers in the `+` column assume no other edits land in
this file first (COORD grants ownership after G04).

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -262,6 +262,22 @@
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
@@ -1689,8 +1705,11 @@
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
@@ -1772,9 +1791,17 @@
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
@@ -2153,36 +2180,33 @@
 	# MILLFIX F1: spin the donor-baked sail from the SAME `_anim_t` clock that
 	# drives the donor morph pass (no second timer, no RNG). Billboarding uses
 	# the node basis rather than material BILLBOARD so the readable local Z
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

### 6.1 Expected post-patch values (DERIVED — for the acceptor)

| Quantity | Before | After | Gate |
|---|---|---|---|
| `rotor.position` (local on mill body) | `(0.17296, 5.23533, 0)` | `(-0.176408, 5.626281, +1.894729)` | ±0.02 m |
| Local Z vs tower mid-depth | `0` (mid-depth) | **+1.895 m, outside the tower face at hub height (~+1.781)** | `p.z > 1.5` and `p.z < 2.3` |
| `MILL_SPIN` / axis | `0.75` / local Z (`FORWARD`) | unchanged | exact |
| Body yaw | `0` (shared `_xf()`) | `0` (donor-grounded, unchanged) | exact |
| Camera basis in `sync()` | `face * spin` | **removed** — pure `Basis().rotated(FORWARD, spin)` | grep: no `get_camera_3d` in rotor block |
| `stats["mill_rotor_hub_local_m"]` | absent | `[-0.176408, 5.626281, 1.894729]` | new key present |
| Sails from behind | billboard always face-on | tower occludes the fixed sail | windowed capture (M04/G04) |

---

## 7. M04 must be co-updated (otherwise correct code goes RED)

M04 is a **proposal, not a landed gate**, so correcting it pre-landing is design
work, **not test weakening**. Its atom currently asserts the old geometry at
`:101`, `:107`, `:431-474`, `:590-596`, `:819-826`, `:907-910`. Before the atom is
authored, a later owner must change:

| M04 location | Current expectation | Required after M03 |
|---|---|---|
| §3 `:101-108`, `POS_TOL` `:172` | hub `(0.173,5.235,0)`, `abs(p.z) <= 0.01` | hub `(-0.176,5.626,+1.895)`, assert `p.z > 1.5 && p.z < 2.3`, `p.distance_to(want) <= 0.02`, `|off|>4` retained |
| §4 `_assert_static` `:431-443` | recompute old `hx/hy`, want `(hx,hy,0)` | read `Ent.MILL_ROTOR_HUB_DONOR`, `Ent.MILL_TOWER_BBOX_LO/HI`, `Ent.MILL_ROTOR_AXLE_TIP_DONOR_Y`; compute the same three components as the patch; **add** a new check `rotor_is_donor_axle_tip` |
| §4 `:452-463` `rotor_spin_axis_correct` | local +Z·to-camera > 0.98 (billboard) | fixed axle: assert `b.z ≈ Vector3(0,0,1)` (local), keep `spin_rad_per_s = 0.75`, and assert relative frame0→N rotation pure about local Z; **do not** reuse the billboard-dot predicate |
| §4 `:465-474` `mill_yaw_puts_sails_toward_camera` | `facing > 0.95` (billboard guaranteed this) | with a fixed axle and −32° camera pitch, `z·to_cam ≈ 0.87`, so **0.95 would fail**. Assert `mill_yaw_rad == 0`, `rotor.global_transform.basis.z ≈ (0,0,1)` and `to_camera.z > 0.8` (re-derived from `camera3d.gd:262-282`, not a lowered arbitrary threshold); record the old 0.95 as billboard-era |
| §4 `constants` `:589-596`, `frames.json` sample `:807-815` | old 2D constants only | add the four new `MILL_*` constants + `hub_source` meta; label geometry DONOR-GROUNDED, visual PORT APPROX |
| §8 criterion 7/8/9 `:907-910` | old values | update wording to the new hub/axis; keep all 14 criteria and the headless `SKIP_CAPTURE` guard |

Do **not** weaken the headless branch, the symmetry guard, `POS_TOL`, the pixel
diff threshold or the one-write result guard. If M04 is adopted unchanged, its
check 7/8/9 will correctly go RED — the fix, not the threshold, is wrong there.

---

## 8. Apply procedure (for COORD, after G04 + ownership grant)

1. **Wait** for G04's gates to finish and for COORD's explicit exclusive ownership
   of `variant3d/scripts/world3d_entities.gd` (this file is contested with P11 —
   `WAVE_G_CHARTER.md:102-104`). **M03 applied nothing.**
2. **Backup first** (charter §66 / Wave G/P rule at `WAVE_G_CHARTER.md:87` style):
   ```
   Copy-Item "variant3d\scripts\world3d_entities.gd" "inbox\backup\world3d_entities.gd.bak-M03"
   ```
   Verify the backup exists and is non-empty before editing.
3. **Apply** the §6 diff with `git apply m03.patch` (or paste the hunks). The patch
   is already verified against the current tree.
4. **Do not** also apply P11's draw-call hunks to the same lines in the same pass;
   COORD serialises the two owners. Re-check line numbers if P11 landed first.
5. **Co-update M04's proposed atom** per §7 **before** authoring it.
6. **Re-run gates** from §5 under the sole-runner rule (G04). First structural
   smoke, then windowed P0 / real-map capture; read `stats["mill_rotor_hub_local_m"]`
   from the result to confirm `[-0.176, 5.626, 1.895]`.
7. **If a capture shows sail/tower clipping**, the only donor-grounded tuning knob
   is the axle-tip donor Y (`: -1.897957`); a fallback to the slab centre
   (`-1.469455` → local `z=+1.466`) must be labelled **PORT APPROX (occlusion
   trade-off)**, not donor parity. Any other artistic offset must carry an explicit
   `PORT APPROX` label per charter §130.

---

## 9. Observed / derived / inferred / UNVERIFIED ledger

- **OBSERVED:** `M01_mill_rotor_audit.md` in full; `M04_mill_qa.md` in full;
  `world3d_entities.gd:225-273, 1053-1112, 1551-1593, 1645-1686, 1689-1782,
  1785-1900, 1996, 2019, 2148-2188, 2190-2270`; `camera3d.gd:262-282`;
  `bake_mill_rotor.py:1-93`; `bake_sprites.py:226-245`; `convert_models.py:48-99`;
  `manifest.json:1202-1218`; `buildings.json:578-589`; donor `.oss`/`.osm`/`.actor`
  bytes and text (§3); `MILLFIX_rotor_fields.md`, `PLAY2_02_mill_fields.md`,
  `MOTION_ANIM_01` excerpts quoted in M01.
- **DERIVED:** local hub `(-0.176408, 5.626281, +1.894729)`; tower face at hub
  height ≈ +1.781; ΔZ ≈ 1.895 m from the old hub; `anim3d.gd` has no rotor path;
  `git apply --check` + full apply clean in a temp copy; M04's 0.95 facing check
  would fail under a fixed axle at −32° pitch.
- **INFERRED:** the donor attach slab's −Y offset is the sail's front face; the
  M03 hub is the "appropriate tip" the owner described; no whole-mill yaw is
  needed because the donor axle already faces the default camera.
- **UNVERIFIED / PORT APPROX:** rendered pixels; donor `.oss` spin **sign**;
  whether `mill_rotor.png` binds or degrades to the white fallback; the 2D
  bake-on-quad stand-in vs the true lattice sail; live-camera occlusion from
  behind; all donor parity. No Godot was run and no capture exists.
- **NOT DONE by M03:** no code/asset/test/config edit, no backup, no runner job,
  no Godot process, no git operation, no PNG or result JSON.

*End of M03 report.*
