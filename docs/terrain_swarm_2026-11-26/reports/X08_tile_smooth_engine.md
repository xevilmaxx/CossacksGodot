---
id: X08
wave: Verification / donor-data decode (terrain swarm 2026-11-26)
title: "X08 — Tile-smooth engine spec: validated parse of tilesmooth_scripts.cfg + verbatim semantics of smoothtiles.inc"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_REPO_SOURCE_EDITS__NO_GODOT_JOB
owner_file: "reports/X08_tile_smooth_engine.md (the ONLY repo file written)"
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor_root: "C:\\Games\\Cossacks 3 (read-only; never executed, never copied into repo)"
prototype_root: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\tilesmooth_validate\\ (outside repo)"
visual_parity_claim: false
---

# X08 — Validated machine-readable tile-smoothing engine spec

## 0. Scope and evidence discipline

Read first: `CHARTER.md`, `SWARM_BOARD.md`, `reports/F03_gen_config.md` (§6 grammar/census),
`spec/09_EDITOR_PARAMETERS.md`, `spec/06_TILE_AND_ATLAS.md`, plus `spec/10_STAGE_ORDER.md`
and landed prior art (`docs/research/T6_S03_smooth_chains.md`,
`docs/audit/TERRAIN_BLEND_DONOR_PLAN.md:88-139`).

Labels: **[O]** observed donor bytes/lines; **[D]** derived arithmetic/structure;
**[I]** inferred reading with caveat; **[U]** UNVERIFIED (no live consumer found);
**PORT APPROXIMATION** = what a fresh Godot module may implement, explicitly *not*
a donor-parity claim. Per charter §3, **no donor visual-parity claim is made** — no
donor GPU A/B frame was produced.

Donor was read only. No donor executable was run, no donor binary copied, no repo
source/config/asset/test/git edit, no Godot runner job. The Python prototype and its
JSON live only under the approved temp path in the frontmatter.

**Important correction to the task brief [D]/[O]:** `smoothtiles.inc` contains **no 3×3
kernel**. Its atomic operation is a **single axis-aligned adjacent tile pair**; the
pair is visited at every horizontal and every vertical grid edge (§5.4). The 3×3 grids
in §7 are a *test harness* for several adjacent edges, not a donor neighbourhood shape.
F03 §6.2's phrase "fires on a 3x3 tile neighbourhood" is therefore not literal; the
verbatim donor calls at `smoothtiles.inc:203-204,221-222` take exactly two cells.

---

## 1. Executive summary

1. **[O]/[D] Every F03 count is independently reproduced.** The prototype emits
   **22 chains, 130 groups (118 active / 12 commented), 310 entries (282 active /
   28 commented), 86 distinct active names, ΣProb = 174.0168**, with zero unparsed
   lines. SHA-256 of the parsed donor file matches F03 exactly
   (`b82c8884…a531b433`, 64,017 B, 1,863 lines). Per-chain sums, active-entry counts
   and `Prob=0` name sets match F03 §6.3 line-for-line (§4).
2. **[O] The grammar is a 4-level OSW struct nest** — chain → `SmoothTiles` → group →
   `TileNames` → entry (`TileName`, `Prob`); `//` kills a group, an entry or a value;
   C10/C21 are empty terminators with four commented groups each (§5.1-5.2).
3. **[O]/[D] Semantics decoded and quoted verbatim (§5.3-5.5).** A chain is an ordered
   compatibility sequence; a group index is the *distance metric*; `TileName` is a
   preset name resolved to an integer id; `Prob` is a roulette weight (only positive
   weights can be picked). The best chain is the one with **smallest |group1-group2|**,
   ties resolved by **first chain in source order** (`<`, never `<=`, at
   `smoothtiles.inc:128`). Distance 1 → no change; distance 2 → replace the farther
   tile from the middle group; distance >2 → replace the farther tile from
   `nearer+1`; no shared chain → no change.
4. **[O]/[D] Pass order is: snapshot once → 3 passes of (horizontal sweep, then vertical
   sweep) with in-place edits → single write-back.** Editing `atilemap` in place means
   later edges in the same pass see earlier replacements; this contradicts a prior-art
   gloss that smoothing is "against the snapshot, then written back once"
   (`TERRAIN_BLEND_DONOR_PLAN.md:118`). Multi-pass verdict in §6, item A1.
5. **[D] Both donor contradictions survive four independent passes** and are preserved,
   not fixed: `TileSmoothPasses=6` vs `SmoothTileMap(...,3)`; `tilesmooth.cfg` path vs
   `tilesmooth_scripts.cfg` actually loaded. No script in `data/scripts/**` references
   either cfg key; the only load in all scripts is `smoothtiles.inc:5`.
6. **[U]/PORT APPROXIMATION** All 246 `smoothtiles.inc` lines are `;`-prefixed, and the
   commented block contains an uncompilable fragment (`i1 + )`, `:147`). The decoded
   algorithm is **donor intent**, not proven live runtime. Uninitialised `sumProb`/`tmp`
   (`:42,68`) are preserved as an anomaly; the prototype models them as zero. No parity
   claim.

---

## 2. Evidence table

| ID | Label | Evidence (donor path:line, 1-based) | Supports |
|---|---|---|---|
| E01 | **[O]** | `data/gen/tilesmooth_scripts.cfg` (64,017 B, 1,863 lines, SHA-256 `b82c8884…b433` = F03 §2) | Parse input; §4 counts |
| E02 | **[O]** | `data/scripts/common.inc/smoothtiles.inc:4-7` | Load `tilesmooth_scripts.cfg`, select `TileSmoothLists`, `Count` = chain count |
| E03 | **[O]** | `smoothtiles.inc:9-27` | Record types; array bounds `SmoothTile[0..15]`, `SmoothTiles[0..23]`, `Items[0..63]`, `atilemap[0..640]²` |
| E04 | **[O]** | `smoothtiles.inc:30-32,192-197,237,240-242` | Snapshot, pass loop, 3 passes, map write-back |
| E05 | **[O]** | `smoothtiles.inc:35-60` | Parse each chain/group/entry; resolve `TileName`→`TileIndex` (`:51`); accumulate `SumProb` (`:53,58`) |
| E06 | **[O]** | `smoothtiles.inc:63-80` | `FindRandomTileIndex`: `rnd := RandomExt*sumProb`, first `prob>0` with `rnd<tmp`; `-1` default |
| E07 | **[O]** | `smoothtiles.inc:84-187` | `GetNeighbourTiles`: name lookup (`:95-96`), group indices (`:108-123`), min-distance chain (`:126-136`), four decision branches (`:139-186`) |
| E08 | **[O]** | `smoothtiles.inc:200-215,218-233` | Horizontal then vertical edge sweeps, in-place writes (`:210,213,228,231`) |
| E09 | **[O]** | `data/gen/globalparams.cfg:9` = `TileSmoothPasses = 6`; `:10` = `TileSmoothListFileName = .\data\gen\tilesmooth.cfg` | Contradiction C2/C3 |
| E10 | **[O]** | grep of `data/scripts/**`: 0 hits for `TileSmoothPasses`, `TileSmoothListFileName` or `tilesmooth.cfg`; 1 hit for `tilesmooth_scripts.cfg` (`smoothtiles.inc:5`) | C2/C3 fourth pass |
| E11 | **[O]** | `data/terrain/tiles/terrain.presets:6-129` (Summer) / `:138-261` (Winter) | Name↔id resolution for test vectors (F05 E01) |
| E12 | **[O]** | `tilesmooth_scripts.cfg:8-35,37-50,51-94,449-452,817-879,881-929,1811-1862` | Grammar exemplars, dead rules, 1.0028 anomaly, terminators |
| E13 | **[D]** | F03 §6.3-6.6; `docs/research/T6_S03_smooth_chains.md:39-80,211-216`; `TERRAIN_BLEND_DONOR_PLAN.md:88-127` | Independent corroboration; Winter mirror |
| E14 | **[D]** | `spec/09_EDITOR_PARAMETERS.md:49-58`; `spec/10_STAGE_ORDER.md:55`; `spec/06_TILE_AND_ATLAS.md:1-48` | Existing spec integration points |

---

## 3. Method (reproducible, outside the repo)

1. **Prototype parser** — `…\tilesmooth_validate\parse_tilesmooth.py` (read-only):
   `latin-1` byte decode, line-numbered state machine over `struct.begin` / `struct.end`,
   stack of frames `{root, chain, smooth, TileNames, entry}`, `//` stripped at any
   indentation; commented frames mark entire groups/entries dead, a commented `Prob`
   inside a live entry is recorded as a dead *alternative value* (e.g. `:451/452`).
   Probabilities are parsed with `Decimal`, never binary floats, so Σ is exact.
2. **Output** — `tilesmooth_spec.json` (full parsed tree + validation + vectors) and
   `validation_summary.json` (counts) in the temp directory only.
3. **Evaluator** — a faithful Python model of `smoothtiles.inc:4-242`; `RandomExt` is
   injectable so vectors are exact. `rnd_fn` defaults to 0 (first positive entry).
4. **Name↔id** — `terrain.presets:6-129` parsed directly; Summer id *i* is line
   `6+i` (`grass1=0 … alpha0c=123`), cross-checked against F05 §3.
5. **Multiple passes** — every contradiction and anomaly was re-read with a second
   instrument (byte re-read via Python, full-file grep of `data/scripts/**`, structural
   parser, prior-art cross-check, executable evaluator); verdicts in §6.
6. **No invention** — values not in the donor (runtime RNG stream position, initial
   accumulator contents, out-of-range edge values) are registered `[U]`, never guessed
   into the spec as facts.

---

## 4. Validation counts (all **[D]** from **[O]** bytes; prototype = F03)

| Metric | F03 §6.3 | Prototype | Verdict |
|---|---:|---:|---|
| Chains | 22 | 22 | ✅ |
| Groups total | 130 | 130 | ✅ |
| Groups active | 118 | 118 | ✅ |
| Groups commented | 12 | 12 | ✅ |
| Entries total | 310 | 310 | ✅ |
| Entries active | 282 | 282 | ✅ |
| Entries commented | 28 | 28 | ✅ |
| Distinct active names | 86 | 86 | ✅ |
| ΣProb (all active entries) | 174.0168 | 174.0168 (Decimal) | ✅ |
| Winter mirrors C00–C10 | exact | 11/11 exact (`_winter` suffix, identical probs/boundaries) | ✅ |
| Unparsed lines | — | 0 | ✅ |

`[D]` ΣSummer = `6+11+13+14+11.0028+10.0028+8.0028+3+3+8 = 87.0084`;
Winter mirrors it exactly, so `2 × 87.0084 = 174.0168` — matches F03's Σ.

Per-chain census **[O]/[D]** (chain first-line here = the `[*]` record; F03 §6.3 used the
`SmoothTiles : struct.begin` line one lower, e.g. C00 line 3 vs 4 — same chain):

| Chain | `[*]` line | groups act/dead | entries active | ΣProb | `Prob=0` names |
|---|---:|---:|---:|---:|---|
| C00 | 3 | 4 / 1 | 15 | 6.0000 | rock5, rock8, rock9 |
| C01 | 97 | 6 / 0 | 17 | 11.0000 | — |
| C02 | 193 | 6 / 0 | 16 | 13.0000 | — |
| C03 | 285 | 9 / 0 | 18 | 14.0000 | — |
| C04 | 397 | 9 / 0 | 20 | 11.0028 | — |
| C05 | 518 | 8 / 0 | 18 | 10.0028 | — |
| C06 | 627 | 6 / 0 | 19 | 8.0028 | — |
| C07 | 732 | 3 / 1 | 4 | 3.0000 | test8 |
| C08 | 780 | 3 / 0 | 5 | 3.0000 | — |
| C09 | 816 | 5 / 0 | 9 | 8.0000 | — |
| C10 | 880 | 0 / 4 | 0 | 0 | — (terminator) |
| C11 | 933 | 4 / 1 | 15 | 6.0000 | rock5_winter, rock8_winter, rock9_winter |
| C12 | 1027 | 6 / 0 | 17 | 11.0000 | — |
| C13 | 1123 | 6 / 0 | 16 | 13.0000 | — |
| C14 | 1215 | 9 / 0 | 18 | 14.0000 | — |
| C15 | 1327 | 9 / 0 | 20 | 11.0028 | — |
| C16 | 1448 | 8 / 0 | 18 | 10.0028 | — |
| C17 | 1557 | 6 / 0 | 19 | 8.0028 | — |
| C18 | 1662 | 3 / 1 | 4 | 3.0000 | test8_winter |
| C19 | 1710 | 3 / 0 | 5 | 3.0000 | — |
| C20 | 1746 | 5 / 0 | 9 | 8.0000 | — |
| C21 | 1810 | 0 / 4 | 0 | 0 | — (terminator) |

**[D] Dead-rule accounting matches F03 §6.6 exactly:** 12 dead groups =
`1(C00)+1(C07)+4(C10)` ×2; 28 dead entries = `2(C00)+3(C07)+1(C09)+8(C10)` ×2.
The `//Prob = 0.36` alternatives at `:451,572,681` (winter `:1381,1502,1611`) are
dead *values*, not extra entries; the inert `//Prob = 0` at `:42,47` is an annotation.

---

## 5. Grammar and evaluation semantics

### 5.1 Exact grammar **[O]** (`tilesmooth_scripts.cfg`, consumer `smoothtiles.inc:4-60`)

```
section.begin
   TileSmoothLists : struct.begin
      [*] : struct.begin                  # CHAIN i -> Items[i],  array bound [0..63]  (:26)
         SmoothTiles : struct.begin
            [*] : struct.begin            # GROUP j -> SmoothTiles[j], bound [0..23] (:23)
               TileNames : struct.begin
                  [*] : struct.begin      # ENTRY k -> SmoothTile[k], bound [0..15] (:18)
                     TileName = <tile-block-name>   # :50 -> MapGetTileIndexByTileBlock (:51)
                     Prob = <decimal float>         # :52 -> SumProb += prob (:53,:58)
                  struct.end
               struct.end
            struct.end
         struct.end
      struct.end
   struct.end
section.end
```

Comment rules **[O]**: `//` at any indentation discards the token on that line. A
commented `[*] : struct.begin` discards the whole group/entry (`:37-50`, `:856-859`,
`:882-929`); a commented `Prob` inside a live entry is a dead alternative (`:451/452`).
`[D]` Bounds are per-structure upper limits, not observed counts: 22 chains ≤ 64
(`Items`), ≤9 groups in any chain ≤ 24 (`SmoothTiles`), and ≤6 entries in any one
group ≤ 16 (`SmoothTile`). C04/C15 have 20 entries **in total across 9 groups**, not
in one group — no bound is exceeded.

### 5.2 Machine-readable output contract **[D]** (prototype JSON)

```
{
  "validation": { chains, groups_total, groups_active, groups_dead,
                  entries_total, entries_active, entries_dead,
                  distinct_active_names, sum_prob_all_active,
                  per_chain[], winter_mirror[] },
  "spec": { source, sha256, bytes, lines,
            "chains": [ { index, line, commented,
                          "groups": [ { index, line, commented,
                          "entries": [ { index, line, commented,
                                         TileName, Prob (string|null),
                                         prob_alternatives[] } ] } ] } ],
            "unparsed": [] },
  "name_id_map_summer": { "<preset name>": <integer 0..123> },
  "test_vectors": [ { label, input_3x3_ids, output_3x3_ids_after_1_pass,
                      note, donor_rule } ]
}
```
A fresh module should key chains by **index** (never by name) and keep entries in
source order; `Prob` stays a string/Decimal in the compiler, converted once at load.

### 5.3 What each element means **[O]/[D]/[I]**

| Element | Meaning | Evidence |
|---|---|---|
| Chain `Items[i]` | One ordered compatibility family; a pair "shares a chain" iff both names occur in it. Source order is the tie-break key. | `smoothtiles.inc:26,102,126-136` |
| Group j | A step/band in that chain; its **index** is the distance used by all decisions. | `:108-123,128,142,159,165,171` |
| `TileName` | Tile-block/preset name; resolved id→name and name→id round-trip. Must match `terrain.presets` exactly. | `:50-51,95-96`; F05 E01 |
| `Prob` | Roulette weight for *replacement picks only*. `Prob=0` names remain endpoints for lookup but can never be picked (`prob>0` guard). `SumProb` is the group's sum (zeros included). | `:52-58,66-79,112-121` |
| Empty chain | Array terminator; contains no active groups, contributes nothing. | `tilesmooth_scripts.cfg:881-929,1811-1859` |

### 5.4 Verbatim donor semantics — `GetNeighbourTiles` and sweeps **[O]**

All lines below are copied verbatim from
`C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc` (the `[*] = ;` prefix is
part of the file). Every line is `;`-commented → **[U]** for live activity.

Load and parse:
```
    4:       [*] = ;var pTileSmoothLists : Integer = _parser_ParserTemporary(True);
    5:       [*] = ;ParserLoadFromFileByHandle(pTileSmoothLists, '.\data\gen\tilesmooth_scripts.cfg');
    6:       [*] = ;pTileSmoothLists := ParserSelectByHandleByKey(pTileSmoothLists, 'TileSmoothLists');
    7:       [*] = ;var Count : Integer = ParserGetCountByHandle(pTileSmoothLists);
   51:       [*] = ;         var tileIndex : Integer = MapGetTileIndexByTileBlock(tileName);
   52:       [*] = ;         var prob : Float = ParserGetFloatValueByKeyByHandle(pTileName, 'Prob');
   53:       [*] = ;         sumProb := sumProb+prob;
   58:       [*] = ;      Items[i].SmoothTiles[j].SumProb := sumProb;
```

Roulette:
```
   63:       [*] = ;function FindRandomTileIndex(i, j : Integer) : Integer;
   65:       [*] = ;   Result := -1;
   66:       [*] = ;   var sumProb : Float = Items[i].SmoothTiles[j].SumProb;
   67:       [*] = ;   var rnd : Float = RandomExt*sumProb;
   68:       [*] = ;   var tmp : Float;
   70:       [*] = ;   for k:=0 to Items[i].SmoothTiles[j].TileCount-1 do
   72:       [*] = ;      var prob : Float = Items[i].SmoothTiles[j].SmoothTile[k].Prob;
   73:       [*] = ;      tmp := tmp+prob;
   74:       [*] = ;      if (prob>0) and (rnd<tmp) then
   76:       [*] = ;         Result := Items[i].SmoothTiles[j].SmoothTile[k].TileIndex;
```
`[D]` All-zero group ⇒ `sumProb=0` (if initialised) ⇒ `rnd=0`, every `prob>0` false ⇒
returns `-1` ⇒ **no replacement**. This is the `Prob=0` endpoint barrier (vector V3).

Chain search and decision:
```
   95:       [*] = ;   tilename1 := MapGetTileBlockByTileIndex(tindex1);
   96:       [*] = ;   tilename2 := MapGetTileBlockByTileIndex(tindex2);
   99:       [*] = ;   mindist := gc_MaxInt;
  102:       [*] = ;   for i := 0 to Count-1 do
  108:       [*] = ;      for j := 0 to Items[i].TileListsCount-1 do
  110:       [*] = ;         for k := 0 to Items[i].SmoothTiles[j].TileCount-1 do
  112:       [*] = ;            if Items[i].SmoothTiles[j].SmoothTile[k].TileName = tilename1 then
  114:       [*] = ;               ind1 := j;
  115:       [*] = ;               ind1ProbZero := (Items[i].SmoothTiles[j].SmoothTile[k].prob=0);
  117:       [*] = ;            if Items[i].SmoothTiles[j].SmoothTile[k].TileName = tilename2 then
  119:       [*] = ;               ind2 := j;
  120:       [*] = ;               ind2ProbZero := (Items[i].SmoothTiles[j].SmoothTile[k].prob=0);
  124:       [*] = ;      if ((tilename1='rock5') and (tilename2='rock2')) or ((tilename1='rock2') and (tilename2='rock5')) then
  125:       [*] = ;      ind2ProbZero := ind2ProbZero;
  126:       [*] = ;      if (ind1<>ind2) then
  127:       [*] = ;      if (ind1 > -1) and (ind2 > -1) then
  128:       [*] = ;      if Abs(ind1 - ind2) < mindist then
  130:       [*] = ;         mindist := round(Abs(ind1 - ind2));
  135:       [*] = ;         ilist := i;
  139:       [*] = ;   if ilist > -1 then
  142:       [*] = ;      if (Abs(i1 - i2) = 1) and ((not i1ProbZero) or (not i2ProbZero)) then
  153:       [*] = ;            outtile1 := -1;
  154:       [*] = ;            outtile2 := -1;
  159:       [*] = ;      if i1 - i2 = 2 then
  161:       [*] = ;         outtile1 := FindRandomTileIndex(ilist, (i1 + i2) div 2);
  165:       [*] = ;      if i2 - i1 = 2 then
  168:       [*] = ;         outtile2 := FindRandomTileIndex(ilist, (i1 + i2) div 2);
  171:       [*] = ;      if i1 < i2 then
  174:       [*] = ;         outtile2 := FindRandomTileIndex(ilist, i1 + 1);
  178:       [*] = ;         outtile1 := FindRandomTileIndex(ilist, i2 + 1);
  182:       [*] = ;   else
  184:       [*] = ;      outtile1 := -1;
  185:       [*] = ;      outtile2 := -1;
```
`[D]` Consequences: (a) the name loops **do not break**, so if a name occurs in two
groups of one chain the *last* occurrence wins (`test8` in C09 g3/g4 — vector V9);
(b) `:126` rejects same-group pairs; (c) strict `<` at `:128` keeps the first chain on
a distance tie; (d) `:124-125` is a no-op self-assignment; (e) if distance is 1 but
**both** endpoints have `Prob=0`, the first condition fails and the code falls through
to `:171-180`, replacing the farther tile from its own group — but the parser census
finds **zero** donor name pairs in adjacent groups with both `Prob=0`, so this branch
is unreachable with shipped data `[D]`.

The intended Prob-zero reroll is commented out (and syntactically invalid):
```
  144:       [*] = ;         {if (i1ProbZero) or (i2ProbZero) then
  146:       [*] = ;            if (i1ProbZero) then
  147:       [*] = ;            outtile1 := FindRandomTileIndex(ilist, i1 + );
  149:       [*] = ;            outtile2 := FindRandomTileIndex(ilist, i2 + i1);
  151:       [*] = ;         end
  152:       [*] = ;         else}
```

Sweeps, pass count and write-back:
```
  191:       [*] = ;procedure SmoothTileMap(mini, minj, maxi, maxj, passes : Integer);
  197:       [*] = ;   for k := 0 to passes-1 do
  200:       [*] = ;      for i := mini to maxi-1 do
  201:       [*] = ;      for j := minj to maxj do
  203:       [*] = ;         tind1 := atilemap[i, j];
  204:       [*] = ;         tind2 := atilemap[i+1, j];
  205:       [*] = ;         if tind1 <> tind2 then
  210:       [*] = ;            atilemap[i, j] := tchange1;
  213:       [*] = ;            atilemap[i+1, j] := tchange2;
  218:       [*] = ;      for j := minj to maxj-1 do
  219:       [*] = ;      for i := mini to maxi do
  221:       [*] = ;         tind1 := atilemap[i, j];
  222:       [*] = ;         tind2 := atilemap[i, j+1];
  223:       [*] = ;         if tind1 <> tind2 then
  228:       [*] = ;            atilemap[i, j] := tchange1;
  231:       [*] = ;            atilemap[i, j+1] := tchange2;
  237:       [*] = ;SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3);
  242:       [*] = ;SetTileIndex(i, j, atilemap[i, j]);
```
`[D]` Loop order (outer `i`, inner `j` for horizontal; outer `j`, inner `i` for
vertical) is part of determinism. Snapshot at `:30-32` happens **once**; `atilemap`
is then mutated in place on every pass and written to the map only at `:240-242`.

### 5.5 Evaluator pseudocode **[D]** — translate this into the Godot module

```python
# Faithful model of smoothtiles.inc (commented donor intent). Symbols map 1:1.
# Decimal keeps SumProb exact; RandomExt is injected for determinism.

def load(path):                                   # :4-60
    chains = []
    for each active chain [*] in TileSmoothLists:  # skip //[*] frames
        groups = []
        for each active group under SmoothTiles:
            entries = []
            for each active entry under TileNames:
                name  = entry["TileName"]          # :50
                idx   = preset_index_of(name)      # :51 MapGetTileIndexByTileBlock
                prob  = Decimal(entry["Prob"])     # :52
                entries.append({"name": name, "idx": idx, "prob": prob})
            groups.append(entries)                 # SumProb = sum(prob) (:53,:58)
        chains.append(groups)
    return chains

def find_random(chains, i, j, RandomExt):         # :63-80
    group = chains[i][j]
    SumProb = sum((e["prob"] for e in group), Decimal(0))
    rnd = RandomExt * SumProb                      # :67
    tmp = Decimal(0)                               # donor leaves `tmp` uninitialised [U]
    for e in group:
        tmp += e["prob"]                           # :73
        if e["prob"] > 0 and rnd < tmp:            # :74 - Prob=0 can never be picked
            return e["idx"]                        # :76
    return -1                                      # :65 - all-zero group => no pick

def get_neighbour_tiles(chains, i2name, t1, t2, RandomExt):   # :84-187
    name1, name2 = i2name[t1], i2name[t2]           # :95-96
    ilist, mindist, i1, i2 = -1, None, -1, -1
    z1 = z2 = False
    for ci, groups in enumerate(chains):            # :102 (first tie wins: strict <)
        ind1 = ind2 = -1; zind1 = zind2 = False
        for gj, group in enumerate(groups):          # :108
            for e in group:                          # :110 - NO break: last match wins
                if e["name"] == name1: ind1, zind1 = gj, (e["prob"] == 0)  # :112-115
                if e["name"] == name2: ind2, zind2 = gj, (e["prob"] == 0)  # :117-120
        # :124-125 rock5/rock2 self-assignment: no effect, omit
        if ind1 != ind2 and ind1 > -1 and ind2 > -1:           # :126-127
            d = abs(ind1 - ind2)
            if mindist is None or d < mindist:                 # :128
                mindist, i1, i2, ilist = d, ind1, ind2, ci
                z1, z2 = zind1, zind2
    if ilist == -1: return -1, -1                             # :182-186
    if abs(i1 - i2) == 1 and ((not z1) or (not z2)):
        return -1, -1                                          # :142-156 compatible
    if i1 - i2 == 2:  return find_random(chains, ilist,(i1+i2)//2,RandomExt), -1  # :159-163
    if i2 - i1 == 2:  return -1, find_random(chains, ilist,(i1+i2)//2,RandomExt)  # :165-169
    if i1 < i2:       return -1, find_random(chains, ilist, i1+1, RandomExt)      # :171-175
    return find_random(chains, ilist, i2+1, RandomExt), -1                        # :176-180

def smooth_tile_map(atilemap, W, H, passes=3, RandomExt=0):    # :191-235
    a = [row[:] for row in atilemap]                          # :27,:30-32 snapshot
    for _ in range(passes):                                    # :197
        for i in range(W-1):                                    # :200 outer x
            for j in range(H):                                  # :201 inner y
                if a[j][i] != a[j][i+1]:                        # :205
                    c1, c2 = get_neighbour_tiles(a[j][i], a[j][i+1])  # :207
                    if c1 > -1: a[j][i]   = c1                  # :210  IN PLACE
                    if c2 > -1: a[j][i+1] = c2                  # :213
        for j in range(H-1):                                    # :218 outer y
            for i in range(W):                                  # :219 inner x
                if a[j][i] != a[j+1][i]:                        # :223
                    c1, c2 = get_neighbour_tiles(a[j][i], a[j+1][i])  # :225
                    if c1 > -1: a[j][i]   = c1                  # :228
                    if c2 > -1: a[j+1][i] = c2                  # :231
    for j in range(H):                                          # :240-242 write-back
        for i in range(W): SetTileIndex(i, j, a[j][i])
    return a
```
`[D]` The port's `RandomExt` stream state at smoothing time is unknown (D02); the
`PORT APPROXIMATION` module must inject a deterministic per-stage RNG and document the
choice. `/` in Pascal `:161/:168` is integer `div`; Python `//` matches.

---

## 6. Multiple-pass contradiction and anomaly register

Every row was re-examined with **≥2 instruments** before a verdict; no anomaly was
silently skipped (charter §4).

| # | Item | Pass 1 | Pass 2 | Pass 3 / 4 | Verdict |
|---|---|---|---|---|---|
| C2 | `TileSmoothPasses=6` vs `SmoothTileMap(...,3)` | `globalparams.cfg:9` literal `[O]` | `smoothtiles.inc:237` literal `3` `[O]` | full grep `data/scripts/**`: **0** references to `TileSmoothPasses`; prior art `TERRAIN_BLEND_DONOR_PLAN.md:125-127`, `spec/09:51-58`, `spec/10:55` agree | **Preserve.** 6 = editor-facing; skirmish uses **3**. `[D]` |
| C3 | `tilesmooth.cfg` path vs `tilesmooth_scripts.cfg` loaded | `globalparams.cfg:10` literal `[O]` | `smoothtiles.inc:5` literal load `[O]` | full grep: the *only* script reference to either file is `:5`; `tilesmooth.cfg` re-counted 8 sections / 30 names / 129 lines `[O]`; prior art `:105-109` agrees | **Preserve.** Runtime file = `tilesmooth_scripts.cfg`; plain table is editor-only. `[D]` |
| A1 | "snapshot then written back once" vs in-place sweeps | Prior art `TERRAIN_BLEND_DONOR_PLAN.md:118` claims snapshot-only `[O]` of a gloss | Donor writes `atilemap` at `:210,213,228,231` `[O]` | Snapshot `:30-32`; map write-back `:240-242`; evaluator V4-V6 show cascades within one pass | Prior art **imprecise**. Snapshot once, edit in place across passes, write map once. `[D]` |
| A2 | Uninitialised `sumProb` / `tmp` | `:42` `var sumProb : Float;` and `:68` `var tmp : Float;` — no `:= 0` `[O]` | Byte re-read of exact lines confirms no hidden initialiser `[O]` | Prior art describes `rnd := RandomExt*SumProb` as if initialised; no binary consumer read | `[U]` runtime initial value. Prototype models **0** = `PORT APPROXIMATION`; port must not claim exact roulette boundaries. |
| A3 | Invalid code inside commented reroll block | `:147` ends `i1 + );` `[O]` | Byte re-read confirms the dangling `+` `[O]` | Block is `{...}` (`144`,`151`); **all** 246 script lines are `;`-prefixed | Script is **authoring intent, not compilable live code**; reinforces `[U]` on all semantics. |
| A4 | `rock5`/`rock2` special case | `:124-125` `[O]` | Byte re-read identical `[O]` | Prior art `TERRAIN_BLEND_DONOR_PLAN.md:120` calls it a no-op; parser confirms no behavioural flag change | **No semantic effect**; omit in port but document. `[D]` |
| A5 | Sweep reads index `W`/`H` outside snapshot | `:200-204` reaches `i+1 == W`; `:218-222` reaches `j+1 == H` `[O]` | Snapshot loops `:30-32` cover only `0..W-1, 0..H-1` `[O]` | Array bound `[0..640]` (`:27`) permits the index, but its value is never assigned; write-back `:240-242` discards it | `[U]` what value `atilemap[W,*]/[*,H]` holds; likely no-chain/no-change, not proven. |
| A6 | Distance-1 both-`Prob=0` fall-through | `:142` requires `not z1 or not z2` `[O]` | Parser census: **0** donor pairs in adjacent groups of one chain with both `Prob=0` `[D]` | Evaluator confirms no shipped data reaches `:171-180` via that path | Branch exists but is **unreachable with shipped data**. `[D]` |

---

## 7. Exact test vectors (derived, not invented)

Inputs are 3×3 Summer tile **ids** (`row-major`, id from `terrain.presets:6-129` / F05 §3).
Outputs are after **one** `SmoothTileMap` pass with `RandomExt=0` except V11. Every
vector was produced by the evaluator in §5.5 and can be re-run from the temp prototype.

Selected ids **[O]** (`terrain.presets` line): `grass1=0 (:6)`, `grass3=2 (:8)`,
`grass4=3 (:9)`, `grass9=8 (:14)`, `ground1=10 (:16)`, `grass_ground2=15 (:21)`,
`rock1=17 (:23)`, `rock8=24 (:30)`, `rock9=25 (:31)`, `test2=73 (:78)`,
`test8=79 (:85)`, `test9=80 (:86)`, `sandsea1=93 (:99)`, `sandsea5=97 (:103)`,
`desert1=111 (:117)`.

| # | Input 3×3 ids | Output 3×3 ids | Donor rule (derived) |
|---|---|---|---|
| V1 | `[[0,0,0],[0,0,0],[0,0,0]]` | unchanged | No differing edge; `smoothtiles.inc:205,223` guard. |
| V2 | `[[93,97,97],[97,97,97],[97,97,97]]` | unchanged | `sandsea1`=C00 g0, `sandsea5`=C00 g1, distance 1, both `Prob>0` → compatible/no change (`:142-156`); vertical edges same. |
| V3 | `[[97,17,17],[17,17,17],[17,17,17]]` | unchanged | C00 g1↔g3 distance 2; middle g2 = `{rock9=0,rock8=0,rock5=0}` → `FindRandomTileIndex` returns `-1` (`:65,74`) → no pick (`:165-169`). **Prob=0 barrier.** |
| V4 | `[[0,0,80],[0,0,0],[0,0,0]]` | `[[0,0,8],[0,0,0],[0,0,0]]` | `grass1`=C03 g4, `test9`=C03 g6, distance 2; middle g5=`{grass9=1}` → right tile = id 8 (`:165-169`); then vertical edge `8|0` = g5↔g4 distance 1 → no change. |
| V5 | `[[80,80,80],[0,0,0],[0,0,0]]` | `[[8,8,8],[0,0,0],[0,0,0]]` | Same pair transposed; horizontal sweep sees equal rows; vertical sweep replaces the **upper** tile (t1, farther g6) via `:159-163`; lower edge `8|0` then no-change. |
| V6 | `[[0,3,8],[8,8,8],[8,8,8]]` | `[[0,8,8],[8,8,8],[8,8,8]]` | `grass1`=g4, `grass4`=g8 distance **4** >2, `i1<i2` → pick from g5=`{grass9=1}` (`:171-175`); other cells pre-set to 8 to isolate the edge. |
| V7 | `[[25,17,17],[17,17,17],[17,17,17]]` | unchanged | `rock9`=C00 g2 has `Prob=0`, `rock1`=g3 positive; distance 1 with one positive → no change (`:142`); C00's distance 1 beats C04's distance 2. |
| V8 | `[[111,0,0],[0,0,0],[0,0,0]]` | unchanged | `desert1` occurs in **no** smoothing chain → `ind1=-1` → `ilist=-1` (`:126-136,182-186`). |
| V9 | `[[79,10,10],[10,10,10],[10,10,10]]` | `[[73,10,10],[10,10,10],[10,10,10]]` | `test8` occurs in C09 g3 (`0.4`) **and** g4 (`1`); no `break` at `:110-123` so `ind1=4`. Distance to `ground1` g0 = 4, `i1>i2` → **left** tile replaced from g1=`{test2=1}` → id 73 (`:176-180`). |
| V10 | `[[25,24,24],[24,24,24],[24,24,24]]` | unchanged | `rock9`/`rock8` share C00 g2 (`ind1==ind2` → rejected at `:126`); C04 offers distance 1 with positive endpoints → no change. |
| V11 | `[[25,0,15],[15,15,15],[15,15,15]]`, `RandomExt=0.6392` | `[[25,15,15],[15,15,15],[15,15,15]]` | `rock9`=C04 g2, `grass1`=g4 distance 2; middle g3 `{0.64,0.0028,0.36}` has authored `SumProb=1.0028`; `rnd=0.6392×1.0028=0.64098976` lies in `(0.64,0.6428]` → `grass_ground2` id 15 (`:449-452`, `:53,58,63-80,165-169`). **Preserve the 1.0028 anomaly.** |

`[D]` Vectors V4-V6 also demonstrate A1 in-place cascades: a replacement in the
horizontal sweep is visible to the vertical sweep of the same pass.

---

## 8. Implications for spec §06 and §10 (`PORT APPROXIMATION`)

### §06 — tile ids and atlas
1. **[D]** Smoothing must operate on **integer preset ids 0–123** and round-trip through
   tile-block names (`MapGetTileIndexByTileBlock` / `MapGetTileBlockByTileIndex`,
   `smoothtiles.inc:51,95-96`). A compiler may emit a static `name→id` table from
   `terrain.presets:6-129` / `:138-261`; id equality across seasons is preserved (F05).
2. **[D]** Only **86 names** participate; face ids 35–70, alpha sentinels 86/110/123,
   desert 111–122 and water (no id) are absent from the chains. An out-of-range or
   unlisted tile id simply finds no chain and is left unchanged (`:182-186`) — no
   sentinel repair should happen inside the smoother.
3. **[U]/PORT APPROXIMATION** Winter chains C11–C20 are exact `_winter` mirrors, but
   no script selects them by season. The port may either load them verbatim or use the
   index-preserving Summer table with a documented alias map; the two are *structurally*
   equivalent only if aliases preserve group membership (T6-S03 §4.3). **Do not claim
   equivalence as proven.**
4. **[D]** `spec/06 §5` alpha holes (ids 86/110/123) and face reuse are separate
   rendering concerns; this engine changes **ids only**, never atlas cells or masks.

### §10 — generation stage order
5. **[O]/[D]** Tile smoothing sits inside `GenerateMap` after texture/tile selection
   and before the shore exclusion mask (`spec/10 §1` item 5; `smoothtiles.inc` is D5).
   It must not move ahead of relief stamping or after start placement.
6. **[D]** Use **3 passes** (`smoothtiles.inc:237`), not `globalparams.cfg:9`'s 6;
   keep the cfg literal as provenance only. Sweep order and in-place semantics are
   part of determinism — a double-buffered implementation will produce different
   vectors V4-V6 and is `PORT APPROXIMATION`.
7. **[U]** `RandomExt` stream position at the smoothing stage is unknown (D02). The
   fresh module must inject a per-stage seed and label the resulting RNG choice
   `PORT APPROXIMATION`; exact donor roulette cannot be claimed.
8. **[D]** The four decision branches (no-change / middle pick / inward step / no
   chain) are complete over integer distances ≥1 once `ind1≠ind2` is enforced; no
   extra "blend" or threshold may be added (charter §4 "no invention").

---

## 9. Risks

| Risk | Label | Mitigation |
|---|---|---|
| Implementing 6 passes from the cfg | `[D]` | Follow `smoothtiles.inc:237` (3); preserve 6 as editor-only provenance. |
| Feeding plain `tilesmooth.cfg` to a weighted roulette | `[O]` | Load `tilesmooth_scripts.cfg` only (`:5`); 118 active groups, not 30 plain names. |
| Normalising `Prob=0`, the 1.0028 group, or rounding weights | `[O]/[D]` | Keep literal `Decimal` weights; V3/V11 are regression tests. |
| Taking first instead of last name occurrence inside a chain | `[D]` | No `break` at `:110-123`; V9 regression test. |
| Double-buffering the sweep | `[D]` | In-place writes at `:210,213,228,231`; V4-V6 regression tests. |
| Assuming Winter chains are selected by season | `[U]` | Mirror data; document selection as UNVERIFIED. |
| Treating commented `smoothtiles.inc` as proven live code | `[U]` | Every claim labelled "donor intent"; line `:147` is uncompilable. |
| Missing the uninitialised accumulator effect | `[U]` | Model zero explicitly; flag any parity claim about exact pick thresholds. |
| Reading `atilemap[W]`/`[*,H]` as 0 | `[U]` | Explicit out-of-range register; no test vector depends on it. |
| Claiming visual parity from correct ids | `[U]` | No GPU A/B frame; charter §3 forbids the claim. |

---

## 10. UNVERIFIED register (do not promote)

| # | Item | Why UNVERIFIED |
|---|---|---|
| U1 | Whether `smoothtiles.inc` executes at all | All 246 lines `;`-prefixed; `:147` would not compile if uncommented as-is. |
| U2 | Runtime value of uninitialised `sumProb`/`tmp` (`:42,68`) | No binary consumer read; compiler-dependent. |
| U3 | `RandomExt` stream position/seed at smoothing stage | D02 owns seed/RNG; no script consumer read. |
| U4 | Season switch selecting C11–C20 | No call found in `data/scripts/**`. |
| U5 | Consumer of editor `tilesmooth.cfg` | `globalparams.cfg:10` names it; grep finds no reader. |
| U6 | Value of `atilemap[W,*]` / `atilemap[*,H]` in sweeps | Array allocated but never assigned at those indices. |
| U7 | Whether `MapGetTileIndexByTileBlock` returns `-1` or another sentinel for unknown names | Binary implementation not read; engine behaviour assumed from name. |
| U8 | Whether donor chains are ever truncated at the `[0..63]`/`[0..23]`/`[0..15]` bounds | Only 22/9/6 observed; bounds untested. |
| U9 | Any live tile-selection script writing the ids that smoothing then reads | `texturemap.inc` is also fully commented (F05 E08/G9). |
| U10 | Exact numeric behaviour of `round(Abs(ind1-ind2))` (`:130`) | Integers already; assumed no-op. |
| U11 | Whether the rock5/rock2 no-op was an abandoned fix | Intent not recoverable from text. |
| U12 | Visual outcome of any vector in a live donor frame | No donor GPU A/B frame exists. |

---

## 11. Open questions (hand-off)

1. **D02/D03:** what is `RandomExt` at the moment D5 runs, and does the uninitialised
   `sumProb` become 0 in the shipped build? This decides exact roulette boundaries.
2. **D08:** does the binary ever call `SmoothTileMap`, and with how many passes? If yes,
   C2/A1 change from "donor intent" to observed runtime.
3. **F09:** is there a live reader of `globalparams.cfg:TileSmoothPasses` /
   `TileSmoothListFileName` outside `data/scripts/**` (e.g. editor binary)?
4. **COORD:** integrate §5.5 pseudocode into `spec/10` as the smoothing stage, and the
   §5.2 JSON schema into `spec/09`'s `decode_donor_cfg.py` contract.
5. **A05:** add V1–V11 as CPU unit tests for the fresh module; they are id-level,
   deterministic and require no donor frame.
6. **F05/D08:** decide Winter name handling (verbatim `_winter` chains vs index-preserving
   Summer alias) and record the choice as `PORT APPROXIMATION` until a season A/B exists.

---

## 12. Five-line hand-off summary

1. `[O]/[D]` Prototype parser reproduces **all** F03 counts and the exact file hash: 22 chains / 130 groups (118 active) / 310 entries (282 active) / 86 names / ΣProb **174.0168**; 0 unparsed lines.
2. `[O]` Donor has **no 3×3 kernel**: smoothing is an axis-aligned tile-pair edge rule, 3 passes, horizontal then vertical sweeps, in-place edits, one map write-back (`smoothtiles.inc:200-242`).
3. `[O]/[D]` Semantics recovered verbatim: min-|group1-group2| chain (first wins), distance 1 no-change, distance 2 middle-group pick, >2 inward step, no shared chain no-change; `Prob=0` names are endpoints, never picks.
4. `[D]` Both donor contradictions survived four passes and are preserved (6 vs 3 passes; `tilesmooth.cfg` vs `tilesmooth_scripts.cfg`); additionally found uninitialised accumulators, a no-op self-assignment and an uncompilable commented branch.
5. `PORT APPROXIMATION` only: §5.5 pseudocode + 11 exact id-level vectors are ready for the fresh Godot module; the whole consumer is commented `[U]` and **no donor visual-parity claim is made**.

*End of X08. Exactly one repo file written; prototype/JSON only in the approved temp directory.*
