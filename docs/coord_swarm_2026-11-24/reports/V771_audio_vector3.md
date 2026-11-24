---
id: V7-71
owner: V7-71
scope: "P1 G3 fix in variant3d/scripts/audio.gd only — Camera3D Vector3 centre/type error and 3D-aware distance culling; 2D path preserved"
date: 2026-11-24
status: DELIVERED — parse clean; stub-Camera3D probe 6/6 PASS; selftest passed:true 29/29
files_changed:
  - variant3d/scripts/audio.gd
  - docs/coord_swarm_2026-11-24/reports/V771_audio_vector3.md
runner: "variant3d/tools/godot_runner.py only — no direct godot invocation, no git commands"
---

# V7-71 — audio Vector3→Vector2 fix and 3D-aware culling

## 1. Task and exact failing operation

Charter: P1 of `AUDIT3D_09_runtime_proof.md:29,75,85` (gap G3) plus the follow-up on
`AUDIT3D_06_fx_anim_audio.md:94-96,129-133`.

- Windowed ticket `00000077.../stderr.txt`: `SCRIPT ERROR: Trying to assign value of type 'Vector3' to a variable of type 'Vector2'. at: C3Audio._process (res://scripts/audio.gd:153)`.
- Cause: `camera3d.gd:38 extends Camera3D`, so `cam.global_position` is `Vector3`;
  the pre-existing 2D statement `center = cam.global_position / 16.0` assigns to a
  `Vector2` (`audio.gd:150,153` before the fix). This is the ambient proximity centre
  used by `b.pos.distance_to(center)` (`audio.gd:162`), i.e. the 2D distance test that
  decides mill/town volume — not a pan control.
- Second, silent defect: `play()` looked up only `get_viewport().get_camera_2d()`
  (`audio.gd:318` before the fix). In `render_mode="3d"` that returns `null`, so the
  20–60 m distance curve/cutoff was skipped and every positional event played at full
  volume (`AUDIT3D_06:94`).

## 2. 2D / donor evidence (read-only)

| Evidence | Path:line | Use in this fix |
|---|---|---|
| 2D truth — ambient centre | `app/scripts/audio.gd:150-153` | `var center := Vector2.ZERO`; `center = cam.global_position / 16.0` — preserved verbatim as the `else` branch. |
| 2D truth — culling curve | `app/scripts/audio.gd:317-323` | `get_camera_2d()` → `at.distance_to(cam.global_position / 16.0)`; >60 m return; `clampf((d-20.0)*0.15, 0.0, 12.0)` — preserved verbatim as the `if cam != null` branch; the new 3D branch reuses the *same literals*, no new audio values. |
| Metres↔px scalar | `app/scripts/data.gd:113`, `variant3d/scripts/data.gd:117` | Existing `PIXELS_PER_METER := 16.0`; no new constant introduced. |
| 3D camera type | `variant3d/scripts/camera3d.gd:38` | `extends Camera3D` → `global_position` is `Vector3`. |
| Ground-plane convention | `variant3d/scripts/camera3d.gd:159-161,176`; `variant3d/scripts/hud3d_adapter.gd:86-96` | `Vector2(world.x, 0.0, world.y)` and `Vector2(hit.x, hit.z)`; the explicit comment at `hud3d_adapter.gd:95` is "game y == world z". Hence horizontal components = `x` and `z`, fed to the unchanged `/16.0` expression. |
| Camera3D transform | `variant3d/scripts/camera3d.gd:148-153` | `global_position = Vector3(_target.x, 0, _target.y) + Vector3(0, h, back)`: x/z are the available ground-plane components; the `back` offset caveat is recorded as an open question. |
| No spatial audio in port | `AUDIT3D_06:29,96,109`; donor `data/scripts/lib/sound.script:418,468,515` (quoted there) | Donor is emitter-based; no `AudioStreamPlayer3D`/buses were added here (out of scope). |
| Audio bed parity | `AUDIT3D_06:28` | Identical `audio.gd` hash vs `app/` before this task; 325 identical `.ogg` clips; identical event dispatch. Only the 3D-aware branches below were added. |

No donor binary was run and no donor art/audio values were copied or invented. No RNG
was added (the existing `randi()` in `play()` was untouched). Indentation is tabs.

## 3. Exact diff (only `variant3d/scripts/audio.gd`)

Hunk 1 — `_process()` ambient centre, original lines 150–153 → new lines 150–161:

```gdscript
 	var center := Vector2.ZERO
 	var cam = parent.get("camera")
 	if cam != null and is_instance_valid(cam):
-		center = cam.global_position / 16.0   # main.gd's metres convention
+		# Variant3d may bind a Camera3D here (camera3d.gd:38): its global_position
+		# is Vector3. Keep the 2D ground-plane convention — game y is world z
+		# (hud3d_adapter.gd:95-96, camera3d.gd:159-161) — and feed the same two
+		# horizontal components into the unchanged /16.0 metres conversion below.
+		if cam.global_position is Vector3:
+			var p3: Vector3 = cam.global_position
+			center = Vector2(p3.x, p3.z) / 16.0
+		else:
+			center = cam.global_position / 16.0   # main.gd's metres convention
```

The original 2D statement is byte-identical and is now the `else` branch; a Camera2D
takes exactly the old path.

Hunk 2 — `play()` listener lookup, original lines 317–323 → new lines 325–343:

```gdscript
 	if at != Vector2.INF:
 		var cam := get_viewport().get_camera_2d() if get_viewport() != null else null
 		if cam != null:
 			var d: float = at.distance_to(cam.global_position / 16.0)
 			if d > 60.0:
 				return
 			vol_db -= clampf((d - 20.0) * 0.15, 0.0, 12.0)
+		else:
+			# No Camera2D in render_mode="3d" (AUDIT3D-06 §5, audio.gd:317-323):
+			# use the active Camera3D's horizontal ground-plane components with
+			# the SAME cutoff/curve literals as the 2D branch above.
+			var vp := get_viewport()
+			var cam3 := vp.get_camera_3d() if vp != null else null
+			if cam3 != null:
+				var p3: Vector3 = cam3.global_position
+				var d3: float = at.distance_to(Vector2(p3.x, p3.z) / 16.0)
+				if d3 > 60.0:
+					return
+				vol_db -= clampf((d3 - 20.0) * 0.15, 0.0, 12.0)
 	var names := names_for(prefixes)
```

All four numeric literals (16.0, 60.0, 20.0, 0.15, 12.0) are the pre-existing 2D
values quoted above; the 2D branch itself was not edited. The 3D branch is reached
only when there is no current Camera2D, so app/ behaviour is unchanged.

## 4. Measured results (variant3d runner only)

All jobs launched from the repo root as
`python variant3d\tools\godot_runner.py run --id <id> --timeout <s> -- <godot args>`.
The runner serialised them with `godot.lock`; stdout/stderr were read from
`variant3d/.godot_queue/results/<ticket>_<id>/`, not from a local console.

| Ticket / job id | Command tail | Wait / run / exit | Measured result |
|---|---|---|---|
| 97 `v771-audio-check` | `--headless --path variant3d --check-only --script res://scripts/audio.gd` | 150.26 s / 3.36 s / 0 (`ok`) | `stdout.txt`: engine banner only; **`stderr.txt` empty (0 lines)** → both edits parse clean in Godot 4.7.2. |
| 107 `v771-audio-probe` (first attempt, superseded) | `--headless --path variant3d --script res://tests/t_v771_audio_tmp.gd` | 248.41 s / 182.27 s / -9 (`timed-out`) | Probe defect, **not** a product defect: work ran in `SceneTree._initialize()` before tree notifications, so `Camera3D.global_position`/`get_viewport()` failed (`stderr.txt:1-18`) and `quit` was never reached. Rewritten with a deferred `_run()`. Note the pre-fix stack showed the edited `audio.gd:157-158` reading `global_position` with no type error. |
| 117 `v771-audio-probe2` | same script, deferred version | 50.95 s / 3.77 s / 0 (`ok`) | **6/6 PASS**, `V771 RESULT {"passed":true,...}`. `stderr.txt` contains only benign exit-time RID/ObjectDB leak warnings (1 CanvasItem RID, 5 ObjectDB instances), no script error. Temp probe then deleted (`Test-Path` = `False`). |
| 121 `v771-audio-fix` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | 3.04 s / 57.19 s / 0 (`ok`) | `variant3d/selftest.json`: `"passed": true`, `steps = 29`, `failed = 0` → **29/29 unchanged**. `stderr.txt` only the known `STATIC BIND POSE` warning and exit-time ObjectDB/resource cleanup messages. |

Probe setup and measured values (ticket 117): a real `Camera3D` stub at
`global_position = Vector3(320, 40, 160)` was made current; a `Camera2D` stub at
`Vector2(320, 160)` supplied the 2D truth; a stub game supplied a finished mill at
10 m and town hall at 40 m from the expected centre (empty terrain ⇒ sea branch
skipped).

- `center formula x,z/16 == 2D x,y/16 :: center3d=(20.0, 10.0) center2d=(20.0, 10.0)`.
- `camera3d is active :: cam3d=@Camera3D@3... cam2d=<Object#null>` — confirms the 3D branch, not the 2D one, executed.
- Ambient mill: 3D `-22.5000` dB = 2D `-22.5000` dB = expected
  `-12 - 10 - clampf((10-8)*0.25,0,8)`; finite, `mill_ambient_active = true`.
- Ambient town: 3D `-18.0206` dB = 2D `-18.0206` dB = expected
  `-12 + linear_to_db(0.5)`; finite, `town_ambient_active = true`.
- `play()` distance culling executed with the Camera3D: 40 m → `volume_db = -3.0000`
  (exactly `clampf((40-20)*0.15,0,12)`); 100 m → `volume_db = 99.0000` (unchanged
  from the sentinel), proving the 60 m cutoff returned early.
- No type error, no NaN/Inf in any measured volume; no type-related line in stderr.

The temp probe `variant3d/tests/t_v771_audio_tmp.gd` was removed before this report
was written. No files other than `variant3d/scripts/audio.gd` and this report were
edited by me; `variant3d/selftest.json` was rewritten by the required selftest runner.

## 5. Open questions

1. **Units caveat (not changed here).** `AUDIT3D_06:95` observes that a
   `Camera3D.global_position` is already in scene metres (`camera3d.gd:148-152`), so
   dividing its horizontal components by 16 shrinks the centre relative to
   map-origin metre positions like `b.pos`. This fix deliberately preserves the
   charter's "same formula for the same x/y" and the 2D byte path; a metre-correct
   listener would need a separate render-mode decision (e.g. `camera3d.gd:90`
   `_target`), which would change 3D audio semantics beyond this P1. Not measured.
2. **Camera is behind the focus.** `camera3d.gd:150-153` offsets the Camera3D by
   `back` along Z from the ground focus, so `global_position.z` is not exactly the
   focus `y`. The x/z ground-plane convention is the only one available on a plain
   `Camera3D` stub; using the focus would require a new camera API (other owner).
3. **No spatial audio.** No `AudioStreamPlayer3D`, listener or buses were added, per
   scope. Donor emitter radius `8000` vs `80` and panning semantics remain
   UNVERIFIED (`AUDIT3D_06:96,156-160`); this fix restores distance volume only.
4. **Interactive windowed run not repeated.** The type error was observed in
   ticket 77 (screenshot mode) and is proven absent here by a stub Camera3D probe;
   whether ordinary windowed play hits the same branch is inferred (headless skips
   audio via `main.gd:1077-1079`), not measured in a new windowed job.
5. **2D A/B not executed.** The 2D branch was kept byte-identical rather than
   re-run through `app/`; no 2D regression was measured beyond the unchanged
   formula and the passing variant3d selftest.

## 6. Verdict

G3's `Vector3`→`Vector2` runtime error is removed in `variant3d/scripts/audio.gd`
without altering 2D behaviour, and the missing 3D camera lookup now drives the
unchanged distance culling/attenuation curve. Parse clean, probe 6/6 PASS, full
selftest still `passed:true` 29/29. Dimensional concerns in open questions 1–2 are
documented rather than silently changed.
