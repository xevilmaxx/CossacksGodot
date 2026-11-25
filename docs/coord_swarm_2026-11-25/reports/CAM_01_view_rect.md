---
id: CAM-01
title: "CAM-01 — donor camera truth: view_rect half-map fix and stale-label correction"
owner: CAM-01 (implementation builder, coordinated swarm)
date: 2026-11-25
status: IMPLEMENTED__COMMENT_ONLY_IN_CAMERA3D__SMOKE_OK__WORLD3D_CHANGE_REQUEST_LEFT_OPEN
scope: "Exactly two files touched: variant3d/scripts/camera3d.gd (comment-only) and this report. No other file edited. Donor READ-ONLY; no donor file executed or copied."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION]
backup: inbox/backup/camera3d.gd.bak-CAM01
smoke: "python variant3d\\tools\\godot_runner.py run --id cam01-smoke --timeout 60 -- --headless --path variant3d --script <temp>/cam01_smoke.gd  [ticket 339: status=ok exit=0 stderr SCRIPT ERROR == 0]"
evidence_labels: [observed, derived, inferred, UNVERIFIED]
---

# CAM-01 — donor camera truth: `view_rect` half-map fix and stale-label correction

## Goal

Fix the two camera-side documentation defects that make the 3D `view_rect`
consumer mis-convert screen corners, and relabel the hard-coded FOV with the
RV-CAM-01-corrected rationale — without changing any camera behaviour. The
actual consumer fix lives in `world3d.gd`, which is **not owned by this ticket**;
it is filed below as a separate change request to COORD.

## Files owned / touched

| File | Action |
|---|---|
| `variant3d/scripts/camera3d.gd` | EDITED — **comment-only** (two comment blocks); zero code tokens changed |
| `docs/coord_swarm_2026-11-25/reports/CAM_01_view_rect.md` | CREATED (this report) |

**No other file was edited.** In particular `hud.gd`, `hud3d_adapter.gd`,
`input_controller.gd`, `picking3d.gd` and `world3d.gd` are untouched by CAM-01.
Concurrent foreign edits were visible in `git status` at edit time
(`config.gd`, `input_controller.gd`, `menu.gd`, `selftest.json`,
`tests/manifest.json`, `tools/test_all.py` plus several atom-repair test files),
and more appeared by final verification (`config.json`, `hud.gd`,
`hud3d_adapter.gd`, `selftest.gd`, `water3d.gd`, `world3d_entities.gd`,
`world3d_terrain.gd`, both `.gdshader` files). **None were reverted, staged,
altered, or reported as CAM-01 errors** — they are other builders' work, and
the `cam01-smoke` job's stderr was empty (no foreign transient errors surfaced
in this job). `world3d.gd` itself was not modified by anyone in this window.

Backup taken before any edit:
`inbox/backup/camera3d.gd.bak-CAM01` (32,781 bytes, byte copy of the pre-CAM-01
`variant3d/scripts/camera3d.gd`).

## Read first (all consumed before editing)

- `docs/coord_swarm_2026-11-25/reports/V3D_01_selection_rectangle_audit.md`
  — break-point **row 5** (`:252`): `world3d.gd:247-293` trusts a stale comment and
  omits the half-map shift; cites `camera3d.gd:266-275,354-363` and
  `PLAY2FIX_navbox.md:14-29,69-83`. Row 5 is **MEDIUM-HIGH derived** from a single
  prior measurement (CENTRED corners), not a runtime re-measurement here.
- `.../DSEL_02_donor_pick_math.md` — claims 1–5, 12–13, 19 (perspective f=400,
  tilt −32°, dolly 20–58, heightfield ground ray, four-corner viewport rect,
  centred world origin), divergence table `:237-249`, FOV paragraph `:296-299`.
- `.../RV_CAM_01_fov_resolution.md` — verdict **CONFIRMED_UNVERIFIED** (`:217-236`);
  PORT APPROXIMATION recommendation (`:238-257`); final label table (`:306-314`).
- `decomp/DEC_07_cameras_shaders.md` — §5.2–5.3 projection math and `:721-723`
  caveat. Its §8.3 "correction" is superseded by RV-CAM-01.
- `docs/coord_swarm_2026-11-25/GAPS.md` §1 Projection row (`:22`) and
  "Minimap / HUD" row (`:25`): `camera3d.gd:354` comment contradicts `:435-436`;
  fix when the camera owner touches the file.
- Owned file read in full (662→679 lines after edits), especially
  `screen_to_world()` `:266-275`, `get_viewport_corners()` `:354-363`,
  `get_view_rect()` `:366-380`, `clamp_pos()` `:417-448` (the corroborating
  CENTRED comment at `:435-436`, SIM conversion at `:438`), and the FOV constant
  at `:62-65` (assigned at `:153`).
- Cross-checked consumers (read-only): `hud3d_adapter.gd:45,53-71` (adds
  `Vector2(mw,mh)*TILE_M*0.5` at `:62`), `world3d.gd:247-293` (Vector2 branch
  `:270-274` omits the shift; Vector3 branch `:275-279` adds `ox,oz`),
  `t_camera3d.gd:133,176-184` (API/rect smoke contract).

> Line citations in the edited file use the **pre-edit** numbering of
> `camera3d.gd`, matching the audit reports. The two comment insertions shifted
> later code down by 10 and then 11 lines; no cited function moved relative to
> another.

## Finding 1 — stale comment at `camera3d.gd:354` (DEC-08 / GAPS §1)

**Before (observed, literal):**
```
# Four GROUND corners in screen order TL, TR, BR, BL (metres, top-left map origin).
```

**Evidence that it is false:** `get_viewport_corners()` fills the array with
`screen_to_world(...)` results (`:359-362`), and `screen_to_world()` returns
`Vector2(hit.x, hit.z)` from `project_ray_origin/project_ray_normal` on the
**actual centred Camera3D transform** (`:267-275`) — no `_map_half()` addition.
`clamp_pos()` independently states "get_viewport_corners()/screen_to_world()
return CENTRED world metres" at `:435-436` and adds `_map_half()` at `:438`.
`hud3d_adapter.gd:57-62` independently adds the same half-map offset before
tile mapping (PLAY2FIX-NAVBOX; PLAY2-01 E5/E7). `world3d.gd:271-273` quotes the
stale "MAP-ORIGIN sim space" claim as its reason for **not** shifting.

**After (comment-only):**
```
# Four GROUND corners ... returned as Vector2(x=world X, y=world Z) in CENTRED
# world metres (origin at map CENTRE), NOT SIM top-left map-origin metres. ...
# STALE COMMENT CORRECTED (DEC-08 / GAPS.md §1 "Minimap / HUD" row): ...
```

`for c in corners:` body, `get_view_rect()`, and all return values are
**byte-identical** to the backup.

## Finding 2 — Vector2 corner / half-map conversion consistency

**Decision: do NOT shift the returned corners inside `camera3d.gd`.** The
half-map conversion is *already* consistent with `hud3d_adapter.gd:57-62` in the
sense that the adapter's `p += Vector2(mw,mh)*TILE_M*0.5` is applied to CENTRED
corners and is correct. Shifting inside `get_viewport_corners()` would cause a
**double shift** in two correct consumers:

1. `camera3d.gd:438` — `var centre_sim: Vector2 = centre + _map_half()`;
2. `hud3d_adapter.gd:62` — `p += Vector2(mw, mh) * Data.TILE_M * 0.5`.

That would break camera clamping (off-terrain / black edges, the PLAY2-01 RC2
failure mode) and the minimap frustum box — a behaviour regression forbidden by
"keep every other camera behaviour byte-identical", and the same class of trap
as the CAM-SEAM v2 double-subtract (GAPS watchlist §3 #4/#9).

**What was done in the owned file:** the corrected `get_viewport_corners()`
comment now states the CENTRED contract explicitly and names the two consumers
that add the offset, plus the SIM-space rule (`add _map_half()`; mirror
`world3d.gd:279`'s Vector3 branch). This makes the source self-consistent with
`:435-436` and `hud3d_adapter.gd:57-62` and prevents another consumer from
repeating the `world3d.gd:271-273` mistake.

**What could not be done in the owned file:** the defective call site is
`world3d.gd:268-274`, which calls `get_viewport_corners()` by name and then takes
the **Vector2 branch with no shift**. No existing camera API returns shifted
corners, and adding a shift to the existing return value is unsafe (above).
Adding a *new* method would not help that caller without editing `world3d.gd`.
Therefore the fix is filed as a **separate COORD ticket** (below), as the task
requires. `world3d.gd` was **not** edited.

## Finding 3 — FOV label corrected, value unchanged

**Before (`:62-65`, literal):**
```
# PORT ASSUMPTION — NOT a donor literal. M0.6 "display sensor" V-FOV used to keep vertical
# faces visible; A/B candidate 2.90 deg (36 mm sensor) still pending. G31:227,262-263;
# terrain3d_sandbox.gd:24-36; SWARM_BOARD.md:415-420.
const FOV_DEG_ASSUMED: float = 17.27
```

**After:** relabelled **PORT APPROXIMATION / UNVERIFIED** with RV-CAM-01's
corrected rationale — 17.27° is the 16:9 **vertical** FOV of a **216 mm
horizontal** sensor at donor `f=400` (`H=2·atan(216/800)=30.219°`,
`V=2·atan(tan(H/2)/(16/9))=17.272°`); the donor FOV API exists
(`EXE 0x1fe0ef`, inverse `0x1fe158`) but has no readable call site and no sensor
constant, so the number is **CONFIRMED_UNVERIFIED**. Explicit warning not to
substitute 5.15°/30.22° (those are the horizontal FOVs, DEC-07 §8.3's own
"correction" is wrong), 2.90° retained as an equally unverified secondary A/B,
and the byte-identical value justified as the measured baseline
(V790 `fov=17.270000`, selftest 29/29).

`const FOV_DEG_ASSUMED: float = 17.27` and `fov = FOV_DEG_ASSUMED` (`:153`) are
**unchanged**. No numeric FOV was promoted to donor truth.

## Finding 4 — deliberately left unchanged

- **CAM-SEAM v2** (`CAM_HANDOFF_VERSION = 2`, `apply_external_target()`,
  `mark_external_transform()`, single SIM→centred subtraction in
  `_apply_transform()` `:246-247`): untouched. No double-subtract reintroduced.
- **Minimap jumps** (`jump_to_world()` `:403-411`, donor ArcTan offset/heading
  OPEN): untouched — owned by HUD-01/pick owners.
- **`screen_to_world()` flat Y=0** (`:266-275`): unchanged. **LEFT OPEN.** A
  donor-grounded replacement (engine heightfield ray, DSEL-02 claim 7 / formula
  E, `init.script:101` precision 1e-7) exists in principle and the file already
  has a height-sampler path (`_resolve_height_sampler()` `:282-304`,
  `_screen_to_surface()` `:339-351`), but wiring it into `screen_to_world()`
  would (a) recurse (`_screen_to_surface()` calls `screen_to_world()`),
  (b) change the flat-Y contract used by `clamp_pos()`/HUD and the zoom-anchor
  split (`:633-657`, which intentionally separates surface hit from flat
  re-hit), and (c) overlap the `picking3d.gd` owner's ray-march
  (`picking3d.gd:148-171`). No donor-grounded replacement can be proven without
  that owner's file, so this stays **UNVERIFIED / PORT APPROXIMATION** and is
  not attempted here.
- **FOV still UNVERIFIED** by construction (RV-CAM-01 verdict): no donor
  screenshot A/B was run (running the donor is forbidden).

## Change request to COORD — separate ticket (not executed here)

**Target:** `variant3d/scripts/world3d.gd:268-274` — Vector2 branch of
`_update_view_rect()`.

**Current code (observed):**
```
if c is Vector2:
    # camera3d.gd:181-188 returns ground metres in
    # MAP-ORIGIN sim space (camera3d.gd:89-90);
    # no half-map shift (AUDIT3D-05 E9).
    xy = c as Vector2
```

**Requested minimal change:** replace the stale comment and add the already-
available half-map vector (`ox`, `oz` are computed at `world3d.gd:252-253`
as `float(w)*0.5*t` / `float(h)*0.5*t`):
```
if c is Vector2:
    # camera3d.get_viewport_corners() returns CENTRED world metres
    # (camera3d.gd:354-363, :435-438; hud3d_adapter.gd:57-62);
    # shift to SIM map-origin metres before the view_scale multiply.
    xy = (c as Vector2) + Vector2(ox, oz)
```

**Constraints:** leave the Vector3 branch (`:275-279`, already shifted) and the
`view_scale` AABB construction (`:289-292`) byte-identical; do not edit
`camera3d.gd`; do not bundle with SEL-01 (GAPS §1 "Related bug" row says
"separate atom (do not bundle)"). **Impact:** fixes double-click
select-all-of-type (`input_controller.gd:632-635`), **not** the drag-box
(V3D-01 §5, row 5). **Confidence:** MEDIUM-HIGH **derived** — rests on one prior
measurement (PLAY2FIX) that corners are CENTRED; re-verify with a runtime probe
before/after. The camera-side comment at `camera3d.gd:354` is now corrected so
this consumer's old justification can no longer be cited.

## Validation — variant runner only

Runner: `python variant3d\tools\godot_runner.py run --id cam01-smoke --timeout 60
-- --headless --path variant3d --script <approved-temp>/cam01_smoke.gd`.
The probe script lives outside the repo (approved temp folder), extends
`SceneTree`, loads `res://scripts/camera3d.gd` (a parse/load smoke of the owned
file), prints `CAM01_SMOKE_OK` and self-exits via `call_deferred("quit", 0)` —
the same pattern as the prior `sel01-probe-smoke` job (ticket 323) and
`t_pick3d.gd:11`. **No direct `godot`, no gates, no ladder.**

**Result (ticket 339):** `status=ok`, `exit=0`, `wait=121.15 s`, `run=5.30 s`
(FIFO queue delay only — the 121 s wait was another builder's job, not a CAM-01
error). `stdout.txt` contains `CAM01_SMOKE_OK`; `stderr.txt` is **empty** and
`SCRIPT ERROR` count = **0**. Artifacts:
`variant3d/.godot_queue/results/00000339.json`,
`variant3d/.godot_queue/results/00000339_cam01-smoke/{stdout,stderr}.txt`.
No foreign transient errors appeared in this job's stderr.

## Before → after summary

| # | Item | Before | After |
|---:|---|---|---|
| 1 | `camera3d.gd` corner comment (`:354`) | "metres, top-left map origin" (false; contradicts `:435-436`) | explicit CENTRED-world-metres contract + half-map consumer citations + world3d change-request pointer |
| 2 | `get_viewport_corners()` returned Vector2 corners | CENTRED (correct for `clamp_pos()`/`hud3d_adapter.gd`), but undocumented and mis-documented | **code unchanged**; contract documented; consumer fix filed as separate COORD ticket |
| 3 | `FOV_DEG_ASSUMED` label (`:62-65`) | "PORT ASSUMPTION … display sensor" | "PORT APPROXIMATION / UNVERIFIED" + 216 mm horizontal / f400 / 16:9 V rationale; value `17.27` unchanged |
| 4 | Everything else | CAM-SEAM v2, minimap jumps, flat-Y `screen_to_world()` | byte-identical; flat-Y and ArcTan offset explicitly LEFT OPEN |

`git diff -- variant3d/scripts/camera3d.gd` shows **only `+`/`-` comment lines**;
`const FOV_DEG_ASSUMED: float = 17.27`, `func get_viewport_corners()`, its loop,
and every executable statement are untouched.

## UNVERIFIED / label ledger

- Donor numeric FOV: **CONFIRMED_UNVERIFIED** (RV-CAM-01); 17.27° is a
  **PORT APPROXIMATION**, not a donor literal.
- "Corners are CENTRED": **derived/observed** from camera source + two
  independent consumers; the *original* PLAY2FIX measurement was not repeated
  here. The `world3d` impact remains **MEDIUM-HIGH derived**, not runtime-proven.
- Donor heightfield ground ray / flat-Y divergence: **agent-side approximation**;
  native ray math **UNVERIFIED** (DSEL-02 claim 7).
- Minimap donor ArcTan offset/heading: **UNVERIFIED** (unchanged).

## Open questions

1. Will COORD open the `world3d.gd:268-274` ticket as a separate atom, and will a
   runtime probe confirm CENTRED corners before the one-line shift lands?
2. Should a future `camera3d.get_viewport_corners_sim()` convenience API be
   added (would make the world3d fix a call swap)? Deliberately **not** added
   here because it cannot help the current caller without a world3d edit and
   would add unused API surface.
3. Can a donor screenshot with a known ground feature at a known bookmark height
   ever supply an A/B FOV anchor (RV-CAM-01 open question 5)? Forbidden in this
   task; 2.90° and 17.27° remain the only coherent A/B candidates.
4. Should `screen_to_world()` be migrated to the heightfield ray in a dedicated
   ticket that also owns `picking3d.gd`, preserving the flat-Y zoom-anchor path?

## Verification / integrity statement

No donor file was executed or copied. No Godot process was started outside the
variant runner. No gates or ladder were run. No file other than the two listed
above was edited by CAM-01; concurrent foreign edits were left intact.
