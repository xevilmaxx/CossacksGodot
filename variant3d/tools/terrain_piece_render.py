#!/usr/bin/env python3
"""Headless, deterministic Pillow renderer for single Cossacks 3 terrain pieces.

No Godot process is launched. No donor/binary asset is copied into the repo:
only PNGs already exported under ``app/assets`` are read, and the optional
reference JPEG is read in place from the read-only reference directory.

Usage (from anywhere)::

    python app/tools/terrain_piece_render.py --spec app/tools/piece_specs/shore_sand.json
    python app/tools/terrain_piece_render.py --spec app/tools/piece_specs
    python app/tools/terrain_piece_render.py --spec a.json b.json --out-dir /tmp/pieces

Outputs (default ``app/shots/pieces``)::

    <name>.png               rendered piece, RGB, size_px
    <name>.manifest.json     what was drawn + sha256 of the PNG
    <name>_compare.png       only when ``reference`` is present and read OK:
                             labelled [render | donor crop] comparison tile

SPEC SCHEMA (copy this)::

    {
      "name": "shore_sand",
      "size_px": [512, 512],
      "seed": 7,
      "background": [40, 44, 48],
      "bands": {"seed": 7, "direction": "down", "origin": 0.5,
                "jitter_px": 10, "step_px": 6,
                "sand": [26, 51], "wash": [30, 50]},
      "layers": [
        {"type": "block", "name": "grass_rock1", "opacity": 1.0, "tile": true},
        {"type": "block", "name": "sandsea3", "mask": "band", "band": "sand",
         "rect": [0.0, 0.0, 1.0, 0.62], "feather_px": 6, "contour": true},
        {"type": "sprite", "name": "bush1", "pos": [0.6, 0.4],
         "scale": 1.0, "source": "hi", "anchor": "foot"},
        {"type": "water", "sheet": "diffusewaves2", "mode": "wash",
         "band": "wash", "opacity": 0.85, "feather_px": 4},
        {"type": "water", "sheet": "diffusewaves2", "mode": "foam",
         "band": "wash", "intensity": 0.9, "opacity": 0.9},
        {"type": "water", "sheet": "diffusewaves2", "mode": "shallow",
         "band": "water", "opacity": 0.8}
      ],
      "reference": {"image": "cossacks-3-v1-498085.jpg",
                    "box": [560, 150, 1000, 560]}
    }

Every field above except ``name``/``size_px``/``layers`` is OPTIONAL and
backward compatible: old specs (no ``bands``, no mask/stretch keys) render
byte-identically to before.

Spec-level controls
-------------------
native_render   true / int factor (default false): render the whole piece at
                ``size_px * factor`` (1024² for a 512² piece) and downsample
                only once at final output. Restores donor-scale grain.
resample        "bilinear" (default) | "nearest" | "lanczos" | "box": source
                resampling for mirror tiles; "nearest" keeps native grain.
final_resample  "lanczos" (default) | "box" | "bilinear": the single downsample
                used when ``native_render`` is on.
grain_lift      0..1 (default 0): UnsharpMask percent after the final resize.

Layer fields
------------
block
    name        stem of ``assets/terrain/blocks/<name>.png`` (required).
    tile        true (default): mirror-tileable like world.gd::_mirror_tileable,
                then seamless wrap-crop. false: resize the whole image to canvas.
    offset      [px, px] wrap offset (default [0, 0]).
    jitter_px   deterministic seeded jitter radius for the offset (default 0).
    scale       tile scale multiplier (default 1.0).
    opacity     0..1 (default 1.0).
    contrast    block grain lift, matches world.gd adjust_bcs(1.0, 1.12, 1.0)
                (default 1.12).
    brightness  real exposure multiplier (default 1.0) in adjust_bcs; replaces
                the old olive-water-tint "sun lift" proxy.
    rect        [u0, v0, u1, v1] normalised rectangular mask (default full).
                Several block layers may now stack, each with its own
                rect/band mask, e.g. a sandsea rim over a grass base.
    feather_px  Gaussian soft edge on that mask (default 0).
    mask        "rect" (default when rect present) or "band" (use the shared
                ``bands`` geometry so a second block becomes a coastal band).
    band        "sand" | "wash" | "water" segment of ``bands`` (default:
                inferred from ``mask``/``mode`` when ``bands`` is present).
    contour     true -> hard (≤3 px) dark rim on the mask contour instead of
                a tile-grid feather; suppresses stair-step edges. Optional
                "contour_strength" (default 0.75).
    opacity_mask
                per-pixel alpha instead of flat global alpha. Object/string:
                {"type":"luminance","low":0,"high":1,"invert":false},
                {"type":"gradient","direction":"down"|"up"|"left"|"right"},
                {"type":"grid","grid":[[...],...]}. Multiplies with ``opacity``.
                Available on block / sprite / water / patches / face.

sprite
    name        stem of the sprite PNG (required).
    source      "hi" (default) -> models/sprites_hi, fallback models/sprites,
                terrain/deco_png. "low" -> sprites first. "deco" -> deco_png.
                "auto" -> hi, low, deco. "block"/"blocks" -> terrain/blocks
                (used for face skins, e.g. rock1 flutes over a rock8 fill).
    pos         [u, v] normalised canvas position (default [0.5, 0.5]).
    anchor      "foot" (default) puts the bottom-centre of the sprite's visible
                (alpha) ink at pos; "center" centres the whole image;
                "topleft"/"raw" uses pos as the top-left corner.
    scale       size multiplier (default 1.0).
    stretch     [sx, sy] target footprint as a fraction of the canvas
                (e.g. [0.6, 0.7]); overrides ``scale`` when present.
    tile        true -> mirror-tile the sprite to fill the stretched footprint
                (face-skin mode) instead of a single plain resize.
    jitter_px   deterministic seeded [x, y] jitter radius (default 0).
    opacity     0..1 (default 1.0).

water
    sheet       stem of ``assets/terrain/water_png/<sheet>.png`` (required).
    mode        "shallow" (0.10,0.24,0.24), "deep" (0.00,0.025,0.05),
                "coast" (0.18,0.32,0.34), "wash" (pale #BDBDA9/#C3D1CA),
                "foam" (near-white specks), or an explicit "tint": [r,g,b]
                in 0..1. Body colour follows shaders/water_overlay.gdshader:
                col = tint * (0.80 + 0.40 * wave_greyscale).
    rect        [u0, v0, u1, v1] normalised region to cover (default full).
    feather_px  Gaussian soft edge on the region mask (default 0).
    band        "sand" | "wash" | "water" from the shared ``bands`` geometry.
    intensity   foam only: speck brightness multiplier (default 1.0).
                "speck_scale" tunes the coarse/fine speck frequencies.
    offset / jitter_px / scale / opacity
                same meaning as for block layers.

bands (spec-level, shared by all layers that set ``band``)
    seed        deterministic geometry seed; default = spec ``seed``.
    direction   "down" (default) | "up" | "left" | "right": which way the
                shoreline progresses from land to water.
    origin      shoreline position along that axis, 0..1 (default 0.5).
    jitter_px   shoreline wobble amplitude (default 8).
    step_px     polygon vertex spacing, clamped to <=8 so no constant-x (or
                constant-y) run exceeds 8 px (default 6).
    sand        [min, max] sand band width in px (default [26, 51]).
    wash        [min, max] wash band width in px (default [30, 50]).

patches (masked gain layer; mirrors world.gd:998-1046 coverage-grid compositor)
    type        "patches".
    seed        deterministic patch driver seed (default 0).
    patch_px    patch size in px, or [min,max] picked by seed (default [20,80]).
    grid        optional explicit N×N coverage grid (values -1..1); if absent
                a seeded random terrain driver is generated.
    gain        ± luminance gain amplitude (default 30 -> ±25..35 L band).
    olive_weights
                [wr,wg,wb] RGB gain weights (default [1.0,0.96,0.68]) so the
                gain is olive, not neutral grey.
    cover       "full" | "positive": whether the gain/optional block is gated
                to the bright half of the patch field. Default "full" without
                ``name``, "positive" with it.
    name        optional block stem composited through the patch mask.
    hard_rim    true -> binary patches with a <=3 px contour cut.
    rect / opacity_mask / opacity / contour_strength
                compose with the patch field.

face (height-step / ravine / plateau face; 2D height proxy)
    type        "face".
    geometry    {"kind":"polyline","points":[[u,v],...],"height_px":N} or
                {"kind":"height","cells":9,"threshold":0.55}.
    fill        block stem for the fill (default "rock8").
    flutes      block stem for vertical striations (default "rock1"; null
                disables). Mirrors the rock arbitration verdict.
    stretch     vertical stretch of both tiles (default 2.0).
    rim_px      hard contour rim width 1..3 (default 3); ``contour`` defaults
                to true for faces.
    lit/shadow  colours (hex "#RRGGBB" or [r,g,b] 0..1); defaults
                #6C614B / #393424.
    ramp_gain   lit-to-shadow luminance delta in L (default 22).
    rect / opacity_mask / opacity
                compose with the face mask.

glaze (winter luminance-masked cool tint)
    type        "glaze".
    tint        [r,g,b] 0..1 multiplier (default [0.80,0.88,1.0]).
    white_floor L threshold (default 246) above which pixels are forced to
                exact #FFFFFF while lower pixels receive the cool tint. This
                is how ≥25% exact white and ≥80% B>=R can coexist.
    strength    0..1 glaze weight (default 0.35).

reference
    image       filename inside the reference directory (read-only).
    box         [left, top, right, bottom] pixel crop of that image.
    The reference directory defaults to ``~/Downloads/c3`` and can be
    overridden with ``--reference-dir`` or the ``C3_REFERENCE_DIR`` env var.

TOOL LIMIT: coast-band foam and wash are *diffuse* approximations of the
donor shader (nautic/particles specks, no time scroll). True sun-linked
specular glints (pow(170)/pow(120) highlights) are NOT reproducible here and
still require an in-engine capture; do not use these verdicts to close a
water_glints / water_shallow build ticket. ``face`` and ``patches`` are 2D
height/gain proxies: there is no real height channel, no collision and no
buildability output, so geometry criteria still need a map-dump verifier.
Glaze preserves exact white but readers must measure B>=R themselves.

Determinism: fixed resampling (BILINEAR, matching Godot's
Image.INTERPOLATE_BILINEAR), no clock/time input, one random.Random(seed)
shared by all layers in spec order (band geometry uses ``bands.seed``),
stable PNG bytes and a sha256 in the manifest. Re-running a spec overwrites
the same files with identical bytes.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import re
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent
ROOT = APP.parent
ASSETS = APP / "assets"
BLOCKS_DIR = ASSETS / "terrain" / "blocks"
WATER_DIR = ASSETS / "terrain" / "water_png"
DECO_DIR = ASSETS / "terrain" / "deco_png"
SPRITES_HI_DIR = ASSETS / "models" / "sprites_hi"
SPRITES_DIR = ASSETS / "models" / "sprites"
DEFAULT_OUT_DIR = APP / "shots" / "pieces"
DEFAULT_SPEC_DIR = TOOLS / "piece_specs"

# world.gd normalises every block/wave sheet onto a 1024² wrap tile.
TILE_SIZE = 1024
RESAMPLE = Image.Resampling.BILINEAR
SAFE_NAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]{0,96}$")

WATER_TINTS: dict[str, tuple[float, float, float]] = {
    "shallow": (0.10, 0.24, 0.24),   # water_overlay.gdshader WATERCOLOR
    "deep": (0.00, 0.025, 0.05),     # WATERCOLOR2
    "coast": (0.18, 0.32, 0.34),
    "foam": (0.50, 0.60, 0.70),
}

# Pale wash band: donor #BDBDA9 (dry rim) -> #C3D1CA (wet rim).
WASH_COLORS: tuple[tuple[float, float, float], tuple[float, float, float]] = (
    (0xBD / 255.0, 0xBD / 255.0, 0xA9 / 255.0),
    (0xC3 / 255.0, 0xD1 / 255.0, 0xCA / 255.0),
)
FOAM_COLOR = (0.92, 0.96, 1.00)
VALID_BANDS = ("sand", "wash", "water")
VALID_DIRECTIONS = ("down", "up", "left", "right")
MAX_SHORE_STEP = 8   # hard cap on a constant-x / constant-y boundary run

RESAMPLE_MAP = {
    "bilinear": Image.Resampling.BILINEAR,
    "nearest": Image.Resampling.NEAREST,
    "lanczos": Image.Resampling.LANCZOS,
    "box": Image.Resampling.BOX,
}
# Olive gain: R/G lead, B lags -> +L patches stay olive, -L patches stay warm.
OLIVE_GAIN_WEIGHTS = (1.00, 0.96, 0.68)
DEFAULT_LIT = (0x6C / 255.0, 0x61 / 255.0, 0x4B / 255.0)
DEFAULT_SHADOW = (0x39 / 255.0, 0x34 / 255.0, 0x24 / 255.0)


def _log(verbose: bool, message: str) -> None:
    if verbose:
        print("[piece] " + message)


def _clamp255(value: float) -> int:
    return max(0, min(255, int(round(value))))


def _safe_name(value: Any, what: str) -> str:
    """Reject path separators / traversal in asset names coming from JSON."""
    if not isinstance(value, str) or not SAFE_NAME.fullmatch(value) or ".." in value:
        raise ValueError(f"unsafe {what}: {value!r}")
    return value


def _png(directory: Path, name: str) -> Path:
    path = directory / (name + ".png")
    if not path.is_file():
        raise FileNotFoundError(f"missing asset: {path}")
    return path


def _opacity(value: Any, default: float = 1.0) -> float:
    if value is None:
        return default
    op = float(value)
    if not 0.0 <= op <= 1.0:
        raise ValueError(f"opacity out of 0..1: {value!r}")
    return op


def _reference_root(override: str | None) -> Path:
    if override:
        return Path(override).expanduser().resolve()
    env = os.environ.get("C3_REFERENCE_DIR")
    if env:
        return Path(env).expanduser().resolve()
    return (Path.home() / "Downloads" / "c3").resolve()


# ---------------------------------------------------------------------------
# image primitives (Python ports of world.gd helpers)
# ---------------------------------------------------------------------------
def mirror_tileable(src: Image.Image, size: int = TILE_SIZE,
                    resample: int = RESAMPLE) -> Image.Image:
    """Port of world.gd::_mirror_tileable: quarter tile + X/Y/both mirrors.

    Any wrapped crop of the result is seamless, matching the terrain blocks
    and wave sheets the real port feeds to its shaders. ``resample`` may be
    swapped to NEAREST/LANCZOS for the grain-preserving path.
    """
    q = max(1, size // 2)
    a = src.convert("RGB")
    if a.size != (q, q):
        a = a.resize((q, q), resample)
    fh = a.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    fv = a.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
    fb = a.transpose(Image.Transpose.ROTATE_180)
    out = Image.new("RGB", (q * 2, q * 2))
    out.paste(a, (0, 0))
    out.paste(fh, (q, 0))
    out.paste(fv, (0, q))
    out.paste(fb, (q, q))
    if out.size != (size, size):
        out = out.resize((size, size), resample)
    return out


def wrap_crop(src: Image.Image, ox: int, oy: int, w: int, h: int) -> Image.Image:
    """Port of world.gd::_wrap_crop: modular multi-blit seamless crop."""
    n, m = src.size
    ox, oy = ox % n, oy % m
    out = Image.new(src.mode, (w, h))
    x = 0
    while x < w:
        sx = (ox + x) % n
        sw = min(w - x, n - sx)
        y = 0
        while y < h:
            sy = (oy + y) % m
            sh = min(h - y, m - sy)
            out.paste(src.crop((sx, sy, sx + sw, sy + sh)), (x, y))
            y += sh
        x += sw
    return out


def adjust_bcs(im: Image.Image, brightness: float = 1.0, contrast: float = 1.0) -> Image.Image:
    """Port of Godot Image.adjust_bcs (scale around mid-grey, 0..255 clamp).

    Used for the block grain lift: ``adjust_bcs(1.0, 1.12)`` in _block_img().
    """
    if brightness == 1.0 and contrast == 1.0:
        return im
    lut = [_clamp255((((i / 255.0 - 0.5) * contrast + 0.5) * brightness) * 255.0)
           for i in range(256)]
    if im.mode == "RGB":
        return im.point(lut * 3)
    if im.mode == "RGBA":
        return im.point(lut * 3 + [255] * 256)
    return im.point(lut)


def paste_rgba(dest: Image.Image, src: Image.Image, x: int, y: int) -> None:
    """Alpha-composite src onto dest at (x, y), clipping off-canvas pixels."""
    dx0, dy0 = max(0, x), max(0, y)
    dx1 = min(dest.width, x + src.width)
    dy1 = min(dest.height, y + src.height)
    if dx0 >= dx1 or dy0 >= dy1:
        return
    sx0, sy0 = dx0 - x, dy0 - y
    part = src.crop((sx0, sy0, sx0 + (dx1 - dx0), sy0 + (dy1 - dy0)))
    dest.alpha_composite(part, (dx0, dy0))


def _with_opacity(im: Image.Image, op: float,
                  mask: Image.Image | None = None) -> Image.Image:
    """Scalar opacity, optionally multiplied by a per-pixel (L) mask."""
    if mask is None:
        if op >= 1.0:
            return im
        out = im.copy()
        lut = [_clamp255(i * op) for i in range(256)]
        out.putalpha(out.getchannel("A").point(lut))
        return out
    alpha = mask if op >= 1.0 else mask.point([_clamp255(i * op) for i in range(256)])
    out = im.copy()
    out.putalpha(ImageChops.multiply(out.getchannel("A"), alpha))
    return out


def _opacity_mask_for(layer: dict[str, Any], w: int, h: int,
                      canvas: Image.Image | None) -> Image.Image | None:
    """Build the optional per-pixel opacity mask (world.gd coverage-grid idea).

    Returns None for legacy specs, so every original code path stays intact.
    """
    spec = layer.get("opacity_mask")
    if spec is None:
        return None
    if isinstance(spec, str):
        spec = {"type": spec}
    if not isinstance(spec, dict):
        raise ValueError(f"opacity_mask must be an object/string: {spec!r}")
    kind = str(spec.get("type", "luminance")).lower()
    invert = bool(spec.get("invert", False))

    if kind == "luminance":
        base = canvas.convert("L") if canvas is not None else Image.new("L", (w, h), 128)
        lo = float(spec.get("low", 0.0))
        hi = float(spec.get("high", 1.0))
        lut = []
        for i in range(256):
            v = (i / 255.0 - lo) / max(1e-6, hi - lo)
            v = max(0.0, min(1.0, v))
            lut.append(_clamp255((1.0 - v if invert else v) * 255.0))
        return base.point(lut)

    if kind == "gradient":
        direction = str(spec.get("direction", "down")).lower()
        if direction not in VALID_DIRECTIONS:
            raise ValueError(f"bad opacity_mask.direction: {direction!r}")
        ramp = Image.linear_gradient("L").resize((w, h), RESAMPLE)
        if direction == "up":
            ramp = ramp.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        elif direction == "right":
            ramp = ramp.transpose(Image.Transpose.ROTATE_90)
        elif direction == "left":
            ramp = ramp.transpose(Image.Transpose.ROTATE_270)
        return ramp.point([_clamp255(255 - i if invert else i) for i in range(256)])

    if kind == "grid":
        grid = spec.get("grid")
        if not isinstance(grid, (list, tuple)) or not grid:
            raise ValueError("opacity_mask.grid must be a non-empty 2D array")
        return _smooth_field(grid, w, h, RESAMPLE).point(
            [_clamp255(255 - i if invert else i) for i in range(256)])

    raise ValueError(f"unknown opacity_mask type: {kind!r}")


def _offset_for(layer: dict[str, Any], rng: random.Random,
                base_key: str = "offset") -> tuple[int, int]:
    base = layer.get(base_key) or [0, 0]
    ox, oy = float(base[0]), float(base[1])
    jitter = layer.get("jitter_px", 0) or 0
    if isinstance(jitter, (list, tuple)):
        jx, jy = float(jitter[0]), float(jitter[1])
    else:
        jx = jy = float(jitter)
    if jx:
        ox += rng.uniform(-jx, jx)
    if jy:
        oy += rng.uniform(-jy, jy)
    return int(round(ox)), int(round(oy))


def _scaled_tile(src: Image.Image, layer: dict[str, Any]) -> Image.Image:
    """mirror_tile -> brightness/contrast -> optional scale.

    ``brightness`` (default 1.0) is the real exposure control: legacy specs
    are unchanged because adjust_bcs(1.0, contrast) is the old call.
    """
    resample = RESAMPLE_MAP.get(str(layer.get("_resample", "bilinear")).lower(), RESAMPLE)
    tile_size = int(layer.get("_tile_size", TILE_SIZE))
    tile = mirror_tileable(src, tile_size, resample)
    contrast = float(layer.get("contrast", 1.12))
    brightness = float(layer.get("brightness", 1.0))
    if contrast != 1.0 or brightness != 1.0:
        tile = adjust_bcs(tile, brightness, contrast)
    scale = float(layer.get("scale", 1.0))
    if scale <= 0:
        raise ValueError(f"scale must be > 0: {scale!r}")
    if scale != 1.0:
        side = max(1, int(round(tile_size * scale)))
        tile = tile.resize((side, side), resample)
    return tile


# ---------------------------------------------------------------------------
# masks: rect / coast bands / contour / foam
# ---------------------------------------------------------------------------
def _rect_px(rect: Any, w: int, h: int) -> tuple[int, int, int, int]:
    if not isinstance(rect, (list, tuple)) or len(rect) != 4:
        raise ValueError(f"rect must be [u0,v0,u1,v1]: {rect!r}")
    return (int(round(float(rect[0]) * w)), int(round(float(rect[1]) * h)),
            int(round(float(rect[2]) * w)), int(round(float(rect[3]) * h)))


def _rect_mask(w: int, h: int, rect: Any, feather: float) -> Image.Image:
    mask = Image.new("L", (w, h), 0)
    mask.paste(255, _rect_px(rect, w, h))
    if feather > 0:
        mask = mask.filter(ImageFilter.GaussianBlur(feather))
    return mask


def _band_geometry(desc: dict[str, Any], w: int, h: int,
                   spec_seed: int) -> dict[str, Any]:
    """Deterministic shoreline shared by every layer with a ``band`` key."""
    rng = random.Random(int(desc.get("seed", spec_seed)))
    direction = str(desc.get("direction", "down")).lower()
    if direction not in VALID_DIRECTIONS:
        raise ValueError(f"unknown bands.direction: {direction!r}")

    def _width(key: str, default: list[int]) -> int:
        pair = desc.get(key) or default
        lo, hi = int(pair[0]), int(pair[1])
        if lo < 0 or hi < lo:
            raise ValueError(f"bad bands.{key} range: {pair!r}")
        return rng.randint(lo, hi)

    sand_w = _width("sand", [26, 51])
    wash_w = _width("wash", [30, 50])
    span = w if direction in ("down", "up") else h
    base = float(desc.get("origin", 0.5)) * span
    jitter = max(0, int(desc.get("jitter_px", 8)))
    # Clamp step to <=8 px: no constant-x / constant-y boundary run is longer.
    step = min(MAX_SHORE_STEP, max(1, int(desc.get("step_px", 6))))
    points: list[tuple[int, float]] = []
    t = 0
    while t < span:
        points.append((t, base + rng.randint(-jitter, jitter)))
        t += step
    points.append((span, base + rng.randint(-jitter, jitter)))
    return {
        "direction": direction, "points": points,
        "sand_w": sand_w, "wash_w": wash_w,
        "seed": int(desc.get("seed", spec_seed)), "step_px": step,
    }


def _shore_xy(direction: str, t: int, shore: float, off: float,
              w: int, h: int) -> tuple[float, float]:
    """Map (cross-axis t, shore position + signed offset) to canvas coords.

    Positive ``off`` always points from land toward water.
    """
    if direction == "down":
        return (t, shore + off)
    if direction == "up":
        return (t, shore - off)
    if direction == "right":
        return (shore + off, t)
    return (shore - off, t)  # left


def _band_mask(geom: dict[str, Any], band: str, w: int, h: int,
               feather: float) -> Image.Image:
    """One of three sequential jagged bands: sand | wash | water."""
    if band not in VALID_BANDS:
        raise ValueError(f"unknown band: {band!r}")
    sand_w, wash_w = geom["sand_w"], geom["wash_w"]
    if band == "sand":
        near, far = -sand_w, 0.0
    elif band == "wash":
        near, far = 0.0, float(wash_w)
    else:
        near, far = float(wash_w), float(max(w, h) * 2)
    direction = geom["direction"]
    points = geom["points"]
    poly = [_shore_xy(direction, t, s, near, w, h) for t, s in points]
    poly += [_shore_xy(direction, t, s, far, w, h) for t, s in reversed(points)]
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).polygon(poly, fill=255)
    if feather > 0:
        mask = mask.filter(ImageFilter.GaussianBlur(feather))
    return mask


def _layer_mask(layer: dict[str, Any], w: int, h: int,
                band_geom: dict[str, Any] | None,
                default_band: str | None = None) -> tuple[Image.Image | None, str | None]:
    """Build the alpha mask for a block/water layer.

    Returns ``(None, None)`` when the layer has no masking keys, so callers
    keep the original full-canvas code path (backward compatibility).
    """
    band = layer.get("band") or default_band
    feather = 0.0 if layer.get("contour") else float(layer.get("feather_px", 0))
    if band_geom is not None and band is not None:
        band = str(band).lower()
        if band not in VALID_BANDS:
            raise ValueError(f"unknown band: {band!r}")
        mask = _band_mask(band_geom, band, w, h, feather)
        used = band
    elif layer.get("rect") is not None:
        mask = _rect_mask(w, h, layer["rect"], feather)
        used = None
    else:
        return None, None
    if used is not None and layer.get("rect") is not None:
        # Hard clip to the rect; the band keeps its own (softer) feather.
        mask = ImageChops.multiply(mask, _rect_mask(w, h, layer["rect"], 0.0))
    return mask, used


def _apply_contour(img: Image.Image, mask: Image.Image,
                   layer: dict[str, Any], width_px: int = 3) -> Image.Image:
    """Hard binary mask + <=3 px dark rim along the contour (no grid feather)."""
    strength = float(layer.get("contour_strength", 0.75))
    binary = mask.point([255 if i >= 128 else 0 for i in range(256)])
    inner = binary.filter(ImageFilter.MinFilter(3))
    width = min(3, max(1, int(width_px)))
    if width % 2 == 0:
        width += 1
    rim = ImageChops.subtract(binary, inner).filter(ImageFilter.MaxFilter(width))
    avg = img.convert("RGB").resize((1, 1), RESAMPLE).getpixel((0, 0))
    color = tuple(_clamp255(v * 0.55) for v in avg)
    overlay = Image.new("RGBA", img.size, color + (0,))
    overlay.putalpha(rim.point([_clamp255(i * strength) for i in range(256)]))
    img.alpha_composite(overlay)
    return binary


def _foam_specks(waves: Image.Image, w: int, h: int,
                 intensity: float, speck_scale: float) -> Image.Image:
    """Donor-style nautic/particles specks from the wave sheet (no time scroll)."""

    def _resample(factor: float) -> Image.Image:
        sw = max(2, int(w * factor))
        sh = max(2, int(h * factor))
        return waves.resize((sw, sh), RESAMPLE).resize((w, h), RESAMPLE)

    f1 = _resample(0.16 * speck_scale)
    f2 = _resample(0.55 * speck_scale)
    nautic = f1.point([_clamp255(((1.0 - i / 255.0) ** 5) * 255.0)
                       for i in range(256)])
    particles = f2.point([_clamp255(((i / 255.0) ** 7) * 255.0 * 1.5)
                          for i in range(256)])
    field = ImageChops.add(nautic, particles)
    if intensity != 1.0:
        field = field.point([_clamp255(i * intensity) for i in range(256)])
    return field


def _smooth_field(grid: Any, w: int, h: int,
                  resample: int = RESAMPLE) -> Image.Image:
    """Bilinear low-res coverage grid -> canvas-sized L field (world.gd:NxN)."""
    if not isinstance(grid, (list, tuple)) or not grid:
        raise ValueError("grid must be a non-empty 2D array")
    rows = len(grid)
    cols = len(grid[0]) if isinstance(grid[0], (list, tuple)) else 1
    small = Image.new("L", (cols, rows))
    for gy, row in enumerate(grid):
        values = row if isinstance(row, (list, tuple)) else [row]
        if len(values) != cols:
            raise ValueError("grid rows must have equal length")
        for gx, value in enumerate(values):
            small.putpixel((gx, gy), _clamp255(float(value) * 255.0))
    return small.resize((w, h), resample)


def _olive_gain(base: Image.Image, delta: Image.Image,
                weights: tuple[float, float, float]) -> Image.Image:
    """Add a signed, per-pixel L gain (delta centred on 128) with RGB weights."""
    pos = delta.point([max(0, i - 128) for i in range(256)])
    neg = delta.point([max(0, 128 - i) for i in range(256)])
    out = base.convert("RGB")
    channels = []
    for index in range(3):
        weight = weights[index]
        add = pos.point([_clamp255(i * weight) for i in range(256)])
        sub = neg.point([_clamp255(i * weight) for i in range(256)])
        channels.append(ImageChops.add(ImageChops.subtract(
            out.getchannel(index), sub), add))
    return Image.merge("RGB", channels).convert("RGBA")


def _face_mask(geometry: dict[str, Any], w: int, h: int,
               rng: random.Random) -> tuple[Image.Image, dict[str, Any]]:
    """Face coverage from a height field or a polyline extrusion."""
    kind = str(geometry.get("kind", "polyline")).lower()
    mask = Image.new("L", (w, h), 0)
    if kind == "polyline":
        points = geometry.get("points") or [[0.15, 0.18], [0.42, 0.42], [0.70, 0.24]]
        top = [(float(p[0]) * w, float(p[1]) * h) for p in points]
        drop = float(geometry.get("height_px", h * 0.10))
        bottom = [(x, y + drop) for x, y in top]
        poly = top + list(reversed(bottom))
        ImageDraw.Draw(mask).polygon(poly, fill=255)
        detail = {"kind": kind, "points": points, "height_px": drop}
    elif kind == "height":
        cells = int(geometry.get("cells", 9))
        grid = [[rng.uniform(0.0, 1.0) for _ in range(cells)] for _ in range(cells)]
        field = _smooth_field(grid, w, h, RESAMPLE)
        threshold = _clamp255(float(geometry.get("threshold", 0.55)) * 255.0)
        mask = field.point([255 if i >= threshold else 0 for i in range(256)])
        detail = {"kind": kind, "cells": cells, "threshold": threshold / 255.0}
    else:
        raise ValueError(f"unknown face geometry.kind: {kind!r}")
    return mask, detail


def _striated_fill(fill_name: str, flutes_name: str | None, w: int, h: int,
                   stretch: float, rng: random.Random,
                   resample: int, verbose: bool,
                   tile_size: int = TILE_SIZE) -> Image.Image:
    """rock8 fill + vertically stretched rock1 flutes (ravine_face M7)."""
    phase = max(1, tile_size // 2)
    fill_path = _png(BLOCKS_DIR, _safe_name(fill_name, "face fill"))
    _log(verbose, f"face fill {fill_name} <- {fill_path.name}")
    fill_tile = mirror_tileable(Image.open(fill_path), tile_size, resample)
    if stretch != 1.0:
        fill_tile = fill_tile.resize(
            (tile_size, max(1, int(round(tile_size * stretch)))), resample)
    fill = wrap_crop(fill_tile, rng.randrange(phase), rng.randrange(phase), w, h).convert("RGBA")
    if flutes_name:
        flutes_path = _png(BLOCKS_DIR, _safe_name(flutes_name, "face flutes"))
        _log(verbose, f"face flutes {flutes_name} <- {flutes_path.name}")
        flute_tile = mirror_tileable(Image.open(flutes_path), tile_size, resample)
        if stretch != 1.0:
            flute_tile = flute_tile.resize(
                (tile_size, max(1, int(round(tile_size * stretch)))), resample)
        flutes = wrap_crop(flute_tile, rng.randrange(phase), rng.randrange(phase), w, h)
        # Anisotropic striation: brighten along the vertical grain only.
        detail = flutes.convert("L").filter(ImageFilter.GaussianBlur(1.2))
        gain = detail.point([_clamp255(96 + (i - 128) * 0.9) for i in range(256)])
        fill = _olive_gain(fill, gain, (1.0, 0.98, 0.90))
    return fill


# ---------------------------------------------------------------------------
# layer renderers
# ---------------------------------------------------------------------------
def _render_block(layer: dict[str, Any], w: int, h: int,
                  rng: random.Random, verbose: bool,
                  band_geom: dict[str, Any] | None = None,
                  canvas: Image.Image | None = None) -> tuple[Image.Image, dict[str, Any]]:
    name = _safe_name(layer.get("name"), "block name")
    path = _png(BLOCKS_DIR, name)
    _log(verbose, f"block {name} <- {path.name}")
    src = Image.open(path)
    tile = _scaled_tile(src, layer)
    ox, oy = _offset_for(layer, rng)
    if bool(layer.get("tile", True)):
        img = wrap_crop(tile, ox, oy, w, h)
    else:
        img = tile.resize((w, h), RESAMPLE)

    img = img.convert("RGBA")
    op = _opacity(layer.get("opacity"))
    op_mask = _opacity_mask_for(layer, w, h, canvas) if canvas is not None else None
    mask_mode = str(layer.get("mask", "")).lower()
    default_band = "sand" if mask_mode == "band" else None
    mask, used_band = _layer_mask(layer, w, h, band_geom, default_band)
    if mask is None and op_mask is None:
        # Original full-canvas path, kept byte-for-byte for legacy specs.
        img = _with_opacity(img, op)
    else:
        if mask is None:
            mask = Image.new("L", (w, h), 255)
        elif layer.get("contour"):
            mask = _apply_contour(img, mask, layer)
        if op_mask is not None:
            mask = ImageChops.multiply(mask, op_mask)
        if op < 1.0:
            mask = mask.point([_clamp255(i * op) for i in range(256)])
        img.putalpha(mask)

    detail = {
        "name": name, "source": _rel(path), "tile": bool(layer.get("tile", True)),
        "tile_size": list(tile.size), "offset_px": [ox, oy],
        "contrast": float(layer.get("contrast", 1.12)),
        "brightness": float(layer.get("brightness", 1.0)),
        "scale": float(layer.get("scale", 1.0)),
        "mask_mode": mask_mode or None, "mask_band": used_band,
        "contour": bool(layer.get("contour", False)),
        "opacity_mask": bool(layer.get("opacity_mask") is not None),
    }
    if layer.get("rect") is not None:
        detail["rect_px"] = list(_rect_px(layer["rect"], w, h))
    return img, detail


def _sprite_path(name: str, source: str) -> Path:
    source = source.lower()
    if source in ("hi", "sprites_hi", "auto", ""):
        candidates = [SPRITES_HI_DIR, SPRITES_DIR, DECO_DIR]
    elif source in ("low", "sprites", "sprites_low"):
        candidates = [SPRITES_DIR, SPRITES_HI_DIR, DECO_DIR]
    elif source in ("deco", "deco_png"):
        candidates = [DECO_DIR]
    elif source in ("block", "blocks", "terrain_block"):
        # Face-skin mode: a block tile (e.g. rock1) used as a sprite overlay.
        candidates = [BLOCKS_DIR]
    else:
        raise ValueError(f"unknown sprite source: {source!r}")
    for directory in candidates:
        candidate = directory / (name + ".png")
        if candidate.is_file():
            return candidate
    raise FileNotFoundError(f"sprite {name!r} not found in "
                            + ", ".join(str(d) for d in candidates))


def _render_sprite(layer: dict[str, Any], w: int, h: int,
                   rng: random.Random, verbose: bool,
                   canvas: Image.Image | None = None) -> tuple[Image.Image, tuple[int, int], dict[str, Any]]:
    name = _safe_name(layer.get("name"), "sprite name")
    source = str(layer.get("source", "hi"))
    path = _sprite_path(name, source)
    _log(verbose, f"sprite {name} <- {path.name}")
    src_img = Image.open(path).convert("RGBA")
    scale = float(layer.get("scale", 1.0))
    if scale <= 0:
        raise ValueError(f"scale must be > 0: {scale!r}")
    stretch = layer.get("stretch")
    tile_mode = bool(layer.get("tile", False))
    if stretch is not None:
        if not isinstance(stretch, (list, tuple)) or len(stretch) != 2:
            raise ValueError(f"stretch must be [sx, sy]: {stretch!r}")
        target = (max(1, int(round(float(stretch[0]) * w))),
                  max(1, int(round(float(stretch[1]) * h))))
    elif tile_mode:
        target = (max(1, int(round(src_img.width * scale))),
                  max(1, int(round(src_img.height * scale))))
    else:
        target = None

    if target is None:
        # Original single-resize path, untouched for legacy specs.
        img = src_img
        if scale != 1.0:
            size = (max(1, int(round(img.width * scale))),
                    max(1, int(round(img.height * scale))))
            img = img.resize(size, RESAMPLE)
    elif tile_mode:
        # Face skin: mirror-tile the source across the stretched footprint.
        resample = RESAMPLE_MAP.get(str(layer.get("_resample", "bilinear")).lower(), RESAMPLE)
        tile = mirror_tileable(src_img, int(layer.get("_tile_size", TILE_SIZE)), resample)
        ox, oy = _offset_for(layer, rng)
        img = wrap_crop(tile, ox, oy, target[0], target[1]).convert("RGBA")
    else:
        img = src_img.resize(target, RESAMPLE)

    pos = layer.get("pos") or [0.5, 0.5]
    px, py = float(pos[0]) * w, float(pos[1]) * h
    # sprites are placed by normalised pos; jitter_px adds seeded sub-pixel
    # variation, and nudge_px is an optional explicit pixel displacement.
    dx, dy = _offset_for(layer, rng, base_key="nudge_px")
    px += dx
    py += dy

    anchor = str(layer.get("anchor", "foot")).lower()
    if anchor == "foot":
        bbox = img.getchannel("A").getbbox()
        if bbox:
            cx = (bbox[0] + bbox[2]) / 2.0
            foot_y = bbox[3]
        else:  # fully transparent sprite: fall back to image bounds
            cx, foot_y = img.width / 2.0, img.height
        x, y = px - cx, py - foot_y
    elif anchor in ("center", "centre"):
        x, y = px - img.width / 2.0, py - img.height / 2.0
    elif anchor in ("topleft", "top_left", "raw"):
        x, y = px, py
    else:
        raise ValueError(f"unknown sprite anchor: {anchor!r}")
    x, y = int(round(x)), int(round(y))
    op_mask = _opacity_mask_for(layer, w, h, canvas) if canvas is not None else None
    img = _with_opacity(img, _opacity(layer.get("opacity")), op_mask)
    detail = {
        "name": name, "source": _rel(path), "source_dir": source,
        "pos_norm": [float(pos[0]), float(pos[1])], "pos_px": [int(round(px)), int(round(py))],
        "anchor": anchor, "foot_px": [x, y], "scale": scale,
        "sprite_size_px": list(img.size),
        "stretch": [float(v) for v in stretch] if stretch is not None else None,
        "tile": tile_mode,
    }
    return img, (x, y), detail


def _render_water(layer: dict[str, Any], w: int, h: int,
                  rng: random.Random, verbose: bool,
                  band_geom: dict[str, Any] | None = None,
                  canvas: Image.Image | None = None) -> tuple[Image.Image, dict[str, Any]]:
    sheet = _safe_name(layer.get("sheet"), "water sheet")
    path = _png(WATER_DIR, sheet)
    _log(verbose, f"water {sheet} <- {path.name}")
    src = Image.open(path)
    tile = _scaled_tile(src, {"scale": layer.get("scale", 1.0), "contrast": 1.0})
    ox, oy = _offset_for(layer, rng)
    waves = wrap_crop(tile, ox, oy, w, h).convert("L")

    mode = str(layer.get("mode", "shallow")).lower()
    opacity = _opacity(layer.get("opacity"))
    explicit_tint = layer.get("tint")
    if explicit_tint is not None:
        if not isinstance(explicit_tint, (list, tuple)) or len(explicit_tint) != 3:
            raise ValueError(f"tint must be [r,g,b]: {explicit_tint!r}")
        rgb_tint = tuple(float(c) for c in explicit_tint)

    if mode == "foam":
        # Coast-band foam: nautic/particles-style specks, gated by coverage.
        intensity = float(layer.get("intensity", 1.0))
        speck_scale = float(layer.get("speck_scale", 1.0))
        field = _foam_specks(waves, w, h, intensity, speck_scale)
        rgb_tint = tuple(float(c) for c in (explicit_tint or FOAM_COLOR))
        rgb = tuple(_clamp255(c * 255.0) for c in rgb_tint)
        img = Image.new("RGBA", (w, h), rgb + (0,))
        default_band = "wash"
    elif mode == "wash" and explicit_tint is None:
        # Pale wash: #BDBDA9 (dry) -> #C3D1CA (wet), mild wave modulation.
        bands = []
        for dry, wet in zip(*WASH_COLORS):
            bands.append(waves.point([
                _clamp255((dry + (wet - dry) * i / 255.0) * 255.0
                          * (0.92 + 0.08 * i / 255.0)) for i in range(256)]))
        img = Image.merge("RGB", bands).convert("RGBA")
        rgb_tint = WASH_COLORS[0]
        default_band = "wash"
    else:
        if explicit_tint is None:
            if mode not in WATER_TINTS:
                raise ValueError(f"unknown water mode: {mode!r}")
            rgb_tint = WATER_TINTS[mode]
        # shader body: col = tint * (0.80 + 0.40 * h)
        bands = []
        for channel in rgb_tint:
            bands.append(waves.point([_clamp255(channel * 255.0 * (0.80 + 0.40 * i / 255.0))
                                      for i in range(256)]))
        img = Image.merge("RGB", bands).convert("RGBA")
        default_band = "water"

    mask, used_band = _layer_mask(layer, w, h, band_geom,
                                  default_band if band_geom is not None else None)
    if mode == "foam":
        gate = mask if mask is not None else Image.new("L", (w, h), 255)
        alpha = ImageChops.multiply(gate, field)  # coastfade gate on specks
    else:
        alpha = mask if mask is not None else Image.new("L", (w, h), 255)
    if canvas is not None:
        op_mask = _opacity_mask_for(layer, w, h, canvas)
        if op_mask is not None:
            alpha = ImageChops.multiply(alpha, op_mask)
    if opacity < 1.0:
        alpha = alpha.point([_clamp255(i * opacity) for i in range(256)])
    img.putalpha(alpha)

    rect = layer.get("rect") or [0.0, 0.0, 1.0, 1.0]
    detail = {
        "sheet": sheet, "source": _rel(path), "mode": mode,
        "tint": [round(c, 4) for c in rgb_tint],
        "rect_norm": [float(v) for v in rect], "rect_px": list(_rect_px(rect, w, h)),
        "feather_px": float(layer.get("feather_px", 0)), "offset_px": [ox, oy],
        "scale": float(layer.get("scale", 1.0)),
        "mask_band": used_band,
    }
    if mode == "foam":
        detail.update({"intensity": intensity, "speck_scale": speck_scale})
    return img, detail


# ---------------------------------------------------------------------------
# new layer types: patches / face / glaze
# ---------------------------------------------------------------------------
def _parse_color(value: Any, default: tuple[float, float, float]) -> tuple[float, float, float]:
    if value is None:
        return default
    if isinstance(value, str):
        text = value.strip().lstrip("#")
        if len(text) != 6:
            raise ValueError(f"bad hex colour: {value!r}")
        return tuple(int(text[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    if isinstance(value, (list, tuple)) and len(value) == 3:
        return tuple(float(c) for c in value)
    raise ValueError(f"bad colour: {value!r}")


def _render_patches(layer: dict[str, Any], w: int, h: int,
                    rng: random.Random, canvas: Image.Image, verbose: bool,
                    resample: int) -> tuple[Image.Image, dict[str, Any]]:
    """Terrain-driven ±L olive gain at 20-80 px patch scale (grass_mottled)."""
    prng = random.Random(int(layer.get("seed", 0)))
    patch_px = layer.get("patch_px") or [20, 80]
    if isinstance(patch_px, (list, tuple)):
        cell = prng.randint(int(patch_px[0]), int(patch_px[1]))
    else:
        cell = int(patch_px)
    cell = max(4, int(cell))
    cols = max(1, (w + cell - 1) // cell)
    rows = max(1, (h + cell - 1) // cell)
    grid = layer.get("grid") or [
        [prng.uniform(-1.0, 1.0) for _ in range(cols)] for _ in range(rows)]
    field = _smooth_field(grid, w, h, resample)  # 0..255, 128 = zero gain
    amplitude = float(layer.get("gain", 30))
    delta = field.point([_clamp255(128 + (i - 128) * amplitude / 127.5)
                         for i in range(256)])
    weights = tuple(float(v) for v in (layer.get("olive_weights") or OLIVE_GAIN_WEIGHTS))

    cover_mode = str(layer.get("cover", "full" if not layer.get("name") else "positive")).lower()
    if cover_mode == "positive":
        alpha = field.point([_clamp255(max(0, (i - 112) * 3)) for i in range(256)])
    elif cover_mode == "full":
        alpha = Image.new("L", (w, h), 255)
    else:
        raise ValueError(f"unknown patches.cover: {cover_mode!r}")

    base = canvas.copy()
    if layer.get("name"):
        block_path = _png(BLOCKS_DIR, _safe_name(layer["name"], "patch block"))
        _log(verbose, f"patches block {layer['name']} <- {block_path.name}")
        tile_size = int(layer.get("_tile_size", TILE_SIZE))
        phase = max(1, tile_size // 2)
        tile = mirror_tileable(Image.open(block_path), tile_size, resample)
        crop = wrap_crop(tile, rng.randrange(phase), rng.randrange(phase), w, h).convert("RGBA")
        crop.putalpha(alpha)
        base.alpha_composite(crop)

    if layer.get("hard_rim"):
        base = _olive_gain(base, delta, weights)
        alpha = _apply_contour(base, alpha, layer, width_px=int(layer.get("rim_px", 3)))
        out = base
    else:
        out = _olive_gain(base, delta, weights)

    if layer.get("rect") is not None:
        alpha = ImageChops.multiply(alpha, _rect_mask(w, h, layer["rect"], 0.0))
    if layer.get("opacity_mask"):
        op_mask = _opacity_mask_for(layer, w, h, canvas)
        if op_mask is not None:
            alpha = ImageChops.multiply(alpha, op_mask)
    op = _opacity(layer.get("opacity"))
    if op < 1.0:
        alpha = alpha.point([_clamp255(i * op) for i in range(256)])
    out.putalpha(alpha)

    detail = {
        "type": "patches", "patch_px": cell, "grid": [cols, rows],
        "gain": amplitude, "olive_weights": list(weights), "cover": cover_mode,
        "block": layer.get("name"), "hard_rim": bool(layer.get("hard_rim", False)),
        "seed": int(layer.get("seed", 0)),
    }
    return out, detail


def _render_face(layer: dict[str, Any], w: int, h: int,
                 rng: random.Random, canvas: Image.Image, verbose: bool,
                 resample: int) -> tuple[Image.Image, dict[str, Any]]:
    """Height-step / ravine face: striated fill, lit-shadow ramp, hard rim."""
    geometry = layer.get("geometry") or {}
    mask, geo_detail = _face_mask(geometry, w, h, rng)
    fill_name = str(layer.get("fill") or "rock8")
    flutes_name = layer.get("flutes", "rock1")
    flutes = str(flutes_name) if flutes_name else None
    stretch = float(layer.get("stretch", 2.0))
    fill = _striated_fill(fill_name, flutes, w, h, stretch, rng, resample, verbose,
                          int(layer.get("_tile_size", TILE_SIZE)))

    lit = _parse_color(layer.get("lit"), DEFAULT_LIT)
    shadow = _parse_color(layer.get("shadow"), DEFAULT_SHADOW)
    ramp_gain = float(layer.get("ramp_gain", 22))
    grad = Image.linear_gradient("L").resize((w, h), RESAMPLE)
    grad = grad.point([255 - i for i in range(256)])  # lit at top, shadow at foot
    delta = grad.point([_clamp255(128 + (i - 127.5) * 2.0 * ramp_gain / 127.5)
                        for i in range(256)])
    weights = (1.0, 0.96, 0.82)
    fill = _olive_gain(fill, delta, weights)

    rim_px = int(layer.get("rim_px", 3))
    if layer.get("contour", True):
        mask = _apply_contour(fill, mask, layer, width_px=rim_px)
        rim = True
    else:
        rim = False

    if layer.get("rect") is not None:
        mask = ImageChops.multiply(mask, _rect_mask(w, h, layer["rect"], 0.0))
    if layer.get("opacity_mask"):
        op_mask = _opacity_mask_for(layer, w, h, canvas)
        if op_mask is not None:
            mask = ImageChops.multiply(mask, op_mask)
    op = _opacity(layer.get("opacity"))
    if op < 1.0:
        mask = mask.point([_clamp255(i * op) for i in range(256)])
    fill.putalpha(mask)

    detail = {
        "type": "face", "geometry": geo_detail, "fill": fill_name,
        "flutes": flutes, "stretch": stretch, "rim_px": rim_px if rim else 0,
        "lit": [round(c, 3) for c in lit], "shadow": [round(c, 3) for c in shadow],
        "ramp_gain": ramp_gain,
    }
    return fill, detail


def _render_glaze(layer: dict[str, Any], w: int, h: int,
                  canvas: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    """Luminance-masked cool glaze: exact white survives, other pixels cool."""
    tint = tuple(float(c) for c in (layer.get("tint") or [0.80, 0.88, 1.0]))
    white_floor = int(layer.get("white_floor", 246))
    strength = float(layer.get("strength", 0.35))
    luminance = canvas.convert("L")
    white_mask = luminance.point([255 if i >= white_floor else 0 for i in range(256)])
    weights = []
    for i in range(256):
        if i >= white_floor:
            weights.append(0)
        else:
            weights.append(_clamp255((0.35 + 0.65 * i / 255.0) * strength * 255.0))
    weight = luminance.point(weights)
    channels = []
    for index in range(3):
        channels.append(canvas.getchannel(index).point(
            [_clamp255(i * tint[index]) for i in range(256)]))
    glazed = Image.merge("RGBA", channels + [Image.new("L", (w, h), 255)])
    out = canvas.copy()
    out.alpha_composite(_with_opacity(glazed, 1.0, weight))
    pure = Image.new("RGBA", (w, h), (255, 255, 255, 255))
    out = Image.composite(pure, out, white_mask)
    out.putalpha(Image.new("L", (w, h), 255))

    detail = {
        "type": "glaze", "tint": list(tint), "white_floor": white_floor,
        "strength": strength,
        "exact_white_pct": round(100.0 * white_mask.histogram()[255] / (w * h), 2),
    }
    return out, detail


# ---------------------------------------------------------------------------
# reference comparison
# ---------------------------------------------------------------------------
def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        pass
    for candidate in (
        "C:/Windows/Fonts/dejavusans.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ):
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


def build_comparison(name: str, render: Image.Image, reference: Image.Image,
                     seed: int, layers: list[dict[str, Any]], crop: list[int]) -> Image.Image:
    """Labelled [render | donor crop] tile; reference is only ever read."""
    w, h = render.size
    pad, gap, header, caption = 12, 14, 44, 28
    canvas = Image.new("RGB", (pad * 2 + w * 2 + gap, pad * 2 + header + h + caption),
                       (22, 24, 28))
    d = ImageDraw.Draw(canvas)
    title_font = _font(15)
    cap_font = _font(13)
    types = ", ".join(dict.fromkeys(str(l["type"]) for l in layers)) or "none"
    d.text((pad, pad),
           f"{name}   seed={seed}   {w}x{h}   layers: {types}   (Pillow, no Godot)",
           font=title_font, fill=(232, 236, 242))
    top = pad + header
    canvas.paste(render, (pad, top))
    canvas.paste(reference, (pad + w + gap, top))
    d.rectangle((pad - 1, top - 1, pad + w, top + h), outline=(96, 102, 112))
    d.rectangle((pad + w + gap - 1, top - 1, pad + w * 2 + gap, top + h),
                outline=(96, 102, 112))
    d.text((pad, top + h + 7), "PORT RENDER (deterministic)", font=cap_font,
           fill=(150, 220, 168))
    d.text((pad + w + gap, top + h + 7),
           f"DONOR REFERENCE CROP {tuple(crop)} (read-only)",
           font=cap_font, fill=(240, 198, 140))
    return canvas


# ---------------------------------------------------------------------------
# spec driver
# ---------------------------------------------------------------------------
def _rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def _load_reference(spec: dict[str, Any], ref_root: Path, w: int, h: int,
                    verbose: bool) -> tuple[Image.Image | None, dict[str, Any]]:
    ref = spec.get("reference")
    if not ref:
        return None, {"provided": False}
    image_name = _safe_name(ref.get("image"), "reference image")
    path = ref_root / image_name
    info: dict[str, Any] = {
        "provided": True, "image": image_name,
        "directory": str(ref_root), "box": ref.get("box"),
    }
    if not path.is_file():
        info["available"] = False
        info["reason"] = "reference file not found (render still written)"
        _log(verbose, f"WARNING reference not found: {path}")
        return None, info
    box = ref.get("box")
    if not isinstance(box, (list, tuple)) or len(box) != 4:
        raise ValueError(f"reference.box must be [l,t,r,b]: {box!r}")
    crop_box = tuple(int(v) for v in box)
    with Image.open(path) as source:
        source = source.convert("RGB")
        l, t, r, b = crop_box
        if not (0 <= l < r <= source.width and 0 <= t < b <= source.height):
            raise ValueError(f"reference.box {crop_box} outside {source.size}")
        crop = source.crop(crop_box)
    info["available"] = True
    info["source_size"] = list(source.size)
    info["resolved"] = str(path)
    return crop.resize((w, h), RESAMPLE), info


def render_spec(spec_path: Path, out_dir: Path, ref_root: Path,
                verbose: bool = False) -> dict[str, Any]:
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    if not isinstance(spec, dict):
        raise ValueError("spec root must be a JSON object")

    name = _safe_name(spec.get("name"), "spec name")
    size = spec.get("size_px")
    if not isinstance(size, (list, tuple)) or len(size) != 2:
        raise ValueError("size_px must be [width, height]")
    w, h = int(size[0]), int(size[1])
    if not (16 <= w <= 4096 and 16 <= h <= 4096):
        raise ValueError(f"size_px out of range 16..4096: {w}x{h}")
    seed = int(spec.get("seed", 0))
    rng = random.Random(seed)

    # Grain-preserving path: render at native 1024² (or a multiple) and only
    # downsample once at final output. Legacy specs stay at size_px.
    native = spec.get("native_render")
    factor = int(native) if isinstance(native, int) and native > 1 else (2 if native else 1)
    rw, rh = w * factor, h * factor
    if rw > 4096 or rh > 4096:
        raise ValueError(f"native_render exceeds 4096 px: {rw}x{rh}")
    resample_name = str(spec.get("resample", "bilinear")).lower()
    if resample_name not in RESAMPLE_MAP:
        raise ValueError(f"unknown resample: {resample_name!r}")
    resample = RESAMPLE_MAP[resample_name]
    final_name = str(spec.get("final_resample", "lanczos")).lower()
    final_resample = RESAMPLE_MAP.get(final_name, Image.Resampling.LANCZOS)
    grain_lift = float(spec.get("grain_lift", 0))

    band_geom = None
    if isinstance(spec.get("bands"), dict):
        band_geom = _band_geometry(spec["bands"], rw, rh, seed)
    layers = spec.get("layers", [])
    if not isinstance(layers, list):
        raise ValueError("layers must be a JSON array")

    background = spec.get("background") or [40, 44, 48]
    if not isinstance(background, (list, tuple)) or len(background) != 3:
        raise ValueError("background must be [r,g,b]")
    canvas = Image.new("RGBA", (rw, rh),
                       tuple(_clamp255(v) for v in background) + (255,))

    drawn: list[dict[str, Any]] = []
    for index, layer in enumerate(layers):
        if not isinstance(layer, dict):
            raise ValueError(f"layer {index} must be an object")
        local = dict(layer)
        local["_resample"] = resample_name
        # At native render the mirror tile must be 2x the working canvas so
        # the quadrant stays at the donor's full 1024² grain.
        local["_tile_size"] = rw * 2 if factor != 1 else TILE_SIZE
        kind = str(local.get("type", "")).lower()
        if kind == "block":
            img, detail = _render_block(local, rw, rh, rng, verbose, band_geom, canvas)
            paste_rgba(canvas, img, 0, 0)
        elif kind == "sprite":
            img, (x, y), detail = _render_sprite(local, rw, rh, rng, verbose, canvas)
            paste_rgba(canvas, img, x, y)
        elif kind == "water":
            img, detail = _render_water(local, rw, rh, rng, verbose, band_geom, canvas)
            paste_rgba(canvas, img, 0, 0)
        elif kind == "patches":
            img, detail = _render_patches(local, rw, rh, rng, canvas, verbose, resample)
            paste_rgba(canvas, img, 0, 0)
        elif kind == "face":
            img, detail = _render_face(local, rw, rh, rng, canvas, verbose, resample)
            paste_rgba(canvas, img, 0, 0)
        elif kind == "glaze":
            img, detail = _render_glaze(local, rw, rh, canvas)
            paste_rgba(canvas, img, 0, 0)
        else:
            raise ValueError(f"unknown layer type {kind!r} at index {index}")
        detail.update({"index": index, "type": kind,
                       "opacity": _opacity(local.get("opacity"))})
        drawn.append(detail)

    render = canvas.convert("RGB")
    if factor != 1:
        render = render.resize((w, h), final_resample)
        if grain_lift > 0:
            render = render.filter(ImageFilter.UnsharpMask(
                radius=1.2, percent=int(round(grain_lift * 100)), threshold=2))
    out_dir.mkdir(parents=True, exist_ok=True)
    png_path = out_dir / f"{name}.png"
    render.save(png_path, format="PNG", optimize=True)
    digest = hashlib.sha256(png_path.read_bytes()).hexdigest()

    reference_img, reference_info = _load_reference(spec, ref_root, w, h, verbose)
    comparison_path: Path | None = None
    if reference_img is not None:
        comparison = build_comparison(
            name, render, reference_img, seed, drawn,
            list(reference_info.get("box") or []),
        )
        comparison_path = out_dir / f"{name}_compare.png"
        comparison.save(comparison_path, format="PNG", optimize=True)

    manifest = {
        "generator": "terrain_piece_render.py",
        "version": 1,
        "name": name,
        "spec": _rel(spec_path),
        "seed": seed,
        "size_px": [w, h],
        "render_size_px": [rw, rh],
        "mirror_tile_size": rw * 2 if factor != 1 else TILE_SIZE,
        "resample": resample_name,
        "final_resample": final_name if factor != 1 else None,
        "grain_lift": grain_lift,
        "output": _rel(png_path),
        "comparison": _rel(comparison_path) if comparison_path else None,
        "sha256": digest,
        "layers": drawn,
        "bands": ({k: band_geom[k] for k in ("seed", "direction", "step_px",
                                             "sand_w", "wash_w")}
                  if band_geom is not None else None),
        "reference": reference_info,
        "tool_limits": (
            "Coast foam/wash are diffuse approximations (no time scroll). "
            "Sun-linked specular glints still require an in-engine capture. "
            "Faces/patches are 2D height proxies: no real height channel, "
            "collision or buildability. Winter glaze keeps exact white but "
            "readers must verify cool bias themselves."
        ),
    }
    manifest_path = out_dir / f"{name}.manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
                             encoding="utf-8")
    manifest["manifest"] = _rel(manifest_path)
    return manifest


def _expand_specs(raw_specs: list[str]) -> list[Path]:
    specs: list[Path] = []
    for raw in raw_specs:
        path = Path(raw).expanduser().resolve()
        if path.is_dir():
            specs.extend(sorted(path.glob("*.json")))
        elif path.is_file():
            specs.append(path)
        else:
            raise SystemExit(f"spec not found: {path}")
    if not specs:
        raise SystemExit("no spec JSON files found")
    return specs


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=__doc__.split("\n")[0],
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Spec schema and layer fields are documented in the module docstring.",
    )
    parser.add_argument("--spec", nargs="+", required=True, metavar="JSON|DIR",
                        help="spec JSON file(s) or a directory of *.json specs")
    parser.add_argument("--out-dir", default=str(DEFAULT_OUT_DIR),
                        help=f"output directory (default: {DEFAULT_OUT_DIR})")
    parser.add_argument("--reference-dir", default=None,
                        help="read-only reference image directory "
                             "(default: ~/Downloads/c3 or $C3_REFERENCE_DIR)")
    parser.add_argument("--verbose", action="store_true", help="log each asset load")
    args = parser.parse_args(argv)

    out_dir = Path(args.out_dir).expanduser().resolve()
    ref_root = _reference_root(args.reference_dir)
    for spec_path in _expand_specs(args.spec):
        try:
            manifest = render_spec(spec_path, out_dir, ref_root, args.verbose)
        except (OSError, ValueError) as exc:
            print(f"[piece] ERROR {spec_path.name}: {exc}", file=sys.stderr)
            return 1
        extra = f" compare={manifest['comparison']}" if manifest["comparison"] else ""
        print(f"[piece] {manifest['name']}: {manifest['output']} "
              f"sha256={manifest['sha256'][:12]}{extra}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
