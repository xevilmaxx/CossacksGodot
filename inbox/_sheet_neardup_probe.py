#!/usr/bin/env python3
"""Deeper probe: characterize true static/repeated frames vs subtle motion.
Read-only companion to _sheet_neardup_analysis.py.
"""
import os
from PIL import Image
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCOPES = [
    os.path.join(ROOT, "app", "assets", "models", "anim", "common", "units"),
    os.path.join(ROOT, "app", "assets", "models", "anim", "sco", "units"),
]
files = [os.path.join(s, f) for s in SCOPES for f in sorted(os.listdir(s)) if f.lower().endswith(".png")]

# accumulate fp_mae distribution for ALL adjacent pairs, and high-res stats
fp_vals = []
hr_vals = []
changed_vals = []
exact_adj = 0
exact_nonadj = 0
nearstatic_adj = 0
nearstatic_nonadj = 0
safe_sheets = []
total_adj = 0

for path in files:
    with Image.open(path) as im:
        sheet = im.convert("RGBA")
    w, h = sheet.size
    cell = w // 8
    rows = h // cell
    name = os.path.basename(path)
    full = []
    fps = []
    for r in range(rows):
        strip = sheet.crop((0, r * cell, w, (r + 1) * cell))
        bg = Image.new("RGBA", strip.size, (255, 255, 255, 255))
        comp = Image.alpha_composite(bg, strip).convert("L")
        full.append(np.asarray(comp, dtype=np.int16))
        fps.append(np.asarray(comp.resize((32, 32), Image.LANCZOS), dtype=np.int16))
    exact_groups = []
    sheet_exact_pairs = 0
    sheet_nearstatic_pairs = 0
    for i in range(rows):
        for j in range(i + 1, rows):
            d = np.abs(full[i] - full[j])
            if d.max() == 0:
                if j == i + 1:
                    exact_adj += 1
                else:
                    exact_nonadj += 1
                sheet_exact_pairs += 1
                exact_groups.append((i, j))
            else:
                hm = float(d.mean() / 255.0)
                cf = float((d > 8).mean())
                if hm < 0.003 and cf < 0.001:
                    if j == i + 1:
                        nearstatic_adj += 1
                    else:
                        nearstatic_nonadj += 1
                    sheet_nearstatic_pairs += 1
        if i < rows - 1:
            fp_vals.append(float(np.abs(fps[i] - fps[i + 1]).mean() / 255.0))
    if sheet_exact_pairs or sheet_nearstatic_pairs:
        safe_sheets.append((name, rows, sheet_exact_pairs, sheet_nearstatic_pairs, exact_groups[:8]))

fp_vals = np.array(fp_vals)
print("files:", len(files))
print("adjacent pairs total:", len(fp_vals))
print("fp_mae distribution (normalized):")
for p in (0, 1, 5, 25, 50, 75, 95, 99, 100):
    print("  p%-3d = %.6f" % (p, np.percentile(fp_vals, p)))
print("adjacent pairs with fp_mae < 0.02:", int((fp_vals < 0.02).sum()), "/", len(fp_vals))
print("adjacent pairs with fp_mae < 0.005:", int((fp_vals < 0.005).sum()))
print("adjacent pairs with fp_mae < 0.002:", int((fp_vals < 0.002).sum()))
print()
print("EXACT identical full-res strips: adjacent=", exact_adj, " non-adjacent=", exact_nonadj)
print("NEAR-STATIC full-res strips:     adjacent=", nearstatic_adj, " non-adjacent=", nearstatic_nonadj)
print()
print("Sheets with any exact/near-static repeat:", len(safe_sheets))
for n, r, e, ns, eg in safe_sheets[:40]:
    print("  %-42s rows=%-3d exact=%-3d nearstatic=%-3d eg=%s" % (n, r, e, ns, eg))
