#!/usr/bin/env python3
"""Bake soft shadow + selection ring textures into assets/ui/overlays/.
Run: python app/tools/make_overlays.py --out app/assets/ui/overlays
"""
import argparse, math, os
from PIL import Image, ImageDraw

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--out", required=True)
    a = ap.parse_args(); os.makedirs(a.out, exist_ok=True)
    S = 64
    sh = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(sh)
    for i in range(16, 0, -1):
        al = int(70 * (1.0 - i / 16.0) ** 1.6)
        d.ellipse([S/2 - i*1.9, S/2 - i*0.95, S/2 + i*1.9, S/2 - i*0.95], fill=(0, 0, 0, al))
    sh.save(os.path.join(a.out, "shadow.png"))
    for name, col in (("ring_p0", (70, 130, 255)), ("ring_p1", (255, 80, 60)), ("ring_sel", (255, 255, 255))):
        im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        d.ellipse([4, 10, S-4, S-10], outline=col + (230,), width=3)
        d.ellipse([7, 13, S-7, S-13], outline=col + (90,), width=2)
        im.save(os.path.join(a.out, name + ".png"))
    print("overlays written")

main()
