#!/usr/bin/env python3
"""T6-T05 -- single-piece headless mini-baker for ``ravine_face`` (R3 rebuild).

Donor-faithful redesign after the coordinator's binding intervention: the face
is NO LONGER a constant-height zigzag extrusion.  It is a winding gully with two
organically irregular walls, irregular-width/depth vertical flutes, a soft
ambient-occlusion collar on the grass (no drawn black contour) and a lit-top /
shadowed-bottom ramp with contact occlusion.

Headless Python 3.14 + Pillow + NumPy only.  No Godot.  ``terrain_piece_render``
is imported READ-ONLY for tiling helpers and the labelled comparison sheet.
Deterministic: seed 7.  Every output PNG carries the executing module version
and source hash in its metadata, and the manifest repeats both, so a stale
pipeline can be ruled out by inspecting the file itself.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import random
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageFilter
from PIL.PngImagePlugin import PngInfo

TOOLS = Path(__file__).resolve().parent.parent
APP = TOOLS.parent
ROOT = APP.parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as tpr                       # READ-ONLY

BLOCKS = APP / "assets" / "terrain" / "blocks"
OUT = APP / "shots" / "pieces"
DEFAULT_REF_DIR = Path("C:/Users/Maxym.Oboyshev/Downloads/c3")
REF_NAME = "cossacks-3-v1-498085.jpg"
CROP_A = (560, 150, 1000, 560)

OUT_PX = 512
NATIVE_PX = 1024
SEED = 7
MODULE_VERSION = "T6T05-R3-ORGULLY-20261123"
SOURCE_HASH = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()

# Palette anchors (docs/audit/PIECES/ravine_face.md §1.2).
LIT = np.array([0x6C, 0x61, 0x4B], dtype=np.float64)     # #6C614B
MID = np.array([0x4B, 0x44, 0x30], dtype=np.float64)     # #4B4430
SHADOW = np.array([0x39, 0x34, 0x24], dtype=np.float64)  # #393424
PALE = np.array([0x8B, 0x7D, 0x67], dtype=np.float64)    # #8B7D67

# Gully geometry (fractions of the native canvas).
GULLY_AMP = 0.10           # winding amplitude of the centreline
FLOOR_HW = 0.018           # dark recess half-width
WALL_W = 0.060             # width of each lit / shadow wall
EDGE_RAG = 3.5             # ragged (not smooth) wall outer edges

# Face texture + shading.
FLUTE_GAIN = 0.75          # lit wall crest/groove amplitude
SHADOW_GAIN = 1.50         # shadow flutes fainter than lit, but still legible
FLUTE_PERIOD = 9.0         # native px, varies 9..20 with y
GRAIN_AMP = 11.0
VERTICAL_GRADE = 0.10      # darker toward the bottom of the frame
CONTACT_AO = 0.12          # soft occlusion at the grass/floor contacts
GRASS_AO = 0.22            # soft collar on grass (NO black contour)
GRASS_MOTTLE = 7.0
GRASS_BRIGHT = 1.02
GRASS_CONTRAST = 1.10


def _clamp(a: np.ndarray, lo: float, hi: float) -> np.ndarray:
    return np.clip(a, lo, hi)


def _blur(a: np.ndarray, sigma: float) -> np.ndarray:
    im = Image.fromarray(_clamp(a, 0, 255).astype(np.uint8), "L")
    return np.asarray(im.filter(ImageFilter.GaussianBlur(sigma)), dtype=np.float64)


def _smooth1d(vals: list[float], n: int, sigma: float) -> np.ndarray:
    arr = np.interp(np.linspace(0, len(vals) - 1, n), np.arange(len(vals)),
                    np.asarray(vals, dtype=np.float64))
    k = np.exp(-0.5 * (np.arange(-3 * sigma, 3 * sigma + 1) / sigma) ** 2)
    k /= k.sum()
    return np.convolve(np.pad(arr, (len(k) // 2, len(k) // 2), mode="edge"),
                       k, mode="valid")


def _tile(name: str, size: int, ox: int, oy: int) -> Image.Image:
    path = tpr._png(BLOCKS, name)
    tile = tpr.mirror_tileable(Image.open(path), size, Image.Resampling.BILINEAR)
    return tpr.wrap_crop(tile, ox, oy, size, size).convert("RGB")


def _png_info() -> PngInfo:
    """Embed the executing code identity in every written PNG."""
    info = PngInfo()
    info.add_text("T6T05-module-version", MODULE_VERSION)
    info.add_text("T6T05-source-sha256", SOURCE_HASH)
    info.add_text("T6T05-method", "winding gully, irregular flutes, soft AO collar")
    return info


def build_piece() -> tuple[Image.Image, dict[str, Any]]:
    rng = np.random.default_rng(SEED)
    pyrng = random.Random(SEED)
    n = NATIVE_PX
    x = np.arange(n, dtype=np.float64)[None, :]
    y = np.arange(n, dtype=np.float64)[:, None]

    # -- grass plateau with subtle tonal mottling ----------------------------
    grass = _tile("grass1", n, int(rng.integers(0, 512)), int(rng.integers(0, 512)))
    grass = tpr.adjust_bcs(grass, GRASS_BRIGHT, GRASS_CONTRAST)
    grass_arr = np.asarray(grass, dtype=np.float64).copy()
    small = np.array([[pyrng.randrange(256) for _ in range(24)] for _ in range(24)],
                     dtype=np.uint8)
    mf = np.asarray(Image.fromarray(small, "L").resize(
        (n, n), Image.Resampling.BILINEAR).filter(ImageFilter.GaussianBlur(12)),
        dtype=np.float64)
    grass_arr = _clamp(grass_arr + ((mf - 128) / 128 * GRASS_MOTTLE)[:, :, None]
                       * np.array([1.0, 0.98, 0.68]), 0, 255)

    # -- winding gully geometry: NO polyline, NO constant width --------------
    cx = (0.50 * n
          + GULLY_AMP * n * np.sin(2 * np.pi * 1.15 * y / n + 0.6)
          + 0.045 * n * _smooth1d([pyrng.uniform(-1, 1) for _ in range(9)],
                                  n, 70)[:, None])
    fw = FLOOR_HW * n * (0.80 + 0.40 * (0.5 + 0.5 * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(9)], n, 55)[:, None]))
    wl = WALL_W * n * (0.85 + 0.30 * (0.5 + 0.5 * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(9)], n, 60)[:, None]))
    wr = WALL_W * n * (0.85 + 0.30 * (0.5 + 0.5 * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(9)], n, 60)[:, None]))
    # Ragged outer edges: the donor's rim is irregular, not a smooth curve.
    lo = cx - fw - wl + EDGE_RAG * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(25)], n, 14)[:, None]
    ro = cx + fw + wr + EDGE_RAG * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(25)], n, 14)[:, None]
    li, ri = cx - fw, cx + fw
    left = (x >= lo) & (x < li)
    right = (x > ri) & (x <= ro)
    floor = (x >= li) & (x <= ri)
    u_left = _clamp((x - lo) / wl, 0.0, 1.0)             # 0 grass -> 1 floor
    u_right = _clamp((ro - x) / wr, 0.0, 1.0)             # 0 grass -> 1 floor

    # -- irregular flutes: spacing, width and depth all vary ----------------
    r1 = np.asarray(_tile("rock1", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))).convert("L"), dtype=np.float64)
    r8 = np.asarray(_tile("rock8", n, int(rng.integers(0, 512)),
                          int(rng.integers(0, 512))).convert("L"), dtype=np.float64)
    warp = (_blur(r1, 18.0) - 128.0) / 128.0           # 2-D low-freq warp
    per = FLUTE_PERIOD * (1.0 + 1.2 * (0.5 + 0.5 * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(11)], n, 48)[:, None]))
    phase = 2.0 * np.pi * _smooth1d(
        [pyrng.uniform(-1, 1) for _ in range(7)], n, 80)[:, None]
    strata = 0.45 + 0.55 * (0.5 + 0.5 * np.sin(
        y / 40.0 + phase + warp * 1.5))                # horizontal stratification
    s_left = x - lo + 9.0 * warp                       # warped across-wall coord
    s_right = ro - x + 9.0 * warp
    p_l = s_left / per + phase * 0.15
    p_r = s_right / per + phase * 0.20
    # two incommensurate harmonics -> non-uniform flute spacing AND width
    wave_l = 0.62 * np.sin(2 * np.pi * p_l) \
             + 0.38 * np.sin(2 * np.pi * 1.73 * p_l + phase)
    wave_r = 0.62 * np.sin(2 * np.pi * p_r) \
             + 0.38 * np.sin(2 * np.pi * 1.61 * p_r + phase * 1.3)
    tex = r1 - _blur(r1, 3.0)
    tex /= 2.4 * tex.std() + 1e-6
    grain = r8 - _blur(r8, 2.5)
    grain /= 2.4 * grain.std() + 1e-6
    flute_l = _clamp(0.62 * wave_l * strata + 0.38 * tex, -1.0, 1.0)
    flute_r = _clamp(0.62 * wave_r * strata + 0.38 * tex, -1.0, 1.0)

    grade = 1.0 - VERTICAL_GRADE * y / n             # lit-top -> darker foot

    def shade(u: np.ndarray, flute: np.ndarray, top: np.ndarray,
              bottom: np.ndarray, crest_col: np.ndarray,
              groove_col: np.ndarray, gain: float) -> np.ndarray:
        base = top[None, None, :] * (1.0 - u[:, :, None]) \
               + bottom[None, None, :] * u[:, :, None]
        crest = np.maximum(flute, 0.0)[:, :, None]
        groove = np.maximum(-flute, 0.0)[:, :, None]
        base = base + crest * (crest_col - top)[None, None, :] * gain \
                    + groove * (groove_col - bottom)[None, None, :] * gain
        base = base + grain[:, :, None] * GRAIN_AMP * grade[:, :, None]
        contact = np.clip((0.06 - u) / 0.06, 0.0, 1.0)[:, :, None]
        base = base * (1.0 - CONTACT_AO * contact)
        return _clamp(base * grade[:, :, None], 0, 255)

    # clear lit / shadow separation: lit crests -> PALE, shadow stays dark
    left_rgb = shade(u_left, flute_l, LIT * 1.12, MID, PALE,
                     SHADOW * 0.90, FLUTE_GAIN)
    right_rgb = shade(u_right, flute_r, SHADOW * 1.30, SHADOW * 0.85,
                      PALE * 0.85, SHADOW * 0.40, SHADOW_GAIN)

    # -- soft grass-contact collar (NO black contour) -----------------------
    dg = np.minimum(np.maximum(0.0, lo - x), np.maximum(0.0, x - ro))
    ao = np.exp(-dg / 7.0)
    canvas = grass_arr * (1.0 - GRASS_AO * ao[:, :, None])

    # dark gully recess with occlusion toward both wall feet
    floor_rgb = SHADOW * 0.72 + grain[:, :, None] * 1.5
    canvas[floor] = _clamp(floor_rgb, 0, 255)[floor]
    canvas[left] = left_rgb[left]
    canvas[right] = right_rgb[right]

    # -- one downsample, mild grain lift -------------------------------------
    out = Image.fromarray(_clamp(canvas, 0, 255).astype(np.uint8), "RGB")
    out = out.resize((OUT_PX, OUT_PX), Image.Resampling.LANCZOS)
    out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=150, threshold=2))

    details = {
        "generator": "t6_ravine_face.py", "module_version": MODULE_VERSION,
        "source_sha256": SOURCE_HASH, "seed": SEED,
        "size_px": [OUT_PX, OUT_PX], "native_px": n,
        "geometry": "winding gully, two irregular walls, dark recess; no polyline",
        "gully_amplitude": GULLY_AMP, "floor_half_width": FLOOR_HW,
        "wall_width": WALL_W, "flute_gain": FLUTE_GAIN,
        "grass_ao_collar": GRASS_AO, "contact_ao": CONTACT_AO,
        "vertical_grade": VERTICAL_GRADE,
        "palette": {"lit": "#6C614B", "mid": "#4B4430", "shadow": "#393424",
                    "pale_flute": "#8B7D67"},
        "art": {"grass": "grass1.png", "fill": "rock8.png", "flutes": "rock1.png"},
    }
    return out, details


def _reference_crop(ref_dir: Path) -> Image.Image:
    path = ref_dir / REF_NAME
    if not path.is_file():
        raise FileNotFoundError(f"reference not found: {path}")
    return Image.open(path).convert("RGB").crop(CROP_A).resize(
        (OUT_PX, OUT_PX), tpr.RESAMPLE)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="T6-T05 ravine_face mini-baker R3")
    ap.add_argument("--out-dir", default=str(OUT))
    ap.add_argument("--ref-dir", default=str(DEFAULT_REF_DIR))
    args = ap.parse_args(argv)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    render, details = build_piece()
    info = _png_info()
    render_path = out_dir / "t6_ravine_face.png"
    render.save(render_path, format="PNG", optimize=True, pnginfo=info)

    ref = _reference_crop(Path(args.ref_dir))
    compare = tpr.build_comparison(
        "t6_ravine_face", render, ref, SEED,
        [{"type": "block"}, {"type": "face"}], list(CROP_A))
    compare.save(out_dir / "t6_ravine_face_compare.png", format="PNG",
                 optimize=True, pnginfo=info)

    face_crop = render.crop((150, 40, 360, 472))
    face_crop.save(out_dir / "t6_ravine_face_facecrop.png", format="PNG",
                   optimize=True, pnginfo=info)

    details["sha256"] = hashlib.sha256(render_path.read_bytes()).hexdigest()
    details["outputs"] = {
        "piece": str(render_path),
        "compare": str(out_dir / "t6_ravine_face_compare.png"),
        "facecrop": str(out_dir / "t6_ravine_face_facecrop.png"),
    }
    (out_dir / "t6_ravine_face.manifest.json").write_text(
        json.dumps(details, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[t6_ravine_face] version={MODULE_VERSION} src={SOURCE_HASH[:12]} "
          f"sha256={details['sha256'][:12]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
