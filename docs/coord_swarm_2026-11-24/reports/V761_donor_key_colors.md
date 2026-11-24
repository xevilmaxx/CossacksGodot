---
id: V7-61
owner: V7-61
date: 2026-11-24
scope: "Read-only extraction of the donor player key-colour table into variant3d/data/donor_key_colors.json for the 3D variant (AUDIT3D-02 gap G2)."
status: "COMPLETE — 13 donor player slots extracted verbatim and converted; alpha and uniform-0 shading UNVERIFIED"
governing_rule: "AUDIT3D_CHARTER.md:6-15 — donor read-only, path:line evidence, OBS vs INFERENCE, UNVERIFIED labels, no source edits, no git."
---

# V7-61 — Donor key colours → machine-readable data file

## 1. Scope and method

- Read **read-only donor text** at the exact lines cited by AUDIT3D-02, plus the
  declarations, population loop, count constants and GUI application sites
  needed to interpret them. No donor binary was copied or executed; nothing in
  the donor tree was written.
- Owned outputs only:
  - `variant3d/data/donor_key_colors.json` (new; `variant3d/` had **no** `data/`
    directory before this task — confirmed by directory read and glob)
  - this report.
- No `.gd`, `app/`, config, test or other file was edited; no git command was run.
- Labels: **OBS** = directly readable at the cited `path:line`; **INF** =
  arithmetic/inference from OBS; **UNVERIFIED** = not determinable from donor
  text and therefore not emitted as a value.

## 2. Evidence table

| # | Finding | Donor `path:line` (OBS) | Verdict |
|---|---|---|---|
| 1 | Key-colour function `GetKeyColorByPlayerIndex(plInd; var r,g,b : Float)`; default `koef := 1.1`; case table with active entries `0..13`; formula `r := ir*koef/255`, `g := ig*koef/255`, `b := ib*koef/255`; `else` → 255,255,255 (with inherited `koef=1.1` → 1.1,1.1,1.1). | `data\scripts\lib\classes.script:7986-8015` (default `:7988`, cases `:7991-8008`, commented-out variants `:7994-7995,:7998-7999`, else `:8009-8010`, formula `:8012-8014`) | **OBS** |
| 2 | `gKeyColor` is `array [0..gc_MaxKeyColorCount-1] of array [0..2] of Float`, populated by `GetKeyColorByPlayerIndex(i, ...)` for `i = 0..gc_MaxKeyColorCount-1`. | `classes.script:7685`, `:8091-8092` | **OBS** |
| 3 | `gc_MaxColorCount = 13`, `gc_MaxKeyColorCount = 24`. | `data\scripts\dmscript.global:121-122` | **OBS** |
| 4 | Key colour is applied only when `colorInd>=0 and colorInd<gc_MaxColorCount` → **indices 0..12 only**; index 13 is populated but unreachable through this path. Uniform slot **0**, components `[0],[1],[2]` in that order; `a:=1` only when lib-material texture format = 2. Recursive over child objects. | `data\scripts\lib\misc.script:5067-5081` (guard `:5070`, call `:5073`, alpha `:5069,:5072`) | **OBS** |
| 5 | Application to units and to port buildings: `_misc_ApplyKeyColorRecursiveChild(goHnd/guiHnd, gMap.players[pl].color)`. | `data\scripts\lib\unit.script:3860`; `data\scripts\lib\player.script:2971` | **OBS** |
| 6 | Table is keyed by **player slot**, not nation: `mapplayer.color := ind`; mercenary forced to `gc_MaxColorCount-1` = 12. GUI reads `gKeyColor[gMap.players[i].color][0..2]` and passes them straight to `SetGUIElementUserColor` (RGB order, no swap). | `data\scripts\lib\map.script:123`, `:136-137`; `data\gui\menu.inc\showcustomgame.inc:705`; `showhistoricalbattle.inc:648`; `showtraderesources.inc:265` | **OBS** |
| 7 | AUDIT3D-02's P0 gap G2 (no donor colours consumed in `variant3d/`) and its slot comparison table. | `docs\coord_swarm_2026-11-24\reports\AUDIT3D_02_colors.md:92-99`, `:53-78` | **OBS** (report) |

## 3. Exact extraction reasoning — value format and conversion

1. **Literal transcription.** Each case line was copied verbatim from
   `classes.script:7991-8008` (leading indentation trimmed only; inline comments
   kept). Slot 1's `ig := 60+25` is retained as written and evaluated to 85.
2. **Effective `koef`.** `var koef : Float = 1.1;` at `:7988` is assigned once
   before the case. Entries with no `koef := ...` therefore inherit **1.1** —
   this applies to slot 3 (`127,50,190` → 0.547843137, 0.215686275,
   0.819607843). Slots with an explicit override use it; slot 5 uses `koef := 1`.
3. **Conversion (INF from the donor formula at `:8012-8014`).**
   `r = channel * koef / 255`. The result is a **normalised float**, not a hex
   string, not a BGR triplet, and not a 0–255 byte value. This is corroborated
   by the two application sites: floats are passed to
   `SetGameObjectUniform4fByHandle(goHnd, 0, [0],[1],[2], a, False)`
   (`misc.script:5073`) and to `SetGUIElementUserColor(...[0],...[1],...[2], ...)`
   (`showcustomgame.inc:705`), in RGB order. Godot's `Color(r, g, b)` uses the
   same normalised float convention, so no reordering or byte scaling is needed
   for `rgb_godot_float`.
4. **No clamp in the donor.** `koef` can be 1.2, so raw results can exceed 1.0:
   slot 4 R = 1.2; slot 6 G = 1.072941176 and B = 1.2. AUDIT3D-02's table
   shows these clamped to 1.0 (`:61`–`:73`). The data file therefore stores
   **both**: `rgb_godot_float` = exact donor-formula output (Godot `Color` can
   hold >1), and `rgb_display_clamped` = clamped to 0..1, plus a convenience
   `rgb_8bit_clamped`. Choosing which one to render is explicitly a consumer
   decision, not a donor fact.
5. **Alpha is not in the donor key colour.** `GetKeyColorByPlayerIndex` returns
   only r,g,b; `misc.script:5069` declares `var a : Float;` and `:5072` sets
   `a:=1` **only** when `GetLibMaterialTextureFormat(...) = 2`, leaving it
   unassigned otherwise. No alpha value was invented; the data file emits RGB
   only and marks alpha **UNVERIFIED**.
6. **Why exactly 13 values.** The case table has 14 active entries (0–13),
   but `gc_MaxColorCount = 13` (`dmscript.global:121`) and the tint guard at
   `misc.script:5070` rejects `colorInd >= 13`. Index 13 is therefore recorded
   in `_out_of_range_case_entries` (with its value and reason) and **excluded**
   from `slots`. The 13 player slots are 0–12; slot 12 is the mercenary slot
   (`map.script:136-137`). There is **no nation key** in this table; the
   mapping is `player slot → colour index` (identity), with mercenary → 12.

## 4. Full colour list — the 13 donor player slots

Values are `rgb_godot_float` (exact donor formula, 9 dp). `clamped` column shows
`rgb_display_clamped` where it differs. All rows are **OBS** literals + **INF**
arithmetic from `classes.script:8012-8014`.

| Slot | Donor `path:line` | ir, ig, ib | koef (source) | Exact RGB float | Clamped 0..1 (if different) | 8-bit |
|---|---|---|---|---|---|---|
| 0 | `classes.script:7991` | 164, 0, 0 | 1.15 (explicit) | (0.739607843, 0, 0) | — | (189, 0, 0) |
| 1 | `classes.script:7992` | 15, 60+25=85, 192 | 1.2 (explicit) | (0.070588235, 0.4, 0.903529412) | — | (18, 102, 230) |
| 2 | `classes.script:7993` | 44, 180, 148 | 1.15 (explicit) | (0.198431373, 0.811764706, 0.66745098) | — | (51, 207, 170) |
| 3 | `classes.script:7996` | 127, 50, 190 | **1.1 (default at :7988)** | (0.547843137, 0.215686275, 0.819607843) | — | (140, 55, 209) |
| 4 | `classes.script:7997` | 255, 90, 0 | 1.2 (explicit) | (1.2, 0.423529412, 0) | (1.0, 0.423529412, 0) | (255, 108, 0) |
| 5 | `classes.script:8000` | 0, 164, 0 | 1 (explicit) | (0, 0.643137255, 0) | — | (0, 164, 0) |
| 6 | `classes.script:8001` | 140, 228, 255 | 1.2 (explicit) | (0.658823529, 1.072941176, 1.2) | (0.658823529, 1.0, 1.0) | (168, 255, 255) |
| 7 | `classes.script:8002` | 255, 80, 140 | 1.0 (explicit) | (1, 0.31372549, 0.549019608) | — | (255, 80, 140) |
| 8 | `classes.script:8003` | 255, 190, 0 | 1.0 (explicit) | (1, 0.745098039, 0) | — | (255, 190, 0) |
| 9 | `classes.script:8004` | 0, 128, 140 | 1.0 (explicit) | (0, 0.501960784, 0.549019608) | — | (0, 128, 140) |
| 10 | `classes.script:8005` | 140, 190, 80 | 1.0 (explicit) | (0.549019608, 0.745098039, 0.31372549) | — | (140, 190, 80) |
| 11 | `classes.script:8006` | 110, 90, 35 | 1.1 (explicit) | (0.474509804, 0.388235294, 0.150980392) | — | (121, 99, 39) |
| 12 | `classes.script:8007` | 101, 52, 0 | 1.1 (explicit) | (0.435686275, 0.224313725, 0) | — | (111, 57, 0) |

Compact 13-value list (exact floats, slot order 0..12):

```
0  (0.739607843, 0.000000000, 0.000000000)
1  (0.070588235, 0.400000000, 0.903529412)
2  (0.198431373, 0.811764706, 0.667450980)
3  (0.547843137, 0.215686275, 0.819607843)
4  (1.200000000, 0.423529412, 0.000000000)   [clamped R=1.0]
5  (0.000000000, 0.643137255, 0.000000000)
6  (0.658823529, 1.072941176, 1.200000000)   [clamped (0.658823529,1,1)]
7  (1.000000000, 0.313725490, 0.549019608)
8  (1.000000000, 0.745098039, 0.000000000)
9  (0.000000000, 0.501960784, 0.549019608)
10 (0.549019608, 0.745098039, 0.313725490)
11 (0.474509804, 0.388235294, 0.150980392)
12 (0.435686275, 0.224313725, 0.000000000)   [mercenary]
```

## 5. Ambiguities / UNVERIFIED items

| Item | Status | Explanation |
|---|---|---|
| Alpha channel | **UNVERIFIED** | Not returned by `GetKeyColorByPlayerIndex`; donor alpha is conditionally set to 1 only for material texture format 2 (`misc.script:5069,:5072`), otherwise unassigned. No alpha value written into the data file. |
| Donor clamp for >1.0 values | **UNVERIFIED downstream** | Script formula at `:8012-8014` has no clamp; whether the engine clamps at the shader is not in readable text. Both exact and clamped variants supplied. |
| Uniform-0 operation (multiplicative tint / additive / palette swap) | **UNVERIFIED** | `SetGameObjectUniform4fByHandle(..., 0, ...)` is an engine call; no implementing shader fragment was identified in AUDIT3D-02. |
| Slot 13 (`50,50,68`, koef 1.2) | **Readable but out of range** | Present at `classes.script:8008` and written to `gKeyColor[13]` at `:8091-8092`, but never applied (`misc.script:5070` guard). Kept in `_out_of_range_case_entries`, not in the 13 slots. |
| Indices 14–23 of `gKeyColor` | **Readable but out of range** | The `else` branch at `:8009-8010` yields 255,255,255 with inherited `koef=1.1` → (1.1,1.1,1.1); unreachable for player tint. Omitted entirely. |
| Comment `// black to green` on slot 5 | **OBS** | Donor text retained verbatim; comment is stale relative to the actual colour (pure green). Comment `// black` on slot 13 is likewise descriptive, not extracted as a value. |
| Nation mapping | **N/A** | Table is keyed by player slot, not nation (`map.script:123`). No nation→colour mapping exists in this donor table; do not synthesise one. |
| Existing port palettes | **Not trusted** | `world.gd:2172-2179`, `hud.gd:131-138`, `world3d_fx.gd:67-74` are port-invented and disagree with the donor and each other (AUDIT3D-02 §2.1); none was copied into the data file. |

## 6. How the 3D implementation should consume it

1. Load `res://data/donor_key_colors.json` from `variant3d/` (e.g. in
   `variant3d/scripts/data.gd`) and expose `slots[i].rgb_godot_float` as
   `Color(r, g, b)` for `i in 0..12`. Keep `res://` paths valid by placing the
   JSON inside the `variant3d/` project root (as done here).
2. Since the table is **player-slot keyed**, index by the entity's `player`
   value; do **not** index by nation. Reserve slot 12 for mercenary, matching
   `map.script:136-137`. Any player slot ≥13 must be clamped/rejected the same
   way the donor guard at `misc.script:5070` rejects it.
3. Use `rgb_display_clamped` for normal material tint if HDR >1.0 would wash
   out the albedo; use `rgb_godot_float` if reproducing the donor's unclamped
   uniform exactly. This choice needs owner sign-off (AUDIT3D-02 Q2/Q3): the
   port currently has no donor shader that proves which is faithful.
4. Choose alpha explicitly in Godot (e.g. 1.0 for opaque material tint) and
   document it as a port choice — the donor alpha is UNVERIFIED, so no alpha
   should be claimed as donor-derived.
5. Apply the colour **on top of** the existing donor albedo texture in
   `world3d_entities.gd`, mirroring `misc.script:5073` (uniform 0) rather than
   replacing textures; only after that, align `world3d_fx.gd:67-74` with the
   same source so flag and model tint agree (AUDIT3D-02 §4 steps 2–4).
6. The data file is deliberately data-only: it does not edit any `.gd`, and it
   does not decide the unresolved donor-fidelity vs 2D-parity question.

## 7. Reply summary

- **File:** `variant3d/data/donor_key_colors.json` — **STATUS: COMPLETE** (13
  donor player slots, verbatim literals + exact formula values + citations).
- **Report:** `docs/coord_swarm_2026-11-24/reports/V761_donor_key_colors.md`.
- **13 values (exact donor formula, slots 0..12):** see §4 compact list;
  UNVERIFIED: alpha, uniform-0 semantics, downstream clamp.
