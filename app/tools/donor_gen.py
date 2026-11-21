#!/usr/bin/env python3
"""Donor-faithful random-map generation mechanism (preview engine).

This is NOT an invented blob layout. It reproduces the mechanism read out of
the installed game's own scripts:

  data/scripts/common.inc/generatemap.inc     relief/water from an RGB TGA mask
  data/scripts/common.inc/dogenerate.inc      pattern stamping, start/mine rings
  data/scripts/lib/misc.script:3384           _misc_CheckStandPattern (mask test)
  data/game/var/generator.cfg                 TerrainTypes + Pattern families/Freq
  data/pattern/*.pattern                      int32 w,h + w*h occupancy mask + objects
  data/gen/terrainmasks/*/...png              the real donor masks (already ported)

Pipeline
  1. pick a donor mask, sample R=relief / G=forest / B=water, read start markers
  2. clear gPatternMask; mark the 3 keep-clear ellipses around each start
  3. tiled patterns on a 25-unit grid, 64 random attempts each (SetupTiles)
  4. mines: 3 resource kinds x rounds, random angle, donor ring distances,
     256 attempts each (SetupMines)
  5. start resources: food rects + stone/forest in the cCircle2/cCircle3 rings
  6. forests / stones / hills / decor: weighted family pick from generator.cfg,
     random x/y, 64/128 attempts, footprint tested against gPatternMask
  7. smoothing of the coastline (as mapgen.gd already does)

The pattern MASK bytes are parsed from the real .pattern files; object contents
are synthesised per family (the binary object records are engine-specific).
The same mechanism is what will be implemented in Godot (mapgen.gd + game.gd).
"""

import glob
import json
import math
import os
import random
import struct

from PIL import Image

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TERRAIN = os.path.join(APP, "assets", "terrain")
MASKS = os.path.join(TERRAIN, "masks")
# Portable donor root: $COSSACKS3_DIR overrides the historical Windows default.
GAME = os.path.expanduser(os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3"))
PATTERNS = os.path.join(GAME, "data", "pattern")
GENERATOR_CFG = os.path.join(GAME, "data", "game", "var", "generator.cfg")

# Donor terrain ids used by the preview renderer.
GRASS, DIRT, FLOOR, WATER, SAND, ROCK = range(6)
C_WATER = -1.1
C_PLATEAU = 2.964
C_HILL = C_PLATEAU / 2.25
C_RAVINE = -2.964

# Donor constants (dogenerate.inc:407-414) in donor map units.
CIRCLE1 = (5.0, 7.0)
CIRCLE2 = (12.0, 15.0)
CIRCLE3 = (22.0, 18.0)
MINE_RINGS = ((14.0, 22.0), (32.0, 42.0), (50.0, 62.0))  # rounds 0/1/2
DONOR_UNITS = 160.0   # donor coordinate scale: 1 unit = 2 map cells; map=320 cells


def relief(v):
    if v >= 250.0:
        return C_PLATEAU
    if abs(v - 96.0) <= 12.0:
        return C_HILL
    if abs(v - 48.0) <= 12.0:
        return C_RAVINE
    if v > 0.0:
        return C_PLATEAU * (v / 255.0) * 0.5
    return 0.0


def parse_pattern(path):
    """Return (width, height, mask[row][col]) from a donor .pattern file."""
    with open(path, "rb") as f:
        b = f.read()
    if len(b) < 8:
        return None
    w, h = struct.unpack_from("<ii", b, 0)
    if w <= 0 or h <= 0 or len(b) < 8 + w * h:
        return None
    raw = b[8:8 + w * h]
    mask = [[bool(raw[y * w + x]) for x in range(w)] for y in range(h)]
    return w, h, mask


class PatternLibrary:
    """Reads generator.cfg family weights and loads the real pattern masks."""

    def __init__(self):
        self.families = {}
        self.masks = {}
        self._parse_cfg()
        self._load_masks()

    def _parse_cfg(self):
        if not os.path.exists(GENERATOR_CFG):
            return
        with open(GENERATOR_CFG, encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
        cur = None
        for line in lines:
            s = line.strip()
            if s.startswith("Name = "):
                cur = s[7:].strip()
                self.families.setdefault(cur, [])
            elif s.startswith("Pattern = ") and cur:
                self.families[cur].append([s[10:].strip(), 1.0])
            elif s.startswith("Freq = ") and cur and self.families[cur]:
                try:
                    self.families[cur][-1][1] = float(s[7:].strip())
                except ValueError:
                    pass
        # generator.cfg repeats 'plain_medium' etc.; keep first definition only
        seen = set()
        for k in self.families:
            if k in seen:
                continue
            seen.add(k)

    def _load_masks(self):
        for pats in self.families.values():
            for name, _w in pats:
                if name in self.masks:
                    continue
                p = os.path.join(PATTERNS, name + ".pattern")
                if os.path.exists(p):
                    self.masks[name] = parse_pattern(p)

    def pick(self, family, rng):
        pats = self.families.get(family, [])
        if not pats:
            return None
        total = sum(w for _n, w in pats if w > 0)
        if total <= 0:
            return rng.choice(pats)[0]
        r = rng.random() * total
        for name, w in pats:
            if w <= 0:
                continue
            r -= w
            if r <= 0:
                return name
        return pats[-1][0]

    def scaled_mask(self, name, n, donor_units=DONOR_UNITS):
        """Downsample a donor pattern footprint onto the preview tile grid."""
        key = (name, n)
        if key in self._scaled_cache:
            return self._scaled_cache[key]
        src = self.masks.get(name)
        if not src:
            self._scaled_cache[key] = [(0, 0)]
            return [(0, 0)]
        w, h, mask = src
        s = n / donor_units
        sw, sh = max(1, round(w * s)), max(1, round(h * s))
        cells = []
        for ty in range(sh):
            y0, y1 = int(ty * h / sh), max(int(ty * h / sh) + 1, int((ty + 1) * h / sh))
            for tx in range(sw):
                x0, x1 = int(tx * w / sw), max(int(tx * w / sw) + 1, int((tx + 1) * w / sw))
                if any(mask[y][x] for y in range(y0, min(y1, h))
                       for x in range(x0, min(x1, w))):
                    cells.append((tx - sw // 2, ty - sh // 2))
        if not cells:
            cells = [(0, 0)]
        self._scaled_cache[key] = cells
        return cells

    _scaled_cache = {}


LIB = None


def library():
    global LIB
    if LIB is None:
        LIB = PatternLibrary()
    return LIB


class DonorMap:
    """A donor-mask + stamped-pattern map with the same fields as MapModel."""

    def __init__(self, n, cfg):
        self.n = n
        self.cfg = cfg
        self.rng = random.Random(cfg["seed"])
        self.lib = library()
        self.s = n / DONOR_UNITS
        self.height = [0.0] * (n * n)
        self.type = [GRASS] * (n * n)
        self.depth = [0.0] * (n * n)
        self.coast = [0.0] * (n * n)
        self.forest_f = [0.0] * (n * n)
        self.trees, self.stones, self.wheat, self.mines, self.bushes = [], [], [], [], []
        self.starts = []
        self.occ = [False] * (n * n)     # gPatternMask
        self.stamped = []                # diagnostics

    def idx(self, x, y):
        return int(y) * self.n + int(x)

    def in_bounds(self, x, y):
        return 0 <= x < self.n and 0 <= y < self.n

    # -- stage 1: donor mask ------------------------------------------------
    def load_mask(self):
        manifest_path = os.path.join(MASKS, "manifest.json")
        with open(manifest_path, encoding="utf-8") as f:
            man = json.load(f)
        kind = self.cfg.get("mask_type", "land")
        entries = man["types"].get(kind, man["types"]["land"])["masks"]
        m = entries[self.cfg.get("mask_index", 0) % len(entries)]
        self.mask_info = m
        path = os.path.join(MASKS, m["file"])
        im = Image.open(path).convert("RGB")
        iw, ih = im.size
        n = self.n
        px = im.load()
        for y in range(n):
            sy0 = int(y / n * ih)
            sy1 = max(sy0 + 1, int((y + 1) / n * ih))
            for x in range(n):
                sx0 = int(x / n * iw)
                sx1 = max(sx0 + 1, int((x + 1) / n * iw))
                cr = cg = cb = cnt = 0.0
                for sy in range(sy0, min(sy1, ih)):
                    for sx in range(sx0, min(sx1, iw)):
                        r, g, b = px[sx, sy]
                        if r > 250 and g > 250 and b > 250:
                            continue  # start marker
                        cr += r; cg += g; cb += b; cnt += 1
                i = self.idx(x, y)
                if cnt:
                    cr /= cnt; cg /= cnt; cb /= cnt
                    self.height[i] = C_WATER * (cb / 255.0) * (1.0 + (cr / 255.0) * 3.5) + relief(cr)
                    self.forest_f[i] = cg / 255.0
                    if self.height[i] < -0.25:
                        self.type[i] = WATER
                        self.depth[i] = -self.height[i]
                    elif self.height[i] < -0.1:
                        self.type[i] = SAND
                    elif cr >= 250.0:
                        self.type[i] = ROCK
                    elif cr > 90.0:
                        self.type[i] = DIRT if cg < 40 else GRASS
        # coastline smoothing (generatemap.inc:611-640, 3 passes)
        for _ in range(3):
            src = self.height[:]
            for y in range(1, n - 1):
                for x in range(1, n - 1):
                    i = self.idx(x, y)
                    if self.type[i] not in (WATER, SAND):
                        continue
                    avg = (src[i - n - 1] + src[i - n + 1] + src[i + n - 1] + src[i + n + 1]) * 0.25
                    self.height[i] = src[i] + (avg - src[i]) * 0.5
        # start markers from the mask manifest; take the farthest pair for 2 players
        pts = [(int(a * n), int(b * n)) for a, b in m.get("starts", [])]
        if len(pts) < 2:
            pts = [(int(n * 0.15), int(n * 0.15)), (int(n * 0.85), int(n * 0.85))]
        best = max(((math.hypot(pts[i][0] - pts[j][0], pts[i][1] - pts[j][1]), i, j)
                    for i in range(len(pts)) for j in range(i + 1, len(pts))))
        self.starts = [pts[best[1]], pts[best[2]]]

    def compute_coast(self):
        n = self.n
        water = [(x, y) for y in range(n) for x in range(n)
                 if self.type[self.idx(x, y)] == WATER]
        if not water:
            return
        for y in range(n):
            for x in range(n):
                best = min((x - wx) ** 2 + (y - wy) ** 2 for wx, wy in water)
                d = math.sqrt(best)
                self.coast[self.idx(x, y)] = -d if self.type[self.idx(x, y)] == WATER else d

    # -- stage 2-6: pattern stamping ---------------------------------------
    def mark_ellipse(self, cx, cy, rx, ry, value=True):
        for y in range(int(cy - ry), int(cy + ry + 1)):
            for x in range(int(cx - rx), int(cx + rx + 1)):
                if self.in_bounds(x, y) and ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                    self.occ[self.idx(x, y)] = value

    def try_stamp(self, pattern_name, x, y, stand=True):
        """_misc_CheckStandPattern: test footprint against gPatternMask."""
        cells = self.lib.scaled_mask(pattern_name, self.n)
        n = self.n
        for dx, dy in cells:
            tx, ty = int(x) + dx, int(y) + dy
            if not self.in_bounds(tx, ty) or self.occ[self.idx(tx, ty)]:
                return False
        if stand:
            for dx, dy in cells:
                tx, ty = int(x) + dx, int(y) + dy
                self.occ[self.idx(tx, ty)] = True
        return True

    def family_home(self, family):
        b = "desert_" if self.cfg.get("biome") == "desert" else ""
        return b + family if (b + family) in self.lib.families else family

    def place_family(self, family, count, attempts=64, region=None, on_success=None):
        placed = 0
        fam = self.family_home(family)
        for _ in range(count):
            for _a in range(attempts):
                name = self.lib.pick(fam, self.rng)
                if not name:
                    break
                x = self.rng.randrange(2, self.n - 2)
                y = self.rng.randrange(2, self.n - 2)
                if region and not region(x, y):
                    continue
                if self.type[self.idx(x, y)] == WATER:
                    continue
                if self.try_stamp(name, x, y):
                    cells = self.lib.scaled_mask(name, self.n)
                    if on_success:
                        on_success(name, x, y, cells)
                    self.stamped.append((fam, name, x, y))
                    placed += 1
                    break
        return placed

    def terrain_in_cells(self, cells, cx, cy, kind, probability=1.0):
        for dx, dy in cells:
            x, y = cx + dx, cy + dy
            if self.in_bounds(x, y) and self.rng.random() < probability \
                    and self.type[self.idx(x, y)] not in (WATER, SAND):
                self.type[self.idx(x, y)] = kind

    def trees_in_cells(self, cells, cx, cy, density=0.55):
        for dx, dy in cells:
            x, y = cx + dx, cy + dy
            if not self.in_bounds(x, y) or self.type[self.idx(x, y)] in (WATER, SAND, ROCK):
                continue
            self.type[self.idx(x, y)] = FLOOR
            if self.rng.random() < density:
                self.trees.append((x, y, self.rng.randrange(2),
                                   self.rng.uniform(0.95, 1.30),
                                   self.rng.uniform(1.08, 1.40)))

    def stones_in_cells(self, cells, cx, cy, density=0.28):
        for dx, dy in cells:
            x, y = cx + dx, cy + dy
            if not self.in_bounds(x, y) or self.type[self.idx(x, y)] in (WATER, SAND):
                continue
            if self.rng.random() < density:
                self.stones.append((x, y, self.rng.uniform(0.75, 1.25)))
            if self.rng.random() < 0.08:
                self.bushes.append((x, y, True))

    def setup_tiles(self):
        """SetupTiles/SetupTiledPatterns: 25-unit strict grid, one pattern/cell."""
        # On a 72-tile preview the donor 25-unit grid would pack ~49 huge tile
        # decals and saturate gPatternMask, so we thin the grid (decor only).
        step = max(6, round(60 * self.s))
        fam = self.family_home("tiles")
        if not self.lib.families.get(fam):
            fam = "tiles"
        for gy in range(0, self.n, step):
            for gx in range(0, self.n, step):
                name = self.lib.pick(fam, self.rng)
                if not name:
                    continue
                x, y = gx + step // 2, gy + step // 2
                if self.try_stamp(name, x, y):
                    self.terrain_in_cells(self.lib.scaled_mask(name, self.n), x, y,
                                          DIRT, probability=0.18)
                    self.stamped.append(("tiles", name, x, y))

    def setup_mines(self):
        """SetupMines: for each start, 3 kinds x 3 rounds, 256 random angles."""
        kinds = ("mng", "mni", "mnc")
        for sx, sy in self.starts:
            for ki, kind in enumerate(kinds):
                fam = self.family_home(kind)
                for rnd_i, (d0, d1) in enumerate(MINE_RINGS):
                    for _a in range(256):
                        name = self.lib.pick(fam, self.rng)
                        if not name:
                            break
                        ang = self.rng.random() * math.tau
                        dst = (d0 + self.rng.random() * (d1 - d0)) * self.s
                        x = int(sx + math.cos(ang) * dst)
                        y = int(sy + math.sin(ang) * dst)
                        if not self.in_bounds(x, y) or self.type[self.idx(x, y)] == WATER:
                            continue
                        if self.try_stamp(name, x, y):
                            cells = self.lib.scaled_mask(name, self.n)
                            self.terrain_in_cells(cells, x, y, DIRT, probability=0.45)
                            self.mines.append((x, y, ("gold", "iron", "coal")[ki]))
                            self.stamped.append((kind, name, x, y))
                            break

    def setup_start_resources(self):
        """SetupStartingResources: cCircle1/2/3 keep-clear + ring placement."""
        for sx, sy in self.starts:
            r1 = (CIRCLE1[0] * self.s, CIRCLE1[1] * self.s)
            r2 = (CIRCLE2[0] * self.s, CIRCLE2[1] * self.s)
            r3 = (CIRCLE3[0] * self.s, CIRCLE3[1] * self.s)
            self.mark_ellipse(sx, sy, *r1, True)
            # food rects in the mid ring (the donor's only rectangular cluster)
            for g in range(2):
                ox = sx + (-r2[0] + g * r2[0]) + 2
                oy = sy + r2[1]
                for row in range(4):
                    for col in range(5):
                        wx = int(ox + (col - 2) * 0.95)
                        wy = int(oy + (row - 1.5) * 0.95)
                        if self.in_bounds(wx, wy) and self.type[self.idx(wx, wy)] not in (WATER, ROCK):
                            self.wheat.append((wx, wy))
            # stone + forest in the outer rings via real family masks
            for fam, ncnt in (("stones", 2), ("forests_pine_small", 2),
                              ("forests_mixed_medium", 1)):
                self.place_family(fam, ncnt, attempts=128,
                                  region=lambda x, y, s=sx, t=sy, rr=r3:
                                  math.hypot(x - s, y - t) < max(rr) * 1.4,
                                  on_success=self._on_forest
                                  if fam.startswith("forest") else self._on_stones)
            self.mark_ellipse(sx, sy, r2[0], r2[1], True)  # keep army space clear

    def _on_forest(self, name, x, y, cells):
        self.trees_in_cells(cells, x, y)

    def _on_stones(self, name, x, y, cells):
        self.terrain_in_cells(cells, x, y, DIRT, probability=0.8)
        self.terrain_in_cells(cells, x, y, ROCK, probability=0.25)
        self.stones_in_cells(cells, x, y)

    def _on_hills(self, name, x, y, cells):
        self.terrain_in_cells(cells, x, y, DIRT, probability=0.85)
        self.terrain_in_cells(cells, x, y, ROCK, probability=0.55)
        for dx, dy in cells:
            tx, ty = x + dx, y + dy
            if self.in_bounds(tx, ty):
                self.height[self.idx(tx, ty)] += 0.35

    def _on_decor(self, name, x, y, cells):
        for dx, dy in cells:
            tx, ty = x + dx, y + dy
            if self.in_bounds(tx, ty) and self.rng.random() < 0.22:
                self.bushes.append((tx, ty, self.type[self.idx(tx, ty)] in (SAND, ROCK)))

    def stamp_world(self):
        """Fill the map with weighted pattern families (dogenerate.inc rest stage)."""
        area = self.n * self.n
        base = area / (72.0 * 72.0)
        recipes = [
            ("forests_pinefir_big", int(5 * base), self._on_forest),
            ("forests_pine_medium", int(5 * base), self._on_forest),
            ("forests_spruce_big", int(4 * base), self._on_forest),
            ("forests_leaf_medium", int(4 * base), self._on_forest),
            ("forests_mixed_big", int(4 * base), self._on_forest),
            ("forests_pine_small", int(4 * base), self._on_forest),
            ("forests_leaf_small", int(3 * base), self._on_forest),
            ("stones", int(4 * base), self._on_stones),
            ("stoneforests", int(3 * base), self._on_stones),
            ("hills_dark", int(3 * base), self._on_hills),
            ("hills_light", int(3 * base), self._on_hills),
            ("decor", int(5 * base), self._on_decor),
            ("dcr1", int(3 * base), self._on_decor),
        ]
        biome = self.cfg.get("biome", "summer")
        for fam, count, cb in recipes:
            if biome == "desert" and fam.startswith("forest"):
                fam = "desert_forests_big"
            self.place_family(fam, max(1, count), attempts=200, on_success=cb)

    def generate(self):
        self.load_mask()
        self.compute_coast()
        self.setup_tiles()
        self.setup_mines()
        self.setup_start_resources()
        self.stamp_world()
        return self


def stats(mm):
    total = mm.n * mm.n
    counts = [0] * 6
    for t in mm.type:
        counts[t] += 1
    return {
        "mask": os.path.basename(mm.mask_info.get("file", "?")),
        "water_pct": round(100 * counts[WATER] / total, 1),
        "sand_pct": round(100 * counts[SAND] / total, 1),
        "rock_pct": round(100 * counts[ROCK] / total, 1),
        "floor_pct": round(100 * counts[FLOOR] / total, 1),
        "dirt_pct": round(100 * counts[DIRT] / total, 1),
        "trees": len(mm.trees), "stones": len(mm.stones),
        "wheat": len(mm.wheat), "mines": len(mm.mines),
        "bushes": len(mm.bushes), "stamped": len(mm.stamped),
    }
