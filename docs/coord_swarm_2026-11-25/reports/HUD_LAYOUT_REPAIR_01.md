---
id: HUD-LAYOUT-REPAIR-01
title: "HUD-LAYOUT-REPAIR-01 — atom repair of the three stale tooltip literals and the three-size viewport sweep"
area: coord_swarm_2026-11-25
task_id: HUD-LAYOUT-REPAIR-01
date: 2026-11-25
owner: test-atom repair builder (exclusive ownership: atom + this report)
status: EXECUTED_ONCE__BOTH_ATOM_DEFECTS_REPAIRED__ATOM_STILL_FAIL__REAL_TOPBAR_OVERFLOW_AND_CAPTURE_METRIC_UNITS_REMAIN
scope: "variant3d/tests/t_hud_layout.gd + this report only; NO hud.gd / other atoms / config / result JSON hand edit"
labels: [ATOM_REPAIR, WINDOWED_RUNNER_JOB, THREE_SIZES_EXERCISED, NO_ASSERTION_WEAKENED, REAL_TOPBAR_OVERFLOW, CAPTURE_METRIC_UNITS_BUG, NO_SOURCE_EDIT]
evidence_in: "docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_RUN_01.md (job hudlayoutrun01-atom, ticket 530, FAIL 42/11/12, SCRIPT ERROR 0)"
backup: "inbox/backup/t_hud_layout.gd.bak-HUDLAYOUTREPAIR (SHA-256 verified before edit)"
runner_job: "hudlayoutrepair01-run / ticket 548 / windowed"
game_code_edited: false
---

# HUD-LAYOUT-REPAIR-01 — report

## 0. Scope and ownership

Edited exactly one code file, `variant3d/tests/t_hud_layout.gd`, plus this report. Created one backup. **No other file was edited by this worker** — no `hud.gd`, no other atom, no config/manifest/queue state, no result JSON by hand. The result JSON named below was written by the atom itself during the runner job.

Backup taken **before** the first edit: `inbox/backup/t_hud_layout.gd.bak-HUDLAYOUTREPAIR`.
SHA-256 backup = original = `3CC88281B9D5AC23837B04ED719EFB04178709C6C885A02A55FA336C46303E4B`; SHA-256 after this worker's repair = `0E38F277F90E6A53FA0A5EAFC12F75FD3FBA6B3502DE4F7D13DD16F2AD064527`.

**Concurrent edit by another worker:** after job 548 finished (result JSON written 12:48:43), a separate `HUD-CAPTURE-FIX-01` change landed in the same atom at 12:56:56 (`_image_metrics` channel scaling, saved-PNG readback and a three-gate nonblank guard, currently `:533-535`, `:607-625`). It is **not** this worker's edit and was **not** exercised by the job recorded below. This report describes the state the job actually ran.

## 1. Before → after: the three tooltip literals

The atom collected `TextureRect.tooltip_text` set at `hud.gd:413`; its hardcoded expected strings had drifted from the current donor-cited `RES_TOOLTIPS` at `hud.gd:128-130`. `hud.gd` was **not** changed; only the atom's literals were aligned to it (`t_hud_layout.gd:64-73`, citation comment added for `:128-130`).

| # | Before (atom) | After (atom) | Canonical source |
|---|---|---|---|
| 1 | `Gold is produced by gold mines which can be placed over gold deposits. ...` | `Gold is produced **at** gold mines which can be placed over gold deposits. ...` | `variant3d/scripts/hud.gd:128` |
| 2 | `Iron is produced by iron mines. ...` | `Iron is produced **at** iron mines. ...` | `variant3d/scripts/hud.gd:129` |
| 3 | `Coal is produced by coal mines. ...` | `Coal is produced **at** coal mines. ...` | `variant3d/scripts/hud.gd:130` |

The other three literals (food/wood/stone) were already exact matches and are untouched. All six `six_resource_entries_*` checks now PASS at all three sizes (`icons_with_hint=6`, previously 3).

## 2. Before → after: three-size viewport mechanism

**Before:** only `root.size = want` (`testbridge.gd:103-105`) followed by `hud._on_vp_resize()`. `root.size` read back as the wanted size, but `hud.ui_vp` stayed `(1280,720)` for all three sizes, so the sweep measured one layout three times.

**Root cause (sharper than the prior report):** `variant3d/project.godot:18-19` sets `window/stretch/mode="canvas_items"` with aspect `expand` and a **1280×720 base**. `get_viewport().get_visible_rect().size` — which `hud._calc_us()` reads at `hud.gd:234-239` — is the *logical* size, so it stays 1280×720 for every 16:9 window size. This is not purely a headless limitation: a plain windowed resize would hit the same stretch base.

**After (TEST-ONLY harness setup, clearly labelled in the atom at `:260-269`, assignments at `:270-291`):**

```
if not _headless and DisplayServer.get_name() != "headless":
    DisplayServer.window_set_size(want)   # real window, real root texture for capture
root.size = want                          # testbridge.gd:103-105 (window/root property)
root.content_scale_size = want            # TEST-ONLY retarget of the logical viewport base
await process_frame
await process_frame
hud.call("_on_vp_resize")                 # hud.gd:273-275
await process_frame
...
root.size = original_size
root.content_scale_size = original_scale  # restore
```

- Windowed runs resize the real `DisplayServer` window, so the physical root texture matches `want` and the capture path is genuinely evaluated.
- The `content_scale_size` override is a **harness-only** retarget of the stretch base (not an override of `hud.ui_vp`, and not a game-code edit): the HUD still derives `ui_vp` itself from its viewport via `hud.gd:234-239`. Unlike a bare `hud.ui_vp` assignment, this also makes the HUD's anchored Controls lay out at the wanted size, so the containment/minimap/top-panel assertions measure three real layouts.
- Headless is still detected and still uses `SKIP_CAPTURE`; no PNG claim is fabricated.
- No assertion was relaxed, deleted, reordered or replaced by this worker. Compared with the backup, all 29 `check(...)` lines were byte-identical after this worker's repair. No expected-PASS was hardcoded.
- The later concurrent `HUD-CAPTURE-FIX-01` edit is outside this ticket; a current-file comparison now shows 30 check lines, the extra one being that other worker's nonblank guard.

## 3. Validation — ONE runner job

```bat
python variant3d\tools\godot_runner.py run --id hudlayoutrepair01-run --timeout 300 --max-wait 3600 -- --path variant3d --script res://tests/t_hud_layout.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\hudlayoutrepair\hud_layout_unused.png" --png-1024x576 "...\hud_1024x576.png" --png-1280x720 "...\hud_1280x720.png" --png-1920x1080 "...\hud_1920x1080.png"
```

| Field | Value |
|---|---|
| Runner | `variant3d/tools/godot_runner.py run` (variant FIFO, no direct `godot`) |
| Job id / ticket | **`hudlayoutrepair01-run` / 548** (fresh, unique) |
| Mode | **windowed** (`--path variant3d --script ...`, no `--headless`); GPU `gl_compatibility`, 1920×1080 desktop |
| `--timeout` / `--max-wait` | 300 s / 3600 s |
| Queue wait / run | 303.29 s / 82.86 s |
| Runner status / exit | **`failed` / exit 1** — the atom's own deferred `quit(0 if _ok else 1)`; completed normally, no timeout, no lock loss, no skip |
| Output dir | `variant3d/.godot_queue/results/00000548_hudlayoutrepair01-run/` |
| Runner record | `variant3d/.godot_queue/results/00000548.json` |
| Result JSON (atom-written) | `variant3d/tests/results/t_hud_layout.json` |
| Verdict | **FAIL** (`passed=false`, `structural_ok=false`) |
| Pass / fail / skip | **55 / 7 / 3** (`55/62 evaluated, 3 skipped`) |
| Capture | windowed: 6 capture PASS + 3 `capture_nonblank_*` FAIL; `capture_status=PASS`, `headless=false` |
| Skips | 3 × `RECORDED_NOT_GATE` (`clipped_overflow_children_*`); no `SKIP_CAPTURE` in this windowed run |
| Fixture / parity | `64x64`, seed `20261113`; `PORT APPROX — internal layout consistency only, visual UNVERIFIED as gate` |

**`SCRIPT ERROR`: 0.** `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000548_hudlayoutrepair01-run\stderr.txt` → `[{"exists": true, "script_error_lines": 0, "lines": []}]`. Only warnings / exit-time diagnostics, as before; none attributed to this atom without a focused investigation.

### 3.1 Effect of the repair (before → after)

| Category | Before (job 530, headless) | After (job 548, windowed) |
|---|---|---|
| `six_resource_entries_*` | 3 FAIL (`icons_with_hint=3`) | **3 PASS** (`icons_with_hint=6`) |
| `hud_scale_viewport_*` | FAIL at 1024/1920; `ui_vp=(1280,720)` ×3 | **PASS ×3**; `ui_vp=(1024,576)/(1280,720)/(1920,1080)` — three real layouts |
| `minimap_bottom_right_*` | FAIL at 1024/1920 | **PASS ×3** |
| `top_panel_right_in_viewport_*` | FAIL at 1024/1280 | FAIL at 1024/1280 (same geometry — now attributable to a real overflow, see 3.2) |
| `no_unclipped_control_outside_viewport_*` | FAIL at 1024/1280 | FAIL at 1024/1280 (same, real) |
| `capture_*` | 9 × `SKIP_CAPTURE` | 6 PASS + 3 FAIL (see 3.3) |
| Totals | 42 / 11 / 12 | **55 / 7 / 3** |

R2 (single speed dropdown) remains verified at all three sizes; all speed, minimap-slot, square, clip and boot checks PASS.

### 3.2 The 4 remaining layout FAILs are real, not false

At 1024×576 `top_panel` is `x=[6.4,1126.4]` (1120 px wide) against a 1024 viewport; at 1280×720 it is `x=[8,1298]` against 1280. The bottom-right minimap, by contrast, is correctly inset at every size (`right=vp-6.4/8/12`), proving the viewport itself is correct. The three unclipped offenders at 1024/1280 are the `top_panel`, its `HBoxContainer` and a trailing `Label` — all the same top-bar row. The saved PNGs (`hud_1024x576.png`, `hud_1280x720.png`) visibly show the resource/settings row running off the right edge. Most likely cause: `top_center`'s combined minimum size (`~1128/1306/1932` px scaled) exceeds the viewport; `top_panel.clip_contents` clips painting but does not shrink the control rect. **Not fixed here** — `hud.gd` belongs to UI-TOPBAR-01 and the assertion is deliberately left strict.

### 3.3 The 3 `capture_nonblank_*` FAILs are a separate atom defect, not fixed here

All three PNGs exist, have the exact wanted dimensions, and are visibly nonblank (saved sizes 79 804 / 101 646 / 171 689 bytes; the 1280×720 image clearly shows the top bar, selection panel and minimap). Yet `non_black_fraction=0.0000`, `mean_luma≈0.12`. Cause: `t_hud_layout.gd:_image_metrics` computes luma from `Color` floats (`0..1`) and tests `if l > 8.0` (`:536-542`) — impossible for a 0..1 value. The established atom pattern scales to 0..255 first (`t_combo_shore_mines.gd:467-470`) before the same `> 8.0` test. This guard was never exercised in headless (`SKIP_CAPTURE`). Left **unchanged** because this ticket's edit scope is limited to (a) literals and (b) resize mechanism; see open question 3.

## 4. No-weakening statement

- No containment, top-panel, minimap or speed assertion was deleted, relaxed, reordered or made conditional. `top_panel_right_in_viewport_*`, `no_unclipped_control_outside_viewport_*`, `minimap_bottom_right_*`, `minimap_square_*`, `minimap_declared_240_*` and `six_resource_entries_*` are byte-identical to the backup.
- The only assertion-adjacent change is that the three expected tooltip strings now match the live donor-cited `hud.gd:128-130` text — a corpus fix, not a threshold change.
- No expected PASS is hardcoded; the atom still writes `passed=false` / `verdict=FAIL` whenever any check is false, and still exits 1 in that case (it did).
- The `content_scale_size` assignment is additive harness setup labelled TEST-ONLY in comments; it makes the assertions test three genuine layouts instead of one. It does not edit game code or invent measurements.
- The reported FAIL is recorded, not "fixed" by changing an assertion.

## 5. Open questions

1. **Top-bar min-size overflow (real).** Should UI-TOPBAR-01 cap `top_center`/`top_bar` minimum width or make `top_panel` shrink below its content min size so the row is contained at 1024/1280? Owner: `hud.gd`, outside this ticket. The atom is currently the only strict detector.
2. **Resize mechanism canonical form.** Is a test-only `content_scale_size` retarget acceptable to COORD design, or should the atom switch the project to `content_scale_mode=DISABLED` for the sweep (a different harness setup with the same goal)? Current form passed all three `hud_scale_viewport_*` checks.
3. **Capture guard units — now being handled elsewhere.** The three `capture_nonblank_*` FAILs in job 548 came from the old `l > 8.0` test on 0..1 floats (backup `:522`; same pattern as `t_combo_shore_mines.gd:467-470`, which scales to 0..255). No such edit was made in this ticket, but the concurrent `HUD-CAPTURE-FIX-01` change after the job addresses it. One further windowed job would be needed to verify that change; none was run here (single-job scope).
4. **Visual gate.** The saved PNGs are visibly nonblank, but the atom still claims only `PORT APPROX — internal layout consistency`; no visual PASS is made here.
5. **Exit diagnostics.** Whether the exit-time resource/RID messages in stderr are pre-existing remains unattributed, as in the prior report.

## 6. Summary

- Backed up the atom to `inbox/backup/t_hud_layout.gd.bak-HUDLAYOUTREPAIR` before any edit (SHA-256 matched).
- Repaired both atom-side false failures: the three "produced by → produced at" tooltip literals now match `hud.gd:128-130`, and the sweep now retargets the root viewport's `content_scale_size` (plus a real `DisplayServer.window_set_size` in windowed mode) so `hud.ui_vp` actually takes the three wanted values.
- Ran exactly one windowed variant-runner job, `hudlayoutrepair01-run` / ticket 548, timeout 300, max-wait 3600: 55 passes / 7 fails / 3 skips, verdict FAIL, exit 1, `SCRIPT ERROR 0`.
- The two original false-failure families are cleared (3 tooltip checks and the resize/viewport/minimap cascade). Four strict layout FAILs remain and are **real top-bar overflow** at 1024/1280, not weakened or suppressed; three additional `capture_nonblank_*` FAILs are a pre-existing 0..1-vs-0..255 metric bug exposed by the windowed path and left out of scope. A later concurrent `HUD-CAPTURE-FIX-01` edit targets that bug but was not validated by this ticket.
- No source, config, other atom, queue state or result JSON was edited by hand by this worker; no retry, no full gate or ladder.
