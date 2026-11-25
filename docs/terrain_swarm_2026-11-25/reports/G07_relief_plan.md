---
id: G07
ticket: TERRAIN-SWARM-WAVE-G / G07 (READ-ONLY feasibility plan)
title: "A05 Fix #1 resolved — minimal faithful donor-active relief-grid subset as a disjoint follow-up ticket"
agent: "G07 (Wave G, read-only)"
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "One new file only: this report. No source, asset, config, test, shader, JSON, PNG, donor, queue or git edit; no Godot process, no runner job."
outputs:
  - docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md
labels: [observed, derived, inferred, UNVERIFIED, BLOCKED, PORT APPROX]
parity_guard: "PORT APPROXIMATION — no donor GPU A/B frame exists (CHARTER §3). No donor parity claim. Every substitute grid/table/scale in this plan is PORT APPROX."
verdict: "B03'S DEFERRAL IS CORRECT AND IS RESOLVED BY SEPARATING DATA FROM CODE. FULL w×h FLOAT WINDOWS ARE NOT IN DPATTERN_01 AND ARE OUT OF SCOPE. THE MINIMAL FAITHFUL SUBSET = {k_ravine_big_stone_1} (Tier 1, requires a prerequisite derived 8x10 extraction) OPTIONALLY + {hil1, g_hil4} (Tier 2, tables already in DPATTERN_01 Appendix A). k_ravine_1 STAYS BLOCKED / DONOR-DISABLED. OWNER FILE game.gd (B03's) → PLAN AS FOLLOW-UP."
---

# G07 — Relief-grid feasibility plan (A05 Fix #1 resolved)

> [!IMPORTANT]
> Labels: **observed** (literal source line, decoded donor field quoted from a
> prior report, or literal table), **derived** (arithmetic/control-flow
> consequence), **inferred** (attribution without a donor GPU A/B),
> **UNVERIFIED** (not measurable with available instruments), **BLOCKED** (no
> producer/instrument exists), **PORT APPROX** (labelled substitute, not donor
> truth). No donor file was read, copied or executed by this worker; all donor
> numbers are cited from `DPATTERN_01_relief_grids.md`. No Godot process was
> launched. No code, config, asset, test, shader, donor, queue or git edit.

---

## 0. Mandate and boundary

Wave G charter (`WAVE_G_CHARTER.md:45`) assigns G07: *"A05 Fix #1 feasibility:
donor-active relief grids (ravine_big) as a future ticket"*. The dispatch adds
the specific conflict to resolve: B03 deferred A05 Fix #1, arguing that full
`w×h` tables are not port data and that Appendix A calls the 8×10 means
"debug/preview aids only".

Read first, in full: `WAVE_G_CHARTER.md`, `CHARTER.md`,
`reports/A05_relief_visibility.md`, `reports/B04_relief_impl.md`, and
`docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md`. Supporting
reads (all read-only): `reports/B03_diversity_impl.md`,
`reports/A10_regression_constraints.md`,
`docs/coord_swarm_2026-11-25/reports/RELIEF_02_stamp_marker.md`,
`.../RELIEF_SEED_SCAN_01.md`, `variant3d/scripts/{game,main,pattern_gen}.gd`,
`variant3d/tests/t_map_variety.gd`, `variant3d/tools/scan_map.py`, and
`variant3d/assets/terrain/patterns/donor_patterns.json`.

Standing rules honoured: report root only, one file; no runner (G04 is sole
runner owner, `WAVE_G_CHARTER.md:31`); no donor access; no code edit;
disjoint ownership; every substitute labelled PORT APPROX; no donor parity
claim.

---

## 1. What B03 actually deferred, and why it is right

**OBSERVED** (`B03_diversity_impl.md:200-218`): B03 did not land A05 Fix #1 and
gave four reasons:

1. `DPATTERN_01` does **not** contain full `w×h` float32 tables; its
   Appendix A explicitly labels the 8×10 block means *"debug/preview aids only
   — stamp from the full grid, not from these means"* (`DPATTERN_01:595-600`).
2. A05 §7.5 records full windows are **not in the port**; exporting them is a
   **derived-data task**, and B03's ownership forbids adding an asset file.
3. A05's acceptance needs runtime proof (`candidates>0`, `applied_cells>0`,
   changed hashes, a cell below −2.0) and B03 is forbidden to run Godot.
4. Adding height/collision stamps changes `terrain`/`tileblock` for many seeds,
   risking the mapgen/scan gates COORD owns.

**DERIVED — the flaw in A05 Fix #1 as written.** A05 §6 Fix 1
(`:304-324`) asks for "full derived float32 numeric tables" for "every decoded
donor-active relief id (min. `k_ravine_big_stone_1`, plus `plt1/3/4/5`,
`hil1..4`, `g_hil1..9`, `f_plt_big_1`)". That request is **not executable from
DPATTERN_01 alone**: the report supplies (a) per-pattern metadata and exact
min/max for 29 inventory rows (§3), (b) a representative row RLE for a handful
(§4), and (c) **only four** 8×10 block-mean tables in Appendix A — A1
`k_ravine_1`, A2 `plt2`, A3 `hil1`, A4 `g_hil4` (`DPATTERN_01:595-652`).
There is **no 8×10 table and no full grid for `k_ravine_big_stone_1`** in that
report. So "full derived tables for every decoded id" would require new
read-only donor decoding (§7 recipe, `:450-495`) before any code is possible.

**Resolution:** split the work into two disjoint tickets — a **data
extraction** step (offline, derived numbers only, no donor binary shipped) and
a **code** step in `game.gd`. Keep the code step minimal: reuse the *existing*
8×10 shape, because the current port already stamps from exactly that shape
(`game.gd:92-113,918-934`) and generalising the sampler to per-grid `w×h`
would add risk without adding donor fidelity. All such stamps stay **PORT
APPROX** because the tables are derived block means (Appendix A) or a freshly
derived block mean, not the donor's engine blend.

---

## 2. Inventory — which decoded grids are actually usable

### 2.1 Reachability filter (observed)

The port places stamps only from `donor_patterns.json` families
(`pattern_gen.gd:56-63,76-79`), and its relief recipes are
`RELIEF_RECIPES` (`pattern_gen.gd:43-52`): `mountains`, `plateau_big`,
`plain_huge`, `ravine_big`, `plateau`, `plateau_small`, `hills_dark`,
`hills_light`. The JSON families (read-only) confirm the same names.
Therefore a grid is usable **only if its name occurs in an exported family
and its family has a recipe**. Donor `ravine_medium` is `//`-disabled
(`dogenerate.inc:1760`) and is **not exported** — `k_ravine_1` is absent from
`donor_patterns.json` and every family list (`RELIEF_02:68-84`; `main.gd:774-776`).

### 2.2 Decision table (observed metadata / derived verdicts)

| DPATTERN_01 grid (§3 line) | Donor family / status | In `donor_patterns.json` + recipe? | Table in DPATTERN_01? | Verdict for this ticket |
|---|---|---|---|---|
| `k_ravine_big_stone_1` (`:152`) | `ravine_big` — **donor-ACTIVE** (`:341-346`, `dogenerate.inc:1761`) | YES (`ravine_big` family; recipe `:47`) | **NO** — metadata only (84×100, G=8225, min/max) | **Tier 1: MUST add** after prerequisite 8×10 extraction |
| `hil1` (`:160`) | `hills_dark` — donor-active (`:696`, recipe `:50`) | YES | **YES** — Appendix A3 (`:628-639`) | **Tier 2: add (cheap)** |
| `g_hil4` (`:166`) | `hills_light` — donor-active (`:729`, recipe `:51`) | YES | **YES** — Appendix A4 (`:641-652`) | **Tier 2: add (cheap)** |
| `k_ravine_1` (`:142`) | `ravine_medium` — donor-**DISABLED** (`:341-346`) | **NO** | YES — Appendix A1 (already in port) | **BLOCKED — keep blocked; do NOT add producer/recipe/family** |
| `plt2` (`:154`) | `plateau` — active | YES | YES — Appendix A2 (already in port) | Already in port; no change |
| `k_ravine_2..9`, `k_ravine_big_1`, `i_mnt_big_1` (`:143-151,170`) | disabled / orphan / unstamped | NO | metadata (or none) | EXCLUDE — unreachable, no producer |
| `g_mnt_1`, `g_mnt_3` (`:168-169`) | `mountains` active but **all-zero grid** (`:271-279`) | YES | N/A | EXCLUDE — no height payload; relief lives in `terrainmesh*` props (`:280-285`), a different ticket |
| `plt1/3/4_fixed/5`, `f_plt_big_1`, `d_plt1`, `hil2/3/4`, `g_hil1/2/9` (`:153-167`) | donor-active families | YES | **metadata only** (§3), no 8×10 table in DPATTERN_01 | DEFER — would need the same extraction as Tier 1; adding them all is not minimal |

**DERIVED — minimal faithful subset.** The smallest set that restores a whole
missing donor-active relief *class* (A05 rank 3, `:259`) is exactly one grid:
**`k_ravine_big_stone_1`**. Its prerequisite is a derived 8×10 table. Two more
grids, **`hil1`** and **`g_hil4`**, can be added at zero data cost because their
tables are already printed in DPATTERN_01 Appendix A; each is independently
droppable if a gate regresses. Nothing else from DPATTERN_01 is needed for a
minimal fix.

**BLOCKED — non-negotiable:** `k_ravine_1` stays donor-disabled and unreachable
(no `ravine_medium` recipe, no `main.gd` producer change, no new family). Its
existing `RELIEF_GRID_K_RAVINE_1` const remains a dead, for-completeness table
exactly as today (`game.gd:94-103`, `:970-973`; `main.gd:774-776`).

---

## 3. Exact data shape for the follow-up ticket

### 3.1 Current shape (observed, `game.gd`)

- `const RELIEF_GRID_W := 10`, `const RELIEF_GRID_H := 8` (`:92-93`).
- Each grid is a **flat `Array` of 80 little-endian-derived floats**, 8 rows ×
  10 columns, row-major; constants `RELIEF_GRID_K_RAVINE_1` / `_PLT2`
  (`:94-113`).
- `RELIEF_GRID_META[name]` (`:118-123`):
  `{scale: float, min: float, max: float, w: int, h: int, offset: int, lib: String}`
  — `offset` is the donor byte offset (traceability only; no bytes shipped).
- Id gate is a hard-coded `if donor_name == "plt2" … elif == "k_ravine_1"`
  (`:974-982`), counting `relief_grid_candidates` (`:983-984`).
- Sampler `_sample_relief_grid(grid,u,v)` bilinearly samples the fixed 10×8
  grid over the stamp bbox (`:918-934`); caller maps
  `gu = 0.5 + (x-cx)/(2*hx)`, `gv = 0.5 + (y-cy)/(2*hy)` (`:1049-1050`).
- Blend (`:1051-1057`):
  `h = clampf(h + gv*scale, maxf(gmin, -2.964), minf(gmax, +2.964))`, then
  `_relief_donor_mask[i] = 1`; **no RNG draw**, no terrain/tile write here.
- Ledger `map_meta["relief_grid"]` (`:1104-1113`): `label`, `tables`,
  `source`, `candidates`, `applied_cells`, `blend`, `clamp_reconcile`,
  `row_flip`.

### 3.2 Tier 2 tables — transcribe verbatim from DPATTERN_01 Appendix A

All floats below are **observed** from `DPATTERN_01:628-652`; each 8×10 array
is 80 floats, same shape as `RELIEF_GRID_PLT2`. Label **PORT APPROX** (derived
block means, "debug/preview aids only", `DPATTERN_01:599-600`).

`RELIEF_GRID_HIL1` (Appendix A3 `:631-638`), row-major 8 rows × 10 cols:

```
 0.287  0.160  0.009  0.000  0.000  0.000  0.000  0.000  0.000  0.120
 0.559  0.710  0.466  0.156  0.020  0.000  0.000  0.001  0.016  0.152
 1.236  1.462  1.051  0.562  0.197  0.000  0.000  0.054  0.166  0.422
 2.694  2.712  2.005  1.434  0.515  0.037  0.000  0.217  0.869  1.906
 3.402  3.039  2.267  1.576  0.519  0.045  0.000  0.203  0.976  1.981
 1.807  1.551  1.094  0.626  0.212  0.004  0.000  0.062  0.343  0.835
 1.070  0.699  0.234  0.019  0.000  0.000  0.000  0.015  0.189  0.446
 0.191  0.079  0.004  0.000  0.000  0.000  0.000  0.056  0.171  0.160
```

`RELIEF_GRID_G_HIL4` (Appendix A4 `:644-651`):

```
 0.126  0.152  0.037  0.000  0.000  0.000  0.000  0.000  0.001  0.024
 0.760  0.557  0.227  0.075  0.065  0.026  0.002  0.001  0.170  0.483
 1.324  0.686  0.335  0.311  0.245  0.131  0.018  0.187  0.847  1.212
 1.705  1.609  0.801  0.402  0.262  0.125  0.020  0.176  0.394  0.523
 0.839  1.571  1.505  0.994  0.494  0.135  0.006  0.000  0.015  0.162
 0.801  1.212  0.880  0.656  0.282  0.081  0.005  0.000  0.011  0.167
 0.719  0.747  0.547  0.464  0.295  0.119  0.009  0.000  0.014  0.176
 0.276  0.334  0.350  0.302  0.201  0.096  0.013  0.125  0.046  0.229
```

`RELIEF_GRID_META` additions (**observed** from `DPATTERN_01` §3/§4.5; keep
`HeightFieldScale` verbatim — `hil1` is **0.65**, not 1):

```
"hil1":   {"scale": 0.65, "min": 0.0,
           "max": 3.861302375793457, "w": 25, "h": 41, "offset": 1000,
           "lib": "pattern.lib:33111-33112"}
"g_hil4": {"scale": 1.0, "min": -4.321273157012473e-13,
           "max": 1.9169878959655762, "w": 33, "h": 59, "offset": 1912,
           "lib": "pattern.lib:366499-366500"}
```

### 3.3 Tier 1 — `k_ravine_big_stone_1` prerequisite data ticket

**OBSERVED** metadata (`DPATTERN_01:152`; §4 has no dedicated decode subsection
for this pattern): `w=84, h=100`, `file=477,326 B`, grid `G=8225 / 33,600 B`,
`scale=1`, decoded `min=-2.963627338409424`, `max=+0.17386487126350403`,
MATCH `pattern.lib:730045-730046`.

The follow-up must **first** derive an 8×10 block-mean table with the §7 recipe
(`:450-495`): read `data\pattern\k_ravine_big_stone_1.pattern` **read-only**,
decode `float32[84*100]` at the exact offset 8225, reshape row-major
`(100,84)`, and block-average rows `[j*100/8,(j+1)*100/8)`, cols
`[i*84/10,(i+1)*84/10)` — the same rule that produced Appendix A
(`:599-600`). **Verification gate:** decoded min/max must equal the two
`pattern.lib` literals above bit-exactly before the table is used (§4.7,
`:287-298`). The result is a **derived numeric table**, never a copied donor
binary (`DPATTERN_01:524-529`); label **PORT APPROX**. Then add
`RELIEF_GRID_K_RAVINE_BIG_STONE_1` (80 floats) and meta:

```
"k_ravine_big_stone_1": {"scale": 1.0, "min": -2.963627338409424,
    "max": 0.17386487126350403, "w": 84, "h": 100, "offset": 8225,
    "lib": "pattern.lib:730045-730046"}
```

**DERIVED — why not use the full 84×100 window.** Adding a full window would
require a per-grid `w/h` sampler and a different clamp/footprint path; that is
a larger data + code change, is not present in DPATTERN_01, and is explicitly
not needed to restore the ravine *class*. It is a separate derived-data ticket,
not part of this minimal one.

### 3.4 Code delta in `game.gd` (minimal, no new math/RNG)

1. Add the new const arrays and meta entries from §3.2/§3.3 beside `:94-123`.
2. Extend the id gate at `:974-982` from two `if/elif` branches to a lookup over
   the new ids (e.g. additional `elif donor_name == "hil1"/"g_hil4"/
   "k_ravine_big_stone_1"` branches, or a name→const dictionary). **Keep**
   "no id invented": only names present in `RELIEF_GRID_META` and in
   `donor_patterns.json` may match. Do **not** add `k_ravine_1` behaviour.
3. Leave `_sample_relief_grid()` (`:918-934`), the blend/clamp (`:1039-1058`),
   the footprint math (`:1016-1033`) and the collision pass (`:1243-1264`)
   **byte-identical** — all new grids are the same 8×10 shape.
4. Update the ledger at `:1104-1113`: `tables` lists the added ids; `source`
   cites "DPATTERN_01 Appendix A3/A4 + derived A-rule for
   `k_ravine_big_stone_1` — 8×10 block means, debug/preview aids only"; keep
   `label`, `blend`, `row_flip: "UNVERIFIED"` and add an explicit
   `"port_approx": true` for each table.
5. Backup per charter: `inbox/backup/game.gd.bak-<TICKET>` before first edit.

**Not touched by this ticket:** `main.gd` dump producer (`:767-803`) — the
`relief_stamps` marker stays `plt2`/`k_ravine_1` only; acceptance uses the
`meta.relief_grid` ledger and decoded `height`/`tileblock` hashes instead
(§6). `pattern_gen.gd` (no new recipe, especially **no** `ravine_medium`),
`world3d_terrain.gd`, shader, atlas loader, input/fx scripts, config, tests,
`app/**`.

---

## 4. Ownership and sequencing (disjointness)

**OBSERVED:** `game.gd` is B03's exclusive Wave-B file
(`B03_diversity_impl.md:5,9-11`; `WAVE_G_CHARTER.md:20`); B04 owns
`world3d_terrain.gd` (`B04:5-9`). `WAVE_G_CHARTER.md:33` allows COORD to send
follow-ups through the same session.

**PLAN (derived):**
- **Ticket R-DATA (prerequisite, disjoint file):** produce the derived
  `k_ravine_big_stone_1` 8×10 table with the DPATTERN_01 §7 recipe; output is
  numbers in a report or a **new** derived-only data file, never a donor
  binary. No repo source edit. Can run in parallel with R-CODE for Tier 2,
  because Tier 2 needs no donor access.
- **Ticket R-CODE (follow-up, exclusive owner of `variant3d/scripts/game.gd`
  ONLY):** transcribe Tier 2 tables (and Tier 1 table once R-DATA lands),
  extend the id gate and ledger per §3.4. Must be assigned **after B03 is
  closed/integrated by COORD** — do not co-edit `game.gd` in parallel with
  B03. No other file.
- **G04 (sole runner owner)** re-runs all gates (§6). No other Wave-G agent
  submits jobs (`WAVE_G_CHARTER.md:31`).

---

## 5. Gate-impact analysis (what must not break)

**OBSERVED gate predicates (A10 / scan_map):**
- `t_map_variety.gd:71-89,187-228`: `_summary()` includes `terrain`, `blocked`,
  `tileblock`, `res`, `starts`, `meta`; asserts `different_seeds_different_layout`,
  `same_seed_byte_identical`, map-type water-fraction deltas.
- `scan_map.py:420-510`: per-dump gates `water` vs mask (±5 pp), `patches`,
  `mean_sz`, `purity=100`, `clear=100`, `sand_ring>=90`, `cliff>=80`,
  `tileflow>=99`, `reach=True`.
- `A10` structural atoms (`t_terrain_only`, `t_combo_all`, `t_season_overlay`)
  build from **stub height arrays / fixed dumps**, not from `game.gd`
  generation (`A10:41-128`): flat-grid guards, 1/4096/7938/4096 topology,
  UV2/tileblock byte identity, `height_at_world_samples`,
  `resource_y_matches_terrain`, luma floors.
- `selftest 29/29`, `uitest 17/17` run real `game.setup()` and are sensitive to
  walkability/build slots (`A10:146-152`).
- `RELIEF_SEED_SCAN_01:228-240`: height/tileblock hashes are **diagnostic**, not
  frozen baselines; height min/max is explicitly *not* a discriminator because
  donor cells clamp to ±2.964.

**DERIVED impact of the proposed change:**
- **Unchanged by construction:** no RNG consumption, so
  `same_seed_byte_identical` holds; stamp placement counts, `res`, `starts`,
  `tileblock` smoothing input and season index mapping are untouched; stub-based
  structural atoms are insulated; water cells (terrain==3) are skipped by the
  donor-grid branch (`game.gd:1037`), so `water` vs mask, `tileflow`,
  `sand_ring`, forest `patches`/`mean_sz`, `purity`/`clear` stay unchanged.
- **Changed by design:** `height[]` on stamped footprints; `terrain==5`
  (rock) via the collision pass (`:1243-1264`); `tileblock` via steep-cell
  remap; `meta.relief_grid.candidates/applied_cells/tables`. `cliff_ring`
  should stay ≥80 because steep cells are blocked by the same collision pass.
- **Real risk:** `reach` (relief adds `blocked` cells away from starts) and
  `selftest`/`uitest` walkability/build outcomes. Mitigation already in code:
  the `near_start` protect ring (`:951-966`) and water/shore skip (`:1037`)
  keep starts and coasts flat. If a gate regresses, **drop Tier 2 ids one at a
  time** (`g_hil4` first), keeping Tier 1; never lower a threshold.
- **No frozen hash baseline exists** to update; do not edit test fixtures to
  accommodate changed heights.

---

## 6. Acceptance criteria (for the follow-up ticket)

**Static (owner, before COORD gates):**
1. Backup `inbox/backup/game.gd.bak-<TICKET>` exists; only `game.gd` edited.
2. Each new grid const has exactly **80 floats** and matches §3.2 tables /
   §3.3 derived table; every new meta entry carries exact `scale/min/max/
   w/h/offset/lib` from `DPATTERN_01` §3 (notably `hil1.scale = 0.65`).
3. Tier-1 table verified bit-exactly against `pattern.lib:730045-730046`
   min/max before transcription; derivation evidence recorded; no donor binary
   in repo.
4. Id gate admits only donor-active names present in `RELIEF_GRID_META`;
   **no `ravine_medium` recipe, no `k_ravine_1` producer change, no new family**
   — `k_ravine_1` remains BLOCKED and unreachable.
5. Sampler, blend/clamp, footprint, collision code byte-identical; no new RNG
   draw; ledger `tables`/`source` updated and each substitute labelled
   **PORT APPROXIMATION**; `row_flip` stays `UNVERIFIED`.
6. No edit to shader, `world3d_terrain.gd`, `main.gd`, `pattern_gen.gd`, config,
   tests or `app/**`; no donor-parity claim anywhere in the ticket report.

**Runtime (COORD via G04 only, one Godot at a time):**
7. `--dump-map` for a seed that places a `hil1`/`g_hil4` stamp (and, after
   Tier 1, a `k_ravine_big_stone_1` stamp — e.g. from the seeded sweeps in
   `RELIEF_SEED_SCAN_01:184-224`) shows `meta.relief_grid.candidates > 0`,
   `applied_cells > 0`, new ids in `tables`, and changed decoded `height` and
   `tileblock` hashes vs the pre-change dump. **Do not** use height min/max as
   the pass criterion (clamped to ±2.964).
8. `t_map_variety` **5/5** with `same_seed_byte_identical` PASS — proves no RNG
   desync; `different_seeds_different_layout` still PASS.
9. `scan_map.py` ALL GREEN on a fresh seed set: `cliff>=80`, `tileflow>=99`,
   `reach` all seeds, water/patches/mean/purity/clear/sand_ring unchanged vs
   baseline. Record `rock%` increase as the intended signal.
10. `selftest 29/29`, `uitest 17/17`, `t_render_mode` 2D default intact,
    `assert_clean CLEAN`; structural atoms (`t_terrain_only`, `t_combo_all`,
    `t_season_overlay`) unchanged from baseline because they use stubs.
11. A fresh windowed 64² and real-map capture (G04) reviewed by a second agent
    (G05) for no new seam/dark band and visibly steeper ravine/hill silhouettes.
    **Visual parity with donor stays UNVERIFIED**; do not flip H-6
    (`FINAL_CHECKLIST:436-449`) without that evidence.

---

## 7. Risks / UNVERIFIED / BLOCKED

1. **UNVERIFIED:** donor engine blend (`Replace`/`ReplaceForWater`/`Smooth`,
   clamp/scale order, row flip) has no plaintext consumer
   (`DPATTERN_01:366-382,540-557`) — every new stamp stays **PORT APPROX**.
2. **UNVERIFIED:** no donor GPU A/B frame exists; whether the new ravine reads
   like the reference is unknown. **No parity claim.**
3. **BLOCKED (keep blocked):** `k_ravine_1` is donor-disabled and has no
   producer; unblocking it would change family coverage and still only yield a
   coarse 8×10 aid (`A05:213-236`; `RELIEF_02:68-84`). Do not add it.
4. **Derived-data risk (Tier 1):** the exact float-plane boundary ambiguity
   (±24–160 B, `DPATTERN_01:110-118,540-543`) makes offset 8225 authoritative
   only by the §7 verification; re-run the min/max gate before shipping the
   table.
5. **Gate risk:** added relief increases blocked cells and may flip `reach` or
   gameplay steps; staged rollout with per-id drop is the mitigation (§5).
6. **Scope risk:** adding all 29 decoded ids is *not* minimal and would broaden
   height changes without new visual classes; defer metadata-only ids.
7. **Not a synthetic field:** no RNG, dither, noise or invented constant is
   added (CHARTER §3, S-25-09); all numbers are donor-derived.

---

## 8. Summary

- B03's deferral is **correct** but incomplete: `DPATTERN_01` has no full `w×h`
  windows and only four 8×10 tables; "full derived tables for every decoded
  id" is not implementable from that report alone.
- **Resolution:** split into a derived-data ticket and a `game.gd` code ticket.
  The minimal faithful code subset is **Tier 1 = `k_ravine_big_stone_1`**
  (donor-active ravine, needs a prerequisite §7-derived 8×10 table), optionally
  plus **Tier 2 = `hil1` + `g_hil4`** (tables already in Appendix A). All are
  **PORT APPROX**.
- `k_ravine_1` stays **BLOCKED / donor-disabled**; its table remains dead, its
  producer absent, no `ravine_medium` recipe added.
- Existential shape is unchanged: 8×10 / 80-float const arrays + `RELIEF_GRID_META`
  entries + extended id gate + unchanged sampler/blend/collision + updated
  ledger. No new RNG, so `same_seed_byte_identical` is preserved by construction.
- Owner file `game.gd` is B03's — the code ticket is a **follow-up after B03**,
  disjoint from B04's `world3d_terrain.gd`, G04's runner role and the data
  extraction ticket; acceptance is §6 with gates re-run by COORD only.

*End of G07. One report written; no code, config, asset, test, shader, donor,
queue or git edit; no Godot process or runner job; no donor parity claim.*
