#!/usr/bin/env python3
"""TERRAIN-SMALL read-only image / runner-log inspector.

No writes, no Godot launches, no network. Used to report the WINDOWED GPU
captures and to scan runner stderr.txt files for SCRIPT ERROR lines.

    python variant3d/tools/smallmap_capture.py stats <png> [<png> ...] \
        [--reference C:/Users/.../Temp/opencode/v792_tileindex_water.png]
    python variant3d/tools/smallmap_capture.py scan-stderr <stderr.txt> [...]
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image


def image_stats(path: str) -> dict:
    p = Path(path)
    with Image.open(p) as im:
        rgb = np.asarray(im.convert("RGB"), dtype=np.float32)
    luma = 0.2126 * rgb[:, :, 0] + 0.7152 * rgb[:, :, 1] + 0.0722 * rgb[:, :, 2]
    non_black = float(np.any(rgb > 8.0, axis=2).mean())
    # Full-width dark bands: rows where >90% of pixels have luma < 20.
    dark_rows = int(((luma < 20.0).mean(axis=1) > 0.90).sum())
    return {
        "path": str(p),
        "bytes": p.stat().st_size,
        "width": int(rgb.shape[1]),
        "height": int(rgb.shape[0]),
        "non_black_fraction": round(non_black, 6),
        "mean_rgb": [round(float(v), 3) for v in rgb.reshape(-1, 3).mean(axis=0)],
        "mean_luma": round(float(luma.mean()), 3),
        "full_width_dark_rows": dark_rows,
        "full_width_dark_row_fraction": round(dark_rows / float(rgb.shape[0]), 6),
    }


def cmd_stats(args: argparse.Namespace) -> None:
    rows = [image_stats(p) for p in args.images]
    if args.reference:
        rows.append({"reference": args.reference, **image_stats(args.reference)})
    print(json.dumps(rows, indent=2))
    print("NOTE: qualitative comparison only. No donor parity is claimed.")


def cmd_scan_stderr(args: argparse.Namespace) -> None:
    out = []
    for raw in args.logs:
        p = Path(raw)
        text = p.read_text(encoding="utf-8", errors="replace") if p.exists() else ""
        lines = [ln.strip() for ln in text.splitlines() if "SCRIPT ERROR" in ln]
        out.append({"path": str(p), "exists": p.exists(),
                    "script_error_lines": len(lines), "lines": lines[:20]})
    print(json.dumps(out, indent=2))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)
    ps = sub.add_parser("stats")
    ps.add_argument("images", nargs="+")
    ps.add_argument("--reference", default=None)
    ps.set_defaults(func=cmd_stats)
    pe = sub.add_parser("scan-stderr")
    pe.add_argument("logs", nargs="+")
    pe.set_defaults(func=cmd_scan_stderr)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
