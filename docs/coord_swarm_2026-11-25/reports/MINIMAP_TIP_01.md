---
id: MINIMAP-TIP-01
title: "MINIMAP-TIP-01 — donor click framing reconciled; narrow-width top bar/containment fixed"
area: coord_swarm_2026-11-25
task_id: MINIMAP-TIP-01
date: 2026-11-25
owner: MINIMAP-TIP-01 (implementation builder)
status: DELIVERED__LAYOUT_ATOM_PASS__CAMERA_MATH_UNCHANGED__NO_TIP_AB__SCRIPT_ERROR_0
scope: "Exclusive ownership honoured: variant3d/scripts/camera3d.gd, variant3d/scripts/hud.gd, variant3d/scripts/hud3d_adapter.gd + this report. Net source change is confined to hud.gd's responsive top-bar thresholds/padding; camera3d.gd and hud3d_adapter.gd are byte-identical to their pre-ticket backups. Donor READ-ONLY. No test/config/queue/game/app edit, no direct godot, no gates, no ladder, no re-submit loop."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION, NO_DONOR_AB, NO_PARITY_CLAIM]
diag_in: "docs/coord_swarm_2026-11-25/reports/MINIMAP_TIP_DIAG_01.md"
qa_in: "docs/coord_swarm_2026-11-25/reports/QA_HUD_REPAIR_01.md"
---

# MINIMAP-TIP-01 — report

Label key: **[observed]** = read from a cited file/artifact; **[derived]** = arithmetic or control-flow consequence of observed lines; **[inferred]** = plausible reading without proof; **UNVERIFIED** = no evidence obtained; **PORT APPROX** = port-side approximation, explicitly not a donor parity claim.

## 1. Donor truth established before editing

`reports/MINIMAP_TIP_DIAG_01.md` landed after this ticket started and was read in full before finalizing. Its fresh donor byte reads agree with the decompiled citations already in-tree:

| # | Donor literal / fact | Label | Citation |
|---:|---|---|---|
| 1 | Active helper writes `newX = dstX + offX + dx`, `newZ = dstZ + offZ + dz`; `dstX/dstZ` are the clicked GUI `X/Y` | observed | `control.script:574-613`, `onmousedown.inc:116-131`, `MINIMAP_TIP_DIAG_01.md §2.1-2.3` |
| 2 | `angleZ = +32°` for every height (`camera.cfg:32-35`), `dz = 0.1·cos32° ≈ 0.0848 m` | observed + derived | `control.script:595-599`; `MINIMAP_TIP_DIAG_01.md:76-83,98-101` |
| 3 | `offZ = ArcTan(32°)·height ≈ cot32°·h` — **ArcTan body/units UNVERIFIED**, only the bookmark ratio `78.42125/49 = 1.60043` vs `cot32° = 1.60033` is derived | observed + PORT APPROX / UNVERIFIED | `control.script:601-602`; `default.cameras:5-10`; `DEC_07 §5.5`; diag `:104` |
| 4 | Forward displacement `≈32.09 / 54.59 / 92.91 m` at `h = 20 / 34.06 / 58` | derived | diag `:106-112` |
| 5 | The helper does **not** write the clicked point as the camera target; it displaces the target by the camera boom | derived | `control.script:611-612`; diag `:116,156` |
| 6 | Minimap click GUI `X/Y` is the cursor position; minimap cursor `crDefault` is 32×32 with `SpotX = SpotY = 0` (top-left arrow point) and stays active over GUI | observed + derived | `cursors.lib:5-12`, `doupdatecursor.inc:4,6-12,104-106`; diag `:122,158` |
| 7 | A **separate** in-world `movearrow` 3D actor is also written from the same `X/Y` | observed | `onmousedown.inc:617-624,869`, `control.script:409-418`, `movearrow.actor`; diag `:123` |
| 8 | Engine-side meaning of `SetMainCameraMoveToTargetXZ` (eye vs look-at) is **UNVERIFIED**; no donor A/B was run | UNVERIFIED | diag `:125,154-163,197` |

**Therefore the donor does not centre the clicked GUI point at script level.** The owner's wording ("in center" vs "tip of the arrow cursor") cannot be settled into a screen-space claim without a donor run/binary RE. Two different "arrow" notions exist (GUI cursor hotspot vs in-world `movearrow` actor); this report does **not** guess which one the owner meant (open question §7.1).

## 2. Port state reconciled (read-only, no camera math change)

| Step | File:line | Behaviour |
|---|---|---|
| Minimap UV → SIM world | `hud.gd:1598-1600` | `mp = local_mouse_position/size`; `world_pos = Vector2(mp.x*MAP_W, mp.y*MAP_H)*TILE_M` |
| Primary 3D LMB press/drag | `hud.gd:1605,1633-1652` | `_cam3d_jump` calls **`jump_to_world_donor_offset(world_pos)`** (guard at `:1643`), unchanged by this ticket |
| Plain centre API | `camera3d.gd:444-452` | `_target = world_pos` → centre; **byte-identical** to backup (CAM-RV-01 20/20 dependency), SHA prefix `565fdca1…` per diag `:146` |
| Donor-offset API | `camera3d.gd:560-586` | `off_z = h/tan32°` (PORT APPROX), `dz = 0.1 cos32°`, `new_target = world_point + (off_x+dx, off_z+dz)` — already donor-equivalent in structure |
| Other centring paths | `input_controller.gd:375-385` (fallback calls plain `jump_to_world`), `hud.gd:1616-1622` (2D branch) | **foreign-owned**; remain centring |

The primary 3D click is **already** routed through the labelled offset API, so the "port centres the click" premise is true only for the 2D branch and the 3D fallback, neither owned here. A speculative screen-space cursor correction (viewport-mouse ray → target translation) was drafted and inserted during this ticket, then **removed before any runner job started** once the diagnostic's rule against inventing a hotspot correction (diag `:172`) was applied. Net `camera3d.gd` change is **zero**. No new constant, no new formula, no `ArcTan` redefinition.

Discriminating measurement: a static calculation from the cited donor/port math gives, for the diag's example click `A = (32,32) m` at seeded `h = 34.06 m`, `B ≈ A + (0,54.59 m)` and viewport centre `C ≈ B` (port `look_at(base)` with `base = _target - half`, `camera3d.gd:264-282`). Thus the clicked point is displaced from centre by ≈54.59 m — **derived, not a runtime measurement**. No windowed A/B or click probe was feasible without editing a test file (forbidden by ownership); whether the point lands on-screen under a GUI arrow tip remains **UNVERIFIED**. No donor parity claim.

## 3. Narrow-width top bar — net source change

`reports/QA_HUD_REPAIR_01.md:50,60` recorded the real, unrelaxed failures after the harness was fixed: `top_panel_right_in_viewport_1024x576` (`x=[6.4,1126.4]` vs `1024`), the same at `1280x720` (`x=[8,1298]`), and two `no_unclipped_control_outside_viewport_*` failures (3 offenders each: panel, HBoxContainer, Label). At `1920x1080` both passed. Root cause is the top row's **content minimum** forcing `top_panel` wider than its anchored width at the two narrow sizes; padding alone could not fix it.

### Before → after (`variant3d/scripts/hud.gd`, `_layout_top`)

| Item | Before (line in pre-ticket file) | After (line in final file) |
|---|---|---|
| Mode comment | none | `:517-522` new 6-line MINIMAP-TIP-01 comment citing job 548/554 measurements and the protected blocks |
| `compact` threshold | `w < 1000.0` (`:517`) | `w < 1500.0` (`:523`) — activates compact at 1024 and 1280, hiding separators and the long settings label |
| `tiny` threshold | `w < 700.0` (`:518`) | `w < 1100.0` (`:524`) — 1024 also shrinks icons/buttons |
| `ultra` threshold | `w < 560.0` (`:519`) | `w < 800.0` (`:525`) — reserved for narrower windows; no tested size uses it |
| compact padding | `pad = 5.0` (`:530`) | `pad = 4.0` (`:536`) |
| tiny padding | `pad = 3.0` (`:539`) | `pad = 2.0` (`:545`) |

Unchanged: minimap geometry (`240×240`, bottom-right, `−8` inset, `_mm_size`/`_mm_inset`), the single `OptionButton` with items `["II","1x","2x","4x"]` and metadata `[0,1,2,4]`, all other `_layout_top` values (band, separators, icon/button sizes), the 2D branch, and every test/assertion. The atom's `_check_size` block was not opened for write.

## 4. Backups (taken before any edit, hash-verified)

| File | Backup | Bytes | SHA-256 prefix | Final state |
|---|---|---:|---|---|
| `variant3d/scripts/camera3d.gd` | `inbox/backup/camera3d.gd.bak-MINIMAPTIP` | 40,656 | `a91c68cd0b96f7a8` | restored byte-identical to backup after the speculative correction was withdrawn |
| `variant3d/scripts/hud.gd` | `inbox/backup/hud.gd.bak-MINIMAPTIP` | 86,604 | `525d4e0e2297788c` | only §3 change |
| `variant3d/scripts/hud3d_adapter.gd` | `inbox/backup/hud3d_adapter.gd.bak-MINIMAPTIP` | 10,221 | `f2ccfa02e9d92a52` | never edited; byte-identical to backup |

## 5. Validation — variant runner only

Launch form: `python variant3d/tools/godot_runner.py run --id <unique-id> --timeout 120|300 -- --headless|--path variant3d [--check-only] --script res://...` — no direct `godot`, no `--` trap, no queue mutation, no retries.

| Job id | Ticket | Target | Result | wait / run | stderr bytes | `SCRIPT ERROR` |
|---|---:|---|---|---:|---:|---:|
| `minimaptip01-smoke-hud` | 559 | `--headless --check-only res://scripts/hud.gd` | `ok`, exit 0 | 1008.85 s / 5.33 s | 0 | **0** |
| `minimaptip01-smoke-cam` | 560 | `--headless --check-only res://scripts/camera3d.gd` | `ok`, exit 0 | 1014.00 s / 7.55 s | 0 | **0** |
| `minimaptip01-smoke-adapter` | 561 | `--headless --check-only res://scripts/hud3d_adapter.gd` | `ok`, exit 0 | 1021.23 s / 5.12 s | 0 | **0** |
| `minimaptip01-hudlayout` | 562 | windowed `res://tests/t_hud_layout.gd` with three `--png-*` paths | `ok`, exit 0 | 1015.61 s / 27.60 s | 4,520 | **0** |

Runner records: `variant3d/.godot_queue/results/00000559.json` … `00000562.json`; per-job `stdout.txt`/`stderr.txt` in the matching `000005<id>_<job-id>/` directories. All four jobs were submitted while `camera3d.gd` still contained the speculative correction; the camera file was restored **before any job started** (runner status at revert showed all tickets pending), so every job parses/executes the final file. No retry, no cancel, no `ack`/`reset`/`unwedge`, no other job from this ticket.

**Discriminating HUD-layout measurement (job 562, atom-written `variant3d/tests/results/t_hud_layout.json`, `unix_ms=1795609248355`):** **PASS 62/62 evaluated, 3 skipped**, `passed=true`, `structural_ok=true`, `verdict=PASS`, `headless=false`, `capture_status=PASS`, exit 0. Honest scope: PASS here means "all layout assertions pass and 3 PNGs were saved"; the atom's own `non_black_fraction` values are 0.992050 / 0.995079 / 0.995466 from the saved PNGs, but this ticket makes **no visual/donor parity claim**.

| Size | `hud_ui_vp` | `top_panel` x-range | viewport width | unclipped offenders | change vs job 548/554 |
|---|---|---|---:|---:|---|
| 1024×576 | `[1024,576]` | `[1.6, 1022.4]` | 1024 | 0 | was `[6.4,1126.4]` + 3 offenders → both FAILs now PASS |
| 1280×720 | `[1280,720]` | `[4.0, 1276.0]` | 1280 | 0 | was `[8,1298]` + 3 offenders → both FAILs now PASS |
| 1920×1080 | `[1920,1080]` | `[12.0, 1908.0]` | 1920 | 0 | unchanged PASS |

R1 ("top bar never overflows") is now positively evidenced at all three tested widths. All six resource hints (6/6), the single speed widget with `["II","1x","2x","4x"]`, and the minimap geometry checks PASS at all three sizes; the 3 skips are the unchanged `RECORDED_NOT_GATE` `clipped_overflow_children_*` rows. PNGs written: `%LOCALAPPDATA%\Temp\opencode\minimaptip01_1024x576.png` (80,575 B), `..._1280x720.png` (101,839 B), `..._1920x1080.png` (171,364 B). No assertion was weakened or deleted by this ticket (the atom file was never opened for write).

## 6. Explicit PORT APPROX / UNVERIFIED labels

- **PORT APPROX**: `off_z = h/tan32°` stands in for donor `ArcTan(32°)·h`; numerically within 0.0062 % of the `78.42125/49` bookmark, not a donor literal (diag `:104`; `MMJUMP-02 §8`).
- **UNVERIFIED**: `ArcTan` VM body/units, `VectorRotateX/Y` signs, donor yaw, `SetMainCameraMoveToTargetXZ` semantics, GUI-pixel→event-metre conversion, hotspot-to-event offset, and engine-side screen landing (diag §7).
- **UNVERIFIED**: which "arrow" the owner meant — GUI cursor hotspot `(0,0)` or the in-world `movearrow` actor. No choice made.
- **UNVERIFIED**: whether the ≈54.59 m displacement is visible/on-screen at port FOV; no donor A/B or click probe was obtained.
- **PORT APPROX**: the narrow-width layout fix is internal UI containment consistency, not donor GPU/visual parity; the atom itself carries `parity_guard: PORT APPROX — internal layout consistency only`.
- **UNVERIFIED**: `capture_status=PASS` in the atom means "3 PNGs saved", not a visual PASS (QA_HUD_REPAIR_01.md:51).

## 7. Open questions

1. Does the owner's "arrow" mean the GUI cursor hotspot (`cursors.lib:5-12`) or the in-world `movearrow` actor (`control.script:409-418`)? If the latter, the port has no 3D marker — a separate feature ticket, not camera math (diag `:173`).
2. Confirm at runtime whether `_bound_cam3d` is set on the tested minimap click. An unset binding silently routes to the 2D/centring branch and reproduces "in center" (diag `:150,204`).
3. Is the centring seen by the owner in the foreign-owned `input_controller.gd:377` fallback or the 2D `hud.gd:1617` branch? Changing those needs a separate owner/scope.
4. A discriminating capture (diag §6) measuring `A` (clicked point), `B` (camera target), `C` (centre ground point), `D` (ground under cursor) and `E` (marker) at `h = 20` and `h = 58`, plus a matched donor A/B, is still required before any tip formula is authored.
5. Does a clamp at map edges move the donor-offset target enough to defeat the framing? UNVERIFIED without the same capture.
6. The concurrent `selftest.gd:170` `slot` parse error seen in job 554 (HUD_CAPTURE_FIX_01.md §5) did **not** recur in job 562: its 4,520-byte stderr contains **0** `SCRIPT ERROR` lines. The foreign-owned file was not edited by this ticket; attribution of the earlier error remains as reported by HUD-CAPTURE-FIX-01. [observed]

## 8. Scope statement / summary

- **Net source edit: one file** — `variant3d/scripts/hud.gd` §3 only. `camera3d.gd` and `hud3d_adapter.gd` are byte-identical to their pre-ticket backups; no camera constant, signature, API or jump math was changed.
- **Donor truth**: the clicked GUI point is deliberately **not** the camera target; the helper adds the boom offset (`≈32.09/54.59/92.91 m`). The primary 3D port click already applies a labelled PORT APPROX of that offset, so no new centring/tip formula was invented.
- **HUD fix**: compact/tiny/ultra thresholds and compact/tiny padding tightened so the 1024/1280 top row fits; minimap geometry, speed dropdown and all assertions preserved. Job 562 (windowed) is **PASS 62/62, 3 recorded skips, exit 0, SCRIPT ERROR 0**; job 548/554's four real containment FAILs are gone.
- **Validation**: three `--check-only` smokes `ok`/exit 0 with 0-byte stderr and 0 `SCRIPT ERROR`; one windowed HUD atom `ok`/exit 0 with 0 `SCRIPT ERROR`. All job ids unique; no re-submit loop.
- **No other file edited**: no test, config, fixture, runner, result JSON, `game.gd`, `app/**`, donor file, queue mutation, gate or ladder. No `godot` process outside `variant3d/tools/godot_runner.py`. Concurrent edits by other workers appear in `git status` and are not from this ticket.
