---
id: LOAD-PROBE-REPAIR-01
title: "LOAD-PROBE-REPAIR-01 — harness repair + one validation run of t_load_usability.gd (measurement, no PASS claim)"
owner: test-atom repair builder
date: 2026-11-25
status: MEASUREMENT_ONLY__NO_PASS_CLAIM__REPAIR_VALIDATED
scope: "Exclusive ownership: variant3d/tests/t_load_usability.gd + this report, plus the mandated backup inbox/backup/t_load_usability.gd.bak-LOADPROBEREPAIR. One variant-runner job only. No main.gd, other atom, config, gate, manifest or result JSON hand-edit; no queue mutation; no direct godot."
owns:
  - "variant3d/tests/t_load_usability.gd"
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_REPAIR_01.md"
labels: [LOAD, POST_LOAD_USABILITY, HARNESS_REPAIR, RUNNER_JOB, MEASUREMENT_ONLY, NO_PASS_CLAIM]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
inputs_read:
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_RUN_01.md"
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_01.md"
  - "docs/coord_swarm_2026-11-25/RUN_GUIDE.md"
  - "variant3d/tests/t_load_usability.gd"
  - "variant3d/scripts/main.gd (read-only)"
  - "variant3d/scripts/camera3d.gd, input_controller.gd, game.gd, data.gd (read-only)"
  - "variant3d/tools/godot_runner.py, smallmap_capture.py"
---

# LOAD-PROBE-REPAIR-01 — repair log and single validation run

## 1. What was done

- Read the run evidence `LOAD_PROBE_RUN_01.md` and the atom, then made **only**
  minimal harness repairs in `variant3d/tests/t_load_usability.gd` (§3).
- Backed the atom up **before** any edit (§2).
- Submitted **exactly one** job via the **variant** runner, unique id
  `loadproberepair01-run`, `--timeout 300 --max-wait 3600`, headless. No retry,
  no re-submit, no `cancel`/`reset`/`ack`/`unwedge`, no direct `godot`.
- Read back the runner result JSON, stdout, stderr and the atom's result JSON
  (read-only), and ran `smallmap_capture.py scan-stderr` on the job stderr.
- No criterion was weakened and no PASS was fabricated (§8). Verdict remains
  `MEASUREMENT_ONLY__NO_PASS_CLAIM`, `gate_claim: NONE`, `pass_claim: false`.

## 2. Backup (observed)

| Item | Value |
|---|---|
| Source | `variant3d/tests/t_load_usability.gd` (pre-repair, 578 lines) |
| Backup | `inbox/backup/t_load_usability.gd.bak-LOADPROBEREPAIR` |
| Verification | SHA-256 of backup and pre-edit source both `60EF98D6E8CA0D449ADE16C749F3290972C381442B2966A269D49C9F3937C209` (identical) |

## 3. Defect diagnosis and before → after line map

Root cause of `overlay_frames=0` (observed in code, confirmed by the new run):
`main.gd:_show_loading()` calls `_hide_loading()` (`:463`), whose first statement
clears `loading_active = false` (`:518`). `_do_async_load()` sets the flag true at
`:538` and then immediately calls `_show_loading()` at `:543`, so the flag is
**false for the entire staged load**. The old atom gated overlay sampling on
`loading_active && loading_layer` (old `:281-284`), so it never sampled the
overlay, never saw the hide transition, and spun in `_phase_loading()` until its
own 120 s wall-cap. `main.gd` was **not** edited (owned by LOAD-ASYNC-01).

| # | Repair | Before (backup) lines | After lines | Effect |
|---|---|---|---|---|
| 1 | Repair note / ownership comment | `:8-10` | `:12-21` | Documents the repairs; no behaviour change. |
| 2 | Phase comment corrected | `:71` | `:71` | Comment only. |
| 3 | New diagnostic counters `_overlay_flag_true_frames`, `_overlay_stage_true_frames`, `_load_ready_seen`, `_camera_request_issued` | — | `:91-94` | Raw flags recorded, not used to relax a gate. |
| 4 | Overlay sampled from **first** `_process()` frame: `_phase_loading()` moved out of the `match` and called unconditionally when `_phase == 2` | `:232-241` | `:247-261` (call at `:259-260`) | No lost first-appearance / hide transition between phases. |
| 5 | Node-based overlay presence: `visible := layer_ok or stage_ok`; raw `loading_active` counted separately; `load_ready` observed | `:279-300` | `:299-333` (gate at `:301-315`) | Overlay now observable despite the game-side flag bug. |
| 6 | Hide snapshot fields extended with raw flag counts and `load_ready_seen_at_hide` | `:302-314` | `:335-350` | Diagnosable hide evidence. |
| 7 | Camera request guaranteed distinguishable from current focus; `_camera_request_issued` set and real `apply_external_target()` called unconditionally; before/request targets recorded | `:336-352`, `:354-356` | `:391-405`, `:416-427` | Frame `-1` cause removed; request is now real and recorded. |
| 8 | Player-0 unit fallback through existing sim API `game.spawn("peasant", 0, pos)` (`game.gd:2198`) if no live unit exists; `probe_unit_created_by_atom` recorded | — | `:371-390`, `:423` | No game-code edit; unit is real sim state. |
| 9 | Raw counters also written in `_finish()` so the wall-cap path is diagnosable | `:435-440` | `:506-518` (`:509-515`) | Failure no longer looks like "no overlay ever existed". |
| 10 | `c_input_response` detail string parenthesised (`%d` fix) | `:502-503` | `:580-581` | Removes one latent format ERROR. |
| 11 | `c_camera_response` branch: `UNVERIFIED` if no request issued, else `OBSERVED` | `:510-514` | `:588-597` | Stricter, not weaker. |
| 12 | `d_no_deferred_heavy_stage` detail string parenthesised — the reported `t_load_usability.gd:518` "String formatting error" | `:519-521` | `:601-604` | Literal `%d` placeholders replaced by real numbers. |

Two format expressions had the same latent defect (old `:502-503`, old `:519-521`):
GDScript binds `%` tighter than `+`, so `% [...]` applied only to the trailing
string literal. Both concatenations are now parenthesised before formatting.
No other line of the atom was changed. All criterion constants are unchanged:
`RESPONSE_FRAMES=30`, `STABILITY_FRAMES=30`, `MAX_FRAMES=3600`,
`WALL_CAP_US=120000000` (120 s), `STALL_LIMIT_US=250000`, `POS_TOL_M=1.0`.

## 4. Validation job (observed)

Launch (Windows `python`, from repo root, exactly one invocation):

```bat
python variant3d\tools\godot_runner.py run --id loadproberepair01-run --timeout 300 --max-wait 3600 -- --headless --path variant3d --script res://tests/t_load_usability.gd -- --config res://tests/fixtures/small_map_64.json
```

| Field | Value | Source |
|---|---|---|
| job id | `loadproberepair01-run` | `00000547.json` |
| ticket | **547** | runner START/END; `00000547.json` |
| runner status / exit | `ok` / `0` | `00000547.json` |
| hard timeout | `300.0 s` (not reached) | `00000547.json` |
| `--max-wait` | `3600 s` (not reached) | command line |
| FIFO wait | **237.04 s** (`237.0374858379364`) | `00000547.json`; START line |
| run time | **91.88 s** (`91.8800950050354`) | `00000547.json`; END line |
| created (unix s) | `1795606935.1738272` | `00000547.json` |
| argv | `--headless --path variant3d --script res://tests/t_load_usability.gd -- --config res://tests/fixtures/small_map_64.json` | `00000547.json` |

Artifacts (read-only here): `variant3d/.godot_queue/results/00000547.json`,
`.../00000547_loadproberepair01-run/stdout.txt`,
`.../00000547_loadproberepair01-run/stderr.txt`, and
`variant3d/tests/results/t_load_usability.json` (written by the atom at
`stdout.txt:3`). stdout tail:
`T_LOAD_USABILITY RESULT_JSON: ...t_load_usability.json` then
`T_LOAD_USABILITY VERDICT: MEASUREMENT_ONLY__NO_PASS_CLAIM` (`stdout.txt:3-4`).
`exit=0`/`ok` means only "process exited 0 / lock released", not a gate result.

## 5. Atom result — exact measured fields (observed, read only)

- `id`: `t_load_usability`; `verdict`: `MEASUREMENT_ONLY__NO_PASS_CLAIM`;
  `gate_claim`: `NONE`; `pass_claim`: `false`; `unix_ms`: `1795607262024.0`.
- `frames`: **60** (before: 1742). **No wall-cap note in `notes`** — the only
  note is the unchanged Start-click-proxy limitation. The probe completed its
  hide → probes → stability sequence inside its own 120 s cap.

| Field | Before (ticket 531) | After (ticket 547) |
|---|---|---|
| `overlay_visible_frames` | 0 | **28** |
| `overlay_stage_valid_frames` | absent | 28 |
| `overlay_flag_active_frames` | absent | **0** (confirms the `loading_active` bug) |
| `overlay_first_us` | absent | `5443043` |
| `overlay_hidden_us` | absent | `46638551` |
| `overlay_lifetime_us` | absent | `41195508` (~41.20 s) |
| `hide_frame` | absent | **29** |
| `load_ready_seen_at_hide` | absent | `true` |
| `stage_log` | absent | 15 transitions, first `Preparing...`, last `<none>` |
| `max_stage_to_stage_us` | `23262030` (~23.26 s) | **`21481471` (~21.48 s)** |
| `max_gap_loading_us` | 0 (untouched default) | `21481301` (~21.48 s, real sample) |
| `hide_snapshot.all_bound` | absent | `true`; `missing_or_late=[]` |
| `bind_first_frame` | absent | game 3, world 19, camera 21, hud 23, input 25 — all ≤ 25 < hide 29 |
| `probe_unit_found` | absent | `true` |
| `probe_unit_created_by_atom` | absent | `false` (a real live player-0 unit existed; fallback not used) |
| `camera_request_issued` | absent | `true` |
| `camera_target_before` → `requested` | absent | `[103.74, 41.44]` → `[72.0, 64.0]` |
| `response_frames` input/order/camera | absent / camera `-1` | **1 / 1 / 1** (window 30) |
| `stability_violations` | absent | **11** |
| `max_gap_post_us` | absent | `33515827` (~33.52 s; heuristic ceiling 250000) |
| `order_dest_requested` | absent | `[128.0, 15.36]` |

The `(d)` detail string is now numeric (no literal `%d`):
`No deferred-stage API exists to inspect. Proxies over 30 frames: violations=11, max_inter_frame_gap_post_us=33515827 (heuristic ceiling 250000)`.

## 6. Criteria — now measured vs still UNVERIFIED

| Req | id | Status / met (after) | Honest reading |
|---|---|---|---|
| — | `headless_guard`, `real_64_game_boot` | OBSERVED / `true` | Headless, real 64² / seed 20261113 / 3D boot through `main.tscn`. |
| — | `staged_overlay_observed` | **OBSERVED / `true`** (was UNVERIFIED / `false`) | `overlay_frames=28`, 15 stage transitions. First appearance and hide were sampled. |
| (a) | `a_longest_main_thread_stall` | **UNVERIFIED / `null`** (unchanged) | Literal per-stage busy time still needs `main.gd` instrumentation (LOAD-ASYNC-01). Proxies are now **real**: ~21.48 s max inter-frame gap and ~21.48 s stage-to-stage wall delta. These are *not* isolated main-thread time. |
| (b) | `b_bindings_before_overlay_hide` | **OBSERVED / `true`** (was UNVERIFIED / `null`) | Measured at `hide_frame=29`: all 19 binding flags true, `all_bound_at_hide=true`, `missing_or_late=[]`, every first-seen frame ≤ 25. The real Start-click ordering is still UNVERIFIED (forced-call proxy). |
| (c) | `c_input_response` | **OBSERVED / `true`** (was UNVERIFIED / `null`) | `selected_ids` contained the probe unit at post-hide frame 1 of 30. Proxy: direct `_set_selection()`; real injected mouse events remain UNVERIFIED. |
| (c) | `c_order_response` | **OBSERVED / `true`** (was UNVERIFIED / `null`) | `unit.order.type ∈ {move,attack_move}` at frame 1 of 30 via `minimap_order()`. Same input-proxy limitation. |
| (c) | `c_camera_response` | **OBSERVED / `true`** (was OBSERVED / **`false`** at frame `-1`) | A real `apply_external_target([72,64])` request was issued and `_target`/`global_position` changed by post-hide frame 1 of 30. |
| (d) | `d_no_deferred_heavy_stage` | **UNVERIFIED / `null`** (unchanged) | Literal claim has no observable in `main.gd`. Numeric proxies were produced for the first time and **breach the heuristic**: `violations=11`, `max_gap_post_us=33515827` ≫ `250000`. This is an honest negative proxy observation, not a PASS and not a proven game fault. |
| (e) | `e_no_hard_engine_errors` | **UNVERIFIED / `null`** (unchanged) | GDScript cannot read stderr. External scan (§7) found `script_error_lines == 0`; the atom emits a runtime ERROR only if one actually occurs (none did here). |
| — | `no_pass_claim` | OBSERVED / `true` | Verdict/gate/pass fields unchanged. |

**Derived overall:** (b) and all three (c) rows are now genuinely measured OBSERVED
rows; (a), (d) and (e) remain UNVERIFIED exactly as designed. Nothing was
promoted to PASS and no gate was asserted. The (d) proxy breach is reported, not
explained away.

## 7. stderr scan and error triage

Command (Windows `python`, from repo root):

```bat
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000547_loadproberepair01-run\stderr.txt
```

Observed result:

```json
[{"path": "variant3d\\.godot_queue\\results\\00000547_loadproberepair01-run\\stderr.txt",
  "exists": true, "script_error_lines": 0, "lines": []}]
```

- **`SCRIPT ERROR` count: 0** (required precondition satisfied).
- A direct text scan found **no** `String formatting error`, **no**
  `t_load_usability.gd:` backtrace, and **no** `SCRIPT ERROR` line. The ticket-531
  runtime ERROR at old `:518` is gone; both format sites now substitute correctly.
- Remaining stderr is expected noise only (classified per `RUN_GUIDE.md:94-103,
  131`): `T-MINES-FIX` warning at `pattern_gen.gd:676`; image-as-resource warnings
  for `tile_index_atlas.png`, `alpha.png`, `alphavert.png`, `mill_rotor.png`;
  `DONOR-SAMPLED FLAT-ROOT MORPH — PORT APPROXIMATION` label; exit-time
  `3 ObjectDB instances were leaked at exit` and
  `ERROR: 1 resources still in use at exit`. **No "clean stderr" claim is made** —
  the exit-time `ERROR:` line is present and reported.

## 8. No-weakening statement

- All six probe constants and all 30-frame / 250 ms / 1 m windows are byte-for-byte
  unchanged (§3). The 120 s `WALL_CAP_US` was **not raised**.
- Every `_record()` id, `citation`, `status` vocabulary and `met_criterion`
  semantic is unchanged; (a), (d) and (e) remain `UNVERIFIED / null`.
- The overlay gate was changed from a broken game flag to the **real overlay
  nodes**. This removes a false "not observed" result; it does not make any
  assertion easier to satisfy — `staged_overlay_observed` still needs ≥1 overlay
  frame **and** ≥2 stage transitions, and (b) still requires every binding flag
  true at hide with first-seen frame ≤ hide frame.
- The camera row is *stricter*: if no request is issued it is now `UNVERIFIED`
  instead of an automatic `OBSERVED/false`.
- The player-0 unit fallback uses the existing `game.spawn()` sim API inside the
  atom; it creates real sim state and does not fabricate a response. In this run
  it was **not needed** (`probe_unit_created_by_atom: false`).
- The (d) numeric proxies are honestly reported as breaching the heuristic. No
  result was hand-edited; the atom wrote its own JSON.

### Wall-cap / phasing outcome

The previous cap hit was not a slow load alone: the atom spun for ~90 s on a
hidden overlay because `loading_active` was never true. Sampling overlay nodes
from the first `_process()` frame detected hide at frame 29 and completed all
phases at frame 60 (~91.88 s run including Godot startup/shutdown), so **no
windowed run was required for this repair**. A windowed run is still required for
the owner's R3 (real title-bar drag / window paint during load) and for the real
Start-button click path; headless cannot answer those and this report claims
nothing about them.

## 9. Open questions

1. `main.gd:_show_loading()` clears `loading_active` via `_hide_loading()` at
   `:463` immediately after `_do_async_load()` sets it at `:538`. Is that a
   game-side bug for LOAD-ASYNC-01 to fix? Not edited here; the atom now works
   around it with node-based observation and records `overlay_flag_active_frames=0`.
2. Are the ~21.48 s load-stage gap and the ~33.52 s post-hide gap real heavy
   work / post-overlay blocking (the owner's R5 symptom) or headless frame-pump
   artefacts? Literal (a) still needs `main.gd` instrumentation; (d) remains a
   proxy with a breached heuristic.
3. `stability_violations=11` over 30 frames — does this warrant a dedicated
   follow-up probe (e.g. per-frame gap log) to locate the stalls? No PASS or
   root-cause claim is made here.
4. A windowed follow-up with a real Start click is still needed for R3 and for
   the click/signal path; headless cannot test either.
5. No numeric owner/UX budget exists for the 30-frame / 250 ms probe parameters;
   they remain labelled heuristic probe parameters, not spec constants.
6. Should the `loading_active` flag bug and the overlay-node observation strategy
   be reflected in LOAD-ASYNC-01's own report by that owner?

## 10. Summary

- **Observed:** one runner job (`loadproberepair01-run`, ticket 547, `ok`,
  `exit=0`, 237.04 s queue wait, 91.88 s run) after 12 minimal harness repairs in
  `variant3d/tests/t_load_usability.gd`; backup taken and hash-verified first.
- **Observed:** the probe now completes all phases in 60 frames without hitting
  its 120 s cap: 28 overlay-visible frames, hide at frame 29 with
  `all_bound=true`/`missing_or_late=[]`, input/order/camera responses at frame 1
  of 30, and numeric (d) proxies. `staged_overlay_observed`, (b) and all three (c)
  rows are now OBSERVED/`true`; (a), (d), (e) remain UNVERIFIED as designed.
- **Observed:** `scan-stderr` → `script_error_lines == 0`; no `SCRIPT ERROR`, no
  formatting ERROR, no atom backtrace. Expected warnings plus one exit-time
  resource `ERROR` remain and are reported, not hidden.
- **Derived:** both reported `%d` defects are fixed; the `overlay_frames=0` and
  camera `-1` defects were downstream of the broken `loading_active` flag and
  the never-reached `_begin_probes()`, both now addressed in the atom only.
- **Not claimed:** no PASS, no gate result, no clean-stderr claim, no windowed
  responsiveness result, no game-code fix.
- **File ownership:** this worker edited **only**
  `variant3d/tests/t_load_usability.gd` and authored **only** this report, plus
  the mandated backup file. No `main.gd`, other atom, config, manifest, gate or
  result JSON was hand-edited; no result JSON was generated by hand. Other
  changed files visible in `git status` are concurrent swarm work, not this
  worker's edits.
