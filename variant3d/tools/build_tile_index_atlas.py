"""Build the donor-indexed terrain tile atlas and the two runtime alpha masks.

This tool is ASSET-ONLY. It never edits .gd files, the splat bake, app/, config,
tests or git state. It writes four files, all under
``variant3d/assets/terrain/atlas/``:

  * ``tile_index_atlas.png``          one uniform 1024x1024 cell per preset name
  * ``tile_index_atlas.manifest.json`` cell layout + provenance + verification
  * ``alpha.png``                     8-bit intensity, 512x256  (from donor BMP)
  * ``alphavert.png``                 8-bit intensity, 1024x512 (from donor BMP)

Donor grounding (read-only, latin-1 text + byte headers only):

  * ``data/terrain/tiles/terrain.presets:2-6``  Summer set, DefaultIndex=0,
    first TileBlock = grass1; the shipped JSON mirror is
    ``variant3d/assets/terrain/structs/presets_summer.json:2-125`` (124 names,
    array element i == donor preset index i). The index dictionary is therefore
    read from shipped data, never invented here.
  * ``data/terrain/tiles/tiles.mat:142-148,206-220`` rock1vf/vs bind rock1.dds
    and sand1f/s bind sand1.dds. Face preset entries with no own PNG are filled
    from their base block PNG -- this mapping is donor text, not a guess.
  * ``data/terrain/ref/reftilealpha.mat:30-37`` alpha.bmp,
    imagealpha=tiaAlphaFromIntensity, textureformat=tfAlpha -> intensity PNG.
  * ``data/terrain/ref/reftilealpha.mat:139-146`` alphavert.bmp, same settings.
  * ``data/terrain/ref/reftile.mat:120-169`` face refkeys use alphavert with
    TextureScale=0.125 and eye-linear S/T; this tool exports the WHOLE donor
    mask atlas and does NOT invent a cell<->tile sub-rect mapping (that math is
    engine-side / commented out in reftile.lib:7-11).

Labels carried in the manifest:

  * DONOR_INDEX / DONOR_ART -- index order and source pixels come from donor
    data already shipped in the repo.
  * APPROX_ATLAS_PACKING -- uniform 16x8 cell grid; donor tsDouble/ttExtended
    packing is engine-side (reftile.lib:3-12) and UNVERIFIED.
  * APPROX_SAND_UPSCALE -- sand1/sand2 ship at 256x256 (tiles.lib:53-63) and
    are replicated to 1024x1024 with NEAREST so no new texel value is invented.
  * UNVERIFIED -- preset names with no shipped PNG (alpha0a/alpha0b/alpha0c)
    get transparent EMPTY cells; no art is fabricated. A donor mask that cannot
    be read is omitted with an explicit UNVERIFIED note, never synthesized.

Usage (from the project root):

  python variant3d/tools/build_tile_index_atlas.py
  python variant3d/tools/build_tile_index_atlas.py --check
  python variant3d/tools/build_tile_index_atlas.py --game "C:\\Games\\Cossacks 3"

The donor root defaults to $COSSACKS3_DIR or C:\\Games\\Cossacks 3 and is only
ever read. Donor files are private use and are never copied into the repo
verbatim; only converted PNGs are emitted.
"""
from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import re
import struct
import sys
from collections import Counter
from pathlib import Path

from PIL import Image

# Raised deliberately: a 16x8 grid of 1024x1024 RGBA cells is 134,217,728 px,
# above Pillow's default decompression-bomb warning threshold. We allocate the
# buffer ourselves; no untrusted image is opened at that size.
Image.MAX_IMAGE_PIXELS = None

ROOT = Path(__file__).resolve().parents[2]
PRESETS = ROOT / "variant3d" / "assets" / "terrain" / "structs" / "presets_summer.json"
BLOCKS = ROOT / "variant3d" / "assets" / "terrain" / "blocks"
OUT = ROOT / "variant3d" / "assets" / "terrain" / "atlas"
DUMP = ROOT / "app" / "shots" / "g32_dump.json"

ATLAS_NAME = "tile_index_atlas.png"
MANIFEST_NAME = "tile_index_atlas.manifest.json"
ALPHA_NAME = "alpha.png"
ALPHAVERT_NAME = "alphavert.png"
EXPECTED_FILES = {ATLAS_NAME, MANIFEST_NAME, ALPHA_NAME, ALPHAVERT_NAME}

CELL = 1024
COLS = 16
ROWS = 8
SLOTS = COLS * ROWS  # 128 slots; 124 named cells + 4 trailing unused
EXPECTED_NAMES = 124

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DONOR_TEX = Path("data") / "terrain" / "tiles" / "textures"

# required donor mask -> (expected width, expected height, expected bpp,
#                         donor evidence path:line, output filename)
MASKS = {
    "alpha": (512, 256, 8,
              "data/terrain/ref/reftilealpha.mat:30-37", ALPHA_NAME),
    "alphavert": (1024, 512, 24,
                  "data/terrain/ref/reftilealpha.mat:139-146", ALPHAVERT_NAME),
}

FACE_RE = re.compile(r"^(rock|sand)(\d+)(vf|vs|f|s)$")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def bmp_header(path: Path) -> dict:
    """Return width/height/bpp from a Windows BITMAPFILEHEADER + DIB header."""
    with open(path, "rb") as f:
        head = f.read(54)
    if len(head) < 54 or head[:2] != b"BM":
        raise ValueError("not a Windows BMP: %s" % path)
    dib = struct.unpack_from("<I", head, 14)[0]
    if dib != 40:
        raise ValueError("unsupported DIB size %d (expected 40): %s" % (dib, path))
    return {
        "w": struct.unpack_from("<i", head, 18)[0],
        "h": struct.unpack_from("<i", head, 22)[0],
        "bpp": struct.unpack_from("<H", head, 28)[0],
        "compression": struct.unpack_from("<I", head, 30)[0],
    }


def face_base(name: str) -> str | None:
    """Donor tiles.mat binds vf/vs/f/s blocks to their base DDS (no new art)."""
    m = FACE_RE.match(name)
    return f"{m.group(1)}{m.group(2)}" if m else None


def load_names() -> list[str]:
    names = json.loads(PRESETS.read_text("utf-8"))
    if not isinstance(names, list) or len(names) != EXPECTED_NAMES:
        raise AssertionError("presets_summer.json must hold %d names, got %s"
                             % (EXPECTED_NAMES, len(names)))
    if len(set(names)) != len(names):
        raise AssertionError("presets_summer.json contains duplicate names")
    return names


def resolve_sources(names: list[str]) -> tuple[list[dict], list[str]]:
    """Resolve every preset index to a shipped PNG, or mark it EMPTY/UNVERIFIED."""
    files = {p.stem: p for p in BLOCKS.glob("*.png")}
    used_stems: set[str] = set()
    layout: list[dict] = []
    for idx, name in enumerate(names):
        cx, cy = idx % COLS, idx // COLS
        cell = {"index": idx, "name": name, "cell_xy": [cx, cy],
                "cell_px": [cx * CELL, cy * CELL, CELL, CELL]}
        if name in files:
            src = files[name]
            used_stems.add(name)
            cell.update(source_png=src.name, kind="DIRECT",
                        donor_evidence="presets_summer.json:%d" % (idx + 2),
                        status="OK")
        else:
            base = face_base(name)
            if base and base in files:
                src = files[base]
                used_stems.add(base)
                cell.update(source_png=src.name, kind="FACE_BASE_REUSE",
                            donor_evidence=(
                                "data/terrain/tiles/tiles.mat:142-148,206-220 "
                                "(%s binds %s.dds)" % (name, base)),
                            status="OK")
            else:
                cell.update(source_png=None, kind="EMPTY",
                            donor_evidence=None,
                            status="UNVERIFIED — no shipped PNG for this preset name; "
                                   "cell left transparent, no art fabricated")
        layout.append(cell)
    unused = sorted(p.name for p in BLOCKS.glob("*.png") if p.stem not in used_stems)
    return layout, unused


def build_atlas(names: list[str], layout: list[dict]) -> dict:
    atlas = Image.new("RGBA", (COLS * CELL, ROWS * CELL), (0, 0, 0, 0))
    upscaled: list[str] = []
    for cell in layout:
        if cell["source_png"] is None:
            cell["source_size"] = None
            cell["upscaled"] = False
            continue
        src = BLOCKS / cell["source_png"]
        with Image.open(src) as im:
            size = list(im.size)
            rgb = im.convert("RGB")
        if size != [CELL, CELL]:
            # NEAREST replicates existing texels; no interpolated colour is
            # invented. This is an explicit APPROX (tiles.lib:53-63).
            rgb = rgb.resize((CELL, CELL), Image.Resampling.NEAREST)
            cell["upscaled"] = True
            upscaled.append("%s %s->%d" % (cell["source_png"], size, CELL))
            cell["upscale_label"] = "APPROX_SAND_UPSCALE" if cell["name"].startswith("sand") \
                else "APPROX_UPSCALE"
        else:
            cell["upscaled"] = False
        cell["source_size"] = size
        cell["source_sha256"] = sha256(src)
        x, y, w, h = cell["cell_px"]
        atlas.paste(rgb, (x, y, x + w, y + h))
        rgb.close()
    atlas.save(OUT / ATLAS_NAME, format="PNG", compress_level=6)
    atlas.close()
    return {
        "file": ATLAS_NAME,
        "size": [COLS * CELL, ROWS * CELL],
        "cell_size": [CELL, CELL],
        "grid": [COLS, ROWS],
        "slots": SLOTS,
        "named_cells": len(names),
        "filled_cells": sum(1 for c in layout if c["source_png"] is not None),
        "empty_cells": sum(1 for c in layout if c["source_png"] is None),
        "upscaled_sources": upscaled,
        "packing_label": "APPROX_ATLAS_PACKING (donor tsDouble/ttExtended is engine-side, UNVERIFIED)",
    }


def build_masks(game: Path) -> dict:
    tex = game / DONOR_TEX
    masks: dict[str, dict] = {}
    for key, (ew, eh, ebpp, evidence, out_name) in MASKS.items():
        src = tex / ("%s.bmp" % key)
        entry = {"donor_evidence": evidence, "donor_path": str(src).replace("\\", "/"),
                 "expected_size": [ew, eh], "expected_bpp": ebpp}
        if not src.is_file():
            entry.update(status="UNVERIFIED", file=None,
                         note="donor BMP unreadable/missing; no PNG fabricated")
            masks[key] = entry
            print("MASK %s: UNVERIFIED (missing %s)" % (key, src), file=sys.stderr)
            continue
        try:
            hdr = bmp_header(src)
            if (hdr["w"], hdr["h"], hdr["bpp"]) != (ew, eh, ebpp):
                raise ValueError("header %s != expected %s" %
                                 (str(hdr), str((ew, eh, ebpp))))
            with Image.open(src) as im:
                # Donor uses tiaAlphaFromIntensity + tfAlpha: one 8-bit
                # intensity per pixel. Palette lookup on alpha.bmp gives the
                # donor grey value; alphavert.bmp is near-grey RGB (all three
                # channels equal on ~92% of pixels), so L conversion is the
                # faithful single-channel representation. The exact donor
                # intensity formula is ENGINE / UNVERIFIED and is labelled.
                grey = im.convert("L")
                grey.save(OUT / out_name, format="PNG")
                mode = grey.mode
                size = list(grey.size)
                grey.close()
            entry.update(status="CONVERTED_FROM_DONOR", file=out_name,
                         size=size, mode=mode, source_sha256=sha256(src),
                         header=hdr,
                         note=("intensity PNG from donor BMP; exact "
                               "tiaAlphaFromIntensity formula is ENGINE/UNVERIFIED; "
                               "no cell<->tile sub-rect mapping invented"))
        except Exception as exc:  # unreadable -> omit, never fabricate
            entry.update(status="UNVERIFIED", file=None,
                         note="donor BMP unreadable: %r; no PNG fabricated" % (exc,))
            print("MASK %s: UNVERIFIED (%r)" % (key, exc), file=sys.stderr)
        masks[key] = entry
    return masks


def shipped_ids() -> dict:
    """Cross-check: every id in the shipped tileblock resolves in the dictionary."""
    if not DUMP.is_file():
        return {"status": "UNVERIFIED", "note": "app/shots/g32_dump.json missing"}
    dump = json.loads(DUMP.read_text("utf-8"))
    raw = base64.b64decode(dump["tileblock"])
    hist = Counter(raw)
    names = load_names()
    bad = sorted(i for i in hist if i >= len(names))
    return {
        "source": "app/shots/g32_dump.json:1 (key 'tileblock', base64 uint8)",
        "bytes": len(raw),
        "distinct_ids": len(hist),
        "min_id": min(hist),
        "max_id": max(hist),
        "histogram": {str(k): hist[k] for k in sorted(hist)},
        "unresolved_ids": bad,
        "all_resolvable": not bad,
        "top_ids": [[k, hist[k]] for k, _ in hist.most_common(5)],
    }


def verify(names: list[str], manifest: dict) -> dict:
    checks: dict[str, bool] = {}
    atlas = OUT / ATLAS_NAME
    with Image.open(atlas) as im:
        checks["atlas_size_16384x8192"] = im.size == (COLS * CELL, ROWS * CELL)
        checks["atlas_mode_RGBA"] = im.mode == "RGBA"
    checks["named_cells_124"] = manifest["atlas"]["named_cells"] == EXPECTED_NAMES
    checks["cell_size_1024"] = manifest["atlas"]["cell_size"] == [CELL, CELL]
    checks["layout_len_124"] = len(manifest["layout"]) == EXPECTED_NAMES
    checks["all_tile_ids_resolvable"] = manifest["shipped_tileblock"]["all_resolvable"]
    checks["sand1_sand2_upscaled"] = all(
        c["upscaled"] for c in manifest["layout"] if c["name"] in ("sand1", "sand2"))
    for key, (ew, eh, _bpp, _ev, out_name) in MASKS.items():
        ent = manifest["masks"][key]
        if ent.get("file") and (OUT / out_name).is_file():
            with Image.open(OUT / out_name) as im:
                checks["%s_size_%dx%d" % (key, ew, eh)] = im.size == (ew, eh)
                checks["%s_mode_L" % key] = im.mode == "L"
        else:
            checks["%s_omitted_unverified" % key] = ent.get("status") == "UNVERIFIED"
    checks["only_4_output_files"] = sorted(p.name for p in OUT.iterdir()) == sorted(EXPECTED_FILES)
    if not all(checks.values()):
        raise AssertionError("verification failed: %s" %
                             {k: v for k, v in checks.items() if not v})
    return {"checks": checks, "passed": True}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="donor install root (default: $COSSACKS3_DIR or C:/Games/Cossacks 3)")
    ap.add_argument("--check", action="store_true",
                    help="verify existing outputs without rebuilding")
    args = ap.parse_args()

    names = load_names()
    if args.check:
        manifest = json.loads((OUT / MANIFEST_NAME).read_text("utf-8"))
        result = verify(names, manifest)
        print(json.dumps(result, indent=2))
        return

    OUT.mkdir(parents=True, exist_ok=True)
    layout, unused = resolve_sources(names)
    atlas = build_atlas(names, layout)
    masks = build_masks(Path(args.game).expanduser())
    manifest = {
        "version": 1,
        "generator": "variant3d/tools/build_tile_index_atlas.py",
        "labels": ["DONOR_INDEX", "DONOR_ART", "APPROX_ATLAS_PACKING",
                   "APPROX_SAND_UPSCALE", "APPROX_ALPHA_INTENSITY_FORMULA",
                   "UNVERIFIED_EMPTY_CELLS", "UNVERIFIED_ALPHA_SUBRECT_MAPPING"],
        "atlas": atlas,
        "index_dictionary": {
            "file": "variant3d/assets/terrain/structs/presets_summer.json",
            "lines": "2-125",
            "count": len(names),
            "donor_evidence": "data/terrain/tiles/terrain.presets:2-6",
        },
        "layout": layout,
        "unused_shipped_blocks": unused,
        "unused_note": ("27 winterN.png ship but have no index in presets_summer.json; "
                        "they belong to the Winter set and are intentionally not packed"),
        "masks": masks,
        "shipped_tileblock": shipped_ids(),
        "visual_parity_claim": False,
    }
    (OUT / MANIFEST_NAME).write_text(
        json.dumps(manifest, indent=1, ensure_ascii=False), encoding="utf-8")
    result = verify(names, manifest)
    print(json.dumps({
        "atlas": atlas,
        "masks": {k: {"status": v["status"], "file": v.get("file"), "size": v.get("size")}
                  for k, v in masks.items()},
        "shipped_tileblock": {
            "bytes": manifest["shipped_tileblock"].get("bytes"),
            "distinct_ids": manifest["shipped_tileblock"].get("distinct_ids"),
            "max_id": manifest["shipped_tileblock"].get("max_id"),
            "all_resolvable": manifest["shipped_tileblock"]["all_resolvable"],
        },
        "empty_cells": [c["name"] for c in layout if c["source_png"] is None],
        "verify": result,
        "manifest": str(OUT / MANIFEST_NAME),
    }, indent=2))


if __name__ == "__main__":
    main()
