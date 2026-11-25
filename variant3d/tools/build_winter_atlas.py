"""Build the index-preserving Winter tile atlas and its manifest (SP-4).

ASSET-ONLY. This tool never edits a .gd/.gdshader/config/test file, never
opens, reads or copies a donor file, and never touches git state. It writes
exactly two NEW files under ``variant3d/assets/terrain/atlas/``:

  * ``tile_index_atlas_winter.png``          16384x8192 RGBA, 16x8 x 1024^2 cells
  * ``tile_index_atlas_winter.manifest.json``  same schema as the Summer manifest

It consumes only already-converted port data, all read-only:

  * ``atlas/winter_aliases.json``   SP-2's 124-entry alias dictionary (indices
    0-123, identical to ``structs/presets_summer.json``). Every `source_png`
    resolves to an already-converted PNG in ``assets/terrain/blocks/``.
  * ``atlas/tile_index_atlas.manifest.json``  the observed Summer manifest:
    grid, cell_size, size, slots, masks, EMPTY-cell status text, packing label
    and shipped-tile histogram are taken from it, not guessed here.
  * ``app/shots/g32_dump.json``  the same dump the Summer builder measures.

Donor grounding is SECOND-HAND ONLY, cited via SP-2 / DENV-01 / SEASON-PLAN-01,
which read the donor read-only in earlier passes (the donor is NOT opened here):

  * ``data/terrain/tiles/terrain.presets:134-263`` Winter 124-entry section,
    one-for-one rename at the same preset index (SP-2 section 3; DENV-01 3.3).
  * ``data/scripts/common.inc/texturemap.inc:525-526,605-606`` appends the
    ``_winter`` suffix for GetSeasonType=2 (SP-2 section 3; DENV-01 4).
  * ``data/terrain/tiles/tiles.mat`` resolves the 124 aliases to 23 winter
    textures plus 12 unchanged desert textures (SP-2 sections 3 and 6).
  * ``data/terrain/ref/reftile.lib:3-12`` donor packing is engine-side: the
    16x8 uniform grid is APPROX_ATLAS_PACKING, and the two alpha masks are
    shared unchanged (no donor BMP is read or re-converted by this tool).

Index-preserving swap: cell i always means preset index i, so the shader's
``floor(abs(tile))`` alpha-patch rule needs NO edit (SEASON-PLAN-01 B4/B5).
The three alpha carriers (SP-2 `shared_alpha: true`, indices 86/110/123) stay
EMPTY and transparent exactly as in the Summer atlas — SP-2 records their
`source_png` as a donor alias carrier only, not as shipped art. The four
donor-unaliased PNGs (winter18/23/24/26) are never packed and are listed in
`unused_shipped_blocks`; no replacement art is invented.

NO VISUAL PARITY CLAIM: no donor read and no GPU A/B were performed here.
"""
from __future__ import annotations

import argparse
import base64
import hashlib
import json
import time
from collections import Counter
from pathlib import Path

from PIL import Image

# A 16x8 grid of 1024x1024 RGBA cells is 134,217,728 px, above Pillow's
# default decompression-bomb warning. We allocate the buffer ourselves and
# only decode already-converted port PNGs, never untrusted data.
Image.MAX_IMAGE_PIXELS = None

ROOT = Path(__file__).resolve().parents[2]
TERRAIN = ROOT / "variant3d" / "assets" / "terrain"
ATLAS = TERRAIN / "atlas"
BLOCKS = TERRAIN / "blocks"
SUMMER_MANIFEST = ATLAS / "tile_index_atlas.manifest.json"
WINTER_ALIASES = ATLAS / "winter_aliases.json"
PRESETS_SUMMER = TERRAIN / "structs" / "presets_summer.json"
DUMP = ROOT / "app" / "shots" / "g32_dump.json"

ATLAS_NAME = "tile_index_atlas_winter.png"
MANIFEST_NAME = "tile_index_atlas_winter.manifest.json"
EXPECTED_NAMES = 124

LABELS = [
    "DONOR_INDEX_CITED_SECOND_HAND",
    "DONOR_ART_ALIAS_CITED_SECOND_HAND",
    "APPROX_ATLAS_PACKING",
    "APPROX_ALPHA_INTENSITY_FORMULA",
    "UNVERIFIED_EMPTY_CELLS",
    "UNVERIFIED_ALPHA_SUBRECT_MAPPING",
    "NO_VISUAL_PARITY_CLAIM",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def json_read(path: Path):
    return json.loads(path.read_text("utf-8"))


def alias_line_range() -> str:
    """Line span of winter_aliases.json `entries`, read from the file itself."""
    lines = WINTER_ALIASES.read_text("utf-8").splitlines()
    start = next(i for i, line in enumerate(lines, 1) if '"entries": [' in line)
    end = next(i for i in range(start + 1, len(lines) + 1)
               if lines[i - 1].strip() == "],")
    return "%d-%d" % (start + 1, end - 1)


def shipped_ids() -> dict:
    """Same histogram contract as the Summer builder; indices are unchanged."""
    if not DUMP.is_file():
        return {"status": "UNVERIFIED", "note": "app/shots/g32_dump.json missing"}
    raw = base64.b64decode(json_read(DUMP)["tileblock"])
    hist = Counter(raw)
    return {
        "source": "app/shots/g32_dump.json:1 (key 'tileblock', base64 uint8)",
        "bytes": len(raw),
        "distinct_ids": len(hist),
        "min_id": min(hist),
        "max_id": max(hist),
        "histogram": {str(k): hist[k] for k in sorted(hist)},
        "unresolved_ids": sorted(i for i in hist if i >= EXPECTED_NAMES),
        "all_resolvable": all(i < EXPECTED_NAMES for i in hist),
        "top_ids": [[k, v] for k, v in hist.most_common(5)],
    }


def load_inputs() -> tuple[dict, dict, list, list, list[int], list[int], int, int]:
    summer = json_read(SUMMER_MANIFEST)
    aliases = json_read(WINTER_ALIASES)
    entries = aliases["entries"]
    names = json_read(PRESETS_SUMMER)
    if len(entries) != EXPECTED_NAMES or len(names) != EXPECTED_NAMES:
        raise AssertionError("expected 124 entries / 124 names")
    if [e["index"] for e in entries] != list(range(EXPECTED_NAMES)):
        raise AssertionError("winter_aliases.json indices are not 0..123 contiguous")
    if [e["name"] for e in entries] != names:
        raise AssertionError("winter alias names differ from presets_summer.json")

    s_atlas = summer["atlas"]
    grid, cell_size = s_atlas["grid"], s_atlas["cell_size"]
    cols, rows = grid
    cw, ch = cell_size
    if (cols, rows, cw, ch) != (16, 8, 1024, 1024):
        raise AssertionError("unexpected Summer manifest geometry: %r %r" %
                             (grid, cell_size))
    if s_atlas["size"] != [cols * cw, rows * ch] or s_atlas["slots"] != cols * rows:
        raise AssertionError("Summer manifest size/slots disagree with grid")

    # SP-2's shared-alpha flags must equal the Summer manifest's EMPTY cells.
    shared = sorted(e["index"] for e in entries if e.get("shared_alpha"))
    summer_empty = sorted(c["index"] for c in summer["layout"] if c["kind"] == "EMPTY")
    if shared != summer_empty:
        raise AssertionError("SP-2 shared_alpha %r != Summer EMPTY cells %r" %
                             (shared, summer_empty))

    return summer, aliases, entries, names, shared, summer_empty, cols, cw


def build(summer: dict, entries: list[dict], shared: list[int],
          cols: int, cw: int) -> tuple[dict, dict]:
    grid = summer["atlas"]["grid"]
    cell_size = summer["atlas"]["cell_size"]
    rows, ch = grid[1], cell_size[1]
    empty_status = next(c["status"] for c in summer["layout"] if c["kind"] == "EMPTY")
    atlas = Image.new("RGBA", (cols * cw, rows * ch), (0, 0, 0, 0))
    layout: list[dict] = []
    first_use: dict[str, int] = {}
    used: set[str] = set()
    cache: dict[str, Image.Image] = {}
    shared_set = set(shared)

    for e in entries:
        idx = e["index"]
        cx, cy = idx % cols, idx // cols
        cell = {"index": idx, "name": e["name"], "cell_xy": [cx, cy],
                "cell_px": [cx * cw, cy * ch, cw, ch]}
        if idx in shared_set:
            # No shipped art and no fabricated replacement: SP-2 records these
            # as shared-alpha carriers only. Keep the Summer EMPTY semantics.
            cell.update(source_png=None, kind="EMPTY", donor_evidence=None,
                        status=empty_status, source_size=None, upscaled=False)
        else:
            src_name = e["source_png"]
            src = BLOCKS / src_name
            if not src.is_file():
                raise FileNotFoundError("missing converted port PNG: %s" % src)
            if src_name not in cache:
                im = Image.open(src)
                if im.size != (cw, ch):
                    raise AssertionError("%s is %r, expected (%d, %d)" %
                                         (src_name, im.size, cw, ch))
                cache[src_name] = im.convert("RGB")
            first = first_use.setdefault(src_name, idx)
            kind = "DIRECT" if first == idx else "FACE_BASE_REUSE"
            used.add(src_name)
            cell.update(
                source_png=src_name,
                kind=kind,
                donor_evidence=(
                    "winter_aliases.json:%d (%s -> %s; %s; indices identical to "
                    "presets_summer.json; donor terrain.presets:134-263 / "
                    "texturemap.inc:525-526 via SP-2/DENV-01)" %
                    (idx, e["winter_alias"], src_name, e["kind"])),
                status="OK",
                upscaled=False,
                source_size=[cw, ch],
                source_sha256=sha256(src),
            )
            x, y, w, h = cell["cell_px"]
            atlas.paste(cache[src_name], (x, y, x + w, y + h))
        layout.append(cell)

    for im in cache.values():
        im.close()
    atlas.save(ATLAS / ATLAS_NAME, format="PNG", compress_level=6)
    atlas.close()

    unused = sorted(p.name for p in BLOCKS.glob("*.png") if p.name not in used)
    unused_winter = sorted(n for n in unused if n.startswith("winter"))
    note = (
        "%d on-disk block PNGs are not selected by the Winter alias dictionary: "
        "%d donor-unaliased winter PNGs deliberately unmapped (%s — no tiles.mat "
        "alias, no replacement invented, SP-2 sections 6-7 / SEASON-PLAN-01 Q1/B1) "
        "and %d summer-only PNGs not referenced by any Winter alias. The three "
        "shared-alpha carriers (indices 86/110/123) stay EMPTY: their SP-2 "
        "source_png values are donor alias carriers only, not shipped art."
    ) % (len(unused), len(unused_winter), ", ".join(unused_winter),
         len(unused) - len(unused_winter))

    s_atlas = summer["atlas"]
    manifest = {
        "version": 1,
        "generator": "variant3d/tools/build_winter_atlas.py",
        "labels": LABELS,
        "atlas": {
            "file": ATLAS_NAME,
            "size": list(s_atlas["size"]),
            "cell_size": list(cell_size),
            "grid": list(grid),
            "slots": s_atlas["slots"],
            "named_cells": len(layout),
            "filled_cells": sum(1 for c in layout if c["source_png"] is not None),
            "empty_cells": sum(1 for c in layout if c["source_png"] is None),
            "upscaled_sources": [],
            "packing_label": s_atlas["packing_label"],
        },
        "index_dictionary": {
            "file": "variant3d/assets/terrain/atlas/winter_aliases.json",
            "lines": alias_line_range(),
            "count": len(layout),
            "donor_evidence": (
                "data/terrain/tiles/terrain.presets:134-263 (Winter 124-entry "
                "section, one-for-one rename); indices identical to "
                "presets_summer.json:2-125 / terrain.presets:2-6. Alias rule: "
                "texturemap.inc:525-526,605-606 (SP-2 / DENV-01, second-hand)"),
        },
        "layout": layout,
        "unused_shipped_blocks": unused,
        "unused_note": note,
        "masks": json.loads(json.dumps(summer["masks"])),  # shared, unchanged
        "shipped_tileblock": shipped_ids(),
        "visual_parity_claim": False,
    }
    (ATLAS / MANIFEST_NAME).write_text(
        json.dumps(manifest, indent=1, ensure_ascii=False), encoding="utf-8")
    return manifest, {"unused_winter": unused_winter, "unused_count": len(unused)}


def verify(manifest: dict, extra: dict) -> dict:
    checks: dict[str, bool] = {}
    png = ATLAS / ATLAS_NAME
    checks["png_exists"] = png.is_file()
    with Image.open(png) as im:
        checks["png_size_16384x8192"] = im.size == tuple(manifest["atlas"]["size"])
        checks["png_mode_RGBA"] = im.mode == "RGBA"
        layout = manifest["layout"]
        checks["layout_len_124"] = len(layout) == EXPECTED_NAMES
        checks["indices_0_to_123"] = [c["index"] for c in layout] == list(range(124))
        checks["cell_xy_and_px"] = all(
            c["cell_xy"] == [c["index"] % 16, c["index"] // 16] and
            c["cell_px"] == [c["cell_xy"][0] * 1024, c["cell_xy"][1] * 1024, 1024, 1024]
            for c in layout)
        checks["counts_124_121_3"] = (
            manifest["atlas"]["named_cells"] == 124 and
            manifest["atlas"]["filled_cells"] == 121 and
            manifest["atlas"]["empty_cells"] == 3)
        checks["empty_indices_86_110_123"] = [
            c["index"] for c in layout if c["source_png"] is None] == [86, 110, 123]
        checks["all_source_pngs_exist"] = all(
            (BLOCKS / c["source_png"]).is_file()
            for c in layout if c["source_png"] is not None)
        checks["no_upscaled_cells"] = not any(c["upscaled"] for c in layout)

        # Full pixel-byte check (stronger than the required 5-cell spot check):
        # every filled cell's RGB bytes must equal its source PNG's RGB bytes,
        # with alpha forced to 255; every EMPTY cell must be fully transparent.
        cache: dict[str, bytes] = {}
        pixel_fail: list[int] = []
        for c in layout:
            x, y, w, h = c["cell_px"]
            cell = im.crop((x, y, x + w, y + h))
            if c["source_png"] is None:
                if cell.getchannel("A").getextrema() != (0, 0) or \
                        not all(ch == (0, 0)
                                for ch in cell.convert("RGB").getextrema()):
                    pixel_fail.append(c["index"])
            else:
                name = c["source_png"]
                if name not in cache:
                    with Image.open(BLOCKS / name) as src:
                        cache[name] = src.convert("RGB").tobytes()
                if cell.convert("RGB").tobytes() != cache[name] or \
                        cell.getchannel("A").getextrema() != (255, 255):
                    pixel_fail.append(c["index"])
            cell.close()
        checks["all_cell_pixel_bytes_match_sources"] = not pixel_fail
        checks["all_4_unmapped_winter_listed"] = all(
            n in manifest["unused_shipped_blocks"]
            for n in ("winter18.png", "winter23.png", "winter24.png", "winter26.png"))
        checks["no_unmapped_winter_packed"] = all(
            c["source_png"] not in ("winter18.png", "winter23.png",
                                    "winter24.png", "winter26.png")
            for c in layout)
        checks["masks_shared_schema"] = set(manifest["masks"]) == {"alpha", "alphavert"}
        checks["shipped_ids_resolvable"] = manifest["shipped_tileblock"].get(
            "all_resolvable", False)
        checks["visual_parity_false"] = manifest["visual_parity_claim"] is False
    failed = [k for k, v in checks.items() if not v]
    if failed:
        raise AssertionError("verification failed: %s" % failed)
    return {"checks": checks, "passed": True, "pixel_failures": pixel_fail}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="verify existing outputs without rebuilding")
    args = ap.parse_args()
    t0 = time.perf_counter()

    if args.check:
        manifest = json_read(ATLAS / MANIFEST_NAME)
        print(json.dumps({"verify": verify(manifest, {}),
                          "build_seconds": round(time.perf_counter() - t0, 3)},
                         indent=2))
        return

    summer, _aliases, entries, _names, shared, _empty, cols, cw = load_inputs()
    manifest, extra = build(summer, entries, shared, cols, cw)
    result = verify(manifest, extra)
    png = ATLAS / ATLAS_NAME
    print(json.dumps({
        "atlas": str(png),
        "atlas_bytes": png.stat().st_size,
        "atlas_sha256": sha256(png),
        "manifest": str(ATLAS / MANIFEST_NAME),
        "manifest_bytes": (ATLAS / MANIFEST_NAME).stat().st_size,
        "manifest_sha256": sha256(ATLAS / MANIFEST_NAME),
        "atlas_block": manifest["atlas"],
        "source_pngs_resolved": len({c["source_png"] for c in manifest["layout"]
                                     if c["source_png"]}),
        "unused_block_pngs": extra["unused_count"],
        "unmapped_winter_pngs": extra["unused_winter"],
        "empty_cells": [c["name"] for c in manifest["layout"]
                        if c["source_png"] is None],
        "verify": result,
        "build_seconds": round(time.perf_counter() - t0, 3),
    }, indent=2))


if __name__ == "__main__":
    main()
