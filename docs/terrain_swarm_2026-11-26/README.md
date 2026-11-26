# Terrain swarm — 2026-11-26 (donor-first)

> **Cold entry point.** Today's rule: decode the donor before touching the port.
> We work only on `variant3d/`; `app/` stays byte-untouched. Donor is read-only,
> private use, never executed, never committed.

## Start here

1. [CHARTER.md](CHARTER.md) — problem, sources, deliverable, guardrails.
2. [SWARM_BOARD.md](SWARM_BOARD.md) — 31 workers, assignments, status.
3. `reports/**` — one report per worker (landing now).
4. `spec/**` — the cited specification assembled from those reports.

## The day's sequence

```
30+ workers ──▶ 24 donor-decoding reports (D/F waves)
               ──▶  6 port-audit reports  (P wave)
               ──▶  6 design reports     (A wave)
                         │
                         ▼
              COORD cross-check + contradictions resolved
                         │
                         ▼
              docs/terrain_swarm_2026-11-26/spec/  (cited)
                         │
                         ▼
              variant3d/tools/*  donor → runtime asset compilers
                         │
                         ▼
              variant3d/scripts/terrain_donor_*.gd  (NEW, not patched)
                         │
                         ▼
              gates + fresh capture + honest verdict
```

## Free decompilation tooling (owner note)

Craft Anything's **Deep mode** already exposes a Ghidra-class lifter (native
function study / pseudo-C / xrefs) and is the primary tool this session. If the
owner can install extra **free** software, the highest-value additions for this
specific stripped 32-bit Delphi/C++Builder target are:

| Tool | Why it helps | Cost |
|---|---|---|
| **Ghidra 11.x** (NSA) | batch headless analysis + Python scripts for RTTI/vtable recovery; same class of lifter Craft Anything uses | free/open source |
| **IDR — Interactive Delphi Reconstructor** | purpose-built for stripped Delphi binaries: recovers class hierarchies, RTTI, DFM events and generates IDA/Ghidra-friendly maps — exactly the `X*`/`T*` problem in `DA_PE.md` | free |
| **ImHex** | pattern-language binary parser for `*.pattern` and `pattern.lib`; byte-accurate struct definition | free/open source |
| **Cutter / radare2** or **RetDec** | second-opinion decompilation when the built-in lifter produces unstructured pseudo-C | free/open source |
| **HxD** (or ImHex) | read-only hex inspection of donor `.map` / `.pattern` bytes | free |

None is required to continue — the swarm is already decoding with Craft Anything
and Python. They would mainly speed up Delphi RTTI anchoring and cross-check
decompiler output.

## Status (point-in-time, 2026-11-26)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor
> GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

- **Reports:** 100+ landed — **108 report files** under `reports/**` at the final
  three-pass count (the set grew 104 → 105 → 108 during the day and was still moving).
  `LANDED` means a file exists; it is not integration, correctness or a gate PASS.
- **Implementation + assets:** the **14 implementation files/tickets (I01–I13 + N14
  composer, seam counted once)** are present on disk, plus **780 derived JSON assets**
  under `variant3d/assets/terrain_new/**` (`cfg/` 3, `patterns/` 713,
  `patterns/families/` 64; untracked). Presence is not validation: no `atlas/` tier,
  no root `manifest.json`, no `terrain_donor_tiles.gd`, no N7 validator; I08/I09
  fall back to legacy assets.
- **API state:** V48's four caller-side patches are applied; V61 (and V65) report
  all six audited caller→callee pairs as **static PASS** on type/arity/contract.
  That is a line-level static verdict only — no parse job, runner, gate or capture
  was run by those workers.
- **Gates / parity:** **no gate has been run for today's tree** (result JSONs are
  stale 2026-11-25; `assert_clean` was `DIRTY` with 575/582/585 unacked), no
  admissible capture and **no donor GPU A/B frame**. `parity.status = "UNVERIFIED"`,
  `parity.claim = NONE`, `blocking_unverified` non-empty ⇒ `RESULT IS NOT GOOD`.
- **Backend:** `terrain_backend` **defaults to `"legacy"`** (`features.terrain.backend`;
  `main.gd:125`/`:189`, `world3d.gd:144`); only the exact string `"donor"` opts in and
  late switching is refused after `bind()`. The donor path is inert-by-default and
  ungated — no default flip.

_Counts re-globbed in three independent passes immediately before this edit (reports
108, assets 780); re-check before use. Documentation only — no source, asset, config,
test, git, Godot or donor state was changed by this edit._
