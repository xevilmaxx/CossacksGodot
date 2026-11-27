#!/usr/bin/env python3
"""Tiny image I/O layer shared by the acceptance tools.

Pillow is used when importable (verified available in this workspace).  A
minimal pure-standard-library PNG fallback is included so the scripts stay
runnable on a bare Python 3 install.  FALLBACK LIMITATIONS (also in README):

  * PNG only (no JPEG/BMP input), 8-bit, non-interlaced;
  * colour types 0 (grey), 2 (RGB), 3 (palette), 4 (grey+alpha), 6 (RGBA);
  * alpha is composited onto white, tRNS is ignored;
  * resampling / label drawing require Pillow; the fallback refuses them.

No image is ever synthesised: every raster returned here comes from a file.
"""
from __future__ import annotations

import hashlib
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path

try:  # Pillow is present in this workspace; the fallback is a portability net.
    from PIL import Image as _PILImage
    HAS_PIL = True
except ImportError:  # pragma: no cover - exercised only on bare Python
    _PILImage = None
    HAS_PIL = False


@dataclass(frozen=True)
class Raster:
    """Uncompressed 8-bit RGB pixels, row-major, exactly w*h*3 bytes."""

    w: int
    h: int
    data: bytes

    def crop(self, box: tuple[int, int, int, int]) -> "Raster":
        x0, y0, x1, y1 = box
        if not (0 <= x0 < x1 <= self.w and 0 <= y0 < y1 <= self.h):
            raise ValueError(f"crop {box} outside image {self.w}x{self.h}")
        stride = self.w * 3
        rows = bytearray()
        for y in range(y0, y1):
            off = y * stride + x0 * 3
            rows += self.data[off:off + (x1 - x0) * 3]
        return Raster(x1 - x0, y1 - y0, bytes(rows))

    def pixel_hash(self) -> str:
        return hashlib.sha256(self.data).hexdigest()


# --------------------------------------------------------------------------
# minimal PNG reader / writer (fallback only)
# --------------------------------------------------------------------------
_PNG_SIG = b"\x89PNG\r\n\x1a\n"
_CHANNELS = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}


def _iter_png_chunks(raw: bytes):
    if not raw.startswith(_PNG_SIG):
        raise ValueError("not a PNG file")
    pos = 8
    while pos + 12 <= len(raw):
        (length,) = struct.unpack_from(">I", raw, pos)
        kind = raw[pos + 4:pos + 8]
        end = pos + 8 + length
        if end + 4 > len(raw):
            raise ValueError("truncated PNG chunk")
        yield kind, raw[pos + 8:end]
        pos = end + 4


def _paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    return a if pa <= pb and pa <= pc else (b if pb <= pc else c)


def _unfilter(buf: bytes, stride: int, bpp: int, height: int) -> bytearray:
    out = bytearray(stride * height)
    prev = bytearray(stride)
    pos = 0
    for y in range(height):
        ft = buf[pos]
        line = bytearray(buf[pos + 1:pos + 1 + stride])
        pos += 1 + stride
        if len(line) != stride:
            raise ValueError("truncated PNG scanline")
        if ft == 1:
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 0xFF
        elif ft == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ft == 3:
            for i in range(stride):
                left = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif ft == 4:
            for i in range(stride):
                left = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + _paeth(left, prev[i], prev[i - bpp] if i >= bpp else 0)) & 0xFF
        elif ft != 0:
            raise ValueError(f"unsupported PNG filter {ft}")
        out[y * stride:(y + 1) * stride] = line
        prev = line
    return out


def _load_png_fallback(path: Path) -> Raster:
    raw = path.read_bytes()
    ihdr = None
    palette = b""
    idat = bytearray()
    for kind, payload in _iter_png_chunks(raw):
        if kind == b"IHDR":
            ihdr = struct.unpack(">IIBBBBB", payload[:13])
        elif kind == b"PLTE":
            palette = payload
        elif kind == b"IDAT":
            idat += payload
        elif kind == b"IEND":
            break
    if ihdr is None:
        raise ValueError("PNG has no IHDR")
    w, h, depth, ctype, comp, filt, interlace = ihdr
    if depth != 8 or interlace != 0 or comp != 0 or filt != 0:
        raise ValueError("fallback needs 8-bit non-interlaced PNG")
    if ctype not in _CHANNELS:
        raise ValueError(f"fallback cannot read PNG colour type {ctype}")
    bpp = _CHANNELS[ctype]
    unpacked = _unfilter(zlib.decompress(bytes(idat)), w * bpp, bpp, h)
    rgb = bytearray(w * h * 3)
    for i in range(w * h):
        s = i * bpp
        d = i * 3
        if ctype == 0:
            rgb[d] = rgb[d + 1] = rgb[d + 2] = unpacked[s]
        elif ctype == 4:
            v = unpacked[s]
            rgb[d] = rgb[d + 1] = rgb[d + 2] = v
        elif ctype == 2:
            rgb[d:d + 3] = unpacked[s:s + 3]
        elif ctype == 6:
            rgb[d:d + 3] = unpacked[s:s + 3]
        elif ctype == 3:
            idx = unpacked[s] * 3
            if idx + 3 > len(palette):
                raise ValueError("palette index out of range")
            rgb[d:d + 3] = palette[idx:idx + 3]
    return Raster(w, h, bytes(rgb))


def _chunk(kind: bytes, payload: bytes) -> bytes:
    return (struct.pack(">I", len(payload)) + kind + payload
            + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF))


def _save_png_fallback(path: Path, raster: Raster) -> None:
    ihdr = struct.pack(">IIBBBBB", raster.w, raster.h, 8, 2, 0, 0, 0)
    stride = raster.w * 3
    raw = b"".join(b"\x00" + raster.data[y * stride:(y + 1) * stride]
                   for y in range(raster.h))
    path.write_bytes(_PNG_SIG
                     + _chunk(b"IHDR", ihdr)
                     + _chunk(b"IDAT", zlib.compress(raw, 6))
                     + _chunk(b"IEND", b""))


# --------------------------------------------------------------------------
# public API
# --------------------------------------------------------------------------
def load_rgb(path: str | Path) -> Raster:
    """Load a file as RGB pixels. No resampling, no synthesis."""
    p = Path(path)
    if not p.is_file():
        raise FileNotFoundError(str(p))
    if HAS_PIL:
        with _PILImage.open(p) as im:
            im = im.convert("RGB")
            return Raster(im.width, im.height, im.tobytes())
    return _load_png_fallback(p)


def save_png(path: str | Path, raster: Raster) -> None:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    if HAS_PIL:
        _PILImage.frombytes("RGB", (raster.w, raster.h), raster.data).save(p, format="PNG")
    else:
        _save_png_fallback(p, raster)


def hash_file(path: str | Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for block in iter(lambda: fh.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()
