---
id: V12
date: 2026-11-26
wave: Verify / reconciliation (DONOR-FIRST terrain swarm)
title: "Definitive, implementation-ready RESOURCE PLACEMENT specification — reconciling D07 with A02/X03 and the stage-order spec"
agent: "V12 (verification subagent, one-report-only)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V12_resource_spec.md
status: LANDED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_BINARY_EXECUTED
donor_root: "C:\\Games\\Cossacks 3 (READ ONLY, private use; no donor binary executed, no donor file copied or committed)"
labels: ["[O] observed", "[D] derived", "[I] inferred", "[U] UNVERIFIED", "PORT APPROXIMATION"]
parity_claim: false
cross_checks: ["reports/D07_resources_bin.md", "reports/A02_algorithm.md", "reports/X03_dscript_corpus.md", "spec/10_STAGE_ORDER.md", "spec/07_RESOURCES.md", "reports/V15_acceptance_without_reference.md", "reports/P05_2d_reuse.md"]
notes: "X09_starting_settings.md and F08_flora_minerals.md were NOT landed at write time; no data from them is used."
---

# V12 — Definitive resource-placement specification

## 0. Executive summary

1. **[O] Authority is donor text, not a recovered native function.** D07's binary lane found 0
   functions named `SetupMines`/`SetupStartingResources`/`FillOwnerMap` (discovery truncated at
   6,000,000 instructions) and rejected the clean-room pseudo-C for `sub_71c0b4` because
   `0x71c0a5` is ASCII `XMap…` lifted as `pop eax`. This V12 re-read the raw donor scripts
   directly; all placement claims below are quoted from `dogenerate.inc:N`, `misc.script:N`,
   `dmscript.global:N`. No donor binary was run. **No donor-parity claim.**
2. **[O] Mines are ring-indexed, not ore-indexed.** `dogenerate.inc:535` outer loop is `i` = ring,
   `:544-550` middle loop is `j` = ore (`mng`/`mni`/`mnc`; `desert_` prefix at `:552-553`), and
   `:525,:555,:704` give **256 angle attempts per ore per ring**. The port's
   `MINE_RINGS=[[14,22],[32,42],[50,62]]` (`pattern_gen.gd:13`) is a pre-77 grouping and the port
   reverses loop order (ore→ring, `pattern_gen.gd:279-283`). Both are **PORT APPROXIMATION** to
   replace.
3. **[O] Four active ring bands on the current branch.** For `gRecordGeneratorVersion>=80` and
   `mapsize>2`: ring0 `14+8R`, ring1 `32+10R`, ring2 `70+12R`, ring3 `22+16R`, ring4 `continue`
   (`dogenerate.inc:595-601`). `R` is a **fresh `RandomExt` draw per assignment per attempt**.
   Density 0/1/2 → `rounds` 3/4/5 (`:528-531`), clamped by `maxround` (`:533-534`). Two call sites:
   near `(minround=0,maxround=1)` at `:985`, global `(minround=1,maxround=0)` at `:1770`.
4. **[O] The `mapsize<=2, spcount<=4, v>=80` branch has no `case i of 2`** (labels 0,1,3,4,5 at
   `dogenerate.inc:639-645`); ring 2 receives no `dst` assignment and ring 5 is `continue`. This
   is real (three reads: D07 P6, X03 §3 verbatim, V12 raw re-read). **Recommendation [D]/[I],
   labelled: REPRODUCE the donor gap structurally, with an explicit zero-initialised `dst` and
   a trace toggle; never silently insert a band, never silently skip the anomaly.** §4 gives the
   reasoning, including a new cross-pass argument from `FillOwnerMap`.
5. **[O] `SetupStartingResources` places six attempted stone/forest items, never food.**
   `trycount=128`, `trycount2=3` (`:724-725`); `dst = mindst + R*span + (i+j)*0.5` with `span=3`
   for placements 1–3 and `span=2` for 4–5 (`:754,:793,:848,:880,:933`); ellipses **5×7**
   (`:984`, before near mines), **12×15** (`:769`, after stoneforest), **22×18** (`:947`, at the
   end), all centred `(x, y+2)`. The C3 placement block `:949-977` is commented out. Fields are
   mill-seeded elsewhere; A02/spec §10's "guaranteed food rects in D1:720-980" is an inherited
   error and is refuted (§1 C-V4).
6. **[O] `FillOwnerMap` is a late 160×160 four-neighbour wavefront BFS.** Grid constants
   `gc_scangrid_size=4`, `640/4=160` (`dmscript.global:55-59`); reset `:1373-1379`, seeds
   `:1381-1389`, `CheckOwnerDist` `:1361-1368`, wavefront `:1395-1419`; called at `:2062`, then
   peace-only border markers `:2064-2065`, then `_misc_SetShoresCollision` `:2068`. No terrain
   test inside the BFS; the border-assignment block `:1421-1427` is dead.
7. **[O] Rejection is occupancy-only.** `_misc_CheckStandPattern` (`misc.script:3384-3513`) tests
   stand/inv-stand mask cells (`:3434-3435,:3461,:3492`), 4-step fast sample at angle 0 (`:3439-3472`),
   full box with **exclusive** upper bound (`:3476-3510`), bounds/`gPatternMask` rejection
   (`:3466,:3504`), and `Ext` = test then stamp (`:3516-3521`). Water enters `gPatternMask`
   earlier at `height < -0.1` (`dogenerate.inc:1568-1581` — D07's `:1557-1564` citation is wrong).

---

## 1. Method, passes, and contradiction resolutions

Four passes were used; every contradiction was re-read with a different instrument before a
reading was accepted. No item was skipped after a single failed read (CHARTER §4).

| Pass | Instrument / source | Result |
|---|---|---|
| P-A | `reports/D07_resources_bin.md` read in full (7-pass verification log) | Recovered ring/ore/attempt structure, ellipses, BFS, checker; flagged ring-2 anomaly as [U] |
| P-B | `reports/A02_algorithm.md`, `spec/10_STAGE_ORDER.md`, `spec/07_RESOURCES.md`, `reports/X03_dscript_corpus.md`, `reports/V15_acceptance_without_reference.md`, `reports/P05_2d_reuse.md` | Stage seam, verbatim mine matrix, inherited food-rect claim, port approximation locations |
| P-C | **Raw donor re-read, read-only**: `dogenerate.inc:404-419,520-988,1358-1429,1544-1587,2052-2077`; `misc.script:3384-3521`; `dmscript.global:50-60,167-173`; `variant3d/scripts/pattern_gen.gd:1-30,274-305,424-439` | All numeric claims re-verified; two D07 line citations corrected; new RNG-bookkeeping and zero-init findings |
| P-D | Cross-table reconciliation + determinism argument from a second donor routine (`FillOwnerMap`) | Anomaly policy settled as reproduce-with-zero-init, labelled [D]/[I]/PORT APPROXIMATION |

### Contradictions settled (multi-pass)

| # | Conflict | Passes | Accepted reading |
|---|---|---|---|
| C-V1 | D07 §3.3 says `var dst` is declared at `:536` "outside the `j`/`k` loops"; raw donor shows `var dst : Float;` at **`dogenerate.inc:537` inside the `i` (ring) loop** | P-A, P-C | [O] Correction: `dst` is re-declared **per ring**; this changes the anomaly reasoning (§4). D07's conclusion (no `i=2` assignment) is unaffected. |
| C-V2 | D07/spec §07 cite shore prefill as `dogenerate.inc:1557-1564`; raw donor shows the loop at **`:1568-1581`** with `const cWaterShoreHeight = -0.1` at `:1576` | P-A, P-B (A02/X03 had `:1568-1581`), P-C | [O] A02/X03 are right; D07/spec §07 line range is a mis-citation. Corrected in §3.6 and §6. |
| C-V3 | `dogenerate.inc:571` says `if (mapsize>2) then // tiny`, but the branch structure puts `mapsize<=2 & spcount<=4` in the `else` at `:603-604` | P-A ([I] "do not assume >2 means tiny"), P-B (X03 quotes the same comment), P-C (raw re-read) | [O] literal numeric gate `mapsize>2` is implemented verbatim; the semantic enum label "tiny" is **[U]** pending X09. Never rename the gate by the comment. |
| C-V4 | A02 Stage 9 / `spec/10 §2` claim "guaranteed food rects inside `SetupStartingResources` (D1:720-980)"; D07 `:720-977` contains no `field`/`food` placement | P-A, P-B, P-C (full `:720-977` re-read; only player stock at `:258,:286`) | [O] **D07 wins**: zero food rects in this procedure; fields are mill-seeded. V15 V-E11 already agrees. A02/spec §10 assertion becomes a **red gate** (§5 G9). |
| C-V5 | D07 says ring 2 "inherits a stale `dst` (or an uninitialised one on the first attempt)"; raw loop structure shows `i=2` is never the first reachable ring (near call caps at 1 via `maxround`; global call starts at 1) and `FillOwnerMap` relies on an uninitialised `dist` being 0 (`:1394` vs `:1400`) | P-A, P-B (X03 U13), P-C | [I] Reproduce structurally with **zero-initialised `dst`** per ring; flag the VM semantics **[U]**. See §4. |
| C-V6 | Prior art `GUIDE4:2127`/`F2-02 F8` groups bands by ore (gold 14–22, iron 32–42, coal 70–82); D07/X03 group by ring; V15 I1 vs I2 | P-A, P-B, P-C | [O] Ring grouping confirmed at `dogenerate.inc:544-551,595-601`; per-ore grouping REFUTED. V15 already refuses to promote I1 to red. |
| C-V7 | D07 says ring 4/5 are "skipped"; raw donor uses `continue` inside the `for k` loop (`dogenerate.inc:580,:591,:600,:624,:635,:644,:653`) | P-A, P-C | [O]/[D] `continue` skips **the innermost `k` loop body**; the name-pick RNG draw at `:557` is still consumed 256× per ore. No angle draw at `:704`. "Skipped" must be implemented as *no placement with name-draw consumption*, not as an outer-loop skip. |
| C-V8 | A02/X03 call `SetupStartingResources` a "7-step order"; D07 counts "six attempted placements" | P-A, P-B, P-C | [D] Both correct: **6 placement attempts** (1 stoneforest + 1 stones + 2 forests + 1 stones + 1 forest) plus **2 ellipse fills inside the function** (`:769,:947`); X03 groups the two forest stamps into one step. C1 ellipse is outside, in `CreateStartPoint` (`:984`). |
| C-V9 | A02 Stage 7 telemetry says "deposit amounts scale with `cfg.minerals`" (`:591`); D07 §3.8 / spec §07 §4 say no finite deposit amount exists | P-A, P-B, P-C (`res.script:23-32`, `initial.inc:49-51` via D07) | [U] No finite capacity in generator; A02's telemetry sentence must be struck or relabelled **[U]** (§5 G10). |

---

## 2. Evidence table

Labels are per claim. Every donor path is read-only; line numbers are 1-based as re-read in P-C.

| Evidence (`dogenerate.inc:N` unless noted) | Claim | Label |
|---|---|---|
| `:522-523`, `:524-525`, `:528-535`, `:537`, `:544-557`, `:704-713` | `SetupMines` signature, `trycount=256`, rounds 3/4/5 + `maxround` clamp, ring→ore→attempt nesting, `var dst` per ring, first-success `break` | [O] |
| `:538-543` | commented-out legacy radius `case` (18+10R / 40+10R / 130+40R / 60+20R) — dead | [O] |
| `:559-568`, `:571-601`, `:603-654` | full nine-row version/size/player-count radius matrix, including `// tiny` comment and missing `i=2` | [O] |
| `:658-697` | `i=2 & spcount<=4 & mapsize>2` corner relocation; `v<90` no move; `v>=90` `±(maphW-24)/±(maphH-24)`; `ErrorLog('SetupMines wrong position. check it')` | [O] |
| `:407-416` | `cCircle1MaskX/Y=5/7`, `cCircle2=12/15`, `cCircle3=22/18`, `cBorderObjDist=1` | [O] |
| `:720-726` | `SetupStartingResources`: `trycount=128`, `trycount2=3`, `smalltry=4` (unused), `mindst=Min(5,7)=5` | [O] |
| `:731-767`, `:769`, `:771-805`, `:807-861`, `:863-892`, `:894-945`, `:947`, `:949-977` | six placement attempts, name picked once per placement, C2 fill after step 1, C3 fill at end, dead C3 placement block | [O] |
| `:754,:793,:848` = `+R*3`; `:880,:933` = `+R*2`; all `+((i+j)*0.5)` | exact probe radius expressions | [O] |
| `:980-988` | `CreateStartPoint`: C1 ellipse at `(x,y+2)` → `SetupMines(...,0,1,...)` → `SetupStartingResources` | [O] |
| `:1544`, `:1586-1587` | `minesdensity := gen.resourcemines`; `>2 → floor(RandomExt*3)` | [O] |
| `:1568-1581` | shore prefill `height < -0.1` into `gPatternMask` (not `:1557-1564`) | [O] |
| `:1613`, `:1615`, `:1616`, `:1769-1770`, `:1772`, `:1927`, `:2059-2068` | border mask radius 3, stage order: starts → reset → relief → global mines → reset → units/scale → `FillOwnerMap` → border objects → shore collision | [O] |
| `:1361-1368`, `:1370-1428`, `:1421-1427` | `CheckOwnerDist`, reset/seeds, wavefront, dead border block | [O] |
| `misc.script:3384-3435` | checker signature, `StandPatternWithAngle` on `doStand`, mask dims/offsets, stand/inv-stand flags | [O] |
| `misc.script:3439-3472`, `:3475-3510`, `:3516-3521` | 4-step fast path, full box, bounds+occupancy rejection, atomic `Ext` | [O] |
| `misc.script:3588-3632`, `:3634-3653`, `:3681-3704` | `Freq*0.2` floor `1e-4`, roulette, global budget `trycount=floor(256*mapsizeoptimise)` | [O] |
| `dmscript.global:55-59`, `:171` | scan grid 640/4 = 160²; `gc_meters_to_tile=2` | [O] |
| `reports/X03_dscript_corpus.md:854-893`, `:940` | verbatim radius matrix and starting-resource step list (second independent read) | [O] via X03 |
| `reports/D07_resources_bin.md:17-67`, `:138-221`, `:238-275`, `:305-379` | D07 settled statements; binary lane limitations; no finite deposit amount | [O]/[U] via D07 |
| `variant3d/scripts/pattern_gen.gd:13`, `:279-298`, `:428-436`, `:132`, `:153` | port approximations present in the working tree (read this pass, no edits) | [O] |

---

## 3. Settled algorithm

### 3.1 `SetupMines` — exact control flow

`dogenerate.inc:522`:

```
:525  var trycount : Integer = 256;
:528  case minesdensity of 0: rounds:=3; 1: rounds:=4; 2: rounds:=5; end;
:533  if (maxround>0) and (rounds>maxround) then rounds := maxround;
:535  for i:=minround to rounds-1 do            // ring
:537    var dst : Float;
:544    for j:=0 to 2 do                        // restypes
:548      0: str:='mng'; 1: str:='mni'; 2: str:='mnc';
:552      if (bDesert) then str := 'desert_'+str;
:554      pPatternList := _misc_SelectPatternListParser(pGenerator, str);
:555      for k:=0 to trycount-1 do
:557        _misc_GetPatternNameByParser(name, pPatternList);
:559-654   version/size/player-count case assigns dst, or `continue`
:704        angle := RandomExt*360;
:705        px := dst; py:=0; pz:=0; VectorRotateY(px,py,pz,angle);
:709        if _misc_CheckStandPatternExt(envplHnd, name,
                 round(newpointx+px), round(newpointy+pz), True, pRecordManagerPatternList) then
:711          _misc_PatternIncreaseFreq(pGenerator, str, name);
:712          break;
```

**[D]** Upper bound `256 × 3 × (rounds-minround)` attempts per call; first success per (ring, ore)
wins. **[O]** RNG draws per attempt: **one** name-pick (`RandomExt*FreqSum`, `misc.script:3638-3651`)
plus **one** angle (`RandomExt*360`, `:704`) plus **one** `dst` draw when the case assigns a band;
`continue` rings spend only the name-pick. Distances are in **map cells**; `gc_meters_to_tile=2`
(`dmscript.global:171`), so a 14–22 band is 28–44 m. **[O]**

### 3.2 Full radius/gate matrix

`R` = one fresh `RandomExt` per assignment. `v` = `gRecordGeneratorVersion` (fresh maps take
`gDataVersion`, `initmapgen.inc:57`, engine-side value **[U]**). `big` = literal `mapsize>2`
(`:571`; enum label "tiny" **[U]**). `CONT` = `continue` (no placement, name-draw consumed).

| Gate | ring0 | ring1 | ring2 | ring3 | ring4 | ring5 | Lines |
|---|---|---|---|---|---|---|---|
| `v<70` | `14+8R` | `38+8R` | `130+40R` | `52+8R` | `26+5R` | — | `:561-567` |
| `v>=70, big, v<77` | `14+8R` | `36+12R` | `50+12R` | `22+16R` | `CONT` | — | `:575-581` |
| `v>=70, big, v<80` | `14+8R` | `32+10R` | `50+12R` | `22+16R` | `CONT` | — | `:586-592` |
| **`v>=80, big`** | **`14+8R`** | **`32+10R`** | **`70+12R`** | **`22+16R`** | **`CONT`** | — | **`:595-601`** |
| `v>=70, !big, spcount<=4, v<75` | `14+8R` | `36+12R` | `88+18R` | `50+12R` | `24+9R` | — | `:608-614` |
| `v>=70, !big, spcount<=4, v<77` | `14+8R` | `36+12R` | **no case** | `50+12R` | `22+16R` | `CONT` | `:619-625` |
| `v>=70, !big, spcount<=4, v<80` | `14+8R` | `32+10R` | **no case** | `50+12R` | `22+16R` | `CONT` | `:630-636` |
| **`v>=70, !big, spcount<=4, v>=80`** | **`14+8R`** | **`32+10R`** | **no case** | **`70+12R`** | **`22+16R`** | **`CONT`** | **`:639-645`** |
| `v>=70, !big, spcount>4` | `14+6R` | `23+10R` | `39+9R` | `33+9R` | `CONT` | — | `:648-654` |

Two callers: near `SetupMines(pointx,pointy,0,1,minesdensity,spcount)` (`:985`) reaches only
rings 0–1; global `SetupMines(...,1,0,...)` (`:1770`) reaches rings `1..rounds-1`, so the
`i=2` anomaly is **only reachable in the global call**. `minesdensity>2` is normalised to
`floor(RandomExt*3)` before starts (`:1586-1587`).

### 3.3 Corner relocation for the far ring

`dogenerate.inc:658-702`: if `i=2 && spcount<=4 && mapsize>2`, the centre is moved:
`v<90` → unchanged centre (`:660-664`); `v>=90` → quadrant corner
`(±(maphW-24), ±(maphH-24))` by sign of `pointx/pointy` (`:667-689`), with
`ErrorLog('SetupMines wrong position. check it')` fallback (`:690-695`). Otherwise centre is the
start (`:698-702`). On a 320-cell map `maphW=maphH=160`, giving `±136`. **[O]**

### 3.4 `SetupStartingResources` — six attempted placements, no food

Constants `dogenerate.inc:407-414`; procedure `:720-977`. The family name is picked **once per
placement** (`:743,:782,:839,:869,:922`), then 128×3 probes share it; `break(MAIN)` exits both
loops; if all 384 probes fail the placement simply emits nothing.

| # | `str` family (non-desert) | count | `mindst` | `dst` | Lines |
|---|---|---|---|---|---|
| 1 | `stoneforests` | 1 | `Min(5,7)=5` (`:730`) | `5+3R+(i+j)*0.5` | `:731-767`, `:754` |
| — | fill ellipse **12×15** at `(x,y+2)` | — | — | — | `:769` |
| 2 | `stones` | 1 | `Min(12,15)=12` (`:771`) | `12+3R+(i+j)*0.5` | `:771-805`, `:793` |
| 3 | forest `foreststype=0` variant | 2 | 12 | `12+3R+(i+j)*0.5` | `:807-861`, `:848` |
| 4 | `stones` | 1 | `Min(12,15)+4=16` (`:863`) | `16+2R+(i+j)*0.5` | `:863-892`, `:880` |
| 5 | forest `foreststype=0` variant | 1 | 16 | `16+2R+(i+j)*0.5` | `:894-945`, `:933` |
| — | fill ellipse **22×18** at `(x,y+2)` | — | — | — | `:947` |

- **[O]** C1 `5×7` is stamped in `CreateStartPoint` at `:984` **before** near mines.
- **[O]** `dogenerate.inc:6` forces `foreststype := 0`, so leaf/mixed cases `:835-836,:918-919`
  are dead in vanilla (X03 A1/C7).
- **[O]** `smalltry=4` (`:726`) is declared but unused here; `prevname` (`:728`) is only used by
  the commented-out C3 block `:949-977` — **do not implement** that block (A02 F8, C18).
- **[O]** No `field`/`food` call exists in `:720-977`; food is mill-seeded elsewhere (D07 §3.6,
  F2-02 §3.3). `[D]` Max probe radii if never accepted: `135.5` (steps 1–3), `145.5` (steps 4–5);
  first success normally lands near the inner bound.

### 3.5 Occupancy-only rejection

`misc.script:3384-3521`. Predicate at `:3461`/`:3492`:
`(maskValue and maskStand) or ((not maskValue) and maskInvStand)`. Test branch rejects if
`indI<0 or indI>=mapH or indJ<0 or indJ>=mapW or gPatternMask[indJ,indI]` (`:3466`, `:3504`);
stamp branch marks `gPatternMask := true` only for in-bounds free cells (`:3497-3501`). Fast path
`step = 4` only when `not doStand and angle=0` (`:3439-3441`); full path uses `for i := vMinY to
vMaxY-1` (`:3476-3477`, exclusive upper bound) with rotated cell mapping when `angle<>0`
(`:3485-3488`). `Ext` calls test with `doStand=false` then stamp with `doStand=true`, both at
`angle=0` (`:3516-3521`); all D07 call sites use `Ext`, so the rotated branch is **unused here**.
`StandPatternWithAngle` is invoked by `doStand=true` at `:3390` — i.e. the actual engine stamp
comes after a successful test. **[O]** There is **no** water/rock semantic argument: water/shore
enter `gPatternMask` earlier at `height < -0.1` (`dogenerate.inc:1568-1581`), border at radius 3
(`:1613`), and the three ellipses at `:984,:769,:947`. **[I]** "no water" is emergent occupancy.

### 3.6 `FillOwnerMap` — timing and exact walk

`dmscript.global:55-59` → 640/4 = **160×160**. `dogenerate.inc:1370-1428`:

```
reset every cell: fChecked=false, owner=-1, dist=-1        # :1373-1379
for each start i: if _misc_PosToScanGridIndices(...) then   # :1381-1389
    grid.owner := arrStartPosBusy[i]; grid.dist := 0;
dist := 0 (implicit zero-init — [U], see §4)
while f:                                                    # :1395-1419
    f := false
    for all cells with grid.dist = dist and not grid.fChecked:
        owner := grid.owner
        for 4 in-bounds neighbours: CheckOwnerDist(nb,dist,owner)  # :1361-1368
            # assign only if nb.dist < 0
        grid.fChecked := true; f := true
    dist := dist+1
# :1421-1427 border-assignment block is commented out — do not implement
```

**[O]** Wavefront scan (whole grid per distance ring), not FIFO queue; X03 §9 Q1 notes a FIFO
would give the same `owner`/`dist` but a different visit order. **[O]** No terrain/collision test
inside the BFS — ownership crosses water. **[O]** Timing: `FillOwnerMap(spcount)` at `:2062`,
after units/scale (`SetRandomKey` `:1927`), then peace-mode `SetupBorderObjects` `:2064-2065`,
then `_misc_SetShoresCollision` `:2068`. Border objects are invisible `ptborder`/`ptborderwater`
markers, **not** rocks/trees (A02 C20). This is territory bookkeeping, **not** a placement stage.

### 3.7 Settled pseudocode (implementation-ready, donor-shaped)

```
# [O] quoted structure: dogenerate.inc:522-717, misc.script:3384-3521
def setup_mines(x, y, minround, maxround, minesdensity, spcount, rng, occ):
    rounds = {0:3, 1:4, 2:5}[minesdensity]              # :528-531
    if maxround > 0 and rounds > maxround: rounds = maxround   # :533-534
    for i in range(minround, rounds):                   # :535  RING first
        dst = 0.0                                       # :537  [D]/[I] zero-init, see §4
        for j, ore in enumerate(("mng","mni","mnc")):   # :544-550
            fam = ("desert_" if bDesert else "") + ore  # :552-553
            plist = select_pattern_list(generator, fam) # :554
            for k in range(256):                        # :525,:555
                name = roulette(plist, rng)             # :557 / misc.script:3634-3653
                spec = radius_band(i, v, mapsize_gt2, spcount_le4, rng)  # :559-654
                if spec is CONT: continue               # innermost k loop; no angle draw
                if spec is UNASSIGNED: pass             # anomaly: keep dst (zero on ring entry)
                else: dst = draw(spec)                  # one fresh RandomExt per assignment
                cx0, cy0 = corner_target(x, y, i, spcount, v)  # :658-702
                ang = rng.next()*360                    # :704
                vx, vz = rotate_y(dst, ang)             # :705-708
                if check_stand_ext(occ, name, round(cx0+vx), round(cy0+vz), True, rec_mgr):  # :709
                    increase_freq(plist, name)          # :711 / misc.script:3588-3632
                    break                               # :712

def setup_starting_resources(x, y, rng, occ):
    # C1 (5x7) already stamped by CreateStartPoint at (x, y+2)  # :984
    mindst = 5                                          # :730
    for step in SIX_PLACEMENTS:                         # :731-945, table §3.4
        fam = pick_family(step, bDesert, v, foreststype)
        name = roulette(select_pattern_list(generator,fam), rng)  # ONCE per placement
        if name == "": continue
        for num in range(step.count):
            for i in range(128):                        # :724
                ang = rng.next()*360                    # :751/:790/:845/:877/:930
                for j in range(3):                      # :725
                    dst = step.mindst + rng.next()*step.span + (i+j)*0.5  # :754/:793/:848/:880/:933
                    vx, vz = rotate_y(dst, ang)
                    if check_stand_ext(occ, name, round(x+vx), round(y+vz), True, rec_mgr):
                        increase_freq(...); break(MAIN)
        if step == 1: fill_ellipse(occ, x, y+2, 12, 15)  # :769
    fill_ellipse(occ, x, y+2, 22, 18)                    # :947
    # NO food rects; commented C3 placement :949-977 is dead
```

Stage seam with `spec/10_STAGE_ORDER.md §1` **[O]**: starts + ellipses + near mines at
`D1:1586-1616` (spec item 7); `SetRandomKey(randkey1)` `:1616`; relief `:1621-1766`; global mines
`:1769-1770` (spec item 8); reset `:1772`; forests/stones `:1774-1906` (item 9); units/scale
`:1914-2027` (item 10); `FillOwnerMap` `:2062` (item 11). A02's 5 re-seed sites are a subset of
X03's 11 + 3 (X03 §1 item 2); resource-relevant resets are `:1616` (before near+global mines)
and `:1772`. **[D]** Key mixing remains **[U]**; derive per-stage streams with a labelled
**PORT APPROXIMATION** and record the stream id in `gen_trace`.

---

## 4. Anomaly recommendation — missing `case i of 2`

**Observation [O].** In `dogenerate.inc:619-625`, `:630-636`, `:639-645` (small map,
`spcount<=4`, `v` in `<77`, `<80`, `>=80`) the `case i of` labels are `0,1,3,4,5`; `i=2` has no
assignment. `var dst : Float;` is at `:537`, **inside the ring loop**. The `>=80` row puts
`70+12R` at label 3 and `22+16R` at label 4 — i.e. the bands are shifted one ring relative to the
large-map row `:595-601`, and label 5 is `continue`.

**Passes attempted.** D07 P6 (double read of `:625-655` + `DTRN_05:208` comparison); X03 §3
verbatim re-read (`:880-885`); V12 raw re-read (`:537,:639-645`); cross-check with `FillOwnerMap`'s
own uninitialised locals (`:1394` `var dist, owner : Integer;` used at `:1400`
`if gScanGrid[i,j].dist = dist`). None skipped.

**Recommendation — label `[D]/[I]`, `PORT APPROXIMATION` until an engine/VM lane confirms
initialisation semantics: REPRODUCE the donor gap; do NOT fix it silently.**

1. Implement the `case` **literally with no `i=2` label** and keep `dst` declared per ring. In the
   fresh module set `dst = 0.0` on ring entry (GDScript's declaration semantics), record
   `ring2_dst_mode = "zero"` in `gen_trace` with label **[I]/PORT APPROXIMATION**, and assert that
   ring 2 emits **zero accepted mines** in the affected branch (a zero-radius candidate sits at
   the start centre, which is inside the already-stamped C1/C2/C3 keep-clear ellipses —
   `:984,:769,:947`, `misc.script:3466`).
2. **Why not "fix" by inserting `70+12R`:** that value is not present in this donor branch; it
   would be an **invented donor constant** (CHARTER §4, A02 F12), it would change which cells are
   occupied for later global passes, and it would desynchronise the RNG/occupancy stream relative
   to the donor. The donor consumes name-pick draws at `:557` and angle draws at `:704` for ring 2
   regardless; a fix changes the candidate, not the draw count, but changes downstream rejection.
3. **Why not "reproduce stale `dst`":** [I] a second donor routine (`FillOwnerMap` `:1394`→`:1400`)
   only functions if DScript scalar locals are zero-initialised on declaration, which favours
   zero-init over carry-forward. This is an inference, not proof (X03 U13); hence **[U]** remains
   on VM semantics and the trace flag is mandatory.
4. Provide an **explicit, off-by-default** `legacy_ring2_gap` switch plus an opt-in
   `ring2_band_override` that may only be enabled with COORD sign-off and a label stating it is a
   **deliberate divergence**, never a parity claim. Default behaviour = reproduce.
5. Never "silently skip" the anomaly in code or docs: the case table, the trace field, this
   section, and gate G2 below are the minimum audit trail.

---

## 5. Port approximations to replace and red gates

### 5.1 Port approximations (locations re-read this pass; no edits made)

| Port approximation | Replacement (donor authority) |
|---|---|
| `pattern_gen.gd:13` `MINE_RINGS=[[14,22],[32,42],[50,62]]` (pre-77 grouping) | Full 9-row band matrix `dogenerate.inc:559-654` with version/size/player gates (§3.2) |
| `pattern_gen.gd:279-298` ore→ring loop order, `256` tries, implicit water rejection at `:293-294` | ring→ore→attempt `dogenerate.inc:535,:544,:555`; occupancy-only rejection `misc.script:3384-3521`, water pre-seeded at `:1568-1581` |
| `pattern_gen.gd:132` `can_stand`, `:153` static `pick` | two-phase `CheckStandPatternExt` `misc.script:3516-3521`; roulette + `Freq*0.2` damping `misc.script:3588-3653` |
| `pattern_gen.gd:428-436` near-start: `stones×2`, `forests_pine_small×1`, CIRCLE2 ellipse only | six placements + C1/C2/C3 ellipses at `(x,y+2)` `dogenerate.inc:731-947`, `:984` |
| A02 Stage 9 / `spec/10 §2` "food rects in `SetupStartingResources`" | none — remove; mill-seeded fields are a separate pass (D07 §3.6, V15 V-E11) |
| `game.gd:152` single RNG seed (via A02 E02) | per-stage `SetRandomKey` discipline `dogenerate.inc:1616,:1772` (X03: 11+3 sites) |
| Port "quarry" concept (no donor asset, A04 E26) | `stones`/`stoneforests` families `generator.cfg:802,876` |

### 5.2 Red gates (assertions that must FAIL if violated)

| Gate | Donor assertion | Red condition |
|---|---|---|
| G1 | Rings→ores→256 attempts, first success wins — `dogenerate.inc:525,:535,:544,:555,:704-712` | any (ring,ore) with `attempts>256`, `accepted>1`, or ore outer loop detected |
| G2 | Radius matrix exact — `dogenerate.inc:559-654` (esp. `:595-601`, `:639-645`) | unit test over all 9 gates returns any band not in §3.2; or ring-2 small-map branch silently assigned; or `legacy_ring2_gap` trace field absent |
| G3 | `continue` rings consume name draws, no angle — `dogenerate.inc:557,:580,:600,:653` | angle-draw count on a `CONT` ring ≠ 0, or name-draw count ≠ 256×3×skipped_rings |
| G4 | Density→rounds + clamp + call sites — `dogenerate.inc:528-534,:985,:1770,:1586-1587` | rounds ≠ 3/4/5 for density 0/1/2; near call reaches ring ≥2; global call skips ring 1; `minesdensity>2` not normalised |
| G5 | Corner relocation — `dogenerate.inc:658-697` | `i=2,spcount<=4,mapsize>2,v>=90` centre not `±(maphW-24)/±(maphH-24)`, or `v<90` centre moved |
| G6 | Ellipses — `5×7` `:984`, `12×15` `:769`, `22×18` `:947`, centre `(x,y+2)`, C3 placement dead `:949-977` | wrong size/centre/timing; any stamp from the commented C3 block |
| G7 | Six placements and radius formulas — `dogenerate.inc:731-945`, `:754,:793,:848,:880,:933` | count/order/`mindst`/`span` mismatch; name redrawn per probe instead of per placement; food emitted here |
| G8 | Occupancy-only checker — `misc.script:3434-3435,:3441,:3461,:3466,:3476-3510,:3516-3521` | any terrain-semantic rejection branch; missing 4-step fast path; inclusive upper bound in full path; test pass stamps anything |
| G9 | No food rects in start resources — `dogenerate.inc:720-977` | any `food`/`field` object attributed to this procedure (this is the A02/spec §10 error) |
| G10 | No finite deposit amount — `res.script:23-32`, `initial.inc:49-51,74-103` via D07 §3.8 | any asserted per-deposit capacity, or telemetry "amounts scale with minerals" promoted as [O] |
| G11 | `FillOwnerMap` — `dmscript.global:55-59`, `dogenerate.inc:1370-1428,:2062-2068` | grid ≠ 160²; 8-neighbour; terrain-filtered BFS; border block `:1421-1427` implemented; called before starts/props |
| G12 | Stage seam and re-seed — `dogenerate.inc:1616,:1769-1772,:1927,:2059-2068` | resource stage moved before relief/forest passes; missing stage stream id; border objects rendered as rocks/trees |
| G13 | Weighted pick + damping — `misc.script:3588-3653`, `generator.cfg:69-140` | static pick list; damping ≠ ×0.2/floor `1e-4`; `FreqSum` not updated |

All gates are **structural/determinism assertions**, not visual parity assertions. No donor GPU
A/B frame exists; none is claimed.

---

## 6. Implications for `spec/07_RESOURCES.md`

1. **§1:** replace the single "current band" sentence with the full 9-row table of §3.2 and add
   `dogenerate.inc:559-654` verbatim line ranges. Change "ring 4 skipped" to "`continue` inside
   the `k` loop; name-draw still consumed" (C-V7).
2. **§1 anomaly:** replace "V12 will recommend reproduce-vs-fix" with §4's labelled
   **REPRODUCE / zero-init / trace-toggle** recommendation; keep VM semantics in the UNVERIFIED
   register.
3. **§2:** add the exact six-placement table (family, count, `mindst`, `span`, donor line) and the
   three ellipse timings; state that the name is drawn once per placement and that C3 placement
   `:949-977` is dead. Add explicit "no food rects; A02 Stage 9 claim refuted".
4. **§3:** correct shore prefill citation from `:1557-1564` to **`:1568-1581`**; add
   `FillOwnerMap` timing (`:2062`→`:2064-2065`→`:2068`), 160² derivation
   (`dmscript.global:55-59`), and the dead border block `:1421-1427`.
5. **§4:** add the [I] note that `FillOwnerMap`'s reliance on a zero-initialised `dist`
   (`:1394`→`:1400`) supports the zero-init reading for ring 2; still **[U]**.
6. **§5:** keep `mng/mni/mnc` 6 members / ΣFreq 5, family→ore mapping **[I]**, and mark F08
   family-content confirmation pending (F08 not landed at write time).
7. **§6 cross-check queue:** mark V12 landed with the anomaly recommendation; X09 (starting
   settings → `mapsize` enum, `gDataVersion`, per-player presets) and F08 remain pending; D04
   (saved `.map` placement records) remains the only route to confirm emitted coordinates.

---

## 7. Risks

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | `[*] = ;` prefix means the script text is authoritative intent, not proven runtime activation | high | Keep D07 U1; no parity claim; capture/histogram only |
| R2 | Wrong `gRecordGeneratorVersion` band changes `70+12R` to `50+12R` or `88+18R` | high | Read version at A/B time, record branch in `gen_trace`, gate G2 |
| R3 | `mapsize>2` labelled `// tiny` but enum meaning unknown (X09 pending) | medium | Implement literal numeric gate; never rename from comment; gate G2 |
| R4 | DScript local-init semantics unproven → ring-2 zero-init is [I] | medium-high | Explicit trace flag + reproduction policy (§4), gate G2 |
| R5 | `continue` implemented as outer-loop skip → RNG stream desync | high | Gate G3 counts name/angle draws separately |
| R6 | Native lane truncated (6M instructions); a native helper may participate in stamping | medium | Keep D07 U2; authority remains donor text; no native parity claim |
| R7 | F08/X09 not landed → family contents and `mapsize`/version enum remain [U] | medium | Do not invent family members or enum labels; pending register |
| R8 | Port's semantic water rejection and reversed loop order copied into fresh module | high | Gate G1/G8; delete `pattern_gen.gd:293-294` style checks in fresh code |
| R9 | No donor GPU A/B frame and no donor binary execution | high (epistemic) | `parity.claim = NONE`; all visual expectations INFERRED/UNVERIFIED |

---

## 8. UNVERIFIED register

| # | Item | Passes attempted | Would settle it |
|---|---|---|---|
| U1 | Runtime activation of `[*] = ;` DScript text | P-A/P-B/P-C; binary lane cannot see external script text; no execution allowed | Approved replay/trace lane |
| U2 | Native methods behind `XMapGenerator`/`XCastleGenerator` | D07 P1–P5; V12 re-read of text authority | Full Ghidra/Cutter with complete function discovery |
| U3 | Shipping `gRecordGeneratorVersion` / `gDataVersion` value | D07 U4, X03 §8 U7, V12 `:559-654` re-read | Saved-record/CFG lane; record branch in trace |
| U4 | `mapsize` enum → "tiny" mapping | `:571` comment vs `:603-604` branch structure; X03 quote; raw re-read | X09 starting settings (not landed) |
| U5 | DScript local initialisation (`dst` at `:537`, `dist` at `:1394`) | V12 cross-routine argument; X03 U13; D07 U6 | Engine VM semantics lane; keep trace flag |
| U6 | Exact stand/inv-stand mask cells per mine/stone/forest family | D07 P7 header (8×10 for `mng_1`) | F01 full `.pattern` parser + F08 (not landed) |
| U7 | Finite deposit amount / capacity | D07 §3.8; raw `res.script:23-32` not re-read by V12 beyond D07 quote | Native/save inspection; represent as non-depleting marker |
| U8 | Food fields' exact mill-seed rule and stage position | D07 refutation, A02 Stage 9 [U], X03 §8 U10 | F07 (mill/field assets) + runtime observation |
| U9 | Family→ore mapping (`mng`=gold etc.) | `initial.inc:49-51` via D07; interpreted **[I]** | F08 / saved map records |
| U10 | Whether port-side ellipses/footprints are pixel-equivalent to donor masks | port file read; no donor render | A05 capture + A/B frame (still absent) |

---

## 9. Open questions

1. Does the retail build actually take the `v>=80` branch on a 320-cell, 2-player map (U3)?
2. Does `mapsize>2` mean "not tiny" (branch structure) or "tiny" (donor comment at `:571`)? (U4 → X09.)
3. Is DScript `var dst : Float;` at `:537` zero-initialised per ring iteration? V12's zero-init
   recommendation rests on `FillOwnerMap`'s analogous reliance (U5).
4. Do `Freq`/`UsedCount` mutations persist into saved games/replays, changing later resource draws?
5. Is the `i=2` gap a shipping bug visible on small ≤4-player maps, or masked because the centre
   is always occupied by the ellipses? (No donor execution permitted.)
6. F08 (not landed): do `str_new_1..8` / `d_stn_1..7` stand masks match the port's converted
   footprints? F03/X03 family counts should be used verbatim until then.
7. X09 (not landed): do starting presets set `resourcemines` outside 0..2, and how is `mapsize`
   populated from UI settings?

---

## 10. Sign-off

Exactly one repo file written: this report. No source, shader, config, asset, test, JSON, PNG,
donor, queue, or git edit; no Godot process or runner job; no donor binary executed; no donor
file copied or committed. Every donor claim is quoted with `dogenerate.inc:N` / `misc.script:N` /
`dmscript.global:N`. **No donor-parity claim** — no donor GPU A/B frame exists.

*End of V12. One report written.*
