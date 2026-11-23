#!/usr/bin/env python3
"""T6-U06 -- Support-cast family mini-baker (piece-by-piece verification).

Family keys (verbatim from T6_WAVE_PLAN.md LANE UNITS):
    officer, officer18, drummer, drummer18, priest, pope, padre, mullah,
    bagpiper
Donor base mapping is IDENTITY (each key == its donor base name), matching
the read-only table in app/tools/bake_sprites.py.

DESIGN -- thin wrapper, original NEVER edited
---------------------------------------------
This module imports the PROVEN reader/camera/skinning logic from the
read-only reference ``app/tools/bake_sprites.py`` (qmat transposed
quaternions, bone-0 de-travel to a single global idle HOME with a per-clip
reference only for death, one shared stand + one death camera group centred
at XZ=(0,0), projected long-side ortho over all 8 azimuths, attach-prop
compositing, ground_anchor_ay, Workbench/Cycles emission setup) and calls
its ``bake_unit``. The reference file is NEVER written to.

DONOR TRUTH FOR THIS FAMILY (observed, read-only)
-------------------------------------------------
NONE of these 9 units ships an ``attach/<base>_tools.actor`` manifest or
any ``<base>_<tool>.oss`` prop (the donor attach/ directory only carries
ship flags). Bug 5 of UNIT_BAKING_FIX.md -- composite the donor's own prop
mesh into the body -- is therefore NOT APPLICABLE to the support family;
every action here has ``tool == None``. This is confirmed by the live
``app/assets/models/anim/index.json`` (all 9 keys have tool:null).

MODES
-----
Pure Python (no Blender needed):
    python app/tools/unit_bakers/support.py --game ... --truth-only
    python app/tools/unit_bakers/support.py --game ... --verify
Under Blender (bake):
    blender --background --factory-startup \
      --python app/tools/unit_bakers/support.py -- \
      --game "C:\\Games\\Cossacks 3" \
      --out app/shots/unit_pieces/support --only officer \
      --size 160 --engine workbench

Staging outputs (PNG sheets + staging_manifest.json + donor_truth.json)
go ONLY to --out (normally app/shots/unit_pieces/support/). Scratch -- per
cell renders and converted donor textures -- goes to the SYSTEM TEMP dir,
never inside res://. No raw donor format is ever copied into the repo.
"""
import argparse
import json
import math
import os
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parent
APP = TOOLS.parent

# Key -> donor base. Identity mapping for this family (see bake_sprites.TABLE).
KEYS = {
    "officer": "officer",
    "officer18": "officer18",
    "drummer": "drummer",
    "drummer18": "drummer18",
    "priest": "priest",
    "pope": "pope",
    "padre": "padre",
    "mullah": "mullah",
    "bagpiper": "bagpiper",
}

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_OUT = str(APP / "shots" / "unit_pieces" / "support")
DEFAULT_IDX = str(APP / "assets" / "models" / "anim" / "land_units" / "index.json")

# The donor AAF clips the family actually resolves to, in baker priority
# order (bake_sprites.bake_unit plan). Kept here for the truth dump only.
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
    ap.add_argument("--idx", default=DEFAULT_IDX, help="live index.json to compare in --verify")
    ap.add_argument("--truth-only", action="store_true",
                    help="dump donor truth (pure Python, no Blender)")
    ap.add_argument("--verify", action="store_true",
                    help="verify staging sheets vs donor truth + live index (no Blender)")
    return ap.parse_args(rest)


# ---------------------------------------------------------------------------
# Pure-Python donor readers (mirrors bake_sprites.py; no bpy needed).
# ---------------------------------------------------------------------------
def read_oss_header(path):
    with open(path, "rb") as f:
        k, fps, bones, verts, faces, uvs = struct.unpack("<6i", f.read(24))
    return dict(frames=k, fps=fps, bones=bones, verts=verts, faces=faces, uvs=uvs)


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
                 if f.startswith(base + "_") and f.endswith(".oss")] if os.path.isdir(propdir) else []
        manifest = os.path.join(propdir, base + "_tools.actor")
        expected = {}
        for action, names, n, loop in PLAN_TRUTH:
            rng = next((acts[x] for x in names if x in acts), None)
            if not rng:
                continue
            frs = sample(rng, n)
            expected[action] = {
                "aaf_range": list(rng), "sampled_frames": len(frs),
                "frames_list": frs,
                "duration": round((rng[1] - rng[0] + 1) / max(1, hdr["fps"]), 3),
                "loop": loop,
                "tool": None,
            }
        out[key] = {
            "base": base, "oss": hdr, "aaf_all": acts,
            "attach_props": props, "tools_manifest": os.path.exists(manifest),
            "expected": expected,
        }
    return out


def print_truth(truth):
    for key, d in truth.items():
        h = d["oss"]
        print("%-10s base=%-10s frames=%4d fps=%d bones=%2d verts=%4d props=%d manifest=%s" % (
            key, d["base"], h["frames"], h["fps"], h["bones"], h["verts"],
            len(d["attach_props"]), d["tools_manifest"]))
        for a, e in d["expected"].items():
            print("    %-7s aaf=%-12s sample=%2d dur=%-6s loop=%-5s tool=%s" % (
                a, str(e["aaf_range"]), e["sampled_frames"], e["duration"],
                e["loop"], e["tool"]))
        unused = [x for x in d["aaf_all"] if x not in
                  {n for a, names, _n, _l in PLAN_TRUTH for n in names}]
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

    Mirrors app/tools/sheet_metrics.py but thresholds alpha at >8 (per the
    T6-U06 ticket) instead of Pillow's implicit >0, and also flags a CLIP
    when any cell's union touches an edge.
    """
    from PIL import Image
    im = Image.open(path).convert("RGBA")
    cols, rows = im.width // cell, im.height // cell
    x0 = y0 = cell
    x1 = y1 = 0
    for r in range(rows):
        for c in range(cols):
            tile = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
            mask = tile.getchannel("A").point(lambda v: 255 if v > 8 else 0)
            bb = mask.getbbox()
            if bb is None:
                continue
            x0, y0 = min(x0, bb[0]), min(y0, bb[1])
            x1, y1 = max(x1, bb[2]), max(y1, bb[3])
    if x1 <= x0 or y1 <= y0:
        return None
    return {
        "bbox": [x0, y0, x1, y1],
        "fig_h": round((y1 - y0) / float(cell), 4),
        "foot": round(y1 / float(cell), 4),
        "cx": round((x0 + x1) / 2.0 / float(cell), 4),
        "clip": bool(x0 <= 0 or y0 <= 0 or x1 >= cell or y1 >= cell),
    }


def bake(a):
    ref = import_reference()
    # The reference baker reads these module globals in setup_scene().
    ref._ENGINE = a.engine
    ref._SAMPLES = a.samples
    from PIL import Image  # noqa: F401 (available under Blender via ref path)
    import tempfile
    keys = [k for k in KEYS if not a.only or k in set(a.only.split(","))]
    if not keys:
        print("no keys selected")
        return 2
    out = str(Path(a.out).expanduser().resolve())
    game = str(Path(a.game).expanduser().resolve())
    os.makedirs(out, exist_ok=True)
    tmp = os.path.join(tempfile.gettempdir(), "cossacks_bake",
                       os.path.basename(out))
    os.makedirs(tmp, exist_ok=True)

    truth = donor_truth(game)
    with open(os.path.join(out, "donor_truth.json"), "w", encoding="utf-8") as f:
        json.dump(truth, f, indent=1)

    # Merge with any existing staging manifest: the family may be baked in
    # several invocations (one unit first, then the rest), and each run must
    # ACCUMULATE keys rather than overwrite earlier verified entries.
    mf_path = os.path.join(out, "staging_manifest.json")
    if os.path.exists(mf_path):
        try:
            manifest = json.load(open(mf_path, encoding="utf-8"))
        except Exception:
            manifest = {}
    else:
        manifest = {}
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
                ad["bbox"] = met["bbox"]
                ad["fig_h"] = met["fig_h"]
                ad["foot"] = met["foot"]
                ad["cx"] = met["cx"]
                ad["clip"] = met["clip"]
        manifest[key] = entry
        print("UNIT", key, "actions", ",".join(entry["actions"]), flush=True)
    with open(mf_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1)
    print("BAKE COMPLETE", ",".join(keys),
          "(manifest now %d keys)" % len(manifest), flush=True)
    print("BAKE DONE -- slot B free", flush=True)
    return 0


# ---------------------------------------------------------------------------
# Verify mode (pure Python + Pillow): staging vs donor truth + live index.
# ---------------------------------------------------------------------------
def _same(a, b, tol=None):
    if tol is not None and isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(float(a) - float(b)) <= tol
    return a == b


def verify(a):
    from PIL import Image
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
        # 1. frames/duration/loop/tool vs donor truth
        for action, ad in acts.items():
            exp = truth.get(key, {}).get("expected", {}).get(action)
            ok = True
            if exp:
                ok &= ad["frames"] == exp["sampled_frames"]
                ok &= abs(ad["duration"] - exp["duration"]) <= 0.002
                ok &= ad["loop"] == exp["loop"]
                ok &= ad.get("tool") == exp["tool"]
            print("  %-7s donor_truth=%s frames=%s dur=%s tool=%s -> %s" % (
                action, "OK" if ok else "FAIL", ad["frames"], ad["duration"],
                ad.get("tool"), "PASS" if ok else "FAIL"))
            allpass &= ok
        # 2. byte-comparable metrics vs live index
        if key in live:
            la = live[key]["actions"]
            for action, ad in acts.items():
                if action not in la:
                    print("  LIVE missing", action); allpass = False; continue
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
        # 3. GROUP_OK: one stand group + one death group
        stand = [a for a in acts if a != "death"]
        def group_ok(names):
            if not names:
                return True
            ref0 = acts[names[0]]
            fields = ("ortho", "center", "ax", "ay")
            return all(all(_same(acts[n][f], ref0[f], tol=1e-3 if f == "ortho" else None)
                           for f in fields) for n in names)
        gok = group_ok(stand) and group_ok(["death"] if "death" in acts else [])
        print("  GROUP_OK stand=%s death=%s -> %s" % (
            group_ok(stand), group_ok(["death"] if "death" in acts else []),
            "PASS" if gok else "FAIL"))
        allpass &= gok
        # 4. CLIP + distinct dirs per action sheet (alpha>8)
        for action, ad in acts.items():
            p = os.path.join(out, "%s_%s.png" % (key, action))
            im = Image.open(p).convert("RGBA")
            cols, rows = im.width // cell, im.height // cell
            clips = 0
            distinct = 0
            for r in range(rows):
                hashes = []
                for c in range(cols):
                    tile = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
                    mask = tile.getchannel("A").point(lambda v: 255 if v > 8 else 0)
                    bb = mask.getbbox()
                    if bb is None:
                        continue
                    if bb[0] <= 0 or bb[1] <= 0 or bb[2] >= cell or bb[3] >= cell:
                        clips += 1
                    hashes.append(hash(tile.tobytes()))
                if len(set(hashes)) == cols:
                    distinct += 1
            print("  SHEET %-7s %dx%d cells, edge-touch=%d, rows with 8 distinct dirs=%d/%d -> %s" % (
                action, cols, rows, clips, distinct, rows,
                "PASS" if clips == 0 and distinct == rows else "FAIL"))
            allpass &= (clips == 0 and distinct == rows)
            # 5. foot pin proxy: shared projected anchor ax == 0.5, within band
            ax = ad.get("ax"); ay = ad.get("ay")
            anchor_ok = (ax is not None and abs(ax - 0.5) <= 0.02)
            allpass &= anchor_ok
            print("     anchor ax=%s ay=%s fig_h=%s foot=%s cx=%s clip_flag=%s -> %s" % (
                ax, ay, ad.get("fig_h"), ad.get("foot"), ad.get("cx"),
                ad.get("clip"), "PASS" if anchor_ok else "FAIL"))
    print("\nVERDICT", "ALL PASS" if allpass else "FAIL (see above)")
    return 0 if allpass else 1


def main():
    a = parse_args()
    if a.truth_only:
        print_truth(donor_truth(str(Path(a.game).expanduser())))
        return 0
    if a.verify:
        return verify(a)
    return bake(a)


if __name__ == "__main__":
    sys.exit(main())
