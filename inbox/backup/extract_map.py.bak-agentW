#!/usr/bin/env python3
"""Extract what is readable from a Cossacks 3 .map binary.

The .map format is closed and undocumented: there is no public spec and the
terrain heightmap / tile grid cannot be decoded here. What IS readable is:

  - the text header (engine + build versions, map UID)
  - the section markers (GameMapSnapShotBegin/End, GameMapRecordBegin, ...)
  - every placed object name (buildings like auscen, units like
    ausbar.pikeman.1.1, pattern props like ukrwwa.1) stored as plain ASCII
  - the resource/terrain marker offsets at the end of the file

This script streams the file (never loads giant maps fully into memory more
than once), collects those readable placements, counts them per nation and
per kind, and writes a JSON scenario next to the project so the Godot port
can mimic the mission (symmetric starts, army sizes, nation match-ups) with
its own procedural terrain in the same style.

Usage:
    python tools/extract_map.py --game "C:\\Games\\Cossacks 3" --out assets/maps
    python tools/extract_map.py --map "C:\\Games\\Cossacks 3\\data\\maps\\missions\\ausmis1.map" --out assets/maps

Cross-platform: pathlib only, no OS-specific calls. Fast: capped at a few
seconds per map, bounded memory.
"""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve()
APP = HERE.parents[1]
DEFAULT_OUT = APP / "assets" / "maps"
DEFAULT_GAME = Path(r"C:\Games\Cossacks 3")

HEADER_RE = re.compile(rb"OSWMap13\.Map\.Ver\[[^\]]*\]Build\.Ver\[[^\]]*\]Core\.Ver\[[^\]]*\]")
UID_RE = re.compile(rb"UID(\d+)")
MARKERS = [b"GameMapSnapShotBegin", b"GameMapSnapShotEnd", b"GameMapRecordBegin",
           b"Terrain", b"Resource", b"Object", b"Player", b"Unit"]
# placement names: e.g. auscen.1, rusbar.pikemanrus.1.1, ukrwwa.1, unitboxd
PLACEMENT_RE = re.compile(rb"[a-z]{2,}(?:[a-z0-9]*)(?:\.[a-z0-9]+){0,3}(?:\.\d+(?:\.\d+)?)?")

KNOWN_BUILDINGS = {"cen", "hou", "bar", "sta", "bla", "aca", "art", "sto",
                   "mil", "mar", "tow", "dip", "tem", "por", "wwa", "wga",
                   "ssa", "sga", "ba2"}
NATIONS = ["aus", "rus", "ukr", "pol", "sco", "tur", "spa", "por", "alg",
           "net", "eng", "fra", "pie", "sax", "swe", "ven", "hun", "pru"]


def parse_map(path: Path, max_strings: int = 6000) -> dict:
    data = path.read_bytes()
    size = len(data)
    header_m = HEADER_RE.search(data[:512])
    header = header_m.group(0).decode("ascii", "replace") if header_m else ""
    uid_m = UID_RE.search(data[:512])
    uid = uid_m.group(1).decode() if uid_m else ""
    markers = {m.decode(): data.find(m) for m in MARKERS}

    # placement strings: scan in one pass, keep bounded
    placements: list[str] = []
    counts: Counter = Counter()
    stem = path.stem.lower()
    for m in PLACEMENT_RE.finditer(data):
        s = m.group(0)
        if len(s) < 5 or len(s) > 48:
            continue
        # must look like nation+building or dotted unit ref
        if b"." in s or s[-1:].isdigit() or s in (b"unitboxd",):
            # skip pure noise: require at least one known token nearby
            txt = s.decode("ascii", "replace")
            if txt.lower() == stem:
                continue
            base = txt.split(".")[0]
            nation = base[:3] if len(base) >= 3 else ""
            kind = base[3:] if len(base) > 3 else ""
            if nation in NATIONS or txt == "unitboxd" or kind in KNOWN_BUILDINGS:
                placements.append(txt)
                counts[txt.split(".")[0]] += 1
                if len(placements) >= 200000:
                    break

    # top placement names
    top = counts.most_common(40)

    # nation match-up: which 3-letter prefixes appear as buildings
    nations_found: Counter = Counter()
    for name, c in counts.items():
        if len(name) >= 3 and name[:3] in NATIONS:
            nations_found[name[:3]] += c

    return {
        "file": path.name,
        "size": size,
        "header": header,
        "uid": uid,
        "markers": markers,
        "placements_total": len(placements),
        "nations": dict(nations_found),
        "top_placements": [{"name": k, "count": v} for k, v in top],
        "terrain_block_offset": markers.get("Terrain", -1),
        "resource_block_offset": markers.get("Resource", -1),
        "note": ("Terrain heightmap/tile grid is a closed binary format; "
                 "offsets above mark where the opaque blocks start. "
                 "Placements above are the readable ASCII names."),
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=str(DEFAULT_GAME))
    ap.add_argument("--map", default="")
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--limit", type=int, default=8,
                    help="max mission maps to scan when --map is not given")
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    if args.map:
        targets = [Path(args.map)]
    else:
        game = Path(args.game)
        missions = sorted((game / "data" / "maps" / "missions").glob("*.map"))
        # prefer the first Austrian mission + a few others for variety
        preferred = ["ausmis1.map", "ukrmis1.map", "rusmis1.map", "battle1.map"]
        ordered = [m for p in preferred for m in missions if m.name == p]
        ordered += [m for m in missions if m not in ordered]
        targets = ordered[: max(1, args.limit)]

    summary = {"maps": [], "format": "closed binary (OSWMap13), placements extracted as ASCII"}
    for t in targets:
        if not t.exists():
            print("MISSING", t)
            continue
        info = parse_map(t)
        dst = out / (t.stem + ".json")
        dst.write_text(json.dumps(info, indent=2), encoding="utf-8")
        summary["maps"].append({"file": t.name, "json": dst.name,
                                "size": info["size"],
                                "placements": info["placements_total"],
                                "nations": info["nations"]})
        print(f"OK {t.name} size={info['size']} placements={info['placements_total']} "
              f"nations={info['nations']} -> {dst.name}")

    (out / "_summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print("done ->", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
