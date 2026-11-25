---
id: SP-03
task: "DESERT-REMAP — create the Desert tile remap JSON from donor Summer-name rules (indices 111-122 already packed)"
date: 2026-11-25
status: DELIVERED__DATA_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Two files written only: variant3d/assets/terrain/atlas/desert_remap.json and this report. No donor file opened/executed/copied; no Godot job; no .gd/.gdshader/.json asset/config/test edited; no art invented; no git state changed beyond these two new files."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/assets/terrain/atlas/desert_remap.json"
  - "docs/coord_swarm_2026-11-25/reports/SP_03_desert_remap.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 2
visual_parity_claim: false
---

# SP-03 — Desert tile remap JSON (Summer families → packed Desert ids 111–122)

## 1. Goal and scope

Turn the donor `_misc_SetDesert` Summer→Desert tile-name remap into a **single, read-only data
file** that a future renderer hook (SP-6) can consume. The 12 `desert1..12` ids are **already
packed** in the Summer atlas at indices **111–122**; this ticket adds only the name→index
decision table. No art, no new ids, no code, no runner job.

Explicitly out of scope (carried from SEASON-PLAN-01 §1/§7): winter atlas, cloud/weather, sky,
fog, snow, day/night, mesh height scaling, prop-material edits, and any runtime execution of
the donor rules. All cited donor `path:line` facts are **second-hand** from the read-only audit
docs (DENV-01, DEC-05, DEC-03), because the donor was not opened this task.

---

## 2. Citations (all read this task, none edited)

| # | Source | Line(s) | What it supplies | Label |
|---|---|---|---|---|
| C1 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | `:188` | SP-3 ticket definition: per-case Summer→Desert/set name table; include `rock8` gate, `koef=0.8`, mine `s` as labelled data only | observed |
| C2 | SEASON_PLAN_01.md | `:148-157` | `_misc_SetDesert` effect summary and the "two suffixes not conflated" rule | observed |
| C3 | SEASON_PLAN_01.md | `:94-95`, `:159-174` | desert1..12 packed at 111–122; derived port mapping: desert remap is an **index remap before UV2**, no shader edit | observed + derived |
| C4 | SEASON_PLAN_01.md | `:231-232`, `:241-263` | labels to carry (height `koef`, mine `s`, rock8 gate = donor-text-observed / runtime UNVERIFIED / data only); open questions Q2/Q8 | observed |
| C5 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | `:439-445` | `_misc_SetDesert` (`miscext.script:1429-1543`) explicit remap pairs at `:1447-1502`; `rock8` gate `:1504-1505`; `koef=0.8` `:1513-1520`; mine `s` `:1531-1534`; env destruction `:1536-1537` | observed (donor via prior read) |
| C6 | DENV_01.md | `:420-426` | season enum: `map.script:250` default 0, `dmscript.global:237` count 3, desert test `dogenerate.inc:4,2079`, `generator.cfg:1629-1655` weights 1000/0/1000/100 | observed |
| C7 | DENV_01.md | `:474-494` | season swap chain table: desert = Summer names remapped in place, **no separate preset section**; `alpha0a→alpha0c`; `koef=0.8`; colour table 7; props = `desert*` + frequency keys | observed |
| C8 | DENV_01.md | `:483`, `:492-494` | prop material suffix **`w` is a WINTER rule** (`fir1→fir1w`, `UseableWinterMaterials`); desert does not use `w`; tile aliases use `_winter`; cloud `season=2` UNVERIFIED | observed |
| C9 | DENV_01.md | `:529-530`, `:596-599` | port has `presets_summer.json` (desert1..12 at `:113-124`) and manifest desert entries at `:2710-2987`; donor `;`-script runtime activity UNVERIFIED (Q6/Q8) | observed |
| C10 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | `:417-439` | 124 ids per season; ids 93–98 `sandsea1..6` shoreline; id 123 `alpha0c` is an alias material to `grass1.dds`, not a distinct texture | observed |
| C11 | DEC-05.md | `:441-448`, `:560-563` | one integer `tex` per cell; `;`-prefixed `.inc` lines → activity UNVERIFIED | observed |
| C12 | `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` | `:60` | inventory record for `data\game\var\generator.cfg` (70,074 B, 2367 lines). Exact weight line numbers come from C6/C1, not re-parsed here | observed |
| C13 | `variant3d/assets/terrain/structs/presets_summer.json` | `:2-125` (READ-ONLY) | 124 Summer names; index = line − 2. Source/target ids: `grass1` 0 (`:2`), `grass2` 1 (`:3`), `grass7` 6 (`:8`), `grass8` 7 (`:9`), `ground1` 10 (`:12`), `rock1` 17 (`:19`), `rock7` 23 (`:25`), `rock8` 24 (`:26`), `rock9` 25 (`:27`), `test7` 78 (`:80`), `test8` 79 (`:81`), `alpha0a` 86 (`:88`), `sandsea5` 97 (`:99`), `test16` 100 (`:102`), `test23` 107 (`:109`), `desert1..12` 111–122 (`:113-124`), `alpha0c` 123 (`:125`) | observed |
| C14 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | `:2710-2987` (READ-ONLY) | `layout` entries for desert1..12 at indices 111–122; e.g. `desert2` idx 112 `:2735-2756`, `desert4` idx 114 `:2783-2804`, `desert6` idx 116 `:2831-2852`, `desert11` idx 121 `:2951-2972`; other targets: `sandsea5` `:2380`, `test16` `:2452`, `test23` `:2620`, `alpha0a` `:2120`, `alpha0c` `:3000` | observed |

Evidence vocabulary: **observed** = literal line read (port directly this task; donor via
C1–C12 earlier passes); **derived** = index arithmetic over observed names; **UNVERIFIED** =
cannot be proven from readable data; **PORT APPROXIMATION** = port-chosen transport/claim not
asserted as donor parity.

---

## 3. Mapping table (the JSON contents)

Source keys are base **Summer** preset names; target indices were derived from
`presets_summer.json` (index = array position) and confirmed against the manifest `layout`.
All 12 source keys exist in `presets_summer.json`; all 12 targets resolve to packed indices.

| # | Source (Summer) | src idx | Target | tgt idx | target `source_png` | Donor citation | Label |
|---:|---|---:|---|---:|---|---|---|
| 1 | `grass1` | 0 | `sandsea5` | 97 | `sandsea5.png` | `miscext.script:1447-1502` (C5) | DONOR_INDEX |
| 2 | `grass7` | 6 | `desert6` | 116 | `desert6.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 3 | `grass8` | 7 | `desert6` | 116 | `desert6.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 4 | `ground1` | 10 | `test16` | 100 | `test16.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 5 | `grass2` | 1 | `desert11` | 121 | `desert11.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 6 | `test7` | 78 | `desert11` | 121 | `desert11.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 7 | `test8` | 79 | `desert11` | 121 | `desert11.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 8 | `rock1` | 17 | `desert2` | 112 | `desert2.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 9 | `rock7` | 23 | `desert4` | 114 | `desert4.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 10 | `rock9` | 25 | `test23` | 107 | `test23.png` | `:1447-1502` (C5) | DONOR_INDEX |
| 11 | `alpha0a` | 86 | `alpha0c` | 123 | **none** (EMPTY cell) | `:1501` (C7) | DONOR_INDEX / PORT APPROX |
| 12 | `rock8` | 24 | `desert2` | 112 | `desert2.png` | `:1504-1505` (C5) | UNVERIFIED_RUNTIME_GATED (data only) |

**Notes on the table**

- Rows 1–11 are the direct per-case remap; row 12 is the height-gated case and is stored in the
  JSON's separate `height_gated` block, not executed.
- `desert1/3/5/7/8/9/10/12` (indices 111/113/115/117/118/119/120/122) are **packed but not
  a target of any explicit donor remap case**; the donor reaches them via generation weights
  (`generator.cfg:1629-1655`, C6) and smoothing, which are outside this ticket's name table.
  No invented source→id pair was added for them.
- `test16` (100) and `test23` (107) are **already-packed Summer-set tiles**, not `desertN`
  ids. They are recorded because the donor text names them explicitly (C5); they satisfy
  "resolves to a packed atlas index" but fall outside the parenthetical enumeration in the
  SP-3 acceptance line (C1). See Open question O2.
- `alpha0a`→`alpha0c` is index-only: both are manifest EMPTY cells with `source_png = null`
  (C13/C14). DEC-05 `:435` (C10) records `alpha0c` as an alias material resolving to
  `grass1.dds`, not distinct art. No art was fabricated.

### 3.1 Labelled data-only fields (stored, not executed)

| Field | Value | Donor citation | Label |
|---|---|---|---|
| `rock8` height gate | `0.1 < h < 2.9 and (h > 1.8 or h < 1)` → `desert2` | `miscext.script:1504-1505` (C5) | UNVERIFIED_RUNTIME_GATED |
| dry-land height scale | `koef = 0.8` | `miscext.script:1513-1520` (C5) | UNVERIFIED_RUNTIME_GATED, DATA_ONLY_NOT_EXECUTED |
| mine basename suffix | `s` (`minegold → minegolds`) | `miscext.script:1531-1534` (C5) | DATA_ONLY_NOT_EXECUTED |
| env object destruction | all except `stones*` / `field` | `miscext.script:1536-1537` (C5) | DATA_ONLY_NOT_EXECUTED |
| `desert_tiles` weights | `d_tls_1=1000`, `d_tls_2=0`, `d_tls_3=1000`, `d_tls_4=100` | `generator.cfg:1629-1655` (C6; inventory C12) | DATA_ONLY_NOT_EXECUTED |

### 3.2 Scope clarification — the `w` suffix is NOT a desert rule

DENV-01 `:483` (C8) assigns the `w` suffix to **winter** prop materials
(`fir1→fir1w`, `field1→field1w`, `plantsatlas→plantsatlasw`, `UseableWinterMaterials`);
desert props are `desert*` props plus `desert` frequency keys in generator patterns (C7).
SEASON-PLAN-01 `:155-157` (C2) forbids conflating `_winter` tile aliases, `w` prop materials
and the cloud `season=2` field. Therefore **no `w` suffix appears in the desert remap JSON**;
this is recorded in its `scope_clarifications` block so a future consumer does not apply it.

---

## 4. Validation

Two read-only Python 3.14 passes (scripts in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`,
outside the repo) over the new JSON, `presets_summer.json` and the atlas manifest:

| Check | Result |
|---|---|
| `json.load()` parse of `desert_remap.json` | **PASS** (16 top-level keys, no syntax error) |
| Source keys present in `presets_summer.json` | **12/12** (11 direct + 1 height-gated) |
| Target names present in `presets_summer.json` | **12/12** |
| `source_index` / `atlas_index` equal array positions | **12/12** |
| Each target's manifest `layout[atlas_index].name` equals target | **12/12** |
| Each source's manifest `layout[src_index].name` equals source | **12/12** |
| Declared `target_source_png` equals manifest `source_png` | **12/12** (incl. `null` for `alpha0c`) |
| `desert1..12` contiguous at indices 111–122 | **PASS** (verified independently in pass 1) |
| `sandsea1..6` at 93–98 | **PASS** |
| New ids invented | **0** |
| Donor file read/copied/executed; Godot job run | **none** |
| Code / shader / loader / test / config edited | **none** |

Earlier read-only inventory pass (SEASON-PLAN-01 §3, C3): atlas has 16×8 grid, 124 named
cells, 121 filled, 3 empty (`alpha0a` 86, `alpha0b` 110, `alpha0c` 123), 4 spare slots
(124–127). This file uses only existing named cells; it does not change the atlas, its PNG,
or any shipped dump.

---

## 5. What stays UNVERIFIED

1. **Engine swap activity.** All cited donor swap logic lives in `;`-prefixed `.inc`/`.script`
   lines (`miscext.script`, `texturemap.inc`, `dogenerate.inc`, `onloadfull.inc`). The literal
   remap text is observed; whether `_misc_SetDesert` actually runs in the shipped build is
   **UNVERIFIED** (C5/C9/C11; DENV-01 Q6/Q8; SEASON-PLAN-01 B6). This JSON encodes donor
   **intent**, not proven runtime behaviour.
2. **Season value `1`.** `gc_MaxSeasonCount=3` implies 0/1/2 but only 0 (default), 2 (winter)
   and 3 (desert) are readable; value 1 stays UNVERIFIED (C6). No mapping for it was added.
3. **Height gate, `koef=0.8`, mine suffix `s`, env-object destruction, generator weights.**
   Donor-text-observed but runtime-UNVERIFIED; stored as labelled `DATA_ONLY_NOT_EXECUTED`.
   SP-6 is index-only and does not apply height scaling (C4).
4. **Atlas packing / alpha subrects.** Port 16×8 packing is `APPROX_ATLAS_PACKING`; donor
   `tsDouble`/`ttExtended` is engine-side. `alpha0a`/`alpha0c` EMPTY cells have no shipped
   PNG. Donor GPU A/B and visual parity are **UNVERIFIED** (`visual_parity_claim: false`).
5. **Prop `w` art.** Winter prop `w` art is absent in the port (SEASON-PLAN-01 B1b); this is a
   winter concern only and is not modified here.
6. **No consumer wired yet.** The JSON is data only. `world3d_terrain.gd` currently has no
   BIOME branch (`:870-878`, `:924-992` per SEASON-PLAN-01 §3.4); applying this table is SP-6.

---

## 6. Open questions (do not guess)

- **O1 — File location.** The task brief assigns `variant3d/assets/terrain/atlas/desert_remap.json`;
  SEASON-PLAN-01 `:188` (C1) proposed `variant3d/assets/terrain/structs/desert_remap.json`.
  The brief's `atlas/` path was used, adjacent to the manifest whose indices the table names.
  COORD/SP-6 must confirm which path the renderer hook reads; if `structs/` is preferred, move
  the file in a coordinated edit (not done here — would violate this ticket's exclusive outputs).
- **O2 — Acceptance parenthetical.** C1's acceptance enumerates targets as "desert 111–122,
  `sandsea*` 93–98, `alpha0c` 123" but donor text also maps `ground1→test16` (100) and
  `rock9→test23` (107). Both are already-packed Summer tiles, so they meet the real requirement
  ("resolves to a packed atlas index"); recorded as such, not silently rewritten to `desertN`.
- **O3 — Unpacked desert ids.** What should consume `desert1/3/5/7/8/9/10/12` (indices
  111/113/115/117/118/119/120/122) when no explicit donor remap names them? Likely generator
  weights + smoothing (C6), which are outside this ticket. No invented mapping added.
- **O4 — `alpha0a→alpha0c` semantics.** Both are EMPTY port cells; is the intended port effect
  "leave transparent", "sample `grass1.png`" (DEC-05 `:435` alias), or a shader alpha patch
  change? Index-only was chosen; no art invented. Needs DALPHA-02 owner input.
- **O5 — Height gate application.** Should SP-6 (or a later ticket) apply `rock8`'s height gate
  and `koef=0.8`? Requires mesh-height work beyond index remap and is runtime-UNVERIFIED
  (SEASON-PLAN-01 Q2).
- **O6 — Single source of truth.** This table duplicates donor facts already summarised in
  DENV-01/SEASON-PLAN-01; duplication is intentional to keep this ticket data-only and avoid
  co-owned `game.gd` (SEASON-PLAN-01 B4/Q3).

---

## 7. Summary

SP-03 created **one data file** — `variant3d/assets/terrain/atlas/desert_remap.json` — holding
the donor `_misc_SetDesert` Summer→Desert name remap as **11 direct pairs + 1 height-gated
pair**, plus four labelled data-only fields (height gate, `koef=0.8`, mine suffix `s`, env
destruction) and generator weights. Every source key and every target resolves against the
read-only `presets_summer.json` / atlas manifest; all 12 pairs, all 12 source-png declarations
and the 111–122 desert packing were validated twice. No new art, no invented id, no shader,
loader, renderer, config or test edit, no donor read/copy/execute and no Godot job occurred.
Visual parity and donor runtime swap activity remain **UNVERIFIED**.

**No other file was edited.** The two files written are the JSON and this report. Pre-existing
working-tree changes by other builders (e.g. `data.gd`, `tile_atlas_loader.gd`, `world3d_terrain.gd`,
board docs and backups visible in `git status` at task start) were left untouched.

*End of SP-03. One JSON + one report written; no donor binary opened/copied/executed; no Godot
job; no code, art, config, test or other doc changed; visual parity not claimed.*
