---
id: DEC-U-COLLISION-FULL
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-COLLISION-FULL — mechanical per-sid radius/mask/slot audit, mask provenance, centred-origin/rotation verdict, inertia/LOS/ctpo semantics, data.gd/game.gd change list"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_collision_full.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only text/byte/VA/decomp observation; every port statement is a read-only source line. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only; network/multiplayer/lobby/Steam/replay-sync explicitly OUT OF SCOPE."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every Craft Anything call in THIS job passed document=t_87f0f3c130b0 explicitly; global active target was already t_87f0f3c130b0 and was never changed."
port_scope: "app/scripts/data.gd + app/scripts/game.gd (read-only line citations; change list is specify-only, no edit). picking3d.gd / variant3d callers are noted only where the prior worker already specified them."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (§0-§6, U2/U3/U7/U14/U12/U13, P1-P15, ev_* carried as noted)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_objects_anim_collisions_fx.md (§1.5-§1.6, §6 U12 plan)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_skirmish_impl_patch.md (IMPL-COLLISION-CALLERS concurrency note)
context_delta: "Prior worker recovered collision caller constants (px radii, gc_collision_size=0.5, centred helpers sub_755168/764e04/7550f8/75505c) but left [U]: U12-ships sid→slot px radius, U12-formation slot, mask bitmaps absent from repo, inertia numeric, LOS/OctreeRayCast, ctpo operand semantics. IMPL-COLLISION-CALLERS has since wired the donor MINIMUM ship radius as a labelled floor, not a per-sid map (per task brief; concurrent edits: re-anchor by function name before applying §8)."
---

# DEC-U — full collision audit (donor 1:1, per-sid tables)

> READ-ONLY. No approximation endorsed. Each `[U]` ends in a named capture, never in a port fallback.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary VA / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only donor tree). `P:` = workspace `app\scripts\`. `c3` = `t_87f0f3c130b0`.
- `ev_<hex>` = Craft Anything evidence id of a pass in **this** job (all `document=t_87f0f3c130b0` for binary calls, or donor text paths for file reads). `ev(carried)` = id from the prior worker, re-cited not re-run.

### 0.1 Pass ledger (pin `t_87f0f3c130b0`, multiple passes; strange-decomp log inline)

| Pass | Operation | Evidence | Result |
|---|---|---|---|
| P1 | `native_strings_find` `Collision` / `Inertia` / `OctreeRayCast` / `RayCast` | `ev_2debdff96f1275ad979aef6d1f3a9a57ffee1b065bd682eb68f673ea722f5a3`, `ev_505f45f3ef0ea0bfbd66600a1d3e9176100f2c7475524a9310eb01cd40589`, `ev_9f2733165510c3de6f7db53ee7c3e1cca558ecb5b498a8a56466874598a1e40d`, `ev_051e42b1e2817b9cd6e9844bd8aa82c53aab89572473d7afd16fdd3af62b46a8` | [O] `Collision` ×3 (`.rsrc` `0x9589c7 XCollisionMask`, `0x958a13 XCollisionTags`, `0x95972b 3XCollisionInertia`); `Inertia` ×1 (same `0x95972b`); `OctreeRayCast` ×0; `RayCast` ×0 strings |
| P2 | `native_strings_find` `ctpo` / `SetObjectCollisionRadius` / `DefaultRadius` / `XCollision` | `ev_0737937de5741f205fb140e7c8d5df015a7c02586ea38835305a365b9d9b8b00`, `ev_bd93ed9e22e805e7bfa24b8ce19919b6d7097b668236851e2a1cdd97a5acee23`, `ev_782090193403838756e6930fe349b73202a71eaf8069b7ad91a00a7d1712f`, `ev_90e9295ed7e4f2981c04889d80d7bfba2a2d8598112b72c1c5376d42870da4f9` | [O] all ×0 except `XCollision` ×3 (same 3 VAs). `SetObjectCollisionRadius` and `DefaultRadius` have **no binary string** — radii do not flow through an export of that name |
| P3 | `native_functions_decompile` `0x755168,0x764e04,0x7550f8,0x75505c` | `ev_865549a98c09af367c51b5d3bd400d27ab4c3da35144e4d85433598818c403b8` | [O] 4/4 ok. `sub_764e04` = bounds-checked `rowTable[[obj+0xa8]][edx][ecx]=arg_8`; `sub_755168` = centre by `(W-1)>>1/(H-1)>>1` then store; `sub_7550f8` = pure −half..+half bounds test + centred read; `sub_75505c` = centred test + `+[0x65]` gate + occupant id write at `+0x1c` |
| P4 | `native_xrefs_list` `0x9589c7/0x958a13/0x95972b` | `ev_13ed9a5b4f80e2e752a0fefdf18448bfea3cb51f87fbb924e4de480199b50605`, `ev_11fbcdedb69a5eb0a49fa45e808433195a02babe4bec3e398768ed147bbbb113`, `ev_ada22e94aa3ce8c7d8aca74659b93d7f75dbdfc74a9f1c6e98010bc8940aaf4b` | [O] 0 static xrefs each — `.rsrc` collision classes resolve at runtime (Delphi RTTI), not by static pointer [D]. Not proof of non-use |
| P5 | `native_bytes_find` text `XCollisionTags` / `ctpoEqual`; `native_instruction_show` + `native_function_find` on `0x5dcdc3` | `ev_abd1241e9d896e2b82625d09732beffc1cb2f0cc94184632286dede19885bb2e`, `ev_8d8b5116f15354626b0ae9796d5c8539ebf615be81294a9cc01c0466ccbb2a79`, `ev_61c732f3b5d00108e1a179587bbdb9e4eb44fb9686aa98e788a98987fc21a51b`, `ev_ca881fe6b49a6812754de41dc1b1911f82fb62493641c8225c890f3f93b554a0` | [O] `XCollisionTags` ×5 (4 CODE + 1 `.rsrc`); `ctpoEqual` ×2 in CODE (`0x84981e/0x849f20`). CODE `0x5dcdc3` disassembles as single-byte `pop eax`; `function_find` = not inside any discovered function. Verdict: **false positives** (packed/script bytecode `0x58`), discarded as call sites [D]; kept only as "script constants embedded in image" |
| P6 | donor text `dmscript.global:161-220` (conversions) + `:661-690` (radii) + `:966-980` (collision mass/radius) | `ev_fc1398b77c214799c239f95cdaca3c25a1e99c53351d9ac8bd132ad7cb0e25e9`, `ev_4fefbfdeaad7b19065216b60f97caf23b093f41d72f14751fdedaf3c6916aa3f`, `ev_c875ebfbd2cb967b209c0b77f5f73dd98d6b53708044d17814f34ee404f9f39d` | [O] `gc_pixels_to_tile=53.3333333`, `gc_meters_to_tile=2`, `gc_pixels_to_meter=26.6666666`, `gc_collision_size=0.5`, full `gc_obj_radius_*` + `gc_collision_{mass,radius}_*` rows (see §1/§6) |
| P7 | donor text `refbuilding.prop:36-145` (mask/mesh/CI defaults) + `algcen.prop:1-80` (mask rows + AABB) | `ev_ae79d66a91cd121c748eca5a7b0980d6f3fa7cd0aa91dba36aa7485f71c64ca1`, `ev_21bc4983e2b61a3004e1b7c4c1edade8b3179b509578b1d20ef6aed4b820c929` | [O] refbuilding mask-layer defaults (`Rotate=0/ScaleFactor=1/Reflect=False`, all `tmo*=False`, `coTest/coWrite=True`, `cttoNone/ctpoNever`); algcen 11×12 bitmap + AABB `(-2.40,0.00,-1.20)..(2.55,1.65,1.20)` |
| P8 | donor text `misc.script:2281-2360` (LOS march with `GetGameObjectRayCastAABBByHandle` / `CustAABB`) | `ev_f3852410fff8af3a46ef4c9c27cc61303ce6e4d630af4b01ced15bdc8fc0ac5` | [O] scan-grid march calls `GetGameObjectRayCastAABBByHandle(goHnd,x1,tmpy1,z1,x2,tmpy2,z2)` (and `CustAABB` when `gCustomObjPoints[cid][id].aabb.buse`), `y<0.05→0.05` clamp; full chain in §7 |
| P9-SH | read-only shell census: `D:objects/buildings/*.prop` (369), `D:objects/units/*.prop` (140), mask-row regex, per-sid scales/AABBs, `unit.script` sid branches, `control.script` pick chain, `group.script` formation grid, `formations.cfg` ids, wall/gate/tower samples | shell output (no evidence id; commands listed in §9 provenance) | [O] 354/369 building props carry own `[*] = [01]+` rows; 15 do not (list §2); 0/140 unit props carry mask rows; full dim histogram §2; sid→radius branch map §1; pick/LOS/inertia sites §6/§7 |

**Strange-decomp log (required):** P5 CODE-region `XCollisionTags` hits initially looked like caller anchors; per-byte `instruction_show` + `function_find` proved `0x5dcdc3` is a `0x58` byte outside any discovered function, and `ctpoEqual` VAs likewise sit outside discovered code. They are **discarded as call sites**. No branch polarity or caller was guessed. The only trusted binary caller semantics remain P3 (`sub_755168/764e04/7550f8/75505c`), whose pseudo-C is register-level but structurally unambiguous (bounds tests + centred index + `+0xa8` row table + `+0x1c` occupant slot).

---

## 1. Per-sid collision RADIUS table (exact; no `SetObjectCollisionRadius` export)

### 1.1 Negative result first [O]

There is **no** `SetObjectCollisionRadius` and **no** `DefaultRadius` string in the binary (P2, `ev_bd93…`/`ev_7820…` ×0) and no such key in any sampled `.prop` or `dmscript.global`. The donor radius surface is:

- `D:scripts/dmscript.global:665-678` (`ev_4fef…`): `gc_obj_radius_*` px constants;
- `D:scripts/lib/misc.script:460-465` (`_misc_PixelsToTiles`, carried `ev_a3ba…` from prior worker): `Result := val/gc_pixels_to_tile`;
- `D:scripts/lib/unit.script` per-sid `objprop.radius := _misc_PixelsToTiles(gc_obj_radius_*)` overrides (§1.3);
- engine CI surface `SetGameObjectCIIntersectRadiusByHandle(hnd, …)` (`unit.script:11163/11169`, §6).

`DefaultScale` **does** exist — as a `.prop` key (`scaleproperty`), not a binary string (see §3).

### 1.2 Canonical px → tiles → metres law [O/D]

`dmscript.global:170-172` (`ev_fc13…`): `gc_pixels_to_meter = 26.6666666; gc_meters_to_tile = 2; gc_pixels_to_tile = 53.3333333`. Hence per prior worker (unchanged):

- `tiles = px / 53.3333333` [D]; `metres = px / 26.6666666 = tiles × 2` [D].

### 1.3 Exact radius table [O] px + [D] conversions

| Donor constant (`dmscript.global:665-678`, `ev_4fef…`) | px | tiles [D] | metres [D] | Applies to (branch site [O]) |
|---|---|---|---|---|
| `gc_obj_radius_default` | 10 | 0.1875 | **0.375** | every sid whose `unit.script` branch has **no** `objprop.radius` override (infantry/peasant/officer/drummer/priest/grenadier defaults in `:630-1330` sampled; full 140-sid no-override proof is mechanical recipe §9-U) |
| `gc_obj_radius_horse` | 15 | 0.28125 | **0.5625** | `unit.script:1323` cavalry branch (`croat/hussar/hussarpru/wingedhussar/cossacksich/…hackapell/raidersco/…`); `:1421` reiter/cuirassier/… branch; `:1547` dragoon branch head; `:1667` tatar branch |
| `gc_obj_radius_artillery` | 15 | 0.28125 | **0.5625** | `unit.script:1700` cannon; `:1736` howitzer; `:1769` mortar; `:1797` multicannon; `:1827` framegun |
| `gc_obj_radius_ship_fishboat` | 40 | 0.75 | **1.5** | `unit.script:1858` `fishboat` |
| `gc_obj_radius_ship_ferry` | 70 | 1.3125 | **2.625** | `unit.script:2036` `ferry` |
| `gc_obj_radius_ship_yacht` | 35 | 0.65625 | **1.3125** | `unit.script:1876` `yacht` (+`yachttur` entry, overridden below) |
| `gc_obj_radius_ship_yachttur` | 50 | 0.9375 | **1.875** | `unit.script:1907` inside `yacht/yachttur` branch, `if sid='yachttur'` override |
| `gc_obj_radius_ship_chaika` | 45 | 0.84375 | **1.6875** | `unit.script:2016` inside `frigate/xebec/battleship/chaika` branch, `chaika` override |
| `gc_obj_radius_ship_galley` | 80 | 1.5 | **3.0** | `unit.script:1925` `galley` |
| `gc_obj_radius_ship_frigate` | 90 | 1.6875 | **3.375** | `unit.script:1962` `frigate` base of the 4-ship branch (frigate keeps it) |
| `gc_obj_radius_ship_xebec` | 80 | 1.5 | **3.0** | `unit.script:1992` `xebec` override |
| `gc_obj_radius_ship_battleship` | 90 | 1.6875 | **3.375** | `unit.script:2002` `battleship` override |
| `gc_obj_radius_formation_default` | 8 | 0.15 | **0.30** | DEFINED `dmscript.global:677` but **commented out** at use site — see §4 [U] |
| `gc_obj_radius_formation_horse` | 12 | 0.225 | **0.45** | DEFINED `dmscript.global:678`; no active consumer found in sampled passes — see §4 [U] |

Ship-branch nesting (exact, `unit.script:1855-2036` shell read [O]): `fishboat` alone; `yacht,yachttur` (tur overrides yacht); `galley` alone; `frigate,xebec,battleship,chaika` (frigate base, xebec/battleship/chaika each override); `ferry` alone. `yachttur` therefore never uses 35 px; `xebec` never uses 90 px.

IMPL-COLLISION-CALLERS note: wiring the **minimum** ship radius (35 px → 1.3125 m yacht) as a labelled floor is consistent with the table's column minimum, but it is **not** the per-sid map above; §8-C1 replaces the floor with the per-sid rows.

### 1.4 What remains [U] U12-ships

- **[U] U12-ships-open:** (a) proof that no other `objprop.radius` override exists outside `unit.script:630-2060` sampled branches (mechanical grep recipe §9, then this table is closed); (b) whether `objprop.radius` (broadphase/separation) and the placement `blocked` disc use the same value at runtime (placement callers read `GetGameObjectCollisionMask*` for buildings, never `objprop.radius` — units have no mask at all, §2).
- No GPU needed: close by text. Until then the per-sid rows above are the table; any port row not equal to its cell is a port estimate, labelled as such.

---

## 2. Per-sid collision MASK bitmaps (exact provenance + extraction)

### 2.1 Provenance rule [O]

Each `D:objects/<kind>/<sid>.prop` carries `{refurl=.\data\objects\ref\<ref>.prop}` and **only the sections it overrides**. Mask rows live in `collisionmaskproperty → Mask : struct.begin → [*] = <01-string>` (`algcen.prop:46-56`, `ev_21bc…`). Reference files (`refbuilding/refunit/refenv/…`) define the class defaults and carry **no** `Mask` rows (`refbuilding.prop:39-73`, `ev_ae79…`: mask-layer keys but no `Mask` block). Extraction method (read-only, no binary executed, nothing copied into the repo):

1. `Get-Content <sid>.prop -Raw`;
2. regex `\[\*\] = ([01]+)` inside the `collisionmaskproperty` section;
3. row count = bitmap height `h`, first-row length = bitmap width `w` (all sampled bitmaps are rectangular; any ragged file would fail closed as [U]).

### 2.2 Census [O] (shell, `D:objects/buildings/*.prop` = 369 files)

- **354 files carry their own `Mask` rows; 15 do not** (hence inherit the mask-less ref default = no bitmap):
  `algaca, algart, algbar, algbla, algdip, algsta, algtem, misdecor1…misdecor8` (7 + 8).
- `D:objects/units/*.prop` = 140 files, **0 carry mask rows** (`refunit.prop` has `collisionmaskproperty Enabled=False`, carried `ev_3c27…`). Units are AABB/CI-only by donor text.
- Dimension histogram (rows×width, counts sum to 354) [O]:

| dim | n | dim | n | dim | n | dim | n |
|---|---|---|---|---|---|---|---|
| 2×2 | 62 | 4×4 | 45 | 5×5 | 2 | 5×6 | 1 |
| 3×5 | 1 | 3×6 | 1 | 4×2 | 1 | 5×7 | 2 |
| 5×8 | 1 | 6×2 | 4 | 6×8 | 2 | 7×6 | 6 |
| 7×8 | 5 | 7×10 | 7 | 7×11 | 1 | 7×12 | 4 |
| 8×6 | 3 | 8×8 | 8 | 8×10 | 4 | 8×12 | 3 |
| 8×14 | 2 | 9×8 | 2 | 9×10 | 20 | 9×11 | 1 |
| 9×12 | 10 | 9×14 | 2 | 10×8 | 9 | 10×10 | 10 |
| 10×11 | 1 | 10×12 | 10 | 10×14 | 1 | 11×10 | 6 |
| 11×11 | 2 | 11×12 | 24 | 11×14 | 5 | 11×15 | 1 |
| 11×16 | 1 | 12×12 | 15 | 12×14 | 3 | 13×12 | 4 |
| 13×13 | 1 | 13×14 | 17 | 13×16 | 2 | 14×12 | 2 |
| 14×13 | 1 | 14×14 | 5 | 14×15 | 1 | 14×16 | 1 |
| 14×18 | 1 | 15×12 | 2 | 15×14 | 2 | 15×16 | 10 |
| 15×18 | 1 | 16×8 | 1 | 16×12 | 1 | 17×16 | 1 |
| 17×18 | 4 | 19×18 | 1 | 19×20 | 2 | 19×22 | 1 |
| 21×18 | 1 | 2×6 | 4 | — | — | — | — |

### 2.3 Game-sid → donor-file mapping + verbatim bitmaps [O]

Game sids aggregate nation-prefixed donor files: `cen/hou/bar/dip/sta/bla/aca/art` × 21 nations each (`alg/aus/bav/den/eng/eur/fra/hun/net/pie/pol/por/pru/rus/sax/sco/spa/swe/swi/tur/ukr`); `mil` ×3 (`eur/rus/tur`); `sto/mar` ×4 (`eur/rus/spa` + `turmar` for mar); `tow` ×3 (`eur/rus/tur`); walls/gates/towers per-nation (`eurswa*`, `russwa*`, …). Cell size `gc_collision_size = 0.5` (`ev_fc13…`) = half a map cell = 1 m at `gc_meters_to_tile = 2`.

Verbatim rows (whitespace-trimmed; `1` = blocked):

- `mil` ← `eurmil.prop:47-51`: 5×5 diamond —
  `00100 / 01110 / 11111 / 01110 / 00100`. AABB `(-0.70,-0.15,-0.60)..(0.60,2.20,0.65)`, scale `0.43³`, roll 45.
- `tow` ← `eurtow.prop:47-51`: 5×5 —
  `01110 / 11111 / 11111 / 11111 / 01110`. AABB `(-1.05,-0.25,-0.65)..(0.80,2.35,0.85)`, scale `0.54³`, roll 45.
- `sto` ← `eursto.prop:47-51`: 5×7 —
  `0000000 / 0000010 / 1100010 / 0000010 / 0000000`. AABB `(-1.30,-0.55,-0.30)..(0.15,0.85,1.50)`, scale `0.665³`, roll 45.
- `mar` ← `eurmar.prop` (11×15): `000000000110000 / 000001111111000 / 000011111111100 / 000111111111110 / 011111111111110 / 111111111111100 / 011111111111000 / 001111111100000 / 000011111000000 / 000001110000000 / 000000100000000`. AABB `(-2.25,0.00,-1.55)..(2.55,1.70,1.80)`, scale `0.463³`, roll 135.
- `cen` ← `algcen.prop:47-57` (`ev_21bc…`): 11×12 —
  `000000011000 / 000000111100 / 000001111110 / 000011111111 / 000111111111 / 001111111110 / 011111111100 / 011111111000 / 011111110000 / 001111100000 / 000000000000`. AABB `(-2.40,0.00,-1.20)..(2.55,1.65,1.20)`, scale `0.41³`, roll 135.
- walls/gates/towers ← `eurswa*.prop`: `eurswa`, `eurswa_01`, `eurswa_gate`, `eurswa_tower` **all 2×2** (`11/11`); `eurswa_gate` AABB `±0.6 × 0.00..1.65`, scale `0.33333³`, roll 0. (Wall run segments compose from 2×2 cells; `45gate/turn/v1/v2` variants share the 2×2 cell — sampled [O], full variant table by the §9 recipe.)

Nation variance is NOT assumed uniform: `algcen` (11×12) vs `eurmil` (5×5) prove dims differ by (nation, sid). Any port single-radius-per-game-sid therefore cannot reproduce the bitmap set; §8-C2 exports every file's rows keyed by `(nation, sid)`.

### 2.4 What remains [U] U12-mask

- **[U] U12-mask-open:** (a) full 369-file `(nation,sid)→(w,h,rows)` dump (mechanical; recipe §9); (b) fallback semantics for the 15 mask-less files (ref default has no bitmap — placement path for e.g. `algsta` unproven; capture C-CAP-1 covers); (c) any `Rotate ≠ 0` override in the 369 files (sampled files all inherit `Rotate=0`; full scan is one grep, recipe §9). No approximation: until (a)-(c) land, the port must carry the sampled bitmaps above plus an explicit gap list, never a resized stand-in.

---

## 3. `DefaultScale` / AABB / `SelectionSize` (exact per-sid rows)

### 3.1 Class defaults [O]

| Ref file | `DefaultScale` | AABB | `SelectionSize` / CI |
|---|---|---|---|
| `refunit.prop` (carried + re-cited) | `(0.5, 0.5, 0.5)` | `(-0.25,-0.10,-0.25)..(0.25,0.90,0.25)`, sphere `0.32` | `stoCircle`, `SelectionSize=0.5`; `CIEnabled=True/Movable=True/Mass=1/CIIntersectRadius=0.16` |
| `refunithorse.prop` | `(0.5375³)` | `(-0.35,0.05,-0.35)..(0.35,0.95,0.35)` | inherits unit selection/CI |
| `refbuilding.prop` (`ev_ae79…`) | `(0.375³)` | `±0.5³`, sphere `0.5` | `stoCircle`, `SelectionSize=1`; `CIEnabled=False/CIMovable=False/Mass=1/CIIntersectRadius=0.16` |

Per-sid unit props **inherit** scale unless they override: `cannon.prop` (no `scaleproperty` block [O]) → `0.5`; `frigate.prop` (no `scaleproperty` block [O]) → `0.5` with ship AABB `(-0.7,-0.4,-2.0)..(0.7,0.9,3.2)` + `UseCustTransformed=True`, `ocoTerrainWater`. Horse sids use `refunithorse` (`0.5375`).

### 3.2 Building per-sid overrides [O] (shell reads)

| Game sid (donor file) | `DefaultScale` | `DefaultRollAngle` | AABB min..max |
|---|---|---|---|
| `mil` (`eurmil`) | 0.43³ | 45 | `(-0.70,-0.15,-0.60)..(0.60,2.20,0.65)` |
| `sto` (`eursto`) | 0.665³ | 45 | `(-1.30,-0.55,-0.30)..(0.15,0.85,1.50)` |
| `mar` (`eurmar`) | 0.463³ | 135 | `(-2.25,0.00,-1.55)..(2.55,1.70,1.80)` |
| `tow` (`eurtow`) | 0.54³ | 45 | `(-1.05,-0.25,-0.65)..(0.80,2.35,0.85)` |
| wall/gate (`eurswa_gate`) | 0.33333³ | 0 | `(-0.6,0.00,-0.6)..(0.6,1.65,0.6)` |
| `cen` (`algcen`) | 0.41³ | 135 | `(-2.40,0.00,-1.20)..(2.55,1.65,1.20)` |

Mask-layer transform keys (all sampled building files [O]): `Rotate=0`, `ScaleFactor=1`, `Reflect=False`, `TransformMaskOptions {tmoScale=False, tmoRotate=False}`, `TransformChildrenMaskOptions {False,False}`, `LayerOptions {all False}`, `Options {coTest=True, coWrite=True}`, `ChildrenOptions {False,False}`, `TestTypeOption=cttoNone`, `TestPriorityOption=ctpoNever`. Scale therefore does **not** rescale the bitmap at the mask layer in any sampled file; AABB is the scaled broadphase (`UseCustTransformed=True` on buildings).

---

## 4. Formation slot: defined constants, commented-out consumer [U]

- Defined [O] (`ev_4fef…`): `gc_obj_radius_formation_default = 8` (0.30 m), `gc_obj_radius_formation_horse = 12` (0.45 m); `gc_formation_maxcount=160`, `gc_formation_maskmaxwidth=54`, `gc_formation_maskmaxheight=24` (`ev_fc13…`).
- Formation table [O] (`D:game/var/formations.cfg`): `id=none` (mask `*`) + `LINE3..LINE27` + `LINE3PUS..LINE27PUS` (sampled ids to `LINE27PUS`; full count by recipe), each with `symmetry/bonusdamage/bonusshield/bonusdamagehold/bonusshieldhold` + `mask` rows of `*` (slot) vs `.` (gap), e.g. `LINE3: *..*..*`, `LINE3PUS: *.*.*`. Loader [O] (`init.script:5-78`): parses `gc_filepath_formations` into `gFormation[i]{id,sid,symmetry,…,width,height,countunits,countofficers,mask,maskofficers}`, `*`→`True`.
- Consumer [O] (`group.script:122-160` shell read): the **only** sampled formation-radius use is **commented out**:
  `//unitRadius := _misc_PixelsToTiles(gc_obj_radius_formation_default);` with the C1-vs-C3 cavalry note; active code uses `unitRadius := _group_GetMaxUnitRadius(grHnd)` then `unitRadius := unitRadius*0.8; dispRadius := unitRadius*0.5`, `GroupSetMinX/Y(unitRadius*4)`, `GroupSetOffsetX/Y(dispRadius)`, grid `cols/rows := fWidth/fHeight`, cells from `TSquad.arGrid` masked by `gFormation.mask`.
- **[U] U12-form-open:** the px slot constants (8/12) have no active consumer in sampled code; the live slot pitch is `unitRadius*0.8`-derived + formation-mask-gated. Which unit kinds use the horse slot, and the exact `arGrid` slot→world offsets, need the `squad.script` slot-placement read + runtime capture C-CAP-3. The port must not treat 8/12 px as implemented slot pitch; label them defined-but-unconsumed.

---

## 5. Centred mask origin: statically recovered [O]; rotation: statically absent in samples [O] with full-scan recipe [U]

Binary [O] (`ev_8655…`):

- `sub_764e04`: `if 0<=edx<W and 0<=ecx<H: rowTable[[obj+0xa8]][edx][ecx] = arg_8` — row-major bit table behind `+0xa8`.
- `sub_755168`: adds `(W-1)>>1` to dx and `(H-1)>>1` to dz before delegating to `sub_764e04` — placement write is **mask-centred on the target cell**; even sizes bias by `>>1` truncation [D].
- `sub_7550f8`: tests `-W/2..+W/2 × -H/2..+H/2`, then adds `W>>1/H>>1` back before the row-table read — centred read.
- `sub_75505c`: centred test + `if [esi+0x65]!=0` gate → `sub_7d9694`, then writes occupant id at record `+0x1c`.

Donor placement readers confirm the consumer side [O]: `unit.script:8588-8595/8714-8724/8771-8981` (`GetGameObjectCollisionMaskWidth/Height/Reflect/ValueByHandle` walks with `curRow±1/curCol±1` neighbour tests); `misc.script:4646-4706` (`w/h` + `GetGameObjectCollisionMaskValueByHandle(buildHnd,i,j)` + `GetMapCollisionTagInRadius(x+i*0.5+0.25, y+j*0.5+0.25, 0, true)` per-cell tests); cell stride `0.5` matches `gc_collision_size` [D].

Rotation [O-in-samples]: every sampled building mask block inherits `Rotate=0, Reflect=False, tmoRotate=False, tmoScale=False`. No per-sid `Rotate` override was observed in `algcen/eurmil/eursto/eurmar/eurtow/eurswa_gate/eurswa`. `DefaultRollAngle` (45/135/0) lives in `directionupproperty` (visual yaw), not in `collisionmaskproperty`. Static verdict for samples: **no mask rotation/mirror is applied**; the bitmap is stamped axis-aligned, centred per `sub_755168`.
Full-close recipe [U]: one grep for `Rotate = [1-9]` / `Reflect = True` / `tmoRotate = True` across the 369 files (§9). Until that scan is recorded, rotation stays `[U] U12-rot` for the unscanned files, with capture C-CAP-1 as terminator (place `algcen` roll-135 vs `eurswa_gate` roll-0; any orientation-dependent bitmap difference fails the capture).

---

## 6. Inertia numeric [O-text] / engine integration [U]

Text [O] (`ev_c875…`, `dmscript.global:969-974`): `gc_collision_mass_default = 1; gc_collision_mass_stand = 1.5; gc_collision_mass_attack = 3; gc_collision_radius_default = 0.16; gc_collision_radius_stand = 0.1; gc_collision_radius_attack = 0.1`.

Class rows [O] (`refunit.prop` carried + `refbuilding.prop ev_ae79…`): both `CIMass=1`, `CIIntersectRadius=0.16`, `CIMaxDistKoef=2`, `CIDeltaStep=0.005`, `CIRotationSpeed=5`, `CIStuckAngle=5`, `CIEpsilonAngle=4`, `CIEpsilonShift=0.001`, `CIEpsilonMove=0.02`, `CIDistExtPointEpsilon=0.005`, `CIAvoidPointMaxAngle=60`, `CIMaxCollideCounter=7`; units `CIEnabled/Movable=True`, buildings `False/False`; both `UncollideDelta=0.05`.

Callers [O] (`unit.script:11155-11170` shell read): on `iAction=build` + `GetGameObjectCIMovable` → `SetGameObjectCIMovable(False)` + `SetGameObjectCIIntersectRadiusByHandle(hnd, gc_collision_radius_default*0)`; when leaving build and not movable → `SetGameObjectCIMovable(True)` + `SetGameObjectCIIntersectRadiusByHandle(hnd, gc_collision_radius_default)`. So the mobile CI radius is exactly `0.16`, immobilised-build CI radius is exactly `0.0` [D].

Binary [O] (P1/P4): `3XCollisionInertia` exists at `0x95972b` with 0 static xrefs (`ev_ada2…`). Engine-side mass/stand/attack switching is **[U] U-inertia**: the `stand/attack` mass/radius rows have no sampled script consumer; capture is runtime (two units shoving; log separation vs mass rows) — out of placement scope, recorded here so no port `LIFE`-style invention fills it.

---

## 7. LOS / `OctreeRayCast` / `ctpo` operand semantics

### 7.1 LOS surface [O] (all donor text)

- Projectile LOS (`D:scripts/misc/projectile.inc/nothing.inc:55-56` shell read): `var rayCast := OctreeRayCastIntersect(trgHnd, sx,sy,sz, dx,dy,dz, px,py,pz, nx,ny,nz)` (12 floats: origin, direction, hit, normal) with the `OctreeRayCastIntersectChildren` variant present but commented out. `dst := VectorDistance(sx,sy,sz, px,py,pz); if dst<2` branch follows.
- Mouse pick (`control.script:150-200` + `:286-300` shell reads): `GameObjectRayCastMouseRay; GameObjectSortRayCastList; … prio := 0.5; if playable∧visible∧collision-detection ∧ GetGameObjectRayCastAABBByHandle(goHnd, cPos…, mPos…) then nearest by _misc_GetDistancePos` (+ res-type prio overrides after).
- Scan-grid LOS march (`misc.script:2281-2360`, `ev_f385…`): per-cell `GetGameObjectRayCastAABBByHandle` or `GetGameObjectRayCastCustAABBByHandle(…, aabb.min…, aabb.max…)` when `gCustomObjPoints[cid][id].aabb.buse`; `tmpy := 0.05` clamp when `y<0.05` (donor comment: AABB call returns wrong result for `y<0`).
- Toggles/precision [O]: `SetGameObjectRayCastIntersectEnabledByHandle(goHnd, True)` (`unit.script:11805`); disable path `player.script:509` (carried); `SetTerrainRayCastPrecison(0.0000001)` (`init.script:101` carried); `RayCastHeight/RayCastWater` height reads (`unit.script:6336-6337/7550-7551/8495-8496` shell grep [O]).
- Raycast flags in props [O]: `RayCastIntersect=False`, `RayCastUsingTLF=False`, `UseCameraCollision=False`, `BVRayCastIntersect=False` in refunit/refbuilding (`ev_ae79…`); per-sid overrides none sampled.

### 7.2 Implementation + `ctpo` semantics [U]

- Binary: 0 `OctreeRayCast`/`RayCast` strings (P1), 0 static xrefs for all three `XCollision*` classes (P4), CODE `ctpoEqual` bytes are the P5 false positives. Argument types (target handle vs origin/dir vs hit/normal), return convention, and engine-side `ctpoEqual/ctpoGreater` comparison are **[U] U13-impl**.
- Text constants [O]: `dmscript.global:94-95` shell read: `gc_TestPriorityOption_Water = 'ctpoEqual'; gc_TestPriorityOption_Land = 'ctpoGreater'`; tags `:84-92` (`ev_fc13…` region): `none=0/bridge=10/building=80/terrain=101/water=87/waterborder=110/landborder=109/stretchland=85/wall=95`. Ref props set `TestTypeOption=cttoNone`, `TestPriorityOption=ctpoNever` (`ev_ae79…`). Which engine call consumes `ctpoEqual/ctpoGreater` per call site is unproven — capture C-CAP-4.
- `_misc_CircleIntersectRect` (`misc.script:2384+` shell read) is the clamped-point circle-vs-cell test (corner `(x-x1)²+(y-y1)²≤r²`, edge `|y1-y|≤r`, inside `True`) used by `_misc_MakeScanCellsList` (`:2493`) — it is **not** the footprint test [O] (re-affirmed).

---

## 8. Exact port change list (`data.gd` / `game.gd`; specify-only, no edit)

Conventions: port site [O] with as-read line; donor fact [O]/[D] from this job; replacement names the algorithm. Line numbers are provenance-only — IMPL-COLLISION-CALLERS is concurrently editing both files (per `DEC_U_skirmish_impl_patch.md` §8 + task brief), so re-anchor by **function name + verbatim text**. Zero port edits were made by this worker.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement (no parity claim) |
|---|---|---|---|
| C1 | `P:data.gd:584-1143` per-unit `"radius"` values (`0.35/0.5/0.6/0.55…`); `:1156` naval comment; `:1163` header note | §1.3 table [O px + D m]: default 0.375; horse/artillery 0.5625; ships 1.5/2.625/1.3125/1.875/1.6875/3.0/3.375/3.0/3.375; formation 0.30/0.45 defined-but-unconsumed | Store single-source per-sid metres from §1.3 keyed by donor sid (ship overrides nested per §1.3 nesting rule); keep the current minimum-ship floor only as labelled placeholder until this lands. No other value changed |
| C2 | `P:data.gd:1243-1298` `BUILDINGS_BASE` `"radius"` (footprint estimates 1.0-3.0) | §2.3 bitmaps + §3 AABBs/scales [O]: radii-as-discs do not exist in donor placement for buildings | Replace disc with `(nation,sid)→{w,h,rows[],aabb,scale,roll}` export from §2 (all 369 files; 15 mask-less flagged per §2.4b); keep `radius` column only where the sim (non-placement) needs a scalar, labelled estimate until then |
| C3 | `P:game.gd:477-490` `set_blocked_circle(p, r_m, value)` (disc stamp) | `gc_collision_size=0.5` (`ev_fc13…`); centred write `sub_755168/764e04` (`ev_8655…`); per-cell test `x+i*0.5+0.25` (`misc.script:4677/4706` shell [O]) | Stamp the §2 bitmap centred per `(W-1)>>1` (§5), stride 0.5, via `set_blocked_tile`; keep disc only for units (no mask, §2.2) + resource nodes. Rotation stays identity per §5 samples |
| C4 | `P:game.gd:492-506` `bld_rect_cells` + `1505-1560` `bld_block_r/bld_block_rect/pick_radius` (`+1.4` grab) + `2041-2060` place-building `block_r/block_rect` + `1552-1553` `_unblock_building` + `2070-2071` `_default_rally` | Mask bitmaps [O] §2.3; `SelectionSize` unit 0.5 / building 1 (`refunit:331`, `refbuilding` selection block `ev_ae79…` region); AABB per §3 [O] | Build occupancy from the bitmap set (C3); `pick_radius` from `SelectionSize`/AABB chain per prior `ev_9aee…` eligibility (carried), not `+1.4`; `_default_rally` offset from bitmap extent + 2.0 m stays labelled until rally TTL art lands (U14, other worker) |
| C5 | `P:game.gd:462-476` `is_blocked` / water=`terrain==3` check | Tags [O] §7.2: `water=87/waterborder=110/landborder=109/stretchland=85/bridge=10/building=80/terrain=101/wall=95`; `ctpoEqual/ctpoGreater` constants (`dmscript.global:94-95` shell [O]) | Read donor collision tags incl. border/stretch; implement land/water/border tests with the `ctpo` priority pair once C-CAP-4 types the engine call; until then label water handling port-local |
| C6 | `P:data.gd:16-18` `PX_TO_M/TILE_M` + `FRAMES_TO_TIME` | Conversions [O] `ev_fc13…`: `26.6666666 / 2 / 53.3333333 / 0.03125` | Already donor-derived; no change. Radii conversions in C1 must use `26.6666666` (px→m), never the port's estimated `TILE` |
| C7 | `P:game.gd:1942-1947` `set_blocked_tile` | Bounds-checked cell write mirrors `sub_764e04` [O] (`ev_8655…`) | Keep; route C3 through it so `nav_version` bumps identically |

Required donor asset manifest (sourced through approved converters, **not copied here**): all `D:objects/buildings/*.prop` (369: 354 bitmaps + 15 mask-less) + `D:objects/units/*.prop` (140, AABB/scale/CI inheritance) + `D:objects/ref/{refunit,refbuilding,refunithorse,refenv,refmisc,refmountain,refproj}.prop` + `D:objects/env,misc` (decor masks incl. `misdecor*`) + `D:scripts/{dmscript.global,lib/unit.script,lib/group.script,lib/squad.script,lib/control.script,lib/misc.script,lib/init.script,misc/projectile.inc/nothing.inc}` + `D:game/var/formations.cfg`.

---

## 9. Provenance appendix + recipes to close the [U]s (read-only)

Donor text reads in this job: `dmscript.global` ×3 (`ev_fc13…`, `ev_4fef…`, `ev_c875…`), `refbuilding.prop` (`ev_ae79…`), `algcen.prop` (`ev_21bc…`), `misc.script` LOS window (`ev_f385…`); shell (read-only `Get-Content`/`Select-String`, no execution of donor binaries): unit/group/squad/control/init scripts, formations.cfg, 369+140 prop census, per-sid AABB/scale/mask samples. Binary: P1-P5 table (§0.1) with VAs `0x9589c7/0x958a13/0x95972b` (`.rsrc`), CODE `0x5dcdc3/0x5dcebc/0x5dd005/0x5dd10a` + `0x84981e/0x849f20` (false positives, discarded), funcs `0x755168/0x764e04/0x7550f8/0x75505c`.

Mechanical recipes (no binary needed): (i) `Select-String 'objprop\.radius :=' D:scripts/lib/unit.script` → every override vs §1.3 (closes U12-ships-a); (ii) dump `(nation,sid)→(w,h)` + `Rotate/Reflect/tmoRotate` for all 369 building props (closes U12-mask-a/c); (iii) `Select-String 'formations.cfg' id` full count + `squad.script` slot-offset read (closes U12-form partly).

---

## 10. Fixed-camera placement / route captures (zero-mismatch termination)

All captures: singleplayer skirmish, fixed map seed, fixed camera (position/yaw/pitch/fov logged + capture id). **Termination rule: 0 mismatched cells/rows across the stated matrix; first mismatch stops the run and is filed with its capture id — never overridden by a port fallback.**

- **C-CAP-1 mask origin/rotation:** surveyed flat cell; place `eurmil` (5×5), `eurtow` (5×5), `eursto` (5×7), `eurmar` (11×15), `algcen` (11×12, even width), `eurswa_gate` (2×2, roll 0) each at 4 rotations of the building yaw + one mask-less sid (`algsta`). Dump occupancy rows in a `(w+4)×(h+4)` window. Pass = centred-`sub_755168` prediction matches all cells, all placements, 0 mismatches (even-width bias confirmed on `algcen`).
- **C-CAP-2 ship radii:** per ship sid (§1.3), sail a straight lane past a surveyed 1-cell gap at fixed speed; log first-contact vs pass-through frame. Pass = contact order matches radius order `35<40<45<50<70<80<90` px with 0 inversions across all 9 sids × 3 trials.
- **C-CAP-3 formation slots:** `LINE3/LINE8/LINE3PUS` squads of foot then horse; log slot world offsets vs `unitRadius*0.8/dispRadius` law + mask gating. Pass = 0 slot mismatches; decides whether 8/12 px play any role.
- **C-CAP-4 LOS/ctpo:** unit behind wall vs ridge vs open water; call `OctreeRayCastIntersect` + `GetGameObjectRayCastAABBByHandle` pairwise, toggle `SetGameObjectRayCastIntersectEnabledByHandle` + `SetTerrainRayCastPrecison`; log `(hit, px,py,pz, nx,ny,nz)`. Pass = typed signature + `ctpoEqual/ctpoGreater` truth table with log ids.

---

## 11. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | px radii + conversions (§1.3) are donor-exact per cited constants/branches; metre column is exact arithmetic | [O] `ev_4fef…/ev_fc13…` + branch lines; [D] divisions |
| 2 | `SetObjectCollisionRadius`/`DefaultRadius` have no binary string and no sampled text key; the donor surface is `gc_obj_radius_*` + `objprop.radius` + `SetGameObjectCIIntersectRadiusByHandle` | [O] `ev_bd93…/ev_7820…` + §1.1 sites |
| 3 | 354/369 building props carry own bitmaps (histogram §2.2); 15 named files do not; 0/140 unit props do | [O] shell census §2.2 |
| 4 | §2.3 verbatim bitmaps/AABBs/scales/rolls are donor-exact per cited prop lines | [O] this § + `ev_21bc…` |
| 5 | Mask write/read is centred (`(W-1)>>1`, `+0xa8` table, `+0x65` gate, `+0x1c` occupant) | [O] `ev_8655…` |
| 6 | No mask rotation in sampled files (`Rotate=0/tmoRotate=False`); full-file scan still open | [O] samples `ev_ae79…` + shell; [U] U12-rot for unscanned files |
| 7 | Formation 8/12 px defined but commented out at the sampled consumer; live pitch is `unitRadius*0.8/*0.5` + mask gating | [O] `ev_4fef…` + `group.script:122-160` |
| 8 | Inertia numerics (`1/1.5/3`, `0.16/0.1/0.1`, full CI block, `0.0`-on-build rule) are donor-exact text | [O] `ev_c875…/ev_ae79…` + `unit.script:11163-11169` |
| 9 | LOS call shapes + `ctpo` constants + tag values are donor-exact text; engine comparison semantics unrecovered | [O] §7.1 sites; [U] U13-impl |
| 10 | CODE `XCollisionTags/ctpoEqual` bytes are `0x58` false positives outside discovered functions | [D] `ev_61c7…/ev_ca88…` |
| 11 | Port differs at §8 sites; each has a donor-faithful replacement algorithm; `game.gd/data.gd` rows are specified, not edited | [O] port lines + donor facts |
| 12 | Every [U] has a mechanical recipe or a zero-mismatch capture (C-CAP-1..4); none is closed by a port fallback | [D] this report |
| 13 | Any port visual equals donor motion/occlusion/FX | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 12. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned; global target untouched) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-COLLISION-FULL.*
