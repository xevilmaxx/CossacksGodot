---
title: VIDEO / FRAME-SEQUENCE QA protocol (2026-11-25)
area: coordination / visual verification
owner: COORD
updated: 2026-11-25
status: living
---

# 🎞️ Frame-sequence / video QA protocol

**Owner directive (2026-11-25):** for difficult dynamic cases — unit movement, animation,
FX, camera transitions — a single PNG is not enough. Capture a **sequence** of frames (or a
video) and analyse motion, not just stills. For hard cases use
`opencode-go/muse-spark-1.3-contributor` at its **default variant** (owner directive 2026-11-25:
"#default will do fine"; exact id verified via `tools.opencode.models`).

## When this applies
- Unit walk/idle/attack/death, 8-azimuth direction changes, foot sliding / pose popping.
- Drag marquee during motion, rally flags, build ghosts, selection aura pulses.
- Water animation, smoke/volley FX, weather, camera pan/zoom seams.
- Any claim whose evidence would otherwise be "I looked at one screenshot".

## Tooling confirmed on this host
- `ffmpeg` at `C:\Users\Maxym.Oboyshev\AppData\Local\Microsoft\WinGet\Links\ffmpeg.exe`.
- Pillow 12.1.1 via `python -c "import PIL"`.
- 3D PNGs require a **windowed** runner job + dedicated `SubViewport` readback;
  headless yields only an 800×600 CPU map (`main.gd:1157-1158,1790-1800`).
- Frames/videos go to `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\...` — never into the repo.

## Capture rules
1. One atom per motion case, new file only, no game-code edits, no runner concurrency bypass.
2. Fixed camera, fixed seed, fixed 64² fixture, fixed frame interval (e.g. every 3 frames for
   ~30 frames) so frame-to-frame differences are attributable to motion, not camera drift.
3. Record per-frame metadata (sim time, unit position/pose id, azimuth) in a sidecar JSON.
4. Assemble: contact sheet with Pillow (for static side-by-side review) **and** MP4 with
   `ffmpeg -framerate N -i frame_%03d.png -c:v libx264 -pix_fmt yuv420p out.mp4`.
5. Keep raw frames until the analysis verdict is recorded.

## Analysis rules
- Static reviewer: check contact sheet for pose pops, direction flips, ground penetration,
  duplicated frames, counter/marker drift.
- Video reviewer (muse-spark #high): watch the MP4 and report **per-frame observations** with
  timestamps/frame numbers, separating `observed` / `derived` / `inferred`. Never infer donor
  parity from motion smoothness alone — donor AABBs/ACL semantics remain UNVERIFIED
  (`DANIM-01`, `DEC_04`, `DEEPDEC_06`).
- A motion verdict is CONFIRMED only if it cites frame numbers and a reproducible capture path.

## Donor reference limitation
Donor footage is external YouTube links (`reference/videos.md`); no donor video may be
downloaded into the repo. Donor-derived truth available locally: AAF action ranges, `.oss`
pose payloads, OBJ meshes, DDS art and script constants. Compare motion **behaviour** against
those, and label visual parity UNVERIFIED unless an approved donor frame/video is supplied.

## Current queue
- `VID-CAP-01` — capture a moving-unit frame sequence on the 64² fixture (reserved).
- `VID-AN-01` — analyse the sequence with muse-spark 1.3 contributor (after capture lands).
