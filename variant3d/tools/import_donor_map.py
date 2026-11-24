#!/usr/bin/env python3
"""Read-only donor `.map` relief importer -> heightmap_splat.py dump JSON.

Private-use tool for a locally installed Cossacks 3. It ONLY reads the donor
file (open(..., 'rb').read()); it never executes donor code, never copies a
donor binary into this repository, and never writes inside the repository.
Default output is stdout; an explicit --out must resolve outside this repo.

Parsed, decoded and emitted
---------------------------
After ``TerrainMapBegin`` the donor stream contains a second
``int32 320, int32 320`` header. Eight bytes later is a plain, uncompressed
little-endian ``float32[320*320]`` elevation grid (409,600 B), bounding
exactly +/-2.964 m. This is byte-identical in shape and encoding to the
``height`` field consumed by ``heightmap_splat.py::load_dump`` (lines 137-176).

Parsed but SEMANTICS UNVERIFIED (reported, never emitted, no meaning invented)
-----------------------------------------------------------------------------
* 37-byte tile-index records: 102,400 fixed-stride records starting
  ``height_grid_end + 2556``; bytes 8..11 are four small integers, bytes
  16..31 are four 1.0f weights. Whether bytes 8..11 are donor tile indices
  is an INFERENCE (DECOMP-06 3.4); this tool only counts them in --survey.
* Named coordinate records: variable-length ``int32 L | "xNNNyNNN" | 5*f32``
  (total 24+L bytes; 31 bytes when the name is 7 characters), ending at the
  int32 prefix of ``TerrainMapEnd``. The first three floats read 2.0/2.0/-0.5,
  the last two look like world coordinates. Their semantics, the world scale
  and the height-grid row orientation are UNVERIFIED (DECOMP-06 3.5, 6).

Reference: docs/coord_swarm_2026-11-24/reports/DECOMP_06_map_format.md
           docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md

Usage (from project root)::

    python variant3d/tools/import_donor_map.py --help
    python variant3d/tools/import_donor_map.py MAP --out /tmp/donor_height.json
    python variant3d/tools/import_donor_map.py MAP                    # stdout
    python variant3d/tools/import_donor_map.py MAP --verify           # read-only compare
    python variant3d/tools/import_donor_map.py MAP --survey           # structure counts only
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

TOOL_VERSION = "1.0.0"
ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DUMP = ROOT / "app" / "shots" / "g32_dump.json"

GRID_SIDE = 320
CELLS = GRID_SIDE * GRID_SIDE          # 102,400
HEIGHT_BYTES = CELLS * 4               # 409,600
HEADER = struct.pack("<ii", GRID_SIDE, GRID_SIDE)
TILE_RECORD_BYTES = 37
TILE_GAP = 2556                        # height-grid end -> first 37-byte record
END_PREFIX_BYTES = 4
NAMED_NAME_RE = re.compile(rb"x\d+y\d+")

SCHEMA_TEXT = """\
Emitted dump JSON (consumed by heightmap_splat.py::load_dump):
  map_w, map_h : int   320, 320
  seed         : int   0 (no donor seed is known; not donor-derived)
  height       : str   base64 of little-endian float32[102400], metres
  tileblock    : str   base64 of uint8[102400]; ZERO PLACEHOLDER by default
                       (donor tile semantics UNVERIFIED; use --tileblock omit
                       for a height-only document)
  meta         : obj   importer version, source path/hash, byte offsets,
                       measured bounds, and the tileblock caveat
Base64 uses validate=True-compatible ASCII (Godot Marshall format).
All numeric arrays are row-major: index = y * map_w + x.
"""


class ImportError_(ValueError):
    """A donor map/JSON validation failure with a user-facing message."""


# --------------------------------------------------------------------------- donor

def _locate(data: bytes) -> dict:
    """Find and validate the TerrainMapBegin/second-header/height-grid anchors."""
    marker = data.find(b"TerrainMapBegin")
    if marker < 0:
        raise ImportError_("TerrainMapBegin not found: not a Cossacks 3 .map stream")
    if data.find(b"TerrainMapBegin", marker + 1) >= 0:
        raise ImportError_("more than one TerrainMapBegin; refusing ambiguous parse")
    if marker < END_PREFIX_BYTES or struct.unpack_from("<i", data, marker - 4)[0] != 15:
        raise ImportError_("TerrainMapBegin length prefix != 15; unexpected stream layout")

    end_marker = data.find(b"TerrainMapEnd", marker)
    if end_marker < 0:
        raise ImportError_("TerrainMapEnd not found after TerrainMapBegin")
    if data.find(b"TerrainMapEnd", end_marker + 1) >= 0:
        raise ImportError_("more than one TerrainMapEnd; refusing ambiguous parse")
    # "TerrainMapEnd" is 13 ASCII bytes; the 16 read at +len("TerrainMapEnd")
    # by DECOMP-06 3.2 is the prefix of the NEXT string, not this one.
    if struct.unpack_from("<i", data, end_marker - 4)[0] != 13:
        raise ImportError_("TerrainMapEnd length prefix != 13; unexpected stream layout")

    headers: list[int] = []
    i = marker
    while True:
        i = data.find(HEADER, i)
        if i < 0:
            break
        headers.append(i)
        i += 1
    if len(headers) < 2:
        raise ImportError_(f"expected >=2 320x320 headers after TerrainMapBegin, found {len(headers)}")
    grid_header = headers[1]              # DECOMP-06 3.2: take the SECOND header
    if not marker < grid_header < end_marker:
        raise ImportError_("second 320x320 header lies outside the terrain section")
    width, height = struct.unpack_from("<ii", data, grid_header)
    if (width, height) != (GRID_SIDE, GRID_SIDE):
        raise ImportError_(f"second header is {width}x{height}, expected 320x320")

    grid_off = grid_header + len(HEADER)
    if grid_off + HEIGHT_BYTES > end_marker:
        raise ImportError_("height grid runs past TerrainMapEnd; refusing to decode")
    return {
        "marker": marker,
        "end_marker": end_marker,
        "headers": headers,
        "grid_header": grid_header,
        "grid_off": grid_off,
    }


def read_donor(path: Path) -> tuple[tuple[float, ...], dict]:
    """Decode the donor height grid. Returns (heights, anchors). Read-only."""
    if not path.is_file():
        raise FileNotFoundError(f"donor map not found: {path}")
    data = path.read_bytes()              # the ONLY donor file access
    anchors = _locate(data)
    heights = struct.unpack_from(f"<{CELLS}f", data, anchors["grid_off"])
    anchors["source"] = str(path)
    anchors["sha256"] = hashlib.sha256(data).hexdigest()
    anchors["size_bytes"] = len(data)
    anchors["data"] = data                # kept in memory only; never written
    return heights, anchors


def stats(heights: tuple[float, ...]) -> dict:
    return {
        "cells": len(heights),
        "min": min(heights),
        "max": max(heights),
        "mean": round(sum(heights) / len(heights), 6),
    }


# ------------------------------------------------------------------------- survey

def survey(data: bytes, anchors: dict) -> dict:
    """Count opaque structures only. No field semantics are assigned."""
    grid_end = anchors["grid_off"] + HEIGHT_BYTES
    tile_off = grid_end + TILE_GAP
    tile_ok = 0
    for k in range(CELLS):
        off = tile_off + k * TILE_RECORD_BYTES
        if off + 32 <= anchors["end_marker"] and struct.unpack_from("<4f", data, off + 16) == (1.0,) * 4:
            tile_ok += 1
    tile_end = tile_off + CELLS * TILE_RECORD_BYTES

    # Walk the variable-length named records forward from the end of the tile
    # grid; the first valid record starts in the undecoded gap.
    named_off = -1
    for off in range(tile_end, anchors["end_marker"] - 4):
        length = struct.unpack_from("<i", data, off)[0]
        if not 1 <= length <= 32:
            continue
        name = data[off + 4:off + 4 + length]
        if not NAMED_NAME_RE.fullmatch(name):
            continue
        if struct.unpack_from("<3f", data, off + 4 + length) == (2.0, 2.0, -0.5):
            named_off = off
            break

    named_count = 0
    sizes: dict[int, int] = {}
    if named_off >= 0:
        off = named_off
        stop = anchors["end_marker"] - END_PREFIX_BYTES
        while off + 24 <= stop:
            length = struct.unpack_from("<i", data, off)[0]
            if not 1 <= length <= 32 or not NAMED_NAME_RE.fullmatch(data[off + 4:off + 4 + length]):
                break
            if struct.unpack_from("<3f", data, off + 4 + length) != (2.0, 2.0, -0.5):
                break
            total = 24 + length
            sizes[total] = sizes.get(total, 0) + 1
            off += total
            named_count += 1
    return {
        "tile": {"first": hex(tile_off), "end": hex(tile_end), "records": CELLS,
                 "stride_bytes": TILE_RECORD_BYTES, "trailing_1f_quad_ok": tile_ok},
        "named": {"first": hex(named_off) if named_off >= 0 else None,
                  "end": hex(anchors["end_marker"] - END_PREFIX_BYTES),
                  "records": named_count, "record_sizes": dict(sorted(sizes.items()))},
    }


# -------------------------------------------------------------------------- verify

def _dump_floats(doc: dict, path: Path) -> tuple[float, ...]:
    value = doc.get("height")
    if isinstance(value, str):
        try:
            raw = base64.b64decode(value, validate=True)
        except (ValueError, binascii.Error) as exc:
            raise ImportError_(f"{path}: invalid height base64: {exc}") from exc
    elif isinstance(value, list):
        raw = struct.pack(f"<{len(value)}f", *(float(v) for v in value))
    else:
        raise ImportError_(f"{path}: height must be base64 str or number[]")
    if len(raw) % 4:
        raise ImportError_(f"{path}: height byte count {len(raw)} is not a multiple of 4")
    w, h = int(doc.get("map_w", 0) or 0), int(doc.get("map_h", 0) or 0)
    n = len(raw) // 4
    if (w, h) != (GRID_SIDE, GRID_SIDE) or n != CELLS:
        raise ImportError_(f"{path}: expected 320x320/102400 height cells, got {w}x{h}/{n}")
    return struct.unpack_from(f"<{CELLS}f", raw, 0)


def compare(donor_h: tuple[float, ...], anchors: dict, dump_path: Path) -> dict:
    if not dump_path.is_file():
        raise FileNotFoundError(f"local dump not found: {dump_path}")
    doc = json.loads(dump_path.read_text(encoding="utf-8"))
    if not isinstance(doc, dict):
        raise ImportError_(f"{dump_path}: root must be a JSON object")
    local = _dump_floats(doc, dump_path)
    exact = sum(a == b for a, b in zip(donor_h, local))
    max_err = max(abs(a - b) for a, b in zip(donor_h, local))
    ls = stats(local)
    return {
        "dump": str(dump_path),
        "dump_sha256": hashlib.sha256(dump_path.read_bytes()).hexdigest(),
        "donor": stats(donor_h),
        "local": ls,
        "exact_matches": exact,
        "total_cells": CELLS,
        "exact_pct": round(100.0 * exact / CELLS, 4),
        "max_abs_error_m": max_err,
        "bounds_error_m": {"min": round(ls["min"] - stats(donor_h)["min"], 9),
                           "max": round(ls["max"] - stats(donor_h)["max"], 9)},
    }


def print_verify(anchors: dict, res: dict) -> None:
    d, l = res["donor"], res["local"]
    print("DONOR MAP (read-only comparison; nothing written)")
    print(f"  source           : {anchors['source']}")
    print(f"  sha256           : {anchors['sha256']}")
    print(f"  grid offset      : {hex(anchors['grid_off'])}  (header {hex(anchors['grid_header'])})")
    print(f"  donor bounds m   : min {d['min']:.6f}  max {d['max']:.6f}  mean {d['mean']:.6f}  cells {d['cells']}")
    print("LOCAL DUMP")
    print(f"  path             : {res['dump']}")
    print(f"  sha256           : {res['dump_sha256']}")
    print(f"  local bounds m   : min {l['min']:.6f}  max {l['max']:.6f}  mean {l['mean']:.6f}  cells {l['cells']}")
    print("COMPARISON (cell order y*320+x, exact float32 equality)")
    print(f"  exact matches    : {res['exact_matches']} / {res['total_cells']} ({res['exact_pct']}%)")
    print(f"  max abs error m  : {res['max_abs_error_m']:.6f}")
    print(f"  bounds delta m   : min {res['bounds_error_m']['min']:+.9f}  max {res['bounds_error_m']['max']:+.9f}")
    print("  donor data written to disk: NONE (report only)")


# --------------------------------------------------------------------------- output

def build_json(heights: tuple[float, ...], anchors: dict) -> dict:
    raw = struct.pack(f"<{CELLS}f", *heights)
    s = stats(heights)
    return {
        "map_w": GRID_SIDE,
        "map_h": GRID_SIDE,
        "seed": 0,
        "height": base64.b64encode(raw).decode("ascii"),
        "tileblock": base64.b64encode(bytes(CELLS)).decode("ascii"),
        "meta": {
            "importer": "import_donor_map.py",
            "importer_version": TOOL_VERSION,
            "source_map": Path(anchors["source"]).name,
            "source_map_sha256": anchors["sha256"],
            "source_size_bytes": anchors["size_bytes"],
            "terrain_map_begin_offset": hex(anchors["marker"]),
            "terrain_map_end_offset": hex(anchors["end_marker"]),
            "grid_header_offset": hex(anchors["grid_header"]),
            "height_grid_offset": hex(anchors["grid_off"]),
            "height_bytes": HEIGHT_BYTES,
            "height_min_m": s["min"],
            "height_max_m": s["max"],
            "height_mean_m": s["mean"],
            "tileblock_origin": "NEUTRAL_ZERO_PLACEHOLDER",
            "tileblock_note": ("Donor tile-index semantics UNVERIFIED (DECOMP-06 3.4); "
                               "zeros only satisfy heightmap_splat.py::load_dump, "
                               "not donor-derived tile data."),
            "height_row_orientation": "UNVERIFIED; row-major y*320+x as stored on disk",
            "donor_data_written": False,
        },
    }


def guard_out(out: Path) -> None:
    rp = out.expanduser().resolve()
    if rp == ROOT or ROOT in rp.parents:
        raise ImportError_(f"refusing to write inside the repository: {out}")
    return None


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Read-only donor .map height-grid importer (float32[320x320] -> dump JSON).",
        epilog=SCHEMA_TEXT + "Donor files are private use; no binary is copied or executed.\n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("map", type=Path, nargs="?", help="absolute path to a donor .map file (read-only)")
    p.add_argument("--verify", action="store_true",
                   help="compare decoded grid with a local dump; write nothing")
    p.add_argument("--dump", type=Path, default=DEFAULT_DUMP,
                   help=f"local dump for --verify (default: {DEFAULT_DUMP})")
    p.add_argument("--out", type=Path,
                   help="output JSON path OUTSIDE this repo (default: stdout)")
    p.add_argument("--tileblock", choices=("zero", "omit"), default="zero",
                   help="zero placeholder (default, load_dump-compatible) or omit the key")
    p.add_argument("--survey", action="store_true",
                   help="print opaque structure counts (tile/named records); no semantics")
    p.add_argument("--schema", action="store_true", help="print emitted schema and exit")
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.schema:
        print(SCHEMA_TEXT, end="")
        return 0
    if args.map is None:
        build_parser().error("MAP is required (or use --schema)")

    try:
        heights, anchors = read_donor(args.map)
        if args.verify:
            if args.out is not None:
                print("--verify is read-only; ignoring --out", file=sys.stderr)
            print_verify(anchors, compare(heights, anchors, args.dump))
        else:
            doc = build_json(heights, anchors)
            if args.tileblock == "omit":
                doc.pop("tileblock", None)
            text = json.dumps(doc, indent=2, sort_keys=True) + "\n"
            if args.out is None:
                sys.stdout.write(text)
            else:
                guard_out(args.out)
                args.out.expanduser().parent.mkdir(parents=True, exist_ok=True)
                args.out.expanduser().write_text(text, encoding="utf-8")
                print(f"wrote {args.out} (donor file read-only, nothing copied)", file=sys.stderr)
        if args.survey:
            s = survey(anchors["data"], anchors)
            print("STRUCTURE SURVEY (parsed, SEMANTICS UNVERIFIED)", file=sys.stderr)
            print(json.dumps(s, indent=2, sort_keys=True), file=sys.stderr)
        return 0
    except (OSError, ValueError, ImportError_, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
