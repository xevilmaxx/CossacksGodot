---
id: MINIMAP-QUAD-01
title: "MINIMAP-QUAD-01 — 4-edge donor frustum quad on the minimap (adapter-side implementation + parse repair)"
owner: MINIMAP-QUAD-01 (small implementation builder)
date: 2026-11-25
status: IMPLEMENTED__PARSE_REPAIR_CLEAN__NO_GATES
scope: "Exactly one source file edited (variant3d/scripts/hud3d_adapter.gd) plus its required backup copy and this report. No other source/config/test file edited — not hud.gd, camera3d.gd, t_view_rect_rv.gd, any atom, or app/**. Donor READ-ONLY. No gates, no ladder, no direct godot invocation."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION]
---

# MINIMAP-QUAD-01 — 4-edge donor frustum quad on the minimap

## 1. Goal and ownership

HUD-01 (`reports/HUD_01_minimap.md` §7 item 4 / §8 item 4) left the frustum as an
AABB: `hud3d_adapter.gd` exposed four mapped camera ground corners but the HUD
painter (`hud.gd:_mm_paint_box`, `:1516-1526`) stroked only their AABB. This
ticket adds the adapter-side quad capability: expose the four corners as an
ordered polygon and implement a true 4-edge stroke, **without** touching the
`Rect2` box contract that CAM-RV-01 verifies.

**Exclusive ownership honoured:** `variant3d/scripts/hud3d_adapter.gd` and this
report only. `hud.gd` and `camera3d.gd` (MMJUMP-02), `t_view_rect_rv.gd`, the
atoms and `app/**` were **read only**.

## 2. Sources read first (all read-only)

| Source | What it supplied |
|---|---|
| `reports/HUD_01_minimap.md` `:38,65-76,101-114` | Claim 4: four ground corners from `GetCameraFrustumQuadrangle`; painter still strokes AABB (PA); true quad stroke explicitly left open at §8 item 4 |
| `reports/CAM_RV_01_view_rect_runtime.md` `:35,81-85,136-143,191-193` | The AABB `get_minimap_box() = Rect2(12, 11, 40, 34)` must remain valid; box derived from `world.view_rect` is compared to it |
| `decomp/DEC_08_ui_strings.md` §5.2 `:143-153`, §9 Q2 `:269` | `initminimap.inc:29-39` frustum on; `minimap.cfg:4` `FrustumVisible=True` vs `:26` line-style `Visible=False`; quad-vs-AABB shape UNVERIFIED |
| `reports/DSEL_02_donor_pick_math.md` claim 15 `:79`, claim 12 `:76`, claims 18/19 `:82-83` | 240×240 minimap with engine-drawn frustum box; `GetCameraFrustumQuadrangle` EXE API; centred-world mapping; 240 px zoom 1 |
| `variant3d/scripts/hud3d_adapter.gd` (owned, read in full) | Existing `get_minimap_box()`, `get_minimap_corners()`, half-map fix at `:104-109`, painter contract at `:35-37` |
| `variant3d/scripts/hud.gd` (read only) | `:201-213` adapter created/bound; `:1476-1514` painter uses `get_minimap_box()` then `_mm_paint_box(box,false)`; `:1516-1526` stroke implementation |
| `variant3d/scripts/camera3d.gd` (read only) | `:377-397` `get_viewport_corners()` returns TL,TR,BR,BL in order, in CENTRED metres |

## 3. Donor citations and labels

| # | Claim | Label | Citation |
|---:|---|---|---|
| 1 | Minimap frustum is visible | OBS | `initminimap.inc:29-39`, `SetMiniMapFrustumVisible(true)` at `:37`; `DSEL_02` claim 15 |
| 2 | Frustum = four ground corners `GetCameraFrustumQuadrangle(lt,rt,rb,lb)` | OBS (API) / U (shape) | `classes.script:6030-6040`; `DSEL_02` claim 12 (EXE API @`0x1fdf..`) |
| 3 | World coords centred → `u=(x+halfW)/mapW`, `v=(z+halfH)/mapH` | OBS + D | `misc.script:2017,2025`; `dogenerate.inc:402-404`; `DSEL_02` claims 18/19 |
| 4 | Exact visible donor frustum shape (quad / AABB / lens) | **UNVERIFIED** | `minimap.cfg:4` vs `:26`; `DEC_08` §9 Q2; `HUD_01` §7 item 4 |
| 5 | Port 4-edge stroke is a **PORT APPROXIMATION** of the donor engine primitive | PA | This change; donor not executed (read-only), oblique-camera shape not A/B tested |

Labels: **OBS** = observed literal at cited `path:line`; **D** = derived; **U** = UNVERIFIED; **PA** = port approximation.

## 4. Before → after (`variant3d/scripts/hud3d_adapter.gd`)

All edits are **additive**: a header-comment block and three new methods. No
pre-existing function body was modified.

| Item | Before | After | After-location |
|---|---|---|---|
| Header provenance | PAINTER CONTRACT note ends at "still strokes the AABB (PORT APPROXIMATION …)" | Added a `MINIMAP-QUAD-01` block with donor `path:line` citations, the 0→1→2→3→0 edge order, the **PORT APPROXIMATION** label, and the `get_minimap_box()`-unchanged note | `:39-55` |
| Quad polygon API | absent | `get_minimap_quad() -> PackedVector2Array`: the four `get_minimap_corners()` values in TL→TR→BR→BL order, unrounded, same minimap-image pixel space as `get_minimap_box()` | `:140-150` |
| Quad stroke | absent | `stroke_minimap_quad(restore: bool = false) -> bool`: pulls `hud.minimap_view_img` / `hud.minimap_img`, strokes 4 edges 0→1→2→3→0 in `Color(1,1,1,0.9)`, restores from the clean image when `restore=true`; returns `false` on missing buffers or incomplete quad | `:153-179` |
| Line primitive | absent | `_plot_quad_line(...)`: integer Bresenham with in-image bounds guard | `:182-207` |
| **`get_minimap_box()`** | inclusive `Vector4i`-compatible `Rect2`, AABB from the four corners | **byte-identical — untouched** | `:73-99` |
| **`get_minimap_corners()`** | centred-world mapping + half-map fix | **byte-identical — untouched** (half-map fix preserved at `:104-109`, formerly `:57-62`) | `:103-137` |
| HUD layout / geometry / jump | — | **unchanged** (no `hud.gd` edit) | — |

### 4.1 Parse repair (urgent follow-up)

The owner's real game hit parse errors at adapter `:172-173` and a cascade at
`hud.gd:207` (`Nonexistent function 'new' in base 'GDScript'`) because the
adapter failed to load. **Root cause: inferred-type (`var w :=` / `var h :=`)
declarations in my earlier edit**, whose receiver (`clean_img`) is a `Variant`
obtained via `hud.get(...)`, so Godot could not infer a type for `get_width()` /
`get_height()`. Fixed with explicit declared types matching the actual Godot 4
return type (`int`):

| Line | Before (broken) | After (fixed) |
|---:|---|---|
| `hud3d_adapter.gd:172` | `var w := clean_img.get_width()` | `var w: int = clean_img.get_width()` |
| `hud3d_adapter.gd:173` | `var h := clean_img.get_height()` | `var h: int = clean_img.get_height()` |

No behaviour, no assertion and no other line was changed by the repair.

### 4.2 Integration status

`stroke_minimap_quad()` is exposed and self-contained, but the HUD painter is
`hud.gd:_draw_minimap_viewport_box` (`:1476-1514`), which still calls
`get_minimap_box()` and `_mm_paint_box(box,false)`. **Replacing that call site
with `stroke_minimap_quad(false)` / `(true)` requires editing `hud.gd`, which is
foreign-owned (MMJUMP-02) and explicitly out of this ticket's scope.** The
adapter therefore provides the true-quad implementation and API; the painter
wire-up is recorded as an open question (§7 item 1), not claimed as done.

## 5. Backup

| File | Backup | Bytes |
|---|---|---|
| `variant3d/scripts/hud3d_adapter.gd` | `inbox/backup/hud3d_adapter.gd.bak-MINIMAPQUAD01` | 6164 |

Taken **before** the first edit and verified present.

## 6. Validation — variant runner only (Windows `python`)

All launches were `python variant3d/tools/godot_runner.py run --id <id> --timeout <t> -- <godot args>`.
No direct `godot`, no gates, no ladder, no test edits.

| Ticket / job | id | Args | Result | exit | wait / run | stderr / `SCRIPT ERROR` |
|---:|---|---|---|---:|---|---|
| 427 | `minimapquad01-smoke` (initial) | `--headless --path variant3d --check-only --script res://scripts/hud3d_adapter.gd` | `failed` | 1 | 269.85 s / 5.70 s | **2 parse errors at `:172`/`:173`** (the inferred-type bug), `hud.gd:207` cascade reported by owner |
| 437 | `minimapquad01-smoke` (after first fix) | same | **`ok`** | **0** | 24.11 s / 7.52 s | 0 bytes, `SCRIPT ERROR == 0` |
| 442 | `minimapquad01-repair` (requested re-validate) | same | **`ok`** | **0** | 365.15 s / 4.11 s | **0 bytes, `SCRIPT ERROR == 0`** |
| 454 | `minimapquad01-boot` (real boot path) | `--headless --path variant3d -- --self-test variant3d/selftest.json` | `skipped` | — | — | queue race (`serving=465`), not a Godot result |
| 481 | `minimapquad01-boot2` (retry) | same | `failed` | 1 | 64.72 s / 88.64 s | **0 bytes, `SCRIPT ERROR == 0`** — no parse error, no `bind_3d`/`.new()`/adapter lines |

Result JSONs: `variant3d/.godot_queue/results/000004{27,37,42}.json` and
`000004{54,81}.json`, with per-job `stdout.txt` / `stderr.txt`.

**Parse-error verdict: GONE.** The required check-only job 442 is `ok`/exit 0
with empty stderr and `SCRIPT ERROR == 0`. In the real boot path (481) stderr is
also empty with `SCRIPT ERROR == 0`; the specific `Cannot infer the type of
"w"/"h"` errors and the `hud.gd:207` `.new()` cascade the owner reported are
**absent**. Job 481's exit 1 is not a parse failure: stdout contains only the
Godot v4.7.2 banner and no self-test report line, consistent with the many
other agents' self-test jobs in the same queue window that also exit 1, i.e. a
pre-existing self-test harness/path condition, not this adapter. This is a
**parse/run smoke, not a donor visual A/B** — no visual parity claim is made.

## 7. Open questions

1. **Painter wire-up (who/when):** `hud.gd:_draw_minimap_viewport_box:1490-1513`
   must call `stroke_minimap_quad(false)` / `(true)` in place of
   `_mm_paint_box(box,false)` / `(true)` to replace the AABB with the quad on
   screen. `hud.gd` is owned by MMJUMP-02; no edit made here. Until that lands,
   the visible minimap outline remains the AABB.
2. **Frustum shape parity:** quad vs AABB vs lens under the oblique −32° camera
   is UNVERIFIED (`DEC_08` §9 Q2). The quad stroke is a **PORT APPROXIMATION**,
   not a parity claim; no donor was executed.
3. **Boot exit 1:** job 481 exits 1 with empty stderr; the likely cause is the
   relative `--self-test variant3d/selftest.json` path under `--path variant3d`
   (main.gd `:1243-1244`, `:2026-2032`) or a pre-existing self-test failure.
   Out of this ticket's scope; the parse repair is independently proven by 437/442.
4. **Buffer contract:** `stroke_minimap_quad()` assumes the bound hud exposes
   `minimap_view_img`, `minimap_img` (as `_mm_paint_box` does). If the hud owner
   renames those, the method returns `false` rather than drawing.
5. **Blip scale / locale / jump** remain as HUD-01 left them; untouched here.

## 8. Explicit non-regression statements

- **`get_minimap_box()` is unchanged — byte-identical to the backup.** Its body
  at `:73-99` was not edited, so the inclusive `(12,11)`, exclusive `(52,45)`
  `Rect2(12,11,40,34)` result measured by CAM-RV-01
  (`CAM_RV_01_view_rect_runtime.md:136-143,191-193`) is unchanged and
  **CAM-RV-01 remains valid**. No test assertion was weakened or edited.
- The centred-world formula and the half-map fix (`pc + half`, `:104-109`,
  originally `:57-62`) are **preserved verbatim**; minimap geometry and HUD
  layout are untouched.
- Parse repair touched only `:172-173`, changing `:=` to explicit `: int` —
  the actual return type of `Image.get_width()`/`get_height()` — and nothing else.
- No donor file was copied, unpacked or executed. No gate or terrain ladder was
  run. No `godot` process was launched outside `variant3d/tools/godot_runner.py`.

## 9. Summary

Added three additive methods to `hud3d_adapter.gd` — `get_minimap_quad()` (four
ordered TL→TR→BR→BL corners), `stroke_minimap_quad()` (true 4-edge polygon
stroke into the HUD minimap image, with clean-image restore) and
`_plot_quad_line()` (bounded integer Bresenham) — plus donor-citation comments
labelling the stroke **PORT APPROXIMATION**. `get_minimap_box()` and
`get_minimap_corners()` were left byte-identical, so CAM-RV-01's AABB
`(12,11,40,34)` stays valid. An urgent parse error caused by inferred-type
`:=` variables at `:172-173` in the first edit was repaired with explicit
`: int` declarations; the final check-only job `minimapquad01-repair` (442) is
`ok`, exit 0, stderr empty, `SCRIPT ERROR == 0`, and the real boot job (481)
shows no parse error or `hud.gd:207` cascade.

**No file other than `variant3d/scripts/hud3d_adapter.gd`, its backup
`inbox/backup/hud3d_adapter.gd.bak-MINIMAPQUAD01`, and this report was edited by
MINIMAP-QUAD-01.**
