"""Split the V7-85 180 MB tile atlas into GitHub-safe parts (+ runtime manifest).

ASSET-ONLY tool, owned by V7-91. It never edits .gd, the V7-85 build tool,
the V7-86 shader, app/, config, tests or git state. It writes ONLY inside
``variant3d/assets/terrain/atlas_parts/``:

  * ``tile_index_atlas.part000``, ``part001`` ...  (<= 90,000,000 bytes each)
  * ``split_manifest.json``                       (sizes, sha256, order)
  * ``alpha.png`` / ``alphavert.png``             (small donor masks, copied)

WHY SPLIT INSTEAD OF ZIP (MEASURED, not guessed):

  ``zipfile.ZipFile(..., ZIP_DEFLATED, compresslevel=9)`` over the 179,912,941
  byte PNG gives 179,553,069 bytes -> ratio 0.998. PNG is already deflated, so
  a single archive STILL exceeds GitHub's ~100 MB per-file limit. Splitting is
  the only change that actually makes the commit possible. Run with
  ``--measure-zip`` to reproduce the measurement (the temp zip is discarded).

REASSEMBLY CONTRACT (consumed by ``variant3d/scripts/tile_atlas_loader.gd``):

  concatenate ``parts`` in ``reassembly.order`` to a ``user://`` cache file;
  sha256(cache) MUST equal ``source.sha256``. The loader never writes res://.

The source PNG is deliberately NOT deleted by this tool. After an independent
verification (part hash + dual-mode runtime probe) it is removed by the owning
agent; it is regenerable with ``python variant3d/tools/build_tile_index_atlas.py``
(the V7-85 tool, donor root read-only). Use ``--check`` to validate the parts
after that deletion — it compares against the hash recorded in the manifest.

Usage (project root):

  python -m py_compile variant3d/tools/pack_tile_atlas_split.py
  python variant3d/tools/pack_tile_atlas_split.py --measure-zip
  python variant3d/tools/pack_tile_atlas_split.py --check
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ATLAS = ROOT / "variant3d" / "assets" / "terrain" / "atlas"
PARTS = ROOT / "variant3d" / "assets" / "terrain" / "atlas_parts"

SOURCE = ATLAS / "tile_index_atlas.png"
V785_MANIFEST = ATLAS / "tile_index_atlas.manifest.json"
SPLIT_MANIFEST = PARTS / "split_manifest.json"
MASKS = ("alpha.png", "alphavert.png")

PART_MAX = 90_000_000          # GitHub per-file ceiling is ~100 MB; keep headroom
PART_PREFIX = "tile_index_atlas.part"
CHUNK = 1 << 20                # 1 MiB streaming chunks — never hold 180 MB in RAM

DONOR_MASKS = {
    "alpha.png": "data/terrain/ref/reftilealpha.mat:30-37",
    "alphavert.png": "data/terrain/ref/reftilealpha.mat:139-146",
}

LABELS = [
    "DONOR_INDEX_VIA_V785_MANIFEST",
    "LOSSLESS_BYTE_SPLIT",
    "REASSEMBLY_SHA256_VERIFIED",
    "APPROX_ATLAS_PACKING (inherited from V7-85; donor packing UNVERIFIED)",
    "NO_VISUAL_PARITY_CLAIM",
]


def sha256_path(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(CHUNK), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def measure_zip_size(source: Path) -> dict:
    """MEASURED zip-vs-split comparison; temp archive is discarded."""
    fd, tmp = tempfile.mkstemp(prefix="v791_zip_probe_", suffix=".zip")
    import os
    os.close(fd)
    try:
        with zipfile.ZipFile(tmp, "w", compression=zipfile.ZIP_DEFLATED,
                             compresslevel=9) as zf:
            zf.write(source, arcname=source.name)
        zsize = Path(tmp).stat().st_size
    finally:
        Path(tmp).unlink(missing_ok=True)
    raw = source.stat().st_size
    return {
        "raw_bytes": raw,
        "zip_deflated_level9_bytes": zsize,
        "ratio": round(zsize / raw, 6),
        "exceeds_github_100mb": zsize > 100_000_000,
        "note": "PNG is already deflated; zip does not fit GitHub's ~100MB per-file limit.",
    }


def split(source: Path) -> dict:
    """Stream source into ordered parts; return manifest-ready metadata."""
    if not source.is_file():
        raise FileNotFoundError("missing source atlas: %s" % source)
    if not V785_MANIFEST.is_file():
        raise FileNotFoundError("missing V7-85 manifest (index order source): %s" % V785_MANIFEST)

    PARTS.mkdir(parents=True, exist_ok=True)
    # Remove stale parts from a previous run (no other directory is touched).
    for old in PARTS.glob(PART_PREFIX + "*"):
        old.unlink()

    parts: list[dict] = []
    out = None
    part_hash = hashlib.sha256()
    part_bytes = 0
    part_index = 0
    total = 0

    def close_part() -> None:
        nonlocal out, part_hash, part_bytes, part_index
        if out is not None:
            out.close()
            out = None
            parts.append({
                "name": "%s%03d" % (PART_PREFIX, part_index),
                "order": part_index,
                "bytes": part_bytes,
                "sha256": part_hash.hexdigest(),
                "offset": total - part_bytes,
            })
            part_index += 1
            part_hash = hashlib.sha256()
            part_bytes = 0

    try:
        with open(source, "rb") as fh:
            while True:
                chunk = fh.read(CHUNK)
                if not chunk:
                    break
                if part_bytes + len(chunk) > PART_MAX:
                    # Fill the current part exactly up to PART_MAX, then roll.
                    room = PART_MAX - part_bytes
                    if room:
                        part_hash.update(chunk[:room])
                        out.write(chunk[:room])
                        part_bytes += room
                        total += room
                    close_part()
                    rest = chunk[room:] if room else chunk
                    if rest:
                        out = open(PARTS / ("%s%03d" % (PART_PREFIX, part_index)), "wb")
                        part_hash.update(rest)
                        out.write(rest)
                        part_bytes += len(rest)
                        total += len(rest)
                    continue
                if out is None:
                    out = open(PARTS / ("%s%03d" % (PART_PREFIX, part_index)), "wb")
                part_hash.update(chunk)
                out.write(chunk)
                part_bytes += len(chunk)
                total += len(chunk)
    finally:
        if out is not None:
            out.close()  # keep the handle so the final close_part() records it
    close_part()
    # Whole-file hash is measured on the reassembled parts in verify() below;
    # no 180 MB buffer is ever held in RAM.
    return {"total": total, "parts": parts}


def reassemble_and_verify(parts: list[dict], expected_hash: str,
                          expected_bytes: int) -> dict:
    """Concatenate parts in order into a temp file and hash it (real bytes)."""
    fd, tmp = tempfile.mkstemp(prefix="v791_reassembly_", suffix=".png")
    import os
    os.close(fd)
    h = hashlib.sha256()
    written = 0
    try:
        with open(tmp, "wb") as dst:
            for entry in parts:
                p = PARTS / entry["name"]
                if not p.is_file():
                    raise FileNotFoundError("missing split part: %s" % p)
                if p.stat().st_size != entry["bytes"]:
                    raise AssertionError("part size mismatch: %s" % p.name)
                if sha256_path(p) != entry["sha256"]:
                    raise AssertionError("part hash mismatch: %s" % p.name)
                with open(p, "rb") as src:
                    while True:
                        chunk = src.read(CHUNK)
                        if not chunk:
                            break
                        dst.write(chunk)
                        h.update(chunk)
                        written += len(chunk)
        got = h.hexdigest()
    finally:
        Path(tmp).unlink(missing_ok=True)
    ok = got == expected_hash and written == expected_bytes
    return {
        "reassembled_bytes": written,
        "reassembled_sha256": got,
        "expected_bytes": expected_bytes,
        "expected_sha256": expected_hash,
        "matches": ok,
    }


def copy_masks() -> dict:
    """Small donor masks stay as separate files; copied so atlas_parts/ is whole."""
    out: dict = {}
    for name in MASKS:
        src = ATLAS / name
        if not src.is_file():
            raise FileNotFoundError("missing donor mask: %s" % src)
        dst = PARTS / name
        shutil.copyfile(src, dst)
        out[name] = {
            "file": name,
            "bytes": dst.stat().st_size,
            "sha256": sha256_path(dst),
            "copied_from": "variant3d/assets/terrain/atlas/" + name,
            "donor_evidence": DONOR_MASKS[name],
            "status": "CONVERTED_FROM_DONOR (V7-85), small separate file — NOT split",
        }
    return out


def write_manifest(source_hash: str, source_bytes: int, parts: list[dict],
                   verification: dict, zip_info: dict, masks: dict) -> dict:
    manifest = {
        "version": 1,
        "generator": "variant3d/tools/pack_tile_atlas_split.py",
        "task": "V7-91 — dual-mode atlas (split parts + Texture2DArray)",
        "labels": LABELS,
        "source": {
            "file": "variant3d/assets/terrain/atlas/tile_index_atlas.png",
            "bytes": source_bytes,
            "sha256": source_hash,
            "status": "DELETED__REGENERABLE",
            "regenerate": "python variant3d/tools/build_tile_index_atlas.py",
            "regenerate_note": "V7-85 tool; donor root read-only via $COSSACKS3_DIR",
        },
        "part_max_bytes": PART_MAX,
        "part_count": len(parts),
        "parts": parts,
        "reassembly": {
            "order": [e["name"] for e in parts],
            "algorithm": "concatenate parts in `order` to user:// cache; sha256 must equal source.sha256",
            "destination": "user://tile_atlas_cache/tile_index_atlas.png (never res://)",
        },
        "masks": masks,
        "verification": verification,
        "zip_vs_split": zip_info,
        "index_order_source": {
            "file": "variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json",
            "use": "array mode: layout[index].source_png + kind define slot order",
            "evidence": "presets_summer.json:2-125 (terrain.presets:2-6)",
        },
        "visual_parity_claim": False,
    }
    SPLIT_MANIFEST.write_text(
        json.dumps(manifest, indent=1, ensure_ascii=False), encoding="utf-8")
    return manifest


def do_build(measure_zip: bool) -> dict:
    source_hash = sha256_path(SOURCE)
    source_bytes = SOURCE.stat().st_size
    result = split(SOURCE)
    parts = result["parts"]
    if sum(p["bytes"] for p in parts) != source_bytes:
        raise AssertionError("split byte total != source size")
    verification = reassemble_and_verify(parts, source_hash, source_bytes)
    if not verification["matches"]:
        raise AssertionError("reassembly hash/size mismatch: %s" % verification)
    masks = copy_masks()
    zip_info = measure_zip_size(SOURCE) if measure_zip else {
        "skipped": "pass --measure-zip to reproduce (temp archive discarded)"
    }
    manifest = write_manifest(source_hash, source_bytes, parts, verification,
                              zip_info, masks)
    print(json.dumps({
        "source_bytes": source_bytes,
        "source_sha256": source_hash,
        "part_max_bytes": PART_MAX,
        "part_count": len(parts),
        "parts": [{"name": p["name"], "bytes": p["bytes"]} for p in parts],
        "verification": verification,
        "masks": {k: {"bytes": v["bytes"], "sha256": v["sha256"]}
                  for k, v in masks.items()},
        "zip_vs_split": zip_info,
        "manifest": str(SPLIT_MANIFEST),
    }, indent=2))
    return manifest


def do_check() -> dict:
    if not SPLIT_MANIFEST.is_file():
        raise FileNotFoundError("missing split manifest: %s" % SPLIT_MANIFEST)
    manifest = json.loads(SPLIT_MANIFEST.read_text("utf-8"))
    verification = reassemble_and_verify(
        manifest["parts"], manifest["source"]["sha256"], manifest["source"]["bytes"])
    mask_check = {}
    for name, entry in manifest["masks"].items():
        p = PARTS / entry["file"]
        mask_check[name] = p.is_file() and sha256_path(p) == entry["sha256"]
    ok = verification["matches"] and all(mask_check.values())
    print(json.dumps({
        "check": "part reassembly + mask hashes",
        "verification": verification,
        "mask_hashes_ok": mask_check,
        "passed": ok,
        "note": "source PNG may be deleted; hash comes from the manifest",
    }, indent=2))
    if not ok:
        raise AssertionError("split check failed")
    return manifest


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="verify existing parts against manifest (source may be gone)")
    ap.add_argument("--measure-zip", action="store_true",
                    help="also measure ZIP_DEFLATED level 9 size (temp, discarded)")
    args = ap.parse_args()
    if args.check:
        do_check()
    else:
        do_build(args.measure_zip)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
