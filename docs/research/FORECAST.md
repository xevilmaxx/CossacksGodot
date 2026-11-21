# Port gap forecast — aggregated 2026-11-21

This combines the five parallel research reports and the build workers' findings
into one finite backlog estimate. Every number below comes from a cited report;
none is invented. Ranges are preserved where the source gave a range.

## 0. Owner priority re-scope (2026-11-21) — READ FIRST

The owner does **not** care about missions, campaigns or network for now. The
goal is a good **random-skirmish** port with **maximum graphics fidelity**,
including AI at least as good as the donor, multiple enemies on one map,
squads, and later improvements. Therefore:

- **DEFERRED (not in the active estimate):** all 24–31 DLC/mission tickets,
  P-16 (`.aix` triggers), P-17 (DLC map strategy), cinematics, network.
- **ACTIVE estimate:** roster 40 + mechanics 22 + terrain 56 + visual 36 +
  worker findings ~12 = **~166 tickets**, of which the highest-value skirmish
  tranche is board P-18…P-25 (~34 tickets across AI/teams, options, two fidelity
  tranches, mass-army scale, upgrades, roster and HUD).
- Decompilation effort is filtered the same way: generator/gameplay text,
  roster and asset formats matter; mission-map RE is parked.

## 1. Source reports

| Report | Scope | Tickets |
|---|---|---:|
| `RA_ROSTER.md` | Nations/units/buildings/upgrades/formations vs port | 40 |
| `RB_MECHANICS.md` | Combat/economy/capture/upgrade mechanics (57 rows checked) | 22 |
| `RC_TERRAIN.md` | Map/terrain/generator/editor features (19 rows checked) | 56 |
| `RD_DLC.md` | 5 content DLCs + 2 seasonal packs, 67 mission files on disk | 24–31 |
| `RE_VISUAL.md` | 10 visual categories vs public footage | 36 (23 for top 5) |
| Worker findings (P-06, P-10…P-15, AB, AC) | Concrete defects/gaps from the build lane | ~12 |
| **Total** | | **≈ 190–195 tickets** |

Overlap is small but real: naval appears in RA (3), RE (7) and the AC integration
hand-off; the DLC map-geometry rows in RD overlap RC's map-size work. Treat the
total as an upper bound of **~195 tickets**, with a de-duplicated working figure
of **~175**.

## 2. What the research actually found

- **The port is further along than its docs claim.** RB found 28 of 57 mechanics
  fully implemented; RE/RC found donor masks, scan tooling, formations, morale,
  grapeshot and 95-worker mine ladders already present. RA measured 1506 building
  sprite keys against 18 sim types — the de-duplication matters.
- **The biggest single gap is content scale, not code.** RA: donor 21 nations /
  85 unit names / 119 sids / 889 upgrade names / 149 formation variants versus
  the port's 20 / 42 / 54 / 50 / 5. Scotland is the cheapest visible win — sprite
  `sco_peasant` and 14 building sheets are already baked (RD: 3 tickets).
- **Naval is now a port, not a waiver.** W-01 proved 54 readable meshes and 5
  animated `.oss`; AC baked `yacht` walk + static hull successfully. AC also
  found a real reader bug (`bake_sprites.read_osm_first` offsets 10/11/12 should
  be 12/13/14) — one ticket on its own.
- **The hardest gaps are closed formats — but one opened up.** DD found `.aix`
  files are **plain UTF-8 trigger scripts** (not compiled AI blobs), so campaign
  logic is portable: 18 files, only 6 unique (12 are identical 393 B stubs).
  Exact `.map` terrain grids remain closed (header/markers/placements decode;
  numeric arrays have undocumented stride). RD's 8-ticket DLC-map estimate is
  revised to 3 tickets for procedural mimicry, 4 for a timeboxed hybrid spike,
  or 6–8 for full format RE.
- **Cheapest high-value fixes:** `chop` sound (P-12), nation music (P-13), 12
  baked-but-unwired sprite keys (RA), `attack_force` doc drift, and the review
  template hardening already delivered by AE.

## 3. Capacity model — how many workers this implies

Current enterprise shape:

| Lane | Live slots | Contention |
|---|---:|---|
| Build (Godot) | 20 WIP limit | one serialized Godot runner — throughput throttle |
| Research (web) | 5 (RA–RE) | none — done |
| Decompilation (Craft Anything) | 5 (DA–DE) | none — shared read-only evidence session |
| Governance (Review/Triage/QA) | 3 | no code edits |

At ~175–195 remaining tickets and a WIP limit of 20, that is roughly **9–10
wave-cycles** if each worker completes about one ticket per cycle. Raising WIP
does **not** help the build lane: every code ticket needs selftest/uitest through
the single runner, and measured queue waits are already 100–430 s. The honest
lever is *fewer redundant runner jobs per ticket*, which the job-budget rule in
`app/tools/AGENT_PROTOCOL.md` §1b now enforces.

To finish in ~5 cycles, the build lane would need ~40 live workers — but the
runner would then serialise ~80 acceptance jobs per cycle, with waits exceeding
an hour. The recommended scale is therefore:

- keep **20 build workers**, tighten job budgets, and let QA own the final suite;
- keep research/decompilation lanes parallel (they cost no runner time);
- convert the research reports into a triaged, WIP-limited backlog as tickets,
  starting with the ~10 cheapest high-visibility items;
- DD has reported (`.aix` portable, `.map` grid closed — mission work deferred).
  DC has reported: 17,237 donor files inventoried, OSS/OSM/AAF layouts decoded,
  and the suspected `.osm` reader bug **refuted** (readers already correct).
  Remaining format validation is ~5 worker-days under the skirmish charter;
  the closed `.map` full decoder (+3–5 days) stays deferred with missions.
  All five decompilers have now reported: DA (packed EXEs, RTTI class names
  only, ~3–4 tickets), DB (formation bonuses, stage-level reseeding, hotkeys,
  envscales — ~50–74 h of skirmish truth, board P-30…P-33), DC (format layouts
  decoded, reader bug refuted), DD (`.aix` portable; `.map` grid closed, mission
  work deferred), DE (20 nation tracks + `chop` mapping + hotkeys). The
  decompilation lane is complete; remaining capacity goes to the skirmish
  build tranche and the 15 small-test authors.

## 4. Definition of done for the whole port

`SWARM_OPS.md` gates apply to every ticket: owned files only, backup present,
Godot only via `godot_runner.py`, selftest green, uitest green, Review approve,
QA sign. The port is "all of it" when the ticket backlog is empty **or** each
remaining item has a signed waiver in `WAIVERS.md` naming the exact donor files
and why they are non-playable/unreadable.
