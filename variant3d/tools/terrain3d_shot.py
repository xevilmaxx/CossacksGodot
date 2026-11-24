#!/usr/bin/env python3
"""Read-only verification helper for the M0.5 3D terrain art pass.

Checks the PNG produced by terrain3d_sandbox.gd (size + non-blankness), and
measures the three M0.5 art-pass targets against the M0 baseline:
  * ground mean luminance in the central terrain ROI (M0 = 49.7; donor ~75-100)
  * seam-gap pixels (thin bright see-through lines; M0 = 2533)
  * reference luminance of the donor JPG and the 2D sample FINAL_land_v5.png
Does NOT launch Godot: every Godot launch goes through godot_runner.py.

Usage:
  python app/tools/terrain3d_shot.py                 # terrain3d_m05.png
  python app/tools/terrain3d_shot.py --shot app/shots/terrain3d_sandbox.png
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SHOT = ROOT / "app" / "shots" / "terrain3d_m06.png"
DEFAULT_STATS = ROOT / "app" / "shots" / "terrain3d_m06.json"
M05_SHOT = ROOT / "app" / "shots" / "terrain3d_m05.png"
M0_SHOT = ROOT / "app" / "shots" / "terrain3d_sandbox.png"
DONOR = Path(r"C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg")
TWO_D = ROOT / "app" / "shots" / "FINAL_land_v5.png"

# Central region fully inside the 32 m patch for the shipped camera framing.
ROI = (slice(160, 560), slice(250, 1030))


def luma(rgb: np.ndarray) -> np.ndarray:
    return 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]


def box_mean(a: np.ndarray, size: int) -> np.ndarray:
    """Uniform box mean via an integral image (no scipy needed)."""
    p = np.pad(a, ((size // 2, size // 2), (size // 2, size // 2)), mode="edge")
    c = np.pad(p.cumsum(0).cumsum(1), ((1, 0), (1, 0)))
    return (c[size:, size:] - c[:-size, size:]
            - c[size:, :-size] + c[:-size, :-size]) / (size * size)


def measure(path: Path) -> dict | None:
    if not path.exists():
        return None
    rgb = np.asarray(Image.open(path).convert("RGB")).astype(np.float64)
    l = luma(rgb)
    ground = l[ROI]
    local = box_mean(l, 15)
    # Thin bright slivers against darker terrain inside the patch = see-through
    # gaps. Same metric applied to M0 and M0.5 so the before/after is honest.
    seams = int((l[ROI] > local[ROI] + 30).sum())
    return {
        "size": f"{rgb.shape[1]}x{rgb.shape[0]}",
        "mean_luma_all": round(float(l.mean()), 2),
        "stddev_luma_all": round(float(l.std()), 2),
        "ground_mean_luma_roi": round(float(ground.mean()), 2),
        "bright_line_heuristic_px": seams,
        "cliff_band_px": cliff_band_pixels(l),
    }


def cliff_band_pixels(l: np.ndarray) -> int:
    """Dark, horizontally elongated, vertically thin runs inside the patch.

    These are the M0.5 'horizontal dark cliff bands' the reviewer rejected:
    side quads lit with the wrong normal / near-black material.
    """
    dark = (l[ROI] < 55.0).astype(np.float64)
    hmean = box_mean(dark, 41)
    vmean = box_mean(dark, 5)
    return int(((dark > 0) & (hmean > 0.75) & (vmean < 0.60)).sum())


def mask_seam_pixels(path: Path) -> int | None:
    """True see-through gaps: magenta background pixels inside the patch ROI.

    Produced by the --seam-mask render (solid magenta background, distant
    ground hidden). This is the authoritative seam metric; the local-contrast
    heuristic is texture-contrast dominated and must NOT be called a seam.
    """
    if not path.exists():
        return None
    rgb = np.asarray(Image.open(path).convert("RGB")).astype(np.int16)
    magenta = ((rgb[..., 0] > 170) & (rgb[..., 2] > 170) & (rgb[..., 1] < 90))
    return int(magenta[ROI].sum())


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--shot", type=Path, default=DEFAULT_SHOT)
    args = ap.parse_args()
    shot = args.shot
    stats_path = DEFAULT_STATS

    cur = measure(shot)
    if cur is None:
        print(f"MISSING: {shot}")
        return 1
    print(f"[shot] {shot}")
    print("  " + json.dumps(cur))
    ok = (cur["size"] == "1280x720" and cur["stddev_luma_all"] >= 10.0)

    for tag, path in (("M0.5 (rejected)", M05_SHOT), ("M0 baseline", M0_SHOT),
                      ("donor JPG", DONOR), ("2D sample", TWO_D)):
        m = measure(path)
        if m:
            print(f"[{tag}] " + json.dumps(m))

    # M0 seam count (documented method): background-RGB-coloured pixels
    # embedded >=55% in terrain within an 11x11 neighbourhood = 2284 px.
    print("[seams] M0 baseline = 2284 px (background-hole detection, 11x11)")
    if cur.get("cliff_band_px", 0) > 0:
        print(f"[cliffs] M0.6 cliff-band px = {cur['cliff_band_px']}")
    m06 = mask_seam_pixels(ROOT / "app" / "shots" / "terrain3d_m06_seammask.png")
    if m06 is not None:
        print(f"[seams] M0.6 = {m06} px (magenta mask inside central ROI)")
        ok = ok and m06 == 0
    else:
        print("[seams] M0.6 = MISSING magenta mask render")

    if stats_path.exists():
        d = json.loads(stats_path.read_text(encoding="utf-8"))
        print("[stats] " + json.dumps({
            "camera": d.get("camera"),
            "performance": d.get("performance"),
            "art_pass": d.get("art_pass"),
            "side_quads": d.get("side_quads"),
            "perimeter_wall_quads": d.get("perimeter_wall_quads"),
            "seam_policy": d.get("seam_policy"),
            "surfaces": d.get("surfaces"),
            "triangles": d.get("triangles"),
        }, indent=2))
    else:
        print(f"[stats] MISSING: {stats_path}")
        ok = False

    print(f"VERDICT nonblank_1280x720={ok}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
