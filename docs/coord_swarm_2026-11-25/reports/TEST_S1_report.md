---
id: TEST-S1
title: "TEST-S1 — author the real-input selection-rectangle atom (t_select_rect.gd)"
owner: TEST-S1 (test-authoring micro-worker)
date: 2026-11-25
status: AUTHORING_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_PASS_CLAIM
scope: "Exactly two files authored: variant3d/tests/t_select_rect.gd and this report. No source, config, fixture, manifest, gate, git or other test edit."
owns:
  - "variant3d/tests/t_select_rect.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_S1_report.md"
labels: [REAL_INPUT, DRAG_RECTANGLE, EXPECTED_FAILURE_PRE_FIX, HEADLESS, NO_RUN]
evidence_labels: [observed, derived, inferred]
---

# TEST-S1 — real-input selection-rectangle atom, authored

## Goal

Author ONE new `extends SceneTree` atom that exercises the **real** 3D
drag-select path with injected mouse events — not the fake `uitest select_box`
step — on the committed 64² map, and asserts both the functional selection
result and the still-missing screen-space marquee overlay. The overlay assertion
is retained and flagged `EXPECTED_FAILURE` pre-fix; nothing is weakened to make
the atom green. No Godot process was started, no runner ticket was submitted,
and **no pass is claimed**.

## Sources read (all read-only)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md` row S1 (`:220`), facts 7/8/10 (`:99-133`) | S1 row shape, screenshot/HUD facts, "no 3D marquee" fact |
| `.../V3D_01_selection_rectangle_audit.md` §"Smallest automated test proposal" (`:338-383`), break point 1 (`:248`) | 3-unit probe, real-event sequence, overlay assertion, expected pre-fix result |
| `.../DSEL_01_donor_selection_rectangle.md` claims 1–7/18 (`:92-109`), pseudocode (`:121-214`), claim 27/28 (`:118-119`) | donor 0.005 m epsilon, Shift=add, LMB-up finalize, yellow box, port divergence |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,26,53-58` | S1 row, common-map rule, one-Godot / `python` rules, second-agent re-check rule |
| `variant3d/tests/t_pick3d.gd:12-16,22-46,53-71,181-239` | atom layout, `check()`/result JSON, `cmd_*` counter pattern, deferred quit |
| `variant3d/tests/_template_test.gd:1-38` | result path `res://tests/results`, `call_deferred("quit", …)` |
| `variant3d/tests/t_smallmap_terrain.gd:9-16,174-231` | real `main.tscn` boot pattern, first-frame inspection, `--config` handling |
| `variant3d/scripts/testbridge.gd:116-142` | `InputEventMouseButton` / `InputEventMouseMotion` event pattern (`Input.parse_input_event`) |
| `variant3d/scripts/input_controller.gd:9,199-217,528,543-554,555-663,1158-1172` | typed `game: C3Game`, `_set_selection`, drag state, 6 px threshold, minimap guard, `world.sel_rect` mirror |
| `variant3d/scripts/camera3d.gd:222-229,234-252,255-275` | SIM→centred conversion, `world_to_px`, `unproject_position`, `screen_to_world` |
| `variant3d/scripts/main.gd:168-244,1096-1097,1180-1193,1527-1543,1662-1672,1821-1853` | menu skip, HUD hide, screenshot viewport, saver/quit timing, headless branch |
| `variant3d/scripts/game.gd:82-104,1988-2040,2152,2585-2590,2839-2999,3124,3157,4187-4247` | `spawn()`, entity fields, exact `cmd_*` signatures for the spy |
| `variant3d/scripts/data.gd:582,591,1248` | valid unit/building sids (`peasant`, `pikeman`, `cen`), `TILE_M` |
| `variant3d/tests/fixtures/small_map_64.json:1-16` | 64² fixture shape, inherited seed/render mode |

## Capture path chosen

**Real boot path.** The atom instantiates `res://scenes/main.tscn` and requires
`--config <abs small_map_64.json>` plus a `--screenshot <path>` user arg. The
screenshot arg is used **only** as the menu-skip / full-game-boot flag
(`main.gd:206,230-244`), exactly as the proven 64² harness does
(`TEST_01_smallmap_harness.md:198-202`). After boot the atom:

- re-shows `hud.visible = true` because `--screenshot` hides it
  (`main.gd:1096-1097`, TEST-01 fact 8);
- raises `screenshot_frames`, sets `screenshot_done`, clears `ais` and sets
  `speed = 0` so main cannot save-and-quit or move the camera mid-drag
  (`main.gd:1543,1670-1672,1821-1853`);
- asserts structurally in a **headless** run. No PNG is the assertion surface.

**Why not a self-owned SubViewport:** the target defect is a missing
`CanvasLayer` overlay, not a pixel defect. A private viewport would duplicate
main's already-proven `Screenshot3DViewport` seam (`main.gd:1180-1193`) and
still would not draw a marquee that no code renders (`V3D-01:187-199,248`).
Headless also cannot capture 3D at all (`main.gd:1156-1158,1790-1800`;
TEST-01 fact 7). The dummy screenshot path therefore satisfies the requested
boot form without pretending to be visual evidence.

**Headless guard:** non-headless launches fail with a `headless guard` check
before boot; the atom deliberately needs no GPU/window.

## Real-input sequence (exact)

Deferred to the first frames (`_process` stage machine), never `_initialize()`
(empty viewport/camera reason: `V3D-01:359-361`):

1. `InputEventMouseButton` LMB **pressed** at `p0` → `Input.parse_input_event`
   (`testbridge.gd:121-127`).
2. `InputEventMouseMotion` at `p1` with `button_mask = MOUSE_BUTTON_MASK_LEFT`
   so `input_controller.gd:662-663` sets `dragging = true`.
3. `InputEventMouseButton` LMB **released** at `p1` → `input_controller.gd:610-647`.
4. Short click at `p_click` (same press/release pattern, < 6 px movement) for
   click-pick regression.

`p0`, `p1`, `p_click` come from `camera3d.unproject_position()` on SIM→centred
ground points (`camera3d.gd:222-229,246,255-260`); `world_to_px()` agreement is
asserted. Corridor chosen near map centre: SIM box corners `half + (-12,-8)` and
`half + (12,8)`; units 10/11 at `half + (-6,-2)` / `half + (4,4)`; unit 12 at
`half + (40,40)` (outside); building 13 at `half + (0,0)` (inside the box).

## Exact assertions and citations

| Check name | Expected | Citation / rationale |
|---|---|---|
| `headless guard` | run only with `--headless` | `main.gd:1156-1158`; TEST-01 fact 7 |
| `config_fixture`, `screenshot_skip_flag` | both user args present and fixture resolvable | TEST-01 facts 3/6; `small_map_64.json:10-15` |
| `boot_real_64_3d_game` | main booted, `render_mode == "3d"`, `MAP_W/H == 64` | `main.gd:181-182,230-244`; TEST-01 §"Smallest-map determination" |
| `hud_visible` | HUD restored after boot | `main.gd:1096-1097` |
| `test_entities_exact` | ids `[10,11,12,13]`: 3 friendly units + 1 building; all generator entities pruned | V3D-01 `:351-357`; isolation required for exact id set |
| `cmd_spy_installed` | `input_ctl.game` is a `C3Game` subclass spy | `input_controller.gd:9` (typed field); `game.gd:2839-2999` (cmd sites) |
| `picking3d_bound` | `bind_3d()` adapter present | `input_controller.gd:114-126`; V3D-01 `:68-70` |
| `projected_pixels_in_viewport`, `unproject_matches_world_to_px` | drag pixels finite and inside viewport; helper agrees | `camera3d.gd:255-260`; V3D-01 `:319-323` |
| `drag_crosses_port_6px_threshold` | `|p1-p0| > 6.0` px | `input_controller.gd:613,662-663`; DSEL-01 claim 27 |
| `ground_endpoints_finite`, `drag_crosses_donor_0.005m_epsilon` | `picking3d.ground_point()` endpoints finite; world delta `> 0.005` m | `input_controller.gd:455-462`; `picking3d.gd:235-243`; DSEL-01 claim 1 / `onmousemove.inc:32-34` |
| `drag_start_from_real_event` | press event reached `_unhandled_input` (`drag_start ≈ p0`) | `input_controller.gd:528,556,608-609,543-554` |
| `world_sel_active_during_drag` | existing SIM-mirror state set while dragging | `input_controller.gd:1164-1172`; `world3d.gd:126-127` |
| `overlay_rect_during_drag` — **EXPECTED_FAILURE pre-fix** | `CanvasLayer` overlay found, visible, reports `Rect2 == Rect2(p0,p1).abs()` (≤ approx tolerance) | DSEL-01 claim 18 / `brushes\selection.cfg:3-14`; V3D-01 `:317-332,248`; no draw consumer at `world3d.gd:126-127` |
| `overlay_hidden_after_release` — **EXPECTED_FAILURE pre-fix** | same overlay hidden / empty / removed after release | DSEL-01 claim 6 / `onmousedown.inc:364-390`; V3D-01 `:372-373` |
| `selected_ids_exact` | selected ids `== [10,11]` | `input_controller.gd:619-624`; V3D-01 `:369-370`; DSEL-01 verification recipe `:368-375` |
| `unit10_selected`, `unit11_selected`, `unit12_not_selected` | `e.selected` flags match id set | `input_controller.gd:207-217`; `game.gd:2585-2590` |
| `building_not_selected` + `building_inside_rect_but_excluded_by_kind` | building lies inside measured ground rect yet is NOT selected → exclusion is the **kind** filter, not geometry | `input_controller.gd:620` (`kind != "unit"`); DSEL-01 claim 27 |
| `cmd_counter_zero_after_drag` | spy `cmd_*` call total `== 0` | `picking3d.gd:4-8` contract; `t_pick3d.gd:234-236`; DSEL-01 recipe step 2 |
| `short_click_selects_single_unit` | short click selects only `[10]` | `input_controller.gd:625-645`; `picking3d.gd:266-301`; V3D-01 `:375` |
| `cmd_counter_zero_after_click` | spy total still `== 0` | same as above |

Result JSON: `res://tests/results/t_select_rect.json` with `passed`, per-check
`expected_pre_fix_failure`, measured pixel/ground rects, overlay probes, cmd
calls, `donor_semantics` (0.005 m epsilon, Shift=add declared, 6 px port
threshold), `capture_path`, and `runner_declaration`. Exit:
`call_deferred("quit", 0 if _ok else 1)`; runner stderr must still be scanned
externally (`smallmap_capture.py scan-stderr`), per TEST-01 fact 5.

**Donor semantics encoded, not silently dropped:** `donor_semantics.world_epsilon_m
= 0.005`, `drag_start = first LMB-held move` (DSEL-01 claim 3), `shift = "add"`
(claim 4) with the explicit note that the port drag ignores Shift (claim 27,
`input_controller.gd:624`). This atom does **not** assert Shift-add: the pending
change is the overlay fix, so adding a second independent donor-parity failure
would mix concerns. The drag still crosses both the donor world epsilon and the
port 6 px gate, so a post-fix run cannot pass by exploiting the weaker port
threshold.

**"Neutral" building interpretation (derived):** a politically neutral
(`player != 0`) building would be excluded by `e.player != 0` and would *not*
prove the kind filter. The atom therefore spawns the building with `player = 0`
but `kind = "building"` and calls it neutral in the sense "non-unit target".
`building_inside_rect_but_excluded_by_kind` verifies the geometry is inside the
box, so exclusion can only come from `kind != "unit"`.

## Expected pre-fix failures (do not treat as regressions)

1. `overlay_rect_during_drag` — **EXPECTED_FAILURE**: `world3d.gd:126-127`
   declares `sel_rect`/`sel_active`; grep found no 3D draw consumer
   (`V3D-01:187-199,248`; `DSEL_01` claim 28). No `CanvasLayer` with a rect
   API exists, so the assertion fails loudly.
2. `overlay_hidden_after_release` — **EXPECTED_FAILURE** for the same reason
   (no overlay node to hide). It is retained as the post-condition of the fix,
   not deleted or relaxed.
3. Functional checks (`selected_ids_exact` etc.) are **UNVERIFIED until a run**:
   V3D-01 rates the functional branch present but geometrically approximate
   under the −32° perspective (`:249-250,412-423`). If the measured ground rect
   over-selects, those checks will fail too; that is real evidence, not to be
   suppressed.
4. Projected-pixel / ground-endpoint checks may fail if the default headless
   viewport size differs from `Data.WINDOW_WIDTH/HEIGHT`; the measured values
   are written to JSON for diagnosis rather than adjusted silently.

**No pass claim:** nothing in this report asserts that the atom runs green. It
is an authored, unexecuted test.

## Launch form (documentation only — NOT executed)

```
python variant3d\tools\godot_runner.py run --id <ticket>-S1 --timeout 40 -- \
  --headless --path variant3d --script res://tests/t_select_rect.gd -- \
  --config <ABS>\variant3d\tests\fixtures\small_map_64.json \
  --screenshot <temp>\smallmap64_select_rect.png
```

One Godot at a time; Windows `python`, never `python3`
(`TEST_MATRIX.md:53-58`). Manifest registration and `test_all.py` root fixes
remain separate integration work (`TEST_01_smallmap_harness.md:257-267`); this
ticket did not touch them. Per `TEST_MATRIX.md:58`, a second agent must re-check
any capture before a row is called PASS — this atom produces no visual capture,
so the JSON/stdout evidence is what a re-checker must inspect.

## Open questions

1. Will `Input.parse_input_event` motion with `button_mask` reach
   `_unhandled_input` reliably in a headless `SceneTree` atom with the HUD
   re-shown? Static reading says yes (`input_controller.gd:528,650-663`;
   `hud.gd:354,1409-1443`), but V3D-01 open question 2 remains unmeasured.
2. Will the ground-AABB round trip (`unproject → ground_point`) contain exactly
   units 10/11 under real 64² terrain relief? The 6 m margin should absorb
   small ray-heightfield shifts, but this is derived, not measured.
3. What public API will the overlay fix expose? The probe accepts a tagged or
   `select`+`rect`-named `CanvasLayer` with `get_selection_rect()`,
   `selection_rect()`, `get_rect()` or a `selection_rect` Rect2 property. If the
   fix uses another shape, the probe must be extended by the integrating owner.
4. Should Shift-add and donor composition filters (buildings/water/guards/
   squads, DSEL-01 claims 10-12) get their own atom after the overlay fix?
5. If the coordinator requires politically neutral buildings, flipping id 13
   to `player = 1` makes `building_not_selected` trivial; a separate
   player-0 building case would then be needed to keep the kind-filter proof.
6. Does the selection aura render in a windowed 64² capture? Not asserted here;
   TEST-01 open question 4 stays open.

## No-runner declaration

**AUTHORING ONLY.** No Godot process was started, no `godot_runner.py` job was
submitted, no result JSON was generated, and no pass/FAIL verdict was observed.
Only the two declared files were written: `variant3d/tests/t_select_rect.gd` and
this report. All runtime statements above are expectations, not measurements.
