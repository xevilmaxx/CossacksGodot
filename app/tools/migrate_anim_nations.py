#!/usr/bin/env python3
"""Migrate anim PNG+import pairs into the nation-first hierarchy.

Driven by ``inbox/anim_nation_plan.json``.  Python stdlib only; no Godot jobs.

For every ``<name>.png`` under the three source folders (``buildings/``,
``land_units/``, ``naval_units/``) together with its ``<name>.png.import``
sibling, the pair is moved to ``<nation|common>/<kind>/`` and three fields of
the .import are rewritten at byte level:

  * deps/source_file      -> res://assets/models/anim/<nation|common>/<kind>/<name>.png
  * remap/path            -> res://.godot/imported/<name>-<NEW_MD5>.ctex
  * deps/dest_files[0]    -> res://.godot/imported/<name>-<NEW_MD5>.ctex

NEW_MD5 = md5(new source_file encoded utf-8).  All other bytes (uid, params,
metadata, whitespace, line endings) are preserved verbatim.  The two stale
``*.tmp``/``*.TMP`` files and the five JSON metadata files are never touched.

Modes (mutually exclusive; --dry-run is the default)
----------------------------------------------------
  --dry-run   report counts + preflight; write nothing
  --apply     move pairs, rewrite .imports, write inbox/anim_nation_undo.json
  --rollback  inverse of apply, using the undo log's exact original bytes
  --verify    check targets, .import fields, counts and leftovers
"""
import argparse
import base64
import collections
import datetime
import hashlib
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN_PATH = ROOT / "inbox" / "anim_nation_plan.json"
UNDO_PATH = ROOT / "inbox" / "anim_nation_undo.json"
RES_ROOT = "res://assets/models/anim"
PROGRESS_EVERY = 200

SRC_RE = re.compile(rb'source_file="([^"]+)"')
PATH_RE = re.compile(rb'(?m)^path="([^"]+)"$')
DEST_RE = re.compile(rb'dest_files=\["([^"]+)"\]')


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def log(msg=""):
    print(msg, flush=True)


def md5_hex(text):
    return hashlib.md5(text.encode("utf-8")).hexdigest()


def sha256_hex(data):
    return hashlib.sha256(data).hexdigest()


def read_bytes(path):
    with path.open("rb") as fh:
        return fh.read()


def write_bytes(path, data):
    with path.open("wb") as fh:
        fh.write(data)


def progress(done, total, label="processed"):
    if done % PROGRESS_EVERY == 0 or done == total:
        log("  %s %d/%d" % (label, done, total))


def load_plan():
    if not PLAN_PATH.is_file():
        raise SystemExit("ERROR: plan not found: %s" % PLAN_PATH)
    with PLAN_PATH.open(encoding="utf-8") as fh:
        data = json.load(fh)
    for key in ("nations", "classification", "source_root",
                "current_counts", "counts_per_target_folder"):
        if key not in data:
            raise SystemExit("ERROR: plan missing key %r" % key)
    nations = set(data["nations"])
    if not nations:
        raise SystemExit("ERROR: plan has no nations")
    kind_map = data["classification"]["source_to_kind"]
    for src in ("buildings", "land_units", "naval_units"):
        if src not in kind_map:
            raise SystemExit("ERROR: source_to_kind missing %r" % src)
    return data, nations, kind_map


def nation_of(png_name, nations):
    """First-3-chars nation code, WITH the mandatory underscore guard."""
    stem = png_name[:-4] if png_name.endswith(".png") else png_name
    if len(stem) < 4 or stem[3] != "_":
        return "common"
    prefix = stem[:3].lower()
    return prefix if prefix in nations else "common"


def source_root(data):
    return ROOT / data["source_root"].rstrip("/")


def build_entries(data, nations, kind_map):
    """Recompute the full move manifest deterministically from the plan rules."""
    base = source_root(data)
    entries, skipped = [], []
    for src in ("buildings", "land_units", "naval_units"):
        src_dir = base / src
        if not src_dir.is_dir():
            raise SystemExit("ERROR: source dir missing: %s" % src_dir)
        kind = kind_map[src]
        for name in sorted(f for f in os.listdir(src_dir) if f.endswith(".png")):
            imp = name + ".import"
            if not (src_dir / imp).is_file():
                skipped.append((src, name, "no .import sibling"))
                continue
            nation = nation_of(name, nations)
            target_dir = "%s/%s" % (nation, kind)
            old_source = "%s/%s/%s" % (RES_ROOT, src, name)
            new_source = "%s/%s/%s" % (RES_ROOT, target_dir, name)
            stem = name  # Godot cache key keeps the ".png" suffix
            old_ctex = "res://.godot/imported/%s-%s.ctex" % (stem, md5_hex(old_source))
            new_ctex = "res://.godot/imported/%s-%s.ctex" % (stem, md5_hex(new_source))
            entries.append({
                "png": name,
                "import": imp,
                "source_kind_dir": src,
                "target_dir": target_dir,
                "old_source": old_source,
                "new_source": new_source,
                "old_ctex": old_ctex,
                "new_ctex": new_ctex,
            })
    return entries, skipped


def entries_from_undo(data, nations, kind_map):
    """Rebuild the expected move list from the undo log (post-apply state).

    After --apply the source folders are empty, so verify/rollback must derive
    the manifest from the undo log instead of scanning source folders.  Values
    are recomputed from the plan rules and cross-checked against the recorded
    reverse replacements.
    """
    if not UNDO_PATH.is_file():
        raise SystemExit("ERROR: undo log not found: %s" % UNDO_PATH)
    with UNDO_PATH.open(encoding="utf-8") as fh:
        undo = json.load(fh)
    entries, skipped = [], []
    for op in undo.get("operations", []):
        src, name = op["source_kind_dir"], op["png"]
        target = op["target_dir"]
        if src not in kind_map:
            raise SystemExit("ERROR: undo op has unknown source dir %r" % src)
        expected_target = "%s/%s" % (nation_of(name, nations), kind_map[src])
        if target != expected_target:
            raise SystemExit(
                "ERROR: undo target %r != expected %r for %s"
                % (target, expected_target, name))
        old_source = "%s/%s/%s" % (RES_ROOT, src, name)
        new_source = "%s/%s/%s" % (RES_ROOT, target, name)
        old_ctex = "res://.godot/imported/%s-%s.ctex" % (name, md5_hex(old_source))
        new_ctex = "res://.godot/imported/%s-%s.ctex" % (name, md5_hex(new_source))
        entry = {
            "png": name,
            "import": op["import"],
            "source_kind_dir": src,
            "target_dir": target,
            "old_source": old_source,
            "new_source": new_source,
            "old_ctex": old_ctex,
            "new_ctex": new_ctex,
        }
        recorded = {r["field"]: r for r in op.get("reverse_replacements", [])}
        checks = (
            ("deps/source_file", new_source, old_source),
            ("remap/path", new_ctex, old_ctex),
            ("deps/dest_files[0]", new_ctex, old_ctex),
        )
        for field, new_val, old_val in checks:
            r = recorded.get(field)
            if not r or r.get("from") != new_val or r.get("to") != old_val:
                raise SystemExit(
                    "ERROR: undo reverse replacement mismatch for %s (%s)"
                    % (name, field))
        entries.append(entry)
    return entries, skipped


def paths_for(data, entry):
    base = source_root(data)
    return (
        base / entry["source_kind_dir"] / entry["png"],
        base / entry["source_kind_dir"] / entry["import"],
        base / entry["target_dir"] / entry["png"],
        base / entry["target_dir"] / entry["import"],
    )


def reverse_replacements(entry):
    return [
        {"field": "deps/source_file",
         "from": entry["new_source"], "to": entry["old_source"]},
        {"field": "remap/path",
         "from": entry["new_ctex"], "to": entry["old_ctex"]},
        {"field": "deps/dest_files[0]",
         "from": entry["new_ctex"], "to": entry["old_ctex"]},
    ]


def rewrite_import(entry, original_bytes):
    """Return (new_bytes, list_of_3_replacements) with strict count checks."""
    matches = SRC_RE.findall(original_bytes)
    if len(matches) != 1:
        raise ValueError("%s: expected 1 source_file, found %d"
                         % (entry["import"], len(matches)))
    actual_old_source = matches[0].decode("utf-8")
    if actual_old_source != entry["old_source"]:
        raise ValueError("%s: source_file %r != expected %r"
                         % (entry["import"], actual_old_source, entry["old_source"]))
    # cache path (old_ctex) must be present exactly twice: remap/path + dest_files
    ob, nb = entry["old_ctex"].encode("utf-8"), entry["new_ctex"].encode("utf-8")
    osb, nsb = entry["old_source"].encode("utf-8"), entry["new_source"].encode("utf-8")
    if original_bytes.count(ob) != 2:
        raise ValueError("%s: old ctex occurs %d time(s), expected 2"
                         % (entry["import"], original_bytes.count(ob)))
    if original_bytes.count(osb) != 1:
        raise ValueError("%s: old source occurs %d time(s), expected 1"
                         % (entry["import"], original_bytes.count(osb)))
    if nb in original_bytes or nsb in original_bytes:
        raise ValueError("%s: new path already present in original"
                         % entry["import"])
    out = original_bytes.replace(ob, nb).replace(osb, nsb)
    return out, reverse_replacements(entry)


def print_summary(title, entries, skipped, data):
    counts = collections.Counter(e["target_dir"] for e in entries)
    by_kind = collections.Counter(e["source_kind_dir"] for e in entries)
    log()
    log("=== SUMMARY: %s ===" % title)
    log("  selected pairs    : %d" % len(entries))
    log("    from buildings  : %d" % by_kind["buildings"])
    log("    from land_units : %d" % by_kind["land_units"])
    log("    from naval_units: %d" % by_kind["naval_units"])
    log("  target dirs       : %d" % len(counts))
    log("  top target folders:")
    for folder in ("buildings", "units", "naval"):
        sub = {k: v for k, v in counts.items() if k.endswith("/" + folder)}
        log("    %-10s %d file(s) across %d dir(s)"
            % (folder, sum(sub.values()), len(sub)))
    log("  skipped files     : %d" % len(skipped))
    log("  plan totals       : %d PNG / %d import"
        % (data["current_counts"]["total_png"],
           data["current_counts"]["import_files_one_per_png"]))


# --------------------------------------------------------------------------- #
# preflight
# --------------------------------------------------------------------------- #
def preflight(data, entries, preparing=True):
    problems, prepared = [], []
    seen_targets = {}
    for idx, entry in enumerate(entries, start=1):
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        if not src_png.is_file():
            problems.append("missing source PNG: %s" % src_png)
        if not src_imp.is_file():
            problems.append("missing source import: %s" % src_imp)
        for target in (dst_png, dst_imp):
            if target.exists():
                problems.append("target already exists: %s" % target)
            key = str(target)
            if key in seen_targets:
                problems.append("duplicate target %s (also for %s)"
                                % (target, seen_targets[key]))
            seen_targets[key] = entry["png"]
        original_bytes = new_bytes = None
        if src_imp.is_file():
            try:
                original_bytes = read_bytes(src_imp)
                new_bytes, _ = rewrite_import(entry, original_bytes)
            except ValueError as exc:
                problems.append("rewrite check failed: %s" % exc)
        prepared.append((entry, src_png, src_imp, dst_png, dst_imp,
                         original_bytes, new_bytes))
        if idx % PROGRESS_EVERY == 0:
            log("  preflight %d/%d" % (idx, len(entries)))
    # dedupe
    seen, unique = set(), []
    for p in problems:
        if p not in seen:
            seen.add(p)
            unique.append(p)
    return prepared, unique


# --------------------------------------------------------------------------- #
# modes
# --------------------------------------------------------------------------- #
def cmd_dry_run(data, entries, skipped):
    log("MODE: dry-run (no writes)")
    print_summary("dry-run", entries, skipped, data)
    prepared, problems = preflight(data, entries)
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
    for e in entries[:5]:
        log("  %s/%s -> %s/%s"
            % (e["source_kind_dir"], e["png"], e["target_dir"], e["png"]))
    log()
    log("Sample rewrites (first 2 of %d):" % len(entries))
    for e in entries[:2]:
        log("  [%s]" % e["import"])
        log("      source_file: %s -> %s" % (e["old_source"], e["new_source"]))
        log("      ctex       : %s -> %s" % (e["old_ctex"], e["new_ctex"]))
    log()
    log("No files created, moved or modified.")
    return 0


def cmd_apply(data, entries, skipped):
    log("MODE: apply")
    print_summary("apply (preflight)", entries, skipped, data)
    prepared, problems = preflight(data, entries)
    if problems:
        log()
        log("REFUSING --apply: %d problem(s):" % len(problems))
        for p in problems:
            log("  ! " + p)
        return 2

    base = source_root(data)
    created_dirs = []
    for dest in sorted({e["target_dir"] for e in entries}):
        d = base / dest
        if not d.exists():
            d.mkdir(parents=True, exist_ok=True)
            created_dirs.append(dest)
            log("  created dir: %s" % dest)

    operations, errors = [], []
    log()
    log("Applying %d moves..." % len(entries))
    for i, (entry, src_png, src_imp, dst_png, dst_imp,
            original_bytes, new_bytes) in enumerate(prepared, start=1):
        try:
            os.replace(str(src_png), str(dst_png))
            os.replace(str(src_imp), str(dst_imp))
            write_bytes(dst_imp, new_bytes)
            operations.append({
                "png": entry["png"],
                "import": entry["import"],
                "source_kind_dir": entry["source_kind_dir"],
                "target_dir": entry["target_dir"],
                "reverse_replacements": reverse_replacements(entry),
                "original_import_sha256": sha256_hex(original_bytes),
                "original_import_b64": base64.b64encode(original_bytes).decode("ascii"),
            })
        except OSError as exc:
            errors.append("%s: %s" % (entry["png"], exc))
        progress(i, len(entries))

    undo = {
        "task": "T-NATION-ASSETS executor undo log",
        "manifest": str(PLAN_PATH.relative_to(ROOT)).replace("\\", "/"),
        "source_root": data["source_root"],
        "count": len(operations),
        "created_dirs": created_dirs,
        "created_local": datetime.datetime.now().isoformat(timespec="seconds"),
        "operations": operations,
    }
    with UNDO_PATH.open("w", encoding="utf-8") as fh:
        json.dump(undo, fh, indent=1)
        fh.write("\n")
    log()
    log("Undo log written: %s (%d operations, %d created dirs)"
        % (UNDO_PATH.relative_to(ROOT), len(operations), len(created_dirs)))
    print_summary("apply", entries, skipped, data)
    log("  moved           : %d" % len(operations))
    log("  errors          : %d" % len(errors))
    for e in errors[:20]:
        log("    ! " + e)
    return 1 if errors else 0


def cmd_rollback(data, entries, skipped):
    log("MODE: rollback")
    if not UNDO_PATH.is_file():
        log("REFUSING --rollback: undo log not found: %s" % UNDO_PATH)
        return 2
    with UNDO_PATH.open(encoding="utf-8") as fh:
        undo = json.load(fh)
    ops = undo.get("operations", [])
    log("  undo log: %s (%d operations)"
        % (UNDO_PATH.relative_to(ROOT), len(ops)))
    by_key = {(o["source_kind_dir"], o["png"]): o for o in ops}

    base = source_root(data)
    problems = []
    for idx, entry in enumerate(entries, start=1):
        key = (entry["source_kind_dir"], entry["png"])
        op = by_key.get(key)
        if op is None:
            problems.append("no undo operation for %s" % entry["png"])
            continue
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        if not dst_png.is_file() or not dst_imp.is_file():
            problems.append("moved pair missing at target: %s" % entry["png"])
            continue
        if src_png.exists() or src_imp.exists():
            problems.append("origin path occupied: %s" % entry["png"])
            continue
        try:
            original = base64.b64decode(op["original_import_b64"])
            if sha256_hex(original) != op["original_import_sha256"]:
                problems.append("undo log sha256 mismatch: %s" % entry["png"])
            expected_new, _ = rewrite_import(entry, original)
            if read_bytes(dst_imp) != expected_new:
                problems.append("current import differs from expected rewrite: %s"
                                % entry["png"])
        except (ValueError, KeyError) as exc:
            problems.append("undo check failed for %s: %s" % (entry["png"], exc))
        if idx % PROGRESS_EVERY == 0:
            log("  rollback preflight %d/%d" % (idx, len(entries)))

    seen, problems = set(), [p for p in problems if not (p in seen or seen.add(p))]
    if problems:
        log()
        log("REFUSING --rollback: %d problem(s):" % len(problems))
        for p in problems[:20]:
            log("  ! " + p)
        return 2

    restored, errors = 0, []
    log()
    log("Rolling back %d moves..." % len(entries))
    for idx, entry in enumerate(entries, start=1):
        op = by_key[(entry["source_kind_dir"], entry["png"])]
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        try:
            original = base64.b64decode(op["original_import_b64"])
            os.replace(str(dst_png), str(src_png))
            os.replace(str(dst_imp), str(src_imp))
            write_bytes(src_imp, original)
            restored += 1
        except OSError as exc:
            errors.append("%s: %s" % (entry["png"], exc))
        progress(idx, len(entries), "restored")

    # remove created dirs only when empty (deepest first)
    for dest in sorted(undo.get("created_dirs", []),
                       key=lambda p: p.count("/"), reverse=True):
        d = base / dest
        try:
            os.rmdir(d)
            log("  removed empty dir: %s" % dest)
        except OSError:
            pass

    log()
    log("Restored pairs: %d; errors: %d" % (restored, len(errors)))
    return 1 if errors else 0


def expected_counts(data):
    groups = data["counts_per_target_folder"]
    out = {}
    for kind in ("buildings", "units", "naval"):
        for key, value in groups.get(kind, {}).items():
            if key != "TOTAL":
                out[key] = value
    return out


def cmd_verify(data, entries, skipped):
    log("MODE: verify")
    base = source_root(data)
    problems = []

    for idx, entry in enumerate(entries, start=1):
        src_png, src_imp, dst_png, dst_imp = paths_for(data, entry)
        if not dst_png.is_file():
            problems.append("missing target PNG: %s" % dst_png)
        if not dst_imp.is_file():
            problems.append("missing target import: %s" % dst_imp)
            continue
        if src_png.exists():
            problems.append("leftover source PNG: %s" % src_png)
        if src_imp.exists():
            problems.append("leftover source import: %s" % src_imp)
        content = read_bytes(dst_imp)
        src_m, path_m, dest_m = SRC_RE.search(content), PATH_RE.search(content), DEST_RE.search(content)
        if not src_m or src_m.group(1).decode("utf-8") != entry["new_source"]:
            problems.append("%s: source_file != new source" % entry["import"])
        if not path_m or path_m.group(1).decode("utf-8") != entry["new_ctex"]:
            problems.append("%s: remap/path != new ctex" % entry["import"])
        if not dest_m or dest_m.group(1).decode("utf-8") != entry["new_ctex"]:
            problems.append("%s: dest_files[0] != new ctex" % entry["import"])
        if entry["old_source"].encode("utf-8") in content:
            problems.append("%s: stale old source_file" % entry["import"])
        if entry["old_ctex"].encode("utf-8") in content:
            problems.append("%s: stale old ctex path" % entry["import"])
        progress(idx, len(entries), "checked")

    exp = expected_counts(data)
    for target, want in sorted(exp.items()):
        d = base / target
        actual = len([f for f in os.listdir(d) if f.endswith(".png")]) if d.is_dir() else 0
        if actual != want:
            problems.append("%s/: %d PNG(s), expected %d" % (target, actual, want))

    for src in ("buildings", "land_units", "naval_units"):
        d = base / src
        leftovers = [f for f in os.listdir(d) if f.endswith(".png") or f.endswith(".png.import")]
        if leftovers:
            problems.append("%s/: %d leftover PNG/import file(s): %s"
                            % (src, len(leftovers), leftovers[:3]))

    for jpath in data.get("json_metadata_stays_put", []):
        p = ROOT / jpath
        if not p.is_file():
            problems.append("JSON metadata missing: %s" % jpath)
    for tmp in ("rus_sta_s4.png.import~RF139ced6.TMP",
                "rus_sto_dead.png.import401825162.tmp"):
        if not (base / "buildings" / tmp).is_file():
            problems.append("known stale temp file missing: %s" % tmp)

    print_summary("verify", entries, skipped, data)
    if problems:
        log("  RESULT: FAIL (%d problem(s))" % len(problems))
        for p in problems[:30]:
            log("    ! " + p)
        if len(problems) > 30:
            log("    ... and %d more" % (len(problems) - 30))
        return 1
    log("  RESULT: PASS - %d pairs at target with correct .import fields, "
        "per-folder counts match plan, no leftovers, JSON/temp files untouched"
        % len(entries))
    return 0


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Migrate anim PNG+import pairs into <nation>/<kind> dirs "
                    "using inbox/anim_nation_plan.json.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true", help="report only (default)")
    mode.add_argument("--apply", action="store_true",
                      help="move pairs, rewrite .imports, write undo log")
    mode.add_argument("--rollback", action="store_true", help="inverse of apply")
    mode.add_argument("--verify", action="store_true", help="verify migration")
    args = parser.parse_args(argv)
    if not (args.apply or args.rollback or args.verify or args.dry_run):
        args.dry_run = True

    data, nations, kind_map = load_plan()
    # After --apply the source folders are empty: verify/rollback must rebuild
    # the expected move list from the undo log rather than scanning them.
    if args.verify or args.rollback:
        entries, skipped = entries_from_undo(data, nations, kind_map)
    else:
        entries, skipped = build_entries(data, nations, kind_map)
    log("Plan     : %s" % PLAN_PATH.relative_to(ROOT))
    log("Source   : %s" % data["source_root"])
    log("Nations  : %d; entries: %d; skipped: %d"
        % (len(nations), len(entries), len(skipped)))
    for src, name, why in skipped[:5]:
        log("  skip %s/%s (%s)" % (src, name, why))

    if args.apply:
        return cmd_apply(data, entries, skipped)
    if args.rollback:
        return cmd_rollback(data, entries, skipped)
    if args.verify:
        return cmd_verify(data, entries, skipped)
    return cmd_dry_run(data, entries, skipped)


if __name__ == "__main__":
    sys.exit(main())
