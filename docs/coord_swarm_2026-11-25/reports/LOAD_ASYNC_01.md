# LOAD-ASYNC-01 — non-blocking load / usable-when-overlay-hides

Owner: LOAD-ASYNC-01 implementation builder. Date: 2026-11-25.
Scope: `variant3d/scripts/main.gd` + this report only. Root:
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.

## 1. Blocking-call inventory (code observation, `path:line` in final file)

All line numbers below are from the edited `main.gd` unless prefixed otherwise.

### 1.1 Stages that already yielded before the change
`_do_async_load` (`main.gd:535`) already awaited two process frames between
each sim stage via `_loading_tick` (`main.gd:526-533`; two `process_frame`
awaits at `:531-532`). The stage calls themselves remained single synchronous
blocks:

| Call | Site | What it does |
|---|---|---|
| `game.setup_begin(start_mode)` | `main.gd:563` | resizes 4 full-map arrays, `nav.configure` (`game.gd:355-412`) |
| `game._gen_base()` | `main.gd:566` | `C3MapGen.build` (`game.gd:1007`), `C3PatternGen.build` (`game.gd:1078`), several full-grid passes (`game.gd:1050-1064`, `:1087-1097`, `:1101-1122`) |
| `game._gen_forests()` | `main.gd:569` | per-start painting/scatter (`game.gd:1145-1162`) |
| `game._gen_resources()` | `main.gd:572` | richness ores + near-start clusters (`game.gd:1164-1178`) |
| `game._gen_finish()` | `main.gd:575` | keep-clear + purity passes (`game.gd:1362-1407`) |
| `game._assign_tileblocks()` | `main.gd:578` | donor tile smoothing (`game.gd:1800`) |
| `game.setup_spawns()` | `main.gd:581` | slots, ore, spawn, grid rebuild, reach repair (`game.gd:414-423`) |

### 1.2 The un-sliced block — primary freeze evidence
Before the change, only ONE `_loading_tick` separated world construction from
the end of the loader. From `"Building interface..."` through `_hide_loading()`
(~55 lines) there was **no yield at all**. Every call below ran in a single
frame with the OS message pump unable to pump repaint/move events:

| Call | Site | Notes |
|---|---|---|
| `world.bind(game)` / `add_child(world)` | `main.gd:588-593` | 3D: `make_world3d()` → `bind` → full-grid terrain mesh + entity seed (`world3d.gd:599`, `terrain.build()` at `:639`, `_reconcile_entities()` at `:642`) |
| `camera.bind(...)`, zoom/focus | `main.gd:596-619` | 3D `apply_external_target` (`main.gd:613`) |
| `hud.bind(game, world)`, refresh | `main.gd:622-636` | HUD/minimap construction |
| `input_ctl.bind(...)`, `_apply_3d_hooks` | `main.gd:639-646` | picking + minimap 3D wiring (`main.gd:1070-1073`) |
| `_create_ai_brains`, `audio.start_music` | `main.gd:647-655` | AI construction, audio resource start |
| `_hide_loading()` | old `main.gd:645` | overlay removed at the tail of that same block |

`_setup_full_game` (`main.gd:1077`) and `_process` (`main.gd:1587`) are the
non-interactive/boot paths. `_process` runs sim ticks (`main.gd:1625`) and
`world.sync(dt)` (`main.gd:1671`) every frame once `ais` is non-empty
(`main.gd:1603-1604`); it contains per-frame budget guards (`main.gd:1623`,
`:1633`) and no blocking sleeps. No `OS.delay` or blocking sleep exists on the
main thread in this file (grep: none).

### 1.3 Post-overlay work
Code inspection: in the old flow `_create_ai_brains` ran before the final
two-frame `_loading_tick`, so the first `_process` sim tick and `world.sync`
were already behind the overlay. There is no labelled deferred stage in
`main.gd`. Any genuinely asynchronous asset/FX work that continues after the
overlay is owned by the composed world/HUD modules (`world3d*.gd`, `hud.gd`),
which are outside this ticket's ownership — see Open questions.

## 2. Backup

`inbox/backup/main.gd.bak-LOADASYNC01` — byte copy of `main.gd` before edits
(83,697 bytes, created before any change). Verified present.

## 3. Before → after (all in `main.gd`)

1. `var load_ready := false` added at `main.gd:157`; reset on every overlay
   open at `:464`; set true only at `:675`, immediately before `_hide_loading()`
   at `:676`.
2. The old single `"Building interface..."` tick at old `:586` is split into
   four labelled, frame-yielding slices (`_loading_tick` = 2 `process_frame`
   awaits each):
   - `:594` `0.92 "Wiring camera..."` — after world/terrain/entity build
   - `:620` `0.94 "Building interface..."` — after camera bind + focus
   - `:637` `0.96 "Wiring input..."` — after HUD bind/refresh
   - `:648` `0.98 "Starting audio..."` — after input bind, 3D hooks,
     initial selection and AI brains
   - `:664` `1.00 "Ready!"` — after audio/objectives
3. Presentation-only warm-up `world.sync(0.0)` at `:660-662` behind the
   overlay; `dt=0` advances no sim time and no animation phase.
4. Overlay is held for one `await RenderingServer.frame_post_draw` (`:668`)
   after the last stage, then `load_ready = true` (`:675`) and hide (`:676`).

**Not changed:** sim logic, mapgen call order/contents, determinism, any test
hook, any deferred/cancellation behaviour, `_show_loading`/`_hide_loading`
internals beyond the flag reset, or the headless/screenshot setup path. Every
original stage call is still present and in the original order; only yields
and the readiness gate were added. No stage was skipped silently. No
`WorkerThreadPool` task was introduced: `C3MapGen.build` calls
`ResourceLoader.load` (`mapgen.gd:141`) and `C3PatternGen.build` is a resource/
pattern producer, so the data stages are **not safely isolated** for a worker
thread without a broader redesign (see Separate ticket).

## 4. Validation jobs (variant runner only; FIFO waits normal; no re-submit,
   no queue mutation, no direct `godot`)

| Job id | Ticket | Command | Result |
|---|---|---|---|
| `loadasync01-smoke` | 514 | `--headless --path variant3d --check-only --script res://scripts/main.gd` | runner `status=ok`, `exit=0`, wait 56.83 s, run 8.72 s — **BUT stderr contained a foreign parse error**: `SCRIPT ERROR: Parse Error: Identifier "slot" not declared ... res://scripts/selftest.gd:153` followed by `Failed to compile depended scripts` and `Failed to load script res://scripts/main.gd`. `selftest.gd` is not owned by this ticket and was being edited concurrently; it was observed fixed later the same minute. Exit 0 therefore does **not** prove `main.gd` parsed at that instant. |
| `loadasync01-windowed-boot` | 517 | `--path variant3d -- --screenshot variant3d/shots/loadasync01_boot.png --timeout 60` | runner `status=failed`, `exit=1`, wait 359.70 s, run 13.84 s. stdout shows Godot 4.7.2 + OpenGL/NVIDIA init; stderr empty; no screenshot file written. Cause UNKNOWN. This path uses `_setup_full_game()` (`main.gd:1077`, dispatched at `:231`), **not** `_do_async_load`, so it does not exercise the edited loader. The ~14 s GL boot is consistent with `main.gd` having loaded, but is not a proof of async-path correctness. |

Artifacts: `variant3d/.godot_queue/results/00000514.json`,
`.../00000514_loadasync01-smoke/{stdout,stderr}.txt`,
`00000517.json`, `.../00000517_loadasync01-windowed-boot/{stdout,stderr}.txt`.
A second syntax job was **not** submitted (no re-submit per task order).

## 5. "Usable when overlay hides" — evidence status

**Code-level: established.** `_hide_loading()` (`main.gd:676`) is reachable
only after: sim/spawn stages (`:563-581`), world+terrain+entity bind
(`:586-593`), camera bind/focus (`:596-619`), HUD bind/refresh (`:622-636`),
input bind + 3D hooks + selection + AI (`:639-647`), audio/objectives
(`:650-656`), warm sync (`:660-662`), 100% tick (`:664`) and one drawn frame
(`:668`); `load_ready` is set at `:675` on that same path. No labelled
deferred work remains in this loader.

**Runtime: UNVERIFIED.** Neither job exercised the interactive Start-click
async path; the windowed probe failed without a screenshot and without a
captured error. Window movability during the remaining single-block stages is
also UNVERIFIED — see Separate ticket. No visual-parity claim is made.

## 6. What remains deferred / separate ticket

- **SEPARATE TICKET (not faked):** individual stage bodies remain synchronous:
  `game._gen_base()` (`game.gd:983`) contains full-grid loops and two
  `ResourceLoader`-backed builders (`game.gd:1007`, `:1078`;
  `mapgen.gd:141`); `world.bind()` (`world3d.gd:599`) builds the full terrain
  mesh in one call (`:639`) and seeds all entities (`:642`). Splitting these
  needs edits to `game.gd` / `world3d*.gd` (outside this ticket) or a safe
  worker-thread design. They are now separated by extra process-frame yields,
  but a single such stage can still hold the OS window for its own duration.
- **Open question (not changed):** the async loader does not call
  `game._gen_patterns()` or `game._finalize_mine_tiles()`, whereas
  `game.setup()` does (`game.gd:306-315`). Observed pre-existing discrepancy;
  changing it would alter map generation results, so it was left untouched and
  is flagged for the mapgen owner.
- **Open question:** any asset/FX loading that continues after the overlay in
  the composed `world3d_*` / `hud` modules could not be shown or hidden from
  `main.gd` alone; runtime truth UNVERIFIED.

## 7. Owner requirement matrix (QA ping — findings upheld, not rebutted)

| Req | Status | Evidence / concession |
|---|---|---|
| Loading non-blocking; Windows window stays movable | **PARTIAL, runtime UNVERIFIED** | Only inter-stage yields were added. Stage bodies are still monolithic (R3). No windowed interactive probe was possible; no movability claim. |
| Overlay hidden only when ready | **Code-level established; runtime UNVERIFIED** | `load_ready = true` at `main.gd:675`, `_hide_loading()` at `:676`, all gates before it (§5). No runtime observation. |
| **R3 — stage bodies still synchronous** | **CONFIRMED** | `game._gen_base()` (`game.gd:983`) with full-grid passes (`:1050-1122`) and two resource-backed builders (`:1007`, `:1078`; `mapgen.gd:141`); `world.bind()` (`world3d.gd:599`) builds the full mesh (`:639`) and seeds entities (`:642`). Not fixed: those files are outside ownership and the builders call `ResourceLoader.load`, so worker isolation is not safe. Separate ticket. |
| **R4 — `_hide_loading()` has no guard** | **CONFIRMED** | `_hide_loading()` (`main.gd:517-522`) unconditionally sets `loading_active=false` and frees the layer; it does not check `load_ready`. Readiness is enforced only by the single caller path at `main.gd:675-676`. A future/other caller could hide early. Left unchanged deliberately: `_show_loading()` calls `_hide_loading()` at `:463` before resetting `load_ready` at `:464`, so a naive guard would mis-fire there. Open gap for the follow-up owner. |
| **R5 — no deferred-stage observable** | **CONFIRMED** | `load_ready` (`main.gd:157`) is a field only: set at `:675`, reset at `:464`, never read, printed or emitted. There is no labelled deferred-work flag or telemetry proving at runtime that no stage remains after the overlay. "No deferred stage remains" is a code-inspection statement, not an observable. |
| Game fully usable when loading screen finishes | **UNVERIFIED** | No runtime evidence for input/orders/camera/HUD/FX usability. No such claim is made. |

## 8. Summary

Minimal change confined to `variant3d/scripts/main.gd`: the previously
un-sliced art/interface tail of the interactive loader is now four labelled,
frame-yielding stages; a presentation-only warm sync and one drawn frame are
held behind the overlay; an explicit `load_ready` gate is set only after all
usability-binding stages complete, immediately before the overlay is removed.
Backup and two honest runner jobs recorded. Runtime responsiveness, window
movability, guard enforcement, deferred-work observability and "fully usable"
end-to-end behaviour remain UNVERIFIED; the monolithic stage internals, the
unguarded `_hide_loading()` and the missing deferred-work observable are handed
off as open gaps / a separate ticket. No other file was edited by this agent.
No visual-parity claim.
