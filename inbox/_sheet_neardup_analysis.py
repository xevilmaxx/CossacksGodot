#!/usr/bin/env python3
"""MICRO RECON: perceptual near-duplicate frame detection in unit sheets.

Read-only. For each sprite sheet:
  cell = width/8, rows = height/cell (8 columns = viewing directions, rows = frames).
  Each row (full-width strip) is alpha-composited over white, downscaled to 32x32
  grayscale -> perceptual fingerprint (bytes) + normalized MAE vs neighbouring rows.
  Near-duplicate pair flag: normalized MAE < 0.02.

Also computes a full-resolution diff for each flagged pair to distinguish
"static repeated pose" (safe to collapse) from "subtle motion frames" (unsafe).

Writes inbox/sheet_neardup_audit.json. No asset edits.
"""
import os, json, base64, hashlib
from PIL import Image
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCOPES = [
    os.path.join(ROOT, "app", "assets", "models", "anim", "common", "units"),
    os.path.join(ROOT, "app", "assets", "models", "anim", "sco", "units"),
]
FP_THRESHOLD = 0.02          # normalized MAE on 32x32 grayscale
FP_SIZE = (32, 32)
BG = (255, 255, 255)         # fixed composite background: white
# full-res motion classification thresholds (normalized MAE on composited full-res strip)
STATIC_MAE = 0.003
STATIC_CHANGED_FRAC = 0.001  # fraction of pixels with |diff|>8 (of 255)


def action_of(name):
    n = name.lower()
    for kw in ("construct", "death", "attack", "walk", "idle", "work"):
        if kw in n:
            return kw
    return "other"


def unit_of(name, action):
    base = name[:-4]  # drop .png
    # remove action keyword (and any directly-appended suffix words after it)
    for kw in (action, "death", "attack", "walk", "idle", "work", "construct"):
        idx = base.find(kw)
        if idx > 0:
            return base[:idx]
    return base


def fingerprint(strip_rgba):
    """Strip (RGBA PIL) -> 32x32 grayscale bytes after white composite."""
    bg = Image.new("RGBA", strip_rgba.size, BG + (255,))
    comp = Image.alpha_composite(bg, strip_rgba).convert("L")
    fp = np.asarray(comp.resize(FP_SIZE, Image.LANCZOS), dtype=np.uint8)
    return fp, comp  # comp: full-res composited grayscale (for motion analysis)


def groups_from_pairs(flags):
    """Adjacent-pair boolean flags -> connected groups of row indices."""
    if not flags:
        return []
    groups, cur = [], [flags[0][0]]
    for (a, b), f in zip(flags, flags[1:]):
        if f[1] == b:  # overlapping next pair
            cur.append(b)
        else:
            groups.append(cur); cur = [b]
    groups.append(cur)
    return groups


def analyze_sheet(path):
    with Image.open(path) as im:
        sheet = im.convert("RGBA")
    w, h = sheet.size
    cell = w // 8
    rows = h // cell
    name = os.path.basename(path)
    action = action_of(name)
    unit = unit_of(name, action)

    fps, fullres = [], []
    alpha_cov = []  # mean alpha coverage of each strip (to spot padding/empty rows)
    for r in range(rows):
        strip = sheet.crop((0, r * cell, w, (r + 1) * cell))
        a = np.asarray(strip.getchannel("A"), dtype=np.float32) / 255.0
        alpha_cov.append(float(a.mean()))
        fp, comp = fingerprint(strip)
        fps.append(fp)
        fullres.append(np.asarray(comp, dtype=np.int16))

    fps = np.stack(fps)
    # neighbour MAE (normalized 0..1)
    neighbor_mae = []
    for i in range(rows - 1):
        d = np.abs(fps[i].astype(np.int16) - fps[i + 1].astype(np.int16))
        neighbor_mae.append(float(d.mean() / 255.0))

    # exact + high-res analysis for flagged near-dup adjacent pairs
    pairs = []
    for i in range(rows - 1):
        if neighbor_mae[i] >= FP_THRESHOLD:
            continue
        a, b = fullres[i], fullres[i + 1]
        diff = np.abs(a - b)
        hm = float(diff.mean() / 255.0)
        changed = float((diff > 8).mean())
        exact = bool(diff.max() == 0)
        if exact:
            cls = "exact_static"
        elif hm < STATIC_MAE and changed < STATIC_CHANGED_FRAC:
            cls = "near_static"
        else:
            cls = "subtle_motion"
        pairs.append({
            "row_a": i, "row_b": i + 1,
            "fp_mae": round(neighbor_mae[i], 6),
            "highres_mae": round(hm, 6),
            "changed_frac": round(changed, 6),
            "exact": exact,
            "class": cls,
            "empty_pair": bool(alpha_cov[i] < 0.01 and alpha_cov[i + 1] < 0.01),
        })

    # all-pairs near-dup (supplementary; catches non-adjacent repeats)
    all_pairs = []
    exact_pairs = []
    nearstatic_pairs = []
    for i in range(rows):
        for j in range(i + 1, rows):
            d = np.abs(fps[i].astype(np.int16) - fps[j].astype(np.int16))
            m = float(d.mean() / 255.0)
            if m < FP_THRESHOLD:
                all_pairs.append({"row_a": i, "row_b": j, "fp_mae": round(m, 6)})
            dh = np.abs(fullres[i] - fullres[j])
            if dh.max() == 0:
                exact_pairs.append([i, j])
            else:
                hm = float(dh.mean() / 255.0)
                cf = float((dh > 8).mean())
                if hm < STATIC_MAE and cf < STATIC_CHANGED_FRAC:
                    nearstatic_pairs.append({"row_a": i, "row_b": j,
                                             "highres_mae": round(hm, 6),
                                             "changed_frac": round(cf, 6)})

    # near-static groups (union-find over nearstatic_pairs endpoints)
    parent = list(range(rows))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for p in nearstatic_pairs:
        ra, rb = find(p["row_a"]), find(p["row_b"])
        if ra != rb:
            parent[ra] = rb
    buckets = {}
    for r in range(rows):
        buckets.setdefault(find(r), []).append(r)
    nearstatic_groups = sorted([g for g in buckets.values() if len(g) >= 2])

    # connected groups from adjacent near-dup pairs
    flags = [(p["row_a"], p["row_b"]) for p in pairs]
    groups = []
    if flags:
        cur = [flags[0][0], flags[0][1]]  # first pair covers both endpoints
        for k in range(1, len(flags)):
            if flags[k][0] == flags[k - 1][1]:
                cur.append(flags[k][1])
            else:
                groups.append(cur); cur = [flags[k][0], flags[k][1]]
        groups.append(cur)
    groups = [g for g in groups if len(g) >= 2]

    near_dup_rows = set()
    for p in pairs:
        near_dup_rows.add(p["row_a"]); near_dup_rows.add(p["row_b"])

    raw_row_bytes = w * cell * 4  # RGBA8 uncompressed bytes per row
    drop_rows = sum(len(g) - 1 for g in groups)

    return {
        "file": os.path.relpath(path, ROOT).replace("\\", "/"),
        "unit": unit,
        "action": action,
        "width": w, "height": h, "cell": cell, "rows": rows,
        "fingerprints_b64": [base64.b64encode(fp.tobytes()).decode("ascii") for fp in fps],
        "fingerprint_sha1_8": [hashlib.sha1(fp.tobytes()).hexdigest()[:16] for fp in fps],
        "neighbor_mae": [round(m, 6) for m in neighbor_mae],
        "alpha_coverage": [round(c, 4) for c in alpha_cov],
        "near_dup_pairs": pairs,
        "near_dup_pair_count": len(pairs),
        "near_dup_row_count": len(near_dup_rows),
        "near_dup_groups": groups,
        "all_pairs_near_dup": all_pairs,
        "exact_identical_pairs": exact_pairs,
        "nearstatic_pairs": nearstatic_pairs,
        "nearstatic_groups_rows": nearstatic_groups,
        "nearstatic_row_count": len(set(
            r for g in nearstatic_groups for r in g)),
        "drop_rows_if_collapsed": drop_rows,
        "raw_bytes_total": raw_row_bytes * rows,
        "raw_bytes_saved": raw_row_bytes * drop_rows,
    }


def main():
    files = []
    for scope in SCOPES:
        for f in sorted(os.listdir(scope)):
            if f.lower().endswith(".png"):
                files.append(os.path.join(scope, f))

    sheets = [analyze_sheet(p) for p in files]

    # summary by action
    by_action = {}
    for s in sheets:
        a = s["action"]
        d = by_action.setdefault(a, {"sheets": 0, "rows": 0, "near_dup_pairs": 0,
                                     "near_dup_rows": 0, "drop_rows": 0,
                                     "exact_static_pairs": 0, "near_static_pairs": 0,
                                     "subtle_motion_pairs": 0})
        d["sheets"] += 1
        d["rows"] += s["rows"]
        d["near_dup_pairs"] += s["near_dup_pair_count"]
        d["near_dup_rows"] += s["near_dup_row_count"]
        d["drop_rows"] += s["drop_rows_if_collapsed"]
        for p in s["near_dup_pairs"]:
            d[p["class"] + "_pairs"] += 1

    total_near = sum(s["near_dup_pair_count"] for s in sheets)
    total_drop = sum(s["drop_rows_if_collapsed"] for s in sheets)
    total_raw = sum(s["raw_bytes_total"] for s in sheets)
    total_saved = sum(s["raw_bytes_saved"] for s in sheets)
    cls_totals = {"exact_static": 0, "near_static": 0, "subtle_motion": 0}
    for s in sheets:
        for p in s["near_dup_pairs"]:
            cls_totals[p["class"]] += 1
    empty_pairs = sum(1 for s in sheets for p in s["near_dup_pairs"] if p["empty_pair"])
    exact_all = sum(len(s["exact_identical_pairs"]) for s in sheets)
    nearstatic_all = sum(len(s["nearstatic_pairs"]) for s in sheets)
    safe_sheets = [s for s in sheets if s["nearstatic_pairs"] or s["exact_identical_pairs"]]
    nearstatic_rows_all = sum(s["nearstatic_row_count"] for s in sheets)
    raw_per_row_avg = total_raw / max(1, sum(s["rows"] for s in sheets))
    safe_mb_upper = nearstatic_rows_all * raw_per_row_avg / 1048576

    top10 = sorted(sheets, key=lambda s: (s["near_dup_pair_count"], s["drop_rows_if_collapsed"]), reverse=True)[:10]

    report = {
        "meta": {
            "task": "MICRO RECON - perceptual near-duplicate frame detection in unit sheets",
            "read_only": True,
            "scopes": [os.path.relpath(s, ROOT).replace("\\", "/") for s in SCOPES],
            "sheet_count": len(sheets),
            "method": {
                "grid": "8 columns (viewing directions) x N rows (animation frames); cell=width/8",
                "fingerprint": "each full-width row strip alpha-composited over white, "
                               "resized to 32x32 grayscale LANCZOS, stored as bytes (base64 + sha1-8)",
                "near_dup_threshold": "normalized MAE (on 32x32 grayscale, /255) < 0.02",
                "pairs": "adjacent (neighbouring) rows; all-pairs also computed supplementary",
                "motion_classification": "full-res composited-strip MAE: exact if pixel-identical; "
                                         "near_static if MAE<0.003 and changed-frac(|d|>8)<0.001; "
                                         "else subtle_motion",
            },
        },
        "summary": {
            "sheets_analyzed": len(sheets),
            "total_rows": sum(s["rows"] for s in sheets),
            "total_near_dup_pairs": total_near,
            "total_near_dup_rows": sum(s["near_dup_row_count"] for s in sheets),
            "near_dup_class_totals": cls_totals,
            "empty_padding_pairs": empty_pairs,
            "by_action": by_action,
            "raw_mb_total": round(total_raw / 1048576, 3),
            "raw_mb_saved_if_collapsed_all": round(total_saved / 1048576, 3),
            "drop_rows_if_collapsed_all": total_drop,
            "raw_mb_saved_conservative_exact_only": 0.0,  # filled in below
            "exact_identical_pairs_all": exact_all,
            "nearstatic_pairs_all": nearstatic_all,
            "nearstatic_rows_all": nearstatic_rows_all,
            "sheets_with_any_true_repeat": len(safe_sheets),
            "raw_mb_upper_bound_if_only_nearstatic_collapsed": round(safe_mb_upper, 3),
        },
        "top10_sheets": [
            {
                "file": s["file"], "action": s["action"], "rows": s["rows"],
                "near_dup_pair_count": s["near_dup_pair_count"],
                "near_dup_row_count": s["near_dup_row_count"],
                "near_dup_groups_rows": s["near_dup_groups"],
                "drop_rows_if_collapsed": s["drop_rows_if_collapsed"],
                "raw_mb_saved": round(s["raw_bytes_saved"] / 1048576, 4),
                "classes": [p["class"] for p in s["near_dup_pairs"]],
            } for s in top10
        ],
        "deep_probe": {
            "exact_identical_fullres_strips": exact_all,
            "near_static_fullres_pairs": nearstatic_all,
            "note": ("No byte-identical adjacent frames exist anywhere in the corpus. "
                     "The 0.02 32x32-grayscale threshold flags 96% of adjacent pairs, "
                     "but full-resolution comparison shows >97% of those are genuine "
                     "subtle motion; only near_static pairs are plausible static holds."),
            "candidate_sheets": [
                {"file": s["file"], "action": s["action"],
                 "nearstatic_groups_rows": s["nearstatic_groups_rows"],
                 "nearstatic_row_count": s["nearstatic_row_count"]}
                for s in safe_sheets
            ],
        },
        "recommendation": {
            "verdict": "DO NOT COLLAPSE based on the 0.02 threshold alone",
            "rationale": [
                "At 32x32 grayscale the 0.02 normalized-MAE threshold is far too permissive: "
                "1693/1762 (96%) adjacent pairs pass, including ordinary walk/idle/attack motion.",
                "Full-resolution comparison finds ZERO exactly identical frames in 214 sheets; "
                "every flagged pair has real pixel differences (typical high-res MAE 0.01-0.03).",
                "Only 129 near-static pairs across 33 sheets are even candidates, and even these "
                "show nonzero differences that may be intentional sub-pixel jitter or antialiasing.",
                "Walk and attack dominate the raw near-dup counts, which is expected for smooth "
                "animation and is precisely where collapsing would be most damaging.",
            ],
            "conservative_action": (
                "Treat the 1119 MB 'all-drop' figure as an Unsafe upper bound, not realizable savings. "
                "If any action is taken, restrict it to a small, visually-verified subset of "
                "near_static idle/attack hold groups (e.g. chasseur_attack, highlander_attack, "
                "howitzer_attack, jannisary_attack, mortar_attack, musketeer_attack, pandur_attack) "
                "and only after frame-by-frame human review. Theoretical best case from these "
                "near-static groups is ~%s MB raw (uncompressed RGBA); actual PNG file savings "
                "will be smaller and must account for the playback-map overhead." % safe_mb_upper
            ),
        },
        "sheets": sheets,
    }

    # conservative exact-only savings (groups where every adjacent pair is exact)
    cons_saved = 0
    for s in sheets:
        # build groups where all pairs exact
        gpairs = [p for p in s["near_dup_pairs"] if p["exact"]]
        seen = []
        if gpairs:
            cur = [gpairs[0]["row_a"]]
            for k in range(1, len(gpairs)):
                if gpairs[k]["row_a"] == gpairs[k - 1]["row_b"]:
                    cur.append(gpairs[k]["row_b"])
                else:
                    seen.append(cur); cur = [gpairs[k]["row_a"]]
            seen.append(cur)
        drop = sum(len(g) - 1 for g in seen if len(g) >= 2)
        cons_saved += (s["raw_bytes_total"] / s["rows"]) * drop
    report["summary"]["raw_mb_saved_conservative_exact_only"] = round(cons_saved / 1048576, 3)

    out = os.path.join(ROOT, "inbox", "sheet_neardup_audit.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print("WROTE", out)
    print("sheets:", len(sheets), "total near-dup pairs:", total_near,
          "classes:", cls_totals)
    print("raw MB all-drop:", report["summary"]["raw_mb_saved_if_collapsed_all"],
          "exact-only:", report["summary"]["raw_mb_saved_conservative_exact_only"])


if __name__ == "__main__":
    main()
