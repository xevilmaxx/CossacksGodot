# D02 — Donor seed / RNG reverse-engineering (2026-11-26)

**Worker:** D02 (Wave D, binary lane). **Deliverable:** this report only. No source,
shader, config, asset, git or Godot changes were made. Donor was accessed read-only at
`C:\Games\Cossacks 3`; no donor binary was executed or copied into the repo.

**Active target used (announced):** `t_87f0f3c130b0` = `cossacks.exe` (Deep mode, Ghidra
engine). Cross-check target `t_68474ddde43f` = `editor.exe`. Other workers changed the
*global* active target during this session (one probe unexpectedly returned `editor.exe`);
from that point all Craft Anything calls pinned `document:` explicitly. No target was
re-opened or re-selected by this worker.

**Label key:** `[O]` observed, `[D]` derived, `[I]` inferred, `[U]` UNVERIFIED,
`PORT APPROXIMATION`. No donor visual/behavioural parity is claimed anywhere in this report.

---

## 1. Executive summary

1. `[O]` The port's "randkey1/2" is a misnomer: the donor schema is **two 32-bit integers
   `randkey0` and `randkey1`** (`TMapSettingsGen`, `map format 0x182640`). Installed via
   `SetRandomExtKey64(k0,k1)`, they form a 64-bit state whose **high word is `randkey0`,
   low word is `randkey1`**. `GetRandomKey` returns `randkey1` (the low word), which is
   embedded in the generated map filename. (`donewgame.inc:16,33-37`; `ev_14126307…`;
   `DEC_06_map_formats.md §7.1`.)
2. `[D]` **The core generator is not a Mersenne/xorshift/LCG64 — it is a 32-bit LCG**
   run inside a 64-bit arithmetic wrapper:
   `s ← (s × 0xFC0D + 0x3C6EF35F) mod 2^32`, with output
   `RandomExt() = float32( int64(s) / 2^32 )` in `[0,1)` after the first draw.
   Recovered at `cossacks.exe` CODE VA `0x60f64c`–`0x60f696` (file offset
   `0x20ea4c`–`0x20ea96`); identical constants appear independently in `editor.exe`,
   `config.exe` and `modman.exe`. Full pass log in §3.
3. `[O]` **No `RandomInt` / `RandomFloat` engine API exists.** The donor DScript API table
   registers only `RandomExt(): Float`, `Random(): Float`, `GetRandomKey`, `SetRandomKey`,
   `GetRandomExtKey64`, `SetRandomExtKey64` (`cossacks.exe:CODE+0x209a62…0x209b31`,
   `ev_1858bbfd…`, `ev_3526b7da…`). `RandomInt`/`RandomFloat` are port inventions.
   Script wrappers are `GetRandom(n) = floor(RandomExt*n)` and
   `GetRandomRange(min,max) = min+floor(RandomExt*(max-min+1))`
   (`dogenerate.inc:990-997`, `ev_…`/read of 2026-11-26).
4. `[O]` **There are at least three independent RNG streams** using the same algorithm:
   the DScript-global state at `0x9048d4/d8`, per-object generator RNGs (e.g.
   `sub_7281bc`, state at `this+0x18/+0x1c`, 15 callers in the relief/terrain region
   `0x71e438`–`0x728190`), and the separate `Random()` Delphi LCG
   (`seed = seed*0x8088405+1`, output `seed/2^32`). The three native setters
   `SetRandomExtKey64`, `SetMapGeneratorRandomKey`, `SetGlobalMapGeneratorRandomKey`
   are called back-to-back in `donewgame.inc:33-35`, so they seed different instances.
5. `[O]` **Determinism is stage-scoped, not one continuous stream.** `SetRandomKey(randkey1)`
   is re-issued before every generation stage (9 sites in `dogenerate.inc`, 2 in
   `initmapgen.inc`, plus 3 `SetRandomExtKey64` resets in `generatemap.inc`). Start
   selection consumes a *fixed number* of draws per player index
   (`for j:=0 to i-1 do RandomExt` etc.), so reproducible replay needs **call-for-call
   parity inside each stage**; stage reseeds isolate stages from one another.

---

## 2. Evidence table

| Evidence id / path:offset:line | Observation | Label |
|---|---|---|
| `ev_1858bbfd695a985a6714c2bbe0a110faa7af2880b5f5ddd31f25614b5e97a695` | Ghidra pseudo-C of `FUN_00608238` — the DScript native registration routine; maps declaration strings to implementation addresses, including `RandomExt → LAB_0060f64c`, `GetRandomKey → LAB_0060f69c`, `SetRandomKey → LAB_0060f6a4`, `GetRandomExtKey64 → FUN_0060f6bc`, `SetRandomExtKey64 → LAB_0060f6dc`, `Random → LAB_0060e47c`. `[O]` |
| `ev_3526b7da4de6db7c011e8e090b9a733576bb2c7cecb03be81e4496318228c169` | Raw bytes at CODE `0x60a5c0` containing the declaration strings `function RandomExt(): Float`, `function GetRandomKey`, `procedure SetRandomKey(key: Integer)`, `GetRandomExtKey64`, `SetRandomExtKey64`. `[O]` |
| `ev_dbb98317fb70ecfbcbcbc13b960279a8a2afcea6702b16dad793319aacae8cea` | `native_bytes_find "RandomExt"` → file offsets `0x209a62`, `0x209ae5`, `0x209b31` (VA `0x60a662`, `0x60a6e5`, `0x60a731`), section CODE — prior string tools missed these because they only search data sections. `[O]` |
| `ev_d5b51af0808dd609842ab36f411ca6cbd51212d8de038e641acfd28d3198239f` | PE sections: CODE file offset `0x400` → VA `0x401000`; used for all offset↔VA conversions (`VA = file offset + 0x400C00`). `[O]` |
| `ev_3dfbf17f1bd9757f8dc35812a1b4b8dc2568d6ed0dbd306975d5ce43cdefe173` | On-demand Ghidra pseudo-C of `FUN_0060f64c`: `uVar1 = FUN_00406718(0xfc0d,0,param_3,DAT_009048d4,DAT_009048d8); DAT_009048d4 = FUN_004067b8(uVar1+0x3c6ef35f, carry); DAT_009048d8 = extraout_EDX`. `[O]` (partial: x87 tail omitted) |
| `ev_de4333ad1c1957dae2fdefc5beed366d2bc96fa3737c759d9a6a3e3d583855cc` | `native_function_study 0x406718` — 14-instruction 64×64 multiply helper, `ret 8`; confirms the `0xFC0D` multiplier and that exactly two stack words are consumed. `[D]` |
| `ev_f4c7db72f65db2271f5967e4bf03ddbffa53dc564fc7ed331c80c06136820980` | `native_function_study 0x4067b8` — 64-bit modulo helper (returns remainder in `edx:eax`, divisor `CONCAT44([esp+0x18],[esp+0x14])`); cross-checked with its use in `sub_406874` where divisor = 10. `[D]` |
| `ev_6283059d19b38fbd59adb0a1fbeb300f26eeeb1dc96462ece3dbe4ce6b508a4c` | `native_data_show 0x60f698 f32 = 4294967296.0` (`2^32`), the output divisor of `RandomExt`. `[O]` |
| `ev_843ff3a77abdfee572c61d863964e2b9c6baed581ee92cd38223a6b3c3bc49c8` | `native_function_study 0x7281bc` — second RNG instance (state `this+0x18/+0x1c`), same constants and scaling, 15 callers in `0x71e438`–`0x728190`. `[O]` |
| `ev_9419ae7e34428f057a409726f34c41890b164a3b47871c9f08fcd0272b5051a8` | 53 callers of `0x403a28`, the separate Delphi `Random()` LCG. `[O]` |
| `ev_35cf1117bbdbb2bad03de0f84f65ac1e221fafaaed7b09e84233a0fb2c2014b0` | `native_data_show 0x8f206c f64 = 2.3283064365386963e-10` (`2^-32`), scaling constant of `Random()`. `[O]` |
| `ev_14126307a277fb94960c790fc45a959cc408ae4528b7e43ea27ec8ac8dfaa335` | `data\gui\menu.inc\donewgame.inc:0-49` — `GenerateMapRandKey`, three native setters, map name from `GetRandomKey`, size enum. `[O]` |
| `ev_00a36e2790c11f786defba9f6619b56dda5b74246d529210aff17f37494b5687` | `dogenerate.inc:1534-1541` — `SetupTiledPatterns` then `SetRandomKey(randkey1)` before `ExecuteState('GenerateMap')`. `[O]` |
| `ev_b305f68f23260c3520c509a91b5fc8c86e3ed1870b30b7ea7532998454b03bf0` | `dogenerate.inc:1612-1623` — `RandomStartingPoints` then `SetRandomKey(randkey1)`, then `relieftype := floor(RandomExt*5)`. `[O]` |
| `ev_0214d722919b8c8a34d0774d7d70b912848deec4509ccaf288a114b0f3c515c8` | `dogenerate.inc:0-11` — `foreststype := floor(RandomExt*3); foreststype := 0` (one consumed draw, neutralised result). `[O]` |
| `ev_c06572cb82a7dea0943d204fbf90c9d91cdfe25707c2a631d21ac6f3eabb695d` | `dogenerate.inc:1096-1103` — per-player `SetRandomKey` + `for j:=0 to i-1 do RandomExt` in `RandomStartingPoints`. `[O]` |
| `ev_16bb0349822eef5fb69b9f227c3d8fcc272c65418f3f0b56ac317ba0fcbf410f` | `dogenerate.inc:1578-1595` — `minesdensity := floor(RandomExt*3)` occurs *before* the `:1616` reseed. `[O]` |
| `ev_d53dcd01f532054123ab5ba9bdbcfdcd2d9c1e6946bfad18b848d02676ccd322` | `dogenerate.inc:1765-1778` — `SetupMines` loop then `SetRandomKey` then pattern-weight scaling. `[O]` |
| `docs/coord_swarm_2026-11-25/reports/DMAPGEN_01_skirmish_options.md:224-292` | Prior-art transcription of all 11 stage reseeds and version gates. `[O]` (prior observation, re-verified in part above) |
| `docs/decomp/DB_SCRIPTS.md:71` / `docs/terrain_swarm_2026-11-25/reports/F01_almanac_terrain.md:105` | Prior art explicitly marked RNG internals UNVERIFIED; this report closes that gap for the state update only. `[O]` |

---

## 3. Method — and the multiple-pass rule applied to anomalies

Owner directive: *if decompilation looks strange/garbled/contradictory, do multiple passes before
skipping; record every pass and why the final reading was accepted.* Applied as follows.

**Anomaly A — string tools reported zero RNG API strings.** `native_strings_find` returned
0 for `RandomExt`/`randkey`/`SetRandomKey` on `cossacks.exe`, contradicting the fact that
the scripts call these names and prior evidence that `config.exe` contains them.
Passes: (1) `native_strings_find` with explicit `document:` → 0, with `Runtime` as control → 1;
(2) raw Python byte scan of all donor EXEs → `RandomExt` at `cossacks.exe:0x209a62/0x209ae5/
0x209b31`; (3) `native_bytes_find` → same three addresses, section CODE, with the tool's
`data_sections_only` limitation explaining the discrepancy. **Accepted:** the names are
compiled into the CODE section, not a data section; absence in `native_strings_find` is not absence.

**Anomaly B — Ghidra pseudo-C of `RandomExt` omits the output scaling and shows odd carry.**
`FUN_0060f64c` pseudo-C ends after the two state stores; the `fild`/`fdiv`/`fstp` tail is
missing, and carry is rendered as `(uint)(0xc3910ca0 < uVar1)` (the exact threshold should be
`0xC3910CA1`).
Passes: (1) Ghidra `native_function_pseudocode` at `0x60f64c`, `0x60f682`, `0x60f688` —
all three returned the same truncated body; (2) clean-room `native_function_study` on the two
helpers `0x406718`, `0x4067b8` — multiply and modulo confirmed, but the call convention is
flagged `calling_convention_assumed`; (3) raw x86 via Capstone 5.0.7 over `0x60f64c..0x60f696` —
full `fild qword [0x9048d4]; fdiv dword [0x60f698]; fstp dword [esp]` recovered;
(4) `native_data_show` on `0x60f698` → `4294967296.0`; (5) byte-level cross-check of the
same code sequence in `editor.exe:0x4907be`, `config.exe:0x33701b`, `modman.exe:0x191dc1`
(identical `b8 0d fc 00 00 33 d2 e8 … 05 5f f3 6e 3c 83 d2 00 …`).
**Accepted:** raw assembly + constant read, with the Ghidra carry expression treated as a
decompiler artifact. Label `[D]` for the recurrence, `[O]` for the constants.

**Anomaly C — the modulo divisor appeared to be the old state (nonsensical LCG).**
A first reading of `sub_4067b8` stack slots (`[esp+0x14]=state_lo`, `[esp+0x18]=state_hi`)
implied `new = (old*M+C) mod old`, which would collapse the stream.
Passes: (1) clean-room pseudo-C of `0x4067b8`; (2) Ghidra pseudo-C of `0x4067b8`
(`uVar3 = dividend % divisor`; both agree it is *modulo*, not divide); (3) re-derivation of
stack depth: `0x406718` ends in `ret 8`, which **consumes the two pushed state words**, so
at the `0x4067b8` entry the remaining stack words are `push 1` (high) and `push 0` (low)
→ divisor `CONCAT44(1,0) = 2^32`; (4) independent check of `0x4067b8` from `sub_406874`
where the pushed pair is `0` (high), `0xA` (low) and the routine is used to compute decimal
digits — proving the slot roles. **Accepted:** divisor is `2^32`; the initial reading was a
stack-depth error. No result was skipped.

**Anomaly D — the second API declaration table (`GenerateMapRandKey`, `SetMapGeneratorRandomKey`)
has no direct code xrefs.** Passes: `native_bytes_find` found the declaration strings at
`cossacks.exe:0x29e852` / `0x29e902`; `native_function_find`/`native_function_pseudocode` at those
VAs failed ("may be data, or code reached only through a table of pointers"); scans for a
4-byte pointer to each declaration string and for `b9 <declVA>` patterns returned 0; full-file
search of `C:\Games\Cossacks 3\data` showed only *call sites*, no definition. **Accepted:** the
implementation of `GenerateMapRandKey` was **not** recovered → `[U]` in §7.

**Target switching:** one early `native_functions_search` returned `subject.name = editor.exe`
even though the active target was `cossacks.exe`. All subsequent calls pinned `document:`.
This is a session hazard, not a donor anomaly.

---

## 4. Findings

### 4.1 The DScript native API surface (anchor for all further RNG work)

`[O]` `FUN_00608238` (`cossacks.exe` VA `0x608238`, file `0x207238`) is the registration
routine: for each entry it executes `call [esi+0x30]` with `(declaration_string, implementation_address)`.
At file offsets `0x209a62`, `0x209a8a`, `0x209ab2`, `0x209ae5`, `0x209b31` the relevant
entries are (evidence `ev_1858bbfd…`, `ev_3526b7da…`):

| DScript declaration | Implementation VA | File offset |
|---|---|---|
| `function RandomExt(): Float` | `0x60f64c` | `0x20ea4c` |
| `function GetRandomKey: Integer` | `0x60f69c` | `0x20ea9c` |
| `procedure SetRandomKey(key: Integer)` | `0x60f6a4` | `0x20eaa4` |
| `procedure GetRandomExtKey64(var key0,key1: Integer)` | `0x60f6bc` | `0x20eabc` |
| `procedure SetRandomExtKey64(const key0,key1: Integer)` | `0x60f6dc` | `0x20eadc` |
| `function Random: Float` | `0x60e47c` | `0x20d87c` |

`[O]` There is **no** `RandomInt` / `RandomFloat` entry. `[D]` The port's assumption of such
wrappers is wrong; they must be treated as port-local helpers, not donor behaviour.
`GetRandom`/`GetRandomRange` are *script* functions (`dogenerate.inc:990-997`).

### 4.2 Exact state update — a 32-bit LCG in a 64-bit wrapper

`[D]` From the full x86 sequence at `cossacks.exe:CODE+0x20ea4c` (VA `0x60f64c`), with
`state = CONCAT44(DAT_009048d8, DAT_009048d4)`:

```
; DScript RandomExt(): Float — cossacks.exe VA 0x60f64c..0x60f696
push ecx                       ; scratch slot for the returned float
push 1                         ; divisor high word
push 0                         ; divisor low word
push [0x9048d8]                ; state high word (key0)
push [0x9048d4]                ; state low  word (key1)
mov  eax, 0xFC0D               ; multiplier 64525  (0xfc0d)
xor  edx, edx
call 0x406718                  ; 64x64 multiply -> edx:eax, ret 8 (eats 2 stack words)
add  eax, 0x3C6EF35F           ; +1013904223
adc  edx, 0
call 0x4067b8                  ; 64 % 0x0000000100000000 -> edx:eax (edx=0)
mov  [0x9048d4], eax           ; new state low  = remainder
mov  [0x9048d8], edx           ; new state high = 0
fild qword  [0x9048d4]         ; signed 64-bit -> x87 extended
fdiv dword  [0x60f698]         ; divide by 2^32  (f32 constant)
fstp dword  [esp]
fld  dword  [esp]              ; return float32 in ST(0)
pop  edx
ret
```

Equivalent pseudocode:

```
state64 = (hi << 32) | lo
state64 = (state64 * 0xFC0D + 0x3C6EF35F) & 0xFFFFFFFF
hi = 0; lo = state64
return float32(float64(state64) / 4294967296.0)
```

`[O]` Constants: multiplier `0xFC0D = 64,525`; increment `0x3C6EF35F = 1,013,904,223`;
modulus `2^32 = 4,294,967,296`; output divisor `2^32` (`native_data_show 0x60f698`).
`[D]` Because increment is odd and multiplier `64525 ≡ 1 (mod 4)`, the LCG has full `2^32`
period (Hull–Dobell); no claim is made about statistical quality.
`[D]` After the first draw `hi=0` forever, so the key0 word only affects the **first** output
(via the 64×64 product cross term) and is then discarded. The `SetRandomKey` reseed
(sign-extended 32-bit key) also makes `hi=0` for any non-negative key, which is the normal
skirmish path.

`[D]` Worked example (Python model, not executed donor): with `randkey0=0, randkey1=1` the
first five states are `0x3c6fef6c` (0.236082996), `0x7dcc6bdb` (0.491400472),
`0xd9fc017e` (0.851501554), `0x5fb30ec5` (0.373825954), `0x5b109f60` (0.355722390).
With `randkey0=0x44a108f9, randkey1=0` the first state is exactly the increment
`0x3c6ef35f` (0.236067973), demonstrating the discarded high word. **UNVERIFIED** against
a live donor run (donor execution is prohibited).

### 4.3 Seed setters and key-word order

`[O]` `SetRandomExtKey64(k0,k1)` at VA `0x60f6dc` / file `0x20eadc` calls `0x8484ac`, which
**swaps** `eax` and `edx`, then stores: `state_lo = k1`, `state_hi = k0`.
Ghidra `FUN_008484ac` returns `param_2` (`=k1`) in `eax`; raw bytes at `0x8484ac` confirm the
swap. `[O]` `GetRandomExtKey64` (`0x60f6bc`) calls `0x8484d0` and writes
`*out0 = state_hi (k0)`, `*out1 = state_lo (k1)`.
`[O]` `SetRandomKey(k)` at `0x60f6a4`: `state_lo = k`, `state_hi = k >> 31` (arithmetic —
sign extension). `[O]` `GetRandomKey` at `0x60f69c` returns `state_lo` = `randkey1`.
This explains the map filename `'game_v'+gDataVersion+'k'+IntToStr(GetRandomKey)+'.map'`
(`donewgame.inc:37`) and the large u32 observed at `bonmis1.map:0x18c0f1 = 0x44a108f9`
(`DEC_06_map_formats.md §7.1`).

### 4.4 Skirmish seed derivation

`[O]` `donewgame.inc:16` calls `GenerateMapRandKey(randkey0, randkey1)` unless this is a LAN
client or a game restart. There is **no player-facing seed UI** in the donor skirmish flow;
seeds are generated per new game and preserved in the saved `.map` record / replay.
`[O]` The two keys are then installed into three different RNG owners at `donewgame.inc:33-35`:
`SetRandomExtKey64`, `SetMapGeneratorRandomKey`, `SetGlobalMapGeneratorRandomKey`.
`[U]` `GenerateMapRandKey`'s body is engine-native and was not located (Anomaly D).
`[D]` Prior work (`DEC_06 §7.1`) notes sampled version-13 maps place a large u32 at aligned
word index 2 and version-7 maps vary; these are consistent with `randkey1` but the
byte-to-field mapping is still `[U]`.

### 4.5 Wrappers and other RNG streams

`[O]` Script wrappers (`dogenerate.inc:990-997`):
```
function GetRandom(n)        := floor(RandomExt * n);
function GetRandomRange(a,b) := a + floor(RandomExt * (b-a+1));
```
`[O]` `Random(): Float` (`0x60e47c` → `0x403a28`) is a **different** generator:
`seed32 = seed32 * 0x8088405 + 1` (Delphi RTL LCG at `DAT_008f2008`), output
`float32( seed32 * 2^-32 )` (`0x8f206c = 2.3283064365386963e-10`, evidence
`ev_35cf1117…`). It is not reseeded by `SetRandomKey`/`SetRandomExtKey64`. Any donor script
that calls `Random()` rather than `RandomExt()` is outside the seeded stream — `[U]` whether
terrain generation calls it (the observed generation scripts use `RandomExt`).

`[O]` Per-object generator RNGs use the same recurrence. `sub_7281bc` (`0x7281bc`, file
`0x3275bc`) stores state at `this+0x18/+0x1c`, uses the same `0xFC0D` / `0x3C6EF35F` /
`2^32` constants, and has 15 callers in `0x71e438`–`0x728190` — a region whose Ghidra bodies
read/write 2-D float grids and pattern data (`FUN_0071fce0`, `FUN_00723748`), i.e. relief /
tile work. `[I]` This is the RNG owned by the map-generator object that
`SetMapGeneratorRandomKey` seeds. A third embedded instance with state at
`this+0x108/+0x10c` appears at `cossacks.exe:0x408a57`/`0x408aa1` and in the other EXEs.
`[U]` Exact class identity of each instance is not established (RTTI strings have no code
xrefs — `DA_PE.md §3`).

### 4.6 Call ordering / determinism contract

`[O]` Reseed sites (line numbers are `dogenerate.inc` unless noted):

| # | Site | What follows in that stage |
|---:|---|---|
| 0 | `initmapgen.inc:99`, `:146` | country selection consumes `floor(RandomExt*n)` at `:106,:114,:118,:124,:128` |
| 1 | `:1538` | terrain-type random (`:1551` `floor(RandomExt*6)` / `:1557` `floor(RandomExt*gc_MaxTerrainTypeCount)`) → `ExecuteState('GenerateMap')` |
| 2 | `:1100` | old `RandomStartingPoints`: per player `SetRandomKey(randkey1)`, then exactly `i` discarded draws, then one draw for the index |
| 3 | `:1161` | team path: per team, `i` discarded draws + `GetRandom(teamlist.Count)` |
| 4 | `:1177` (`ver>77`) | per player in team, `j+1` discarded draws + `GetRandom(points.Count)` |
| 5 | `:1213` | remaining points: `i+9` discarded draws + `GetRandom(pointsremained.Count)` |
| 6 | `:1616` | `minesdensity` random (`:1587`, **before** this reseed), relief random (`:1622`), relief/plateau/hill pattern placement (`:1624+`), `SetupMines` per start (`:1770`) |
| 7 | `:1772` | forest / stone / swamp / lake / plain pattern passes (`:1774-1907`) |
| 8 | `:1909` | `CreateUniqueStartingUnits` / `CreateStartPointPeasants` |
| 9 | `:1927` | preload / final stage |

`[O]` Additional resets inside `generatemap.inc`: `:190` mask choice
`floor(RandomExt*count)`, then `:216` `SetRandomExtKey64(randkey0,randkey1)`;
`:513` before `PostProcess` (gaussian noise); `:774` before `TextureMap`.
`[O]` One draw is consumed and discarded at `dogenerate.inc:5` (`foreststype :=
floor(RandomExt*3)`, immediately overwritten to 0 at `:6`) — a caller must reproduce that
draw to stay aligned.

`[O]` The stream is *global*: the same `RandomExt` is used by projectiles, AI, GUI and unit
scripts (e.g. `misc/projectile.inc/doexplode.inc:139-224`, `lib/gui.script:1044`,
`lib/ai.script:2517`), so any draw taken between two reseeds shifts subsequent draws.

`[D]` **Answer to the ordering question:** mask choice → start points → relief/mines →
pattern placement → starting units → texture/smooth/postprocess, with a fresh `randkey1`
stream at each boundary. Reproducibility therefore requires **call-for-call parity within
each stage** (including discarded draws and version-gated branches) but **not** across stage
boundaries that re-seed. A single continuous RNG stream (the port's current design,
`DB_SCRIPTS.md:137`) cannot reproduce donor replay fidelity.

---

## 5. Implications for the port (`PORT APPROXIMATION`)

All items below are recommendations, **not** parity claims. No donor GPU A/B frame exists.

1. `PORT APPROXIMATION` Implement the recovered LCG exactly as a 32-bit state:
   `s = (s * 64525 + 1013904223) & 0xFFFFFFFF; return s / 4294967296.0`.
   Use `uint32` arithmetic; do **not** feed the seed into Godot's `RandomNumberGenerator`
   (different algorithm) and expect parity.
2. `PORT APPROXIMATION` Keep **multiple named RNG instances**: one DScript-global stream,
   one (or more) generator-internal streams for relief/tile work, and — if used — the
   separate Delphi `Random()` stream. Seed all of them from the same `(key0,key1)` pair,
   mirroring the three native setters.
3. `PORT APPROXIMATION` Preserve key-word order: `key0 = high`, `key1 = low`,
   `GetRandomKey = key1`. The port's single integer seed maps most naturally to `key1`
   with `key0 = 0`, but this is an approximation until `GenerateMapRandKey` is recovered.
4. `PORT APPROXIMATION` Reseed per stage and mirror the fixed discarded-draw counts in
   `RandomStartingPoints` (`i`, `i`, `j+1`, `i+9`). Also reproduce the two neutralised
   draws at `dogenerate.inc:5-6` and the mask-choice draw at `generatemap.inc:190`.
5. `PORT APPROXIMATION` Add a `generator_version` concept: version gates `<53/<61/<63/<68/
   <70/<75/<77/>77/<80/<89/<91` change both draw counts and outcomes. Without it, replay
   of older maps and current-donor parity are both out of reach.
6. `PORT APPROXIMATION` Expose a deterministic test hook that dumps the draw sequence for a
   given `(key0,key1)` so A02/A05 can compare stage streams without executing the donor.

---

## 6. Risks

- **Over-claiming the first draw.** The high key word affects draw #1 only; if the port
  always reseeds with `SetRandomKey(randkey1)` first (as the donor does per stage), this quirk
  is invisible — but a UI-seeded port that skips the reseed will diverge on draw #1.
- **Float32 rounding.** `fstp dword` truncates x87 extended to IEEE float32; a port
  returning `float64` will differ in `floor(r*n)` at exact integer boundaries. Use float32
  for the returned value before any `floor` (evidence: raw x87 sequence, §4.2).
- **Shared global stream.** GUI/AI/projectile draws can consume the same stream; a port
  with a separate "terrain RNG" will be *more* stable than the donor, not identical.
- **Anchoring:** the RNG functions were found via the DScript registration table, not via
  RTTI names (which have zero code xrefs). This is a solid anchor for the *API*, but the
  class identity of the per-object RNGs remains inferred.
- **Packed stub:** `.bind` (entropy 7.96) was never unpacked or executed, so any RNG code
  living only there is outside this analysis (DA_PE.md §4).

---

## 7. UNVERIFIED register

| # | Claim | Status | Passes attempted |
|---:|---|---|---|
| U1 | `GenerateMapRandKey` body / how it derives `(randkey0,randkey1)` from time, hardware or network | `[U]` | strings, byte scan, `native_function_find`/pseudocode, pointer scan, full `data\` search — only call sites found |
| U2 | Byte-to-field mapping of `randkey0/1` in version-7 saved `.map` blobs | `[U]` | inherited from `DEC_06 §7.1`; no known-key generated map shipped |
| U3 | Exact class owning each embedded RNG instance (`+0x18`, `+0x1c`; `+0x108`, `+0x10c`) | `[U]` | xrefs + Ghidra bodies read; RTTI has no code xrefs |
| U4 | Whether terrain generation ever calls `Random()` (separate Delphi LCG) | `[U]` | generation scripts observed use `RandomExt`; exhaustive call-path trace not done |
| U5 | Output of the recovered LCG compared to a live donor replay | `[U]` | donor execution prohibited; only numeric model run |
| U6 | Whether `SetMapGeneratorRandomKey` / `SetGlobalMapGeneratorRandomKey` use *exactly* the same constants and word order as `RandomExt` | `[U]` | same constants observed in embedded instances at `0x7281bc` and `0x408a57`; setter bodies not anchored |
| U7 | Whether Ghidra's truncated pseudo-C for `RandomExt` hides any additional state update after the x87 tail | `[U]` | three pseudocode passes + full raw disassembly; tail ends in `ret` at `0x60f696` |

---

## 8. Open questions

1. Where is `GenerateMapRandKey` implemented, and does it use the Delphi `Random()` LCG,
   `GetTickCount`, or a hardware source? (Blocks true UI-seed parity.)
2. Do `SetMapGeneratorRandomKey` / `SetGlobalMapGeneratorRandomKey` seed the `+0x18` and
   `+0x108` instances respectively, and in which word order?
3. What is the exact draw count of `SetupMines` / `SetupStartingResources` for each
   `minesdensity` and `gRecordGeneratorVersion`? (Needed for byte-identical stage replay.)
4. Does `floor(RandomExt*n)` ever receive `n=0` in a version-gated branch (donor would
   produce 0; port must match rather than clamp)?
5. Can a known-key generated `game_v…k….map` be obtained read-only (e.g. from a replay pack)
   to validate U2 and U5 without executing the donor?

---

## 9. Closing

`[D]` The donor RNG is now specified at the arithmetic level: one 32-bit LCG, two key words,
a float32/2^32 output, three independent stream owners, and stage-scoped reseeding.
`[U]` The seed-*derivation* function and the exact mapping of saved-map seed bytes remain
open. No donor parity claim is made; all port mappings are labelled `PORT APPROXIMATION`.
