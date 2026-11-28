---
id: ANOM-RELIEFGRID
ticket: "TERRAIN-SWARM-2026-11-26 / ANOM_reliefgrid (worker ANOM-RELIEFGRID)"
date: 2026-11-27
status: DELIVERED__ONE_REPORT_ONLY__DONOR_READ_ONLY__NO_SOURCE_NO_GIT_NO_GODOT
scope: "Exactly one repo file written: this report. Donor at C:\\Games\\Cossacks 3 opened read-only (text reads only); no donor binary executed, copied, or installed; no repo source/asset/config/test/shader/queue/git/Godot state changed."
labels: [O, D, U]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists. All grids below are static byte/text observations. No parity claim."
chain: "0/6"
result: "RESULT IS NOT GOOD"
---

# ANOM_reliefgrid — why `--dump-map` reports `candidates=0, applied_cells=0`

## 0. Verdict up front

1. **[O] The zero-candidate state on seed 20261113 is correct *per the port's current gate*,
   and it is NOT correct per donor law.** `game.gd:1533-1540` only counts a stamp when
   `st.get("name")` is exactly `"plt2"` or `"k_ravine_1"`. The DEBUG run's 92 stamps used
   family display names (`plateau_big` / `plain_huge` / `ravine_big` / `plateau` /
   `hills_dark` / `hills_light`); none of its stamp `name` fields was the literal `plt2`,
   and `k_ravine_1` can never appear (§3). So `candidates=0` follows from the gate.
2. **[O]+[D] Donor law says that run SHOULD have had relief-grid work:** every stamped
   family whose members were read this ticket carries `HeightFieldStand = True` with a
   full `w*h` float32 relief window (§1). The gate ignores all of them except two ids.
3. **[O]+[D] The port's two grid constants are the STALE shifted windows, not the decoded
   donor windows.** `game.gd:125` cites `DPATTERN_01 Appendix A1/A2`, and `game.gd:158-161`
   pins the stale offsets `2866` / `2266`. X23 proves the true windows are `2798` / `2222`
   (shifts +68/+44 B, §4). Correct full windows for both ids already sit in the repo's
   pattern JSONs (§5). No value is invented here; no grid is transcribed into this report.
4. **[O] The exact missing grids are named in §6.** The largest single gap for the observed
   run is `k_ravine_big_stone_1` (`data/pattern/pattern.lib:730016`, grid `G=8225`) for the
   `ravine_big` stamps the donor generator places at `dogenerate.inc:1761`.

Parity: **UNVERIFIED**. Chain: **0/6**. **RESULT IS NOT GOOD.**

---

## 1. Which donor pattern NAMES carry relief/height grids — [O]

Byte-proven this ticket by direct read of `data/pattern/pattern.lib` sections
(`Name = …` line, then `HeightFieldStand = True` within the same prologue).
Every row below was read, not inferred:

| Donor pattern name | `pattern.lib` Name line | `HeightFieldStand = True` line | Dims / Min-Max lines (same section) | Donor family (`generator.cfg`) |
|---|---|---|---|---|
| `plt1` | :322 | :328 | `Width = 38, Height = 53` (:323-324) | `plateau` (:584) |
| `plt2` | :6776 | :6782 | `42 x 55`; Min :6805, Max :6806 | `plateau` (:588) |
| `hil1` | :33082 | :33088 | `25 x 41`; Min :33111, Max :33112 | `hills_dark` (:696) |
| `g_hil4` | :366470 | :366476 | `33 x 59`; Min :366499, Max :366500 | `hills_light` (:729) |
| `k_ravine_1` | :549556 | :549562 | `46 x 63`; Min :549585, Max :549586 | `ravine_medium` (:543) |
| `k_ravine_big_stone_1` | :730016 | :730022 | `84 x 100`; Min :730045, Max :730046 | `ravine_big` (:506) |

Further [O] flag detail read in the same prologues:

- `plt2`: `HeightFieldReplace = False` (:6783), `HeightFieldReplaceForWater = True` (:6784),
  `HeightFieldScale = 1` (:6788), `HeightFieldSmooth = False` (:6792),
  `Offset = 0` (:6807) — `pattern.lib:6776-6807`.
- `k_ravine_1`: `Replace = False` (:549563), `ReplaceForWater = True` (:549564),
  `Scale = 1` (:549568), `Smooth = False` (:549572), `Offset = 0` (:549587) —
  `pattern.lib:549556-549587`.
- `hil1`: `Scale = 0.649999976158142` (:33094), `ReplaceForWater = True` (:33090),
  `Smooth = False` (:33098) — `pattern.lib:33082-33113`.
- `g_hil4`: `Smooth = True`, `SmoothRadius = 3`, `SmoothFactor = 4`, `SmoothOffset = 2`
  (:36486-36489 sic :366486-366489), `ReplaceForWater = True` (:366478) —
  `pattern.lib:366470-366501`.
- `k_ravine_big_stone_1`: `Smooth = True` (:730032), `Replace = False` (:730023),
  `ReplaceForWater = False` (:730024) — `pattern.lib:730016-730047`.

**[U] explicitly NOT proven this ticket:** the `HeightFieldStand` flag of the sibling
members (`plt3`, `plt4_fixed`, `plt5`, `d_plt1..6`, `f_plt_big_1..3`, `f_plt_mid_1..2`,
`g_mnt_1..7`, `hil2..4`, `g_hil1..9`, `k_ravine_2..9`, `k_ravine_big_stone_2..8`).
Their *names* are [O] in `generator.cfg:503-752` (`ravine_big` :503-537, `ravine_medium`
:540-579, `plateau` :581-604, `plateau_small` :606-633, `plateau_big` :635-658,
`mountains` :660-691, `hills_dark` :693-712, `hills_light` :714-753), but their Stand
flags were not re-read here, so any claim that "all 40+ members stamp height" stays [U].
What is [O] is sufficient for the anomaly: **each stamped family in the DEBUG run has at
least one member proven above to carry a donor height grid, and the port gate matches
none of those members.**

---

## 2. Is `plt2` a real, reachable shipped-generator recipe name — [O] yes

Spelling is lowercase **`plt2`** in every donor text read:

- `data/pattern/pattern.lib:6776`: `Name = plt2` (section `Width = 42, Height = 55`).
- `data/game/var/generator.cfg:588`: `Pattern = plt2` inside `Name = plateau` (:581),
  with `Freq = 1` (:589).
- `data/scripts/lib/map.script:112-113`: `StandPattern(envPlHnd, 'plt2', …)` — twice,
  exact lowercase spelling.
- `data/scripts/common.inc/dogenerate.inc:1762`: the live (non-commented) stage-9 line
  stamps family `'plateau'` at `plt/3`. `plateau` is the family that contains `plt2`
  (`generator.cfg:581-603`), so `plt2` is reachable through the shipped generator.
  Contrast `ravine_medium` at `dogenerate.inc:1760`, which is `//`-commented out
  (see §3).

Port-side reachability is independently [O]:

- `variant3d/assets/terrain/patterns/donor_patterns.json` (line 1): `plateau` family
  contains `["plt1",1],["plt2",1],["plt3",1],["plt4_fixed",1],["plt5",1]`; source field
  cites donor `data/pattern/*.pattern + data/game/var/generator.cfg`.
- `variant3d/scripts/pattern_gen.gd:48`: `["plateau", "plt", 3.0, "plateau"]` is in
  `RELIEF_RECIPES`; `:32` comment maps it to `dogenerate.inc:1762`.
- RELIEF-02 (`docs/coord_swarm_2026-11-25/reports/RELIEF_02_stamp_marker.md:44-66`):
  `plt2` present with Freq 1.0; marker emission donor-grounded.
- RELIEF-SEED-SCAN-01 (`SWARM_BOARD.md:429`): offline seed **20261150** / relief `plains`
  places donor-grounded `plt2` at (54,33) → `candidates 1 / applied_cells 443`;
  confirmed at runtime by RELIEF-SEED-PROBE-01 (job 565, height+tileblock SHA changed).

**`generatemap.inc` spelling note [O] negative:** no `generatemap.inc` file was located
under `data/scripts` this ticket (only reference found: `data/scripts/common.aix:73`
`UsedFileName = .\data\scripts\common.inc\generatemap.inc`). No spelling claim is made
for that file. The spellings above (`pattern.lib`, `generator.cfg`, `map.script`,
`dogenerate.inc` family name) are all exactly `plt2` / `plateau`.

---

## 3. Is `k_ravine_1` reachable — [O] no (BLOCKED, donor-disabled)

- [O] `generator.cfg:540-579`: `Name = ravine_medium` lists `k_ravine_1` (:543, `Freq = 1`)
  plus `k_ravine_2..9` (:547-577).
- [O] `dogenerate.inc:1760`:
  `//_misc_SetupPatternsByType(pGenerator, envplHnd, 'ravine_medium'{'ravine_big'}, plt/3); // sand ravine`
  — the `ravine_medium` call is commented out; the live line `:1761` stamps
  `'ravine_big'` instead.
- [O] `pattern_gen.gd:27-52`: `RELIEF_RECIPES` has `plateau`, `plateau_small`,
  `plateau_big`, `ravine_big` (:47), `mountains`, `hills_dark`, `hills_light`,
  `plain_huge` — **no `ravine_medium` entry** (`:37` comment: "`ravine_medium` is
  `//`-disabled in the donor and stays absent").
- [O] `donor_patterns.json` (line 1): `k_ravine_big_stone_1..8` exist under `ravine_big`;
  `k_ravine_1` is absent (RELIEF-02 §2, :68-84).
- [O] `game.gd:1528-1529` itself comments that `k_ravine_1` "is not reachable from
  `donor_patterns.json` / `pattern_gen.gd` recipes (RELIEF-02 §5, BLOCKED)".

So the port's second grid id can never increment `relief_grid_candidates` in a
donor-faithful run. Keeping it in the gate is harmless but inert; it cannot explain or
fix the observed zero on its own.

---

## 4. The port's two decoded grids are the STALE windows — [O]+[D]

- [O] `variant3d/scripts/game.gd:125`: the tables are "windows in DPATTERN_01 Appendix
  A1/A2 (:595-626)".
- [O] `game.gd:133-152`: the two 8×10 constants; `game.gd:158-161`:
  `k_ravine_1 … "offset": 2866`, `plt2 … "offset": 2266`.
- [O] `variant3d/tools/decode_donor_pattern.py:128,137` (I02, F01-corrected):
  `plt2 … "grid_offset": 2222`, `k_ravine_1 … "grid_offset": 2798`.
- [O] `docs/terrain_swarm_2026-11-26/reports/X23_corrected_relief_grids.md:252-256`
  (§5 table): old-vs-true `2866 → 2798` (+68 B = +17 float columns) for `k_ravine_1`
  and `2266 → 2222` (+44 B = +11 columns) for `plt2`; old tables reproduce DPATTERN
  Appendix A1/A2 with **zero deviation** at the shifted offsets (§5 P8).
- [D] Therefore the live `RELIEF_GRID_PLT2` / `RELIEF_GRID_K_RAVINE_1` constants are
  block-means of windows shifted +11/+17 columns into the true float plane — spatially
  wrong at edges by up to ~3.2 donor height units (X23 §5 MAE 1.044/1.154). They are
  correctly labelled `PORT APPROXIMATION` in `game.gd:127-128,1596-1604,1682`, but
  their *offsets and every cell value* predate the F01/X23 correction and were never
  updated (X23 §6 S1 gives the replacement tables; that replacement is out of scope
  for this read-only ticket).

---

## 5. Additional donor grid windows decodable statically from the repo — [O] yes

No donor execution is needed. The I02 decoder already emitted full `w*h` float32
`relief_float_grid` arrays into the repo:

- [O] `variant3d/assets/terrain_new/patterns/plt2.json:58`: `"grid_offset": 2222`;
  `:42150`: `"relief_float_grid": [` (full 42×55 = 2310-float window).
- [O] `variant3d/assets/terrain_new/patterns/k_ravine_1.json:58`: `"grid_offset": 2798`
  (full 46×63 window).
- [O] `variant3d/assets/terrain_new/patterns/hil1.json:58`: `"grid_offset": 968`;
  `:18324`: `"relief_float_grid": [` (full 25×41 window for the `hills_dark` stamps).
- [O] `variant3d/assets/terrain_new/patterns/k_ravine_big_stone_1.json:58`:
  `"grid_offset": 8225`; `:156207`: `"relief_float_grid": [` (full 84×100 window for
  the `ravine_big` stamps of the DEBUG run).
- [O] `variant3d/assets/terrain_new/patterns/g_hil4.json` exists in the same decoded
  set (X23 §4.4: `G=1864`, `33×59`, bit-exact vs `pattern.lib:366499-366500`).
- [O] `variant3d/assets/terrain_new/patterns/compact/patterns.json:1`
  (`schema terrain_new/patterns_compact/v1`) embeds `relief_float_grid` arrays inline
  for the pattern set (first entry `b_frt_b_p_1` with `w/h` + full float list).
- [O] `variant3d/assets/terrain_new/patterns/pattern_decode_manifest.json:14,22-23`:
  `output_count 710`, every entry `status DECODED` with `relief_float_grid` + mask.
- [O] Negative (the actual gap): `variant3d/scripts/pattern_gen.gd:58` loads
  `res://assets/terrain/patterns/donor_patterns.json` — the LEGACY export whose schema
  note (`export_donor_patterns.py:139-155`, A04 E05) stores only `w/h/cells` per pattern.
  So at stamp time the port can see footprints for `ravine_big` / `hills_dark` /
  `hills_light` / `mountains` / `plateau_big` / `plateau_small` (RELIEF_RECIPES :44-52)
  but has **no float window** for any of them; only the two stale 8×10 constants in
  `game.gd` exist, behind the two-id name gate.

[D] consequence: any *additional* grid window the port wants (hil1, g_hil4,
k_ravine_big_stone_1, plt1/plt3, g_mnt_*, f_plt_*, d_plt_*) is statically available from
the already-landed `terrain_new/patterns/*.json` full grids at the F01 offsets
(`G = 8+(w-1)*(h-1)`); wiring them in is a builder decision, not a decode problem.
No grid is transcribed here — paths and offsets above are the pointers.

---

## 6. Answer to the ticket's question

- **Is the zero-candidate state correct per donor law? [D] No.** Donor law
  (`pattern.lib` Stand flags, §1; `dogenerate.inc:1757-1765` live stamp list) gives
  height grids to members of every family in the 92-stamp run. A donor-faithful port
  would have had grid work to do on the `ravine_big`, `hills_dark/light`, `plateau*`,
  `plateau_big`, and `mountains` stamps.
- **Is it correct per the port's current gate? [O] Yes.** `game.gd:1533-1540` counts
  only literal `plt2`/`k_ravine_1` stamp names; the seed-20261113 run placed neither
  (all plateau stamps were other `plt*` members; `k_ravine_1` is unreachable, §3).
  `candidates=0, applied_cells=0` is the gate's faithful output.
- **Port gap, named exactly [O]:** the missing grid with the largest footprint on this
  run is **`k_ravine_big_stone_1`** — donor section `data/pattern/pattern.lib:730016`
  (`HeightFieldStand = True` at :730022, `84×100`, Min/Max :730045-730046), family
  `ravine_big` at `generator.cfg:503-537`, stamped live by `dogenerate.inc:1761`,
  recipe `pattern_gen.gd:47`, full float window already decoded at
  `variant3d/assets/terrain_new/patterns/k_ravine_big_stone_1.json:58`
  (`grid_offset 8225`, grid at `:156207`). Sibling gaps in priority order: `hil1`
  (`pattern.lib:33082`, G=968), `g_hil4` (`pattern.lib:366470`, G=1864), `plt1/plt3`
  (`pattern.lib:322`, `:13510`), `g_mnt_1` (`generator.cfg:663`), `f_plt_big_1`
  (`generator.cfg:639`) — Stand flags for the last three not re-read this ticket [U].
- **No new decode needed [O]:** all of the above already exist as full static windows
  in `terrain_new/patterns/*.json` (§5). What is missing is port-side constants plus a
  gate that recognises the names the generator actually emits.

---

## 7. Evidence index (all [O] unless marked)

| # | Path:line | Class | What it establishes |
|---|---|---|---|
| E1 | `data/pattern/pattern.lib:6776-6807` | [O] | `plt2` 42×55, Stand, ReplaceForWater, Scale 1, Min/Max, Offset 0 |
| E2 | `data/pattern/pattern.lib:549556-549587` | [O] | `k_ravine_1` 46×63, Stand, ReplaceForWater, Scale 1, Smooth False |
| E3 | `data/pattern/pattern.lib:33082-33113` | [O] | `hil1` 25×41, Stand, Scale 0.649999976158142 |
| E4 | `data/pattern/pattern.lib:366470-366501` | [O] | `g_hil4` 33×59, Stand, Smooth True Radius 3/Factor 4/Offset 2 |
| E5 | `data/pattern/pattern.lib:730016-730047` | [O] | `k_ravine_big_stone_1` 84×100, Stand, Smooth True, ReplaceForWater False |
| E6 | `data/pattern/pattern.lib:322-328` | [O] | `plt1` 38×53, Stand True |
| E7 | `data/game/var/generator.cfg:503-753` | [O] | Families + member names: ravine_big :503, ravine_medium :540 (k_ravine_1 :543), plateau :581 (plt2 :588), plateau_small :606, plateau_big :635, mountains :660, hills_dark :693, hills_light :714 |
| E8 | `data/scripts/common.inc/dogenerate.inc:1757-1765` | [O] | Live stamps mountains/plateau_big/plain_huge/ravine_big/plateau/plateau_small/hills_dark/hills_light; ravine_medium `//`-disabled at :1760 |
| E9 | `data/scripts/lib/map.script:112-113` | [O] | `StandPattern(envPlHnd, 'plt2', …)` ×2 — shipped-script spelling `plt2` |
| E10 | `variant3d/scripts/game.gd:125,133-162` | [O] | Port grids = DPATTERN_01 App. A1/A2 windows; stale offsets 2866/2266 |
| E11 | `variant3d/scripts/game.gd:1526-1540` | [O] | Candidate gate: exact `plt2`/`k_ravine_1` only; BLOCKED comment |
| E12 | `variant3d/scripts/game.gd:1681-1690` | [O] | `meta.relief_grid` ledger: candidates/applied_cells, PORT APPROXIMATION label |
| E13 | `variant3d/tools/decode_donor_pattern.py:128,137` | [O] | Corrected `grid_offset` 2222 (plt2) / 2798 (k_ravine_1) |
| E14 | `docs/…/X23_corrected_relief_grids.md:252-256` | [O]+[D] | Shifts +68/+44 B; old tables = shifted windows, zero dev |
| E15 | `variant3d/assets/terrain_new/patterns/plt2.json:58,42150` | [O] | Full 2310-float window at G=2222 in repo |
| E16 | `…/k_ravine_1.json:58` | [O] | Full window at G=2798 in repo |
| E17 | `…/hil1.json:58,18324` | [O] | Full 1025-float window at G=968 in repo |
| E18 | `…/k_ravine_big_stone_1.json:58,156207` | [O] | Full 8400-float window at G=8225 in repo |
| E19 | `…/pattern_decode_manifest.json:14,22-23` | [O] | 710/710 DECODED outputs |
| E20 | `variant3d/scripts/pattern_gen.gd:44-52,58` | [O] | Recipes place ravine_big/hills/mountains/plateau*; loader reads legacy JSON (cells only) |
| E21 | `docs/coord_swarm_2026-11-25/reports/RELIEF_02_stamp_marker.md:44-84` | [O] | plt2 reachable (Freq 1); k_ravine_1 absent + BLOCKED |
| E22 | `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:429` | [O] | Seed 20261150 → plt2 at (54,33), candidates 1 / applied_cells 443 |

---

## 8. Open / UNVERIFIED

- U1. Per-seed stamp-name census for ticket 180 (which exact `plt*`/`hil*`/`g_hil*`/
  `k_ravine_big_stone_*` names the 92 stamps carried) — taken from the ticket statement;
  not re-derived here.
- U2. Stand flags of unlisted siblings (plt3/4_fixed/5, d_plt*, f_plt_*, g_mnt_2..7,
  hil2..4, g_hil1..3/5..9, k_ravine_2..9, k_ravine_big_stone_2..8) — names [O] in
  `generator.cfg`, flags [U].
- U3. Engine blend, row-sign flip, smooth-port behaviour, clamp consumers — UNVERIFIED
  (X23 U2/U3/U4, spec §04 §78 note). No parity claim.
- U4. Which seed(s) place `plt2` under the *current* `pattern_gen.gd` RNG stream —
  only the RELIEF-SEED-SCAN-01 observation (E22) is cited; not re-verified here.

*End of ANOM_reliefgrid. Exactly one repo file written. Donor read-only; no code, no
Godot, no git, no donor execution. Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD.*
