---
id: Y01
title: "Owner clarification — data proof of the concentric maze: which array carries it, and was it position-locked in pre-swarm dumps"
agent: "Y01 (OWNER CLARIFICATION wave, read-only subagent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER__NO_GODOT__NO_CODE_EDIT
scope: "One new file only — this report. No runner job, no Godot process, no source/asset/config/test/JSON/PNG/donor/git edit."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, UNVERIFIED]
parity_guard: "NO DONOR PARITY CLAIM. All measurements are in-repo, internal-consistency only. No donor file was read, copied or executed by this agent."
verdict: "PARTIALLY CONFIRMED / PARTIALLY REDIRECTED. CONFIRMED by data: terrain==5 is the carrier of the concentric maze, and its positions are position-locked across all available pre-swarm seed-20261113 dumps (IoU 0.996–1.000); the visible art changed via tileblock. REDIRECTED: the dominant producer of the maze cells is the HEIGHT-GRADIENT collision pass (game.gd:1240-1264, now :1275-1308), not the hill/stone dc discs at :846-852 — 99.5% of terrain==5 cells reproduce exactly from the dumped height array, radial ring-profile correlation 0.9996–1.0000."
---

# Y01 — Maze data proof

> [!IMPORTANT]
> Labels: **OBSERVED** = literal bytes decoded from an on-disk dump, or a
> literal source line. **DERIVED** = arithmetic/control-flow consequence of
> observed values. **UNVERIFIED** = not provable with the available instruments.
> No Godot process was launched, no runner job submitted, no donor file read,
> no file other than this report written. **No donor parity claim.**

---

## 0. Mandate

Owner: *"the maze patterns in realmap.png have ALWAYS been there, position-locked,
and only the colour changed."*

COORD: the maze was traced to `game.gd:846-852` (hill/stone stamps painting
`terrain=5` at `dc` radii) plus `:1240-1264` (height-gradient rock painting).

This ticket must **prove or refute with data, not just code**: decode an on-disk
dump containing terrain/height/tileblock, correlate `terrain==5` with the
concentric rings, test whether the same cells are rock in pre-swarm dumps, and
identify which array carries the maze.

Charter/guardrails read: `WAVE_G_CHARTER.md` (standing rules :29-33), `CHARTER.md`
(labels :55-69, disjoint ownership :67-68, no donor parity :57-58),
`A05_relief_visibility.md` (height/relief chain :78-110, collision pass :95,
:240-249), `DPATTERN_01_relief_grids.md` (§2/§5/§8), `RELIEF_01_stamping.md`
(§2-3), `RELIEF_02_stamp_marker.md` (§2-4).

---

## 1. Dumps decoded (OBSERVED)

All arrays are base64 -> raw little-endian, `W=H=320`, `102400` cells.
`terrain`, `tileblock`, `blocked` = 1 byte/cell (102,400 B); `height` = float32
(409,600 B). Decode confirmed by exact byte-length closure.

| Dump | Path | File timestamp | Seed | Arrays present |
|---|---|---|---|---|
| G32 | `app/shots/g32_dump.json` | 2026-11-24 11:35:49 | 20261113 | terrain, height, tileblock, blocked |
| A | `app/shots/t6t90_dumps/dump_20261113_a.json` | 2026-11-23 13:09:19 | 20261113 | terrain, height, tileblock, blocked |
| B | `app/shots/t6t90_dumps/dump_20261113_b.json` | 2026-11-23 13:09:46 | 20261113 | terrain, height, tileblock, blocked |
| W52 (app) | `app/tests/results/w52_self_base.json` | 2026-11-24 11:18:59 | 20261113 | terrain, height, blocked — **no tileblock** |
| W52 (variant3d) | `variant3d/tests/results/w52_self_base.json` | 2026-11-24 11:35:48 | 20261113 | same as above |

**OBSERVED:** all four dump families predate the 2026-11-25 terrain swarm.
The charter is dated 2026-11-25; the dumps are dated 23–24 Nov. These are
genuine **pre-swarm** dumps.

**OBSERVED:** the four arrays decode to:
- `terrain` values `{0, 1, 2, 5}` only. `terrain==5` count: **6,967** in G32/W52,
  **6,965** in A/B.
- `height` range exactly `−2.9640 … +2.9640`, 8,065 distinct values, 64,712
  zeros — the clamped land band described at `game.gd:1213-1239` / A05 §2.
- `tileblock`: 31 distinct ids; `blocked`: 2 values.

An additional 128 JSON dumps on disk carry `terrain` (seeds 7/8/9/20261113,
sizes 128²/320²); they are used in §4 only.

**OBSERVED (code provenance):** `git blame` on the hill/stone `dc` paint
(`game.gd:847-852` at read time) attributes those lines to commit `b6b1f2c5c`,
2026-11-24 — i.e. the code that paints `terrain=5` in this way already existed
on the day of the dumps. **UNVERIFIED:** the exact commit that produced the
2026-11-23 dump A is not pinned; no build/revision id is stored in the dump.

---

## 2. Which array carries the maze? (OBSERVED + DERIVED)

### 2.1 `terrain` carries the ring mask

Rendering the decoded `terrain==5` mask as a 320² image (`nearest`, written to
the agent temp dir, **not** into the repo) reproduces the characteristic
concentric/annular stepped bands and arcs seen in `realmap.png`. Three dominant
4-connected components (OBSERVED from the mask):

| Component | Cells | Centroid (x,y) | Max radius | BBox (x0,y0)-(x1,y1) |
|---|---:|---|---:|---|
| 1 | 2,424 | (201.5, 233.0) | 93.0 | (124,145)-(269,314) |
| 2 | 512 | (124.8, 64.6) | 54.0 | (85,30)-(167,88) |
| 3 | 479 | (79.4, 162.4) | 41.1 | (49,136)-(116,183) |

40 components have ≥8 cells. These are the maze rings; the bands are 1–3 cells
wide and nest around plateaus/hills.

### 2.2 `tileblock` is the *art/colour* downstream of `terrain`

(OBSERVED) Fraction of each tileblock id's cells that are `terrain==5`:

| tileblock id | cells of that id | also terrain==5 | fraction |
|---:|---:|---:|---:|
| 20 | 2,415 | 2,356 | 97.6% |
| 19 | 879 | 847 | 96.4% |
| 23 | 1,255 | 1,208 | 96.3% |
| 17 | 1,498 | 1,432 | 95.6% |
| 22 | 265 | 252 | 95.1% |
| 18 | 282 | 266 | 94.3% |
| 24 | 2,283 | 598 | 26.2% (mixed) |

Ids `{17,18,19,20,22,23}` are the rock/cliff atlas cells: 6,594 cells total,
of which **6,361 (96.5%)** are `terrain==5`. Conversely **6,361 / 6,967 = 91.3%**
of all `terrain==5` cells carry a rock tile id.

**DERIVED:** the causal direction is `terrain` (rock classification) ->
`tileblock` (rock tile id) -> shader/colour. `tileblock` does **not** originate
the maze; it paints the maze. `height` is the *driver* (§3). A 320² false-colour
render of `tileblock` shows broad mottled patches and no independent concentric
rings; the rings appear only in `terrain`/`height`.

**DERIVED:** this is consistent with `world3d_terrain.gd:110-116,973-998`
(`tileblock` is the tile-index source, UV2.x = donor tile index) and with
A05 §4 rank 8 ("pale stepped marks on flat land are tile-id art, not relief"),
but it does **not** by itself identify the producer — §3 does.

---

## 3. Spatial correlation with the concentric rings (OBSERVED + DERIVED)

### 3.1 Exact reproduction of the collision pass from `height`

I re-implemented `game.gd:1240-1264` (current tree `:1275-1308`) **exactly** on
the decoded height array: cardinal `|dh|>0.5` at `(x±1,y)`, `(x,y±1)`; diagonal
`|dh|>0.55` at `(x+1,y−1)` and `(x+1,y+1)`; skip `terrain∈{3,4}`.

| Quantity | Cells |
|---|---:|
| `terrain==5` in dump | 6,967 |
| steep cells recomputed from `height` | 7,194 |
| `terrain==5` **and** steep | **6,932 = 99.5% of terrain==5** |
| `terrain==5` **not** steep | **35 = 0.5%** |
| steep not `terrain==5` | 262 = 3.6% of steep |

The 35 non-steep rock cells are isolated single cells (no component larger than
1 cell), consistent with the small `dc<=1.6`/`dc<=2.2` hill/stone discs at
`game.gd:847-852`, not with rings.

### 3.2 Radial ring-profile correlation

For each of the three component centroids, I binned cells by integer radius
`r=0..79` and compared the `terrain==5` fraction profile with the recomputed
steep fraction profile:

| Centre (x,y) | `corr(terrain5_profile, steep_profile)` |
|---|---:|
| (201.5, 233.0) | **0.9996** |
| (124.8, 64.6) | **0.9996** |
| (79.4, 162.4) | **1.0000** |

**DERIVED:** the concentric rings are, to measurement precision, the
**contour bands of the height field** produced by the collision pass, not a
free-standing stamp-art pattern. The ring at radius ≈18–22 around centre 1
peaks at 40.8% `terrain==5` / 42.1% steep; the profile follows the plateau
height `h≈+1.26`.

### 3.3 Verdict on COORD's code trace

- **CONFIRMED (DERIVED from OBSERVED):** `terrain==5` is the carrier, and
  `:1240-1264` (`game.gd`, now `:1275-1308`) is its **dominant** producer —
  99.5% of the rock cells reproduce from the dumped height alone.
- **REDIRECTED:** the `dc<=1.6`/`dc<=2.2` hill/stone paints at `:846-852`
  account for at most **35 cells (0.5%)** in this dump. They are not the maze.
  With `hill=22`, `stone=24` stamps in `meta.stamp_counts`, the dc discs are
  real but tiny and mostly coincide with already-steep cells.
- **UNVERIFIED:** the current working tree contains uncommitted `B03-RELIEF`
  edits that (a) change the hill branch to `pass` (`game.gd:853-861`) and
  (b) gate the collision paint with `if _relief_stamp_mask[i] == 0`
  (`game.gd:1298-1307`). Their runtime effect is **not measured** — no runner
  job was submitted and no new dump exists. No claim is made about them.

---

## 4. Position-locking across pre-swarm dumps (OBSERVED)

### 4.1 Same seed, same rock positions

| Pair | terrain array | height array | `terrain==5` sets |
|---|---|---|---|
| W52 vs G32 | **byte-identical** (0 diff cells) | **byte-identical** | 6,967 / 6,967 — **IoU 1.0000** |
| A vs B | **byte-identical** | **byte-identical** | 6,965 / 6,965 — IoU 1.0000 |
| G32 vs A | 267 cells differ (all arrays) | identical | 6,952 overlap / 6,980 union — **IoU 0.9960** (15 added, 13 removed; all differences in x∈[210,229], y∈[164,189]) |

**DERIVED:** the owner's "position-locked" claim is **CONFIRMED for the
available pre-swarm seed-20261113 dumps**: the rock mask is bit-identical in
two independent dump families (W52 test result and G32 shot) and 99.6% identical
in the third, with the small residual confined to one local patch.

### 4.2 "Only the colour changed" — CONFIRMED in the data

G32 vs A (OBSERVED):

- `height`: **identical** (hash `569e3860e2` in both).
- `terrain`: 99.74% identical; `terrain==5`: IoU 0.9960.
- `tileblock`: **25,333 cells differ** (24.7% of the map; hash `23315c85ab` vs
  `2706186156`). Inside rock cells 1,350/6,967 (19.4%) changed id, mostly
  permutations among the rock ids (`20->22` 60, `17->20` 58, `20->19` 54,
  `19->20` 54, …); outside rock cells 23,983/95,433 (25.1%) changed.
- `blocked`: 2,322 cells differ.

**DERIVED:** the *mask* stayed fixed while the *tile-id/art* array changed by a
quarter of the map — exactly the owner's "same positions, only colour changed",
at the array level. **UNVERIFIED:** whether the screenshot's hue delta is caused
by these tileblock changes or by shader/colour tuning (B01/A07) — no GPU A/B
was run in this ticket.

### 4.3 Scope limit — not universal across seeds

(OBSERVED) Across all 128 dumps with a `terrain` array, `terrain==5` counts range
from 0 to 10,925 and hashes differ by seed/config; e.g. seed 7 alone has masks
of 16, 26, 295, 5,861, 7,197, 10,925 cells; seed 20261113 also has an "atomic"
probe with 292 rock cells (`app/scans/atomic/def.json`). **DERIVED:** the maze is
position-locked *for the shipped map/config/seed*, not a seed-independent
constant of the generator.

---

## 5. Which array carries the maze — direct answer

| Array | Role | Evidence |
|---|---|---|
| **`terrain`** | **Carrier of the maze positions.** `terrain==5` *is* the concentric rock mask. | §2.1 components; §3 99.5% collision-pass reproduction; §4 bit-identical across pre-swarm dumps |
| **`height`** | **Driver / generator of the rings.** Contour bands `|dh|>0.5/0.55` produce the mask. | §3 radial correlation 0.9996–1.0000; height identical while art changed |
| **`tileblock`** | **Art/colour only**, downstream of `terrain`; does not originate the pattern. | §2.2 96.5% of rock tile ids are terrain5; 25% changed while mask stayed fixed |

---

## 6. UNVERIFIED — do not guess

1. **No 240² dump exists on disk.** `realmap.png` was captured with the shipped
   240² config (`G04_gate_log.md:234-237`, seed 20261113); every dump found is
   320² (or 128² debug). All ring measurements above are therefore on the
   **320²** map, not the exact captured map. The visual correspondence with
   `realmap.png` is strong but **UNVERIFIED at cell level**.
2. **No donor parity claim.** No donor file was read, copied or executed; no
   donor A/B frame exists. All facts are in-repo internal consistency.
3. **No runner.** No Godot process, no new capture, no new dump. Nothing in this
   report reflects the uncommitted `B03-RELIEF` edits (§3.3).
4. Exact cell-to-pixel transform for `realmap.png` (`camera_pos=(144.11,58,−88.57)`,
   `target=(384.11,58.61)`, from `G04_gate_log.md:248-251`) was not inverted; no
   pixel-level correlation was computed.
5. The 262 steep-but-not-rock cells and the 35 rock-but-not-steep cells are not
   fully attributed; edge/guard interactions with later `_gen_patterns` paints
   remain **UNVERIFIED**.

### Exact probe needed (no new runner used by this agent)

To close item 1, the owner/G04 should capture a dump **from the same windowed
240² seed-20261113 run** that produces `realmap.png`:

```
python variant3d\tools\godot_runner.py run --id y01-240dump -- --path variant3d \
  -- --screenshot ".../y01/realmap240.png" --screenshot-frames 10 \
     --seed 20261113 --dump-map ".../y01/terrain240.json" --timeout 600
```

Then repeat §2–§4 on that file: decode `terrain`/`height`/`tileblock`, recompute
the `|dh|>0.5/0.55` mask, check `corr(terrain5, steep)≈1`, and align the
screenshot to cells via the camera matrix. This requires **no donor access** and
no code change — only a dump of the already-existing capture configuration.

---

## 7. Summary

- **OBSERVED:** four pre-swarm dump families (23–24 Nov) carry a decoded
  `terrain==5` mask; 6,967 rock cells at seed 20261113/320².
- **DERIVED:** the concentric maze is the `terrain==5` mask; **99.5%** of it
  reproduces exactly from the dumped height via the collision pass
  (`game.gd:1240-1264`), with radial ring-profile correlation **0.9996–1.0000**.
  The hill/stone `dc` discs at `:846-852` contribute only **35 cells (0.5%)**.
- **DERIVED:** `terrain` = positions, `height` = driver, `tileblock` = colour/art.
- **OBSERVED/DERIVED:** owner's "position-locked, only colour changed" is
  **confirmed at array level**: rock mask IoU 0.996–1.000 across pre-swarm
  dumps, height bit-identical, tileblock 24.7% changed.
- **UNVERIFIED:** exact 240² screenshot alignment, donor parity, and the effect
  of concurrent uncommitted edits. **No donor parity claim; no Godot run.**

*End of Y01. This agent wrote only this report.*
