#!/usr/bin/env python3
# T6-U04 — cavalry family mini-baker (piece-by-piece verification).
#
# Donor readers / skinning / camera / compositing are IMPORTED FROM the shared
# read-only reference app/tools/bake_sprites.py (never edited; no donor bytes
# are copied into the repo). Attribution: those primitives are the proven
# peasant-family fix in docs/UNIT_BAKING_FIX.md §2-§4.
#
# WHAT THIS FILE ADDS over the reference / siblings:
#   (a) the 16-key cavalry table + a donor-truth probe that includes the
#       `<base>_horse.oss` MOUNT (the known open follow-up in UNIT_BAKING_FIX §7);
#   (b) a second co-animated skeleton (the mount) composited into the same mesh
#       with two materials, skinned with TRANSPOSED quats and de-traveled by ONE
#       SHARED bone-0 reference (the ground-contact mount, not the rider — see
#       MOUNT DE-TRAVEL below);
#   (c) --no-mount rider-only mode so the rider piece verifies independently;
#   (d) explicit enforcement/reporting of all FIVE bug fixes + staging-only
#       outputs + a self-measuring manifest with cell-local metrics.
#
# MODES
#   --truth / --truth-only   donor truth probe, PURE PYTHON (no Blender)
#   --verify / --verify-only re-measure staged sheets, no Blender, no bake
#   default                  bake (needs Blender): sheets + manifest.json in --out
#
# PHASE-2 BAKE COMMANDS (only after a bake slot is granted by T6-UNITS):
#   "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" \
#     --background --factory-startup --python app\tools\unit_bakers\cavalry.py -- \
#     --game "C:\Games\Cossacks 3" --out "app\shots\unit_pieces\cavalry" \
#     --only dragoon --size 160 --engine workbench
#   :: rider-only A/B control:
#   "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" \
#     --background --factory-startup --python app\tools\unit_bakers\cavalry.py -- \
#     --game "C:\Games\Cossacks 3" --out "app\shots\unit_pieces\cavalry" \
#     --only dragoon --size 160 --engine workbench --no-mount
#
# MOUNT DE-TRAVEL (evidence — docs/t6/reports/T6-U04.md claim C8/C9/C10):
#   The rider's bone 0 is STATIC across idle/walk/attack (dragoon18
#   [-2.003,-0.364,0.721] at frames 505..637) while the horse's bone 0 moves
#   (y -0.153..-0.822). A per-frame probe PROVED that subtracting the horse
#   root makes the horse body DRIFT ~0.4 m (the root translate is an internal
#   rig offset that cancels leg articulation): the raw horse body centroid is
#   already ~y=-0.63 constant across every gallop frame. So the single SHARED
#   de-travel is the RIDER's bone 0 (global idle HOME; per-clip ref for death),
#   applied unchanged to BOTH skeletons — same rule as the reference baker.
#   It preserves rider/horse gluing and keeps the whole mount on one tile.
#
# Donor is PRIVATE USE ONLY: no donor file is copied into the repo. Outputs go
# ONLY to app/shots/unit_pieces/cavalry/**; never to app/assets/models/anim/**.
"""T6-U04 cavalry mini-baker: donor truth + verified staged 8-dir sheets."""
import argparse, hashlib, json, math, os, struct, sys, tempfile
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
if str(APP / "tools") not in sys.path:
    sys.path.insert(0, str(APP / "tools"))

# --truth / --verify must run under plain python, where importing bpy fails.
# bake_sprites defers its Blender imports when it sees --help, so import it
# that way for the read-only modes (same trick as the sibling mini-bakers).
_READONLY = any(a in ("--truth", "--truth-only", "--verify", "--verify-only")
                for a in sys.argv)
if _READONLY:
    _argv = list(sys.argv)
    sys.argv = [_argv[0], "--help"]
    import bake_sprites as ref
    sys.argv = _argv
else:
    import bake_sprites as ref

from PIL import Image

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
STAGING = (APP / "shots" / "unit_pieces" / "cavalry").resolve()
DEFAULT_OUT = str(STAGING)

# Verbatim from T6_WAVE_PLAN LANE UNITS / bake_sprites.py TABLE (L558-561).
KEYS = {
    "dragoon": "dragoon18", "dragoon17": "dragoon", "hussar": "hussar",
    "wingedhussar": "wingedhussar", "cuirassier": "cuirassier",
    "reiter": "reiter", "lightcavalry": "lightcavalry", "hackapell": "hackapell",
    "tatar": "tatar", "sipahi": "sipahi", "spakh": "spakh",
    "mameluke": "mameluke", "vityaz": "vityaz", "hetman": "hetman",
    "cossackdon": "cossackdon", "cossackregister": "cossackregister",
}

# Cavalry .aaf files expose walk/idle/attack/death only — no work/carry clips.
# Donor-truth probe confirms this for all 16 keys (see report claim C3).
PLAN_SPEC = (
    ("walk",   ("walk",),                              12, True),
    ("idle",   ("idle", "idle0"),                       6, True),
    ("attack", ("attack1", "attack0", "attack2", "attack"), 12, False),
    ("death",  ("death", "death0", "death1"),           8, False),
)

# BUG 5: cavalry hand weapons (sword/lance/pistol) are IN-BODY geometry. The
# only attach asset per base is `<base>_horse.oss` (a 24-bone co-animated MOUNT,
# not an action prop). ALL 16 keys ship it. No <base>_tools.actor manifest.
MOUNT_SUFFIX = "_horse"
# Shared donor horse skin; which of black/brown/white the engine picks is not
# in any data-file text we can read (see report OPEN QUESTION 3). Override with
# --horse-tex; default is the neutral brown used as the A/B baseline.
DEFAULT_HORSE_TEX = "horsebrown.dds"

# Verification bands (donor-derived / project gold standard, report §3).
BAND_CX = (0.35, 0.65)          # wider: mounted figures carry saddle/tack
BAND_FOOT = (0.70, 0.98)        # cavalry anchor ay can exceed 0.9 (see C12)
BAND_FIGH_MIN = 0.20            # fig_h == 1.0 is the unmeasured D23 default
BAND_FOOT_PIN_M = 0.50          # skinned low-z centroid drift, X/Y in metres
BAND_GLUE_M = 0.20              # rider-vs-horse centroid drift (mounted only)
DISTINCT_MIN = 0.90             # fraction of distinct cells per action


def parse_args():
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME)
    ap.add_argument("--out", default=DEFAULT_OUT)
    ap.add_argument("--only", default="dragoon",
                    help="comma-separated unit keys; DEFAULT dragoon so no "
                         "accidental whole-family bake (piece-first rule)")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--engine", default="workbench",
                    choices=["workbench", "cycles", "eevee"])
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--truth", "--truth-only", dest="truth", action="store_true",
                    help="print donor truth only; no Blender, no writes")
    ap.add_argument("--verify", "--verify-only", dest="verify", action="store_true",
                    help="re-measure staged sheets against manifest; no Blender")
    ap.add_argument("--no-mount", action="store_true",
                    help="rider-only control bake (independent of mount piece)")
    ap.add_argument("--horse-tex", default=DEFAULT_HORSE_TEX,
                    help="donor horse skin filename under data/materials/units")
    return ap.parse_args(rest)


def oss_closure(path, k, b, v, fc, t):
    """Exact .oss byte-size closure (DC_FORMATS §2.1): proves the reader saw
    the whole file and no trailing unknown block was skipped."""
    with open(path, "rb") as f:
        f.seek(24 + v * 12 + fc * 12 + t * 8 + fc * 12)
        wbytes = 0
        for _ in range(v):
            n = struct.unpack("<i", f.read(4))[0]
            f.read(8 * n)
            wbytes += 4 + 8 * n
    return 24 + v * 12 + fc * 12 + t * 8 + fc * 12 + wbytes + b * k * 28


def variant_suffix(no_mount):
    """Rider-only sheets/manifest keys get a suffix so an A/B pair can live in
    the same staging dir without clobbering each other."""
    return "_rideronly" if no_mount else ""


def sheet_name(key, action, no_mount):
    return "%s%s_%s.png" % (key, variant_suffix(no_mount), action)


def read_aaf_lines(path):
    return open(path, encoding="ascii", errors="replace").read().splitlines()


def donor_truth(game):
    """Observed table for all 16 keys (read-only, no Blender)."""
    out = {}
    for key, base in KEYS.items():
        op = os.path.join(game, "data", "actors", "units", base + ".oss")
        ap = os.path.join(game, "data", "animations", "aaf", base + ".aaf")
        mp = os.path.join(game, "data", "actors", "units", "attach",
                          base + MOUNT_SUFFIX + ".oss")
        mac = os.path.join(game, "data", "actors", "units", "attach",
                           base + MOUNT_SUFFIX + ".actor")
        m = ref.read_oss(op)
        acts = ref.read_aaf(ap)
        header = dict(k=m["k"], fps=m["fps"], bones=len(m["anim"]),
                      verts=len(m["verts"]), faces=len(m["faces"]),
                      uvs=len(m["uvs"]))
        disk = os.path.getsize(op)
        closure = oss_closure(op, m["k"], header["bones"], header["verts"],
                              header["faces"], header["uvs"])
        plan = []
        for action, names, n, loop in PLAN_SPEC:
            rng = next((acts[x] for x in names if x in acts), None)
            if not rng:
                continue
            frs = ref.sample(rng, n)
            plan.append(dict(
                action=action,
                donor_name=next(x for x in names if x in acts),
                first=rng[0], last=rng[1], count=rng[1] - rng[0] + 1,
                fps=m["fps"],
                duration=round((rng[1] - rng[0] + 1) / max(1, m["fps"]), 3),
                frames=len(frs), sampled_frames=frs, loop=loop))
        # MOUNT truth.
        hm = ref.read_oss(mp) if os.path.exists(mp) else None
        mount = None
        if hm:
            mh = dict(k=hm["k"], fps=hm["fps"], bones=len(hm["anim"]),
                      verts=len(hm["verts"]), faces=len(hm["faces"]),
                      uvs=len(hm["uvs"]), size=os.path.getsize(mp))
            hclosure = oss_closure(mp, hm["k"], mh["bones"], mh["verts"],
                                   mh["faces"], mh["uvs"])
            idle = next((p for p in plan if p["action"] == "idle"), None)
            ref_fr = idle["sampled_frames"][0] if idle else plan[0]["sampled_frames"][0]
            mount = dict(
                file=os.path.basename(mp), header=mh, bytes=mh["size"],
                closure=hclosure, closure_ok=(mh["size"] == hclosure),
                actor=open(mac, encoding="ascii", errors="replace").read()
                       if os.path.exists(mac) else None,
                root_at_idle=[round(hm["anim"][0][ref_fr][i], 4) for i in range(3)],
                root_static=all(
                    abs(hm["anim"][0][f][i] - hm["anim"][0][ref_fr][i]) < 0.02
                    for p in plan if p["action"] != "death"
                    for f in p["sampled_frames"] for i in range(3)),
                # sample rider vs horse bone-0 root travel (gallop evidence)
                root_probe={str(fr): dict(
                    rider=[round(m["anim"][0][fr][i], 3) for i in range(3)],
                    horse=[round(hm["anim"][0][fr][i], 3) for i in range(3)])
                    for fr in sorted(set(
                        [ref_fr] + [p["sampled_frames"][0] for p in plan]))},
            )
        adir = os.path.join(game, "data", "actors", "units", "attach")
        attach = sorted(x for x in os.listdir(adir) if x.startswith(base + "_"))
        tools = os.path.join(adir, base + "_tools.actor")
        out[key] = dict(
            base=base, oss=header, oss_bytes=disk, oss_closure=closure,
            closure_ok=(disk == closure), mount=mount,
            tools_manifest=os.path.exists(tools), attach=attach,
            aaf_count=int(read_aaf_lines(ap)[1]),
            aaf={n: dict(first=r[0], last=r[1], count=r[1] - r[0] + 1,
                         duration=round((r[1] - r[0] + 1) / max(1, m["fps"]), 3))
                 for n, r in acts.items()},
            plan=plan)
    return out


def root_refs(m, hm, truth, root=0):
    """Compute the global idle HOME and per-clip death reference for BOTH
    skeletons. Returns (rider_refs_by_frame, horse_refs_by_frame)."""
    idle = next((p for p in truth["plan"] if p["action"] == "idle"), None)
    seed = idle["sampled_frames"][0] if idle else truth["plan"][0]["sampled_frames"][0]
    rider_home = (m["anim"][root][seed][0], m["anim"][root][seed][1])
    horse_home = (hm["anim"][0][seed][0], hm["anim"][0][seed][1]) if hm else None
    rr, hr = {}, {}
    for p in truth["plan"]:
        first = p["sampled_frames"][0]
        rider_ref = ((m["anim"][root][first][0], m["anim"][root][first][1])
                     if p["action"] == "death" else rider_home)
        horse_ref = ((hm["anim"][0][first][0], hm["anim"][0][first][1])
                     if (hm and p["action"] == "death") else horse_home)
        for fr in p["sampled_frames"]:
            rr[fr], hr[fr] = rider_ref, horse_ref
    return rr, hr, rider_home, horse_home


def foot_pin_probe(m, hm, truth, mounted):
    """Geometry-level Bug 2/3 probe. The SHARED de-travel is the rider's bone 0
    in BOTH modes (see module header) — one global idle HOME, per-clip ref for
    death.

    Rider-only: low-z (boot) centroid drift across all standing frames.
    Mounted: the low-z centroid follows the galloping hooves (large, EXPECTED
   articulation), so the tile-pin proxy is the whole-MOUNT body centroid, which
    is stationary in donor world space; plus a rider-vs-mount glue check."""
    rr, _hr, rider_home, horse_home = root_refs(m, hm, truth)
    idle = next(p for p in truth["plan"] if p["action"] == "idle")
    standing = [f for p in truth["plan"] if p["action"] != "death"
                for f in p["sampled_frames"]]

    def centroid_low_z(sk):
        zlo = min(p[2] for p in sk)
        band = [p for p in sk if p[2] <= zlo + 0.15]
        return (sum(p[0] for p in band) / len(band),
                sum(p[1] for p in band) / len(band))

    def centroid(sk):
        return (sum(p[0] for p in sk) / len(sk),
                sum(p[1] for p in sk) / len(sk))

    rider_pts, horse_pts = {}, {}
    for fr in standing:
        dx = m["anim"][0][fr][0] - rr[fr][0]
        dy = m["anim"][0][fr][1] - rr[fr][1]
        rider_pts[fr] = [(x - dx, y - dy, z) for x, y, z in ref.skin(m, fr)]
        if hm:
            horse_pts[fr] = [(x - dx, y - dy, z)
                             for x, y, z in ref.skin(hm, fr)]
    if mounted:
        pin = centroid(horse_pts[standing[0]])   # whole-mount body centroid
        drift = max(math.hypot(*(a - b for a, b in zip(
            centroid(horse_pts[f]), pin))) for f in standing)
        glue_base = tuple(a - b for a, b in zip(
            centroid(rider_pts[standing[0]]), centroid(horse_pts[standing[0]])))
        glue = max(math.hypot(*(a - b for a, b in zip(
            tuple(x - y for x, y in zip(centroid(rider_pts[f]),
                                        centroid(horse_pts[f]))),
            glue_base))) for f in standing)
    else:
        pin = centroid_low_z(rider_pts[standing[0]])
        drift = max(math.hypot(*(a - b for a, b in zip(
            centroid_low_z(rider_pts[f]), pin))) for f in standing)
        glue = None
    return dict(
        mode="mounted" if mounted else "rider_only",
        pin_metric=("mount_body_centroid" if mounted else "rider_low_z_centroid"),
        rider_home=[round(rider_home[0], 4), round(rider_home[1], 4)],
        horse_home=[round(horse_home[0], 4), round(horse_home[1], 4)] if horse_home else None,
        idle_ref_frame=idle["sampled_frames"][0],
        foot_xy=[round(pin[0], 4), round(pin[1], 4)],
        max_stand_drift_m=round(drift, 4),
        max_glue_drift_m=round(glue, 4) if glue is not None else None,
        band=BAND_FOOT_PIN_M,
        ok=(drift <= BAND_FOOT_PIN_M and
            (glue is None or glue <= BAND_GLUE_M)))


def measure_sheet(path, cell, key, action):
    """Cell-local alpha>8 union bbox + fig_h/foot/cx, CLIP and 8-dir
    distinctness. Mirrors sheet_metrics.py; adds per-cell hash alarms."""
    im = Image.open(path).convert("RGBA")
    cols, rows = im.width // cell, im.height // cell
    x0, y0, x1, y1 = cell, cell, 0, 0
    hashes, clips = [], []
    for r in range(rows):
        for c in range(cols):
            crop = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
            a = crop.getchannel("A").point(lambda p: 255 if p > 8 else 0)
            bb = a.getbbox()
            if bb:
                x0, y0 = min(x0, bb[0]), min(y0, bb[1])
                x1, y1 = max(x1, bb[2]), max(y1, bb[3])
                if bb[0] <= 0 or bb[1] <= 0 or bb[2] >= cell or bb[3] >= cell:
                    clips.append([c, r, bb])
            hashes.append(hashlib.sha256(crop.tobytes()).hexdigest()[:12])
    if x1 <= x0 or y1 <= y0:
        return dict(bbox=None, error="empty sheet")
    cx = (x0 + x1) / 2.0 / float(cell)
    foot = y1 / float(cell)
    fig_h = (y1 - y0) / float(cell)
    distinct = len(set(hashes))
    return dict(
        bbox=[x0, y0, x1, y1], fig_h=round(fig_h, 4), foot=round(foot, 4),
        cx=round(cx, 4), cells=len(hashes), distinct_cells=distinct,
        distinct_frac=round(distinct / float(len(hashes)), 4), clips=clips,
        bands_ok=(BAND_CX[0] <= cx <= BAND_CX[1]
                  and BAND_FOOT[0] <= foot <= BAND_FOOT[1]
                  and fig_h > BAND_FIGH_MIN
                  and distinct / float(len(hashes)) >= DISTINCT_MIN))


def save_crops(out, key, action, frames, size, no_mount):
    """Phase-2 visual aids, staged next to the sheets: one 8-dir row strip for
    the first/middle/last sampled frame plus a per-frame dir-0/4 column."""
    cdir = Path(out) / "crops"
    cdir.mkdir(parents=True, exist_ok=True)
    p = Path(out) / sheet_name(key, action, no_mount)
    im = Image.open(p).convert("RGBA")
    picks = sorted(set([0, len(frames) // 2, len(frames) - 1]))
    strip = Image.new("RGBA", (size * 8, size * len(picks)), (0, 0, 0, 0))
    for i, ri in enumerate(picks):
        for d in range(8):
            strip.paste(im.crop((d * size, ri * size, (d + 1) * size,
                                 (ri + 1) * size)), (d * size, i * size))
    tag = "rideronly" if no_mount else "mounted"
    strip.save(cdir / ("%s_%s_%s_dirs.png" % (key, action, tag)))


def bake_one(game, out, key, truth, size, samples, engine, tmp,
             horse_tex, no_mount, metrics=True):
    """One unit, all five bug fixes, staged output only."""
    base = truth["base"]
    m = ref.read_oss(os.path.join(game, "data", "actors", "units", base + ".oss"))
    hm = None
    if not no_mount and truth["mount"]:
        hm = ref.read_oss(os.path.join(game, "data", "actors", "units",
                                       "attach", base + MOUNT_SUFFIX + ".oss"))
    plan = truth["plan"]
    root = 0  # BUG 2: always bone 0, never the max-weight bone/head
    rr, _hr, _rider_home, _horse_home = root_refs(m, hm, truth)

    # BUG 1 (qmat transposed) + BUG 2 (bone-0 de-travel). ONE SHARED rider-root
    # displacement (global idle HOME; per-clip ref for death) is applied to
    # BOTH skeletons — keeps the mount glued and on one tile (module header).
    skinned, skinned_mount = {}, {}
    for p in plan:
        for fr in p["sampled_frames"]:
            if fr in skinned:
                continue
            dx = m["anim"][root][fr][0] - rr[fr][0]
            dy = m["anim"][root][fr][1] - rr[fr][1]
            skinned[fr] = [(x - dx, y - dy, z)
                           for x, y, z in ref.skin(m, fr)]
            if hm:
                skinned_mount[fr] = [(x - dx, y - dy, z)
                                     for x, y, z in ref.skin(hm, fr)]

    def seqs(fr):
        s = [skinned[fr]]
        if hm:
            s.append(skinned_mount[fr])
        return s

    # BUG 3 + 4: ONE stand group and ONE death group. Centre XZ pinned to the
    # entity origin (0,0); Z is the group's union mid-height. Ortho is the
    # largest projected single-side deviation over ALL 8 azimuths (×1.12 AA).
    groups = {}
    for g in ("stand", "death"):
        members = [p for p in plan if (p["action"] == "death") == (g == "death")]
        if not members:
            continue
        lo = [1e9] * 3
        hi = [-1e9] * 3
        for p in members:
            for fr in p["sampled_frames"]:
                for seq in seqs(fr):
                    for x, y, z in seq:
                        for i, v in enumerate((x, y, z)):
                            lo[i] = min(lo[i], v)
                            hi[i] = max(hi[i], v)
        center = (0.0, 0.0, (lo[2] + hi[2]) * 0.5)
        el = math.radians(32.0)
        ce, se = math.cos(el), math.sin(el)
        worst = 1e-6
        for d in range(8):
            az = math.radians(d * 45.0)
            ca, sa = math.cos(az), math.sin(az)
            rx, ry, rz = (-sa, ca, 0.0)
            bx, by, bz = (ca * ce, sa * ce, se)
            ux, uy, uz = (by * rz - bz * ry, bz * rx - bx * rz, bx * ry - by * rx)
            x0 = y0 = 1e9
            x1 = y1 = -1e9
            for p in members:
                for fr in p["sampled_frames"]:
                    for seq in seqs(fr):
                        for x, y, z in seq:
                            dx, dy, dz = x - center[0], y - center[1], z - center[2]
                            px = dx * rx + dy * ry + dz * rz
                            py = dx * ux + dy * uy + dz * uz
                            x0, x1 = min(x0, px), max(x1, px)
                            y0, y1 = min(y0, py), max(y1, py)
            worst = max(worst, 2.0 * max(abs(x0), abs(x1), abs(y0), abs(y1)))
        groups[g] = dict(center=center, ortho=worst * 1.12, lo=lo, hi=hi,
                         members=[p["action"] for p in members])

    png = ref.dds_to_png(ref.tex_png(game, "unit", base),
                         os.path.join(tmp, base + ".png"), True)
    hpng = None
    if hm:
        hp = os.path.join(game, "data", "materials", "units", horse_tex)
        if not os.path.exists(hp):
            raise FileNotFoundError("horse texture not found: " + hp)
        hpng = ref.dds_to_png(hp, os.path.join(tmp, base + "_horse.png"), True)
    ref._ENGINE = engine
    ref._SAMPLES = samples
    ref.setup_scene()
    mat = ref.make_mat(png)
    hmat = ref.make_mat(hpng) if hpng else None

    from mathutils import Vector
    anchors = {}
    for g, gd in groups.items():
        cam = ref.camera(Vector(gd["center"]), 0.0, gd["ortho"])
        anchors[g] = ref.ground_anchor_ay(cam, size)
        ref.bpy.data.objects.remove(cam, do_unlink=True)
        gd["ax"], gd["ay"] = anchors[g]

    # BUG 5: body + donor mount mesh in ONE object, two materials. When the
    # mount is absent (--no-mount) it is the plain reference body mesh. The
    # mounted path uses the corrected UV offset (build_mesh_two, claim C11);
    # the read-only reference builder would scramble the mount's texture.
    if hm and not uv_bounds_ok(m, hm):
        raise ValueError("donor UV index out of range for combined mesh: " + base)
    ob = (build_mesh_two(m, mat, hm, hmat) if hm else ref.build_mesh(m, mat))
    entry = dict(cell=size, actions={}, mounted=bool(hm),
                 horse_tex=(horse_tex if hm else None))
    for p in plan:
        a = p["action"]
        g = "death" if a == "death" else "stand"
        gd = groups[g]
        me = ob.data
        frs = p["sampled_frames"]
        sheet = Image.new("RGBA", (size * 8, size * len(frs)), (0, 0, 0, 0))
        for ri, fr in enumerate(frs):
            verts = [c for seq in seqs(fr) for v in seq for c in v]
            me.vertices.foreach_set("co", verts)
            me.update()
            for d in range(8):
                cam = ref.camera(Vector(gd["center"]), d * 45.0, gd["ortho"])
                cellpath = os.path.join(tmp, "cell.png")
                ref.render_cell(cellpath, size)
                sheet.paste(Image.open(cellpath).convert("RGBA"),
                            (d * size, ri * size))
                ref.bpy.data.objects.remove(cam, do_unlink=True)
        sp = os.path.join(out, sheet_name(key, a, no_mount))
        sheet.save(sp)
        ad = dict(frames=len(frs), duration=p["duration"], loop=p["loop"],
                  ortho=round(gd["ortho"], 3),
                  center=[round(v, 3) for v in gd["center"]],
                  ax=gd["ax"], ay=gd["ay"],
                  tool=(base + MOUNT_SUFFIX if hm else None),
                  donor_name=p["donor_name"],
                  donor_range=[p["first"], p["last"]],
                  donor_count=p["count"], fps=p["fps"],
                  sampled_frames=frs, group=g, mounted=bool(hm))
        if metrics:
            ad.update(measure_sheet(sp, size, key, a))
            save_crops(out, key, a, frs, size, no_mount)
        entry["actions"][a] = ad
    ref.bpy.data.objects.remove(ob, do_unlink=True)
    return entry


def uv_bounds_ok(m, m2):
    """Pure-Python preflight for build_mesh_two's corrected UV offset."""
    iu = max(i for tri in m["uvf"] for i in tri)
    i2 = max(i for tri in m2["uvf"] for i in tri) + len(m["uvs"])
    return iu < len(m["uvs"]) and i2 < len(m["uvs"]) + len(m2["uvs"])


def build_mesh_two(m, mat, m2, mat2):
    """Body + donor mount in one object, two materials.

    Corrected UV-index offset (BONUS BUG, see report claim C11). The shared
    read-only `ref.build_mesh` offsets m2.uvf by the body VERTEX count; donor
    `uvf` are genuine UV indices (verified uvf_max == len(uvs)-1 on every
    .oss sampled), and donor verts != uvs (dragoon18 814v/1039uv, horse
    807v/1086uv), so that offset scrambles the second mesh's texture. Here the
    offset is the body UV count. Face vertex indices still offset by nB.
    Bounds: body uvf<1039; horse uvf+1039<2125. The read-only ref is unchanged.
    """
    nB, nU = len(m["verts"]), len(m["uvs"])
    av = list(m["verts"]) + list(m2["verts"])
    af = list(m["faces"]) + [(a + nB, b + nB, c + nB) for a, b, c in m2["faces"]]
    auv = list(m["uvs"]) + list(m2["uvs"])
    auvf = list(m["uvf"]) + [(a + nU, b + nU, c + nU) for a, b, c in m2["uvf"]]
    me = ref.bpy.data.meshes.new("cavalry_mesh")
    me.from_pydata(av, [], af)
    me.update()
    uv = me.uv_layers.new(name="UVMap")
    for fi, tri in enumerate(af):
        for li in range(3):
            uv.data[fi * 3 + li].uv = auv[auvf[fi][li]]
    ob = ref.bpy.data.objects.new("cavalry", me)
    ref.bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    ob.data.materials.append(mat2)
    for i, poly in enumerate(ob.data.polygons):
        poly.material_index = 0 if i < len(m["faces"]) else 1
    return ob


def signatures(entry):
    return {(ad["ortho"], tuple(ad["center"]), ad["ax"], ad["ay"])
            for ad in entry["actions"].values()}


def check_unit(key, truth, entry, foot, out, no_mount):
    """PASS/FAIL gate; every acceptance criterion is reported, not implied."""
    checks = {}
    checks["oss_size_closure"] = dict(ok=truth["closure_ok"],
        observed=truth["oss_bytes"], expected=truth["oss_closure"])
    aaf = truth["aaf"]
    dur_ok = all(
        aaf[p["donor_name"]]["duration"] == entry["actions"][p["action"]]["duration"]
        and aaf[p["donor_name"]]["first"] == p["first"]
        and aaf[p["donor_name"]]["last"] == p["last"]
        for p in truth["plan"])
    checks["donor_frames_durations"] = dict(ok=dur_ok, expected=[
        [p["donor_name"], p["first"], p["last"], p["duration"]]
        for p in truth["plan"]])
    # GROUP_OK: one stand ortho/centre/anchor; one death group; XZ=(0,0).
    stand = [a for a, ad in entry["actions"].items() if ad["group"] == "stand"]
    death = [a for a, ad in entry["actions"].items() if ad["group"] == "death"]
    sigs = signatures(entry)

    def sig(a):
        ad = entry["actions"][a]
        return (ad["ortho"], tuple(ad["center"]), ad["ax"], ad["ay"])
    group_ok = (len(stand) > 0 and len({sig(a) for a in stand}) == 1
                and len(death) <= 1 and 1 <= len(sigs) <= 2
                and all(abs(entry["actions"][a]["center"][i]) < 1e-9
                        for a in entry["actions"] for i in (0, 1)))
    checks["GROUP_OK"] = dict(ok=group_ok, stand_count=len(stand),
                              death_count=len(death), signatures=len(sigs),
                              stand_sig=sig(stand[0]) if stand else None,
                              death_sig=sig(death[0]) if death else None)
    # Parent ruling (T6-UNITS, relayed in T6-U02 §7.2): the foot-pin band is
    # N/A for mounted riders — limb centroids move with the gallop stride, so
    # a limb-level drift alarm is a DIAGNOSTIC, not a quality gate. The figure
    # staying on one tile is checked by the GROUP_OK anchor + sheet metrics.
    checks["foot_pin_de_travel"] = dict(
        foot, gating=(not entry.get("mounted", False)),
        note=("diagnostic only: foot-pin band N/A for mounted riders"
              if entry.get("mounted") else "gating: rider-only foot band"))
    # BUG 5: every cavalry donor base ships exactly one *_horse.oss mount; it
    # must be composited in mounted mode and absent in rider-only mode.
    mount = truth["mount"]
    expected_tool = (truth["base"] + MOUNT_SUFFIX) if (mount and not no_mount) else None
    got_tools = [entry["actions"][p["action"]]["tool"] for p in truth["plan"]]
    checks["mount_composited"] = dict(
        ok=bool(all(t == expected_tool for t in got_tools)),
        expected=expected_tool, observed=got_tools,
        donor_mount=mount["file"] if mount else None)
    # Metrics / clip / 8-dir distinctness.
    msgs = []
    for a, ad in entry["actions"].items():
        if "bbox" not in ad:
            msgs.append([a, "NOT_MEASURED"])
            continue
        if not ad.get("bands_ok"):
            msgs.append([a, "BAND", ad["bbox"], ad["fig_h"], ad["foot"],
                         ad["cx"], ad["distinct_frac"]])
        if ad.get("clips"):
            msgs.append([a, "CLIP", len(ad["clips"])])
    checks["sheet_metrics"] = dict(ok=(not msgs), alarms=msgs)
    checks["sheets_exist"] = dict(ok=all(
        os.path.exists(os.path.join(out, sheet_name(key, a, no_mount)))
        for a in entry["actions"]))
    overall = all(v.get("ok") for k, v in checks.items()
                  if k != "foot_pin_de_travel" or v.get("gating", True))
    return dict(checks=checks, verdict="PASS" if overall else "FAIL")


def main():
    a = parse_args()
    a.game = str(Path(a.game).expanduser().resolve())
    a.out = Path(a.out).expanduser().resolve()
    # STAGING RULE (absolute): never let an --out typo write into live assets.
    if a.out != STAGING and STAGING not in a.out.parents:
        print("REFUSED: --out must be inside", STAGING, file=sys.stderr)
        return 2
    a.out = str(a.out)
    truth = donor_truth(a.game)
    if a.truth:
        print(json.dumps(truth, indent=1))
        return 0
    keys = [k for k in a.only.split(",") if k]
    bad = [k for k in keys if k not in KEYS]
    if bad:
        print("unknown keys", bad, "known", sorted(KEYS), file=sys.stderr)
        return 2
    os.makedirs(a.out, exist_ok=True)
    mpath = os.path.join(a.out, "manifest.json")
    manifest = json.load(open(mpath, encoding="utf-8")) if os.path.exists(mpath) else {}
    manifest.setdefault("ticket", "T6-U04")
    manifest.setdefault("cell", a.size)
    manifest.setdefault("engine", a.engine)
    manifest.setdefault("staging", str(STAGING))
    manifest.setdefault("horse_tex", a.horse_tex)
    manifest.setdefault("index", {})
    manifest.setdefault("units", {})

    if a.verify:
        for key in keys:
            ukey = key + variant_suffix(a.no_mount)
            rec = manifest["units"].get(ukey, {})
            entry = rec.get("entry")
            if not entry:
                print("VERIFY", ukey, "FAIL - no staged entry in manifest")
                continue
            for action, ad in entry["actions"].items():
                p = os.path.join(a.out, sheet_name(key, action, a.no_mount))
                if os.path.exists(p):
                    ad.update(measure_sheet(p, a.size, key, action))
            res = check_unit(key, truth, entry,
                             rec.get("foot_pin", {"ok": False}), a.out, a.no_mount)
            print("VERIFY", ukey, res["verdict"],
                  json.dumps(res["checks"], indent=1))
        return 0

    import time
    tmp = os.path.join(tempfile.gettempdir(), "cossacks_t6u04",
                       os.path.basename(a.out))
    os.makedirs(tmp, exist_ok=True)
    for key in keys:                      # piece-first: only --only keys
        t = truth[key]
        m = ref.read_oss(os.path.join(a.game, "data", "actors", "units",
                                      t["base"] + ".oss"))
        hm = None
        if not a.no_mount and t["mount"]:
            hm = ref.read_oss(os.path.join(a.game, "data", "actors", "units",
                                           "attach", t["base"] + MOUNT_SUFFIX + ".oss"))
        foot = foot_pin_probe(m, hm, t, mounted=not a.no_mount)
        print("BAKE", key, "base", t["base"], "mount", bool(hm),
              "foot_pin", foot["max_stand_drift_m"], "m",
              "glue", foot["max_glue_drift_m"], flush=True)
        t0 = time.time()
        entry = bake_one(a.game, a.out, key, t, a.size, a.samples, a.engine,
                         tmp, a.horse_tex, a.no_mount)
        res = check_unit(key, t, entry, foot, a.out, a.no_mount)
        ukey = key + variant_suffix(a.no_mount)
        manifest["units"][ukey] = dict(
            base=t["base"], mount=t["mount"],
            donor=dict(oss=t["oss"], oss_bytes=t["oss_bytes"], aaf=t["aaf"],
                       aaf_count=t["aaf_count"], attach=t["attach"]),
            foot_pin=foot, entry=entry, verification=res,
            bake_seconds=round(time.time() - t0, 2))
        # Live-schema index subset, for the gated integration ticket only.
        manifest["index"][ukey] = dict(cell=a.size, actions={
            act: {k: ad[k] for k in ("frames", "duration", "loop", "ortho",
                                     "center", "ax", "ay", "tool",
                                     "bbox", "fig_h", "foot", "cx")
                  if k in ad} for act, ad in entry["actions"].items()})
        json.dump(manifest, open(mpath, "w", encoding="utf-8"), indent=1)
        print("BAKE DONE", ukey, res["verdict"],
              "seconds", manifest["units"][ukey]["bake_seconds"], flush=True)
        for cname, c in res["checks"].items():
            state = ("DIAG" if not c.get("gating", True) else
                     "OK" if c.get("ok") else "FAIL")
            print("  %-22s %s" % (cname, state),
                  json.dumps(c) if state != "OK" else "", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
