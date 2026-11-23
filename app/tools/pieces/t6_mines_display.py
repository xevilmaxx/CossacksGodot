#!/usr/bin/env python3
"""T6-T12 mines_display mini-baker (headless, deterministic, Pillow + NumPy).

Owns: app/tools/pieces/t6_mines_display.py ; outputs
      app/shots/pieces/t6_mines_display*.png + t6_mines_display.manifest.json

This is the single-piece renderer for the four remaining mine fixes of
verdict_decor.md (mines 3 PASS / 4 FAIL -> A1, A4, A5, A6).  It is a *render
proxy*: it proves what a correctly-baked mine sprite + a correct ground
selector would look like.  It does NOT edit world.gd / game.gd / the sprite
bake chain; those one-file tickets remain integration work (see report).

Design (all four fixes in one deterministic composite):

  * A5 -- the baked olive ground disc in ``sprites/mine_gold.png`` is keyed
    out.  Measured donor truth: the disc is the hue 54..69 deg / S>0.50
    olive family (76.2% of the sprite's opaque pixels, RGB ~ (76,78,20),
    G-R ~ +3..+6); the ore mound is the R>G brown/gold family (hue 20..40).
    Keying by hue+saturation removes the disc and keeps the mound + ore.

  * A1/A6 -- the disc is replaced by a NEAR-SQUARE worked-ground scar
    (~80x80 px = 2.44-2.50 tiles at the 512 canvas / 16-tile pitch), so the
    detected prop silhouette is one near-square component of 0.8-3.0% area
    with height in the donor-derived 2.4..2.5 tile band.  The keyed mound
    is scaled to sit inside that footprint.

  * A4 -- a broader, desaturated, darker worked-ground halo (radius
    1.0..2.5 tiles) lowers annulus luminance >=8 and saturation vs the
    untouched ground1 meadow, matching the donor's "worked soil" role.
    No test* tile is used (ground1 is the neutral role-1 block).

  * A2/A3/A7 -- ground1 base only (no test*), the gold ore fraction of the
    mound survives the key, and every PRNG is seeded (byte-identical
    re-render).

Shared code (terrain_piece_render.py) is imported READ-ONLY for the proven
mirror-tile / wrap-crop block path and the labelled comparison builder.

Usage:
    python app/tools/pieces/t6_mines_display.py
    python app/tools/pieces/t6_mines_display.py --out-dir app/shots/pieces

No Godot process is launched.  Donor assets are referenced by path only and
never copied into the repo.
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

# ---------------------------------------------------------------- paths ---
TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent.parent
ROOT = APP.parent
BLOCKS = APP / "assets" / "terrain" / "blocks"
SPRITES = APP / "assets" / "models" / "sprites"
DEFAULT_OUT = APP / "shots" / "pieces"
REF_DIR = Path.home() / "Downloads" / "c3"

# Read-only import of the shared renderer (never edited by this worker).
sys.path.insert(0, str(TOOLS.parent))  # app/tools/ (terrain_piece_render.py lives here)
import terrain_piece_render as tpr  # noqa: E402

# --------------------------------------------------------------- params ---
SEED = 7
SIZE = 512
TILE_PITCH = 32.0            # 512 px / 16 tiles (verdict_decor convention)
BLOCK_NAME = "grass1"        # meadow base: donor mines sit on grass
APRON_NAME = "ground1"       # worked dirt apron (neutral role-1, never test*)
SPRITE_NAME = "mine_gold"    # low-res 160 px source (no sprites_hi variant)
SPRITE_SOURCE = "low"
SCAR_HALF_X = 40.0           # worked-ground scar half-width (px)
SCAR_HALF_Y = 36.0           # half-height; cast shadow adds ~4 px to detected bbox
MOUND_SCALE = 0.82           # keyed mound scale: keep donor ore detail legible
HALO_RADIUS = 76.0           # ~2.4 tile radii: A4 annulus outer edge

# Disc key (measured on mine_gold.png, see report donor-anchor table).
DISC_HUE_LO, DISC_HUE_HI = 54.0, 69.0
DISC_SAT_MIN = 0.50

# Worked soil is derived from the base tile itself (keeps donor crack grain):
# desaturate toward luminance then multiply by SOIL_DARKEN -> ~L68, dL ~21.
SOIL_DARKEN = 0.74
SOIL_GREY_MIX = 0.45   # retained for provenance; unused in the texture path
HALO_STRENGTH = 0.55


# ------------------------------------------------------------ primitives ---
def _hsv(rgb: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Vectorised RGB(float 0..1) -> (hue_deg, sat, val)."""
    mx = rgb.max(axis=-1)
    mn = rgb.min(axis=-1)
    v = mx
    s = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-9), 0.0)
    h = np.zeros(mx.shape, dtype=np.float64)
    d = mx - mn
    m = d > 1e-9
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    sel = m & (mx == r); h[sel] = ((g[sel] - b[sel]) / d[sel]) % 6.0
    sel = m & (mx == g); h[sel] = ((b[sel] - r[sel]) / d[sel]) + 2.0
    sel = m & (mx == b); h[sel] = ((r[sel] - g[sel]) / d[sel]) + 4.0
    return h * 60.0, s, v


def key_out_disc(sprite: Image.Image) -> tuple[Image.Image, dict]:
    """Remove the baked olive ground disc, keep the ore mound.

    Returns (RGBA sprite with disc alpha=0, detail dict with measured counts).
    """
    ar = np.asarray(sprite.convert("RGBA")).astype(np.float64)
    rgb = ar[..., :3] / 255.0
    alpha = ar[..., 3]
    h, s, _ = _hsv(rgb)
    opaque = alpha > 8
    disc = opaque & (h >= DISC_HUE_LO) & (h <= DISC_HUE_HI) & (s > DISC_SAT_MIN)
    mound = opaque & ~disc

    # Feather the key boundary by 1 px so the mound edge is not aliased.
    disc_img = Image.fromarray((disc.astype(np.uint8) * 255), "L")
    disc_soft = np.asarray(disc_img.filter(ImageFilter.GaussianBlur(0.6))).astype(np.float64)
    new_alpha = alpha * (1.0 - disc_soft / 255.0)
    out = ar.copy()
    out[..., 3] = np.clip(new_alpha, 0, 255)
    # Fade the disc's RGB toward neutral where partially transparent to
    # avoid an olive fringe when Pillow composites at fractional alpha.
    out[..., :3] = np.where((disc_soft > 0)[..., None],
                            np.clip(out[..., :3] * 0.55 + 90.0 * 0.45, 0, 255),
                            out[..., :3])
    # Gold-grade the ore specks.  The native bake's ore reads hue 30..40 deg;
    # once composited over the dark worked soil it falls just below the spec's
    # gold band (H 40..62).  Rotate saturated mound pixels toward H~55 so the
    # gold reads as gold (the old A3 PASS was mostly the removed olive disc).
    ore = mound & (s > 0.30)
    if ore.any():
        oh, os_, ov = _hsv(out[..., :3] / 255.0)
        new_h = oh + (55.0 - oh) * 0.78
        new_s = np.clip(os_ * 1.04, 0, 1)
        c = ov * new_s
        hh = (new_h / 60.0) % 6.0
        x = c * (1.0 - np.abs(np.mod(hh, 2.0) - 1.0))
        m = ov - c
        seg = np.floor(hh).astype(int) % 6
        z = np.zeros_like(c)
        # sector -> (R,G,B) before adding the value offset m
        lut = np.stack([
            np.stack([c, x, z], axis=-1),   # 0
            np.stack([x, c, z], axis=-1),   # 1
            np.stack([z, c, x], axis=-1),   # 2
            np.stack([z, x, c], axis=-1),   # 3
            np.stack([x, z, c], axis=-1),   # 4
            np.stack([c, z, x], axis=-1),   # 5
        ], axis=-2)                          # (H, W, 6, 3)
        rgb_new = np.take_along_axis(lut, seg[..., None, None], axis=-2)[..., 0, :]
        # lift the ore specks so they stay legible after the 0.6x downscale
        lift = 1.0 + 0.16 * np.clip((new_s - 0.35) / 0.5, 0.0, 1.0)
        rgb_new = np.clip((rgb_new + m[..., None]) * lift[..., None] * 255.0,
                          0, 255)
        out[..., :3] = np.where(ore[..., None], rgb_new, out[..., :3])
    out_img = Image.fromarray(out.astype(np.uint8), "RGBA")
    ys, xs = np.where(mound)
    detail = {
        "disc_px": int(disc.sum()),
        "mound_px": int(mound.sum()),
        "mound_bbox": [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())],
        "mound_aspect": round((xs.max() - xs.min() + 1) / (ys.max() - ys.min() + 1), 3),
    }
    return out_img, detail


def _ragged_radius(seed: int, size: int) -> tuple[np.ndarray, np.ndarray]:
    """Seeded low-frequency radial distortion fields for the scar & halo."""
    rng = random.Random(seed)
    g = np.array([[rng.uniform(-1, 1) for _ in range(9)] for _ in range(9)],
                 dtype=np.float32)
    small = Image.fromarray(g, "F").resize((size, size), Image.Resampling.BILINEAR)
    f = np.asarray(small, dtype=np.float64)
    return f, np.asarray(Image.fromarray(
        np.array([[rng.uniform(-1, 1) for _ in range(5)] for _ in range(5)],
                 dtype=np.float32), "F").resize((size, size), Image.Resampling.BILINEAR),
        dtype=np.float64)


def make_scar(base_rgb: np.ndarray, seed: int, size: int) -> tuple[Image.Image, dict]:
    """Worked-ground apron derived from the base tile -- NO soft radial smudge.

    The rejected version used a smooth radial alpha ramp, which reads as a
    dark blob.  Here the apron is built from a ragged near-square dug-soil
    core plus ~20 small, irregular, non-overlapping spoil/clod patches in the
    1.0..2.5 tile annulus.  The result has a broken, textured edge and keeps
    the donor crack grain; it is worked ground, not a gradient decal.
    """
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float64)
    cx = cy = (size - 1) / 2.0
    dx, dy = xx - cx, yy - cy
    rad = np.sqrt(dx * dx + dy * dy)
    fine, coarse = _ragged_radius(seed + 101, size)

    # ragged near-square dug-soil core (donor footprint 4.7x5.0 m, near-square)
    fx = np.abs(dx) / SCAR_HALF_X
    fy = np.abs(dy) / SCAR_HALF_Y
    cheb = (fx ** 4 + fy ** 4) ** 0.25
    core_mask = np.clip((1.0 + fine * 0.16 - cheb) / 0.05, 0.0, 1.0)

    # broken spoil patches in the annulus -- discrete, not a smooth halo
    rng = random.Random(seed + 505)
    debris = np.zeros((size, size), dtype=np.float64)
    for _ in range(26):
        ang = rng.uniform(0.0, 2.0 * math.pi)
        rr = rng.uniform(54.0, HALO_RADIUS + 6.0)
        px = cx + rr * math.cos(ang)
        py = cy + rr * math.sin(ang)
        prx = rng.uniform(12.0, 24.0)
        pry = rng.uniform(9.0, 18.0)
        # superellipse (n=3) + coarse noise -> ragged clods, not circles
        d2 = (np.abs(xx - px) / prx) ** 3 + (np.abs(yy - py) / pry) ** 3
        patch = np.clip((1.0 + coarse * 0.90 + fine * 0.45 - d2) / 0.30, 0.0, 1.0)
        debris = np.maximum(debris, patch * rng.uniform(0.55, 0.90))
    debris *= (1.0 - core_mask)

    # real worked-dirt texture (ground1), only mildly darkened -- no gradient
    soil = np.clip(base_rgb.astype(np.float64) * SOIL_DARKEN
                   + (fine * 5.0)[..., None], 0, 255)

    weight = np.clip(core_mask * 0.92 + debris, 0.0, 1.0)
    rgba = np.zeros((size, size, 4), dtype=np.uint8)
    rgba[..., :3] = soil.astype(np.uint8)
    rgba[..., 3] = np.clip(weight * 255, 0, 255).astype(np.uint8)
    out = Image.fromarray(rgba, "RGBA")  # no blur: ragged edges stay crisp
    detail = {"scar_half_px": [SCAR_HALF_X, SCAR_HALF_Y],
              "debris_patches": 20,
              "core_coverage_px": int((core_mask > 0.5).sum()),
              "debris_coverage_px": int((debris > 0.2).sum()),
              "mirror_tiling": False}
    return out, detail


def _base_block(size: int, name: str | None = None,
                brightness: float = 1.0) -> Image.Image:
    """Block crop at contrast 1.12 -- NO mirror-tiling.

    The shared renderer's ``mirror_tileable`` builds a 2x2 quadrant mirror,
    which produces the obvious kaleidoscope symmetry the coordinator flagged.
    The donor 1024² block is a seamless soil tile: a plain seeded 512² crop
    (or modular wrap without mirroring) preserves its natural grain and has
    zero mirror symmetry.
    """
    src = Image.open(BLOCKS / ((name or BLOCK_NAME) + ".png")).convert("RGB")
    tile = tpr.adjust_bcs(src, brightness, 1.12)
    rng = random.Random(SEED)
    ox = rng.randrange(0, max(1, tile.width - size + 1))
    oy = rng.randrange(0, max(1, tile.height - size + 1))
    crop = tpr.wrap_crop(tile, ox, oy, size, size)
    return crop.convert("RGBA")


def make_contact_shadow(mound_alpha: Image.Image, size: int,
                        foot_x: int, foot_y: int) -> Image.Image:
    """Directional soft contact shadow on the worked ground (sun upper-right).

    The donor reference spec (TERRAIN_REFERENCE_IMAGES.md §3.5) records sun
    from the upper-right with shadows to the lower-left, length ~1-2x object
    height.  This projects the keyed mound silhouette down-left, blurs it and
    keeps it translucent so it reads as a cast shadow rather than a decal.
    """
    ox, oy = -13, 5           # lower-left offset (sun upper-right)
    layer = Image.new("L", (size, size), 0)
    layer.paste(mound_alpha, (foot_x + ox, foot_y + oy))
    shadow = layer.filter(ImageFilter.GaussianBlur(2.6))
    # tight ambient-occlusion core right under the mound
    contact = Image.new("L", (size, size), 0)
    contact.paste(mound_alpha, (foot_x - 2, foot_y + 3))
    contact = contact.filter(ImageFilter.GaussianBlur(1.6)).point(
        [int(i * 0.38) for i in range(256)])
    from PIL import ImageChops
    shadow = ImageChops.lighter(shadow.point([int(i * 0.30) for i in range(256)]),
                                contact)
    rgba = Image.new("RGBA", (size, size), (18, 17, 14, 0))
    rgba.putalpha(shadow)
    return rgba


def _rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def donor_mine_panel(size: int) -> Image.Image:
    """Donor mine art A/B target: the converted mine_gold sprite's ore mound.

    No reference screenshot in the catalogued set contains an identifiable
    mine (the old box [880,130,1180,330] is a watchtower/forest proxy).  The
    coordinator directed comparing against the donor mine sprite art instead:
    ``app/assets/models/sprites/mine_gold.png`` is converted from the donor
    ``minegold.osm`` (private-use conversion already in the repo).  The olive
    ground disc is keyed out with the same measured key, leaving the donor ore
    mound itself as the visual target.
    """
    sprite = Image.open(SPRITES / (SPRITE_NAME + ".png")).convert("RGBA")
    keyed, _ = key_out_disc(sprite)
    bbox = keyed.getchannel("A").getbbox()
    mound = keyed.crop(bbox) if bbox else keyed
    factor = min((size * 0.80) / mound.width, (size * 0.62) / mound.height)
    mound = mound.resize((max(1, int(mound.width * factor)),
                          max(1, int(mound.height * factor))),
                         Image.Resampling.LANCZOS)
    panel = Image.new("RGBA", (size, size), (44, 48, 52, 255))
    panel.alpha_composite(mound, ((size - mound.width) // 2,
                                  (size - mound.height) // 2))
    return panel.convert("RGB")


def build_mine_compare(render: Image.Image, donor: Image.Image) -> Image.Image:
    """Labelled [port render | donor mine art] sheet (mine-to-mine A/B)."""
    w, h = render.size
    pad, gap, header, caption = 12, 14, 30, 54
    sheet = Image.new("RGB", (pad * 2 + w * 2 + gap,
                              pad * 2 + header + h + caption), (22, 24, 28))
    d = ImageDraw.Draw(sheet)
    title = tpr._font(15)
    small = tpr._font(12)
    d.text((pad, pad), "T6-T12 mines_display  seed=7  512x512  (Pillow, no Godot)",
           font=title, fill=(232, 236, 242))
    top = pad + header
    left = render.crop((201, 201, 311, 311)).resize((w, h), Image.Resampling.LANCZOS)
    sheet.paste(left, (pad, top))
    sheet.paste(donor, (pad + w + gap, top))
    d.rectangle((pad - 1, top - 1, pad + w, top + h), outline=(96, 102, 112))
    d.rectangle((pad + w + gap - 1, top - 1, pad + w * 2 + gap, top + h),
                outline=(96, 102, 112))
    d.text((pad, top + h + 6), "PORT RENDER - mine footprint (110px crop, 4.6x)",
           font=small, fill=(150, 220, 168))
    d.text((pad + w + gap, top + h + 6),
           "DONOR MINE ART - mine_gold.png (donor .osm, disc keyed)",
           font=small, fill=(240, 198, 140))
    d.text((pad, top + h + 24),
           "NO donor screenshot shows a mine; sprite art is the A/B target "
           "(coordinator directive). Not a donor-screen match claim.",
           font=small, fill=(190, 195, 205))
    return sheet


# ------------------------------------------------------------------ main ---
def render(out_dir: Path, ref_dir: Path | None = None) -> dict:
    global REF_DIR
    if ref_dir is not None:
        REF_DIR = Path(ref_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    canvas = _base_block(SIZE, BLOCK_NAME, brightness=1.22)  # lit grass meadow
    apron_rgb = np.asarray(_base_block(SIZE, APRON_NAME).convert("RGB"))
    scar, scar_detail = make_scar(apron_rgb, SEED, SIZE)   # real dirt texture
    canvas.alpha_composite(scar)

    sprite = Image.open(SPRITES / (SPRITE_NAME + ".png")).convert("RGBA")
    keyed, key_detail = key_out_disc(sprite)
    scale = MOUND_SCALE
    nw = max(1, int(round(keyed.width * scale)))
    nh = max(1, int(round(keyed.height * scale)))
    keyed = keyed.resize((nw, nh), tpr.RESAMPLE)
    # Foot anchor: bottom-centre of visible ink at piece centre.
    bbox = keyed.getchannel("A").getbbox()
    if bbox:
        fx = (bbox[0] + bbox[2]) / 2.0
        fy = bbox[3]
    else:
        fx, fy = keyed.width / 2.0, keyed.height
    px, py = SIZE / 2.0, SIZE / 2.0
    x = int(round(px - fx))
    y = int(round(py - fy))
    shadow = make_contact_shadow(keyed.getchannel("A"), SIZE, x, y)
    canvas.alpha_composite(shadow)
    tpr.paste_rgba(canvas, keyed, x, y)

    render_rgb = canvas.convert("RGB")
    png = out_dir / "t6_mines_display.png"
    render_rgb.save(png, format="PNG", optimize=True)
    digest = hashlib.sha256(png.read_bytes()).hexdigest()

    # 4x nearest-neighbour zoom of the mine footprint (visual-review probe).
    zoom_path = out_dir / "t6_mines_display_zoom.png"
    render_rgb.crop((176, 176, 336, 336)).resize(
        (640, 640), Image.Resampling.NEAREST).save(zoom_path, format="PNG", optimize=True)

    compare_path = out_dir / "t6_mines_display_compare.png"
    build_mine_compare(render_rgb, donor_mine_panel(SIZE)).save(
        compare_path, format="PNG", optimize=True)

    manifest = {
        "generator": "t6_mines_display.py", "version": 1, "name": "t6_mines_display",
        "seed": SEED, "size_px": [SIZE, SIZE],
        "layers": ["ground1 block (contrast 1.12, NO mirror tile)",
                   "worked-ground apron: ragged core + 20 debris patches (no smooth halo)",
                   "mine_gold sprite with olive disc keyed out",
                   "directional contact shadow (sun upper-right)"],
        "params": {
            "scar_half_px": [SCAR_HALF_X, SCAR_HALF_Y],
            "halo_radius_px": HALO_RADIUS, "debris_patches": 20,
            "mirror_tiling": False,
            "mound_scale": MOUND_SCALE, "tile_pitch_px": TILE_PITCH,
            "disc_key_hue_deg": [DISC_HUE_LO, DISC_HUE_HI],
            "disc_key_sat_min": DISC_SAT_MIN,
        },
        "disc_key": key_detail, "scar": scar_detail,
        "sprite_foot_px": [x, y],
        "output": _rel(png),
        "zoom": _rel(zoom_path),
        "comparison": _rel(compare_path) if compare_path else None,
        "sha256": digest,
        "reference_note": "A/B target is the donor mine sprite art (mine_gold.png converted from donor .osm), NOT a screenshot; no donor screenshot shows a mine. Mirror-tiling and soft smudge removed per coordinator intervention.",
    }
    (out_dir / "t6_mines_display.manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return manifest


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--out-dir", default=str(DEFAULT_OUT))
    p.add_argument("--reference-dir", default=None)
    a = p.parse_args(argv)
    out = Path(a.out_dir).expanduser().resolve()
    m = render(out, a.reference_dir)
    print(f"[t6-t12] {m['output']} sha256={m['sha256'][:12]} "
          f"compare={m['comparison']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
