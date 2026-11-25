---
id: B-A-PATTERN-COUNTS
title: "P0-1: donor-grounded relief attempt counts + 5-tier presets in pattern_gen.gd"
agent: "B-A-PATTERN-COUNTS (implementation builder, coord swarm 2026-11-25)"
date: 2026-11-25
scope: "OWNED: variant3d/scripts/pattern_gen.gd ONLY + this report. app/ NEVER touched. No other file edited."
labels: [observed, derived, PORT-APPROXIMATION, UNVERIFIED]
parity_guard: "No donor GPU A/B exists. No parity claim made anywhere in this report."
---

# B-A-PATTERN-COUNTS — P0-1 implementation report

## 1. Backup evidence (governance)

- Source: `variant3d/scripts/pattern_gen.gd` → `inbox/backup/pattern_gen.gd.bak-BAPATTERN`
- Verify: `fc.exe /b` → `FC: no differences encountered` (byte-identical, observed 2026-11-25).
- No renames of called symbols. `pick()` weights untouched. No donor binary copied. All donor numbers cite `path:line` or are marked UNVERIFIED.

## 2. Exact diff (before → after)

### Hunk 1 — 5-tier RELIEF_PRESETS (`pattern_gen.gd:19-23` → `:15-33`)

Before: 3 string keys (`plains/hills/mountains`).
After: int ids 0–4 with tier triples verbatim from the Z1 §5 proposal table, donor
`dogenerate.inc:1626-1628,1631-1633,1636-1638,1641-1643,1646-1648` cited per line;
legacy string keys kept with identical values (`plains`=id 0, `hills`=id 1,
`mountains`=id 3), so `game.gd` string callers are unaffected. Plus two labelled
placeholders: `RELIEF_PROBLARGE ≡ 1.0`, `RELIEF_PROBHUGE ≡ 1.0`
(PORT APPROXIMATION — engine-computed multipliers, UNVERIFIED, Z1 §3.3).

### Hunk 2 — recipe comment + plain_huge freq (`:24-36` → `:34-52`)

Before: `plain_huge` used `plt/12` (port-invented, Z1 §3.3 INVENTED verdict).
After: `RELIEF_PLAIN_HUGE_FREQ := 0.00005` (= `plain/2`, `dogenerate.inc:1727,1731`);
the recipe row keeps shape with divisor marked `UNUSED`. `ravine_medium` stays
absent (donor `//`-disabled, `dogenerate.inc:1760`).

### Hunk 3 — signature (`:60-62` → `:76-83`)

`relief: String` → `relief: Variant = "plains"` (accepts future int ids 0–4;
current string callers byte-identical) + new optional `stage_seed: int = -1`.
Both `game.gd` call sites pass 9 positional args (`:739-740,:1207-1208`), so the
appended 10th optional param is safe. `stage_seed` is the sequenced **P1-1 hook**:
while `-1`, every draw stays on the legacy shared rng stream (unused now).

### Hunk 4 — count rule (`:541-549` → `:562-589`)

Before: `freq = preset/divisor; needed = int(W*H*freq); if needed<1: needed=1`.
After:

```
size_mod = 640/((W+H)/2)                       # dogenerate.inc:1718-1725; 1.0 iff W+H=1280
freq_fam = tier/divisor × RELIEF_PROBLARGE × size_mod   # problarge≡1 UNVERIFIED
plain_huge: freq = 5e-5 × RELIEF_PROBHUGE × size_mod     # probhuge≡1 UNVERIFIED
needed = floor(W*H*freq_fam)                    # misc.script:3695
if needed==0: needed = round(W*H*freq_fam)       # misc.script:3696-3700; may stay 0
if needed<=0: continue                           # hard ≥1 clamp DELETED
```

`pick()` (`:132-151`) untouched → family `Freq` weights verbatim (MAPGEN-RECON-01 E7).

## 3. Validation — one targeted runner job (governance max)

- Job: ticket **573**, id `bapattern-dump240-20261113`, `status: ok`, `exit: 0`,
  run 44.55 s, waited ~0 s (queue was pending=1 at submit check → waited 110 s
  until pending=0/lock free, then submitted once; no re-submit).
- `stdout.txt` 167 B, `stderr.txt` 0 B, **SCRIPT ERROR count: 0** (both files).
- Fixture OUTSIDE repo (temp dir, new): 240², seed 20261113, no relief key →
  tier `plains` inherited (`main.gd:306-309` + `data.gd:364`, derived).
- Dump: seed 20261113, 240×240, `meta.type: mediterranean`, `meta.quality: high`.

## 4. Dump ledger vs Z1 reference columns (observed, no parity claim)

`meta.stamp_counts` (relief kinds only): `plateau: 2, plain: 4, hill: 3`
(`mountain: 0, ravine: 0` — keys absent). Non-relief: `forest 44, stone 14,
decor 5, tile 4, mine 16`. `relief_stamps: []`, `meta.relief_grid:
{candidates: 0, applied_cells: 0}` — expected: the marker only lists
`plt2`/`k_ravine_1` (`main.gd:777-783`), and the single `plateau`-family draw
missed `plt2` at P=4/5; `ravine_medium` is donor-disabled.

| Recipe (plains, 240², size_mod=2.667, derived) | New `needed` target | Old-port §2 target | Placed here |
|---|---|---|---|
| mountains | 3 | 1 | 0 |
| plateau_big | 1 | 1 | — |
| plain_huge | 7 | 1 | 4 |
| ravine_big | 1 | 1 | 0 |
| plateau | 1 | 1 | — (plateau-kind total: 2 of 3) |
| plateau_small | 1 | 1 | — |
| hills_dark | 5 | 2 | — (hill-kind total: 3 of 10) |
| hills_light | 5 | 2 | — |
| **Total** | **24** | **10** | **9** |

The 24-target column reproduces the Z1 §5 donor-reference row
(3/1/7/1/1/1/5/5, `problarge=probhuge=1` UNVERIFIED) exactly; the placed-9
shortfall is donor-normal rejection sampling (placed ≤ needed, Z1 §3.2:
512-attempt footprint test on the separate relief grid). No ladder, no gate
claim: one seed, one tier, targets-vs-placed only.

## 5. Handoff / leftovers

- P1-1 (stage-keyed RNG, same file, sequenced after): consume `stage_seed` from
  `game.gd:_reseed_stage("patterns")` for the relief sub-stream; keep
  tile/mine/forest draws on the legacy stream (MAPGEN-RECON-01 §5 P1-1).
- Disjoint: `game.gd`, `world3d_terrain.gd`, shader, config untouched.
- Donor citations used: `dogenerate.inc:1626-1648,1718-1725,1727,1731,1737-1739,
  1757-1765,1760`; `misc.script:3695-3700`; `generator.cfg` Freq semantics via
  Z1 §3.1. UNVERIFIED: `problarge/probhuge` numeric values, engine count
  semantics, all visual parity.

*End of B-A-PATTERN-COUNTS. One file changed + backup + this report; one runner
job; no donor parity claimed.*
