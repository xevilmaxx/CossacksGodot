---
id: BUILD-ANIM-DIAG-01
title: "BUILD-ANIM-DIAG-01 — why the peasant building animation is wrong (read-only diagnosis)"
date: 2026-11-25
owner: BUILD-ANIM-DIAG-01 (read-only diagnosis worker)
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY__NO_PARITY_CLAIM
scope: "Exactly one report written. No repo code/config/asset/test/scene/git edit; no Godot/Blender run, no runner job. Donor read-only bytes/latin-1 only (Python 3.14 probe in approved temp folder, deleted); no donor binary executed, unpacked or copied into the repo."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; no donor binary executed or copied)"
output: "docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
governing_rule: "Cite donor path:line or path:offset; separate observed / derived / inferred / UNVERIFIED; never claim donor parity from data-level or motion evidence (DANIM-01 frontmatter :12; VID_AN_01:10; DEC-04 §7)."
verdict: "ROOT CAUSE = presentation-layer action selection, not missing AAF clip. The 3D entity renderer's _unit_action() has no build/repair branch, so a peasant with order.type='build' is rendered as 'idle' (or 'walk' while travelling); additionally the shipped compact skins never export 'construct' frames, so a naive action-string-only fix would snap frames 186..198 to death frame 149 / attack0 frame 237."
---

# BUILD-ANIM-DIAG-01 — why the peasant building animation is wrong

## 0. Question and answer bounded

Why is the 3D peasant's building animation wrong? Answer: **the donor `construct`
clip is readable and is already in the port's AAF table, but the 3D renderer
never asks for it.** `world3d_entities.gd:_unit_action()` selects only
`death / walk / idle` (`world3d_entities.gd:1009-1016`); the sim's
`order.type == "build"` (`game.gd:3115`) is invisible to it. A stationary
builder therefore renders the donor **idle** pose loop, and a builder walking to
the site renders **walk**. Even if the action string were changed alone, the
shipped compact skin `variant3d/assets/models/skin/peasant.json` exports no
`construct` frames, so `_nearest_exported_frame()` would substitute frames from
`death`/`attack0`.

**No donor-parity or visual-fidelity claim is made.** Deformation is flat-root
`PORT APPROXIMATION — NOT DONOR PARITY`, `visual = "UNVERIFIED"`
(`anim3d.gd:63,66,524`; `world3d_entities.gd:181-186`). Everything below is a
code/data-level diagnosis; no capture or runner job was executed by this worker.

---

## 1. Sources read (all read-only)

| # | Source | Used for |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md` | 62-name AAF catalog, §4.2 state→name chain, §5 clip table, §4.3 loop/blend policy |
| S2 | `docs/coord_swarm_2026-11-25/reports/DANIM_02.md` | independent re-verification; 43/43 clip table correct; peasant ACL chain `:247` |
| S3 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` | `.oss/.aaf/.acl` layouts, FPS 30, §5 cross-reference, §7 blockers |
| S4 | `docs/coord_swarm_2026-11-24/reports/V764_donor_morph_anim.md` | `anim3d.gd` handoff, body-only morph, tool open Q3, one-shot open Q6 |
| S5 | `docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md` | 3-state PORT action policy `:506-517`, per-pose batching, no visual claim |
| S6 | `docs/coord_swarm_2026-11-24/reports/V779_pose_memo.md` | per-`sync()` memo, frame from `(sid, action, donor time)` `:77-83` |
| S7 | `docs/audit/ANIM_ADJUDICATION.md` | AAF cadence is donor truth; "do not detune correct data to please a stale test" `:27-32` |
| S8 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md` | building stage selector; no stage/scaffold 3D art; site reuses base mesh |
| S9 | `docs/coord_swarm_2026-11-25/reports/VID_AN_01_motion_analysis.md` | `moving:true` at ~0 velocity, walk/idle cycle vs render, speed-gate rationale |
| S10 | `variant3d/scripts/anim3d.gd` (READ ONLY) | `AAF_ACTIONS` `:71-90`, alias `:94-96`, `pose_for` `:489-530`, `_frame_at` `:582-588`, `_nearest_exported_frame` `:907-912`, `_action_range_for` `:918-934` |
| S11 | `variant3d/scripts/world3d_entities.gd` (READ ONLY) | `_unit_action` `:1009-1016`, speed gate `:199`, `sync` Pass 1 `:1804-1888`, stage call `:1913`, yaw `:1375-1379` |
| S12 | `variant3d/scripts/world3d.gd` (READ ONLY) | 2D sibling `_anim_action` `:470-499` — build→`construct` already implemented there |
| S13 | `variant3d/scripts/game.gd` (READ ONLY) | `order.type="build"` `:3115`, repair `:4411`, building progress `:2193,:4968-4974` |
| S14 | `variant3d/tools/convert_skins.py`, `variant3d/assets/models/skin/index.json`, `peasant.json` (READ ONLY) | exported action set and frame union; `DEFAULT_ACTIONS` `:69-73` |
| S15 | fresh read-only donor Python pass (bytes/latin-1, temp, deleted) | verbatim `peaukr.aaf`, `acl.lib`, `peasant.acl`, `peaukr.prop`, `dmscript.global`, `unit.script`, `showdebuganimations.inc`, `buildsmoke*.actor`, `actors.lib`, `pfxbuildsmoke*.aaf` rows below |

---

## 2. Donor truth — the peasant build animation

### 2.1 Donor action table

All rows below are **observed** from donor bytes/text (S15) unless labelled;
`duration = (last-first+1)/30` is **derived** and independently cross-checked
against `data/scripts/lib/unit.script:10774-10777` (S1 §3.2, S2 §2.3).

| Item | Donor truth | Path:line / evidence |
|---|---|---|
| State tag | `gc_statetag_action_build = 1 shl 8` | `data/scripts/dmscript.global:13` (S15) |
| Name constant | `gc_anim_construct = 'construct'` | `data/scripts/dmscript.global:926` (S15; S1 `:70,316`) |
| State→name selection | `gc_statetag_action_build : anim := gc_anim_construct;` | `data/scripts/lib/unit.script:10877` (S15; S1 `:325`) ; `data/scripts/units/unit.inc/ontagstates.inc:318` (S1 `:325`) |
| AAF row | `"construct",186,198,morph` | `data/animations/aaf/peaukr.aaf:17` (S15; S1 `:405`, S3 `:478-482`) |
| Range / frames / duration | inclusive **186..198**, **13 frames**, **0.433 s** | derived from AAF row + fps 30; S1 §5; S2 `:247` |
| FPS | `30` in `.oss` header int #1 (`peaukr.oss:0x4`) | `data/actors/units/peaukr.oss:0x4` (S3 `:119,474`); 335/335 files |
| Actor binding | AAF + `.oss` loaded by the peasant actor | `data/actors/units/peaukr.actor:4-6` (S3 `:375-380`) |
| `.prop`→ACL library | `FrameAnimationCyclesLibName = peaukr` | `data/objects/units/peaukr.prop:54` (S15; S1 `:72`) |
| ACL library | `Name = peaukr` → `peasant.acl` | `data/animations/acl/acl.lib:238-239` (S15; S1 `:73`, S2 `:247`) |
| ACL clip binding | `From = construct` / `Name = construct` / `items[0].AnimationName = construct` / `refkey=.default` / `global refkey=.peasantidle` / `items[1].ExecuteStateName=OnAclAnimationReachedConstruct` | `data/animations/acl/peasant.acl:2245-2252` (S15); inheritance `peasant.acl`→`refunit.acl`→`refspeed.acl` (S2 `:247`; `refspeed.acl:10` = `peasantidle`) |
| Loop / one-shot policy | **AAF has no loop flag** (1,434/1,434 rows are `morph` only). Loop is authored elsewhere: debug UI `CreateDebugAnimPlayButton('construct', False, ind)` → **loop**; attacks/deaths use `True` → play-once. ACL `construct` has no `NumberCycle = 1` (contrast `peasant.acl:2228,2241`), and fires an execute-state. Blend `minFrameBlend=6 / maxFrameBlend=8`. | `data/animations/aaf/peaukr.aaf:3-20` (S1 `:92`); `data/gui/menu.inc/showdebuganimations.inc:143` vs `:121-131` (S15; S1 `:359-368`); `data/scripts/lib/unit.script:10846-10847`, `data/scripts/units/unit.inc/initial.inc:17-19` (S1 `:374-380`). **UNVERIFIED:** exact engine playback/blend semantics (no compiled engine). |
| Tool | same action name selects the separate single-bone hammer `.oss`: `gc_anim_construct : actorInd := gc_actor_peasant_hammer;` | `data/scripts/lib/unit.script:7008` (S15; S1 `:342-347`); `data/actors/units/attach/peaukr_hammer.oss` (S3 `:379-380`); `variant3d/tools/bake_sprites.py:344-353` `ATTACH_ACTIONS hammer→construct` (S15) |
| Smoke | **separate PFX family, not part of the `construct` AAF row or ACL**: `buildsmoke1/2/3(_birth).actor` each bind a `pfxbuildsmoke*.aaf` + `.oss`; registered in `actors.lib`; each AAF is `"idle",1,90,morph` (3.0 s loop). No readable script text contains `buildsmoke` (fresh donor sweep: hits only in `.actor`/`.lib`), so the spawn trigger is **UNVERIFIED**. Do not confuse with musket-volley smoke (`GUIDE4.md:910`). | `data/actors/pfx/fire/buildsmoke1.actor:2-4` (S15; same shape for all six); `data/actors/actors.lib:2490-2511` (S15); `data/animations/aaf/pfx/pfxbuildsmoke1.aaf:3` (S15) |
| 8-azimuth handling | Donor 2D bake renders **8 azimuths d·45°, elevation 32°, ortho, 50 m** — a camera/renderer transform, **not** an AAF action. Peasant AAF has zero turn/azimuth clips (`peaukr.aaf:3-20`). | `variant3d/tools/bake_sprites.py:218-238` (S15); `docs/guides/GUIDE4.md:825,906-907`; S1 open Q4 `:588`. Port 3D uses continuous yaw instead (`world3d_entities.gd:1375-1379`), so the build pose itself is azimuth-independent; visual equivalence of the 8 views stays **UNVERIFIED** (S3 §7, S1 §8.5). |

### 2.2 What the donor build animation actually is (synthesis)

**Observed/derived:** when a peasant receives the build state tag, the donor
selects AAF action `construct` = donor frames 186..198, 13 frames at 30 fps
(0.433 s). The same action name also switches on a separate one-bone hammer
mesh. The AAF row carries no loop flag; looping/one-shot is authored in ACL and
scripts, and the debug UI treats `construct` as a looping pose. Construction
smoke, where present, is a **separate** PFX actor family on the site, not a
channel of the peasant clip. Azimuth is never an action: the eight donor views
are eight camera positions around the same mesh.

**Inferred (not provable read-only):** the looping `construct` pose is a hammer
swing cycle repeated while the build state is active, terminated by the ACL
`OnAclAnimationReachedConstruct` execute-state / state-machine exit (peasant.acl:2251-2252;
S1 §4.2). Exact engine timing, blending and whether the hammer PFX smoke is
fired per strike or per building stage are **UNVERIFIED**.

---

## 3. Port selection trace — what happens today when a peasant builds

### 3.1 Sim side (observed, S13)

- `game.gd:3115`: `e.order = {"type": "build", "target": site.id}`; repair uses
  `{"type":"repair",...}` (`game.gd:4411`).
- Building progress is `progress / def.build_time` (`game.gd:2193`,
  `:4968-4974`). The sim does **not** write a `construct`/`build` flag onto the
  unit's animation state; the only unit-level presentation fields are
  `dead`, `moving`, `face`, `carry`/`carry_type`, `order` and `pos`.

### 3.2 3D renderer side (observed, S11)

1. `sync()` advances one shared clock `_anim_t += maxf(dt,0.0)`
   (`world3d_entities.gd:1781`).
2. Per unit it **measures** displacement speed via `_measure_speed()`
   (`:1023-1034`) and calls `_unit_action(ed, speed)` (`:1829`).
3. `_unit_action()` (`:1009-1016`) is the entire action-selection policy:
   ```
   if dead                       -> "death"
   if speed >= 0.0               -> "walk" if speed >= WALK_SPEED_GATE_M_S else "idle"
   if moving                     -> "walk"
                                 -> "idle"
   ```
   with `WALK_SPEED_GATE_M_S = 0.15` (`:199`). **No branch reads `order`,
   `order.type`, `build`, `repair`, `gather`, `carry`, or AAF `construct`.**
   Constant `MORPH_ACTION_MAP` (`:186`) openly documents the 3-state policy
   `dead->death / moving->walk / else idle`.
4. The chosen string goes to `anim.pose_for(ed, action, _anim_t)` (`:1839`);
   only a non-empty `pose_source == "donor_flat_root_morph"` pose is accepted
   (`:1843-1849`), batched under `...|a<action>|f<frame>` (`:1856-1860`), with a
   same-batch mesh refresh fallback (`:1868-1883`).
5. The **building** is handled separately: `_sync_building_stages()` (`:1913`)
   records stage metadata but, because no stage OBJs exist, reuses the base
   mesh (S8 `:20-24,38-54,84-93`). There is no link from building progress back
   to the builder unit's action.

**Observed conclusion:** a peasant with `order.type="build"`, standing at the
site (speed ≈ 0), gets `action = "idle"`; one still walking to the site gets
`"walk"`. `construct` is never requested by the 3D module.

### 3.3 anim3d / clip-table side (observed, S10, S14)

- `anim3d.gd:86`: `AAF_ACTIONS["construct"] = [186, 198, 17, "morph"]` — the
  clip **is** present; the "missing clip" hypothesis is **REFUTED**.
- `pose_for` (`:489-530`) maps alias `attack→attack0` only (`:94-96`), resolves
  the range with `_action_range_for` (`:918-934`: per-sid skin actions first,
  else the peaukr table), resolves the donor frame with `_frame_at`
  (`:582-588`, `fposmod` loop), then `_morph_fields` (`:534-556`).
- **Shipped skins exclude the action.** `convert_skins.py:69-73` sets
  `DEFAULT_ACTIONS = ("idle","idle0","walk","walk0","death","attack0","attack1")`
  with the comment "idle/walk/death are the only ones the shipped renderer asks
  for (world3d_entities.gd:506-511)". `skin/index.json` has the same 7
  `actions_requested`; `skin/peasant.json` actually carries 5
  (`idle, idle0, walk, death, attack0`) because the peasant AAF lacks `walk0`
  and `attack1`. `convert_skins.py:13-17,210-217` stores only 6 sampled frames
  per selected action and the union of those frames for **compact** skins.
- `_normalise_raw` marks shipped skins `compact = true` (`anim3d.gd:860`), so
  `_morph_fields` (`:546`) calls `_nearest_exported_frame` (`:907-912`) and
  `skin_vertices` maps a donor frame to a compact slot (`:421,428`).
- **Measured snap (derived from the shipped JSON):** peasant `frames` =
  `[1,5,9,12,16,20,64,74,84,93,103,113,115,122,129,135,142,149,237,240,244,247,251,254]`.
  Any `construct` donor frame resolves to **149** (last `death` frame) for
  186..192, or **237** (first `attack0` frame) for 194..198. Therefore passing
  `"construct"` today would render a death/attack pose, **not** a build pose.
  (Rendered appearance inferred from code+JSON; not run by this worker.)

### 3.4 Contrast — the 2D sibling already does it right (observed, S12)

`variant3d/scripts/world.gd:481-490` implements the donor-derived map:
`order.type=="gather"` → `workwood/workfood/workstone` (by `res`),
`"resow"` → `workfood`, **`"build" or "repair"` → `"construct"`**; carry
variants at `:491-497` and fallbacks at `:542-550`. This is a donor-grounded
precedent already in the repo; the 3D module simply did not port that branch.

### 3.5 Speed gate context (observed code / inferred sim state)

The 0.15 m/s gate was added by MOTION-ANIM-01 because VID-AN-01 measured a
unit with `moving:true` at ~0.001 m/s while its walk frames kept cycling
(`VID_AN_01:67,86-90`; `world3d_entities.gd:191-194,1004-1008`). For a builder,
**inferred** (not measured here): standing at the site yields speed < gate →
`idle`; travelling to the site yields `walk`. Neither is `construct`. No
builder-specific capture has been taken.

---

## 4. Root-cause ranking (most load-bearing first)

| Rank | Cause | Label | Evidence | Effect if fixed alone |
|---|---|---|---|---|
| 1 | **Missing build-state propagation in `_unit_action()`** — no `order.type` branch, unlike the 2D sibling | **observed** (code) | `world3d_entities.gd:1009-1016` vs `world.gd:481-490`; sim field `game.gd:3115` | Builder would request `"construct"` — necessary but **not sufficient** |
| 2 | **Shipped compact skins never export `construct` frames** → `_nearest_exported_frame` snaps 186..198 to death 149 / attack0 237 | **observed** (code + JSON); rendered outcome **inferred** | `convert_skins.py:69-73`; `index.json actions_requested`; `peasant.json actions/frames`; `anim3d.gd:546,860,907-912` | Without this, rank-1 fix renders a wrong clip — the decisive secondary cause |
| 3 | **Speed gate forces `idle` for a stationary builder** | **observed** (code); builder speed ≈ 0 **inferred** | `world3d_entities.gd:199,1012-1013,1023-1034`; VID-AN-01 `:67,86-90` | Correctly stops walk-while-stalled; does not create a build action |
| 4 | **Tool / smoke / looping presentation absent in 3D** (body-only flat-root morph; no hammer `.oss`, no `buildsmoke` PFX) | **observed** absence; visual impact **UNVERIFIED** | `V764 §2/:207-216` Q3; `DEC_04:379-380`; donor `unit.script:7008`, `buildsmoke1.actor:2-4`, `actors.lib:2490-2511`; no PFX call in `anim3d.gd`/`world3d_entities.gd` | Even after 1+2, hammer and site smoke still missing; not part of smallest fix |
| 5 | **Construction site itself static** — no stage/scaffold 3D OBJ, base mesh reused | **observed** | `BUILD_STAGES_01:20-24,38-54,84-93`; `world3d_entities.gd:1913` | Building progress geometry still absent; distinct ticket |
| — | **Not a cause:** `anim3d` AAF table lacks `construct` | **REFUTED** | `anim3d.gd:86`; S1 §5 `:405`; S2 `:247` | No action needed in `anim3d.gd`'s table |

**Single sentence:** the primary defect is a **presentation-layer action-selection
gap** (rank 1), made non-recoverable by a **skin-export gap** (rank 2); the
donor clip data and the port's AAF lookup are already correct.

---

## 5. Smallest fix recipe (no edits made by this worker)

| Step | Owner / file | Change | Why smallest |
|---|---|---|---|
| 1 | `variant3d/scripts/world3d_entities.gd` — `_unit_action()` `:1009-1016` | Add, after the `dead` check and before the speed/moving fallbacks: if measured speed is below `WALK_SPEED_GATE_M_S` (i.e. not walking) and `str(ed.get("order",{}).get("type","")) in ["build","repair"]`, return `"construct"`. Mirror `world.gd:489-490`. Optional, same change: `gather`/`resow` → `workwood/workfood/workstone` per `world.gd:481-488`. Keep `rendered_actions` telemetry (`:1830`). | One function; reuses the sim field that already exists; preserves dead-first priority and the VID-AN-01 speed gate. |
| 2 | `variant3d/tools/convert_skins.py` `:69-73` **and** generated `variant3d/assets/models/skin/index.json` + per-sid skin JSON (asset/data owner; regenerate **offline**) | Add `construct` (optionally `workfood/workwood/workstone`) to `DEFAULT_ACTIONS`; re-run the converter so each skin's `actions`/`frames`/`anim` include donor frames 186..198. Expected peasant `construct` export: `[186,188,191,193,196,198]` (verified with `convert_skins.sample_frames`). | Data-only; no runtime donor access; makes rank-1 fix resolve real poses instead of 149/237. |
| 3 | `variant3d/scripts/anim3d.gd` | **No code change.** `AAF_ACTIONS.construct` `:86` and `_action_range_for` `:918-934` already work once step 2 lands. Keep all `PORT APPROXIMATION` / `visual = UNVERIFIED` labels. | Avoids touching the donor-math contract. |

**Explicitly out of this smallest fix (label, do not bundle):** hammer tool skin
(`V764` Q3 / `bake_sprites.py:344-353`); `buildsmoke` PFX presentation; stageOBJs
(`BUILD_STAGES_01` Q1); one-shot/blend policy (`DANIM-01 §8.3`). None of these
may be reported as donor parity.

---

## 6. Discriminating capture / test (recipe only — NOT run)

**Shape (read-only probe, temporary, deleted after):** one `peasant` unit with
`order = {"type":"build","target":site}` and site `progress = 0.4*build_time`,
`finished=false`; sim frozen at speed 0 and driven by fixed `sync(dt)` ticks;
hold `face = 0.0` constant to isolate azimuth (3D yaw is a continuous transform,
`world3d_entities.gd:1375-1379`, so varying it would confound pixel diffs).
Per tick, record `order.type`, `rendered_actions`, `pose.action`,
`pose.frame`, `pose_source`, batch key, vertex-buffer hash, and
`build_stage_suffix`.

**Layer A — direct deterministic mapping check** (calls `pose_for` at
`t = f/30` for the six donor frames, so no clock aliasing):

| Stage | Expected `pose.action` | Expected `pose.frame` sequence | Guard |
|---|---|---|---|
| Before (current) | `"idle"` when asked via `_unit_action`; if `"construct"` is passed explicitly | if passed explicitly: snapped to **149/237** (death/attack0) | none |
| **After steps 1+2** | `"construct"` | **[186, 188, 191, 193, 196, 198]** — six distinct vertex-buffer hashes | `pose.frame` **never** in `{149, 237}`; `pose_source == "donor_flat_root_morph"`; `visual == "UNVERIFIED"` |

This is the discriminator: it separates "action string changed but skin export
still missing" (wrong death/attack pose, 149/237) from a real build pose
sequence. The expected frame list is derived from
`convert_skins.sample_frames(186,198,6)` (verified read-only), itself the donor
`bake_sprites.py:145-152` decimation.

**Layer B — sync-level builder capture:** assert `rendered_actions["construct"] >= 1`
and `rendered_actions["idle"] == 0` for the builder while the build order is
active, batch keys contain `|aconstruct|`, and the site's `build_stage_suffix`
advances (`floor(0.4*4)+1 = "2"` per `BUILD_STAGES_01 §4`). Expected fail-before:
`rendered_actions = {"idle":N}`, no `|aconstruct|` key.

**Capture hygiene (from `VID_AN_01:150-153`):** use a closer camera / lit ground
if a limb-level hammer swing is to be judged; at zoom 2.9 / height 20 m the
right-hand unit was bit-identical across 16 frames, so a negative pixel result
alone is **not** evidence of a missing pose. No donor footage exists; motion
smoothness is not parity evidence (`VID_AN_01:115-125`).

---

## 7. Open questions

1. **Loop vs one-shot:** `construct` debug button is `bPlayOnce=False`
   (`showdebuganimations.inc:143`) and ACL fires `OnAclAnimationReachedConstruct`
   (`peasant.acl:2251-2252`), but ACL engine semantics and the state-machine exit
   timing are **UNVERIFIED** (S1 §9 Q2/Q5).
2. **Smoke trigger:** `buildsmoke*.actor`/`pfxbuildsmoke*.aaf` exist
   (`actors.lib:2490-2511`), but no readable script binds them to the build
   state (0 script hits for `buildsmoke`) — spawn policy **UNVERIFIED**.
3. **8 azimuths vs continuous yaw:** donor uses 8 camera azimuths
   (`bake_sprites.py:218-238`); 3D port uses continuous `PI/2 - face`
   (`world3d_entities.gd:1375-1379`) and clamps yaw rate to 45°/s (`:200`).
   No donor citation for 3D yaw (S1 Q4); equivalence **UNVERIFIED**.
4. **Repair and gather mapping:** donor `gc_statetag_action_build` covers build;
   port 2D maps `build`/`repair` → `construct` (`world.gd:489`) and gather →
   `work*` (`:481-488`). Whether the donor distinguishes repair via a different
   tag is **UNVERIFIED** here.
5. **Tool visibility at 3D zoom:** the hammer is a separate single-bone `.oss`
   (`unit.script:7008`); whether an empty-handed 3D peasant is acceptable is an
   owner decision (V764 Q3).
6. **Stage art:** until `<sid>1..4.obj` / scaffold art arrive, even a correct
   peasant pose plays in front of a static base-mesh site (`BUILD_STAGES_01 Q1`).
7. **Visual parity:** bind form, quaternion convention and rendered A/B remain
   **UNVERIFIED** (`DEC_04 §7`; S1 §8.5). This report changes none of that.

---

## 8. Summary

- **Donor truth (observed/derived):** peasant build = AAF action `construct`,
  `peaukr.aaf:17` 186..198 inclusive, 13 frames @30 fps = 0.433 s; selected by
  `gc_statetag_action_build` (`dmscript.global:13`) → `gc_anim_construct`
  (`:926`) in `unit.script:10877`; bound through `peaukr.prop:54` → `acl.lib:238-239`
  → `peasant.acl:2245-2252` (`From/Name/AnimationName = construct`,
  `OnAclAnimationReachedConstruct`); the same action switches on the separate
  hammer `.oss` (`unit.script:7008`). AAF has no loop flag; loop/one-shot is
  authored in ACL/scripts (`showdebuganimations.inc:143` = loop for construct).
  Smoke is a separate site PFX family (`buildsmoke*.actor`, `pfxbuildsmoke*.aaf`
  idle 1..90), not a channel of the peasant clip. Eight azimuths are camera
  views (`bake_sprites.py:218-238`), never an action.
- **Port trace (observed):** `game.gd:3115` sets `order.type="build"`, but
  `world3d_entities.gd:_unit_action()` (`:1009-1016`) only returns
  `death/walk/idle`; the 0.15 m/s gate (`:199`) forces a stationary builder to
  `idle`. The AAF table is **not** missing (`anim3d.gd:86`), but shipped skins
  export no `construct` frames (`convert_skins.py:69-73`), so a naive
  action-string-only fix would snap frames 186..198 to death frame 149 /
  attack0 frame 237 (`anim3d.gd:546,907-912`). The 2D sibling already maps build
  → construct (`world.gd:489`).
- **Ranking:** (1) missing build-state propagation, (2) missing `construct` skin
  export, (3) speed gate → idle, (4) no tool/smoke presentation, (5) static site
  art. `anim3d` AAF table "missing clip" is refuted.
- **Smallest fix:** two files — `world3d_entities.gd:_unit_action()` (add
  build/repair → construct, mirroring `world.gd:489-490`) and
  `convert_skins.py` + regenerated skin JSON (add `construct`, expected frames
  `[186,188,191,193,196,198]`). No `anim3d.gd` change. Discriminating test:
  `pose_for(...,"construct", f/30)` must yield those six frames and never
  149/237; a build-order sync capture must show `|aconstruct|` batches and zero
  builder idle frames.
- **Labels preserved:** `PORT APPROXIMATION — NOT DONOR PARITY`,
  `visual = "UNVERIFIED"`. No donor parity, rendered-frame or engine-behaviour
  claim is made. No code, asset, config or test was edited; no runner job was
  started; no donor binary was executed or copied.

*End of BUILD-ANIM-DIAG-01 report.*
