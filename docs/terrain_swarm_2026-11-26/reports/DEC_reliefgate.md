---
id: DEC-RELIEFGATE
ticket: "TERRAIN-SWARM-2026-11-26 / DEC_reliefgate (worker DEC-RELIEFGATE)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__DONOR_READ_ONLY__NO_SOURCE_NO_GIT_NO_GODOT
scope: "Exactly one repo file written: this report. Donor at C:\\Games\\Cossacks 3 opened read-only (text reads only); no donor binary executed, copied, or installed; no repo source/asset/config/test/shader/queue/git/Godot state changed. No grid transcribed into this report; paths/offsets only."
labels: [O, D, U]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists. All grids below are static byte/text observations. No parity claim."
chain: "0/6"
result: "RESULT IS NOT GOOD"
---

# DEC_reliefgate — which donor recipe selects `plt2`, and whether the `plt2`/`k_ravine_1` gate is donor law or a gap

## 0. Verdict up front

1. **[O] `plt2` is selected by exactly one shipped-generator recipe: family `plateau`, member `Pattern = plt2`, `Freq = 1`** — `data/game/var/generator.cfg:581` (`Name = plateau`) / `:588-589` (`Pattern = plt2`, `Freq = 1`). It is stamped live by `data/scripts/common.inc/dogenerate.inc:1762` (`'plateau', plt/3`) in the **non-desert** branch (`:1755-1762`; `bDesert = (season=3)` per `:4`). Detail + conditions in §1.
2. **[O] All 15 sibling plateau members carry their OWN donor relief windows, and all 15 are already present in the repo as full `relief_float_grid` arrays.** `HeightFieldStand = True` re-read this ticket for every one of the 16 plateau patterns in `data/pattern/pattern.lib` (§2 table); every matching repo JSON carries `Stand: true`, a `grid_offset`, `w`/`h`, and a `relief_float_grid` array (§2 table). No new decode is needed.
3. **[D] The port's current gate (`game.gd:1574`: exact `plt2`/`k_ravine_1`) is a GAP per donor law, not donor law.** Donor law stamps height for all 16 plateau members; the gate honours 1 of the 16 reachable ones (`plt2`) plus 1 unreachable one (`k_ravine_1`, `//`-disabled at `dogenerate.inc:1760`). Run-180 `candidates=0` is a gate artefact, consistent with ANOM_reliefgrid.
4. **[O]+[D] A gate extension to the 14 remaining plateau names is byte-proven as a NAME+GRID set (§4), but ACTIVATION is BLOCKED on one owner condition:** per-pattern `RELIEF_GRID_META` (`scale/min/max`) values for the 14 siblings were NOT re-read from `pattern.lib` this ticket (only `Stand` was). The owner must transcribe `HeightFieldScale/Min/Max` per name before wiring. Exact blocked condition in §4. No code is written or proposed for execution here; no parity claim.

Parity: **UNVERIFIED**. Chain: **0/6**. **RESULT IS NOT GOOD.**

---

## 1. Which family/recipe selects `plt2`, and under what conditions — [O]

### 1.1 The recipe (byte-proven)

- [O] `data/game/var/generator.cfg:581`: `Name = plateau` opens the family block (`:581-603`).
- [O] `data/game/var/generator.cfg:588-589`: member `Pattern = plt2`, `Freq = 1` — uniform with its 4 siblings (`plt1` :584-585, `plt3` :592-593, `plt4_fixed` :596-597, `plt5` :600-601, each `Freq = 1`).
- [O] `data/pattern/pattern.lib:6776`: `Name = plt2`, `Width = 42, Height = 55` (`:6777-6778`); `HeightFieldStand = True` (`:6782`); `HeightFieldReplace = False` (`:6783`); `HeightFieldReplaceForWater = True` (`:6784`); `HeightFieldScale = 1` (`:6788`); `HeightFieldSmooth = False` (`:6792`); `HeightFieldMin = -0.0732548981904984` (`:6805`); `HeightFieldMax = 3.61341166496277` (`:6806`); `HeightFieldOffset = 0` (`:6807`).
- [O] `data/scripts/common.inc/dogenerate.inc:1762`: live (non-commented) stage-9 line stamps family `'plateau'` at density `plt/3`.
- [O] `variant3d/scripts/pattern_gen.gd:48`: port recipe `["plateau", "plt", 3.0, "plateau"]` maps to `dogenerate.inc:1762` (comment at `:34-37`).
- [O] `data/scripts/lib/map.script:112-113`: `StandPattern(envPlHnd, 'plt2', …)` ×2 — exact lowercase spelling, scripted placement independent of the generator draw.

### 1.2 The conditions (byte-proven, quoted)

- **Map-type / desert-vs-temperate:** the stamp at `:1762` sits in the `else` branch at `dogenerate.inc:1755-1756` (`else begin … mountains/plateau_big/plain_huge/ravine_big/plateau/plateau_small/hills_dark/hills_light`, `:1757-1765`). The `if` branch (`:1747-1754`) stamps only `desert_*` families. Branch key: `dogenerate.inc:4`: `var bDesert : Boolean = (gMap.settings.gen.season=3)`. So `plt2`-via-generator requires **non-desert, i.e. `season ≠ 3`** (any of the other season ids). The DEBUG run-180 `mediterranean/hills` configuration satisfies this.
- **Record-manager path:** stage-9 stamping at `:1743-1766` runs under `if (not bGenRecordManager)` (`:1743`); the record-manager replay path (`:1788-1798`) stamps by recorded name instead. So generator-drawn `plt2` requires **not-record-manager playback**.
- **Relief id:** `dogenerate.inc:1542`: `var relieftype : Integer = gMap.settings.gen.relieftype`; `:1621-1622`: `if (relieftype>4)` (random) `relieftype := floor(RandomExt*5)`; `:1624-1650`: `case relieftype of 0..4` sets `plt` density (`0.000010 / 0.000020 / 0.000075 / 0.000055 / 0.000090`), later scaled by `problarge` (`:1738`) and `areamod` (`:1702-1708`). **All five relief ids stamp the `plateau` family** — density varies, none is zero. Run-180 relief `hills` (id 1, `pattern_gen.gd:31` citing `dogenerate.inc:1631-1633`) therefore still draws from `plateau` (and from `plateau_small` `:1763`, `plateau_big` `:1758`).
- **Season flags on the pattern itself:** `pattern.lib:6808-6812`: `NativeSeason = Summer`, `Summer = True`, `Autumn = True`, `Winter = True`, `Spring = True`. No season excludes `plt2`.
- **Draw probability within the family:** `Freq = 1` for all five `plateau` members ⇒ `plt2` is **1 of 5 equiprobable outcomes per `plateau` stamp event**. Stamping the *family* (`plateau_big`/`plateau`/`plateau_small` display names in run 180) does **not** imply stamping the literal donor id `plt2`. This is exactly why `game.gd:1574` (exact-name match) counted zero.

### 1.3 `k_ravine_1` reachability (recap, byte-proven)

- [O] `generator.cfg:540-543`: `Name = ravine_medium` contains `Pattern = k_ravine_1` (`Freq = 1`).
- [O] `dogenerate.inc:1760`: `//_misc_SetupPatternsByType(pGenerator, envplHnd, 'ravine_medium'{'ravine_big'}, plt/3); // sand ravine` — commented out; live line `:1761` stamps `'ravine_big'` instead.
- [O] `pattern_gen.gd:34-37,43-52`: `RELIEF_RECIPES` has no `ravine_medium` entry (comment: "`ravine_medium` is `//`-disabled in the donor and stays absent").
- Consequence: the gate's second id can never match a donor-faithful run. Keeping it is harmless but inert.

---

## 2. Do the other plateau families carry their OWN donor windows, already in the repo — [O] yes, all 15

`HeightFieldStand` re-read this ticket at the `Name = …` section of every plateau pattern (each row: `Name` line, `Width/Height`, `HeightFieldStand = True` line). Repo columns: `flags.Stand`, `grid_offset` (`:58`), `h` (`:59`), `w` (tail line), `relief_float_grid` array line. Families index: `plateau` = `variant3d/assets/terrain_new/patterns/families/plateau.json` (`cfg_line 581`, patterns `:402-507`); `plateau_small` = `families/plateau_small.json` (`cfg_line 606`, patterns `:352-478`); `plateau_big` = `families/plateau_big.json` (`cfg_line 635`, patterns `:338-443`).

| Donor id | Donor `pattern.lib` Name / Stand (this ticket) | Donor WxH | Repo JSON `grid_offset` :58 / `h` :59 / `w` / `relief_float_grid` array |
|---|---|---|---|
| `plt1` | `:322` / `:328` | 38×53 | `patterns/plt1.json:58` G=1932, `:59` h=53, `:38662` w=38, `:36640` grid |
| `plt2` (gate) | `:6776` / `:6782` | 42×55 | `patterns/plt2.json:58` G=2222, `:59` h=55, `:44468` w=42, `:42150` grid |
| `plt3` | `:13510` / `:13516` | 58×63 | `patterns/plt3.json:58` G=3542, `:59` h=63, `:70892` w=58, `:67230` grid |
| `plt4_fixed` | `:78064` / `:78070` | 41×56 | `patterns/plt4_fixed.json:58` G=2208, `:59` h=56, `:44188` w=41, `:41884` grid |
| `plt5` | `:24416` / `:24422` | 41×59 | `patterns/plt5.json:58` G=2328, `:59` h=59, `:46591` w=41, `:44164` grid |
| `d_plt1` | `:89460` / `:89466` | 51×63 | `patterns/d_plt1.json:58` G=3108, `:59` h=63, `:62205` w=51, `:58984` grid |
| `d_plt2` | `:94570` / `:94576` | 57×58 | `patterns/d_plt2.json:58` G=3200, `:59` h=58, `:64046` w=57, `:60732` grid |
| `d_plt3` | `:100660` / `:100666` | 65×53 | `patterns/d_plt3.json:58` G=3336, `:59` h=53, `:66769` w=65, `:63316` grid |
| `d_plt4` | `:107982` / `:107988` | 45×61 | `patterns/d_plt4.json:58` G=2648, `:59` h=61, `:52997` w=45, `:50244` grid |
| `d_plt5` | `:113092` / `:113098` | 63×62 | `patterns/d_plt5.json:58` G=3790, `:59` h=62, `:75856` w=63, `:71942` grid |
| `d_plt6` | `:118566` / `:118572` | 59×57 | `patterns/d_plt6.json:58` G=3256, `:59` h=57, `:65167` w=59, `:61796` grid |
| `f_plt_big_1` | `:272110` / `:272116` | 81×93 | `patterns/f_plt_big_1.json:58` G=7368, `:59` h=93, `:147465` w=81, `:139924` grid |
| `f_plt_big_2` | `:308342` / `:308348` | 66×68 | `patterns/f_plt_big_2.json:58` G=4363, `:59` h=68, `:87325` w=66, `:82829` grid |
| `f_plt_big_3` | `:283912` / `:283918` | 70×86 | `patterns/f_plt_big_3.json:58` G=5873, `:59` h=86, `:117547` w=70, `:111519` grid |
| `f_plt_mid_1` | `:297086` / `:297092` | 49×51 | `patterns/f_plt_mid_1.json:58` G=2408, `:59` h=51, `:48191` w=49, `:45684` grid |
| `f_plt_mid_2` | `:302952` / `:302958` | 45×53 | `patterns/f_plt_mid_2.json:58` G=2296, `:59` h=53, `:45949` w=45, `:43556` grid |
| `k_ravine_1` (gate, unreachable) | `:549556` / `:549562` | 46×63 | `patterns/k_ravine_1.json:58` G=2798, h=63 (ANOM E16) |

Notes (all [O] unless marked):

- Every repo JSON above also carries `"Stand": true` (`:54`) and `"grid_layout": "h x w row-major f32 at G=8+(w-1)*(h-1)"` (`:57`), with `byte_closure.ok = true` (e.g. `plt2.json:2-43`); grid semantics/engine blend stay [U] (label at each file's `:75-76`, X23 §3/§9 Q3).
- `families/plateau.json:2` (`cfg_line 581`), `families/plateau_small.json:2` (`cfg_line 606`), `families/plateau_big.json:2` (`cfg_line 635`) confirm the three family→member mappings byte-consistently with `generator.cfg:581-603`, `:606-632`, `:635-657`.
- Recipe membership of the siblings: `generator.cfg:584-601` (plateau 5×Freq 1), `:609-630` (plateau_small 6×Freq 1), `:638-655` (plateau_big: big Freq 3 / mid Freq 2). All three families are stamped live in the non-desert branch: `dogenerate.inc:1758` (`plateau_big` plt/3), `:1762` (`plateau` plt/3), `:1763` (`plateau_small` plt/3). Hence run-180 stamps of `plateau_big`/`plateau`/`plateau_small` draw from the 16 ids above — 15 of which the gate ignores.

---

## 3. Is the port's current gate CORRECT per donor law — [D] no, it is a gap

- [O] Gate: `variant3d/scripts/game.gd:1571-1574` reads `donor_name = str(st.get("name"))` and matches **only** `"plt2" or "k_ravine_1"`; `:1589-1590` increments `relief_grid_candidates` only when a grid was found. Loader: `game.gd:1487-1504` (`_load_full_relief_grid`, path `res://assets/terrain_new/patterns/<name>.json`, size-checked `w*h`); sampler `:1507-1526` (bilinear, labelled PORT APPROXIMATION at `:1509-1511`).
- [D] Per donor law (§1–§2), **16 of 16** plateau ids stamp donor height (`HeightFieldStand = True`); the generator draws all of them on the run-180 configuration (non-desert, relief id 1, families at `:1758/:1762/:1763`). The gate honours **1 reachable** (`plt2`) + **1 unreachable** (`k_ravine_1`). Any run whose plateau draws resolve to the other 15 ids — the expected case for 92 plateau-family stamps at 1/5–1/6 per-id odds — reports `candidates=0` while donor law did height work. That is exactly the run-180 observation.
- [O] Narrow correctness retained: the two ids the gate names do have correct decoded windows (`plt2` G=2222 42×55, `k_ravine_1` G=2798 46×63; `game.gd:158-161,166-169`; ANOM §4). The gate is therefore *internally consistent* (no false positives) but *donor-incomplete* (systematic false negatives). Extending the gate needs no new decode — only name recognition plus per-id meta.

---

## 4. Gate-extension specification vs BLOCKED condition

### 4.1 Byte-proven extension SET (names + grid pointers) — [O]

The following 14 literal donor ids are proven (i) members of live-stamped families, (ii) `HeightFieldStand = True` in `pattern.lib`, and (iii) present as full `relief_float_grid` arrays at the listed offsets:

`plt1`, `plt3`, `plt4_fixed`, `plt5`, `d_plt1`, `d_plt2`, `d_plt3`, `d_plt4`, `d_plt5`, `d_plt6`, `f_plt_big_1`, `f_plt_big_2`, `f_plt_big_3`, `f_plt_mid_1`, `f_plt_mid_2` — evidence: §2 table (donor line + repo path:line + G + dims per id).

Mechanically (for the owner/builder, NOT executed here): the existing loader at `game.gd:1487-1504` already resolves any of these names to its full grid by file path (`res://assets/terrain_new/patterns/<name>.json`) with a `w*h` size check, so the only functional change is name recognition at `game.gd:1574` plus one `RELIEF_GRID_META` entry per id (cf. existing entries at `game.gd:166-169`). No new binary decode, no invented grid.

### 4.2 BLOCKED: exact owner condition before activation — [U]→owner read required

- **BLOCKED:** per-pattern `RELIEF_GRID_META` values (`scale`, `min`, `max`, and any `ReplaceForWater` handling) for the 14 ids above were **not** re-read from `pattern.lib` this ticket. Only `Stand` lines were read (§2). The single fully-proven META row remains `plt2` (`pattern.lib:6783-6788,6805-6807`; `game.gd:169`).
- **Owner condition to unblock:** for each of the 14 ids, read and quote `HeightFieldScale`, `HeightFieldMin`, `HeightFieldMax` (and `HeightFieldReplace`/`ReplaceForWater`) from its `pattern.lib` section (Name lines in §2 table; values sit within ~+30 lines as in the `plt2` `:6776-6807` exemplar), then transcribe into `RELIEF_GRID_META`. Until that is on record, wiring the extension would attach UNVERIFIED meta to byte-proven grids.
- **Standing [U] (unchanged by this ticket):** interpolation kernel and file-row→map-row sign remain UNVERIFIED (`game.gd:1509-1511`; X23 §3/§9 Q3); any extension inherits the existing PORT APPROXIMATION label. No parity claim.

---

## 5. Evidence index (all [O] unless marked)

| # | Path:line | Class | What it establishes |
|---|---|---|---|
| E1 | `data/game/var/generator.cfg:581-603` | [O] | `plateau` family; `plt2` at `:588-589` Freq 1 among 5 |
| E2 | `data/game/var/generator.cfg:606-632` | [O] | `plateau_small` family; `d_plt1..6` Freq 1 |
| E3 | `data/game/var/generator.cfg:635-657` | [O] | `plateau_big` family; big Freq 3 / mid Freq 2 |
| E4 | `data/scripts/common.inc/dogenerate.inc:4` | [O] | `bDesert = (season=3)` |
| E5 | `data/scripts/common.inc/dogenerate.inc:1542,1621-1650` | [O] | `relieftype` source; random reroll; ids 0-4 `plt` densities |
| E6 | `data/scripts/common.inc/dogenerate.inc:1743-1766` | [O] | Non-record-manager stage 9; desert vs non-desert branches; live `plateau_big :1758`, `plateau :1762`, `plateau_small :1763`; `ravine_medium //` at `:1760` |
| E7 | `data/pattern/pattern.lib:322/:328`, `:6776/:6782-6807`, `:13510/:13516`, `:78064/:78070`, `:24416/:24422` | [O] | `plt1..5` Stand True; `plt2` full flag/min/max/offset set |
| E8 | `data/pattern/pattern.lib:89460/:89466`, `:94570/:94576`, `:100660/:100666`, `:107982/:107988`, `:113092/:113098`, `:118566/:118572` | [O] | `d_plt1..6` Stand True (this ticket) |
| E9 | `data/pattern/pattern.lib:272110/:272116`, `:308342/:308348`, `:283912/:283918`, `:297086/:297092`, `:302952/:302958` | [O] | `f_plt_big_1/2/3`, `f_plt_mid_1/2` Stand True (this ticket) |
| E10 | `data/pattern/pattern.lib:549556/:549562` | [O] | `k_ravine_1` 46×63 Stand True |
| E11 | `data/pattern/pattern.lib:6808-6812` | [O] | `plt2` all four seasons True |
| E12 | `data/scripts/lib/map.script:112-113` | [O] | Scripted `StandPattern(…, 'plt2', …)` spelling |
| E13 | `variant3d/assets/terrain_new/patterns/{plt1,plt3,plt4_fixed,plt5,d_plt1..6,f_plt_big_1..3,f_plt_mid_1..2}.json:58-59` + w/grid lines | [O] | Full grids present (G, h, w, array — §2 table) |
| E14 | `variant3d/scripts/game.gd:1487-1504,1507-1526,1571-1590` | [O] | Generic full-grid loader; bilinear sampler; two-id gate; candidate counter |
| E15 | `variant3d/scripts/game.gd:158-169` | [O] | G=2798/2222 windows; existing two META rows |
| E16 | `variant3d/scripts/pattern_gen.gd:25-52` | [O] | Relief-id densities; recipes incl. `plateau :48`, `plateau_small :49`, `plateau_big :45`; `ravine_medium` absent `:34-37` |
| E17 | `…/families/plateau.json:2,402-507`; `plateau_small.json:2,352-478`; `plateau_big.json:2,338-443` | [O] | Family→member index consistent with `generator.cfg` |
| E18 | `docs/terrain_swarm_2026-11-26/reports/ANOM_reliefgrid.md:18-36,120-139` | [O]+[D] | Zero-candidate = gate artefact; `k_ravine_1` BLOCKED |

## 6. Open / UNVERIFIED

- U1. Per-seed stamp-name census for run 180 (which exact `plt*`/`d_plt*`/`f_plt_*` ids the 92 stamps carried) — taken from the task statement; not re-derived here.
- U2. Per-pattern `HeightFieldScale/Min/Max/ReplaceForWater` for the 14 extension ids — the §4.2 owner read.
- U3. Blend kernel, row-sign, smooth-port behaviour, clamp consumers — UNVERIFIED (X23 §3/§9 Q3; `game.gd:1509-1511`).
- U4. Desert-branch plateau equivalents (`desert_plateau`, `desert_plateau_small`, `desert_plateau_big` at `dogenerate.inc:1750-1753`) — out of scope for the run-180 question; no claim.

*End of DEC_reliefgate. Exactly one repo file written. Donor read-only; no code, no Godot, no git, no donor execution. Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD.*
