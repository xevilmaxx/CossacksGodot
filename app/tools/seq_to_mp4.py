#!/usr/bin/env python3
"""Assemble a captured frame sequence into an MP4 video (or a contact sheet).

Usage:
    python tools/seq_to_mp4.py --dir app/shots/j1 [--fps 10] [--out journey.mp4]
    python tools/seq_to_mp4.py --dir app/shots/j1 --contact-only

Needs ffmpeg on PATH for MP4 (https://ffmpeg.org, `winget install ffmpeg`).
Without ffmpeg only the contact sheet (Pillow) is produced.
"""
from __future__ import annotations
import argparse, json, os, shutil, subprocess, sys

try:
    from PIL import Image
except Exception:
    Image = None


def contact(frames: list, out: str, cols: int = 6) -> None:
    imgs = [Image.open(f).convert("RGB") for f in frames]
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

    frames = sorted(f for f in
                    (os.path.join(args.dir, x) for x in os.listdir(args.dir))
                    if os.path.basename(f).startswith("frame_") and f.endswith(".png"))
    if not frames:
        print("no frame_*.png in", args.dir)
        return 1
    idx = os.path.join(args.dir, "seq_index.json")
    if os.path.exists(idx):
        print("sequence:", json.load(open(idx)))
    print("frames:", len(frames))

    if Image is not None:
        contact(frames, os.path.join(args.dir, "contact.png"))

    if args.contact_only:
        return 0
    ff = shutil.which("ffmpeg")
    if ff is None:
        print("ffmpeg not on PATH - install it (winget install ffmpeg), then re-run; contact sheet kept")
        return 0
    out = args.out or os.path.join(args.dir, "journey.mp4")
    cmd = [ff, "-y", "-framerate", str(args.fps), "-i",
           os.path.join(args.dir, "frame_%04d.png"),
           "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20", out]
    print("+", " ".join(cmd))
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stderr[-2000:])
        return 1
    print("video:", out, os.path.getsize(out), "bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
