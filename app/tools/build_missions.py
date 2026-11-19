#!/usr/bin/env python3
"""Build app/assets/missions.json from the original's own config files.

Reads (when present, all inside C:\\Games\\Cossacks 3 by default):
  data/game/var/campaigns.cfg    - campaign -> missions (tut + nations)
  data/game/var/battles.cfg      - historical battles battle1..8
  data/game/var/generator.cfg    - random-map terrain types
  data/game/var/startingsettings.cfg - start options (comments gc_mapsettings_*)

Output: assets/missions.json with nations, campaigns, battles, map_types,
start_options. The game menu (scripts/menu.gd) reads this file; if it is
missing the menu falls back to built-in defaults.

Usage:
  python tools/build_missions.py --game "C:\\Games\\Cossacks 3" --out assets/missions.json
"""
import argparse
import json
import os
import re

NATIONS = [
    ("aus", "Austria"), ("fra", "France"), ("eng", "England"),
    ("spa", "Spain"), ("rus", "Russia"), ("ukr", "Ukraine"),
    ("pol", "Poland"), ("swe", "Sweden"), ("pru", "Prussia"),
    ("ven", "Venice"), ("tur", "Turkey"), ("alg", "Algeria"),
    ("net", "Netherlands"), ("den", "Denmark"), ("por", "Portugal"),
    ("pie", "Piedmont"), ("sax", "Saxony"), ("bav", "Bavaria"),
    ("hun", "Hungary"), ("swi", "Switzerland"),
]

MAP_TYPES = [
    ("land", "Land", "Open plains, no sea (generator TerrainTypes 0)"),
    ("mediterranean", "Mediterranean", "Sea in the middle (generator 1)"),
    ("peninsulas", "Peninsulas", "Long coastlines (generator 2)"),
    ("islands", "Islands", "Scattered islands (generator 3)"),
    ("continents", "Continents", "Two large landmasses (generator 4)"),
    ("continent", "Continent", "One large landmass (generator 5)"),
]

START_OPTIONS = [
    ("default", "Town + peasants", "Town hall and 8 peasants, empty stores"),
    ("armysmall", "Small army", "Town + small ready army, 1000 food"),
    ("armymedium", "Medium army", "Town + medium ready army"),
    ("armylarge", "Large army", "Town + large ready army"),
    ("towers", "Towers", "Town + defensive towers"),
    ("cannons", "Cannons", "Town + artillery park"),
]


def _read(path):
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()
    except OSError:
        return ""


def parse_campaigns(txt):
    """Pull Name = xxx lines grouped per campaign block (best effort)."""
    out = []
    # split on 'Name = ' occurrences; keep order
    names = re.findall(r"Name\s*=\s*(\w+)", txt)
    # campaigns.cfg groups: first name in each [*] struct at campaign level,
    # then mission names. Heuristic: names ending in 'cam'/'cam3' are campaigns.
    cur = None
    for n in names:
        if n.endswith("cam") or n.endswith("cam3"):
            if cur:
                out.append(cur)
            cur = {"id": n, "missions": []}
        elif cur is not None and re.match(r"^(tut|aus|eng|fra|rus|ukr|bon|net|sce|scemis|netmis).*", n):
            cur["missions"].append(n)
    if cur:
        out.append(cur)
    # campaigns.cfg repeats each campaign header (Enabled/Visible/Locale
    # blocks list the Name twice): merge duplicates, keep mission order.
    merged = []
    seen = {}
    for c in out:
        if c["id"] in seen:
            for m in c["missions"]:
                if m not in seen[c["id"]]["missions"]:
                    seen[c["id"]]["missions"].append(m)
        else:
            seen[c["id"]] = c
            merged.append(c)
    return merged


def parse_battles(txt):
    names = re.findall(r"Name\s*=\s*(battle\d+)", txt)
    seen = []
    for n in names:
        if n not in seen:
            seen.append(n)
    return [{"id": n, "name": "Historical battle %s" % n.replace("battle", ""),
             "max_players": 8} for n in seen] or \
        [{"id": "battle%d" % i, "name": "Historical battle %d" % i,
          "max_players": 8} for i in range(1, 9)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", default=r"C:\Games\Cossacks 3")
    ap.add_argument("--out", default=os.path.join("assets", "missions.json"))
    args = ap.parse_args()

    base = args.game
    campaigns_txt = _read(os.path.join(base, "data", "game", "var", "campaigns.cfg"))
    battles_txt = _read(os.path.join(base, "data", "game", "var", "battles.cfg"))
    gen_txt = _read(os.path.join(base, "data", "game", "var", "generator.cfg"))

    campaigns = parse_campaigns(campaigns_txt) if campaigns_txt else []
    if not campaigns:
        campaigns = [
            {"id": "tutcam", "missions": ["tutmis1", "tutmis2"]},
            {"id": "auscam", "missions": ["ausmis1", "ausmis2", "ausmis3", "ausmis4", "ausmis5"]},
            {"id": "engcam", "missions": ["engmis1", "engmis2", "engmis3", "engmis4", "engmis5"]},
            {"id": "fracam", "missions": ["framis1", "framis2", "framis3", "framis4", "framis5"]},
            {"id": "ruscam", "missions": ["rusmis1", "rusmis2", "rusmis3", "rusmis4", "rusmis5"]},
            {"id": "ukrcam", "missions": ["ukrmis1", "ukrmis2", "ukrmis3", "ukrmis4", "ukrmis5"]},
        ]
    battles = parse_battles(battles_txt) if battles_txt else \
        [{"id": "battle%d" % i, "name": "Historical battle %d" % i,
          "max_players": 8} for i in range(1, 9)]

    data = {
        "version": 1,
        "sources": {
            "campaigns": "data/game/var/campaigns.cfg",
            "battles": "data/game/var/battles.cfg",
            "map_types": "data/game/var/generator.cfg TerrainTypes",
            "start_options": "data/game/var/startingsettings.cfg comments",
            "nations": "data/scripts/lib/country.script _country_GetSIDByID",
        },
        "nations": [{"id": sid, "name": name} for sid, name in NATIONS],
        "map_types": [{"id": i, "name": n, "descr": d} for i, n, d in MAP_TYPES],
        "start_options": [{"id": i, "name": n, "descr": d} for i, n, d in START_OPTIONS],
        "campaigns": campaigns,
        "battles": battles,
        "generator_present": bool(gen_txt),
    }
    out = args.out
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    print("wrote %s (%d campaigns, %d battles)" % (out, len(campaigns), len(battles)))


if __name__ == "__main__":
    main()
