---
id: X28
wave: X (deterministic test-vector derivation)
ticket: "Shore/water tile-selection vectors for I08/I10/I12 assertions"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; private use; no donor binary executed, no donor file copied into repo)"
owner_file: docs/terrain_swarm_2026-11-26/reports/X28_shore_tile_vectors.md
vectors_written: "%LOCALAPPDATA%\\Temp\\opencode\\shore_vectors\\{vectors.csv,vectors.json,gen_vectors.py,combined_table.md,vectors_table.md,input_table.md,combined_table.py,input_table.py} — OUTSIDE the repo"
parity_claim: false
multi_pass: true
---

# X28 — Deterministic shore/water tile-selection test vectors

## 0. Executive summary

1. **[O] The donor rule is now pinned verbatim from `data/scripts/common.inc/texturemap.inc:426-611`, not reconstructed from summaries.** All prior reports cited this block, but two material details were only resolvable by reading the donor lines themselves: (a) the shore block's 8 windows are an `if/else` chain whose **final `else` (`:501`) is a catch-all with no upper bound**, and (b) the cliff block sits in the `else` of the shore block (`:556-557`) and therefore **does not execute `vecangle := vecangle+180` (`:476`)** — its 6 angle windows apply to the *pre-add* signed angle. Both change the expected tile at specific inputs (vectors 9, 17–22).
2. **[O] Encoded gate.** A tile is painted only if `VectorLength(dirX,dirY)>0.01` (`:441-442`) **and** `gMapMask[ix,iy].b>0` (`:464`) **and** `h<-0.25` (`bWater`, `:466-467`) **or** `-0.25≤h<-0.1` (`bWaterShore`, `:469-470`). The task's `h<-0.25 ∨ h<-0.1` is the correct *union*; the two branches are distinct classifications because of the `else` at `:468`. `[D]` Strict inequalities mean `h=-0.25` is `bWaterShore` and `h=-0.1` is dry (vectors 11, 13).
3. **[O] 35 deterministic vectors** (≥16 required) cover all 8 shore sectors, the `bRT` catch-all, both classification boundaries, the mask gate, all 6 cliff faces, all 3 cliff `|h|` overrides with their exact boundary cases, the `cDiff1/cDiff2` collision gates, and the winter suffix. Exact ids from F05's 124-id table: `sandsea1=93`, `sandsea5=97`, `sandsea6=98` (`F05 §3 :229/:233/:234`); cliff `rock1=17`, `rock3=19`, `rock4=20`, `rock7=23`, `rock8=24` (`F05 §3 :153/:155/:156/:159/:160`).
4. **[O] Three water levels are three separate fields and are NOT conflated:** basin `−1.1` (`generatemap.inc:7`), generated water field `−0.5` (`generatemap.inc:688,704`), tile classification `−0.25` (`texturemap.inc:30,466-467`) and shore band `−0.1` (`texturemap.inc:31,469-470`). See §3.5. No single threshold is used for two roles.
5. **[O]/[D] `bmTransparency` is a fixed-function framebuffer crossfade and the alpha mask is not an albedo multiplier** (X17 §3.2, D08 §3.5). These vectors select **tile ids only**; they assert nothing about colour, blend factors, alpha or pass count.
6. **No donor parity claim.** No donor binary was run, no donor file copied into the repo, no source/shader/config/asset/test/git state changed, no Godot job submitted. Exactly one repo file written (this one).

---

## 1. Evidence table

| Source (authoritative citation) | Earlier report / chain of custody | What it establishes |
|---|---|---|
| `data/scripts/common.inc/texturemap.inc:29-31` | F05 E08; D06 §3.1; X11 §7.1 | `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` — all `;`-commented GSC text. |
| `texturemap.inc:63-64`, `:88-129`, `:675-676`, `:700-735` | D06 §4 "cDiff1/cDiff2=0.5/0.55 (:63-64)" | `cDiff1=0.5`, `cDiff2=0.55`; used in `Abs(height-lh/rh/bh/th)>cDiff1` and `Abs(bh-rh)/Abs(height-rbh)>cDiff2` to paint `gc_collisiontag_terrain` — upstream collision gates, **not** tile-selection thresholds. |
| `texturemap.inc:426` | D06 §7.1 | `height = GetHeightData(realx,realy)` — the `h` used by the gate. |
| `texturemap.inc:433-437` | D06 §7.1 | Only **5** neighbour samples are read: `lh=W (:433)`, `rh=E (:434)`, `th=N (:435)`, `bh=S (:436)`, `rbh=SE (:437)`. NW/NE/SW are not sampled by this block. |
| `texturemap.inc:438-447` | D06 §7.1; X11 §6.1 | `dirX=lh-rh`, `dirY=th-bh`, `len=VectorLength(dirX,0,dirY)`; **gate `len>0.01` (`:442`)**; normalize (`:444`); `vecangle=VectorAngle(1,0,0,dirX,0,dirY)` (`:445`); negate if `dirY<0` (`:446-447`). |
| `texturemap.inc:463-472` | D06 §7.1; spec/05 §4; X11 §6.1 | Mask gate and the two exclusive height classifications. |
| `texturemap.inc:474-501` | D06 §7.1 (`:479-501`); X11 §10 #12 | `cAngle=45`; `vecangle+=180` at `:476`; eight windows at `:479-498`; **`:500-501` commented bound + bare `else bRT` catch-all**. |
| `texturemap.inc:503-511` | D06 §7.1; D08 §3.2 | `newtile` assignments: `bLB→sandsea5`, `bRB→sandsea6`, `bB→sandsea1`, `bL→sandsea6`, `bR→sandsea6`, `bT→sandsea1`, `bRT→sandsea5`, `bLT→sandsea6`; each an independent `if` in this file order. |
| `texturemap.inc:514-519` | D06 §4 | `|h|>2.7→rock8` / `>2.4→rock4` on the **shore** path are `{…}`-commented — inert. |
| `texturemap.inc:525-528` | D06 §7.1; X11 §6.1 | `GetSeasonType=2 → '_winter'`; `MapGetTileIndexByTileBlock(newtile)`; `SetTileIndex(x,y,newtex)`. |
| `texturemap.inc:556-557` | D06 §7.2; D08 §3.2 | Cliff path is the `else` of the shore block; trigger = map edge or `GetMapCollisionTagInRadius(realx,realy,0,False)>0`. |
| `texturemap.inc:560-575` | D06 §7.2; D08 §3.2; X11 §6.2 | Six asymmetric windows: `bRB [22.5,67.5]`, `bLB [120,170]`, `bR [-45,45]`, `bB [45,135]`, `bT [-135,-45]`, else `bL`; first-match-wins `else-if`. |
| `texturemap.inc:577-591` | D06 §7.2 | Face tiles: `bLB→rock7`, `bB→rock1`, `bL→rock3`, `bR→rock4`, `bT→rock4`, `bRB→rock4`; `rock6`/`rock2` alternatives commented (`:579,:582`). |
| `texturemap.inc:594-601` | D06 §7.2 | Live cliff overrides: `Abs(h)>2.7→rock8`, `>2.4→rock4`, `Abs(h)<0.1→no tile`; `:603-608` winter + `SetTileIndex`. |
| `reports/F05_tile_mapping.md §3 :229/:233/:234` | F05 E13/E15 | Summer ids `sandsea1=93`, `sandsea5=97`, `sandsea6=98`; atlas cells `(13,5)`, `(1,6)`, `(2,6)`. E15 cross-checks `world3d_terrain.gd:1357-1358,1592`. |
| `reports/F05_tile_mapping.md §3 :153/:155/:156/:159/:160` | F05 E01 | Cliff ids `rock1=17`, `rock3=19`, `rock4=20`, `rock7=23`, `rock8=24`; cells `(1,1)`, `(3,1)`, `(4,1)`, `(7,1)`, `(8,1)`. |
| `reports/F05_tile_mapping.md §4.1 :271-280` | F05 E12/E13 | Atlas cell rule `cell=(id%16, id//16)` (port packing, **PORT APPROXIMATION** as donor layout; id space itself donor-faithful). |
| `generatemap.inc:7` / `:688,704` | D06 §3.1; spec/05 §1; X11 §7.1 | Basin `−1.1`; generated field Y `−0.5` (GSC-commented ⇒ runtime `[U]`). |
| `cossacks.exe` VA `0x4ef991`/`0x88fbb0`/`0x88fbb7`, factor table `0x8fb1c4/0x8fb1c8` | D08 §3.5; X17 §3.1-3.2 | `bmTransparency` = `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`; mask is a framebuffer crossfade weight, never an albedo multiply. |
| `hf.pvl.smx3.frag:13-14,50` | X17 §3.2 | `color.rgb=texUnit0.rgb`, `color.a=texUnit1.a`, no mask→RGB math. |

---

## 2. Method and multi-pass ledger

**Authority:** donor read-only with `open(...,'rb')`/text reads; no Craft Anything target was opened or changed, no donor binary executed. Vector arithmetic was performed in a Python helper **outside the repo** (`%LOCALAPPDATA%\Temp\opencode\shore_vectors\gen_vectors.py`) that re-implements `texturemap.inc:426-611` statement-for-statement, including the else-chain order and the unguarded final `else`. Outputs `vectors.csv`, `vectors.json`, `combined_table.md` stay in that temp directory.

**Owner directive — multiple passes on contradictory thresholds.** Each discrepancy between prior reports and the donor text was attacked from independent angles before an expected value was accepted:

| # | Lead / apparent contradiction | Pass 1 | Pass 2 | Pass 3+ | Verdict |
|---|---|---|---|---|---|
| M1 | 8-sector rule: D06 §7.1 says `sector=floor((vecangle+22.5)/45)`; X11 §6.1 writes `int(...)%8`; X11 §10 #12 flags the integer mapping as `[U]` | Read D06/X11 pseudocode | Read verbatim `texturemap.inc:479-501` | Generate a vector at post angle `350°` (vector 9) and run both implementations | **[O] Donor if/else windows accepted.** `:500-501` has the `vecangle>=337.5` bound **commented out**; the final `else bRT` is a catch-all. `floor()%8` gives sector 0 (`bR`→`sandsea6`) at 350°, donor gives `bRT`→`sandsea5`. X11 `modulo` form is `[D]/PORT APPROXIMATION` outside `[−22.5,337.5)`. |
| M2 | Cliff angle basis: D08 §3.2 lists cliff windows `30–60 RB`, `120–150+20 LB`, `±45 R`, `45–135 B`, `−135..−45 T` alongside the shore rule, implying one angle variable | Compare D06 §7.1 vs D08 §3.2 prose | Read verbatim `:472` (`if bWater or bWaterShore … begin`) and `:476` (`vecangle+=180` inside that block) | Read `:556-557`: cliff is in the `else`, so `:476` never runs; read `:560-575` windows and test pre angles 45/135/0/90/−90/180 | **[O] Two angle bases accepted**: shore uses `post=pre+180`, cliff uses `pre`. Vector 17–22 encode this; using post for cliff would give wrong rock ids. |
| M3 | `|h|>2.7→rock8`, `>2.4→rock4` appear in both paths in D06 §4/§7.2 | Read D06 prose | Read `:514-519` — enclosed in `{…}`, commented | Read `:594-601` — live, cliff only | **[O] Overrides accepted on cliff path only.** Shore vectors with `h=-1.0` keep `sandsea*`; cliff vectors 23–31 exercise the overrides. |
| M4 | Gate description `mask.b>0 ∧ (h<-0.25 ∨ h<-0.1)` could be read as two independent low-height tests | Read task/D06 phrasing | Read `:466-470`: `if h<-cWaterHeight … else if h<-cWaterShoreHeight` | Evaluate `h=-0.25` and `h=-0.1` exactly (vectors 11, 13) | **[O] Union accepted, with an `else`.** `bWater` = `h<-0.25`; `bWaterShore` = `−0.25≤h<-0.1`; union is `h<-0.1`; strict `<` at both bounds. |
| M5 | `cDiff1/cDiff2=0.5/0.55` listed with the cliff table by D06 §4 | Read D06 §4 | `grep cDiff` over donor `texturemap.inc` → `:63-64,88-129,675-676,700-735` | Read `:88-129`: gates painting `gc_collisiontag_terrain`; read `:557`: cliff trigger consumes collision tags | **[O] Accepted as upstream collision gates, not tile thresholds.** Vectors 32–34 test `>0.5` / `>0.55` strictness and the resulting cliff context. |
| M6 | 8 neighbour heights requested vs donor's apparent 5 reads | Read task requirement | Read `:433-437`: W,E,N,S,SE only | Include all 8 in every vector; mark NW/NE/SW unused | **[O] 8-neighbour tensor accepted as input shape**; only 5 are consumed. No synthetic neighbour values were invented for unused slots (all 0). |
| M7 | Slope gate `len>0.01` mentioned by D06 §7.1 at `:432` (off by ten lines) | Read D06 | Read `:441-442` verbatim | Confirm the whole gate/sector/cliff block is nested inside `if len>0.01 … end` at `:443/:612` | **[O] Precondition accepted for both paths.** All 35 vectors use `len≥0.49`, so all pass it; a flat-cell vector would produce no tile. |
| M8 | Water levels: `−1.1`, `−0.5`, `−0.25`, `−0.1` repeatedly called "water height" in prior reports | Read spec/05 §1 | Read `generatemap.inc:7,688,704` and `texturemap.inc:30-31` via D06/X11 evidence | Separate table §3.5 with distinct roles | **[O] Four distinct fields accepted; no conflation.** |

Nothing was silently skipped; every final reading is tagged `[O]` from donor bytes/lines or `[D]` arithmetic over those lines.

---

## 3. Encoded rules (exact)

### 3.1 Preconditions `[O]`

```
len  = VectorLength(lh-rh, 0, th-bh)        // texturemap.inc:438-441
if len <= 0.01: NO TILE                      // :442 -- wraps the entire block to :612
vec_pre  = VectorAngle(1,0,0, dirX,0,dirY); if dirY<0: vec_pre = -vec_pre   // :445-447
```

`[D]` For the normalized 2-D gradient used by the vectors below, `vec_pre = atan2(dirY,dirX)` in degrees.

### 3.2 Gate `[O]`

```
bWater      = (gMapMask[ix,iy].b > 0) and (h < -0.25)                  // :464,466-467
bWaterShore = (gMapMask[ix,iy].b > 0) and not bWater and (h < -0.1)    // :464,468-470
if bWater or bWaterShore: -> SHORE PATH                                // :472
else if edge or collision_tag>0: -> CLIFF PATH                         // :556-557
else: NO TILE
```

The task's disjunction is the correct union; the `else` at `:468` is what keeps the two classifications distinct.

### 3.3 Shore: 8×45° sector table `[O]`

`vec_post = vec_pre + 180` (`:476`); windows on `vec_post`, first match wins (`:479-501`):

| Sector | Window on `vec_post` | Donor line | Tile (Summer name) | F05 id | Atlas cell |
|---|---|---|---|---:|---|
| `bR` | `[−22.5, 22.5)` | `:479-480` | `sandsea6` | 98 | (2,6) |
| `bRB` | `[22.5, 67.5)` | `:482-483` | `sandsea6` | 98 | (2,6) |
| `bB` | `[67.5, 112.5)` | `:485-486` | `sandsea1` | 93 | (13,5) |
| `bLB` | `[112.5, 157.5)` | `:488-489` | `sandsea5` | 97 | (1,6) |
| `bL` | `[157.5, 202.5)` | `:491-492` | `sandsea6` | 98 | (2,6) |
| `bLT` | `[202.5, 247.5)` | `:494-495` | `sandsea6` | 98 | (2,6) |
| `bT` | `[247.5, 292.5)` | `:497-498` | `sandsea1` | 93 | (13,5) |
| `bRT` | **catch-all `else`** (nominal `[292.5,337.5)`, but `:500` bound is commented) | `:500-501` | `sandsea5` | 97 | (1,6) |

`GetSeasonType=2` appends `_winter` (`:525-526`); winter keeps the same numeric id (F05 F05/F06). `[D]` Exactly three live shore textures: `sandsea1/5/6`; `sandsea2/3/4` survive only in smoothing lists (D06 §4.3).

### 3.4 Cliff: separate 6-branch table `[O]`

Windows apply to **`vec_pre`** (no `+180` — cliff is in the `else`), first match wins (`:560-575`):

| Face | Window on `vec_pre` | Line | Tile | F05 id | Cell |
|---|---|---|---|---:|---|
| `bRB` | `[22.5, 67.5]` | `:560-561` | `rock4` | 20 | (4,1) |
| `bLB` | `[120, 170]` | `:563-564` | `rock7` | 23 | (7,1) |
| `bR` | `[−45, 45]` | `:566-567` | `rock4` | 20 | (4,1) |
| `bB` | `[45, 135]` | `:569-570` | `rock1` | 17 | (1,1) |
| `bT` | `[−135, −45]` | `:572-573` | `rock4` | 20 | (4,1) |
| `bL` | `else` | `:575` | `rock3` | 19 | (3,1) |

Overlaps are resolved by the if/else order: `vec_pre=45` matches `bRB` first (vector 17), `vec_pre=135` matches `bLB` before `bB` (vector 18). `[O]` Live height overrides after face choice (`:594-601`): `Abs(h)>2.7→rock8 (24)`, else `>2.4→rock4 (20)`, else `Abs(h)<0.1→no tile`. `[O]` `cDiff1=0.5`/`cDiff2=0.55` (`:63-64`) gate `gc_collisiontag_terrain` painting at `:88-129`, which feeds the `GetMapCollisionTagInRadius(...)>0` cliff trigger at `:557`.

### 3.5 Three distinct water levels — separate fields, no conflation `[O]`

| Field name | Value | Donor source | Role | Never used as |
|---|---:|---|---|---|
| `BASIN_HEIGHT` | `−1.1` | `generatemap.inc:7` | generation basin depth | tile gate / plane Y |
| `WATER_FIELD_Y` | `−0.5` | `generatemap.inc:688,704` | Y passed to `WaterFieldAdd` per 2×2 field (text `[O]`, runtime `[U]`) | tile gate |
| `TILE_WATER_HEIGHT` | `−0.25` | `texturemap.inc:30,466-467` | `bWater` classification | plane Y / basin |
| `TILE_SHORE_HEIGHT` | `−0.1` | `texturemap.inc:31,469-470` | `bWaterShore` band (width `[D]` 0.15) | plane Y / basin |

**Assertion:** no single threshold is conflated across these roles; `−0.25/−0.1` are classification literals only, `−0.5` is a field-placement Y, `−1.1` is a basin depth. The shader plane `gl_TexCoord[1].z` (`water.dev.vert:18`) is a fifth, `[U]`, engine-supplied value; the `1.5 /*0.94*/` debug Y (`water.frag:182`) is inactive.

### 3.6 `bmTransparency` boundary (X17) `[O]/[D]`

`bmTransparency` is fixed-function `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)` with default `GL_FUNC_ADD` (`cossacks.exe` VA `0x4ef991`/`0x88fbb0`/`0x88fbb7`, table `0x8fb1c4/0x8fb1c8`; D08 §3.5, X17 §3.2). The donor fragment sets `color.a` from `texUnit1` and never multiplies alpha into RGB (`hf.pvl.smx3.frag:13-14,50`). **The alpha mask must not be multiplied into albedo**; the port's `rgb *= mask` is **PORT APPROXIMATION**. These vectors are **tile-selection only** — they assert tile name, numeric id and atlas cell; they assert no colour, alpha, blend factor or pass count.

---

## 4. Vector table

`ctx` = `E` map edge, `C` collision tag `>0` at `:557`, `-` none. `class` is the height-band label from `:466-470`; the booleans are only assigned when `mask.b>0` (`:464`), so vectors 15 and 24 are labelled `bWater` by height but take the cliff/no-tile path because `mask.b=0`. `pre`/`post` are degrees. `(NW,N,NE,W,E,SW,S,SE)` heights; donor consumes only N, W, E, S, SE (NW/NE/SW are 0 and unused). Generator and machine-readable forms: `%LOCALAPPDATA%\Temp\opencode\shore_vectors\vectors.csv` / `vectors.json`.

| # | mask.b | h | (NW,N,NE,W,E,SW,S,SE) | ctx | class | pre | post | sector/face | expected tile | id | atlas |
|---:|---:|---:|---|---|---|---:|---:|---|---|---:|---|
| 1 | 1.0 | -1.0 | (0.0,-0.34202,0.0,-0.939693,0.0,0.0,0.0,0.0) | - | bWater | -160.0 | 20.0 | bR | sandsea6 | 98 | (2,6) |
| 2 | 1.0 | -1.0 | (0.0,-0.707107,0.0,-0.707107,0.0,0.0,0.0,0.0) | - | bWater | -135.0 | 45.0 | bRB | sandsea6 | 98 | (2,6) |
| 3 | 1.0 | -1.0 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWater | -90.0 | 90.0 | bB | sandsea1 | 93 | (13,5) |
| 4 | 1.0 | -1.0 | (0.0,-0.707107,0.0,0.707107,0.0,0.0,0.0,0.0) | - | bWater | -45.0 | 135.0 | bLB | sandsea5 | 97 | (1,6) |
| 5 | 1.0 | -1.0 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | - | bWater | 0.0 | 180.0 | bL | sandsea6 | 98 | (2,6) |
| 6 | 1.0 | -1.0 | (0.0,0.707107,0.0,0.707107,0.0,0.0,0.0,0.0) | - | bWater | 45.0 | 225.0 | bLT | sandsea6 | 98 | (2,6) |
| 7 | 1.0 | -1.0 | (0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWater | 90.0 | 270.0 | bT | sandsea1 | 93 | (13,5) |
| 8 | 1.0 | -1.0 | (0.0,0.707107,0.0,-0.707107,0.0,0.0,0.0,0.0) | - | bWater | 135.0 | 315.0 | bRT | sandsea5 | 97 | (1,6) |
| 9 | 1.0 | -1.0 | (0.0,0.173648,0.0,-0.984808,0.0,0.0,0.0,0.0) | - | bWater | 170.0 | 350.0 | bRT | sandsea5 | 97 | (1,6) |
| 10 | 1.0 | -0.2501 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWater | -90.0 | 90.0 | bB | sandsea1 | 93 | (13,5) |
| 11 | 1.0 | -0.25 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWaterShore | -90.0 | 90.0 | bB | sandsea1 | 93 | (13,5) |
| 12 | 1.0 | -0.15 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWaterShore | -90.0 | 90.0 | bB | sandsea1 | 93 | (13,5) |
| 13 | 1.0 | -0.1 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | dry | -90.0 | 90.0 | - | (none) | - | - |
| 14 | 1.0 | -0.0999 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | dry | -90.0 | 90.0 | - | (none) | - | - |
| 15 | 0.0 | -1.0 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWater | -90.0 | 90.0 | - | (none) | - | - |
| 16 | 0.0001 | -1.0 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWater | -90.0 | 90.0 | bB | sandsea1 | 93 | (13,5) |
| 17 | 0.0 | 1.0 | (0.0,0.707107,0.0,0.707107,0.0,0.0,0.0,0.0) | E | dry | 45.0 | 225.0 | bRB | rock4 | 20 | (4,1) |
| 18 | 0.0 | 1.0 | (0.0,0.707107,0.0,-0.707107,0.0,0.0,0.0,0.0) | E | dry | 135.0 | 315.0 | bLB | rock7 | 23 | (7,1) |
| 19 | 0.0 | 1.0 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 20 | 0.0 | 1.0 | (0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0) | E | dry | 90.0 | 270.0 | bB | rock1 | 17 | (1,1) |
| 21 | 0.0 | 1.0 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | E | dry | -90.0 | 90.0 | bT | rock4 | 20 | (4,1) |
| 22 | 0.0 | 1.0 | (0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0) | E | dry | 180.0 | 360.0 | bL | rock3 | 19 | (3,1) |
| 23 | 0.0 | 2.7001 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock8 | 24 | (8,1) |
| 24 | 0.0 | -2.8 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | bWater | 0.0 | 180.0 | bR | rock8 | 24 | (8,1) |
| 25 | 0.0 | 2.7 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 26 | 0.0 | 2.4 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 27 | 0.0 | 2.4001 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 28 | 0.0 | 0.05 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | (none) | - | - |
| 29 | 0.0 | -0.05 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | (none) | - | - |
| 30 | 0.0 | 0.1 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 31 | 0.0 | -0.1 | (0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0) | E | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 32 | 0.0 | 1.0 | (0.0,1.0,0.0,0.49,0.0,0.0,1.0,1.0) | C | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 33 | 0.0 | 1.0 | (0.0,1.0,0.0,0.5,0.0,0.0,1.0,1.0) | - | dry | 0.0 | 180.0 | - | (none) | - | - |
| 34 | 0.0 | 1.0 | (0.0,0.43,0.0,1.49,0.99,0.0,0.43,0.43) | C | dry | 0.0 | 180.0 | bR | rock4 | 20 | (4,1) |
| 35 | 1.0 | -1.0 | (0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0) | - | bWater | -90.0 | 90.0 | bB | sandsea1_winter | 93 | (13,5) |

**Coverage audit `[D]`:** sectors `bR,bRB,bB,bLB,bL,bLT,bT,bRT` = vectors 1–8; catch-all boundary = 9; `h=-0.25/-0.1` exact boundaries = 11/13; mask gate = 15/16; cliff faces `bRB,bLB,bR,bB,bT,bL` = 17–22; cliff overrides `>2.7,>2.4,<0.1` with exact bounds = 23–31; `cDiff1/cDiff2` = 32–34; winter = 35. Total **35 ≥ 16**.

---

## 5. Implications for I08 / I10 / I12

No I08/I10/I12 report had landed and their exact tickets were not on the swarm board I read; the scoping below is **[I]** from the task's naming and should be corrected by COORD if their ownership differs.

1. **I08 (tile-selection owner) — assert against the vector table, not a sector formula.** Implement the shore rule as the literal if/else windows of `texturemap.inc:479-501` with the unguarded `else bRT`; vector 9 is the regression that catches a `floor()%8` shortcut. Implement cliff as the `else` branch with **pre-angle** windows (`:560-575`) and the live `|h|` overrides (`:594-601`); do not apply `+180` there. Enforce `len>0.01` (`:442`) before either path. Keep the three shore ids `93/97/98` and cliff ids `17/19/20/23/24` from F05; do not invent a water tile id (F05 §3; spec/06 §3).
2. **I08 — smoothing is a later, separate stage.** `sandsea5=0.7`, `sandsea6=0.3`, `rock9/8/5=0` (`tilesmooth_scripts.cfg:5-36`, D06 §4.3) apply *after* `SetTileIndex`; the vectors assert the pre-smoothing selection only. Do not let a smoothing pass rewrite a vector expectation. `TileSmoothPasses=6` vs script `3` stays `[U]` (SWARM_BOARD C2).
3. **I10 (tile shader owner) — no colour assertion from these vectors.** Per X17 §3.2/§4 and D08 §3.5, keep the mask out of albedo: base opaque layer + `blend_mix` overlay with raw mask alpha, no `rgb*a`, no `0.35` floor, no `step` guard. Pass count is `[U] CONFIRMED_UNVERIFIED` after six X17 passes; any two-layer Godot shape remains **PORT APPROXIMATION**. Do not treat `sandsea1/5/6` ids as carrying any particular RGB.
4. **I10 — face ids are distinct but reuse base pixels in the port.** Vectors 17–22 select `rock1/3/4/7` (ids 17/19/20/23), not `vf/vs` ids 53–70; promotion to face tiles is `[U]` (F05 §9 #2, D08 §7 #8) and the port's 36 `FACE_BASE_REUSE` cells are **PORT APPROXIMATION**. Do not fold that into a vector expectation.
5. **I12 (integration owner) — keep the level fields separate at the seam.** Wire the four §3.5 fields as four distinct parameters; never pass `−0.25` as a water-plane Y or `−0.5` as a classification gate (spec/05 §1, X11 §8). `water3d.gd:36` uses `−0.25` only as a labelled placeholder for the `[U]` plane; that is not donor truth.
6. **I12 — QA histogram.** F05 E15 notes the shipped dump samples only ids 0–85; add a gate that forces coverage of shore 93/97/98 and cliff 17/19/20/23/24 before any shore/cliff visual verdict (F05 §7 #5).
7. **All — no parity claim.** These vectors validate *structural tile selection* against commented GSC text. Runtime execution of `texturemap.inc` is `[U]` (F05 F07, D06 §10.1); no donor GPU A/B frame exists.

---

## 6. UNVERIFIED register (do not promote)

1. **[U] Runtime activity of the whole `texturemap.inc` block** — every cited line is `;`-commented; text is authoritative intent, execution was not observed (read-only rule). Passes: verbatim donor read, F05 F07, D06 §10.1.
2. **[U] `VectorAngle` exact return convention** — `[D]` the vectors use `pre=atan2(dirY,dirX)` from `VectorAngle(1,0,0,...)` + the `dirY<0` negation at `:446-447`; the engine function itself was not decompiled. The four cardinal vectors (5,7,19,21) are insensitive to the convention; the diagonal vectors assume standard `atan2`.
3. **[U] Exact numeric runtime `gl_TexCoord[1].z` plane Y** and the `−0.5` field-Y runtime execution (D06 §11 #3, X11 §10 #11). Four separate fields retained in §3.5.
4. **[U] `bmTransparency` layer/pass count and draw order** — X17 six passes, CONFIRMED_UNVERIFIED. Vectors assert nothing about it.
5. **[U] Face-promotion rule (base id → `vf/vs` 53–70) and `AngleX/AngleZ=25` application** (F05 §9 #2). Vectors stop at base ids.
6. **[U] `tsDouble`/`ttExtended`/`AlphaRows=8`/`AlphaCols=4` arithmetic and donor atlas packing** — the atlas cell `(id%16,id//16)` in the vector table is the port grid and is **PORT APPROXIMATION** as donor layout (F05 G4, D08 §3.1).
7. **[U] `MapGetTileIndexByTileBlock` / `SetTileIndex` 0-based indexing proof** (D08 §7 #2) — ids taken from F05 preset order; no binary consumer recovered.
8. **[U] Visual parity of any port shore/cliff frame** — no donor A/B capture; explicitly not claimed.

---

## 7. Open questions

1. Can a Deep session recover the compiled consumer of `texturemap.inc` selection (or prove none exists), so the `[U]` runtime label can be resolved?
2. Should COORD add vector 9 (`post=350°`) as a named regression in A05's QA harness, given it distinguishes the verbatim catch-all from X11's `modulo-8` pseudocode?
3. Do the I08/I10/I12 tickets match the scoping in §5, or should the implications be reassigned?
4. If `VectorAngle` is found to return unsigned `[0,180]` only (with negation at `:446-447` giving `[−180,180]`), do the diagonal sector vectors need angle-sign reversal? Cardinal vectors 3/5/7/19/21/22 are unaffected.
5. Does the collision-tag path (`:88-129` / `:700-735`) run before texture selection in the shipped generator, so vectors 32/34's `collision` context is actually available at `:557`? Stage order is `[O]` from `generatemap.inc:770-798` but runtime execution is `[U]`.
6. Should a flat-gradient vector (`len≤0.01`, all neighbours = centre h) be added as vector 36 to assert the `:442` no-tile precondition explicitly?

---

## 8. Bottom line

35 deterministic vectors were derived from the verbatim donor selection block `texturemap.inc:426-611` and F05's 124-id table, covering all 8 shore sectors, the unguarded `bRT` catch-all, the `−0.25`/`−0.1` classification boundaries, the mask and slope gates, all 6 cliff faces, all 3 cliff height overrides with exact boundaries, the `cDiff1/cDiff2` collision gates, and the winter suffix. Three distinct water levels are carried as separate fields with no conflation. The alpha mask is a framebuffer crossfade weight, not an albedo multiplier; the vectors select tile ids only. Every contradictory reading was multi-passed (M1–M8) with accept/reject reasons; unresolved items are `[U]`. **No donor parity claim.** One repo file written; vectors live only in `%LOCALAPPDATA%\Temp\opencode\shore_vectors\`.

*End of X28 report.*
