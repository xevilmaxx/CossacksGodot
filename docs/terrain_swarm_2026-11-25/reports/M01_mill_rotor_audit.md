---
id: M01
ticket: MILL WAVE M01
title: "M01 — end-to-end audit of the current 3D mill rotor (placement, pivot, axis, orientation, view logic)"
date: 2026-11-25
owner: M01 read-only audit subagent
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_EDITS
owns:
  - "docs/terrain_swarm_2026-11-25/reports/M01_mill_rotor_audit.md"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
scope: "READ ONLY. No Godot run, no runner job, no code/asset/test/config edit. One report only."
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md + WAVE_G_CHARTER.md read first"
owner_report: "'mill rotor seems maybe on wrong side of the mill or in the middle of it; needs to be positioned on an appropriate tip, and maybe facing the direction of the user view so not viewed from behind. Maybe you even need to rotate the whole mill.'"
---

# M01 — mill rotor end-to-end audit

## 0. Verdict in one paragraph

**OBSERVED:** the rotor is a 6.352 m billboard quad attached as a child of the mill
body `MeshInstance3D` at local `(0.17296, 5.23533, 0) m`
(`variant3d/scripts/world3d_entities.gd:1765-1782`); the mill body itself never
receives yaw (`_xf():1551-1593` only applies face-derived yaw to `class=="unit"`);
and the only view-dependent logic in the whole module is the rotor billboard in
`sync()` (`:2159-2181`), which points the sail's local +Z at the camera.
**DERIVED:** the hub's local Z=0 puts the sail plane through the **mid-depth of the
tower**, not on an outward axle tip, and local X=+0.173 m is essentially the
**horizontal centre** of the 5.204 m-wide mesh; the hub was derived from 2D
sprite-cell constants, not from any 3D axle vertex. **INFERRED:** this is the code
cause of "in the middle of it"; the fixed-yaw tower plus a camera-following sail
explains "wrong side / viewed from behind". **UNVERIFIED:** the actual pixels —
no mill capture exists on disk, and this ticket ran no Godot, so no visual claim
is made. `anim3d.gd` contains **no** mill/rotor logic at all; rotor animation is
entirely in `world3d_entities.gd:sync()`.

---

## 1. Evidence inventory (all read-only; current tree)

| # | Source | Fact | Label |
|---|---|---|---|
| E1 | `variant3d/scripts/world3d_entities.gd:239-252` | `ROTOR_TEX_PATH`, `ROTOR_TEX_IMPORT_PATH`, `ROTOR_META_PATH`; `MILL_HUB=(0.525,0.21)`, `MILL_SPIN=0.75`, `MILL_ROTOR_ORTHO=6.352`, `MILL_TOWER_ORTHO=6.627`, `MILL_TOWER_CX=0.4989`, `MILL_TOWER_FOOT=1.0` | OBSERVED |
| E2 | `world3d_entities.gd:1685-1686` | `if sid == "mil": _attach_rotor(id, mi)` inside `add_building()` | OBSERVED |
| E3 | `world3d_entities.gd:1689-1696` | Hub derivation comment: `local X=(0.525−0.4989)*ortho`, `local Y=(1.0−0.21)*ortho`, `local Z=0`, "billboard plane through tower centre", quad span = full 6.352 m cell | OBSERVED |
| E4 | `world3d_entities.gd:1697-1722` | `_rotor_mesh()`: flat XY quad, 4 verts all `z=0`, half=3.176 m; UVs map image (0,0) to local top-left; normals `Vector3.BACK` | OBSERVED |
| E5 | `world3d_entities.gd:1725-1762` | `_rotor_material()`: `tex/` copy first, original anim/ PNG second, `Image.load()` decode, alpha-scissor 0.5, `CULL_DISABLED`, `UNSHADED`, white-quad fallback | OBSERVED |
| E6 | `world3d_entities.gd:1765-1782` | `_attach_rotor()`: `hx=(MILL_HUB.x−MILL_TOWER_CX)*MILL_TOWER_ORTHO`, `hy=(MILL_TOWER_FOOT−MILL_HUB.y)*MILL_TOWER_ORTHO`, `rotor.position=Vector3(hx,hy,0)`, `parent.add_child(rotor)` | OBSERVED |
| E7 | `world3d_entities.gd:1551-1593` | `_xf()`: yaw stays 0 for everything except a `_slot` entry whose `class=="unit"`; `:1587-1588` explicitly "Resource yaw is intentionally left at 0: no rotation is invented" | OBSERVED |
| E8 | `world3d_entities.gd:2143-2146`, `:1682` | Buildings' transform is `mi.transform = _xf(id)`; no separate building orientation path | OBSERVED |
| E9 | `world3d_entities.gd:2153-2183` | `rotor_spin = _anim_t * MILL_SPIN`; camera from `get_viewport().get_camera_3d()`; `d=cam.global_position−rotor.global_position`; `rx=UP.cross(d)`, `ry=d.cross(rx)`, `face=Basis(rx,ry,d)`; `rotor.transform = Transform3D(face * Basis().rotated(Vector3.FORWARD, rotor_spin), rotor.position)`; `rotor.visible = e.finished` | OBSERVED |
| E10 | `world3d_entities.gd:2159-2176` (sole hits for `get_viewport/get_camera_3d/global_position` in the file) | The rotor billboard is the **only** view-dependent logic in this module | OBSERVED |
| E11 | `variant3d/scripts/anim3d.gd` (full function/keyword grep: no `mill`/`rotor` match) | anim3d.gd is a generic donor morph pose sampler (`pose_for`, `skin_vertices`, `sample_frames`, ...); it has **no** mill-specific or rotor animation/pose code | OBSERVED |
| E12 | `variant3d/scripts/data.gd:1303-1331`, esp. `:1330` | Mill sim data: sid `mil`, `radius=2.0`, cost/hp/build_time; **no** mesh offset/orientation field | OBSERVED |
| E13 | `variant3d/scripts/world.gd:3078-3079` | 2D-only `_bld_height("mil") = 6.5 m` (not used by the 3D body mesh) | OBSERVED |
| E14 | `variant3d/assets/models/manifest.json:1202-1218` | `mil` donor mesh `eurmil.osm`; bbox x `[-2.4255,2.7783]`, y `[-2.4006,2.3941]`, z `[-0.00285,5.91401]`; height 5.91686 m | OBSERVED |
| E15 | `variant3d/scripts/world3d_entities.gd:1053-1104` | `_bake_mesh()` maps donor `(x,y,z) -> ((x−cx)*s, (z−z0)*s, −(y−cy)*s)`; local Y=0 is mesh bottom, X and Z are bbox-centred | OBSERVED |
| E16 | `variant3d/assets/models/anim/buildings/buildings.json:578-589`; `mill_rotor.json:1-5` | `ukr_mil`: ortho 6.627, cell 320, `ink=[44,18,277,320]`, `cx=0.4989` → `foot=ink[3]/cell=1.0`; rotor `cell=320, ortho=6.352`, "face-on 4-blade sail rotor" | OBSERVED |
| E17 | `app/scripts/world.gd:199-208`, `:640-654`, `:2892-2895` | Donor/2D: `hub = tl + sz*MILL_HUB`, `tl = p − sz*(cx,foot)`, `draw_set_transform(hub, anim_t*0.75, ONE)`, full-cell rect; drawn only when `e.finished` | OBSERVED |
| E18 | `variant3d/tools/bake_mill_rotor.py:8-12`, `:64-79` | Tower sheet baked from donor **+X** view (rotor edge-on); rotor bake rendered from donor **+Y** view (blades face-on) | OBSERVED |
| E19 | `variant3d/scripts/camera3d.gd:262-282`; `data.gd:196` | Camera pitch −32°, sits at `base + (0,h,back)` with `back>0`, `look_at(base)` → default view is from world **+Z**, looking toward −Z; "Yaw 0 = look toward −Z" | OBSERVED |
| E20 | Godot 4.7 `Vector3` docs (`docs.godotengine.org/en/stable/classes/class_vector3.html`) | `Vector3.FORWARD=(0,0,−1)`, `Vector3.BACK=(0,0,1)`, `Vector3.UP=(0,1,0)`; `cross()` is right-handed | OBSERVED (engine constant) |
| E21 | `docs/coord_swarm_2026-11-25/reports/MOTION_ANIM_01.md:224-240`, `:289-305` | Prior fix: `ResourceLoader.load()` removed, `Image.load()` + white fallback; spin axis `BACK -> FORWARD`; speed/pivot audited unchanged; donor 3-D spin UNVERIFIED | OBSERVED (report) |
| E22 | `docs/coord_swarm_2026-11-25/reports/ASSET_IMPORT_01.md:90-100`, `:123-141` | Original `.ctex` absent because `assets/models/anim/.gdignore` excludes the tree; target ctex never produced by job 444 | OBSERVED (report) |
| E23 | `docs/coord_swarm_2026-11-24/reports/MILLFIX_rotor_fields.md:47-48`, `:81-88`, `:103-110` | Original derivation hub `(0.17296,5.23533,0)`, "mesh height 5.917 m → tower cap"; probe measured angle/span/hub only; live-camera billboard **derived, not measured** | OBSERVED (report) |
| E24 | `app/shots/mill_rotor_check.png` — only `.import` exists; no PNG on disk; no other mill capture found | No visual evidence of the current mill | OBSERVED (absence) |

---

## 2. Requested file:line answers

### 2.1 Where the rotor mesh is attached
- `world3d_entities.gd:1685-1686` — inside `add_building()`, only when resolved `sid == "mil"`.
- `world3d_entities.gd:1768-1782` — `_attach_rotor()` creates `MeshInstance3D "MillRotor_<id>"`, assigns `_rotor_mesh()` and the `_rotor_material()` override, then `parent.add_child(rotor)` at `:1781`.
- Parent is the exact static donor mill body `Building_mil_<id>_STATIC_POSE` created at `:1661-1681` (`mi.mesh = info["mesh"]`, `:1663`). The body mesh came from `mil.obj`/`mil.glb` via `_mesh_info()` at `:1110-1160` and `_bake_mesh()` at `:1053-1104`.

### 2.2 Local position relative to the mill body mesh
- `world3d_entities.gd:1774-1776`: `hx=(0.525−0.4989)*6.627`; `hy=(1.0−0.21)*6.627`; `rotor.position = Vector3(hx, hy, 0.0)`.
- **DERIVED numbers:** `hx = +0.17296 m`, `hy = +5.23533 m`, `hz = 0.0 m` — matches E23's measured probe value exactly.
- Relative to the baked mesh bbox (E14/E15): local X half-span ≈ **2.602 m**, so `hx=+0.173 m` is within 6.7 % of the tower centre; local Y span **0…5.9169 m**, so `hy` is **88.5 %** of mesh height (near the cap); local Z half-span ≈ **2.397 m**, so `hz=0` is the **exact middle of the tower's depth**.
- The quad (E4) is centred on that hub and spans 6.352 m in local X and Y → local X extent ≈ `[−3.003, +3.349] m`, i.e. it overhangs the 2.602 m tower half-width on both sides and its plane cuts through the tower volume at Z=0.

### 2.3 Rotation axis / pivot
- Pivot = the quad centre at `rotor.position` (`:1776`); the child transform's origin is that local point (`:2180-2181` uses `rotor.position` as translation, so the spin is about the hub, not the mesh origin). **OBSERVED.**
- Spin rate `_anim_t * 0.75` (`world3d_entities.gd:2158`, constant `:248`) — unchanged donor number. **OBSERVED.**
- Axis: `Basis().rotated(Vector3.FORWARD, rotor_spin)` at `:2181`. With E20, `FORWARD=(0,0,−1)`, so this is a **negative-Z** rotation; under the billboard basis (camera at +Z → basis ≈ identity, local +X→screen-right, local +Y→screen-up) it is **screen-clockwise**, matching the donor 2D `draw_set_transform` positive angle (E17). **DERIVED.** The spin direction is a **PORT APPROX** vs the 2D bake proxy; donor `.oss` 3-D direction stays **UNVERIFIED** (E21).
- Quad vertex normals are `Vector3.BACK = +Z` (`:1710`), consistent with the +Z geometric winding (`:1711-1713`) and with MILLFIX's "+Z normal" note (E23); `CULL_DISABLED` + `UNSHADED` (`:1759-1761`) means both faces render identically. **OBSERVED + DERIVED.**

### 2.4 Does the mill body have a yaw/orientation?
- **No.** `_xf()` (`:1557`) initializes `yaw = 0.0`; it only assigns `yaw = PI/2 − face` when `_slot[id].class == "unit"` (`:1558-1582`). Buildings live in `_nodes` (`:1681`), not `_slot`, and `add_building()` never writes a face/yaw (`:1645-1686`). The comment at `:1587-1588` is explicit: no authored per-object rotation reaches this module; none is invented. The building transform is applied at `:1682` and refreshed at `:2146` with that same zero-yaw `_xf()`. **OBSERVED.**
- Consequence: the mill's donor front (baked from donor +X per E18; donor +X → local +X via E15) points world +X, i.e. **screen-right** under the default camera (E19), while the sail billboard points at the camera (+Z). **DERIVED.**

### 2.5 View-dependent logic
- **Only** `world3d_entities.gd:2159-2181`: `get_viewport().get_camera_3d()`, `d = cam.global_position − rotor.global_position`, `rx = UP.cross(d)`, `ry = d.cross(rx)`, `face = Basis(rx, ry, d)` ("local +Z faces the camera", `:2176`), then composed with the spin. With no camera, `face = Basis()` (identity, `:2168`). Guard `absf(d.dot(UP)) < 0.999` at `:2173` prevents degeneracy looking straight down. **OBSERVED.**
- `rotor.visible = e.finished` (`:2183`) — state-dependent, not view-dependent. **OBSERVED.**
- Nothing in `anim3d.gd`, `data.gd`, or the mill body transform reads the camera. **OBSERVED.**

---

## 3. Defect analysis against the owner's words

### D1 — "in the middle of it" / "on the wrong side": hub is derived from a 2D sprite anchor and lands on the tower's centre plane

**OBSERVED:** E3/E6 derive the hub from `MILL_HUB` (a *2D* axle-centre fraction inside the tower sprite cell, `app/scripts/world.gd:203`) combined with `buildings.json` cell constants `cx`/`foot` and the *2D* tower ortho (`6.627`). It never consults the 3-D mesh (`mil.obj` bbox E14), a bone, or an axle vertex. The resulting local Z is hard-coded `0.0` (`:1776`).

**DERIVED:** after `_bake_mesh()` bbox-centring (E15), local Z=0 is the mid-depth of the 4.795 m-deep tower (half-depth ≈2.397 m). The authored sail plane therefore passes **through the tower**, not out to the axle tip on a face. Because the quad is camera-billboarded around that same hub, the inner half of every blade is inside/behind the tower silhouette; the visible blades read as growing out of the tower's middle. Local X=+0.173 m ≈ mesh centre (half-width 2.602 m), so the hub is not on any lateral "tip" either. The 6.352 m square (full bake cell) is ~1.22× the tower's X width, so blades overhang the roof on both sides.

**INFERRED (high confidence):** this is the primary code-level explanation of "in the middle of it" and "needs to be positioned on an appropriate tip". A correct port placement would put the hub at the 3-D axle tip — offset along the tower's face normal (local ±Z, roughly the 2.397 m half-depth or the measured axle length) and at the axle's actual height — instead of at `(0.173, 5.235, 0)`. No donor 3-D axle coordinate is currently read, so any new number would be a **PORT APPROX** unless a donor vertex/bone is cited.

**UNVERIFIED:** pixel appearance; no capture exists (E24), no Godot run performed.

### D2 — "facing the direction of the user view so not viewed from behind": the sail faces the camera but the mill never does

**OBSERVED:** E9/E10 — the sail billboard follows the camera; E7/E8 — the tower has yaw 0 and never follows anything. E19 — the default camera is at world +Z looking −Z, while the tower's donor front points local/world +X (E15/E18). E18 — the sail bake itself is rendered from donor +Y, which maps to local −Z (E15), i.e. the *opposite* side from the billboard's +Z front.

**DERIVED:** the composite is internally inconsistent: from the default view the tower shows its donor +Y **side** (not its authored front), while the sail shows its face-on +Y-donor bake turned to face the camera. The user sees a "face-on rotor on the side/back of a tower whose front is elsewhere" — exactly the "wrong side / viewed from behind" impression. Because camera yaw is fixed at 0 in this port (E19), the mismatch is stable at the default view; if the camera were ever rotated, the sail would follow but the tower would not, making the mismatch worse.

**INFERRED:** rotating the whole mill so its authored front (local +X) faces the user view (world +Z) — a yaw of −90° under `_xf`'s `Basis().rotated(Vector3.UP, yaw)` convention — would align the tower with the billboarded sail; alternatively, stop billboarding and mount the sail rigidly on the tower's real axle face. Which is donor-correct is **UNVERIFIED**: the donor is a 2-D isometric sprite compositor (E17/E18), not a 3-D camera-facing rig, so "rotate the whole mill" is a presentation choice, not a donor-cited rule.

**UNVERIFIED:** the visual result of any such rotation; donor 3-D `.oss` sail-front convention was not read.

### D3 — prior-report wording discrepancy on the spin axis (no code defect found)

**OBSERVED:** `MOTION_ANIM_01.md:240` justifies `BACK -> FORWARD` by stating "the billboard basis maps local +X to screen-left" and calling BACK "−local Z". E20 says `BACK=(0,0,+1)`, and the billboard with camera at +Z gives local +X → screen-right (E19/E9). Both premises in that sentence are wrong.

**DERIVED:** despite the wrong justification, the *change itself* is consistent with the donor 2-D proxy: current `FORWARD=(0,0,−1)` → screen-CW, matching `draw_set_transform` positive angle (E17). So the shipped axis is **not** a new defect; only the report's reasoning is unreliable. Flagged so a future fixer does not "correct" the axis back to BACK based on that sentence. Donor 3-D spin direction remains **UNVERIFIED**.

### D4 — latent fragility (not a current defect)

**OBSERVED:** the rotor attaches only when the resolved mesh sid is exactly `"mil"` (`:1685`). `_entity_mesh_sid()`'s building branch (`:776-788`) probes a nation-prefixed candidate (`ukrmil`, etc.). No such 3-D OBJ exists today, so `sid` falls back to `"mil"`. **INFERRED:** if a nation-specific mill OBJ were added later, the mill would silently lose its rotor. **UNVERIFIED** as a live symptom.

### D5 — asset/import history is not the placement defect

**OBSERVED:** E21/E22/E23 — the earlier hard engine `ERROR:` lines were the `.ctex` import-cache problem (`.gdignore` tree), fixed by the `tex/` port copy + `Image.load()` fallback; speed and pivot were audited and left unchanged (E21). **DERIVED:** those tickets established the rotor *exists and spins*, but explicitly never validated the live-camera placement (MILLFIX E23 §4 "billboard in a live camera is derived, not measured"). The current owner complaint is therefore a **placement/orientation** defect, not a recurrence of the import error.

---

## 4. Numeric summary (DERIVED from E1/E6/E14/E15)

| Quantity | Value | Note |
|---|---|---|
| Hub local X | +0.17296 m | ≈ tower mesh centre (half-width 2.602 m) |
| Hub local Y | +5.23533 m | 88.5 % of 5.91686 m mesh height (near cap) |
| Hub local Z | 0.0 m | exact mid-depth (half-depth ≈2.397 m) |
| Quad span | 6.352 × 6.352 m | full rotor bake cell; X extent ≈ [−3.003, +3.349] m |
| Quad plane | local XY, all verts z=0 | billboard basis later maps local +Z to camera |
| Spin | 0.75 rad/s about local FORWARD (0,0,−1) | screen-CW under default camera; PORT APPROX |
| Mill body yaw | 0 rad, always | no orientation source for buildings |
| Camera default | +Z, pitch −32°, look toward −Z | `camera3d.gd:262-282` |

---

## 5. UNVERIFIED / open register

1. **No visual evidence.** `app/shots/mill_rotor_check.png` is absent (only `.import`), no other mill capture was found, and this ticket ran **no** Godot. Every "looks like" statement above is a code-path derivation, not a measured pixel. (E24)
2. **Donor 3-D truth UNVERIFIED.** No donor `.oss` axle vertex/bone or donor 3-D camera convention was read; the correct hub offset, sail-front normal, and whether the whole mill should be rotated are presentation decisions unless a donor citation is produced.
3. **Live-camera billboard UNVERIFIED.** MILLFIX's 20/20 probe used no `Camera3D` (E23 §4); the camera-facing path at `:2169-2176` has never been measured in a rendered frame.
4. **White-quad fallback UNVERIFIED visually.** The import path is real (E21/E22), but whether the current live frame binds the donor PNG or the fallback is unknown without a run.
5. **Nation-prefixed mill mesh** would drop the rotor (D4) — latent, unverified as a live symptom.
6. **2-D "squash in X" not implemented.** `mill_rotor.json:4` and `bake_mill_rotor.py:11-12` say the face-on bake is squashed in X to project into the tower view; both `app/scripts/world.gd:652` (`Vector2.ONE`) and the 3-D billboard draw an un-squashed full cell. Its visual impact is UNVERIFIED; noted for completeness, not asserted as the owner's defect.

---

## 6. Recommendations (proposal only — no edits made)

All are **PORT APPROX until donor-cited**. Ordered by how directly they answer the owner:

1. Replace the 2-D-derived hub (`world3d_entities.gd:1774-1776`) with a hub placed at the mill mesh's **actual axle tip** — read from a named vertex/bone of the `mil` donor mesh or, minimally, offset along the tower face normal from Z=0 — and keep the spin pivot on that hub (`:2180-2181`). Do not reuse `(0.173, 5.235, 0)` blindly.
2. Resolve orientation: either give buildings a documented yaw so the mill front faces the default view (`:1557-1582`, `:1682`, `:2146`), or make the sail rigid on the tower face and drop the camera billboard (`:2168-2181`). Pick one; do not leave a camera-facing sail on a fixed-yaw tower.
3. Do **not** flip the spin axis back to `Vector3.BACK` on the strength of `MOTION_ANIM_01.md:240` (D3).
4. Obtain one fixed-camera mill capture (front, side, back) before and after any change; this audit deliberately supplies none.

---

## 7. Scope statement

No code, asset, config, test, document other than this report, or git state was edited. No runner job, Godot launch, or capture was submitted (WAVE_G_CHARTER.md:31 — only G04 runs jobs). All numbers were computed from the cited files with read-only tooling. Separate observations from inferences and unverified items per CHARTER.md:55-69.

*End of M01 report.*
