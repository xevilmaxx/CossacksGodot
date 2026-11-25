---
id: G15
ticket: "WAVE G / G15 — measure new tile histogram from dumps / world stats vs A04 baseline"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "ONE new report written. No game code, shader, asset, config, test, git state or runner job changed."
owner_files:
  - docs/terrain_swarm_2026-11-25/reports/G15_tile_measure.md
labels: [observed, derived, inferred, UNVERIFIED]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md
  - docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - variant3d/scripts/game.gd (B03 hunks :1936, :2040, :2183; grep only)
  - variant3d/scripts/world3d_terrain.gd (:357, :1080-1086, :1650, :1746-1755)
  - variant3d/tests/t_terrain_mines.gd (:733-737), t_smallmap_terrain.gd (:341-349)
  - variant3d/tools/terrain_ab_metric.py (read to rule it in/out as a tile metric)
  - app/shots/g32_dump.json, app/shots/t6t90_dumps/dump_20261113_a.json,
    app/shots/t6t90_dumps/dump_20261113_b.json, variant3d/tests/results/w52_self_base.json,
    app/tests/results/w52_self_base.json, variant3d/tests/results/t_combo_shore_mines.json
  - variant3d/.godot_queue/results/00000582.json, 00000583.json + stdout/stderr
  - repo-wide scan of all *.json for full `tileblock` / `tile_index_hist` content (127 files)
parity_guard: "No donor GPU A/B frame and no post-B03 live histogram exist. No donor-parity claim is made."
temp_scripts: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\g15_tile_measure.py, g15_scan_all.py, g15_p3_proxy.py (throwaway, outside repo)"
---

# G15 — Does B03's tile-diversity change move the numbers? (offline measurement)

## 0. Verdict first

**UNVERIFIED.** B03's effect is **not observable from any offline data on disk**. Every
tileblock dump in the repository predates B03's `game.gd` edit, and no result JSON stores
a full runtime `tile_index_hist`. Re-measuring the dumps reproduces the **A04 baseline
exactly** (31 ids, top-5 73.09%, `grass_ground1` 27.87%, 2,036-cell largest patch,
29.93% uniform-component share) — which is itself proof that the dumps were not
regenerated after B03. Section 6 gives the exact runtime probe required.

**observed** = literal file bytes or a measurement made here; **derived** = arithmetic /
control-flow consequence of cited lines; **inferred** = attribution without a live frame;
**UNVERIFIED** = not provable from readable offline data.

---

## 1. Method (read-only, no Godot)

Three throwaway Python scripts were written **only** to the approved temp folder
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the repo), per A04's own
precedent. No repo file other than this report was written; no Godot process was started;
no runner job was submitted.

- `g32_dump.json` / `dump_20261113_a.json`: strict JSON; `tileblock` is a base64 string.
  Decoded to 102,400 uint8 bytes (320² map).
- `w52_self_base.json`: **not strict JSON** — Godot object literals such as
  `Rect2(...)` and `PackedByteArray(...)` break `json.load`. The `tileblock` line was
  extracted with a regex as a `PackedByteArray(0, 79, 79, …)` integer list (102,400 ints).
- Metrics computed exactly as A04 §2/§3 did:
  - **distinct ids** = `len(Counter(tileblock))`;
  - **top-5 share** = sum of the five largest counts / 102,400;
  - **uniform-component share** = cells inside a maximal 4-connected same-id component
    of ≥100 cells / 102,400 (A04's threshold); largest component reported;
  - **neighbour-identical fraction** = share of horizontally and vertically adjacent
    cell pairs with the *same* id (204,160 pairs total at 320²).

### 1.1 Provenance: every dump is pre-B03 — observed

| File | Last write | vs B03 edit |
|---|---|---|
| `inbox/backup/game.gd.bak-B03` | 2026-11-25 14:01:26 | pre-edit backup |
| `variant3d/scripts/game.gd` (B03 hunks present) | 2026-11-25 14:33:11 | **the B03 edit** |
| `app/shots/g32_dump.json` | 2026-11-24 | pre-B03 |
| `app/shots/t6t90_dumps/dump_20261113_a.json` | 2026-11-23 | pre-B03 |
| `variant3d/tests/results/w52_self_base.json` | 2026-11-24 | pre-B03 |
| `app/tests/results/w52_self_base.json` | 2026-11-24 | pre-B03 |

A repo-wide scan found **127 JSON files with a full `tileblock`** (the three above plus
`dump_20261113_b.json`, the `scans/` Python map-gen sims, and `app/scans/` dumps). The
only JSON files written anywhere in the repo **after** 14:33 were four runner-queue files
(tickets 582/583) — none contains tile data. Therefore **no post-B03 tileblock exists on disk**.

Ticket 583 (14:40, after the B03 edit) is the only Godot run in that window: it **failed**
on B05's parse errors (`input_controller.gd:621` and `:876`, per the WAVE G charter),
`stdout.txt` is 75 bytes, and its stderr contains no histogram. It cannot evidence B03.

No file on disk contains a full `tile_index_hist` dictionary. The only runtime histogram
strings are truncated to 400 characters in `t_smallmap_terrain.json` and
`t_combo_shore_mines.json` (the latter a 64² fixture: `{0:3779, 93:42, 98:84, 255:149,
97:42}`, A04 §2) — both pre-B03 and not representative of a 320² meadow.

---

## 2. OBSERVED — measured metrics from the three dumps

All three are seed 20261113, 320² = 102,400 cells. Full numbers:

| Dump | Distinct | Top-5 | Top-5 ids (count, %) | `grass_ground1` (14) | Largest 4-comp | Uniform ≥100 share | Neighbour-identical H / V |
|---|---:|---:|---|---:|---:|---:|---|
| `g32_dump.json` | **31** | **73.09%** | `14` 28,535 (27.87%), `0` 15,993 (15.62%), `16` 15,962 (15.59%), `79` 7,667 (7.49%), `78` 6,691 (6.53%) | 27.87% | **2,036** | **29.93%** (30,651 cells / 84 comps) | **48.07% / 47.65%** |
| `dump_20261113_a.json` | 31 | 73.16% | same five, ±0.1 pp (`14` 27.89%, `0` 15.70%, `16` 15.56%, `79` 7.48%, `78` 6.54%) | 27.89% | 1,824 | 30.32% (31,050 / 84) | 48.10% / 47.75% |
| `w52_self_base.json` | **31** | **73.09%** | byte-for-byte the `g32` histogram | 27.87% | **2,036** | **29.93%** | **48.07% / 47.65%** |

Supporting detail (g32, identical to w52): `test7+test8` (78+79) = 14,358 cells =
**14.02%**; id 14 alone holds 21,508 cells inside ≥100-cell components (42 such comps);
id 0 holds 7,148; id 16 has no ≥100 component (interleaved with 14). Combined neighbour
equality = 97,709 / 204,160 = **47.86%**. `dump_20261113_a` differs only by tiny
seed-capture jitter (largest patch 1,824 vs 2,036) — still the same pre-B03 regime.

*Footnote on a small A04 inconsistency:* A04 §2 quotes "offline 14.63% → 14.89%" for
`test7+8`; direct decode of the cited dumps gives 14.02% (7.49 + 6.53). The A04 §2 table
itself implies 14.02%, so 14.63% appears to be an arithmetic slip in that sentence. It
does not affect the conclusion.

### 2.1 Reproducing the A04 baseline — observed

| Metric | A04 baseline (ticket text) | Re-measured from dumps (G15) | Match |
|---|---:|---:|---|
| Distinct ids | 31 | 31 | exact |
| Top-5 share | 73.09% (`g32`) | 73.09% (`g32`), 73.16% (`dump_20261113_a`) | exact |
| `grass_ground1` | 27.87% | 27.87% | exact |
| Largest uniform patch | 2,036 cells | 2,036 cells | exact |
| Uniform-component share | 29.93% | 29.93% | exact |
| Neighbour-identical | 48.07% H / 47.65% V | 48.07% H / 47.65% V | exact |

**derived:** the exact reproduction means these files are the *same* bytes A04 measured.
They were not re-captured after TRN-DATA, let alone after B03. A04 §2 already noted no
post-TRN-DATA live histogram exists; G15 confirms the same is true post-B03.

---

## 3. OBSERVED — B03's code is present, but nothing downstream of it was captured

B03 landed four hunks in `game.gd`, verified present by grep: `B03-P1` at `:1936`
(re-roll bitmap `test7`/`test8` through donor lists), `B03-P2` at `:2040` (paint stored
`kind=="tile"` stamps as `ground1`), `B03-P3` at `:2183` (redirect `_tb_pick` output
`grass_ground1/2/3` → `grass9/test8/test7`). B03 report status is
`DELIVERED__NO_GODOT_JOB__COORD_GATES_PENDING`; its §5 explicitly says "no live histogram
produced", and its §8 says "Did not run Godot, any runner job, or any test".

Expected direction (B03 §5, **INFERRED**): `test7+test8` ≈ 5–6% (from 14.89% post-TRN-DATA
offline), distinct ≥35, top-5 below 58.52% (post-TRN-DATA offline baseline).

**None of those signatures appears in any offline file.** The dumps still contain
28,535 cells of id 14 and 14,358 cells of ids 78+79; id 8 (`grass9`) has only **1** cell
in g32. A post-B03 tileblock would have to show id 14 sharply reduced (P3 redirect) and
ids 78/79 redistributed (P1 re-roll), with id 8 materially increased. It does not.

---

## 4. DERIVED — why offline data cannot answer this even in principle

1. **P1 is RNG-dependent.** B03 §4 states P1's extra `_tb_pick(2,5)` / `_tb_pick(1,4)`
   draws shift the whole downstream `brng` sequence, so tileblock bytes change for every
   seed. Reproducing them requires **Godot's** RNG, not Python's — A04 §8 already records
   that its 58.52% post-TRN-DATA number was a Python-RNG substitution and therefore
   UNVERIFIED. No offline replay of B03 exists on disk, and a faithful one is out of
   scope for a read-only ticket.
2. **P2/P3 alone do not move the global diversity metrics — a pure relabel redistributes
   counts, it does not create them.** To demonstrate, a deliberately over-approximating
   proxy remapped **every** id 14→8, 15→79, 16→78 in the g32 tileblock (B03-P3 only
   touches `_tb_pick` output on the *post-TRN-DATA* tree, so this is an upper bound, not a
   measurement of B03):

   | Proxy | Distinct | Top-5 | Largest patch | Uniform ≥100 share | Neighbour H/V |
   |---|---:|---:|---:|---:|---|
   | g32 baseline | 31 | 73.09% | 2,036 | 29.93% | 48.07 / 47.65 |
   | mechanical `14→8,15→79,16→78` | 28 | **77.27%** | 2,036 | 29.97% | 48.32 / 47.90 |

   **derived:** the relabel makes top-5 *worse* (id 78 absorbs id 16's 15.59%, id 8
   absorbs id 14's 27.87%) and leaves patch size and uniform share essentially unchanged.
   A03 shows why this is still visually worthwhile — it swaps the worst diagonal-lattice
   art (`grass_ground1/2/3`) for isotropic `grass9/test8/test7` — but **any improvement in
   distinct-id / top-5 / patch metrics must come from P1's re-roll**, which is exactly the
   part that needs Godot. This proxy is labelled DERIVED and is **not** claimed as B03's
   measured effect.
3. `terrain_ab_metric.py` (C01, untracked) is an **image-space** luma/variance/FFT tool,
   not a tile-index metric; it cannot produce the four requested numbers and was not run.

---

## 5. Conclusion — UNVERIFIED

The offline data can only establish that B03 **has not** changed the numbers on disk:
all available tileblocks are byte-identical or near-identical to the A04 baseline. It
cannot establish whether B03 *would* change them at runtime, because the change lives in
GDScript executed by Godot and no post-B03 capture exists. Therefore:

> **B03's tile-diversity effect is UNVERIFIED offline.** No verdict on whether top-5,
> distinct ids, patch size or neighbour equality actually improved is possible without
> the runtime probe in §6. Do not quote 58.52% / 5–6% / ≥35 as achieved values.

---

## 6. Exact runtime probe required (owner: G04 — sole runner owner)

### 6.1 What to capture

Run headless Godot with the **post-B03** tree at **seed 20261113, 320×320**, and write a
new result JSON containing:

```gdscript
# after world/game setup; mirror t_terrain_mines.gd:733-737
var tstats: Dictionary = _dict(_terrain.get("stats"))          # == world.stats for terrain
var hist: Dictionary  = _dict(tstats.get("tile_index_hist", null))
var cells: int        = int(tstats.get("tile_index_cells", -1)) # expect 102400
var ooa: int          = int(tstats.get("tile_index", {}).get("out_of_atlas_cells_clamped", -1))
# also dump the live uint8 grid, for the patch/neighbour metrics:
var tb: PackedByteArray = _game.get("tileblock")               # 102400 bytes
```

Provenance of the probe in the current tree (`variant3d/scripts/world3d_terrain.gd`):
`_tile_index_hist` is declared at `:357`, cleared and rebuilt from `_tile_indices` at
`:1080-1084`, exposed as `stats.tile_index_hist` at `:1650` and as
`stats.tile_index.hist` at `:1749`; `stats.tile_index_cells` is at `:1649`. The historical
A04 citation `:1570/:1641` has shifted because B04 edited the file — use the current
`:1650` / `:1746-1755`.

### 6.2 Metrics from that capture

- **distinct ids** = `hist.size()`;
- **top-5 share** = sum of the five largest `hist.values()` / `cells`;
- **`grass_ground1` share** = `hist.get("14", 0) / cells`;
- **`test7+test8`** = `(hist.get("78",0) + hist.get("79",0)) / cells`;
- **uniform-component share and neighbour-identical fraction cannot be derived from a
  histogram** — they need the grid. Decode the captured `tb` bytes and run the same
  4-connected / neighbour scan used in §2 (the G15 temp script is reusable). Alternatively,
  a new non-G15 ticket may add a `stats.tile_index_patch` diagnostic that scans
  `_tile_indices` in `world3d_terrain.gd` and publishes both numbers.

### 6.3 A/B design (needed because P1 shifts the RNG stream)

Two Godot runs with the **same seed**, by G04 only:

1. **pre-B03 control** — restore `inbox/backup/game.gd.bak-B03` (post-TRN-DATA, pre-B03);
2. **post-B03 candidate** — current `variant3d/scripts/game.gd`.

Capture `world.stats.tile_index_hist` + `game.tileblock` from each. Compare the four
metrics; also assert `same_seed_byte_identical` (two runs of the *same* tree) and that
no out-of-atlas id appears. Directionally expected (from B03 §5 / A04 §7, **not** yet
achieved): distinct ≥35, top-5 < 58.52%, `test7+8` < 10%, largest patch < 800 cells and
cells in ≥100-cell uniform components < 15%. Note the immediate control is the
post-TRN-DATA tree, since the on-disk dumps are even older (pre-TRN-DATA).

---

## 7. Scope statement

Files created by this ticket: **this report only**. The three analysis scripts live in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the repo) and are not
repo changes. No game code, shader, asset, config, test, git state or runner job was
changed; Godot was not executed. All statements about what B03 *would* do at runtime are
INFERRED or UNVERIFIED, and no donor-parity claim is made.

*End of G15.*
