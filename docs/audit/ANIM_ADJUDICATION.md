---
title: Animation-metric threshold adjudication (t_anim_metrics)
owner: ADJ-P45
ticket: P-45
decision: D-22
updated: 2026-11-21
status: CLOSED-ADJUDICATED
---

# 🔬 Animation-metric threshold adjudication — P-45 / D-22

> [!IMPORTANT]
> Quality-first protocol (`SWARM_OPS.md` §5b-QUALITY, decision **D-22**):
> evidence before edits, independent re-verification by a different method,
> `observed` / `derived` / `inferred` kept separate, and **no bulk data change
> to make a test green**. Ownership for **P-45** was limited to
> `app/tests/t_anim_metrics.gd` and this new audit file. No value in
> `app/assets/models/anim/index.json`, `naval/index.json`, or any game code was
> changed.

## Adjudication table

| Check | Original threshold | Evidence | Verdict | Adjusted rule | Justification |
|---|---|---|---|---|---|
| `action_structure` | `frames >= 2` for **every** action (GUIDE4 DO-L7.01's "one row = bake failed") | **observed** (donor, read-only): `cannon/howitzer/mortar/multicannon.aaf` all contain `idle 1..1`; baker formula `duration=(last−first+1)/fps` (`bake_sprites.py:246`) → exactly 1 frame / 0.033 s. The PNGs are genuinely 1280×160 (8 dirs × 1 row), i.e. a static pose, not a collapsed bake. | **threshold wrong** (claim "data defect" CONTRADICTED) | Exempt `frames == 1` **only** for `idle` of those four named artillery keys; all other actions still require `frames >= 2`, `duration > 0`, `loop` bool. | DO-L7.01's single-row guard is a **walk** skate check; a one-pose artillery idle is donor-faithful. The exemption names the four donors rather than all idles, so a 1-frame `walk`/`attack`/`death` still fails. |
| `metric_ranges` | `foot` in **0.70..0.90** (GUIDE4 DO-L7.02, a standing-man eyeball band) | **observed**: 299/299 actions re-measured from the PNGs with Pillow 12.1.1 using the project's exact `sheet_metrics.py:33-48` method (cell-local RGBA `getbbox()`, union over 8 dirs × frames) → **0 mismatches**. All 68 outliers are real pixels: 25 `death` (lying, 0.9062–0.9437), 14 `attack` (weapon swing, 0.9062–0.95), 16 `walk` + 11 `idle` (crouch/rolling, 0.6813–0.95), 2 carry poses. `world.gd` anchors with `ax/ay` first, so `foot` is a fallback. | **threshold wrong** (claim "data defect" CONTRADICTED) | `foot` in **0.66..0.96** = measured envelope 0.6813–0.95 + 0.02 rounding margin. `fig_h` 0.30..0.95 and `cx` 0.40..0.60 unchanged. | `foot = y1/cell` is the bottom of the per-action ink bbox (DO-L7.04). Lying/swinging/rolling donor poses naturally place that bottom outside the standing band. Re-measurement proves the values are measured, not stale defaults; the G1 tiny-men failure is still caught by the unchanged `fig_h` band (1.0 default excluded). |
| `walk_stride` | `duration ≈ frames × 0.09` ±0.15 s for **all** walks (GUIDE4 DO-L7.06) | **observed**: duration is the donor AAF range ÷ 30 fps (`bake_sprites.py:246`). Mapping all 54 keys through the baker's own key→base table (`bake_sprites.py:552-565`) gives **45/54 donor-exact**; the only 9 deviations are the 9 peasant walks deliberately set to 1.08 s by agentC2/agentSE (`UNIT_BAKING_FIX.md` §10/§11) per DO-L7.06. DO-L7.08 itself assigns a faster gallop to cavalry and a longer roll to artillery. | **threshold wrong** (claim "data defect" CONTRADICTED) | Replace the single rule with **per-class donor cadence bands** for a 12-frame walk, scaled by `frames/12`: march 0.78–0.85, gallop 0.52–0.58, cossack 1.55–1.65, siege 3.25–3.35, peasant 1.06–1.10. | Each band is centred on a cited donor AAF range, not tuned to the current data: e.g. `pikeman.aaf walk 1..24/30 = 0.8`, `hussar.aaf 1..16/30 = 0.533`, `cossacksich.aaf 1..48/30 = 1.6`, `cannon.aaf 1..99/30 = 3.3`. Bands are tight (±0.03 s) and still reject the 0.05 s min-clamp hyper-flap DO-L7.02 warns about. |

**Overall verdict for P-45:** all three red checks are **stale thresholds**, not data
defects. This is the same class of ruling as D-24 (stale 25-tile judge radius vs a
correct generator) and D-25 (boundary `>=`, not radius): **do not detune correct
data to please a stale test.**

## Evidence detail

### E1 — metric values are measured, not defaults (independent re-verification)

Exact method replication of `sheet_metrics.py` (Pillow 12.1.1, `convert("RGBA")`,
`crop(cell).getbbox()` per cell, cell-local union, `foot=round(y1/cell,4)`):

| Action | Index bbox / fig_h / foot / cx | Re-measured | Match |
|---|---|---|---|
| `pikeman/death` | `[9,25,152,146]` / 0.7562 / **0.9125** / 0.5031 | identical | ✅ |
| `archer/attack` | `[8,21,152,151]` / 0.8125 / **0.9437** / 0.5 | identical | ✅ |
| `drummer/walk` | `[30,18,130,152]` / 0.8375 / **0.95** / 0.5 | identical | ✅ |
| `pikeman18/idle` | `[62,46,98,109]` / 0.3937 / **0.6813** / 0.5 | identical | ✅ |
| `mortar/idle` | `[9,39,151,151]` / 0.7 / **0.9437** / 0.5 | identical | ✅ |
| `peasant/walk` (control) | `[61,56,99,115]` / 0.3688 / 0.7188 / 0.5 | identical | ✅ |

Full-roster sweep: **299 actions checked, 0 mismatches**. This independently
confirms agentSE's §11 finding and IMPL-ASSETS's §12.3 naval measurement by a
second method (Pillow vs the baker's own metrics pass).

### E2 — donor AAF cadence (read-only, no donor file copied into `res://`)

| Class | Key(s) | Donor AAF `walk` | Duration @30 fps | Index |
|---|---|---|---|---|
| march (33) | pikeman, archer, drummer, musk18, … | `1..24` | 0.8 | 0.8 |
| march (3) | cossackregister, sipahi, vityaz | `614..638` | 0.833 | 0.833 |
| gallop (2) | hussar, wingedhussar | `1..16` | 0.533 | 0.533 |
| gallop (2) | hackapell, croat | `1..17` | 0.567 | 0.567 |
| cossack (1) | cossack (`cossacksich`) | `1..48` | 1.6 | 1.6 |
| siege (4) | cannon, howitzer, mortar, multicannon | `1..99` | 3.3 | 3.3 |
| peasant (9) | peasant + 8 national variants | `1..20` | 0.667 | **1.08** (DO-L7.06 `n*0.09` correction) |

`derived`: the 0.05 s min-clamp failure mode in DO-L7.02 maps to a 1–2 frame
duration and is outside every band; the bands are therefore not weakened into
"accept anything".

### E3 — verification run

`python app\tools\godot_runner.py run --id adj-p45 --timeout 90 --max-wait 3600 -- --headless --path app --script res://tests/t_anim_metrics.gd`

- Runner ticket **377**: `wait 0.00s`, `run 0.35s`, `exit 0`, `status ok`.
- `app/tests/results/t_anim_metrics.json` **fresh** (`unix_ms 1795252452194`,
  advanced from `1795252099461`): `passed: true`, 5/5 checks PASS —
  `main_index_54_units`, `action_structure`, `metric_ranges`, `walk_stride`,
  `naval_schema`.
- Negative controls (Python simulation of the new rules): a 0.05 s duration and
  a 1-frame `walk` are still flagged; only the four donor-static artillery
  `idle` actions are exempt.

## Genuine data defects left

**None found in the three adjudicated checks.** The following are *open policy
questions*, explicitly **not** defects — no data was edited and no ticket is
raised to change values:

1. **Mixed peasant cadence convention** (9 keys): donor truth is 0.667 s, port
   value is the DO-L7.06-corrected 1.08 s. Both are defensible (donor fidelity
   vs foot-length stride); the data owner should pick one policy in a separate
   ticket before any further walk retiming.
2. **50 systemic short attack durations** — already deferred by agentSE §11.4
   to a dedicated frame-level timing ticket; out of scope for P-45.
3. **Scottish unit walk convention** (`sco_highlandersword`, donor `walk 1..24`
   = 0.8 s vs the 1.08 s port convention) — open per `UNIT_BAKING_FIX.md` §12.4(c);
   it lives in the separate `sco_units.json`, not the 54-key index.
4. **Naval `foot` 0.9313 / 0.95** exceed the land band but are real measured
   values and the naval test does not range-check them (§12.3).

## Files changed

- `app/tests/t_anim_metrics.gd` — three rules narrowed as above; backup at
  `inbox/backup/t_anim_metrics.gd.bak-ADJ-P45`.
- `docs/audit/ANIM_ADJUDICATION.md` — this file (new).

No `index.json`, asset, or game-code file was touched by **P-45**.
