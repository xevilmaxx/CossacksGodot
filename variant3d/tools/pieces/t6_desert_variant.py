#!/usr/bin/env python3
"""T6-T15 — single-piece headless mini-baker for ``desert_variant``.

Scope: ONE piece. No Godot, no whole-map work, no donor file copied into the
repo. The donor ``desert*.dds`` are only READ by a separate probe when the C7
source-faithfulness hash is recomputed; this module reads the already converted
port PNGs under ``app/assets/terrain/blocks`` and the piece JSON spec.

The shared renderer ``app/tools/terrain_piece_render.py`` is imported READ-ONLY
for its proven ``mirror_tileable`` / ``wrap_crop`` / ``adjust_bcs`` primitives
and the standard labelled compare sheet. Nothing in it is modified.

V3 RECIPE (rebuilt after coordinator visual review: the v2 40x40 binary grid
produced identical rectangular stamps on a visible lattice):

  1. base     : ``desert6`` mirror tile, contrast 1.12, brightness 1.00 (A4)
  2. grade    : zero-mean low-frequency tonal field selecting among ALL TWELVE
                donor desert palette means (light+mid family), applied as a
                per-pixel RGB delta so grain scale is preserved
  3. patches  : irregular seeded multi-octave noise + thin winding cracks;
                ``desert2`` texture through that organic mask, its colour
                modulated by the four dark-family donor palette means
  4. glaze    : warm dry grade tint [1.04, 1.00, 0.97], strength 0.45,
                white_floor 256 (no pixel forced white)
  5. accent   : ``rock_sea1`` dry rock at (0.6, 0.5), foot anchor, softened
                alpha edge + a soft warm contact shadow

Only TWO block composites are used (base + patch texture); the palette bank is
a colour grade, not extra layers, so C8's budget is unchanged.

ADAPTATIONS (all recorded in docs/t6/reports/T6-T15.md):
  A1 sprite ``rock_landstone1`` -> ``rock_sea1`` (mossy landstone1 is green).
  A2 sprite scale 1.0 -> auto-fit (<=3% visible ink, C6).
  A3 accent composited last so it sits on the ground.
  A4 block brightness 1.09 -> 1.00 (restores the donor base anchor).
  A5 (v3) 40x40 binary coverage grid -> seeded irregular noise/crack field.
  A6 (v3) all 12 donor palette means drive grade + patch modulation.
  A7 (v3) accent alpha softened and given a contact shadow.
  A8 (v4) patch opacity 0.85 -> 0.80 so rendered cracked grain lands in the
          donor 8-9 hi-freq band (measured 200², donor desert2 = 8.42) while
          dark coverage stays <=25%. C5 measurement corrected to the donor
          200² convention; the v3 report's 7.12 was measured at 512² by error.

Determinism: fixed seed from the spec, fixed resampling, no clock. Re-running
overwrites the same PNGs with byte-identical output.

Usage::

    python app/tools/pieces/t6_desert_variant.py
    python app/tools/pieces/t6_desert_variant.py --out-dir <temp> --metrics-out <temp>/m.json
"""
from __future__ import annotations

import argparse
import colorsys
import hashlib
import json
import math
import os
import random
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent          # app/tools/pieces
TOOLS = HERE.parent                            # app/tools
APP = TOOLS.parent                             # app
ROOT = APP.parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as shared          # READ-ONLY import

SPEC_PATH = TOOLS / "piece_specs" / "desert_variant.json"
BLOCKS = APP / "assets" / "terrain" / "blocks"
SPRITES_HI = APP / "assets" / "models" / "sprites_hi"
DEFAULT_OUT = APP / "shots" / "pieces"
DEFAULT_REF_ROOT = Path.home() / "Downloads" / "c3"

PIECE = "t6_desert_variant"
RESAMPLE = Image.Resampling.BILINEAR
SMOOTH = Image.Resampling.BICUBIC
INK_ALPHA = 16
SOURCE_INK_FRACTION = 0.3374           # measured rock_sea1 alpha>16 fraction
TARGET_INK_FRACTION = 0.0195           # accent-only target; shadow+soft edge add ~0.7%
BRIGHTNESS_OVERRIDE = 1.00             # A4: restore the donor desert6 anchor
PATCH_OPACITY_OVERRIDE = 0.80          # A8: rendered cracked grain -> donor 8-9 band
LIGHT_FAMILY = (1, 6, 7, 8, 11, 12)    # donor light-sand blocks
MID_FAMILY = (9, 10)                   # donor mid olive-tan blocks
DARK_FAMILY = (2, 3, 4, 5)             # donor dark cracked/scree blocks
GRADE_PALETTE = LIGHT_FAMILY + MID_FAMILY
PATCH_PALETTE = DARK_FAMILY


# ---------------------------------------------------------------------------
# small self-contained primitives
# ---------------------------------------------------------------------------
def _clamp255(v: float) -> int:
    return max(0, min(255, int(round(v))))


def _palette_bank() -> dict[int, np.ndarray]:
    """Mean RGB of all 12 converted port blocks (200², same convention as the doc).

    Read-only on repo assets; no donor binary is opened here.
    """
    bank: dict[int, np.ndarray] = {}
    for i in range(1, 13):
        with Image.open(BLOCKS / f"desert{i}.png") as im:
            small = im.convert("RGB").resize((200, 200), RESAMPLE)
            bank[i] = np.asarray(small, dtype=np.float64).mean(axis=(0, 1))
    return bank


def _noise_field(w: int, h: int, cell: int, seed: int) -> np.ndarray:
    """Seeded smooth value noise in [0,1]; no regular stamp lattice."""
    rng = random.Random(seed)
    gw, gh = max(2, int(math.ceil(w / cell))), max(2, int(math.ceil(h / cell)))
    small = Image.new("L", (gw, gh))
    for y in range(gh):
        for x in range(gw):
            small.putpixel((x, y), rng.randrange(256))
    return np.asarray(small.resize((w, h), SMOOTH), dtype=np.float64) / 255.0


def _organic_field(w: int, h: int, seed: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """(broad noise, hairline ridges, clustered threshold) from multi-scale noise.

    Four octaves at deliberately different scales (128/52/22/180 px) plus a
    spatially varying threshold: patches cluster, change size and leave empty
    ground, instead of tiling one identical stamp across the whole canvas.
    """
    n1 = _noise_field(w, h, 128, seed + 11)
    n2 = _noise_field(w, h, 52, seed + 23)
    n3 = _noise_field(w, h, 22, seed + 37)
    n4 = _noise_field(w, h, 180, seed + 53)
    broad = 0.50 * n1 + 0.32 * n2 + 0.18 * n3
    ridge = 1.0 - np.abs(2.0 * (0.60 * n2 + 0.40 * n3) - 1.0)
    threshold = 0.605 + 0.055 * (n4 - 0.5)
    return broad, ridge, threshold


def _palette_field(bank: dict[int, np.ndarray], family: tuple[int, ...],
                   field: np.ndarray) -> np.ndarray:
    """Per-pixel RGB selected by a smooth noise field from a donor family.

    Returns a zero-mean delta around the family's reference mean (desert6 for
    the ground grade, desert2 for the patch modulation), so the global palette
    anchors are preserved.
    """
    means = np.stack([bank[i] for i in family])
    ref = bank[6] if family == GRADE_PALETTE else bank[2]
    # Stretch the selector to its own [0,1] range so EVERY palette in the
    # family actually contributes pixels (raw bicubic noise never hits 0/1).
    span = float(field.max() - field.min())
    selector = (field - field.min()) / span if span > 1e-9 else np.full_like(field, 0.5)
    pos = np.clip(selector, 0.0, 1.0) * (len(family) - 1)
    idx = np.minimum(pos.astype(int), len(family) - 2)
    t = (pos - idx)[..., None]
    chosen = means[idx] * (1.0 - t) + means[np.minimum(idx + 1, len(family) - 1)] * t
    delta = chosen - ref
    return delta - delta.mean(axis=(0, 1), keepdims=True)


def _apply_delta(img: Image.Image, delta: np.ndarray,
                 mask: Image.Image | None = None) -> Image.Image:
    arr = np.asarray(img.convert("RGB"), dtype=np.float64) + delta
    out = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    if mask is not None:
        out.putalpha(mask)
    return out


def _organic_patch_mask(w: int, h: int, seed: int) -> tuple[Image.Image, float]:
    """Irregular patches + thin cracks; returns (mask 0..255, coverage fraction)."""
    broad, ridge, threshold = _organic_field(w, h, seed)
    core = broad > threshold
    cracks = ridge > 0.965
    cover = np.maximum(core.astype(np.float64), cracks.astype(np.float64) * 0.55)
    mask_img = Image.fromarray((np.clip(cover, 0, 1) * 255).astype(np.uint8), "L")
    return mask_img.filter(ImageFilter.GaussianBlur(1.1)), float(core.mean())


def _dry_glaze(img: Image.Image, tint: list[float], strength: float,
               white_floor: int) -> Image.Image:
    """Warm multiplier with luminance-weighted strength; no forced white."""
    lum = img.convert("L")
    lut = []
    for i in range(256):
        if i >= white_floor:
            lut.append(0)
        else:
            lut.append(_clamp255((0.35 + 0.65 * i / 255.0) * strength * 255.0))
    weight = lum.point(lut)
    bands = [img.getchannel(c).point(
        [_clamp255(v * tint[c]) for v in range(256)]) for c in range(3)]
    # Weight goes into the ALPHA channel only. Putting it into RGB as well
    # would attenuate twice and darken the frame (v2 bug, fixed here too).
    out = img.copy()
    out.alpha_composite(Image.merge("RGBA", bands + [weight]))
    out.putalpha(255)
    return out


def _sprite_dry_grade(path: Path) -> dict[str, Any]:
    """Green-dominance / hue check on the accent sprite's visible ink."""
    with Image.open(path) as im:
        arr = np.asarray(im.convert("RGBA")).astype(np.float64)
    mask = arr[:, :, 3] > INK_ALPHA
    rgb = arr[:, :, :3][mask]
    ys = np.where(mask)[0]
    ycut = ys.min() + (ys.max() - ys.min()) * 0.4
    row_index = np.arange(arr.shape[0])[:, None]
    crown = arr[:, :, :3][mask & (row_index <= ycut)]
    lum = crown.mean(axis=1)
    lit = crown[lum >= np.percentile(lum, 85)].mean(axis=0)
    hue, sat, _ = colorsys.rgb_to_hsv(*(c / 255.0 for c in lit))
    return {
        "sprite": path.name,
        "ink_fraction_source": round(float(mask.mean()), 4),
        "green_dominant_fraction": round(float((rgb[:, 1] > rgb[:, 0]).mean()), 4),
        "lit_rgb": [round(float(v), 1) for v in lit],
        "lit_hex": "#%02X%02X%02X" % tuple(_clamp255(v) for v in lit),
        "lit_hue_deg": round(hue * 360.0, 2),
        "lit_sat": round(sat, 3),
    }


# ---------------------------------------------------------------------------
# the bake
# ---------------------------------------------------------------------------
def load_spec() -> tuple[dict[str, Any], dict[str, Any]]:
    spec = json.loads(SPEC_PATH.read_text(encoding="utf-8"))
    layers = {layer["type"]: layer for layer in spec["layers"]}
    return spec, layers


def sprite_scale() -> float:
    return round(math.sqrt(TARGET_INK_FRACTION / SOURCE_INK_FRACTION), 4)


def bake(spec: dict[str, Any] | None = None, *, with_patches: bool = True,
         with_glaze: bool = True, with_sprite: bool = True) -> tuple[Image.Image, dict[str, Any]]:
    if spec is None:
        spec, _ = load_spec()
    layers = {layer["type"]: layer for layer in spec["layers"]}
    w, h = (int(v) for v in spec["size_px"])
    seed = int(spec["seed"])
    block = layers["block"]
    patches = layers.get("patches") or {}
    glaze = layers.get("glaze") or {}
    sprite = layers.get("sprite") or {}
    bank = _palette_bank()

    canvas = Image.new("RGBA", (w, h), tuple(spec["background"]) + (255,))
    detail: dict[str, Any] = {"size_px": [w, h], "seed": seed,
                              "palette_bank_families": {
                                  "light": list(LIGHT_FAMILY), "mid": list(MID_FAMILY),
                                  "dark": list(DARK_FAMILY)}}

    # 1. base desert6 -------------------------------------------------------
    base_path = BLOCKS / (block["name"] + ".png")
    base_tile = shared.mirror_tileable(Image.open(base_path), shared.TILE_SIZE, RESAMPLE)
    spec_brightness = float(block.get("brightness", 1.0))
    base_tile = shared.adjust_bcs(base_tile, BRIGHTNESS_OVERRIDE,
                                  float(block.get("contrast", 1.12)))
    rng = random.Random(seed)
    base = shared.wrap_crop(base_tile, rng.randrange(512), rng.randrange(512), w, h)
    canvas.alpha_composite(base.convert("RGBA"))
    detail["base"] = {"name": block["name"], "spec_brightness": spec_brightness,
                      "brightness": BRIGHTNESS_OVERRIDE,
                      "adaptation": "A4" if spec_brightness != BRIGHTNESS_OVERRIDE else None,
                      "contrast": block.get("contrast", 1.12)}

    # 2. all-12-palette zero-mean tonal grade ------------------------------
    grade_field = _noise_field(w, h, 118, seed + 101)
    grade_delta = _palette_field(bank, GRADE_PALETTE, grade_field)
    canvas = _apply_delta(canvas, grade_delta)
    detail["grade"] = {"families_used": GRADE_PALETTE, "cell_px": 118,
                       "delta_mean_rgb": [0.0, 0.0, 0.0],
                       "delta_p1_rgb": [round(float(np.percentile(grade_delta[:, :, c], 1)), 2)
                                        for c in range(3)],
                       "delta_p99_rgb": [round(float(np.percentile(grade_delta[:, :, c], 99)), 2)
                                         for c in range(3)]}

    # 3. organic dark patches (desert2 texture + 4 dark-family palettes) ---
    if with_patches and patches:
        mask, core_fraction = _organic_patch_mask(w, h, int(patches.get("seed", seed)))
        patch_path = BLOCKS / (patches["name"] + ".png")
        patch_tile = shared.mirror_tileable(Image.open(patch_path), shared.TILE_SIZE, RESAMPLE)
        prng = random.Random(seed + int(patches.get("seed", 0)) + 7)
        patch_img = shared.wrap_crop(patch_tile, prng.randrange(512),
                                     prng.randrange(512), w, h).convert("RGBA")
        dark_field = _noise_field(w, h, 83, seed + 211)
        dark_delta = _palette_field(bank, PATCH_PALETTE, dark_field)
        patch_img = _apply_delta(patch_img, dark_delta)
        spec_opacity = float(patches.get("opacity", 1.0))
        op = PATCH_OPACITY_OVERRIDE
        alpha = mask if op >= 1.0 else mask.point([_clamp255(i * op) for i in range(256)])
        patch_img.putalpha(alpha)
        canvas.alpha_composite(patch_img)
        detail["patches"] = {
            "name": patches["name"], "spec_opacity": spec_opacity,
            "used_opacity": op,
            "adaptation": "A8" if spec_opacity != op else None,
            "core_fraction": round(core_fraction, 4),
            "families_modulation": list(PATCH_PALETTE),
            "geometry": "seeded 3-octave value noise (96/44/19 px) + ridge cracks; no grid",
        }

    # 4. warm dry glaze -----------------------------------------------------
    if with_glaze and glaze:
        canvas = _dry_glaze(canvas, list(glaze["tint"]),
                            float(glaze["strength"]), int(glaze["white_floor"]))
        detail["glaze"] = {"tint": glaze["tint"], "strength": glaze["strength"],
                           "white_floor": glaze["white_floor"]}

    # 5. dry rock accent + soft contact shadow -----------------------------
    if with_sprite and sprite:
        accent_path = SPRITES_HI / (sprite["name"] + ".png")
        if not accent_path.is_file():
            accent_path = APP / "assets" / "models" / "sprites" / (sprite["name"] + ".png")
        accent = Image.open(accent_path).convert("RGBA")
        scale = sprite_scale()
        size = (max(1, int(round(accent.width * scale))),
                max(1, int(round(accent.height * scale))))
        accent = accent.resize(size, SMOOTH)
        # A7: soften the hard alpha edge without changing the dry RGB.
        alpha = accent.getchannel("A").filter(ImageFilter.GaussianBlur(0.6))
        accent.putalpha(alpha)
        px, py = float(sprite["pos"][0]) * w, float(sprite["pos"][1]) * h
        bbox = accent.getchannel("A").getbbox()
        if sprite.get("anchor", "foot") == "foot" and bbox:
            cx, fy = (bbox[0] + bbox[2]) / 2.0, bbox[3]
        else:
            cx, fy = accent.width / 2.0, accent.height / 2.0
        x, y = int(round(px - cx)), int(round(py - fy))
        # Contact shadow sits UNDER the rock: wide soft warm ellipse at the foot.
        shadow = Image.new("L", (w, h), 0)
        sd = ImageDraw.Draw(shadow)
        sd.ellipse((px - 46, py - 9, px + 46, py + 9), fill=96)
        shadow = shadow.filter(ImageFilter.GaussianBlur(5))
        shade = Image.new("RGBA", (w, h), (58, 50, 33, 0))
        shade.putalpha(shadow)
        canvas.alpha_composite(shade)
        shared.paste_rgba(canvas, accent, x, y)
        detail["sprite"] = {"name": sprite["name"], "source": str(accent_path),
                            "spec_scale": sprite.get("scale", 1.0),
                            "used_scale": scale, "pos": sprite["pos"],
                            "foot_px": [x, y], "size_px": list(size),
                            "ink_frac_expected": round(SOURCE_INK_FRACTION * scale ** 2, 4),
                            "alpha_blur_px": 0.6,
                            "contact_shadow_ellipse_px": [92, 18], "shadow_blur_px": 5}
        detail["sprite_grade"] = _sprite_dry_grade(accent_path)

    return canvas.convert("RGB"), detail


# ---------------------------------------------------------------------------
# measurement
# ---------------------------------------------------------------------------
def measure(img: Image.Image) -> dict[str, Any]:
    a = img.convert("RGB").resize((200, 200), RESAMPLE)
    arr = np.asarray(a).astype(np.float64)
    luma = np.asarray(a.convert("L")).astype(np.float64)
    blur = np.asarray(a.convert("L").filter(ImageFilter.GaussianBlur(5))).astype(np.float64)
    bins = np.histogram(luma, bins=8, range=(0, 256))[0] / luma.size * 100.0
    rgb = arr.reshape(-1, 3)
    order = (rgb[:, 0] > rgb[:, 1]) & (rgb[:, 1] > rgb[:, 2])
    return {
        "mean_rgb": [round(float(arr[:, :, c].mean()), 2) for c in range(3)],
        "median_rgb": [int(round(np.median(arr[:, :, c]))) for c in range(3)],
        "mean_hex": "#%02X%02X%02X" % tuple(
            _clamp255(arr[:, :, c].mean()) for c in range(3)),
        "L_mean": round(float(luma.mean()), 2),
        "L_std": round(float(luma.std()), 2),
        "hifreq": round(float(np.abs(luma - blur).mean()), 2),
        "bins_pct": [round(float(v), 2) for v in bins],
        "rgb_order_pct": round(float(order.mean()) * 100.0, 2),
        "dark_L_lt90_pct": round(float((luma < 90).mean()) * 100.0, 2),
        "bright_L_ge128_pct": round(float((luma >= 128).mean()) * 100.0, 2),
    }


def patch_interior_hifreq(img: Image.Image, spec: dict[str, Any],
                          threshold: int = 220) -> dict[str, Any]:
    """C5 in the DONOR convention: 200² downsample + 5 px Gaussian blur.

    Both the render and the patch mask are downsampled identically; fully
    covered interior pixels (mask>220) are selected so boundary bleed is
    excluded. This is directly comparable to the donor desert2 200² hi-freq
    of 8.42 measured by t6_t15_probe.py. (The v3 report's 7.12 was measured
    at 512² by mistake — this function corrects that methodology.)
    """
    patches = next(l for l in spec["layers"] if l.get("type") == "patches")
    mask, core = _organic_patch_mask(512, 512, int(patches.get("seed", 7)))
    inner = np.asarray(mask.resize((200, 200), RESAMPLE)) > threshold
    small = img.convert("RGB").resize((200, 200), RESAMPLE)
    luma = np.asarray(small.convert("L")).astype(np.float64)
    blur = np.asarray(small.convert("L").filter(ImageFilter.GaussianBlur(5))).astype(np.float64)
    return {
        "patch_interior_hifreq": round(float(np.abs(luma - blur)[inner].mean()), 2),
        "patch_interior_pct_of_frame": round(float(inner.mean()) * 100.0, 2),
        "core_fraction_at_512": round(core, 4),
        "donor_desert2_reference_hifreq": 8.42,
        "method": "200² bilinear render+mask, |L-Blur5| on mask>220 px",
    }


def subbox_luma(img: Image.Image, sprite_box: tuple[int, int, int, int] | None = None,
                n: int = 40) -> dict[str, Any]:
    a = np.asarray(img.convert("L")).astype(np.float64)
    if sprite_box is not None:
        x, y, sw, sh = sprite_box
        a = a.copy()
        a[max(0, y - 4):y + sh + 4, max(0, x - 4):x + sw + 4] = np.nan
    cell = 512 // n
    rows = []
    for gy in range(n):
        band = a[gy * cell:(gy + 1) * cell, :cell * n]
        for gx in range(n):
            part = band[:, gx * cell:(gx + 1) * cell]
            if not np.isfinite(part).any():
                continue
            rows.append(float(np.nanmean(part)))
    return {"subbox_min_L": round(min(rows), 2),
            "subbox_max_L": round(max(rows), 2),
            "subbox_mean_L": round(float(np.mean(rows)), 2),
            "subbox_std_L": round(float(np.std(rows)), 2),
            "subbox_count": len(rows)}


def verify_source() -> dict[str, Any]:
    donor_dir = Path(os.environ.get("C3_DONOR_DIR", r"C:\Games\Cossacks 3\data\terrain\tiles\textures"))
    result: dict[str, Any] = {"donor_dir": str(donor_dir), "matches": 0}
    for i in range(1, 13):
        d, p = donor_dir / f"desert{i}.dds", BLOCKS / f"desert{i}.png"
        if not (d.is_file() and p.is_file()):
            result[f"desert{i}"] = "missing"
            continue
        with Image.open(d) as di, Image.open(p) as pi:
            a = hashlib.md5(np.asarray(di.convert("RGB")).tobytes()).hexdigest()
            b = hashlib.md5(np.asarray(pi.convert("RGB")).tobytes()).hexdigest()
        result[f"desert{i}"] = "MATCH" if a == b else "MISMATCH"
        result["matches"] += int(a == b)
    return result


def reference_crop(spec: dict[str, Any], ref_root: Path, w: int, h: int) -> tuple[Image.Image, list[int]]:
    """DEPRECATED: the spec's 33 px MADV strip stretched 10x is a degenerate A/B panel.

    Kept only for reproducibility of the old sheet; `main()` now uses the valid
    donor-tile ground truth panel below.
    """
    ref = spec["reference"]
    box = [int(v) for v in ref["box"]]
    with Image.open(ref_root / ref["image"]) as im:
        crop = im.convert("RGB").crop(tuple(box))
    return crop.resize((w, h), RESAMPLE), box


# Real donor ground truth, read-only. Cossacks 3 has no desert-biome screenshot
# in the reference folder, so the four measured desert tiles are shown directly
# as a labelled contact sheet instead of a stretched 33 px building strip.
DONOR_TRUTH_TILES = ("desert6", "desert2", "desert3", "desert4")
DONOR_TRUTH_CROP = (256, 256, 768, 768)   # 512² centre crop of each 1024² DDS


def donor_ground_truth(donor_dir: Path, size: int = 512) -> Image.Image:
    """2x2 labelled contact sheet of genuine donor desert tiles (private use).

    Only READS the donor DDS by path — nothing is written into the repo except
    the final comparison PNG, which is a diagnostic staging shot.
    """
    half = size // 2
    panel = Image.new("RGB", (size, size))
    font = shared._font(11)
    for index, name in enumerate(DONOR_TRUTH_TILES):
        path = donor_dir / (name + ".dds")
        with Image.open(path) as im:
            crop = im.convert("RGB").crop(DONOR_TRUTH_CROP).resize((half, half), RESAMPLE)
        ox, oy = (index % 2) * half, (index // 2) * half
        panel.paste(crop, (ox, oy))
        draw = ImageDraw.Draw(panel)
        label = f"{name}  crop {DONOR_TRUTH_CROP}"
        box = draw.textbbox((0, 0), label, font=font)
        tw, th = box[2] - box[0], box[3] - box[1]
        draw.rectangle((ox + 3, oy + 3, ox + tw + 9, oy + th + 7), fill=(18, 20, 24))
        draw.text((ox + 6, oy + 4), label, font=font, fill=(238, 214, 168))
    draw = ImageDraw.Draw(panel)
    draw.line((half - 1, 0, half - 1, size), fill=(24, 26, 30), width=2)
    draw.line((0, half - 1, size, half - 1), fill=(24, 26, 30), width=2)
    return panel


def build_donor_comparison(name: str, render: Image.Image, donor_panel: Image.Image,
                           seed: int, layers: list[dict[str, Any]]) -> Image.Image:
    """Labelled [PORT RENDER | DONOR GROUND TRUTH] sheet with an honest caption."""
    w, h = render.size
    pad, gap, header, caption = 12, 14, 44, 30
    sheet = Image.new("RGB", (pad * 2 + w * 2 + gap, pad * 2 + header + h + caption),
                      (22, 24, 28))
    draw = ImageDraw.Draw(sheet)
    types = ", ".join(dict.fromkeys(str(l["type"]) for l in layers)) or "none"
    draw.text((pad, pad),
              f"{name}   seed={seed}   {w}x{h}   layers: {types}   (Pillow, no Godot)",
              font=shared._font(15), fill=(232, 236, 242))
    top = pad + header
    sheet.paste(render, (pad, top))
    sheet.paste(donor_panel, (pad + w + gap, top))
    draw.rectangle((pad - 1, top - 1, pad + w, top + h), outline=(96, 102, 112))
    draw.rectangle((pad + w + gap - 1, top - 1, pad + w * 2 + gap, top + h),
                   outline=(96, 102, 112))
    draw.text((pad, top + h + 6), "PORT RENDER (deterministic)",
              font=shared._font(13), fill=(150, 220, 168))
    draw.text((pad + w + gap, top + h + 6),
              "DONOR GROUND TRUTH: desert6 / 2 / 3 / 4 tiles, centre crop 256:768 (read-only)",
              font=shared._font(12), fill=(240, 198, 140))
    return sheet


# ---------------------------------------------------------------------------
# driver
# ---------------------------------------------------------------------------
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out-dir", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--metrics-out", type=Path, default=None)
    ap.add_argument("--no-compare", action="store_true")
    ap.add_argument("--ref-dir", type=Path,
                    default=Path(os.environ.get("C3_REFERENCE_DIR", str(DEFAULT_REF_ROOT))))
    ap.add_argument("--donor-dir", type=Path,
                    default=Path(os.environ.get("C3_DONOR_DIR",
                                               r"C:\Games\Cossacks 3\data\terrain\tiles\textures")))
    args = ap.parse_args()

    spec, _ = load_spec()
    w, h = (int(v) for v in spec["size_px"])
    render, detail = bake(spec)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    out_png = args.out_dir / (PIECE + ".png")
    render.save(out_png, format="PNG", optimize=True)

    metrics: dict[str, Any] = {
        "piece": PIECE, "generator": "t6_desert_variant.py",
        "spec": str(SPEC_PATH),
        "sha256": hashlib.sha256(out_png.read_bytes()).hexdigest(),
        "detail": detail, "final": measure(render),
        "base_only": measure(bake(spec, with_patches=False, with_glaze=False,
                                  with_sprite=False)[0]),
        "base_plus_patches": measure(bake(spec, with_patches=True, with_glaze=False,
                                          with_sprite=False)[0]),
    }
    no_sprite, _ = bake(spec, with_sprite=False)
    diff = ImageChops.difference(render, no_sprite).convert("L")
    metrics["sprite_ink_pct_of_frame"] = round(float((np.asarray(diff) > 3).mean()) * 100.0, 2)
    x, y = detail["sprite"]["foot_px"]
    sw, sh = detail["sprite"]["size_px"]
    metrics["subbox_all"] = subbox_luma(render)
    metrics["subbox_ground_only"] = subbox_luma(render, (x, y, sw, sh))
    metrics["c5_patch"] = patch_interior_hifreq(render, spec)

    compare_png = None
    if not args.no_compare:
        donor_dir = args.donor_dir.expanduser().resolve()
        panel = donor_ground_truth(donor_dir, w)
        sheet = build_donor_comparison(
            PIECE, render, panel, int(spec["seed"]),
            [{"type": t} for t in ("block", "patches", "glaze", "sprite")])
        compare_png = args.out_dir / (PIECE + "_compare.png")
        sheet.save(compare_png, format="PNG", optimize=True)
        metrics["compare_sha256"] = hashlib.sha256(compare_png.read_bytes()).hexdigest()
        metrics["reference"] = {
            "mode": "donor_tile_ground_truth",
            "note": "replaces the degenerate 33 px MADV strip stretched ~10x",
            "tiles": list(DONOR_TRUTH_TILES), "crop_xyxy": list(DONOR_TRUTH_CROP),
            "root": str(donor_dir), "private_use_read_only": True,
        }

    if args.metrics_out:
        args.metrics_out.parent.mkdir(parents=True, exist_ok=True)
        args.metrics_out.write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    print(json.dumps(metrics, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
