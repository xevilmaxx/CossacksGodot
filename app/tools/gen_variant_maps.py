#!/usr/bin/env python3
"""Generate 3 small, clustered, donor-textured terrain-map variants as PNGs.

Purpose (round 1 of the iterative terrain-beauty loop):
  * show the MACRO layout only -- water, hills, forests, resources -- no
    buildings and no units, so the terrain itself can be judged;
  * every variant contains ALL feature families, always in discrete clusters
    with meadow gaps between them (the donor's dogenerate.inc rhythm);
  * ground pixels come from the installed game's own terrain PNGs, so the
    preview "confronts" directly with the reference screenshots;
  * the three variants differ by layout recipe + seed so you can pick one,
    or tell me to rethink before anything is written into the Godot port.

Output (default): app/shots/map_variants/
  variant_A_lakeside.png, variant_B_highland.png, variant_C_river.png
  variants_contact.png        -- the three, labelled + legend
  compare_with_originals.png  -- reference samples on top, variants below
  spec.json                   -- seed / parameters / coverage per variant

Usage:
  python app/tools/gen_variant_maps.py
  python app/tools/gen_variant_maps.py --out app/shots/map_variants --size 72 --tile 12
"""

import argparse
import glob
import json
import math
import os
import random
from collections import defaultdict

from PIL import Image, ImageDraw, ImageFilter, ImageFont

import donor_gen

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
ROOT = os.path.dirname(APP)
TERRAIN = os.path.join(APP, "assets", "terrain")
BLOCKS = os.path.join(TERRAIN, "blocks")
WATER_PNG = os.path.join(TERRAIN, "water_png")
DECO = os.path.join(TERRAIN, "deco_png")
SHOTS = os.path.join(APP, "shots")
SAMPLES = os.path.join(os.path.expanduser("~"), "Downloads", "c3")

# --------------------------------------------------------------------------
# Terrain ids (same six the port uses): 0 grass, 1 dirt, 2 forest floor,
# 3 water, 4 sand/shore, 5 rock.
# --------------------------------------------------------------------------
GRASS, DIRT, FLOOR, WATER, SAND, ROCK = range(6)


# --------------------------------------------------------------------------
# Deterministic value noise (no numpy dependency).
# --------------------------------------------------------------------------
class Noise:
    def __init__(self, rng, cells):
        self.cells = max(1, int(cells))
        self.g = [rng.random() for _ in range((self.cells + 1) * (self.cells + 1))]

    def sample(self, x, y):
        c = self.cells
        fx = min(max(x * c, 0.0), float(c) - 1e-6)
        fy = min(max(y * c, 0.0), float(c) - 1e-6)
        x0, y0 = int(fx), int(fy)
        tx, ty = fx - x0, fy - y0
        tx = tx * tx * (3.0 - 2.0 * tx)
        ty = ty * ty * (3.0 - 2.0 * ty)
        w = c + 1
        a = self.g[y0 * w + x0]
        b = self.g[y0 * w + x0 + 1]
        c2 = self.g[(y0 + 1) * w + x0]
        d = self.g[(y0 + 1) * w + x0 + 1]
        return (a + (b - a) * tx) + ((c2 + (d - c2) * tx) - (a + (b - a) * tx)) * ty


def fbm(rng, layers=((4, 0.55), (9, 0.30), (19, 0.15))):
    ns = [(Noise(rng, cells), weight) for cells, weight in layers]
    def f(x, y):
        s = 0.0
        for n, weight in ns:
            s += (n.sample(x, y) - 0.5) * 2.0 * weight
        return s
    return f


# --------------------------------------------------------------------------
# Asset loading (donor-derived PNGs that the project already ships).
# --------------------------------------------------------------------------
def _load_rgb(path):
    im = Image.open(path)
    return im.convert("RGB")


def load_assets(biome="summer"):
    """Load the FULL donor tile families already converted from the installed
    game into app/assets/terrain/blocks/ (grass, ground, sand, rock, desert,
    winter, sandsea, sandrock) plus donor water waves and field decals.

    biome: summer | winter | desert -- donor season palettes.
    """
    from PIL import ImageEnhance, ImageFilter, ImageStat

    def tex(prefix, indices):
        out = []
        for i in indices:
            p = os.path.join(BLOCKS, "%s%d.png" % (prefix, i))
            if os.path.exists(p):
                out.append(_load_rgb(p))
        return out

    def lush(im, bright=1.0, sat=1.0, target=None):
        if sat != 1.0:
            im = ImageEnhance.Color(im).enhance(sat)
        if bright != 1.0:
            im = ImageEnhance.Brightness(im).enhance(bright)
        if target:
            m = ImageStat.Stat(im.convert("L")).mean[0]
            if m > 1:
                im = ImageEnhance.Brightness(im).enhance(target / m)
        return im

    rng10 = list(range(1, 11))
    rng9 = list(range(1, 10))
    rng12 = list(range(1, 13))
    rng27 = list(range(27))
    if biome == "winter":
        # donor winter0..winter26.dds -- the donor's own snow season tiles.
        # They are high-contrast 1:1 engine tiles; soften + flatten so they
        # read as a snow field at this preview scale, like the winter sample.
        def snow(im):
            im = im.filter(ImageFilter.GaussianBlur(2.2))
            return ImageEnhance.Contrast(im).enhance(0.55)
        grass = [lush(snow(im), sat=0.5, target=196) for im in tex("winter", rng27)]
        worn = [lush(snow(im), sat=0.4, target=176) for im in tex("winter", rng27[:8])]
        forest = [lush(snow(im), sat=0.4, target=158) for im in tex("winter", rng27[8:16])]
        sand = [lush(snow(im), sat=0.45, target=206) for im in tex("winter", rng27[16:20])]
        dirt = [lush(snow(im), sat=0.45, target=164) for im in tex("winter", rng27[20:24])]
        rock = [lush(im, sat=0.5, target=166) for im in tex("rock", rng9)]
    elif biome == "desert":
        grass = [lush(im, sat=1.05, target=148) for im in tex("desert", rng12)]
        worn = [lush(im, sat=1.0, target=162) for im in tex("sand", rng9)]
        forest = [lush(im, sat=0.9, target=138) for im in tex("desert", rng12[:6])]
        sand = [lush(im, sat=1.05, target=172) for im in tex("sandsea", range(1, 7))]
        dirt = [lush(im, sat=1.0, target=150) for im in tex("sandrock", range(1, 7))]
        rock = [lush(im, sat=0.95, target=148) for im in tex("sandrock", range(1, 7))]
    else:  # summer -- the full green family, not just the 17 legacy files
        grass = [lush(im, sat=1.14, target=86) for im in tex("grass", rng10)]
        worn = [lush(im, sat=1.05, target=82) for im in tex("grass_ground", range(1, 4))]
        forest = [lush(im, sat=1.05, target=72) for im in tex("grass_ground", range(1, 4))]
        sand = [lush(im, sat=1.05, target=96) for im in tex("grass_sand", range(1, 3))]
        dirt = [lush(im, sat=1.0, target=78) for im in tex("ground", range(1, 2))]
        rock = [lush(im, sat=0.9, target=108) for im in tex("rock", rng9)]

    # donor-baked trees from the project's own sprites
    def tree(path):
        im = _load_rgb(path)
        lum = im.convert("L")
        alpha = lum.point(lambda v: 0 if v < 11 else min(255, (v - 11) * 7))
        im.putalpha(alpha)
        bb = alpha.getbbox()
        return im.crop(bb) if bb else im

    trees = [tree(os.path.join(SHOTS, "tree_tree_pine.png")),
             tree(os.path.join(SHOTS, "tree_tree_oak.png"))]
    if biome == "winter":
        # snow-laden canopy, matching the winter reference sample
        snowy = []
        for im in trees:
            im = im.copy()
            px, (w, h) = im.load(), im.size
            for yy in range(h):
                for xx in range(w):
                    r, g, b, a = px[xx, yy]
                    if a > 20 and yy < h * 0.80:
                        k = 0.58 if yy < h * 0.52 else 0.24
                        px[xx, yy] = (int(r + (238 - r) * k), int(g + (244 - g) * k),
                                      int(b + (250 - b) * k), a)
            snowy.append(im)
        trees = snowy

    # donor water wave textures (data/water/textures/diffusewaves*.dds -> PNG)
    waves = []
    for p in sorted(glob.glob(os.path.join(WATER_PNG, "diffusewaves*.png"))):
        waves.append(_load_rgb(p))
    field = None
    fp = os.path.join(DECO, "envfieldd.png" if biome != "winter" else "envfielddw.png")
    if os.path.exists(fp):
        field = Image.open(fp).convert("RGBA")
    return {"grass": grass, "worn": worn, "forest": forest, "sand": sand,
            "dirt": dirt, "rock": rock, "trees": trees, "waves": waves,
            "field": field, "biome": biome}


# --------------------------------------------------------------------------
# Map model.
# --------------------------------------------------------------------------
class MapModel:
    def __init__(self, n, cfg):
        self.n = n
        self.cfg = cfg
        self.rng = random.Random(cfg["seed"])
        self.height = [0.0] * (n * n)
        self.type = [GRASS] * (n * n)
        self.depth = [0.0] * (n * n)
        self.coast = [0.0] * (n * n)   # signed distance to water (<0 = in water)
        self.trees = []           # (x_tile, y_tile, kind, size, tint)
        self.stones = []          # (x_tile, y_tile, size)
        self.wheat = []           # (x_tile, y_tile)
        self.mines = []           # (x_tile, y_tile, kind)
        self.bushes = []          # (x_tile, y_tile, dry)
        self.starts = []          # (x_tile, y_tile)
        self.quarry_centers = []  # for post-forest tree clearance
        self.field_centers = []
        self.claims = []          # (x_tile, y_tile, radius) -- cluster separation
        self.base = fbm(self.rng)
        self.detail = fbm(self.rng, ((22, 0.6), (47, 0.4)))

    def idx(self, x, y):
        return int(y) * self.n + int(x)

    def in_bounds(self, x, y, pad=1):
        return pad <= x < self.n - pad and pad <= y < self.n - pad

    def claim(self, x, y, r, margin=None):
        """Reject a cluster that would merge into an existing one."""
        m = self.cfg["margin"] if margin is None else margin
        for cx, cy, cr in self.claims:
            if math.hypot(x - cx, y - cy) < r + cr + m:
                return False
        self.claims.append((x, y, r))
        return True

    def reserve(self, x, y, r):
        """Claim a spot unconditionally (resources have priority over forests)."""
        self.claims.append((x, y, r))
        return True

    def find_land(self, x, y):
        """Spiral out to the nearest walkable tile (resources never sit in water)."""
        x, y = int(x), int(y)
        if self.in_bounds(x, y) and self.type[self.idx(x, y)] not in (WATER, SAND, ROCK):
            return float(x), float(y)
        for r in range(1, self.n):
            for dy in range(-r, r + 1):
                for dx in range(-r, r + 1):
                    nx, ny = x + dx, y + dy
                    if self.in_bounds(nx, ny) and self.type[self.idx(nx, ny)] not in (WATER, SAND, ROCK):
                        return float(nx), float(ny)
        return float(x), float(y)

    # -- water -------------------------------------------------------------
    def water_feature(self):
        n = self.n
        wf = self.cfg["water"]
        if wf["kind"] == "river":
            phase = self.rng.uniform(0, math.tau)
            amp = n * wf.get("amp", 0.11)
            width = n * wf.get("width", 0.036)
            for y in range(n):
                xc = n * 0.5 + math.sin(y / n * math.tau + phase) * amp
                wob = self.detail(xc / n, y / n) * 1.4
                half = width + wob
                for x in range(n):
                    d = abs(x - xc) - half
                    if d < 0:
                        self.height[self.idx(x, y)] -= 1.7 + min(0.7, -d * 0.06)
                        self.type[self.idx(x, y)] = WATER
                        self.depth[self.idx(x, y)] = -d
                    elif d < 2.0 and self.type[self.idx(x, y)] != WATER:
                        self.type[self.idx(x, y)] = SAND
            # a widening pool where the river bends
            px = int(n * 0.5 + math.sin(n * 0.62 / n * math.tau + phase) * amp)
            self._lake(px, int(n * 0.62), n * 0.075, n * 0.07)
            return

        cx, cy = wf["cx"] * n, wf["cy"] * n
        rx, ry = wf["rx"] * n, wf["ry"] * n
        self._lake(cx, cy, rx, ry)

    def _lake(self, cx, cy, rx, ry):
        n = self.n
        for y in range(n):
            for x in range(n):
                nx = (x - cx) / rx
                ny = (y - cy) / ry
                d = math.hypot(nx, ny)
                edge = self.detail(x / n, y / n) * 0.11
                d += edge
                if d < 1.0:
                    i = self.idx(x, y)
                    self.height[i] -= 1.8 + (1.0 - d) * 0.8
                    self.type[i] = WATER
                    self.depth[i] = (1.0 - d) * rx
                elif d < 1.24 and self.type[self.idx(x, y)] != WATER:
                    self.type[self.idx(x, y)] = SAND

    # -- hills -------------------------------------------------------------
    def hills(self):
        n = self.n
        self.hill_list = []
        for h in self.cfg["hills"]:
            cx, cy = h["cx"] * n, h["cy"] * n
            r = h["r"] * n
            amp = h.get("amp", 1.7)
            # never bury a hill under water
            if self.type[self.idx(int(cx), int(cy))] == WATER:
                continue
            self.hill_list.append((cx, cy, r))
            for y in range(max(0, int(cy - r * 1.3)), min(n, int(cy + r * 1.3))):
                for x in range(max(0, int(cx - r * 1.3)), min(n, int(cx + r * 1.3))):
                    d = math.hypot(x - cx, y - cy) / r
                    d += self.detail(x / n, y / n) * 0.10
                    if d >= 1.15:
                        continue
                    i = self.idx(x, y)
                    if self.type[i] == WATER:
                        continue
                    self.height[i] += max(0.0, 1.0 - d) ** 2 * amp
                    if d < 0.42:
                        self.type[i] = ROCK
                    elif d < 0.78 and self.type[i] == GRASS:
                        self.type[i] = DIRT
            self.claim(cx, cy, r)

    # -- forests -----------------------------------------------------------
    def forests(self):
        n = self.n
        count = self.cfg["forests"]
        tries = 0
        placed = 0
        while placed < count and tries < 600:
            tries += 1
            r = self.rng.uniform(*self.cfg["forest_r"]) * n
            x = self.rng.uniform(0.10, 0.90) * n
            y = self.rng.uniform(0.10, 0.90) * n
            # forests may sit closer to work sites than work sites to each other;
            # clear_trees_around_resources() trims any canopy that crosses in.
            if not self.claim(x, y, r, margin=1.0):
                continue
            if self.type[self.idx(int(x), int(y))] in (WATER, SAND, ROCK):
                self.claims.pop()
                continue
            for hx, hy, hr in self.hill_list:
                if math.hypot(x - hx, y - hy) < r + hr * 0.55:
                    self.claims.pop()
                    break
            else:
                self._forest_blob(x, y, r)
                placed += 1

    def _forest_blob(self, cx, cy, r):
        n = self.n
        step = 0.9
        y = cy - r
        while y <= cy + r:
            x = cx - r
            while x <= cx + r:
                nx = (x - cx) / r
                ny = (y - cy) / r
                d = math.hypot(nx, ny)
                edge = self.detail(x / n, y / n) * 0.20
                if d + edge < 0.95:
                    xi, yi = int(round(x)), int(round(y))
                    if self.in_bounds(xi, yi) and self.type[self.idx(xi, yi)] not in (WATER, SAND, ROCK):
                        self.type[self.idx(xi, yi)] = FLOOR
                        if self.rng.random() < 0.90 - d * 0.22:
                            kind = self.rng.randrange(2)
                            size = self.rng.uniform(0.95, 1.30)
                            tint = self.rng.uniform(1.08, 1.40)
                            self.trees.append((xi, yi, kind, size, tint))
                x += step * (0.85 + self.rng.random() * 0.35)
            y += step * (0.85 + self.rng.random() * 0.35)

    # -- resources ---------------------------------------------------------
    def resources(self):
        n = self.n
        # two dirt plazas (terrain only -- no buildings, no units)
        for sx, sy in self.cfg["starts"]:
            x, y = sx * n, sy * n
            for yy in range(int(y - 3), int(y + 4)):
                for xx in range(int(x - 3), int(x + 4)):
                    if self.in_bounds(xx, yy) and math.hypot(xx - x, yy - y) < 3.2:
                        if self.type[self.idx(xx, yy)] not in (WATER, ROCK):
                            self.type[self.idx(xx, yy)] = DIRT
            self.starts.append((x, y))
            self.reserve(x, y, 3.2)

        # stone quarries: pale dirt scar, grey core, treeless
        for qx, qy in self.cfg["quarries"]:
            x, y = self.find_land(qx * n, qy * n)
            self.reserve(x, y, n * 0.075)
            self.quarry_centers.append((x, y))
            for yy in range(int(y - 5), int(y + 6)):
                for xx in range(int(x - 5), int(x + 6)):
                    if not self.in_bounds(xx, yy):
                        continue
                    d = math.hypot(xx - x, yy - y)
                    if d < 4.6 and self.type[self.idx(xx, yy)] not in (WATER, ROCK):
                        self.type[self.idx(xx, yy)] = DIRT
                    if d < 2.4:
                        self.type[self.idx(xx, yy)] = ROCK
            for _ in range(self.rng.randint(5, 8)):
                a = self.rng.random() * math.tau
                rr = self.rng.uniform(0.4, 3.0)
                self.stones.append((x + math.cos(a) * rr, y + math.sin(a) * rr,
                                    self.rng.uniform(0.75, 1.25)))
            for _ in range(self.rng.randint(2, 4)):
                a = self.rng.random() * math.tau
                self.bushes.append((x + math.cos(a) * 4.2, y + math.sin(a) * 4.2, True))

        # one mining district: gold / iron / coal spaced as a cluster
        mx, my = self.find_land(self.cfg["mines"]["cx"] * n, self.cfg["mines"]["cy"] * n)
        self.reserve(mx, my, n * 0.085)
        for ki, kind in enumerate(("gold", "iron", "coal")):
            a = self.cfg["mines"]["angles"][ki]
            d = self.cfg["mines"]["dist"] * n * 0.5
            px, py = self.find_land(mx + math.cos(a) * d, my + math.sin(a) * d)
            for yy in range(int(py - 2), int(py + 3)):
                for xx in range(int(px - 2), int(px + 3)):
                    if self.in_bounds(xx, yy) and math.hypot(xx - px, yy - py) < 2.4 \
                            and self.type[self.idx(xx, yy)] not in (WATER, SAND):
                        self.type[self.idx(xx, yy)] = DIRT
            self.mines.append((px, py, kind))

        # rectangular food fields (the donor's only rectangular cluster)
        for fx, fy in self.cfg["fields"]:
            x, y = self.find_land(fx * n, fy * n)
            self.reserve(x, y, n * 0.05)
            self.field_centers.append((x, y))
            for row in range(4):
                for col in range(5):
                    wx = x + (col - 2) * 0.95 + self.rng.uniform(-0.12, 0.12)
                    wy = y + (row - 1.5) * 0.95 + self.rng.uniform(-0.12, 0.12)
                    if self.in_bounds(int(wx), int(wy)) \
                            and self.type[self.idx(int(wx), int(wy))] not in (WATER, ROCK):
                        self.wheat.append((wx, wy))

        # shore shrubs (decor, never claimed, non-blocking)
        for y in range(n):
            for x in range(n):
                if self.type[self.idx(x, y)] in (SAND, ROCK) and self.rng.random() < 0.035:
                    self.bushes.append((x + self.rng.random(), y + self.rng.random(),
                                        self.type[self.idx(x, y)] == SAND))

    def compute_coast(self):
        """Signed distance to the water line, used for a smooth shoreline."""
        n = self.n
        water = [(x, y) for y in range(n) for x in range(n)
                 if self.type[self.idx(x, y)] == WATER]
        if not water:
            return
        for y in range(n):
            for x in range(n):
                best = 1e9
                for wx, wy in water:
                    dx, dy = x - wx, y - wy
                    dd = dx * dx + dy * dy
                    if dd < best:
                        best = dd
                d = math.sqrt(best)
                self.coast[self.idx(x, y)] = -d if self.type[self.idx(x, y)] == WATER else d

    def clear_trees_around_resources(self):
        """Forests are placed last, so prune any canopy that grew into a work site."""
        def prune(cx, cy, r):
            self.trees = [t for t in self.trees if math.hypot(t[0] - cx, t[1] - cy) > r]
        for sx, sy in self.starts:
            prune(sx, sy, 3.6)
        for qx, qy in self.quarry_centers:
            prune(qx, qy, 5.0)
        for mx, my, _ in self.mines:
            prune(mx, my, 3.0)
        for fx, fy in self.field_centers:
            prune(fx, fy, 3.4)

    def generate(self):
        # base relief first
        for y in range(self.n):
            for x in range(self.n):
                self.height[self.idx(x, y)] = self.base(x / self.n, y / self.n) * 0.85
        self.water_feature()
        self.compute_coast()
        self.hills()
        self.resources()          # resources reserve their spots FIRST (priority)
        self.forests()            # forests then fill the gaps between them
        self.clear_trees_around_resources()
        return self


# --------------------------------------------------------------------------
# Renderer.
# --------------------------------------------------------------------------
def _feather_mask(size, feather):
    m = Image.new("L", (size, size), 255)
    px = m.load()
    for y in range(size):
        for x in range(size):
            d = min(x, y, size - 1 - x, size - 1 - y)
            if d < feather:
                px[x, y] = int(255 * (d + 1) / (feather + 1))
    return m


def _crop_resize(tex, rng, out, crop=128):
    w, h = tex.size
    cw = min(crop, w - 2)
    ch = min(crop, h - 2)
    x = rng.randrange(0, w - cw)
    y = rng.randrange(0, h - ch)
    return tex.crop((x, y, x + cw, y + ch)).resize((out, out), Image.BILINEAR)


def render(mm, assets, tile=12):
    n = mm.n
    rng = random.Random(mm.cfg["seed"] ^ 0x5f3a)
    S = n * tile
    canvas = Image.new("RGB", (S, S), (60, 78, 44))
    pad = 2
    cell = tile + pad * 2
    mask = _feather_mask(cell, 3)
    pools = {
        GRASS: list(assets["grass"]),
        DIRT: assets["dirt"],
        FLOOR: assets["forest"],
        SAND: assets["sand"],
        ROCK: assets["rock"],
    }
    variant_noise = fbm(rng, ((11, 0.6), (23, 0.4)))
    worn_noise = fbm(rng, ((13, 0.7), (29, 0.3)))

    for y in range(n):
        for x in range(n):
            t = mm.type[mm.idx(x, y)]
            if t == WATER:
                continue
            # rare, coherent worn flecks -- the donor's 4th grass voice, not a camo print
            if t == GRASS and worn_noise(x / n, y / n) > 0.68 and rng.random() < 0.25:
                pool = assets["worn"]
            else:
                pool = pools[t]
            v = variant_noise(x / n, y / n)
            tex = pool[min(len(pool) - 1, int((v * 0.5 + 0.5) * len(pool)))]
            piece = _crop_resize(tex, rng, cell)
            f = 1.0 + v * 0.06
            if t == FLOOR:
                f *= 0.90
            elif t == SAND:
                f *= 1.06
            elif t == DIRT:
                f *= 0.98
            elif t == ROCK:
                f *= 1.05
            arr = piece.load()
            for yy in range(cell):
                for xx in range(cell):
                    r, g, b = arr[xx, yy]
                    arr[xx, yy] = (min(255, int(r * f)), min(255, int(g * f)), min(255, int(b * f)))
            canvas.paste(piece, (x * tile - pad, y * tile - pad), mask)

    # water at 4x sub-tile resolution -> smooth, non-blocky shoreline
    SS = 4
    wlayer = Image.new("RGBA", (S * SS, S * SS), (0, 0, 0, 0))
    wp = wlayer.load()

    def bill(arr, tx, ty):
        x0 = min(max(int(tx), 0), n - 1)
        y0 = min(max(int(ty), 0), n - 1)
        x1 = min(x0 + 1, n - 1)
        y1 = min(y0 + 1, n - 1)
        ax, ay = tx - x0, ty - y0
        a = arr[y0 * n + x0] * (1 - ax) + arr[y0 * n + x1] * ax
        b = arr[y1 * n + x0] * (1 - ax) + arr[y1 * n + x1] * ax
        return a * (1 - ay) + b * ay

    for sy in range(S * SS):
        ty = (sy / SS) / tile
        for sx in range(S * SS):
            tx = (sx / SS) / tile
            cd = bill(mm.coast, tx, ty)
            if cd > 0.28:
                continue
            dep = max(0.0, bill(mm.depth, tx, ty))
            t = min(1.0, dep / 10.0)
            col = (int(60 - t * 34), int(126 - t * 58), int(158 - t * 50))
            alpha = 255 if cd < -0.35 else int(255 * (0.28 - cd) / 0.63)
            wp[sx, sy] = col + (max(0, min(255, alpha)),)
    wlayer = wlayer.resize((S, S), Image.LANCZOS)
    canvas = Image.alpha_composite(canvas.convert("RGBA"), wlayer).convert("RGB")
    # donor's own water waves (data/water/textures/diffusewaves*.dds), clipped
    # to the water line -- no hand-drawn ripple lines
    if assets["waves"]:
        wav = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        wmask = Image.new("L", (S, S), 0)
        wm = wmask.load()
        for y in range(n):
            for x in range(n):
                if mm.type[mm.idx(x, y)] != WATER:
                    continue
                wav.paste(_crop_resize(rng.choice(assets["waves"]), rng, tile, crop=512),
                          (x * tile, y * tile))
                for yy in range(tile):
                    for xx in range(tile):
                        wm[x * tile + xx, y * tile + yy] = 255
        wmask = wmask.filter(ImageFilter.GaussianBlur(0.8))
        wav.putalpha(wmask.point(lambda v: int(v * 0.20)))
        canvas = Image.alpha_composite(canvas.convert("RGBA"), wav).convert("RGB")

    # hillshade from the height field (light from NW)
    shade = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    for y in range(1, n - 1):
        for x in range(1, n - 1):
            c = mm.height[mm.idx(x, y)]
            gx = mm.height[mm.idx(x + 1, y)] - mm.height[mm.idx(x - 1, y)]
            gy = mm.height[mm.idx(x, y + 1)] - mm.height[mm.idx(x, y - 1)]
            s = (gx + gy) * 26.0 + max(0.0, c) * 5.0
            if abs(s) < 2.0:
                continue
            col = (255, 248, 226, min(58, int(abs(s)))) if s > 0 else (8, 16, 14, min(66, int(abs(s))))
            sd.rectangle([x * tile, y * tile, (x + 1) * tile, (y + 1) * tile], fill=col)
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shade).convert("RGB")
    d = ImageDraw.Draw(canvas, "RGBA")

    def tw(x, y):
        return x * tile + tile * 0.5, y * tile + tile * 0.5

    # trees: soft shadow then sprite (alpha already keyed from the donor sheet)
    for tx, ty, kind, size, tint in mm.trees:
        px, py = tw(tx, ty)
        d.ellipse([px - tile * 0.85, py - tile * 0.18, px + tile * 0.85, py + tile * 0.42],
                  fill=(10, 18, 10, 70))
        sp = assets["trees"][kind]
        h = int(tile * 2.9 * size)
        w = max(1, int(sp.width * h / sp.height))
        sp = sp.resize((w, h), Image.BILINEAR)
        if abs(tint - 1.0) > 0.02:
            r, g, b, a = sp.split()
            sp = Image.merge("RGBA", (r.point(lambda v: min(255, int(v * tint))),
                                      g.point(lambda v: min(255, int(v * tint))),
                                      b.point(lambda v: min(255, int(v * tint))), a))
        canvas.paste(sp, (int(px - w / 2), int(py - h + tile * 0.55)), sp)

    # stones
    for sx, sy, sz in mm.stones:
        px, py = tw(sx, sy)
        rr = max(2, int(tile * 0.42 * sz))
        d.ellipse([px - rr, py - rr * 0.7, px + rr, py + rr * 0.7], fill=(92, 88, 80, 255))
        d.ellipse([px - rr, py - rr * 0.7, px - rr // 3, py], fill=(150, 146, 136, 220))

    # wheat tufts (gold, the donor food field signature)
    for wx, wy in mm.wheat:
        px, py = tw(wx, wy)
        for k in (-1, 0, 1):
            d.line([px + k * 2, py + 2, px + k * 2 - 1, py - 3], fill=(218, 190, 72, 235), width=1)
        d.ellipse([px - 1, py - 4, px + 1, py - 2], fill=(240, 214, 96, 230))

    # mine dots
    mcol = {"gold": (232, 196, 60), "iron": (168, 92, 64), "coal": (56, 58, 62)}
    for mx, my, kind in mm.mines:
        px, py = tw(mx, my)
        d.ellipse([px - 5, py - 3, px + 5, py + 4], fill=(48, 44, 38, 200))
        c = mcol[kind]
        d.ellipse([px - 3, py - 4, px + 3, py + 2], fill=c + (255,))
        d.ellipse([px - 2, py - 4, px, py - 2], fill=(255, 255, 255, 120))

    # shrubs
    for bx, by, dry in mm.bushes:
        px, py = tw(bx, by)
        c = (96, 96, 52, 220) if dry else (54, 86, 44, 220)
        d.ellipse([px - 3, py - 2, px + 3, py + 2], fill=c)

    # plaza rings (terrain reading aid, no buildings/units)
    for sx, sy in mm.starts:
        px, py = tw(sx, sy)
        d.ellipse([px - tile * 3.1, py - tile * 3.1, px + tile * 3.1, py + tile * 3.1],
                  outline=(225, 214, 180, 110), width=2)

    return canvas.filter(ImageFilter.GaussianBlur(0.35))


# --------------------------------------------------------------------------
# Variant recipes.
# --------------------------------------------------------------------------
def variant_configs():
    return [
        {
            "name": "A_lakeside",
            "label": "A  /  LAKESIDE  - one big lake, forests in belts, hills opposite",
            "seed": 1017,
            "mask_type": "land", "mask_index": 0,
            "margin": 2.2,
            "water": {"kind": "lake", "cx": 0.22, "cy": 0.26, "rx": 0.20, "ry": 0.17},
            "hills": [{"cx": 0.76, "cy": 0.30, "r": 0.13, "amp": 1.7},
                      {"cx": 0.66, "cy": 0.74, "r": 0.11, "amp": 1.4}],
            "forests": 6, "forest_r": (0.085, 0.120),
            "quarries": [(0.44, 0.18), (0.86, 0.62)],
            "mines": {"cx": 0.48, "cy": 0.78, "angles": (2.2, 3.9, 5.5), "dist": 0.13},
            "fields": [(0.20, 0.72), (0.80, 0.88)],
            "starts": [(0.09, 0.09), (0.91, 0.91)],
        },
        {
            "name": "B_highland",
            "label": "B  /  HIGHLAND  - central rocky ridge, small pond, tight forest wedges",
            "seed": 2029,
            "mask_type": "land", "mask_index": 6,
            "margin": 2.2,
            "water": {"kind": "lake", "cx": 0.80, "cy": 0.82, "rx": 0.13, "ry": 0.12},
            "hills": [{"cx": 0.50, "cy": 0.42, "r": 0.16, "amp": 2.1},
                      {"cx": 0.30, "cy": 0.66, "r": 0.10, "amp": 1.5}],
            "forests": 6, "forest_r": (0.085, 0.120),
            "quarries": [(0.18, 0.28), (0.70, 0.18)],
            "mines": {"cx": 0.78, "cy": 0.48, "angles": (2.6, 4.2, 5.8), "dist": 0.12},
            "fields": [(0.16, 0.86), (0.88, 0.20)],
            "starts": [(0.09, 0.91), (0.91, 0.09)],
        },
        {
            "name": "C_river",
            "label": "C  /  RIVER VALLEY  - winding river + pool, forest flanks, hills on one bank",
            "seed": 3041,
            "mask_type": "land", "mask_index": 1,
            "margin": 2.2,
            "water": {"kind": "river", "amp": 0.12, "width": 0.035},
            "hills": [{"cx": 0.22, "cy": 0.24, "r": 0.12, "amp": 1.7},
                      {"cx": 0.80, "cy": 0.70, "r": 0.12, "amp": 1.6}],
            "forests": 7, "forest_r": (0.080, 0.115),
            "quarries": [(0.72, 0.24), (0.28, 0.78)],
            "mines": {"cx": 0.50, "cy": 0.50, "angles": (0.6, 2.4, 4.4), "dist": 0.12},
            "fields": [(0.14, 0.52), (0.86, 0.48)],
            "starts": [(0.08, 0.08), (0.92, 0.92)],
        },
    ]


def _font(size, bold=False):
    # Cross-platform candidates first; explicit Windows paths are kept as a
    # fallback so legacy hosts still get Arial. Final fallback is unchanged.
    candidates = [
        "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold
        else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\segoeui.ttf",
    ]
    for p in candidates:
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            continue
    return ImageFont.load_default()


def make_contact(images, cfgs, out):
    tw = 440
    th = int(images[0].height * tw / images[0].width)
    bar = 52
    sheet = Image.new("RGB", (tw * 3, th + bar + 46), (22, 24, 20))
    d = ImageDraw.Draw(sheet)
    f = _font(15, True)
    fs = _font(12)
    for i, (im, cfg) in enumerate(zip(images, cfgs)):
        sheet.paste(im.resize((tw, th), Image.LANCZOS), (i * tw, bar))
        short = cfg["label"].split("-")[0].strip()
        d.text((i * tw + 12, 16), short, font=f, fill=(235, 226, 198))
        d.rectangle([i * tw, bar - 2, i * tw + tw - 1, bar], fill=(150, 118, 62))
    legend = ("GREEN = meadow  |  DARK GREEN + trees = forest belt  |  GREY = rock/hill  |  "
              "BLUE = water + sand collar  |  BROWN = worked dirt / quarry  |  "
              "GOLD tufts = food field  |  coloured dots = gold / iron / coal mines  |  "
              "pale rings = two start clearings (no buildings, no units)")
    d.text((14, bar + th + 12), legend, font=fs, fill=(198, 196, 178))
    sheet.save(out)


def make_comparison(images, cfgs, out):
    """All reference samples (green/winter/desert) above, our 3 variants below."""
    ext = (".jpg", ".jpeg", ".png", ".webp")
    samples = sorted(p for p in os.listdir(SAMPLES) if p.lower().endswith(ext)) if os.path.isdir(SAMPLES) else []
    refs = []
    for name in samples:
        im = Image.open(os.path.join(SAMPLES, name)).convert("RGB")
        w, h = im.size
        refs.append((name, im.crop((int(w * 0.05), int(h * 0.10), int(w * 0.95), int(h * 0.90)))))
    if not refs:
        return
    cw, ch, refcols = 290, 186, 5
    gap, label_h, top = 8, 24, 30
    refrows = math.ceil(len(refs) / refcols)
    W = refcols * cw + (refcols + 1) * gap
    y_variants = top + refrows * (ch + label_h) + gap + label_h
    H = y_variants + ch + label_h + gap
    sheet = Image.new("RGB", (W, H), (18, 20, 17))
    d = ImageDraw.Draw(sheet)
    f = _font(14, True)
    d.text((gap, 6), "REFERENCE SAMPLES - green / winter / desert biomes (Cossacks 3)", font=f, fill=(236, 224, 190))
    small = _font(10)
    for i, (name, im) in enumerate(refs):
        col, row = i % refcols, i // refcols
        x = gap + col * (cw + gap)
        y = top + row * (ch + label_h)
        sheet.paste(im.resize((cw, ch), Image.LANCZOS), (x, y + label_h))
        d.text((x + 2, y + 5), os.path.splitext(name)[0][:38], font=small, fill=(202, 202, 188))
    y2 = y_variants
    d.text((gap, y2 - label_h + 4), "GENERATED VARIANTS - donor textures, clustered macro layout, no buildings/units",
           font=f, fill=(236, 224, 190))
    for i, (im, cfg) in enumerate(zip(images, cfgs)):
        x = gap + i * (cw + gap)
        sheet.paste(im.resize((cw, ch), Image.LANCZOS), (x, y2))
        d.text((x + 2, y2 + ch + 4), cfg["label"].split("-")[0].strip(), font=_font(11), fill=(206, 206, 190))
    sheet.save(out)


def stats(mm):
    total = mm.n * mm.n
    counts = defaultdict(int)
    for t in mm.type:
        counts[t] += 1
    return {
        "grass_pct": round(100 * counts[GRASS] / total, 1),
        "dirt_pct": round(100 * counts[DIRT] / total, 1),
        "floor_pct": round(100 * counts[FLOOR] / total, 1),
        "water_pct": round(100 * counts[WATER] / total, 1),
        "sand_pct": round(100 * counts[SAND] / total, 1),
        "rock_pct": round(100 * counts[ROCK] / total, 1),
        "trees": len(mm.trees), "stones": len(mm.stones), "wheat": len(mm.wheat),
        "mines": len(mm.mines), "bushes": len(mm.bushes), "clusters": len(mm.claims),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(SHOTS, "map_variants"))
    ap.add_argument("--size", type=int, default=72, help="map side in tiles")
    ap.add_argument("--tile", type=int, default=12, help="pixels per tile")
    ap.add_argument("--biome", choices=("summer", "winter", "desert"), default=None,
                    help="override the biome for all three variants")
    ap.add_argument("--engine", choices=("donor", "blob"), default="donor",
                    help="donor = real masks + pattern stamping (default); blob = early prototype")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    cfgs = variant_configs()
    cache = {}
    images, spec = [], {"map_tiles": a.size, "tile_px": a.tile, "variants": {}}
    suffix = "" if a.biome in (None, "summer") else "_" + a.biome
    for cfg in cfgs:
        biome = a.biome or cfg.get("biome", "summer")
        if biome not in cache:
            cache[biome] = load_assets(biome)
        run_cfg = dict(cfg)
        run_cfg["biome"] = biome
        if a.engine == "donor":
            mm = donor_gen.DonorMap(a.size, run_cfg).generate()
            st = donor_gen.stats(mm)
        else:
            mm = MapModel(a.size, run_cfg).generate()
            st = stats(mm)
        im = render(mm, cache[biome], a.tile)
        key = cfg["name"] + suffix
        path = os.path.join(a.out, "variant_%s.png" % key)
        im.save(path)
        images.append(im)
        spec["variants"][key] = {"seed": cfg["seed"], "biome": biome,
                                 "engine": a.engine,
                                 "label": cfg["label"] + " [" + biome + "]",
                                 "config": cfg, "stats": st, "file": os.path.basename(path)}
        print("%-12s %-6s %s" % (key, biome, st))
    make_contact(images, cfgs, os.path.join(a.out, "variants_contact" + suffix + ".png"))
    make_comparison(images, cfgs, os.path.join(a.out, "compare_with_originals" + suffix + ".png"))
    with open(os.path.join(a.out, "spec.json"), "w", encoding="utf-8") as f:
        json.dump(spec, f, indent=2, ensure_ascii=False)
    print("wrote", a.out)


if __name__ == "__main__":
    main()
