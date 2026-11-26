"""Build a compact, lossless runtime bundle for donor terrain pattern inputs.

The authoritative decoded JSON remains untouched. This offline tool emits only
the fields consumed by ``terrain_donor_inputs.gd``:

* family index: family/output/pattern-count metadata;
* family files: ordered pattern name/frequency pairs;
* pattern files: name, dimensions, relief grid, flags, offsets, optional
  canonical grid and occupancy cells.

Usage (from the repository root):
    python -B variant3d/tools/build_compact_patterns.py --check
    python -B variant3d/tools/build_compact_patterns.py --write

No donor binary is executed or copied. No synthetic grid or metadata is added.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_ROOT = ROOT / "variant3d/assets/terrain_new/patterns"
DEFAULT_OUTPUT = DEFAULT_ROOT / "compact"
SCHEMA = "terrain_new/patterns_compact/v1"
PATTERN_FIELDS = (
    "name",
    "w",
    "h",
    "relief_float_grid",
    "flags",
    "grid_offset",
    "grid_layout",
    "grid",
    "occupancy_cells",
)


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def dumps(obj: Any) -> str:
    return json.dumps(obj, ensure_ascii=False, separators=(",", ":"), allow_nan=False)


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def compact_pattern(name: str, doc: dict[str, Any]) -> dict[str, Any]:
    w = doc.get("w")
    h = doc.get("h")
    grid = doc.get("relief_float_grid")
    if not isinstance(w, int) or not isinstance(h, int) or w <= 0 or h <= 0:
        raise ValueError(f"{name}: invalid dimensions")
    if not isinstance(grid, list) or len(grid) != w * h:
        raise ValueError(f"{name}: relief grid size mismatch")
    for value in grid:
        if not isinstance(value, (int, float)) or not math.isfinite(float(value)):
            raise ValueError(f"{name}: non-finite relief value")
    flags = doc.get("flags")
    if flags is None:
        flags = {}
    if not isinstance(flags, dict):
        raise ValueError(f"{name}: flags must be a dictionary")
    out: dict[str, Any] = {
        "name": str(doc.get("name", name)),
        "w": w,
        "h": h,
        "relief_float_grid": grid,
        "flags": flags,
        "grid_offset": int(doc.get("grid_offset", 0)),
        "grid_layout": str(doc.get("grid_layout", "")),
    }
    if "grid" in doc:
        canonical = doc["grid"]
        if not isinstance(canonical, list) or len(canonical) != w * h:
            raise ValueError(f"{name}: canonical grid size mismatch")
        for value in canonical:
            if not isinstance(value, (int, float)) or not math.isfinite(float(value)):
                raise ValueError(f"{name}: non-finite canonical grid value")
        out["grid"] = canonical
    if "occupancy_cells" in doc:
        occupancy = doc["occupancy_cells"]
        if not isinstance(occupancy, list):
            raise ValueError(f"{name}: occupancy must be an array")
        packed = bytearray()
        for value in occupancy:
            if not isinstance(value, int) or value < 0 or value > 255:
                raise ValueError(f"{name}: occupancy byte out of range")
            packed.append(value)
        if len(packed) not in (w * h, (w - 1) * (h - 1)):
            raise ValueError(f"{name}: occupancy size mismatch")
        out["occupancy_cells"] = occupancy
    # Prove no consumed field was silently omitted.
    for field in PATTERN_FIELDS:
        if field in doc and field not in out:
            raise ValueError(f"{name}: consumed field {field} was not carried")
    return out


def build(source_root: Path) -> tuple[dict[str, bytes], dict[str, Any]]:
    index_path = source_root / "family_index.json"
    index = read_json(index_path)
    source_families = index.get("families")
    if not isinstance(source_families, list):
        raise ValueError("family_index.families must be an array")

    compact_families: list[dict[str, Any]] = []
    family_source_bytes = 0
    family_source_files = 0
    for entry in source_families:
        if not isinstance(entry, dict):
            raise ValueError("family entry must be a dictionary")
        family = entry.get("family")
        output = entry.get("output")
        if not isinstance(family, str) or not isinstance(output, str):
            raise ValueError("family entry missing family/output")
        path = source_root / output.replace("\\", "/")
        doc = read_json(path)
        patterns = doc.get("patterns")
        if not isinstance(patterns, list):
            raise ValueError(f"{family}: patterns must be an array")
        compact_patterns: list[dict[str, Any]] = []
        for item in patterns:
            if not isinstance(item, dict):
                raise ValueError(f"{family}: pattern entry must be a dictionary")
            name = item.get("match") or item.get("pattern")
            if not isinstance(name, str) or not name:
                raise ValueError(f"{family}: pattern entry missing name")
            compact_patterns.append({"match": name, "freq": float(item.get("freq", 1.0))})
        compact_families.append({
            "family": family,
            "output": output,
            "pattern_count": int(entry.get("pattern_count", len(compact_patterns))),
            "patterns": compact_patterns,
        })
        family_source_bytes += path.stat().st_size
        family_source_files += 1

    compact_patterns_by_name: dict[str, dict[str, Any]] = {}
    pattern_source_bytes = 0
    pattern_source_files = 0
    excluded: list[str] = []
    for path in sorted(source_root.glob("*.json")):
        if path.name in ("family_index.json", "pattern_decode_manifest.json"):
            continue
        doc = read_json(path)
        if not isinstance(doc, dict) or "relief_float_grid" not in doc:
            excluded.append(path.name)
            continue
        compact = compact_pattern(path.stem, doc)
        compact_patterns_by_name[path.stem] = compact
        pattern_source_bytes += path.stat().st_size
        pattern_source_files += 1

    families_doc = {
        "schema": SCHEMA,
        "source": "variant3d/assets/terrain_new/patterns/family_index.json",
        "source_sha256": sha256_file(index_path),
        "families": compact_families,
        "visual_parity_claim": False,
    }
    patterns_doc = {
        "schema": SCHEMA,
        "patterns": compact_patterns_by_name,
        "visual_parity_claim": False,
    }

    # Independent round-trip checks before any output is written.
    if json.loads(dumps(families_doc)) != families_doc:
        raise ValueError("family bundle round-trip mismatch")
    if json.loads(dumps(patterns_doc)) != patterns_doc:
        raise ValueError("pattern bundle round-trip mismatch")
    missing_family_patterns = sorted({
        item["match"]
        for family in compact_families
        for item in family["patterns"]
        if item["match"] not in compact_patterns_by_name
    })

    payloads = {
        "families.json": dumps(families_doc).encode("utf-8"),
        "patterns.json": dumps(patterns_doc).encode("utf-8"),
    }
    output_bytes = sum(len(data) for data in payloads.values())
    manifest = {
        "schema": SCHEMA,
        "source_family_index_sha256": sha256_file(index_path),
        "source_family_index_bytes": index_path.stat().st_size,
        "source_family_files": family_source_files,
        "source_family_bytes": family_source_bytes,
        "source_pattern_files": pattern_source_files,
        "source_pattern_bytes": pattern_source_bytes,
        "source_total_bytes": index_path.stat().st_size + family_source_bytes + pattern_source_bytes,
        "compact_family_count": len(compact_families),
        "compact_pattern_count": len(compact_patterns_by_name),
        "compact_files": 2,
        "compact_bytes": output_bytes,
        "size_reduction_pct": round(
            100.0 * (1.0 - output_bytes / (index_path.stat().st_size + family_source_bytes + pattern_source_bytes)),
            3,
        ),
        "excluded_non_pattern_json": excluded,
        "missing_family_pattern_files": missing_family_patterns,
        "roundtrip": "PASS",
        "visual_parity_claim": False,
    }
    payloads["manifest.json"] = dumps(manifest).encode("utf-8")
    return payloads, manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--write", action="store_true")
    parser.add_argument("--source", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    payloads, manifest = build(args.source)
    changed: list[str] = []
    for rel, data in sorted(payloads.items()):
        path = args.output / rel
        old = path.read_bytes() if path.exists() else None
        if old == data:
            continue
        changed.append(rel)
        if args.write:
            args.output.mkdir(parents=True, exist_ok=True)
            tmp = path.with_suffix(path.suffix + ".tmp")
            tmp.write_bytes(data)
            tmp.replace(path)
    manifest["mode"] = "write" if args.write else "check"
    manifest["changed_files"] = changed
    print(json.dumps(manifest, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
