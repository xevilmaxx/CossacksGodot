---
id: V20
ticket: "TERRAIN-SWARM-2026-11-26 / V20 (DONOR-FIRST terrain swarm)"
title: "Definitive TILE-SMOOTHING specification for I07/I08 — reconcile D08, X08, F03 and the port"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY
owner_file: "docs/terrain_swarm_2026-11-26/reports/V20_smoothing_reconciliation.md"
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope_guard: "Donor read-only; no donor binary executed, copied or committed. No repo source/shader/config/asset/test/git edit. No Godot runner job. Temp analysis scripts only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\."
target_used: "Donor text read directly from C:\\Games\\Cossacks 3 (files listed in §1). No Craft Anything target was opened or changed."
parity_claim: false
---

# V20 — Definitive tile-smoothing reconciliation (I07/I08)

## 0. Executive summary

1. **[D] Pass count settled: the skirmish/seeded-map path uses exactly 3 passes.** The only
   executable call site is `data/scripts/common.inc/smoothtiles.inc:237`
   `SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3)`, reached from
   `generatemap.inc:781-789` via `ExecuteState('SmoothTiles')` (`:786`). The cfg literal
   `TileSmoothPasses = 6` (`data/gen/globalparams.cfg:9`) has **no consumer in any
   `data/scripts/**` file** (full-file grep: 0 hits); it is editor-facing provenance,
   preserved as a donor contradiction (SWARM_BOARD C2), not the runtime value.
   Verified in four passes (§3.1).
2. **[O]/[D] The three reported count sets are the same object read at three granularities,
   not a conflict.** `22 Items` (X08/D08/F03) = parsed chains; `130 groups / 118 active`
   = groups; `310 entries` (X08/F03/RV_TRN_02) = **all** `TileName` lines, of which
   **282 are active** (D08's number); `28` are commented. `320 Prob` (RV_TRN_02) =
   282 active `Prob` + 38 commented `Prob` alternatives/annotations. Independent
   re-read of the donor file this agent reproduces 22/130/118/310/282/86/ΣProb=174.0168
   with zero unparsed lines (§2, §3.2).
3. **[D] Settled algorithm: snapshot once → 3 × (horizontal edge sweep, then vertical edge
   sweep) with *in-place* `atilemap` edits → one write-back.** The atomic operation is a
   **single axis-aligned adjacent tile pair**, never a 3×3 kernel (X08 §0 correction;
   `smoothtiles.inc:203-204,221-222`). A double-buffer is `PORT APPROXIMATION` and
   changes results (X08 V4–V6).
4. **[O]/[D] Roulette and compatibility rules are fixed verbatim:** `rnd = RandomExt * SumProb`,
   cumulative `(prob>0) and (rnd<tmp)`, raw unnormalised weights (including the authored
   `0.64/0.0028/0.36`, Σ=1.0028 anomaly); best chain = minimum `|group1-group2|` with
   first-in-file tie-break; Δ1 compatible/no-change, Δ2 middle-group pick, Δ>2 inward
   step from the farther tile, no shared chain → unchanged. Full ordered lists with
   donor line citations are in §3.4.
5. **[O]/[U] Eye-plane texgen equations and default planes are recovered** from
   `hf.pvl.sm.vert:9,26-34`, `hf.pvl.smx3.frag:13-17` and binary defaults at
   `cossacks.exe:0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4`; **effective per-frame planes and
   `gl_TextureMatrix[0]` stay [U] CONFIRMED_UNVERIFIED** after D08's six binary passes (§3.5).
6. **PORT APPROXIMATION** — the port embeds all 118 active lists but diverges in RNG source,
   guard conditions, art substitution, sweep edge bounds and stage order (§4). **No donor
   visual-parity claim is made anywhere in this report.**

## 1. Evidence table

| Ev id | Label | Source (donor path:line / repo path:line) | Claim |
|---|---|---|---|
| E01 | **[O]** | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc:4-7` | `ParserLoadFromFileByHandle(...,'.\data\gen\tilesmooth_scripts.cfg')`; `TileSmoothLists`; `Count` = chain count. |
| E02 | **[O]** | `smoothtiles.inc:9-27` | `TSmoothTile{TileName,TileIndex,Prob}`, `TSmoothTileList{SumProb,TileCount,SmoothTile[0..15]}`, `TItem{TileListsCount,SmoothTiles[0..23]}`, `Items[0..63]`, `atilemap[0..640]²`. Bounds, not counts. |
| E03 | **[O]** | `smoothtiles.inc:30-32,240-242` | One snapshot `atilemap[i,j]=GetTileIndex(i,j)`; one write-back `SetTileIndex(i,j,atilemap[i,j])`. |
| E04 | **[O]** | `smoothtiles.inc:35-60` | Parse loop; `tileIndex=MapGetTileIndexByTileBlock(tileName)` (`:51`); `sumProb+=prob` (`:53`); `SumProb` stored (`:58`); `var sumProb:Float;` uninitialised (`:42`). |
| E05 | **[O]** | `smoothtiles.inc:63-80` | `FindRandomTileIndex`: `Result=-1` (`:65`), `rnd=RandomExt*sumProb` (`:67`), `var tmp:Float;` uninitialised (`:68`), `tmp+=prob` (`:73`), `(prob>0) and (rnd<tmp)` (`:74`), return `TileIndex[k]` (`:76`). |
| E06 | **[O]** | `smoothtiles.inc:84-187` | `GetNeighbourTiles`: name lookup (`:95-96`), group indices with **no break** (`:108-123`), min-distance chain (`:126-136`), decision branches (`:139-186`). |
| E07 | **[O]** | `smoothtiles.inc:124-125` | `rock5`/`rock2` special case is `ind2ProbZero := ind2ProbZero` — a no-op. |
| E08 | **[O]** | `smoothtiles.inc:144-151` | Intended Prob-zero reroll is commented and syntactically invalid (`i1 + )` at `:147`). Inactive. |
| E09 | **[O]** | `smoothtiles.inc:191-235,237` | `SmoothTileMap(mini,minj,maxi,maxj,passes)`; `for k:=0 to passes-1` (`:197`); horizontal `i:=mini..maxi-1, j:=minj..maxj` (`:200-215`); vertical `j:=minj..maxj-1, i:=mini..maxi` (`:218-233`); call with passes=`3` (`:237`). |
| E10 | **[O]** | `data/scripts/common.inc/generatemap.inc:770-798` | `SetRandomExtKey64` (`:774`) → `ExecuteState('TextureMap')` (`:776`) → `ExecuteState('SmoothTiles')` (`:786`) → `ExecuteState('LoadTextureTerrainFromBitmap')` (`:795`); `//MapGeneratorSmoothTiles;` dead (`:784`). |
| E11 | **[O]** | `data/gen/globalparams.cfg:9-10` | `TileSmoothPasses = 6`; `TileSmoothListFileName = .\data\gen\tilesmooth.cfg`. |
| E12 | **[O]** | `data/gen/tilesmooth_scripts.cfg:1-1863` (64,017 B, SHA-256 `b82c8884…a531b433`) | Independent full re-parse by V20: 22 Items, 130 groups (118 active/12 commented), 310 `TileName` (282 active/28 commented), 86 distinct active names, ΣProb=174.0168; grammar exemplar `:1-35`; dead group `:37-50`; anomaly `:449-452`; terminators `:881-929`, `:1811-1859`. |
| E13 | **[O]** | `data/gen/tilesmooth.cfg:1-129` | 8 sections × 3–4 unweighted plain names = 30 `TileName`, no `Prob` (F03 §6.1). Not read by `smoothtiles.inc`. |
| E14 | **[D]** | `reports/F03_gen_config.md:37,52,597,806`, `spec/09_EDITOR_PARAMETERS.md:15,49-58` | Authoritative counts, both contradictions, "follow script for skirmish". |
| E15 | **[O]/[D]** | `reports/D08_tile_select_bin.md:20,118-215,290-319,321-333` | Algorithm transcription, id dictionary, detail pass, `bmTransparency` factors, eye-plane texgen, six binary passes on runtime planes. |
| E16 | **[O]/[D]** | `reports/X08_tile_smooth_engine.md:44-74,122-172,240-352,435-480` | Validated parse (matches F03), no 3×3 kernel, verbatim semantics, contradictions C2/C3 + anomalies A1–A6, 11 test vectors V1–V11. |
| E17 | **[O]** | `data/shaders/obj/hf.pvl.sm.vert:9,26-34`; `hf.pvl.smx3.frag:13-17`; `data/terrain/ref/reftile.mat:120-169` | Eye-space texgen equations and face-material overrides. |
| E18 | **[D]** | `data/shaders/obj/hf.pvl.sm.vert` © D08 ev ids `ev_64eb…`, `ev_97d7…`, `ev_79fc…`, `cossacks.exe:0x8f4aa4…0x8f4ad4` | Texgen mode map (1/2/7) and default planes S/T/R/Q; per-frame values [U]. |
| E19 | **[O]** | `variant3d/scripts/game.gd:1597-1604,1780-1797,2285-2346,2348-2355,2090-2149` | Current port: embedded 118 lists, `_tb_smooth_pair`, `_smooth_tilemap(brng,3)`, detail pass before smoothing, port-only guards/substitutions. |
| E20 | **[D]** | `docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md:764-765`, `docs/coord_swarm_2026-11-25/GAPS.md:31`, `docs/audit/TERRAIN_BLEND_DONOR_PLAN.md:105-127` | Prior-art corroboration of 22/130/118/310/282 and 3 passes; 320 `Prob` lines. |

## 2. Method and multi-pass discipline

* Direct, read-only re-read of all smoothing-relevant donor text (§1). Counts were recomputed
  by a temp-only Python state machine (`%TEMP%\opencode\v20_parse_smooth.py`) that tracks
  active vs `//`-commented frames by indentation and emits group/entry line numbers; it
  reproduces F03/X08 exactly. No donor binary was run; no repo file other than this report
  was written.
* Every contradiction was examined with **at least two instruments** before a verdict
  (full-file literal read, structural re-parse, script-wide grep, cross-report cross-check,
  prior-art comparison). Results are in §3.1–§3.2 and §5.
* Where a donor line is `;`-prefixed (all 246 lines of `smoothtiles.inc`), the decoded
  behaviour is **[U] donor intent**, not proven live runtime; X08 additionally found an
  uncompilable fragment at `:147`.

## 3. Settled algorithm

### 3.1 Pass count — 3, not 6 (four independent passes)

| Pass | Instrument | Result |
|---|---|---|
| 1 | `smoothtiles.inc:237` read directly | `SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3)` — literal **3**. |
| 2 | `globalparams.cfg:9-10` read directly | `TileSmoothPasses = 6`, path `tilesmooth.cfg`. |
| 3 | Full `data/scripts/**` grep (X08 E10; F03 U4/U5; D08 §2) | **0** references to `TileSmoothPasses` or `TileSmoothListFileName`; the only script load of a smoothing file is `smoothtiles.inc:5` → `tilesmooth_scripts.cfg`. |
| 4 | Call-site order `generatemap.inc:781-789` | `ExecuteState('SmoothTiles')` takes no pass argument; the pass count is internal to `:237`. `//MapGeneratorSmoothTiles;` at `:784` is dead. Prior art agrees (`TERRAIN_BLEND_DONOR_PLAN.md:125-127`, `DEC_05:451-456`, `spec/09:51-58`, `spec/10:55`, X08 §6 C2). |

**Settled [D]:** the skirmish/seeded-map path executes **3 passes**, each horizontal then
vertical, in place. `6` is preserved as an editor-facing cfg literal / donor contradiction
(C2); do not "fix" it. C3 (cfg path vs loaded file) is preserved likewise.

### 3.2 Count reconciliation — one structure, three granularities (three passes)

| Pass | Instrument | Result |
|---|---|---|
| 1 | D08 §0/§3.3 | 22 Items, 118 active lists, **282 tile entries**, 86 names. |
| 2 | F03 §2/§6.3, `spec/09:15`, X08 §4 | 22 chains, 130 groups (118 active), **310 `TileName` entries** (282 active), ΣProb=174.0168. RV_TRN_02 adds **320 `Prob` lines**. |
| 3 | V20 independent line-numbered re-parse of `tilesmooth_scripts.cfg:1-1863` | 22 Items; 130 groups = 118 active + 12 commented; 310 `TileName` lines = 282 active + 28 commented; **282 active `Prob` lines + 38 commented `Prob` lines = 320**; 86 distinct active names; ΣProb = 174.0168. Zero unparsed lines. |

**Settled [D]:** no conflict. D08 counted *active* entries; X08/F03 counted *all* entries;
RV_TRN_02 counted *all* `Prob` tokens. The two empty terminator Items (10 at `cfg:880`,
21 at `cfg:1810`) contain only commented groups and contribute 0 active lists. `C00` and
`C07` (winter `C11`, `C18`) each contain 1 dead group; the `//Prob = 0.36` alternatives at
`cfg:451,572,681` (winter `:1381,1502,1611`) are dead *values*, not extra entries.

### 3.3 Data structure, load and roulette (exact, `[O]`)

Grammar (`smoothtiles.inc:4-60`, `tilesmooth_scripts.cfg:1-35`):

```
section.begin
   TileSmoothLists : struct.begin
      [*] : struct.begin                  // Item/chain i       (bound Items[0..63]   :26)
         SmoothTiles : struct.begin
            [*] : struct.begin            // group j            (bound SmoothTiles[0..23] :23)
               TileNames : struct.begin
                  [*] : struct.begin      // entry k            (bound SmoothTile[0..15] :18)
                     TileName = <preset tile-block name>       // :50 -> MapGetTileIndexByTileBlock :51
                     Prob = <float>                            // :52 -> sumProb += prob :53
                  struct.end
               struct.end
            struct.end
         struct.end
      struct.end
   struct.end
section.end
```

* `//` at any indentation kills the token/frame on that line. A commented group makes the
  whole group dead (`cfg:37-50`, `:746-758`, `:882-929`, `:1811-1859`); a commented `Prob`
  inside a live entry is a dead alternative value (`cfg:451/452`). The *active* value wins.
* `SumProb` is the **raw group sum including `Prob=0` entries** (`smoothtiles.inc:53,58`).
  `var sumProb:Float;` at `:42` and `var tmp:Float;` at `:68` have **no initialiser** —
  `[U]` runtime value; the shipped data and all models assume 0 (`X08 A2`).
* Roulette (`smoothtiles.inc:63-80`): `rnd = RandomExt * SumProb` (`:67`);
  `tmp += Prob` (`:73`); first `k` with `(Prob>0) and (rnd<tmp)` returns `TileIndex[k]`
  (`:74,76`); otherwise `-1` (`:65`). Not normalised. A group whose entries are all
  `Prob=0` has `SumProb=0` ⇒ `rnd=0` ⇒ no pick ⇒ `-1` ⇒ no replacement.
* `Prob` is a **replacement weight only**. `Prob=0` names remain legal endpoints for the
  group-index lookup but can never be picked; do not remove or renormalise them. The
  `0.64/0.0028/0.36` group (`cfg:447-459`, Σ=1.0028) is authored and must be preserved
  (X08 V11 exercises it with `RandomExt=0.6392`).

### 3.4 Compatibility rules and full ordered lists (`[O]`, donor line citations)

**Chain search (`smoothtiles.inc:95-136`).** Resolve both ids to names (`:95-96`). For each
Item `i` in **source order**, scan every entry of every group; set `ind1/ind2` to the
containing group index `j` and record `Prob==0` flags (`:108-123`). The loops **do not
break**, so if a name occurs in two groups of one chain the **last** occurrence wins
(X08 V9: `test8` in C09 g3 and g4 → `ind1=4`). Require `ind1<>ind2` (`:126`), both `>-1`
(`:127`), and strict `Abs(ind1-ind2) < mindist` (`:128`) with `mindist := gc_MaxInt`
(`:99`) and `mindist := round(Abs(ind1-ind2))` (`:130`, integer no-op). Strict `<` means
**first Item in file order wins a distance tie**. `rock5`/`rock2` at `:124-125` is a
self-assignment no-op.

**Decision branches (`smoothtiles.inc:139-186`):**

| Case | Donor line | Action |
|---|---|---|
| No shared Item (`ilist=-1`) | `:182-186` | `out1=out2=-1` → unchanged. |
| `Abs(i1-i2)=1` and (`not i1ProbZero` **or** `not i2ProbZero`) | `:142-156` | compatible → `out1=out2=-1` → unchanged. (If *both* are zero-prob this fails and falls through to `:171-180`; with shipped data no adjacent-group pair is both zero-prob — X08 A6 — so unreachable.) |
| `i1-i2=2` | `:159-163` | `out1 = roulette(ilist, (i1+i2) div 2)`, `out2=-1`. |
| `i2-i1=2` | `:165-169` | `out1=-1`, `out2 = roulette(ilist, (i1+i2) div 2)`. |
| `i1<i2` (Δ>2) | `:171-175` | `out1=-1`, `out2 = roulette(ilist, i1+1)`. |
| else `i1>i2` (Δ>2) | `:176-180` | `out1 = roulette(ilist, i2+1)`, `out2=-1`. |

`(i1+i2) div 2` is a **list-index midpoint**, not a colour/height blend. The commented
replacement reroll at `:144-151` is inactive and uncompilable (`:147 i1 + )`).

**Full ordered lists.** Notation: `ITEM n @cfg:L` = Item `[*]` record line; `g k @cfg:L`
= active group `[*]` line; `{name=prob}` entries in source order; `DEAD` = `//`-commented
group excluded by the parser. `L` in parentheses is the exact `TileName`/`Prob` line.
Grammar exemplar is quoted verbatim at `cfg:1-35`; the 1.0028 anomaly at `cfg:449-452`.
Winter items 11–20 are exact `_winter` mirrors of items 0–9 (X08 §4, 11/11 verified).

```
ITEM 0  @cfg:3   (4 active / 1 dead)
  g0 @5   {sandsea1=1(L8), sandsea2=1(L12), sandsea3=1(L16), sandsea4=1(L20)}
  g1 @25  {sandsea5=0.7(L28), sandsea6=0.3(L32)}
  g2 @37  DEAD {sandrock1=0.4(L40), sandrock3=0.6(L45)}
  g3 @51  {rock9=0(L54), rock8=0(L58), rock5=0(L62)}
  g4 @67  {rock1=0.16(L70), rock2=0.16(L74), rock3=0.16(L78), rock6=0.16(L82), rock7=0.16(L86), rock4=0.20(L90)}
ITEM 1  @cfg:97  (6 active)
  g0 @99  {sandsea1=1(L102), sandsea2=1(L106), sandsea3=1(L110), sandsea4=1(L114)}
  g1 @119 {sandsea5=0.7(L122), sandsea6=0.3(L126)}
  g2 @131 {sandrock1=0.4(L134), sandrock3=0.6(L138)}
  g3 @143 {sandrock4=0.6(L146), sandrock2=0.4(L150)}
  g4 @155 {grass1=1(L158), grass2=1(L162), test8=1(L166)}
  g5 @171 {grass7=0.25(L174), test12=0.25(L178), test13=0.25(L182), test14=0.25(L186)}
ITEM 2  @cfg:193 (6 active)
  g0 @195 {sandsea1=1(L198), sandsea2=1(L202), sandsea3=1(L206), sandsea4=1(L210)}
  g1 @215 {sandsea5=0.7(L218), sandsea6=0.3(L222)}
  g2 @227 {sandrock1=0.4(L230), sandrock3=0.6(L234)}
  g3 @239 {sandrock4=0.6(L242), sandrock2=0.4(L246)}
  g4 @251 {grass1=1(L254), grass2=1(L258), test8=1(L262)}
  g5 @267 {test7=1(L270), grass8=1(L274), test6=1(L278)}
ITEM 3  @cfg:285 (9 active)
  g0 @287 {sandsea1=1(L290), sandsea2=1(L294), sandsea3=1(L298), sandsea4=1(L302)}
  g1 @307 {sandsea5=0.7(L310), sandsea6=0.3(L314)}
  g2 @319 {sandrock1=0.4(L322), sandrock3=0.6(L326)}
  g3 @331 {sandrock4=0.6(L334), sandrock2=0.4(L338)}
  g4 @343 {grass1=1(L346), grass2=1(L350), test8=1(L354)}
  g5 @359 {grass9=1(L362)}
  g6 @367 {test9=1(L370)}
  g7 @375 {grass3=1(L378)}
  g8 @383 {grass4=0.9(L386), grass10=0.1(L390)}
ITEM 4  @cfg:397 (9 active)
  g0 @399 {rock1=0.16(L402), rock2=0.16(L406), rock3=0.16(L410), rock6=0.16(L414), rock7=0.16(L418), rock4=0.20(L422)}
  g1 @427 {rock8=0.5(L430), rock5=0.5(L434)}
  g2 @439 {rock9=1(L442)}
  g3 @447 {grass_ground1=0.64(L450), grass_ground2=0.0028(L455), grass_ground3=0.36(L459)}   // //Prob=0.36 at L451 dead
  g4 @464 {grass1=1(L467), grass2=1(L471), test8=1(L475)}
  g5 @480 {grass9=1(L483)}
  g6 @488 {test9=1(L491)}
  g7 @496 {grass3=1(L499)}
  g8 @504 {grass4=0.9(L507), grass10=0.1(L511)}
ITEM 5  @cfg:518 (8 active)
  g0 @520 {rock1=0.16(L523), rock2=0.16(L527), rock3=0.16(L531), rock6=0.16(L535), rock7=0.16(L539), rock4=0.20(L543)}
  g1 @548 {rock8=0.5(L551), rock5=0.5(L555)}
  g2 @560 {rock9=1(L563)}
  g3 @568 {grass_ground1=0.64(L571), grass_ground2=0.0028(L576), grass_ground3=0.36(L580)}   // //Prob=0.36 at L572 dead
  g4 @585 {grass1=1(L588), grass2=1(L592), test8=1(L596)}
  g5 @601 {test7=1(L604)}
  g6 @609 {grass8=1(L612)}
  g7 @617 {test6=1(L620)}
ITEM 6  @cfg:627 (6 active)
  g0 @629 {rock1=0.16(L632), rock2=0.16(L636), rock3=0.16(L640), rock6=0.16(L644), rock7=0.16(L648), rock4=0.20(L652)}
  g1 @657 {rock8=0.5(L660), rock5=0.5(L664)}
  g2 @669 {rock9=1(L672)}
  g3 @677 {grass_ground1=0.64(L680), grass_ground2=0.0028(L685), grass_ground3=0.36(L689)}   // //Prob=0.36 at L681 dead
  g4 @694 {grass1=1(L697), grass2=1(L701), test8=1(L705)}
  g5 @710 {grass7=0.25(L713), test12=0.25(L717), test13=0.25(L721), test14=0.25(L725)}
ITEM 7  @cfg:732 (3 active / 1 dead)
  g0 @734 {rock9=1(L737), test8=0(L741)}
  g1 @746 DEAD {grass_ground1=0.36(L749), grass_ground2=0.28(L753), grass_ground3=0.36(L757)}
  g2 @762 {grass5=1(L765)}
  g3 @770 {grass6=1(L773)}
ITEM 8  @cfg:780 (3 active)
  g0 @782 {rock9=1(L785)}
  g1 @790 {grass5=1(L793)}
  g2 @798 {grass_ground1=0.36(L801), grass_ground2=0.28(L805), grass_ground3=0.36(L809)}
ITEM 9  @cfg:816 (5 active)
  g0 @818 {ground1=1(L821)}
  g1 @826 {test2=1(L829)}
  g2 @834 {test1=1(L837), test3=1(L841)}
  g3 @846 {test8=0.4(L849), test7=0.6(L853)}     // //TileName=grass2 at L857 is commented
  g4 @862 {grass1=1(L865), grass2=1(L869), test8=1(L873)}
ITEM 10 @cfg:880 — EMPTY TERMINATOR: 4 dead groups @882,890,902,914; 0 active lists.
ITEM 11 @cfg:933  = ITEM 0  with `_winter` suffix (4 active/1 dead; g0 @935, g1 @955, DEAD g2 @967, g3 @981, g4 @997)
ITEM 12 @cfg:1027 = ITEM 1  (g0 @1029, g1 @1049, g2 @1061, g3 @1073, g4 @1085, g5 @1101)
ITEM 13 @cfg:1123 = ITEM 2  (g0 @1125, g1 @1145, g2 @1157, g3 @1169, g4 @1181, g5 @1197)
ITEM 14 @cfg:1215 = ITEM 3  (g0 @1217 … g8 @1313; grass4_winter=0.9(L1316), grass10_winter=0.1(L1320))
ITEM 15 @cfg:1327 = ITEM 4  (g0 @1329 … g8 @1434; anomaly g3 @1377: 0.64(L1380)/0.0028(L1385)/0.36(L1389))
ITEM 16 @cfg:1448 = ITEM 5  (g0 @1450 … g7 @1547; anomaly g3 @1498)
ITEM 17 @cfg:1557 = ITEM 6  (g0 @1559 … g5 @1640; anomaly g3 @1607)
ITEM 18 @cfg:1662 = ITEM 7  (g0 @1664 {rock9_winter=1(L1667),test8_winter=0(L1671)}; DEAD @1676; g2 @1692; g3 @1700)
ITEM 19 @cfg:1710 = ITEM 8  (g0 @1712, g1 @1720, g2 @1728 {grass_ground1_winter=0.36(L1731),grass_ground2_winter=0.28(L1735),grass_ground3_winter=0.36(L1739)})
ITEM 20 @cfg:1746 = ITEM 9  (g0 @1748, g1 @1756, g2 @1764, g3 @1776, g4 @1792)
ITEM 21 @cfg:1810 — EMPTY TERMINATOR: 4 dead groups @1812,1820,1832,1844; 0 active lists.
```
Winter `Prob` values and group boundaries are byte-identical to the Summer mirror after
removing `_winter` (F03 F7; X08 §4 11/11). Winter selection logic is **[U]** (§7 U4).

### 3.5 Sweeps, pass order, write-back (`[O]`)

```
smoothtiles.inc:30-32   for j:=0..GetMapHeight-1: for i:=0..GetMapWidth-1: atilemap[i,j]:=GetTileIndex(i,j)
smoothtiles.inc:197     for k:=0 to passes-1
smoothtiles.inc:200-215   for i:=mini to maxi-1: for j:=minj to maxj:     // HORIZONTAL, j INCLUSIVE of maxj
                            compare (i,j) with (i+1,j); write atilemap[i,j] / [i+1,j] in place (:210,:213)
smoothtiles.inc:218-233   for j:=minj to maxj-1: for i:=mini to maxi:     // VERTICAL, i INCLUSIVE of maxi
                            compare (i,j) with (i,j+1); write atilemap[i,j] / [i,j+1] in place (:228,:231)
smoothtiles.inc:237     SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3)
smoothtiles.inc:240-242 for j:=0..H-1: for i:=0..W-1: SetTileIndex(i,j,atilemap[i,j])
```
**[D]** One snapshot, 3 in-place passes, one write-back. Later edges in the same sweep and
all later passes see earlier replacements (X08 A1; vectors V4–V6). The sweep reaches
`atilemap[W,*]` / `[* ,H]`, which the snapshot never assigns; the array bound `[0..640]`
permits the index but its value is **[U]** (X08 A5). No 3×3 kernel exists — the pair
calls at `:203-204,221-222` take exactly two cells.

### 3.6 Eye-plane texgen — recovered equations and planes (`[O]`/`[D]`; runtime `[U]`)

From `hf.pvl.sm.vert` (quoted by line):

```
9:   vec4 realpos = gl_ModelViewMatrix*gl_Vertex;                    // EYE space
26:  if(texGen==0) gl_TexCoord[0]=gl_TextureMatrix[0]*gl_MultiTexCoord0;
30:  gl_TexCoord[0].s = dot(realpos, gl_EyePlaneS[0]);               // else branch
31:  gl_TexCoord[0].t = dot(realpos, gl_EyePlaneT[0]);
32:  gl_TexCoord[0]   = gl_TextureMatrix[0]*gl_TexCoord[0];
34:  gl_TexCoord[1]   = gl_MultiTexCoord1;                          // alpha patch UV, mesh supplied
```
`hf.pvl.smx3.frag:13-17`: `color.rgb=texture2D(texUnit0, gl_TexCoord[0].xy).rgb`,
`color.a=texture2D(texUnit1, gl_TexCoord[1].xy).a`,
`color.xyz=color.xyz*gl_TexCoord[4].xyz+gl_TexCoord[5].xyz`, `gl_FragColor=color` (`:50`).

**[D] Binary texgen state machine** (D08 `ev_97d7…`, `cossacks.exe:0x4ec3f0`): mappingmode
`1=tmmObjectLinear`, `2=tmmEyeLinear`, `7=tmmEyePlane` build `glTexGeni/glTexGenfv`
planes; `0=tmmUser` (ground `reftile.mat`) makes no texgen calls but the shader still
uses `gl_EyePlaneS/T[0]`. **Default plane constants [O]**: `S=(1,0,0,0)` @`0x8f4aa4`,
`T=(0,1,0,0)` @`0x8f4ab4`, `R=(0,0,1,0)` @`0x8f4ac4`, `Q=(0,0,0,1)` @`0x8f4ad4`.
Face materials `reftile.mat:120-169` override `TextureScale=0.125`, eye-linear S/T on
X/Z (front) or Y/Z (side). `sub_4be364` (`ev_79fc…`) sets per-frame planes on texture
unit 0 with caller-supplied values. **[U] CONFIRMED_UNVERIFIED:** effective per-frame
`gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` (D08's six binary passes found computed
pointers/runtime state). No donor literal for the port's `uv_repeat=(0.5,0.5)` was found —
that value is **PORT APPROXIMATION**.

## 4. What the port currently does — and what is PORT APPROXIMATION

**[O] Current implementation** (`variant3d/scripts/game.gd`):

* All **118 active lists** are embedded as `const DONOR_SMOOTH_RULES` at `:1604` (comment
  at `:1597-1603`), with `J` = index of the active list inside its Item. `tbl_smooth` is
  built at `:1786-1797`; `_winter` names are **stripped to the Summer alias** at
  `:1793-1794` (donor winter name space is not used).
* `_tb_smooth_pair()` `:2285-2346` implements the min-distance chain search, Δ1/Δ2/>2
  branches and cumulative roulette; `_smooth_tilemap(brng,3)` `:2348-2355` runs 3 passes.
* Stage order around the smoother (`:2090-2149`): `_apply_shore_cliffs()` →
  `_apply_detail_pass()` (**before** smoothing) → `tls_*` ground1 paint →
  `_stamp_grass_spots()` → `_smooth_tilemap(brng,3)` → `_stamp_forest_borders()` → mine-apron
  authority → Y08 final collapse of ordinary land to `test8`.

**PORT APPROXIMATION** (every item a divergence from the donor text, not a parity claim):

| # | Port behaviour | Donor rule | Label |
|---|---|---|---|
| P1 | Uses shared `brng.randf()` with many other stage draws instead of donor `RandomExt` at the smoothing stage; stream position unknown (D02). | `rnd=RandomExt*SumProb` (`smoothtiles.inc:67`) | **PORT APPROX / [U]** |
| P2 | Early-returns on `mine_mask`, `BLK_WATER`, equal ids and `tbl_names` bounds (`:2288-2295`). | Only `tind1<>tind2` guard (`:205,:223`) | **PORT APPROX** |
| P3 | `_tb_pick` redirects `grass_ground1/2/3` art to `grass9/test8/test7` (`:2276-2281`, B03-P3). | Roulette returns the picked name's id (`:76`) | **PORT APPROX** |
| P4 | Sweep loops use `x∈[0,W-1]`, `y∈[0,H-1]` only (`:2350-2354`). | Horizontal `j` inclusive `maxj`, vertical `i` inclusive `maxi` (`:200-219`) | **PORT APPROX** |
| P5 | Detail pass runs **before** smoothing (`:2097`); extra tls/spots/forest-border/final-collapse stages (`:2099-2149`). | `TextureMap → SmoothTiles → LoadTextureTerrainFromBitmap` (`generatemap.inc:776,786,795`) | **PORT APPROX** |
| P6 | `_winter` names aliased to Summer ids (`:1793-1794`). | C11–C20 are distinct `_winter` chains; season switch **[U]** | **PORT APPROX / [U]** |
| P7 | `prob<=0.0` test and `float` arithmetic; no `Decimal` accumulator; `<=0` vs donor `=0` (`:2315,:2318`). | `(prob=0)` flags, `Float` (`:115,:120`) | equivalent for shipped data, **PORT APPROX** in general |
| P8 | Rules embedded in code, not read from a cfg asset (`:1780`). | Runtime loads `tilesmooth_scripts.cfg` (`smoothtiles.inc:5`) | data-equivalent; **PORT APPROX** plumbing |

The port's **pass count (3) and 118-list data are donor-faithful**; the rest above must be
labelled if kept.

## 5. Donor contradictions preserved (multi-pass verdicts)

| # | Contradiction | Pass 1 | Pass 2 | Pass 3 / 4 | Verdict |
|---|---|---|---|---|---|
| C2 | `TileSmoothPasses=6` (`globalparams.cfg:9`) vs `SmoothTileMap(...,3)` (`smoothtiles.inc:237`) | cfg literal | script literal | grep 0 consumers + prior art + X08 §6 | **Preserve.** Skirmish=3; 6 editor-only. `[D]` |
| C3 | `tilesmooth.cfg` path (`globalparams.cfg:10`) vs `tilesmooth_scripts.cfg` loaded (`smoothtiles.inc:5`) | cfg literal | script load | grep: only `:5` references either; `tilesmooth.cfg` re-counted 8/30/129 | **Preserve.** Weighted file is runtime; plain file editor-only. `[D]` |
| A1 | "snapshot then write back once" gloss (`TERRAIN_BLEND_DONOR_PLAN.md:118`) vs in-place writes (`:210,213,228,231`) | prior art | donor lines | snapshot `:30-32`, evaluator V4–V6 | Prior art imprecise; **in-place** wins. `[D]` |
| A2 | Uninitialised `sumProb` `:42` / `tmp` `:68` | byte read | X08 A2 byte re-read | no binary consumer | **[U]**; model 0 = **PORT APPROX** |
| A3 | Uncompilable commented reroll `i1 + )` `:147` | byte read | byte re-read | `{…}` block `:144-151`, all lines `;` | Script = **intent**, not provable live code `[U]` |
| A4 | `rock5`/`rock2` `:124-125` | donor line | byte re-read | prior art no-op, parser confirms | **No semantic effect**; omit but document `[D]` |
| A5 | Sweep reads unassigned `atilemap[W,*]`/`[*,H]` | loop bounds | snapshot bounds | array `[0..640]` | **[U]** value; likely no-chain/no-change |
| A6 | Δ1 with both endpoints `Prob=0` falls through (`:142` fails) | donor branch | parser census: 0 shipped pairs | evaluator | Branch exists but **unreachable** with shipped data `[D]` |

No contradiction was silently skipped; none was "fixed" in the donor text.

## 6. GDScript pseudocode implementation (exact donor constants only)

Faithful translation of `smoothtiles.inc:4-242`. **No invented constants**: the only
literals below are donor ones (`22`-item source order from the cfg, `0/1/2` distance cases,
`div 2`, `-1` sentinel, `3` passes, `gc_MaxInt`, `0.64/0.0028/0.36` as *data* from the cfg).
`RandomExt` and the initial value of the accumulators are **[U]** and must be injected and
labelled (§7). Name↔id resolution uses the `terrain.presets` dictionary (ids 0–123);
`MapGetTileIndexByTileBlock` semantics are **[U]** (D08 U2).

```gdscript
# DONOR-FAITHFUL SKELETON — donor intent, not proven live runtime ([U]).
# Data: one array per Item, one array per active group, one dict per entry:
#   {name:String, id:int, prob:float}, groups/entries in SOURCE order.
#   Prob=0 entries stay in the list; commented groups/entries are excluded.
#   domain: preset ids 0..123 (terrain.presets); sentinel -1 = "no pick".

func load_smooth_lists(path: String) -> Array:
    # smoothtiles.inc:4-60. Skip every //-commented frame; keep active Prob only.
    # Resolve TileName -> preset id (:50-51); SumProb = sum of ALL active Prob
    # in the group (:53,:58). The donor leaves sumProb uninitialised [U];
    # we model 0 explicitly (PORT APPROXIMATION).
    var items: Array = []
    for chain_node in parse_struct(path, "TileSmoothLists"):   # :6-7
        var groups: Array = []
        for group_node in chain_node["SmoothTiles"]:            # :38-40
            var entries: Array = []
            var sum_prob: float = 0.0                            # [U] donor :42
            for entry_node in group_node["TileNames"]:           # :44-46
                var nm: String = entry_node["TileName"]           # :50
                var idx: int = preset_index_of(nm)                # :51 [U] semantics
                var prob: float = float(entry_node["Prob"])       # :52 (Decimal in compiler)
                sum_prob += prob                                  # :53
                entries.append({"name": nm, "id": idx, "prob": prob})
            groups.append({"entries": entries, "sum_prob": sum_prob}) # :58
        items.append(groups)                                     # :39, :26 bound [0..63]
    return items                                                 # Count = 22 observed

func find_random_tile_index(items: Array, i: int, j: int, random_ext: float) -> int:
    # smoothtiles.inc:63-80
    var result: int = -1                                         # :65
    var group: Dictionary = items[i][j]
    var sum_prob: float = group["sum_prob"]
    var rnd: float = random_ext * sum_prob                        # :67
    var tmp: float = 0.0                                         # [U] donor :68 uninitialised
    for e in group["entries"]:                                    # :70
        var prob: float = e["prob"]
        tmp += prob                                               # :73
        if prob > 0.0 and rnd < tmp:                              # :74
            return int(e["id"])                                   # :76
    return result                                                 # :80 (all-zero group -> -1)

func get_neighbour_tiles(items: Array, i2name: Array, t1: int, t2: int,
                         random_ext: float) -> Array:
    # smoothtiles.inc:84-187. Returns [out1, out2]; -1 = "do not change".
    var name1: String = i2name[t1]                                # :95
    var name2: String = i2name[t2]                                # :96
    var ilist: int = -1                                           # :98
    var mindist: int = gc_MaxInt                                  # :99
    var i1: int = -1; var i2: int = -1                            # :100-101
    var i1_prob_zero: bool = false; var i2_prob_zero: bool = false
    for i in items.size():                                        # :102 (source order!)
        var ind1: int = -1; var ind2: int = -1                    # :104-105
        var ind1_zero: bool = false; var ind2_zero: bool = false  # :106-107
        for j in items[i].size():                                 # :108
            for e in items[i][j]["entries"]:                       # :110 NO break
                if e["name"] == name1:                            # :112
                    ind1 = j                                       # :114 (last match wins)
                    ind1_zero = (e["prob"] == 0.0)                 # :115
                if e["name"] == name2:                            # :117
                    ind2 = j                                       # :119
                    ind2_zero = (e["prob"] == 0.0)                 # :120
        # :124-125 rock5/rock2 self-assignment is a NO-OP — intentionally omitted.
        if ind1 != ind2 and ind1 > -1 and ind2 > -1:              # :126-127
            if absi(ind1 - ind2) < mindist:                        # :128 STRICT <
                mindist = absi(ind1 - ind2)                        # :130 (round() no-op)
                i1_prob_zero = ind1_zero; i2_prob_zero = ind2_zero # :131-132
                i1 = ind1; i2 = ind2; ilist = i                    # :133-135
    if ilist == -1:
        return [-1, -1]                                            # :182-186
    if absi(i1 - i2) == 1 and (not i1_prob_zero or not i2_prob_zero):
        return [-1, -1]                                            # :142-156 compatible
    if i1 - i2 == 2:                                               # :159-163
        return [find_random_tile_index(items, ilist, (i1 + i2) / 2, random_ext), -1]
    if i2 - i1 == 2:                                               # :165-169
        return [-1, find_random_tile_index(items, ilist, (i1 + i2) / 2, random_ext)]
    if i1 < i2:                                                    # :171-175
        return [-1, find_random_tile_index(items, ilist, i1 + 1, random_ext)]
    return [find_random_tile_index(items, ilist, i2 + 1, random_ext), -1]  # :176-180

func smooth_tile_map(atilemap: Array, w: int, h: int, i2name: Array,
                     random_ext: float) -> void:
    # smoothtiles.inc:191-235. atilemap already snapshotted once (:30-32).
    for _k in 3:                                                   # :197, call :237 PASSES=3
        for i in range(0, w - 1):                                  # :200 outer i
            for j in range(0, h + 1):                              # :201 j INCLUSIVE of maxj
                var t1: int = atilemap[i][j]                       # :203
                var t2: int = atilemap[i + 1][j]                   # :204
                if t1 != t2:                                        # :205
                    var ch: Array = get_neighbour_tiles(items_cache, i2name, t1, t2, random_ext) # :207
                    if ch[0] > -1: atilemap[i][j] = ch[0]          # :209-210 IN PLACE
                    if ch[1] > -1: atilemap[i + 1][j] = ch[1]      # :212-213 IN PLACE
        for j in range(0, h - 1):                                  # :218 outer j
            for i in range(0, w + 1):                              # :219 i INCLUSIVE of maxi
                var t1: int = atilemap[i][j]                       # :221
                var t2: int = atilemap[i][j + 1]                   # :222
                if t1 != t2:                                        # :223
                    var ch: Array = get_neighbour_tiles(items_cache, i2name, t1, t2, random_ext) # :225
                    if ch[0] > -1: atilemap[i][j] = ch[0]          # :227-228 IN PLACE
                    if ch[1] > -1: atilemap[i][j + 1] = ch[1]      # :230-231 IN PLACE
    # Single write-back afterwards: smoothtiles.inc:240-242.
    for j in range(0, h):
        for i in range(0, w):
            set_tile_index(i, j, atilemap[i][j])
```
Notes: `items_cache` is the loaded array (passed here for readability). `gc_MaxInt` is the
donor sentinel from `smoothtiles.inc:99`; `preset_index_of` must emit ids 0–123 from
`terrain.presets:6-129`/`:138-261` (F05 E01). `random_ext` must be supplied per draw from
an injected deterministic RNG and labelled **PORT APPROXIMATION** (D02/X08 U3). The
inclusive `w`/`h` edge reads are retained but their values are **[U]** (X08 A5). X08's
11 vectors V1–V11 are the unit-test oracle; they are id-level and need no donor frame.

## 7. Implications for spec §06 and §10

**§06 (tile ids and atlas):**

1. **[D]** Add a smoothing subsection: the smoother is an **id-level** transform over
   preset ids 0–123, round-tripping through tile-block names
   (`MapGetTileIndexByTileBlock` / `MapGetTileBlockByTileIndex`, `smoothtiles.inc:51,95-96`).
   Only **86** names participate; face ids 35–70, alpha sentinels 86/110/123, desert
   111–122 and water have no chain and are left unchanged (`:182-186`). Do not repair
   sentinels inside the smoother.
2. **[D]/[U]** Winter C11–C20 are exact `_winter` mirrors; no donor season switch was found.
   The port's suffix-stripping alias (game.gd:1793-1794) is **PORT APPROXIMATION**; mirror
   the data verbatim and document the alias choice.
3. **[D]** The §06 alpha holes/face reuse are rendering concerns (F06); the smoother
   changes ids only — never atlas cells or alpha masks. Keep §06's `APPROX_ATLAS_PACKING`
   label; no donor packing was recovered (D08 §3.1).
4. **[O]/[U]** Detail-bitmap pass (`loadtextureterrainfrombitmap.inc:4-49`) is *after*
   smoothing in donor call order (`generatemap.inc:786,795`) and writes only where
   `GetTileIndex=0`; the port runs it before smoothing (P5). Preserve the donor order claim
   as authored intent **[U]** and the port order as **PORT APPROXIMATION**.

**§10 (stage order):**

5. **[O]/[D]** Replace the one-line "3 passes, probability tables (D5…)" row with the
   full settled algorithm: `TextureMap → SmoothTiles → LoadTextureTerrainFromBitmap`
   (`generatemap.inc:776,786,795`); 3 passes; snapshot once → in-place H-then-V sweeps →
   one write-back; 22/118/310 data; `tilesmooth_scripts.cfg`, not `tilesmooth.cfg`.
   Cross-link X08 §5.5 pseudocode and vectors V1–V11.
6. **[D]** Keep the C2/C3 contradictions in the spec's contradiction register (already at
   `spec/09:49-58`, SWARM_BOARD C2/C3); do not resolve them by choosing 6 or the plain cfg.
7. **[U]** `RandomExt` stream position at this stage is D02's contract; a fresh module
   must inject a documented per-stage RNG and label it **PORT APPROXIMATION**. No exact
   roulette boundary claim without it.
8. **[D]** The four branches (no-change / midpoint / inward step / no-chain) are complete
   once `ind1≠ind2` is enforced; no extra blend, threshold, noise or dither may be added
   (charter §4, S-25-09).

## 8. Risks

| Risk | Label | Mitigation |
|---|---|---|
| Implementing 6 passes from `globalparams.cfg:9` | `[D]` | Follow `smoothtiles.inc:237` (3); preserve 6 as editor-only provenance. |
| Feeding `tilesmooth.cfg` (30 unweighted names) to the roulette | `[O]` | Load `tilesmooth_scripts.cfg` (`:5`); 118 active weighted groups. |
| Renormalising `1.0028`, dropping `Prob=0` names, or rounding weights | `[O]/[D]` | Keep literal weights; X08 V3/V11 are regression tests. |
| Taking the first instead of last name occurrence in a chain | `[D]` | No `break` at `:110-123`; X08 V9 regression. |
| Double-buffering the sweep / wrong sweep bounds | `[D]` | In-place writes `:210,213,228,231`; inclusive `j=maxj`, `i=maxi`; V4–V6. |
| Treating the `;`-commented script as live proven code | `[U]` | All semantics = donor intent; `:147` would not compile. |
| Assuming the uninitialised accumulators are 0 in the shipped build | `[U]` | Model 0 explicitly; never claim exact pick thresholds. |
| Winter chains assumed selected by season | `[U]` | Mirror data; alias choice labelled **PORT APPROX**. |
| Reading unassigned `atilemap[W,*]`/`[*,H]` as 0 | `[U]` | Registered, no test vector depends on it. |
| Port art substitution / extra stages / brng stream | **PORT APPROX** | Keep labels in code comments; no visual-parity claim. |
| Visual parity inferred from correct ids | `[U]` | No donor GPU A/B frame exists; charter §3 forbids the claim. |
| Shared Craft Anything session / concurrent report landings | `[I]` | This agent opened no target and wrote only its own report; X08 landed mid-audit and was re-read in full. |

## 9. UNVERIFIED register

1. **U1** Whether `smoothtiles.inc` executes at all — all 246 lines `;`-prefixed; `:147` uncompilable.
2. **U2** Runtime value of uninitialised `sumProb` (`:42`) / `tmp` (`:68`) — no binary consumer read.
3. **U3** `RandomExt` stream position/seed when `SmoothTileMap` runs — D02 owns seed/RNG.
4. **U4** Season switch selecting C11–C20 — no script reader found; port alias is **PORT APPROX**.
5. **U5** Consumer of editor `tilesmooth.cfg` (8 plain groups) — `globalparams.cfg:10` names it; no reader.
6. **U6** Value of `atilemap[W,*]` / `atilemap[*,H]` — array allocated but never assigned there.
7. **U7** `MapGetTileIndexByTileBlock` semantics and sentinel for unknown names (D08 U2).
8. **U8** `round(Abs(ind1-ind2))` at `:130` — integers already; assumed no-op.
9. **U9** Whether the rock5/rock2 no-op (`:124-125`) was an abandoned fix — intent unrecoverable.
10. **U10** Whether `bmTransparency` composes more than one layer per cell / in what order — D08 U5.
11. **U11** Effective `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` at draw time — D08's six binary passes; runtime state.
12. **U12** Donor `tsDouble`/`ttExtended` atlas packing and tile→alpha patch selector — D08 U3/U4.
13. **U13** Runtime activity of `texturemap.inc` and `loadtextureterrainfrombitmap.inc` (also `;`-commented).
14. **U14** Any donor GPU A/B frame — none produced; all visual consequences structural only.

## 10. Open questions (hand-off)

1. **D02/D03:** what is `RandomExt` at the moment D5 runs, and do the uninitialised accumulators
   evaluate to 0 in the shipped build? This decides exact roulette boundaries.
2. **D08/binary:** does `cossacks.exe` ever call `SmoothTileMap`, and with how many passes?
   If yes, C2/A1/U1 change from "intent" to observed runtime.
3. **F09/D09:** is there a live reader of `TileSmoothPasses` / `TileSmoothListFileName`
   outside `data/scripts/**` (e.g. the editor binary)?
4. **A05:** adopt X08 V1–V11 as CPU unit tests for the fresh module (id-level, deterministic,
   no donor frame needed).
5. **COORD:** integrate §3.4/§6 of this report into `spec/10`; keep §06 as id-space/atlas
   only; record V20's settlement of C2/C3 without deleting the contradictions.
6. **F05/D08:** decide Winter name handling (verbatim `_winter` chains vs index-preserving
   Summer alias) and label the choice **PORT APPROXIMATION** until a season A/B exists.

## 11. Five-line hand-off summary

1. **[D]** Skirmish smoothing = **3** passes (`smoothtiles.inc:237`); `TileSmoothPasses=6` (`globalparams.cfg:9`) has no consumer — preserve, don't fix (C2); `tilesmooth_scripts.cfg` is the loaded file (C3).
2. **[O]/[D]** Counts reconciled: 22 Items / 130 groups (118 active) / 310 entries (282 active) / 86 names / ΣProb=174.0168; D08's 282 = active subset of X08/F03's 310; RV_TRN_02's 320 = 282 active + 38 commented `Prob`.
3. **[D]** Settled algorithm: one snapshot → 3 × in-place H-then-V edge sweeps → one write-back; roulette `RandomExt*SumProb` with raw weights and `(prob>0)&&(rnd<tmp)`; min-|Δgroup| chain, first wins; Δ1 no-change, Δ2 midpoint pick, Δ>2 inward step, no chain unchanged; full ordered lists with donor lines in §3.4.
4. **[O]/[U]** Eye-plane equations and default planes recovered (`hf.pvl.sm.vert:9,26-34`; binaries `0x8f4aa4…0x8f4ad4`); per-frame planes/matrix remain UNVERIFIED; port matches pass count + 118 lists but diverges in RNG, guards, art substitution, edge bounds and stage order (**PORT APPROXIMATION**).
5. **No donor visual-parity claim.** All commented donor text remains `[U]` intent; uninitialised accumulators, winter chain selection and the `Prob=0`/1.0028 anomalies are preserved verbatim; §6 GDScript skeleton uses exact donor constants only.

*End of V20. Exactly one repo file written: this report. Temp analysis script lives outside the repo. No donor binary run/copied; no source/shader/config/asset/test/git/Godot state changed.*
