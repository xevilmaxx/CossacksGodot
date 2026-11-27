# FLATMAP-4 — Why the camera preset did not change the capture (read-only)

Worker: FLATMAP-4. Scope: read-only investigation, no code/Godot/donor execution, no config or source edits.
Parity: UNVERIFIED. No parity claim. Chain 0/6. RESULT IS NOT GOOD.

## Inputs compared (byte-read)

- Donor-backend config: `variant3d/config_donor_capture.json:68-77`
  `camera.pitch_degrees = -32.0`, `camera.start_zoom = 0.3448276`,
  `features.camera.fov_deg = 17.27` (`:42-44`), `gameplay.render_mode = "3d"` (`:79-81`).
- Temp wide config: `inbox/qa/captures/wide_view_config.json:68-77`
  `camera.pitch_degrees = -55`, `camera.start_zoom = 0.22`,
  `features.camera.fov_deg = 17.27` (`:42-44`, unchanged), `gameplay.render_mode = "3d"` (`:79-81`, unchanged).
- Both files parsed as JSON in this investigation (read succeeded, 879 lines each); no byte-level corruption was observed in the read. Whether the capture command line actually passed the temp file via `--config` was NOT verified here [U] (see §d).

## (a) Does the headless deterministic `--seq` path read `camera.start_zoom` / `pitch_degrees` at all, and where

Byte-proven reads:

- `variant3d/scripts/main.gd:198` — `start_zoom = cfg.num("camera.start_zoom", 0.75)`. The `--config` JSON value IS read into `main.gd:start_zoom`.
- `variant3d/scripts/main.gd:200` — `render_mode = str(cfg.text("gameplay.render_mode", "2d")).to_lower()`. The render-mode key IS read.
- `variant3d/scripts/config.gd:527` — `Data.CAMERA_PITCH = num("camera.pitch_degrees", -32.0)` inside `apply()`. The pitch key IS read into `Data.CAMERA_PITCH`.
- `variant3d/scripts/config.gd:479-482` — `feature_camera_fov_deg()` returns `num("features.camera.fov_deg", 17.27)`. The FOV key IS read (both configs carry 17.27, so no change was possible on this axis regardless).
- `variant3d/scripts/camera3d.gd:192-251` (`bind()`) — reads `fov` via `cfg.feature_camera_fov_deg()` (`camera3d.gd:216`), plus `camera.zoom_notch_gain / zoom_smooth_rate / edge_* / wheel_speed / middlemousescrollspeed / keyscrollspeed / mousescrollspeed` (`camera3d.gd:217-229`). It does NOT read `camera.start_zoom` and does NOT read `camera.pitch_degrees` / `Data.CAMERA_PITCH` anywhere in `bind()`.
- `variant3d/scripts/camera3d.gd:234-240` — `bind()` hard-seeds `min_zoom = 20/58`, `max_zoom = 58/20`, then `zoom_target = clampf(1.0, ...)` and `zoom = zoom_target`. The config start_zoom is NOT consumed here.
- `variant3d/scripts/camera3d.gd:288-310` (`_apply_transform()`) — `pitch = deg_to_rad(DONOR_PITCH_DEG)` (`camera3d.gd:306`), with `DONOR_PITCH_DEG = -32.0` (`camera3d.gd:76`). The transform NEVER consults `Data.CAMERA_PITCH` or any config pitch. A `-55` preset therefore cannot reach the 3D transform through this path (byte-proven).
- The ONLY path by which `start_zoom` reaches the 3D camera is the later explicit call in `variant3d/scripts/main.gd:1172` (`_setup_full_game()`): `camera.set_zoom_target(start_zoom, true)`, followed by `camera.apply_external_target(focus3)` (`main.gd:1179`). Same pattern in the async loader (`main.gd:661-666`). So (a) = split: `start_zoom` IS forwarded (via `set_zoom_target`, not via `bind`); `pitch_degrees` is read into `Data` but is byte-proven DEAD for the 3D camera transform; `fov_deg` IS forwarded via `bind()` but was identical (17.27) in both configs.

## (b) Is start_zoom overridden by a later `set_zoom_target` on a different value

- Normal capture path: NO second override is byte-present. After `main.gd:1172` there is no further `set_zoom_target` in `_setup_full_game()`; `_process` does not retarget zoom except in journey mode.
- Journey-mode override (byte-proven, conditional): `variant3d/scripts/main.gd:1786-1787` — `want_zoom = 0.75 if fighting else 1.0; camera.set_zoom_target(want_zoom)` every ~1 s while `journey_mode` is true. Whether either capture ran with `--journey` is [U]; if it did, the preset would be overwritten within one second. If it did not, this override did not fire.
- Clamp override (byte-proven, unconditional): `variant3d/scripts/camera3d.gd:788-790` (`set_zoom_target`) — `zoom_target = clampf(target, min_zoom, max_zoom)` with `min_zoom = 20/58 ≈ 0.3448`. The temp preset `0.22` is BELOW the floor, so even on the correct `--config` path it clamps to `≈ 0.3448` — byte-identical to the donor config's `0.3448276`. On the zoom axis the two presets are therefore INDISTINGUISHABLE BY CONSTRUCTION, independent of any load failure.
- `camera3d.gd:774-780` (`zoom_step`) likewise clamps `height_target` to `DONOR_HEIGHT_MIN..MAX` (20..58 m).

## (c) Is the capture taken before camera setup completes

NO (byte-proven ordering for both setup variants):

- `_setup_full_game()` (`main.gd:1131-1243`) is fully synchronous: `camera.bind` (`main.gd:1171`) → `set_zoom_target(start_zoom, true)` (`main.gd:1172`) → `apply_external_target` (`main.gd:1179`) → HUD/input/audio all complete BEFORE `_ready` returns and before any `_process` frame.
- Seq frames are emitted only from `_process` (`main.gd:1821-1827`: `if seq_dir != "" ... _save_seq_frame()`), i.e. strictly after setup. The deterministic gate (`main.gd:1672`) additionally waits for `load_ready`.
- Headless caveat (byte-proven, decisive for headless runs): `_save_seq_frame()` (`main.gd:2214-2238`) captures the viewport ONLY `if not is_headless`; under headless `img` stays null and falls through to `img = _render_headless_image(800, 600)` (`main.gd:2236-2237`). `_render_headless_image` (`main.gd:2065-2134`) is a pure CPU tile/resource/entity plot that NEVER reads the camera (no `camera`, `zoom`, `pitch`, or `fov` reference in that function). Any headless `--seq` run therefore produces camera-INDEPENDENT frames: identical output is EXPECTED even with a working preset. Which display path (`headless` vs windowed) the two captures used is [U] from source alone (needs the `seq_index.json` `mode` field / launch logs).

## (d) Did the temp config fail to parse and silently fall back

- Parse-failure fallback EXISTS (byte-proven): `config.gd:369-376` (`_parse`) returns `{}` and appends to `problems` on invalid JSON / non-object top level; `config.gd:307-317` (`load_all`) appends `"extra settings file not found: ..."` when the `--config` path resolves nowhere, then continues on base defaults. Either failure is silent except for a `printerr` of `problems` (`main.gd:210-211`).
- No byte evidence of such a failure was found in this read-only pass: the temp file is well-formed JSON as read (all keys present, `camera.start_zoom = 0.22` at line 77, `pitch_degrees = -55` at line 69), and no capture log (`problems` output, `--dump-config`, effective `--config` argv) was examined — deliberately out of scope for a no-execution worker. So: fallback mechanism CONFIRMED present in code; whether it FIRED for `mapwide_20261127` stays [U].
- Positive byte evidence against needing a parse failure: per §(b) clamp + §(a) pitch-dead + identical FOV, the two presets produce IDENTICAL camera state even when the temp file loads perfectly (0.22→0.3448 clamp; −55 ignored; 17.27 = 17.27). A load failure is NOT required to explain the identical frames.

## Which is byte-proven vs [U]

- Byte-proven: (1) `start_zoom` read at `main.gd:198`, forwarded only at `main.gd:1172` / `main.gd:661`, never in `camera3d.bind`; (2) `pitch_degrees` read at `config.gd:527` but dead for the 3D transform, which is pinned at `camera3d.gd:76,306`; (3) `fov_deg` read at `config.gd:479-482` / consumed at `camera3d.gd:216` but identical in both configs; (4) `0.22` clamps to donor floor at `camera3d.gd:788-790` given `min_zoom = 20/58` at `camera3d.gd:234`; (5) capture-after-setup ordering at `main.gd:1131-1243` vs `main.gd:1821-1827`; (6) headless seq ignores the camera at `main.gd:2219-2237` + `main.gd:2065-2134`; (7) silent-fallback code paths at `config.gd:369-376,307-317`.
- Stays [U]: (i) the exact `--config` argv / working directory / candidate-path resolution for each capture; (ii) whether `problems[]` reported a missing/unparseable file (needs logs or `--dump-config`); (iii) headless vs windowed vs `capture_deterministic` mode of each capture (needs `seq_index.json` `mode` / launch logs); (iv) whether `--journey` (the `main.gd:1786-1787` zoom override) was active; (v) any donor-side claim about correct pitch/zoom semantics — parity UNVERIFIED, no parity claimed.

## Verdict

The preset change had no effect through at least THREE independent byte-proven mechanisms, any one of which suffices: pitch is not wired to the 3D transform, 0.22 clamps to the donor floor, and FOV did not change — plus a fourth (headless CPU timelapse) if the captures ran headless. Chain 0/6. RESULT IS NOT GOOD.
