#!/usr/bin/env python3
"""Build-placement video test with a REAL OS cursor (interactive-GUI fidelity).

The bridge injects synthetic events, but the placement ghost follows the real
OS cursor and a real player clicks with it — so this driver moves the actual
cursor (ctypes, Windows): menu buttons, build-menu house icon, map placement
point. Every step is visible in the video, then it exits right after the
house is finished.

Usage:
  Terminal 1: godot --path app -- --test-api 8141 --timeout 400
  Terminal 2: python app/tools/video_build.py --port 8141 --out app/shots/build_house
"""
import argparse, ctypes, json, os, socket, subprocess, sys, time

user32 = ctypes.windll.user32

hwnd = None

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

# --- real-cursor helpers (Windows) ---
def find_game_window():
    found = []
    @ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)
    def cb(hwnd, _):
        if user32.IsWindowVisible(hwnd):
            n = ctypes.create_unicode_buffer(512)
            user32.GetWindowTextW(hwnd, n, 512)
            if "CossacksGodot" in n.value:
                found.append(hwnd)
        return True
    user32.EnumWindows(cb, 0)
    return found[0] if found else None

class RECT(ctypes.Structure):
    _fields_ = [("l", ctypes.c_long), ("t", ctypes.c_long),
                ("r", ctypes.c_long), ("b", ctypes.c_long)]

class POINT(ctypes.Structure):
    _fields_ = [("x", ctypes.c_long), ("y", ctypes.c_long)]

def client_origin(hwnd):
    pt = POINT(0, 0)
    user32.ClientToScreen(hwnd, ctypes.byref(pt))
    return (pt.x, pt.y)

def move_cursor_smooth(tx, ty, steps=25, delay=0.02):
    pt = POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    for i in range(1, steps + 1):
        x = int(pt.x + (tx - pt.x) * i / steps)
        y = int(pt.y + (ty - pt.y) * i / steps)
        user32.SetCursorPos(x, y)
        time.sleep(delay)

def real_click(tag="click"):
    global hwnd
    ensure_focus()
    fg = user32.GetForegroundWindow()
    print("focus: game=%s fg=%s match=%s" % (hwnd, fg, fg == hwnd), flush=True)
    pt = POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    print("%s at screen %d,%d" % (tag, pt.x, pt.y), flush=True)
    user32.mouse_event(0x0002, 0, 0, 0, 0)  # LEFTDOWN
    time.sleep(0.08)
    user32.mouse_event(0x0004, 0, 0, 0, 0)  # LEFTUP

def ensure_focus():
    global hwnd
    if user32.GetForegroundWindow() != hwnd:
        print("refocusing game window", flush=True)
        user32.SetForegroundWindow(hwnd)
        time.sleep(0.8)
    if user32.GetForegroundWindow() != hwnd:
        raise RuntimeError("cannot bring game window to front - "
                           "do not touch mouse/keyboard during the run")

def main():
    global hwnd
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8141)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--out", default="app/shots/build_house")
    ap.add_argument("--place", default="350,350")
    a = ap.parse_args()
    # fresh frame dir (old build_house frames would corrupt the mp4)
    import shutil
    shutil.rmtree(a.out, ignore_errors=True)
    os.makedirs(a.out, exist_ok=True)
    px, py = (float(v) for v in a.place.split(","))

    hwnd = find_game_window()
    assert hwnd, "game window not found (title must contain CossacksGodot)"
    user32.SetForegroundWindow(hwnd)
    time.sleep(0.5)
    ox, oy = client_origin(hwnd)
    print("window client origin: %d,%d" % (ox, oy), flush=True)
    # canvas 1280x720 -> screen (window is 1280x720 client at default size)
    def to_screen(cx, cy):
        return (ox + int(round(cx)), oy + int(round(cy)))

    s = socket.create_connection((a.host, a.port), timeout=15.0)
    rpc = make_rpc(s)
    print("ping:", rpc({"cmd": "ping"}), flush=True)

    frames = []
    def shot(tag):
        p = os.path.join(a.out, "frame_%04d.png" % len(frames))
        r = rpc({"cmd": "shot", "path": os.path.abspath(p)})
        frames.append(p)
        print("shot %s -> %s" % (tag, r.get("ok")), flush=True)

    def center(bs, needle):
        for b in bs:
            if needle in str(b["text"]):
                x, y, w, h = b["rect"]
                return (x + w / 2, y + h / 2)
        return None

    def ghost_active():
        d = rpc({"cmd": "tree"})
        return any("Placing hou" in str(b["text"]) for b in d.get("tree", []))

    def menu_click(needle, timeout=40.0):
        t0 = time.time()
        c = None
        while time.time() - t0 < timeout:
            bs = rpc({"cmd": "buttons"})["buttons"]
            c = center(bs, needle)
            if c:
                break
            time.sleep(1.0)
        assert c, "no button: " + needle
        sx, sy = to_screen(*c)
        move_cursor_smooth(sx, sy)
        time.sleep(0.3)
        real_click()
        time.sleep(1.0)

    # --- menu -> skirmish -> game ---
    shot("menu")
    menu_click("Skirmish - random map")
    shot("skirmish")
    menu_click("Start skirmish")
    t0 = time.time()
    while time.time() - t0 < 150.0:
        if rpc({"cmd": "state"}).get("has_game"):
            break
        time.sleep(2.0)
    else:
        print("ABORT: game never started", flush=True)
        return 1
    time.sleep(4.0)
    shot("game_start")

    # --- select all peasants (build menu auto-opens) ---
    print("select-all:", rpc({"cmd": "key", "key": "A", "ctrl": True}), flush=True)
    time.sleep(2.0)
    st = rpc({"cmd": "state"})
    print("selected:", st["game"].get("selected"),
          "blds0:", st["game"].get("blds0"), flush=True)
    shot("peasants_selected")

    # --- real cursor onto the 2nd build-menu icon (order: cen, hou, ...) ---
    bs = rpc({"cmd": "buttons"})["buttons"]
    st = rpc({"cmd": "state"})
    lay = st.get("layout", {})
    sel_l = lay.get("sel_l", 242)
    icons = [b for b in bs
             if b["class"] == "Button" and str(b["text"]) == ""
             and b["rect"][0] > sel_l and 570 < b["rect"][1] < 720]
    icons.sort(key=lambda b: (round(b["rect"][1]), round(b["rect"][0])))
    print("build icons found:", len(icons), flush=True)
    if len(icons) >= 2:
        x, y, w, h = icons[1]["rect"]
        sx, sy = to_screen(x + w / 2, y + h / 2)
        move_cursor_smooth(sx, sy)
        time.sleep(0.4)
        shot("ghost_hover_house")
        real_click()
        time.sleep(1.0)
    if not ghost_active():
        print("icon click missed ghost; hotkey H fallback",
              rpc({"cmd": "key", "key": "H"}), flush=True)
        time.sleep(1.0)
    assert ghost_active(), "ghost mode never engaged"
    shot("ghost_ready")

    # --- real cursor to the placement point, real click ---
    sx, sy = to_screen(px, py)
    move_cursor_smooth(sx, sy)
    time.sleep(0.5)
    shot("ghost_at_site")
    real_click()
    time.sleep(1.5)
    st = rpc({"cmd": "state"})
    print("after place: blds0:", st["game"].get("blds0"),
          "unfin0:", st["game"].get("unfin0"),
          "ghost:", ghost_active(), flush=True)
    if st["game"].get("blds0", 1) < 2:  # one retry, nudged point
        print("RETRY at nudged point", flush=True)
        move_cursor_smooth(sx + 60, sy + 40)
        time.sleep(0.5)
        real_click()
        time.sleep(1.5)
        st = rpc({"cmd": "state"})
        print("after retry: blds0:", st["game"].get("blds0"), flush=True)
    assert st["game"].get("blds0", 1) >= 2, "placement failed twice"
    shot("placed")

    # --- capture until the house is finished, then exit ---
    t0 = time.time()
    i = 0
    while time.time() - t0 < 150.0:
        time.sleep(1.0)
        shot("build_%03d" % i)
        i += 1
        st = rpc({"cmd": "state"})
        if i % 10 == 0:
            print("t+%ds unfin0=%s" % (int(time.time() - t0),
                  st["game"].get("unfin0")), flush=True)
        if st["game"].get("blds0", 0) >= 2 and \
                st["game"].get("unfin0", 1) == 0:
            print("HOUSE FINISHED at t+%ds" % int(time.time() - t0), flush=True)
            break
    # select the finished house for the closing shots
    move_cursor_smooth(sx, sy)
    time.sleep(0.3)
    real_click()
    time.sleep(1.0)
    for i in range(6):
        time.sleep(0.75)
        shot("selected_%d" % i)
    print("quit:", rpc({"cmd": "quit"}), flush=True)
    s.close()

    mp4 = os.path.join(os.path.abspath(a.out), "build_house.mp4")
    cmd = [sys.executable,
           os.path.abspath("app/tools/seq_to_mp4.py"),
           "--dir", os.path.abspath(a.out), "--fps", "8", "--out", mp4]
    print("+", " ".join(cmd), flush=True)
    r = subprocess.run(cmd, capture_output=True, text=True)
    print(r.stdout[-1500:])
    if r.returncode != 0:
        print(r.stderr[-2000:])
        return 1
    print("video:", mp4, os.path.getsize(mp4), "bytes,", len(frames), "frames")
    return 0

sys.exit(main())
