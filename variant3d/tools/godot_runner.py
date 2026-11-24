#!/usr/bin/env python3
"""
godot_runner.py - the single door through which every Godot launch must pass.

Why this exists
---------------
When several agents work on the port at once, letting each one run `godot`
directly produces two failures:
  1. mutual exclusion is violated (two Godot processes fight over app/.godot,
     imports, screenshots and test output);
  2. a script that hangs (e.g. quit() in _initialize()) leaks a 100%-CPU zombie
     forever and starves every later job.

This runner fixes both:
  * FIFO ticket lock  -> exactly one Godot at a time, and bounded waiting
                         (no starvation: ticket N+1 cannot pass ticket N).
  * hard timeout      -> the process *tree* is killed after --timeout seconds.
  * spool isolation   -> every job owns its result/error directories, so two
                         jobs can never clobber each other's screenshots.
  * stale recovery    -> if a worker dies mid-job, the next ticket reclaims the
                         lock after STALE_SEC instead of blocking forever.
  * telemetry         -> status.json records wait/run durations and the max
                         wait, so "no starvation" is measurable, not a claim.

Usage (workers MUST use `run`, never invoke godot themselves):
  python app/tools/godot_runner.py run --id selftest --timeout 120 -- \
      --headless --path app -- --self-test app/selftest.json
  python app/tools/godot_runner.py run --id shot_l1 --timeout 90 -- \
      --path app -- --screenshot app/shots/g4_l1.png --timeout 60
  python app/tools/godot_runner.py status
  python app/tools/godot_runner.py doctor      # kill orphaned godot processes
  python app/tools/godot_runner.py reset --yes # clear lock state (maintenance)
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]          # project root
SPOOL = ROOT / "variant3d" / ".godot_queue"
JOBS = SPOOL / "jobs"
RESULTS = SPOOL / "results"
COUNTER = SPOOL / "counter"
SERVING = SPOOL / "now_serving"
GODOT_LOCK = SPOOL / "godot.lock"
STATUS = SPOOL / "status.json"
STALE_SEC = 300.0          # reclaim a dead ticket after this long
POLL_SEC = 0.15

GODOT = shutil.which("godot") or "godot"


# ---------------------------------------------------------------------------
# tiny atomic file helpers (atomic = write temp, then os.replace)
# ---------------------------------------------------------------------------
def atomic_write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text)
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp, path)


def read_int(path: Path, default: int = 0) -> int:
    try:
        return int(path.read_text(encoding="utf-8").strip())
    except (OSError, ValueError):
        return default


def spinner_lock():
    """Short-lived exclusive lock for counter/serving mutations."""
    class Lock:
        def __init__(self, p: Path):
            self.p = p
            self.fd = None

        def __enter__(self):
            for _ in range(2000):
                try:
                    self.fd = os.open(self.p, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                    return self
                except FileExistsError:
                    time.sleep(0.005)
            raise RuntimeError("could not acquire spool lock")

        def __exit__(self, *a):
            if self.fd is not None:
                os.close(self.fd)
                try:
                    self.p.unlink()
                except OSError:
                    pass

    return Lock(SPOOL / "spool.lock")


def ensure_spool() -> None:
    for d in (SPOOL, JOBS, RESULTS):
        d.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# ticket allocation (FIFO - the anti-starvation guarantee)
# ---------------------------------------------------------------------------
def take_ticket(job_id: str, argv: list[str], timeout: float) -> int:
    ensure_spool()
    with spinner_lock():
        ticket = read_int(COUNTER)
        atomic_write(COUNTER, str(ticket + 1))
        job = {
            "id": job_id,
            "ticket": ticket,
            "argv": argv,
            "timeout": timeout,
            "created": time.time(),
            "pid": os.getpid(),
        }
        atomic_write(JOBS / f"{ticket:08d}.json", json.dumps(job))
    return ticket


def job_path(ticket: int) -> Path:
    return JOBS / f"{ticket:08d}.json"


def load_job(ticket: int) -> dict | None:
    p = job_path(ticket)
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def claim_godot_lock(ticket: int) -> bool:
    """O_EXCL exclusivity, refreshed with the serving ticket's timestamp."""
    try:
        fd = os.open(GODOT_LOCK, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        os.write(fd, f"{ticket} {time.time():.3f}".encode())
        os.close(fd)
        return True
    except FileExistsError:
        return False


def release_godot_lock() -> None:
    try:
        GODOT_LOCK.unlink()
    except OSError:
        pass


def godot_lock_age() -> float:
    try:
        parts = GODOT_LOCK.read_text(encoding="utf-8").split()
        return time.time() - float(parts[1])
    except (OSError, ValueError, IndexError):
        return 0.0


def advance_serving(expected: int) -> bool:
    with spinner_lock():
        if read_int(SERVING) == expected:
            atomic_write(SERVING, str(expected + 1))
            return True
    return False


def record(result: dict) -> None:
    ensure_spool()
    ticket = result["ticket"]
    atomic_write(RESULTS / f"{ticket:08d}.json", json.dumps(result, indent=2))
    hist = []
    try:
        hist = json.loads(STATUS.read_text(encoding="utf-8")).get("history", [])
    except (OSError, ValueError):
        pass
    hist.append(result)
    atomic_write(STATUS, json.dumps({"history": hist[-500:]}, indent=2))


# ---------------------------------------------------------------------------
# process-tree kill (PowerShell on Windows, process group on POSIX)
# ---------------------------------------------------------------------------
def kill_tree(proc: subprocess.Popen) -> None:
    if sys.platform == "win32":
        subprocess.run(
            ["taskkill", "/PID", str(proc.pid), "/T", "/F"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    else:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except OSError:
            proc.kill()


def pid_alive(pid: int) -> bool:
    """Best-effort liveness check for a dead-ticket holder process."""
    if not pid:
        return False
    try:
        if sys.platform == "win32":
            out = subprocess.run(
                ["tasklist", "/FI", f"PID eq {pid}"],
                capture_output=True, text=True, timeout=10,
            ).stdout
            return str(pid) in out
        os.kill(pid, 0)
        return True
    except Exception:
        return False


def godot_pids() -> set[int]:
    """PIDs of live Godot processes (used to reap children the shim leaves behind)."""
    if sys.platform == "win32":
        ps = ("Get-CimInstance Win32_Process -Filter \"Name like 'Godot%'\" | "
              "Select-Object -ExpandProperty ProcessId")
        try:
            out = subprocess.run(["powershell", "-NoProfile", "-Command", ps],
                                 capture_output=True, text=True, timeout=15).stdout
        except (OSError, subprocess.SubprocessError):
            return set()
        return {int(x) for x in out.split() if x.strip().isdigit()}
    try:
        out = subprocess.run(["pgrep", "-f", "godot"],
                             capture_output=True, text=True, timeout=15).stdout
    except (OSError, subprocess.SubprocessError):
        return set()
    return {int(x) for x in out.split() if x.strip().isdigit()}


def reap_spawned_godot(before: set[int]) -> None:
    """Kill Godot children left alive after a job (WinGet shim exits first)."""
    for pid in godot_pids() - before:
        try:
            if sys.platform == "win32":
                subprocess.run(["taskkill", "/PID", str(pid), "/T", "/F"],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                os.kill(pid, signal.SIGKILL)
        except (OSError, subprocess.SubprocessError):
            pass


def godot_process_count() -> int:
    if sys.platform == "win32":
        out = subprocess.run(
            ["powershell", "-NoProfile", "-Command",
             "(Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue | Measure-Object).Count"],
            capture_output=True, text=True, timeout=15,
        ).stdout.strip()
        try:
            return int(out)
        except ValueError:
            return -1
    out = subprocess.run(["pgrep", "-c", "godot"], capture_output=True,
                         text=True, timeout=15).stdout.strip()
    try:
        return int(out)
    except ValueError:
        return -1


def unwedge() -> int:
    """Advance past dead holders when no Godot process and no lock is active."""
    if GODOT_LOCK.exists():
        print("refusing to unwedge: godot.lock is held", file=sys.stderr)
        return 2
    n = godot_process_count()
    if n != 0:
        print(f"refusing to unwedge: {n} Godot process(es) alive", file=sys.stderr)
        return 2
    advanced = 0
    for _ in range(2000):
        serving = read_int(SERVING)
        holder = load_job(serving)
        if holder is not None and pid_alive(int(holder.get("pid", 0))):
            break
        atomic_write(RESULTS / f"{serving:08d}.json", json.dumps({
            "ticket": serving,
            "id": holder.get("id", "") if holder else "",
            "status": "skipped",
            "error": "unwedged: dead holder",
            "wait": 0.0, "run": 0.0,
        }, indent=2))
        if not advance_serving(serving):
            break
        job_path(serving).unlink(missing_ok=True)
        advanced += 1
    print(f"unwedged: advanced {advanced} dead ticket(s); now_serving={read_int(SERVING)}")
    return 0


def wait_for_turn(ticket: int, max_wait: float) -> None:
    """Block until it is this ticket's turn. Stale tickets are skipped."""
    t0 = time.time()
    last_pid_check = 0.0
    holder_alive = False
    while True:
        if time.time() - t0 > max_wait:
            raise TimeoutError(f"ticket {ticket} waited > {max_wait:.0f}s for its turn")
        serving = read_int(SERVING)
        if serving == ticket:
            return
        if serving > ticket:
            raise RuntimeError(f"ticket {ticket} was skipped (serving={serving})")
        # Is the current holder dead / hung? Reclaim after STALE_SEC.
        # A dead holder that never acquired the lock leaves NO lock file, so
        # godot_lock_age() is 0.0 and the old check could never reclaim it —
        # serving stayed pinned forever (the 2026-11-21 wedge on ticket 47).
        holder = load_job(serving)
        lock_free = not GODOT_LOCK.exists()
        lock_stale = godot_lock_age() > STALE_SEC
        holder_pid = int(holder.get("pid", 0)) if holder else 0
        # Reclaim ONLY when the holder is genuinely gone (or its lock is
        # demonstrably stale). Age alone is NOT proof of death: a live waiter
        # can sit in the FIFO queue longer than STALE_SEC and must not be
        # skipped (2026-11-21: agentQ's tickets 48/84 were wrongly skipped).
        # T-PERF-TOOL: pid_alive() spawns `tasklist` (~1 s on Windows); with a
        # 0.15 s poll that cost dominates a waiting job. Throttle it to ~2 s.
        now = time.time()
        if now - last_pid_check >= 2.0:
            last_pid_check = now
            holder_alive = pid_alive(holder_pid) if holder_pid else False
        dead_holder = holder is None or (holder_pid != 0 and not holder_alive)
        if dead_holder or (lock_stale and not lock_free):
            if not lock_free:
                release_godot_lock()
            if advance_serving(serving):
                job_path(serving).unlink(missing_ok=True)
            continue
        time.sleep(POLL_SEC)


# ---------------------------------------------------------------------------
# `run`: submit + wait + execute (the only legal way for an agent to start Godot)
# ---------------------------------------------------------------------------
def cmd_run(ns: argparse.Namespace) -> int:
    argv = ns.godot_args
    if not argv:
        print("ERROR: nothing to run after `--`", file=sys.stderr)
        return 2
    os.chdir(ROOT)
    ticket = take_ticket(ns.id, argv, ns.timeout)
    submitted = time.time()
    out_dir = RESULTS / f"{ticket:08d}_{ns.id}"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "stdout.txt"
    err_file = out_dir / "stderr.txt"

    result = {
        "ticket": ticket,
        "id": ns.id,
        "argv": argv,
        "created": submitted,
        "wait": 0.0,
        "run": 0.0,
        "exit": None,
        "timeout": ns.timeout,
        "status": "queued",
        "stdout": str(out_file.relative_to(ROOT)),
        "stderr": str(err_file.relative_to(ROOT)),
    }

    try:
        wait_for_turn(ticket, ns.max_wait)
    except (TimeoutError, RuntimeError) as e:
        result.update(status="skipped", error=str(e), wait=time.time() - submitted)
        record(result)
        print(f"[runner] ticket {ticket} skipped: {e}", file=sys.stderr)
        return 3

    result["wait"] = time.time() - submitted
    # second exclusivity net: only the serving ticket may hold the lock
    deadline = time.time() + ns.max_wait
    while not claim_godot_lock(ticket):
        if time.time() > deadline:
            result.update(status="lock-timeout", run=0.0)
            record(result)
            print(f"[runner] ticket {ticket} could not get godot.lock", file=sys.stderr)
            return 4
        time.sleep(POLL_SEC)

    started = time.time()
    result["status"] = "running"
    pids_before = godot_pids()  # T-PERF-TOOL: reap children left by the shim
    print(f"[runner] ticket {ticket} '{ns.id}' START (waited {result['wait']:.2f}s)", flush=True)
    try:
        with open(out_file, "wb") as fo, open(err_file, "wb") as fe:
            proc = subprocess.Popen([GODOT, *argv], stdout=fo, stderr=fe)
            try:
                code = proc.wait(timeout=ns.timeout)
                result["exit"] = code
                result["status"] = "ok" if code == 0 else "failed"
            except subprocess.TimeoutExpired:
                kill_tree(proc)
                proc.wait()
                result["exit"] = -9
                result["status"] = "timed-out"
                with open(err_file, "ab") as fe2:
                    fe2.write(f"\n[runner] KILLED after {ns.timeout}s (hard timeout)\n".encode())
    except Exception as e:  # noqa: BLE001 - report and keep the queue moving
        result.update(status="error", error=repr(e), exit=-1)
    finally:
        result["run"] = time.time() - started
        release_godot_lock()
        # CRITICAL: advance the serving ticket BEFORE any cleanup that can fail.
        # On Windows an antivirus or another reader can briefly hold the job
        # file open; if unlink() raised here, now_serving would never advance
        # and every later ticket would wait forever (real starvation).
        advance_serving(ticket)
        try:
            reap_spawned_godot(pids_before)
        except Exception:  # noqa: BLE001 - cleanup must never stall the queue
            pass
        for attempt in range(10):
            try:
                job_path(ticket).unlink(missing_ok=True)
                break
            except OSError:
                time.sleep(0.05 * (attempt + 1))
        record(result)

    print(f"[runner] ticket {ticket} '{ns.id}' END {result['status']} "
          f"(run {result['run']:.2f}s)", flush=True)
    return 0 if result["status"] == "ok" else 1


def cmd_status(ns: argparse.Namespace) -> int:
    ensure_spool()
    print(f"spool        = {SPOOL}")
    serving = read_int(SERVING)
    counter = read_int(COUNTER)
    pending = sorted(int(p.stem) for p in JOBS.glob("*.json"))
    print(f"now_serving = {serving}")
    print(f"next_ticket = {counter}")
    print(f"pending      = {len(pending)} {pending[:10]}")
    print(f"godot.lock   = {'HELD (age %.1fs)' % godot_lock_age() if GODOT_LOCK.exists() else 'free'}")
    try:
        hist = json.loads(STATUS.read_text(encoding="utf-8")).get("history", [])
    except (OSError, ValueError):
        hist = []
    if hist:
        waits = [h.get("wait", 0) for h in hist]
        runs = [h.get("run", 0) for h in hist]
        print(f"completed    = {len(hist)}")
        print(f"max wait     = {max(waits):.2f}s   mean wait = {sum(waits)/len(waits):.2f}s")
        print(f"max run      = {max(runs):.2f}s")
        print(f"statuses     = { {s: sum(1 for h in hist if h.get('status')==s) for s in sorted({h.get('status') for h in hist})} }")
    return 0


def cmd_doctor(ns: argparse.Namespace) -> int:
    """Kill orphaned Godot processes that bypassed this runner."""
    if sys.platform == "win32":
        out = subprocess.run(
            ["powershell", "-NoProfile", "-Command",
             "Get-CimInstance Win32_Process -Filter \"Name like 'Godot%'\" | "
             "Select-Object ProcessId,CommandLine | ConvertTo-Json -Compress"],
            capture_output=True, text=True,
        ).stdout.strip()
        try:
            procs = json.loads(out) if out else []
        except ValueError:
            procs = [json.loads(out)] if out else []
        if isinstance(procs, dict):
            procs = [procs]
        for p in procs:
            pid = p.get("ProcessId")
            print(f"killing orphan PID {pid}: {p.get('CommandLine','')}")
            subprocess.run(["taskkill", "/PID", str(pid), "/T", "/F"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(f"killed {len(procs)} orphan(s)")
    else:
        subprocess.run(["pkill", "-9", "-f", "godot"], stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)
        print("pkill godot sent")
    release_godot_lock()
    return 0


def cmd_reset(ns: argparse.Namespace) -> int:
    if not ns.yes:
        print("refusing without --yes", file=sys.stderr)
        return 2
    ensure_spool()
    for p in (COUNTER, SERVING, STATUS):
        p.unlink(missing_ok=True)
    release_godot_lock()
    for p in list(JOBS.glob("*.json")) + list(RESULTS.glob("*.json")):
        p.unlink(missing_ok=True)
    print("queue state cleared")
    return 0


def cmd_cancel(ns: argparse.Namespace) -> int:
    """Cancel PENDING jobs by id prefix (never the serving job)."""
    ensure_spool()
    serving = read_int(SERVING)
    cancelled = []
    for p in sorted(JOBS.glob("*.json")):
        ticket = int(p.stem)
        if ticket < serving:
            continue
        try:
            job = json.loads(p.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if ns.ticket is not None and ticket != ns.ticket:
            continue
        if ns.prefix and not str(job.get("id", "")).startswith(ns.prefix):
            continue
        if ns.ticket is None and ns.prefix is None:
            continue
        if ticket == serving and GODOT_LOCK.exists():
            continue
        atomic_write(RESULTS / f"{ticket:08d}.json", json.dumps({
            "ticket": ticket, "id": job.get("id", ""), "status": "skipped",
            "error": "cancelled by coordinator", "wait": 0.0, "run": 0.0,
        }, indent=2))
        p.unlink(missing_ok=True)
        cancelled.append(ticket)
    print(f"cancelled {len(cancelled)} pending job(s): {cancelled}")
    return 0


def cmd_ack(ns: argparse.Namespace) -> int:
    """Mark a historical failure as acknowledged/resolved so clean gates work."""
    ensure_spool()
    p = RESULTS / f"{ns.ticket:08d}.json"
    if not p.exists():
        print(f"no result for ticket {ns.ticket}", file=sys.stderr)
        return 2
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except ValueError:
        print(f"corrupt result for ticket {ns.ticket}", file=sys.stderr)
        return 2
    data["acknowledged"] = True
    data["ack_reason"] = ns.reason
    data["ack_at"] = time.time()
    atomic_write(p, json.dumps(data, indent=2))
    # keep the telemetry copy in sync
    try:
        st = json.loads(STATUS.read_text(encoding="utf-8"))
        for h in st.get("history", []):
            if h.get("ticket") == ns.ticket:
                h.update(acknowledged=True, ack_reason=ns.reason, ack_at=data["ack_at"])
        atomic_write(STATUS, json.dumps(st, indent=2))
    except (OSError, ValueError):
        pass
    print(f"ticket {ns.ticket} acknowledged: {ns.reason}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("run", help="submit a Godot job and wait for the serialized result")
    p.add_argument("--id", required=True, help="short job name")
    p.add_argument("--timeout", type=float, default=120.0, help="hard per-job timeout (s)")
    p.add_argument("--max-wait", type=float, default=3600.0, help="max time in queue (s)")
    p.add_argument("godot_args", nargs=argparse.REMAINDER)
    p.set_defaults(func=cmd_run)

    p = sub.add_parser("status", help="show queue depth, lock state and wait statistics")
    p.set_defaults(func=cmd_status)

    p = sub.add_parser("doctor", help="kill orphaned Godot processes that bypassed the runner")
    p.set_defaults(func=cmd_doctor)

    p = sub.add_parser("reset", help="clear queue state (maintenance)")
    p.add_argument("--yes", action="store_true")
    p.set_defaults(func=cmd_reset)

    p = sub.add_parser("cancel", help="cancel pending jobs by --ticket or --prefix")
    p.add_argument("--ticket", type=int)
    p.add_argument("--prefix")
    p.set_defaults(func=cmd_cancel)

    p = sub.add_parser("unwedge", help="advance past dead holders when no Godot is running")
    p.set_defaults(func=lambda ns: unwedge())

    p = sub.add_parser("ack", help="acknowledge a historical failure so clean gates can pass")
    p.add_argument("ticket", type=int)
    p.add_argument("--reason", required=True)
    p.set_defaults(func=cmd_ack)

    ns = ap.parse_args()
    if ns.cmd == "run" and ns.godot_args and ns.godot_args[0] == "--":
        ns.godot_args = ns.godot_args[1:]
    return ns.func(ns)


if __name__ == "__main__":
    raise SystemExit(main())
