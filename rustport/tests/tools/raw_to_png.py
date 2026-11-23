"""Convert a deterministic RGBA .raw shot to PNG (T6-R06 helper).

Usage: python raw_to_png.py <input.raw> <output.png> <width> <height>
The raw file must be exactly width*height*4 bytes in R,G,B,A order.
No donor data is involved: the input is a generated render.
"""

import sys

from PIL import Image


def main() -> None:
    if len(sys.argv) != 5:
        raise SystemExit("usage: raw_to_png.py <in.raw> <out.png> <width> <height>")
    raw_path, png_path, w, h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    with open(raw_path, "rb") as f:
        data = f.read()
    expected = w * h * 4
    if len(data) != expected:
        raise SystemExit(f"raw length {len(data)} != expected {expected}")
    Image.frombytes("RGBA", (w, h), data).save(png_path)
    print(f"PNG {png_path} ({w}x{h}) from raw {len(data)} bytes")


if __name__ == "__main__":
    main()
