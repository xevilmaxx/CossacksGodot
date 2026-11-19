#!/usr/bin/env python3
"""Add per-action ink bbox to assets/models/anim/index.json.
Run: python app/tools/sheet_metrics.py --dir app/assets/models/anim
For every <key>_<action>.png referenced by index.json: union of alpha>8 bboxes
over ALL cells (8 dirs x n frames). Writes actions[action]["bbox"]=[x0,y0,x1,y1]
in CELL-LOCAL pixels, plus ["fig_h"]=(y1-y0)/cell and ["foot"]=y1/cell and
["cx"]=(x0+x1)/2/cell. Idempotent; skips sheets already measured unless --force.
"""
import argparse, json, os
from PIL import Image

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    ip = os.path.join(a.dir, "index.json")
    idx = json.load(open(ip, encoding="utf-8"))
    changed = 0
    for key, info in idx.items():
        cell = int(info["cell"])
        for act, ad in info.get("actions", {}).items():
            if "bbox" in ad and not a.force:
                continue
            p = os.path.join(a.dir, "%s_%s.png" % (key, act))
            if not os.path.exists(p):
                continue
            im = Image.open(p).convert("RGBA")
            cols, rows = im.width // cell, im.height // cell
            x0, y0, x1, y1 = cell, cell, 0, 0
            for r in range(rows):
                for c in range(cols):
                    bb = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell)).getbbox()
                    if bb is None:
                        continue
                    x0, y0 = min(x0, bb[0]), min(y0, bb[1])
                    x1, y1 = max(x1, bb[2]), max(y1, bb[3])
            if x1 <= x0 or y1 <= y0:
                continue
            ad["bbox"] = [x0, y0, x1, y1]
            ad["fig_h"] = round((y1 - y0) / float(cell), 4)
            ad["foot"] = round(y1 / float(cell), 4)
            ad["cx"] = round((x0 + x1) / 2.0 / float(cell), 4)
            changed += 1
    json.dump(idx, open(ip, "w", encoding="utf-8"), indent=1)
    print("measured", changed, "action sheets")

main()
