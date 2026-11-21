#!/usr/bin/env python3
"""Render the converted Cossacks 3 models to sprites with Blender.

Run headless from the project folder:

    blender --background --factory-startup --python tools/render_models.py -- \
        --manifest assets/models/manifest.json --out assets/models/sprites

For every model in the manifest one PNG per viewing direction is written
(sid.png for a single direction, sid_000.png ... for several).  The camera is
orthographic, at the original game's low three-quarter view, with a
transparent background, so the sprites drop straight into the 2-D game.

Portability: run with `blender` (or `blender.exe` on Windows). This file is a
Blender host script (imports bpy), not a launcher, so it needs no shutil.which.
All paths are supplied on the command line; none are hardcoded here.
"""
from __future__ import annotations

import argparse
import json
import math
import os
import sys

import bpy
from mathutils import Vector


def parse_args() -> argparse.Namespace:
    argv = sys.argv
    rest = argv[argv.index("--") + 1:] if "--" in argv else []
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--manifest", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--only", default="", help="render only these sids (comma separated)")
    ap.add_argument("--size", type=int, default=256, help="longest sprite side in pixels")
    ap.add_argument("--engine", default="cycles", choices=["cycles", "eevee"],
                    help="render engine (eevee is much faster, fine for sprites)")
    ap.add_argument("--elevation", type=float, default=32.0, help="camera elevation in degrees")
    ap.add_argument("--start-angle", type=float, default=0.0)
    ap.add_argument("--samples", type=int, default=24)
    args = ap.parse_args(rest)
    return args


def clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_obj(path: str):
    # Blender 4.x/5.x importer. The converted files are Z-up (game coords),
    # so import them that way instead of lying them down.
    try:
        bpy.ops.wm.obj_import(filepath=path, up_axis="Z", forward_axis="Y")
    except Exception:
        try:
            bpy.ops.wm.obj_import(filepath=path)
        except Exception:
            bpy.ops.import_scene.obj(filepath=path)
    objs = [o for o in bpy.context.selected_objects if o.type == "MESH"]
    return objs


def make_material(image_path: str):
    mat = bpy.data.materials.new("c3model")
    mat.use_nodes = True
    nt = mat.node_tree
    # Shadeless: the original textures are painted with their own shading,
    # like the game's own sprites, so emit the texel colors directly.
    out = nt.nodes.get("Material Output")
    emit = nt.nodes.new("ShaderNodeEmission")
    tex = nt.nodes.new("ShaderNodeTexImage")
    img = bpy.data.images.load(image_path, check_existing=True)
    img.colorspace_settings.name = "sRGB"
    tex.image = img
    nt.links.new(tex.outputs["Color"], emit.inputs["Color"])
    emit.inputs["Strength"].default_value = 1.0
    nt.links.new(emit.outputs["Emission"], out.inputs["Surface"])
    for n in list(nt.nodes):
        if n.type == "BSDF_PRINCIPLED":
            nt.nodes.remove(n)
    return mat


def assign_material(objs, mat, sid: str) -> None:
    for o in objs:
        try:
            slots_before = len(o.data.materials)
            o.data.materials.clear()
            o.data.materials.append(mat)
            print("  %s: %d polys, slots %d -> %d" % (
                sid, len(o.data.polygons), slots_before, len(o.data.materials)), flush=True)
        except Exception as exc:
            print("  material assign failed on %s: %s" % (sid, exc), flush=True)


def mesh_bounds(objs):
    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    for o in objs:
        for corner in o.bound_box:
            w = o.matrix_world @ Vector(corner)
            lo = Vector((min(lo.x, w.x), min(lo.y, w.y), min(lo.z, w.z)))
            hi = Vector((max(hi.x, w.x), max(hi.y, w.y), max(hi.z, w.z)))
    return lo, hi


def setup_world() -> None:
    world = bpy.data.worlds.new("w")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs[0].default_value = (0.6, 0.7, 0.9, 1.0)
        bg.inputs[1].default_value = 0.6


def setup_light() -> None:
    sun_data = bpy.data.lights.new("sun", type="SUN")
    sun_data.energy = 6.0
    sun_data.angle = math.radians(20.0)
    sun = bpy.data.objects.new("sun", sun_data)
    bpy.context.collection.objects.link(sun)
    sun.rotation_euler = (math.radians(50.0), 0.0, math.radians(35.0))
    # soft fill from the other side so walls/roofs never go black
    fill_data = bpy.data.lights.new("fill", type="SUN")
    fill_data.energy = 2.0
    fill_data.angle = math.radians(40.0)
    fill = bpy.data.objects.new("fill", fill_data)
    bpy.context.collection.objects.link(fill)
    fill.rotation_euler = (math.radians(30.0), 0.0, math.radians(215.0))


def setup_camera(lo: Vector, hi: Vector, azimuth_deg: float, elevation_deg: float, ortho_scale: float):
    center = (lo + hi) * 0.5
    cam_data = bpy.data.cameras.new("cam")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = ortho_scale
    cam = bpy.data.objects.new("cam", cam_data)
    bpy.context.collection.objects.link(cam)
    bpy.context.scene.camera = cam
    az = math.radians(azimuth_deg)
    el = math.radians(elevation_deg)
    dist = 50.0
    pos = center + Vector((math.cos(az) * math.cos(el),
                           math.sin(az) * math.cos(el),
                           math.sin(el))) * dist
    cam.location = pos
    direction = (center - pos).normalized()
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    return cam, center


def render_to(path: str, samples: int, size: int, engine: str) -> bool:
    scene = bpy.context.scene
    if engine == "eevee":
        try:
            scene.render.engine = "BLENDER_EEVEE_NEXT"
        except Exception:
            scene.render.engine = "BLENDER_EEVEE"
        try:
            scene.eevee.taa_render_samples = max(1, samples)
        except Exception:
            pass
    else:
        scene.render.engine = "CYCLES"
        scene.cycles.samples = samples
        scene.cycles.use_denoising = True
        try:
            scene.cycles.device = "CPU"
        except Exception:
            pass
    scene.render.resolution_x = size
    scene.render.resolution_y = size
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.filepath = path
    try:
        bpy.ops.render.render(write_still=True)
        return True
    except Exception as exc:
        print("  render failed: %s" % exc)
        return False


def main() -> int:
    args = parse_args()
    with open(args.manifest, "r", encoding="utf-8") as f:
        manifest = json.load(f)
    os.makedirs(args.out, exist_ok=True)
    only = set(x for x in args.only.split(",") if x)

    clear_scene()
    setup_world()
    setup_light()

    done = 0
    for m in manifest["models"]:
        sid = m["sid"]
        if only and sid not in only:
            continue
        if not os.path.exists(m["obj"]) or not os.path.exists(m["texture_png"]):
            print("SKIP %s (missing obj or texture)" % sid)
            continue
        objs = import_obj(m["obj"])
        if not objs:
            print("SKIP %s (no mesh imported)" % sid)
            continue
        mat = make_material(m["texture_png"])
        assign_material(objs, mat, sid)
        lo, hi = mesh_bounds(objs)
        size = max(hi.x - lo.x, hi.y - lo.y, hi.z - lo.z)
        print("  bounds lo=%s hi=%s size=%.3f" % (lo, hi, size), flush=True)
        # a little margin so the sprite is not clipped
        ortho = size * 1.15 if size > 0 else 4.0
        directions = int(m.get("directions", 1))
        for d in range(directions):
            az = args.start_angle + (360.0 / directions) * d
            setup_camera(lo, hi, az, args.elevation, ortho)
            if directions == 1:
                name = "%s.png" % sid
            else:
                name = "%s_%03d.png" % (sid, int(round(az)) % 360)
            path = os.path.join(args.out, name)
            if render_to(path, args.samples, args.size, args.engine):
                done += 1
                print("rendered %s" % name, flush=True)
        # remove the imported objects before the next model
        for o in objs:
            bpy.data.objects.remove(o, do_unlink=True)
        bpy.data.materials.remove(mat)

    print("done: %d sprites in %s" % (done, args.out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
