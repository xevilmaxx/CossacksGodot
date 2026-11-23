#!/usr/bin/env python3
"""T6-T10 — headless, deterministic mini-baker for the bushes_understory piece.

OWNED FILE. No Godot is launched and no donor file is copied into the repo:
only port-owned PNGs under ``app/assets`` are used for the render, and the
primary donor JPEG is READ for the side-by-side sheet.

Design (all targets from docs/audit/PIECES/bushes_understory.md §4 C1-C7 and
docs/T6_WAVE_PLAN.md T6-T10):

  * dark olive forest floor (#3B3F1B donor anchor) from the mirror-tiled
    ``grass1`` block, graded to (61, 66, 30) while keeping its 2-5 px grain;
  * REAL bush/stump sprites only — bush1..4, fern1..4, plantain1..3,
    flower1..3 and tree_stump1..4. NO rock / stone / landstone asset is ever
    loaded (explicit allowlist + runtime assertion), so there is no fallback;
  * pure-black backing keyed to alpha 0 (tree_stump2 carries 22% opaque black);
  * 8-12 clumps on a cross-mixed hash jitter (no axis-aligned rows), clustered
    twigs so each clump reads as organic foliage, not a stencil icon;
  * 2 size buckets with >= 1.25 spread, varied silhouettes;
  * ONE flower kept at the port's 0.75x shrink, plus a few SOFT pale blossom
    specks (#C8CAA2 donor anchor) as a disclosed 2D proxy for the missing
    chamomile sprite;
  * soft blurred contact shadows under every clump, cast lower-left.

Usage::

    python app/tools/pieces/t6_bushes_understory.py
    python app/tools/pieces/t6_bushes_understory.py --out-dir /tmp/pieces
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# Shared renderer is READ-ONLY; importing its primitives is allowed.
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

# Donor anchors (measured, see docs/t6/reports/T6-T10.md claim table)
FLOOR_TARGET = (61.0, 66.0, 30.0)     # donor forest floor #3B3F1B / gully foliage
BLOSSOM_RGB = (200, 202, 162)         # donor near-white #C8CAA2
BLACK_KEY = 3                          # alpha 0 where R,G,B <= 3

# Real understory sprite allowlist. Anything outside this set is a fallback
# attempt and is rejected before compositing.
ALLOWED_SPRITES = frozenset(
    [f"bush{i}" for i in range(1, 5)]
    + [f"fern{i}" for i in range(1, 5)]
    + [f"plantain{i}" for i in range(1, 4)]
    + [f"flower{i}" for i in range(1, 4)]
    + [f"tree_stump{i}" for i in range(1, 5)]
)

# Per-family RGB grade (keeps the real sprite alpha/geometry, only re-grading
# colour toward donor foliage). Stumps stay brown wood, never achromatic rock.
GRADE: dict[str, tuple[float, float, float]] = {
    "bush": (1.52, 1.55, 0.86),
    "fern": (1.36, 1.36, 0.86),
    "plantain": (1.48, 1.50, 0.96),
    "flower": (1.30, 1.38, 0.95),
    "stump": (1.10, 1.16, 1.22),
}

SHADOW_ALPHA = 82
SHADOW_BLUR = 4.5
BLOSSOM_ALPHA = 165

# Deterministic per-clump width ladder. Native sprite aspects cluster tightly
# (1.2-1.65), so a fixed spread keeps every rendered silhouette aspect >5%
# apart (doc C6 "no duplicate aspect") without changing height buckets.
WIDTH_LADDER = (0.80, 1.18, 0.92, 1.32, 0.86, 1.05, 1.26, 0.97, 1.40, 0.83, 1.14, 1.22)

# Size buckets in source-px of clump height (donor clumps are 25-36 px at 720p;
# the 512px piece is a zoomed terrain patch, so 30-100 px is the equivalent).
SIZE_BUCKETS: tuple[tuple[int, int, str], ...] = (
    (30, 48, "small"),
    (49, 78, "medium"),
    (79, 112, "large"),
)


# ---------------------------------------------------------------------------
# sprite loading / grading
# ---------------------------------------------------------------------------
def load_sprite(name: str) -> Image.Image:
    """Load a real understory sprite, key pure black, crop to opaque ink."""
    if name not in ALLOWED_SPRITES:
        raise ValueError(f"rock/foreign fallback rejected: {name!r}")
    path = SPRITES_HI_DIR / (name + ".png")
    with Image.open(path) as im:
        a = np.asarray(im.convert("RGBA")).copy()
    rgb, alpha = a[..., :3], a[..., 3]
    black = (rgb[..., 0] <= BLACK_KEY) & (rgb[..., 1] <= BLACK_KEY) \
        & (rgb[..., 2] <= BLACK_KEY)
    alpha[black] = 0
    a[..., 3] = alpha
    im = Image.fromarray(a, mode="RGBA")
    bbox = im.getchannel("A").getbbox()
    return im.crop(bbox) if bbox else im


def grade_tile(name: str, target_h: int, mirror: bool,
               wscale: float = 1.0) -> Image.Image:
    """Crop-to-ink sprite, grade toward donor foliage, scale to target_h."""
    fam = ("bush" if name.startswith("bush") else
           "fern" if name.startswith("fern") else
           "plantain" if name.startswith("plantain") else
           "flower" if name.startswith("flower") else "stump")
    im = load_sprite(name)
    a = np.asarray(im).astype(np.float64)
    mul = GRADE[fam]
    for c in range(3):
        a[..., c] = np.clip(a[..., c] * mul[c], 0, 255)
    im = Image.fromarray(np.clip(np.round(a), 0, 255).astype(np.uint8), "RGBA")
    scale = target_h / float(im.height)
    tw = max(1, int(round(im.width * scale * wscale)))
    im = im.resize((tw, max(1, target_h)), Image.Resampling.LANCZOS)
    if mirror:
        im = im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    return im


def bucket_of(height: int) -> str:
    for lo, hi, label in SIZE_BUCKETS:
        if lo <= height <= hi:
            return label
    return "large" if height > SIZE_BUCKETS[-1][1] else "small"


# ---------------------------------------------------------------------------
# deterministic clump plan (cross-mixed hash jitter, anti-row rejection)
# ---------------------------------------------------------------------------
def plan_clumps(seed: int) -> list[dict[str, Any]]:
    """Return 12 real-sprite clumps with explicit anti-row rejection."""
    rng = random.Random(seed * 1000003 + 71)
    # (family sprite choices, target-height draw range, weight)
    recipes = [
        ("bush", ["bush1", "bush2", "bush3", "bush4"], (74, 110)),
        ("fern", ["fern1", "fern2", "fern3"], (60, 86)),
        ("plantain", ["plantain1", "plantain2", "plantain3"], (40, 64)),
        ("stump", ["tree_stump2", "tree_stump3", "tree_stump4"], (32, 50)),
    ]
    # family order for the 12 picks: bush-heavy, a few ferns, 2 stumps,
    # 2 plantains and exactly 1 flower (port 12.5% share approximation).
    plan_fam = ["bush", "bush", "bush", "bush", "fern", "fern", "fern",
                "plantain", "plantain", "stump", "stump", "flower"]

    clumps: list[dict[str, Any]] = []
    cells_x, cells_y = 4, 3
    slots = [(gx, gy) for gy in range(cells_y) for gx in range(cells_x)]
    rng.shuffle(slots)
    for idx, fam in enumerate(plan_fam):
        gx, gy = slots[idx]
        # cross-mix both axes (world.gd:1479-1486 anti-row rule)
        ux = (gx + 0.5 + rng.uniform(-0.36, 0.36)) / cells_x
        uy = (gy + 0.5 + rng.uniform(-0.36, 0.36)) / cells_y
        x, y = ux * W, uy * H
        # reject if too close to an existing clump centroid or forms a row
        for _ in range(24):
            bad = any(math.hypot(x - c["x"], y - c["y"]) < 0.06 * W
                      or abs(y - c["y"]) < 10 or abs(x - c["x"]) < 10
                      for c in clumps)
            if not bad:
                break
            ux = (gx + 0.5 + rng.uniform(-0.42, 0.42)) / cells_x
            uy = (gy + 0.5 + rng.uniform(-0.42, 0.42)) / cells_y
            x, y = ux * W, uy * H

        if fam == "flower":
            name = "flower1"
            h = 30
            h = int(round(h * 0.75))  # port flower shrink
        else:
            choices = next(r[1] for r in recipes if r[0] == fam)
            hrange = next(r[2] for r in recipes if r[0] == fam)
            name = choices[rng.randrange(len(choices))]
            h = rng.randint(hrange[0], hrange[1])

        # A bush clump is 2-3 overlapping twig sprites -> organic thicket,
        # never a single iconic stencil silhouette.
        members = [name]
        if fam == "bush" and rng.random() < 0.75:
            members.append(choices[rng.randrange(len(choices))])
            if rng.random() < 0.35:
                members.append(choices[rng.randrange(len(choices))])
        clumps.append({
            "family": fam, "name": name, "members": members, "h": h,
            "x": x, "y": y, "mirror": rng.random() < 0.5,
            "lean": rng.uniform(-0.15, 0.15),
            "blossom": fam == "bush" and rng.random() < 0.75,
            "bucket": bucket_of(h),
            "wscale": WIDTH_LADDER[idx % len(WIDTH_LADDER)],
        })
    return clumps


# ---------------------------------------------------------------------------
# compositing
# ---------------------------------------------------------------------------
def build_ground(seed: int) -> Image.Image:
    """Mirror-tiled grass1 block graded to donor forest floor."""
    with Image.open(BLOCKS_DIR / "grass1.png") as src:
        tile = tpr.mirror_tileable(src, tpr.TILE_SIZE, tpr.RESAMPLE)
    tile = tpr.adjust_bcs(tile, 1.0, 1.12)
    rng = random.Random(seed * 7919 + 3)
    ox, oy = rng.randrange(tpr.TILE_SIZE), rng.randrange(tpr.TILE_SIZE)
    floor = np.asarray(tpr.wrap_crop(tile, ox, oy, W, H).convert("RGB")).astype(np.float64)
    a = np.asarray(floor)
    a = np.clip(a * np.array([FLOOR_TARGET[0] / 76.0,
                              FLOOR_TARGET[1] / 82.5,
                              FLOOR_TARGET[2] / 30.4]), 0, 255)
    return Image.fromarray(np.clip(np.round(a), 0, 255).astype(np.uint8), "RGB")


def build_shadows(clumps: list[dict[str, Any]]) -> Image.Image:
    """Soft contact shadows, sun from upper-right -> shadow lower-left."""
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for c in clumps:
        h = c["h"]
        cx = c["x"] - 0.34 * h
        cy = c["y"] + 0.20 * h
        rx, ry = 0.62 * h, 0.24 * h
        d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry),
                  fill=(20, 24, 10, SHADOW_ALPHA))
    return layer.filter(ImageFilter.GaussianBlur(SHADOW_BLUR))


def build_decor(clumps: list[dict[str, Any]]) -> Image.Image:
    """Composite the real sprite clumps onto a transparent layer."""
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cache: dict[tuple[str, int, bool, float], Image.Image] = {}
    for c in clumps:
        for j, mname in enumerate(c["members"]):
            key = (mname, c["h"] if j == 0 else max(28, c["h"] - 12),
                   c["mirror"], c["wscale"])
            tile = cache.get(key)
            if tile is None:
                tile = grade_tile(mname, key[1], key[2], key[3])
                cache[key] = tile
            # twig members overlap with a small deterministic offset
            dx = 0 if j == 0 else int((j - 1) * 5 + math.sin(c["x"] + j) * 3)
            dy = 0 if j == 0 else int(-4 - j * 3)
            px = int(round(c["x"] - tile.width * 0.5 + dx))
            py = int(round(c["y"] - tile.height + dy))
            tpr.paste_rgba(layer, tile, px, py)
    return add_blossoms(layer, clumps)


def _component_aspects(decor: Image.Image) -> list[tuple[dict[str, Any], float]]:
    a = np.asarray(decor.convert("RGBA"))
    out = []
    for c in components(a[..., 3] > 32):
        if c["area"] < 800:
            continue
        w = c["bbox"][2] - c["bbox"][0] + 1
        h = c["bbox"][3] - c["bbox"][1] + 1
        out.append((c, w / max(1, h)))
    return out


def _bad_aspect_pairs(decor: Image.Image) -> list[tuple[int, int]]:
    items = _component_aspects(decor)
    return [(i, j) for i in range(len(items)) for j in range(i + 1, len(items))
            if abs(items[i][1] - items[j][1]) / max(items[i][1], items[j][1]) < 0.055]


def _clump_of(comp: dict[str, Any], clumps: list[dict[str, Any]]) -> int:
    return min(range(len(clumps)),
               key=lambda k: (comp["cx"] - clumps[k]["x"]) ** 2
               + (comp["cy"] - clumps[k]["y"]) ** 2)


def aspect_separated_decor(clumps: list[dict[str, Any]]) -> Image.Image:
    """Deterministically nudge clump widths until no two silhouette aspects
    agree within 5% (doc C6). No RNG: the same seed always converges to the
    same clump widths, so the PNG stays byte-identical across runs."""
    decor = build_decor(clumps)
    for _ in range(24):
        bad = _bad_aspect_pairs(decor)
        if not bad:
            break
        items = _component_aspects(decor)
        touched: set[int] = set()
        for i, j in bad:
            for idx, sign in ((i, -1), (j, 1)):
                ci = _clump_of(items[idx][0], clumps)
                if ci in touched:
                    continue
                touched.add(ci)
                # push the two aspects away from each other
                clumps[ci]["wscale"] *= 0.78 if items[idx][1] <= items[
                    j if idx == i else i][1] else 1.28
        decor = build_decor(clumps)

    # Bounded deterministic fallback for any residual pair (overlapping
    # members can couple two components): try a small fixed ladder of width
    # factors on the two offending clumps and keep the first clean result.
    for _ in range(6):
        bad = _bad_aspect_pairs(decor)
        if not bad:
            break
        items = _component_aspects(decor)
        i, j = bad[0]
        ca = _clump_of(items[i][0], clumps)
        cb = _clump_of(items[j][0], clumps)
        if ca == cb:
            break
        base_a, base_b = clumps[ca]["wscale"], clumps[cb]["wscale"]
        solved = False
        for fa, fb in ((0.70, 1.45), (1.45, 0.70), (0.60, 1.60), (1.60, 0.60)):
            clumps[ca]["wscale"], clumps[cb]["wscale"] = base_a * fa, base_b * fb
            trial = build_decor(clumps)
            if not _bad_aspect_pairs(trial):
                decor = trial
                solved = True
                break
        if not solved:
            clumps[ca]["wscale"], clumps[cb]["wscale"] = base_a, base_b
            break
    return decor


def add_blossoms(layer: Image.Image, clumps: list[dict[str, Any]]) -> Image.Image:
    """Soft pale blossom specks — disclosed proxy for unrebaked chamomile."""
    d = ImageDraw.Draw(layer)
    for c in clumps:
        if not c["blossom"]:
            continue
        rng = random.Random(int(c["x"] * 31 + c["y"] * 17) + 5)
        for _ in range(24):
            bx = c["x"] + rng.uniform(-0.22, 0.22) * c["h"]
            by = c["y"] - rng.uniform(0.30, 0.92) * c["h"]
            rr = rng.uniform(0.9, 1.7)
            d.ellipse((bx - rr, by - rr * 0.85, bx + rr, by + rr * 0.85),
                      fill=BLOSSOM_RGB + (BLOSSOM_ALPHA,))
    # one mild blur pass -> soft, not hard-edged icon dots
    return layer.filter(ImageFilter.GaussianBlur(0.55))


def render(seed: int = SEED) -> tuple[Image.Image, Image.Image, Image.Image,
                                      Image.Image, list[dict[str, Any]]]:
    """Return (final_rgb, ground, shadows, decor, clumps)."""
    clumps = plan_clumps(seed)
    ground = build_ground(seed)
    shadows = build_shadows(clumps)
    decor = aspect_separated_decor(clumps)
    base = Image.alpha_composite(ground.convert("RGBA"), shadows)
    final = Image.alpha_composite(base, decor).convert("RGB")
    return final, ground, shadows, decor, clumps


# ---------------------------------------------------------------------------
# measurement (metrics never override visual review)
# ---------------------------------------------------------------------------
def components(mask: np.ndarray) -> list[dict[str, Any]]:
    """8-connected components of a boolean mask; return area/bbox/centroid."""
    seen = np.zeros_like(mask, dtype=bool)
    out: list[dict[str, Any]] = []
    h, w = mask.shape
    for sy in range(h):
        for sx in range(w):
            if not mask[sy, sx] or seen[sy, sx]:
                continue
            stack = [(sy, sx)]
            seen[sy, sx] = True
            xs: list[int] = []
            ys: list[int] = []
            while stack:
                y, x = stack.pop()
                xs.append(x); ys.append(y)
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        ny, nx = y + dy, x + dx
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                            seen[ny, nx] = True
                            stack.append((ny, nx))
            ar = len(xs)
            out.append({"area": ar, "bbox": (min(xs), min(ys), max(xs), max(ys)),
                        "cx": float(np.mean(xs)), "cy": float(np.mean(ys))})
    return out


def measure(ground: Image.Image, decor: Image.Image,
            clumps: list[dict[str, Any]]) -> dict[str, Any]:
    a = np.asarray(decor.convert("RGBA")).astype(np.int16)
    r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    op = al > 128
    n_op = int(op.sum())
    tile = W * H

    ink_mask = al > 32
    comps = [c for c in components(ink_mask) if c["area"] >= 800]
    cy = [c["cy"] for c in comps]
    cx = [c["cx"] for c in comps]
    pairs = [(abs(cy[i] - cy[j]), abs(cx[i] - cx[j]))
             for i in range(len(comps)) for j in range(i + 1, len(comps))]
    align_y = (sum(1 for dy, _ in pairs if dy < 10) / len(pairs)) if pairs else 0.0
    align_x = (sum(1 for _, dx in pairs if dx < 10) / len(pairs)) if pairs else 0.0
    bins: dict[int, int] = {}
    for y in cy:
        bins[int(y // 16)] = bins.get(int(y // 16), 0) + 1
    max_bin = (max(bins.values()) / len(comps)) if comps else 0.0

    pink = op & (r > 1.15 * g) & (r > 1.08 * b) & ((0.299*r + 0.587*g + 0.114*b) > 55)
    yellow = op & (r > 140) & (g > 110) & (b < 70)
    pink_tile = int(pink.sum())
    green = op & (g > r) & (g > b)
    nearblack = op & (r <= 3) & (g <= 3) & (b <= 3)
    gray = op & (np.abs(r - g) < 8) & (np.abs(g - b) < 8) \
        & ((0.299*r + 0.587*g + 0.114*b) > 60) \
        & ((0.299*r + 0.587*g + 0.114*b) < 120)

    heights = [c["bbox"][3] - c["bbox"][1] + 1 for c in comps]
    aspects = [(c["bbox"][2] - c["bbox"][0] + 1) / max(1, hh)
               for c, hh in zip(comps, heights)]
    dup = any(abs(aspects[i] - aspects[j]) / max(aspects[i], aspects[j]) < 0.05
              for i in range(len(aspects)) for j in range(i + 1, len(aspects)))
    bucket_set = sorted({bucket_of(h) for h in heights})

    res: dict[str, Any] = {
        "clumps": len(clumps),
        "sprite_layers": sum(len(c["members"]) for c in clumps),
        "families": {f: sum(1 for c in clumps if c["family"] == f)
                     for f in ("bush", "fern", "plantain", "stump", "flower")},
        "clump_buckets": {lab: sum(1 for c in clumps if c["bucket"] == lab)
                          for lab in ("small", "medium", "large")},
        "rock_fallback_assets": 0,
        "C1_aligned_y_pct": round(100 * align_y, 2),
        "C1_aligned_x_pct": round(100 * align_x, 2),
        "C1_max_ybin_pct": round(100 * max_bin, 2),
        "C2_pink_pct_decor": round(100 * pink.sum() / max(1, n_op), 4),
        "C2_pink_pct_tile": round(100 * pink_tile / tile, 4),
        "C2_yellow_pct": round(100 * yellow.sum() / max(1, n_op), 4),
        "C3_components_ge800": len(comps),
        "C3_ink_pct": round(100 * n_op / tile, 2),
        "C3_largest_pct": round(100 * max((c["area"] for c in comps), default=0)
                                / max(1, n_op), 2),
        "C4_green_pct": round(100 * green.sum() / max(1, n_op), 2),
        "C4_mean_B": round(float(b[op].mean()) if n_op else 0.0, 2),
        "C5_nearblack_pct": round(100 * nearblack.sum() / max(1, n_op), 3),
        "C6_heights": sorted(heights),
        "C6_height_ratio": round(max(heights) / max(1, min(heights)), 2) if heights else 0,
        "C6_buckets": bucket_set,
        "C6_duplicate_aspect": bool(dup),
        "C7_gray_pct": round(100 * gray.sum() / max(1, n_op), 3),
        "blossom_pct_tile": round(100 * int((op & (r > 170) & (g > 170)
                                             & (b > 120)).sum()) / tile, 3),
    }
    # verdicts (visual A/B still governs the final PASS)
    v = {
        "C1": res["C1_aligned_y_pct"] <= 20 and res["C1_aligned_x_pct"] <= 20
              and res["C1_max_ybin_pct"] <= 30,
        "C2": res["C2_pink_pct_decor"] < 2 and res["C2_pink_pct_tile"] < 2
              and res["C2_yellow_pct"] < 1,
        "C3": res["C3_components_ge800"] >= 3 and 8 <= res["C3_ink_pct"] <= 35
              and res["C3_largest_pct"] <= 55,
        "C4": res["C4_green_pct"] >= 60 and res["C4_mean_B"] >= 20
              and res["C2_yellow_pct"] < 1,
        "C5": res["C5_nearblack_pct"] <= 2,
        "C6": len(res["C6_buckets"]) >= 2 and res["C6_height_ratio"] >= 1.25
              and not res["C6_duplicate_aspect"],
        "C7": res["C7_gray_pct"] <= 5,
        "D": 8 <= res["clumps"] <= 12,
        "ROCK": res["rock_fallback_assets"] == 0,
    }
    res["verdict"] = {k: ("PASS" if x else "FAIL") for k, x in v.items()}
    return res


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_compare(final: Image.Image, seed: int, ref_dir: Path,
                  out: Path) -> Path | None:
    """Side-by-side sheet. Donor panel is a verified clean square bush crop."""
    ref = Path(ref_dir).expanduser() / "cossacks-3-v1-498085.jpg"
    box = (0, 435, 150, 585)  # #8: 3 white bushes + tall tufts, no UI/units
    if not ref.is_file():
        return None
    with Image.open(ref) as src:
        crop = src.convert("RGB").crop(box).resize((W, H), tpr.RESAMPLE)
    sheet = tpr.build_comparison(
        "t6_bushes_understory", final, crop, seed,
        [{"type": "block"}, {"type": "sprite"}, {"type": "shadow"},
         {"type": "blossom"}], list(box))
    path = out / "t6_bushes_understory_compare.png"
    sheet.save(path, format="PNG", optimize=True)
    return path


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--out-dir", default=str(DEFAULT_OUT))
    p.add_argument("--seed", type=int, default=SEED)
    p.add_argument("--reference-dir", default=str(DEFAULT_REF))
    args = p.parse_args(argv)

    out = Path(args.out_dir).expanduser().resolve()
    out.mkdir(parents=True, exist_ok=True)
    final, ground, _shadows, decor, clumps = render(args.seed)
    png = out / "t6_bushes_understory.png"
    final.save(png, format="PNG", optimize=True)
    compare = build_compare(final, args.seed, Path(args.reference_dir), out)

    result: dict[str, Any] = {
        "generator": "t6_bushes_understory.py", "seed": args.seed,
        "size_px": [W, H], "output": str(png), "sha256": sha256(png),
        "compare": str(compare) if compare else None,
    }
    result.update(measure(ground, decor, clumps))
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
