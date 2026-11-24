#!/usr/bin/env python3
"""Add per-action ink bbox to assets/models/anim/index.json.
Run: python app/tools/sheet_metrics.py --dir app/assets/models/anim
For every <key>_<action>.png referenced by index.json: union of alpha>8 bboxes
over ALL cells (8 dirs x n frames). Writes actions[action]["bbox"]=[x0,y0,x1,y1]
in CELL-LOCAL pixels, plus ["fig_h"]=(y1-y0)/cell and ["foot"]=y1/cell and
["cx"]=(x0+x1)/2/cell. Idempotent; skips sheets already measured unless --force.
"""
import argparse, json, os
from pathlib import Path
from PIL import Image

# Nation-first layout: sheets live under <nation>/<kind> or common/<kind>,
# with the old category folders and the flat anim root as fallbacks. index.json
# is always read/written at its old path under --dir.
NATIONS = ("aus", "eng", "pol", "rus", "spa", "tur", "ukr", "bav", "den",
           "fra", "hun", "net", "pie", "por", "pru", "sax", "swe", "swi",
           "ven", "alg", "sco")
ANIM_KINDS = ("buildings", "units", "naval")
LEGACY_ANIM_SUBDIRS = ("buildings", "land_units", "naval")
ANIM = Path(__file__).resolve().parents[1] / "assets" / "models" / "anim"

def nation_of(name):
    """Nation prefix of a baked sheet name, or "" for shared art.

    Mirrors world.gd: the `_` at index 3 keeps "spakh_*" in common.
    """
    stem = name[:-4] if name.endswith(".png") else name
    if len(stem) < 4 or stem[3] != "_":
        return ""
    p = stem[:3].lower()
    return p if p in NATIONS else ""

def resolve_anim_png(name, base=None):
    """First existing path for one anim PNG; nation-first dirs before root.
    `base` is the anim root (--dir); defaults to the path derived from __file__.
    """
    root = Path(base) if base is not None else ANIM
    nat = nation_of(name)
    dirs = []
    for kind in ANIM_KINDS:
        if nat:
            dirs.append(root / nat / kind)
        dirs.append(root / "common" / kind)
    for sub in LEGACY_ANIM_SUBDIRS:
        dirs.append(root / sub)
    for d in dirs:
        p = d / name
        if p.is_file():
            return str(p)
    return str(root / name)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--normalize", action="store_true",
                    help="use the idle action's body metrics for every action")
    a = ap.parse_args()
    # Index moved to land_units/. Prefer the new path; an explicit --dir at a
    # different index root (e.g. naval_units/) still resolves via the legacy
    # candidate, and the new path is the default when neither file exists yet.
    ip = os.path.join(a.dir, "land_units", "index.json")
    if not os.path.isfile(ip):
        legacy_ip = os.path.join(a.dir, "index.json")
        if os.path.isfile(legacy_ip):
            ip = legacy_ip
    if os.path.dirname(ip):
        os.makedirs(os.path.dirname(ip), exist_ok=True)
    idx = json.load(open(ip, encoding="utf-8"))
    changed = 0
    for key, info in idx.items():
        cell = int(info["cell"])
        for act, ad in info.get("actions", {}).items():
            # ax/ay ground anchors (from the baker's origin projection) are
            # authoritative: never overwrite them here. bbox/fig_h/foot/cx
            # remain as fallback info for old clients and clip detection.
            if "bbox" in ad and not a.force:
                continue
            p = resolve_anim_png("%s_%s.png" % (key, act), a.dir)
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
            # Clip alarm: ink touching a cell edge means the baker's ortho
            # was too tight and the pose is cut off in-game.
            if x0 <= 0 or y0 <= 0 or x1 >= cell or y1 >= cell:
                print("CLIP %s_%s union %s (ortho %.3f too tight)" % (
                    key, act, ad["bbox"], float(ad.get("ortho", 0.0))))
            changed += 1
    if a.normalize:
        for key, info in idx.items():
            acts = info.get("actions", {})
            ref = acts.get("idle") or acts.get("walk")
            if not ref or "fig_h" not in ref:
                continue
            for act, ad in acts.items():
                if "fig_h" not in ad:
                    continue
                ad["fig_h"] = ref["fig_h"]
                ad["foot"] = ref["foot"]
                ad["cx"] = ref["cx"]
    json.dump(idx, open(ip, "w", encoding="utf-8"), indent=1)
    print("measured", changed, "action sheets")

main()
