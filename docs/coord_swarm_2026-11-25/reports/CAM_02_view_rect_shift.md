---
id: CAM-02
title: "CAM-02 — world3d.gd Vector2 view-rect half-map shift (double-click select-all-of-type)"
owner: CAM-02 (implementation builder, coordinated swarm)
date: 2026-11-25
status: IMPLEMENTED__SMOKE_OK__RUNTIME_PARITY_UNVERIFIED__REVERIFY_TICKET_NEEDED
scope: "Exactly two files touched: variant3d/scripts/world3d.gd (4-line change, Vector2 branch only) and this report. No other file edited. camera3d.gd (CAM-01), hud3d_adapter.gd, input_controller.gd, world3d_terrain.gd, shaders and tests untouched."
labels: [observed, derived, UNVERIFIED]
backup: inbox/backup/world3d.gd.bak-CAM02 (36,116 bytes; SHA256 66A37C321CFCA9826078A1ACC8122732DEE96F551F7EB630128327CA579F179E, byte-identical to pre-edit file)
smoke: "python variant3d\\tools\\godot_runner.py run --id cam02-smoke --timeout 60 -- --headless --path variant3d --script <approved-temp>/cam02_smoke.gd  [ticket 356: status=ok exit=0 wait=76.65s run=5.77s stderr empty, SCRIPT ERROR == 0]"
evidence_labels: [observed, derived, UNVERIFIED]
---

# CAM-02 — `world3d.gd` Vector2 view-rect half-map shift

## CAM-01 reference

This ticket executes the **separate COORD change request** filed by
`docs/coord_swarm_2026-11-25/reports/CAM_01_view_rect.md` §"Change request to
COORD — separate ticket" (`:183-216`). CAM-01 deliberately did **not** shift
`get_viewport_corners()` because two consumers already add the half-map offset
(`camera3d.gd:438` via `+ _map_half()`, `hud3d_adapter.gd:57-62` via
`p += Vector2(mw, mh) * Data.TILE_M * 0.5` in the pre-edit numbering); shifting
there would double-shift. CAM-01 identified the defective caller as
`world3d.gd:268-274` and left it for this atom. Also consulted:
`V3D_01_selection_rectangle_audit.md` break-point **row 5** and
`PLAY2FIX_navbox.md:14-29,69-83`. Effect path is **double-click
select-all-of-type** (`input_controller.gd:632-635`), **not** the drag box.
Confidence remains **MEDIUM-HIGH derived** — no runtime re-measurement was
made here.

## Files owned / touched

| File | Action |
|---|---|
| `variant3d/scripts/world3d.gd` | EDITED — Vector2 branch of `_update_view_rect()` only; 4 lines replaced by 4 lines, no line-number shift |
| `docs/coord_swarm_2026-11-25/reports/CAM_02_view_rect_shift.md` | CREATED (this report) |

**No other file was edited.** In particular `camera3d.gd`, `hud3d_adapter.gd`,
`input_controller.gd`, `world3d_terrain.gd`, shaders and tests are untouched by
CAM-02. Foreign concurrent edits were visible in `git status` at edit time
(`config.json`, `camera3d.gd`, `config.gd`, `hud.gd`, `hud3d_adapter.gd`,
`input_controller.gd`, `menu.gd`, `selftest.gd`, `water3d.gd`,
`world3d_entities.gd`, `world3d_terrain.gd`, `selftest.json`, both `.gdshader`
files, `tests/manifest.json`, `tools/test_all.py`, test fixtures and their
backups). None were reverted, staged, altered or reported as CAM-02 errors.
The `cam02-smoke` job's stderr was empty, so no foreign transient errors
surfaced in this job.

## Read first (all consumed before editing)

- CAM-01 report in full (above).
- `world3d.gd:240-300` — confirmed `ox` / `oz` are already computed at
  `:252-253` as `float(w) * 0.5 * t` / `float(h) * 0.5 * t`; the Vector2 branch
  at `:270-274` quotes the stale "MAP-ORIGIN sim space" comment and assigns
  `xy = c as Vector2` with **no** shift; the Vector3 branch at `:275-279`
  already does `Vector2(v3.x, v3.z) + Vector2(ox, oz)`; the `view_scale` AABB
  at `:289-292` is downstream and untouched.
- `camera3d.gd:264-284` and `:434-454` **read-only** — `screen_to_world()`
  returns `Vector2(hit.x, hit.z)` from the actual centred Camera3D transform
  with no half-map addition; `get_viewport_corners()` fills its array from
  those results (CAM-01 `:354-363` pre-edit numbering); `clamp_pos()` confirms
  the CENTRED contract and adds `_map_half()` (CAM-01 `:438`).
- `hud3d_adapter.gd:45-74` **read-only** — `get_minimap_box()` consumes
  minimap tile points; CAM-01's cited `p += Vector2(mw, mh) * TILE_M * 0.5`
  at its `:62` is the second independent half-map adder (the current file is
  a foreign concurrent edit and was not touched).
- `variant3d/tools/godot_runner.py` in full — single door for Godot launch;
  `cam01_smoke.gd` used as the approved probe pattern.

**Vector2/Vector3 distinction check:** found exactly as CAM-01 reported —
Vector2 unshifted, Vector3 shifted. No ambiguity, so no stop/report needed.

## Before → after (`variant3d/scripts/world3d.gd`)

**Before (observed, `:270-274`):**
```
							if c is Vector2:
								# camera3d.gd:181-188 returns ground metres in
								# MAP-ORIGIN sim space (camera3d.gd:89-90);
								# no half-map shift (AUDIT3D-05 E9).
								xy = c as Vector2
```

**After (`:270-274`, same line numbers):**
```
							if c is Vector2:
								# camera3d.get_viewport_corners() returns CENTRED world metres
								# (camera3d.gd:354-363, :435-438; hud3d_adapter.gd:57-62);
								# shift to SIM map-origin metres before the view_scale multiply.
								xy = (c as Vector2) + Vector2(ox, oz)
```

The camera citations in the new comment use CAM-01's canonical **pre-edit**
`camera3d.gd` numbering (CAM-01's two comment insertions shifted later lines
by +10/+11; no code moved relative to another). No symbols were renamed.

**Byte-identical:** `ox` / `oz` declarations (`:252-253`), the Vector3 branch
(`:275-279`), the finiteness guard (`:282-283`), the min/max accumulation
(`:284-288`), the `view_scale` AABB (`:289-292`), `view_rect = rect` (`:293`)
and every other line of the file. `git diff -- variant3d/scripts/world3d.gd`
shows exactly `4 insertions(+), 4 deletions(-)` in one hunk.

## Backup

`copy variant3d\scripts\world3d.gd inbox\backup\world3d.gd.bak-CAM02` was run
before the edit. Backup is 36,116 bytes and its SHA256
(`66A37C32…F179E`) matched the pre-edit source exactly.

## Validation — variant runner only

Probe: `<approved-temp>/cam02_smoke.gd` (temporary file **outside** the repo,
same pattern as CAM-01's `cam01_smoke.gd`), `extends SceneTree`; loads
`res://scripts/world3d.gd`, instantiates it, checks `bind` / `sync` /
`world_to_px` / `_update_view_rect` exist, calls `_update_view_rect()` once on
an unbound, out-of-tree instance (full-map fallback path), prints
`CAM02_SMOKE_OK` and self-exits via `call_deferred("quit", 0)`. **No
`view_rect` parity assertion** was added: CAM-02 owns no test file, and the
task explicitly requires deferring parity to a re-verify ticket.

Command:
```
python variant3d\tools\godot_runner.py run --id cam02-smoke --timeout 60 -- --headless --path variant3d --script C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\cam02_smoke.gd
```

**Result (ticket 356):** `status=ok`, `exit=0`, `wait=76.65 s`, `run=5.77 s`.
`stdout.txt` contains `CAM02_SMOKE_OK view_rect=[P: (0.0, 0.0), S: (5120.0, 5120.0)]`
(the full-map fallback, as expected out-of-tree). `stderr.txt` is **empty**;
`SCRIPT ERROR` count = **0**. Artifacts:
`variant3d/.godot_queue/results/00000356.json`,
`variant3d/.godot_queue/results/00000356_cam02-smoke/{stdout,stderr}.txt`.
The 76.65 s wait was another builder's queued job (FIFO serialization), not a
CAM-02 error. **No direct `godot`, no gates, no ladder.**

## UNVERIFIED / runtime re-verify ticket needed

- **Runtime parity is UNVERIFIED.** The smoke proves the edited script parses,
  instantiates and runs the non-camera fallback path without errors. It does
  **not** prove that the resulting `view_rect` in a live scene matches
  `hud3d_adapter.get_minimap_box()` or that the CENTRED-corner premise holds at
  runtime. Confidence is **MEDIUM-HIGH derived**, resting on CAM-01's single
  prior measurement, not a fresh runtime probe.
- **A dedicated runtime re-verify ticket is needed** before this atom can be
  considered donor/parity-confirmed: drive the double-click select-all-of-type
  path (`input_controller.gd:632-635`) in a live 3D scene with a current
  Camera3D, compare the shifted `world3d.view_rect` against
  `hud3d_adapter.get_minimap_box()`, and confirm no regression in camera
  clamping or drag-box selection. CAM-02 did not open that ticket; it is
  reported here for COORD to schedule.
- Axis-aligned AABB under camera yaw remains a **PORT APPROXIMATION**
  (V71 §6 Q5 / study open Q9) — unchanged by this fix.

## Open questions

1. Will a runtime probe confirm the corners are CENTRED with a live Camera3D,
   or will it reveal that `get_viewport_corners()` is already shifted in some
   code path (which would make this a double-shift)? The smoke cannot answer
   this.
2. Should the future re-verify compare `view_rect` to `get_minimap_box()` in
   tile units, requiring division by `Data.TILE_M`, or use a direct
   world-metres comparison? CAM-02 owns no test file and did not decide.
3. Is the same stale "no half-map shift" claim repeated in any other consumer
   outside CAM-02's ownership (e.g. a 2D-side call site)? Not audited here;
   CAM-01's audit named only this caller.
4. Should `camera3d.get_viewport_corners_sim()` be added later to make this
   one-line shift a call swap (CAM-01 open question 2)? Deliberately not added.

## Summary

CAM-02 applied CAM-01's requested minimal fix: the Vector2 corner branch of
`world3d._update_view_rect()` now adds the already-computed half-map offset
`Vector2(ox, oz)` before the `view_scale` multiply, matching the Vector3 branch
and the two correct half-map consumers. Only the owning file's four lines
changed; runtime parity is **UNVERIFIED** and a re-verify ticket is needed.
No other file was edited.
