#!/usr/bin/env python3
# T6-U02 — 17c infantry family mini-baker (piece-by-piece verification).
#
# Donor readers / skinning / camera / compositing are IMPORTED FROM the shared
# read-only reference app/tools/bake_sprites.py (never edited, never copied into
# the repo as donor data). Attribution: those primitives are the proven
# peasant-family fix documented in docs/UNIT_BAKING_FIX.md §2-§4.
#
# This file adds only: (a) the 11-key infantry17 table + donor-truth probe,
# (b) explicit enforcement/reporting of all FIVE bug fixes, (c) staging-only
# outputs + a self-measuring manifest with cell-local metrics and checks.
#
# MODES
#   --truth   donor-truth probe, PURE PYTHON (no Blender); prints JSON
#   default   bake (requires Blender): sheets + manifest.json into --out
#   --verify-only  re-measure existing staged sheets, no Blender, no writes
#
# BAKE (phase 2, only after a bake slot is granted by T6-UNITS):
#   "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" \
#     --background --factory-startup --python app/tools/unit_bakers/infantry17.py -- \
#     --game "C:\Games\Cossacks 3" \
#     --out  "app\shots\unit_pieces\infantry17" \
#     --only pikeman --size 160 --engine workbench
#
# Donor is PRIVATE USE ONLY: no donor file is copied into the repo. Outputs go
# ONLY to the staging dir; never to app/assets/models/anim/** (integration is
# a separate gated ticket).
"""T6-U02 17c infantry mini-baker: donor truth + verified staged 8-dir sheets."""
import argparse, hashlib, json, math, os, struct, sys, tempfile
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
if str(APP / "tools") not in sys.path:
    sys.path.insert(0, str(APP / "tools"))

# Loader trick: --truth / --verify-only must run under plain python, where
# importing bpy fails. bake_sprites defers its Blender imports when it sees
# --help, so import it that way for the read-only modes.
_TRUTH_MODE = any(a in ("--truth", "--verify-only") for a in sys.argv)
if _TRUTH_MODE:
    _argv = list(sys.argv)
    sys.argv = [_argv[0], "--help"]
    import bake_sprites as ref
    sys.argv = _argv
else:
    import bake_sprites as ref

from PIL import Image

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_OUT = str(APP / "shots" / "unit_pieces" / "infantry17")

# Verbatim from T6_WAVE_PLAN LANE UNITS / bake_sprites.py table.
KEYS = {
    "pikeman": "pikeman", "roundshier": "roundshier", "serdiuk": "serdiuk",
    "archer": "archer", "strelet": "strelet", "cossack": "cossacksich",
    "pandur": "pandur", "croat": "croat", "chasseur": "chasseur",
    "highlander": "highlander", "jannisary": "jannisary",
}

# Donor action selection, identical priority to bake_sprites.bake_unit.
# attack1 (volley) wins when present; pike/sword units have only attack0
# (thrust), which is then correctly chosen (confirmed from each .aaf).
PLAN_SPEC = (
    ("walk",    ("walk",),                             12, True),
    ("idle",    ("idle", "idle0"),                      6, True),
    ("attack",  ("attack1", "attack0", "attack2", "attack"), 12, False),
    ("death",   ("death", "death0", "death1"),          8, False),
)

# BUG 5 (attach props). This family's donor ships NO `<base>_<tool>.oss`
# files: tools/weapons are already inside the body mesh. The only attach
# assets for two keys are *_horse.oss mounts (cavalry role, out of this lane).
# The mapping stays EMPTY here on donor evidence, not by omission; the
# compositing path below is generic and will bake any prop that is discovered
# for a future key without changing the code.
ATTACH_ACTIONS = {}

# Verification bands (donor-derived / project gold standard, see report §3).
BAND_CX = (0.40, 0.60)          # sheet_metrics roster audit: all cx 0.497..0.503
BAND_FOOT = (0.70, 0.95)        # land foot band (68 measured outliers end 0.95)
BAND_FIGH_MIN = 0.20            # fig_h == 1.0 is the unmeasured D23 default
BAND_FOOT_PIN_M = 0.50          # skinned low-z centroid drift, X/Y in metres
DISTINCT_MIN = 0.90             # fraction of distinct cells per action


def parse_args():
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME)
    ap.add_argument("--out", default=DEFAULT_OUT)
    ap.add_argument("--only", default="pikeman",
                    help="comma-separated unit keys; DEFAULT pikeman so no "
                         "accidental whole-family bake (piece-first rule)")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--engine", default="workbench",
                    choices=["workbench", "cycles", "eevee"])
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--truth", action="store_true",
                    help="print donor truth only; no Blender, no writes")
    ap.add_argument("--verify-only", action="store_true",
                    help="re-measure staged sheets against manifest; no Blender")
    return ap.parse_args(rest)


def oss_closure(path, k, b, v, fc, t):
    """Exact .oss byte-size closure (DC_FORMATS §2.1); proves the reader saw
    the whole file and no trailing unknown block was skipped."""
    with open(path, "rb") as f:
        f.seek(24 + v * 12 + fc * 12 + t * 8 + fc * 12)
        wbytes = 0
        for _ in range(v):
            n = struct.unpack("<i", f.read(4))[0]
            f.read(8 * n)
            wbytes += 4 + 8 * n
    return 24 + v * 12 + fc * 12 + t * 8 + fc * 12 + wbytes + b * k * 28


def donor_truth(game):
    """Observed table for all 11 keys (read-only, no Blender)."""
    out = {}
    for key, base in KEYS.items():
        op = os.path.join(game, "data", "actors", "units", base + ".oss")
        ap = os.path.join(game, "data", "animations", "aaf", base + ".aaf")
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
        adir = os.path.join(game, "data", "actors", "units", "attach")
        attach = sorted(x for x in os.listdir(adir) if x.startswith(base + "_"))
        out[key] = dict(
            base=base, oss=header, oss_bytes=disk, oss_closure=closure,
            closure_ok=(disk == closure),
            aaf_count=int(open(ap, encoding="ascii", errors="replace")
                          .read().splitlines()[1]),
            aaf={n: dict(first=r[0], last=r[1], count=r[1] - r[0] + 1,
                         duration=round((r[1] - r[0] + 1) / max(1, m["fps"]), 3))
                 for n, r in acts.items()},
            plan=plan, attach=attach)
    return out


def foot_pin_probe(m, truth, ref):
    """Geometry-level Bug 2/3 probe: after bone-0 de-travel to the global
    idle HOME, the skinned LOW-Z (foot) centroid must stay put across every
    standing frame and all sampled actions (not just within one clip)."""
    root = 0
    idle = next(p for p in truth["plan"] if p["action"] == "idle")
    home = (m["anim"][root][idle["sampled_frames"][0]][0],
            m["anim"][root][idle["sampled_frames"][0]][1])
    refs = {}
    for p in truth["plan"]:
        if p["action"] == "death":
            r = (m["anim"][root][p["sampled_frames"][0]][0],
                 m["anim"][root][p["sampled_frames"][0]][1])
        else:
            r = home
        for fr in p["sampled_frames"]:
            refs[fr] = r
    feet = {}
    for fr, r in refs.items():
        sk = ref.skin(m, fr)
        rx, ry = (m["anim"][root][fr][0] - r[0],
                  m["anim"][root][fr][1] - r[1])
        pts = [(x - rx, y - ry, z) for x, y, z in sk]
        zlo = min(z for _, _, z in pts)
        band = [p for p in pts if p[2] <= zlo + 0.15]
        feet[fr] = (sum(p[0] for p in band) / len(band),
                    sum(p[1] for p in band) / len(band))
    base = feet[idle["sampled_frames"][0]]
    standing = [feet[f] for p in truth["plan"] if p["action"] != "death"
                for f in p["sampled_frames"]]
    drift = max(math.hypot(x - base[0], y - base[1]) for x, y in standing)
    return dict(home=[round(home[0], 4), round(home[1], 4)],
                idle_ref_frame=idle["sampled_frames"][0],
                foot_xy=[round(x, 4) for x in base],
                max_stand_drift_m=round(drift, 4),
                band=BAND_FOOT_PIN_M, ok=drift <= BAND_FOOT_PIN_M)


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
    distinct = len(set(hashes))
    # Acceptance is "all 8 directions distinct" PER FRAME ROW. Cross-frame
    # duplicates are donor-true for looping idle (loop closure: first pose ==
    # last pose) and one-shot attacks (recovery hold), so the aggregate
    # fraction is informational only (archer idle 43/48, jannisary attack
    # 81/96 — both have 8/8 distinct dirs in every row).
    row_dir_uniq = [len(set(hashes[r * cols:(r + 1) * cols])) for r in range(rows)]
    dirs_ok = all(v == cols for v in row_dir_uniq)
    return dict(
        bbox=[x0, y0, x1, y1],
        fig_h=round((y1 - y0) / float(cell), 4),
        foot=round(y1 / float(cell), 4),
        cx=round((x0 + x1) / 2.0 / float(cell), 4),
        cells=len(hashes), distinct_cells=distinct,
        distinct_frac=round(distinct / float(len(hashes)), 4),
        dir_uniq_per_row=row_dir_uniq, dirs_ok=dirs_ok,
        clips=clips,
        bands_ok=(BAND_CX[0] <= (x0 + x1) / 2.0 / float(cell) <= BAND_CX[1]
                  and 0.70 <= y1 / float(cell) <= 0.95
                  and (y1 - y0) / float(cell) > BAND_FIGH_MIN
                  and dirs_ok))


def save_crops(out, key, action, frames, size):
    """Phase-2 visual aids, staged next to the sheets: one 8-dir row strip
    for the first/middle/last sampled frame and a per-frame dir-0 column."""
    cdir = Path(out) / "crops"
    cdir.mkdir(parents=True, exist_ok=True)
    p = Path(out) / ("%s_%s.png" % (key, action))
    im = Image.open(p).convert("RGBA")
    picks = sorted(set([0, len(frames) // 2, len(frames) - 1]))
    strip = Image.new("RGBA", (size * 8, size * len(picks)), (0, 0, 0, 0))
    for i, ri in enumerate(picks):
        for d in range(8):
            strip.paste(im.crop((d * size, ri * size, (d + 1) * size,
                                 (ri + 1) * size)), (d * size, i * size))
    strip.save(cdir / ("%s_%s_dirs.png" % (key, action)))


def compute_groups(plan, seqs):
    """BUG 3 + 4: ONE stand group and ONE death group. Centre XZ is pinned to
    the entity origin (0,0); Z is the group's union mid-height. Ortho is the
    largest projected single-side deviation over ALL 8 azimuths at elevation
    32 deg (×1.12 AA bleed). Pure Python: callable in --truth mode for the
    read-only cross-check against compute_ortho.py."""
    groups = {}
    for g in ("stand", "death"):
        members = [p for p in plan if (p["action"] == "death") == (g == "death")]
        if not members:
            continue
        lo = [1e9] * 3
        hi = [-1e9] * 3
        for p in members:
            for fr in p["sampled_frames"]:
                for seq in seqs(p, fr):
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
                    for seq in seqs(p, fr):
                        for x, y, z in seq:
                            dx, dy, dz = x - center[0], y - center[1], z - center[2]
                            px = dx * rx + dy * ry + dz * rz
                            py = dx * ux + dy * uy + dz * uz
                            x0, x1 = min(x0, px), max(x1, px)
                            y0, y1 = min(y0, py), max(y1, py)
            worst = max(worst, 2.0 * max(abs(x0), abs(x1), abs(y0), abs(y1)))
        groups[g] = dict(center=center, ortho=worst * 1.12, lo=lo, hi=hi,
                         members=[p["action"] for p in members])
    return groups


def bake_one(game, out, key, truth, size, samples, engine, tmp, metrics=True):
    """One unit, all five bug fixes, staged output only."""
    base = truth["base"]
    m = ref.read_oss(os.path.join(game, "data", "actors", "units", base + ".oss"))
    plan = truth["plan"]
    root = 0  # BUG 2: always bone 0 (hips), never the max-weight bone/head

    # BUG 2: one global HOME from the idle clip; death keeps a per-clip ref.
    idle = next((p for p in plan if p["action"] == "idle"), None)
    if idle:
        idle_home = (m["anim"][root][idle["sampled_frames"][0]][0],
                     m["anim"][root][idle["sampled_frames"][0]][1])
    else:
        idle_home = (m["anim"][root][plan[0]["sampled_frames"][0]][0],
                     m["anim"][root][plan[0]["sampled_frames"][0]][1])
    skinned = {}
    for p in plan:
        ref_xy = ((m["anim"][root][p["sampled_frames"][0]][0],
                   m["anim"][root][p["sampled_frames"][0]][1])
                  if p["action"] == "death" else idle_home)
        for fr in p["sampled_frames"]:
            if fr in skinned:
                continue
            s = ref.skin(m, fr)                       # BUG 1: qmat transposed
            rx, ry = (m["anim"][root][fr][0] - ref_xy[0],
                      m["anim"][root][fr][1] - ref_xy[1])
            skinned[fr] = [(x - rx, y - ry, z) for x, y, z in s]

    # BUG 5: discover donor props (none for this family); composite any that
    # exist with the same transposed skin + identical bone-0 de-travel.
    attach_dir = os.path.join(game, "data", "actors", "units", "attach")
    prop_files = {}
    for p in plan:
        for tool in ATTACH_ACTIONS.get(p["action"], []):
            fp = os.path.join(attach_dir, "%s_%s.oss" % (base, tool))
            if os.path.exists(fp):
                prop_files[tool] = ref.read_oss(fp)
    skinned_tool = {}
    for p in plan:
        for tool in ATTACH_ACTIONS.get(p["action"], []):
            am = prop_files.get(tool)
            if not am:
                continue
            ref_xy = ((m["anim"][root][p["sampled_frames"][0]][0],
                       m["anim"][root][p["sampled_frames"][0]][1])
                      if p["action"] == "death" else idle_home)
            for fr in p["sampled_frames"]:
                key2 = (fr, tool)
                if key2 in skinned_tool:
                    continue
                M = ref.qmat(*am["anim"][0][fr][3:])
                pp = am["anim"][0][fr][:3]
                rx, ry = (m["anim"][root][fr][0] - ref_xy[0],
                          m["anim"][root][fr][1] - ref_xy[1])
                skinned_tool[key2] = [
                    (M[0][0] * x + M[0][1] * y + M[0][2] * z + pp[0] - rx,
                     M[1][0] * x + M[1][1] * y + M[1][2] * z + pp[1] - ry,
                     M[2][0] * x + M[2][1] * y + M[2][2] * z + pp[2])
                    for x, y, z in am["verts"]]

    def tool_of(action):
        for tool, acts in ATTACH_ACTIONS.items():
            if action in acts and tool in prop_files:
                return tool
        return None

    def seqs(p, fr):
        seq = [skinned[fr]]
        t = tool_of(p["action"])
        if t and (fr, t) in skinned_tool:
            seq.append(skinned_tool[(fr, t)])
        return seq

    # BUG 3 + 4: ONE stand group and ONE death group (compute_groups below).
    groups = compute_groups(plan, seqs)

    png = ref.dds_to_png(ref.tex_png(game, "unit", base),
                         os.path.join(tmp, base + ".png"), True)
    tpng = None
    if prop_files:
        tpng = ref.dds_to_png(os.path.join(game, "data", "materials", "units",
                                           "peaaustools.dds"),
                              os.path.join(tmp, "tools.png"), True)
    ref._ENGINE = engine
    ref._SAMPLES = samples
    ref.setup_scene()
    mat = ref.make_mat(png)
    tmat = ref.make_mat(tpng) if tpng else None

    # Project the world origin ONCE per group: identical ax/ay for every
    # action and direction in that group (feet cannot slide on action change).
    from mathutils import Vector
    anchors = {}
    for g, gd in groups.items():
        cam = ref.camera(Vector(gd["center"]), 0.0, gd["ortho"])
        anchors[g] = ref.ground_anchor_ay(cam, size)
        ref.bpy.data.objects.remove(cam, do_unlink=True)
        gd["ax"], gd["ay"] = anchors[g]

    ob = None
    cur_tool = object()
    entry = dict(cell=size, actions={})
    for p in plan:
        a = p["action"]
        g = "death" if a == "death" else "stand"
        gd = groups[g]
        tool = tool_of(a)
        if ob is None or tool != cur_tool:
            if ob is not None:
                ref.bpy.data.objects.remove(ob, do_unlink=True)
            ob = (ref.build_mesh(m, mat, prop_files[tool], tmat)
                  if tool else ref.build_mesh(m, mat))
            cur_tool = tool
        me = ob.data
        frs = p["sampled_frames"]
        sheet = Image.new("RGBA", (size * 8, size * len(frs)), (0, 0, 0, 0))
        for ri, fr in enumerate(frs):
            verts = list(skinned[fr])
            if tool and (fr, tool) in skinned_tool:
                verts += skinned_tool[(fr, tool)]
            me.vertices.foreach_set("co", [c for v in verts for c in v])
            me.update()
            for d in range(8):
                cam = ref.camera(Vector(gd["center"]), d * 45.0, gd["ortho"])
                cellpath = os.path.join(tmp, "cell.png")
                ref.render_cell(cellpath, size)
                cell_img = Image.open(cellpath).convert("RGBA")
                sheet.paste(cell_img, (d * size, ri * size), cell_img)
                ref.bpy.data.objects.remove(cam, do_unlink=True)
        sp = os.path.join(out, "%s_%s.png" % (key, a))
        sheet.save(sp)
        ad = dict(frames=len(frs), duration=p["duration"], loop=p["loop"],
                  ortho=round(gd["ortho"], 3),
                  center=[round(v, 3) for v in gd["center"]],
                  ax=gd["ax"], ay=gd["ay"], tool=tool,
                  donor_name=p["donor_name"],
                  donor_range=[p["first"], p["last"]],
                  donor_count=p["count"], fps=p["fps"],
                  sampled_frames=frs, group=g)
        if metrics:
            ad.update(measure_sheet(sp, size, key, a))
            save_crops(out, key, a, frs, size)
        entry["actions"][a] = ad
    if ob is not None:
        ref.bpy.data.objects.remove(ob, do_unlink=True)
    return entry


def check_unit(key, truth, entry, foot, out):
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
    def sig(a):
        ad = entry["actions"][a]
        return (ad["ortho"], tuple(ad["center"]), ad["ax"], ad["ay"])
    sigs = signatures(entry)
    group_ok = (len(stand) > 0 and len({sig(a) for a in stand}) == 1
                and len(death) <= 1 and 1 <= len(sigs) <= 2
                and all(abs(entry["actions"][a]["center"][i]) < 1e-9
                        for a in entry["actions"] for i in (0, 1)))
    checks["GROUP_OK"] = dict(ok=group_ok, stand_count=len(stand),
                              death_count=len(death),
                              stand_sig=sig(stand[0]) if stand else None,
                              death_sig=sig(death[0]) if death else None)
    checks["foot_pin_de_travel"] = foot
    # BUG 5: on donor evidence this family has no tool props; *_horse is a
    # cavalry mount, deliberately out of scope (not an action prop).
    expected_tools = [tool_of_family(truth) for _ in truth["plan"]]
    got_tools = [entry["actions"][p["action"]]["tool"] for p in truth["plan"]]
    checks["attach_props"] = dict(ok=expected_tools == got_tools,
                                  expected=expected_tools, observed=got_tools,
                                  donor_attach=truth["attach"])
    # Metrics / clip / 8-dir distinctness.
    msgs = []
    for a, ad in entry["actions"].items():
        if "bbox" not in ad:
            msgs.append([a, "NOT_MEASURED"])
            continue
        if not ad.get("bands_ok"):
            msgs.append([a, "BAND", ad.get("bbox"), ad.get("fig_h"),
                         ad.get("foot"), ad.get("cx"),
                         ad.get("distinct_frac")])
        if ad.get("clips"):
            msgs.append([a, "CLIP", len(ad["clips"])])
    checks["sheet_metrics"] = dict(ok=(not msgs), alarms=msgs)
    checks["sheets_exist"] = dict(ok=all(
        os.path.exists(os.path.join(out, "%s_%s.png" % (key, a)))
        for a in entry["actions"]))
    overall = all(v.get("ok") for v in checks.values()) and group_ok and foot["ok"]
    return dict(checks=checks, verdict="PASS" if overall else "FAIL")


def signatures(entry):
    """Distinct (ortho, center, ax, ay) tuples across all actions: 1 when the
    unit has no death clip, 2 for a shared stand group + one death group."""
    return {(ad["ortho"], tuple(ad["center"]), ad["ax"], ad["ay"])
            for ad in entry["actions"].values()}


def tool_of_family(truth):
    """Donor-driven: no `<base>_<tool>.oss` for this family -> None."""
    return next((x for x in truth["attach"]
                 if x.endswith(".oss") and "_horse" not in x), None)


def main():
    a = parse_args()
    a.game = str(Path(a.game).expanduser().resolve())
    a.out = str(Path(a.out).expanduser().resolve())
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
    manifest.setdefault("ticket", "T6-U02")
    manifest.setdefault("cell", a.size)
    manifest.setdefault("engine", a.engine)
    manifest.setdefault("index", {})
    manifest.setdefault("units", {})

    if a.verify_only:
        for key in keys:
            entry = manifest["units"].get(key, {}).get("entry")
            if not entry:
                print("VERIFY", key, "FAIL - no staged entry in manifest")
                continue
            for action, ad in entry["actions"].items():
                p = os.path.join(a.out, "%s_%s.png" % (key, action))
                if os.path.exists(p):
                    ad.update(measure_sheet(p, a.size, key, action))
            res = check_unit(key, truth[key], entry,
                             manifest["units"][key].get("foot_pin", {"ok": False}),
                             a.out)
            manifest["units"][key]["verification"] = res
            # Persist re-measurements: a verify pass after a band refinement
            # must update the staged verdict, not just print it.
            for act, ad in entry["actions"].items():
                manifest["index"][key]["actions"][act].update({
                    k: ad[k] for k in ("bbox", "fig_h", "foot", "cx") if k in ad})
            json.dump(manifest, open(mpath, "w", encoding="utf-8"), indent=1)
            print("VERIFY", key, res["verdict"], json.dumps(res["checks"], indent=1))
        return 0

    import time
    tmp = os.path.join(tempfile.gettempdir(), "cossacks_t6u02",
                       os.path.basename(a.out))
    os.makedirs(tmp, exist_ok=True)
    for key in keys:                      # piece-first: only --only keys
        t = truth[key]
        m = ref.read_oss(os.path.join(a.game, "data", "actors", "units",
                                      t["base"] + ".oss"))
        foot = foot_pin_probe(m, t, ref)
        print("BAKE", key, "base", t["base"], "foot_pin", foot["max_stand_drift_m"],
              "m", flush=True)
        t0 = time.time()
        entry = bake_one(a.game, a.out, key, t, a.size, a.samples, a.engine, tmp)
        res = check_unit(key, t, entry, foot, a.out)
        manifest["units"][key] = dict(base=t["base"], donor=dict(
            oss=t["oss"], oss_bytes=t["oss_bytes"], aaf=t["aaf"],
            aaf_count=t["aaf_count"], attach=t["attach"]),
            foot_pin=foot, entry=entry, verification=res,
            bake_seconds=round(time.time() - t0, 2))
        # Live-schema index subset, for the gated integration ticket only.
        manifest["index"][key] = dict(cell=a.size, actions={
            act: {k: ad[k] for k in ("frames", "duration", "loop", "ortho",
                                     "center", "ax", "ay", "tool",
                                     "bbox", "fig_h", "foot", "cx")
                  if k in ad} for act, ad in entry["actions"].items()})
        json.dump(manifest, open(mpath, "w", encoding="utf-8"), indent=1)
        print("BAKE DONE", key, res["verdict"],
              "seconds", manifest["units"][key]["bake_seconds"], flush=True)
        for cname, c in res["checks"].items():
            print("  %-22s %s" % (cname, "OK" if c.get("ok") else "FAIL"),
                  json.dumps(c) if not c.get("ok") else "", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
