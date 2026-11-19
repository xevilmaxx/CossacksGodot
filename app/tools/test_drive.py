#!/usr/bin/env python3
"""Drive the running game through its REAL GUI via --test-api.
Usage: python app/tools/test_drive.py --port 8123 --out app/shots/uidrive
Scenario: dump menu buttons -> screenshot menu -> open Skirmish ->
screenshot -> resize small -> screenshot -> start game -> screenshot HUD.
Every step prints what it did; any failure is explicit, never silent.
"""
import argparse, json, os, socket, sys, time

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
    ap.add_argument("--port", type=int, default=8123)
    ap.add_argument("--out", default="app/shots/uidrive")
    ap.add_argument("--host", default="127.0.0.1")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    s = socket.create_connection((a.host, a.port), timeout=15.0)
    rpc = make_rpc(s)

    print("ping:", rpc({"cmd": "ping"}), flush=True)
    print("state:", rpc({"cmd": "state"}), flush=True)

    def shot(name):
        p = os.path.join(a.out, name + ".png")
        r = rpc({"cmd": "shot", "path": os.path.abspath(p)})
        print("shot", name, "->", r, flush=True)
        return r

    def buttons():
        r = rpc({"cmd": "buttons"})
        bs = r.get("buttons", [])
        print("buttons: %d visible" % len(bs), flush=True)
        for b in bs:
            print("  [%s] %r at %s" % (b["class"], b["text"], [round(v) for v in b["rect"]]), flush=True)
        return bs

    def click_text(bs, needle, button="left"):
        for b in bs:
            if needle in str(b["text"]):
                x, y, w, h = b["rect"]
                r = rpc({"cmd": "click", "x": x + w / 2.0, "y": y + h / 2.0, "button": button})
                print("click %r ->" % needle, r, flush=True)
                time.sleep(1.0)
                return True
        print("MISS: no button containing %r" % needle, flush=True)
        return False

    def tree():
        r = rpc({"cmd": "tree"})
        items = r.get("tree", [])
        print("tree: %d visible controls, vp=%s" % (len(items), r.get("vp")), flush=True)
        for b in items:
            print("  [%s] %r at %s" % (b["class"], b["text"][:40], [round(v) for v in b["rect"]]), flush=True)
        return items

    buttons()
    tree()
    shot("01_menu")
    click_text(buttons(), "Skirmish - random map")
    buttons()
    tree()
    shot("02_skirmish")
    # start the match (heavy mapgen happens now)
    if not click_text(buttons(), "Start skirmish"):
        print("ABORT: could not start game", flush=True)
        return 1
    print("waiting for game...", flush=True)
    t0 = time.time()
    while time.time() - t0 < 120.0:
        st = rpc({"cmd": "state"})
        print("state:", st.get("has_game"), st.get("game"), flush=True)
        if st.get("has_game"):
            break
        time.sleep(2.0)
    time.sleep(3.0)
    buttons()
    tree()
    shot("04_game_hud")
    print("select-all:", rpc({"cmd": "key", "key": "A", "ctrl": True}), flush=True)
    time.sleep(2.0)
    buttons()
    shot("05_game_units")
    print("quit:", rpc({"cmd": "quit"}), flush=True)
    s.close()
    print("DONE", flush=True)
    return 0

sys.exit(main())
