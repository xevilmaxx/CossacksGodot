#!/usr/bin/env python3
"""Migration executor for the root anim PNG layout change.

Driven entirely by ``inbox/anim_migration_manifest.json`` (the read-only
T-MOVE-PLAN analysis).  No Godot jobs are launched; Python stdlib only.

What it does
------------
For every manifest entry (1837 root PNGs) the PNG and its companion
``.png.import`` are moved from ``app/assets/models/anim/`` into either
``buildings/`` or ``land_units/``.  Inside each ``.import`` three fields are
rewritten with the manifest-provided strings and the new md5 cache hash:

  * deps/source_file            (9 pre-existing ``res://res://`` values are
                                  normalised via ``old_source_file_actual``)
  * remap/path                  (cache hash old -> new)
  * deps/dest_files[0]          (cache hash old -> new)

Rewrites are done at the byte level with exact ``from`` -> ``to`` string
replacement, so every other byte (comments, params, uid, whitespace, line
endings) is preserved verbatim.

Modes (mutually exclusive; --dry-run is the default)
----------------------------------------------------
  --dry-run    Print counts, sample moves and preflight results; write nothing.
  --apply      Perform the moves + rewrites; refuse if any target exists;
               write ``inbox/anim_migration_undo.json`` with exact reverse ops.
  --rollback   Inverse of apply, derived from the manifest (the undo log is
               used as an exact-bytes cross-check when present).
  --verify     Check every target exists, no ``res://res://`` remains, and
               per-folder PNG counts equal the manifest totals.

  --batch {buildings,land_units,all}   Restrict apply/rollback/verify (default all).
"""
import argparse
import base64
import collections
import datetime
import hashlib
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "inbox" / "anim_migration_manifest.json"
UNDO_PATH = ROOT / "inbox" / "anim_migration_undo.json"
PROGRESS_EVERY = 200
BATCHES = ("buildings", "land_units", "all")


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def log(msg=""):
    print(msg, flush=True)


def load_manifest():
    if not MANIFEST_PATH.is_file():
        raise SystemExit("ERROR: manifest not found: %s" % MANIFEST_PATH)
    with MANIFEST_PATH.open(encoding="utf-8") as fh:
        data = json.load(fh)
    for key in ("source_dir", "totals", "import_rewrites"):
        if key not in data:
            raise SystemExit("ERROR: manifest missing key %r" % key)
    files = data["import_rewrites"].get("files")
    if not isinstance(files, list) or not files:
        raise SystemExit("ERROR: manifest has no import_rewrites.files")
    # sanity: replacement fields must be the three expected ones
    expected_fields = {"deps/source_file", "remap/path", "deps/dest_files[0]"}
    for entry in files:
        fields = {r["field"] for r in entry["replacements"]}
        if fields != expected_fields:
            raise SystemExit(
                "ERROR: unexpected replacement fields in %s: %r"
                % (entry["import"], sorted(fields))
            )
    return data


def src_root(data):
    return ROOT / data["source_dir"].rstrip("/")


def selected_entries(data, batch):
    entries = data["import_rewrites"]["files"]
    if batch == "all":
        return entries
    return [e for e in entries if e["target_dir"] == batch]


def paths_for(data, entry):
    base = src_root(data)
    name_png = entry["png"]
    name_imp = entry["import"]
    dest = entry["target_dir"]
    return (
        base / name_png,
        base / name_imp,
        base / dest / name_png,
        base / dest / name_imp,
    )


def replacement_groups(entry):
    """Group replacements by identical ``from`` string -> (to, count)."""
    groups = collections.OrderedDict()
    for repl in entry["replacements"]:
        frm, to = repl["from"], repl["to"]
        if frm in groups:
            if groups[frm][0] != to:
                raise ValueError(
                    "conflicting 'to' for one 'from' in %s" % entry["import"]
                )
            groups[frm] = (to, groups[frm][1] + 1)
        else:
            groups[frm] = (to, 1)
    return groups


def rewrite_import(entry, original_bytes):
    """Return rewritten bytes. Validate exact replacement counts.

    ``from`` strings that appear more than once (the cache path is shared by
    remap/path and deps/dest_files[0]) are replaced in one shot; the expected
    old count equals the number of manifest records using that ``from``.
    """
    out = original_bytes
    for frm, (to, expected_old_count) in replacement_groups(entry).items():
        fb, tb = frm.encode("utf-8"), to.encode("utf-8")
        actual = out.count(fb)
        if actual != expected_old_count:
            raise ValueError(
                "%s: %r occurs %d time(s), expected %d"
                % (entry["import"], frm, actual, expected_old_count)
            )
        if out.count(tb) != 0:
            raise ValueError(
                "%s: target string already present: %r" % (entry["import"], to)
            )
        out = out.replace(fb, tb)
    return out


def restore_import(entry, current_bytes):
    """Inverse of rewrite_import (manifest-driven)."""
    out = current_bytes
    for frm, (to, expected_new_count) in replacement_groups(entry).items():
        fb, tb = frm.encode("utf-8"), to.encode("utf-8")
        actual = out.count(tb)
        if actual != expected_new_count:
            raise ValueError(
                "%s: %r occurs %d time(s), expected %d"
                % (entry["import"], to, actual, expected_new_count)
            )
        out = out.replace(tb, fb)
    return out


def read_bytes(path):
    with path.open("rb") as fh:
        return fh.read()


def write_bytes(path, data):
    with path.open("wb") as fh:
        fh.write(data)


def sha256_hex(data):
    return hashlib.sha256(data).hexdigest()


def progress(done, total, label="processed"):
    if done % PROGRESS_EVERY == 0 or done == total:
        log("  %s %d/%d" % (label, done, total))


def print_summary(title, entries, data):
    counts = collections.Counter(e["target_dir"] for e in entries)
    log()
    log("=== SUMMARY: %s ===" % title)
    log("  selected moves : %d" % len(entries))
    log("    buildings    : %d" % counts["buildings"])
    log("    land_units   : %d" % counts["land_units"])
    log("  manifest totals: root_pngs=%d  classified=%d+%d=%d"
        % (data["totals"]["root_pngs"],
           data["totals"]["classified_buildings"],
           data["totals"]["classified_land_units"],
           data["totals"]["classification_sums_check"]))


# --------------------------------------------------------------------------- #
# preflight
# --------------------------------------------------------------------------- #
def preflight(data, entries, preparing):
    """Validate sources/targets/references.

    Returns (prepared, problems).  ``prepared`` is a list of
    (entry, src_png, src_imp, dst_png, dst_imp, original_bytes, new_bytes)
    actually only filled when ``preparing`` is True.
    """
    problems = []
    prepared = []
    seen_targets = {}
    base = src_root(data)

    for idx, entry in enumerate(entries):
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        if not src_png.is_file():
            problems.append("missing source PNG: %s" % src_png)
        if not src_imp.is_file():
            problems.append("missing source import: %s" % src_imp)
        for target in (dst_png, dst_imp):
            if target.exists():
                problems.append("target already exists: %s" % target)
            if str(target) in seen_targets:
                problems.append(
                    "duplicate target %s (also for %s)"
                    % (target, seen_targets[str(target)])
                )
            seen_targets[str(target)] = entry["png"]

        new_bytes = None
        original_bytes = None
        if src_imp.is_file():
            try:
                original_bytes = read_bytes(src_imp)
                new_bytes = rewrite_import(entry, original_bytes)
            except ValueError as exc:
                problems.append("rewrite check failed: %s" % exc)
        prepared.append((entry, src_png, src_imp, dst_png, dst_imp,
                         original_bytes, new_bytes))
        if (idx + 1) % PROGRESS_EVERY == 0:
            log("  preflight %d/%d" % (idx + 1, len(entries)))

    # dedupe problems for readable output
    seen = set()
    unique = []
    for p in problems:
        if p not in seen:
            seen.add(p)
            unique.append(p)
    return prepared, unique


# --------------------------------------------------------------------------- #
# modes
# --------------------------------------------------------------------------- #
def cmd_dry_run(data, entries):
    log("MODE: dry-run (no writes)")
    print_summary("dry-run", entries, data)
    prepared, problems = preflight(data, entries, preparing=True)
    log()
    if problems:
        log("PREFLIGHT: %d problem(s):" % len(problems))
        for p in problems[:20]:
            log("  ! " + p)
        if len(problems) > 20:
            log("  ... and %d more" % (len(problems) - 20))
    else:
        log("PREFLIGHT: OK - all sources present, all targets clear, "
            "all rewrites validated")
    log()
    log("Sample moves (first 5 of %d):" % len(entries))
    for entry in entries[:5]:
        log("  %s -> %s/%s"
            % (entry["png"], entry["target_dir"], entry["png"]))
    log()
    log("Sample rewrites (first 2 of %d):" % len(entries))
    for entry in entries[:2]:
        for repl in entry["replacements"]:
            log("  [%s] %s" % (entry["import"], repl["field"]))
            log("      - %s" % repl["from"])
            log("      + %s" % repl["to"])
    log()
    log("No files created, moved or modified.")


def cmd_apply(data, entries):
    log("MODE: apply")
    print_summary("apply (preflight)", entries, data)
    prepared, problems = preflight(data, entries, preparing=True)
    if problems:
        log()
        log("REFUSING --apply: %d problem(s):" % len(problems))
        for p in problems:
            log("  ! " + p)
        return 2

    # create destination directories (only after a clean preflight)
    for dest in sorted({e["target_dir"] for e in entries}):
        d = src_root(data) / dest
        d.mkdir(parents=True, exist_ok=True)
        log("  ensured dir: %s" % d)

    operations = []
    errors = []
    log()
    log("Applying %d moves..." % len(entries))
    for i, (entry, src_png, src_imp, dst_png, dst_imp,
            original_bytes, new_bytes) in enumerate(prepared, start=1):
        try:
            os.replace(str(src_png), str(dst_png))
            os.replace(str(src_imp), str(dst_imp))
            write_bytes(dst_imp, new_bytes)
            reverse = [
                {"field": r["field"], "from": r["to"], "to": r["from"]}
                for r in entry["replacements"]
            ]
            operations.append({
                "png": entry["png"],
                "import": entry["import"],
                "target_dir": entry["target_dir"],
                "from_dir": data["source_dir"].rstrip("/"),
                "to_dir": (data["source_dir"].rstrip("/") + "/"
                           + entry["target_dir"]),
                "reverse_replacements": reverse,
                "original_import_sha256": sha256_hex(original_bytes),
                "original_import_b64": base64.b64encode(
                    original_bytes).decode("ascii"),
            })
        except OSError as exc:
            errors.append("%s: %s" % (entry["png"], exc))
        progress(i, len(entries))

    log()
    log("Writing undo log: %s" % UNDO_PATH)
    undo = {
        "task": "T-MIGRATE-TOOL undo log",
        "manifest": str(MANIFEST_PATH.relative_to(ROOT)).replace("\\", "/"),
        "source_dir": data["source_dir"],
        "batch": _batch_used,
        "created_local": datetime.datetime.now().isoformat(timespec="seconds"),
        "count": len(operations),
        "operations": operations,
    }
    with UNDO_PATH.open("w", encoding="utf-8") as fh:
        json.dump(undo, fh, indent=1)
        fh.write("\n")

    print_summary("apply", entries, data)
    log("  moved           : %d" % len(operations))
    log("  errors          : %d" % len(errors))
    for e in errors[:20]:
        log("    ! " + e)
    return 1 if errors else 0


def cmd_rollback(data, entries):
    log("MODE: rollback")
    print_summary("rollback (preflight)", entries, data)

    base = src_root(data)
    problems = []
    undo_by_name = {}
    if UNDO_PATH.is_file():
        with UNDO_PATH.open(encoding="utf-8") as fh:
            undo = json.load(fh)
        for op in undo.get("operations", []):
            undo_by_name[op["import"]] = op
        log("  undo log loaded: %s (%d operations)"
            % (UNDO_PATH, len(undo_by_name)))
    else:
        log("  undo log not found; deriving exact inverse from manifest")

    for entry in entries:
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        if not dst_png.is_file():
            problems.append("moved PNG missing at target: %s" % dst_png)
        if not dst_imp.is_file():
            problems.append("moved import missing at target: %s" % dst_imp)
        if src_png.exists():
            problems.append("origin PNG already occupied: %s" % src_png)
        if src_imp.exists():
            problems.append("origin import already occupied: %s" % src_imp)
        try:
            current = read_bytes(dst_imp)
            restored = restore_import(entry, current)
            op = undo_by_name.get(entry["import"])
            if op and op.get("original_import_b64"):
                expected = base64.b64decode(op["original_import_b64"])
                if restored != expected:
                    problems.append(
                        "restored bytes differ from undo log for %s"
                        % entry["import"])
        except ValueError as exc:
            problems.append("inverse check failed: %s" % exc)

    seen = set()
    problems = [p for p in problems if not (p in seen or seen.add(p))]
    if problems:
        log()
        log("REFUSING --rollback: %d problem(s):" % len(problems))
        for p in problems:
            log("  ! " + p)
        return 2

    restored_dirs = set()
    errors = []
    done = 0
    log()
    log("Rolling back %d moves..." % len(entries))
    for entry in entries:
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        try:
            current = read_bytes(dst_imp)
            restored = restore_import(entry, current)
            os.replace(str(dst_png), str(src_png))
            os.replace(str(dst_imp), str(src_imp))
            write_bytes(src_imp, restored)
            restored_dirs.add(str(base / entry["target_dir"]))
        except OSError as exc:
            errors.append("%s: %s" % (entry["png"], exc))
        done += 1
        progress(done, len(entries))

    for d in restored_dirs:
        try:
            os.rmdir(d)  # remove now-empty batch dirs (ignore if not empty)
        except OSError:
            pass

    print_summary("rollback", entries, data)
    log("  restored        : %d" % (done - len(errors)))
    log("  errors          : %d" % len(errors))
    for e in errors[:20]:
        log("    ! " + e)
    return 1 if errors else 0


def cmd_verify(data, entries):
    log("MODE: verify")
    problems = []
    base = src_root(data)

    for idx, entry in enumerate(entries, start=1):
        _sp, _si, dst_png, dst_imp = paths_for(data, entry)
        if not dst_png.is_file():
            problems.append("missing target PNG: %s" % dst_png)
        if not dst_imp.is_file():
            problems.append("missing target import: %s" % dst_imp)
            continue
        content = read_bytes(dst_imp)
        if b"res://res://" in content:
            problems.append("res://res:// remains in %s" % dst_imp)
        for frm, (to, expected) in replacement_groups(entry).items():
            tb, fb = to.encode("utf-8"), frm.encode("utf-8")
            if content.count(tb) != expected:
                problems.append(
                    "%s: %r count %d != %d"
                    % (entry["import"], to, content.count(tb), expected))
            if fb in content:
                problems.append(
                    "%s: stale old string %r" % (entry["import"], frm))
        progress(idx, len(entries), "checked")

    expected_counts = {
        "buildings": data["totals"]["classified_buildings"],
        "land_units": data["totals"]["classified_land_units"],
    }
    actual_counts = {}
    for dest in ("buildings", "land_units"):
        d = base / dest
        actual_counts[dest] = (len([f for f in os.listdir(d) if f.endswith(".png")])
                               if d.is_dir() else 0)
        if _batch_used in (dest, "all") and actual_counts[dest] != expected_counts[dest]:
            problems.append(
                "%s/: %d PNGs, expected %d"
                % (dest, actual_counts[dest], expected_counts[dest]))

    root_png_count = len([f for f in os.listdir(base) if f.endswith(".png")])
    expected_root = 0 if _batch_used == "all" else (
        data["totals"]["root_pngs"] - expected_counts[_batch_used])
    if root_png_count != expected_root:
        problems.append(
            "root: %d PNGs, expected %d" % (root_png_count, expected_root))

    print_summary("verify", entries, data)
    log("  PNG counts      : buildings=%d land_units=%d root=%d"
        % (actual_counts["buildings"], actual_counts["land_units"],
           root_png_count))
    if problems:
        log("  RESULT: FAIL (%d problem(s))" % len(problems))
        for p in problems[:30]:
            log("    ! " + p)
        if len(problems) > 30:
            log("    ... and %d more" % (len(problems) - 30))
        return 1
    log("  RESULT: PASS - targets present, rewrites correct, no res://res://, "
        "counts match")
    return 0


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
_batch_used = "all"


def main(argv=None):
    global _batch_used
    parser = argparse.ArgumentParser(
        description="Migrate root anim PNGs into buildings/ and land_units/ "
                    "using inbox/anim_migration_manifest.json.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true",
                      help="report only; no writes (default)")
    mode.add_argument("--apply", action="store_true",
                      help="perform moves + .import rewrites and write undo log")
    mode.add_argument("--rollback", action="store_true",
                      help="inverse of apply, derived from the manifest")
    mode.add_argument("--verify", action="store_true",
                      help="check targets, rewrites and per-folder counts")
    parser.add_argument("--batch", choices=BATCHES, default="all",
                        help="restrict to a destination batch (default: all)")
    args = parser.parse_args(argv)

    if not (args.apply or args.rollback or args.verify or args.dry_run):
        args.dry_run = True
    _batch_used = args.batch

    data = load_manifest()
    entries = selected_entries(data, args.batch)
    log("Manifest : %s" % MANIFEST_PATH.relative_to(ROOT))
    log("Source   : %s" % data["source_dir"])
    log("Batch    : %s" % args.batch)

    if args.apply:
        return cmd_apply(data, entries)
    if args.rollback:
        return cmd_rollback(data, entries)
    if args.verify:
        return cmd_verify(data, entries)
    return cmd_dry_run(data, entries)


if __name__ == "__main__":
    sys.exit(main())
