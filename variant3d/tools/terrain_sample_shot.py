#!/usr/bin/env python3
"""Deterministic 128x128 terrain-sample harness (BUILDER-CAPTURE).

Never launches Godot directly. Every Godot process is submitted through the
one legal door, app/tools/godot_runner.py, with a ``tbb0-`` job id prefix.

Modes (from the project root)::

    # (a) print the exact runner commands used by this harness
    python app/tools/terrain_sample_shot.py

    # (b) cheap headless --dump-map seed scan (sim only, no GPU)
    python app/tools/terrain_sample_shot.py --scan-seeds 3

    # (c) windowed (real renderer) capture + PNG validation
    python app/tools/terrain_sample_shot.py --capture --seed 9

All generated files carry a ``_128`` suffix so the 64x64 evidence is never
overwritten. Godot runs use unique ``tbb0-128-*`` job ids through the runner.

The 800x600 CPU fallback produced by a headless screenshot is explicitly
rejected by the real-renderer gate; only a 1280x720, non-blank PNG passes.
"""
from __future__ import annotations

import argparse
import base64
import json
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageStat

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent
ROOT = APP.parent
RUNNER = TOOLS / "godot_runner.py"
SHOTS = APP / "shots"

# Fixed candidate list for this 128x128 scan (priority order matters).
CANDIDATE_SEEDS = (9, 7, 20261113)

# terrain code -> (short name, minimum acceptable percentage).
# SAMPLE-ONLY Stage-1 thresholds: these pick a readable 128x128 frame. They
# are NOT the full-map TS-1 acceptance criteria (ravine rock morphology
# 8-18% is a Stage-3 gate per TERRAIN_BEAUTY_TRIAGE.md) and make no beauty
# claim. 128x128 is used because pattern_gen.gd floors stamp counts at
# maxi(1, base*area_scale): at 64x64 every family gets exactly 1 stamp (no
# forests); at 128x128 counts reach 5-8 per family.
SAMPLE_GATE_NOTE = (
    "SAMPLE-ONLY Stage-1 thresholds (water>=5%, forest>=4%, rock>=1%) - "
    "these pick a readable 128x128 frame; they are NOT the full-map TS-1 "
    "acceptance criteria (ravine rock morphology 8-18% is a Stage-3 gate)."
)
FEATURE_GATES = {
    "water": (3, 5.0),
    "forest": (2, 4.0),
    "rock": (5, 1.0),
}

CONFIG_REL = "shots/terrain_sample.json"
CONFIG_PATH = SHOTS / "terrain_sample.json"
PNG_REL = "shots/terrain_sample_128.png"
DUMP_REL = "shots/terrain_sample_128_seedscan_{seed}.json"
PNG_PATH = SHOTS / "terrain_sample_128.png"
SCAN_REPORT = SHOTS / "terrain_sample_128_seedscan.json"
BEST_FILE = SHOTS / "terrain_sample_128_seedscan_best.json"

# Hard per-job process-tree kill (seconds). 128x128 generation/rendering is
# heavier than 64x64; keep >=300s to match the caller's tool timeout budget.
RUNNER_TIMEOUT = 300
MAX_WAIT = 3600              # FIFO queue wait budget
GAME_TIMEOUT = 60            # in-game wall-clock watchdog
SHOT_FRAMES = 120            # enough frames to build the 2x2 chunks

EXPECTED_SIZE = (1280, 720)  # real windowed viewport
FALLBACK_SIZE = (800, 600)   # headless CPU map render - NOT acceptable here
MIN_BYTES = 100 * 1024       # non-blank smoke threshold (>100 KB)
MIN_LUMA_LEVELS = 16         # multiple luminance levels, not a flat picture


# ---------------------------------------------------------------------------
# runner plumbing (all Godot launches go through here)
# ---------------------------------------------------------------------------
def _shell_arg(text: object) -> str:
    text = str(text)
    return text if not any(c.isspace() for c in text) else '"%s"' % text


def build_runner_command(job_id: str, godot_args: list[str]) -> list[str]:
    """Return the argv *after* `python app/tools/godot_runner.py`."""
    return [
        "run",
        "--id", job_id,
        "--timeout", str(RUNNER_TIMEOUT),
        "--max-wait", str(MAX_WAIT),
        "--", *godot_args,
    ]


def print_runner_command(job_id: str, godot_args: list[str]) -> None:
    parts = build_runner_command(job_id, godot_args)
    print("  python app\\tools\\godot_runner.py " + " ".join(_shell_arg(p) for p in parts))


def print_reference_commands(seed: int) -> None:
    """(a) Always print the exact runner commands this harness uses."""
    print("=" * 78)
    print("exact runner commands (Godot is NEVER launched directly)")
    print("=" * 78)
    for candidate in CANDIDATE_SEEDS:
        print("seed scan %d:" % candidate)
        print_runner_command("tbb0-128-seed-%d" % candidate, scan_godot_args(candidate))
    print("windowed capture (seed %d):" % seed)
    print_runner_command("tbb0-128-capture", capture_godot_args(seed))
    print("-" * 78)


def read_result(job_id: str, stdout: str, proc: subprocess.CompletedProcess) -> dict:
    """Resolve the runner result JSON using the ticket from its START/END lines."""
    ticket = None
    stream_status = None
    run_secs = None
    for line in stdout.splitlines():
        m = re.search(r"ticket (\d+) '([^']+)' START", line)
        if m and m.group(2) == job_id:
            ticket = int(m.group(1))
        m = re.search(r"ticket (\d+) '([^']+)' END (\w+) \(run ([0-9.]+)s\)", line)
        if m and m.group(2) == job_id:
            ticket = int(m.group(1))
            stream_status = m.group(3)
            run_secs = float(m.group(4))

    result = {
        "id": job_id,
        "ticket": ticket,
        "status": stream_status,
        "exit": proc.returncode,
        "run": run_secs,
        "stdout_lines": [ln for ln in stdout.splitlines() if ln.strip()],
    }
    if ticket is not None:
        result_path = ROOT / "app" / ".godot_queue" / "results" / ("%08d.json" % ticket)
        if result_path.exists():
            try:
                data = json.loads(result_path.read_text(encoding="utf-8"))
            except (OSError, ValueError):
                data = {}
            result.update({
                "result_json": str(result_path.relative_to(ROOT)),
                "status": data.get("status", result["status"]),
                "exit": data.get("exit", result["exit"]),
                "run": data.get("run", result["run"]),
                "wait": data.get("wait"),
                "stdout_file": data.get("stdout"),
                "stderr_file": data.get("stderr"),
                "error": data.get("error"),
            })
    return result


def run_job(job_id: str, godot_args: list[str]) -> dict:
    """Submit one job through the runner and wait for its FIFO result."""
    cmd = build_runner_command(job_id, godot_args)
    print("[runner] %s" % job_id)
    print_runner_command(job_id, godot_args)
    try:
        proc = subprocess.run(
            [sys.executable, str(RUNNER), *cmd],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            # generous: covers queue wait + hard runner timeout + slack
            timeout=MAX_WAIT + RUNNER_TIMEOUT + 120,
        )
    except subprocess.TimeoutExpired as exc:
        print("[runner] %s wrapper timeout - result unknown; check status" % job_id,
              file=sys.stderr)
        return {"id": job_id, "ticket": None, "status": "wrapper-timeout",
                "exit": None, "run": None, "error": repr(exc)}
    for line in proc.stdout.splitlines():
        if line.strip():
            print("  | " + line)
    if proc.stderr.strip():
        for line in proc.stderr.splitlines():
            if line.strip():
                print("  ! " + line, file=sys.stderr)
    return read_result(job_id, proc.stdout, proc)


def godot_log(job: dict, which: str = "stdout") -> str:
    rel = job.get(which + "_file")
    if not rel:
        return ""
    path = ROOT / rel
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


# ---------------------------------------------------------------------------
# seed scan
# ---------------------------------------------------------------------------
def scan_godot_args(seed: int) -> list[str]:
    return [
        "--headless", "--path", "app", "--",
        "--config", CONFIG_REL,
        "--seed", str(seed),
        "--dump-map", DUMP_REL.format(seed=seed),
        "--timeout", str(GAME_TIMEOUT),
    ]


def scan_seed(seed: int) -> dict:
    job = run_job("tbb0-128-seed-%d" % seed, scan_godot_args(seed))
    dump_path = APP / DUMP_REL.format(seed=seed)
    rec = {
        "seed": seed,
        "job": job,
        "dump_path": str(dump_path.relative_to(ROOT)),
        "map_w": None, "map_h": None, "cells": None,
        "counts": {}, "percentages": {}, "gates": {},
        "mask_file": None, "meta_type": None, "mask_water": None,
        "passes": False,
    }
    if job.get("status") != "ok":
        rec["error"] = "runner status=%s exit=%s" % (job.get("status"), job.get("exit"))
        return rec
    if not dump_path.exists():
        rec["error"] = "dump file missing: %s" % dump_path
        return rec
    try:
        data = json.loads(dump_path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        rec["error"] = "bad dump json: %r" % exc
        return rec

    # Marshalls.raw_to_base64(PackedByteArray) -> one byte per map cell.
    raw = base64.b64decode(data.get("terrain", ""))
    total = len(raw)
    rec["seed_reported"] = data.get("seed")
    rec["map_w"] = data.get("map_w")
    rec["map_h"] = data.get("map_h")
    rec["cells"] = total
    for name, (code, _min_pct) in FEATURE_GATES.items():
        rec["counts"][name] = raw.count(code)
        rec["percentages"][name] = round(100.0 * rec["counts"][name] / total, 3) if total else 0.0
    for name, (_code, min_pct) in FEATURE_GATES.items():
        rec["gates"][name] = {
            "minimum_pct": min_pct,
            "actual_pct": rec["percentages"][name],
            "met": rec["percentages"][name] >= min_pct,
        }
    rec["passes"] = all(g["met"] for g in rec["gates"].values())

    meta = data.get("meta") or {}
    mask = meta.get("mask") or {}
    rec["mask_file"] = mask.get("file")
    rec["meta_type"] = meta.get("type")
    rec["mask_water"] = meta.get("mask_water")
    return rec


def _tree_rank(r: dict) -> tuple[int, int]:
    """Trees are the priority: forest count first, rock count as tie-break."""
    counts = r.get("counts") or {}
    return (counts.get("forest", 0), counts.get("rock", 0))


def choose_seed(records: list[dict]) -> tuple[dict | None, str]:
    eligible = [r for r in records if r.get("passes")]
    if eligible:
        best = max(eligible, key=_tree_rank)
        return best, ("best tree signal among gate-passing seeds "
                      "(forest=%d, rock=%d cells; trees prioritized)" % _tree_rank(best))
    scored = [r for r in records if r.get("counts")]
    if not scored:
        return None, "no usable dump - cannot choose a seed"

    # fallback: rank all usable records by tree signal (trees prioritized)

    best = max(scored, key=_tree_rank)
    return best, ("no candidate met all gates; chose best tree signal "
                  "(forest=%d, rock=%d cells; trees prioritized)" % _tree_rank(best))


def do_scan(n: int) -> int:
    n = max(1, min(n, len(CANDIDATE_SEEDS)))
    seeds = list(CANDIDATE_SEEDS[:n])
    print("[scan] candidates: %s" % seeds)
    records = [scan_seed(seed) for seed in seeds]
    chosen, reason = choose_seed(records)

    report = {
        "candidates": seeds,
        "gates": {name: {"terrain_code": code, "minimum_pct": pct}
                  for name, (code, pct) in FEATURE_GATES.items()},
        "records": records,
        "chosen_seed": chosen["seed"] if chosen else None,
        "chosen_reason": reason,
        "note": "Smoke measurement harness only; no beauty claim is made here. "
                + SAMPLE_GATE_NOTE,
    }
    SCAN_REPORT.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    print("\n[scan] NOTE: " + SAMPLE_GATE_NOTE)
    print("[scan] results")
    for r in records:
        pct = r["percentages"]
        cnt = r["counts"]
        print("  seed %-9s map %sx%s cells %-6s "
              "forest %5s%% (%s) water %5s%% (%s) rock %5s%% (%s) "
              "mask=%s passes=%s job=%s(%s)" % (
                  r["seed"], r["map_w"], r["map_h"], r["cells"],
                  pct.get("forest"), cnt.get("forest"), pct.get("water"), cnt.get("water"), pct.get("rock"), cnt.get("rock"),
                  r["mask_file"], r["passes"], r["job"].get("id"),
                  r["job"].get("status")))
    print("[scan] chosen seed: %s (%s)" % (report["chosen_seed"], reason))
    print("[scan] report: %s" % SCAN_REPORT.relative_to(ROOT))
    if chosen:
        BEST_FILE.write_text(json.dumps(chosen, indent=2, sort_keys=True), encoding="utf-8")
        print("[scan] best seed record: %s" % BEST_FILE.relative_to(ROOT))
    return 0 if chosen else 1


# ---------------------------------------------------------------------------
# windowed capture + real-renderer gate
# ---------------------------------------------------------------------------
def capture_godot_args(seed: int) -> list[str]:
    return [
        "--path", "app", "--",
        "--config", CONFIG_REL,
        "--seed", str(seed),
        "--screenshot", PNG_REL,
        "--screenshot-frames", str(SHOT_FRAMES),
        "--timeout", str(GAME_TIMEOUT),
    ]


def validate_png(job: dict, skip_log_check: bool = False) -> dict:
    report = {
        "job": job,
        "png": str(PNG_PATH.relative_to(ROOT)),
        "screenshot_saved_line": False,
        "size_bytes": None,
        "dimensions": None,
        "luminance_levels": None,
        "luminance_stddev": None,
        "checks": {},
        "real_renderer_gate": False,
        "failure_reason": None,
    }
    report["screenshot_saved_line"] = ("screenshot saved:" in godot_log(job)
                                       if not skip_log_check else True)

    checks = report["checks"]
    checks["runner_ok"] = job.get("status") == "ok"
    checks["screenshot_logged"] = report["screenshot_saved_line"]
    checks["png_exists"] = PNG_PATH.exists()

    if checks["png_exists"]:
        report["size_bytes"] = PNG_PATH.stat().st_size
        with Image.open(PNG_PATH) as im:
            report["dimensions"] = list(im.size)
            luma = im.convert("L")
            colors = luma.getcolors(maxcolors=256)
            report["luminance_levels"] = len(colors) if colors else 256
            report["luminance_stddev"] = round(ImageStat.Stat(luma).stddev[0], 3)

    w, h = report["dimensions"] if report["dimensions"] else (None, None)
    if (w, h) == FALLBACK_SIZE:
        checks["dimensions_1280x720"] = False
        report["failure_reason"] = (
            "REAL-RENDERER GATE FAILED: PNG is 800x600 - the headless CPU map "
            "fallback fired (main.gd:1185-1199). This is NOT a windowed viewport "
            "capture; the beauty comparison would be invalid.")
        print("\n[FAIL] " + report["failure_reason"], file=sys.stderr)
    else:
        checks["dimensions_1280x720"] = (w, h) == EXPECTED_SIZE
        if not checks["dimensions_1280x720"]:
            report["failure_reason"] = "PNG dimensions %sx%s != 1280x720" % (w, h)

    checks["over_100kb"] = (report["size_bytes"] or 0) > MIN_BYTES
    checks["multi_luminance"] = (report["luminance_levels"] or 0) >= MIN_LUMA_LEVELS
    report["real_renderer_gate"] = all(checks.values())

    print("\n[validate] %s" % PNG_PATH.relative_to(ROOT))
    print(json.dumps(report, indent=2, sort_keys=True))
    return report


def config_seed() -> int | None:
    """Seed declared in the capture config - the default for real captures."""
    try:
        return int(json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
                   ["gameplay"]["random_seed"])
    except (OSError, ValueError, KeyError, TypeError):
        return None


def resolve_seed(arg_seed: int | None) -> int:
    if arg_seed is not None:
        return arg_seed
    # The config is the source of truth for the default capture seed, so a
    # re-scan that happens to pick a different "closest" seed cannot silently
    # make the final capture disagree with terrain_sample.json (seed 9).
    configured = config_seed()
    if configured is not None:
        return configured
    if BEST_FILE.exists():
        try:
            return int(json.loads(BEST_FILE.read_text(encoding="utf-8"))["seed"])
        except (OSError, ValueError, KeyError, TypeError):
            pass
    return CANDIDATE_SEEDS[0]


def do_capture(seed: int) -> int:
    job = run_job("tbb0-128-capture", capture_godot_args(seed))
    report = validate_png(job)
    return 0 if report["real_renderer_gate"] else 1


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--scan-seeds", type=int, nargs="?", const=len(CANDIDATE_SEEDS),
                    metavar="N",
                    help="scan the first N candidate seeds (default when flag used: %d)"
                         % len(CANDIDATE_SEEDS))
    ap.add_argument("--capture", action="store_true",
                    help="windowed real-renderer capture + PNG validation")
    ap.add_argument("--seed", type=int, default=None,
                    help="seed for --capture (default: best from the scan, else %d)"
                         % CANDIDATE_SEEDS[0])
    ap.add_argument("--validate-only", action="store_true",
                    help="re-validate an existing PNG without running Godot")
    args = ap.parse_args(argv)

    seed = resolve_seed(args.seed)
    print_reference_commands(seed)

    if args.scan_seeds is not None:
        do_scan(args.scan_seeds)
    if args.capture:
        do_capture(seed)
    if args.validate_only:
        report = validate_png({"id": "n/a (validate-only)", "status": "ok"},
                              skip_log_check=True)
        return 0 if report["real_renderer_gate"] else 1
    if args.scan_seeds is None and not args.capture and not args.validate_only:
        print("No action requested: pass --scan-seeds [N] and/or --capture --seed S.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
