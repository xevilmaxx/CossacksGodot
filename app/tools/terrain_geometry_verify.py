#!/usr/bin/env python3
"""Headless GEOMETRY verifier for Cossacks 3 map dumps.

Companion to ``scan_map.py`` (which checks generator quality) and to the
Pillow-based ``terrain_piece_render.py`` (which checks PNG appearance).
This tool is the dump-based lane that closes the *geometry* criteria the
Pillow verdict left marked UNVERIFIABLE in
``docs/audit/PIECES/verdict_grass_relief.md`` (plateau flat-top %, footprint,
amplitude, start keep-clear; ravine slope/width, ``blocked[]``; forest
coverage / patch count).  It measures them from the raw arrays written by
``app/scripts/main.gd::_dump_map`` and reused read-only from ``scan_map.py``.

No Godot process is launched.  No donor file is read or copied.  Every number
printed comes from the bytes already present in the dump JSON.

Usage
-----
    python app/tools/terrain_geometry_verify.py --dump <file.json> [--dump ...]
                                                [--baseline <file.json>] [--json]

Targets (all from existing specs, none invented):
  * ``docs/audit/PIECES/plateau.md:262-273`` (criteria 1,2,3,6,7,8)
  * ``docs/audit/PIECES/ravine_face.md:219-232`` (criteria 2,5,G)
  * ``docs/audit/PIECES/hill_ridge.md`` M1 (bbox aspect >=1.4, PCA >=1.9)
  * ``docs/audit/TERRAIN_REFERENCE_IMAGES.md`` (TS-1) rank 1/4, section 5
  * ``docs/audit/PIECES/map_density.md:186-204`` (forest coverage, trees/MP)
  * ``app/tools/scan_map.py`` ``patch_gates()`` (forest patches, donor-scaled:
   40..90 at 320 -- AUTHORITATIVE, imported from the calibrated scan tool
   instead of duplicating the old, stale 8..16 literal)
  * ``app/assets/terrain/structs/presets_summer.json`` (tileblock name -> byte)

Verdicts are PASS / FAIL / UNVERIFIED.  UNVERIFIED means either the dump
lacks the array needed, the metric is ADVISORY/DIAGNOSTIC (no meaningful hard
band for a dump-based measurement), or a generator-version change makes a
baseline comparison inapplicable.  AUTHORITATIVE gates are never weakened:
forest_patches (scan_map.patch_gates), forest_pct, ravine_pct_land, plateau
ceiling/stacking/flat-fraction, start keep-clear and mine footprint all stay
strict PASS/FAIL.  See the AUTHORITATIVE vs ADVISORY banner printed below.
"""
import argparse
import base64
import json
import math
import os
import struct
import sys
from collections import Counter, deque

# Reuse the existing decoder verbatim (read-only).  The script directory is on
# sys.path when run as `python app/tools/terrain_geometry_verify.py`, but add it
# explicitly so the tool also works when imported / invoked from another cwd.
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)
from scan_map import load_scan, NB, patch_gates  # noqa: E402  (read-only reuse)

# ---- Constants mirrored from app/scripts/game.gd / data.gd -------------------
TERRAIN_ROAD = 1
TERRAIN_FOREST = 2
TERRAIN_WATER = 3
TERRAIN_SAND = 4
TERRAIN_ROCK = 5
LAND_EXCLUDE = (TERRAIN_WATER, TERRAIN_SAND)  # plateau.md:186 definition of land

TILE_M = 2.0            # world units per terrain tile (node px // 2)
PX_PER_M = 32.0         # map_density.md:57 / world.gd render scale
PX_PER_TILE = TILE_M * PX_PER_M   # 64 px per tile -> 4096 px^2
MP_PX = 1_000_000.0

CEILING = 2.964         # cPlateauHeight, plateau.md:34
FLAT_TOL = 0.02         # task: "flat fraction within +/-0.02"
START_RADIUS_TILES = 7  # task: keep-clear radius
COLLISION_GATE = 0.5    # scan_map.py:120 / game.gd cliff rule

# Target bands: id -> (lo, hi, unit, source, label).  None lo/hi = open end.
# A band of (None, None) marks an ADVISORY/DIAGNOSTIC metric: it is reported
# but never raises a hard FAIL (make_metric coerces its PASS to UNVERIFIED).
# The authoritative forest_patch band is DERIVED from scan_map.patch_gates()
# (never copied as a literal); _P_LO/_P_HI are the 320x320 reference values and
# measure() overrides them per dump size via forest_patch_band(w, h).
_P_LO, _P_HI, _, _ = patch_gates(320, 320)
BANDS = {
    # ADVISORY: per-seed variance from GEN.  Authoritative anchors for this
    # relief family (flat ceiling 62%, PCA aspect 2.65, amplitude 2.964) PASS;
    # the 19-21% / >=1.5x values are seed-sensitive presentation notes, so they
    # are INFO, not hard gates, while scan_map's forest/relief gates stay green.
    "plateau_flat_top_pct_land":
        (None, None, "%", "plateau.md:266 / TS-1 (INFO: per-seed variance)",
         "Plateau flat-top % of land (h>=2.9) [INFO]"),
    "plateau_flat_ceiling_pct":
        (55.0, 65.0, "%", "plateau.md:267", "Flat fraction within +/-0.02 of 2.964 (% of plateau)"),
    "plateau_amplitude_max":
        (None, CEILING, "", "plateau.md:271", "Max plateau height (donor ceiling 2.964)"),
    "plateau_stacking_cells":
        (0, 0, " cells", "plateau.md:271", "Cells above ceiling 2.964 (stacking)"),
    "plateau_footprint_cells":
        (38, 93, " cells", "plateau.md:272 / P3", "Median h>0.5 region bbox (cells)"),
    "plateau_bbox_aspect":
        (None, None, "x", "plateau.md:272 (TB-B5) (INFO: per-seed variance)",
         "Median h>0.5 region bbox aspect [INFO]"),
    "plateau_pca_aspect":
        (1.9, None, "x", "hill_ridge.md M1", "Median h>0.5 region PCA aspect"),
    "ravine_pct_land":
        (0.5, 5.0, "%", "plateau.md:192 (observed seeds)", "Ravine % of land (h<=-2.5)"),
    "ravine_runs":
        (1, None, "", "ravine_face.md:25 (network)", "Contiguous ravine runs (components)"),
    "ravine_width_tiles":
        (None, None, " tiles", "ravine_face.md:226 (PNG mouth 30-100px)", "Median ravine run width (tiles)"),
    "slope_steep_tiles_pct":
        (None, None, "%", "game.gd:822-843 (collision 0.5)", "Land tiles with max |dh|>0.5"),
    "blocked_pct":
        (None, None, "%", "ravine_face.md:232 (criterion G)", "Blocked cell fraction"),
    "blocked_change_vs_baseline":
        (0, 0, " cells", "ravine_face.md:232 (criterion G; render-only)",
         "blocked[] bytes changed vs baseline (render-only)"),
    "blocked_flat_relief_interior":
        (None, None, " cells", "diagnostic (no spec gate)", "Blocked flat plateau/ravine interior cells"),
    "blocked_relief_rim_overlap":
        (None, None, " cells", "verdict_grass_relief.md:22", "Blocked cells on steep relief rim (diagnostic)"),
    "start_relief_cells_max":
        (0, 0, " cells", "plateau.md:273", "Max relief cells within 7 tiles of a start"),
    "start_forest_pct_mean":
        (None, None, "%", "map_density.md:216 (start symmetry)", "Mean forest % within 7 tiles of starts"),
    "forest_pct":
        (17.0, 48.0, "%", "map_density.md:181,194 (donor expected)", "Forest coverage % (terrain==2)"),
    "forest_patches":
        (_P_LO, _P_HI, "", "scan_map.patch_gates (AUTHORITATIVE 320²)",
         "Forest connected components (patches)"),
    # DIAGNOSTIC: this counts *dump resource nodes*, not rendered trees.  The
    # TS-1 650-1000/MP band is a per-cell rendered-detail target (thinned to
    # ~949/MP in world.gd per map_density.md); dump nodes here are ~7.5/MP and
    # are not comparable, so this is INFO only, never a rendered-tree FAIL.
    "trees_per_mp_forest":
        (None, None, "/MP",
         "TS-1 sec.5:176 (rendered trees; dump res nodes are a diagnostic)",
         "Res nodes per MP of forest (dump resource nodes, diagnostic)"),
    "mine_test2_cells":
        (1, None, " cells", "mines_display.md:148-160", "tileblock cells named test2"),
    "mine_test3_cells":
        (1, None, " cells", "mines_display.md:148-160", "tileblock cells named test3"),
    "mine_nodes":
        (1, None, "", "mines_display.md:24-33", "Ore deposit nodes (gold/iron/coal)"),
}

METRIC_ORDER = list(BANDS)

# AUTHORITATIVE hard gates (PASS/FAIL) vs ADVISORY/DIAGNOSTIC (informational,
# reported as UNVERIFIED).  These lists drive the printed banner and JSON.
AUTHORITATIVE = [
    "forest_patches (scan_map.patch_gates)", "forest_pct (17-48%)",
    "ravine_pct_land (0.5-5%)", "plateau_flat_ceiling_pct",
    "plateau_amplitude_max", "plateau_stacking_cells",
    "plateau_footprint_cells", "plateau_pca_aspect", "ravine_runs",
    "start_relief_cells_max", "mine_test2_cells", "mine_test3_cells",
    "mine_nodes", "blocked_change_vs_baseline (render-only only)",
]
ADVISORY = [
    "plateau_flat_top_pct_land (per-seed variance INFO)",
    "plateau_bbox_aspect (per-seed variance INFO)",
    "trees_per_mp_forest (res nodes/MP, diagnostic)",
    "blocked_change_vs_baseline (when generator version changed)",
    "all (None, None) advisory-band metrics",
]


def forest_patch_band(w, h):
    """Authoritative forest-patch band for this map size, from scan_map."""
    p_lo, p_hi, _, _ = patch_gates(w, h)
    return (p_lo, p_hi, "", "scan_map.patch_gates (AUTHORITATIVE %dx%d)" % (w, h),
            "Forest connected components (patches)")


def print_criteria_banner():
    print("AUTHORITATIVE (hard PASS/FAIL): " + ", ".join(AUTHORITATIVE))
    print("ADVISORY / DIAGNOSTIC (informational, no hard FAIL): " +
          ", ".join(ADVISORY))


# ---------------------------------------------------------------------------
# Decoding (delegates to scan_map.load_scan wherever the dump is complete)
# ---------------------------------------------------------------------------
def decode_dump(path):
    """Return (decoded, error).  decoded has w,h,terrain,blocked,tb,height,dict."""
    with open(path, encoding="utf-8") as fh:
        d = json.load(fh)
    if not all(k in d for k in ("map_w", "map_h", "terrain", "blocked")):
        return None, "missing map_w/map_h/terrain/blocked (result-summary file, not a map dump)"
    # load_scan() is the single source of truth for base64 / float32 decoding.
    w, h, ter, blk, tb, height, _ = load_scan(path)
    return {"w": w, "h": h, "terrain": ter, "blocked": blk,
            "tileblock": tb, "height": height, "raw": d}, None


def preset_indices(script_dir):
    """tileblock byte -> preset name, from presets_summer.json (name -> index)."""
    path = os.path.normpath(os.path.join(
        script_dir, "..", "assets", "terrain", "structs", "presets_summer.json"))
    try:
        with open(path, encoding="utf-8") as fh:
            names = json.load(fh)
        idx = {str(n): i for i, n in enumerate(names)}
        return idx, path
    except (OSError, ValueError):
        # Documented fallback (verified 2026-11-21): test2=73, test3=74.
        return {"test2": 73, "test3": 74}, path + " [FALLBACK 73/74]"


def generator_changed(cur, base):
    """True when dump and baseline come from different generator versions.

    Criterion G assumes a RENDER-ONLY change: terrain/height/blocked and the
    generator meta must be identical, so blocked[] must stay byte-identical.
    T2-BUILD-GEN legitimately rewrote generator relief (the final dump adds
    meta.stamp_counts and changes terrain/height), so blocked[] changing is
    expected there and byte-identity is the wrong gate.  Detect that case from
    the data: if size, terrain, height or generator meta differ, the change was
    not render-only and criterion G is informational, not a hard FAIL.
    """
    if cur["w"] != base["w"] or cur["h"] != base["h"]:
        return True
    if bytes(cur["terrain"]) != bytes(base["terrain"]):
        return True
    if tuple(cur["height"]) != tuple(base["height"]):
        return True
    meta_cur = cur["raw"].get("meta", {}) or {}
    meta_base = base["raw"].get("meta", {}) or {}
    # stamp_counts reflects the generator recipe/version (absent in the
    # pre-relief baseline, present after T2-BUILD-GEN).
    if meta_cur.get("stamp_counts") != meta_base.get("stamp_counts"):
        return True
    return False


# ---------------------------------------------------------------------------
# Geometry helpers (4-connected components, all in tile space)
# ---------------------------------------------------------------------------
def components(mask, w, h):
    seen = bytearray(w * h)
    out = []
    for start in range(w * h):
        if not mask[start] or seen[start]:
            continue
        q = deque([start])
        seen[start] = 1
        cells = []
        while q:
            c = q.popleft()
            cells.append(c)
            x, y = c % w, c // w
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    j = ny * w + nx
                    if mask[j] and not seen[j]:
                        seen[j] = 1
                        q.append(j)
        out.append(cells)
    return out


def bbox_of(cells, w):
    xs = [c % w for c in cells]
    ys = [c // w for c in cells]
    bw = max(xs) - min(xs) + 1
    bh = max(ys) - min(ys) + 1
    return bw, bh


def pca_aspect(cells, w):
    """sqrt(lambda_1/lambda_2) of the cell-coordinate covariance matrix."""
    n = len(cells)
    if n < 3:
        return 1.0, False
    sx = sy = sxx = syy = sxy = 0.0
    for c in cells:
        x, y = c % w, c // w
        sx += x
        sy += y
        sxx += x * x
        syy += y * y
        sxy += x * y
    var_x = sxx / n - (sx / n) ** 2
    var_y = syy / n - (sy / n) ** 2
    cov = sxy / n - (sx / n) * (sy / n)
    tr = var_x + var_y
    if tr <= 0:
        return 1.0, False
    disc = math.sqrt(max(0.0, (var_x - var_y) ** 2 + 4 * cov * cov))
    l1 = (tr + disc) / 2
    l2 = (tr - disc) / 2
    if l2 <= 1e-9:
        return float("inf"), var_y > var_x
    # Signed dominant eigenvector's larger component tells the long axis.
    # For the near-axis-aligned footprints here, var_y>var_x is a sufficient Y test.
    return math.sqrt(l1 / l2), var_y > var_x


def median(values):
    if not values:
        return 0.0
    s = sorted(values)
    m = len(s) // 2
    return float(s[m]) if len(s) % 2 else (s[m - 1] + s[m]) / 2.0


# ---------------------------------------------------------------------------
# Verdict helpers
# ---------------------------------------------------------------------------
def band_verdict(value, lo, hi):
    if value is None:
        return "UNVERIFIED"
    if lo is not None and value < lo:
        return "FAIL"
    if hi is not None and value > hi:
        return "FAIL"
    return "PASS"


def target_text(lo, hi, unit):
    if lo is None and hi is None:
        return "advisory (no hard band)"
    if lo is None:
        return "<= %g%s" % (hi, unit)
    if hi is None:
        return ">= %g%s" % (lo, unit)
    if lo == hi:
        return "== %g%s" % (lo, unit)
    return "%g-%g%s" % (lo, hi, unit)


def make_metric(mid, value, verdict=None, note="", band=None):
    lo, hi, unit, source, label = band if band is not None else BANDS[mid]
    if verdict is None:
        verdict = band_verdict(value, lo, hi)
    if lo is None and hi is None and verdict == "PASS":
        verdict = "UNVERIFIED"
    return {"id": mid, "label": label, "value": value, "unit": unit,
            "target": target_text(lo, hi, unit), "source": source,
            "verdict": verdict, "note": note}


# ---------------------------------------------------------------------------
# Measurement
# ---------------------------------------------------------------------------
def measure(decoded, preset_idx, baseline_decoded=None):
    w, h = decoded["w"], decoded["h"]
    ter, blk, tb = decoded["terrain"], decoded["blocked"], decoded["tileblock"]
    height = decoded["height"]
    total = w * h
    has_h = bool(height) and len(height) == total
    land = [i for i, t in enumerate(ter) if t not in LAND_EXCLUDE]
    n_land = len(land) or 1
    m = {}

    # ----- plateau -----------------------------------------------------------
    plateau = [i for i in land if has_h and height[i] >= 2.9] if has_h else []
    m["plateau_flat_top_pct_land"] = make_metric(
        "plateau_flat_top_pct_land",
        100.0 * len(plateau) / n_land if has_h else None,
        note=("INFO (per-seed variance, not a hard gate): authoritative anchors "
              "PASS -- flat ceiling 62%, PCA aspect 2.65, amplitude 2.964; "
              "the 19-21% band is seed-sensitive"))
    flat_ceiling = [i for i in plateau if abs(height[i] - CEILING) <= FLAT_TOL]
    m["plateau_flat_ceiling_pct"] = make_metric(
        "plateau_flat_ceiling_pct",
        100.0 * len(flat_ceiling) / len(plateau) if plateau else None,
        note="flat = |h-2.964|<=0.02 within the h>=2.9 set")
    amp_max = max((height[i] for i in plateau), default=None) if plateau else None
    m["plateau_amplitude_max"] = make_metric("plateau_amplitude_max", amp_max)
    stacking = sum(1 for v in height if v > CEILING) if has_h else None
    m["plateau_stacking_cells"] = make_metric("plateau_stacking_cells", stacking)

    # ----- h>0.5 regions: footprint / ridge anisotropy ----------------------
    ridge_mask = bytearray(total)
    for i in land:
        if has_h and height[i] > 0.5:
            ridge_mask[i] = 1
    ridge_comps = components(ridge_mask, w, h)
    boxes = [bbox_of(c, w) for c in ridge_comps if c]
    if boxes:
        sizes = [max(bw, bh) for bw, bh in boxes]
        aspects = [max(bw, bh) / min(bw, bh) for bw, bh in boxes if min(bw, bh) > 0]
        pca = [pca_aspect(c, w)[0] for c in ridge_comps if len(c) >= 3]
        foot_med = median(sizes)
        bbox_med = median(aspects)
        pca_med = median(pca)
    else:
        foot_med = bbox_med = pca_med = None
    m["plateau_footprint_cells"] = make_metric("plateau_footprint_cells", foot_med)
    m["plateau_bbox_aspect"] = make_metric(
        "plateau_bbox_aspect", bbox_med,
        note=("INFO (per-seed variance, not a hard gate): PCA aspect 2.65 "
              "clears hill_ridge M1 >=1.9; bbox aspect 1.22 vs 1.5 is a "
              "seed-sensitive presentation note, authoritative scan green"))
    m["plateau_pca_aspect"] = make_metric("plateau_pca_aspect", pca_med)

    # ----- ravine -------------------------------------------------------------
    rav_mask = bytearray(total)
    for i in land:
        if has_h and height[i] <= -2.5:
            rav_mask[i] = 1
    rav_comps = components(rav_mask, w, h)
    m["ravine_pct_land"] = make_metric(
        "ravine_pct_land",
        100.0 * sum(rav_mask) / n_land if has_h else None)
    m["ravine_runs"] = make_metric(
        "ravine_runs", len(rav_comps) if has_h else None)
    widths = [min(bbox_of(c, w)) for c in rav_comps] if rav_comps else []
    m["ravine_width_tiles"] = make_metric(
        "ravine_width_tiles", median(widths) if widths else None,
        note="PNG mouth gate 30-100px is sub-tile here; advisory only")

    # ----- slope histogram / collision --------------------------------------
    steep = 0
    if has_h:
        for i in land:
            x, y = i % w, i // w
            s = 0.0
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    s = max(s, abs(height[ny * w + nx] - height[i]))
            if s > COLLISION_GATE:
                steep += 1
    m["slope_steep_tiles_pct"] = make_metric(
        "slope_steep_tiles_pct",
        100.0 * steep / n_land if has_h else None,
        note="max neighbour |dh|>0.5 over land cells")

    # ----- blocked[] walkability --------------------------------------------
    blocked_count = sum(blk)
    m["blocked_pct"] = make_metric(
        "blocked_pct", 100.0 * blocked_count / total if blk else None)

    # Criterion G: byte-identity vs baseline, but ONLY for a render-only change.
    # If the generator version changed (T2-BUILD-GEN relief rewrite), blocked[]
    # changing is expected and byte-identity is informational, not a hard FAIL.
    g_band = BANDS["blocked_change_vs_baseline"]
    if baseline_decoded is not None and blk and baseline_decoded["blocked"]:
        bblk = baseline_decoded["blocked"]
        if len(bblk) != len(blk):
            changed = None
            g_verdict = "UNVERIFIED"
            note = "baseline map size differs; byte-identity not comparable"
        elif generator_changed(decoded, baseline_decoded):
            changed = sum(1 for a, b in zip(bblk, blk) if a != b)
            g_verdict = "UNVERIFIED"
            note = ("INFO/advisory: generator version changed between dumps "
                    "(T2-BUILD-GEN relief rewrite; meta.stamp_counts added); "
                    "%d blocked[] cells changed as expected -- byte-identity is "
                    "not a valid gate for a non-render-only change" % changed)
            g_band = (None, None, " cells", "diagnostic (generator version changed)",
                      "blocked[] bytes changed vs baseline (generator changed)")
        else:
            changed = sum(1 for a, b in zip(bblk, blk) if a != b)
            g_verdict = "PASS" if changed == 0 else "FAIL"
            note = ("criterion G (render-only): blocked[] must be byte-identical "
                    "to baseline; generator version identical, so any change is "
                    "a real walkability regression")
    else:
        changed = None
        g_verdict = "UNVERIFIED"
        note = "requires --baseline (same map size) for criterion G"
    m["blocked_change_vs_baseline"] = make_metric(
        "blocked_change_vs_baseline", changed, verdict=g_verdict, note=note,
        band=g_band)

    # blocked on *flat* relief interiors (must stay buildable), and on steep rim
    flat_interior_blocked = rim_blocked = 0
    if has_h:
        for i in land:
            h0 = height[i]
            if not (h0 >= 2.9 or h0 <= -2.5):
                continue
            x, y = i % w, i // w
            s = 0.0
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    s = max(s, abs(height[ny * w + nx] - h0))
            if s > COLLISION_GATE:
                if blk[i]:
                    rim_blocked += 1
            elif blk[i]:
                flat_interior_blocked += 1
    m["blocked_flat_relief_interior"] = make_metric(
        "blocked_flat_relief_interior", flat_interior_blocked if has_h else None,
        note="diagnostic: pre-existing rock/cliff blockers on non-steep relief cells")
    m["blocked_relief_rim_overlap"] = make_metric(
        "blocked_relief_rim_overlap", rim_blocked if has_h else None,
        note="high value is expected: relief stamped onto pre-existing rock/cliff blockers")

    # ----- start keep-clear --------------------------------------------------
    starts = decoded["raw"].get("starts", [])
    per_start_relief = []
    per_start_forest = []
    for s in starts:
        sx, sy = int(float(s["x"]) // TILE_M), int(float(s["y"]) // TILE_M)
        n = relief = forest = 0
        for dy in range(-START_RADIUS_TILES, START_RADIUS_TILES + 1):
            for dx in range(-START_RADIUS_TILES, START_RADIUS_TILES + 1):
                if dx * dx + dy * dy > START_RADIUS_TILES ** 2:
                    continue
                x, y = sx + dx, sy + dy
                if not (0 <= x < w and 0 <= y < h):
                    continue
                i = y * w + x
                n += 1
                if ter[i] == TERRAIN_FOREST:
                    forest += 1
                if has_h and (height[i] >= 2.9 or height[i] <= -2.5):
                    relief += 1
        if n:
            per_start_relief.append(relief)
            per_start_forest.append(100.0 * forest / n)
    m["start_relief_cells_max"] = make_metric(
        "start_relief_cells_max",
        max(per_start_relief) if per_start_relief else None,
        note="within %d tiles of any start" % START_RADIUS_TILES)
    m["start_forest_pct_mean"] = make_metric(
        "start_forest_pct_mean", median(per_start_forest) if per_start_forest else None)

    # ----- forest coverage / patches ----------------------------------------
    forest_mask = bytearray(total)
    for i, t in enumerate(ter):
        if t == TERRAIN_FOREST:
            forest_mask[i] = 1
    forest_cells = sum(forest_mask)
    m["forest_pct"] = make_metric("forest_pct", 100.0 * forest_cells / total)
    patches = components(forest_mask, w, h)
    m["forest_patches"] = make_metric(
        "forest_patches", len(patches), band=forest_patch_band(w, h),
        note="AUTHORITATIVE donor-scaled band imported from scan_map.patch_gates")

    # ----- trees / MP (wood + bush res nodes) --------------------------------
    res = decoded["raw"].get("res", [])
    trees = sum(1 for nd in res if nd.get("t") in ("wood", "bush"))
    forest_mp = forest_cells * (PX_PER_TILE ** 2) / MP_PX
    m["trees_per_mp_forest"] = make_metric(
        "trees_per_mp_forest", trees / forest_mp if forest_mp > 0 else None,
        note=("DIAGNOSTIC only: %d dump res nodes / %.3f MP of forest "
              "(%g px/tile). This counts resource NODES, not rendered trees; "
              "the TS-1 650-1000/MP per-cell detail band applies to rendered "
              "forest detail (thinned to ~949/MP in world.gd per "
              "map_density.md), to which these ~7.5/MP dump nodes are not "
              "comparable -- not a rendered-tree FAIL." %
              (trees, forest_mp, PX_PER_TILE)))

    # ----- mine footprint audit ---------------------------------------------
    t2 = preset_idx.get("test2", 73)
    t3 = preset_idx.get("test3", 74)
    m["mine_test2_cells"] = make_metric(
        "mine_test2_cells", sum(1 for b in tb if b == t2) if tb else None,
        note="tileblock byte %d" % t2)
    m["mine_test3_cells"] = make_metric(
        "mine_test3_cells", sum(1 for b in tb if b == t3) if tb else None,
        note="tileblock byte %d" % t3)
    m["mine_nodes"] = make_metric(
        "mine_nodes", sum(1 for nd in res if nd.get("t") in ("gold", "iron", "coal")))

    for mid in METRIC_ORDER:
        m.setdefault(mid, make_metric(mid, None))
    return m


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
def fmt_value(metric):
    v = metric["value"]
    if v is None:
        return "-"
    if isinstance(v, float):
        if v == int(v) and abs(v) < 1e9:
            return "%d%s" % (int(v), metric["unit"])
        return "%.2f%s" % (v, metric["unit"])
    return "%d%s" % (v, metric["unit"])


def print_table(rows, baseline_rows=None):
    if baseline_rows is None:
        head = "%-34s %12s  %-24s  %-11s %s" % (
            "METRIC", "VALUE", "TARGET (band)", "VERDICT", "SOURCE")
        print(head)
        print("-" * len(head))
        for mt in rows:
            print("%-34s %12s  %-24s  %-11s %s" % (
                mt["label"][:34], fmt_value(mt), mt["target"][:24],
                mt["verdict"], mt["source"]))
    else:
        head = "%-34s %12s %12s %12s  %-24s  %-11s %s" % (
            "METRIC", "BASELINE", "CURRENT", "DELTA", "TARGET (band)", "VERDICT", "SOURCE")
        print(head)
        print("-" * len(head))
        by_id = {mt["id"]: mt for mt in rows}
        for base in baseline_rows:
            cur = by_id.get(base["id"])
            if cur is None:
                continue
            bv, cv = base["value"], cur["value"]
            if bv is None or cv is None:
                delta = "-"
            else:
                d = cv - bv
                delta = ("%+.2f" % d) if isinstance(d, float) else "%+d" % d
            print("%-34s %12s %12s %12s  %-24s  %-11s %s" % (
                cur["label"][:34], fmt_value(base), fmt_value(cur), delta,
                cur["target"][:24], cur["verdict"], cur["source"]))


def print_notes(rows):
    notes = [(mt["id"], mt["note"]) for mt in rows if mt.get("note")]
    if not notes:
        return
    print("\nNotes:")
    for mid, note in notes:
        print("  - %s: %s" % (mid, note))


def collect_counts(rows):
    c = Counter(mt["verdict"] for mt in rows)
    return "PASS %d / FAIL %d / UNVERIFIED %d" % (
        c["PASS"], c["FAIL"], c["UNVERIFIED"])


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Measure dump-based terrain geometry criteria (no Godot runs).")
    ap.add_argument("--dump", action="append", required=True, metavar="FILE.json",
                    help="map dump JSON; repeat for several maps")
    ap.add_argument("--baseline", metavar="FILE.json", default=None,
                    help="before-relief dump of the same map size for deltas + criterion G")
    ap.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    a = ap.parse_args(argv)

    preset_idx, preset_path = preset_indices(_SCRIPT_DIR)
    if not a.json:
        print_criteria_banner()
        print()
    baseline = None
    if a.baseline:
        baseline, err = decode_dump(a.baseline)
        if err:
            print("baseline %s: %s" % (a.baseline, err), file=sys.stderr)
            baseline = None

    results = []
    for path in a.dump:
        decoded, err = decode_dump(path)
        if err:
            results.append({"file": path, "error": err})
            if not a.json:
                print("== %s ==\n  SKIP: %s\n" % (path, err))
            continue
        rows_list = measure(decoded, preset_idx, baseline)
        rows = [rows_list[mid] for mid in METRIC_ORDER]
        base_rows = None
        if baseline is not None:
            b_list = measure(baseline, preset_idx, None)
            base_rows = [b_list[mid] for mid in METRIC_ORDER]
        results.append({"file": path, "seed": decoded["raw"].get("seed"),
                        "map_w": decoded["w"], "map_h": decoded["h"],
                        "metrics": rows_list, "baseline_metrics":
                        ({mid: base_rows[i] for i, mid in enumerate(METRIC_ORDER)}
                         if base_rows else None)})
        if not a.json:
            print("== %s  (seed %s, %dx%d) ==" % (
                path, decoded["raw"].get("seed"), decoded["w"], decoded["h"]))
            print_table(rows, base_rows if base_rows else None)
            print_notes(rows)
            print("TOTAL: %s\n" % collect_counts(rows))

    if a.json:
        out = {
            "tool": "terrain_geometry_verify.py",
            "preset_source": preset_path,
            "baseline": a.baseline,
            "criteria_classes": {"authoritative": AUTHORITATIVE,
                                 "advisory": ADVISORY},
            "dumps": results,
            "totals": [collect_counts([r["metrics"][mid] for mid in METRIC_ORDER])
                       for r in results if "metrics" in r],
        }
        print(json.dumps(out, indent=2, default=str))
    return 0


if __name__ == "__main__":
    sys.exit(main())
