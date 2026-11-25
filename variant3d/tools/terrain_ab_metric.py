#!/usr/bin/env python3
"""Texture-statistics metric for terrain A/B work (ticket C01, TERRAIN-SWARM-2026-11-25).

Scores a candidate PNG against a reference PNG (or against a folder of donor
stills) using *statistics that are independent of scene content*: this tool
does NOT compare two pictures pixel-by-pixel. It measures the statistical
shape of the surface so that a flat/tiled render can be told apart from an
organic donor still even when the two show different scenery.

Reported metrics (all computed on luma unless stated otherwise):

  * multi-scale block variance       - between/within-block variance at 2..128 px
  * autocorrelation                  - Pearson r at chosen (dx,dy) pixel lags
  * directional-gradient energy      - axis vs diagonal gradient energy,
                                       structure-tensor coherence/orientation,
                                       directional FFT power of the detrended
                                       luma (banding / moire view)
  * seam / repetition score          - row/column spikes, profile periodicity,
                                       shifted-patch repetition
  * colour statistics                - mean/std RGB, luma, saturation

Two modes:

    python variant3d\\tools\\terrain_ab_metric.py CANDIDATE.png REFERENCE.png [--json]
    python variant3d\\tools\\terrain_ab_metric.py CANDIDATE.png \
        --compare-ref "C:\\Users\\Maxym.Oboyshev\\Downloads\\c3" [--json]

Exit codes: 0 = computed, 2 = bad invocation / unreadable input (including a
missing numpy). No Godot, no network, no donor-asset access beyond reading the
images the caller names. Every number is a SMOKE METRIC for human calibration:
it is NOT a fidelity gate and NOT proof of donor parity (see the charter,
"observed vs inferred vs UNVERIFIED").
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

from PIL import Image, ImageOps

try:
    import numpy as np
except ImportError as _np_exc:  # guarded: a clear message beats a traceback
    np = None
    NUMPY_IMPORT_ERROR = str(_np_exc)
else:
    NUMPY_IMPORT_ERROR = ""

DEFAULT_REF_FOLDER = Path(r"C:\Users\Maxym.Oboyshev\Downloads\c3")
DEFAULT_BLOCKS = "2,4,8,16,32,64,128"
DEFAULT_LAGS = (
    (1, 0), (0, 1), (1, 1), (1, -1),
    (2, 2), (2, -2), (4, 0), (0, 4),
    (8, 8), (8, -8), (16, 0), (0, 16),
    (32, 32), (32, -32), (64, 0), (0, 64),
)
IMAGE_EXTS = (".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tif", ".tiff")
LUMA_WEIGHTS = (0.2126, 0.7152, 0.0722)  # Rec.709, 0..255 luma
SMOKE_LABEL = "SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof"
SCHEMA = "terrain_ab_metric/1"


def require_numpy() -> bool:
    if np is None:
        print("ERROR: numpy is required for this tool but could not be imported: %s\n"
              "Install it into this Python (e.g. 'python -m pip install numpy')."
              % NUMPY_IMPORT_ERROR, file=sys.stderr)
        return False
    return True


# ---------------------------------------------------------------------------
# Input helpers
# ---------------------------------------------------------------------------

def parse_crop(text: str) -> tuple[int, int, int, int]:
    """Argparse type for --crop x,y,w,h (pixels, applied to every image)."""
    parts = text.split(",")
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("--crop must be x,y,w,h (four integers)")
    try:
        x, y, w, h = (int(p.strip()) for p in parts)
    except ValueError:
        raise argparse.ArgumentTypeError("--crop must be x,y,w,h (four integers)")
    if x < 0 or y < 0 or w <= 0 or h <= 0:
        raise argparse.ArgumentTypeError("--crop needs x,y >= 0 and w,h > 0")
    return x, y, w, h


def parse_crop_frac(text: str) -> tuple[float, float, float, float]:
    """Argparse type for --crop-frac x0,y0,x1,y1 (fractions 0..1, per image).

    Allows A11-style ground ROIs (e.g. `.35,.55,.48,.70`) to be applied to
    images of different native resolutions without hand-computing pixels.
    """
    parts = text.split(",")
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("--crop-frac must be x0,y0,x1,y1")
    try:
        v = tuple(float(p.strip()) for p in parts)
    except ValueError:
        raise argparse.ArgumentTypeError("--crop-frac must be four numbers in 0..1")
    x0, y0, x1, y1 = v
    if not (0.0 <= x0 < x1 <= 1.0 and 0.0 <= y0 < y1 <= 1.0):
        raise argparse.ArgumentTypeError("--crop-frac needs 0<=x0<x1<=1, 0<=y0<y1<=1")
    return v


def parse_blocks(text: str) -> tuple[int, ...]:
    """Argparse type for --blocks 2,4,8,... (positive pixel sizes)."""
    try:
        values = tuple(int(p.strip()) for p in text.split(",") if p.strip())
    except ValueError:
        raise argparse.ArgumentTypeError("--blocks must be comma-separated integers")
    if not values or any(v <= 0 for v in values):
        raise argparse.ArgumentTypeError("--blocks needs positive integers")
    return tuple(sorted(set(values)))


def parse_lags(text: str) -> tuple[tuple[int, int], ...]:
    """Argparse type for --lags 'dx,dy;dx,dy;...' (integer pixel shifts)."""
    lags = []
    for chunk in text.split(";"):
        chunk = chunk.strip()
        if not chunk:
            continue
        parts = chunk.split(",")
        if len(parts) != 2:
            raise argparse.ArgumentTypeError("--lags entries must be dx,dy")
        try:
            lags.append((int(parts[0].strip()), int(parts[1].strip())))
        except ValueError:
            raise argparse.ArgumentTypeError("--lags entries must be integer dx,dy")
    if not lags:
        raise argparse.ArgumentTypeError("--lags needs at least one dx,dy entry")
    return tuple(lags)


def load_rgb(path: Path,
             crop: tuple[int, int, int, int] | None,
             crop_frac: tuple[float, float, float, float] | None = None):
    """Open any Pillow-readable image, honour EXIF orientation, return RGB.

    ``crop`` is pixel x,y,w,h; ``crop_frac`` is fractional x0,y0,x1,y1 and is
    resolved against each image's own size. At most one may be supplied.
    """
    try:
        with Image.open(path) as raw:
            im = ImageOps.exif_transpose(raw).convert("RGB")
    except (OSError, ValueError) as exc:
        raise ValueError("cannot open %s: %s" % (path, exc)) from exc
    if crop_frac is not None:
        rx0, ry0, rx1, ry1 = crop_frac
        iw, ih = im.size
        crop = (int(round(rx0 * iw)), int(round(ry0 * ih)),
                max(1, int(round((rx1 - rx0) * iw))),
                max(1, int(round((ry1 - ry0) * ih))))
    if crop is not None:
        x, y, w, h = crop
        iw, ih = im.size
        x0, y0 = min(x, iw - 1), min(y, ih - 1)
        x1, y1 = min(x0 + w, iw), min(y0 + h, ih)
        if x1 <= x0 or y1 <= y0:
            raise ValueError("crop %s is outside %s (%dx%d)" % (crop, path, iw, ih))
        im = im.crop((x0, y0, x1, y1))
    if im.width < 8 or im.height < 8:
        raise ValueError("image too small for metrics after crop: %s (%dx%d)"
                         % (path, im.width, im.height))
    return im


# ---------------------------------------------------------------------------
# Core numeric helpers
# ---------------------------------------------------------------------------

def pearson(a, b) -> float:
    """Pearson correlation of two equal-length 1-D arrays; 0 if degenerate."""
    if a.size < 2 or a.shape != b.shape:
        return 0.0
    af = a.astype(np.float64, copy=False) - a.mean()
    bf = b.astype(np.float64, copy=False) - b.mean()
    aa, bb, ab = float(np.sum(af * af)), float(np.sum(bf * bf)), float(np.sum(af * bf))
    den = math.sqrt(aa * bb)
    return ab / den if den > 1e-12 else 0.0


def autocorr_at(luma, dx: int, dy: int) -> float:
    """Normalised autocorrelation at lag (dx,dy) using the overlapping region."""
    h, w = luma.shape
    if abs(dx) >= w or abs(dy) >= h:
        return 0.0
    if dx == 0 and dy == 0:
        return 1.0
    oh, ow = h - abs(dy), w - abs(dx)
    ay, ax = max(0, -dy), max(0, -dx)
    by, bx = max(0, dy), max(0, dx)
    return pearson(luma[ay:ay + oh, ax:ax + ow],
                   luma[by:by + oh, bx:bx + ow])


def block_variance(luma, blocks: tuple[int, ...]) -> list[dict]:
    """Between-block vs within-block luma variance at several pixel scales.

    between_block_var: variance of the block MEANS (large-scale mottling).
    within_block_var:  mean of each block's own variance (fine grain/detail).
    Flat fields have near-zero between-block variance; tiled fields have a
    spike at the tile period. Both are reported, never a single score.
    """
    out = []
    h, w = luma.shape
    for b in blocks:
        hh, ww = (h // b) * b, (w // b) * b
        if hh < b or ww < b:
            continue
        cells = (luma[:hh, :ww]
                 .reshape(hh // b, b, ww // b, b)
                 .transpose(0, 2, 1, 3)
                 .reshape(-1, b * b))
        means = cells.mean(axis=1)
        within = float(cells.var(axis=1).mean())
        between = float(means.var())
        total = between + within
        out.append({
            "block_px": b,
            "block_count": int(means.size),
            "between_block_var": between,
            "within_block_var": within,
            "between_share": between / total if total > 1e-12 else 0.0,
        })
    return out


def color_stats(rgb) -> dict:
    """Mean/std of RGB, Rec.709 luma and HSV-style saturation (0..1)."""
    mean_rgb = [float(v) for v in rgb.mean(axis=(0, 1))]
    std_rgb = [float(v) for v in rgb.std(axis=(0, 1))]
    mx = rgb.max(axis=2)
    mn = rgb.min(axis=2)
    sat = np.where(mx > 1e-6, (mx - mn) / np.maximum(mx, 1e-6), 0.0)
    luma = (rgb[..., 0] * LUMA_WEIGHTS[0]
            + rgb[..., 1] * LUMA_WEIGHTS[1]
            + rgb[..., 2] * LUMA_WEIGHTS[2])
    return {
        "mean_rgb": mean_rgb,
        "std_rgb": std_rgb,
        "mean_luma": float(luma.mean()),
        "std_luma": float(luma.std()),
        "p05_luma": float(np.percentile(luma, 5)),
        "p95_luma": float(np.percentile(luma, 95)),
        "mean_saturation": float(sat.mean()),
        "std_saturation": float(sat.std()),
    }


def directional_gradient(luma) -> dict:
    """Directional gradient energy and structure-tensor orientation.

    gx/gy are central differences in image coordinates (x right, y down).
    diag_plus  = mean((gx+gy)^2)/2 : gradient along (1,1), i.e. streaks
                    oriented along (1,-1).
    diag_minus = mean((gx-gy)^2)/2 : gradient along (1,-1), i.e. streaks
                    oriented along (1,1).
    Their shares always sum to 1 (within float error); 0.5/0.5 = isotropic.
    coherence is 0 for an isotropic gradient field and ->1 for a single
    dominant orientation. gradient_angle_deg is the DOMINANT GRADIENT
    normal; streak_angle_deg is perpendicular to it.
    """
    gy, gx = np.gradient(luma)
    jxx = float(np.mean(gx * gx))
    jyy = float(np.mean(gy * gy))
    jxy = float(np.mean(gx * gy))
    axis = jxx + jyy
    d_plus = float(np.mean((gx + gy) ** 2)) * 0.5
    d_minus = float(np.mean((gx - gy) ** 2)) * 0.5
    den = axis if axis > 1e-12 else 1e-12
    coherence = math.sqrt((jxx - jyy) ** 2 + 4.0 * jxy * jxy) / den
    grad_angle = math.degrees(0.5 * math.atan2(2.0 * jxy, jxx - jyy))
    result = {
        "axis_gradient_energy": axis,
        "diag_plus_energy": d_plus,
        "diag_minus_energy": d_minus,
        "diag_plus_share": d_plus / den,
        "diag_minus_share": d_minus / den,
        "diag_excess": max(d_plus, d_minus) / den - 0.5,
        "coherence": coherence,
        "gradient_angle_deg": grad_angle,
        "streak_angle_deg": (grad_angle + 90.0) % 180.0,
    }
    result.update(spectral_banding(luma))
    return result


def _box_blur(a, radius: int):
    """Reflect-padded box mean, used to strip slow relief before the FFT."""
    padded = np.pad(a, radius, mode="reflect")
    acc = np.zeros((a.shape[0], a.shape[1]), dtype=np.float64)
    for dy in range(-radius, radius + 1):
        for dx in range(-radius, radius + 1):
            acc += padded[radius + dy:radius + dy + a.shape[0],
                          radius + dx:radius + dx + a.shape[1]]
    return acc / (2 * radius + 1) ** 2


def spectral_banding(luma) -> dict:
    """Directional spectrum of the detrended luma (banding/moiré view).

    The gradient shares above see pixel-scale slopes; a 9x9 box residual plus
    a Hann-windowed FFT exposes repeated bands at mid spatial frequencies.
    Power is averaged into twelve 15-degree bins (0..180, image axes) over an
    annulus of 10..min(h,w)/4 cycles. Reported values:

      band_anisotropy    (max-min)/(max+min), 0 = isotropic, 1 = one direction;
      band_peak_deg      direction of strongest residual power;
      band_peak_to_mean  peak / mean of the 12 bins;
      band_peak_to_second peak / second-largest bin (peak sharpness);
      band_diagonal_share power in the 30-60 and 120-150 degree bins / total.

    IMPORTANT: donor screenshots have their own directional content (cliffs,
    unit rows), so these are DESCRIPTIVE values, not a pass/fail signal. Use
    them with the block-variance and profile metrics, never alone.
    """
    h, w = luma.shape
    if h < 64 or w < 64:
        return {"band_anisotropy": 0.0, "band_peak_deg": None,
                "band_peak_to_mean": 0.0, "band_peak_to_second": 0.0,
                "band_diagonal_share": 0.0}
    radius = 12
    resid = luma - _box_blur(luma, radius)
    window = (np.hanning(h)[:, None] * np.hanning(w)[None, :]).astype(np.float32)
    power = np.fft.fftshift(np.abs(np.fft.fft2(resid * window)) ** 2)
    yy, xx = np.mgrid[:h, :w]
    ry = yy - h // 2
    rx = xx - w // 2
    radial = np.hypot(ry, rx)
    angle = np.degrees(np.arctan2(ry, rx)) % 180.0
    band = (radial > 10) & (radial < max(24.0, min(h, w) / 4.0))
    bins = np.array([float(np.mean(power[band & (angle >= a) & (angle < a + 15)]))
                     for a in range(0, 180, 15)])
    total = float(bins.sum())
    if total <= 1e-12:
        return {"band_anisotropy": 0.0, "band_peak_deg": None,
                "band_peak_to_mean": 0.0, "band_peak_to_second": 0.0,
                "band_diagonal_share": 0.0}
    peak, low = float(bins.max()), float(bins.min())
    second = float(np.sort(bins)[-2])
    return {
        "band_anisotropy": (peak - low) / (peak + low) if peak + low > 1e-12 else 0.0,
        "band_peak_deg": 15 * int(bins.argmax()),
        "band_peak_to_mean": peak / (total / 12.0),
        "band_peak_to_second": peak / (second + 1e-12),
        "band_diagonal_share": float((bins[2] + bins[3] + bins[8] + bins[9]) / total),
    }


def _spike_score(profile) -> tuple[float, float, float]:
    """(max/p99 second-difference ratio, squashed 0..1 score, max second diff).

    A one-row seam (black row, wrap discontinuity) produces an isolated spike
    in the second difference. Real features such as cliffs are spread over
    many rows and have a low max/p99 ratio. Squash: 1.2 = clean, >=5 = hard
    seam. The old max/median-of-first-difference score saturated on any textured
    image and was replaced.
    """
    pf = profile.astype(np.float64, copy=False)
    if pf.size < 8:
        return 0.0, 0.0, 0.0
    d2 = np.abs(pf[2:] - 2.0 * pf[1:-1] + pf[:-2])
    p99 = float(np.percentile(d2, 99))
    ratio = float(d2.max()) / (p99 + 1e-9)
    score = 1.0 - 1.0 / (1.0 + max(0.0, ratio - 1.2) * 3.0)
    return ratio, score, float(d2.max())


def _periodicity(profile) -> tuple[float, int | None]:
    """Periodicity PEAK of a detrended profile, relative to nearby lags.

    A smooth signal correlates at r~0.7 at lag 2 purely because it is smooth;
    that is not a repeating pattern. The score is the excess of the best lag
    over the mean correlation at neighbouring lags, squashed to 0..1. Only
    this excess is reported; the raw best-lag r is kept as supporting detail.
    """
    n = profile.size
    if n < 32:
        return 0.0, None
    x = np.arange(n, dtype=np.float64)
    pf = profile.astype(np.float64, copy=False)
    # Remove a quadratic trend so hills/relief do not look periodic.
    coeffs = np.polyfit(x, pf, 2)
    det = pf - np.polyval(coeffs, x)
    max_lag = min(n // 4, 256)
    rs = [pearson(det[:-lag], det[lag:]) for lag in range(2, max_lag + 1)]
    if len(rs) < 6:
        return 0.0, None
    best = max(rs)
    i = rs.index(best)
    lo, hi = max(0, i - 4), min(len(rs), i + 5)
    local = rs[lo:hi]
    baseline = sum(local) / len(local)
    excess = max(0.0, best - baseline)
    score = 1.0 - 1.0 / (1.0 + excess * 6.0)
    return score, i + 2


def seam_repetition(luma) -> dict:
    """Row/column seams, profile periodicity and shifted-patch repetition.

    Every component is an "artificiality" indicator: HIGHER = MORE suspect.
    tile_repeat_score compares a patch with copies shifted by a spread of
    periods: 1 means one shift is a near-exact copy while typical shifts are
    not; ~0 means no shift is more similar than any other.
    `seam_repetition_score` is the max of the components, kept alongside them
    so a flag can always be traced to a concrete cause.
    """
    row_z, row_score, row_max = _spike_score(luma.mean(axis=1))
    col_z, col_score, col_max = _spike_score(luma.mean(axis=0))
    row_per, row_lag = _periodicity(luma.mean(axis=1))
    col_per, col_lag = _periodicity(luma.mean(axis=0))

    h, w = luma.shape
    patch = 48
    periods = (7, 11, 16, 23, 32, 45, 64, 91, 128, 181)
    usable = [p for p in periods if p + patch <= min(h, w)]
    tile_score, tile_period, tile_axis = 0.0, None, None
    best_mad, median_mad = None, None
    if usable:
        anchors = [
            ((h - patch) // 2, (w - patch) // 2),
            (max(0, h // 4 - patch // 2), max(0, w // 4 - patch // 2)),
            (max(0, 3 * h // 4 - patch // 2), max(0, 3 * w // 4 - patch // 2)),
        ]
        mads = []
        for ay, ax in anchors:
            a = luma[ay:ay + patch, ax:ax + patch]
            for p in usable:
                bx, by = ax + p, ay + p
                if bx + patch <= w:
                    mads.append((float(np.mean(np.abs(a - luma[ay:ay + patch,
                                                               bx:bx + patch]))), p, "x"))
                if by + patch <= h:
                    mads.append((float(np.mean(np.abs(a - luma[by:by + patch,
                                                               ax:ax + patch]))), p, "y"))
        if len(mads) >= 4:
            median_mad = float(np.median([m[0] for m in mads]))
            best_mad, tile_period, tile_axis = min(mads)
            # A short shift (7 or 11 px) always has lower MAD than a long one
            # on any continuous image, so comparing raw MADs across periods
            # manufactures a false "repeat". Compare each period only with
            # similarly sized periods instead.
            peers = [m[0] for m in mads
                     if abs(m[1] - tile_period) <= 48 and m[1] != tile_period]
            peer_baseline = float(np.median(peers)) if peers else median_mad
            tile_score = max(0.0, min(1.0,
                                      1.0 - best_mad / (peer_baseline + 1e-6)))

    components = {
        "row_seam": row_score,
        "col_seam": col_score,
        "row_periodicity": row_per,
        "col_periodicity": col_per,
        "tile_repeat": tile_score,
    }
    return {
        "row_seam_ratio": row_z,
        "row_seam_max_second_diff": row_max,
        "col_seam_ratio": col_z,
        "col_seam_max_second_diff": col_max,
        "row_period_lag_px": row_lag,
        "col_period_lag_px": col_lag,
        "tile_best_mad": best_mad,
        "tile_baseline_mad": median_mad,
        "tile_period_px": tile_period,
        "tile_axis": tile_axis,
        **components,
        "seam_repetition_score": max(components.values()),
        "seam_repetition_driver": max(components, key=components.get),
    }


def image_metrics(im: Image.Image, blocks: tuple[int, ...],
                  lags: tuple[tuple[int, int], ...]) -> dict:
    """Compute every metric group for one RGB image."""
    rgb = np.asarray(im, dtype=np.float32)
    luma = (rgb[..., 0] * LUMA_WEIGHTS[0]
            + rgb[..., 1] * LUMA_WEIGHTS[1]
            + rgb[..., 2] * LUMA_WEIGHTS[2])
    ac = {}
    for dx, dy in lags:
        ac["%d,%d" % (dx, dy)] = autocorr_at(luma, dx, dy)
    axis_lags = [v for k, v in ac.items() if k in ("1,0", "0,1", "4,0", "0,4",
                                                   "16,0", "0,16", "64,0", "0,64")]
    diag_lags = [v for k, v in ac.items() if k in ("1,1", "1,-1", "2,2", "2,-2",
                                                   "8,8", "8,-8", "32,32", "32,-32")]
    return {
        "color": color_stats(rgb),
        "block_variance": block_variance(luma, blocks),
        "autocorrelation": ac,
        "autocorr_summary": {
            "axis_mean": sum(axis_lags) / len(axis_lags) if axis_lags else 0.0,
            "diag_mean": sum(diag_lags) / len(diag_lags) if diag_lags else 0.0,
            "diag_minus_axis": ((sum(diag_lags) / len(diag_lags)) - (sum(axis_lags) / len(axis_lags)))
                               if axis_lags and diag_lags else 0.0,
        },
        "directional_gradient": directional_gradient(luma),
        "seam_repetition": seam_repetition(luma),
    }


# ---------------------------------------------------------------------------
# Comparison / interpretation
# ---------------------------------------------------------------------------

def flatten(obj, prefix: str = "") -> dict[str, float]:
    """Flatten nested numeric metrics into dotted keys for comparison."""
    out: dict[str, float] = {}
    if isinstance(obj, dict):
        for key, value in obj.items():
            k = "%s.%s" % (prefix, key) if prefix else str(key)
            out.update(flatten(value, k))
    elif isinstance(obj, (list, tuple)):
        for i, value in enumerate(obj):
            out.update(flatten(value, "%s.%d" % (prefix, i)))
    elif isinstance(obj, (int, float)) and not isinstance(obj, bool):
        out[prefix] = float(obj)
    return out


def round_floats(obj, digits: int = 6):
    if isinstance(obj, dict):
        return {k: round_floats(v, digits) for k, v in obj.items()}
    if isinstance(obj, list):
        return [round_floats(v, digits) for v in obj]
    if isinstance(obj, float):
        return round(obj, digits)
    return obj


def delta_table(cand: dict, ref: dict) -> dict:
    """Per-metric candidate vs reference diff/ratio (flat dotted keys)."""
    cf, rf = flatten(cand), flatten(ref)
    out = {}
    for key in sorted(cf.keys() & rf.keys()):
        c, r = cf[key], rf[key]
        out[key] = {
            "candidate": c,
            "reference": r,
            "diff": c - r,
            "ratio": c / r if abs(r) > 1e-9 else None,
        }
    return out


def flags_for(cand: dict, ref_summary: dict, distribution: bool) -> list[str]:
    """Heuristic readings. These are prompts for a human, NOT pass/fail gates."""
    cf, rf = flatten(cand), ref_summary
    flags = []

    def cmp(key: str, mul: float, label: str) -> None:
        if key not in cf or key not in rf:
            return
        c, r = cf[key], rf[key]
        if mul > 0 and c < r / 2.0:
            flags.append("%s: candidate %.4g is < half the reference %.4g" % (label, c, r))
        elif mul < 0 and c > r * 2.0:
            flags.append("%s: candidate %.4g is > 2x the reference %.4g" % (label, c, r))

    big = max((k for k in cf if k.startswith("block_variance.") and
               k.endswith(".between_block_var")),
              key=lambda k: int(k.split(".")[1]), default="")
    if big and big in rf and rf[big] > 1e-6 and cf[big] < 0.35 * rf[big]:
        flags.append("flat_large_scale: large-block luma variance far below reference")
    small = "block_variance.0.between_block_var"
    cmp(small, 1, "low_fine_variation")
    cmp("color.mean_saturation", 1, "low_saturation")
    cmp("directional_gradient.diag_excess", -1, "diagonal_gradient_bias")
    cmp("directional_gradient.coherence", -1, "gradient_anisotropy")
    cmp("directional_gradient.band_diagonal_share", -1, "diagonal_fft_power_bias")
    cmp("directional_gradient.band_peak_to_mean", -1, "narrow_spectral_peak")
    for key in ("seam_repetition.tile_repeat", "seam_repetition.row_periodicity",
                "seam_repetition.col_periodicity", "seam_repetition.seam_repetition_score"):
        if key in cf and key in rf and cf[key] > max(0.55, rf[key] + 0.12):
            flags.append("%s: candidate %.3f exceeds reference %.3f" % (key, cf[key], rf[key]))

    if distribution:
        flags.append("compare_ref: donor stills include UI/units/rock/water; "
                     "treat all deltas as scene-context SMOKE only")
    if not flags:
        flags.append("no heuristic flag fired (does NOT prove donor parity)")
    return flags


def reference_summary(metrics_list: list[dict]) -> dict:
    """Median and extremes of every flat metric across several references."""
    rows = [flatten(m) for m in metrics_list]
    keys = set(rows[0]) if rows else set()
    for row in rows[1:]:
        keys &= set(row)
    out = {}
    for key in sorted(keys):
        vals = [row[key] for row in rows]
        sv = sorted(vals)
        n = len(sv)
        median = sv[n // 2] if n % 2 else 0.5 * (sv[n // 2 - 1] + sv[n // 2])
        mean = sum(vals) / n
        std = math.sqrt(sum((v - mean) ** 2 for v in vals) / n)
        out[key] = {"mean": mean, "median": median, "min": sv[0],
                    "max": sv[-1], "std": std}
    return out


def distribution_table(cand: dict, summary: dict) -> dict:
    """Candidate value + z-score/range check against the donor distribution."""
    cf = flatten(cand)
    out = {}
    for key, stat in summary.items():
        if key not in cf:
            continue
        c = cf[key]
        out[key] = {
            "candidate": c,
            "donor_median": stat["median"],
            "donor_min": stat["min"],
            "donor_max": stat["max"],
            "z": (c - stat["mean"]) / stat["std"] if stat["std"] > 1e-9 else 0.0,
            "outside_donor_range": c < stat["min"] or c > stat["max"],
        }
    return out


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

def _fmt(v) -> str:
    if v is None:
        return "n/a"
    if isinstance(v, float):
        return "%.4f" % v
    return str(v)


def human_output(result: dict) -> None:
    mode = result["mode"]
    cand = result["candidate"]
    cm = cand["metrics"]
    rm = result["reference"]["metrics"] if mode == "single" else None
    flat_c = flatten(cm)
    flat_r = flatten(rm) if rm is not None else None
    dist = result.get("distribution", {})

    print("terrain_ab_metric %s  [%s]" % (SCHEMA, SMOKE_LABEL))
    print("candidate : %s  (%dx%d)" % (cand["path"], cand["width"], cand["height"]))
    if mode == "single":
        print("reference : %s  (%dx%d)" % (result["reference"]["path"],
                                           result["reference"]["width"],
                                           result["reference"]["height"]))
    elif mode == "compare-ref":
        print("reference : %s  (%d donor images)" % (result["reference_folder"],
                                                     result["reference_file_count"]))
    else:
        print("reference : NONE (descriptive single-image smoke metrics; "
              "no baseline comparison)")

    def row(label: str, key: str, c=None, r=None) -> None:
        """One candidate/reference line; key addresses a flat metric."""
        if c is None:
            c = flat_c.get(key)
        if r is None:
            r = flat_r.get(key) if flat_r is not None else dist.get(key, {}).get("donor_median")
        print("  %-34s cand=%-12s ref=%-12s" % (label, _fmt(c), _fmt(r)))

    print("\nCOLOR (0..255 RGB/luma, 0..1 saturation)")
    for ch, i in (("R", 0), ("G", 1), ("B", 2)):
        row("mean_%s" % ch, "color.mean_rgb.%d" % i)
    for key in ("mean_luma", "std_luma", "p05_luma", "p95_luma",
                "mean_saturation", "std_saturation"):
        row(key, "color." + key)

    print("\nBLOCK VARIANCE of luma (higher between-share = more large-scale mottling)")
    for i, b in enumerate(cm["block_variance"]):
        row("block %3dpx between_var" % b["block_px"],
            "block_variance.%d.between_block_var" % i)
        row("block %3dpx between_share" % b["block_px"],
            "block_variance.%d.between_share" % i)

    print("\nAUTOCORRELATION (luma Pearson r at pixel lag dx,dy)")
    for k in cm["autocorrelation"]:
        row("lag (%-7s)" % k, "autocorrelation." + k)

    print("\nDIRECTIONAL GRADIENT (diag_excess > 0 means diagonal bias)")
    for key in ("axis_gradient_energy", "diag_plus_energy", "diag_minus_energy",
                "diag_plus_share", "diag_minus_share", "diag_excess",
                "coherence", "band_anisotropy", "band_peak_deg", "band_peak_to_mean",
                "band_peak_to_second", "band_diagonal_share",
                "gradient_angle_deg", "streak_angle_deg"):
        row(key, "directional_gradient." + key)

    print("\nSEAM / REPETITION (higher = more artificial)")
    for key in ("row_seam", "col_seam", "row_periodicity", "col_periodicity",
                "tile_repeat", "seam_repetition_score"):
        row(key, "seam_repetition." + key)
    cs = cm["seam_repetition"]
    print("  driver: %s  tile_period=%s axis=%s" %
          (cs["seam_repetition_driver"], _fmt(cs["tile_period_px"]), cs["tile_axis"]))

    print("\nFLAGS (heuristic prompts, not verdicts)")
    for flag in result["flags"]:
        print("  - %s" % flag)
    if not result["warnings"]:
        return
    print("\nWARNINGS")
    for warning in result["warnings"]:
        print("  ! %s" % warning)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("candidate", help="candidate PNG (the render under test)")
    ap.add_argument("reference", nargs="?", default=None,
                    help="reference PNG or baseline PNG")
    ap.add_argument("--compare-ref", metavar="FOLDER", default=None,
                    help="folder of donor stills to use as the reference "
                         "distribution (canonical: %s)" % DEFAULT_REF_FOLDER)
    ap.add_argument("--json", action="store_true", help="emit one JSON object on stdout")
    ap.add_argument("--crop", type=parse_crop, metavar="x,y,w,h",
                    help="pixel crop applied to EVERY input image before measuring")
    ap.add_argument("--crop-frac", type=parse_crop_frac, metavar="x0,y0,x1,y1",
                    help="fractional crop (0..1) resolved per image, e.g. "
                         "A11 ground ROI .35,.55,.48,.70; exclusive with --crop")
    ap.add_argument("--blocks", type=parse_blocks, default=DEFAULT_BLOCKS,
                    metavar="2,4,8,...", help="block sizes in pixels (default: %s)" % DEFAULT_BLOCKS)
    ap.add_argument("--lags", type=parse_lags, default=DEFAULT_LAGS, metavar="dx,dy;...",
                    help="semicolon-separated pixel lags")
    ap.add_argument("--per-file", action="store_true",
                    help="in --compare-ref mode, include each donor file's metrics")
    args = ap.parse_args(argv)

    if args.reference is not None and args.compare_ref is not None:
        ap.error("give REFERENCE or --compare-ref FOLDER, not both")
    if args.crop is not None and args.crop_frac is not None:
        ap.error("--crop and --crop-frac are mutually exclusive")
    if not require_numpy():
        return 2

    cand_path = Path(args.candidate)
    warnings: list[str] = []
    try:
        cand_im = load_rgb(cand_path, args.crop, args.crop_frac)
    except ValueError as exc:
        print("ERROR: %s" % exc, file=sys.stderr)
        return 2
    cand_metrics = image_metrics(cand_im, args.blocks, args.lags)
    candidate = {
        "path": str(cand_path), "width": cand_im.width, "height": cand_im.height,
        "crop": list(args.crop) if args.crop else None,
        "crop_frac": list(args.crop_frac) if args.crop_frac else None,
        "metrics": cand_metrics,
    }

    result = {
        "schema": SCHEMA, "label": SMOKE_LABEL,
        "numpy_version": np.__version__, "pillow_version": Image.__version__,
        "crop": list(args.crop) if args.crop else None,
        "crop_frac": list(args.crop_frac) if args.crop_frac else None,
        "blocks": list(args.blocks),
        "lags": [list(lag) for lag in args.lags],
        "candidate": candidate, "warnings": warnings,
    }

    if args.reference is None and args.compare_ref is None:
        # C02's gate plan calls the tool with ONE path; descriptive only.
        result["mode"] = "candidate-only"
        result["reference"] = None
        result["flags"] = ["candidate_only: descriptive statistics only; "
                           "no baseline/reference comparison performed"]
    elif args.compare_ref is None:
        ref_path = Path(args.reference)
        try:
            ref_im = load_rgb(ref_path, args.crop, args.crop_frac)
        except ValueError as exc:
            print("ERROR: %s" % exc, file=sys.stderr)
            return 2
        ref_metrics = image_metrics(ref_im, args.blocks, args.lags)
        result["mode"] = "single"
        result["reference"] = {
            "path": str(ref_path), "width": ref_im.width, "height": ref_im.height,
            "metrics": ref_metrics,
        }
        result["delta"] = delta_table(cand_metrics, ref_metrics)
        result["flags"] = flags_for(cand_metrics, flatten(ref_metrics), False)
    else:
        folder = Path(args.compare_ref)
        if not folder.is_dir():
            print("ERROR: --compare-ref folder not found: %s" % folder, file=sys.stderr)
            return 2
        paths = sorted(p for p in folder.iterdir()
                       if p.is_file() and p.suffix.lower() in IMAGE_EXTS)
        if not paths:
            print("ERROR: no images found in %s" % folder, file=sys.stderr)
            return 2
        metrics_list, files = [], []
        for path in paths:
            try:
                im = load_rgb(path, args.crop, args.crop_frac)
            except ValueError as exc:
                warnings.append(str(exc))
                continue
            m = image_metrics(im, args.blocks, args.lags)
            metrics_list.append(m)
            entry = {"path": str(path), "width": im.width, "height": im.height,
                     "metrics": m}
            files.append(entry)
        if not metrics_list:
            print("ERROR: no readable images in %s" % folder, file=sys.stderr)
            return 2
        summary = reference_summary(metrics_list)
        result["mode"] = "compare-ref"
        result["reference_folder"] = str(folder)
        result["reference_file_count"] = len(metrics_list)
        result["reference_distribution"] = summary
        result["distribution"] = distribution_table(cand_metrics, summary)
        result["flags"] = flags_for(
            cand_metrics,
            {k: v["median"] for k, v in summary.items()}, True)
        if args.per_file:
            result["reference_files"] = files
        else:
            result["reference_files"] = [{"path": f["path"],
                                          "width": f["width"], "height": f["height"]}
                                         for f in files]

    result = round_floats(result)
    if args.json:
        print(json.dumps(result, sort_keys=True, indent=2 if args.per_file else None))
    else:
        human_output(result)
    return 0


if __name__ == "__main__":
    sys.exit(main())
