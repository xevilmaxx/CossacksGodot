#!/usr/bin/env python3
"""I03 - production decoder for donor ``pattern.lib`` (DONOR-FIRST swarm 2026-11-26).

F02 established, and X05 independently validated, that ``pattern.lib`` is a
*plaintext* CRLF section database, not a binary container.  This tool decodes
that database read-only and emits derived, labelled JSON into
``variant3d/assets/terrain_new/lib/``.  No donor byte is copied, executed
or committed; donor binaries are never touched.

Labels carried into the outputs:
  OBSERVED            - literal donor bytes (line text, prologue, nested fields)
  DERIVED             - deterministic arithmetic over donor bytes (line->byte, counts)
  PORT APPROXIMATION  - the documented name normaliser for generator.cfg refs
  UNVERIFIED          - undecodable fields (value null) and the one quarantined
                        header mismatch (``m_swamp_12_old``)

``visual_parity_claim`` is False in every emitted document: no donor GPU A/B
frame exists, so no donor visual parity is claimed (CHARTER.md:43-44,125).

OUTPUT OWNERSHIP BOUNDARY (COORD, V44 escalation): this tool emits ONLY ONE
file, ``lib/pattern_lib_index.json``, under ``variant3d/assets/terrain_new/lib/``.
It holds the 680-record plaintext section index, 37-field prologues, nested
Objects/Waters/Decals census, 14 HeightField* key census, line->byte table,
quarantine list and generator.cfg 64-family/493-pair join.  It does NOT emit
the I02-owned family index, per-family metadata or the I02-owned
``terrain_new/patterns`` root, nor any per-``.pattern`` decoded grid,
occupancy mask, binary float plane or object tail.  Only pattern.lib /
generator.cfg plaintext metadata and the 8-byte W/H header equality check
appear here.

CLI:
  python variant3d/tools/decode_pattern_lib.py --dry-run --check
  python variant3d/tools/decode_pattern_lib.py --write --check --out <dir>

Dry-run is the default and prints, for every output,
``source -> output -> sha256 -> labels``.  ``--out`` inside the donor root is
refused.  Two runs produce byte-identical output (stable sort, no timestamps).
"""

import argparse
import collections
import hashlib
import json
import os
import re
import struct
import sys

DEFAULT_GAME = r"C:\Games\Cossacks 3"
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT_OUT = os.path.join(REPO_ROOT, "variant3d", "assets", "terrain_new", "lib")

LIB_REL = os.path.join("data", "pattern", "pattern.lib")
PAT_DIR_REL = os.path.join("data", "pattern")
GEN_REL = os.path.join("data", "game", "var", "generator.cfg")

LABEL_OBSERVED = "OBSERVED"
LABEL_DERIVED = "DERIVED"
LABEL_APPROX = "PORT APPROXIMATION"
LABEL_UNVERIFIED = "UNVERIFIED"

SCHEMA = "terrain_new/pattern_lib/v1"
EXPECTED_FILE_SIZE = 30309138
EXPECTED_LINES = 1172417
EXPECTED_CRLF = 1172416
EXPECTED_SECTIONS = 680
EXPECTED_PATTERN_FILES = 710
EXPECTED_OBJECT_RECORDS = 39780
EXPECTED_DISTINCT_BASENAMES = 235
EXPECTED_FAMILIES = 64
EXPECTED_PAIRS = 493
EXPECTED_BYTES = 30309138

# F02 §5.1 / X05 V1: the ordered 37-field prologue, lines +1..+37 from
# section.begin.  Any donor update that changes this tuple must fail loudly.
EXPECTED_PROLOGUE_KEYS = [
    "Name", "Width", "Height", "TilesStand", "GameObjectsStand",
    "DecalsStand", "HeightFieldStand", "HeightFieldReplace",
    "HeightFieldReplaceForWater", "HeightFieldUseRndScale",
    "HeightFieldMinScale", "HeightFieldMaxScale", "HeightFieldScale",
    "TerrainScale", "ObjectsScale", "RotationAngle", "HeightFieldSmooth",
    "HeightFieldSmoothRadius", "HeightFieldSmoothFactor",
    "HeightFieldSmoothOffset", "PatternMaskStand", "PatternMaskReverceStand",
    "CollisionStand", "OffsetX", "OffsetZ", "ObjectsOffset",
    "ObjectsHeightOffset", "IgnoreMatrix", "ObjAutoOffset",
    "HeightFieldMin", "HeightFieldMax", "HeightFieldOffset", "NativeSeason",
    "Summer", "Autumn", "Winter", "Spring",
]

FLOAT_KEYS = {"HeightFieldScale", "HeightFieldMin", "HeightFieldMax"}
INT_KEYS = {
    "Width", "Height", "HeightFieldMinScale", "HeightFieldMaxScale",
    "TerrainScale", "ObjectsScale", "RotationAngle", "HeightFieldSmoothRadius",
    "HeightFieldSmoothFactor", "HeightFieldSmoothOffset", "OffsetX", "OffsetZ",
    "HeightFieldOffset",
}

# X05 V5: exactly 14 HeightField* keys.  TerrainScale is reported separately
# because it is not a HeightField* key, but D05 binds it into the Smooth path.
HF_KEYS = sorted(
    key for key in EXPECTED_PROLOGUE_KEYS if key.startswith("HeightField")
)

# F02 §5.2 / X05 V3: five prior "byte offsets" are 1-based line numbers.
# (min line, max line, section, expected byte of min, expected byte of max)
CITED_LINE_PAIRS = [
    (6805, 6806, "plt2", 173669, 173710),
    (33111, 33112, "hil1", 854933, 854956),
    (366499, 366500, "g_hil4", 9458861, 9458904),
    (549585, 549586, "k_ravine_1", 14196248, 14196285),
    (730045, 730046, "k_ravine_big_stone_1", 18877479, 18877518),
]

# F02/X05 corpus citations, resolved as 1-based LINE numbers.  ``needle`` is a
# literal substring of the cited line (verified against the donor, not assumed).
OTHER_CITATIONS = [
    (328, "plt1 HeightFieldStand", "HeightFieldStand"),
    (351, "plt1 HeightFieldMin", "HeightFieldMin"),
    (352, "plt1 HeightFieldMax", "HeightFieldMax"),
    (338482, "g_mnt_1 mountain prop", "BaseName = terrainmesh4"),
    (542627, "k_ravine_big_1 HeightFieldMin", "HeightFieldMin"),
    (542628, "k_ravine_big_1 HeightFieldMax", "HeightFieldMax"),
    (583073, "k_ravine_7 HeightFieldMin", "HeightFieldMin"),
    (583074, "k_ravine_7 HeightFieldMax", "HeightFieldMax"),
    (713410, "mng minegold object", "BaseName = minegold"),
    (715244, "mni mineiron object", "BaseName = mineiron"),
    (716910, "mnc minecoal object", "BaseName = minecoal"),
    (1168944, "winter mineiron object", "BaseName = mineirons"),
    (1170134, "winter minegold object", "BaseName = minegolds"),
    (1171156, "winter minecoal object", "BaseName = minecoals"),
    (905523, "m_swamp_12_old section.begin", "section.begin"),
    (555365, "k_ravine_2 section.begin", "section.begin"),
    (359, "first Objects block", "Objects : struct.begin"),
    (638257, "first Waters block", "Waters : struct.begin"),
]

OBJECT_FIELDS = ("RaceName", "BaseName")
OBJECT_STRUCTS = ("Position", "Direction", "Up", "Scaling")
VECTOR4 = ("X", "Y", "Z", "W")


# --------------------------------------------------------------------------
# small deterministic helpers
# --------------------------------------------------------------------------


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

def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest()


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def is_inside(path, root):
    """True if ``path`` equals ``root`` or lies beneath it (case-insensitive)."""
    p = os.path.normcase(os.path.realpath(os.path.abspath(path)))
    r = os.path.normcase(os.path.realpath(os.path.abspath(root)))
    return p == r or p.startswith(r.rstrip(os.sep) + os.sep)


def json_bytes(doc):
    """Canonical bytes: sorted keys, fixed indent, LF only, trailing newline."""
    text = json.dumps(_scrub_donor_paths(doc), sort_keys=True, indent=2, ensure_ascii=True)
    return (text + "\n").encode("utf-8")


def envelope(source, source_sha256, labels):
    """Every emitted document carries provenance and an explicit parity flag."""
    return {
        "schema": SCHEMA,
        "visual_parity_claim": False,
        "labels": sorted(set(labels)),
        "source": source,
        "source_sha256": source_sha256,
    }


def parse_scalar(key, literal):
    """Decode a donor literal; return (value, label).  Never guess."""
    if literal == "True":
        return True, LABEL_OBSERVED
    if literal == "False":
        return False, LABEL_OBSERVED
    if key in FLOAT_KEYS:
        try:
            return float(literal), LABEL_OBSERVED
        except ValueError:
            return None, LABEL_UNVERIFIED
    if key in INT_KEYS or re.match(r"^-?\d+$", literal):
        try:
            return int(literal), LABEL_OBSERVED
        except ValueError:
            return None, LABEL_UNVERIFIED
    try:
        return float(literal), LABEL_OBSERVED
    except ValueError:
        # A plaintext string literal (Name, RaceName, BaseName, NativeSeason,
        # ...) is decodable as-is; preserve it verbatim, never invent a number.
        return literal, LABEL_OBSERVED


def normalise_name(name):
    """F02 §5.3 normaliser: lowercase, delete '_', strip leading zeros in runs."""
    return re.sub(r"(?<![0-9])0+(?=[0-9])", "", name.lower().replace("_", ""))


# --------------------------------------------------------------------------
# line table + plaintext section parser
# --------------------------------------------------------------------------

class LineTable(object):
    """Raw CRLF bytes with a 1-based line -> byte-start table."""

    def __init__(self, path):
        with open(path, "rb") as fh:
            self.raw = fh.read()
        self.lines = self.raw.split(b"\r\n")
        self.starts = [0] * (len(self.lines) + 1)
        pos = 0
        for i, line in enumerate(self.lines):
            self.starts[i + 1] = pos
            pos += len(line) + 2
        self.end_pos = pos

    def text(self, number):
        return self.lines[number - 1].decode("latin-1")

    def byte(self, number):
        """Byte offset of the start of 1-based line ``number``."""
        return self.starts[number]

    def byte_end(self, number):
        return self.starts[number] + len(self.lines[number - 1]) + 2

    def crlf_audit(self):
        return {
            "bytes": len(self.raw),
            "split_lines": len(self.lines),
            "crlf_pairs": self.raw.count(b"\r\n"),
            "bare_lf": sum(1 for b in self.raw if b == 10) - self.raw.count(b"\r\n"),
            "bare_cr": sum(1 for b in self.raw if b == 13) - self.raw.count(b"\r\n"),
        }


def _new_frame(label, indent, line, kind, parent):
    return {
        "label": label,
        "indent": indent,
        "line": line,
        "kind": kind,
        "style": "nested",
        "parent": parent,
        "fields": {},
        "children": {},
        "records": [],
    }


def parse_blocks(table, line_begin, line_end):
    """Indentation-aware parse of nested struct blocks inside one section."""
    stack = []
    blocks = []
    issues = []
    for n in range(line_begin + 1, line_end):
        raw = table.lines[n - 1]
        if not raw.strip():
            continue
        indent = len(raw) - len(raw.lstrip(b" "))
        text = raw.strip().decode("latin-1")
        if text == "struct.end":
            if not stack:
                issues.append({"line": n, "reason": "unmatched struct.end",
                               "label": LABEL_UNVERIFIED})
                continue
            frame = stack.pop()
            parent = frame["parent"]
            if parent is None:
                blocks.append(frame)
            elif frame["kind"] == "record":
                parent["records"].append(frame)
            else:
                parent["children"].setdefault(frame["label"], []).append(frame)
            continue
        if text.endswith(": struct.begin"):
            label = text[:-len(": struct.begin")].strip()
            inline = label.endswith("[*]") and label != "[*]"
            if inline:
                label = label[:-3].strip()
            kind = "record" if label == "[*]" or inline else "block"
            if label == "[*]":
                label = "record"
            frame = _new_frame(label, indent, n, kind, stack[-1] if stack else None)
            if inline:
                frame["style"] = "inline"
            stack.append(frame)
            continue
        if " = " in text:
            key, literal = text.split(" = ", 1)
            if not stack:
                issues.append({"line": n, "reason": "field outside struct",
                               "label": LABEL_UNVERIFIED})
                continue
            stack[-1]["fields"][key] = {"literal": literal, "line": n}
            continue
        issues.append({"line": n, "reason": "unparsed line", "text": text,
                       "label": LABEL_UNVERIFIED})
    while stack:
        frame = stack.pop()
        issues.append({"line": frame["line"], "reason": "unclosed struct",
                       "struct": frame["label"], "label": LABEL_UNVERIFIED})
    return blocks, issues


def frame_to_record(frame):
    rec = {"line": frame["line"], "style": frame["style"]}
    for key, item in frame["fields"].items():
        value, label = parse_scalar(key, item["literal"])
        rec[key] = {"literal": item["literal"], "value": value,
                    "line": item["line"], "label": label}
    for label, children in frame["children"].items():
        if children:
            rec[label] = {
                key: parse_scalar(key, item["literal"])[0]
                for key, item in children[0]["fields"].items()
            }
    return rec


def blocks_to_json(blocks):
    result = []
    for block in blocks:
        if block["kind"] == "record":
            records = [frame_to_record(block)]
        else:
            records = [frame_to_record(r) for r in block["records"]]
        result.append({
            "block": block["label"],
            "line": block["line"],
            "style": block["style"],
            "records": records,
        })
    return result


def parse_sections(table):
    """Split column-0 section.begin/section.end pairs and decode every section."""
    begins = [n for n, line in enumerate(table.lines, 1) if line == b"section.begin"]
    ends = [n for n, line in enumerate(table.lines, 1) if line == b"section.end"]
    sections = []
    order_issues = []
    for idx, (a, b) in enumerate(zip(begins, ends)):
        if b <= a:
            order_issues.append({"begin": a, "end": b, "label": LABEL_UNVERIFIED})
            continue
        prologue = []
        key_order = []
        for n in range(a + 1, b):
            line = table.lines[n - 1]
            if not (line.startswith(b"   ") and not line.startswith(b"    ")):
                continue
            text = line.strip().decode("latin-1")
            if " = " not in text:
                continue
            key, literal = text.split(" = ", 1)
            if key not in EXPECTED_PROLOGUE_KEYS:
                continue
            value, label = parse_scalar(key, literal)
            prologue.append({"key": key, "literal": literal, "line": n,
                             "value": value, "label": label})
            key_order.append(key)
        # fixed 37-field prologue: first 37 recognised keys in order, nothing else
        prologue = prologue[:37]
        key_order = key_order[:37]
        fields = {}
        for item in prologue:
            fields[item["key"]] = {k: item[k] for k in ("literal", "line", "value", "label")}
        blocks, issues = parse_blocks(table, a, b)
        sections.append({
            "index": idx,
            "name": fields.get("Name", {}).get("literal"),
            "line_start": a,
            "line_end": b,
            "byte_start": table.byte(a),
            "byte_end": table.byte_end(b),
            "size_bytes": table.byte_end(b) - table.byte(a),
            "key_order": key_order,
            "fields": fields,
            "blocks": blocks_to_json(blocks),
            "block_issues": issues,
        })
    return sections, begins, ends, order_issues


# --------------------------------------------------------------------------
# donor file inventory + generator.cfg families
# --------------------------------------------------------------------------

def pattern_inventory(game, sections):
    pat_dir = os.path.join(game, PAT_DIR_REL)
    files = sorted(fn for fn in os.listdir(pat_dir)
                   if fn.lower().endswith(".pattern"))
    by_stem = {}
    for fn in files:
        by_stem.setdefault(fn[:-8].lower(), []).append(fn)
    joined = {}
    for section in sections:
        name = section["name"] or ""
        candidates = by_stem.get(name.lower(), [])
        if not candidates:
            section["pattern_file"] = None
            section["pattern_case_only"] = None
            section["pattern_w"] = None
            section["pattern_h"] = None
            section["pattern_size"] = None
            section["header_status"] = LABEL_UNVERIFIED
            section["header_label"] = LABEL_UNVERIFIED
            continue
        filename = candidates[0]
        section["pattern_file"] = filename
        section["pattern_case_only"] = (filename[:-8] != name)
        path = os.path.join(pat_dir, filename)
        with open(path, "rb") as fh:
            header = fh.read(8)
        w, h = struct.unpack("<ii", header) if len(header) == 8 else (None, None)
        section["pattern_w"] = w
        section["pattern_h"] = h
        section["pattern_size"] = os.path.getsize(path)
        match = (w == section["fields"].get("Width", {}).get("value")
                 and h == section["fields"].get("Height", {}).get("value"))
        if match:
            section["header_status"] = "MATCH"
            section["header_label"] = LABEL_OBSERVED
        else:
            section["header_status"] = LABEL_UNVERIFIED
            section["header_label"] = LABEL_UNVERIFIED
        joined[name] = filename
    return files, by_stem, joined


def parse_generator(path):
    """The 64 ordered (family, cfg_line, [(pattern, freq, cfg_line)]) groups."""
    with open(path, "rb") as fh:
        lines = fh.read().split(b"\r\n")
    families = []
    current = None
    for n, raw in enumerate(lines, 1):
        indent = len(raw) - len(raw.lstrip(b" "))
        if not raw.strip():
            continue
        text = raw.strip().decode("latin-1")
        if indent == 9 and text.startswith("Name = "):
            current = {"name": text[len("Name = "):], "line": n, "pairs": []}
            families.append(current)
        elif indent == 15 and text.startswith("Pattern = "):
            if current is not None:
                current["pairs"].append({"pattern": text[len("Pattern = "):],
                                         "freq_literal": None, "line": n})
        elif indent == 15 and text.startswith("Freq = "):
            if current is not None and current["pairs"]:
                current["pairs"][-1]["freq_literal"] = text[len("Freq = "):]
    for family in families:
        for pair in family["pairs"]:
            literal = pair["freq_literal"]
            try:
                pair["freq"] = float(literal) if literal is not None else None
            except (TypeError, ValueError):
                pair["freq"] = None
                pair["label"] = LABEL_UNVERIFIED
            else:
                pair["label"] = LABEL_OBSERVED
    return families


def join_families(families, sections):
    by_exact = {}
    by_lower = {}
    by_norm = collections.defaultdict(list)
    for section in sections:
        name = section["name"] or ""
        by_exact.setdefault(name, []).append(section)
        by_lower.setdefault(name.lower(), []).append(section)
        by_norm[normalise_name(name)].append(section)
    summary = collections.Counter()
    for family in families:
        for pair in family["pairs"]:
            name = pair["pattern"]
            if name in by_exact:
                pair["join"] = "exact"
                pair["sections"] = [s["name"] for s in by_exact[name]]
                pair["join_label"] = LABEL_OBSERVED
                summary["exact"] += 1
            elif name.lower() in by_lower:
                pair["join"] = "case_insensitive"
                pair["sections"] = [s["name"] for s in by_lower[name.lower()]]
                pair["join_label"] = LABEL_OBSERVED
                summary["case_insensitive"] += 1
            elif normalise_name(name) in by_norm:
                pair["join"] = "normalized"
                pair["sections"] = sorted(s["name"] for s in by_norm[normalise_name(name)])
                pair["join_label"] = LABEL_APPROX
                summary["normalized"] += 1
                if len(pair["sections"]) > 1:
                    pair["join_label"] = LABEL_UNVERIFIED
                    summary["normalized_ambiguous"] += 1
            else:
                pair["join"] = "unresolved"
                pair["sections"] = []
                pair["join_label"] = LABEL_UNVERIFIED
                summary["unresolved"] += 1
    return dict(summary)


# --------------------------------------------------------------------------
# derived documents
# --------------------------------------------------------------------------

def source_string(game, lib_path, gen_path, sections):
    first = sections[0]["line_start"] if sections else 1
    last = sections[-1]["line_end"] if sections else 1
    return ("%s:L%d-L%d + %s:L67-L2367" %
            (LIB_REL, first, last, GEN_REL))


def source_hashes(game, sections, families):
    pat_dir = os.path.join(game, PAT_DIR_REL)
    hashes = {LIB_REL: sha256_file(os.path.join(game, LIB_REL)),
              GEN_REL: sha256_file(os.path.join(game, GEN_REL))}
    for filename in sorted({s["pattern_file"] for s in sections if s["pattern_file"]}):
        hashes["%s/%s" % (PAT_DIR_REL, filename)] = sha256_file(
            os.path.join(pat_dir, filename))
    return hashes


def build_index_doc(ctx):
    doc = envelope(ctx["source"], ctx["source_sha256"],
                   [LABEL_OBSERVED, LABEL_DERIVED, LABEL_UNVERIFIED])
    doc.update({
        "description": "680 plaintext pattern.lib records; section.begin/section.end authoritative",
        "section_count": len(ctx["sections"]),
        "expected_section_count": EXPECTED_SECTIONS,
        "sections": [],
        "quarantine": [],
    })
    for section in ctx["sections"]:
        record = {k: section[k] for k in (
            "index", "name", "line_start", "line_end", "byte_start",
            "byte_end", "size_bytes", "pattern_file", "pattern_case_only",
            "pattern_w", "pattern_h", "pattern_size", "header_status",
            "header_label")}
        record["fields"] = section["fields"]
        record["blocks"] = section["blocks"]
        record["unverified_fields"] = {
            "relief_float_grid": None,
            "float_plane_start_byte": None,
            "object_tail_binary_mapping": None,
            "engine_row_sign": None,
            "label": LABEL_UNVERIFIED,
        }
        record["labels"] = sorted({LABEL_OBSERVED, LABEL_DERIVED} |
                                  ({LABEL_UNVERIFIED}
                                   if section["header_status"] == LABEL_UNVERIFIED
                                   else set()))
        doc["sections"].append(record)
        if section["header_status"] == LABEL_UNVERIFIED:
            doc["quarantine"].append({
                "name": section["name"],
                "line": section["line_start"],
                "lib_width": section["fields"].get("Width", {}).get("value"),
                "lib_height": section["fields"].get("Height", {}).get("value"),
                "binary_width": section["pattern_w"],
                "binary_height": section["pattern_h"],
                "policy": "quarantined as UNVERIFIED; not silently repaired",
                "label": LABEL_UNVERIFIED,
            })
    doc["sections"].sort(key=lambda r: (r["line_start"], r["name"]))
    doc["quarantine"].sort(key=lambda r: r["name"])
    return doc


def build_offset_doc(ctx):
    table = ctx["table"]
    doc = envelope(ctx["source"], {LIB_REL: ctx["source_sha256"][LIB_REL]},
                   [LABEL_OBSERVED, LABEL_DERIVED])
    doc.update({
        "description": "Every pattern.lib:N prior citation is a 1-based LINE number, not a byte offset",
        "conversion": "byte_start(N) = sum(len(line_i)+2 for i in 1..N-1), CRLF, 0-based bytes",
        "cited_pairs": [],
        "other_citations": [],
    })
    for line_min, line_max, name, expected_min, expected_max in CITED_LINE_PAIRS:
        text_min = table.text(line_min)
        text_max = table.text(line_max)
        byte_min = table.byte(line_min)
        byte_max = table.byte(line_max)
        doc["cited_pairs"].append({
            "citation": "pattern.lib:%d-%d" % (line_min, line_max),
            "section": name,
            "line_min": line_min,
            "line_max": line_max,
            "line_min_text": text_min,
            "line_max_text": text_max,
            "byte_min": byte_min,
            "byte_max": byte_max,
            "expected_byte_min": expected_min,
            "expected_byte_max": expected_max,
            "fields_are_min_max": (text_min.strip().startswith("HeightFieldMin = ")
                                   and text_max.strip().startswith("HeightFieldMax = ")),
            "bytes_exact": (byte_min == expected_min and byte_max == expected_max),
            "label": LABEL_DERIVED,
        })
    for line, description, needle in OTHER_CITATIONS:
        text = table.text(line)
        doc["other_citations"].append({
            "citation": "pattern.lib:%d" % line,
            "description": description,
            "line": line,
            "byte": table.byte(line),
            "line_text": text,
            "needle_present": needle in text,
            "label": LABEL_DERIVED,
        })
    doc["cited_pairs"].sort(key=lambda r: r["line_min"])
    doc["other_citations"].sort(key=lambda r: r["line"])
    doc["summary"] = {
        "cited_pairs_checked": len(CITED_LINE_PAIRS),
        "cited_pairs_fields_ok": sum(1 for r in doc["cited_pairs"]
                                     if r["fields_are_min_max"]),
        "cited_pairs_bytes_exact": sum(1 for r in doc["cited_pairs"]
                                       if r["bytes_exact"]),
        "other_citations_resolved": len(doc["other_citations"]),
    }
    return doc


def value_census(sections, key):
    owners = collections.defaultdict(list)
    for section in sections:
        item = section["fields"].get(key)
        if item is None:
            continue
        owners[item["literal"]].append(section["name"])
    buckets = {}
    for literal in sorted(owners):
        value, label = parse_scalar(key, literal)
        buckets[literal] = {
            "value": value,
            "count": len(owners[literal]),
            "owners": sorted(owners[literal]),
            "label": label,
        }
    return {
        "present": sum(len(v) for v in owners.values()),
        "distinct_values": len(buckets),
        "value_counts": {literal: buckets[literal]["count"] for literal in sorted(buckets)},
        "owners_by_value": buckets,
    }


def build_census_doc(ctx):
    doc = envelope(ctx["source"], {LIB_REL: ctx["source_sha256"][LIB_REL]},
                   [LABEL_OBSERVED, LABEL_DERIVED])
    doc.update({
        "description": "X05 census: all 14 HeightField* keys with literal -> owner lists",
        "key_count": len(HF_KEYS),
        "keys": {key: value_census(ctx["sections"], key) for key in HF_KEYS},
        "related_not_heightfield": {
            "TerrainScale": value_census(ctx["sections"], "TerrainScale"),
        },
        "blend_flags": {
            "HeightFieldReplace": value_census(ctx["sections"], "HeightFieldReplace"),
            "HeightFieldReplaceForWater": value_census(
                ctx["sections"], "HeightFieldReplaceForWater"),
            "HeightFieldSmooth": value_census(ctx["sections"], "HeightFieldSmooth"),
            "HeightFieldOffset": value_census(ctx["sections"], "HeightFieldOffset"),
            "HeightFieldScale": value_census(ctx["sections"], "HeightFieldScale"),
        },
        "engine_side_consumption": {
            "value": None,
            "label": LABEL_UNVERIFIED,
            "note": "D05 decoded native blend math statically; no donor GPU A/B frame exists",
        },
    })
    return doc


def build_object_doc(ctx):
    doc = envelope(ctx["source"], {LIB_REL: ctx["source_sha256"][LIB_REL]},
                   [LABEL_OBSERVED, LABEL_DERIVED, LABEL_UNVERIFIED])
    counts = collections.Counter()
    basenames = collections.Counter()
    mine_owners = collections.defaultdict(list)
    for section in ctx["sections"]:
        for block in section["blocks"]:
            if block["block"] != "Objects":
                continue
            for record in block["records"]:
                counts[record["style"]] += 1
                basename = record.get("BaseName", {}).get("value")
                if basename is not None:
                    basenames[basename] += 1
                name = (section["name"] or "").lower()
                if name.startswith(("mng", "mni", "mnc")) and basename:
                    mine_owners[basename].append(section["name"])
    doc.update({
        "description": "Nested Objects/Waters/Decals records decoded from pattern.lib",
        "object_records_nested": counts["nested"],
        "object_records_inline": counts["inline"],
        "object_records_total": sum(counts.values()),
        "distinct_base_names": len(basenames),
        "base_name_counts": {name: basenames[name] for name in sorted(basenames)},
        "waters_blocks": sum(1 for s in ctx["sections"]
                             for b in s["blocks"] if b["block"] == "Waters"),
        "decals_blocks": sum(1 for s in ctx["sections"]
                             for b in s["blocks"] if b["block"] == "Decals"),
        "mine_embedding_owners": {name: sorted(set(mine_owners[name]))
                                  for name in sorted(mine_owners)},
        "unverified_fields": {
            "binary_tail_record_relationship": None,
            "label": LABEL_UNVERIFIED,
        },
    })
    return doc


def pair_doc(pair, section_by_name):
    doc = {
        "pattern": pair["pattern"],
        "cfg_line": pair["line"],
        "freq": pair["freq"],
        "freq_literal": pair["freq_literal"],
        "join": pair["join"],
        "match": pair["sections"][0] if pair["sections"] else None,
        "candidates": pair["sections"],
        "labels": sorted({pair["label"], pair["join_label"]}),
    }
    if doc["match"] in section_by_name:
        section = section_by_name[doc["match"]]
        doc["source_line_start"] = section["line_start"]
        doc["source_line_end"] = section["line_end"]
        doc["source_byte_start"] = section["byte_start"]
        doc["source_byte_end"] = section["byte_end"]
        doc["width"] = section["fields"].get("Width", {}).get("value")
        doc["height"] = section["fields"].get("Height", {}).get("value")
        doc["header_status"] = section["header_status"]
    else:
        doc["source_line_start"] = None
        doc["source_line_end"] = None
        doc["source_byte_start"] = None
        doc["source_byte_end"] = None
        doc["width"] = None
        doc["height"] = None
        doc["header_status"] = None
        doc["labels"] = sorted(set(doc["labels"]) | {LABEL_UNVERIFIED})
    return doc


def build_lib_index_doc(ctx):
    """Build the single owned output: lib/pattern_lib_index.json.

    Contains all plaintext pattern.lib metadata and the generator.cfg family
    table.  I02 exclusively owns decoded per-``.pattern`` products; none are
    emitted or referenced as outputs here.
    """
    families = ctx["families"]
    section_by_name = {s["name"]: s for s in ctx["sections"] if s["name"]}
    family_groups = []
    for family in families:
        family_groups.append({
            "family": family["name"],
            "cfg_line": family["line"],
            "pattern_count": len(family["pairs"]),
            "patterns": [pair_doc(p, section_by_name) for p in family["pairs"]],
        })
    family_groups.sort(key=lambda g: (g["cfg_line"], g["family"]))

    index = envelope(ctx["source"], ctx["source_sha256"],
                     [LABEL_OBSERVED, LABEL_DERIVED, LABEL_APPROX,
                      LABEL_UNVERIFIED])
    index.update({
        "description": (
            "generator.cfg 64 families / 493 Pattern+Freq pairs plus the "
            "680-record plaintext pattern.lib index; metadata only, no "
            "per-.pattern binary decode (I02 owns grids/occupancy/tails)"),
        "family_count": len(families),
        "pair_count": sum(len(f["pairs"]) for f in families),
        "join_summary": ctx["join_summary"],
        "pattern_lib": {
            "section_count": ctx["index_doc"]["section_count"],
            "expected_section_count": ctx["index_doc"]["expected_section_count"],
            "sections": ctx["index_doc"]["sections"],
            "quarantine": ctx["index_doc"]["quarantine"],
            "prologue_key_order": EXPECTED_PROLOGUE_KEYS,
        },
        "line_byte_offsets": {
            k: ctx["offset_doc"][k] for k in
            ("description", "conversion", "cited_pairs", "other_citations", "summary")
        },
        "heightfield_census": {
            "key_count": ctx["census_doc"]["key_count"],
            "keys": ctx["census_doc"]["keys"],
            "related_not_heightfield": ctx["census_doc"]["related_not_heightfield"],
            "blend_flags": ctx["census_doc"]["blend_flags"],
            "engine_side_consumption": ctx["census_doc"]["engine_side_consumption"],
        },
        "object_census": {
            k: ctx["object_doc"][k] for k in
            ("description", "object_records_nested", "object_records_inline",
             "object_records_total", "distinct_base_names", "base_name_counts",
             "waters_blocks", "decals_blocks", "mine_embedding_owners",
             "unverified_fields")
        },
        "generator_families": family_groups,
        "unverified_fields": {
            "relief_float_grid": None,
            "binary_object_tail": None,
            "visual_parity": None,
            "label": LABEL_UNVERIFIED,
        },
    })
    return index


# --------------------------------------------------------------------------
# checks
# --------------------------------------------------------------------------

def run_checks(ctx, docs, docs2):
    checks = []

    def add(name, condition, observed, expected=None):
        checks.append({
            "name": name,
            "status": "PASS" if condition else "FAIL",
            "observed": observed,
            "expected": expected,
            "labels": [LABEL_DERIVED],
        })

    table = ctx["table"]
    sections = ctx["sections"]
    audit = table.crlf_audit()
    add("lib_size", audit["bytes"] == EXPECTED_FILE_SIZE,
        audit["bytes"], EXPECTED_FILE_SIZE)
    add("line_count", audit["split_lines"] == EXPECTED_LINES,
        audit["split_lines"], EXPECTED_LINES)
    add("crlf_pairs", audit["crlf_pairs"] == EXPECTED_CRLF,
        audit["crlf_pairs"], EXPECTED_CRLF)
    add("no_bare_eol", audit["bare_lf"] == 0 and audit["bare_cr"] == 0,
        {"bare_lf": audit["bare_lf"], "bare_cr": audit["bare_cr"]}, {"both": 0})
    add("section_begin_count", len(ctx["begins"]) == EXPECTED_SECTIONS,
        len(ctx["begins"]), EXPECTED_SECTIONS)
    add("section_end_count", len(ctx["ends"]) == EXPECTED_SECTIONS,
        len(ctx["ends"]), EXPECTED_SECTIONS)
    add("records_paired", len(sections) == EXPECTED_SECTIONS,
        len(sections), EXPECTED_SECTIONS)
    add("section_order", not ctx["order_issues"], len(ctx["order_issues"]), 0)
    prologue_ok = sum(1 for s in sections
                      if s["key_order"] == EXPECTED_PROLOGUE_KEYS)
    add("prologue_37_fields_identical", prologue_ok == EXPECTED_SECTIONS,
        prologue_ok, EXPECTED_SECTIONS)
    add("prologue_key_order_matches_F02", prologue_ok == EXPECTED_SECTIONS,
        prologue_ok, EXPECTED_SECTIONS)
    span_sum = sum(s["size_bytes"] for s in sections)
    gaps = sum(sections[i + 1]["byte_start"] - sections[i]["byte_end"]
               for i in range(len(sections) - 1))
    trailing = len(table.raw) - sections[-1]["byte_end"]
    closure = span_sum + gaps + trailing
    add("byte_closure", closure == EXPECTED_BYTES,
        {"sections": span_sum, "gaps": gaps, "trailing": trailing,
         "total": closure}, EXPECTED_BYTES)
    add("gap_count_679x2", len(sections) - 1 == 679 and gaps == 1358,
        {"gaps": len(sections) - 1, "gap_bytes": gaps}, {"gaps": 679, "gap_bytes": 1358})
    joins = sum(1 for s in sections if s["pattern_file"])
    add("name_to_pattern_file", joins == EXPECTED_SECTIONS, joins, EXPECTED_SECTIONS)
    add("pattern_files_present", len(ctx["pattern_files"]) == EXPECTED_PATTERN_FILES,
        len(ctx["pattern_files"]), EXPECTED_PATTERN_FILES)
    add("orphan_pattern_files",
        len(ctx["pattern_files"]) - joins == 30,
        len(ctx["pattern_files"]) - joins, 30)
    header_ok = sum(1 for s in sections if s["header_status"] == "MATCH")
    add("binary_header_match", header_ok == 679, header_ok, 679)
    quarantined = [s["name"] for s in sections
                   if s["header_status"] == LABEL_UNVERIFIED]
    anomaly = ctx["index_doc"]["quarantine"]
    add("header_quarantine",
        quarantined == ["m_swamp_12_old"] and len(anomaly) == 1
        and anomaly[0]["lib_width"] == 17 and anomaly[0]["lib_height"] == 20
        and anomaly[0]["binary_width"] == 18 and anomaly[0]["binary_height"] == 23,
        quarantined, ["m_swamp_12_old"])
    pairs = ctx["offset_doc"]["cited_pairs"]
    add("cited_pairs_fields",
        sum(1 for p in pairs if p["fields_are_min_max"]) == 5,
        sum(1 for p in pairs if p["fields_are_min_max"]), 5)
    add("cited_pairs_byte_exact",
        sum(1 for p in pairs if p["bytes_exact"]) == 5,
        sum(1 for p in pairs if p["bytes_exact"]), 5)
    add("other_citations_needles",
        all(c["needle_present"] for c in ctx["offset_doc"]["other_citations"]),
        sum(1 for c in ctx["offset_doc"]["other_citations"] if c["needle_present"]),
        len(ctx["offset_doc"]["other_citations"]))
    add("heightfield_key_count", len(HF_KEYS) == 14, len(HF_KEYS), 14)
    add("heightfield_census_keys",
        len(ctx["census_doc"]["keys"]) == 14,
        len(ctx["census_doc"]["keys"]), 14)
    census = ctx["census_doc"]
    add("replace_false_680",
        census["blend_flags"]["HeightFieldReplace"]["value_counts"] == {"False": 680},
        census["blend_flags"]["HeightFieldReplace"]["value_counts"], {"False": 680})
    add("replace_for_water_true_85",
        census["blend_flags"]["HeightFieldReplaceForWater"]["value_counts"].get("True") == 85,
        census["blend_flags"]["HeightFieldReplaceForWater"]["value_counts"], None)
    add("smooth_true_41",
        census["blend_flags"]["HeightFieldSmooth"]["value_counts"].get("True") == 41,
        census["blend_flags"]["HeightFieldSmooth"]["value_counts"], None)
    add("stand_true_582",
        census["keys"]["HeightFieldStand"]["value_counts"] == {"True": 582, "False": 98},
        census["keys"]["HeightFieldStand"]["value_counts"],
        {"True": 582, "False": 98})
    scale_counts = census["keys"]["HeightFieldScale"]["value_counts"]
    add("scale_nonunity_11_includes_065",
        sum(v for k, v in scale_counts.items() if k != "1") == 11
        and scale_counts.get("0.649999976158142") == 1,
        scale_counts, {"nonunity": 11, "0.649999976158142": 1})
    add("smooth_radius_distribution",
        census["keys"]["HeightFieldSmoothRadius"]["value_counts"] ==
        {"2": 427, "3": 248, "1": 5},
        census["keys"]["HeightFieldSmoothRadius"]["value_counts"],
        {"2": 427, "3": 248, "1": 5})
    add("smooth_offset_distribution",
        census["keys"]["HeightFieldSmoothOffset"]["value_counts"] ==
        {"0": 435, "2": 240, "1": 5},
        census["keys"]["HeightFieldSmoothOffset"]["value_counts"],
        {"0": 435, "2": 240, "1": 5})
    add("min_max_present_680",
        census["keys"]["HeightFieldMin"]["present"] == 680
        and census["keys"]["HeightFieldMax"]["present"] == 680,
        {"min": census["keys"]["HeightFieldMin"]["present"],
         "max": census["keys"]["HeightFieldMax"]["present"]}, 680)
    obj = ctx["object_doc"]
    add("object_records_39780_nested",
        obj["object_records_nested"] == EXPECTED_OBJECT_RECORDS,
        obj["object_records_nested"], EXPECTED_OBJECT_RECORDS)
    add("object_records_inline_3", obj["object_records_inline"] == 3,
        obj["object_records_inline"], 3)
    add("distinct_base_names_235",
        obj["distinct_base_names"] == EXPECTED_DISTINCT_BASENAMES,
        obj["distinct_base_names"], EXPECTED_DISTINCT_BASENAMES)
    complete = 0
    total_objects = 0
    for section in sections:
        for block in section["blocks"]:
            if block["block"] != "Objects":
                continue
            for record in block["records"]:
                total_objects += 1
                ok = all(name in record for name in OBJECT_FIELDS)
                for name in OBJECT_STRUCTS:
                    ok = ok and isinstance(record.get(name), dict) and all(
                        component in record[name] for component in VECTOR4)
                if ok:
                    complete += 1
    add("object_fields_complete",
        complete == total_objects and total_objects == 39783,
        {"complete": complete, "total": total_objects}, {"complete": 39783, "total": 39783})
    mine_owners = obj["mine_embedding_owners"]
    add("mng_embeds_minegold", "minegold" in mine_owners,
        mine_owners.get("minegold", []), "non-empty owner list")
    add("mni_embeds_mineiron", "mineiron" in mine_owners,
        mine_owners.get("mineiron", []), "non-empty owner list")
    add("mnc_embeds_minecoal", "minecoal" in mine_owners,
        mine_owners.get("minecoal", []), "non-empty owner list")
    add("family_count_64", len(ctx["families"]) == EXPECTED_FAMILIES,
        len(ctx["families"]), EXPECTED_FAMILIES)
    pair_count = sum(len(f["pairs"]) for f in ctx["families"])
    add("family_pairs_493", pair_count == EXPECTED_PAIRS, pair_count, EXPECTED_PAIRS)
    join_summary = ctx["join_summary"]
    add("family_exact_452", join_summary.get("exact") == 452,
        join_summary.get("exact"), 452)
    add("family_normalized_37", join_summary.get("normalized") == 37,
        join_summary.get("normalized"), 37)
    add("family_unresolved_4", join_summary.get("unresolved") == 4,
        join_summary.get("unresolved"), 4)
    add("lib_index_pair_count",
        ctx["lib_index_doc"]["pair_count"] == EXPECTED_PAIRS,
        ctx["lib_index_doc"]["pair_count"], EXPECTED_PAIRS)
    add("out_guard_rejects_donor",
        is_inside(os.path.join(ctx["game"], "data", "pattern"), ctx["game"])
        and is_inside(ctx["game"], ctx["game"])
        and not is_inside(ctx["out"], ctx["game"]),
        {"donor_subdir": True, "donor_root": True, "default_out": False},
        {"all": True})
    emitted = sorted(docs)
    boundary_ok = emitted == ["pattern_lib_index.json"]
    add("emission_boundary_lib_index_only", boundary_ok, emitted,
        ["pattern_lib_index.json"])
    add("no_per_pattern_binary_json",
        not any(path.split("/")[0] == "patterns" for path in emitted),
        [path for path in emitted if path.split("/")[0] == "patterns"], [])
    parsed_docs = [json.loads(data.decode("utf-8")) for data in docs.values()]
    parity_ok = all(doc.get("visual_parity_claim") is False for doc in parsed_docs)
    add("parity_flag_false_everywhere", parity_ok, parity_ok, True)
    add("undecodable_fields_null_labelled",
        all(r["unverified_fields"]["relief_float_grid"] is None
            and r["unverified_fields"]["label"] == LABEL_UNVERIFIED
            for r in ctx["index_doc"]["sections"]),
        True, True)
    first_bytes = {path: sha256_bytes(data) for path, data in docs.items()}
    second_bytes = {path: sha256_bytes(data) for path, data in docs2.items()}
    add("determinism_two_runs", first_bytes == second_bytes,
        {"documents": len(first_bytes), "identical": first_bytes == second_bytes},
        {"identical": True})
    add("no_timestamps_in_documents",
        not any(re.search(r'"(timestamp|generated_at|generated|date)"\s*:',
                          data.decode("utf-8"), re.IGNORECASE)
                for data in docs.values()),
        True, True)
    return checks


# --------------------------------------------------------------------------
# orchestration
# --------------------------------------------------------------------------

def load_context(game, out):
    lib_path = os.path.join(game, LIB_REL)
    gen_path = os.path.join(game, GEN_REL)
    pat_dir = os.path.join(game, PAT_DIR_REL)
    for path in (lib_path, gen_path, pat_dir):
        if not os.path.exists(path):
            raise RuntimeError("missing donor path: %s" % path)
    table = LineTable(lib_path)
    sections, begins, ends, order_issues = parse_sections(table)
    pattern_files, _, _ = pattern_inventory(game, sections)
    families = parse_generator(gen_path)
    join_summary = join_families(families, sections)
    ctx = {
        "game": game,
        "out": out,
        "table": table,
        "sections": sections,
        "begins": begins,
        "ends": ends,
        "order_issues": order_issues,
        "pattern_files": pattern_files,
        "families": families,
        "join_summary": join_summary,
    }
    ctx["source"] = source_string(game, lib_path, gen_path, sections)
    ctx["source_sha256"] = source_hashes(game, sections, families)
    ctx["index_doc"] = build_index_doc(ctx)
    ctx["offset_doc"] = build_offset_doc(ctx)
    ctx["census_doc"] = build_census_doc(ctx)
    ctx["object_doc"] = build_object_doc(ctx)
    ctx["lib_index_doc"] = build_lib_index_doc(ctx)
    # Ownership boundary (COORD/V44): one lib index only; no I02-owned outputs.
    docs = {"pattern_lib_index.json": json_bytes(ctx["lib_index_doc"])}
    return ctx, docs


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Decode donor pattern.lib (plaintext CRLF section DB) into labelled JSON")
    parser.add_argument("--game", default=DEFAULT_GAME,
                        help="donor install root (read-only), default %r" % DEFAULT_GAME)
    parser.add_argument("--out", default=DEFAULT_OUT,
                        help="derived output directory, default %s" % DEFAULT_OUT)
    parser.add_argument("--check", action="store_true",
                        help="run the full validation suite; exit 1 on any FAIL")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", dest="write", action="store_false",
                      help="print the emission plan only (DEFAULT)")
    mode.add_argument("--write", dest="write", action="store_true",
                      help="actually write derived JSON under --out")
    parser.set_defaults(write=False)
    args = parser.parse_args(argv)

    game = os.path.abspath(args.game)
    out = os.path.abspath(args.out)
    if is_inside(out, game):
        print("REFUSED: --out is inside the read-only donor root: %s" % out,
              file=sys.stderr)
        return 2
    try:
        ctx, docs = load_context(game, out)
        docs2 = None
        if args.check:
            _, docs2 = load_context(game, out)
        checks = run_checks(ctx, docs, docs2) if args.check else []
    except (OSError, RuntimeError, ValueError, struct.error) as exc:
        print("ERROR: %s" % exc, file=sys.stderr)
        return 2

    for path in sorted(docs):
        doc = json.loads(docs[path].decode("utf-8"))
        labels = ",".join(doc.get("labels", [])) or "-"
        print("%s -> %s -> sha256:%s -> labels:%s" %
              (doc.get("source", "derived"), path,
               sha256_bytes(docs[path]), labels))
    if args.write:
        for path in sorted(docs):
            destination = os.path.join(out, *path.split("/"))
            parent = os.path.dirname(destination)
            if not os.path.isdir(parent):
                os.makedirs(parent)
            with open(destination, "wb") as fh:
                fh.write(docs[path])
        print("WROTE %d derived JSON files to %s" % (len(docs), out))

    if args.check:
        passed = sum(1 for c in checks if c["status"] == "PASS")
        failed = sum(1 for c in checks if c["status"] == "FAIL")
        for check in sorted(checks, key=lambda c: c["name"]):
            print("[%s] %s observed=%r expected=%r" %
                  (check["status"], check["name"], check["observed"],
                   check["expected"]))
        print("CHECK SUMMARY: %d PASS / %d FAIL (no donor parity claim)" %
              (passed, failed))
        return 1 if failed else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
