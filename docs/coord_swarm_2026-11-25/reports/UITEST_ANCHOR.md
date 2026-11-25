---
id: UITEST-ANCHOR
title: "UITEST-ANCHOR — correct the uitest minimap anchor expectation to donor bottom-right"
owner: UITEST-ANCHOR (implementation builder)
date: 2026-11-25
status: DONE__17_17_GREEN
scope: "One source file edited (variant3d/scripts/uitest.gd) plus this report and the required backup copy. Donor READ-ONLY. No gates other than the prescribed uitest; no full selftest, no ladder, no direct godot."
labels: [donor-truth, no-weakening, OBS]
---

# UITEST-ANCHOR — minimap anchor expectation corrected after HUD-01

## 1. Goal and ownership

HUD-01 moved the 3D minimap from bottom-LEFT 200 px to bottom-RIGHT 240×240 with a −8/−8 inset, but could not touch `uitest.gd` (foreign owner) and reported that `uitest.gd:304-307` would fail the 17/17 gate. This ticket grants that file and corrects the **expected value** to donor truth.

**Exclusive ownership honoured:** `variant3d/scripts/uitest.gd`, `docs/coord_swarm_2026-11-25/reports/UITEST_ANCHOR.md`, and the one required backup copy. No other source/test/config file was hand-edited.

## 2. Donor citations (the values are citable; nothing guessed)

All donor lines were **read** via `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` §5.2/§7 C1, `reports/HUD_01_minimap.md` §3 claim 1 / §4.1, and the read-only HUD-01 git diff of `variant3d/scripts/hud.gd`.

| Donor fact | Citation | Label |
|---|---|---|
| `cMinimapSize = 240`, `cMinimapOffsetX = -8`, `cMinimapOffsetY = -8` | `initminimap.inc:5-7` | OBS |
| `_gui_CreateParent('minimap', 0, gc_halParentRightWidth, gc_valParentBottomHeight, -8, -8, 240, 240, True)` — right + bottom anchored | `initminimap.inc:17` | OBS |
| `SetGUIMiniMapPosition(GetViewerWidth - 240*scale - 8, -8, 0)`; `SetGUIMinimapZoom(1)`; `SetMiniMapFrustumVisible(true)` | `initminimap.inc:29-39` | OBS |
| A 289-px right strip is reserved; unit panel spans `ViewerWidth-289` | `showunitcontrol.inc:109-110,586` | OBS |
| Port implementation of the above: panel anchored left/right/top/bottom = `1.0`, offsets `−278 / −270 / −8 / −8`, rect min size `240×240` | `hud.gd:297,1385-1409` (HUD-01 diff) | OBS (port) |

The old expectation (`par.anchor_left == 0.0`, detail `"minimap bottom-left"`) described the **pre-HUD-01** port, not the donor. `DEC_08` §5.2/§7 C1 and `HUD_01_minimap.md` §8 item 3 both say the donor side is bottom-right and hand this assertion update to the test owner.

## 3. Before → after (exact lines)

File: `variant3d/scripts/uitest.gd`, function `_s_minimap_frustum`.

| Line | Before | After |
|---:|---|---|
| 306 | *(absent)* | `# HUD-01 donor truth: minimap is bottom-RIGHT 240x240, -8/-8 inset` |
| 307 | *(absent)* | `# (initminimap.inc:5-7,17,29-35; showunitcontrol.inc:109-110,586).` |
| 306 → 308 | `var ok: bool = hud.minimap_rect != null and par != null and par.anchor_left == 0.0` | `var ok: bool = hud.minimap_rect != null and par != null and par.anchor_left == 1.0` |
| 307 → 309 | `... "minimap bottom-left: %s" ...` | `... "minimap bottom-right: %s" ...` |

`git diff -- variant3d/scripts/uitest.gd` shows **only** these 4 lines in this one hunk; the other 16 step functions and all 17 entries in `SCENES` (`:32-35`) are byte-identical. No assertion was deleted, skipped, or relaxed. The check remains a single strict equality (`par.anchor_left == 1.0`), matching the panel's donor-backed `anchor_left = 1.0` at `hud.gd:1400`. Size/inset are not asserted by this step, so they were not added or changed (the task requires "size/inset **if** the test checks them").

## 4. Backup

| File | Backup | Bytes |
|---|---|---|
| `variant3d/scripts/uitest.gd` | `inbox/backup/uitest.gd.bak-UITESTANCHOR` | 13,478 |

Copied **before** the edit and verified present.

## 5. Validation — variant runner only

Exact prescribed command (no direct `godot`, no full selftest, no ladder, no `--check-only`):

```
python variant3d\tools\godot_runner.py run --id uitestanchor-uitest --timeout 240 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
```

| Ticket | Job id | Result | Wait / run | Exit | stdout |
|---:|---|---|---|---:|---|
| 366 | `uitestanchor-uitest` | runner `END ok` | 5.47 s / 84.96 s | 0 | `variant3d/.godot_queue/results/00000366_uitestanchor-uitest/stdout.txt` |

`variant3d/.godot_queue/results/00000366.json` records `status: "ok"`, `exit: 0`, `timeout: 240.0`. The generated report `variant3d/uitest.json` has **`"passed": true`** and **17/17 steps passed**; step 14 reads `"detail": "minimap bottom-right: yes"`, `"passed": true`, `"step": "minimap_frustum"`. No failing step; no revert was needed.

`stderr.txt` contains only pre-existing, unrelated concurrent-tree noise (flat-root morph `PORT APPROXIMATION` warning, a missing `mill_rotor.png` imported texture, an ObjectDB leak warning); none concerns `uitest.gd` or the minimap anchor.

## 6. Explicit NO-WEAKENING statement

**This is a correction to donor truth, not a test weakening.** The assertion was not deleted, skipped, conditionally bypassed, or made looser: the single strict equality on the minimap parent's horizontal anchor was changed from the obsolete port value `0.0` (left) to the donor-backed value `1.0` (right), and its human-readable detail string was corrected. All 17 scenes and all 16 other step functions remain byte-identical. The 17/17 gate is still a real gate and passed with the corrected expectation.

## 7. Open questions

1. The step checks only `anchor_left`. A stronger future check could also assert `anchor_right == 1.0` and the `−8` offsets / `240×240` size, but the donor-backed port values (`hud.gd:1400-1409`) are scaled by `ui_us` at runtime (`hud.gd:297,308`), so a fixed pixel assertion would need a scaling rule. Left intentionally unchanged here (task: keep other steps byte-identical, do not weaken).
2. The mandated runner writes its report to the `--ui-test` path, so the tracked `variant3d/uitest.json` was **regenerated** by the runner. Its only diff is the generated detail string `minimap bottom-left: yes` → `minimap bottom-right: yes`. This is runner output, not a hand edit; per the convention in `reports/CFG_01_skirmish_defaults.md:109` and `reports/CFG_02_no_menu_defaults.md:118,130`.
3. HUD-01's remaining donor gaps (double-click jump, frustum quad vs AABB, blip scale) are outside this ticket; DEC_08 §9 Q1/Q2 remain UNVERIFIED.

## 8. Summary / scope statement

**Donor truth:** bottom-right 240×240 minimap anchored right+bottom with −8/−8 inset (`initminimap.inc:5-7,17,29-35`; `showunitcontrol.inc:109-110,586`), implemented at `hud.gd:1385-1409`.

**Change:** `uitest.gd:306-309` — flip expected `anchor_left` from `0.0` to `1.0`, add a 2-line donor citation, update the detail text to `minimap bottom-right`. No other step touched.

**Validation:** runner ticket 366 / `uitestanchor-uitest` → `ok`, exit 0, **17/17 passed**.

**Files edited by hand:** only `variant3d/scripts/uitest.gd` and this report, plus the required backup copy `inbox/backup/uitest.gd.bak-UITESTANCHOR`. **No other file was hand-edited.** The runner-generated `variant3d/uitest.json` artifact is disclosed in §7 item 2. Donor was read-only; no direct `godot`, no full selftest, no ladder.
