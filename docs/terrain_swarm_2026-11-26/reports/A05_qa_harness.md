---
id: A05
swarm: TERRAIN-SWARM-2026-11-26
title: "QA / acceptance harness for the donor-faithful terrain — design only"
role: DESIGN — no code edits, no Godot jobs, no donor copy into repo
owner_file: docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md
status: DESIGN_ONLY__NO_RUNNER_JOB__NO_CODE_OR_ASSET_EDIT__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / internal consistency only. No donor GPU A/B frame exists. Every number below is either a determinism invariant of the port itself or an advisory direction band derived from third-party stills; none certifies donor fidelity. Donor parity stays UNVERIFIED."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md — §1–§6
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md — A05 row, integration gates
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md — §2, §5, §7
  - docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md — §1–§6
  - docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md — §1–§6
  - variant3d/tools/terrain_ab_metric.py, variant3d/tools/compare_shots.py
  - variant3d/scripts/main.gd:751-810, variant3d/scripts/game.gd:52, variant3d/tools/donor_gen.py:49-59
---

# A05 — QA / acceptance harness (design)

## 0. Executive summary

This report designs, but does not build, the QA harness for the fresh donor-faithful
terrain. It specifies five layers:

1. **Determinism gate (hard).** Two runs at identical `(seed, generation-key tuple)`
   must be **byte-identical** on all five `--dump-map` streams (`height` float32
   bytes, `terrain`, `blocked`, `tileblock`, and a canonical-hashed prop/cluster/
   stamp set) at **64², 240² and 320²**. Zero tolerance. SHA-256 fingerprints over
   raw base64-decoded bytes, not rounded numbers (`main.gd:791-798`,
   `full_map_shot.py:191-227`).
2. **Donor-grounded structural gates (hard + advisory).** Height-band/decile
   occupancy, water/shore fractions, tile-id histogram, relief-stamp candidates,
   pattern-family counts, and mine/field/forest counts. Numeric donor ranges are
   **not in evidence yet** — they are owned by D03–D08/F03–F08 — so the harness
   ships with an explicit `--policy advisory` mode and only accepts `--policy red`
   after a signed donor spec. Thresholds below are labelled `[D]` (derived from donor
   constants already in the repo) or `[I]` (sanity bands inferred from the prior
   wave's flat-field symptom), never `[O]` donor measurements.
3. **Visual A/B protocol.** Donor stills in `C:\Users\Maxym.Oboyshev\Downloads\c3\`
   (12 files, listed in §4) are third-party images of unknown build, camera and
   compression. Only *statistical direction of movement* on identical fractional
   ground ROIs is legitimate (`C01:145,181,205-217`; `G21:80-105`). `compare_shots.py`
   SSIM/MAD is legitimate **only** for candidate-vs-candidate determinism at a pinned
   camera, never as donor parity. Admissibility gates G0-a…e and region cards R1–R8
   are carried over from `G21:52-58,131-191`; the metric never overrides the visual
   read (`G21:241-250`).
4. **Gate sequence + rollback.** Preflight → static → determinism → structure →
   visual → regression → COORD sign-off. Any hard FAIL, gate weakening, `app/` hash
   drift, headless/blank capture, or `timed-out|error|skipped` runner status triggers
   rollback to the legacy `world3d_terrain.gd` switch (`CHARTER.md:61`) and restores
   from `inbox/backup/` (`AGENT_PROTOCOL.md:11`).
5. **JSON schema** `terrain_qa_report/1` (§7) that keeps labels, evidence ids, metric
   fields and visual fields separate and records `parity.status = "UNVERIFIED"`.

**Nothing in this design claims donor parity.** A05 submits **zero** Godot jobs
(`CHARTER.md:82`); every runner command in §8 is **PLANNED**, for COORD / the
implementation owner. No source, test, tool, config or asset file is edited.

## 1. Evidence table

| # | Label | Source (path:line) | What it establishes | Harness use |
|---|---|---|---|---|
| E01 | `[O]` | `docs/terrain_swarm_2026-11-26/CHARTER.md:27-31,40-44,61-64,74-82,121-126` | Read-only donor, only `variant3d/`, `app/` byte-untouched; labels mandatory; legacy retained behind switch; gates 29/29, 17/17, `t_render_mode`, `assert_clean`, `app/`; same seed ⇒ byte-identical; 240²/320² must work; no parity claim | Binding scope + gate list |
| E02 | `[O]` | `docs/terrain_swarm_2026-11-26/SWARM_BOARD.md:36,39-45` | A05 is QA harness design; COORD integrates; no worker edits board | Ownership |
| E03 | `[O]` | `variant3d/scripts/main.gd:751-810` | `--dump-map` emits `seed, map_w, map_h, terrain, blocked, height, tileblock, starts, clusters, res, meta` and opt-in `relief_stamps`; `height` is float32 bytes; `res` entries `{t,x,y,hits,r}` | Fingerprint inputs |
| E04 | `[O]` | `variant3d/tools/full_map_shot.py:191-227` | Canonical dump decode: base64→bytes, height `struct.unpack("<%df")`, `BLK_WATER` fill 1, meta passthrough | Fingerprint decoder contract |
| E05 | `[O]` | `variant3d/scripts/game.gd:52,749,1267-1274,2164-2170` | `BLK_WATER = 255`; density telemetry in `meta`; donor heights quantised from 8-bit mask R channel + clamp; tileblock bytes change under TRN-DATA | Water id, height bands, byte-tracking |
| E06 | `[D]` | `variant3d/tools/donor_gen.py:49-59,62-71,97-100` | Donor constants `C_WATER=-1.1`, `C_PLATEAU=2.964`, `C_HILL=2.964/2.25≈1.317`, `C_RAVINE=-2.964`; rings `(14,22)/(32,42)/(50,62)` donor units; `DONOR_UNITS=160` ⇒ 1 unit = 2 cells; 3 kinds × rounds × 256 mine attempts; family weights read from `generator.cfg` | Height bands, mine ring counts, family check |
| E07 | `[O]` | `variant3d/scripts/main.gd:769-776` | Stamp names from `assets/terrain/patterns/donor_patterns.json`; only `plt2` emitted; `k_ravine_1` hook **blocked** because absent from the donor catalogue | Relief-candidate admissibility |
| E08 | `[O]` | `docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md:29,48-60,145,181,205-217,210-211` | Metrics are SMOKE, not a fidelity gate; JSON schema `terrain_ab_metric/1`; use relative movement; PNG-vs-PNG like-with-like; no 640 normalisation in tool; never whole frame vs cropped donor | Visual A/B legitimacy rules |
| E09 | `[D]` | `docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md:16-24,57-77,123-141,165-187,188-212` | 12 donor stills are unknown-build third-party; ground ROIs; green-ref medians (BV32 n640 247.6, luma std 20.1, sat 0.529, grad 1.30); direction bands BV32 150–270, grad 1–2, luma std 18–22; confounds | Advisory visual bands |
| E10 | `[O]` | `docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md:52-58,80-105,110-128,131-191,194-219,241-250` | G0-a…e admissibility; same-ROI A/B; target bands corroboration only; R1–R8; sign-off rows 7/8 UNVERIFIED without CAP-3; metric-never-overrides | Visual protocol + honesty |
| E11 | `[O]` | `variant3d/tools/terrain_ab_metric.py:52,62-63,204-233,258-293,407-479,613-629,745-840` | Canonical donor folder; `SMOKE_LABEL`; block/autocorr/gradient/seam/distribution fields; CLI `--crop`, `--crop-frac`, `--compare-ref`, `--json` | Exact planned commands |
| E12 | `[O]` | `variant3d/tools/compare_shots.py:15-18,105-129,132-142` | SSIM/MAD score with default 0.80 explicitly a smoke placeholder, not a fidelity gate | Restricted use: self-determinism only |
| E13 | `[O]` | `variant3d/tools/smallmap_capture.py:21-39,50-58` | `stats` (non-blank, dark rows) and `scan-stderr` (`script_error_lines`) | Capture admissibility |
| E14 | `[O]` | `variant3d/config.json:24-31,35-71,75-77` + `variant3d/tests/fixtures/small_map_64.json:3-8` | Camera/seed keys; 64² overlay inherits from config; fixture `_readme` claims shipped 320² while `config.json:75-76` currently says 240² | Key manifest + size ambiguity (§10 Q1) |
| E15 | `[O]` | `variant3d/tools/AGENT_PROTOCOL.md:14-35,39-69,71-78`; `docs/variant3d/README.md:129-153`; `docs/variant3d/STATUS_WAVE7_PHASE2.md:24-27` | Runner is the only legal Godot launch; unique ids; queue waits aren't hangs; job budget; gate command forms; prior green baseline | Gate commands + rollback |
| E16 | `[O]` | `variant3d/tools/assert_clean.py:13-18,33-42` | Exit 0 clean / 1 dirty / 2 invocation; failure statuses `timed-out,error,skipped` | Preflight + postflight |
| E17 | `[O]` | direct read-only listing of `C:\Users\Maxym.Oboyshev\Downloads\c3\` (2026-11-26) | 12 image files: the 11 A11 refs plus `MADVBuilding1.JPG`; JPG/WEBP, 480×360…2355×1376 | Donor A/B corpus (read-only) |
| E18 | `[O]` | `glob docs/terrain_swarm_2026-11-26/reports/P03*.md` → no file at read time | P03 (concurrent) had not landed; its gate/capture inventory is not yet available | Reconcile before promoting advisory→red (§10 Q2) |

`[I]` items are confined to §3 threshold tables and are flagged there.

## 2. Design — deterministic dump contract

### 2.1 Generation keys (what "same seed+keys" means)

The harness pins a **key manifest** and refuses to compare dumps whose manifests
differ. Two groups:

- **Generation keys** (change the bytes): `gameplay.random_seed` (`20261113`,
  `config.json:77`), `map_width_tiles`, `map_height_tiles` (`config.json:75-76`),
  `gameplay.map_type`, `start_option`, `nation0/nation1`, `start_resources`,
  `deposits`, `features.terrain.relief_stamps`, `features.water.surface_y /
  alpha_confine / shore_prox` (`config.json:24-31,78-108`). All must be echoed into
  `dump.meta`; any key present in the config but absent from `meta` is `[U]` and
  blocks red promotion.
- **Capture keys** (do not change bytes but must be pinned for A/B):
  `camera.pitch_degrees=-32`, `fov_deg=17.27`, `start_zoom=0.3448276`,
  `min_height/max_height=20/58`, `display.pixels_per_meter=16`,
  `window_width/height=1280/720` (`config.json:36-71,51-56`). `start_zoom` is the
  donor-legal maximum zoom (`config.json:14`).

`config.gd` merges an overlay over `config.json` (`small_map_64.json:4-7`). All
planned dump/capture commands therefore pass an **absolute** overlay path; relying
on the ambient config is forbidden (it is ambiguous — E14).

### 2.2 Five canonical streams and fingerprints

For each dump, a planned pure-Python utility
`variant3d/tools/terrain_qa_harness.py fingerprint <dump*.json> --json` decodes
(E03/E04) and hashes:

| Stream | Decode | Canonical form hashed | Bytes at 64² |
|---|---|---|---|
| `height` | base64 → `<%df` little-endian float32 | **raw decoded bytes** (bit-exact, no rounding) | 4 × 4096 = 16384 |
| `tileblock` | base64 → uint8 | raw decoded bytes (length N) | 4096 |
| `terrain` | base64 → uint8 | raw decoded bytes | 4096 |
| `blocked` | base64 → uint8 | raw decoded bytes | 4096 |
| props set | `res`, `clusters`, `starts`, `relief_stamps` | `json.dumps(sort_keys=True, separators=(",",":"), allow_nan=False)` with every float written as `float.hex()` | variable |

`meta` is hashed **after** stripping any timing/worker fields; if an unknown field
appears the run is `[U]`, not silently dropped. Floats use `float.hex()` so a
serializer change cannot fake a mismatch (or hide one). Cell counts: 64²=4,096;
240²=57,600; 320²=102,400.

### 2.3 Gates

| Gate | Rule | Threshold | Justification / label |
|---|---|---|---|
| **D1 within-size repeat** | For each size S ∈ {64,240,320}: run A vs run B, same key manifest ⇒ all five SHA-256 equal | **zero difference** (hard) | `[O]` charter §6.3 "same seed ⇒ byte-identical"; a drift means hidden state (time, dict order, RNG consumed elsewhere). No tolerance is defensible for byte identity. |
| **D2 cross-size** | Same seed/keys across sizes ⇒ key manifests equal; normalized structural fingerprint (height deciles, water/shore fraction, tile-id histogram / N, family counts / N) within band | fractions ±0.02 absolute, decile edges ±0.05 height units — **ADVISORY ONLY** | `[I]`/PORT APPROXIMATION. Byte-identical arrays across different N is impossible; treating it as a gate would be a fake test. Promote to red only after D02 confirms the donor's size-invariance contract; measure the three dumps first. |
| **D3 run integrity** | Every dump job: runner status ∉ {timed-out,error,skipped}; `scan-stderr.script_error_lines == 0`; `assert_clean --json` exit 0 after the batch | exact (hard) | `[O]` E16, E13, `AGENT_PROTOCOL.md:52-53`. A green dump from a dirty runner is not evidence. |

## 3. Donor-grounded structural gates

A planned `terrain_qa_harness.py structure <dump> --spec <terrain_qa_spec.json>
--policy advisory|red --json` computes the metrics below. The **spec file** is to be
populated by D03–D08/F03–F08 with cited donor ranges; until then all range checks
run `advisory` and emit `status: UNVERIFIED` — the harness never manufactures a
donor range. Hard gates (illegal id, unknown stamp, run integrity) apply in both
policies.

| Gate | Metric definition | Threshold | Justification / label |
|---|---|---|---|
| **S1 height deciles** | 10 equal-count deciles of float32 `height`; plus occupancy of the 5 donor bands `(<-2.964, -2.964..-1.1, -1.1..0, 0..1.317, >1.317..2.964)` via E06 | no decile > 0.85 of cells; ≥3 of 5 bands occupied; band proportions within spec range once populated | `[I]` sanity against the "flat/narrow spike" symptom (`A11:156-161,171-181`); `[D]` band edges from E06/E05. Not donor-measured. |
| **S2 water fraction** | `count(tileblock == 255)/N` (`game.gd:52`) | id **must be 255** (hard); advisory band `[0.05,0.45]` on `map_type=land` | `[D]` id; `[I]` band. Land skirmish must show sea but not be mostly sea (charter §1). Water-free 64² fixture → `RECORDED_NOT_APPLICABLE`, not FAIL (`G21:139`). |
| **S3 shore fraction** | land cells 4-adjacent to water `/N`; plus `shore/water` ratio | advisory `[0.02,0.25]`, ratio `[0.2,1.5]` | `[I]`; charter §1 requires a readable shore; D06/F03 will supply the real band. |
| **S4 tile-id histogram** | counts per `tileblock` id; distinct land ids; top-1 share; illegal ids (`id` not in the donor-derived preset name list used by `build_tile_index_atlas.py:76,273`) | illegal ids **= 0** (hard); advisory distinct ≥ 8, top-1 share ≤ 0.60 | `[I]` anti-flat-field check (`A11:158`); legal-id domain from donor-derived atlas, F05 pending. |
| **S5 relief candidates** | `relief_stamps[]` names and `(cx,cy)` vs `assets/terrain/patterns/donor_patterns.json` | every name ∈ catalogue (hard); count within spec range (advisory); `k_ravine_1` presence ⇒ `[U]` | `[O]` E07 — donor catalogue is the only legal source; charter §4 "no new donor constants". Cross-check stamp centres against the height field once D05 lands. |
| **S6 pattern families** | family counts from stamp/prop names vs weights from `generator.cfg` (E06) | unknown family **= 0** (hard); observed/expected ratio ∈ `[0.5,2.0]` advisory | `[D]` weight source; `[I]` ratio band. F02/F08 supply the family catalogue; D07 supplies exact counts. |
| **S7 mine/field/forest** | counts by `res[].t`: gold/iron/coal mines, mill/field family, forest/tree and stone/quarry families; per-start radial histogram of mine distances from nearest `starts[]` | advisory: gold/iron/coal ≈ 9 sites per start (3 kinds × 3 rounds, band `[6,9]`, 256 attempts each — E06), ≥1 field family per start, ≥1 forest and ≥1 stone family on land maps; ring peaks near 28–44 / 64–84 / 100–124 cells where in bounds | `[D]` E06 constants; `[I]` bands. At 64² rings exceed the map → record `OUT_OF_BOUNDS`, never lower the count gate. D07/F07/F08 must replace these with donor-measured ranges. |

All range checks record `{threshold, observed, within, label, evidence}`; an
`advisory` FAIL never silently becomes PASS, and a `red` gate is never lowered.

## 4. Visual A/B protocol (legitimate metric only)

**Corpus (read-only, E17).** `C:\Users\Maxym.Oboyshev\Downloads\c3\`: the 12
A11 files, including `cossacks-3-v1-498085.jpg` (ref A, ROI `.35,.55,.48,.70`),
`articolo-787.jpg` (ref B), plus `MADVBuilding1.JPG`. Full resolutions 480×360 to
2355×1376; JPEG/WEBP, unknown build/camera/downsampling. `[O]` file facts;
donor-parity status `[U]`.

### 4.1 Admissibility (before any number counts)

Carry G0-a…e verbatim (`G21:52-58`): windowed launch (no `--headless`); PNG exists
1280×720 non-blank (plus capture diag `camera_current=true`,
`world_parent=Screenshot3DViewport`); `scan-stderr.script_error_lines: 0`; seed,
camera, size, config pinned and recorded; ground-only ROI chosen and **the same
fractional ROI applied to both sides**. A failed sub-item makes the dependent
comparison UNVERIFIED → FAIL; don't substitute green JSON or another capture.

### 4.2 What is legitimate

1. **Candidate-after vs candidate-before, same camera/seed/harness:** PNG vs PNG,
   `--crop x,y,w,h` identical on both — the like-with-like case (`C01:181`).
   Advisory direction bands from A11/G21 (not gates, not parity): `BV32 n640`
   8.7 → ≈150–270; `grad n640` 5.00 → ≈1–2; `luma std` 10.6 → ≈18–22;
   `mean_saturation` 0.675 → ≈0.53 (secondary only); all four block scales must
   rise in step (`A11:167-187`, `G21:114-128`). Use C01's raw-crop proxies only for
   **direction of movement**, never as A11 absolute values (`C01:205-217`).
2. **Candidate vs donor folder distribution:** `--compare-ref` with `--crop-frac`
   per image. `distribution`, `z`, `outside_donor_range` are calibration hints
   only; `flags` are heuristic prompts, not verdicts (`C01:48-60`, `G21:250`).
3. **Candidate-A vs candidate-B determinism at pinned camera:** `compare_shots.py`
   with `--threshold 0.9999` is legitimate here — same scene, same camera, so
   SSIM/MAD ≈ 1.0 is a real reproducibility check. It is **illegitimate** for
   donor-vs-candidate parity: different scenes, cameras and compression make any
   single score meaningless (`E12`, `C01:176-188`).
4. **Visual cards R1–R6** from `G21:131-177` on named pixel boxes; R7/R8 require
   CAP-3 drag/ghost frames and are UNVERIFIED from terrain stills (`G21:178-190`).
   Record metric and prose in **two separate fields**; a green number never erases
   a visible grid/streak/blotch/seam, and a red number never invents one
   (`G21:241-250`).

**Forbidden:** whole-frame vs cropped-donor comparison (`C01:210-211`);
"donor match/parity/confirmed" wording; using the 0.80 `compare_shots.py` default
as a gate; dropping a region to avoid an artifact; rerunning until green
(`G21:258-273`). Required reviewer line verbatim: "PORT APPROXIMATION — internal
consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this
review certifies neither donor fidelity nor a gate pass." (`G21:230`).

## 5. Gate sequence

| Step | Gate | Evidence | On FAIL |
|---|---|---|---|
| G0 preflight | `app/` sha256 manifest equals recorded baseline; `git status` shows no `app/` change; `godot_runner.py status` no pending job; `assert_clean --json` exit 0 | E15, E16 | STOP; do not queue |
| G1 static | `python -m py_compile` on new tools; runner `--check-only --script res://scripts/terrain_donor_*.gd`; no donor binary in repo | `AGENT_PROTOCOL.md:55-59` | STOP; fix cited cause |
| G2 determinism | D1 (all three sizes) + D3 | §2.3 | rollback (§6) |
| G3 structure | S1–S7 in `advisory`; promote to `red` only after donor spec + COORD sign-off | §3 | advisory FAIL → report; red FAIL → rollback |
| G4 visual | G0-a…e admissibility → §4.2 metrics → R1–R8 cards → sign-off | §4 | UNVERIFIED required item ⇒ `RESULT IS NOT GOOD` (`G21:194-219`) |
| G5 regression | selftest 29/29, uitest 17/17, `t_render_mode` PASS `seam_missing=false`, `assert_clean` CLEAN, `app/` hash unchanged | E15, `STATUS_WAVE7_PHASE2.md:24-27` | rollback; re-run G5 to green |
| G6 sign-off | COORD checks all 30 reports, writes `spec/`, integrates | `SWARM_BOARD.md:39-45` | no worker self-certifies |

Ordering rationale: determinism before structure (a non-reproducible map makes a
histogram meaningless), structure before visual (structural FAIL explains a visual
FAIL), regression last (it must cover the final integrated tree, not an interim
one). Gate items are read from their own reports, never inferred from a PNG or a
metric (`G21:251`).

## 6. Rollback criteria

Trigger any one: D1 byte mismatch; D3 dirty runner; any red structural FAIL; a
visible R1–R6 FAIL with or without green metrics; headless, blank, wrong-size or
root-texture capture; `app/` hash drift; a deleted assertion/lowered threshold;
a new donor constant without a donor path:offset citation; any donor-parity claim;
a required UNVERIFIED item at sign-off.

Action: switch composition back to legacy `world3d_terrain.gd` behind the existing
switch (`CHARTER.md:61`), restore any touched file from `inbox/backup/<name>.bak-<id>`
(`AGENT_PROTOCOL.md:11`), re-run G5 to green, record the reason in the report's
`rollback` block. **No rerun-for-green, no threshold lowering, no assertion
deletion** (`G21:258-273`). Analysis workers (including A05) never perform the
rollback; COORD does.

## 7. JSON report schema (planned)

`terrain_qa_report/1` — emitted by `python variant3d\tools\terrain_qa_harness.py
report --manifest <manifest.json> --json`:

```json
{
  "schema": "terrain_qa_report/1",
  "run_id": "A05-<timestamp>", "worker": "A05", "created_utc": "…",
  "parity": {"claim": "NONE", "status": "UNVERIFIED",
             "note": "PORT APPROXIMATION — internal consistency only; no donor GPU A/B frame"},
  "key_manifest": {
    "generation": {"random_seed": 20261113, "map_w": 240, "map_h": 240,
                   "map_type": "land", "start_option": "default", "seed_keys_sha256": "…"},
    "capture": {"pitch_degrees": -32.0, "fov_deg": 17.27, "start_zoom": 0.3448276,
                "pixels_per_meter": 16.0, "window": [1280, 720]},
    "config_sha256": "…", "overlay_sha256": "…"
  },
  "inputs": [{"role": "dump|png|spec|stderr", "path": "…", "sha256": "…", "label": "O"}],
  "gates": [{
    "id": "D1|G2|S3|R2|G5-selftest|…", "kind": "hard|advisory",
    "status": "PASS|FAIL|UNVERIFIED|NOT_APPLICABLE|RECORDED_NOT_APPLICABLE",
    "policy": "advisory|red", "threshold": "…", "observed": "…",
    "labels": ["D"], "evidence": ["E05", "docs/…:line"],
    "justification": "…"
  }],
  "determinism": {"sizes": [
    {"n": 4096, "runs": ["A","B"],
     "fingerprints": {"height":"sha256:…","tileblock":"sha256:…","terrain":"sha256:…",
                      "blocked":"sha256:…","props":"sha256:…"},
     "pairwise_equal": true}
  ], "cross_size": {"status": "ADVISORY", "max_fraction_delta": 0.0}},
  "structure": {"n": 4096, "height_deciles": [], "donor_band_occupancy": [],
                "water_fraction": 0.0, "shore_fraction": 0.0,
                "tilehist": {}, "illegal_tile_ids": 0, "relief_stamps": [],
                "unknown_stamp_names": [], "family_counts": {}, "res_counts": {}},
  "visual_ab": {
    "admissibility": {"windowed": true, "size_ok": true, "script_error_lines": 0,
                      "capture_diag_verified": true},
    "roi_frac": [0.35, 0.55, 0.48, 0.70],
    "metric_field": {"tool": "terrain_ab_metric/1", "command": "…", "values": {}},
    "visual_field": {"cards": [], "reviewer": "…", "parity_phrase_verbatim": "…"},
    "donor_distribution": {"tool": "terrain_ab_metric/1", "hint_only": true},
    "self_determinism": {"tool": "compare_shots.py", "score": 1.0, "purpose": "same-scene only"}
  },
  "regression": {"selftest": "29/29", "uitest": "17/17",
                 "t_render_mode": "PASS seam_missing=false",
                 "assert_clean": "CLEAN", "app_sha256_unchanged": true},
  "rollback": {"triggered": false, "reason": null, "restored_to": null},
  "unverified": [], "open_questions": [], "end": "*End of report.*"
}
```

Invariants: every numeric claim carries `labels` + `evidence`; `metric_field` and
`visual_field` are never merged; `status: UNVERIFIED` is never converted to PASS;
`parity.claim` is always `"NONE"`.

## 8. Exact planned CLI commands (NOT RUN)

All commands are **repo-root relative**, use `python` (not `python3`), and use
`<T>` = `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\a05\`. Runner jobs are
submitted by COORD / implementation owner with **unique ids**; A05 submits none.

```powershell
# --- G0 preflight / G5 regression (forms from E15) ---
python variant3d\tools\assert_clean.py --json
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id a05-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id a05-uitest --timeout 240 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
python variant3d\tools\godot_runner.py run --id a05-t-render-mode --timeout 90 -- --headless --path variant3d --script res://tests/t_render_mode.gd

# --- G2 determinism: 2 runs x 3 sizes; absolute overlays, pinned seed (E14) ---
# 64² fixture exists; 240²/320² overlays are PLANNED files, to be created by COORD.
python variant3d\tools\godot_runner.py run --id a05-dump-64-a --timeout 300 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config <T>\small_map_64.json --dump-map <T>\a05_64_a.json --timeout 120
python variant3d\tools\godot_runner.py run --id a05-dump-64-b --timeout 300 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config <T>\small_map_64.json --dump-map <T>\a05_64_b.json --timeout 120
python variant3d\tools\godot_runner.py run --id a05-dump-240-a --timeout 300 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config <T>\map_240.json --dump-map <T>\a05_240_a.json --timeout 120
python variant3d\tools\godot_runner.py run --id a05-dump-240-b --timeout 300 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config <T>\map_240.json --dump-map <T>\a05_240_b.json --timeout 120
python variant3d\tools\godot_runner.py run --id a05-dump-320-a --timeout 300 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config <T>\map_320.json --dump-map <T>\a05_320_a.json --timeout 120
python variant3d\tools\godot_runner.py run --id a05-dump-320-b --timeout 300 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config <T>\map_320.json --dump-map <T>\a05_320_b.json --timeout 120

# --- planned pure-Python harness (no Godot) ---
python variant3d\tools\terrain_qa_harness.py fingerprint <T>\a05_64_a.json <T>\a05_64_b.json --json
python variant3d\tools\terrain_qa_harness.py compare-runs --manifest <T>\a05_manifest.json --json
python variant3d\tools\terrain_qa_harness.py structure <T>\a05_320_a.json --spec docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json --policy advisory --json

# --- G4 windowed capture (no --headless; --screenshot after the second --) ---
python variant3d\tools\godot_runner.py run --id a05-ab-capture --timeout 120 --max-wait 3600 -- --path variant3d -- --config <T>\map_320.json --screenshot <T>\a05_ab_after.png --timeout 60
python variant3d\tools\smallmap_capture.py stats <T>\a05_ab_after.png
python variant3d\tools\smallmap_capture.py scan-stderr <T>\a05_ab_capture_stderr.txt

# --- visual metric: same crop on both PNGs; donor distribution on matched ROI ---
python variant3d\tools\terrain_ab_metric.py <T>\a05_ab_after.png <T>\a05_ab_before.png --crop 200,150,800,500 --json
python variant3d\tools\terrain_ab_metric.py <T>\a05_ab_after.png --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --crop-frac .35,.55,.48,.70 --json --per-file

# --- self-determinism ONLY (same scene/camera), never donor parity ---
python variant3d\tools\compare_shots.py --shot <T>\a05_ab_after.png --ref <T>\a05_ab_repeat.png --threshold 0.9999 --json

python variant3d\tools\terrain_qa_harness.py report --manifest <T>\a05_manifest.json --json
python variant3d\tools\assert_clean.py --json
```

`--crop-frac .35,.55,.48,.70` is A11's ref-A ground ROI (`A11:77`) resolved per
image; `--crop 200,150,800,500` is an identical *pixel* box for the two 1280×720
PNG captures (`C01:94-96`). If scene composition differs, relocate by description
and record the new box (`G21:43`).

## 9. Implications

- **For implementers:** the fresh terrain module must emit a complete, stable
  `--dump-map` contract (E03) including `meta` generation keys and prop arrays;
  without it, no deterministic gate exists. Donor-derived asset names must be
  cited, or S5/S6 fail.
- **For COORD:** populate `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json`
  from D03–D08/F03–F08 with donor path:offset evidence, then flip `--policy red`
  explicitly. Until then the harness is an instrument, not a gate.
- **For reviewers:** visual sign-off is a second-agent read; A05's numbers are
  corroboration only. `RESULT IS NOT GOOD` until CAP-3 frames exist for R7/R8.
- **For the final verdict:** the honest outcome is "gates green / internal
  consistency PASS / donor parity UNVERIFIED", never "donor match".

## 10. Risks

1. **Donor stills are confounded** (camera, zoom, units, cliffs, JPEG): all visual
   bands are order-of-magnitude direction only (`A11:188-212`).
2. **Map-size ambiguity:** `config.json:75-76` says 240² while
   `small_map_64.json:6` claims shipped 320² — the wrong canonical size would make
   three "different-size" runs actually identical. Resolve via explicit overlays.
3. **Size-invariance of the RNG is unknown** until D02 lands; D2 is deliberately
   advisory to avoid a fabricated red gate.
4. **Float/serialization drift** could fake D1 FAIL or PASS; hashing raw bytes and
   `float.hex()` removes serializer dependence but not a genuine RNG change.
5. **Concurrent P03** had not landed at read time (E18); its gate/capture inventory
   may change the command forms — reconcile before integration.
6. **Runner serialization:** queue waits of 100–400 s are normal
   (`AGENT_PROTOCOL.md:39-51`); do not re-submit a pending job.
7. **`app/` drift:** any accidental edit breaks charter §3; G0/G5 hash it.
8. **False parity via one number:** `compare_shots.py`'s 0.80 default or a donor
   z-score must never be presented as fidelity (`E12`, `C01:29`).

## 11. UNVERIFIED register

| Item | Status | Owner ticket |
|---|---|---|
| Donor height histogram deciles / water-shore fractions / tile-id histogram / family & resource counts as concrete ranges | UNVERIFIED — spec slots only | D03–D08, F03–F08 |
| Donor RNG size-invariance contract (legal meaning of cross-size byte identity) | UNVERIFIED; D2 advisory | D02 |
| `k_ravine_1` relief producer | UNVERIFIED/blocked — absent from donor catalogue (`main.gd:774-776`) | D05 / F02 |
| Donor GPU A/B frame (required for any parity statement) | UNVERIFIED — does not exist | COORD |
| CAP-3 drag/ghost frames for R7/R8 | UNVERIFIED from terrain stills | G21 follow-up |
| Which map size is canonical (240² vs 320²) | UNVERIFIED — contradictory configs (E14) | COORD |
| P03 gate/capture inventory | UNVERIFIED — report not landed (E18) | P03 |
| Whether `meta` contains all generation keys | UNVERIFIED until inspected on a real dump | A02/A06 |

## 12. Open questions

1. **Q1 (COORD):** canonical size — `config.json:75-76` = 240², `small_map_64.json:6`
   says shipped 320²; which config backs the 320² dump? Explicit overlay recommended.
2. **Q2 (P03/COORD):** does the concurrent P03 report change the gate command forms
   or add a capture tool A05 must call? Reconcile on landing.
3. **Q3 (D02):** is cross-size byte identity a donor property or only a port
   invariant? If donor has a single 320-cell size, D2 should stay advisory.
4. **Q4 (D06/F03):** what are the real donor water/shore fraction ranges for a
   `map_type=land` skirmish, and does the 64² fixture legitimately have zero water?
5. **Q5 (D07/F07/F08):** exact mine/field/forest counts per start and global, to
   replace the `[D]`/`[I]` bands in S7.
6. **Q6 (A06):** who owns CAP-3 frames and the independent second-agent visual read?
7. **Q7 (COORD):** at what evidence threshold may `--policy` flip to `red` —
   spec populated, or spec + one verified donor GPU frame? A05 recommends the
   former for structural gates, the latter never for visual parity.

---

*End of A05. Design only: no code, asset, config, test or tool edit; no Godot job
submitted; no donor file copied; no donor-parity claim made.*
