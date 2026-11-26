"""Decode ALL donor terrain masks into DERIVED height tiles + a labelled index.

I04 / TERRAIN-SWARM-2026-11-26.  Donor is READ-ONLY; only derived PNG/JSON is
ever written.  No donor TGA byte is copied into the repository, no donor binary
is executed, no visual-parity claim is made (CHARTER.md:26-30,41-44,125).

Ground truth (all [O]/[D], no parity claim):
  F04 reports/F04_masks.md: decode of all 4,466 RLE truecolour 24-bit TGAs in
    3 trees; R/G are 0 on every non-start pixel of the 1,331 vanilla masks,
    5,125 single-pixel white starts, B spans all 256 values; B encodes the
    water bed h = -1.1 * B/255, water when h < -0.25 (integer B >= 58).
  X19 reports/X19_mask_decoder_gap.md: V1-V7 validation vectors, three distinct
    water notions (class B==255 / bed h=-1.1*B/255 / tile tag B>0 & h<-0.25),
    and the two manifest bugs in the legacy tool (B>58 off-by-one; starts
    counted as water) which this tool does NOT repeat.
  A02/spec 03: generatemap.inc cites R=terrain-class / G=forest-class semantics
    (source-bitmap intent, possibly .src), but F04 measured shipped `_gauss`
    pixels with R/G == 0.  Both facts are emitted with labels; the
    contradiction (SWARM_BOARD C9) is preserved, not silently resolved.

Usage (from repo root):
  python variant3d/tools/decode_donor_masks.py --check            # Python-only self-test
  python variant3d/tools/decode_donor_masks.py                    # DRY RUN (default)
  python variant3d/tools/decode_donor_masks.py --write            # emit derived assets
  python variant3d/tools/decode_donor_masks.py --game PATH --out PATH [--check] [--write]

Determinism: stable sort, no timestamps, fixed zlib level, fixed JSON layout.
Two identical runs produce byte-identical JSON and PNG files.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import os
import struct
import sys
import zlib
from pathlib import Path

import numpy as np

TOOL = "decode_donor_masks.py"
TOOL_VERSION = "1.0.0"
DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_OUT = Path(__file__).resolve().parent.parent / "assets" / "terrain_new" / "masks"

# Donor trees: (canonical name, folder under data/gen, expected width/height,
# expected TGA descriptor).  Counts verified by F04 section 3.
TREES = (
    ("vanilla", "terrainmasks", 320, 0x00, 1331),
    ("dlc5", "terrainmasks.dlc5", 320, 0x00, 1856),
    ("src", "terrainmasks.src", 256, 0x20, 1279),
)

# Donor constants (generatemap.inc:4-7,567; texturemap.inc:29-31) [O].
H_SCALE = -1.1          # hwater = -1.1 * B/255 with fr=0 on all shipped pixels
WATER_DEEP_B = 58       # h < -0.25  <=>  integer B >= 58 (X19 C-B)
SHORE_B = 24            # h < -0.10  <=>  integer B >= 24
WHITE = (255, 255, 255)

# F04 / X19 observed corpus facts used by --check.
EXPECTED_VANILLA_STARTS = 5125
EXPECTED_TOTAL = 4466

# 8-connected neighbours for white-component detection (F04 section 2 item 4).
_NEIGHBOURS = ((dx, dy) for dy in (-1, 0, 1) for dx in (-1, 0, 1) if (dx or dy))


# --------------------------------------------------------------------------- #
# TGA decode (pure Python RLE truecolour 24-bit; no donor file is written)
# --------------------------------------------------------------------------- #

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

def parse_header(buf: bytes) -> dict:
    """Validate an 18-byte unindexed RLE-truecolour TGA header (F04 E3-E5)."""
    if len(buf) < 18:
        raise ValueError("TGA shorter than 18-byte header")
    (idlen, cmtype, itype, cmap_first, cmap_len, cmap_depth,
     xorg, yorg, w, h, depth, desc) = struct.unpack_from("<BBBHHBHHHHBB", buf, 0)
    if idlen != 0:
        raise ValueError(f"idlen={idlen} != 0")
    if cmtype != 0 or cmap_len != 0:
        raise ValueError(f"colour map present (cmtype={cmtype}, cmap_len={cmap_len})")
    if itype != 10:
        raise ValueError(f"image type {itype} != 10 (RLE truecolour)")
    if depth != 24:
        raise ValueError(f"pixel depth {depth} != 24")
    if desc & 0x0F:
        raise ValueError(f"alpha bits in descriptor {desc:#04x}")
    return {"idlen": idlen, "itype": itype, "w": w, "h": h,
            "depth": depth, "desc": desc, "top_left": bool(desc & 0x20)}


def decode_tga(path: Path) -> tuple[np.ndarray, dict, bytes]:
    """Return (RGB top-down uint8 array [h,w,3], header dict, raw donor bytes).

    RLE packets: bit7 set => repeated run, count = (b & 0x7f) + 1 pixels;
    otherwise raw run of count pixels.  BGR byte order is swapped to RGB.
    Descriptor bit 0x20 clear (bottom-left, final `_gauss`) => vertical flip.
    """
    data = path.read_bytes()
    head = parse_header(data[:18])
    w, h = head["w"], head["h"]
    pos = 18 + head["idlen"]
    total = w * h * 3
    raw = bytearray(total)
    written = 0
    while written < total:
        if pos >= len(data):
            raise ValueError(f"RLE payload exhausted at pixel {written // 3}/{w*h}")
        packet = data[pos]
        pos += 1
        count = (packet & 0x7F) + 1
        nbytes = count * 3
        if packet & 0x80:
            if pos + 3 > len(data):
                raise ValueError("truncated repeated RLE packet")
            px = data[pos:pos + 3]
            pos += 3
            end = written + nbytes
            if end > total:
                raise ValueError("RLE overruns image")
            # C-level repeat instead of a per-pixel Python loop (large water
            # runs dominate the 4,466-file corpus).
            raw[written:end] = px * count
            written = end
        else:
            if pos + nbytes > len(data):
                raise ValueError("truncated raw RLE packet")
            end = written + nbytes
            if end > total:
                raise ValueError("RLE overruns image")
            raw[written:end] = data[pos:pos + nbytes]
            pos += nbytes
            written = end

    arr = np.frombuffer(raw, dtype=np.uint8).reshape(h, w, 3)
    if not head["top_left"]:
        arr = arr[::-1]                    # bottom-left -> top-down
    # BGR -> RGB (copy makes the array contiguous and independent of raw).
    rgb = np.ascontiguousarray(arr[:, :, [2, 1, 0]])
    return rgb, head, data


def sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# --------------------------------------------------------------------------- #
# Derived fields
# --------------------------------------------------------------------------- #
def white_components(rgb: np.ndarray) -> list[list[tuple[int, int]]]:
    """Exact (255,255,255) pixels -> 8-connected components, scan order.

    Donor records each white pixel and dedupes only identical coordinates
    (generatemap.inc:413-443); component merging is the F04 §8 / X19 C-D
    de-duplication guard for the six known 1-2 px near-duplicate starts.
    """
    white = np.all(rgb == np.array(WHITE, dtype=np.uint8), axis=2)
    ys, xs = np.nonzero(white)
    remaining = set(zip(xs.tolist(), ys.tolist()))
    comps: list[list[tuple[int, int]]] = []
    while remaining:
        seed = min(remaining, key=lambda p: (p[1], p[0]))
        stack = [seed]
        remaining.discard(seed)
        comp: list[tuple[int, int]] = []
        while stack:
            x, y = stack.pop()
            comp.append((x, y))
            for dx, dy in _NEIGHBOURS:
                n = (x + dx, y + dy)
                if n in remaining:
                    remaining.discard(n)
                    stack.append(n)
        comps.append(sorted(comp, key=lambda p: (p[1], p[0])))
    comps.sort(key=lambda c: (min(p[1] for p in c), min(p[0] for p in c)))
    return comps


def analyse(path: Path, tree: str, shape: str) -> dict:
    """Decode one TGA and compute all derived fields; no file is written."""
    rgb, head, donor_bytes = decode_tga(path)
    h, w = head["h"], head["w"]
    comps = white_components(rgb)
    white_mask = np.all(rgb == np.array(WHITE, dtype=np.uint8), axis=2)

    B = rgb[:, :, 2].astype(np.int16)
    starts_px = [[x, y] for c in comps for (x, y) in c]

    # Height tile: h = -1.1*B/255 encoded losslessly as gray8 v=B;
    # donor zeroes start pixels after recording them (generatemap.inc:440-443,
    # :565-566), so v=0 at every white pixel.  Decode: h_m = -1.1*v/255.
    height = B.astype(np.uint8).copy()
    height[white_mask] = 0

    nonstart = ~white_mask
    n_nonstart = int(np.count_nonzero(nonstart))
    b_ns = B[nonstart]
    r_ns = rgb[:, :, 0][nonstart]
    g_ns = rgb[:, :, 1][nonstart]

    water_count = int(np.count_nonzero(b_ns >= WATER_DEEP_B))
    shore_count = int(np.count_nonzero(b_ns >= SHORE_B))
    class_count = int(np.count_nonzero(b_ns == 255))
    water_all_count = int(np.count_nonzero(B >= WATER_DEEP_B))

    # Legacy-compatible `starts`: centroid normalised by source w,h, 5 dp.
    starts: list[list[float]] = []
    detail: list[dict] = []
    for c in comps:
        cx = sum(p[0] for p in c) / len(c)
        cy = sum(p[1] for p in c) / len(c)
        nx, ny = round(cx / w, 5), round(cy / h, 5)
        starts.append([nx, ny])
        detail.append({"n_pixels": len(c), "pixels": [[x, y] for x, y in c],
                       "cx": round(cx, 4), "cy": round(cy, 4),
                       "nx": nx, "ny": ny})

    rel_source = path.relative_to(path.parents[2]).as_posix()  # <tree-folder>/<shape>/<file>, under data/gen
    rel_out = f"height/{tree}/{shape}/{path.stem}.height.png"

    rec = {
        "file": rel_out,
        "starts": starts,
        "water": round(water_count / n_nonstart, 6),
        # --- derived additions (legacy schema keys above are preserved) ---
        "source": rel_source,
        "source_sha256": sha256_bytes(donor_bytes),
        "source_bytes": len(donor_bytes),
        "shape": shape,
        "tree": tree,
        "width": w, "height": h,
        "descriptor": f"0x{head['desc']:02x}",
        "start_components": detail,
        "start_pixel_count": len(starts_px),
        "height_encoding": {
            "format": "gray8", "pixel": "v",
            "height_m": "-1.1 * v / 255",
            "start_pixels": "v=0 (donor zeroes starts after recording)",
        },
        "water_all": round(water_all_count / (w * h), 6),
        "water_class_fraction": round(class_count / n_nonstart, 6),
        "water_shore_fraction": round(shore_count / n_nonstart, 6),
        "b58_pixels": water_count,
        "nonstart_r_sum": int(r_ns.sum()),
        "nonstart_g_sum": int(g_ns.sum()),
        "b_distinct": len(np.unique(B)),
        "labels": {
            "height": "DONOR_B [O]/[D] h=-1.1*B/255, starts zeroed",
            "starts": "DONOR_WHITE [O] 8-connected components, pixel coords",
            "water": "DONOR_B [D] h<-0.25 => B>=58, starts excluded",
            "water_class": "DONOR_B [O] B==255 (generatemap.inc:486-490)",
            "forest_density": None,
            "forest_density_label": "[U] UNVERIFIED: G=0 on vanilla non-start pixels; no density invented",
            "relief_class_r": "[U] generatemap.inc R-class semantics are donor intent, absent in shipped vanilla pixels",
            "forest_class_g": "[U] generatemap.inc G-class semantics are donor intent, absent in shipped vanilla pixels",
        },
    }
    return {"record": rec, "height": height, "width": w, "height_px": h}


# --------------------------------------------------------------------------- #
# Deterministic PNG writer (grayscale 8-bit; no metadata, fixed zlib level)
# --------------------------------------------------------------------------- #
def gray8_png(flat: np.ndarray, w: int, h: int) -> bytes:
    scanlines = b"".join(b"\x00" + flat[y * w:(y + 1) * w].tobytes() for y in range(h))

    def chunk(tag: bytes, payload: bytes) -> bytes:
        return (struct.pack(">I", len(payload)) + tag + payload +
                struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF))

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 0, 0, 0, 0)  # gray8, no interlace
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) +
            chunk(b"IDAT", zlib.compress(scanlines, 9)) + chunk(b"IEND", b""))


# --------------------------------------------------------------------------- #
# Corpus walk
# --------------------------------------------------------------------------- #
def discover(game: Path) -> dict[str, dict[str, list[Path]]]:
    found: dict[str, dict[str, list[Path]]] = {}
    for name, folder, _size, _desc, _count in TREES:
        root = game / "data" / "gen" / folder
        shapes: dict[str, list[Path]] = {}
        if root.is_dir():
            for p in root.rglob("*.tga"):
                shapes.setdefault(p.parent.relative_to(root).as_posix(), []).append(p)
        for shape in shapes:
            shapes[shape].sort(key=lambda p: p.name)
        found[name] = dict(sorted(shapes.items()))
    return found


def iter_paths(found: dict[str, dict[str, list[Path]]]):
    for tree in sorted(found):
        for shape in sorted(found[tree]):
            for path in found[tree][shape]:
                yield tree, shape, path


# --------------------------------------------------------------------------- #
# --check: Python-only self-test against F04/X19 vectors (no writes)
# --------------------------------------------------------------------------- #
def run_check(game: Path, found: dict[str, dict[str, list[Path]]]) -> int:
    results: list[tuple[str, bool, str]] = []

    def record(name: str, ok: bool, detail: str) -> None:
        results.append((name, ok, detail))
        print(f"CHECK {name}: {'PASS' if ok else 'FAIL'} | {detail}")

    # Inventory counts (F04 section 3).
    for name, _folder, size, desc, expected in TREES:
        n = sum(len(v) for v in found[name].values())
        record(f"inventory/{name}", n == expected,
               f"{n} tga (expected {expected})")
        for shape, paths in found[name].items():
            for p in paths:
                head = parse_header(p.read_bytes()[:18])
                if head["w"] != size or head["h"] != size or head["desc"] != desc:
                    record(f"header/{name}/{shape}/{p.name}", False,
                           f"{head['w']}x{head['h']} desc={head['desc']:#04x}")
                    break
        else:
            record(f"header/{name}", True, f"all itype=10 depth=24 {size}x{size} desc={desc:#04x}")

    # Full vanilla corpus facts (F04 section 5.1).
    v_starts = 0
    v_r = 0
    v_g = 0
    v_b = set()
    v_bad = 0
    for shape, paths in found["vanilla"].items():
        for p in paths:
            rgb, _head, _raw = decode_tga(p)
            white = np.all(rgb == np.array(WHITE, dtype=np.uint8), axis=2)
            v_starts += int(np.count_nonzero(white))
            ns = ~white
            v_r += int(rgb[:, :, 0][ns].sum())
            v_g += int(rgb[:, :, 1][ns].sum())
            v_b.update(np.unique(rgb[:, :, 2]).tolist())
            if not np.all(np.isin(rgb[:, :, 0][ns], [0, 255])) or v_r:
                v_bad += 1
    record("vanilla_starts", v_starts == EXPECTED_VANILLA_STARTS,
           f"{v_starts} white pixels (expected {EXPECTED_VANILLA_STARTS})")
    record("vanilla_rg_nonstart_zero", v_r == 0 and v_g == 0 and v_bad == 0,
           f"R sum={v_r} G sum={v_g} anomalous masks={v_bad}")
    record("vanilla_b_spans_256", v_b == set(range(256)),
           f"{len(v_b)} distinct B values, min={min(v_b)} max={max(v_b)}")

    total = sum(len(v) for shapes in found.values() for v in shapes.values())
    record("corpus_total", total == EXPECTED_TOTAL, f"{total} (expected {EXPECTED_TOTAL})")

    def by_rel(rel: str, tree: str = "vanilla") -> Path | None:
        # rel like "nowater2/4pl_mask_nowater_176_gauss.tga"
        folder = next(f for n, f, _s, _d, _c in TREES if n == tree)
        p = game / "data" / "gen" / folder / rel
        return p if p.is_file() else None

    def starts_of(p: Path) -> list[tuple[int, int]]:
        rgb, _h, _r = decode_tga(p)
        return [(x, y) for c in white_components(rgb) for x, y in c]

    # V1 - flat land: 4 starts, non-start R=G=B=0, water 0.
    p = by_rel("nowater2/4pl_mask_nowater_176_gauss.tga")
    if p:
        a = analyse(p, "vanilla", "nowater2")["record"]
        exp = {(41, 41), (278, 41), (63, 256), (256, 256)}
        got = {(xy[0], xy[1]) for xy in (pt for c in a["start_components"] for pt in c["pixels"])}
        record("V1_flat", got == exp and a["water"] == 0.0 and a["nonstart_r_sum"] == 0
               and a["nonstart_g_sum"] == 0,
               f"starts={sorted(got)} water={a['water']} R/G sums 0")

    # V2 - med/22: 4 starts, 22 px at B=58, water_all ~0.213857, transect.
    p = by_rel("mediterranean/4pl_mask_mediterranean_22_gauss.tga")
    if p:
        a = analyse(p, "vanilla", "mediterranean")["record"]
        rgb, _h, _r = decode_tga(p)
        exp = {(39, 31), (192, 164), (62, 262), (289, 288)}
        got = {(xy[0], xy[1]) for xy in (pt for c in a["start_components"] for pt in c["pixels"])}
        b58 = int(np.count_nonzero(rgb[:, :, 2] == 58))
        transect = [int(rgb[120, x, 2]) for x in range(35, 44)]
        exp_t = [0, 1, 7, 31, 97, 194, 246, 254, 255]
        record("V2_med22", got == exp and b58 == 22 and abs(a["water_all"] - 0.213857) < 2e-6
               and transect == exp_t,
               f"starts={sorted(got)} B58={b58} water_all={a['water_all']} transect={transect}")

    # V3 - islands/0: 2 starts, high water, R/G zero.
    p = by_rel("islands/2pl_mask_islands_0_gauss.tga")
    if p:
        a = analyse(p, "vanilla", "islands")["record"]
        exp = {(99, 68), (189, 260)}
        got = {(xy[0], xy[1]) for xy in (pt for c in a["start_components"] for pt in c["pixels"])}
        record("V3_islands", got == exp and 0.64 <= a["water_all"] <= 0.645
               and a["nonstart_r_sum"] == 0 and a["nonstart_g_sum"] == 0,
               f"starts={sorted(got)} water_all={a['water_all']}")

    # V4 - peninsulas/0: 2 starts, water_all ~0.492637.
    p = by_rel("peninsulas/2pl_mask_peninsulas_0_gauss.tga")
    if p:
        a = analyse(p, "vanilla", "peninsulas")["record"]
        exp = {(149, 81), (268, 275)}
        got = {(xy[0], xy[1]) for xy in (pt for c in a["start_components"] for pt in c["pixels"])}
        record("V4_peninsulas", got == exp and abs(a["water_all"] - 0.492637) < 2e-6,
               f"starts={sorted(got)} water_all={a['water_all']}")

    # V5 - .src master: 256x256, top-left, binary B.
    p = by_rel("mediterranean/4pl_mask_mediterranean_22.tga", "src")
    if p:
        rgb, head, _r = decode_tga(p)
        a = analyse(p, "src", "mediterranean")["record"]
        bset = set(np.unique(rgb[:, :, 2]).tolist())
        record("V5_src_master", head["w"] == head["h"] == 256 and head["desc"] == 0x20
               and bset <= {0, 255} and a["nonstart_r_sum"] == 0,
               f"256x256 desc=0x20 B={sorted(bset)} R sum={a['nonstart_r_sum']}")

    # V6 - six near-duplicate starts: raw white pixels > filename prefix.
    v6 = {
        "land/4pl_mask_land_113_gauss.tga": 5,
        "land/4pl_mask_land_114_gauss.tga": 5,
        "mediterranean/4pl_mask_mediterranean_51_gauss.tga": 5,
        "mediterranean/4pl_mask_mediterranean_62_gauss.tga": 5,
        "islands/2pl_mask_islands_98_gauss.tga": 3,
        "peninsulas/4pl_mask_peninsulas_5_gauss.tga": 5,
    }
    v6_ok = True
    v6_detail = []
    for rel, expected in v6.items():
        p = by_rel(rel)
        if p is None:
            v6_ok = False
            v6_detail.append(f"{rel}:MISSING")
            continue
        n = len(starts_of(p))
        v6_ok &= n == expected
        v6_detail.append(f"{Path(rel).name}:{n}/{expected}")
    record("V6_duplicate_starts", v6_ok, " ".join(v6_detail))

    # V7 - DLC5 grey pixels: R/G not confined to {0,255} in two masks.
    v7_ok = True
    v7_detail = []
    for idx in (8, 9):
        rel = f"continents/8pl_mask_continents_{idx}_gauss.tga"
        p = by_rel(rel, "dlc5")
        if p is None:
            v7_ok = False
            v7_detail.append(f"{rel}:MISSING")
            continue
        rgb, _h, _r = decode_tga(p)
        grey = int(np.count_nonzero((rgb[:, :, 0] != 0) & (rgb[:, :, 0] != 255)))
        nstarts = len(starts_of(p))
        v7_ok &= grey >= 4 and nstarts == 7
        v7_detail.append(f"_{idx}:grey={grey},starts={nstarts}")
    record("V7_dlc5_grey", v7_ok, " ".join(v7_detail))

    # Three distinct water thresholds must stay distinct on med/22.
    p = by_rel("mediterranean/4pl_mask_mediterranean_22_gauss.tga")
    if p:
        a = analyse(p, "vanilla", "mediterranean")["record"]
        distinct = not (a["water"] == a["water_class_fraction"] == a["water_shore_fraction"])
        record("three_water_notions", distinct,
               f"deep={a['water']} class={a['water_class_fraction']} shore={a['water_shore_fraction']}")

    passed = sum(1 for _n, ok, _d in results if ok)
    print(f"CHECK SUMMARY: {passed}/{len(results)} PASS | "
          f"parity=UNVERIFIED | no donor frame, no writes")
    return 0 if passed == len(results) else 1


# --------------------------------------------------------------------------- #
# Compile / dry-run
# --------------------------------------------------------------------------- #
def build_manifest(found: dict[str, dict[str, list[Path]]], do_write: bool,
                   out: Path, game: Path) -> tuple[dict, int, int]:
    types: dict[str, dict] = {}
    png_bytes = 0
    n_masks = 0
    for tree, shape, path in iter_paths(found):
        result = analyse(path, tree, shape)
        rec = result["record"]
        key = f"{tree}/{shape}"
        types.setdefault(key, {"masks": []})["masks"].append(rec)
        n_masks += 1

        png = gray8_png(result["height"].reshape(-1), result["width"], result["height_px"])
        png_sha = sha256_bytes(png)
        rec["height_sha256"] = png_sha
        rec["height_bytes"] = len(png)
        if do_write:
            dst = out / rec["file"]
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes(png)
            png_bytes += len(png)
        print(f"SOURCE {rec['source']} -> OUTPUT {rec['file']} -> "
              f"sha256 {png_sha} -> {rec['labels']['height']}")

    # Stable key order; no timestamps anywhere.
    for key in sorted(types):
        types[key]["masks"].sort(key=lambda r: r["file"])

    counts = {name: sum(len(v) for v in found[name].values()) for name, _f, _s, _d, _c in TREES}
    data = {
        "version": 1,
        "source": (game / "data" / "gen").as_posix().rstrip("/"),
        "note": ("DERIVED height masks from donor B channel (h=-1.1*B/255, gray8 "
                 "v=B, starts zeroed); white=start; R/G class semantics [U]; "
                 "visual_parity_claim=false"),
        "types": types,
        # ---- additions: provenance / labels / contradiction (mirror legacy 4 keys above) ----
        "visual_parity_claim": False,
        "provenance": {
            "tool": TOOL,
            "tool_version": TOOL_VERSION,
            "licence": "private-use donor input; DERIVED PNG/JSON only; no raw donor TGA copied",
            "derived_only": True,
            "donor_trees": [
                {"tree": name, "folder": folder, "size": size,
                 "descriptor": f"0x{desc:02x}", "masks": counts[name]}
                for name, folder, size, desc, _c in TREES
            ],
            "total_masks": n_masks,
            "method": [
                "TGA RLE truecolour 24-bit decode; BGR->RGB; descriptor bit 0x20 honoured (F04 E3-E5)",
                "start: exact (255,255,255), 8-connected components (F04 sec2, X19 C-D)",
                "height: h=-1.1*B/255, gray8 v=B, start pixels v=0 (donor generatemap.inc:440-443)",
                "water: B>=58 (h<-0.25), starts excluded (X19 BUG-1/BUG-2 fixed)",
            ],
            "citations": [
                "F04_masks.md sec3,5,6,8,10 (donor pixel truth)",
                "X19_mask_decoder_gap.md sec5 V1-V7, sec4 C-A..C-G (decoder recipe)",
                "spec/03_MASK_TO_HEIGHT.md sec1 (h=-1.1*B/255)",
                "spec/11_ASSET_CONVERSION.md sec11.1 (dry-run, provenance, parity false)",
            ],
        },
        "observations": {
            "C9_contradiction": {
                "fact_observed": ("F04: R/G=0 on every non-start pixel of all 1,331 vanilla "
                                  "_gauss masks; 5,125 single-pixel white starts; B spans 0..255"),
                "fact_observed_label": "[O] measured donor pixels",
                "fact_cited": ("A02 / generatemap.inc: R = terrain class (255/191/96/112/48/88/64), "
                               "G = forest/stone class (255/127/64/128/192) on source bitmaps "
                               "(possibly .src / editor authoring)"),
                "fact_cited_label": "[U] donor intent text, inert on shipped vanilla pixels",
                "status": "PRESERVED — SWARM_BOARD C9 OPEN; both facts emitted, none silently chosen",
                "label": "[U] UNVERIFIED",
            },
            "forest_density": {
                "value": None,
                "label": "[U] UNVERIFIED — G=0 on vanilla non-start pixels; density from patterns "
                         "(D07/F08), not invented from zero G (X19 UNVERIFIED #3)",
            },
            "water_notions": {
                "class": "B==255 (generatemap.inc:486-490)",
                "bed": "h=-1.1*B/255 (generatemap.inc:567)",
                "tile_tag": "B>0 and h<-0.25/-0.10 (texturemap.inc:464-470)",
                "label": "[O]/[D] three distinct thresholds; not conflated (X19 sec0.5)",
            },
        },
        "parity": {
            "visual_parity_claim": False,
            "status": "UNVERIFIED",
            "note": "No donor GPU A/B frame exists (CHARTER.md:41,125).",
        },
    }
    return data, n_masks, png_bytes


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="donor install folder (default: $COSSACKS3_DIR or C:/Games/Cossacks 3)")
    ap.add_argument("--out", default=str(DEFAULT_OUT),
                    help="derived-asset output root (default: variant3d/assets/terrain_new/masks)")
    ap.add_argument("--check", action="store_true",
                    help="Python-only self-test against F04/X19 vectors; writes nothing")
    ap.add_argument("--dry-run", action="store_true",
                    help="explicit dry run (already the default); writes nothing")
    ap.add_argument("--write", action="store_true",
                    help="actually emit derived PNG/JSON (default is dry-run)")
    args = ap.parse_args()

    game = Path(args.game).expanduser().resolve()
    out = Path(args.out).expanduser().resolve()
    do_write = bool(args.write) and not args.dry_run and not args.check

    # Licence guard: never write inside the donor install.
    gkey = str(game).lower().rstrip("\\/")
    okey = str(out).lower().rstrip("\\/")
    try:
        inside_donor = os.path.commonpath([gkey, okey]) == gkey
    except ValueError:  # different drives on Windows
        inside_donor = False
    if inside_donor:
        print(f"REFUSED: --out {out} is inside donor root {game}")
        return 2

    found = discover(game)
    if args.check:
        return run_check(game, found)

    data, n_masks, png_bytes = build_manifest(found, do_write, out, game)
    payload = (json.dumps(_scrub_donor_paths(data), indent=1, ensure_ascii=True) + "\n").encode("utf-8")
    manifest_sha = sha256_bytes(payload)
    manifest_path = out / "mask_index.json"
    if do_write:
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_bytes(payload)
    mode = "WRITE" if do_write else "DRY-RUN"
    print(f"{mode} | masks={n_masks} | trees=3 | png_bytes={png_bytes} | "
          f"manifest={manifest_path.as_posix()} sha256={manifest_sha} | "
          f"visual_parity_claim=false | {data['observations']['C9_contradiction']['status']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
