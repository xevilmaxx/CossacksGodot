#!/usr/bin/env python3
"""Export donor pattern masks + generator.cfg family weights for the Godot port.

Reads the installed game (C:\\Games\\Cossacks 3) only; writes a compact JSON
into app/assets/terrain/patterns/donor_patterns.json. The Godot engine
(scripts/pattern_gen.gd) uses these masks exactly like the donor's
_misc_CheckStandPattern: footprint test against a global occupancy grid.
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import donor_gen as dg

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(APP, "assets", "terrain", "patterns")
OUT = os.path.join(OUT_DIR, "donor_patterns.json")

# Only the families the generator actually stamps (GUIDE4 L3 / dogenerate.inc).
WANTED = [
    "mng", "mni", "mnc", "desert_mng", "desert_mni", "desert_mnc",
    "tiles", "desert_tiles",
    "stones", "stoneforests", "desert_stones", "desert_stoneforests",
    "hills_dark", "hills_light", "desert_plateau", "desert_mountains",
    "decor", "decor_big", "dcr1", "dcr2", "dcr3",
    "forests_pinefir_big", "forests_pinefir_medium", "forests_pinefir_small",
    "forests_spruce_big", "forests_spruce_medium",
    "forests_pinedrygreen_small", "forests_pine_small", "forests_pine_medium",
    "forests_pine_big", "forests_pine_big_2",
    "forests_mixed_big", "forests_mixed_medium",
    "forests_leaf_big", "forests_leaf_medium", "forests_leaf_small",
    "desert_forests_big", "desert_forests_medium", "desert_forests_small",
    "desert_forests_unique",
]


def main():
    lib = dg.library()
    families = {k: v for k, v in lib.families.items() if k in WANTED}
    needed = set()
    for pats in families.values():
        for name, _w in pats:
            if name in lib.masks:
                needed.add(name)
    patterns = {}
    for name in sorted(needed):
        w, h, mask = lib.masks[name]
        cells = []
        for y in range(h):
            for x in range(w):
                if mask[y][x]:
                    cells.append([x - w // 2, y - h // 2])
        patterns[name] = {"w": w, "h": h, "cells": cells}
    out = {
        "version": 1,
        "source": "C:/Games/Cossacks 3/data/pattern/*.pattern + data/game/var/generator.cfg",
        "note": "cells are centred (dx,dy) donor-map-cell offsets; the Godot port scales them by map_tiles/160",
        "donor_units": dg.DONOR_UNITS,
        "families": families,
        "patterns": patterns,
    }
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(out, f, separators=(",", ":"))
    print("families=%d patterns=%d cells=%d -> %s (%.1f KB)" % (
        len(families), len(patterns), sum(len(p["cells"]) for p in patterns.values()),
        OUT, os.path.getsize(OUT) / 1024.0))


if __name__ == "__main__":
    main()
