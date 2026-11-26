---
id: TERRAIN-VISUAL-WAVE-2026-11-26
title: "Visual correction wave — donor-shaped relief, natural terrain, usability and speed"
owner: COORD
created: 2026-11-26
status: ACTIVE
---

# Visual correction wave

## Observed evidence

- `cap_donor_240b.png`: donor backend runtime types fixed, but flat olive field +
  black unit/building/tree silhouettes; no readable relief.
- `cap_donor_240c.png`: I17 donor inputs wired; now shows a **large blocky,
  terraced/stepped surface with diagonal bands** — better than flat, but far
  from donor reference (soft organic hills, ravines, cliffs, natural shore).
- Donor reference images: `C:\Users\Maxym.Oboyshev\Downloads\c3\` (12 stills;
  third-party, unknown build/camera/compression — direction of movement only).
- Capture command and config live under `%TEMP%\opencode\v42\` (outside repo).

## Wave goals

1. Determine whether the stepped surface comes from **height data**, **tile art**,
   **normals/shading**, or **atlas/alpha/eye-plane** — separate the layers.
2. Produce quantitative heightmap + tile-id + normal diagnostics from the live
   donor backend, not just screenshots.
3. Fix the pipeline/shaders/props at their donor-grounded source; never hide the
   problem with noise/dither, face promotion, HEIGHT_SCALE fudge or lowered gates.
4. Re-capture still + short motion sequence; compare against donor stills/video
   references using only legitimate direction-of-movement metrics.
5. Improve usability/speed where measured (no concurrent Godot, one runner id per
   job, `app/**` byte-untouched, legacy backend default until new captures pass).

## Hard rules

- Donor read-only, never executed by workers; owner-only same-camera A/B per X39.
- Multiple passes on every strange decompile/image/metric before skipping.
- Labels `[O]/[D]/[I]/[U]/PORT APPROXIMATION`; parity stays UNVERIFIED.
- No synthetic noise/dither, no invented donor constants, no test weakening.
- COORD owns `main.gd`, `world3d.gd`, composer and final integration; workers own
  one disjoint file or one read-only report.
