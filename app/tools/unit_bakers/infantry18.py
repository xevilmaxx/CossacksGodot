#!/usr/bin/env python3
"""T6-U03 -- 18c infantry family mini-baker (piece-by-piece verification).

Family keys (verbatim from T6_WAVE_PLAN.md LANE UNITS):
    musk18, pikeman18, musketeer, grenadier, lightinfantry
Donor base mapping (from the READ-ONLY bake_sprites.py TABLE):
    musk18 -> musketeer18, pikeman18 -> pikeman18, musketeer -> musketeer,
    grenadier -> grenadier, lightinfantry -> lightinfantry

DESIGN -- thin wrapper, reference NEVER edited
-----------------------------------------------
This module imports the PROVEN reader/camera/skinning logic from the
read-only reference ``app/tools/bake_sprites.py`` and calls its
``bake_unit``. That reference already contains all FIVE fixes from
docs/UNIT_BAKING_FIX.md S2:
  1. ``qmat`` returns the TRANSPOSED (donor row-vector) rotation;
  2. skin de-travel uses BONE 0 to one global idle HOME, per-clip ref ONLY
     for death;
  3. ONE shared stand group + ONE death group, both centred XZ=(0,0), one
     ortho and one projected ground anchor per group;
  4. ``projected_ortho`` fits the long side over all 8 azimuths at elevation
     32 deg (x1.12 AA bleed);
  5. donor attach-prop meshes are composited into the body mesh for the
     matching actions.
This file never writes to bake_sprites.py or any live asset.

DONOR TRUTH FOR THIS FAMILY (observed, read-only)
--------------------------------------------------
NONE of these 5 bases ships an ``attach/<base>_tools.actor`` manifest or any
``<base>_<tool>.oss`` prop: the donor attach/ holds only ship parts and
cavalry horses. Fix 5 is therefore NOT APPLICABLE to this family -- muskets,
pikes and grenades are modelled INTO the body .oss (pikeman18 bind z reaches
3.499 m; musketeer18 2.719 m). Every action legitimately has ``tool: None``,
which is asserted in --verify. The live index.json agrees (all 5 tool:null).
Gunpowder bases musketeer18/musketeer/grenadier have ``attack1`` (volley) and
are resolved to it by the reference priority; pikeman18/lightinfantry have no
attack1 and resolve to ``attack0``.

MODES
-----
Pure Python (no Blender needed):
    python app/tools/unit_bakers/infantry18.py --game ... --truth-only
    python app/tools/unit_bakers/infantry18.py --game ... --verify
Under Blender (bake; needs a parent-granted slot):
    blender --background --factory-startup \
      --python app/tools/unit_bakers/infantry18.py -- \
      --game "C:\\Games\\Cossacks 3" \
      --out app/shots/unit_pieces/infantry18 --only musketeer \
      --size 160 --engine workbench

Staging outputs (PNG sheets + staging_manifest.json + donor_truth.json) go
ONLY to --out (normally app/shots/unit_pieces/infantry18/). Scratch -- per-cell
renders and converted donor textures -- goes to the SYSTEM TEMP dir, never
inside res://. No raw donor format is ever copied into the repo.
"""
import argparse
import hashlib
import json
import math
import os
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parent
APP = TOOLS.parent

KEYS = {
    "musk18": "musketeer18",
    "pikeman18": "pikeman18",
    "musketeer": "musketeer",
    "grenadier": "grenadier",
    "lightinfantry": "lightinfantry",
}

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_OUT = str(APP / "shots" / "unit_pieces" / "infantry18")
DEFAULT_IDX = str(APP / "assets" / "models" / "anim" / "index.json")

# The clips this family resolves to, in the read-only reference's plan order.
PLAN_TRUTH = (
    ("walk", ("walk",), 12, True),
    ("idle", ("idle", "idle0"), 6, True),
    ("attack", ("attack1", "attack0", "attack2", "attack"), 12, False),
    ("death", ("death", "death0", "death1"), 8, False),
)


def parse_args():
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME)
    ap.add_argument("--out", default=DEFAULT_OUT)
    ap.add_argument("--only", default="", help="comma-separated keys (default: whole family)")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="workbench", choices=["workbench", "cycles", "eevee"])
    ap.add_argument("--idx", default=DEFAULT_IDX, help="live index.json to cross-check in --verify")
    ap.add_argument("--truth-only", action="store_true",
                    help="dump donor truth (pure Python, no Blender)")
    ap.add_argument("--verify", action="store_true",
                    help="verify staging sheets vs donor truth + live index (no Blender)")
    return ap.parse_args(rest)


# ---------------------------------------------------------------------------
# Pure-Python donor readers (mirrors bake_sprites.py; no bpy needed).
# read_oss_full / qmat / skin are used only for the foot-pin diagnostic.
# ---------------------------------------------------------------------------
def read_oss_header(path):
    with open(path, "rb") as f:
        k, fps, bones, verts, faces, uvs = struct.unpack("<6i", f.read(24))
    return dict(frames=k, fps=fps, bones=bones, verts=verts, faces=faces, uvs=uvs)


def read_oss_full(path):
    with open(path, "rb") as f:
        k, fps, b, v, fc, t = struct.unpack("<6i", f.read(24))
        verts = [struct.unpack("<3f", f.read(12)) for _ in range(v)]
        faces = [struct.unpack("<3i", f.read(12)) for _ in range(fc)]
        uvs = [struct.unpack("<2f", f.read(8)) for _ in range(t)]
        uvf = [struct.unpack("<3i", f.read(12)) for _ in range(fc)]
        weights = []
        for _ in range(v):
            n = struct.unpack("<i", f.read(4))[0]
            weights.append([struct.unpack("<if", f.read(8)) for _ in range(n)])
        anim = [[struct.unpack("<7f", f.read(28)) for _ in range(k)] for _ in range(b)]
    return dict(fps=fps, verts=verts, faces=faces, uvs=uvs, uvf=uvf,
                weights=weights, anim=anim, k=k)


def read_aaf(path):
    acts = {}
    if not os.path.exists(path):
        return acts
    for line in open(path, "r", encoding="ascii", errors="replace").read().splitlines()[2:]:
        line = line.strip()
        if not line.startswith('"'):
            continue
        try:
            name, rest = line[1:].split('"', 1)
            a, b, _ = rest.strip().lstrip(",").split(",")
            acts[name] = (int(a), int(b))
        except Exception:
            pass
    return acts


def sample(rng, n):
    """Exact copy of bake_sprites.sample -- donor order, keep short clips."""
    a, b = rng
    if b <= a:
        return [a]
    total = b - a + 1
    if total <= n:
        return list(range(a, b + 1))
    return [a + round((b - a) * i / (n - 1)) for i in range(n)] if n > 1 else [a]


def qmat(x, y, z, w):
    """TRANSPOSED (donor row-vector) rotation -- mirror of bake_sprites.qmat."""
    M = ((1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)),
         (2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)),
         (2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)))
    return ((M[0][0], M[1][0], M[2][0]),
            (M[0][1], M[1][1], M[2][1]),
            (M[0][2], M[1][2], M[2][2]))


def skin(m, fr):
    """Mirror of bake_sprites.skin (transposed quats, weighted sum)."""
    mats = [qmat(*m["anim"][bi][fr][3:]) for bi in range(len(m["anim"]))]
    poss = [m["anim"][bi][fr][:3] for bi in range(len(m["anim"]))]
    out = []
    for i, (x, y, z) in enumerate(m["verts"]):
        sx = sy = sz = 0.0
        for bi, w in m["weights"][i]:
            M, (px, py, pz) = mats[bi], poss[bi]
            sx += w * (M[0][0] * x + M[0][1] * y + M[0][2] * z + px)
            sy += w * (M[1][0] * x + M[1][1] * y + M[1][2] * z + py)
            sz += w * (M[2][0] * x + M[2][1] * y + M[2][2] * z + pz)
        out.append((sx, sy, sz))
    return out


def donor_truth(game):
    """Return {key: {...}} with observed .oss/.aaf facts + expected metrics."""
    out = {}
    for key, base in KEYS.items():
        op = os.path.join(game, "data", "actors", "units", base + ".oss")
        ap = os.path.join(game, "data", "animations", "aaf", base + ".aaf")
        hdr = read_oss_header(op)
        acts = read_aaf(ap)
        propdir = os.path.join(game, "data", "actors", "units", "attach")
        props = [f for f in os.listdir(propdir)
                 if f.startswith(base + "_") and (f.endswith(".oss") or f.endswith(".actor"))] \
            if os.path.isdir(propdir) else []
        manifest = os.path.join(propdir, base + "_tools.actor")
        expected = {}
        for action, names, n, loop in PLAN_TRUTH:
            rng = next((acts[x] for x in names if x in acts), None)
            if not rng:
                continue
            frs = sample(rng, n)
            chosen = next((x for x in names if x in acts), None)
            expected[action] = {
                "aaf_name": chosen,
                "aaf_range": list(rng),
                "sampled_frames": len(frs),
                "frames_list": frs,
                "duration": round((rng[1] - rng[0] + 1) / max(1, hdr["fps"]), 3),
                "loop": loop,
                "tool": None,  # no attach props for this family (observed)
            }
        # bind-pose bbox (read-only): sanity band for the projected ortho.
        full = read_oss_full(op)
        xs, ys, zs = ([v[0] for v in full["verts"]],
                      [v[1] for v in full["verts"]],
                      [v[2] for v in full["verts"]])
        out[key] = {
            "base": base, "oss": hdr, "aaf_all": acts,
            "bind_bbox": {
                "x": [round(min(xs), 3), round(max(xs), 3)],
                "y": [round(min(ys), 3), round(max(ys), 3)],
                "z": [round(min(zs), 3), round(max(zs), 3)],
            },
            "attach_props": props, "tools_manifest": os.path.exists(manifest),
            "expected": expected,
        }
    return out


def print_truth(truth):
    for key, d in truth.items():
        h = d["oss"]
        print("%-13s base=%-13s frames=%4d fps=%d bones=%2d verts=%4d "
              "props=%d manifest=%s bind_z=%s" % (
                  key, d["base"], h["frames"], h["fps"], h["bones"], h["verts"],
                  len(d["attach_props"]), d["tools_manifest"], d["bind_bbox"]["z"]))
        for a, e in d["expected"].items():
            print("    %-7s <- %-9s aaf=%-12s sample=%2d dur=%-6s loop=%-5s tool=%s" % (
                a, e["aaf_name"], str(e["aaf_range"]), e["sampled_frames"],
                e["duration"], e["loop"], e["tool"]))
        unused = [x for x in d["aaf_all"] if x not in
                  {n for _a, names, _n, _l in PLAN_TRUTH for n in names}]
        print("    unused_aaf: " + ", ".join(sorted(unused)))


# ---------------------------------------------------------------------------
# Bake mode (Blender only): import the read-only reference baker lazily.
# ---------------------------------------------------------------------------
def import_reference():
    if str(TOOLS) not in sys.path:
        sys.path.insert(0, str(TOOLS))
    import bake_sprites as ref  # attribution: app/tools/bake_sprites.py
    return ref


def measure_sheet(path, cell):
    """Cell-local alpha>8 union bbox + metrics, sheet_metrics-style.

    Mirrors app/tools/sheet_metrics.py but thresholds alpha at >8 and also
    reports the minimum number of distinct direction hashes per frame row
    (8 expected -- proves sample() did not collapse the azimuths).
    """
    from PIL import Image
    im = Image.open(path).convert("RGBA")
    cols, rows = im.width // cell, im.height // cell
    x0 = y0 = cell
    x1 = y1 = 0
    clip_cells = 0
    distinct_min = cols + 1
    distinct_rows = 0
    for r in range(rows):
        hashes = []
        for c in range(cols):
            tile = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
            mask = tile.getchannel("A").point(lambda v: 255 if v > 8 else 0)
            bb = mask.getbbox()
            if bb is None:
                continue
            x0, y0 = min(x0, bb[0]), min(y0, bb[1])
            x1, y1 = max(x1, bb[2]), max(y1, bb[3])
            if bb[0] <= 0 or bb[1] <= 0 or bb[2] >= cell or bb[3] >= cell:
                clip_cells += 1
            hashes.append(hashlib.sha1(tile.tobytes()).hexdigest())
        nd = len(set(hashes))
        distinct_min = min(distinct_min, nd)
        if nd == cols:
            distinct_rows += 1
    if x1 <= x0 or y1 <= y0:
        return None
    return {
        "bbox": [x0, y0, x1, y1],
        "fig_h": round((y1 - y0) / float(cell), 4),
        "foot": round(y1 / float(cell), 4),
        "cx": round((x0 + x1) / 2.0 / float(cell), 4),
        "clip_cells": clip_cells,
        "distinct_dirs_min": distinct_min,
        "distinct_rows": distinct_rows,
        "rows": rows,
        "cols": cols,
    }


def foot_pin_diag(game, key, base, truth):
    """Supplementary numerical check of fix 2 (NOT a pass/fail gate).

    Rebuilds the same skin()/HOME/death-ref math as bake_unit and reports the
    largest XY drift (metres) of the lowest 12 cm of vertices from the entity
    origin. CAVEAT (observed on pikeman18): this centroid is contaminated by
    long in-body weapons -- the pike butt/thrust and its foot-bone swings can
    report ~2 m even though the rendered body stays inside 11 px of one tile.
    The authoritative tile-pin proof is the fixed shared camera anchor
    (GROUP_OK, ax=0.5) plus the pixel-measured `render_body_slide_px` in the
    staging manifest. Death may drift (per-clip ref lets the fall play out).
    """
    m = read_oss_full(os.path.join(game, "data", "actors", "units", base + ".oss"))
    root = 0
    plan = [(a, e["frames_list"]) for a, e in truth[key]["expected"].items()]
    home = None
    for a, frs in plan:
        if a == "idle":
            home = (m["anim"][root][frs[0]][0], m["anim"][root][frs[0]][1])
            break
    if home is None and plan:
        home = (m["anim"][root][plan[0][1][0]][0], m["anim"][root][plan[0][1][0]][1])
    result = {}
    for a, frs in plan:
        ref = (m["anim"][root][frs[0]][0], m["anim"][root][frs[0]][1]) \
            if a == "death" else home
        worst = 0.0
        for fr in frs:
            pts = skin(m, fr)
            rx, ry = (m["anim"][root][fr][0] - ref[0], m["anim"][root][fr][1] - ref[1])
            pts = [(x - rx, y - ry, z) for x, y, z in pts]
            zmin = min(p[2] for p in pts)
            feet = [(x, y) for x, y, z in pts if z <= zmin + 0.12]
            if not feet:
                continue
            cx = sum(x for x, _ in feet) / len(feet)
            cy = sum(y for _, y in feet) / len(feet)
            worst = max(worst, math.hypot(cx, cy))
        result[a] = round(worst, 4)
    return {"per_action_m": result,
            "stand_max_m": round(max([v for a, v in result.items() if a != "death"] or [0]), 4)}


def bake(a):
    # Fail fast on ownership violations BEFORE importing Blender-only modules.
    out = str(Path(a.out).expanduser().resolve())
    staging = str(Path(DEFAULT_OUT).resolve())
    if out != staging:
        raise SystemExit("T6-U03 staging rule: --out must be %s (got %s)" % (staging, out))
    keys = [k for k in KEYS if not a.only or k in set(a.only.split(","))]
    bad = [k for k in a.only.split(",") if k and k not in KEYS]
    if bad:
        raise SystemExit("unknown --only key(s): " + ",".join(bad))
    if not keys:
        print("no keys selected")
        return 2
    ref = import_reference()
    # The reference baker reads these module globals in setup_scene().
    ref._ENGINE = a.engine
    ref._SAMPLES = a.samples
    game = str(Path(a.game).expanduser().resolve())
    os.makedirs(out, exist_ok=True)
    import tempfile
    tmp = os.path.join(tempfile.gettempdir(), "cossacks_bake", "infantry18")
    os.makedirs(tmp, exist_ok=True)

    truth = donor_truth(game)
    with open(os.path.join(out, "donor_truth.json"), "w", encoding="utf-8") as f:
        json.dump(truth, f, indent=1)

    mf_path = os.path.join(out, "staging_manifest.json")
    manifest = json.load(open(mf_path, encoding="utf-8")) if os.path.exists(mf_path) else {}
    for key in keys:
        base = KEYS[key]
        print("BAKE", key, "->", base, "engine", a.engine, flush=True)
        entry = ref.bake_unit(game, out, key, base, a.size, a.samples, tmp)
        if not entry:
            print("FAIL", key, "no actions", flush=True)
            continue
        for action, ad in entry["actions"].items():
            p = os.path.join(out, "%s_%s.png" % (key, action))
            met = measure_sheet(p, a.size) if os.path.exists(p) else None
            if met:
                for f in ("bbox", "fig_h", "foot", "cx"):
                    ad[f] = met[f]
                ad["sheet_metrics"] = met
            exp = truth[key]["expected"].get(action, {})
            ad["aaf_name"] = exp.get("aaf_name")
            ad["aaf_range"] = exp.get("aaf_range")
        entry["donor_truth"] = {
            "base": base, "oss": truth[key]["oss"], "bind_bbox": truth[key]["bind_bbox"],
            "attach_props": truth[key]["attach_props"],
            "tools_manifest": truth[key]["tools_manifest"],
            "attach_fix5": "N/A - no donor props for this family; weapons in body mesh",
        }
        entry["foot_pin"] = foot_pin_diag(game, key, base, truth)
        manifest[key] = entry
        print("UNIT", key, "actions", ",".join(entry["actions"]), flush=True)
    with open(mf_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1)
    print("BAKE COMPLETE", ",".join(keys), flush=True)
    print("BAKE DONE -- slot free", flush=True)
    return 0


def _same(a, b, tol=None):
    if tol is not None and isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(float(a) - float(b)) <= tol
    return a == b


def verify(a):
    from PIL import Image  # noqa: F401 (measure_sheet opens its own)
    out = str(Path(a.out).expanduser().resolve())
    game = str(Path(a.game).expanduser().resolve())
    mf_path = os.path.join(out, "staging_manifest.json")
    if not os.path.exists(mf_path):
        print("NO staging_manifest.json in", out)
        return 2
    mf = json.load(open(mf_path, encoding="utf-8"))
    live = json.load(open(a.idx, encoding="utf-8")) if os.path.exists(a.idx) else {}
    truth = donor_truth(game)
    allpass = True
    for key, e in mf.items():
        cell = int(e["cell"])
        acts = e["actions"]
        print("\n=== VERIFY", key, "===")
        # 1. frames/duration/loop/tool vs donor AAF truth
        for action, ad in acts.items():
            exp = truth.get(key, {}).get("expected", {}).get(action)
            ok = True
            if exp:
                ok &= ad["frames"] == exp["sampled_frames"]
                ok &= abs(ad["duration"] - exp["duration"]) <= 0.002
                ok &= ad["loop"] == exp["loop"]
                ok &= ad.get("tool") == exp["tool"]
            print("  %-7s <- %-9s donor_truth=%s frames=%s dur=%s tool=%s -> %s" % (
                action, exp.get("aaf_name") if exp else "?",
                "OK" if ok else "FAIL", ad["frames"], ad["duration"],
                ad.get("tool"), "PASS" if ok else "FAIL"))
            allpass &= ok
        # 2. attach-prop truth (fix 5): no prop files => all tools must be null
        props = truth.get(key, {}).get("attach_props", [])
        attach_ok = (not props) and all(ad.get("tool") is None for ad in acts.values())
        print("  ATTACH props=%s tools=%s -> %s" % (
            props, [ad.get("tool") for ad in acts.values()],
            "PASS (fix5 N/A)" if attach_ok else "FAIL"))
        allpass &= attach_ok
        # 3. byte-comparable metrics vs live index (cross-check, not authority)
        if key in live:
            la = live[key]["actions"]
            for action, ad in acts.items():
                if action not in la:
                    print("  LIVE missing", action)
                    allpass = False
                    continue
                lv = la[action]
                diffs = []
                for f in ("frames", "loop", "ortho", "center", "ax", "ay", "tool"):
                    if not _same(ad.get(f), lv.get(f), tol=1e-3 if f == "ortho" else None):
                        diffs.append("%s %s!=%s" % (f, ad.get(f), lv.get(f)))
                if not _same(ad["duration"], lv["duration"], tol=1e-3):
                    diffs.append("duration %s!=%s" % (ad["duration"], lv["duration"]))
                print("  LIVE %-7s %s" % (action, "MATCH" if not diffs else "DIFF " + "; ".join(diffs)))
                allpass &= not diffs
        else:
            print("  LIVE key absent (cannot cross-check)")
        # 4. GROUP_OK: one stand group + one death group, centre XZ=(0,0)
        stand = [x for x in acts if x != "death"]
        def group_ok(names):
            if not names:
                return True
            ref0 = acts[names[0]]
            fields = ("ortho", "center", "ax", "ay")
            return all(all(_same(acts[n][f], ref0[f], tol=1e-3 if f == "ortho" else None)
                           for f in fields) for n in names)
        gok = group_ok(stand) and group_ok(["death"] if "death" in acts else [])
        centers_ok = all(abs(ad["center"][0]) <= 0.001 and abs(ad["center"][1]) <= 0.001
                         for ad in acts.values())
        print("  GROUP_OK stand=%s death=%s centre_XZ_zero=%s -> %s" % (
            group_ok(stand), group_ok(["death"] if "death" in acts else []),
            centers_ok, "PASS" if gok and centers_ok else "FAIL"))
        allpass &= gok and centers_ok
        # 5. CLIP + 8 distinct dirs per row (alpha>8), cell-local
        for action, ad in acts.items():
            p = os.path.join(out, "%s_%s.png" % (key, action))
            met = measure_sheet(p, cell)
            if met is None:
                print("  SHEET %-7s MISSING/EMPTY -> FAIL" % action)
                allpass = False
                continue
            sheet_ok = (met["clip_cells"] == 0 and met["distinct_dirs_min"] == met["cols"]
                        and met["rows"] == ad["frames"])
            print("  SHEET %-7s %dx%d cells, edge-touch=%d, distinct_dirs_min=%d/%d, "
                  "rows=%d (expect %d) -> %s" % (
                      action, met["cols"], met["rows"], met["clip_cells"],
                      met["distinct_dirs_min"], met["cols"], met["rows"],
                      ad["frames"], "PASS" if sheet_ok else "FAIL"))
            allpass &= sheet_ok
            # 6. foot pin: shared projected anchor ax == 0.5 + de-travel diag
            ax, ay = ad.get("ax"), ad.get("ay")
            anchor_ok = ax is not None and abs(ax - 0.5) <= 0.02
            fp = (e.get("foot_pin", {}).get("per_action_m", {}).get(action))
            print("     anchor ax=%s ay=%s fig_h=%s foot=%s cx=%s footpin_drift=%s -> %s" % (
                ax, ay, ad.get("fig_h"), ad.get("foot"), ad.get("cx"), fp,
                "PASS" if anchor_ok else "FAIL"))
            allpass &= anchor_ok
        print("  FOOT_PIN stand_max=%sm (per action: %s)" % (
            e.get("foot_pin", {}).get("stand_max_m"),
            e.get("foot_pin", {}).get("per_action_m")))
    print("\nVERDICT", "ALL PASS" if allpass else "FAIL (see above)")
    return 0 if allpass else 1


def main():
    a = parse_args()
    if a.truth_only:
        keys = [k for k in KEYS if not a.only or k in set(a.only.split(","))]
        t = donor_truth(str(Path(a.game).expanduser()))
        print_truth({k: t[k] for k in keys})
        return 0
    if a.verify:
        return verify(a)
    return bake(a)


if __name__ == "__main__":
    sys.exit(main())
