#!/usr/bin/env python3
"""T6-T06 -- single-piece headless mini-baker for ``hill_ridge``.

One owned piece: an elongated (N-S, aspect 1.69) donor-shaped grass-capped
ridge with ONE broad eroded rock/earth flank.  The flank carries a lit-rim /
shadowed-foot colour ramp, curved irregular erosion banding, an ambient-
occlusion collar at the grass contact, and a soft contact/cast shadow.  The
goal is an eroded 3D-looking landscape, not a diagram or a round green dome.

Hard rules honoured here
------------------------
* Headless Python 3.14 + Pillow + NumPy only.  No Godot process is launched.
* ``terrain_piece_render.py`` is imported READ-ONLY for the low-level tiling
  helpers and the labelled comparison sheet; it is never edited and no spec
  JSON is written.
* Donor assets are private-use reference only.  The raw ``g_hil1.pattern``
  occupancy bytes are NEVER copied into the repo: only a smoothed, derived
  envelope (numbers below) is embedded.  All rendering art comes from port
  PNGs under ``app/assets``.
* Deterministic: fixed seed 7, no clock input, fixed resampling.

Output (all under ``app/shots/pieces``)::

    t6_hill_ridge.png          the piece, 512x512 RGB
    t6_hill_ridge_compare.png  labelled [render | donor crop] sheet
    t6_hill_ridge_facecrop.png diagnostic flank crop (measurement aid)
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# ---- read-only import of the shared renderer helpers -----------------------
TOOLS = Path(__file__).resolve().parent.parent          # app/tools
APP = TOOLS.parent                                       # app
ROOT = APP.parent                                        # repo root
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as tpr                       # READ-ONLY

BLOCKS = APP / "assets" / "terrain" / "blocks"
SPRITES = APP / "assets" / "models" / "sprites_hi"
OUT = APP / "shots" / "pieces"
DEFAULT_REF_DIR = Path("C:/Users/Maxym.Oboyshev/Downloads/c3")
REF_NAME = "articolo-787.jpg"                            # primary ridge reference (#6)
CROP = (300, 210, 470, 330)                             # spec primary box (mound2)

OUT_PX = 512
NATIVE_PX = 1024                                         # one native pass, one downsample
SEED = 7

# ---- donor-derived footprint envelope (DERIVED, not copied) ----------------
# Source: C:\Games\Cossacks 3\data\pattern\g_hil1.pattern, 32x56 cells,
# 725 occupied cells (ratio 0.405), occupied bbox 32x54 -> aspect 1.688,
# eigen-aspect 2.215, long axis Y (docs/audit/PIECES/hill_ridge.md 1.1).
# The donor mask's occupied rows form a sinuous N-S band with a mean width
# giving ~0.405 occupancy; its row-centre drifts but with hard jumps, so we
# keep a gently curved centreline and a similar mean band width.  No raw mask
# bytes are stored here.
FOOT_Y0, FOOT_Y1 = 0.08, 0.92          # 432 px at 512 -> footprint height
FACE_L = 0.22                           # outer (foot) edge of the flank, norm X
RIM_X = 0.40                            # grass/rock boundary, norm X
RIGHT_X = 0.74                          # right edge of footprint, norm X
# footprint width = 0.74-0.22 = 0.52*512 = 266 px; height 432 -> aspect 1.62
DRIFT = 0.022                           # gentle centreline sway (norm X)
PHASE = 0.6
RIM_JIT = 0.012                         # seeded rim irregularity (norm X)
FACE_VAR = 0.022                        # flank-width variation

# ---- palette anchors (observed / canonical) --------------------------------
# docs/audit/TERRAIN_REFERENCE_IMAGES.md 2 + hill_ridge.md 1.2
LIT = np.array([0x6C, 0x61, 0x4B], dtype=np.float64)     # #6C614B pale lit rock
MID = np.array([0x4B, 0x44, 0x30], dtype=np.float64)     # #4B4430 mid rock
SHADOW = np.array([0x39, 0x34, 0x24], dtype=np.float64)  # #393424 deep shadow
PALE = np.array([0x8B, 0x7D, 0x67], dtype=np.float64)    # #8B7D67 pale flute
# donor grass cap means (articolo-787.jpg): (66.6,65.7,49.7) L64.7 and
# (63.7,58.4,30.9) L57.5; open plain control (78.4,75.7,39.8) L73.7.
GRASS_TARGET = np.array([88.0, 88.0, 50.0])              # hue 60 deg, sat 0.43

# ---- tunables (calibrated against donor mound crops; see report) ----------
GRASS_BRIGHT = 1.0
GRASS_CONTRAST = 1.10
GRASS_MOTTLE = 11.0        # gentle +/- L mottling (donor relief grass std ~25)
SCUFF_OPACITY = 0.40       # grass_rock1 dry-brown scuffs at the spec opacity
STRETCH = 2.4              # vertical stretch of rock1 grain
FLUTE_SIGMA = 3.0
BAND_GAIN = 0.55           # curved erosion banding, irregular not corduroy
BANDS_N = 2.8              # only a few broad layers, not corduroy
EARTH_AMP = 9.0            # strong fine earth texture (rock1 high-pass)
GRAIN_AMP = 5.0
RAMP_GAMMA = 2.6           # lit rim -> shadowed foot; bulk of face stays dark
AO_STRENGTH = 0.24         # dark collar in grass at the rock contact
CONTACT_AO = 0.18          # contact shadow on the top few px of the wall
FOOT_AO = 0.24             # contact shadow where the wall meets the field
CAST_STRENGTH = 0.14       # soft ridge cast shadow onto the field (lower-left)
TUFT_COUNT = 190           # overhanging grass tufts along the rim


def _clamp(arr: np.ndarray, lo: float, hi: float) -> np.ndarray:
    return np.clip(arr, lo, hi)


def _blur(arr: np.ndarray, sigma: float) -> np.ndarray:
    """Gaussian blur a 2-D float array via Pillow (matches shared renderer)."""
    im = Image.fromarray(_clamp(arr, 0, 255).astype(np.uint8), "L")
    return np.asarray(im.filter(ImageFilter.GaussianBlur(sigma)), dtype=np.float64)


def _smooth1d(vals: list[float], n: int, sigma: float) -> np.ndarray:
    """Seeded smooth 1-D noise field of length n (organic variation)."""
    arr = np.interp(np.linspace(0, len(vals) - 1, n), np.arange(len(vals)),
                    np.asarray(vals, dtype=np.float64))
    half = int(round(3 * float(sigma)))
    k = np.exp(-0.5 * (np.arange(-half, half + 1, dtype=np.float64) / sigma) ** 2)
    k /= k.sum()
    pad = len(k) // 2
    return np.convolve(np.pad(arr, (pad, pad), mode="edge"),
                       k, mode="valid")


def _tile(name: str, size: int, ox: int, oy: int) -> Image.Image:
    """Mirror-tile a port block and wrap-crop it deterministically."""
    path = tpr._png(BLOCKS, name)
    tile = tpr.mirror_tileable(Image.open(path), size, Image.Resampling.BILINEAR)
    return tpr.wrap_crop(tile, ox, oy, size, size).convert("RGB")


def _taper(t: np.ndarray) -> np.ndarray:
    """Rounded ends INSIDE the footprint band: 0 at FOOT_Y0/FOOT_Y1, 1 in body."""
    e = np.clip(np.minimum(t - FOOT_Y0, FOOT_Y1 - t) / 0.09, 0.0, 1.0) ** 0.45
    return 0.55 + 0.45 * e          # rounded ends, never a sharp point


def build_piece(include_tree: bool = True) -> tuple[Image.Image, dict[str, Any]]:
    """Render the single hill-ridge piece. Returns (512px RGB image, details).

    ``include_tree=False`` renders the same piece without the spruce; used by
    the acceptance probe to segment the tree by exact difference.
    """
    rng = np.random.default_rng(SEED)
    n = NATIVE_PX
    ys = np.arange(n, dtype=np.float64)[:, None]      # (n,1) pixel coords
    xs = np.arange(n, dtype=np.float64)[None, :]      # (1,n) pixel coords
    xn = xs / n                                        # (1,n) normalised X
    t = ys / n                                         # long-axis coordinate
    end = _taper(t)                                     # rounded N/S ends
    drift = DRIFT * np.sin(2 * np.pi * t * 0.9 + PHASE) * end
    rim_jit = RIM_JIT * (0.70 * _smooth1d(
        [rng.uniform(-1, 1) for _ in range(13)], n, 52)
        + 0.30 * _smooth1d(
            [rng.uniform(-1, 1) for _ in range(31)], n, 11))[:, None] * end
    face_jit = 0.012 * _smooth1d(
        [rng.uniform(-1, 1) for _ in range(17)], n, 30)[:, None] * end
    face_l = 0.50 + (FACE_L + drift + face_jit - 0.50) * end
    rim = 0.50 + (RIM_X + drift + rim_jit - 0.50) * end
    right = 0.50 + (RIGHT_X + drift - 0.50) * end
    width = np.maximum(rim - face_l, 1e-6)            # flank width (n,1)

    # ---- grass field base ---------------------------------------------------
    grass = np.asarray(_tile("grass1", n, int(rng.integers(0, 512)),
                             int(rng.integers(0, 512))), dtype=np.float64)
    grass = np.asarray(tpr.adjust_bcs(Image.fromarray(grass.astype(np.uint8), "RGB"),
                                      GRASS_BRIGHT, GRASS_CONTRAST), dtype=np.float64)
    mean = grass.mean(axis=(0, 1), keepdims=True)
    grass = grass - mean + GRASS_TARGET[None, None, :]   # donor near olive, grain kept
    mottle = _smooth1d([rng.uniform(-1, 1) for _ in range(40)], n, 26)[:, None]
    mottle2 = _smooth1d([rng.uniform(-1, 1) for _ in range(40)], n, 30)[None, :]
    grass += GRASS_MOTTLE * (0.6 * mottle + 0.4 * mottle2)[:, :, None]
    canvas = _clamp(grass, 0, 255)

    # ---- soft cast/contact shadow of the ridge onto the field --------------
    shadow_mask = Image.new("L", (n, n), 0)
    sd = ImageDraw.Draw(shadow_mask)
    off = int(0.035 * n)                                # lower-left (sun upper-right)
    poly = []
    for y0 in range(int(n * FOOT_Y0), int(n * FOOT_Y1), 8):
        yy = y0 / n
        e = float(_taper(np.array([[yy]]))[0, 0])
        c = DRIFT * np.sin(2 * np.pi * yy * 0.9 + PHASE) * e
        poly.append((float(face_l[int(yy * n) - 1, 0] if int(yy*n)>0 else FACE_L) * n - off,
                     y0 + off))
    for y0 in range(int(n * FOOT_Y1) - 1, int(n * FOOT_Y0) - 1, -8):
        yy = y0 / n
        e = float(_taper(np.array([[yy]]))[0, 0])
        c = DRIFT * np.sin(2 * np.pi * yy * 0.9 + PHASE) * e
        rr = (RIGHT_X + c * 0.5) * e + 0.50 * (1 - e)
        poly.append((rr * n - off, y0 + off))
    if len(poly) > 2:
        sd.polygon(poly, fill=255)
    cast = np.asarray(shadow_mask.filter(ImageFilter.GaussianBlur(20)),
                      dtype=np.float64) / 255.0
    canvas = canvas * (1 - CAST_STRENGTH * cast[:, :, None])

    # ---- dry-brown scuffs on the grass cap (seeded blotches) ---------------
    scuff = np.asarray(_tile("grass_rock1", n, int(rng.integers(0, 512)),
                             int(rng.integers(0, 512))), dtype=np.float64)
    sgrid = [[rng.uniform(-1, 1) for _ in range(7)] for _ in range(11)]
    small = Image.new("L", (7, 11))
    for gy in range(11):
        for gx in range(7):
            small.putpixel((gx, gy), int(_clamp(128 + 110 * sgrid[gy][gx], 0, 255)))
    sfield = np.asarray(small.resize((n, n), Image.Resampling.BILINEAR),
                        dtype=np.float64) / 255.0
    cap = (xn >= rim + 0.004) & (xn <= right) & (ys >= n * FOOT_Y0) \
          & (ys <= n * FOOT_Y1)
    scuff_alpha = cap & (sfield > 0.45)
    scuff_alpha = scuff_alpha.astype(np.float64)
    a = SCUFF_OPACITY * scuff_alpha[:, :, None]
    canvas = canvas * (1 - a) + scuff * a
    # a slight tonal lift makes the ridge cap read distinct from the open field
    canvas = canvas + np.where(cap, 3.0, 0.0)[:, :, None]

    # ---- flank texture: stretched rock1 grain + curved erosion banding ----
    r1 = np.asarray(_tile("rock1", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))).convert("L"), dtype=np.float64)
    r8 = np.asarray(_tile("rock8", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))).convert("L"), dtype=np.float64)

    def norm(f: np.ndarray) -> np.ndarray:
        return _clamp(f / (2.4 * f.std() + 1e-6), -1.0, 1.0)

    def stretched(src: np.ndarray, stretch: float, sigma: float) -> np.ndarray:
        idx = np.minimum((np.arange(n) / stretch).astype(int), n - 1)
        s = src[idx, :]
        return s - _blur(s, sigma)

    grain = norm(stretched(r8, 2.0, 2.5))
    fine = norm(stretched(r1, STRETCH, FLUTE_SIGMA))
    earth = norm(stretched(r1, 1.5, 1.5))
    # 2-D smooth noise -> irregular band spacing (kills the corduroy look)
    g2 = [[rng.uniform(-1, 1) for _ in range(9)] for _ in range(13)]
    small2 = Image.new("L", (9, 13))
    for gy in range(13):
        for gx in range(9):
            small2.putpixel((gx, gy), int(_clamp(128 + 110 * g2[gy][gx], 0, 255)))
    n2 = np.asarray(small2.resize((n, n), Image.Resampling.BILINEAR),
                    dtype=np.float64) / 255.0 - 0.5

    # positional field across the flank: u=0 foot(left), u=1 rim(right)
    u = _clamp((xn - face_l) / width, 0.0, 1.0)
    v = t
    # Curved layers: phase bends along the ridge and is perturbed by rock1
    # grain, so bands sweep with the loaf instead of running as straight lines.
    col = np.minimum((u * (n - 1)).astype(int), n - 1)
    row_idx = np.arange(n)[:, None]                      # (n,1)
    fine_u = fine[row_idx, col]                          # (n,n) sampled at flank u
    earth_u = earth[row_idx, col]
    phase = (BANDS_N * u
             + 1.15 * np.sin(2 * np.pi * v * 0.9)
             + 0.55 * np.sin(2 * np.pi * v * 2.3 + 0.7)
             + 0.45 * n2 + 0.12 * fine_u)
    layer = np.sin(2 * np.pi * phase)                    # broad curved layers
    # earth texture dominates over the (subtle) layering
    layer = _clamp(0.85 * layer + 0.30 * fine_u + 0.20 * earth_u, -1.0, 1.0)
    # along-ridge amplitude variation -> bands fade in and out (organic)
    amp_y = 0.55 + 0.5 * (0.5 + 0.5 * _smooth1d(
        [rng.uniform(-1, 1) for _ in range(9)], n, 48))[:, None]

    # ---- one-sided rock flank ---------------------------------------------
    face = (xn >= face_l) & (xn < rim) & (ys >= n * FOOT_Y0) & (ys <= n * FOOT_Y1)
    ramp = _clamp((u - 0.02) / 0.85, 0.0, 1.0) ** RAMP_GAMMA
    foot_col = SHADOW * 0.72                              # deepest foot shadow
    base = foot_col[None, None, :] * (1 - ramp[:, :, None]) \
           + LIT[None, None, :] * ramp[:, :, None]
    crest = np.maximum(layer, 0.0)[:, :, None]
    groove = np.maximum(-layer, 0.0)[:, :, None]
    mod = BAND_GAIN * amp_y[:, :, None] * (0.45 + 0.55 * ramp[:, :, None])
    base = base + crest * (PALE - LIT)[None, None, :] * mod \
                + groove * (SHADOW - MID)[None, None, :] * mod
    base = base + earth_u[:, :, None] * EARTH_AMP + grain[:, :, None] * GRAIN_AMP
    # pale lit streaks on the upper face (donor mound1 catches light near the rim)
    streak = np.clip((u - 0.55) / 0.45, 0.0, 1.0)[:, :, None] \
             * (0.25 + 0.75 * np.maximum(layer, 0.0))[:, :, None] \
             * (0.45 + 0.55 * (n2 + 0.5))[:, :, None]
    base = base + streak * np.array([8.0, 7.0, 5.0])[None, None, :]
    # contact shadow at the grass/rock contact (u -> 1)
    contact = np.clip((u - 0.90) / 0.10, 0.0, 1.0)[:, :, None]
    base = base * (1 - CONTACT_AO * contact)
    # ambient occlusion where the wall meets the field (u -> 0)
    foot = np.clip((0.12 - u) / 0.12, 0.0, 1.0)[:, :, None]
    base = base * (1 - FOOT_AO * foot)
    # 2 px feathered edge (not a black outline); donor rim is hard but clean
    edge = np.minimum(np.clip((xn - face_l) / 0.004, 0, 1),
                      np.clip((rim - xn) / 0.004, 0, 1))[:, :, None]
    blend = face[:, :, None].astype(np.float64) * edge
    canvas = canvas * (1 - blend) + _clamp(base, 0, 255) * blend

    # ---- AO collar in the grass at the rock contact -----------------------
    grass_base = canvas.copy()
    d_rim = xn - rim                                    # >0 inside the grass
    collar = np.where((d_rim >= 0) & (d_rim < 0.030),
                      np.exp(-d_rim / 0.010), 0.0)[:, :, None]
    in_y = ((ys >= n * FOOT_Y0) & (ys <= n * FOOT_Y1))[:, :, None]
    canvas = canvas * (1 - AO_STRENGTH * collar * in_y)

    # ---- overhanging grass tufts along the rim ----------------------------
    tuft_img = Image.new("L", (n, n), 0)
    td = ImageDraw.Draw(tuft_img)
    for _ in range(TUFT_COUNT):
        y0 = int(rng.uniform(n * FOOT_Y0, n * FOOT_Y1))
        x0 = int(float(rim[y0, 0]) * n) + int(rng.integers(-4, 3))
        td.line([(x0, y0 - 2), (x0 + int(rng.integers(3, 8)), y0 - 2)],
                fill=255, width=2)
    tuft = np.asarray(tuft_img) > 0
    canvas[tuft] = _clamp(grass_base[tuft] * 0.70, 0, 255)

    # ---- spruce on the rim (spec pos 0.4,0.5; anchor centre so the visible
    #      ink centroid lands at the mandated M8 point) ---------------------
    if include_tree:
        tree = Image.open(SPRITES / "tree_spruce1.png").convert("RGBA")
        tw, th = int(round(0.15 * n)), int(round(0.19 * n))   # ~64x74 out ink px
        tree = tree.resize((tw, th), Image.Resampling.BILINEAR)
        ib = tree.getchannel("A").getbbox()
        cx = (ib[0] + ib[2]) / 2.0 if ib else tw / 2.0
        cy = (ib[1] + ib[3]) / 2.0 if ib else th / 2.0
        tree_layer = Image.new("RGBA", (n, n), (0, 0, 0, 0))
        tree_layer.alpha_composite(tree, (int(round(0.40 * n - cx)),
                                          int(round(0.50 * n - cy))))
        ta = np.asarray(tree_layer.getchannel("A"), dtype=np.float64) / 255.0
        trgb = np.asarray(tree_layer.convert("RGB"), dtype=np.float64)
        canvas = canvas * (1 - ta[:, :, None]) + trgb * ta[:, :, None]

    # Two smaller spruces on the grass cap (donor trees cluster on rims).
    # Always drawn in both variants so the M8 exact-difference isolates the
    # single spec-mandated tree at (0.4, 0.5).
    rim_trees = ((0.47, 0.12, 0.09, 0.11), (0.54, 0.27, 0.12, 0.13),
                 (0.45, 0.63, 0.08, 0.10), (0.58, 0.72, 0.10, 0.12),
                 (0.50, 0.90, 0.07, 0.09))
    for px, py, sx, sy in rim_trees:
        t2 = Image.open(SPRITES / "tree_spruce1.png").convert("RGBA")
        t2 = t2.resize((int(sx * n), int(sy * n)), Image.Resampling.BILINEAR)
        ib2 = t2.getchannel("A").getbbox()
        c2x = (ib2[0] + ib2[2]) / 2.0 if ib2 else t2.width / 2.0
        c2y = (ib2[1] + ib2[3]) / 2.0 if ib2 else t2.height / 2.0
        lay = Image.new("RGBA", (n, n), (0, 0, 0, 0))
        lay.alpha_composite(t2, (int(round(px * n - c2x)), int(round(py * n - c2y))))
        a2 = np.asarray(lay.getchannel("A"), dtype=np.float64) / 255.0
        rgb2 = np.asarray(lay.convert("RGB"), dtype=np.float64)
        canvas = canvas * (1 - a2[:, :, None]) + rgb2 * a2[:, :, None]

    # ---- one downsample, mild grain lift ----------------------------------
    out = Image.fromarray(_clamp(canvas, 0, 255).astype(np.uint8), "RGB")
    out = out.resize((OUT_PX, OUT_PX), Image.Resampling.LANCZOS)
    out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=140, threshold=2))

    details = {
        "generator": "t6_hill_ridge.py", "seed": SEED,
        "size_px": [OUT_PX, OUT_PX], "native_px": n,
        "footprint_box_px": [113, 41, 379, 471], "footprint_aspect": 1.62,
        "donor_mask": {"pattern": "g_hil1.pattern", "w": 32, "h": 56,
                       "occupied": 725, "ratio": 0.405, "eig_aspect": 2.215,
                       "long_axis": "Y", "note": "raw bytes never copied; only a "
                       "derived centreline/width envelope embedded"},
        "face": {"width_norm": round(float(np.mean(width)), 3),
                 "stretch": STRETCH, "bands": BANDS_N, "band_gain": BAND_GAIN,
                 "earth_amp": EARTH_AMP, "ramp_gamma": RAMP_GAMMA,
                 "grain_amp": GRAIN_AMP},
        "occlusion": {"grass_contact_ao": AO_STRENGTH, "wall_contact_ao": CONTACT_AO,
                      "foot_ao": FOOT_AO, "cast_shadow": CAST_STRENGTH},
        "palette": {"lit": "#6C614B", "mid": "#4B4430", "shadow": "#393424",
                    "pale_flute": "#8B7D67", "grass_target": [78, 78, 42]},
        "art": {"field": "grass1.png", "scuffs": "grass_rock1.png",
                "flutes": "rock1.png", "grain": "rock8.png",
                "tree": "tree_spruce1.png"},
        "tree": {"pos_norm": [0.40, 0.50], "anchor": "centre",
                 "stretch": [0.15, 0.19], "height_out_px": int(0.19 * n) // 2},
    }
    return out, details


def _reference_crop(ref_dir: Path) -> Image.Image:
    path = ref_dir / REF_NAME
    if not path.is_file():
        raise FileNotFoundError(f"reference not found: {path}")
    return Image.open(path).convert("RGB").crop(CROP).resize(
        (OUT_PX, OUT_PX), tpr.RESAMPLE)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="T6-T06 hill_ridge mini-baker")
    ap.add_argument("--out-dir", default=str(OUT))
    ap.add_argument("--ref-dir", default=str(DEFAULT_REF_DIR))
    args = ap.parse_args(argv)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    render, details = build_piece()
    render_path = out_dir / "t6_hill_ridge.png"
    render.save(render_path, format="PNG", optimize=True)

    ref = _reference_crop(Path(args.ref_dir))
    compare = tpr.build_comparison(
        "t6_hill_ridge", render, ref, SEED,
        [{"type": "block"}, {"type": "face"}, {"type": "sprite"}], list(CROP))
    compare.save(out_dir / "t6_hill_ridge_compare.png", format="PNG", optimize=True)

    render.crop((110, 70, 300, 450)).save(
        out_dir / "t6_hill_ridge_facecrop.png", format="PNG", optimize=True)

    details["sha256"] = hashlib.sha256(render_path.read_bytes()).hexdigest()
    details["outputs"] = {
        "piece": str(render_path),
        "compare": str(out_dir / "t6_hill_ridge_compare.png"),
        "facecrop": str(out_dir / "t6_hill_ridge_facecrop.png"),
    }
    (out_dir / "t6_hill_ridge.manifest.json").write_text(
        json.dumps(details, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[t6_hill_ridge] wrote {render_path}  sha256={details['sha256'][:12]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
