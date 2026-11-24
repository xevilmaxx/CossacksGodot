#!/usr/bin/env python3
"""Terrain-only contact sheet: port capture vs Cossacks 3 reference crops.

The first version of this sheet paired a PORT building crop with a REFERENCE
ravine crop and printed ``norm_mad`` numbers, which were meaningless because
the two sides were not the same feature. This version only ever compares
feature-aligned pairs:

  * a full-frame port image next to the full-frame primary reference, shown
    as scene context only (NEVER scored -- they are different scenes);
  * three PORT crops chosen automatically by simple colour classification
    (water = blue-dominant, rock = grey-brown low-sat, grass = olive), each
    paired with the reference crop of the SAME feature. Reference boxes come
    from docs/audit/TERRAIN_REFERENCE_IMAGES.md §6. Primary #8 has no water,
    so the water reference uses the §6 secondary #6 water crop and is labelled
    as such.

Any numeric score is a SMOKE METRIC for human calibration only, explicitly
labelled "SMOKE ONLY — feature-aligned, not a fidelity gate" (compare_shots.py
:15-18, docs/COMMANDS.md §11). If a feature cannot be classified reliably the
pair is shown with "not detected" and no score at all rather than a bogus one.

Usage (from the project root)::

    python app/tools/terrain_compare.py
    python app/tools/terrain_compare.py --shot app/shots/terrain_sample.png \
        --ref "C:\\Users\\Maxym.Oboyshev\\Downloads\\c3\\cossacks-3-v1-498085.jpg"

Output: app/shots/terrain_sample_contact.png
"""
from __future__ import annotations

import argparse
import colorsys
import importlib.util
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent
ROOT = APP.parent
SHOTS = APP / "shots"
BEST_FILE = SHOTS / "terrain_sample_128_seedscan_best.json"

DEFAULT_SHOT = SHOTS / "terrain_sample.png"
DEFAULT_REF = Path(r"C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg")
# §6 secondary reference for water: primary #8 has no water (doc §3.4/§5).
DEFAULT_WATER_REF = Path(r"C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg")
DEFAULT_OUT = SHOTS / "terrain_sample_contact.png"

# SMOKE_LABEL is stamped on every scored pair. It is deliberately not a
# pass/fail gate and must stay attached to any number this tool prints.
SMOKE_LABEL = "SMOKE ONLY — feature-aligned, not a fidelity gate"

# Set by --no-water / --seed in main(). For map types such as nowater2 the
# water feature genuinely does not exist, so its pair is labelled "not
# detected" instead of being scored against a spurious blue-ish crop.
NO_WATER = False
SEED_OVERRIDE = None

# Reference boxes (x0, y0, x1, y1) in source pixels, from
# docs/audit/TERRAIN_REFERENCE_IMAGES.md §6. Each is paired with the PORT
# crop of the SAME feature, never with an arbitrary screen region.
REFERENCE_PAIRS = (
    {
        "feature": "water",
        "ref_source": "secondary #6 articolo-787.jpg §6 water (600,0,960,160); "
                      "primary #8 has no water (§3.4)",
        "ref_box": (600, 0, 960, 160),
        "use_water_ref": True,
    },
    {
        "feature": "rock",
        "ref_source": "primary #8 §6 crop A ravine/rock (560,150,1000,560)",
        "ref_box": (560, 150, 1000, 560),
        "use_water_ref": False,
    },
    {
        "feature": "grass",
        "ref_source": "primary #8 §6 crop C plateau/grass (350,0,850,300)",
        "ref_box": (350, 0, 850, 300),
        "use_water_ref": False,
    },
)

# Simple HSV signatures used only to LOCATE a same-feature port crop.
# target hue (turns), tolerance, sat range, value range.
FEATURE_SIGNATURES = {
    "water": {"hue": 0.56, "hue_tol": 0.14, "sat": (0.05, 0.45), "val": (0.10, 0.75)},
    "rock":  {"hue": 0.10, "hue_tol": 0.10, "sat": (0.05, 0.50), "val": (0.15, 0.80)},
    "grass": {"hue": 0.19, "hue_tol": 0.10, "sat": (0.15, 0.85), "val": (0.10, 0.70)},
}
MIN_CONFIDENCE = 0.15  # below this the feature is reported as "not detected"

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS

# Layout (pixels on the contact sheet).
CELL_W, CELL_H = 480, 270
CAPTION_H = 44
GAP = 12
MARGIN = 14
HEADER_H = 64


def load_compare_shots():
    """Import the existing comparator as a module without editing it."""
    path = TOOLS / "compare_shots.py"
    spec = importlib.util.spec_from_file_location("c3_compare_shots", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def font(size: int):
    for name in ("arial.ttf", "C:\\Windows\\Fonts\\arial.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def fit(im: Image.Image, size: tuple[int, int]) -> Image.Image:
    return im.resize(size, _RESAMPLE)


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def resolve_seed() -> object:
    if BEST_FILE.exists():
        try:
            return json.loads(BEST_FILE.read_text(encoding="utf-8")).get("seed")
        except (OSError, ValueError):
            pass
    return "?"


def _hue_dist(a: float, b: float) -> float:
    d = abs(a - b) % 1.0
    return min(d, 1.0 - d)


def _range_score(x: float, lo: float, hi: float, soft: float = 0.08) -> float:
    if lo <= x <= hi:
        return 1.0
    if x < lo:
        return max(0.0, 1.0 - (lo - x) / soft)
    return max(0.0, 1.0 - (x - hi) / soft)


def feature_confidence(kind: str, r: int, g: int, b: int) -> float:
    """Return [0,1]: how strongly one RGB pixel matches ``kind``'s signature."""
    sig = FEATURE_SIGNATURES[kind]
    h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
    hue_score = max(0.0, 1.0 - _hue_dist(h, sig["hue"]) / sig["hue_tol"])
    sat_score = _range_score(s, *sig["sat"])
    val_score = _range_score(v, *sig["val"])
    return hue_score * sat_score * val_score


def choose_port_crop(im: Image.Image, kind: str) -> tuple[tuple[int, int, int, int], float]:
    """Pick a quarter-frame PORT crop centred on the best-matching tile.

    Returns ((x0, y0, x1, y1), confidence). The crop is deliberately a region
    of the frame, not a single pixel, so the paired cell is visually useful.
    """
    w, h = im.size
    grid = max(2, min(16, min(w, h) // 8))
    small = im.resize((grid, grid), _RESAMPLE)
    px = small.load()
    best_conf, best_gx, best_gy = -1.0, 0, 0
    for gy in range(grid):
        for gx in range(grid):
            conf = feature_confidence(kind, *px[gx, gy])
            if conf > best_conf:
                best_conf, best_gx, best_gy = conf, gx, gy

    cw, ch = max(1, w // 4), max(1, h // 4)
    cx = int((best_gx + 0.5) * w / grid)
    cy = int((best_gy + 0.5) * h / grid)
    x0 = max(0, min(w - cw, cx - cw // 2))
    y0 = max(0, min(h - ch, cy - ch // 2))
    return (x0, y0, x0 + cw, y0 + ch), best_conf


def build_contact(shot_path: Path, ref_path: Path, out_path: Path,
                  water_ref_path: Path) -> int:
    compare = load_compare_shots()
    shot = compare.load_rgb(str(shot_path))
    ref = compare.load_rgb(str(ref_path))
    water_ref = (compare.load_rgb(str(water_ref_path))
                 if water_ref_path.is_file() else None)
    f_cap = font(12)
    f_small = font(12)
    f_head = font(17)

    rows = 1 + len(REFERENCE_PAIRS)
    width = MARGIN * 2 + CELL_W * 2 + GAP
    height = MARGIN * 2 + HEADER_H + rows * (CELL_H + CAPTION_H) + (rows - 1) * GAP
    sheet = Image.new("RGB", (width, height), (24, 24, 26))
    draw = ImageDraw.Draw(sheet)

    draw.text((MARGIN, MARGIN),
              "TERRAIN SAMPLE CONTACT SHEET - feature-aligned port vs Cossacks 3",
              fill=(235, 235, 235), font=f_head)
    draw.text((MARGIN, MARGIN + 24), SMOKE_LABEL,
              fill=(255, 205, 120), font=f_small)
    draw.text((MARGIN, MARGIN + 44),
              "Full frames are scene context only (not scored). Crops are "
              "same-feature pairs; units/HUD in the reference are ignored.",
              fill=(180, 180, 180), font=f_small)

    def cell(row: int, col: int, image: Image.Image, caption: str,
             scored: bool = False) -> None:
        x = MARGIN + col * (CELL_W + GAP)
        y = MARGIN + HEADER_H + row * (CELL_H + CAPTION_H + GAP)
        sheet.paste(fit(image.convert("RGB"), (CELL_W, CELL_H)), (x, y))
        draw.rectangle((x, y + CELL_H, x + CELL_W, y + CELL_H + CAPTION_H),
                       fill=(42, 42, 46))
        draw.text((x + 6, y + CELL_H + 4), caption, fill=(225, 225, 225), font=f_cap)
        draw.text((x + 6, y + CELL_H + 22),
                  SMOKE_LABEL if scored else "visual only - no score",
                  fill=(200, 200, 200), font=f_cap)

    seed = SEED_OVERRIDE if SEED_OVERRIDE is not None else resolve_seed()
    # (a) Full frames: context only, NEVER scored (different scenes).
    cell(0, 0, shot, "PORT full frame  %s  seed=%s  (not scored)"
         % (shot_path.name, seed))
    cell(0, 1, ref, "REFERENCE full frame  %s  (not scored)" % ref_path.name)

    # (b) Feature-aligned pairs only. A score is computed (and labelled) only
    # when both sides are the same feature; no misaligned numbers are kept.
    pairs = []
    for i, spec in enumerate(REFERENCE_PAIRS, start=1):
        feature = spec["feature"]
        ref_image = water_ref if spec["use_water_ref"] else ref
        box = tuple(spec["ref_box"])
        ref_region = ref_image.crop(box) if ref_image is not None else None

        port_box, conf = choose_port_crop(shot, feature)
        detected = conf >= MIN_CONFIDENCE
        if NO_WATER and feature == "water":
            detected = False
        port_region = shot.crop(port_box) if detected else None

        score = None
        method = None
        if detected and ref_region is not None:
            score, method, _detail = compare.score_pair(port_region, ref_region)

        pairs.append({
            "feature": feature,
            "port_box_xyxy": list(port_box),
            "classification_confidence": round(conf, 3),
            "detected": detected,
            "ref_source": spec["ref_source"],
            "ref_box_xyxy": list(box),
            "score": score,
            "method": method,
            "score_label": SMOKE_LABEL if score is not None else "not detected - no score",
        })

        if detected:
            port_caption = "PORT %s crop %s conf=%.2f  score=%s" % (
                feature, port_box, conf, "%.4f" % score if score is not None else "n/a")
        else:
            why = ("no water in this map" if (NO_WATER and feature == "water")
                   else "low colour confidence")
            port_caption = "PORT %s NOT DETECTED (%s) - no score" % (feature, why)
        cell(i, 0, port_region if detected else shot, port_caption,
             scored=(score is not None))

        ref_caption = ("REF %s  box=%s" % (feature, box))
        if not detected:
            ref_caption += "  (no port match - informational)"
        if ref_region is not None:
            cell(i, 1, ref_region, ref_caption, scored=(score is not None))
        else:
            cell(i, 1, shot, "REF %s unavailable (water ref missing) - no score" % feature)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_path)
    print(json.dumps({
        "out": rel(out_path),
        "dimensions": list(sheet.size),
        "shot": rel(shot_path),
        "reference": str(ref_path),
        "water_reference": str(water_ref_path) if water_ref is not None else None,
        "score_label": SMOKE_LABEL,
        "pairs": pairs,
        "note": "Full frames are unscored scene context. Every number is a "
                "feature-aligned SMOKE metric only; 0.80 is NOT a fidelity gate.",
    }, indent=2))
    print("[compare] contact sheet: %s" % rel(out_path))
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--shot", default=str(DEFAULT_SHOT), help="captured port PNG")
    ap.add_argument("--ref", default=str(DEFAULT_REF), help="primary C3 reference still (#8)")
    ap.add_argument("--water-ref", default=str(DEFAULT_WATER_REF),
                    help="secondary C3 reference for water (#6); #8 has no water")
    ap.add_argument("--out", default=str(DEFAULT_OUT), help="contact sheet output PNG")
    ap.add_argument("--no-water", action="store_true",
                    help="force the water pair to 'not detected' (e.g. nowater2 maps)")
    ap.add_argument("--seed", default=None,
                    help="seed label override for the full-frame caption")
    args = ap.parse_args(argv)
    shot_path = Path(args.shot)
    ref_path = Path(args.ref)
    for p in (shot_path, ref_path):
        if not p.is_file():
            print("ERROR: missing input file: %s" % p, file=sys.stderr)
            return 2
    global NO_WATER, SEED_OVERRIDE
    NO_WATER = args.no_water
    SEED_OVERRIDE = args.seed
    return build_contact(shot_path, ref_path, Path(args.out), Path(args.water_ref))


if __name__ == "__main__":
    sys.exit(main())
