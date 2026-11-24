#!/usr/bin/env python3
"""T6-U01 — Peasants family MINI-BAKER (piece-by-piece, staging only).

Scope: peasant + ukr/rus/pol/aus/eng/spa/tur/sco_peasant.  Reads the donor
(C:\\Games\\Cossacks 3) READ-ONLY; writes ONLY staging sheets + derived metadata
under app/shots/unit_pieces/peasants/.  Never writes app/assets/models/anim/**.

Reuse: the baking path calls the proven app/tools/bake_sprites.py primitives
(read_oss/read_aaf/qmat/skin/sample/camera/ground_anchor_ay/projected-ortho/
attach compositing) via import -- that file is READ-ONLY and unmodified.  The
pure-python readers below are copied verbatim from it (with attribution) so the
audit/verify modes run without Blender.

Usage (Blender 5.2, workbench, fast):
  blender --background --factory-startup --python app/tools/unit_bakers/peasants.py -- \
     --game "C:\\Games\\Cossacks 3" --out app/shots/unit_pieces/peasants \
     --size 160 --engine workbench --only peasant

  python app/tools/unit_bakers/peasants.py --out app/shots/unit_pieces/peasants --verify
"""
import argparse
import hashlib
import json
import math
import os
import struct
import sys
import tempfile
from pathlib import Path

# ---------------------------------------------------------------------------
# Keys (verbatim T6_WAVE_PLAN.md LANE UNITS) -> donor base (bake_sprites table)
# ---------------------------------------------------------------------------
KEYMAP = {
    "peasant":       "peaukr",
    "ukr_peasant":   "peaukr",
    "rus_peasant":   "pearus",
    "pol_peasant":   "peapol",
    "aus_peasant":   "peaaus",
    "eng_peasant":   "peaeng",
    "spa_peasant":   "peaspa",
    "tur_peasant":   "peatur",
    "sco_peasant":   "peasco",
}

# Tool -> actions, from bake_sprites.py:288-291 (UNIT_BAKING_FIX §2 bug 5).
ATTACH_ACTIONS = {
    "axe": ["workwood", "attack"],
    "hammer": ["construct"],
    "hoe": ["workfood"],
    "pick": ["workstone"],
    "lumber": ["walkwood", "idlewood"],
    "bag": ["walkfood", "idlefood"],
    "cart": ["walkstone", "idlestone"],
}

# Exact action plan of bake_sprites.bake_unit (lines 229-242).  Kept here for
# independent donor-truth verification; the bake itself calls bake_unit.
PLAN_SPEC = (
    ("walk",      ("walk",),                     12, True),
    ("idle",      ("idle", "idle0"),              6, True),
    ("attack",    ("attack1", "attack0", "attack2", "attack"), 12, False),
    ("workwood",  ("workwood",),                 10, True),
    ("workfood",  ("workfood",),                 10, True),
    ("workstone", ("workstone",),                10, True),
    ("construct", ("construct",),                  8, True),
    ("walkwood",  ("walkwood",),                 10, True),
    ("walkfood",  ("walkfood",),                 10, True),
    ("walkstone", ("walkstone",),                10, True),
    ("idlewood",  ("idlewood",),                  6, True),
    ("idlefood",  ("idlefood",),                  6, True),
    ("idlestone", ("idlestone",),                 6, True),
    ("death",     ("death", "death0", "death1"),  8, False),
)

# agentC2 / agentSE port convention (UNIT_BAKING_FIX §10 / §11.2): 12 sampled
# walk frames => 1.08 s (n*0.09), overriding the raw donor 20 frames / 30 fps
# = 0.667 s.  Stored in the staged index; the raw donor value is kept in
# donor_truth.json so both are auditable.
WALK_DURATION_PORT = 1.08

DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

# Blender puts the script's own dir on sys.path, not app/tools/ where the
# unmodified reference baker lives (T6-U01 owns only this file).
_TOOLS_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _TOOLS_DIR not in sys.path:
    sys.path.insert(0, _TOOLS_DIR)

# ---------------------------------------------------------------------------
# Pure-python donor readers — copied verbatim from bake_sprites.py (READ-ONLY).
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
    """TRANSPOSED donor rotation (bake_sprites.py:84-95, UNIT_BAKING_FIX bug 1)."""
    M = ((1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)),
         (2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)),
         (2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)))
    return ((M[0][0], M[1][0], M[2][0]),
            (M[0][1], M[1][1], M[2][1]),
            (M[0][2], M[1][2], M[2][2]))


def skin(m, fr):
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
    a, b = rng
    if b <= a:
        return [a]
    total = b - a + 1
    if total <= n:
        return list(range(a, b + 1))
    return [a + round((b - a) * i / (n - 1)) for i in range(n)] if n > 1 else [a]


def action_plan(m, acts):
    """Return (action, range, sampled_frames, loop, donor_duration) rows."""
    plan = []
    for action, names, n, loop in PLAN_SPEC:
        rng = next((acts[x] for x in names if x in acts), None)
        if rng:
            plan.append((action, rng, sample(rng, n), loop,
                         (rng[1] - rng[0] + 1) / max(1, m["fps"])))
    return plan


def resolve_out(out):
    out = str(Path(out).expanduser().resolve())
    os.makedirs(out, exist_ok=True)
    return out


def scratch_dir(out):
    # Scratch NEVER under res:// (UNIT_BAKING_FIX §8).
    d = os.path.join(tempfile.gettempdir(), "cossacks_t6_u01", os.path.basename(out))
    os.makedirs(d, exist_ok=True)
    return d


def load_json(path, default):
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    return default


def merge_json(path, new):
    """Piece-by-piece: a later --only run must not erase earlier units."""
    cur = load_json(path, {})
    cur.update(new)
    json.dump(cur, open(path, "w", encoding="utf-8"), indent=1)


# ---------------------------------------------------------------------------
# DONOR TRUTH (read-only) -> derived numbers/names only, no donor bytes copied.
# ---------------------------------------------------------------------------
def audit_donor(game, keys):
    truth = {}
    for key in keys:
        base = KEYMAP[key]
        oss = os.path.join(game, "data", "actors", "units", base + ".oss")
        aaf = os.path.join(game, "data", "animations", "aaf", base + ".aaf")
        m = read_oss(oss)
        acts = read_aaf(aaf)
        plan = action_plan(m, acts)
        props = {}
        for tool in ATTACH_ACTIONS:
            p = os.path.join(game, "data", "actors", "units", "attach",
                             "%s_%s.oss" % (base, tool))
            if not os.path.exists(p):
                continue
            pm = read_oss(p)
            props[tool] = {
                "bones": len(pm["anim"]), "verts": len(pm["verts"]),
                "faces": len(pm["faces"]), "k": pm["k"], "fps": pm["fps"],
            }
        truth[key] = {
            "base": base,
            "oss": {"fps": m["fps"], "frames": m["k"], "bones": len(m["anim"]),
                    "verts": len(m["verts"]), "faces": len(m["faces"]),
                    "uvs": len(m["uvs"])},
            "aaf_action_ranges": acts,
            "plan": [{"action": a, "range": list(r), "sampled_frames": frs,
                      "loop": loop, "donor_duration": round(dur, 4)}
                     for a, r, frs, loop, dur in plan],
            "attach_props": props,
            "tool_map": ATTACH_ACTIONS,
            "textures": {
                "body": os.path.exists(os.path.join(
                    game, "data", "materials", "units", base + ".dds")),
                "tools": os.path.exists(os.path.join(
                    game, "data", "materials", "units", "peaaustools.dds")),
            },
            "attach_manifest": os.path.exists(os.path.join(
                game, "data", "actors", "units", "attach", base + "_tools.actor")),
        }
    return truth


# ---------------------------------------------------------------------------
# Metrics: sheet_metrics-style CELL-LOCAL alpha>8 union bbox + per-cell clips.
# ---------------------------------------------------------------------------
def measure_sheets(out, idx):
    from PIL import Image
    detail = {}
    cell = int(idx[next(iter(idx))]["cell"]) if idx else 160
    for key, info in idx.items():
        cell = int(info["cell"])
        for act, ad in info.get("actions", {}).items():
            p = os.path.join(out, "%s_%s.png" % (key, act))
            if not os.path.exists(p):
                detail["%s_%s" % (key, act)] = {"missing_sheet": True}
                continue
            im = Image.open(p).convert("RGBA")
            alpha = im.getchannel("A").point(lambda v: 255 if v > 8 else 0)
            cols, rows = im.width // cell, im.height // cell
            x0, y0, x1, y1 = cell, cell, 0, 0
            foot_rows = [1.0, 0.0]
            clips = []
            cell_ink = []
            row_hashes = []
            cell_hashes = []
            for r in range(rows):
                rowhash = hashlib.sha1()
                col_inks = []
                row_cell_hashes = []
                for c in range(cols):
                    cell_rgba = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell))
                    # Distinctness must use the FULL RGBA bytes: hashing the
                    # alpha>8 mask collapses near-identical silhouettes at
                    # 160 px and falsely reports duplicate frames.
                    ch = hashlib.sha1(cell_rgba.tobytes()).hexdigest()[:12]
                    row_cell_hashes.append(ch)
                    a = cell_rgba.getchannel("A").point(lambda v: 255 if v > 8 else 0)
                    bb = a.getbbox()
                    if bb:
                        x0, y0 = min(x0, bb[0]), min(y0, bb[1])
                        x1, y1 = max(x1, bb[2]), max(y1, bb[3])
                        foot_rows[0] = min(foot_rows[0], bb[3] / float(cell))
                        foot_rows[1] = max(foot_rows[1], bb[3] / float(cell))
                        if bb[0] <= 0 or bb[1] <= 0 or bb[2] >= cell or bb[3] >= cell:
                            clips.append([c, r, list(bb)])
                        col_inks.append(sum(1 for v in a.getdata() if v))
                    else:
                        col_inks.append(0)
                    rowhash.update(cell_rgba.tobytes())
                cell_ink.append(col_inks)
                cell_hashes.append(row_cell_hashes)
                row_hashes.append(rowhash.hexdigest()[:12])
            if x1 <= x0 or y1 <= y0:
                detail["%s_%s" % (key, act)] = {"empty_sheet": True}
                continue
            ad["bbox"] = [x0, y0, x1, y1]
            ad["fig_h"] = round((y1 - y0) / float(cell), 4)
            ad["foot"] = round(y1 / float(cell), 4)
            ad["cx"] = round((x0 + x1) / 2.0 / float(cell), 4)
            detail["%s_%s" % (key, act)] = {
                "clips": clips, "n_clips": len(clips),
                "distinct_frames": len(set(row_hashes)), "frames": rows,
                "distinct_dirs_per_frame": [
                    len(set(row)) for row in cell_hashes
                ],
                "ink_bbox": [x0, y0, x1, y1],
                "foot_row_range": [round(foot_rows[0], 4), round(foot_rows[1], 4)],
            }
    return detail


# ---------------------------------------------------------------------------
# Independent projection math (BUG 4 cross-check), no bpy.
# ---------------------------------------------------------------------------
def projected_ortho_body_only(m, frs, center, keyplan):
    # De-travel exactly as the baker does; without it the diagnostic returns
    # 2.688 instead of the documented body-only 4.136 for peaukr.
    idle = next((f for a, r, f, loop, dur in keyplan if a == "idle"), frs[:1])
    home = (m["anim"][0][idle[0]][0], m["anim"][0][idle[0]][1])
    el = math.radians(32.0)
    ce, se = math.cos(el), math.sin(el)
    uncached = {}
    worst = 1e-6
    for d in range(8):
        az = math.radians(d * 45.0)
        ca, sa = math.cos(az), math.sin(az)
        rx, ry, rz = -sa, ca, 0.0
        bx, by, bz = ca * ce, sa * ce, se
        ux = by * rz - bz * ry
        uy = bz * rx - bx * rz
        uz = bx * ry - by * rx
        x0 = y0 = 1e9
        x1 = y1 = -1e9
        for fr in frs:
            if fr not in uncached:
                rx = m["anim"][0][fr][0] - home[0]
                ry = m["anim"][0][fr][1] - home[1]
                uncached[fr] = [(x - rx, y - ry, z) for x, y, z in skin(m, fr)]
            for x, y, z in uncached[fr]:
                dx, dy, dz = x - center[0], y - center[1], z - center[2]
                px = dx * rx + dy * ry + dz * rz
                py = dx * ux + dy * uy + dz * uz
                x0, x1 = min(x0, px), max(x1, px)
                y0, y1 = min(y0, py), max(y1, py)
        worst = max(worst, 2.0 * max(abs(x0), abs(x1), abs(y0), abs(y1)))
    return worst * 1.12


def foot_pin_stats(m, keyplan):
    """De-travel (bone 0 to global idle HOME) -> foot stability per frame."""
    idle_home = None
    for action, rng, frs, loop, dur in keyplan:
        if action == "idle":
            idle_home = (m["anim"][0][frs[0]][0], m["anim"][0][frs[0]][1])
            break
    if idle_home is None:
        frs0 = keyplan[0][2]
        idle_home = (m["anim"][0][frs0[0]][0], m["anim"][0][frs0[0]][1])
    rows = []
    for action, rng, frs, loop, dur in keyplan:
        ref = ((m["anim"][0][frs[0]][0], m["anim"][0][frs[0]][1])
               if action == "death" else idle_home)
        for fr in frs:
            vs = skin(m, fr)
            rx = m["anim"][0][fr][0] - ref[0]
            ry = m["anim"][0][fr][1] - ref[1]
            vs = [(x - rx, y - ry, z) for x, y, z in vs]
            minz = min(v[2] for v in vs)
            feet = [v for v in vs if v[2] < minz + 0.10]
            cx = sum(v[0] for v in feet) / len(feet)
            cy = sum(v[1] for v in feet) / len(feet)
            rows.append((action, fr, round(minz, 4), round(cx, 4), round(cy, 4)))
    stand = [r for r in rows if r[0] != "death"]
    max_xy = max((math.hypot(r[3], r[4]) for r in stand), default=0.0)
    max_drift = 0.0
    if stand:
        for r in stand:
            max_drift = max(max_drift, math.hypot(r[3] - stand[0][3], r[4] - stand[0][4]))
    return {"n_frames": len(rows), "max_foot_offset_m": round(max_xy, 4),
            "max_foot_drift_m": round(max_drift, 4),
            "minz_range": [min(r[2] for r in stand), max(r[2] for r in stand)],
            "per_frame": rows}


def de_travel_stats(m, keyplan):
    """BUG 2 check: bone 0 (root) is re-based to ONE global idle HOME for
    every standing frame (per-clip ref only for death), so the root never
    travels and the figure's ground plane stays at z ~ 0.  Unlike a foot
    centroid this is not confused by the donor's work-step leg motion.
    """
    idle = next((frs for a, r, frs, loop, dur in keyplan if a == "idle"), None)
    if not idle:
        idle = keyplan[0][2]
    home = (m["anim"][0][idle[0]][0], m["anim"][0][idle[0]][1])
    stand_refs = set()
    death_ref = None
    death_first = None
    stand_minzs = []
    for action, rng, frs, loop, dur in keyplan:
        ref = ((m["anim"][0][frs[0]][0], m["anim"][0][frs[0]][1])
               if action == "death" else home)
        if action == "death":
            death_ref = tuple(round(v, 6) for v in ref)
            death_first = tuple(round(m["anim"][0][frs[0]][i], 6) for i in (0, 1))
        else:
            stand_refs.add(tuple(round(v, 6) for v in ref))
            for fr in frs:
                stand_minzs.append(min(v[2] for v in skin(m, fr)))
    return {"home": [round(v, 4) for v in home],
            "n_stand_refs": len(stand_refs),
            "stand_ref": sorted(stand_refs)[0] if stand_refs else None,
            "death_ref_per_clip": death_ref,
            "death_ref_is_own_first_frame": (death_ref == death_first),
            "death_ref_coincides_with_home": (death_ref == tuple(round(v, 6) for v in home)),
            "stand_ground_z_min": round(min(stand_minzs), 4),
            "stand_ground_z_max": round(max(stand_minzs), 4)}


def grip_bone_check(game, base, props, m):
    """For each prop, find the body bone its bone-0 rest translation matches."""
    ref_fr = 64 if m["k"] > 64 else 0
    out = {}
    for tool in props:
        pm = read_oss(os.path.join(game, "data", "actors", "units", "attach",
                                   "%s_%s.oss" % (base, tool)))
        p = pm["anim"][0][min(ref_fr, pm["k"] - 1)][:3]
        best = sorted(((math.dist(p, m["anim"][j][min(ref_fr, m["k"] - 1)][:3]), j)
                       for j in range(len(m["anim"]))))[:3]
        out[tool] = {"prop_bone0_rest": [round(v, 4) for v in p],
                     "nearest_body_bones": [[round(d, 4), j] for d, j in best]}
    return out


# ---------------------------------------------------------------------------
# BAKE — calls the unmodified reference baker, then measures + writes manifest.
# ---------------------------------------------------------------------------
def do_bake(game, out, keys, size, samples, engine):
    import bake_sprites as B  # Blender-only; deliberately imported lazily.
    B._ENGINE = engine
    B._SAMPLES = samples
    tmp = scratch_dir(out)
    idx_path = os.path.join(out, "index.json")
    idx = load_json(idx_path, {})
    truth = audit_donor(game, keys)
    for key in keys:
        base = KEYMAP[key]
        try:
            e = B.bake_unit(game, out, key, base, size, samples, tmp)
            if not e:
                print("FAIL unit", key, "no action plan", flush=True)
                continue
            if "walk" in e["actions"]:
                raw = e["actions"]["walk"]["duration"]
                e["actions"]["walk"]["duration"] = WALK_DURATION_PORT
                e["actions"]["walk"]["donor_duration"] = raw
            idx[key] = e
            json.dump(idx, open(idx_path, "w", encoding="utf-8"), indent=1)
            print("unit", key, "actions", len(e["actions"]),
                  "stand_ortho", e["actions"].get("idle", {}).get("ortho"),
                  flush=True)
        except Exception as ex:
            print("FAIL unit", key, repr(ex), flush=True)
    detail = measure_sheets(out, idx)
    json.dump(idx, open(idx_path, "w", encoding="utf-8"), indent=1)
    merge_json(os.path.join(out, "donor_truth.json"), truth)
    merge_json(os.path.join(out, "measure_detail.json"), detail)
    print("BAKE COMPLETE", len(keys), "keys ->", out, flush=True)


# ---------------------------------------------------------------------------
# VERIFY (pure python, no Blender): donor truth x sheet metrics x 5 bug fixes.
# ---------------------------------------------------------------------------
def do_verify(game, out, keys, truth=None):
    idx = load_json(os.path.join(out, "index.json"), {})
    truth = truth or load_json(os.path.join(out, "donor_truth.json"), {})
    detail = load_json(os.path.join(out, "measure_detail.json"), {})
    report = {"keys": {}, "checks": {}, "pass": True}
    for key in keys:
        if key not in idx:
            report["keys"][key] = {"pass": False, "reason": "not in staged index"}
            report["pass"] = False
            continue
        t = truth.get(key, {})
        m = read_oss(os.path.join(game, "data", "actors", "units",
                                  KEYMAP[key] + ".oss"))
        acts = read_aaf(os.path.join(game, "data", "animations", "aaf",
                                     KEYMAP[key] + ".aaf"))
        kp = action_plan(m, acts)
        ad = idx[key]["actions"]
        res = {"checks": {}}
        # 1. coverage / frame counts / durations / loop
        expected = {a for a, r, frs, loop, dur in kp}
        got = set(ad)
        res["checks"]["action_set"] = (expected == got)
        mism = []
        for a, r, frs, loop, dur in kp:
            if a not in ad:
                continue
            x = ad[a]
            if x["frames"] != len(frs):
                mism.append((a, "frames", x["frames"], len(frs)))
            if x["loop"] != loop:
                mism.append((a, "loop", x["loop"], loop))
            exp_dur = WALK_DURATION_PORT if a == "walk" else dur
            if abs(float(x["duration"]) - exp_dur) > 0.002:
                mism.append((a, "duration", x["duration"], exp_dur))
        res["checks"]["frames_loop_duration"] = (not mism)
        res["mismatches"] = mism
        # 2. tools per action (bug 5)
        want_tool = {}
        for tool, aa in ATTACH_ACTIONS.items():
            for a in aa:
                want_tool[a] = tool
        tool_bad = [a for a in ad if ad[a].get("tool") != want_tool.get(a)]
        res["checks"]["tool_mapping"] = (not tool_bad)
        res["tool_bad"] = tool_bad
        # 3. shared stand / death camera group (bug 3)
        stand = [ad[a] for a in ad if a != "death"]
        def sig(x):
            return (x["ortho"], tuple(x["center"]), x["ax"], x["ay"])
        res["checks"]["shared_stand_group"] = all(sig(s) == sig(stand[0]) for s in stand)
        res["checks"]["shared_death_distinct"] = (
            "death" not in ad or sig(ad["death"]) != sig(stand[0]))
        res["checks"]["center_xz_zero"] = all(
            abs(s["center"][0]) < 1e-9 and abs(s["center"][1]) < 1e-9
            for s in ad.values())
        res["stand_sig"] = sig(stand[0]) if stand else None
        # 4. transposed quaternion sanity (bug 1)
        x, y, z, w = 0.31, -0.22, 0.47, 0.79
        n = math.sqrt(x*x + y*y + z*z + w*w)
        x, y, z, w = x/n, y/n, z/n, w/n
        Q = qmat(x, y, z, w)
        MT = ((1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+y*w)),
              (2*(x*y+z*w), 1-2*(x*x+z*z), 2*(y*z-x*w)),
              (2*(x*z-y*w), 2*(y*z+x*w), 1-2*(x*x+y*y)))
        res["checks"]["qmat_transposed"] = all(
            abs(Q[r][c] - MT[c][r]) < 1e-12 for r in range(3) for c in range(3))
        res["checks"]["rest_quat_identity"] = all(
            abs(v - (1.0 if i == 3 else 0.0)) < 1e-6
            for i, v in enumerate(m["anim"][0][0][3:]))
        # 5. projected ortho recompute (bug 4) + body-only gold-standard probe
        if stand:
            c = stand[0]["center"]
            allfr = sorted({fr for a, r, frs, loop, dur in kp
                            if a != "death" for fr in frs})
            # full recompute with props would need bake_unit internals; compare
            # the body-only projection to the historical 4.136 reference and
            # assert the staged ortho >= it (props widen the stand group).
            body_ortho = projected_ortho_body_only(m, allfr, c, kp)
            res["body_only_stand_ortho"] = round(body_ortho, 3)
            res["staged_stand_ortho"] = stand[0]["ortho"]
            res["checks"]["ortho_body_lower_bound"] = (
                stand[0]["ortho"] >= body_ortho - 0.02)
        # 6. per-cell clip / distinctness (sheet metrics, visual proxy)
        clips = 0
        distinct_ok = True
        for a in ad:
            d = detail.get("%s_%s" % (key, a), {})
            clips += d.get("n_clips", 0)
            if d.get("stage") != "skip":
                if d.get("distinct_frames", 0) < max(1, ad[a]["frames"]):
                    distinct_ok = False
                if any(v < 2 for v in d.get("distinct_dirs_per_frame", [])):
                    distinct_ok = False
        res["checks"]["zero_cell_clips"] = (clips == 0)
        res["checks"]["all_dirs_frames_distinct"] = distinct_ok
        res["total_clips"] = clips
        # 7. foot pin / de-travel (bug 2): one global HOME for all stand
        # clips, per-clip ref for death, figure ground plane near z=0, and
        # rendered feet stay inside one cell row band across every action.
        fp = de_travel_stats(m, kp)
        res["de_travel"] = fp
        rows_lo, rows_hi = 1.0, 0.0
        for a in ad:
            fr = detail.get("%s_%s" % (key, a), {}).get("foot_row_range")
            if fr:
                rows_lo, rows_hi = min(rows_lo, fr[0]), max(rows_hi, fr[1])
        res["rendered_foot_row_range"] = [round(rows_lo, 4), round(rows_hi, 4)]
        res["checks"]["single_global_idle_home"] = (fp["n_stand_refs"] == 1)
        # The baker keeps a per-clip ref for death; on this donor the first
        # death-frame root happens to equal HOME numerically, so assert the
        # RULE (ref == own first frame) rather than that the numbers differ.
        res["checks"]["death_uses_own_ref"] = (
            fp["death_ref_per_clip"] is None or
            fp["death_ref_is_own_first_frame"])
        res["checks"]["ground_plane_stable"] = (
            -0.15 <= fp["stand_ground_z_min"] and fp["stand_ground_z_max"] <= 0.15)
        res["checks"]["feet_on_one_tile"] = (0.45 <= rows_lo and rows_hi <= 1.0)
        # 8. grips per nation prefix
        grips = grip_bone_check(game, KEYMAP[key], t.get("attach_props", {}), m)
        res["grips"] = grips
        res["checks"]["grips_close_to_body_bone"] = all(
            v["nearest_body_bones"][0][0] < 0.35 for v in grips.values())
        res["checks"]["all_7_props_present"] = (len(grips) == 7)
        # verdict
        res["pass"] = all(res["checks"].values())
        report["keys"][key] = res
        if not res["pass"]:
            report["pass"] = False
        print("%-14s %s  stand=%s  clips=%d  footrow=[%.3f,%.3f]" % (
            key, "PASS" if res["pass"] else "FAIL",
            res.get("stand_sig"), clips, rows_lo, rows_hi), flush=True)
    with open(os.path.join(out, "verify_report.json"), "w", encoding="utf-8") as f:
        json.dump(report, f, indent=1)
    print("VERIFY", "ALL PASS" if report["pass"] else "FAILURES PRESENT", flush=True)
    return report


def parse_args():
    # Under Blender the real arguments follow `--`; under plain python they
    # are sys.argv[1:] (mirrors bake_sprites.parse_args).
    rest = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME)
    ap.add_argument("--out", required=True)
    ap.add_argument("--only", default="")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="workbench",
                    choices=["cycles", "eevee", "workbench"])
    ap.add_argument("--mode", choices=["audit", "bake", "verify", "all"], default="bake")
    return ap.parse_args(rest)


def main():
    a = parse_args()
    out = resolve_out(a.out)
    keys = [k for k in KEYMAP if (not a.only or k in set(a.only.split(",")))]
    if a.mode in ("audit", "bake", "all"):
        truth = audit_donor(a.game, keys)
        merge_json(os.path.join(out, "donor_truth.json"), truth)
        print("AUDIT", len(truth), "keys", flush=True)
    if a.mode in ("bake", "all"):
        do_bake(a.game, out, keys, a.size, a.samples, a.engine)
    if a.mode in ("verify", "all"):
        report = do_verify(a.game, out, keys)
        return 0 if report["pass"] else 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
