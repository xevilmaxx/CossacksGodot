---
id: PORT1TO1-FIXED-STEP-PLAN
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER FIXED-STEP-PLAN — read-only design of an opt-in deterministic capture mode and its acceptance-harness contract
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fixed_step_plan.md
status: DELIVERED__READ_ONLY_DESIGN__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", "PRESERVE-ONLY"]
parity_status: UNVERIFIED
parity_claim: false
scope_guard: "Exactly one repo file written (this report). No source, shader, asset, config, test, fixture, result JSON, backup, git state, Godot process or donor binary touched. No capture was produced by this worker. All line numbers are from the current on-disk tree read directly; anchors marked [O] were verified by direct reads of the named file."
governing_sources:
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (task 146, §Preserve-only user mods :178-185)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_determinism_audit.md (N1..N9, §5 experiment template)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§2 capture protocol, §2.3 admissibility, §7 preserve-only)
  - variant3d/scripts/main.gd (all anchors in §2)
  - variant3d/scripts/{data,game,audio,water3d}.gd
  - variant3d/{config.json,config_donor_capture.json}
  - variant3d/tools/acceptance/capture_sequence.py
  - variant3d/tools/godot_runner.py
---

# PORT1TO1 — opt-in deterministic fixed-step capture mode (design only)

> **Required reviewer line, verbatim (W05 §7.3 / PREP-VIDEO §5 / W08 §0):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
> frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a design, not an implementation.** No flag was added, no line of `main.gd` or
> `capture_sequence.py` was changed, no backup was created, no Godot process was launched and
> no capture/frame/hash was produced by this worker. Every hunk in §5 is an *unapplied sketch*.
> The mode described here would, once implemented and run twice, demonstrate **port-internal
> self-consistency only**. It does not and cannot establish donor parity; `parity=UNVERIFIED`
> remains in the manifest.

---

## 0. What is being designed, and what is explicitly out of scope

### 0.1 One sentence contract

A single opt-in master flag plus one required integer companion make `main.gd` execute an
**exact, pre-declared number of fixed `1/Data.FPS` simulation ticks with no wall-clock input and
no CPU-map substitution**, and make `capture_sequence.py` record and verify that contract in
`manifest.json` before a human accepts any frame.

### 0.2 Scope of the mode

| Item | Decision | Anchor / reason |
|---|---|---|
| Admissible engine modes | windowed `--seq` (primary, video/snapshot sequence) and windowed `--screenshot` (additive fix in harness §4.3) | `main.gd:238-253` bypasses the menu for both |
| Refused with the flag | `--headless`, `--cli`, `--seed random`, missing/invalid `--capture-ticks`, missing window, `load_save` | removes N1/N5/N8 paths by construction |
| Not touched | `--bench`, `--journey`, `--self-test`, `--ui-test`, test-API, interactive menu, watchdog, async loader, CPU fallback, audio paths | all remain byte-present and unchanged when the flag is off |
| Donor comparison | **never claimed**; donor binary not run | acceptance plan §2.4, §5 |

### 0.3 Exact new command-line flags (engine side)

| Flag | Syntax | Parsed at | Effect when present |
|---|---|---|---|
| `--deterministic-capture` | presence only, no value | `main.gd:1278-1392`, new case adjacent to `--seed` at `:1377-1384` | sets `capture_deterministic = true`; activates every guard in §3; inverts no existing default |
| `--capture-ticks <N>` | integer `1..1000000`, required companion | same switch, new case adjacent to `--timeout` at `:1355-1357` | sets `capture_ticks_total = N`; exact number of `1/Data.FPS` ticks to execute before finishing |

No other new flag is introduced. The per-frame tick budget is **derived**, not a third flag:
`capture_ticks_per_frame = maxi(1, int(round(seq_step * Data.FPS)))` in seq mode, else
`int(Data.FPS)`. With `--step 1` this is `32` (`data.gd:246`). With `--step 1` and `--frames 24`
the required `--capture-ticks` is `24 * 32 = 768`.

**Exact tick contract:** `seq_step` is clamped in `main.gd:1331-1334`; `Data.FPS = 32.0`
(`data.gd:246`); `game.tick(dt)` adds `dt` to `time_s` at `game.gd:5731` after clamping to
`TICK_MAX` (`game.gd:5730`, `game.gd:598`, config `max_tick_seconds=0.25` at
`config_donor_capture.json:98`; `1/32 = 0.03125 < 0.25`, so no clamp is hit). Therefore after
exactly `N` fixed ticks `game.time_s == N / 32.0` (float, deterministic on a fixed build), and
with `ticks_per_frame = round(step*32)` the engine emits one captured frame per render frame,
`frames` frames total, at sim-time spacing `ticks_per_frame/32`.

---

## 1. Exact on-disk anchors `[O]`

All of the following were read directly; roles are unaffected by the design.

### 1.1 `variant3d/scripts/main.gd`

| Line(s) | Current content / role | Design action |
|---|---|---|
| `:3-35` | CLI doc header | ADD two flag lines (§5.1) |
| `:65-69` | `acc`, `speed`, `frame`, `screenshot_frames := 120` | ADD state vars after `:171` |
| `:113` | `started_ms := 0` | NONE (preserve) |
| `:124` / `:125` | `render_mode := "2d"` / `terrain_backend := "legacy"` | **PRESERVE — I11 seam** |
| `:174` | `started_ms = Time.get_ticks_msec()` | NONE (telemetry) |
| `:176-177` | `_parse_args(OS.get_cmdline_args())` + user args | ADD cases inside `_parse_args` |
| `:188-191` | I11 backend resolution (`donor` → else `legacy`) | **PRESERVE — I11 seam** |
| `:192-195` | `--seed random` → `randi()`, else `seed_arg` | NONE; deterministic mode requires `seed_arg >= 0` |
| `:214-220` | `hard_limit`, `deadline_ms`, `watchdog` assignment | ADD override to zero **after** the block (purely additive) |
| `:222-224` | `cli_mode` → `_setup_cli_only()` | ADD refusal in `_ready` validation |
| `:238-253` | test/capture bypass → `_setup_full_game()`; `:251-252` `_setup_screenshot_window()` | ADD `capture_deterministic` to `:239` list; ADD deterministic seq viewport setup |
| `:543-550` | `_loading_tick()` awaits `process_frame` at `:548-549` | ADD deterministic drain variant (defensive; path not reached) |
| `:552-695` | `_do_async_load()`; awaits `:562-563`, `:667`, `:682`, `:687`; `load_ready = true` at `:694`; AI brains at `:666` | **PRESERVE**; deterministic mode never enters it; add defensive drain + tick gate |
| `:760-768` | `_setup_cli_only()`; `cli_ticks_left = int(cli_seconds * Data.FPS)` at `:766` | NONE; CLI refused deterministically |
| `:1096-1102` | `_setup_full_game()` window size / VSYNC | NONE |
| `:1124-1125` | `world.set_terrain_backend(terrain_backend)` | **PRESERVE — I11 seam** |
| `:1162-1201` | HUD/input/AI/audio setup; function ends at `:1201` | ADD `load_ready = true` at `:1202` for deterministic sync path |
| `:1278-1392` | `_parse_args()` | ADD two cases |
| `:1355-1357` | `--timeout` → `limit_s` | NONE; engine ignores it when deterministic, runner still enforces its own |
| `:1377-1384` | `--seed` | NONE |
| `:1608-1613` | watchdog forced exit | No code change needed: no-op when `deadline_ms == 0` |
| `:1624-1628` | `if game == null or ais.is_empty(): return`; CLI dispatch | ADD `(capture_deterministic and not load_ready)` to `:1624` |
| `:1629-1634` | watchdog decrement | No code change needed: no-op when `watchdog == 0.0` |
| `:1635-1642` | `dt = minf(dt,0.25); acc += dt*speed; step := 1/Data.FPS; while acc >= step and steps < 64` | ADD fixed-tick branch; original loop preserved verbatim in `else` leg |
| `:1645-1655` | per-tick `Time.get_ticks_usec()` telemetry; `:1654-1655` wall-clock break | NONE; wall-clock break no-op when `deadline_ms == 0` |
| `:1660` / `:1676-1689` | `dbg_steps += steps`; bench report | NONE (bench not used deterministically) |
| `:1690-1693` | `world.sync(dt)` | ADD fixed sync delta = `steps * (1/Data.FPS)` when deterministic |
| `:1734-1744` | `_consume_events()`, audio walk timer, `frame += 1` | NONE |
| `:1751-1753` | `--screenshot` fires on render-frame count `frame >= screenshot_frames` | ADD deterministic branch on `capture_ticks_done >= capture_ticks_total` |
| `:1758-1764` | seq trigger on `game.time_s >= seq_next` | NONE (sim-time thresholds are tick-deterministic once §3.1 holds) |
| `:1870-1881` | `_save_screenshot()` headless branch → `_render_headless_image(800,600)` | ADD refusal before it; ADD size assert at `:1901` |
| `:1885-1890` | authoritative `capture_view3d` texture path (3D) | NONE; reused by deterministic seq (§3.2) |
| `:1953-1989` | `_is_blank()` | NONE; used to *refuse* a frame, never to trigger a fallback |
| `:1993+` | `_render_headless_image(w,h)` | **PRESERVE**; never called in deterministic mode |
| `:2142-2164` | `_save_seq_frame()`: GPU read `:2147-2152`, silent 800×600 fallback `:2153-2154`, write `:2155`, termination `:2157`, index `:2159-2161`, quit `:2163` | ADD authoritative viewport read, blank/size refusal, tick-based termination, index fields |
| `:2169-2207` | `_run_cli_incremental()` wall-clock budget `:2185-2189`, seq fallback `:2198`, quit `:2205` | NONE; CLI refused deterministically |

### 1.2 Other exact anchors

| Anchor | Content | Why it matters |
|---|---|---|
| `data.gd:246` | `static var FPS := 32.0` | authoritative fixed tick rate |
| `data.gd:506-507` | `WINDOW_WIDTH := 1280`, `WINDOW_HEIGHT := 720` | resolution assert source |
| `data.gd:509` | `VSYNC := true` | VSYNC is frame pacing only; irrelevant once `dt` is ignored |
| `game.gd:5727`, `:5730-5731` | `tick(dt)`, `dt = minf(dt, TICK_MAX)`, `time_s += dt` | proves fixed-step ⇒ fixed `time_s`; early `return` at `:5728` when `winner != -1` must be asserted |
| `audio.gd:334-337`, `:360`, `:368` | wall-clock dedup + unseeded `randi()`/`randf_range()` | Class-N hazard **not** neutralized by this design (§6) |
| `game.gd:8127-8130` | unseeded global `randf()` fisher target/order | Class-N P0 hazard **not** neutralized (§6) |
| `water3d.gd:374-384` | `_process(delta)` → `_time += delta` | frame-paced visual accumulator; currently no water drawn (U12 hard-fail) |
| `config_donor_capture.json:29-33` | `relief_stamps=true`, `backend="donor"`, `demo_mill=true` | **PRESERVE**; QA fixture flag |
| `config_donor_capture.json:58-59` | `window_width=1280`, `window_height=720` | harness `resolution_requested` source |
| `config.json:28-31` | `backend="donor"`, `relief_stamps=true`, `color_unify=true` | **PRESERVE** |
| `variant3d/tools/acceptance/capture_sequence.py` | argv `:143-163`; runner result `:184-196`; frame hashes `:206-225`; index `:227-229`; args `:241-266`; manifest `:308-336` | harness change sites |
| `variant3d/tools/godot_runner.py:437` | `subprocess.Popen([GODOT, *argv])` | proves new flags pass through verbatim |
| `variant3d/tools/godot_runner.py:650-651` | strips a single leading `--` from `godot_args` | proves `capture_sequence.py`'s post-`--` args reach `main.gd` unchanged |

---

## 2. Design — `main.gd` fixed-step driver

### 2.1 State added (all near `:171`, no existing var changed)

```
capture_deterministic := false       # master opt-in
capture_ticks_total := 0             # --capture-ticks, exact
capture_ticks_done := 0              # increments once per game.tick(step)
capture_ticks_per_frame := 32        # derived: maxi(1, int(round(seq_step * Data.FPS)))
capture_error := false               # refusal flag; harness also reads stderr
const CAPTURE_EXPECTED_W := 1280     # data.gd:506
const CAPTURE_EXPECTED_H := 720      # data.gd:507
```

### 2.2 Wall-clock decoupling — exact insertion point `:220`

Insert **after** the existing `if/else` block that ends at `:220`:

```
if capture_deterministic:
    deadline_ms = 0        # disables :1610-1613, :1654-1655, :2187-2189, :2205
    watchdog = 0.0         # disables :1629-1634
```

Because every wall-clock check in `_process` is guarded by `deadline_ms > 0` or
`watchdog > 0.0`, this makes all four truncation sites inert **without editing them**. The
external `godot_runner.py` hard timeout still exists (safety net for a hung process); it is not
a tick source and cannot change the number of ticks executed before the engine exits normally.
`--timeout` (`main.gd:1355-1357`) is therefore deliberately ignored internally in this mode and
must be pinned in the run notes (`capture_sequence.py:329-330` still records it).

Required validation, also inserted after `:220`:

```
if capture_deterministic:
    if is_headless or cli_mode or seed_arg < 0 or capture_ticks_total <= 0:
        printerr("deterministic-capture: needs windowed --seq/--screenshot, literal --seed and --capture-ticks > 0")
        _quit(2); return
    if seq_dir != "":
        capture_ticks_per_frame = maxi(1, int(round(seq_step * Data.FPS)))
```

`load_save` cannot be rejected from this site easily (it is a config key applied at
`main.gd:700-705` / `:969-971`); it is excluded by the capture protocol (§6), and the harness
asserts the config file SHA.

### 2.3 Fixed step count — exact replacement at `:1635-1642`

The original `dt/acc/while` block becomes the `else` leg, byte-for-byte. `steps` is hoisted so
the existing `dbg_steps += steps` at `:1660` still works:

```
var steps := 0
var t_tick := 0.0
var t_ai := 0.0
if capture_deterministic:
    var dstep := 1.0 / Data.FPS
    while capture_ticks_done < capture_ticks_total and steps < capture_ticks_per_frame:
        var t0 := Time.get_ticks_usec()
        game.tick(dstep)
        bench_sim_ms += float(Time.get_ticks_usec() - t0) / 1000.0
        for brain in ais:
            brain.tick(dstep)
        capture_ticks_done += 1
        steps += 1
else:
    dt = minf(dt, 0.25)
    acc += dt * speed
    var step := 1.0 / Data.FPS
    while acc >= step and steps < 64:
        ... unchanged :1643-1655 ...
```

Consequences:
- No `dt`, no `acc`, no `speed` (`--fast`/`--speed` at `:1371-1375` cannot enter).
- No `steps < 64` frame cap, so `--step 30` (960 ticks/frame) is permitted and bounded only by
  the declared `capture_ticks_total` and `capture_ticks_per_frame`.
- No `Time.get_ticks_*` value participates in tick count; the remaining `Time.get_ticks_usec()`
  calls at `:1645-1652` are telemetry only.
- `world.sync(dt)` at `:1692` becomes
  `world.sync(float(steps) * (1.0 / Data.FPS) if capture_deterministic else dt)` so visual
  interpolators advance by exactly the sim time advanced this frame.
- `_process` early-return at `:1624` gains `or (capture_deterministic and not load_ready)`;
  `load_ready` is set at `:1202` in the synchronous setup path (§3).

### 2.4 Termination

- **Seq mode:** at `:2157`, replace the single condition with a deterministic disjunction:
  `if seq_count >= seq_max or (capture_deterministic and capture_ticks_done >= capture_ticks_total) or (not capture_deterministic and (game.time_s >= seq_seconds or game.winner != -1)):`
  Add to the `index` dict at `:2159-2161`: `deterministic=true`, `capture_ticks=N`,
  `ticks_done=capture_ticks_done`, `ticks_per_frame=capture_ticks_per_frame`,
  `winner=game.winner`. The harness refuses `winner != -1` (§4.4).
- **Screenshot mode:** at `:1751`, fire when `capture_ticks_done >= capture_ticks_total`
  instead of `frame >= screenshot_frames`, keeping the original condition as the `else` leg.
- `_quit(0)` sites (`:2163`, `:1951`) are unchanged; only the conditions feeding them change.

---

## 3. Design — fallback refusal and 1280×720 assertion

### 3.1 Refuse the CPU fallback, do not delete it

`_render_headless_image(800,600)` at `main.gd:2153-2154` (seq) and `:1873` (headless screenshot)
stays byte-present for all non-deterministic users. Insert immediately **before** the fallback
at `:2153`:

```
if capture_deterministic and (img == null or img.is_empty() or _is_blank(img)
        or img.get_width() != CAPTURE_EXPECTED_W or img.get_height() != CAPTURE_EXPECTED_H):
    printerr("deterministic-capture: blank/wrong-size viewport frame; CPU fallback refused")
    capture_error = true
    _quit(2); return
```

and before the headless branch at `:1871`:

```
if capture_deterministic and is_headless:
    printerr("deterministic-capture: headless CPU screenshot refused")
    _quit(2); return
```

After `var img := tex.get_image()` at `:1901`, apply the same 1280×720 + non-blank refusal for
`screenshot` mode. `_is_blank()` (`:1953-1989`) is used as a *veto*, never as a trigger for a
substitute — the silent `mode="window"` mislabel described in the audit (N8) is therefore
impossible in this mode.

### 3.2 Authoritative viewport for deterministic `--seq`

Windowed `--seq` currently reads `get_viewport().get_texture()` at `:2149-2152` (root
backbuffer, blank under `gl_compatibility`), while the screenshot path already solves this with
`capture_view3d` at `:1885-1890`. Add, inside the `:238-253` setup block:

```
if capture_deterministic and seq_dir != "":
    _setup_screenshot_window()
```

`_setup_screenshot_window()` (`:1237-1274`) sets window size to `Data.WINDOW_WIDTH/HEIGHT`
(`:1243`), creates `SubViewport` of the same size (`:1262-1267`) and reparents world+camera
(`:1268-1274`). Then, in `_save_seq_frame()` at `:2147-2152`, for deterministic 3D reads use
`capture_view3d.get_texture()` (with `render_target_update_mode = UPDATE_ONCE`) instead of the
root viewport. This makes the seq path use the same authoritative texture as the single-shot
path, and gives a real 1280×720 `Image` to hash.

### 3.3 Assertion summary (engine side)

| Assertion | Site | Failure |
|---|---|---|
| `not is_headless`, `not cli_mode`, `seed_arg >= 0`, `capture_ticks_total > 0` | after `:220` | `printerr` + `_quit(2)` |
| `img` non-null, non-empty, `not _is_blank(img)` | `:2153`, `:1901` | `printerr` + `_quit(2)`, no frame written |
| `img.get_width()==1280 && img.get_height()==720` | `:2153`, `:1901` | `printerr` + `_quit(2)` |
| `ticks_done == capture_ticks_total` at finalization | `:2157` | finalization only reached at equality |
| `game.winner == -1` at finalization | `:2159` index | harness refuses otherwise |

---

## 4. Design — deterministic async-load awaiting

### 4.1 Primary design: the async loader is never entered

Add `capture_deterministic` to the test/capture bypass condition at `main.gd:239`:

```
if capture_deterministic or bench_mode or screenshot_path != "" or ... or journey_mode:
```

`_ready` then calls `_setup_full_game()` (`:240`) synchronously, the same path used by headless
tests. `_do_async_load()` (`:552-695`) — with its `process_frame` awaits at `:548-549`, `:562-563`,
`:667`, `:682` and `frame_post_draw` at `:687` — is **not invoked at all**, so no load-stage
yield can let sim ticks run between stages. This is the deterministic "await": there is no await.
Add `load_ready = true` at `:1202` (end of `_setup_full_game`) so the new `:1624` tick gate opens
only after every synchronous stage (sim, terrain, camera, HUD, input, AI at `:1194`, audio at
`:1196-1201`) is complete.

### 4.2 Defensive secondary design (only if the async path is ever reached)

If an owner later combines the flag with the interactive loader, add a fixed-count drain that
replaces frame-paced awaits **without changing stage order**:

```
func _det_load_yield() -> void:
    for _i in 4:
        await get_tree().process_frame
```

Use it in `_loading_tick()` (`:548-549`) and `_do_async_load()` (`:562-563`) in place of the two
bare `await get_tree().process_frame` calls **only when** `capture_deterministic` is true; skip the
final `await RenderingServer.frame_post_draw` at `:687` in that mode. The `:1624` gate
`(capture_deterministic and not load_ready)` guarantees zero sim ticks during those yields, so
four yields are state-neutral: they only let the renderer repaint. `load_ready = true` at `:694`
remains the single readiness close. Stage order and all `game.setup_*`/`_gen_*` calls
(`:580-598`) stay byte-identical. This is defensive only — normal deterministic captures take
§4.1.

---

## 5. Minimal additive-diff sketch (unapplied) with backups

> **Not applied by this worker.** Before any implementation, the owner would create reversible
> backups. No backup exists on disk as a result of this report.

```
copy variant3d\scripts\main.gd                       variant3d\scripts\main.gd.bak-FIXEDSTEP-20261126
copy variant3d\tools\acceptance\capture_sequence.py  variant3d\tools\acceptance\capture_sequence.py.bak-FIXEDSTEP-20261126
```

The `I11` seam backups `main.gd.bak-COORD-I11` and `world3d.gd.bak-COORD-I11` are **not** touched
(acceptance plan §7 records their SHA-256 witnesses).

### 5.1 `main.gd` (sketch)

```diff
--- a/variant3d/scripts/main.gd
+++ b/variant3d/scripts/main.gd        # SKETCH — NOT APPLIED
@@ -34,3 +34,6 @@
 # Cross-platform: renderer is gl_compatibility (project.godot), all paths are
 # res:// / user:// or absolute, window flags are guarded by OS.get_name().
+#   --deterministic-capture  opt-in fixed-step capture; windowed --seq/--screenshot only
+#   --capture-ticks <n>      required companion: exact count of 1/Data.FPS ticks
 extends Node
@@ -169,3 +172,10 @@
 var capture_view3d: SubViewport = null
+
+var capture_deterministic := false
+var capture_ticks_total := 0
+var capture_ticks_done := 0
+var capture_ticks_per_frame := 32
+var capture_error := false
+const CAPTURE_EXPECTED_W := 1280
+const CAPTURE_EXPECTED_H := 720
@@ -217,3 +227,16 @@
 		deadline_ms = 0
 		watchdog = 0.0
 	}
+	if capture_deterministic:
+		deadline_ms = 0            # all wall-clock checks :1610/:1654/:2187/:2205 become inert
+		watchdog = 0.0
+		if is_headless or cli_mode or seed_arg < 0 or capture_ticks_total <= 0:
+			printerr("deterministic-capture: windowed --seq/--screenshot, literal --seed and --capture-ticks > 0 required")
+			_quit(2); return
+		if seq_dir != "":
+			capture_ticks_per_frame = maxi(1, int(round(seq_step * Data.FPS)))
@@ -237,3 +260,4 @@
-	if bench_mode or screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or battle_requested or journey_mode:
+	if capture_deterministic or bench_mode or screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or battle_requested or journey_mode:
 		_setup_full_game()
@@ -249,3 +273,5 @@
 		if screenshot_path != "":
 			_setup_screenshot_window()
+		if capture_deterministic and seq_dir != "":
+			_setup_screenshot_window()   # authoritative 3D texture for seq
 		return
@@ -1199,3 +1225,5 @@
 	audio.set_meta("can_play", can_play)
+	if capture_deterministic:
+		load_ready = true            # synchronous setup closes all readiness gates
@@ -1382,3 +1410,10 @@
 			"--seed":
 				... unchanged ...
 				continue
+			"--deterministic-capture":
+				capture_deterministic = true
+			"--capture-ticks":
+				capture_ticks_total = clampi(int(args[i + 1]) if i + 1 < args.size() else 0, 0, 1000000)
+				i += 2
+				continue
 			"--dump-map":
@@ -1622,4 +1657,4 @@
-	if game == null or ais.is_empty():
+	if game == null or ais.is_empty() or (capture_deterministic and not load_ready):
 		return
@@ -1634,4 +1669,22 @@
-	dt = minf(dt, 0.25)
-	acc += dt * speed
-	var step := 1.0 / Data.FPS
-	var steps := 0
+	var step := 1.0 / Data.FPS
+	var steps := 0
 	var t_tick := 0.0
 	var t_ai := 0.0
+	if capture_deterministic:
+		var dstep := 1.0 / Data.FPS
+		while capture_ticks_done < capture_ticks_total and steps < capture_ticks_per_frame:
+			var t0 := Time.get_ticks_usec()
+			game.tick(dstep)
+			bench_sim_ms += float(Time.get_ticks_usec() - t0) / 1000.0
+			for brain in ais:
+				brain.tick(dstep)
+			capture_ticks_done += 1
+			steps += 1
+	else:
+		dt = minf(dt, 0.25)
+		acc += dt * speed
+		while acc >= step and steps < 64:
+			... unchanged :1643-1655 ...
@@ -1689,4 +1742,4 @@
-		world.sync(dt)
+		world.sync(float(steps) * (1.0 / Data.FPS) if capture_deterministic else dt)
@@ -1749,4 +1802,8 @@
-	if screenshot_path != "" and not screenshot_done and frame >= screenshot_frames:
+	if capture_deterministic:
+		if screenshot_path != "" and not screenshot_done and capture_ticks_done >= capture_ticks_total:
+			screenshot_done = true
+			_save_screenshot()
+	elif screenshot_path != "" and not screenshot_done and frame >= screenshot_frames:
 		screenshot_done = true
@@ -1869,3 +1926,6 @@
 func _save_screenshot() -> void:
+	if capture_deterministic and is_headless:
+		printerr("deterministic-capture: headless CPU screenshot refused")
+		_quit(2); return
 	if is_headless:
@@ -1899,3 +1959,5 @@
 	var img := tex.get_image()
+	if capture_deterministic and (img == null or img.is_empty() or _is_blank(img) or img.get_width() != 1280 or img.get_height() != 720):
+		printerr("deterministic-capture: blank/wrong-size screenshot; no fallback"); _quit(2); return
@@ -2146,4 +2208,12 @@
 	var img: Image = null
 	if not is_headless:
 		await RenderingServer.frame_post_draw
+		if capture_deterministic and capture_view3d != null and is_instance_valid(capture_view3d):
+			capture_view3d.render_target_update_mode = SubViewport.UPDATE_ONCE
+			var dtex := capture_view3d.get_texture()
+			if dtex != null:
+				img = dtex.get_image()
 		if is_instance_valid(get_viewport()):
@@ -2152,3 +2222,6 @@
 				img = tex.get_image()
+	if capture_deterministic and (img == null or img.is_empty() or _is_blank(img) or img.get_width() != 1280 or img.get_height() != 720):
+		printerr("deterministic-capture: blank/wrong-size viewport frame; CPU fallback refused")
+		capture_error = true; _quit(2); return
 	if img == null or img.is_empty() or _is_blank(img):
@@ -2155,4 +2227,7 @@
 	seq_saving = false
-	if seq_count >= seq_max or game.time_s >= seq_seconds or game.winner != -1:
+	var det_done := capture_deterministic and capture_ticks_done >= capture_ticks_total
+	if seq_count >= seq_max or (capture_deterministic and det_done) \
+			or (not capture_deterministic and (game.time_s >= seq_seconds or game.winner != -1)):
 		seq_done = true
 		var index := {"seconds": seq_seconds, "step": seq_step, "frames": seq_count,
 			"sim_seconds": game.time_s, "mode": "headless" if is_headless else "window"}
+		if capture_deterministic:
+			index["deterministic"] = true
+			index["capture_ticks"] = capture_ticks_total
+			index["ticks_done"] = capture_ticks_done
+			index["ticks_per_frame"] = capture_ticks_per_frame
+			index["winner"] = game.winner
```

Note on the `_save_seq_frame` hunk: when the flag is off, `det_done` is false and the third
disjunct reduces to the original `game.time_s >= seq_seconds or game.winner != -1`, so the
non-deterministic behaviour stays byte-identical. The deterministic path finalizes only at the
declared tick count; `seq_index.json` carries the tick witness fields asserted in §8.2.

### 5.2 `capture_sequence.py` (sketch)

```diff
--- a/variant3d/tools/acceptance/capture_sequence.py
+++ b/variant3d/tools/acceptance/capture_sequence.py   # SKETCH — NOT APPLIED
@@ RUNNER = PROJECT / "tools" / "godot_runner.py"
+ENGINE_FPS = 32              # variant3d/scripts/data.gd:246
+CAPTURE_W, CAPTURE_H = 1280, 720  # data.gd:506-507
+
@@ -149,6 +149,8 @@
     godot_args += ["--seed", ns.seed]
+    if ns.deterministic:
+        godot_args += ["--deterministic-capture", "--capture-ticks", str(ns.capture_ticks)]
@@ -264,2 +266,6 @@
-    ns = ap.parse_args(argv)
+    ap.add_argument("--deterministic", action="store_true",
+                    help="opt-in fixed-step capture; windowed --seq only by default")
+    ap.add_argument("--capture-ticks", type=int, default=None, metavar="N",
+                    help="exact fixed tick count; required with --deterministic")
+    ns = ap.parse_args(argv)
```

The two `add_argument` lines belong **immediately before** `ns = ap.parse_args(argv)` at
`capture_sequence.py:266` (the `@@ -264` marker above indicates that insertion region).

```diff
@@ -289,2 +293,14 @@
     if not ns.view:
         ap.error("at least one --view is required (use NAME for engine defaults)")
+    if ns.deterministic:
+        if ns.headless or ns.mode == "shot":
+            ap.error("--deterministic requires windowed --seq (no --headless/--mode shot)")
+        tpf = max(1, round(ns.step * ENGINE_FPS))
+        if ns.capture_ticks is None or ns.capture_ticks <= 0:
+            ap.error("--capture-ticks N (>0) is required with --deterministic")
+        if ns.capture_ticks != ns.frames * tpf:
+            ap.error(f"--capture-ticks must equal frames*max(1,round(step*32))={ns.frames*tpf}")
@@ -318,3 +338,9 @@
         "seed": ns.seed,
+        "deterministic_capture": ns.deterministic,
+        "capture_ticks": ns.capture_ticks if ns.deterministic else None,
+        "engine_fps_anchor": "variant3d/scripts/data.gd:246",
+        "expected_sim_seconds": (ns.capture_ticks / ENGINE_FPS) if ns.deterministic else None,
+        "expected_resolution": [CAPTURE_W, CAPTURE_H] if ns.deterministic else None,
@@ -227,3 +253,3 @@
     if index_path.is_file():
         view["seq_index"] = json.loads(index_path.read_text(encoding="utf-8"))
+    if ns.deterministic:
+        idx = view.get("seq_index") or {}
+        err = view.get("engine_stderr") or ""
+        if idx.get("deterministic") is not True or idx.get("ticks_done") != ns.capture_ticks:
+            raise RuntimeError(f"view {name}: tick contract missing in seq_index.json")
+        if abs(float(idx.get("sim_seconds")) - ns.capture_ticks / ENGINE_FPS) > 1e-9:
+            raise RuntimeError(f"view {name}: sim_seconds != capture_ticks/32")
+        if int(idx.get("winner", -1)) != -1:
+            raise RuntimeError(f"view {name}: winner set before tick budget completed")
+        if view["resolution_observed"] != {"width": CAPTURE_W, "height": CAPTURE_H}:
+            raise RuntimeError(f"view {name}: not 1280x720 (CPU fallback / wrong size)")
+        if not view["resolution_matches_request"]:
+            raise RuntimeError(f"view {name}: resolution_matches_request is false")
+        for bad in ("deterministic-capture:", "watchdog:", "cli: wall-clock limit reached"):
+            if bad in err:
+                raise RuntimeError(f"view {name}: refusal/watchdog line in engine stderr: {bad}")
```

`godot_runner.py` needs **no change**: `godot_runner.py:650-651` strips the single `--`, and
`:437` passes `[GODOT, *argv]` verbatim to `subprocess.Popen`.

### 5.3 Optional snapshot extension (only if owner wants deterministic `--screenshot`)

One additive hunk at `capture_sequence.py:206`: if `ns.mode == "shot"`, seed the `frames` list
with `view_dir / "snapshot.png"` instead of the empty `frame_*.png` glob; then relax the §5.2
validation to permit `--mode shot` with `capture_ticks = ns.frames * ENGINE_FPS` and skip the
`seq_index` assertions (no index is written by the shot path). No engine change beyond §2.4's
tick-based screenshot trigger.

---

## 6. Preserve-only guards

Every item below is **left byte-unchanged**; the design only adds flag-gated branches.

| Guard | Exact preserved value / location | Rule |
|---|---|---|
| I11 seam — `main.gd` | `:125 var terrain_backend := "legacy"`; `:188-191` coercion; `:605-606` and `:1124-1125` `set_terrain_backend(terrain_backend)` | never re-apply, never flip default; `.bak-COORD-I11` SHA witness in acceptance §7 |
| I11 seam — `world3d.gd` | `world3d.gd:147 terrain_backend := "legacy"`; late-switch refusal `:223-227`; `.bak-COORD-I11` | untouched |
| `config.json` | `:28-31` `backend="donor"`, `relief_stamps=true`, `color_unify=true`; all numeric overrides; `_readme` comments | no edit; deterministic mode reads it via existing `--config` (`main.gd:1359-1362`) and hashes it |
| `config_donor_capture.json` demo_mill | `:29-33` `relief_stamps=true`, `backend="donor"`, `demo_mill=true` | must stay `true`; QA fixture, **not** donor skirmish law; record in capture notes |
| Watchdog / deadline | `main.gd:174`, `:214-220`, `:1610-1613`, `:1654-1655`, `:2187-2189`, `:2205`, `--timeout` `:1355-1357` | preserved for all non-flag runs; neutralised only by `:220` override |
| Async staged loader | `main.gd:543-550`, `:552-695`, `frame_post_draw :687`, `load_ready :694` | preserved; deterministic mode bypasses it (§4.1) |
| CPU fallback | `_render_headless_image` `:1993+`, calls at `:1873`/`:2154`, `_is_blank` `:1953-1989` | preserved; deterministic mode refuses the branch, never deletes the function |
| Audio / Random seed | `audio.gd:334-337,360,368`; `menu.gd:905-908`; `main.gd:192-193,1377-1380` | preserved user features; not gated by this design |
| Manifest owner mods | `assets/models/manifest.json` nation move / EUR aliases / field-palm-desert, plus backup dir | untouched |
| Save state | `game.gd` v5 keys, `main.gd:700-705,969-971` | preserved; `load_save` excluded from deterministic captures by protocol |
| Water `[U]` | `water3d.gd:374-384` `_time += delta`; U12 hard-fail | **not** frozen and not "fixed" — see §7 |

---

## 7. Residual Class-N hazards — what this design does NOT neutralize

The mode fixes **stepping, deadline truncation, async yields and the CPU fallback**. It does not
by itself make every possible capture byte-identical. The following remain open from the audit
and must be excluded or separately neutralized before a zero-mismatch claim:

| Hazard | Exact site | Relation to this mode |
|---|---|---|
| N3 unseeded fisher `randf()` | `game.gd:8127-8130` | Sim-state divergence; a capture containing a fishing delivery can still hash-differ. Keep inadmissible until routed through seeded `sim_rng` or frozen by owner experiment. |
| N4 audio RNG + wall-clock dedup | `audio.gd:334-337,360,368` | Windowed capture has `can_play = not is_headless` (`main.gd:671-674`), so audio runs. Use a temp config with `audio.enabled=false` for pixel captures, or record WAV and expect mismatch until seeded. |
| N9 save/load seed rewrite | `game.gd:9334-9335`, `main.gd:700-705` | Exclude `load_save` captures. |
| U5 water time accumulator | `water3d.gd:374-384` | Currently no water pixels (U12 hard-fail). Do **not** freeze `_time=0` in this design: that is a `[U]` candidate, not a donor value, and freezing it would be an approximation. If water is ever enabled, this becomes a separate open hazard. |
| GPU/driver state | renderer `gl_compatibility`, VSYNC handling at `main.gd:1101-1102,1254` | Two runs must be on the same machine, same build and same driver; no cross-GPU determinism is claimed. |
| Frame-count `--screenshot` path | `main.gd:1751` | Non-deterministic without §2.4 override; unchanged for non-flag users. |

Because of these, the verification criterion in §8 is an **empirical test**, not a proof derived
from the design. A mismatch is never papered over by weakening the gate or by adding a port
fallback.

---

## 8. Verification criterion — two runs, identical seed/config, byte-identical frame hashes

### 8.1 Exact harness command (Run A)

From repo root, with a temp config copy whose bytes are pinned (copy of
`variant3d/config_donor_capture.json`, `demo_mill=true` preserved at `:32`, seed literal
`20261113`, `window_width/height=1280/720`):

```powershell
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label fixedA `
  --view wide=$Acc\wide_config.json `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/fixedA_20261126
```

`768 = frames(24) * max(1, round(step(1) * FPS(32))) = 24 * 32`. Run B is byte-identical except
`--label fixedB` and `--out inbox/qa/captures/fixedB_20261126`. Same config file bytes → same
`config_sha256_file`. Preflight is exactly acceptance plan §2.1 (runner `status` quiet,
`assert_clean.py --json`, `py_compile`, ffmpeg/ffprobe/Pillow present); no `reset`/`doctor`/
`cancel`/result deletion, one job at a time.

### 8.2 Pass conditions (all required, none weakened)

1. Both manifests: `status=ok`, `parity=UNVERIFIED`, `deterministic=true`, `seed="20261113"`,
   `deterministic_capture=true`, `capture_ticks=768`, `engine_fps_anchor="variant3d/scripts/data.gd:246"`,
   `expected_sim_seconds=24.0`, `expected_resolution=[1280,720]`,
   `config_sha256_file` equal to the pinned temp config, `headless=false`,
   `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`.
2. Every view: `runner_status=ok`, `runner_exit=0`, `complete=true`, `frame_count=24`,
   `resolution_observed == {"width":1280,"height":720}`, `resolution_matches_request=true`.
3. `seq_index.json`: `deterministic=true`, `ticks_done=768`, `ticks_per_frame=32`,
   `sim_seconds == 768/32 == 24.0` (exact within `1e-9`), `frames=24`, `mode="window"`,
   `winner=-1`.
4. `runner_stderr.txt` / `engine_stderr` contain **no** `watchdog:`, **no**
   `cli: wall-clock limit reached`, **no** `deterministic-capture:` refusal line.
5. **Byte-identical frame hashes:** for each view and each index `0..23`, Run A's
   `sha256_pixels` equals Run B's `sha256_pixels` in order, and `sha256_file` likewise (Godot's
   PNG encoder is deterministic for identical pixels on a fixed build; `sha256_pixels` is the
   authoritative criterion if PNG metadata ever differs). `seq_index.json` and the manifest's
   per-frame fields are otherwise identical apart from `generated_utc`/`runner_ticket`/
   timestamps/paths.
6. No 800×600 frame. A single 800×600 or blank frame, or any early termination, is a **failed
   capture** (acceptance plan §2.3/§5.6), not an admissible replay.

### 8.3 Verdict rule

- If **all** conditions hold: the evidence supports **port-internal fixed-seed self-consistency
  only**. It is not donor parity; the reviewer line at the top of this report stays verbatim.
- If **any** condition fails: deterministic capture mode is **not demonstrated**; keep the
  affected Class-N/`[U]` item open (§7). Do not lower a threshold, do not substitute a CPU map,
  do not retry until green, and do not add a port fallback to force a match.
- A passing pair never changes `parity=UNVERIFIED` or `blocking_unverified`. Unit-test gates are
  not the acceptance path.

---

## 9. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `main.gd:1635-1642` uses frame-paced `dt`; `:214-220`/`:1610-1613`/`:1654-1655`/`:2187-2205` are wall-clock truncators; `:2153-2154` silently substitutes an 800×600 CPU map | [O] direct reads |
| 2 | `--deterministic-capture` + required `--capture-ticks N` is the exact proposed flag pair; no third flag is introduced | [D] design |
| 3 | Zeroing `deadline_ms`/`watchdog` after `:220` disables all four wall-clock checks without editing their guarded sites; a fixed tick loop at `:1635-1642` makes `time_s` a function of tick count only (`game.gd:5731`) | [D] derived from [O] |
| 4 | Adding `capture_deterministic` to `:239` forces the synchronous `_setup_full_game()` path, so `_do_async_load` yields (`:548-549,562-563,667,682,687`) never run; defensive fixed-count drain is only for a hypothetical future path | [D] design |
| 5 | `godot_runner.py:650-651` + `:437` pass the new flags through verbatim; `capture_sequence.py:143-163` is the only harness site that must add them | [O]/[D] |
| 6 | I11 seam, `config.json`, `config_donor_capture.json:32 demo_mill=true`, watchdog, async loader and CPU fallback remain byte-preserved; backups named in §5 are the only reversible copies | [D] preserve-only |
| 7 | The verification criterion is two runs with identical seed/config producing byte-identical per-frame `sha256_pixels` (and `sha256_file`), with clean stderr and 1280×720 resolution | [D] design |
| 8 | N3 fisher RNG, N4 audio RNG, N9 save and U5 water time are not neutralized; byte-identical hashes remain an empirical result, not a design consequence | [O]/[D] |
| 9 | This worker wrote exactly one repo file (this report); no code, Godot process, git state, donor execution, backup or capture was produced | [O] scope |

---

## 10. Verdict

- **Design delivered:** an opt-in, flag-gated fixed-step capture mode with explicit tick count,
  wall-clock decoupling, authoritative 1280×720 viewport read, hard refusal of the 800×600 CPU
  fallback, synchronous/deterministic load completion, and a manifest-verifying harness contract.
- **Not implemented, not executed:** all hunks are unapplied sketches; no backup was created.
- **Port-vs-port self-determinism:** CONDITIONAL — passes only if §8's two-run byte-identical
  frame-hash test actually passes on the owner's machine; §7 hazards remain open until excluded.
- **Port-vs-donor comparison:** UNVERIFIED — no donor GPU A/B frame, no parity claim.
- **Preserve-only choices:** all §6 items documented, none removed or gated off for other users.

*End of PORT1TO1_fixed_step_plan. Read-only design; exactly one repository file written. No
approximation introduced, no test weakened, no donor binary executed, parity UNVERIFIED.*
