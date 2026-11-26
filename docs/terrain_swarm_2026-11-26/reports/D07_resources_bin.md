---
id: D07
date: 2026-11-26
wave: D (donor binary / DScript cross-check)
title: "Donor resource-placement algorithm: SetupMines, SetupStartingResources, FillOwnerMap, CheckStandPattern"
status: LANDED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
donor_root: "C:\\Games\\Cossacks 3 (READ ONLY, private use; no donor binary executed, no donor file copied or committed)"
craft_target: "cossacks.exe, t_87f0f3c130b0, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (deep mode)"
labels: ["[O] observed", "[D] derived", "[I] inferred", "[U] UNVERIFIED", "PORT APPROXIMATION"]
parity_claim: false
---

# D07 — Donor resource placement, decoded from donor text with binary cross-check

## 0. Executive summary

1. **[O] The placement algorithm is not a recovered native `SetupMines` function.** The donor
   executable embeds the class-name literals `XMapGenerator` (17 hits, first at VA `0x71c0a5`,
   file offset `0x31b4a5`, section `CODE`) and `XCastleGenerator` (19 hits, first at `0x72835c`,
   offset `0x32775c`), but native function discovery was truncated at 6,000,000 instructions and
   found **0** functions matching those names or `SetupMines|SetupStartingResources|FillOwnerMap`.
   The clean-room lifter misreads the embedded ASCII as code (`0x71c0a5` = byte `0x58` = `pop eax`),
   so its 65 kB pseudo-C for `sub_71c0b4` is **rejected as evidence of the algorithm**. The
   authoritative algorithm is readable donor DScript text in `data/scripts/common.inc/dogenerate.inc`
   and `data/scripts/lib/misc.script`, plus cfg/pattern data. (§1, §3.1)

2. **[O] Port belief "gold 14–22, iron 32–42, coal 70–82" is REFUTED as stated.** `SetupMines`
   (`dogenerate.inc:522-717`) loops **rings** (outer `i`), then **all three ores** (`j = 0..2` →
   `mng`, `mni`, `mnc`; `desert_` prefix on desert maps), then up to **256 angle attempts** per ore
   per ring (`:525`, `:544-553`, `:554-557`, `:704-713`). The numbers 14–22 / 32–42 / 70–82 are
   **ring radii bands shared by all three ores**, not per-ore radii. On the current band
   (`gRecordGeneratorVersion >= 80`, `mapsize > 2`) they are ring 0 `14+8R`, ring 1 `32+10R`,
   ring 2 `70+12R`, ring 3 `22+16R`, ring 4 skipped (`:595-601`). Rounds are 3/4/5 for
   `minesdensity` 0/1/2 (`:528-534`). (§3.2–3.4, §3.11)

3. **[O] Real anomaly, not skipped:** in the `v>=80`, `spcount<=4`, `mapsize<=2` band there is
   **no `case i of 2`** — only labels `0,1,3,4,5` (`:639-645`). Ring 2 therefore inherits a stale
   `dst` (or an uninitialised one on the first attempt), and ring 5 is skipped. Multiple passes
   were run before accepting this (§1 P6). It does **not** occur in the `mapsize>2` band used for
   the 14/32/70 table above. (§3.3)

4. **[O] `SetupStartingResources` (`:720-947`) does place stone/forest rings but does NOT place
   food rects.** It uses `trycount = 128` outer tries × `trycount2 = 3` inner radius steps per
   placement, with six attempted placements: stoneforest ×1, stones ×1, forest ×2, stones ×1 at
   `+4`, forest ×1. Three nested keep-clear ellipses are stamped into the same occupancy mask:
   **5×7** (before near mines), **12×15** (after stoneforest), **22×18** (at the end of the
   function), always centred at `(start.x, start.y+2)` (`:407-415`, `:769`, `:947`, `:984`).
   Food fields are mill-seeded elsewhere (prior art F2-02 F4/F6), not guaranteed here. (§3.6, §3.11)

5. **[O] `FillOwnerMap` is a 4-neighbour BFS over a 160×160 scan grid** seeded from player starts
   (`:1370-1425`; `dmscript.global:57-58`: 640/4 = 160). It runs *late*, after peasants, and is
   followed by `SetupBorderObjects` and shore collision (`:2062-2068`). (§3.9–3.10)

6. **[O] Rejection is occupancy-based, not semantic.** `_misc_CheckStandPattern` tests the
   pattern's stand mask against `gPatternMask` (4-step fast sample, then full box), rejecting any
   out-of-map or already-occupied cell (`misc.script:3384-3513`); `Ext` first tests with
   `doStand=false`, then stamps with `doStand=true` (`:3516-3521`). Water/shore cells enter that
   mask earlier from `height < -0.1` (`dogenerate.inc:1557-1564`); earlier tiled/relief patterns
   and the three start ellipses occupy the rest. There is no dedicated "water/rock" branch inside
   the checker. (§3.7)

7. **[U] No finite deposit amount is set by the generator.** Ore deposits are typed resource nodes
   (`env.inc/initial.inc:49-51`), `_res_Init` sets `hp := 0` (`res.script:23-32`) and
   `initial.inc:74-103` overrides hp only for wood/stone/food. Any "deposit amount" analogue is
   UNVERIFIED; player starting stock in `startingsettings.cfg` is a different system. (§3.8, §6)

No donor-parity claim: no donor GPU A/B frame exists and no donor binary was executed.

---

## 1. Method and multi-pass register (owner directive: never silently skip)

Shared Craft Anything session: another worker switched the global active target to `editor.exe`
mid-session. **Every analysis call below was pinned to `document: "t_87f0f3c130b0"`** (cossacks.exe);
no `core_target_open`/`core_target_select` was issued by this worker. Text reads used explicit
`path=` (donor files, read-only). Evidence ids are from the shared ledger.

| Pass | Tool / source | Result | Acceptance reasoning |
|---|---|---|---|
| P1 | `native_functions_search` regex `XMapGenerator\|XCastleGenerator\|XPattern\|XTerrainData` and `SetupMines\|SetupStartingResources\|FillOwnerMap\|CheckStandPattern` on cossacks.exe | **0 functions**, with limitation `instruction_limit` (discovery stopped after 6,000,000 instructions; `ev_e98e765f…`, `ev_913a09dd…`) | Inconclusive, **not absence**. Kept as [O] tool result only. |
| P2 | `native_strings_find` for `stoneforests`, `mni_1` | 0 (limitation: data sections only) | Expected: those are *data-file* names, not necessarily exe strings. Inconclusive. |
| P3 | `native_bytes_find` over full file bytes for `XMapGenerator`, `XCastleGenerator`, `dogenerate.inc`, `stoneforests`, `generator.cfg` | XMapGenerator 17 hits (`ev_43fb1f88…`), XCastleGenerator 19 hits (`ev_7f22818c…`); **0** hits for the three script/cfg names (`ev_04ed3fbb…`, `ev_8ed0b6be…`, `ev_40d53b46…`) | Confirms RTTI/class-name literals in `CODE` + one in `.rsrc`, and that script source/cfg names are not embedded. Anchors P4; does not yield placement constants. |
| P4a | `native_function_find` for each literal VA → `sub_71c0b4` (entry `0x71c0b4`, 2,128 B, 407 blocks); `native_function_study` (`ev_85467957…`), `native_function_pseudocode`, `native_function_disassemble` | Pseudo-C has 212 gotos, 133 `__asm` items, no string recovery; 5 indirect calls, **0 direct callers, address taken 30 times**, tail-call to `sub_71c038` (`ev_fc217288…`, `ev_ec8bb39a…`) | **Rejected as algorithm evidence.** The bytes at `0x71c0a5` are ASCII, not instructions; the lifter emits `pop eax` there (`ev_f4a62967…`). Consistent with a class/vtable-registration thunk, not a placement routine. |
| P4b | `native_xrefs_list` at `0x71c0a5`, `native_data_show` as cstring | 0 static xrefs (`ev_5908fe71…`); cstring reads `XMapGenerator` + trailing garbage (`ev_c68d8043…`) | String data has no static xref; references are computed at run time (tool limitation `static_references`). No native placement entry point recovered. |
| P4c | `native_function_study` on `sub_71c038` | 1 instruction (`ev_79e423a3…`) | Tail thunk; no algorithm. |
| P5 | `core_feature_find("SetupMines")` on cossacks.exe | 0 strings/functions/imports (`ev_41dd5983…`, `no_match`) | Corroborates P1/P3: placement is external DScript, not a named native symbol. |
| P6 | `core_text_read` of donor scripts + cfg + pattern header, with PowerShell line-number cross-check; comparison to prior art `F2_02`, `BLD_01`, `DTRN_05` | Recovered full loops/constants below (`ev_a33507f9…`, `ev_7733cb43…`, `ev_5200df4f…`, `ev_71484fdd…`, `ev_32fd9062…`, `ev_5826ad27…`) | **Accepted as authority** for the algorithm. Every numeric claim re-read at least twice; the ring-2 gap was re-read at `:625-655` and compared against `DTRN_05:208` before being reported as an anomaly rather than a transcription error. |
| P7 | Pattern/cfg cross-check: `generator.cfg:69-140`, `:802-905`; `pattern/mng_1.pattern` header via Python `struct` | mng/mni/mnc groups with `Freq`; stoneforests = `str_new_1..8`; stones = `d_stn_1..7`; `mng_1.pattern` 3,730 B, header `08 00 00 00 0a 00 00 00` (8×10) | Corroborates pattern-family literals named in the script; no new constants invented. |

**Acceptance rule applied:** a claim is [O] only when the donor file line (or byte/VA) was read
this session; [D] for deterministic arithmetic over those values; [I] when interpreting an
ambiguous comment/enum; [U] when the above passes could not settle it. Native decompiler output
was explicitly *not* promoted where it contradicted raw bytes.

---

## 2. Evidence table

| Id | What it is | Use |
|---|---|---|
| `ev_43fb1f88f544a4d5b54cd478b07331afd25fb9fb6edd130d27f4b6087f993041` | 17 `XMapGenerator` literals in cossacks.exe, first VA `0x71c0a5` / offset `0x31b4a5`, section CODE | §3.1 |
| `ev_7f22818c23f165256a178ac98ade0a3a7a2e7c94fd4c1d791a8cde206103d89a` | 19 `XCastleGenerator` literals, first VA `0x72835c` | §3.1 |
| `ev_e98e765f2644fdb3a8684fa0c56261623f2affc98926cb8e6fba81f86e4fbd69`, `ev_913a09ddf69370f8c60aabf597ab1cc0579fcb185ef3389110a4baef9aefc4cb` | native function searches: 0 matches, discovery truncated | §1 P1, §6 |
| `ev_85467957f6fa2ab75623a91a9dc23191980a8c5d8d2f4c5006aed8ed37a8251a`, `ev_f4a62967ae4974643fee198e39735e904d9c8dc54c302c75462af363e9db13f8` | `sub_71c0b4` dossier; `0x71c0a5` disassembles as `pop eax` | rejected decompiler, §1 P4a |
| `ev_fc217288663e78328bba2fc45f0758646c6f668e8cb9649287468fb04708a166`, `ev_ec8bb39a2ac2883846faba54a40deb927d717891cfc88ae1d96bcc3abca3f201` | 0 direct callers / 30 address-taken; 6 calls (5 indirect) | §1 P4a |
| `ev_41dd5983fd46759b5b458cd9c78401ad9c6895876c51ae42965069792d46c318` | `core_feature_find("SetupMines")` no match | §1 P5 |
| `ev_a33507f945c695b4938dfc77d81d382482d54de32bb737f4172e9f2b58e780b4` | `dogenerate.inc:522-721` — full `SetupMines` | §3.2–3.5 |
| `ev_7733cb431b61599d4c73794296090e9ecad0cff6205c43d04501979fb352109a`, `ev_5200df4fe71ca6a611639834b9c14c2c1de6f894c6e22fdc03f7b51af8700f06` | `dogenerate.inc:722-921`, `:922-1081` — `SetupStartingResources` and `CreateStartPoint` | §3.6 |
| `ev_71484fdd28d67bc4032b55c39c5b162ee1a029fd343d91b772b262dd80c285f4`, `ev_32fd9062bfd74afda5f78f6234f406bb32c71d7240d92c9a1db9ce031b7df7cb`, `ev_5826ad276cc90d2a8b5d6b65e21051141fc0c56556fcaebe80dbf58b7f4d0e3e` | `misc.script:3384`, `:3516`, `:3681` — checker, Ext wrapper, global placer | §3.7, §3.10 |
| Craft Anything findings `fnd_1`…`fnd_5` | Settled D07 statements appended to the shared investigation | cross-reference |

Donor paths below are absolute and read-only: `C:\Games\Cossacks 3\data\...`. Line numbers are
1-based as read this session. All script lines in `*.inc` carry the literal `[*] = ;` comment
prefix; activation is [U] (see §6).

---

## 3. Findings

### 3.1 Where the algorithm lives — binary anchor vs data authority

- **[O]** `native_bytes_find` on cossacks.exe finds `XMapGenerator` at VAs `0x71c0a5`, `0x71c0d6`,
  `0x71c1b3`, `0x71c5c9`…`0x71c847` (16 in CODE) plus `0x959430` (.rsrc); `XCastleGenerator` at
  `0x72835c`…`0x7292a2` plus `0x95945f`. These are ASCII strings sitting **inside/adjacent to the
  CODE section**, which is why `native_strings_find` (data sections only) returned nothing.
  (`ev_43fb1f88…`, `ev_7f22818c…`)
- **[O]** `native_function_find` maps most of those VAs into `sub_71c0b4` (2,128 B, 407 blocks,
  922 instructions); it has 0 direct callers, its address is taken 30 times, and it makes 5
  indirect calls + a tail call to the 1-instruction `sub_71c038`. That shape is consistent with
  class registration / vtable population, **not** a placement loop. `[I]`
- **[O]** The lifter treats the ASCII constants as instructions; at `0x71c0a5` (`"XMap…"`) the
  reported instruction is `pop eax` because `0x58 == 'X'`. Its pseudo-C contains values like
  `eax |= 0x70614d58` (little-endian `"XMap"`). **Rejected** for algorithm recovery. (`ev_f4a62967…`)
- **[O]** No literal `dogenerate.inc`, `stoneforests`, or `generator.cfg` occurs in the exe bytes;
  the algorithm and its constants are in shipped data files. This is the reason D07's concrete
  answer comes from DScript text, cross-checked against the binary naming evidence.

### 3.2 `SetupMines` — exact loop skeleton [O]

`C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:522-717` (`ev_a33507f9…`):

```pascal
procedure SetupMines(pointx, pointy : Float; minround, maxround, minesdensity, spcount : Integer);
var trycount : Integer = 256;                    // :525
    bstand : Boolean; rounds : Integer;
case minesdensity of 0: rounds:=3; 1: rounds:=4; 2: rounds:=5; end;   // :528-532
if (maxround>0) and (rounds>maxround) then rounds := maxround;         // :533-535
for i := minround to rounds-1 do                                      // ring
begin
  var dst : Float;
  for j := 0 to 2 do                                                  // ore family
  begin
    case j of 0: str:='mng'; 1: str:='mni'; 2: str:='mnc'; end;        // :544-548
    if bDesert then str := 'desert_'+str;                              // :550-551
    pPatternList := _misc_SelectPatternListParser(pGenerator, str);   // :554
    for k := 0 to trycount-1 do                                       // 256 attempts :555
    begin
      _misc_GetPatternNameByParser(name, pPatternList);               // weighted pick
      // version/size/player-count case selects dst (see §3.3) ; corner override (§3.4)
      angle := RandomExt*360;                                         // :704
      px := dst; py := 0; pz := 0; VectorRotateY(px, py, pz, angle);  // :705-708
      if _misc_CheckStandPatternExt(envplHnd, name,
             round(newpointx+px), round(newpointy+pz), True,
             pRecordManagerPatternList) then                          // :709
      begin
        _misc_PatternIncreaseFreq(pGenerator, str, name);             // :711
        break;                                                        // first success wins
      end;
    end;
  end;
end;
```

Consequences: **[D]** upper bound `256 × 3 ores × (rounds-minround)` attempts per start call;
**[O]** the angle is re-drawn on every attempt (`RandomExt*360`), and a failed candidate leaves
no trace (the checker's test pass does not stamp). Note the *order*: ring → ore → attempts, so
all three ores are attempted at ring `i` before moving outward. The "ore radius" reading in
GUIDE4:2127 / F2-02 F8 (`gold 14–22, iron 32–42, coal 70–82`) is a mis-grouping of these rings.

### 3.3 Distance bands — version / map-size / player-count gated [O]

All `dst` values are in **map cells** (`gc_meters_to_tile = 2`, `dmscript.global:171`), so band 0
is 28–44 m for a 14–22 band. `R = RandomExt`.

| Condition (`dogenerate.inc` lines) | ring 0 | ring 1 | ring 2 | ring 3 | ring 4 | ring 5 |
|---|---|---|---|---|---|---|
| `v<70` (`:561-567`) | `14+8R` | `38+8R` | `130+40R` | `52+8R` | `26+5R` | — |
| `v>=70`, `mapsize>2`, `v<77` (`:573-579`) | `14+8R` | `36+12R` | `50+12R` | `22+16R` | skip | — |
| `v>=70`, `mapsize>2`, `v<80` (`:584-590`) | `14+8R` | `32+10R` | `50+12R` | `22+16R` | skip | — |
| **`v>=80`, `mapsize>2` (`:595-601`)** | **`14+8R`** | **`32+10R`** | **`70+12R`** | **`22+16R`** | skip | — |
| `v>=70`, `mapsize<=2`, `spcount<=4`, `v<75` (`:606-612`) | `14+8R` | `36+12R` | `88+18R` | `50+12R` | `24+9R` | — |
| `v>=70`, `mapsize<=2`, `spcount<=4`, `v<77` (`:617-625`) | `14+8R` | `36+12R` | **no case** | `50+12R` | `22+16R` | skip |
| `v>=70`, `mapsize<=2`, `spcount<=4`, `v<80` (`:630-636`) | `14+8R` | `32+10R` | **no case** | `50+12R` | `22+16R` | skip |
| `v>=70`, `mapsize<=2`, `spcount<=4`, `v>=80` (`:639-645`) | `14+8R` | `32+10R` | **no case** | `70+12R` | `22+16R` | skip |
| `v>=70`, `mapsize<=2`, `spcount>4` (`:648-654`) | `14+6R` | `23+10R` | `39+9R` | `33+9R` | skip | — |

**[O] anomaly / multi-pass acceptance:** the four `spcount<=4` small-map cases label their
entries `0,1,3,4` (and `5:continue`) at `:630-636` and `:639-645`; `i=2` has no assignment.
`var dst` is declared at `:536` outside the `j`/`k` loops, so ring 2 uses whatever `dst` the
previous attempt left (uninitialised on the very first attempt). I re-read `:625-655` twice and
compared with prior `DTRN_05:208`, which lists the same five upper bounds without ring labels;
the label gap is real in the shipped text, so it is reported as an observed source quirk, not as
a promoted runtime effect. **[U]** whether the runtime engine initialises locals (affecting the
first attempt) — no execution was permitted.

**[I]** The inline comment `if (gMap.settings.gen.mapsize>2) then // tiny` (`:572`) is ambiguous:
the enum mapping of `mapsize` values to Tiny/Small/… was not recovered. The literal condition is
quoted verbatim; do not assume ">2 means tiny" when porting.

### 3.4 Corner relocation for the far ring [O]

At `:658-697`, when `i=2` **and** `spcount<=4` **and** `mapsize>2`:

- `v<90`: `newpointx/y := pointx/y` (no relocation).
- `v>=90`: the centre is snapped to the quadrant corner
  `newpointx := ±(maphW-24)`, `newpointy := ±(maphH-24)` (sign from `pointx/pointy`),
  e.g. `maphW=maphH=160` on a 320-cell map → `±136`. A wrong-position case logs
  `SetupMines wrong position. check it` and falls back to the start point.

This is why the current far ring (70–82 cells) can land in map corners rather than simply around
the start. **[O]**

### 3.5 Weighted pattern choice and frequency damping [O]

- `generator.cfg:69-140` defines groups `mng`, `mni`, `mnc`, each a `PatternList` with one
  legacy pattern at `Freq = 0` (`mng4`, `mni4`, `mnc4`) and five live patterns at `Freq = 1`
  (`mng_1..mng_5`, `mni_1..mni_5`, `mnc_1..mnc_5`). Desert groups `desert_mng/mni/mnc` use three
  `_a` patterns each (`:156-204`). `stoneforests` = `str_new_1..8` (`:802-833`); `stones` =
  `d_stn_1..7` (`:876-905`); desert equivalents at `:1932+`.
- `_misc_GetPatternNameByParser` (`misc.script:3634-3653`): `freqrnd := RandomExt*FreqSum`;
  subtract each `Freq` in order; pick the first pattern whose `freqrnd < Freq`. **[O]**
- `_misc_PatternIncreaseFreq` (`:3588-3632`): on acceptance `newfreq := max(oldfreq*0.2,
  0.0001)`, increments `UsedCount` and group `TotalCount`, and adjusts `FreqSum`. **[O]** This
  is the donor's anti-repetition mechanism: a stamp that worked becomes 5× less likely next time.
- `_misc_GetOrCreateGeneratorParser` (`:3522-3557`) computes `FreqSum` on load and defaults any
  missing `Freq` to 1. **[O]**

### 3.6 `SetupStartingResources` — counts, radii, ellipses [O]

`dogenerate.inc:720-947` (`ev_7733cb43…`, `ev_5200df4f…`):

```
trycount = 128; trycount2 = 3;                         // :724-726
mindst = Min(cCircle1MaskX, cCircle1MaskY) = Min(5,7) = 5     // :730, :407-408
for each placement pass:
  for i := 0..127:  angle := RandomExt*360
    for j := 0..2:  dst := mindst + RandomExt*3 + (i+j)*0.5   // :748
      px := dst; VectorRotateY(px,py,pz,angle)
      if CheckStandPatternExt(name, round(pointx+px), round(pointy+pz), True, ...) then
        IncreaseFreq; break(MAIN)
```

| Order | Family (`str`) | Count | `mindst` | `dst` formula | Lines |
|---|---|---|---|---|---|
| 1 | `stoneforests` (desert: `desert_stoneforests` if `v<77`, else `desert_forests_big`) | 1 | 5 | `5 + 3R + (i+j)*0.5` | `:731-767` |
| — | **stamp ellipse `cCircle2` 12×15 at `(pointx, pointy+2)`** | — | — | — | `:769` |
| 2 | `stones` (desert: `desert_stones`) | 1 | 12 | `12 + 3R + (i+j)*0.5` | `:771-802` |
| 3 | forest list (7 pine/spruce variants for `foreststype=0`, else leaf/mixed; `foreststype` forced 0 at `:7`) | 2 | 12 | `12 + 3R + (i+j)*0.5` | `:804-861` |
| 4 | `stones` | 1 | `12+4=16` | `16 + 2R + (i+j)*0.5` | `:863-889` |
| 5 | forest list (same choice logic) | 1 | 16 | `16 + 2R + (i+j)*0.5` | `:891-941` |
| — | **stamp ellipse `cCircle3` 22×18 at `(pointx, pointy+2)`** | — | — | — | `:947` |

Constants: `cCircle1MaskX/Y = 5/7`, `cCircle2MaskX/Y = 12/15`, `cCircle3MaskX/Y = 22/18`
(`:407-415`). `CreateStartPoint` stamps `cCircle1` at `(pointx, pointy+2)` **before** calling
`SetupMines(...,0,1,...)` and `SetupStartingResources` (`:980-988`). **[O]**

**[D]** max radius before acceptance: `5+3+127.5 = 135.5` cells for pass 1; `12+3+127.5 =
142.5` for passes 2–3; `16+2+127.5 = 145.5` for passes 4–5 — but the first accepted candidate
wins, so typical radii are near the inner bound, not these maxima. **[O]** Each pass stops both
loops on first success via `break(MAIN)`; if all 384 probes fail, the pass simply places nothing.

**[O] Refutation of "food rects":** there is no `field`/`food` placement in this procedure; the
only food-related lines in `dogenerate.inc` are player stock additions (`:258`, `:286`). Fields
are produced by mills (`_unit_DoSeedWheat`, prior F2-02 §3.3, `generatemap.inc:1014-1024`).

### 3.7 Rejection logic — `_misc_CheckStandPattern(Ext)` [O]

`misc.script:3384-3513` and `:3516-3521` (`ev_71484fdd…`, `ev_32fd9062…`):

1. `doStand=true`: `StandPatternWithAngle(plHnd, patName, x, z, angleRad, 0, 90)` actually places
   the pattern; if `bWriteToParser`, record `n/x/y` into the record-manager pattern list.
2. Compute pattern mask width/height and offsets, bounding box `vMinX..vMaxX`, `vMinY..vMaxY`,
   centre `cx,cy` (`:3396-3430`).
3. `Result := true`; `maskStand := GetPatternMaskStand(patName)`, `maskInvStand :=
   GetPatternInvMaskStand(patName)` (`:3434-3435`).
4. **Fast path** when `not doStand` and `angle=0`: `step = 4`, sample every 4th mask cell
   (`:3441-3470`). For any cell where `(maskValue and maskStand) or ((not maskValue) and
   maskInvStand)`, reject if out of map **or** `gPatternMask[indJ,indI]` already true.
5. Full path over the whole mask box (`:3471-3513`): same predicate; with `doStand=false` it
   rejects, with `doStand=true` it marks `gPatternMask := true` for the relevant cells.
6. `Ext` runs step 5 with `doStand=false` first; only if it returns true does it run the
   `doStand=true` stamping pass. All D07 call sites pass `angle=0`, so the rotated branch is
   present but unused here. **[O]**

**[I] Interpretation:** "rejects against water/rock/other patterns" is emergent from `gPatternMask`
occupancy. Water enters the mask from `height < -0.1` (`dogenerate.inc:1557-1564`); earlier tiled
patterns and relief patterns stamp it; the three start ellipses stamp it. The checker itself knows
nothing about terrain semantics. There is no special water/rock argument.

For global passes, `_misc_SetupPatternsByType` (`misc.script:3681-3726`) computes
`needed := floor(mapW*mapH*freq)` and `trycount := floor(256*mapsizeoptimise)` where
`mapsizeoptimise := (320*320)/(mapW*mapH)` and is multiplied by `0.65` if `< 1` (`:3685-3704`).
**[D]** 256 tries at 320×320, ~455 at 240×240, ~41 at 640×640.

### 3.8 Deposit stamp and amounts [O / U]

- **[O]** `mng_1.pattern` is 3,730 B with header `08 00 00 00 0a 00 00 00` → 8×10 cells;
  prior `DTRN_05 C9` re-derived 63 records of 24 bytes at `0x18b` and 32/80 mask cells. Same
  family shape for `mni`/`mnc` and desert variants. Record-id→prop mapping remains [U].
- **[O]** Deposits are typed as ore resources by basename (`minegold/minegolds` → gold id 4,
  `mineiron` → 5, `minecoal` → 6; `env.inc/initial.inc:49-51`, `dmscript.global:794-797`), added
  to the resource grid (`:71`, `res.script:80-97`), and tagged for HUD highlighting only
  (`env.inc/nothing.inc:12,94`). `_res_Init` sets `hp := 0` (`res.script:23-32`);
  `initial.inc:74-103` overrides hp only for wood/stone/food. **[I]** Ore deposits therefore look
  like non-depleting markers; **[U]** any finite "deposit amount" value. `startingsettings.cfg`
  `addresources{gold=1000,iron=6000,coal=9000,…}` values are *player starting stock* added via
  `dogenerate.inc:261-263,289-291`, not per-deposit capacity.

### 3.9 `FillOwnerMap` — flood fill [O]

`dogenerate.inc:1370-1425` (`CheckOwnerDist` at `:1361-1368`):

```
for every scan-grid cell: fChecked=false; owner=-1; dist=-1
for each start i: if PosToScanGridIndices(start[i]) then
    grid.owner := arrStartPosBusy[i]; grid.dist := 0
dist := 0; repeat
  f := false
  for every cell with dist == current and not fChecked:
      for each in-bounds 4-neighbour: CheckOwnerDist(nb, dist, owner)
          // assign dist+1 and this owner only if nb.dist < 0
      fChecked := true; f := true
  dist := dist+1
until not f
```

**[O]** Grid size: `gc_scangrid_size = 4`, `gc_scangrid_mapwidth = 640` → 160×160 cells
(`dmscript.global:57-58`). **[O]** No terrain/collision test is applied inside the BFS: ownership
propagates through the whole connected grid even across water. **[O]** `SetupBorderObjects`
(`:1430+`) then places `ptborder`/`ptborderwater` props along owner boundaries; it is only called
under peacetime (`:2065`).

### 3.10 Exact top-level pass order [O]

From `dogenerate.inc` (line numbers in brackets):

1. Clear `gPatternMask` (fixed `cMapSize = 640`) and reset pattern map / objects [`:438-453`].
2. `SetupTiledPatterns('tiles')` (or `desert_tiles`) [`:1528-1536`].
3. `SetRandomKey(randkey1)` [`:1538`]; choose terrain type [`:1547-1565`].
4. `ExecuteState('GenerateMap')` → height field from mask; then mark all cells with
   `height < -0.1` and not already occupied as occupied (`cWaterShoreHeight = -0.1`) [`:1565-1564`].
5. `minesdensity := gen.resourcemines`; if `>2` choose `floor(RandomExt*3)` [`:1544`, `:1586-1587`].
6. `RandomStartingPoints(...)` → for each start: stamp ellipse 5×7, `SetupMines(minround=0,
   maxround=1)`, `SetupStartingResources` [`:1615`, `:980-988`].
7. `SetRandomKey(randkey1)` again [`:1616`]; choose relief type [`:1621-1622`].
8. Relief probabilities → global plateau/hill/mountain/ravine patterns [`:1738-1766`].
9. **Global mines:** for each start `SetupMines(minround=1, maxround=0)` [`:1768-1770`].
10. `SetRandomKey(randkey1)` [`:1772`]; global forests, stones, swamps, lakes, plains [`:1774-1906`].
11. `SetRandomKey(randkey1)` [`:1909`]; spawn starting peasants [`:1921`].
12. `SetRandomKey(randkey1)` [`:1927`]; scale-fix pass [`:1940-2020`].
13. `FillOwnerMap(spcount)` [`:2062`]; optional `SetupBorderObjects` [`:2065`];
    `_misc_SetShoresCollision` [`:2068`]; final lighting/colour [`:2073+`].

**[D]** The repeated `SetRandomKey(randkey1)` means each major stage starts from the same RNG
stream reset (cf. D02 for the exact `RandomExt` contract). This is a donor behaviour the port must
not flatten into a single continuous RNG sequence if stage-by-stage determinism is required.

### 3.11 Verdict on the Port belief (D07 scope)

| Port belief | Verdict | Evidence |
|---|---|---|
| `SetupMines` places gold 14–22, iron 32–42, coal 70–82 | **[O] REFUTED**: those are ring-distance bands applied to *each* of gold/iron/coal; current large-map bands are 14–22 / 32–42 / 70–82 / 22–38 for rings 0–3 | `dogenerate.inc:544-553,595-601`, `ev_a33507f9…` |
| up to 256 attempts | **[O] CONFIRMED per ore per ring** (not per whole pass); global `_misc_SetupPatternsByType` uses `floor(256*mapsizeoptimise)` | `:525,555`, `misc.script:3704` |
| density 0/1/2 → 3/4/5 rings | **[O] CONFIRMED**, capped by `maxround`; near call `0..1`, global call `1..rounds-1` | `:528-535`, `:985`, `:1770` |
| `SetupStartingResources` guarantees food rects + stone/forest rings | **[O] stone/forest rings CONFIRMED; food rects NOT in this function** (fields are mill-seeded) | `:720-947`, F2-02 §3.3 |
| `FillOwnerMap` flood-fills from starts | **[O] CONFIRMED** (4-neighbour BFS, scan grid) | `:1370-1425`, `dmscript.global:57-58` |
| `CheckStandPattern(Ext)` rejects water/rock/other patterns and 3 elliptical keep-clear zones per start | **[O] partially CONFIRMED / refined**: generic occupancy mask (water/rock enter it earlier), ellipses 5×7, 12×15, 22×18; no semantic water/rock branch; `cCircle3` is stamped *after* all start-resource passes | `misc.script:3384-3521`, `dogenerate.inc:407-415,769,947,984,1557-1564` |
| deposit amounts | **[U]** no per-deposit capacity set by generator | `res.script:23-32`, `initial.inc:49-51,74-103` |

---

## 4. Implications for port — PORT APPROXIMATION (design input only; no source edited)

All items below are **PORT APPROXIMATION** until a cited spec, decoder and donor GPU A/B frame exist.

1. Model deposits as **ring passes**, not ore-specific radii: for each start, for ring
   `i in [minround, rounds-1]`, for ore `in {gold, iron, coal}`, draw `dst` from the ring band,
   draw `angle = R*360`, rotate, test/stamp. Keep the ordered version/size/player-count bands
   verbatim (§3.3), including the small-map missing-`i=2` quirk (document it; do not silently
   "repair" it if byte-level reproduction is the goal).
2. Near deposits use `minround=0,maxround=1`; global deposits use `minround=1,maxround=0`.
   The same ` rounds` cap (3/4/5 by density) applies to both.
3. Implement **one occupancy mask** (`gPatternMask`) with a two-phase checker (test, then stamp);
   stamp water/shore from `height < -0.1` before any resource pass; stamp the three nested start
   ellipses at 5×7, 12×15, 22×18 centred `(x, z+2)` at the exact points in §3.6/§3.10.
4. Implement **weighted pattern selection with `Freq × 0.2` damping and `FreqSum` bookkeeping**;
   without it, repeated stamps diverge from the donor distribution even if radii match.
5. Do **not** guarantee food rectangles inside `SetupStartingResources`; if food near start is
   required, model the mill → `_unit_DoSeedWheat` path (49 nodes, 1.6981 spacing, 45° grid;
   prior F2-02 §3.3) and label it a separate pass.
6. Reset the RNG stream at each donor `SetRandomKey(randkey1)` boundary (D02 must confirm the
   `RandomExt` contract before any numeric replay claim).
7. `FillOwnerMap` is territory ownership, **not terrain placement**: keep it after prop/peasant
   passes; do not use it to decide where mines/forests go.
8. Deposit *amount* should be represented as a non-depleting marker unless D02/F08 finds a
   finite source; do not invent a capacity.

---

## 5. Risks

- **Activation risk:** every relevant `.inc` line is `[*] = ;`-prefixed (authoritative intent
  text, not proven runtime execution). The donor binary was never executed per guardrails.
- **Binary-analysis risk:** function discovery truncated at 6M instructions; the lifter
  misparses embedded ASCII, so "no native function" is a tool-limited observation, not a proof
  that no native helper participates in stamping.
- **Version risk:** `gRecordGeneratorVersion := gDataVersion` for new games
  (`initmapgen.inc:57`) but `gDataVersion` is an engine-side value not found in script text;
  choosing the wrong band changes 70–82 into 50–62 or 88–106. F03/D02 should settle it.
- **Enum risk:** `mapsize>2` commented `// tiny`; its semantic label is [U].
- **Stale-`dst` risk:** reproducing the small-map ring-2 quirk may produce a nondeterministic
  radius if locals are not zero-initialised; a port must choose and document a policy rather than
  inherit an accident silently.
- **Cross-worker contradiction:** prior `GUIDE4:2127` and `F2-02 F8` group the bands by ore.
  D07's ring interpretation is based on the literal loop nesting and should be cross-checked by
  COORD before the spec is frozen.
- **No parity claim:** no donor GPU A/B frame; no capture was run by this worker.

---

## 6. UNVERIFIED register (with passes attempted)

| # | Unverified item | Passes attempted | What would settle it |
|---|---|---|---|
| U1 | Runtime activation of `[*] = ;` DScript text | P1–P7 (binary searches P1–P5 cannot see external script text); no execution allowed | Donor runtime trace / exported saved record parsed by an approved lane; remain [U] |
| U2 | Native class methods behind `XMapGenerator`/`XCastleGenerator` | P1 name search (0, truncated), P2 strings (0), P3 bytes (literals found), P4 study/pseudocode/disasm/xrefs (garbage / 0 xrefs), P5 feature_find (0), P6 data cross-check (script algorithm) | Full Ghidra/Cutter session with complete function discovery; still [U] for concrete methods |
| U3 | Finite deposit amount / capacity | P6: `generator.cfg`, `initial.inc`, `res.script`, `nothing.inc`, pattern header; no finite value found | Native/engine docs or replay save inspection; remain [U] |
| U4 | `gRecordGeneratorVersion` value in shipped random games | P6 grep: set from `gDataVersion` (`initmapgen.inc:57`), `gDataVersion` not in script text; `generator.cfg` has no `ver` key | F03 or saved-record analysis |
| U5 | `mapsize` enum → "tiny" mapping | P6 read of literal condition + comment (`dogenerate.inc:572`); comment ambiguous | UI/custom-game settings decode (F03) |
| U6 | Whether unassigned `dst` is zero or stale in ring 2 small-map band | P6 double-read `:625-655`; DScript local-init semantics not in readable data | DScript VM / engine semantics lane; remain [U] |
| U7 | `gPatternMask` exact footprint for every pattern family (width/height/offset/inv-mask) | P3 binary strings, P6 checker + `generator.cfg` + `mng_1.pattern` header (8×10) | F01 complete `.pattern` parser |
| U8 | Visual parity of resulting forests/stones/mines | none (no donor A/B frame, no runner job) | A05 capture harness + owner verdict |

---

## 7. Open questions

1. Which `gRecordGeneratorVersion` band does the retail 2026 build actually take, and is the
   70–82 ring active on a 320-cell map with 2 players? (D02/F03)
2. Does `mapsize>2` mean "not tiny" (as the code structure suggests) or "tiny" (as the inline
   comment says)? Determines which table row applies.
3. What does `RandomExt` return and how is `SetRandomKey` re-seeding implemented — are stage
   resets idempotent or stateful? (D02; §3.10 shows three+ resets.)
4. Is the missing `case i=2` a shipping bug that actually produces duplicate/stale mine rings on
   2–4 player small maps, or is the local `dst` zero-initialised by the VM?
5. What are the exact stand-mask cells of `mng_*/mni_*/mnc_*` and `str_new_*/d_stn_*` (F01/F08),
   i.e. how many cells one accepted deposit occupies in `gPatternMask`?
6. Do the recorded `Freq`/`UsedCount` values persist into saved games/replays, affecting replay
   determinism of later placement stages?
7. Is `cCircle3` (22×18) intentionally stamped only *after* starting resources, i.e. a ring that
   protects later global passes but does not protect the start's own stone/forest? (Text says yes;
   intent [I].)

---

## 8. Closing statement

D07 recovered the donor resource-placement algorithm from **donor data text**, anchored by
**binary naming evidence** and cross-checked against cfg/pattern bytes, with a documented
six-pass verification log for every contradiction. The port belief is refined: the 14/32/70
family are **ring radii shared by gold/iron/coal**, 256 is the per-ore-per-ring attempt count,
stone/forest rings are real but food rectangles are not part of `SetupStartingResources`, the
owner flood-fill is a late, terrain-agnostic BFS, and rejection is a two-phase occupancy-mask
test with three nested start ellipses. No donor binary was executed, no donor file was copied
into the repo, no source/config/test/git state was changed, no Godot runner job was submitted,
and **no donor-parity claim is made**.

*End of D07. One report written.*

---

### Appendix A — evidence-id shorthand

Full ids are in §2; short forms used in-text:
`ev_43fb1f88…` = XMapGenerator bytes; `ev_7f22818c…` = XCastleGenerator bytes;
`ev_85467957…` = sub_71c0b4 study; `ev_f4a62967…` = `pop eax` at `0x71c0a5`;
`ev_a33507f9…` = `SetupMines`; `ev_7733cb43…` / `ev_5200df4f…` = `SetupStartingResources`;
`ev_71484fdd…` / `ev_32fd9062…` / `ev_5826ad27…` = checker / Ext / global placer.
Craft Anything findings `fnd_1`–`fnd_5` were appended to the shared investigation ledger
(`fnd_4` = ellipses, `fnd_3` = checker, `fnd_5` = ring-2 anomaly).
