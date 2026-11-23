# T6-S03 — Donor smoothing chains (all 22) vs the port's 10 Summer chains

**Ticket:** T6-S03 (LANE RESEARCH, read-only). **Executed by:** T6-RESEARCH parent
directly (no child session; SWARM_OPS.md §7.2). **Date:** 2026-11-23.
**Boundaries:** private use only; donor never executed; no donor file copied into
the repo; no Godot job; no code/asset edit.

**Labels:** `observed` = parsed literal line / file content; `derived` =
structural/arithmetic consequence; `inferred` = plausible reading with caveat;
`UNVERIFIED` = not proven by the files read.

**Baseline read first:** `docs/audit/TERRAIN_BLEND_DONOR_PLAN.md` (§2.1, D4),
which reported 22 sections (10 Summer + 10 Winter + 2 empty terminators) and a
faithful port copy of the 10 Summer chains. This ticket **fully transcribes**
them, re-diffs the port data byte-for-entry, and states exactly what is missing.

---

## 1. Sources and method

| Source | Role |
|---|---|
| `C:\Games\Cossacks 3\data\gen\tilesmooth_scripts.cfg` | 64,017 B, **1,863 lines** — the probability tables actually consumed by `smoothtiles.inc:5` |
| `app\assets\terrain\structs\smooth_summer.json` | port's 10 chains (single-line JSON) |
| `app\scripts\game.gd:1139-1141, 1149-1200, 1418-1422, 1500-1589` | port loader + smoother + winter art mapping (read-only) |
| `data\scripts\common.inc\smoothtiles.inc:237` | donor invokes `SmoothTileMap(...,3)` |

**Method (independent re-derivation):** a read-only Python parser
(`%TEMP%\opencode\t6_parse_smooth.py`, outside the repo) stripped `//`
comments, tracked `struct.begin/end` nesting, and emitted each
`SmoothTiles` section with its groups, ordered `(TileName, Prob)` pairs and
source line numbers. A second script compared the parsed Summer chains to the
port JSON entry-by-entry (names and probabilities, float-rounded to 6 dp) and
compared each Winter chain to its Summer counterpart after stripping the
`_winter` suffix. Python command used: `python` (3.14), never `python3`.

---

## 2. Structural census (`observed`)

| Section | First line | Groups | Entries | Season | `Prob=0` names |
|---:|---:|---:|---:|---|---|
| C00 | 4 | 4 | 15 | Summer | rock9, rock8, rock5 |
| C01 | 98 | 6 | 17 | Summer | — |
| C02 | 194 | 6 | 16 | Summer | — |
| C03 | 286 | 9 | 18 | Summer | — |
| C04 | 398 | 9 | 20 | Summer | — |
| C05 | 519 | 8 | 18 | Summer | — |
| C06 | 628 | 6 | 19 | Summer | — |
| C07 | 733 | 3 | 4 | Summer | test8 |
| C08 | 781 | 3 | 5 | Summer | — |
| C09 | 817 | 5 | 9 | Summer | — |
| **C10** | 881 | **0** | 0 | terminator | — |
| C11 | 934 | 4 | 15 | Winter | rock9_winter, rock8_winter, rock5_winter |
| C12 | 1028 | 6 | 17 | Winter | — |
| C13 | 1124 | 6 | 16 | Winter | — |
| C14 | 1216 | 9 | 18 | Winter | — |
| C15 | 1328 | 9 | 20 | Winter | — |
| C16 | 1449 | 8 | 18 | Winter | — |
| C17 | 1558 | 6 | 19 | Winter | — |
| C18 | 1663 | 3 | 4 | Winter | test8_winter |
| C19 | 1711 | 3 | 5 | Winter | — |
| C20 | 1747 | 5 | 9 | Winter | — |
| **C21** | 1811 | **0** | 0 | terminator | — |

Group counts for Summer C00–C09 =
`[4,6,6,9,9,8,6,3,3,5]`, total **141 entries**; identical to the port's
`smooth_summer.json` group counts (`observed`, parser output). Donor Summer
entry total = **141**; port entry total = **141**.

The commented-out `sandrock` group in C00 (`tilesmooth_scripts.cfg:37-50`) is
correctly **absent** from both the donor parse and the port chain 0.

---

## 3. Full transcription of all 22 chains (`observed`)

Notation: `C<nn> [Season] line <n>` then groups in order, each `{name=prob, …}`
separated by ` ; `. `Prob = 0` entries are legal endpoints but never roulette
picks (`TERRAIN_BLEND_DONOR_PLAN.md §2.2`, donor `smoothtiles.inc:112-121`).

### Summer (consumed by the port)

**C00 [SUMMER] line 4** (4 groups)
`{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ;
`{sandsea5=0.7, sandsea6=0.3}` ;
`{rock9=0, rock8=0, rock5=0}` ;
`{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.2}`

**C01 [SUMMER] line 98** (6 groups)
`{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ;
`{sandsea5=0.7, sandsea6=0.3}` ;
`{sandrock1=0.4, sandrock3=0.6}` ;
`{sandrock4=0.6, sandrock2=0.4}` ;
`{grass1=1, grass2=1, test8=1}` ;
`{grass7=0.25, test12=0.25, test13=0.25, test14=0.25}`

**C02 [SUMMER] line 194** (6 groups)
`{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ;
`{sandsea5=0.7, sandsea6=0.3}` ;
`{sandrock1=0.4, sandrock3=0.6}` ;
`{sandrock4=0.6, sandrock2=0.4}` ;
`{grass1=1, grass2=1, test8=1}` ;
`{test7=1, grass8=1, test6=1}`

**C03 [SUMMER] line 286** (9 groups)
`{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ;
`{sandsea5=0.7, sandsea6=0.3}` ;
`{sandrock1=0.4, sandrock3=0.6}` ;
`{sandrock4=0.6, sandrock2=0.4}` ;
`{grass1=1, grass2=1, test8=1}` ;
`{grass9=1}` ; `{test9=1}` ; `{grass3=1}` ;
`{grass4=0.9, grass10=0.1}`

**C04 [SUMMER] line 398** (9 groups)
`{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.2}` ;
`{rock8=0.5, rock5=0.5}` ; `{rock9=1}` ;
`{grass_ground1=0.64, grass_ground2=0.0028, grass_ground3=0.36}` ;
`{grass1=1, grass2=1, test8=1}` ;
`{grass9=1}` ; `{test9=1}` ; `{grass3=1}` ;
`{grass4=0.9, grass10=0.1}`

**C05 [SUMMER] line 519** (8 groups)
`{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.2}` ;
`{rock8=0.5, rock5=0.5}` ; `{rock9=1}` ;
`{grass_ground1=0.64, grass_ground2=0.0028, grass_ground3=0.36}` ;
`{grass1=1, grass2=1, test8=1}` ;
`{test7=1}` ; `{grass8=1}` ; `{test6=1}`

**C06 [SUMMER] line 628** (6 groups)
`{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.2}` ;
`{rock8=0.5, rock5=0.5}` ; `{rock9=1}` ;
`{grass_ground1=0.64, grass_ground2=0.0028, grass_ground3=0.36}` ;
`{grass1=1, grass2=1, test8=1}` ;
`{grass7=0.25, test12=0.25, test13=0.25, test14=0.25}`

**C07 [SUMMER] line 733** (3 groups)
`{rock9=1, test8=0}` ; `{grass5=1}` ; `{grass6=1}`

**C08 [SUMMER] line 781** (3 groups)
`{rock9=1}` ; `{grass5=1}` ;
`{grass_ground1=0.36, grass_ground2=0.28, grass_ground3=0.36}`

**C09 [SUMMER] line 817** (5 groups)
`{ground1=1}` ; `{test2=1}` ; `{test1=1, test3=1}` ;
`{test8=0.4, test7=0.6}` ; `{grass1=1, grass2=1, test8=1}`

### Empty terminator

**C10 [EMPTY] line 881** — `SmoothTiles` struct with **no groups** (a bound/end
marker for the 64-item `Items[0..63]` array in `smoothtiles.inc:117`, not a
chain with data).

### Winter (NOT present in the port)

**C11 [WINTER] line 934** (4 groups)
`{sandsea1_winter=1, sandsea2_winter=1, sandsea3_winter=1, sandsea4_winter=1}` ;
`{sandsea5_winter=0.7, sandsea6_winter=0.3}` ;
`{rock9_winter=0, rock8_winter=0, rock5_winter=0}` ;
`{rock1_winter=0.16, rock2_winter=0.16, rock3_winter=0.16, rock6_winter=0.16, rock7_winter=0.16, rock4_winter=0.2}`

**C12 [WINTER] line 1028** (6 groups) — Summer C01 structure, all names
`_winter`-suffixed:
`{sandsea1_winter=1, … sandsea4_winter=1}` ;
`{sandsea5_winter=0.7, sandsea6_winter=0.3}` ;
`{sandrock1_winter=0.4, sandrock3_winter=0.6}` ;
`{sandrock4_winter=0.6, sandrock2_winter=0.4}` ;
`{grass1_winter=1, grass2_winter=1, test8_winter=1}` ;
`{grass7_winter=0.25, test12_winter=0.25, test13_winter=0.25, test14_winter=0.25}`

**C13 [WINTER] line 1124** (6 groups) — C02 structure: same four leading groups
as C12, then `{test7_winter=1, grass8_winter=1, test6_winter=1}`.

**C14 [WINTER] line 1216** (9 groups) — C03 structure: four leading groups,
`{grass1_winter=1, grass2_winter=1, test8_winter=1}`, then
`{grass9_winter=1}`, `{test9_winter=1}`, `{grass3_winter=1}`,
`{grass4_winter=0.9, grass10_winter=0.1}`.

**C15 [WINTER] line 1328** (9 groups) — C04 structure:
`{rock1_winter=0.16, … rock4_winter=0.2}` ;
`{rock8_winter=0.5, rock5_winter=0.5}` ; `{rock9_winter=1}` ;
`{grass_ground1_winter=0.64, grass_ground2_winter=0.0028, grass_ground3_winter=0.36}` ;
`{grass1_winter=1, grass2_winter=1, test8_winter=1}` ;
`{grass9_winter=1}`, `{test9_winter=1}`, `{grass3_winter=1}`,
`{grass4_winter=0.9, grass10_winter=0.1}`.

**C16 [WINTER] line 1449** (8 groups) — C05 structure: four rock/ground groups
as C15, then `{grass1_winter=1, grass2_winter=1, test8_winter=1}`,
`{test7_winter=1}`, `{grass8_winter=1}`, `{test6_winter=1}`.

**C17 [WINTER] line 1558** (6 groups) — C06 structure: four rock/ground groups
as C15, then `{grass1_winter=1, grass2_winter=1, test8_winter=1}` and
`{grass7_winter=0.25, test12_winter=0.25, test13_winter=0.25, test14_winter=0.25}`.

**C18 [WINTER] line 1663** (3 groups)
`{rock9_winter=1, test8_winter=0}` ; `{grass5_winter=1}` ; `{grass6_winter=1}`

**C19 [WINTER] line 1711** (3 groups)
`{rock9_winter=1}` ; `{grass5_winter=1}` ;
`{grass_ground1_winter=0.36, grass_ground2_winter=0.28, grass_ground3_winter=0.36}`

**C20 [WINTER] line 1747** (5 groups)
`{ground1_winter=1}` ; `{test2_winter=1}` ; `{test1_winter=1, test3_winter=1}` ;
`{test8_winter=0.4, test7_winter=0.6}` ;
`{grass1_winter=1, grass2_winter=1, test8_winter=1}`

### Empty terminator

**C21 [EMPTY] line 1811** — no groups; file ends at line 1863.

> **Structural identity (derived, exact):** for every `i` in 0..9, chain
> `C(i+11)` equals `Ci` after replacing every name `n` with `n_winter`, with
> **identical group boundaries and identical probabilities** (parser check:
> `names_equal=True probs_equal=True` for all 10 pairs). This is strong evidence
> that the Winter set is a mechanical mirror of the Summer set, not a separate
> authoring effort.

---

## 4. Diff against the port

### 4.1 Summer — exact match (`observed`)

| Check | Donor C00–C09 | Port `smooth_summer.json` | Verdict |
|---|---|---|---|
| Chain count | 10 | 10 | equal |
| Group counts | `[4,6,6,9,9,8,6,3,3,5]` | `[4,6,6,9,9,8,6,3,3,5]` | equal |
| Total entries | 141 | 141 | equal |
| Entry-by-entry (name + prob, 6 dp) | — | — | **0 mismatches** |
| `Prob=0` names | rock9, rock8, rock5, test8 | rock9, rock8, rock5, test8 | equal |
| Commented `sandrock` group (`:37-50`) | excluded | absent | equal |

The port's Summer smoothing data needs **no regeneration**. This independently
re-verifies TERRAIN_BLEND_DONOR_PLAN.md D4 at entry granularity (that audit
compared counts; this one compares every name and probability).

### 4.2 What is missing (the exact answer)

| Donor section(s) | Lines | In port? | Content missing |
|---|---|---|---|
| C11–C20 | 934–1810 | **No** | 10 Winter chains, 141 entries total (same structure/probabilities as Summer with `_winter`-suffixed names) |
| C10, C21 | 881, 1811 | **No** | 2 empty `SmoothTiles` structs; these carry **no data** and are array terminators — their absence is harmless |
| C00 commented group | 37–50 | No (correct) | `sandrock1/3/4/2` group is commented out in the donor; not a real chain entry |

There is **no `smooth_winter.json` anywhere in the port** (filesystem search of
`app\assets\terrain\structs\`). `game.gd:1139-1141` loads only
`smooth_summer.json` into `tbl_smooth`, and `game.gd:1500-1589` uses that same
`tbl_smooth` for every season; winter behaviour is handled by a separate
**art-name alias map** `WINTER_ART` (`game.gd:1149-1189`) and
`winter_tile_names` (`:1193,1418-1422`) that maps each summer tile name to
`winterN` textures while leaving `tileblock` indices (and hence smoothing)
unchanged. This is `observed` from source.

### 4.3 Does the gap change behaviour? (careful separation)

- **Derived:** because the donor Winter chains are an exact structural mirror
  of the Summer chains (`_winter` suffix only) and the donor Winter preset is a
  1:1 alias of the Summer preset (`game.gd:1143-1148` comment, citing
  `tiles.mat`), smoothing **indices** with the Summer probability table is
  structurally equivalent to smoothing with the Winter table, provided the
  alias mapping preserves group membership.
- **Inferred (not proven):** the port's `WINTER_ART` maps to `winterN` art, not
  to the donor's literal `<name>_winter` chain names. If a future build uses
  the donor's literal winter tile names, the Summer table's names will not
  match and compatibility decisions would be lost. This is a *data-model*
  divergence, not a currently observed visual defect.
- **UNVERIFIED:** whether the donor ever selects the Winter `SmoothTiles`
  sections at runtime for winter maps (plaintext shows both sets in one file;
  no script call selects between them by season was found). Do not assert that
  the port is wrong here.

---

## 5. Claim table

| # | Claim | Evidence | Method | Status |
|---|---|---|---|---|
| 1 | `tilesmooth_scripts.cfg` has 22 `SmoothTiles` sections: C00–C09 Summer, C10 empty, C11–C20 Winter, C21 empty | parser, lines 4…1811 | parse + read | **observed** |
| 2 | Full transcription in §3 is exact (names, probs, order, line starts) | `tilesmooth_scripts.cfg` | parse | **observed** |
| 3 | Port Summer chains are an exact 141-entry copy of C00–C09 | parser vs `smooth_summer.json` | entry diff | **observed** (0 mismatches) |
| 4 | Commented `sandrock` group is correctly absent | cfg:37-50; port chain 0 | read | **observed** |
| 5 | Winter chains are byte-structural mirrors of Summer under `_winter` suffix | parser pair check | derived | **derived (exact)** |
| 6 | Port has no Winter chain data and always smooths with Summer table | `game.gd:1139-1141,1500-1589`; filesystem | read | **observed** |
| 7 | Two empty terminators carry no data | parser | read | **observed** |
| 8 | Port's Summer-table use is behaviourally equivalent for winter maps | #5 + preset alias comment | chained | **inferred** — conditional on alias preserving group membership |
| 9 | Donor runtime selects Winter sections for winter maps | — | — | **UNVERIFIED** |

---

## 6. Hand-off to builders

1. **No action for Summer** — `smooth_summer.json` is confirmed exact; do not
   regenerate it.
2. **If the UNITS/TERRAIN lanes add a literal winter tile-name path**, add a
   `smooth_winter.json` transcribed verbatim from C11–C20 (lines 934–1810) and
   load it when winter is active; do **not** invent new chains. Until then,
   document the current Summer-table-for-all-seasons behaviour as an
   `inferred`-equivalent approximation, not a proven donor match.
3. Keep the two empty terminators out of any port data file — they are array
   padding, not chains.
4. The `Prob=0` names (`rock9`, `rock8`, `rock5`, `test8` and their `_winter`
   forms) must remain `0`: they are valid endpoints but never roulette picks
   (`smoothtiles.inc:112-121`). Do not "fix" them to positive probabilities.

No donor asset was copied; no donor executable was run; no code was changed.
