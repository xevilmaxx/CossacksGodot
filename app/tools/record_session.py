#!/usr/bin/env python3
"""Hands-off session recorder: captures frames while a HUMAN plays.

The driver never touches mouse/keyboard — it only polls `shot` + `state`
(read-only). When the player closes the game window, the connection drops
and the recorder assembles the MP4 + contact sheet by itself.

Usage:
  Terminal 1: launch Godot through the serialized runner (NEVER call `godot`
              directly) -- see app/tools/godot_runner.py, e.g.
              python app\\tools\\godot_runner.py run --id agentS-record --timeout 900 -- --path app -- --test-api 8142 --timeout 900
  Terminal 2: python app/tools/record_session.py --port 8142 --out app/shots/session1
"""
import argparse, json, os, shutil, socket, subprocess, sys, time
from pathlib import Path

def make_rpc(sock, timeout=60.0):
    buf = bytearray()
    def recv_line():
        while True:
            i = buf.find(b"\n")
            if i >= 0:
                line = bytes(buf[:i])
                del buf[:i + 1]
                return line
            sock.settimeout(timeout)
            chunk = sock.recv(65536)
            if not chunk:
                raise RuntimeError("connection closed")
            buf.extend(chunk)
    def rpc(obj):
        sock.sendall((json.dumps(obj) + "\n").encode("utf-8"))
        return json.loads(recv_line().decode("utf-8"))
    return rpc

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8142)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--out", default="app/shots/session1")
    ap.add_argument("--interval", type=float, default=0.7)
    ap.add_argument("--max-frames", type=int, default=1200)
    a = ap.parse_args()
    shutil.rmtree(a.out, ignore_errors=True)
    os.makedirs(a.out, exist_ok=True)

    # wait for the game to come up (player may still see the menu)
    rpc = None
    t0 = time.time()
    while time.time() - t0 < 120.0:
        try:
            s = socket.create_connection((a.host, a.port), timeout=5.0)
            rpc = make_rpc(s)
            print("connected:", rpc({"cmd": "ping"}), flush=True)
            break
        except OSError:
            time.sleep(2.0)
    if rpc is None:
        print("ABORT: game never came up", flush=True)
        return 1

    n = 0
    try:
        while n < a.max_frames:
            try:
                p = os.path.join(a.out, "frame_%04d.png" % n)
                r = rpc({"cmd": "shot", "path": os.path.abspath(p)})
                if not r.get("ok"):
                    print("shot failed:", r, flush=True)
                    break
                n += 1
                if n % 10 == 0:
                    try:
                        st = rpc({"cmd": "state"})
                        print("frame %d has_game=%s blds0=%s unfin0=%s sel=%s" % (
                            n, st.get("has_game"), st["game"].get("blds0"),
                            st["game"].get("unfin0"),
                            st["game"].get("selected")), flush=True)
                    except (OSError, RuntimeError):
                        break
                time.sleep(a.interval)
            except (OSError, RuntimeError) as e:
                print("game closed by player after %d frames (%s)" % (n, e),
                      flush=True)
                break
    finally:
        try:
            s.close()
        except Exception:
            pass
    if n == 0:
        print("no frames captured", flush=True)
        return 1
    mp4 = os.path.join(os.path.abspath(a.out), "session.mp4")
    # Resolve the helper relative to THIS script, not the current working dir.
    seq_tool = str(Path(__file__).resolve().parent / "seq_to_mp4.py")
    cmd = [sys.executable, seq_tool,
           "--dir", os.path.abspath(a.out), "--fps", "8", "--out", mp4]
    print("+", " ".join(cmd), flush=True)
    r = subprocess.run(cmd, capture_output=True, text=True, shell=False)
    print(r.stdout[-1500:])
    if r.returncode != 0:
        print(r.stderr[-2000:])
        return 1
    if not os.path.isfile(mp4):
        print("no MP4 produced (ffmpeg missing?) - contact sheet kept;",
              "install ffmpeg and re-run seq_to_mp4.py", flush=True)
        return 1
    print("video:", mp4, os.path.getsize(mp4), "bytes,", n, "frames")
    return 0

sys.exit(main())
