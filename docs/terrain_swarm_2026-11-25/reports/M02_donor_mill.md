---
id: TERRAIN-SWARM-WAVE-G / M02
ticket: "MILL WAVE M02 — donor truth: mill/windmill geometry and orientation"
owner: M02 (read-only subagent)
created: 2026-11-25
output: docs/terrain_swarm_2026-11-25/reports/M02_donor_mill.md
guardrails: "WAVE_G_CHARTER.md §Wave M (M01-M04), CHARTER.md §3. READ-ONLY. One report written. No runner, no Godot, no code/asset/test/scene/git edit. No donor file copied. Donor data at C:\\Games\\Cossacks 3\\data opened read-only."
labels: [OBSERVED, DERIVED, UNVERIFIED]
---

# M02 — Donor truth: mill body, rotor, attach point, axis, yaw, camera/wind, rotation

## 0. Scope and method

Answers the six M02 questions from the Wave M directive (`WAVE_G_CHARTER.md:89-104`).
Evidence is (a) local donor files read in place under `C:\Games\Cossacks 3\data`,
(b) the donor binary `.oss`/`.osm` meshes decoded **in memory only** with the port's
existing read-only parser (`app/tools/bake_sprites.py:91-103,551-560`), and (c) online
sources. Every claim carries a path:line or URL and a label. Where the donor exposes
no text field, the claim is UNVERIFIED rather than guessed.

Terminology: **OBSERVED** = read directly from a named donor file/URL, or decoded from
donor bytes by the cited read-only parser; **DERIVED** = arithmetic/inference from
observed donor data (labelled, not a donor assertion); **UNVERIFIED** = no readable
donor citation found this pass.

---

## 1. Donor file inventory (OBSERVED — directory enumeration)

Three culture families ship a mill. Each has the same six-slot layout:

| Family | Body actor / body `.osm` | Build stages | Scaffold attach | Rotor attach | Rotor anim |
|---|---|---|---|---|---|
| European | `data/actors/buildings/commoneur/eurmil.actor`, `eurmil.osm` | `eurmil1..4.osm`, `eurmil_death1/2.osm` | `attach/eurmila.actor` → `eurmila.osm`, `eurmil1a..4a.osm` | `attach/eurmilanim.actor` → `eurmilanim.oss` | `attach/eurmilanim.aaf` |
| Russian | `data/actors/buildings/commonrus/rusmil.actor`, `rusmil.osm` | `rusmil1..4.osm`, `rusmil_death1/2.osm` | `attach/rusmila.actor` → `rusmila.osm`, `rusmil1a..4a.osm` | `attach/rusmilanim.actor` → `rusmilanim.oss` | `attach/rusmilanim.aaf` |
| Turkish | `data/actors/buildings/commontur/turmil.actor`, `turmil.osm` | `turmil1..4.osm`, `turmil_death1/2.osm` | `attach/turmila.actor` → `turmila.osm`, `turmil1a..4a.osm` | **none** | **none** |

Evidence:
- `eurmil.actor:2-3` binds `eurmil.mesh` to `eurmil.osm`; `:5-18` binds four build stages;
  `:21-26` binds two death stages. Same pattern in `rusmil.actor`, `turmil.actor`.
- `eurmila.actor:3-4` binds the scaffold `eurmila.mesh`; `:7-28` binds stage scaffolds.
- `eurmilanim.actor:2` loads `.\data\animations\aaf\eurmilanim.aaf`; `:5-6` binds
  `eurmilanim.mesh` to `.\data\actors\buildings\commoneur\attach\eurmilanim.oss`.
- `rusmilanim.actor:4` loads `rusmilanim.aaf` (same 4-line pattern).
- `data/animations/aaf/` contains **only** `eurmilanim.aaf` and `rusmilanim.aaf` for mills;
  `commontur/attach/` contains no `turmilanim.*` (directory enumeration).
- `.prop` twins: `data/objects/buildings/eurmil.prop`, `rusmil.prop`, `turmil.prop`;
  `data/objects/buildings/attach/{eurmila,eurmilanim,rusmila,rusmilanim,turmila}.prop`.

## 2. Which `.osm` is the body, which is the rotor/sails

**Body** = the base `<sid>.osm` (finished tower) and `<sid>1..4.osm` (construction stages),
loaded by `<sid>.actor`. **OBSERVED** — `eurmil.actor:2-18`; documented build-stage chain
also in `docs/terrain_swarm_2026-11-25/CHARTER.md:105-107` (cossacksworld: `<sid>1..4.osm`,
`<sid>_death1/2.osm`, registered in `<sid>.actor`).

**Scaffold** = `<sid>a.osm` family in `attach/`, material `scaffold` — **not** the sails.
**OBSERVED** — `eurmila.prop:23-57` (`DefaultMaterialName = scaffold` for all 7 meshes);
`eurmil.prop:78-97` lists `eurmila..eurmil4a` as `achildRequered` children with
`scaffold` material.

**Rotor/sails** = `<sid>anim.oss`, a separate skinned mesh, **not** a `.osm`.
**OBSERVED** — `eurmilanim.actor:5-6` (`.oss`), `rusmilanim.actor` (same);
`eurmilanim.prop:8-14` (`DefaultMeshName = eurmilanim.mesh`, one usable mesh);
`eurmilanim.prop:17-21` uses the mill's own material `eurmil`/`eurmilw`, distinguishing it
from the scaffold's `scaffold`/`scaffoldw`.

The port's own bake tool states the same relationship explicitly (a **port** claim about
donor art, corroborated below by direct byte decode): `app/tools/bake_mill_rotor.py:4-7`
— "The donor keeps the sails as a separate attach … `eurmilanim.oss` …
`eurmilanim.aaf` (`"idle",1,249,morph`)" and `:8-12` — the tower sheet is baked from the
+X view where the rotor is edge-on, the +Y view shows the four lattice blades.

## 3. Rotor attach point and rotation axis

### 3.1 How the donor attaches the rotor (OBSERVED)

The attach is **generic and script-driven by name**, not a bespoke `.prop` offset:

- `data/scripts/lib/miscext2.script:876-878` — at load, for every building it registers
  `sid`, `sid+'a'` and `sid+'anim'` into `gc_racename_buildings`.
- `data/scripts/units/building.inc/initial.inc:130-135` —
  `var aname := GetGameObjectMyLODActorName+'anim'; GameObjectAddNewChild(myHnd, gc_racename_buildings, aname);`
  and likewise `'anim2'`. **No position/rotation arguments are passed.**
- `data/scripts/units/building.inc/ontagstates.inc:129-134` — the same `+'anim'` child is
  added on the completion branch immediately before `arg_obj.bbuilt := True` (`:134`).
- `data/scripts/lib/player.script:3087-3094` — resolves the `+'anim'` child by base name
  and re-adds it if missing.

**Conclusion (OBSERVED):** the rotor is a child object spawned at the mill's own transform
with **no explicit attach offset**; its placement relative to the tower is baked into the
`.oss` vertex coordinates, which share the mill mesh's coordinate frame (§3.3).

Note: `data/objects/ref/refbuildingattach.prop:55` sets
`UseParentTLFToPosition = False` and `:163-167` has `Offset = (0,0,0)`, `AutoOffset = True`.
What `AutoOffset` does for an `'anim'` child is not documented in the readable data — the
exact engine-side attach transform is **UNVERIFIED**; the mesh-frame match in §3.3 is the
observable evidence.

### 3.2 Rotation axis and rate, decoded from donor bytes (OBSERVED / DERIVED)

Read-only decode of `eurmilanim.oss` with `app/tools/bake_sprites.py:91-103`
(header `<6i` = k, fps, bones, verts, faces, uvs; then per-bone `k × 7` floats of
position+quaternion) gives:

| Quantity | European `eurmilanim.oss` | Russian `rusmilanim.oss` | Label |
|---|---|---|---|
| Header: keys / fps / bones / verts / faces / uvs | 251 / 30 / 1 / 1098 / 550 / 1098 | 251 / 30 / 1 / 878 / … / … | **OBSERVED** |
| AAF action | `"idle",1,249,morph` (`eurmilanim.aaf:1-4`) | `"idle",1,249,morph` (`rusmilanim.aaf:1-4`) | **OBSERVED** |
| Bone quaternion at frames 62 / 125 / 187 | `(qx,qy,qz,qw) = (0,−0.6945,0,0.7195) / (0,−0.9998,0,0.0174) / (0,0.7545,0,0.6563)` | frame 125 `(0,−0.9999,0,0.0142)` | **OBSERVED** |
| Rotation axis | **local Y only** (qx = qz = 0 at every sampled key; Y ~ −87°, −180°, +98°, then identity at 249/250) | same | **OBSERVED** |
| Spin period / rate | 251 keys ÷ 30 fps = **8.367 s** → 2π/T = **0.751 rad/s** | identical | **DERIVED** |
| Fixed axle point (x,z), solved from `(I−R)p = t` at frames 62/125/187 | **(0.000, 5.628)** at all three frames | **(0.000, 3.562)** | **DERIVED** |
| Vertex bounds x / y / z | [−2.996,2.996] / [−1.898,−1.041] / [2.627,8.620] | [−2.611,2.508] / [−1.110,−0.253] / [1.053,6.069] | **OBSERVED** |

Quaternion orientation convention: the port's read-only parser documents that donor
rotations apply transposed (`app/tools/bake_sprites.py:118-129`); the axle solve above uses
that convention and returns the same (x,z) at three independent frames, which is the
consistency check. Sign of the spin direction in world terms is **UNVERIFIED** (see §5.3).

Spin rate cross-check: the port's `MILL_SPIN = 0.75` rad/s
(`variant3d/scripts/world3d_entities.gd:248`, cited to `app/scripts/world.gd:203-204`)
matches the donor-derived 0.751 rad/s to 2 dp — the port constant is donor-plausible even
though its own provenance note is a port file. This is **DERIVED corroboration**, not a
donor text citation.

### 3.3 Attach point in the mill's mesh frame (DERIVED from OBSERVED bytes)

`eurmil.osm` parsed with `app/tools/bake_sprites.py:551-560` has 2949 vertices, bounds
x [−2.426, 2.778], y [−2.401, 2.394], **z [−0.003, 5.914]** — i.e. local **Z is the tower's
vertical axis**, top at z ≈ 5.914.

The European rotor's blades are centred at x ≈ 0, z ≈ 5.628 (the solved axle) and y ≈ −1.470
(midpoint of the rotor slab [−1.898,−1.041]). Therefore the effective hub/attach point is:

- **European:** mill-local ≈ **(x=0, y=−1.47, z=5.628)** — 0.286 below the tower cap,
  centred across the tower, offset toward its −Y face. **DERIVED.**
- **Russian:** ≈ **(x=0, y=−0.68, z=3.562)**. **DERIVED.**

The rotor plane is X–Z (blades span x ±3.0, z ≈ 2.6..8.6) and its normal/axle is local Y.
This independently confirms the port bake-tool note (`app/tools/bake_mill_rotor.py:8-12`)
that the +X view is edge-on and the +Y view face-on. **DERIVED / OBSERVED.**

**Explicit donor numeric attach offset: UNVERIFIED.** No `<sid>.prop`, `.actor`, `.aaf`,
script or `data/game/var/objcustom.cfg` entry states the hub coordinate; the values above
are decoded from mesh geometry. The port's own hub `(0.17296, 5.23533, 0) m`
(`variant3d/scripts/world3d_entities.gd:1691-1695,1774-1776`) is derived from a **2D
sprite bake** (`MILL_HUB = (0.525,0.21)`, `app/scripts/world.gd:203`) and does **not**
match the donor mesh-frame hub above — treat it as **PORT APPROX**, not donor truth.
`data/game/var/objcustom.cfg:10945-10955` has an `eurmil` entry but only `Decal`,
`ResourcePoint` and `SmokePoints`, no rotation/attach override (consistent with the
almanac's statement that `objcustom.cfg` holds only those fields).

## 4. Whole-building yaw — does it place the sails on a specific face?

**Yes at authoring/default level. OBSERVED (value), DERIVED (interpretation).**

| Building prop | Field | Label |
|---|---|---|
| `data/objects/buildings/eurmil.prop:110-113` | `directionupproperty` override `DefaultRollAngle = 45` | OBSERVED |
| `data/objects/buildings/rusmil.prop:110-111` | `DefaultRollAngle = 45` | OBSERVED |
| `data/objects/buildings/turmil.prop:115-116` | `DefaultRollAngle = 135` | OBSERVED |
| `data/objects/ref/refbuilding.prop:266-270` | `RandomRollAngle = False`, `DefaultRollAngle = 0`, `RandomTurnAngle = False`, `DefaultTurnAngle = 0` | OBSERVED |
| `data/objects/ref/refbuilding.prop:253-261` | `DefaultDirection = (0,1,0)`, `DefaultUp = (1,0,0)` | OBSERVED |

Interpretation that `DefaultRollAngle` is the **ground-plane facing** (yaw): the same field
takes 0/90/180/270 on straight wall variants — e.g. `eurswa_02.prop:54` roll 0 with a
2×2 mask (`:32-33`), `eurswa_09.prop:56` roll 90 with an L-shaped mask (`:32-35`) — and
multiples of 45° across ~340 building props. A tilt about the forward axis at those values
would be implausible; the wall pairs are the decisive internal check. **DERIVED** (engine
semantics not documented in readable donor text, so the *naming* "roll" vs "yaw" stays
UNVERIFIED; the *effect* is a map-plane orientation).

Consequently the donor mill is authored with the sail plane (local X–Z, normal local Y)
turned 45° for eur/rus and 135° for tur relative to the grid; the sails face a specific
diagonal, they are not centred/omnidirectional. **DERIVED.** Whether a given `.map`
overrides that default per placed instance is **UNVERIFIED** (maps are binary and were
not decoded).

## 5. Camera-facing or wind-facing?

### 5.1 Not camera-facing (OBSERVED / DERIVED)

- The rotor child is created with `GameObjectAddNewChild` and no orientation arguments
  (`initial.inc:130-132`, `ontagstates.inc:129-130`, §3.1).
- `eurmilanim.prop:1` refs `refbuildingattach.prop`; that ref has a plain
  `directionupproperty` (`refbuildingattach.prop:141-155`) with `DefaultDirection = (0,1,0)`,
  `DefaultUp = (1,0,0)` — the same frame as the parent building
  (`refbuilding.prop:253-261`). There is **no billboard/camera-facing flag** in the rotor
  `.prop`, its `.actor`, or the ref. **OBSERVED** (absence of field in named files).
- The donor's animation is a 249-frame morph cycle (`eurmilanim.aaf:1-4`) applied as a
  looping frame animation (`eurmilanim.prop:24-36`; `refunit.actor:18-20`:
  `AnimationMode = aamLoop`, `Reference = aarMorph`). Only bone 0 exists and it rotates
  about local Y (§3.2). **OBSERVED.**

**Conclusion:** the rotor spins in a fixed plane tied to the building's orientation; it does
not turn to face the camera. **DERIVED from OBSERVED fields.** (Cossacks 3's fixed isometric
camera means it usually *appears* face-on, but that is camera geometry, not auto-facing.)

### 5.2 Not wind-driven (OBSERVED)

- `FrameAnimationSynchronizeOption = fasoNone` in `eurmilanim.prop:30` (the ref default
  is `fasoInherited`, `refbuildingattach.prop:118`) — the rotor animation is **not**
  synchronized to any parent/world clock other than its own loop.
- The only wind-related code found is audio: `data/scripts/lib/gui.script:3234`
  `const cMill = 'amb_windmill'`; `:3281` distance from camera listener to each built mill;
  `:3285-3289` `usage = gc_obj_usage_mill` → volume by distance; `:3301-3302` sets that
  volume. `data/sounds/ambient/amb_windmill.ogg` is the bed. No wind vector drives the
  rotor: no `wind` → rotation linkage exists in `data/scripts/**` (full-tree search for
  `milanim|rotor|wind` returned only the audio and animation-loading hits). **OBSERVED.**

### 5.3 Spin direction (UNVERIFIED in world terms)

The bone quaternion about local Y is observed (§3.2), and the single rotation axis is
certain. Whether that reads as screen-clockwise or counter-clockwise under the donor's
isometric camera + the 45°/135° mill yaw is **UNVERIFIED** without a donor GPU capture or
an engine-side transform chain. The port resolved this as a **PORT APPROX** by switching
`BACK → FORWARD` (`MOTION_ANIM_01.md:232,240,296-300`), explicitly not donor parity.

## 6. Can the player rotate the mill? (editor "R" key)

| Claim | Label | Evidence |
|---|---|---|
| In-game building rotation is not available to the player | **OBSERVED (community forum text, not an official manual)** | Steam discussion "Is there anyway to rotate buildings?", 2019-01-02 reply by Cherebuschka: *"It isn't possible to rotate building in game … With the external editor it's possible, so you may see building rotated in campaign mission"* — https://steamcommunity.com/app/333420/discussions/0/1742229167224417949/ |
| Rotation was still a requested feature in 2017 (i.e. absent in-game) | **OBSERVED (forum text)** | Steam discussion "Rotation of Buildings", 2017-04-27, OP requests "a click to choose the position, then turn to the preferred position and with a second click pass to the construction"; a reply notes GSC scenes with buildings at different rotations — https://steamcommunity.com/app/333420/discussions/0/1319962329027871657/ |
| In-game hotkey list contains no building-rotation key | **OBSERVED** | Gamepressure UI guide (2016-10-17) lists group/hold/attack/selection/queue hotkeys only — https://www.gamepressure.com/cossacks3/user-interface/zd91b1 |
| The external (Steam "Launch Game Editor") editor exists and is where map authors work; the in-menu editor is largely non-functional | **OBSERVED** | https://cossacks3.fandom.com/wiki/Editor — "both tools are undocumented and the version accessed through the game's main menu is largely non-functional"; "To launch the actual map editor … right-click on Cossacks 3, then select Launch Game Editor" |
| An **"R" key** rotates a selected object/building in the Cossacks 3 editor | **UNVERIFIED** | No Cossacks 3 editor manual/hotkey list found that names R; the Fandom editor page is silent; `editor.ini` has no keybind, `editor.cdx` yields only Delphi property/script names (`Rotate`, `RotationStep`, `SLogicFrmRotateGetShift`, …), not an accelerator label. Search results mentioning "[R] rotate object" are for *other* games (HoMM5, OMSI) and are **not** Cossacks 3 evidence. |
| Building rotation is achievable by editing the `.prop` (modding path) | **OBSERVED (search-index snippet) / page UNREACHABLE** | cossacksworld "Adding new buildings": "Lets rotate the building a bit, and rescale it a bit aswell just so you know how …" — http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349 (HTTP 403 and HTTPS transport error on 2026-11-25; only the search snippet was retrievable). This matches the local `DefaultRollAngle` field (§4). |

**Bottom line:** player rotation in-game = **no (community-observed)**; editor/modding
rotation = **yes as a placement/`.prop` property (observed)**; a specific "R" hotkey =
**UNVERIFIED** — do not ship a claim that the donor binds R to rotate without a donor
editor manual or a live editor capture.

## 7. Direct answers to the six M02 questions

| # | Question | Answer | Label |
|---|---|---|---|
| 1 | Which `.osm` is the mill body? | Base `<sid>.osm` (finished) + `<sid>1..4.osm` (stages) + `<sid>_death1/2.osm`, loaded by `<sid>.actor`: `eurmil.actor:2-26`, `rusmil.actor`, `turmil.actor`. Scaffold is the separate `<sid>a.osm` family. | OBSERVED |
| 2 | Which is the rotor/sails? | `<sid>anim.oss` (not `.osm`), e.g. `attach/eurmilanim.actor:5-6` → `eurmilanim.oss`; Russian `rusmilanim.oss`; **no Turkish rotor**. | OBSERVED |
| 3 | Rotor attach point | Generic `+'anim'` child spawned at the mill transform with no offset (`building.inc/initial.inc:130-132`, `ontagstates.inc:129-130`); hub decoded from mesh: eur ≈ (0, −1.47, 5.628), rus ≈ (0, −0.68, 3.562) in mill-local coords, near tower cap. Explicit donor numeric offset field: none. | OBSERVED (mechanism) / DERIVED (hub) / UNVERIFIED (engine-side exact transform) |
| 4 | Rotation axis | Single bone, quaternion about **local Y**; blade plane X–Z; 251 keys @ 30 fps = 8.367 s ≈ **0.751 rad/s** (port's 0.75 matches). World-space cw/ccw UNVERIFIED. | OBSERVED / DERIVED |
| 5 | Whole-building yaw | `DefaultRollAngle` 45 (eur, rus) / 135 (tur) vs ref 0; same field is the map-plane orientation for walls. Sails therefore face a specific diagonal; per-map override UNVERIFIED. | OBSERVED (value) / DERIVED (meaning) |
| 6 | Camera- or wind-facing? | Neither. Fixed-orientation looping morph child (`fasoNone`, `aamLoop`, no billboard flag); windmill sound is distance-driven only. | OBSERVED / DERIVED |

## 8. Open questions / what M03 must not claim

1. **UNVERIFIED** — exact engine semantics of `UseParentTLFToPosition=False` /
   `AutoOffset=True` for an `'anim'` child (`refbuildingattach.prop:55,163-167`).
2. **UNVERIFIED** — world-space spin sense (cw/ccw) and how the 45°/135° yaw maps to screen
   direction without a donor GPU frame.
3. **UNVERIFIED** — per-map rotation overrides, and a donor editor "R" hotkey.
4. The port's rotor is a **2D billboard quad** with hub `(0.17296, 5.23533, 0) m`, spin
   axis `Vector3.FORWARD`, and camera-facing transform
   (`world3d_entities.gd:1691-1696,1765-1781,2158-2181`). Its own labels say
   "donor `.oss` 3D direction UNVERIFIED" / "PORT APPROX"
   (`world3d_entities.gd:253-264`, `MOTION_ANIM_01.md:240,296-300`). **Do not** present any
   port rotor placement as donor-verified; the donor mesh-frame hub in §3.3 differs from
   the port hub.
5. **Do not copy donor files.** All donor bytes were decoded in memory; no donor asset was
   written into the repo by this ticket.

## 9. Sources

Local donor (read-only, `C:\Games\Cossacks 3\data\...`):
- `actors/buildings/commoneur/eurmil.actor:2-26`; `attach/eurmila.actor:3-28`;
  `attach/eurmilanim.actor:2,5-6`; `actors/buildings/commonrus/{rusmil.actor,attach/rusmilanim.actor}`;
  `actors/buildings/commontur/turmil.actor` + `attach/` enumeration.
- `animations/aaf/{eurmilanim,rusmilanim}.aaf:1-4`.
- `scripts/lib/miscext2.script:876-878`; `scripts/units/building.inc/initial.inc:130-135`;
  `scripts/units/building.inc/ontagstates.inc:129-134`;
  `scripts/lib/player.script:3087-3094`; `scripts/lib/gui.script:3234,3281-3302`;
  `scripts/lib/unit.script:2141-2151`, `scripts/dmscript.global:308`.
- `objects/buildings/{eurmil,rusmil,turmil}.prop` (roll/scale/mask/AABB lines in §4);
  `objects/buildings/attach/{eurmila,eurmilanim}.prop:1-43`;
  `objects/ref/{refbuilding,refbuildingattach}.prop` (lines in §3-4);
  `game/var/objcustom.cfg:10945-10955`.
- Binary decode: `actors/buildings/commoneur/eurmil.osm` (2949 verts);
  `actors/buildings/commoneur/attach/eurmilanim.oss` and
  `actors/buildings/commonrus/attach/rusmilanim.oss` — parser
  `app/tools/bake_sprites.py:91-103,551-560`; note
  `app/tools/bake_mill_rotor.py:4-12`.

Online:
- https://steamcommunity.com/app/333420/discussions/0/1742229167224417949/
- https://steamcommunity.com/app/333420/discussions/0/1319962329027871657/
- https://www.gamepressure.com/cossacks3/user-interface/zd91b1
- https://cossacks3.fandom.com/wiki/Editor
- http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349 (403/transport error; snippet only)
- https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/building_mechanics_evidence.md
  (footprint/mask context only: 1 mask cell = 0.5 map cells; `eurmil` 10 and `rusmil` 7 builder
  positions confirmed — no rotor/orientation claims)

Repo cross-references (port, not donor): `docs/coord_swarm_2026-11-25/reports/MOTION_ANIM_01.md:191-300`;
`docs/terrain_swarm_2026-11-25/reports/E05_ghost_mesh_naming.md:244`;
`variant3d/scripts/world3d_entities.gd:231-264,1691-1696,1765-1781,2158-2188`.

*End of M02 report.*
