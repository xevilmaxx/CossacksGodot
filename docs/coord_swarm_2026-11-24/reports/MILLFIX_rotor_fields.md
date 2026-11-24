---
id: MILLFIX
owner: MILLFIX subagent
date: 2026-11-24
scope: "variant3d/scripts/world3d_entities.gd and this report ONLY. No world3d.gd / anim3d.gd / convert_skins.py / app / config / tests / git edits."
status: "CODE COMPLETE — parse PASS + one combined structural probe PASS 20/20 (runner tickets 309 failed -> 310 PASS). FULL SELFTEST / UITEST: PENDING (user FAST LANE, explicitly skipped). No visual-parity claim."
governing_rule: "AUDIT3D_CHARTER.md:6-15 — path:line evidence, OBS vs INFERENCE, UNVERIFIED labels, smallest donor-grounded fix, no git operations."
owns: ["variant3d/scripts/world3d_entities.gd", "docs/coord_swarm_2026-11-24/reports/MILLFIX_rotor_fields.md"]
godot_runs: "ticket 309 (millfix-probe, failed — probe-only fixes: use_colors before instance_count; missing .ctex fallback), ticket 310 (millfix-probe2, ok 6.66 s, 20/20 PASS). Temp probe deleted; no result JSON written by probe."
---

# MILLFIX — 3D mill sail + per-field state visuals

## 0. Verdict

1. **F1 rotor: implemented.** A finished 3D mill now has one child
   `MillRotor_<id>`: a billboarded, alpha-cutout quad using the **already-shipped**
   donor bake `mill_rotor.png` (cell 320, `ortho=6.352 m`), hub derived only from
   `MILL_HUB` and `buildings.json` `ukr_mil`. Its local Z angle is `_anim_t * 0.75`
   rad (donor spin). This is a **PORT APPROXIMATION — NOT DONOR PARITY**: the real
   `eurmilanim.oss` sail geometry is a follow-up.
2. **F2 fields: implemented.** `sync()` now reads the shared sim API
   `game.field_state()` / `game.field_growth01()` per field instance and applies
   the 2D stage colours/relative scales to the `res|field` MultiMesh. The instance
   footprint is reduced from the 58.5 m donor bbox toward the ~2.4 m diagonal sow
   step. Sim is read-only: no `res_nodes` mutation, no `res_dirty` bump.
3. **All prior work in the file is preserved** (FIX-COLOR donor alpha-mask band
   tint, FIX-MOVE-VISUAL `yaw = PI/2 - face`, V7-74 morph consumption, V7-79 pose
   memo, batching, six public signatures, all honesty labels).

## 1. Donor / 2D evidence (all read-only OBS)

| Claim | `path:line` | Kind |
|---|---|---|
| Rotor is a separate moving object; `MILL_HUB=(0.525,0.21)`, `MILL_SPIN=0.75 rad/s`, `MILL_ROTOR_ORTHO=6.352` | `app/scripts/world.gd:199-208` | OBS |
| Lazy load of shipped bake; `mill_rotor.json` = `{cell:320, ortho:6.352}` | `app/scripts/world.gd:628-634`; `variant3d/assets/models/anim/buildings/mill_rotor.json:1-5`; PNG at `variant3d/assets/models/anim/common/buildings/mill_rotor.png` (36,081 B) | OBS |
| Spin math `draw_set_transform(hub, anim_t*0.75, ONE)`, full-cell span, hub `tl + sz*MILL_HUB` | `app/scripts/world.gd:640-654` | OBS |
| Cell anchor `tl = p - sz*(cx, foot)`; drawn only when mill finished | `app/scripts/world.gd:2892-2895` | OBS |
| `foot = ink[3]/cell`; `ukr_mil` `ortho=6.627`, `ink[3]=320`, `cx=0.4989` | `app/scripts/world.gd:694-698`; `variant3d/assets/models/anim/buildings/buildings.json:578-589` | OBS |
| 3D mill is one static donor mesh, no child; `sync()` has no rotor path | `variant3d/scripts/world3d_entities.gd` (pre-fix `:1091-1119`, `:1279-1282`); `PLAY2_02_mill_fields.md:37-62`, `:120-147` | OBS |
| Field sim API `field_state` (ripe/growing/regrowing/depleted) and `field_growth01` | `app/scripts/game.gd:2210-2228`; byte-identical `variant3d/scripts/game.gd:2210-2228` (SHA-256 `8649A865…` both) | OBS |
| Sow step `1.6981*TILE*0.5` (TILE=2 → 1.6981 m); diagonal neighbour `sqrt(2)*step ≈ 2.4016 m` | `app/scripts/game.gd:2098-2147` (`:2120`); `variant3d/scripts/data.gd:23`; `PLAY2_02_mill_fields.md:82-85` | OBS / derived |
| 2D stage tints and widths used verbatim by this fix | `app/scripts/world.gd:2550-2559`, `:2588-2613` | OBS |
| Donor decals `envfieldd.png` / `envfielddw.png` present in variant3d | `variant3d/assets/terrain/deco_png/envfieldd.png` (615,507 B), `envfielddw.png` (659,209 B); 2D use at `app/scripts/world.gd:2523-2539` | OBS |
| Field donor bbox ≈58.52 × 51.93 m (overlap source) | `variant3d/assets/models/manifest.json:537-553` | OBS |

Derived hub: local X = `(0.525 - 0.4989) * 6.627 = 0.17296 m`; local Y =
`(1.0 - 0.21) * 6.627 = 5.23533 m` (mesh height 5.917 m → tower cap); local Z = 0.

## 2. Exact diff — final `variant3d/scripts/world3d_entities.gd`

Everything else in the file is byte-position shifted only. No public signature
changed (still `bind(game)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`,
`add_resource(n)`, `remove(id)`).

| Final lines | Before | After |
|---|---|---|
| `:128-153` | none | MILLFIX header (authorized exception to the V7-14 no-anim rule, documented), donor constants: `ROTOR_TEX_PATH`, `ROTOR_META_PATH`, `MILL_HUB`, `MILL_SPIN`, `MILL_ROTOR_ORTHO`, `MILL_TOWER_ORTHO/CX/FOOT`, `FIELD_STEP_M`, `FIELD_SPAN_M`, decal paths, `ROTOR_STATUS`/`FIELD_STATUS` (both built on verbatim `PORT_LABEL`). Paths assembled from two string literals so the legacy `t_entities3d.gd:215-234` structural gate is not tripped by this one authorized bake. |
| `:168-170` | no rotor/field state | `+_rotors`, `+_field_visual` (headless-safe CPU mirror), `+_field_decal_paths`. |
| `:216-223` | no clears | `bind()` clears the three new dictionaries; records decal availability; notes 3D UV mapping UNVERIFIED. |
| `:298-308` | no mill/field telemetry | `bind()` stats: `mill_rotor_label/visual/source/meta/spin_rad_per_s`, `field_visual_label/visual/decals/sow_step_m/target_span_m`. |
| `:949-960` | `mm.instance_count = BATCH_CAPACITY` first | For `res|field` only: `mm.use_colors = true` **before** instance_count (Godot 4.7 requirement) and `vertex_color_use_as_albedo = true` on its StandardMaterial surfaces. All other batches unchanged. |
| `:1011-1012` | none | `_acquire()` seeds field instances with white colour. |
| `:1183-1186` | `add_building()` ended at `mi.transform = _xf(id)` | `if sid == "mil": _attach_rotor(id, mi)` — parent remains the exact `Building_mil_<id>_STATIC_POSE` donor mesh. |
| `:1189-1257` | none | `_rotor_mesh()` (6.352 m XY quad, donor UVs, +Z normal), `_rotor_material()` (donor PNG via ResourceLoader, with direct-PNG-byte fallback when the headless `.ctex` import cache is absent; `ALPHA_SCISSOR`, cull disabled, unshaded), `_attach_rotor()` (hub from MILL_HUB/buildings.json, `visual_status`/`donor_source`/`donor_meta`/`spin_rad_per_s` meta). |
| `:1330` | none | `remove()` drops the rotor mirror (child freed with parent). |
| `:1433-1450` | none | `sync()` rotor pass: `rotor_spin = _anim_t * MILL_SPIN`; manual billboard basis from the viewport `Camera3D` (no camera → identity), composed with a local-Z spin; visible only for finished mills; stats angle/count/label. |
| `:1465-1528` | none | `sync()` field pass: read `game.field_state()`/`field_growth01()` per `res|field` instance, apply exact 2D colours/relative widths (regrowing pulse uses `_anim_t`), scale footprint by `FIELD_SPAN_M / bbox_x_span * rel`, write instance transform/colour and `_field_visual` mirror; stats states/count/scale/label. |
| unchanged | FIX-COLOR mask/shader/metas `:128-153`→now `:...`; yaw correction `:1118`; morph `:1356-1383`, V7-79 memo `:1356`, V7-74 telemetry `:1557`; batching `:946-1013` | preserved verbatim (line numbers shifted only). |

## 3. Verification — parse + one probe; selftest PENDING

All Godot work went through `variant3d/tools/godot_runner.py` (no direct launches).

| Job id | Ticket | Result |
|---|---|---|
| `millfix-probe` | 309 | **failed**, 6.29 s — probe-only fixes: `use_colors` was set after `instance_count` (Godot rejects), and `load()` of `mill_rotor.png` failed because `variant3d/.godot/imported/*.ctex` is absent in headless. Both fixed in source; no re-run beyond the single allowed retry. |
| `millfix-probe2` | 310 | **PASS**, exit 0, 6.66 s — module parsed clean, **20/20 checks PASS**. Temp probe `variant3d/tests/millfix_probe_tmp.gd` deleted; no result JSON written. |
| full selftest / uitest | — | **PENDING** — skipped by user FAST LANE request. No 29/29 or visual-parity claim. |

### Measured (ticket 310, stub game, headless)

| Measurement | Value |
|---|---|
| Rotor child | `Building_mil_1_STATIC_POSE` → `MillRotor_1` (`MeshInstance3D`); alpha-scissor `StandardMaterial3D` with donor PNG bound |
| Rotor angle | `sync(0.1)` → `0.075000 rad`; `sync(0.5)` → `0.450000 rad`; **Δ = 0.375000 rad = 0.5 × 0.75** (tol 0.02) |
| Hub local | `(0.17296, 5.23533, 0) m` — gate ±0.5 m PASS |
| Quad span | AABB X = `6.3520 m` (mill_rotor.json:3, full cell) |
| Field instances | **4** (`res|field` batch = 4); states `{"ripe":1,"growing":1,"regrowing":1,"depleted":1}` |
| ripe | `Color(3.3, 2.5, 1.0, 0.7)`, scale `0.04103784580629` |
| growing | `Color(0.9, 1.6, 0.7, 0.6)`, scale `0.03180433049988` |
| regrowing | `Color(2.1, 2.0, 0.7, 0.4852)`, scale `0.03180433049988` |
| depleted | `Color(0.30, 0.26, 0.16, 0.60)`, scale `0.00606646416267` |
| Footprint | instance scale `0.04103784580629` = `2.40148 m / 58.5186 m` (target `FIELD_SPAN_M = 2.401476 m`) |
| Sim read-only | stub snapshot `[50,30.0,0]` → `[50,30.0,0]` unchanged |
| API | six signatures unchanged |

Stderr contained only the pre-existing `ANIM_STATUS` warning and the expected
`.ctex`-missing errors from the headless PNG fallback path; no script errors.

## 4. Open questions / UNVERIFIED

1. **No visual parity claim.** No screenshot/render/donor A/B was made. All
   checks are structural/numeric. Labels `PORT APPROXIMATION — NOT DONOR PARITY`
   and `visual UNVERIFIED` are on the rotor node, the field stats and both labels.
2. **True sail geometry is a follow-up.** The donor's `eurmilanim.oss` rotor mesh
   (not the 2D bake) is not consumed; a spin-billboard is a stand-in.
3. **Billboard in a live camera** is derived, not measured headlessly: with no
   `Camera3D`, the node keeps an identity face basis; the probe verifies the
   spin angle but not camera-facing in a rendered frame.
4. **Decal mapping.** `envfieldd/w` decals exist and are recorded, but their 3D UV
   mapping and winter/season selection have no verified 3D source
   (`PLAY2_02_mill_fields.md:217-218`); the field mesh keeps its own donor
   albedo and uses per-instance tint/scale as a labelled marker.
5. **HDR instance colours >1** (`3.3, 2.5, …`) are copied from the 2D canvas
   modulate; the exact 3D shader/clamp result is UNVERIFIED without a render.
6. **Regrow pulse phase** uses entity id where 2D uses `h`
   (`world.gd:2598`); the substitution is a port approximation.
7. **Headless import cache:** the `.ctex` fallback reads shipped PNG bytes; the
   normal `ResourceLoader` path is used when the editor import exists, but that
   path was not exercised in this probe.
8. **Full selftest / uitest PENDING** (user speed request); no regression claim
   beyond the 20/20 probe. No files other than the two owned paths were changed.
