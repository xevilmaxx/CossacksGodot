---
id: D06
title: "D06 — visual inventory of on-disk selection quad / marquee captures"
owner: D06 (read-only analysis worker)
date: 2026-11-25
status: READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__ONE_REPORT_ONLY
scope: "Exactly one new file: docs/terrain_swarm_2026-11-25/reports/D06_selection_captures.md. No atom, .gd/.gdshader, config, fixture, result JSON, PNG, donor access or runner job."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "Internal visual evidence only. No donor GPU A/B quad frame was opened or produced. Donor parity is UNVERIFIED; this report makes no donor-parity claim (CHARTER §3, §5.4)."
---

# D06 — what the selection quad looks like on disk today

## 0. Boundary and label key

- **OBSERVED** = read directly from a named file/line or from opening an image with the read tool.
- **DERIVED** = arithmetic or control-flow consequence of observed code/JSON.
- **INFERRED** = reasoned, not directly observed.
- **UNVERIFIED** = cannot be established from available material.

This ticket did **not** launch Godot, submit a runner job, edit code, or write any file other
than this report. No donor material was consulted.

---

## 1. Search coverage (OBSERVED — what was actually examined)

### 1.1 Paths searched

| Root | Filter | Result |
|---|---|---|
| `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode` (recursive) | `s1`, `select`, `drag`, `minimaptip`, `motion`, `frames`, `contact`, plus `sel|quad|marq|pick|capture` | Mostly unrelated assets: `*_s1.png` building textures under `alpha_norm_backup\` and `variant3d\assets\models\anim\...`, `dragoon*_*.png` sprite sheets, `t6u04_*_dragoon_*.log`. The only selection-relevant **images** found were the three `minimaptip01_*.png`, the three `hudcapturefix\hud_*.png`, and `vidqa\contact_sheet.png` + `vidqa\frame_000..015.png`. |
| `variant3d\tests\results\*.json` | all 50+ files; grep for `overlay|sel_rect|marquee|drag_start|selected_ids`, `expected_pre_fix_failure`, `.png` paths | Only `t_select_rect.json` carries overlay/quad assertions and a PNG path. `fixselvis_probe.json`, `t_pick_res.json`, `t_pick3d.json`, `t_motion_capture.json`, `t_hud_layout.json`, `t_load_usability.json`, `selftest_capture.json`, `t_capture.json` were read and are described in §2. |
| Temp root JSONs | `sel01_probe_result*.json`, `v2_gpS1.json`, `sprite_dims.json`, etc. | Three `sel01_probe_result*.json` contain drag/overlay state; `v2_gpS1.json` is a grass-patch measurement, not selection. |
| `app\shots\session1\`, `app\shots\j2\`, `app\shots\j3\` | `frame_*.png` | 2D app captures, opened two representatives (`frame_0000.png`, `frame_0018.png`); unit-selection rings, no marquee. |
| `variant3d\assets\ui\overlays\ring_sel.png` | selection overlay sprite | Opened: 64×64 white ring, unit aura, not the marquee. |

### 1.2 PNG paths that were checked and are **ABSENT** (OBSERVED, `Test-Path = False`)

```
...\Temp\opencode\s1inputfix_smallmap64.png
...\Temp\opencode\s1inputfix_smallmap64_r2.png
...\Temp\opencode\configwires_smallmap64.png
...\Temp\opencode\audiosel02_smallmap64.png
...\Temp\opencode\smallmap64_select_rect.png
...\Temp\opencode\sel01_select_rect.png
...\Temp\opencode\bselrect_probe.png          <- the ONLY PNG path inside t_select_rect.json (:229)
...\Temp\opencode\d03_selquad_before.png
...\Temp\opencode\d03_selquad_during.png
...\Temp\opencode\d03_selquad_after.png
```

A recursive `*.png` search across both the Temp root and the repo found **no** file whose name
contains `selquad`, `marquee`, or `quad`, and no `t_select_rect_capture.json`. The same six
absent paths are already recorded in `docs/coord_swarm_2026-11-25/reports/RECHECK_S1.md:121-132`.

---

## 2. OBSERVED visual inventory

For every artifact: "quad rendered?" is answered against the **world-space drag marquee** the
owner complained about, not against minimap rectangles, unit rings, or building ghosts.

| # | Artifact (opened / inspected) | What it actually is | Quad rendered? | Colour / thickness / size | Drag or after? | White / sky bleed or offset |
|---|---|---|---|---|---|---|
| 1 | `minimaptip01_1024x576.png`, `minimaptip01_1280x720.png`, `minimaptip01_1920x1080.png` (all three opened) | Root-window HUD captures from `t_hud_layout.json` (`save_png` at lines 131/257/383). Bottom-right minimap + top resource bar + bottom-left tip box reading **"Nothing selected. Left-click or drag to select."** World area above is an empty near-black green field. | **NO.** Only a rectangular outline *inside the minimap*. | White/light-grey outline, ≈2 px at 1024×576 and 1280×720, ≈3 px at 1920×1080 (scaled). Approx. sizes: 120×102 px / 154×126 px / 223×187 px respectively. Insets from minimap top-left ≈ (20,10) / (100,9) / (147,13) px. | Neither — static idle HUD state, no selection and no drag in progress. | The white rectangle sits **inside the minimap panel only** and tracks the camera viewport; it is **not** a world-space marquee and shows no offset into the 3D view. No sky/white bleed in the world area (it is uniformly dark). Do not read this as the quad. |
| 2 | `hudcapturefix\hud_1024x576.png`, `hud_1280x720.png`, `hud_1920x1080.png` (1920 opened; 1024/1280 are byte-size near-identical siblings) | Same HUD layout capture, later re-run. 1920 image is visually identical to #1 at that resolution: "Nothing selected" tip, white minimap rect, empty world. | **NO.** | Same as #1. | Neither — idle. | No bleed/offset beyond the minimap panel. |
| 3 | `vidqa\contact_sheet.png` (opened) | 4×4 sheet of 16 `frame_000..015` from `t_motion_capture.json`. Yellow `frame NNN` labels are **sheet annotations**, not selection graphics. Frames show a large white/cyan wireframe ghost building and two moving units. | **NO.** No yellow rectangle anywhere. | N/A. Labels are yellow text only; ghost wireframe is thin white/cyan. | No drag performed; atom issued one `cmd_move` (`t_motion_capture.json:31`). | World-only `Screenshot3DViewport` readback — HUD is not composited, so no quad layer could appear even if one existed. The bright wireframe is a building preview, not marquee bleed. |
| 4 | `vidqa\frame_000.png` (opened, 1280×720) | Full frame behind the sheet: two units on dark olive ground, a large white/cyan wireframe structure left/right, dark circular shadow/reflection blobs. A **blue dotted ring** appears around the right-hand structure. | **NO.** | Blue dotted ring ≈1–2 px around a building footprint; consistent with `fixselvis_probe.json` player-1 colour `[0.0706, 0.4, 0.9035]`. Ring diameter ≈200 px. Not a rectangle. | No drag; no selection marquee state recorded in `frames.json`. | No white/yellow bleed; only the wireframe preview is bright. |
| 5 | `vidqa\frames.json` (read) + `motion.mp4` (present, 431 KB) | `format=vidcap01-frames-1`, 16 frames, `capture: windowed Screenshot3DViewport readback`, per-frame camera/signature metadata; `analysis_note` explicitly "CAPTURE ONLY - no donor parity or motion verdict". | **NO** visual assertion of any kind; JSON contains no selection fields. | N/A. | N/A — movement capture. | `vidqa\SKIP_CAPTURE.txt` records an earlier headless attempt: `status: SKIP_CAPTURE`, `passed: false`. |
| 6 | `variant3d\assets\ui\overlays\ring_sel.png` (opened) | 64×64 white ring sprite — **unit selection aura**, not the marquee. | **NO** (different feature). | White, thin ~1–2 px ring, 64×64 sprite. | Static asset. | No bleed; alpha-isolated sprite. |
| 7 | `app\shots\session1\frame_0000.png`, `frame_0018.png` (opened) | 2D app frames. `frame_0000`: eight white/blue unit rings, green building-placement outline, "Placing sto - left-click to build". `frame_0018`: white dashed unit ring, no marquee. | **NO** yellow drag quad. | Unit rings are white/blue ellipses ~35–60 px wide; placement ghost is green. Neither is a draggable rectangle. | Neither frame is mid-drag. | No marquee offset or bleed; these are the 2D app, not the 3D variant under complaint. |
| 8 | `variant3d\tests\results\t_select_rect.json` (read in full) | The **only** green gate for the 3D drag marquee. 23/23 checks, `run_mode=windowed_real_input`, `headless=false`, viewport 1280×720. | **Not captured** — "capture_path" field says "**no PNG assertion**" (:2); its sole PNG path `bselrect_probe.png` (:229) is ABSENT. | Overlay state only: during drag `SelectionRectOverlay`, `visible=true`, `Rect2[(395.262,273.539),(917.084,457.888)]` — a 521.82×184.35 px screen rect; after release `visible=false`, `Rect2((0,0),(0,0))`. Colour **never asserted**. | Both during (`:77-81`) and after (`:83-87`), but as node state, not pixels. | Pixel-level bleed/offset **UNVERIFIED**. Note the edge trap from `D03_selection_probe.md:72-83`: `input_ctl` stays in the root viewport while `Screenshot3DViewport` holds only world+camera — a capture of that viewport would omit the marquee entirely. |
| 9 | `sel01_probe_result.json` (opened) | Early **headless** probe, `passed=false`. Overlay rect during drag `[-46684.43, 19499.61, 14858.01, 29143.46]`, `p0=(-1591.3,975.0)`. | No PNG. Node rect is far outside a 1280×720 viewport (x from −46684 to −31826). | Enormous/off-screen; colour not probed. | During drag and after; after hidden/empty. | **N/A as visual evidence** — `sel01_probe.gd:78-81,166-168` forces headless and bypasses the canvas stretch transform by direct `_unhandled_input` delivery; these negative pixel coordinates are an artifact of that harness, not a rendered quad. |
| 10 | `sel01_probe_result2.json`, `sel01_probe_result3.json` (opened) | Same probe after coordinate fix. `passed=true`. Overlay rect during drag `≈[-2323..-2328, 975, 737..740, 1457]`, `visible=true`; after release hidden/empty. Selected `[10,11]`; result3 adds `shift_drag_is_additive` → `[10,11,12]`. | No PNG; still headless with negative/off-viewport pixel coordinates. | Same out-of-view rect; no colour/width. | During and after. | Not a visual capture; cannot support any claim about on-screen bleed or offset. |
| 11 | `fixselvis_probe.json` (opened) | Ring lifecycle probe (not the rect): 2 rings `SelRing_11`, `SelRing_22`, colours player0 `[0.7396,0,0]` (red) and player1 `[0.0706,0.4,0.9035]` (blue); after clear count=0. | **NO** marquee involved. | Ring colours above; no thickness/size recorded. | Before/after ring sync, not drag. | No image, no bleed/offset observable. |
| 12 | `t_hud_layout.json`, `t_load_usability.json`, `t_pick_res.json`, `t_pick3d.json`, `t_motion_capture.json`, `selftest_capture.json`, `t_capture.json` (all read) | HUD geometry (minimap 240 declared; rendered 194/242/362 px at the three resolutions), loading overlay, unit/resource picking, motion capture, building capture. | **NO** selection-quad assertion or capture in any of them. | N/A. | N/A. | `t_load_usability.json:40` explicitly records `c_input_response` as a **proxy**: "direct `_set_selection` call in headless, real mouse events UNVERIFIED". |

### 2.1 Code-derived appearance (DERIVED — not a visual observation)

- `variant3d/scripts/input_controller.gd:96-108`: `SelectionRectPainter._draw()` calls
  `draw_rect(rect_px, Color(col), false, width, false)` — outline only, **no fill, no antialias**.
- Defaults at `:102-103` and `variant3d/scripts/config.gd:431-436`:
  `col = [1,1,0,1]` (opaque yellow), `width = 1.0 px`, overridable via
  `features.selection.marquee_color` / `marquee_width_px`.
- `input_controller.gd:111-119`: `SelectionRectOverlay` is a `CanvasLayer`, `layer = 10`,
  `visible = false` at init; `:220` sets the rect during drag, `:225` clears it after release.
- **DERIVED:** if the intended draw path executes, the marquee should be a 1 px opaque yellow
  rectangle with an unfilled interior. **UNVERIFIED:** that this was ever rasterised into a
  saved frame. The code states intent; no PNG corroborates it.

---

## 3. Result-JSON assertion cross-reference and `expected_pre_fix_failure` markers

`variant3d\tests\results\t_select_rect.json` — 23 assertions, all `passed: true`, 23 marker fields.

| Marker value | Count | Checks |
|---|---|---|
| `expected_pre_fix_failure: true` | **2** | `overlay_rect_during_drag` (`:77-81`), `overlay_hidden_after_release` (`:83-87`) |
| `expected_pre_fix_failure: false` | 21 | all remaining 21 checks |

- **OBSERVED:** both `true` markers sit on the two overlay checks **while those checks report
  `passed: true`**. The 23/23 green result therefore still carries the pre-fix expectation flag
  on precisely the two checks that describe the quad's presence and lifetime.
- **OBSERVED:** the marker is hard-coded in the source: `variant3d\tests\t_select_rect.gd:524-539`
  `_assert_overlay()` passes `true` as the 4th `check()` argument at `:539`, and both overlay call
  sites use that helper (`:611-612` per `RECHECK_S1.md:90,106`). Marker count in the source is
  unchanged; no assertion was deleted or weakened.
- **OBSERVED:** no other result JSON in `variant3d\tests\results\` contains the
  `expected_pre_fix_failure` key (grep over all `*.json`: 23 matches, all in `t_select_rect.json`).
  `sel01_probe_result*.json` use a different schema with no marker field.
- **DERIVED:** the flags are a *guardrail record*, not a failure signal — flipping them is
  forbidden by `CHARTER.md:58-60` unless a fix has landed. `RECHECK_S1.md:178` already lists
  "who flips them, and when?" as an open question. **No flip was performed by D06.**

---

## 4. Verdict on the owner's "selection quad not ok" complaint

**OBSERVED:** across every selection-related PNG, frame, contact sheet and result JSON on disk,
there is **not one image of the 3D drag marquee**. The only rectangular outlines actually
visible are a white camera-view rectangle drawn inside the minimap of the HUD captures
(`minimaptip01_*`, `hudcapturefix\hud_*`, all with "Nothing selected"), and a bright white/cyan
building ghost wireframe in the motion frames; neither is the world-space quad. Unit-selection
rings (`ring_sel.png`, blue ring in `frame_000.png`, white rings in the 2D app frames) are a
different feature. The authoritative green gate `t_select_rect.json` asserts overlay node
visibility, rect geometry and selection semantics (23/23, during and after drag) but explicitly
asserts no PNG, and its only screenshot path is absent; the earlier headless `sel01_probe`
results show off-screen node rects that are harness artifacts, not renderable evidence. Code
(`input_controller.gd:96-108`, `config.gd:431-436`) says the intended quad is a 1 px opaque
yellow unfilled outline, but no frame confirms its colour, thickness, position, drag-time
visibility, cleanup, or freedom from white/sky bleed/offset — and the minimap rect is a
plausible source of the owner's "quad not ok" impression precisely because it is the only
white rectangle on screen. **Therefore the visual half of the complaint remains UNVERIFIED,
not refuted and not confirmed: logic is green, pixels are absent.** Consistently with
`D03_selection_probe.md` and `RECHECK_S1.md:143,167`, no visual PASS or visual FAIL may be
manufactured from JSON alone; the honest next step is the D03-style three-capture probe
(before / during / after) with the overlay reparented into `Screenshot3DViewport`. This report
makes **no donor-parity claim** and proposes no code change.

---

*End of D06.*
