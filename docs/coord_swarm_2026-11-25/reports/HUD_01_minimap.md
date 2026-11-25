---
id: HUD-01
title: "HUD-01 — donor minimap geometry and world→minimap mapping (implementation)"
owner: HUD-01 (implementation builder)
date: 2026-11-25
status: IMPLEMENTED__PARSE_SMOKE_CLEAN__NO_GATES
scope: "Exactly two source files edited (hud.gd, hud3d_adapter.gd) plus this report and the two required backup copies. No other source/config/test file edited. Donor READ-ONLY. No gates, no ladder, no direct godot invocation."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION]
---

# HUD-01 — donor minimap geometry and world→minimap mapping

## 1. Goal and ownership

Close the geometry half of `GAPS.md` §1 "Minimap / HUD" row: the port minimap was **200 px bottom-left**, while the donor is **bottom-RIGHT 240×240** with an engine-drawn frustum. Implement only geometry + the world→minimap transform, keeping the port's map texture and click handling byte-identical.

**Exclusive ownership honoured:** `variant3d/scripts/hud.gd`, `variant3d/scripts/hud3d_adapter.gd`, `docs/coord_swarm_2026-11-25/reports/HUD_01_minimap.md`. `input_controller.gd`, `camera3d.gd`, `uitest.gd` were **read only**.

## 2. Sources read first (all read-only)

| Source | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` §5.2, §5.4, §7 C1/C4/C5, §8, §9 Q1/Q2 | Donor minimap truth; bottom-right 240×240; 289-px strip; linear scale table DERIVED/UNVERIFIED; stale camera comment |
| `docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md` claims 12, 15, 16; formula (d); divergences "Minimap box"; Q5 | `GetCameraFrustumQuadrangle` four ground corners; 240×240 zoom 1 `SetMiniMapFrustumVisible(true)`; centred-world uv formula; donor jump helper `control.script:574-613` |
| `docs/coord_swarm_2026-11-25/GAPS.md` §1 "Minimap / HUD" row | Ticket boundary: separate HUD ticket; fix stale comment when its owner touches it |
| `docs/coord_swarm_2026-11-25/PLAN_IMPLEMENTATION.md` §3 | One file per builder, backup, targeted runner job, report with claim table + before→after |
| `variant3d/scripts/hud.gd`, `variant3d/scripts/hud3d_adapter.gd` | Owned files read in full before edit |

## 3. Claim table

Labels: **OBS** = observed literal at cited donor/per `path:line`; **D** = derived; **I** = inferred; **U** = UNVERIFIED; **PA** = port approximation.

| # | Claim | Label | Citation | This ticket |
|---:|---|---|---|---|
| 1 | Minimap widget is 240×240, bottom-right, inset −8/−8, zoom 1, frustum on | OBS | `initminimap.inc:5-7` (`cMinimapSize=240`, offsets −8), `:17` (`gc_halParentRightWidth`, `gc_valParentBottomHeight`), `:29-39` (`GetViewerWidth-240*scale-8`, `SetGUIMinimapZoom(1)`, `SetMiniMapFrustumVisible(true)`); `minimap.cfg:2-6`; `DSEL_02` claim 15 | Applied as geometry |
| 2 | A 289-px right strip is reserved for the minimap; unit panel spans `ViewerWidth-289` | OBS | `showunitcontrol.inc:109-110` (`cMinimapSizeX=289`), `:586` | Applied by clipping the bottom strip to the left of the minimap |
| 3 | 34 nearest-filtered atlas primitives, 240-px image; blips 3×3/4×4 | OBS | `minimap.cfg:28-723,724-759`; `DEC_08` §5.2 | Not copied (port keeps its own blip logic — out of scope) |
| 4 | Frustum = four ground corners from `GetCameraFrustumQuadrangle(lt,rt,rb,lb)` | OBS (API) / U (exact shape) | `classes.script:6030-6040`; EXE census in `DSEL_02` §Sources; `DEC_08` §9 Q2 (quad vs AABB vs lens UNVERIFIED) | Adapter now sources the four corners explicitly; painter still strokes their AABB (PA) |
| 5 | World coords are centred on map origin → `u=(x+halfW)/mapW`, `v=(z+halfH)/mapH` | OBS + D | `misc.script:2017,2025`; `dogenerate.inc:402-404`; `DSEL_02` claims 18/19 and fix recipe (d) | Applied per corner in `get_minimap_corners()` |
| 6 | Linear world→minimap scale (0.75 px/tile at 320 tiles) | **D / UNVERIFIED** | `DEC_08` §5.4 table; `minimap.cfg:2-5`, `dmscript.global:172`, `gc_MaxMapWidth/Height=640` | Recorded in the adapter header as **DERIVED / UNVERIFIED**; never used as a code constant |
| 7 | Donor double-click minimap jump helper exists (`control.script:574-613`) | OBS | `onmousedown.inc:116-131,121-122`; `eventminimap.inc:8-55`; `DSEL_02` claim 16 | **NOT implemented** — needs `input_controller.gd`/`camera3d.gd`; separate ticket |
| 8 | `camera3d.gd` corner comment was stale (`"top-left map origin"` vs centred) | OBS | prior `camera3d.gd:354`; `camera3d.gd:435-436`; `DEC_08` §7 C5 | **Not edited** (foreign owner). Concurrent CAM01 edit corrected it at `camera3d.gd:363-371` |
| 9 | Port 2D box used `cam.global_position = world_pos * view_scale` | OBS (port) | `hud.gd:1415` (unchanged 2D branch); `DSEL_02` divergences "Minimap box" | 3D adapter never uses it; 2D branch untouched |
| 10 | Existing `uitest.gd` asserts minimap bottom-left | OBS (port) | `variant3d/scripts/uitest.gd:304-307` (`par.anchor_left == 0.0`, detail string "minimap bottom-left") | **Not edited** (foreign file); this assertion will now fail — see §8 |

## 4. Before → after (source diff)

### 4.1 `variant3d/scripts/hud.gd` — geometry only

| Item | Before | After | After-location |
|---|---|---|---|
| Widget min size | `Vector2(200,200)`, meta `uimw/uimh = 200` | `Vector2(240,240)`, meta `240` | `:1387-1389` |
| `_apply_scale()` size | `minf(_ms(200.0), ui_vp.x*0.20)` | `minf(_ms(240.0), ui_vp.x*0.25)` | `:297` |
| Panel anchor | left/bottom (`anchor_left=0, anchor_right=0`) | right/bottom (`anchor_left=1, anchor_right=1`) | `:1400-1403` |
| Panel offsets (initial) | `(4, -212, 234, 0)` | `(-278, -270, -8, -8)` = −(240+30+8), −(240+22+8), −8, −8 | `:1406-1409` |
| Panel offsets (on resize) | left `4`, right `4+mm+30`, top `-(mm+22)`, bottom `0` | right `−8`, left `−8−mm−30`, top `−8−mm−22`, bottom `−8` | `:308-314` |
| Bottom strip partition | minimap owns left edge; `sel_panel` starts at `mm_right+8`; `cmd_panel` right edge at viewport right `−8` | minimap owns right edge; `sel_panel` starts at left `+4` and ends before `cmd_panel`; `cmd_panel` remains right-anchored but its right edge stops at the minimap's left edge (`strip_right`) | `:316-327` |
| Map texture / click path | `minimap_tex`, `_on_minimap_input`, `_minimap_jump_3d`, `_cam3d_jump`, `_mm_paint_box` | **byte-identical** | `:1382`, `:1412`, `:1409-1461` (shifted by the added comments only) |

Notes:
- `ui_us` scaling is retained (port-specific adaptation); the `0.25` cap only guards very narrow viewports. Donor's literal 240 at zoom 1 is the base-resolution value.
- `mm_pad_w=30`, `mm_pad_h=22` are the pre-existing stylebox padding allowances, unchanged.
- `sel_panel.offset_right` is floored with `maxf(_ms(44.0), …)` so a very narrow viewport cannot produce a negative width.

### 4.2 `variant3d/scripts/hud3d_adapter.gd` — world→minimap transform only

| Item | Before | After | After-location |
|---|---|---|---|
| Donor evidence header | "no donor path:line was re-read … UNVERIFIED" | donor citations (`initminimap.inc`, `showunitcontrol.inc`, `classes.script`, `misc.script`) + **DERIVED/UNVERIFIED** scale table + painter-contract note | `:16-33` |
| Box source | `cam.get_viewport_corners()` → loop inline in `get_minimap_box()` | same four corners, now produced by new `get_minimap_corners()`; `get_minimap_box()` derives the AABB from them | `:61-80`, `:85-117` |
| Half-map fix (`p += Vector2(mw,mh)*TILE_M*0.5`) | present at `:57-62` | **preserved verbatim** as `var p: Vector2 = pc + half` (`half = extent*0.5`) with the original PLAY2FIX-NAVBOX comment | `:105-109` |
| Mapping | `int(p.x / TILE_M)` clamped to `[0,mw-1]` | `u = p.x/extent.x`, `v = p.y/extent.y` (≡ `(x+halfW)/mapW`), then `clampf(u*mw, 0, mw-1)` | `:98-99`, `:112-117` |
| `world_pos*view_scale` | absent (already fixed) | still absent; explicitly documented | header `:20-22`, `:88-90` |
| Contract | inclusive `Vector4i` from exclusive `Rect2` end | **unchanged** (`+1` on width/height) | `:79-80` |

Numerical equivalence (no regression): `u*mw = (x+halfW)/(mw*TILE_M) * mw = (x+halfW)/TILE_M`, identical to the old `p.x/TILE_M`; integer truncation + clamp and clamp + integer truncation agree because the bounds are integers. The change is an explicit restatement of the donor formula, not a numeric change.

## 5. Backups

| File | Backup | Bytes |
|---|---|---|
| `variant3d/scripts/hud.gd` | `inbox/backup/hud.gd.bak-HUD01` | 77,668 |
| `variant3d/scripts/hud3d_adapter.gd` | `inbox/backup/hud3d_adapter.gd.bak-HUD01` | 4,022 |

Both copies were taken **before** the first edit and verified present.

## 6. Validation — variant runner only

All launches: `python variant3d/tools/godot_runner.py run --id <job> --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/<file>.gd` (no extra `--` before Godot flags, per `V782` trap). No direct `godot`. No gates, no ladder, no test edits.

| Ticket | Job id | File parsed | Result | Wait / run | stderr |
|---:|---|---|---|---|---|
| 340 | `hud01-smoke` | `res://scripts/hud.gd` | `ok`, exit 0 | 126.70 s / 7.75 s | **0 bytes; `SCRIPT ERROR == 0`** |
| 349 | `hud01-smoke-adapter` | `res://scripts/hud3d_adapter.gd` | `ok`, exit 0 | 110.59 s / 6.25 s | **0 bytes; `SCRIPT ERROR == 0`** |
| 357 | `hud01-smoke-adapter-final` (re-run after the final provenance comment) | `res://scripts/hud3d_adapter.gd` | `ok`, exit 0 | 78.83 s / 7.73 s | **0 bytes; `SCRIPT ERROR == 0`** |

Result JSON: `variant3d/.godot_queue/results/00000340.json`, `00000349.json`, `00000357.json`. Stderr scanned from the per-job `stderr.txt` referenced by those JSONs. **Parse-only smoke, not a runtime/donor A/B** — no visual parity claim.

Foreign concurrent edits were present in the working tree (`camera3d.gd`, `input_controller.gd`, `config.gd`, shaders, tests, etc.). None were touched or reverted by this ticket; the smoke jobs ran against the shared concurrent tree and still reported zero `SCRIPT ERROR`.

## 7. Explicit UNVERIFIED / PORT APPROXIMATION labels

- **DERIVED / UNVERIFIED** — the linear world→minimap scale table (256 → 0.9375, 320 → 0.75, 480 → 0.5, 640 → 0.375 px/tile; metre column = half those values). Stated in the adapter header, not used in code (`DEC_08` §5.4, §9 Q1).
- **UNVERIFIED** — donor frustum shape: quad vs AABB vs lens (`minimap.cfg:4` `FrustumVisible=True` but `:26` `Visible=False`; `DEC_08` §9 Q2). The adapter supplies four corners; `hud.gd:_mm_paint_box` strokes their **AABB** → labelled **PORT APPROXIMATION** in the adapter header. A true 4-edge quad stroke is not claimed.
- **UNVERIFIED** — engine internals of `SetGUIMiniMapPrimitivePosition` / `SetMiniMapFrustumVisible`; whether the engine always stretches the full map extent into 240 px and how `SetGUIMinimapZoom(1)` interacts (`DEC_08` §9 Q1).
- **PORT APPROXIMATION** — the port minimap image is 1 px per tile stretched into the 240-px widget; donor blips are fixed 3×3/4×4 atlas primitives, not reproduced (texture and blip logic deliberately untouched per ticket scope).
- **UNVERIFIED** — minimap GUI event X/Y units feeding the jump helper (`DSEL_02` Q5); not acted on because jump is out of scope.

## 8. Left open / not implemented

1. **Donor double-click minimap jump — separate ticket.** Donor path: `eventminimap.inc:37-54` (Tag 30 up), `onmousedown.inc:116-131,121-122` (double-click → `_control_MoveCameraToPosition`), helper `control.script:574-613` (`dx=cx-tx`, `dz=0.1`, `angleZ=+32°`, `offZ≈1.6004*h`, rotate into heading, rotate-to-target off). Port has only one jump path (`hud.gd:1414-1466` → `camera3d.jump_to_world`). Implementing the donor offset requires edits to `input_controller.gd` and/or `camera3d.gd`, which are **not owned by HUD-01**; `ArcTan` semantics are also UNVERIFIED (`DSEL_02` Q1). No change made — report as a new ticket.
2. **Stale `camera3d.gd:354` comment — not edited by HUD-01.** It belongs to another owner (`GAPS.md` §1: "fix stale comment when owner touches it"). Concurrent CAM01 work has already corrected it: current `camera3d.gd:363-371` now says CENTRED world metres, not top-left map-origin. HUD-01 only added a note about that line drift in the adapter header.
3. **`variant3d/scripts/uitest.gd:304-307` still asserts `par.anchor_left == 0.0`** with detail `"minimap bottom-left"`. After this geometry change that assertion is expected to **fail**; `DEC_08` §8 already notes that closing W23 item 4 requires updating that test. The file is foreign-owned and outside this ticket — **not edited**. Hand off to COORD / test owner (flip the assertion to a right anchor, e.g. `anchor_left == 1.0` / `anchor_right == 1.0`, 240 px). This is why no gate was run here (ticket says no gates/ladder).
4. **True quad stroke** for the frustum (instead of the unchanged AABB painter) is left for a follow-up; donor quad-vs-AABB shape is UNVERIFIED and the `Rect2` box contract is shared with unchanged HUD code.

## 9. Open questions

1. Does the donor engine always stretch the full map extent into 240 px, and how does `SetGUIMinimapZoom(1)` enter the projection? Needs runtime A/B or native decompilation (`DEC_08` §9 Q1).
2. Is the visible donor frustum a rotated quad, an AABB, or a lens marker? `FrustumVisible=True` vs `FrustumLineStyle.Visible=False` is unresolved (`DEC_08` §9 Q2).
3. At what viewport widths should the port abandon the fixed-donor 240 px (its `ui_us` scaling currently shrinks it)? A donor screenshot at multiple resolutions would settle it.
4. Who owns the `uitest.gd:304-307` assertion update, and when should it land relative to the HUD geometry change? (No gate was run in this ticket.)
5. `ArcTan` / `VectorRotate*` units for the donor minimap jump remain UNVERIFIED — relevant only to the separate jump ticket.

## 10. Final scope statement

**No file other than the two owned sources (`variant3d/scripts/hud.gd`, `variant3d/scripts/hud3d_adapter.gd`), the two required backup copies, and this report was edited by HUD-01.** No donor file was copied, unpacked or executed. No `godot` process was launched outside `variant3d/tools/godot_runner.py`. No gates, ladder, locale layer or pop-cap changes were made.
