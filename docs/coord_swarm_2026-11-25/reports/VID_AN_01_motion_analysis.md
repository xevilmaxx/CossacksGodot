---
id: VID-AN-01
title: "Motion analysis of the VID-CAP-01 16-frame unit-movement sequence"
date: 2026-11-25
owner: VID-AN-01 (video-analysis micro-worker)
model: opencode-go/muse-spark-1.3-contributor
status: DELIVERED__MOTION_VERDICTS_RECORDED__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Exactly one report written. No repo code/config/asset/test/scene/git edit; no Godot/Blender run; no donor binary executed, unpacked or copied."
labels: [FRAME_SEQUENCE_ANALYSIS, observed, derived, inferred, visual-UNVERIFIED]
governing_rule: "VIDEO_QA_PROTOCOL.md:40-46 — per-frame observations, observed/derived/inferred separated; never infer donor parity from motion smoothness (DANIM-01, DEC-04)."
---

# VID-AN-01 — unit-motion sequence analysis (frames 000–015)

## 0. Goal

Analyse the VID-CAP-01 capture (16 GPU frames, fixed camera, one squad move order)
for **motion**, not stills: squad translation coherence, pose continuity, direction
changes, terrain contact, frame uniqueness. Cross-check pixels against `frames.json`
numbers. No donor-parity claim is made or possible here.

Read first (all read-only): `VIDEO_QA_PROTOCOL.md`,
`reports/VID_CAP_01_capture.md`, `reports/DANIM_01_action_ranges.md` (full read),
`decomp/DEC_04_anim_formats.md` (§1–§2), `V774_consume_poses.md` (§0–§2),
`V779_pose_memo.md` (§0–§2), `docs/audit/ANIM_ADJUDICATION.md` (§E1–E2 table).

## 1. Artifact paths (all outside the repo)

| Artifact | Path |
|---|---|
| Raw frames | `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa/frame_000.png` … `frame_015.png` (1280×720, ~1.51 MB each) |
| Sidecar | `.../vidqa/frames.json` (per-frame SIM time, unit SIM pos, azimuth, pose, camera, signature) |
| Contact sheet | `.../vidqa/contact_sheet.png` (4×4) |
| Video | `.../vidqa/motion.mp4` (ffmpeg 9.0.1, `-framerate 4`, libx264, 16 frames / 4 s) |

Capture facts reused from VID-CAP-01 (not re-verified): real 64² `main.tscn`,
fixed camera at SIM (64,64) height 20 m, sim frozen at speed 0 and driven 12 fixed
1/32 s ticks per capture, 4 player-0 `officer` units, one `cmd_move` to SIM
(78,69), SIM time 0.500→6.125 s in exact 0.375 s steps, rendered frames 3…48.

## 2. Method

Analysis was performed on the **raw PNGs** (lossless), not on the lossy MP4
encode — strictly stronger than watching the video. Tools: Pillow 12.1.1
(mean-abs frame diffs, changed-pixel bboxes at thresholds >12 and >40, tight
unit-window crops upscaled nearest-neighbour) plus exact arithmetic over
`frames.json` (displacement, speed, yaw deltas). Helper scripts
(`an01_calc.py`, `an01_img*.py`) live in the approved temp folder, never the repo.
No frame, crop, or slow-down clip was written into the repo.

## 3. Frame-numbered observation table

`observed` = pixels I inspected. `derived` = computed from `frames.json`.
`inferred` = best explanation, labelled as such.

| Frames | Observed (pixels) | Derived (frames.json) |
|---|---|---|
| f00 | Contact sheet + full frame: 4 officer figures visible (2 large foreground, 2 small near terrain ridge). Terrain shows white linear striping (wireframe/debug-like fill) with dark textured discs; ground plane otherwise near-black. | Unit 10 walk:15 at (61.176, 61.587), az −74.9°. Units 11–13 at spawn corners, `order:none`, `moving:false`, az 0.0°. Camera block identical to all later frames. |
| f00→f01 | Whole-frame mean-abs diff 1.49. Changed-pixel bbox left edge x=327. | Unit 10 Δ (+0.403, −0.156) = 0.433 m → 1.15 m/s. Az −74.9°→−16.9° (58° step). Pose 15→1. |
| f01→f02 | Diff 1.70 (largest of sequence). Bbox left edge advances to x=353. | Δ 0.450 m → 1.20 m/s. Az unchanged (−16.9°). Pose 1→15. |
| f02→f03 | Diff 1.22. Bbox left edge x=381. | Δ 0.444 m → 1.18 m/s. Az −16.9°→−34.6°. Pose 15→1. |
| f03→f04 | Diff 2.10. Bbox left edge x=404. | Δ 0.357 m → 0.95 m/s. **Az −34.6°→+56.5° = 91° yaw step in one 0.375 s capture.** Pose 1→15. |
| f04→f05 | Diff 1.76. Bbox left edge x=410. | Δ 0.401 m → 1.07 m/s. Az +56.5°→+56.0° (steady). Pose 15→24. |
| f05→f06 | Diff 1.09. Bbox left edge x=414. | Δ 0.424 m → 1.13 m/s. Az +56.0°→+26.2°. Pose 24→10. |
| f06→f07 | Diff 1.16. | Δ 0.402 m → 1.07 m/s. Az +26.2°→−48.2° (74° step). Pose 10→24. |
| f07→f08 | Diff 0.70 (drops sharply). Bbox left edge stalls ~x=410. | Δ 0.174 m → 0.46 m/s (deceleration). **Az −48.2°→+117.7° = 166° yaw snap.** Pose 24→10. |
| f08→f09…f14→f15 | Diffs collapse: 0.090, 0.031, 0.061, 0.072, 0.066, 0.061, 0.031 — shimmer-level. Changed-pixel bbox stays ~(410,205,874,470), i.e. the textured-disc/ridge region only. No figure translates anywhere. | Unit 10 Δ ≈ 0.0005 m/frame → ~0.001 m/s, total f08→f15 drift 0.003 m — **SIM-static** while `order` is still `move`, `moving` still `true`, destination (78,69) ~14 m away, az locked at 117.7°. **Walk pose frames keep cycling: 10→19→10→19→6→19→6→15.** Idle pose frames of units 11–13 also keep cycling (e.g. 115→135→144→154→115→125→135→144). |
| all 16 | Right-foreground unit window (880,380,1010,660): **mean-abs diff exactly 0.000 on all 15 consecutive pairs** — bit-identical pixels. Left-foreground unit strip (f00/f04/f08/f15): identical stance, pike vertical, same screen position; only background stripe shimmer differs. **No limb-level pose change is discernible on any unit in any frame pair at this resolution/darkness.** | Units 11–13 SIM positions bit-constant (67,62 / 61,66 / 67,66), az 0.0° all frames. Camera block byte-identical all 16 frames. All 16 PNG byte sizes distinct; all 16 frames non-blank. |
| f00 vs f04 / f00 vs f08 | High-threshold (Δ>40) changed bbox (327,147,691,325) / (327,147,873,442): one coherent region expanding-then-stopping eastward, consistent with a single small figure walking east and halting (see §4). | Unit 10 net f00→f08: +2.59 m X, −0.01 m Y. |

Additional observed facts: no teleport/pop of any figure between consecutive
frames (change bboxes evolve monotonically, no disjoint jumps); no duplicated
adjacent frames at byte level (all PNG sizes distinct, all diffs > 0); no
unit-unit overlap ever (positions distinct); no ground penetration or floating
visible — figures stand on the dark ground plane (coarse judgment: the terrain
fill looks like a debug/wireframe state, so fine contact detail is not assessable).

## 4. Numeric cross-check: where visual motion and SIM agree / disagree

1. **Agree — translation f00→f08.** SIM shows unit 10 advancing ~0.36–0.45 m per
   capture (≈1.0–1.2 m/s); pixels show a single coherent changed region marching
   east (bbox left edge 327→414) then stopping. Attribution of that region to
   unit 10 is `derived` (only unit 10 changes SIM position), and it fits.
2. **Agree — stall f08→f15.** SIM Δ≈0.0005 m/frame; pixels drop to shimmer-level
   diffs. Both say: nothing translates after f08.
3. **DISAGREE — pose vs velocity f08→f15.** Sidecar keeps `action:walk` with
   cycling donor frames (10/19/6/15) while SIM speed is ~0.001 m/s. A walk cycle
   playing at zero velocity is in-place marching (foot-skate by definition at data
   level). Visually the figures are too small/dark to confirm skate at limb
   level — the skate itself is `derived`, its visual confirmation is missing.
4. **DISAGREE — idle rendering.** Units 11–13 idle donor frames advance every
   capture (125→144→154→164→…), yet the right-foreground unit is bit-identical
   across all 16 frames (0.000). Either the mesh rebuild is skipped for
   stationary units or idle-frame deltas are sub-pixel at this zoom — either way
   the cycling sidecar pose does not reach the screen. (`inferred` candidates in §7.)
5. **DISAGREE — squad order.** Only unit 10 reports `moving:true` and
   `order:move`; units 11–13 report `order:none`, `moving:false`, az 0.0° for the
   whole sequence despite the single squad `cmd_move` (VID-CAP-01 §2: squad 1,
   `move_calls=1`). The order visibly affected one unit, not the squad.

## 5. Verdict table

| Criterion | Verdict | Frame evidence |
|---|---|---|
| Translation coherence (smooth, order-following) | **FAIL** | f00→f07 smooth ~0.4 m steps, then stall: f08→f15 total 0.003 m with `order:move` unfulfilled ~14 m short; `moving` stays `true` at ~0.001 m/s |
| Squad moves together | **FAIL** | 1 of 4 units ever `moving:true`; units 11–13 `order:none`, static, az 0.0° all 16 frames |
| Pose continuity (no pop / walk matches velocity) | **FAIL** (data level) / **UNDETERMINED** (visual pop) | walk frames cycle while SIM-static f08→f15 (10→19→6→15); idle frames cycle while render bit-frozen (right-unit window 0.000 ×15); no limb-level pop discernible at this resolution — pop itself neither confirmed nor refuted |
| Direction (no flips) | **FAIL** | 91° yaw step f03→f04 (−34.6°→+56.5°); 166° snap f07→f08 (−48.2°→+117.7°); 74° step f06→f07 — all within single 0.375 s captures while translating |
| Terrain contact | **PASS** (coarse) | No sinking, floating, or clipping observed on any frame; caveat: terrain fill looks wireframe/debug-like, so only gross penetration could be judged |
| Frame uniqueness (no duplicates/teleports) | **PASS** (with caveat) | All 16 PNG byte sizes distinct, all consecutive diffs > 0, change bboxes evolve monotonically; caveat: f08–f15 are near-identical visually (diffs 0.03–0.09, shimmer-level) |

No PASS is claimed beyond the frames: each verdict is bounded by this 16-frame,
single-order, single-camera capture.

## 6. Donor-parity caveat

Parity with the donor remains **UNVERIFIED**. No donor GPU footage exists
(`VIDEO_QA_PROTOCOL.md:48-52`: donor footage is external-YouTube-only and was
not used). The only local donor references are `DANIM_01` AAF ranges (e.g.
officer walk/idle spans, loop/one-shot policy in `DANIM_01 §4.3/§8`) and the
flat-root sampled poses consumed per `V774/V779` — all carrying
`pose_source:donor_flat_root_morph`, `visual:UNVERIFIED` in every sidecar entry.
Motion smoothness observed here says nothing about donor faithfulness, and the
walk-while-static + yaw-snap findings above are port-behaviour findings, not
donor comparisons.

## 7. Fix recommendations (read-only; smallest owner file each, no edits made)

1. **Stall 14 m short with `moving:true` + squad non-propagation** → owner
   `variant3d/scripts/game.gd` (`_tick_unit` / nav-grid / formation arrival and
   `cmd_move` squad propagation at `:3283-3310`): only unit 10 exhibits order
   effects; units 11–13 sit at `order:none`. Arrive/stall leaves `moving:true`
   at ~0 velocity.
2. **Walk action at ~0 velocity f08→f15** → owner
   `variant3d/scripts/world3d_entities.gd` (per-`sync` action selection,
   `dead→death / moving→walk / else idle` per `V774:506-517`): gate `walk` on
   measured speed with an arrival threshold and swap to `idle` below it, mirroring
   the donor's state map (`DANIM_01 §4.2`) instead of the 3-state coarse map.
3. **166°/91° yaw snaps** → owner `variant3d/scripts/world3d_entities.gd` (yaw
   from `face`) and/or `variant3d/scripts/anim3d.gd`: clamp per-capture yaw rate
   or blend heading (donor authors `minFrameBlend=6 / maxFrameBlend=8`,
   `DANIM_01 §4.3`); port's nearest-exported snap (`anim3d.gd:893-912`) has no
   interpolation by design.
4. **Cycling sidecar poses with frozen render** (right unit bit-identical ×16,
   walk-cycle invisible f08→f15) → owner
   `variant3d/scripts/world3d_entities.gd` `sync()` mesh-update path (with
   `V779` memo in mind: memo is per-`sync()` so it cannot serve stale frames —
   look at whether rebuilds are skipped for stationary units, or whether pose
   deltas are simply sub-pixel at zoom 2.9 / height 20 m).
5. **Capture hygiene for the next sequence (no code change asked):** figures are
   a few dozen dark pixels at this zoom — limb-level skate/pop verdicts need a
   closer camera (lower height / higher zoom) and/or a lit ground plane; the
   wireframe-looking terrain fill also limits contact judgments.

## 8. Open questions

1. Why does unit 10 decelerate to a stall at (63.76, 61.58) with `moving:true`
   — pathing blocker, formation anchor, or arrival radius larger than the
   remaining distance? (VID-CAP-01 Q1–Q2, still open.)
2. Why do squad members 11–13 carry `order:none` after a squad `cmd_move`?
3. Is the frozen render of cycling idle/walk poses a skipped mesh rebuild or
   sub-pixel deltas at this zoom? A close-up capture (§7.5) decides it.
4. What are the dark textured discs / white striping in the terrain fill —
   expected debug visualisation or a material regression? (Affects contact-call
   confidence; not a motion verdict.)
5. The MP4 plays 0.375 s-interval captures at 4 fps (mild time-lapse vs the
   2.67 fps native rate) — presentation only, no timing-parity meaning.

## 9. Summary

- f00→f07: one unit translates smoothly (~1.0–1.2 m/s) with large yaw steps
  (up to 166°); the other three never move and never receive the order.
- f08→f15: SIM-static stall 14 m short of the destination while `moving:true`,
  `action:walk` cycling, azimuth locked — walk-in-place at data level.
- Render: camera byte-stable; no duplicates/teleports/clipping/penetration; but
  cycling poses produce no discernible pixel change on any unit (one unit
  bit-identical all 16 frames), so visual pose continuity is UNDETERMINED at
  this zoom while data-level pose/velocity coherence FAILS.
- Verdicts: translation FAIL, squad FAIL, pose FAIL(data)/UNDETERMINED(visual),
  direction FAIL, terrain contact PASS(coarse), uniqueness PASS.
- Donor parity: UNVERIFIED (no donor footage; AAF ranges + flat-root poses are
  the only local reference). No code was edited, no job was run, nothing donor
  was copied.
