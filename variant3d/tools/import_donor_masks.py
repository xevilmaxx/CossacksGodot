"""Import donor terrain masks (RGB TGA -> compact PNG + manifest).

The donor generates every random map from a hand-authored heightmask:
  C:/Games/Cossacks 3/data/gen/terrainmasks/<type>/Xpl_mask_<type>_<n>_gauss.tga
  R = relief (plateau/hill/ravine), G = forest/stone, B = water, white = start.

The gauss variants only carry water (R/G are zero except starts); relief and
forest come from the pattern passes. We still copy RGB so the format stays
identical and a future mask with relief/forest data works without a reimport.

Usage (from project root):
  python app/tools/import_donor_masks.py [--game PATH]

The donor root comes from --game or $COSSACKS3_DIR (default:
C:/Games/Cossacks 3). Donor files are private use — never redistribute.
"""
from __future__ import annotations

import argparse
import json
import os
from collections import deque
from pathlib import Path

from PIL import Image

# Portable donor location: $COSSACKS3_DIR overrides the historical Windows
# default (mirrors copy_assets.py). OUT stays project-relative.
DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

def donor_for(game):
    return Path(game).expanduser() / "data" / "gen" / "terrainmasks"

DONOR = donor_for(DEFAULT_GAME)
OUT = Path(__file__).resolve().parent.parent / "assets" / "terrain" / "masks"
MANIFEST = OUT / "manifest.json"
PER_TYPE = 8  # keep the asset set light: enough variety without shipping ~1000 files


def start_dots(rgb) -> list[list[float]]:
    """Connected components of pure white pixels (donor start markers)."""
    h, w = rgb.shape[:2]
    seen = [[False] * w for _ in range(h)]
    out: list[list[float]] = []
    white = (rgb[:, :, 0] == 255) & (rgb[:, :, 1] == 255) & (rgb[:, :, 2] == 255)
    for y in range(h):
        for x in range(w):
            if not white[y, x] or seen[y][x]:
                continue
            q = deque([(x, y)])
            seen[y][x] = True
            pts = []
            while q:
                cx, cy = q.popleft()
                pts.append((cx, cy))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = cx + dx, cy + dy
                    if 0 <= nx < w and 0 <= ny < h and white[ny, nx] and not seen[ny][nx]:
                        seen[ny][nx] = True
                        q.append((nx, ny))
            # donor marks each start with a single pure-white pixel
            out.append([round(sum(p[0] for p in pts) / len(pts) / w, 5),
                        round(sum(p[1] for p in pts) / len(pts) / h, 5)])
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="installed game folder (default: $COSSACKS3_DIR or C:/Games/Cossacks 3)")
    a = ap.parse_args()
    donor = donor_for(a.game)

    import numpy as np

    OUT.mkdir(parents=True, exist_ok=True)
    types: dict[str, dict] = {}
    for folder in ("land", "nowater2", "mediterranean", "peninsulas",
                   "islands", "continents", "continent"):
        src = donor / folder
        files = sorted(src.glob("*pl*_gauss.tga"))
        if not files:
            print(f"skip {folder}: no gauss masks")
            continue
        step = max(1, len(files) // PER_TYPE)
        chosen = files[::step][:PER_TYPE]
        # "nowater2" is a separate donor terrain type (flat land, zero water);
        # do not merge it into "land", which has real lakes.
        key = folder
        entry = types.setdefault(key, {"masks": []})
        for src_file in chosen:
            im = Image.open(src_file).convert("RGB")
            rgb = np.asarray(im)
            rel = f"{folder}/{src_file.stem}.png"
            dst = OUT / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            im.save(dst, optimize=True)
            water = float((rgb[:, :, 2] > 58).mean())
            entry["masks"].append({
                "file": rel.replace("\\", "/"),
                "starts": start_dots(rgb),
                "water": round(water, 4),
            })
        print(f"{key}: {len(entry['masks'])} masks")
    data = {
        "version": 1,
        "source": str(donor).replace("\\", "/"),
        "note": "RGB terrain masks: R=relief, G=forest/stone, B=water, white=start",
        "types": types,
    }
    MANIFEST.write_text(json.dumps(data, indent=1), encoding="utf-8")
    total = sum(len(t["masks"]) for t in types.values())
    size = sum(f.stat().st_size for f in OUT.rglob("*.png"))
    print(f"manifest: {MANIFEST} | masks={total} | png bytes={size}")


if __name__ == "__main__":
    main()
