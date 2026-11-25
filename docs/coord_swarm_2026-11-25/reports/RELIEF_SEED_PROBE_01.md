---
id: RELIEF-SEED-PROBE-01
title: "RUNTIME CONFIRMED — seed 20261150 (plains, 64x64) emits plt2 relief stamp; markers, candidates and applied_cells match the offline prediction exactly"
agent: "RELIEF-SEED-PROBE-01 (runtime verification worker, coord swarm 2026-11-25)"
date: 2026-11-25
status: CONFIRMED__RUNTIME_MARKER_AND_LEDGER_OBSERVED__HEIGHT_MINMAX_UNCHANGED_AS_PREDICTED__NO_PARITY_CLAIM
scope: "One new file only: this report. Game code READ-ONLY; no source/asset/config/test/shader/donor/queue/git edit; no direct godot; exactly ONE variant-runner job submitted; no re-submit; no re-submit of a slow job; no queue mutation. Fixture, decode scripts and dump live OUTSIDE the repo under %LOCALAPPDATA%\\Temp\\opencode\\reliefseedprobe\\."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/RELIEF_SEED_PROBE_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, UNVERIFIED, BLOCKED]
label_key: "observed = literal job artifact / decoded dump bytes read this pass | derived = arithmetic or deterministic consequence of observed bytes | UNVERIFIED = not measured this pass | BLOCKED = no instrument exists to measure"
parity_guard: "PORT APPROXIMATION — this probe confirms the PORT's own plt2 branch fires at runtime. It makes NO donor parity claim: donor engine blend (Replace/Smooth/clamp order), silhouette, row flip and GPU appearance remain UNVERIFIED; no donor A/B frame exists."
probe_target: "Confirm seed 20261150 actually emits a plt2 relief stamp at runtime (RELIEF-SEED-SCAN-01 §6 optional probe)."
verdict: CONFIRMED
job:
  id: reliefseedprobe01-dump
  ticket: 565
  status: ok
  exit: 0
  wait_s: 396.2196683883667
  run_s: 10.862032651901245
  timeout_s: 300.0
  max_wait_s: 1800
  runner: "variant3d\\tools\\godot_runner.py (variant runner only; no app runner, no direct godot)"
  stderr_bytes: 416
  script_error_count: 0
  engine_banner: "Godot Engine v4.7.2.stable.official.ed1daf0bf"
  result_artifact: "variant3d/.godot_queue/results/00000565.json"
measured:
  relief_stamps: [{name: plt2, cx: 54, cy: 33}]
  candidates: 1
  applied_cells: 443
  height_min: -1.100000023841858
  height_max: 2.9639999866485596
  height_sha256_16: "1ab1573a4738709a"
  tileblock_sha256_16: "72cfda93c7354088"
baseline:
  artifact: "%LOCALAPPDATA%\\Temp\\opencode\\relieflive01_dump.json (measured S5 anchor, seed 20261113, post-fix job 551)"
  corroborator: "%LOCALAPPDATA%\\Temp\\opencode\\reliefenabl01_dump.json (pre-fix, same seed; identical height/tileblock hashes)"
  relief_stamps: []
  candidates: 0
  applied_cells: 0
  height_min: -1.100000023841858
  height_max: 2.9639999866485596
  height_sha256_16: "12750f48bd17e919"
  tileblock_sha256_16: "21f77d2985d7f8fc"
---

# RELIEF-SEED-PROBE-01 — runtime confirmation of the seed-20261150 `plt2` stamp

> [!IMPORTANT]
> This is a **runtime measurement**, not a replay. Exactly one `--dump-map` job was
> submitted through the variant runner (ticket **565**, `status: ok`, `exit 0`,
> **`SCRIPT ERROR == 0`**). The decoded dump shows
> `relief_stamps = [{"name":"plt2","cx":54,"cy":33}]`,
> `meta.relief_grid.candidates = 1` and `applied_cells = 443` — an exact match to
> the RELIEF-SEED-SCAN-01 offline prediction. The seed is therefore **CONFIRMED**
> to exercise the port's `plt2` donor-grid branch at runtime. Height min/max did
> **not** shift, as the scan explicitly cautioned; the discriminators are the
> marker, `candidates`, `applied_cells` and the decoded `height`/`tileblock`
> hashes (both changed). **No donor parity claim.**

---

## 1. Evidence read (all read-only)

| # | Source | Fact used |
|---:|---|---|
| S1 | `docs/.../reports/RELIEF_SEED_SCAN_01.md:184-272` | Prediction under test: seed 20261150 → `relief_stamps=[{plt2,cx:54,cy:33}]`, `candidates=1`, `applied_cells=443`; §6 exact optional probe command; §5 discriminator table. |
| S2 | `docs/.../reports/RELIEF_LIVE_FIX_01.md:225-259,263-276` | Prior jobs 550/551; seed-20261113 blocker (`relief_stamps: []`, `applied_cells=0`); runtime grid path previously UNEXERCISED. |
| S3 | `docs/.../reports/QA_RELIEF_FIX_01.md:85-129` | Baseline hashes and labels; `stats.relief_grid.applied` not in dump schema. |
| S4 | `variant3d/tests/fixtures/small_map_64.json:1-15` | Overlay model: config.gd merges fixture over shipped config; 64², seed 20261113, plains inherited. |
| S5 | `variant3d/scripts/data.gd:229-247` | `Data.RELIEF = "plains"` default (`:235`); fixture needs no relief override. |
| S6 | `%LOCALAPPDATA%\Temp\opencode\relieflive01_dump.json` (54,589 B, measured) | Seed-20261113 baseline used for comparison (S5 of the scan). |
| S7 | `%LOCALAPPDATA%\Temp\opencode\reliefenabl01_dump.json` (54,137 B) | Pre-fix companion; identical `height`/`tileblock` hashes — corroborates the baseline. |
| S8 | `variant3d/.godot_queue/results/00000565.json` + `00000565_reliefseedprobe01-dump/{stdout,stderr}.txt` | This probe's job ticket, timings, status, banner and stderr — **observed**. |

---

## 2. Command run (verbatim, from repo root; Windows `python`)

Fixture created OUTSIDE the repo at
`%LOCALAPPDATA%\Temp\opencode\reliefseedprobe\seed_20261150.json`:

```json
{
  "_readme": [
    "RELIEF-SEED-PROBE-01: 64x64, seed 20261150, relief tier plains (Data.RELIEF default, data.gd:235).",
    "All other config inherited from res://config.json via config.gd overlay merge (config.gd:229-243)."
  ],
  "gameplay": {
    "render_mode": "3d",
    "random_seed": 20261150,
    "map_width_tiles": 64,
    "map_height_tiles": 64
  }
}
```

`relief plains` is the inherited `Data.RELIEF` default (`data.gd:235`); no game
config file was touched. One command, quoted paths, unique id, `--timeout 300`,
`--max-wait 1800`:

```
python variant3d\tools\godot_runner.py run --id reliefseedprobe01-dump --timeout 300 --max-wait 1800 -- --headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefseedprobe/seed_20261150.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefseedprobe/dump.json"
```

This is the scan's §6 command with the id and temp paths renamed for this probe.
No `--check-only`, no gate, no ladder, no direct `godot`, no second submission.

---

## 3. Job data (observed)

| Field | Value |
|---|---|
| Runner | `variant3d\tools\godot_runner.py` (variant runner only) |
| Job id | `reliefseedprobe01-dump` (unique) |
| Ticket | **565** |
| `status` | **ok** |
| `exit` | **0** |
| `wait` | 396.2196683883667 s (~6.6 min, FIFO — normal) |
| `run` | 10.862032651901245 s |
| `--timeout` | 300.0 s |
| `--max-wait` | 1800 s |
| stdout | `variant3d\.godot_queue\results\00000565_reliefseedprobe01-dump\stdout.txt` |
| stderr | `variant3d\.godot_queue\results\00000565_reliefseedprobe01-dump\stderr.txt` |
| Engine banner | `Godot Engine v4.7.2.stable.official.ed1daf0bf` |
| stdout body | `map dump: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefseedprobe/dump.json` |
| stderr | **416 B** — the pre-existing `T-MINES-FIX` warning at `pattern_gen.gd:676` (`build` → `game.gd:1207` → `_dump_map`) |
| **`SCRIPT ERROR` count** | **0** (case-insensitive scan of stderr bytes) |

**Queue discipline (observed).** `godot_runner.py status` was checked **before**
submission: `now_serving=555`, `next_ticket=565`, `pending=10 [555..564]`,
`godot.lock` held (age 878.1 s). The job waited 396.22 s in FIFO and ran once;
it was **not re-submitted**. After completion `now_serving=566`,
`next_ticket=568` (tickets 566/567 belong to other workers), confirming this
probe created exactly **one** job. No queue mutation was performed.

---

## 4. Decoded dump table (observed / derived)

Python 3.14 read-only decode: base64 `height` → `struct.unpack('<4096f')`,
base64 `tileblock` → raw bytes, SHA-256 truncated to 16 hex as in prior reports.

| Metric | Probe — seed **20261150** | Baseline — seed **20261113** (`relieflive01_dump.json`) | Discriminates? |
|---|---:|---:|---|
| `seed` / size | 20261150 / 64×64 | 20261113 / 64×64 | — (setup) |
| mask | `mediterranean/7pl_mask_mediterranean_10_gauss.png` | same file | no (same mask, as scan predicted) |
| **`relief_stamps`** | **`[{"name":"plt2","cx":54,"cy":33}]`** | `[]` | **YES — primary gate** |
| **`meta.relief_grid.candidates`** | **1** | 0 | **YES — id gate fired** |
| **`meta.relief_grid.applied_cells`** | **443** | 0 | **YES — donor-grid heights written** |
| `meta.relief_grid.tables` | `["k_ravine_1","plt2"]` | `["k_ravine_1","plt2"]` | no (static ledger) |
| `height` min | −1.100000023841858 | −1.100000023841858 | **NO** (explicit scan caveat) |
| `height` max | +2.9639999866485596 | +2.9639999866485596 | **NO** (explicit scan caveat) |
| SHA-256(decoded `height`, 16 hex) | `1ab1573a4738709a` | `12750f48bd17e919` | **YES — cell-level height change** |
| SHA-256(decoded `tileblock`, 16 hex) | `72cfda93c7354088` | `21f77d2985d7f8fc` | **YES — collision/tile change** |
| decoded `height` length | 16,384 B / 4,096 floats | 16,384 B / 4,096 floats | — |
| decoded `tileblock` length | 4,096 B | 4,096 B | — |
| `meta.stamp_counts` (non-mine) | `decor 1, forest 10, hill 2, mountain 1, plain 1, plateau 2, stone 4, tile 4` | `decor 1, forest 10, hill 4, mountain 1, plain 1, plateau 2, stone 3, tile 4` | corroborating replay |
| `meta.stamp_counts.mine` | 9 | 11 | not modelled by scan (`UNVERIFIED` there) |

The pre-fix artifact `reliefenabl01_dump.json` has the same seed-20261113
`height` hash `12750f48bd17e919`, `tileblock` hash `21f77d2985d7f8fc` and
`relief_stamps: []`, so the baseline is stable across the fix (S7).

### Derived cross-checks

- **Scan prediction vs measurement — exact.** `relief_stamps` name and centre
  `(54,33)`, `candidates=1` and `applied_cells=443` all match
  RELIEF-SEED-SCAN-01 §5 byte-for-byte. The seed is **CONFIRMED**.
- **Height min/max unchanged — expected.** The donor plateau grid is clamped to
  the port's ±2.964 bound and the water floor is untouched; min/max is *not* the
  pass criterion, exactly as the scan caveat stated. The discriminating proof of
  a height change is the SHA-256 delta (`12750f48…` → `1ab1573a…`).
- **Tileblock SHA changed** (`21f77d29…` → `72cfda93…`), consistent with the
  scan's note that relief runs before collision.
- **Non-mine `stamp_counts` match the scan's per-seed prediction** (`hill 2`,
  `stone 4`, others equal); `mine=9` was outside the offline replay's model.
  This independently corroborates the shared-RNG replay that found the seed.

---

## 5. Verdict

| Check | Grade | Basis |
|---|---|---|
| Runtime `plt2` marker present | **CONFIRMED** | `relief_stamps=[{plt2,cx:54,cy:33}]` measured in ticket 565 dump — **observed** |
| Id gate fired | **CONFIRMED** | `meta.relief_grid.candidates = 1` — **observed** |
| Donor-grid heights written | **CONFIRMED** | `meta.relief_grid.applied_cells = 443` — **observed** |
| Height min/max shifts? | **NO — as predicted** | unchanged −1.100000023841858 / +2.9639999866485596; not a discriminator — **observed/derived** |
| Cell-level height change | **CONFIRMED** | decoded `height` SHA `12750f48…` → `1ab1573a…` — **derived from observed** |
| Tile change | **CONFIRMED** | decoded `tileblock` SHA `21f77d29…` → `72cfda93…` — **derived from observed** |
| Runner green / clean stderr | **CONFIRMED** | ticket 565 `ok`, `exit 0`, 416 B stderr, `SCRIPT ERROR == 0` — **observed** |
| Donor GPU/silhouette parity | **NO CLAIM** | no donor A/B frame; coarse 8×10 block-mean tables; blend/row-flip UNVERIFIED — **UNVERIFIED** |

**Overall: CONFIRMED.** Seed **20261150** at 64²/`plains` genuinely emits a
`plt2` relief stamp at runtime, and the previously unexercised donor-grid branch
in `game.gd:_shape_stamp_relief()` is now demonstrably exercised
(`applied_cells = 443`). This retires the scan's "UNVERIFIED prediction" label
for the marker/candidates/applied-cell values. It does **not** upgrade anything
to donor parity (§6).

---

## 6. Open questions (UNVERIFIED — do not guess)

1. **Still-open visual A/B.** No donor GPU frame exists. Whether the stamped
   `plt2` reads as a hill, a flat pale cap, or otherwise at the shipped 3D camera
   is **UNVERIFIED**. This probe measures dump bytes only, not pixels.
2. **Donor engine blend parity.** `Replace` / `Smooth` / clamp order, sign
   convention and the `HeightFieldScale` application remain **UNVERIFIED**; the
   port uses an additive-clamp **PORT APPROXIMATION** over 8×10 block means
   (debug/preview aids), not the full float32 window. **No parity claim.**
3. **Row flip.** File-row → map-row sign remains **UNVERIFIED**; needs a donor A/B.
4. **Full 320² map / other tiers.** This probe is 64²/`plains` only. Seed
   20261150 on the shipped 320² config (or hills/mountains) picks a different
   mask and RNG stream — **UNVERIFIED**.
5. **`k_ravine_1`** remains unreachable from any current producer (donor
   `ravine_medium` `//`-disabled; absent from the port recipes) — **BLOCKED**;
   not attempted here.
6. **`stats.relief_grid.applied`** (consumer-side `world3d_terrain.gd`) is not in
   the `--dump-map` schema — **BLOCKED**. Do not conflate it with the measured
   `meta.relief_grid.applied_cells = 443`.
7. **Exact applied-cell accounting.** 443 is the measured game.gd ledger value;
   the scan's bbox/protected-cell decomposition of that number is **derived**,
   not independently re-derived here.
8. **Engine version.** Banner reads Godot 4.7.2; the scan's RNG source cross-check
   was against 4.2-stable/master. The exact runtime dump match (marker, centre,
   candidates, applied_cells and non-mine counts) is strong empirical evidence
   the same PCG is in force, but no source-level version audit was done here.

---

## 7. Summary

One variant-runner job (`reliefseedprobe01-dump`, ticket **565**) was submitted
with seed 20261150, 64×64 and inherited `plains` relief; it finished `ok` /
`exit 0` with `SCRIPT ERROR == 0`. The decoded dump **confirms** the offline
prediction exactly: `relief_stamps = [{"name":"plt2","cx":54,"cy":33}]`,
`meta.relief_grid.candidates = 1`, `applied_cells = 443`. Height min/max stayed at
−1.100000023841858 / +2.9639999866485596 as the scan anticipated, while decoded
`height` and `tileblock` SHA-256 values both changed versus the seed-20261113
baseline — cell-level proof the donor-grid heights were actually written. The
non-mine `stamp_counts` also match the scan's per-seed replay prediction.

Verdict: **CONFIRMED** for the port's `plt2` runtime branch. The still-open
visual A/B and all donor-parity questions remain **UNVERIFIED — no parity
claim**. No game file was edited: game code, assets, config, tests, shaders,
donor files, queue state and git were all READ-ONLY; the fixture, decode script
and dump live outside the repo under `%LOCALAPPDATA%\Temp\opencode\reliefseedprobe\`.
The only file written in the repo is this report.

---

*End of RELIEF-SEED-PROBE-01. One runner job; one report; no game file edited.*
