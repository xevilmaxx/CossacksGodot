#!/usr/bin/env python3
"""T6-T01 grass_mottled mini-baker — headless, deterministic Pillow + NumPy.

Owns exactly: this file, the t6_grass_mottled*.png outputs in app/shots/pieces,
docs/audit/PIECES/grass_mottled.md (appended verdict) and docs/t6/reports/T6-T01.md.
Shared ``terrain_piece_render.py`` is IMPORTED READ-ONLY, never edited. No Godot.

WHY A NEW MINI-BAKER (observed defect in the shared renderer)
-------------------------------------------------------------
``terrain_piece_render._render_patches`` builds its signed grid with
``_smooth_field``, which writes signed floats into an ``L`` (0..255) image:
``_clamp255(float(value) * 255)``. Every negative grid value is clamped to 0,
so a uniform[-1,1] grid has field mean ~62.6 instead of 128. With gain 80 this
biases the gain by -38.6 L (SEED 7, 26x26 grid -> measured channel shifts
[-41.0, -39.4, -27.9], i.e. exactly the olive weights). The baseline
grass_mottled.png therefore reaches its L std by a mostly-negative gain with a
bright tail, not by a symmetric terrain-driven +/-L driver. This module keeps
the gain as a NumPy float array end-to-end: negatives survive.

DONOR ANCHORS (all measured in temp by t6t01_donor_truth.py / _props.py)
-----------------------------------------------------------------------
OBSERVED  primary #8 cossacks-3-v1-498085.jpg src box (560,325,735,500):
          mean #606428, L 91.75, std 8.70, hi-freq(5px) 3.42, 2 bins >=3%.
OBSERVED  palette boxes in #8: lit #686935 ~(395,40,465,85), mid #616727 exact,
          mid-alt #64642F exact; canonical doc anchors #6B6732/#616727/#3E411F.
OBSERVED  mottled target #6 articolo-787.jpg box (250,220,450,420): mean
          #4D4B2A, L 71.66, std 37.55, hi-freq 11.18, bins
          [5.0,39.3,44.7,4.8,1.9,1.2,1.2,1.8] -> 4 bins >=3% (all bins 0-3).
          Visual caveat: that crop contains explosions/rock/trees; the bright
          bins 4-7 are fire, not grass. Grass-only subregion (0,0,150,200):
          L 71.77, std 33.98, hi-freq 9.31, bins [4.2,36.4,49.4,4.7,2.0,...],
          p10/p50/p90 = 39/70/95. This is the grass-only target used here.
OBSERVED  donor grass1/6/10.dds are 1024^2 DXT1; decoded RGB is byte-identical
          (mean abs diff 0.0) to app/assets/terrain/blocks/{grass1,6,10}.png,
          so no donor binary is needed or copied at render time.
DERIVED   high-pass FFT autocorrelogram grid_peak = max over lags 8..40 px of
          0.5*(|ACF_h(0,lag)|+|ACF_h(lag,0)|), ACF of (L - GaussianBlur(6))
          normalised by ACF(0,0), on the 200x200 measurement crop: donor
          c6 0.048, c8 clean 0.025, c8 gully 0.066; old baseline 0.203;
          synthetic 24px checker positive control 0.93. Gate <0.20.
INFERRED  gain field = smooth multi-octave value noise at 20-80 px (512 canvas)
          with a signed power-law transfer and an olive RGB gain weight; the
          exact donor low-frequency driver is not recoverable from a PNG.

METHOD: three named donor block layers (grass1 base, grass6/grass10 through
terrain-driven coverage masks, opacities <=0.35/<=0.2) plus one signed gain
driver; render at 1024^2, single Lanczos downsample to 512^2, small unsharp
lift to restore donor-scale grain. Fixed SEED=7, no clock input.

Usage:
    python app/tools/pieces/t6_grass_mottled.py
    python app/tools/pieces/t6_grass_mottled.py --out-dir app/shots/pieces
    python app/tools/pieces/t6_grass_mottled.py --measure   # metrics to stdout
    python app/tools/pieces/t6_grass_mottled.py --params '{"gain_amp":44}'
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent.parent
ROOT = APP.parent
BLOCKS = APP / "assets" / "terrain" / "blocks"
OUT = APP / "shots" / "pieces"
REF = Path.home() / "Downloads" / "c3"

# Shared renderer READ-ONLY imports (allowed by T6-WAVE_PLAN LANE TERRAIN).
sys.path.insert(0, str(TOOLS.parent))
import terrain_piece_render as tpr  # noqa: E402  (read-only)

SEED = 7
SIZE = 512
NATIVE = SIZE * 2

# ----------------------------------------------------------- tuned defaults --
# OBSERVED / DERIVED anchors live in the docstring; these are INFERRED render
# parameters, calibrated against the donor crops by t6t01_search.py (temp).
DEFAULT: dict[str, Any] = {
    "seed": SEED,
    # Final calibrated variant (t6t01_search6.py in temp). The "smalltail"
    # vector is the measured grass-only donor histogram with the fire bin
    # censored: bins 0-4 follow the donor grass crop, bins 5-6 hold a thin
    # sunlit-tip tail (1%+1%), bin 7 is empty (no explosion/white-hot pixels).
    "mode": "cdf",         # rank-map a smooth terrain driver to a target CDF
    "cdf_kind": "ramp",    # continuous within each bin (no posterised camo)
    "donor_hist": [6, 36, 41, 12, 3, 1, 1, 0],
    "cdf_tighten": 0.82,   # keeps hist L1 <=25 while the stronger fine grain is applied
    # T6 parent visual feedback (2026-11-23): a single BICUBIC grid read as
    # blurry camo blobs. Octaves at cell/2 and cell/4 roughen patch edges;
    # the additive fine grain is raised to donor hi-freq (~11 L) so the
    # grass texture competes with the tonal patches instead of sitting under
    # smooth soft-edged blobs. Stage-10 probe (temp) selected these values.
    "cell_px": 56.0,       # 512-canvas patch cell, inside donor 20-80 px band
    "octave2_weight": 0.20,
    "octave3_weight": 0.08,
    "shape_power": 0.62,   # noise-mode-only
    "fine_px": 6.0,        # 512-canvas fine-grain cell (donor blade scale 2-5 px)
    "fine_amp": 6.0,       # signed fine-grain L amplitude (added to gain)
    "gain_bias": -37.0,    # noise-mode-only: L shift of the 3-block base (~109.5)
    "gain_amp": 44.0,      # noise-mode-only: gain excursion
    "olive_weights": [1.00, 0.96, 0.68],
    "grain_lift": 1.0,     # UnsharpMask percent*100
    "grain_radius": 12.0,  # applied at native 1024 so it survives 512->200
    "grain_stage": "native",
    "brightness": 1.4,
    "contrast": 0.8,
    "op_base": 1.0,
    "op_dark": 0.35,       # grass6 ceiling (grass_mottled.md section 3)
    "op_warm": 0.20,       # grass10 ceiling
    "mask_modulation": 0.25,  # coverage varies 0.75..1.0 of each ceiling
}


# --------------------------------------------------------------- primitives --
def value_noise(seed: int, size: int, cell: float) -> np.ndarray:
    """Deterministic signed value noise in [-1,1], BICUBIC upsampled.

    Uses a float array -> uint8 L mapping that PRESERVES negatives (unlike the
    shared renderer's clamp-to-zero bug documented above).
    """
    rng = np.random.default_rng(seed)
    cols = max(2, int(np.ceil(size / cell)) + 2)
    grid = rng.uniform(-1.0, 1.0, size=(cols, cols))
    small = Image.fromarray(np.clip((grid + 1.0) * 127.5, 0, 255).astype(np.uint8), "L")
    field = np.asarray(small.resize((size, size), Image.Resampling.BICUBIC), np.float64)
    return (field - 127.5) / 127.5


def smooth_driver(p: dict[str, Any], size: int) -> np.ndarray:
    """The terrain-driven field shared by both gain modes.

    T6 parent visual feedback (2026-11-23): a single BICUBIC-upsampled grid
    makes rounded "camo blobs". Extra octaves at cell/2 and cell/4 give the
    tonal patches ragged edges and internal structure, so the donor grass
    grain reads through instead of a smooth soft-edged proxy.
    """
    cell = float(p["cell_px"]) * (size / SIZE)
    n1 = value_noise(int(p["seed"]) + 11, size, cell)
    n2 = value_noise(int(p["seed"]) + 23, size, cell * 0.5)
    n = 0.70 * n1 + float(p["octave2_weight"]) * n2
    w3 = float(p.get("octave3_weight", 0.0))
    if w3 > 0:
        n3 = value_noise(int(p["seed"]) + 37, size, cell * 0.25)
        n = n + w3 * n3
    return n


def build_gain(p: dict[str, Any], size: int, base_luma: np.ndarray) -> np.ndarray:
    """Terrain-driven signed L gain (float, never clamped before application).

    cdf mode (default): rank-map the smooth driver onto the OBSERVED donor
    grass-only 8-bin luminance histogram. This reproduces the donor's tonal
    patch mix (light/mid/dark olive) while preserving the smooth patch shapes.
    noise mode: the legacy explicit bias/amplitude + signed power-law driver.
    """
    n = smooth_driver(p, size)
    fine_amp = float(p.get("fine_amp", 0.0))
    if fine_amp > 0:
        fine = value_noise(int(p["seed"]) + 91, size,
                           float(p["fine_px"]) * size / SIZE)
        fine = (fine - fine.mean()) / max(1e-6, float(fine.std())) * fine_amp
    else:
        fine = 0.0
    if str(p["mode"]).lower() == "cdf":
        # Rank -> uniform, then inverse-CDF of the measured donor bin vector.
        flat = np.argsort(n, axis=None)
        u = np.empty(n.shape, np.float64)
        u.flat[flat] = (np.arange(n.size, dtype=np.float64) + 0.5) / n.size
        hist = np.asarray(p["donor_hist"], np.float64)
        hist = hist / hist.sum()
        cdf = np.concatenate(([0.0], np.cumsum(hist)))
        if str(p.get("cdf_kind", "ramp")).lower() == "ramp":
            # Continuous ramp across each bin: no tonal plateaus / camo edges,
            # but the histogram is still the measured donor 8-bin vector.
            edges = np.arange(9, dtype=np.float64) * 32.0
            target_l = np.interp(u, cdf, edges)
        else:
            centres = np.arange(8, dtype=np.float64) * 32.0 + 16.0
            knots = 0.5 * (cdf[:-1] + cdf[1:])  # centre of each CDF interval
            target_l = np.interp(u, knots, centres)
        # Tighten toward the mean: additive block grain supplies the rest of
        # the variance, so a full-width map would over-populate bins 0 and 4+.
        tighten = float(p["cdf_tighten"])
        target_l = target_l.mean() + tighten * (target_l - target_l.mean())
        # olive L-response of an additive RGB gain with weights (1,.96,.68)
        lresp = 0.299 * p["olive_weights"][0] + 0.587 * p["olive_weights"][1] \
            + 0.114 * p["olive_weights"][2]
        return (target_l - base_luma) / lresp + fine

    power = float(p["shape_power"])
    z = np.sign(n) * np.abs(n) ** power
    z = z / max(1e-6, float(z.std()))
    return float(p["gain_bias"]) + float(p["gain_amp"]) * z + fine


def block_stack(p: dict[str, Any], size: int) -> Image.Image:
    """The three named donor block layers with terrain-driven coverage masks."""
    tile_size = size * 2
    canvas = Image.new("RGBA", (size, size), (40, 44, 48, 255))

    def tile(name: str) -> Image.Image:
        src = Image.open(BLOCKS / f"{name}.png")
        t = tpr.mirror_tileable(src, tile_size)
        t = tpr.adjust_bcs(t, float(p["brightness"]), float(p["contrast"]))
        return tpr.wrap_crop(t, 0, 0, size, size).convert("RGBA")

    base = tile("grass1")
    base.putalpha(base.getchannel("A").point(
        [int(round(255 * float(p["op_base"]))) for _ in range(256)]))
    canvas.alpha_composite(base)

    mod = float(p["mask_modulation"])
    # Coverage fields are seeded, smooth, independent of the gain octave phase.
    cov_dark = np.clip(0.5 + 0.5 * np.tanh(2.0 * value_noise(int(p["seed"]) + 41, size,
                                                              float(p["cell_px"]) * size / SIZE * 1.4)), 0, 1)
    cov_warm = np.clip(0.5 + 0.5 * np.tanh(2.0 * value_noise(int(p["seed"]) + 59, size,
                                                              float(p["cell_px"]) * size / SIZE * 1.7)), 0, 1)
    for name, ceiling, cov in (("grass6", float(p["op_dark"]), cov_dark),
                               ("grass10", float(p["op_warm"]), cov_warm)):
        img = tile(name)
        alpha = (ceiling * (1.0 - mod + mod * 2.0 * cov)).clip(0.0, ceiling)
        alpha_u8 = np.clip(alpha * 255.0 + 0.5, 0, 255).astype(np.uint8)
        img.putalpha(Image.fromarray(alpha_u8, "L"))
        canvas.alpha_composite(img)
    return canvas.convert("RGB")


def render_piece(params: dict[str, Any] | None = None) -> Image.Image:
    """Render the 512x512 RGB piece deterministically."""
    p = dict(DEFAULT)
    if params:
        p.update(params)
    base = block_stack(p, NATIVE)
    a = np.asarray(base, np.float64)
    base_l = (a[..., 0] * 0.299 + a[..., 1] * 0.587 + a[..., 2] * 0.114)
    gain = build_gain(p, NATIVE, base_l)
    weights = np.asarray(p["olive_weights"], np.float64)
    out = a + gain[..., None] * weights  # float throughout; olive, signed
    piece = Image.fromarray(np.clip(out + 0.5, 0, 255).astype(np.uint8), "RGB")
    lift = float(p["grain_lift"])
    radius = float(p["grain_radius"])
    if lift > 0 and str(p["grain_stage"]) == "native":
        piece = piece.filter(ImageFilter.UnsharpMask(
            radius=radius, percent=int(round(lift * 100)), threshold=2))
    piece = piece.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    if lift > 0 and str(p["grain_stage"]) == "post":
        piece = piece.filter(ImageFilter.UnsharpMask(
            radius=radius, percent=int(round(lift * 100)), threshold=2))
    return piece


# ------------------------------------------------------------------ metrics --
def _acf(a: np.ndarray) -> np.ndarray:
    c = a - a.mean()
    f = np.fft.rfft2(c)
    r = np.fft.irfft2(f * np.conj(f), s=a.shape)
    return r / max(1e-12, r[0, 0])


def grid_peak(a: np.ndarray, lags: range = range(8, 41)) -> dict[str, Any]:
    """High-pass FFT autocorrelogram periodicity metric (see docstring)."""
    bl = np.asarray(Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "L").filter(
        ImageFilter.GaussianBlur(6)), np.float64)
    r = _acf(a - bl)
    vals = {int(k): round(0.5 * (abs(float(r[0, k])) + abs(float(r[k, 0]))), 4)
            for k in lags if k < a.shape[0] // 2}
    kmax = max(vals, key=vals.get)
    return {"grid_peak": vals[kmax], "lag_px": kmax, "all_lags": vals}


def measure(img: Image.Image, donor_target: np.ndarray | None = None) -> dict[str, Any]:
    """All T6-T01 acceptance metrics on a 200x200 bilinear downsample."""
    small = img.convert("RGB").resize((200, 200), Image.Resampling.BILINEAR)
    a = np.asarray(small.convert("L"), np.float64)
    bl = np.asarray(small.convert("L").filter(ImageFilter.GaussianBlur(5)), np.float64)
    h, _ = np.histogram(a, bins=8, range=(0, 256))
    pct = h / h.sum() * 100.0
    bs = 40
    sub = np.array([[a[gy * bs:(gy + 1) * bs, gx * bs:(gx + 1) * bs].mean()
                     for gx in range(5)] for gy in range(5)])
    sub_p90, sub_p10 = float(np.percentile(sub, 90)), float(np.percentile(sub, 10))
    import colorsys
    sats, vals = [], []
    for r, g, b in np.asarray(small, np.float64).reshape(-1, 3) / 255.0:
        _, s, v = colorsys.rgb_to_hsv(float(r), float(g), float(b))
        sats.append(s); vals.append(v)
    gp = grid_peak(a)
    out = {
        "L_mean": round(float(a.mean()), 3),
        "L_std": round(float(a.std()), 3),
        "hf_blur5": round(float(np.abs(a - bl).mean()), 3),
        "bins8_pct": [round(float(v), 2) for v in pct],
        "bins_ge3": int((pct >= 3).sum()),
        "low_bins_ge3": int((pct[:4] >= 3).sum()),
        "bins1_plus_2": round(float(pct[1] + pct[2]), 2),
        "sat_mean": round(float(np.mean(sats)), 4),
        "val_mean": round(float(np.mean(vals)), 4),
        "subbox_min": round(float(sub.min()), 2),
        "subbox_max": round(float(sub.max()), 2),
        "subbox_spread": round(float(sub.max() - sub.min()), 2),
        "subbox_p90_p10_ratio": round(sub_p90 / max(1.0, sub_p10), 4),
        "grid_peak": gp["grid_peak"],
        "grid_peak_lag_px": gp["lag_px"],
        "mean_rgb": [round(float(v), 2) for v in np.asarray(small, np.float64).reshape(-1, 3).mean(0)],
    }
    if donor_target is not None:
        out["hist_L1_pp"] = round(float(np.abs(pct - donor_target).sum()), 2)
    return out


# ---------------------------------------------------------------- comparison --
def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        for path in ("C:/Windows/Fonts/dejavusans.ttf", "C:/Windows/Fonts/arial.ttf"):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


def build_compare(render: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    """3-panel [render | #6 spec crop | #8 primary grass crop] labelled sheet."""
    panels: list[tuple[str, Image.Image, tuple[int, int, int, int], str]] = [
        ("PORT RENDER (deterministic)", render, (0, 0, 0, 0), "t6_grass_mottled.png"),
        ("DONOR #6 spec crop", None, (250, 220, 450, 420), "articolo-787.jpg"),
        ("DONOR #8 PRIMARY grass crop", None, (0, 480, 170, 630), "cossacks-3-v1-498085.jpg"),
    ]
    loaded: list[tuple[str, Image.Image, str]] = []
    for title, im, box, name in panels:
        if im is None:
            src = Image.open(REF / name).convert("RGB").crop(box)
            im = src.resize((SIZE, SIZE), Image.Resampling.BILINEAR)
        loaded.append((title, im, name))
    pad, gap, header, caption = 12, 14, 46, 52
    w = pad * 2 + SIZE * len(loaded) + gap * (len(loaded) - 1)
    h = pad * 2 + header + SIZE + caption
    sheet = Image.new("RGB", (w, h), (22, 24, 28))
    d = ImageDraw.Draw(sheet)
    f_title, f_cap = _font(15), _font(12)
    d.text((pad, pad), "T6-T01 grass_mottled  seed=7  512x512  (Pillow, no Godot)",
           font=f_title, fill=(232, 236, 242))
    for i, (title, im, name) in enumerate(loaded):
        x = pad + i * (SIZE + gap)
        sheet.paste(im, (x, pad + header))
        d.rectangle((x - 1, pad + header - 1, x + SIZE, pad + header + SIZE),
                    outline=(96, 102, 112))
        colour = (150, 220, 168) if i == 0 else (240, 198, 140)
        d.text((x, pad + header + SIZE + 7), title, font=f_cap, fill=colour)
        d.text((x, pad + header + SIZE + 24), name, font=f_cap, fill=(170, 176, 186))
    return sheet, {"panels": [n for _, _, n in loaded],
                   "donor_crops": {"c6": [250, 220, 450, 420], "c8_primary": [0, 480, 170, 630]}}


# ------------------------------------------------------------------- driver --
def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out-dir", default=str(OUT))
    ap.add_argument("--params", default=None,
                    help='JSON object of parameter overrides, e.g. \'{"gain_amp":44}\'')
    ap.add_argument("--measure", action="store_true", help="print metrics JSON to stdout")
    args = ap.parse_args(argv)

    overrides = json.loads(args.params) if args.params else {}
    piece = render_piece(overrides)
    out_dir = Path(args.out_dir).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    png = out_dir / "t6_grass_mottled.png"
    piece.save(png, format="PNG", optimize=True)

    sheet, _ = build_compare(piece)
    cmp_png = out_dir / "t6_grass_mottled_compare.png"
    sheet.save(cmp_png, format="PNG", optimize=True)

    # Measured donor vectors (temp probes). L1 is reported against BOTH the
    # grass-only subregion and the full contaminated spec crop, never hidden.
    donor_grass = np.array([4.2, 36.4, 49.4, 4.7, 2.0, 1.1, 1.1, 1.2])
    donor_full = np.array([5.0, 39.3, 44.7, 4.8, 1.9, 1.2, 1.2, 1.8])
    result = {
        "params": {**DEFAULT, **overrides},
        "output": str(png.relative_to(ROOT)) if png.is_relative_to(ROOT) else str(png),
        "compare": str(cmp_png.relative_to(ROOT)) if cmp_png.is_relative_to(ROOT) else str(cmp_png),
        "sha256_piece": hashlib.sha256(png.read_bytes()).hexdigest(),
        "sha256_compare": hashlib.sha256(cmp_png.read_bytes()).hexdigest(),
        "metrics": measure(piece, donor_grass),
    }
    result["metrics"]["hist_L1_vs_full_donor_pp"] = measure(piece, donor_full)["hist_L1_pp"]
    if args.measure:
        print(json.dumps(result, indent=2))
    else:
        print(f"[t6t01] {result['output']} sha256={result['sha256_piece'][:12]} "
              f"L_std={result['metrics']['L_std']} hf={result['metrics']['hf_blur5']} "
              f"bins={result['metrics']['bins_ge3']} grid_peak={result['metrics']['grid_peak']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
