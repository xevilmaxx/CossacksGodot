"""
MICRO RECON (read-only): measure PNG bloat from hidden RGB noise under alpha==0.

Scope: 1849 RGBA sprite sheets under app/assets/models/anim.
Samples 60 sheets (largest-first + random across strata), zeroes RGB where
alpha==0, re-saves with the same (Pillow default) settings and compares bytes.
No asset files are modified; all re-saves go to a temporary directory.
"""
import os, glob, json, random, tempfile, statistics, datetime, subprocess

ROOT = os.path.dirname(os.path.abspath(__file__))
ANIM = os.path.join(ROOT, "app", "assets", "models", "anim")
OUT = os.path.join(ROOT, "inbox", "alpha_noise_audit.json")

import numpy as np
from PIL import Image

# ---- enumerate all sheets and classify into strata -----------------------
all_files = sorted(glob.glob(os.path.join(ANIM, "**", "*.png"), recursive=True))

def stratum(rel):
    p = rel.replace("\\", "/")
    if p.startswith("common/units/"):
        return "common/units"
    if p.startswith("common/naval/"):
        return "common/naval"
    if p.startswith("common/"):
        return "common/other"
    parts = p.split("/")
    if len(parts) >= 3:
        if parts[1] == "units":
            return "nation units"
        if parts[1] == "buildings":
            return "nation buildings"
    return "other"

records = []
for f in all_files:
    rel = os.path.relpath(f, ANIM)
    records.append({
        "path": f,
        "rel": rel.replace("\\", "/"),
        "stratum": stratum(rel),
        "size": os.path.getsize(f),
    })

by_stratum = {}
for r in records:
    by_stratum.setdefault(r["stratum"], []).append(r)

# ---- deterministic sampling: largest-first + random, stratified ----------
# 60 total: naval gets all 12; units/common split the remainder.
random.seed(20261123)
def pick(group, n_large, n_random):
    g = sorted(group, key=lambda r: (-r["size"], r["rel"]))
    chosen = g[:n_large]
    rest = g[n_large:]
    k = min(n_random, len(rest))
    chosen += random.sample(rest, k)
    return chosen

plan = [
    ("common/units",   6,  6),   # 12
    ("common/naval",  12,  0),   # 12 (all)
    ("nation buildings", 9, 9), # 18
    ("nation units",   9,  9),   # 18
]
sample = []
for name, nl, nr in plan:
    grp = by_stratum.get(name, [])
    sample.extend(pick(grp, nl, nr))

assert len(sample) == 60, len(sample)

# ---- per-file measurement -------------------------------------------------
def measure(rec, tmpdir, control=False):
    im = Image.open(rec["path"])
    im.load()
    arr = np.asarray(im.convert("RGBA")).copy()
    alpha = arr[:, :, 3]
    total = alpha.size
    a0 = alpha == 0
    a255 = alpha == 255
    semi = (alpha > 0) & (alpha < 255)
    n_a0 = int(a0.sum())
    n_semi = int(semi.sum())
    rgb = arr[:, :, :3]
    noisy = a0 & np.any(rgb != 0, axis=2)
    n_noisy = int(noisy.sum())

    before = rec["size"]
    resaved = None
    after = None
    with tempfile.NamedTemporaryFile(suffix=".png", dir=tmpdir, delete=False) as tf:
        ctrl_path = tf.name
    with tempfile.NamedTemporaryFile(suffix=".png", dir=tmpdir, delete=False) as tf:
        zero_path = tf.name
    try:
        # Control: re-save the untouched image with identical encoder settings.
        Image.fromarray(arr).save(ctrl_path, "PNG")
        resaved = os.path.getsize(ctrl_path)
        # Zeroed: RGB=0 only where alpha==0; semi/trans untouched by construction.
        arr2 = arr.copy()
        arr2[a0, :3] = 0
        Image.fromarray(arr2).save(zero_path, "PNG")
        after = os.path.getsize(zero_path)
    finally:
        for p in (ctrl_path, zero_path):
            try: os.remove(p)
            except OSError: pass

    return {
        "rel": rec["rel"],
        "stratum": rec["stratum"],
        "size": rec["size"],
        "mode": im.mode,
        "dimensions": list(im.size),
        "total_pixels": int(total),
        "alpha0_pixels": n_a0,
        "alpha0_fraction": n_a0 / total,
        "hidden_noise_pixels": n_noisy,
        "hidden_noise_fraction_of_alpha0": (n_noisy / n_a0) if n_a0 else 0.0,
        "opaque_pixels": int(a255.sum()),
        "semi_transparent_pixels": n_semi,
        "bytes_before": before,
        "bytes_resave_control": resaved,
        "bytes_after": after,
        "bytes_saved_vs_original": before - after,
        "bytes_saved_vs_control": resaved - after,
        "pct_saved_vs_original": 100.0 * (before - after) / before,
        "pct_saved_vs_control": 100.0 * (resaved - after) / resaved,
    }

with tempfile.TemporaryDirectory(prefix="alpha_noise_", dir=os.environ.get("TEMP", None)) as td:
    results = [measure(r, td) for r in sample]

# ---- aggregate ------------------------------------------------------------
tot_before = sum(r["bytes_before"] for r in results)
tot_after = sum(r["bytes_after"] for r in results)
tot_ctrl = sum(r["bytes_resave_control"] for r in results)
saved_orig = tot_before - tot_after
saved_ctrl = tot_ctrl - tot_after

top15 = sorted(results, key=lambda r: -r["bytes_saved_vs_original"])[:15]

# Pearson correlation: transparent fraction vs saving fraction (vs original).
xs = np.array([r["alpha0_fraction"] for r in results], dtype=float)
ys = np.array([r["pct_saved_vs_original"] for r in results], dtype=float)
if xs.std() > 0 and ys.std() > 0:
    pearson = float(np.corrcoef(xs, ys)[0, 1])
else:
    pearson = None
ys2 = np.array([r["pct_saved_vs_control"] for r in results], dtype=float)
if xs.std() > 0 and ys2.std() > 0:
    pearson_ctrl = float(np.corrcoef(xs, ys2)[0, 1])
else:
    pearson_ctrl = None

# Also correlate hidden-noise pixel count with savings (bytes).
nz = np.array([r["hidden_noise_pixels"] for r in results], dtype=float)
sv = np.array([r["bytes_saved_vs_original"] for r in results], dtype=float)
pearson_noise_save = float(np.corrcoef(nz, sv)[0, 1]) if nz.std() > 0 and sv.std() > 0 else None

# ---- project-wide estimate ------------------------------------------------
all_bytes = sum(r["size"] for r in records)
scale_orig = tot_before / all_bytes if all_bytes else 0
est_saved_orig = saved_orig / scale_orig if scale_orig else 0
est_after_orig = all_bytes - est_saved_orig
scale_ctrl = tot_ctrl / all_bytes if all_bytes else 0
est_saved_ctrl = saved_ctrl / scale_ctrl if scale_ctrl else 0

# ---- semi-transparency check across ALL 1849 sheets -----------------------
semi_files = []
semi_total_pixels = 0
for r in records:
    im = Image.open(r["path"])
    im.load()
    a = np.asarray(im.convert("RGBA"))[:, :, 3]
    n = int(((a > 0) & (a < 255)).sum())
    if n:
        semi_files.append({"rel": r["rel"], "semi_transparent_pixels": n})
        semi_total_pixels += n

report = {
    "audit": "PNG hidden-RGB-noise-under-alpha=0 bloat audit (read-only)",
    "generated": datetime.datetime.now().isoformat(timespec="seconds"),
    "scope": {
        "root": os.path.relpath(ANIM, ROOT).replace("\\", "/"),
        "total_pngs": len(records),
        "total_bytes": all_bytes,
        "strata_counts": {k: len(v) for k, v in sorted(by_stratum.items())},
    },
    "methodology": {
        "sample_size": len(sample),
        "sampling": "stratified largest-first + seeded random (seed=20261123): "
                    "common/units 6L+6R, common/naval 12(all), "
                    "nation buildings 9L+9R, nation units 9L+9R",
        "noise_definition": "pixel with alpha==0 and RGB != (0,0,0)",
        "fix": "set RGB=(0,0,0) ONLY where alpha==0; all other pixels (including "
               "semi-transparent 0<alpha<255) preserved byte-for-byte in value",
        "encoder": "Pillow PNG, default settings (no optimize) - matches the bake "
                   "scripts' plain save()/render output; before=original file bytes, "
                   "after=zeroed re-save bytes, control=untouched re-save bytes",
        "control_purpose": "isolate encoder/metadata re-save overhead from the "
                           "true zeroing effect (saved_vs_control)",
        "asset_edits": "none; all re-saves written to a temp dir then deleted",
        "libraries": {
            "python": subprocess.check_output(["python", "--version"]).decode().strip(),
            "pillow": __import__("PIL").__version__,
            "numpy": np.__version__,
        },
    },
    "sample_totals": {
        "bytes_before": tot_before,
        "bytes_resave_control": tot_ctrl,
        "bytes_after": tot_after,
        "bytes_saved_vs_original": saved_orig,
        "bytes_saved_vs_control": saved_ctrl,
        "pct_saved_vs_original": 100.0 * saved_orig / tot_before,
        "pct_saved_vs_control": 100.0 * saved_ctrl / tot_ctrl,
        "resave_overhead_bytes": tot_ctrl - tot_before,
        "total_alpha0_pixels": sum(r["alpha0_pixels"] for r in results),
        "total_hidden_noise_pixels": sum(r["hidden_noise_pixels"] for r in results),
        "mean_alpha0_fraction": statistics.mean(xs.tolist()),
    },
    "top_15_by_saving": [
        {k: r[k] for k in ("rel", "stratum", "bytes_before", "bytes_after",
                           "bytes_saved_vs_original", "pct_saved_vs_original",
                           "bytes_saved_vs_control", "alpha0_fraction",
                           "hidden_noise_pixels")}
        for r in top15
    ],
    "correlation": {
        "pearson_transparent_fraction_vs_pct_saved_vs_original": pearson,
        "pearson_transparent_fraction_vs_pct_saved_vs_control": pearson_ctrl,
        "pearson_hidden_noise_pixels_vs_bytes_saved": pearson_noise_save,
        "n": len(sample),
    },
    "project_wide_estimate": {
        "method": "scale sample savings ratio to all 1849 PNGs' total bytes",
        "all_pngs_total_bytes": all_bytes,
        "sample_coverage_bytes_fraction": scale_orig,
        "estimated_bytes_saved_vs_original": est_saved_orig,
        "estimated_bytes_after_original_baseline": est_after_orig,
        "estimated_pct_saved_vs_original": 100.0 * saved_orig / tot_before,
        "estimated_bytes_saved_vs_control_baseline": est_saved_ctrl,
        "estimated_mb_saved_vs_original": est_saved_orig / (1024 * 1024),
        "caveat": "extrapolation from 60 of 1849 sheets (3.2%); per-stratum mix "
                  "and file sizes vary, treat as order-of-magnitude estimate",
    },
    "semi_transparency": {
        "checked_files": len(records),
        "files_with_semi_transparent_pixels": len(semi_files),
        "total_semi_transparent_pixels": semi_total_pixels,
        "files": semi_files,
        "note": "zeroing is gated strictly on alpha==0, so any semi-transparent "
                "pixel is preserved exactly; if this list is empty no sheet uses "
                "semi-transparency and full RGB zeroing under alpha==0 is lossless",
    },
    "per_file_sample": results,
}

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w", encoding="utf-8") as fh:
    json.dump(report, fh, indent=2)

# ---- console summary ------------------------------------------------------
print("SAMPLE", len(sample), "of", len(records), "PNGs")
print("before bytes :", tot_before)
print("control bytes:", tot_ctrl, "(re-save overhead:", tot_ctrl - tot_before, ")")
print("after bytes  :", tot_after)
print("saved vs orig:", saved_orig, "(%.3f%%)" % (100.0 * saved_orig / tot_before))
print("saved vs ctrl:", saved_ctrl, "(%.3f%%)" % (100.0 * saved_ctrl / tot_ctrl))
print("pearson(transfrac, pct_saved_orig):", pearson)
print("pearson(transfrac, pct_saved_ctrl):", pearson_ctrl)
print("pearson(noise_px, bytes_saved):", pearson_noise_save)
print("est project saved vs orig:", round(est_saved_orig), "bytes =", round(est_saved_orig / 1048576, 2), "MB")
print("semi-transparent files (all 1849):", len(semi_files), "total semi px:", semi_total_pixels)
print("TOP 15")
for r in top15:
    print("  %9d  %6.2f%%  a0=%.3f  %s" % (
        r["bytes_saved_vs_original"], r["pct_saved_vs_original"],
        r["alpha0_fraction"], r["rel"]))
print("WROTE", OUT)
