#!/usr/bin/env python3
"""Build ONE deterministic RGBA splat/albedo texture for the G3-2 heightmap mesh.

The texture is built ONLY from port assets (``app/assets/terrain/blocks/*.png``
and ``app/assets/terrain/structs/presets_summer.json``). No donor binary, donor
archive or donor path is read. No Godot launch is performed.

Input dump schema (the canonical output of ``--dump-map`` in ``main.gd``)::

    {
      "map_w": 320, "map_h": 320, "seed": 20261113,
      "height":    "<base64 of little-endian float32[map_w*map_h]>",
      "tileblock": "<base64 of uint8[map_w*map_h]>",       # preset index, 255 = water
      "terrain":   "<base64 of uint8[map_w*map_h]>",       # optional, unused here
      "blocked":   "<base64 of uint8[map_w*map_h]>",       # optional, unused here
      ... "meta": {...}, "starts": [...], "res": [...]
    }

``height``, ``tileblock`` and ``terrain`` may ALSO be flat JSON arrays of
numbers (same ordering, row-major ``y * map_w + x``). If ``map_w``/``map_h``
are absent and ``height`` has a square length, they are inferred.

Index -> block name comes from ``presets_summer.json`` (the exact table used by
``game.gd::_assign_tileblocks`` via ``tbl_names``/``tbl_idx``). Index 255 is
``BLK_WATER`` and has no PNG, so it is rendered with the ``--water-block``
albedo (default ``sandsea6``, the donor shore tile under water).

Output (default ``app/assets/terrain/heightmap/splat_albedo.png``):

* RGB = donor-derived block albedo, sampled from the port PNGs. With the
  default ``--texels-per-cell 1`` the texture is exactly ``map_w x map_h``
  (e.g. 320x320), one texel per height cell. Neighbouring cells of the same
  block family or a similar height are softly blended; no RNG is involved.
* A = ``--alpha height`` (default): normalised dump height,
  ``round_half_up(255 * (h - hmin) / (hmax - hmin))`` over the dump's own
  min/max. ``--alpha roughness`` writes a deterministic per-family proxy
  (NOT donor roughness data -- the donor exposes none). ``--alpha none``
  writes 255.

UV convention for G3-2: cell ``(x, y)`` centre maps to
``u = (x + 0.5) / map_w``, ``v = (y + 0.5) / map_h``; use CLAMP_TO_EDGE and
nearest filtering for the 1:1 grid. Grid row 0 is the north/west origin, same
as ``height[y * map_w + x]``.

Usage::

    python app/tools/heightmap_splat.py --help
    python app/tools/heightmap_splat.py --schema
    python app/tools/heightmap_splat.py --dump app/shots/g32_dump.json --dry-run
    python app/tools/heightmap_splat.py --dump app/shots/g32_dump.json
"""
from __future__ import annotations

import argparse
import base64
import binascii
import hashlib
import json
import re
import struct
import sys
from pathlib import Path

from PIL import Image

TOOL_VERSION = "1.0.0"
ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DUMP = ROOT / "app" / "shots" / "g32_dump.json"
DEFAULT_PRESETS = ROOT / "app" / "assets" / "terrain" / "structs" / "presets_summer.json"
DEFAULT_BLOCKS = ROOT / "app" / "assets" / "terrain" / "blocks"
DEFAULT_OUT = ROOT / "app" / "assets" / "terrain" / "heightmap" / "splat_albedo.png"

WATER_ID = 255
ALPHA_MODES = ("height", "roughness", "none")
DEFAULT_WATER_BLOCK = "sandsea6"

# Non-physical artistic proxy only. The donor has no roughness map; these bytes
# let a shader vary specular response by terrain family if G3-2 wants it.
ROUGHNESS_BY_FAMILY = {
    "grass": 205,
    "ground": 215,
    "rock": 240,
    "sandrock": 235,
    "sandsea": 225,
    "sand": 220,
    "desert": 225,
    "test": 210,
    "alpha": 200,
    "winter": 215,
}
DEFAULT_ROUGHNESS = 210

SCHEMA_TEXT = """\
Dump schema (canonical --dump-map JSON, main.gd:688-695):
  map_w, map_h : int           grid size (inferred if absent and height is square)
  seed         : int           reproduced in the sidecar manifest
  height       : base64 str | number[]   little-endian float32[y*map_w+x], metres
  tileblock    : base64 str | number[]   uint8[y*map_w+x], presets_summer.json index
                                         255 = BLK_WATER (no PNG; --water-block)
  terrain      : base64 str | number[]   uint8[y*map_w+x] (accepted, unused)
  blocked      : base64 str | number[]   uint8[y*map_w+x] (accepted, unused)
Ordering is row-major, north/west origin: index = y * map_w + x.
All base64 strings are decoded with validate=True (Godot Marshalls format).
"""


def half_up(x: float) -> int:
    """Deterministic round-half-up to int (no banker's rounding, no RNG)."""
    return int(x + 0.5) if x >= 0 else -int(-x + 0.5)


def family(name: str) -> str:
    """Leading alpha run of a block name: 'grass_ground1' -> 'grass'."""
    m = re.match(r"[A-Za-z]+", name)
    return m.group(0).lower() if m else "other"


def roughness_for(name: str) -> int:
    return ROUGHNESS_BY_FAMILY.get(family(name), DEFAULT_ROUGHNESS)


def _as_bytes(value: object, width: int, label: str) -> bytes:
    """Accept a Godot base64 string or a flat numeric JSON array."""
    if isinstance(value, str):
        try:
            return base64.b64decode(value, validate=True)
        except (ValueError, binascii.Error) as exc:  # pragma: no cover
            raise ValueError(f"{label}: invalid base64: {exc}") from exc
    if isinstance(value, list):
        nums = [float(v) for v in value]
        if width == 4:
            return struct.pack(f"<{len(nums)}f", *nums)
        return bytes(int(v) & 0xFF for v in nums)
    raise ValueError(f"{label}: expected base64 string or number[], got {type(value).__name__}")


def load_dump(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(f"dump not found: {path}")
    raw_text = path.read_text(encoding="utf-8")
    doc = json.loads(raw_text)
    if not isinstance(doc, dict):
        raise ValueError("dump root must be a JSON object")

    hb = _as_bytes(doc.get("height"), 4, "height")
    tb = _as_bytes(doc.get("tileblock"), 1, "tileblock")
    w = int(doc.get("map_w", 0) or 0)
    h = int(doc.get("map_h", 0) or 0)
    if hb_len := len(hb) // 4:
        if (w <= 0 or h <= 0) and hb_len * 4 == len(hb):
            side = int(hb_len ** 0.5 + 0.5)
            if side * side == hb_len:
                w = h = side
    if w <= 0 or h <= 0:
        raise ValueError("cannot determine map_w/map_h from dump")
    need = w * h
    if len(hb) < need * 4:
        raise ValueError(f"height too short: {len(hb) // 4} values for {need} cells")
    if len(tb) < need:
        raise ValueError(f"tileblock too short: {len(tb)} values for {need} cells")

    heights = struct.unpack_from(f"<{need}f", hb, 0)
    tiles = tb[:need]
    terrain_raw = doc.get("terrain")
    terrain = _as_bytes(terrain_raw, 1, "terrain")[:need] if terrain_raw is not None else None
    return {
        "path": path,
        "sha256": hashlib.sha256(raw_text.encode("utf-8")).hexdigest(),
        "seed": int(doc.get("seed", 0) or 0),
        "map_w": w,
        "map_h": h,
        "heights": heights,
        "tiles": tiles,
        "terrain": terrain,
        "meta": doc.get("meta", {}),
    }


def load_presets(path: Path) -> list[str]:
    if not path.is_file():
        raise FileNotFoundError(f"presets not found: {path}")
    names = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(names, list) or not all(isinstance(n, str) for n in names):
        raise ValueError("presets must be a JSON array of block-name strings")
    return names


_BLOCK_CACHE: dict[tuple[str, int, str], tuple[tuple[int, int, int], ...]] = {}


def block_texels(name: str, blocks_dir: Path, n: int) -> tuple[tuple[int, int, int], ...]:
    """Deterministically sample a port block PNG into n*n RGB texels."""
    key = (name, n, str(blocks_dir))
    if key in _BLOCK_CACHE:
        return _BLOCK_CACHE[key]
    png = blocks_dir / f"{name}.png"
    if not png.is_file():
        raise FileNotFoundError(f"block PNG not found: {png}")
    with Image.open(png) as im:
        rgb = im.convert("RGB")
        sampled = rgb.resize((n, n), Image.Resampling.LANCZOS)
        # Pillow >=14 deprecates getdata(); keep a fallback for older Pillow.
        if hasattr(sampled, "get_flattened_data"):
            texels = tuple(sampled.get_flattened_data())
        else:  # pragma: no cover - older Pillow
            texels = tuple(sampled.getdata())
    _BLOCK_CACHE[key] = texels
    return texels


def resolve_ids(dump: dict, presets: list[str], water_block: str) -> dict[int, str]:
    """Map every tile id actually present in the dump to a block name."""
    out: dict[int, str] = {}
    for tid in sorted(set(dump["tiles"])):
        if tid == WATER_ID:
            out[tid] = water_block
        elif 0 <= tid < len(presets):
            out[tid] = presets[tid]
        else:
            raise ValueError(f"tileblock id {tid} outside presets[0..{len(presets) - 1}] (and not {WATER_ID})")
    return out


def analyse(dump: dict, presets: list[str], water_block: str, blocks_dir: Path) -> tuple[dict[int, str], list[tuple[int, str]]]:
    names = resolve_ids(dump, presets, water_block)
    missing = [(tid, nm) for tid, nm in names.items() if not (blocks_dir / f"{nm}.png").is_file()]
    return names, missing


def build_splat(dump: dict, names: dict[int, str], water_block: str, blocks_dir: Path,
                alpha_mode: str, blend_radius: int, blend_eps: float, texels: int) -> tuple[Image.Image, dict]:
    w, h = dump["map_w"], dump["map_h"]
    heights, tiles = dump["heights"], dump["tiles"]
    H, W = h * texels, w * texels

    # One sampled block image per used id; no per-pixel image I/O in the loop.
    texel_by_id = {tid: block_texels(nm, blocks_dir, texels) for tid, nm in names.items()}

    hmin, hmax = min(heights), max(heights)
    hrange = hmax - hmin
    fam_by_id = {tid: family(nm) for tid, nm in names.items()}
    rough_by_id = {tid: roughness_for(nm) for tid, nm in names.items()}

    # Offsets: own cell always carries weight 4; neighbours are accepted only
    # when they share a block family or are within blend_eps metres in height.
    neighbours = [(dx, dy) for dy in range(-blend_radius, blend_radius + 1)
                  for dx in range(-blend_radius, blend_radius + 1)
                  if (dx or dy) and abs(dx) + abs(dy) <= blend_radius]

    buf = bytearray(W * H * 4)
    for py in range(H):
        cy, sy = divmod(py, texels)
        for px in range(W):
            cx, sx = divmod(px, texels)
            ci = cy * w + cx
            tid = tiles[ci]
            sub = sy * texels + sx
            sr, sg, sb = texel_by_id[tid][sub]
            sw = 4
            if neighbours:
                own_h = heights[ci]
                own_fam = fam_by_id[tid]
                for dx, dy in neighbours:
                    nx, ny = cx + dx, cy + dy
                    if nx < 0 or ny < 0 or nx >= w or ny >= h:
                        continue
                    ni = ny * w + nx
                    nid = tiles[ni]
                    if fam_by_id[nid] != own_fam and abs(heights[ni] - own_h) > blend_eps:
                        continue
                    r, g, b = texel_by_id[nid][sub]
                    sr += r
                    sg += g
                    sb += b
                    sw += 1

            if alpha_mode == "height":
                a = 255 if hrange <= 0 else half_up(255.0 * (heights[ci] - hmin) / hrange)
            elif alpha_mode == "roughness":
                a = rough_by_id[tid]
            else:
                a = 255

            o = (py * W + px) * 4
            buf[o] = half_up(sr / sw)
            buf[o + 1] = half_up(sg / sw)
            buf[o + 2] = half_up(sb / sw)
            buf[o + 3] = a

    image = Image.frombytes("RGBA", (W, H), bytes(buf))
    stats = {
        "used_ids": sorted(names),
        "height_min_m": round(hmin, 6),
        "height_max_m": round(hmax, 6),
        "output_size": [W, H],
    }
    return image, stats


def manifest_payload(dump: dict, names: dict[int, str], blocks_dir: Path, args: argparse.Namespace,
                     stats: dict, out: Path) -> dict:
    mapping = []
    for tid in stats["used_ids"]:
        nm = names[tid]
        mean = block_texels(nm, blocks_dir, 1)[0]
        count = sum(1 for v in dump["tiles"] if v == tid)
        mapping.append({
            "id": tid,
            "name": nm,
            "family": family(nm),
            "is_water_sentinel": tid == WATER_ID,
            "mean_rgb": list(mean),
            "roughness_proxy": roughness_for(nm),
            "cell_count": count,
        })
    return {
        "tool": "heightmap_splat.py",
        "tool_version": TOOL_VERSION,
        "input_dump": str(dump["path"].relative_to(ROOT)) if dump["path"].is_relative_to(ROOT) else str(dump["path"]),
        "input_dump_sha256": dump["sha256"],
        "input_seed": dump["seed"],
        "map_w": dump["map_w"],
        "map_h": dump["map_h"],
        "output_file": str(out.relative_to(ROOT)) if out.is_relative_to(ROOT) else str(out),
        "output_size": stats["output_size"],
        "channels": {"RGB": "blended port block albedo (sRGB bytes)",
                     "A": args.alpha + (" = normalised heap height" if args.alpha == "height"
                                        else " = roughness proxy" if args.alpha == "roughness" else " = 255")},
        "alpha_mode": args.alpha,
        "blend_radius_cells": args.blend_radius,
        "blend_height_eps_m": args.blend_height_eps,
        "texels_per_cell": args.texels_per_cell,
        "water_block": args.water_block,
        "height_min_m": stats["height_min_m"],
        "height_max_m": stats["height_max_m"],
        "mapping": mapping,
        "determinism": "no randomness; fixed LANCZOS resize, half-up rounding; byte-identical on re-run",
    }


def dry_report(dump: dict, names: dict[int, str], missing: list[tuple[int, str]],
               presets: list[str], blocks_dir: Path, args: argparse.Namespace) -> None:
    print("DRY RUN - no files written")
    print(f"input dump      : {dump['path']} (sha256 {dump['sha256'][:16]}..., seed {dump['seed']})")
    print(f"grid            : {dump['map_w']}x{dump['map_h']} = {dump['map_w'] * dump['map_h']} cells")
    print(f"presets         : {len(presets)} names; block PNGs found in {blocks_dir}")
    print(f"predicted output: {args.out} {dump['map_w'] * args.texels_per_cell}x{dump['map_h'] * args.texels_per_cell} RGBA (NOT written)")
    print(f"channels        : RGB=blended block albedo; A={args.alpha}")
    print(f"blend           : radius {args.blend_radius} cell(s), height eps {args.blend_height_eps} m")
    print(f"water sentinel  : id {WATER_ID} -> {args.water_block}")
    print("id -> block name -> mean RGB (used ids only):")
    for tid in sorted(names):
        nm = names[tid]
        mean = block_texels(nm, blocks_dir, 1)[0] if (blocks_dir / f"{nm}.png").is_file() else None
        print(f"  {tid:3d} -> {nm:16s} -> {mean if mean else '<MISSING PNG>'}")
    if missing:
        print("MISSING BLOCK PNGs: " + ", ".join(f"{tid}:{nm}" for tid, nm in missing))
    else:
        print("MISSING BLOCK PNGs: none for used ids")
    print("No donor file read. No Godot launch. No randomness.")


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Deterministic donor-block splat/albedo PNG for the G3-2 heightmap mesh.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=SCHEMA_TEXT + "\nUV: cell (x,y) centre -> u=(x+0.5)/map_w, v=(y+0.5)/map_h.\n",
    )
    p.add_argument("--dump", type=Path, default=DEFAULT_DUMP,
                   help=f"map dump JSON (default: {DEFAULT_DUMP})")
    p.add_argument("--out", type=Path, default=DEFAULT_OUT,
                   help=f"output RGBA PNG (default: {DEFAULT_OUT})")
    p.add_argument("--presets", type=Path, default=DEFAULT_PRESETS,
                   help="presets_summer.json (index -> block name)")
    p.add_argument("--blocks-dir", type=Path, default=DEFAULT_BLOCKS,
                   help="directory of donor-derived block PNGs")
    p.add_argument("--alpha", choices=ALPHA_MODES, default="height",
                   help="A channel: normalised height (default), roughness proxy, or 255")
    p.add_argument("--blend-radius", type=int, default=1,
                   help="cell blend radius, 0 disables neighbour blending (default: 1)")
    p.add_argument("--blend-height-eps", type=float, default=0.25,
                   help="max height delta in metres for cross-family blending (default: 0.25)")
    p.add_argument("--texels-per-cell", type=int, default=1,
                   help="output texels per grid cell; 1 gives map_w x map_h (default: 1)")
    p.add_argument("--water-block", default=DEFAULT_WATER_BLOCK,
                   help=f"albedo block for BLK_WATER id {WATER_ID} (default: {DEFAULT_WATER_BLOCK})")
    p.add_argument("--dry-run", action="store_true",
                   help="parse and validate, print id->name mapping, write nothing")
    p.add_argument("--schema", action="store_true",
                   help="print the expected dump schema and exit")
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.schema:
        print(SCHEMA_TEXT, end="")
        return 0
    if args.blend_radius < 0 or args.texels_per_cell < 1:
        print("--blend-radius must be >= 0 and --texels-per-cell must be >= 1", file=sys.stderr)
        return 2

    try:
        dump = load_dump(args.dump)
        presets = load_presets(args.presets)
        names, missing = analyse(dump, presets, args.water_block, args.blocks_dir)
        if missing:
            print("ERROR: used block PNGs missing: " + ", ".join(f"{i}:{n}" for i, n in missing), file=sys.stderr)
            return 2
        if args.dry_run:
            dry_report(dump, names, missing, presets, args.blocks_dir, args)
            return 0

        image, stats = build_splat(dump, names, args.water_block, args.blocks_dir,
                                   args.alpha, args.blend_radius, args.blend_height_eps,
                                   args.texels_per_cell)
        args.out.parent.mkdir(parents=True, exist_ok=True)
        image.save(args.out, format="PNG", optimize=False)
        manifest = args.out.with_suffix(".manifest.json")
        manifest.write_text(json.dumps(manifest_payload(dump, names, args.blocks_dir, args, stats, args.out),
                                       indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"wrote {args.out} {image.width}x{image.height} RGBA (alpha={args.alpha})")
        print(f"wrote {manifest}")
    except (FileNotFoundError, ValueError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        if not args.dump.is_file():
            print(f"Hint: g32_dump.json is not available yet; pass an existing dump via --dump "
                  f"or use --dry-run with one. See --help for the schema.", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
