#!/usr/bin/env python3
"""
normalize_alpha_noise.py -- reversible PNG alpha-noise normalizer.

Zeroes hidden RGB noise strictly where alpha == 0 in every sprite sheet under
``app/assets/models/anim/**/*.png``. Semi-transparent pixels (0 < alpha < 255)
and opaque pixels are preserved byte-for-byte in value. After the PNG is
rewritten, the Godot import-cache companion ``.md5`` file has only its
``source_md5`` patched to md5(new PNG bytes); ``dest_md5`` and the ``.ctex``
are left untouched (the visible image is identical, so no reimport is needed).

Four modes (default is --dry-run, which never writes a PNG):

    python app/tools/normalize_alpha_noise.py --dry-run
    python app/tools/normalize_alpha_noise.py --apply
    python app/tools/normalize_alpha_noise.py --verify
    python app/tools/normalize_alpha_noise.py --rollback

Outputs (all under inbox/ except the backup tree, which lives in %TEMP%):

    inbox/alpha_norm_plan.json   -- per-file dry-run report (old/new size+md5,
                                    semi-transparent count, md5-cache path)
    inbox/alpha_norm_undo.json   -- exact reverse ops written by --apply
    inbox/alpha_norm_verify.json -- report written by --verify
    inbox/alpha_norm_rollback.json -- report written by --rollback
    %TEMP%/opencode/alpha_norm_backup/<path-relative-to-app>/<file>.png
                                 -- original PNG bytes for every backed-up file

Only Python stdlib + Pillow are used. No Godot jobs are spawned.

Note on the audit's ~17 MB projection: inbox/alpha_noise_audit.json scaled a
60-file sample to the whole tree. That sample under-weighted the 1524 building
sheets (which save ~13.7%) and over-weighted nation units (~1.2%), so its
5.3% / ~17 MB figure is a low extrapolation. This tool measures all 1849 files
exactly and reports the true full-tree saving (~50.5 MB / 16.4%). Its PNG
encoding was verified byte-identical to the audit's numpy method across all
strata.

Godot cache naming (verified against the tree):
    rel = path of PNG relative to app/, with forward slashes
    h   = md5(("res://" + rel).encode("utf-8")).hexdigest()
    cache = app/.godot/imported/<basename>-<h>.md5
The companion file contains ``source_md5="<hex>"`` and ``dest_md5="<hex>"``.
"""

import argparse
import datetime
import hashlib
import io
import json
import os
import pathlib
import shutil
import sys
import tempfile
import time

from PIL import Image, ImageChops

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
HERE = pathlib.Path(__file__).resolve()
APP = HERE.parent.parent                       # .../app
ROOT = APP.parent                              # repository root
ANIM = APP / "assets" / "models" / "anim"
IMPORTED = APP / ".godot" / "imported"
INBOX = ROOT / "inbox"

PLAN_PATH = INBOX / "alpha_norm_plan.json"
UNDO_PATH = INBOX / "alpha_norm_undo.json"
VERIFY_PATH = INBOX / "alpha_norm_verify.json"
ROLLBACK_PATH = INBOX / "alpha_norm_rollback.json"

BACKUP_ROOT = pathlib.Path(tempfile.gettempdir()) / "opencode" / "alpha_norm_backup"

PROGRESS_EVERY = 200


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------
def now_iso():
    return datetime.datetime.now().isoformat(timespec="seconds")


def root_rel(p):
    """Root-relative path with forward slashes."""
    return pathlib.Path(p).relative_to(ROOT).as_posix()


def app_rel(p):
    """App-relative path with forward slashes (used by Godot's hash)."""
    return pathlib.Path(p).relative_to(APP).as_posix()


def md5_bytes(data):
    return hashlib.md5(data).hexdigest()


def cache_md5_path(png):
    """Deterministic Godot import-cache companion path for a PNG."""
    h = hashlib.md5(("res://" + app_rel(png)).encode("utf-8")).hexdigest()
    return IMPORTED / (png.name + "-" + h + ".md5")


def read_md5_pair(path):
    """Return (source_md5, dest_md5, raw_bytes) from a Godot .md5 file."""
    raw = path.read_bytes()
    src = dst = None
    for line in raw.decode("utf-8").splitlines():
        if line.startswith("source_md5="):
            src = line.split("=", 1)[1].strip().strip('"')
        elif line.startswith("dest_md5="):
            dst = line.split("=", 1)[1].strip().strip('"')
    return src, dst, raw


def patch_source_md5(path, new_hex, expected_old_hex=None):
    """Replace only the source_md5 hex value, leaving every other byte intact."""
    raw = path.read_bytes()
    prefix = b'source_md5="'
    i = raw.find(prefix)
    if i < 0:
        raise RuntimeError("no source_md5 field in " + str(path))
    start = i + len(prefix)
    j = raw.find(b'"', start)
    if j < 0:
        raise RuntimeError("unterminated source_md5 field in " + str(path))
    old_hex = raw[start:j].decode("ascii")
    if expected_old_hex is not None and old_hex != expected_old_hex:
        raise RuntimeError(
            "source_md5 mismatch in %s: expected %s, found %s"
            % (path, expected_old_hex, old_hex)
        )
    patched = raw[:start] + new_hex.encode("ascii") + raw[j:]
    path.write_bytes(patched)
    return old_hex


def iter_pngs(limit=0):
    files = sorted(p for p in ANIM.rglob("*.png") if p.is_file())
    if limit and limit > 0:
        files = files[:limit]
    return files


def image_stats(im):
    """
    Stats for an RGBA Pillow Image:
      alpha0_pixels, semi_transparent_pixels, opaque_pixels,
      hidden_noise_pixels (alpha == 0 AND RGB != (0,0,0)).
    """
    r, g, b, a = im.split()
    ah = a.histogram()
    alpha0 = ah[0]
    semi = sum(ah[1:255])
    opaque = ah[255]
    max_rgb = ImageChops.lighter(ImageChops.lighter(r, g), b)
    nonzero = max_rgb.point([0 if v == 0 else 255 for v in range(256)])
    a0_mask = a.point([255 if v == 0 else 0 for v in range(256)])
    noise = ImageChops.multiply(nonzero, a0_mask)
    hidden_noise = noise.histogram()[255]
    return {
        "alpha0_pixels": alpha0,
        "semi_transparent_pixels": semi,
        "opaque_pixels": opaque,
        "hidden_noise_pixels": hidden_noise,
    }


def zero_alpha0_rgb(png, data=None):
    """
    Return (new_png_bytes, stats).

    Re-encodes with Pillow's default PNG settings. RGB is set to (0,0,0) only
    where alpha == 0; all other pixel values are untouched. The output mode is
    RGBA. No metadata is copied (same encoder behaviour as the audit).
    """
    if data is None:
        data = pathlib.Path(png).read_bytes()
    with Image.open(io.BytesIO(data)) as src:
        mode = src.mode
        size = src.size
        im = src.convert("RGBA")
    stats = image_stats(im)
    stats["mode"] = mode
    stats["dimensions"] = list(size)

    r, g, b, a = im.split()
    a0_mask = a.point([255 if v == 0 else 0 for v in range(256)])
    black = Image.new("L", size, 0)
    r2 = Image.composite(black, r, a0_mask)
    g2 = Image.composite(black, g, a0_mask)
    b2 = Image.composite(black, b, a0_mask)
    out = Image.merge("RGBA", (r2, g2, b2, a))
    buf = io.BytesIO()
    out.save(buf, format="PNG")
    return buf.getvalue(), stats


def progress(i, total, label, extra=""):
    if i % PROGRESS_EVERY == 0 or i == total:
        print("  [%d/%d] %s %s" % (i, total, label, extra), flush=True)


def write_json(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


# ---------------------------------------------------------------------------
# --dry-run
# ---------------------------------------------------------------------------
def cmd_dry_run(limit):
    files = iter_pngs(limit)
    total = len(files)
    records = []
    print("DRY-RUN: measuring %d PNGs (no PNG will be modified)" % total, flush=True)
    t0 = time.time()

    for i, f in enumerate(files, 1):
        old_bytes = f.read_bytes()
        old_size = len(old_bytes)
        old_md5 = md5_bytes(old_bytes)
        new_bytes, stats = zero_alpha0_rgb(f, old_bytes)
        new_size = len(new_bytes)
        new_md5 = md5_bytes(new_bytes)

        cpath = cache_md5_path(f)
        cache_exists = cpath.exists()
        cache_src = cache_dst = None
        if cache_exists:
            cache_src, cache_dst, _ = read_md5_pair(cpath)

        records.append({
            "png": root_rel(f),
            "rel": f.relative_to(ANIM).as_posix(),
            "md5_cache": root_rel(cpath) if cache_exists else app_rel(cpath),
            "cache_exists": cache_exists,
            "cache_source_md5": cache_src,
            "cache_dest_md5": cache_dst,
            "cache_matches_png": (cache_src == old_md5) if cache_exists else False,
            "old_size": old_size,
            "new_size": new_size,
            "saving": old_size - new_size,
            "old_md5": old_md5,
            "new_md5": new_md5,
            **stats,
        })
        progress(i, total, "measured")

    old_total = sum(r["old_size"] for r in records)
    new_total = sum(r["new_size"] for r in records)
    saving = old_total - new_total
    top20 = sorted(records, key=lambda r: (-r["saving"], r["png"]))[:20]

    report = {
        "task": "T-ALPHA-NORM dry-run (read-only; no PNG modified)",
        "created_local": now_iso(),
        "source_root": root_rel(ANIM),
        "note": "new_size/new_md5 are the exact bytes Pillow would write when "
                "RGB is zeroed strictly where alpha==0; semi-transparent and "
                "opaque pixel values are preserved.",
        "file_count": total,
        "old_bytes_total": old_total,
        "new_bytes_total": new_total,
        "saving_bytes_total": saving,
        "saving_mb": saving / (1024 * 1024),
        "saving_pct": (100.0 * saving / old_total) if old_total else 0.0,
        "total_hidden_noise_pixels": sum(r["hidden_noise_pixels"] for r in records),
        "total_semi_transparent_pixels": sum(r["semi_transparent_pixels"] for r in records),
        "files_with_hidden_noise": sum(1 for r in records if r["hidden_noise_pixels"]),
        "files_with_semi_transparent_pixels": sum(
            1 for r in records if r["semi_transparent_pixels"]),
        "cache_missing_files": sum(1 for r in records if not r["cache_exists"]),
        "cache_source_md5_mismatches": sum(
            1 for r in records if r["cache_exists"] and not r["cache_matches_png"]),
        "top_20_by_saving": [
            {k: r[k] for k in ("png", "old_size", "new_size", "saving",
                               "hidden_noise_pixels", "alpha0_pixels")}
            for r in top20
        ],
        "files": records,
    }
    write_json(PLAN_PATH, report)

    print("\nDRY-RUN COMPLETE in %.1fs" % (time.time() - t0), flush=True)
    print("  files            : %d" % total)
    print("  old bytes total  : %d" % old_total)
    print("  new bytes total  : %d" % new_total)
    print("  would-be saving  : %d bytes = %.2f MB (%.3f%%)"
          % (saving, saving / (1024 * 1024), report["saving_pct"]))
    print("  hidden-noise px  : %d across %d files"
          % (report["total_hidden_noise_pixels"], report["files_with_hidden_noise"]))
    print("  semi-transparent : %d px across %d files"
          % (report["total_semi_transparent_pixels"],
             report["files_with_semi_transparent_pixels"]))
    print("  cache missing    : %d ; cache md5 mismatches: %d"
          % (report["cache_missing_files"], report["cache_source_md5_mismatches"]))
    print("  TOP 20 BY SAVING")
    for r in top20:
        print("    %9d  %6.2f%%  %s"
              % (r["saving"],
                 100.0 * r["saving"] / r["old_size"] if r["old_size"] else 0.0,
                 r["png"]))
    print("  WROTE " + root_rel(PLAN_PATH), flush=True)
    return report


# ---------------------------------------------------------------------------
# --apply
# ---------------------------------------------------------------------------
def cmd_apply(limit):
    files = iter_pngs(limit)
    total = len(files)
    print("APPLY: backing up, rewriting and patching %d PNGs" % total, flush=True)

    # Seed the undo log now so a crash at any later point is recoverable.
    undo = {
        "task": "T-ALPHA-NORM apply undo log",
        "created_local": now_iso(),
        "backup_root": str(BACKUP_ROOT),
        "source_root": root_rel(ANIM),
        "count": 0,
        "files": [],
    }
    write_json(UNDO_PATH, undo)

    t0 = time.time()
    saving = 0
    changed = 0
    for i, f in enumerate(files, 1):
        old_bytes = f.read_bytes()
        old_md5 = md5_bytes(old_bytes)
        new_bytes, stats = zero_alpha0_rgb(f, old_bytes)
        new_md5 = md5_bytes(new_bytes)

        cpath = cache_md5_path(f)
        if not cpath.exists():
            raise RuntimeError("missing cache companion: " + str(cpath))
        cache_src, cache_dst, _ = read_md5_pair(cpath)
        if cache_src != old_md5:
            raise RuntimeError(
                "cache source_md5 != md5(PNG) for %s; refusing to patch "
                "(run --verify first)" % f
            )

        # 1) back up the original bytes (outside the repository)
        backup_path = BACKUP_ROOT / app_rel(f)
        backup_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(f, backup_path)

        # 2) rewrite the PNG
        f.write_bytes(new_bytes)

        # 3) patch only source_md5; dest_md5 and the .ctex stay as-is
        patch_source_md5(cpath, new_md5, expected_old_hex=old_md5)

        is_changed = new_bytes != old_bytes
        if is_changed:
            changed += 1
        saving += len(old_bytes) - len(new_bytes)

        undo["files"].append({
            "png": root_rel(f),
            "backup": str(backup_path),
            "md5_cache": root_rel(cpath),
            "old_size": len(old_bytes),
            "new_size": len(new_bytes),
            "old_md5": old_md5,
            "new_md5": new_md5,
            "old_source_md5": cache_src,
            "new_source_md5": new_md5,
            "dest_md5": cache_dst,
            "changed": is_changed,
            **stats,
        })
        undo["count"] = len(undo["files"])

        if i % PROGRESS_EVERY == 0:
            write_json(UNDO_PATH, undo)  # crash-safe partial log
            progress(i, total, "applied")
    write_json(UNDO_PATH, undo)

    print("\nAPPLY COMPLETE in %.1fs" % (time.time() - t0), flush=True)
    print("  rewritten        : %d files (%d byte-changed)" % (total, changed))
    print("  bytes saved      : %d (%.2f MB)" % (saving, saving / (1024 * 1024)))
    print("  backup root      : %s" % BACKUP_ROOT)
    print("  WROTE " + root_rel(UNDO_PATH), flush=True)


# ---------------------------------------------------------------------------
# --rollback
# ---------------------------------------------------------------------------
def cmd_rollback():
    if not UNDO_PATH.exists():
        raise RuntimeError("no undo log at " + str(UNDO_PATH))
    undo = json.loads(UNDO_PATH.read_text(encoding="utf-8"))
    entries = undo.get("files", [])
    total = len(entries)
    print("ROLLBACK: restoring %d PNGs from %s" % (total, undo.get("backup_root")),
          flush=True)
    t0 = time.time()
    restored = 0
    for i, e in enumerate(entries, 1):
        png = ROOT / e["png"]
        backup = pathlib.Path(e["backup"])
        if not backup.exists():
            raise RuntimeError("backup missing: " + str(backup))
        shutil.copy2(backup, png)

        cpath = ROOT / e["md5_cache"]
        patch_source_md5(
            cpath, e["old_source_md5"], expected_old_hex=e["new_source_md5"]
        )
        restored += 1
        progress(i, total, "restored")

    report = {
        "task": "T-ALPHA-NORM rollback report",
        "created_local": now_iso(),
        "restored_files": restored,
        "from_undo": root_rel(UNDO_PATH),
    }
    write_json(ROLLBACK_PATH, report)
    print("\nROLLBACK COMPLETE in %.1fs: restored %d files"
          % (time.time() - t0, restored), flush=True)
    print("  WROTE " + root_rel(ROLLBACK_PATH), flush=True)


# ---------------------------------------------------------------------------
# --verify
# ---------------------------------------------------------------------------
def cmd_verify():
    if not PLAN_PATH.exists():
        raise RuntimeError("no plan at " + str(PLAN_PATH))
    plan = json.loads(PLAN_PATH.read_text(encoding="utf-8"))
    entries = plan.get("files", [])
    total = len(entries)
    print("VERIFY: checking %d PNGs against plan" % total, flush=True)
    t0 = time.time()

    residual_files = 0
    residual_pixels = 0
    semi_mismatches = 0
    md5_mismatches = 0
    cache_missing = 0
    mode_mismatches = 0
    achieved_saving = 0
    problems = []

    for i, e in enumerate(entries, 1):
        png = ROOT / e["png"]
        data = png.read_bytes()
        cur_md5 = md5_bytes(data)
        with Image.open(io.BytesIO(data)) as src:
            mode = src.mode
            im = src.convert("RGBA")
        stats = image_stats(im)

        if mode != "RGBA":
            mode_mismatches += 1
            problems.append((e["png"], "mode", mode))

        if stats["hidden_noise_pixels"] != 0:
            residual_files += 1
            residual_pixels += stats["hidden_noise_pixels"]
            problems.append((e["png"], "residual_noise",
                             stats["hidden_noise_pixels"]))

        if stats["semi_transparent_pixels"] != e["semi_transparent_pixels"]:
            semi_mismatches += 1
            problems.append((e["png"], "semi",
                             "%d != %d" % (stats["semi_transparent_pixels"],
                                           e["semi_transparent_pixels"])))

        cpath = ROOT / e["md5_cache"]
        if not cpath.exists():
            cache_missing += 1
            problems.append((e["png"], "cache_missing", ""))
        else:
            cache_src, _, _ = read_md5_pair(cpath)
            if cache_src != cur_md5:
                md5_mismatches += 1
                problems.append((e["png"], "source_md5",
                                 "%s != %s" % (cache_src, cur_md5)))

        achieved_saving += e["old_size"] - len(data)
        progress(i, total, "verified")

    ok = (residual_files == 0 and residual_pixels == 0 and semi_mismatches == 0
          and md5_mismatches == 0 and cache_missing == 0 and mode_mismatches == 0)
    report = {
        "task": "T-ALPHA-NORM verify report",
        "created_local": now_iso(),
        "files_checked": total,
        "ok": ok,
        "files_with_residual_alpha0_noise": residual_files,
        "residual_noise_pixels": residual_pixels,
        "semi_transparent_mismatches": semi_mismatches,
        "cache_source_md5_mismatches": md5_mismatches,
        "cache_missing": cache_missing,
        "mode_mismatches": mode_mismatches,
        "achieved_saving_bytes": achieved_saving,
        "achieved_saving_mb": achieved_saving / (1024 * 1024),
        "problems": problems[:200],
    }
    write_json(VERIFY_PATH, report)

    print("\nVERIFY COMPLETE in %.1fs" % (time.time() - t0), flush=True)
    print("  files checked          : %d" % total)
    print("  residual alpha0 noise  : %d files / %d px"
          % (residual_files, residual_pixels))
    print("  semi-transparent diffs : %d" % semi_mismatches)
    print("  cache md5 mismatches   : %d" % md5_mismatches)
    print("  cache missing          : %d" % cache_missing)
    print("  mode mismatches        : %d" % mode_mismatches)
    print("  achieved saving        : %d bytes (%.2f MB)"
          % (achieved_saving, achieved_saving / (1024 * 1024)))
    print("  RESULT                 : %s" % ("PASS" if ok else "FAIL"), flush=True)
    print("  WROTE " + root_rel(VERIFY_PATH), flush=True)
    return ok


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Reversible PNG alpha-noise normalizer (stdlib + Pillow)."
    )
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--dry-run", action="store_true",
                   help="measure would-be savings only (default); no PNG is modified")
    g.add_argument("--apply", action="store_true",
                   help="back up, rewrite PNGs and patch Godot .md5 source_md5")
    g.add_argument("--rollback", action="store_true",
                   help="restore PNGs from backup and original source_md5 values")
    g.add_argument("--verify", action="store_true",
                   help="check normalization, semi counts and cache md5 consistency")
    ap.add_argument("--limit", type=int, default=0,
                    help="process only the first N PNGs (0 = all); useful for testing")
    args = ap.parse_args(argv)

    mode = "dry-run"
    if args.apply:
        mode = "apply"
    elif args.rollback:
        mode = "rollback"
    elif args.verify:
        mode = "verify"

    if not ANIM.is_dir():
        print("ERROR: anim root not found: %s" % ANIM, file=sys.stderr)
        return 2

    if mode == "dry-run":
        cmd_dry_run(args.limit)
        return 0
    if mode == "apply":
        cmd_apply(args.limit)
        return 0
    if mode == "rollback":
        cmd_rollback()
        return 0
    if mode == "verify":
        return 0 if cmd_verify() else 1
    return 2


if __name__ == "__main__":
    sys.exit(main())
