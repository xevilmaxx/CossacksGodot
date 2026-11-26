---
id: VIDEO-ANIM-3D
swarm: TERRAIN-SWARM-2026-11-26 / TERRAIN-VISUAL-WAVE-2026-11-26
role: WORKER VIDEO-ANIM-3D — donor video 3D-model motion analysis
owner_file: docs/terrain_swarm_2026-11-26/reports/VIDEO_ANIM_3d.md
status: DELIVERED__READ_ONLY__NO_CODE__NO_GODOT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists."
scope_guard: "Exactly one repo file written (this report). No donor binary executed, no donor material copied into the repo."
donor_roots:
  - "%TEMP%\\opencode\\donor_videos\\selected\\cZW0AEupCaI\\ (V1, 40:21)"
  - "%TEMP%\\opencode\\donor_videos\\selected\\ljlCn4KSSU4\\ (V2, 37:33)"
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DONOR_VIDEO_analysis.md
  - variant3d/scripts/anim3d.gd
  - variant3d/scripts/world3d_entities.gd
  - variant3d/scripts/world3d_fx.gd
  - variant3d/assets/models/skin/index.json
---

# VIDEO-ANIM-3D — which donor 3D models visibly animate, and what the port does

## 0. Method note (read this first)

- **[O]** = directly seen in a listed frame or computed from a listed repo file.
- **[I]** = interpretation: plausible motion mechanism, NOT provable from 60 s-apart stills.
- **[U]** = unresolved after the passes in this ticket.
- Sampling is **one 1280×720 frame per ~60 s** (V1 `t_0/60/120/300/600/900/1200/1500/1800/2100/2260/2370`,
  V2 `t_0/60/300/600/900/1200/1500/1730/1800/2100`). A 60 s cadence **cannot resolve**
  a walk cycle (~0.7 s), a sail revolution (~8 s at 0.75 rad/s) or a muzzle flash (~0.4 s).
  What the stills give is **state-change evidence** (pose/stage/effect present in frame N,
  different in frame M), not motion curves. Anything about rate, loop or easing is **[I]**.
- No donor parity, threshold or A/B claim is made. Unknown build/map/camera/zoom/compression.

## 1. Observed donor motion, frame by frame

### 1.1 Mill sails — visibly different rotor angles across sampled frames [O]

| Frame | [O] sail state |
|---|---|
| V1 `t_60.png` (00:01:00) | 4-sail rotor on tower, sails pose ≈ diagonal cross, mill centred in green field parcel |
| V1 `t_120.png` (00:02:00) | Same mill, sails at a **different angle** than `t_60` (rotor arms nearer vertical/horizontal); field now mature golden wheat wrapping the tower |
| V1 `t_1800.png` (00:30:00) | Same mill, sails again at a **different angle**; peasants reaping inside the parcel, army column passing |

- **[O]** Three sail orientations at 00:01 / 00:02 / 00:30 on the same mill. The rotor visibly
  changes attitude between samples.
- **[I]** Consistent with continuous sail rotation, but spin direction, rate and loop-closure
  are **unresolvable** at 60 s sampling (aliasing). Do NOT derive a rad/s constant from these frames.
- Donor asset anchor (read-only, for owners): `data\actors\units\eurmilanim.oss`
  (k=251, fps=30, b=1, v=1098), cited at `world3d_entities.gd:292-306`.

### 1.2 Units — walk/march, idle garrison, combat [O state-change / I mechanism]

| Frame | [O] unit state |
|---|---|
| V1 `t_900.png` (00:15:00) | Formal multi-rank infantry lines beside the golden field and stone buildings; static formation pose |
| V1 `t_1800.png` (00:30:00) | Long red-coated column marching along the field edge; peasants bent over crops inside the parcel (work poses) |
| V2 `t_1500.png` (00:25:00) | Two large bodies in contact: blue/yellow line discharging firearms — **white musket-smoke puffs** distributed along the firing line; red-coated blocks returning fire; muzzle flashes visible as bright points |
| V2 `t_1800.png` (00:30:00) | Large orderly formation standing on open grass (idle/garrison state); spacing and footprint readable |

- **[O]** Distinct unit dispositions across frames: march column vs. formed line vs. firing line
  with smoke vs. standing mass. Peasant work poses inside the mill parcel (`t_1800`).
- **[O]** Musket smoke is a **frame-visible effect**: discrete white puffs along the V2 `t_1500`
  firing line, plus a brown dust/smoke channel on the ground.
- **[I]** Walk-cycle limb motion, per-man idle sway and the attack (shoulder/fire/recoil) sequence
  cannot be resolved from these stills; they are inferred mechanics, standard for the genre,
  not measured here. Which donor AAF action (`walk`/`walk0`/`attack0`/`attack1`) is on screen
  at any instant is **[U]** from video alone.
- **[O]** No unit in any sampled frame reads as a frozen T-pose; formations hold facing with
  coherent spacing (see also DONOR_VIDEO_analysis §4).

### 1.3 Building construction — staged growth with scaffolding [O]

| Frame | [O] construction state |
|---|---|
| V2 `t_60.png` (00:01:00) | Blacksmith site: open wall frames + timber scaffold beside finished town hall; "Town Hall has been constructed successfully" banner |
| V1 `t_120.png` (00:02:00) | Same blacksmith: walls higher, roof timbers started, **torch/fire glow** at the forge mouth; second town-hall wing complete |
| V2 `t_1200.png` (00:20:00) | Barracks tower wrapped in timber scaffold (mid-stage shell); separate wall-foundation trench running to a gatehouse; finished stone buildings adjacent for contrast |
| V2 `t_60.png` (00:01:00) | Small mine-pit structures with rock clusters (finished state, no scaffold) |

- **[O]** Construction is **staged**: open-frame → walled → roofed, with a timber scaffold
  present only mid-build. `t_60`→`t_120` shows stage advance on the same site.
- **[O]** Wall foundations are their own low stage (trench + footing course, V2 `t_1200`).
- **[I]** Whether stage swaps are discrete mesh swaps vs. progressive growth is unresolvable
  from 60 s stills; the donor runtime rule (hp-driven, `unit.script:6583-6596`) is code
  evidence, not video evidence.

### 1.4 Flags [O static presence; motion U]

- **[O]** Small pennant/flag markers are visible but rare in the sampled stills: a red pennant
  on the mine hut at V1 `t_1800` (right edge, above the mine building) and blue pennants on
  finished barracks/gatehouse at V2 `t_1200`. They read as **static few-pixel markers**
  at 720p; no flutter direction or wave phase is measurable.
- **[U]** Whether donor flags wave (vertex/cloth animation) or are rigid billboards cannot be
  decided from these frames. No flag occupies enough pixels for a before/after shape comparison.

### 1.5 Smoke / fire / dust [O]

| Frame | [O] effect |
|---|---|
| V2 `t_1500.png` (00:25:00) | Musket-volley smoke puffs along the firing line; ground dust channel |
| V2 `t_2100.png` (00:35:00) | **Burning-building columns**: multiple adjacent buildings emit tall white-grey smoke
  pillars with orange flame tongues at window/roof lines; smoke drifts leeward and occludes roofs |
| V1 `t_120.png` (00:02:00) | Small forge-glow at the blacksmith (flame light, not a smoke column) |

- **[O]** Fire + smoke is the largest animated effect in the sampled material (whole city
  blocks burning, `t_2100`). Volley smoke is the second (`t_1500`).
- **[I]** Particle vs. sprite-strip implementation, emission rate and wind response are
  engine internals, not video-derivable.

### 1.6 Explicitly NOT observed in sampled frames

- **[O]** No ship/water animation (consistent with DONOR-VIDEO §5.2: no certifiable shore frame).
- **[O]** No visible tree sway, field ripple, cloud shadow drift or water shimmer between the
  sampled stills; vegetation reads static at this cadence (sway at ±1–2 px would be invisible
  after H.264 anyway). Absence here is a **sampling limit**, not a donor-engine claim.
- **[O]** No building collapse animation sampled (only the burning steady-state).

## 2. What the port animates today (read from code, not from a run)

Owner: `variant3d/scripts/anim3d.gd` (donor clock + flat-root morph) +
`variant3d/scripts/world3d_entities.gd` (renderer) + `variant3d/scripts/world3d_fx.gd` (effects).

| # | Port behaviour | Mechanism (file:line) | Status |
|---|---|---|---|
| P1 | Unit idle/walk/death/construct morph | `anim3d.gd:161-226` `play()` / `528-569` `pose_for()`; donor AAF ranges `anim3d.gd:71-90`; 66 shipped skins in `assets/models/skin/index.json` (30–42 frames each of idle/walk/death/attack/construct subsets) | Animates for skinned sids; flat-root only (`BLOCKED_RIG`, bone parents unreadable); visual UNVERIFIED |
| P2 | Walk-vs-idle from **measured** displacement | `_measure_speed` (:1664), `_unit_action` (:1635), gate `WALK_SPEED_GATE_M_S = 0.15` (:252) | PORT APPROXIMATION; fixes walk-while-stalled |
| P3 | Mill sail spin | `_attach_rotor` (:2250), fixed-axle quad from `eurmilanim.oss` bbox (:302-306), `rotor_spin = _anim_t * 0.75` (:2672) | Spins; 2D-bake quad stand-in, spin sign PORT APPROX, visual UNVERIFIED |
| P4 | Construction stages + scaffold child | `_build_stage_suffix` (:2298, `floor(progress*4)`), `_sync_building_stages` (:2344), converted `<sid>1..4` / `<sid>1a..4a` OBJs under `assets/models/obj/shared/buildings/` | Mesh swap present where art converted; else base-mesh fallback; visual UNVERIFIED |
| P5 | Build-stage yaw clamp on units | `_smooth_face` (:1682), `YAW_MAX_RATE_RAD_S` 45°/s (:253) | PORT APPROX presentation clamp |
| P6 | Musket/cannon smoke, muzzle flash, projectile trails, snow, impact fire | `world3d_fx.gd:99-232` (`volley_smoke`, `muzzle_flash`, `arrow_trail`, snow cfg constants, impact smoke/fire) | Effect framework present (donor-param-cited); in-game calibration UNVERIFIED |
| P7 | Field growth-stage material swap | `_field_spec` (:788), `FIELD_GROWTH_MATERIALS` (:328), decal quads (:324-354) | Material/decal swap, no interpolation |

## 3. What the port holds static (gaps vs. §1)

| # | Static in port | Evidence |
|---|---|---|
| S1 | **Attack never selected**: `_unit_action` (:1635-1657) has only dead/construct/walk/idle branches; shipped skins DO export `attack0`/`attack1` frames (e.g. musketeer `attack1` [99..124], `index.json`) but no caller resolves them | `world3d_entities.gd:1635-1657` + `CONSTRUCT_SKIN_STATUS` (:206): "gather/resow/carry/attack still resolve to idle/walk" |
| S2 | **No building fire/burn state**: finished buildings stay intact meshes; no char/burn visual, no smoke column attach | No burn branch in `_sync_building_stages` (:2344-2429); `world3d_fx.gd` fire is impact-keyed, not building-state-keyed |
| S3 | **No flags/markers**: no pennant mesh, no flag-wave path in entities or fx | `grep flag variant3d/scripts` → only config keys and the AAF "loop flag" string; zero flag geometry/animation code |
| S4 | **No work actions**: `workfood/workwood/workstone`, `walkfood/walkwood`, `idlefood/idlewood`, `reaction`, `prepare0/unprepare0` exist in donor AAF (`anim3d.gd:76-89`, peaukr) but the port maps everything non-dead/non-build to walk/idle | `anim3d.gd:71-90` vs `_unit_action` (:1635) |
| S5 | **True sail mesh unused**: donor `eurmilanim.oss` (1098 verts) exists as data; the rotor is the 2D `mill_rotor.png` bake on a quad | `ROTOR_TEX_PATH` (:265), `ROTOR_STATUS` (:279) |
| S6 | Trees/rocks/fields: rigid instances; no sway/ripple path | No sway code in entities; jitter is placement-time only (`_jitter_factor` :721) |

## 4. Five smallest donor-grounded improvements (ranked)

Rank = smallest scope that closes an observed (§1) vs. static (§3) gap. Every item keeps
`PORT APPROXIMATION — NOT DONOR PARITY`; none claims donor motion fidelity.

| Rank | Improvement | Exact owner(s) | Donor ground | Why this size |
|---|---|---|---|---|
| 1 | **Wire `attack0`/`attack1` into `_unit_action`** for sids whose shipped skin exports them (musketeer, grenadier, archer, cannon… per `skin/index.json` `actions` keys). Add one branch: combat order + measured speed < walk gate → `attack0` (alias `attack`→`attack0` already in `anim3d.gd:94-96`). Covers the V2 `t_1500` firing-line gap (§1.2). | `variant3d/scripts/world3d_entities.gd:_unit_action` (:1635); `anim3d.gd:ACTION_ALIAS` (:94) already handles the name | Donor AAF `attack0/attack1` ranges per-sid in `skin/index.json`; pose/verts path already shipped (P1) | One branch + order-type check; zero new assets, zero new skins; reuses the existing morph-batch path |
| 2 | **Burning-building state**: when a building entity is flagged destroyed/burning by the sim, attach a smoke-column + flame effect from the existing `world3d_fx.gd` kit and swap to a darkened material tint; remove on repair. Covers the V2 `t_2100` city-fire gap (§1.5), the largest observed effect. | `variant3d/scripts/world3d_entities.gd:_sync_building_stages` (:2344, new burn pass beside stage pass); `variant3d/scripts/world3d_fx.gd` (`volley_smoke`/impact-fire kinds, :99-158) | Frame-visible donor behaviour (fire + smoke columns on damaged buildings, V2 `t_2100`); donor particle params cited in `world3d_fx.gd:117-232` | New visual state machine on existing nodes + existing FX kit; no new donor decode |
| 3 | **True 3-D sail mesh from `eurmilanim.oss`**: convert the shipped attach to OBJ/skin (1098 verts, bbox already measured at :295-301), bind as the rotor child in place of the PNG quad, rotate about the proven local-Z axle. Closes S5 and the §1.1 rotor-approximation debt. | `variant3d/tools/convert_skins.py` (extend to the attach) + `world3d_entities.gd:_rotor_mesh/_attach_rotor` (:2182-2275); asset `variant3d/assets/models/obj/shared/buildings/eurmilanim.*` | Donor geometry already probed read-only (`eurmilanim.oss` k/v/bbox at :293-301; mount math at :302-306) | One small asset conversion + swap of one child mesh; axle/position math already landed (M03) |
| 4 | **Work-action mapping for peasants**: route gather/reap orders to shipped `workfood/workwood/workstone` and carry orders to `walkfood/walkwood` (frames already exported for peasant sids per `anim3d.gd:76-81`; check per-sid `actions` in `skin/index.json`, fall back to idle/walk when absent). Covers the V1 `t_1800` reaping-pose gap (§1.2). | `variant3d/scripts/world3d_entities.gd:_unit_action` (:1635, new order-type branches); `variant3d/assets/models/skin/index.json` (per-sid availability gate) | Donor AAF work/carry ranges (`peaukr.aaf` via `anim3d.gd:76-81`); same morph path as P1 | Same one-function change as Rank 1, gated per-sid by already-shipped skin data; no new assets |
| 5 | **Pennant/flag marker on mines and finished prestige buildings**: small rigid triangular pennant child (red on mine hut per V1 `t_1800`, blue on barracks per V2 `t_1200`), static or with a cheap shader sway; explicitly labelled rigid/proxy until donor flag rig is readable. Closes S3 minimally. | `variant3d/scripts/world3d_entities.gd:add_building` (:2127, new pennant child beside the rotor precedent :2165-2168); new tiny asset under `variant3d/assets/models/obj/shared/buildings/` | Frame-observed marker presence/colour/placement (§1.4); motion stays **[U]** so the static-first version is the honest one | One small mesh + one attach call following the existing `_attach_rotor` pattern; no donor decode needed |

## 5. Observed-vs-inferred ledger (no parity claim)

| # | Statement | Label |
|---|---|---|
| 1 | Mill sails sit at different angles at V1 00:01 / 00:02 / 00:30 | [O] |
| 2 | Sail spin is continuous with a fixed donor rate | [I] — 60 s sampling aliases any rate; do not quote rad/s from video |
| 3 | Units march, form lines, fire with smoke, garrison idle across V1/V2 frames | [O] state-change |
| 4 | Walk-cycle / attack-sequence joint motion matches any donor AAF range | [U] — unresolvable from stills; AAF ranges are code facts, not video facts |
| 5 | Construction advances open-frame → walled → roofed with scaffold mid-build | [O] |
| 6 | Stage swaps are discrete donor mesh swaps (`floor(progress*4)`) | [I] from donor code (`unit.script`, `ontagstates.inc`), not from video |
| 7 | Volley smoke (V2 00:25) and building fire/smoke columns (V2 00:35) exist | [O] |
| 8 | Particle implementation / emission rate / wind response | [U] engine internals |
| 9 | Flag pennants present on mine hut (V1 00:30) and barracks (V2 00:20) | [O] presence/colour |
| 10 | Flags wave / use cloth simulation | [U] — pixels insufficient |
| 11 | Trees/fields/water animate in the donor | [U] — not observable at this cadence; no claim either way |
| 12 | Any port animation equals donor motion | **Denied** — PORT APPROXIMATION only; no same-camera A/B exists |

## 6. Scope statement

Exactly one repo file written (this report). Donor video files, frames and crops remain
outside the repo under `%TEMP%\opencode\donor_videos\`; no donor binary was executed and no
donor material was copied into the repo. No source, asset, config, test, shader, fixture,
git or runner state was changed; no Godot job was submitted.

*End of VIDEO-ANIM-3D.*
