---
id: RELIEF-SEED-SCAN-01
title: "Offline donor/port placement replay finds a 64x64 skirmish seed that places plt2 (seed 20261150) — runtime dump UNVERIFIED"
agent: "RELIEF-SEED-SCAN-01 (donor/port analysis worker, coord swarm 2026-11-25)"
date: 2026-11-25
status: FOUND_OFFLINE__RUNTIME_UNVERIFIED__NO_GODOT_JOB__NO_PARITY_CLAIM
scope: "One new file only: this report. Game code READ-ONLY; no repo source/asset/config/test/shader/donor/git edit; no Godot process; no runner job. Scratch Python scripts were written outside the repo, under %LOCALAPPDATA%\\Temp\\opencode\\."
output: docs/coord_swarm_2026-11-25/reports/RELIEF_SEED_SCAN_01.md
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, BLOCKED]
label_key: "observed = literal source/donor/dump bytes read this pass | derived = arithmetic or deterministic replay over observed bytes | inferred = strong but indirect attribution | UNVERIFIED = not measured this pass | BLOCKED = no instrument exists to measure"
parity_guard: "PORT APPROXIMATION — donor engine blend (Replace/Smooth/clamp order) UNVERIFIED; no donor GPU A/B frame exists; NO DONOR PARITY CLAIM."
verdict: "SEED 20261150 PREDICTED TO EMIT relief_stamps=[{plt2,cx:54,cy:33}] AND meta.relief_grid.applied_cells=443; OFFLINE REPLAY VALIDATED 8/8 NON-MINE STAMP COUNTS AND MASK PICK AGAINST THE MEASURED SEED-20261113 DUMP; RUNTIME DUMP NOT MEASURED"
found:
  seed: 20261150
  relief_tier: plains
  map: "64x64 (fixture overlay), biome summer, richness med, render_mode 3d"
  expected_relief_stamps: [{"name": "plt2", "cx": 54, "cy": 33}]
  expected_applied_cells: 443
---

# RELIEF-SEED-SCAN-01 — find a seed that actually places `plt2`

> [!IMPORTANT]
> Donor is truth; donor files were read in place only (bytes → latin-1), never
> copied, run or edited. Every number produced by the offline replay is a
> **derived** consequence of observed source bytes and Godot engine source,
> cross-checked against the measured seed-20261113 dump. **No Godot process was
> launched, no runner job was submitted and no game code was edited.** A runtime
> dump for the found seed does not exist, so its marker/applied-cell values are
> **UNVERIFIED predictions**, not measurements. No donor parity claim.

---

## 1. Sources

### 1.1 Reports / artifacts (observed)

| # | Source | Fact used |
|---:|---|---|
| S1 | `docs/.../reports/RELIEF_02_stamp_marker.md:49-84,105-117,188-205` | Producer emits `{"name","cx","cy"}` from `game.pattern_stamps`, filtered to `plt2`/`k_ravine_1`; `k_ravine_1` BLOCKED; open Q1 asks which seed places `plt2`. |
| S2 | `docs/.../reports/RELIEF_LIVE_FIX_01.md:218-240,244-258,296-300` | Live grid wired in `game.gd`, but seed 20261113 has `relief_stamps: []`, `applied_cells=0`; seed sweep listed as open question. |
| S3 | `docs/.../reports/QA_RELIEF_FIX_01.md:91-111,133-142` | Measured dump comparison, seed-20261113 blocker reproduced; `height` min/max `−1.100000023841858 / +2.9639999866485596`, SHA of decoded height `12750f48bd17e919`. |
| S4 | `docs/.../reports/DPATTERN_01_relief_grids.md:142,154,172-178,302-346,595-626` | Donor ids, sizes, `Freq`, family divisors, disabled `ravine_medium`, Appendix A coarse tables. |
| S5 | `%LOCALAPPDATA%\Temp\opencode\relieflive01_dump.json` (54,589 B, measured) | Ground truth for anchor: `seed=20261113`, 64×64, `meta.stamp_counts`, `meta.mask.file`, `starts`, base64 `terrain`/`height`; `relief_stamps: []`. |
| S6 | `variant3d/tests/fixtures/small_map_64.json`, `small_map_128.json` | Fixture overlay pattern: only `gameplay.map_*_tiles`/`random_seed` change; all else inherited. |
| S7 | `variant3d/.godot_queue/results/00000551.json:1-22` | Exact shape of the prior single `--dump-map` job (`relieflive01-dump`, quoted paths, `--timeout 300`). |

### 1.2 Port source (observed, read-only)

| # | Source | Fact used |
|---:|---|---|
| P1 | `variant3d/scripts/pattern_gen.gd:19-36,60-70,89-151,158-190,206-230,232-277,407-472,474-549` | Relief presets, recipes, RNG seed, weighted `pick`, all shared-RNG passes, relief own-grid placement. |
| P2 | `variant3d/scripts/game.gd:354-363,403-411,1112-1148,1153-1172,1207-1209,937-1110,1216-1237,2652-2668` | `setup()` order; `C3PatternGen.build()` called with **2** mask starts and pre-collision `terrain`; donor-grid gate and ledger; appended starts happen later (`setup_spawns`); start-protect radius. |
| P3 | `variant3d/scripts/main.gd:755-812` | `_dump_map()` producer; `relief_stamps` appended **only if** `cfg.feature_terrain_relief_stamps()`. |
| P4 | `variant3d/scripts/config.gd:59,448-449`; `variant3d/config.json` `features.terrain.relief_stamps = true` | Marker flag is on in the shipped config, so a dump contains the key (as S5 shows). |
| P5 | `variant3d/scripts/data.gd:220,230,234-235,246-247` | Defaults `PLAYER_COUNT=2`, `BIOME=summer`, `RICHNESS=med`, `RELIEF=plains`. |
| P6 | `variant3d/assets/terrain/patterns/donor_patterns.json` (`families.plateau`, `patterns.plt2`) | `plateau = [plt1,plt2,plt3,plt4_fixed,plt5]` all weight `1.0` → `plt2` is 1 of 5 equally likely picks; `plt2` has 733 footprint cells. |
| P7 | `variant3d/assets/terrain/masks/manifest.json`; `variant3d/scripts/mapgen.gd:51-61,96-117,145-238` | Mask pick uses an independent RNG seeded `(seed ^ type.hash()) + 104729`; starts come from the mask only. |
| P8 | `variant3d/scripts/godot_runner.py` (present) | Runner entry point exists for the optional probe command in §6. |

### 1.3 Donor plaintext (read in place, observed)

| # | Source | Fact used |
|---:|---|---|
| D1 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:540-576` | `ravine_medium`: `k_ravine_1…9`, `Freq = 1` each. |
| D2 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:580-602` | `plateau`: `plt1` `:584`, **`plt2` `:588`**, `plt3` `:592`, `plt4_fixed` `:596`, `plt5` `:600`, each `Freq = 1`. |
| D3 | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1757-1765` | Family divisors `plateau plt/3`, `plateau_big plt/3`, `plain_huge pln_huge`, `ravine_big plt/1.5`, `hills_* hil/2`; `ravine_medium` is `//`-disabled at `:1760`. |

### 1.4 Godot engine source (fetched from GitHub, observed external)

`core/math/random_pcg.h`, `core/math/random_pcg.cpp`, `thirdparty/misc/pcg.h/.cpp`,
`core/math/random_number_generator.h`, `core/string/ustring.cpp` (4.2-stable;
`master` checked for `randf()` — identical). Gives exact PCG-XSH-RR state
update, `pcg32_srandom_r`, bounded rejection sampling, the two-draw CLZ-based
`randf()`, `randi_range` → bounded PCG, and djb2 `String.hash()`. **Inference:**
the runner banner in prior reports says Godot 4.7.2; the engine version actually
used by the queue worker is **UNVERIFIED**, but the anchor replay matches its
output (§4), which is empirical evidence the same RNG is in force.

---

## 2. Placement analysis — which seeds can place `plt2`

1. **Relief tier / option.** `Data.RELIEF` defaults to `"plains"` (P5). The
   relevant preset row is `RELIEF_PRESETS["plains"] = {plt:1e-5, mnt:2e-5,
   hil:7.5e-5}` (P1:19-23). `RELIEF_RECIPES` (P1:27-36) contains **three**
   plateau-family recipes: `plateau_big` (÷3), `plateau` (÷3) and
   `plateau_small` (÷3), plus `plain_huge` (÷12) and `ravine_big` (÷1.5).
   Only the family literally named `plateau` can emit the donor ids `plt1…
   plt5`; `plateau_big`/`plateau_small` use different families, and
   `ravine_big` uses `k_ravine_big_stone_*`. **Therefore the seed search must
   target the `plateau` recipe** (P1:32), not the mere total plateau stamp
   count reported as `meta.stamp_counts.plateau = 2`.
2. **Count on a 64² map.** `needed = int(W·H·(plt/3))` clamped to ≥1
   (P1:542-549). With `W·H = 4096`, `4096·(1e-5/3) = 0.0136 → 0 → 1`. So
   exactly **one** `pick("plateau")` draw is made per seed, and `plt2` has
   probability `1/5` *if the footprint passes the relief mask*. On the shipped
   320² map the same recipe still gets `needed = 1` (`102400·3.33e-6 = 0.34`),
   so the tier changes little at this level: `hills` gives `plt=2e-5` and
   `mountains` `plt=5.5e-5` (still 1 on 64², 1 on 320² for `hills`, 1 for
   `mountains`). **Scan range chosen: `plains`, 64², seeds near the known
   fixture seed** — first hit at `20261150` (§5).
3. **Why the name is seed-dependent.** `pick()` (P1:132-151) computes
   `r = rng.randf() * 5` and walks the equal weights, so `plt2` is selected
   exactly when `1 ≤ r < 2`, i.e. `0.2 ≤ randf() < 0.4`. The `randf()` at that
   moment is not the first draw: the shared `rng` is seeded at P1:69-70 with
   `(seed ^ 0x5F356495) + (W·31 + H)` and consumed, in order, by the tile pass
   (P1:209-230), the mine **count** replay (P1:251-277), near-start stone/forest
   (P1:407-415), the forest recipes (P1:435-461), the six `recipes` (P1:462-472)
   and only then the eight relief recipes (P1:541-549). A change of seed
   reshuffles all of these, so brute-force sweeping is the practical method.
4. **Two port-specific traps reproduced faithfully.**
   - The mine replay calls `can_stand`/`stand` **without** a mask argument
     (P1:275-276); the lambdas' default `mask = null` resolves to the *shared*
     `occupied` grid, so `mine_occ` (P1:238-249) is dead code. Using `mine_occ`
     breaks the stream (it changed 5 of 8 predicted counts in this scan).
   - At build time `map_starts` holds only the **2** mask starts; the 2 extra
     corner starts are appended later by `setup_spawns()` → `_ensure_start_slots()`
     (P2:354-363,462-463,2652-2668). The measured dump's first two `starts`
     entries are exactly the mask pair, confirming no water-snap moved them.
5. **Donor caveat.** Donor `plateau` has five equal-`Freq` members (D2), but
   the port's placement is engine-side (`dogenerate.inc`, native
   `StandPattern`) and its exact footprint/blend is **UNVERIFIED** (S4 §5.2).
   This search is for a **port** seed that exercises the port's own `plt2`
   branch; it is not a donor seed equivalence claim.

---

## 3. Scan method (offline, pure Python, read-only)

Scratch scripts (outside the repo, no game file touched):

```
%LOCALAPPDATA%\Temp\opencode\reliefseedscan01_scan.py      # exact PCG + build() replay
%LOCALAPPDATA%\Temp\opencode\reliefseedscan01_variants.py  # RNG-flavour discrimination
%LOCALAPPDATA%\Temp\opencode\reliefseedscan01_sweep.py     # seed sweep + mask filter
%LOCALAPPDATA%\Temp\opencode\reliefseedscan01_predict.py   # applied_cells prediction
```

1. **Exact RNG.** Implemented Godot `RandomPCG`: seed
   `pcg32_srandom_r(state=0, inc=(PCG_DEFAULT_INC<<1)|1)`, XSH-RR output,
   `pcg32_boundedrand_r` rejection, `randf() = ldexp(f32(rand()|0x80000001),
   -32-clz32(first rand))` (two draws), `randi_range = bounded+min`.
2. **Exact placement.** Translated `pattern_gen.gd:60-549` line-for-line,
   including `gd_round` (half away from zero), `int()` truncation, `TAU`,
   elliptical keep-clears, tile step `max(6, round(60·0.4)) = 24`, per-pass
   masks and the 512-attempt relief rejection loop.
3. **Anchor inputs.** `terrain` (4,096 bytes) and the first two `starts` were
   decoded verbatim from S5. They are valid for any seed that picks the same
   mask, because `mapgen.gd` derives height/starts from the mask alone and the
   game domes skip water/shore cells (P2:1164-1172).
4. **Mask filter.** Reproduced `String.hash()` (djb2) for `"mediterranean"`
   (`2681419844`) and `mapgen.gd:59-61` pick:
   `PCG((seed ^ 2681419844) + 104729).rand() % 8 == 7` selects
   `mediterranean/7pl_mask_mediterranean_10_gauss.png` — the mask recorded in
   S5 for seed 20261113 (index 7 of 8). Only such seeds were swept.
5. **Sweep.** Seeds `20261100…20261200`: 14 share the anchor mask; the
   `plateau` family pick distribution was `plt1:4, plt2:3, plt4_fixed:4,
   plt5:1` (one seed placed no `plateau` stamp). Three seeds placed `plt2`.
6. **No Godot.** No `--check-only`, no `--dump-map`, no gate, no ladder.

---

## 4. Validation of the offline replay (anchor seed 20261113)

| Check | Offline prediction | Measured (S5) | Grade |
|---|---|---|---|
| Mask index | 7 → `7pl_mask_mediterranean_10_gauss.png` | same file in `meta.mask.file` | **derived = observed** |
| `stamp_counts` (non-mine) | `decor 1, forest 10, hill 4, mountain 1, plain 1, plateau 2, stone 3, tile 4` | identical | **8/8 exact match** |
| Mine count | not modelled (final pass uses separate `mine_rng`, P1:625-718) | 11 | **UNVERIFIED** by this replay |
| `relief_stamps` | `[]` | `[]` | **match** |
| `plateau` family name | `plt5` at (53,50) | not in dump schema | **inferred** (count parity only) |
| `meta.relief_grid.applied_cells` | 0 (no `plt2`/`k_ravine_1`) | 0 | **match** |

The `mine` sub-pass was deliberately left unimplemented: it consumes a
**separate** RNG (P1:296-297) and relocates already-counted stamps, so it cannot
change the shared stream that decides the `plt2` pick. All eight shared-stream
count buckets matched, which is the strongest available evidence that the
replay reproduces the engine's draws without running it.

---

## 5. FOUND — exact seed and options (offline prediction)

**Primary recommendation: `seed = 20261150`.**

Options (all other config inherited from `variant3d/config.json`; relief tier
`plains` is the `data.gd:235` default):

```
gameplay.random_seed      = 20261150
gameplay.map_width_tiles  = 64
gameplay.map_height_tiles = 64
gameplay.render_mode      = 3d
Data.RELIEF = plains ; Data.BIOME = summer ; Data.RICHNESS = med
features.terrain.relief_stamps = true   (shipped config.json — already on)
```

Expected producer marker (P3:781-807), **derived / UNVERIFIED at runtime**:

```json
"relief_stamps": [{"name": "plt2", "cx": 54, "cy": 33}]
```

Expected audit ledger (P2:1101-1110): `candidates: 1`,
`applied_cells: 443` (exact count of bbox cells that are not water/shore and
outside the 9-tile start-protect ring; bbox from `ex=8, ey=11` at scale
`64/160`, so `x∈[45,63], y∈[21,45]`, with 416 protected cells and water cells
excluded). `tables: ["k_ravine_1","plt2"]`, `row_flip: "UNVERIFIED"`.

Alternative seeds from the same 64²/`plains` sweep (same marker shape, smaller
expected applied-cell counts):

| seed | expected `relief_stamps` | expected `applied_cells` |
|---:|---|---:|
| **20261150** | `[{"name":"plt2","cx":54,"cy":33}]` | **443** |
| 20261168 | `[{"name":"plt2","cx":20,"cy":52}]` | 425 |
| 20261181 | `[{"name":"plt2","cx":8,"cy":41}]` | 425 |

For seed 20261150 the replay also predicts non-mine `stamp_counts`:
`decor 1, forest 10, hill 2, mountain 1, plain 1, plateau 2, stone 4, tile 4`
(mine not modelled, **UNVERIFIED**). Other relief stamps predicted:
`g_mnt_1` at (11,10), `f_plt_mid_1` at (26,54), `k_plain_10` at (49,54).

### Discriminating dump fields to measure

| Field | Anchor (measured) | Expected for 20261150 | Why discriminating |
|---|---|---|---|
| `relief_stamps` | `[]` | `[{"name":"plt2","cx":54,"cy":33}]` | Direct producer marker; primary gate. |
| `meta.relief_grid.candidates` | 0 | 1 | Id gate fired (P2:977-984). |
| `meta.relief_grid.applied_cells` | 0 | **443** | Donor-grid branch actually wrote heights (P2:1039-1055). |
| SHA-256 of decoded `height` | `12750f48bd17e919` | must differ | Cell-level proof of a height change. |
| SHA-256 of decoded `tileblock` / `blocked` | `21f77d2985d7f8fc` (tileblock) | must differ | Relief runs before collision (P2:1209,1241-1262), so steep cells change rock/block counts. |
| `height` min / max | `−1.100000023841858 / +2.9639999866485596` | **likely unchanged** | Water floor untouched; donor cells clamp to the port `±2.964` ceiling (P2:1052,1228). **Do not use min/max alone as the pass criterion** — use `applied_cells` plus the hashes. |

**Ranking:** `relief_stamps` → `candidates` → `applied_cells` → decoded
`height`/`tileblock` hashes. Height min/max is explicitly *not* expected to be
a discriminator here (honest correction to the "height min/max vs baseline"
framing in the task).

---

## 6. Exact optional probe command (NOT executed by this worker)

No runner job was submitted (offline derivation sufficed, per the mandate). If
an owner wants the single controlled runtime confirmation, use exactly one job
with id **`reliefseedscan01-dump`**. First create the temp fixture (outside the
repo) with this content:

```json
{
  "_readme": ["RELIEF-SEED-SCAN-01: 64x64, seed 20261150; all other config inherited from res://config.json"],
  "gameplay": {
    "render_mode": "3d",
    "random_seed": 20261150,
    "map_width_tiles": 64,
    "map_height_tiles": 64
  }
}
```

Then one command, quoted paths, from the repo root (Windows `python`, not
`python3`), matching job 551's shape:

```
python variant3d\tools\godot_runner.py run --id reliefseedscan01-dump --timeout 300 --max-wait 1800 -- --headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefseedscan01_seed_20261150.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefseedscan01_dump.json"
```

Compare the resulting dump with S5 using §5's table. Report the job ticket,
`status`, `exit`, stderr byte count (`SCRIPT ERROR` check) and the measured
values verbatim; do not upgrade this report's predictions without that dump.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Does the actual runner engine (banner 4.7.2) use the same PCG/`randf()` as
   the 4.2-stable/master sources fetched here? The anchor's 8/8 count match is
   strong indirect evidence, but no `--dump-map` for 20261150 exists — **the
   seed is an UNVERIFIED prediction**.
2. Will `applied_cells` be exactly 443 at runtime? The count assumes the
   dump's post-collision `terrain` has the same 3/4 cells as the pre-collision
   terrain passed to `build()` (water/shore are unchanged by domes and
   collision, so this is **derived**, not measured).
3. Will decoded `height` min/max truly stay at
   `−1.100000023841858 / +2.9639999866485596`, or will a donor-grid cell land
   below the water floor / above the cap? Predicted unchanged; **UNVERIFIED**.
4. Which relief tier (`plains`/`hills`/`mountains`) or full 320² map the
   coordinator wants: this scan is 64²/`plains` only. The same seed at 320²
   will pick a different mask and a different RNG stream — **UNVERIFIED**.
5. Does `k_ravine_1` remain unreachable (S1 §5, D3 `:1760`)? Yes from read-only
   evidence — **BLOCKED**; this scan did not attempt to unblock it.
6. Donor parity of the `plt2` silhouette, row flip and blend: coarse
   8×10 debug-aid tables only; **no donor GPU A/B; NO PARITY CLAIM**.
7. Does `stats.relief_grid.applied` (consumer-side, `world3d_terrain.gd`) ever
   get measured? That statistic is not in the dump schema — **BLOCKED**.

---

## 8. Summary

A read-only offline replay of the port's `pattern_gen.gd` placement with Godot's
exact PCG32 RNG was validated against the measured seed-20261113 dump: mask
pick, `relief_stamps: []`, `applied_cells: 0` and **all eight** non-mine
`stamp_counts` buckets matched exactly. Sweeping seeds `20261100…20261200`
restricted to that same terrain mask (14 candidates) found three that place
the donor `plateau` pattern `plt2`. Recommended:

- **`seed = 20261150`, relief tier `plains`, 64×64, summer/med, feature flag on**.
- Expected dump marker: **`relief_stamps = [{"name":"plt2","cx":54,"cy":33}]`**.
- Expected ledger: **`candidates: 1`, `applied_cells: 443`**.
- Discriminators: marker presence, `candidates`, `applied_cells`, decoded
  `height`/`tileblock` SHA-256; **not** height min/max (expected unchanged).

No Godot process was run, no runner job was submitted, no game/asset/config/
test/donor file was edited and no donor binary was copied. The found seed and
its dump values are **derived predictions, UNVERIFIED at runtime**; the
single-job probe command is supplied in §6 for an owner to confirm. Donor
engine blend and GPU appearance remain **UNVERIFIED** — **no parity claim**.

*End of RELIEF-SEED-SCAN-01. One report written; game code READ-ONLY.*
