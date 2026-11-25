---
id: LOAD-PROBE-RUN-01
title: "LOAD-PROBE-RUN-01 — one runner execution of t_load_usability.gd after the async-loader change (measurement log)"
owner: test-execution-worker
date: 2026-11-25
status: MEASUREMENT_ONLY__NO_PASS_CLAIM__RUN_COMPLETED
scope: "One variant-runner job (id loadprobe01-atom, ticket 531) plus this report. READ-ONLY on code and result JSON; no hand edits to any source file, atom, manifest, gate or result artifact."
owns:
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_RUN_01.md"
labels: [LOAD, POST_LOAD_USABILITY, RUNNER_JOB, MEASUREMENT_ONLY, NO_PASS_CLAIM]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
inputs_read:
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_01.md"
  - "docs/coord_swarm_2026-11-25/reports/LOAD_ASYNC_01.md"
  - "docs/coord_swarm_2026-11-25/RUN_GUIDE.md"
  - "variant3d/tests/t_load_usability.gd"
  - "variant3d/tools/godot_runner.py"
  - "variant3d/tools/smallmap_capture.py"
  - "variant3d/scripts/main.gd (read-only, for field-name cross-check)"
---

# LOAD-PROBE-RUN-01 — execution log / measurement

## 1. What was done

- Read `reports/LOAD_PROBE_01.md`, `reports/LOAD_ASYNC_01.md`, the atom
  `variant3d/tests/t_load_usability.gd` (args/launch contract at its `:27-32`),
  and `godot_runner.py status` before submitting.
- Submitted **exactly one** job through the **variant** runner with a fresh unique
  id. No re-submit, no queue mutation, no `cancel`/`reset`/`ack`/`unwedge`,
  no direct `godot` invocation. FIFO queue wait was allowed to run normally.
- Read back the runner result JSON, the captured stdout/stderr, the atom's
  `res://tests/results/t_load_usability.json`, and ran the required
  `smallmap_capture.py scan-stderr`. All result JSON was **read only** — no hand
  edits to code or to any result file.
- No source file was added, modified or deleted by this worker. The only files
  created by the job are runtime artifacts owned by the runner/atom
  (`variant3d/.godot_queue/results/00000531*` and
  `variant3d/tests/results/t_load_usability.json`), plus this exclusive report.

## 2. Command (as launched, Windows `python`, from repo root)

```bat
python variant3d\tools\godot_runner.py run --id loadprobe01-atom --timeout 300 --max-wait 3600 -- --headless --path variant3d --script res://tests/t_load_usability.gd -- --config res://tests/fixtures/small_map_64.json
```

Headless, as required: the atom itself drives the staged loader through the two
real menu handlers (`_apply_menu_cfg` + `_do_async_load` via `Object.call`,
atom `:265-273`), not through a windowed Start click.

## 3. Job data (observed)

| Field | Value | Source |
|---|---|---|
| job id | `loadprobe01-atom` | runner result JSON `00000531.json` |
| ticket | **531** | runner START/END lines; `00000531.json` |
| runner status | `ok` | `00000531.json` |
| runner exit | `0` | `00000531.json` (START/END lines confirm) |
| hard timeout | `300.0 s` | `00000531.json` (not reached) |
| `--max-wait` | `3600 s` | command line (not reached) |
| queue wait | **347.26 s** (`347.2623767852783`) | `00000531.json`; `[runner] ... START (waited 347.26s)` |
| run time | **134.34 s** (`134.341059923172`) | `00000531.json`; `[runner] ... END ok (run 134.34s)` |
| created (unix s) | `1795605183.1262615` | `00000531.json` |
| argv | `--headless --path variant3d --script res://tests/t_load_usability.gd -- --config res://tests/fixtures/small_map_64.json` | `00000531.json` |

Artifacts (observed, all read-only here):
- `variant3d/.godot_queue/results/00000531.json`
- `variant3d/.godot_queue/results/00000531_loadprobe01-atom/stdout.txt`
- `variant3d/.godot_queue/results/00000531_loadprobe01-atom/stderr.txt`
- `variant3d/tests/results/t_load_usability.json` (written by the atom at
  `stdout.txt:17`)

**Derived:** runner `exit=0` / `status=ok` means only "the Godot process exited 0
and the runner released the lock". It is **not** a gate result and **not** a PASS
claim; the atom's own verdict governs.

## 4. Atom result JSON (observed, read only)

- `id`: `t_load_usability`
- `verdict`: `MEASUREMENT_ONLY__NO_PASS_CLAIM`
- `gate_claim`: `NONE`, `pass_claim`: `false`
- `unix_ms`: `1795605663650.0`
- stdout tail: `T_LOAD_USABILITY RESULT_JSON: ...t_load_usability.json` then
  `T_LOAD_USABILITY VERDICT: MEASUREMENT_ONLY__NO_PASS_CLAIM` (`stdout.txt:17-18`).

### 4.1 Measured block (`measured`, observed)

| Key | Value |
|---|---|
| `display_server` / `headless` | `headless` / `true` |
| `boot_render_mode` | `3d` |
| `boot_map_tiles` | `[64, 64]` |
| `boot_seed` | `20261113` |
| `boot_game_before_async` | `false` |
| `fixture` | `res://tests/fixtures/small_map_64.json` |
| `boot_mode` | `atom-forced _do_async_load via Object.call (proxy for menu Start)` |
| `frames` | `1742` |
| `max_stage_to_stage_us` | `23262030` (≈ **23.26 s**) |

`real_64_game_boot` and `headless_guard` are `OBSERVED` / `met_criterion: true`:
the atom really booted the 64×64, seed-20261113 3D game through `main.tscn` and
ran headless.

### 4.2 Notes (observed)

1. `Async load driven by Object.call('_apply_menu_cfg') + Object.call('_do_async_load'); a real Start-button click / chosen signal is NOT exercised (main.gd:251-268).`
2. `wall-cap reached before completion; remaining assertions UNVERIFIED`

**Derived:** the atom's own `WALL_CAP_US = 120000000` (120 s, atom `:44`) fired
at frame 1742, ~14 s before the runner's 134.34 s total run (the remainder is
Godot shutdown). The run therefore ended on the probe's failsafe, **not** on a
completed hide→probes→stability sequence.

## 5. Measurements vs owner requirements

Criterion ids/statuses are quoted verbatim from the atom's `checks` array. No row
was promoted to PASS; `met_criterion: false` is reported as a negative
observation, `null` as UNVERIFIED.

| Req | id | status / met | Measured value in this run | Honest reading |
|---|---|---|---|---|
| (a) longest main-thread stall | `a_longest_main_thread_stall` | UNVERIFIED / `null` | proxies: `max_inter_frame_gap_loading_us=0`, `max_stage_to_stage_us=23262030` | Literal per-stage stall still needs `main.gd` instrumentation. The 23.26 s figure is a **wall-clock delta between observed `loading_stage` text changes**, not isolated main-thread busy time. The `0` gap is the **untouched default** (atom updates it only inside `if visible`, which never held) — it does **not** mean "no stall". |
| (b) bindings before overlay hide | `b_bindings_before_overlay_hide` | UNVERIFIED / `null` | `No overlay-hidden transition observed; cannot check binding order.` | No overlay-hide binding snapshot was captured: `_hide_snapshot`, `_bind_first`, `overlay_visible_frames`, `overlay_hidden_us`, `hide_frame`, `stage_log` and `overlay_lifetime_us` are **absent** from `measured` (the atom writes them only in its hide-transition branch, atom `:302-315`, which never fired). |
| (c) input response | `c_input_response` | UNVERIFIED / `null` | `No live player-0 unit found for a selection/order probe.` | Probe never began; no `selected_ids` observation. Real mouse events are UNVERIFIED regardless (proxy only). |
| (c) order response | `c_order_response` | UNVERIFIED / `null` | `No live player-0 unit found for an order probe.` | No `unit.order.type` observation. |
| (c) camera response | `c_camera_response` | OBSERVED / **`false`** | `apply_external_target -> _target/global_position changed at frame -1 (window=30)` | **Negative observation:** no change was seen; frame `-1` means `apply_external_target` was never issued because `_begin_probes()` was never called. Do not read as a passed response. |
| (d) no deferred heavy stage | `d_no_deferred_heavy_stage` | UNVERIFIED / `null` | detail string retained literal `%d` placeholders (see §6.2) | Stability phase never entered; no violations/gap numbers exist. Literal claim has no observable anyway (`LOAD_PROBE_01.md` limitation 5). |
| (e) no hard engine errors | `e_no_hard_engine_errors` | UNVERIFIED / `null` | external stderr scan required | See §6.1: literal `SCRIPT ERROR` count = 0; a **runtime** GDScript ERROR from the probe itself was present. |
| overlay seen | `staged_overlay_observed` | UNVERIFIED / **`false`** | `overlay_frames=0 stage_transitions=15 first=Preparing... last=<none>` | 15 distinct `loading_stage` texts were observed (first `Preparing...`, last `<none>`, consistent with the overlay later being hidden), but `loading_active && loading_layer` was never sampled true, so `overlay_frames=0`. |
| no PASS claim | `no_pass_claim` | OBSERVED / `true` | `verdict=MEASUREMENT_ONLY__NO_PASS_CLAIM; this atom is not a gate.` | Upheld. |

**Derived overall:** of the five owner-requested properties (a)–(e), none was
established at runtime by this run. (c)-camera produced a measured *non-response*
and (a) produced a large timing proxy; both remain non-gate measurements.

## 6. stderr scan and error triage

Command (Windows `python`, from repo root):

```bat
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000531_loadprobe01-atom\stderr.txt
```

### 6.1 `SCRIPT ERROR` scan (observed)

```json
[{"path": "variant3d\\.godot_queue\\results\\00000531_loadprobe01-atom\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```

`script_error_lines == 0` — the atom's (e) precondition on literal `SCRIPT ERROR`
parse errors is satisfied. **However**, honesty requires also recording a
**runtime** ERROR line that the scan does not classify as `SCRIPT ERROR`:

```
ERROR: String formatting error: not all arguments converted during string formatting.
   at: validated_evaluate (core/variant/variant_op.h:770)
   GDScript backtrace (most recent call first):
       [0] _finish (res://tests/t_load_usability.gd:518)
       [1] _process (res://tests/t_load_usability.gd:226)
```
(`stderr.txt:59-63`, observed.) This originates **inside the probe's own
`_finish()`**, not in game code; it is consistent with the wall-cap branch at
atom `:226` and the unsubstituted detail string in §6.2. It did not stop the atom
from writing the result JSON and exiting 0. Judged per `RUN_GUIDE.md:102`, this is
not a `SCRIPT ERROR` parse failure, but it **is** a real probe-side defect and is
reported as such — no "clean stderr" claim is made.

### 6.2 Other stderr content (observed, classified)

- `WARNING: T-MINES-FIX: no open iron site near start (61,5)` — `pattern_gen.gd:676`
  via `_gen_base`/`_do_async_load`: known expected generation warning.
- Three `Loaded resource as image file ... will not work on export` warnings for
  `tile_index_atlas.png`, `alpha.png`, `alphavert.png` plus `mill_rotor.png` —
  expected per `RUN_GUIDE.md:108` / `PROGRESS.md` error classes; not
  `SCRIPT ERROR`s.
- `world3d_entities: DONOR-SAMPLED FLAT-ROOT MORPH — PORT APPROXIMATION` — the
  documented expected label (`RUN_GUIDE.md:98`).
- `3 ObjectDB instances were leaked at exit` and `1 resources still in use at
  exit` — expected exit-time cleanup noise (`RUN_GUIDE.md:102`).
- Atom `(d)` detail string in the result JSON literally reads:
  `No deferred-stage API exists to inspect. Proxies over %d frames: violations=%d, max_inter_frame_gap_post_us=%d (heuristic ceiling %d)`
  — all four `%d` placeholders unsubstituted, the direct symptom of the
  `_finish:518` formatting ERROR above. No numeric (d) proxies were produced.

## 7. Interpretation and limits (labelled)

- **Observed:** one completed runner job with `exit=0`/`ok`; atom verdict
  `MEASUREMENT_ONLY__NO_PASS_CLAIM`, `gate_claim: NONE`, `pass_claim: false`;
  boot and headless assertions true; 15 stage-text transitions; a 23.26 s max
  stage-to-stage wall-clock proxy; no overlay-visible frame sampled; no hide
  snapshot; no unit found for input/order probes; camera non-response at frame
  -1; wall-cap termination; zero literal `SCRIPT ERROR` lines; one probe-side
  runtime formatting ERROR.
- **Derived:** the 134.34 s run ended on the atom's own 120 s wall-cap, so the
  hide→probes→stability phases were never reached; most (b)/(c)/(d) rows are
  UNVERIFIED for that reason, not because a criterion was weakened.
- **Inferred (not proven):** the `<none>` final stage text is consistent with
  `_hide_loading()` having run (`main.gd:517-524` sets `loading_stage = null`),
  i.e. the loader may have finished while the atom still never sampled
  `visible=true`; the atom's `visible` gate (`loading_active && loading_layer
  valid`, atom `:281-284`) is a plausible point of failure. Cross-check
  (observed) confirms those field names still exist in `main.gd:148-157`,
  `_do_async_load` sets `loading_active = true` at `:538` and calls
  `_show_loading()` at `:543`, so this is a **probe observation/timing issue,
  not evidence that LOAD-ASYNC-01 renamed its flags**. Cause UNVERIFIED — would
  need atom-side instrumentation or a second run, which this task does not
  authorise.
- **UNVERIFIED:** real Start-button click path; window movability/paint during
  load (headless cannot test R3 — `RUN_GUIDE.md`, `LOAD_PROBE_01.md` limitation 3);
  exact per-stage main-thread stall (a); literal deferred-stage absence (d);
  real synthetic mouse/key input; FX readiness; hard engine errors beyond the
  literal `SCRIPT ERROR` scan.

## 8. Verdict

**MEASUREMENT_ONLY__NO_PASS_CLAIM — upheld, not promoted.** The runner job is
complete and the atom wrote its measurements, but the measurement set is
**incomplete relative to the atom's own design**: it terminated on its 120 s
wall-cap before the overlay-hide transition, so the binding snapshot, post-hide
input/order/camera probes and post-hide stability poll were not produced. No PASS,
no gate claim, no green result is asserted by this worker. This report is a
measurement log only.

## 9. Open questions

1. Why did `overlay_frames` stay 0 while 15 `loading_stage` transitions were
   observed (ending `<none>`)? Owner of the atom (LOAD-PROBE-01) should decide
   whether the `visible` gate or the frame-ordering between the atom's `_process`
   and `_loading_tick`'s `process_frame` awaits is at fault. Not retried here.
2. Should the probe's 120 s `WALL_CAP_US` be raised, or its wall-clock counter
   started later, so the hide→probes→stability phases can complete on this
   machine (observed ~69 ms/frame; `stdout.txt:3` shows one `sync_ms=356.77`
   tick)? Any change belongs to LOAD-PROBE-01, not this worker.
3. Can the `_finish:518` string-format ERROR be fixed in the atom so (d) produces
   real numeric proxies? (Probe-owned; read-only here.)
4. Is the 23.26 s `max_stage_to_stage_us` proxy a genuine long stage, an artefact
   of the wall-clock frame pump, or both? Literal (a) still requires
   `main.gd`-side instrumentation owned by LOAD-ASYNC-01.
5. Is a windowed follow-up with a real Start click acceptable to test R3
   (window movability) and the real click path? Headless cannot answer either.
6. Should UX_LOADING.md set a numeric responsiveness budget so the probe's
   30-frame / 250 ms probe parameters stop being heuristics (`LOAD_PROBE_01.md`
   open questions 3–4)?

## 10. Summary

- **Observed:** one `loadprobe01-atom` job (ticket 531, `ok`, `exit=0`) ran after
  the async-loader change: 347.26 s FIFO wait, 134.34 s run. It booted the real
  64×64/seed-20261113 3D game headless, observed 15 loading-stage text changes,
  and wrote `t_load_usability.json` with verdict
  `MEASUREMENT_ONLY__NO_PASS_CLAIM`, `gate_claim: NONE`, `pass_claim: false`.
- **Observed limits:** the atom hit its own 120 s wall-cap at frame 1742, so
  `overlay_frames=0`, no overlay-hide binding snapshot, no unit for input/order
  probes, camera non-response at frame -1, and no post-hide stability numbers
  were produced. `scan-stderr` found 0 literal `SCRIPT ERROR` lines, but the
  probe emitted its own runtime string-format ERROR at `t_load_usability.gd:518`.
- **Derived:** no owner requirement (a)–(e) was established at runtime by this
  run; the only positive numeric proxy is a 23.26 s wall-clock stage-to-stage gap
  whose interpretation remains open.
- **Not claimed:** no PASS, no gate result, no "clean run" claim. No source file
  or result JSON was hand-edited; this report is the sole authored output.
