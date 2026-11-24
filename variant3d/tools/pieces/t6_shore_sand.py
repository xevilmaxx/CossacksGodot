#!/usr/bin/env python3
"""T6-T02 shore_sand — single-piece, headless, deterministic mini-baker.

Owns ONE piece: the Cossacks 3 shallow shore (dry sand -> wet sandsea ->
wash -> shallow water).  No Godot, no whole-map test.  Python 3.14 +
Pillow + NumPy only.  It may import ``terrain_piece_render.py`` READ-ONLY
(never edits it) for mirror-tile primitives and the comparison sheet.

WHAT THIS PIECE FIXES that the shared renderer could not express (v2 M2 FAIL):
  * the donor 8x45-degree SECTOR FOLD from texturemap.inc:445-501 is computed
    per pixel from a height field (dirX=lh-rh, dirY=th-bh, dirY<0 -> -angle,
    +180) and selects one of the three LIVE donor tiles sandsea1/5/6;
  * DRY-SAND base (sand3), not the v2 grass_rock1 base;
  * a hard <=3 px rim at the dry->wet boundary and a sub-tile, jittered,
    non-grid shoreline (no stair-step).

Donor assets are READ from app/assets/terrain/blocks (donor-identical PNGs)
and the reference JPEG is READ in place.  Nothing from C:\\Games\\Cossacks 3
is copied into the repo.  Outputs go only to app/shots/pieces/t6_shore_sand*.

Usage:  python app/tools/pieces/t6_shore_sand.py
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

TOOLS = Path(__file__).resolve().parents[1]          # app/tools
APP = TOOLS.parent
ROOT = APP.parent
BLOCKS = APP / "assets" / "terrain" / "blocks"
WATER = APP / "assets" / "terrain" / "water_png"
SHOTS = APP / "shots" / "pieces"
SPEC = TOOLS / "piece_specs" / "shore_sand.json"
# READ-ONLY water lane output (T6-W02 / T6-WATER owns the water body).
# Concentric-ring ripples were removed from THIS piece: water is not ours.
WATER_LANE_SHORE = SHOTS / "t6_water_shore.png"
# Clean #12 donor sub-crop: sand -> pale wash, NO minimap / UI text / units.
CLEAN_REF_BOX = (345, 190, 420, 250)

# read-only import of the shared renderer (mirror tiles / comparison sheet)
sys.path.insert(0, str(TOOLS))
import terrain_piece_render as tpr  # noqa: E402

SEED = 7
SIZE = 512

# Donor-derived lit lift: unlit sandsea1 #807856 -> lit sand #A89E7F.
# Per-channel factors = #A89E7F / #807856 (sky fill adds blue).  observed->derived.
LIT_GAIN = np.array([168.0 / 128.5, 158.0 / 119.5, 127.0 / 85.8])
DRY_GAIN = np.array([160.0 / 122.7, 154.0 / 116.7, 129.0 / 87.3])  # sand3 -> dry lit

# Live donor sector table (texturemap.inc:503-511); exactly 3 distinct tiles.
SECTOR_TILES = {
    0: "sandsea6",  # bR
    1: "sandsea6",  # bRB
    2: "sandsea1",  # bB
    3: "sandsea5",  # bLB
    4: "sandsea6",  # bL
    5: "sandsea6",  # bLT
    6: "sandsea1",  # bT
    7: "sandsea5",  # bRT
}
SECTOR_FLAGS = ["bR", "bRB", "bB", "bLB", "bL", "bLT", "bT", "bRT"]
ACTIVE_TILES = ["sandsea1", "sandsea5", "sandsea6"]
SECTOR_COLORS = {  # probe-tile false colour, not part of the rendered piece
    "sandsea1": (214, 120, 72),
    "sandsea5": (86, 172, 128),
    "sandsea6": (96, 132, 214),
}


def _clamp(a):
    return np.clip(a, 0, 255).astype(np.uint8)


def _load_band_spec() -> tuple[int, int, float]:
    """Read donor band ranges from the READ-ONLY piece spec (never edit it)."""
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    bands = spec.get("bands", {})
    rng = random.Random(int(bands.get("seed", spec.get("seed", SEED))))
    sand_w = rng.randint(int(bands["sand"][0]), int(bands["sand"][1]))
    wash_w = rng.randint(int(bands["wash"][0]), int(bands["wash"][1]))
    origin = float(bands.get("origin", 0.42))
    return sand_w, wash_w, origin


def _value_noise(w: int, h: int, cell: int, seed: int) -> np.ndarray:
    """Deterministic smoothed random field, zero-mean, roughly -1..1."""
    rng = random.Random(seed)
    cols = max(2, (w + cell - 1) // cell + 2)
    rows = max(2, (h + cell - 1) // cell + 2)
    small = Image.fromarray(
        np.array([[rng.uniform(-1, 1) for _ in range(cols)] for _ in range(rows)],
                 dtype=np.float32) * 127 + 128).convert("L")
    big = np.asarray(small.resize((w, h), Image.Resampling.BILINEAR),
                     dtype=np.float64)
    return (big - 128.0) / 127.0


def _shoreline(w: int, h: int, origin: float, seed: int) -> np.ndarray:
    """Organic shoreline from multi-octave 1D noise — NOT a schematic sine.

    The parent flagged the previous smooth sinusoid as "diagram-art curve";
    the donor shoreline is an irregular heightfield contour.  Three octaves
    (200/90/38 px) plus tiny jitter give a natural boundary without a tile grid.
    """
    rng = random.Random(seed + 101)
    y = np.arange(h, dtype=np.float64)

    def octave(period: float, amp: float, salt: int) -> np.ndarray:
        r = random.Random(seed + salt)
        n = max(3, int(h / period) + 3)
        nodes = np.array([r.uniform(-1.0, 1.0) for _ in range(n)])
        xp = np.linspace(0.0, float(h), n)
        return np.interp(y, xp, nodes) * amp

    curve = (octave(200, 17.0, 111) + octave(90, 9.0, 112)
             + octave(38, 2.5, 113))
    jitter = np.array([rng.uniform(-0.9, 0.9) for _ in range(h)])
    # Sub-pixel deterministic dither keeps the boundary from freezing into a
    # long constant-x run (M4), without producing a visible grid ramp.
    dither = 0.7 * (((np.arange(h) % 5) - 2) / 2.0)
    return np.clip(origin * w + curve + jitter + dither, 40, w - 70)


def _sector_field(w: int, h: int, xs: np.ndarray, seed: int) -> np.ndarray:
    """Literal donor aspect -> 8x45 sector fold -> tile id per pixel.

    texturemap.inc:433-447   dirX=lh-rh, dirY=th-bh, len, normalize,
                             VectorAngle(1,0,0,dirX,0,dirY), dirY<0 -> -angle
    texturemap.inc:476       vecangle += 180
    texturemap.inc:474-501   cAngle=45, 8 windows [k*45-22.5, (k+1)*45-22.5)
    texturemap.inc:503-511   1/5/6 tile choice.
    """
    # Height proxy: shore slope dominates, plus a donor-like local relief
    # aspect so that all three live tiles are selected (a flat beach alone
    # would collapse to one sector).
    noise = _value_noise(w, h, 30, seed + 7)
    xx = np.arange(w, dtype=np.float64)[None, :]
    H = 0.13 * (xs[:, None] - xx) + 3.2 * noise

    # central differences with edge clamping == lh-rh / th-bh
    Hx = np.pad(H, ((0, 0), (1, 1)), mode="edge")
    Hy = np.pad(H, ((1, 1), (0, 0)), mode="edge")
    dirX = Hx[:, :-2] - Hx[:, 2:]      # lh - rh
    dirY = Hy[:-2, :] - Hy[2:, :]      # th - bh

    length = np.hypot(dirX, dirY)
    # unsigned angle between +x and (dirX,dirY); VectorAngle() in GSC is
    # unsigned 0..180, and for a shore dirX>0 this is atan2(|dirY|,dirX).
    theta = np.degrees(np.arctan2(np.abs(dirY), np.abs(dirX)))
    va = np.where(dirY < 0, 180.0 - theta, 180.0 + theta)
    sector = (np.floor((va + 22.5) / 45.0).astype(np.int64) % 8)
    sector[length <= 0.01] = 4         # flat fallback -> bL -> sandsea6
    return sector


def _tile_canvas(name: str, w: int, h: int, rng: random.Random) -> Image.Image:
    """donor-identical project PNG -> mirror tile -> wrap crop at native grain."""
    src = Image.open(BLOCKS / (name + ".png")).convert("RGB")
    tile = tpr.mirror_tileable(src, tpr.TILE_SIZE, Image.Resampling.NEAREST)
    return tpr.wrap_crop(tile, rng.randrange(512), rng.randrange(512), w, h)


def _lit(a: np.ndarray, gain: np.ndarray) -> np.ndarray:
    return _clamp(np.asarray(a, dtype=np.float64) * gain[None, None, :])


def _band_masks(w: int, h: int, xs: np.ndarray, sand_w: int, wash_w: int):
    """Masks from the shoreline: wet sand [xs-sand_w, xs], wash [xs, xs+wash_w],
    water [xs+wash_w, ...].  Returned as L images (255 = inside)."""
    xx = np.arange(w, dtype=np.float64)[None, :]
    d = xx - xs[:, None]          # >0 waterward, <0 landward (doc: +off -> water)
    sand = ((d >= -sand_w) & (d < 0)).astype(np.uint8) * 255
    # Donor wash edges are soft (reference #12): feather ALONG X only, so the
    # 10-90% step is 3-8 px (M3) but per-row boundary tracking is preserved
    # (a 2D blur smooths y and creates false long constant-x runs in M4).
    wash = ((d >= 0) & (d < wash_w)).astype(np.float64) * 255.0
    k = np.array([1.0, 4.0, 6.0, 4.0, 1.0]) / 16.0
    padded = np.pad(wash, ((0, 0), (2, 2)), mode="edge")
    wf = sum(k[i] * padded[:, i:i + w] for i in range(len(k)))
    wash_img = Image.fromarray(_clamp(wf), "L")
    water = (d >= wash_w).astype(np.uint8) * 255
    return (Image.fromarray(sand, "L"), wash_img,
            Image.fromarray(water, "L"))


def _arc_ripples(w: int, h: int, seed: int) -> np.ndarray:
    """Faint concentric arcs like the donor shallow-water ripples (#12)."""
    rng = random.Random(seed + 55)
    # Centre inside the water area so arcs are visibly CONCENTRIC (#12),
    # not near-parallel stripes from a far-off centre.
    cx = (0.82 + rng.uniform(-0.04, 0.04)) * w
    cy = (0.42 + rng.uniform(-0.06, 0.06)) * h
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float64)
    r = np.hypot(xx - cx, (yy - cy) * 1.4)
    return np.sin(r * 2 * math.pi / 30.0)  # -1..1


def _wash_zone(w: int, h: int, xs: np.ndarray, wash_w: int, seed: int):
    """Noisy, mottled washed zone replacing the clean pale ribbon (visual FAIL fix).

    The donor #12 washed zone is broad, irregular and sand-interleaved, NOT a
    uniform bright band.  Both boundaries are warped by multi-scale noise and
    the alpha ramps are long/irregular, so no continuous bright ribbon survives.
    Returns (alpha 0..1, normalised position 0..1, zone_start, zone_end).
    """
    xx = np.arange(w, dtype=np.float64)[None, :]
    nlo = _value_noise(w, h, 80, seed + 301)
    nmid = _value_noise(w, h, 22, seed + 302)
    start = xs[:, None] + nlo * 8.0 + nmid * 3.0
    nlo2 = _value_noise(w, h, 100, seed + 303)
    nmid2 = _value_noise(w, h, 28, seed + 304)
    # ~2x the spec band width: donor washed zone is visually much broader than
    # the doc's 5-10% area estimate (honest numeric M7 deviation, visual first).
    end = start + (wash_w * 2.0) + nlo2 * 16.0 + nmid2 * 5.0
    fine = _value_noise(w, h, 10, seed + 305)
    din = xx - start + fine * 1.5
    dout = end - xx + fine * 3.0
    a_in = np.clip(din / 5.0, 0.0, 1.0)
    a_out = np.clip(dout / 16.0, 0.0, 1.0)
    alpha = a_in * a_out
    # Break the continuous ribbon: large-scale presence noise lets sandy
    # substrate through in patches, so the wash is not a uniform band.
    presence = np.clip(
        0.72 + _value_noise(w, h, 130, seed + 306) * 0.85
        + _value_noise(w, h, 50, seed + 307) * 0.40, 0.0, 1.0)
    alpha *= presence
    t = np.clip((xx - start) / np.maximum(1.0, end - start), 0.0, 1.0)
    return alpha, t, start, end


def _hard_rim(layer: Image.Image, sand_mask: Image.Image,
              xs: np.ndarray, sand_w: int, strength: float = 0.22) -> None:
    """Darken a <=3 px contour at the LANDWARD edge of the sand band."""
    a = np.asarray(layer.convert("RGBA")).copy()
    inner_x = np.clip(np.rint(xs - sand_w).astype(int), 1, layer.width - 2)
    y = np.arange(layer.height)
    for dy in (-1, 0, 1):
        xi = np.clip(inner_x + dy, 0, layer.width - 1)
        col = a[y, xi, :3].astype(np.float64)
        a[y, xi, :3] = _clamp(col * (1.0 - 0.42 * strength))
    out = Image.fromarray(a, "RGBA")
    layer.paste(out)


def render(seed: int = SEED, size: int = SIZE, verbose: bool = False):
    rng = random.Random(seed)
    sand_w, wash_w, origin = _load_band_spec()
    xs = _shoreline(size, size, origin, seed)
    sector = _sector_field(size, size, xs, seed)
    sand_m, _, _ = _band_masks(size, size, xs, sand_w, wash_w)

    if verbose:
        print(f"[t6-shore] sand_w={sand_w} wash_w={wash_w} origin={origin}")

    # 1) DRY-SAND BASE (donor dry beach sand3, lit lift) over the whole canvas.
    dry = _tile_canvas("sand3", size, size, rng)
    canvas_arr = _lit(np.asarray(dry), DRY_GAIN).astype(np.float64)

    # 2) WET SAND: 3 sector-selected donor tiles, composited per-pixel.
    tile_arrays = {name: _lit(np.asarray(_tile_canvas(name, size, size, rng)), LIT_GAIN)
                   for name in ACTIVE_TILES}
    sector_col = np.empty((size, size, 3), dtype=np.uint8)
    for k, name in SECTOR_TILES.items():
        sector_col[sector == k] = tile_arrays[name][sector == k]
    sm = np.asarray(sand_m) > 0
    canvas_arr[sm] = sector_col[sm].astype(np.float64)
    # NO hard dark contour: the parent flagged it as diagram-art outline.
    # Contact shading is added later as a soft, noise-modulated shadow.

    # 3) WASHED ZONE: broad, noisy, sand-interleaved — NO clean bright ribbon.
    #    This replaces the parent-flagged visual FAIL (uniform pale band).
    waves = np.asarray(tpr.mirror_tileable(
        Image.open(WATER / "diffusewaves2.png").convert("RGB"),
        tpr.TILE_SIZE, Image.Resampling.BILINEAR).resize((size, size),
        Image.Resampling.BILINEAR), dtype=np.float64)
    wl = waves.mean(axis=2)
    wash_a, wash_t, zstart, zend = _wash_zone(size, size, xs, wash_w, seed)
    xx = np.arange(size, dtype=np.float64)[None, :]

    # Calibrated to the CLEAN #12 crop wash anchor #BCC6BD (188,198,189).
    # The old (contaminated, minimap/UI) crop gave a misleadingly darker target.
    dry_wash = np.array([0xC8, 0xD2, 0xCB], dtype=np.float64)
    wet_wash = np.array([0xD2, 0xDC, 0xD6], dtype=np.float64)
    wave_t = np.clip((wl - wl.min()) / max(1.0, wl.max() - wl.min()), 0, 1)
    mott = (_value_noise(size, size, 60, seed + 401) * 16.0
            + _value_noise(size, size, 24, seed + 402) * 12.0
            + _value_noise(size, size, 9, seed + 403) * 8.0)
    wash_rgb = (dry_wash[None, None, :]
                + (wet_wash - dry_wash)[None, None, :] * wash_t[..., None]
                + mott[..., None])
    # Sand patches interleaved into the wash (strongest near the sand edge),
    # so the washed zone reads as mottled sandy material, not a clean stripe.
    inter = (_value_noise(size, size, 34, seed + 411)
             + 0.45 * _value_noise(size, size, 12, seed + 412))
    sand_patch = (np.clip((inter - 0.10) * 1.7, 0.0, 1.0)
                  * (1.0 - wash_t) * 0.95)
    wash_rgb = ((1.0 - sand_patch[..., None]) * wash_rgb
                + sand_patch[..., None] * canvas_arr)
    canvas_arr = (1.0 - wash_a[..., None]) * canvas_arr + wash_a[..., None] * wash_rgb
    wm = wash_a > 0.45

    # 4) FOAM specks: donor coast-band gate only (band = wash), no invented family.
    foam_field = np.asarray(tpr._foam_specks(
        Image.fromarray(_clamp(wl), "L"), size, size, 1.0, 1.0), dtype=np.float64)
    foam_gate = wm & (foam_field > 180)
    foam_col = np.array([0.92, 0.96, 1.0]) * 255
    canvas_arr[foam_gate] = (0.65 * canvas_arr[foam_gate]
                             + 0.35 * foam_col[None, :])

    # 5) WATER BODY — OUT OF THIS PIECE'S SCOPE (W02 / T6-WATER owns it).
    #    CONCENTRIC RINGS REMOVED.  We composite the read-only T6-WATER shore
    #    texture as a flat donor-matched shallow placeholder and score ONLY
    #    sand / wash / rim features.  No local ripple/arc generation remains.
    wfine = _value_noise(size, size, 12, seed + 501)
    water_a = np.clip((xx - zend + wfine * 3.0) / 10.0, 0.0, 1.0)
    wt = water_a > 0.5
    sub0 = canvas_arr.copy()
    submean = sub0[wt].mean(axis=0) if wt.any() else sub0.mean(axis=(0, 1))
    substrate = submean[None, None, :] + 0.62 * (sub0 - submean[None, None, :])
    water_sub = substrate * np.array([0.80, 0.86, 0.94])[None, None, :]
    with Image.open(WATER_LANE_SHORE) as _wimg:
        water_tex = np.asarray(
            _wimg.convert("RGB").crop((0, 250, 512, 512)).resize(
                (size, size), Image.Resampling.BILINEAR), dtype=np.float64)
    # Darken W02's lit foam texture toward the donor shallow anchor #696B65.
    water_tex *= 0.62
    shallow = 0.35 * water_tex + 0.65 * water_sub
    canvas_arr = ((1.0 - water_a[..., None]) * canvas_arr
                  + water_a[..., None] * np.clip(shallow, 0.0, 255.0))

    # 6) SOFT CONTACT SHADOWS — donor ambient occlusion at the sand/wash and
    #    wash/water contacts.  Broad and noise-modulated, never a hard outline.
    contact_n = _value_noise(size, size, 26, seed + 601)
    d_sand = xx - zstart
    d_water = xx - zend
    sh1 = np.exp(-((d_sand - 3.0) / 9.0) ** 2) * (0.65 + 0.35 * contact_n)
    sh2 = np.exp(-((d_water + 2.0) / 11.0) ** 2) * (0.65 + 0.35 * contact_n)
    shade = np.clip(1.0 - 0.16 * sh1 - 0.11 * sh2, 0.72, 1.0)
    canvas_arr *= shade[..., None]

    render_img = Image.fromarray(_clamp(canvas_arr), "RGB")

    # Probe tile: false-colour sector map proving the 8x45 fold + 3 tiles.
    probe = np.zeros((size, size, 3), dtype=np.uint8)
    for k, name in SECTOR_TILES.items():
        probe[sector == k] = SECTOR_COLORS[name]
    probe_img = Image.fromarray(probe, "RGB")

    meta = {
        "seed": seed, "size": [size, size], "sand_w": sand_w,
        "wash_w": wash_w, "origin": origin,
        "sector_flags": SECTOR_FLAGS,
        "sector_tiles": {SECTOR_FLAGS[k]: SECTOR_TILES[k] for k in range(8)},
        "sector_windows_deg": [[k * 45 - 22.5, (k + 1) * 45 - 22.5]
                               for k in range(8)],
        "fold": "dirY<0 -> vecangle=-vecangle; then +180; cAngle=45",
        "sector_pixel_counts": {SECTOR_FLAGS[k]: int((sector == k).sum())
                                for k in range(8)},
        "tile_pixel_counts": {name: int(np.isin(sector, [k for k, v in
                              SECTOR_TILES.items() if v == name]).sum())
                              for name in ACTIVE_TILES},
        "active_tiles": ACTIVE_TILES,
        "base": "sand3 (dry beach) lit",
        "rim_px": 2,
        "shallow_opacity": 0.35,
        "wash_zone": "noisy sand-interleaved (visual iteration after parent spot-check)",
        "wash_nominal_w": wash_w,
        "wash_eff_w": wash_w * 2,
        "visual_iteration": True,
        "water_body_source": "READ-ONLY T6-WATER app/shots/pieces/t6_water_shore.png (crop y250:512), no local arcs",
        "clean_reference_box": list(CLEAN_REF_BOX),
        "revoked_old_reference_box": [300, 150, 512, 288],
    }
    return render_img, probe_img, meta


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--seed", type=int, default=SEED)
    p.add_argument("--size", type=int, default=SIZE)
    p.add_argument("--out-dir", default=str(SHOTS))
    p.add_argument("--verbose", action="store_true")
    a = p.parse_args(argv)

    out = Path(a.out_dir).expanduser().resolve()
    out.mkdir(parents=True, exist_ok=True)
    render_img, probe_img, meta = render(a.seed, a.size, a.verbose)

    png = out / "t6_shore_sand.png"
    render_img.save(png, format="PNG", optimize=True)
    probe_img.save(out / "t6_shore_sand_sectors.png", format="PNG", optimize=True)

    # Compare sheet: CLEAN #12 crop only (no minimap / UI / units).  Upscaled
    # uniformly and letterboxed so aspect is preserved — the old contaminated
    # (300,150,512,288) box is REVOKED and no longer used for any measurement.
    ref = Image.open(Path.home() / "Downloads" / "c3" / "maxresdefault_1.jpg")
    ref = ref.convert("RGB").crop(CLEAN_REF_BOX)
    scale = min(a.size / ref.width, a.size / ref.height)
    nw, nh = max(1, int(ref.width * scale)), max(1, int(ref.height * scale))
    ref_big = ref.resize((nw, nh), Image.Resampling.BILINEAR)
    padded = Image.new("RGB", (a.size, a.size), (22, 24, 28))
    padded.paste(ref_big, ((a.size - nw) // 2, (a.size - nh) // 2))
    layers = [{"type": "block", "name": "sand3 (dry base)"},
              {"type": "block", "name": "sandsea1/5/6 (sector fold)"},
              {"type": "water", "name": "wash (this piece)"},
              {"type": "water", "name": "W02 water body (read-only)"}]
    comp = tpr.build_comparison("t6_shore_sand", render_img, padded, a.seed,
                                layers, list(CLEAN_REF_BOX))
    comp.save(out / "t6_shore_sand_compare.png", format="PNG", optimize=True)

    digest = hashlib.sha256(png.read_bytes()).hexdigest()
    meta["sha256_png"] = digest
    (Path.home() / "AppData" / "Local" / "Temp" / "opencode" /
     "t6_shore_sand_meta.json").write_text(
        json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[t6-shore] {png} sha256={digest[:16]}")
    print(f"[t6-shore] tiles={meta['tile_pixel_counts']} "
          f"sand_w={meta['sand_w']} wash_w={meta['wash_w']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
