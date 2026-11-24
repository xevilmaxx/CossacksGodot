---
id: V7-64
owner: V7-64
date: 2026-11-24
mode: "atomic builder — ONE owned code file edited + ONE report written; temporary probe created, run, then deleted"
file: variant3d/scripts/anim3d.gd
report: docs/coord_swarm_2026-11-24/reports/V764_donor_morph_anim.md
scope: "SINGLEPLAYER SKIRMISH ONLY — per-unit animation timing and donor-sampled flat-root morph data; no campaign, missions, cutscenes, DLC or network (WAVE7_3D_VARIANT_CHARTER.md:37-38)"
governing_rule: "Leverage existing DONOR code — do not invent; every donor-derived constant cites donor path:line or is UNVERIFIED (WAVE7_3D_VARIANT_CHARTER.md:29-36)"
donor: "C:\\Games\\Cossacks 3 (private use; bytes/ASCII read-only; no donor binary run or copied into repo)"
contract: "docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:17 — bind(game, entities) / play(e, action, t) signatures unchanged"
no_rng: true
tabs: true
sprite_sheets: false
bake_outputs: false
godot_runs: "variant3d runner ticket 80 (v764-anim3d-parse) exit 0; ticket 82 (v764-anim3d-probe) exit 0, 17/17 checks PASS — see §5"
status: "IMPLEMENTED — donor-sampled flat-root morph DATA path (real skinned verts per donor frame); DONOR-PARITY DEFORMATION BLOCKED by absent bone parents; visual UNVERIFIED; entity-module wiring left to a later integration agent"
---

# V7-64 — `anim3d.gd`: donor-sampled morph/pose animation

## 1. Honest verdict up front

- **DONE, DATA-LEVEL:** `anim3d.gd` no longer only computes a frame number. It now
  contains a GDScript translation of the *readable* donor skin pipeline
  (`bake_sprites.read_oss` → `qmat` → `skin` → `sample`) and returns the **actual
  skinned vertex array** for the resolved donor AAF frame. A real donor sample
  (peasant `walk` frames 1 and 10) moves **577/577** vertices, max **0.29530 m**,
  mean **0.10366 m** in donor metres (§5). That is real donor motion, not an
  invented keyframe.
- **STILL BLOCKED:** donor-faithful *skeletal* animation. The donor `.oss` has
  flat per-bone tracks but **no bone-parent table**; the skin here applies each
  bone track directly to bind vertices (flat root), exactly as
  `bake_sprites.skin:131-143` does. No joint tree is invented
  (`V72_mesh_conversion_feasibility.md:180-186, :264-284`, Table B1 `:380-386`).
- **LABEL RETAINED:** every status and pose carries
  `PORT APPROXIMATION — NOT DONOR PARITY` (`anim3d.gd:55`) plus
  `BLOCKED_RIG` (`:58`) and `visual = "UNVERIFIED"` (`:153, :173, :459`).
- **NOT YET VISIBLE IN PLAY:** this agent owns only `anim3d.gd`. The entity
  module still renders a static bind pose
  (`world3d_entities.gd:41-50, :75, :81-82, :555-590`). The exact handoff for a
  later integration agent is in §4. **No visual parity is claimed.**

## 2. Exact readable / unreadable split (with citations)

### READABLE and translated this pass

| Donor fact | Citation | Where used in `anim3d.gd` |
|---|---|---|
| `.oss` 24-byte header `<6i k,fps,b,v,fc,t>`; all little-endian float32 | `C:\Games\Cossacks 3\data\actors\units\peaukr.oss` byte 0; `docs/decomp/DC_FORMATS.md:44, :46-64` (table `:62` gives the exact 312,376-byte closure) | `parse_donor_oss()` `:193-263`; header sanity `:209-214` |
| `v × <3f>` verts, `fc × <3i>` faces, `t × <2f>` UVs, `fc × <3i>` UV faces, then `v` weight lists (`<i f>` bone+weight pairs), then `b × k × <7f>` bone tracks | `docs/decomp/DC_FORMATS.md:55`; `variant3d/tools/bake_sprites.py:91-103` (`read_oss`) | `parse_donor_oss()` `:216-262`; faces/UVs **skipped by seek**, never synthesised (`:222`) |
| Measured peaukr header: `k=483, fps=30, b=20, v=577, fc=921, t=733`, 584 weight pairs, exact size closure | `docs/decomp/DC_FORMATS.md:62`; independently re-measured this pass read-only (GDScript probe + Python cross-check) | probe result §5 |
| Donor rotations apply **transposed** (row-vector convention) | `bake_sprites.py:118-129` (`qmat`, verified bone by bone); `docs/decomp/DC_FORMATS.md:64` | `_qmat()` `:525-537` — flattened row-major transpose, identical maths |
| Flat-root skin: `Σ w · (M·bind_vertex + bone_pos)`, no parent matrix | `bake_sprites.py:131-143` (`skin`) | `skin_vertices()` `:353-402` |
| Optional bone-0 root rebase `(x,y) − (root_frame − root_ref)` | `bake_sprites.py:310-317, :319-342` (root = bone 0 = hips/pelvis) | `skin_vertices(..., ref_frame >= 0)` `:370-377` — default `-1` = exact `skin` output |
| Donor-order frame decimation, Python `round()` half-to-even | `bake_sprites.py:145-152` (`sample`) | `sample_frames()` `:404-426`, `_py_round_i()` `:539-548` |
| 18 named clips, inclusive ranges, 30 fps cadence | `data\animations\aaf\peaukr.aaf:3-20` (`walk 1..20` at `:5`); `docs/decomp/DC_FORMATS.md:96-109`; prior V7-18 report §3 | `AAF_ACTIONS` `:63-84`, `_frame_at()` `:514-523` |
| Morph index `i` equals shipped OBJ vertex `i` | both readers consume the same first vertex block: `bake_sprites.py:94` and `convert_models.py:43-66, :109-125`; `AUDIT3D_01_models.md:57` | `MORPH_COORD` `:98`; handoff §4 |

### UNREADABLE / UNVERIFIED — deliberately NOT invented

| Gap | Citation | Consequence here |
|---|---|---|
| Donor **bone parent hierarchy** absent; `.oss` tracks are flat | `V72_mesh_conversion_feasibility.md:180-186, :264-284`, Table B1 `:380-386`; `AUDIT3D_08:56, :98` | `BLOCKED_RIG` `:58`; only flat-root skin is emitted; no glTF joint tree |
| Donor→Godot quaternion convention uncited | `V72...:184-186` open question 2; `V718_anim3d.md:99-101` | `skin_vertices` mirrors donor `qmat` verbatim; whether the Y-up entity needs a further convention swap is **UNVERIFIED** |
| AAF loop/clamp flag absent (rows carry only `morph`) | `peaukr.aaf:3-20`; `V718_anim3d.md:96-98` | `_frame_at` loops with deterministic `fposmod`; one-shot `death` will wrap unless caller overrides — **UNVERIFIED** |
| Attached tools are separate `.oss` meshes, not part of the body mesh | `bake_sprites.py:343-353, :360-390` | body morph only; tool motion not delivered (open question 3) |
| Only `peaukr` skin was fed to the probe; other sids not embedded | `V718_anim3d.md:106-108` | `pose_for` returns honest `donor_timing_only` for unregistered sids (`:469-478`) |
| **Visual parity** unproven | `AUDIT3D_08:18-24, :92-102`; `AUDIT3D_01:179-182` | all statuses `visual = "UNVERIFIED"`, `verified = false` |

## 3. What changed in `anim3d.gd` only

| Function | Line | Donor source copied (no invention) |
|---|---|---|
| `bind`, `play`, `action_info`, `_frame_at`, `_unknown`, `_publish` | `114, 123, 496, 514, 664, 685` | V7-18 signatures preserved; `play` now also publishes morphed verts |
| `parse_donor_oss` | `193` | `bake_sprites.py:91-103` read_oss; byte-closure checked |
| `register_skin`, `has_skin`, `unregister_skin`, `skin_info`, `load_skin_from_donor` | `269, 286, 290, 294, 315` | sid → normalised packed skin registry |
| `capabilities` | `323` | machine-readable readable/unreadable split |
| `skin_vertices` | `353` | `bake_sprites.py:118-143` qmat + skin (+ optional `:310-342` rebase) |
| `sample_frames`, `_py_round_i` | `404, 539` | `bake_sprites.py:145-152` |
| `pose_for` | `428` | **handoff API** (§4) |
| `_morph_fields`, `_valid_skin`, `_normalise_raw` | `469, 562, 584` | strict validation; raw JSON in `read_oss` shape accepted; no default/fill values |

No other file was edited. `world3d_entities.gd`, `world3d.gd`, `app/`, tests,
config and git were not touched. No sprite sheet, PNG bake, 2D bake output,
RNG or invented keyframe is used; indentation is tabs only (static check:
689 lines, 0 space-indented lines, 0 `randf`/`randi`/`RandomNumberGenerator`,
0 `index.json` references).

## 4. API and exact integration handoff (for the later integration agent)

### Owned public methods

```
bind(game, entities) -> void                       # unchanged V7-18 contract
play(e, action, t) -> Dictionary                   # unchanged signature; richer pose
action_info(action) -> Dictionary                  # unchanged
register_skin(sid, skin: Dictionary) -> bool       # normalised OR raw read_oss-shaped dict
has_skin(sid) -> bool
unregister_skin(sid) -> void
skin_info(sid) -> Dictionary
load_skin_from_donor(sid, path: String) -> bool    # tools/probes only, not shipped runtime
capabilities() -> Dictionary
parse_donor_oss(path: String) -> Dictionary        # read-only donor translation
skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVector3Array
sample_frames(first: int, last: int, n: int) -> Array[int]
pose_for(e, action, t) -> Dictionary               # THE PER-UNIT HANDOFF CALL
```

`e` in `pose_for`/`play` may be an entity `Dictionary` (uses its `sid`), an
`Object` with a `sid` property, or a sid `String` (`_sid_of`, `:551-560`).

### Exact handoff call

```gdscript
# bootstrap (once, alongside world3d_entities.bind)
var anim3d = load("res://scripts/anim3d.gd").new()
add_child(anim3d)
anim3d.bind(game, world3d_entities)
# skin data must come from an OFFLINE-converted donor .oss asset (read_oss
# shape or normalised shape). Never read C:\Games\Cossacks 3 at shipped runtime.
anim3d.register_skin("peasant", skin_dict)

# per unit, per sim frame, from the entity renderer's sync(dt)
var pose: Dictionary = anim3d.pose_for(e, action_name, t)
# pose["verts"]       : PackedVector3Array — donor Z-up metres, 577 for peaukr,
#                       vertex i == assets/models/obj/<sid>.obj vertex i
# pose["pose_source"] : "donor_flat_root_morph" | "donor_timing_only"
# pose["frame"]       : resolved inclusive donor AAF frame
# pose["range"]       : [first, last]; pose["fps"] = 30.0
# pose["label"]       : "PORT APPROXIMATION — NOT DONOR PARITY"
# pose["rig"]         : BLOCKED_RIG; pose["visual"] = "UNVERIFIED"
# pose["coord"]       : MORPH_COORD; empty verts when pose_source == timing_only
```

`play(e, action, t)` does the same **and** writes the pose to
`e["anim3d_pose"]` (or Object metadata `anim3d_pose`) under key `POSE_KEY`
(`:91`, `:685-689`), preserving the V7-18 integration seam. Prefer `pose_for`
for per-frame work: `play` stores a full vertex array on each entity.

### Applying `verts` to the 3D mesh (integration agent's job)

The entity's cached mesh is already baked by
`world3d_entities._bake_mesh:217-270` from the **same** bind vertices. Recompute
each vertex with that exact transform rather than inverting the baked mesh:

```
donor (x, y, z) -> Vector3((x - cx) * s, (z - z0) * s, -(y - cy) * s)
```

where `cx, cy, z0, s` come from the manifest bbox and `ENV_SCALE`
(`world3d_entities.gd:226-244`). `world3d_entities` currently batches units by
sid into one shared `MultiMesh` (`:321-336`); per-unit morphs therefore need a
per-pose batch, per-instance vertex texture, or per-unit `MeshInstance3D`.
That renderer choice is intentionally left to the integration agent.

## 5. Verification (variant3d runner only)

Both jobs went through `variant3d/tools/godot_runner.py run` (FIFO lock + hard
timeout). No direct Godot invocation.

1. **Parse gate — ticket 80, id `v764-anim3d-parse`, status `ok`, exit 0.**
   ```
   python variant3d\tools\godot_runner.py run --id v764-anim3d-parse --timeout 90 -- \
     --headless --path variant3d --check-only --script res://scripts/anim3d.gd
   ```
   wait 17.83 s, run 3.82 s. stdout = Godot 4.7.2 banner only; stderr empty.
   Spool: `variant3d/.godot_queue/results/00000080.json`.

2. **Behaviour probe — ticket 82, id `v764-anim3d-probe`, status `ok`, exit 0,
   17/17 checks PASS.** Temporary file `variant3d/tests/_v764_probe.gd` loaded
   `anim3d.gd`, called `parse_donor_oss` on the real read-only donor
   `C:/Games/Cossacks 3/data/actors/units/peaukr.oss`, registered it as sid
   `peasant`, and asserted morph data changes between donor frames. Result
   spool: `variant3d/.godot_queue/results/00000082.json` and
   `.../00000082_v764-anim3d-probe/stdout.txt`. **The probe and its result JSON
   were deleted after the run** (verified: no `*v764*` file remains under
   `variant3d/tests/`).

   Measured values:

   | Check | Measured |
   |---|---|
   | Real donor header | `k=483`, `fps=30`, `bones=20`, `v=577`, `bytes=312376` (exact size closure, `docs/decomp/DC_FORMATS.md:62`) |
   | Skinned verts at donor walk frame 1 / 10 | 577 / 577 |
   | Vertices changed between frames 1 → 10 | **577 / 577** |
   | Max per-vertex displacement | **0.295301526784897 m** donor space |
   | Mean per-vertex displacement | **0.103663814617272 m** donor space |
   | `pose_for("peasant","walk",0.3)` | `frame=10`, `pose_source=donor_flat_root_morph`, 577 verts |
   | `play(...)["anim3d_pose"]["verts"]` | 577 verts, label exact, `visual` begins `UNVERIFIED` |
   | `sample_frames(1,20,12)` | `[1,3,4,6,8,10,11,13,15,17,18,20]` (donor order, matches `bake_sprites.sample`) |
   | Unregistered sid fallback | `pose_source=donor_timing_only`, empty verts |

   Independent read-only Python re-implementation of `read_oss`+`skin` gave the
   same delta (max 0.2953, mean 0.10366), cross-checking the GDScript math.
   **This proves the pose *data* changes; it does NOT prove a rendered frame
   matches the donor.** No screenshot or visual A/B was performed.

## 6. Open questions

1. Will the integration agent supply converted `.oss` skin assets per sid, and
   in which form (normalised packed dict or raw `read_oss`-shaped JSON)? Both
   are accepted; the shipping path must not read the private donor install.
2. Is a donor-readable bone-parent table hidden in `animations/ref/*` or an
   `.actor`/`.lib` refkey chain? `AUDIT3D_08:171-175` and `V718_anim3d.md:133-137`
   found none. Until cited, donor-parity skin stays BLOCKED.
3. Attached hand tools are separate donor meshes (`bake_sprites.py:343-353`):
   should the morph path also skin `attach/<base>_<tool>.oss`, or accept
   empty-handed 3D peasants as an explicit approximation?
4. Does the Y-up entity need a quaternion-convention swap on top of
   `bake_sprites.qmat` (`:118-129`)? Uncited; requires a rendered-frame A/B.
5. Which renderer strategy will carry per-unit morphs through the shared
   `MultiMesh` batches (`world3d_entities.gd:321-336`) — per-pose batch,
   vertex texture, or per-unit `MeshInstance3D`? Cost/perf is UNVERIFIED.
6. Should one-shot actions clamp instead of loop? AAF has no loop flag
   (`peaukr.aaf:3-20`); current `fposmod` wrap remains an UNVERIFIED port policy.

---

*V7-64, singleplayer-skirmish scope. One owned code file edited and one report
written; temporary probe deleted. Donor-parity skeletal deformation is NOT
claimed: the delivered morph is a donor-sampled flat-root approximation,
labelled `PORT APPROXIMATION — NOT DONOR PARITY`, visual result UNVERIFIED.*
