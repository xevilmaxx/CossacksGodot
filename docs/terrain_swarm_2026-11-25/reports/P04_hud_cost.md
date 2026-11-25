---
id: P04-HUD-COST
ticket: TERRAIN-SWARM-2026-11-25 / WAVE P / P04 (read-only HUD + minimap per-frame cost audit)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS__NO_CODE_EDITS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P04_hud_cost.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No Godot run, no capture and no frame-time telemetry were produced by this agent. All cost rankings are static/analytical (INFERRED) from OBSERVED code lines. **Measured FPS is UNVERIFIED.** Donor parity is not claimed and is out of scope for a cost audit (CHARTER §3)."
---

# P04 — HUD / minimap per-frame and main-thread cost audit

## 0. Scope compliance

- Read-only. Exactly one file created (this report). **No code, script, test, config, shader or
  runner file edited.** No Godot process started and no runner job submitted
  (`WAVE_G_CHARTER.md:31,67-70`: only G04 runs Godot).
- Charters read in full: `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave P row P04 at
  `:77`, P12 at `:85`, backup rule at `:87`) and
  `docs/terrain_swarm_2026-11-25/CHARTER.md` (guardrails `:55-69`, green gates `:128-129`).
- Source read in full: `variant3d/scripts/hud.gd` (2056 lines) and
  `variant3d/scripts/hud3d_adapter.gd` (234 lines). Supporting reads:
  `variant3d/scripts/camera3d.gd:296-305,397-421`, `variant3d/scripts/game.gd:2957-2984,4065-4074,4266-4271`,
  `variant3d/scripts/data.gd:25,33-34,154,188-194`, `variant3d/scripts/config.gd:76,120-121,460-461,513-514`,
  `variant3d/tests/t_hud_layout.gd` (632 lines), `variant3d/scripts/uitest.gd:100-319`,
  `variant3d/tests/results/t_hud_layout.json`, `variant3d/uitest.json`,
  `docs/coord_swarm_2026-11-25/reports/UI_TOPBAR_01.md`,
  `docs/terrain_swarm_2026-11-25/reports/G17_perf_audit.md`.
- **No measured FPS claim is made.** Every "cost" word below means *analytical work estimate*,
  not a benchmark. No donor A/B frame exists.

## 1. Bottom line for COORD (summary)

The HUD already contains a substantial prior performance pass (`T-PERF-RENDER` / `T-MINIMAP`
comments throughout `hud.gd`), so the obvious waste is gone: there is **no `_draw()` override**,
**no per-frame `get_node`/group lookup**, **no per-frame panel rebuild**, and label writes are
dirty-flagged. Three per-frame costs remain:

1. **3D minimap viewport box is derived from four camera ray-casts every frame *before* the
   change gate** (`hud.gd:1516,1666-1698` → `hud3d_adapter.gd:73-94,103-137` →
   `camera3d.gd:397-404,296-305`). When the camera moves, the whole minimap image is also
   re-uploaded to the GPU every frame (`hud.gd:1704`). **Rank 1.**
2. **~20–30 temporary `String` allocations per frame** for the six resource rows and the status
   line, even when nothing changed (`hud.gd:1454-1485,1499-1504`). Assignment is dirty-flagged,
   but *formatting* is not. This is the likeliest contributor to low **idle** FPS. **Rank 2.**
3. Full minimap image duplicate + blip rebuild + texture upload every `MINIMAP_INTERVAL`
   (0.25–1.0 s) (`hud.gd:1509-1512,1968-2035`). **Rank 3.**

The HUD is **not** the whole answer to the owner's "FPS too low even on start" — G17
(`G17_perf_audit.md:105-142`) identifies a synchronous ~683 MiB mip build on the loading path and
a ~683 MiB atlas VRAM footprint. HUD work is a **low-risk incremental** improvement, and its
benefit at runtime is **UNVERIFIED** without a capture.

## 2. OBSERVED — what the HUD actually executes per frame

### 2.1 The single `_process` body (`hud.gd:1437-1523`)

| Site | What runs | Cadence |
|---|---|---|
| `:1443-1444` | `fps_ema = lerpf(...)` every frame | per frame |
| `:1445-1448` | `Performance.get_monitor(TIME_FPS)` + `"%03d"` format | 0.5 s |
| `:1449-1453` | `_recompute_eco()` + `unit_count()` + `queue_count()` | 0.5 s |
| `:1454-1480` | 6× resource read + `str()`/`"(%d)"`/`"%s %s"` formats + deficit flags | **per frame** |
| `:1481-1496` | idle/mine text formats + disabled + colour overrides | per frame (gated writes) |
| `:1499-1504` | status `"units %d/%d score %d %s"` format | **per frame** |
| `:1505-1508` | message timer | per frame |
| `:1509-1512` | `_update_minimap()` | `MINIMAP_INTERVAL` (0.25–1.0 s) |
| `:1516` | `_draw_minimap_viewport_box()` | **per frame** |
| `:1519-1523` | `_update_dynamic()` | 0.75 s, only when `build_ghost_sid == ""` |

The only unconditional per-frame bodies are the resource/status formatting block, the message
timer, and the viewport-box draw. Everything else is already throttled.

### 2.2 Answers to the ticket's specific audit questions

- **Minimap redraw / `Texture` updates:** yes. `_draw_minimap_viewport_box()` at `:1516` every
  frame; on box change `_mm_paint_box(restore)` + `_mm_paint_box(paint)` +
  `minimap_tex.update(minimap_view_img)` at `:1700-1704`. `ImageTexture.update()` re-uploads the
  **whole** `MAP_W×MAP_H` RGBA8 image (Godot has no partial `ImageTexture.update` API here).
  Default config map is 240×240 = 230,400 B/upload (`config.gd:120-121,513-514`), 160×160
  fixture (`data.gd:33-34`) = 102,400 B; larger custom maps scale quadratically.
- **`_draw()` calls:** **none.** Neither `hud.gd` nor `hud3d_adapter.gd` defines or calls
  `CanvasItem._draw()`. All minimap drawing is CPU-side `Image.set_pixel()` followed by a texture
  upload; the adapter's quad stroke (`hud3d_adapter.gd:164-207`) is *not wired in* (its own comment
  at `:160-163` leaves the call site open). There is no `_draw()` hot path to optimize.
- **String formatting of resource counts:** yes — `str(stock)` at `:1457`, `"(%d-%d)"` / `"(%d)"`
  at `:1463`, `"%s  %s"` at `:1464`, `"idle %d"` at `:1482`, `"slots %d"` at `:1492`, status at
  `:1500-1501`. The *assignment* is dirty-flagged (`:1466-1470,1482-1495,1502-1504`), so no
  relayout on identical text, but the **formatting itself runs every frame**.
- **Polling game state every frame:** yes for `game.players[0].res[]`, `famine`, `gold_famine_t`,
  `farm_cap`, `score`, `paused` (`:1456,1472-1477,1500-1501`) and for the camera
  (`:1673` / `:1680`). Economy/selection polling is already throttled (`:1450-1453`, `:1519-1523`).
- **Repeated `get_node`:** **none per frame.** Group lookups
  `get_tree().get_first_node_in_group("c3_input")` occur only in event handlers
  (`:658,664,1084,1622`). The closest per-frame equivalents are the viewport camera queries
  `get_viewport().get_camera_2d()` at `:1673` (and `:1613` on minimap input).
- **Control layout invalidation:** label writes are change-gated as above; `add_theme_*_override`
  happens only in `_apply_scale()` / `_layout_top()` (`:301-388,513-595`), called from `bind()`,
  `_on_vp_resize()` and `refresh_selection()` — **not per frame**. `show_hint()` explicitly
  no-ops on identical text (`:1342-1346`), preserving a prior fix.
- **Group / selection panels rebuilt each frame:** **no.** `refresh_selection()` (`:727-925`)
  rebuilds all buttons only on selection/order changes and action handlers. The periodic
  `_update_dynamic()` (`:1289-1340`) *never frees buttons* — it only updates text/disabled, by
  design (`:1290-1292`). The costly `find_children("*","Control",true,false)` subtree walk
  (`:302`) runs inside `_apply_scale()`, i.e. on resize/selection events, not per frame.
- **Font / label updates:** per-frame text assignments are dirty-flagged; colour overrides for
  deficit/idle states fire only on change (`:1478-1480,1488-1490`). `fps_label` is already
  gated to 0.5 s (`:1445-1448`). No per-frame font work.

### 2.3 The 3D adapter hot chain (the important one)

`hud.gd:1674-1684` calls `_hud3d_adapter.get_minimap_box()` every frame in 3D mode. That single
call performs:

1. `hud.get("game")` + `MAP_W/MAP_H` reads (`hud3d_adapter.gd:74-76`);
2. `get_minimap_corners()` (`:79` → `:103-137`), which **repeats** the game/size reads
   (`:105-107`), checks `has_method` (`:110`), calls `cam.get_viewport_corners()` (`:112`);
3. `camera3d.gd:397-404` allocates an `Array` and calls `screen_to_world()` four times;
   `camera3d.gd:296-305` performs `project_ray_origin()` + `project_ray_normal()` +
   plane intersection **four times per frame**;
4. a new `PackedVector2Array` plus finite/clamp loops (`hud3d_adapter.gd:104,118-136`);
5. a second AABB loop over the four points (`:86-92`).

**All of that happens before `hud.gd:1697-1698`'s `if box == _mm_box_last: return` change gate.**
A completely static camera therefore still pays four ray casts and two array allocations at 60 Hz.
This is a genuine structural inefficiency, not micro-optimisation.

`camera3d.gd` uses perspective projection with a fixed runtime `fov` set at bind time
(`:175,179,195`) and implements pan **and** zoom as camera-position/height changes (`:111-116,731-753`).
Therefore a cheap `Transform3D` + viewport-size signature is sufficient to detect a changed box;
no fov change needs handling at runtime (OBSERVED code; INFERRED conclusion).

## 3. Ranked cost ledger

Ranked by (expected per-frame work × probability of occurring) ÷ risk of removing it.
"Class" is relative, not measured. All cost labels **INFERRED** from OBSERVED code; all FPS
impact **UNVERIFIED**.

| # | Hotspot | Site | Cadence | Mechanism / class | Label |
|---|---|---|---|---|---|
| 1 | 3D minimap viewport box derived before change gate; full-image texture upload when camera moves | `hud.gd:1516,1666-1704`; `hud3d_adapter.gd:73-94,103-137`; `camera3d.gd:296-305,397-404` | **every frame** + upload on change | 4 ray casts + 2 array allocs/frame, ~230 KB/upload at 240². **High** in 3D; upload dominates during pan/zoom | code OBSERVED, cost INFERRED, FPS UNVERIFIED |
| 2 | Resource + status string formatting | `hud.gd:1454-1485,1499-1504` | **every frame** | ~20–30 temporary Strings/frame → heap churn/GC even when idle; dirty flags prevent relayout but not formatting. **Medium**; strongest idle-FPS suspect | code OBSERVED, cost INFERRED, FPS UNVERIFIED |
| 3 | Full minimap rebuild per tick | `hud.gd:1509-1512,1968-2035` (duplicates `:1980,1987,1989,2033`; unit scan `:2027`→`:1835-1892`; force redraw `:2034-2035`) | 0.25–1.0 s | Two `Image.duplicate()` allocations + one full upload per tick; hidden-minimap guard at `:1973-1974` already helps. **Medium-low average / bursty** | code OBSERVED, cost INFERRED, FPS UNVERIFIED |
| 4 | Economy recompute | `hud.gd:1449-1452,1363-1435` | 0.5 s | Full `live_units` + `live_blds` scans, 3 dict allocations, nested `eat`/`weapons` loops. O(units+buildings) **periodic spike** with large armies | code OBSERVED, cost INFERRED, FPS UNVERIFIED |
| 5 | Dynamic button text pass | `hud.gd:1519-1523,1289-1340` | 0.75 s | `game.get_selected()` scans **all** entities (`game.gd:2979-2984`), lambda `filter` allocs, `build_cost_ui()` (`:1179-1202`, `game.gd:4065-4074`) may scan buildings. **Low** | code OBSERVED, cost INFERRED, FPS UNVERIFIED |
| 6 | FPS readout | `hud.gd:1443-1448` | per-frame lerp + 0.5 s monitor | `Performance.get_monitor` + one format twice/sec; `fps_ema` lerp every frame is effectively dead work. **Negligible** | code OBSERVED, cost INFERRED |
| 7 | Per-frame viewport camera query (2D path) | `hud.gd:1673` | **every frame** | `get_viewport().get_camera_2d()` lookup even when nothing moves. **Low**, folded into #1 fix | code OBSERVED, cost INFERRED |
| 8 | Event-driven panel rebuild / subtree walk | `hud.gd:727-925`, `:302`, group lookups `:658,664,1084,1622` | on input/selection/resize only | Not a per-frame cost; recorded to close the audit question. **N/A per frame** | code OBSERVED |

Explicitly **not** hotspots: `_draw()` (absent), per-frame `get_node` (absent), per-frame panel
rebuild (absent), per-frame theme/font override (absent), identical-string label writes
(dirty-flagged at `:1345,1466-1470,1482-1495,1502-1504`).

## 4. Regression constraints — must not be undone by P12

These are OBSERVED acceptance facts; P12 touches the same two files and must preserve all of them.

### 4.1 UX_TOPBAR / UI-TOPBAR-01 (`hud.gd`)

- The responsive top bar is `_layout_top()` (`:513-595`) driven by `ui_vp.x` (`:516`), with
  width thresholds `<1500/<1100/<800` (`:523-525`, tightened by MINIMAP-TIP-01), full-width
  `top_center` + clipped `top_panel` (`:394-403`), and `mouse_filter = IGNORE` on both
  (`:396,401`) — documented as intentional click-through
  (`UI_TOPBAR_01.md:66-67`; `D05_selection_ui.md:59` flags it as an owner decision, do **not**
  flip unilaterally).
- One `OptionButton` `speed_menu` with items `["II","1x","2x","4x"]` and float metadata
  `[0,1,2,4]` (`:444`, `:490-501`); `speed_buttons` stays empty for API readers (`:108`).
  `refresh_speed()` mirrors external changes without feeding back (`:635-644`).
- `_apply_scale()` calls `_layout_top()` **after** the generic meta pass so compact overrides win
  (`:319-326`); `_on_vp_resize()` is connected from `bind()` (`:198-199`, `:273-275`).
- Minimap geometry, `_mm_size/_mm_inset/_mm_corner` (`:283-299`), `_build_minimap()` (`:1525-1602`),
  minimap input / 3D jump (`:1604-1658`) were declared byte-identical by UI-TOPBAR-01
  (`UI_TOPBAR_01.md:40-48`). P12 must keep them byte-identical too, except for the explicitly
  proposed change-gate additions in §5.1.

### 4.2 Gates that must stay green

- `variant3d/uitest.json`: OBSERVED `passed: true`, **17 steps** (verified by reading the JSON).
  HUD-sensitive steps: `select_box` (`:118-123`, reads `hud_report().selection_panel`),
  `train_flow` (`:180-193`, `dyn_buttons kind=train`), `market_panel` (`:236-242`),
  `research_panel` (`:248-261`, `dyn_buttons kind=research`), `speed_pause` (`:275-280`,
  `main.set_speed`), `minimap_frustum` (`:304-309`, `minimap_rect.parent.anchor_left == 1.0`).
- `variant3d/tests/results/t_hud_layout.json`: OBSERVED `verdict: PASS`, `62 passes / 0 fails /
  3 skipped`, `capture_status: PASS`, `headless: false`. Atom asserts: `hud.ui_vp` tracks each
  viewport (`t_hud_layout.gd:360-365`), resize hook present (`:366-367`), six resource labels +
  six hinted icons (`:390-410`), exactly one speed widget with `["II","1x","2x","4x"]` and
  `[0,1,2,4]` metadata + no legacy speed buttons (`:412-441`), minimap bottom-right anchors and
  240 declared slot (`:443-486`), and no unclipped control outside the viewport (`:488-511`).
- `hud_report()` (`:2037-2056`) is read by the selftest/uitest; do not change its keys.
- No test weakening: no threshold/assertion/expected value may be edited by P12.

## 5. Proposed exact low-risk changes for P12 (implementation owner only)

P12 owns **only** `variant3d/scripts/hud.gd` + `hud3d_adapter.gd`. Before any edit, create
`inbox/backup/hud.gd.bak-P12` and `inbox/backup/hud3d_adapter.gd.bak-P12`
(`WAVE_G_CHARTER.md:87`). All items below are **proposals from a read-only agent**, not applied.
Expected benefit is INFERRED; runtime FPS effect **UNVERIFIED** until a measured run by G04/COORD.

### 5.1 P12-A — gate the minimap box behind a cheap camera-state signature (highest value)

**Where:** `hud.gd:1666-1704` (`_draw_minimap_viewport_box`), with two new member vars near `:47`
(e.g. `_mm_box_sig_cam: Transform3D`, `_mm_box_sig_vp: Vector2`, `_mm_box_sig_valid := false`).

**Change:** at function entry, after the null guard (`:1667-1668`), compute
`var sig_cam: Transform3D` from the active camera (`_bound_cam3d` in 3D; `get_camera_2d()` global
transform in 2D) and `var sig_vp: Vector2 = get_viewport().get_visible_rect().size`. If
`not force and _mm_box_sig_valid and sig_cam == _mm_box_sig_cam and sig_vp == _mm_box_sig_vp`,
**return before** the adapter call at `:1680` and before the 2D maths at `:1685-1695`. On a real
change (or `force == true`), run the existing body unchanged, then store the signature and set
`_mm_box_sig_valid = true`.

**Why safe:** the box is a pure function of camera transform + viewport size + map size
(`hud3d_adapter.gd:74-94,103-137`; `camera3d.gd:296-305,397-404`), and pan **and** zoom both
move the 3D camera transform (`camera3d.gd:111-116,731-753`), fov is constant at runtime
(`:175,179,195`). `_update_minimap()` already calls with `force = true` (`:2035`), so a rebuilt
image still repaints the box and re-uploads. Minimap click/drag jumps call
`_draw_minimap_viewport_box()` after moving the camera (`:1619,1628,1639,1643`); the transform
changes, so the gate passes. No minimap geometry, data, order or donor offset code changes.
Optionally include the static `fov` in the signature defensively (cheap, no behaviour change).

**Acceptance:** box still visible at all three `t_hud_layout` widths and on minimap jump/drag;
`minimap_frustum` 17/17 step unchanged; with a static camera the adapter's
`cam.get_viewport_corners()` and `minimap_tex.update()` must no longer run each frame (verify by
an instrumented count in a *future* capture, **not by this agent**).

### 5.2 P12-B — replace per-frame resource formatting with an int-signature gate

**Where:** `hud.gd:1454-1480`. Add `var _res_sig: Array = []` near `:91`, sized 6 in `bind()`.

**Change:** per frame compute the cheap ints `stock`, `workers`, `consume` as today (`:1455-1462`).
Store `[stock, workers, consume]` in `_res_sig[i]`; build `stock_s`, `net_s` and `rt` **only when
that triple changed** (or on first frame). Keep the existing `_last_res_text` comparison and
`res_labels[i].text` assignment (`:1466-1470`) **unchanged**, and keep the deficit evaluation
(`:1471-1480`) **per frame** using the same freshly read ints/flags.

**Why safe:** the displayed string is a pure function of those ints, so output is identical;
deficit tint timing is unchanged, unlike moving the whole block to the 0.5 s eco cadence (which
would delay famine/gold-famine tint and break the deliberate "other fields stay live" decision at
`:1497`). Removes ~15–18 String allocations/frame in the common idle case.

**Acceptance:** `t_hud_layout` `six_resource_entries_*` (non-empty labels, `:408-410`) still PASS
at 1024/1280/1920; `hud_report().resource_labels` stays non-empty; a resource gain/loss still
updates the label on the next frame.

### 5.3 P12-C — gate the status-line format on its inputs

**Where:** `hud.gd:1499-1504`. Add `var _status_sig: Array = []` near `:94`.

**Change:** compute `[ucount, int(game.players[0].farm_cap), int(game.players[0].score),
bool(game.paused)]`; format the `"units %d/%d score %d %s"` string only when that tuple changes;
keep the existing `_last_status_text` check and `status_label.text` assignment intact. `ucount`
is already the throttled `_cached_ucount` (`:1497`), so this removes ~1–2 allocations/frame.

**Acceptance:** `hud_report()["status_text"]` (`:2048`) still reports the exact same string for a
given state; no uitest step reads it, so 17/17 is unaffected.

### 5.4 P12-D — remove the unused `fps_ema` work (optional, smallest)

**Where:** `hud.gd:95-97,1443-1444`. `fps_ema` is written every frame but never read (the label
uses `Performance.get_monitor` at `:1448`). Either delete the var and the lerp, or use the EMA
for the label. **Recommend deletion** (no behaviour change). Keep the 0.5 s label cadence
byte-identical.

**Acceptance:** FPS label still shows a 3-digit number; no test reads `fps_ema`.

### 5.5 P12-E — avoid one full image duplicate per minimap tick (optional, verify first)

**Where:** `hud.gd:2033` (`minimap_view_img = minimap_img.duplicate()`).

**Change:** allocate `minimap_view_img` once in `_build_minimap()` (`:1559`) and reuse it with
`minimap_view_img.blit_rect(minimap_img, Rect2i(0, 0, w, h), Vector2i.ZERO)` on each tick,
removing one `Image.duplicate()` allocation per tick. **Do not apply without a focused check**:
`blit_rect` alpha/format behaviour vs `duplicate()` must be confirmed on this Godot version, and
the `force=true` repaint at `:2035` must still restore/paint correctly.

**Acceptance:** minimap pixels identical to a baseline capture (future job); `minimap` key in
`hud_report()` (`:2045`) stays true; 17/17 `minimap_frustum` unchanged.

### 5.6 Explicitly NOT recommended for P12

- Do **not** wire in `hud3d_adapter.stroke_minimap_quad()` (`:164-179`) — it would add four
  Bresenham strokes (`:184-207`) and a second `get_minimap_corners()` call **per frame**, and its
  call site is deliberately left open (`:160-163`). Quad-vs-AABB shape is UNVERIFIED (header `:49-55`).
- Do **not** draw the box as a separate Control/shader overlay to remove the full-image upload:
  conceptually best, but it changes HUD tree geometry and donor-approx behaviour and would need
  a fresh `t_hud_layout` + visual A/B — out of scope for a low-risk ticket.
- Do **not** move the whole resource/deficit block to the 0.5 s eco tick (behaviour change, §5.2).
- Do **not** touch `_layout_top()` thresholds, `speed_menu` literals/metadata, minimap anchors,
  `mouse_filter`, `hud_report()` keys, or any test file.

## 6. Acceptance checks (owner/COORD to run; this agent ran none)

Only the sole runner owner may submit jobs (`WAVE_G_CHARTER.md:31,67-70`). Exact forms, adapted
from `G04_gate_log.md:111-113` and `t_hud_layout.gd:35-44`:

1. **uitest 17/17** — fresh, on a quiet tree:
   `python variant3d\tools\godot_runner.py run --id P12-uitest --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json`
   Gate: `variant3d/uitest.json` regenerated with `passed: true` and **all 17 steps**, especially
   `select_box`, `train_flow`, `research_panel`, `speed_pause`, `minimap_frustum`. A stale JSON is
   not evidence (`UI_TOPBAR_01.md:121-124`).
2. **t_hud_layout** — fresh windowed run with the committed 64² fixture and the three PNG args:
   `python variant3d\tools\godot_runner.py run --id P12-hudlayout --timeout 90 -- --path variant3d --script res://tests/t_hud_layout.gd -- --config <ABS>\small_map_64.json --screenshot <TEMP>\p12_unused.png --png-1024x576 <TEMP>\p12_1024.png --png-1280x720 <TEMP>\p12_1280.png --png-1920x1080 <TEMP>\p12_1920.png`
   Gate: `variant3d/tests/results/t_hud_layout.json` `verdict: PASS`, 62 evaluated checks, 0
   fails, `capture_status: PASS`, and the three PNGs non-blank — matching the current baseline
   (`verdict PASS / 62 / 0 / 3 / capture PASS`).
3. **Static parse check** of both edited files via the runner (`--check-only`), as in
   `UI_TOPBAR_01.md:115-116`.
4. **No-weakening diff check:** `git diff` of P12 must contain zero hunks in `variant3d/tests/**`,
   `uitest.gd/json`, `selftest.gd/json`, `t_hud_layout.gd/json` (other owners' files), and no change
   to UI-TOPBAR-01 literals in `hud.gd:108,394-403,444,490-501,513-595,635-644`.
5. **Backups present:** `inbox/backup/hud.gd.bak-P12` and
   `inbox/backup/hud3d_adapter.gd.bak-P12` before any edit.

**FPS evidence:** none of the above measures FPS. A before/after FPS claim requires a real
capture/telemetry run planned by P09 and executed by G04. Until then **measured FPS is UNVERIFIED**,
and no "X% faster" statement may be made.

## 7. UNVERIFIED register

1. **Measured FPS / frame time — UNVERIFIED.** No Godot run, no capture, no profiler output from
   this agent. All rank/class statements are INFERRED from code.
2. The actual share of HUD cost in the owner's "low FPS even on start" symptom — UNVERIFIED.
   G17's loading/VRAM suspects (`:105-142`) may dominate; HUD work is speculative until measured.
3. `ImageTexture.update()` payload size on this Godot build and its GPU cost — INFERRED from
   `MAP_W×MAP_H×4` bytes; no driver measurement.
4. `blit_rect` vs `duplicate()` alpha behaviour for P12-E — UNVERIFIED (needs a check, §5.5).
5. 3D box invariance to camera transform + viewport size only (fov constant) — INFERRED from
   `camera3d.gd:175,179,195,296-305,397-404`; no runtime proof.
6. Donor parity of the minimap box/panels — not assessed; the AABB-vs-quad shape remains a
   PORT APPROXIMATION (`hud3d_adapter.gd:35-55`); no donor GPU A/B frame exists (CHARTER §3).
7. Current green gates (uitest 17/17, `t_hud_layout` PASS 62/0/3) are **on-disk artifacts read
   this session**, not re-runs by this agent; they establish the baseline P12 must preserve, not
   the result of any P12 change.

*End of P04 report.*
