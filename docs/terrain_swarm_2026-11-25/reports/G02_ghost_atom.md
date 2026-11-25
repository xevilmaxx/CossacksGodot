---
id: G02
ticket: "Author E04's decisive ghost-final-stage atom (NEW file only)"
swarm: TERRAIN-SWARM-WAVE-G
owner: G02 subagent
created: 2026-11-25
status: ATOM CREATED — NO GODOT RUN, NO RUNNER JOB, NO SHARED FILE EDIT
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
outputs:
  - variant3d/tests/t_ghost_final_stage.gd (NEW)
  - docs/terrain_swarm_2026-11-25/reports/G02_ghost_atom.md (this report)
---

# G02 — ghost FINAL-stage atom, authored from E04's proposal

## 0. Authority / scope statement

- Read before work: `docs/terrain_swarm_2026-11-25/CHARTER.md` and
  `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md`, plus
  `docs/terrain_swarm_2026-11-25/reports/E04_ghost_qa.md` (E04 §3.2 proposal).
- **Files created by this agent: exactly two** — the atom and this report. No
  existing file was edited; no backup was needed or created (CHARTER §3 backup
  rule applies to edits, and both outputs are new). No game code, config,
  fixture, manifest, gate or other test was touched (disjoint ownership).
- **No Godot process was started and no runner job was submitted.** Wave G
  standing rule: only G04 submits runner jobs. This report does not claim any
  runtime PASS; parse and runtime behaviour are **UNVERIFIED** until G04 runs it.
- Donor parity stays **UNVERIFIED**. Tint and footprint constants are port-side
  **PORT APPROX** (`world.gd:3509`, `data.gd:1303` "estimated"), no donor GPU A/B
  frame exists.

## 1. What landed

`variant3d/tests/t_ghost_final_stage.gd` implements E04 §3.2 essentially verbatim:
a `extends SceneTree` atom that boots real `main.tscn` windowed on the 64×64 3D
fixture, freezes `main`'s own screenshot saver, enters build-placement mode, and
runs 12 decisive checks plus 5 setup/capture guards. It writes only
`res://tests/results/t_ghost_final_stage.json` and two temp PNGs.

| # | Check | What it asserts | Provenance |
|---|---|---|---|
| 1 | `boot_real_64_3d_game` | real main boot, `render_mode=="3d"`, MAP 64×64, `fx`, `capture_view3d` | E04 |
| 2 | `build_mode_entered` | `hud.build_ghost_sid=="hou"`, peasant selected, gate affordable | E04 |
| 3 | `ghost_node_exists` | `BuildGhost3D` under `world.fx`, visible, primary ghost MeshInstance3D with mesh | E04 |
| 4 | `ghost_mesh_is_final_finished` | mesh **identity** equals `entities._mesh_info("hou","building").mesh` (finished base, B06's first choice); stage `"4"` retained as E04's second authoritative convention. Stage `"1"` is never accepted | E04, `expected_pre_fix_failure=true` |
| 5 | `no_foundation_mesh` | identity != `_stage_mesh_info("hou","1",false).mesh`; no suffix-1 meta child, no `Scaffold_*`, no stale `GhostBuildingStage0` name | E04, `expected_pre_fix_failure=true` |
| 6 | `ghost_alpha_and_tint_ok` | shared material `TRANSPARENCY_ALPHA`, `CULL_DISABLED`, `DEPTH_DRAW_DISABLED`, albedo RGB ≈ `GHOST_OK`, alpha 0.30–0.46 pulse band, emission RGB = albedo RGB, footprint shares the same material | E04 (regression guard) |
| 7 | `footprint_matches_donor_mask` | `Footprint` **visible**, BoxMesh `(1,0.05,1)`, scale `(2r,1,2r)`, `r = bld_rm(0,"hou") or def.radius` — the same radius `can_place()` uses | **E04 strict check preserved**, `expected_pre_fix_failure=true` |
| 8 | `png_during_placement` | real windowed GPU PNG from `main.capture_view3d`, non-black > 0.5, non-empty | E04 |
| 9 | `ghost_visible_in_pixels` | during vs post-cancel PNG differ by > 40 px in an 160 px box at ghost centre, majority green-dominant | E04 |
| 10 | `ghost_tint_blocked` | ghost on home town hall → `_sync_build_ghost` → `GHOST_BAD` RGB, alpha in band | E04 |
| 11 | `cleared_on_cancel` | synthetic right-click → `hud.build_ghost_sid==""` and ghost hidden / `_ghost_active != true` | E04 |
| 12 | `converted_to_construction_node_on_place` | synthetic left-click → new `hou` building, player 0, `finished=false`, `hp==def.hp*0.25`, real `Building_hou_<id>_STATIC_POSE` with `build_stage_suffix=="1"` and `Scaffold_hou_<id>` child; ghost cleared | E04 |

Guards also present: `picking3d_bound`, `final_art_available`,
`clear_site_selected`, `capture_image` (×2, during/after), `headless_guard`
(or `launch_args` on bad args).

### Check 7 is NOT weakened

`world3d_fx.gd:621-637` (OBSERVED) sets `_ghost_mesh.visible = false` whenever a
building mesh resolves, so the `Footprint` overlay is hidden in the landed B06
code. `footprint_matches_donor_mask` still requires `fp.visible == true` in the
same conjunction as `bm_ok` and `scale_ok`; it is marked
`expected_pre_fix_failure=true`, which only records provenance (precedent
`t_select_rect.gd:178-188`) and never changes `passed`. I did **not** re-scope it
to geometry-only, did not lower a threshold, and did not flip it. The result
JSON also carries `strict_check_7` documenting this decision.

## 2. G02 corrections to E04's proposal (all source-grounded)

These are correctness fixes so the atom tests what E04 intended; none lowers a
threshold or removes an assertion.

| Fix | OBSERVED evidence | Why |
|---|---|---|
| Spawn a finished `"cen"` town hall after the state reset | E04's `_configure` clears `entities`/`live_blds`/`grid`, so `_assert_blocked_tint`'s `buildings_of(0)` could never find a home → check 10 would fail for setup reasons, not ghost behaviour. `game.gd:2964-2969` shows `buildings_of` filters by `finished` and by `live_blds` | Home placed at map-centre + (24,24) m, outside the ±12 m clear-site scan; it is a real blocked-site fixture and is counted in `_n_bld0` |
| Use `buildings_of(0, false)` for `_n_bld0`, pre-place count, post-place count and blocked-site lookup | `game.gd:2964-2969` default `only_finished=true`; `place_building` spawns `finished=false` (`game.gd:4135-4139`). With the default, the new construction node is invisible to the count and check 12 can never pass | Counts now include unfinished buildings; check 12 remains unchanged |
| `_write_result` sets `_finished=true` and returns early if already finished | E04's `_write_result` had no such guard; stage 5 re-ran every frame until deferred `quit`, appending duplicate checks and rewriting the JSON | Single terminal write; `_process` stops on `_finished` |
| `_apply_ghost()` calls `fx._update_ghost()` after `_sync_build_ghost()` | `world3d_fx.gd:1491-1501` writes `albedo_color`/`emission` only inside `_update_ghost()`, on FX's own frame; `draw_ghost` only sets `_ghost_ok` (`world3d_fx.gd:580-604`). A synchronous probe could read the previous site's tint | Checks 6 and 10 measure the tint for the site just applied |
| `foot_mat.get_instance_id()` without `as Variant` cast | `foot_mat` is already a Variant holding `StandardMaterial3D`; guarded by `foot_mat != null` | Avoids an unnecessary/fragile Variant cast |
| Extra measured fields (`footprint_visible`, `footprint_scale_want`, `footprint_box_ok`, `ghost_building_name`, `home_id`) | — | Diagnostic evidence for COORD/G05; no assertion change |

## 3. Capture lifecycle (windowed only, COORD to run)

1. Launch windowed (no `--headless`) with `--config small_map_64.json`,
   `--screenshot <during>.png`, `--no-ghost-png <cancelled>.png`.
   `main.gd:233-248` skips the menu under `--screenshot`.
2. `_configure` freezes `main`'s saver (`screenshot_frames=1000000`,
   `screenshot_done=true`) because `main.gd:1849-1930` otherwise calls
   `_quit(0)` right after saving.
3. Build mode + clear site + `set_build_ghost_pos` + `_sync_build_ghost`, then
   assertions and `_capture_async(true)`: `UPDATE_ONCE`,
   `await RenderingServer.frame_post_draw`, `tex.get_image()`, `save_png()`.
   This is the same GPU seam as `main.gd:1864-1880`; no CPU fallback is used.
4. Check 10 at the home town hall, restore ghost to the clear site, synthetic
   right-click cancel, check 11, `_capture_async(false)` baseline PNG.
5. Re-arm build mode, synthetic left-click, check 12, write JSON, deferred quit.

## 4. Verdict semantics (unchanged from E04)

| Situation | `verdict` | `passed` | exit |
|---|---|---|---|
| All checks true, windowed PNG saved | `PASS` | true | 0 |
| Any evaluated check false (pre-fix expected for #4/#5/#7) | `FAIL` | false | 1 |
| Headless launch | `SKIPPED_HEADLESS` | `false` | 0 (deliberate skip, `SKIP_CAPTURE`) |
| Bad args / fixture / boot / setup | `ABORTED_*` | false | 0 |

The headless branch calls `check("headless_guard", false, ...)` and
`_write_result("SKIPPED_HEADLESS")`; `passed` is computed solely as
`(verdict == "PASS")`, so headless can never be reported as a pass. No PNG is
written on that path.

## 5. Runner command — for COORD only, NOT executed by G02

Check the queue first (`python variant3d\tools\godot_runner.py status`), refresh
the unique id if `e04-ghost-final` is already used, then one line from the
project root (PowerShell-safe, Windows `python`, no `&&`):

```
python variant3d\tools\godot_runner.py run --id e04-ghost-final --timeout 90 -- --path variant3d --script res://tests/t_ghost_final_stage.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\e04_ghost_during.png" --no-ghost-png "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\e04_ghost_cancelled.png"
```

Read-only verification after the run (no Godot):
`python variant3d\tools\smallmap_capture.py stats <during.png> <cancelled.png>`
and `... scan-stderr <runner-results>\<ticket>_e04-ghost-final\stderr.txt`.

## 6. Observed / derived / inferred / UNVERIFIED ledger

- **OBSERVED (direct source reads this session):** `world3d_fx.gd:580-604,
  621-694, 893-925, 1008-1019, 1491-1501, 1553-1558`; `world3d.gd:463-498,
  424-437, 784-786`; `world3d_entities.gd:1805-1811, 1819-1822, 1860-1914`;
  `game.gd:1822-1835, 2382-2426, 2964-2969, 3986-4058, 4092-4156`;
  `hud.gd:102, 1224-1241`; `input_controller.gd:22, 340-349, 821-849,
  943-944, 993-1004`; `main.gd:53-70, 124, 170, 1849-1930`;
  `camera3d.gd:52, 146-147, 444`; `data.gd:23, 1305-1330`;
  `t_select_rect.gd:178-188, 267-323, 378-379`.
- **DERIVED:** the atom itself is E04's design; the six G02 corrections in §2;
  the need for a finished home fixture; the single-write guard; forcing
  `_update_ghost()` for deterministic tint; treating `buildings_of(0,false)` as
  the only correct unfinished-building count.
- **INFERRED (to be confirmed by G04's run):** on the **landed B06** code,
  checks 4/5/6/9/10/11/12 and setup guards should pass, while check 7 stays RED
  because `world3d_fx.gd:632` hides the footprint. The pre-fix backup
  (`inbox/backup/world3d_fx.gd.bak-B06`) would additionally fail 4/5. These are
  expectations, not results.
- **UNVERIFIED / PORT APPROX:** donor ghost colour and mask radius (port
  constants, no donor GPU A/B), finished-art visual fidelity, stage art labels,
  and whether the two PNGs actually show a convincing finished hologram. The
  atom proves rendering and state, **not** donor parity.
- **NOT DONE by G02:** no Godot run, no runner job, no PNG, no result JSON, no
  parse check. Everything runtime-related above awaits G04.

## 7. Handoff

- COORD: run §5 under the one-Godot lock, inspect the two PNGs (translucent
  finished house during placement, green footprint if the fix has landed, no
  ghost after cancel), and keep check 7 RED as the honest record of the
  unresolved footprint-visibility requirement (`WAVE_G_CHARTER.md` B06 note and
  `E04_ghost_qa.md` §7 open question). Do not resolve it by weakening this atom.
- If a later owner makes the footprint visible alongside the finished mesh,
  check 7 should turn green without any edit; if the `Footprint` child is
  replaced by a donor-mask decal under another name, the integrating owner must
  update `_probe_ghost()`/check 7 — not delete it.
- End of G02 report.
