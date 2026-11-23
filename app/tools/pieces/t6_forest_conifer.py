#!/usr/bin/env python3
"""T6-T08 — headless, deterministic mini-baker for the forest_conifer piece.

OWNED FILE (do not edit anything else in the swarm). No Godot is launched: the
piece is composed with Python 3.14 + Pillow + NumPy from port-owned PNG assets,
and the donor reference is only ever READ for the side-by-side sheet.

Scope: close the two visually decisive baseline FAILs of verdict_decor
(conifer 3/5) — tree count / size buckets (#3/#4) and directional contact
shadow (#6) — while holding the palette gains (#1/#2) and fixing the ground
tint (#7). Design truth is measured in docs/t6/reports/T6-T08.md.

Design (donor-derived, all labelled in the report):
  * tileable ``grass_ground2`` forest floor, contrast 1.12, then tinted down to
    donor forest floor #3B3F1B (grass_ground2 #535428 x ~0.75),
  * ~200 conifers per 512^2 (~760 trees/MP = donor dense-forest band),
    clumped by a seeded density field (NOT a uniform grid), 3 size buckets
    24-34 / 43-62 / 77-101 px at 60/30/10 %,
  * real donor-derived port sprites (spruce / pinesmall / firsmall, dry accent
    <=10 %) so the silhouette is an organic whorled spruce, not a stencil icon:
    mirror, per-tree brightness jitter, height jitter, and a soft "branch
    frosting" gain on the upper lit tips,
  * two crown colour families graded into the donor bands
    (dark spruce and lit fir; lit35 B/G >= 0.40, hue 58-69 deg, L 46-95),
  * one soft contact ellipse per tree, centroid lower-left of the foot,
    length ~1x tree height, lit/shadow luma ratio >= 1.5,
  * painter's order: lower trees drawn last (in front), giving forest depth.

``render(seed, with_trees)`` is the public entry point; ``with_trees=False``
returns the ground+shadow base so a caller can segment tree ink by difference.

Usage::

    python app/tools/pieces/t6_forest_conifer.py
    python app/tools/pieces/t6_forest_conifer.py --out-dir /tmp/pieces
"""
from __future__ import annotations

import argparse
import colorsys
import hashlib
import json
import math
import random
import sys
from collections import deque
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# The shared renderer is READ-ONLY. Import its tile primitives so the ground
# matches the port's mirror-tile + wrap-crop + adjust_bcs path exactly.
TOOLS = Path(__file__).resolve().parents[1]
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as tpr  # noqa: E402

ROOT = TOOLS.parent
ASSETS = ROOT / "assets"
BLOCKS_DIR = ASSETS / "terrain" / "blocks"
SPRITES_HI_DIR = ASSETS / "models" / "sprites_hi"
DEFAULT_OUT = ROOT / "shots" / "pieces"
DEFAULT_REF = Path.home() / "Downloads" / "c3"

W = H = 512
SEED = 7
MP = 1_000_000.0 / (W * H)

# ---------------------------------------------------------------------------
# Donor-derived constants (measured — see docs/t6/reports/T6-T08.md)
# ---------------------------------------------------------------------------
# Forest floor: grass_ground2 (83,84,40) x ~0.75 -> (60,66,34) ~= donor
# #3B3F1B (59,63,27), nudged +3G/+7B so the whole frame clears the global
# HSV gate (sat 0.30-0.55, value 0.25-0.45).
GROUND_TINT = (0.78, 0.86, 1.12)
GROUND_SAT_GUARD = 0.55

# Per-species RGB grade. Values chosen so the lit35 crown mean lands inside
# donor bands: dark spruce lit ~#3B4130..#52533A, lit fir lit ~#61683A..#6B6A38.
# family: "dark" (near-black spruce/pine) or "lit" (bright fir tips).
# frost: add a small upper-crown gain (branch frosting) to mimic lit tips.
CONIFERS: tuple[tuple[str, str, tuple[float, float, float], str, float, bool], ...] = (
    ("tree_spruce1",    "spruce",    (1.00, 1.04, 1.12), "dark", 1.00, False),
    ("tree_spruce2",    "spruce",    (0.93, 1.02, 1.12), "dark", 1.02, False),
    ("tree_spruce3",    "spruce",    (1.00, 1.30, 1.58), "dark", 0.98, False),
    ("tree_spruce4",    "spruce",    (1.00, 1.07, 1.10), "dark", 1.00, False),
    ("tree_pinesmall1", "pinesmall", (1.28, 1.32, 1.40), "dark", 0.95, False),
    ("tree_pinesmall2", "pinesmall", (1.10, 0.96, 1.08), "dark", 0.95, False),
    ("tree_pinesmall4", "pinesmall", (1.28, 1.30, 1.36), "dark", 0.95, False),
    ("tree_firsmall1",  "firsmall",  (0.90, 0.90, 1.02), "lit",  0.95, True),
    ("tree_firsmall2",  "firsmall",  (0.95, 0.90, 1.02), "lit",  0.95, True),
    ("tree_firsmall3",  "firsmall",  (0.92, 0.92, 1.02), "lit",  0.95, True),
    ("tree_firsmall4",  "firsmall",  (0.90, 0.90, 1.02), "lit",  0.95, True),
)
DRY: tuple[tuple[str, str, tuple[float, float, float], str, float, bool], ...] = (
    # hold native pinedry2 hue ~38.6 deg (donor dry accent 37-38), lift B a touch.
    ("tree_pinedry2", "dry", (1.00, 1.00, 1.05), "dry", 1.00, False),
)

SPECIES_WEIGHTS = {"spruce": 0.40, "pinesmall": 0.30, "firsmall": 0.24,
                   "dry": 0.06}
# size buckets: (min_height, max_height, weight) — donor 15-30/40-60/70-100 @720p
SIZE_BUCKETS: tuple[tuple[int, int, float], ...] = (
    (28, 34, 0.50),
    (56, 62, 0.35),
    (90, 101, 0.15),
)

# Shadows: sun from upper-right -> shadow centroid lower-left of the foot.
SHADOW_DX = -0.30          # x offset in tree heights (left)
SHADOW_DY = 0.20           # y offset in tree heights (down)
SHADOW_RX = 0.48           # semi-major (along-x) in tree heights -> length ~1x h
SHADOW_RY = 0.115          # semi-minor (along-y) in tree heights -> thin, not a blob
SHADOW_RGB = (22, 26, 13)
SHADOW_ALPHA = 150         # peak core alpha -> lit/shadow luma ratio >= 1.5
SHADOW_BLUR = 3.2

# Poisson-style placement target and crown widening (donor whorled spruces).
TREE_TARGET = 212
SPRUCE_WIDEN = 1.06

FROST_GAIN = (7, 9, 4)     # upper-crown lit-tip lift
BLACK_FLOOR = (19, 21, 11) # avoid pure-black stencil outlines


# ---------------------------------------------------------------------------
# sprite grading
# ---------------------------------------------------------------------------
def _grade_array(a: np.ndarray, mul: tuple[float, float, float],
                 frost: bool) -> np.ndarray:
    """Grade an RGBA array in place-ish; alpha is preserved byte-for-byte."""
    rgb = a[..., :3].astype(np.float64)
    for c, m in enumerate(mul):
        rgb[..., c] = np.clip(rgb[..., c] * m, 0.0, 255.0)

    alpha = a[..., 3]
    ys, xs = np.where(alpha > 16)
    if ys.size:
        y0, y1 = int(ys.min()), int(ys.max())
        span = max(1, y1 - y0)
        yy = np.arange(rgb.shape[0])[:, None]
        upper = yy < (y0 + 0.42 * span)
        lum = 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]
        med = float(np.median(lum[alpha > 16]))
        bright = lum > med
        frost_mask = (alpha > 16) & upper & bright
        if frost:
            for c, g in enumerate(FROST_GAIN):
                rgb[..., c] = np.where(frost_mask,
                                       np.clip(rgb[..., c] + g, 0, 255),
                                       rgb[..., c])
        # Soft black-floor: lift near-black opaque pixels (no hard stencil).
        near_black = (alpha > 16) & (rgb.max(axis=2) < 11)
        for c in range(3):
            rgb[..., c] = np.where(near_black, BLACK_FLOOR[c], rgb[..., c])

    a[..., :3] = np.clip(np.round(rgb), 0, 255).astype(np.uint8)
    return a


def grade_sprite(path: Path, mul: tuple[float, float, float],
                 frost: bool = False) -> Image.Image:
    with Image.open(path) as im:
        a = np.asarray(im.convert("RGBA")).copy()
    return Image.fromarray(_grade_array(a, mul, frost), mode="RGBA")


def tree_tile(graded: Image.Image, target_h: int,
              widen: float = 1.0) -> Image.Image:
    """Crop to opaque ink and scale so the whole tree (crown+trunk) is target_h.

    ``widen`` broadens the whorled branch fans slightly so overlapping conifers
    read as a continuous canopy rather than thin needle sticks. Applied only to
    spruce/pine; H/W stays inside the donor silhouette bands.
    """
    bbox = graded.getchannel("A").getbbox()
    if bbox is None:
        return Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    crop = graded.crop(bbox)
    scale = target_h / float(crop.height)
    tw = max(1, int(round(crop.width * scale * widen)))
    return crop.resize((tw, max(1, target_h)), Image.Resampling.LANCZOS)


# ---------------------------------------------------------------------------
# deterministic tree plan
# ---------------------------------------------------------------------------
def _density_field(seed: int) -> Image.Image:
    """Seeded 6x6 density grid -> smooth 512^2 field (clumps, not a grid)."""
    rng = random.Random(seed * 104729 + 11)
    small = Image.new("L", (6, 6))
    vals = [[rng.uniform(0.30, 1.0) for _ in range(6)] for _ in range(6)]
    lo, hi = min(min(r) for r in vals), max(max(r) for r in vals)
    for gy, row in enumerate(vals):
        for gx, v in enumerate(row):
            n = (v - lo) / max(1e-6, hi - lo)
            small.putpixel((gx, gy), int(round((0.45 + 0.55 * n) * 255)))
    return small.resize((W, H), Image.Resampling.BILINEAR)


def _pick_size(rng: random.Random) -> int:
    r = rng.random()
    acc = 0.0
    for lo, hi, weight in SIZE_BUCKETS:
        acc += weight
        if r < acc:
            return rng.randint(lo, hi)
    return SIZE_BUCKETS[-1][1]


def _pick_species(rng: random.Random) -> tuple[str, tuple, str, float, bool]:
    r = rng.random()
    acc = 0.0
    families = ("spruce", "pinesmall", "firsmall", "dry")
    for fam in families:
        acc += SPECIES_WEIGHTS[fam]
        if r < acc:
            pool = DRY if fam == "dry" else tuple(
                c for c in CONIFERS if c[1] == fam)
            name, sp, grade, family, hmul, frost = pool[rng.randrange(len(pool))]
            return name, grade, family, hmul, frost
    name, sp, grade, family, hmul, frost = CONIFERS[0]
    return name, grade, family, hmul, frost


def plan_trees(seed: int) -> list[dict[str, Any]]:
    """Poisson-style clumped placement (no visible grid) with density field.

    Candidate points are rejected if they sit closer than a density-modulated
    fraction of the two crown radii. Dense patches allow near-overlap (canopy),
    sparse patches leave gaps — the clumped, non-gridded pattern measured in the
    donor dense-forest reference (#11). Deterministic: one seeded Random.
    """
    rng = random.Random(seed * 1000003 + 17)
    density = np.asarray(_density_field(seed), dtype=np.float64) / 255.0
    trees: list[dict[str, Any]] = []
    occupied: list[tuple[float, float, float]] = []  # x, y, crown radius
    attempts = 0
    max_attempts = TREE_TARGET * 80

    while len(trees) < TREE_TARGET and attempts < max_attempts:
        attempts += 1
        x = rng.uniform(6.0, W - 6.0)
        y = rng.uniform(8.0, H - 8.0)
        d = float(density[min(int(y), H - 1), min(int(x), W - 1)])
        h = _pick_size(rng)
        sp, grade, family, hmul, frost = _pick_species(rng)
        rad = 0.26 * h * hmul * (SPRUCE_WIDEN if sp.startswith(
            ("tree_spruce", "tree_pine")) else 1.0)
        # dense patches (d->1) allow crowns to nearly touch; sparse patches
        # keep them apart. 0.50..1.05 x (r1+r2).
        sep_k = 0.50 + 0.55 * (1.0 - d)
        if any(math.hypot(x - ox, y - oy) < sep_k * (rad + orad)
               for ox, oy, orad in occupied):
            continue
        occupied.append((x, y, rad))
        trees.append({
            "sprite": sp, "grade": grade, "family": family,
            "hmul": hmul, "frost": frost,
            "x": float(x), "y": float(y), "h": h,
            "mirror": rng.random() < 0.5,
            "hbright": rng.uniform(0.90, 1.10),  # per-tree brightness jitter
        })

    # Painter's order: trees lower on the canvas are drawn last (in front).
    trees.sort(key=lambda t: t["y"])
    return trees


# ---------------------------------------------------------------------------
# compositing
# ---------------------------------------------------------------------------
def build_ground(seed: int) -> Image.Image:
    with Image.open(BLOCKS_DIR / "grass_ground2.png") as src:
        tile = tpr.mirror_tileable(src, tpr.TILE_SIZE, tpr.RESAMPLE)
    tile = tpr.adjust_bcs(tile, 1.0, 1.12)
    rng = random.Random(seed * 7919 + 3)
    ox, oy = rng.randrange(tpr.TILE_SIZE), rng.randrange(tpr.TILE_SIZE)
    floor = np.asarray(tpr.wrap_crop(tile, ox, oy, W, H).convert("RGB")).astype(np.float64)
    floor *= np.asarray(GROUND_TINT, dtype=np.float64)[None, None, :]
    # grass_ground2 carries pale sand/rock streaks. Under a closed donor
    # conifer canopy those streaks are shaded olive, not bare eroded ground:
    # crush highlights above L~66 and force an olive cast (R<=0.94G, B<=0.56G)
    # while keeping the fine 2-5 px grain and the wrap seam.
    lum = 0.299 * floor[..., 0] + 0.587 * floor[..., 1] + 0.114 * floor[..., 2]
    over = np.clip((lum - 66.0) / 30.0, 0.0, 1.0)
    floor *= (1.0 - 0.42 * over)[..., None]
    g = floor[..., 1]
    floor[..., 0] = np.minimum(floor[..., 0], 0.94 * g)
    floor[..., 2] = np.minimum(floor[..., 2], 0.56 * g)
    return Image.fromarray(np.clip(np.round(floor), 0, 255).astype(np.uint8),
                           mode="RGB")


def build_shadows(trees: list[dict[str, Any]]) -> Image.Image:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for t in trees:
        h = t["h"] * t["hmul"]
        cx = t["x"] + SHADOW_DX * h      # sun upper-right -> shadow lower-left
        cy = t["y"] + SHADOW_DY * h
        rx, ry = SHADOW_RX * h, SHADOW_RY * h
        d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry),
                  fill=SHADOW_RGB + (SHADOW_ALPHA,))
    return layer.filter(ImageFilter.GaussianBlur(SHADOW_BLUR))


def render(seed: int = SEED, with_trees: bool = True
           ) -> tuple[Image.Image, list[dict[str, Any]]]:
    """Render the 512x512 piece. with_trees=False yields ground+shadow base."""
    trees = plan_trees(seed)
    base = Image.alpha_composite(build_ground(seed).convert("RGBA"),
                                 build_shadows(trees))
    if with_trees:
        cache: dict[tuple[str, tuple[float, float, float], int], Image.Image] = {}
        for t in trees:
            key = (t["sprite"], t["grade"], int(round(t["h"])))
            tile = cache.get(key)
            if tile is None:
                graded = grade_sprite(SPRITES_HI_DIR / (t["sprite"] + ".png"),
                                      t["grade"], frost=t["frost"])
                widen = SPRUCE_WIDEN if t["sprite"].startswith(("tree_spruce", "tree_pine")) else 1.0
                tile = tree_tile(graded, int(round(t["h"])), widen=widen)
                cache[key] = tile.copy()
            tile = cache[key]
            if t["mirror"]:
                tile = tile.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            if abs(t["hbright"] - 1.0) > 0.01:
                a = np.asarray(tile).copy()
                a[..., :3] = np.clip(
                    np.round(a[..., :3].astype(np.float64) * t["hbright"]),
                    0, 255).astype(np.uint8)
                tile = Image.fromarray(a, mode="RGBA")
            px = int(round(t["x"] - tile.width * 0.5))
            py = int(round(t["y"] - tile.height))  # foot anchor
            tpr.paste_rgba(base, tile, px, py)
    return base.convert("RGB"), trees


# ---------------------------------------------------------------------------
# measurement (Pillow + NumPy only) — mirrors the verdict_decor metric methods
# ---------------------------------------------------------------------------
def _hsv_band(arr: np.ndarray) -> dict:
    a = arr.reshape(-1, 3).astype(np.float64)
    a = a[a.max(axis=1) > 0]
    lum = 0.299 * a[:, 0] + 0.587 * a[:, 1] + 0.114 * a[:, 2]
    thr = np.percentile(lum, 65)
    lit = a[lum >= thr]
    lm = lit.mean(axis=0)
    h, s, v = colorsys.rgb_to_hsv(*(lm / 255.0))
    return {
        "lit35_hex": "#%02X%02X%02X" % tuple(int(round(x)) for x in lm),
        "lit35_rgb": [round(x, 1) for x in lm],
        "hue_deg": round(h * 360, 1),
        "sat": round(s, 3),
        "val": round(v, 3),
        "B_over_G": round(lm[2] / max(1e-6, lm[1]), 3),
        "lit35_luma": round(float(0.299*lm[0] + 0.587*lm[1] + 0.114*lm[2]), 1),
    }


def _components(mask: np.ndarray) -> list[tuple[int, int]]:
    """4-connected component bbox heights; mask is bool 512^2."""
    seen = np.zeros_like(mask, dtype=bool)
    heights: list[tuple[int, int]] = []
    Hh, Ww = mask.shape
    for sy in range(Hh):
        for sx in range(Ww):
            if not mask[sy, sx] or seen[sy, sx]:
                continue
            q = deque([(sy, sx)])
            seen[sy, sx] = True
            minx = maxx = sx
            miny = maxy = sy
            while q:
                y, x = q.popleft()
                minx, maxx = min(minx, x), max(maxx, x)
                miny, maxy = min(miny, y), max(maxy, y)
                for dy, dx in ((1,0),(-1,0),(0,1),(0,-1)):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < Hh and 0 <= nx < Ww and mask[ny,nx] and not seen[ny,nx]:
                        seen[ny, nx] = True
                        q.append((ny, nx))
            heights.append((miny, maxy))
    return heights


def measure(seed: int = SEED) -> dict:
    full, trees = render(seed, with_trees=True)
    base, _ = render(seed, with_trees=False)
    fa = np.asarray(full).astype(np.int16)
    ba = np.asarray(base).astype(np.int16)
    diff = np.abs(fa - ba).max(axis=2)
    crown = diff > 6
    crown_rgb = np.asarray(full)[crown]

    # per-family lit35 from graded sprite tiles (derived from the plan)
    fam_rgb: dict[str, list[np.ndarray]] = {}
    for t in trees:
        graded = grade_sprite(SPRITES_HI_DIR / (t["sprite"] + ".png"),
                              t["grade"], frost=t["frost"])
        widen = SPRUCE_WIDEN if t["sprite"].startswith(("tree_spruce", "tree_pine")) else 1.0
        tile = tree_tile(graded, int(round(t["h"])), widen=widen)
        a = np.asarray(tile)
        px = a[a[..., 3] > 16][:, :3]
        if px.size:
            fam_rgb.setdefault(t["family"], []).append(px)
    families = {fam: _hsv_band(np.concatenate(v))
                for fam, v in fam_rgb.items()}

    # size buckets from the plan
    buckets = {"small_24_34": 0, "mid_43_62": 0, "large_77_101": 0, "outside": 0}
    for t in trees:
        h = t["h"]
        if 24 <= h <= 34:
            buckets["small_24_34"] += 1
        elif 43 <= h <= 62:
            buckets["mid_43_62"] += 1
        elif 77 <= h <= 101:
            buckets["large_77_101"] += 1
        else:
            buckets["outside"] += 1

    # connected-component heights on the crown mask (overlap merges some)
    comps = _components(crown)
    comp_heights = [b - a + 1 for a, b in comps if b - a + 1 >= 4]
    comp_buckets = {"small": 0, "mid": 0, "large": 0, "other": 0}
    for ch in comp_heights:
        if 24 <= ch <= 34:
            comp_buckets["small"] += 1
        elif 43 <= ch <= 62:
            comp_buckets["mid"] += 1
        elif 77 <= ch <= 101:
            comp_buckets["large"] += 1
        else:
            comp_buckets["other"] += 1

    # shadow: lit ground vs shadow core, sampled from base render
    shadow = np.asarray(Image.alpha_composite(
        Image.new("RGBA", (W, H), (0, 0, 0, 0)), build_shadows(trees)))
    sh_alpha = shadow[..., 3]
    g = np.asarray(build_ground(seed)).astype(np.float64)
    # Measure the COMPOSITED base (ground + shadow), not the raw ground: the
    # shadow darkens those pixels, which is what the lit/shadow ratio tests.
    bl = 0.299*ba[...,0] + 0.587*ba[...,1] + 0.114*ba[...,2]
    core = (sh_alpha > 120) & (diff == 0)  # shadow-only pixels, no tree ink
    lit_sel = (sh_alpha == 0) & (diff == 0)
    sh_l = float(bl[core].mean()) if core.any() else 0.0
    lit_l = float(bl[lit_sel].mean()) if lit_sel.any() else 0.0
    # directional offset from plan (mean shadow centroid - tree foot)
    dxs = [t["hmul"] * t["h"] * SHADOW_DX for t in trees]
    dys = [t["hmul"] * t["h"] * SHADOW_DY for t in trees]
    ratio = lit_l / max(1e-6, sh_l)

    # species mix
    n = len(trees)
    species: dict[str, int] = {}
    for t in trees:
        species[t["sprite"].replace("tree_", "")] = species.get(
            t["sprite"].replace("tree_", ""), 0) + 1
    dry_n = sum(1 for t in trees if t["family"] == "dry")
    conifer_pct = 100.0 * (n - dry_n) / max(1, n)

    # ground + global gate (whole frame)
    gm = g.reshape(-1, 3).mean(axis=0)
    allpx = np.asarray(full).reshape(-1, 3).astype(np.float64) / 255.0
    hs = np.array([colorsys.rgb_to_hsv(*p)[1] for p in allpx[::37]])
    vs = np.array([colorsys.rgb_to_hsv(*p)[2] for p in allpx[::37]])

    return {
        "trees": n,
        "trees_per_MP": round(n * MP, 1),
        "species_counts": species,
        "conifer_pct": round(conifer_pct, 1),
        "dry_pct": round(100.0 * dry_n / max(1, n), 1),
        "crown_ink_pct": round(100.0 * crown.mean(), 2),
        "families": families,
        "whole_crown_lit35": _hsv_band(crown_rgb),
        "size_buckets_plan": buckets,
        "component_count": len(comp_heights),
        "component_buckets": comp_buckets,
        "component_height_min": min(comp_heights) if comp_heights else 0,
        "component_height_max": max(comp_heights) if comp_heights else 0,
        "shadow_luma_ratio": round(ratio, 3),
        "shadow_lit_luma": round(lit_l, 1),
        "shadow_core_luma": round(sh_l, 1),
        "shadow_offset_px": [round(float(np.mean(dxs)), 1), round(float(np.mean(dys)), 1)],
        "ground_mean_rgb": [round(x, 1) for x in gm],
        "ground_mean_hex": "#%02X%02X%02X" % tuple(int(round(x)) for x in gm),
        "global_sat_mean": round(float(hs.mean()), 3),
        "global_val_mean": round(float(vs.mean()), 3),
    }


def gate_proof(render_img: Image.Image, ref_root: Path) -> dict:
    """P-45-class adjudication evidence: identical-method donor HSV sampling.

    Every panel is cropped in source px, resized to 512^2 with BILINEAR, then
    sampled with ``[::37]`` through ``colorsys.rgb_to_hsv``. That is EXACTLY the
    sampling used by ``measure()`` for the port render, so the numbers are
    directly comparable. Used to rule whether the supporting global HSV gate
    (sat 0.30-0.55 / val 0.25-0.45) is applicable to a pure dense-forest crop.
    """
    items = (
        ("donor_dense_clean_11", "large_1.webp", [560, 20, 788, 200]),
        ("donor_primary_clean_8", "cossacks-3-v1-498085.jpg", [0, 560, 260, 720]),
        ("donor_floor_ref7_documented",
         "cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg",
         [350, 480, 470, 570]),
        ("donor_darkcrown_11_documented", "large_1.webp", [455, 55, 510, 105]),
    )

    def _sample(im: Image.Image) -> dict:
        a = np.asarray(im.convert("RGB").resize(
            (W, H), Image.Resampling.BILINEAR)).reshape(-1, 3).astype(np.float64) / 255.0
        hsv = np.array([colorsys.rgb_to_hsv(*px) for px in a[::37]])
        sat, val = float(hsv[:, 1].mean()), float(hsv[:, 2].mean())
        lum = 0.299 * a[:, 0] + 0.587 * a[:, 1] + 0.114 * a[:, 2]
        return {"sat": round(sat, 3), "val": round(val, 3),
                "mean_luma_8bit": round(float(lum.mean() * 255), 1),
                "in_gate": 0.30 <= sat <= 0.55 and 0.25 <= val <= 0.45}

    out: dict[str, Any] = {
        "method": "crop source px -> resize 512^2 BILINEAR -> RGB/255 -> "
                  "colorsys.rgb_to_hsv on pixels [::37] -> arithmetic mean S,V",
        "gate": {"sat": [0.30, 0.55], "val": [0.25, 0.45]},
    }
    for key, name, box in items:
        path = ref_root / name
        if path.is_file():
            with Image.open(path) as src:
                im = src.convert("RGB").crop(tuple(box))
            out[key] = {"image": name, "box_src_px": box,
                        "crop_size": list(im.size), **_sample(im)}
    out["port_render"] = _sample(render_img)
    return out


# ---------------------------------------------------------------------------
# driver
# ---------------------------------------------------------------------------
def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--out-dir", default=str(DEFAULT_OUT))
    p.add_argument("--seed", type=int, default=SEED)
    p.add_argument("--reference-dir", default=str(DEFAULT_REF))
    args = p.parse_args(argv)

    out_dir = Path(args.out_dir).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    render_img, trees = render(args.seed)
    png = out_dir / "t6_forest_conifer.png"
    render_img.save(png, format="PNG", optimize=True)

    ref_root = Path(args.reference_dir).expanduser()
    # A/B donor panels: CLEAN conifer crops only — no units, minimap or UI.
    # T08 REVISION (parent T6-TERRAIN hold): the previous panels contained
    # troop formations and a minimap (T02-style contamination) and were revoked.
    #   #11 crop [560,20,788,200] — dense conifers, verified clean at 3x/8x
    #       (the only bright specks are branch-tip highlights, not units).
    #   #8  crop [0,560,260,720] — gully-rim conifers, verified clean at 3x.
    comparisons: dict[str, str] = {}
    for suffix, ref_name, box in (
        ("_compare", "large_1.webp", [560, 20, 788, 200]),
        ("_compare_primary", "cossacks-3-v1-498085.jpg", [0, 560, 260, 720]),
    ):
        ref_path = ref_root / ref_name
        if ref_path.is_file():
            with Image.open(ref_path) as src:
                ref = src.convert("RGB").crop(tuple(box)).resize((W, H), tpr.RESAMPLE)
            sheet = tpr.build_comparison(
                "t6_forest_conifer" + suffix, render_img, ref, args.seed,
                [{"type": "block"}, {"type": "sprite", "count": len(trees)},
                 {"type": "shadow"}, {"type": "grade"}], box)
            cpath = out_dir / ("t6_forest_conifer" + suffix + ".png")
            sheet.save(cpath, format="PNG", optimize=True)
            comparisons[suffix] = str(cpath)

    metrics = measure(args.seed)
    result = {
        "generator": "t6_forest_conifer.py", "seed": args.seed,
        "size_px": [W, H], "output": str(png), "sha256": sha256(png),
        "comparisons": comparisons, "metrics": metrics,
        "gate_proof": gate_proof(render_img, ref_root),
        "donor_panels": "CLEAN conifer crops; no units, minimap or UI",
    }
    (out_dir / "t6_forest_conifer_metrics.json").write_text(
        json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
