#!/usr/bin/env python3
"""Read-only donor `.map` importer -> height/splat dump JSON + donor data survey.

Private-use tool for a locally installed Cossacks 3. It ONLY reads the donor
file (open(..., 'rb').read()); it never executes donor code, never copies a
donor binary into this repository, and never writes inside the repository.
Default output is stdout; an explicit --out must resolve outside this repo.

Modes
-----
(default)                 emit the heightmap_splat.py dump JSON (schema below)
--verify                  read-only compare against a local g32-style dump
--survey                  print decoded tile-index histogram + record counts (stderr)
--export-placements       emit a JSON sample of GameObject placements + tile summary

Proven by this tool / cited reports
-----------------------------------
* DECOMP-06: after `TerrainMapBegin`, the SECOND repeated `u32 W,u32 W` header
  precedes a plain LE `float32[W*H]` height grid (+8 bytes). 320x320 for
  bonmis1/engmis4, 384x384 for battle1 (DEEPDEC-05 §2.1) -- W/H are NEVER
  hard-coded by the parser.
* DEEPDEC-05 §3: 37-byte tile records start after a short post-grid float run;
  bytes 8..11 are four u8 tile indices, ordinals into donor `tiles.lib`
  (mirrored by `variant3d/assets/terrain/structs/tileblocks.json`), and bytes
  16..31 are four constant 1.0f weights. Index->name is decoded from donor
  text, not invented.
* DEEPDEC-05 §4: named-coordinate records are variable length:
  `u32 count`, then `count * (u32 nameLen | "xNyM" | 5*f32)`.
* DEEPDEC-05 §5: `GameObjectBegin` records carry typed, named, player-owned
  placements; only category/type/instance/owner strings and the first float
  triplet are decoded here. All other field semantics are UNVERIFIED.

The tile-index -> tile-name mapping and placement roles are readings of donor
text (DEEPDEC-05), not guesses by this tool. Anything not proven is labelled
UNVERIFIED in the emitted metadata; no meaning is invented.

Reference: docs/coord_swarm_2026-11-24/reports/DECOMP_06_map_format.md
           docs/coord_swarm_2026-11-24/reports/DEEPDEC_05_map_serialization.md
           docs/coord_swarm_2026-11-24/reports/V783_donor_map_importer.md

Usage (from project root)::

    python variant3d/tools/import_donor_map.py --help
    python variant3d/tools/import_donor_map.py MAP --out /tmp/donor_height.json
    python variant3d/tools/import_donor_map.py MAP --verify
    python variant3d/tools/import_donor_map.py MAP --survey
    python variant3d/tools/import_donor_map.py MAP --export-placements --limit 5
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
from collections import Counter
from pathlib import Path

TOOL_VERSION = "1.1.0"
ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DUMP = ROOT / "app" / "shots" / "g32_dump.json"
DEFAULT_TILEBLOCKS = ROOT / "variant3d" / "assets" / "terrain" / "structs" / "tileblocks.json"

GRID_SIDE = 320                        # g32 dump / --verify reference only
TILE_RECORD_BYTES = 37
END_PREFIX_BYTES = 4
NAMED_NAME_RE = re.compile(rb"x\d+y\d+")
ASCII_RE = re.compile(rb"^[ -~]+$")
ONE_QUAD = struct.pack("<4f", 1.0, 1.0, 1.0, 1.0)

SCHEMA_TEXT = """\
Default dump JSON (consumed by heightmap_splat.py::load_dump):
  map_w, map_h : int   320, 320 for bonmis1/engmis4 (384 for battle1)
  seed         : int   0 (no donor seed is known; not donor-derived)
  height       : str   base64 of little-endian float32[map_w*map_h], metres
  tileblock    : str   base64 of uint8[map_w*map_h]; ZERO PLACEHOLDER by default
                       (use --tileblock omit for a height-only document)
  meta         : obj   importer version, source path/hash, byte offsets,
                       measured bounds, and the tileblock caveat
--export-placements JSON:
  gameobject_begin_count, placements[{begin_prefix_offset, category, type,
  f32_0, f32_1, f32_2, strings_after_floats, mesh_hint}], tile_grid summary.
  Roles are DEEPDEC-05 readings; all other field semantics are UNVERIFIED.
Base64 uses validate=True-compatible ASCII (Godot Marshall format).
Numeric arrays are row-major: index = y * map_w + x.
Donor files are private use; no binary is copied or executed.
"""


class ImportError_(ValueError):
    """A donor map / JSON validation failure with a user-facing message."""


# --------------------------------------------------------------------------- donor

def _lp_string(data: bytes, off: int, lo: int = 0, hi: int = 256,
               ascii_only: bool = True) -> tuple[str, int] | None:
    """Read one int32-length-prefixed string at `off`; (value, next_offset)."""
    if off < 0 or off + 4 > len(data):
        return None
    length = struct.unpack_from("<i", data, off)[0]
    if not lo <= length <= hi or off + 4 + length > len(data):
        return None
    raw = data[off + 4:off + 4 + length]
    if ascii_only and not ASCII_RE.fullmatch(raw):
        return None
    return raw.decode("latin-1"), off + 4 + length


def _locate(data: bytes) -> dict:
    """Find and validate the TerrainMapBegin / repeated-header / grid anchors."""
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
    # "TerrainMapEnd" is 13 ASCII bytes. DECOMP-06:119's "int32 16" is the
    # prefix of the NEXT string, not this one (V7-83 correction).
    if struct.unpack_from("<i", data, end_marker - 4)[0] != 13:
        raise ImportError_("TerrainMapEnd length prefix != 13; unexpected stream layout")

    # DEEPDEC-05 §2.1: W/H vary (320 for bonmis1/engmis4, 384 for battle1).
    block_header = marker + 15
    w, h = struct.unpack_from("<II", data, block_header)
    if w != h or not 64 <= w <= 1024:
        raise ImportError_(f"unexpected terrain dimensions {w}x{h} at {hex(block_header)}")
    pair = struct.pack("<II", w, w)
    headers: list[int] = []
    i = block_header
    while True:
        i = data.find(pair, i)
        if i < 0 or i >= end_marker:
            break
        headers.append(i)
        i += 1
    if len(headers) < 2:
        raise ImportError_(f"expected >=2 {w}x{w} headers after TerrainMapBegin, found {len(headers)}")
    grid_header = headers[1]              # DECOMP-06 3.2 / DEEPDEC-05 §9
    if not marker < grid_header < end_marker:
        raise ImportError_("second dimension header lies outside the terrain section")
    grid_off = grid_header + len(pair)
    cells = w * h
    if grid_off + cells * 4 > end_marker:
        raise ImportError_("height grid runs past TerrainMapEnd; refusing to decode")
    return {
        "marker": marker, "end_marker": end_marker, "headers": headers,
        "grid_header": grid_header, "grid_off": grid_off,
        "w": w, "h": h, "cells": cells,
    }


def read_donor(path: Path) -> tuple[tuple[float, ...], dict]:
    """Decode the donor height grid. Returns (heights, anchors). Read-only."""
    if not path.is_file():
        raise FileNotFoundError(f"donor map not found: {path}")
    data = path.read_bytes()              # the ONLY donor file access
    anchors = _locate(data)
    heights = struct.unpack_from(f"<{anchors['cells']}f", data, anchors["grid_off"])
    anchors["source"] = str(path)
    anchors["sha256"] = hashlib.sha256(data).hexdigest()
    anchors["size_bytes"] = len(data)
    anchors["data"] = data                # kept in memory only; never written
    return heights, anchors


def stats(heights: tuple[float, ...]) -> dict:
    return {
        "cells": len(heights), "min": min(heights), "max": max(heights),
        "mean": round(sum(heights) / len(heights), 6),
    }


# ---------------------------------------------------------------------- tile grid

def find_tile_grid(data: bytes, anchors: dict) -> int:
    """Locate the 37-byte tile record array by its invariant 1.0f quad.

    The post-grid float run is 2,556 B for 320 maps but 3,068 B for battle1
    (DEEPDEC-05 §2.1), so the gap is measured, not hard-coded.
    """
    grid_end = anchors["grid_off"] + anchors["cells"] * 4
    end = anchors["end_marker"]
    probes = (0, 1, 2, 3, anchors["cells"] - 1)
    pos = grid_end
    while True:
        pos = data.find(ONE_QUAD, pos)
        if pos < 0 or pos > end:
            raise ImportError_("37-byte tile record array not found after height grid")
        off = pos - 16
        if off >= grid_end and off + anchors["cells"] * TILE_RECORD_BYTES <= end:
            if all(struct.unpack_from("<4f", data, off + k * TILE_RECORD_BYTES + 16) == (1.0,) * 4
                   for k in probes):
                # bytes 5..6 are 0xFFFF for every record except record 0
                if all(data[off + k * TILE_RECORD_BYTES + 5:off + k * TILE_RECORD_BYTES + 7] == b"\xff\xff"
                       for k in (1, 2)):
                    return off
        pos += 1


def load_tile_names(path: Path | None) -> dict[int, str]:
    """DEEPDEC-05 §3 / evidence line 46: tiles.lib ordinal == tileblocks.json position."""
    if path is None or not path.is_file():
        return {}
    doc = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(doc, list):
        return {}
    return {i: (item["name"] if isinstance(item, dict) and isinstance(item.get("name"), str)
                else str(item)) for i, item in enumerate(doc)}


def survey(data: bytes, anchors: dict, tile_names: dict[int, str]) -> dict:
    """Decode tile indices and count opaque structures. No semantics invented."""
    cells = anchors["cells"]
    tile_off = find_tile_grid(data, anchors)
    tile_end = tile_off + cells * TILE_RECORD_BYTES
    weights_ok = 0
    per_position = [Counter() for _ in range(4)]
    combined: Counter[int] = Counter()
    for k in range(cells):
        off = tile_off + k * TILE_RECORD_BYTES
        if struct.unpack_from("<4f", data, off + 16) == (1.0,) * 4:
            weights_ok += 1
        for p in range(4):
            tid = data[off + 8 + p]
            per_position[p][tid] += 1
            combined[tid] += 1

    # ---- named-coordinate array (DEEPDEC-05 §4: u32 count + variable records)
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
    declared_count = (struct.unpack_from("<I", data, named_off - 4)[0]
                      if named_off >= 4 else -1)
    named_count = 0
    sizes: Counter[int] = Counter()
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
            sizes[total] += 1
            off += total
            named_count += 1

    # ---- GameObjectBegin census (DEEPDEC-05 §5)
    go_offs: list[int] = []
    i = 0
    while True:
        i = data.find(b"GameObjectBegin", i)
        if i < 0:
            break
        if i >= 4 and struct.unpack_from("<i", data, i - 4)[0] == 15:
            go_offs.append(i - 4)
        i += 1

    top = [{"id": tid, "name": tile_names.get(tid, "<unresolved>"), "count": cnt}
           for tid, cnt in combined.most_common(12)]
    return {
        "grid": {"w": anchors["w"], "h": anchors["h"], "cells": cells,
                 "height_grid_offset": hex(anchors["grid_off"]),
                 "height_grid_end": hex(anchors["grid_off"] + cells * 4)},
        "tile": {"first": hex(tile_off), "end": hex(tile_end), "records": cells,
                 "stride_bytes": TILE_RECORD_BYTES, "trailing_1f_quad_ok": weights_ok,
                 "gap_from_height_grid_bytes": tile_off - (anchors["grid_off"] + cells * 4),
                 "distinct_ids_all_four_positions": len(combined),
                 "id_range": [min(combined), max(combined)] if combined else None,
                 "per_position_distinct": [len(c) for c in per_position],
                 "histogram_all_positions": {str(tid): combined[tid] for tid in sorted(combined)},
                 "top_ids": top,
                 "name_source": "DEEPDEC-05 §3: donor tiles.lib ordinal; repo tileblocks.json order mirror",
                 "unresolved_ids": [tid for tid in sorted(combined) if tid not in tile_names]},
        "named": {"count_prefix_offset": hex(named_off - 4) if named_off >= 4 else None,
                  "declared_count": declared_count, "parsed_count": named_count,
                  "first": hex(named_off) if named_off >= 0 else None,
                  "end": hex(anchors["end_marker"] - END_PREFIX_BYTES),
                  "record_sizes": dict(sorted(sizes.items())),
                  "world_coordinate_rule": "DEEPDEC-05 §4: world = 2*idx - (N-1); consumer UNVERIFIED"},
        "gameobject": {"begin_count": len(go_offs), "first_offset": hex(go_offs[0]) if go_offs else None,
                       "field_semantics": "UNVERIFIED beyond category/type/instance/owner (DEEPDEC-05 §5)"},
    }


# ---------------------------------------------------------------------- placements

def decode_placements(data: bytes, anchors: dict, limit: int) -> dict:
    """Decode a bounded sample of GameObjectBegin records (DEEPDEC-05 §5 grammar)."""
    go_offs: list[int] = []
    i = 0
    while len(go_offs) < limit:
        i = data.find(b"GameObjectBegin", i)
        if i < 0:
            break
        if i >= 4 and struct.unpack_from("<i", data, i - 4)[0] == 15:
            go_offs.append(i - 4)
        i += 1

    samples = []
    for off in go_offs:
        q = off + 4 + len(b"GameObjectBegin")
        first = _lp_string(data, q, 1, 128)
        second = _lp_string(data, first[1], 1, 128) if first else None
        if not second or second[1] + 12 > len(data):
            samples.append({"begin_prefix_offset": hex(off), "error": "header strings unreadable"})
            continue
        f = struct.unpack_from("<3f", data, second[1])
        q = second[1] + 12
        after: list[str] = []
        for _ in range(4):
            item = _lp_string(data, q, 1, 128)
            if item is None:
                break
            after.append(item[0])
            q = item[1]
        mesh = None
        r = q
        while r < min(q + 2048, len(data) - 8):
            item = _lp_string(data, r, 4, 128)
            if item and item[0].endswith(".mesh"):
                mesh = {"offset": hex(r + 4), "name": item[0]}
                break
            r += 1
        samples.append({
            "begin_prefix_offset": hex(off),
            "category": first[0],
            "type": second[0],
            "f32_0": f[0], "f32_1": f[1], "f32_2": f[2],
            "strings_after_floats": after,
            "roles_after_floats": "DEEPDEC-05 §5 reading: instance, type, category, owner (not re-proven here)",
            "mesh_hint": mesh,
            "field_semantics": "UNVERIFIED beyond the decoded strings and first float triplet",
        })
    total = 0
    i = 0
    while True:
        i = data.find(b"GameObjectBegin", i)
        if i < 0:
            break
        if i >= 4 and struct.unpack_from("<i", data, i - 4)[0] == 15:
            total += 1
        i += 1
    return {
        "source_map": Path(anchors["source"]).name,
        "source_map_sha256": anchors["sha256"],
        "begin_prefix_pattern": "int32 15 + 'GameObjectBegin' (DEEPDEC-05 §5)",
        "gameobject_begin_count": total,
        "sample_limit": limit,
        "samples": samples,
        "labels": {
            "category_type_instance_owner": "DECODED_FROM_DONOR_TEXT (DEEPDEC-05 §5)",
            "float_triplet": "raw LE float32 values; world meaning UNVERIFIED",
            "mesh_hint": "first lp string ending '.mesh' within 2048 B after the four strings; consumer UNVERIFIED",
        },
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
    if (w, h) != (GRID_SIDE, GRID_SIDE) or n != GRID_SIDE * GRID_SIDE:
        raise ImportError_(f"{path}: expected 320x320/102400 height cells, got {w}x{h}/{n}")
    return struct.unpack_from(f"<{GRID_SIDE * GRID_SIDE}f", raw, 0)


def compare(donor_h: tuple[float, ...], anchors: dict, dump_path: Path) -> dict:
    if (anchors["w"], anchors["h"]) != (GRID_SIDE, GRID_SIDE):
        raise ImportError_(f"--verify compares against a 320x320 dump; this map is "
                           f"{anchors['w']}x{anchors['h']}")
    if not dump_path.is_file():
        raise FileNotFoundError(f"local dump not found: {dump_path}")
    doc = json.loads(dump_path.read_text(encoding="utf-8"))
    if not isinstance(doc, dict):
        raise ImportError_(f"{dump_path}: root must be a JSON object")
    local = _dump_floats(doc, dump_path)
    cells = GRID_SIDE * GRID_SIDE
    exact = sum(a == b for a, b in zip(donor_h, local))
    max_err = max(abs(a - b) for a, b in zip(donor_h, local))
    ds, ls = stats(donor_h), stats(local)
    return {
        "dump": str(dump_path), "dump_sha256": hashlib.sha256(dump_path.read_bytes()).hexdigest(),
        "donor": ds, "local": ls, "exact_matches": exact, "total_cells": cells,
        "exact_pct": round(100.0 * exact / cells, 4), "max_abs_error_m": max_err,
        "bounds_error_m": {"min": round(ls["min"] - ds["min"], 9),
                           "max": round(ls["max"] - ds["max"], 9)},
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
    print("COMPARISON (cell order y*map_w+x, exact float32 equality)")
    print(f"  exact matches    : {res['exact_matches']} / {res['total_cells']} ({res['exact_pct']}%)")
    print(f"  max abs error m  : {res['max_abs_error_m']:.6f}")
    print(f"  bounds delta m   : min {res['bounds_error_m']['min']:+.9f}  max {res['bounds_error_m']['max']:+.9f}")
    print("  donor data written to disk: NONE (report only)")


# --------------------------------------------------------------------------- output

def build_json(heights: tuple[float, ...], anchors: dict) -> dict:
    s = stats(heights)
    return {
        "map_w": anchors["w"], "map_h": anchors["h"], "seed": 0,
        "height": base64.b64encode(struct.pack(f"<{len(heights)}f", *heights)).decode("ascii"),
        "tileblock": base64.b64encode(bytes(anchors["cells"])).decode("ascii"),
        "meta": {
            "importer": "import_donor_map.py", "importer_version": TOOL_VERSION,
            "source_map": Path(anchors["source"]).name,
            "source_map_sha256": anchors["sha256"],
            "source_size_bytes": anchors["size_bytes"],
            "terrain_map_begin_offset": hex(anchors["marker"]),
            "terrain_map_end_offset": hex(anchors["end_marker"]),
            "grid_header_offset": hex(anchors["grid_header"]),
            "height_grid_offset": hex(anchors["grid_off"]),
            "height_bytes": anchors["cells"] * 4,
            "height_min_m": s["min"], "height_max_m": s["max"], "height_mean_m": s["mean"],
            "tileblock_origin": "NEUTRAL_ZERO_PLACEHOLDER",
            "tileblock_note": ("Donor tile-index semantics UNVERIFIED at dump time; zeros only satisfy "
                               "heightmap_splat.py::load_dump. Use --survey / --export-placements "
                               "for the decoded donor tile ids (DEEPDEC-05 §3)."),
            "height_row_orientation": "UNVERIFIED; row-major y*map_w+x as stored on disk",
            "donor_data_written": False,
        },
    }


def guard_out(out: Path) -> None:
    rp = out.expanduser().resolve()
    if rp == ROOT or ROOT in rp.parents:
        raise ImportError_(f"refusing to write inside the repository: {out}")


def emit(text: str, out: Path | None) -> None:
    if out is None:
        sys.stdout.write(text)
    else:
        guard_out(out)
        target = out.expanduser()
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")
        print(f"wrote {target} (donor file read-only, nothing copied)", file=sys.stderr)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Read-only donor .map height importer + tile/placement survey (DEEPDEC-05).",
        epilog=SCHEMA_TEXT, formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("map", type=Path, nargs="?", help="absolute path to a donor .map file (read-only)")
    p.add_argument("--verify", action="store_true",
                   help="compare decoded grid with a local 320x320 dump; write nothing")
    p.add_argument("--dump", type=Path, default=DEFAULT_DUMP,
                   help=f"local dump for --verify (default: {DEFAULT_DUMP})")
    p.add_argument("--out", type=Path,
                   help="output JSON path OUTSIDE this repo (default: stdout)")
    p.add_argument("--tileblock", choices=("zero", "omit"), default="zero",
                   help="zero placeholder (default, load_dump-compatible) or omit the key")
    p.add_argument("--survey", action="store_true",
                   help="print decoded tile-index histogram + record counts to stderr")
    p.add_argument("--export-placements", action="store_true",
                   help="emit JSON with first N GameObject placements + tile summary")
    p.add_argument("--limit", type=int, default=5, help="placement sample size (default: 5)")
    p.add_argument("--tile-names", type=Path, default=DEFAULT_TILEBLOCKS,
                   help="tiles.lib ordinal mirror (default: repo tileblocks.json, read-only)")
    p.add_argument("--schema", action="store_true", help="print emitted schema and exit")
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.schema:
        print(SCHEMA_TEXT, end="")
        return 0
    if args.map is None:
        build_parser().error("MAP is required (or use --schema)")
    if args.limit < 1:
        build_parser().error("--limit must be >= 1")

    try:
        heights, anchors = read_donor(args.map)
        if args.verify:
            if args.out is not None:
                print("--verify is read-only; ignoring --out", file=sys.stderr)
            print_verify(anchors, compare(heights, anchors, args.dump))
        elif args.export_placements:
            names = load_tile_names(args.tile_names)
            sv = survey(anchors["data"], anchors, names)
            doc = decode_placements(anchors["data"], anchors, args.limit)
            doc["tile_grid"] = sv["tile"]
            doc["importer_version"] = TOOL_VERSION
            emit(json.dumps(doc, indent=2, sort_keys=True) + "\n", args.out)
        else:
            doc = build_json(heights, anchors)
            if args.tileblock == "omit":
                doc.pop("tileblock", None)
            emit(json.dumps(doc, indent=2, sort_keys=True) + "\n", args.out)
        if args.survey:
            print("SURVEY (DEEPDEC-05 decode; semantics labelled, nothing invented)", file=sys.stderr)
            print(json.dumps(survey(anchors["data"], anchors, load_tile_names(args.tile_names)),
                             indent=2, sort_keys=True), file=sys.stderr)
        return 0
    except (OSError, ValueError, ImportError_, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
