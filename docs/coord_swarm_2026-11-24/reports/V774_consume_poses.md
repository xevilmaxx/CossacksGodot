---
id: V7-74
owner: V7-74
date: 2026-11-24
mode: "atomic builder — ONE owned code file edited + ONE report written; temporary probe created, run, then deleted"
file: variant3d/scripts/world3d_entities.gd
report: docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md
scope: "SINGLEPLAYER SKIRMISH ONLY — consume anim3d.gd donor flat-root morph data for units; no campaign, DLC, network, sprite sheets, invented keyframes or RNG (WAVE7_3D_VARIANT_CHARTER.md:37-53)"
governing_rule: "AUDIT3D_CHARTER.md:6-15 — path:line evidence, OBS vs INFERENCE, UNVERIFIED labels, smallest donor-grounded fix, no git operations"
owns: ["variant3d/scripts/world3d_entities.gd", "docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md"]
no_rng: true
tabs: true
sprite_sheets: false
handoff: "V764_donor_morph_anim.md §4 — anim3d.gd.pose_for(e, action, t) -> pose['verts']"
status: "IMPLEMENTED — units visibly re-morph between donor AAF frames when a donor skin is registered; donor flat-root ONLY, visual = UNVERIFIED, NO visual-parity claim"
godot_runs: "variant3d/tools/godot_runner.py only — tickets 136,154,162 (parse ok); 161 (probe ok 20/20); 163 (selftest ok, passed:true 29/29). Development tickets 139,142,146,150,156,159,160 failed and were superseded — see §5."
---

# V7-74 — consume donor poses in `world3d_entities.gd`

## 1. Honest verdict up front

- **DONE, MEASURABLE:** the entity renderer now calls
  `anim3d.pose_for(e, action, t)` once per unit per `sync(dt)` and rebuilds that
  unit's mesh from the returned **real donor-sampled flat-root verts**. In a
  headless probe that registered the real read-only donor
  `peaukr.oss`, a unit's rendered vertex buffer changed **733/733 vertices**
  between donor `walk` frame 1 and frame 10, max displacement
  **0.295301526784897 m**, mean **0.10651640705561 m** (§5). The max matches
  V7-64's donor-space max (`0.295301526784897 m`, V764 §5) exactly.
- **STILL NOT DONOR PARITY:** the deform is **flat-root** (donor bone parents
  are unreadable — V7-2 §3.3 / Table B1), normals are generated from the
  morphed faces (the `.oss` carries no normals), and the Godot UV V-flip is a
  port convention. Every status/meta field carries
  `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = "UNVERIFIED"`.
- **NO VISUAL CLAIM:** no screenshot, frame A/B or donor render comparison was
  performed. "Visible meshes change" is proved numerically on the **rendered
  vertex buffer**, not by looking at a picture.
- **SHIPPED-RUNTIME CAVEAT:** no converted skin asset is registered by
  `world3d.gd` today (no skin JSON exists under `variant3d/data/`). With no
  registered skin, the module keeps the exact V7-14/V7-65 static bind-pose path.
  Wiring a converted skin asset is outside this file's ownership (open Q1).

## 2. V7-64 handoff citation (the API consumed)

V764 report §4 (`docs/coord_swarm_2026-11-24/reports/V764_donor_morph_anim.md:90-155`) specifies:

- owned handoff call at `:107` — `pose_for(e, action, t) -> Dictionary` (defined
  at `variant3d/scripts/anim3d.gd:428-465`);
- per-unit `sync(dt)` call with `pose["verts"]`, `pose["pose_source"]`,
  `pose["frame"]`, `pose["label"]`, `pose["rig"]`, `pose["visual"]` at `:113-134`;
- "Applying `verts` to the 3D mesh" at `:141-155`: the entity's cached mesh is
  baked by `_bake_mesh` from the same bind vertices, so recompute each vertex as
  `donor (x,y,z) -> Vector3((x-cx)*s, (z-z0)*s, -(y-cy)*s)` rather than inverting
  the baked mesh; the renderer choice (per-pose batch / vertex texture /
  per-unit mesh) is explicitly left to the integration agent (`:152-155`);
- `invoked e` may be the entity Dictionary (`anim3d.gd:551-560`), which is what
  this module passes.

**Renderer choice made here:** per-pose batching (V764 `:154` first option),
which preserves MultiMesh batching and V7-65's per-player tint split. A
per-instance vertex texture was rejected as UNVERIFIED in headless Godot 4.7;
a per-unit `MeshInstance3D` would destroy mass-army batching (§6).

## 3. Exact diff — `variant3d/scripts/world3d_entities.gd` only

All line numbers are final post-edit. V7-65's donor tint work (`KEY_COLORS_PATH`,
`_load_key_colors`, `_player_tint`, `_tinted_material`, `_apply_tint`, tinted
batch keys, tinted building overrides) is **untouched**.

| Final line(s) | Change |
|---|---|
| 41-56 | Header ANIMATION block rewritten: documents real donor flat-root morph consumption, batching strategy, retained label and static fallback. |
| 88-94 | New `PORT_LABEL` (exact V7-64 text, em dash), rewritten `ANIM_STATUS` (now `DONOR-SAMPLED FLAT-ROOT MORPH — PORT APPROXIMATION — NOT DONOR PARITY … visual UNVERIFIED`), `MORPH_POSE_SOURCE`, `MORPH_ACTION_MAP`. |
| 112-124 | New state: `_anim` / `_anim_checked` (discovered anim3d sibling), `_morph_meshes` (sid\|action\|frame cache), `_obj_topology` (source OBJ topology cache). |
| 137-144 | `bind()` resets all three caches/discovery state. |
| 186-193 | `bind()` stats gains `donor_morph_api`, `donor_morph_label`, `donor_morph_visual`, `donor_morph_rig`, `donor_morph_coord`, `donor_morph_action_map`, `donor_morph_normals` — all explicit UNVERIFIED labels. |
| 478-504 | `_find_anim()` — discovers the anim3d module once among the composed world's children (`world3d.gd:152-165` `add_child`s all modules under one Node3D). No edit to `world3d.gd` needed; atomic tests with a bare stub have no anim sibling and keep the static path. |
| 506-517 | `_unit_action(ed)` — deterministic PORT policy `dead→death / moving→walk / else idle`; all names are real AAF entries (`anim3d.gd:64,66,67`; `peaukr.aaf:3-5`). No keyframe invented: frame+verts still come from `pose_for`. |
| 519-567 | `_load_obj_topology(sid)` — parses the donor-converted `assets/models/obj/<sid>.obj` once per sid (577 `v`, 733 `vt`, 921 `f` for peasant; `convert_models.py:43-66,109-125`). Needed because Godot's importer de-indexed peasant to **719** vertices, so the imported buffer cannot be addressed by the 577 donor indices (OBS, probe diagnosis). On missing/malformed OBJ it returns empty and the caller keeps the static pose. |
| 569-659 | `_morph_mesh(sid, info, frame, action, verts)` — rebuilds one mesh from donor verts via the exact V764 §4 transform, with donor OBJ faces/UVs, generated normals, donor albedo material. Strict rejection (empty result + reason) on any count/index mismatch; never fills/guesses a vertex. Cached per sid\|action\|frame. |
| 662-691 | `_new_batch(key, info, cls, pose = {})` — internal 4th param; morph batches get `MORPH_a<action>_f<frame>` node names and meta `donor_pose_source`, `donor_frame`, `donor_action`, `donor_label`, `donor_visual`; batch dict gains `morph` flag. Static batches are byte-for-byte unchanged. |
| 693-720 | `_acquire(..., pose: Dictionary = {})` — internal 7th param; slot now retains `tint`, `player`, `pose_source`, `frame`, `action` so a frame change can re-acquire the exact batch. Existing callers unaffected. |
| 722-762 | `_release()` — empty **morph** batches are kept alive (no draw: `visible_instance_count == 0`) to avoid free/create churn; empty static batches are still freed synchronously, so V7-34 node-count lifecycle checks still pass. |
| 940-1058 | `sync(dt)` — Pass 1 samples `pose_for` per unit and migrates it to `unit|<sid>[\|p<player>]\|a<action>\|f<frame>`; Pass 2 is the unchanged transform loop; stats gain measured morph telemetry; `anim_handoff` gains `applied/morph_units/label/visual`. |

**Six public signatures unchanged:** `bind(game)`, `sync(dt)`, `add_unit(e)`,
`add_building(e)`, `add_resource(n)`, `remove(id)` — exactly the V7-65/V7-62
surface (`bind()` stats `api` list at `:135-137` untouched). Batching (one
MultiMesh per key with `BATCH_CAPACITY` slots, CPU transform mirror,
swap-remove) remains intact; only the key gains an action/frame suffix when a
real morph exists.

## 4. How a frame becomes a mesh (deterministic, no RNG)

1. `_anim_t += maxf(dt, 0.0)` (`sync:944`) — sim clock only.
2. `_unit_action(ed)` picks a real AAF name from sim booleans (`_refs` entity).
3. `anim.pose_for(ed, action, _anim_t)` resolves the inclusive donor frame with
   the donor 30 fps `fposmod` clock (`anim3d.gd:514-520`) and skins the
   registered donor verts at that frame (`anim3d.gd:353-402`).
4. Only a pose with `pose_source == "donor_flat_root_morph"` and non-empty
   `verts` is accepted. Anything else (unregistered sid, unknown action,
   structural mismatch) leaves the unit on its static bind batch — no
   interpolation, no sprite, no invented motion.
5. `_morph_mesh` applies the V764 §4 transform and reuses donor OBJ faces/UVs;
   the unit is swapped into the matching frame batch via `_release`/`_acquire`.

## 5. Verification — variant3d runner only (job ids + measured results)

Every Godot launch went through `variant3d/tools/godot_runner.py run`.
No direct Godot invocation, no git command.

| Ticket | Job id | Command / purpose | Result |
|---|---|---|---|
| 136 | `v774-entities-parse` | `--headless --path variant3d --check-only --script res://scripts/world3d_entities.gd` | ok, exit 0, run 1.82 s |
| 139/142/146 | `v774-probe`, `v774-probe2`, `v774-probe3` | first probes | failed — diagnosis: strict bind/donor index match rejected morph (`bind=719 donor=577`); superseded |
| 150 | `v774-parse2` | parse after OBJ-topology rewrite | failed — `_obj_topology` var/func name collision (OBS from stderr); superseded |
| 154 | `v774-parse3` | parse after rename to `_load_obj_topology` | ok, exit 0, run 2.82 s |
| 156 | `v774-probe4` | probe after topology rewrite | failed — `ArrayMesh.generate_normals()` does not exist in Godot 4.7; superseded by computed face normals |
| 159/160 | `v774-probe5`, `v774-probe-final` | probes | failed only on one probe assertion (`stats` Dictionary read by reference, so both snapshots showed frame 10); code path itself passed all other checks |
| **161** | **`v774-probe-pass`** | temporary `variant3d/tests/_v774_probe.gd`: real donor `peaukr.oss` skin registered at runtime, one `peasant` unit added, `sync(0.0)` then `sync(0.3)` | **ok, exit 0, run 2.39 s, 20/20 checks PASS** |
| **162** | **`v774-entities-parse-final`** | final parse gate | **ok, exit 0, run 2.31 s** |
| **163** | **`v774-consume-poses`** | mandated full selftest `--headless --path variant3d -- --self-test variant3d/selftest.json` | **ok, exit 0, run 54.82 s; `variant3d/selftest.json` = `passed: true`, 29/29 steps passed, 0 failed; stderr free of parse/instantiate errors** |

Probe result (`variant3d/tests/results/v774_probe.json`, read before deletion):

| Assertion | Measured |
|---|---|
| Real donor skin loaded | `registered=true`, `k=483`, `fps=30`, `bones=20`, `v=577`, `weight_pairs=584` (V764 §5 header) |
| Donor frame resolved at `t=0` / `t=0.3` | walk frame **1** / **10** (`stats.donor_morph_frames` `[1] -> [10]`) |
| Rendered buffer size at both frames | **733 / 733** de-indexed corners (donor OBJ `vt` count) |
| Vertices changed frame 1 → 10 | **733 / 733** |
| Max per-vertex displacement | **0.295301526784897 m** (baked Y-up metres) — identical to V764's donor-space max |
| Mean per-vertex displacement | **0.10651640705561 m** (corner-weighted; V764's 0.10366 is over 577 unique donor verts, hence a different weighting) |
| `pose_source` / batch meta | `donor_flat_root_morph`; meta `donor_frame=10`, `donor_label` and `donor_visual` exact |
| Honest labels | stats `donor_morph_label = PORT APPROXIMATION — NOT DONOR PARITY`, `donor_morph_visual = UNVERIFIED`, `anim_handoff.applied = true` |
| Batch migrations | `donor_morph_frame_changes = 1`, `donor_morph_units = 1`, `donor_morph_static_units = 0`, no rejected meshes |

The probe file and its result JSON were **deleted** after the run (verified:
zero `*v774*` files remain under `variant3d/tests/` or `variant3d/tests/results/`).
`variant3d/selftest.json` was rewritten by the mandated selftest command itself
(generated output, not a source edit).

## 6. Perf / memory tradeoff (explicit, measured where possible)

- **Batch fan-out:** static rendering used 1 MultiMesh per
  `(sid, player slot)`; morph rendering uses 1 per
  `(sid, player slot, action, frame)` actually visited. In the probe, 1 unit
  produced 2 batches (frames 1 and 10) at 733 corners each; the empty old frame
  batch is retained for reuse. More distinct simultaneous frames ⇒ more draw
  calls. This is the cost of per-unit morphs without a vertex texture.
- **Mesh memory:** one rebuilt `ArrayMesh` per `(sid, action, frame)`, cached.
  For peasant: 733 corners × (pos 12 B + normal 12 B + UV 8 B) ≈ 23.5 KB plus
  2763 indices × 4 B ≈ 11 KB ⇒ **≈ 35 KB per frame mesh**. Even ~105 visited
  frames (idle 50 + walk 20 + death 35) ≈ 3.7 MB per sid — bounded by visited
  frames because creation is lazy and cached.
- **MultiMesh slot reservation:** `_new_batch` still sets
  `instance_count = BATCH_CAPACITY` (4096) per batch, so each frame batch
  reserves ~256 KB of transform slots. With many frames this dominates mesh
  memory (e.g. ~27 MB for 105 batches). Sizing `instance_count` to demand is a
  possible follow-up but would touch the shared batching path used by V7-65,
  so it was deliberately left out of this atomic change (open Q6).
- **CPU:** `pose_for` is called **per unit per frame** as required, i.e.
  ~577 verts / 584 weight pairs + 20 bone matrices per call. Units sharing an
  action share a frame (common sim clock), but pose calls are not deduplicated
  in this pass. This is the honest cost of the literal per-unit handoff call.
- **Not chosen:** per-unit `MeshInstance3D` (would remove mass-army batching and
  multiply tinted materials); per-instance vertex texture (UNVERIFIED under the
  headless dummy RenderingServer). Both remain open alternatives (V764 §6 Q5).

## 7. Open questions / UNVERIFIED

1. **Skin registration in shipped runtime (BLOCKED for default play).** No
   converted `.oss` skin asset exists in `variant3d/data/`, and `world3d.gd`
   (not owned here) does not call `register_skin`. The probe registered the
   real donor at runtime per V764 §4 ("tools/probes only, not shipped
   runtime"). Which converted asset/path and which form (packed vs raw) should
   ship is an owner decision — V764 §6 Q1.
2. **Action mapping is PORT policy, not donor.** `dead→death / moving→walk /
   else idle` uses real AAF names but the donor's own action-selection logic is
   not in readable text; the sim's `order`/state fields could drive a finer
   map (18 clips in `peaukr.aaf:3-20`). Needs sign-off.
3. **Lockstep frames.** All units use the same `_anim_t`, so units in the same
   action morph in sync. A deterministic per-unit phase offset is possible but
   would be an invented port policy, so it was not added.
4. **Visual parity is UNVERIFIED.** Flat-root only (bone parents unreadable);
   normals generated from morphed faces; tangents unset; UVs use the standard
   Godot V-flip; donor→Godot quaternion convention remains uncited (V764 §6 Q4).
   A rendered-frame A/B is required before any parity claim.
5. **Other sids / multi-surface.** All 172 manifest sids report an OBJ
   available, but only `peasant` was measured. A sid whose OBJ has several
   surfaces or a GLB-only sid (`_bake_mesh` `glb_assumed_yup` path) takes the
   strict-rejection fallback to static pose; verify per sid before claiming
   coverage.
6. **Batch slot reservation** (§6) — consider demand-sized `instance_count`.
7. **One-shot `death` loops** via `fposmod` (AAF carries no loop flag) —
   inherited UNVERIFIED port policy from `anim3d.gd:514-520` (V764 §6 Q6).
8. **Stale inherited comment:** `world3d.gd:490` still describes entities as
   "static bind pose". That file is outside V7-74 ownership, so the comment was
   not changed; its runtime behaviour is unaffected.

## 8. Reply summary

- Files: `variant3d/scripts/world3d_entities.gd` (edited),
  `docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md` (this report).
- STATUS: **COMPLETE — donor pose data consumed; measurable morph;
  no visual-parity claim.**
- Verification: parse ok (tickets 136/154/162), probe 20/20 (ticket 161,
  733/733 verts changed, max 0.295301526784897 m), selftest `passed: true`
  29/29 (ticket 163). Temporary probe deleted.
- No git operations, no edits to `anim3d.gd`, `world3d.gd`, `main.gd`, FX,
  `app/`, tests, config or selftest source.
