#!/usr/bin/env python3
"""Labelled contact sheet from captured frames, with pixel-preserving tiling.

Default: NO RESCALE.  Every source frame is pasted 1:1 at the top-left of its
cell; text goes in a separate band above the image, never over it.  `--fit`
rescales explicitly, and both the label band and the sidecar JSON say so.

Inputs: --frame FILE (repeatable), --dir DIR (glob frame_*.png by default) and
--manifest PATH (from capture_sequence.py).  Sources are de-duplicated by
resolved path and sorted, so the same inputs give the same sheet.

Example:
  python variant3d/tools/acceptance/contact_sheet.py \
      --manifest inbox/qa/captures/abrun_20261113/manifest.json \
      --out inbox/qa/captures/abrun_20261113/contact.png --cols 4 --hash-labels

Pillow, when present, is used for antialiased text and resampling.  Without
Pillow the built-in PNG reader plus a tiny 5x7 bitmap font tiled sheet still
works; `--fit` is refused (see README limitations).  Nothing is synthesised.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

from imgio import HAS_PIL, Raster, hash_file, load_rgb, save_png

ROOT = Path(__file__).resolve().parents[3]  # repo root
RESAMPLE = {"nearest", "bilinear", "bicubic", "lanczos"}
EXIT_OK, EXIT_BAD = 0, 2

# Minimal 5x7 font for the non-Pillow path (row bitmasks, bit 4 = left pixel).
_FONT = {
    " ": (0, 0, 0, 0, 0, 0, 0),
    "A": (14, 17, 17, 31, 17, 17, 17), "B": (30, 17, 17, 30, 17, 17, 30),
    "C": (14, 17, 16, 16, 16, 17, 14), "D": (30, 17, 17, 17, 17, 17, 30),
    "E": (31, 16, 16, 30, 16, 16, 31), "F": (31, 16, 16, 30, 16, 16, 16),
    "G": (14, 17, 16, 23, 17, 17, 15), "H": (17, 17, 17, 31, 17, 17, 17),
    "I": (14, 4, 4, 4, 4, 4, 14), "J": (7, 2, 2, 2, 2, 18, 12),
    "K": (17, 18, 20, 24, 20, 18, 17), "L": (16, 16, 16, 16, 16, 16, 31),
    "M": (17, 27, 21, 21, 17, 17, 17), "N": (17, 25, 21, 19, 17, 17, 17),
    "O": (14, 17, 17, 17, 17, 17, 14), "P": (30, 17, 17, 30, 16, 16, 16),
    "Q": (14, 17, 17, 17, 21, 18, 13), "R": (30, 17, 17, 30, 20, 18, 17),
    "S": (15, 16, 16, 14, 1, 1, 30), "T": (31, 4, 4, 4, 4, 4, 4),
    "U": (17, 17, 17, 17, 17, 17, 14), "V": (17, 17, 17, 17, 17, 10, 4),
    "W": (17, 17, 17, 21, 21, 27, 17), "X": (17, 17, 10, 4, 10, 17, 17),
    "Y": (17, 17, 10, 4, 4, 4, 4), "Z": (31, 1, 2, 4, 8, 16, 31),
    "0": (14, 17, 19, 21, 25, 17, 14), "1": (4, 12, 4, 4, 4, 4, 14),
    "2": (14, 17, 1, 2, 4, 8, 31), "3": (30, 1, 1, 14, 1, 1, 30),
    "4": (2, 6, 10, 18, 31, 2, 2), "5": (31, 16, 16, 30, 1, 1, 30),
    "6": (14, 16, 16, 30, 17, 17, 14), "7": (31, 1, 2, 4, 8, 8, 8),
    "8": (14, 17, 17, 14, 17, 17, 14), "9": (14, 17, 17, 15, 1, 1, 14),
    ".": (0, 0, 0, 0, 0, 12, 12), ":": (0, 12, 12, 0, 12, 12, 0),
    "-": (0, 0, 0, 31, 0, 0, 0), "_": (0, 0, 0, 0, 0, 0, 31),
    "/": (1, 1, 2, 4, 8, 16, 16), "\\": (16, 16, 8, 4, 2, 1, 1),
    "(": (2, 4, 8, 8, 8, 4, 2), ")": (8, 4, 2, 2, 2, 4, 8),
    "x": (0, 0, 17, 10, 4, 10, 17), "X": (17, 17, 10, 4, 10, 17, 17),
    "!": (4, 4, 4, 4, 4, 0, 4), "*": (0, 10, 4, 31, 4, 10, 0),
}


def resolve_sources(ns: argparse.Namespace) -> list[Path]:
    found: dict[Path, None] = {}
    for raw in ns.frame or []:
        p = Path(raw)
        p = p if p.is_absolute() else (ROOT / p).resolve()
        if not p.is_file():
            raise ValueError(f"--frame not a file: {p}")
        found[p.resolve()] = None
    for raw in ns.dir or []:
        d = Path(raw)
        d = d if d.is_absolute() else (ROOT / d).resolve()
        if not d.is_dir():
            raise ValueError(f"--dir not a directory: {d}")
        for p in sorted(d.glob(ns.pattern)):
            if p.is_file():
                found[p.resolve()] = None
    for raw in ns.manifest or []:
        mp = Path(raw)
        mp = mp if mp.is_absolute() else (ROOT / mp).resolve()
        data = json.loads(mp.read_text(encoding="utf-8"))
        for view in data.get("views", []):
            if ns.view and view.get("name") != ns.view:
                continue
            for fr in view.get("frames", []):
                p = Path(fr["file"])
                p = p if p.is_absolute() else (ROOT / p).resolve()
                if not p.is_file():
                    raise ValueError(f"manifest frame missing: {p}")
                found[p.resolve()] = None
    if not found:
        raise ValueError("no input frames: pass --frame, --dir or --manifest")
    return sorted(found)


def parse_fit(text: str) -> tuple[int, int]:
    m = re.fullmatch(r"(\d+)\s*[xX]\s*(\d+)", text.strip())
    if not m or int(m.group(1)) < 1 or int(m.group(2)) < 1:
        raise argparse.ArgumentTypeError("--fit must be WxH with positive integers")
    return int(m.group(1)), int(m.group(2))


def rescale(raster: Raster, size: tuple[int, int], method: str) -> Raster:
    if not HAS_PIL:
        raise RuntimeError("--fit needs Pillow (stdlib fallback cannot resample)")
    from PIL import Image as PILImage
    modes = {"nearest": PILImage.Resampling.NEAREST,
             "bilinear": PILImage.Resampling.BILINEAR,
             "bicubic": PILImage.Resampling.BICUBIC,
             "lanczos": PILImage.Resampling.LANCZOS}
    src = PILImage.frombytes("RGB", (raster.w, raster.h), raster.data)
    out = src.resize(size, modes[method])
    return Raster(out.width, out.height, out.tobytes())


def truncate(text: str, max_chars: int) -> str:
    return text if len(text) <= max_chars else text[:max(0, max_chars - 3)] + "..."


def build_pillow(paths: list[Path], ns: argparse.Namespace) -> tuple[Raster, list[dict]]:
    from PIL import Image, ImageDraw, ImageFont
    font = ImageFont.load_default()
    sources = [(p, load_rgb(p)) for p in paths]
    cells = [(ns.fit[0] if ns.fit else r.w, ns.fit[1] if ns.fit else r.h)
             for _, r in sources]
    cw, ch = max(c for c, _ in cells), max(c for _, c in cells)
    cols = min(ns.cols, len(paths))
    rows = (len(paths) + cols - 1) // cols
    margin = ns.gap
    header = ns.label_height + ns.gap if ns.title else 0
    W = 2 * margin + cols * cw + (cols - 1) * ns.gap
    H = 2 * margin + header + rows * (ns.label_height + ch) + (rows - 1) * ns.gap
    sheet = Image.new("RGB", (W, H), ns.background)
    draw = ImageDraw.Draw(sheet)
    if ns.title:
        draw.text((margin, margin), truncate(ns.title, max(8, W // 7)),
                  fill=ns.foreground, font=font)

    records: list[dict] = []
    max_chars = max(4, cw // 7)
    for i, ((p, src), (dw, dh)) in enumerate(zip(sources, cells)):
        row, col = divmod(i, cols)
        x = margin + col * (cw + ns.gap)
        y = margin + header + row * (ns.label_height + ch + ns.gap)
        tile = rescale(src, (dw, dh), ns.resample) if ns.fit else src
        label = p.name + f" {src.w}x{src.h}"
        if ns.fit:
            label = f"RESCALED {dw}x{dh} <- {src.w}x{src.h} ({ns.resample}) " + p.name
        elif dw != src.w or dh != src.h:
            label += " (cell padded, pixels unchanged)"
        if ns.hash_labels:
            label += " " + hash_file(p)[:12]
        draw.rectangle((x, y, x + cw - 1, y + ns.label_height - 1), fill=(28, 28, 34))
        draw.text((x + 3, y + (ns.label_height - 14) // 2),
                  truncate(label, max_chars), fill=ns.foreground, font=font)
        sheet.paste(Image.frombytes("RGB", (tile.w, tile.h), tile.data), (x, y + ns.label_height))
        records.append({
            "source": str(p), "source_sha256": hash_file(p),
            "source_size": [src.w, src.h], "placed_size": [tile.w, tile.h],
            "box": [x, y + ns.label_height, dw, dh], "label": label,
            "rescaled": bool(ns.fit),
            "exact_pixels_preserved": not bool(ns.fit),
        })
    return Raster(W, H, sheet.tobytes()), records


def build_fallback(paths: list[Path], ns: argparse.Namespace) -> tuple[Raster, list[dict]]:
    if ns.fit:
        raise RuntimeError("--fit needs Pillow (stdlib fallback cannot resample)")
    sources = [(p, load_rgb(p)) for p in paths]
    cw = max(r.w for _, r in sources)
    ch = max(r.h for _, r in sources)
    cols = min(ns.cols, len(paths))
    rows = (len(paths) + cols - 1) // cols
    margin = ns.gap
    header = ns.label_height + ns.gap if ns.title else 0
    W = 2 * margin + cols * cw + (cols - 1) * ns.gap
    H = 2 * margin + header + rows * (ns.label_height + ch) + (rows - 1) * ns.gap
    buf = bytearray(bytes(ns.background) * (W * H))

    def draw_text(text: str, x: int, y: int) -> None:
        for ci, char in enumerate(text.upper()):
            rows_bits = _FONT.get(char, _FONT["!"])
            for ry, bits in enumerate(rows_bits):
                for cx in range(5):
                    if bits & (1 << (4 - cx)):
                        px, py = x + ci * 6 + cx, y + ry
                        if 0 <= px < W and 0 <= py < H:
                            off = (py * W + px) * 3
                            buf[off:off + 3] = bytes(ns.foreground)

    if ns.title:
        draw_text(truncate(ns.title, W // 6), margin, margin)
    records: list[dict] = []
    max_chars = max(4, cw // 6)
    for i, (p, src) in enumerate(sources):
        row, col = divmod(i, cols)
        x = margin + col * (cw + ns.gap)
        y = margin + header + row * (ns.label_height + ch + ns.gap)
        label = p.name + f" {src.w}x{src.h}"
        if src.w != cw or src.h != ch:
            label += " (cell padded, pixels unchanged)"
        if ns.hash_labels:
            label += " " + hash_file(p)[:12]
        draw_text(truncate(label, max_chars), x + 2, y + 1)
        oy = y + ns.label_height
        for ry in range(src.h):
            off = ((oy + ry) * W + x) * 3
            buf[off:off + src.w * 3] = src.data[ry * src.w * 3:(ry + 1) * src.w * 3]
        records.append({
            "source": str(p), "source_sha256": hash_file(p),
            "source_size": [src.w, src.h], "placed_size": [src.w, src.h],
            "box": [x, oy, src.w, src.h], "label": label,
            "rescaled": False, "exact_pixels_preserved": True,
        })
    return Raster(W, H, bytes(buf)), records


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--frame", action="append", metavar="PNG", help="frame file (repeatable)")
    ap.add_argument("--dir", action="append", metavar="DIR", help="directory of frames")
    ap.add_argument("--pattern", default="frame_*.png", help="glob inside --dir (default frame_*.png)")
    ap.add_argument("--manifest", action="append", metavar="JSON",
                    help="capture_sequence.py manifest to read frames from")
    ap.add_argument("--view", metavar="NAME", help="only this view from --manifest")
    ap.add_argument("--out", required=True, metavar="PNG", help="output contact sheet PNG")
    ap.add_argument("--cols", type=int, default=4, help="tiles per row (default 4)")
    ap.add_argument("--gap", type=int, default=4, help="gap/margin in pixels (default 4)")
    ap.add_argument("--label-height", type=int, default=24,
                    help="label band height in pixels (default 24)")
    ap.add_argument("--title", default="", help="optional sheet title")
    ap.add_argument("--hash-labels", action="store_true",
                    help="append 12-char source SHA-256 to each label")
    ap.add_argument("--fit", type=parse_fit, metavar="WxH",
                    help="EXPLICIT rescale to WxH; labels say RESCALED")
    ap.add_argument("--resample", choices=sorted(RESAMPLE), default="lanczos",
                    help="Pillow resample filter for --fit (default lanczos)")
    ap.add_argument("--background", default="10,10,14", metavar="R,G,B")
    ap.add_argument("--foreground", default="235,235,240", metavar="R,G,B")
    ap.add_argument("--json", dest="json_out", metavar="JSON",
                    help="sidecar JSON (default: <out>.json)")
    ns = ap.parse_args(argv)

    def rgb(name: str) -> tuple[int, int, int]:
        parts = getattr(ns, name).split(",")
        if len(parts) != 3:
            ap.error(f"--{name.replace('_', '-')} must be R,G,B")
        try:
            vals = tuple(int(x.strip()) for x in parts)
        except ValueError:
            ap.error(f"--{name.replace('_', '-')} must be R,G,B integers")
        if not all(0 <= v <= 255 for v in vals):
            ap.error(f"--{name.replace('_', '-')} channels must be 0..255")
        return vals  # type: ignore[return-value]

    ns.background, ns.foreground = rgb("background"), rgb("foreground")
    if ns.cols < 1 or ns.gap < 0 or ns.label_height < 8:
        ap.error("--cols>=1, --gap>=0, --label-height>=8 required")
    try:
        paths = resolve_sources(ns)
        sheet, records = (build_pillow(paths, ns) if HAS_PIL
                          else build_fallback(paths, ns))
    except (OSError, ValueError, RuntimeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return EXIT_BAD

    out = Path(ns.out)
    out = out if out.is_absolute() else (ROOT / out).resolve()
    save_png(out, sheet)
    side = Path(ns.json_out) if ns.json_out else out.with_suffix(out.suffix + ".json")
    side = side if side.is_absolute() else (ROOT / side).resolve()
    side.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "tool": "contact_sheet.py",
        "image": str(out),
        "sheet_size": [sheet.w, sheet.h],
        "tiles": records,
        "rescale_requested": bool(ns.fit),
        "rescale_target": list(ns.fit) if ns.fit else None,
        "resample_filter": ns.resample if ns.fit else None,
        "backend": "Pillow" if HAS_PIL else "stdlib PNG fallback (5x7 font, no rescale)",
        "note": "Presentation only. A contact sheet and metrics alone never "
                "constitute donor parity; parity=UNVERIFIED.",
    }
    side.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    print(f"[contact] {out} {sheet.w}x{sheet.h}; {len(records)} tile(s); sidecar {side}")
    return EXIT_OK


if __name__ == "__main__":
    raise SystemExit(main())
