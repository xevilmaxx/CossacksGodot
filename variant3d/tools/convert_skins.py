#!/usr/bin/env python3
"""Export donor-grounded skin/pose data as a runtime asset set for anim3d.gd.

V7-78. Private-use, READ-ONLY donor access: this tool only opens the .oss/.aaf
files named by variant3d/assets/models/manifest.json; it never writes into the
donor install and never runs a donor binary.

WHY A SUBSET
------------
A full .oss anim block is bones * k * 7 float32 values. Measured across the 55
real .oss units in the manifest that is 3,247,545 floats (~13 MB binary, ~32 MB
as JSON) - far more than a shipped 3D asset set needs. This exporter keeps a
DETERMINISTIC SUBSET of donor frames: for every selected AAF action it keeps
`--frames-per-action` frames using the exact same donor-order decimation as
bake_sprites.sample (:145-152). The union of those frames is stored, in sorted
order, with its exact donor frame indices in both the per-sid JSON and
index.json. No frame index is invented and no bone-track value is synthesised.

FORMAT (schema c3_skin_v1)
--------------------------
Per sid JSON:
  sid, source, path, aaf_path, cite, skin_math, label, rig, visual, coord,
  k, fps, bones, v, bytes,
  actions : { name: {first, last, donor, frames:[exact donor frame indices]} },
  frames  : sorted union of every exported donor frame index,
  verts   : [[x,y,z], ...]                 (v bind verts, donor Z-up metres)
  weights : [[[bone,weight], ...], ...]    (v weight lists, donor order)
  anim    : [ [ [px,py,pz,rx,ry,rz,rw], ... per frame ], ... per bone ]
            anim[bi][fi] is donor bone bi at donor frame index frames[fi].

The runtime (anim3d.gd) rebuilds packed arrays from this and skins with the
verbatim bake_sprites.qmat/skin math (bake_sprites.py:118-143). No 2D bake,
sprite sheet, PNG, or invented keyframe is produced.

DONOR CITATIONS
---------------
  docs/decomp/DC_FORMATS.md:44,46-64     .oss <6i k,fps,b,v,fc,t> + payload
  variant3d/tools/bake_sprites.py:91-103 read_oss (layout copied below)
  variant3d/tools/bake_sprites.py:105-116 read_aaf (dialect copied below)
  variant3d/tools/bake_sprites.py:118-143 qmat + skin (flat-root, no parents)
  variant3d/tools/bake_sprites.py:145-152 sample (donor-order decimation)
  variant3d/tools/convert_models.py:43-66 identical vertex order in the OBJ
  data/animations/aaf/<base>.aaf          per-unit inclusive action ranges
  data/actors/units/<base>.oss            per-unit skin source (manifest mesh)

Usage:
  python variant3d/tools/convert_skins.py \
      --game "C:\\Games\\Cossacks 3" \
      --manifest variant3d/assets/models/manifest.json \
      --out variant3d/assets/models/skin

FIX-SAIL-MESH — derived sail geometry (opt-in, skin pass not run):
  python variant3d/tools/convert_skins.py --sail-mesh \
      --game "C:\\Games\\Cossacks 3" \
      --sail-out variant3d/assets/models/obj/shared/buildings

The .oss reader below is shared with the sail exporter: read_oss(..., geometry=True)
also keeps the donor faces / UVs / UV-faces so the OBJ can carry them verbatim.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import struct
from pathlib import Path

# Donor-derived port constants (anim3d.gd:55, :58, :98-100; V7-2 Table C).
PORT_LABEL = "PORT APPROXIMATION — NOT DONOR PARITY"
BLOCKED_RIG = ("BLOCKED: donor bone parent hierarchy unreadable "
               "(V7-2 §3.3.1 / Table B1); flat-root skin only")
MORPH_COORD = ("donor Z-up metres; vertex i == assets/models/obj/<sid>.obj "
               "vertex i (bake_sprites.py:94 / convert_models.py:47)")
OSS_CITE = "data/actors/units/<sid>.oss <6i k,fps,b,v,fc,t> (docs/decomp/DC_FORMATS.md:46-64)"
SKIN_CITE = "variant3d/tools/bake_sprites.py:118-143 (qmat + skin)"

# Actions worth shipping. DEC-U-AAF-ART C1 expands this request union from 8
# names to the donor-declared families the port needs; it is a UNION OF NAMES,
# never a table of frame ranges. convert_unit() looks every name up in the
# sid's OWN donor AAF (read_aaf, :161-180) and silently skips names that AAF
# does not declare. Therefore a peasant range can never be copied onto a
# musketeer (DANIM_01 §3 / DEC_U_aaf_art_audit §1.2, §5 C1): every exported
# first/last/donor citation comes from that one unit's file.
#
#  - peasant families (peaukr.aaf:8-20): workfood/workwood/workstone,
#    idlefood/idlewood/idlestone, walkfood/walkwood/walkstone, reaction,
#    prepare0/unprepare0.
#  - musketeer/grenadier families (musketeer.aaf:3-19, grenadier.aaf:3-32):
#    death0/death1/death2, idle1/idle2, walkprepare0/walkunprepare0,
#    trans01/trans10/trans02/trans12/trans20/trans21,
#    prepare1/unprepare1/prepare2/unprepare2, attack2/attack2before/attack2after.
#  - "construct" is the peasant build action: donor
#    data/animations/aaf/peaukr.aaf:17 = "construct",186,198,morph (inclusive
#    186..198, 13 frames @ 30 fps = 0.433 s); selected by
#    gc_statetag_action_build -> gc_anim_construct
#    (data/scripts/dmscript.global:13, :926; data/scripts/lib/unit.script:10877)
#    and bound in data/animations/acl/peasant.acl:2245-2252.
#
# No loop/one-shot/blend flag is invented here: all donor rows carry only
# "morph" (DEC_U §1.3); cycle policy lives in anim3d.gd C2.
DEFAULT_ACTIONS = (
    "idle", "idle0", "walk", "walk0", "death", "attack0", "attack1", "construct",
    "workfood", "workwood", "workstone",
    "idlefood", "idlewood", "idlestone",
    "walkfood", "walkwood", "walkstone",
    "reaction", "prepare0", "unprepare0",
    "death0", "death1", "death2",
    "idle1", "idle2",
    "walkprepare0", "walkunprepare0",
    "trans01", "trans10", "trans02", "trans12", "trans20", "trans21",
    "prepare1", "unprepare1", "prepare2", "unprepare2",
    "attack2", "attack2before", "attack2after",
)
SCHEMA = "c3_skin_v1"

# FIX-SAIL-MESH — donor mill-sail attach. The actor/prop name the mesh and its
# material; the geometry stays RAW donor Z-up metres (convert_models.py:43-66).
SAIL_OSS_REL = "data/actors/buildings/commoneur/attach/eurmilanim.oss"
SAIL_OBJ_STEM = "eurmilanim"
# The donor prop names material `eurmil` (summer); the already-converted repo
# PNG for that exact DDS is `mil.png` (manifest.json sid `mil`, tex bucket).
SAIL_MTL_REF = r"..\..\..\tex\shared\buildings\mil.png"
SAIL_CITE = ("data/actors/buildings/commoneur/attach/eurmilanim.actor:5-6; "
             "data/objects/buildings/attach/eurmilanim.prop:17-21")
SAIL_EXPECT = {"k": 251, "fps": 30, "bones": 1, "v": 1098, "fc": 550, "t": 1098}


# ---------------------------------------------------------------------------
# DEC-U-TOOL-ATTACH C1/C2 - peasant attach-tool export (additive, offline)
# ---------------------------------------------------------------------------
# Donor facts, all read-only (DEC_U_tool_attach.md §1-§5, pin t_87f0f3c130b0):
#   56 <base>_<tool>.oss under data/actors/units/attach/ (8 nations x 7 tools);
#   header b=1, fps=30, k==k_body; every slot loads the SAME nation's
#   <base>.aaf; one shared material peaaustools (units.mat:18-19). The transform
#   is identity relative to the parent in every text source examined.
# No tool art is synthesised and no body mesh is reused as a tool: every tool
# asset below is decoded from ITS OWN donor .oss payload via read_oss(), and a
# failed gate is labelled DATA_GAP rather than filled or guessed.
ATTACH_TOOLS = ("axe", "bag", "cart", "hammer", "hoe", "lumber", "pick")

# §2.1 action -> tool map (unit.script:6991-7012 + dmscript.global:928-934).
# The port's "attack" bridge token resolves to donor attack0 first
# (anim3d.gd:102-104), so the donor name is used verbatim here.
ATTACH_ACTION_TOOL = {
    "workfood": "hoe",
    "workwood": "axe",
    "workstone": "pick",
    "construct": "hammer",
    "attack0": "axe",
    "walkfood": "bag", "idlefood": "bag",
    "walkwood": "lumber", "idlewood": "lumber",
    "walkstone": "cart", "idlestone": "cart",
}
ATTACH_TOOL_ACTIONS = {
    tool: tuple(name for name in DEFAULT_ACTIONS
                if ATTACH_ACTION_TOOL.get(name) == tool)
    for tool in ATTACH_TOOLS
}
ATTACH_OSS_REL = "data/actors/units/attach/%s_%s.oss"
ATTACH_ACTOR_REL = "data/actors/units/attach/%s_tools.actor"
ATTACH_GATE = {"fps": 30, "bones": 1}
ATTACH_DIR = "attach"
ATTACH_CITE = (
    "docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md §2.1,§5 C1/C2; "
    "data/scripts/lib/unit.script:6991-7012; data/scripts/dmscript.global:928-934; "
    "data/actors/units/attach/<base>_tools.actor:1-30; "
    "data/materials/units/units.mat:18-19"
)
# Both [U] items stay UNRESOLVED. Each ends in a fixed-camera close-up capture
# with a zero-mismatch termination criterion (§4); none is closed by a
# fallback, and no capture was produced or examined by this exporter.
ATTACH_U_ITEMS = {
    "T-A": {
        "label": "[U]-T-A donor runtime proof of child-0 tool swap/visibility",
        "status": "UNRESOLVED",
        "observation": "text only: actor-index swap + visibility on child 0, "
                       "identity relative transform (unit.script:6988,7014-7016; "
                       "DEC_U_tool_attach.md §1.2, §2.4)",
        "capture": "fixed camera, close-up on one peasant per action; every "
                   "tool-visible action of §2.1 plus hidden walk/idle/death; "
                   "log per frame (actionWindowFrame, child0 actorInd, "
                   "child0 visible, tool mesh name) over the FULL windows",
        "termination": "0 mismatching frames against the §2.1 map",
        "cite": "docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md §4",
    },
    "T-B": {
        "label": "[U]-T-B port 3D tool implementation proof",
        "status": "UNRESOLVED",
        "observation": "port 3D path has no tool-child node (§5 C3/C4); tool "
                       "shading unverified (ShaderLOD 26/23 vs body 18/11)",
        "capture": "fixed camera, same donor frame index, tool-mask pixel diff "
                   "per action window (donor silhouette vs port render, body "
                   "masked out), incl. cart/lumber occlusion parity",
        "termination": "0 mismatching tool-mask pixels for every sampled donor "
                       "frame of all tool-visible actions; 0 tool pixels on "
                       "hidden cases",
        "cite": "docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md §4",
    },
}
VISUAL_PARITY_CLAIM = False


# ---------------------------------------------------------------------------
# donor layout readers (verbatim shape from bake_sprites.py / convert_models.py)
# ---------------------------------------------------------------------------

def read_oss(path: str, geometry: bool = False) -> dict:
    """bake_sprites.py:91-103 / convert_models.py:48-71, read-only.

    geometry=False keeps the original skin path byte-identical. geometry=True
    additionally returns the donor face / UV / UV-face arrays without changing
    any offsets or interpretation.
    """
    with open(path, "rb") as f:
        raw = f.read()
    if len(raw) < 24:
        raise ValueError("short .oss header")
    k, fps, b, v, fc, t = struct.unpack_from("<6i", raw, 0)
    if not (0 < k < 100000 and 0 < fps < 1000 and 0 < b < 4096
            and 0 < v < 200000 and 0 <= fc < 500000 and 0 <= t < 500000):
        raise ValueError("implausible .oss header %r" % ((k, fps, b, v, fc, t),))
    off = 24
    verts = []
    for _ in range(v):
        verts.append(struct.unpack_from("<3f", raw, off)); off += 12
    geom_off = off
    off += fc * 12 + t * 8 + fc * 12          # faces, uv, uv-faces: skipped
    weights = []
    for _ in range(v):
        n = struct.unpack_from("<i", raw, off)[0]; off += 4
        if n < 0 or n > 16:
            raise ValueError("implausible weight count %d" % n)
        pairs = []
        for _ in range(n):
            pairs.append(struct.unpack_from("<if", raw, off)); off += 8
        weights.append(pairs)
    anim = []
    for _bone in range(b):
        frames = []
        for _frame in range(k):
            frames.append(struct.unpack_from("<7f", raw, off)); off += 28
        anim.append(frames)
    if off != len(raw):
        raise ValueError("size closure failed: consumed %d of %d bytes"
                         % (off, len(raw)))
    out = dict(k=k, fps=fps, bones=b, v=v, fc=fc, t=t,
               verts=verts, weights=weights, anim=anim, bytes=off)
    if geometry:
        p = geom_off
        faces = [struct.unpack_from("<3i", raw, p + 12 * i) for i in range(fc)]
        p += fc * 12
        uvs = [struct.unpack_from("<2f", raw, p + 8 * i) for i in range(t)]
        p += t * 8
        uv_faces = [struct.unpack_from("<3i", raw, p + 12 * i) for i in range(fc)]
        out.update(faces=faces, uvs=uvs, uv_faces=uv_faces)
    return out


def read_aaf(path: str) -> dict:
    """bake_sprites.py:105-116; values are inclusive (DC_FORMATS.md:109)."""
    acts: dict[str, tuple[int, int, int, str]] = {}
    if not os.path.isfile(path):
        return acts
    with open(path, "r", encoding="ascii", errors="replace") as fh:
        lines = fh.read().splitlines()[2:]
    for lineno, line in enumerate(lines, start=3):
        line = line.strip()
        if not line.startswith('"'):
            continue
        try:
            name, rest = line[1:].split('"', 1)
            fields = rest.strip().lstrip(",").split(",")
            first, last = int(fields[0]), int(fields[1])
            kind = fields[2].strip() if len(fields) > 2 else ""
            acts[name] = (first, last, lineno, kind)
        except (ValueError, IndexError):
            continue
    return acts


def sample_frames(first: int, last: int, n: int) -> list[int]:
    """bake_sprites.sample (:145-152), Python round() half-to-even."""
    if last <= first:
        return [first]
    total = last - first + 1
    if total <= n:
        return list(range(first, last + 1))
    if n > 1:
        return [first + round((last - first) * i / (n - 1)) for i in range(n)]
    return [first]


def qmat(x, y, z, w):
    """bake_sprites.py:118-129, donor row-vector convention."""
    M = ((1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)),
         (2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)),
         (2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)))
    return ((M[0][0], M[1][0], M[2][0]),
            (M[0][1], M[1][1], M[2][1]),
            (M[0][2], M[1][2], M[2][2]))


def skin_at(mesh: dict, frame: int) -> list[tuple[float, float, float]]:
    """bake_sprites.skin (:131-143), flat-root, ref_frame=-1 (raw skin)."""
    mats = [qmat(*mesh["anim"][bi][frame][3:]) for bi in range(mesh["bones"])]
    poss = [mesh["anim"][bi][frame][:3] for bi in range(mesh["bones"])]
    out = []
    for x, y, z in mesh["verts"]:
        sx = sy = sz = 0.0
        for bi, wgt in mesh["weights"][len(out)]:
            M, (px, py, pz) = mats[bi], poss[bi]
            sx += wgt * (M[0][0] * x + M[0][1] * y + M[0][2] * z + px)
            sy += wgt * (M[1][0] * x + M[1][1] * y + M[1][2] * z + py)
            sz += wgt * (M[2][0] * x + M[2][1] * y + M[2][2] * z + pz)
        out.append((sx, sy, sz))
    return out


def r6(x: float) -> float:
    """Trim float32 noise so the JSON stays compact (1e-6 m precision)."""
    return round(float(x), 6)


# ---------------------------------------------------------------------------
# FIX-SAIL-MESH — derived donor sail OBJ/MTL (geometry pass only)
# ---------------------------------------------------------------------------

def write_sail_obj(dest: Path, mesh: dict, mtl_name: str) -> None:
    """Same wire format as convert_models.write_obj (:114-130), donor order.

    Vertices stay RAW donor Z-up metres and UVs are the donor's own (no bake,
    no axis flip, no re-indexing); the runtime mount applies the proven
    _bake_mesh() transform instead. A different header line marks provenance.
    """
    with open(dest, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# Cossacks 3 donor sail mesh, derived by convert_skins.py "
                 "(FIX-SAIL-MESH); raw donor Z-up metres\n")
        fh.write("mtllib %s\n" % mtl_name)
        fh.write("o model\n")
        for x, y, z in mesh["verts"]:
            fh.write("v %.6f %.6f %.6f\n" % (x, y, z))
        for u, v in mesh["uvs"]:
            fh.write("vt %.6f %.6f\n" % (u, v))
        for tri, uv in zip(mesh["faces"], mesh["uv_faces"]):
            fh.write("f %d/%d %d/%d %d/%d\n" % (
                tri[0] + 1, uv[0] + 1, tri[1] + 1, uv[1] + 1,
                tri[2] + 1, uv[2] + 1))


def write_sail_mtl(dest: Path, texture_ref: str) -> None:
    """Same material block as convert_models.write_mtl (:133-137)."""
    with open(dest, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("newmtl model\n")
        fh.write("Kd 1 1 1\n")
        fh.write("map_Kd %s\n" % texture_ref)


def convert_sail_mesh(game: Path, out_dir: Path) -> dict:
    """Derive OBJ/MTL from the donor sail attach; never copy donor bytes."""
    src = game / SAIL_OSS_REL
    if not src.is_file():
        raise ValueError("missing donor sail mesh %s" % src)
    donor_bytes = src.read_bytes()
    mesh = read_oss(str(src), geometry=True)
    for field, want in SAIL_EXPECT.items():
        if mesh[field] != want:
            raise ValueError("donor sail %s=%d, expected %d (source drift)"
                             % (field, mesh[field], want))
    for tri in mesh["faces"] + mesh["uv_faces"]:
        if min(tri) < 0 or max(tri) >= mesh["v"]:
            raise ValueError("donor sail face index out of range")
    if len(mesh["faces"]) != mesh["fc"] or len(mesh["uvs"]) != mesh["t"] \
            or len(mesh["uv_faces"]) != mesh["fc"]:
        raise ValueError("donor sail geometry count mismatch")

    obj_path = out_dir / (SAIL_OBJ_STEM + ".obj")
    mtl_path = out_dir / (SAIL_OBJ_STEM + ".mtl")
    write_sail_obj(obj_path, mesh, SAIL_OBJ_STEM + ".mtl")
    write_sail_mtl(mtl_path, SAIL_MTL_REF)

    obj_hash = hashlib.sha256(obj_path.read_bytes()).hexdigest()
    mtl_hash = hashlib.sha256(mtl_path.read_bytes()).hexdigest()
    donor_hash = hashlib.sha256(donor_bytes).hexdigest()
    xs, ys, zs = zip(*mesh["verts"])
    return {
        "sid": SAIL_OBJ_STEM,
        "source": src.as_posix(),
        "cite": SAIL_CITE,
        "label": PORT_LABEL + " — donor geometry verbatim; spin/mount PORT APPROX, visual UNVERIFIED",
        "coord": MORPH_COORD,
        "k": mesh["k"], "fps": mesh["fps"], "bones": mesh["bones"],
        "v": mesh["v"], "fc": mesh["fc"], "t": mesh["t"],
        "vt": len(mesh["uvs"]), "f": len(mesh["faces"]),
        "donor_bytes": len(donor_bytes), "donor_sha256": donor_hash,
        "obj": obj_path.name, "obj_bytes": obj_path.stat().st_size,
        "obj_sha256": obj_hash,
        "mtl": mtl_path.name, "mtl_bytes": mtl_path.stat().st_size,
        "mtl_sha256": mtl_hash, "mtl_map_kd": SAIL_MTL_REF,
        "bbox": [min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)],
        "donor_binary_copied": obj_hash == donor_hash,
    }


# ---------------------------------------------------------------------------
# DEC-U-TOOL-ATTACH C1/C2 - additive attach-tool export
# ---------------------------------------------------------------------------

def sha256_file(path: str) -> str:
    """sha256 of a file's bytes; used for donor + derived-asset hash cites."""
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def export_attach_for_entry(entry: dict, game: Path, attach_dir: Path,
                            per_action: int, attach_subdir: str) -> dict:
    """Export the 7 donor tool skins for ONE body entry; never touch the body.

    The nation base is the body .oss stem (the donor attach files are keyed by
    nation, so the generic `peasant` sid resolves to the peaukr tool set). Every
    tool reuses its OWN body entry's already-exported donor frames - those came
    from that nation's own AAF in convert_unit() - and re-derives them from that
    same AAF with sample_frames(); any mismatch is a DATA_GAP, never a fill.
    """
    sid = str(entry.get("sid", ""))
    donor_oss = str(entry.get("donor_oss", ""))
    if not donor_oss or not os.path.isfile(donor_oss):
        raise ValueError("attach: body donor .oss missing for sid %s" % sid)
    base = Path(donor_oss).stem
    body_k = int(entry["k"])
    body_actions = entry.get("actions", {})
    aaf_rel = "data/animations/aaf/%s.aaf" % base
    acts = read_aaf(str(game / aaf_rel))
    visible = set(ATTACH_ACTION_TOOL)
    hidden = sorted(name for name in body_actions if name not in visible)

    tools: dict[str, dict] = {}
    for tool in ATTACH_TOOLS:
        rel = ATTACH_OSS_REL % (base, tool)
        src = game / rel
        rec: dict = {"tool": tool, "donor_oss": rel.replace("\\", "/")}
        if not src.is_file():
            rec.update(status="DATA_GAP",
                       error="missing donor attach .oss (no synthesis allowed)")
            tools[tool] = rec
            continue

        donor_bytes = src.read_bytes()
        mesh = read_oss(str(src))
        bad = []
        if mesh["bones"] != ATTACH_GATE["bones"]:
            bad.append("bones=%d!=1" % mesh["bones"])
        if mesh["fps"] != ATTACH_GATE["fps"]:
            bad.append("fps=%d!=30" % mesh["fps"])
        if mesh["k"] != body_k:
            bad.append("k=%d!=body_k=%d" % (mesh["k"], body_k))
        if bad:
            rec.update(status="DATA_GAP", error="gate fail: " + "; ".join(bad),
                       k=mesh["k"], fps=mesh["fps"], bones=mesh["bones"],
                       v=mesh["v"], fc=mesh["fc"], t=mesh["t"],
                       donor_sha256=sha256_file(str(src)))
            tools[tool] = rec
            continue

        # Per-sid frame windows only: this sid's own AAF, the same donor frames
        # its body entry already exported. No cross-sid range is ever copied.
        tool_actions: dict[str, dict] = {}
        union: set[int] = set()
        mismatch = []
        for name in ATTACH_TOOL_ACTIONS[tool]:
            if name not in acts or name not in body_actions:
                continue
            first, last, lineno, kind = acts[name]
            expect = sample_frames(first, last, per_action)
            frames = [int(fr) for fr in body_actions[name]]
            if expect != frames:
                mismatch.append("%s:AAF%s!=body%s" % (name, expect, frames))
                continue
            tool_actions[name] = {
                "first": first, "last": last, "kind": kind,
                "donor": aaf_rel.replace("\\", "/") + ":%d" % lineno,
                "frames": frames,
            }
            union.update(frames)
        if mismatch or not tool_actions:
            rec.update(status="DATA_GAP",
                       error="AAF frame mismatch/absent: "
                             + (", ".join(mismatch) if mismatch
                                else "no visible action exported"),
                       k=mesh["k"], fps=mesh["fps"], bones=mesh["bones"],
                       v=mesh["v"], fc=mesh["fc"], t=mesh["t"],
                       donor_sha256=sha256_file(str(src)))
            tools[tool] = rec
            continue

        frames = sorted(union)
        # Single-bone rigid track: only bone 0 is sampled (b==1 gate above).
        # Keep the c3_skin_v1 shape anim[bone][frame][7], not anim[frame][7].
        anim_out = [[[r6(q) for q in mesh["anim"][0][fr]] for fr in frames]]
        payload = {
            "schema": SCHEMA,
            "sid": sid,
            "tool": tool,
            "attach_key": base + "_" + tool,
            "kind": "peasant_attach_tool",
            "source": "donor_oss_attach",
            "path": rel.replace("\\", "/"),
            "aaf_path": aaf_rel.replace("\\", "/"),
            "cite": ATTACH_CITE,
            "skin_math": SKIN_CITE,
            "label": PORT_LABEL,
            "rig": "donor b=1 single-bone rigid track; flat-root skin, no parent hierarchy",
            "visual": "UNVERIFIED",
            "visual_parity_claim": VISUAL_PARITY_CLAIM,
            "coord": MORPH_COORD,
            "k": mesh["k"], "fps": mesh["fps"], "bones": mesh["bones"],
            "v": mesh["v"], "fc": mesh["fc"], "t": mesh["t"],
            "bytes": mesh["bytes"],
            "donor_bytes": len(donor_bytes),
            "donor_sha256": sha256_file(str(src)),
            "actions": tool_actions,
            "frames": frames,
            "verts": [[r6(x), r6(y), r6(z)] for x, y, z in mesh["verts"]],
            "weights": [[[int(bi), r6(w)] for bi, w in pairs]
                        for pairs in mesh["weights"]],
            "anim": anim_out,
        }
        # Key by SID (the donor base is kept in attach_key/path): two port sids
        # can resolve to the same nation base (peasant -> peaukr) and must not
        # overwrite one another's cited asset hash.
        asset_rel = attach_subdir.strip().strip("/\\") + "/" + sid + "_" + tool + ".json"
        dest = attach_dir / (sid + "_" + tool + ".json")
        dest.parent.mkdir(parents=True, exist_ok=True)
        with open(dest, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, separators=(",", ":"), ensure_ascii=False)

        rec.update(status="exported", asset=asset_rel,
                   donor_sha256=payload["donor_sha256"],
                   asset_sha256=sha256_file(str(dest)),
                   donor_bytes=len(donor_bytes), asset_bytes=dest.stat().st_size,
                   k=mesh["k"], fps=mesh["fps"], bones=mesh["bones"],
                   v=mesh["v"], fc=mesh["fc"], t=mesh["t"],
                   actions={name: a["frames"]
                            for name, a in tool_actions.items()},
                   frames=frames)
        tools[tool] = rec

    return {
        "base": base,
        "donor_body_oss": donor_oss.replace("\\", "/"),
        "donor_tools_actor": (ATTACH_ACTOR_REL % base).replace("\\", "/"),
        "aaf_path": aaf_rel.replace("\\", "/"),
        "cite": ATTACH_CITE,
        "action_tool_map": dict(ATTACH_ACTION_TOOL),
        "hidden_actions": hidden,
        "hidden_rule": ("child hidden for '', walk, idle, death, reaction and "
                        "any unmapped action (unit.script:6991-7012)"),
        "tools": tools,
        "visual_parity_claim": VISUAL_PARITY_CLAIM,
        "u_items_ref": ["T-A", "T-B"],
    }


def export_attach_mode(game: Path, out_dir: Path, index_name: str,
                       per_action: int, attach_subdir: str) -> dict:
    """ADDITIVE index edit: load the existing index, add attach blocks only.

    The 66 body entries, their 40 requested actions and every existing frame
    list are left byte-identical apart from the appended `attach` key and the
    additive header fields. A pristine `.bak-TOOLBAKER` is kept once.
    """
    index_path = out_dir / index_name
    if not index_path.is_file():
        raise ValueError("attach: no existing index at %s" % index_path)
    original = index_path.read_bytes()
    backup = Path(str(index_path) + ".bak-TOOLBAKER")
    if not backup.exists():
        backup.write_bytes(original)

    index = json.loads(original.decode("utf-8"))
    subdir = attach_subdir.strip().strip("/\\")
    attach_dir = out_dir / subdir
    attach_dir.mkdir(parents=True, exist_ok=True)

    exported = 0
    gaps = []
    for entry in index.get("entries", []):
        if not str(entry.get("sid", "")).startswith("pea") or entry.get("skipped"):
            continue
        block = export_attach_for_entry(entry, game, attach_dir, per_action, subdir)
        entry["attach"] = block
        for tool, rec in block["tools"].items():
            if rec.get("status") == "exported":
                exported += 1
            else:
                gaps.append("%s/%s: %s" % (entry["sid"], tool, rec.get("error")))

    index["visual_parity_claim"] = VISUAL_PARITY_CLAIM
    index["attach_export"] = {
        "status": "exported" if not gaps else "exported_with_data_gaps",
        "frames_per_action": per_action,
        "decimation": "sample_frames (bake_sprites.py:145-152), donor-order "
                      "round half-to-even",
        "range_policy": "per-sid: each tool reuses its own body entry's "
                        "exported donor frames from that nation's own <base>.aaf; "
                        "no cross-sid ranges",
        "gates": "b==1, fps==30, k==body k; reject-and-label DATA_GAP "
                 "otherwise (never synthesise, never reuse a body mesh)",
        "asset_dir": subdir + "/<sid>_<tool>.json",
        "no_synthesis": True,
        "body_mesh_reuse": False,
        "material": "peaaustools (units.mat:18-19) shared; not re-baked here",
        "schema": SCHEMA,
        "cite": ATTACH_CITE,
        "visual_parity_claim": VISUAL_PARITY_CLAIM,
    }
    index["u_items"] = ATTACH_U_ITEMS

    with open(index_path, "w", encoding="utf-8") as fh:
        json.dump(index, fh, separators=(",", ":"), ensure_ascii=False)
    return {"index": str(index_path), "backup": str(backup),
            "exported": exported, "gaps": gaps,
            "index_bytes": index_path.stat().st_size}


# ---------------------------------------------------------------------------
# export
# ---------------------------------------------------------------------------

def convert_unit(m: dict, game: Path, out_dir: Path,
                 actions: tuple[str, ...], per_action: int) -> dict:
    sid = str(m.get("sid", ""))
    mesh_path = str(m["mesh"])
    mesh_file = Path(mesh_path)
    with open(mesh_file, "rb") as fh:
        magic = fh.read(4)
    if magic == b"IDP2":
        return {"sid": sid, "skipped": True,
                "reason": "donor .osm/IDP2 hull (no skin tracks; V7-63 ships are static)",
                "mesh": mesh_path}
    mesh = read_oss(mesh_path)

    base = mesh_file.stem
    aaf_rel = "data/animations/aaf/%s.aaf" % base
    aaf_abs = game / aaf_rel
    acts = read_aaf(str(aaf_abs))

    exported: dict[str, dict] = {}
    union: set[int] = set()
    for name in actions:
        if name not in acts:
            continue
        first, last, lineno, kind = acts[name]
        if first < 0 or last >= mesh["k"] or last < first:
            continue
        frames = sample_frames(first, last, per_action)
        union.update(frames)
        exported[name] = {
            "first": first, "last": last, "kind": kind,
            "donor": aaf_rel.replace("\\", "/") + ":%d" % lineno,
            "frames": frames,
        }
    frames = sorted(union)
    fpos = {fr: i for i, fr in enumerate(frames)}

    # anim[bone][frame-position] - only donor values, no filling or guessing.
    anim_out = [
        [[r6(q) for q in mesh["anim"][bi][fr]] for fr in frames]
        for bi in range(mesh["bones"])
    ]
    payload = {
        "schema": SCHEMA,
        "sid": sid,
        "source": "donor_oss",
        "path": mesh_path,
        "aaf_path": aaf_rel.replace("\\", "/"),
        "cite": OSS_CITE,
        "skin_math": SKIN_CITE,
        "label": PORT_LABEL,
        "rig": BLOCKED_RIG,
        "visual": "UNVERIFIED",
        "coord": MORPH_COORD,
        "k": mesh["k"], "fps": mesh["fps"],
        "bones": mesh["bones"], "v": mesh["v"],
        "bytes": mesh["bytes"],
        "actions": exported,
        "frames": frames,
        "verts": [[r6(x), r6(y), r6(z)] for x, y, z in mesh["verts"]],
        "weights": [[[int(bi), r6(w)] for bi, w in pairs]
                    for pairs in mesh["weights"]],
        "anim": anim_out,
    }
    # DEC-U-AAF-ART C1: keep the shipped nation-first layout. `bucket` is the
    # manifest's OWN relative bundle (e.g. "rus/land_units"), the same value
    # the on-disk index entries carry; no location is invented here.
    bucket = str(m.get("bucket", "")).strip().strip("/\\")
    rel = (bucket + "/" + sid + ".json") if bucket else (sid + ".json")
    dest = out_dir / rel.replace("/", os.sep)
    dest.parent.mkdir(parents=True, exist_ok=True)
    with open(dest, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, separators=(",", ":"), ensure_ascii=False)

    # Independent donor-grounding evidence: flat-root skinned verts at the
    # first exported frame (computed here, NOT stored in the asset).
    probe = skin_at(mesh, frames[0]) if frames else []
    checksum = round(sum(p[0] + p[1] + p[2] for p in probe), 6) if probe else 0.0
    return {
        "sid": sid, "skipped": False,
        "file": rel, "bytes": dest.stat().st_size,
        "donor_oss": mesh_path, "donor_aaf": aaf_rel.replace("\\", "/"),
        "k": mesh["k"], "fps": mesh["fps"], "bones": mesh["bones"],
        "v": mesh["v"], "oss_bytes": mesh["bytes"],
        "actions": {name: a["frames"] for name, a in exported.items()},
        "frames": frames, "frame_count": len(frames),
        "skin_probe_frame": frames[0] if frames else -1,
        "skin_probe_checksum": checksum,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--game", default=os.environ.get("COSSACKS3_DIR",
                    r"C:\Games\Cossacks 3"), help="read-only donor install")
    ap.add_argument("--manifest", default="variant3d/assets/models/manifest.json")
    ap.add_argument("--out", default="variant3d/assets/models/skin")
    ap.add_argument("--frames-per-action", type=int, default=6)
    ap.add_argument("--actions", default=",".join(DEFAULT_ACTIONS))
    ap.add_argument("--index-name", default="index.json",
                    help="C01-ASSET: index filename written under --out "
                         "(default: index.json; an additive run must use a "
                         "separate name, e.g. index_nation.json)")
    ap.add_argument("--sail-mesh", action="store_true",
                    help="FIX-SAIL-MESH: export ONLY the donor eurmilanim.oss "
                         "sail geometry as derived OBJ/MTL; no skin pass, no "
                         "index write")
    ap.add_argument("--sail-out",
                    default="variant3d/assets/models/obj/shared/buildings",
                    help="destination folder for --sail-mesh OBJ/MTL")
    ap.add_argument("--attach-tools", action="store_true",
                    help="DEC-U C1/C2 ADDITIVE: load the existing index.json, "
                         "export per-sid peasant attach-tool skins into "
                         "<out>/attach/, add attach blocks + unresolved [U] "
                         "labels; no body pass, no donor binary run")
    ap.add_argument("--attach-dir", default=ATTACH_DIR,
                    help="subdir under --out for derived tool skins "
                         "(default: attach)")
    args = ap.parse_args()

    game = Path(args.game)
    if args.sail_mesh:
        sail_out = Path(args.sail_out)
        sail_out.mkdir(parents=True, exist_ok=True)
        try:
            sail = convert_sail_mesh(game, sail_out)
        except (OSError, ValueError) as exc:
            print("SAIL FAIL %s" % exc)
            return 1
        print("SAIL OK %s v=%d vt=%d f=%d (donor k=%d fps=%d b=%d fc=%d t=%d)"
              % (sail["obj"], sail["v"], sail["vt"], sail["f"], sail["k"],
                 sail["fps"], sail["bones"], sail["fc"], sail["t"]))
        print("  donor %s bytes sha256=%s"
              % (sail["donor_bytes"], sail["donor_sha256"]))
        print("  obj   %s bytes sha256=%s"
              % (sail["obj_bytes"], sail["obj_sha256"]))
        print("  mtl   %s bytes sha256=%s map_Kd=%s"
              % (sail["mtl_bytes"], sail["mtl_sha256"], sail["mtl_map_kd"]))
        return 0
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    actions = tuple(a.strip() for a in args.actions.split(",") if a.strip())
    if args.frames_per_action < 1:
        raise SystemExit("--frames-per-action must be >= 1")

    if args.attach_tools:
        try:
            r = export_attach_mode(game, out_dir, args.index_name,
                                   args.frames_per_action, args.attach_dir)
        except (OSError, ValueError, json.JSONDecodeError) as exc:
            print("ATTACH FAIL %s" % exc)
            return 1
        print("ATTACH OK %d tool skins -> %s/ ; index %d B (backup %s)"
              % (r["exported"], args.attach_dir, r["index_bytes"], r["backup"]))
        for gap in r["gaps"]:
            print("  DATA GAP %s" % gap)
        return 0 if not r["gaps"] else 1

    entries, skipped, failed = [], [], []
    for m in manifest.get("models", []):
        if m.get("kind") != "unit":
            continue
        try:
            row = convert_unit(m, game, out_dir, actions, args.frames_per_action)
        except (OSError, ValueError) as exc:
            failed.append({"sid": m.get("sid", ""), "error": str(exc),
                           "mesh": m.get("mesh", "")})
            continue
        (skipped if row.get("skipped") else entries).append(row)

    index = {
        "schema": SCHEMA,
        "generator": "variant3d/tools/convert_skins.py (V7-78)",
        "frames_per_action": args.frames_per_action,
        "actions_requested": list(actions),
        # DEC-U-AAF-ART C1 provenance — no new donor art, no cross-sid ranges.
        "aafart_c1": "per-sid AAF export union expanded; each sid reads only its own data/animations/aaf/<base>.aaf; frames_per_action=6 deterministic decimation retained; see docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md §5 C1",
        "label": PORT_LABEL,
        "visual": "UNVERIFIED",
        "skin_math": SKIN_CITE,
        "coord": MORPH_COORD,
        "count": len(entries),
        "total_bytes": sum(e["bytes"] for e in entries),
        "entries": entries,
        "skipped": skipped,
        "failed": failed,
    }
    index_path = out_dir / args.index_name
    with open(index_path, "w", encoding="utf-8") as fh:
        json.dump(index, fh, separators=(",", ":"), ensure_ascii=False, indent=None)

    print("exported %d skins, %d skipped, %d failed; total %.2f MB -> %s"
          % (len(entries), len(skipped), len(failed),
             index["total_bytes"] / 1e6, index_path))
    for row in entries[:5]:
        print("  %-18s k=%4d b=%2d v=%4d frames=%2d actions=%s %7d B"
              % (row["sid"], row["k"], row["bones"], row["v"],
                 row["frame_count"], ",".join(row["actions"]), row["bytes"]))
    for row in skipped:
        print("  SKIP %-18s %s" % (row["sid"], row["reason"]))
    for row in failed:
        print("  FAIL %-18s %s" % (row["sid"], row["error"]))
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
