#!/usr/bin/env python3
"""T6-T09 — headless, deterministic mini-baker for the forest_broadleaf piece.

OWNED FILE (do not edit anything else in the swarm). No Godot is launched: the
piece is composed with Python 3.14 + Pillow + NumPy from port-owned PNG assets,
and the donor reference is only ever READ for the side-by-side sheet.

Design (measured donor truth — see docs/t6/reports/T6-T09.md):
  * tileable ``grass_ground2`` forest floor (contrast 1.12, mirror-tiled),
  * interleaved broadleaf + conifer trees from the real port sprite bank,
  * broadleaf crowns re-graded from #575A30 to donor lime #6C7832 / yellow
    #656038 (lit B>=48, sat 0.43-0.59),
  * conifer crowns re-graded to donor #51582E / #6D6739 with B/G >= 0.40,
  * bare brown trunks corrected to B/G = 0.74 (wave-plan T6-T09 anchor),
  * three apparent size buckets (small ~24 / medium ~50 / large ~84 px),
  * soft shadows cast toward lower-left, ~1x tree height,
  * 30-50% broadleaf share, conifer within one crown width of >=50% of the
    broadleaf crowns.

``render(seed, with_trees)`` is the public entry point; ``with_trees=False``
returns the ground+shadow base so a caller can segment tree ink by difference.

Usage::

    python app/tools/pieces/t6_forest_broadleaf.py
    python app/tools/pieces/t6_forest_broadleaf.py --out-dir /tmp/pieces
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

# ---------------------------------------------------------------------------
# Donor-derived constants (all measured, see report claim table)
# ---------------------------------------------------------------------------
# Per-channel multipliers applied to sprite RGB. Chosen so the upper-65%
# brightness crown mean lands inside the donor bands.
BROAD_LEAF_GRADES: tuple[tuple[float, float, float], ...] = (
    (1.42, 1.52, 1.06),  # lime   -> rendered lit ~#636B33 (hue 69, sat 0.54, B 50)
    (1.36, 1.46, 1.08),  # lime-2 -> between lime and village olive
    (1.36, 1.28, 1.14),  # yellow -> rendered lit ~#5F6333 (hue 53, sat 0.47, B 54)
)
BROAD_WIDTH_SCALE = 1.12      # slightly wider crowns -> clumpier, higher wide_frac
CONIFER_TOP_SCALE = 0.25      # geometric taper -> narrow triangular conifer tiers
CONIFER_SPECS: tuple[tuple[str, tuple[float, float, float], float], ...] = (
    # sprite, RGB grade, height multiplier (conifers read slightly taller)
    ("tree_fir", (0.95, 1.08, 1.15), 1.05),
    ("tree_spruce1", (1.35, 1.45, 1.55), 1.00),
    ("tree_firsmall1", (0.88, 0.98, 1.08), 0.95),
    ("tree_pinesmall1", (1.60, 1.50, 1.80), 0.92),
)
DRY_SPEC = ("tree_pinedry1", (1.25, 1.18, 1.22), 1.00)
TRUNK_BG = 0.74                 # T6-T09 acceptance anchor
TRUNK_FRACTION = 0.26           # bottom share of opaque bbox treated as wood
BLUE_LIFT = 10                  # global B lift -> ground B >= 27, frame sat <= 0.55
SHADOW_ALPHA = 74
SHADOW_BLUR = 4

# size buckets: (min_height, max_height, weight) — donor 15-30/40-60/70-100 @720p
SIZE_BUCKETS: tuple[tuple[int, int, float], ...] = (
    (18, 27, 0.60),
    (43, 58, 0.28),
    (72, 94, 0.12),
)


# ---------------------------------------------------------------------------
# sprite grading
# ---------------------------------------------------------------------------
def grade_sprite(path: Path, mul: tuple[float, float, float],
                 fix_trunk: bool = False) -> Image.Image:
    """Load a port sprite, apply an RGB grade and (optionally) fix trunk B/G.

    Alpha is preserved byte-for-byte. The trunk correction only touches
    lower-bbox pixels that are already brown (R>G>B), so leaf clumps and the
    green understory are never recoloured by it.
    """
    with Image.open(path) as im:
        a = np.asarray(im.convert("RGBA")).copy()
    rgb = a[..., :3].astype(np.float64)
    for c, m in enumerate(mul):
        rgb[..., c] = np.clip(rgb[..., c] * m, 0.0, 255.0)

    if fix_trunk:
        alpha = a[..., 3]
        ys, xs = np.where(alpha > 16)
        if ys.size:
            ytop, ybot = int(ys.min()), int(ys.max())
            y0 = ybot - int(TRUNK_FRACTION * max(1, ybot - ytop))
            yy = np.arange(rgb.shape[0])[:, None]
            wood = ((yy >= y0) & (alpha > 16) & (rgb[..., 0] > rgb[..., 1] + 2)
                    & (rgb[..., 1] > rgb[..., 2] + 2))
            # set B = TRUNK_BG * G for wood pixels -> exact B/G anchor
            rgb[..., 2] = np.where(wood, np.round(TRUNK_BG * rgb[..., 1]),
                                   rgb[..., 2])

    a[..., :3] = np.clip(np.round(rgb), 0, 255).astype(np.uint8)
    return Image.fromarray(a, mode="RGBA")


def tree_tile(graded: Image.Image, target_h: int) -> Image.Image:
    """Crop to opaque ink and scale so the whole tree (crown+trunk) is target_h."""
    bbox = graded.getchannel("A").getbbox()
    if bbox is None:
        return Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    crop = graded.crop(bbox)
    scale = target_h / float(crop.height)
    tw = max(1, int(round(crop.width * scale)))
    return crop.resize((tw, max(1, target_h)), Image.Resampling.LANCZOS)


def geo_taper(tile: Image.Image, top_scale: float) -> Image.Image:
    """Make a conifer crown geometrically triangular: narrow the upper rows.

    Unlike fading alpha (which removes narrow rows and *raises* wide_frac),
    this physically squeezes each upper row toward the centre, producing the
    layered-droop silhouette measured in the donor conifer references.
    """
    a = np.asarray(tile.getchannel("A"))
    h, w = a.shape
    out = np.zeros_like(a)
    for r in range(h):
        f = top_scale + (1.0 - top_scale) * min(1.0, r / max(1, int(0.55 * h)))
        half = max(1, int(round(w * f * 0.5)))
        c = w // 2
        lo, hi = max(0, c - half), min(w, c + half)
        out[r, lo:hi] = a[r, lo:hi]
    tile.putalpha(Image.fromarray(out, mode="L"))
    return tile


# ---------------------------------------------------------------------------
# deterministic tree plan
# ---------------------------------------------------------------------------
def _pick_size(rng: random.Random) -> int:
    r = rng.random()
    acc = 0.0
    for lo, hi, weight in SIZE_BUCKETS:
        acc += weight
        if r < acc:
            return rng.randint(lo, hi)
    return SIZE_BUCKETS[-1][1]


def plan_trees(seed: int) -> list[dict[str, Any]]:
    """Jittered-grid placement with explicit broadleaf<->conifer interleaving."""
    rng = random.Random(seed * 1000003 + 17)
    cells = 9
    cell = W / cells
    trees: list[dict[str, Any]] = []
    broad_anchors: list[dict[str, Any]] = []

    for gy in range(cells):
        for gx in range(cells):
            if rng.random() > 0.95:
                continue
            x = (gx + 0.5 + rng.uniform(-0.34, 0.34)) * cell
            y = (gy + 0.5 + rng.uniform(-0.34, 0.34)) * cell
            h = _pick_size(rng)
            if rng.random() < 0.50:
                grade = BROAD_LEAF_GRADES[rng.randrange(len(BROAD_LEAF_GRADES))]
                t = {"species": "broadleaf", "sprite": "tree_oak",
                     "grade": grade, "x": x, "y": y, "h": h, "hmul": 1.0,
                     "mirror": rng.random() < 0.5}
                trees.append(t)
                broad_anchors.append(t)
            elif rng.random() < 0.035:
                name, grade, hmul = DRY_SPEC
                trees.append({"species": "dry", "sprite": name, "grade": grade,
                              "x": x, "y": y, "h": h, "hmul": hmul,
                              "mirror": rng.random() < 0.5})
            else:
                name, grade, hmul = CONIFER_SPECS[rng.randrange(len(CONIFER_SPECS))]
                trees.append({"species": "conifer", "sprite": name, "grade": grade,
                              "x": x, "y": y, "h": h, "hmul": hmul,
                              "mirror": rng.random() < 0.5})

    # Pair ~55% of broadleaf crowns with a nearby conifer centroid, so the
    # species-interleaving criterion is satisfied without monoculture blocks.
    rng.shuffle(broad_anchors)
    for anchor in broad_anchors[: max(1, int(0.75 * len(broad_anchors)))]:
        name, grade, hmul = CONIFER_SPECS[rng.randrange(len(CONIFER_SPECS))]
        ang = rng.uniform(0, 2 * math.pi)
        dist = anchor["h"] * 0.70 + rng.uniform(2, 7)
        x = anchor["x"] + math.cos(ang) * dist
        y = anchor["y"] + math.sin(ang) * dist * 0.75
        ch = rng.randint(16, 24)  # small paired conifer: interleaves without
                                  # swallowing the broadleaf crown component
        trees.append({"species": "conifer", "sprite": name, "grade": grade,
                      "x": x, "y": y, "h": ch, "hmul": hmul,
                      "mirror": rng.random() < 0.5})

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
    # Crop on a mirror-symmetry axis of the 1024² tile (256 or 768). The
    # wrapped canvas edges are then exact mirror copies -> zero seam when the
    # 512² piece is tiled, unlike an arbitrary wrap offset.
    ox = 256 + 512 * (int(seed) & 1)
    oy = 256 + 512 * ((int(seed) >> 1) & 1)
    floor = tpr.wrap_crop(tile, ox, oy, W, H).convert("RGB")
    # grass_ground2 carries pale sand/rock streaks that read as bare eroded
    # ground. Under a donor broadleaf canopy those streaks are shaded and
    # green: compress highlights above L~88 and add a slight green cast while
    # keeping the fine 2-5 px grain and the wrap seam.
    a = np.asarray(floor).astype(np.float64)
    mx = a.max(axis=2)
    over = np.clip((mx - 80.0) / 80.0, 0.0, 1.0)
    a *= (1.0 - 0.62 * over)[..., None]
    a[..., 1] *= 1.0 + 0.06 * over
    # Remaining pale low-saturation streaks (exposed rock/sand in the source
    # block) read as bare gullies under canopy: fold them into dark forest
    # green while preserving fine grain and the mirror-tile seam.
    mn = a.min(axis=2)
    gray = ((mx - mn) < 40.0) & (mx > 66.0)
    target = np.array([58.0, 66.0, 29.0])
    a[gray] = 0.22 * a[gray] + 0.78 * target
    return Image.fromarray(np.clip(np.round(a), 0, 255).astype(np.uint8), mode="RGB")


def build_shadows(trees: list[dict[str, Any]]) -> Image.Image:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for t in trees:
        h = t["h"] * t["hmul"]
        cx = t["x"] - 0.42 * h          # sun from upper-right -> lower-left
        cy = t["y"] + 0.30 * h
        rx, ry = 0.50 * h, 0.22 * h
        d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry),
                  fill=(22, 26, 12, SHADOW_ALPHA))
    return layer.filter(ImageFilter.GaussianBlur(SHADOW_BLUR))


def render(seed: int = SEED, with_trees: bool = True
           ) -> tuple[Image.Image, list[dict[str, Any]]]:
    """Render the 512x512 piece. with_trees=False yields the ground+shadow base."""
    trees = plan_trees(seed)
    base = Image.alpha_composite(build_ground(seed).convert("RGBA"),
                                 build_shadows(trees))
    if with_trees:
        cache: dict[tuple[str, tuple[float, float, float], int], Image.Image] = {}
        for t in trees:
            key = (t["sprite"], t["grade"], int(round(t["h"])), t["species"])
            tile = cache.get(key)
            if tile is None:
                graded = grade_sprite(SPRITES_HI_DIR / (t["sprite"] + ".png"),
                                      t["grade"], fix_trunk=(t["species"] == "broadleaf"))
                tile = tree_tile(graded, int(round(t["h"])))
                if t["species"] == "broadleaf":
                    tile = tile.resize(
                        (max(1, int(round(tile.width * BROAD_WIDTH_SCALE))), tile.height),
                        Image.Resampling.LANCZOS)
                else:
                    tile = geo_taper(tile, CONIFER_TOP_SCALE)
                cache[key] = tile
            if t["mirror"]:
                tile = tile.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            px = int(round(t["x"] - tile.width * 0.5))
            py = int(round(t["y"] - tile.height))  # foot anchor
            tpr.paste_rgba(base, tile, px, py)

    rgb = np.asarray(base.convert("RGB")).astype(np.int16)
    rgb[..., 2] = np.clip(rgb[..., 2] + BLUE_LIFT, 0, 255)  # global sat gate
    out = Image.fromarray(rgb.astype(np.uint8), mode="RGB")
    return out, trees


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
    png = out_dir / "t6_forest_broadleaf.png"
    render_img.save(png, format="PNG", optimize=True)

    # side-by-side against the donor primary target (read-only)
    ref_path = Path(args.reference_dir).expanduser() / "cossacks-3-v1-498085.jpg"
    box = [180, 200, 340, 340]  # documented #8 mixed-forest overview crop
    if ref_path.is_file():
        with Image.open(ref_path) as src:
            ref = src.convert("RGB").crop(box).resize((W, H), tpr.RESAMPLE)
        sheet = tpr.build_comparison(
            "t6_forest_broadleaf", render_img, ref, args.seed,
            [{"type": "block"}, {"type": "sprite"}, {"type": "shadow"},
             {"type": "grade"}], box)
        sheet.save(out_dir / "t6_forest_broadleaf_compare.png",
                   format="PNG", optimize=True)

    counts: dict[str, int] = {}
    for t in trees:
        counts[t["species"]] = counts.get(t["species"], 0) + 1
    result = {
        "generator": "t6_forest_broadleaf.py", "seed": args.seed,
        "size_px": [W, H], "trees": len(trees), "species_counts": counts,
        "broadleaf_share_pct": round(100.0 * counts.get("broadleaf", 0) / len(trees), 1),
        "output": str(png), "sha256": sha256(png),
        "compare": str(out_dir / "t6_forest_broadleaf_compare.png"),
    }
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
