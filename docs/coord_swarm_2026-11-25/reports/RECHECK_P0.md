---
id: RECHECK-P0
title: "Second-agent re-check of the P0 terrain-only capture (RECHECK-P0-01)"
owner: "Second agent — independent re-checker, not the executing builder"
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT
scope: "One new file only: docs/coord_swarm_2026-11-25/reports/RECHECK_P0.md. No PNG/JSON/stderr/atom/shader/config/fixture/git edit, no Godot submission, no donor access, no ladder advance."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
protocol: "docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md (§1.2 commands, §2 P0 checklist, §3 image rules, §4 recording)"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; donor parity UNVERIFIED. This re-check never certifies donor parity."
capture_under_review: "ticket 441 / job id terraindarkfix-p0 (stage-1 post-fix); PNG mtime 2026-11-25T09:52:12Z"
ladder_note: "P0 criteria PASS for the captured stage-1 frame; NOT cleared for ladder advancement on current code — no final-formula P0 capture exists. COORD decides."
---

# RECHECK-P0 — independent P0 terrain-only capture re-check

## 0. Mandate and boundary

Executed CAPTURE-RECHECK-01 for row **P0** only. The protocol requires that visual review and the atom's own assertions be reported **separately**, that no metric override the image, and that no donor parity be inferred (`CAPTURE_RECHECK.md:36,82,91,234-240`). This report does not submit a row, rerun a failing row, change a threshold, or advance the ladder (`:249`). Everything below is `observed` unless explicitly labelled `derived`, `inferred` or `UNVERIFIED`.

Sources opened: `CAPTURE_RECHECK.md`, `reports/TEST_RUN_02_ladder_log.md`, `reports/TERRAIN_DARK_FIX.md`, `reports/P0_GATE_01.md`, `reports/PIXEL_01_p0_capture_review.md`, `reports/METRIC_01_dark_rows.md`, plus the artifacts and commands in §1–2. `frames.json` is not applicable: P0 is not a motion row (`CAPTURE_RECHECK.md:52`).

## 1. Artifacts opened

| Artifact | Path | Observed state |
|---|---|---|
| PNG under re-check (post-fix, stage 1) | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\terraindarkfix-p0\smallmap64_terrain_only.png` | 2,159,108 B; mtime **2026-11-25 09:52:12 UTC**; read directly as an image; matches JSON `measured.png_metrics.bytes` and `png_path` |
| PNG, earlier/pre-fix (comparison only) | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png` | 987,980 B; mtime **2026-11-25 09:37:10 UTC**; overwritten by validation job 421 (`p0gate01-run`, `P0_GATE_01.md:160-165`), no longer the 988,242 B job-404 PNG; read directly as an image |
| Result JSON | `variant3d\tests\results\t_terrain_only.json` | 5,718 B; mtime **2026-11-25 09:52:13 UTC**; `unix_ms=1795600333500` → **2026-11-25T09:52:13.5Z**; `verdict=PASS`, `passed=true`, `passes=22`, `fails=0`, `skipped_or_skip_capture=1`, `structural_ok=true`, `capture_status=PASS`, `headless=false`, parity label `PORT APPROX — internal consistency only; no donor GPU A/B` |
| Runner stderr (post-fix) | `variant3d\.godot_queue\results\00000441_terraindarkfix-p0\stderr.txt` | exists; `script_error_lines: 0` (see §2); non-`SCRIPT ERROR` diagnostics remain (§6) |
| Runner stdout (post-fix) | `variant3d\.godot_queue\results\00000441_terraindarkfix-p0\stdout.txt` | ends `T_TERRAIN_ONLY RESULT: PASS 22/22 evaluated, 1 skipped`; `RESULT_JSON` points at the JSON above |
| Runner stderr (earlier PNG) | `variant3d\.godot_queue\results\00000421_p0gate01-run\stderr.txt` | exists; `script_error_lines: 0` (see §2) |
| Final-formula fix2 artifacts | `...\Temp\opencode\terraindarkfix2-p0\` | **absent** (directory not found). Jobs `00000456_terraindarkfix2-p0`, `00000483_terraindarkfix2-p0-r2`, `00000496_terraindarkfix2-p0-r3` have no capture artifacts (456/496 result dirs empty; 483 has only a 167-byte header-only stdout and a 0-byte stderr). Recursive search found **no** `*.png` in the opencode temp root newer than 09:45 UTC. |

## 2. Command outputs (verbatim, read-only)

Run from repo root with Windows `python`, per `CAPTURE_RECHECK.md:62-83`.

Post-fix PNG:

```
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\terraindarkfix-p0\smallmap64_terrain_only.png"
```

```json
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\terraindarkfix-p0\\smallmap64_terrain_only.png",
    "bytes": 2159108,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      101.198,
      104.261,
      35.935
    ],
    "mean_luma": 98.68,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

Earlier/pre-fix PNG:

```
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png"
```

```json
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\test01_ladder2\\smallmap64_terrain_only.png",
    "bytes": 987980,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 0.992815,
    "mean_rgb": [
      14.043,
      14.381,
      0.001
    ],
    "mean_luma": 13.271,
    "full_width_dark_rows": 720,
    "full_width_dark_row_fraction": 1.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

stderr scans:

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000441_terraindarkfix-p0\stderr.txt
```

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000441_terraindarkfix-p0\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000421_p0gate01-run\stderr.txt
```

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000421_p0gate01-run\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

Atom-side values used for gates (from JSON, not from `stats`, which does not print `max_luma`): `mean_luma=98.6802637594176`, `max_luma=172.139004115865`, `non_black_fraction=1.0`, `full_width_dark_rows=0`; check details print `mean_luma=98.680` and `max_luma=172.139`. Luma gates are PORT APPROX thresholds (`P0_GATE_01.md:92-112`), not donor calibrations.

## 3. P0 criterion checklist (CAPTURE-RECHECK.md §2, current atom assertions)

All values refer to the **post-fix capture (ticket 441)** JSON/PNG unless stated otherwise. Exactly one of PASS/FAIL/N/A is marked per row.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `harness_stub_shape`, `terrain_module_api`, `camera_module_api`, `build_ok` | **PASS** |  |  | All four `passed=true` in JSON; stdout lines 4–7; shared harness source recorded. |
| Structural counts: `surface_count==1`, `vertex_count==4096`, `triangle_count==7938`, `uv2_count==4096` | **PASS** |  |  | JSON details `surfaces=1`, `vertices=4096`, `triangles=7938`, `UV2 entries=4096`; `measured` agrees. |
| `uv2_y_face_modes` (histogram recorded; values ∈{0,1,2}) | **PASS** |  |  | JSON `uv2_y_hist={"0":4096}`; only face mode 0, within {0,1,2}. |
| `flat_grid_promoted == 0` | **PASS** |  |  | JSON detail `promoted=0`; `measured.flat_grid_promoted_cells=0`. |
| `res_nodes_empty`, `no_water_cells == 0`, `no_water_tileblock == 0` | **PASS** |  |  | JSON details `res_nodes=0`, `0 cells below -0.25 m`, `BLK_WATER cells=0`. |
| `atlas_grid_manifest [16,8]`, `atlas_material_bound` (3 samplers), `shader_shadow_disabled` | **PASS** |  |  | JSON `stats.grid=[16.0,8.0]` = shader `(16.0,8.0)`; detail `tile/alpha/alphavert bound=true`; `shader_shadow_enabled="0.0"`. |
| `water_plane_hidden` (water hidden, not deleted) | **PASS** |  |  | JSON detail `WaterPlane nodes=1 all_hidden=true`; `water_plane_count=1`, `water_3d_node_count=1`. |
| `capture_image`, `capture_saved` | **PASS** |  |  | JSON `SubViewport texture 1280x720`; `save_png(...terraindarkfix-p0\...) err=0`; `stats` confirms 1280×720, 2,159,108 B. Windowed: `measured.headless=false`. |
| `non_black_fraction > 0.9` | **PASS** |  |  | `stats=1.0`; atom detail `non_black_fraction=1.0`. |
| Luma gates: `ground_mean_luma >= 40`, `ground_max_luma >= 100` | **PASS** |  |  | `mean_luma=98.680` ≥ 40; `max_luma=172.139` ≥ 100; both JSON `passed=true`. PORT APPROX gates, no donor parity. |
| `full_width_dark_rows` = recorded diagnostic |  |  | **N/A** | JSON `status=RECORDED_NOT_APPLICABLE`, `passed:null`; recorded value **0** (fraction 0.0) in the post-fix PNG; earlier/ladder2 PNG recorded **720** (fraction 1.0). No pass/fail contribution by design (`P0_GATE_01.md:74-77,143-145`); image reading in §4. |
| `SCRIPT ERROR == 0`, windowed, JSON `verdict=PASS` | **PASS** |  |  | `script_error_lines: 0` on ticket 441 stderr; `headless=false`; JSON `verdict=PASS`, `passed=true`. Non-`SCRIPT ERROR` diagnostics recorded in §6. |

Counts: **11 PASS, 0 FAIL, 1 N/A (recorded-only)**. No blank or `UNVERIFIED` checklist row.

## 4. Image inspection (independent of metrics)

### 4.1 Post-fix capture — ticket 441, `terraindarkfix-p0` (the frame under re-check)

**observed** (from opening the PNG): the full 1280×720 frame, all four corners included, is filled by an olive / yellow-green grass field. There is no sky, no horizon, no water band, no shoreline and no trees, mines, units or buildings. No 2 m tile grid, checkerboard, seam or full-width dark row is distinguishable. Fine, fairly even grain covers the whole field; a few faint, irregular darker streaks are visible around the centre/left-middle and a faint smudge in the lower-left, all low-contrast and not grid-aligned. The frame is plainly non-blank and has visible tonal range.

**derived**: the absence of a dark band is consistent with `full_width_dark_rows=0` and with the JSON's `no_water_cells=0` / hidden water plane; the featurelessness is consistent with a terrain-only composition (`res_nodes=0`). Metrics and image agree here; neither substitutes for the other.

**inferred / UNVERIFIED**: the faint streaks may be atlas grain or eye-plane texgen artefacts, but no causal claim is made. Whether the olive hue, grain scale or tonal distribution resembles a donor 64² terrain-only frame is **UNVERIFIED** — no donor GPU A/B frame exists.

### 4.2 Earlier/ladder2 capture — ticket 421, `test01_ladder2` (comparison only)

**observed**: the whole frame is a near-black dark-olive field with no sky, horizon, tiles or structures; only very faint diagonal strokes and a lower-left curved smudge are visible. This matches PIXEL-01's description of the original job-404 frame (`PIXEL_01:24-38,54-57`) and the re-measured dark numbers in §2 (`mean_luma=13.271`, 720/720 dark rows). **derived**: the brightness difference between §4.1 and §4.2 is large and global, not a thin band. **inferred**: attribution to the shader sun-direction fix is supported by the ticket chronology (`TERRAIN_DARK_FIX.md:134-153`) but donor parity and exact causal decomposition remain UNVERIFIED. This earlier PNG is **not** the frame used for the checklist verdict.

### 4.3 Separation of fields

The §3 checklist judges the atom's assertions. The §4.1 visual reading reports what the pixels show. They are recorded independently: the post-fix image shows no visual defect that contradicts the luma/non-blank gates, but it is still a featureless ground field; the earlier image shows the genuine defect independently confirmed by PIXEL-01. No donor-parity claim is made for either.

## 5. Verdict

- **Atom JSON verdict (ticket 441):** `PASS` — `passed=true`, `verdict=PASS`, `passes=22`, `fails=0`, `skipped_or_skip_capture=1`, `structural_ok=true`, `capture_status=PASS`; stdout `PASS 22/22 evaluated, 1 skipped`.
- **Second-agent image verdict (post-fix PNG):** **no contradicting visual defect for P0's own gates** — non-blank, uniformly olive, no dark band, no water band; visual character is a fine-grained featureless ground field. `PORT APPROX`; donor parity **UNVERIFIED**.
- **Per-criterion verdict:** 11 PASS / 0 FAIL / 1 N/A (recorded diagnostic) as tabulated in §3.
- **Donor parity:** **UNVERIFIED**. No donor GPU A/B frame exists; `stats` itself prints `qualitative comparison only. No donor parity is claimed.` Nothing here certifies donor fidelity.
- **Ladder advancement:** **not cleared by this re-check.** The §3 PASS applies to the captured **stage-1** frame only. The final LIGHT-02 formula is present in the current shader (`terrain_tileindex.gdshader:287-294`, `sun_world = normalize(vec3(x, y, z))`) with file mtime **09:53:34 UTC**, i.e. **after** the 09:52:12 capture; `TERRAIN_DARK_FIX.md:16,155-157,217` still records `p0_fix2: PENDING`. No final-formula P0 PNG, JSON or stderr exists (§1). Per `CAPTURE_RECHECK.md:249`, only COORD may advance; a fresh final-formula P0 capture plus re-check, or an explicit COORD decision to accept the stage-1 capture as representative, is required before P1. This report makes no advancement decision.

## 6. Recorded observations / open questions

1. **Post-fix identity:** the only post-fix P0 PNG is ticket **441 / `terraindarkfix-p0`**, mtime **2026-11-25 09:52:12 UTC** (JSON `unix_ms` 09:52:13.5 UTC), produced under stage 1 (`vec3(x/4, y, z/2)` per `TERRAIN_DARK_FIX.md:134-153`). The `...\terraindarkfix2-p0\` folder named in the task does not exist; jobs 456 (skipped), 483 and 496 produced no capture. The final-formula re-capture remains **PENDING** (`TERRAIN_DARK_FIX.md:157`).
2. **Non-`SCRIPT ERROR` diagnostics persist** on ticket 441 stderr: cosmetic `String formatting error` at `t_terrain_only.gd:429`, two camera bind-time `!is_inside_tree()` / `look_at` errors (`camera3d.gd:281-282`), and a 3-instance ObjectDB leak warning. They are recorded, not silently ignored (`CAPTURE_RECHECK.md:59`); `SCRIPT ERROR == 0` is still MET, and they were not the P0 gate.
3. **Dark-row history:** original job 404 = 720 (988,242 B PNG, now overwritten); ticket 421 (= current ladder2 PNG) = 720 at 987,980 B; ticket 441 = 0 at 2,159,108 B. The value is recorded-only in all post-P0-GATE runs.
4. **Gate calibration:** `>=40` and `>=100` are PORT APPROX, not donor-derived (`P0_GATE_01.md:92-112,190-192`). Whether `max_luma>=100` is appropriate for a healthy sky-free ground frame remains unknowable without a donor/healthy capture (`P0_GATE_01.md:204-206`).
5. **Faint streaks** in both frames: cause UNVERIFIED; no A/B was run here and no donor frame exists.
6. **Absolute luma / engine GL binding** remain UNVERIFIED (`TERRAIN_DARK_FIX.md:159-182`).
7. **No visual PASS was manufactured from a missing file**: the absent final-formula artifacts are reported as absent, not inferred green.

## 7. Summary

Independently re-checked P0 from its PNG, result JSON, job-441 stdout/stderr and the two `smallmap_capture.py` commands. The post-fix P0 capture (ticket 441, 09:52:12 UTC) satisfies every applicable P0 criterion: structural counts, atlas/shadow/water state, non-blank capture, `mean_luma=98.680 >= 40`, `max_luma=172.139 >= 100`, windowed run, JSON `verdict=PASS`, and `SCRIPT ERROR == 0`; `full_width_dark_rows` is correctly N/A/recorded (value 0). Direct image inspection supports the read: a non-blank olive grass field with no dark band, while its featurelessness is expected for a terrain-only frame. The earlier dark frame (720 rows) is retained as a pre-fix observation, and PIXEL-01's visual defect verdict still describes that frame.

No donor parity is claimed; all findings are `PORT APPROX — internal consistency only`. The re-check **does not advance the ladder**: the captured frame predates the final LIGHT-02 shader edit and no final-formula P0 capture exists, so COORD must require a fresh capture/re-check or explicitly accept the stage-1 capture before authorising P1. Only this report was written; no other file was edited.

---

*End of RECHECK-P0. Second-agent record only: no runner job, no code/PNG/JSON/stderr edit, no donor access, no donor-parity claim, no row advancement by this worker.*
