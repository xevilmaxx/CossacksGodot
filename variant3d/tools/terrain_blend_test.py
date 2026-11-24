"""Terrain-ONLY blend A/B harness (no objects, headless, no donor binaries).

Purpose
-------
Owner complaint: "current terrain is a total checkerboard mess".  This tool
makes that claim MEASURABLE on ground art alone, with no trees, bushes, rocks,
units or water overlays that could confound the measurement.  It renders a
small grid of terrain cells from the port's own block PNGs
(``app/assets/terrain/blocks/``) in three modes:

* ``uniform``      one donor block wrapped continuously over the whole canvas.
                   Control: must show NO 64 px checkerboard (grid_peak ~ 0).
* ``donor_tiles``  per-cell donor tileblock names from a coherent field, with
                   simple feathered border blending.  Anti-checker reference.
* ``current_gain`` positive control modelling the CURRENT synthetic look in
                   ``world.gd``: mirror-folded gain grid + hard rim (quantised
                   overlay), with the alternating per-cell gain that makes a
                   checkerboard.  Must show a clear grid peak at cell spacing.

Each mode writes ``app/shots/blend_<mode>.png`` and a manifest
``app/shots/blend_<mode>.manifest.json`` containing the measured metrics.

Read-only reuse
---------------
``terrain_piece_render.py`` is imported, never edited.  Reused primitives:
``mirror_tileable`` (world.gd::_mirror_tileable port), ``wrap_crop``
(world.gd::_wrap_crop port), ``adjust_bcs`` (the 1.12 contrast lift every
land block gets), ``_olive_gain`` and ``_clamp255``.  The current-gain
constants mirror ``world.gd:595-701`` and are documented below.

Metric
------
2-D autocorrelogram of the luminance field, normalised by ACF(0,0), computed
with an FFT.  ``grid_peak = (|ACF(0, cell_px)| + |ACF(cell_px, 0)|) / 2``.
A checkerboard (alternating cell tones) drives |ACF| at one-cell lag towards
1; organic donor art and a uniform wrap leave it near zero.  Also reports
luminance standard deviation and hi-frequency energy
``mean |L - L.filter(GaussianBlur(5))|`` (same convention as
``docs/audit/PIECES/grass_plain.md``).

Scope / caveat
--------------
Ground art only.  No Godot run: there is no config that hides objects
in-engine, and this is a tool-only ticket.  ``current_gain`` is a deliberate
headless approximation of world.gd's gain pass (its quantised hard rim is
aligned to the test cell so the metric can see it), NOT an in-engine capture.

CLI
---
    python app/tools/terrain_blend_test.py --mode all
    python app/tools/terrain_blend_test.py --mode uniform --spec app/shots/blend_grass.json
    python app/tools/terrain_blend_test.py --mode donor_tiles --grid 12x12 --cell-px 64

After a fix removes the gain pass, a follow-up spec with
``current_gain.checker = false`` should drop ``grid_peak`` from ~0.65 to ~0.08
and is the headless proof that the checker component is gone.  All three modes
accept per-cell ``donor_tiles.cells`` (2-D array of block names) as an explicit
alternative to the sampled ``pool``.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import random
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageFilter

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent
SHOTS = APP / "shots"
PRESETS_PATH = APP / "assets" / "terrain" / "structs" / "presets_summer.json"
DEFAULT_SPEC_PATH = SHOTS / "blend_grass.json"

if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

import terrain_piece_render as tpr  # noqa: E402  (read-only import; never edited)

MODES = ("uniform", "donor_tiles", "current_gain")

# From world.gd:611-612 (GRASS_PATCH_DARK / GRASS_PATCH_LIGHT), 8-bit.
GRASS_PATCH_DARK = (23, 26, 10)     # Color(0.09, 0.10, 0.04)
GRASS_PATCH_LIGHT = (153, 150, 97)  # Color(0.60, 0.59, 0.38)

DEFAULT_SPEC: dict[str, Any] = {
    "name": "blend_grass",
    "grid": [12, 12],
    "cell_px": 64,
    "seed": 7,
    "uniform": {"block": "grass1"},
    "donor_tiles": {
        "pool": ["grass1", "grass2", "grass7", "grass9",
                 "grass_ground1", "sandsea3", "rock8"],
        "border": "blend",
        "border_px": 4,
        "noise_cells": 12,
    },
    "current_gain": {
        "base": "grass1",
        "amplitude": 30.0,
        "gain_levels": 3.0,
        "dither": True,
        "hard_alpha": 0.66,
        "hard_rim": True,
        "checker": True,
        "checker_strength": 1.0,
    },
}


# ---------------------------------------------------------------------------
# spec / assets
# ---------------------------------------------------------------------------
def load_spec(path: Path | None) -> tuple[dict[str, Any], str]:
    """Load a JSON spec, falling back to the built-in default."""
    if path is None:
        if DEFAULT_SPEC_PATH.is_file():
            path = DEFAULT_SPEC_PATH
        else:
            return json.loads(json.dumps(DEFAULT_SPEC)), "built-in default"
    spec = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(spec, dict):
        raise ValueError("spec root must be a JSON object")
    merged = json.loads(json.dumps(DEFAULT_SPEC))
    merged.update(spec)
    return merged, str(path.relative_to(APP) if path.is_relative_to(APP) else path)


def preset_names() -> set[str]:
    """Tileblock names from presets_summer.json (explicit names also allowed)."""
    if not PRESETS_PATH.is_file():
        return set()
    data = json.loads(PRESETS_PATH.read_text(encoding="utf-8"))
    return {str(v) for v in data} if isinstance(data, list) else set()


def check_block(name: Any, presets: set[str], what: str) -> str:
    """Validate a block name against the safe pattern and an existing PNG."""
    stem = tpr._safe_name(name, what)
    tpr._png(tpr.BLOCKS_DIR, stem)  # raises if the PNG is missing
    if presets and stem not in presets:
        # Explicit names outside the summer preset are permitted by the task;
        # they are still resolved against a real PNG above.
        print(f"[blend] note: {what} {stem!r} is not in presets_summer.json "
              "(explicit name, PNG exists)", file=sys.stderr)
    return stem


class TileCache:
    """Load each block once, mirror-tile to 1024² and lift contrast like world.gd."""

    def __init__(self) -> None:
        self._tiles: dict[str, Image.Image] = {}

    def get(self, name: str) -> Image.Image:
        if name not in self._tiles:
            with Image.open(tpr._png(tpr.BLOCKS_DIR, name)) as src:
                tile = tpr.mirror_tileable(src.convert("RGB"), tpr.TILE_SIZE,
                                           tpr.RESAMPLE)
            self._tiles[name] = tpr.adjust_bcs(tile, 1.0, 1.12)
        return self._tiles[name]

    def crop(self, name: str, ox: int, oy: int, w: int, h: int) -> Image.Image:
        return tpr.wrap_crop(self.get(name), ox, oy, w, h)


def name_offset(name: str, mod: int = 1024) -> tuple[int, int]:
    """Deterministic crop phase per block name (sha256, unlike salted hash())."""
    digest = hashlib.sha256(name.encode("utf-8")).digest()
    return (int.from_bytes(digest[:4], "little") % mod,
            int.from_bytes(digest[4:8], "little") % mod)


# ---------------------------------------------------------------------------
# renderers
# ---------------------------------------------------------------------------
def render_uniform(cfg: dict[str, Any], rows: int, cols: int, cell: int,
                   cache: TileCache, presets: set[str]) -> tuple[Image.Image, list[str]]:
    """One block, wrapped continuously: the no-checkerboard control."""
    name = check_block(cfg["block"], presets, "uniform block")
    w, h = cols * cell, rows * cell
    ox, oy = name_offset(name)
    img = cache.crop(name, ox, oy, w, h).convert("RGB")
    return img, [name]


def _coherent_indices(rows: int, cols: int, n: int, seed: int,
                      low_res: int) -> np.ndarray:
    """Low-res random field bilinearly upsampled to the cell grid (donor-like)."""
    rng = random.Random(seed)
    lr = max(1, min(int(low_res), rows, cols))
    lc = max(1, min(int(low_res), rows, cols))
    small = Image.fromarray(
        (np.array([[rng.random() for _ in range(lc)] for _ in range(lr)])
         * 255).astype(np.uint8), mode="L")
    field = np.asarray(small.resize((cols, rows), Image.Resampling.BILINEAR),
                       dtype=np.float64) / 255.0
    return np.clip((field * n).astype(int), 0, n - 1)


def _smooth_border(a: np.ndarray, cell: int, border: int) -> np.ndarray:
    """Feather cell borders by crossfading the two adjacent cell images."""
    b = min(border, cell // 2)
    if b <= 0:
        return a
    out = a.astype(np.float32).copy()
    work = out.copy()
    for k in range(1, a.shape[1] // cell):
        bx = k * cell
        for d in range(b):
            w = 0.5 * (1.0 - d / b)
            left, right = work[:, bx - 1 - d].copy(), work[:, bx + d].copy()
            out[:, bx - 1 - d] = (1.0 - w) * left + w * right
            out[:, bx + d] = (1.0 - w) * right + w * left
    work = out.copy()
    for k in range(1, a.shape[0] // cell):
        by = k * cell
        for d in range(b):
            w = 0.5 * (1.0 - d / b)
            top, bottom = work[by - 1 - d].copy(), work[by + d].copy()
            out[by - 1 - d] = (1.0 - w) * top + w * bottom
            out[by + d] = (1.0 - w) * bottom + w * top
    return np.clip(out + 0.5, 0, 255).astype(np.uint8)


def render_donor_tiles(cfg: dict[str, Any], rows: int, cols: int, cell: int,
                       cache: TileCache, presets: set[str], seed: int
                       ) -> tuple[Image.Image, list[str]]:
    """Per-cell donor names, coherent (no per-tile randi), feathered borders."""
    pool = [check_block(n, presets, "donor pool block") for n in cfg["pool"]]
    if not pool:
        raise ValueError("donor_tiles.pool must be non-empty")
    explicit = cfg.get("cells")
    if explicit is not None:
        if len(explicit) != rows or any(len(r) != cols for r in explicit):
            raise ValueError("cells must be a grid matching [cols, rows]")
        names = [[check_block(n, presets, "cell block") for n in row]
                 for row in explicit]
    else:
        idx = _coherent_indices(rows, cols, len(pool), seed,
                                int(cfg.get("noise_cells", 4)))
        names = [[pool[idx[gy, gx]] for gx in range(cols)] for gy in range(rows)]

    cells = np.empty((rows, cols, cell, cell, 3), dtype=np.uint8)
    for gy in range(rows):
        for gx in range(cols):
            name = names[gy][gx]
            box, boy = name_offset(name)
            # Per-cell phase (like the donor detail pass) avoids repeating the
            # same 64 px crop when the same block name is drawn twice.
            ox, oy = (box + gx * cell) % 1024, (boy + gy * cell) % 1024
            cells[gy, gx] = np.asarray(cache.crop(name, ox, oy, cell, cell))
    arr = cells.transpose(0, 2, 1, 3, 4).reshape(rows * cell, cols * cell, 3)
    border = str(cfg.get("border", "blend")).lower()
    if border == "blend":
        arr = _smooth_border(arr, cell, int(cfg.get("border_px", 4)))
    elif border != "nearest":
        raise ValueError(f"unknown donor_tiles.border: {border!r}")
    used = sorted({n for row in names for n in row})
    return Image.fromarray(arr, mode="RGB"), used


def _mirror_fold(quarter: np.ndarray, rows: int, cols: int) -> np.ndarray:
    """world.gd:621-622 fold: x if x<64 else 127-x (here the grid is smaller)."""
    qh, qw = quarter.shape
    out = np.empty((rows, cols), dtype=np.float64)
    for gy in range(rows):
        my = gy if gy < qh else rows - 1 - gy
        for gx in range(cols):
            mx = gx if gx < qw else cols - 1 - gx
            out[gy, gx] = quarter[my % qh, mx % qw]
    return out


def render_current_gain(cfg: dict[str, Any], rows: int, cols: int, cell: int,
                        cache: TileCache, presets: set[str], seed: int
                        ) -> tuple[Image.Image, list[str]]:
    """Headless approximation of world.gd's gain_map + quantised hard rim."""
    base = check_block(cfg["base"], presets, "current_gain base")
    w, h = cols * cell, rows * cell
    ox, oy = name_offset(base)
    canvas = cache.crop(base, ox, oy, w, h).convert("RGB")

    # Mirror-folded gain grid (world.gd uses a 128-tile fold; scaled to our grid).
    qh, qw = max(1, (rows + 1) // 2), max(1, (cols + 1) // 2)
    rng = random.Random(seed)
    quarter = np.array([[rng.uniform(-1.0, 1.0) for _ in range(qw)]
                        for _ in range(qh)], dtype=np.float64)
    gain = _mirror_fold(quarter, rows, cols)

    # Checker artifact component.  The owner's "checkerboard mess" is modelled
    # as an alternating +/- gain at every cell: it is still mirror-folded, but
    # a quarter grid of alternating signs folds to a full checkerboard.  This
    # is the POSITIVE CONTROL for the metric, not a pixel-exact world.gd copy.
    if bool(cfg.get("checker", True)):
        strength = float(cfg.get("checker_strength", 1.0))
        checker_q = np.array(
            [[1.0 if (gx + gy) % 2 == 0 else -1.0 for gx in range(qw)]
             for gy in range(qh)], dtype=np.float64)
        checker = _mirror_fold(checker_q, rows, cols)
        gain = checker * strength + gain * (1.0 - strength)

    # Soft bilinear bright/dark pass with olive RGB weights (world.gd:677-688).
    amplitude = float(cfg.get("amplitude", 30.0))
    soft_small = np.clip((gain * 0.5 + 0.5) * 255.0 + 0.5, 0, 255).astype(np.uint8)
    soft = np.asarray(Image.fromarray(soft_small, mode="L").resize(
        (w, h), Image.Resampling.BILINEAR), dtype=np.float64)
    delta = np.clip(128.0 + (soft - 128.0) * amplitude / 127.5, 0, 255).astype(np.uint8)
    result = tpr._olive_gain(
        canvas.convert("RGBA"), Image.fromarray(delta, mode="L"),
        tuple(float(v) for v in tpr.OLIVE_GAIN_WEIGHTS)).convert("RGB")

    # Hard rim: quantise to discrete gain levels + dither, NEAREST-upscale
    # (world.gd:638-701).  Aligned to the test cell so the checker is visible.
    if bool(cfg.get("hard_rim", True)):
        levels = max(1.0, float(cfg.get("gain_levels", 3.0)))
        alpha = float(cfg.get("hard_alpha", 0.66))
        dither = np.zeros((rows, cols), dtype=np.float64)
        if bool(cfg.get("dither", True)):
            for gy in range(rows):
                for gx in range(cols):
                    dither[gy, gx] = (((gx * 7 + gy * 11) % 5) - 2) * 0.055
        quant = np.floor(gain * levels + 0.5 + dither) / levels
        quant = np.clip(quant, -1.0, 1.0)
        arr = np.asarray(result, dtype=np.float64)
        for colour, sign in ((GRASS_PATCH_LIGHT, 1.0), (GRASS_PATCH_DARK, -1.0)):
            a = np.clip(np.maximum(quant * sign, 0.0) * alpha, 0.0, 1.0)
            if not a.any():
                continue
            small = Image.fromarray((a * 255.0 + 0.5).astype(np.uint8), mode="L")
            full = np.asarray(small.resize((w, h), Image.Resampling.NEAREST),
                              dtype=np.float64)[..., None] / 255.0
            arr = arr * (1.0 - full) + np.array(colour, dtype=np.float64) * full
        result = Image.fromarray(np.clip(arr + 0.5, 0, 255).astype(np.uint8),
                                 mode="RGB")
    return result, [base]


# ---------------------------------------------------------------------------
# metric
# ---------------------------------------------------------------------------
def periodicity(img: Image.Image, cell_px: int) -> dict[str, float]:
    """Luminance ACF at one-cell lag + std + hi-frequency energy."""
    grey = img.convert("L")
    lum = np.asarray(grey, dtype=np.float64)
    centred = lum - lum.mean()
    fft = np.fft.rfft2(centred)
    acf = np.fft.irfft2(fft * np.conj(fft), s=lum.shape)
    acf /= acf[0, 0]
    lag = min(cell_px, lum.shape[0] // 2 - 1, lum.shape[1] // 2 - 1)
    acf_h, acf_v = float(acf[0, lag]), float(acf[lag, 0])
    blur = np.asarray(grey.filter(ImageFilter.GaussianBlur(5)), dtype=np.float64)
    return {
        "grid_peak": 0.5 * (abs(acf_h) + abs(acf_v)),
        "acf_h": acf_h,
        "acf_v": acf_v,
        "lag_px": lag,
        "lum_std": float(lum.std()),
        "lum_mean": float(lum.mean()),
        "hifreq": float(np.abs(lum - blur).mean()),
    }


# ---------------------------------------------------------------------------
# driver
# ---------------------------------------------------------------------------
def _parse_grid(text: str) -> tuple[int, int]:
    parts = str(text).lower().replace("x", ",").split(",")
    if len(parts) != 2:
        raise ValueError("grid must be WxH (e.g. 12x12)")
    w, h = int(parts[0]), int(parts[1])
    if not (1 <= w <= 128 and 1 <= h <= 128):
        raise ValueError("grid dimensions must be 1..128")
    return w, h


def run_mode(mode: str, spec: dict[str, Any], spec_label: str, cols: int, rows: int,
             cell: int, seed: int, out_dir: Path, verbose: bool) -> dict[str, Any]:
    cache, presets = TileCache(), preset_names()
    if mode == "uniform":
        img, used = render_uniform(spec["uniform"], rows, cols, cell, cache, presets)
    elif mode == "donor_tiles":
        img, used = render_donor_tiles(spec["donor_tiles"], rows, cols, cell,
                                       cache, presets, seed)
    elif mode == "current_gain":
        img, used = render_current_gain(spec["current_gain"], rows, cols, cell,
                                        cache, presets, seed)
    else:
        raise ValueError(f"unknown mode: {mode!r}")

    metrics = periodicity(img, cell)
    out_dir.mkdir(parents=True, exist_ok=True)
    png = out_dir / f"blend_{mode}.png"
    img.save(png, format="PNG", optimize=True)
    digest = hashlib.sha256(png.read_bytes()).hexdigest()
    manifest = {
        "generator": "terrain_blend_test.py",
        "version": 1,
        "mode": mode,
        "spec": spec_label,
        "grid": [cols, rows],
        "cell_px": cell,
        "seed": seed,
        "output": str(png.relative_to(APP) if png.is_relative_to(APP) else png),
        "sha256": digest,
        "blocks_used": used,
        "metrics": metrics,
        "reuse": ("terrain_piece_render.py (read-only import): mirror_tileable, "
                  "wrap_crop, adjust_bcs, _olive_gain, OLIVE_GAIN_WEIGHTS"),
        "scope": ("ground art only: no trees/bushes/rocks/units/water overlays; "
                  "headless, no Godot (no object-hiding config exists)"),
        "limits": ("current_gain approximates world.gd gain_map + quantised hard "
                   "rim + alternating-cell checker component, aligned to the "
                   "test cell; positive control, not an in-engine capture"),
    }
    mpath = out_dir / f"blend_{mode}.manifest.json"
    mpath.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
                     encoding="utf-8")
    if verbose:
        print(f"[blend] {mode}: blocks={used} lag={metrics['lag_px']}px "
              f"acf_h={metrics['acf_h']:+.4f} acf_v={metrics['acf_v']:+.4f}")
    return manifest


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__.split("\n")[0],
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--mode", default="all",
                    help=f"one of {', '.join(MODES)} or 'all' (default: all)")
    ap.add_argument("--spec", default=None, metavar="JSON",
                    help=f"grid spec (default: {DEFAULT_SPEC_PATH} if present)")
    ap.add_argument("--out-dir", default=str(SHOTS), metavar="DIR",
                    help=f"output dir (default: {SHOTS})")
    ap.add_argument("--grid", default=None, metavar="WxH",
                    help="override spec grid, e.g. 12x12")
    ap.add_argument("--cell-px", type=int, default=None,
                    help="override spec cell size in px (default: 64)")
    ap.add_argument("--seed", type=int, default=None,
                    help="override spec seed")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args(argv)

    modes = MODES if args.mode == "all" else (args.mode,)
    invalid = [m for m in modes if m not in MODES]
    if invalid:
        ap.error(f"invalid mode(s): {', '.join(invalid)}")
    try:
        spec, spec_label = load_spec(Path(args.spec).expanduser().resolve()
                                     if args.spec else None)
        cols, rows = _parse_grid(args.grid) if args.grid else (
            int(spec["grid"][0]), int(spec["grid"][1]))
        cell = args.cell_px if args.cell_px is not None else int(spec["cell_px"])
        seed = args.seed if args.seed is not None else int(spec.get("seed", 0))
        if not (4 <= cell <= 256):
            raise ValueError("cell_px must be 4..256")
        out_dir = Path(args.out_dir).expanduser().resolve()
        manifests = [run_mode(m, spec, spec_label, cols, rows, cell, seed,
                              out_dir, args.verbose) for m in modes]
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f"[blend] ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"[blend] {cols}x{rows} cells @ {cell}px -> {cols * cell}x{rows * cell}; "
          f"spec={spec_label}")
    print(f"{'MODE':<14}{'GRID_PEAK':>11}{'STD':>9}{'HI-FREQ':>10}  PNG")
    for m in manifests:
        d = m["metrics"]
        print(f"{m['mode']:<14}{d['grid_peak']:>11.4f}{d['lum_std']:>9.2f}"
              f"{d['hifreq']:>10.2f}  {m['output']}")
        print(f"{'':<14}  acf_h={d['acf_h']:+.4f} acf_v={d['acf_v']:+.4f} "
              f"lag={d['lag_px']}px sha256={m['sha256'][:12]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
