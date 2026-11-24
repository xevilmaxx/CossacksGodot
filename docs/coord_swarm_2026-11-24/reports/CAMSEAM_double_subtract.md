---
id: CAM-SEAM
role: "RUNTIME FIX — make the SIM->centred camera handoff IDEMPOTENT (retire the V7-70/V7-81 signature seam)"
owner: CAM-SEAM
date: 2026-11-24
scope: "variant3d/scripts/camera3d.gd + variant3d/scripts/main.gd ONLY, plus this report and two rollback copies under inbox/backup/ (protocol AGENT_PROTOCOL.md:11). No Godot launch, no runner job, no git, no edit to picking3d/input_controller/hud/world3d_terrain/world3d/world3d_fx/entities/app/config/tests."
charter: "COMP-04 Top 5 #1 (docs/coord_swarm_2026-11-24/reports/COMPLETENESS_04_runtime_stability.md:188-193); PROGRESS.md:275-282; V781_minimap_black_fix.md:178 Q1"
status: "CODE COMPLETE — VERIFICATION PENDING. Godot queue intentionally NOT touched (4 other fix agents active); awaiting explicit all-clear from coordinator to run the jobs in §7."
visual_parity_claim: false
---

# CAM-SEAM — idempotent SIM->centred camera handoff

## 1. COMP-04 evidence this fixes

`COMPLETENESS_04_runtime_stability.md` §6 Top 5, item 1 (`:190-193`) ranks this as
the highest remaining runtime risk:

> V7-70/V7-81 seam is signature-based (`main.gd:1008-1016` ↔
> `camera3d.gd:233-237`): a zoom change between the foreign `_target` write and
> the next `_apply_transform()` can double-subtract the half-map offset →
> off-terrain camera / black view. Not covered by the 11/11 constant-zoom probe.

Corroborating evidence cited by COMP-04:

- E6 (`:54`): minimap centre click → black main view; camera `(320,34,374)` off
  the ±320 m centred terrain; V781 fixed it by measurement but **user windowed
  retest is still pending** (`AUDIT3D_TRIAGE.md:56-58`).
- H1 (`:97`): "if a zoom change makes `zoom != _last_clamp_zoom` when the foreign
  memo is written, the guard will not fire and `_apply_transform()` can subtract
  the map half twice → off-terrain focus (black view). The 11/11 probe simulated
  the seam at *constant* zoom."
- §4 item 3 (`:142-144`): "V7-70 seam under zoom changes (H1): probe froze zoom".
- §5 item 3 (`:164-166`): window test "Seam + zoom … watch for a camera snap
  off-terrain — this is the H1 signature-guard failure mode the probe did not
  exercise."
- `PROGRESS.md:275-282`: "CAM-SEAM dispatched … replace with explicit idempotent
  handoff API (mark_external_transform / apply_external_target), preserve all
  recent work, HOLD Godot jobs until queue clear".
- `V781_minimap_black_fix.md:178` Q1 already recommended exactly this handoff:
  "remove `_center_camera3d_target()` and its three call sites … or expose an
  explicit `camera.apply_sim_focus()` seam and stop writing private fields."

The user has already reported a black main view once (task briefing); this is a
real, not hypothetical, failure mode.

## 2. Why the old signature failed

Two coordinate frames exist:

| Frame | Meaning | Owner |
|---|---|---|
| **SIM** | top-left map origin, `[0..MAP_W*TILE_M] × [0..MAP_H*TILE_M]` metres | `_target`, `jump_to_world()`, HUD minimap, `clamp_pos()` limits |
| **centred** | origin-centred world3d mesh, ±320 m for the 320-tile config | terrain/entities meshes, `screen_to_world()`, `global_position` |

`centred = SIM − half`, where `half = Vector2(MAP_W, MAP_H) * TILE_M * 0.5`
(`camera3d.gd:_map_half()`, `main.gd`'s old `centre_offset`).

V7-81 moved the subtraction into `_apply_transform()`, but left V7-70's
`main.gd:_center_camera3d_target()` in place. That helper **also** wrote a
centred `_target` and froze `_last_clamp_target/_last_clamp_zoom`, then called
`_apply_transform()`. The camera could only survive this by *guessing* that a
foreign write had happened, from a three-value signature at old
`camera3d.gd:233-237`:

```gdscript
if _target == _last_clamp_target and _target != _own_clamp_target and zoom == _last_clamp_zoom:
    _target += half   # undo the foreign pre-conversion, then subtract once below
```

Failure mechanics:

1. **`zoom == _last_clamp_zoom` is a value snapshot, not an intent marker.**
   `_last_clamp_zoom` is frozen at the moment of the foreign write; `zoom` is
   live state advanced every frame by `_smooth_zoom()` (`camera3d.gd:621-649`)
   from wheel input. If a wheel event changes `zoom` after the memo freeze and
   before the guarded `_apply_transform()` runs, the equality is false, the
   guard does not fire, and an already-centred `_target` is fed into
   `base = _target − half` → **second subtraction** → focus ≈ another −320 m off
   the centred terrain → black view. The 11/11 probe held zoom constant, so this
   branch was never executed.
2. **`_target != _own_clamp_target` can also misfire.** If the previous own
   clamp memo happens to equal the new centred focus (e.g. small maps / near
   map centre where SIM ≈ centred), a genuine foreign write is treated as ours
   and is *not* restored — same double-subtract outcome. Conversely, a future
   writer that freezes the memo with an already-SIM value is falsely treated as
   a seam and gets one extra half *added* (V781 Q1).
3. **`_target` is transiently centred.** Between the foreign write and the
   guarded transform, any reader of `_target` (journey probe print at
   `main.gd:1652`, HUD, a later `_apply_transform()` from `_process`) observes
   the wrong frame. The conversion is therefore not just fragile, it is
   non-idempotent by construction: applying "the conversion" twice gives a
   different answer.

The fix removes the guess entirely: there is no centred `_target` state
anywhere, so there is nothing to detect and nothing to double-subtract.

## 3. Exact diff (file:line, final line numbers)

### `variant3d/scripts/camera3d.gd`

| Final lines | Change |
|---|---|
| `:11-16` | API header: document `apply_external_target` / `mark_external_transform` (CAM-SEAM v2) and that the old v1 signature guard was `camera3d.gd:233-237 (old)`. |
| `:70-75` | Add `const CAM_HANDOFF_VERSION: int = 2` with a v1→v2 contract comment. |
| `:138-143` | `_own_clamp_target` comment rewritten: still a clamp memo, **no longer a seam detector**. Field kept, behaviour of `clamp_pos()` unchanged. |
| `:234-252` | `_apply_transform()`: **deleted** the 5-line signature guard (old `:229-236`). The SIM→centred subtraction at `:247` is now unconditional and idempotent; comment at `:239-245` states the invariant. |
| `:403-411` | `jump_to_world()`: the three private memo writes (old `:399-401`) replaced by one `mark_external_transform()` call at `:410`. Public API and observable behaviour unchanged. |
| `:451-459` | **New** public `mark_external_transform()` — invalidates the clamp memos (the explicit replacement for the old private-field freeze). |
| `:462-475` | **New** public `apply_external_target(sim_pos: Vector2)` — the versioned handoff (full contract in §4). |

Old code removed (verbatim, old `:229-236`):

```gdscript
	# V7-70 seam defence: when an external writer freezes the memo to a target
	# other than ours, it has already converted _target SIM -> centred. Restore
	# SIM here so the subtraction below happens exactly once, whatever path set
	# the focus (minimap jump, startup, journey mode).
	if _target == _last_clamp_target and _target != _own_clamp_target and zoom == _last_clamp_zoom:
		_target += half
		_last_clamp_target = _target
		_own_clamp_target = _target
```

New public API (verbatim, final `:451-475`):

```gdscript
func mark_external_transform() -> void:
	_last_clamp_target = Vector2.INF
	_last_clamp_zoom = -1.0
	_own_clamp_target = Vector2.INF


func apply_external_target(sim_pos: Vector2) -> void:
	_target = sim_pos
	_zoom_anchor_screen = Vector2.INF  # a focus handoff cancels any zoom anchor
	mark_external_transform()
	clamp_pos()         # clamps in SIM space; may apply the transform itself
	_apply_transform()  # unconditional, single SIM->centred subtraction
```

### `variant3d/scripts/main.gd`

| Final lines | Change |
|---|---|
| `:600-605` (async menu startup) | `camera.set("_target", focus3)` + `camera.clamp_pos()` + `_center_camera3d_target()` → single `camera.apply_external_target(focus3)` at `:605`. |
| `:1050-1058` (synchronous setup / screenshot path) | Same replacement at `:1058`; `focus3` computation and the `screenshot_focus == "relief"` override at `:1055-1056` are byte-preserved. |
| `:1635-1642` (journey) | Deleted the `_center_camera3d_target()` call after `camera.call("jump_to_world", target_m)`. `jump_to_world()` itself already leaves `_target` in SIM and performs exactly one centred transform now that the guard is gone. |
| `:1003-1009` | **Deleted** the whole `_center_camera3d_target()` helper (old `:999-1016`) and replaced it with a short removal note. No caller remains anywhere in the repo. |

There are now **zero** `camera.set("_target" …)`, `camera.set("_last_clamp_*" …)`
or `camera.call("_apply_transform")` writes in `main.gd` (verified by repo grep).

## 4. The new idempotent contract

```
CAM_HANDOFF_VERSION = 2

Producer (main.gd):
  - passes a SIM-metre focus (top-left map origin) to camera3d;
  - NEVER writes camera private fields and NEVER calls _apply_transform().

Consumer (camera3d.gd):
  - _target is CANONICAL SIM on every path: bind(), jump_to_world(), _process
    pan/zoom, set_zoom_target(immediate) and apply_external_target() all keep it
    in SIM;
  - _apply_transform() performs ONE unconditional subtraction of _map_half():
    base = (target.x - half.x, 0, target.y - half.y). No memo, no zoom, no
    signature is consulted;
  - mark_external_transform() publicly invalidates the clamp memos;
  - apply_external_target(sim_pos) = store SIM target, clear zoom anchor,
    invalidate memos, clamp in SIM, apply the single centred transform.

Idempotence: applying the conversion N times to the same SIM focus yields the
same camera transform for any N >= 1 and for any zoom value in between. There
is no centred-target state to subtract twice. Calling apply_external_target()
twice with the same sim_pos is a no-op on the second call (clamp delta = 0),
and a wheel zoom between a handoff and the next _apply_transform() cannot
change the offset applied.
```

`jump_to_world()` remains the canonical API for minimap/click jumps; it uses the
same `mark_external_transform()` + `clamp_pos()` sequence and needs no extra
seam from `main.gd`.

## 5. Preserved-work checklist

- [x] **V7-81 black-screen fix** — `bind()` still starts at `_map_half()` (map
      centre), `_apply_transform()` still subtracts exactly one map half, and
      `clamp_pos()` still converts centred viewport corners back to SIM before
      clamping (`:433-448`). Expected measurements unchanged: centre focus →
      camera `gp.x = 0.0`; corner focus → centred `≈(-297, -300)`.
- [x] **V7-90 donor height / wheel / pan** — `height`/`height_target`,
      `_height_m`/`_zoom_to_height`/`_height_to_zoom`, `zoom_step()`,
      middle-drag (`:470-479`), edge scroll/dwell and arrow-key pan untouched.
- [x] **V7-77 terrain height sampler** — `_resolve_height_sampler`,
      `_sample_height`, `_screen_to_surface`, `_zoom_anchor_screen` and the
      zoom-anchor correction (`_target += anchor_world - after`) untouched.
- [x] **V7-82 / V7-92 terrain work** — no terrain, water, shader, atlas or
      `world3d*` file opened for writing. Only the camera transform consumer
      of the centred frame changed, and its output is identical at constant zoom.
- [x] **V7-70 screenshot path** — `screenshot_path`, `screenshot_focus == "relief"`,
      `_relief_focus_position() / world.view_scale` (`:1055-1056`) and the
      2D-branch relief handling (`:1071-1072`) preserved verbatim.
- [x] **Snapshot / selftest logic in main.gd** — `selftest_baseline = game.serialize()`
      (`:1040`), `st.set_baseline(selftest_baseline)` (`:1989`) and all screenshot
      gates untouched.
- [x] **Public APIs used by hud/input** — `bind`, `jump_to_world`,
      `screen_to_world`, `world_to_px`, `get_view_rect`, `get_viewport_corners`,
      `zoom_step`, `set_zoom_target`, `clamp_pos` — signatures and call sites
      unchanged. Only two *new* public methods were added.
- [x] **2D camera** (`camera.gd`) untouched; its own `_last_clamp_zoom`
      (`:31,128,137`) is a separate 2D mechanism.
- [x] Tabs preserved in both `.gd` files; main.gd's CRLF and camera3d.gd's LF
      line endings preserved.

## 6. Static checks already performed (no Godot involved)

- Repo grep: no remaining `_center_camera3d_target`, no `set("_target")` /
      `set("_last_clamp_*")` / `call("_apply_transform")` in `main.gd`.
- All 10 `_target` writes in `camera3d.gd` reviewed: every one is SIM
      (`_map_half()`, `world_pos`, `sim_pos`, SIM clamp delta, SIM pan delta,
      centred-space *difference* `anchor_world - after` which is frame-invariant).
- `tests/t_camera3d.gd` and `scripts/selftest.gd` contain no assertions on the
      old seam signature, so no committed test is invalidated by removing the guard.
- Protocol backups created (reconstructed pre-edit originals, verified 620 and
      2133 lines respectively):
      `inbox/backup/camera3d.gd.bak-CAMSEAM`, `inbox/backup/main.gd.bak-CAMSEAM`.

**Not verified:** GDScript parse, headless probe, selftest, uitest, windowed
render. No Godot process was launched, per the queue hold.

## 7. Verification PENDING — exact jobs to run after all-clear

Run from the project root through the serialized runner only
(`AGENT_PROTOCOL.md:14-34`). These are **planned, not submitted**.

```bat
python app\tools\godot_runner.py run --id camseam-parse-cam --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/camera3d.gd
python app\tools\godot_runner.py run --id camseam-parse-main --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/main.gd
python app\tools\godot_runner.py run --id camseam-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python app\tools\godot_runner.py run --id camseam-uitest --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
```

Plus a ticket-specific zoom-perturbation probe (written to
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/_camseam_probe.gd` at all-clear;
**not** into `variant3d/tests/`, which is out of this agent's ownership):

```bat
python app\tools\godot_runner.py run --id camseam-probe --timeout 180 -- --headless --path variant3d --script C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/_camseam_probe.gd
```

Probe assertions (the case the 11/11 constant-zoom probe missed):

1. `bind()` → centred `gp.x ≈ 0` and `_target == (320,320)` SIM.
2. `jump_to_world((320,320))` → centred `gp.x ≈ 0`; `_target` still SIM.
3. `apply_external_target(sim)` → expected centred focus; `_target == sim`.
4. **Zoom-perturbation:** after step 3, change `zoom`/`height` (simulating a
   wheel notch), call `_apply_transform()` 3×, assert `global_position` unchanged
   and no second half subtracted. Repeat with a wheel notch *between* the
   handoff and the first transform.
5. **Idempotence:** `apply_external_target(same_sim)` twice → identical
   `global_position` and `_target`.
6. Corner focus lands near centred `(-297,-300)` after clamp; centred corner
   centre round-trips to SIM within the view half-extent (V781 baselines).

Optional windowed sanity capture (only if the coordinator wants a fresh frame
after the other agents' fixes land):

```bat
python app\tools\godot_runner.py run --id camseam-shot --timeout 300 -- --path variant3d -- --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/camseam_after.png --screenshot-frames 10 --timeout 300
```

## 8. Handoff notes / open questions

- The old V781 probe (temp, already deleted per that report) simulated the v1
  seam by writing a centred `_target` plus frozen memos and asserting restoration.
  That assertion is **obsolete by design**: the new contract forbids a centred
  `_target`, so the probe must be re-expressed against `apply_external_target()`
  as in §7. No committed test needs changing.
- `V781 §4 Q1` and `TERRAIN2_05 RB-16` can be closed once the §7 probe is green:
  `main.gd` no longer freezes the clamp memo and no longer owns a centred write.
- **Queue discipline:** no runner job was submitted by this agent. Four other
  fix agents (FIX-SEL, FIX-TERRAIN, FIX-SELECTVIS, FIX-COLOR) are using the Godot
  queue (tickets 257-274 in `status.json`); wait for the coordinator's all-clear
  before running §7.
- No donor visual parity is claimed; this is a coordinate-frame correctness fix.

---

*End of report. CAM-SEAM wrote only the two owned source files, this report, and
two uniquely named rollback copies under `inbox/backup/`. No Godot launch, no
git command, no test/asset/config edit.*
