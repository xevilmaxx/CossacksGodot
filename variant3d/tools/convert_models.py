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


def write_obj_exact(path: str, mesh: dict, mtl_name: str, source: str = "") -> None:
    """A3 — exact-float OBJ writer (additive; legacy write_obj() is untouched).

    The legacy writer rounds to 6 decimals, which is a PORT APPROXIMATION.
    This writer emits each float32 value with Python's shortest round-trip
    repr, so a parse-back is bit-identical to read_osm()'s vertices and UVs.
    Winding and UV-face order are copied verbatim from the reader; no shape,
    UV or topology is invented.
    """
    verts = mesh["verts"]
    uvs = mesh["uvs"]
    faces = mesh["faces"]
    uv_faces = mesh.get("uv_faces", faces)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("# Cossacks 3 original mesh, converted by tools/convert_models.py\n")
        if source:
            f.write("# Source: %s (IDP2 v%s, first frame only: %s)\n" % (
                source, mesh.get("version", "?"), mesh.get("frame_name", "")))
        f.write("mtllib %s\n" % mtl_name)
        f.write("o model\n")
        f.write("usemtl model\n")
        for v in verts:
            f.write("v %s %s %s\n" % (repr(float(v[0])), repr(float(v[1])), repr(float(v[2]))))
        for t in uvs:
            f.write("vt %s %s\n" % (repr(float(t[0])), repr(float(t[1]))))
        for tri, uv in zip(faces, uv_faces):
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


def stage_models(game: str) -> list:
    """BUILD-ART-CONV-01 — additive donor construction-stage / scaffold table.

    108 entries for the 12 non-wall building sids: 48 parent stages, 48
    attach stages and 12 base scaffolds. No new format work: read_osm(),
    write_obj() and convert_texture() already handle these IDP2 files.

    Donor sources (read-only, relative to ``C:\\Games\\Cossacks 3\\data\\``):
      * Stage mesh slots ``<base>1.mesh`` .. ``<base>4.mesh`` ->
        ``<base>1.osm`` .. ``<base>4.osm``: ``actors/buildings/ukr/ukrcen.actor:5-18``
        (lines 6/10/14/18 are the four LoadFromFile paths); all 12 families
        repeat this pattern at the same lines.
      * Parent stages reuse the base building material (no scaffold PNG):
        ``objects/buildings/ukrcen.prop:13-43`` (DefaultMaterialName = ukrcen
        at :14, :20, :24, :28, :32, :36, :40); same single material in all
        12 mapped props.
      * Scaffold auto-child with slots ``<base>a``, ``<base>1a`` ..
        ``<base>4a`` and ``DefaultMaterialName = scaffold``:
        ``objects/buildings/engcen.prop:72-112`` (:86-97); the other 11 props
        carry the same child (e.g. ``ukrcen.prop:88-97``).
      * Visual stage 0..3 -> suffix 1..4, wall fold ``1+stage div 3`` and
        child ``<actor><stage>a.mesh``: ``scripts/units/building.inc/ontagstates.inc:240-259``.
      * Completion switches the child to ``<base>a.mesh``: same file ``:112-127``.
      * ``scaffold`` material texture: ``materials/buildings/buildings.mat:528-529``
        -> ``materials/buildings/constructor/scaffold.dds`` (winter
        ``scaffoldw`` at :1546-1547 is not used).

    ``wal``/``gat`` and the ``_death1``/``_death2`` stages are deliberately
    excluded (BUILD_ART_01.md sections 3.2/3.3; donor mapping is UNVERIFIED).
    """
    actors = os.path.join(game, "data", "actors", "buildings")
    mats = os.path.join(game, "data", "materials", "buildings")
    scaffold_dds = os.path.join(mats, "constructor", "scaffold.dds")
    # port sid -> (actor folder, actor base, texture folder, texture base).
    # These are exactly the 12 non-wall rows of building_models()'s table;
    # the mapped building PNG is reused for parent stages via tex_name.
    table = {
        "cen": ("ukr", "ukrcen", "ukr", "ukrcen"),
        "hou": ("ukr", "ukrhou", "ukr", "ukrhou"),
        "bar": ("ukr", "ukrbar", "ukr", "ukrbar"),
        "sta": ("ukr", "ukrsta", "ukr", "ukrsta"),
        "bla": ("ukr", "ukrbla", "ukr", "ukrbla"),
        "aca": ("ukr", "ukraca", "ukr", "ukraca"),
        "art": ("ukr", "ukrart", "ukr", "ukrart"),
        "dip": ("ukr", "ukrdip", "ukr", "ukrdip"),
        "sto": ("commoneur", "eursto", "commoneur", "eursto"),
        "mil": ("commoneur", "eurmil", "commoneur", "eurmil"),
        "mar": ("commoneur", "eurmar", "commoneur", "eurmar"),
        "tow": ("commoneur", "eurtow", "commoneur", "eurtow"),
    }
    out = []
    for sid, (af, ab, tf, tb) in table.items():
        # 48 parent stages: 12 sids x 4, same albedo as the base building.
        for i in range(1, 5):
            stage_sid = "%s%d" % (sid, i)
            out.append({
                "sid": stage_sid, "kind": "building",
                "obj_name": stage_sid, "tex_name": sid,
                "mesh": os.path.join(actors, af, "%s%d.osm" % (ab, i)),
                "texture": os.path.join(mats, tf, tb + ".dds"),
                "directions": 1,
            })
        # 48 attach stages: 12 sids x 4, all share one scaffold PNG.
        for i in range(1, 5):
            stage_sid = "%s%da" % (sid, i)
            out.append({
                "sid": stage_sid, "kind": "building",
                "obj_name": stage_sid, "tex_name": "scaffold",
                "mesh": os.path.join(actors, af, "attach", "%s%da.osm" % (ab, i)),
                "texture": scaffold_dds,
                "directions": 1,
            })
        # 12 base scaffolds: the donor's completion-state child mesh.
        scaffold_sid = sid + "a"
        out.append({
            "sid": scaffold_sid, "kind": "building",
            "obj_name": scaffold_sid, "tex_name": "scaffold",
            "mesh": os.path.join(actors, af, "attach", "%sa.osm" % ab),
            "texture": scaffold_dds,
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


# --------------------------------------------------------------------------
# C01-ASSET — additive nation / relief tables.
#
# Every function below is OPT-IN. A default invocation still calls only the
# five original tables (unit/building/ship/env/stage) and produces the exact
# same 280-entry manifest. The additive run writes a SEPARATE manifest name
# and the asset owner text-inserts its entries into the shipped manifest so
# all 280 existing entries and all 280 existing asset bytes stay untouched
# (N06 §3, Z05 §4). No donor binary is copied into the repo: the same
# read_mesh()/write_obj()/convert_texture() path derives OBJ/MTL/PNG from the
# private install, which is only ever read.
# --------------------------------------------------------------------------

def nation_building_models(game: str) -> list:
    """C01-ASSET / N07 T0 — additive nation-hall table (4 default nations).

    Donor sources (read-only, private use):
      data/actors/buildings/<nat>/<nat>cen.osm
      data/materials/buildings/<nat>/<nat>cen.dds
    N02 A2 / N07 §3.2 confirm a distinct hall mesh+albedo for all 21 nations;
    the port only converts ukrcen (as the generic `cen`). `ruscen` is the
    owner-mandated different Russian hall (15,348 verts/9,936 faces vs
    ukrcen's 5,611/3,714 — N06 §1.1). bav/pol/swe are N07's other T0 starts.
    """
    actors = os.path.join(game, "data", "actors", "buildings")
    mats = os.path.join(game, "data", "materials", "buildings")
    # port sid -> (actor folder, actor base, texture folder, texture base)
    table = {
        "ruscen": ("rus", "ruscen", "rus", "ruscen"),
        "bavcen": ("bav", "bavcen", "bav", "bavcen"),
        "polcen": ("pol", "polcen", "pol", "polcen"),
        "swecen": ("swe", "swecen", "swe", "swecen"),
    }
    return [{
        "sid": sid, "kind": "building",
        "mesh": os.path.join(actors, af, ab + ".osm"),
        "texture": os.path.join(mats, tf, tb + ".dds"),
        "directions": 1,
    } for sid, (af, ab, tf, tb) in table.items()]


def nation_peasant_models(game: str) -> list:
    """C01-ASSET / N06 §1.2 — exact 8-nation peasant table.

    The port previously mapped only `peasant -> peaukr`, so no nation-stemmed
    peasant mesh existed on disk (N01/N03). Each `.oss` is a distinct donor
    binary with its own bone/vertex/face counts; `convert_skins.py` reads each
    nation's own AAF for action ranges (N06 B5: `pearus k=486`, others 483).
    `peaukr` is a derived duplicate of the shipped `peasant.obj` (N06 B12);
    the uniform 8-stem mapping is kept deliberately for a consistent sid map.
    """
    actors = os.path.join(game, "data", "actors", "units")
    mats = os.path.join(game, "data", "materials", "units")
    bases = ("pearus", "peaukr", "peapol", "peaaus",
             "peaeng", "peaspa", "peatur", "peasco")
    return [{
        "sid": base, "kind": "unit",
        "mesh": os.path.join(actors, base + ".oss"),
        "texture": os.path.join(mats, base + ".dds"),
        "directions": 8,
    } for base in bases]


def nation_signature_models(game: str) -> list:
    """C01-ASSET / N07 §6.1 T0 — additive signature units for the 4 starts.

    N07 T0 picks one donor-distinct signature unit per default nation:
    Russia `pikemanrus`, Bavaria `musketeer18bav`, Sweden `pikeman18swe`.
    Poland's signature `wingedhussar` is already converted in the base set,
    so it is NOT re-emitted here. All three are real donor `.oss`+`.dds`+`.aaf`
    triples; no shape or frame range is invented.
    """
    actors = os.path.join(game, "data", "actors", "units")
    mats = os.path.join(game, "data", "materials", "units")
    bases = ("pikemanrus", "musketeer18bav", "pikeman18swe")
    return [{
        "sid": base, "kind": "unit",
        "mesh": os.path.join(actors, base + ".oss"),
        "texture": os.path.join(mats, base + ".dds"),
        "directions": 8,
    } for base in bases]


def relief_models(game: str) -> list:
    """Z05 — additive donor relief-prop table (terrainmesh1..4 only).

    Donor sources (read-only, private use):
      data/actors/env/terrainmeshN.osm      (IDP2 version 8, first frame only)
      data/materials/env/terrainmeshN.dds   (terrainmeshN.prop:14 summer albedo)
    Geometry and pixels are DERIVED by the existing read_osm()/write_obj()/
    convert_texture() path; no donor .osm/.dds is copied into the repo.

    terrainplateau1..4 are deliberately excluded: no donor albedo, no .prop,
    zero pattern.lib BaseName refs (Z05 §1.3). Per-object Scaling/Position/
    Direction are placement data (pattern.lib), NOT mesh data — the OBJ stays
    in RAW donor units (scale is left raw) and a later instancing consumer
    applies the authored per-placement transform. kind="relief" keeps
    force_opaque=False so the real donor alpha is preserved (Z05 §1.1).
    """
    actors = os.path.join(game, "data", "actors", "env")
    mats = os.path.join(game, "data", "materials", "env")
    table = {
        "terrainmesh1": "terrainmesh1",
        "terrainmesh2": "terrainmesh2",
        "terrainmesh3": "terrainmesh3",
        "terrainmesh4": "terrainmesh4",
    }
    return [{
        "sid": sid, "kind": "relief",
        "mesh": os.path.join(actors, base + ".osm"),
        "texture": os.path.join(mats, base + ".dds"),
        "directions": 1,
    } for sid, base in table.items()]


# --------------------------------------------------------------------------
# A3 — additive palm / desert-scrub / plantyellow conversion.
#
# Opt-in and self-contained: --palm-desert writes ONLY new derived assets under
# <out>/{obj,tex}/shared/terrain/ and APPENDS new sid entries to <out>/manifest.json.
# No existing asset is rewritten, no donor binary is copied or executed, and the
# legacy default pipeline stays byte-identical. Donor sources are read-only:
#   mesh:  data/actors/env/<stem>.osm       (IDP2 v8, first frame only)
#   albedo: data/materials/env/<material>.dds
# Material provenance: X16 rows 9-14, 69-72, 98-99 + each data/objects/env/
# <stem>.prop DefaultMaterialName (palm*->palm1, desertN->desertN,
# plantyellow*/plantyellowN->plantsyellowatlas).
# --------------------------------------------------------------------------

def desert_palm_models(game: str) -> list:
    """Return the donor-grounded A3 model table (28 canonical + 8 alias sids)."""
    actors = os.path.join(game, "data", "actors", "env")
    mats = os.path.join(game, "data", "materials", "env")
    canonical = []
    # palm1..5 + palmsmall1..3 all declare DefaultMaterialName = palm1.
    for i in range(1, 6):
        canonical.append(("palm%d" % i, "palm%d" % i, "palm1", "palm1"))
    for i in range(1, 4):
        canonical.append(("palmsmall%d" % i, "palmsmall%d" % i, "palm1", "palm1"))
    # Each desertN has three real donor mesh variants (.1/.2/.3) and its own
    # summer albedo; keep the variant index in the sid instead of collapsing it.
    for i in range(1, 6):
        for v in range(1, 4):
            canonical.append(("desert%d_%d" % (i, v), "desert%d.%d" % (i, v),
                              "desert%d" % i, "desert%d" % i))
    # plantyellow props reuse plant1..5.mesh with plantsyellowatlas albedo.
    for i in range(1, 6):
        canonical.append(("plantyellow%d" % i, "plant%d" % i,
                          "plantsyellowatlas", "plantsyellowatlas"))
    out = []
    for sid, stem, mat, png in canonical:
        out.append({
            "sid": sid, "kind": "env",
            "mesh": os.path.join(actors, stem + ".osm"),
            "texture": os.path.join(mats, mat + ".dds"),
            "obj_name": sid, "tex_name": png, "directions": 1,
            "exact": True, "source_rel": "data/actors/env/%s.osm" % stem,
            "alias_of": None,
        })
    # Feed BaseNames (AUDIT §3, X16) bind to the variant-1 asset: same derived
    # geometry, no second file and no synthetic variant.
    aliases = [("palm", "palm1"), ("palmsmall", "palmsmall1")]
    aliases += [("desert%d" % i, "desert%d_1" % i) for i in range(1, 6)]
    aliases.append(("plantyellow", "plantyellow1"))
    by_sid = {m["sid"]: m for m in out}
    for sid, target in aliases:
        entry = dict(by_sid[target])
        entry["sid"] = sid
        entry["alias_of"] = target
        out.append(entry)
    return out


def _parse_obj_exact(path: str) -> dict:
    """Parse an exact-float OBJ back into reader-shaped arrays for comparison."""
    verts, uvs, faces, uvf = [], [], [], []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("v "):
                verts.append(tuple(float(x) for x in line.split()[1:4]))
            elif line.startswith("vt "):
                uvs.append(tuple(float(x) for x in line.split()[1:3]))
            elif line.startswith("f "):
                parts = [p.split("/") for p in line.split()[1:4]]
                faces.append(tuple(int(p[0]) - 1 for p in parts))
                uvf.append(tuple(int(p[1]) - 1 for p in parts))
    return {"verts": verts, "uvs": uvs, "faces": faces, "uv_faces": uvf}


def _rgba_bytes(path: str) -> bytes:
    if Image is None:
        return b""
    img = Image.open(path)
    img.load()
    return img.convert("RGBA").tobytes()


def convert_palm_desert(game: str, out: str) -> int:
    """A3: emit derived OBJ/MTL/PNG, append manifest sids, write provenance."""
    import hashlib

    obj_dir = os.path.join(out, "obj", "shared", "terrain")
    tex_dir = os.path.join(out, "tex", "shared", "terrain")
    os.makedirs(obj_dir, exist_ok=True)
    os.makedirs(tex_dir, exist_ok=True)
    models = desert_palm_models(game)
    failures = []
    tex_report, mesh_report = [], []
    meshes_by_name = {}

    # -- textures: one PNG per distinct donor albedo -----------------------
    for png, src in sorted({m["tex_name"]: m["texture"] for m in models}.items()):
        if not os.path.exists(src):
            failures.append("MISSING texture " + src)
            continue
        dst = os.path.join(tex_dir, png + ".png")
        if not convert_texture(src, dst, force_opaque=False):
            failures.append("texture failed " + src)
            continue
        donor_rgba = _rgba_bytes(src)
        png_rgba = _rgba_bytes(dst)
        alpha = bytes(png_rgba[3::4])
        tex_report.append({
            "material": png,
            "source": "\\".join(["data", "materials", "env", png + ".dds"]),
            "output": "variant3d/assets/models/tex/shared/terrain/%s.png" % png,
            "source_sha256": hashlib.sha256(open(src, "rb").read()).hexdigest(),
            "output_sha256": hashlib.sha256(open(dst, "rb").read()).hexdigest(),
            "source_bytes": os.path.getsize(src),
            "output_bytes": os.path.getsize(dst),
            "donor_decoded_mode": "RGBA",
            "donor_decoded_size": list(Image.open(src).size),
            "decoded_rgba_sha256": hashlib.sha256(donor_rgba).hexdigest(),
            "decoded_alpha_sha256": hashlib.sha256(alpha).hexdigest(),
            "alpha_min": min(alpha), "alpha_max": max(alpha),
            "alpha_unique_values": len(set(alpha)),
            "pixels_equal": donor_rgba == png_rgba,
            "alpha_equal": alpha == bytes(donor_rgba[3::4]),
            "retouch": "none; direct DDS decode -> RGBA PNG re-encode",
        })

    # -- meshes: one OBJ+MTL per distinct donor .osm ------------------------
    for name, m in sorted({x["obj_name"]: x for x in models}.items()):
        if not os.path.exists(m["mesh"]):
            failures.append("MISSING mesh " + m["mesh"])
            continue
        mesh = read_osm(m["mesh"])
        n_v, n_uv = len(mesh["verts"]), len(mesh["uvs"])
        if any(not (0 <= i < n_v) for tri in mesh["faces"] for i in tri):
            failures.append("vertex index out of range " + m["mesh"])
            continue
        if any(not (0 <= i < n_uv) for tri in mesh["uv_faces"] for i in tri):
            failures.append("UV index out of range " + m["mesh"])
            continue
        obj_path = os.path.join(obj_dir, name + ".obj")
        mtl_path = os.path.join(obj_dir, name + ".mtl")
        write_obj_exact(obj_path, mesh, name + ".mtl", m["source_rel"])
        write_mtl(mtl_path, "../../../tex/shared/terrain/%s.png" % m["tex_name"])
        back = _parse_obj_exact(obj_path)
        checks = {
            "verts_count": len(back["verts"]) == n_v,
            "uvs_count": len(back["uvs"]) == n_uv,
            "faces_count": len(back["faces"]) == len(mesh["faces"]),
            "vertices_exact": back["verts"] == [tuple(v) for v in mesh["verts"]],
            "uvs_exact": back["uvs"] == [tuple(t) for t in mesh["uvs"]],
            "faces_exact": back["faces"] == [tuple(t) for t in mesh["faces"]],
            "uv_faces_exact": back["uv_faces"] == [tuple(t) for t in mesh["uv_faces"]],
            "mtllib_present": ("mtllib " + name + ".mtl") in open(obj_path, encoding="utf-8").read(),
            "usemtl_present": "usemtl model" in open(obj_path, encoding="utf-8").read(),
            "mtl_texture_exists": os.path.exists(os.path.join(
                obj_dir, "../../../tex/shared/terrain/%s.png" % m["tex_name"])),
        }
        xs = [v[0] for v in mesh["verts"]]
        ys = [v[1] for v in mesh["verts"]]
        zs = [v[2] for v in mesh["verts"]]
        info = {
            "mesh_variant": name,
            "source": m["source_rel"],
            "obj": "variant3d/assets/models/obj/shared/terrain/%s.obj" % name,
            "mtl": "variant3d/assets/models/obj/shared/terrain/%s.mtl" % name,
            "source_sha256": hashlib.sha256(open(m["mesh"], "rb").read()).hexdigest(),
            "obj_sha256": hashlib.sha256(open(obj_path, "rb").read()).hexdigest(),
            "mtl_sha256": hashlib.sha256(open(mtl_path, "rb").read()).hexdigest(),
            "source_bytes": os.path.getsize(m["mesh"]),
            "obj_bytes": os.path.getsize(obj_path),
            "mtl_bytes": os.path.getsize(mtl_path),
            "format": "osm", "version": mesh["version"],
            "frame_name": mesh["frame_name"],
            "verts": n_v, "uvs": n_uv, "faces": len(mesh["faces"]),
            "bbox": [min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)],
            "mtl_texture_reference": "../../../tex/shared/terrain/%s.png" % m["tex_name"],
            "checks": checks,
            "float_serialization": "shortest round-trip repr; exact float32 values reparse bit-identical",
        }
        meshes_by_name[name] = info
        mesh_report.append(info)

    if failures:
        print("A3 failures: " + "; ".join(failures))
        return 1

    # -- manifest: append only; keep the shipped CRLF / indent=1 byte style --
    manifest_path = os.path.join(out, "manifest.json")
    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)
    existing = {str(x.get("sid", "")) for x in manifest.get("models", [])}
    before = len(manifest.get("models", []))
    added_sids = []
    for m in models:
        sid = m["sid"]
        if sid in existing:
            failures.append("manifest sid already exists: " + sid)
            continue
        info = meshes_by_name[m["obj_name"]]
        entry = {
            "sid": sid, "kind": "env",
            "mesh": m["mesh"], "texture": m["texture"], "directions": 1,
            "obj": os.path.join(obj_dir, m["obj_name"] + ".obj"),
            "texture_png": os.path.join(tex_dir, m["tex_name"] + ".png"),
            "bbox": info["bbox"], "verts": info["verts"],
            "faces": info["faces"], "uvs": info["uvs"],
            "bucket": "shared/terrain",
            "assets": {
                "obj": "res://assets/models/obj/shared/terrain/%s.obj" % m["obj_name"],
                "tex": "res://assets/models/tex/shared/terrain/%s.png" % m["tex_name"],
            },
            "source_rel": m["source_rel"],
        }
        if m["alias_of"]:
            entry["alias_of"] = m["alias_of"]
        manifest["models"].append(entry)
        manifest.setdefault("extra_assets", {})[sid] = {
            "obj": entry["assets"]["obj"],
            "tex": entry["assets"]["tex"],
            "bucket": "shared/terrain",
        }
        added_sids.append(sid)
    text = json.dumps(manifest, indent=1).replace("\n", "\r\n")
    tmp = manifest_path + ".tmp-palm-desert"
    with open(tmp, "w", encoding="utf-8", newline="") as f:
        f.write(text)
    os.replace(tmp, manifest_path)

    # -- provenance manifest (FIX-FIELD-ASSETS invariant pattern) -----------
    prov = {
        "schema": "fix-palm-desert/conversion/v1",
        "worker": "CONVERT-PALM-DESERT",
        "date": "2026-11-26",
        "donor_root_policy": "C:/Games/Cossacks 3 (read-only private install)",
        "generator": "offline Python + Pillow; OSM topology read through "
                     "variant3d/tools/convert_models.py:read_osm",
        "tools_modified": ["variant3d/tools/convert_models.py (additive "
                           "--palm-desert mode; legacy pipeline untouched)"],
        "counts": {
            "donor_textures_read": len(tex_report),
            "png_outputs": len(tex_report),
            "donor_mesh_variants_converted": len(mesh_report),
            "obj_outputs": len(mesh_report),
            "mtl_outputs": len(mesh_report),
            "manifest_sids_added": len(added_sids),
            "manifest_model_entries_before": before,
            "manifest_model_entries_after": len(manifest["models"]),
            "extra_asset_mappings_added": len(added_sids),
            "donor_binaries_copied": 0,
        },
        "invariants": {
            "all_texture_pixels_equal": all(t["pixels_equal"] for t in tex_report),
            "all_texture_alpha_equal": all(t["alpha_equal"] for t in tex_report),
            "all_mesh_vertices_exact": all(m["checks"]["vertices_exact"] for m in mesh_report),
            "all_mesh_uvs_exact": all(m["checks"]["uvs_exact"] for m in mesh_report),
            "all_mesh_faces_exact": all(m["checks"]["faces_exact"] for m in mesh_report),
            "all_mesh_uv_faces_exact": all(m["checks"]["uv_faces_exact"] for m in mesh_report),
            "all_mtl_textures_resolve": all(m["checks"]["mtl_texture_exists"] for m in mesh_report),
            "synthetic_art": False,
            "color_retouch": False,
            "donor_dds_or_osm_in_outputs": [],
        },
        "textures": tex_report,
        "meshes": mesh_report,
        "manifest_sids": added_sids,
        "limitations": [
            "Static/offline conversion only; no Godot editor, importer, runner, "
            "render, capture or git command was run.",
            "Every donor DDS carries mip levels; each derived PNG contains only "
            "the base level. No mip chain was generated or copied.",
            "New PNG/OBJ assets have no .import sidecars; a normal Godot import "
            "is required before ResourceLoader.exists/load can be relied on.",
            "Winter albedo variants (palm1w..3w, desert1w..5w, "
            "plantsyellowatlasw) are not converted here; only the donor "
            "DefaultMaterialName summer albedo used by each MTL is emitted.",
            "Feed BaseName -> sid rules in terrain_donor_props.gd are unchanged; "
            "binding these sids is separate follow-up work.",
            "No donor/port A/B frame exists. Pixel/topology equality is not a "
            "visual parity claim.",
        ],
        "visual_parity_claim": False,
    }
    prov_path = os.path.join(obj_dir, "palm_desert_conversion.manifest.json")
    with open(prov_path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(prov, f, indent=2)
        f.write("\n")

    print("A3 done: %d meshes, %d textures, %d manifest sids (models %d -> %d)" % (
        len(mesh_report), len(tex_report), len(added_sids), before, len(manifest["models"])))
    return 0 if not failures else 1


def load_bucket_map() -> dict:
    """FOLD-06: read the shipped additive `bucket` map; no nation logic here.

    A sid absent from the shipped manifest is written flat (with a warning), so
    an additive C01-ASSET run cannot silently invent a bucket. The default
    pipeline stays byte-identical unless --bucket-layout is requested.
    """
    path = Path(__file__).resolve().parents[1] / "assets" / "models" / "manifest.json"
    if not path.is_file():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}
    return {str(m.get("sid", "")): str(m.get("bucket", ""))
            for m in data.get("models", []) if m.get("bucket")}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="the installed game folder (default: $COSSACKS3_DIR "
                         "or C:\\Games\\Cossacks 3)")
    ap.add_argument("--out", required=True, help="the folder inside the project")
    ap.add_argument("--include-stages", action="store_true",
                    help="BUILD-ART-CONV-01: also convert the 108 donor "
                         "construction-stage / scaffold OSMs (opt-in; the "
                         "default run is byte-identical to the base pipeline)")
    ap.add_argument("--nation-art", action="store_true",
                    help="C01-ASSET: emit ONLY the additive nation halls, "
                         "peasants and signature units (opt-in; never mixed "
                         "with the 280 base entries)")
    ap.add_argument("--include-relief", action="store_true",
                    help="Z05: also convert the 4 donor terrainmeshN relief "
                         "props (opt-in; scale stays raw in the OBJ)")
    ap.add_argument("--manifest-name", default="manifest.json",
                    help="C01-ASSET: manifest filename written under --out "
                         "(default: manifest.json; an additive run must use a "
                         "separate name, e.g. manifest_addendum.json)")
    ap.add_argument("--bucket-layout", action="store_true",
                    help="FOLD-06: write obj/tex into the manifest bucket tree "
                         "and emit additive bucket/assets fields; default off "
                         "keeps the flat 280-entry pipeline byte-identical")
    ap.add_argument("--palm-desert", action="store_true",
                    help="A3: convert donor palm/palmsmall/desert1..5/plantyellow "
                         "props into shared/terrain and append new manifest sids; "
                         "legacy pipeline is untouched")
    args = ap.parse_args()

    # expanduser makes ~/: Linux/macOS paths work; Path.resolve is cross-platform.
    game = str(Path(args.game).expanduser().resolve())
    out = str(Path(args.out).expanduser().resolve())
    if args.palm_desert:
        return convert_palm_desert(game, out)
    obj_dir = os.path.join(out, "obj")
    tex_dir = os.path.join(out, "tex")
    os.makedirs(obj_dir, exist_ok=True)
    os.makedirs(tex_dir, exist_ok=True)
    bucket_map = load_bucket_map() if args.bucket_layout else {}
    if args.bucket_layout:
        print("bucket-layout: %d sids from shipped manifest" % len(bucket_map))

    models = (unit_models(game) + building_models(game) + ship_models(game)
              + env_models(game))
    if args.include_stages:
        # Additive only: base entries keep their original sid/name/texture.
        models = models + stage_models(game)
    if args.nation_art:
        # C01-ASSET: an additive run emits ONLY the new nation sids. The asset
        # owner text-inserts them into the shipped manifest so all 280
        # existing entries and asset bytes stay byte-identical (N06 §3).
        # Never mix the base tables into an additive manifest rewrite.
        models = (nation_building_models(game) + nation_peasant_models(game)
                  + nation_signature_models(game))
    if args.include_relief:
        # Z05: append the 4 relief props (after nation art when both flags
        # are set, so one run derives the whole additive set).
        models = models + relief_models(game)
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
        # BUILD-ART-CONV-01: per-entry output overrides. Defaults keep the
        # original names, so a run without --include-stages is unchanged.
        obj_name = m.get("obj_name", sid) + ".obj"
        mtl_name = m.get("obj_name", sid) + ".mtl"
        tex_name = m.get("tex_name", sid) + ".png"
        bucket = bucket_map.get(sid, "") if args.bucket_layout else ""
        if args.bucket_layout and not bucket:
            print("WARN no shipped bucket for %s; writing flat" % sid)
        if bucket:
            dest_obj = os.path.join(obj_dir, *bucket.split("/"))
            dest_tex = os.path.join(tex_dir, *bucket.split("/"))
            os.makedirs(dest_obj, exist_ok=True)
            os.makedirs(dest_tex, exist_ok=True)
            # obj/<bucket> -> tex/<bucket>: three levels up to models/, then tex.
            mtl_ref = os.path.join("..", "..", "..", "tex", *bucket.split("/"), tex_name)
        else:
            dest_obj, dest_tex = obj_dir, tex_dir
            mtl_ref = os.path.join("..", "tex", tex_name)
        write_obj(os.path.join(dest_obj, obj_name), mesh, mtl_name)
        write_mtl(os.path.join(dest_obj, mtl_name), mtl_ref)
        convert_texture(m["texture"], os.path.join(dest_tex, tex_name),
                        force_opaque=(m["kind"] in ("unit", "building")))
        verts = mesh["verts"]
        xs = [v[0] for v in verts]
        ys = [v[1] for v in verts]
        zs = [v[2] for v in verts]
        entry = dict(m)
        entry["obj"] = os.path.join(dest_obj, obj_name)
        entry["texture_png"] = os.path.join(dest_tex, tex_name)
        if bucket:
            entry["bucket"] = bucket
            entry["assets"] = {
                "obj": "res://assets/models/obj/%s/%s" % (bucket, obj_name),
                "tex": "res://assets/models/tex/%s/%s" % (bucket, tex_name),
            }
        entry["bbox"] = [min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)]
        entry["verts"] = len(verts)
        entry["faces"] = len(mesh["faces"])
        manifest["models"].append(entry)
        ok += 1
        print("OK %-12s %-8s verts=%-5d faces=%-5d bbox z %.2f..%.2f" % (
            sid, mesh["format"], len(verts), len(mesh["faces"]), min(zs), max(zs)))

    manifest_path = os.path.join(out, args.manifest_name)
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
    print("done: %d models, manifest at %s" % (ok, manifest_path))
    return 0 if ok == len(models) else 1


if __name__ == "__main__":
    sys.exit(main())
