---
title: Deep audit protocol — quality first
owner: coordinator
decision: D-22
updated: 2026-11-21
---

# 🔬 Deep audit — quality first

> [!IMPORTANT]
> The owner asked for a deep, unhurried analysis of every implementation and
> decompilation. This directory supersedes the "ship waves" tempo. **Breadth
> expansion is paused.** Depth, evidence and reproducibility matter more than
> ticket throughput. See `SWARM_OPS.md` §5b-QUALITY and decision D-22.

## Rules

1. **Evidence before edits** — cite a donor file/constant, a runner result, or
   a Craft Anything evidence id for every claim.
2. **Independent re-verification** — a finding is accepted only after a second
   check by a different method or agent. One grep or one green test is not proof.
3. **Observation vs inference** — label `observed`, `derived`, `inferred`.
   Never promote an inference to a fact because it is convenient.
4. **No "good enough"** — if a claim cannot be measured, write `UNVERIFIED`.
5. **Correct, don't rewrite** — minimal diffs, backed up, gates re-run.
6. **Configurability and efficiency** are required for the final port, but are
   a LATER tranche (D-22). Record them as explicit future tickets here, not as
   excuses to cut fidelity now.

## Claim table format (every audit file)

| # | Claim | Evidence | Verification method | Verdict | Correction needed |
|---|---|---|---|---|---|
| 1 | e.g. "formation bonus 7 on hold" | `dogenerate.inc` / `formations.cfg` (DB fnd_22) | re-read donor bytes + compare `game.gd:1737` | CONFIRMED / CONTRADICTED / UNVERIFIED | ticket id or "none" |

Verdict values: `CONFIRMED`, `CONTRADICTED`, `UNVERIFIED`, `PARTIAL`.

## Audit assignments

| File | Area | Auditor | State |
|---|---|---|---|
| `SIM.md` | game.gd simulation truth (damage, economy, capture, formations) | deep-SIM | assigned |
| `RENDER.md` | world.gd visual fidelity vs donor assets | deep-RENDER | assigned |
| `DECOMP.md` | independent re-verification of DA–DE findings | deep-DECOMP | assigned |
| `CONFIG_EFFICIENCY.md` | configurability + performance baseline (future tranche) | deep-CONFIG | assigned |

## Related

`docs/RESUME.md` · `docs/DECISION_LOG.md` (D-22) · `docs/STATUS_*.md` · `SWARM_BOARD.md`
