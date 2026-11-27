---
id: PORT1TO1-ROI-METRICS-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER ROI-METRICS — executed compare_frames.py over the 14 verified ROI locators; metrics ONLY, no parity verdict
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_metrics.md
status: DELIVERED__14_COMPARISONS_EXECUTED__0_REFUSALS__PARITY_UNVERIFIED__ONE_REPORT_ONLY
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION]
parity_status: UNVERIFIED
parity_claim: false
scope_guard: "Exactly one repository file written (this report). No source, shader, asset, config, test, fixture, Godot process, donor binary, git state, existing report or pre-existing artifact was edited. 14 diff PNGs and 14 metrics JSONs were newly written ONLY under inbox/qa/captures/roi_metrics_20261113/. No donor execution, no Godot, no git. No ROI, provenance string or camera label was altered to force a pass; --assert-ab-verified was not supplied to any command."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md  (§1 inventory, §2 command contract, §3 ROIs R01–R14, §5 copy-paste commands, §6 refusals, §8 [U] legend)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md  (§1.2/§1.3, §4, §5, §6)
  - variant3d/tools/acceptance/compare_frames.py  (source read, lines 43–257)
  - variant3d/tools/acceptance/imgio.py  (save_png parent creation, line 189)
  - inbox/qa/captures/fullport6_seq2_20261113/manifest.json  (F0 resolution + sha256_file, read-only)
---

# PORT1TO1 — executed ROI metrics (14 locators, all `parity=UNVERIFIED`)

> **Required reviewer line, verbatim (W05 §7.3 / PREP-VIDEO §5 / W08 §0):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **No metric constitutes parity.** `compare_frames.py` printed `parity=UNVERIFIED (metrics never constitute donor parity)` on every one of the 14 successful runs. MAE, RMSE, max error, differing-pixel count/fraction, Pearson pixel correlation, histogram correlation and every diff PNG are **support cues only**. No threshold is defined; no similarity %, donor-threshold PASS, "matches donor" or gate PASS claim is admissible anywhere in this report.

> **Why every row is UNVERIFIED:** the donor files are third-party H.264 extracts of unknown build/map/camera/zoom/compression and the port frame F0 is a port-internal viewport capture. The `--camera NOT_SHARED_donor-oblique_vs_port-17p27` value is a mandatory-field marker recording that **no shared camera is asserted**; it is not a camera match. The harness applies one pixel box to both frames without rescaling, clamping or inferred alignment, and cannot verify donor identity, camera equality or ROI correctness. The blocking `[U]` set (PT-V1 controlling, plus P0-1…P0-8, W-R1, T-SEED/T-CALLBACK, atlas-layout and the domain residuals listed in the register §8 / acceptance plan §6) is still non-empty. Therefore **every row below is `parity=UNVERIFIED`**, independent of its numeric values.

---

## 0. Scope of this pass [O]

- Read-only inputs: `PORT1TO1_roi_register.md` §1–§8, `PORT1TO1_acceptance_plan.md` §1.2/§1.3/§4/§5/§6, `compare_frames.py`, `imgio.py`, and `fullport6_seq2_20261113/manifest.json`.
- Executed: 14 invocations of `variant3d/tools/acceptance/compare_frames.py` with Python 3.14.3 from the repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.
- Outputs written **only** to `inbox/qa/captures/roi_metrics_20261113/` (14 `.png` + 14 `.json`); the directory did not exist before this pass and was created by `imgio.save_png` / the report writer.
- Not executed: donor binary, Godot, `godot_runner.py`, any capture/contact/MP4 step, git. No existing file was edited or overwritten.
- The only change from the register §5 copy-paste commands is the **output directory**: `--out-diff` and `--report` were redirected from `inbox/qa/captures/` to `inbox/qa/captures/roi_metrics_20261113/`. Every `--donor`, `--port`, `--roi`, `--roi-source` and `--camera` value is the register value verbatim.

### 0.1 Command contract observed in all 14 runs [O]

| Field | Value used | Source |
|---|---|---|
| Tool | `variant3d/tools/acceptance/compare_frames.py` | register §2 |
| `--port` (F0) | `inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png` — view label, port pixels; manifest `sha256_file=6fc7dfab26ea04429db165c4327604908b892cfa4707605d5eda32e8a6f4ba80`, 1280×720 | register §1.2 |
| `--donor` | `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\t_*.png`, 1280×720, all 12 files present before the run | register §1.1 |
| `--camera` | `NOT_SHARED_donor-oblique_vs_port-17p27` — exact register marker, no shared-camera assertion | register §2 |
| `--roi-source` | Exact register §5 provenance string per ROI, including the closing `locator only, no same-camera claim` | register §5 |
| `--config-donor` / `--config-port` | Not supplied (single port config cannot be paired with a donor H.264 frame) | register §2 |
| `--assert-ab-verified` | **Not supplied** in any command; all reports have `owner_assertion: null`, `claim: null` | register §2 |
| `--hist-bins` | Default 16 (not overridden) | tool default |
| `--amplify` | Default 1.0 (not overridden); all diff images recorded `mode=abs_diff_exact`, `amplify=1.0` | tool default |
| Dispatch | PowerShell argument array from repo root so the provenance text was passed byte-for-byte; equivalent single-line commands are reproduced in §2 | this pass |

---

## 1. Results — 14 rows, all `parity=UNVERIFIED`

Metrics below are copied from the executed stdout and the corresponding JSON (`overall` = mean MAE / RMSE across R,G,B, max across channels, differing pixels where **any** channel differs). `pixel_corr` is Pearson pixel correlation, printed per channel. Every row is a support-cue measurement of two unrelated images, **not** a donor comparison verdict.

| ROI id | t / donor file | `--roi x,y,w,h` | Overall MAE | Overall RMSE | max | differing px (fraction) | pixel_corr R / G / B | hist_corr R / G / B | parity |
|---|---|---|---:|---:|---:|---:|---|---|---|
| R01 | `t_0.png` 00:00 | `400,350,500,300` | 15.1416 | 21.7783 | 211 | 149999 / 90000 (0.999993) | -0.023286 / -0.026199 / -0.002246 | 0.717886 / 0.636962 / 0.673633 | UNVERIFIED |
| R02 | `t_120.png` 00:02 | `920,140,360,250` | 25.0324 | 34.0541 | 245 | 90000 / 90000 (1.000000) | 0.036016 / 0.018576 / 0.021560 | 0.746713 / 0.797627 / 0.517450 | UNVERIFIED |
| R03 | `t_300.png` 00:05 | `640,360,640,360` | 21.4815 | 32.3773 | 255 | 230399 / 230400 (0.999996) | -0.001858 / -0.169451 / -0.059483 | 0.822482 / 0.710883 / 0.579041 | UNVERIFIED |
| R04 | `t_300.png` 00:05 | `640,500,460,200` | 14.5947 | 19.9219 | 186 | 91999 / 92000 (0.999989) | -0.000202 / 0.087123 / -0.047924 | 0.893077 / 0.826134 / 0.528126 | UNVERIFIED |
| R05 | `t_300.png` 00:05 | `180,300,240,170` | 11.9324 | 16.9626 | 197 | 40800 / 40800 (1.000000) | -0.001158 / -0.037144 / 0.010400 | 0.811703 / 0.799693 / 0.587319 | UNVERIFIED |
| R06 | `t_600.png` 00:10 | `0,60,640,300` | 13.2659 | 18.6066 | 188 | 192000 / 192000 (1.000000) | -0.017583 / -0.016170 / -0.017305 | 0.774539 / 0.599567 / 0.621256 | UNVERIFIED |
| R07 | `t_600.png` 00:10 | `200,280,280,170` | 15.0119 | 19.3533 | 177 | 47600 / 47600 (1.000000) | -0.094836 / -0.080800 / -0.038465 | 0.806197 / 0.618958 / 0.450707 | UNVERIFIED |
| R08 | `t_1200.png` 00:20 | `400,350,500,250` | 18.6425 | 24.4154 | 215 | 124999 / 125000 (0.999992) | -0.079596 / -0.074942 / -0.053639 | 0.744631 / 0.623183 / 0.424713 | UNVERIFIED |
| R09 | `t_1200.png` 00:20 | `900,140,180,150` | 32.8653 | 44.9533 | 220 | 27000 / 27000 (1.000000) | -0.070624 / -0.092698 / 0.105148 | 0.823636 / 0.804261 / 0.555611 | UNVERIFIED |
| R10 | `t_1200.png` 00:20 | `400,230,100,100` | 27.4196 | 42.6640 | 196 | 10000 / 10000 (1.000000) | -0.123648 / 0.014393 / -0.035307 | 0.796737 / 0.834423 / 0.477747 | UNVERIFIED |
| R11 | `t_1800.png` 00:30 | `620,40,110,90` | 29.5915 | 44.4733 | 247 | 9900 / 9900 (1.000000) | -0.094171 / -0.123552 / -0.017075 | 0.826823 / 0.719885 / 0.482569 | UNVERIFIED |
| R12 | `t_1800.png` 00:30 | `1060,220,110,110` | 28.4400 | 38.9988 | 255 | 12100 / 12100 (1.000000) | 0.058590 / 0.016545 / 0.052601 | 0.852665 / 0.818482 / 0.474013 | UNVERIFIED |
| R13 | `t_1800.png` 00:30 | `380,280,530,280` | 26.6915 | 38.3579 | 222 | 148400 / 148400 (1.000000) | 0.034177 / 0.008474 / 0.035432 | 0.782365 / 0.693712 / 0.428859 | UNVERIFIED |
| R14 | `t_2100.png` 00:35 | `0,0,1280,360` | 25.8626 | 37.7640 | 255 | 460795 / 460800 (0.999989) | -0.003384 / 0.018774 / -0.004010 | 0.614529 / 0.504117 / 0.497911 | UNVERIFIED |

Notes on the table [O]/[D]:

- "differing px (fraction)" is `differing_pixels_any_channel / (w*h)`; the denominator `w*h` is shown after the slash. Four rows have a fraction just below 1.0 because 1–5 pixels happened to match on all three channels; this is a measured value, not a pass.
- Per-channel MAE/RMSE/max, histogram intersection/chi-square and the full 16-bin histograms are in the JSON reports (§3). No value in this table was rounded for any verdict purpose; shown values are the printed 4-decimal stdout values.
- Near-zero or slightly negative/positive pixel correlation across all rows is expected for two unrelated frames and is **not** interpreted here as anything beyond a support cue.

### 1.1 Diff artifacts (all under `inbox/qa/captures/roi_metrics_20261113/`) [O]

| ROI id | Diff PNG | PNG SHA-256 | Metrics JSON |
|---|---|---|---|
| R01 | `diff_roi_R01_t0_d1.png` | `44dc8622c349dd43750db492b8da871a3291a9ed6372fa2c68d1875953edfdca` | `diff_roi_R01_t0_d1.json` |
| R02 | `diff_roi_R02_t120_d6.png` | `0caec11f6e514f88668f2a1975b909a36a3ecb3d286b24f457723da82e1012ce` | `diff_roi_R02_t120_d6.json` |
| R03 | `diff_roi_R03_t300_d1.png` | `a6b816493095a63df15cfd338180ca961092c51db72f039cd4317a871d1a0d55` | `diff_roi_R03_t300_d1.json` |
| R04 | `diff_roi_R04_t300_d3.png` | `db3bfb58c6a5ed0c65fc9a8067c87c0d9a3ed661b07d0ba1c558d9c7174bf82c` | `diff_roi_R04_t300_d3.json` |
| R05 | `diff_roi_R05_t300_d5.png` | `cb1d037f139ed5eb553fa07811d0717282aac410d65cbfb70eaa9679d77e4b5d` | `diff_roi_R05_t300_d5.json` |
| R06 | `diff_roi_R06_t600_d4.png` | `4813a85cf6680b00284cec38ddd66b39211bbd5dc6cda0d6d14a92e513e346b7` | `diff_roi_R06_t600_d4.json` |
| R07 | `diff_roi_R07_t600_d3.png` | `2c4e87966e4ca38cc8ebd3f05b210c7cc5ba7b9bd4caf652117c6300720b5486` | `diff_roi_R07_t600_d3.json` |
| R08 | `diff_roi_R08_t1200_d1.png` | `a73c15c1f2b0ee2f28b6b3c5ff1e767437ba5e8e6a8d7bf8b7fb10ccfd388e77` | `diff_roi_R08_t1200_d1.json` |
| R09 | `diff_roi_R09_t1200_d5.png` | `a1a336cd43cc67274f573a61e5cb633f17955f5d70886afa02d9987e45238a09` | `diff_roi_R09_t1200_d5.json` |
| R10 | `diff_roi_R10_t1200_d7.png` | `a803dfa1c01ec4478e21ff101e44d163aafae33fd06a6f8f7de004042127e645` | `diff_roi_R10_t1200_d7.json` |
| R11 | `diff_roi_R11_t1800_d5a.png` | `54ba3488ec079e04d59e0f6614c36475e16bb7dc5a108bab4441df61de98d4b4` | `diff_roi_R11_t1800_d5a.json` |
| R12 | `diff_roi_R12_t1800_d5b.png` | `a88590beea32a9c028efd2754787806ca296d0937dc5499d07f1aa80a36430c6` | `diff_roi_R12_t1800_d5b.json` |
| R13 | `diff_roi_R13_t1800_d6.png` | `478c9af196848a5dc27231ae12a4c223801876f41f80aa18245e0ce81926c442` | `diff_roi_R13_t1800_d6.json` |
| R14 | `diff_roi_R14_t2100_d4.png` | `b2de02875f980a135a371de926151420a31664ebedc0b22645260c26075ce602` | `diff_roi_R14_t2100_d4.json` |

All diff images are `abs_diff_exact`, `amplify=1.0`, size equal to the ROI (`w×h`), recorded `frame_size=[1280,720]`. Each JSON records `tool=compare_frames.py`, `schema=1`, both `sha256_file` values, `roi`, `roi_source`, `camera`, `config_donor=null`, `config_port=null`, `hist_bins=16`, per-channel + overall metrics, `difference_image` block, `parity="UNVERIFIED"`, `claim=null`, `owner_assertion=null`, and the tool's note that metrics cannot prove donor identity, camera equality or visual parity. Verified across all 14 JSONs.

Donor file SHA-256 values recorded in the reports: `t_0=b037afde74b9e6dbb3b807b31468da81222a24af58da768c725c7ce0d40b5c45`; `t_120=59039e2dbf2cef6ba1c15d4065c8f8ed9604296b271ffa105b5f74d6d81e6677`; `t_300=cc3baa4b557a3e246e0cead52a57c79e2c39d2be569ae00bc4c520c0c309523f`; `t_600=326a33d3120ca9379aa1a552c65cf3816654da57f37823e03a3ad1e95963dbed`; `t_1200=a98ef75b02fe66ba920cf8bbd7eb2d66b3af25c757b3eb15a6105f0c575ae187`; `t_1800=7def3a3d88f64dd3d5825ffab6121748bddb2a637dbc0bc2207c14000a96b937`; `t_2100=5e14ed4f3471d06351d833979a3bd19e7e107d8e450d23fb00b9d7a7ddf69aeb`. Every port-side hash is the F0 manifest value `6fc7dfab26ea04429db165c4327604908b892cfa4707605d5eda32e8a6f4ba80`.

---

## 2. Executed commands (one per ROI id, R01–R14) [O]

The 14 commands below are the exact argument sequences executed from the repo root, shown in equivalent single-line PowerShell form. They were dispatched via a PowerShell argument array so each `--roi-source` string was passed byte-for-byte as written in the register §5. The sole difference from register §5 is the output directory, redirected to `inbox/qa/captures/roi_metrics_20261113/`. No `--assert-ab-verified`, no config arguments, no `--hist-bins`/`--amplify` override.

```powershell
# R01 — t_0.png 00:00, D1 meadow, ROI 400,350,500,300
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_0.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 400,350,500,300 --roi-source "PORT1TO1_video_targets.md section 3 D1, donor cZW0AEupCaI t_0 meadow [400,350,900,650) => 400,350,500,300; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R01_t0_d1.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R01_t0_d1.json

# R02 — t_120.png 00:02, D6 wheat parcel, ROI 920,140,360,250
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_120.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 920,140,360,250 --roi-source "PORT1TO1_video_targets.md section 3 D6, donor cZW0AEupCaI t_120 mature wheat parcel [920,140,1280,390) => 920,140,360,250; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R02_t120_d6.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R02_t120_d6.json

# R03 — t_300.png 00:05, D1 ridge-apron grass, ROI 640,360,640,360
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_300.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 640,360,640,360 --roi-source "PORT1TO1_video_targets.md section 1 D1, donor cZW0AEupCaI t_300 right-half ridge apron [640,360,1280,720) => 640,360,640,360; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R03_t300_d1.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R03_t300_d1.json

# R04 — t_300.png 00:05, D3 ridge-foot feathering, ROI 640,500,460,200
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_300.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 640,500,460,200 --roi-source "PORT1TO1_video_targets.md section 3 D3 land-margin grammar, donor cZW0AEupCaI t_300 ridge-foot feathering [640,500,1100,700) => 640,500,460,200; land-margin only, not a shore target; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R04_t300_d3.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R04_t300_d3.json

# R05 — t_300.png 00:05, D5 rock scatter/pit, ROI 180,300,240,170
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_300.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 180,300,240,170 --roi-source "PORT1TO1_video_targets.md section 1 D5, donor cZW0AEupCaI t_300 rock scatter/pit [180,300,420,470) => 180,300,240,170; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R05_t300_d5.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R05_t300_d5.json

# R06 — t_600.png 00:10, D4 conifer belt + glades, ROI 0,60,640,300
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 0,60,640,300 --roi-source "PORT1TO1_video_targets.md section 3 D4, donor cZW0AEupCaI t_600 conifer belt and glades [0,60,640,360) => 0,60,640,300; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R06_t600_d4.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R06_t600_d4.json

# R07 — t_600.png 00:10, D3 dirt/grass feathering at rock, ROI 200,280,280,170
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 200,280,280,170 --roi-source "PORT1TO1_video_targets.md section 1 D3, donor cZW0AEupCaI t_600 dirt/grass feathering at rock [200,280,480,450) => 200,280,280,170; land-margin only, not a shore target; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R07_t600_d3.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R07_t600_d3.json

# R08 — t_1200.png 00:20, D1 inter-rock grass, ROI 400,350,500,250
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1200.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 400,350,500,250 --roi-source "PORT1TO1_video_targets.md section 3 D1, donor cZW0AEupCaI t_1200 inter-rock grass [400,350,900,600) => 400,350,500,250; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R08_t1200_d1.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R08_t1200_d1.json

# R09 — t_1200.png 00:20, D5 minehead hut + apron, ROI 900,140,180,150
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1200.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 900,140,180,150 --roi-source "PORT1TO1_video_targets.md section 3 D5, donor cZW0AEupCaI t_1200 wooden minehead and rock apron [900,140,1080,290) => 900,140,180,150; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R09_t1200_d5.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R09_t1200_d5.json

# R10 — t_1200.png 00:20, D7 red church, ROI 400,230,100,100
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1200.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 400,230,100,100 --roi-source "PORT1TO1_video_targets.md section 3 D7, donor cZW0AEupCaI t_1200 red church [400,230,500,330) => 400,230,100,100; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R10_t1200_d7.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R10_t1200_d7.json

# R11 — t_1800.png 00:30, D5 top-centre mine, ROI 620,40,110,90
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1800.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 620,40,110,90 --roi-source "PORT1TO1_video_targets.md section 1 D5, donor cZW0AEupCaI t_1800 top-centre rock-pile/timber mine [620,40,730,130) => 620,40,110,90; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R11_t1800_d5a.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R11_t1800_d5a.json

# R12 — t_1800.png 00:30, D5 right mine, ROI 1060,220,110,110
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1800.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 1060,220,110,110 --roi-source "PORT1TO1_video_targets.md section 3 D5, donor cZW0AEupCaI t_1800 right rock-pile/timber mine [1060,220,1170,330) => 1060,220,110,110; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R12_t1800_d5b.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R12_t1800_d5b.json

# R13 — t_1800.png 00:30, D6 wheat parcel, ROI 380,280,530,280
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1800.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 380,280,530,280 --roi-source "PORT1TO1_video_targets.md section 3 D6, donor cZW0AEupCaI t_1800 wheat parcel around mill [380,280,910,560) => 380,280,530,280; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R13_t1800_d6.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R13_t1800_d6.json

# R14 — t_2100.png 00:35, D4 forested middle ground, ROI 0,0,1280,360
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_2100.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 0,0,1280,360 --roi-source "PORT1TO1_video_targets.md section 3 D4, donor cZW0AEupCaI t_2100 forested middle ground + cavalry grass [0,0,1280,360) => 0,0,1280,360; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R14_t2100_d4.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R14_t2100_d4.json
```

---

## 3. Refusals [O]

**No comparison refused.** All 14 invocations exited with `EXIT=0`, emitted no `REFUSED:` line on stderr, printed `[compare] ROI ... frames=1280x720`, the per-channel/overall metrics, the diff/report path line, and `parity=UNVERIFIED (metrics never constitute donor parity)`. The mechanical preconditions from register §6 were satisfied for every row: all mandatory arguments were present, every `--roi` was four integers with `x,y>=0`, `w,h>=1` and `x+w<=1280`, `y+h<=720`; every `--roi-source` was the long register string (>10 chars); donor and port were both 1280×720 (no resolution refusal); no config pair was supplied (no SHA-256 refusal); `--amplify` was the in-range default 1.0.

No exact refusal reason is therefore recordable — there were zero refusals. **No ROI, provenance string, camera label, resolution, frame or metric was tweaked to force a pass**, because nothing failed and no pass was sought. Where a landed donor report supplies no numeric box (register §4: `t_0` D4, `t_60`, `t_600` D1/D8, `t_900`, `t_1200` D4, `t_1500`, `t_1800` D1/D8, `t_2100` D7/D8, the `t_2260`/`t_2370` negatives, D9 camera, 4K/headless frames) **no command was invented and no comparison was run**. The port-side locator boxes in the register were not used as `--roi`, exactly as the register §0 routing rule requires.

---

## 4. Honest verdict

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — donor/port cameras are not A/B-matched (PT-V1 controlling) and the
blocking [U] set is non-empty (P0-1…P0-8, W-R1, T-SEED/T-CALLBACK, atlas-layout and the
domain residuals in register §8 / acceptance plan §6).
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = [PT-V1, PT-V2, PT-V3, PT-V4, PT-V5, PT-V6, PT-V7,
                       P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8,
                       W-R1, T-SEED, T-CALLBACK, atlas-layout, X17,
                       DEC_VIS_01_uv_mapping, DEC_VIS_03_fields, DEC_U_placement,
                       DEC_DEEP_forest_generation, DEC_SMALL_light_products,
                       DEC_U_scenecolor_glstate, DEC_U_shore_alpha]
```

Every one of the 14 rows in §1 is `parity=UNVERIFIED`: the donor and port cameras are **not A/B-matched** (the register's `--camera` marker explicitly records `NOT_SHARED`), the frames are different scenes from different sources, and blocking `[U]` items remain open. Metrics quantify a pair of images; they cannot prove donor identity, camera equality, ROI correctness or visual parity, and no metric, diff image or human assertion in this report constitutes a threshold, a similarity percentage, a donor-threshold PASS or a gate PASS.

---

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | All 12 donor PNGs, F0 and Python 3.14.3 were present before execution; the target report and `roi_metrics_20261113/` were absent | [O] read-only listing |
| 2 | 14 `compare_frames.py` runs were executed from repo root with the register's exact donor/port/ROI/`--roi-source`/`--camera`; only output paths were redirected to `inbox/qa/captures/roi_metrics_20261113/` | [O] command dispatch |
| 3 | 14 diff PNGs and 14 JSONs exist under `inbox/qa/captures/roi_metrics_20261113/`; no other artifact directory was written | [O] post-run listing |
| 4 | Every run exited 0, printed metrics and `parity=UNVERIFIED`; there were zero `REFUSED:` lines | [O] stdout/stderr capture |
| 5 | Every JSON has `parity="UNVERIFIED"`, `claim=null`, `owner_assertion=null`, `camera=NOT_SHARED_donor-oblique_vs_port-17p27`, exact register `roi_source`, `hist_bins=16`, `amplify=1.0`, `frame_size=[1280,720]` | [O] JSON read-back |
| 6 | `--assert-ab-verified` was not supplied; no ROI/provenance/camera value was changed to force a pass | [O] scope |
| 7 | No donor execution, Godot, git or edit of any existing source/config/report occurred; exactly one repository file (this report) was written | [O] scope |
| 8 | No metric constitutes parity; every row is UNVERIFIED while cameras are not A/B-matched and blocking `[U]` remain | [U] guard; register §7, acceptance plan §5/§6 |

*End of PORT1TO1_roi_metrics. Exactly one repository file written. No donor GPU A/B frame produced; 14 metrics only; parity UNVERIFIED; no approximation and no parity claim.*
