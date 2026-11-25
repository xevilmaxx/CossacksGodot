---
id: A09-CAPTURE-PLAN
title: "A09 — decisive visual A/B measurement plan: fresh WINDOWED 64² P0 + REAL-MAP 320² captures, repetition metrics, non-parity scoring"
ticket: A09 (TERRAIN-SWARM-2026-11-25)
owner: A09 read-only analysis subagent
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Read-only design. Exactly one new file written: this report. No .gd/.gdshader/config/fixture/tool/result file was created or edited; no Godot/runner job was submitted; no donor frame was produced."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists (CHARTER §3; TEST_MATRIX.md:32-34,73-74; CAPTURE_RECHECK.md:35). The reference JPEGs are screenshots with a different camera/content; scoring against them is descriptive ranking, NEVER donor parity."
---

# A09 — decisive visual A/B measurement plan

## 0. Boundary and short answer

**Observed.** A09 is a diagnosis-wave, read-only ticket. Every claim below is grounded in direct reads of `variant3d/tools/smallmap_capture.py`, `docs/coord_swarm_2026-11-25/TEST_MATRIX.md`, `docs/coord_swarm_2026-11-25/VIDEO_QA_PROTOCOL.md`, the capture command examples in `RUN_GUIDE.md`, `CAPTURE_RECHECK.md`, `MASK_ALPHA_FIX_01.md`, `BLANK_CHECK_01.md`, `RELIEF_VISUAL_01.md`, `P0_FRESH_CAPTURE_01.md`, plus on-disk `variant3d/config.json`, `variant3d/tests/fixtures/small_map_64.json`, `variant3d/scripts/{main,config,camera3d,picking3d,data}.gd`. **Derived** = arithmetic/control-flow consequence. **Inferred** = plausible reading with caveat. **UNVERIFIED** = cannot be proven; above all, donor parity.

**Deliverables (all inside this report):** exact windowed capture commands for (a) the 64² P0 atom and (b) a real-map 320² boot at fixed seed/camera; a complete Pillow/NumPy metric script proposed at a new path (NOT created by A09); a scoring rule that ranks candidates against the baseline and describes (but never certifies) the reference samples; runner-id naming; the one-Godot rule; and a copy-pasteable procedure.

**Key constraint (observed):** A09 runs **zero** runner jobs. The commands are a specification for the COORD/implementation agent that owns capture, not work done here.

---

## 1. Fixed conditions — what must be identical across every A/B capture

| Condition | Required value / rule | Source & label |
|---|---|---|
| Launcher | `python variant3d\tools\godot_runner.py run --id <UNIQUE> ...` from the repo root; Windows `python`, never `python3`; PowerShell uses `;`, not `&&` | CHARTER §3; TEST_MATRIX.md:70-72; RUN_GUIDE.md:14; **observed** |
| Windowed | **No `--headless`** in any capture job; headless yields `SKIP_CAPTURE` / `passed=false`, never PASS | TEST_MATRIX.md:62-64; CAPTURE_RECHECK.md:56-60; **observed** |
| Capture surface | `Screenshot3DViewport`, **1280×720**, after ~10 frames (`--screenshot-frames 10`); the root backbuffer reads blank under `gl_compatibility` | TEST_MATRIX.md:29-36; main.gd:167-170,1242; RELIEF_VISUAL_01.md:104-106; **observed** |
| Seed | `20261113` — inherited from the shipped config / `small_map_64.json` and additionally pinned with `--seed 20261113` (applied **after** config merge: main.gd:187-190,1356-1362) | small_map_64.json:12; config.json:77; **observed** |
| Camera | Fixed by `camera.start_zoom=0.3448276` (config.json:70) → height 58 m via `_zoom_to_height` (camera3d.gd:239-241); perspective FOV 17.27° (camera3d.gd:88,175-195); no pan/zoom/wheel input during capture | config.json:70; camera3d.gd:175-195,239-241; data.gd:197-198; **observed/derived** |
| Camera proof | The capture diag line must contain `image=1280x720`, `camera_current=true` and a recorded `camera_pos=... target=...`; the 64² baseline recorded `camera_pos=(21.98215, 58.0, 70.25505) target=(85.98215, 41.43565)` | RELIEF_VISUAL_01.md:104-106; MASK_ALPHA_FIX_01.md:155; **observed** |
| P0 fixture | `variant3d/tests/fixtures/small_map_64.json` — 64² synthetic all-grass stub, 4,096 verts / 7,938 tris / 4,096 UV2, atlas (16,8), shadow off, no trees/shore/mines/water | TEST_MATRIX.md:29-40; CAPTURE_RECHECK.md:98-110; **observed** |
| Real map | 320² generated game boot through main's `--screenshot` path (no `--script` atom), same seed/camera/FOV | G31_donor_3d_truth.md:195-207; MASK_ALPHA_FIX_01.md:138-157; **observed/derived** |
| Artefact location | `%LOCALAPPDATA%\Temp\opencode\a09\...` — **never in the repo** | VIDEO_QA_PROTOCOL.md:28; RUN_GUIDE.md:92; **observed** |
| Integrity gates | PNG exists, 1280×720, non-blank; atom JSON `capture_image`/`capture_saved` hold; `scan-stderr` returns `script_error_lines: 0` | CAPTURE_RECHECK.md:56-60; smallmap_capture.py:21-39,50-58; **observed** |
| Visual verdict | A second agent opens the PNG and records `observed/derived/inferred/UNVERIFIED` separately; the owner never self-certifies; metrics never override the visual read | TEST_MATRIX.md:73-75; CAPTURE_RECHECK.md §3; **observed** |

**Important config drift (observed).** The charter and several coord reports describe the shipped map as 320², but **at A09's read time the on-disk** `variant3d/config.json` reads `gameplay.map_width_tiles: 240` and `map_height_tiles: 240` (lines 75-76). Concurrent implementation tickets may change it again — re-check immediately before capturing. Therefore a real-map 320² capture **cannot safely** rely on the shipped config alone: pass a tiny override config (§2.2), which pins 320² regardless of the base layer. This is a PORT APPROX measurement setup, not a game edit. Do not silently treat a 240² capture as 320².

Pixels-per-metre for the metric script (derived, PORT APPROX). At the view centre, `ppm = 720 / (2·tan(FOV/2)·D)` where `D = |camera_pos − target|` from the capture diag and `FOV = 17.27°`. For the 64² baseline `D ≈ 66.1 m`, giving **≈35.9 px/m**. Hold this value identical across A/B rows of one fixture; record the diag-derived value per capture. Because the ground is foreshortened, row-wise (y) metrics are approximate — label them as such.

---

## 2. Exact capture commands (copy-paste; run from repo root)

### 2.0 Preflight (every capture session)

```bat
python variant3d\tools\godot_runner.py status
```

Confirm the spool line and that no job of yours is in flight (RUN_GUIDE.md:63; **observed**). Create the artefact directory (PowerShell):

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\a09"
```

### 2.1 Fresh WINDOWED 64² P0 frame — `t_terrain_only.gd` stub

Proven form: RUN_GUIDE.md:73, FINAL_GATE_PLAN_01.md:126-130, `P0_FRESH_CAPTURE_01.md:54` (job 504), `P0_GATE_01.md:131`. The atom reads `--screenshot` with `--png` fallback (`t_terrain_only.gd:413-415`) and creates the output dir recursively (`:664-666`). Seed/camera are inherited from the shipped config/fixture; the atom builds a flat 64² control grid by construction.

```bat
python variant3d\tools\godot_runner.py run --id a09-p0-baseline --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/smallmap64_p0_fresh.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/smallmap64_p0_fresh.png"
```

- No `--headless`; `--screenshot` and `--png` point at the **same** path (observed precedent).
- Expect `t_terrain_only.json` at `variant3d\tests\results\t_terrain_only.json` with `capture_image`, `capture_saved`, and the luma gates (`ground_mean_luma >= 40`, `ground_max_luma >= 100`); `full_width_dark_rows` is a recorded diagnostic, not a pass/fail gate (CAPTURE_RECHECK.md:106-110; **observed**).
- The fresh `p0fresh01/p0_final_formula.png` is the current visual baseline (CHARTER §1, row 1). Keep it as the reference input for scoring; do not overwrite it.

### 2.2 REAL-MAP 320² frame — generated game boot, fixed seed/camera

The real-map capture pattern is proved by `MASK_ALPHA_FIX_01.md:138-157` (job 563, `ok`/0), `RELIEF_VISUAL_01.md:70-85` (job 532) and `BLANK_CHECK_01.md:141-157`: **no `--script`**, `--screenshot` as a user arg after the second `--`, `--screenshot-frames 10`, absolute `--config`, main watchdog `--timeout 120`, runner `--timeout 300`. To force 320² despite the on-disk 240², create an override config **outside the repo** (the `--config` layer is a third merge layer over `res://config.json`: A12 §0, config.gd:275-304,309-322):

```powershell
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":320,"map_height_tiles":320}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\a09\real_map_320.json" -Encoding ascii -NoNewline
```

Use an ASCII path without spaces (the doc's absolute-path-with-spaces `--config` form succeeded in jobs 532/563, but a spaces-free path avoids the ticket-380/386 failure class — RUN_GUIDE.md:92; **derived**). Then:

```bat
python variant3d\tools\godot_runner.py run --id a09-realmap320-baseline --timeout 300 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/realmap320_fresh.png" --screenshot-frames 10 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/real_map_320.json" --seed 20261113 --timeout 120
```

- Expected grid: 320×320 = 102,400 cells (G31_donor_3d_truth.md:200-207; **derived**). Confirm from the stdout dump/camera diag that the boot used the override (config source line `settings file:` from main.gd:198) before comparing rows.
- `--seed 20261113` is a belt-and-braces pin; main.gd:187-190 applies it after config, so it wins over `random_seed` in any layer.
- **Known failure mode (observed, not a visual defect):** the `_is_blank()` one-sided luminance comparator (main.gd:1932-1942) can reject a valid olive frame because bright sky (`p00≈(0.71,0.91,1.0)`) makes ground pixels look "not brighter". Job 532 failed this way but left a valid `.raw.png` sidecar; job 563 succeeded with the same camera. If it recurs, analyse `<name>.png.raw.png` and record the failure as an instrument defect — do **not** edit the detector (read-only, no test weakening: CHARTER §3, TEST_MATRIX.md:67-68).

### 2.3 Integrity check (both captures)

```bat
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/smallmap64_p0_fresh.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/realmap320_fresh.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket-id>_a09-p0-baseline\stderr.txt variant3d\.godot_queue\results\<ticket-id>_a09-realmap320-baseline\stderr.txt
```

Replace `<ticket-id>` with the 8-digit job number printed by the runner (e.g. `00000404_TESTRUN02-P0`, CAPTURE_RECHECK.md:79). `stats` is explicitly a **qualitative inspector only** and prints "No donor parity is claimed" (smallmap_capture.py:47); `scan-stderr` must return `script_error_lines: 0`.

---

## 3. Proposed metric script — SPEC ONLY, NOT CREATED BY A09

**New file path (to be created by an implementation owner, NOT by this agent):**
`variant3d/tools/terrain_repetition_metrics.py`

It is a sibling of `variant3d/tools/smallmap_capture.py` and uses the same dependencies (`numpy` + `PIL`, both already imported by that tool: smallmap_capture.py:17-18). Keep all outputs under `%LOCALAPPDATA%\Temp\opencode\a09`. The script below was syntax/import checked and smoke-run on the existing `p0fresh01/p0_final_formula.png` (read-only); it writes only the optional `--json` output.

```python
#!/usr/bin/env python3
"""A09-proposed repetition / streak / seam / multi-scale colour metrics.

Spec only: A09 did NOT create this file. Read-only on captures; no Godot, no game edit.

    python variant3d\\tools\\terrain_repetition_metrics.py <capture.png> [...] \
        --px-per-m 35.9 --crop 0.15,0.20,0.85,0.80 \
        --baseline <baseline.png> \
        --reference <ref1.jpg> <ref2.jpg> --reference-crop 0.05,0.25,0.60,0.75 \
        --json <TEMP>/a09/a09_metrics.json

Prints JSON to stdout. Labels every result PORT APPROX; no donor parity is claimed.
"""
from __future__ import annotations

import argparse
import copy
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

LUMA = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
SPACINGS_M = (2.0, 8.0, 32.0)
SCALES_M = (1.0, 2.0, 4.0, 8.0, 16.0, 32.0)
BOX = getattr(Image, "Resampling", Image).BOX  # Pillow 12 compatible


def parse_crop(text):
    try:
        v = [float(x) for x in text.split(",")]
    except ValueError as e:
        raise argparse.ArgumentTypeError("crop must be x0,y0,x1,y1") from e
    if len(v) != 4 or not (0 <= v[0] < v[2] <= 1 and 0 <= v[1] < v[3] <= 1):
        raise argparse.ArgumentTypeError("crop must satisfy 0<=x0<x1<=1, 0<=y0<y1<=1")
    return tuple(v)


def load_rgb(path, crop):
    with Image.open(path) as im:
        im = im.convert("RGB")
        w, h = im.size
        x0, y0, x1, y1 = crop
        box = (int(round(x0 * w)), int(round(y0 * h)),
               int(round(x1 * w)), int(round(y1 * h)))
        im = im.crop(box)
        arr = np.asarray(im, dtype=np.float32)
    if arr.ndim != 3 or arr.shape[2] != 3 or min(arr.shape[:2]) < 8:
        raise ValueError(f"{path}: unusable crop {arr.shape}")
    return arr


def detrend(rgb, preblur_px=1.0):
    """Remove slow lighting slope; keep 2/8/32 m scales. Returns zero-mean residual."""
    luma = rgb @ LUMA
    if preblur_px > 0:
        im = Image.fromarray(np.clip(luma, 0, 255).astype(np.uint8), "L")
        im = im.filter(ImageFilter.GaussianBlur(preblur_px))
        luma = np.asarray(im, dtype=np.float32)
    h, w = luma.shape
    yy, xx = np.mgrid[0:h, 0:w]
    xn = 2.0 * xx / max(w - 1, 1) - 1.0
    yn = 2.0 * yy / max(h - 1, 1) - 1.0
    basis = np.stack([np.ones_like(xn), xn, yn, xn * xn, xn * yn, yn * yn], axis=-1)
    step = max(1, min(h, w) // 96)
    sample = (slice(None, None, step), slice(None, None, step))
    coef, *_ = np.linalg.lstsq(basis[sample].reshape(-1, 6),
                               luma[sample].ravel(), rcond=None)
    return luma - (basis @ coef).reshape(h, w)


def autocorr(res, dx, dy):
    """Normalised autocorrelation of the residual at pixel lag (dx, dy)."""
    h, w = res.shape
    x0, x1 = max(0, dx), min(w, w + dx)
    y0, y1 = max(0, dy), min(h, h + dy)
    if x1 <= x0 or y1 <= y0:
        return 0.0
    a = res[y0:y1, x0:x1]
    b = res[y0 - dy:y1 - dy, x0 - dx:x1 - dx]
    den = float(np.dot(res.ravel(), res.ravel()))
    return float(np.dot(a.ravel(), b.ravel()) / den) if den > 1e-9 else 0.0


def repetition(res, ppm):
    """Autocorrelation at 2 m / 8 m / 32 m, along axes and diagonals."""
    out = {}
    for s in SPACINGS_M:
        lag = max(2, int(round(s * ppm)))
        d = {
            "horizontal": autocorr(res, lag, 0),
            "vertical": autocorr(res, 0, lag),
            "diagonal_downright": autocorr(res, lag, lag),
            "diagonal_downleft": autocorr(res, -lag, lag),
        }
        local = 0.5 * (autocorr(res, max(1, lag - 5), 0) +
                       autocorr(res, lag + 5, 0))
        overlap = round(1.0 - lag / max(min(res.shape), 1), 4)
        out[f"{s:g}m"] = {
            "lag_px": lag,
            **{k: round(v, 5) for k, v in d.items()},
            "axis_excess": round(max(d["horizontal"], d["vertical"]) - local, 5),
            "diagonal_excess": round(max(d["diagonal_downright"],
                                         d["diagonal_downleft"]) - local, 5),
            "overlap_fraction": overlap,
            "reliability": "OK" if lag <= min(res.shape) / 3.0
                           else "LOW_OVERLAP__UNVERIFIED",
        }
    return out


def directional_gradients(res):
    """Diagonal streak energy via 0/45/90/135-degree directional gradients."""
    gx = 0.5 * (np.roll(res, -1, 1) - np.roll(res, 1, 1))
    gy = 0.5 * (np.roll(res, -1, 0) - np.roll(res, 1, 0))
    inv = 1.0 / math.sqrt(2.0)
    g45, g135 = (gx + gy) * inv, (gx - gy) * inv
    inner = (slice(2, -2), slice(2, -2))
    e = {
        "along_x": float(np.abs(gx[inner]).mean()),
        "along_y": float(np.abs(gy[inner]).mean()),
        "diag_45": float(np.abs(g45[inner]).mean()),
        "diag_135": float(np.abs(g135[inner]).mean()),
    }
    axis = e["along_x"] + e["along_y"]
    diag = e["diag_45"] + e["diag_135"]
    return {
        **{k: round(v, 4) for k, v in e.items()},
        "diagonal_index": round(diag / (axis + 1e-6), 5),
    }


def tile_boundary(res, ppm):
    """Peakiness of mean |gradient| by phase modulo the 2 m atlas cell."""
    period = max(2, int(round(2.0 * ppm)))
    dx = np.abs(np.diff(res, axis=1)).mean(axis=0)
    dy = np.abs(np.diff(res, axis=0)).mean(axis=1)

    def peakiness(d):
        phase = np.arange(d.size) % period
        counts = np.bincount(phase, minlength=period).astype(float)
        profile = np.bincount(phase, weights=d, minlength=period) / np.maximum(counts, 1.0)
        k = int(np.argmax(profile))
        return round(float(profile[k] / max(profile.mean(), 1e-6) - 1.0), 5), k

    cx, px = peakiness(dx)
    cy, py = peakiness(dy)
    return {
        "period_px_2m": period,
        "contrast_x": cx, "peak_phase_x_px": px,
        "contrast_y": cy, "peak_phase_y_px": py,
        "note": "y (row) metric is approximate: ground foreshortened by perspective camera",
    }


def multiscale_variance(rgb, res, ppm):
    """Luma/RGB variance of block-averaged images at 1/2/4/8/16/32 m."""
    h, w = rgb.shape[:2]
    im8 = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB")
    out = {}
    for s in SCALES_M:
        block = max(1, int(round(s * ppm)))
        bw, bh = max(1, w // block), max(1, h // block)
        if bw < 2 or bh < 2:
            out[f"{s:g}m"] = {
                "not_measurable": True,
                "reason": "fewer than 2 blocks fit the crop at the fixed camera; UNVERIFIED",
            }
            continue
        small = np.asarray(im8.resize((bw, bh), BOX), dtype=np.float32)
        luma_small = small @ LUMA
        out[f"{s:g}m"] = {
            "block_px": block, "blocks": [bw, bh],
            "luma_var": round(float(luma_small.var()), 4),
            "rgb_var": [round(float(small[:, :, c].var()), 4) for c in range(3)],
        }
    grain = float(res.var())
    out["grain_residual_var"] = round(grain, 4)
    eight = out.get("8m", {})
    out["mottle_ratio"] = (round(eight["luma_var"] / max(grain, 1e-6), 5)
                           if "luma_var" in eight else None)
    return out


def measure(path, args):
    rgb = load_rgb(path, args.crop)
    res = detrend(rgb, args.preblur_px)
    rep = repetition(res, args.px_per_m)
    grad = directional_gradients(res)
    bound = tile_boundary(res, args.px_per_m)
    multi = multiscale_variance(rgb, res, args.px_per_m)
    summary = {
        "rep_strength": round(max(0.0, max(v["axis_excess"] for v in rep.values())), 5),
        "diag_rep_strength": round(max(0.0, max(v["diagonal_excess"] for v in rep.values())), 5),
        "boundary_contrast": round(max(bound["contrast_x"], bound["contrast_y"]), 5),
    }
    return {
        "path": str(path), "crop": list(args.crop),
        "crop_px": [int(rgb.shape[1]), int(rgb.shape[0])],
        "px_per_m": args.px_per_m,
        "autocorr": rep, "gradients": grad,
        "tile_boundary": bound, "multiscale_variance": multi,
        "summary": summary,
        "scale_free": {
            "diagonal_index": grad["diagonal_index"],
            "boundary_contrast": summary["boundary_contrast"],
            "mottle_ratio": multi.get("mottle_ratio"),
        },
    }


def ratio(c, b, cap=3.0):
    return round(min(cap, c / max(b, 1e-6)), 4)


def score(candidate, baseline):
    """Rank a candidate AGAINST THE BASELINE at identical camera/fixture.

    ARI = 0.40*rep + 0.25*diag_rep + 0.20*boundary + 0.15*inverse_mottle.
    All terms are candidate/baseline ratios (capped at 3); lower is better.
    """
    c, b = candidate["summary"], baseline["summary"]
    cm, bm = candidate["scale_free"], baseline["scale_free"]
    r_rep = ratio(c["rep_strength"], b["rep_strength"])
    r_diag = ratio(c["diag_rep_strength"], b["diag_rep_strength"])
    r_bound = ratio(c["boundary_contrast"], b["boundary_contrast"])
    r_inv_mottle = ratio(bm.get("mottle_ratio") or 0.0,
                         cm.get("mottle_ratio") or 0.0)
    ari = round(0.40 * r_rep + 0.25 * r_diag + 0.20 * r_bound
                + 0.15 * r_inv_mottle, 4)
    return {
        "path": candidate["path"],
        "ratios_vs_baseline": {
            "repetition": r_rep, "diagonal_repetition": r_diag,
            "boundary": r_bound, "inverse_mottle": r_inv_mottle,
        },
        "artifact_regression_index_ARI": ari,
        "interpretation": ("ARI < 1 = fewer artifacts than baseline at fixed "
                           "camera; > 1 = regression. PORT APPROX, not donor parity."),
    }


def main() -> None:
    ap = argparse.ArgumentParser(description="A09 terrain repetition metrics")
    ap.add_argument("images", nargs="+", help="candidate capture PNGs")
    ap.add_argument("--px-per-m", type=float, default=35.9,
                    help="ground px/m at capture target (PORT APPROX; derive from camera diag)")
    ap.add_argument("--crop", type=parse_crop, default=(0.15, 0.20, 0.85, 0.80),
                    help="normalised ground crop x0,y0,x1,y1")
    ap.add_argument("--preblur-px", type=float, default=1.0)
    ap.add_argument("--baseline", default=None,
                    help="pre-fix capture of the SAME fixture/camera")
    ap.add_argument("--reference", nargs="*", default=[],
                    help="reference JPEG/PNG samples (NOT donor GPU A/B)")
    ap.add_argument("--reference-crop", type=parse_crop, default=(0.05, 0.25, 0.60, 0.75))
    ap.add_argument("--json", default=None, help="output JSON path (keep outside the repo)")
    args = ap.parse_args()

    rows = [measure(p, args) for p in args.images]
    result = {
        "tool": "A09-proposed terrain_repetition_metrics",
        "labels": "PORT APPROX — no donor parity claimed",
        "px_per_m": args.px_per_m, "crop": list(args.crop), "images": rows,
    }
    if args.baseline:
        base = measure(args.baseline, args)
        result["baseline"] = {
            "path": args.baseline, "summary": base["summary"],
            "scale_free": base["scale_free"],
        }
        result["scores"] = [score(r, base) for r in rows]
    if args.reference:
        ref_args = copy.copy(args)
        ref_args.crop = args.reference_crop
        refs = [measure(p, ref_args) for p in args.reference]
        bands = {}
        for key in ("diagonal_index", "boundary_contrast", "mottle_ratio"):
            vals = [r["scale_free"][key] for r in refs
                    if r["scale_free"][key] is not None]
            if vals:
                bands[key] = {"min": round(min(vals), 5), "max": round(max(vals), 5)}
        result["reference_band"] = {
            "paths": [str(p) for p in args.reference],
            "crop": list(args.reference_crop), "scale_free_bands": bands,
            "note": ("Evidence only: screenshots have a different camera/content. "
                     "No donor parity claim."),
        }
    text = json.dumps(result, indent=2)
    print(text)
    print("NOTE: qualitative ranking only. Donor parity UNVERIFIED "
          "(no donor GPU A/B frame exists).")
    if args.json:
        Path(args.json).write_text(text + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
```

### 3.1 What each metric detects, and its honest limit

| Metric | Implementation | Signal for the owner's symptom | Limit / label |
|---|---|---|---|
| Autocorrelation at 2/8/32 m | Zero-mean, linear-trend-detrended luma; normalised shift-dot at lags `round(s·ppm)` along x, y, both diagonals; `axis_excess`/`diagonal_excess` versus neighbouring lags | A strong peak at the **2 m** lag is the hard atlas repeat (`uv_repeat=(0.5,0.5)`, CHARTER §2 suspect 1); a peak at 8/32 m implies patch-scale repetition | 32 m lag ≈1,149 px is near/over the 1,280 px frame edge → `reliability: LOW_OVERLAP__UNVERIFIED` is expected; do not interpret a 0 as "clean"; **derived/PORT APPROX** |
| Diagonal streak energy | 0°/45°/90°/135° central-difference gradients; `diagonal_index = (E45+E135)/(E0+E90)` plus diagonal autocorrelation excess | Elevated diagonal index or diagonal autocorrelation at 2 m matches the "faint diagonal streaks / repeating bands" seen in the P0 frame (CHARTER §1 row 1) | Natural diagonal content (cliffs) also raises it; compare **against baseline**, never to a donor constant; **inferred** |
| Tile-boundary discontinuity | Mean `|Δluma|` per column/row, binned by phase modulo the 2 m cell (~72 px at 35.9 px/m); `contrast = peak/mean − 1` | A periodic phase spike is a grid/seam boundary (CHARTER §2 suspects 1 and 2) | Row metric is foreshortened; atlas phase unknown in image space, so the metric reports peak phase rather than absolute alignment; **derived/PORT APPROX** |
| Colour variance at multiple scales | BOX downsample to 1/2/4/8/16/32 m blocks; luma and per-channel variance; `mottle_ratio = var(8 m blocks)/fine-grain residual var` | The donor samples show large soft green mottling; a flat olive field has low coarse-scale variance and a low `mottle_ratio` | 32 m scale may be `not_measurable` at the fixed camera (fewer than 2 blocks) → record `UNVERIFIED`; **observed metric / inferred interpretation** |

Smoke check already performed on the existing P0 PNG (read-only, central crop, ppm 35.9): 2 m axis autocorrelation ≈0.277, 8 m ≈0.038, 32 m out-of-range; boundary contrast ≈0.046; 1 m block variance ≈4.9 versus 8 m ≈1.5. These are **uncalibrated baseline numbers only** — no defect threshold and no donor comparison is implied by them.

---

## 4. Scoring candidates — and why this is not donor parity

### 4.1 Two-track decision rule (observed policy, derived formula)

**Track A — authoritative internal A/B (PORT APPROX, same fixture/camera/seed).** Build a baseline pair first: `smallmap64_p0_fresh.png` (P0 stub) and `realmap320_fresh.png` (real map). For every fix candidate, capture a **new** PNG with the same command and the same fixture, then run the script with `--baseline <same-fixture baseline>`:

```
ARI = 0.40·(rep_c/rep_b) + 0.25·(diag_c/diag_b) + 0.20·(bound_c/bound_b) + 0.15·(mottle_b/mottle_c)
```

each ratio capped at 3 so one runaway metric cannot dominate. `ARI < 1` means fewer artifacts than baseline; `> 1` means regression. Interpret per-metric ratios alongside ARI: repetition and boundary ratios must each be < 1 for a genuine improvement, and `mottle_ratio` must increase. **A candidate is not a PASS by ARI alone** — the second agent must still open the PNG and describe regions, and the atom's own gates must stay green (CAPTURE_RECHECK.md §3 rules 1-7; TEST_MATRIX.md:73-74; **observed**). Any defect visible in the image overrides a green score.

**Track B — reference samples, descriptive only (UNVERIFIED parity).** The two named samples are
`C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` and
`...\articolo-787.jpg` (CHARTER §1, rows 3-4), from a 12-screenshot donor folder. They are **JPEG screenshots with a different camera, FOV, resolution, content (trees/cliffs/UI) and no captured camera diag**. Run them through the same script with a reviewer-chosen `--reference-crop` that excludes UI/sky/trees (record the crop in the report). Compare only the **scale-free** fields (`diagonal_index`, `boundary_contrast`, `mottle_ratio`) as a band, e.g. "candidate mottle_ratio moved from 0.8× to 1.9× of the reference band, diagonal_index halved". Do **not** feed the reference numbers into ARI; do **not** call the result parity.

**Verdict vocabulary to use in the scorecard:** `PORT APPROX — internal consistency only` for Track A; `UNVERIFIED — no donor GPU A/B frame` for Track B. Donor parity requires an actual donor GPU A/B frame, which does not exist (CHARTER §3; CAPTURE_RECHECK.md:35,237; VIDEO_QA_PROTOCOL.md:48-52; **observed**).

### 4.2 Scorecard template (one row per candidate, per fixture)

| Field | Content |
|---|---|
| Runner id / job / fixture | e.g. `b03-a09-p0-uvrepeat025`, job `<n>`, 64² P0 / real-map 320² |
| Artefacts | PNG path, `t_terrain_only.json` path, `stderr.txt` path, `a09_metrics.json` path |
| Capture integrity | windowed (no `--headless`), 1280×720, non-blank, `camera_current=true`, camera diag, `script_error_lines=0` |
| Track A | ARI; four ratios vs baseline; per-lag autocorrelation table; diagonal index; boundary contrast; multi-scale variance |
| Track B | reference band per scale-free field; direction of movement only; `UNVERIFIED` parity label |
| Second-agent image verdict | regions described in words; defects named or explicitly absent; `observed/derived/inferred/UNVERIFIED` separated |
| Decision | `IMPROVED / NO CHANGE / REGRESSION` (PORT APPROX) + `parity UNVERIFIED`; COORD alone advances any ladder row (CAPTURE_RECHECK.md §4; **observed**) |

If a metric's predicate is inapplicable (32 m lag at the frame edge; 32 m blocks not fitting), record the raw value **and** `UNVERIFIED` — never drop it, never substitute a donor constant (CAPTURE_RECHECK.md:238-240; **observed**).

---

## 5. Runner-id naming and the one-Godot-at-a-time rule

**Naming convention (derived from observed ids `p0fresh01-capture`, `vidcap01-frames`, `blankcheck01-boot`, `maskalpha01-realmap`, `TESTRUN02-P0`, `coord-final-selftest`):** lowercase, hyphen-separated, `<owning-ticket>-<fixture>-<variant>`, unique on **every** invocation (RUN_GUIDE.md:14, `docs/COMMANDS.md:32`):

| Row | Id pattern | Example |
|---|---|---|
| A09 baselines | `a09-p0-baseline`, `a09-realmap320-baseline` | §2.1 / §2.2 |
| Implementer candidate on P0 | `<ticket>-a09-p0-<variant>` | `b03-a09-p0-uvrepeat025` |
| Implementer candidate on real map | `<ticket>-a09-rm320-<variant>` | `b03-a09-rm320-masktoalpha0` |

Do not reuse an id, do not `reset`/`ack`/`unwedge` as an analysis worker, and never bypass the runner with a direct `godot` call. Results land in `variant3d\.godot_queue\results\<ticket>_<job-id>\` (RUN_GUIDE.md:55).

**One Godot at a time (binding, CHARTER §3; TEST_MATRIX.md:70-72; RUN_GUIDE.md:92):** run `python variant3d\tools\godot_runner.py status` before submitting; the FIFO runner serialises jobs, so submit the next capture only after the previous job's JSON plus PNG/stderr exist. A09 itself submits **no** jobs. Never run the 2D `app/tools/godot_runner.py doctor` during a variant job (it kills Godot by name regardless of spool — RUN_GUIDE.md:55,129). Expect long FIFO waits as telemetry, not hangs (RUN_GUIDE.md:101).

---

## 6. Copy-pasteable procedure (for the capture-owning agent; A09 runs none)

All commands assume the repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3` (`Set-Location` in PowerShell, `cd /d` in CMD), Windows `python`, PowerShell `;`.

1. **Preflight** — `python variant3d\tools\godot_runner.py status`; confirm quiet queue. Create `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\a09`.
2. **Baseline P0 (fresh, windowed)** — §2.1 command with id `a09-p0-baseline`. Keep the existing `p0fresh01/p0_final_formula.png` untouched as the visual baseline.
3. **Baseline real-map 320² (fresh, windowed)** — create `real_map_320.json` (§2.2), then §2.2 command with id `a09-realmap320-baseline`. Check stdout reports the override config and 320² grid.
4. **Integrity** — §2.3 `smallmap_capture.py stats` and `scan-stderr`; require 1280×720, non-blank, `script_error_lines=0`, `camera_current=true`. If the blank detector rejects a valid frame, analyse the `.raw.png` sidecar and record an instrument defect; do not edit the detector.
5. **Second-agent visual read** — open both PNGs; describe regions; name or explicitly deny diagonal streaks / checker mosaic / repeated dark blotches / seams / black rows (CAPTURE_RECHECK.md §3).
6. **Baseline metrics** — run the §3 script once per fixture with `--baseline <same baseline>` to freeze baseline numbers into `a09_metrics_baseline.json`. Record per-capture `--px-per-m` from the camera diag.
7. **Candidate captures** — for each fix, repeat steps 2-4 with the §5 unique id; then:
   ```
   python variant3d\tools\terrain_repetition_metrics.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/<candidate>.png" --baseline "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/smallmap64_p0_fresh.png" --px-per-m 35.9 --crop 0.15,0.20,0.85,0.80 --reference "C:/Users/Maxym.Oboyshev/Downloads/c3/cossacks-3-v1-498085.jpg" "C:/Users/Maxym.Oboyshev/Downloads/c3/articolo-787.jpg" --reference-crop 0.05,0.25,0.60,0.75 --json "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/a09/<candidate>_metrics.json"
   ```
   (substitute the real-map baseline PNG when scoring a 320² candidate).
8. **Score** — fill the §4.2 scorecard; Track A ARI/ratios decide `IMPROVED / NO CHANGE / REGRESSION`; Track B reference band is descriptive; both carry `parity UNVERIFIED`. Metrics never override the second agent's visual verdict.
9. **Record** — write `reports/RECHECK_<ROW>.md` per CAPTURE_RECHECK.md §4; COORD alone advances any ladder row and runs FINAL last (TEST_MATRIX.md:57-66). Keep raw frames and metric JSONs until the verdict is recorded (VIDEO_QA_PROTOCOL.md:37).

---

## 7. What A09 did not do, and open questions

**Observed.** No file other than this report was created/edited; no Godot process was launched; no donor asset was accessed beyond the two paths already named in the charter; no metric threshold was invented; no donor parity was claimed. The metric script is a **specification** at a proposed path — its implementation is not part of this ticket.

**Open questions / UNVERIFIED:**
1. Will the on-disk `config.json` still be 240² when implementation runs? Re-check before step 3; if restored to 320², the override is still harmless (it pins the same values).
2. Exact 32 m repetition/scale measurement is at the frame edge at the fixed 58 m camera height; a true 32 m sample would need a separately authorised wider-FOV capture with a recorded camera change — out of A09's scope.
3. Whether any candidate actually reduces the artifacts is **UNVERIFIED** until the captures and second-agent reviews land; this report provides the measurement instrument, not a verdict.
4. The donor JPEGs' camera/crop is unknown; the reference band is a qualitative aid only, never a parity certificate.

*End of A09_capture_plan.md.*
