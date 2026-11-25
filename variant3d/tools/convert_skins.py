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
"""
from __future__ import annotations

import argparse
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

# Actions worth shipping. "idle"/"walk"/"death" are the only ones the shipped
# renderer asks for (world3d_entities.gd:506-511); the rest are real donor AAF
# entries exported for completeness. All are taken from each unit's OWN AAF.
# "construct" is the peasant build action: donor
# data/animations/aaf/peaukr.aaf:17 = "construct",186,198,morph (inclusive 186..198,
# 13 frames @ 30 fps = 0.433 s); selected by gc_statetag_action_build ->
# gc_anim_construct (data/scripts/dmscript.global:13, :926;
# data/scripts/lib/unit.script:10877) and bound in
# data/animations/acl/peasant.acl:2245-2252. No range is hard-coded here:
# read_aaf derives first/last/donor citation from each unit's own AAF (:118-137,
# :210-218), so sids without "construct" are skipped (:208-209).
DEFAULT_ACTIONS = ("idle", "idle0", "walk", "walk0", "death",
                   "attack0", "attack1", "construct")
SCHEMA = "c3_skin_v1"


# ---------------------------------------------------------------------------
# donor layout readers (verbatim shape from bake_sprites.py / convert_models.py)
# ---------------------------------------------------------------------------

def read_oss(path: str) -> dict:
    """bake_sprites.py:91-103 / convert_models.py:48-71, read-only."""
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
    return dict(k=k, fps=fps, bones=b, v=v, fc=fc, t=t,
                verts=verts, weights=weights, anim=anim, bytes=off)


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
    dest = out_dir / (sid + ".json")
    with open(dest, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, separators=(",", ":"), ensure_ascii=False)

    # Independent donor-grounding evidence: flat-root skinned verts at the
    # first exported frame (computed here, NOT stored in the asset).
    probe = skin_at(mesh, frames[0]) if frames else []
    checksum = round(sum(p[0] + p[1] + p[2] for p in probe), 6) if probe else 0.0
    return {
        "sid": sid, "skipped": False,
        "file": dest.name, "bytes": dest.stat().st_size,
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
    args = ap.parse_args()

    game = Path(args.game)
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    actions = tuple(a.strip() for a in args.actions.split(",") if a.strip())
    if args.frames_per_action < 1:
        raise SystemExit("--frames-per-action must be >= 1")

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
