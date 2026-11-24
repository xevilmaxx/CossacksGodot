# AUDIT3D_TRIAGE — consolidated 3D variant gap triage (2026-11-24)

Nine parallel audits (01-09) completed. Charter: `AUDIT3D_CHARTER.md`.
All reports: `docs/coord_swarm_2026-11-24/reports/AUDIT3D_0*_*.md`.

## What is VERIFIED GOOD
- **Simulation parity:** 14/21 common scripts byte-identical (incl. game.gd,
  ai.gd, world.gd); all 29 selftest step details match app/. Config differs
  only by `render_mode` (AUDIT3D-04).
- **Models are real:** 116 donor-derived OBJ meshes from binary `.oss`/`.osm`
  geometry, 0 GLB, no billboards/boxes as the primary path (AUDIT3D-01).
- **Terrain is real:** 102,400-vertex live-height grid; splat SHA-256 matches
  `g32_dump.json` identically in app/ and variant3d/ (AUDIT3D-03).
- **Runtime 3D nodes are real:** Camera3D, MeshInstance3D x4,
  DirectionalLight3D, WorldEnvironment measured at runtime; OpenGL 3.3 context
  in windowed mode (AUDIT3D-09).
- **Audio bed preserved:** identical audio.gd hash, 325 identical .ogg clips,
  identical event dispatch (AUDIT3D-06).
- **Resources sound:** no P0; full .import coverage, 19 benign static and 9
  dynamic unresolved res:// refs, DDS correctly excluded (AUDIT3D-07).
- **Camera/order semantics:** donor zoom bounds/tilt/edge-scroll match 2D; all
  cmd_* order paths inherited; no double-binding (AUDIT3D-05).
- **Launcher fixed:** direct windowed launch; variant3d defaults to 3d;
  selftest 29/29 passes with render_mode="3d" after hud.bind fix.

## P0 — BLOCK ACCEPTANCE
| ID | Gap | Evidence | Assignment | State |
|----|-----|----------|------------|-------|
| G1 | No real 3D pixels; windowed capture blank -> CPU 2D map fallback | AUDIT3D-09, main.gd:1715-1771 | V7-70 | **CLOSED** — genuine GPU pixels via Screenshot3DViewport (138/179); donor visual A/B still UNVERIFIED |
| G2 | Zero entity meshes in play: no add_unit/add_building call | AUDIT3D-01, world3d.gd:214-248,279-288 | V7-62 | **CLOSED** — probe 0->5 real mesh nodes (V762) |
| G3 | 58/81 IDs lack OBJ -> invented cube | AUDIT3D-01, world3d_entities.gd:191-213 | V7-63+V7-72 | **CLOSED** — 23/81->79/81; 172 obj_available; bar18/dock absent in donor |
| G4 | No donor player/nation tint; batching by sid only; invented palettes | AUDIT3D-02, world3d_entities.gd:170-188,321-336 | V7-61+V7-65 | **CLOSED** — 13 donor slots loaded, tint by player batch, probe 21/21 |
| G5 | No runtime light rig (donor rig stranded) | AUDIT3D-03/08, heightmap_world3d.gd:114-147 | V7-60 | **CLOSED** — WorldEnvironment+DonorSun node-tree 19/19 |
| G6 | Incomplete world3d contract (missing fog_revision, _anim_dir, etc.) | AUDIT3D-04, main.gd:1331/1418-1442 | V7-62 | **CLOSED** — 8 contract methods added, contract errors gone |
| G7 | Minimap camera jump is a 3D no-op | AUDIT3D-05, hud.gd:1397-1415 | V7-66+V7-67 | **CLOSED** — one-arg sim-metre contract verified end-to-end |
| G8 | Static bind pose; animation discarded/labeled approximation | AUDIT3D-01/08, anim3d.gd | V7-64+V7-74+V7-78 | **CLOSED (approx)** — 55 shipped skins auto-register, 733/733 verts morph; flat-root PORT APPROXIMATION, visual UNVERIFIED |
| G9 | FX mispositioned ~320 m (world_offset never set) | AUDIT3D-06, world3d_fx.gd:90,227-236 | V7-73 | **CLOSED** — 452.548 m -> 0.000 m |
| G10 | Ghost/rally/anim clock have no callers at runtime | AUDIT3D-06, world3d_fx.gd:167,191; world3d.gd:328-331 | V7-76 (+V7-74) | **CLOSED** — ghost false->true, rally 0->1, FX meshes 1->5 |

## P1
- P1.1 Static albedo baked from one seed, no seed/size consistency check (03).
- P1.2 Flat water quad vs 2D animated donor diffusewaves shader (03).
- P1.3 Player colour never rendered: no 3D selection ring/flag/stripe (02).
- P1.4 `picking3d.gd:208-236` discards players_only=false (04) -> V7-68.
- P1.5 Self-snapshot regression to w52-self-base-1 + lossy block_rect (04) -> V7-69.
- P1.6 view_rect full-map via Vector2/Vector3 mismatch (05) -> V7-62.
- P1.7 Fog quad height/centre mismatch + missing fog_revision (05) -> V7-62/follow-up.
- P1.8 Per-frame `int(id)` on entity Dictionaries (09, world3d.gd:207) -> V7-62 — **CLOSED** (extract "id", error gone).
- P1.12 NEW user-reported runtime: `dbg_res`/`dbg_bld`/`dbg_unit`/`dbg_fx`
  missing on world3d.gd, called unbranched from main.gd:1592 -> **CLOSED**
  (counters added with real increments; probe + selftest green).
- P1.13 E19 journey-mode camera lerp at main.gd:1626-1627 -> V7-70 — **CLOSED**.
- P1.14 E18 shift+group camera write -> V7-75 — **CLOSED**.
- P1.15 E6 flat-Y zoom anchor -> V7-77 — **OPEN QUESTION, no measured bug**
  (drift did not improve; flat correction preserves whole view ray).
- P1.9 Windowed Vector3->Vector2 audio error + no 3D distance culling (09/06, audio.gd:153,318) -> V7-71.
- P1.10 No 3D positional audio / AudioStreamPlayer3D (06, donor sound.script:418,515) -> later wave.
- P1.11 .gitignore excludes 4236 legacy sprite files (07) — tracking UNVERIFIED, no git used.

## P2
- P2.1 shots/ dir never created (07).
- P2.2 17 .gd lack .uid sidecars; 2099 .ctex absent (07).
- P2.3 Donor light constants dropped in heightmap_world3d.gd; 3D capture harness reduced; +0.1875s selftest sim-time (04).
- P2.4 Assumed FOV (~2.3x tighter view than 2D), fixed-depth pick, missing selection-rect/patrol overlays (05).

## Donor facts / honesty labels
- UNREADABLE/UNVERIFIED: `.map` relief, `.oss` bone parents, ACL/PFX semantics,
  absolute FOV, alpha in donor key colours, >1.0 colour clamping (08/02).
- No `.ani` files exist in the installed donor (08).
- `render_mode` is a PORT EXTENSION, never donor behaviour.
- Animation and rally/ghost art remain `PORT APPROXIMATION — NOT DONOR PARITY`
  until donor-parity evidence exists.

## Gate discipline
- No git operations by the assistant; user owns all commits.
- Every fix must keep `app/` (2D shipping port) byte-identical and its final
  gate green (selftest 29/29, uitest 17/17, clean).
- Variant gate after all fixes: selftest 29/29 with render_mode="3d",
  uitest, clean check, t_render_mode, plus runtime node-tree/photo evidence.
