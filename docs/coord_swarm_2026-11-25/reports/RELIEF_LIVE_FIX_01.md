---
id: RELIEF-LIVE-FIX-01
title: "LIVE skirmish height now consumes donor-derived relief grids (plt2 / k_ravine_1), gated by donor stamp id"
agent: "RELIEF-LIVE-FIX-01 (implementation builder, coord swarm 2026-11-25)"
date: 2026-11-25
status: IMPLEMENTED__PARSE_AND_DUMP_GREEN__RUNTIME_EXERCISE_BLOCKED_BY_FIXTURE__NO_PARITY_CLAIM
scope: "One owned source file edited (variant3d/scripts/game.gd) + this report. No data file needed; both coarse tables are embedded as labelled constants. Donor READ-ONLY."
owner_files:
  - variant3d/scripts/game.gd
  - docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_FIX_01.md
backup: "inbox/backup/game.gd.bak-RELIEFLIVEFIX (236,991 B; SHA-256 BB2265C71A1A189C600513631034934DADD1B535DCD3D05EC4391DB3525888D4)"
jobs: "relieflive01-smoke = ticket 550 (ok); relieflive01-dump = ticket 551 (ok); variable-runner only; no direct godot"
labels: [observed, derived, PORT APPROXIMATION, UNVERIFIED, BLOCKED (runtime exercise)]
parity_guard: "PORT APPROXIMATION — donor engine blend UNVERIFIED; no donor GPU A/B exists; no parity claim."
height_truth: "Reconciled with HEIGHT_GEN_DEEP_01: disabled R-code multipliers NOT used as donor truth; no donor clamp asserted; exact mapgen.gd amplitude fix is a follow-up ticket (§8 Q7)."
---

# RELIEF-LIVE-FIX-01 — donor relief grids in the LIVE height path

> [!IMPORTANT]
> Donor is truth. Every number in the two tables below is a **derived block-mean**
> of a decoded donor float32 height window (DPATTERN-01 Appendix A1/A2). No
> donor binary was copied, run or edited. The sculpt blend remains the labelled
> **PORT APPROXIMATION** of DPATTERN-01 §5.2; the donor engine's `Replace` /
> `Smooth` / clamp order has no plaintext consumer and is **UNVERIFIED**.
> **No synthetic noise, no raised amplitude, no invented hill.** Tile assignment,
> smoothing rules, blocking, start positions and RNG consumption are untouched.

---

## 0. Mandate and boundary

RELIEF-LIVE-DIAG-01 established that the config flag gates only `main.gd:788-803`
(the `--dump-map` key) and that live boot shapes `game.height` in
`game.gd:_shape_stamp_relief()` with analytic radial/taper profiles over donor
footprints; no donor float32 grid ever reached live height. This ticket wires a
donor-derived grid into **that function only**, for stamps whose donor id is a
decoded grid, and reconciles the two **live** clamps around it.

Exclusive ownership honoured: `variant3d/scripts/game.gd`, optionally a new
`variant3d/scripts/data/relief_grids.json` (not needed — the two 80-float tables
are embedded as constants), and this report. `pattern_gen.gd`,
`world3d_terrain.gd`, tests, config, shaders, fixtures and `app/**` were read
only. NATION-SPAWN-IMPL-01 is terminated: `_spawn_sid()` was preserved
byte-identically (verified by SHA-256 of the function body, current == backup).
TRN-DATA smoothing (`DONOR_SMOOTH_RULES`, `tbl_smooth`, `_tb_smooth_pair`,
`_smooth_tilemap`) is untouched — it appears nowhere in the diff.

---

## 1. Evidence read (all read-only)

| Source | Fact used |
|---|---|
| `RELIEF_LIVE_DIAG_01.md:121-165,183-209,344-360` | Sole live height writer is `game.gd:_shape_stamp_relief()`; two clamps at `:993` and `:1099-1109`; owner-file recommendation is exactly this function. |
| `DPATTERN_01_relief_grids.md:101-124` | `.pattern` = `w*h` u8 grid + row-major `w*h` float32 height window; exact plane boundary and row→map sign **UNVERIFIED**. |
| `DPATTERN_01:142` | `k_ravine_1` 46×63, offset 2866, `HeightFieldScale=1`, min `−2.963627576828003`, max `+3.139820098876953` = `pattern.lib:549585-549586`; `Smooth=False` `:549572`. |
| `DPATTERN_01:154,244-249` | `plt2` 42×55, offset 2266, scale 1, min `−0.07325489819049835`, max `+3.6134116649627686` = `pattern.lib:6805-6806`; broad flat cap ≈3.2–3.5, not a Gaussian. |
| `DPATTERN_01:348-382` | Sculpt config exists only in `pattern.lib` (9,520 hits, zero script consumers); engine blend **UNVERIFIED**; safe port form `h=clamp(h+grid*scale+offset, Min, Max)`. |
| `DPATTERN_01:595-626` (Appendix A1/A2) | The two 8×10 block-mean tables transcribed verbatim; `:599-600` labels them "debug/preview aids only — stamp from the full grid". |
| `DTRN_02_donor_terrain_geometry.md:97,102-106,310-318,362-388` | Baked `.map` grids within ±2.964 (C10) and `cMaxHeight=2.96` **tile-classification** constant (C13, `texturemap.inc:29`); §8 Step 2 prescribes `height=clamp(h_base+grid*scale+offset, MN, MX)` in this exact function. R-code amplitudes from C1 are superseded for hill/ravine by HEIGHT-GEN-DEEP-01 §4.3. |
| `HEIGHT_GEN_DEEP_01.md:1-13,180-195,272-344,418-433,536-561` | Full fresh `generatemap.inc` read: base `h = −1.1·fb·(1+3.5·fr) + A_class·fr` (`:567-574`); **no noise/frequency/per-cell RNG** (seed only picks the mask at `:190,216`); live amplitudes at R=96/R=48 are **+0.495937258 / −0.557929397**, the larger values require `//`-disabled multipliers at `:571-572`; R=88 is a **ravine** code (`−1.022870660`) that port `mapgen.gd:67-68` misroutes to the hill branch; **no script height clamp** — final clamp UNVERIFIED (`:420-428`, §8 Q1). Relief shape still comes from the authored `.pattern` float grids (`:240-252`). |
| `RELIEF_01_stamping.md:117-131,166-184` | Prior opt-in additive-clamp helper and its labels; coarse tables are debug aids; no full float windows in the port. |
| `RELIEF_02_stamp_marker.md:49-84,144-164` | `plt2` is reachable from `donor_patterns.json` `plateau` family; `k_ravine_1` is **BLOCKED** (absent, `ravine_medium` not in recipes, `//`-disabled at donor `dogenerate.inc:1760`). |
| `TRN_DATA_implementation.md:44-64,72-90` | Live tile diversity and 3-pass smoothing are a separate owner; not to be disturbed. |
| `RELIEF_LIVE_DIAG_01.md:290-294` | `k_ravine_1` cannot be emitted by any current producer; restored below as a decoded table but not fabricated into a stamp. |

### 1.1 Coordinator correction folded in

The later `QA_RELIEF_LIVE_01.md` notice is respected verbatim:

- **Rank 3 refuted for the dump path.** The live ±2.964 clamp does **not**
  truncate a dump-path `plt2` stamp: `world3d_terrain.gd:1178-1199` stamps a
  *local decoded copy* with its own `hi` clamp. That consumer was **not edited**
  and no "clamp conflict" there was reconciled. The reconciliation in §3 applies
  only to the live `game.gd` stamp/clamp path owned by this ticket.
- **Rank 6 overstated.** `rock4`/`rock8` can reach flat cells through smoothing
  chains with no height read (now `game.gd:2144-2215`; QA quoted `:2016-2077` before this ticket's
   insertions). This report makes **no**
  claim that rock ids are height-gated or impossible on flat land.
- **Probe step 1 BLOCKED.** The only available 64² dump has `relief_stamps: []`
  for seed 20261113 despite `plateau: 2`, and `stats.relief_grid.applied` is not
  in `--dump-map`. Both are reported as measured/blocked in §6; no seed sweep
  and no invented marker were attempted.

### 1.2 Reconciliation with HEIGHT-GEN-DEEP-01 (new donor height truth)

The later `HEIGHT_GEN_DEEP_01.md` full re-read supersedes the R-code amplitudes
used by DTRN_02 / TERRAIN_DONOR_PIPELINE. This ticket does **not** use the
disabled values as donor truth:

| R code | Donor class | **Live** `hterrain = A·R/255` (HEIGHT-GEN-DEEP §4.3) | Prior-doc value (disabled `*(255/code)`) | Port `mapgen.gd:63-73` |
|---:|---|---:|---:|---:|
| 255 | plateau | +2.963999987 | +2.964 | +2.964 ✅ |
| 191 | plateau smooth | +2.220094204 | — | +1.110 ❌ |
| 96 | hill | **+0.495937258** | +1.317 ❌ | +1.317 ❌ |
| 112 | hill smooth | +0.578593493 | — | +0.651 ❌ |
| 48 | ravine | **−0.557929397** | −2.964 ❌ | −2.964 ❌ |
| 88 | ravine smooth | **−1.022870660** | — | **+1.317 ❌** (hill branch at `mapgen.gd:67-68`) |
| 64 | none (smooth) | 0.0 (derived) | — | +0.372 ❌ |

Consequences for this ticket, all **behaviour-preserving**:

1. **The donor grids themselves are unaffected.** DPATTERN-01's `plt2` and
   `k_ravine_1` float windows and verbatim `HeightFieldScale/Min/Max` are
   pattern-file literals (DPATTERN `:142,154`), independent of the base-mask
   amplitude table. HEIGHT-GEN-DEEP §3.1 explicitly keeps authored pattern
   grids as the relief-shape source; its §4.3 correction concerns `generatemap.inc`
   base heights, not `pattern.lib` sculpt config.
2. **The legacy constants `RELIEF_HILL=2.964/2.25` and `RELIEF_RAVINE=-2.964`
   were NOT changed.** They predate this ticket and feed only the unchanged
   analytic fallback (`_shape_stamp_relief` for ids with no donor grid) and the
   parabolic domes. Their comment in `game.gd` was corrected to state that they
   correspond to the `//`-disabled multipliers and are **not** donor truth for
   R=96/R=48. Changing their numeric values would alter every existing map's
   height and is outside this minimal fix.
3. **The port's ±2.964 bound is NOT claimed to be a donor clamp.** The donor has
   no script height write after phase 4 and no clamp (`HEIGHT-GEN-DEEP §5.4`);
   the final clamp is UNVERIFIED (§8 Q1). The observed `.map` grids merely lie
   inside ±2.964. The global clamp in `game.gd` is retained as a **port-only**
   bound to avoid stacked heights; its comment and the `map_meta` ledger string
   were corrected accordingly. `cMaxHeight=2.96` is a **tile-classification**
   constant (`texturemap.inc:29`), not a height ceiling.
4. **No noise was added.** HEIGHT-GEN-DEEP §3.2 confirms the donor height write
   has no noise/frequency/per-cell RNG; seed only picks the mask bitmap
   (`:190,216`). The `_noise2` dither at `game.gd:1231-1234` is a **pre-existing
   port quantisation artefact**, untouched for non-donor cells and explicitly
   not used as donor shape.
5. **Follow-up ticket (different owner, NOT edited here)** — see §8 item 7 for
   the exact `mapgen.gd` change list.

After these comment-only corrections the two runner results remain valid: no
executable statement, constant value, RNG draw, height write or tile assignment
changed after validation.

### 1.3 Independent QA grading (read-only, landed concurrently)

`QA_RELIEF_FIX_01.md:115-129` graded this fix **CODE LANDED AND CONFIRMED;
RUNTIME GRID PATH NOT EXERCISED; NO PARITY CLAIM**, matching this report's
self-assessment. It independently confirmed: id-gated donor grid before the
analytic fallback; 80/80 floats exact against Appendix A1/A2; verbatim donor
min/max; `_spawn_sid`, `_tb_smooth_pair`, `_assign_tileblocks`,
`_apply_detail_pass` and the smoothing rules byte-identical by SHA-256; jobs
550/551 green; decoded `height` and `tileblock` byte-identical to baseline
(`applied_cells = 0`). One grade is **PARTIAL**, recorded here without change:
the "explicit BLOCKED if no donor data" contract is documented in comments and
§6 but the runtime `meta.relief_grid` ledger has no `blocked`/`no_data` field,
and stamps with unrecognised ids silently use the analytic fallback. Adding a
ledger field would change the validated dump content, so no further runner job
was submitted; the BLOCKED evidence remains §6 plus `candidates/applied_cells
= 0`. `stats.relief_grid.applied` stays UNMEASURED and must not be conflated
with `meta.relief_grid.applied_cells`.

---

## 2. Before → after (`inbox/backup/game.gd.bak-RELIEFLIVEFIX` → current)

`git diff --no-index --stat` = **134 insertions, 6 deletions**, all inside
`variant3d/scripts/game.gd`. Deletions are only replaced *comment* lines
(function header, legacy amplitude comment, clamp comment) plus the audit-ledger
string; no executable statement or numeric constant was removed or changed.
No data file was created. The two runner jobs were submitted before the final
comment-only corrections (§1.2); their results therefore remain valid.

| Before (backup) | After (current) | Change |
|---|---|---|
| `:71-75` height constants only | `:74-121` | Added `RELIEF_GRID_W/H=10/8`, `RELIEF_GRID_K_RAVINE_1` and `RELIEF_GRID_PLT2` (80 floats each, Appendix A1/A2), `RELIEF_GRID_META` with verbatim donor `scale/min/max/w/h/offset/lib`, and the PORT APPROXIMATION / no-synthetic-shape provenance block. |
| `:70` `var _pattern_build` | `:73-74` | Added `_relief_donor_mask: PackedByteArray` — marks cells stamped from a donor grid so the later global clamp can treat them once. |
| — | `:918-934` | New `_sample_relief_grid(grid,u,v)`: bilinear sample of the 8×10 coarse table over 0..1 footprint coordinates; file row order kept (row flip UNVERIFIED). |
| `:870-880` header ("height fields are undecoded") | `:937-950` | Header corrected: donor id → donor grid; analytic profile retained **only** as fallback. Initialises counters and zeroed mask. |
| `:893-895` per-stamp kind read | `:967-985` | Reads `st.get("name")` and selects `plt2` / `k_ravine_1` grid + donor meta; increments `relief_grid_candidates`. No other id is eligible. |
| `:945-950` land/near-start skip | `:1036-1055` | **Donor branch before the analytic profile**: `height[i]=clampf(height[i]+sample*HeightFieldScale, HeightFieldMin, HeightFieldMax)`, mark mask, count cells, `continue`. Analytic radial/taper path below is byte-unchanged. |
| end of `:993` | `:1100-1110` | `map_meta["relief_grid"]` audit ledger: label, table names, source, `candidates`, `applied_cells`, blend form, clamp reconciliation, row_flip. Dump metadata only — no height/tile effect. |
| `:1099-1109` global clamp applies dither to every land cell | `:1216-1236` | Donor-masked cells now take a single `clampf(h, RELIEF_RAVINE, RELIEF_PLATEAU)` (**port-only** ±2.964 bound, no dither-as-shape; no donor clamp exists — §1.2); **all other cells keep the original dither clamp verbatim**. |
| `:1092` call site | `:1209` | Same call, before collision — unchanged ordering. |

Unchanged by construction: `map_starts`, `terrain[]`, `blocked[]`, `tileblock[]`,
all `_tb_*` / `DONOR_SMOOTH_RULES` smoothing, all `Data.*`, RNG draw order,
collision thresholds, `_spawn_sid()` (byte-identical), and the two clamps' values
(`RELIEF_RAVINE=-2.964`, `RELIEF_PLATEAU=2.964`).

---

## 3. Blend and clamp reconciliation (implementation detail)

```
# PORT APPROXIMATION — DONOR ENGINE BLEND UNVERIFIED (DPATTERN-01 §5.2)
u,v        = 0.5 + (map_cell - stamp_centre) / (2 * scaled_donor_extent)
sample     = bilinear( coarse8x10, u, v )         # DPATTERN Appendix A1/A2
h_stamp    = clamp(h_base + sample * HeightFieldScale
                   + HeightFieldOffset(=0), HeightFieldMin, HeightFieldMax)
h_global   = clamp(h_stamp, RELIEF_RAVINE, RELIEF_PLATEAU)   # PORT bound, not a donor clamp
```

- `HeightFieldScale=1` for both ids (DPATTERN `:142`, `:154`); min/max are the
  verbatim float32 `pattern.lib` literals.
- `HeightFieldSmooth` is **not emulated**: the smoothing pass definition is
  UNVERIFIED (DPATTERN §5.2, §9 Q2). No local smoothing/blur was substituted.
- The two **live** clamps are reconciled as follows: the old `game.gd:993`
  `[-2.964,+2.964]` stamp clamp would pre-saturate a donor cap before the
  `game.gd:1099-1109` dither clamp saw it; for donor cells the stamp clamp now
  uses the pattern's own `HeightFieldMin/Max` and the global pass applies one
  clean **port** bound. No donor clamp is asserted (HEIGHT-GEN-DEEP §5.4/§8 Q1);
  cells with no donor grid keep both old clamps exactly.
- The `0.03` dither is untouched for non-donor cells and was **not** repurposed
  as shape, per RELIEF-LIVE-DIAG-01 §3.2.
- The refuted dump-path clamp conflict (`world3d_terrain.gd:1178-1199`) was not
  touched — see §1.1.

---

## 4. Height-field footprint caveat (honest)

The coarse table is mapped over the existing scaled donor footprint bbox
(`cx±ex`, `cy±ey`, derived from `st.cells`, which are donor footprint cells).
The donor engine's exact stamp extent/placement is engine-side and UNVERIFIED
(`dogenerate.inc:1621-1765`, native `StandPattern`); this mapping is a
**PORT APPROXIMATION**, not a donor byte replay. The full `w*h` float windows
(46×63 / 42×55) are deliberately not shipped — Appendix A tables are the
evidence-backed, labelled coarse substitute allowed by the mandate. Row `v`
keeps file order; the file-row→map-row sign flip is UNVERIFIED (DPATTERN `:120-124`).

---

## 5. Validation — variant runner only

| Job (id) | Ticket | Command | Result |
|---|---|---|---|
| `relieflive01-smoke` | **550** | `--headless --path variant3d --check-only --script res://scripts/game.gd` | **ok**, wait 70.85 s, run 17.42 s, **exit 0**. stdout = Godot 4.7.2 banner; stderr **0 B** → `SCRIPT ERROR == 0`. Parse/compile green for the edited file. |
| `relieflive01-dump` | **551** | `--headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/relieflive01_dump.json"` (`--timeout 300 --max-wait 1800`, quoted paths) | **ok**, wait 0.00 s, run 21.58 s, **exit 0**. stdout = banner + `map dump: C:/.../relieflive01_dump.json`. stderr 416 B = the pre-existing `T-MINES-FIX` warning at `pattern_gen.gd:676`; **`SCRIPT ERROR == 0`**. |

No direct `godot`, no gate, no ladder, no queue mutation, no re-submit.
No test was weakened. Gate status remains **28/29 `build`** by prior reports;
this ticket did not run or change any gate, so that red is attributed to the
pre-existing `build` step, not to this edit (TRN_DATA_implementation.md:77).

### 5.1 Measured dump comparison (seed 20261113, 64², 4,096 cells)

| Metric | Baseline `reliefenabl01_dump.json` | After `relieflive01_dump.json` |
|---|---:|---:|
| `height` min | −1.100000023841858 | −1.100000023841858 |
| `height` max | +2.9639999866485596 | +2.9639999866485596 |
| `relief_stamps` | `[]` | `[]` |
| `meta.stamp_counts.plateau` | 2 | 2 |
| `meta.relief_grid` | *absent* | `candidates: 0`, `applied_cells: 0`, tables `["k_ravine_1","plt2"]` |
| `blocked` cells set | 597 | 597 |
| `tileblock` cells with id != 0 | 3,010 | 3,010 |

**Derived:** the live donor-grid hook is present and exercised (the ledger
appears in `meta`), but **zero cells were stamped** because this fixture's two
plateau stamps are not named `plt2` and no `k_ravine_1` stamp can be produced
(§6). Consequently `height` min/max and all tile/blocked counts are byte-for-byte
the baseline — the fix changes no tile assignment, as required. A measurable
height-range delta is **not claimable** from this fixture.

`stats.relief_grid.applied` is **not present** in `--dump-map` output
(RELIEF_ENABLE_01.md:144-149); it was **not measured**, and the new
`meta.relief_grid.applied_cells = 0` is a separate game.gd ledger, not that
consumer statistic. No donor GPU A/B frame exists — no visual/parity claim.

---

## 6. BLOCKED — runtime exercise of the donor grid

- The only available 64² dump (seed 20261113, `small_map_64.json`) carries
  `relief_stamps: []` even though `meta.stamp_counts.plateau = 2`: the plateau
  family's five equally weighted members (`plt1..plt5`) placed two stamps, but
  neither was `plt2` (RELIEF_LIVE_DIAG_01 §3.5; `reliefenabl01_dump.json`).
- `k_ravine_1` is absent from `donor_patterns.json` and every family list;
  `ravine_medium` is not in `pattern_gen.gd:27-36` and is `//`-disabled at donor
  `dogenerate.inc:1760` (DPATTERN-01:341-346; RELIEF-02 §5). No `k_ravine_1`
  marker or stamp was fabricated. Its decoded table is present and will fire if
  a reachable producer ever names that id; until then its live effect is 0.
- Per the mandate, no seed sweep, no extra runner job and no producer/asset edit
  was attempted. **Status: the code path is wired and parse/dump-green; the
  donor-grid stamp itself was not exercised at runtime by any available fixture.**

---

## 7. What remains APPROXIMATION / UNVERIFIED / BLOCKED

1. **Donor engine blend** — `Replace` / `ReplaceForWater` / `Smooth`, clamp and
   scale order, and `-0.925` sign convention are UNVERIFIED (DPATTERN §5.2, §9 Q2).
   Additive-clamp is a PORT APPROXIMATION, not donor parity.
2. **Coarse 8×10 tables are debug/preview aids** (DPATTERN `:599-600`), not the
   full float32 windows; the donor silhouette and cap shape cannot be reproduced
   from block means. `plt2` max `+3.6134` is clamped by the single **port** ±2.964
   bound; the sub-cap shape is coarse. Whether it reads as a hill at the shipped
   camera is UNVERIFIED.
3. **Stamp extent / placement** — mapped over the scaled `st.cells` bbox; donor
   native extent is engine-side and UNVERIFIED.
4. **Row flip** — file-row→map-row sign UNVERIFIED (DPATTERN `:120-124`); file
   order kept.
5. **No donor GPU A/B.** Hue, grain, relief silhouette and luma parity are
   UNVERIFIED. No parity claim.
6. **`stats.relief_grid.applied`** — unmeasured (not in dump schema).
7. **Graded quality of rock/tile marks** — Rank 6 was overstated by QA: rock ids
   can reach flat cells via smoothing; this ticket neither asserts nor changes
   that mechanism (tile assignment untouched).
8. **Dump-path clamp truncation** — refuted by QA (`world3d_terrain.gd:1178-1199`);
   not touched.
9. **Fixture coverage** — runtime grid stamping BLOCKED (§6).
10. **Donor final clamp** — `generatemap.inc` has no height clamp; baked `.map`
    grids only *happen* to lie in ±2.964, and relief grids can reach −3.066
    (HEIGHT-GEN-DEEP §5.4, §8 Q1). The `±2.964` bound kept in `game.gd` is a
    port-only safety bound, not donor-verified.
11. **Legacy `RELIEF_HILL` / `RELIEF_RAVINE`** — +1.31733 / −2.964 match the
    `//`-disabled multipliers (`generatemap.inc:571-572`); live donor amplitudes
    at R=96/R=48 are +0.496/−0.558 (HEIGHT-GEN-DEEP §4.3). Kept unchanged as the
    analytic-fallback constants; **not** used as donor truth by the grid path.
    Reconciling them and `mapgen.gd:63-73` needs a separate owner ticket (§8 Q1).

---

## 8. Open questions (UNVERIFIED — do not guess)

1. Which seed/preset actually places a `plt2` stamp? None found; a producer-side
   dump-content sweep is needed (RELIEF-02 §7 Q1, RELIEF_LIVE_DIAG §7 Q1).
2. Would a `plt2` runtime dump show a measurable height-range delta over the
   baseline, given the 2.964 ceiling and coarse table?
3. Should the full `w*h` float32 windows be exported as derived numeric tables
   (DPATTERN §8) in a later ticket, replacing the Appendix A block means?
4. Should `HeightFieldSmooth` be emulated once the donor smoothing definition is
   verified? It is explicitly not modelled here.
5. Is the resolved file-row sign correct? A donor A/B is required.
6. Should the live audit ledger (`meta.relief_grid`) be promoted to a sanctioned
   test assertion (separate test-owner ticket)?
7. **PRECISE FOLLOW-UP — `HEIGHT-GEN-AMPLITUDE-01` (owner `variant3d/scripts/mapgen.gd`,
   NOT executed here).** *Concurrency update at final read:* another owner has
   already landed `RCODE-FIX-01` in `mapgen.gd` (backup
   `inbox/backup/mapgen.gd.bak-RCODEFIX01`); the current `relief()` at
   `mapgen.gd:75-85` uses exact 8-code decode with `C_HILL*code/255` and
   `C_RAVINE*code/255`, i.e. `+0.496` at R=96 and `−1.023` at R=88 — the
   correction below is **no longer outstanding**, and this agent did not touch
   that file. Original precise spec (kept for the audit trail): Replace the band
   `relief()` at `mapgen.gd:63-73` with
   the exact R-code→class→amplitude table of HEIGHT-GEN-DEEP-01 §4.3:
   `255→+2.963999987`, `191→+2.220094204`, `96→+0.495937258`,
   `112→+0.578593493`, `48→−0.557929397`, `88→−1.022870660`, `64→0.0`;
   specifically fix `mapgen.gd:67-68`, where `absf(v-96.0)<=12.0` wrongly captures
   R=88 (a ravine-smooth code) as hill `+1.317` instead of `−1.022870660`.
   Remove the `C_PLATEAU*(v/255)*0.5` fallback at `:71-72` (donor has no such
   half-amplitude band). Leave the water term at `:186` **unchanged** — it
   already matches `-1.1*fb*(1+3.5*fr)` (HEIGHT-GEN-DEEP row 2). Coordinate a
   second step with this file's owner to retire the legacy `RELIEF_HILL` /
   `RELIEF_RAVINE` constants and the analytic domes (`game.gd:1042-1055`), and
   to decide whether to keep the port-only dither cap. No donor parity claim
   until a donor GPU A/B exists. This ticket deliberately made **no** edit to
   `mapgen.gd` and changed **no** amplitude value.

---

## 9. Summary

`variant3d/scripts/game.gd` now consumes donor-derived relief grids in the
**live** height path: `_shape_stamp_relief()` selects `RELIEF_GRID_PLT2` or
`RELIEF_GRID_K_RAVINE_1` by the stamp's donor id and writes
`clamp(h_base + coarse8x10 bilinear sample * HeightFieldScale,
HeightFieldMin, HeightFieldMax)` over the scaled donor footprint; the existing
analytic radial/taper profile remains only for ids with no decoded donor grid.
The two live clamps were reconciled so donor cells are clamped once with the
pattern's donor `HeightFieldMin/Max` plus a single **port-only** ±2.964 bound
(no donor clamp is verified), while all other cells retain the original dither
clamp verbatim. Per HEIGHT-GEN-DEEP-01 §1.2 the disabled hill/ravine multipliers
were **not** adopted as truth: `RELIEF_HILL`/`RELIEF_RAVINE` were left unchanged
and only their comments corrected, and the exact `mapgen.gd` amplitude fix is a
precise follow-up ticket (§8 Q7), not an edit here. The change is
**134 insertions / 6 deletions** in one file; `_spawn_sid()` was preserved
byte-identically and TRN-DATA smoothing was untouched.

Backup: `inbox/backup/game.gd.bak-RELIEFLIVEFIX`.
Validation: `relieflive01-smoke` (ticket 550, exit 0, stderr 0 B) and
`relieflive01-dump` (ticket 551, exit 0, `SCRIPT ERROR == 0`, 64² quoted fixture,
timeout 300). Measured height min/max are unchanged from baseline
(−1.100000023841858 / +2.9639999866485596) with
`meta.relief_grid = {candidates: 0, applied_cells: 0}`, because seed 20261113
places no `plt2` and `k_ravine_1` is still BLOCKED. Runtime exercise of the new
grid path is therefore **UNVERIFIED**; no donor GPU A/B and no parity claim.
No gate was run or weakened; the pre-existing 28/29 `build` red is attributed to
the existing build step, not to this edit.

**Files edited by this agent:** `variant3d/scripts/game.gd` and this report
(`docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_FIX_01.md`). One backup artifact
was created at `inbox/backup/game.gd.bak-RELIEFLIVEFIX`. **No other file** — no
data file, `pattern_gen.gd`, `world3d_terrain.gd`, `main.gd`, test, config,
shader, fixture, donor file or `app/**` — was created or modified by this agent.
Runner result artifacts under `variant3d/.godot_queue/results/00000550*` and
`00000551*` are harness output.

**Concurrent swarm commit:** another builder's `step` commit `65a1f49a`
(125 insertions / 4 deletions in `game.gd`) swept this agent's edit into HEAD
while validation was running, so a later `git status` shows that path clean.
This agent did **not** run `git add` / `git commit`. The diff against the backup
above is unchanged.

---

*End of RELIEF-LIVE-FIX-01.*
