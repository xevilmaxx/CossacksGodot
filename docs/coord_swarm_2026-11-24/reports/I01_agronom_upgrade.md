---
title: "I1 — Donor aca.3 agriculturists' salary / agronomist +50% academy upgrade"
owner: I1
date: 2026-11-24
ticket: "R1 Top-5 item #1 / R01 claim 12"
status: DONE
scope: "ONE file: app/scripts/data.gd (UPGRADES_BASE). Plus this report. No tests, board, ai.gd, or other docs touched."
---

# I1 — agronomist / agriculturists' salary upgrade

## Result

Added the donor's missing `aca.3` academy upgrade as a single new `UPGRADES_BASE`
row. Donor evidence (read-only, observed this pass):
`C:\Games\Cossacks 3\data\locale\en\upgrades.txt:5-6` — `@%nat%aca.3` /
`Raise agriculturists' salary %include(style;upgradevalue)%(harvesting +50%)`.

## Exact diff

`app/scripts/data.gd`, inserted after the `aca_rye1` row (old line 1143), at
**lines 1144-1147**. Verbatim (`\t` = one tab, as in the neighbouring rows):

```
	# Donor locale/en/upgrades.txt:5-6 = "agriculturists' salary +50%" -> multiplier 1.5
	# (aca.3); cost estimated, donor locale gives the effect only.
	"aca_agronom1": {"building": "aca", "cost": {"food": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"food": 1.5}}, "name": "Agriculturists' salary +50%"},
```

`git diff -- app/scripts/data.gd` confirms **exactly 4 added lines and no
deletions or other edits**. The row follows the existing schema (`building`,
`cost`, `time`, `effect`, `name`); this dict has no `prereq`/`requires` field,
so none was invented. Cost/time are estimated in-family, matching the file's
existing convention for donor-effect-only rows (`costs/effects estimated,
marked so in mechanics`, `data.gd:1110`); the comment marks the estimate.
The name contains the literal `+50%` as required.

## Backup

`inbox\backup\data.gd.bak-I1-AGRONOM` — created with
`Copy-Item app\scripts\data.gd inbox\backup\data.gd.bak-I1-AGRONOM -Force`
before the edit (69250 bytes, confirmed present).

## Verification

1. **Pure-Python read (no Godot):** exactly one `"aca_agronom1":` key; row has
   `building:"aca"`, `gather_mult.food = 1.5`, `time`, `cost`, name with `+50%`;
   tab indentation matches neighbours; `UPGRADES_BASE` braces balance across
   lines 1111-1246; 72 upgrade rows counted. Result `PY_VERIFY_OK`.
2. **Targeted runner (only Godot invocation):**
   `python app\tools\godot_runner.py run --id i1-agronom-upgrades --timeout 180 -- --headless --path app --script res://tests/t_upgrades.gd`
   - runner ticket **1233**, id **i1-agronom-upgrades**, `START` → `END ok`, 12.11 s.
   - `app/tests/results/t_upgrades.json`: `"passed": true`, **6/6 checks passed**
     (firepower_tiers_depth, firepower_damage_stacks, flintlock_cost_and_rof,
     bayonet_melee_upgrade, cavalry_and_drills, no_duplicate_application).
   - The test does **not** assert an exact upgrade count, so there is no
     count mismatch to report.

## Gate status

- Targeted gate: **PASS** (runner ticket 1233, 6/6).
- Full selftest: **NOT RUN**, per instruction — coordinator owns the final
  wave gate.

## Determinism note

Data-only change: one static row in a `const` dict read by `research()`; no
RNG, no `randf()`, no new state, no code path changes. `ai.gd` research lists
were **not touched** (verified: only `data.gd` appears in my diff), so AI
research order and seed-sensitive dumps are unchanged. The new upgrade is
therefore available to the tech tree but is not auto-selected by AI in this
wave.

## Open questions

- **Q3 (from R01) — stacking:** donor aca.1/2/3 and mil.1/2 additive vs
  multiplicative harvesting bonuses remain UNVERIFIED; this row inherits the
  port's existing multiplicative `gather_mult` behaviour. No change made here.
- **Cost fidelity:** donor locale gives the effect text only; no donor cost
  or research-time figure was available, so `food 2000 / gold 400 / 12.0 s`
  is an in-family estimate, explicitly commented as such. Replace if a donor
  price table is ever verified.
- AI uptake of the new upgrade is a separate coordination decision (requires
  an `ai.gd` edit, explicitly out of my ownership this wave).
