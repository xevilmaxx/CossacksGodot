#!/usr/bin/env python3
"""
bake_bench.py - QA-1 / TR-6 harness: drive the serialized Godot runner on the
LOW preset and parse its stdout for chunk-bake timing.

HONESTY CONTRACT (read this before using the output)
----------------------------------------------------
RENDER-1 added a one-shot `BAKE_BENCH ... max_ms=<n> mean_ms=<m>` print to
world.gd::_sync_terrain_chunks (emitted on the 120th bake, or on exit if fewer
bakes occurred). Only an explicit, engine-emitted BAKE_BENCH line can produce a
numeric verdict; `PERF ... sync_ms=X` remains CONTEXT ONLY (it is the mean of
TOTAL world.sync() over 120 frames, not a bake maximum).

CAVEATS THAT MUST ACCOMPANY ANY VERDICT:
  * The `preset=low`, `px=8` and `chunks=120` fields in the engine line are
    HARDCODED contract labels, not measurements. Verify the effective preset
    independently with `--dump-config` (config path must be ABSOLUTE; a relative
    'app/shots/...' path is silently ignored by config.gd::_candidate_paths).
  * The true bake count is not emitted. A static-camera capture typically bakes
    only a handful of chunks, so the line is usually flushed at exit; `max_ms`
    can be dominated by the first, cold-cache bake (image loads, cache warm-up).
    That is a real single-frame bake time, but it is not a steady-state figure.
  * main.gd's `--bench` mode SKIPS world.sync() when headless (main.gd:1000), so
    this harness deliberately uses a 120-frame `--screenshot` capture instead.

Godot is NEVER launched directly: every invocation goes through
app/tools/godot_runner.py run (FIFO lock, hard timeout, isolated spool).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RUNNER = ROOT / "app" / "tools" / "godot_runner.py"
RESULTS = ROOT / "app" / ".godot_queue" / "results"
TARGET_MS = 250.0

# A deliberately strict pattern: only an explicit, engine-emitted bake line can
# produce a numeric verdict. Never infer one from PERF/sync_ms or wall time.
BAKE_RE = re.compile(
    r"BAKE_BENCH\b(?P<tail>.*)", re.IGNORECASE
)
KEY_RE = re.compile(r"(\w+)\s*=\s*(-?\d+(?:\.\d+)?)")
PERF_SYNC_RE = re.compile(r"PERF\b.*?sync_ms\s*=\s*(\d+(?:\.\d+)?)")
TICKET_RE = re.compile(r"ticket\s+(\d+)")


def run_via_runner(job_id: str, timeout: float, max_wait: float, frames: int,
                   config: str, shot: str) -> tuple[int, str, int | None]:
    """Submit one headless LOW-preset capture job; return (rc, runner_stdout, ticket)."""
    # config.gd::_candidate_paths() only accepts an ABSOLUTE extra path (a bare
    # relative 'app/shots/..' fails: verified via --dump-config on 2026-11-21).
    cfg_path = str(Path(config).resolve()) if not Path(config).is_absolute() else config
    godot_args = [
        "--headless", "--path", "app", "--",
        "--config", cfg_path,
        "--screenshot", shot,
        "--screenshot-frames", str(frames),
        "--timeout", str(max(5.0, timeout - 30.0)),
    ]
    cmd = [
        sys.executable, str(RUNNER), "run",
        "--id", job_id,
        "--timeout", str(timeout),
        "--max-wait", str(max_wait),
        "--", *godot_args,
    ]
    print("[bake_bench] submitting via runner:", " ".join(cmd), flush=True)
    proc = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    out = proc.stdout + ("\n" + proc.stderr if proc.stderr else "")
    print(out, end="" if out.endswith("\n") else "\n", flush=True)
    tickets = TICKET_RE.findall(out)
    ticket = int(tickets[0]) if tickets else None
    return proc.returncode, out, ticket


def load_result(ticket: int | None) -> dict:
    if ticket is None:
        return {}
    p = RESULTS / f"{ticket:08d}.json"
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def read_engine_stdout(result: dict) -> str:
    rel = result.get("stdout", "")
    if not rel:
        return ""
    p = Path(rel) if Path(rel).is_absolute() else ROOT / rel
    try:
        return p.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def parse_bake(stdout: str) -> dict | None:
    """Parse an explicit BAKE_BENCH line; require max_ms to be present."""
    for line in stdout.splitlines():
        m = BAKE_RE.search(line)
        if not m:
            continue
        kv = {k.lower(): float(v) for k, v in KEY_RE.findall(m.group("tail"))}
        if "max_ms" in kv:
            return {
                "raw": line.strip(),
                "max_ms": kv["max_ms"],
                "mean_ms": kv.get("mean_ms"),
                "chunks": kv.get("chunks"),
                "verdict": "PASS" if kv["max_ms"] < TARGET_MS else "FAIL",
            }
    return None


def parse_perf(stdout: str) -> float | None:
    for line in stdout.splitlines():
        m = PERF_SYNC_RE.search(line)
        if m:
            return float(m.group(1))
    return None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--id", default="qa1-bench-1", help="runner job id")
    ap.add_argument("--timeout", type=float, default=240.0, help="runner hard timeout (s)")
    ap.add_argument("--max-wait", type=float, default=3600.0, help="max FIFO queue wait (s)")
    ap.add_argument("--frames", type=int, default=120, help="frames to draw")
    ap.add_argument("--config", default="app/shots/perf_low.json")
    ap.add_argument("--shot", default=str(
        Path(os.environ.get("TEMP", "/tmp")) / "qa1_bake_bench.png"
    ))
    ap.add_argument("--report", default=str(
        Path(os.environ.get("TEMP", "/tmp")) / "qa1_bake_bench_result.json"
    ))
    ns = ap.parse_args()

    rc, runner_out, ticket = run_via_runner(
        ns.id, ns.timeout, ns.max_wait, ns.frames, ns.config, ns.shot
    )
    result = load_result(ticket)
    engine_out = read_engine_stdout(result)
    bake = parse_bake(engine_out)
    perf_sync = parse_perf(engine_out)

    report = {
        "job_id": ns.id,
        "ticket": ticket,
        "runner_status": result.get("status"),
        "runner_exit": result.get("exit"),
        "runner_wait_s": result.get("wait"),
        "runner_run_s": result.get("run"),
        "settings": {
            "preset": "low",
            "config": str(Path(ns.config).resolve()),
            "frames": ns.frames,
            "chunks_per_frame_cap": 2,
            "lru_cap": 24,
        },
        "n07_target_ms": TARGET_MS,
        "bake": bake,  # None => UNVERIFIED
        "context_perf_mean_total_sync_ms": perf_sync,
        "context_note": (
            "context_perf_mean_total_sync_ms is the MEAN of TOTAL world.sync() "
            "over 120 frames, NOT a max and NOT chunk-bake-only. Never use it "
            "to pass N-07."
        ),
        "verdict": (bake["verdict"] if bake else "UNVERIFIED"),
        "caveats": (
            "BAKE_BENCH preset/px/chunks fields are hardcoded by world.gd, not "
            "measured; verify preset via --dump-config. Actual bake count is "
            "not emitted; max_ms may be a cold-cache first bake."
        ) if bake else None,
        "blocker": (None if bake else
                    "BAKE_BENCH line absent from engine stdout. Check runner "
                    "status/stdout and that world.gd instrumentation is present."),
    }

    report_path = Path(ns.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print("\n[bake_bench] RESULT")
    print(json.dumps(report, indent=2))
    print(f"[bake_bench] report written to {report_path}")
    # Exit 0 = harness ran; the verdict (PASS/FAIL/UNVERIFIED) is in the report.
    return 0 if rc == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
