---
title: "G3-3 — Heightmap 3D capture / donor A-B harness"
agent: G3-3
date: 2026-11-24
status: PENDING_G32_SANDBOX_INCOMPLETE
verdict: UNVERIFIED
claim_under_test: "heightmap mesh closer to donor than M0.6 block heightfield"
owner_files:
  - app/tools/heightmap3d_shot.py
  - app/shots/hm3d_probe.json
  - docs/coord_swarm_2026-11-24/reports/G33_heightmap_capture.md
---

# G3-3 — Heightmap 3D capture / donor A-B harness

## 1. What was done (and what was not)

Built the capture/verify harness `app/tools/heightmap3d_shot.py` and exercised it.
It is **pure Python + the shared runner**: it never starts Godot directly.

Two modes:

- **verify-only (default)** — measures an existing `app/shots/hm3d_*.png` with
  Pillow: size, mean/stddev luminance, modal luminance, a **non-blank fraction**
  (share of pixels whose luminance differs from the modal/background tone by
  `> 8`), occupied quantised-colour buckets, a crude greenish-pixel share, and a
  top-6 colour distribution. Prints a concise `VERDICT` and writes MEASURED
  stats to an `hm3d_*.json`.
- **`--submit`** — checks that G3-2's sandbox has landed, submits **one** capture
  job through `godot_runner.py run` with a unique `g33-*` id (id is guarded to
  start with `g33-`), waits for it, then runs the same verification. Falls back
  from `res://scenes/heightmap3d_sandbox.tscn` to
  `--script res://scripts/heightmap3d_sandbox.gd` if no `.tscn` exists.

The sandbox itself captures after ~30 rendered frames; this tool only
validates the command and the resulting image. **No code in the 3D world was
edited.**

## 2. Runner command + job ids

Command the tool submits once the real sandbox lands (documented, **not yet
run**):

```powershell
python app\tools\godot_runner.py run --id g33-hm3d-shot --timeout 120 -- ^
  --headless --path app res://scripts/heightmap3d_sandbox.gd
```

- **My `g33-*` jobs submitted: none.** The capture was deliberately NOT
  submitted because G3-2's sandbox is still a temporary probe (see §3); running
  it would consume a runner slot and produce no PNG.
- Runner state observed at time of writing: `now_serving=1306`,
  `next_ticket=1313`, **7 pending**, `godot.lock` held (~160 s), so the shared
  queue is contended (wave 5 + G3-2). No re-submission while jobs are pending.
- G3-2 jobs observed pending: `g32-dump`
  (`--dump-map app/shots/g32_dump.json --seed 20261113`) and `g32-cli-probe`
  (`--script res://scripts/heightmap3d_sandbox.gd`).

To finish this task once G3-2 lands:

```powershell
python app\tools\heightmap3d_shot.py --submit --id g33-hm3d-shot --timeout 180
```

## 3. Why the verdict is PENDING

At inspection time:

| G3-2 artefact | State |
|---|---|
| `app/scripts/heightmap3d_sandbox.gd` | **present, but a 169-byte CLI probe stub** (`G32_PROBE Node3D --script accepted`, then `quit(0)`) — not a capture scene |
| `app/scripts/heightmap_world3d.gd` | absent |
| `app/scenes/heightmap3d_sandbox.tscn` | absent |
| `app/shots/g32_dump.json` | absent (dump job still pending) |
| `app/shots/hm3d_full.png` | **absent** |

Running the tool now correctly returns:

```
VERDICT PENDING: no hm3d_*.png shot yet (looked for .../hm3d_full.png). G3-2 sandbox landed=False
```

(`landed=False` in that run refers to the real capture not being ready; the
probe stub landed moments later and is not usable.)

## 4. Image paths + MEASURED stats

### 4.1 Donor reference — MEASURED now (read-only, no copy)

Path: `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg`

| Metric | Value |
|---|---|
| size | 1280x720 |
| mean luminance | 75.35 |
| stddev luminance | 29.09 |
| modal luminance | 94 |
| non-blank fraction | 0.7344 |
| occupied quantised-colour buckets (32-step RGB) | 28 |
| greenish-pixel fraction | 0.2752 |
| top colours (bucket lo RGB, share) | (64,64,32)=0.2376; (32,32,0)=0.1747; (96,96,32)=0.1709; (32,32,32)=0.0665; (96,96,64)=0.0536; (64,64,0)=0.0508 |

The donor reads as a mid-luminance, mid-variance, green/brown oblique scene —
consistent with `terrain3d_shot.py`'s documented donor range (~75–100 ground
luminance).

### 4.2 M0.6 block heightfield — image GONE, documented numbers only

`app/shots/terrain3d_m06.png` does **not** exist (charter: the old dump/patch is
gone). Baseline is therefore **documented, not re-measured here** — from
`docs/SWARM_BOARD.md:407-413`:

- ground luminance **80.65**, cliff-band metric **2921 → 0**, seam gaps **0**,
  **78 draw calls / 16 ms**;
- **visual FAIL** — "still reads as a flat top-down tile mosaic, not the
  donor's oblique eroded landscape".

### 4.3 Heightmap mesh (`hm3d_full.png`) — NO IMAGE YET

No PNG to measure. Nothing here may be credited to the heightmap variant.

Diagnostic state written to `app/shots/hm3d_probe.json` (measured donor +
documented M0.6 + pending flags).

## 5. Comparison

Only half of the A/B exists. We can characterise the donor and restate the
M0.6 baseline, but **no hm3d measurement exists**, so the central comparison is
unavailable. The tool's `heuristic_closer()` (summed absolute difference over
mean luminance, stddev luminance, greenish share, non-blank fraction) is wired
up and will print a numeric hint when both the shot and M0.6 image are
measurable — but M0.6's PNG is also gone, so even after hm3d lands the
comparison will fall back to the **documented** M0.6 scalars, and that
heuristic is explicitly **not a perceptual metric**.

## 6. Verdict table

| Question | Verdict | Basis |
|---|---|---|
| Tool built, pure-Python + runner, `g33-*` id guard | **PASS** | `heightmap3d_shot.py` runs; pending path exercised |
| Donor/JPG baseline MEASURED | **PASS** | Pillow stats in §4.1 |
| `hm3d_*.png` exists and is non-blank 1280x720 | **PENDING** | shot absent (G3-2 still probing) |
| "Heightmap mesh closer to donor than M0.6 block heightfield" | **UNVERIFIED** | no heightmap image to compare; M0.6 image gone; no g33 capture job run |

**Overall for the owner's claim: UNVERIFIED (do not credit either way).**

## 7. Explicit limits

- **Headless capture** (software renderer) — not a windowed donor-like frame.
- **No units / trees / buildings / HUD / fog** in the sandbox — donor depth and
  scene content are out of scope of this A/B.
- **Camera FOV UNVERIFIED** — donor sensor constant unknown; M0.6's 216 mm
  display sensor (17.27° V-FOV) was a visual choice over an unverified
  derivation.
- **M0.6 PNG no longer exists** — baseline is documented scalars, not a
  re-measured image, so the after-the-fact numeric comparison is asymmetric.
- Heuristic distance is coarse statistics only; visual review still governs.

## 8. Open questions

1. When will G3-2 replace the probe stub with the real capture scene and land
   `heightmap_world3d.gd` + a dump?
2. Which dump path will G3-2's sandbox read (`g32_dump.json` vs other)? The
   tool does not couple to it; it only checks the resulting PNG.
3. Will G3-4's splat/albedo land, changing the colour distribution materially?
4. Does headless Godot actually render the viewport `get_image()` for this
   scene, or is a windowed capture required? (Must be answered by the pending
   capture job, not assumed.)
5. Should the coordinator accept a documented-M0.6 numeric comparison, or
   require an archived M0.6 PNG for a symmetric A/B?
