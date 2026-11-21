#!/usr/bin/env python3
"""Bake the windmill's rotating sails as a SEPARATE animated sprite, like the
peasant attach tools.  The donor ships the sails apart from the tower:

  data/actors/buildings/commoneur/eurmil.osm        tower + cap (baked into
                                                    <nat>_mil.png today)
  data/actors/buildings/commoneur/attach/eurmila.osm      static sails
  data/actors/buildings/commoneur/attach/eurmilanim.oss   skinned sail mesh
  data/animations/aaf/eurmilanim.aaf                 "idle",1,249,morph

We render the skinned sail mesh through the EXACT same camera the tower was
baked with (bake_sprites.bake_building: centre of eurmil.osm bounds, ortho =
maxrange*1.12, elevation 32 deg, azimuth 0), so the two layers register pixel
for pixel.  Output: mill_sails_00.png .. mill_sails_NN.png (transparent), plus
an entry in mill_sails.json with the hub position in cell fractions.

Run:
  blender.exe --background --factory-startup --python tools/bake_mill_sails.py -- \
      --game "C:\\Games\\Cossacks 3" --out assets/models/anim [--frames 16] [--size 320]
"""
import argparse, json, math, os, struct, sys
_BLENDER_PY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blender_py")
if os.path.isdir(_BLENDER_PY) and _BLENDER_PY not in sys.path:
    sys.path.insert(0, _BLENDER_PY)
import bpy
from mathutils import Vector
from PIL import Image

# Reuse the proven readers / renderer from bake_sprites.py.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bake_sprites as bs


def osm_bounds(path):
    with open(path, "rb") as f:
        h = dict(zip(["magic","version","sw","sh","fs","ns","nv","nu","nt","ng",
                      "nf","os","ou","ot","of","og","oe"], struct.unpack("<17i", f.read(68))))
        f.seek(h["of"]); f.read(16)
        verts = [struct.unpack("<3fI", f.read(16))[:3] for _ in range(h["nv"])]
    xs = [v[0] for v in verts]; ys = [v[1] for v in verts]; zs = [v[2] for v in verts]
    return ((min(xs)+max(xs))*0.5, (min(ys)+max(ys))*0.5, (min(zs)+max(zs))*0.5,
            max(max(xs)-min(xs), max(ys)-min(ys), max(zs)-min(zs)) * 1.12)


def frames_for_action(aaf_path, key="idle", n=16):
    acts = bs.read_aaf(aaf_path)
    if key not in acts:
        return list(range(n))
    a, b = acts[key]
    if b <= a:
        return [a] * n
    return [a + round((b-a)*i/(n-1)) for i in range(n)] if n > 1 else [a]


def main():
    rest = sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--frames", type=int, default=16)
    ap.add_argument("--size", type=int, default=320)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="cycles", choices=["cycles","eevee","workbench"])
    a = ap.parse_args(rest)

    bs._ENGINE = a.engine; bs._SAMPLES = a.samples
    game = os.path.abspath(a.game); out = os.path.abspath(a.out)
    os.makedirs(out, exist_ok=True)
    tmp = os.path.join(out, "_mill_tmp"); os.makedirs(tmp, exist_ok=True)

    tower = os.path.join(game, "data", "actors", "buildings", "commoneur", "eurmil.osm")
    sail_oss = os.path.join(game, "data", "actors", "buildings", "commoneur", "attach", "eurmilanim.oss")
    sail_aaf = os.path.join(game, "data", "animations", "aaf", "eurmilanim.aaf")
    for p in (tower, sail_oss):
        if not os.path.exists(p):
            print("MISSING", p); return 1

    cx, cy, cz, ortho = osm_bounds(tower)
    center = Vector((cx, cy, cz))
    m = bs.read_oss(sail_oss)
    tex = os.path.join(game, "data", "materials", "buildings", "commoneur", "eurmil.dds")
    png = bs.dds_to_png(tex, os.path.join(tmp, "eurmil.png"), True)

    fr = frames_for_action(sail_aaf, "idle", a.frames)
    hub = None
    entry = {"frames": a.frames, "fps": m["fps"], "aaf": fr}

    bs.setup_scene()
    mat = bs.make_mat(png)
    cam = bs.camera(center, 0.0, ortho)
    # project the cap centre (world z ~ 3.9 m, near the top of the tower) so
    # Godot can spin the sheet around the real hub instead of the cell centre.
    from bpy_extras.object_utils import world_to_camera_view
    bpy.context.view_layer.update()
    hub_world = Vector((cx, cy, cz + 1.78))
    ndc = world_to_camera_view(bpy.context.scene, cam, hub_world)
    hub = [round(float(ndc.x), 4), round(1.0 - float(ndc.y), 4)]

    for i, f in enumerate(fr):
        vs = bs.skin(m, min(f, m["k"]-1))
        mm = dict(m); mm["verts"] = vs
        # single material, no second mesh
        ob = bs.build_mesh(mm, mat)
        bs.render_cell(os.path.join(out, "mill_sails_%02d.png" % i), a.size)
        bpy.data.objects.remove(ob, do_unlink=True)

    entry["hub"] = hub
    entry["cell"] = a.size
    json.dump(entry, open(os.path.join(out, "mill_sails.json"), "w"), indent=1)
    print("mill sails: %d frames, hub=%s, ortho=%.3f" % (a.frames, hub, ortho), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
