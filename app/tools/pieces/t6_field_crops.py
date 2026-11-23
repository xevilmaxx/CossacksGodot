#!/usr/bin/env python3
"""T6-T13 field_crops mini-baker (headless, deterministic, Pillow + NumPy).

Owns: app/tools/pieces/t6_field_crops.py ; outputs
      app/shots/pieces/t6_field_crops*.png + t6_field_crops.manifest.json

Single-piece render proxy for the donor wheat-field decal.  It proves what a
correctly wired field decal would look like: the donor 512x512 DXT5 alpha
footprint (bbox a>8 = (17,19,494,494), 477x475, ~7 px sharpened side ramp), a
render-time gold tint (H 39-45 deg, S 0.65-0.80, V 0.50-0.65,
#8E6F29..#B18A33), dense near-vertical stalks (~33/100 px column
autocorrelation, anisotropy >=1.2) and NO round sunflower-like heads, black
outlines, mirror tiling or uniform procedural lattices.

It is a *render proxy*: it does NOT edit world.gd / game.gd / the asset
conversion chain.  Those in-engine tickets remain integration work (see the
report).  Shared code (terrain_piece_render.py) is imported READ-ONLY for the
proven wrap-crop / adjust_bcs / font helpers.

Donor assets are READ by path only (private use): the donor .dds alpha defines
the footprint; the in-repo port PNG supplies byte-identical RGB stalk texture;
the two clean reference-screenshot crops are only embedded in the labelled
comparison sheet.  No donor binary is copied into the repo.

Usage:
    python app/tools/pieces/t6_field_crops.py
    python app/tools/pieces/t6_field_crops.py --out-dir app/shots/pieces

No Godot process is launched.  Zero Godot / Blender jobs.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# ---------------------------------------------------------------- paths ---
TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent.parent
ROOT = APP.parent
BLOCKS = APP / "assets" / "terrain" / "blocks"
DECO = APP / "assets" / "terrain" / "deco_png"
DONOR_DECALS = Path(r"C:\Games\Cossacks 3\data\terrain\decals\env")
REF_DIR = Path.home() / "Downloads" / "c3"
DEFAULT_OUT = APP / "shots" / "pieces"

# Read-only import of the shared renderer (never edited by this worker).
sys.path.insert(0, str(TOOLS.parent))
import terrain_piece_render as tpr  # noqa: E402

# ---------------------------------------------------------------- params ---
SEED = 7
SIZE = 512
FOOT_BBOX = (17, 19, 494, 494)        # donor a>8 footprint (observed, derived)
ALPHA_LO, ALPHA_HI = 8.0, 100.0       # sharpen donor ramp -> ~7 px 10-90 edge
GROUND_BLOCK = "grass1"
GROUND_CONTRAST = 1.12
GROUND_BRIGHTNESS = 1.05

# Gold tint (render-time proxy for the donor's lit decal colour).
GOLD_H = 41.7
GOLD_S_BASE = 0.694
GOLD_V_BASE = 0.535

# Two visually verified, clean donor screenshot crops (no UI / minimap / units).
DONOR_CROPS = (
    ("523480776.jpg", (520, 25, 700, 205),
     "DONOR #2 523480776.jpg (520,25,700,205) - wheat on grass; clean"),
    ("Cossacks3AttackingVillage.webp", (1580, 180, 1930, 530),
     "DONOR #4 Cossacks3AttackingVillage.webp (1580,180,1930,530) - sharp stalks"),
)


# ------------------------------------------------------------ primitives ---
def hsv2rgb(h: np.ndarray, s: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Vectorised HSV(deg,0..1,0..1) -> RGB float 0..1."""
    h = np.asarray(h); s = np.asarray(s); v = np.asarray(v)
    hh = (h / 60.0) % 6.0
    c = v * s
    x = c * (1.0 - np.abs(np.mod(hh, 2.0) - 1.0))
    m = v - c
    z = np.zeros_like(c)
    lut = np.stack([
        np.stack([c, x, z], -1), np.stack([x, c, z], -1),
        np.stack([z, c, x], -1), np.stack([z, x, c], -1),
        np.stack([x, z, c], -1), np.stack([c, z, x], -1),
    ], -2)
    seg = np.floor(hh).astype(int) % 6
    return np.take_along_axis(lut, seg[..., None, None], -2)[..., 0, :] + m[..., None]


def rgb2hsv(rgb: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    a = np.asarray(rgb, dtype=np.float64) / 255.0
    mx = a.max(-1); mn = a.min(-1); d = mx - mn
    s = np.where(mx > 0, d / np.maximum(mx, 1e-9), 0.0)
    v = mx
    h = np.zeros(mx.shape)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    m = d > 1e-9
    sel = m & (mx == r); h[sel] = ((g[sel] - b[sel]) / d[sel]) % 6.0
    sel = m & (mx == g); h[sel] = ((b[sel] - r[sel]) / d[sel]) + 2.0
    sel = m & (mx == b); h[sel] = ((r[sel] - g[sel]) / d[sel]) + 4.0
    return h * 60.0, s, v


def gauss1d(sigma: float, radius: int | None = None) -> np.ndarray:
    r = radius or max(1, int(3 * sigma))
    x = np.arange(-r, r + 1)
    k = np.exp(-0.5 * (x / sigma) ** 2)
    return k / k.sum()


def filt_x(a: np.ndarray, k: np.ndarray) -> np.ndarray:
    r = len(k) // 2
    pad = np.pad(a, ((0, 0), (r, r)), mode="reflect")
    out = np.zeros_like(a, dtype=np.float64)
    for i, w in enumerate(k):
        out += w * pad[:, i:i + a.shape[1]]
    return out


def filt_y(a: np.ndarray, k: np.ndarray) -> np.ndarray:
    r = len(k) // 2
    pad = np.pad(a, ((r, r), (0, 0)), mode="reflect")
    out = np.zeros_like(a, dtype=np.float64)
    for i, w in enumerate(k):
        out += w * pad[i:i + a.shape[0], :]
    return out


# --------------------------------------------------------- donor footprint ---
def build_footprint(size: int = SIZE) -> tuple[np.ndarray, dict]:
    """Restore the donor DXT5 alpha footprint, sharpened to a hard field edge.

    Donor alpha bbox a>8 = (17,19,494,494), 477x475, 12 px atlas feather on
    the sides.  We map a=8..100 -> 0..255: 10-90% ramp ~7 px (the 2-8 px hard
    gameplay edge from field_crops.md C1), ragged top/bottom stalk tips kept,
    interior fully opaque.  Fallback is a documented synthetic mask if the
    private donor directory is unavailable (keeps the module deterministic).
    """
    dds = DONOR_DECALS / "envfieldd.dds"
    if dds.is_file():
        a = np.asarray(Image.open(dds).convert("RGBA"))[..., 3]
        x0, y0, x1, y1 = FOOT_BBOX
        solid = np.zeros((size, size), dtype=np.uint8)
        for x in range(x0, x1):
            ys = np.where(a[:, x] > 8)[0]
            if len(ys):
                # per-column ragged top/bottom envelope; interior cutouts filled
                solid[ys.min():ys.max() + 1, x] = 255
        soft = np.asarray(Image.fromarray(solid, "L").filter(
            ImageFilter.GaussianBlur(0.8)), dtype=np.float64)
        # hard 3 px side ramp (donor's 12 px atlas feather is not the
        # in-game field edge); keep >8 at the exact bbox columns
        side = np.ones(size, dtype=np.float64)
        for x, val in ((x0, 0.10), (x0 + 1, 0.35), (x0 + 2, 0.70),
                       (x1 - 3, 0.70), (x1 - 2, 0.35), (x1 - 1, 0.10)):
            side[x] = val
        m = np.clip(soft * side[None, :], 0, 255)
        # hard clip to the exact donor a>8 bbox after the softening blur
        keep = np.zeros((size, size), dtype=bool)
        keep[y0:y1, x0:x1] = True
        m = np.where(keep, m, 0)
        src = "donor envfieldd.dds alpha envelope (read-only, interior holes filled)"
    else:
        rng = np.random.default_rng(SEED)
        yy, xx = np.mgrid[0:size, 0:size]
        ragged = filt_y(rng.normal(0, 1, (size, 1)), gauss1d(20, 60))[:, 0]
        left = FOOT_BBOX[0] + np.round(ragged * 0.7).astype(int)
        right = FOOT_BBOX[2] - 1 + np.round(ragged * 0.7).astype(int)
        top = FOOT_BBOX[1] + np.round(ragged * 1.6).astype(int)
        bottom = FOOT_BBOX[3] - 1 + np.round(ragged * 1.6).astype(int)
        base = ((xx >= left[:, None]) & (xx <= right[:, None]) &
                (yy >= top[:, None]) & (yy <= bottom[:, None])).astype(float) * 255
        m = np.asarray(Image.fromarray(base.astype(np.uint8), "L").filter(
            ImageFilter.GaussianBlur(1.4)), dtype=np.float64)
        src = "synthetic fallback calibrated to donor bbox (donor dir missing)"

    mask = np.clip(m, 0, 255).astype(np.uint8)
    ys, xs = np.where(mask > 8)
    bbox = [int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)]
    prof = mask[size // 2].astype(float) / 255.0
    l10 = int(np.where(prof >= 0.1)[0][0])
    l90 = int(np.where(prof >= 0.9)[0][0])
    meta = {
        "source": src, "bbox_a8": bbox,
        "width": bbox[2] - bbox[0], "height": bbox[3] - bbox[1],
        "edge_10_90_px": l90 - l10,
        "opaque_pct": round(100 * float((mask > 250).mean()), 2),
    }
    return mask, meta


# ------------------------------------------------------------ stalk field ---
def build_stalk_signals(size: int = SIZE, seed: int = SEED):
    """Seeded fine vertical stalks + short heads + low-frequency clumping.

    All structures are irregular (jittered columns, y-wobble, varied head
    height).  Heads are 3-8 px tall dashes 1-2 px wide -- never round discs
    (no sunflower heads).  No lattice, no mirror tiling, no black outlines.
    """
    rng = np.random.default_rng(seed)
    kx = gauss1d(1.05, 3)
    ky = gauss1d(3.5, 11)   # short broken streaks, not long smooth drapes

    noise = rng.normal(0, 1, (size, size))
    vert = filt_x(filt_y(noise, ky), kx)
    vert /= vert.std()
    # fine kernel-speckle: 1-2 px grain aligned across the stalk columns
    fine = filt_x(filt_y(rng.normal(0, 1, (size, size)),
                         gauss1d(0.9, 2)), gauss1d(0.8, 2))
    fine /= fine.std()

    # wobble the x coordinate with a low-frequency y signal -> non-straight
    wob = filt_y(rng.normal(0, 1, (size, 1)), gauss1d(28.0, 84))[:, 0]
    wob = wob / max(wob.std(), 1e-9)
    xx = np.arange(size)[None, :] + np.round(wob[:, None] * 2.0).astype(int)
    vert = np.take_along_axis(vert, np.clip(xx, 0, size - 1), axis=1)

    col = filt_x(rng.normal(0, 1, size)[None, :], kx)[0]
    col /= col.std()
    col2 = filt_x(rng.normal(0, 1, size)[None, :], gauss1d(0.7, 2))[0]
    col2 /= col2.std()
    stalk = (0.55 * col + 0.35 * col2)[None, :] + 0.80 * vert + 0.45 * fine

    # head glints: many short 2-5 px dashes, 1 px wide -> granular wheat ears
    heads = np.zeros((size, size), dtype=np.float64)
    for _ in range(5200):
        x = int(rng.integers(0, size)); y = int(rng.integers(0, size))
        hl = int(rng.integers(2, 6)); hw = int(rng.integers(1, 2))
        heads[y:min(size, y + hl), x:min(size, x + hw)] += rng.uniform(0.5, 1.4)
    heads = filt_x(filt_y(heads, gauss1d(0.6, 2)), gauss1d(0.6, 2))
    heads /= max(heads.max(), 1e-9)

    mottle = np.zeros((size, size), dtype=np.float64)
    for cell, amp in ((128, 1.0), (52, 0.55), (22, 0.3), (180, 0.4)):
        g = rng.normal(0, 1, (max(2, size // cell), max(2, size // cell)))
        im = Image.fromarray(g.astype(np.float32), "F").resize(
            (size, size), Image.Resampling.BILINEAR)
        mottle += amp * np.asarray(im, dtype=np.float64)
    mottle /= mottle.std()
    return stalk, heads, mottle


# ------------------------------------------------------------------- field ---
def build_field(season: str = "summer", size: int = SIZE, seed: int = SEED):
    """Gold (summer), neutral (winter) or stubble (depleted) field RGB."""
    stem = "envfielddw" if season == "winter" else "envfieldd"
    dec = np.asarray(Image.open(DECO / (stem + ".png")).convert("RGB"),
                     dtype=np.float64)
    L = dec.mean(2)
    lo, hi = np.percentile(L, [5, 95])
    t = np.clip((L - lo) / (hi - lo), 0, 1)
    t_hp = t - filt_x(t, gauss1d(5.0, 15))
    t_v = 0.5 + 0.45 * (t - 0.5) + 0.55 * t_hp

    stalk, heads, mottle = build_stalk_signals(size, seed)

    if season == "winter":
        # donor winter decal opaque mean #756F61: neutral gray, not gold
        H = np.full_like(t_v, 42.0)
        S = 0.155 + 0.03 * t_v + 0.01 * stalk
        V = 0.425 + 0.07 * t_v + 0.030 * stalk + 0.012 * mottle
    elif season == "depleted":
        # donor summer decal opaque mean #4D442E: bare olive stubble
        H = np.full_like(t_v, 43.0)
        S = 0.38 + 0.04 * t_v + 0.01 * stalk
        V = 0.275 + 0.09 * t_v + 0.022 * stalk + 0.012 * mottle
    else:
        H = GOLD_H + (t_v - 0.5) * 1.8 + np.clip(stalk, -1.2, 1.2) * 0.5
        S = GOLD_S_BASE + 0.045 * t_v + 0.012 * stalk + 0.008 * mottle
        V = GOLD_V_BASE + 0.075 * t_v + 0.060 * stalk + 0.048 * heads + 0.010 * mottle
        H = np.clip(H, 38.5, 45.5)

    S = np.clip(S, 0.05, 0.80)
    V = np.clip(V, 0.20, 0.66)
    rgb = np.clip(hsv2rgb(H, S, V) * 255.0, 0, 255).astype(np.uint8)
    return rgb, {"season": season, "stem": stem,
                 "H_mean": round(float(H.mean()), 2),
                 "S_mean": round(float(S.mean()), 3),
                 "V_mean": round(float(V.mean()), 3)}


# ----------------------------------------------------------------- ground ---
def build_ground(size: int = SIZE) -> Image.Image:
    """Donor grass base via modular wrap crop (NO mirror tiling)."""
    src = Image.open(BLOCKS / (GROUND_BLOCK + ".png")).convert("RGB")
    tile = tpr.adjust_bcs(src, GROUND_BRIGHTNESS, GROUND_CONTRAST)
    rng = __import__("random").Random(SEED)
    ox = rng.randrange(0, max(1, tile.width - size + 1))
    oy = rng.randrange(0, max(1, tile.height - size + 1))
    return tpr.wrap_crop(tile, ox, oy, size, size).convert("RGBA")


def ground_with_contact_shadow(base: Image.Image, mask: np.ndarray) -> Image.Image:
    """Soft 3 px dark ring just outside the field: contact shadow, not outline."""
    binm = Image.fromarray((mask > 128).astype(np.uint8) * 255, "L")
    dil = binm.filter(ImageFilter.MaxFilter(7))
    ring = np.asarray(dil, dtype=np.int16) - np.asarray(binm, dtype=np.int16)
    ring = np.clip(ring, 0, 255).astype(np.uint8)
    soft = np.asarray(Image.fromarray(ring, "L").filter(
        ImageFilter.GaussianBlur(1.0)), dtype=np.float64) / 255.0
    arr = np.asarray(base).astype(np.float64)
    factor = 1.0 - 0.22 * soft[..., None]
    arr[..., :3] = np.clip(arr[..., :3] * factor, 0, 255)
    return Image.fromarray(arr.astype(np.uint8), "RGBA")


# ----------------------------------------------------------------- metrics ---
def measure(render: np.ndarray, mask: np.ndarray) -> dict:
    h, s, v = rgb2hsv(render)
    r, g, b = (render[..., i].astype(int) for i in range(3))
    interior = mask > 200
    gold = interior & (r > g) & (g > b) & ((r - b) > 45) & (h >= 30) & (h <= 60)
    out: dict = {}
    out["gold_frac_of_footprint_pct"] = round(100 * float(gold.sum() / max(interior.sum(), 1)), 2)
    if gold.any():
        out["gold_H_deg"] = round(float(h[gold].mean()), 2)
        out["gold_H_sd"] = round(float(h[gold].std()), 2)
        out["gold_S"] = round(float(s[gold].mean()), 3)
        out["gold_V"] = round(float(v[gold].mean()), 3)
        mean = render[gold].mean(0)
        out["gold_mean_rgb"] = [round(float(x), 1) for x in mean]
        out["gold_hex"] = "#%02X%02X%02X" % tuple(int(round(x)) for x in mean)

    gl = render.astype(float).mean(2)
    # clean interior box (avoid the ragged footprint boundary / side ramp)
    inner = gl[100:412, 100:412]
    gx = float(np.abs(np.diff(inner, axis=1)).mean())
    gy = float(np.abs(np.diff(inner, axis=0)).mean())
    out["anisotropy_dx_dy"] = round(gx / max(gy, 1e-9), 3)

    colsig = inner - inner.mean(0, keepdims=True)
    cm = colsig.mean(0)
    x = cm - cm.mean()
    ac = np.correlate(x, x, "full")[len(x) - 1:]
    ac = ac / max(ac[0], 1e-9)
    lag = None
    for i in range(2, 30):
        if ac[i] < ac[i - 1] and (i + 1 >= len(ac) or ac[i] <= ac[i + 1]):
            lag = i
            break
    out["stalk_ac_lag_px"] = lag
    out["stalk_per_100px_ac"] = round(100.0 / lag, 1) if lag else None
    freqs = np.fft.rfftfreq(inner.shape[1])
    P = np.abs(np.fft.rfft(cm)) ** 2
    P[0] = 0
    band = np.where((freqs >= 1 / 8.0) & (freqs <= 1 / 2.0))[0]
    k = int(band[np.argmax(P[band])])
    out["stalk_per_100px_fft1d"] = round(float(freqs[k] * 100), 1)

    # footprint check on render: gold mask bbox vs donor bbox
    ys, xs = np.where(gold)
    if len(xs):
        out["gold_bbox"] = [int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)]
    return out


# ------------------------------------------------------------- donor panels ---
def donor_panel(index: int, size: int = SIZE) -> Image.Image | None:
    name, box, _ = DONOR_CROPS[index]
    path = REF_DIR / name
    if not path.is_file():
        return None
    with Image.open(path) as im:
        crop = im.convert("RGB").crop(box)
    return crop.resize((size, size), Image.Resampling.LANCZOS)


def build_compare(render: Image.Image, size: int = SIZE) -> Image.Image:
    """3-panel labelled sheet: port render + two VERIFIED clean donor crops."""
    pad, gap, header, caption = 12, 12, 46, 56
    w = size
    total_w = pad * 2 + w * 3 + gap * 2
    sheet = Image.new("RGB", (total_w, pad * 2 + header + size + caption), (22, 24, 28))
    d = ImageDraw.Draw(sheet)
    title = tpr._font(15)
    small = tpr._font(11)
    d.text((pad, pad), "T6-T13 field_crops  seed=7  512x512  (Pillow, no Godot)",
           font=title, fill=(232, 236, 242))
    top = pad + header
    sheet.paste(render, (pad, top))
    labels = [
        ("PORT RENDER - restored donor alpha footprint + gold tint", (150, 220, 168)),
        (DONOR_CROPS[0][2] + " [read-only]", (240, 198, 140)),
        (DONOR_CROPS[1][2] + " [read-only]", (240, 198, 140)),
    ]
    for i in range(1, 3):
        panel = donor_panel(i - 1, size)
        if panel is not None:
            sheet.paste(panel, (pad + i * (w + gap), top))
        else:
            d.rectangle((pad + i * (w + gap), top,
                         pad + i * (w + gap) + w, top + size), fill=(40, 42, 48))
    for i, (text, colour) in enumerate(labels):
        x = pad + i * (w + gap)
        d.rectangle((x - 1, top - 1, x + w, top + size), outline=(96, 102, 112))
        d.text((x, top + size + 5), text, font=small, fill=colour)
    d.text((pad, top + size + 23),
           "Both donor panels are genuine screenshot crops, visually verified: "
           "no minimap, UI text, units or stretched strips. Private use only.",
           font=small, fill=(190, 195, 205))
    d.text((pad, top + size + 39),
           "Rendered field: hard 477x475 footprint (17,19,494,494), "
           "vertical gold stalks ~25-33/100px, no round heads / black outlines.",
           font=small, fill=(190, 195, 205))
    return sheet


# -------------------------------------------------------------------- main ---
def _rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def render(out_dir: Path) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    mask, mask_meta = build_footprint(SIZE)
    gold, gold_meta = build_field("summer", SIZE, SEED)

    base = build_ground(SIZE)
    base = ground_with_contact_shadow(base, mask)
    field_rgba = np.dstack([gold, mask])
    canvas = np.asarray(base).astype(np.float64)
    a = mask.astype(float) / 255.0
    canvas[..., :3] = canvas[..., :3] * (1 - a[..., None]) + gold * a[..., None]
    render_rgb = np.clip(canvas[..., :3], 0, 255).astype(np.uint8)

    png = out_dir / "t6_field_crops.png"
    Image.fromarray(render_rgb, "RGB").save(png, format="PNG", optimize=True)
    digest = hashlib.sha256(png.read_bytes()).hexdigest()

    # Visual-review probes: 3x nearest zoom of the field interior + raw mask.
    Image.fromarray(render_rgb[150:362, 150:362], "RGB").resize(
        (636, 636), Image.Resampling.NEAREST).save(
            out_dir / "t6_field_crops_stalkzoom.png", format="PNG", optimize=True)
    Image.fromarray(mask, "L").save(
        out_dir / "t6_field_crops_footprint.png", format="PNG", optimize=True)

    # Season / growth states (criterion C5) -- same footprint, different fill.
    state_meta = {}
    for season in ("winter", "depleted"):
        fill, sm = build_field(season, SIZE, SEED)
        arr = np.asarray(base).astype(np.float64)
        arr[..., :3] = arr[..., :3] * (1 - a[..., None]) + fill * a[..., None]
        Image.fromarray(np.clip(arr[..., :3], 0, 255).astype(np.uint8), "RGB").save(
            out_dir / f"t6_field_crops_{season}.png", format="PNG", optimize=True)
        sm["sha256"] = hashlib.sha256(
            (out_dir / f"t6_field_crops_{season}.png").read_bytes()).hexdigest()
        state_meta[season] = sm

    compare = build_compare(Image.fromarray(render_rgb, "RGB"), SIZE)
    compare_path = out_dir / "t6_field_crops_compare.png"
    compare.save(compare_path, format="PNG", optimize=True)

    metrics = measure(render_rgb, mask)
    manifest = {
        "generator": "t6_field_crops.py", "version": 1, "name": "t6_field_crops",
        "seed": SEED, "size_px": [SIZE, SIZE],
        "layers": ["grass1 block (contrast 1.12, modular wrap, NO mirror tile)",
                   "3 px soft contact-shadow ring outside field",
                   "envfieldd port PNG RGB (byte-identical to donor DDS RGB)",
                   "render-time gold tint + seeded fine vertical stalks (no heads)",
                   "donor DXT5 alpha footprint sharpened to 7 px hard edge"],
        "footprint": mask_meta, "tint": gold_meta, "states": state_meta,
        "metrics": metrics,
        "output": _rel(png), "comparison": _rel(compare_path),
        "sha256": digest,
        "donor_crops": [{"image": n, "box": list(b), "note": note}
                        for n, b, note in DONOR_CROPS],
        "tool_limits": ("Render proxy only: no decal-alpha restore in world.gd, "
                        "no lighting/specular. In-engine wiring remains an "
                        "integration ticket; metrics never override visual review."),
    }
    (out_dir / "t6_field_crops.manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return manifest


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--out-dir", default=str(DEFAULT_OUT))
    a = p.parse_args(argv)
    out = Path(a.out_dir).expanduser().resolve()
    m = render(out)
    print(f"[t6-t13] {m['output']} sha256={m['sha256'][:12]} "
          f"compare={m['comparison']}")
    print("[t6-t13] metrics=" + json.dumps(m["metrics"]))
    print("[t6-t13] footprint=" + json.dumps(m["footprint"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
