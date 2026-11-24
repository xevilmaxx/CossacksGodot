#!/usr/bin/env python3
"""
assert_clean.py - read-only clean gate for the Godot runner.

N-20 / "Godot never hangs": after a release-gate job (selftest, uitest, CLI,
screenshot) has returned, assert that the machine is clean:

  1. no Godot process is still alive (orphan / zombie),
  2. godot.lock is free, or at least not older than --max-lock-age,
  3. status.json history contains no job in {timed-out, error, skipped}
     (suppress with --ignore-history when historical failures are accepted).

This tool NEVER kills anything and NEVER writes to the spool. It is an
assertion only. Remediation stays the runner's job:

   python app/tools/godot_runner.py doctor

Exit codes: 0 = clean, 1 = dirty, 2 = bad invocation.

Paths are derived from __file__, so the tool works from any cwd, exactly like
godot_runner.py.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPOOL = ROOT / "app" / ".godot_queue"
GODOT_LOCK = SPOOL / "godot.lock"
STATUS = SPOOL / "status.json"

# Keep in sync with godot_runner.py STALE_SEC (a lock older than this is dead).
DEFAULT_MAX_LOCK_AGE = 300.0
# The failure set defined by N-20. "failed" (non-zero exit) is deliberately
# NOT here: a test can fail cleanly; a timed-out/error/skipped job leaked.
FAILURE_STATUSES = {"timed-out", "error", "skipped"}


# ---------------------------------------------------------------------------
# signal 1: running Godot processes
# ---------------------------------------------------------------------------
def godot_processes() -> list[dict]:
    """Return [{pid, name, command}, ...] for every live Godot process."""
    if sys.platform == "win32":
        ps = (
            "Get-CimInstance Win32_Process -Filter \"Name like 'Godot%'\" | "
            "Select-Object ProcessId,Name,CommandLine | ConvertTo-Json -Compress"
        )
        try:
            out = subprocess.run(
                ["powershell", "-NoProfile", "-Command", ps],
                capture_output=True, text=True, timeout=15,
            ).stdout.strip()
        except (OSError, subprocess.SubprocessError):
            return []
        if not out:
            return []
        try:
            data = json.loads(out)
        except ValueError:
            return []
        if isinstance(data, dict):
            data = [data]
        procs = []
        for p in data:
            if not isinstance(p, dict):
                continue
            pid = p.get("ProcessId")
            if pid is None or int(pid) == os.getpid():
                continue
            procs.append({
                "pid": int(pid),
                "name": p.get("Name") or "",
                "command": p.get("CommandLine") or "",
            })
        return procs

    # POSIX: pgrep. Prefer -a (pid + full command); fall back to pids only.
    try:
        r = subprocess.run(["pgrep", "-a", "-f", "godot"],
                           capture_output=True, text=True, timeout=15)
        if r.returncode not in (0, 1):
            r = subprocess.run(["pgrep", "-f", "godot"],
                               capture_output=True, text=True, timeout=15)
        lines = r.stdout.splitlines()
    except (OSError, subprocess.SubprocessError):
        return []
    procs = []
    for line in lines:
        parts = line.strip().split(None, 1)
        if not parts or not parts[0].isdigit():
            continue
        pid = int(parts[0])
        if pid == os.getpid():
            continue
        procs.append({
            "pid": pid,
            "name": "godot",
            "command": parts[1] if len(parts) > 1 else "",
        })
    return procs


def check_processes() -> dict:
    procs = godot_processes()
    return {"clean": not procs, "count": len(procs), "details": procs}


# ---------------------------------------------------------------------------
# signal 2: godot.lock presence and age
# ---------------------------------------------------------------------------
def check_lock(max_age: float) -> dict:
    result = {
        "clean": True, "exists": False, "state": "free",
        "age_sec": None, "max_age_sec": max_age,
    }
    try:
        raw = GODOT_LOCK.read_text(encoding="utf-8")
    except OSError:
        return result  # no lock -> free

    result["exists"] = True
    # Runner writes "<ticket> <epoch>"; fall back to file mtime if unparsable.
    age = None
    try:
        age = time.time() - float(raw.split()[1])
    except (ValueError, IndexError):
        try:
            age = time.time() - GODOT_LOCK.stat().st_mtime
        except OSError:
            pass

    result["age_sec"] = age
    if age is None:
        result.update(clean=False, state="held_unknown_age")
    elif age > max_age:
        result.update(clean=False, state="stale")
    else:
        # A young lock is allowed: a runner job may be in flight. The process
        # signal above is the authoritative orphan check.
        result.update(clean=True, state="held_recent")
    return result


# ---------------------------------------------------------------------------
# signal 3: historical failures in status.json
# ---------------------------------------------------------------------------
def check_history(ignore: bool) -> dict:
    if ignore:
        return {"clean": True, "enabled": False, "total": None, "failures": []}

    try:
        data = json.loads(STATUS.read_text(encoding="utf-8"))
        hist = data.get("history", [])
        if not isinstance(hist, list):
            hist = []
    except (OSError, ValueError):
        hist = []

    failures = []
    acknowledged = 0
    for h in hist:
        if not isinstance(h, dict) or h.get("status") not in FAILURE_STATUSES:
            continue
        # A failure that a worker fixed and the coordinator acknowledged is
        # no longer a live hang signal. `godot_runner.py ack` sets this flag.
        if h.get("acknowledged"):
            acknowledged += 1
            continue
        failures.append({
            "ticket": h.get("ticket"),
            "id": h.get("id"),
            "status": h.get("status"),
            "error": h.get("error", ""),
        })
    return {
        "clean": not failures,
        "enabled": True,
        "total": len(hist),
        "acknowledged": acknowledged,
        "failures": failures,
    }


# ---------------------------------------------------------------------------
# reporting
# ---------------------------------------------------------------------------
def _short(s: str, n: int = 120) -> str:
    s = str(s)
    return s if len(s) <= n else s[: n - 3] + "..."


def build_report(procs: dict, lock: dict, hist: dict, clean: bool) -> dict:
    reasons = []
    if not procs["clean"]:
        reasons.append(f"{procs['count']} Godot process(es) alive")
    if not lock["clean"]:
        if lock["state"] == "stale":
            reasons.append(
                f"stale godot.lock ({lock['age_sec']:.1f}s > "
                f"{lock['max_age_sec']:.1f}s)"
            )
        else:
            reasons.append("godot.lock held with unknown age")
    if not hist["clean"]:
        reasons.append(f"{len(hist['failures'])} failed job(s) in status.json")
    return {
        "clean": clean,
        "verdict": "CLEAN" if clean else "DIRTY",
        "reasons": reasons,
        "checks": {"processes": procs, "lock": lock, "history": hist},
    }


def print_text(report: dict) -> None:
    c = report["checks"]
    procs, lock, hist = c["processes"], c["lock"], c["history"]
    print("[assert_clean] Godot clean gate")

    if procs["clean"]:
        print("  processes : OK - 0 Godot processes alive")
    else:
        print(f"  processes : DIRTY - {procs['count']} Godot process(es) alive")
        for p in procs["details"]:
            print(f"      PID {p['pid']} [{p['name']}] {_short(p['command'])}")

    if lock["state"] == "free":
        print("  lock      : OK - godot.lock free")
    elif lock["state"] == "held_recent":
        print(f"  lock      : OK - held {lock['age_sec']:.1f}s "
              f"(max {lock['max_age_sec']:.1f}s; job may be in flight)")
    elif lock["state"] == "stale":
        print(f"  lock      : DIRTY - stale {lock['age_sec']:.1f}s "
              f"(max {lock['max_age_sec']:.1f}s)")
    else:
        print("  lock      : DIRTY - held, age unreadable")

    if not hist["enabled"]:
        print("  history   : OK - ignored (--ignore-history)")
    elif hist["clean"]:
        print(f"  history   : OK - 0 failure(s) in {hist['total']} job(s) "
              f"[{','.join(sorted(FAILURE_STATUSES))}]")
    else:
        print(f"  history   : DIRTY - {len(hist['failures'])} failure(s) "
              f"in {hist['total']} job(s)")
        for f in hist["failures"]:
            extra = f" error={_short(f['error'], 80)}" if f["error"] else ""
            print(f"      ticket {f['ticket']} id={f['id']} "
                  f"status={f['status']}{extra}")

    tail = "; ".join(report["reasons"]) if report["reasons"] else "all checks passed"
    print(f"VERDICT: {report['verdict']} - {tail} "
          f"(exit {0 if report['clean'] else 1})")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", action="store_true",
                    help="emit a single machine-readable JSON object")
    ap.add_argument("--max-lock-age", type=float, default=DEFAULT_MAX_LOCK_AGE,
                    metavar="SEC",
                    help=f"lock older than SEC seconds is stale "
                         f"(default: {DEFAULT_MAX_LOCK_AGE:.0f}, runner STALE_SEC)")
    ap.add_argument("--ignore-history", action="store_true",
                    help="ignore historical timed-out/error/skipped jobs in status.json")
    ns = ap.parse_args()

    if ns.max_lock_age < 0:
        print("ERROR: --max-lock-age must be >= 0", file=sys.stderr)
        return 2

    procs = check_processes()
    lock = check_lock(ns.max_lock_age)
    hist = check_history(ns.ignore_history)
    clean = procs["clean"] and lock["clean"] and hist["clean"]
    report = build_report(procs, lock, hist, clean)

    if ns.json:
        print(json.dumps(report, indent=2))
    else:
        print_text(report)
    return 0 if clean else 1


if __name__ == "__main__":
    raise SystemExit(main())
