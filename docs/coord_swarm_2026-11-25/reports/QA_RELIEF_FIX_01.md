---
id: QA-RELIEF-FIX-01
title: "Read-only QA — verify RELIEF-LIVE-FIX-01's donor-grid height change"
agent: "QA-RELIEF-FIX-01 (read-only QA subagent, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_LADDER_ADVANCEMENT
scope: "One new file only: this report. No source, asset, config, test, shader, JSON, donor, git, queue or runner edit; no Godot job; no ladder advancement."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_RELIEF_FIX_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, BLOCKED]
label_key: "observed = literal source bytes/decoded artifact read this pass | derived = arithmetic or control-flow consequence of observed bytes | inferred = strong but indirect attribution | UNVERIFIED = not measured this pass | BLOCKED = no instrument/seed exists to measure"
parity_guard: "PORT APPROXIMATION — donor engine blend (Replace/Smooth/clamp order) UNVERIFIED; no donor GPU A/B frame exists; NO DONOR PARITY CLAIM."
head_at_read: "65a1f49a step (fix commit); fix present in HEAD and in working tree"
snapshot_sha256:
  backup_game_gd: "BB2265C71A1A189C600513631034934DADD1B535DCD3D05EC4391DB3525888D4"
  current_game_gd: "965036DF7579A9FF4D5CDC9CADBEA1106130F44128A461F5C353C8D806B3F4E8"
  fix_report: "7446385234C2BCB37515E13FFB8B19DC2DED6989AB3162F4D80783B19E257148"
landing_timeline: "RELIEF_LIVE_FIX_01.md absent at QA start (Test-Path False), landed during QA (288 lines) before the final write; code was already in HEAD 65a1f49a after a concurrent builder committed it"
verdict: "CODE CONFIRMED__REPORT LANDED__RUNTIME PARTIAL (grid path unexercised: meta.relief_grid.applied_cells=0; stats.relief_grid.applied UNVERIFIED)__SEED-20261113 BLOCKER REPRODUCED__NO PARITY CLAIM"
---

# QA-RELIEF-FIX-01 — verify the landed RELIEF-LIVE-FIX-01 donor-grid height change

## 1. Sources, boundary and snapshot

All reads were read-only; the only file written by this worker is this report. **observed**

| # | Source | Use / label |
|---:|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_FIX_01.md` (288 lines, SHA `74463852…`) | Subject under test. Absent at QA start; landed mid-QA. Its claims (`:85-134`, `:150-201`, `:247-270`) were graded against the final landed text — **observed (document)**. |
| S2 | `variant3d/scripts/game.gd` (244,421 B at final read, SHA `965036DF…`) | Live height owner; all code checks below — **observed (source)**. |
| S3 | `inbox/backup/game.gd.bak-RELIEFLIVEFIX` (236,991 B, SHA `BB2265C7…`, matches S1 `:11`) | Pre-fix baseline for `git diff --no-index` and function-hash comparisons — **observed**. |
| S4 | `docs/.../reports/RELIEF_LIVE_DIAG_01.md:121-165,181-209,271-297,301-340,344-369`; `QA_RELIEF_LIVE_01.md:42-113` | Prior diagnosis and the two QA corrections folded into S1 — **observed (document)**. |
| S5 | `variant3d/assets/terrain/patterns/donor_patterns.json`; `docs/.../reports/DPATTERN_01_relief_grids.md:142,154,595-626`; `RELIEF_02_stamp_marker.md:49-84` | Donor ids / grid tables / sculpt metadata — **observed (document/data)**; donor engine blend **UNVERIFIED**. |
| S6 | `%LOCALAPPDATA%\Temp\opencode\relieflive01_dump.json` (54,589 B, 12:52) and `reliefenabl01_dump.json` (54,137 B) | Post-fix and pre-fix `--dump-map` artifacts; base64 `height` decoded in memory with Python 3.14 — **observed (artifact)**. |
| S7 | `variant3d/.godot_queue/results/00000550.json`, `00000551.json` and their `stdout.txt`/`stderr.txt` directories | Runner evidence for the fix's parse smoke and dump — **observed (artifact)**. |
| S8 | `variant3d/scripts/world3d_terrain.gd:527-557,1193,1450-1455` | `stats.relief_grid.applied` producer (consumer path, not in dump schema) — **observed (source)**. |
| S9 | `variant3d/tests/fixtures/small_map_64.json` | Job 551 fixture: 64², `random_seed=20261113`, all other config inherited — **observed**. |

Concurrency note: after the fix commit, another builder edited `game.gd` again (working-tree diff vs HEAD = **12 insertions / 5 deletions**). The probe below shows those are comments plus one ledger string from `HEIGHT-GEN-DEEP-01`; no functional relief line moved. All line numbers in this report are from the final snapshot (SHA `965036DF…`). **observed + derived**

---

## 2. Code verification

### 2.1 Does `_shape_stamp_relief()` consume a donor-derived grid? — **YES (id-gated)**

**observed.** `game.gd:73` adds `_relief_donor_mask`; `:92-122` adds `RELIEF_GRID_W/H=10/8`, `RELIEF_GRID_K_RAVINE_1`, `RELIEF_GRID_PLT2` and `RELIEF_GRID_META`; `:918-935` adds `_sample_relief_grid()` (bilinear, clamped indices, file row order); `:937-945` resets counters/mask; `:977-984` reads `st.get("name")` and selects `plt2` or `k_ravine_1`, incrementing `relief_grid_candidates`; `:1044-1058` writes `height[i] = clampf(height[i] + sample*scale, gmin, gmax)` **before** the analytic branch, sets the mask bit and `continue`s. The old radial/taper profile (`:1060-1099`) is reached only when `donor_grid.is_empty()`. The call site (`:1209`) is still before the collision pass.

**derived.** No id invented: only `plt2` (present in `donor_patterns.json` as a 42×55 pattern with `w/h/cells` — parsed read-only) and `k_ravine_1` (documented as absent/BLOCKED in S1 §6 and S5) are eligible. All other stamps keep the pre-fix analytic path.

**PARTIAL — "explicit BLOCKED if no data".** `k_ravine_1` is labelled `BLOCKED` in a source comment (`:973`) and in S1 `:188-201`, but the **runtime** ledger (`:1101-1111`) carries only `tables/candidates/applied_cells/...` — no `blocked` field, and stamps with an unrecognised name silently fall back to the analytic profile. The no-data condition is therefore documented, not emitted. **observed + derived**

### 2.2 Are the tables donor-derived, not synthetic? — **YES, verbatim transcription**

**observed.** A numeric string comparison against `DPATTERN_01` Appendix A1/A2 found **80/80 floats exactly equal** for each table (`k_ravine_1` min −2.947 / max +2.937; `plt2` min −0.005 / max +3.437). `RELIEF_GRID_META` (`:118-122`) carries the verbatim `pattern.lib` scale/min/max/w/h/offset literals (e.g. `plt2` min `−0.07325489819049835`, max `+3.6134116649627686`, 42×55, offset 2266). The function header and ledger label the tables `PORT APPROXIMATION`, "debug/preview aids only" and `row_flip: UNVERIFIED`.

**derived.** No `rng`/`_noise2`/amplitude-raiser appears in any of the 8 changed diff opcodes; the only arithmetic added is the bilinear `lerpf` and the donor `clampf`. The `0.03` dither block (`:1230-1237`) is byte-unchanged. This supports S1's "no synthetic noise" claim. **derived (from diff opcodes)**. What remains UNVERIFIED is the donor engine's own sculpt blend and whether a coarse block-mean cap reads as a hill at the shipped camera. **UNVERIFIED**

### 2.3 Clamp reconciliation vs `cMaxHeight=2.96` — **CONFIRMED as port ceiling; donor clamp UNVERIFIED**

**observed.** Stamp level (`:1052`): donor cells clamp to the pattern's own `HeightFieldMin/Max`; non-donor cells keep `clampf(h+amp*f, −2.964, +2.964)` at `:1099`. Global level (`:1219-1228`): donor-masked cells take exactly one `clampf(height[hi], RELIEF_RAVINE, RELIEF_PLATEAU)` = `[−2.964, +2.964]` and skip the dither; every other land cell keeps the original dithered cap verbatim. The audit string at `:1107` now reads "single PORT +-2.964 bound on donor cells (donor clamp UNVERIFIED)" and the comment at `:1224-1227` says "`cMaxHeight=2.96` is a tile-class constant".

**derived.** The port's ±2.964 baked-map ceiling is respected; donor values above it (e.g. `plt2` block means 3.437/3.392, donor `HeightFieldMax` 3.6134) are truncated to that port ceiling. S1's post-landing correction is more accurate than its original "donor baked-map ceiling" wording: the donor has no verified script height clamp. The QA-RELIEF-LIVE-01 rank-3 correction is honoured — `world3d_terrain.gd` was not edited and no dump-path clamp conflict was "fixed" here. **observed + derived**

### 2.4 Protected regions byte-identical — **CONFIRMED**

**observed.** SHA-256 of extracted function bodies, pre-fix backup → current (byte-for-byte equal):

| Function | Length | SHA-256 (16 hex) | Result |
|---|---:|---|---|
| `_spawn_sid` (NATION-SPAWN helper) | 316 B | `6fdcb2f47ef5a9be` | **IDENTICAL** |
| `_nation_name` | 637 B | `35c1678b0ae91b24` | **IDENTICAL** |
| `_tb_smooth_pair` (TRN-DATA smoothing) | 1,844 B | `b938bd19dfadf2e7` | **IDENTICAL** |
| `_apply_detail_pass` | 1,052 B | `8b6008ec14915368` | **IDENTICAL** |
| `_assign_tileblocks` | 4,440 B | `08200b8925641314` | **IDENTICAL** |
| `_cliff_tile_for` | 1,067 B | `e696f39d46348aa2` | **IDENTICAL** |

`DONOR_SMOOTH_RULES` and `_smooth_tilemap` are likewise untouched: a line-level `SequenceMatcher` over backup → current produced **exactly 8 changed opcodes**, all inside the relief zones (`:71-80`, `:84-123`, `:918-935`, `:940-950`, `:970-984`, `:1039-1055`, `:1101-1111`, `:1218-1228` in current numbering). No tile/RNG/collision line changed. **observed + derived**

Diff accounting: S1's stated **125 insertions / 4 deletions** is reproducible against S3 at the fix commit (`bb80df40`); at final read the working-tree diff vs backup is 134/6 because of the comment-only drift above (12/5 vs HEAD). The 4 deletions are the two replaced header comment lines. **observed**

---

## 3. Runtime evidence

### 3.1 Runner jobs — **GREEN, but no grid exercised**

**observed.** Job `550 relieflive01-smoke`: `--check-only --script res://scripts/game.gd`, `status: ok`, `exit 0`, stderr 0 B → parse/compile clean. Job `551 relieflive01-dump`: `--config small_map_64.json --dump-map relieflive01_dump.json`, `status: ok`, `exit 0`, run 21.58 s; stderr 416 B is the pre-existing `T-MINES-FIX` warning at `pattern_gen.gd:676`, no `SCRIPT ERROR`. **observed**

### 3.2 Measured dump comparison — height min/max and `relief_grid.applied`

Python 3.14 `base64` + `struct.unpack('<f')` over the 16,384-byte `height` field (4,096 cells), **observed**:

| Metric | `reliefenabl01_dump.json` (pre-fix) | `relieflive01_dump.json` (post-fix) |
|---|---:|---:|
| seed / size | 20261113 / 64×64 | 20261113 / 64×64 |
| `height` min | **−1.100000023841858** | **−1.100000023841858** |
| `height` max | **+2.9639999866485596** | **+2.9639999866485596** |
| cells ≥ 2.93 | 54 | 54 |
| `relief_stamps` | `[]` | `[]` |
| `meta.stamp_counts.plateau` | 2 | 2 |
| `meta.relief_grid` | absent | `{candidates: 0, applied_cells: 0, tables: ["k_ravine_1","plt2"], row_flip: "UNVERIFIED", ...}` |
| SHA-256 of decoded `height` (16 hex) | `12750f48bd17e919` | `12750f48bd17e919` |
| SHA-256 of decoded `tileblock` | `21f77d2985d7f8fc` | `21f77d2985d7f8fc` |

**derived.** The two dumps are byte-identical in `height`, `tileblock`, `terrain` and `blocked`; the ledger proves the new code ran, but **zero donor cells were stamped**, so no height delta is measurable and no donor-grid shape can be attributed to this fixture. `meta.relief_grid.applied_cells = 0` is the game.gd audit counter. **`stats.relief_grid.applied`: UNVERIFIED** — that statistic belongs to `world3d_terrain.gd:1454` and is produced only by `build()`; it is absent from `--dump-map` schema, and no marked dump was fed to that consumer. Do not conflate the two counters. **observed + derived**

### 3.3 The seed-20261113 blocker — **REPRODUCED**

**observed.** Both dumps carry `relief_stamps: []` with `meta.stamp_counts.plateau = 2`, exactly the blocker recorded in `QA_RELIEF_LIVE_01.md:83,101` and `RELIEF_LIVE_DIAG_01.md:259-267`: the two plateau stamps were not named `plt2` (the plateau family has five equally weighted members), and `k_ravine_1` cannot be emitted by any current producer. **inferred** (family weighting explanation from the cited reports; no producer-side sweep was run by this QA). Status of the donor-grid **runtime exercise: BLOCKED**, not failed.

---

## 4. Verdict

| Check | Grade | Basis / labels |
|---|---|---|
| Fix report landed | **CONFIRMED** | S1 present with 288 lines, SHA `74463852…`; absent at QA start — **observed**. |
| Live height consumes donor-derived grid | **CONFIRMED (code)** | Id-gated `plt2`/`k_ravine_1` branch before analytic fallback (`game.gd:977-1058`) — **observed/derived**. |
| Tables donor-derived, no synthetic shape | **CONFIRMED (code)** | 80/80 floats exact vs DPATTERN A1/A2; donor meta verbatim; no new noise/RNG — **observed/derived**. Donor blend and hill appearance **UNVERIFIED**. |
| Explicit BLOCKED when no donor data | **PARTIAL** | Comment + report only; no runtime `blocked` ledger field; unmatched names silently use analytic fallback — **observed/derived**. |
| Clamp reconciliation respects `cMaxHeight=2.96` | **CONFIRMED as port ±2.964 ceiling** | Single donor-cell clamp, dither bypass; donor's own clamp UNVERIFIED — **observed/derived**. |
| TRN-DATA smoothing / NATION-SPAWN helper byte-identical | **CONFIRMED** | SHA-equal function bodies; 8 opcodes, all relief — **observed**. |
| Parse / dump green | **CONFIRMED** | Jobs 550/551 `ok`, `exit 0`, `SCRIPT ERROR == 0` — **observed**. |
| Runtime height delta / donor grid applied | **UNVERIFIED — BLOCKED by fixture** | `applied_cells = 0`, identical height bytes; `stats.relief_grid.applied` not in dump — **observed/UNVERIFIED**. |
| Donor parity | **NO CLAIM** | No donor GPU A/B; coarse debug-aid tables; engine blend UNVERIFIED — **UNVERIFIED**. |

Overall: **CODE LANDED AND CONFIRMED; RUNTIME GRID PATH NOT EXERCISED; NO PARITY CLAIM.** S1's own self-assessment (`IMPLEMENTED__PARSE_AND_DUMP_GREEN__RUNTIME_EXERCISE_BLOCKED_BY_FIXTURE`) is accurate and reproducible. Nothing here upgrades the fix to a runtime PASS or to donor parity.

---

## 5. Open questions (UNVERIFIED — do not guess)

1. Which seed/preset actually emits a `plt2` stamp? Seed 20261113 does not; a producer-side dump sweep is still needed (carried from `QA_RELIEF_LIVE_01` §5 Q1).
2. If a `plt2` dump is found, will `meta.relief_grid.applied_cells > 0` and will the height range shift past ±2.964 be measurable with these coarse tables?
3. Will `stats.relief_grid.applied` ever be measured? It needs a sanctioned marked-dump → `world3d_terrain.build()` test; no such test exists.
4. Should the runtime ledger gain an explicit `blocked`/`no_data` marker for ids without a decoded grid, to satisfy the "explicit BLOCKED" contract beyond comments?
5. Is the file-row→map-row sign correct, and is mapping the coarse 8×10 table over the scaled `st.cells` bbox donor-faithful? Both need a donor A/B.
6. Should the full 42×55 / 46×63 float32 windows be exported as derived numeric tables instead of Appendix A block means?
7. Does the live `plt2` stamp, once exercised, read as a hill at the shipped camera, or as another flat pale cap?
8. Donor parity of hue, grain, relief silhouette and luma: blocked on a donor GPU A/B; none exists. **No parity claim.**

---

## 6. Summary

Read-only QA of the landed `RELIEF_LIVE_FIX_01.md` and its code. The fix report landed during this QA; the code is in HEAD `65a1f49a` and the relief hunks remain intact in the (concurrently edited) working tree. `_shape_stamp_relief()` now writes a donor-derived 8×10 block-mean grid for stamps named `plt2` or `k_ravine_1` (`game.gd:977-1058`), with the analytic profile kept as fallback; both tables match `DPATTERN_01` Appendix A1/A2 exactly, 80/80 floats each. Stamp clamping uses the verbatim donor `HeightFieldMin/Max`, and the later global clamp applies one ±2.964 port ceiling to donor cells while leaving the non-donor `0.03` dither untouched. TRN-DATA smoothing and the NATION-SPAWN helper (`_spawn_sid`, `_tb_smooth_pair`) are byte-identical to the pre-fix backup by SHA-256, and all eight changed diff opcodes are relief-only.

Runtime evidence is green but **not discriminating**: jobs 550/551 passed with `SCRIPT ERROR == 0`, and the post-fix 64² dump shows `height` min/max **−1.100000023841858 / +2.9639999866485596** with `meta.relief_grid.applied_cells = 0`; the decoded `height`/`tileblock` bytes are identical to the pre-fix dump. The seed-20261113 `relief_stamps: []` blocker from `QA_RELIEF_LIVE_01` is reproduced, so the donor-grid height change is **UNVERIFIED at runtime (BLOCKED)** and `stats.relief_grid.applied` was not measured. No donor GPU A/B exists; **no donor parity claim**. No file other than this report was written; no runner job was submitted.

---

*End of QA-RELIEF-FIX-01. Read-only; no code/asset/config/test/shader/JSON/donor/git edit, no Godot job, no ladder advancement.*
