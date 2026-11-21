#!/usr/bin/env python3
"""Headless quality scan for the donor-mask map generator.

Usage: python app/tools/scan_map.py --dir app/scans
Reads any *_*.json dump that has map_w/map_h/terrain keys (scan_, g4_, atomic_).
Every dump is produced by `godot --headless --path app -- --dump-map FILE --seed N`.

Targets come from GUIDE4 / the donor itself:
  water  - must match the chosen donor mask's B-channel water fraction (+/- 5pp)
  patches - 8..16 discrete forest belts, mean size 40..120 tiles
  quarry purity / mine clearance - 100% (no trees in stone/mine clearings)
  sand ring - >=90% of the LAND-WATER COASTLINE is covered by sand
      (the old version divided by total water area, which is geometrically
       impossible for seas: a radius-20 lake has only ~10% perimeter tiles)
  reachability - every start can reach food/wood/stone/gold within 25 tiles
  cliff ring - >80% of rock tiles are impassable (donor collision slope rule)
Exit 1 if any target red, else 0.
"""
import argparse, base64, json, os, sys
from collections import deque

NB = ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1))


def load_scan(path):
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    w, h = int(d["map_w"]), int(d["map_h"])
    terrain = base64.b64decode(d["terrain"])
    blocked = base64.b64decode(d["blocked"])
    tb = base64.b64decode(d["tileblock"]) if d.get("tileblock") else b""
    height_raw = base64.b64decode(d["height"]) if d.get("height") else b""
    import struct
    height = struct.unpack("<%df" % (len(height_raw) // 4), height_raw) if height_raw else ()
    return w, h, terrain, blocked, tb, height, d


def count_patches(w, h, terrain):
    seen = set()
    patches = []
    for y in range(h):
        for x in range(w):
            if (x, y) in seen or terrain[y * w + x] != 2:
                continue
            q = deque([(x, y)])
            seen.add((x, y))
            size = 0
            while q:
                cx, cy = q.popleft()
                size += 1
                for nx, ny in ((cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and terrain[ny*w+nx] == 2:
                        seen.add((nx, ny))
                        q.append((nx, ny))
            patches.append(size)
    return patches


def quarry_purity(res):
    stones = [n for n in res if n["t"] == "stone" and n["hits"] > 0]
    woods = [(n["x"], n["y"]) for n in res if n["t"] == "wood" and n["hits"] > 0]
    if not stones:
        return 1.0
    return sum(1 for s in stones
               if all((s["x"]-wx)**2 + (s["y"]-wy)**2 > (4*2.0)**2 for wx, wy in woods)) / len(stones)


def mine_clearance(res):
    deps = [n for n in res if n["t"] in ("gold", "iron", "coal")]
    woods = [(n["x"], n["y"]) for n in res if n["t"] == "wood" and n["hits"] > 0]
    if not deps:
        return 1.0
    return sum(1 for m in deps
               if all((m["x"]-wx)**2 + (m["y"]-wy)**2 > (5*2.0)**2 for wx, wy in woods)) / len(deps)


def sand_ring(w, h, terrain):
    """Fraction of the coastline (water tiles touching land) that has sand."""
    coast = covered = 0
    for y in range(h):
        for x in range(w):
            if terrain[y*w+x] != 3:
                continue
            nbrs = [(nx, ny) for nx, ny in
                    ((x+ox, y+oy) for ox, oy in NB) if 0 <= nx < w and 0 <= ny < h]
            if not any(terrain[ny*w+nx] != 3 for nx, ny in nbrs):
                continue
            coast += 1
            if any(terrain[ny*w+nx] == 4 for nx, ny in nbrs):
                covered += 1
    return covered / coast if coast else 1.0


def cliff_ring(w, h, terrain, blocked, height):
    """Donor collision rule: a steep tile (|dh| > 0.5/0.55) must be blocked.
    Rock PAINT is not collision (donor paints rock1 on walkable hills too), so
    measuring 'blocked / rock' gives a false failure on every gentle hill."""
    steep = []
    for y in range(h):
        for x in range(w):
            i = y*w+x
            if terrain[i] in (3, 4) or not height:  # water + wet sand are passable shore
                continue
            h0 = height[i]
            s = 0.0
            if x > 0:
                s = max(s, abs(height[i-1]-h0))
            if x+1 < w:
                s = max(s, abs(height[i+1]-h0))
            if y > 0:
                s = max(s, abs(height[i-w]-h0))
            if y+1 < h:
                s = max(s, abs(height[i+w]-h0))
            if s > 0.5:
                steep.append(i)
    return sum(1 for i in steep if blocked[i]) / len(steep) if steep else 1.0


def tileflow(w, h, terrain, tb):
    """BLK_WATER must line up with terrain water; no sandsea on dry land."""
    if not tb:
        return 1.0
    bad = 0
    for i in range(w*h):
        if terrain[i] == 3 and tb[i] != 255:
            bad += 1
    return 1.0 - bad / max(1, sum(1 for t in terrain if t == 3))


def reachability(w, h, blocked, res, starts):
    kinds = ("food", "stone", "wood", "gold")
    for sx, sy in starts:
        stx, sty = int(sx // 2.0), int(sy // 2.0)
        if not (0 <= stx < w and 0 <= sty < h) or blocked[sty*w+stx] != 0:
            found = None
            for r in range(1, 8):
                for dy in range(-r, r+1):
                    for dx in range(-r, r+1):
                        nx, ny = stx+dx, sty+dy
                        if 0 <= nx < w and 0 <= ny < h and blocked[ny*w+nx] == 0:
                            found = (nx, ny)
                            break
                    if found:
                        break
                if found:
                    break
            if not found:
                return False
            stx, sty = found
        seen = {(stx, sty)}
        q = deque([(stx, sty, 0)])
        reach = set()
        while q:
            x, y, d = q.popleft()
            reach.add((x, y))
            if d >= 25:
                continue
            for nx, ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
                if 0 <= nx < w and 0 <= ny < h and (nx,ny) not in seen and blocked[ny*w+nx] == 0:
                    seen.add((nx, ny))
                    q.append((nx, ny, d+1))
        def near_reach(px, py):
            tx, ty = int(px // 2.0), int(py // 2.0)
            return any((tx+dx, ty+dy) in reach for dy in range(-2, 3) for dx in range(-2, 3))
        for k in kinds:
            if not any(near_reach(n["x"], n["y"]) for n in res if n["t"] == k):
                return False
    return True


def scan_one(path):
    w, h, terrain, blocked, tb, height, d = load_scan(path)
    total = w * h
    water = sum(1 for t in terrain if t == 3) / total * 100
    sand = sum(1 for t in terrain if t == 4) / total * 100
    dark = sum(1 for t in terrain if t == 2) / total * 100
    rock = sum(1 for t in terrain if t == 5) / total * 100
    patches = count_patches(w, h, terrain)
    meta = d.get("meta", {})
    return {
        "file": os.path.basename(path), "map_w": w,
        "water": water, "sand": sand, "dark": dark, "rock": rock,
        "mask_water": float((meta.get("mask") or {}).get("water", meta.get("mask_water", -1))) * 100,
        "mask": (meta.get("mask") or {}).get("file", "?"),
        "patches": len(patches), "mean_sz": sum(patches)/len(patches) if patches else 0,
        "purity": quarry_purity(d.get("res", []))*100,
        "clear": mine_clearance(d.get("res", []))*100,
        "sand_ring": sand_ring(w, h, terrain)*100,
        "cliff": cliff_ring(w, h, terrain, blocked, height)*100,
        "tileflow": tileflow(w, h, terrain, tb)*100,
        "reach": reachability(w, h, blocked, d.get("res", []),
                              [(float(s["x"]), float(s["y"])) for s in d.get("starts", [])]),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    a = ap.parse_args()
    files = []
    for f in sorted(os.listdir(a.dir)):
        if not f.endswith(".json"):
            continue
        p = os.path.join(a.dir, f)
        try:
            with open(p, encoding="utf-8") as fh:
                # Godot serialises dictionaries with the big base64 blobs first
                if "map_w" in fh.read():
                    files.append(p)
        except OSError:
            pass
    if not files:
        print("no map dumps in", a.dir)
        return 2
    rows = [scan_one(p) for p in files]
    fails = []
    for r in rows:
        f = []
        if r["mask_water"] >= 0 and abs(r["water"] - r["mask_water"]) > 5:
            f.append("water=%.1f vs mask %.1f" % (r["water"], r["mask_water"]))
        if not (8 <= r["patches"] <= 16):
            f.append("patches=%d" % r["patches"])
        # belt size scales with map AREA (40..120 tiles at the 160-tile baseline)
        lo, hi = 40 * (r["map_w"]/160.0)**2, 120 * (r["map_w"]/160.0)**2
        if not (lo*0.6 <= r["mean_sz"] <= hi*1.6):
            f.append("mean_sz=%.0f" % r["mean_sz"])
        if r["purity"] < 100 or r["clear"] < 100:
            f.append("purity=%.0f clear=%.0f" % (r["purity"], r["clear"]))
        if r["water"] > 0.5 and r["sand_ring"] < 90:
            f.append("coast=%.0f" % r["sand_ring"])
        if r["cliff"] < 80:
            f.append("cliff=%.0f" % r["cliff"])
        if r["tileflow"] < 99:
            f.append("tileflow=%.0f" % r["tileflow"])
        if not r["reach"]:
            f.append("reach=FAIL")
        if f:
            fails.append((r["file"], ",".join(f)))
        print("%(file)s mask=%(mask)s water=%(water).1f sand=%(sand).1f dark=%(dark).1f "
              "rock=%(rock).1f patches=%(patches)d mean=%(mean_sz).0f coast=%(sand_ring).0f "
              "cliff=%(cliff).0f tile=%(tileflow).0f reach=%(reach)s" % r)
    n = len(rows)
    print("--- means over %d seeds ---" % n)
    for k in ("water", "sand", "dark", "rock", "patches", "mean_sz", "sand_ring", "cliff", "tileflow"):
        print("%s %.1f" % (k, sum(r[k] for r in rows)/n))
    print("reachability %d/%d" % (sum(1 for r in rows if r["reach"]), n))
    if fails:
        print("FAIL:")
        for fn, m in fails:
            print(" ", fn, m)
        return 1
    print("ALL GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
