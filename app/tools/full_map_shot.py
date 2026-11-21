#!/usr/bin/env python3
"""full_map_shot.py - whole-map confrontation PNG (T2-INFRA-2, TOOL lane).

What this produces
------------------
ONE PNG of the entire generated map at its *texture* resolution:

    png_width  = map_w * tile_px
    png_height = map_h * tile_px

`tile_px` defaults to **64**, the high-preset baked pixels per tile:
``Data.TERRAIN_PX = 16`` (data.gd:114, high quality data.gd:157-158) and
``world.gd:_bake_px() = mini(terrain_px * 4, 64) = 64`` (world.gd:877-880).
So a 320x320-tile confrontation map becomes a 20480x20480 PNG.

``--tile-px 1`` is kept as a cheap compact diagnostic: the PNG is then exactly
``map_w x map_h`` (one pixel per cell) for a quick layout check. It is NOT the
canonical confrontation size.

Why approach (a) - decoder/compositor - was chosen
-------------------------------------------------
The alternative (b), driving the real Godot renderer and stitching screenshots,
is rejected:

  * headless ``--screenshot`` is NOT a map capture: ``main.gd:_save_screenshot()``
    calls ``_render_headless_image(800, 600)`` - a fixed 800x600 CPU fallback,
    already rejected by ``terrain_sample_shot.py``'s real-renderer gate;
  * windowed capture is a fixed 1280x720 viewport (a zoomed subset), so it never
    shows a 320-tile map at once; whole-map coverage would need scripted camera
    panning and stitching dozens of GPU frames at drifting zoom - slow and
    non-deterministic, and every Godot launch must be serialised through the
    runner anyway.

The compositor below is headless, deterministic and byte-reproducible: it reads
the ``--dump-map`` JSON (base64 terrain/height/tileblock) and pastes the real
port block PNGs from ``app/assets/terrain/blocks/``.

FIDELITY CAVEAT: this is a DIAGNOSTIC COMPOSITOR, not the exact in-game renderer.
It reproduces tile choice / placement / season tint / water / resources, but
not Godot's SmoothTiles cross-fade, the water shader, lighting, fog or sprites.
It is suitable for confrontation-overview and layout checking, not for beauty
comparison. Use a real windowed ``--screenshot`` for that (see --crosscheck-png).

All Godot invocations go through app/tools/godot_runner.py with ``t2full-*`` ids.
The tool never launches ``godot`` directly.

Examples (from the project root)::

    # 1) generate a dump through the runner (headless, seed 20261113, default 320x320 config)
    python app/tools/full_map_shot.py --gen-dump --seed 20261113 \
        --dump app/shots/full_map_dump.json

    # 2) canonical 320*64 = 20480x20480 confrontation PNG
    python app/tools/full_map_shot.py --dump app/shots/full_map_dump.json \
        --out app/shots/full_map_20480x20480_tile64.png --tile-px 64

    # 3) compact 320x320 layout diagnostic
    python app/tools/full_map_shot.py --dump app/shots/full_map_dump.json --tile-px 1

    # 4) consume a real windowed screenshot for cross-checking (no Godot launched)
    python app/tools/full_map_shot.py --dump app/shots/full_map_dump.json \
        --crosscheck-png app/shots/windowed.png
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import re
import struct
import subprocess
import sys
import time
import zlib
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image, ImageDraw

# A 320x320 map at tile_px=64 is 419 Mpx - Pillow's default 178 Mpx
# "decompression bomb" guard rejects even a header-only Image.open(). Our own
# files are trusted, so lift the cap; verification still only reads the header.
Image.MAX_IMAGE_PIXELS = None

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent
ROOT = APP.parent
RUNNER = TOOLS / "godot_runner.py"
SHOTS = APP / "shots"
BLOCKS = APP / "assets" / "terrain" / "blocks"
PRESETS = APP / "assets" / "terrain" / "structs" / "presets_summer.json"

BLK_WATER = 255                       # game.gd:37
TERRAIN_NAMES = {0: "grass", 1: "road", 2: "forest", 3: "water", 4: "sand", 5: "rock"}
# data.gd:191-195 TERRAIN_TINT (multiplicative). world.gd blends these at 0.34
# strength for a subtle glaze; here we apply them at full strength so the
# diagnostic visibly distinguishes seasons.
SEASON_TINT = {
    "summer": (1.00, 1.00, 1.00),
    "winter": (0.86, 0.91, 1.00),
    "desert": (1.00, 0.90, 0.70),
}
RESOURCE_COLORS = {
    "gold": (255, 205, 40),
    "iron": (185, 190, 200),
    "coal": (55, 58, 68),
    "wood": (140, 92, 44),
    "stone": (170, 168, 156),
    "food": (210, 190, 90),
}
VARIANTS = 4                          # deterministic per-block crop variants
WATER_STEPS = 4                       # depth buckets for the water tint
BAND_TILE_ROWS = 16                   # tile rows per streamed PNG band

CAVEAT = (
    "DIAGNOSTIC COMPOSITOR, not the exact in-game renderer: real port block PNGs "
    "and the dumped tileblock grid are used, but Godot SmoothTiles cross-fade, "
    "the water shader, lighting and sprites are not reproduced. Cross-check "
    "against a real windowed --screenshot before any beauty comparison."
)
APPROACH = (
    "(a) decoder/compositor: --dump-map JSON + app/assets/terrain/blocks PNGs; "
    "(b) Godot screenshot stitching rejected (headless is an 800x600 CPU "
    "fallback; windowed is a fixed 1280x720 zoomed viewport)."
)


# ---------------------------------------------------------------------------
# runner plumbing (the ONLY legal way to start Godot)
# ---------------------------------------------------------------------------
def gen_dump(seed: int, dump_rel: str, config_rel: str | None,
             game_timeout: int = 120, runner_timeout: int = 300) -> dict:
    """Submit one headless --dump-map job through godot_runner.py (t2full-*)."""
    job_id = "t2full-dump-%d" % seed
    args = [
        "run", "--id", job_id,
        "--timeout", str(runner_timeout), "--max-wait", "3600", "--",
        "--headless", "--path", "app", "--",
        "--seed", str(seed),
    ]
    if config_rel:
        args += ["--config", config_rel]
    args += ["--dump-map", dump_rel, "--timeout", str(game_timeout)]

    cmd = [sys.executable, str(RUNNER), *args]
    print("[runner] " + " ".join(str(c) for c in cmd), flush=True)
    t0 = time.time()
    proc = subprocess.run(cmd, cwd=str(ROOT), capture_output=True, text=True,
                          encoding="utf-8", errors="replace",
                          timeout=runner_timeout + 3600 + 120)
    for line in proc.stdout.splitlines():
        if line.strip():
            print("  | " + line)
    for line in proc.stderr.splitlines():
        if line.strip():
            print("  ! " + line, file=sys.stderr)

    ticket = None
    status = None
    for line in proc.stdout.splitlines():
        m = re.search(r"ticket (\d+) '([^']+)' START", line)
        if m and m.group(2) == job_id:
            ticket = int(m.group(1))
        m = re.search(r"ticket (\d+) '([^']+)' END (\w+)", line)
        if m and m.group(2) == job_id:
            ticket = int(m.group(1))
            status = m.group(3)
    result = {"id": job_id, "ticket": ticket, "status": status,
              "exit": proc.returncode, "secs": round(time.time() - t0, 2)}
    if ticket is not None:
        rp = ROOT / "app" / ".godot_queue" / "results" / ("%08d.json" % ticket)
        if rp.exists():
            try:
                data = json.loads(rp.read_text(encoding="utf-8"))
                result.update(status=data.get("status", status),
                              wait=data.get("wait"), run=data.get("run"))
            except (OSError, ValueError):
                pass
    return result


# ---------------------------------------------------------------------------
# dump decoding
# ---------------------------------------------------------------------------
def _b64_bytes(s: str) -> bytes:
    return base64.b64decode(s or "")


def decode_dump(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    w, h = int(data["map_w"]), int(data["map_h"])
    n = w * h
    terrain = _b64_bytes(data.get("terrain", ""))
    tileblock = _b64_bytes(data.get("tileblock", ""))
    height_raw = _b64_bytes(data.get("height", ""))

    def fit(raw: bytes, fill: int = 0) -> bytes:
        if len(raw) == n:
            return raw
        if len(raw) > n:
            return raw[:n]
        return raw + bytes([fill]) * (n - len(raw))

    terrain = fit(terrain)
    tileblock = fit(tileblock, 1)

    # height is PackedFloat32Array.to_byte_array() -> 4 little-endian bytes/cell
    heights: list[float] = [0.0] * n
    if len(height_raw) >= 4 * n:
        heights = list(struct.unpack("<%df" % n, height_raw[:4 * n]))
    elif len(height_raw) >= n:
        heights = [float(v) for v in height_raw[:n]]

    meta = data.get("meta") or {}
    return {
        "map_w": w, "map_h": h, "cells": n,
        "seed": data.get("seed"),
        "terrain": terrain, "tileblock": tileblock, "height": heights,
        "res": data.get("res") or [],
        "starts": data.get("starts") or [],
        "mask": meta.get("mask"),
        "meta": meta,
        "season": str(meta.get("season") or "summer"),
        "raw": data,
    }


def load_block_names() -> list[str]:
    return json.loads(PRESETS.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# tile preparation
# ---------------------------------------------------------------------------
def _tint(im: Image.Image, tint: tuple[float, float, float]) -> Image.Image:
    if tint == (1.0, 1.0, 1.0):
        return im
    chans = []
    for ch, m in zip(im.split(), tint):
        chans.append(ch.point(lambda v, mm=m: min(255, int(v * mm))))
    return Image.merge("RGB", chans)


def _crop_variant(src: Image.Image, v: int, tile_px: int) -> Image.Image:
    sw, sh = src.size
    size = min(sw, sh, max(tile_px * 4, min(sw, sh) // 2))
    step = max(1, sw - size)
    stepy = max(1, sh - size)
    ox = (v * step // VARIANTS) if VARIANTS > 1 else 0
    oy = (v * stepy // VARIANTS) if VARIANTS > 1 else 0
    ox, oy = min(ox, sw - size), min(oy, sh - size)
    patch = src.crop((ox, oy, ox + size, oy + size))
    return patch.resize((tile_px, tile_px), Image.Resampling.BILINEAR)


def build_tiles(dump: dict, names: list[str], tile_px: int) -> tuple[dict, dict, dict]:
    """Return (block_tiles, water_tiles, resource_tiles) of PIL images."""
    tint = SEASON_TINT.get(dump["season"], SEASON_TINT["summer"])
    used = sorted({int(b) for b in dump["tileblock"] if b != BLK_WATER and 0 <= b < len(names)})
    block_tiles: dict[str, list[Image.Image]] = {}
    grass1 = None
    for bi in used:
        nm = names[bi]
        p = BLOCKS / (nm + ".png")
        if not p.exists():
            continue
        src = Image.open(p).convert("RGB")
        variants = [_tint(_crop_variant(src, v, tile_px), tint) for v in range(VARIANTS)]
        block_tiles[nm] = variants
        if nm == "grass1":
            grass1 = variants

    if grass1 is None:
        p = BLOCKS / "grass1.png"
        src = Image.open(p).convert("RGB") if p.exists() else Image.new("RGB", (64, 64), (76, 82, 30))
        grass1 = [_tint(_crop_variant(src, 0, tile_px), tint)]
        block_tiles["grass1"] = grass1

    # Water: tint the grass grain with a depth-dependent blue glaze.
    water_tiles: list[Image.Image] = []
    for k in range(WATER_STEPS):
        depth = k / max(1, WATER_STEPS - 1)
        col = (int(70 - 45 * depth), int(130 - 55 * depth), int(165 - 45 * depth))
        layer = Image.new("RGB", (tile_px, tile_px), col)
        water_tiles.append(Image.blend(grass1[0], layer, 0.40 + 0.35 * depth))

    # Resources: a coloured marker over the local grass tile.
    resource_tiles: dict[str, Image.Image] = {}
    for typ, col in RESOURCE_COLORS.items():
        if tile_px <= 2:
            resource_tiles[typ] = Image.new("RGB", (tile_px, tile_px), col)
        else:
            base = grass1[0].copy()
            d = ImageDraw.Draw(base)
            r = max(1, tile_px // 5)
            cx = cy = tile_px // 2
            d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=col)
            resource_tiles[typ] = base

    return block_tiles, water_tiles, resource_tiles


def choose_cells(dump: dict, names: list[str], block_tiles: dict,
                 water_tiles: list, resource_tiles: dict) -> tuple[list, dict]:
    """One tile image per cell, plus histogram bookkeeping."""
    w, h = dump["map_w"], dump["map_h"]
    terr, tb, heights = dump["terrain"], dump["tileblock"], dump["height"]
    res_map: dict[int, str] = {}
    for r in dump["res"]:
        try:
            x, y = int(round(float(r["x"]))), int(round(float(r["y"])))
            t = str(r.get("t", ""))
        except (ValueError, TypeError, KeyError):
            continue
        if 0 <= x < w and 0 <= y < h:
            res_map[y * w + x] = t if t in resource_tiles else "gold"

    cells: list[Image.Image] = []
    fallback = block_tiles["grass1"][0]
    for i in range(w * h):
        x = i % w
        y = i // w
        if int(terr[i]) == 3 or int(tb[i]) == BLK_WATER:
            depth = min(1.0, max(0.0, -float(heights[i])))
            cells.append(water_tiles[min(WATER_STEPS - 1, int(depth * WATER_STEPS))])
        elif i in res_map:
            cells.append(resource_tiles[res_map[i]])
        else:
            bi = int(tb[i])
            nm = names[bi] if 0 <= bi < len(names) else "grass1"
            variants = block_tiles.get(nm)
            cells.append(variants[(x * 7 + y * 13) % VARIANTS] if variants else fallback)

    hist = Counter(int(v) for v in terr)
    tb_hist = Counter(names[int(b)] for b in tb
                      if int(b) != BLK_WATER and 0 <= int(b) < len(names))
    detail = {
        "terrain_histogram": {TERRAIN_NAMES.get(k, str(k)): hist.get(k, 0)
                              for k in sorted(hist)},
        "terrain_histogram_by_code": {str(k): hist.get(k, 0) for k in sorted(hist)},
        "tileblock_top12": dict(tb_hist.most_common(12)),
        "resources_drawn": len(res_map),
        "starts_cells": [{"x": int(round(float(s["x"]))), "y": int(round(float(s["y"])))}
                         for s in dump["starts"]],
    }
    return cells, detail


# ---------------------------------------------------------------------------
# streaming PNG writer (no full-size RGB buffer - avoids the 1.2-1.7 GB spike)
# ---------------------------------------------------------------------------
def _png_chunk(f, typ: bytes, payload: bytes) -> None:
    f.write(struct.pack(">I", len(payload)))
    f.write(typ)
    f.write(payload)
    f.write(struct.pack(">I", zlib.crc32(typ + payload) & 0xFFFFFFFF))


def write_png_streaming(path: Path, cells: list, map_w: int, map_h: int,
                        tile_px: int) -> dict:
    W, H = map_w * tile_px, map_h * tile_px
    band_rows = max(1, BAND_TILE_ROWS)
    band_h = tile_px * band_rows
    peak = W * band_h * 3
    comp = zlib.compressobj(level=6)
    band_count = (map_h + band_rows - 1) // band_rows
    t0 = time.time()
    # Unique temp name: a previous large write may still be held briefly by an
    # antivirus scanner, and another worker may be writing into app/shots too.
    tmp = path.with_name("%s.%d.part" % (path.name, os.getpid()))

    with open(tmp, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        _png_chunk(f, b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
        pending = bytearray()
        for bi in range(band_count):
            y0 = bi * band_rows
            rows_h = min(band_rows, map_h - y0)
            band = Image.new("RGB", (W, tile_px * rows_h))
            for ty in range(rows_h):
                gy = y0 + ty
                for gx in range(map_w):
                    band.paste(cells[gy * map_w + gx],
                               (gx * tile_px, ty * tile_px))
            raw = band.tobytes()
            stride = W * 3
            for r in range(tile_px * rows_h):
                off = r * stride
                pending += comp.compress(b"\x00" + raw[off:off + stride])
            if len(pending) >= 8 * 1024 * 1024:
                _png_chunk(f, b"IDAT", bytes(pending))
                pending.clear()
            band.close()
        pending += comp.flush()
        if pending:
            _png_chunk(f, b"IDAT", bytes(pending))
        _png_chunk(f, b"IEND", b"")
        f.flush()
    # On Windows a just-written large file is often held open for a moment by
    # antivirus indexing; retry the atomic rename instead of failing the whole
    # 20k x 20k encode over a transient sharing violation.
    last = None
    for attempt in range(20):
        try:
            tmp.replace(path)
            last = None
            break
        except OSError as exc:
            last = exc
            time.sleep(0.5 * (attempt + 1) / 2.0)
    if last is not None:
        raise last

    return {
        "seconds": round(time.time() - t0, 2),
        "peak_band_bytes": peak,
        "peak_band_mb": round(peak / 2**20, 1),
        "file_bytes": path.stat().st_size,
        "bands": band_count,
    }


def compose(path: Path, dump: dict, tile_px: int) -> dict:
    names = load_block_names()
    block_tiles, water_tiles, resource_tiles = build_tiles(dump, names, tile_px)
    cells, detail = choose_cells(dump, names, block_tiles, water_tiles, resource_tiles)
    stats = write_png_streaming(path, cells, dump["map_w"], dump["map_h"], tile_px)
    return {**detail, **stats,
            "block_names_used": sorted(block_tiles),
            "variants_per_block": VARIANTS,
            "water_steps": WATER_STEPS}


# ---------------------------------------------------------------------------
# cross-check (consume a real windowed screenshot; no Godot launched here)
# ---------------------------------------------------------------------------
def crosscheck_png(path: Path) -> dict:
    out = {"path": str(path.relative_to(ROOT)) if path.is_absolute() else str(path),
           "exists": path.exists()}
    if not path.exists():
        out["error"] = "screenshot not found"
        return out
    out["bytes"] = path.stat().st_size
    try:
        with Image.open(path) as im:
            out["dimensions"] = list(im.size)
            out["mode"] = im.mode
            if out["bytes"] < 100 * 1024 * 1024:
                luma = im.convert("L")
                cols = luma.getcolors(maxcolors=1 << 20)
                out["luminance_levels"] = len(cols) if cols else ">1M"
        out["is_800x600_fallback"] = out.get("dimensions") == [800, 600]
        out["note"] = (
            "800x600 means the headless CPU fallback fired; a real windowed "
            "capture is 1280x720 and shows only a zoomed viewport subset."
        )
    except Exception as exc:  # noqa: BLE001 - diagnostic only
        out["error"] = repr(exc)
    return out


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dump", help="--dump-map JSON (base64 terrain/height/tileblock)")
    ap.add_argument("--gen-dump", action="store_true",
                    help="generate the dump first via godot_runner.py (t2full-*)")
    ap.add_argument("--seed", type=int, default=20261113,
                    help="seed for --gen-dump (default: 20261113)")
    ap.add_argument("--config", default=None,
                    help="optional --config file for the Godot dump (default: app/config.json)")
    ap.add_argument("--tile-px", type=int, default=64,
                    help="pixels per tile; default 64 (high-preset baked bpx). "
                         "Use 1 for a compact map_w x map_h diagnostic.")
    ap.add_argument("--out", default=None,
                    help="output PNG (default: app/shots/full_map_<W>x<H>_tile<T>.png)")
    ap.add_argument("--crosscheck-png", default=None,
                    help="existing real windowed screenshot to consume for cross-check")
    ap.add_argument("--game-timeout", type=int, default=120,
                    help="in-game wall-clock watchdog passed to Godot")
    ap.add_argument("--runner-timeout", type=int, default=300,
                    help="hard per-job process-tree kill in the runner")
    args = ap.parse_args(argv)

    if args.tile_px < 1:
        print("ERROR: --tile-px must be >= 1", file=sys.stderr)
        return 2

    runner_job = None
    dump_path = Path(args.dump) if args.dump else SHOTS / "full_map_dump.json"
    if args.gen_dump:
        rel = str(dump_path.relative_to(ROOT)) if dump_path.is_absolute() else str(dump_path)
        runner_job = gen_dump(args.seed, rel, args.config,
                              args.game_timeout, args.runner_timeout)
        if runner_job.get("status") != "ok":
            print("ERROR: dump job failed: %s" % runner_job, file=sys.stderr)
            return 1
        if not dump_path.exists():
            # Godot resolves relative paths against res:// (app/); retry there.
            alt = APP / rel
            if alt.exists():
                dump_path = alt
            else:
                print("ERROR: dump file missing after runner job: %s" % dump_path,
                      file=sys.stderr)
                return 1

    if not dump_path.exists():
        print("ERROR: dump not found: %s (pass --dump or --gen-dump)" % dump_path,
              file=sys.stderr)
        return 2
    if dump_path.is_absolute():
        dump_rel = str(dump_path.relative_to(ROOT))
    else:
        dump_rel = str(dump_path)
        dump_path = ROOT / dump_path

    dump = decode_dump(dump_path)
    w, h, tile_px = dump["map_w"], dump["map_h"], args.tile_px
    W, H = w * tile_px, h * tile_px
    if args.out:
        out_path = Path(args.out)
    else:
        out_path = SHOTS / ("full_map_%dx%d_tile%d.png" % (W, H, tile_px))
    if not out_path.is_absolute():
        out_path = ROOT / out_path
    out_path.parent.mkdir(parents=True, exist_ok=True)

    print("[compose] map=%dx%d cells  tile_px=%d  png=%dx%d" % (w, h, tile_px, W, H))
    print("[compose] dump=%s  out=%s" % (dump_rel, out_path.relative_to(ROOT)))

    compose_stats = None
    used_tile_px = tile_px
    fallbacks: list[str] = []
    while True:
        try:
            compose_stats = compose(out_path, dump, used_tile_px)
            break
        except (OSError, MemoryError, ValueError) as exc:
            nxt = used_tile_px // 2
            fallbacks.append("tile_px=%d failed (%s)" % (used_tile_px, exc))
            out_path.unlink(missing_ok=True)
            for stale in out_path.parent.glob(out_path.name + ".*.part"):
                try:
                    stale.unlink(missing_ok=True)
                except OSError:
                    pass
            if nxt < 1:
                print("ERROR: could not write any exact-multiple size: %s" % fallbacks,
                      file=sys.stderr)
                return 1
            print("[compose] %s -> retrying exact multiple tile_px=%d" %
                  (fallbacks[-1], nxt), file=sys.stderr)
            used_tile_px = nxt

    W, H = w * used_tile_px, h * used_tile_px
    # Rename if a fallback changed the actual size.
    if used_tile_px != tile_px:
        renamed = out_path.with_name(
            "full_map_%dx%d_tile%d.png" % (W, H, used_tile_px))
        out_path.replace(renamed)
        out_path = renamed

    # Verify with Pillow (header read only - does not decode 20k² pixels).
    with Image.open(out_path) as im:
        png_w, png_h = im.size
        verified_mode = im.mode
    assert png_w == w * used_tile_px and png_h == h * used_tile_px, (
        "PNG %dx%d != map %dx%d * tile_px %d" %
        (png_w, png_h, w, h, used_tile_px))

    sidecar = {
        "tool": "full_map_shot.py",
        "approach": APPROACH,
        "caveat": CAVEAT,
        "canonical_size_rule": "png_width = map_w * tile_px; png_height = map_h * tile_px",
        "generated_utc": datetime.now(timezone.utc).isoformat(),
        "dump": dump_rel,
        "map_w": w, "map_h": h,
        "tile_px": used_tile_px,
        "requested_tile_px": tile_px,
        "png_width": png_w, "png_height": png_h,
        "png_mode": verified_mode,
        "png_path": str(out_path.relative_to(ROOT)),
        "seed": dump["seed"],
        "mask": dump["mask"],
        "season": dump["season"],
        "fallbacks": fallbacks,
        "assertions": {
            "png_equals_map_times_tile_px":
                (png_w == w * used_tile_px and png_h == h * used_tile_px),
            "compact_one_px_per_cell": used_tile_px == 1,
        },
        "runner_job": runner_job,
        "compose": compose_stats,
        "crosscheck": crosscheck_png(Path(args.crosscheck_png)) if args.crosscheck_png else None,
    }
    for k, v in compose_stats.items():
        if k in ("terrain_histogram", "terrain_histogram_by_code",
                 "tileblock_top12", "resources_drawn", "starts_cells",
                 "block_names_used", "variants_per_block", "water_steps"):
            sidecar[k] = v

    sidecar_path = out_path.with_suffix(".json")
    sidecar_path.write_text(json.dumps(sidecar, indent=2, sort_keys=True), encoding="utf-8")

    print("[done] png=%s  %dx%d  tile_px=%d  %.1fs  %.1f MB file  peak band %.1f MB" % (
        out_path.relative_to(ROOT), png_w, png_h, used_tile_px,
        compose_stats["seconds"], compose_stats["file_bytes"] / 2**20,
        compose_stats["peak_band_mb"]))
    print("[done] sidecar=%s" % sidecar_path.relative_to(ROOT))
    if fallbacks:
        print("[caveat] fallbacks: %s" % "; ".join(fallbacks), file=sys.stderr)
    print("[caveat] " + CAVEAT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
