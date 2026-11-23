#!/usr/bin/env python3
"""First naval bake: reuse bake_sprites.py primitives for ship .oss skeletons.

Run under Blender (donor is PRIVATE USE ONLY - never redistribute raw files):

  blender --background --factory-startup --python app/tools/bake_naval.py -- \
      --game "C:\\Games\\Cossacks 3" --out app/assets/models/anim/naval \
      --only yacht --size 160 --samples 4 --engine cycles

This is intentionally a THIN wrapper: all format reading, skinning, sampling,
framing, material and render helpers come from bake_sprites.py (K-01). Only the
action plan and the ship-specific bake loop live here. Every donor-derived
scratch file (converted .dds -> .png, per-cell render) is written to a fresh
tempfile.mkdtemp() directory OUTSIDE res://; only final sheets + index.json
land under --out.

index.json uses the exact same schema as anim/index.json:
  {key: {"cell": N, "actions": {action: {"frames", "duration", "loop",
         "ortho", "center", "ax", "ay", "tool",
         "bbox", "fig_h", "foot", "cx"}}}}
The four metric fields are measured from the final PNG's alpha channel
(alpha > 8, union over every dir x frame cell) before index.json is written,
so a re-bake cannot silently drop them again (P-45).
"""
import argparse, json, math, os, struct, sys, tempfile
from pathlib import Path

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_WANT_HELP = any(a in ("-h", "--help") for a in sys.argv[1:])

# bake_sprites.py lives beside this file and does the Blender-only imports
# itself (guarded by its own --help check). Importing it reuses every helper.
if not _WANT_HELP:
    if _SCRIPT_DIR not in sys.path:
        sys.path.insert(0, _SCRIPT_DIR)
    import bake_sprites as bs
else:
    bs = None

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

# Naval families present in the donor (docs/NAVAL_EVIDENCE.md 2.1). Battleship and
# xebec have NO animated .oss - they need the static .osm path (see
# docs/NAVAL_PORT_PLAN.md); the wrapper skips them with a clear message.
NAVAL = {
    "yacht": "yacht",
    "yachttur": "yachttur",
    "fishboat": "fishboat",
    "frigate": "frigate",
    "galley": "galley",
    "battleship": "battleship",  # no .oss in donor
    "xebec": "xebec",            # no .oss in donor
}


def parse_args():
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="installed donor folder (default: $COSSACKS3_DIR or "
                         "C:\\Games\\Cossacks 3)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--only", default="yacht", help="comma-separated unit keys")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="cycles",
                    choices=["cycles", "eevee", "workbench"])
    ap.add_argument("--action", default="walk",
                    help="action name to bake from <base>.aaf (default: walk)")
    ap.add_argument("--action-frames", type=int, default=12,
                    help="poses sampled across the action range")
    ap.add_argument("--aaf", default="",
                    help="optional override .aaf filename (e.g. yacht_sail.aaf)")
    ap.add_argument("--no-hull", action="store_true",
                    help="skip the static .osm hull sheet")
    ap.add_argument("--hull-only", action="store_true",
                    help="bake only the static .osm hull (for families with no .oss)")
    return ap.parse_args(rest)


def read_osm_hull(path):
    """Read a static ship hull .osm.

    Local equivalent of bake_sprites.read_osm_first (K-01). Both readers take
    the UV/face/vertex offsets from header longs 12/13/14; there is no defect
    in the shared reader. On yacht.osm both return byte-identical arrays
    (9364 verts, 7731 faces, 11490 uvs, 7731 uvf) and bbox
    x -1.75..1.75, y -4.82..3.21, z -0.38..6.80 (DC finding fnd_7).
    """
    with open(path, "rb") as f:
        h = struct.unpack("<17i", f.read(68))
        nv, nu, nt = h[6], h[7], h[8]
        ou, ot, ov = h[12], h[13], h[14]
        f.seek(ou)
        uvs = [struct.unpack("<2f", f.read(8)) for _ in range(nu)]
        f.seek(ot)
        faces, uvf = [], []
        for _ in range(nt):
            i = struct.unpack("<6i", f.read(24))
            faces.append((i[0], i[2], i[1]))
            uvf.append((i[3], i[5], i[4]))
        f.seek(ov)
        f.read(16)
        verts = [struct.unpack("<3fI", f.read(16))[:3] for _ in range(nv)]
    return dict(verts=verts, faces=faces, uvs=uvs, uvf=uvf)


def projected_ortho(frames, skinned, center):
    """Same 8-azimuth fit as bake_sprites (elevation 32 deg, +12% bleed)."""
    el = math.radians(32.0)
    ce, se = math.cos(el), math.sin(el)
    worst = 1e-6
    for d in range(8):
        az = math.radians(d * 45.0)
        ca, sa = math.cos(az), math.sin(az)
        rx, ry, rz = -sa, ca, 0.0
        bx, by, bz = ca * ce, sa * ce, se
        ux, uy, uz = (by * rz - bz * ry, bz * rx - bx * rz, bx * ry - by * rx)
        x0 = y0 = 1e9
        x1 = y1 = -1e9
        for fr in frames:
            for x, y, z in skinned[fr]:
                dx, dy, dz = x - center[0], y - center[1], z - center[2]
                px = dx * rx + dy * ry + dz * rz
                py = dx * ux + dy * uy + dz * uz
                x0, x1 = min(x0, px), max(x1, px)
                y0, y1 = min(y0, py), max(y1, py)
        worst = max(worst, 2.0 * max(abs(x0), abs(x1), abs(y0), abs(y1)))
    return worst * 1.12


def measure_sheet(path, cell):
    """Cell-local alpha>8 union bbox over every cell of an 8-dir sprite sheet.

    Mirrors sheet_metrics.py's measurement but uses a strict alpha>8 cut, so
    single-pixel near-transparent fringe does not inflate the ink box. The
    world anchors (ax/ay) remain authoritative in world.gd; these four fields
    are fallback/audit data required by the shared action schema.
    """
    im = bs.Image.open(path).convert("RGBA")
    cols, rows = im.width // cell, im.height // cell
    x0 = y0 = cell
    x1 = y1 = 0
    for r in range(rows):
        for c in range(cols):
            crop = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
            bb = crop.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
            if bb is None:
                continue
            x0, y0 = min(x0, bb[0]), min(y0, bb[1])
            x1, y1 = max(x1, bb[2]), max(y1, bb[3])
    if x1 <= x0 or y1 <= y0:
        return {}
    return {
        "bbox": [x0, y0, x1, y1],
        "fig_h": round((y1 - y0) / float(cell), 4),
        "foot": round(y1 / float(cell), 4),
        "cx": round((x0 + x1) / 2.0 / float(cell), 4),
    }


def bake_naval_unit(game, out, key, base, size, aaf_override, action,
                    action_frames, tmp):
    oss = os.path.join(game, "data", "actors", "units", base + ".oss")
    if not os.path.exists(oss):
        print("SKIP naval %s: no animated .oss at %s" % (key, oss), flush=True)
        return None
    aaf_name = aaf_override or (base + ".aaf")
    aaf = os.path.join(game, "data", "animations", "aaf", aaf_name)
    m = bs.read_oss(oss)
    acts = bs.read_aaf(aaf)
    print("naval read %s: k=%d fps=%d bones=%d v=%d f=%d; aaf=%s acts=%s" % (
        base, m["k"], m["fps"], len(m["anim"]), len(m["verts"]),
        len(m["faces"]), aaf_name, sorted(acts)), flush=True)
    if action not in acts:
        print("SKIP naval %s: action %r not in %s" % (key, action, aaf_name),
              flush=True)
        return None

    rng = acts[action]
    frs = bs.sample(rng, action_frames)
    duration = (rng[1] - rng[0] + 1) / max(1, m["fps"])

    # Re-base root locomotion to the first sampled frame (bone 0), exactly the
    # trick bake_unit uses for standing clips: a sailing ship that drifts in
    # the donor clip stays centred in its cell instead of dragging the union.
    ref = frs[0]
    rx0, ry0 = m["anim"][0][ref][0], m["anim"][0][ref][1]
    skinned = {}
    for fr in frs:
        rx = m["anim"][0][fr][0] - rx0
        ry = m["anim"][0][fr][1] - ry0
        skinned[fr] = [(x - rx, y - ry, z) for x, y, z in bs.skin(m, fr)]

    allpts = [p for fr in frs for p in skinned[fr]]
    lo = [min(p[i] for p in allpts) for i in range(3)]
    hi = [max(p[i] for p in allpts) for i in range(3)]
    center = bs.Vector((0.0, 0.0, (lo[2] + hi[2]) * 0.5))
    ortho = projected_ortho(frs, skinned, center)
    print("naval plan %s/%s: frames=%d dur=%.3f ortho=%.3f center=%s" % (
        key, action, len(frs), duration, ortho, tuple(center)), flush=True)

    png = bs.dds_to_png(bs.tex_png(game, "unit", base),
                        os.path.join(tmp, base + ".png"), True)
    bs.setup_scene()
    mat = bs.make_mat(png)
    ob = bs.build_mesh(m, mat)
    me = ob.data

    # Ground anchor from the stand camera, for schema parity with anim/index.
    cam = bs.camera(center, 0.0, ortho)
    ax, ay = bs.ground_anchor_ay(cam, size)
    bs.bpy.data.objects.remove(cam, do_unlink=True)

    sheet = bs.Image.new("RGBA", (size * 8, size * len(frs)), (0, 0, 0, 0))
    for ri, fr in enumerate(frs):
        me.vertices.foreach_set("co", [c for v in skinned[fr] for c in v])
        me.update()
        for d in range(8):
            cam = bs.camera(center, d * 45.0, ortho)
            cell = os.path.join(tmp, "cell.png")
            bs.render_cell(cell, size)
            img = bs.Image.open(cell).convert("RGBA")
            sheet.paste(img, (d * size, ri * size), img)
            bs.bpy.data.objects.remove(cam, do_unlink=True)
    sheet_path = os.path.join(out, "%s_%s.png" % (key, action))
    sheet.save(sheet_path)
    bs.bpy.data.objects.remove(ob, do_unlink=True)
    print("naval sheet %s %dx%d" % (sheet_path, sheet.width, sheet.height),
          flush=True)

    entry = {"cell": size, "actions": {}}
    entry["actions"][action] = {
        "frames": len(frs), "duration": round(duration, 3), "loop": True,
        "ortho": round(ortho, 3),
        "center": [round(center.x, 3), round(center.y, 3), round(center.z, 3)],
        "ax": ax, "ay": ay, "tool": None,
    }
    return entry


def bake_naval_hull(game, out, key, base, size, tmp):
    """Static 8-direction hull sheet from <base>.osm (the ship itself).

    The animated .oss is a ~584-vert crew figure with a pole, NOT the hull;
    without this sheet there is no ship in the naval bake at all.
    """
    osm = os.path.join(game, "data", "actors", "units", base + ".osm")
    if not os.path.exists(osm):
        print("SKIP hull %s: no .osm at %s" % (key, osm), flush=True)
        return None
    m = read_osm_hull(osm)
    xs = [v[0] for v in m["verts"]]
    ys = [v[1] for v in m["verts"]]
    zs = [v[2] for v in m["verts"]]
    center = bs.Vector(((min(xs) + max(xs)) * 0.5,
                        (min(ys) + max(ys)) * 0.5,
                        (min(zs) + max(zs)) * 0.5))
    ortho = projected_ortho([0], {0: m["verts"]}, center)
    print("naval hull %s: v=%d f=%d ortho=%.3f center=%s" % (
        base, len(m["verts"]), len(m["faces"]), ortho, tuple(center)),
        flush=True)

    png = bs.dds_to_png(bs.tex_png(game, "unit", base),
                        os.path.join(tmp, base + "_hull.png"), True)
    bs.setup_scene()
    mat = bs.make_mat(png)
    ob = bs.build_mesh(m, mat)
    cam = bs.camera(center, 0.0, ortho)
    ax, ay = bs.ground_anchor_ay(cam, size)
    bs.bpy.data.objects.remove(cam, do_unlink=True)

    sheet = bs.Image.new("RGBA", (size * 8, size), (0, 0, 0, 0))
    for d in range(8):
        cam = bs.camera(center, d * 45.0, ortho)
        cell = os.path.join(tmp, "hull_cell.png")
        bs.render_cell(cell, size)
        img = bs.Image.open(cell).convert("RGBA")
        sheet.paste(img, (d * size, 0), img)
        bs.bpy.data.objects.remove(cam, do_unlink=True)
    sheet_path = os.path.join(out, "%s_hull.png" % key)
    sheet.save(sheet_path)
    bs.bpy.data.objects.remove(ob, do_unlink=True)
    print("naval sheet %s %dx%d" % (sheet_path, sheet.width, sheet.height),
          flush=True)
    return {"cell": size, "actions": {"hull": {
        # Static 8-view portrait: one frame, but a finite duration so generic
        # action-player code never divides by / advances on a zero duration.
        "frames": 1, "duration": 1.0, "loop": False,
        "ortho": round(ortho, 3),
        "center": [round(center.x, 3), round(center.y, 3), round(center.z, 3)],
        "ax": ax, "ay": ay, "tool": None}}}


def main():
    global bs
    a = parse_args()
    if _WANT_HELP:
        return 0
    a.game = str(Path(a.game).expanduser().resolve())
    a.out = str(Path(a.out).expanduser().resolve())
    if bs is None:
        raise RuntimeError("bake_sprites.py could not be imported")
    bs._ENGINE = a.engine
    bs._SAMPLES = a.samples
    os.makedirs(a.out, exist_ok=True)

    # Fresh scratch dir per run, strictly outside res://.
    tmp = tempfile.mkdtemp(prefix="cossacks_naval_")
    print("naval scratch: %s" % tmp, flush=True)

    idx_path = os.path.join(a.out, "index.json")
    idx = json.load(open(idx_path, encoding="utf-8")) if os.path.exists(idx_path) else {}
    only = set(x for x in a.only.split(",") if x)
    for key, base in NAVAL.items():
        if only and key not in only:
            continue
        try:
            entry = None if a.hull_only else bake_naval_unit(
                a.game, a.out, key, base, a.size,
                a.aaf, a.action, a.action_frames, tmp)
            if (entry or a.hull_only) and not a.no_hull:
                hull = bake_naval_hull(a.game, a.out, key, base, a.size, tmp)
                if hull:
                    if entry:
                        entry["actions"].update(hull["actions"])
                    else:
                        entry = hull
            if entry:
                for act, ad in entry["actions"].items():
                    sheet = os.path.join(a.out, "%s_%s.png" % (key, act))
                    if os.path.exists(sheet):
                        ad.update(measure_sheet(sheet, a.size))
                idx[key] = entry
                json.dump(idx, open(idx_path, "w", encoding="utf-8"), indent=1)
                print("naval OK %s" % key, flush=True)
        except Exception as ex:
            print("FAIL naval %s: %s" % (key, ex), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
