---
task_id: S1-INPUT-FIX
title: "S1-INPUT-FIX — remove the two known blockers in the selection-rectangle atom so the S1 ladder row can run"
owner: S1-INPUT-FIX (small atom-repair builder)
date: 2026-11-25
status: DONE__WINDOWED_REAL_INPUT__23_OF_23__SCRIPT_ERROR_0
scope: "Exactly two repo files: variant3d/tests/t_select_rect.gd and this report. Plus the requested backup copy inbox/backup/t_select_rect.gd.bak-S1INPUTFIX. No game code, harness helper, other atom, manifest, fixture, config, app/** or git edit."
owns:
  - "variant3d/tests/t_select_rect.gd"
  - "docs/coord_swarm_2026-11-25/reports/S1_INPUT_FIX.md"
backup: inbox/backup/t_select_rect.gd.bak-S1INPUTFIX (SHA-256 verified equal to pre-edit file)
validation: "variant runner only; windowed job s1inputfix-run (ticket 407, camera-pose iteration) and final windowed job s1inputfix-run2 (ticket 414, PASS 23/23, exit 0, SCRIPT ERROR 0). No direct godot, no full gates."
labels: [REAL_INPUT, WINDOWED, STRETCH_CONVENTION, EXPECTED_FAILURE_MARKERS_RETAINED, NO_WEAKENING]
---

# S1-INPUT-FIX — report

## Goal

Remove the two non-parse blockers ATOM-REPAIR deliberately left in
`variant3d/tests/t_select_rect.gd` so the S1 ladder row can execute its
real-input drag path:

1. a **headless-only guard** at `:262` that aborted every windowed launch;
2. synthetic `Input.parse_input_event` coordinates that may be **stretch-scaled**
   and therefore not match `camera3d.unproject_position()` output.

The game code (SEL-01) is already green (selftest 29/29, uitest 17/17,
external real-handler probe 12/12 — `SEL_01_implementation.md:14-16,66-77`);
no game file was touched here.

## Sources read (read-only)

| Source | What it supplied |
|---|---|
| `reports/ATOM_REPAIR_report.md:91-92` | The two explicit hand-off blockers, with the exact atom line (`:262`) and the stretch concern |
| `reports/TEST_S1_report.md:69-70,95-121,139-155` | Original headless guard intent, full assertion list, expected pre-fix failures |
| `reports/SEL_01_implementation.md:72,74-76,110-117,119-124` | Windowed atom failed before boot on the guard; headless probe 324 stretched input ×20; probes 326/329 green; off-screen projected `p0` artifact |
| `reports/CAM_RV_01_view_rect_runtime.md:88-94,145-172,199-210` | **Proven windowed real-input pattern**: 1280×720 window, verbatim `Input.parse_input_event`, job 381 `ok` 20/20, `SCRIPT ERROR` 0; headless job 373 input unusable |
| `variant3d/tests/t_view_rect_rv.gd:130-158,218-239,392-401,487-505` | CAM-RV-01's exact event construction, known-camera-pose setup and frame sequencing |
| `variant3d/project.godot:12-19`, `variant3d/scripts/main.gd:206,230-244,601-605,1156-1193`, `variant3d/scripts/camera3d.gd:240-247,252-278` | Stretch convention (`canvas_items`/`expand`, 1280×720), screenshot SubViewport, home-building boot focus, SIM→centred projection |

## Root cause of blocker 1 — headless-only guard

Before (atom `:262-264`):

```gdscript
if DisplayServer.get_name() != "headless":
    _abort("headless guard: run with --headless (no GPU/window needed)")
    return
```

Every windowed launch — the **only** mode in which real input can be delivered —
was rejected before boot. `SEL_01_implementation.md:72` records job 320
(`sel01-tselect-win`) failing *before boot* on exactly this guard;
`ATOM_REPAIR_report.md:91` hands it off untouched. Meanwhile CAM-RV-01 proved
real `Input.parse_input_event` works in a windowed 1280×720 run
(`CAM_RV_01_view_rect_runtime.md:151`, job 381: `ok`, 20/20, `SCRIPT ERROR` 0)
and is unusable headless (`:159-166`, job 373: root viewport 64×64, nothing
reached `_unhandled_input`). The guard therefore selected precisely the mode
that cannot exercise the atom's subject.

**After:** the guard is inverted. Headless is an explicit non-pass:

```gdscript
if DisplayServer.get_name() == "headless":
    _run_mode = "headless_skip"
    _abort("SKIP_CAPTURE: real-input drag path requires windowed mode; ... No fake PASS.")
    return
_run_mode = "windowed_real_input"
```

`_abort()` calls `check(..., false, ...)` → `_ok = false` → `_finish()` writes
`"passed": false` and `"capture_path": "SKIP_CAPTURE (headless): ..."`, then
quits 1. No headless run is presented as a PASS. Windowed launches proceed
into the real drag path.

## Root cause of blocker 2 — stretch-scaled synthetic coordinates

`project.godot:18-19` sets `window/stretch/mode="canvas_items"`,
`aspect="expand"`. `Input.parse_input_event()` delivers `ev.position` in the
**root-window** viewport space, whereas `camera3d.unproject_position()`
(`camera3d.gd:273-278`) returns pixels in the **camera's** projection viewport —
the 1280×720 `Screenshot3DViewport` that `main.gd:1180-1193` creates in windowed
mode. SEL-01 measured the mismatch in headless: window 64×36 → viewport
1280×720 scaled injected mouse positions ×20
(`SEL_01_implementation.md:74`, probe 324), which is why its green probes 326/329
delivered events straight to `_unhandled_input` instead. ATOM-REPAIR did not add
a speculative transform (`ATOM_REPAIR_report.md:92`).

**After:** an explicit stretch transform was added and applied to every
synthetic button/motion event:

```gdscript
var proj: Vector2 = Vector2(_cam.get_viewport().size)  # projection space
var win: Vector2 = Vector2(root.size)                  # root-window space
return Vector2(p.x * win.x / proj.x, p.y * win.y / proj.y)
```

This is the convention CAM-RV-01 proved: in its final windowed job 381,
`root_viewport_px == viewport_px == [1280,720]` and a verbatim click at
`(640,360)` reached the real handler (`CAM_RV_01_view_rect_runtime.md:88-94,151`).
Here the transform consequently evaluates to the **identity** — measured
`event_coord_scale = [1.0, 1.0]`, `root_viewport_px = [1280,720]`,
`projection_viewport_px = [1280,720]` in the final result JSON — so the drag
rect lands exactly on the intended units. Headless, where the two spaces differ,
is the skip branch above rather than a fake coordinate fix.

## Additional additive harness setup (same CAM-RV-01 proven pattern)

The first windowed run failed before the drag: `projected_pixels_in_viewport`
reported `p0=(-246.7, 548.4)`, `p1=(290.4, 819.7)` against a 1280×720 viewport.
Cause: `main.gd:601-605` focuses the camera on the player's **home building**,
not map centre, so the atom's fixed centre-box SIM points fell outside the view
(the same artifact SEL-01 noted at `SEL_01_implementation.md:114-117`). This is
not a stretch-scale failure and not a game bug.

Reusing CAM-RV-01's setup verbatim (`t_view_rect_rv.gd:228-239`; report
`CAM_RV_01_view_rect_runtime.md:159-166` records the headless edge-scroll drift
and its neutralisation) — `camera.jump_to_world(half_map)` plus `edge_margin = 0.0` and
`corner_margin = 0.0` — makes the projection deterministic and keeps the pose
from drifting between configure and assertions. It is **additive harness setup
only**: no assertion, threshold, marker or expected value was altered.

## Before → after (file-local)

| Location | Before | After |
|---|---|---|
| `:262` `_initialize()` | reject every non-headless launch | headless → `SKIP_CAPTURE`, `passed=false`, exit 1; windowed → real-input path |
| `_to_event_coord()` (new) | none | explicit root/projection stretch transform; applied to `ev.position` and `ev.global_position` in both `_send_mouse_button()` and `_send_mouse_motion()` |
| `_configure()` | camera left at home-building focus | `jump_to_world(half)` + edge/corner margins zeroed (CAM-RV-01 pattern); camera target recorded in JSON |
| `_finish()` JSON | `capture_path` said "headless"; `runner_declaration` said "AUTHORING ONLY — no Godot run" | accurate windowed `capture_path`, new `run_mode` field, validation reference |
| `_m["headless"]` | hardcoded `true` | derived from `DisplayServer.get_name()` |

## Backup

`copy variant3d\tests\t_select_rect.gd inbox\backup\t_select_rect.gd.bak-S1INPUTFIX`
— taken **before** the first edit. SHA-256 of original and backup both
`96074A5DC037D8C25D8E35C308BD08ED2DC6DD4BF9C564F5031A284CB92583A7`.

## Validation — variant runner only, Windows `python`, windowed

Command form (no `--headless`; fixture + screenshot menu-skip flag, exactly the
CAM-RV-01 job-381 shape):

```
python variant3d\tools\godot_runner.py run --id <id> --timeout 300 -- `
  --path variant3d --script res://tests/t_select_rect.gd -- `
  --config <ABS>\variant3d\tests\fixtures\small_map_64.json `
  --screenshot <Temp>\s1inputfix_smallmap64.png
```

| Ticket | id | Mode | Status / exit | wait / run | Result | `SCRIPT ERROR` |
|---:|---|---|---|---|---|---:|
| 407 | `s1inputfix-run` | windowed, real input | `failed` / 1 | 203.14 s / 47.16 s | `FAIL 5/7` — `projected_pixels_in_viewport` + `boot_and_setup` (camera focus off-screen; see above) | 0 |
| 414 | `s1inputfix-run2` | windowed, real input | **`ok` / 0** | 268.16 s / 46.72 s | **`PASS 23/23`** | **0** |

Artifacts:
`variant3d/.godot_queue/results/000004{07,14}.json` and
`.../000004{07,14}_s1inputfix-run{2}/stdout.txt`, `stderr.txt`.
Result JSON: `variant3d/tests/results/t_select_rect.json`
(`"passed": true`, `23/23`, `run_mode: windowed_real_input`).

### Checks — final job 414 (all 23 PASS)

`boot_real_64_3d_game`, `hud_visible`, `test_entities_exact`,
`cmd_spy_installed`, `picking3d_bound`, `projected_pixels_in_viewport`,
`unproject_matches_world_to_px`, `drag_crosses_port_6px_threshold`,
`ground_endpoints_finite`, `drag_crosses_donor_0.005m_epsilon`,
`drag_start_from_real_event`, `world_sel_active_during_drag`,
`overlay_rect_during_drag` **(marker `expected_pre_fix_failure: true`, now PASS)**,
`overlay_hidden_after_release` **(marker `expected_pre_fix_failure: true`, now PASS)**,
`selected_ids_exact`, `unit10_selected`, `unit11_selected`,
`unit12_not_selected`, `building_not_selected`,
`building_inside_rect_but_excluded_by_kind`, `cmd_counter_zero_after_drag`,
`short_click_selects_single_unit`, `cmd_counter_zero_after_click`.

**Failures in final job: none.** The two overlay checks carry the retained
`expected_pre_fix_failure` marker but now pass because SEL-01's
`SelectionRectOverlay` exists (`SEL_01_implementation.md:58,88`); the marker was
not cleared. First job 407's two failures are listed above and were resolved by
the additive camera-pose setup, never by relaxing a predicate.

Key measured values (job 414): `p0=(395.262,273.539)`, `p1=(917.084,457.888)`,
`click=(512.029,337.395)`, `viewport=1280×720`, `root_viewport=1280×720`,
`event_coord_scale=[1,1]`, drag `|p1-p0|=553.43 px > 6 px`, world delta
`24.3009 m > 0.005 m`, ground rect `(51.810,54.407)–(76.111,71.214)`,
overlay during drag exactly `Rect2(p0,p1).abs()` and visible, hidden with empty
rect after release, selected `[10,11]`, short click selects `[10]`, cmd calls
`{}` both times. stderr contains only a pre-existing RID leak at exit, not a
`SCRIPT ERROR`.

## Explicit no-weakening statement

- `check()` call count is **24** in both backup and final file; `expected_pre_fix_failure`
  occurrences **4** in both; `EXPECTED_FAILURE_PRE_FIX` literal **1** in both;
  `_assert_*` call sites **7** in both. No `check()` was deleted, reordered,
  skipped, or given a weaker predicate; no `expected_pre_fix_failure` marker was
  cleared; there is no `CHECK_NAMES` array in this atom, so none was touched.
- The two blockers were fixed by changing **which mode runs** and **which
  coordinate space is delivered**, plus additive camera setup. No threshold
  (`PORT_DRAG_PX = 6.0`, `DONOR_EPSILON_M = 0.005`), expected id set, overlay
  expectation or verdict rule was modified. A headless run still ends
  `passed=false` / exit 1.
- No game code was edited to make the run pass; the only implementation rely-on
  is SEL-01's already-landed overlay.

## Open questions / separate tickets

1. The headless `SKIP_CAPTURE` branch is enforced by code and was **not** run
   separately here (a headless atom run would overwrite the green result JSON).
   A coordinator smoke can confirm the literal `SKIP_CAPTURE` stdout if wanted.
2. The atom's `runner_declaration` string names the first validation id
   `s1inputfix-run`; the final green id is `s1inputfix-run2` (ticket 414). This
   is descriptive JSON metadata, not an assertion, and was left byte-identical
   to the validated file.
3. The two `expected_pre_fix_failure` markers are now stale-but-retained by
   instruction. Whether a later ticket flips them to `false` is a coordination
   decision, not this repair.
4. Shift=add remains a declared divergence, not an assertion
   (`TEST_S1_report.md:123-130`; `input_controller.gd` drag branch ignores Shift).
5. No PNG/visual capture is asserted by this atom; per `TEST_MATRIX.md:58` a
   second agent must re-check any capture before an S1 row is called PASS — the
   JSON/stdout above is the re-check surface here.
6. The camera-pose setup focuses map centre; a future variant with a different
   focus would need its own projected-pixel expectations recalculated.

## Summary

Both blockers are removed from `variant3d/tests/t_select_rect.gd`: the guard now
runs the real-input path windowed and turns headless into an explicit
`SKIP_CAPTURE`/`passed=false` non-pass; synthetic events are transformed with
the root/projection stretch convention CAM-RV-01 proved (identity in the proven
1280×720 windowed mode, measured `[1,1]`). An additive camera-pose setup from
the same CAM-RV-01 pattern fixed the off-screen projection observed in the
first windowed job. Final windowed job **414** (`s1inputfix-run2`) is green:
**23/23 checks, exit 0, `SCRIPT ERROR` 0**, with every assertion and
`expected_pre_fix_failure` marker intact.

**No other file was edited by this ticket** — no `input_controller.gd`,
`camera3d.gd`, other atom, harness helper, manifest, fixture, config, `app/**`
or git state. The only extra file is the requested backup copy. No direct
`godot` was launched; no full gate or ladder was run. Concurrent modifications
seen in `variant3d/scripts/{config,menu,selftest}.gd` belong to other swarm
agents and were not made here.
