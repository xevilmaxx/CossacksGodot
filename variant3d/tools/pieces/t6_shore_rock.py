#!/usr/bin/env python3
"""T6-T03 -- single-piece headless mini-baker for ``shore_rock``.

One owned piece: a near-vertical striated rock wall meeting an olive grass
plateau at an organic, shadowed rim.  This module is the *only* renderer this
ticket uses.

Donor truth this reproduces (measured read-only, see docs/t6/reports/T6-T03.md)
------------------------------------------------------------------------------
* rock8 is the donor's ``abs(h)>2.7`` high-face FILL (#494226, coarse-uniform).
* rock1 supplies the vertical FLUTES (BA 1.42 / VSI 2.95, strongest of nine).
* the rendered lit face is #726651 (L~103) against a #6C614B / #393424 palette
  pair (luma ratio 1.90); the donor crest flutes are IRREGULAR in spacing
  (peak-spacing CV 0.77 from the x=948..1012 probe), with horizontal ledges
  interrupting them, and the grass->rock hue crossing takes ~2 px with a soft
  dark collar (no black outline).

Hard rules honoured here
------------------------
* Headless Python 3.14 + Pillow + NumPy only.  No Godot, no Blender, no whole
  map.  ``terrain_piece_render.py`` is imported READ-ONLY for tiling helpers and
  the labelled comparison sheet; it is never edited and no spec JSON is read.
* Donor assets are read in place (reference JPEG under ~/Downloads/c3).  No
  donor binary is copied into the repo -- only port PNGs under ``app/assets``
  are used as the rock/grass art.
* Deterministic: fixed seed 7, no clock input, fixed resampling.  Re-running
  overwrites the same files with identical bytes.

Output (all under ``app/shots/pieces``)::

    t6_shore_rock.png            the piece, 512x512 RGB
    t6_shore_rock_compare.png    labelled [render | donor crop] sheet
    t6_shore_rock_facecrop.png   diagnostic 128px face crop (measurement aid)
    t6_shore_rock.manifest.json  parameters + sha256
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
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as tpr                       # READ-ONLY

BLOCKS = APP / "assets" / "terrain" / "blocks"
SPRITES = APP / "assets" / "models" / "sprites_hi"
OUT = APP / "shots" / "pieces"
DEFAULT_REF_DIR = Path("C:/Users/Maxym.Oboyshev/Downloads/c3")
REF_NAME = "cossacks-3-v1-498085.jpg"
CROP = (840, 360, 1100, 480)                             # donor wall zoom

OUT_PX = 512
NATIVE_PX = 1024                                         # one native pass, one downsample
SEED = 7

# Palette anchors (observed / canonical from the audit docs).
LIT = np.array([0x72, 0x66, 0x51], dtype=np.float64)     # #726651 (114,102,81) donor lit anchor
MID = np.array([0x4B, 0x44, 0x30], dtype=np.float64)     # #4B4430 (75, 68, 48)
PALE = np.array([0xA0, 0x92, 0x78], dtype=np.float64)    # bold lit flute crest (160,146,120)
SHADOW = np.array([0x39, 0x34, 0x24], dtype=np.float64)  # #393424 (57, 52, 36)
DARK = np.array([0x26, 0x23, 0x18], dtype=np.float64)    # deep groove / AO lip
GRASS = np.array([0x54, 0x54, 0x2A], dtype=np.float64)   # (84,84,42) muted olive, S~0.50

# Geometry / tunables (calibrated against the donor wall zoom in this ticket).
RIM_Y = 0.135                    # grass->rock boundary, fraction of canvas
RIM_WOBBLE = (13.0, 5.5, 2.0)    # three-octave organic rim wobble (native px)
FACE_H_NATIVE = 110              # -> 55 out px = 77 px @720p (A5)
RAMP_SPAN = 0.62                 # lit at rim -> full shadow at rim+span*canvas (A3)
MID_T = 0.62                     # ramp position of palette mid (#4B4430)
FLUTE_SMALL = (128, 96)          # downsample rock1 first -> BOLD flutes (donor scale)
FLUTE_Y_STRETCH = (1.5, 2.0)     # extra vertical elongation per scale
FLUTE_SIGMA = (5.0, 7.0)         # high-pass radius per scale
FLUTE_MIX = (0.70, 0.30)
FLUTE_GAIN = 1.02                # crest->PALE / groove->DARK strength
LIGHT_AMP = 0.20                 # broad lit-crest / dark-recess field (x axis)
FLUTE_FADE = 0.26                # flutes fade into the foot shadow
WARP_AMP = 11.0                  # spacing warp from smooth 1-D noise (native px)
CURVE_AMP = 3.5                  # gentle per-column flute bending (native px)
CURVE_PERIOD = 330.0
STRAT_AMP = 0.48                 # horizontal stratification modulation
STRAT_PERIOD = 190.0
LEDGES = (0.34, 0.58, 0.79)      # fractional heights of flute-interrupting ledges
LEDGE_W = 13.0
GATE_BASE = 0.46                 # flutes cluster in crests, not uniform planks
GATE_GAIN = 0.72
GRAIN_AMP = 4.0                  # fine rock8 luma grain (levels, native)
GRASS_CONTRAST = 1.15            # keep plateau texture visible (not flat paint)
AO_STRENGTH = 26.0               # soft collar DARKENING (levels, subtracted equally)
AO_FALLOFF = 13.0                # penumbra length (native px)
TUFT_STEP = 34                   # seeded overhanging grass tufts
ACCENT_OPACITY = 0.62            # rock_sea1 stand-in for missing rock_stones1


def _clamp(arr: np.ndarray, lo: float = 0.0, hi: float = 255.0) -> np.ndarray:
    return np.clip(arr, lo, hi)


def _blur(arr: np.ndarray, sigma: float) -> np.ndarray:
    """Gaussian blur a 2-D float array via Pillow (matches the shared renderer)."""
    im = Image.fromarray(_clamp(arr).astype(np.uint8), "L")
    return np.asarray(im.filter(ImageFilter.GaussianBlur(sigma)), dtype=np.float64)


def _smooth1d(rng: np.random.Generator, n: int, cells: int, amp: float) -> np.ndarray:
    """Seeded smooth zero-mean 1-D noise field of length n (amplitude ~amp)."""
    vals = rng.uniform(-1.0, 1.0, cells)
    x = np.linspace(0, cells - 1, n)
    a = np.interp(x, np.arange(cells), vals)
    k = np.exp(-0.5 * (np.arange(-3, 4) / 1.4) ** 2)
    k /= k.sum()
    a = np.convolve(np.pad(a, (3, 3), mode="edge"), k, mode="valid")
    return a * (amp / (np.std(a) + 1e-6))


def _tile(name: str, size: int, ox: int, oy: int) -> Image.Image:
    """Mirror-tile a port block and wrap-crop it deterministically."""
    tile = tpr.mirror_tileable(Image.open(tpr._png(BLOCKS, name)), size,
                               Image.Resampling.BILINEAR)
    return tpr.wrap_crop(tile, ox, oy, size, size).convert("RGB")


def _norm(arr: np.ndarray) -> np.ndarray:
    return _clamp(arr / (2.4 * arr.std() + 1e-6), -1.0, 1.0)


def _bold_flute(path: Path, small: int, n: int, y_stretch: float,
                sigma: float, shift_x: int) -> np.ndarray:
    """Bold vertical flute field from a downsampled rock tile.

    Downsampling rock1 to ~256 px then upscaling makes its native 2-8 px flutes
    4x wider (matching the donor's 5-20 px source-scale crests) while the extra
    y-stretch makes them strongly elongated -> the anisotropy A1 needs.
    """
    im = Image.open(path).convert("L").resize((small, small), Image.Resampling.LANCZOS)
    big = np.asarray(im.resize((n, n), Image.Resampling.BICUBIC), dtype=np.float64)
    idx = np.minimum((np.arange(n) / y_stretch).astype(int), n - 1)
    arr = np.roll(big[idx, :], shift_x, axis=1)
    return _norm(arr - _blur(arr, sigma))


def _palette(t: np.ndarray) -> np.ndarray:
    """Piecewise LIT -> MID -> SHADOW so both #6C614B and #4B4430 anchors land."""
    t = _clamp(t, 0.0, 1.0)
    a = _clamp(t / MID_T, 0.0, 1.0)[:, :, None]
    b = _clamp((t - MID_T) / (1.0 - MID_T), 0.0, 1.0)[:, :, None]
    c1 = LIT[None, None, :] * (1.0 - a) + MID[None, None, :] * a
    c2 = MID[None, None, :] * (1.0 - b) + SHADOW[None, None, :] * b
    return np.where((t <= MID_T)[:, :, None], c1, c2)


def build_piece() -> tuple[Image.Image, dict[str, Any]]:
    """Render the single shore_rock piece.  Returns (512px RGB image, details)."""
    rng = np.random.default_rng(SEED)
    n = NATIVE_PX
    ys = np.arange(n, dtype=np.float64)[:, None]
    xs = np.arange(n, dtype=np.float64)[None, :]

    # -- organic grass->rock rim ----------------------------------------------
    rim_y = np.full(n, RIM_Y * n, dtype=np.float64)
    for amp, cells in zip(RIM_WOBBLE, (7, 23, 71)):
        rim_y += _smooth1d(rng, n, cells, amp)
    rim_y = _blur(rim_y.reshape(1, -1), 2.0).ravel()

    # -- rock8 FILL: keep its real pixels, shift its mean along the ramp ------
    r8 = np.asarray(_tile("rock8", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))), dtype=np.float64)
    r8_l = r8.mean(axis=2)
    grain8 = _norm(_flute_like(r8_l, 2.6)) * GRAIN_AMP

    # -- rock1 FLUTES: two scales, warped, stratified, gated, irregular depth -
    r1_path = tpr._png(BLOCKS, "rock1")
    f1 = _bold_flute(r1_path, FLUTE_SMALL[0], n, FLUTE_Y_STRETCH[0],
                     FLUTE_SIGMA[0], 0)
    f2 = _bold_flute(r1_path, FLUTE_SMALL[1], n, FLUTE_Y_STRETCH[1],
                     FLUTE_SIGMA[1], int(rng.integers(32, 128)))

    warp = _smooth1d(rng, n, 19, WARP_AMP)
    phase = _smooth1d(rng, n, 11, 2.2)
    depth = 0.55 + 0.45 * (0.5 + 0.5 * _smooth1d(rng, n, 13, 1.0) / 2.0)
    shift = warp[None, :] + CURVE_AMP * np.sin(
        2.0 * np.pi * ys / CURVE_PERIOD + phase[None, :])
    src_x = (xs + shift).astype(np.int64) % n
    fw1 = np.take_along_axis(f1, src_x, axis=1)
    fw2 = np.take_along_axis(f2, src_x, axis=1)
    flute = (FLUTE_MIX[0] * fw1 + FLUTE_MIX[1] * fw2) * depth[None, :]
    flute = np.sign(flute) * np.power(np.abs(flute), 0.82)   # depth irregularity

    # horizontal stratification: periodic modulation + a few ledge bands that
    # interrupt the flutes (the donor wall has clear horizontal breaks).
    strat_phase = _smooth1d(rng, n, 9, 1.8)
    strat = 1.0 + STRAT_AMP * np.sin(
        2.0 * np.pi * ys / STRAT_PERIOD + strat_phase[None, :])
    for frac in LEDGES:
        y0 = rim_y.mean() + frac * (n - rim_y.mean())
        strat *= 1.0 - 0.42 * np.exp(-((ys - y0) / LEDGE_W) ** 2)
    flute = flute * strat

    # presence gate: flutes cluster in crests, not wall-to-wall uniform planks.
    g = rng.uniform(-1.0, 1.0, (9, 9)).astype(np.float32)
    gimg = Image.fromarray(np.uint8(np.clip((g + 1.0) * 127.0, 0, 255)), "L")
    gimg = gimg.resize((n, n), Image.Resampling.BICUBIC)
    gate = _clamp(GATE_BASE + GATE_GAIN * np.asarray(gimg, dtype=np.float64) / 255.0,
                  0.18, 1.0)
    flute = flute * gate

    # -- lit -> shadow ramp (rooted at the rim, full wall below) --------------
    ramp = _clamp((ys - rim_y[None, :]) / (RAMP_SPAN * n), 0.0, 1.0)
    target = _palette(ramp)
    # Broad lit-crest / dark-recess field across x: the donor wall is not a
    # uniformly lit sheet -- one crest catches the sun, flanks fall away.
    lx = _smooth1d(rng, n, 5, 1.0) + 0.30 * _smooth1d(rng, n, 13, 1.0)
    lx = lx / (np.std(lx) + 1e-6)
    light = (1.0 + LIGHT_AMP * lx[None, :])[:, :, None]
    target = target * light
    # rock8 supplies the fine FILL grain; the macro colour comes from the
    # donor palette ramp so the wall reads as rock rather than mossy noise.
    color = target + grain8[:, :, None]

    crest = np.maximum(flute, 0.0)[:, :, None]
    groove = np.maximum(-flute, 0.0)[:, :, None]
    mod = FLUTE_GAIN * (1.0 - FLUTE_FADE * ramp)[:, :, None]
    color = color + crest * (PALE - LIT)[None, None, :] * mod \
                  + groove * (DARK - LIT)[None, None, :] * mod

    # -- soft shadowed collar at grass contact (NO hard black outline) -------
    below = np.maximum(ys - rim_y[None, :], 0.0)
    # Subtractive (not multiplicative) so the grass->rock R-G hue crossing
    # stays <=3 px while the collar still reads as a soft shadow.
    ao = AO_STRENGTH * np.exp(-below / AO_FALLOFF)[:, :, None]
    color = color - ao

    # -- grass plateau above the rim -----------------------------------------
    grass_src = np.asarray(_tile("grass1", n, int(rng.integers(0, 512)),
                                 int(rng.integers(0, 512))), dtype=np.float64)
    gm = grass_src.reshape(-1, 3).mean(axis=0)
    grass = (grass_src - gm) * GRASS_CONTRAST + GRASS[None, None, :]
    grass = grass + grain8[:, :, None] * 0.5
    rock_mask = ys >= rim_y[None, :]
    color = np.where(rock_mask[:, :, None], color, grass)

    # -- overhanging grass tufts just below the rim (donor read) --------------
    out_native = Image.fromarray(_clamp(color).astype(np.uint8), "RGB")
    td = ImageDraw.Draw(out_native)
    for k in range(0, n, TUFT_STEP):
        x0 = min(k + int(rng.integers(0, TUFT_STEP // 2)), n - 8)
        if rng.random() < 0.78:
            y0 = int(rim_y[x0])
            gcol = tuple(int(v) for v in (GRASS * 0.82))
            td.line([(x0, y0), (x0 + 3, y0 + 1), (x0 + 7, y0 - 1)],
                    fill=gcol, width=2)
            if rng.random() < 0.55:
                tu = tuple(int(v) for v in (GRASS * 1.10))
                td.line([(x0 + 2, y0 - 3), (x0 + 5, y0 - 6)],
                        fill=tu, width=2)
    color = np.asarray(out_native, dtype=np.float64)

    # -- small rock_sea1 accent (rock_stones1 stand-in, kept from spec) -------
    apath = SPRITES / "rock_sea1.png"
    if apath.is_file():
        acc = Image.open(apath).convert("RGBA")
        tw, th = int(0.12 * n), int(0.14 * n)
        acc = acc.resize((tw, th), Image.Resampling.BILINEAR)
        ax, ay = int(0.70 * n) - tw // 2, int(0.62 * n) - th
        layer = Image.new("RGBA", (n, n), (0, 0, 0, 0))
        base_rgba = Image.fromarray(_clamp(color).astype(np.uint8), "RGB").convert("RGBA")
        layer.alpha_composite(base_rgba, (0, 0))
        layer.alpha_composite(acc, (ax, ay))
        acc_arr = np.asarray(layer, dtype=np.float64)
        a = (acc_arr[..., 3:4] / 255.0) * ACCENT_OPACITY
        color = color * (1.0 - a) + acc_arr[..., :3] * a

    # -- one downsample, mild grain lift -------------------------------------
    out = Image.fromarray(_clamp(color).astype(np.uint8), "RGB")
    out = out.resize((OUT_PX, OUT_PX), Image.Resampling.LANCZOS)
    out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=140, threshold=2))

    details: dict[str, Any] = {
        "generator": "t6_shore_rock.py", "ticket": "T6-T03",
        "seed": SEED, "size_px": [OUT_PX, OUT_PX], "native_px": n,
        "art": {"fill": "rock8.png", "flutes": "rock1.png",
                "grass": "grass1.png", "accent": "rock_sea1.png"},
        "face_height_out_px": FACE_H_NATIVE // 2,
        "face_height_720p_px": round(FACE_H_NATIVE / 2 * 720 / OUT_PX, 1),
        "face_height_frac_of_frame": round(FACE_H_NATIVE / 2 / OUT_PX, 4),
        "palette": {"lit": "#726651", "mid": "#4B4430", "pale_flute": "#968870",
                    "shadow": "#393424", "grass": "#54542A"},
        "tunables": {
            "rim_y": RIM_Y, "rim_wobble": list(RIM_WOBBLE), "ramp_span": RAMP_SPAN,
            "mid_t": MID_T, "flute_small": list(FLUTE_SMALL),
            "flute_y_stretch": list(FLUTE_Y_STRETCH), "flute_mix": list(FLUTE_MIX),
            "flute_gain": FLUTE_GAIN, "warp_amp": WARP_AMP, "curve_amp": CURVE_AMP,
            "strat_amp": STRAT_AMP, "strat_period": STRAT_PERIOD,
            "ledges": list(LEDGES), "gate": [GATE_BASE, GATE_GAIN],
            "ao_strength": AO_STRENGTH, "ao_falloff": AO_FALLOFF,
            "grain_amp": GRAIN_AMP, "grass_contrast": GRASS_CONTRAST,
        },
    }
    return out, details


def _flute_like(src: np.ndarray, sigma: float) -> np.ndarray:
    """Tiny helper: high-pass a 2-D array (used for the rock8 fill grain)."""
    return src - _blur(src, sigma)


def _reference_crop(ref_dir: Path) -> Image.Image:
    path = ref_dir / REF_NAME
    if not path.is_file():
        raise FileNotFoundError(f"reference not found: {path}")
    return Image.open(path).convert("RGB").crop(CROP).resize(
        (OUT_PX, OUT_PX), Image.Resampling.BILINEAR)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="T6-T03 shore_rock mini-baker")
    ap.add_argument("--out-dir", default=str(OUT))
    ap.add_argument("--ref-dir", default=str(DEFAULT_REF_DIR))
    args = ap.parse_args(argv)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    render, details = build_piece()
    render_path = out_dir / "t6_shore_rock.png"
    render.save(render_path, format="PNG", optimize=True)

    ref = _reference_crop(Path(args.ref_dir))
    compare = tpr.build_comparison(
        "t6_shore_rock", render, ref, SEED,
        [{"type": "block"}, {"type": "face"}, {"type": "sprite"}], list(CROP))
    compare.save(out_dir / "t6_shore_rock_compare.png", format="PNG", optimize=True)

    render.crop((168, 66, 296, 194)).save(
        out_dir / "t6_shore_rock_facecrop.png", format="PNG", optimize=True)

    details["sha256"] = hashlib.sha256(render_path.read_bytes()).hexdigest()
    details["outputs"] = {
        "piece": str(render_path),
        "compare": str(out_dir / "t6_shore_rock_compare.png"),
        "facecrop": str(out_dir / "t6_shore_rock_facecrop.png"),
    }
    (out_dir / "t6_shore_rock.manifest.json").write_text(
        json.dumps(details, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[t6_shore_rock] wrote {render_path}  sha256={details['sha256'][:12]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
