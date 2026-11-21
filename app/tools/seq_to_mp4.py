#!/usr/bin/env python3
"""Assemble a captured frame sequence into an MP4 video (or a contact sheet).

Usage:
    python tools/seq_to_mp4.py --dir app/shots/j1 [--fps 10] [--out journey.mp4]
    python tools/seq_to_mp4.py --dir app/shots/j1 --contact-only

Needs ffmpeg on PATH for MP4 (https://ffmpeg.org, `winget install ffmpeg`).
Without ffmpeg only the contact sheet (Pillow) is produced.
"""
from __future__ import annotations
import argparse, json, shutil, subprocess, sys
from pathlib import Path

try:
    from PIL import Image
except Exception:
    Image = None


def contact(frames: list, out: str, cols: int = 6) -> None:
    imgs = []
    for f in frames:
        with Image.open(f) as im:
            imgs.append(im.convert("RGB"))
    w, h = imgs[0].size
    tw, th = 320, int(320 * h / max(1, w))
    thumbs = [im.resize((tw, th)) for im in imgs]
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * tw, rows * th), (10, 10, 10))
    for i, t in enumerate(thumbs):
        sheet.paste(t, ((i % cols) * tw, (i // cols) * th))
    sheet.save(out, "PNG")
    print("contact sheet:", out)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dir", required=True)
    ap.add_argument("--fps", type=int, default=10)
    ap.add_argument("--out", default="")
    ap.add_argument("--contact-only", action="store_true")
    args = ap.parse_args()

    d = Path(args.dir)
    if not d.is_dir():
        print("not a directory:", args.dir)
        return 1
    frames = sorted(f for f in d.glob("frame_*.png") if f.is_file())
    if not frames:
        print("no frame_*.png in", args.dir)
        return 1
    idx = d / "seq_index.json"
    if idx.is_file():
        with idx.open(encoding="utf-8") as fh:
            print("sequence:", json.load(fh))
    print("frames:", len(frames))

    if Image is not None:
        contact(frames, str(d / "contact.png"))

    if args.contact_only:
        return 0
    # ffmpeg is discovered via PATH, not a hardcoded executable path.
    ff = shutil.which("ffmpeg")
    if ff is None:
        print("ffmpeg not on PATH - install it (winget install ffmpeg), then re-run; contact sheet kept")
        return 0
    out = args.out or str(d / "journey.mp4")
    cmd = [ff, "-y", "-framerate", str(args.fps), "-i",
           str(d / "frame_%04d.png"),
           "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20", out]
    print("+", " ".join(cmd))
    r = subprocess.run(cmd, capture_output=True, text=True, shell=False)
    if r.returncode != 0:
        print(r.stderr[-2000:])
        return 1
    print("video:", out, Path(out).stat().st_size, "bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
