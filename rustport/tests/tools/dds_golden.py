"""Generate a Pillow RGBA golden + header metadata for one donor DDS.

PRIVATE USE ONLY: reads a donor file for the duration of this script, writes
only raw decoded pixels + a small text sidecar into the caller-supplied output
directory (the test uses rustport/target/dds_golden, which is gitignored).
No donor bytes are written into the repository and no golden is committed.

Usage: python dds_golden.py <donor.dds> <outdir>
"""

from __future__ import annotations

import os
import struct
import sys

from PIL import Image


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: dds_golden.py <donor.dds> <outdir>", file=sys.stderr)
        return 2
    src, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)

    with open(src, "rb") as fh:
        header = fh.read(128)
    if len(header) < 128 or header[:4] != b"DDS ":
        raise ValueError(f"not a 128-byte-header DDS: {src}")

    # DDSURFACEDESC2, little-endian, offsets into the 128-byte header.
    dw_size, flags, height, width, pitch, depth = struct.unpack_from("<6I", header, 4)
    fourcc = header[84:88]

    with Image.open(src) as im:
        pillow_size = im.size
        pillow_mode = im.mode
        pillow_format = im.format
        im.load()
        rgba = im.convert("RGBA").tobytes()

    name = os.path.splitext(os.path.basename(src))[0]
    meta_path = os.path.join(outdir, name + ".meta.txt")
    with open(meta_path, "w", encoding="ascii") as fh:
        fh.write(f"path {src}\n")
        fh.write(f"magic {header[:4].decode('latin1')}\n")
        fh.write(f"header_size {dw_size}\n")
        fh.write(f"flags {flags}\n")
        fh.write(f"width {width}\n")
        fh.write(f"height {height}\n")
        fh.write(f"pitch {pitch}\n")
        fh.write(f"depth {depth}\n")
        fh.write(f"fourcc {fourcc.decode('latin1')}\n")
        fh.write(f"pillow_width {pillow_size[0]}\n")
        fh.write(f"pillow_height {pillow_size[1]}\n")
        fh.write(f"pillow_mode {pillow_mode}\n")
        fh.write(f"pillow_format {pillow_format}\n")
        fh.write(f"rgba_len {len(rgba)}\n")

    rgba_path = os.path.join(outdir, name + ".rgba")
    with open(rgba_path, "wb") as fh:
        fh.write(rgba)

    print(
        f"golden {name}: {width}x{height} fourcc={fourcc!r} "
        f"pillow={pillow_size} {pillow_mode}/{pillow_format} rgba_len={len(rgba)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
