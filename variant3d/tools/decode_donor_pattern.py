#!/usr/bin/env python3
"""I02 — production decoder for donor ``data/pattern/*.pattern`` (donor-first swarm 2026-11-26).

OWNER FILE: variant3d/tools/decode_donor_pattern.py   (this is the ONLY repo file I02 writes)

WHAT THIS TOOL IS
-----------------
A one-way, offline, Python-only converter.  It READS a donor install and EMITS
derived JSON (numbers + labels + provenance only).  No donor byte, binary or
executable is copied into the repo, no donor binary is executed, no Godot job
is submitted, no git operation is performed.

VERIFIED INPUT FORMAT  (all citations are donor-read-only evidence)
------------------------------------------------------------------
  * F01 (reports/F01_pattern_format.md):
      - N = (w-1)*(h-1); filesize = 8 + 4*w*h + 54*N   [710/710, zero residual]
      - header  <2i  w,h                         @ 0            (8 B)
      - mask    u8[N]                            @ 8            (N B)  occupancy
      - grid    f32[w*h]                         @ G = 8+N      (4wh B)  relief
      - PRE     u8[4]                            @ 8+N+4wh      (4 B)
      - records N x Rec24                        @ PRE+4         (24N B)
          Rec24 = <i id, <4f f[4], u8 tail4[4]   [semantics UNVERIFIED, F01 §4.5]
      - weights i32[4N-1]                        @ records+24N   (16N-4 B) [UNVERIFIED]
      - tail    N x Tail13                       @ size-13N      (13N B)  [UNVERIFIED]
          Tail13 = u8 zero[10], i16 code, u8 flag                [F01 §4.8]
    CRITICAL: the true grid offset is G = 8+(w-1)*(h-1).  The older
    DPATTERN-01 / F02 offsets are SHIFTED for 17/29 audited patterns (F01 §4.4).
    X26_blend_formula_verification.md E14 re-proved this on the three blend
    vector patterns: G=968 (hil1), 1864 (g_hil4), 2798 (k_ravine_1), versus
    stale F02/DPATTERN 1000/1912/2866 (+8/+12/+17 floats).  Min/max match at
    BOTH starts because of long zero borders, so min/max alone cannot locate
    the grid — only F01's exact size law can.  This tool NEVER scans for
    min/max and NEVER uses DPATTERN-01/F02 shifted offsets.  [X26/F01]
  * F02 / X05 (reports/F02_pattern_lib.md, X05_pattern_lib_validation.md):
      - pattern.lib is plaintext CRLF, 680 sections, fixed 37-field prologue.
      - `pattern.lib:L` citations are 1-based LINE numbers, not byte offsets.
      - HeightFieldMin/Max/Scale/flags are line-derived metadata, copied
        verbatim (bit-exact on 12/12 audited grids, X05 V4).
      - Name -> <Name>.pattern, 680/680 case-insensitive; 30 orphans.
      - hil1 HeightFieldScale = 0.649999976158142 = float32(0.65) (X05 A3).
  * D05 / X12 / X26 (reports/D05_relief_stamp.md, X12_stamp_verification.md,
    X26_blend_formula_verification.md):
      - Min is the SCALE PIVOT  g2 <- (g-Min)*Scale + Min; Max is NEVER read
        in sub_755f30 (X26 E7: 0/6,751 struct +0x60 operands); Offset (+0x64)
        is the additive term.  Scale is consumed in EVERY branch [X26].
      - Three branches: ReplaceForWater = g*Scale + Offset;
        Replace = base_h + ((g-Min)*Scale+Min) + Offset   [X26 authoritative;
        refutes the stale spec literal base_h + g + Offset];
        Smooth  = h1 + (base_h-h0)*TerrainScale + ((g-Min)*Scale+Min) + Offset.
      - Smooth post-pass is IN-PLACE read-after-write (X26 E8), 4-neighbour
        mean / hardcoded 4.0f, Factor = iteration count.
      - No donor-parity claim: these are static byte observations, not a frame.

LABELS: [O] observed / [D] derived / [I] inferred / [U] UNVERIFIED.
Undecodable or semantically unidentified regions are emitted as ``null`` with
an explicit UNVERIFIED label.  Nothing is guessed and no zeros are padded in
silently.  ``visual_parity_claim`` is false in every emitted document.

USAGE
-----
  python variant3d/tools/decode_donor_pattern.py --dry-run --check
  python variant3d/tools/decode_donor_pattern.py --game "C:\\Games\\Cossacks 3" \
         --no-dry-run --out variant3d/assets/terrain_new/patterns/

Dry-run is the DEFAULT.  ``--no-dry-run`` (or ``--write``) actually writes.
``--check`` runs the F01/F02/X05/D05/X12 validation battery and exits non-zero
on any failure.  ``--out`` inside the donor root is always refused.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import struct
import sys
from pathlib import Path
from typing import Any

# ---------------------------------------------------------------------------
# Fixed constants (all donor-derived; see module docstring)
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parents[2]  # tools -> variant3d -> repo root
DEFAULT_OUT = REPO_ROOT / "variant3d" / "assets" / "terrain_new" / "patterns"
DEFAULT_GAME = Path(r"C:\Games\Cossacks 3")
PATTERN_SUBDIR = Path("data") / "pattern"

REC24 = struct.Struct("<i4f4s")   # 4 + 16 + 4 = 24 bytes                [F01 §4.5]
TAIL13 = struct.Struct("<10shB")  # 10 + 2 + 1 = 13 bytes                [F01 §4.8]
HDR = struct.Struct("<2i")        # 8 bytes                              [F01 §4.2]

KEY_RE = re.compile(r"^   ([A-Za-z_][A-Za-z0-9_]*) = (.*)$")  # F02 §5.1

BOOL_FIELDS = {
    "TilesStand", "GameObjectsStand", "DecalsStand", "HeightFieldStand",
    "HeightFieldReplace", "HeightFieldReplaceForWater", "HeightFieldUseRndScale",
    "HeightFieldSmooth", "PatternMaskStand", "PatternMaskReverceStand",
    "CollisionStand", "ObjectsOffset", "ObjectsHeightOffset", "IgnoreMatrix",
    "ObjAutoOffset", "Summer", "Autumn", "Winter", "Spring",
}
INT_FIELDS = {
    "Width", "Height", "HeightFieldMinScale", "HeightFieldMaxScale",
    "TerrainScale", "ObjectsScale", "RotationAngle", "HeightFieldSmoothRadius",
    "HeightFieldSmoothFactor", "HeightFieldSmoothOffset", "OffsetX", "OffsetZ",
    "HeightFieldOffset",
}
FLOAT_FIELDS = {"HeightFieldScale", "HeightFieldMin", "HeightFieldMax"}

# The nine stamp-input flags I07 needs (D05 §F2, X12 claim 3).
FLAG_MAP = {
    "Stand": "HeightFieldStand",
    "Scale": "HeightFieldScale",
    "Min": "HeightFieldMin",
    "Max": "HeightFieldMax",
    "Offset": "HeightFieldOffset",
    "TerrainScale": "TerrainScale",
    "Replace": "HeightFieldReplace",
    "ReplaceForWater": "HeightFieldReplaceForWater",
    "Smooth": "HeightFieldSmooth",
}

# The five cited Min/Max line pairs — F02 §5.2 / X05 V3 (1-based LINE numbers).
# byte starts are the starts of the HeightFieldMin / HeightFieldMax lines.
CITED_PAIRS = [
    {"name": "plt2", "line": 6805, "byte": 173669, "grid_offset": 2222,
     "min": -0.0732548981904984, "max": 3.61341166496277,
     "section_begin_line": 6775},
    {"name": "hil1", "line": 33111, "byte": 854933, "grid_offset": 968,
     "min": 0.0, "max": 3.86130237579346,
     "section_begin_line": 33081},
    {"name": "g_hil4", "line": 366499, "byte": 9458861, "grid_offset": 1864,
     "min": -4.32127315701247e-13, "max": 1.91698789596558,
     "section_begin_line": 366469},
    {"name": "k_ravine_1", "line": 549585, "byte": 14196248, "grid_offset": 2798,
     "min": -2.963627576828, "max": 3.13982009887695,
     "section_begin_line": 549555},
    {"name": "k_ravine_big_stone_1", "line": 730045, "byte": 18877479,
     "grid_offset": 8225,
     "min": -2.96362733840942, "max": 0.173864871263504,
     "section_begin_line": 730015},
]
# grid_offset values above are the F01 CORRECTED G=8+(w-1)*(h-1) starts.
# X26 E14 re-proved 968/1864/2798; the F02/DPATTERN starts 1000/1912/2866
# are stale by +8/+12/+17 floats and are NEVER used here. [F01/X26]

# File F01 fully byte-accounted; used for the explicit closure demonstration.
AUDITED_FILES = ("fb_1.pattern", "k_ravine_big_stone_1.pattern")


# ---------------------------------------------------------------------------
# Small deterministic helpers
# ---------------------------------------------------------------------------


# V93 durability (V78): never emit an absolute donor install path.
_ABS_DONOR_PATH = re.compile(r"[A-Za-z]:[\\/](?:[^\\/\n\"]*[\\/])*Cossacks 3")

def _scrub_donor_paths(obj):
    if isinstance(obj, str):
        return _ABS_DONOR_PATH.sub("$COSSACKS3_DIR", obj)
    if isinstance(obj, dict):
        return {k: _scrub_donor_paths(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_scrub_donor_paths(v) for v in obj]
    return obj

def dumps(obj: Any) -> bytes:
    """Canonical UTF-8 JSON: sorted keys, no timestamps, no NaN/Inf."""
    text = json.dumps(_scrub_donor_paths(obj), sort_keys=True, ensure_ascii=True, indent=2,
                      allow_nan=False) + "\n"
    return text.encode("utf-8")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def f32bits(value: float) -> bytes:
    """Exact float32 bit pattern of a value already decoded from float32."""
    return struct.pack("<f", float(value))


def same_f32(a: Any, b: Any) -> bool:
    return f32bits(a) == f32bits(b)


def convert_field(key: str, value: str) -> Any:
    """Type the 37 prologue literals without changing their value."""
    if key in BOOL_FIELDS:
        return value == "True"
    if key in INT_FIELDS:
        try:
            return int(value)
        except ValueError:
            return value
    if key in FLOAT_FIELDS:
        try:
            return float(value)
        except ValueError:
            return value
    return value


# ---------------------------------------------------------------------------
# pattern.lib: line-oriented plaintext DB (F02 §5.1, X05 V1/V3)
# ---------------------------------------------------------------------------

def load_pattern_lib(path: Path) -> dict[str, Any]:
    raw = path.read_bytes()
    lines = raw.split(b"\r\n")

    # offs[i] = byte start of 1-based line i+1  (F02 §5.6 / X05 method).
    offs: list[int] = []
    pos = 0
    for line in lines:
        offs.append(pos)
        pos += len(line) + 2

    sections: dict[str, dict[str, Any]] = {}
    duplicates: list[str] = []
    start: int | None = None
    for n, line in enumerate(lines, 1):
        if line == b"section.begin":
            start = n
        elif line == b"section.end" and start is not None:
            fields: dict[str, Any] = {}
            field_line: dict[str, int] = {}
            field_byte: dict[str, int] = {}
            for i in range(start + 1, n):
                match = KEY_RE.match(lines[i - 1].decode("latin-1"))
                if not match:
                    continue
                key, value = match.group(1), match.group(2)
                fields[key] = convert_field(key, value)
                field_line[key] = i
                field_byte[key] = offs[i - 1]
            name = fields.get("Name", "")
            key = str(name).lower()
            if key in sections:
                duplicates.append(name)
            else:
                sections[key] = {
                    "name": name,
                    "line_start": start,
                    "line_end": n,
                    "byte_start": offs[start - 1],
                    "byte_end": offs[n - 1] + len(lines[n - 1]) + 2,
                    "fields": fields,
                    "field_line": field_line,
                    "field_byte": field_byte,
                    "prologue_ok": False,  # asserted against the ordered 37 keys below
                }
            start = None

    # X05 V1: 680/680 sections carry the identical ordered 37-key prologue.
    expected_keys = [
        "Name", "Width", "Height", "TilesStand", "GameObjectsStand",
        "DecalsStand", "HeightFieldStand", "HeightFieldReplace",
        "HeightFieldReplaceForWater", "HeightFieldUseRndScale",
        "HeightFieldMinScale", "HeightFieldMaxScale", "HeightFieldScale",
        "TerrainScale", "ObjectsScale", "RotationAngle", "HeightFieldSmooth",
        "HeightFieldSmoothRadius", "HeightFieldSmoothFactor",
        "HeightFieldSmoothOffset", "PatternMaskStand",
        "PatternMaskReverceStand", "CollisionStand", "OffsetX", "OffsetZ",
        "ObjectsOffset", "ObjectsHeightOffset", "IgnoreMatrix", "ObjAutoOffset",
        "HeightFieldMin", "HeightFieldMax", "HeightFieldOffset", "NativeSeason",
        "Summer", "Autumn", "Winter", "Spring",
    ]
    prologue_ok = 0
    for section in sections.values():
        actual = [k for k in expected_keys if k in section["field_line"]]
        section["prologue_keys"] = actual
        section["prologue_ok"] = (actual == expected_keys)
        if section["prologue_ok"]:
            prologue_ok += 1

    return {
        "path": path,
        "raw_size": len(raw),
        "line_count": len(lines),
        "sections": sections,
        "duplicates": duplicates,
        "prologue_ok": prologue_ok,
        "expected_keys": expected_keys,
        "offs": offs,
    }


# ---------------------------------------------------------------------------
# .pattern binary decode — exact F01 region walker
# ---------------------------------------------------------------------------

def region_table(w: int, h: int, size: int) -> tuple[int, list[dict[str, Any]]]:
    """N and the seven contiguous regions; contiguity == byte closure [F01 §4.1/§4.2]."""
    n = (w - 1) * (h - 1)
    wh = w * h
    g0 = 8 + n                       # F01 CORRECTED grid offset (NOT DPATTERN-01)
    p0 = g0 + 4 * wh
    r0 = p0 + 4
    w0 = r0 + 24 * n
    t0 = size - 13 * n
    regions = [
        {"name": "header", "offset": 0, "length": 8},
        {"name": "mask", "offset": 8, "length": n},
        {"name": "height", "offset": g0, "length": 4 * wh},
        {"name": "pre", "offset": p0, "length": 4},
        {"name": "records", "offset": r0, "length": 24 * n},
        {"name": "weights", "offset": w0, "length": 16 * n - 4},
        {"name": "tail", "offset": t0, "length": 13 * n},
    ]
    return n, regions


def byte_closure(regions: list[dict[str, Any]], size: int) -> bool:
    cursor = 0
    for region in regions:
        if region["offset"] != cursor or region["length"] < 0:
            return False
        cursor += region["length"]
    return cursor == size


def flags_from_section(section: dict[str, Any] | None) -> dict[str, Any] | None:
    if section is None:
        return None
    fields = section["fields"]
    out: dict[str, Any] = {}
    for emit_key, lib_key in FLAG_MAP.items():
        value = fields.get(lib_key)
        if value is None:
            return None  # never invent a missing flag
        if lib_key in FLOAT_FIELDS or lib_key in INT_FIELDS:
            value = float(value)
        out[emit_key] = value
    return out


def decode_one(path: Path, section: dict[str, Any] | None) -> tuple[dict[str, Any], dict[str, Any]]:
    """Decode one .pattern into a derived JSON record + invariant statistics."""
    raw = path.read_bytes()
    source_sha = sha256(raw)
    stem = path.stem
    name = section["name"] if section else stem

    labels: dict[str, str] = {
        "binary_layout": "[O] F01 §4.1/§4.2: 8+4wh+54(w-1)(h-1), G=8+(w-1)(h-1)",
        "occupancy_cells": "[O] u8[N] 0/1 lattice mask, (h-1)x(w-1) row-major; semantics [U] (F01 §4.3)",
        "relief_float_grid": "[O] f32[w*h] at G=8+N, h x w row-major; engine blend [U] (F01 §4.4)",
        "object_records": "[O] structure only (Rec24); id/tail4 semantics [U] — no prop-name mapping (F01 §4.5/§9)",
        "collision_records": "[U] Tail13 code/flag semantics unidentified — null, not guessed/padded (F01 §4.8)",
        "lattice_weights": "[U] i32[4N-1] semantics unidentified — null, not guessed/padded (F01 §4.7)",
        "original_floats": "[O] Rec24 f[4] verified 1.0f in all records (F01 E13)",
        "blend_inputs": "[D] D05 §F2/F4 + X12 claim 3/4: Min pivot, Max unused in stamp",
        "parity": "[U] no donor GPU A/B frame; visual_parity_claim=false",
    }
    result: dict[str, Any] = {
        "schema": "terrain_new.pattern_decode.v1",
        "name": name,
        "w": None,
        "h": None,
        "occupancy_cells": None,
        "relief_float_grid": None,
        "object_records": None,
        "flags": None,
        "source": str(path),
        "source_sha256": source_sha,
        "labels": labels,
        "visual_parity_claim": False,
        # Explicit extra provenance / undecodable-region fields:
        "collision_records": None,
        "lattice_weights": None,
        "occupancy_layout": "(h-1) x (w-1) row-major u8 0/1 [F01 §4.3]",
        "grid_layout": "h x w row-major f32 at G=8+(w-1)*(h-1) [F01 §4.4]",
        "status": "UNVERIFIED",
    }
    stats: dict[str, Any] = {
        "source": str(path), "sha256": source_sha, "stem": stem,
        "closure": False, "size": len(raw), "record_count": 0,
        "id_ok": False, "f4_ok": False, "tail_zero_ok": False,
        "tail_code_ok": False, "tail_flag_ok": False, "mask_ok": False,
        "grid_min": None, "grid_max": None, "minmax_match": False,
        "dim_mismatch": False, "quarantined": False, "section": section is not None,
    }

    if len(raw) < HDR.size:
        labels["byte_closure"] = "[U] FAIL: file shorter than 8-byte header"
        labels["overall"] = "UNVERIFIED: undecodable header"
        result["label"] = "UNVERIFIED"
        return result, stats

    w, h = HDR.unpack_from(raw, 0)
    stats["w"], stats["h"] = w, h
    result["w"], result["h"] = w, h
    if w < 2 or h < 2:
        labels["byte_closure"] = "[U] FAIL: implausible header w=%d h=%d" % (w, h)
        labels["overall"] = "UNVERIFIED: implausible header"
        result["label"] = "UNVERIFIED"
        return result, stats

    wh = w * h
    n, regions = region_table(w, h, len(raw))
    expected_size = 8 + 4 * wh + 54 * n
    closed = byte_closure(regions, len(raw)) and len(raw) == expected_size
    stats["closure"] = closed
    stats["N"] = n
    result["byte_closure"] = {
        "ok": closed,
        "actual_bytes": len(raw),
        "expected_bytes": expected_size,
        "formula": "8 + 4*w*h + 54*(w-1)*(h-1)  [F01, 710/710]",
        "regions": regions,
    }
    labels["byte_closure"] = (
        "[O] OK: seven contiguous regions, zero residual [F01 §4.1]"
        if closed else "[U] FAIL: byte closure broken — no fields emitted"
    )
    if not closed:
        labels["overall"] = "UNVERIFIED: byte closure failed"
        result["label"] = "UNVERIFIED"
        return result, stats

    mask = list(raw[8:8 + n])
    grid = list(struct.unpack_from("<%df" % wh, raw, regions[2]["offset"]))
    r0 = regions[4]["offset"]
    records = []
    id_ok = f4_ok = True
    for k, (rid, f0, f1, f2, f3, tail4) in enumerate(REC24.iter_unpack(raw[r0:r0 + 24 * n])):
        records.append({
            "k": k,
            "u": k % (w - 1),
            "v": k // (w - 1),
            "id": rid,
            "f4": [f0, f1, f2, f3],
            "tail4": list(tail4),
        })
        if not (0 <= rid <= 255):
            id_ok = False
        if (f0, f1, f2, f3) != (1.0, 1.0, 1.0, 1.0):
            f4_ok = False

    t0 = regions[6]["offset"]
    zero_ok = code_ok = flag_ok = True
    for zero10, code, flag in TAIL13.iter_unpack(raw[t0:]):
        if any(zero10):
            zero_ok = False
        if code not in (-1, 255):
            code_ok = False
        if flag not in (0, 1):
            flag_ok = False

    stats.update({
        "record_count": len(records), "id_ok": id_ok, "f4_ok": f4_ok,
        "tail_zero_ok": zero_ok, "tail_code_ok": code_ok,
        "tail_flag_ok": flag_ok, "mask_ok": all(v in (0, 1) for v in mask),
        "grid_min": min(grid), "grid_max": max(grid),
        "grid_offset": regions[2]["offset"],
        "weight_offset": regions[5]["offset"],
        "tail_offset": t0,
    })

    # Line-derived metadata: join Name -> <Name>.pattern case-insensitively.
    flags = flags_from_section(section)
    dim_mismatch = bool(
        section and (
            section["fields"].get("Width") != w
            or section["fields"].get("Height") != h
        )
    )
    stats["dim_mismatch"] = dim_mismatch
    result["flags"] = flags
    result["grid_offset"] = regions[2]["offset"]
    result["weight_offset"] = regions[5]["offset"]
    result["tail_offset"] = t0
    if section:
        labels["metadata_source"] = (
            "[O] pattern.lib:%d (byte %d) [F02/X05, 1-based LINE]"
            % (section["line_start"], section["byte_start"])
        )
    else:
        labels["metadata_source"] = (
            "[U] no pattern.lib section for this file; all flags null [F02 §5.3]"
        )

    minmax_match = False
    if flags is not None and not dim_mismatch:
        lo = section["fields"].get("HeightFieldMin")
        hi = section["fields"].get("HeightFieldMax")
        if isinstance(lo, (int, float)) and isinstance(hi, (int, float)):
            minmax_match = (same_f32(min(grid), lo) and same_f32(max(grid), hi))
    stats["minmax_match"] = minmax_match
    labels["min_max_crosscheck"] = (
        "[O] bit-exact float32 match vs lib Min/Max at CORRECTED G [F01 §4.4]"
        if minmax_match else (
            "[U] lib Min/Max absent or stale vs binary grid — retained as "
            "labelled metadata, never silently fixed [F01 §4.9]"
        )
    )

    # Quarantine the one known donor dimension anomaly (F02 E17 / X05 A4).
    if dim_mismatch:
        stats["quarantined"] = True
        result["flags"] = None  # stale section: do not attribute flags
        labels["quarantine"] = (
            "[U] QUARANTINED: lib says %sx%s, binary header says %sx%d "
            "(F02 E17 / X05 A4); metadata withheld"
            % (
                section["fields"].get("Width"), section["fields"].get("Height"),
                w, h,
            )
        )
        labels["overall"] = "UNVERIFIED: quarantined donor header anomaly"
        result["status"] = "UNVERIFIED_QUARANTINE"
        result["label"] = "UNVERIFIED"
    else:
        labels["quarantine"] = "[O] no lib/binary dimension mismatch"
        labels["overall"] = (
            "[O] binary DECODED; semantic fields UNVERIFIED; no parity claim"
        )
        result["status"] = "DECODED"
        result["label"] = (
            "[O] DECODED grid+mask; tail semantics UNVERIFIED"
            if minmax_match else
            "[O] DECODED binary; lib Min/Max crosscheck UNVERIFIED"
        )

    # The binary regions above are structurally decoded and kept.  The two
    # regions whose *meaning* is not identified are emitted as null + label.
    result["occupancy_cells"] = mask
    result["relief_float_grid"] = grid
    result["object_records"] = records
    return result, stats


# ---------------------------------------------------------------------------
# D05/X12 blend-input validation and I07 test vectors
# ---------------------------------------------------------------------------

def build_blend_vectors(lib: dict[str, Any], decoded: dict[str, dict[str, Any]]) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    sections = lib["sections"]
    offs = lib["offs"]
    pair_results: list[dict[str, Any]] = []

    for cited in CITED_PAIRS:
        section = sections.get(cited["name"].lower())
        entry: dict[str, Any] = {
            "pattern": cited["name"],
            "lib_line_heightfield_min": cited["line"],
            "lib_byte_start_cited": cited["byte"],
            "lib_byte_start_computed": None,
            "byte_offset_ok": False,
            "lib_min_cited": cited["min"],
            "lib_max_cited": cited["max"],
            "lib_min_actual": None,
            "lib_max_actual": None,
            "literal_ok": False,
            "binary_grid_min": None,
            "binary_grid_max": None,
            "grid_offset_expected": cited["grid_offset"],
            "grid_offset_G": None,
            "grid_offset_ok": False,
            "grid_match": False,
            "label": "[O] F02 §5.2 / X05 V3 line pair; grid crosscheck [F01 §4.4]",
        }
        if section and "HeightFieldMin" in section["field_byte"]:
            computed = section["field_byte"]["HeightFieldMin"]
            entry["lib_byte_start_computed"] = computed
            entry["byte_offset_ok"] = (computed == cited["byte"])
            lo = section["fields"].get("HeightFieldMin")
            hi = section["fields"].get("HeightFieldMax")
            entry["lib_min_actual"], entry["lib_max_actual"] = lo, hi
            if isinstance(lo, (int, float)) and isinstance(hi, (int, float)):
                entry["literal_ok"] = (
                    same_f32(lo, cited["min"]) and same_f32(hi, cited["max"])
                )
            rec = decoded.get(cited["name"].lower())
            if rec and rec.get("relief_float_grid") is not None:
                grid = rec["relief_float_grid"]
                entry["grid_offset_G"] = rec.get("grid_offset")
                entry["grid_offset_ok"] = (
                    entry["grid_offset_G"] == cited["grid_offset"]
                )  # F01/X26 exact offset, not min/max inference
                entry["binary_grid_min"] = min(grid)
                entry["binary_grid_max"] = max(grid)
                entry["grid_match"] = (
                    same_f32(min(grid), cited["min"])
                    and same_f32(max(grid), cited["max"])
                )
        pair_results.append(entry)

    hil1 = sections.get("hil1")
    hil1_scale = hil1["fields"].get("HeightFieldScale") if hil1 else None
    scale_ok = (
        isinstance(hil1_scale, (int, float))
        and same_f32(hil1_scale, 0.65)
        and abs(float(hil1_scale) - 0.649999976158142) < 1e-15
    )

    branches = [
        {
            "name": "ReplaceForWater",
            "condition": "ReplaceForWater == true",
            "formula": "new = g*Scale + Offset",
            "uses_min_pivot": False,
            "reads_max": False,
            "reads_current_height": False,
            "evidence": "D05 §F4 / X12 claim 4, opcodes 0x75661f-0x756651",
            "label": "[O] static bytecode observation; not a rendered frame",
        },
        {
            "name": "Replace",
            "condition": "ReplaceForWater == false and Replace == true",
            "formula": "new = base_h + ((g-Min)*Scale+Min) + Offset",
            "uses_min_pivot": True,
            "reads_max": False,
            "reads_current_height": False,
            "evidence": "D05 §F4 / X12 claim 4, opcodes 0x75666e-0x756690",
            "label": "[O] static bytecode observation; not a rendered frame",
        },
        {
            "name": "Smooth",
            "condition": "default (ReplaceForWater == false and Replace == false)",
            "formula": "new = h1 + (base_h-h0)*TerrainScale + ((g-Min)*Scale+Min) + Offset",
            "uses_min_pivot": True,
            "reads_max": False,
            "reads_current_height": True,
            "evidence": "D05 §F4 / X12 claim 4, two getHeight reads 0x7566a0/0x7566c7",
            "label": "[O] static bytecode observation; not a rendered frame",
        },
    ]

    # Concrete I07 vectors: donor constants in, formula outputs out.
    # Synthetic g/base_h samples are explicitly labelled derived; they are NOT
    # donor observations and they are NOT a parity claim.
    vectors: list[dict[str, Any]] = []
    for cited in CITED_PAIRS:
        section = sections.get(cited["name"].lower())
        if not section:
            continue
        fields = section["fields"]
        lo = float(fields["HeightFieldMin"])
        hi = float(fields["HeightFieldMax"])
        scale = float(fields["HeightFieldScale"])
        offset = float(fields["HeightFieldOffset"])
        terrain_scale = float(fields["TerrainScale"])
        samples = [("min", lo), ("mid", (lo + hi) / 2.0), ("max", hi)]
        for sample_name, g in samples:
            pivot = (g - lo) * scale + lo
            vectors.append({
                "pattern": cited["name"],
                "sample": sample_name,
                "g": g,
                "Min": lo, "Max": hi,
                "Scale": scale, "Offset": offset,
                "TerrainScale": terrain_scale,
                "base_h": 1.0, "h0": 1.0, "h1": 1.0,
                "expected_ReplaceForWater": g * scale + offset,
                "expected_Replace": 1.0 + pivot + offset,
                "expected_Smooth": 1.0 + (1.0 - 1.0) * terrain_scale + pivot + offset,
                "label": "[D] computed from D05/X12/X26 opcode-verified formulas with "
                         "F02/X05 donor constants; synthetic g/base_h, no donor frame",
            })

    doc = {
        "schema": "terrain_new.blend_test_vectors.v1",
        "generator": "variant3d/tools/decode_donor_pattern.py (I02)",
        "evidence": [
            "D05_relief_stamp.md §F2/F3/F4/F5 (cossacks.exe sub_755f30)",
            "X12_stamp_verification.md claims 3/4/5 (opcode-level re-verification)",
            "X26_blend_formula_verification.md (authoritative formula table, E7/E8/E14)",
            "F01_pattern_format.md §4.1/§4.2/§4.4 (size law + corrected grid G=8+N)",
            "F02_pattern_lib.md §5.2 + X05_pattern_lib_validation.md V3/A3",
        ],
        "corrected_grid_offsets": {
            "formula": "G = 8 + (w-1)*(h-1)  [F01 §4.4; X26 E14]",
            "hil1": 968, "g_hil4": 1864, "k_ravine_1": 2798,
            "stale_F02_DPATTERN": {"hil1": 1000, "g_hil4": 1912,
                                   "k_ravine_1": 2866},
            "stale_shift_floats": {"hil1": 8, "g_hil4": 12, "k_ravine_1": 17},
            "x13_note": "X13_blend_test_vectors.md E4-E6 used G=1000/1912/2866 "
                        "(stale); X26 E14 proved all 19 of its g_bits sit in "
                        "shifted windows. Use THIS file's corrected grid values, "
                        "not X13's g_bits, for spatial stamping.",
            "label": "[O] F01 size closure + X26 vector provenance; min/max "
                     "cannot discriminate shifted windows (zero borders)",
        },
        "visual_parity_claim": False,
        "min_is_scale_pivot": True,
        "max_never_read_in_stamp": True,
        "min_pivot_formula": "g <- (g-Min)*Scale + Min  (only when !ReplaceForWater)",
        "max_role": "metadata only in sub_755f30; parser stores +0x60 but stamp never reads it",
        "hil1_scale_check": {
            "pattern": "hil1",
            "observed_literal": hil1_scale,
            "float32_of_0_65": 0.65,
            "ok": scale_ok,
            "evidence": "X05 A3 / D05 F3/F6: HeightFieldScale=0.649999976158142",
            "label": "[O] donor literal equals float32(0.65) bit-for-bit",
        },
        "cited_min_max_pairs": pair_results,
        "blend_branches": branches,
        "vectors": vectors,
        "smooth_postpass": {
            "kernel": "4-neighbour mean / 4.0f (hardcoded constant @VA 0x755ee4)",
            "iterations": "HeightFieldSmoothFactor (config), not the divisor",
            "interior_only": "own cell and all 8 neighbours must be mask==0",
            "update_order": "in-place read-after-write on the same world height "
                            "field (4 getHeight + 1 setHeight in sub_755db4); "
                            "NO snapshot/double buffer [X26 E8]",
            "evidence": "D05 §F5 / X12 §R1 / X26 E8 (resolves X13 U6); "
                        "const 4.0f @VA 0x755ee4",
            "label": "[O] static bytecode observation; radial remap rounding [U]",
        },
        "precision_note": "[D] vector outputs use Python double arithmetic. For bit-exact "
                          "replay I07 must round to float32 after each donor store "
                          "(X26 P6 d05_f32step 19/19), preserve the two getHeight reads "
                          "in Smooth, and the 80-bit tbyte spill at 0x7566b7.",
        "labels": {
            "blend": "[O] D05/X12/X26 opcode-verified for sub_755f30 only; global setter clamp [U]",
            "vectors": "[D] arithmetic from donor constants and verified formulas; no donor frame",
            "parity": "[U] no donor GPU A/B frame exists",
        },
    }
    return doc, pair_results


# ---------------------------------------------------------------------------
# Validation battery (--check)
# ---------------------------------------------------------------------------

class CheckBook:
    def __init__(self) -> None:
        self.rows: list[tuple[str, bool, str]] = []

    def add(self, name: str, ok: bool, detail: str = "") -> None:
        self.rows.append((name, bool(ok), detail))

    @property
    def passed(self) -> int:
        return sum(1 for _, ok, _ in self.rows if ok)

    @property
    def failed(self) -> int:
        return len(self.rows) - self.passed

    def report(self) -> None:
        print("CHECK SUMMARY: PASS %d / FAIL %d" % (self.passed, self.failed))
        for name, ok, detail in self.rows:
            print("  %-4s %-46s %s" % ("PASS" if ok else "FAIL", name, detail))


def is_within(path: Path, root: Path) -> bool:
    try:
        return os.path.commonpath([str(path.resolve()), str(root.resolve())]) == str(root.resolve())
    except ValueError:  # different Windows drives
        return False


def run_checks(game_root: Path, out: Path, pat_dir: Path, lib: dict[str, Any],
               stats: list[dict[str, Any]], records: list[dict[str, Any]],
               decoded: dict[str, dict[str, Any]],
               pair_results: list[dict[str, Any]],
               pipeline_sha: str) -> CheckBook:
    book = CheckBook()
    n_files = len(stats)

    book.add("donor pattern dir exists", pat_dir.is_dir(), str(pat_dir))
    book.add("710 .pattern files enumerated", n_files == 710, "found %d" % n_files)
    book.add("F01 size law / byte closure 710/710",
             sum(s["closure"] for s in stats) == n_files,
             "%d/%d" % (sum(s["closure"] for s in stats), n_files))
    book.add("mask bytes are 0/1 (F01 E6)",
             all(s["mask_ok"] for s in stats),
             "%d/%d" % (sum(s["mask_ok"] for s in stats), n_files))
    book.add("Rec24 f[4] all exactly 1.0f (F01 E13)",
             all(s["f4_ok"] for s in stats),
             "%d/%d" % (sum(s["f4_ok"] for s in stats), n_files))
    book.add("Rec24 id in 0..255 (F01 E13)",
             all(s["id_ok"] for s in stats),
             "%d/%d" % (sum(s["id_ok"] for s in stats), n_files))
    book.add("Tail13 zero[10] all zero (F01 E17)",
             all(s["tail_zero_ok"] for s in stats),
             "%d/%d" % (sum(s["tail_zero_ok"] for s in stats), n_files))
    book.add("Tail13 code in {-1,255} (F01 E17)",
             all(s["tail_code_ok"] for s in stats),
             "%d/%d" % (sum(s["tail_code_ok"] for s in stats), n_files))
    book.add("Tail13 flag in {0,1} (F01 E17)",
             all(s["tail_flag_ok"] for s in stats),
             "%d/%d" % (sum(s["tail_flag_ok"] for s in stats), n_files))

    book.add("pattern.lib 680 sections", len(lib["sections"]) == 680,
             "%d" % len(lib["sections"]))
    book.add("37-key prologue 680/680 (X05 V1)", lib["prologue_ok"] == 680,
             "%d/680" % lib["prologue_ok"])
    book.add("no duplicate section names", not lib["duplicates"],
             "%d duplicates" % len(lib["duplicates"]))

    joined = sum(1 for s in stats if s["section"])
    orphans = n_files - joined
    book.add("case-insensitive Name->file join 680/680 (X05 V2)", joined == 680,
             "%d joined, %d orphans" % (joined, orphans))
    book.add("orphan count 30 (F02/X05; F01 §4.9 says 31)", orphans == 30,
             "%d" % orphans)
    mismatches = [s["stem"] for s in stats if s["dim_mismatch"]]
    book.add("exactly one dim anomaly (m_swamp_12_old)",
             sorted(mismatches) == ["m_swamp_12_old"], str(mismatches))
    book.add("m_swamp_12_old quarantined UNVERIFIED",
             all(s["quarantined"] for s in stats if s["dim_mismatch"]),
             "%d quarantined" % sum(s["quarantined"] for s in stats))

    good_minmax = sum(1 for s in stats if s["minmax_match"])
    book.add("grid Min/Max bit-exact 678/680 (F01 §4.9)",
             good_minmax == 678, "%d/680" % good_minmax)

    book.add("five cited line->byte offsets (X05 V3)",
             all(p["byte_offset_ok"] for p in pair_results),
             "%d/5" % sum(p["byte_offset_ok"] for p in pair_results))
    book.add("five cited Min/Max literals (F02/X05)",
             all(p["literal_ok"] for p in pair_results),
             "%d/5" % sum(p["literal_ok"] for p in pair_results))
    book.add("five cited grids match at corrected G (F01)",
             all(p["grid_match"] for p in pair_results),
             "%d/5" % sum(p["grid_match"] for p in pair_results))
    book.add("corrected grid offsets 968/1864/2798 etc (F01/X26 E14)",
             all(p["grid_offset_ok"] for p in pair_results),
             "%d/5" % sum(p["grid_offset_ok"] for p in pair_results))
    hil = lib["sections"].get("hil1", {})
    hil_scale = hil.get("fields", {}).get("HeightFieldScale")
    book.add("hil1 Scale == float32(0.65) (X05 A3)",
             isinstance(hil_scale, (int, float)) and same_f32(hil_scale, 0.65),
             repr(hil_scale))

    # Audited byte closure, printed explicitly with every region.
    for audited in AUDITED_FILES:
        st = next((s for s in stats if Path(s["source"]).name.lower() == audited.lower()), None)
        rec = next((r for r in records if Path(r["source"]).name.lower() == audited.lower()), None)
        ok = bool(st and st["closure"] and rec and rec["byte_closure"]["ok"])
        book.add("byte closure " + audited, ok,
                 ("%s: %d B, N=%d, G=%d" % (
                     audited, st["size"], st["N"], st["grid_offset"])) if st else "missing")

    book.add("flags contract for 680 joined records",
             all(r["flags"] is not None
                 for r in records
                 if r["name"].lower() in lib["sections"]
                 and r["status"] != "UNVERIFIED_QUARANTINE"),
             "nine keys: " + ",".join(FLAG_MAP))
    book.add("null+UNVERIFIED for undecodable regions",
             all(r["collision_records"] is None and r["lattice_weights"] is None
                 for r in records),
             "Tail13 / weights semantics unidentified")
    book.add("visual_parity_claim false everywhere",
             all(r["visual_parity_claim"] is False for r in records),
             "%d documents" % len(records))
    book.add("out not inside donor root",
             not is_within(out, game_root),
             str(out))
    book.add("deterministic pipeline hash present", bool(pipeline_sha),
             pipeline_sha[:16] + "...")
    return book


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="I02: decode donor data/pattern/*.pattern into derived JSON (dry-run default).",
    )
    parser.add_argument("--game", default=str(DEFAULT_GAME),
                        help="read-only donor install root (default: %s)" % DEFAULT_GAME)
    parser.add_argument("--out", default=str(DEFAULT_OUT),
                        help="derived JSON output dir (default: variant3d/assets/terrain_new/patterns/)")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true", default=None,
                      help="print only; default")
    mode.add_argument("--no-dry-run", "--write", dest="dry_run", action="store_false",
                      help="actually write derived JSON")
    parser.add_argument("--check", action="store_true",
                        help="run F01/F02/X05/D05/X12 validation battery; exit non-zero on FAIL")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    dry_run = True if args.dry_run is None else args.dry_run

    game_root = Path(args.game).resolve()
    pat_dir = game_root / PATTERN_SUBDIR
    lib_path = pat_dir / "pattern.lib"

    # Resolve --out relative to the repo root, never the donor root.
    out_arg = Path(args.out)
    out = (out_arg if out_arg.is_absolute() else REPO_ROOT / out_arg).resolve()

    # Licence guard: absolutely no write inside the donor install.
    if is_within(out, game_root):
        print("REFUSED: --out is inside the donor root (%s)" % out, file=sys.stderr)
        return 2
    legacy = (REPO_ROOT / "variant3d" / "assets" / "terrain").resolve()
    if is_within(out, legacy):
        print("REFUSED: --out is inside legacy assets/terrain (%s)" % out, file=sys.stderr)
        return 2
    if not pat_dir.is_dir():
        print("ERROR: donor pattern dir not found: %s" % pat_dir, file=sys.stderr)
        return 2
    if not lib_path.is_file():
        print("ERROR: pattern.lib not found: %s" % lib_path, file=sys.stderr)
        return 2

    lib = load_pattern_lib(lib_path)

    pattern_files = sorted(
        (p for p in pat_dir.glob("*.pattern") if p.is_file()),
        key=lambda p: (p.name.lower(), p.name),
    )
    by_stem = {p.stem.lower(): p for p in pattern_files}

    records: list[dict[str, Any]] = []
    stats: list[dict[str, Any]] = []
    decoded: dict[str, dict[str, Any]] = {}
    hashes: list[str] = []
    hash2: list[str] = []

    for path in pattern_files:
        section = lib["sections"].get(path.stem.lower())
        record, stat = decode_one(path, section)
        data = dumps(record)
        records.append(record)
        stats.append(stat)
        decoded[path.stem.lower()] = record
        hashes.append(sha256(data))
        # Determinism is verified in-process by an independent second decode.
        again, _ = decode_one(path, section)
        hash2.append(sha256(dumps(again)))

        rel_out = out / (path.stem + ".json")
        print("%s:0x00000000 -> %s -> sha256:%s -> %s" % (
            path, rel_out, hashes[-1], record["label"]))

    pipeline_input = "".join(
        Path(r["source"]).name.lower() + "\0" + h
        for r, h in zip(records, hashes)
    ).encode("ascii")
    pipeline_sha = sha256(pipeline_input)

    blend_doc, pair_results = build_blend_vectors(lib, decoded)
    blend_bytes = dumps(blend_doc)
    blend_hash = sha256(blend_bytes)

    manifest = {
        "schema": "terrain_new.pattern_decode_manifest.v1",
        "generator": "variant3d/tools/decode_donor_pattern.py (I02)",
        "donor_root": str(game_root),
        "pattern_dir": str(pat_dir),
        "pattern_lib": str(lib_path),
        "pattern_lib_size": lib["raw_size"],
        "source_file_count": len(pattern_files),
        "output_count": len(records),
        "determinism_second_pass_equal": hashes == hash2,
        "pipeline_sha256": pipeline_sha,
        "blend_vectors_sha256": blend_hash,
        "outputs": [
            {
                "name": r["name"],
                "output": Path(r["source"]).stem + ".json",  # relative to --out (deterministic)
                "sha256": h,
                "source": r["source"],
                "source_sha256": r["source_sha256"],
                "status": r["status"],
                "label": r["label"],
            }
            for r, h in zip(records, hashes)
        ],
        "labels": {
            "source": "[O] donor bytes read only; no donor binary executed or copied",
            "derived": "[D] JSON numbers + labels + sha256 only; no donor bytes embedded",
            "undecodable": "[U] null + UNVERIFIED for Tail13/weight semantics and stale metadata",
            "blend": "[O] D05/X12 bytecode; [D] vectors; no donor frame",
            "parity": "[U] visual_parity_claim=false; no donor GPU A/B frame",
        },
        "visual_parity_claim": False,
    }
    manifest_bytes = dumps(manifest)

    print("PATTERN FILES: %d" % len(pattern_files))
    print("BYTE CLOSURE: %d/%d" % (sum(s["closure"] for s in stats), len(stats)))
    print("PIPELINE_SHA256: %s" % pipeline_sha)
    print("BLEND_VECTORS_SHA256: %s" % blend_hash)
    print("MANIFEST_SHA256: %s" % sha256(manifest_bytes))
    print("DRY_RUN: %s" % ("yes (no files written)" if dry_run else "no (write mode)"))

    book = CheckBook()
    if args.check:
        book = run_checks(game_root, out, pat_dir, lib, stats, records, decoded,
                          pair_results, pipeline_sha)
        book.add("two decode passes byte-identical", hashes == hash2,
                 "%d/%d hashes" % (sum(a == b for a, b in zip(hashes, hash2)), len(hashes)))
        book.report()

        # Explicit F01 byte-closure demonstration for the two audited files.
        for audited in AUDITED_FILES:
            rec = next((r for r in records
                        if Path(r["source"]).name.lower() == audited.lower()), None)
            if rec:
                bc = rec["byte_closure"]
                print("CLOSURE AUDIT %s: %d B = %d B predicted, %d regions, ok=%s" % (
                    audited, bc["actual_bytes"], bc["expected_bytes"],
                    len(bc["regions"]), bc["ok"]))
                for region in bc["regions"]:
                    print("    %-8s offset %8d length %8d" % (
                        region["name"], region["offset"], region["length"]))

    if not dry_run:
        out.mkdir(parents=True, exist_ok=True)
        for record in records:
            (out / (Path(record["source"]).stem + ".json")).write_bytes(dumps(record))
        (out / "blend_test_vectors.json").write_bytes(blend_bytes)
        (out / "pattern_decode_manifest.json").write_bytes(manifest_bytes)
        print("WROTE: %d pattern JSON + 2 indexes -> %s" % (len(records), out))

    if args.check and book.failed:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
