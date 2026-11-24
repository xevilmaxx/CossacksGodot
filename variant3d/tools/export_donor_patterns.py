#!/usr/bin/env python3
"""Export donor pattern masks + generator.cfg family weights for the Godot port.

Reads the installed game ($COSSACKS3_DIR or C:/Games/Cossacks 3) only; writes a compact JSON
into app/assets/terrain/patterns/donor_patterns.json. The Godot engine
(scripts/pattern_gen.gd) uses these masks exactly like the donor's
_misc_CheckStandPattern: footprint test against a global occupancy grid.
"""

import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import donor_gen as dg

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(APP, "assets", "terrain", "patterns")
OUT = os.path.join(OUT_DIR, "donor_patterns.json")

# generator.cfg has a handful of pattern names that do not match any .pattern
# filename (TDR-2 claim C4 / ticket T1).  These are the explicit, documented
# case fixes.  Generic numeric/underscore fixes are handled by _candidates()
# below; every candidate is accepted only if a real .pattern file exists, so
# this stays correct when the tool is re-run against a different donor install.
ALIASES = {
    "k_ravine_2": "K_ravine_2",
}


def real_pattern_names():
    """Stems of every .pattern actually present in the donor install."""
    try:
        names = os.listdir(dg.PATTERNS)
    except OSError:
        return set()
    return set(fn[:-8] for fn in names if fn.lower().endswith(".pattern"))


def _candidates(name):
    """Filename candidates for a cfg name, most likely first."""
    out = []
    explicit = ALIASES.get(name)
    if explicit:
        out.append(explicit)
    m = re.match(r"^(.+?)(\d+)$", name)
    if m:
        stem, num = m.group(1), m.group(2)
        # foo12 -> foo_12  (n_desert_frt_big1, desert_plt2)
        out.append(stem + "_" + num)
        # k_pump_1 -> k_pump_01 (zero-padded single digit)
        if len(num) == 1:
            out.append(stem + "0" + num)
            out.append(stem.lstrip("_") + "_0" + num)
        # other zero-pad widths, kept last so exact/underscore wins
        out.append(stem + "_" + num.zfill(3))
    # case-only fixes (k_ravine_2 -> K_ravine_2) also when no digits at end
    if name:
        out.append(name[0].upper() + name[1:])
        out.append(name[0].lower() + name[1:])
    return out


def resolve_name(name, real):
    """Map a cfg pattern name to a real .pattern stem, or None if none exists."""
    if name in real:
        return name
    for cand in _candidates(name):
        if cand in real:
            return cand
    return None


def ensure_mask(lib, name):
    """Load a pattern mask on demand (aliases may name files cfg never lists)."""
    if name not in lib.masks:
        path = os.path.join(dg.PATTERNS, name + ".pattern")
        if os.path.exists(path):
            lib.masks[name] = dg.parse_pattern(path)
    return name in lib.masks

# Only the families the generator actually stamps (GUIDE4 L3 / dogenerate.inc).
WANTED = [
    "mng", "mni", "mnc", "desert_mng", "desert_mni", "desert_mnc",
    "tiles", "desert_tiles",
    "stones", "stoneforests", "desert_stones", "desert_stoneforests",
    "hills_dark", "hills_light", "desert_plateau", "desert_mountains",
    # TDR-1 §3.5 relief families (dogenerate.inc:1757-1765).  Every family
    # below exists as real .pattern files in the donor install; unresolvable
    # cfg names are dropped by main() so the 0-broken-reference invariant holds.
    "mountains", "plateau_big", "plain_huge", "ravine_big",
    "plateau", "plateau_small",
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
    real = real_pattern_names()
    families = {}
    needed = set()
    alias_log = []
    dropped = []
    for fam, pats in lib.families.items():
        if fam not in WANTED:
            continue
        fixed = []
        for name, weight in pats:
            resolved = resolve_name(name, real)
            if resolved is None:
                # No real .pattern file and no alias can rescue it (e.g.
                # desert_mnt_14/15: only _1.._13 exist).  Dropping the entry
                # prevents a silent no-op stamp at pattern_gen.gd:137-138.
                dropped.append((fam, name))
                continue
            if resolved != name:
                alias_log.append((fam, name, resolved))
            if ensure_mask(lib, resolved):
                needed.add(resolved)
            fixed.append([resolved, weight])
        families[fam] = fixed
    if alias_log:
        print("name aliases applied (%d):" % len(alias_log))
        for fam, old, new in alias_log:
            print("  %-24s %s -> %s" % (fam, old, new))
    if dropped:
        print("unresolvable entries dropped (%d):" % len(dropped))
        for fam, name in dropped:
            print("  %-24s %s (no matching .pattern)" % (fam, name))
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
        "source": dg.GAME.replace("\\", "/") + "/data/pattern/*.pattern + data/game/var/generator.cfg",
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
