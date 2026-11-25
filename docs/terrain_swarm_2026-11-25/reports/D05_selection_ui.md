---
id: D05
title: "D05 — non-quad selection UX audit (marquee style, hover, sounds, Shift/Ctrl/double-click, Ctrl+A, click-through, wall bug, HUD overflow)"
area: variant3d / selection UX / HUD
owner: D05 (READ-ONLY audit subagent)
date: 2026-11-25
status: READ_ONLY__NO_EDITS__NO_RUNNER_JOBS__RANKED_DEFECT_TABLE_DELIVERED
scope: "Read-only audit of variant3d/scripts/{hud.gd,hud3d_adapter.gd,input_controller.gd,audio.gd}, config.gd/config.json, the AUDIO_SEL_01/AUDIO_SEL_02/UI_TOPBAR_01/CONFIG_WIRE_SEL reports, the gamepressure UI guide (charter URL), and landed HUD/selection reports. No code, test, config, asset or report file other than this one was written. No Godot process or runner job was submitted."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION, DONOR_CITED, ALREADY_FIXED_UNVERIFIED]
donor: "gamepressure UI guide https://www.gamepressure.com/cossacks3/user-interface/zd91b1 (read this session); donor facts otherwise taken from landed read-only reports (DSEL-01, RV-SEL-01, DEC-08, DAUDIO-01). No donor binary run, no donor GPU A/B frame."
---

# D05 — selection UX beyond the quad

Label key: **[O]** observed in a cited file/artifact; **[D]** derived from observed control flow;
**[I]** inferred; **UNVERIFIED** = no evidence obtained; **PORT APPROX** = port-side
approximation, explicitly **not** a donor-parity claim. All `file:line` values refer to the
current working tree at audit time.

## 0. Executive verdict

The owner's "many UI things are not ok" maps to **three live functional gaps** in the
non-quad selection UX — the entire **Ctrl+click family**, **Shift+click on empty ground**,
and **Shift+double-click** — plus **two feedback risks** (hover cursor over HUD; the top
strip's deliberate click-through). The marquee colour/width, selection sounds, Shift-add
drag, Ctrl+A/Z same-type hotkeys and the 1024/1280/1920 HUD overflow are **already fixed**;
only the HUD overflow is runner-verified at the tested sizes, the rest are
code/citation-verified but **visual/audible/live-key UNVERIFIED**. The donor's "box select
after selecting a wall" quirk is **not reproduced** by code inspection; keep it that way.

## 1. Sources read (read-only)

| Source | What it provided |
|---|---|
| `variant3d/scripts/input_controller.gd:1-1473` | Selection click/drag/Shift/double-click branches, `_set_selection()`, hotkey dispatch, `_update_cursor()`, marquee painter/overlay, `_unhandled_input()` |
| `variant3d/scripts/hud.gd:1-1702` | Top bar construction/_layout_top, `mouse_filter`, bottom panels, minimap input, selection panel |
| `variant3d/scripts/hud3d_adapter.gd:1-234` | 3D minimap box/quad adapter (quad geometry itself is out of D05 scope) |
| `variant3d/scripts/audio.gd:1-477` | `selection_clip()` / `play_selection()` API, non-positional `play()` and its 0.09 s debounce |
| `variant3d/scripts/config.gd:46-53,178-224,416-473`; `variant3d/config.json` | `features.selection.*`, hotkey defaults vs **shipped overrides**, getter fallbacks |
| `docs/coord_swarm_2026-11-25/reports/AUDIO_SEL_01.md`, `AUDIO_SEL_02.md` | Sound API and its integration; explicit open questions on empty/building selections |
| `docs/coord_swarm_2026-11-25/reports/UI_TOPBAR_01.md`, `CONFIG_WIRE_SEL.md`, `CONFIG_WIRE_HUD.md`, `MINIMAP_TIP_01.md`, `HUD_LAYOUT_01.md` | Top-bar overflow fix, marquee config wiring, layout atom result |
| `docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md` rows 5, 11, 16, 19-22, 26, 290-297 | Donor click semantics (Ctrl, Shift, highlight, sounds, hotkeys) and port divergences |
| `docs/research/RE_VISUAL.md:46` (S11) and live fetch of the guide | Donor HUD read-outs and the exact hotkey wording used below |
| `variant3d/tests/results/t_select_rect.json` (23/23), `t_hud_layout.json` (62/62), `uitest.json`, `selftest.json` | Existing verification artifacts; none produced by D05 |
| `docs/terrain_swarm_2026-11-25/CHARTER.md:71-85`, `F04_quality_reviews.md:121-126` | Owner's wall-bug "do NOT copy" rule and drag-selection canon |

## 2. Ranked defect table

Severity: **P1** = an owner-visible donor hotkey/gesture is absent or destructive;
**P2** = misleading feedback / click routing; **P3** = latent or parity-label debt.

| # | Sev | Defect / owner symptom | file:line | Evidence | Minimal fix plan | Status |
|---:|---|---|---|---|---|---|
| 1 | **P1** | **Ctrl+click does not select all same-type units.** Donor: "clicking a unit while holding **CTRL** ... selects all units of the same kind" (guide); DSEL-01 row 16 (`onmousedown.inc:281-344`, `misc.script:6409+`). The LMB click branch has only double-click and Shift tests; `KEY_CTRL` appears nowhere in `_unhandled_input()`. | `input_controller.gd:790-809` (click branch); grep: no `KEY_CTRL` in this file | **[O]** code; **[O]** donor report/guide | In the click branch, before the double-click test, read `Input.is_key_pressed(KEY_CTRL)`; for an own (`e.player == 0`) unit call the existing `_all_same_type(add)` path (`input_controller.gd:1059-1071`) with Shift deciding add-vs-replace. Keep `last_click_t/last_click_sid` writes intact. Do **not** alter the drag branch (donor drag-Ctrl is commented out, DSEL-01 row 5). | **OPEN** |
| 2 | **P1** | **Ctrl+click on an already-selected object does not remove it.** Donor `_misc_RemoveUnitsFromSelection` (`onmousedown.inc:301-302,346-355`, DSEL-01 row 16). Port has no click-Ctrl removal; only the drag-Ctrl omission is documented. | `input_controller.gd:790-809` (same branch) | **[O]** code; **[O]** donor report | Fold into #1: if Ctrl held **and** the clicked entity is already in `selected_ids`, remove just that entity and apply via `_set_selection()`; otherwise run same-type add. Preserve the no-op/sound behaviour for empty clicks (#3). | **OPEN** |
| 3 | **P1** | **Shift+click on empty ground clears the selection.** Donor skips deselect while Shift is held (`onmousedown.inc:346-355`: `if not Shift and not Ctrl: _control_DeselectAllUnits(False)`). Port's Shift union branch is gated on `not e.is_empty()`; an empty `_pick` falls through to `_set_selection([])`. | `input_controller.gd:801-807` (Shift branch), `:807` (fallback) | **[O]** code; **[O]** donor report | Move the Shift test outside the `not e.is_empty()` guard: `var base := get_selected() if shift else []`; append `e` when non-empty; `_set_selection(base)`. When `e` is empty and Shift held, return without applying (avoids a spurious selection sound, see #8). The **drag**-Shift union at `:773-787` is already correct (`spmAdd`) — leave it byte-identical. | **OPEN** |
| 4 | **P2** | **Shift+double-click drops the previous selection.** Donor same-type select takes `GUI_Shift` (`onshortcut.inc:135`; pseudo at DSEL-01 `:143`); the guide says "Combine this with holding **SHIFT** to instantly add more units to selection." Port's double-click branch always replaces. | `input_controller.gd:792-800` (double-click branch, `_set_selection(arr2)` at `:800`) | **[O]** code; **[O]** donor report/guide | When Shift is held, union `arr2` with `get_selected()` (dedupe by id) before `_set_selection`, mirroring the existing drag union at `:773-787`. | **OPEN** |
| 5 | **P2** | **Hover cursor is computed through the world even when the pointer is over HUD.** `_update_cursor()` runs every `_process` frame with no HUD hit-test; `_screen_to_world(mp)` + `_pick()` can set `attack`/`captureattack`/`gain*` cursors while pointing at the top bar, bottom panels or minimap. Donor keeps `crDefault` over GUI (`cursors.lib:5-12`, `doupdatecursor.inc:4,6-12,104-106`, cited in `MINIMAP_TIP_01.md` §1 item 6). | `input_controller.gd:1388` (call), `:1400-1473` (scan), `:1429-1440`; `hud.gd:394-402` (IGNORE strip) | **[O]** code; **[O]** donor citation | At the top of `_update_cursor()`, `_set_cursor("default")` and return if `get_viewport().gui_get_hovered_control()` is a HUD Control, or if the point lies inside `hud.top_panel/sel_panel/cmd_panel/minimap_panel.get_global_rect()`. Keep the mode overrides (build/attack/guard/rally) above the guard, as they are already instant. | **OPEN** (live cursor capture UNVERIFIED) |
| 6 | **P2** | **Click-through UI: the top strip is deliberately `MOUSE_FILTER_IGNORE`, and `_unhandled_input()` has no UI guard.** A press/release over the empty top-bar band sets `drag_start`/`dragging` and can select or order; RMB issues `_right_order`. If the owner means "HUD clicks reach the world", this is the cause. Bottom panels and the minimap keep default STOP and already block. | `hud.gd:394-402` (`top_center`/`top_panel` IGNORE), `:674-708` (bottom panels: no override ⇒ STOP); `input_controller.gd:663-847` (no hovered-Control test), `:672-695` (minimap rect fallback) | **[O]** code; donor parity **UNVERIFIED** | **Decision required, do not flip unilaterally.** Either set `top_panel.mouse_filter = STOP` (children still take clicks; empty band stops blocking world), or keep IGNORE and add an explicit `gui_get_hovered_control()` guard in `_unhandled_input()` that distinguishes the strip from the map. Record the choice with a donor citation or an explicit PORT APPROX label. | **OPEN / decision** (UI-TOPBAR-01 §2.1 calls the pass-through intentional) |
| 7 | **P3** | **Selection sound fires for an empty selection and misclassifies building-only selections.** `_set_selection([])` reaches the same apply point, so `play_selection("unit", 0)` resolves to `selectpeasant1`; a building-only selection is also `"unit"`. Donor plays `bld<sid>` cues on building selection (`showunitcontrol.inc:1015-1021`) and cleared-panel behaviour is UNVERIFIED. | `input_controller.gd:323-337`; `audio.gd:466-477`; `AUDIO_SEL_02.md` §9 Q1/Q4, `AUDIO_SEL_01.md` §8 Q3 | **[O]** code + landed open questions | Guard the call with `not arr.is_empty()`. For buildings, either reuse the existing `audio.building_sound(sid)` resolver or stay silent — a separate decision; do **not** duplicate the clip table in `input_controller.gd`. | **FIXED (wiring) / OPEN (edge cases)**; audible UNVERIFIED |
| 8 | **P3** | **Selection-sound variant choice is a deterministic count-based PORT APPROX.** Donor used a random start index + linear probe (DAUDIO-01 §4.3); `count` on Shift-add is the applied union size, not the number of new ids. | `audio.gd:466-471`; `input_controller.gd:337`; `AUDIO_SEL_01.md` §8 Q1, `AUDIO_SEL_02.md` §9 Q2/Q3 | **[O]** code; **[O]** donor report | No code change: keep the PORT APPROX label. Only change if a donor trace becomes available; the API contract ("number of selected entities") is already met. | **PORT APPROX / accepted**, donor UNVERIFIED |
| 9 | **P3** | **Marquee colour/width have no pixel-level verification.** The painter draws yellow 1 px solid outline, no fill/no AA, and both values are config-driven; the real-input atom verifies the `Rect2` geometry/visibility only. A malformed `marquee_color` array with <4 entries would error at draw time. | `input_controller.gd:77-100` (`draw_rect` at `:100`), `config.gd:431-436`, `config.json features.selection`; `CONFIG_WIRE_SEL.md` §8 Q3 | **[O]** code; **[O]** donor `brushes\selection.cfg:3-14` | Add a one-frame marquee capture that samples the outline RGB/width, or a pure probe of `SelectionRectPainter._draw()` arguments; clamp/pad the colour array in the getter (`config.gd:431-433`) for malformed config. No donor A/B frame exists — label PORT APPROX if captured internally. | **FIXED / VISUALLY UNVERIFIED** |
| 10 | **P3** | **2D marquee style diverges; 3D `world.sel_rect` mirror is dead.** `world.gd` still draws a white 1.5 px outline + translucent white fill; `world3d.gd` declares `sel_rect/sel_active` but no 3D draw reads them (the overlay in `input_controller.gd` draws instead). | `world.gd:3642-3647`; `world3d.gd:126-127`; `input_controller.gd:1350-1351`, `:187-205` | **[O]** code | Informational: changing the 2D style needs a separate owner; removing the dead 3D mirror is cosmetic. Do not touch either while fixing the quad. | **INFORMATIONAL** |

### Fix ordering

1. Land #1-#3 as one `_unhandled_input()` click-branch hunk (same file, same branch, donor-cited).
2. Land #4 in the same hunk (double-click union).
3. Decide #6 with the owner first; then #5 (hover guard) and #7 (sound guards).
4. #9-#10 only if a capture probe is in scope; do not weaken existing atoms to make them green.

## 3. Checks that are **already correct** (do not "fix")

| Check | Evidence | Status |
|---|---|---|
| **Box-select after selecting a wall (donor bug)** — must NOT be copied | Drag branch `input_controller.gd:766-788` rebuilds `arr` from scratch on every drag (`!dead && player==0 && kind=="unit"`) and applies with `_set_selection(arr)`; no state is carried over from a previously selected wall. Wall selection is just a click-pick → `_set_selection([wall])`. Donor quirk: Charter §1b.2, `F04_quality_reviews.md:125-126`. **[D]** no code path reproduces it. | **NO DEFECT by inspection; live A/B UNVERIFIED.** Note: port box-select excludes **all** buildings including walls/gates; donor has a building branch with walls explicitly un-highlighted (DSEL-01 rows 11/21/262). Any expansion is an owner decision, not a bug fix. |
| **Ctrl+A — select every unit** | `config.gd:194`, shipped `variant3d/config.json controls.hotkeys.select_all`, `input_controller.gd:1311-1315` (`_is(k,"select_all")` → `game.units_of(0)`). Guide: "CTRL + A will select every unit on the map." | **IMPLEMENTED; live key test UNVERIFIED** (uitest `hotkeys_live` does not name Ctrl+A). |
| **Z / Shift+Z / Ctrl+Z / Ctrl+Shift+Z same-type** | `config.gd:197,209,214-215`; `input_controller.gd:1283-1291`, `:1323-1331`, `:1103-1117`. **Important:** shipped `config.json` omits the four donor combo keys, but `_donor_combo()` (`input_controller.gd:1033-1039`) re-parses the literal fallbacks, so Ctrl+Z/Ctrl+Shift+Z/Ctrl+Q/Ctrl+Alt+A still dispatch. `Z` selects all same-type on the map; double-click stays on-screen. | **IMPLEMENTED; live key test UNVERIFIED.** |
| **Shift-add drag** | `input_controller.gd:773-787` unions the rect result with `get_selected()` (donor `spmAdd`, DSEL-01 row 5/95); CONFIG-WIRE-SEL §6 records windowed real-drag `PASS 23/23`. | **FIXED / real-drag VERIFIED;** donor parity UNVERIFIED. |
| **Shift-add click on a unit** | `input_controller.gd:801-805` appends the picked entity when Shift is held. | **IMPLEMENTED; UNVERIFIED live.** (Shift+click on *empty* ground is defect #3.) |
| **Double-click select-same-type (no modifier)** | `input_controller.gd:792-800` picks all same-sid own units inside `world.view_rect`; `CAM_RV-01` (SWARM_BOARD :145) saw double-click select `[10,11,12]` in a live 64² job. | **IMPLEMENTED / runtime-observed for the plain case;** Shift variant defect #4. |
| **Selection sound wiring** | `audio.gd:466-477` exposes `play_selection()`; `input_controller.gd:316-337` calls it **once per `_set_selection()`**, after flags and HUD refresh, behind main.gd's `can_play` gate (`main.gd:652-655,1177-1180`); AUDIO_SEL_02 tickets 487 (parse) and 495 (real-drag 23/23) green. | **FIXED / parse+drag VERIFIED; audible parity UNVERIFIED** (edge cases #7/#8). |
| **Selection highlight (hover/selection feedback material)** | Donor `selection.friend` / `selection.building.<0..3>` / `highlight.*` (DSEL-01 rows 19-21); port procedural rings/aura (`FIXSEL_visuals.md`, DSEL-01 row 296) explicitly "NOT DONOR PARITY". | **PORT APPROX / accepted**; no new fix proposed. |
| **HUD overflow at 1024×576 / 1280×720 / 1920×1080** | `hud.gd:513-595` `_layout_top()`; thresholds/pads tightened by MINIMAP-TIP-01 (`hud.gd:523-525`, `:536`, `:545`). Windowed job `minimaptip01-hudlayout` (ticket 562) → `t_hud_layout.json` `passed:true`, `verdict:PASS`, **62/62 evaluated, 3 recorded skips**, 0 unclipped offenders at all 3 sizes, 3 non-blank PNGs (`MINIMAP_TIP_01.md` §4-5). | **FIXED AND VERIFIED** at those three widths. Caveat: the atom tests *internal containment*, not donor visual parity; minimap renders 194/242/362 px at the three sizes (240 logical slot), a documented intentional port adaptation (`HUD_LAYOUT_01.md` OUT_OF_SCOPE). |
| **uitest / selftest gates** | `variant3d/uitest.json` `passed:true` 17 steps (mtime 2026-11-25 13:30); `variant3d/selftest.json` `passed:true` 29 steps (mtime 14:12, newer than current `input_controller.gd`). Neither was re-run by D05. | **FRESH ARTIFACTS; no new job claimed.** |

## 4. Open questions for COORD / owner

1. Is "clicking through UI" (#6) the empty top-bar band, or a bottom panel/minimap case?
   The bottom panels and minimap already consume input; only the top strip is IGNORE.
2. For #7, should building selections play the existing `bld<sid>` cue, or stay silent?
   Donor plays it (DSEL-01 row 22) but the port's dispatcher only wires it on "done".
3. Should donor wall highlight suppression be copied? Port box-select excludes buildings
   altogether, which avoids the donor bug but also removes wall/gate box selection.
4. A fresh audible selection probe (ship clip, counts 1..7 wrap, empty/building) and a
   live key/Ctrl-click capture would close every UNVERIFIED row above. D05 ran none.

## 5. Scope / honesty statement

- **No code, test, config, asset, queue, gate or report other than this file was edited.**
  No runner job, no Godot process, no donor binary, no A/B frame, no test weakening.
- Donor facts come from the gamepressure guide (fetched read-only this session) and landed
  read-only reports; every port-side visual/audible equivalence remains **UNVERIFIED**
  unless a fresh capture/probe is cited. The wall-bug conclusion is a **derivation from
  control flow**, not a live test.
- The quad's geometry/lifetime/hit semantics (overlay creation, four-corner ground AABB,
  world-rect mirror, minimap quad stroke) belong to the other D-tickets and are deliberately
  not adjudicated here; only its colour/width (#9) and click-through context (#5/#6) were audited.

---
*D05, 2026-11-25. Read-only audit. Ranked defects #1-#6 are the actionable list; #7-#10 and §3 are labels and verification notes.*
