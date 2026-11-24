---
owner: V7-18
date: 2026-11-24
mode: atomic builder — ONE new code file + this report
file: variant3d/scripts/anim3d.gd
report: docs/coord_swarm_2026-11-24/reports/V718_anim3d.md
scope: "SINGLEPLAYER SKIRMISH ONLY — action timing for units; no campaign, missions, cutscenes, DLC or network (WAVE7_3D_VARIANT_CHARTER.md:37-38)"
governing_rule: "Leverage existing DONOR code — do not invent; every 3D constant cites donor path:line or is UNVERIFIED (WAVE7_3D_VARIANT_CHARTER.md:29-36)"
donor: "C:\\Games\\Cossacks 3 (private use, ASCII/bytes read-only; no donor binary run or copy)"
contract: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:17
dependency: docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md
no_rng: true
tabs: true
sprite_sheets: false
bake: false
godot_runs: "variant3d runner ticket 19 v718-anim3d-check2, --check-only parse, exit 0 (see §5)"
status: "IMPLEMENTED — donor-timed pose clock; donor-parity skeletal animation BLOCKED; visual result UNVERIFIED"
---

# V7-18 — `anim3d.gd`: donor-timed action/pose clock for the 3D variant

## 1. Verdict up front

- **DONOR-BACKED:** the 18 action names and their inclusive donor frame ranges,
  and the donor 30 fps cadence, are copied from readable donor files. `play()`
  maps a sim time `t` to the exact donor frame with no RNG and no invented fps.
- **BLOCKED:** donor-faithful *skeletal* animation. V7-2 proved the `.oss` skin
  payload is readable but the **bone parent hierarchy is absent**; glTF needs a
  joint tree, and inventing one is forbidden
  (`V72_mesh_conversion_feasibility.md:180-186`, `:264-284`, Table B1 `:380-386`).
- **PORT APPROXIMATION — NOT DONOR PARITY:** the only permitted pose path
  (`V72_mesh_conversion_feasibility.md:305-311`, Table C `:400-410`;
  `WAVE7_3D_VARIANT_CHARTER.md:54-57`). This module publishes a donor-timed
  pose request onto the entity; it does **not** claim donor-parity deformation.
- **UNVERIFIED:** the visual result. No donor-readable bone hierarchy, no
  donor→glTF quaternion convention citation, no morph/skin GLB in the project,
  and AAF has no loop flag. Every `play()` status therefore carries
  `visual = "UNVERIFIED"` and `verified = false`.

No sprite sheet, no atlas, no bake and no RNG is used. The module never opens
`res://assets/models/anim/**` or any `index.json`.

## 2. Exact API implemented

Per `V73_ATOMIC_CONTRACT.md:17`:

| Method | Signature | Behaviour |
|---|---|---|
| `bind` | `bind(game, entities) -> void` | Stores the sim and 3D entity-renderer references. No rig data is fabricated. |
| `play` | `play(e, action, t) -> Dictionary` | Resolves donor AAF range, computes frame at 30 fps, publishes pose request, returns honest status. |

Helper methods (extra, non-contract): `action_info(action) -> Dictionary`;
internal `_frame_at`, `_unknown`, `_publish`. No `class_name`; loaded dynamically
as `load("res://scripts/anim3d.gd")` like the other atomic modules
(`V73_ATOMIC_CONTRACT.md:28-30`).

Pose request written to entity Dictionary key `anim3d_pose` (or Object metadata
for a Node3D entity), containing: `action`, `requested`, `frame`, `fps`, `range`,
`donor`, `kind`, `label`, `rig`, `visual`, `verified`. A 3D entity renderer may
consume `frame` to drive a sampled pose if/when morph assets exist; until then
the value is timing metadata only.

## 3. Donor citations (every constant)

| Constant in `anim3d.gd` | Donor source (read-only) | Repo decode / evidence |
|---|---|---|
| `DONOR_FPS = 30.0` | `data\actors\units\peaukr.oss` byte 0, `<6i k,fps,b,v,fc,t>` | `docs/decomp/DC_FORMATS.md:46-64`; `V72_mesh_conversion_feasibility.md:159` (k=483, fps=30, b=20, exact size closure), `:163-165` |
| `AAF_ACTIONS["idle"] = [64,113,3,"morph"]` | `data\animations\aaf\peaukr.aaf:3` | AAF dialect: `docs/decomp/DC_FORMATS.md:96-109`; `V72...:167-170` |
| `walk = [1,20,5,"morph"]` | `data\animations\aaf\peaukr.aaf:5` | same; V7-2 cites `walk 1..20` at `:56`, `:167-170` |
| `death = [115,149,6,"morph"]` | `...peaukr.aaf:6` | `V72...:167-170` |
| `attack0 = [237,254,7,"morph"]` | `...peaukr.aaf:7` | `V72...:167-170` |
| `workfood/workwood/workstone` | `...peaukr.aaf:8-10` | `V72...:167-170` |
| `idlefood/idlewood/idlestone` | `...peaukr.aaf:11-13` | direct read this pass, lines 11-13 |
| `walkfood/walkwood/walkstone` | `...peaukr.aaf:14-16` | direct read this pass, lines 14-16 |
| `construct/reaction` | `...peaukr.aaf:17-18` | `V72...:167-170` |
| `prepare0/unprepare0` | `...peaukr.aaf:19-20` | direct read this pass, lines 19-20 |
| inclusive bounds + frame sampling | `...peaukr.aaf:3-20` (`"name",start,end,morph`) | `docs/decomp/DC_FORMATS.md:109` (inclusive); `variant3d/tools/bake_sprites.py:105-116` (read_aaf), `:145-152` (donor-order decimation) |
| `PORT_LABEL` | `WAVE7_3D_VARIANT_CHARTER.md:54-57` | `V72...:305-311`, `:400-410` |
| `BLOCKED_RIG` | `.oss` tracks are flat, no parent indices | `V72...:180-186`, `:264-284`, Table B1 `:380-386` |

The AAF file was read directly this pass: 20 lines, line 2 = `18`, 18 quoted
action rows on lines 3-20. All 18 names/ranges in the module match those lines
verbatim. No donor binary was executed.

## 4. Honest limitations (BLOCKED / APPROXIMATION / UNVERIFIED)

1. **BLOCKED — bone hierarchy.** `.oss` stores flat per-bone tracks
   (`docs/decomp/DC_FORMATS.md:46-64`); no parent table was found. No rig is
   constructed and no bone transform is applied by this module.
2. **PORT APPROXIMATION — sampled-pose timing only.** The frame clock is donor
   exact (AAF range + 30 fps), but it selects a *donor frame index*; it does not
   skin a mesh. Labelled in every status and by the constant `PORT_LABEL`.
   Per V7-2 this is acceptable only as an explicitly labelled approximation.
3. **UNVERIFIED — loop semantics.** AAF rows carry only the token `morph`;
   there is no loop/clamp field (`peaukr.aaf:3-20`). `play()` loops the span with
   deterministic `fposmod` and reports this assumption as UNVERIFIED; a one-shot
   such as `death` will wrap unless a caller overrides. Do not claim donor parity
   for wrap behaviour.
4. **UNVERIFIED — quaternion convention.** `bake_sprites.qmat` uses a transposed
   donor rotation (`bake_sprites.py:118-129`); whether glTF needs the same is
   uncited (`V72...:184-186`, open question 2). This module applies no rotation.
5. **UNVERIFIED — asset availability.** No donor-faithful skinned GLB and no
   morph-target GLB exists yet (`V72...:82-84`, `:264-284`, Table B1). If no
   consumer reads `anim3d_pose`, `play()` is effectively a no-op beyond the
   status/pose metadata — reported as such, never as working skeletal animation.
6. **UNVERIFIED — other sids.** Only `peaukr.aaf` was read this pass. Other
   donor AAF files are not embedded; an unknown action returns `ok=false` with a
   `donor = "UNVERIFIED ..."` reason instead of guessing a range.

## 5. Verification

- Parse gate: `python variant3d\tools\godot_runner.py run --id v718-anim3d-check2
  --timeout 90 -- --headless --path variant3d --check-only --script
  res://scripts/anim3d.gd` — **PASS**, runner ticket 19, exit 0, status `ok`
  (run 4.95 s, waited 139.85 s behind the shared FIFO). stdout is just the
  Godot 4.7.2 banner; stderr has no script errors. Result spool:
  `variant3d/.godot_queue/results/00000019_v718-anim3d-check2/`.
- First parse attempt (`v718-anim3d-check`, ticket 8) failed on two GDScript
  inferred-type errors at lines 100-101 (`ACTION_ALIAS.get` returns Variant);
  fixed by declaring `donor_action: String` and `aliased: bool`. No other files
  touched.
- Static hygiene re-checked with Python (UTF-8): 203 lines, tab-only indentation,
  no `randf`/`randi`/`RandomNumberGenerator`, no `index.json`, exact label
  `PORT APPROXIMATION — NOT DONOR PARITY` present.
- No behavioural/runtime test was added: this agent owns exactly one code file
  and one report, and the atomic test atoms are a separate agent
  (`V73_ATOMIC_CONTRACT.md:26-30`). Frame math was checked arithmetically:
  `walk 1..20` has span 20 → 0.6667 s at 30 fps; `t=0` → frame 1,
  `t=0.5` → frame 16, `t=0.667` → frame 1 (wrap, flagged UNVERIFIED above).
  `attack` resolves via PORT-level alias to `attack0 237..254` (7 lines →
  0.6 s), alias recorded in the returned status.

## 6. Open questions

1. Is there a donor-readable bone-parent table (`.actor`, `.lib` refkey chain,
   `data\animations\ref\*`) that V7-2's flat `.oss` reader missed? Until cited,
   donor-faithful skinning stays BLOCKED (`V72...` open question 1, `:423-427`).
2. Which sampled-pose consumer will read `anim3d_pose`, and will morph-target
   GLBs be produced? Without one, the visual result remains UNVERIFIED.
3. Should one-shot actions (`death`, `attack0`, `prepare0`, `unprepare0`) clamp
   instead of loop? AAF has no loop flag; a port-level policy needs owner sign-off
   and must still be labelled approximation.
4. Do the other 245 `.aaf` files need embedding, or will `action_info` be
   extended to read a curated singleplayer-sid AAF set at bind time?
5. Does the sim pass an action name this module maps through `ACTION_ALIAS` for
   anything beyond `attack → attack0`? Unmatched names return `ok=false` by
   design (no invented frame range).

---

*V7-18, atomic builder, singleplayer-skirmish scope. One code file and one report
only. Donor-faithful skeletal animation is NOT claimed; all pose output is
labelled PORT APPROXIMATION — NOT DONOR PARITY with UNVERIFIED visual result.*
