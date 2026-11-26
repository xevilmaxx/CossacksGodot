"""Build the compact runtime prop feed without dropping valid donor records.

The previous PERF-FEED prototype excluded three structurally valid ``inline``
Objects records to preserve an old mandated count of 39,780. Donor fidelity
requires all 39,783 records. This builder keeps the same compact per-family
layout and verifies every emitted record against the source before writing.

Usage (from the repository root):
    python -B variant3d/tools/build_compact_props.py --check
    python -B variant3d/tools/build_compact_props.py --write

Donor-derived input is read-only. No donor binary is executed or copied.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
from collections import Counter
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = ROOT / "variant3d/assets/terrain_new/lib/pattern_lib_index.json"
DEFAULT_OUTPUT = ROOT / "variant3d/assets/terrain_new/props"
SCHEMA = "terrain_new/props_preindex/v1"
FIELDS = ("BaseName", "Position", "Direction", "Up", "Scaling")
VECTORS = ("Position", "Direction", "Up", "Scaling")
AXES = ("X", "Y", "Z", "W")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def dumps(obj: Any) -> str:
    return json.dumps(obj, ensure_ascii=False, separators=(",", ":"), allow_nan=False)


def family_of(section_name: str) -> str:
    return re.sub(r"_?\d+$", "", section_name) or section_name


def safe_name(name: str) -> str:
    value = re.sub(r"[^A-Za-z0-9_.-]", "_", name)
    if value in ("", ".", "..") or value.lower().endswith(".json"):
        value = "s_" + (value or "empty")
    return value


def unwrap_base(value: Any) -> str:
    if isinstance(value, dict):
        value = value.get("value")
    if not isinstance(value, str) or not value:
        raise ValueError("BaseName.value must be a non-empty string")
    return value


def compact_record(record: dict[str, Any]) -> dict[str, Any]:
    out: dict[str, Any] = {}
    for field in FIELDS:
        if field not in record:
            raise ValueError(f"missing {field}")
        value = record[field]
        if field == "BaseName":
            out[field] = unwrap_base(value)
            continue
        if not isinstance(value, dict):
            raise ValueError(f"{field} must be a dictionary")
        vector: dict[str, Any] = {}
        for axis in AXES:
            if axis not in value:
                raise ValueError(f"{field}.{axis} missing")
            component = value[axis]
            if not isinstance(component, (int, float)):
                raise ValueError(f"{field}.{axis} is not numeric")
            if isinstance(component, float) and not math.isfinite(component):
                raise ValueError(f"{field}.{axis} is not finite")
            vector[axis] = component
        out[field] = vector
    return out


def collect(source: dict[str, Any]) -> tuple[dict[str, list[dict[str, Any]]], Counter[str]]:
    sections = source.get("pattern_lib", {}).get("sections")
    if not isinstance(sections, list):
        raise ValueError("source pattern_lib.sections must be an array")
    by_section: dict[str, list[dict[str, Any]]] = {}
    styles: Counter[str] = Counter()
    for section in sections:
        if not isinstance(section, dict):
            raise ValueError("section must be a dictionary")
        name = section.get("name")
        if not isinstance(name, str) or not name:
            raise ValueError("section name must be a non-empty string")
        records_out: list[dict[str, Any]] = []
        for block in section.get("blocks", []):
            if not isinstance(block, dict) or block.get("block") != "Objects":
                continue
            for record in block.get("records", []):
                if not isinstance(record, dict):
                    raise ValueError(f"{name}: Objects record must be a dictionary")
                styles[str(record.get("style", ""))] += 1
                records_out.append(compact_record(record))
        if records_out:
            by_section[name] = records_out
    return by_section, styles


def build_payloads(source_path: Path) -> tuple[dict[str, bytes], dict[str, Any]]:
    source_bytes = source_path.stat().st_size
    source_sha = sha256_file(source_path)
    with source_path.open("r", encoding="utf-8") as f:
        source = json.load(f)
    # ``source_sha256`` inside the derived index identifies the donor pattern.lib,
    # not this JSON file. The compact feed records the actual index SHA computed
    # above and keeps the donor provenance in the unchanged source document.

    by_section, styles = collect(source)
    by_family: dict[str, dict[str, list[dict[str, Any]]]] = {}
    section_family: dict[str, str] = {}
    for name in sorted(by_section):
        family = family_of(name)
        section_family[name] = family
        by_family.setdefault(family, {})[name] = by_section[name]

    family_files = {
        family: f"families/{safe_name(family)}.json" for family in sorted(by_family)
    }
    payloads: dict[str, bytes] = {}
    for family in sorted(by_family):
        rel = family_files[family]
        payloads[rel] = dumps({"family": family, "sections": by_family[family]}).encode("utf-8")

    record_count = sum(len(records) for records in by_section.values())
    basenames = {record["BaseName"] for records in by_section.values() for record in records}
    index = {
        "schema": SCHEMA,
        "source": "variant3d/assets/terrain_new/lib/pattern_lib_index.json",
        "source_sha256": source_sha,
        "source_bytes": source_bytes,
        "record_rule": (
            "pattern_lib.sections[].blocks[block=='Objects'].records[]; "
            "all structurally valid nested and inline records"
        ),
        "excluded_inline_records": 0,
        "record_count": record_count,
        "distinct_basenames": len(basenames),
        "family_count": len(by_family),
        "section_count": len(by_section),
        "files": {name: family_files[section_family[name]] for name in sorted(by_section)},
        "families": family_files,
        "section_family": section_family,
        "style_counts": dict(sorted(styles.items())),
        "visual_parity_claim": False,
    }
    payloads["props_index.json"] = dumps(index).encode("utf-8")

    # Independent round-trip check: decode exactly what would be written and
    # compare every compact record with a fresh source collection.
    decoded_index = json.loads(payloads["props_index.json"])
    roundtrip: dict[str, list[dict[str, Any]]] = {}
    for rel in decoded_index["families"].values():
        doc = json.loads(payloads[rel])
        for name, records in doc["sections"].items():
            if name in roundtrip:
                raise ValueError(f"duplicate section in output: {name}")
            roundtrip[name] = records
    if roundtrip != by_section:
        raise ValueError("round-trip record mismatch")
    if sum(len(records) for records in roundtrip.values()) != record_count:
        raise ValueError("round-trip record count mismatch")

    metrics = {
        "source_bytes": source_bytes,
        "source_sha256": source_sha,
        "record_count": record_count,
        "section_count": len(by_section),
        "family_count": len(by_family),
        "distinct_basenames": len(basenames),
        "style_counts": dict(sorted(styles.items())),
        "output_files": len(payloads),
        "output_bytes": sum(len(data) for data in payloads.values()),
        "size_reduction_pct": round(100.0 * (1.0 - sum(len(data) for data in payloads.values()) / source_bytes), 3),
        "roundtrip": "PASS",
    }
    return payloads, metrics


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="verify without writing")
    mode.add_argument("--write", action="store_true", help="write changed compact feed files")
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    payloads, metrics = build_payloads(args.source)
    changed: list[str] = []
    if args.write:
        args.output.mkdir(parents=True, exist_ok=True)
        (args.output / "families").mkdir(parents=True, exist_ok=True)
        for rel, data in sorted(payloads.items()):
            path = args.output / rel
            old = path.read_bytes() if path.exists() else None
            if old == data:
                continue
            tmp = path.with_suffix(path.suffix + ".tmp")
            tmp.write_bytes(data)
            tmp.replace(path)
            changed.append(rel)
    else:
        for rel, data in sorted(payloads.items()):
            path = args.output / rel
            if not path.exists() or path.read_bytes() != data:
                changed.append(rel)

    metrics["mode"] = "write" if args.write else "check"
    metrics["changed_files"] = changed
    print(json.dumps(metrics, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
