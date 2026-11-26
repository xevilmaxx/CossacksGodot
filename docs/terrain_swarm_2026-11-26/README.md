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

## Status

_swarm running; update from background reports as they land._
