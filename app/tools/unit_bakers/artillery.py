#!/usr/bin/env python3
"""T6-U05 -- Artillery family mini-baker (piece-by-piece verification).

Family keys (verbatim from T6_WAVE_PLAN.md LANE UNITS):
    cannon, howitzer, mortar, multicannon

Donor base mapping is IDENTITY (key == donor base), matching the read-only
table in app/tools/bake_sprites.py.

WHY THIS IS NOT JUST A WRAPPER OVER bake_sprites.bake_unit
----------------------------------------------------------
The monolithic reference baker reads only ``data/actors/units/<base>.oss``.
The four artillery actors are COMPOSITE (observed read-only from
``data/actors/units/<base>.actor``):

    cannon.actor : body cannon.oss + cannon_wheel_left.oss + cannon_wheel_right.oss
    howitzer.actor : body + 2 wheels
    mortar.actor : body + 2 wheels
    multicannon.actor : body + 2 wheels
    <base>_death.actor : separate <base>_death.oss + <base>_death.aaf

There is NO attach/<base>_<tool>.oss prop and NO <base>_tools.actor manifest
for this family (Bug 5 of UNIT_BAKING_FIX.md is N/A: tool == None everywhere);
the wheels are the family's equivalent of an attached prop, and death is a
separate mesh with its OWN AAF rather than a named clip in the body AAF.
Baking only the body would render wheel-less guns with no death animation --
exactly the kind of fidelity gap this mini-baker exists to close.

All rendering/pure primitives are reused from the READ-ONLY reference
``app/tools/bake_sprites.py`` (attribution below); that file is NEVER edited.

THE FIVE BUG FIXES (UNIT_BAKING_FIX.md §2), enforced here
---------------------------------------------------------
1. transposed quaternion matrices (``qmat`` copied from the reference);
2. bone-0 de-travel to ONE global idle HOME; per-clip reference only for
   death (here: the death mesh's own first frame);
3. ONE shared stand group + ONE death camera group, centre XZ=(0,0), Z =
   group union mid-height, one projected ground anchor per group;
4. projected-long-side ortho over ALL 8 azimuths (elevation 32 deg), with
   the wheels included in the stand union -- essential for long barrels;
5. donor prop compositing: the wheels are baked into the body mesh for all
   alive actions; the separate death mesh is baked for the death action.

MODES
-----
Pure Python (no Blender needed):
    python app/tools/unit_bakers/artillery.py --game ... --truth-only
    python app/tools/unit_bakers/artillery.py --game ... --verify
Under Blender (bake -- needs an explicit slot grant from T6-UNITS):
    blender --background --factory-startup \
      --python app/tools/unit_bakers/artillery.py -- \
      --game "C:\\Games\\Cossacks 3" \
      --out app/shots/unit_pieces/artillery --only cannon \
      --size 160 --engine workbench

Staging outputs (PNG sheets + staging_manifest.json + donor_truth.json +
crops/) go ONLY to --out. Scratch goes to the SYSTEM TEMP dir. No raw donor
format is ever copied into the repo.
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

KEYS = {
    "cannon": "cannon",
    "howitzer": "howitzer",
    "mortar": "mortar",
    "multicannon": "multicannon",
}

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_OUT = str(APP / "shots" / "unit_pieces" / "artillery")
DEFAULT_IDX = str(APP / "assets" / "models" / "anim" / "index.json")

# Alive-mesh AAF clips in baker priority order. (action, candidate names,
# sampled-frame cap, loop). Sample caps match the reference baker exactly.
ALIVE_PLAN = (
    ("idle", ("idle", "idle0"), 1, True),
    ("walk", ("walk",), 12, True),
    ("attack", ("attack1", "attack0", "attack2", "attack"), 12, False),
    ("next", ("next",), 12, False),       # multicannon barrel cycling only
)
# Death comes from the SEPARATE <base>_death.oss / .aaf.
DEATH_PLAN = (("death", ("death", "death0", "death1"), 8, False),)

# The reference baker computes the ground anchor BEFORE setting the square
# render resolution, so Blender's ortho view_frame still uses the factory
# 1920x1080 aspect (16:9). Verified: (ay-0.5)*ortho/centre_z == 1.507 for
# every live unit = cos(32deg) * 16/9 = 0.848 * 1.778. Kept for parity.
ANCHOR_ASPECT = 16.0 / 9.0


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
    ap.add_argument("--crops", action="store_true",
                    help="with --verify: write visual inspection crops into <out>/crops/")
    ap.add_argument("--rebuild-manifest", action="store_true",
                    help="rebuild the COMPLETE staging manifest from donor truth + "
                         "existing PNG sheets (pure Python, no Blender). Useful "
                         "after sequential per-key bakes.")
    return ap.parse_args(rest)


# ---------------------------------------------------------------------------
# Pure-Python donor readers -- copied with attribution from the READ-ONLY
# app/tools/bake_sprites.py (read_oss / read_aaf / qmat / skin / sample).
# ---------------------------------------------------------------------------
def read_oss(path):
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


def qmat(x, y, z, w):
    # BUG 1 FIX -- donor rotations apply transposed (row-vector convention).
    # Verified bone-by-bone in UNIT_BAKING_FIX.md §2. Attributed verbatim.
    M = ((1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)),
         (2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)),
         (2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)))
    return ((M[0][0], M[1][0], M[2][0]),
            (M[0][1], M[1][1], M[2][1]),
            (M[0][2], M[1][2], M[2][2]))


def skin(m, fr):
    """Skin one frame of any .oss mesh with transposed quaternions."""
    mats = [qmat(*m["anim"][bi][fr][3:]) for bi in range(len(m["anim"]))]
    poss = [m["anim"][bi][fr][:3] for bi in range(len(m["anim"]))]
    out = []
    for i, (x, y, z) in enumerate(m["verts"]):
        sx = sy = sz = 0.0
        for bi, w in m["weights"][i]:
            M = mats[bi]
            px, py, pz = poss[bi]
            sx += w * (M[0][0] * x + M[0][1] * y + M[0][2] * z + px)
            sy += w * (M[1][0] * x + M[1][1] * y + M[1][2] * z + py)
            sz += w * (M[2][0] * x + M[2][1] * y + M[2][2] * z + pz)
        out.append((sx, sy, sz))
    return out


def sample(rng, n):
    """Exact copy of bake_sprites.sample -- donor order, keep short clips."""
    a, b = rng
    if b <= a:
        return [a]
    total = b - a + 1
    if total <= n:
        return list(range(a, b + 1))
    return [a + round((b - a) * i / (n - 1)) for i in range(n)] if n > 1 else [a]


# ---------------------------------------------------------------------------
# Donor truth (observed, read-only)
# ---------------------------------------------------------------------------
def _mesh_paths(game, base):
    u = os.path.join(game, "data", "actors", "units")
    return {
        "body": os.path.join(u, base + ".oss"),
        "wheel_left": os.path.join(u, base + "_wheel_left.oss"),
        "wheel_right": os.path.join(u, base + "_wheel_right.oss"),
        "death": os.path.join(u, base + "_death.oss"),
    }


def donor_truth(game):
    """Return {key: {...}} with observed .oss/.aaf/.actor facts + expected plan."""
    out = {}
    for key, base in KEYS.items():
        paths = _mesh_paths(game, base)
        body = read_oss_header(paths["body"])
        alive_aaf = read_aaf(os.path.join(game, "data", "animations", "aaf", base + ".aaf"))
        death_aaf = read_aaf(os.path.join(game, "data", "animations", "aaf", base + "_death.aaf"))
        wheels = {}
        for name in ("wheel_left", "wheel_right", "death"):
            wheels[name] = read_oss_header(paths[name]) if os.path.exists(paths[name]) else None
        actor = os.path.join(game, "data", "actors", "units", base + ".actor")
        actor_lines = [ln.strip() for ln in open(actor, encoding="ascii", errors="replace")
                       if "LoadFromFile" in ln or "ShaderID" in ln] if os.path.exists(actor) else []
        propdir = os.path.join(game, "data", "actors", "units", "attach")
        props = [f for f in os.listdir(propdir)
                 if f.startswith(base + "_") and f.endswith(".oss")] if os.path.isdir(propdir) else []

        expected = {}
        for action, names, n, loop in ALIVE_PLAN:
            rng = next((alive_aaf[x] for x in names if x in alive_aaf), None)
            if not rng:
                continue
            frs = sample(rng, n)
            expected[action] = {
                "mesh": "body+wheels", "aaf_source": base + ".aaf",
                "aaf_range": list(rng), "sampled_frames": len(frs),
                "frames_list": frs,
                "duration": round((rng[1] - rng[0] + 1) / max(1, body["fps"]), 3),
                "loop": loop, "tool": None,
            }
        for action, names, n, loop in DEATH_PLAN:
            rng = next((death_aaf[x] for x in names if x in death_aaf), None)
            if not rng:
                continue
            frs = sample(rng, n)
            expected[action] = {
                "mesh": "death", "aaf_source": base + "_death.aaf",
                "aaf_range": list(rng), "sampled_frames": len(frs),
                "frames_list": frs,
                "duration": round((rng[1] - rng[0] + 1) / max(1, (wheels["death"] or body)["fps"]), 3),
                "loop": loop, "tool": None,
            }
        out[key] = {
            "base": base,
            "oss": body,
            "mesh_headers": wheels,
            "aaf_alive": alive_aaf,
            "aaf_death": death_aaf,
            "actor_file": actor_lines,
            "attach_props": props,
            "tools_manifest": os.path.exists(os.path.join(propdir, base + "_tools.actor")),
            "texture": base + ".dds",
            "expected": expected,
        }
    return out


def print_truth(truth):
    for key, d in truth.items():
        h = d["oss"]
        w = d["mesh_headers"]
        print("%-12s body k=%4d fps=%2d bones=%d verts=%4d faces=%4d | "
              "wheel_L=%s wheel_R=%s death=%s | attach=%d manifest=%s" % (
                  key, h["frames"], h["fps"], h["bones"], h["verts"], h["faces"],
                  (w["wheel_left"] or {}).get("verts"), (w["wheel_right"] or {}).get("verts"),
                  (w["death"] or {}).get("verts"), len(d["attach_props"]),
                  d["tools_manifest"]))
        for a, e in d["expected"].items():
            print("    %-7s mesh=%-11s aaf=%-18s range=%-10s sample=%2d dur=%-7s loop=%-5s tool=%s" % (
                a, e["mesh"], e["aaf_source"], str(e["aaf_range"]), e["sampled_frames"],
                e["duration"], e["loop"], e["tool"]))
        unused = [x for x in d["aaf_alive"] if x not in
                  {n for a, names, _n, _l in ALIVE_PLAN for n in names}]
        if unused:
            print("    unused_alive_aaf: " + ", ".join(sorted(unused)))


# ---------------------------------------------------------------------------
# Skinning + framing (pure Python; mirrors bake_sprites.py exactly)
# ---------------------------------------------------------------------------
def skin_frames(m, frs, root_ref=None, detravel_src=None, root=0):
    """Skin frames; translate by bone-0 de-travel from ``detravel_src``.

    ``root_ref`` is the global standing HOME for alive clips; for death the
    caller passes the death mesh's own first-frame root (per-clip ref).
    ``detravel_src`` is the mesh whose bone 0 defines the motion (the body
    for wheels, the death mesh for itself).
    """
    src = detravel_src if detravel_src is not None else m
    out = {}
    for fr in frs:
        s = skin(m, fr)
        rx, ry = (src["anim"][root][fr][0] - root_ref[0],
                  src["anim"][root][fr][1] - root_ref[1])
        out[fr] = [(x - rx, y - ry, z) for x, y, z in s]
    return out


def projected_ortho(seqs, center):
    """BUG 4 FIX -- projected-long-side ortho over all 8 azimuths, x1.12."""
    el = math.radians(32.0)
    ce, se = math.cos(el), math.sin(el)
    worst = 1e-6
    for d in range(8):
        az = math.radians(d * 45.0)
        ca, sa = math.cos(az), math.sin(az)
        rx, ry, rz = -sa, ca, 0.0
        bx, by, bz = ca * ce, sa * ce, se
        ux, uy, uz = by * rz - bz * ry, bz * rx - bx * rz, bx * ry - by * rx
        x0 = y0 = 1e9
        x1 = y1 = -1e9
        for sq in seqs:
            for x, y, z in sq:
                dx, dy, dz = x - center[0], y - center[1], z - center[2]
                px = dx * rx + dy * ry + dz * rz
                py = dx * ux + dy * uy + dz * uz
                if px < x0: x0 = px
                if px > x1: x1 = px
                if py < y0: y0 = py
                if py > y1: y1 = py
        worst = max(worst, 2.0 * max(abs(x0), abs(x1), abs(y0), abs(y1)))
    return worst * 1.12


def make_groups(skinned, group_members):
    """One centre/ortho per group. Centre XZ=(0,0), Z=union mid-height."""
    groups = {}
    for g, seqs in group_members.items():
        lo = [1e9] * 3
        hi = [-1e9] * 3
        for sq in seqs:
            for x, y, z in sq:
                for i, v in enumerate((x, y, z)):
                    if v < lo[i]: lo[i] = v
                    if v > hi[i]: hi[i] = v
        center = (0.0, 0.0, (lo[2] + hi[2]) * 0.5)
        groups[g] = {"center": center, "ortho": projected_ortho(seqs, center)}
    return groups


def predict_anchor(group):
    """Pure-Python prediction of ground_anchor_ay (see ANCHOR_ASPECT note)."""
    cz = group["center"][2]
    return (0.5, round(0.5 + cz * math.cos(math.radians(32.0)) * ANCHOR_ASPECT
                       / group["ortho"], 4))


def build_framing(game, key, truth):
    """Pure-Python skin+frame plan (no bpy). Returns per-key framing dict."""
    base = KEYS[key]
    paths = _mesh_paths(game, base)
    body = read_oss(paths["body"])
    wl = read_oss(paths["wheel_left"])
    wr = read_oss(paths["wheel_right"])
    death = read_oss(paths["death"])
    exp = truth[key]["expected"]

    # BUG 2 FIX: one global idle HOME (first idle frame, else first plan frame).
    idle_ref_fr = exp.get("idle", {}).get("frames_list", [1])[0]
    home = (body["anim"][0][idle_ref_fr][0], body["anim"][0][idle_ref_fr][1])

    skinned = {}
    members = {"stand": [], "death": []}
    for action, e in exp.items():
        frs = e["frames_list"]
        root = 0
        if e["mesh"] == "death":
            ref = (death["anim"][root][frs[0]][0], death["anim"][root][frs[0]][1])
            seqs = skin_frames(death, frs, ref, root=root)
        else:
            ref = home
            seqs = skin_frames(body, frs, ref, root=root)
            lw = skin_frames(wl, frs, ref, detravel_src=body, root=0)
            rw = skin_frames(wr, frs, ref, detravel_src=body, root=0)
        for fr in frs:
            seq = seqs[fr]
            if e["mesh"] != "death":
                seq = seq + lw[fr] + rw[fr]
            skinned[(action, fr)] = seq
            members["death" if e["mesh"] == "death" else "stand"].append(seq)
    groups = make_groups(members, members)
    for g in groups:
        groups[g]["anchor_predicted"] = predict_anchor(groups[g])
    groups["home"] = list(home)
    groups["body_root_frames"] = body["k"]
    return groups


# ---------------------------------------------------------------------------
# Bake mode (Blender only) -- lazy import of the read-only reference baker.
# ---------------------------------------------------------------------------
def import_reference():
    if str(TOOLS) not in sys.path:
        sys.path.insert(0, str(TOOLS))
    import bake_sprites as ref  # attribution: app/tools/bake_sprites.py
    return ref


def combine_meshes(*meshes):
    """Concatenate .oss dicts with rebased indices (one shared texture)."""
    out = {"verts": [], "faces": [], "uvs": [], "uvf": []}
    nv = nu = 0
    for m in meshes:
        out["verts"].extend(m["verts"])
        out["faces"].extend((a + nv, b + nv, c + nv) for a, b, c in m["faces"])
        out["uvs"].extend(m["uvs"])
        out["uvf"].extend((a + nu, b + nu, c + nu) for a, b, c in m["uvf"])
        nv += len(m["verts"])
        nu += len(m["uvs"])
    return out


def measure_sheet(path, cell):
    """Cell-local alpha>8 union bbox + metrics, sheet_metrics-style."""
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
    ref._ENGINE = a.engine
    ref._SAMPLES = a.samples
    from PIL import Image
    import tempfile

    keys = [k for k in KEYS if not a.only or k in set(a.only.split(","))]
    if not keys:
        print("no keys selected")
        return 2
    out = str(Path(a.out).expanduser().resolve())
    game = str(Path(a.game).expanduser().resolve())
    os.makedirs(out, exist_ok=True)
    tmp = os.path.join(tempfile.gettempdir(), "cossacks_bake", os.path.basename(out))
    os.makedirs(tmp, exist_ok=True)

    truth = donor_truth(game)
    with open(os.path.join(out, "donor_truth.json"), "w", encoding="utf-8") as f:
        json.dump(truth, f, indent=1)

    # Merge with an existing manifest: sequential per-key bakes must not
    # erase the keys baked earlier in the same family session.
    mf_path = os.path.join(out, "staging_manifest.json")
    if os.path.exists(mf_path):
        manifest = json.load(open(mf_path, encoding="utf-8"))
        manifest.setdefault("keys", {})
    else:
        manifest = {"cell": a.size, "engine": a.engine, "keys": {}, "bug_fixes": {
            "1_transposed_quaternions": True,
            "2_bone0_detravel_global_idle_home_perclip_death": True,
            "3_shared_stand_death_group_anchor": True,
            "4_projected_longside_ortho_8_az": True,
            "5_wheels_composited_death_mesh_baked": True,
        }}
    manifest["cell"] = a.size
    manifest["engine"] = a.engine
    for key in keys:
        base = KEYS[key]
        paths = _mesh_paths(game, base)
        body = read_oss(paths["body"])
        wl = read_oss(paths["wheel_left"])
        wr = read_oss(paths["wheel_right"])
        death = read_oss(paths["death"])
        framing = build_framing(game, key, truth)
        print("BAKE", key, "->", base, "engine", a.engine, flush=True)

        png = ref.dds_to_png(ref.tex_png(game, "unit", base),
                             os.path.join(tmp, base + ".png"), True)
        ref.setup_scene()
        mat = ref.make_mat(png)

        # One ground anchor per group, computed with the reference camera
        # helper (same convention/order as the live sheets -- see
        # ANCHOR_ASPECT note).
        anchors = {}
        for g, gr in framing.items():
            if g == "home" or g == "body_root_frames":
                continue
            center = ref.Vector(gr["center"])
            cam = ref.camera(center, 0.0, gr["ortho"])
            anchors[g] = ref.ground_anchor_ay(cam, a.size)
            ref.bpy.data.objects.remove(cam, do_unlink=True)

        entry = {"base": base, "cell": a.size, "actions": {},
                 "groups": {g: {"center": gr["center"], "ortho": round(gr["ortho"], 3),
                                "anchor": anchors.get(g)}
                            for g, gr in framing.items()
                            if g not in ("home", "body_root_frames")}}
        for action, e in truth[key]["expected"].items():
            gr = framing["death" if e["mesh"] == "death" else "stand"]
            center = ref.Vector(gr["center"])
            ortho = gr["ortho"]
            ax, ay = anchors["death" if e["mesh"] == "death" else "stand"]
            frs = e["frames_list"]

            if e["mesh"] == "death":
                mesh_src = death
                mesh_verts = len(death["verts"])
            else:
                mesh_src = combine_meshes(body, wl, wr)
                mesh_verts = len(body["verts"]) + len(wl["verts"]) + len(wr["verts"])
            obj = ref.build_mesh(mesh_src, mat)
            me = obj.data

            # Skin every frame ONCE (same de-travel as build_framing).
            idle_fr = truth[key]["expected"].get("idle", {}).get("frames_list", [1])[0]
            home = (body["anim"][0][idle_fr][0], body["anim"][0][idle_fr][1])
            if e["mesh"] == "death":
                ref0 = (death["anim"][0][frs[0]][0], death["anim"][0][frs[0]][1])
                frame_seqs = skin_frames(death, frs, ref0, root=0)
            else:
                bs_seq = skin_frames(body, frs, home, root=0)
                lw_seq = skin_frames(wl, frs, home, detravel_src=body, root=0)
                rw_seq = skin_frames(wr, frs, home, detravel_src=body, root=0)
                frame_seqs = {fr: bs_seq[fr] + lw_seq[fr] + rw_seq[fr] for fr in frs}

            sheet = Image.new("RGBA", (a.size * 8, a.size * len(frs)), (0, 0, 0, 0))
            for ri, fr in enumerate(frs):
                verts = frame_seqs[fr]
                me.vertices.foreach_set("co", [c for v in verts for c in v])
                me.update()
                for d in range(8):
                    cam = ref.camera(center, d * 45.0, ortho)
                    cell_path = os.path.join(tmp, "cell.png")
                    ref.render_cell(cell_path, a.size)
                    img = Image.open(cell_path).convert("RGBA")
                    sheet.paste(img, (d * a.size, ri * a.size), img)
                    ref.bpy.data.objects.remove(cam, do_unlink=True)
            sheet_path = os.path.join(out, "%s_%s.png" % (key, action))
            sheet.save(sheet_path)
            met = measure_sheet(sheet_path, a.size)
            ad = {
                "frames": len(frs), "duration": e["duration"], "loop": e["loop"],
                "ortho": round(ortho, 3),
                "center": [round(v, 3) for v in gr["center"]],
                "ax": ax, "ay": ay, "tool": None,
                "mesh": e["mesh"], "mesh_verts": mesh_verts,
                "aaf_source": e["aaf_source"], "aaf_range": e["aaf_range"],
            }
            if met:
                ad.update(met)
            entry["actions"][action] = ad
            print("  ", action, "frames", len(frs), "dur", e["duration"],
                  "verts", mesh_verts, "clip", ad.get("clip"), flush=True)
            ref.bpy.data.objects.remove(obj, do_unlink=True)
        manifest["keys"][key] = entry
        print("UNIT", key, "actions", ",".join(entry["actions"]), flush=True)

    with open(os.path.join(out, "staging_manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1)
    print("BAKE COMPLETE", ",".join(keys), flush=True)
    print("BAKE DONE -- slot free", flush=True)
    return 0


# ---------------------------------------------------------------------------
# Verify mode (pure Python + Pillow) -- staging vs donor truth + live index.
# ---------------------------------------------------------------------------
def _same(a, b, tol=None):
    if tol is not None and isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(float(a) - float(b)) <= tol
    return a == b


def make_crops(a, key, e, out):
    """Visual-inspection crops: one 8-dir strip per action + 2x close-ups."""
    from PIL import Image
    cropdir = os.path.join(out, "crops")
    os.makedirs(cropdir, exist_ok=True)
    cell = int(e["cell"])
    for action, ad in e["actions"].items():
        p = os.path.join(out, "%s_%s.png" % (key, action))
        if not os.path.exists(p):
            continue
        im = Image.open(p).convert("RGBA")
        rows = im.height // cell
        ri = rows // 2  # mid-frame strip
        strip = Image.new("RGBA", (cell * 8, cell), (0, 0, 0, 0))
        for d in range(8):
            strip.paste(im.crop((d * cell, ri * cell, (d + 1) * cell, (ri + 1) * cell)),
                        (d * cell, 0))
        strip.save(os.path.join(cropdir, "%s_%s_strip.png" % (key, action)))
        for d in (0, 2, 4, 6):
            tile = im.crop((d * cell, ri * cell, (d + 1) * cell, (ri + 1) * cell))
            tile.resize((cell * 2, cell * 2), Image.NEAREST).save(
                os.path.join(cropdir, "%s_%s_d%d.png" % (key, action, d)))


def rebuild_manifest(a):
    """Merge all baked keys into one complete manifest, no Blender needed.

    Every field is re-derived deterministically: centres/orthos/anchors from
    build_framing (the predicted anchor equals the bpy-computed one -- checked
    on all four keys), durations/frames from the donor truth, and bbox/metrics
    measured from the actual PNG cells.
    """
    out = str(Path(a.out).expanduser().resolve())
    game = str(Path(a.game).expanduser().resolve())
    truth = donor_truth(game)
    manifest = {"cell": a.size, "engine": a.engine, "keys": {}, "bug_fixes": {
        "1_transposed_quaternions": True,
        "2_bone0_detravel_global_idle_home_perclip_death": True,
        "3_shared_stand_death_group_anchor": True,
        "4_projected_longside_ortho_8_az": True,
        "5_wheels_composited_death_mesh_baked": True,
    }}
    for key in KEYS:
        exp = truth[key]["expected"]
        paths = [os.path.join(out, "%s_%s.png" % (key, action)) for action in exp]
        if not all(os.path.exists(p) for p in paths):
            print("SKIP", key, "sheets incomplete")
            continue
        framing = build_framing(game, key, truth)
        entry = {"base": KEYS[key], "cell": a.size, "actions": {},
                 "groups": {g: {"center": gr["center"], "ortho": round(gr["ortho"], 3),
                                "anchor": gr["anchor_predicted"]}
                            for g, gr in framing.items()
                            if g not in ("home", "body_root_frames")}}
        h = truth[key]
        for action, e in exp.items():
            gr = framing["death" if e["mesh"] == "death" else "stand"]
            ax, ay = gr["anchor_predicted"]
            if e["mesh"] == "death":
                mesh_verts = h["mesh_headers"]["death"]["verts"]
            else:
                mesh_verts = (h["oss"]["verts"] + h["mesh_headers"]["wheel_left"]["verts"]
                              + h["mesh_headers"]["wheel_right"]["verts"])
            met = measure_sheet(os.path.join(out, "%s_%s.png" % (key, action)), a.size)
            ad = {"frames": e["sampled_frames"], "duration": e["duration"],
                  "loop": e["loop"], "ortho": round(gr["ortho"], 3),
                  "center": [round(v, 3) for v in gr["center"]],
                  "ax": ax, "ay": ay, "tool": None,
                  "mesh": e["mesh"], "mesh_verts": mesh_verts,
                  "aaf_source": e["aaf_source"], "aaf_range": e["aaf_range"]}
            if met:
                ad.update(met)
            entry["actions"][action] = ad
        manifest["keys"][key] = entry
        print("REBUILT", key, ",".join(entry["actions"]))
    path = os.path.join(out, "staging_manifest.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1)
    print("MANIFEST", len(manifest["keys"]), "keys ->", path)
    return 0


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
    for key, e in mf.get("keys", mf).items():
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
                ok &= ad.get("aaf_range") == exp["aaf_range"]
            print("  TRUTH %-7s %s frames=%s dur=%s aaf=%s mesh=%s -> %s" % (
                action, "OK" if ok else "FAIL", ad["frames"], ad["duration"],
                ad.get("aaf_range"), ad.get("mesh"), "PASS" if ok else "FAIL"))
            allpass &= ok
        # 2. live index cross-check (death is expected to be NEW)
        if key in live:
            la = live[key]["actions"]
            for action, ad in acts.items():
                if action not in la:
                    print("  LIVE %-7s absent (new action; expected for death)" % action)
                    continue
                lv = la[action]
                diffs = []
                for f in ("frames", "loop", "ortho", "center", "ax", "ay", "tool"):
                    if not _same(ad.get(f), lv.get(f), tol=1e-3 if f == "ortho" else None):
                        diffs.append("%s %s!=%s" % (f, ad.get(f), lv.get(f)))
                if not _same(ad["duration"], lv["duration"], tol=1e-3):
                    diffs.append("duration %s!=%s" % (ad["duration"], lv["duration"]))
                print("  LIVE %-7s %s" % (action, "MATCH" if not diffs else "DIFF " + "; ".join(diffs)))
        else:
            print("  LIVE key absent (no cross-check)")
        # 3. GROUP_OK: one stand group + one death group; shared centre/anchor
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
        # 4. wheels composited / death mesh used (mesh_verts metadata)
        for action, ad in acts.items():
            exp = truth.get(key, {}).get("expected", {}).get(action, {})
            want = None
            if exp.get("mesh") == "death":
                want = truth[key]["mesh_headers"]["death"]["verts"]
            elif exp.get("mesh") == "body+wheels":
                h = truth[key]
                want = (h["oss"]["verts"] + h["mesh_headers"]["wheel_left"]["verts"]
                        + h["mesh_headers"]["wheel_right"]["verts"])
            vok = want is None or ad.get("mesh_verts") == want
            print("  MESH %-7s verts=%s expect=%s -> %s" % (
                action, ad.get("mesh_verts"), want, "PASS" if vok else "FAIL"))
            allpass &= vok
        # 5. CLIP + distinct dirs per action sheet (alpha>8)
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
            sok = (clips == 0 and distinct == rows)
            print("  SHEET %-7s %dx%d edge-touch=%d distinct-rows=%d/%d -> %s" % (
                action, cols, rows, clips, distinct, rows, "PASS" if sok else "FAIL"))
            allpass &= sok
            ax = ad.get("ax")
            aok = ax is not None and abs(ax - 0.5) <= 0.02
            print("     anchor ax=%s ay=%s fig_h=%s foot=%s cx=%s clip=%s -> %s" % (
                ax, ad.get("ay"), ad.get("fig_h"), ad.get("foot"), ad.get("cx"),
                ad.get("clip"), "PASS" if aok else "FAIL"))
            allpass &= aok
            if a.crops:
                make_crops(a, key, e, out)
    print("\nVERDICT", "ALL PASS" if allpass else "FAIL (see above)")
    return 0 if allpass else 1


def main():
    a = parse_args()
    a.game = str(Path(a.game).expanduser().resolve())
    a.out = str(Path(a.out).expanduser().resolve())
    if a.truth_only:
        os.makedirs(a.out, exist_ok=True)
        truth = donor_truth(a.game)
        with open(os.path.join(a.out, "donor_truth.json"), "w", encoding="utf-8") as f:
            json.dump(truth, f, indent=1)
        print_truth(truth)
        # Pure-Python framing prediction adds no bpy dependency.
        for key in truth:
            g = build_framing(a.game, key, truth)
            st = g["stand"]
            de = g.get("death")
            print("  FRAME %-12s stand ortho=%.3f centre=%s anchor=%s | death ortho=%.3f anchor=%s" % (
                key, st["ortho"], tuple(round(x, 3) for x in st["center"]),
                st["anchor_predicted"], de["ortho"] if de else 0,
                de["anchor_predicted"] if de else None))
        print("\nTRUTH DUMP WRITTEN", os.path.join(a.out, "donor_truth.json"))
        return 0
    if a.rebuild_manifest:
        return rebuild_manifest(a)
    if a.verify:
        return verify(a)
    return bake(a)


if __name__ == "__main__":
    sys.exit(main())
