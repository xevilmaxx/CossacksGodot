---
id: PORT1TO1-ROI-REGISTER-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER ACCEPTANCE-ROI — concrete donor-timestamp -> ROI -> port-capture register for compare_frames.py (read-only planning)
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md
status: DELIVERED__READ_ONLY_PLANNING__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION]
parity_status: UNVERIFIED
parity_claim: false
scope_guard: "Exactly one repository file written (this report). No source, shader, asset, config, test, fixture, result JSON, git state, Godot process or donor binary touched. No capture, no MP4, no ROI metric and no donor A/B frame was produced. Donor frames were listed and their PNG headers read read-only; no donor execution."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_video_targets.md  (§0.1, §1 D1–D9, §3, §4)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md  (§1.1–1.3, §4, §5, §6)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_final_register.md  (§0 P0-1…P0-8, §§1–5)
  - variant3d/tools/acceptance/compare_frames.py  (source read, lines 118–257)
  - variant3d/tools/acceptance/README.md  (§Honesty contract, §3)
  - variant3d/tools/acceptance/imgio.py  (save_png parent creation, line 189)
---

# PORT1TO1 — concrete ROI register for `compare_frames.py`

> **Required reviewer line, verbatim (W05 §7.3 / PREP-VIDEO §5 / W08 §0):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **No metric constitutes parity.** `compare_frames.py` prints `parity=UNVERIFIED` on every successful run and on every refusal. MAE, RMSE, max error, differing-pixel fraction, Pearson pixel correlation, histogram correlation/intersection/chi-square, the absolute-difference PNG, `--assert-ab-verified` and this register are support cues only. No threshold is defined; no donor threshold PASS, similarity %, gate PASS or "matches donor" claim is admissible.

> **No approximations.** Every `x,y,w,h` below is an exact arithmetic conversion of a box already written in a landed donor report; nothing is estimated, interpolated or invented. Where a landed report gives no numeric box for a timestamp/defect pair, this register says **NO ROI — DO NOT RUN** and emits no command.

---

## 0. What this register does and does not establish

This register makes the harness's *mandatory arguments* concrete for the 12 donor timestamps and D1–D9 classes in `PORT1TO1_video_targets.md`. It does **not** establish that any donor frame and any port frame are the same scene, the same camera, the same zoom or the same build. The harness cannot verify donor identity, camera equality or ROI correctness (source lines 14–17, 224–228); a runnable command is therefore **not** an admissible parity comparison. Every row stays `parity=UNVERIFIED` and is blocked by the open `[U]` set in §3 and §8.

Routing rule for the ROI: the harness crops the **same** pixel box from both frames (source lines 166, 176). Donor-side locator boxes and port-side locator boxes in `PORT1TO1_video_targets.md` §3 / `PORT1TO1_acceptance_plan.md` §1.2 are **different boxes for different scenes** and cannot both be supplied to one run. This register uses the **donor-side** box verbatim as the shared `--roi` and records the port-side locator separately as a human re-location target, exactly as the acceptance plan's §4 example does (its `--roi-source` states "port side re-located on fresh wide frame (locator only)").

---

## 1. Verified on-disk inventory (read-only)

### 1.1 Donor frames — confirmed by directory listing and PNG header read

Directory: `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\` (PowerShell: `$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\`). All 12 files present; **every file is 1280×720** (IHDR width/height read read-only). Suffix is a donor video time label, not a port frame index.

| File | Video time | Bytes | Dimensions [O] | Scene class (`PORT1TO1_video_targets.md` §0.1 / `PORT1TO1_acceptance_plan.md` §1.1) |
|---|---|---:|---|---|
| `t_0.png` | 00:00 | 852046 | 1280×720 | town/forest edge, opening meadow |
| `t_60.png` | 00:01:00 | 1262731 | 1280×720 | field + mill town |
| `t_120.png` | 00:02:00 | 1162582 | 1280×720 | mature wheat square around windmill |
| `t_300.png` | 00:05:00 | 606424 | 1280×720 | rocky multi-peak ridge + forest fringe |
| `t_600.png` | 00:10:00 | 646012 | 1280×720 | dense mixed conifer belt, red building, mine works |
| `t_900.png` | 00:15:00 | 910183 | 1280×720 | large golden field, windmill, troop lines, stone blocks |
| `t_1200.png` | 00:20:00 | 1285759 | 1280×720 | wooden minehead on clustered rock + forest + church |
| `t_1500.png` | 00:25:00 | 1383561 | 1280×720 | stone city, market/stable blocks |
| `t_1800.png` | 00:30:00 | 1276426 | 1280×720 | wheat wrapping mill, army, wall, two mines |
| `t_2100.png` | 00:35:00 | 983907 | 1280×720 | ridge behind forested middle ground, cavalry mass |
| `t_2260.png` | 00:37:40 | 925192 | 1280×720 | water-candidate NEGATIVE (uniforms/UI/dark vegetation) |
| `t_2370.png` | 00:39:30 | 1382846 | 1280×720 | water-candidate NEGATIVE (battle/woods) |

No new frame may be extracted; `t_2260`/`t_2370` are negatives and are never scored as water or shore (`PORT1TO1_video_targets.md` §2 rank 5, §4 PT-V2/PT-V3; `PORT1TO1_acceptance_plan.md` §1.3).

### 1.2 Port frame used in every command

**F0** = `inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png`.

- Confirmed present by read-only listing. `01_donor` is the harness **view label**, not a donor file; the pixels are port-side.
- `inbox/qa/captures/fullport6_seq2_20261113/manifest.json` records for F0: `width=1280`, `height=720` (line 72/75), `resolution_matches_request=true` (line 95), `resolution_observed=1280×720` (lines 96–99), `sha256_file=6fc7dfab26ea04429db165c4327604908b892cfa4707605d5eda32e8a6f4ba80` (line 73), `sha256_pixels=36400d9cb2a25cb17be07db6cb1fc21837859ff172fe55043bd851812986632e` (line 74), config SHA `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` (line 65), `headless=false`, `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`, `runner_status=ok`, `runner_exit=0`, `complete=true`, `seed=20261113`, `status=ok`, `parity=UNVERIFIED`.
- F0 thus satisfies the harness's **mechanical** resolution requirement against every 1280×720 donor frame in §1.1. It is **port-internal evidence only**; no same-camera donor A/B pairing is asserted.
- F1 = `.../frame_0001.png` (SHA `bbdec7c59c7ff4799480361810a27169c41e935a550b4b08a119756429ffe2e4`) and F2 = `.../frame_0002.png` (SHA `aa657352e5f659984a337fa211272daf926ad68784dc0c29708eacb61cd47676`) are the only other verified 1280×720 port frames in that landed sequence; substitute them only with a recorded reason.

**Read-only discrepancy [O]:** `PORT1TO1_acceptance_plan.md` §0 and §8 name `inbox/qa/captures/cap_fullport6.png` and `cap_fullport7.png`. A recursive read-only listing of `inbox\qa\captures` found **no** files matching `cap_fullport*`. Those paths are therefore not used here. This register does not move, recreate or repair them.

**Never use as a port side:** `inbox/qa/captures/map_overview_4k.png` (4096×4096 top-down diagnostic) — a 1280×720 donor frame plus this file is refused on resolution (source lines 161–165; `PORT1TO1_acceptance_plan.md` §2.2). `--headless` CPU map timelapses are likewise not viewport frames (`compare_frames.py` / README §1).

---

## 2. Command contract (identical for all commands in §5)

- All commands are PowerShell, run from the repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.
- `--donor`: one of the verified `%TEMP%` filenames in §1.1, spelled exactly.
- `--port`: F0 from §1.2 (or a verified replacement). Same pixel box is applied to both images; no rescaling, no clamping, no inferred alignment (source lines 160–176).
- `--roi`: `x,y,w,h`, derived from a landed `[x0,y0,x1,y1)` box as `x=x0, y=y0, w=x1−x0, h=y1−y0`. Every box in §3 was checked: `x,y>=0`, `w,h>=1`, `x+w<=1280`, `y+h<=720`.
- `--roi-source`: mandatory provenance string (≥10 chars) naming the donor report section, timestamp and the original box; it explicitly says "locator only, no same-camera claim".
- `--camera`: `NOT_SHARED_donor-oblique_vs_port-17p27`. This is a **mandatory-field marker recording that no shared camera is asserted**, not a claim of camera equality. Donor camera/zoom/height/FOV are unknown third-party H.264 metadata (`PT-V1`); port `FOV 17.27°` is PORT APPROXIMATION / UNVERIFIED (`PORT1TO1_acceptance_plan.md` §6 P0-8, §7). Passing a friendly label such as `wide` would be an unsupported assertion.
- `--config-donor` / `--config-port`: **not supplied**. No donor config exists for these third-party frames. The port config for F0 is `variant3d/config_donor_capture.json` (SHA `aa857480…202da` in the manifest), but a single config cannot be paired with a donor H.264 frame; supplying two files that merely differ would trigger the SHA-256 refusal (source lines 170–174).
- `--out-diff`: absolute or repo-relative PNG; `imgio.save_png` creates parent directories (line 189). Outputs below are placed in the existing `inbox/qa/captures/` directory with unique names.
- `--hist-bins` defaults to 16; `--amplify` defaults to 1.0 (exact absolute difference). Neither default is changed in any command.
- `--assert-ab-verified` is **not used** in any command. Adding it would only write `claim=owner-supplied` and still print `parity=UNVERIFIED` (source lines 148–156, 254–255).

---

## 3. ROI register — 14 admissible *locators* (runnable, still UNVERIFIED)

"Justification" names the landed donor report that contains the exact numeric box. "[U] that blocks admissibility" lists the currently-open items from `DEC_U_final_register.md` §0/§§1–5 and `PORT1TO1_video_targets.md` §4 (PT-V IDs); see §8 legend. **PT-V1 applies to every row.** "Port-side locator (not used as `--roi`)" is the separate box from `PORT1TO1_video_targets.md` §3 / `PORT1TO1_acceptance_plan.md` §1.2 for human re-location only.

| ID | t / donor file | Defect / scene class | Donor box `[x0,y0,x1,y1)` | `--roi x,y,w,h` | Justification (exact source) | Port-side locator, NOT used as `--roi` | Currently-open `[U]` making comparison inadmissible |
|---|---|---|---|---|---|---|---|
| R01 | `t_0.png` 00:00 | D1 ground / opening meadow | `[400,350,900,650)` | `400,350,500,300` | `PORT1TO1_video_targets.md` §3 D1 row (line 292); §1 D1 meadow observation (lines 71–76) | P-WIDE frame 0020 playfield centre (no numeric box) | PT-V1; PT-V6; W-R1; T-SEED/T-CALLBACK; atlas-layout `[U]` (`DEC_U_atlas_layout.md`); `DEC_VIS_01_uv_mapping.md`; P0-3 F-GRID-a–e + persistence; P0-8 F-V1/V2 |
| R02 | `t_120.png` 00:02 | D6 field / mature wheat square at windmill | `[920,140,1280,390)` | `920,140,360,250` | `PORT1TO1_video_targets.md` §3 D6 row (line 297); §1 D6 primary parcel (lines 185–190) | P-COL checkerboard `[1080,230,1280,400)` → `1080,230,200,170`; mill clearing `[1010,180,1130,340)` → `1010,180,120,160` | PT-V1; PT-V7; P0-7 S-RNG-G1; T-SEED/T-CALLBACK; `DEC_VIS_03_fields.md` `[U]`; `DEC_U_placement.md`; W-R1 (X17 `rgb*=mask` approximation, pass count `[U]`) |
| R03 | `t_300.png` 00:05 | D1 ground / ridge-apron pasture | `[640,360,1280,720)` | `640,360,640,360` | `PORT1TO1_video_targets.md` §1 D1 "right-half ridge apron" (line 74); `PORT1TO1_acceptance_plan.md` §1.2 D1 | P-WIDE frame 0020 centre (no numeric box) | PT-V1; PT-V6; W-R1; T-SEED/T-CALLBACK; atlas-layout `[U]`; P0-3 F-GRID-a–e; P0-8 F-V1/V2 |
| R04 | `t_300.png` 00:05 | D3 land-margin grammar / ridge-foot feathering | `[640,500,1100,700)` | `640,500,460,200` | `PORT1TO1_video_targets.md` §3 D3 row (line 294); §1 D3 (line 118); `PORT1TO1_acceptance_plan.md` §1.2 D3 | P-SHORE block boundary + step fringe (no numeric box); P-WATER-TOP blob rims | PT-V1; PT-V3 (no beach/foam reference in this video); W-R1; `DEC_U_shore_alpha.md` intensity-arithmetic `[U]`; P0-3 F-GRID-a–e |
| R05 | `t_300.png` 00:05 | D5 mine / open rock scatter + grass tongues | `[180,300,420,470)` | `180,300,240,170` | `PORT1TO1_video_targets.md` §1 D5 (line 163) | P-NAT halos `[230,560,420,650)`→`230,560,190,90`; `[280,140,400,210)`→`280,140,120,70`; `[1050,440,1190,530)`→`1050,440,140,90` | PT-V1; PT-V5; `DEC_U_placement.md`; W-R1; P0-8 E-U13/V1-SENSOR/V2-PROJ; P0-3 F-GRID-a–e |
| R06 | `t_600.png` 00:10 | D4 forest / dense conifer belt + glades | `[0,60,640,360)` | `0,60,640,300` | `PORT1TO1_video_targets.md` §3 D4 row (line 295); §1 D4 (lines 136–141); `PORT1TO1_acceptance_plan.md` §1.2 D4 | P-NAT right belt `[950,80,1280,500)`→`950,80,330,420`; P-COL same | PT-V1; PT-V4; PT-V5; T-SEED/T-CALLBACK; `DEC_DEEP_forest_generation.md` `[U]`; P0-3 F-GRID-a–e; P0-8 F-V1/V2 |
| R07 | `t_600.png` 00:10 | D3 land-margin grammar / dirt-grass feathering at rock | `[200,280,480,450)` | `200,280,280,170` | `PORT1TO1_video_targets.md` §1 D3 (line 118) | P-SHORE block boundary + step fringe (no numeric box) | PT-V1; PT-V3; `DEC_U_shore_alpha.md` intensity-arithmetic `[U]`; W-R1; P0-3 F-GRID-a–e |
| R08 | `t_1200.png` 00:20 | D1 ground / inter-rock grass | `[400,350,900,600)` | `400,350,500,250` | `PORT1TO1_video_targets.md` §3 D1 row (line 292); §1 D1 (line 75) | P-COL `[100,450,600,700)`→`100,450,500,250` | PT-V1; PT-V6; W-R1; T-SEED/T-CALLBACK; atlas-layout `[U]`; P0-3 F-GRID-a–e; P0-8 F-V1/V2 |
| R09 | `t_1200.png` 00:20 | D5 mine / wooden minehead + rock apron | `[900,140,1080,290)` | `900,140,180,150` | `PORT1TO1_video_targets.md` §3 D5 row (line 296); §1 D5 (line 162) | P-NAT halos (same as R05); P-COL top-right `[980,90,1090,150)`→`980,90,110,60` (§1 D5, line 171) | PT-V1; PT-V5; `DEC_U_placement.md`; W-R1; P0-8 E-U13/V1-SENSOR/V2-PROJ; P0-3 F-GRID-a–e |
| R10 | `t_1200.png` 00:20 | D7 buildings / red church facade + silhouette | `[400,230,500,330)` | `400,230,100,100` | `PORT1TO1_video_targets.md` §3 D7 row (line 298); §1 D7 (line 211) | P-COL church `[540,130,750,380)`→`540,130,210,250` (+ huts) | PT-V1; W-R1; `DEC_SMALL_light_products.md` `[U]`; `DEC_U_scenecolor_glstate.md` `[U]`; P0-8 F-V1/V2; P0-3 F-GRID-a–e |
| R11 | `t_1800.png` 00:30 | D5 mine / top-centre rock-pile + timber mine | `[620,40,730,130)` | `620,40,110,90` | `PORT1TO1_video_targets.md` §1 D5 (line 164) | P-NAT halos (same as R05) | PT-V1; PT-V5; `DEC_U_placement.md`; W-R1; P0-8 E-U13/V1-SENSOR/V2-PROJ; P0-3 F-GRID-a–e |
| R12 | `t_1800.png` 00:30 | D5 mine / right rock-pile + timber mine | `[1060,220,1170,330)` | `1060,220,110,110` | `PORT1TO1_video_targets.md` §3 D5 row (line 296); §1 D5 (line 164) | P-NAT halos (same as R05) | PT-V1; PT-V5; `DEC_U_placement.md`; W-R1; P0-8 E-U13/V1-SENSOR/V2-PROJ; P0-3 F-GRID-a–e |
| R13 | `t_1800.png` 00:30 | D6 field / wheat parcel around mill + army edge | `[380,280,910,560)` | `380,280,530,280` | `PORT1TO1_video_targets.md` §3 D6 row (line 297); §1 D6 (line 188) | P-COL checkerboard `[1080,230,1280,400)`→`1080,230,200,170`; mill clearing `[1010,180,1130,340)`→`1010,180,120,160` | PT-V1; PT-V7; P0-7 S-RNG-G1; T-SEED/T-CALLBACK; `DEC_VIS_03_fields.md` `[U]`; W-R1 |
| R14 | `t_2100.png` 00:35 | D4 forest / forested middle ground + open cavalry grass | `[0,0,1280,360)` | `0,0,1280,360` | `PORT1TO1_video_targets.md` §3 D4 row (line 295); §1 D4 (line 140); `PORT1TO1_acceptance_plan.md` §1.2 D4 | P-NAT right belt `[950,80,1280,500)`→`950,80,330,420`; P-COL same | PT-V1; PT-V4; PT-V5; T-SEED/T-CALLBACK; P0-3 F-GRID-a–e; P0-8 F-V1/V2; P0-5 E-B1/B2/C1/C2 (unit motion inside ROI) |

Mechanically valid, **not** admissible: all 14 boxes are inside both 1280×720 frames, and the donor/port file hashes would be recorded in the JSON report. Neither fact verifies that the same content is under the box on both sides. F0 is a port-internal full-port capture with the U12 water hard-fail (`cap_fullport6` class); most donor boxes (church, parcel, mine apron) will not contain corresponding content at the same coordinates. That is a reason to mark the read UNVERIFIED, **never** a reason to move, rescale or re-infer the ROI inside a run.

### 3.1 Provenance trap — do not reuse as justification

`PORT1TO1_acceptance_plan.md` §4 example command (lines 237–245) pairs `t_600.png` with `--roi 400,350,500,250` and a provenance saying "t=600, inter-rock/mill-class ground". That rectangle is the **t_1200** D1 box `[400,350,900,600)` from `PORT1TO1_video_targets.md` §3, not any numeric box cited for `t_600`. It is not used as a justification here. The cited `t_600` boxes are R06 (`[0,60,640,360)`, D4) and R07 (`[200,280,480,450)`, D3); no numeric D1/D8 box is cited for `t_600` (§4.1 below).

---

## 4. NO ROI — DO NOT RUN (no command emitted)

For these pairs a landed donor report gives **no numeric rectangle**. Inventing one would be an approximation, so no `compare_frames.py` command is supplied. An owner-supplied ROI would need new provenance text naming its source; it would still be `parity=UNVERIFIED`.

| t / donor file | Defect / scene class | Why no ROI is emitted | Blocking `[U]` |
|---|---|---|---|
| `t_0.png` 00:00 | D4 forest ("left edge" pines) | `PORT1TO1_video_targets.md` §1 D4 line 139 and §3 D4 row give no box for `t_0` | PT-V1, PT-V4, T-SEED/T-CALLBACK, P0-3, P0-8 |
| `t_60.png` 00:01:00 | D6 field, D4 forest | No numeric box for `t_60` in §1 D4/D6 or §3 | PT-V1, PT-V7, P0-7, P0-3, P0-8 |
| `t_600.png` 00:10 | D1 ground ("glades"), D8 light/shadows ("tree shadows") | §1 D1 lines 73/76 and §1 D8 lines 229–233 describe the appearance but give no numeric box; §4 example box is not justified (§3.1) | PT-V1, PT-V6, W-R1, P0-3, P0-8 |
| `t_900.png` 00:15 | D6 field, D7 buildings | §1 D6 line 188 and §1 D7 line 210 describe the scene with no box | PT-V1, W-R1, P0-7, P0-8 |
| `t_1200.png` 00:20 | D4 forest ("bottom band") | §1 D4 line 139 gives no box | PT-V1, PT-V4, P0-3 |
| `t_1500.png` 00:25 | D7 buildings (market/stable rows) | §3 D7 line 298 names `t_1500.png` rows but gives no box | PT-V1, W-R1, P0-8 |
| `t_1800.png` 00:30 | D1 ground ("army ground"), D8 light/shadows ("unit shadows") | §1 D8 line 231 names the ROI by content only, no numeric box | PT-V1, PT-V6, W-R1, P0-5, P0-8 |
| `t_2100.png` 00:35 | D7 burning building, D8 cavalry shadow | §1 D7 line 212 / §1 D8 line 233 give no numeric box | PT-V1, W-R1, P0-5, P0-8 |
| `t_2260.png` 00:37:40 | D2 water, D3 shore | **Negative** (`PORT1TO1_video_targets.md` §2 rank 5, §4 PT-V2/PT-V3); no admissible water/shore reference exists in this video | PT-V1, PT-V2, PT-V3, P0-1 (W-U12-A/B/C/T/S/P), P0-1b (W-U4*), P0-2 (W-U1/U3/U5/U6) |
| `t_2370.png` 00:39:30 | D2 water, D3 shore | **Negative**; same block | same as `t_2260` |
| any timestamp | D9 camera | §3 D9 row names "all 12 donor frames (oblique grammar)" and P-WIDE `capture.json` pose — no pixel ROI and no donor camera constant | PT-V1, PT-V4, P0-8 F-V1/V2 (`FOV 17.27°` stays PORT APPROXIMATION) |
| any timestamp | port 4K overview / headless frame | 4096×4096 or CPU map image; not donor-legal and refused on resolution | PT-V1, capture admissibility failure (`PORT1TO1_acceptance_plan.md` §5 item 6) |

Port-only support ROIs from `PORT1TO1_acceptance_plan.md` §1.2 (wide clean grass `[500,500,900,700)`→`500,500,400,200`; close interior `x[330,950] y[40,330)`→`330,40,620,290`; close edge `x[100,1180] y[380,540)`→`100,380,1080,160`; close grass `x[100,1180] y[580,710)`→`100,580,1080,130`) are **not** donor-pair ROIs and are not used as `--roi` in this register.

---

## 5. Copy-paste commands (14, one per row in §3)

Each command is mechanically runnable from the repo root against files verified in §1. Every one still prints `parity=UNVERIFIED`; treat the output as a support cue, never as a verdict. Do not run them in parallel with a Godot capture (`PORT1TO1_acceptance_plan.md` §2.0 concerns Godot launches; these commands launch none).

```powershell
# R01 - t_0 D1 meadow, ROI 400,350,500,300
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_0.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 400,350,500,300 --roi-source "PORT1TO1_video_targets.md section 3 D1, donor cZW0AEupCaI t_0 meadow [400,350,900,650) => 400,350,500,300; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R01_t0_d1.png --report inbox/qa/captures/diff_roi_R01_t0_d1.json

# R02 - t_120 D6 wheat parcel, ROI 920,140,360,250
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_120.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 920,140,360,250 --roi-source "PORT1TO1_video_targets.md section 3 D6, donor cZW0AEupCaI t_120 mature wheat parcel [920,140,1280,390) => 920,140,360,250; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R02_t120_d6.png --report inbox/qa/captures/diff_roi_R02_t120_d6.json

# R03 - t_300 D1 ridge-apron grass, ROI 640,360,640,360
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_300.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 640,360,640,360 --roi-source "PORT1TO1_video_targets.md section 1 D1, donor cZW0AEupCaI t_300 right-half ridge apron [640,360,1280,720) => 640,360,640,360; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R03_t300_d1.png --report inbox/qa/captures/diff_roi_R03_t300_d1.json

# R04 - t_300 D3 ridge-foot feathering, ROI 640,500,460,200
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_300.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 640,500,460,200 --roi-source "PORT1TO1_video_targets.md section 3 D3 land-margin grammar, donor cZW0AEupCaI t_300 ridge-foot feathering [640,500,1100,700) => 640,500,460,200; land-margin only, not a shore target; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R04_t300_d3.png --report inbox/qa/captures/diff_roi_R04_t300_d3.json

# R05 - t_300 D5 rock scatter/pit, ROI 180,300,240,170
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_300.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 180,300,240,170 --roi-source "PORT1TO1_video_targets.md section 1 D5, donor cZW0AEupCaI t_300 rock scatter/pit [180,300,420,470) => 180,300,240,170; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R05_t300_d5.png --report inbox/qa/captures/diff_roi_R05_t300_d5.json

# R06 - t_600 D4 conifer belt + glades, ROI 0,60,640,300
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 0,60,640,300 --roi-source "PORT1TO1_video_targets.md section 3 D4, donor cZW0AEupCaI t_600 conifer belt and glades [0,60,640,360) => 0,60,640,300; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R06_t600_d4.png --report inbox/qa/captures/diff_roi_R06_t600_d4.json

# R07 - t_600 D3 dirt/grass feathering at rock, ROI 200,280,280,170
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 200,280,280,170 --roi-source "PORT1TO1_video_targets.md section 1 D3, donor cZW0AEupCaI t_600 dirt/grass feathering at rock [200,280,480,450) => 200,280,280,170; land-margin only, not a shore target; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R07_t600_d3.png --report inbox/qa/captures/diff_roi_R07_t600_d3.json

# R08 - t_1200 D1 inter-rock grass, ROI 400,350,500,250
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1200.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 400,350,500,250 --roi-source "PORT1TO1_video_targets.md section 3 D1, donor cZW0AEupCaI t_1200 inter-rock grass [400,350,900,600) => 400,350,500,250; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R08_t1200_d1.png --report inbox/qa/captures/diff_roi_R08_t1200_d1.json

# R09 - t_1200 D5 minehead hut + apron, ROI 900,140,180,150
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1200.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 900,140,180,150 --roi-source "PORT1TO1_video_targets.md section 3 D5, donor cZW0AEupCaI t_1200 wooden minehead and rock apron [900,140,1080,290) => 900,140,180,150; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R09_t1200_d5.png --report inbox/qa/captures/diff_roi_R09_t1200_d5.json

# R10 - t_1200 D7 red church, ROI 400,230,100,100
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1200.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 400,230,100,100 --roi-source "PORT1TO1_video_targets.md section 3 D7, donor cZW0AEupCaI t_1200 red church [400,230,500,330) => 400,230,100,100; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R10_t1200_d7.png --report inbox/qa/captures/diff_roi_R10_t1200_d7.json

# R11 - t_1800 D5 top-centre mine, ROI 620,40,110,90
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1800.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 620,40,110,90 --roi-source "PORT1TO1_video_targets.md section 1 D5, donor cZW0AEupCaI t_1800 top-centre rock-pile/timber mine [620,40,730,130) => 620,40,110,90; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R11_t1800_d5a.png --report inbox/qa/captures/diff_roi_R11_t1800_d5a.json

# R12 - t_1800 D5 right mine, ROI 1060,220,110,110
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1800.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 1060,220,110,110 --roi-source "PORT1TO1_video_targets.md section 3 D5, donor cZW0AEupCaI t_1800 right rock-pile/timber mine [1060,220,1170,330) => 1060,220,110,110; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R12_t1800_d5b.png --report inbox/qa/captures/diff_roi_R12_t1800_d5b.json

# R13 - t_1800 D6 wheat parcel, ROI 380,280,530,280
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_1800.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 380,280,530,280 --roi-source "PORT1TO1_video_targets.md section 3 D6, donor cZW0AEupCaI t_1800 wheat parcel around mill [380,280,910,560) => 380,280,530,280; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R13_t1800_d6.png --report inbox/qa/captures/diff_roi_R13_t1800_d6.json

# R14 - t_2100 D4 forested middle ground, ROI 0,0,1280,360
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_2100.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 0,0,1280,360 --roi-source "PORT1TO1_video_targets.md section 3 D4, donor cZW0AEupCaI t_2100 forested middle ground + cavalry grass [0,0,1280,360) => 0,0,1280,360; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/diff_roi_R14_t2100_d4.png --report inbox/qa/captures/diff_roi_R14_t2100_d4.json
```

---

## 6. Refusal conditions (exact, from `compare_frames.py` source)

**argparse errors / exit 2 (no image read, no diff):**
1. Missing any mandatory argument: `--donor`, `--port`, `--roi`, `--roi-source`, `--camera`, `--out-diff` (lines 121–132, 141).
2. `--roi` not exactly four comma-separated integers, or `x<0`, `y<0`, `w<1`, `h<1` (lines 43–53).
3. `--roi-source` blank/whitespace or shorter than 10 characters after strip (lines 143–144).
4. `--assert-ab-verified` present with a reason shorter than 10 characters (lines 148–150).
5. `--amplify` non-finite or outside `[1,64]` (lines 145–146).

**Runtime `REFUSED:` to stderr + `parity=UNVERIFIED` to stdout, exit 2 (lines 158–174, 234–237):**
6. Donor or port file cannot be loaded (missing, unreadable, unsupported/truncated PNG) — `OSError`/`ValueError`/`RuntimeError`.
7. **Different frame resolutions**: `"donor WxH vs port WxH differ; identical ROI/camera requires identical resolution, no rescaling is performed"` (lines 161–165). This is why `map_overview_4k.png` (4096×4096) and any 800×600/headless fallback are inadmissible.
8. **ROI outside frame**: `"refusing: ROI ... outside WxH; no clamping"` (lines 166–169). The check is against donor dimensions; because resolutions are forced equal, the port frame is covered too.
9. **Config SHA-256 mismatch**: if both `--config-donor` and `--config-port` are supplied and their hashes differ, `"cameras are not identical"` (lines 170–174).

**Always printed, never promoted (lines 224–256):**
10. Successful runs print `[compare] ...` metrics and then `parity=UNVERIFIED (metrics never constitute donor parity)`.
11. `--assert-ab-verified REASON` only adds `claim=owner-supplied` to the JSON and prints `claim=owner-supplied (human A/B assertion recorded, not verified)`; `parity` stays `UNVERIFIED`.
12. The JSON report records both file SHA-256 values, ROI, `--roi-source`, `--camera`, configs, `hist_bins`, per-channel/overall metrics, difference-image SHA-256, `parity: "UNVERIFIED"`, `claim: null`, and an explicit note that metrics cannot prove donor identity, camera equality or visual parity (lines 199–229).

---

## 7. Honest verdict condition

A result stays UNVERIFIED — and **no parity claim is admissible** — whenever any item of `PORT1TO1_acceptance_plan.md` §5 holds; controlling here: no donor GPU A/B frame (PT-V1), metrics/contact sheets/MP4 only, water/shore scored from this video (`t_2260`/`t_2370` negatives), ROI on wrong content or non-1280×720 non-blank frame, capture admissibility failure, or a non-empty blocking `[U]` set (§6 P0-1…P0-8). Since §6 is non-empty, the overall verdict is `RESULT IS NOT GOOD`, `parity.claim = NONE`, `parity.status = UNVERIFIED`, `blocking_unverified` non-empty.

**Never written about a run produced by §5:** "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", or "gate PASS" derived from a capture. `--assert-ab-verified` is not verification.

---

## 8. `[U]` legend used in §3/§4

All IDs are currently open in `DEC_U_final_register.md` (§0 P0-1…P0-8; §§1–5) or `PORT1TO1_video_targets.md` §4 (PT-V IDs). "RUNTIME" items require an owner-authorised donor GPU/runtime session and are forbidden to workers; none is closed by a `compare_frames.py` metric.

| ID | Open item (short) | Source |
|---|---|---|
| PT-V1 | Donor parity of any pixel; third-party H.264, unknown build/map/camera/zoom/compression, no same-camera A/B | `PORT1TO1_video_targets.md` §4 |
| PT-V2 | Water colour / level / foam width; no certifiable water in `t_0…t_2370` | same |
| PT-V3 | Shore sand/foam band geometry; same gap | same |
| PT-V4 | Exact world-scale tree spacing / stems-per-hectare; image-plane spacing only | same |
| PT-V5 | Exact mine/rock placement-transform semantics; runtime decode unproven | same |
| PT-V6 | Native sceneColor / exposure runtime values | same |
| PT-V7 | Field decal final under donor blend + mips (`GL_DST_ALPHA`, missing mip chains) | same |
| P0-1 / W-U12-A/B/C/T/S/P | Water reflection provenance/size/mips/sampler/unit/projective matrix/viewport, `DiffuseWaves2` alias; port hard-fails water draw (`water3d.gd:520-527`) | `DEC_U_final_register.md` §0, §1 |
| P0-1b / W-U4* | ctor defaults vs `water.lib` layer scalars; live tuple `[U]`; explicit gate, no water | same |
| P0-2 / W-U1/U3/U5/U6 | shader path, hmap numerics/identity, `time` writer, UV/winding | same |
| P0-3 / F-GRID-a–e + persistence | FOW cell size, combine, LOS occlusion, explored-vs-visible persistence, sampling; visibility/tint vetoes | `DEC_U_final_register.md` §0, §5 |
| P0-4 / S-TICK-O1 | Tick interleave `TICK_ORDER v1` = PORT APPROXIMATION | same, §4 |
| P0-5 / E-B1/B2/C1/C2 | Animation blend weight, frame fetch, `acmPlayOnce` hold-vs-return, handler timing | same, §3 |
| P0-7 / S-RNG-G1 | RNG stream split/draw counts/order; wrong stream = desync | same, §4 |
| P0-8 / F-V1/V2, E-U13 | Sensor width→FOV, near/far/aspect, drag anchor, marquee inside-test, pick order/AABB; port `FOV 17.27°` stays APPROX | same, §0, §5 |
| W-R1 | Terrain material floats, light pos+modelview, alpha arithmetic, fog, `glCallList`; `tiaAlphaFromIntensity` converter `[U]` | same, §1 |
| T-SEED / T-CALLBACK | `GenerateMapRandKey` derivation and `randkey0/1` consumers | same, §2 |
| atlas-layout `[U]` | Port 16×8 atlas is a PORT APPROX fallback; donor per-block 1024² DXT1 | `DEC_U_atlas_layout.md`, `DEC_U_final_register.md` §2 |
| `DEC_VIS_01_uv_mapping.md` | Donor tile-id → alpha-patch decomposition not yet ported; UV/sampling residual | evidence index domain A |
| `DEC_VIS_03_fields.md` | Donor field/crop pipeline stages still `[U]` | evidence index domain A |
| `DEC_U_placement.md` | Mine/forest/field placement residuals (U-SEED, etc.) | `DEC_U_final_register.md` §2 |
| `DEC_DEEP_forest_generation.md` | Donor forest generation residual | evidence index domain A |
| `DEC_SMALL_light_products.md`, `DEC_U_scenecolor_glstate.md` | Light products / light-model state residual | evidence index domain A |
| `DEC_U_shore_alpha.md` | Shore alpha confinement; intensity→alpha arithmetic `[U]` | evidence index domain A |
| X17 | `bmTransparency = glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)`; port `rgb*=mask` is approximation, pass count `[U]` | `PORT1TO1_evidence_index.md` domain A |

---

## 9. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | 12 donor PNG files exist at the stated `%TEMP%` path and are all 1280×720; exact filenames and byte sizes listed in §1.1 | [O] read-only listing + IHDR header read |
| 2 | F0 is present and its manifest records 1280×720, `resolution_matches_request=true`, status `ok`, config SHA `aa857480…202da`; `cap_fullport6/7.png` are absent at this read | [O] read-only listing + manifest read |
| 3 | All 14 `--roi` rectangles in §3 are exact `w=x1−x0, h=y1−y0` conversions of boxes cited in `PORT1TO1_video_targets.md` §1/§3; no value is estimated | [D] arithmetic over cited text |
| 4 | The timestamp/defect pairs listed in §4 have no numeric ROI in the landed reports; no command is emitted for them | [O]/[D] report read |
| 5 | Commands in §5 satisfy the harness's mandatory-argument and resolution checks against files actually on disk, and would produce diff/report artifacts with `parity=UNVERIFIED` | [D] source read (lines 118–257) |
| 6 | No command establishes donor identity, camera equality or same-scene pairing; every row is blocked by an open `[U]` set and PT-V1 | [U] guard; `PORT1TO1_acceptance_plan.md` §5/§6 |
| 7 | No metric, contact sheet, MP4 or human assertion constitutes donor parity; `parity=UNVERIFIED` is unconditional | [O] source lines 14–17, 224–256 |
| 8 | This worker wrote exactly one repository file (this report); no code, Godot, git, donor execution, capture or ROI metric was produced | [O] scope |

*End of PORT1TO1_roi_register. Exactly one repository file written. Read-only planning; no donor GPU A/B frame produced; parity UNVERIFIED; no approximation and no parity claim.*
