---
id: DEC-U-B6-G0-DENSITY-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B6-G0 — static fixed-seed mask check for fdens==0 off-starts (density angle)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b6_g0_density.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
pin: t_87f0f3c130b0 (cossacks.exe, 5,768,048 B, SHA256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C; NOT activated this ticket — no native craftanything used)
labels: [O, D, U, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
chain: 0/6
blocking_unverified: [G0]
verdict: "RESULT IS NOT GOOD while blocking_unverified non-empty; G0 stays [U]; no parity claim"
scope_guard: "Read-only shell (Get-Content/Select-String) over donor text under C:\\Games\\Cossacks 3\\data\\scripts\\** and data/game/var/** plus repo reports. No native craftanything used this ticket (hence no native_function_study call, no new evidence id + VA). No donor binary executed/copied; no Godot process, runner job, gate, harness, replay or port capture run; no source/shader/asset/config/test/fixture/result-JSON/git state written. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (B6 angle, T-G0 static fixed-seed mask check for fdens==0 off-starts)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b6_g0.md (prior B6 static angle; zero [D] values promoted; G0 [U])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_placement.md (relief field defaults; U-G0; forest_density side-data only)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb2.md (relief field residuals; no per-pattern float promoted)
---

# DEC-U-B6-G0-DENSITY — static fdens==0 off-start sweep; no zero-density branch writes height

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `chain = 0/6`. This report closes **zero** P0 items, promotes **zero** `[U]`→`[D]` values, invents **zero** densities/heights, and makes **no parity claim**. `RESULT IS NOT GOOD` while `blocking_unverified = [G0]` is non-empty.

## 0. Task and answer in 30 seconds

**Task (B6 density angle, T-G0):** static fixed-seed mask check for `fdens==0` off-starts; sweep donor scripts for `fdens`, forest density, off-start/mask checks and any height write guarded by a zero-density branch; confirm no zero-density branch writes height. Prior `DEC_U_placement` / `DEC_U_nb2` covered relief field defaults; prior `DEC_U_b6_g0` promoted zero `[D]` values only. G0 remains `[U]`.

**Answer:**

1. `fdens` / `forestDensity` / `forest_density` have **zero hits** in donor text under `C:\Games\Cossacks 3\data\scripts\common.inc\` — they are port-side names only `[O]` (§1). No invented density.
2. Donor G vocabulary is byte-proven text-side: `cGNone = 0`, `cGForest = 1`, `cGGenForest = 2`, `cGStone = 3`, `cGForestStone = 4`; `cGColorForest = 255`, `cGColorGenForest = 64`, `cGColorStone = 128`, `cGColorForestStone = 192` `[O]` (§1).
3. Off-start/mask text facts: white starts are exact `fr=1 ∧ fg=1 ∧ fb=1`, then zeroed (`fr := 0; fg := 0; fb := 0`); `ig = floor(fg*255)`; `gMapMask[x,y].g := fg`; decode `case ig of` with `else → cGNone`; neighbour clear writes only `.forest := cGNone` `[O]` (§2).
4. Height block reads **only** `fr`, `fb` + `terrain` class and calls `SetHeightData(realx, realy, hwater+hterrain)`; start-skip tests `(bRandomMap) and (fr=1) and (fb=1)` — **`fg`/`forest`/`ig` ignored** `[O]` (§3). No `SetHeightData` sits inside any `forest = cGNone` / `forest = 0` / zero-density branch in the searched text.
5. No new native call edge observed this ticket (no native tool used). Carried native consumer facts (reader/writer arities, no G→count consumer) are cited, not re-proven (§4).
6. Static text therefore shows **no zero-density branch writes height**, but engine liveness (fixed-seed execution trace / byte-dump) is not statically provable → **G0 stays `[U]`** with the exact fixed-seed zero-mismatch termination in §5. No promotion to live port behaviour.

## 1. Sweep method and `fdens` / density vocabulary `[O]`

Tooling: read-only `Get-ChildItem` + `Select-String` over `C:\Games\Cossacks 3\data\scripts\common.inc\*.inc` and `C:\Games\Cossacks 3\data\game\var\*.cfg`. Denied-path errors on unrelated `env/misc/units/user` subtrees were excluded by scoping to `common.inc`; no donor file written, no binary executed. No native craftanything called this ticket, so no new `evidence id + VA` exists; §4 carries prior VAs verbatim without re-claim.

| # | Pattern | Scope | Hits | Disposition |
|---|---|---|---|---|
| F-1 | `fdens` | `common.inc\*.inc` | **0** | `[O]` negative: port-side `PackedByteArray` name only (`variant3d/scripts/terrain_donor_gen.gd:1418-1419,1476-1490,1516`); never a donor text token |
| F-2 | `forestDensity` / `forest_density` | `common.inc\*.inc` | **0** / **0** | `[O]` negative: same; port side-data label only |
| F-3 | `density` (generic) | `common.inc\*.inc` | only `minesdensity` / `resourcemines` plumbing (`dogenerate.inc:522,528,980,985,1090,1114,1190,1223,1544,1586-1587,1615,1770,2100`) | `[O]` mine-density plumbing only; no forest-density derivation |
| F-4 | `dens` in `data/game/var/*.cfg` | `envscales.cfg`, `generator.cfg`, `objcustom.cfg` | only `grassforest*` group names, `stoneforests/desert_forests_*` family names, `sid = densta` — no numeric density | `[O]` family-name strings only, never a `G→count` rule |

Donor G enum + colour constants (text facts, exact `path:line`):

- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:13` — `const cGNone = 0;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:14` — `const cGForest = 1;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:15` — `const cGGenForest = 2;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:16` — `const cGStone = 3;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:17` — `const cGForestStone = 4;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:28` — `const cGColorForest = 255;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:29` — `const cGColorGenForest = 64;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:30` — `const cGColorStone = 128;` `[O]`
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:31` — `const cGColorForestStone = 192;` `[O]`
- Mirrors: `postprocess.inc:8-12,23-26`, `texturemap.inc:8-12,23-26` carry identical constants `[O]` (sweep §1 table, `GCOLOR DONE`).

## 2. Off-start / mask / zero-density branches `[O]`

All below are `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc` unless noted.

- White-start detection (scaled path): `:325` — `if (fr=1) and (fg=1) and (fb=1) then // starting position` `[O]`
- White-start zeroing (scaled path): `:339` — `fg := 0;` (with `:338` `fr := 0;` and `:340` `fb := 0;`) `[O]`
- White-start detection (equal-size path): `:413` — same `if (fr=1) and (fg=1) and (fb=1) then // starting position` `[O]`
- White-start zeroing (equal-size path): `:441` — `fg := 0;` (with `:440` `fr := 0;`, `:442` `fb := 0;`) `[O]`
- Channel quantise + store: `:343` `var ig : Integer = floor(fg*255);` / `:346` `gMapMask[x,y].g := fg;` and `:445` / `:448` same pair on the second path `[O]`
- Decode branch A: `:372` `cGColorForest : gMapMask[x,y].forest := cGForest;` / `:373` `(cGColorForest div 2) : begin` + `:375` `cRPlateau, cRHill, cRRavine : gMapMask[x,y].forest := cGForest;` / `:378` `cGColorGenForest : gMapMask[x,y].forest := cGGenForest;` / `:379` `cGColorStone : gMapMask[x,y].forest := cGStone;` / `:380` `cGColorForestStone : gMapMask[x,y].forest := cGForestStone;` / `:382` `gMapMask[x,y].forest := cGNone;` (else) `[O]`
- Decode branch B (duplicate site): `:474-482`, `:484` — same shape, same `else → cGNone` at `:484` `[O]`
- Neighbour clear: `:761` `if (gMapMask[x,y].forest=cGForest) then` → `:764` `gMapMask[x+i,y+j].forest := cGNone;` (inside `tmpPatternMask` guard `:756-764`) `[O]` — writes only `.forest`, never height
- Off-start consequence `[D]` (arithmetic, not native): on any non-white pixel with `fg = 0`, `ig = floor(0*255) = 0`, which matches none of `255/127/64/128/192` and falls to `else → cGNone`. No density/height value invented; this is the text decode rule only.
- Editor pre-mark (not skirmish height): `:818` `if ((not bRandomMap) and (gMapMask[x,y].forest<>cGGenForest)) or (gMapMask[x,y].bsmooth) or (gMapMask[x,y].water<>cBNone) or (gMapMask[x,y].broad) ... or (GetMapCollisionTag(realx, realy, True)>0) then` → sets `gPatternMask[x, y] := True` `[O]` — occupancy only, no `SetHeightData`.
- Post-bitmap export: `postprocess.inc:454` `if (gMapMask[x, y].forest>cGNone) then` → sets `fg := 1` for the debug bitmap (`:451-458`) `[O]` — export only, no height write.

Port-side `fdens` mapping (repo text, read-only `[O]`, not promoted):

- `variant3d/scripts/terrain_donor_gen.gd:1483` `C_GCOLOR_FOREST: dens = 1` / `:1484-1486` `C_GCOLOR_FOREST / 2:` gated `if terrain >= 1 and terrain <= 3: dens = 1` / `:1487` `C_GCOLOR_GENFOREST: dens = 2` / `:1488` `C_GCOLOR_STONE: dens = 3` / `:1489` `C_GCOLOR_FORESTSTONE: dens = 4` / `:1490` `fdens[i] = dens` (implicit `else dens = 0`) `[O]`
- `variant3d/scripts/terrain_donor_gen.gd:1476-1480,1513-1516` — `fdens` / `forest_density` is SIDE DATA ONLY; counts come exclusively from `_setup_patterns_by_type` global passes `[O]` port comment. No `forest_density → stamp-count` edge exists in the port text.

## 3. Height writes guarded by zero-density? — none in static text `[O]`

Exhaustive `SetHeightData` surface in `common.inc` (sweep `HEIGHT DONE`):

- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:242` — `SetHeightData(x, y, res)` inside `_misc_SmoothTerrainCustom` (neighbourhood `GetHeightData` at `:230-234`) `[O]` — smoothing kernel, no forest/fdens gate in its parameter list.
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:574` — `SetHeightData(realx, realy, hwater+hterrain)` in the height pass `[O]` — the only per-cell terrain height writer.
- `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1577` — `var height : Float = GetHeightData(realx, realy);` (reader only) `[O]`.

Height-pass block verbatim (`generatemap.inc:563-574`):

- `:563` `var fr : Float = gMapMask[ix,iy].r;` `[O]` — note: **no `fg` fetch here**
- `:564` `var fb : Float = gMapMask[ix,iy].b;` `[O]`
- `:565` `if (bRandomMap) and (fr=1) and (fb=1) then // starting point` + `continue;` `[O]` — start-skip ignores `fg` (asymmetry carried from `DEC_U_placement §1.5`)
- `:567` `var hwater : Float = cWaterHeight*(fb*(1+fr*3.5));` `[O]`
- `:568` `var hterrain : Float;` `[O]`
- `:569` `case gMapMask[ix,iy].terrain of` / `:570` `cRPlateau : hterrain := cPlateauHeight*fr;` / `:571` `cRHill : hterrain := cHillHeight*fr;` / `:572` `cRRavine : hterrain := cRavineHeight*fr;` `[O]`
- `:574` `SetHeightData(realx, realy, hwater+hterrain)` `[O]`

**Static verdict:** `hwater` uses only `fb`, `fr`; `hterrain` uses only `fr` + `terrain` class; the skip uses only `fr`, `fb`. `fg` / `ig` / `.forest` / `cGNone` / `fdens` appear **nowhere** in `:563-574`. The only `forest`-conditional writers (`:372-382`, `:474-484`, `:761-764`, `:818`, `postprocess.inc:454`) write `.forest`, `gPatternMask`, or debug-bitmap channels — never `SetHeightData`. Hence **no zero-density branch guards or performs a height write in the searched donor text** `[O]` (absence-in-searched-text; packed/computed regions unseen — not proof of engine-side absence).

Smoothing gates likewise read no density: S0 `SmoothTerrain(realx,-realy,False,3)` at `:591` on `bsmooth` cells; S1/S2 `_misc_SmoothTerrainCustom(...)` at `:606` / `:637` gated on `water==cBWater` + radius-2 class neighbourhood + `[minh,maxh]` band (`:621` `var bWater : Boolean = (gMapMask[ix,iy].water=cBWater);`) `[O]` carried.

## 4. Native call edge `[D]` — none new this ticket

- No native craftanything tool used → **zero new evidence ids, zero new VAs** this ticket `[O]` (scope guard).
- Carried (not re-proven) native consumer shape from `DEC_U_b6_g0.md §§1-2`, cited for completeness only: `GetBitmapPixel(const bitmap,x,y: Integer; var r,g,b,a: Float)` reader at `0x60ce36`; `SmoothTerrain` / `MapGeneratorSmoothTerrain` `(x,y,passes: Integer; radius: Float)`; `GetHeightData(x,y)/SetHeightData(x,y,value)` height-only; `StandPattern(WithAngle/Adv)` family takes `(plhandle, patternname, standx, standz, ...)` name+coords, never a G byte or density `[D]` carried. No byte-proven native edge `ig/fdens → needed/count` exists in the carried search.
- Port `data.assign_side("forest_density", fdens)` at `variant3d/scripts/terrain_donor_gen.gd:1516` is side data by its own comment; the only count producers remain `_setup_patterns_by_type` (`needed=floor(W·H·freq)`, `trycount=floor(256·mapsizeoptimise)`) and `SetupStartingResources` ring probes (`dogenerate.inc:720-947`) `[O]` carried text.

## 5. G0 stays `[U]` — exact fixed-seed zero-mismatch termination

Liveness (which branch the engine actually takes on a fixed seed, and the resulting height bytes) is **not statically provable** from text alone. G0 therefore stays `[U]`. Terminate only on zero mismatches across the stated repeats; never invent a `G→count` map or a height value to force a match.

Common harness (never invent; owner/COORD-gated where a donor run is required):

- Pin `t_87f0f3c130b0`; fix `randkey0=0, randkey1=<K>` (primary `K=1`; repeat `K=12345`), `W=H=320` (repeat 256/640 once), `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`, `foreststype=0`, caller `pattern_modifiers={small:1,mid:1,large:1,huge:1}`, fixed `families/patterns` bundle.
- Run the port `generate()` twice; diff the named arrays/counts below.

| Check | Named dump | Termination (zero mismatches) |
|---|---|---|
| C-G0a (this angle, port-internal) | `forest_density` side array on **3 shipped `_gauss` masks** with starts masked (e.g. `nowater2`, `land`, `mediterranean` shapes) | `fdens==0` on **every** off-start cell, 3/3 masks, 0 differing bytes. Never add a `G→count` map |
| C-G0b (height non-write) | `height` grid on the same 3 masks + `bsmooth`/water-class flags | height `== -1.1·(B/255)` cell-for-cell on class-None cells (starts excluded), 0 ULP diffs; zero height delta when `fdens` is forced through the `else→0` path vs masked — i.e. the zero-density branch provably writes no height |
| C-G0c (live dials, owner/COORD) | per-family `needed`/`trycount` trip counts + accepted-stamp counts from `SetupStartingResources` + `_misc_SetupPatternsByType` on fixed seeds | `needed==floor(W·H·freq)` exact and accepted counts identical across repeats, 0 mismatches; roulette/damping/occupancy ledger attached |

Until C-G0a/b/c all terminate, the register entry stays exactly: `T-G0 | G=0 zero-density closure | Fixed-seed mask check | fdens==0 off-starts, 0 mismatches | STATIC` with the live-count half `[U]`.

## 6. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | `fdens` 0 hits, `forestDensity`/`forest_density` 0 hits in `common.inc` donor text; `density` hits are mine-plumbing/family-name strings only | `[O]` this pass (§1) |
| 2 | G enum + colour constants at `generatemap.inc:13-17,28-31` (+ mirrors) | `[O]` this pass (§1) |
| 3 | White-start exact-white + zeroing (`:325,:339,:413,:441`), `ig=floor(fg*255)` (`:343,:445`), `g := fg` (`:346,:448`), decode `else → cGNone` (`:382,:484`), neighbour clear `:761/:764`, editor pre-mark `:818`, export `postprocess.inc:454` | `[O]` this pass (§2) |
| 4 | Height pass `:563-574` reads `fr/fb/terrain` only; skip `:565` ignores `fg`; sole writer `:574`; kernel writer `:242`; no `SetHeightData` inside any zero-density branch | `[O]` this pass (§3) |
| 5 | No new native edge this ticket (no native tool used); carried arities show no `ig/fdens → count` consumer | `[O]/[D]` carried (§4) |
| 6 | Port `fdens` decode + `forest_density` side-data-only comments (`terrain_donor_gen.gd:1476-1490,1513-1516`) | `[O]` port text (§2) |
| 7 | No value promoted; G0 stays `[U]` with §5 C-G0a/b/c zero-mismatch battery; no `G→count` formula invented | `[O]/[D]` scope + §5 |
| 8 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared | `[O]` scope guard |
| 9 | `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `chain = 0/6`, `blocking_unverified = [G0]` non-empty so `RESULT IS NOT GOOD` | `[O]` scope guard |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `chain = 0/6`; T-G0 selectors (fixed-seed `fdens==0` off-starts + height non-write liveness) remain `[U]`; static text half CLOSED (no zero-density branch writes height in searched text). **No invented density/height; no parity claim; RESULT IS NOT GOOD.**

*End of DEC_U_b6_g0_density. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED.*
