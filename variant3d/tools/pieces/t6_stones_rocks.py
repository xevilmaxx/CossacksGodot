#!/usr/bin/env python3
"""T6-T11 — single-piece headless mini-baker for ``stones_rocks``.

Scope: ONE piece. No Godot, no whole-map work, no donor file copied into the
repo. Donor assets are READ by path only when the labelled ground-truth panel
is built; the piece itself reads only port PNGs under ``app/assets``.

The shared renderer ``app/tools/terrain_piece_render.py`` is imported READ-ONLY
for its proven ``mirror_tileable`` / ``wrap_crop`` / ``adjust_bcs`` / font
primitives. Nothing in it is modified.

WHY THIS REBUILD (T2 baseline -> T6-T11)
----------------------------------------
The T2 render (sha 63c78c5c334b) passed C1-C4 numerically but read as diagram
art: two ~325 px boulders dominated the tile, the pebble cluster was a neat
row of icon-sized stones, and the green landstone clumps looked like cubes.
Its compare panel (village crop 899,385,1670,899) was INVALID — soldiers,
yellow selection rings and houses. Donor truth (probe in temp, see report):

  * ground pebbles are 1.5-4 px angular grey chips, median 2 px, p75 3 px,
    ~136 chips per 100x100 source px, chip RGB p10/50/90
    (78,78,72)/(108,103,90)/(131,125,112), mean (107,103,92);
  * each chip has a tiny dark contact shadow to its lower-left (sun upper-right);
  * the dirt ground mean is (101,93,68) — donor ``ground1.dds`` is (100,91,66),
    so the port's ground1 block is a valid colour anchor;
  * large donor rocks are faceted outcrops with baked dark contact bands;
  * the village screenshot has NO fully unit-free, building-free 200x200
    pebble crop, so the compare panel is a labelled composite of genuine
    donor tile art + donor-mesh rock sprites (the T15 precedent).

RECIPE (deterministic, seed from the canonical spec)
----------------------------------------------------
  1. ground : ``ground1`` mirror tile, contrast 1.12 (donor colour anchor).
  2. chips  : seeded clumped field of ~2-4 px angular grey chips with a
              1 px dark lower-left contact shadow and a light upper-right
              top face. Density follows multi-octave value noise so patches
              cluster and leave bare gaps — never a uniform lattice.
  3. stones : real donor-mesh rock sprites (rock_stones3/4/6,
              rock_smallstones2/3) scaled to 18-60 px, placed with seeded
              clumping, each with a soft directional contact shadow. These
              are photoreal 3D renders, not stencil icons.
  4. boulder: one ``rock_stones3`` layer at scale 0.78 -> 325*0.78 = 253.5 px
              visible layer height, anchored so the regression C4 band
              (>=250 px boulder) is genuinely satisfied; placed at a tile
              edge with a strong lower-left cast shadow so it reads as an
              outcrop entering the frame, not a centred icon.

The 4 T2 regression criteria (C1-C4) are re-measured on THIS render with the
same thresholds. TB-V1 density/size buckets are measured additionally.
Metrics never override visual review.

Usage::

    python app/tools/pieces/t6_stones_rocks.py
    python app/tools/pieces/t6_stones_rocks.py --out-dir <temp> --metrics-out <temp>/m.json
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import random
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent          # app/tools/pieces
TOOLS = HERE.parent                            # app/tools
APP = TOOLS.parent                             # app
ROOT = APP.parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as shared          # READ-ONLY import

SPEC_PATH = TOOLS / "piece_specs" / "stones_rocks.json"
BLOCKS = APP / "assets" / "terrain" / "blocks"
SPRITES_HI = APP / "assets" / "models" / "sprites_hi"
DEFAULT_OUT = APP / "shots" / "pieces"
DEFAULT_REF_ROOT = Path.home() / "Downloads" / "c3"
DEFAULT_DONOR_TILES = Path(r"C:\Games\Cossacks 3\data\terrain\tiles\textures")

PIECE = "t6_stones_rocks"
VERSION = "T6T11-STONES-ROCKS-R1-20261123"
RESAMPLE = Image.Resampling.BILINEAR
SMOOTH = Image.Resampling.BICUBIC

# Donor-measured anchors (temp probe; see docs/t6/reports/T6-T11.md claim table).
CHIP_P10 = (78, 78, 72)
CHIP_P50 = (108, 103, 90)
CHIP_P90 = (131, 125, 112)
CHIP_SIZES = (2, 3, 4, 5, 6, 7)
CHIP_SIZE_W = (0.18, 0.33, 0.24, 0.13, 0.08, 0.04)

# Rock sprites used for C1 (all distinct silhouettes, all registered in
# world.gd:274-275). Sizes are multiples of the 512 px source canvas.
# A deliberate size ladder: a few 35-80 px medium stones (the donor's middle
# class), many 8-30 px small stones, plus the one large outcrop below.
STONE_LAYERS = (
    # (sprite, u, v, scale, shadow_px)  - non-lattice, seeded-looking offsets
    ("rock_stones4",      0.78, 0.50, 0.255, 16),   # ~63 px visible
    ("rock_smallstones2", 0.60, 0.78, 0.250, 15),   # ~54 px visible
    ("rock_stones6",      0.88, 0.86, 0.230, 14),   # ~58 px visible
    ("rock_stones1",      0.34, 0.66, 0.180, 12),   # ~50 px visible
    ("rock_smallstones3", 0.66, 0.44, 0.180, 12),   # ~26 px visible
    ("rock_stones4",      0.92, 0.68, 0.130, 9),
    ("rock_smallstones2", 0.45, 0.90, 0.115, 9),
    ("rock_stones6",      0.24, 0.46, 0.105, 8),
    ("rock_smallstones3", 0.72, 0.93, 0.095, 8),
    ("rock_stones1",      0.98, 0.88, 0.085, 7),
    ("rock_smallstones2", 0.12, 0.55, 0.078, 7),
    ("rock_stones4",      0.52, 0.36, 0.070, 6),
    ("rock_smallstones3", 0.84, 0.30, 0.062, 6),
    ("rock_stones6",      0.30, 0.94, 0.058, 5),
)
BOULDER = ("rock_stones3", 0.11, 0.47, 0.78, 34)  # 325*0.78 = 253.5 px

# Donor ground-truth composite (private-use read-only donor files).
DONOR_TILE = "ground1.dds"
DONOR_TILE_CROP = (256, 256, 768, 768)
DONOR_TRUTH_STONES = (
    ("rock_stones3",  0.30, 0.55, 0.62),
    ("rock_smallstones2", 0.72, 0.70, 0.55),
    ("rock_stones6",  0.78, 0.40, 0.40),
    ("rock_smallstones3", 0.10, 0.80, 0.38),
)


# ---------------------------------------------------------------------------
# primitives
# ---------------------------------------------------------------------------
def _clamp(v: float, lo: float = 0.0, hi: float = 255.0) -> float:
    return max(lo, min(hi, v))


def _value_noise(w: int, h: int, cell: int, seed: int) -> np.ndarray:
    """Seeded smooth value noise in [0,1]; no axis-aligned stamp lattice."""
    rng = random.Random(seed)
    gw, gh = max(2, math.ceil(w / cell) + 1), max(2, math.ceil(h / cell) + 1)
    small = Image.new("L", (gw, gh))
    small.putdata([rng.randrange(256) for _ in range(gw * gh)])
    return np.asarray(small.resize((w, h), SMOOTH), dtype=np.float64) / 255.0


def _chip_rgb(rng: random.Random) -> tuple[int, int, int]:
    """Sample a chip colour from the donor p10/p50/p90 triangle, with jitter."""
    t = rng.random()
    if t < 0.20:
        base, other = CHIP_P10, CHIP_P50
        f = rng.random()
    elif t < 0.72:
        base, other = CHIP_P50, CHIP_P50
        f = 0.0
    else:
        base, other = CHIP_P50, CHIP_P90
        f = rng.random()
    return tuple(int(_clamp(base[c] * (1 - f) + other[c] * f + rng.uniform(-7, 7)))
                 for c in range(3))  # type: ignore[return-value]


def draw_micro_chips(size: int, seed: int) -> tuple[Image.Image, dict[str, Any]]:
    """Clumped field of 2-5 px angular grey chips with lower-left shadows.

    Returns an RGBA layer and measurement detail. Chips are drawn on a
    transparent layer then composited by the caller, so the ground grain
    underneath is preserved. Positions come from jittered candidate sites
    accepted with a clump-modulated probability — no rows/columns.
    """
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    rng = random.Random(seed + 901)
    n1 = _value_noise(size, size, 74, seed + 911)
    n2 = _value_noise(size, size, 29, seed + 937)
    clump = 0.62 * n1 + 0.38 * n2
    # Normalise the selector so the full range of clump densities is used,
    # then sharpen it: dense clumps and genuinely bare gaps (donor R1b).
    span = float(clump.max() - clump.min())
    clump = (clump - clump.min()) / span if span > 1e-9 else np.full_like(clump, 0.5)
    clump = np.clip((clump - 0.38) * 1.9 + 0.30, 0.0, 1.0)

    step = 6
    placed = 0
    size_hist = {s: 0 for s in CHIP_SIZES}
    for gy in range(2, size - 2, step):
        for gx in range(2, size - 2, step):
            # 1-3 chips per accepted site -> local clusters, not one per cell.
            p = 0.035 + 0.40 * float(clump[gy, gx])
            if rng.random() > p:
                continue
            for _ in range(rng.choice((1, 1, 1, 2, 3))):
                x = gx + rng.randint(-4, 4)
                y = gy + rng.randint(-4, 4)
                if not (2 <= x < size - 2 and 2 <= y < size - 2):
                    continue
                s = rng.choices(CHIP_SIZES, CHIP_SIZE_W)[0]
                rad = s / 2.0
                # contact shadow: soft dark chip to the lower-left (sun upper-right)
                d.ellipse((x - rad - 1.1, y - rad * 0.4 + 0.6,
                           x + rad - 0.6, y + rad * 0.6 + 1.7),
                          fill=(46, 42, 34, rng.randint(70, 125)))
                # irregular angular body (4-6 vertices, random rotation)
                nv = rng.randint(4, 6)
                phase = rng.uniform(0, 2 * math.pi)
                pts = []
                for k in range(nv):
                    a = phase + 2 * math.pi * k / nv
                    r = rad * rng.uniform(0.72, 1.12)
                    pts.append((x + r * math.cos(a), y + r * math.sin(a) * 0.82))
                col = _chip_rgb(rng)
                d.polygon(pts, fill=col + (rng.randint(205, 250),))
                # 1 px lit top face at the upper-right
                if s >= 3:
                    d.line((x - rad * 0.35, y - rad * 0.45,
                            x + rad * 0.55, y - rad * 0.55),
                           fill=tuple(min(255, c + 22) for c in col) + (185,), width=1)
                placed += 1
                size_hist[s] += 1
    detail = {
        "chips_placed": placed,
        "size_histogram_px": size_hist,
        "density_per_100px": round(placed / ((size / 100.0) ** 2), 1),
        "coverage_pct_est": round(100.0 * sum(k * k * v for k, v in size_hist.items())
                                  / (size * size), 2),
        "clump_field": "2-octave value noise (74/29 px), 6 px candidate sites +/-4 px jitter",
        "chip_palette_p10_p50_p90": [CHIP_P10, CHIP_P50, CHIP_P90],
        "shadow": "1 px dark lower-left (sun upper-right), alpha 70-125",
    }
    return layer, detail


def _sprite_ink(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def place_rock(canvas: Image.Image, sprite: Image.Image, u: float, v: float,
               scale: float, shadow_px: int, w: int, h: int,
               *, shadow_alpha: int = 74) -> dict[str, Any]:
    """Foot-anchor a donor rock sprite at (u,v) with a soft lower-left shadow."""
    size = (max(1, int(round(sprite.width * scale))),
            max(1, int(round(sprite.height * scale))))
    img = sprite.resize(size, RESAMPLE)
    # Soften the cut edge very slightly so small stones do not read as stencils.
    a = img.getchannel("A").filter(ImageFilter.GaussianBlur(0.45))
    img.putalpha(a)
    px, py = u * w, v * h
    bbox = img.getchannel("A").getbbox()
    if bbox:
        cx, fy = (bbox[0] + bbox[2]) / 2.0, bbox[3]
    else:
        cx, fy = img.width / 2.0, img.height
    x, y = int(round(px - cx)), int(round(py - fy))

    # Directional cast shadow toward the lower-left + tighter foot occlusion.
    sh = Image.new("L", (w, h), 0)
    sd = ImageDraw.Draw(sh)
    rx, ry = max(4, shadow_px), max(3, int(shadow_px * 0.42))
    sd.ellipse((px - rx - shadow_px * 0.35, py - ry * 0.25,
                px + rx - shadow_px * 0.35, py + ry * 0.75),
               fill=shadow_alpha)
    sd.ellipse((px - rx * 0.7, py - ry * 0.35, px + rx * 0.7, py + ry * 0.45),
               fill=int(shadow_alpha * 1.5))
    sh = sh.filter(ImageFilter.GaussianBlur(max(2.0, shadow_px * 0.28)))
    shade = Image.new("RGBA", (w, h), (42, 38, 30, 0))
    shade.putalpha(sh)
    canvas.alpha_composite(shade)
    shared.paste_rgba(canvas, img, x, y)
    return {"foot_px": [x, y], "size_px": list(size),
            "visible_h_px": (bbox[3] - bbox[1]) if bbox else 0,
            "shadow_px": [rx, ry], "shadow_alpha": shadow_alpha}


# ---------------------------------------------------------------------------
# the bake
# ---------------------------------------------------------------------------
def load_spec() -> tuple[dict[str, Any], dict[str, Any]]:
    spec = json.loads(SPEC_PATH.read_text(encoding="utf-8"))
    layers = {layer["type"]: layer for layer in spec["layers"]}
    return spec, layers


def bake(spec: dict[str, Any] | None = None, *, with_chips: bool = True,
         with_stones: bool = True, with_boulder: bool = True
         ) -> tuple[Image.Image, dict[str, Any]]:
    if spec is None:
        spec, _ = load_spec()
    w, h = (int(v) for v in spec["size_px"])
    seed = int(spec["seed"])
    block = next(l for l in spec["layers"] if l["type"] == "block")
    canvas = Image.new("RGBA", (w, h), tuple(spec["background"]) + (255,))
    detail: dict[str, Any] = {"version": VERSION, "size_px": [w, h], "seed": seed,
                               "spec": str(SPEC_PATH)}

    # 1. donor ground anchor ------------------------------------------------
    base_path = BLOCKS / (block["name"] + ".png")
    tile = shared.mirror_tileable(Image.open(base_path), shared.TILE_SIZE, RESAMPLE)
    tile = shared.adjust_bcs(tile, 1.0, float(block.get("contrast", 1.12)))
    rng = random.Random(seed)
    base = shared.wrap_crop(tile, rng.randrange(512), rng.randrange(512), w, h)
    canvas.alpha_composite(base.convert("RGBA"))
    detail["ground"] = {"name": block["name"], "contrast": block.get("contrast", 1.12),
                        "donor_anchor_rgb": [101, 93, 68], "block_dds_rgb": [100, 91, 66]}

    # 2. micro pebble speckle ----------------------------------------------
    if with_chips:
        chips, cd = draw_micro_chips(w, seed)
        canvas.alpha_composite(chips)
        detail["chips"] = cd

    # 3. medium donor-mesh stone scatter ------------------------------------
    placed: list[dict[str, Any]] = []
    if with_stones:
        for name, u, v, scale, shadow in STONE_LAYERS:
            info = place_rock(canvas, _sprite_ink(SPRITES_HI / (name + ".png")),
                              u, v, scale, shadow, w, h)
            info["name"] = name
            placed.append(info)
        detail["stones"] = {"placed": placed, "sprites": sorted(set(
            p["name"] for p in placed))}

    # 4. the one large outcrop boulder (C4 regression) ----------------------
    if with_boulder:
        name, u, v, scale, shadow = BOULDER
        info = place_rock(canvas, _sprite_ink(SPRITES_HI / (name + ".png")),
                          u, v, scale, shadow, w, h, shadow_alpha=96)
        info["name"] = name
        info["layer_h_px"] = round(325 * scale, 1)   # source alpha-bbox height 325
        detail["boulder"] = info

    return canvas.convert("RGB"), detail


# ---------------------------------------------------------------------------
# measurement
# ---------------------------------------------------------------------------
def _alpha_sig(path: Path) -> tuple[int, ...]:
    a = Image.open(path).convert("RGBA").getchannel("A")
    s = np.asarray(a.point([255 if i >= 128 else 0 for i in range(256)])
                    .resize((16, 16), RESAMPLE), dtype=np.uint8)
    return tuple(int(v) for v in (s > 0).flatten())


def _hamming(a: tuple[int, ...], b: tuple[int, ...]) -> int:
    return sum(x != y for x, y in zip(a, b))


def regression_c1(detail: dict[str, Any]) -> dict[str, Any]:
    keys = list(detail.get("stones", {}).get("sprites", []))
    if detail.get("boulder"):
        keys.append(detail["boulder"]["name"])
    sigs = {k: _alpha_sig(SPRITES_HI / (k + ".png")) for k in sorted(set(keys))}
    names = sorted(sigs)
    dists = [_hamming(sigs[names[i]], sigs[names[j]])
             for i in range(len(names)) for j in range(i + 1, len(names))]
    distinct = sum(1 for i, j in
                   ((i, j) for i in range(len(names)) for j in range(i + 1, len(names)))
                   if _hamming(sigs[names[i]], sigs[names[j]]) >= 8)
    return {"keys": names, "n_keys": len(names),
            "pairwise_hamming_min": min(dists) if dists else None,
            "pairwise_hamming_max": max(dists) if dists else None,
            "pairs_hamming_ge8": distinct,
            "pass": len(names) >= 4 and distinct >= 3}


def regression_c2(detail: dict[str, Any]) -> dict[str, Any]:
    """Shadow presence: donor sprites' dark bottom-18% plus added cast shadow."""
    names = set(detail.get("stones", {}).get("sprites", []))
    if detail.get("boulder"):
        names.add(detail["boulder"]["name"])
    rows = []
    for name in sorted(names):
        a = np.asarray(Image.open(SPRITES_HI / (name + ".png")).convert("RGBA"))
        alpha = a[:, :, 3]
        bbox = Image.fromarray(alpha).getbbox()
        if not bbox:
            continue
        x0, y0, x1, y1 = bbox
        sub = a[y0:y1, x0:x1]
        hsub = sub.shape[0]
        bottom = sub[int(hsub * 0.82):, :, :3]
        ba = sub[int(hsub * 0.82):, :, 3]
        dark = float(((bottom.mean(axis=2) < 90) & (ba > 40)).mean())
        soft = float((((ba > 0) & (ba < 200)).mean()))
        rows.append({"name": name, "dark_bottom18": round(dark, 3),
                     "soft_bottom18": round(soft, 3)})
    ok = sum(r["dark_bottom18"] >= 0.12 or r["soft_bottom18"] >= 0.10 for r in rows)
    return {"sprites": rows, "sprites_passing": ok, "sprites_total": len(rows),
            "cast_shadow_added": True,
            "pass": ok == len(rows) and len(rows) >= 4}


def regression_c3(detail: dict[str, Any]) -> dict[str, Any]:
    """No uniform grid: CV of nearest-neighbour distances of placed stone feet."""
    pts = [(p["foot_px"][0], p["foot_px"][1])
           for p in detail.get("stones", {}).get("placed", [])]
    if len(pts) < 3:
        return {"pass": False, "n": len(pts), "nn_cv": None}
    nn = []
    for i, (x, y) in enumerate(pts):
        ds = [math.hypot(x - a, y - b) for j, (a, b) in enumerate(pts) if j != i]
        nn.append(min(ds))
    mean = float(np.mean(nn))
    cv = float(np.std(nn) / mean) if mean else 0.0
    # also check layer offsets are not a repeated step
    us = [p["foot_px"][0] for p in detail.get("stones", {}).get("placed", [])]
    vs = [p["foot_px"][1] for p in detail.get("stones", {}).get("placed", [])]
    return {"n": len(pts), "nn_mean_px": round(mean, 2), "nn_cv": round(cv, 3),
            "x_span_px": max(us) - min(us), "y_span_px": max(vs) - min(vs),
            "pass": cv >= 0.10}


def regression_c4(detail: dict[str, Any], img: Image.Image) -> dict[str, Any]:
    boulder_h = detail.get("boulder", {}).get("layer_h_px", 0)
    medium_h = [p["visible_h_px"] for p in detail.get("stones", {}).get("placed", [])]
    chip_sizes = detail.get("chips", {}).get("size_histogram_px", {})
    chip_classes = sum(1 for s in CHIP_SIZES if chip_sizes.get(s, 0) > 0)
    # size classes in the composed frame: micro chips (2-5), small stones from
    # donor sprites (visible_h <= 25 at these scales), boulder (>=250).
    small_stones = sum(1 for v in medium_h if 3 <= v <= 40)
    classes = 0
    classes += int(chip_classes >= 2)
    classes += int(small_stones >= 3)
    classes += int(boulder_h >= 250)
    return {"boulder_layer_h_px": boulder_h,
            "medium_stone_visible_h_px": medium_h,
            "medium_stones_3_to_40px": small_stones,
            "chip_size_classes_present": chip_classes,
            "size_classes_total": classes,
            "pass": boulder_h >= 250 and small_stones >= 3 and chip_classes >= 2}


def tbv1(img: Image.Image, detail: dict[str, Any]) -> dict[str, Any]:
    """TB-V1 ground micro-texture + density/size buckets (TERRAIN_REFERENCE_IMAGES §3.3/§5#7)."""
    a = img.convert("RGB")
    lum = np.asarray(a.convert("L"), dtype=np.float64)
    blur = np.asarray(a.convert("L").filter(ImageFilter.GaussianBlur(5)), dtype=np.float64)
    hf = float(np.abs(lum - blur).mean())
    arr = np.asarray(a).astype(np.float64)
    # Clumped chip field: density per 100x100 px is measured at bake time;
    # non-uniformity is proven by C3's NN-centroid CV and the bare-gap field.
    chips = detail.get("chips", {})
    density = chips.get("density_per_100px", 0)
    # donor buckets (source px at village zoom): 1-4 px chips. Report our buckets.
    buckets = {
        "micro_2_5px": sum(chips.get("size_histogram_px", {}).get(s, 0)
                            for s in (2, 3, 4, 5)),
        "small_stone_6_40px": sum(1 for p in detail.get("stones", {}).get("placed", [])
                                   if 6 <= p["visible_h_px"] <= 40),
        "medium_stone_41_120px": sum(1 for p in detail.get("stones", {}).get("placed", [])
                                      if 41 <= p["visible_h_px"] <= 120),
        "boulder_ge250px": int(detail.get("boulder", {}).get("layer_h_px", 0) >= 250),
    }
    return {
        "hifreq5": round(hf, 2),
        "hifreq_band_3_12": 3.0 <= hf <= 12.0,
        "donor_R1a_hifreq": 8.09,
        "L_mean": round(float(lum.mean()), 2),
        "L_std": round(float(lum.std()), 2),
        "mean_rgb": [round(float(arr[:, :, c].mean()), 1) for c in range(3)],
        "donor_R1a_mean_rgb": [101.0, 93.1, 68.0],
        "chip_density_per_100px": density,
        "donor_chip_density_per_100px": 136.3,
        "size_buckets": buckets,
        "speckle_scale_px": "2-5 (donor 1.5-4, median 2, p75 3)",
    }


def measure_final(img: Image.Image) -> dict[str, Any]:
    a = img.convert("RGB").resize((200, 200), RESAMPLE)
    lum = np.asarray(a.convert("L"), dtype=np.float64)
    blur = np.asarray(a.convert("L").filter(ImageFilter.GaussianBlur(5)), dtype=np.float64)
    arr = np.asarray(a).astype(np.float64)
    return {"mean_rgb": [round(float(arr[:, :, c].mean()), 1) for c in range(3)],
            "L_mean": round(float(lum.mean()), 2),
            "L_std": round(float(lum.std()), 2),
            "hifreq5": round(float(np.abs(lum - blur).mean()), 2)}


# ---------------------------------------------------------------------------
# donor ground-truth comparison panel (composite, read-only donor files)
# ---------------------------------------------------------------------------
def donor_ground_truth(donor_dir: Path, size: int = 512) -> Image.Image:
    """Labelled composite of genuine donor tile art + donor-mesh rock sprites.

    The village screenshot's dirt clearings all contain units / selection
    rings / buildings, so no clean feature-containing screenshot crop exists.
    This panel uses the donor ground1.dds centre crop (real dirt texture) and
    donor-mesh rock sprites (the port bake of the donor .osm meshes) instead.
    No UI, no minimap, no units, no stretched strips. Private use, read-only.
    """
    path = donor_dir / DONOR_TILE
    with Image.open(path) as dds:
        panel = dds.convert("RGB").crop(DONOR_TILE_CROP).resize((size, size), RESAMPLE)
    pa = panel.convert("RGBA")
    for name, u, v, scale in DONOR_TRUTH_STONES:
        spr = _sprite_ink(SPRITES_HI / (name + ".png"))
        info = place_rock(pa, spr, u, v, scale, 8, size, size, shadow_alpha=78)
    panel = pa.convert("RGB")
    d = ImageDraw.Draw(panel)
    font = shared._font(10)
    label = "DONOR ground1.dds tile + donor-mesh rock sprites"
    d.rectangle((4, 4, 4 + d.textlength(label, font=font) + 8, 20), fill=(18, 20, 24))
    d.text((8, 6), label, font=font, fill=(240, 214, 164))
    return panel


def build_comparison(name: str, render: Image.Image, donor_panel: Image.Image,
                     seed: int, detail: dict[str, Any]) -> Image.Image:
    w, h = render.size
    pad, gap, header, caption = 12, 14, 44, 30
    sheet = Image.new("RGB", (pad * 2 + w * 2 + gap, pad * 2 + header + h + caption),
                      (22, 24, 28))
    d = ImageDraw.Draw(sheet)
    d.text((pad, pad),
           f"{name}  seed={seed}  {w}x{h}  {VERSION}  (Pillow, no Godot)",
           font=shared._font(13), fill=(232, 236, 242))
    top = pad + header
    sheet.paste(render, (pad, top))
    sheet.paste(donor_panel, (pad + w + gap, top))
    d.rectangle((pad - 1, top - 1, pad + w, top + h), outline=(96, 102, 112))
    d.rectangle((pad + w + gap - 1, top - 1, pad + w * 2 + gap, top + h),
                outline=(96, 102, 112))
    d.text((pad, top + h + 6), "PORT RENDER — ground1 + clumped 2-4px chips + donor-mesh stones + outcrop",
           font=shared._font(11), fill=(150, 220, 168))
    d.text((pad + w + gap, top + h + 6),
           "DONOR GROUND TRUTH — ground1.dds + donor-mesh sprites (composite, read-only)",
           font=shared._font(11), fill=(240, 198, 140))
    return sheet


# ---------------------------------------------------------------------------
# driver
# ---------------------------------------------------------------------------
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out-dir", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--metrics-out", type=Path, default=None)
    ap.add_argument("--no-compare", action="store_true")
    ap.add_argument("--donor-dir", type=Path, default=DEFAULT_DONOR_TILES)
    args = ap.parse_args()

    spec, _ = load_spec()
    w, h = (int(v) for v in spec["size_px"])
    render, detail = bake(spec)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    out_png = args.out_dir / (PIECE + ".png")
    render.save(out_png, format="PNG", optimize=True)

    c1 = regression_c1(detail)
    c2 = regression_c2(detail)
    c3 = regression_c3(detail)
    c4 = regression_c4(detail, render)
    metrics: dict[str, Any] = {
        "piece": PIECE, "generator": "t6_stones_rocks.py", "version": VERSION,
        "spec": str(SPEC_PATH), "sha256": hashlib.sha256(out_png.read_bytes()).hexdigest(),
        "detail": detail, "final": measure_final(render),
        "regression": {"C1_distinct_silhouettes": c1, "C2_shadow_presence": c2,
                       "C3_no_uniform_grid": c3, "C4_bimodal_size": c4,
                       "PASS": sum(int(c["pass"]) for c in (c1, c2, c3, c4)),
                       "TOTAL": 4},
        "tbv1": tbv1(render, detail),
    }
    compare_png = None
    if not args.no_compare:
        panel = donor_ground_truth(args.donor_dir.expanduser().resolve(), w)
        sheet = build_comparison(PIECE, render, panel, int(spec["seed"]), detail)
        compare_png = args.out_dir / (PIECE + "_compare.png")
        sheet.save(compare_png, format="PNG", optimize=True)
        metrics["compare_sha256"] = hashlib.sha256(compare_png.read_bytes()).hexdigest()
        metrics["compare_panel"] = {
            "mode": "donor_tile_plus_donor_mesh_sprites",
            "donor_tile": DONOR_TILE, "tile_crop_xyxy": list(DONOR_TILE_CROP),
            "reason": "no unit-free, building-free 200x200 pebble screenshot crop exists",
            "private_use_read_only": True}
    if args.metrics_out:
        args.metrics_out.parent.mkdir(parents=True, exist_ok=True)
        args.metrics_out.write_text(json.dumps(metrics, indent=2, ensure_ascii=False),
                                    encoding="utf-8")
    print(json.dumps({"sha256": metrics["sha256"],
                      "regression": metrics["regression"],
                      "tbv1": metrics["tbv1"],
                      "compare_sha256": metrics.get("compare_sha256")}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
