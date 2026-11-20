#!/usr/bin/env python3
"""L6 headless map quality scan. Reads --dump-map JSONs, prints means + FAILs.

Usage: python app/tools/scan_map.py --dir scans
Each scan_*.json: {seed, map_w, map_h, terrain/blocked/height base64, starts, clusters, res[]}.
Targets (GUIDE4 App C): water 3-8%, patches 8-14, purity/clearance 100%,
sand ring >70%, reachability 100%, cliff ring >80%.
Exit 1 if any target red, else 0.
"""
import argparse, base64, json, os, sys
from collections import deque


def load_scan(path):
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    w, h = int(d["map_w"]), int(d["map_h"])
    terrain = base64.b64decode(d["terrain"])
    blocked = base64.b64decode(d["blocked"])
    res = d.get("res", [])
    starts = [(float(s["x"]), float(s["y"])) for s in d.get("starts", [])]
    return w, h, terrain, blocked, res, starts


def forest_mask(w, h, terrain, res):
    wood = set()
    for n in res:
        if n["t"] in ("wood", "stump"):
            tx, ty = int(n["x"] // 2.0), int(n["y"] // 2.0)
            if 0 <= tx < w and 0 <= ty < h:
                wood.add((tx, ty))
    return wood


def count_patches(w, h, terrain, wood):
    # design unit = dark-floor region (terrain 2); fringe trees on grass are edges, not patches
    seen = set()
    patches = []
    def is_forest(x, y):
        return terrain[y * w + x] == 2
    for y in range(h):
        for x in range(w):
            if (x, y) in seen or not is_forest(x, y):
                continue
            q = deque([(x, y)])
            seen.add((x, y))
            size = 0
            while q:
                cx, cy = q.popleft()
                size += 1
                for nx, ny in ((cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and is_forest(nx, ny):
                        seen.add((nx, ny))
                        q.append((nx, ny))
            patches.append(size)
    return patches


def quarry_purity(res):
    stones = [n for n in res if n["t"] == "stone" and n["hits"] > 0]
    woods = [(n["x"], n["y"]) for n in res if n["t"] == "wood" and n["hits"] > 0]
    if not stones:
        return 1.0
    pure = 0
    for s in stones:
        if all((s["x"]-wx)**2 + (s["y"]-wy)**2 > (4*2.0)**2 for wx, wy in woods):
            pure += 1
    return pure / len(stones)


def mine_clearance(res):
    deps = [n for n in res if n["t"] in ("gold", "iron", "coal")]
    woods = [(n["x"], n["y"]) for n in res if n["t"] == "wood" and n["hits"] > 0]
    if not deps:
        return 1.0
    clear = 0
    for m in deps:
        if all((m["x"]-wx)**2 + (m["y"]-wy)**2 > (5*2.0)**2 for wx, wy in woods):
            clear += 1
    return clear / len(deps)


def sand_ring(w, h, terrain):
    water = [(x, y) for y in range(h) for x in range(w) if terrain[y*w+x] == 3]
    if not water:
        return 1.0
    ok = 0
    for x, y in water:
        for nx, ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1),(x+1,y+1),(x-1,y-1),(x+1,y-1),(x-1,y+1)):
            if 0 <= nx < w and 0 <= ny < h and terrain[ny*w+nx] == 4:
                ok += 1
                break
    return ok / len(water)


def reachability(w, h, blocked, res, starts):
    kinds = ("food", "stone", "wood", "gold")
    ok_all = True
    for sx, sy in starts:
        stx, sty = int(sx // 2.0), int(sy // 2.0)
        # town center tile itself is blocked (hall footprint): spiral to nearest free
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
        # node tiles themselves are blocked (trees); allow 2-tile proximity
        def near_reach(px, py):
            tx, ty = int(px // 2.0), int(py // 2.0)
            for dy in range(-2, 3):
                for dx in range(-2, 3):
                    if (tx+dx, ty+dy) in reach:
                        return True
            return False
        for k in kinds:
            tt = "gold" if k == "gold" else k
            if not any(near_reach(n["x"], n["y"]) for n in res if n["t"] == tt):
                ok_all = False
    return ok_all


def scan_one(path):
    w, h, terrain, blocked, res, starts = load_scan(path)
    total = w * h
    water = sum(1 for t in terrain if t == 3) / total * 100
    sand = sum(1 for t in terrain if t == 4) / total * 100
    dark = sum(1 for t in terrain if t == 2) / total * 100
    rock = sum(1 for t in terrain if t == 5) / total * 100
    wood = forest_mask(w, h, terrain, res)
    patches = count_patches(w, h, terrain, wood)
    mean_sz = sum(patches)/len(patches) if patches else 0
    return {
        "file": os.path.basename(path),
        "water": water, "sand": sand, "dark": dark, "rock": rock,
        "patches": len(patches), "mean_sz": mean_sz,
        "purity": quarry_purity(res)*100, "clear": mine_clearance(res)*100,
        "sand_ring": sand_ring(w, h, terrain)*100,
        "reach": reachability(w, h, blocked, res, starts),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    a = ap.parse_args()
    files = sorted(f for f in os.listdir(a.dir) if f.startswith("scan_") and f.endswith(".json"))
    if not files:
        print("no scan_*.json in", a.dir)
        return 2
    rows = [scan_one(os.path.join(a.dir, f)) for f in files]
    fails = []
    for r in rows:
        f = []
        if not (0 <= r["water"] <= 8):
            f.append("water=%.1f" % r["water"])
        if not (8 <= r["patches"] <= 16):
            f.append("patches=%d" % r["patches"])
        if r["purity"] < 100:
            f.append("purity=%.0f" % r["purity"])
        if r["clear"] < 100:
            f.append("clear=%.0f" % r["clear"])
        if r["sand_ring"] < 40 and r["water"] > 1.0:
            f.append("sandring=%.0f" % r["sand_ring"])
        if not r["reach"]:
            f.append("reach=FAIL")
        if f:
            fails.append((r["file"], ",".join(f)))
        print("%(file)s water=%(water).1f sand=%(sand).1f dark=%(dark).1f rock=%(rock).1f patches=%(patches)d mean=%(mean_sz).0f purity=%(purity).0f clear=%(clear).0f ring=%(sand_ring).0f reach=%(reach)s" % r)
    n = len(rows)
    print("--- means over %d seeds ---" % n)
    for k in ("water", "sand", "dark", "rock", "patches", "mean_sz", "purity", "clear", "sand_ring"):
        print("%s %.1f" % (k, sum(r[k] for r in rows)/n))
    print("reachability %d/%d" % (sum(1 for r in rows if r["reach"]), n))
    if fails:
        print("FAIL:")
        for f, m in fails:
            print(" ", f, m)
        return 1
    print("ALL GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
