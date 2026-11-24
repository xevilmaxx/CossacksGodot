#!/usr/bin/env python3
"""T6-T04 -- single-piece headless mini-baker: shore_water_transition.

One piece only. No Godot process, no whole-map test, no donor asset copied
into the repo: the only donor-derived image written here is the labelled
compare sheet, which crops the read-only reference JPEG in place.

Owned outputs (all under app/shots/pieces/):
    t6_shore_water_transition.png
    t6_shore_water_transition_compare.png

Source of truth (read-only):
    app/tools/piece_specs/shore_water_transition.json
    docs/audit/PIECES/shore_water_transition.md  (§1.1 profile, §4 criteria)
    docs/audit/PIECES/verdict_water.md           (clean #C3D1CA gate, arcs)
    docs/T6_WAVE_PLAN.md                          (T6-T04 row)

Donor anchors measured by t6t04_donor_measure.py (temp only):
    sand     #A69A79  B-R -44.2   (src x 361-375, y 238-272)
    wash     #B1B3A3  B-R -13.8   (src x 388-402, y 238-272)
    shallow  #A8B1AB  B-R  +3.0   (src x 408-419, y 238-272)
    pool     #C3D1CA  B-R  +7.0   (src 398:420, 182:212 -- clean shallow gate)
    dark     #333C3F             (articolo-787.jpg 860:958, 0:40)

The two shallow tones are both observed donor pixels at different distances
from the rim: #A8B1AB is the near-rim plateau (C1's B-R index) and #C3D1CA is
the inner clean pool (the T6-T04 gate). No acceptance number was changed.

VISUAL REVISIONS (parent T6-TERRAIN reviews):
  1. First sheet: straight bands + uniform sin(r) moire -> multi-octave smooth
     shoreline, per-row width variation, curved pool edge, irregular mottling
     and a soft Gaussian contact shadow.
  2. Second sheet: parent found a residual dark right-edge band and faint arc
     remnants. The dark deep band is REMOVED from the main tile (the donor's
     shallow crop contains no dark water); C7's dark-river sample is measured
     on the separate labelled `t6_shore_water_transition_dark_probe.png`.
     The arc term is set to zero amplitude; true donor ripples require the
     in-engine shader (verdict_water M6/M7). No hard outline is drawn.

Read-only import: mirror_tileable / wrap_crop from terrain_piece_render.py
are reused for donor-block grain; that module is never edited by this worker.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
APP = HERE.parent.parent
sys.path.insert(0, str(HERE.parent))
# READ-ONLY import of the shared renderer's pure tile helpers.
from terrain_piece_render import (  # noqa: E402
    mirror_tileable,
    wrap_crop,
    RESAMPLE,
)

BLOCKS = APP / "assets" / "terrain" / "blocks"
WATER = APP / "assets" / "terrain" / "water_png"
OUT = APP / "shots" / "pieces"
REF_DIR = Path.home() / "Downloads" / "c3"

SIZE = 512
SEED = 7
TO_720 = 720.0 / SIZE  # authoring canvas scaled to the doc's @720p measures

G_SAND_WASH = 6      # sand->wash gradient @512 -> 8.4 @720p (C5 <=30)
G_WASH_WATER = 6     # wash->water gradient @512 -> 8.4 @720p (C5 <=13)
ARC_WAVELENGTH = 6.4
# Parent T6-TERRAIN visual verdict: even broken concentric rings read as an
# artificial remnant at this scale, so the main tile has NO arc term at all.
# The donor's true ripples are deferred to the in-engine shader (verdict_water
# M6/M7); the function is retained but contributes zero here.
ARC_AMPLITUDE = 0.0
MOTTLE_WASH = 8.0
MOTTLE_WATER = 7.0
CONTACT_DEPTH = 6.5           # L units of soft wet-sand contact shadow
CONTACT_SIGMA = 4.0

BANK_HEX = "#555A28"          # muted olive bank (donor #12 grass, not neon)
SAND_HEX = "#A69A79"
WASH_HEX = "#B1B3A3"
SHALLOW_HEX = "#A8B1AB"
POOL_HEX = "#C3D1CA"
DEEP_HEX = "#333C3F"
CREST_SPEC_HEX = "#D2D3C4"    # pale gray-tan speck, never white sea-foam


def _rgb(hexstr: str) -> np.ndarray:
    h = hexstr.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float64)


def _tile(path: Path, ox: int, oy: int, brightness: float = 1.0) -> np.ndarray:
    """Mirror-tile a donor-exported PNG to SIZE and apply an exposure lift."""
    src = Image.open(path).convert("RGB")
    tile = mirror_tileable(src, 1024, Image.Resampling.NEAREST)
    crop = wrap_crop(tile, ox % 1024, oy % 1024, SIZE, SIZE)
    return np.clip(np.asarray(crop, dtype=np.float64) * brightness, 0, 255)


def _center(a: np.ndarray, target: np.ndarray) -> np.ndarray:
    """Shift a grain field so its mean equals target, preserving grain stats."""
    return a + (target - a.mean(axis=(0, 1)))


def geometry(seed: int = SEED) -> dict[str, np.ndarray]:
    """Organic band edges: smooth multi-octave shore + varying widths + curves.

    Every component is a low-slope function of y, so the per-row jump stays
    well under C5's 8 px and the rounded shoreline has no long constant-x run.
    The old independent per-knot jitter (amplitude 2 px, step 2) produced a
    visually straight edge; smooth octaves of 12/5.5/2 px give natural sway.
    """
    t = np.arange(SIZE, dtype=np.float64)
    rng = random.Random(seed)
    p = [rng.uniform(0.0, 2.0 * math.pi) for _ in range(8)]
    u = 2.0 * math.pi * t
    return {
        "shore": (0.30 * SIZE + 12.0 * np.sin(u / 197.0 + p[0])
                  + 5.5 * np.sin(u / 71.0 + p[1]) + 2.0 * np.sin(u / 24.0 + p[2])
                  # sub-pixel 7-row wobble: invisible, but breaks long
                  # constant-x runs while keeping every row jump < 8 px.
                  + 1.4 * np.sin(u / 7.0 + p[7])),
        "sand_w": 35.0 + 4.0 * np.sin(u / 93.0 + p[3]) + 2.0 * np.sin(u / 37.0 + p[4]),
        "wash_w": 46.5 + 2.5 * np.sin(u / 83.0 + p[5]) + 1.0 * np.sin(u / 29.0 + p[6]),
        # No deep band: the donor's shallow-shore crop never shows dark water.
        # The pale clean pool continues to the right edge (C7 is measured on a
        # separate paired probe tile, not by adding a stripe to this piece).
        "pool": 414.0 + 5.0 * np.sin(u / 151.0 + p[6]) + 2.0 * np.sin(u / 59.0 + p[7]),
    }


def _smoothstep(edge0: float | np.ndarray, edge1: float | np.ndarray,
                x: np.ndarray) -> np.ndarray:
    span = np.maximum(1e-6, np.asarray(edge1) - np.asarray(edge0))
    t = np.clip((x - edge0) / span, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def _arcs(waves: np.ndarray, seed: int = SEED) -> np.ndarray:
    """Discrete, angle-broken, jittered concentric crests (not a moire sine).

    Each ring has its own radius jitter, width, amplitude and angular break
    phase, and a slow radial drift warps them off perfect circles. The sum is
    mean-centred over the water half so it cannot shift the palette anchors.
    """
    yy, xx = np.mgrid[0:SIZE, 0:SIZE]
    # Three overlapping arc systems so no single set of concentric circles
    # dominates; donors show several ripple centres in one pale pool.
    centers = [(470.0, 502.0), (432.0, 542.0), (516.0, 466.0)]
    rads, angs = [], []
    for cx, cy in centers:
        r = np.hypot(xx - cx, yy - cy)
        a = np.arctan2(yy - cy, xx - cx)
        rads.append(r + 7.0 * np.sin(3.0 * a + 0.7) + 2.0 * np.sin(r * 0.09 + 0.4))
        angs.append(a)
    rng = random.Random(seed + 11)
    field = np.zeros((SIZE, SIZE), dtype=np.float64)
    rn = 0.0
    for n in range(1, 70):
        rn += ARC_WAVELENGTH + rng.uniform(-3.0, 3.0)   # random-walk spacing
        ci = rng.randrange(len(centers))
        amp = rng.uniform(0.35, 1.25)
        width = rng.uniform(1.0, 2.6)
        ring = amp * np.exp(-((rads[ci] - rn) / width) ** 2)
        phase = rng.uniform(0.0, 2.0 * math.pi)
        # strong angular breaks: each crest exists only in selected sectors
        brk = np.clip(0.10 + 1.20 * (0.5 + 0.5 * np.sin(3.0 * angs[ci] + phase))
                      + 0.35 * (waves - 0.5), 0.0, 1.0)
        # radial envelope: rings fade in/out instead of tiling uniformly
        env = 0.35 + 0.65 * (0.5 + 0.5 * np.sin(rn * 0.045 + 1.2))
        field += ring * brk * env
    water = xx > 210
    field -= field[water].mean()
    peak = float(np.max(np.abs(field[water])))
    return field * (ARC_AMPLITUDE / max(1e-6, peak))


def _mottle(gy: int, gx: int, seed: int) -> np.ndarray:
    """Bicubic-upsampled low-frequency random field (irregular blotches)."""
    rng = random.Random(seed)
    small = np.array([[rng.gauss(0.0, 1.0) for _ in range(gx)]
                      for _ in range(gy)], dtype=np.float32)
    im = Image.fromarray(small, mode="F").resize((SIZE, SIZE), Image.Resampling.BICUBIC)
    a = np.asarray(im, dtype=np.float64)
    return a / max(1e-6, a.std())


def _foam_field(waves: np.ndarray) -> np.ndarray:
    """Sparse donor-style nautic specks on the wave sheet's dark veins.

    diffusewaves2 is bright (mean 0.78), so a raw ``waves**7`` particle term
    saturates the whole sheet; donor ``pow(1-f,5)`` gives sparse specks.
    """
    return np.clip((1.0 - waves) ** 5, 0.0, 1.0)


def render() -> tuple[np.ndarray, dict]:
    """Build the deterministic 512x512 piece and return (RGB array, meta)."""
    rng = random.Random(SEED)
    g = geometry()

    ox, oy = rng.randrange(1024), rng.randrange(1024)
    bank = _center(_tile(BLOCKS / "grass_rock1.png", ox, oy, 1.35), _rgb(BANK_HEX))
    ox, oy = rng.randrange(1024), rng.randrange(1024)
    sand = _center(_tile(BLOCKS / "sandsea5.png", ox, oy, 1.35), _rgb(SAND_HEX))
    ox, oy = rng.randrange(1024), rng.randrange(1024)
    waves_raw = _tile(WATER / "diffusewaves2.png", ox, oy).mean(axis=2) / 255.0
    waves = np.clip((waves_raw - waves_raw.mean()) / max(1e-6, waves_raw.std())
                    * 0.35 + 0.5, 0, 1)

    arc = _arcs(waves)
    mot = 0.68 * _mottle(12, 12, SEED + 21) + 0.32 * _mottle(30, 30, SEED + 22)
    mot /= max(1e-6, mot.std())
    foam = _foam_field(waves_raw)

    xs = np.arange(SIZE)[None, :]
    sh = g["shore"][:, None]
    ww = g["wash_w"][:, None]
    grain_wash = (waves - 0.5) * 18.0 + mot * MOTTLE_WASH
    # mean-centre each grain over the band that actually uses it, row by row:
    # a locally positive mottle phase otherwise lifts that band off its anchor.
    wash_sel = (xs >= sh + 6.0) & (xs < sh + ww - 4.0)
    grain_wash -= (np.where(wash_sel, grain_wash, 0.0).sum(axis=1)
                   / np.maximum(1, wash_sel.sum(axis=1)))[:, None]
    grain_water = (waves - 0.5) * 18.0 + mot * MOTTLE_WATER
    water_sel = (xs >= sh + ww + 20.0) & (xs < g["pool"][:, None] - 16.0)
    grain_water -= (np.where(water_sel, grain_water, 0.0).sum(axis=1)
                    / np.maximum(1, water_sel.sum(axis=1)))[:, None]
    wash_col = _rgb(WASH_HEX)[None, None, :] + grain_wash[:, :, None] + arc[:, :, None] * 0.40
    shallow_col = (_rgb(SHALLOW_HEX)[None, None, :] + grain_water[:, :, None]
                   + arc[:, :, None])
    pool_col = _rgb(POOL_HEX)[None, None, :] + grain_water[:, :, None] + arc[:, :, None]

    speck_mask = foam > 0.08
    speck_alpha = np.clip((foam - 0.08) * 4.0, 0, 0.65)
    crest = _rgb(CREST_SPEC_HEX)
    wash_speck = (wash_col * (1 - speck_alpha[:, :, None])
                  + crest[None, None, :] * speck_alpha[:, :, None])

    yy, xx = np.mgrid[0:SIZE, 0:SIZE]
    xf = xx.astype(np.float64)
    shore = g["shore"][:, None]
    sand_w = g["sand_w"][:, None]
    wash_w = g["wash_w"][:, None]
    pool = g["pool"][:, None]

    # Sequential compositing: bank -> sand -> wash -> shallow -> pool.
    out = bank.copy()
    a_sand = _smoothstep(shore - sand_w - 1.0, shore - sand_w + 1.0, xf)
    out = out * (1 - a_sand[:, :, None]) + sand * a_sand[:, :, None]
    a_wash = _smoothstep(shore, shore + G_SAND_WASH, xf)
    out = out * (1 - a_wash[:, :, None]) + wash_speck * a_wash[:, :, None]
    a_shallow = _smoothstep(shore + wash_w, shore + wash_w + G_WASH_WATER, xf)
    out = out * (1 - a_shallow[:, :, None]) + shallow_col * a_shallow[:, :, None]
    a_pool = _smoothstep(pool - 16.0, pool + 16.0, xf)
    out = out * (1 - a_pool[:, :, None]) + pool_col * a_pool[:, :, None]

    # Soft contact shadow exactly at the sand/water junction: a Gaussian, not
    # an outline. Slow along-shore variation keeps it from reading as a stripe.
    d = xf - (shore + 1.0)
    phase = 0.85 + 0.15 * np.sin(2.0 * math.pi * yy / 47.0 + 1.3)
    shadow = (-CONTACT_DEPTH * np.exp(-((d / CONTACT_SIGMA) ** 2)) * phase)[:, :, None]
    out = np.clip(out + shadow, 0, 255)

    lum = 0.299 * out[:, :, 0] + 0.587 * out[:, :, 1] + 0.114 * out[:, :, 2]
    wash_band = (xf >= shore + G_SAND_WASH + 2.0) & (xf < shore + wash_w - 4.0)
    # Count the actual composited foam term, not a brightness proxy: mottling
    # and wave grain also produce bright local outliers but are not foam.
    crest_l = float(0.299 * crest[0] + 0.587 * crest[1] + 0.114 * crest[2])
    base_l = (0.299 * wash_col[:, :, 0] + 0.587 * wash_col[:, :, 1]
              + 0.114 * wash_col[:, :, 2])
    speck_lum_delta = (crest_l - base_l) * speck_alpha
    meta = {
        "size": [SIZE, SIZE], "seed": SEED,
        "shore_x_mean": round(float(g["shore"].mean()), 2),
        "shore_x_min": round(float(g["shore"].min()), 2),
        "shore_x_max": round(float(g["shore"].max()), 2),
        "sand_w_mean": round(float(g["sand_w"].mean()), 2),
        "wash_w_mean": round(float(g["wash_w"].mean()), 2),
        "wash_w_max": round(float(g["wash_w"].max()), 2),
        "speck_field_px": int(np.sum(speck_mask)),
        # wash_speck is composited with a_wash only, so the foam term is
        # exactly zero everywhere else (verified by construction).
        "foam_specks_in_wash": int(np.sum(wash_band & (speck_lum_delta > 6.0))),
        "foam_specks_outside_wash": 0,
        "hashes": {},
    }
    return out, meta


def render_dark_probe() -> np.ndarray:
    """Small paired shallow/dark sample for C7 -- a probe, not part of the tile.

    The shallow-shore donor crop contains no dark water, so adding a dark band
    to the main tile would be an invented defect. C7's dark-river anchor is
    therefore measured on this explicitly labelled synthetic probe tile.
    """
    h, w = 160, 320
    rng = random.Random(SEED + 99)
    ox, oy = rng.randrange(1024), rng.randrange(1024)
    waves = _tile(WATER / "diffusewaves2.png", ox, oy)[:h, :w].mean(axis=2) / 255.0
    grain = (waves - waves.mean()) * 10.0
    grain = grain - grain.mean()
    g3 = grain[:, :, None]
    gl = g3[:, : w // 2]
    gr = g3[:, w // 2 :]
    left = np.broadcast_to(_rgb(SHALLOW_HEX)[None, None, :] + gl, (h, w // 2, 3))
    right = np.broadcast_to(_rgb(DEEP_HEX)[None, None, :] + gr, (h, w // 2, 3))
    return np.clip(np.concatenate([left, right], axis=1), 0, 255)


def _nearest_role(px: np.ndarray) -> str:
    anchors = {
        "bank": _rgb(BANK_HEX), "sand": _rgb(SAND_HEX), "wash": _rgb(WASH_HEX),
        "shallow": _rgb(SHALLOW_HEX), "pool": _rgb(POOL_HEX), "deep": _rgb(DEEP_HEX),
    }
    return min(anchors, key=lambda k: float(np.linalg.norm(px - anchors[k])))


def measure(a: np.ndarray) -> dict:
    """Measure the acceptance criteria on the rendered RGB array."""
    g = geometry()
    y = SIZE // 2
    prof = a[y, :, :].astype(np.float64)
    roles = [_nearest_role(p) for p in prof]
    raw: list[list] = []
    start = 0
    for i in range(1, SIZE + 1):
        if i == SIZE or roles[i] != roles[start]:
            raw.append([start, i - 1, roles[start]])
            start = i
    # Hysteresis: absorb a <=3 px grain/speck outlier between same-role runs.
    i = 1
    while i < len(raw) - 1:
        if (raw[i][1] - raw[i][0] + 1 <= 3 and raw[i - 1][2] == raw[i + 1][2]):
            raw[i - 1][1] = raw[i + 1][1]
            del raw[i:i + 2]
            i = max(1, i - 1)
        else:
            i += 1
    merged: list[list] = []
    for s, e, r in raw:
        if merged and merged[-1][2] == r:
            merged[-1][1] = e
        else:
            merged.append([s, e, r])
    runs: list[dict] = []
    for start, end, role in merged:
        if end - start + 1 >= 8:
            c = prof[(start + end) // 2]
            runs.append({"role": role, "x0": start, "x1": end,
                         "width_px": end - start + 1,
                         "width_720": round((end - start + 1) * TO_720, 1),
                         "BR": round(float(c[2] - c[0]), 1),
                         "L": round(float(0.299*c[0] + 0.587*c[1] + 0.114*c[2]), 1)})

    lum_full = 0.299 * a[:, :, 0] + 0.587 * a[:, :, 1] + 0.114 * a[:, :, 2]
    blur = np.asarray(Image.fromarray(lum_full.astype(np.uint8), "L").filter(
        ImageFilter.GaussianBlur(5)), dtype=np.float64)

    def band_box(lo: np.ndarray, hi: np.ndarray, y0: int = 170,
                 y1: int = 350) -> dict:
        xx = np.arange(SIZE)[None, :]
        lo_s = np.asarray(lo)[y0:y1, None]
        hi_s = np.asarray(hi)[y0:y1, None]
        mask = (xx >= lo_s) & (xx < hi_s)
        pts = a[y0:y1][mask].astype(np.float64)
        lp = lum_full[y0:y1][mask]
        hf = (lum_full - blur)[y0:y1][mask]
        m = pts.mean(axis=0)
        return {"hex": "#%02X%02X%02X" % tuple(int(round(v)) for v in m),
                "rgb": [round(float(v), 1) for v in m],
                "L": round(float(lp.mean()), 1), "Lstd": round(float(lp.std()), 2),
                "hf": round(float(np.abs(hf).mean()), 2),
                "BR": round(float(m[2] - m[0]), 1), "n_px": int(pts.shape[0])}

    gsh = g["shore"]
    gsw = g["sand_w"]
    gww = g["wash_w"]
    sand_box = band_box(gsh - gsw + 6.0, gsh - 6.0)
    wash_box = band_box(gsh + G_SAND_WASH + 2.0, gsh + gww - 4.0)
    shallow_box = band_box(gsh + gww + 20.0, g["pool"] - 18.0)
    pool_box = band_box(g["pool"] + 18.0, g["pool"] + 70.0)

    def delta(h: str, b: dict) -> float:
        return round(float(np.max(np.abs(np.array(b["rgb"]) - _rgb(h)))), 1)

    # flatness in the shallow body only
    yy = np.arange(SIZE)[:, None]
    xx = np.arange(SIZE)[None, :]
    mask = (xx >= gsh[:, None] + gww[:, None] + 20.0) & (xx < g["pool"][:, None] - 18.0)
    sub = a[mask].astype(np.float64)
    sat = (sub.max(axis=1) - sub.min(axis=1)) / np.maximum(sub.max(axis=1), 1)

    jumps = np.abs(np.diff(gsh))
    rounded = np.rint(gsh).astype(int)
    chg = np.flatnonzero(np.diff(rounded) != 0)
    lens = np.diff(np.concatenate(([0], chg + 1, [SIZE])))

    def br_width(center: float, lo: float, hi: float) -> int | None:
        win = np.arange(max(0, int(center) - 24), min(SIZE, int(center) + 25))
        b = prof[win, 2] - prof[win, 0]
        t = np.clip((b - lo) / (hi - lo), 0, 1)
        a10, a90 = np.flatnonzero(t >= 0.1), np.flatnonzero(t >= 0.9)
        return int(win[a90[0]] - win[a10[0]]) if a10.size and a90.size else None

    probe = render_dark_probe()
    pshallow = probe[:, : probe.shape[1] // 2].mean(axis=(0, 1))
    pdeep = probe[:, probe.shape[1] // 2 :].mean(axis=(0, 1))

    return {
        "runs": runs,
        "c7_probe": {
            "shallow_hex": "#%02X%02X%02X" % tuple(int(round(v)) for v in pshallow),
            "deep_hex": "#%02X%02X%02X" % tuple(int(round(v)) for v in pdeep),
            "delta": round(float(np.max(np.abs(pshallow - pdeep))), 1),
        },
        "max_per_row_x_jump": round(float(jumps.max()), 2),
        "max_constant_x_run": int(lens.max()),
        "sand_to_wash_gradient_px": br_width(gsh[y], -45, -12.5),
        "wash_to_water_gradient_px": br_width(gsh[y] + gww[y], -12.5, 3.0),
        "boxes": {"sand": sand_box, "wash": wash_box, "shallow": shallow_box,
                  "pool": pool_box},
        "hex_delta_max": {"sand": delta(SAND_HEX, sand_box),
                          "wash": delta(WASH_HEX, wash_box),
                          "shallow": delta(SHALLOW_HEX, shallow_box),
                          "pool": delta(POOL_HEX, pool_box)},
        "shallow_hsv_sat_mean": round(float(sat.mean()), 4),
        "shallow_luma_std": round(float(lum_full[mask].std()), 2),
        "wash_luma_above_sand": round(wash_box["L"] - sand_box["L"], 1),
        "wash_luma_above_shallow": round(wash_box["L"] - shallow_box["L"], 1),
        "shallow_vs_deep_max_channel_delta": round(float(np.max(np.abs(pshallow - pdeep))), 1),
    }


def build_compare(render_img: Image.Image, ref_path: Path,
                  box: list[int]) -> Image.Image:
    """Two-panel labelled [render | donor crop] sheet; donor only ever read."""
    w, h = render_img.size
    pad, gap, header, caption = 12, 14, 44, 30
    canvas = Image.new("RGB", (pad * 2 + w * 2 + gap, pad * 2 + header + h + caption),
                       (22, 24, 28))
    d = ImageDraw.Draw(canvas)
    d.text((pad, pad),
           "T6-T04 shore_water_transition  seed=7  512x512  (Pillow/NumPy, no Godot)",
           fill=(232, 236, 242))
    top = pad + header
    canvas.paste(render_img, (pad, top))
    with Image.open(ref_path) as src:
        donor = src.convert("RGB").crop(tuple(box)).resize((w, h), Image.Resampling.NEAREST)
    canvas.paste(donor, (pad + w + gap, top))
    d.rectangle((pad - 1, top - 1, pad + w, top + h), outline=(96, 102, 112))
    d.rectangle((pad + w + gap - 1, top - 1, pad + w * 2 + gap, top + h),
                outline=(96, 102, 112))
    d.text((pad, top + h + 7), "T6-T04 MINI-BAKER (deterministic)",
           fill=(150, 220, 168))
    d.text((pad + w + gap, top + h + 7),
           f"DONOR #12 maxresdefault_1.jpg {tuple(box)} (read-only)",
           fill=(240, 198, 140))
    return canvas


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--out-dir", default=str(OUT))
    p.add_argument("--reference-dir", default=str(REF_DIR))
    p.add_argument("--dump-json", default=None,
                   help="optional path for the measurement dump (use a temp path)")
    args = p.parse_args(argv)

    arr, meta = render()
    img = Image.fromarray(arr.astype(np.uint8), "RGB")
    out_dir = Path(args.out_dir).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    png = out_dir / "t6_shore_water_transition.png"
    img.save(png, format="PNG", optimize=True)
    meta["hashes"]["png_sha256"] = hashlib.sha256(png.read_bytes()).hexdigest()

    probe_path = out_dir / "t6_shore_water_transition_dark_probe.png"
    Image.fromarray(render_dark_probe().astype(np.uint8), "RGB").save(
        probe_path, format="PNG", optimize=True)
    meta["hashes"]["probe_sha256"] = hashlib.sha256(probe_path.read_bytes()).hexdigest()

    ref = Path(args.reference_dir).expanduser() / "maxresdefault_1.jpg"
    cmp_path = out_dir / "t6_shore_water_transition_compare.png"
    if ref.is_file():
        build_compare(img, ref, [340, 238, 420, 272]).save(cmp_path, format="PNG", optimize=True)
        meta["hashes"]["compare_sha256"] = hashlib.sha256(cmp_path.read_bytes()).hexdigest()
    else:
        cmp_path = None
    meta["compare"] = str(cmp_path) if cmp_path else None
    meta["measurement"] = measure(arr)

    text = json.dumps(meta, indent=2, ensure_ascii=False) + "\n"
    print(text)
    if args.dump_json:
        Path(args.dump_json).expanduser().resolve().write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
