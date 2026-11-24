---
owner: W2-8
wave: 2
date: 2026-11-24
title: "G-P12 — scan_map.py tooling perf (duplicate parse + hot ring/BFS loops)"
scope: "one owned file app/tools/scan_map.py + this report; pure-Python A/B only, no Godot run"
status: FIXED-MEASURED
---

# W2-8 — `app/tools/scan_map.py` perf gap G-P12

Evidence labels: **observed** = read from current source or measured here today;
**derived** = computed from those measurements; **inferred** = not measured.

## 0. Verified current source (no prior claim trusted)

- **observed** `docs/coord_swarm_2026-11-24/reports/P04_tooling_perf.md:19-20,39-50`
  tickets C2/C3: tuple-set BFS, per-water-tile neighbour list, flat `cliff_ring`
  loop, and a duplicate `json.load` per dump.
- **observed** `app/tools/scan_map.py:58-60` (before edit) re-opened and re-parsed
  every dump that `main()` had already parsed at `:253-255`; `:71-89` used
  `(x,y)` tuple sets; `:114-128` built an 8-tuple list per water tile;
  `:131-153` scanned all `w*h` cells; `:174-215` used tuple sets in reach BFS.
- **observed** the scan gate is a QA red gate (same tool prints forest %, rock
  %, patches, mean, coast, cliff, tileflow, reach and the ALL GREEN/FAIL verdict);
  byte-identical stdout is therefore the acceptance criterion, not just equal floats.
- **observed** `scans/` contains **42** `.json` map dumps today, not the 39
  quoted by P04. All 42 are real map dumps (checked: every file has `map_w` +
  `terrain`). P04's 28,549 ms was measured on a different input set/machine load.
- **observed** `python -c "import numpy"` → **2.4.3** available in the tool
  interpreter (answers P04 Q3). The tool does not *require* it: an import guard
  plus stdlib-only fallbacks are kept.

## 1. VERIFIED-ALREADY

Nothing in this file was already fixed. **observed** git status before edit:
only the owned file existed at its original blob; backup path absent. No
prior W2-8 fix was found, so all four sub-gaps below were implemented here.

## 2. FIXED (measured)

| Sub-gap | Change | Per-file cost before → after (42-dump aggregate, **measured** in scratch A/B) |
|---|---|---|
| Duplicate parse | `load_scan(path, d=None)` / `scan_one(path, d=None)`; discovery keeps the parsed dict and passes it through (`files` is now `(path, d)`). One `json.load` per dump. | ~0.8 s/run saved (P04's estimate); not isolated here, included in wall time |
| `count_patches` | `(x,y)` tuple set → flat `bytearray(w*h)` visited map, int queue, same row-major seeds and same right/left/down/up BFS order → same patch-size list, same order. | 2738.8 ms → 1790.5 ms over 42 files (x1.53, pure-Python) |
| `sand_ring` | numpy: 8 direction slice-OR masks over `uint8` terrain; stdlib fallback: inline flat-index neighbour checks with early-out. Both compute the same two counts. | 4343.6 ms → 73.0 ms over 42 files (x59.5, numpy path) |
| `cliff_ring` | numpy: OR of four `float64` neighbour differences (OR, **not** AND — an early wrong candidate was caught by A/B on 3 dumps), then terrain skip and blocked count. stdlib fallback: interior loop + guarded border ring. | 11228.4 ms → 840.2 ms over 42 files (x13.4, numpy path) |
| `tileflow` + 4 terrain % counters | `numpy` masks / `bytes.count()` instead of Python generator scans; identical integer numerators and denominators. | tileflow 1207.5 ms → 37.3 ms over 42 files (x32.4) |
| `reachability` | Tuple `seen` set → flat `bytearray`; BFS neighbour order and the 5x5 `reach` set kept unchanged. | 3311.5 ms → 1789.0 ms over 42 files (x1.85) |

All scratch A/B functions were compared on **all 42 dumps** before landing:
`mismatches: 0` for count_patches, sand_ring, cliff_ring, tileflow and
reachability. The numpy `cliff_ring` candidate initially used `&=` across
neighbour directions and produced 3 mismatches; corrected to `|=` and
re-verified at 0 mismatches.

### Before/after wall time (same inputs, same machine, `measure-` harness)

Harness: `python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\scan_bench.py <out> <label>`
= `time.perf_counter()` around `subprocess.run([python, app/tools/scan_map.py, --dir scans])`,
stdout captured to a temp file. Command: `python app\tools\scan_map.py --dir scans`.

| Run | Script | Wall (s) | rc | stdout bytes | sha256 |
|---|---|---:|---:|---:|---|
| BEFORE-1 | original `app/tools/scan_map.py` | **38.857** | 1 | 8878 | `b5763255aa022d53ea91eb63d10a1a08a15fe03a9f401fcf7ff3d787601b3863` |
| BEFORE-2 | original (repeat) | **43.402** | 1 | 8878 | same |
| BEFORE-3 | `inbox/backup/scan_map.py.bak-W28` run *after* the edit (contemporaneous baseline) | **41.638** | 1 | 8878 | same |
| AFTER-1 | edited `app/tools/scan_map.py` | **8.077** | 1 | 8878 | same |
| AFTER-2 | edited (repeat) | **8.015** | 1 | 8878 | same |
| AFTER-3 | edited (final re-run, heavier concurrent swarm load) | **13.713** | 1 | 8878 | same |
| AFTER, numpy disabled (`_np = None` in-process) | edited file, stdlib fallbacks | **32.686** | 1 | 8878 | same |

- **derived** speedup with numpy: 38.857/8.077 = **4.81x** (best-case baseline),
  41.638/8.077 = **5.16x** (contemporaneous baseline), 43.402/8.015 = **5.41x**
  (worst-case baseline); AFTER-3 under heavy load gives 38.857/13.713 = 2.83x.
  Report the low-contention A/B as **~4.8–5.4x** (2.8x worst observed), not as a single exact number:
  other swarm jobs were active: the baseline varied 4.5 s between repeats and
  a final AFTER run landed at 13.713 s under heavier contention (still 2.8x
  faster than the best baseline; hash unchanged in every run).
- **derived** stdlib-only fallback is ~1.2–1.3x faster than the original (no
  duplicate parse, flat BFS/loops) and remains byte-identical.
- P04's 28,549 ms number is **not** used as a baseline: different file count
  and load. All numbers above are measured on the same 42-dump `scans/` dir.

### Byte-identical proof (QA red gate)

```
fc.exe /b <temp>\scan_before.json <temp>\scan_after.json
Comparing files ...scan_before.json and ...SCAN_AFTER.JSON
FC: no differences encountered
```
- Both stdout files: 8878 bytes, 97 lines, same sha256 above. Exit code 1 in
  both cases (the existing 3 FAIL rows are unchanged: 2 patch/mean rows and
  `scan_9.json ... cliff=0`); the gate verdict and failure list are identical.
- The in-process stdlib-fallback run was first compared with Windows newline
  translation added (StringIO does not translate `\n` → `\r\n`); after that it
  matched BEFORE byte-for-byte and produced the same sha256.

### Determinism note

No RNG, clock, thread or subprocess is used in the scan functions. Discovery
uses `sorted(os.listdir(...))`, so row order is fixed. BFS seed order and
neighbour order are unchanged; connected-component sizes are independent of
queue order anyway. numpy reductions are integer `sum()` over bool masks —
exact, order-independent. `cliff_ring` converts the unpacked float32 tuple to
`float64` (exact binary64 values of the same Python floats) before subtraction,
so the `> 0.5` decision matches the original Python arithmetic on all dumps.
Two consecutive AFTER runs and the no-numpy fallback all produced the same
hash; no visual/Godot path is touched.

## 3. NOT-DONE

- **count_patches** still uses a Python BFS (now flat-array, x1.53). A
  row-run/union-find rewrite could remove most of the remaining ~43 ms/file,
  but it changes traversal structure and is not needed for the measured win;
  not attempted (safe part landed).
- **numpy is optional, not mandated.** If the QA machine has no numpy, the
  stdlib fallback path runs at ~32.7 s (still a measured win over 38.9–43.4 s).
- `app/tools/terrain_geometry_verify.py` still has its own duplicate parse
  (`P04` C3 second half). Out of my exclusive ownership — not touched.
- No Godot run, no game-code or scan-dump edits, no gate-rule changes.

## 4. Backup and exact diff

Backup taken **before** any edit (`Copy-Item`, verified present, 13442 bytes):
`inbox/backup/scan_map.py.bak-W28`.
Restore: `Copy-Item inbox\backup\scan_map.py.bak-W28 app\tools\scan_map.py -Force`.

Exact working diff (`git diff -- app/tools/scan_map.py`, 249 insertions / 47 deletions):

```diff
diff --git a/app/tools/scan_map.py b/app/tools/scan_map.py
index 3d6e1944..951945bd 100644
--- a/app/tools/scan_map.py
+++ b/app/tools/scan_map.py
@@ -24,8 +24,36 @@ Exit 1 if any target red, else 0.
 import argparse, base64, json, os, sys
 from collections import deque
 
+# Optional fast path for the per-tile ring checks. The pure-Python fallbacks
+# below are kept (and are themselves faster than the old tuple-set loops), so
+# this QA tool still runs on a bare Python without numpy.
+try:
+    import numpy as _np
+except ImportError:
+    _np = None
+
 NB = ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1))
 
+
+def _neighbor_mask(mask, h, w):
+    """OR of the eight in-bounds neighbours of a bool (h,w) array."""
+    out = _np.zeros((h, w), dtype=bool)
+    for ox, oy in NB:
+        if oy < 0:
+            ys, yd = slice(0, h + oy), slice(-oy, h)
+        elif oy > 0:
+            ys, yd = slice(oy, h), slice(0, h - oy)
+        else:
+            ys, yd = slice(0, h), slice(0, h)
+        if ox < 0:
+            xs, xd = slice(0, w + ox), slice(-ox, w)
+        elif ox > 0:
+            xs, xd = slice(ox, w), slice(0, w - ox)
+        else:
+            xs, xd = slice(0, w), slice(0, w)
+        out[yd, xd] |= mask[ys, xs]
+    return out
+
 # Donor evidence, all at the 320x320 reference map (docs/audit/PIECES/map_density.md):
 #   forest-family stamps: 115 (prob=1) .. 236 (mod*2)   [┬º3.2 table]
 #   donor-equivalent at 160: 29 .. 59 (one quarter, since needed=floor(W*H*freq))
@@ -55,9 +83,10 @@ def patch_gates(w, h):
     return p_lo, p_hi, m_lo, m_hi
 
 
-def load_scan(path):
-    with open(path, encoding="utf-8") as f:
-        d = json.load(f)
+def load_scan(path, d=None):
+    if d is None:
+        with open(path, encoding="utf-8") as f:
+            d = json.load(f)
     w, h = int(d["map_w"]), int(d["map_h"])
     terrain = base64.b64decode(d["terrain"])
     blocked = base64.b64decode(d["blocked"])
@@ -69,22 +98,47 @@ def load_scan(path):
 
 
 def count_patches(w, h, terrain):
-    seen = set()
+    # Flat bytearray visited map: same row-major seeds, same 4-neighbour BFS
+    # order (right, left, down, up) and therefore the same patch sizes in the
+    # same order as the old (x,y) tuple-set version.
+    seen = bytearray(w * h)
     patches = []
     for y in range(h):
+        row = y * w
         for x in range(w):
-            if (x, y) in seen or terrain[y * w + x] != 2:
+            i = row + x
+            if seen[i] or terrain[i] != 2:
                 continue
-            q = deque([(x, y)])
-            seen.add((x, y))
+            seen[i] = 1
+            q = deque([i])
+            pop = q.popleft
+            add = q.append
             size = 0
             while q:
-                cx, cy = q.popleft()
+                j = pop()
                 size += 1
-                for nx, ny in ((cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)):
-                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and terrain[ny*w+nx] == 2:
-                        seen.add((nx, ny))
-                        q.append((nx, ny))
+                cx = j % w
+                cy = j // w
+                if cx + 1 < w:
+                    k = j + 1
+                    if not seen[k] and terrain[k] == 2:
+                        seen[k] = 1
+                        add(k)
+                if cx:
+                    k = j - 1
+                    if not seen[k] and terrain[k] == 2:
+                        seen[k] = 1
+                        add(k)
+                if cy + 1 < h:
+                    k = j + w
+                    if not seen[k] and terrain[k] == 2:
+                        seen[k] = 1
+                        add(k)
+                if cy:
+                    k = j - w
+                    if not seen[k] and terrain[k] == 2:
+                        seen[k] = 1
+                        add(k)
             patches.append(size)
     return patches
 
@@ -113,17 +167,78 @@ def mine_clearance(res):
 
 def sand_ring(w, h, terrain):
     """Fraction of the coastline (water tiles touching land) that has sand."""
+    if _np is not None:
+        t = _np.frombuffer(terrain, dtype=_np.uint8).reshape(h, w)
+        water = t == 3
+        coast = water & _neighbor_mask(~water, h, w)
+        covered = coast & _neighbor_mask(t == 4, h, w)
+        n = int(coast.sum())
+        return int(covered.sum()) / n if n else 1.0
     coast = covered = 0
+    t = terrain
     for y in range(h):
+        row = y * w
+        up = y > 0
+        down = y + 1 < h
         for x in range(w):
-            if terrain[y*w+x] != 3:
+            i = row + x
+            if t[i] != 3:
                 continue
-            nbrs = [(nx, ny) for nx, ny in
-                    ((x+ox, y+oy) for ox, oy in NB) if 0 <= nx < w and 0 <= ny < h]
-            if not any(terrain[ny*w+nx] != 3 for nx, ny in nbrs):
+            left = x > 0
+            right = x + 1 < w
+            wet = sand = False
+            if left:
+                v = t[i-1]
+                wet = v != 3
+                sand = v == 4
+            if right and not (wet and sand):
+                v = t[i+1]
+                if v != 3:
+                    wet = True
+                if v == 4:
+                    sand = True
+            if up and not (wet and sand):
+                j = i - w
+                v = t[j]
+                if v != 3:
+                    wet = True
+                if v == 4:
+                    sand = True
+                if left and not (wet and sand):
+                    v = t[j-1]
+                    if v != 3:
+                        wet = True
+                    if v == 4:
+                        sand = True
+                if right and not (wet and sand):
+                    v = t[j+1]
+                    if v != 3:
+                        wet = True
+                    if v == 4:
+                        sand = True
+            if down and not (wet and sand):
+                j = i + w
+                v = t[j]
+                if v != 3:
+                    wet = True
+                if v == 4:
+                    sand = True
+                if left and not (wet and sand):
+                    v = t[j-1]
+                    if v != 3:
+                        wet = True
+                    if v == 4:
+                        sand = True
+                if right and not (wet and sand):
+                    v = t[j+1]
+                    if v != 3:
+                        wet = True
+                    if v == 4:
+                        sand = True
+            if not wet:
                 continue
             coast += 1
-            if any(terrain[ny*w+nx] == 4 for nx, ny in nbrs):
+            if sand:
                 covered += 1
     return covered / coast if coast else 1.0
 
@@ -132,24 +247,87 @@ def cliff_ring(w, h, terrain, blocked, height):
     """Donor collision rule: a steep tile (|dh| > 0.5/0.55) must be blocked.
     Rock PAINT is not collision (donor paints rock1 on walkable hills too), so
     measuring 'blocked / rock' gives a false failure on every gentle hill."""
+    if not height:
+        return 1.0
+    if _np is not None:
+        # float64 keeps the exact binary64 subtraction of the unpacked float32
+        # heights; OR (not AND) across the four neighbour directions matches
+        # the old max(|dh|) > 0.5 rule.
+        a = _np.asarray(height, dtype=_np.float64).reshape(h, w)
+        steep = _np.zeros((h, w), dtype=bool)
+        steep[:, 1:] |= _np.abs(a[:, 1:] - a[:, :-1]) > 0.5
+        steep[:, :-1] |= _np.abs(a[:, :-1] - a[:, 1:]) > 0.5
+        steep[1:, :] |= _np.abs(a[1:, :] - a[:-1, :]) > 0.5
+        steep[:-1, :] |= _np.abs(a[:-1, :] - a[1:, :]) > 0.5
+        t = _np.frombuffer(terrain, dtype=_np.uint8).reshape(h, w)
+        steep &= (t != 3) & (t != 4)
+        n = int(steep.sum())
+        if not n:
+            return 1.0
+        b = _np.frombuffer(blocked, dtype=_np.uint8).reshape(h, w)
+        return int((steep & (b != 0)).sum()) / n
     steep = []
-    for y in range(h):
-        for x in range(w):
-            i = y*w+x
-            if terrain[i] in (3, 4) or not height:  # water + wet sand are passable shore
+    add = steep.append
+    habs = abs
+    t, hh = terrain, height
+    if w > 2 and h > 2:
+        for y in range(1, h - 1):
+            row = y * w
+            for x in range(1, w - 1):
+                i = row + x
+                ti = t[i]
+                if ti == 3 or ti == 4:
+                    continue
+                h0 = hh[i]
+                s = habs(hh[i-1] - h0)
+                v = habs(hh[i+1] - h0)
+                if v > s:
+                    s = v
+                v = habs(hh[i-w] - h0)
+                if v > s:
+                    s = v
+                v = habs(hh[i+w] - h0)
+                if v > s:
+                    s = v
+                if s > 0.5:
+                    add(i)
+    # Border tiles keep the original guarded neighbour checks.
+    for x in range(w):
+        for y in (0, h - 1):
+            i = y * w + x
+            ti = t[i]
+            if ti == 3 or ti == 4:
+                continue
+            h0 = hh[i]
+            s = 0.0
+            if x > 0:
+                s = max(s, habs(hh[i-1] - h0))
+            if x + 1 < w:
+                s = max(s, habs(hh[i+1] - h0))
+            if y > 0:
+                s = max(s, habs(hh[i-w] - h0))
+            if y + 1 < h:
+                s = max(s, habs(hh[i+w] - h0))
+            if s > 0.5:
+                add(i)
+    for y in range(1, h - 1):
+        for x in (0, w - 1):
+            i = y * w + x
+            ti = t[i]
+            if ti == 3 or ti == 4:
                 continue
-            h0 = height[i]
+            h0 = hh[i]
             s = 0.0
             if x > 0:
-                s = max(s, abs(height[i-1]-h0))
-            if x+1 < w:
-                s = max(s, abs(height[i+1]-h0))
+                s = max(s, habs(hh[i-1] - h0))
+            if x + 1 < w:
+                s = max(s, habs(hh[i+1] - h0))
             if y > 0:
-                s = max(s, abs(height[i-w]-h0))
-            if y+1 < h:
-                s = max(s, abs(height[i+w]-h0))
+                s = max(s, habs(hh[i-w] - h0))
+            if y + 1 < h:
+                s = max(s, habs(hh[i+w] - h0))
             if s > 0.5:
-                steep.append(i)
+                add(i)
     return sum(1 for i in steep if blocked[i]) / len(steep) if steep else 1.0
 
 
@@ -157,11 +335,15 @@ def tileflow(w, h, terrain, tb):
     """BLK_WATER must line up with terrain water; no sandsea on dry land."""
     if not tb:
         return 1.0
-    bad = 0
-    for i in range(w*h):
-        if terrain[i] == 3 and tb[i] != 255:
-            bad += 1
-    return 1.0 - bad / max(1, sum(1 for t in terrain if t == 3))
+    if _np is not None:
+        t = _np.frombuffer(terrain, dtype=_np.uint8)
+        b = _np.frombuffer(tb, dtype=_np.uint8)
+        water = int((t == 3).sum())
+        bad = int(((t == 3) & (b != 255)).sum())
+    else:
+        water = terrain.count(3)
+        bad = sum(1 for t, b in zip(terrain, tb) if t == 3 and b != 255)
+    return 1.0 - bad / max(1, water)
 
 
 def reach_radius(map_w):
@@ -194,7 +376,10 @@ def reachability(w, h, blocked, res, starts, radius=25):
             if not found:
                 return False
             stx, sty = found
-        seen = {(stx, sty)}
+        # Flat visited map, same row-major start, same BFS neighbour order and
+        # the same reach set for the final 5x5 proximity test.
+        seen = bytearray(w*h)
+        seen[sty*w+stx] = 1
         q = deque([(stx, sty, 0)])
         reach = set()
         while q:
@@ -202,10 +387,27 @@ def reachability(w, h, blocked, res, starts, radius=25):
             reach.add((x, y))
             if d >= radius:
                 continue
-            for nx, ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
-                if 0 <= nx < w and 0 <= ny < h and (nx,ny) not in seen and blocked[ny*w+nx] == 0:
-                    seen.add((nx, ny))
-                    q.append((nx, ny, d+1))
+            i = y*w + x
+            if x + 1 < w:
+                k = i + 1
+                if not seen[k] and blocked[k] == 0:
+                    seen[k] = 1
+                    q.append((x+1, y, d+1))
+            if x:
+                k = i - 1
+                if not seen[k] and blocked[k] == 0:
+                    seen[k] = 1
+                    q.append((x-1, y, d+1))
+            if y + 1 < h:
+                k = i + w
+                if not seen[k] and blocked[k] == 0:
+                    seen[k] = 1
+                    q.append((x, y+1, d+1))
+            if y:
+                k = i - w
+                if not seen[k] and blocked[k] == 0:
+                    seen[k] = 1
+                    q.append((x, y-1, d+1))
         def near_reach(px, py):
             tx, ty = int(px // 2.0), int(py // 2.0)
             return any((tx+dx, ty+dy) in reach for dy in range(-2, 3) for dx in range(-2, 3))
@@ -215,13 +417,13 @@ def reachability(w, h, blocked, res, starts, radius=25):
     return True
 
 
-def scan_one(path):
-    w, h, terrain, blocked, tb, height, d = load_scan(path)
+def scan_one(path, d=None):
+    w, h, terrain, blocked, tb, height, d = load_scan(path, d)
     total = w * h
-    water = sum(1 for t in terrain if t == 3) / total * 100
-    sand = sum(1 for t in terrain if t == 4) / total * 100
-    dark = sum(1 for t in terrain if t == 2) / total * 100
-    rock = sum(1 for t in terrain if t == 5) / total * 100
+    water = terrain.count(3) / total * 100
+    sand = terrain.count(4) / total * 100
+    dark = terrain.count(2) / total * 100
+    rock = terrain.count(5) / total * 100
     patches = count_patches(w, h, terrain)
     meta = d.get("meta", {})
     return {
@@ -256,13 +458,13 @@ def main():
             # Parse first: a substring check on the raw text also matches
             # "map_width_tiles" in config files, then load_scan() KeyErrors.
             if isinstance(d, dict) and "map_w" in d and "terrain" in d:
-                files.append(p)
+                files.append((p, d))  # keep the parsed dump: scan_one used to reload it
         except (OSError, ValueError):
             pass
     if not files:
         print("no map dumps in", a.dir)
         return 2
-    rows = [scan_one(p) for p in files]
+    rows = [scan_one(p, d) for p, d in files]
     p_lo, p_hi, m_lo, m_hi = patch_gates(rows[0]["map_w"], rows[0]["map_h"])
     area = rows[0]["map_w"] * rows[0]["map_h"]
     print("gates @%dx%d (s=%.2f, area x%.2f): donor stamps %.0f..%.0f, "
```

## 5. Open questions

1. **Q-W28-1** Should the final QA box require numpy? If not, the ~32.7 s
   fallback is the guaranteed bound; if yes, ~8 s. Coordinator call.
2. **Q-W28-2** `count_patches` row-run/union-find rewrite — worth it if the
   scan is ever run on hundreds of dumps? Needs another byte-identical A/B.
3. **Q-W28-3** P04 measured 39 dumps / 28.5 s; this box has 42 dumps and
   38.9–43.4 s. Was the earlier baseline recorded under lower swarm load or
   before 3 dumps were added? Does not affect the A/B result (same inputs).
4. **Q-W28-4** NaN heights would make `max()` and numpy OR differ in principle;
   none of the 42 current dumps contains NaN (all A/B values matched). No
   generator change is proposed here.
