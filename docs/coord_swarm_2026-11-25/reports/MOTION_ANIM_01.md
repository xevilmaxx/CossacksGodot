---
id: MOTION-ANIM-01
title: "Presentation-side unit motion fixes for the VID-AN-01 faults (speed gate, PORT APPROX yaw clamp, frozen-sim pose refresh)"
date: 2026-11-25
owner: MOTION-ANIM-01 (implementation builder subagent)
status: LANDED__PARSE_SMOKE_OK__SIM_STALL_LEFT_OPEN_FOR_GAME_GD_TICKET
owns:
  - "variant3d/scripts/world3d_entities.gd"
  - "docs/coord_swarm_2026-11-25/reports/MOTION_ANIM_01.md"
backup: "inbox/backup/world3d_entities.gd.bak-MOTIONANIM01"
labels: [PRESENTATION_ONLY, measured-sim-displacement, PORT-APPROX, donor-parity-UNVERIFIED, visual-UNVERIFIED, parse-only-validation]
runner: "variant3d/tools/godot_runner.py ONLY — job 'motionanim01-smoke', ticket 435, status ok, exit 0, run 6.41 s; SCRIPT ERROR == 0. No gates, no ladder, no direct godot."
scope: "Exactly one owned code file edited + one owned report + one required backup. No game.gd / audio.gd / world3d_fx.gd / tests / app / config / asset / donor edit. No donor binary executed, unpacked or copied."
---

# MOTION-ANIM-01 — presentation-side motion fixes

## 0. What this ticket did and did not do

Fixed the **presentation-side** half of the VID-AN-01 faults in the owned file
`variant3d/scripts/world3d_entities.gd`:

1. Walk vs idle pose is now selected from **measured SIM displacement per
   `sync()`**, not from the SIM's `moving` boolean alone.
2. Unit yaw is limited by a per-sync rate clamp that rejects the measured
   91°/166° snaps. This is labelled **PORT APPROX**; donor ACL blend semantics
   are UNVERIFIED and no donor parity is claimed.
3. A frozen sim still forces a pose-frame re-evaluation and, when the normal
   batch-migration callback is skipped, an explicit mesh rebind from the real
   donor verts.

**Not fixed here:** the SIM stall itself and squad order propagation. Those live
in `game.gd` (`_tick_unit` / nav-grid / formation arrival and `cmd_move` squad
propagation) and are explicitly a **separate ticket** — see §6. Nothing in this
edit writes to the sim, changes `moving`/`order`, or invents animation data.

## 1. Evidence read (citations)

| Source | Facts used |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/VID_AN_01_motion_analysis.md:56-69`, `:80-99`, `:103-110` | f00→f07 translation 0.357–0.450 m per 0.375 s capture (~0.95–1.20 m/s); f08→f15 total 0.003 m (~0.001 m/s) while `order:move` / `moving:true` persist, ~14 m short; walk frames keep cycling 10→19→6→15; 91° step f03→f04 and 166° snap f07→f08; right-foreground unit window bit-identical on all 15 pairs; units 11–13 `order:none`, az 0°. |
| `.../VID_AN_01_motion_analysis.md:127-149`, `:155-167` | Fix recommendations 2/3/4 (speed-gated action, yaw clamp, frozen-render pose refresh) and the explicit donor-parity caveat (§6). |
| `docs/coord_swarm_2026-11-25/reports/VID_CAP_01_capture.md:159-190` | 16 frames, `SIM_STEP=1/32`, 12 ticks/capture = 0.375 s, one squad `cmd_move` to (78,69), units 10–13 `officer`, camera byte-identical, pose frames `15,1,15,1,15,24,10,24,10,19,10,19,6,19,6,15`. |
| `.../VID_CAP_01_capture.md:220-237` | Open Q1–Q2: stall with `moving:true` and squad members 11–13 lacking the order are capture-side open questions, not presentation bugs. |
| `docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md:314-341` | Donor state→name map (`weapon_none` + move idle/turn → `idle`, move walk → `walk`), observed in donor script; the port's 3-state map is a coarse PORT policy. |
| `.../DANIM_01_action_ranges.md:349-385`, `:548-575` | Donor blend authored as `minFrameBlend=6 / maxFrameBlend=8`, **engine semantics UNVERIFIED**; one-shot/loop policy lives in ACL, not AAF; sampled flat-root morph stays `PORT APPROXIMATION — NOT DONOR PARITY`. |
| `docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md:21-35`, `:65-92` | The owned renderer consumes `anim3d.pose_for()` donor verts, rebuilds frame-keyed MultiMesh batches, and keeps `PORT APPROXIMATION — NOT DONOR PARITY` / `visual = UNVERIFIED`. Action map `dead→death / moving→walk / else idle` was the V7-74 PORT policy. |
| `docs/coord_swarm_2026-11-24/reports/V779_pose_memo.md:18-33`, `:69-83` | The `pose_memo` is a **local** dict per `sync()` keyed `sid|action`; frame derives from `(sid, action, donor time)`. New per-unit state in this ticket is likewise scoped/reset by `bind()`/`add_unit()`/`remove()`. |
| `docs/audit/ANIM_ADJUDICATION.md:36-68` | Donor cadence bands are measured AAF facts; no threshold was retuned here and no test/data value was changed. |

## 2. Exact edits — `variant3d/scripts/world3d_entities.gd` only

Line numbers are post-edit.

| Final line(s) | Before | After |
|---|---|---|
| `:188-203` | No motion heuristics; only `PORT_LABEL` / `ANIM_STATUS` / `MORPH_ACTION_MAP`. | New `WALK_SPEED_GATE_M_S = 0.15`, `YAW_MAX_RATE_RAD_S = 45°/s`, `MOTION_GATE_STATUS`, `YAW_CLAMP_STATUS`. Each is labelled PORT APPROX with the measured VID-AN numbers and the DANIM-01 blend caveat in comments. |
| `:250-258`, `:302-305`, `:1333-1338`, `:1537-1539` | No per-unit SIM mirror. | `_motion_sample` (pos + anim-clock), `_face_smooth` (clamped face), `_applied_pose_frame` (frame actually bound to the mesh). Cleared in `bind()`, seeded in `add_unit()`, erased in `remove()`. Never written back to the sim. |
| `:936-946` | `_unit_action(ed)` → `moving ? walk : idle`. | `_unit_action(ed, speed = -1.0)`: `dead→death` unchanged; with a measurement, `speed >= 0.15 m/s → walk`, else `idle`; `speed < 0` keeps the V7-74 `moving` fallback for direct/stub callers. |
| `:951-966` | — | `_measure_speed(id, ed)`: `|pos − last_pos| / (_anim_t − last_t)` on the live sim Dictionary. No second wall-clock timer. |
| `:969-978` | — | `_smooth_face(id, target, dt)`: shortest signed arc, `fposmod` wrap-normalised, clamped to `rate * dt`. PORT APPROX, not a donor blend. |
| `:1304-1310` | `yaw = PI / 2.0 - float(ed.get("face", 0.0))` (raw SIM face). | `_xf()` uses the once-per-sync clamped face from `_face_smooth`; raw face is used only before the first sync (spawn / stub callers). All V7-65/FIX-MOVE-VISUAL geometry comments kept. |
| `:1556-1560`, `:1586-1597`, `:1809-1814` | No motion telemetry. | Per-sync `motion_measured_speeds_m_s`, `motion_rendered_actions`, `motion_yaw_clamps`, `motion_frozen_pose_refreshes`, plus bind-time labels `motion_gate_label` / `motion_yaw_clamp_label` / `motion_frozen_refresh_label`. All structural/numeric, never a visual claim. |
| `:1626-1651` | If `new_key == old_key`, nothing touched: a stationary/frozen unit kept whatever mesh binding it had. | On a skipped migration but advanced donor frame, rebind the existing batch's `mm.mesh` from the already-validated `morphed["mesh"]` and refresh its `donor_frame` meta; track the applied frame per unit. Real donor verts only — no guessed vertex, no sprite sheet, no RNG. |

**DECOR-01 preserved byte-identically.** The 43-line block from `const
ENV_TREE_SCALE` through `const TREE_YAW_STATUS` (19-tree `POOL_TREE`, the
`0.475..0.76` per-sid scale ladder, and the `none/tight/wide` jitter bands) is
byte-for-byte identical to the backup; verified by direct line-block comparison.
`ENV_SCALE`, `ENV_TREE_SCALE`, `ENV_JITTER_BANDS`, `TREE_JITTER_BAND` and
`POOL_TREE` each compare equal.

### Why the gate value is 0.15 m/s

`observed` from VID-AN-01 §3: the slowest measured moving capture is 0.357 m /
0.375 s = 0.95 m/s; the stall is ~0.0005 m / 0.375 s ≈ 0.001 m/s. 0.15 m/s is
`derived` as a midpoint band ~6× below march and ~150× above stall. It is a
**PORT presentation heuristic**, not a donor number: the donor state map is
readable (DANIM-01 §4.2) but its engine-side blending is UNVERIFIED (§4.3).

### Why the yaw rate is 45°/s

`derived`: 45°/s × 0.375 s = 16.875° maximum per capture, so the observed 91°
and 166° single-capture steps are clipped to one bounded step instead of a snap;
at a 60 Hz frame dt the same rule allows 0.75°/frame. This is a **PORT APPROX
rate limiter**. Donor authors 6–8 frame blends but the engine meaning is
UNVERIFIED (DANIM-01 §4.3 / §9 Q3), so this is explicitly **not** a donor blend
or a donor-parity claim.

## 3. Before → after against the frame evidence

| VID-AN-01 fault | Before (measured / code) | After (this edit) |
|---|---|---|
| Walk while stalled, f08→f15 | `_unit_action` read `moving:true` → `walk`; donor walk frames cycle 10/19/6/15 at ~0.001 m/s (VID-AN §3/§4.3). | `_measure_speed` returns ~0.001 m/s → `_unit_action` returns `idle`; the renderer binds an `idle` donor frame instead of cycling `walk`. The SIM `moving` flag is untouched. |
| 91° step f03→f04, 166° snap f07→f08 (VID-AN §5) | `_xf()` used raw `ed.face` → `yaw = PI/2 − face` with no per-frame limit. | `_smooth_face` clamps the shortest arc to 16.875° per 0.375 s capture (45°/s × dt); `_xf()` consumes the smoothed face. No donor interpolation is claimed. |
| Frozen render / skipped mesh callback (VID-AN §3 "bit-identical ×16", §7.4) | If a unit stayed in the same batch key, no mesh binding was refreshed; `_applied_pose_frame` did not exist, so nothing detected a pose advance behind a skipped migration. | Every unit is still sampled in Pass 1 (no motion gate on `pose_for`), and a persistent applied-frame mirror now forces an explicit `mm.mesh` rebind when the migration callback is skipped. **Visual visibility of this refresh is UNVERIFIED at zoom 2.9 / height 20 m** — a close-up capture is still needed (VID-AN §7.5). |
| Squad / translation stall (VID-AN §5 translation FAIL, squad FAIL) | SIM behaviour: unit 10 stalls 14 m short with `order:move`; units 11–13 stay `order:none`. | **Unchanged by design** — `game.gd` ownership; separate ticket (§6). |

**Important sidecar caveat (`observed`, not a defect here).** `frames.json`
poses are written by the capture atom's own `pose_for` call and its own
`moving → walk / else idle` rule (`variant3d/tests/t_motion_capture.gd:227-255`),
not by this module's `_unit_action`. A re-run of that capture will therefore
still log walking sidecar frames for a SIM-stalled unit. Validation of this fix
must read this module's new `motion_*` stats / batch keys, not the sidecar pose
string; no such behavioural capture was run in this ticket (parse smoke only).

## 4. Backup and validation

- Backup: `inbox/backup/world3d_entities.gd.bak-MOTIONANIM01`, SHA-256
  `8BDC79D7D5F2E178D65E6004B13B7577EC5167E607257F822921086045733DDE`, identical
  to the pre-edit owned file (verified by hash before editing).
- Runner command (variant runner only):
  `python variant3d\tools\godot_runner.py run --id motionanim01-smoke --timeout 90 -- --headless --path variant3d --check-only --script res://scripts/world3d_entities.gd`
- Result: ticket **435**, job id **`motionanim01-smoke`**, `wait 5.27 s`,
  `run 6.41 s`, `exit 0`, `status ok` (`variant3d/.godot_queue/results/00000435.json`).
  stdout is only the Godot banner; stderr is empty.
- `SCRIPT ERROR` scan: `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000435_motionanim01-smoke\stderr.txt`
  → **`script_error_lines: 0`**.
- No gates, no ladder, no direct `godot`, no visual/GPU capture, no selftest
  rewrite, no test file added or edited. This is a **parse-only smoke**, so all
  behavioural before→after statements in §3 are code-path reasoning tied to the
  cited frame numbers, not newly measured pixels.

## 5. UNVERIFIED / label ledger

- **Donor parity UNVERIFIED** throughout: the clamp and the speed gate are PORT
  APPROX presentation policies; no donor footage, ACL engine trace or rendered
  A/B was used (VID-AN §6; DANIM-01 §4.3/§9).
- **Visual effect UNVERIFIED**: the forced mesh rebind may still be sub-pixel at
  the capture zoom (VID-AN §7.4/Q3). No claim of visible improvement is made.
- Donor blend semantics (`minFrameBlend=6` / `maxFrameBlend=8`) UNVERIFIED;
  this clamp does not reproduce them.
- `visual = "UNVERIFIED"` and `PORT APPROXIMATION — NOT DONOR PARITY` are kept
  verbatim on every batch/node; new labels say only what was measured.
- No donor binary was executed, unpacked or copied; no donor animation
  semantics were invented; all poses still come from `anim3d.pose_for()`.

## 6. Open — SIM stall and squad propagation need a `game.gd` ticket

**Recommendation:** open a separate ticket owned by `variant3d/scripts/game.gd`
for (a) unit 10's arrival/stall at (63.76, 61.58) with `order:move` and
`moving:true` ~14 m short of (78,69) — check `_tick_unit`, nav-grid blockers,
formation anchor and arrival radius (VID-AN §7.1, VID-CAP §7 Q1); and (b) squad
propagation of one `cmd_move` to members 11–13, which stayed `order:none`,
az 0° for all 16 frames (VID-AN §7.1, VID-CAP §7 Q2, `game.gd:3283-3310`).
This ticket deliberately did **not** change sim movement, order propagation or
the `moving` flag.

Other open questions:

1. Is the bit-identical foreground unit a skipped mesh rebuild or sub-pixel
   pose deltas? A fixed-camera close-up (lower height / higher zoom, lit ground)
   decides it (VID-AN §7.5 / Q3). The fallback rebind in this edit removes the
   "skipped callback" half but cannot prove visibility at this zoom.
2. At what measured speed should a stalled unit return to `idle` in a real
   battle (where knockback/collision can produce transient sub-gate motion)?
   The 0.15 m/s value is a bounded heuristic; no donor threshold exists.
3. Should the yaw limiter be rate-based (as here) or a fixed per-capture step?
   Donor ACL blend semantics are UNVERIFIED, so both are port policies.
4. Frozen sim in shipped play: `main.gd` returns before `world.sync()` when
   `ais` is empty / speed 0 (VID-CAP §2), which is outside this file's
   ownership. The atom calls `world.sync(dt)` explicitly
   (`t_motion_capture.gd:386,404`); a shipped frozen-sim refresh hook would be
   a `main.gd` owner decision, not made here.
5. Do the new `motion_*` stats need a fixed-seed behavioural atom? That would
   require editing a test file, which is outside this ticket's ownership.

## 7. Files changed / summary

Changed by this ticket:
- `variant3d/scripts/world3d_entities.gd` (owned; +136/−6 lines).
- `docs/coord_swarm_2026-11-25/reports/MOTION_ANIM_01.md` (this report, new).
- `inbox/backup/world3d_entities.gd.bak-MOTIONANIM01` (required backup only).

**No other file was edited by this ticket** — specifically not `game.gd`,
`audio.gd`, `world3d_fx.gd`, `anim3d.gd`, any test, `app/**`, config, asset,
scene or git state. (Other agents' pre-existing working-tree changes were left
untouched.)

**Summary:** walk/idle now comes from measured SIM displacement, so a stalled
unit stops cycling donor walk frames; yaw changes are rate-limited with a
labelled PORT APPROX clamp that rejects the measured 91°/166° snaps; and a
frozen sim still triggers pose re-evaluation plus an explicit donor-vert mesh
rebind when the migration callback is skipped. Parse smoke `motionanim01-smoke`
passed with `SCRIPT ERROR == 0`. The SIM stall and squad non-propagation remain
**open** for a dedicated `game.gd` ticket; donor parity and the visual result of
the refresh remain **UNVERIFIED**.

---

## 8. Urgent follow-up — mill rotor hard engine errors + spin direction

Owner-reported error (live game, repeated):

```
ERROR: Unable to open file: res://.godot/imported/mill_rotor.png-8777cf……ctex.
ERROR: Failed loading resource: res://assets/models/anim/common/buildings/mill_rotor.png.
  at _rotor_material (world3d_entities.gd:1430) → _attach_rotor → add_building → world3d.gd sync
```

COORD verified the source PNG and `.import` exist while the generated `.ctex`
is missing; ASSET-IMPORT-01 is regenerating the cache in parallel. The prior
code called `ResourceLoader.exists(ROTOR_TEX_PATH)` and then `load()`; a `.import`
file alone made `exists()` true, so `load()` tried the missing `.ctex` and Godot
emitted hard `ERROR:` lines even though the null result was later handled.

**Root cause (ASSET-IMPORT-01, ticket 444):** the import job itself succeeded,
but `variant3d/assets/models/anim/` is under `.gdignore`, so Godot **never
imports** `mill_rotor.png`; its leftover `.import` advertises a `.ctex` that can
never exist. Removing `.gdignore` would pull ~1,800 dead 2D bake PNGs into the
import set, so that was explicitly **not** done.

**Runner incident (QA-PARITY-01 cleanup), all non-code skips:**
- `motionanim01-rotor-smoke` ticket **448** — CANCELLED/skipped (`serving=464`).
- `motionanim01-rotor-smoke-r2` ticket **458** — skipped (`serving=461`) on
  re-submission, so it also parsed nothing.
- `rotorasset01-import` ticket **462** — skipped (`serving=475`) on the first
  import attempt, so no import ran.

None of these three is a parse result, a regression, or a reason to revert.
Each was re-submitted once under a fresh id (`motionanim01-rotor-smoke-r3`,
`rotorasset01-import-r2`); FIFO waits are normal and no slow job was duplicated.

### 8.1 Robustness fix (owned file only)

| Final line(s) | Before | After |
|---|---|---|
| `:213-226` | No rotor fallback label or spin-axis label. | `ROTOR_FALLBACK_STATUS` (`PORT_LABEL + missing cache → plain untextured white quad; visual UNVERIFIED`) and `ROTOR_SPIN_AXIS_STATUS` (PORT APPROX axis correction; donor `.oss` 3D direction UNVERIFIED). |
| `:257-259` | No warning guard. | `_rotor_fallback_warned` — one labelled `push_warning` per process, even with many mills; deliberately not reset in `bind()` because this is an import/project state. |
| `:1447-1479` | `ResourceLoader.exists()` → `load()` (engine ERROR on missing `.ctex`), then a direct-PNG retry via `ProjectSettings.globalize_path`; texture-less path still used alpha-scissor settings. | **No `load()` call for the rotor at all.** Try the new importable port copy `ROTOR_TEX_IMPORT_PATH = "res://assets/models/tex/mill_rotor.png"` **first**, then the original anim/ path as a fallback; for each, check `FileAccess.file_exists()` and decode via `Image.load()`, checking `== OK and not img.is_empty()` before `ImageTexture.create_from_image()`. On total failure: `albedo_texture = null`, white `albedo_color`, `TRANSPARENCY_DISABLED`, one labelled `push_warning`. On success: unchanged alpha-scissor cutout. Material meta `rotor_texture_status` is `donor_png_bound` or `fallback_white_untextured`. |
| `:1488-1490` | Rotor meta did not record texture state. | `_attach_rotor()` copies the material meta onto the `MillRotor_<id>` node. Donor quad geometry, hub `(0.17296, 5.23533, 0) m`, donor source metas and `visible = finished` are untouched. |
| `:1727-1732`, `:1738-1740` | `face * Basis().rotated(Vector3.BACK, rotor_spin)`. | `face * Basis().rotated(Vector3.FORWARD, rotor_spin)`; stats gain `mill_rotor_spin_axis_label` and `mill_rotor_texture_fallback_used`. |

### 8.2 Rotation audit against the cited donor-truth proxies

| Quantity | Donor-truth evidence | Verdict |
|---|---|---|
| Speed | `MILL_SPIN = 0.75 rad/s` at `app/scripts/world.gd:203-204`; spin `anim_t * MILL_SPIN` at `:652`; port `anim_t += dt` at `:2082`. `MILLFIX_rotor_fields.md:35-39,:86` measured Δ0.375 rad over 0.5 s. | **PASS** — unchanged; `_anim_t * MILL_SPIN` matches. |
| Pivot | `hub = tl + sz*MILL_HUB` with `tl = p - sz*(cx,foot)` (`world.gd:651`, `:2892-2895`); `MILLFIX_rotor_fields.md:47-48` derives local `(0.17296, 5.23533, 0) m`. | **PASS** — unchanged; same donor numbers and full-cell span (6.352 m, `world.gd:205-208`). |
| Direction / axis | `world.gd:640-654` rotates the donor-baked sail by a **positive** 2D CanvasItem angle (screen-clockwise with y-down); `app/scripts/world.gd:199-201` states the bake lifts the donor `eurmilanim.oss` rotor. The 3D billboard basis built in `sync()` maps local +X to screen-left and +Y to screen-up (`rx = UP.cross(d)`, `ry = d.cross(rx)`), so positive rotation about **BACK** (−local Z) ran screen-counter-clockwise — reversed relative to the cited 2D donor-bake proxy. | **FIXED (PORT APPROX)**: minimal `BACK → FORWARD` axis change makes positive spin screen-clockwise. Donor **3D** `.oss` spin direction has no readable citation and stays **UNVERIFIED**; no rotation constant was invented. |

### 8.3 Validation and preservation

- Backup before this follow-up: `inbox/backup/world3d_entities.gd.bak-MOTIONANIM01-ROTOR`, SHA-256
  `3FAB5C789C77ACDF10A81CDDDEE1907D8C49B728E3AD8CA28D3B79F01809BFEA` (identical to the post-MOTION-ANIM-01 file).
- **Asset copy (granted file):** `variant3d/assets/models/anim/common/buildings/mill_rotor.png`
  → `variant3d/assets/models/tex/mill_rotor.png`, SHA-256
  `E92CAE700C934CA78BFC201BCFE26A83BE5BF32360F0BB557EAEEC8318DC2949` on both,
  36,081 B. This is a **port-to-port copy of an existing port PNG**, not a donor
  copy: no donor file was read, executed, unpacked or copied for this follow-up.
  `.gdignore` was not edited and no other asset was added.
- **Incident:** `motionanim01-rotor-smoke` (ticket **448**) was CANCELLED by
  QA-PARITY-01's cleanup, not by code; it is excluded from parse evidence.
- Runner-only validation (final code): `python variant3d\tools\godot_runner.py run --id motionanim01-rotor-smoke-r3 --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/world3d_entities.gd`
  → ticket **476**, `wait 0.00 s`, `run 9.47 s`, `exit 0`, `status ok`
  (`variant3d/.godot_queue/results/00000476.json`); stdout is only the Godot
  banner, stderr empty. `smallmap_capture.py scan-stderr` on
  `00000476_motionanim01-rotor-smoke-r3/stderr.txt` → **`script_error_lines: 0`**.
  Tickets 448/458 are excluded (cleanup skips, see incident above).
- Targeted import: `python variant3d\tools\godot_runner.py run --id rotorasset01-import-r2 --timeout 900 --max-wait 1800 -- --headless --path variant3d --import`
  → ticket **478**, `wait 10.17 s`, `run 48.71 s`, `exit 0`, `status ok`
  (`variant3d/.godot_queue/results/00000478.json`). stdout shows
  `reimport | mill_rotor.png` and `[ DONE ]`; **stderr is empty**,
  `script_error_lines: 0`, and there are **zero** lines matching both
  `mill_rotor` and `ERROR` in stdout or stderr. Ticket 462 was a cleanup skip;
  the import was re-submitted once under a new id.
- Generated cache verified on disk:
  `variant3d/.godot/imported/mill_rotor.png-4a48061f0d7ba5177d0860e82ddc4369.ctex`,
  **28,242 B**, written 2026-11-25. The source copy
  `variant3d/assets/models/tex/mill_rotor.png` is 36,081 B with its generated
  `mill_rotor.png.import` (952 B); no `.uid` was generated. This is **not**
  BLOCKED: the real ctex now exists and the graceful white-quad fallback is
  retained anyway.
- Short windowed boot (error-line check): _to be recorded when the job returns._
- MOTION-ANIM-01 speed gate, yaw clamp, frozen-sim refresh and DECOR-01's 19-tree
  pool / scale ladder / jitter bands were re-checked after the rotor edit: the
  43-line DECOR block is byte-identical to the backup and all four in-flight
  motion symbols are still present. No test, app, asset, `game.gd`, `audio.gd`,
  `world3d_fx.gd`, `anim3d.gd`, config or scene file was edited for this
  follow-up. No gates, no ladder, no direct `godot`.
