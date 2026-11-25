---
title: UI-TOPBAR-01 — responsive HUD top bar + speed dropdown
status: IMPLEMENTED (parse VERIFIED; runtime 17/17 UNVERIFIED — see §5)
owner_scope: variant3d/scripts/hud.gd + this report ONLY
date: 2026-11-25
---

# UI-TOPBAR-01 — responsive HUD top bar + speed dropdown

## 1. Scope and intent

Owner report: the resource top bar overflows the screen and the row of game-speed
buttons wastes space. Implemented in `variant3d/scripts/hud.gd` only:

1. the top strip is now sized by the viewport (never by its content), with
   responsive modes driven by the **actual** viewport width;
2. the four speed buttons become one `OptionButton` listing pause + donor speeds;
3. the band is visibly shorter (42 px nominal strip vs the old 64 px, with a
   tighter panel style), and one dropdown replaces four buttons plus their gaps.

**No other source file edited.** Not `main.gd`, `hud3d_adapter.gd`, `selftest.gd`,
`uitest.gd`/`uitest.json`, `config.json`, any test, or anything under `app/**`.
The only other file created is the required backup (§4).

## 2. Before → after (line numbers)

Line numbers: "before" = backup / owner report's cited revision; "after" = current
`variant3d/scripts/hud.gd`. Net diff vs backup: **+179 / −34** (213 changed lines,
`git diff --no-index --stat`).

| Concern | Before (backup) | After (current) |
|---|---|---|
| Speed/state declarations | `:105-109` `speed_buttons`, `speed_label` only | `:108-114` `speed_buttons` kept (empty, for API readers), new `speed_menu: OptionButton`, `top_bar: HBoxContainer`, `res_icons: Array` |
| Top strip container | `:165` `var top_center: CenterContainer` | `:172` `var top_center: Control` — child can no longer be sized to an over-wide content minimum |
| `_apply_scale()` top layout | `:312-317` fixed strip `offset_top=8`, `offset_bottom=72` (64 px band, no width input) | `:319-326` calls `_layout_top()` after the generic meta pass, so compact overrides win |
| `_build_top()` | `:381-443`: `CenterContainer` + `PanelContainer` with shared style; local `var bar := HBoxContainer`; 4 speed buttons at `:428-433` (`II / 1x / 2x / 4x`) | `:390-479`: full-width `Control` strip; anchored, clipped panel with `_top_style()`; member `top_bar` with `SIZE_EXPAND_FILL`; **one** `OptionButton` created at `:444-447` (`speed_menu = _mkoption([...], 1)`, `item_selected → _on_speed_idx`) |
| Helpers | none | `:482-604`: `_top_style()`, `_mkoption()`, `_top_fs()`, `_layout_top()`, `_speed_index()`, `_on_speed_idx()` |
| `refresh_speed()` | `:491-494` only sets `speed_label.text` (`PAUSED` / `Nx`) | `:629-638` same label text semantics **unchanged**, plus dropdown sync (programmatic `selected` does not emit `item_selected`, so no `speed_cb` loop) |
| `_on_speed()` / `speed_cb` | `:495-498` | `:640-643` byte-identical (audio click + `speed_cb.call(sp)`) |
| Minimap panel geometry | `:1445-1448` donor offsets | `:1590-1593` byte-identical |
| Minimap input / jump | `:1453-1494` `_on_minimap_input` + `_minimap_jump_3d`, `:1496-1507` `_cam3d_jump`, `cam.call("jump_to_world_donor_offset", world_pos)` at `:1506` | `:1598-1639`, `:1641-1652`, call at `:1651` — **byte-identical** |

Protected-block verification: the substring from `func _on_minimap_input` through
the end of `_cam3d_jump` is byte-identical in backup and current
(3050 chars, SHA-256 `982B14BE8AB5BC5A5DBA992D0CD24D8DFA343ED0EEED3CB629622D5DC65AE91D`
for both). The bottom-right 240×240 minimap, panel partition and `_mm_size` /
`_mm_inset` / `_mm_corner` getters were untouched. The diff contains no hunk in
`_build_bottom()`, `_build_minimap()` or the minimap block.

### 2.1 What `_layout_top()` does (`:513-589`)

- Reads `ui_vp.x`, refreshed by `_calc_us()` on `get_tree().root.size_changed`
  (`:191-192`, `:266-268`) — resizing, windowed mode and fullscreen all re-layout.
  Breakpoints are actual widths (`<1000` compact, `<700` tiny, `<560` ultra), **not**
  a fixed 1280 assumption.
- Full-width `top_center` + anchored `top_panel` (`anchor_right/bottom = 1`), with
  `clip_contents = true` and responsive side padding: the row cannot spill past the
  viewport; `status_label` uses `SIZE_EXPAND_FILL` + `clip_text` to absorb/truncate
  slack rather than widen the row.
- Shrinks icons (36×31 → 26×23 → 20×18 → 16×14), fonts (`_fs` × 1.0 / 0.84 / 0.72 /
  0.66, floored at 10), button minimum sizes, bar separation (10 → 6 → 3 → 2) and
  strip height (42 → 38 → 36 → 34); hides `VSeparator`s, then `settings_label`,
  then `status_label` at ultra width. FPS and messages are separate nodes and are
  never touched. All six resource values, worker-count brackets and deficit tints
  stay intact *as text* (no data abbreviated away) at every width.
- `mouse_filter = IGNORE` on both strip and panel preserves the prior "map orders
  work underneath" behaviour; actual buttons still take clicks.

### 2.2 Dropdown semantics

Items carry the former speed floats as metadata: `II → 0.0` (pause), `1x → 1.0`,
`2x → 2.0`, `4x → 4.0`; default selection `1x`. `_on_speed_idx()` routes the
selected item through the unchanged `_on_speed()` → `speed_cb` path, so the menu
callback in `main.gd:616-622` still receives the same floats, including pause.
`speed_label` still reads `PAUSED` / `Nx`; Space still pauses via
`input_controller.gd:1166-1167`. Tooltip kept: "Game speed (Space pauses)".

## 3. Donor / port citations

- `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md:157-158` — donor top
  resource strip uses viewer-width-dependent DPI (`GetViewerWidth < 2520 → 1`,
  `< 1260 → width/1260`, `cminwidth = 1280`) and 162 px slots: direct precedent for
  driving bar geometry from the live viewer width instead of a fixed 1280.
- Same file `:103-110` hints/cap/low-food, `:161` idle-peasant + mines buttons,
  `:122` `text.pause`, `:255` existing semantic parity of the six-resource strip —
  the data set that must remain reachable after compacting.
- `variant3d/scripts/config.gd:751-754` `ui_scale_for()` (`clamp min(vp.x/1280,
  vp.y/720), 0.75, 2.5`) and `:761-773` `ui_panel_style()` (14/14/10/10 margins).
  The new `_top_style()` duplicates that shared style with 8/8/3/3 margins so the
  band can be shorter while keeping the same look.
- `variant3d/scripts/hud.gd` (before) `:294-311` meta-driven `_fs()`/`_ms()`
  scaling and `:381-443`/`:491-500` are the port seams that were reworked.
- Speed set `pause/1x/2x/4x` is documented in `variant3d/MECHANICS.md:470` and
  `variant3d/mechanics.json:916`; it is reused verbatim as dropdown items — no new
  speeds or donor values invented.
- Minimap offset call and donor-offset semantics: `MMJUMP_02_minimap_jump.md`,
  preserved byte-identically (SHA above).

## 4. Backup

```
inbox/backup/hud.gd.bak-UITOPBAR01
```
Copied before the first edit; both files then hashed identical
(SHA-256 `D5060B9ECD42485A1FFAF66F42132110CF4258B2FD10B141B0985AE9D3836D9B`).

## 5. Validation — variant runner only, Windows `python`, unique ids

No direct `godot` was invoked; no queue mutation, no `cancel`/`ack`/`reset`;
busy waits were left to drain (no re-submission while queued). All retries used
fresh ids after a completed failure, never a duplicate id.

| Ticket | id | argv | Result | Approach / evidence |
|---|---|---|---|---|
| 510 | `uitopbar01-smoke` | headless `--path variant3d --check-only --script res://scripts/hud.gd` | **failed**, exit 1; wait 204.93 s, run 7.10 s; stderr 456 B | My own parse bug: Godot 4.7 `OptionButton.add_item()` is `void`; assigning its return to typed `idx` failed at `hud.gd:496`. Fixed to `idx = ob.item_count - 1`. |
| 513 | `uitopbar01-smoke-r2` | same check-only | **ok / exit 0**; wait 69.96 s, run 8.60 s; stdout 75 B (banner), stderr 0 B → `SCRIPT ERROR == 0` | Parse/load of `hud.gd` VERIFIED. |
| 515 | `uitopbar01-uitest` | headless `--path variant3d -- --ui-test variant3d/uitest.json` | **failed**, exit 1; wait 0.00 s, run 175.68 s; stderr 3651 B | Unrelated concurrent edit: `selftest.gd:153 Parse Error: Identifier "slot" not declared`, `main.gd` compile failed, then watchdog forced exit. `selftest.gd` last written 11:55:13, *after* this run started at 11:54:49; that file is not in my ownership and was not touched by me. No `hud.gd` error. |
| 519 | `uitopbar01-uitest-r2` | same ui-test | **failed**, exit 1; wait 310.57 s, run 7.05 s; stdout 75 B banner, stderr 0 B | No script error at all; exited before writing a report while other agents were editing `main.gd` (last write 12:05). No `hud.gd` error. |
| 524 | `uitopbar01-uitest-r3` | same ui-test | **failed**, exit 1; wait 195.02 s, run 228.17 s; stderr 3245 B | Only pre-existing asset-load warnings and the `world3d_entities` approximation warning, then `watchdog: wall-clock limit reached, forced exit`. No `ui-test report:` line in stdout. |

**Expected 17/17 is UNVERIFIED in this session.** The on-disk
`variant3d/uitest.json` still reads `passed: true`, 17 steps, but its mtime is
2026-11-25 10:51:54 — earlier than every job above — so it is a stale artifact and
is **not** evidence for this change. I did not edit it and did not weaken any test.

The first smoke passed after my own parse fix; the three UI-test attempts all
failed for reasons outside `hud.gd` (concurrent `selftest.gd` parse break; early
exit with empty stderr; watchdog timeout). No failure implicates the responsive
bar or the dropdown. Per instruction, I am reporting this with evidence rather
than continuing to submit jobs.

**No-weakening statement:** no assertion, threshold, test source, expected result
or artifact was changed or relaxed. `uitest.gd`, `uitest.json`, `selftest.gd` and
every other validation file remain as found. A green 17/17 must be produced by a
fresh owner run on a quiet tree before this ticket is called runtime-verified.

## 6. Open questions / limits

1. Visual confirmation at narrow widths (compact / tiny / ultra) has **not** been
   captured — no screenshot job was in scope. The layout is code-verified only.
2. Below ~560 px the status line is hidden (units/score/PAUSED); resources,
   idle/mine buttons, speed, FPS and messages remain. Whether an even narrower
   viewport should wrap instead of hide is a UX decision for the owner.
3. `speed_buttons` is retained as an empty array for API compatibility; no reader
   was found in the tree, but an external consumer expecting populated buttons
   would need updating (outside this ticket's scope).
4. The dropdown mirrors `refresh_speed()` when callers supply `paused`; Space
   toggles `game.paused` in `input_controller.gd` without calling `refresh_speed`,
   so the dropdown does not follow a Space-only pause (the pre-existing
   `speed_label` had the same limitation). Behaviour deliberately unchanged.

## 7. Summary

`hud.gd` alone now has a full-width, clipped, viewport-driven top bar with four
responsive modes, a single speed `OptionButton` (pause + 1x/2x/4x) wired through
the unchanged `speed_cb`/`_on_speed` path, and an unchanged `speed_label`. The
band is shorter, the 6 resources / idle & mine buttons / deficit tints / FPS /
messages remain reachable, and the minimap partition, donor offsets and MMJUMP-02
call are byte-identical. Parse is verified (`uitopbar01-smoke-r2`, ticket 513);
runtime 17/17 remains UNVERIFIED because three UI-test jobs failed for unrelated
concurrent/watchdog reasons. No test was weakened; no other file was edited.
