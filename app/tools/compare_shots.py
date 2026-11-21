#!/usr/bin/env python3
"""Headless screenshot-vs-reference comparator (backlog ticket N-24).

Scores a captured PNG against a reference crop with a value in [0, 1]
(1.0 = pixel-identical). Pillow only; scikit-image SSIM is used when present,
otherwise a normalised mean-absolute-difference fallback is used. No Godot
import, no GPU, no network, no donor asset access.

Usage (from project root):
    python app/tools/compare_shots.py --shot <png> --ref <png> \
        [--crop x,y,w,h] [--threshold 0.80] [--json]

Exit codes: 0 = PASS, 1 = FAIL, 2 = bad invocation / unreadable input.

The default threshold of 0.80 is a SMOKE-TEST placeholder, NOT a fidelity
gate. A real per-check threshold must be calibrated against the
reference/videos.md stills before this tool can act as a red gate;
see docs/COMMANDS.md §11.
"""
import argparse
import json
import sys

from PIL import Image, ImageChops, ImageStat

EXIT_PASS = 0
EXIT_FAIL = 1
EXIT_BAD = 2

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS


def parse_crop(text):
    """Argparse type: --crop x,y,w,h in reference-image pixels."""
    parts = text.split(",")
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("--crop must be x,y,w,h (four integers)")
    try:
        x, y, w, h = (int(p.strip()) for p in parts)
    except ValueError:
        raise argparse.ArgumentTypeError("--crop must be x,y,w,h (four integers)")
    if x < 0 or y < 0 or w <= 0 or h <= 0:
        raise argparse.ArgumentTypeError("--crop needs x,y >= 0 and w,h > 0")
    return x, y, w, h


def parse_threshold(text):
    """Argparse type: similarity threshold must be within [0, 1]."""
    try:
        value = float(text)
    except ValueError:
        raise argparse.ArgumentTypeError("--threshold must be a number in [0, 1]")
    if not 0.0 <= value <= 1.0:
        raise argparse.ArgumentTypeError("--threshold must be in [0, 1]")
    return value


def load_rgb(path):
    """Open an image and return an RGB copy; exit 2 if it cannot be read."""
    try:
        with Image.open(path) as im:
            return im.convert("RGB")
    except (OSError, ValueError) as exc:
        print("ERROR: cannot open %s: %s" % (path, exc), file=sys.stderr)
        sys.exit(EXIT_BAD)


def clamp_box(x, y, w, h, size):
    """Clamp a (x, y, w, h) region to an image, keeping at least one pixel."""
    iw, ih = size
    x0 = max(0, min(x, iw - 1))
    y0 = max(0, min(y, ih - 1))
    x1 = max(x0 + 1, min(x0 + w, iw))
    y1 = max(y0 + 1, min(y0 + h, ih))
    return x0, y0, x1, y1


def prepare_pair(shot, ref, crop):
    """Crop both images to the same region and align their sizes.

    --crop is given in reference pixels; its normalised coordinates are
    applied to the shot, so crops still line up when the two captures have
    different resolutions. Without --crop the whole frames are compared.
    """
    if crop is None:
        ref_region = ref
        shot_region = shot
    else:
        rx0, ry0, rx1, ry1 = clamp_box(*crop, size=ref.size)
        ref_region = ref.crop((rx0, ry0, rx1, ry1))
        rw, rh = ref.size
        sw, sh = shot.size
        # Normalised reference region -> shot pixel region.
        sx0 = max(0, min(int(round(rx0 * sw / float(rw))), sw - 1))
        sy0 = max(0, min(int(round(ry0 * sh / float(rh))), sh - 1))
        sx1 = max(sx0 + 1, min(int(round(rx1 * sw / float(rw))), sw))
        sy1 = max(sy0 + 1, min(int(round(ry1 * sh / float(rh))), sh))
        shot_region = shot.crop((sx0, sy0, sx1, sy1))

    if shot_region.size != ref_region.size:
        shot_region = shot_region.resize(ref_region.size, _RESAMPLE)
    return shot_region, ref_region


def score_pair(shot_region, ref_region):
    """Return (score in [0,1], method id, method detail).

    SSIM is preferred when scikit-image is importable; any failure there
    falls back to 1 - mean-absolute-difference/255, which is exactly 1.0
    for identical images.
    """
    try:
        from skimage.metrics import structural_similarity as ssim
    except ImportError:
        ssim = None

    if ssim is not None:
        try:
            value = float(ssim(ref_region, shot_region, channel_axis=2, data_range=255))
            return (round(min(1.0, max(0.0, value)), 4), "ssim",
                    "skimage.metrics.structural_similarity")
        except Exception:
            pass  # a broken/older skimage must not break the comparison

    diff = ImageChops.difference(shot_region, ref_region)
    mean_abs = sum(ImageStat.Stat(diff).mean) / 3.0  # R, G, B
    value = 1.0 - (mean_abs / 255.0)
    return (round(min(1.0, max(0.0, value)), 4), "norm_mad",
            "1 - mean(|shot-ref|)/255 (scikit-image unavailable)")


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Score a screenshot against a reference crop (0..1, 1.0 = identical).")
    ap.add_argument("--shot", required=True, help="captured PNG to score")
    ap.add_argument("--ref", required=True, help="reference PNG (or crop source)")
    ap.add_argument("--crop", type=parse_crop, metavar="x,y,w,h",
                    help="region in REFERENCE pixels; scaled to the shot")
    ap.add_argument("--threshold", type=parse_threshold, default=0.80, metavar="FLOAT",
                    help="PASS if score >= threshold (default: 0.80, smoke test only)")
    ap.add_argument("--json", action="store_true", help="emit one JSON object on stdout")
    args = ap.parse_args(argv)

    shot = load_rgb(args.shot)
    ref = load_rgb(args.ref)
    shot_region, ref_region = prepare_pair(shot, ref, args.crop)
    score, method, detail = score_pair(shot_region, ref_region)
    passed = score >= args.threshold

    result = {
        "shot": args.shot,
        "ref": args.ref,
        "crop": list(args.crop) if args.crop else None,
        "method": method,
        "detail": detail,
        "score": score,
        "threshold": args.threshold,
        "verdict": "PASS" if passed else "FAIL",
        "passed": passed,
        "note": "Default threshold is a smoke test; calibrate against "
                "reference/videos.md stills before using as a fidelity gate.",
    }

    if args.json:
        print(json.dumps(result, sort_keys=True))
    else:
        print("method    : %s (%s)" % (method, detail))
        print("score     : %.4f" % score)
        print("threshold : %.4f" % args.threshold)
        print("verdict   : %s" % result["verdict"])
        print("note      : %s" % result["note"])

    return EXIT_PASS if passed else EXIT_FAIL


if __name__ == "__main__":
    sys.exit(main())
