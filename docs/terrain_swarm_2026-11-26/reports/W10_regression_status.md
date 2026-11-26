---
id: W10
swarm: TERRAIN-VISUAL-WAVE-2026-11-26
title: "W10 — current regression status after COORD gate runs"
agent: "W10 (read-only regression witness, reporting to COORD)"
owner_file: docs/terrain_swarm_2026-11-26/reports/W10_regression_status.md
status: DELIVERED__READ_ONLY__NO_RUNNER_JOB__NO_GODOT__NO_GIT_EDIT__NO_PARITY_CLAIM
created: 2026-11-26
snapshot: "2026-11-26T11:22:02+01:00"
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
---

# W10 — current regression status

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

## 0. Scope and method

- Read-only audit of the charter, V21/V42/V112, runner result JSONs, result artifacts, source mtimes and current gate JSONs. **No runner subcommand, Godot process, gate, capture, code/shader/config/test edit or git edit was run.** Exactly one file was written: this report.
- `SCRIPT ERROR` counts below use the same literal rule as `variant3d/tools/smallmap_capture.py:55`: stderr lines containing `SCRIPT ERROR`.
- All times are **2026-11-26, +01:00**. Result mtime is the mtime of `variant3d/.godot_queue/results/<ticket>.json`, not the game result JSON.
- Freshness is judged against **job START**, not only result mtime. A job that started before a source edit can finish afterward with old bytes loaded.

## 1. Bottom line

| State | Current finding |
|---|---|
| **GREEN — fresh** | ACK 575/582/585 landed; `t_map_variety` **638 `v42j-mapvariety` 5/5**, `script_error_lines=0`, started after the latest production edit. Direct spool preconditions are settled: `counter=now_serving=640`, `jobs/` empty, lock absent, history 500, zero unacked leak rows. |
| **RED — fresh** | `t_terrain_donor` **639 `v42k-donor-atom2` FAIL 22/25**, `script_error_lines=0`. Three class-A failures remain: `no_synthetic_noise_field`, `vertex_count_exact`, `triangle_count_exact`. |
| **GREEN BUT STALE — not sign-off evidence** | selftest **631 29/29**; `t_render_mode` **630 10/10**; uitest **637 17/17**; parse-inputs/composer **634/635**; windowed capture **636** (`ok`, 0 script errors). All started before the **11:15:54 shader edit**. |
| **RED / invalid evidence** | Donor atom 629 is stale FAIL 17/25. Capture 632 failed with 93 script errors and no final PNG. Capture 633 has `ok` envelope but one script error and is stale. Jobs 625/626/627 have malformed argv and did **not** execute their named tests. |
| **NOT RUN / UNCLAIMED** | No actual `assert_clean.py --json` output artifact was found, so CLEAN is not witnessed. No six determinism dumps, no `scan_map.py`, no post-shader parse/compile smoke, no fresh final selftest/uitest/render-mode/capture. New `t_terrain_donor_diag.gd` has no runner result. |

## 2. Freshness cutoff — latest named production edits

| Source edit | Observed mtime | Effect |
|---|---:|---|
| `variant3d/shaders/terrain_donor_shader.gdshader` (shader W04 edit) | **11:15:54** | Latest named production edit; jobs starting before this are stale for final-tree sign-off. |
| `variant3d/scripts/terrain_donor_inputs.gd` (I17) | 10:57:51 | Stales earlier input/composer/capture evidence. |
| `variant3d/scripts/terrain_donor_props.gd` (props fix) | 10:56:58 | Stales earlier props/donor/capture evidence. |
| `variant3d/scripts/terrain_donor_mesh.gd` | 10:56:10 | Included in the same final-tree cutoff. |
| `variant3d/scripts/terrain_donor_world.gd` | 10:56:51 | Included in the same final-tree cutoff. |

**Cutoff used below: 11:15:54.** Thus 607–637 are stale; 638 and 639 are new. Ticket 633 is a useful proof that START matters: it started at 10:57:22, before the I17 fix at 10:57:51, and loaded the old `U64_MASK` code even though its result JSON mtime is 10:58:01. The separate diagnostic `variant3d/tests/t_terrain_donor_diag.gd` appeared at 11:21:23; it is not a production input consumed by 638/639 and has not been run.

## 3. ACK / CLEAN

| Ticket / historical job id | Historical status | Result JSON mtime | ACK state | Pass/fail | `SCRIPT ERROR` lines | Interpretation |
|---|---|---:|---|---:|---:|---|
| 575 `bbclamptidy01-parse` | `timed-out`, exit -9 | 10:31:52 | `acknowledged=true`; reason and `ack_at` present | N/A — retired diagnostic | 0 | Retirement only; not a parse PASS. |
| 582 `terrainswarm-g1-selftest` | `skipped`, no exit | 10:32:10 | `acknowledged=true`; reason and `ack_at` present | N/A — never ran | 0 | Retirement only; not a selftest PASS. |
| 585 `g04-uitest` | `timed-out`, exit -9 | 10:32:12 | `acknowledged=true`; reason and `ack_at` present | N/A — retired diagnostic | 0 | Retirement only; not a uitest PASS. |
| **CLEAN** | No job id; non-runner action | **N/A — no result JSON** | History: 500 rows, 41 failure-status rows, **0 unacked**; jobs 0; lock absent; counters 640/640 | N/A | N/A | **Direct preconditions are clean, but no actual `assert_clean --json` verdict/output was found. CLEAN remains unwitnessed/unclaimed.** |

`failed` is outside `assert_clean.py`'s leak set, so the red donor atom 639 does not itself make runner hygiene DIRTY. That does not make the donor gate green.

## 4. Runner ledger — 607 through 639

`1/1` for a parse row means one parse smoke passed; it is not a gameplay gate. `N/A` means the named test/capture did not produce a countable test result.

| Ticket / exact job id | Runner status / exit | Result JSON mtime | Pass/fail | `SCRIPT ERROR` lines | Freshness / note |
|---|---|---:|---:|---:|---|
| 607 `v42-parse-data` | failed / 1 | 10:32:55 | 0/1 | 2 | STALE — float encode/decode arity. |
| 608 `v42-parse-gen` | failed / 1 | 10:33:13 | 0/1 | 38 | STALE — `C3TerrainData` unresolved. |
| 609 `v42-parse-mesh` | ok / 0 | 10:33:29 | 1/1 | 0 | STALE. |
| 610 `v42-parse-props` | failed / 1 | 10:33:48 | 0/1 | 4 | STALE — `String.to_lowercase` unavailable. |
| 611 `v42-parse-world` | ok / 0 | 10:34:01 | 1/1 | 0 | STALE. |
| 612 `v42-parse-main` | ok / 0 | 10:34:16 | 1/1 | 0 | STALE. |
| 613 `v42-parse-seam-world` | ok / 0 | 10:34:31 | 1/1 | 0 | STALE. |
| 614 `v42-parse-tdonor` | failed / 1 | 10:34:50 | 0/1 | 12 | STALE — arity/type/UV2/inference errors. |
| 615 `v42-relief-props-atom` | failed / 1 | 10:35:07 | 0/1 parse | 1 | STALE — `boot_ok` inference; check-only, not runtime atom. |
| 616 `v42b-parse-data` | ok / 0 | 10:36:55 | 1/1 | 0 | STALE. |
| 617 `v42b-parse-gen` | failed / 1 | 10:37:07 | 0/1 | 38 | STALE — `C3TerrainData` unresolved. |
| 618 `v42b-parse-props` | ok / 0 | 10:37:18 | 1/1 | 0 | STALE. |
| 619 `v42b-parse-tdonor` | failed / 1 | 10:37:29 | 0/1 | 7 | STALE — type/UV2/inference errors. |
| 620 `v42b-relief-props` | ok / 0 | 10:37:43 | 1/1 parse | 0 | STALE — check-only, not runtime atom. |
| 621 `v42c-parse-gen` | failed / 1 | 10:39:13 | 0/1 | 9 | STALE — `decode_s32`/float arity and `sqrtf`. |
| 622 `v42c-parse-tdonor` | ok / 0 | 10:39:21 | 1/1 | 0 | STALE. |
| 623 `v42d-parse-gen` | failed / 1 | 10:39:58 | 0/1 | 2 | STALE — `encode_float` arity. |
| 624 `v42e-parse-gen` | ok / 0 | 10:40:50 | 1/1 | 0 | STALE. |
| 625 `v42-shader-smoke` | ok / 0 | 10:44:36 | **N/A — no test executed** | 0 | STALE + INVALID ARGV — whole command/path split incorrectly. No shader-smoke proof. |
| 626 `v42-donor-atom` | ok / 0 | 10:44:48 | **N/A — no test executed** | 0 | STALE + INVALID ARGV — one string instead of argv. No donor-atom result. |
| 627 `v42-rendermode` | ok / 0 | 10:44:59 | **N/A — no test executed** | 0 | STALE + INVALID ARGV — one string instead of argv. No 10/10 result. |
| 628 | — | — | — | — | No result JSON and no history row; not a gate. |
| 629 `v42f-donor-atom` | failed / 1 | 10:48:33 | **17/25** | 1 | STALE — detailed below. |
| 630 `v42g-rendermode` | ok / 0 | 10:50:56 | **10/10** | 0 | STALE — real test, but pre-props/I17/shader edits. |
| 631 `v42g-selftest` | ok / 0 | 10:52:17 | **29/29** | 0 | STALE — real test, but pre-props/I17/shader edits. |
| 632 `v42-cap-donor-240` | failed / 1 | 10:54:12 | N/A — capture failed | 93 | STALE + RED — no final PNG; raw sidecar only. |
| 633 `v42-cap-donor-240b` | ok / 0 | 10:58:01 | N/A — capture | 1 | STALE + RED — `U64_MASK` parse error; started before I17 fix. |
| 634 `v42h-parse-inputs` | ok / 0 | 10:59:01 | 1/1 | 0 | STALE after 11:15:54 shader edit. |
| 635 `v42h-parse-composer` | ok / 0 | 10:59:07 | 1/1 | 0 | STALE after 11:15:54 shader edit. |
| 636 `v42-cap-donor-240c` | ok / 0 | 11:00:08 | N/A — technical capture | 0 | STALE after 11:15:54 shader edit. |
| 637 `v42i-uitest` | ok / 0 | 11:15:37 | **17/17** | 0 | STALE — completed before 11:15:54 shader edit. |
| 638 `v42j-mapvariety` | ok / 0 | 11:16:58 | **5/5** | 0 | **NEW** — started 11:16:22, after production cutoff. |
| 639 `v42k-donor-atom2` | failed / 1 | 11:17:55 | **22/25** | 0 | **NEW + RED** — started 11:17:31, after production cutoff. |

Ticket 640 has no result JSON/history row at the snapshot; it is not a completed gate.

### 4.1 Exact parse/error surfaces that matter

- **607:** 2 lines — `decode_float()` expected 1 arg, got 2; `encode_float()` expected 2, got 3.
- **608/617:** 38 lines each — `Could not find type "C3TerrainData" in the current scope.`
- **610:** 4 lines — `Cannot find member "to_lowercase"` / `Function "to_lowercase()" not found in base String`.
- **614:** 12 lines — float/double arity, `C3TerrainData`, `data`/`nx`/`ny` inference, `Mesh.ARRAY_UV2`, two Variant-inference warnings treated as errors.
- **615:** 1 line — cannot infer `boot_ok`.
- **619:** 7 lines — `C3TerrainData`, `data`/`nx`/`ny` inference, `Mesh.ARRAY_UV2`, two Variant-inference warnings.
- **621:** 9 lines — `decode_s32()`/`decode_float()`/`encode_float()` arity plus `sqrtf()` not found.
- **623:** 2 lines — `encode_float()` expected 2, got 3.
- **625/626/627 malformed argv:** 625 split the config path at the space in `Craft Anything`; 626 and 627 each stored the entire command as one argv string. Their `ok` envelopes prove only an engine launch, not the named test.
- **633:** `SCRIPT ERROR: Parse Error: Identifier "U64_MASK" not declared in the current scope.` at `terrain_donor_inputs.gd:138`.

## 5. Donor atom — exact FAIL reasons

### 5.1 Ticket 629 — stale FAIL 17/25

Eight class-A failures:

1. `no_synthetic_noise_field` — scanner reported two active tokens: `"relief_mask_cells_no_face_promotion"` and `"no_noise_field": true`.
2. `grid_size_64` — detail shows `w=64 h=64 n=4096 height=16384 tileblock=4096 terrain=4096 blocked=16384`.
3. `grid_size_240` — detail shows `w=240 h=240 n=57600 height=230400 tileblock=57600 terrain=57600 blocked=230400`.
4. `surface_count_one` — `surfaces=-1 reason=`.
5. `vertex_count_exact` — `vertices=-1 expected=-2`.
6. `triangle_count_exact` — `triangles=-1 expected=-2`.
7. `uv2_tile_id_invariant` — `UV2.x!=tex violations=-1 eps=0.001`.
8. `uv2_face_domain` — `UV2.y outside {0,1,2} violations=-1`.

One script-error line: `Invalid assignment of property or key 'map_w' with value of type 'int' on a base object of type 'Node (StubGame)'` at `t_terrain_donor.gd:545`.

### 5.2 Ticket 639 — current NEW FAIL 22/25

The current `variant3d/tests/results/t_terrain_donor.json` has `passed=false`, `passes=22`, `total=25`, `status=FAIL`, mtime **11:17:53**. Remaining class-A failures:

1. `no_synthetic_noise_field` — same two-token scanner failure.
2. `vertex_count_exact` — **vertices=25600, expected=57600**.
3. `triangle_count_exact` — **triangles=50562, expected=114242**.

All **19 advisory rows are `UNVERIFIED`**, including the two `HOOK_MISSING` vector hooks. No script-error lines. This is a real fresh red structural result, not a stale JSON.

## 6. Captures 632 / 633 / 636

| Ticket / job id | Runner | Result JSON mtime | `SCRIPT ERROR` lines | PNG evidence | Verdict |
|---|---|---:|---:|---|---|
| 632 `v42-cap-donor-240` | failed / 1 | 10:54:12 | **93** | No final `cap_donor_240.png`; only `cap_donor_240.png.raw.png`, 1280×720, non-black 0.897039, mean luma 23.645, dark rows 0. | **RED + STALE.** 92 errors are `_s(Object)` → Dictionary conversion failures; 1 is `Object != Dictionary`. |
| 633 `v42-cap-donor-240b` | ok / 0 | 10:58:01 | **1** | Final PNG 1280×720, non-black 0.897566, mean luma 68.746, dark rows 0; camera diag present. | **RED + STALE.** `U64_MASK` parse error; runner `ok` is not capture admissibility. |
| 636 `v42-cap-donor-240c` | ok / 0 | 11:00:08 | **0** | Final PNG 1280×720, non-black 0.897311, mean luma 30.557, dark rows 0; `camera_current=true`, `world_parent=Screenshot3DViewport`. | **Technically clean but STALE** after the 11:15:54 shader edit. No current post-shader capture; no visual/parity sign-off. |

## 7. Exact remaining gates

Of COORD's four named remaining items, **uitest and `t_map_variety` have now run**, but only `t_map_variety` is fresh:

1. **Fresh uitest 17/17 — still required.** Ticket 637 is 17/17 with 0 script errors, but it completed before the shader edit and is stale.
2. **`t_map_variety` 5/5 — satisfied fresh** by ticket 638, unless another production edit lands.
3. **Fresh final selftest 29/29 — required.** Ticket 631 is stale.
4. **Fresh final `t_render_mode` 10/10, `seam_missing=false` — required.** Ticket 630 is stale; 627 never ran the test.
5. **Post-shader parse/compile smoke — required.** Ticket 625 was malformed and stale; 634/635 are also pre-shader.
6. **`t_terrain_donor` — fix and rerun.** Current 639 is fresh RED 22/25; the three class-A failures in §5.2 block D-3.
7. **Determinism dumps — not run.** Six unique jobs remain: `v42-dump-64-a`, `v42-dump-64-b`, `v42-dump-240-a`, `v42-dump-240-b`, `v42-dump-320-a`, `v42-dump-320-b`, writing paired dumps under `%TEMP%\opencode\v42\dumps`. Require fresh envelopes, `script_error_lines=0`, mtime-after-START, pairwise whole-file SHA equality as provisional `[D]`, and the N16 five-stream fingerprint before claiming D1. The donor atom's in-process 64/240 checks do **not** replace these dumps or the missing 320² pair.
8. **`scan_map.py` — not run.** After the six dumps: `python variant3d\tools\scan_map.py --dir "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps"`; require `ALL GREEN` / exit 0 with no relaxed checks.
9. **Plain CLEAN — output still required.** Run `python variant3d\tools\assert_clean.py --json` only after the spool settles; retain actual `verdict=CLEAN`, `reasons=[]`, process/lock/history fields. Do not use `--ignore-history`.
10. **Fresh windowed capture — required.** Ticket 636 is pre-shader. Require 1280×720, non-blank, `full_width_dark_rows=0`, `script_error_lines=0`, camera/aperture diag, then separate visual review. No donor-parity wording.
11. **Final `app/**` byte-identity check and COORD sign-off — still required.** No parity claim is permitted.

*End of W10 regression status. Read-only; no job run; no parity claim.*
