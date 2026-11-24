#!/usr/bin/env python3
"""Convert the original Cossacks 3 models into the Godot project.

The original game keeps its meshes in two binary formats next to the actors:

  .oss  the newer skinned format (units, cannons, ...)
  .osm  the older MD2-style format (buildings, trees, props, ...)

Both are read here and written as Wavefront .obj with a .mtl that points at
the original texture (converted from .dds to .png with Pillow).  The sprites
the game draws are rendered from those .obj files by render_models.py.

Usage:
    python tools/convert_models.py --game "C:\\Games\\Cossacks 3" --out assets/models
    # or set COSSACKS3_DIR and omit --game:
    COSSACKS3_DIR=/path/to/game python tools/convert_models.py --out assets/models

Everything is read from the installed game; nothing is written outside the
project folder. The donor is private use only — never redistribute it.

V7-63: outputs are STATIC BIND POSES only. The reader discards .oss weights,
bones and animation frames (read_oss), and .osm keeps only its first frame.
Every exported mesh is a PORT APPROXIMATION, not donor animation parity; the
3D entity renderer must keep its "static bind pose" label.
"""
from __future__ import annotations

import argparse
import json
import os
import struct
import sys
from pathlib import Path

# Portable donor-default: COSSACKS3_DIR overrides the historical Windows path.
DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

try:
    from PIL import Image
except Exception:  # pragma: no cover - Pillow is present on the build machine
    Image = None


# --------------------------------------------------------------------------
# readers
# --------------------------------------------------------------------------

def read_oss(path: str) -> dict:
    """Read a .oss mesh (header, vertices, faces, uvs, weights, animation)."""
    with open(path, "rb") as f:
        k_count, fps, b_count, v_count, f_count, t_count = struct.unpack("<6i", f.read(24))
        verts = [struct.unpack("<3f", f.read(12)) for _ in range(v_count)]
        faces = [struct.unpack("<3i", f.read(12)) for _ in range(f_count)]
        uvs = [struct.unpack("<2f", f.read(8)) for _ in range(t_count)]
        uv_faces = [struct.unpack("<3i", f.read(12)) for _ in range(f_count)]
        weights = []
        for _ in range(v_count):
            w_count = struct.unpack("<i", f.read(4))[0]
            weights.append([struct.unpack("<if", f.read(8)) for _ in range(w_count)])
        animation = []
        for _bone in range(b_count):
            frames = []
            for _frame in range(k_count):
                px, py, pz, rx, ry, rz, rw = struct.unpack("<7f", f.read(28))
                frames.append((px, py, pz, rx, ry, rz, rw))
            animation.append(frames)
    return {
        "format": "oss", "fps": fps, "bones": b_count, "frames": k_count,
        "verts": verts, "faces": faces, "uvs": uvs, "uv_faces": uv_faces,
        "weights": weights, "animation": animation,
    }


def read_osm(path: str) -> dict:
    """Read a .osm mesh (IDP2 / MD2-style, first frame only)."""
    with open(path, "rb") as f:
        keys = ["magic", "version", "skin_w", "skin_h", "frame_size", "num_skins",
                "num_verts", "num_uv", "num_tris", "num_glcmds", "num_frames",
                "ofs_skins", "ofs_uv", "ofs_tris", "ofs_frames", "ofs_glcmds", "ofs_end"]
        h = dict(zip(keys, struct.unpack("<17i", f.read(68))))
        f.seek(h["ofs_uv"])
        uvs = [struct.unpack("<2f", f.read(8)) for _ in range(h["num_uv"])]
        f.seek(h["ofs_tris"])
        tris = []
        tris_uv = []
        for _ in range(h["num_tris"]):
            idx = struct.unpack("<6i", f.read(24))
            tris.append((idx[0], idx[2], idx[1]))
            tris_uv.append((idx[3], idx[5], idx[4]))
        f.seek(h["ofs_frames"])
        name = f.read(16).rstrip(b"\x00").decode("ascii", "replace")
        verts = []
        for _ in range(h["num_verts"]):
            vx, vy, vz, _normal = struct.unpack("<3fI", f.read(16))
            verts.append((vx, vy, vz))
    return {
        "format": "osm", "version": h["version"], "verts": verts, "faces": tris,
        "uvs": uvs, "uv_faces": tris_uv, "frame_name": name,
    }


def read_mesh(path: str) -> dict:
    with open(path, "rb") as head:
        magic = head.read(4)
    if magic == b"IDP2":
        return read_osm(path)
    return read_oss(path)


# --------------------------------------------------------------------------
# writers
# --------------------------------------------------------------------------

def write_obj(path: str, mesh: dict, mtl_name: str) -> None:
    verts = mesh["verts"]
    uvs = mesh["uvs"]
    faces = mesh["faces"]
    uv_faces = mesh.get("uv_faces", faces)
    with open(path, "w", encoding="utf-8") as f:
        f.write("# Cossacks 3 original mesh, converted by tools/convert_models.py\n")
        f.write("mtllib %s\n" % mtl_name)
        f.write("o model\n")
        for v in verts:
            f.write("v %.6f %.6f %.6f\n" % v)
        for t in uvs:
            f.write("vt %.6f %.6f\n" % (t[0], t[1]))
        for i, tri in enumerate(faces):
            uv = uv_faces[i]
            f.write("f %d/%d %d/%d %d/%d\n" % (
                tri[0] + 1, uv[0] + 1, tri[1] + 1, uv[1] + 1, tri[2] + 1, uv[2] + 1))


def write_mtl(path: str, texture: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write("newmtl model\n")
        f.write("Kd 1 1 1\n")
        f.write("map_Kd %s\n" % texture)


def convert_texture(src: str, dst: str, force_opaque: bool = False) -> bool:
    if Image is None:
        return False
    if os.path.exists(dst) and os.path.getsize(dst) > 0 and not force_opaque:
        return True
    try:
        img = Image.open(src)
        img.load()
        if force_opaque:
            # unit/building textures carry a garbage alpha channel (the game
            # draws them opaque); dropping it stops holes in the sprites
            img = img.convert("RGB")
        elif img.mode not in ("RGB", "RGBA"):
            img = img.convert("RGBA")
        img.save(dst, "PNG")
        return True
    except Exception as exc:  # a broken texture must not stop the others
        print("  texture failed: %s (%s)" % (src, exc))
        return False


# --------------------------------------------------------------------------
# the models this port uses (Ukrainian roster, the port's nation)
# --------------------------------------------------------------------------

def unit_models(game: str) -> list:
    actors = os.path.join(game, "data", "actors", "units")
    mats = os.path.join(game, "data", "materials", "units")
    # port sid -> (actor base name, texture base name)
    table = {
        "peasant": "peaukr",
        "pikeman": "pikeman",
        "roundshier": "roundshier",
        "serdiuk": "serdiuk",
        "archer": "archer",
        "cossack": "cossacksich",
        "dragoon": "dragoon18",
        "officer": "officer",
        "cannon": "cannon",
    }
    # V7-63 — port sid -> EXACT donor .oss base (same-named DDS albedo).
    # Source of every mapping: the port's own donor-derived bake table
    # `app/tools/bake_sprites.py:664-674`, except `sco_highlandersword`, whose
    # donor base is fixed by `app/tools/bake_scottish.py:52-53`. Where a port
    # sid differs from the donor actor name the donor name is kept verbatim:
    # musk18->musketeer18, dragoon17->dragoon, sco_highlandersword->
    # swordsmansco. No shape is invented: each entry is read by read_oss().
    table.update({
        "officer18": "officer18",
        "drummer": "drummer",
        "priest": "priest",
        "grenadier": "grenadier",
        "musk18": "musketeer18",
        "howitzer": "howitzer",
        "mortar": "mortar",
        "musketeer": "musketeer",
        "strelet": "strelet",
        "pikeman18": "pikeman18",
        "dragoon17": "dragoon",
        "hussar": "hussar",
        "wingedhussar": "wingedhussar",
        "cuirassier": "cuirassier",
        "reiter": "reiter",
        "lightcavalry": "lightcavalry",
        "lightinfantry": "lightinfantry",
        "tatar": "tatar",
        "sipahi": "sipahi",
        "jannisary": "jannisary",
        "spakh": "spakh",
        "mameluke": "mameluke",
        "vityaz": "vityaz",
        "hetman": "hetman",
        "croat": "croat",
        "pandur": "pandur",
        "chasseur": "chasseur",
        "highlander": "highlander",
        "pope": "pope",
        "padre": "padre",
        "mullah": "mullah",
        "drummer18": "drummer18",
        "multicannon": "multicannon",
        "cossackdon": "cossackdon",
        "hackapell": "hackapell",
        "cossackregister": "cossackregister",
        "bagpiper": "bagpiper",
        "sco_highlandersword": "swordsmansco",
        "pikemansco": "pikemansco",
        "swordsmansco": "swordsmansco",
        "musketeersco": "musketeersco",
        "archersco": "archersco",
        "officersco": "officersco",
        "lancersco": "lancersco",
        "raidersco": "raidersco",
        "framegun": "framegun",
    })
    out = []
    for sid, base in table.items():
        out.append({
            "sid": sid, "kind": "unit",
            "mesh": os.path.join(actors, base + ".oss"),
            "texture": os.path.join(mats, base + ".dds"),
            "directions": 8,
        })
    return out


def building_models(game: str) -> list:
    actors = os.path.join(game, "data", "actors", "buildings")
    mats = os.path.join(game, "data", "materials", "buildings")
    env_actors = os.path.join(game, "data", "actors", "env")
    env_mats = os.path.join(game, "data", "materials", "env")
    # port sid -> (actor folder, actor base, texture folder, texture base)
    table = {
        "cen": ("ukr", "ukrcen", "ukr", "ukrcen"),
        "hou": ("ukr", "ukrhou", "ukr", "ukrhou"),
        "bar": ("ukr", "ukrbar", "ukr", "ukrbar"),
        "sta": ("ukr", "ukrsta", "ukr", "ukrsta"),
        "bla": ("ukr", "ukrbla", "ukr", "ukrbla"),
        "aca": ("ukr", "ukraca", "ukr", "ukraca"),
        "art": ("ukr", "ukrart", "ukr", "ukrart"),
        "sto": ("commoneur", "eursto", "commoneur", "eursto"),
        "mil": ("commoneur", "eurmil", "commoneur", "eurmil"),
        "mar": ("commoneur", "eurmar", "commoneur", "eurmar"),
        "tow": ("commoneur", "eurtow", "commoneur", "eurtow"),
    }
    # V7-63 — three more port sids with exact donor actors. `dip` is the
    # Ukrainian actor named in `app/tools/bake_sprites.py:657` ("dip") and in
    # the donor `data/actors/actors.lib:475` (ukrdip). `wal`/`gat` are the
    # stone wall and gate actors listed under `// walls` in that same donor
    # library (`actors.lib:543,657`, base eurswa / eurswa_gate); their albedo
    # is the shared `commonrus/eurswa.dds` used by those actors.
    table.update({
        "dip": ("ukr", "ukrdip", "ukr", "ukrdip"),
        "wal": ("commoneur", "eurswa", "commonrus", "eurswa"),
        "gat": ("commonrus", "eurswa_gate", "commonrus", "eurswa"),
    })
    # NOT mapped (no donor actor exists — do not guess):
    #   bar18: bake_sprites.py:657 candidates ukrba2 / eurba2 / turba2 are all
    #          absent on disk (17 other nations have <nat>ba2, not Ukraine).
    #   dock:  no shipyard/dock .osm anywhere under data/actors; "Shipyard" at
    #          data/locale/en/units.txt:975 is a name only, not an actor.
    out = []
    for sid, (af, ab, tf, tb) in table.items():
        out.append({
            "sid": sid, "kind": "building",
            "mesh": os.path.join(actors, af, ab + ".osm"),
            "texture": os.path.join(mats, tf, tb + ".dds"),
            "directions": 1,
        })
    # the mines are ordinary environment props in the original
    for sid, base in (("mine_gold", "minegold"), ("mine_iron", "mineiron"), ("mine_coal", "minecoal")):
        out.append({
            "sid": sid, "kind": "building",
            "mesh": os.path.join(env_actors, base + ".osm"),
            "texture": os.path.join(env_mats, base + ".dds"),
            "directions": 1,
        })
    return out


def ship_models(game: str) -> list:
    """V7-63 — naval hulls live as IDP2 .osm under data/actors/units.

    The seven donor bases are the port's own naval table
    (`app/tools/bake_naval.py:46-54`). For battleship/xebec there is no
    animated .oss at all; for the others the .oss is the crew figure, not the
    hull, so the .osm is the correct static geometry in every case. All seven
    have a same-named `data/materials/units/<base>.dds`.
    """
    actors = os.path.join(game, "data", "actors", "units")
    mats = os.path.join(game, "data", "materials", "units")
    table = {
        "yacht": "yacht",
        "yachttur": "yachttur",
        "fishboat": "fishboat",
        "frigate": "frigate",
        "galley": "galley",
        "battleship": "battleship",
        "xebec": "xebec",
    }
    return [{
        "sid": sid, "kind": "unit",
        "mesh": os.path.join(actors, base + ".osm"),
        "texture": os.path.join(mats, base + ".dds"),
        "directions": 8,
    } for sid, base in table.items()]


def env_models(game: str) -> list:
    actors = os.path.join(game, "data", "actors", "env")
    mats = os.path.join(game, "data", "materials", "env")
    # port sid -> (actor base name, texture base name)
    # The texture base is taken from each mesh's `data/objects/env/<base>.prop`
    # `DefaultMaterialName` (many meshes share one atlas, e.g. stones -> stones,
    # flowers -> plantsatlas, reed -> plantswateratlas). Only meshes that both
    # parse as IDP2 .osm and have a matching .dds are listed; `main()` skips any
    # leftover missing file, so a partial donor install cannot break the run.
    # Keep the original six sids first (world.gd already loads those by name).
    table = {
        "tree_fir": ("fir1", "fir1"),
        "tree_oak": ("oak1", "oak1"),
        "tree_pine": ("pine1", "pine1"),
        "rock": ("rocks1", "rocks"),
        "stone": ("stones1", "stones"),
        "field": ("field1", "field1"),
    }
    # (a) conifer / forest variety ------------------------------------------
    table.update({
        "tree_spruce1": ("spruce1", "spruce1"),
        "tree_spruce2": ("spruce2", "spruce2"),
        "tree_spruce3": ("spruce3", "spruce3"),
        "tree_spruce4": ("spruce4", "spruce1"),
        "tree_pinedry1": ("pinedry1", "pinedry1"),
        "tree_pinedry2": ("pinedry2", "pinedry1"),
        "tree_pinedry3": ("pinedry3", "pinedry1"),
        "tree_pinedry4": ("pinedry4", "pinedry1"),
        "tree_pinesmall1": ("pinesmall1", "pinesmall1"),
        "tree_pinesmall2": ("pinesmall2", "pinesmall2"),
        "tree_pinesmall3": ("pinesmall3", "pinesmall3"),
        "tree_pinesmall4": ("pinesmall4", "pinesmall1"),
        "tree_firsmall1": ("firsmall1", "firsmall1"),
        "tree_firsmall2": ("firsmall2", "firsmall2"),
        "tree_firsmall3": ("firsmall3", "firsmall3"),
        "tree_firsmall4": ("firsmall4", "firsmall1"),
        "tree_stump1": ("pinestump1", "pinestump"),
        "tree_stump2": ("pinestump2", "pinestump"),
        "tree_stump3": ("pinestump3", "pinestump"),
        "tree_stump4": ("pinestump4", "pinestump"),
    })
    # (b) rock / stone variety ---------------------------------------------
    for i in range(1, 11):
        table["rock_stones%d" % i] = ("stones%d" % i, "stones")
    for i in range(1, 7):
        table["rock_smallstones%d" % i] = ("smallstones%d" % i, "smallstones")
    for i in range(1, 5):
        table["rock_landstone%d" % i] = ("landstone%d" % i, "landstone")
    table.update({
        "rock_sea1": ("rocksea1", "rocksea1"),
        "rock_sea2": ("rocksea2", "rocksea2"),
        "rock_sea3": ("rocksea3", "rocksea3"),
        "rock_sea4": ("rocksea4", "rocksea1"),
        "rock_sea5": ("rocksea5", "rocksea1"),
        "rock_sea6": ("rocksea6", "rocksea1"),
    })
    for i in range(1, 7):
        table["rock_smallstonesea%d" % i] = ("smallstonessea%d" % i, "smallstonessea")
    for i in range(1, 11):
        table["rock_stonessea%d" % i] = ("stonessea%d" % i, "stonessea")
    # (c) ground decor ------------------------------------------------------
    for i in range(1, 5):
        table["bush%d" % i] = ("bushes%d" % i, "bushes")
    for i in range(1, 4):
        table["flower%d" % i] = ("flowers%d" % i, "plantsatlas")
        table["plantain%d" % i] = ("plantain%d" % i, "plantsatlas")
        table["reed%d" % i] = ("reed%d" % i, "plantswateratlas")
    for i in range(1, 5):
        table["fern%d" % i] = ("fern%d" % i, "fern")
    # (d) festive -----------------------------------------------------------
    table.update({
        "christmastree": ("christmastree", "christmastree"),
        "christmastreea": ("christmastreea", "christmastreea"),
    })
    for i in range(1, 7):
        table["gift%d" % i] = ("gift%d" % i, "gift")
    out = []
    for sid, (ab, tb) in table.items():
        out.append({
            "sid": sid, "kind": "env",
            "mesh": os.path.join(actors, ab + ".osm"),
            "texture": os.path.join(mats, tb + ".dds"),
            "directions": 1,
        })
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="the installed game folder (default: $COSSACKS3_DIR "
                         "or C:\\Games\\Cossacks 3)")
    ap.add_argument("--out", required=True, help="the folder inside the project")
    args = ap.parse_args()

    # expanduser makes ~/: Linux/macOS paths work; Path.resolve is cross-platform.
    game = str(Path(args.game).expanduser().resolve())
    out = str(Path(args.out).expanduser().resolve())
    obj_dir = os.path.join(out, "obj")
    tex_dir = os.path.join(out, "tex")
    os.makedirs(obj_dir, exist_ok=True)
    os.makedirs(tex_dir, exist_ok=True)

    models = (unit_models(game) + building_models(game) + ship_models(game)
              + env_models(game))
    manifest = {"game": game, "models": []}
    ok = 0
    for m in models:
        sid = m["sid"]
        if not os.path.exists(m["mesh"]):
            print("MISSING mesh %s" % m["mesh"])
            continue
        if not os.path.exists(m["texture"]):
            print("MISSING texture %s" % m["texture"])
            continue
        mesh = read_mesh(m["mesh"])
        obj_name = sid + ".obj"
        mtl_name = sid + ".mtl"
        tex_name = sid + ".png"
        write_obj(os.path.join(obj_dir, obj_name), mesh, mtl_name)
        write_mtl(os.path.join(obj_dir, mtl_name), os.path.join("..", "tex", tex_name))
        convert_texture(m["texture"], os.path.join(tex_dir, tex_name),
                        force_opaque=(m["kind"] in ("unit", "building")))
        verts = mesh["verts"]
        xs = [v[0] for v in verts]
        ys = [v[1] for v in verts]
        zs = [v[2] for v in verts]
        entry = dict(m)
        entry["obj"] = os.path.join(obj_dir, obj_name)
        entry["texture_png"] = os.path.join(tex_dir, tex_name)
        entry["bbox"] = [min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)]
        entry["verts"] = len(verts)
        entry["faces"] = len(mesh["faces"])
        manifest["models"].append(entry)
        ok += 1
        print("OK %-12s %-8s verts=%-5d faces=%-5d bbox z %.2f..%.2f" % (
            sid, mesh["format"], len(verts), len(mesh["faces"]), min(zs), max(zs)))

    with open(os.path.join(out, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
    print("done: %d models, manifest at %s" % (ok, os.path.join(out, "manifest.json")))
    return 0 if ok == len(models) else 1


if __name__ == "__main__":
    sys.exit(main())
