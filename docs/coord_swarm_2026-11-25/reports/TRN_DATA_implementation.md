---
id: TRN-DATA
task: "Donor tile diversity + full smoothing rules in the game simulation"
date: 2026-11-25
status: IMPLEMENTED__PARSE_AND_DETERMINISM_GREEN__FULL_SELFTEST_AMBER
scope: "ONE owned source file edited (variant3d/scripts/game.gd) + this report. No other file created or edited. Donor READ-ONLY; no donor file copied or executed."
owner_files:
  - variant3d/scripts/game.gd
  - docs/coord_swarm_2026-11-25/reports/TRN_DATA_implementation.md
backup: inbox/backup/game.gd.bak-TRNDATA (SHA-256 8649A865BE287C6FF61BEA4EF6E312C57FB20698DB95236054898D572DBF108C)
labels: [observed, derived, inferred, UNVERIFIED]
godot_access: "variant3d/tools/godot_runner.py only; no direct godot invocation"
visual_parity_claim: false
---

# TRN-DATA — donor smoothing table + tile diversity (implementation report)

## 0. What changed (one file)

| # | Location in `variant3d/scripts/game.gd` | Change | Donor evidence |
|---|---|---|---|
| 1 | new `const DONOR_SMOOTH_RULES` before `_load_terrain_structs()` | Full **118 active rule lists / 282 active `TileName:Prob` entries**, transcribed from RV-TRN-02 §7 machine-readable table (all 1,864 cfg lines parsed). Literal probabilities, including `0.64/0.0028/0.36` (SumProb 1.0028) and all eight `Prob=0` entries. 12 commented lists excluded; commented `//Prob = 0.36` alternatives NOT used. | `RV_TRN_02_smoothing_rules.md` §3.1/§3.4/§7; `gen/tilesmooth_scripts.cfg` SHA-256 `b82c…1b433` as fingerprinted there; DTRN-01 C10 |
| 2 | `_load_terrain_structs()` | Builds `tbl_smooth` from the embedded constant instead of `res://assets/terrain/structs/smooth_summer.json`. Winter names (`*_winter`) resolve via the donor 1:1 season alias to the existing 124-cell Summer preset index; Items 0–10 are appended first so a Winter row can never displace an equal-J Summer match. Output shape (`{"name","prob"}` dicts) is unchanged, so `_tb_pick` / `_tb_smooth_pair` were NOT refactored. | RV-TRN-02 §3.1 (Items 0–10 Summer, 11–21 Winter); `winter_variant.md:1.1/1.2` as already cited in `game.gd:1611-1615` |
| 3 | `_assign_tileblocks()` base pass, `terrain == 2` (forest) | Forest interior families now use donor **Item 1 J=5** verbatim: `grass7:0.25, test12:0.25, test13:0.25, test14:0.25` (one `RandomNumberGenerator.randf()` draw as before). The former `grass_ground1/3` pair are *transition* tiles and were the single largest histogram cause (RC1/P1). All names and probabilities are donor-authored; no luminance/noise/dither added. | RV-TRN-02 §7 row Item 1 J=5 (`cfg:171`); DTRN-01 M10 / PLAN S-25-09 forbid synthetic noise |
| 4 | `_assign_tileblocks()` pass order | `SmoothTileMap` now runs **after** the donor bitmap detail pass, so transition rules consume the final tile field before UV2 is built. Three passes, horizontal then vertical, unchanged. | DTRN-01 §4 pseudocode (TextureMap → bitmap base → SmoothTiles); RV-TRN-02 §4.4 (`smoothtiles.inc:191-237`); V3D-02 F3 "re-run compatibility smoothing"; GAPS §2 "parse real cfg rules before UV2" |
| 5 | road assignment | **No code change** — existing `ground1 0.5 / test2 0.375 / test3 0.125` from two sequential draws already matches RV-TRN-02 §5.4 (`texturemap.inc:627,633`) and supersedes the old 0.5/0.25/0.25 claim. | RV-TRN-02 §5.4 / §6 correction 1 |

Unchanged on purpose: `_tb_pick` (roulette over SumProb, Prob=0 unselectable), `_tb_smooth_pair` (active-list index J, minimal `|J1-J2|`, `Δ=1` compatible unless BOTH entries Prob=0, `Δ=2` midpoint pick, `Δ>2` one-step pull, no shared list ⇒ no change), `_smooth_tilemap` (3 passes, horizontal sweep then vertical), `_apply_shore_cliffs`, `_stamp_forest_borders`, mine-apron authority, winter name export, all simulation/gameplay code, `Data.*`, and every other file.

## 1. Rule coverage (exact inventory embedded)

| Quantity | Count | Notes |
|---|---:|---|
| Active rule lists embedded | **118 / 118** | Every row of RV-TRN-02 §7 is present; each carries its `Item`, `J`, `cfg:` line and `SumProb` in a trailing comment for audit |
| Active `TileName:Prob` entries | **282 / 282** | Verified by regex count over the embedded constant (script output: `118 lists, 282 entries`) |
| Items represented | **20** | Items 0–9 and 11–20. Items **10 and 21 have zero active lists** (all four of their lists are commented at RV-TRN-02 §3.4 `:882/890/902/914` and `:1812/1820/1832/1844`), so they are intentionally absent; the constant still represents the donor's full 22-Item structure |
| Commented lists excluded | **12** | Per RV-TRN-02 §3.1; none occupy a J slot |
| `Prob=0` entries preserved | **8** | Items 0/11 J=2 all-zero hard separators + `test8` position-only in Items 7/18 J=0 (RV-TRN-02 §3.5) |
| Distinct tile names | **86** (43 Summer + 43 `*_winter`) | After `_winter` alias resolution all names map to an existing `presets_summer.json` index (script output: `missing presets []`) |
| Authored anomalies preserved | yes | `grass_ground1=0.64 / grass_ground2=0.0028 / grass_ground3=0.36` (SumProb 1.0028) in 6 lists; `0.36/0.28/0.36` (SumProb 1.0) in 2 lists. Nothing normalised. |

No probability was invented. The only non-donor selection is the *forest base family* being taken from one authored donor list (Item 1 J=5) — the donor base assignment for forest grid-code 2 is not readable, so that reuse is a labelled port choice, not a claimed donor constant.

## 2. Before → after

### Measured baseline (external, before this ticket)
`FIXTERRAIN_visual_quality.md:52-62` / `V3D_02` P1 / `GAPS.md` §2, from `app/shots/g32_dump.json`, seed 20261113, 320² = 102,400 cells:

- top-5 ids = **73.0%** (`grass_ground1` 28,535; `grass1` 15,993; `grass_ground3` 15,962; `test8` 7,667; `test7` 6,691)
- `test7+test8` = 14,358 cells = **14.0%** (the report's "test7/8/9" label); `test9` adds 2,229 cells ⇒ combined 16.2%
- 31 distinct ids, range 0..85.

### After (this implementation)
No live tileblock histogram dump exists for the variant build (there is no histogram probe in `variant3d/tests/` and creating one is outside this ticket's one-file ownership). An **offline replay of the exact implemented pipeline** over the same dump's `terrain`/`height`/ore nodes and the donor `tile_low/highground` R→`tex` values gave (Python RNG substituted for Godot's — see UNVERIFIED):

| Metric | Baseline replay | Implemented replay |
|---|---:|---:|
| top-5 share | 72.68% | **58.52%** |
| `test7+test8` | 14,982 (14.63%) | 15,243 (14.89%) |
| `test9` | 2,341 (2.29%) | **855 (0.84%)** |
| `test7/8/9` combined | 16.92% | **15.72%** |
| distinct ids | 31 | **32** |

New top five: `grass1` 15.28%, `test14` 11.82%, `test12` 11.62%, `test13` 10.29%, `grass7` 9.51%. The `grass_ground1`/`grass_ground3` 43%-duo is gone from the top five; `test9` (a midpoint-inserted transition from the old grass chain) drops ~2.7×. The `test7+test8` share itself does **not** fall below 14%: the donor bitmaps encode those indices directly (`tile_lowground.bmp` R=156/158 ⇒ tex 78/79 ≈ 30% of low-ground pixels; confirmed by raw donor BMP read), so reducing them further would require replacing donor bitmap data — explicitly forbidden by this ticket (DTRN-01 M10 / PLAN S-25-09). **Exact live-build histogram: UNVERIFIED.**

## 3. Determinism and behaviour isolation

- Same seed → same tileblock bytes: the registered `t_map_variety` check `same_seed_byte_identical` passed twice-generated summary (126,155 bytes each) with `tileblock` included in the summary (`t_map_variety.gd:69-89`). Job `trndata-mapvariety-rerun` (ticket 423), 5/5 checks PASS, `SCRIPT ERROR == 0`, stderr contained only a pre-existing `T-MINES-FIX` warning.
- RNG isolation: the forest-base pool consumes the **same single `r` draw** as the old three-way `grass_ground` branch; `_smooth_tilemap` uses its own `brng` seeded `Data.RANDOM_SEED + 7`. No simulation RNG stream, `rng` draw, `terrain`, `blocked`, resource/start placement or gameplay field was changed.
- Tileblock bytes for a given seed **do change** by design (diversity + donor-order smoothing). "Byte-identical for unchanged seeds" is interpreted as *reproducible per seed*, not *identical to the pre-ticket bytes*; the two goals in F3 cannot both hold literally. Flagged as an open question.

## 4. Validation (variant runner only)

| Job (id) | Ticket | Command / purpose | Result |
|---|---:|---|---|
| `trndata-smoke` | 406 | `--headless --path variant3d --check-only --script res://scripts/game.gd` | **ok** (wait 236.76 s, run 6.40 s), stdout = Godot banner, **stderr 0 bytes, `SCRIPT ERROR == 0`** |
| `trndata-selftest` | 411 | `--headless --path variant3d -- --self-test variant3d/selftest.json` | runner **failed**; 28/29 steps, only `build` false (`house built in 3.1 s of build time` detail string unchanged from baseline). stderr showed missing `res://.godot/imported/mill_rotor.png-…ctex` from `world3d_entities.gd:1349` and ObjectDB leaks. The source PNG exists on disk; `.godot/imported` cache entry was absent → concurrent-builder import race. `tileblock` is read only by the terrain renderer (`world3d_terrain.gd`), never by building placement/pathfinding, so this is a **foreign transient**, not this ticket's change. Not reverted. |
| `trndata-mapvariety` | 418 | registered `res://tests/t_map_variety.gd` | runner exit 1 in 7.71 s with empty stderr and **no result-JSON update** — the script did not execute (transient). Re-run below. |
| `trndata-mapvariety-rerun` | 423 | same command, unique id | **ok** (wait 97.97 s, run 176.84 s), `variant3d/tests/results/t_map_variety.json` **5/5 PASS**, `SCRIPT ERROR == 0`, stderr only a pre-existing `T-MINES-FIX` warning at `pattern_gen.gd:676`. Includes `same_seed_byte_identical`, `different_seeds_different_layout`, water/size/resource reachability. |

No test was weakened, no gate/ladder run, no direct `godot` call, no other worker's file touched.

## 5. UNVERIFIED / honest limitations

- **Live histogram after the change** — not measured in-engine; offline replay only (Python RNG, donor BMP bytes read directly). No GPU A/B exists; visual parity not claimed (CHARTER / V3D-02 F0).
- **Donor loop nesting** — RV-TRN-02 §4.4 says horizontal sweep is `i`(x)-outer, `j`(y)-inner; the port uses y-outer/x-inner (and x-outer/y-inner for vertical). I left the port nesting in place: an offline probe of donor nesting homogenised this fixture to top-5 ≈ 95%, the opposite of F3. This is a **PORT APPROXIMATION**, not donor parity; resolving it needs a donor A/B.
- **Runtime activity of the donor `.inc` scripts** — every code line is `;`-commented in the shipped donor build (RV-TRN-02 §4.6); the rule bytes and authored algorithm are real, but "the donor game executes this" is UNVERIFIED.
- **`RandomExt` semantics / local-float zero-init** — RV-TRN-02 §8 Q1/Q2; the port's `brng.randf()` starts each float accumulator at 0, which is the only consistent reading.
- **Forest base selection** — donor base tile for forest grid-code 2 is not readable; reusing Item 1 J=5 families is donor-data-only, labelled PORT APPROXIMATION.
- **Selftest 28/29** — root cause attributed to a foreign `.godot` import race, not proven by a clean re-run (queue budget / concurrent edits). Report as AMBER, do not mark green.

## 6. Open questions

1. Should a new owned test (separate ticket) dump the live 320² tileblock histogram so F3's exact <73% / <14% thresholds can be asserted in-engine rather than offline?
2. Is the small residual `test7+test8` share (≈14.9% offline) acceptable given donor bitmaps encode those ids, or must F3 be revised to measure `test7/8/9` combined (now ≈15.7% offline, down from 16.9%)?
3. Should TRN-FACE or a follow-up revisit the donor loop-nesting deviation once a donor GPU A/B exists?
4. The `full selftest` build step should be re-run by QA after other builders' in-flight edits settle to confirm 29/29.

## 7. Scope statement

Files edited by this ticket: `variant3d/scripts/game.gd` and this report. Backup created at `inbox/backup/game.gd.bak-TRNDATA`. No config, menu, shader, world3d_terrain, entities, HUD, camera, test, manifest, asset or donor file was created or modified by this agent. Foreign transient changes in other files were observed and deliberately left untouched.
