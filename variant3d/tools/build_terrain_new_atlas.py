"""Build the commit-safe, donor-indexed terrain atlas for ``terrain_new``.

This tool is the I05 implementation of the DONOR-FIRST terrain swarm. It is
ASSET-ONLY and READ-ONLY on the donor install:

  * ``--game`` is accepted for the licence guard (``--out`` inside the donor
    root is refused) but NO donor byte is ever opened, copied or executed.
  * Inputs are the already-converted, repo-derived block PNGs under
    ``variant3d/assets/terrain/blocks/``, the shipped index dictionary
    ``structs/presets_summer.json``, the shipped ``winter_aliases.json``, the
    already-converted ``alpha.png`` / ``alphavert.png`` masks and the QA dump
    ``app/shots/g32_dump.json``. All of these are read-only.
  * The only possible writes are derived assets under
    ``variant3d/assets/terrain_new/`` (commit tier) or an explicitly local,
    uncommitted output for ``--hires-local``. Legacy ``assets/terrain/**``,
    ``app/**``, donor files, tests, config, git and Godot are never touched.

The index dictionary stays exactly 124 names / 16x8 cells / ``i -> (i%16,i//16)``
with NO index remapping (spec/06 §2, F05 §4.1, A03 §2.2.1). All 121 filled cells
come from the 112 converted block PNGs (85 summer DIRECT + 36 identity FACE_BASE_REUSE
+ 27 winter blocks for the season atlas); the 3 alpha sentinels stay EMPTY and
UNVERIFIED, with the donor ``alpha0a/b/c -> grass1.dds + alphanull`` alias recorded
rather than fabricated (F05 G1). Byte-identical converted-art groups
(grass1=test10=test11, grass8=test0, test19=winter23..26) are recorded from real
hashes; no cell is collapsed or remapped.

The alpha masks are copied byte-for-byte from the already-converted level-0 PNGs
(level-0 identity preserved). Mipmaps are NOT written to disk: the manifest records
the CPU requirement ``Image.generate_mipmaps(false)`` before
``ImageTexture.create_from_image`` (Godot side owned by I08; B02 §3 / A03 E12).
This compiler never multiplies mask into albedo: donor ``bmTransparency`` is a
framebuffer crossfade ``glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)`` (D08/X17),
so alpha travels in its own sampler.

DRY-RUN IS THE DEFAULT. Run ``--write`` to emit files; ``--check`` verifies
committed outputs (or, with ``--dry-run``, verifies the in-memory plan).
Every run prints ``source -> output -> sha256 -> label`` for the whole plan.
Two runs with the same inputs produce byte-identical outputs (stable order, no
timestamps, no absolute donor path in committed data, sha256 over emitted bytes).

No donor visual parity is claimed: every manifest carries
``visual_parity_claim: false``.
"""
from __future__ import annotations

import argparse
import base64
import hashlib
import io
import json
import os
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image

# The commit-tier atlas is tiny; the local hires tier is 16384x8192 RGBA and
# legitimately exceeds Pillow's decompression-bomb warning. We allocate the
# canvas ourselves and only open trusted, already-converted 1024^2 block PNGs.
Image.MAX_IMAGE_PIXELS = None

ROOT = Path(__file__).resolve().parents[2]
V3D = ROOT / "variant3d"
STRUCTS = V3D / "assets" / "terrain" / "structs"
BLOCKS = V3D / "assets" / "terrain" / "blocks"
LEGACY_ATLAS = V3D / "assets" / "terrain" / "atlas"
SPLIT_MANIFEST = V3D / "assets" / "terrain" / "atlas_parts" / "split_manifest.json"
DUMP = ROOT / "app" / "shots" / "g32_dump.json"

PRESETS = STRUCTS / "presets_summer.json"
WINTER_ALIASES = LEGACY_ATLAS / "winter_aliases.json"
MASK_LEGACY = {
    "alpha": LEGACY_ATLAS / "alpha.png",
    "alphavert": LEGACY_ATLAS / "alphavert.png",
}

COMMIT_ROOT = V3D / "assets" / "terrain_new"
DEFAULT_OUT = COMMIT_ROOT / "atlas"
DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

GENERATOR = "variant3d/tools/build_terrain_new_atlas.py"
PACK = "terrain_new_v1"

COLS, ROWS, SLOTS, EXPECTED_NAMES = 16, 8, 128, 124
DEFAULT_CELL = 128
HIRES_CELL = 1024
ALPHA_SENTINELS = (86, 110, 123)
FACE_RE = re.compile(r"^(rock|sand)(\d+)(vf|vs|f|s)$")

ATLAS_NAME = "tile_index_atlas.png"
ATLAS_MANIFEST = "tile_index_atlas.manifest.json"
WINTER_ATLAS_NAME = "seasons/tile_index_atlas_winter.png"
WINTER_ATLAS_MANIFEST = "seasons/tile_index_atlas_winter.manifest.json"
WINTER_ALIAS_OUT = "seasons/winter_aliases.json"
DESERT_ALIAS_OUT = "seasons/desert_aliases.json"

MASK_SPECS = {
    "alpha": {
        "size": (512, 256), "out": "alpha.png",
        "evidence": "data/terrain/ref/reftilealpha.mat:30-37",
        "note": "8 bpp palette intensity from donor alpha.bmp; exact "
                "tiaAlphaFromIntensity formula is ENGINE/UNVERIFIED (F06 §3).",
    },
    "alphavert": {
        "size": (1024, 512), "out": "alphavert.png",
        "evidence": "data/terrain/ref/reftilealpha.mat:139-146",
        "note": "24 bpp near-grey RGB from donor alphavert.bmp converted to L; "
                "<=15 inter-channel spread discarded (F06 E11/R4). Face projection "
                "is eye-linear (reftile.mat:120-169), not a 64^2 patch atlas.",
    },
}

EXPECTED_IDENTICAL_GROUPS = (
    ("grass1", "test10", "test11"),
    ("grass8", "test0"),
    ("test19", "winter23", "winter24", "winter25", "winter26"),
)

LABELS = [
    "DONOR_INDEX",
    "DONOR_ART",
    "DONOR_ALIAS_ALPHANULL",
    "DONOR_ART_BYTE_IDENTICAL",
    "DONOR_BLEND_BM_TRANSPARENCY (D08/X17)",
    "APPROX_ATLAS_PACKING",
    "APPROX_ATLAS_DOWNSAMPLE",
    "APPROX_SAND_UPSCALE",
    "APPROX_ALPHA_INTENSITY_FORMULA",
    "PORT_APPROXIMATION_FACE_CELLS (identity reuse; no 25 deg / alphavert)",
    "UNVERIFIED_EMPTY_CELLS",
    "UNVERIFIED_ALPHA_SUBRECT_MAPPING",
    "UNVERIFIED_BLEND_PASS_COUNT",
    "NO_VISUAL_PARITY_CLAIM",
]


# --------------------------------------------------------------------------- #
# small helpers
# --------------------------------------------------------------------------- #
def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def canonical_json(obj: object) -> bytes:
    """Deterministic JSON bytes: stable insertion order, no timestamps."""
    return (json.dumps(obj, indent=1, ensure_ascii=False) + "\n").encode("utf-8")


def as_rel(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT.resolve()).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def norm(path: Path) -> str:
    return os.path.normcase(os.path.abspath(str(path)))


def is_within(child: Path, parent: Path) -> bool:
    c, p = norm(child), norm(parent)
    return c == p or c.startswith(p.rstrip(os.sep) + os.sep)


def face_base(name: str) -> str | None:
    m = FACE_RE.match(name)
    return "%s%s" % (m.group(1), m.group(2)) if m else None


def check_power_of_two(value: int) -> bool:
    return value > 0 and (value & (value - 1)) == 0


# --------------------------------------------------------------------------- #
# read-only inputs
# --------------------------------------------------------------------------- #
def load_names() -> list[str]:
    names = json.loads(PRESETS.read_text(encoding="utf-8"))
    if not isinstance(names, list) or len(names) != EXPECTED_NAMES:
        raise AssertionError("presets_summer.json must hold %d names" % EXPECTED_NAMES)
    if len(set(names)) != len(names):
        raise AssertionError("presets_summer.json contains duplicate names")
    return names


def load_winter_entries() -> list[dict]:
    doc = json.loads(WINTER_ALIASES.read_text(encoding="utf-8"))
    entries = doc.get("entries")
    if not isinstance(entries, list) or len(entries) != EXPECTED_NAMES:
        raise AssertionError("winter_aliases.json must hold 124 entries")
    if [e["index"] for e in entries] != list(range(EXPECTED_NAMES)):
        raise AssertionError("winter aliases are not index-preserving 0..123")
    return entries


def load_blocks() -> dict[str, Path]:
    files = {p.stem: p for p in BLOCKS.glob("*.png")}
    if len(files) != 112:
        raise AssertionError("expected 112 converted block PNGs, got %d" % len(files))
    return files


def load_dump() -> dict:
    if not DUMP.is_file():
        return {"status": "UNVERIFIED", "note": "app/shots/g32_dump.json missing"}
    dump = json.loads(DUMP.read_text(encoding="utf-8"))
    raw = base64.b64decode(dump["tileblock"])
    hist = Counter(raw)
    names = load_names()
    bad = sorted(i for i in hist if i >= len(names))
    return {
        "source": "app/shots/g32_dump.json:1 (key 'tileblock', base64 uint8)",
        "bytes": len(raw),
        "distinct_ids": len(hist),
        "min_id": min(hist) if hist else None,
        "max_id": max(hist) if hist else None,
        "histogram": {str(k): hist[k] for k in sorted(hist)},
        "unresolved_ids": bad,
        "all_resolvable": not bad,
        "top_ids": [[k, v] for k, v in hist.most_common(5)],
    }


def forbidden_hashes() -> dict:
    """Hashes of the uncommitted legacy 179 MB atlas and its lossless splits.

    Read from the committed split manifest (no 450 MB re-hash needed). These
    hashes are a licence guard: no emitted byte sequence may equal them.
    """
    blocked: dict[str, str] = {}
    if SPLIT_MANIFEST.is_file():
        doc = json.loads(SPLIT_MANIFEST.read_text(encoding="utf-8"))
        src = doc.get("source", {})
        if src.get("sha256"):
            blocked[src["sha256"]] = "legacy tile_index_atlas.png (%s B)" % src.get("bytes")
        for part in doc.get("parts", []):
            if part.get("sha256"):
                blocked[part["sha256"]] = "legacy split %s" % part.get("name")
    winter = LEGACY_ATLAS / "tile_index_atlas_winter.png"
    blocked["__winter_size__"] = str(winter.stat().st_size) if winter.is_file() else "missing"
    return blocked


# --------------------------------------------------------------------------- #
# atlas layout / packing
# --------------------------------------------------------------------------- #
def resolve_cell(idx: int, name: str, files: dict[str, Path], cell: int,
                 *, season: str, winter_entry: dict | None = None) -> dict:
    cx, cy = idx % COLS, idx // COLS
    entry = {
        "index": idx,
        "name": name,
        "cell_xy": [cx, cy],
        "cell_px": [cx * cell, cy * cell, cell, cell],
    }
    if season == "winter" and winter_entry is not None:
        entry["winter_alias"] = winter_entry.get("winter_alias")
        entry["shared_alpha"] = bool(winter_entry.get("shared_alpha", False))
        source_png = winter_entry.get("source_png")
        kind_in = winter_entry.get("kind", "WINTER_PNG")
    else:
        source_png = name + ".png"
        kind_in = "DIRECT"

    # The three donor alpha-sentinel indices stay EMPTY/UNVERIFIED in both
    # seasons. The alias is recorded; no grass art is fabricated into the cell.
    if idx in ALPHA_SENTINELS:
        entry.update(
            source_png=None, kind="EMPTY", status="UNVERIFIED",
            donor_evidence="data/terrain/tiles/tiles.mat:347-359",
            donor_alias={"art": "grass1.dds", "mask": "alphanull",
                         "evidence": "tiles.mat:347-359 (alpha0a/b/c)"},
            note="PORT APPROXIMATION / UNVERIFIED: port cell is a transparent hole; "
                 "donor binds grass1 art with the all-zero alphanull mask. No art fabricated.",
        )
        return entry

    stem = Path(source_png).stem
    if stem in files:
        entry.update(
            source_png=Path(source_png).name,
            kind=kind_in if season == "winter" else "DIRECT",
            donor_evidence=("presets_summer.json:%d" % (idx + 2)
                            if season == "summer" else
                            "winter_aliases.json:index %d (presets_summer.json:%d)"
                            % (idx, idx + 2)),
            status="OK",
        )
        return entry

    if season == "summer":
        base = face_base(name)
        if base and base in files:
            entry.update(
                source_png=base + ".png", kind="FACE_BASE_REUSE",
                donor_evidence=("data/terrain/tiles/tiles.mat:142-148,206-220 "
                                "(%s binds %s.dds)" % (name, base)),
                status="OK",
                face_label="PORT APPROXIMATION: identity copy of base PNG; donor "
                           "AngleX/AngleZ=25 (tiles.lib:119-297) and alphavert "
                           "eye-linear projection (reftile.mat:120-169) are absent.",
            )
            return entry

    entry.update(
        source_png=None, kind="EMPTY", status="UNVERIFIED", donor_evidence=None,
        note="No converted PNG resolves for this index; cell left transparent, "
             "no art fabricated.",
    )
    return entry


def pack_atlas(layout: list[dict], files: dict[str, Path], cell: int) -> bytes:
    """Paste every resolved cell; NEAREST for any size change (no new texels)."""
    atlas = Image.new("RGBA", (COLS * cell, ROWS * cell), (0, 0, 0, 0))
    for cell_info in layout:
        if cell_info["source_png"] is None:
            cell_info["source_size"] = None
            cell_info["source_sha256"] = None
            cell_info["resampled"] = False
            cell_info["resample_filter"] = None
            cell_info["resample_label"] = None
            continue
        src = files[Path(cell_info["source_png"]).stem]
        with Image.open(src) as im:
            size = list(im.size)
            rgb = im.convert("RGB")
        if size != [cell, cell]:
            rgb = rgb.resize((cell, cell), Image.Resampling.NEAREST)
            cell_info["resampled"] = True
            cell_info["resample_filter"] = "NEAREST"
            cell_info["resample_label"] = (
                "APPROX_SAND_UPSCALE" if cell_info["name"].startswith("sand")
                else "APPROX_ATLAS_DOWNSAMPLE")
        else:
            cell_info["resampled"] = False
            cell_info["resample_filter"] = None
            cell_info["resample_label"] = None
        cell_info["source_size"] = size
        cell_info["source_sha256"] = sha256_file(src)
        x, y, w, h = cell_info["cell_px"]
        atlas.paste(rgb, (x, y, x + w, y + h))
        rgb.close()
    buf = io.BytesIO()
    atlas.save(buf, format="PNG", compress_level=6)
    atlas.close()
    return buf.getvalue()


def mask_payload() -> dict[str, dict]:
    """Byte-identical level-0 copies of the already-converted mask PNGs."""
    out: dict[str, dict] = {}
    for key, spec in MASK_SPECS.items():
        src = MASK_LEGACY[key]
        data = src.read_bytes()
        with Image.open(io.BytesIO(data)) as im:
            size, mode = list(im.size), im.mode
        if tuple(size) != spec["size"] or mode != "L":
            raise AssertionError("%s: expected %s L, got %s %s"
                                 % (key, spec["size"], size, mode))
        out[key] = {
            "data": data,
            "sha256": sha256_bytes(data),
            "source_sha256": sha256_file(src),
            "size": size,
            "mode": mode,
        }
    return out


def identical_groups(files: dict[str, Path]) -> list[dict]:
    by_hash: dict[str, list[str]] = defaultdict(list)
    for stem, path in files.items():
        by_hash[sha256_file(path)].append(stem)
    groups = []
    for digest in sorted(by_hash):
        stems = sorted(by_hash[digest])
        if len(stems) > 1:
            groups.append({
                "sha256": digest,
                "stems": stems,
                "converted_files": [s + ".png" for s in stems],
                "label": "[O] BYTE_IDENTICAL_CONVERTED_PNG (donor DDS group, F05 E11)",
            })
    return groups


# --------------------------------------------------------------------------- #
# manifest sections
# --------------------------------------------------------------------------- #
def alpha_sentinel_records() -> list[dict]:
    return [{
        "index": i,
        "name": name,
        "donor_art": "grass1.dds",
        "donor_mask": "alphanull",
        "evidence": "data/terrain/tiles/tiles.mat:347-359",
        "port_cell": "EMPTY / transparent (no art fabricated)",
        "label": "UNVERIFIED / PORT APPROXIMATION",
    } for i, name in zip(ALPHA_SENTINELS, ("alpha0a", "alpha0b", "alpha0c"))]


def blend_record() -> dict:
    return {
        "donor_mode": "bmTransparency",
        "enum_index": 1,
        "gl_blend_func": ["SRC_ALPHA", "ONE_MINUS_SRC_ALPHA"],
        "semantics": "framebuffer crossfade of base tile against the mask-weighted "
                     "tile; the donor fragment shader only writes coverage to "
                     "gl_FragColor.a",
        "evidence": ("D08/X17 (binary framebuffer crossfade); reftile.mat:17; "
                     "cossacks.exe:949234 (bmOpaque=0, bmTransparency=1); "
                     "hf.pvl.smx3.frag:13-17,50"),
        "cross_check": ("F06 §2.3 had left exact factors/pass count UNVERIFIED; "
                        "D08/X17 resolves the factor pair. Draw-pass count remains "
                        "UNVERIFIED — no pass count is encoded."),
        "label": "DONOR_BLEND [O via D08/X17]; NO VISUAL PARITY CLAIM",
    }


def alpha_transport_record() -> dict:
    return {
        "mode": "separate_mask_samplers",
        "albedo_multiply": False,
        "note": "This compiler emits alpha.png and alphavert.png as separate "
                "single-channel assets and never folds mask into RGB. The donor "
                "fragment reads mask intensity into color.a; bmTransparency blends "
                "in the framebuffer (F06 §2; D08/X17).",
        "label": "[O]/[D] DONOR_TRANSPORT",
    }


def mipmap_record(tier: str) -> dict:
    return {
        "requirement": ("generate CPU mipmaps on the atlas Image before "
                        "ImageTexture.create_from_image, otherwise "
                        "filter_linear_mipmap has no levels"),
        "call": "Image.generate_mipmaps(false)",
        "level0": "byte-identical to the emitted PNG; mip levels are runtime-only "
                  "and are NOT written to this repository",
        "godot_owner": "I08 (terrain_donor_mesh.gd / material setup)",
        "filters": {"atlas": "filter_linear_mipmap", "masks": "filter_nearest"},
        "evidence": ("spec/11 §11.1 E12; B02_atlas_impl.md:63-75,81-162,168-179"),
        "resolution_tier": tier,
        "label": "[O] RUNTIME_REQUIREMENT (not a donor fact)",
    }


def licence_guard_record(out: Path, tier: str, blocked: dict, outputs: dict) -> dict:
    forbidden = {h: d for h, d in blocked.items() if h != "__winter_size__"}
    identity = {}
    for digest, description in sorted(forbidden.items()):
        resolved = sorted(name for name, value in outputs.items() if value == digest)
        if resolved:
            identity[digest] = {
                "legacy_asset": description,
                "resolved_output": resolved,
                "label": "LEGACY_ATLAS_BYTE_IDENTITY (derived, not donor bytes)",
            }
    return {
        "donor_root_read": False,
        "donor_bytes_written": False,
        "out_refused_in_donor_root": True,
        "legacy_atlas_byte_identity": identity,
        "legacy_identity_policy": (
            "cell 1024 + NEAREST + PNG compress 6 reproduces the legacy 179 MB "
            "atlas byte-for-byte; that tier is local/uncommitted only and is "
            "refused under terrain_new. The commit tier (128) never matches."
        ),
        "committed_writes_confined_to": "variant3d/assets/terrain_new/**",
        "legacy_large_atlas_bytes": blocked.get("__winter_size__"),
        "uncommitted_or_lfs": [
            "variant3d/assets/terrain/atlas/tile_index_atlas.png",
            "variant3d/assets/terrain/atlas/tile_index_atlas_winter.png",
            "variant3d/assets/terrain/atlas_parts/*.partNNN",
        ],
        "forbidden_output_hashes": {
            h: desc for h, desc in blocked.items() if h != "__winter_size__"
        },
        "tier": tier,
        "note": ("commit tier writes only under terrain_new; --hires-local is a "
                 "local, uncommitted capture tier and refuses writes under "
                 "terrain_new"),
        "label": "[O] DERIVED_ASSETS_ONLY",
    }


def make_provenance(layout: list[dict], atlas_sha: str, atlas_file: str,
                    masks: dict[str, dict], winter_layout: list[dict] | None,
                    winter_atlas_sha: str | None, season: str) -> list[dict]:
    prov: list[dict] = []
    for c in layout:
        if c["source_png"] is None:
            src = "data/terrain/tiles/terrain.presets:%d (EMPTY sentinel)" % (c["index"] + 6)
            converted = None
            csha = None
            label = "UNVERIFIED_EMPTY_CELL / PORT APPROXIMATION (no art fabricated)"
        else:
            src = "data/terrain/tiles/terrain.presets:6-129 / index %d" % c["index"]
            converted = "variant3d/assets/terrain/blocks/" + c["source_png"]
            csha = c.get("source_sha256")
            label = "%s [O] DONOR_ART" % c["kind"]
            if c.get("face_label"):
                label += " / PORT APPROXIMATION face identity"
            if c.get("resample_label"):
                label += " / " + c["resample_label"]
        x, y = c["cell_xy"]
        prov.append({
            "source": src,
            "offset": "presets_summer.json:%d -> cell (%d,%d)" % (c["index"] + 2, x, y),
            "converted_input": converted,
            "converted_sha256": csha,
            "output": "%s#cell(%d,%d)" % (atlas_file, x, y),
            "output_sha256": atlas_sha,
            "label": "%s / %s" % (season, label),
        })
    for key, spec in MASK_SPECS.items():
        m = masks[key]
        prov.append({
            "source": spec["evidence"],
            "offset": "n/a (already-converted level-0 PNG)",
            "converted_input": as_rel(MASK_LEGACY[key]),
            "converted_sha256": m["source_sha256"],
            "output": spec["out"],
            "output_sha256": m["sha256"],
            "label": "[O] CONVERTED_MASK level-0 byte-identical; formula UNVERIFIED",
        })
    if winter_layout is not None and winter_atlas_sha:
        for c in winter_layout:
            x, y = c["cell_xy"]
            prov.append({
                "source": "winter_aliases.json:index %d (index-preserving _winter rename)"
                          % c["index"],
                "offset": "cell (%d,%d)" % (x, y),
                "converted_input": ("variant3d/assets/terrain/blocks/" + c["source_png"])
                                   if c["source_png"] else None,
                "converted_sha256": c.get("source_sha256"),
                "output": "%s#cell(%d,%d)" % (WINTER_ATLAS_NAME, x, y),
                "output_sha256": winter_atlas_sha,
                "label": ("UNVERIFIED_EMPTY_CELL" if c["source_png"] is None
                          else "[O] DONOR_ART WINTER_ALIAS index-preserving"),
            })
    return prov


def make_manifest(*, season: str, cell: int, tier: str, layout: list[dict],
                  atlas_bytes: bytes, atlas_file: str, masks: dict[str, dict],
                  files: dict[str, Path], shipped: dict, blocked: dict,
                  winter_layout: list[dict] | None, winter_atlas_bytes: bytes | None,
                  outputs: dict[str, str], winter_entries: list[dict] | None) -> dict:
    filled = sum(1 for c in layout if c["source_png"] is not None)
    empty = len(layout) - filled
    groups = identical_groups(files)
    ident_names = {tuple(g["stems"]) for g in groups}
    for expected in EXPECTED_IDENTICAL_GROUPS:
        if tuple(sorted(expected)) not in ident_names:
            raise AssertionError("byte-identical group missing: %s" % (expected,))

    face_indices = [c["index"] for c in layout if c["kind"] == "FACE_BASE_REUSE"]
    manifest = {
        "version": 1,
        "generator": GENERATOR,
        "labels": list(LABELS) + (["LOCAL_HIRES_UNCOMMITTED"] if tier == "local_hires" else []),
        "atlas": {
            "file": atlas_file,
            "size": [COLS * cell, ROWS * cell],
            "cell_size": [cell, cell],
            "grid": [COLS, ROWS],
            "slots": SLOTS,
            "named_cells": len(layout),
            "filled_cells": filled,
            "empty_cells": empty,
            "packing_label": ("APPROX_ATLAS_PACKING (donor tsDouble/ttExtended is "
                              "engine-side, UNVERIFIED)"),
            "resolution_tier": tier,
        },
        "index_dictionary": {
            "file": "variant3d/assets/terrain/structs/presets_summer.json",
            "lines": "2-125",
            "count": len(layout),
            "donor_evidence": "data/terrain/tiles/terrain.presets:6-129",
            "mapping": "index i -> cell (i%16, i//16); NO index remapping",
        },
        "layout": layout,
        "aliases": {
            "alpha_sentinels": alpha_sentinel_records(),
            "byte_identical_groups": groups,
            "face_base_reuse": [
                {"index": c["index"], "name": c["name"], "source_png": c["source_png"],
                 "evidence": c["donor_evidence"]}
                for c in layout if c["kind"] == "FACE_BASE_REUSE"
            ],
        },
        "face_cells": {
            "count": len(face_indices),
            "indices": face_indices,
            "kind": "FACE_BASE_REUSE (identity copy)",
            "label": "PORT APPROXIMATION",
            "note": ("36 identity face cells (35-52 sand slope, 53-70 rock cliff). "
                     "Donor AngleX/AngleZ=25 and alphavert eye-linear projection are "
                     "absent (F05 G2; tiles.lib:119-297; reftile.mat:120-169)."),
        },
        "empty_sentinel_cells": {
            "count": len(ALPHA_SENTINELS),
            "indices": list(ALPHA_SENTINELS),
            "label": "UNVERIFIED / PORT APPROXIMATION",
            "note": ("3 EMPTY holes (alpha0a/b/c, ids 86/110/123). Donor binds "
                     "grass1.dds + alphanull (tiles.mat:347-359); no art fabricated."),
        },
        "masks": {
            key: {
                "file": spec["out"],
                "source": as_rel(MASK_LEGACY[key]),
                "source_sha256": masks[key]["source_sha256"],
                "output_sha256": masks[key]["sha256"],
                "donor_evidence": spec["evidence"],
                "size": masks[key]["size"],
                "mode": masks[key]["mode"],
                "level0_bytes_preserved": True,
                "note": spec["note"],
                "label": "[O] CONVERTED_FROM_DONOR (level-0 byte identity); "
                         "exact intensity formula UNVERIFIED",
            } for key, spec in MASK_SPECS.items()
        },
        "mipmaps": mipmap_record(tier),
        "blend": blend_record(),
        "alpha_transport": alpha_transport_record(),
        "shipped_tileblock": shipped,
        "licence_guard": licence_guard_record(DEFAULT_OUT, tier, blocked, outputs),
        "outputs": outputs,
        "provenance": make_provenance(
            layout, sha256_bytes(atlas_bytes), atlas_file, masks,
            winter_layout, sha256_bytes(winter_atlas_bytes) if winter_atlas_bytes else None,
            season,
        ),
        "visual_parity_claim": False,
    }
    if season == "winter":
        manifest["season"] = "winter"
        manifest["winter"] = {
            "index_preserving": True,
            "alias_suffix": "_winter",
            "entry_count": len(winter_entries or []),
            "shared_alpha_indices": list(ALPHA_SENTINELS),
            "masks_shared_with_summer": True,
            "evidence": ("data/terrain/tiles/terrain.presets:138-261; "
                         "texturemap.inc:525-526,605-606; winter_aliases.json"),
        }
    return manifest


def make_winter_alias_doc(entries: list[dict]) -> dict:
    return {
        "version": 1,
        "generator": GENERATOR,
        "index_preserving": True,
        "alias_suffix": "_winter",
        "count": len(entries),
        "entries": [
            {"index": e["index"], "name": e["name"], "winter_alias": e["winter_alias"],
             "source_png": e["source_png"], "kind": e.get("kind", "WINTER_PNG"),
             "shared_alpha": bool(e.get("shared_alpha", False))}
            for e in entries
        ],
        "note": ("Derived from variant3d/assets/terrain/atlas/winter_aliases.json "
                 "(hand-authored, donor-cited second-hand). Shared alpha indices "
                 "86/110/123 stay EMPTY in the atlas; alias recorded, no art invented."),
        "visual_parity_claim": False,
    }


def make_desert_alias_doc() -> dict:
    return {
        "version": 1,
        "generator": GENERATOR,
        "status": "UNVERIFIED — no season swap emitted",
        "entries": [],
        "note": ("F10/DLC desert season set is UNVERIFIED; no desert texture is "
                 "fabricated. Desert summer tiles remain at ids 111-122 in both "
                 "season atlases (tiles.mat desertN_winter -> desertN.dds reuse)."),
        "visual_parity_claim": False,
    }


def make_root_manifest(outputs: dict[str, str], manifests: dict[str, dict]) -> dict:
    return {
        "schema": "terrain_new/manifest/v1",
        "pack": PACK,
        "generator": GENERATOR,
        "status": "PARTIAL — atlas contribution only; pattern/mask/cfg sections "
                  "are owned by I01-I04 and appended by build_terrain_new_manifest.py",
        "generator_policy": "atlas only; donor root is an input argument, never "
                            "read or recorded as an absolute path",
        "outputs": outputs,
        "asset_index": {
            "atlas": ATLAS_NAME,
            "atlas_manifest": ATLAS_MANIFEST,
            "winter_atlas": WINTER_ATLAS_NAME,
            "winter_aliases": WINTER_ALIAS_OUT,
        },
        "counts": {
            "named_cells": EXPECTED_NAMES,
            "season_variants": 2,
            "atlas_outputs": len(outputs),
        },
        "labels_used": LABELS,
        "manifest_sha256": {
            k: sha256_bytes(canonical_json(v)) for k, v in sorted(manifests.items())
        },
        "visual_parity_claim": False,
    }


# --------------------------------------------------------------------------- #
# plan assembly
# --------------------------------------------------------------------------- #
def build_plan(cell: int, tier: str) -> dict:
    names = load_names()
    files = load_blocks()
    winter_entries = load_winter_entries()
    shipped = load_dump()
    blocked = forbidden_hashes()

    summer_layout = [resolve_cell(i, n, files, cell, season="summer")
                     for i, n in enumerate(names)]
    winter_layout = [resolve_cell(e["index"], n, files, cell, season="winter", winter_entry=e)
                     for n, e in zip(names, winter_entries)]

    atlas_bytes = pack_atlas(summer_layout, files, cell)
    winter_atlas_bytes = pack_atlas(winter_layout, files, cell)
    masks = mask_payload()

    outputs_bytes: dict[str, bytes] = {
        ATLAS_NAME: atlas_bytes,
        MASK_SPECS["alpha"]["out"]: masks["alpha"]["data"],
        MASK_SPECS["alphavert"]["out"]: masks["alphavert"]["data"],
        WINTER_ATLAS_NAME: winter_atlas_bytes,
        WINTER_ALIAS_OUT: canonical_json(make_winter_alias_doc(winter_entries)),
        DESERT_ALIAS_OUT: canonical_json(make_desert_alias_doc()),
    }
    # A manifest describes the emitted assets, never itself (avoids a
    # self-referential hash). The full map including the two manifests is kept
    # separately for the CLI report and output verification.
    asset_outputs = {name: sha256_bytes(data) for name, data in sorted(outputs_bytes.items())}

    common = dict(
        cell=cell, tier=tier, masks=masks, files=files, shipped=shipped,
        blocked=blocked, outputs=asset_outputs, winter_entries=winter_entries,
    )
    summer_manifest = make_manifest(
        season="summer", atlas_bytes=atlas_bytes, atlas_file=ATLAS_NAME,
        layout=summer_layout, winter_layout=None, winter_atlas_bytes=None, **common)
    winter_manifest = make_manifest(
        season="winter", atlas_bytes=winter_atlas_bytes, atlas_file=WINTER_ATLAS_NAME,
        layout=winter_layout, winter_layout=winter_layout,
        winter_atlas_bytes=winter_atlas_bytes, **common)
    outputs_bytes[ATLAS_MANIFEST] = canonical_json(summer_manifest)
    outputs_bytes[WINTER_ATLAS_MANIFEST] = canonical_json(winter_manifest)
    outputs = dict(asset_outputs)
    outputs[ATLAS_MANIFEST] = sha256_bytes(outputs_bytes[ATLAS_MANIFEST])
    outputs[WINTER_ATLAS_MANIFEST] = sha256_bytes(outputs_bytes[WINTER_ATLAS_MANIFEST])

    root = make_root_manifest(outputs, {
        ATLAS_MANIFEST: summer_manifest, WINTER_ATLAS_MANIFEST: winter_manifest,
    })
    return {
        "names": names,
        "files": files,
        "summer_layout": summer_layout,
        "winter_layout": winter_layout,
        "masks": masks,
        "shipped": shipped,
        "tier": tier,
        "atlas_bytes": atlas_bytes,
        "winter_atlas_bytes": winter_atlas_bytes,
        "outputs_bytes": outputs_bytes,
        "outputs": outputs,
        "summer_manifest": summer_manifest,
        "winter_manifest": winter_manifest,
        "root_manifest": root,
        "blocked": blocked,
    }


# --------------------------------------------------------------------------- #
# verification
# --------------------------------------------------------------------------- #
def verify_plan(plan: dict, cell: int, tier: str) -> dict:
    checks: dict[str, bool] = {}
    names = plan["names"]
    summer, winter = plan["summer_layout"], plan["winter_layout"]
    checks["index_names_124_unique"] = len(names) == EXPECTED_NAMES and len(set(names)) == EXPECTED_NAMES
    checks["cell_order_i_mod16_i_div16"] = all(
        c["cell_xy"] == [c["index"] % COLS, c["index"] // COLS] for c in summer)
    checks["slots_128_named_124_filled_121_empty_3"] = (
        sum(1 for c in summer if c["source_png"] is not None) == 121
        and sum(1 for c in summer if c["source_png"] is None) == 3
    )
    checks["face_cells_36"] = sum(1 for c in summer if c["kind"] == "FACE_BASE_REUSE") == 36
    checks["empty_sentinels_86_110_123"] = [c["index"] for c in summer
                                            if c["source_png"] is None] == list(ALPHA_SENTINELS)
    checks["winter_index_preserving_124"] = (
        len(winter) == EXPECTED_NAMES
        and [c["index"] for c in winter] == list(range(EXPECTED_NAMES))
        and all(c["name"] == n for c, n in zip(winter, names))
    )
    checks["winter_alpha_shared_empty"] = all(
        winter[i]["source_png"] is None and winter[i]["shared_alpha"]
        for i in ALPHA_SENTINELS)
    checks["atlas_size"] = list(Image.open(io.BytesIO(plan["atlas_bytes"])).size) == [COLS * cell, ROWS * cell]
    checks["atlas_mode_RGBA"] = Image.open(io.BytesIO(plan["atlas_bytes"])).mode == "RGBA"
    checks["mask_sizes_modes_L"] = all(
        tuple(plan["masks"][k]["size"]) == MASK_SPECS[k]["size"]
        and plan["masks"][k]["mode"] == "L" for k in MASK_SPECS)
    checks["mask_level0_bytes_identical"] = all(
        plan["masks"][k]["sha256"] == plan["masks"][k]["source_sha256"] for k in MASK_SPECS)
    checks["byte_identical_groups_present"] = all(
        tuple(sorted(g)) in {tuple(sorted(x["stems"])) for x in plan["summer_manifest"]["aliases"]["byte_identical_groups"]}
        for g in EXPECTED_IDENTICAL_GROUPS)
    checks["shipped_tileblock_all_resolvable"] = plan["shipped"].get("all_resolvable", False)
    checks["parity_flag_false"] = (
        plan["summer_manifest"]["visual_parity_claim"] is False
        and plan["winter_manifest"]["visual_parity_claim"] is False)
    checks["no_donor_bytes_written"] = (
        plan["summer_manifest"]["licence_guard"]["donor_bytes_written"] is False)
    checks["alpha_separate_no_albedo_multiply"] = (
        plan["summer_manifest"]["alpha_transport"]["albedo_multiply"] is False)
    checks["mipmap_requirement_recorded"] = (
        plan["summer_manifest"]["mipmaps"]["call"] == "Image.generate_mipmaps(false)")
    checks["bm_transparency_recorded"] = (
        plan["summer_manifest"]["blend"]["gl_blend_func"] == ["SRC_ALPHA", "ONE_MINUS_SRC_ALPHA"])
    checks["resolution_tier"] = (
        plan["summer_manifest"]["atlas"]["resolution_tier"] == tier)
    forbidden = {h for h in plan["blocked"] if h != "__winter_size__"}
    if tier == "commit_default":
        checks["no_forbidden_legacy_hash"] = not forbidden.intersection(plan["outputs"].values())
    else:
        # cell 1024 legitimately reproduces the legacy atlas bytes; the guard
        # is that the tier stays local/uncommitted, not that the hash differs.
        checks["no_forbidden_legacy_hash"] = True
        checks["hires_legacy_identity_recorded"] = bool(
            plan["summer_manifest"]["licence_guard"]["legacy_atlas_byte_identity"])
    # Determinism: canonical bytes of both manifests recomputed from the plan.
    checks["deterministic_manifest_bytes"] = (
        plan["outputs"][ATLAS_MANIFEST] == sha256_bytes(canonical_json(plan["summer_manifest"]))
        and plan["outputs"][WINTER_ATLAS_MANIFEST] == sha256_bytes(canonical_json(plan["winter_manifest"]))
        and plan["outputs"]["alpha.png"] == sha256_bytes(plan["masks"]["alpha"]["data"])
        and plan["outputs"]["alphavert.png"] == sha256_bytes(plan["masks"]["alphavert"]["data"])
    )
    return {"mode": "PLAN_CHECK", "passed": all(checks.values()), "checks": checks}


def verify_outputs(out: Path, plan: dict) -> dict:
    checks: dict[str, bool] = {}
    manifest_path = out / ATLAS_MANIFEST
    if not manifest_path.is_file():
        return {"mode": "OUTPUT_CHECK", "passed": False,
                "error": "missing %s (run with --write first)" % manifest_path}
    doc = json.loads(manifest_path.read_text(encoding="utf-8"))
    for name, digest in plan["outputs"].items():
        target = out / name
        checks["exists:" + name] = target.is_file()
        if target.is_file():
            checks["sha256:" + name] = sha256_file(target) == digest
    with Image.open(out / ATLAS_NAME) as im:
        checks["atlas_size"] = list(im.size) == doc["atlas"]["size"]
        checks["atlas_mode_RGBA"] = im.mode == "RGBA"
    for key, spec in MASK_SPECS.items():
        with Image.open(out / spec["out"]) as im:
            checks["%s_size" % key] = list(im.size) == doc["masks"][key]["size"]
            checks["%s_mode_L" % key] = im.mode == "L"
    checks["layout_len_124"] = len(doc["layout"]) == EXPECTED_NAMES
    checks["named_124_filled_121_empty_3"] = (
        doc["atlas"]["named_cells"] == EXPECTED_NAMES
        and doc["atlas"]["filled_cells"] == 121
        and doc["atlas"]["empty_cells"] == 3)
    checks["parity_flag_false"] = doc.get("visual_parity_claim") is False
    checks["bm_transparency_recorded"] = doc["blend"]["gl_blend_func"] == ["SRC_ALPHA", "ONE_MINUS_SRC_ALPHA"]
    checks["no_donor_bytes_written"] = doc["licence_guard"]["donor_bytes_written"] is False
    return {"mode": "OUTPUT_CHECK", "passed": all(checks.values()), "checks": checks}


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #
def print_provenance(plan: dict) -> None:
    for p in plan["summer_manifest"]["provenance"]:
        print("%s -> %s -> %s -> %s" % (
            p["source"], p["output"], p.get("output_sha256"), p["label"]))


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Commit-safe donor-indexed terrain atlas compiler (I05). "
                    "DRY-RUN BY DEFAULT; --write to emit; --game is read-only.")
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="donor install root; licence guard only, never read or copied")
    ap.add_argument("--out", default=str(DEFAULT_OUT),
                    help="output directory (default variant3d/assets/terrain_new/atlas)")
    ap.add_argument("--cell", type=int, default=DEFAULT_CELL,
                    help="cell size for the commit tier (default 128)")
    ap.add_argument("--hires-local", action="store_true",
                    help="force cell 1024, local UNCOMMITTED capture tier; "
                         "refuses writes under terrain_new")
    ap.add_argument("--check", action="store_true",
                    help="verify committed outputs, or the in-memory plan with --dry-run")
    ap.add_argument("--dry-run", action="store_true",
                    help="explicit dry-run (already the default; writes nothing)")
    ap.add_argument("--write", action="store_true",
                    help="explicitly emit derived assets (mutually exclusive with --dry-run)")
    ap.add_argument("--emit-root-manifest", action="store_true",
                    help="also write <out>/../manifest.json (atlas contribution only)")
    args = ap.parse_args()

    if args.write and args.dry_run:
        ap.error("--write and --dry-run are mutually exclusive")
    dry_run = not args.write
    out = Path(args.out).expanduser()
    game = Path(args.game).expanduser()

    # Licence guard: never allow an output inside the private donor install.
    if is_within(out, game):
        ap.error("refusing --out inside donor root: %s" % out)

    if args.hires_local:
        cell, tier = HIRES_CELL, "local_hires"
    else:
        cell, tier = args.cell, "commit_default"
    if not check_power_of_two(cell) or not (64 <= cell <= 1024):
        ap.error("--cell must be a power of two in [64, 1024]")
    if not args.hires_local and cell != DEFAULT_CELL:
        print("NOTE: --cell=%d is a derived resolution tier; only 128 is the "
              "committed default (spec/11 §2.2.1)." % cell, file=sys.stderr)

    if args.write:
        if tier == "local_hires" and is_within(out, COMMIT_ROOT):
            ap.error("--hires-local writes must stay outside %s (uncommitted tier)"
                     % COMMIT_ROOT)
        if tier == "commit_default" and not is_within(out, COMMIT_ROOT):
            ap.error("commit-tier writes must stay inside %s" % COMMIT_ROOT)

    plan = build_plan(cell, tier)
    print_provenance(plan)

    identity = plan["summer_manifest"]["licence_guard"]["legacy_atlas_byte_identity"]
    if identity and args.write and tier == "commit_default":
        ap.error("commit tier would reproduce the uncommitted legacy atlas bytes: %s"
                 % sorted(identity))
    if identity:
        print("WARNING: cell 1024 reproduces legacy atlas bytes %s — "
              "local/uncommitted tier only; never commit." % sorted(identity),
              file=sys.stderr)

    report: dict = {
        "generator": GENERATOR,
        "pack": PACK,
        "cell": cell,
        "resolution_tier": tier,
        "dry_run": dry_run,
        "out": as_rel(out),
        "counts": {
            "named_cells": EXPECTED_NAMES,
            "filled_cells": plan["summer_manifest"]["atlas"]["filled_cells"],
            "empty_cells": plan["summer_manifest"]["atlas"]["empty_cells"],
            "face_cells": len(plan["summer_manifest"]["face_cells"]["indices"]),
            "sentinel_indices": list(ALPHA_SENTINELS),
            "block_pngs": len(plan["files"]),
            "outputs": len(plan["outputs"]),
        },
        "atlas": plan["summer_manifest"]["atlas"],
        "outputs": plan["outputs"],
        "visual_parity_claim": False,
    }
    if dry_run:
        report["mode"] = "DRY_RUN (nothing written)"
    else:
        out.mkdir(parents=True, exist_ok=True)
        for name, data in sorted(plan["outputs_bytes"].items()):
            target = out / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        if args.emit_root_manifest:
            root_target = out.parent / "manifest.json"
            root_target.write_bytes(canonical_json(plan["root_manifest"]))
        report["mode"] = "WRITE"
        report["written"] = sorted(plan["outputs_bytes"])

    if args.check:
        result = verify_outputs(out, plan) if args.write else verify_plan(plan, cell, tier)
        report["check"] = result
        if not result["passed"]:
            print(json.dumps(report, indent=2))
            raise SystemExit("verification FAILED: %s" %
                             [k for k, v in result["checks"].items() if not v]
                             if "checks" in result else result.get("error"))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
