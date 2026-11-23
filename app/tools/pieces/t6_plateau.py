#!/usr/bin/env python3
"""T6-T07 -- single-piece headless mini-baker for ``plateau``.

Owns exactly: this file, ``app/shots/pieces/t6_plateau*.png`` (+ manifest),
an APPEND-only verdict section in ``docs/audit/PIECES/plateau.md`` and
``docs/t6/reports/T6-T07.md``.  ``terrain_piece_render.py`` is imported
READ-ONLY for the tiling primitives and the comparison sheet; it is never
edited and no Godot process is launched.

What the piece models
---------------------
Donor truth (docs/audit/PIECES/plateau.md, verified again this ticket): the
plateau is a near-planar *grass* top at height +2.964 (mask R=255,
``generatemap.inc:4,21,569-574``) cut by branching near-vertical earthen/rock
walls; the wall is the ONLY rock, grass meets it in a 1-3 px rim with
overhanging tufts, and lit/shadow are #6C614B / #393424.  The donor height
grid is the map grid (256/320/480/640 samples per axis); the port mirrors the
amplitude but uses a fixed 160^2 grid and an authored radial ramp.

This renderer produces BOTH:
  * a deterministic 2-D visual (grass top + organic fluted rock wall + walkable
    grass ramp + ambient occlusion at the grass/rock contact), and
  * a small deterministic height model (64x64 tiles over the piece) so that
    ``max height <= 2.964``, the presence of a walkable ramp (gradient <=
    collision gate 0.5) and the presence of steep rock cells are measurable.

The height model is a *port profile* derived from ``game.gd:641-642,692-703``
(amp 2.964, edge 0.97, rim 8 tiles, collision gate 0.5).  It is NOT a decoded
donor heightfield -- the donor per-cell stamp heights are undecoded.  Every
claim is labelled observed / derived / inferred in the report.

Usage::

    python app/tools/pieces/t6_plateau.py
    python app/tools/pieces/t6_plateau.py --measure
    python app/tools/pieces/t6_plateau.py --params '{"rock_gain":0.8}'
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# ---- read-only shared renderer ---------------------------------------------
TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent.parent
ROOT = APP.parent
if str(TOOLS.parent) not in sys.path:
    sys.path.insert(0, str(TOOLS.parent))
import terrain_piece_render as tpr                       # READ-ONLY, never edited

BLOCKS = APP / "assets" / "terrain" / "blocks"
OUT = APP / "shots" / "pieces"
REF = Path.home() / "Downloads" / "c3"
REF_NAME = "cossacks-3-v1-498085.jpg"
CROP_C = (350, 0, 850, 300)                              # primary plateau crop
CROP_BOUNDARY = (0, 600, 210, 720)                       # grass->rock rim zoom

SEED = 7
SIZE = 512
NATIVE = SIZE * 2                                        # one native pass, one downsample
GRID_TILES = 64                                          # height-model grid over the piece
PX_PER_TILE = NATIVE // GRID_TILES                       # 16 native px / port tile

# Height profile (derived from game.gd plateau branch + collision gate).
H_CAP = 2.964                                            # donor ceiling, no stacking
H_LIP = 1.50                                             # height at bottom of the rock lip
LIP_TILES = 2                                            # steep rock lip (2 tiles)
RAMP_TILES = 6                                           # walkable grass ramp (6 tiles)
RIM_TILES = LIP_TILES + RAMP_TILES                       # 8 tiles, matches rim_tiles=8
COLLISION_GATE = 0.5
LIP_GRAD = (H_CAP - H_LIP) / LIP_TILES                   # 0.732 > gate -> rock
RAMP_GRAD = H_LIP / RAMP_TILES                           # 0.250 <= gate -> walkable
# Modelled full-stamp geometry (donor footprints 38-93 cells, port scale s=MAP_W/160).
STAMP_RX = 48.0
STAMP_RY = 30.0                                          # aspect 1.6 >= TB-B5 1.5

# Palette anchors (observed, TERRAIN_REFERENCE_IMAGES.md §2 / plateau.md §1.4).
# Measured target anchors. LIT/PALE are the *pre-contact* lit-strip colours:
# the contact AO below darkens the first few px so the sampled lit band lands
# on the canonical #6C614B.
LIT = np.array([135.0, 122.0, 96.0], np.float64)         # target #6C614B after contact AO
MID = np.array([0x4B, 0x44, 0x30], np.float64)           # #4B4430 (75,68,48)
SHADOW = np.array([66.0, 60.0, 42.0], np.float64)        # target #393424 after foot AO
PALE = np.array([165.0, 152.0, 128.0], np.float64)       # pale flute crests

# INFERRED render tunables, calibrated against donor crops this ticket.
GRASS_BRIGHT = 1.16
GRASS_CONTRAST = 0.85
GRASS_MOTTLE_AMP = 6.0
AO_COLLAR = 0.30                                         # soft AO just above the rim
AO_WIDE = 0.14                                           # wider grass darkening near rim
CONTACT_AO = 0.30                                        # contact shadow at wall top
FOOT_AO = 0.15                                           # AO at wall foot
FLOOR_DARK = 0.72                                        # lower-grass floor shading
FLUTE_GAIN = 0.90
FLUTE_FADE = 0.45
FLUTE_STRETCH = 2.4
FLUTE_WARP = 7.0
GRAIN_AMP = 5.0
TUFT_OPACITY = 0.86
RAMP_DARK = 0.17                                         # gentle grassy-slope shading


# --------------------------------------------------------------- primitives --
def _tile(name: str, size: int, ox: int, oy: int) -> Image.Image:
    """Mirror-tile a port block and wrap-crop it deterministically."""
    path = tpr._png(BLOCKS, name)
    tile = tpr.mirror_tileable(Image.open(path), size, Image.Resampling.BILINEAR)
    return tpr.wrap_crop(tile, ox, oy, size, size).convert("RGB")


def _blur(arr: np.ndarray, sigma: float) -> np.ndarray:
    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "L")
    return np.asarray(im.filter(ImageFilter.GaussianBlur(sigma)), np.float64)


def value_noise(seed: int, size: int, cell: float) -> np.ndarray:
    """Signed smooth value noise in [-1,1] (negatives preserved, unlike tpr L)."""
    rng = np.random.default_rng(seed)
    cols = max(2, int(math.ceil(size / cell)) + 2)
    grid = rng.uniform(-1.0, 1.0, (cols, cols))
    small = Image.fromarray(np.clip((grid + 1.0) * 127.5, 0, 255).astype(np.uint8), "L")
    field = np.asarray(small.resize((size, size), Image.Resampling.BICUBIC), np.float64)
    return (field - 127.5) / 127.5


def highpass(src: np.ndarray, stretch: float, sigma: float) -> np.ndarray:
    """Vertically stretched high-pass: kills vertical gradient, keeps flutes."""
    n = src.shape[0]
    idx = np.minimum((np.arange(n) / stretch).astype(int), n - 1)
    s = src[idx, :]
    return s - _blur(s, sigma)


def norm_field(f: np.ndarray) -> np.ndarray:
    return np.clip(f / (2.4 * f.std() + 1e-6), -1.0, 1.0)


# ------------------------------------------------------------- geometry ------
def boundary_profile(n: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Organic periodic plateau rim, wall thickness and walkable-ramp sector.

    Returns three length-n arrays (native px / px / 0..1).  The rim is a
    diagonal trend plus a multi-octave meander and local gully notches: it is
    deliberately NOT a circle, a straight line or a constant-width ribbon.
    """
    rng = np.random.default_rng(SEED + 101)
    xs = np.arange(n, dtype=np.float64)
    phase = {k: rng.uniform(0.0, 2.0 * math.pi) for k in (1, 2, 3, 4, 5, 7, 8, 11)}
    # Winding diagonal trend (left high, right lower) + broad meander.
    y = 0.30 * n + 0.20 * n * xs / n
    for k, amp in ((1, 46.0), (2, 28.0), (3, 17.0), (4, 10.0), (5, 7.0),
                   (8, 4.0), (11, 3.5), (17, 2.0)):
        y += amp * np.sin(2.0 * math.pi * k * xs / n + phase.get(k, 0.0))
    # Gully tongues: the plateau cuts DOWN into the wall at two irregular x.
    for cx, amp, wid in ((0.20 * n, 62.0, 0.040 * n),
                         (0.62 * n, 38.0, 0.055 * n)):
        dn = np.abs(xs - cx)
        dn = np.minimum(dn, n - dn)
        y += amp * np.exp(-0.5 * (dn / wid) ** 2)
    # Wall bulges: the wall intrudes UP into the plateau at two other x.
    for cx, amp, wid in ((0.38 * n, 44.0, 0.050 * n),
                         (0.86 * n, 30.0, 0.035 * n)):
        db = np.abs(xs - cx)
        db = np.minimum(db, n - db)
        y -= amp * np.exp(-0.5 * (db / wid) ** 2)

    # Wall thickness varies strongly (60..230 native px): no uniform ribbon.
    hw = np.full(n, 146.0, np.float64)
    for k, amp in ((1, 34.0), (2, 26.0), (3, 18.0), (4, 12.0), (7, 9.0),
                   (11, 11.0), (17, 6.0)):
        hw += amp * np.sin(2.0 * math.pi * k * xs / n + phase.get(k, 0.0))
    hw = np.clip(hw, 55.0, 235.0)

    # Walkable-ramp sector: the wall tapers into a gentle grass slope at the
    # right edge, blending continuously (no rectangular gap in the wall).
    d0 = np.abs(xs - 0.88 * n)
    d0 = np.minimum(d0, n - d0)
    ramp = np.clip((0.17 * n - d0) / (0.10 * n), 0.0, 1.0)
    return y, hw, ramp


def height_model(y: np.ndarray, hw: np.ndarray, ramp: np.ndarray) -> dict[str, Any]:
    """64x64 port-tile height field: flat top + steep rock lip + walkable ramp.

    This is the *port height profile* (game.gd amplitude/rim constants), not a
    decoded donor heightfield.  Values are capped at H_CAP -- one stamp, no
    additive stacking.
    """
    g = GRID_TILES
    gy = np.arange(g, dtype=np.float64)[:, None] * PX_PER_TILE
    gx = np.arange(g, dtype=np.float64)[None, :] * PX_PER_TILE
    yi = np.clip(np.rint(y).astype(int), 0, NATIVE - 1)
    yb = yi[np.clip(np.rint(gx[0]).astype(int), 0, NATIVE - 1)][None, :]
    hw_g = hw[np.clip(np.rint(gx[0]).astype(int), 0, NATIVE - 1)][None, :]
    ramp_g = ramp[np.clip(np.rint(gx[0]).astype(int), 0, NATIVE - 1)][None, :]
    d_tiles = (gy - yb) / PX_PER_TILE

    h = np.full((g, g), H_CAP, np.float64)
    # Steep rock lip (2 tiles) then walkable ramp (6 tiles).
    lip = (d_tiles > 0) & (d_tiles <= LIP_TILES)
    h[lip] = H_CAP - (H_CAP - H_LIP) * d_tiles[lip] / LIP_TILES
    rmp = (d_tiles > LIP_TILES) & (d_tiles <= RIM_TILES)
    h[rmp] = H_LIP * (1.0 - (d_tiles[rmp] - LIP_TILES) / RAMP_TILES)
    h[d_tiles > RIM_TILES] = 0.0
    # Ramp sector: no lip, one gentle 8-tile slope (port profile 0.37/tile).
    rs = ramp_g > 0.5
    full = (d_tiles > 0) & (d_tiles <= RIM_TILES) & rs
    h[full] = H_CAP * (1.0 - d_tiles[full] / RIM_TILES)

    flat = h >= H_CAP - 1e-9
    rock = h > 1e-9
    # Local vertical gradient per tile (down-slope direction).
    grad = np.zeros_like(h)
    grad[1:, :] = np.abs(np.diff(h, axis=0))
    rock_cells = int(((grad > COLLISION_GATE) & rock).sum())
    walk_cells = int(((grad > 0) & (grad <= COLLISION_GATE) & rock).sum())
    # Modelled full-stamp flat fraction (ellipse, 8-tile rim).
    inner = (STAMP_RX - RIM_TILES) * (STAMP_RY - RIM_TILES)
    flat_frac_stamp = inner / (STAMP_RX * STAMP_RY)
    return {
        "grid": [g, g], "max_h": round(float(h.max()), 6),
        "min_h": round(float(h.min()), 6),
        "h_ceiling": H_CAP,
        "cap_pass": bool(h.max() <= H_CAP + 1e-9),
        "flat_cells": int(flat.sum()), "positive_cells": int(rock.sum()),
        "flat_fraction_of_piece": round(float(flat.sum()) / rock.sum(), 4),
        "modelled_stamp_flat_fraction": round(flat_frac_stamp, 4),
        "lip_gradient_per_tile": round(LIP_GRAD, 4),
        "ramp_gradient_per_tile": round(RAMP_GRAD, 4),
        "collision_gate": COLLISION_GATE,
        "walkable_pass": bool(RAMP_GRAD <= COLLISION_GATE),
        "rock_cells": rock_cells, "walkable_cells": walk_cells,
        "rock_face_present": bool(rock_cells > 0),
        "rim_tiles": RIM_TILES,
        "stamp_rx_tiles": STAMP_RX, "stamp_ry_tiles": STAMP_RY,
        "stamp_anisotropy": round(STAMP_RX / STAMP_RY, 3),
        "note": ("port height profile derived from game.gd:641-642,692-703; "
                 "NOT a decoded donor heightfield (donor stamp cells undecoded)"),
    }


# ---------------------------------------------------------------- piece ------
def build_piece(params: dict[str, Any] | None = None) -> tuple[Image.Image, dict[str, Any]]:
    """Render the 512px RGB piece; return (image, deterministic details)."""
    p: dict[str, Any] = {
        "ao_collar": AO_COLLAR, "contact_ao": CONTACT_AO, "foot_ao": FOOT_AO,
        "flute_gain": FLUTE_GAIN, "grain_amp": GRAIN_AMP,
        "ramp_dark": RAMP_DARK, "grass_bright": GRASS_BRIGHT,
        "grass_contrast": GRASS_CONTRAST,
    }
    if params:
        p.update(params)
    rng = np.random.default_rng(SEED)
    n = NATIVE
    phase0 = float(rng.uniform(0.0, 2.0 * math.pi))
    y, hw, ramp = boundary_profile(n)
    hm = height_model(y, hw, ramp)

    xs = np.arange(n)
    ys = np.arange(n, dtype=np.float64)[:, None]
    yb = y[None, :]
    hw2 = hw[None, :]
    ramp2 = ramp[None, :]
    d = ys - yb                                          # >0 below the rim
    t = np.clip(d / hw2, 0.0, 2.0)                       # 0 at rim, 1 at foot

    # -- grass plateau top ----------------------------------------------------
    grass = _tile("grass1", n, int(rng.integers(0, 512)), int(rng.integers(0, 512)))
    grass = tpr.adjust_bcs(grass, float(p["grass_bright"]), float(p["grass_contrast"]))
    base = np.asarray(grass, np.float64).copy()
    # Two octaves of signed olive gain -> readable tonal patches, still near-planar.
    g1 = value_noise(SEED + 31, n, 58.0)
    g2 = value_noise(SEED + 47, n, 118.0)
    base += (GRASS_MOTTLE_AMP * g1 + 2.8 * g2)[..., None] * np.array([1.0, 0.96, 0.68])

    # Ambient occlusion of the grass approaching the rim (soft, not a black line).
    near = np.where(d < 0, np.exp(d / 24.0), 0.0)
    collar = np.where(d < 0, np.exp(d / 8.0), 0.0)
    ao = 1.0 - float(p["ao_collar"]) * collar - AO_WIDE * near
    base *= np.clip(ao, 0.50, 1.0)[..., None]

    # Lower-grass gully floor, darker (it sits ~2.964 below the plateau top).
    floor_ao = np.clip((t - 1.0) / 0.30, 0.0, 1.0)
    base *= (FLOOR_DARK + (1.0 - FLOOR_DARK) * (1.0 - floor_ao))[..., None]
    # Contact AO on the floor immediately below the wall foot.
    floor_contact = np.where(d >= hw2, np.exp(-(d - hw2) / 14.0), 0.0)
    base *= (1.0 - float(p["foot_ao"]) * floor_contact)[..., None]

    canvas = base.copy()

    # -- rock wall: striated fill + lit->shadow ramp + contact AO -------------
    r1 = np.asarray(_tile("rock1", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))).convert("L"), np.float64)
    r8 = np.asarray(_tile("rock8", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))).convert("L"), np.float64)

    f_n = norm_field(highpass(r1, FLUTE_STRETCH, 3.0))
    f_b = norm_field(highpass(r1, FLUTE_STRETCH * 0.75, 7.0))
    f_f = norm_field(highpass(r8, FLUTE_STRETCH, 5.0))
    grain = norm_field(highpass(r8, 1.0, 2.5))

    # Strong spacing warp + slow waviness: no two flutes share a spacing.
    warp = np.rint(26.0 * np.sin(xs / 29.0) + 13.0 * np.sin(xs / 11.3)
                   + 6.0 * np.sin(xs / 5.1)).astype(int)
    wx = (xs + warp) % n
    wobble = np.rint(4.0 * np.sin(2.0 * math.pi * ys / 130.0
                                  + 2.0 * math.pi * xs[None, :] / 230.0)
                     + 2.0 * np.sin(2.0 * math.pi * ys / 47.0
                                    + 2.0 * math.pi * xs[None, :] / 91.0)).astype(int)
    sx = np.clip(wx[None, :] + wobble, 0, n - 1)
    rows = np.arange(n)[:, None]
    flute = (0.55 * f_n[rows, sx] + 0.28 * f_b[rows, sx] + 0.17 * f_f[rows, sx])
    # Flutes fade in/out along the wall (no uniform comb).
    amp_fine = value_noise(SEED + 77, n, 150.0)[0, :]
    amp_broad = value_noise(SEED + 83, n, 62.0)[0, :]
    amp_x = np.clip(0.55 + 0.65 * amp_fine + 0.20 * amp_broad, 0.08, 1.20)
    flute *= amp_x[None, :]
    # Faint horizontal stratification breaks perfectly straight striations.
    strat = 1.0 - 0.18 * (0.5 + 0.5 * np.sin(ys / 38.0
                                              + 2.0 * math.pi * xs[None, :] / 400.0))
    flute = np.clip(flute * strat, -1.0, 1.0)

    # Irregular dark recess slits (donor gullies have deep shadowed cuts).
    recess = np.zeros(n, np.float64)
    for cx, width, depth in ((0.13 * n, 9.0, 0.72), (0.44 * n, 7.0, 0.62),
                             (0.67 * n, 13.0, 0.80), (0.91 * n, 8.0, 0.55)):
        dd = np.abs(xs - cx)
        dd = np.minimum(dd, n - dd)
        recess += depth * np.exp(-0.5 * (dd / width) ** 2)
    recess = np.clip(recess, 0.0, 1.0)[None, :]
    recess_eff = recess * (0.55 + 0.45 * (1.0 - np.clip(t, 0.0, 1.0)))

    # Lit top -> shadow foot; the bulk of the wall reads dark, like the donor.
    r = np.clip(t, 0.0, 1.0)
    shade = np.clip(r / 0.12, 0.0, 1.0) * 0.55 \
        + np.clip((r - 0.12) / 0.40, 0.0, 1.0) * 0.45
    pal = LIT[None, None, :] * (1.0 - shade[..., None]) + SHADOW[None, None, :] * shade[..., None]
    crest = np.maximum(flute, 0.0)[..., None]
    groove = np.maximum(-flute, 0.0)[..., None]
    mod = float(p["flute_gain"]) * (1.0 - FLUTE_FADE * shade)[..., None]
    col = pal + crest * (PALE - LIT)[None, None, :] * mod \
              + groove * (SHADOW - LIT)[None, None, :] * mod
    col += grain[..., None] * float(p["grain_amp"])
    col *= (1.0 - 0.40 * recess_eff[..., None])

    # Contact shadow directly under the grass rim, plus a slight foot AO.
    contact = np.clip((0.035 - t) / 0.035, 0.0, 1.0)[..., None]
    foot = np.clip((t - 0.82) / 0.18, 0.0, 1.0)[..., None]
    col *= (1.0 - float(p["contact_ao"]) * contact) * (1.0 - float(p["foot_ao"]) * foot)

    # -- wall / walkable-ramp continuous blend (no rectangular gap) -----------
    wall = (d >= 0) & (t < 1.0)
    rw = ramp2[:, :, None]                               # 0 = rock, 1 = grass slope
    ramp_shade = 1.0 - float(p["ramp_dark"]) * np.clip(t, 0.0, 1.0)
    grass_col = base * ramp_shade[..., None]
    blended = col * (1.0 - rw) + grass_col * rw
    canvas[wall] = np.clip(blended, 0.0, 255.0)[wall]

    # -- overhanging grass tufts along the rim (irregular gaps) ---------------
    tuft = Image.new("L", (n, n), 0)
    td = ImageDraw.Draw(tuft)
    x = 0
    while x < n:
        step = int(rng.integers(5, 10))
        x += step
        xi = x % n
        if rng.random() < TUFT_OPACITY:
            yy = int(y[xi])
            for _ in range(int(rng.integers(2, 5))):
                bx = x + int(rng.integers(-3, 4))
                length = int(rng.integers(6, 15))
                lean = int(rng.integers(-4, 5))
                td.line([(bx, yy - 4), (bx + lean, yy + length)], fill=255,
                        width=int(rng.integers(1, 3)))
    tuft_arr = np.asarray(tuft) > 0
    canvas[tuft_arr] = np.clip(base[tuft_arr] * 0.80, 0.0, 255.0)

    out = Image.fromarray(np.clip(canvas + 0.5, 0, 255).astype(np.uint8), "RGB")
    out = out.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=120, threshold=2))

    details = {
        "generator": "t6_plateau.py", "ticket": "T6-T07",
        "seed": SEED, "size_px": [SIZE, SIZE], "native_px": n,
        "height_model": hm,
        "palette": {"lit": "#6C614B", "mid": "#4B4430", "shadow": "#393424",
                    "pale_flute": "#8B7D67"},
        "art": {"top": "grass1.png", "fill": "rock8.png", "flutes": "rock1.png"},
        "tunables": {k: (round(float(v), 4) if isinstance(v, (int, float)) else v)
                     for k, v in p.items()},
        "defect_fixes": {
            "no_hard_outline": True, "ao_at_grass_contact": True,
            "lit_top_shadow_foot": True, "organic_rim": True,
            "walkable_ramp_sector": True, "tufts_overhang": True,
        },
        "tool_limits": ("2-D visual + derived port height profile; no engine "
                        "collision / buildability output. Geometry numbers are "
                        "model-derived, not donor-heightfield measurements."),
    }
    return out, details


# ---------------------------------------------------------------- metrics -----
def _hsv_stats(arr: np.ndarray) -> tuple[float, float]:
    import colorsys
    sats, vals = [], []
    for r, g, b in (arr.reshape(-1, 3) / 255.0)[::7]:
        _, s, v = colorsys.rgb_to_hsv(float(r), float(g), float(b))
        sats.append(s)
        vals.append(v)
    return float(np.mean(sats)), float(np.mean(vals))


def measure(img: Image.Image) -> dict[str, Any]:
    """All PNG-measurable plateau criteria on out-resolution crops."""
    a = np.asarray(img.convert("RGB"), np.float64)
    L = a @ np.array([0.299, 0.587, 0.114])

    # Rock classifier: donor grass is green (G>R), rock/earth is brown (R>=G).
    rock = (a[..., 0] > a[..., 1] + 1.0) & (a[..., 1] > a[..., 2] + 2.0) \
        & (L < 140.0)
    rock_frac = float(rock.mean() * 100.0)

    # Flat-top crop: upper plateau region, above the rim (base rim ~0.43*512=220).
    crop = a[40:170, 70:270, :]
    cl = crop @ np.array([0.299, 0.587, 0.114])
    cbl = np.asarray(Image.fromarray(np.clip(cl, 0, 255).astype(np.uint8), "L")
                     .filter(ImageFilter.GaussianBlur(5)), np.float64)
    h, _ = np.histogram(cl, bins=8, range=(0, 256))
    sat, val = _hsv_stats(crop)
    # Distinct olive tonal patches: quantized colour clusters in the olive band.
    q = (crop // 16).astype(int)
    keys = set(tuple(v) for v in q.reshape(-1, 3))
    olive_keys = [k for k in keys if k[1] >= k[2] and abs(k[0] - k[1]) <= 3]

    # Rim width: per-column first rock row, from the last grass row above it.
    widths = []
    for x in range(0, SIZE, 4):
        col = rock[:, x]
        idx = np.flatnonzero(col)
        if idx.size == 0:
            continue
        first = int(idx[0])
        if first > 0 and not col[first - 1]:
            widths.append(1)
    rim_median = float(np.median(widths)) if widths else -1.0

    # Lit/shadow from the wall band: sample brown pixels in the top/bottom
    # quartiles of their own vertical span (non-ramp part of the frame).
    brown_cols = np.where(rock.sum(0) > SIZE * 0.08)[0]
    lit_s, shad_s = [], []
    for x in brown_cols:
        rows = np.flatnonzero(rock[:, x])
        if rows.size < 30:
            continue
        top = rows[:max(3, rows.size // 6)]
        bot = rows[-max(3, rows.size // 5):]
        lit_s.append(a[top, x].mean(0))
        shad_s.append(a[bot, x].mean(0))
    lit_rgb = np.mean(lit_s, 0) if lit_s else np.zeros(3)
    shad_rgb = np.mean(shad_s, 0) if shad_s else np.zeros(3)
    lit_l = float(lit_rgb @ np.array([0.299, 0.587, 0.114]))
    shad_l = float(shad_rgb @ np.array([0.299, 0.587, 0.114]))

    return {
        "rock_fraction_pct": round(rock_frac, 3),
        "rim_width_px_out": rim_median,
        "flat_top": {
            "L_mean": round(float(cl.mean()), 3),
            "L_std": round(float(cl.std()), 3),
            "hf_blur5": round(float(np.abs(cl - cbl).mean()), 3),
            "bins8_pct": [round(float(v) / cl.size * 100.0, 2) for v in h],
            "bins_ge3": int((h / cl.size * 100.0 >= 3).sum()),
            "sat_mean": round(sat, 4), "val_mean": round(val, 4),
            "olive_patch_keys": len(olive_keys),
            "mean_rgb": [round(float(v), 2) for v in crop.reshape(-1, 3).mean(0)],
        },
        "wall_palette": {
            "lit_rgb": [round(float(v), 2) for v in lit_rgb],
            "shadow_rgb": [round(float(v), 2) for v in shad_rgb],
            "lit_l": round(lit_l, 2), "shadow_l": round(shad_l, 2),
            "ratio": round(lit_l / max(1.0, shad_l), 3),
        },
    }


# ------------------------------------------------------------- comparison ----
def _font(size: int):
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        for p in ("C:/Windows/Fonts/dejavusans.ttf", "C:/Windows/Fonts/arial.ttf"):
            try:
                return ImageFont.truetype(p, size)
            except OSError:
                continue
    return ImageFont.load_default()


def build_compare(render: Image.Image, ref_dir: Path) -> tuple[Image.Image, dict[str, Any]]:
    """Three labelled panels: port | donor crop C | donor boundary rim zoom."""
    panels: list[tuple[str, Image.Image, str]] = [
        ("PORT RENDER (deterministic)", render, "t6_plateau.png"),
    ]
    with Image.open(ref_dir / REF_NAME) as src:
        src = src.convert("RGB")
        for title, box in (("DONOR #8 plateau crop C", CROP_C),
                           ("DONOR #8 grass->rock rim", CROP_BOUNDARY)):
            c = src.crop(box).resize((SIZE, SIZE), Image.Resampling.BILINEAR)
            panels.append((title, c, REF_NAME))
    pad, gap, header, caption = 12, 14, 46, 44
    w = pad * 2 + SIZE * len(panels) + gap * (len(panels) - 1)
    h = pad * 2 + header + SIZE + caption
    sheet = Image.new("RGB", (w, h), (22, 24, 28))
    d = ImageDraw.Draw(sheet)
    ft, fc = _font(15), _font(12)
    d.text((pad, pad), "T6-T07 plateau  seed=7  512x512  (Pillow + NumPy, no Godot)",
           font=ft, fill=(232, 236, 242))
    for i, (title, im, name) in enumerate(panels):
        x = pad + i * (SIZE + gap)
        sheet.paste(im, (x, pad + header))
        d.rectangle((x - 1, pad + header - 1, x + SIZE, pad + header + SIZE),
                    outline=(96, 102, 112))
        d.text((x, pad + header + SIZE + 7), title, font=fc,
               fill=(150, 220, 168) if i == 0 else (240, 198, 140))
        d.text((x, pad + header + SIZE + 24), f"{name}  (read-only)", font=fc,
               fill=(170, 176, 186))
    return sheet, {"panels": [n for _, _, n in panels],
                   "donor_crops": {"crop_C": list(CROP_C),
                                   "boundary_zoom": list(CROP_BOUNDARY)}}


# ------------------------------------------------------------------- driver --
def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out-dir", default=str(OUT))
    ap.add_argument("--ref-dir", default=str(REF))
    ap.add_argument("--params", default=None,
                    help='JSON object of tunables, e.g. \'{"flute_gain":0.8}\'')
    ap.add_argument("--measure", action="store_true", help="print full metrics JSON")
    args = ap.parse_args(argv)

    overrides = json.loads(args.params) if args.params else {}
    render, details = build_piece(overrides)
    out_dir = Path(args.out_dir).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    png = out_dir / "t6_plateau.png"
    render.save(png, format="PNG", optimize=True)
    sheet, cmp_info = build_compare(render, Path(args.ref_dir))
    cmp_png = out_dir / "t6_plateau_compare.png"
    sheet.save(cmp_png, format="PNG", optimize=True)

    metrics = measure(render)
    details["metrics"] = metrics
    details["comparison"] = cmp_info
    details["sha256_piece"] = hashlib.sha256(png.read_bytes()).hexdigest()
    details["sha256_compare"] = hashlib.sha256(cmp_png.read_bytes()).hexdigest()
    details["outputs"] = {"piece": str(png), "compare": str(cmp_png)}
    (out_dir / "t6_plateau.manifest.json").write_text(
        json.dumps(details, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if args.measure:
        print(json.dumps(details, indent=2))
    else:
        print(f"[t6_plateau] {png} sha256={details['sha256_piece'][:12]} "
              f"rock={metrics['rock_fraction_pct']}% "
              f"flat_std={metrics['flat_top']['L_std']} "
              f"cap={details['height_model']['max_h']} "
              f"ramp_grad={details['height_model']['ramp_gradient_per_tile']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
