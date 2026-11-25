---
id: P0-FRESH-CAPTURE-01
title: "Fresh P0 terrain-only capture and measurement AFTER the final LIGHT-02 shader edit"
date: 2026-11-25
status: COMPLETE__ONE_RUNNER_JOB__MEASURED__P0_READY_FOR_LADDER
scope: "Exclusive new file only: docs/coord_swarm_2026-11-25/reports/P0_FRESH_CAPTURE_01.md. No code/test/shader/config/other-report edit. One windowed job through variant3d/tools/godot_runner.py only (unique id, no direct godot, no queue mutation). Runner regenerated its own result JSON, stdout/stderr and PNG as runtime outputs; no donor access."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner: "Execution worker — single fresh P0 capture (subagent)"
labels: [observed, derived, inferred, UNVERIFIED]
evidence_basis: "RECHECK_P0.md:12-13,173-177 — previous only post-fix P0 capture (ticket 441) at 09:52:12 UTC predated the final shader edit at 09:53:34 UTC; no final-formula capture then existed."
job: "p0fresh01-capture / ticket 504 / ok"
final_formula_check: "variant3d/shaders/terrain_tileindex.gdshader:287-293 sun_world = normalize(vec3(donor_sun_position.x, .y, .z)); file mtime 2026-11-25 09:53:34 UTC. Capture PNG mtime 10:41:11 UTC (47 min 37 s later)."
verdict: "P0 READY_FOR_LADDER on the measured gates; ladder advancement itself remains COORD's decision (TEST_MATRIX.md:57-59; CAPTURE_RECHECK.md:249)."
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; no donor parity is claimed (TEST_MATRIX.md:34,73-74)."
other_files_edited: false
---

# P0-FRESH-CAPTURE-01 — fresh P0 capture after the final LIGHT-02 edit

## 0. Mandate and boundary

Close the evidence gap recorded by `RECHECK_P0.md`: the only post-fix P0 capture it
found (ticket 441, `terraindarkfix-p0`, PNG mtime 09:52:12 UTC) was taken **before**
the final LIGHT-02 shader edit (09:53:34 UTC), so it could not certify the current
code. This worker submitted exactly **one** fresh windowed P0 job, measured its
artifacts with the two read-only tools, and wrote only this report. No assertion,
threshold, gate, atom, shader, config, fixture or other report was changed; no
row was advanced by this worker. Everything below is `observed` unless labelled
`derived`, `inferred` or `UNVERIFIED`.

## 1. Sources read (all read-only)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/RECHECK_P0.md` | Gap statement (`:12-13,173-177`): ticket 441 predates the final edit; no final-formula capture existed at that time; `full_width_dark_rows` is recorded-only. |
| `docs/coord_swarm_2026-11-25/reports/TERRAIN_DARK_FIX.md` | Stage-1 vs final formula history (`:104-110,157-197`), prior final-formula ticket 496 values, PORT APPROX / no-parity declarations (`:199-219`). |
| `docs/coord_swarm_2026-11-25/reports/LIGHT_02_light_space.md` | Independent derivation of the final formula `normalize(vec3(P.x,P.y,P.z))` (frontmatter `:13`). |
| `docs/coord_swarm_2026-11-25/reports/P0_GATE_01.md` | Gate semantics: `full_width_dark_rows` recorded-only; strict `mean_luma>=40`, `max_luma>=100` (`:61-112`); PORT APPROX thresholds. |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md` | Row P0 (`:18`), 64² reuse / 4,096-7,938-4,096 baseline (`:29-46`), sequential ladder + second-agent rule (`:53-59`), never weaken an assertion (`:67-68`), no donor-parity claim (`:73-74`). |
| `docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md` | Atom's expected args and assertions: `--screenshot` alias `--png` (`:96`), windowed PNG checks (`:100-101`), proposed launch form (`:226-237`). |
| `variant3d/tests/t_terrain_only.gd` (read-only) | Confirmed `_arg_value("--screenshot")` with `--png` fallback (`:413-415`); recursive output-dir creation (`:664-666`); metric mirror and `max_luma` (`:370-402`); gate checks (`:677-707`). |
| `variant3d/shaders/terrain_tileindex.gdshader` (read-only) | Confirmed final LIGHT-02 formula at `:287-293`; UTC mtime 09:53:34 (observed via `Get-Item`). |
| `variant3d/tools/smallmap_capture.py` (read-only) | `stats` luma/non-black/dark-row definitions (`:21-39`) and `scan-stderr` (`:50-58`). |

## 2. Job

Pre-flight `python variant3d\tools\godot_runner.py status` showed
`now_serving=500`, `next_ticket=503`, `pending=3 [500,501,502]`, `godot.lock=HELD`.
The FIFO wait was expected; the job was submitted **once** and never re-submitted.

Exact command submitted (Windows `python`, unique id, windowed, runner only):

```
python variant3d\tools\godot_runner.py run --id p0fresh01-capture --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png --png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png
```

| Field | Value |
|---|---|
| Job id / ticket | `p0fresh01-capture` / **504** |
| Runner lifecycle | `START (waited 79.69s)` → `END ok (run 27.81s)` |
| Mode | Windowed (no `--headless`); JSON `display_server=Windows`, `headless=false` |
| Result JSON | `variant3d\tests\results\t_terrain_only.json` — 5,658 B, mtime **2026-11-25 10:41:12 UTC**, `unix_ms=1795603272261.0` → **10:41:12.261 UTC**; stdout `RESULT_JSON` points here |
| Result verdict | **`PASS`** — `passed=true`, `verdict=PASS`, `passes=22`, `fails=0`, `skipped_or_skip_capture=1`, `structural_ok=true`, `capture_status=PASS`, `harness_source=shared:res://tests/fixtures/_smallmap_harness.gd` |
| stdout tail | `T_TERRAIN_ONLY RESULT: PASS 22/22 evaluated, 1 skipped` (result dir `variant3d\.godot_queue\results\00000504_p0fresh01-capture\stdout.txt`) |
| stderr / stdout paths | `variant3d\.godot_queue\results\00000504_p0fresh01-capture\stderr.txt` / `stdout.txt` |

### Timing proof that this is a post-final-edit capture

`variant3d/shaders/terrain_tileindex.gdshader` currently contains
`sun_world = normalize(vec3(donor_sun_position.x, donor_sun_position.y, donor_sun_position.z))`
(`:292-293`), the LIGHT-02 final formula, with file mtime **09:53:34 UTC**. The fresh
PNG's mtime is **10:41:11 UTC**, i.e. **47 min 37 s after** the final shader edit. This
capture is therefore the final-formula frame that `RECHECK_P0.md:173-177` found missing.

## 3. Artifacts and measured stats

PNG: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png`
— **2,129,263 B**, mtime **2026-11-25 10:41:11 UTC**, 1280×720. Size and path agree
with JSON `measured.png_metrics.bytes` / `png_path`; `save_png(... ) err=0`.

Command:

```
python variant3d\tools\smallmap_capture.py stats C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png
```

Verbatim output:

```json
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\p0fresh01\\p0_final_formula.png",
    "bytes": 2129263,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      93.749,
      96.783,
      31.643
    ],
    "mean_luma": 91.432,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

`max_luma` is not printed by `stats`; it is taken from the atom's `measured.png_metrics`
and check detail: **155.163005127713** (detail prints `max_luma=155.163`).
`mean_luma` full precision from JSON: **91.4320785333257**.

Command:

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000504_p0fresh01-capture\stderr.txt
```

Verbatim output:

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000504_p0fresh01-capture\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

### Consolidated measurements

| Metric | Value | Source / gate |
|---|---:|---|
| `mean_luma` | **91.432** (JSON 91.4320785333257) | `stats` + JSON; `ground_mean_luma >= 40` **PASS** |
| `max_luma` | **155.163** (JSON 155.163005127713) | JSON only (`stats` omits it); `ground_max_luma >= 100` **PASS** |
| `full_width_dark_rows` | **0** (fraction 0.0) | `stats` + JSON; `RECORDED_NOT_APPLICABLE`, no pass/fail contribution (`P0_GATE_01.md:74-77`) |
| `non_black_fraction` | **1.0** | `stats` + JSON; `> 0.9` **PASS** |
| `mean_rgb` | (93.749, 96.783, 31.643) | `stats` |
| `SCRIPT ERROR` count | **0** | `scan-stderr`, `lines: []` |

Structural checks from the same JSON, all `passed=true`: `surface_count=1`,
`vertex_count=4096`, `triangle_count=7938`, `uv2_count=4096`, `uv2_y_hist={"0":4096}`,
`flat_grid_promoted=0`, `res_nodes=0`, `cells_below_water_level=0`,
`water_tileblock_cells=0`, `atlas_grid=[16,8]` (shader `(16.0, 8.0)`), 3 atlas samplers
bound, `shadow_enabled=0.0`, `WaterPlane nodes=1 all_hidden=true`, 1280×720
SubViewport capture. No check was weakened or bypassed.

### Visual read of the PNG (independent of the metrics)

**observed:** the whole 1280×720 frame, corners included, is a non-blank olive /
yellow-green grass field with fine, fairly even grain. No sky, horizon, water band,
shoreline, tile grid, checkerboard, seam, dark band, tree, mine, unit or building is
visible; no full-width dark row is distinguishable.

**derived:** the image is consistent with `full_width_dark_rows=0`,
`non_black_fraction=1.0`, hidden water plane and empty `res_nodes`; metrics and image
agree and neither substitutes for the other.

**inferred / UNVERIFIED:** faint low-contrast mottling may be atlas grain / texgen
artefact (no causal A/B run). Whether the olive hue, grain scale or tonal distribution
resembles a donor frame is **UNVERIFIED** — no donor GPU A/B frame exists.

### Recorded non-`SCRIPT ERROR` diagnostics

The stderr is not empty: one cosmetic `String formatting error` at
`t_terrain_only.gd:429`, three image-load export warnings, two camera bind-time
`!is_inside_tree()` / `look_at` errors (`camera3d.gd:281-282`) and a 3-instance
ObjectDB leak warning. These are **recorded, not ignored**; they are pre-existing
non-script diagnostics and none contributes to a gate. `SCRIPT ERROR == 0` holds.

## 4. Verdict

**P0 READY_FOR_LADDER** — the fresh, post-final-LIGHT-02-formula P0 capture (ticket
504) satisfies every applicable P0 criterion with measured evidence:

1. Final-formula timing: shader mtime 09:53:34 UTC < PNG mtime 10:41:11 UTC — the gap
   identified by `RECHECK_P0.md:173-177` is closed.
2. Atom JSON `verdict=PASS`, `passes=22`, `fails=0`, `structural_ok=true`,
   `capture_status=PASS`, stdout `PASS 22/22 evaluated, 1 skipped`, windowed
   (`headless=false`, `display_server=Windows`).
3. `mean_luma=91.432 >= 40` and `max_luma=155.163 >= 100` (both hard PORT APPROX gates).
4. `non_black_fraction=1.0 > 0.9`; `full_width_dark_rows=0` recorded-only (N/A as gate).
5. `SCRIPT ERROR == 0` on ticket 504 stderr; PNG exists with matching JSON bytes/path.
6. Visual read shows a non-blank grass field with no contradicting defect.

`full_width_dark_rows` remains N/A/recorded, not converted into a pass. No threshold
was lowered, no row was re-run hoping for green. The measured luma is close to the
prior final-formula observation in `TERRAIN_DARK_FIX.md:180-197` (ticket 496:
`mean_luma=91.424`, `max_luma=154.448`); this fresh run is an independent
reproduction of that magnitude, **not** a donor comparison.

**Scope of the verdict:** readiness on the port's own gates only. Ladder advancement
is COORD's decision (`TEST_MATRIX.md:57-59`; `RECHECK_P0.md:173`), and this report does
not advance it. **PORT APPROX — internal consistency only; no donor parity claim.**

## 5. Open questions

1. **Donor parity (F0) still blocked:** no matched donor GPU A/B terrain frame exists;
   hue/grain/luma fidelity remains **UNVERIFIED** (`TEST_MATRIX.md:46,73-74`).
2. **Absolute luma / SubViewport readback:** the private readback's colour/tonemap
   behaviour remains **UNVERIFIED** (`TERRAIN_DARK_FIX.md:207-211`).
3. **Engine GL light binding:** `W=1` / `lsParallel` submission and `realpos`
   subtraction remain **UNVERIFIED** (`TERRAIN_DARK_FIX.md:199-206`).
4. **Non-script diagnostics:** the format-string, camera bind and ObjectDB warnings
   persist; out of scope for this capture ticket, recorded rather than suppressed.
5. **Stale module sun vector:** `world3d_terrain.gd:121-126,138` still carries the
   water-derived `SUN_LIGHTVEC=(x/4,z/2,y)`; read-only here and outside this ticket
   (`TERRAIN_DARK_FIX.md:214-219`).
6. **Ladder/second-agent protocol:** whether COORD treats this fresh independent
   capture-and-measurement as the required second-agent re-check, or requests a
   separate re-check, is a COORD decision (`TEST_MATRIX.md:58,75`).

## 6. Summary

Submitted exactly one windowed P0 job (`p0fresh01-capture`, ticket 504, `ok`) after
confirming the final LIGHT-02 shader formula was already on disk. Measured the fresh
PNG with `smallmap_capture.py stats` and its stderr with `scan-stderr`: `mean_luma=
91.432`, `max_luma=155.163` (from JSON), `full_width_dark_rows=0`,
`non_black_fraction=1.0`, `SCRIPT ERROR=0`; JSON `PASS 22/22 evaluated, 1 skipped`.
The PNG (2,129,263 B, 10:41:11 UTC) postdates the shader edit (09:53:34 UTC), so the
missing final-formula P0 capture now exists. Verdict: **P0 READY_FOR_LADDER** on the
port's own gates; donor parity remains UNVERIFIED and advancement remains COORD's.
No file other than this report was edited — no code, test, shader, config, other
report, queue mutation or direct `godot` invocation.

---

*End of P0-FRESH-CAPTURE-01.*
