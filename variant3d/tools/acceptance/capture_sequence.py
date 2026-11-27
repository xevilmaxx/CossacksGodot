#!/usr/bin/env python3
"""Deterministic, serial capture of Godot frame sequences / snapshots.

Every Godot launch goes through variant3d/tools/godot_runner.py `run` (FIFO
mutex + hard timeout + isolated spool).  This harness NEVER starts Godot
itself, NEVER submits two jobs at once, and guards against a second instance
of itself with an exclusive lock file in the output directory.

The engine has no `--camera` or `--preset` command-line flag.  Camera/preset
views are therefore expressed as *config files*: `--view NAME=PATH.json` is a
recorded, hashed `--config` argument (camera.start_zoom, camera.pitch_degrees,
gameplay.* etc).  `--view NAME` means "engine default config, uncontrolled"
and is labelled as such in the manifest.

Frame-count mapping: the engine's `--seq` mode captures one frame per
`--seq-step` sim-seconds, so this tool submits `--seq-seconds = frames * step`
and records the exact derived argument.  The engine may stop early (winner)
or clamp values; requested and observed counts are both recorded.

Usage (from repo root):
  python variant3d/tools/acceptance/capture_sequence.py \
      --seed 20261113 --frames 60 --step 1 --label abrun \
      --view wide=variant3d/config_donor_capture.json \
      --view zoom=C:/abs/path/zoom_config.json \
      --out inbox/qa/captures/abrun_20261113

Output: <out>/manifest.json with exact argv, resolved config hashes,
requested/observed resolution, per-frame file + pixel SHA-256 and runner
status.  `parity=UNVERIFIED` is always printed: a capture is evidence, not a
donor-parity claim.

Optional --verify-repeat (requires --deterministic + integer --seed) submits a
SECOND identical deterministic capture into a sibling <out>_repeat directory
and writes <out>/repeat_verification.json.  It compares per-frame sha256_pixels
and sha256_file, seq_index.json.sim_seconds, 1280x720 resolution and clean
engine stderr, and exits non-zero on any mismatch.  This is a port-internal
repeatability gate ONLY: it is never a donor-parity claim.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from imgio import hash_file, load_rgb

PROJECT = Path(__file__).resolve().parents[2]          # .../variant3d
ROOT = PROJECT.parent                                  # repo root
RUNNER = PROJECT / "tools" / "godot_runner.py"
# Anchors: variant3d/scripts/data.gd:246 (FPS), :506-507 (window 1280x720).
ENGINE_FPS = 32
CAPTURE_W, CAPTURE_H = 1280, 720
RESULTS = PROJECT / ".godot_queue" / "results"
TICKET_RE = re.compile(r"ticket\s+(\d+)")
SLUG_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]*$")
EXIT_OK, EXIT_BAD, EXIT_FAILED = 0, 2, 1

# Optional port-internal repeatability gate.  This is a REPEAT test of this
# harness/port only; it never compares against the donor and never changes any
# ROI, threshold or acceptance criterion.  parity stays UNVERIFIED throughout.
REPEAT_SUFFIX = "_repeat"
REPEAT_STDERR_MARKERS = (
    "deterministic-capture:", "watchdog:",
    "cli: wall-clock limit reached", "fallback map render",
    "headless map render", "blank image, retrying",
)


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def atomic_json(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(obj, indent=2, sort_keys=True), encoding="utf-8")
    os.replace(tmp, path)


def rel(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return str(path.resolve())


def write_manifest(manifest: dict) -> None:
    """Serialize the manifest without internal-only fields."""
    clean = {k: v for k, v in manifest.items() if not k.startswith("_")}
    atomic_json(manifest["_path"], clean)


def parse_view(text: str) -> tuple[str, Path | None]:
    """`name=path.json` -> (name, absolute path); `name` -> (name, None)."""
    if "=" in text:
        name, raw = text.split("=", 1)
        name, raw = name.strip(), raw.strip()
        if not SLUG_RE.match(name) or not raw:
            raise argparse.ArgumentTypeError(
                f"bad --view {text!r}: name must match {SLUG_RE.pattern}")
        p = Path(raw)
        if not p.is_absolute():
            p = (ROOT / p).resolve()
        if not p.is_file():
            raise argparse.ArgumentTypeError(f"--view config is not a file: {p}")
        try:
            json.loads(p.read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            raise argparse.ArgumentTypeError(f"--view config is not valid JSON: {p}: {exc}")
        return name, p
    name = text.strip()
    if not SLUG_RE.match(name):
        raise argparse.ArgumentTypeError(
            f"--view name must match {SLUG_RE.pattern}: {name!r}")
    return name, None


def config_resolution(cfg: Path | None) -> dict:
    if cfg is None:
        return {"width": None, "height": None,
                "source": "engine default (NOT independently verified)"}
    data = json.loads(cfg.read_text(encoding="utf-8"))
    display = data.get("display") if isinstance(data, dict) else None
    display = display if isinstance(display, dict) else {}
    return {
        "width": display.get("window_width"),
        "height": display.get("window_height"),
        "source": rel(cfg),
    }


def read_runner_result(ticket: int | None) -> dict:
    if ticket is None:
        return {}
    path = RESULTS / f"{ticket:08d}.json"
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def capture_view(ns: argparse.Namespace, view: dict, index: int, manifest: dict) -> None:
    """Submit ONE runner job and wait for it. No concurrency anywhere here."""
    name = view["name"]
    cfg: Path | None = Path(view["config_abs"]) if view.get("config_abs") else None
    view_dir = Path(ns.out).resolve() / f"{index:02d}_{name}"
    view_dir.mkdir(parents=True, exist_ok=True)

    existing = sorted(view_dir.glob("frame_*.png")) + list(view_dir.glob("seq_index.json"))
    if existing:
        raise RuntimeError(f"refusing to reuse {view_dir}: {len(existing)} prior capture "
                           "file(s). Choose a fresh --out; frames are never deleted.")

    project_arg = rel(PROJECT) if PROJECT.is_dir() else "variant3d"
    godot_args: list[str] = []
    if ns.headless:
        godot_args.append("--headless")
    godot_args += ["--path", project_arg, "--"]
    if cfg is not None:
        godot_args += ["--config", str(cfg)]
    godot_args += ["--seed", ns.seed]
    if ns.deterministic:
        godot_args += ["--deterministic-capture", "--capture-ticks", str(ns.capture_ticks)]
    if ns.mode == "seq":
        godot_args += ["--seq", str(view_dir),
                       "--seq-seconds", f"{ns.frames * ns.step:g}",
                       "--seq-step", f"{ns.step:g}"]
    else:
        godot_args += ["--screenshot", str(view_dir / "snapshot.png"),
                       "--screenshot-frames", str(ns.frames)]
    engine_timeout = max(5.0, ns.timeout - 30.0)
    godot_args += ["--timeout", f"{engine_timeout:g}"]

    job_id = f"acapt-{ns.label}-{name}"
    cmd = [sys.executable, str(RUNNER), "run",
           "--id", job_id, "--timeout", f"{ns.timeout:g}",
           "--max-wait", f"{ns.max_wait:g}", "--", *godot_args]

    view["command_line"] = cmd
    view["command_line_text"] = subprocess.list2cmdline(cmd)
    view["argv_plain"] = shlex.join(cmd)  # POSIX-style readable form
    view["output_dir"] = rel(view_dir)
    view["resolution_requested"] = config_resolution(cfg)
    print("+ " + view["command_line_text"], flush=True)

    started = time.time()
    proc = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    duration = time.time() - started
    stdout_path = view_dir / "runner_stdout.txt"
    stderr_path = view_dir / "runner_stderr.txt"
    stdout_path.write_text(proc.stdout, encoding="utf-8")
    stderr_path.write_text(proc.stderr, encoding="utf-8")
    combined = proc.stdout + ("\n" + proc.stderr if proc.stderr else "")
    ticket_match = TICKET_RE.search(combined)
    ticket = int(ticket_match.group(1)) if ticket_match else None
    result = read_runner_result(ticket)

    view.update({
        "runner_ticket": ticket,
        "runner_status": result.get("status", "unknown"),
        "runner_exit": result.get("exit", proc.returncode),
        "runner_harness_rc": proc.returncode,
        "runner_wait_s": result.get("wait"),
        "runner_run_s": result.get("run"),
        "runner_duration_s": round(duration, 3),
        "runner_stdout": rel(stdout_path),
        "runner_stderr": rel(stderr_path),
        "engine_stdout": result.get("stdout"),
        "engine_stderr": result.get("stderr"),
    })
    write_manifest(manifest)

    if ticket is None:
        raise RuntimeError(f"no runner ticket in stdout for view {name}: {combined[-800:]}")
    if proc.returncode != 0 or result.get("status") != "ok":
        raise RuntimeError(
            f"runner failed for view {name}: status={result.get('status')} "
            f"rc={proc.returncode}; see {rel(stderr_path)}")

    frames = sorted(view_dir.glob("frame_*.png"))
    if not frames:
        raise RuntimeError(f"view {name}: no frame_*.png produced in {view_dir}")
    frame_records = []
    for fp in frames:
        raster = load_rgb(fp)  # read-only; never writes or synthesises
        frame_records.append({
            "file": rel(fp),
            "sha256_file": hash_file(fp),
            "sha256_pixels": raster.pixel_hash(),
            "width": raster.w,
            "height": raster.h,
        })
    first = frame_records[0]
    view["frames"] = frame_records
    view["frame_count"] = len(frame_records)
    view["resolution_observed"] = {"width": first["width"], "height": first["height"]}
    view["resolution_matches_request"] = (
        view["resolution_requested"]["width"] == first["width"]
        and view["resolution_requested"]["height"] == first["height"])

    index_path = view_dir / "seq_index.json"
    if index_path.is_file():
        view["seq_index"] = json.loads(index_path.read_text(encoding="utf-8"))
    if ns.deterministic:
        idx = view.get("seq_index") or {}
        err = view.get("engine_stderr") or ""
        if idx.get("deterministic") is not True or idx.get("ticks_done") != ns.capture_ticks:
            raise RuntimeError(f"view {name}: tick contract missing in seq_index.json")
        if int(idx.get("capture_ticks", -1)) != ns.capture_ticks:
            raise RuntimeError(f"view {name}: capture_ticks witness mismatch")
        if int(idx.get("ticks_per_frame", -1)) != max(1, round(ns.step * ENGINE_FPS)):
            raise RuntimeError(f"view {name}: ticks_per_frame witness mismatch")
        if abs(float(idx.get("sim_seconds")) - ns.capture_ticks / ENGINE_FPS) > 1e-9:
            raise RuntimeError(f"view {name}: sim_seconds != capture_ticks/32")
        if int(idx.get("winner", -1)) != -1:
            raise RuntimeError(f"view {name}: winner set before tick budget completed")
        if view["resolution_observed"] != {"width": CAPTURE_W, "height": CAPTURE_H}:
            raise RuntimeError(f"view {name}: not 1280x720 (CPU fallback / wrong size)")
        if not view["resolution_matches_request"]:
            raise RuntimeError(f"view {name}: resolution_matches_request is false")
        for bad in ("deterministic-capture:", "watchdog:",
                    "cli: wall-clock limit reached", "fallback map render",
                    "headless map render", "blank image, retrying"):
            if bad in err:
                raise RuntimeError(f"view {name}: refusal/watchdog/fallback line in engine stderr: {bad}")
    view["requested_frames"] = ns.frames
    view["complete"] = len(frame_records) >= ns.frames
    if not view["complete"]:
        print(f"WARNING: view {name}: requested {ns.frames} frames, "
              f"got {len(frame_records)} (engine may stop on winner)", file=sys.stderr)
    print(f"[capture] {name}: {len(frame_records)} frame(s), "
          f"{first['width']}x{first['height']}, ticket {ticket}, "
          f"status {view['runner_status']}", flush=True)
    write_manifest(manifest)


def engine_stderr_text(view: dict) -> str:
    """Read the engine stderr FILE named by a view record (a path, not content)."""
    rel_path = view.get("engine_stderr")
    if not isinstance(rel_path, str) or not rel_path:
        return ""
    path = Path(rel_path)
    if not path.is_absolute():
        path = ROOT / path
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def repeat_stderr_violations(view: dict) -> list[str]:
    """Refusal/watchdog/fallback markers in a view's real engine stderr."""
    text = engine_stderr_text(view)
    return [marker for marker in REPEAT_STDERR_MARKERS if marker in text]


def _repeat_seconds(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return value


def _run_repeat_pass(ns: argparse.Namespace, out: Path) -> dict:
    """Second identical deterministic submission into a sibling output dir."""
    repeat_out = out.parent / (out.name + REPEAT_SUFFIX)
    prior = sorted(repeat_out.glob("*/frame_*.png")) + sorted(
        repeat_out.glob("*/seq_index.json"))
    if prior:
        raise RuntimeError(
            f"repeat dir {repeat_out} already holds {len(prior)} capture artifact(s); "
            "use a fresh --out (frames are never deleted)")
    repeat_out.mkdir(parents=True, exist_ok=True)
    repeat_lock = repeat_out / ".capture.lock"
    try:
        fd = os.open(repeat_lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        raise RuntimeError(
            f"repeat pass refused: another capture holds {repeat_lock}")
    os.write(fd, f"{os.getpid()} {utc_now()}\n".encode("utf-8"))
    os.close(fd)

    repeat_manifest: dict = {
        "_path": repeat_out / "manifest.json",
        "tool": "capture_sequence.py",
        "schema": 1,
        "role": "repeat_verification_pass",
        "parity": "UNVERIFIED",
        "generated_utc": utc_now(),
        "primary_manifest": rel(out / "manifest.json"),
        "seed": ns.seed,
        "deterministic": True,
        "deterministic_capture": ns.deterministic,
        "capture_ticks": ns.capture_ticks,
        "frames": ns.frames,
        "step_s": ns.step,
        "views": [],
        "status": "running",
    }
    repeat_ns = argparse.Namespace(**vars(ns))
    repeat_ns.out = str(repeat_out)
    try:
        for idx, (name, cfg) in enumerate(ns.view, start=1):
            entry = {
                "name": name,
                "config": rel(cfg) if cfg is not None else None,
                "config_abs": str(cfg) if cfg is not None else None,
                "config_sha256_file": hash_file(cfg) if cfg is not None else None,
                "config_controlled": cfg is not None,
                "audio_seed": int(ns.seed),
                "audio_seed_note": (
                    "cosmetic-only audio_rng seed (not a simulation RNG stream)"),
            }
            repeat_manifest["views"].append(entry)
            capture_view(repeat_ns, entry, idx, repeat_manifest)
        if not all(v.get("complete", False) for v in repeat_manifest["views"]):
            raise RuntimeError("repeat pass incomplete (engine stopped early)")
        repeat_manifest["status"] = "ok"
    except Exception as exc:
        repeat_manifest["status"] = "failed"
        repeat_manifest["error"] = repr(exc)
        raise
    finally:
        repeat_manifest["finished_utc"] = utc_now()
        write_manifest(repeat_manifest)
        try:
            repeat_lock.unlink()
        except OSError:
            pass
    return repeat_manifest


def _finish_repeat(report: dict, path: Path, primary: dict) -> None:
    atomic_json(path, report)
    try:
        primary["repeat_verification"] = {
            "path": rel(path),
            "byte_identical": report["byte_identical"],
            "status": report["status"],
            "mismatch_count": len(report["mismatches"]),
            "note": "port-internal repeatability only; never donor parity",
        }
        write_manifest(primary)
    except Exception:
        pass


def verify_repeat(ns: argparse.Namespace, out: Path, primary: dict) -> bool:
    """Second deterministic pass + byte-level comparison; writes repeat_verification.json.

    Port-internal repeatability only: no ROI/threshold is read, changed or
    relaxed here, and no donor comparison is made (parity stays UNVERIFIED).
    """
    verification_path = out / "repeat_verification.json"
    report: dict = {
        "tool": "capture_sequence.py",
        "schema": 1,
        "generated_utc": utc_now(),
        "kind": "port-internal repeatability gate (NOT donor parity)",
        "parity": "UNVERIFIED (not assessed)",
        "seed": ns.seed,
        "frames": ns.frames,
        "step_s": ns.step,
        "capture_ticks": ns.capture_ticks,
        "expected_resolution": [CAPTURE_W, CAPTURE_H],
        "primary_manifest": rel(out / "manifest.json"),
        "byte_identical": False,
        "checks": [],
        "mismatches": [],
        "status": "fail",
    }
    try:
        repeat_manifest = _run_repeat_pass(ns, out)
    except Exception as exc:
        report["mismatches"].append(f"repeat pass failed: {exc!r}")
        _finish_repeat(report, verification_path, primary)
        print("REPEAT VERIFICATION FAILED (port-internal, not donor parity): "
              f"repeat pass failed: {exc!r}", file=sys.stderr)
        return False

    report["repeat_manifest"] = rel(repeat_manifest["_path"])
    report["repeat_out"] = rel(repeat_manifest["_path"].parent)
    primary_views = {v["name"]: v for v in primary.get("views", [])}
    repeat_views = {v["name"]: v for v in repeat_manifest.get("views", [])}
    target_resolution = {"width": CAPTURE_W, "height": CAPTURE_H}

    for name, _cfg in ns.view:
        pv = primary_views.get(name, {})
        rv = repeat_views.get(name, {})
        pf = pv.get("frames", [])
        rf = rv.get("frames", [])
        p_sim = (pv.get("seq_index") or {}).get("sim_seconds")
        r_sim = (rv.get("seq_index") or {}).get("sim_seconds")
        check: dict = {
            "view": name,
            "primary_frames": len(pf),
            "repeat_frames": len(rf),
            "frame_count_match": len(pf) == len(rf) and len(pf) > 0,
            "resolution_primary": pv.get("resolution_observed"),
            "resolution_repeat": rv.get("resolution_observed"),
            "resolution_ok": (pv.get("resolution_observed") == target_resolution
                              and rv.get("resolution_observed") == target_resolution),
            "sim_seconds_primary": p_sim,
            "sim_seconds_repeat": r_sim,
            "sim_seconds_match": (p_sim is not None
                                  and _repeat_seconds(p_sim) == _repeat_seconds(r_sim)),
            "engine_stderr_path_primary": pv.get("engine_stderr"),
            "engine_stderr_path_repeat": rv.get("engine_stderr"),
            "stderr_violations_primary": repeat_stderr_violations(pv),
            "stderr_violations_repeat": repeat_stderr_violations(rv),
            "frames": [],
            "match": False,
        }
        check["stderr_clean_primary"] = not check["stderr_violations_primary"]
        check["stderr_clean_repeat"] = not check["stderr_violations_repeat"]
        for i in range(min(len(pf), len(rf))):
            a, b = pf[i], rf[i]
            check["frames"].append({
                "index": i,
                "primary_file": a.get("file"),
                "repeat_file": b.get("file"),
                "sha256_file": {
                    "primary": a.get("sha256_file"),
                    "repeat": b.get("sha256_file"),
                    "match": a.get("sha256_file") == b.get("sha256_file"),
                },
                "sha256_pixels": {
                    "primary": a.get("sha256_pixels"),
                    "repeat": b.get("sha256_pixels"),
                    "match": a.get("sha256_pixels") == b.get("sha256_pixels"),
                },
            })
        check["match"] = bool(
            check["frame_count_match"] and check["resolution_ok"]
            and check["sim_seconds_match"]
            and check["stderr_clean_primary"] and check["stderr_clean_repeat"]
            and all(f["sha256_file"]["match"] and f["sha256_pixels"]["match"]
                    for f in check["frames"]))
        report["checks"].append(check)
        if check["match"]:
            continue
        reasons: list[str] = []
        if not check["frame_count_match"]:
            reasons.append(f"frame count {len(pf)} != {len(rf)}")
        if not check["resolution_ok"]:
            reasons.append(f"resolution primary={check['resolution_primary']} "
                           f"repeat={check['resolution_repeat']} (want 1280x720)")
        if not check["sim_seconds_match"]:
            reasons.append(f"sim_seconds primary={p_sim!r} repeat={r_sim!r}")
        if not check["stderr_clean_primary"]:
            reasons.append(f"primary stderr markers={check['stderr_violations_primary']}")
        if not check["stderr_clean_repeat"]:
            reasons.append(f"repeat stderr markers={check['stderr_violations_repeat']}")
        for frame in check["frames"]:
            if not frame["sha256_file"]["match"]:
                reasons.append(f"frame {frame['index']} sha256_file "
                               f"{frame['sha256_file']['primary']} != "
                               f"{frame['sha256_file']['repeat']}")
            if not frame["sha256_pixels"]["match"]:
                reasons.append(f"frame {frame['index']} sha256_pixels "
                               f"{frame['sha256_pixels']['primary']} != "
                               f"{frame['sha256_pixels']['repeat']}")
        report["mismatches"].append(f"view {name}: " + "; ".join(reasons))

    report["byte_identical"] = bool(report["checks"]) and not report["mismatches"]
    report["status"] = "pass" if report["byte_identical"] else "fail"
    _finish_repeat(report, verification_path, primary)
    if report["byte_identical"]:
        print(f"[repeat] byte_identical=TRUE: {len(report['checks'])} view(s), "
              f"{sum(len(c['frames']) for c in report['checks'])} frame(s); "
              "parity=UNVERIFIED", flush=True)
    else:
        print("REPEAT VERIFICATION FAILED (port-internal repeatability only, "
              "NOT donor parity):", file=sys.stderr)
        for mismatch in report["mismatches"]:
            print("  - " + mismatch, file=sys.stderr)
        print(f"  report: {rel(verification_path)}", file=sys.stderr)
    return report["byte_identical"]


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--seed", required=True, metavar="INT|random",
                    help="explicit integer seed (deterministic) or literal 'random'")
    ap.add_argument("--frames", required=True, type=int, metavar="N",
                    help="frames requested per view (1..600; engine seq cap 600)")
    ap.add_argument("--step", type=float, default=1.0, metavar="SECONDS",
                    help="sim seconds between seq frames (0.25..30, default 1)")
    ap.add_argument("--view", action="append", default=[], type=parse_view,
                    metavar="NAME[=CONFIG.json]",
                    help="camera/preset view; repeatable, submitted strictly in order")
    ap.add_argument("--out", required=True, metavar="DIR",
                    help="fresh output directory under inbox/qa/captures/ recommended")
    ap.add_argument("--label", default="capture", metavar="SLUG",
                    help="runner job-id prefix (default: capture)")
    ap.add_argument("--mode", choices=("seq", "shot"), default="seq",
                    help="seq = frame sequence via --seq; shot = one --screenshot PNG")
    ap.add_argument("--headless", action="store_true",
                    help="headless: engine saves a CPU map timelapse, NOT a real "
                         "viewport frame; default is windowed viewport capture")
    ap.add_argument("--timeout", type=float, default=240.0,
                    help="runner hard per-job timeout in seconds (default 240)")
    ap.add_argument("--max-wait", type=float, default=3600.0,
                    help="max FIFO queue wait in seconds (default 3600)")
    ap.add_argument("--deterministic", action="store_true",
                    help="opt-in fixed-step capture; windowed --seq only by default")
    ap.add_argument("--capture-ticks", type=int, default=None, metavar="N",
                    help="exact fixed tick count; required with --deterministic")
    ap.add_argument("--verify-repeat", action="store_true",
                    help="port-internal repeatability gate ONLY (NOT donor parity): "
                         "submit a second identical deterministic capture into a "
                         "sibling <out>_repeat dir and fail non-zero on any mismatch")
    ns = ap.parse_args(argv)

    if not 1 <= ns.frames <= 600:
        ap.error("--frames must be between 1 and 600 (engine seq_max)")
    if not 0.25 <= ns.step <= 30.0:
        ap.error("--step must be between 0.25 and 30.0 sim seconds")
    seq_seconds = ns.frames * ns.step
    if ns.mode == "seq" and not (1.0 <= seq_seconds <= 600.0):
        ap.error("--frames * --step must fall in [1, 600] for --seq-seconds")
    if not SLUG_RE.match(ns.label):
        ap.error("--label must be a simple slug")
    if not ns.view:
        ap.error("at least one --view is required (use NAME for engine defaults)")
    if ns.deterministic:
        if ns.headless or ns.mode == "shot":
            ap.error("--deterministic requires windowed --seq (no --headless/--mode shot)")
        tpf = max(1, round(ns.step * ENGINE_FPS))
        if ns.capture_ticks is None or ns.capture_ticks <= 0:
            ap.error("--capture-ticks N (>0) is required with --deterministic")
        if ns.capture_ticks != ns.frames * tpf:
            ap.error(f"--capture-ticks must equal frames*max(1,round(step*32))={ns.frames * tpf}")
    names = [v[0] for v in ns.view]
    if len(set(names)) != len(names):
        ap.error("--view names must be unique")
    deterministic = ns.seed != "random"
    if not deterministic:
        print("WARNING: seed=random is NOT deterministic; manifest says so", file=sys.stderr)
    else:
        try:
            int(ns.seed)
        except ValueError:
            ap.error("--seed must be an integer or the literal 'random'")
    if ns.verify_repeat:
        if not ns.deterministic or not deterministic:
            ap.error("--verify-repeat requires --deterministic with an integer --seed; "
                     "it is a port-internal repeatability gate, not donor parity")

    out = Path(ns.out)
    if not out.is_absolute():
        out = (ROOT / out).resolve()
    ns.out = str(out)
    out.mkdir(parents=True, exist_ok=True)
    lock_path = out / ".capture.lock"
    try:
        fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        print(f"REFUSED: another capture holds {lock_path}. "
              "Sequential-only: do not run two harnesses. Remove the lock only "
              "after confirming no capture process is alive.", file=sys.stderr)
        return EXIT_BAD
    os.write(fd, f"{os.getpid()} {utc_now()}\n".encode("utf-8"))
    os.close(fd)

    manifest_path = out / "manifest.json"
    manifest: dict = {
        "_path": manifest_path,  # internal; removed by write_manifest()
        "tool": "capture_sequence.py",
        "schema": 1,
        "generated_utc": utc_now(),
        "parity": "UNVERIFIED",
        "runner": rel(RUNNER),
        "runner_python": sys.executable,
        "godot_on_path": shutil.which("godot"),
        "project": rel(PROJECT),
        "seed": ns.seed,
        "deterministic": deterministic,
        "deterministic_capture": ns.deterministic,
        "capture_ticks": ns.capture_ticks if ns.deterministic else None,
        "engine_fps_anchor": "variant3d/scripts/data.gd:246",
        "expected_sim_seconds": (ns.capture_ticks / ENGINE_FPS) if ns.deterministic else None,
        "expected_resolution": [CAPTURE_W, CAPTURE_H] if ns.deterministic else None,
        "mode": ns.mode,
        "headless": ns.headless,
        "capture_semantics": (
            "headless seq = CPU map timelapse, NOT viewport frames"
            if ns.headless else
            "windowed seq = real viewport frames (frame_post_draw)"),
        "requested_frames_per_view": ns.frames,
        "step_s": ns.step,
        "seq_seconds": seq_seconds if ns.mode == "seq" else None,
        "timeouts": {"runner_s": ns.timeout, "max_wait_s": ns.max_wait,
                     "engine_s": max(5.0, ns.timeout - 30.0)},
        "parallelism": {"submissions": "strictly sequential",
                        "godot_processes": "one at a time via godot_runner.py FIFO",
                        "harness_lock": rel(lock_path)},
        "views": [],
        "status": "running",
    }

    exit_code = EXIT_OK
    try:
        for idx, (name, cfg) in enumerate(ns.view, start=1):
            entry = {"name": name,
                     "config": rel(cfg) if cfg is not None else None,
                     "config_abs": str(cfg) if cfg is not None else None,
                     "config_sha256_file": hash_file(cfg) if cfg is not None else None,
                     "config_controlled": cfg is not None,
                     "audio_seed": int(ns.seed) if deterministic else None,
                     "audio_seed_note": "cosmetic-only audio_rng seed (not a simulation RNG stream)"}
            manifest["views"].append(entry)
            try:
                capture_view(ns, entry, idx, manifest)
            except Exception as exc:  # keep the partial manifest as evidence
                entry["error"] = repr(exc)
                manifest["status"] = "failed"
                write_manifest(manifest)
                print(f"ERROR: {exc}", file=sys.stderr)
                exit_code = EXIT_FAILED
                break
        else:
            if not all(v.get("complete", False) for v in manifest["views"]):
                manifest["status"] = "incomplete"
                exit_code = EXIT_FAILED
            else:
                manifest["status"] = "ok"
    finally:
        manifest["finished_utc"] = utc_now()
        manifest["status"] = manifest["status"] if manifest["status"] in (
            "ok", "failed", "incomplete") else "failed"
        write_manifest(manifest)
        try:
            lock_path.unlink()
        except OSError:
            pass

    if ns.verify_repeat and exit_code == EXIT_OK:
        if not verify_repeat(ns, out, manifest):
            exit_code = EXIT_FAILED

    print(f"[capture] manifest: {rel(manifest_path)} (status={manifest['status']})")
    print("parity=UNVERIFIED (a capture is evidence, never a donor-parity claim)")
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
