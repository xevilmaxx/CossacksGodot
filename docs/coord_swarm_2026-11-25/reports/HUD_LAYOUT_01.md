---
id: HUD-LAYOUT-01
title: "Responsive top-bar layout atom — authoring report (no runner, no PASS)"
owner: HUD-LAYOUT-01
date: 2026-11-25
status: AUTHORED__NO_GODOT_RUN__NO_PASS_CLAIM__NO_SHARED_CODE_EDIT
scope: "Two owned files only: variant3d/tests/t_hud_layout.gd and this report. No hud.gd/main.gd/manifest/config/fixture/result-JSON edit; no Godot process; no runner ticket."
owns:
  - "variant3d/tests/t_hud_layout.gd"
  - "docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_01.md"
labels: [RESPONSIVE_TOPBAR, THREE_VIEWPORTS, REAL_64_BOOT, SKIP_CAPTURE, DEFERRED_QUIT, NO_RUNNER]
matrix: "docs/coord_swarm_2026-11-25/PROGRESS.md:104-113"
---

# HUD-LAYOUT-01 — responsive top-bar layout atom (authoring only)

## Goal

Author a single-feature atom that verifies the owner's UX directive — "the bar must
never overflow and should adapt to viewport/resolution" plus "game speed should be
a dropdown" (`docs/coord_swarm_2026-11-25/PROGRESS.md:104-113`) — at three
viewports: **1024×576, 1280×720, 1920×1080**. It must run against the real 64²
3D game, check top-bar containment, six resource entries, one speed dropdown,
minimap placement/no-overlap and whole-HUD viewport containment, write
`res://tests/results/t_hud_layout.json`, mark captures `SKIP_CAPTURE` in headless
mode, and always quit via `call_deferred`. This agent did **not** run the atom;
no PASS is claimed.

## Sources

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/PROGRESS.md:104-113` | Owner directive and disjoint ownership: UI-TOPBAR-01 = `hud.gd`, LOAD-ASYNC-01 = `main.gd`, HUD-LAYOUT-01 = new atom. |
| `variant3d/scripts/hud.gd:17,112-114,273-275,301-326,390-457,480-500,505-512,590-601` | Working-tree top bar: full-width clipped `PanelContainer`, `res_icons`/`res_labels`, single `OptionButton` speed menu with metadata, `_layout_top()` responsive modes, resize hook. This is the current source of truth; its report has not landed. |
| `variant3d/scripts/hud.gd:283-299,327-353,1519-1596` | Minimap declared 240 slot, bottom-right anchors, `ui_us` scaling and bottom-strip partition. |
| `variant3d/scripts/data.gd:25-26,113-114` | Six resources (`food..coal`) and base 1280×720 window size. |
| `variant3d/scripts/config.gd:751-754` | `ui_scale_for(vp) = clamp(min(w/1280, h/720), 0.75, 2.5)` — why 1024 and 1920 scale UI differently. |
| `variant3d/scripts/main.gd:171-172,199-244,1110-1132,1125-1126,1307-1310,1699-1701,1818-1884` | User-arg parsing (both arg arrays), fixture boot skips menu, HUD bind, `--screenshot` hides HUD and has its own PNG saver/watchdog, blank-frame guard. |
| `variant3d/scripts/testbridge.gd:103-105` | `root.size = Vector2i(w,h)` resize precedent (mid-run resize otherwise unsafe). |
| `variant3d/tests/_template_test.gd:1-38` | `extends SceneTree`, result JSON, `call_deferred("quit", ...)` rule. |
| `variant3d/tests/t_smallmap_terrain.gd:9-16,42-111,174-231,234-247` | Real 64² boot through `main.tscn`, `--config` resolution, inspect on first `_process`, boot assertions. |
| `variant3d/tests/t_terrain_only.gd:175-246,648-679` | `check()` with JSON-null SKIP_CAPTURE rows, verdict fields, GPU readback and blank-frame guard pattern. |
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:79,98,110,183-189,220,269-280` | Runner launch form, real-boot facts, one-job-at-a-time, windowed-only PNG, headless CPU fallback cannot prove UI layout. |
| `docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md:45-60,62-73,237-240` | Capture integrity prerequisites, windowed + `stats` + `scan-stderr`, no threshold weakening. |
| `docs/coord_swarm_2026-11-25/reports/HUD_01_minimap.md:35,52-61,120` | Donor minimap 240×240 bottom-right; port keeps `ui_us` scaling; open question about abandoning 240 at wide viewports. |
| `inbox/backup/hud.gd.bak-UITOPBAR01:108,384-392,428-433` | Pre-UI-TOPBAR-01 baseline: `speed_buttons` array, `CenterContainer`, fixed offsets, four speed `Button`s. |
| `docs/coord_swarm_2026-11-25/reports/UI_TOPBAR_01.md` | **Not found at authoring time.** No report to cite; the working-tree `hud.gd` was used instead and all citations below point there. |

## Atom design

**Boot.** `extends SceneTree` (`_template_test.gd:1-4`). `_initialize()` resolves
`--config`, parses three `--png-*` user args, instantiates `res://scenes/main.tscn`
and adds it to `root`; checks start on the first `_process()` tick, after scene
`_ready()` has applied the fixture (`t_smallmap_terrain.gd:213-224`). Boot is
asserted as mode `3d`, 64×64, seed `20261113` (`t_smallmap_terrain.gd:235-247`;
`tests/fixtures/small_map_64.json:10-15`).

**Why real boot instead of a stub HUD.** A stub would avoid the ~15 s measured
64² startup (`TEST_01_smallmap_harness.md:149-153`), but it would have to
reconstruct `C3HUD.bind(game, world)`, config-driven `_mm_size/_mm_inset`, the
3D adapter and root `size_changed` wiring. That reconstruction is itself the
thing under test (the bar is sized from the *actual* viewport via
`hud.gd:232-234,273-275,505-518`); a stub could pass while the real scene
overflows. One boot plus three root resizes also holds map/seed/game state
constant, so per-size differences are attributable to layout only
(`TEST_01_smallmap_harness.md:11-12`). The atom clears `main.screenshot_path`
after boot so main's own saver/watchdog cannot quit mid-sweep
(`main.gd:1699-1701`), and re-shows `hud.visible = true` because
`--screenshot` hides it (`main.gd:1125-1126`; `TEST_01_smallmap_harness.md:220`).

**Sweep.** For each size: `root.size = want` (`testbridge.gd:103-105`) →
`await process_frame` → explicit `hud.call("_on_vp_resize")` (`hud.gd:273-275`,
covers headless where `size_changed` may not fire) → `await process_frame` →
structural checks → capture. A 600-frame watchdog and a `finish()` guard
prevent a hang; `quit` is always deferred (`_template_test.gd:3,38`).

**Capture.** Headless sets three `capture_*` rows to JSON `null` with status
`SKIP_CAPTURE`; `passed` is false and the verdict is `SKIP_CAPTURE`, never PASS
(`t_terrain_only.gd:192-218,243-246`; `CAPTURE_RECHECK.md:57`). Windowed mode
reads the root viewport texture after `await RenderingServer.frame_post_draw`
(`main.gd:1835`, `testbridge.gd:277-308`) and requires exact pixel dimensions,
a saved file and a non-blank frame; a blank texture is a hard FAIL with no CPU
fallback (`main.gd:1830-1832,1875-1882`; `CAPTURE_RECHECK.md:58-59`). Per-size
PNG paths are user args `--png-1024x576`, `--png-1280x720`, `--png-1920x1080`;
main ignores unknown flags (`main.gd:1226-1230`). Paths are included but **no
windowed job was run**, so capture quality is UNVERIFIED.

**Result.** `res://tests/results/t_hud_layout.json` with `id`, `passed`,
`verdict`, `structural_ok`, pass/fail/skip counts, all `checks`, per-size
`measured` geometry (top-panel rect, speed widget count/options, resource
label texts, minimap declared slot/scaled min/rendered px/panel rect,
unclipped offenders, clipped-overflow count, PNG metrics), config/fixture,
PNG arg list and the external `scan-stderr` note (`_template_test.gd:6,17-31`;
`TEST_01_smallmap_harness.md:92`; `CAPTURE_RECHECK.md:72`).

**Commands (documented, not executed; Windows `python`, FIFO runner only):**

```
python variant3d\tools\godot_runner.py run --id HUDLAYOUT01-headless --timeout 90 -- \
  --headless --path variant3d --script res://tests/t_hud_layout.gd -- \
  --config <ABS>\small_map_64.json --screenshot <TEMP>\hud_layout_unused.png

python variant3d\tools\godot_runner.py run --id HUDLAYOUT01-windowed --timeout 90 -- \
  --path variant3d --script res://tests/t_hud_layout.gd -- \
  --config <ABS>\small_map_64.json --screenshot <TEMP>\hud_layout_unused.png \
  --png-1024x576 <TEMP>\hud_1024x576.png \
  --png-1280x720 <TEMP>\hud_1280x720.png \
  --png-1920x1080 <TEMP>\hud_1920x1080.png
```

Registration in `manifest.json`, `test_all.py` root fixes and any result-JSON
harvest are integration tickets, deliberately untouched here
(`TEST_01_smallmap_harness.md:261-266`).

## Assertion table

Every check name below is suffixed with the size tag (`_1024x576`,
`_1280x720`, `_1920x1080`) unless marked "once".

| Check | Predicate | Source | Pre-fix baseline (HEAD) |
|---|---|---|---|
| `real_64_boot`, `hud_bound` (once) | main boots `3d`, Data 64×64, seed 20261113, `main.game` and `main.hud` bound | `t_smallmap_terrain.gd:234-247`; `main.gd:1110-1112`; `small_map_64.json:10-15` | pass (shared harness) |
| `viewport`, `hud_scale_viewport`, `resize_hook` | `root.size == want`, `hud.ui_vp == want`, `_on_vp_resize` exists | `testbridge.gd:103-105`; `hud.gd:232-234,273-275`; `config.gd:751-754` | pass if headless window resize works; **UNVERIFIED** (not run) |
| `top_panel_present` | `hud.top_panel` is a live `Control` | `hud.gd:17,398-403` | pass |
| `top_panel_right_in_viewport` | `top_panel` global rect `x >= -2` and `right <= vp.width + 2` | `PROGRESS.md:105-108`; `hud.gd:319-326,554-557` | **expected FAIL at 1024/1280** — `CenterContainer` + content-driven size (`bak:384-392`) can spill; post-fix full-width anchors (`hud.gd:399-400,556-557`) bound it |
| `top_panel_clip` | `top_panel.clip_contents == true` | `hud.gd:402`; `bak:392` | pass in both baseline and current tree |
| `six_resource_entries` | 6 non-empty `res_labels` + 6 distinct `TextureRect` hints from `RES_TOOLTIPS` | `hud.gd:124-130,407-418`; `data.gd:25-26` | pass (preserved by UI-TOPBAR-01) |
| `single_speed_widget` | exactly one `OptionButton`/`MenuButton` in the top-panel subtree; zero legacy speed Buttons | `hud.gd:112,439-447,490-500`; `main.gd:1114-1120`; `bak:108,428-433` | **expected FAIL at all 3 sizes** — baseline has four speed `Button`s (`bak:428-433`) |
| `speed_options`, `speed_option_metadata` | item texts exactly `["II","1x","2x","4x"]`; metadata exactly `[0,1,2,4]` seconds | `hud.gd:444,495-498,590-601` | **expected FAIL at all 3 sizes** (no dropdown baseline) |
| `minimap_nodes_present` | `minimap_rect`/`minimap_panel` live | `hud.gd:48-49,1555-1595` | pass |
| `minimap_declared_240` | `_mm_size() == 240` and `uimw/uimh == 240` | `hud.gd:283-287,1560-1563`; `HUD_01_minimap.md:35,52-61` | pass (240 default, fixture has no override) |
| `minimap_square` | rendered minimap rect width ≈ height (±2 px) | `hud.gd:327-333` | pass expected |
| `minimap_bottom_right` | panel anchors all `1.0`, rect centre in bottom-right quadrant, rect within viewport | `hud.gd:1579-1595`; `HUD_01_minimap.md:54-56` | pass expected |
| `minimap_no_topbar_overlap` | minimap panel rect does not intersect `top_panel` rect | `hud.gd:319-321,327-350` | pass expected |
| `no_unclipped_control_outside_viewport` | every visible root-viewport `Control` rect is inside the viewport, except children visually clipped by a clipping ancestor | `PROGRESS.md:105-108`; `hud.gd:402,554-557` | **expected FAIL at narrow sizes** where the old bar spills; clipped children are recorded separately |
| `clipped_overflow_children` | recorded JSON-null diagnostic (count only), not a gate | `hud.gd:402`; P0_GATE-01 precedent cited in `CAPTURE_RECHECK.md:239` | N/A (recorded) |
| `capture_image`, `capture_saved`, `capture_nonblank` | windowed: root texture exact size, PNG saved, non-black fraction > 0; headless: `SKIP_CAPTURE` null rows | `main.gd:1830-1832,1875-1882`; `CAPTURE_RECHECK.md:57-60`; `t_terrain_only.gd:648-679` | headless SKIP_CAPTURE by design; windowed **UNVERIFIED** (no run) |

`EPS = 2.0` px is float/container rounding slack only; it does not relax a
real overflow. Clipped descendants of `top_panel` are excluded from the
viewport-containment gate because `clip_contents = true`
(`hud.gd:402`) is the intended containment mechanism; their count is recorded
in JSON so nothing is discarded (`CAPTURE_RECHECK.md:236-240`, no weakening).

## Expected pre-fix failures

"Pre-fix" means the HEAD/baseline `hud.gd` preserved at
`inbox/backup/hud.gd.bak-UITOPBAR01:108,384-392,428-433`, not the current
uncommitted working tree, which already contains UI-TOPBAR-01's implementation.

1. `single_speed_widget`, `speed_options`, `speed_option_metadata`,
   `no_legacy_speed_buttons` at all three sizes: baseline builds four speed
   `Button`s appended to `speed_buttons` (`bak:428-433`); the requirement is one
   dropdown (`PROGRESS.md:105-107`; current `hud.gd:439-447,490-500`).
2. `top_panel_right_in_viewport` at 1024×576 and plausibly 1280×720: baseline
   uses a `CenterContainer` whose child is sized by content
   (`bak:384-392`), matching the owner's overflow report
   (`PROGRESS.md:105-106`). The current tree uses viewport-driven anchors
   (`hud.gd:399-400,554-557`), which this atom will verify rather than assume.
3. `no_unclipped_control_outside_viewport` at the same sizes, for the same
   spill (the old panel is not viewport-bounded).
4. Capture rows: headless is `SKIP_CAPTURE`, not a failure and not a PASS.
   Windowed root-texture readback is UNVERIFIED until a runner job exists;
   `main.gd:1830-1832` warns the root backbuffer can read blank under
   `gl_compatibility`, in which case this atom deliberately fails loudly rather
   than substituting a CPU frame.

No threshold was lowered and no assertion was deleted to accommodate the
baseline. The one recorded-only row (`clipped_overflow_children`) mirrors the
P0_GATE-01 precedent: keep the old value visible, gate on an applicable strict
predicate (`CAPTURE_RECHECK.md:237-240`).

## OUT_OF_SCOPE

| Item | Reason |
|---|---|
| Literal *rendered* 240×240 px at all three sizes | `hud.gd:327-333` scales the slot by `ui_us` (192 px at 1024×576, 360 px at 1920×1080), and `HUD_01_minimap.md:52-61,120` records that scaling as an intentional port adaptation with the "when to abandon 240" question still open. Hard-asserting rendered pixels would contradict documented behavior and is not the top-bar concern owned here. The atom instead hard-asserts the declared 240 slot, bottom-right placement, squareness and non-overlap, and records actual rendered px per size. |
| Loading overlay / async readiness | Owned by LOAD-ASYNC-01 (`main.gd`), explicitly disjoint (`PROGRESS.md:110-112`). |
| Any `hud.gd`, `main.gd`, `manifest.json`, config, fixture or result-JSON edit | Exclusive outputs are the atom and this report; integration tickets are listed in `TEST_01_smallmap_harness.md:261-266`. |
| Donor GPU A/B visual parity | No donor frame exists; `CAPTURE_RECHECK.md:35,237` and `TEST_01_smallmap_harness.md:294-296`. All layout results are PORT APPROX / internal consistency only. |
| Manifest registration and runner execution | Integration/COORD work; this worker must not submit a Godot job (`PROGRESS.md:113`; `TEST_01_smallmap_harness.md:70-86`). |

## Open questions

1. `reports/UI_TOPBAR_01.md` had not landed when this was authored. Its
   implementation is present as uncommitted edits to `hud.gd`. Re-read the
   report when it lands and confirm the speed option labels/metadata and
   responsive modes still match the cited lines; do not edit the atom to make
   it green if they change — raise an integration ticket.
2. Does `root.size` update the root viewport's `get_visible_rect().size` in
   `--headless`? The atom asserts both `viewport` and `hud_scale_viewport` and
   calls `_on_vp_resize()` explicitly, so a mismatch fails loudly instead of
   silently testing the wrong size. Only a runner can settle this.
3. Is the root window texture readable in windowed `gl_compatibility` mode?
   `main.gd:1830-1832` says it may be blank, which is why main uses a
   `SubViewport` for 3D. If blank, the atom fails the capture rows; the correct
   follow-up is a dedicated HUD-capture ticket, **not** a CPU fallback or a
   relaxed assertion.
4. Should the minimap stay at the scaled 192/360 px rendered sizes, or become
   literal 240 px at every size? `HUD_01_minimap.md:120` leaves this open; it is
   deliberately OUT_OF_SCOPE here.
5. Who registers `t_hud_layout` in `manifest.json` and performs the mandatory
   second-agent capture re-check (`CAPTURE_RECHECK.md:249`)? COORD only.

## No-runner declaration

No Godot process was launched, no `godot_runner.py` ticket was created, no PNG
was captured, no result JSON was read or written by this agent, and no atom was
executed. No gate, ladder row, manifest, config, fixture, `hud.gd` or `main.gd`
was changed. Only the two owned files were created/edited. Therefore **no PASS
is claimed** for the atom, for UI-TOPBAR-01 or for LOAD-ASYNC-01. The result JSON
path above will exist only when someone else runs the atom. Stderr must still
be scanned externally with `python variant3d\tools\smallmap_capture.py
scan-stderr <runner stderr>` (`CAPTURE_RECHECK.md:72`).

## Summary

- Authored one `extends SceneTree` atom that boots the real 64² 3D scene once
  and sweeps 1024×576, 1280×720 and 1920×1080, with strict, individually
  cited checks for top-bar containment and clipping, six resource entries, one
  speed dropdown with the donor speed set, minimap 240 slot/bottom-right/
  square/no-overlap, and whole-HUD viewport containment.
- Result JSON is `res://tests/results/t_hud_layout.json`, with JSON-null
  `SKIP_CAPTURE` rows in headless mode, windowed per-size PNG user args, a
  loud blank-frame guard and an always-deferred quit.
- Expected baseline failures are the four speed-widget checks and (at narrow
  widths) top-bar overflow checks; neither was weakened. The literal rendered
  240 px minimap assertion is explicitly OUT_OF_SCOPE with its documented
  reason and is replaced by a declared-slot + placement + squareness + overlap
  gate with rendered pixels recorded.
- Authoring only: no runner, no capture, no PASS claim, no shared-code edit.
