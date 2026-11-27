---
id: DEC-U-RES-POINT
worker: DEC-U-RES-POINT (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (size + sha256 re-verified read-only this ticket; binary never executed/copied)"
scope: "READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edit: this report is the only file written."
labels: "[O] verbatim donor bytes/text lines read this ticket · [D] deterministic reading of [O] · [I] inference, flagged · [U] UNVERIFIED with settling experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
upstream: "DEC_U_market_tail.md (§3 D1-D3, §5.3, [U]-E1) + DEC_U_carry.md (capacity/credit law, U-FISH/U-PART) + DEC_U_skirmish.md + DEC_U_skirmish_impl_patch.md"
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker; no port capture compared."
network: "OUT OF SCOPE. No multiplayer/netcode law is wired or changed."
---

# DEC-U-RES-POINT — per-building `resourcePoint` offsets + `GetPortResourcePoint` water-ring fallback (2026-11-26)

## 0. Pass ledger (owner rule; every anchor pinned `document:"t_87f0f3c130b0"`)

Donor root read-only: `C:\Games\Cossacks 3\`. Port read-only: `variant3d/scripts/game.gd`, `variant3d/scripts/data.gd`. No donor binary executed (only a read-only size+SHA256 stat); no bytes copied into the repo.

| # | Pass | Result |
|---|---|---|
| P1 | donor-text read `misc.script:4495-4560` + `:4560-4640` | `[O]` full `_misc_GetPortResourcePoint` (`:4506-4636`): bui-child arm `:4509-4518`, water-ring fallback `:4520-4634` (precise `tries=72/minDist 3`, fast `tries=16/minDist 9`, `maxDist 11`, `cCollisionRad 1`, innermost-water scan, `×1.1` cardinal-ish penalty, winner-pick, `angle=minIndex*5`, `7.5` floor) — `ev_9f2c41aa7d0e4b1c8c3f77d1022be881` |
| P2 | donor-text read `unit.script:9580-9690,9690-9715,9750-9770,10705-10735,11860-11935,12000-12080,4425-4450,5615-5640` | `[O]` all 5 `resourcePoint` consumption sites + all 7 `GetPortResourcePoint` call sites; zero rotation terms — `ev_41d0b6e88caa42f5a1e09c3d4f77a102` |
| P3 | donor-text read `country.script:4080-4132,4130-4200` + `classes.script:4255-4290` + `dmscript.global:200-225` | `[O]` parse path (`objcustom.cfg` → `gCustomObjPoints[cid][id].resourcePoint`, `y:=0` forced `:4168`), `TCustomObjPoints.resourcePoint : TPos3f` (`classes.script:4272`), global radii `3`/`Sqr 9` (`:210`,`:220`) — `ev_77c3e50fb91d4a0d9a6b2c1d5e88c03` |
| P4 | donor-text read `data\game\var\objcustom.cfg` whole file (51586 lines), two sweeps | `[O]` all 27 `ResourcePoint` blocks with per-sid `(x,z)` + line numbers, §1 table — `ev_2b6e10c4f5a441d3b8d77a0e9c41d55` |
| P5 | port read-only `game.gd:7580-7800,3090-3121,3910-3994` + `data.gd:350-365,2500-2535,3050-3130` + greps | `[O]` port current shape: `_store_drop_point` (`:7620-7626`) / `_port_resource_point` (`:7633-7639`) read `resource_point` keys that NO writer populates (always `Vector2.ZERO` → centre fallback); radii constants already donor-exact (`:7586-7597`); generic sids `sto/mil/cen/dock` with prop-file cites (`data.gd:3053-3068`) — `ev_55aa09d2c7f04e1fa22b88e3d60f1c4` |
| P6 | negative grep `lib\*.script` for `Rotate…resourcePoint\|resourcePoint…Rotate\|Direction…torehouse` | **negative** — zero rotation/counter-rotation terms adjacent to any `resourcePoint` use — `ev_0d31f4b6a2c94e9f8b7d55c0a13e77b1` |
| P7 | cited prior passes (not re-run) | market-tail D1–D3 literals + delivery golden paths; carry capacity/credit law; `progresstick:=floor(RandomExt*32)` (`unit.script:2707`) |
| P8 | pin stat | `cossacks.exe` Length `5768048` + SHA256 `87F0F3C1…AF4E16C` match the pinned identity — `ev_pin_87f0f3c130b0` |

"Address" in this report = `path:line` (scripts/cfg are text; no binary addresses are read or cited).

## 1. [O] Per-building `resourcePoint` offsets — RECOVERED, complete (27/27 blocks)

**Parse law `[O]`** (`country.script:4111-4170`): `_country_InitObjCustom` loads `gc_filepath_objcustom` (`dmscript.global:1355` → `.\data\game\var\objcustom.cfg`), matches each block's `sid` against `gCountry[cid].members[id]` (`:4120-4128`), and stores `resourcePoint.x/z` verbatim (`:4167`,`:4169`) with **`y forced to 0`** (`:4168`, donor comment disables the file `y`). Container type `TCustomObjPoints.resourcePoint : TPos3f` (`classes.script:4272`). Runtime key is `(cid,id)` — i.e. per nation-member slot, resolved by sid match at load. No other writer exists except the `_unit_SetResourcePoint` setter (`unit.script:10714-10719`), which has **zero callers in the read corpus** (grep P2: only the definition hit) — file values stand.

**Complete table `[O]`** (`data\game\var\objcustom.cfg`; `y = 0` for all rows by `:4168`):

| sid (donor nation building) | x | z | block `objcustom.cfg:line` |
|---|---|---|---|
| `swecen` | 0.02 | -3.68 | :1452 |
| `prucen` | -0.06 | -3.07 | :3714 |
| `polcen` | -0.06 | -2.63 | :5274 |
| `turcen` | 0.49 | -3.41 | :7597 |
| `algcen` | 0.80 | -3.20 | :7744 |
| `spacen` | 0.10 | -3.35 | :9020 |
| `eurmil` | -0.02 | -1.61 | :10952 |
| `ukrcen` | -1.30 | -3.16 | :12330 |
| `ruscen` | -0.28 | -3.22 | :14011 |
| `auscen` | -0.11 | -3.34 | :15051 |
| `engcen` | -0.50 | -3.67 | :16801 |
| `fracen` | 0.01 | -3.12 | :18652 |
| `vencen` | 0.07 | -3.86 | :20826 |
| `eursto` | 0.20 | -1.69 | :21428 |
| `russto` | 0.19 | -1.50 | :21591 |
| `tursto` | 0.17 | -1.67 | :21766 |
| `rusmil` | 0.04 | -1.09 | :21879 |
| `turmil` | -0.44 | -2.56 | :22078 |
| `dencen` | -0.10 | -2.20 | :29341 |
| `netcen` | 0.43 | -2.23 | :32119 |
| `bavcen` | -1.45 | -3.07 | :34233 |
| `saxcen` | 0.24 | -3.25 | :35963 |
| `scocen` | 0.00 | -0.72 | :38373 |
| `porcen` | 0.30 | -3.17 | :41015 |
| `huncen` | 1.39 | -2.25 | :44398 |
| `piecen` | -0.25 | -2.42 | :47168 |
| `swicen` | -1.82 | -2.51 | :50098 |

**`[D]` consequences (load-bearing):**

1. All 27 offsets are **negative-z dominant** (building-local "front" toward −z; magnitudes 0.72–3.86 m). Centres (`*cen`, 21 rows) sit 2.2–3.9 m out; storehouses (`*sto`, 3 rows) 1.5–1.7 m; mills (`*mil`, 3 rows) 1.1–2.6 m. No port/dock/shipyard sid carries a block — ports never use this path (they use §2).
2. Consumption is **unrotated addition, 5/5 sites**: nearest-storehouse select (`unit.script:9591`), return STP set ×2 (`:9626`,`:9642`), drop test (`:9702`), re-path point (`:9756-9757`). Negative grep P6 confirms no `VectorRotateY`/direction term touches any of them. Exact replication = `drop_point = storehouse.pos + (x, z)` as-is. Any port facing/rotation of the vector invents law (stays `[U]-E1-R`, §4).
3. Acceptance gates using the corrected point: storehouse must satisfy `resourcebase[restype]` + `bbuilt` (`:9589`), return path restricted to `usage ∈ {storage, mill, center}` (`:9619`); collision-tag sanity `ErrorLog` on the corrected point (`:9624-9625`) — log-only, no law change.
4. Port generic-sid wiring is grounded, not invented: port `data.gd` cites its own donor prop files — `"sto"` → `eursto.prop` (`data.gd:3059`), `"mil"` → `eurmil.prop` (`:3053`), `"cen"` → `algcen.prop` (`:3068`). Therefore the exact port rows are `sto=(0.20,-1.69)`, `mil=(-0.02,-1.61)`, `cen=(0.80,-3.20)`. Any other nation-sid row is out of scope until the port gains nation-specific buildings.

## 2. [O] `GetPortResourcePoint` (`misc.script:4506-4636`) — full fallback law recovered

```pascal
function _misc_GetPortResourcePoint(const goHnd: Integer; var x, z: Float; bPrecise: Boolean): Boolean;  // :4506
begin
   Result := False;                                                                                     // :4508
   // ARM 1 — built bui-child absolute position (:4509-4518)
   var bui: Integer = GetGameObjectGOHandleChildByBaseName(goHnd, gc_racename_misc, gc_basename_bui);    // :4509
   if (bui<>0) then                                                                                     // :4510
   begin
      var pobj: Pointer = _misc_GetObjectArgData(goHnd, gc_argunit_obj);                                // :4512
      if (pobj<>nil) and (TObj(pobj).bbuilt) then                                                        // :4513
      begin
         var y: Float;
         GetGameObjectAbsolutePositionByHandle(bui, x, y, z);                                           // :4516
         Result := True;                                                                                // :4517
      end;
   end;
   // ARM 2 — water-ring search fallback (:4520-4634)
   if (not Result) then                                                                                 // :4520
   begin
      Result := False;                                                                                  // :4521
      var portX: Float = GetGameObjectPositionXByHandle(goHnd);                                         // :4523
      var portZ: Float = GetGameObjectPositionZByHandle(goHnd);                                         // :4524
      var minDistance: Float = gc_MaxFloat;                                                             // :4525
      var minIndex: Integer = -1;                                                                       // :4526
      var minDist: Float = 9;                                                                           // :4527
      var maxDist: Float = 11;                                                                          // :4528
      var i, j, tries: Integer;
      if (bPrecise) then                                                                                // :4530
      begin
         minDist := minDist-6;         // → 3                                                          // :4532
         const cPresiseCalc = 72;      // (donor spelling)                                             // :4533
         tries := cPresiseCalc;                                                                         // :4534
         ...scan body A...                                                                              // :4535-4575
      end
      else
      begin
         const cFastCalc = 16;                                                                          // :4579
         tries := cFastCalc;                                                                            // :4580
         ...scan body B (identical shape, minDist stays 9)...                                           // :4581-4621
      end;
      if (minIndex>=0) then                                                                             // :4623
      begin
         var angle: Float = minIndex*5;             // NOTE: hardcoded *5 = 360/72 in BOTH arms          // :4625
         if (minDistance<7.5) then minDistance := 7.5;                                                  // :4626-4627
         var dirX: Float = minDistance;                                                                 // :4628
         var dirY, dirZ: Float;
         VectorRotateY(dirX, dirY, dirZ, angle);                                                         // :4630
         x := portX+dirX;                                                                               // :4631
         z := portZ+dirZ;                                                                               // :4632
         Result := True;                                                                                // :4633
      end;
   end;                                                                                                 // :4636 (end)
end;
```

Scan-body law (both arms, `[O]` `:4538-4567` / `:4582-4613`): for each `i`, `angle = i*(360/tries)` (precise step 5°, fast step 22.5°); probe `(portX+dirX, portZ+dirZ)` at `maxDist=11` with `cCollisionRad=1` via `GetMapCollisionTagInRadius(...,True)`; only if that probe is `gc_collisiontag_water`, scan `j` from `floor(minDist)` to `floor(maxDist)-1` (precise `3..10`, fast `9..10`) along the same ray and keep the **innermost** (`break` at first) water cell: `fDistance[i] := j`, with a `×1.1` penalty under a `case i of` range guard (`:4556-4561` / `:4602-4607`, quoted verbatim below); winner = smallest `fDistance[i] > 0` (`:4568-4575` / `:4614-4621`). If `minIndex = -1`, `Result` stays `False` and `x/z` are untouched.

Penalty guard verbatim (`:4556-4561`, precise arm; fast arm identical at `:4602-4607`):

```pascal
case i of
   84/angle..96/angle : fDistance[i] := fDistance[i]*1.1;
   174/angle..186/angle : fDistance[i] := fDistance[i]*1.1;
   264/angle..276/angle : fDistance[i] := fDistance[i]*1.1;
   354/angle..366/angle : fDistance[i] := fDistance[i]*1.1;
   0/angle..6/angle : fDistance[i] := fDistance[i]*1.1;
end;
```

**`[D]` evaluated match sets** (real-division + range-containment reading of the verbatim text; `angle = i·360/tries`):

- Precise (`tries=72`, `angle=5i`): guard `a/angle..b/angle ∋ i ⟺ a ≤ (360/72)·i² ≤ b`. Fires at **`i=1` (5°)** via the `0..6` guard and **`i=6` (30°)** via the `174..186` guard ($5·36=180 \in [174,186]$). The `84..96`, `264..276`, `354..366` guards match **no** integer `i` (dead guards — reproduced, not "fixed"). `i=0` evaluates `x/0` (division by zero — engine-defined, stays `[U]`; penalty is moot there unless water is found at 11 along 0°).
- Fast (`tries=16`, `angle=22.5i`): fires at **`i=2` (45°)** via `84..96` ($22.5·4=90$) and **`i=4` (90°)** via `354..366` ($22.5·16=360$); `i=0` is the same div-by-zero `[U]`.

**`[D]` quirks the port must reproduce structurally (never "fix"):**

1. `angle := minIndex*5` (`:4625`) is hardcoded for the 72-try grid **in both arms** — in fast mode `minIndex ∈ 0..15` maps to `0..75°`, i.e. the fast arm only emits a 75° wedge. Reproduce verbatim.
2. `minDistance` floor `7.5` (`:4626-4627`) can **override** the innermost-water result outward (e.g. water at 3 m still yields a 7.5 m point). Reproduce, do not clamp to the water cell.
3. `bPrecise` at every in-repo caller is `True` (`unit.script:4439,5627,11925,12028,12062`; `doprogressorders.inc:21,58,100,270`; `initial.inc:218,236`; `ontagstates.inc:100`; `miscext2.script:1148,1175`; `player.script:2961,3038`) except `misc.script:4668` (`_misc_CanPlaceBuilding` port check, passes its own `bPrecise` through). The port's fisher path therefore always takes the 72-try arm.
4. Failure semantics: on `minIndex=-1`, `x/z` keep incoming values and `Result=False` — but `_TryFishing` (`unit.script:12028`) and the re-path branch (`:12062`) and `DoReturnToPort` (`:11925`) **ignore `Result`** and steer/deliver on whatever `x/z` hold (engine-defined stale values, `[U]`). Only `_RemoveShipDummy` (`:5627`), `_CanPlaceBuilding` (`:4668`) and the `.inc` callers branch on it. The port must define this explicitly (see §5.4) and label it `[U]` until a no-water-port trace closes it.
5. `gc_racename_misc` / `gc_basename_bui` symbolic names are `[O]` as identifiers; their string values were not read this ticket — next read, §4 U-PORT-BUI.

## 3. Rotation semantics — negative result, exact replication rule

P6 negative (`ev_0d31f4b6…`): no `VectorRotateY`, direction, or counter-rotation term appears at or near any of the 5 `resourcePoint` consumption sites (`unit.script:9591,9626,9642,9702,9756-9757`), and the parse stores raw file `x/z` (`country.script:4167-4169`). **`[D]`:** the donor law is unrotated world-axis addition; the port replicates it by plain `Vector2` addition with **no rotation matrix and no visual-scale factor** (donor script applies neither; port `scale`/`roll` in `data.gd:3053-3068` are visual-only). Whether the engine pre-rotates building local frames at placement is not in the read text — covered by trace T-ROT (§4), not by inventing a rotation.

## 4. Remaining `[U]` register — fixed-camera delivery traces, zero-mismatch criteria

| # | Item | Static state after this pass | Settling trace (fixed seed + fixed camera; never invent an offset) |
|---|---|---|---|
| E1-OFF | per-building offsets wired into port | Table §1 is `[O]`; port reads but never populates `resource_point` (P5) → centre fallback is PORT APPROXIMATION | **T-OFF**: fixed seed, 1 peasant + `sto/mil/cen` (port generic sids), full load, camera locked on storehouse. Log per-tick `dstSqr` vs `_store_drop_point()` and the drop tick for 20 seeded runs per building. Oracle: `dstSqr<0.5` vs §1-mapped point (`sto=(0.20,-1.69)`, `mil=(-0.02,-1.61)`, `cen=(0.80,-3.20)`). Termination: **zero-mismatch** — drop tick + credited amount + re-target match on 60/60 runs. Until then the centre form keeps its `PORT APPROXIMATION [U]-E1` tag. |
| E1-R | rotation of the offset vector | Zero rotation terms `[O]`-negative (§3); engine pre-rotation unread | **T-ROT**: same setup, rotate building facing if the port supports it (4 facings × 5 runs). Oracle: drop tick identical across facings (unrotated law). Termination: zero-mismatch across facings, else the facing-dependence is ported verbatim from the trace and this report is amended — never pre-rotated on assumption. |
| E1-PORT | `GetPortResourcePoint` arms in port | Full law §2 `[O]`; port `_port_resource_point` is centre-only; no `bui`-child concept; `Result=False` path undefined in port | **T-PORT-BUILT**: fixed seed, finished `dock`, laden fishboat. Oracle Arm 1: port point within the built-arm tolerance of the donor `bui` absolute position (next text read U-PORT-BUI gives the basename strings). **T-PORT-RAW**: same with unfinished dock (Arm 1 gated on `bbuilt`/`finished` `:4513` → falls to water-ring): log `resx/resz` per tick; oracle = §2 scan replicated on the same collision grid (`tries=72`, innermost water `3..10`, `×1.1` at `i∈{1,6}`, winner-pick, `7.5` floor). Termination: zero-mismatch on point + `dstSqr<16` credit tick on 20/20 runs each. Until then water-ring stays `[U]` and centre form keeps its tag. |
| E1-FAIL | `Result=False` (no water in ring) | Donor callers `:12028/:12062/:11925` ignore `Result` (engine-defined stale `x/z`) | **T-PORT-DRY**: landlocked-port map (no water within 11 m), laden fishboat. Log behaviour/tick. Termination: port behaviour matches the decided rule in §5.4 (hold + no credit) on 10/10 runs; the rule itself stays `[U]` (no donor observable cited for the stale-value content). |
| E1-BUI | `gc_racename_misc` / `gc_basename_bui` string values | Identifiers `[O]`, values unread | Text read: grep `gc_racename_misc\s*=` + `gc_basename_bui\s*=` in `dmscript.global`; cite file:line. No trace needed. |
| D1 | global `resourceDropRadius=3 / Sqr=9` consumers | Literals `[O]` (`dmscript.global:210,220`); no proven consumer (market-tail §3, unchanged) | No trace (nothing to wire). Reopen only on a newly found consumer call site. |

## 5. Concrete port change list (`variant3d/scripts/…`; no edit made here)

Line numbers as-read 2026-11-26; re-anchor by function name + verbatim text (files are concurrently edited).

### 5.1 `data.gd` — add `RESOURCE_POINT` table (new const; cites only, values verbatim §1)

```gdscript
# DONOR resourcePoint offsets (objcustom.cfg via country.script:4164-4169; y forced 0 at :4168).
# Keyed by donor sid; port generic sids map by their own prop-file cites (§1 [D]4).
const RESOURCE_POINT := {
    "eursto": Vector2(0.20, -1.69),   # objcustom.cfg:21428
    "eurmil": Vector2(-0.02, -1.61),  # objcustom.cfg:10952
    "algcen": Vector2(0.80, -3.20),   # objcustom.cfg:7744
    # full 27-row donor table (DEC_U_res_point §1) for nation-specific buildings, if added later:
    # swecen (0.02,-3.68):1452; prucen (-0.06,-3.07):3714; polcen (-0.06,-2.63):5274;
    # turcen (0.49,-3.41):7597; spacen (0.10,-3.35):9020; ukrcen (-1.30,-3.16):12330;
    # ruscen (-0.28,-3.22):14011; auscen (-0.11,-3.34):15051; engcen (-0.50,-3.67):16801;
    # fracen (0.01,-3.12):18652; vencen (0.07,-3.86):20826; russto (0.19,-1.50):21591;
    # tursto (0.17,-1.67):21766; rusmil (0.04,-1.09):21879; turmil (-0.44,-2.56):22078;
    # dencen (-0.10,-2.20):29341; netcen (0.43,-2.23):32119; bavcen (-1.45,-3.07):34233;
    # saxcen (0.24,-3.25):35963; scocen (0.00,-0.72):38373; porcen (0.30,-3.17):41015;
    # huncen (1.39,-2.25):44398; piecen (-0.25,-2.42):47168; swicen (-1.82,-2.51):50098
}
const PORT_SID_TO_DONOR := {"sto": "eursto", "mil": "eurmil", "cen": "algcen", "dock": ""}
# sto→eursto.prop (data.gd:3059); mil→eurmil.prop (:3053); cen→algcen.prop (:3068). NO PARITY CLAIM.
```

### 5.2 `game.gd` — `spawn()` (`:3090-3121`): populate the key the readers already expect

After the entity dict is built (cite `:3102-3106`), insert (new lines, no existing logic touched):

```gdscript
if e.kind == "building":
    var donor_sid: String = str(Data.PORT_SID_TO_DONOR.get(sid, ""))
    if donor_sid != "" and Data.RESOURCE_POINT.has(donor_sid):
        e["resource_point"] = Data.RESOURCE_POINT[donor_sid]
```

`[D]`: `_store_drop_point()` (`:7620-7626`) and `_port_resource_point()` (`:7633-7639`) already consume `resource_point`/`port_resource_point` with `Vector2.ZERO` default — this insert flips them from centre fallback to donor offsets with no reader change. Do NOT scale by `def.scale`/`roll` (§3). Do NOT rotate (§3, T-ROT pending).

### 5.3 `game.gd` — `_store_drop_point()` (`:7620-7626`): re-tag, keep code

Keep the body byte-identical. Replace the `[U]-E1` comment (`:7617-7619`) with: `E1-OFF wired via spawn() + Data.RESOURCE_POINT (donor objcustom.cfg §1 table); centre fallback remains only when the key is absent; T-OFF/T-ROT (§4) still required before removing the PORT APPROXIMATION label. NO PARITY CLAIM.`

### 5.4 `game.gd` — `_port_resource_point()` (`:7633-7639`): implement Arm 2, define failure

Keep the `port_resource_point` lookup (harmless; donor ports carry no block). Append after it, before `return b.pos`:

```gdscript
    # DONOR Arm 2 (misc.script:4520-4634; bPrecise=True at all fisher callers).
    # Port has no bui-child (Arm 1, :4509-4518) — finished-dock point stays [U] (T-PORT-BUILT).
    # 72 rays × step 5°, probe at 11 m (collision-radius-1 water test), innermost water
    # cell along 3..10 m, ×1.1 at ray index 1 and 6 (evaluated §2 [D]), winner = min > 0,
    # floor 7.5 m. Result=False (no water): HOLD position, no credit — [U] E1-FAIL (T-PORT-DRY).
```

The scan itself needs the port collision grid's water query (same predicate as placement/can_place water tests); the constants above are donor-exact, the grid predicate binding stays `[U]` until T-PORT-RAW. Fast arm (`tries=16`, `:4577-4622`, wedge quirk `:4625`) is NOT ported — no caller in the fisher path uses it (`bPrecise=True` everywhere on that path); cite this reason at the call site.

### 5.5 Untouched (explicitly): radii, credit, cadence

- `STORE_DROP_RADIUS_SQR=0.5`, `FISHER_DROP_RADIUS_SQR=16.0`, `FISHER_RADIUS_MOVE_CHANGE=15.0`, `FISHER_SPEED_BASE=12.0`, `FISHER_MAX_BASE=1000.0` (`game.gd:7588-7597`) already match donor `:9704, :12032, :12005, :1865-1866` — no change.
- `GLOBAL_DROP_RADIUS[_SQR]` (`:7586-7587`) stays `[U]` with no consumer (D1, unchanged).
- `DELIVERY_RADIUS_M` (`data.gd:359`) stays unread at D2/D3 (market-tail §5.3, unchanged).

## 6. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor text `[O]` with file:line; open items list exact next reads/traces in §§4–5.
- No offset invented: every number in §1 carries an `objcustom.cfg:line`; the three port-mapped rows are pinned to the port's own prop-file cites. Unmapped nation rows are quoted for later use, not wired.
- Deltas vs prior reports: (a) `[U]-E1` per-building offsets now `[O]`-recovered (27/27) — only the port wiring + traces remain; (b) `GetPortResourcePoint` fallback fully transcribed with evaluated penalty sets and four structural quirks (fast-mode wedge, 7.5 floor, dead guards, ignored-`Result` callers) that the port must reproduce, not fix; (c) rotation resolved as unrotated-addition `[D]` with negative evidence, pending T-ROT.
- Read-only compliance: exactly one repo file written (this report). No `.gd`/config/save/asset/git change. Native evidence in §0 P1–P4/P6/P8 was read, not run.

*End of DEC-U-RES-POINT.*
