#!/usr/bin/env python3
"""T6-U07 -- NAVAL family mini-baker (continue P-10).

Donor truth target: ``yacht`` (the only live naval key). Additional readable
naval meshes from docs/NAVAL_EVIDENCE.md are supported as NEW scoped keys, each with
its OWN donor truth -- yacht's sheets are never substituted for another vessel.

DESIGN -- thin wrapper, reference NEVER edited
----------------------------------------------
Pure-Python modes (--truth-only / --verify) use the readers below, which mirror
the proven ``app/tools/bake_sprites.py`` primitives. Bake mode (under Blender)
lazily imports that reference file and reuses its ``skin``/``qmat`` (transposed
quaternions), ``build_mesh``, ``camera``, ``ground_anchor_ay``, ``render_cell``,
``setup_scene``/``make_mat``, ``dds_to_png``/``tex_png`` and ``read_osm_first``.
The reference is READ-ONLY and is never written to.

THE FIVE APPLICABLE BUG FIXES (UNIT_BAKING_FIX.md)
-------------------------------------------------
1. Transposed quaternions -- ``ref.qmat`` returns the row-vector/conjugate
   rotation; the pure-Python ``qmat`` below is byte-equivalent. Donor records
   are (px,py,pz,rx,ry,rz,rw) with |q| == 1.
2. Bone-0 de-travel -- yacht.oss bone 0 actually drifts (f0 (0,0,0),
   f310 (0.006,-0.149,-0.115)); every standing frame is re-based against the
   first sampled walk frame so the ship stays centred in its cell.
3. Shared camera groups -- one camera per group (the animated crew "stand"
   group and the static hull group), shared across all dirs/frames/actions of
   that group; no per-action centre/ortho jumps.
4. Projected long-side ortho -- ``projected_ortho`` projects every skinned
   vertex of every frame through all 8 azimuths (elevation 32 deg) and fits
   ``2*max|x0|,|x1|,|y0|,|y1| * 1.12``, never axis-aligned bounds*1.4.
5. Build-stage truth -- DONOR HAS NO NAVAL HAND PROPS. Sails/flags/dock hull
   stages are SEPARATE .osm/.oss meshes with their own .actor + .aaf manifests
   (``yacht_sail.actor`` uses aarMorph over a 151-frame .osm;
   ``yacht_flag1/2.actor`` use skinned .oss). They are recorded in
   donor_truth.json as build stages and are NEVER composited into the crew
   sheet the way peasant tools are. Optional ``--build-stages`` writes them as
   separate scoped sheets with ``stage: true, composite: false``.

OBSERVED DONOR TRUTH (read-only probe, see report for evidence)
---------------------------------------------------------------
* yacht.oss : k=311 fps=30 20 bones 584 verts 947 faces 793 UVs, 217344 B,
  exact size closure 24 + 36080 + 7080 + 174160 = 217344.
* yacht.aaf : exactly idle/walk/death/attack0, ALL 1..280 inclusive (=> 9.333 s
  at 30 fps). The 584-vert .oss is the CREW figure, not the hull.
* yacht.osm : 9364 verts / 7731 faces / 11490 UVs; bbox
  x -1.752..1.752, y -4.819..3.208, z -0.376..6.803. read_osm_first offsets
  12/13/14 (DC_FORMATS.md 2.2 verdict: the 10/11/12 "bug" is refuted).
* attach/yacht_* : dock stages yachta/yacht1a..4a/yacht_death1a/2a.osm,
  aarMorph sail (yacht_sail.osm, nf=151, aaf idle 1..60 / idle_to_walk 61..90 /
  walk 91..120 / walk_to_idle 121..149), two skinned flags (yacht_flag.aaf
  idle 1..149). units/yacht1..4.osm + yacht_death1/2.osm are hull direction /
  wreck stages. Material: only units/yacht.dds exists (no separate sail/flag
  texture) -- stage textures are inferred, never asserted as observed.

MODES
-----
Pure Python (no Blender):
    python app/tools/unit_bakers/naval.py --truth-only
    python app/tools/unit_bakers/naval.py --verify
Under Blender (bake) -- ONLY after the parent grants a bake slot:
    blender --background --factory-startup \
      --python app/tools/unit_bakers/naval.py -- \
      --game "C:\\Games\\Cossacks 3" \
      --out app/shots/unit_pieces/naval --only yacht \
      --size 160 --engine workbench

STAGING RULE (absolute): --out is RUNTIME-GUARDED to be under
app/shots/unit_pieces/naval. All PNG sheets, donor_truth.json and
staging_manifest.json go there and ONLY there. Scratch renders / converted
textures go to the SYSTEM TEMP dir. No raw donor format is copied into res://.
"""
import argparse
import datetime
import json
import math
import os
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parent
APP = TOOLS.parent

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_OUT = APP / "shots" / "unit_pieces" / "naval"
DEFAULT_IDX = APP / "assets" / "models" / "anim" / "naval" / "index.json"
STAGING_ROOT = (APP / "shots" / "unit_pieces" / "naval").resolve()

# Key -> donor base. yacht is the live key; the rest are NEW scoped keys with
# their own truth (never share yacht sheets). Ships with no .oss can still get
# a static hull sheet from their .osm.
KEYS = {
    "yacht": "yacht",
    "yachttur": "yachttur",
    "fishboat": "fishboat",
    "frigate": "frigate",
    "galley": "galley",
    "battleship": "battleship",  # no animated .oss in donor
    "xebec": "xebec",            # no animated .oss in donor
}

# Deliberately EMPTY: naval sails/flags/dock stages are BUILD STAGES with their
# own manifests, not in-place hand props. Never emulate the peasant tool
# composite for them (UNIT_BAKING_FIX.md 7 / ticket "do NOT fake ... for sails").
NAVAL_ATTACH = {}

# Donor clips actually present in yacht.aaf. All four span 1..280, so the
# baker resolves "walk" (the live key's animated action) and records the rest
# as observed-but-identical ranges instead of inventing distinct poses.
CREW_ACTION = "walk"
CREW_SAMPLES = 12
HULL_DURATION = 1.0  # static portrait: finite, never played as a loop


def parse_args():
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME)
    ap.add_argument("--out", default=str(DEFAULT_OUT),
                    help="staging dir; RUNTIME-GUARDED under "
                         "app/shots/unit_pieces/naval")
    ap.add_argument("--only", default="yacht",
                    help="comma-separated keys (default: yacht)")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="workbench",
                    choices=["workbench", "cycles", "eevee"])
    ap.add_argument("--idx", default=str(DEFAULT_IDX),
                    help="live naval index.json to compare in --verify")
    ap.add_argument("--truth-only", action="store_true",
                    help="dump donor truth (pure Python, no Blender)")
    ap.add_argument("--verify", action="store_true",
                    help="verify staging sheets vs donor truth + live index "
                         "(pure Python + Pillow, no Blender)")
    ap.add_argument("--build-stages", action="store_true",
                    help="OPT-IN: also bake sail/flag/dock stage portraits as "
                         "separate scoped sheets (never composited)")
    ap.add_argument("--no-hull", action="store_true",
                    help="skip the static .osm hull sheet")
    return ap.parse_args(rest)


def guard_out(out):
    """Absolute staging rule: refuse anything outside app/shots/unit_pieces/naval."""
    p = Path(out).expanduser().resolve()
    if p != STAGING_ROOT and STAGING_ROOT not in p.parents:
        raise SystemExit(
            "REFUSED --out=%s : naval staging must be under %s "
            "(live anim/naval assets are READ-ONLY)" % (p, STAGING_ROOT))
    return p


# ---------------------------------------------------------------------------
# Pure-Python donor readers (mirror bake_sprites.py; no bpy needed).
# ---------------------------------------------------------------------------
def read_oss_header(path):
    with open(path, "rb") as f:
        k, fps, bones, verts, faces, uvs = struct.unpack("<6i", f.read(24))
    return dict(frames=k, fps=fps, bones=bones, verts=verts,
                faces=faces, uvs=uvs, bytes=os.path.getsize(path))


def read_oss_full(path):
    """Full OSS reader: byte-identical to bake_sprites.read_oss."""
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
        anim = [[struct.unpack("<7f", f.read(28)) for _ in range(k)]
                for _ in range(b)]
    return dict(fps=fps, verts=verts, faces=faces, uvs=uvs, uvf=uvf,
                weights=weights, anim=anim, k=k)


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
    """TRANSPOSED donor rotation (row-vector convention) -- bug fix 1."""
    M = ((1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)),
         (2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)),
         (2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)))
    return ((M[0][0], M[1][0], M[2][0]),
            (M[0][1], M[1][1], M[2][1]),
            (M[0][2], M[1][2], M[2][2]))


def skin(m, fr, ref=(0.0, 0.0)):
    """Skin one frame with transposed quats + bone-0 de-travel (fixes 1+2)."""
    mats = [qmat(*m["anim"][bi][fr][3:]) for bi in range(len(m["anim"]))]
    poss = [m["anim"][bi][fr][:3] for bi in range(len(m["anim"]))]
    rx = m["anim"][0][fr][0] - ref[0]
    ry = m["anim"][0][fr][1] - ref[1]
    out = []
    for i, (x, y, z) in enumerate(m["verts"]):
        sx = sy = sz = 0.0
        for bi, w in m["weights"][i]:
            M = mats[bi]
            px, py, pz = poss[bi]
            sx += w * (M[0][0] * x + M[0][1] * y + M[0][2] * z + px)
            sy += w * (M[1][0] * x + M[1][1] * y + M[1][2] * z + py)
            sz += w * (M[2][0] * x + M[2][1] * y + M[2][2] * z + pz)
        out.append((sx - rx, sy - ry, sz))
    return out


def sample(rng, n):
    """Exact copy of bake_sprites.sample -- donor order, keep short clips."""
    a, b = rng
    if b <= a:
        return [a]
    if b - a + 1 <= n:
        return list(range(a, b + 1))
    return [a + round((b - a) * i / (n - 1)) for i in range(n)] if n > 1 else [a]


def projected_ortho(frames, skinned, center):
    """Projected long-side ortho over all 8 azimuths (fix 4).

    Attribution: mirrors app/tools/bake_naval.py::projected_ortho and the
    group fitter in bake_sprites.bake_unit (K-01). Elevation 32 deg, +12% AA.
    """
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


def read_osm_first(path):
    """Static .osm first frame -- byte-identical to bake_sprites.read_osm_first.

    Offsets are header longs 12/13/14 (ou/ot/of). DC_FORMATS.md 3 refutes the
    alleged 10/11/12 defect; do NOT 'fix' the shared reader.
    """
    with open(path, "rb") as f:
        h = dict(zip(
            ["magic", "version", "sw", "sh", "fs", "ns", "nv", "nu", "nt",
             "ng", "nf", "os", "ou", "ot", "of", "og", "oe"],
            struct.unpack("<17i", f.read(68))))
        f.seek(h["ou"])
        uvs = [struct.unpack("<2f", f.read(8)) for _ in range(h["nu"])]
        f.seek(h["ot"])
        faces, uvf = [], []
        for _ in range(h["nt"]):
            i = struct.unpack("<6i", f.read(24))
            faces.append((i[0], i[2], i[1]))
            uvf.append((i[3], i[5], i[4]))
        f.seek(h["of"])
        f.read(16)
        verts = [struct.unpack("<3fI", f.read(16))[:3] for _ in range(h["nv"])]
    return dict(verts=verts, faces=faces, uvs=uvs, uvf=uvf, header=h)


def _bbox(pts):
    lo = [min(p[i] for p in pts) for i in range(3)]
    hi = [max(p[i] for p in pts) for i in range(3)]
    return lo, hi


def _actor_facts(path):
    """Lightweight .actor fact scrape (config dialect, no full parser)."""
    if not os.path.exists(path):
        return None
    txt = open(path, encoding="ascii", errors="replace").read()
    meshes = [ln.split("MeshObjects.LoadFromFile", 1)[1].strip().lstrip("= ")
              for ln in txt.splitlines() if "MeshObjects.LoadFromFile" in ln]
    aaf = next((ln.split("=", 1)[1].strip() for ln in txt.splitlines()
                if "Animations.LoadFromFile" in ln and "=" in ln), "")
    ref = next((ln.split("=", 1)[1].strip() for ln in txt.splitlines()
                if ln.strip().startswith("Reference") and "=" in ln), "")
    interval = next((ln.split("=", 1)[1].strip() for ln in txt.splitlines()
                     if ln.strip().startswith("Interval") and "=" in ln), "")
    mode = next((ln.split("=", 1)[1].strip() for ln in txt.splitlines()
                 if ln.strip().startswith("AnimationMode") and "=" in ln), "")
    return dict(meshes=meshes, anim=aaf, reference=ref,
                interval=interval, animation_mode=mode, bytes=os.path.getsize(path))


# ---------------------------------------------------------------------------
# Donor truth -- observed facts + DERIVED expected framing.
# ---------------------------------------------------------------------------
def donor_truth(game, keys):
    game = str(Path(game).expanduser().resolve())
    U = os.path.join(game, "data", "actors", "units")
    AD = os.path.join(U, "attach")
    A = os.path.join(game, "data", "animations", "aaf")
    out = {
        "generated_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "donor_root": game,
        "keys": {},
        "labels": {
            "observed": "read directly from donor file on disk",
            "derived": "computed from observed donor geometry/ranges by the "
                       "same math as the baker (no live asset used)",
            "inferred": "not stated by donor; documented assumption",
        },
    }
    for key in keys:
        base = KEYS.get(key, key)
        oss = os.path.join(U, base + ".oss")
        aaf = os.path.join(A, base + ".aaf")
        osm = os.path.join(U, base + ".osm")
        d = {"base": base, "composite_attach": NAVAL_ATTACH, "parts": {}}

        # --- crew .oss (observed + derived framing) ---
        if os.path.exists(oss):
            hdr = read_oss_header(oss)
            acts = read_aaf(aaf)
            m = read_oss_full(oss)
            geom = (hdr["verts"] * 12 + hdr["faces"] * 12
                    + hdr["uvs"] * 8 + hdr["faces"] * 12)
            animbytes = hdr["bones"] * hdr["frames"] * 28
            # recompute weight bytes from actual parsed weights
            wbytes = sum(4 + len(w) * 8 for w in m["weights"])
            size_ok = (24 + geom + wbytes + animbytes == hdr["bytes"])
            max_dev = 0.0
            for anim_bone in m["anim"]:
                for rec in anim_bone:
                    max_dev = max(max_dev, abs(math.sqrt(sum(c * c for c in rec[3:])) - 1.0))
            frs = sample(acts.get(CREW_ACTION, (1, 1)), CREW_SAMPLES)
            ref = (m["anim"][0][frs[0]][0], m["anim"][0][frs[0]][1])
            skinned = {fr: skin(m, fr, ref) for fr in frs}
            lo, hi = _bbox([p for fr in frs for p in skinned[fr]])
            # T6-UNITS ruling: project with the SAME RAW center the baker uses
            # (bake_crew builds an unrounded mathutils.Vector and rounds only
            # for storage). Rounding before projecting is an apples-to-oranges
            # comparison and produced a spurious ortho delta. Round AFTER.
            center_raw = (0.0, 0.0, (lo[2] + hi[2]) * 0.5)
            ortho = projected_ortho(frs, skinned, center_raw)
            center = tuple(round(c, 3) for c in center_raw)
            dur = round((acts[CREW_ACTION][1] - acts[CREW_ACTION][0] + 1)
                        / max(1, hdr["fps"]), 3) if CREW_ACTION in acts else 0.0
            d["parts"]["crew"] = {
                "oss": "data/actors/units/%s.oss" % base,
                "aaf": "data/animations/aaf/%s.aaf" % base,
                "header": hdr,
                "size_closure_ok": size_ok,
                "max_quat_norm_dev": max_dev,
                "aaf_actions": acts,
                "aaf_all_same_range": len(set(acts.values())) <= 1 if acts else False,
                "material": "data/materials/units/%s.dds" % base,
                "material_exists": os.path.exists(
                    os.path.join(game, "data", "materials", "units", base + ".dds")),
                "expected": {
                    "action": CREW_ACTION, "frames": len(frs),
                    "frames_list": frs, "duration": dur, "loop": True,
                    "tool": None, "ortho": round(ortho, 3),
                    "center": list(center), "camera_group": "stand",
                },
            }
        else:
            d["parts"]["crew"] = {"oss": None, "note": "no animated .oss in donor"}

        # --- static hull .osm (observed + derived framing) ---
        if os.path.exists(osm):
            hm = read_osm_first(osm)
            hh = hm["header"]
            lo, hi = _bbox(hm["verts"])
            # See crew note: align with bake_hull(), which projects with the
            # raw bbox midpoint and rounds center/ortho only when writing JSON.
            center_raw = tuple((lo[i] + hi[i]) * 0.5 for i in range(3))
            ortho = projected_ortho([0], {0: hm["verts"]}, center_raw)
            center = tuple(round(c, 3) for c in center_raw)
            d["parts"]["hull"] = {
                "osm": "data/actors/units/%s.osm" % base,
                "verts": hh["nv"], "faces": hh["nt"], "uvs": hh["nu"],
                "morph_frames": hh["nf"],
                "offsets": {"ou": hh["ou"], "ot": hh["ot"], "of": hh["of"]},
                "bbox": [[round(v, 3) for v in lo], [round(v, 3) for v in hi]],
                "expected": {
                    "action": "hull", "frames": 1, "duration": HULL_DURATION,
                    "loop": False, "tool": None, "ortho": round(ortho, 3),
                    "center": list(center), "camera_group": "hull",
                },
            }
            variants = {}
            for nm in ("%s1.osm" % base, "%s2.osm" % base, "%s3.osm" % base,
                       "%s4.osm" % base, "%s_death1.osm" % base,
                       "%s_death2.osm" % base):
                p = os.path.join(U, nm)
                if not os.path.exists(p):
                    continue
                vm = read_osm_first(p)
                vh = vm["header"]
                vlo, vhi = _bbox(vm["verts"])
                variants[nm] = {
                    "verts": vh["nv"], "morph_frames": vh["nf"],
                    "bbox": [[round(v, 3) for v in vlo],
                             [round(v, 3) for v in vhi]],
                    "role": "wreck stage" if "death" in nm else "build/direction stage",
                }
            d["parts"]["hull"]["variants"] = variants
        else:
            d["parts"]["hull"] = {"osm": None, "note": "no static .osm hull"}

        # --- attach / build-stage truth (OBSERVED, never composited) ---
        if os.path.isdir(AD):
            att = sorted(x for x in os.listdir(AD)
                         if x.lower().startswith(base.lower()))
            details = {}
            for nm in att:
                p = os.path.join(AD, nm)
                if nm.endswith(".actor"):
                    details[nm] = _actor_facts(p)
                elif nm.endswith(".osm"):
                    hm = read_osm_first(p)
                    details[nm] = {"verts": hm["header"]["nv"],
                                   "morph_frames": hm["header"]["nf"],
                                   "bytes": os.path.getsize(p)}
                elif nm.endswith(".oss"):
                    details[nm] = read_oss_header(p)
                else:
                    details[nm] = {"bytes": os.path.getsize(p)}
            d["parts"]["attach"] = {
                "dir": "data/actors/units/attach",
                "files": details,
                "classification": (
                    "sail = aarMorph .osm stage; flags = skinned .oss; "
                    "yachta/yacht1a..4a/death1a/2a = dock build stages; "
                    "ALL are separate build stages, NOT in-place hand props"),
                "composite_into_crew": False,
                "stage_texture": {
                    "observed": "no separate yacht_sail/flag .dds in donor",
                    "value": "data/materials/units/%s.dds" % base,
                    "label": "inferred",
                },
            }
        else:
            d["parts"]["attach"] = {"dir": None, "files": {},
                                    "composite_into_crew": False}
        # sail / flag AAF (separate timelines)
        extra = {}
        for an in ("%s_sail.aaf" % base, "%s_flag.aaf" % base,
                   "%s_sail.aaf" % base.replace("yacht", "yachttur")):
            p = os.path.join(A, an)
            if os.path.exists(p):
                extra[an] = read_aaf(p)
        d["parts"]["stage_aaf"] = extra
        out["keys"][key] = d
    return out


def print_truth(truth):
    print("donor root:", truth["donor_root"])
    for key, d in truth["keys"].items():
        print("\n=== %s (base %s) ===" % (key, d["base"]))
        c = d["parts"].get("crew", {})
        if c.get("header"):
            h = c["header"]
            print("  crew OSS k=%d fps=%d bones=%d verts=%d faces=%d uvs=%d "
                  "closure=%s quat_dev=%.2g" % (
                      h["frames"], h["fps"], h["bones"], h["verts"],
                      h["faces"], h["uvs"], c["size_closure_ok"],
                      c["max_quat_norm_dev"]))
            print("  crew AAF %s  all_same_range=%s" % (
                c["aaf_actions"], c["aaf_all_same_range"]))
            e = c["expected"]
            print("  crew expected %s frames=%d dur=%.3f ortho=%.3f center=%s "
                  "(DERIVED)" % (e["action"], e["frames"], e["duration"],
                                 e["ortho"], e["center"]))
        h = d["parts"].get("hull", {})
        if h.get("verts"):
            e = h["expected"]
            print("  hull OSM verts=%d faces=%d morph=%d bbox=%s" % (
                h["verts"], h["faces"], h["morph_frames"], h["bbox"]))
            print("  hull expected frames=1 dur=%.1f ortho=%.3f center=%s "
                  "(DERIVED)" % (e["duration"], e["ortho"], e["center"]))
            print("  hull stages: " + ", ".join(
                "%s(%dv)" % (nm, v["verts"]) for nm, v in
                h.get("variants", {}).items()))
        at = d["parts"].get("attach", {})
        print("  attach files=%d composite_into_crew=%s stage_aaf=%s" % (
            len(at.get("files", {})), at.get("composite_into_crew"),
            sorted(d["parts"].get("stage_aaf", {}))))
    print("\nLabels: observed=read from donor; derived=computed from donor; "
          "inferred=documented assumption.")


# ---------------------------------------------------------------------------
# Bake mode (Blender only).
# ---------------------------------------------------------------------------
def import_reference():
    if str(TOOLS) not in sys.path:
        sys.path.insert(0, str(TOOLS))
    import bake_sprites as ref  # attribution: app/tools/bake_sprites.py (K-01)
    return ref


def measure_sheet(path, cell):
    """Cell-local alpha>8 union bbox + metrics + CLIP flag (sheet_metrics-style)."""
    from PIL import Image
    im = Image.open(path).convert("RGBA")
    cols, rows = im.width // cell, im.height // cell
    x0 = y0 = cell
    x1 = y1 = 0
    for r in range(rows):
        for c in range(cols):
            tile = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
            bb = tile.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
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


def _camera_anchor(ref, center, ortho, size):
    cam = ref.camera(center, 0.0, ortho)
    ax, ay = ref.ground_anchor_ay(cam, size)
    ref.bpy.data.objects.remove(cam, do_unlink=True)
    return ax, ay


def _render_8(ref, ob, center, ortho, size, tmp, sheet_path, tag):
    sheet = ref.Image.new("RGBA", (size * 8, size), (0, 0, 0, 0))
    for d in range(8):
        cam = ref.camera(center, d * 45.0, ortho)
        cellp = os.path.join(tmp, "%s_cell.png" % tag)
        ref.render_cell(cellp, size)
        img = ref.Image.open(cellp).convert("RGBA")
        sheet.paste(img, (d * size, 0), img)
        ref.bpy.data.objects.remove(cam, do_unlink=True)
    sheet.save(sheet_path)
    print("  sheet %s %dx%d" % (sheet_path, sheet.width, sheet.height), flush=True)


def bake_crew(ref, game, out, key, base, size, tmp, expected):
    oss = os.path.join(game, "data", "actors", "units", base + ".oss")
    if not os.path.exists(oss):
        return None
    m = ref.read_oss(oss)
    acts = ref.read_aaf(os.path.join(game, "data", "animations", "aaf", base + ".aaf"))
    frs = sample(acts.get(CREW_ACTION, (1, 1)), CREW_SAMPLES)
    rng = acts[CREW_ACTION]
    dur = round((rng[1] - rng[0] + 1) / max(1, m["fps"]), 3)
    # fix 2: bone-0 de-travel to first sampled frame; single stand group (fix 3).
    ref0 = (m["anim"][0][frs[0]][0], m["anim"][0][frs[0]][1])
    skinned = {}
    for fr in frs:
        rx = m["anim"][0][fr][0] - ref0[0]
        ry = m["anim"][0][fr][1] - ref0[1]
        skinned[fr] = [(x - rx, y - ry, z) for x, y, z in ref.skin(m, fr)]
    allp = [p for fr in frs for p in skinned[fr]]
    lo, hi = _bbox(allp)
    center = ref.Vector((0.0, 0.0, (lo[2] + hi[2]) * 0.5))
    ortho = projected_ortho(frs, skinned, (center.x, center.y, center.z))
    print("BAKE crew %s/%s frames=%d dur=%.3f ortho=%.3f center=%s" % (
        key, CREW_ACTION, len(frs), dur, ortho, tuple(center)), flush=True)

    png = ref.dds_to_png(ref.tex_png(game, "unit", base),
                         os.path.join(tmp, base + "_crew.png"), True)
    ref.setup_scene()
    ob = ref.build_mesh(m, ref.make_mat(png))
    me = ob.data
    ax, ay = _camera_anchor(ref, center, ortho, size)
    sheet = ref.Image.new("RGBA", (size * 8, size * len(frs)), (0, 0, 0, 0))
    for ri, fr in enumerate(frs):
        me.vertices.foreach_set("co", [c for v in skinned[fr] for c in v])
        me.update()
        for d in range(8):
            cam = ref.camera(center, d * 45.0, ortho)
            cp = os.path.join(tmp, "crew_cell.png")
            ref.render_cell(cp, size)
            img = ref.Image.open(cp).convert("RGBA")
            sheet.paste(img, (d * size, ri * size), img)
            ref.bpy.data.objects.remove(cam, do_unlink=True)
    sp = os.path.join(out, "%s_%s.png" % (key, CREW_ACTION))
    sheet.save(sp)
    ref.bpy.data.objects.remove(ob, do_unlink=True)
    ad = {"frames": len(frs), "duration": dur, "loop": True,
          "ortho": round(ortho, 3),
          "center": [round(center.x, 3), round(center.y, 3), round(center.z, 3)],
          "ax": ax, "ay": ay, "tool": None, "camera_group": "stand"}
    met = measure_sheet(sp, size)
    if met:
        ad.update(met)
    return {CREW_ACTION: ad}


def bake_hull(ref, game, out, key, base, size, tmp):
    osm = os.path.join(game, "data", "actors", "units", base + ".osm")
    if not os.path.exists(osm):
        return None
    m = ref.read_osm_first(osm)
    lo, hi = _bbox(m["verts"])
    center = ref.Vector(tuple((lo[i] + hi[i]) * 0.5 for i in range(3)))
    ortho = projected_ortho([0], {0: m["verts"]},
                            (center.x, center.y, center.z))
    print("BAKE hull %s verts=%d faces=%d ortho=%.3f center=%s" % (
        key, len(m["verts"]), len(m["faces"]), ortho, tuple(center)), flush=True)
    png = ref.dds_to_png(ref.tex_png(game, "unit", base),
                         os.path.join(tmp, base + "_hull.png"), True)
    ref.setup_scene()
    ob = ref.build_mesh(m, ref.make_mat(png))
    ax, ay = _camera_anchor(ref, center, ortho, size)
    sp = os.path.join(out, "%s_hull.png" % key)
    _render_8(ref, ob, center, ortho, size, tmp, sp, "hull")
    ref.bpy.data.objects.remove(ob, do_unlink=True)
    ad = {"frames": 1, "duration": HULL_DURATION, "loop": False,
          "ortho": round(ortho, 3),
          "center": [round(center.x, 3), round(center.y, 3), round(center.z, 3)],
          "ax": ax, "ay": ay, "tool": None, "camera_group": "hull"}
    met = measure_sheet(sp, size)
    if met:
        ad.update(met)
    return {"hull": ad}


def bake_stages(ref, game, out, key, base, size, tmp, truth):
    """Opt-in separate stage portraits -- NEVER composited into the crew sheet."""
    AD = os.path.join(game, "data", "actors", "units", "attach")
    png = ref.dds_to_png(ref.tex_png(game, "unit", base),
                         os.path.join(tmp, base + "_stage.png"), True)
    result = {}
    stages = []
    sail = os.path.join(AD, base + "_sail.osm")
    if os.path.exists(sail):
        stages.append(("sail", sail, "osm"))
    for n in (1, 2):
        fp = os.path.join(AD, "%s_flag%d.oss" % (base, n))
        if os.path.exists(fp):
            stages.append(("flag%d" % n, fp, "oss"))
    for nm, fn, kind in stages:
        try:
            ref.setup_scene()
            if kind == "osm":
                m = ref.read_osm_first(fn)
                first = m["verts"]
            else:
                m = ref.read_oss(fn)
                frs = sample(ref.read_aaf(os.path.join(
                    game, "data", "animations", "aaf",
                    base + "_flag.aaf")).get("idle", (1, 1)), 1)
                first = ref.skin(m, frs[0])
            lo, hi = _bbox(first)
            center = ref.Vector(tuple((lo[i] + hi[i]) * 0.5 for i in range(3)))
            ortho = projected_ortho([0], {0: first},
                                    (center.x, center.y, center.z))
            ob = ref.build_mesh(m, ref.make_mat(png))
            if kind == "oss":
                ob.data.vertices.foreach_set("co", [c for v in first for c in v])
                ob.data.update()
            ax, ay = _camera_anchor(ref, center, ortho, size)
            sk = "%s_%s" % (key, nm)
            sp = os.path.join(out, "%s_stage.png" % sk)
            _render_8(ref, ob, center, ortho, size, tmp, sp, "stage_" + nm)
            ref.bpy.data.objects.remove(ob, do_unlink=True)
            ad = {"frames": 1, "duration": HULL_DURATION, "loop": False,
                  "ortho": round(ortho, 3),
                  "center": [round(center.x, 3), round(center.y, 3),
                             round(center.z, 3)],
                  "ax": ax, "ay": ay, "tool": None,
                  "stage": True, "composite": False, "camera_group": "stage_" + nm}
            met = measure_sheet(sp, size)
            if met:
                ad.update(met)
            result[sk] = {"cell": size, "actions": {nm: ad}}
        except Exception as ex:
            print("FAIL stage %s/%s: %s" % (key, nm, ex), flush=True)
    return result


def bake(a, out, game):
    ref = import_reference()
    ref._ENGINE = a.engine
    ref._SAMPLES = a.samples
    from PIL import Image  # noqa: F401 (available under Blender via ref path)
    import tempfile
    keys = [k for k in KEYS if not a.only or k in set(a.only.split(","))]
    if not keys:
        print("no keys selected")
        return 2
    os.makedirs(out, exist_ok=True)
    tmp = os.path.join(tempfile.gettempdir(), "cossacks_naval_t6u07",
                       os.path.basename(out))
    os.makedirs(tmp, exist_ok=True)
    print("naval scratch:", tmp, flush=True)

    truth = donor_truth(game, keys)
    # ACCUMULATE truth across one-key-at-a-time invocations, mirroring the
    # staging manifest. A later vessel must not erase the already-verified
    # yacht truth artifact.
    truth_path = os.path.join(out, "donor_truth.json")
    if os.path.exists(truth_path):
        try:
            prev = json.load(open(truth_path, encoding="utf-8"))
            merged = dict(prev)
            merged["keys"] = dict(prev.get("keys", {}))
            merged["keys"].update(truth["keys"])
            merged["generated_utc"] = truth["generated_utc"]
            truth = merged
        except Exception:
            pass
    with open(truth_path, "w", encoding="utf-8") as f:
        json.dump(truth, f, indent=1)

    mf_path = os.path.join(out, "staging_manifest.json")
    manifest = {}
    if os.path.exists(mf_path):
        try:
            manifest = json.load(open(mf_path, encoding="utf-8"))
        except Exception:
            manifest = {}
    for key in keys:
        base = KEYS[key]
        print("BAKE", key, "->", base, "engine", a.engine, flush=True)
        acts = {}
        if not a.no_hull:
            acts.update(bake_hull(ref, game, out, key, base, a.size, tmp) or {})
        acts.update(bake_crew(ref, game, out, key, base, a.size, tmp,
                              truth["keys"][key]) or {})
        if acts:
            manifest[key] = {"cell": a.size, "actions": acts}
            print("UNIT", key, "actions", ",".join(acts), flush=True)
        if a.build_stages:
            manifest.update(bake_stages(ref, game, out, key, base, a.size,
                                        tmp, truth))
        with open(mf_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=1)
    with open(mf_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1)
    print("BAKE COMPLETE", ",".join(keys),
          "(manifest now %d keys)" % len(manifest), flush=True)
    print("BAKE DONE -- slot free", flush=True)
    return 0


# ---------------------------------------------------------------------------
# Verify mode (pure Python + Pillow): staging vs donor truth + live index.
# ---------------------------------------------------------------------------
def _same(a, b, tol=None):
    if tol is not None and isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(float(a) - float(b)) <= tol
    return a == b


def verify(a, out, game):
    from PIL import Image
    mf_path = os.path.join(out, "staging_manifest.json")
    if not os.path.exists(mf_path):
        print("NO staging_manifest.json in", out)
        return 2
    mf = json.load(open(mf_path, encoding="utf-8"))
    live = json.load(open(a.idx, encoding="utf-8")) if os.path.exists(a.idx) else {}
    truth = donor_truth(game, [k for k in mf if k in KEYS])
    allpass = True
    for key, e in mf.items():
        cell = int(e["cell"])
        acts = e["actions"]
        print("\n=== VERIFY", key, "===")
        exp_parts = truth["keys"].get(key, {}).get("parts", {})
        # 1. frames/duration/loop/tool + framing vs DONOR TRUTH (derived)
        for action, ad in acts.items():
            stage = ad.get("stage", False)
            if stage:
                print("  %-9s STAGE sheet (composite=%s) -- not in live index"
                      % (action, ad.get("composite")))
                continue
            exp = None
            for part in ("crew", "hull"):
                ep = exp_parts.get(part, {}).get("expected", {})
                if ep.get("action") == action:
                    exp = ep
            ok = True
            if exp:
                ok &= ad["frames"] == exp["frames"]
                ok &= abs(ad["duration"] - exp["duration"]) <= 0.002
                ok &= ad["loop"] == exp["loop"]
                ok &= ad.get("tool") == exp["tool"]
                ok &= abs(ad["ortho"] - exp["ortho"]) <= 0.002
                ok &= all(abs(x - y) <= 0.002
                          for x, y in zip(ad["center"], exp["center"]))
            else:
                ok = False
            print("  %-9s donor_truth=%s frames=%s dur=%s ortho=%s tool=%s -> %s" % (
                action, "OK" if ok else "FAIL", ad["frames"], ad["duration"],
                ad["ortho"], ad.get("tool"), "PASS" if ok else "FAIL"))
            allpass &= ok
        # 2. cross-check live naval index schema (byte-comparable fields)
        if key in live:
            la = live[key]["actions"]
            for action, ad in acts.items():
                if ad.get("stage") or action not in la:
                    continue
                lv = la[action]
                diffs = []
                for f in ("frames", "loop", "ortho", "center", "ax", "ay", "tool"):
                    if not _same(ad.get(f), lv.get(f),
                                 tol=1e-3 if f in ("ortho", "ax", "ay") else None):
                        diffs.append("%s %s!=%s" % (f, ad.get(f), lv.get(f)))
                if not _same(ad["duration"], lv["duration"], tol=1e-3):
                    diffs.append("duration %s!=%s" % (ad["duration"], lv["duration"]))
                print("  LIVE %-9s %s" % (action,
                      "MATCH" if not diffs else "DIFF " + "; ".join(diffs)))
                allpass &= not diffs
        else:
            print("  LIVE key absent (NEW scoped key -- no live cross-check)")
        # 3. GROUP_OK: stand vs hull groups internally consistent
        def group_ok(names):
            if not names:
                return True
            ref0 = acts[names[0]]
            fields = ("ortho", "center", "ax", "ay")
            return all(all(_same(acts[n][f], ref0[f],
                                 tol=1e-3 if f == "ortho" else None)
                           for f in fields) for n in names)
        stand = [n for n, ad in acts.items() if not ad.get("stage")
                 and ad.get("camera_group") == "stand"]
        hull = [n for n, ad in acts.items() if not ad.get("stage")
                and ad.get("camera_group") == "hull"]
        gok = group_ok(stand) and group_ok(hull)
        print("  GROUP_OK stand=%s hull=%s -> %s" % (
            group_ok(stand), group_ok(hull), "PASS" if gok else "FAIL"))
        allpass &= gok
        # 4. AAF frame truth: walk must use 12 donor-order samples of 1..280
        ep = exp_parts.get("crew", {}).get("expected", {})
        if ep and CREW_ACTION in acts:
            fr_ok = acts[CREW_ACTION]["frames"] == ep["frames"]
            print("  AAF frames %d == donor sample %d -> %s" % (
                acts[CREW_ACTION]["frames"], ep["frames"],
                "PASS" if fr_ok else "FAIL"))
            allpass &= fr_ok
        # 5. build-stage truth: no tool compositing into crew. A hull-only key
        # (battleship/xebec have no .oss) has no crew action, so the check is
        # vacuously satisfied -- never FAIL a static-hull key for this.
        if CREW_ACTION in acts:
            ctool = acts[CREW_ACTION].get("tool", "missing")
            cok = ctool is None
            print("  BUILD_STAGE crew tool=%s (sail/flag separate, never composited) -> %s"
                  % (ctool, "PASS" if cok else "FAIL"))
        else:
            cok = True
            print("  BUILD_STAGE no crew action (static-hull-only key) -> PASS (N/A)")
        allpass &= cok
        # 6. sheet integrity: 8 distinct dirs per row, zero CLIP
        for action, ad in acts.items():
            # Stage sheets are stored as <scoped-key>_stage.png (the scoped key
            # already embeds the stage name, e.g. yacht_sail_stage.png).
            if ad.get("stage"):
                p = os.path.join(out, "%s_stage.png" % key)
            else:
                p = os.path.join(out, "%s_%s.png" % (key, action))
            if not os.path.exists(p):
                print("  SHEET %-9s MISSING %s" % (action, p))
                allpass = False
                continue
            im = Image.open(p).convert("RGBA")
            cols, rows = im.width // cell, im.height // cell
            clips = 0
            distinct = 0
            ink = 0
            for r in range(rows):
                hashes = []
                for c in range(cols):
                    tile = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
                    mask = tile.getchannel("A").point(lambda v: 255 if v > 8 else 0)
                    bb = mask.getbbox()
                    if bb is None:
                        continue
                    ink += 1
                    if bb[0] <= 0 or bb[1] <= 0 or bb[2] >= cell or bb[3] >= cell:
                        clips += 1
                    hashes.append(hash(tile.tobytes()))
                if len(set(hashes)) == cols:
                    distinct += 1
            sheet_ok = (cols == 8 and ink > 0 and clips == 0 and distinct == rows)
            print("  SHEET %-9s %dx%d cells, ink=%d, edge-touch=%d, "
                  "rows 8-distinct=%d/%d -> %s" % (
                      action, cols, rows, ink, clips, distinct, rows,
                      "PASS" if sheet_ok else "FAIL"))
            allpass &= sheet_ok
            ax, ay = ad.get("ax"), ad.get("ay")
            anchor_ok = (ax is not None and ay is not None
                         and abs(ax - 0.5) <= 0.10)
            print("     anchor ax=%s ay=%s fig_h=%s foot=%s cx=%s clip=%s -> %s" % (
                ax, ay, ad.get("fig_h"), ad.get("foot"), ad.get("cx"),
                ad.get("clip"), "PASS" if anchor_ok else "FAIL"))
            allpass &= anchor_ok
    print("\nVERDICT", "ALL PASS" if allpass else "FAIL (see above)")
    return 0 if allpass else 1


def main():
    a = parse_args()
    out = guard_out(a.out)
    game = str(Path(a.game).expanduser().resolve())
    keys = [k for k in KEYS if not a.only or k in set(a.only.split(","))]
    if not keys:
        print("no keys selected")
        return 2
    if a.truth_only:
        truth = donor_truth(game, keys)
        os.makedirs(out, exist_ok=True)
        with open(os.path.join(out, "donor_truth.json"), "w", encoding="utf-8") as f:
            json.dump(truth, f, indent=1)
        print_truth(truth)
        print("\nwrote", os.path.join(out, "donor_truth.json"))
        return 0
    if a.verify:
        return verify(a, out, game)
    return bake(a, out, game)


if __name__ == "__main__":
    sys.exit(main())
