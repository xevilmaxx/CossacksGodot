#!/usr/bin/env python3
"""Bake a small, REAL Scottish sprite set from the installed donor.

Donor files are PRIVATE USE ONLY. Only the derived PNG sheets and JSON
registrations below are written into res://; every intermediate (converted
.dds -> .png, per-frame/per-cell renders) goes to a fresh tempfile.mkdtemp()
directory OUTSIDE the project.

Evidence (read-only donor inventory, 2026-11-21):
  data/actors/buildings/sco/scocen.osm  +  data/materials/buildings/sco/scocen.dds
  data/actors/buildings/sco/scohou.osm  +  data/materials/buildings/sco/scohou.dds
  data/actors/buildings/sco/scobar.osm  +  data/materials/buildings/sco/scobar.dds
  data/actors/units/swordsmansco.oss + data/animations/aaf/swordsmansco.aaf
      + data/materials/units/swordsmansco.dds
  (all present on disk; sco=21 in donor country.script; A-01 correction:
   buildings.json had ZERO sco_* keys before this tool.)

Run under Blender (Blender 5.2.3 LTS; CPU Cycles, low samples):

  blender --background --factory-startup --python app/tools/bake_scottish.py -- \
      --game "C:\\Games\\Cossacks 3" --anim app/assets/models/anim \
      --size 160 --samples 4 --engine cycles

Uses the existing portable primitives in bake_sprites.py (K-01): bake_building
for the single-view 320 px building sheets and bake_unit for the 8-direction
unit sheets. The metric fields use bake_naval.measure_sheet (alpha > 8).
"""
import argparse, json, os, struct, sys, tempfile
from pathlib import Path

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_WANT_HELP = any(a in ("-h", "--help") for a in sys.argv[1:])

if not _WANT_HELP:
    if _SCRIPT_DIR not in sys.path:
        sys.path.insert(0, _SCRIPT_DIR)
    import bake_sprites as bs
    from bake_naval import measure_sheet
else:
    bs = None
    measure_sheet = None

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

# (donor building suffix, port key suffix). All three meshes + textures exist.
BUILDINGS = (("cen", "cen"), ("hou", "hou"), ("bar", "bar"))
# Scotland-unique swordsman. 'highlander' is already a key in anim/index.json;
# this key lives only in the scoped sco_units.json so the 54-key main index
# (asserted by t_anim_metrics) stays untouched.
UNIT_KEY = "sco_highlandersword"
UNIT_BASE = "swordsmansco"
BLDG_CELL = 320


def parse_args():
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="installed donor folder (default: $COSSACKS3_DIR or "
                         "C:\\Games\\Cossacks 3)")
    ap.add_argument("--anim", required=True,
                    help="anim assets dir (holds index.json, buildings.json, sheets)")
    ap.add_argument("--size", type=int, default=160, help="unit cell size")
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="cycles",
                    choices=["cycles", "eevee", "workbench"])
    ap.add_argument("--skip-buildings", action="store_true")
    ap.add_argument("--skip-unit", action="store_true")
    return ap.parse_args(rest)


def osm_bounds(path):
    """Same donor .osm bounds recovery as compute_buildings.py (read-only)."""
    with open(path, "rb") as f:
        h = dict(zip(["magic", "version", "sw", "sh", "fs", "ns", "nv", "nu",
                      "nt", "ng", "nf", "os", "ou", "ot", "of", "og", "oe"],
                     struct.unpack("<17i", f.read(68))))
        f.seek(h["of"])
        f.read(16)
        verts = [struct.unpack("<3fI", f.read(16))[:3] for _ in range(h["nv"])]
    xs, ys, zs = zip(*verts)
    return (max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs))


def building_metrics(png_path, ortho):
    """buildings.json schema: {ortho, cell, ink:[x0,y0,x1,y1], cx, rm}.

    Uses im.getbbox(), exactly as compute_buildings.py does for the other 20
    nations, so the Scottish rows are directly comparable to theirs.
    """
    im = bs.Image.open(png_path).convert("RGBA")
    bb = im.getbbox()
    if not bb:
        return None
    x0, y0, x1, y1 = bb
    band_top = int(y1 - (y1 - y0) * 0.15)
    px = im.load()
    tot = sx = 0.0
    for yy in range(band_top, y1):
        for xx in range(x0, x1):
            a = px[xx, yy][3]
            if a > 8:
                tot += a
                sx += xx * a
    cx = (sx / tot / im.width) if tot else ((x0 + x1) * 0.5 / im.width)
    rm = ((x1 - x0) / im.width * ortho) * 0.5
    return {"ortho": ortho, "cell": im.width, "ink": [x0, y0, x1, y1],
            "cx": round(cx, 4), "rm": round(rm, 3)}


def register_buildings(game, anim, new_keys):
    """Append sco_* rows to buildings.json, preserving every existing byte."""
    path = os.path.join(anim, "buildings.json")
    raw = open(path, "rb").read().decode("utf-8")
    idx = json.loads(raw)
    # Round-trip guard: abort rather than rewrite 1506 existing rows on a
    # formatting mismatch between Python versions.
    if json.dumps(idx, indent=1).replace("\n", "\r\n") != raw:
        raise RuntimeError("buildings.json round-trip mismatch - aborting")
    added = []
    for key, m in new_keys.items():
        idx[key] = m
        added.append(key)
    out = json.dumps(idx, indent=1).replace("\n", "\r\n")
    open(path, "wb").write(out.encode("utf-8"))
    print("sco buildings.json +%d keys (total %d)" % (len(added), len(idx)),
          flush=True)


def main():
    global bs
    a = parse_args()
    if _WANT_HELP:
        return 0
    a.game = str(Path(a.game).expanduser().resolve())
    a.anim = str(Path(a.anim).expanduser().resolve())
    if bs is None:
        raise RuntimeError("bake_sprites.py could not be imported")
    bs._ENGINE = a.engine
    bs._SAMPLES = a.samples
    os.makedirs(a.anim, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix="cossacks_scottish_")
    print("sco scratch: %s" % tmp, flush=True)

    if not a.skip_buildings:
        metrics = {}
        for bld, sid in BUILDINGS:
            osm = os.path.join(a.game, "data", "actors", "buildings", "sco",
                               "sco" + bld + ".osm")
            if not os.path.exists(osm):
                print("SKIP sco_%s: no donor mesh %s" % (sid, osm), flush=True)
                continue
            dx, dy, dz = osm_bounds(osm)
            ortho = round(max(dx, dy, dz) * 1.12, 3)
            ok = bs.bake_building(a.game, a.anim, "sco", bld, BLDG_CELL, tmp, sid)
            print("sco building %s bbox=(%.2f,%.2f,%.2f) ortho=%.3f baked=%s"
                  % (sid, dx, dy, dz, ortho, ok), flush=True)
            if not ok:
                continue
            for suffix in ("", "_s1", "_s2", "_s3", "_s4", "_dead"):
                key = "sco_%s%s" % (sid, suffix)
                png = os.path.join(a.anim, key + ".png")
                if not os.path.exists(png):
                    continue
                m = building_metrics(png, ortho)
                if m:
                    metrics[key] = m
                    print("sco sheet %s %dx%d ink=%s" % (
                        key, m["cell"], bs.Image.open(png).height, m["ink"]),
                        flush=True)
        if metrics:
            register_buildings(a.game, a.anim, metrics)

    if not a.skip_unit:
        entry = bs.bake_unit(a.game, a.anim, UNIT_KEY, UNIT_BASE, a.size,
                             a.samples, tmp)
        if entry:
            for act, ad in entry["actions"].items():
                sheet = os.path.join(a.anim, "%s_%s.png" % (UNIT_KEY, act))
                if os.path.exists(sheet):
                    ad.update(measure_sheet(sheet, a.size))
            path = os.path.join(a.anim, "sco_units.json")
            json.dump({UNIT_KEY: entry}, open(path, "w", encoding="utf-8"),
                      indent=1)
            print("sco unit %s (%s): actions=%s -> %s" % (
                UNIT_KEY, UNIT_BASE, sorted(entry["actions"]), path), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
