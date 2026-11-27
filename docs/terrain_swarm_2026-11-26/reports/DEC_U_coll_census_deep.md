---
id: DEC-U-COLL-CENSUS-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-COLL-CENSUS-DEEP — class-B static angle from PORT1TO1_u_classify.md: E-COLL census (full 369-file mechanical enumeration, packed CODE byte search, renderer+0x40 registration-site inspection)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_coll_census_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only text/byte/VA/decomp observation; every port statement is a read-only source line. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only; network/multiplayer/lobby/Steam/replay-sync explicitly OUT OF SCOPE."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every Craft Anything call in THIS job passed document=t_87f0f3c130b0 explicitly; global active target was already t_87f0f3c130b0 and was never changed."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_collision_full.md (§0-§10, 27 radii, 354/369 census, centred origin, inertia text; this job closes its U12-mask-a/c rotation scan and re-tests its P5 false-positive verdict on new VAs)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.3 B8 E-COLL, §4 B8 exact next angle)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_gen_seed.md (§3.3 renderer+0x40 installer, indirect +0x0b copy [U] with write-break probe)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_alpha_pass_quad.md (§6 0x48→0x50 +0x0b map, §U10b copy-site resolution task)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (P4 centred primitives, carried)
---

# DEC-U — collision census deep (full 369-file enumeration, CODE byte search, renderer+0x40 registration sites)

> READ-ONLY. No approximation. Each `[U]` ends in a named capture/probe, never in a port fallback.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary VA / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only donor tree). `P:` = workspace `app\scripts\`. `c3` = `t_87f0f3c130b0`.
- `ev_*` = Craft Anything evidence id of a pass in **this** job (all `document=t_87f0f3c130b0` for binary calls, or donor text paths for file reads). `ev(carried)` = id from a prior worker, re-cited not re-run.
- Census method (read-only, no binary executed): Python `re.findall(r'\[\*\]\s*=\s*([01]+)')` per file over `D:objects/buildings/*.prop` (369) and `D:objects/units/*.prop` (140); `W` = first-row length, `H` = row count, `ragged` = >1 distinct row length. Rotation scan: whole-file substring search for `Rotate|Reflect|tmoRotate|tmoScale|coTest|coWrite|TestTypeOption|TestPriorityOption|ScaleFactor` in all 369 building files.

### 0.1 Pass ledger (pin `t_87f0f3c130b0`, multiple passes; strange-decomp log inline)

| Pass | Operation | Evidence | Result |
|---|---|---|---|
| P1 | shell census: 369 building + 140 unit prop files; per-file `(W,H,ragged)` | shell (read-only `Get-Content`/regex; commands in §8 provenance) | [O] 354 with Mask rows, 15 without (§1); 0 ragged; 0/140 units with rows (§1) |
| P2 | rotation/transform scan: 9 keys × 369 building files, whole-file | shell | [O] 0 files contain any of `Rotate/Reflect/tmoRotate/tmoScale/coTest/coWrite/TestTypeOption/TestPriorityOption/ScaleFactor`; 362 contain `Mask` (§3) |
| P3 | alias-stub read: 7 `alg*` + 1 `misdecor1` full heads | shell | [O] 7 stubs (`mainproperty` only + top-level `refurl=tur*.prop`); 8 `misdecor*` carry an **empty** `Mask` struct (§1) |
| P4 | `native_bytes_find` `collisionmaskproperty` | `ev_2ef1346a…` | [O] ×0 in `c3` (neither utf8 nor utf16le) |
| P5 | `native_bytes_find` `CollisionTags` / `ctpoEqual` / `ctpoGreater` / `XCollisionInertia` | `ev_dcb496ca…` / `ev_657b7e…` / `ev_24c81869…` / `ev_ba727b61…` | [O] Tags ×5 (4 CODE + 1 `.rsrc`); `ctpoEqual` ×2 CODE; `ctpoGreater` ×2 CODE (new vs prior); `XCollisionInertia` ×2 (1 CODE `0x82b9f2` + 1 `.rsrc` `0x95972c`) |
| P6 | `native_bytes_find` `TXCollisionMask` / `CollisionMaskProperty` / `3XCollisionMask`; `native_strings_find` `ctpo` | `ev_051dc981…` / `ev_681f6142…` / `ev_31a759b1…` / `ev_73520ec2…` | [O] `TXCollisionMask` ×4 CODE; `CollisionMaskProperty` ×4 CODE; `3XCollisionMask` ×0; `ctpo` ×0 data-section strings |
| P7 | `native_instruction_show` + `native_function_find` on all P5/P6 CODE VAs (12 sites) | `ev_2f46f708…`, `ev_f18af24e…`, `ev_2cbd6eff…`, `ev_f2c41acd…`, `ev_17669dee…`, `ev_ce156c57…`, `ev_b1b70c67…`, `ev_11dbaf7a…`, `ev_c0276565…`, `ev_d75c89fa…`, `ev_e5e29783…`, `ev_8fa44560…`, `ev_ece1c21d…` + finds `ev_caf0f744…`/`ev_d76d9014…`/`ev_1142a8d…`/`ev_03f4cc4b…`/`ev_4c8c8d79…`/`ev_6d56bd7b…`/`ev_20cc673a…`/`ev_2c31f2cc…`/`ev_e4c1cb28…` | [O] all decode as 1–4 B fragments of ASCII (`inc ebx` on `C`, `arpl` on `ctpo`, `push esp` on `T`); 2 sites inside discovered functions are pre-code metadata prefixes (proof §4) |
| P8 | `native_bytes_show` contexts `0x5dd0e0`, `0x82b9c0`, `0x8497e0`, `0x849ef0`, `0x8371e0` (96–160 B) | `ev_c0fc1a69…`, `ev_8ffb263f…`, `ev_3cabb4b9…`, `ev_9fd80135…`, `ev_c6ddb113…` | [O] Pascal-string enum/class metadata tables (§4); [D] call-site verdict: discarded |
| P9 | `native_function_disassemble 0x8177f0` (129 insn) | `ev_9ce28a17…` (re-observed, identical to `ev(carried)` from `DEC_U_gen_seed.md` §3) | [O] renderer slots `+0x48/+0x4c`, `+0x40/+0x44`; collision writers absent (§5) |
| P10 | `native_xrefs_list` `0x755168/0x764e04/0x7550f8/0x75505c/0x755f30` + `native_bytes_find` `68 51 75 00` (LE of `0x755168`) | `ev_0ab62c1a…`, `ev_968a643c…`, `ev_5bf022a5…`, `ev_50ed90e7…`, `ev_db2dd583…`, `ev_0c351335…` | [O] collision writers called **directly** from `sub_755f30` only; 0 registration-table stores; `sub_755f30` has 5 direct callers (§5) |
| P11 | `native_xrefs_list` `0x9589c7/0x958a13/0x95972b` (re-run) | same ids as prior `ev_13ed9a5b…`/`ev_11fbcded…`/`ev_ada22e94…` | [O] 0 static xrefs each — reproduced exactly |
| P12 | `native_strings_find` `collisionmaskproperty` / `XCollisionInertia` / `ctpoGreater` | `ev_2ef1346a…`(P4 twin) / `ev_22d2f941…` / `ev_3a354aa9…` | [O] maskproperty ×0; Inertia ×1 (`.rsrc` only); `ctpoGreater` ×0 data-section (CODE bytes only, P5) |
| P13 | refunit/unit census re-check | shell | [O] 0/140 unit props carry `[01]` rows; `refunit.prop` mask `Enabled=False`, `tmoRotate=True` (§1) |

**Strange-decomp log (required):** two CODE string VAs sit *inside* discovered functions (`0x5dd10b` in `sub_5dd038+0xd3`, `0x839048` in `sub_83876c+0x8dc`, `0x849983` in `sub_849924+0x5f`), which initially looked like promotion of the prior false-positive verdict. Per-byte `instruction_show` + 96–160 B `bytes_show` windows prove all three are **Pascal-string metadata prefixes before real code**: `0x5dd0e0` reads `TXAngleCollisionTagCollection … XCollisionTags … FileName` with the function body starting at `0x5dd13c` (`lea eax,[eax]; push ebx…`, preceded by ~0x100 B of `insb/outsb/arpl` garbage-decode); `0x8371e0` reads pointer-table + `TXCollisionMaskProperty` Pascal pairs; single-byte decodes (`inc ebx` = `C`, `push esp` = `T`, `arpl` = `ctpo`) are the ASCII-misdecode signature. Verdict unchanged and now stronger: **discarded as call sites [D]**, kept as packed script/RTTI constants. No branch polarity or caller was guessed.

---

## 1. Full 369-file census [O] (mechanical, §8 recipe)

- `D:objects/buildings/*.prop` = **369 files**: **354 carry `[*] = [01]` Mask rows; 15 do not**; **0 ragged** (every multi-row file is rectangular).
- The 15 mask-less files split into two mechanical classes:
  - **7 alias stubs** (no `collisionmaskproperty` section at all, `mainproperty`-only + top-level `{refurl=.\data\objects\buildings\tur*.prop}`): `algaca→turaca`, `algart→turart`, `algbar→turbar`, `algbla→turbla`, `algdip→turdip`, `algsta→tursta`, `algtem→turtem`. [D] At runtime these inherit the whole `tur*` record (including its Mask, e.g. `tursta` 13×14 diamond, `turaca` 5×6) *if* the engine follows the top-level `refurl` chain — the chain-following itself is **[U]** (capture C-CAP-1 in `DEC_U_collision_full.md` §10 already places `algsta`; no new capture needed).
  - **8 empty-Mask files**: `misdecor1…misdecor8` carry `collisionmaskproperty → Priority = 101 → Mask : struct.begin / struct.end` with **zero** `[*]` rows (sample `misdecor1.prop` [O] P3). Donor placement for these has no bitmap to stamp — capture C-CAP-1 covers (`algsta` is a stub; a `misdecor*` placement proves the empty-Mask path).
- `D:objects/units/*.prop` = **140 files, 0 carry `[01]` rows** (reproduced). `refunit.prop`: `collisionmaskproperty … Enabled = False … tmoRotate = True` ([O] P13) — note `tmoRotate=True` differs from `refbuilding` (`False`), but with `Enabled=False` and no Mask rows it is moot for placement; recorded so no worker "fixes" a difference that has no effect.
- 362/369 building files contain the substring `Mask` (354 with rows + 8 empty structs); the 7 stubs contain no `Mask` token at all [O] (P2).

### 1.1 Dimension histogram (H×W = rows × width, counts sum to 354) [O]

| dim | n | dim | n | dim | n |
|---|---|---|---|---|---|
| 2×2 | 62 | 4×4 | 45 | 11×12 | 24 |
| 9×10 | 20 | 13×14 | 17 | 12×12 | 15 |
| 10×10 | 10 | 15×16 | 10 | 9×12 | 10 |
| 10×12 | 10 | 10×8 | 9 | 8×8 | 8 |
| 7×10 | 7 | 11×10 | 6 | 7×6 | 6 |
| 11×14 | 5 | 7×8 | 5 | 14×14 | 5 |
| 8×10 | 4 | 7×12 | 4 | 13×12 | 4 |
| 6×2 | 4 | 2×6 | 4 | 17×18 | 4 |
| 8×12 | 3 | 12×14 | 3 | 8×6 | 3 |
| 11×11 | 2 | 15×14 | 2 | 15×12 | 2 |
| 8×14 | 2 | 9×14 | 2 | 13×16 | 2 |
| 19×20 | 2 | 5×5 | 2 | 5×7 | 2 |
| 9×8 | 2 | 6×8 | 2 | 14×12 | 2 |
| 10×14 | 1 | 11×15 | 1 | 11×16 | 1 |
| 7×11 | 1 | 9×11 | 1 | 14×15 | 1 |
| 14×16 | 1 | 17×16 | 1 | 14×18 | 1 |
| 15×18 | 1 | 19×18 | 1 | 21×18 | 1 |
| 19×22 | 1 | 4×2 | 1 | 3×5 | 1 |
| 3×6 | 1 | 5×6 | 1 | 5×8 | 1 |
| 16×8 | 1 | 16×12 | 1 | 13×13 | 1 |
| 14×13 | 1 | 10×11 | 1 | | |

Row reads `H×W: n` with `H` = row count, `W` = first-row length (all files rectangular, so `W` is exact). This histogram reproduces `DEC_U_collision_full.md` §2.2 exactly (same 62/45/20/… distribution); the two jobs used independent regex runs over the same 369 files.

Largest bitmaps [O]: `ukrtem` 19×22, `ukrpor` 21×18, `spatem`/`ventem` 19×20, `rustem` 19×18. Smallest: 62 files at 2×2 (all `11/11`), 4 files at 4×4 diagonal variants (`eurswa_03/04` etc.), 4 files at 6×2 / 4 at 2×6 (gate-tooth `sga_14/15` family).

### 1.2 Full per-file dump (354 files; `W` = width, `H` = row count; rows verbatim, `1` = blocked) [O]

`FILE:<name> W=<w> H=<h> :: <row1>|<row2>|…` (Appendix A). The 15 mask-less files of §1 head the appendix. Consuming worker: key by **filename** (nation+sid), not by game sid — `algcen` ≠ `ausaca` ≠ `ukrcen` (11×12 vs 13×14 vs 15×16).

---

## 2. Per-sid mask origin/rotation: full-file close [O]

- **Rotation: CLOSED statically for all 369 files.** Whole-file scan (P2): 0/369 building files contain `Rotate`, `Reflect`, `tmoRotate`, `tmoScale`, `coTest`, `coWrite`, `TestTypeOption`, `TestPriorityOption`, or `ScaleFactor` anywhere (not only in the mask section). Every per-sid file therefore inherits the `refbuilding.prop` mask-layer defaults (`ev(carried)` `ev_ae79…`: `Rotate=0`, `ScaleFactor=1`, `Reflect=False`, `tmoScale/tmoRotate=False`, `coTest/coWrite=True`, `cttoNone/ctpoNever`). **No mask rotation/mirror/scale applies to any of the 369 building masks** [O over all files; the U12-rot scan recipe of `DEC_U_collision_full.md` §9 is now executed and closed]. `DefaultRollAngle` (45/135/0) lives in `directionupproperty` (visual yaw), not in `collisionmaskproperty` — unchanged.
- **Origin: centred write [O] (carried + re-cited).** `sub_755168` adds `(W-1)>>1/(H-1)>>1` before `sub_764e04`; `sub_7550f8/75505c` test `-W/2..+W/2` then add back `W>>1/H>>1` (`ev(carried)` `ev_8655…`). Even-width bias by `>>1` truncation [D] — observable in the dump: 2×2, 4×4, 6×8 etc. bitmaps (§1.1) stamp with the documented off-by-truncation centre.
- Per-sid mask origin/rotation is therefore **fully typed statically**: origin = centred `sub_755168`, rotation = identity for all 369. What remains is the *copy-site* question of §5 (the terrain-mesh 0x48→0x50 `+0x0b` copy, which is a different subsystem), **not** the mask transform.

---

## 3. Packed CODE byte search: full table + verdicts

All searches `document=t_87f0f3c130b0`, both utf8+utf16le for `text`, both file-bytes and data-section strings where applicable.

| # | Query | Kind | Hits (VA, section) | Per-site decode [O] | Verdict |
|---|---|---|---|---|---|
| 1 | `collisionmaskproperty` | bytes | ×0 | — | [O] no packed occurrence; class name lives only in `.prop` text + RTTI-adjacent `CollisionMaskProperty` (row 6) |
| 2 | `CollisionTags` | bytes | ×5: `0x5dcdc4/0x5dcebd/0x5dd006/0x5dd10b` CODE + `0x958a14` `.rsrc` | `0x5dcdc4/0x5dcebd/0x5dd006`: `inc ebx` (`0x43`=`C`), outside any discovered function (`ev_caf0f744…` for `0x5dcdc4`); `0x5dd10b`: `inc ebx` inside `sub_5dd038+0xd3`, but `0x5dd0e0` window reads `TXAngleCollisionTagCollection … XCollisionTags … FileName` Pascal metadata with real code starting `0x5dd13c` | [D] all 4 CODE hits are packed script/class metadata, discarded as call sites (prior verdict reproduced + strengthened: the in-function site is a metadata prefix, not code) |
| 3 | `ctpoEqual` | bytes | ×2 CODE: `0x84981e/0x849f20` | `arpl [eax+esi*2+0x6f],si` (`63 70 6f` = `ctp`), outside any discovered function (`ev_1142a8d…/ev_03f4cc4b…`) | [D] discarded; `0x8497e0` window (§3.1) shows the true context: length-prefixed enum table |
| 4 | `ctpoGreater` | bytes | ×2 CODE: `0x849833/0x849f48` (**new**: prior job never searched it) | `arpl …` same signature; outside any discovered function (`ev_4c8c8d79…/ev_6d56bd7b…`) | [D] discarded, same class as row 3 |
| 5 | `XCollisionInertia` | bytes | ×2: `0x82b9f2` CODE + `0x95972c` `.rsrc` | `0x82b9f2`: `pop eax` (`0x58`=`X`), outside any discovered function (`ev_d76d9014…`); `0x82b9c0` window: float-table prefix + `TXCollisionInertia` Pascal string + RTTI-ish trailer | [D] CODE hit is class-metadata, discarded as call site; `.rsrc` hit is the Delphi class name |
| 6 | `TXCollisionMask` | bytes | ×4 CODE: `0x837205/0x837222/0x849983/0x84999a` | `0x837205/0x849983`: `push esp` (`0x54`=`T`); `0x837222`: same class; two sites inside discovered functions (`0x839048`→`sub_83876c+0x8dc`, `0x849983`→`sub_849924+0x5f`) but decoding ASCII bytes | [D] discarded; `0x8371e0` window shows pointer-table + `TXCollisionMaskProperty` Pascal pairs = property-registration metadata |
| 7 | `CollisionMaskProperty` | bytes | ×4 CODE: `0x837207/0x837224/0x839048/0x83b344` | `inc ebx` (`C`); `0x839048`/`0x83b344` same signature | [D] discarded, same metadata class as row 6 |
| 8 | `ctpo` | data-section strings | ×0 | — | [O] no data-section string; `ctpo*` lives only in CODE-region packed enum tables (rows 3–4), hence invisible to string-only sweeps |
| 9 | `XCollisionInertia` / `ctpoGreater` / `collisionmaskproperty` | data-section strings | 1 / 0 / 0 | Inertia hit = `0x95972c` `.rsrc` (`3XCollisionInertia`) | [O] confirms rows 1/4/5 section placement |
| 10 | `XCollision*` classes | xrefs | `0x9589c7/0x958a13/0x95972c`: 0 static xrefs each (re-run, same evidence ids as prior) | — | [O] reproduced: RTTI resolves at runtime, no static caller |

### 3.1 Enum/class metadata typing [O/D]

- `0x8497e0` (160 B, `ev_3cabb4b9…`): `…yOption … ctpoNever ctpoAlways ctpoLess ctpoLequal ctpoEqual ctpoGequal ctpoGreater ctpoNotEqual … XCollisionMask … TXCollisionTestUnitOption` — length-prefixed Pascal strings: the **`TestPriorityOption` enum table** (`09 ctpoEqual`, `0b ctpoGreater` length bytes visible). Values per `dmscript.global:84-95` (carried): `none=0/bridge=10/building=80/terrain=101/water=87/waterborder=110/landborder=109/stretchland=85/wall=95`; `gc_TestPriorityOption_Water='ctpoEqual'`, `Land='ctpoGreater'`.
- `0x849ef0` (96 B, `ev_9fd80135…`): `FFFFFFFF 08 ctpoLess … FFFFFFFF 0A ctpoLequal … FFFFFFFF 09 ctpoEqual … FFFFFFFF 0A ctpoGequal … FFFFFFFF 0B ctpoGrea…` — the same enum with `FFFFFFFF` ordinal tags: **engine-side comparison-operand table layout**, values still untyped ([U] §6).
- `0x82b9c0` (96 B, `ev_8ffb263f…`): float triple + `12 TXCollisionInertia` + `90 53 84 …` trailer: **inertia class descriptor prefix**. No vtable/method layout recovered — engine inertia RTTI stays [U] (§6).
- LOS/engine-call typing stays exactly where `DEC_U_collision_full.md` §7 left it: call shapes [O] text, argument/return/consumer semantics [U].

---

## 4. Centred-write registration sites vs renderer+0x40: statically DISJOINT [O/D]; copy site NOT closed [U]

### 4.1 `sub_8177f0` installer (re-observed, `ev_9ce28a17…`, 129 insn) [O]

Three slot pairs, selected by word-gates, then consumer chain `0x81ac98 → 0x81ae94/0x81aeac → 0x818920`:

- `[eax+0x48]/[eax+0x4c]` ← `edx=[ebx+0xb8]/[ebx+0xbc]` passthrough, else `0x8185c0` / `0x818554` (`0x817841/0x817868/0x81787a`);
- `[eax+0x40]/[eax+0x44]` ← `edx=[ebx+0xb0]/[ebx+0xb4]` passthrough, else `ebx` + **`0x812e34`** (`0x81789d/0x8178b1/0x8178b4`).

The `+0x40` slot receives **only** terrain-producer addresses (`0x812e34` default, `0x818554/0x8185c0` siblings, or passthrough) — never a collision address.

### 4.2 Collision centred-write fan-in (new xrefs, this job) [O]

- `sub_755168` ← 2 direct calls from `sub_755f30` (`0x756392`, `0x7563b8`); → `sub_764e04` (`0x75519a`) (`ev_0ab62c1a…`, `ev_968a643c…` carried-shape).
- `sub_7550f8` ← 4 calls, `sub_75505c` ← 4 calls, all from `sub_755f30` (`0x756bae…0x756c60`) (`ev_5bf022a5…`, `ev_50ed90e7…`).
- `sub_764e04` ← 5 calls: 4 from `sub_73c330` + 1 from `sub_755168` — i.e. the row-table writer is shared by a second (map-fill) path, both direct `call`s.
- `sub_755f30` ← 5 direct callers: `sub_6b2b58`, `sub_723748` ×2, `sub_75c228`, `sub_75c1fc` (`ev_db2dd583…`).
- `native_bytes_find 68 51 75 00` (LE `0x755168`): **×0** (`ev_0c351335…`) — no callback-registration table stores the centred-write address anywhere in the image.

### 4.3 Verdict [D] + remaining [U]

The 0x48→0x50 indirect `+0x0b` copy (`DEC_U_alpha_pass_quad.md` §6.4: producer UV `+0x05…+0x44` → consumer UV `+0x10…+0x4f`, 16-byte index header) lives on the **renderer mesh path** (`0x8177f0` installs `0x812e34`; `0x818920` consumes). The collision centred-write path (`sub_755f30 → 755168/7550f8/75505c → 764e04`) is invoked by **direct calls only**, with no registration table and no `renderer+0x40` dispatch anywhere on it. The two subsystems are **statically disjoint**: the `+0x0b` copy source is **not reachable from any centred-write registration site**, because there is no registration site — and it is not the copy that moves collision bytes (collision bytes are written cell-by-cell by `sub_764e04`, proven by the `+0xa8` row-table store, `ev(carried)`).

Per the task rule ("only if byte-proven, close the copy site"): the byte proof goes the other way — **the copy site is NOT closed**. It stays **[U] U-copy-site** with the exact experiment below (inherited from `DEC_U_gen_seed.md` §3.3, restated so this report is self-contained):

- **[U] U-copy-site (write-breakpoint byte-dump, owner trace only):** break on write to `renderer+0x40` at `0x8178b4` (default path), then break on the first indirect call through that slot during a cell build; single-step the callee's copy loop and record `(src_off → dst_off)` for all 0x40 UV bytes. Terminate when every `+0x05…+0x44 → +0x10…+0x4f` byte is mapped with zero gaps AND the four `+0x00…+0x0c` index words are shown written from the vertex-index source. Until then the port keeps the §6.4 field map as a labelled transport, never a claimed copy site. (Terrain-mesh scope; collision placement does not depend on it.)

---

## 5. What this closes / what stays [U]

Closed by this job (static):

- **U12-mask-a** (`DEC_U_collision_full.md` §2.4): full 369-file `(file→W×H+rows)` dump — Appendix A. CLOSED-STATIC.
- **U12-mask-c / U12-rot**: `Rotate`/`Reflect`/`tmoRotate` full-file scan — 0 overrides in 369 files; identity rotation for every building mask. CLOSED-STATIC (behavioural confirmation still rides C-CAP-1, which needs no new design).
- **P5-verdict extension**: `ctpoGreater`, `XCollisionInertia`-CODE, `TXCollisionMask`, `CollisionMaskProperty` CODE hits classified as packed metadata, same false-positive class as prior `XCollisionTags`/`ctpoEqual`. CLOSED-STATIC (as negatives).
- **B8 registration-site sweep** (`PORT1TO1_u_classify.md` §4 B8, second half): `renderer+0x40` installer re-read + full collision-writer xref fan-in + LE-address registration sweep — disjointness proven. CLOSED-STATIC (as a negative: no site exists).

Still [U] (each with its terminator; none is closed by a port fallback):

- **U-copy-site**: §4.3 write-break byte-dump (owner trace; workers forbidden).
- **U12-ships / U12-form** (`DEC_U_collision_full.md` §§1.4/4): untouched by this job — recipes stand (`objprop.radius` grep; `squad.script` slot read) + C-CAP-2/3.
- **U-inertia-engine**: mass/stand/attack switching + `XCollisionInertia` method layout — no static caller/table recovered; runtime shove-log capture owns it.
- **U13-impl (LOS/`ctpo` consumer)**: enum tables typed as data (§3.1) but the engine call consuming `ctpoEqual/ctpoGreater` per call site unproven; C-CAP-4 owns it.
- **Mask-less runtime semantics**: 7 stubs inherit `tur*` rows *if* the top-level `refurl` chain is followed ([D] over file text, chain-following unproven); 8 `misdecor*` have no rows at all. C-CAP-1 (`algsta` + one `misdecor*` placement, zero-mismatch window) terminates both.

---

## 6. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | 369 building files: 354 with Mask rows, 15 without (7 alias stubs + 8 empty-Mask), 0 ragged; 0/140 unit files with rows | [O] P1/P3/P13, Appendix A |
| 2 | Histogram (§1.1) reproduces `DEC_U_collision_full.md` §2.2 exactly | [O] this job (independent regex run) |
| 3 | 0/369 files contain any mask transform/option key; rotation = identity for every building mask | [O] P2 (whole-file scan) |
| 4 | Mask write/read is centred (`(W-1)>>1`, `+0xa8` table, `+0x65` gate, `+0x1c` occupant) | [O] `ev(carried)` + P10 fan-in |
| 5 | 12 CODE string VAs are packed metadata, not call sites (single-byte ASCII decodes + Pascal-table windows) | [D] P5–P8 |
| 6 | `renderer+0x40` installs only terrain producers; collision writers are direct-called; LE-address registration sweep ×0 — subsystems disjoint, copy site NOT closed | [O] P9/P10; [D] §4.3 |
| 7 | Inertia numerics (`1/1.5/3`, `0.16/0.1/0.1`, CI block, `0.0`-on-build) are donor-exact text | [O] `ev(carried)` (untouched, re-cited) |
| 8 | Any port visual equals donor motion/occlusion/FX | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |
| 9 | Every [U] has a mechanical recipe or a zero-mismatch capture/probe; none is closed by a port fallback | [D] §5 |

## 7. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned; global target untouched) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

---

## 8. Provenance appendix

Shell census (read-only; PowerShell `py -3` stdlib only, no donor execution):

1. `Get-ChildItem D:objects/buildings/*.prop` (count 369) / `units/*.prop` (count 140); `cossacks.exe` length 5768048.
2. Per-file `re.findall(r'\[\*\]\s*=\s*([01]+)')` → `(W=len(row0), H=len(rows), ragged=len(set(map(len,rows)))>1)` → `coll_census.txt` (369 lines); bitmaps → `coll_bitmaps.txt`; compact `FILE:W:H :: r1|r2|…` → `coll_compact.txt` (Appendix A source; temp files only, not repo).
3. Whole-file key scan for `Rotate/Reflect/tmoRotate/tmoScale/coTest/coWrite/TestTypeOption/TestPriorityOption/ScaleFactor/Mask` over 369 files; stub-head reads for the 15 mask-less files.

Binary (all `document=t_87f0f3c130b0`): P4–P12 table (§0.1) with VAs `0x9589c7/0x958a13/0x95972b` (`.rsrc`), CODE `0x5dcdc4/0x5dcebd/0x5dd006/0x5dd10b`, `0x84981e/0x849f20/0x849833/0x849f48`, `0x82b9f2`, `0x837205/0x837222/0x839048/0x83b344/0x849983/0x84999a`, contexts `0x5dd0e0/0x82b9c0/0x8497e0/0x849ef0/0x8371e0`, installer `0x8177f0`, writers `0x755168/0x764e04/0x7550f8/0x75505c/0x755f30`, LE-pattern `68 51 75 00`.

---

## Appendix A — full mask dump [O]

15 mask-less files: `algaca, algart, algbar, algbla, algdip, algsta, algtem` stubs (7, §1) + `misdecor1…misdecor8` empty-Mask (8).

`FILE:<name> W=<width> H=<rows> :: <row1>|<row2>|…` (`H×W` dim = rows × width):

```text
FILE:algcen.prop W=12 H=11 ok :: 000000011000|000000111100|000001111110|000011111111|000111111111|001111111110|011111111100|011111111000|011111110000|001111100000|000000000000
FILE:alghou.prop W=10 H=9 ok :: 0000011000|0000111110|0001111111|0011111111|0011111111|0011111110|0001111100|0000111000|0000000000
FILE:ausaca.prop W=14 H=13 ok :: 00001000000000|00011100000000|00111110000000|01111111000000|00111111100000|00011111110000|00001111111000|00000111111100|00000011111110|00000001111111|00000000111110|00000000011100|00000000001000
FILE:ausart.prop W=14 H=13 ok :: 00000001100000|00000011110000|00000111111000|00001111111100|00011111111110|00111111111111|00011111111111|00001111111110|00000111111100|00000011000000|00000000000000|00000000000000|00000000000000
FILE:ausba2.prop W=16 H=17 ok :: 0000000000000000|0000000000000000|0000001110000000|0000011111000000|0000111111100000|0001111111110000|0011111111111000|0111111111111100|0111111111111110|0111111111111111|0011111111111110|0011111111111100|0001111111111000|0000111111110000|0000011111100000|0000000111000000|0000000000000000
FILE:ausbar.prop W=13 H=14 ok :: 0000000000000|0000011100000|0000111110000|0001111110000|0011111111000|0111111111100|1111111111110|1111111111111|0111111111110|0011111111100|0000111111000|0000011110000|0000011100000|0000000000000
FILE:ausbla.prop W=12 H=7 ok :: 000000111000|000001111110|000111111111|001111111110|001111111100|000011110000|000001100000
FILE:auscen.prop W=14 H=11 ok :: 00000111000000|00001111100000|00011111110000|00111111111000|01111111111100|01111111111110|00111111111111|00011111111110|00000111111100|00000000110000|00000000000000
FILE:ausdip.prop W=14 H=13 ok :: 00000000000000|00000001100000|00000011100000|00000111110000|00001111111110|00011111111111|00111111111110|00111111111100|00011111111000|00001111110000|00001111100000|00001111000000|00000110000000
FILE:aushou.prop W=10 H=7 ok :: 0000110000|0001111000|0011111100|0111111111|0011111110|0001111100|0000000000
FILE:aussta.prop W=14 H=9 ok :: 00000000110000|00001111111000|00011111111100|00111111111110|01111111111111|00111111111111|00011111111100|00000000111000|00000000000000
FILE:austem.prop W=18 H=15 ok :: 000000000000000000|000000000000000000|000001111111110000|000001111111110000|000011111111111000|000011111111111000|000111111111111100|000111111111111110|000011111111111111|000011111111111110|000011111111111100|000011111111111000|000001111111110000|000000001111100000|000000000111000000
FILE:bavaca.prop W=14 H=11 ok :: 00000111111000|00001111111100|00011111111110|00111111111111|01111111111110|01111111111100|00111110000000|00011100000000|00001000000000|00000000000000|00000000000000
FILE:bavart.prop W=14 H=9 ok :: 00000000111000|00000001111100|00000011111111|00000111111111|00001111111111|00011111111110|00011111111000|00001111110000|00000110000000
FILE:bavba2.prop W=12 H=11 ok :: 000000111000|000001111000|000011111100|000111111110|001111111111|011111111111|111111111000|111111110000|011111100000|001111100000|000011100000
FILE:bavbar.prop W=12 H=11 ok :: 000011000000|000111100000|001111100000|011111100000|111111100000|011111111110|001111111111|000111111111|000011111110|000001111100|000000111000
FILE:bavbla.prop W=10 H=7 ok :: 0000111100|0001111100|0011111111|0111111111|0011111100|0001111000|0000110000
FILE:bavcen.prop W=12 H=11 ok :: 000110000000|001111000000|011111100000|111111110000|011111111000|001111111110|000111111110|000011111100|000001111000|000000110000|000000000000
FILE:bavdip.prop W=10 H=9 ok :: 0000011100|0000111110|0001111111|0011111111|0111111110|0111111100|0111111000|0011110000|0001100000
FILE:bavhou.prop W=12 H=7 ok :: 000111100000|001111111100|001111111110|001111111111|000110000110|000000000000|000000000000
FILE:bavsta.prop W=12 H=9 ok :: 000000111100|000001111110|000011111111|011111111110|111111111100|111111111100|011111111000|001111110000|000011000000
FILE:bavtem.prop W=12 H=11 ok :: 001110000000|011111000000|011111100000|001111111110|001111111111|000111111111|000011111111|000011111111|000011111111|000011111111|000011111110
FILE:denaca.prop W=10 H=8 ok :: 0001100000|0011111100|0111111100|0111111100|0011111110|0011111111|0001111111|0000001110
FILE:denart.prop W=14 H=8 ok :: 00000011110000|00000111111000|00000111111100|00001111111110|00111111111111|00011111111110|00001111111100|00000110000000
FILE:denba2.prop W=12 H=12 ok :: 000000000000|000000001100|000000011110|000000111111|000001111111|000011111111|000111111110|001111111000|011111110000|011111100000|001111100000|000111000000
FILE:denbar.prop W=14 H=8 ok :: 00000111000000|00001111100000|00011111110000|00011111111111|00111111111111|00111111111110|00011111111000|00001111110000
FILE:denbla.prop W=12 H=10 ok :: 000000000000|000000000000|000000000000|000000010000|000000111000|000001111110|000011111111|000111111110|000001111100|000000011000
FILE:dencen.prop W=12 H=10 ok :: 000000000000|000000011000|000000111100|000001111111|000011111110|000111111100|011111111000|001111110000|000111100000|000011000000
FILE:dendip.prop W=12 H=10 ok :: 000000011000|000000111100|000001111110|000011111111|000111111110|001111111100|011111111100|001111110000|000111110000|000011000000
FILE:denhou.prop W=8 H=8 ok :: 00000000|00000000|00001100|00011110|00111111|01111111|00111100|00011000
FILE:densta.prop W=12 H=12 ok :: 000000000000|000000000000|000000110000|000001111000|000011111100|000111111110|001111111111|001111111111|000111111110|000011111100|000001111000|000000110000
FILE:dentem.prop W=12 H=12 ok :: 000000000000|000001100000|000011111000|000011111100|000111111110|001111111110|011111111111|011111111111|001111111110|000111111000|000011110000|000001100000
FILE:engaca.prop W=12 H=11 ok :: 001111000000|011111100000|111111110000|011111111000|011111111100|001111111110|000111111110|000011111111|000001111111|000000111111|000000001110
FILE:engart.prop W=12 H=11 ok :: 000000010000|000000111000|000001111100|000011111110|000111111111|011111111111|111111111111|011111111110|000001111100|000000111000|000000000000
FILE:engba2.prop W=12 H=11 ok :: 000000011100|000000111110|000001111111|000011111110|000111111100|001111111100|011111111000|111111110000|011111100000|001111000000|000110000000
FILE:engbar.prop W=12 H=11 ok :: 000011100000|000111110000|001111111000|111111111100|011111111110|001111111111|000111111111|000011111111|000001111110|000001111100|000000000000
FILE:engbla.prop W=11 H=7 ok :: 00000110000|00001111100|00111111110|01111111110|00111111100|00011111000|00000110000
FILE:engcen.prop W=14 H=13 ok :: 00000111100000|00001111110000|00011111111000|00111111111100|01111111111100|11111111111100|11111111111100|01111111111100|00111111111100|00011111111100|00001111111000|00000000000000|00000000000000
FILE:engdip.prop W=10 H=7 ok :: 0000011100|0000111110|0001111111|0011111110|0111111110|0011111100|0001111000
FILE:enghou.prop W=10 H=7 ok :: 0000011000|0000111100|0001111110|0011111111|0011111110|0001111100|0000111000
FILE:engsta.prop W=12 H=11 ok :: 000001110000|000011111000|000111111100|001111111110|011111111111|011111111111|001111111111|000111111110|000011111100|000001111000|000000110000
FILE:engtem.prop W=12 H=13 ok :: 000000000000|000000001100|000011111110|000111111111|000111111111|001111111111|011111111111|111111111111|111111111110|111111111100|011111111000|001111100000|000111000000
FILE:eurcoa.prop W=8 H=10 ok :: 00000000|00111100|01111110|11111111|11111111|11111111|11111111|01111110|00111100|00000000
FILE:eurgol.prop W=8 H=10 ok :: 00000000|00111100|01111110|11111111|11111111|11111111|11111111|01111110|00111100|00000000
FILE:euriro.prop W=8 H=10 ok :: 00000000|00111100|01111110|11111111|11111111|11111111|11111111|01111110|00111100|00000000
FILE:eurmar.prop W=15 H=11 ok :: 000000000110000|000001111111000|000011111111100|000111111111110|011111111111110|111111111111100|011111111111000|001111111100000|000011111000000|000001110000000|000000100000000
FILE:eurmil.prop W=5 H=5 ok :: 00100|01110|11111|01110|00100
FILE:eurpor.prop W=18 H=17 ok :: 000000000000000000|000000000111100000|000000001111110000|000000011111110000|000000111111111000|000000111111111110|000000111111111111|000001111111111111|000011111111111110|000011111111111100|000011111111111000|000001111111110000|000000011111100000|000000001111100000|000000001111100000|000000000111100000|000000000011000000
FILE:eursga.prop W=6 H=7 ok :: 001100|011110|111111|111111|111111|011110|001100
FILE:eursga_14.prop W=6 H=2 ok :: 100001|100001
FILE:eursga_15.prop W=2 H=6 ok :: 11|00|00|00|00|11
FILE:eursga_16.prop W=8 H=8 ok :: 00000111|00000111|00000011|00000001|11000000|11100000|11110000|11110000
FILE:eursga_17.prop W=8 H=10 ok :: 00000000|11110000|11110000|11100000|11000000|00000000|00000011|00000111|00000111|00000111
FILE:eursto.prop W=7 H=5 ok :: 0000000|0000010|1100010|0000010|0000000
FILE:eurswa.prop W=2 H=2 ok :: 11|11
FILE:eurswa_01.prop W=2 H=2 ok :: 11|11
FILE:eurswa_02.prop W=2 H=2 ok :: 11|11
FILE:eurswa_03.prop W=4 H=4 ok :: 0010|0111|1110|0100
FILE:eurswa_04.prop W=4 H=4 ok :: 0100|1110|0111|0010
FILE:eurswa_05.prop W=2 H=2 ok :: 11|11
FILE:eurswa_06.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:eurswa_07.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:eurswa_08.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:eurswa_09.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:eurswa_10.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:eurswa_11.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:eurswa_12.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:eurswa_13.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:eurswa_45gate.prop W=2 H=2 ok :: 11|11
FILE:eurswa_45v1.prop W=2 H=2 ok :: 11|11
FILE:eurswa_45v2.prop W=2 H=2 ok :: 11|11
FILE:eurswa_gate.prop W=2 H=2 ok :: 11|11
FILE:eurswa_tower.prop W=2 H=2 ok :: 11|11
FILE:eurswa_turn.prop W=2 H=2 ok :: 11|11
FILE:eurswa_turnmirror.prop W=2 H=2 ok :: 11|11
FILE:eurswa_v1.prop W=2 H=2 ok :: 11|11
FILE:eurswa_v2.prop W=2 H=2 ok :: 11|11
FILE:eurtow.prop W=5 H=5 ok :: 01110|11111|11111|11111|01110
FILE:eurwga.prop W=6 H=7 ok :: 001100|011110|111111|111111|111111|011110|001100
FILE:eurwwa.prop W=6 H=7 ok :: 001100|011110|111111|111111|111111|011110|001100
FILE:fraaca.prop W=14 H=11 ok :: 00011100000000|00111110000000|01111111000000|00111111100000|00011111110000|00001111111000|00000111111100|00000011111110|00000001111111|00000000111110|00000000011100
FILE:fraart.prop W=16 H=15 ok :: 0000000000000000|0000000000000000|0000000000000000|0000000011000000|0000000111100000|0000001111110000|0000011111111000|0000111111111110|0000111111111111|0000011111111111|0000011111111110|0000001111111000|0000001111110000|0000001111110000|0000000001100000
FILE:fraba2.prop W=16 H=15 ok :: 0000000000000000|0000000111000000|0000001111100000|0000011111110000|0000111111111000|0001111111111100|0011111111111110|0111111111111111|0011111111111110|0001111111111100|0000111111111000|0000011111110000|0000001111100000|0000000111000000|0000000010000000
FILE:frabar.prop W=10 H=7 ok :: 0000011100|0000111110|0001111111|0011111110|0111111100|0011111000|0001110000
FILE:frabla.prop W=8 H=9 ok :: 00000000|00000000|00001100|00011110|00111111|00111110|00011100|00001100|00001000
FILE:fracen.prop W=16 H=15 ok :: 0000000000000000|0000000000000000|0000000111000000|0000001111100000|0000011111111110|0000111111111111|0001111111111111|0011111111111111|0001111111111110|0000111111111100|0000011111111000|0000011111110000|0000011111100000|0000011111000000|0000001110000000
FILE:fradip.prop W=10 H=9 ok :: 0000001110|0000011111|0000111111|0001111111|0011111110|0111111100|0111111000|0111110000|0011100000
FILE:frahou.prop W=6 H=7 ok :: 000000|000110|001111|011111|011110|001100|000000
FILE:frasta.prop W=12 H=11 ok :: 000011100000|000111110000|001111111000|011111111100|011111111110|011111111111|001111111111|000111111111|000011111110|000001111100|000000111000
FILE:fratem.prop W=16 H=15 ok :: 0011111000000000|0111111100000000|0111111110000000|0111111111000000|0111111111100000|0111111111110000|0011111111111000|0001111111111100|0000111111111110|0000011111111111|0000001111111111|0000000111111110|0000000011111100|0000000001111000|0000000000110000
FILE:g_45left.prop W=2 H=2 ok :: 11|11
FILE:g_45right.prop W=2 H=2 ok :: 11|11
FILE:hunaca.prop W=10 H=10 ok :: 0000000000|0000011100|0000111110|0001111111|0011111111|0111111111|1111111110|0111111100|0011111000|0001110000
FILE:hunart.prop W=12 H=8 ok :: 000001110000|000011111100|000111111110|001111111111|001111111111|000111111110|000011111100|000001111000
FILE:hunba2.prop W=14 H=14 ok :: 00000000000000|00000001100000|00000011110000|00000111111000|00001111111100|00011111111110|00111111111111|01111111111111|01111111111111|00111111111110|00011111111000|00001111110000|00000111110000|00000011100000
FILE:hunbar.prop W=12 H=12 ok :: 000000000000|000000110000|000001111000|000111111100|001111111100|011111111110|011111111111|001111111111|000111111110|000011111100|000001111000|000000110000
FILE:hunbla.prop W=6 H=8 ok :: 000000|001100|011110|111111|111111|011111|001110|001100
FILE:huncen.prop W=12 H=12 ok :: 000000000000|000001100000|000011110000|000111111100|001111111110|011111111111|011111111111|001111111110|000111111100|000111111000|000011110000|000001100000
FILE:hundip.prop W=10 H=10 ok :: 0000000000|0000001100|0000111110|0001111111|0011111111|0011111111|0111111110|0111111100|0011111000|0001110000
FILE:hunhou.prop W=8 H=8 ok :: 00000000|00011000|00111100|01111110|00111111|00011111|00011110|00001100
FILE:hunsta.prop W=10 H=10 ok :: 0000000000|0000111000|0001111100|0011111110|0111111111|1111111111|0111111111|0011111110|0001111100|0000111000
FILE:huntem.prop W=14 H=14 ok :: 00000001000000|00000011100000|00000111110000|00001111111000|00011111111100|00111111111110|01111111111111|11111111111111|11111111111110|01111111111100|00111111111000|00011111111000|00001111110000|00000111000000
FILE:misblg.prop W=12 H=10 ok :: 000000000000|000000000000|000011100000|000111110000|000111111000|000011111100|000001111110|000000111110|000000011100|000000001000
FILE:misblg2.prop W=8 H=10 ok :: 00000000|00000000|00000100|00001110|00011111|00111111|01111110|11111100|01111000|00110000
FILE:misbridge1.prop W=2 H=2 ok :: 11|11
FILE:misbridge1a.prop W=2 H=2 ok :: 11|11
FILE:misbridge2.prop W=2 H=2 ok :: 11|11
FILE:misbridge2a.prop W=2 H=2 ok :: 11|11
FILE:misbridge3.prop W=2 H=2 ok :: 11|11
FILE:misbridge3a.prop W=2 H=2 ok :: 11|11
FILE:misbridge4.prop W=2 H=2 ok :: 11|11
FILE:misbridge4a.prop W=2 H=2 ok :: 11|11
FILE:miscauldron.prop W=4 H=4 ok :: 0000|0000|0011|0010
FILE:mischest1.prop W=4 H=4 ok :: 0010|0010|0110|0000
FILE:mischest2.prop W=4 H=4 ok :: 0000|0000|0011|0001
FILE:miscommandcenter.prop W=18 H=14 ok :: 000000000000000000|000000000100000000|000000001100000000|000000011100000000|000011111111100000|001111111111110000|111111111111111000|111111111111111000|111111111111111000|011111111111111110|001111111111111111|000111111111111111|000000000000011110|000000000000001100
FILE:mistent.prop W=12 H=10 ok :: 000000000100|000000001110|000000011111|000000111111|111111111110|011111111100|001111111000|000111110000|000000000000|000000000000
FILE:miswel1.prop W=4 H=4 ok :: 0000|0000|0011|0011
FILE:miswel2.prop W=4 H=4 ok :: 0000|0000|0111|0111
FILE:miswel3.prop W=2 H=4 ok :: 00|01|11|10
FILE:misyurt.prop W=8 H=10 ok :: 00000000|00000000|00001100|00011110|00111111|00111111|00111111|00011110|00001100|00000100
FILE:netaca.prop W=10 H=10 ok :: 0000000000|0000100000|0001110000|0011111000|0111111100|0011111110|0001111111|0000111110|0000011100|0000001000
FILE:netart.prop W=12 H=10 ok :: 000001111000|000011111100|000111111110|011111111111|001111111111|001111111111|000111111110|000011100000|000001100000|000000000000
FILE:netba2.prop W=12 H=10 ok :: 000000011100|000000111110|000001111111|000011111111|000111111110|001111111110|011111111100|011111111000|011111110000|001111100000
FILE:netbar.prop W=12 H=10 ok :: 000000000000|000000011110|000000111110|000001111110|000011111110|111111111110|111111111100|011111111100|001111111100|000111111000
FILE:netbla.prop W=8 H=6 ok :: 00111111|11111111|11111111|01111111|01111111|00000100
FILE:netcen.prop W=12 H=10 ok :: 000000000000|000000000000|000001111110|000011111111|000111111110|000111111100|001111111000|011111110000|001111000000|000110000000
FILE:netdip.prop W=10 H=10 ok :: 0000000000|0000001100|0000011110|0000111111|0001111111|0011111110|0111111100|0111111000|0011110000|0001100000
FILE:nethou.prop W=8 H=8 ok :: 00000000|00000000|00001100|00011110|00111111|01111111|00111110|00011100
FILE:netsta.prop W=10 H=10 ok :: 0000000000|0000111000|0001111100|0011111110|0111111111|1111111111|1111111111|0011111110|0001000000|0000000000
FILE:nettem.prop W=12 H=12 ok :: 000000000000|000000000000|000001111000|000011111100|000111111110|000111111110|011111111110|111111111110|011111111100|001111111000|000111100000|000011000000
FILE:pieaca.prop W=12 H=12 ok :: 000000000000|000000001000|000000011100|000000111110|000001111111|000011111111|000111111111|001111111111|011111111111|001111111111|000111111111|000001111110
FILE:pieart.prop W=12 H=8 ok :: 000011100000|000111110000|111111111000|111111111100|111111111110|011111111110|001111111100|000111111000
FILE:pieba2.prop W=12 H=12 ok :: 000000000000|000000010000|000000111000|000001111100|000011111110|000111111111|001111111111|011111111110|001111111100|000111111000|000011110000|000001100000
FILE:piebar.prop W=14 H=12 ok :: 00000010000000|00000111000000|00001111100000|00011111110000|00111111111000|00011111111100|00001111111110|00000111111111|00000011111110|00000001111100|00000000111000|00000000010000
FILE:piebla.prop W=10 H=8 ok :: 0000010000|0000111100|0011111110|0111111111|0111111111|0011111110|0001111000|0000000000
FILE:piecen.prop W=14 H=14 ok :: 00000000000000|00000000000000|00000000011000|00000000111111|00000001111111|00000011111110|00000111111100|00001111111000|00011111110000|00111111100000|00111111000000|00011110000000|00011100000000|00011000000000
FILE:piedip.prop W=8 H=8 ok :: 00000100|00001110|00011111|00111111|01111111|11111110|01111100|00111000
FILE:piehou.prop W=6 H=8 ok :: 000000|000100|001110|011111|111111|111110|011110|001100
FILE:piesta.prop W=12 H=16 ok :: 000000000000|000000000000|000000000000|000000000000|000001100000|000011110000|000111111000|001111111100|011111111110|111111111111|111111111110|011111111100|001111111000|000111110000|000011100000|000001000000
FILE:pietem.prop W=12 H=12 ok :: 000000000000|000000000000|000111110000|001111111000|001111111100|001111111110|001111111111|001111111110|000111111100|000011111000|000001110000|000000100000
FILE:polaca.prop W=11 H=11 ok :: 00000000000|00000110000|00001111000|00011111100|01111111110|01111111110|01111111100|00111111000|00011110000|00001110000|00000000000
FILE:polart.prop W=10 H=11 ok :: 0011110000|0111111000|0111111100|1111111111|1111111111|1111111111|1111111110|0011111100|0000111000|0000000000|0000000000
FILE:polba2.prop W=14 H=14 ok :: 00000000000000|00000000000000|00000111000000|00001111100000|00011111110000|00111111111000|01111111111100|01111111111110|00111111111111|00011111111110|00000111111100|00000111111000|00000011110000|00000001000000
FILE:polbar.prop W=15 H=14 ok :: 000000000000000|000001110000000|000011111100000|000011111110000|000111111111000|000111111111100|001111111111110|011111111111111|011111111111111|001111111111110|000111111111100|000011111111000|000001111110000|000000001100000
FILE:polbla.prop W=11 H=9 ok :: 00000000000|00000011000|00111111100|01111111110|11111111110|01111111100|00111111000|00011110000|00001100000
FILE:polcen.prop W=11 H=10 ok :: 00000000000|00001100000|00011110000|00111111000|01111111110|01111111110|00111111110|00011111100|00001111000|00001110000
FILE:poldip.prop W=10 H=9 ok :: 0001110000|0011111000|0011111100|0011111110|0011111111|0001111111|0000111111|0000001110|0000000000
FILE:polhou.prop W=10 H=8 ok :: 0000000000|0001100000|0011111100|0111111111|1111111111|0111111111|0011111110|0001111100
FILE:polsta.prop W=16 H=15 ok :: 0000000000000000|0000000000000000|0000111110000000|0001111111000000|0001111111100000|0001111111110000|0000111111111000|0000011111111110|0000001111111111|0000000111111111|0000000111111110|0000000111111100|0000000111111000|0000000011110000|0000000001100000
FILE:poltem.prop W=11 H=11 ok :: 00011111000|00111111100|01111111100|11111111100|11111111110|11111111111|11111111111|11111111111|01111111110|00111111100|00000111000
FILE:poraca.prop W=10 H=10 ok :: 0000000000|0000000000|0000011110|0000111111|0001111111|0011111110|0011111100|0011111000|0011110000|0001100000
FILE:porart.prop W=12 H=10 ok :: 000001000000|000011100000|000111110000|001111111000|011111111111|111111111111|011111111111|001111111110|000111000000|000010000000
FILE:porba2.prop W=12 H=14 ok :: 000000000000|000000000000|000000011000|000001111000|000111111100|001111111100|011111111110|111111111111|111111111111|111111111110|011111111000|001111110000|000111100000|000011000000
FILE:porbar.prop W=12 H=12 ok :: 000000000000|000001100000|000011110000|000111111000|001111111100|011111111110|011111111111|001111111111|000111111110|000011111100|000011111000|000001110000
FILE:porbla.prop W=10 H=8 ok :: 0000000000|0000000000|0000111111|0011111111|0111111110|0111111100|0011110000|0001100000
FILE:porcen.prop W=14 H=10 ok :: 00000011110000|00000111111000|00001111111100|00011111111110|00001111111111|00000111111111|00000011111110|00000001111100|00000000111000|00000000010000
FILE:pordip.prop W=10 H=10 ok :: 0000010000|0000111000|0001111100|0011111110|0111111110|1111111110|1111111110|0111111110|0011111100|0000000000
FILE:porhou.prop W=6 H=8 ok :: 000000|000100|001111|011111|111111|111110|011100|001000
FILE:porpor.prop W=12 H=14 ok :: 000000000000|000000000000|000000000000|000011110000|000111111000|001111111100|001111111110|001111111110|011111111110|011111111110|011111111100|001111111000|000111111000|000000110000
FILE:porsta.prop W=14 H=12 ok :: 00000000000000|00000011100000|00000111110000|00001111111000|00011111111100|00111111111110|01111111111111|00111111111110|00011111111100|00001111100000|00000111000000|00000011000000
FILE:portem.prop W=16 H=14 ok :: 0000001110000000|0000001111110000|0000000111111000|0000000111111100|0000001111111110|0000011111111110|0000111111111110|0000111111111111|0000011111111111|0000001111100011|0000000111000000|0000000000000000|0000000000000000|0000000000000000
FILE:pruaca.prop W=10 H=9 ok :: 0000011100|0000111111|0001111111|0011111111|0111111110|1111111100|0111111000|0011110000|0000000000
FILE:pruart.prop W=12 H=11 ok :: 000001100000|000011110000|000111111000|001111111100|011111111110|011111111111|001111111111|000111111110|000011111000|000001110000|000000100000
FILE:pruba2.prop W=14 H=13 ok :: 00000000000000|00000000000000|00000111111000|00001111111100|00011111111100|00011111111110|00011111111110|00011111111111|00011111111111|00011111111111|00001111111110|00000000111100|00000000011000
FILE:prubar.prop W=10 H=9 ok :: 0000001100|0000011110|0000111111|0001111111|0011111111|0111111110|0111111100|0111111000|0011110000
FILE:prubla.prop W=10 H=7 ok :: 0000000000|0000011100|0000111110|0001111111|0011111110|0001111100|0000110000
FILE:prucen.prop W=10 H=11 ok :: 0000001100|0000011110|0000111111|0001111111|0011111111|0111111111|1111111111|1111111110|0111111100|0011111000|0000000000
FILE:prudip.prop W=12 H=9 ok :: 000111000000|001111110000|001111111000|000111111100|000111111110|000011111111|000001111111|000000011110|000000001100
FILE:pruhou.prop W=8 H=7 ok :: 00000000|00011100|00111110|00111111|00111111|00011110|00001100
FILE:prusta.prop W=10 H=11 ok :: 0000000000|0000011110|0000111111|0001111111|0011111111|0111111110|0111111110|0111111100|0011111000|0011110000|0001100000
FILE:prutem.prop W=14 H=15 ok :: 00000000000000|00000000000000|00000000011000|00000011111100|00000111111110|00001111111111|00011111111111|00011111111110|00111111111110|00111111111100|00111111111100|00011111111000|00001111111000|00000011110000|00000001100000
FILE:rusaca.prop W=12 H=15 ok :: 000000000000|000000000000|000111000000|001111100000|011111110000|111111111000|011111111100|001111111110|000111111110|000011111110|000001111110|000000111110|000000011111|000000001111|000000000111
FILE:rusart.prop W=16 H=11 ok :: 0000001100000000|0000011110000000|0000111111000000|0001111111111000|0011111111111110|0001111111111111|0000111111111111|0000011111111100|0000001111000000|0000000110000000|0000000000000000
FILE:rusba2.prop W=18 H=17 ok :: 000000000100000000|000000001110000000|000000011111000000|000000111111100000|000001111111110000|000011111111111000|000111111111111100|001111111111111110|000111111111111111|000011111111111110|000011111111111100|000011111111111000|000001111111110000|000000001111100000|000000000111000000|000000000010000000|000000000000000000
FILE:rusbar.prop W=12 H=13 ok :: 000000011000|000000111100|000001111110|000011111111|000011111111|000111111110|001111111100|011111111000|011111110000|011111110000|001111100000|000110000000|000000000000
FILE:rusbla.prop W=12 H=7 ok :: 000001100000|000011110000|000111111100|000111111110|000111111110|000011111100|000001110000
FILE:ruscen.prop W=12 H=15 ok :: 000000000000|000000000000|000001110000|000011111000|000111111100|001111111110|011111111100|111111111000|111111111000|011111111000|001111111000|000111111000|000011111000|000001110000|000000100000
FILE:rusdip.prop W=10 H=11 ok :: 0000001000|0000011100|0000111110|0001111110|0011111110|0111111110|1111111110|1111111100|0111111000|0000000000|0000000000
FILE:rushou.prop W=10 H=9 ok :: 0000000000|0001100000|0011111100|0111111110|0111111111|0011111111|0001111110|0000111100|0000011000
FILE:rusmar.prop W=12 H=13 ok :: 000001100000|000011110000|000111111000|001111111100|011111111110|111111111110|111111111110|111111111000|011111110000|011111100000|001111000000|000110000000|000000000000
FILE:rusmil.prop W=6 H=3 ok :: 001110|001111|001111
FILE:ruspor.prop W=16 H=15 ok :: 0000000000000000|0000001111100000|0000001111110000|0000111111111000|0001111111111100|0011111111111110|0011111111111111|0011111111111111|0011111111111111|0011111111111111|0000011111111100|0000001111111000|0000000111110000|0000000011100000|0000000000000000
FILE:russga_14.prop W=6 H=2 ok :: 100001|100001
FILE:russga_15.prop W=2 H=6 ok :: 11|00|00|00|00|11
FILE:russga_16.prop W=8 H=8 ok :: 00000111|00000111|00000011|00000001|11000000|11100000|11110000|11110000
FILE:russga_17.prop W=8 H=10 ok :: 00000000|11110000|11110000|11100000|11000000|00000000|00000011|00000111|00000111|00000111
FILE:russta.prop W=12 H=11 ok :: 000001110000|000011111000|000111111100|001111111110|011111111111|011111111111|011111111111|001111111110|000111111100|000011110000|000001100000
FILE:russto.prop W=5 H=3 ok :: 10001|10001|00001
FILE:russwa.prop W=2 H=2 ok :: 11|11
FILE:russwa_01.prop W=2 H=2 ok :: 11|11
FILE:russwa_02.prop W=2 H=2 ok :: 11|11
FILE:russwa_03.prop W=4 H=4 ok :: 0010|0111|1110|0100
FILE:russwa_04.prop W=4 H=4 ok :: 0100|1110|0111|0010
FILE:russwa_05.prop W=2 H=2 ok :: 11|11
FILE:russwa_06.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:russwa_07.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:russwa_08.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:russwa_09.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:russwa_10.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:russwa_11.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:russwa_12.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:russwa_13.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:russwa_45gate.prop W=2 H=2 ok :: 11|11
FILE:russwa_45v1.prop W=2 H=2 ok :: 11|11
FILE:russwa_45v2.prop W=2 H=2 ok :: 11|11
FILE:russwa_gate.prop W=2 H=2 ok :: 11|11
FILE:russwa_tower.prop W=2 H=2 ok :: 11|11
FILE:russwa_turn.prop W=2 H=2 ok :: 11|11
FILE:russwa_turnmirror.prop W=2 H=2 ok :: 11|11
FILE:russwa_v1.prop W=2 H=2 ok :: 11|11
FILE:russwa_v2.prop W=2 H=2 ok :: 11|11
FILE:rustem.prop W=18 H=19 ok :: 000000000000000000|000000000000000000|000000000000000000|000000000000000000|000001111111110000|000011111111111000|011111111111111000|111111111111111000|111111111111111000|011111111111111100|001111111111111100|000111111111111100|000011111111111000|000011111111111000|000001111111111000|000000011111110000|000000001111100000|000000000111100000|000000000011000000
FILE:rustow.prop W=6 H=7 ok :: 000000|001110|011111|011111|011111|001110|000000
FILE:saxaca.prop W=10 H=9 ok :: 0000111000|0001111100|0011111110|0111111111|1111111111|0111111111|0011111100|0001111000|0000111000
FILE:saxart.prop W=10 H=9 ok :: 0000111000|0001111100|0011111110|0111111111|1111111111|0111111110|0011111100|0001111000|0000110000
FILE:saxba2.prop W=12 H=9 ok :: 000001111000|000011111110|000111111111|001111111110|011111111100|001111111100|000111110000|000111110000|000111000000
FILE:saxbar.prop W=10 H=11 ok :: 0000001110|0000011111|0000111111|0001111111|0011111111|0111111111|1111111110|1111111100|1111111000|1111100000|0000000000
FILE:saxbla.prop W=10 H=9 ok :: 0000011000|0000111100|0001111110|0011111111|0011111110|0001111100|0000000000|0000000000|0000000000
FILE:saxcen.prop W=12 H=11 ok :: 000001100000|000011110000|000111111000|001111111100|011111111110|011111111111|011111111111|001111111110|000011110000|000001110000|000000000000
FILE:saxdip.prop W=10 H=9 ok :: 0000001100|0000011110|0000111110|0001111110|0011111100|0111111000|0111110000|0111100000|0011000000
FILE:saxhou.prop W=8 H=7 ok :: 00001100|00011110|00111111|01111111|00111111|00011110|00000000
FILE:saxsta.prop W=10 H=9 ok :: 0001110000|0011111000|0111111100|1111111110|1111111111|0111111111|0011111110|0001111100|0000111000
FILE:saxtem.prop W=14 H=15 ok :: 00000000000000|00000000000000|00000000111000|00000001111100|00000011111110|00000111111110|00001111111110|00011111111100|00111111111000|01111111110000|11111111100000|11111111000000|11111110000000|01111100000000|00110000000000
FILE:scoaca.prop W=12 H=9 ok :: 011111000000|011111100000|011111110000|001111111000|001111111100|000111111110|000001111111|000000111111|000000011110
FILE:scoart.prop W=14 H=11 ok :: 00000011100000|00000111110000|00001111111000|00011111111100|00111111111110|00011111111111|00001111111000|00000111100000|00000011000000|00000000000000|00000000000000
FILE:scoba2.prop W=16 H=15 ok :: 0000000001000000|0000000111100000|0000001111110000|0000011111111000|0000111111111100|0001111111111110|0011111111111110|0111111111111111|0111111111111111|0011111111111110|0000111111111000|0000011111110000|0000001111100000|0000000111000000|0000000110000000
FILE:scobar.prop W=12 H=11 ok :: 000001110000|000011110000|000111111000|001111111100|011111111111|111111111111|011111111111|001111111100|000111111000|000011110000|000001110000
FILE:scobla.prop W=10 H=9 ok :: 0000110000|0001111000|0111111100|0111111110|0011111111|0000011000|0000001000|0000000000|0000000000
FILE:scocen.prop W=14 H=13 ok :: 00000000000000|00000000000000|00000000000000|00110000000110|01111000001111|11111100011111|01111110111110|00111111111100|00011111111000|00001111111000|00000111111000|00000011111000|00000000110000
FILE:scodip.prop W=10 H=9 ok :: 0000001110|0000011111|0000111111|0001111111|0011111110|0111111100|1111111000|0111110000|0011000000
FILE:scohou.prop W=8 H=9 ok :: 00000000|00000000|00001100|00011110|00111111|01111111|01111111|00111110|00011100
FILE:scosta.prop W=10 H=11 ok :: 0000000000|0000011000|0000111100|0001111110|0011111111|0111111111|0111111110|1111111100|1111111000|1111110000|0111000000
FILE:scotem.prop W=12 H=11 ok :: 001000000000|011111000000|011111100000|011111111000|011111111100|011111111110|001111111111|000111111111|000011111111|000001111111|000000011110
FILE:spaaca.prop W=14 H=13 ok :: 00000011000000|00000111100000|00001111110000|00011111111000|00111111111100|01111111111110|01111111111111|00111111111111|00011111111110|00001111111100|00000111111000|00000011110000|00000001100000
FILE:spaart.prop W=12 H=13 ok :: 000000000000|000001110000|000011111000|000111111100|001111111110|011111111111|011111111111|011111111111|001111111110|001111111100|001111111000|001111111000|000000110000
FILE:spaba2.prop W=14 H=13 ok :: 00000011000000|00000111100000|00001111110000|00011111111000|00111111111100|01111111111110|01111111111111|01111111111111|00111111111110|00011111111100|00001111111000|00000111110000|00000011100000
FILE:spabar.prop W=10 H=9 ok :: 0000011100|0000111110|0001111111|0011111111|0111111111|0111111110|0111111100|0011111000|0001110000
FILE:spabla.prop W=8 H=7 ok :: 00000000|00001100|00011110|00111111|01111110|00111100|00011000
FILE:spacen.prop W=14 H=13 ok :: 00000000000000|00001111111000|00011111111100|00111111111110|00111111111110|00111111111110|00111111111111|00111111111111|00111111111110|00111111111100|00011111111000|00001111110000|00000001100000
FILE:spadip.prop W=12 H=11 ok :: 000000000000|000000111100|000001111110|000011111111|000111111111|001111111110|011111111100|011111111000|001111110000|000111100000|000011000000
FILE:spahou.prop W=10 H=7 ok :: 0000000000|0011111100|0011111110|0011111111|0011111111|0000011110|0000000100
FILE:spamar.prop W=13 H=13 ok :: 0000011000000|0000111100000|0000111110000|0001111111000|0011111111100|0111111111110|0111111111110|0111111111100|0011111111000|0001111110000|0000111110000|0000011100000|0000001000000
FILE:spasta.prop W=12 H=11 ok :: 000000000000|000000011100|000000111110|000001111111|000011111111|000111111110|001111111100|011111111000|011111110000|001111100000|000111000000
FILE:spasto.prop W=7 H=5 ok :: 0000000|0000011|0000111|1000111|0000110
FILE:spatem.prop W=20 H=19 ok :: 00000000000000000000|00000000111000000000|00000001111100000000|00000011111110000000|00000111111111000000|00001111111111100000|00011111111111110000|00111111111111111000|00111111111111111100|00111111111111111110|00011111111111111111|00001111111111111111|00001111111111111110|00000111111111111000|00000001111111110000|00000000111111100000|00000000011111000000|00000000001111000000|00000000000110000000
FILE:sweaca.prop W=10 H=9 ok :: 0000110000|0001111000|0011111100|0111111110|0111111111|0011111111|0001111110|0000111100|0000011000
FILE:sweart.prop W=12 H=11 ok :: 000001100000|000011110000|000111111000|001111111100|011111111111|011111111111|001111111110|000111100000|000010000000|000000000000|000000000000
FILE:sweba2.prop W=14 H=13 ok :: 00000011000000|00000111100000|00001111110000|00011111111000|00111111111100|11111111111111|11111111111111|01111111111111|00111111111110|00011111111110|00001111111000|00000111111000|00000011100000
FILE:swebar.prop W=14 H=13 ok :: 00000011100000|00000011110000|00000111111000|00001111111100|00111111111110|11111111111110|11111111111100|01111111111100|00111111111100|00011111111100|00001111111000|00000110000000|00000000000000
FILE:swebla.prop W=12 H=7 ok :: 000011111000|000111111100|001111111110|001111111111|000111111111|000011111110|000000000000
FILE:swecen.prop W=16 H=13 ok :: 0000000111000000|0000001111100000|0000011111110000|0000111111111000|0001111111111100|0011111111111110|0111111000111111|0011110000011110|0001100000001100|0000000000000000|0000000000000000|0000000000000000|0000000000000000
FILE:swedip.prop W=10 H=9 ok :: 0000000000|0000011000|0000111110|0001111111|0011111110|0111111100|0011111000|0001110000|0000100000
FILE:swehou.prop W=10 H=9 ok :: 0000000000|0000000000|0000001100|0000011111|0000111111|0001111100|0011111000|0001110000|0000100000
FILE:swesta.prop W=14 H=11 ok :: 00011110000000|00111111000000|01111111111000|01111111111100|01111111111110|00111111111110|00011111111100|00001111100000|00000111000000|00000000000000|00000000000000
FILE:swetem.prop W=14 H=13 ok :: 00000000000000|00000000000000|00000111000000|00001111100000|00011111110000|00111111111000|00111111111110|00011111111111|00001111111111|00000111111110|00000011111000|00000001111000|00000000110000
FILE:swiaca.prop W=12 H=12 ok :: 000000000000|000000110000|000001111000|000011111100|000111111110|001111111111|011111111111|011111111110|001111111100|000111111000|000011110000|000001100000
FILE:swiart.prop W=12 H=12 ok :: 000000000000|000000000000|000000000000|000111100000|001111111100|011111111110|111111111100|111111111100|111111111100|011111111000|000011110000|000001100000
FILE:swiba2.prop W=12 H=12 ok :: 000000000000|000000100000|000001110000|000011111000|000111111100|001111111110|011111111111|001111111110|000111111110|000011111000|000001111000|000000100000
FILE:swibar.prop W=12 H=12 ok :: 000000000000|000001111000|000011111100|000111111110|001111111111|011111111111|111111111111|011111111111|001111111110|000111111100|000011111000|000001110000
FILE:swibla.prop W=10 H=10 ok :: 0000000000|0000011000|0000111100|0001111110|0011111111|0011111111|0001111111|0001111110|0000111100|0000011100
FILE:swicen.prop W=12 H=12 ok :: 000000000000|000001110000|000011111000|000111111100|001111111110|011111111111|111111111111|011111111110|001111111100|000111111000|000011110000|000001100000
FILE:swidip.prop W=10 H=10 ok :: 0000000000|0000011000|0000111100|0001111110|0011111111|0111111110|0111111100|0011111000|0001110000|0000100000
FILE:swihou.prop W=8 H=6 ok :: 00000000|00011100|00111110|00111111|00111111|00011110
FILE:swista.prop W=12 H=8 ok :: 000011110000|000111111000|001111111100|001111111110|001111111111|000111111110|000011111100|000001111000
FILE:switem.prop W=14 H=12 ok :: 00000000000000|00000000000000|00000111100000|00001111110000|00011111111000|00111111111110|00111111111110|00011111111100|00001111111000|00000111110000|00000111100000|00000011000000
FILE:turaca.prop W=6 H=5 ok :: 000000|001110|001110|001110|000000
FILE:turart.prop W=14 H=14 ok :: 00000000110000|00000001111000|00000011111100|00000111111110|00001111111111|00011111111111|00111111111111|01111111111110|11111111111100|11111111111000|01111111110000|00001111110000|00000111110000|00000011000000
FILE:turbar.prop W=12 H=11 ok :: 000011100000|000111110000|001111111000|011111111100|011111111110|011111111111|011111111111|001111111111|000111111110|000011111100|000001111000
FILE:turbla.prop W=12 H=9 ok :: 000000000000|000001111000|000011111100|000111111110|000111111110|000111111110|000111111100|000001111000|000000000000
FILE:turcen.prop W=14 H=13 ok :: 00000000000000|00000011110000|00000111111000|00000111111100|00000111111110|00001111111111|00011111111111|00111111111110|00111111111100|00011111000000|00001110000000|00000000000000|00000000000000
FILE:turdip.prop W=14 H=13 ok :: 00000001110000|00000011111000|00000011111100|00000111111100|00001111111000|00111111111000|01111111111000|11111111110000|01111111100000|00111111000000|00000000000000|00000000000000|00000000000000
FILE:turhou.prop W=8 H=7 ok :: 00001100|00011110|00111111|01111111|01111110|00111100|00011000
FILE:turmar.prop W=12 H=9 ok :: 000001110000|000011111100|000111111110|001111111110|011111111100|111111111000|011111110000|000111100000|000000000000
FILE:turmil.prop W=8 H=8 ok :: 00011000|00111100|01111110|11111111|11111111|01111111|00111100|00011000
FILE:turpor.prop W=16 H=15 ok :: 0000000000000000|0000000111000000|0000001111100000|0011111111111100|0111111111111100|1111111111111110|1111111111111110|1111111111111111|1111111111111111|0111111111111110|0011111111111100|0001111111111000|0000111111110000|0000000111110000|0000000011000000
FILE:tursga_14.prop W=6 H=2 ok :: 100001|100001
FILE:tursga_15.prop W=2 H=6 ok :: 11|00|00|00|00|11
FILE:tursga_16.prop W=8 H=8 ok :: 00000111|00000111|00000011|00000001|11000000|11100000|11110000|11110000
FILE:tursga_17.prop W=8 H=10 ok :: 00000000|11110000|11110000|11100000|11000000|00000000|00000011|00000111|00000111|00000111
FILE:tursta.prop W=14 H=13 ok :: 00000001110000|00000011111000|00000111111100|00001111111110|00011111111111|00111111111111|01111111111111|01111111111110|00111111111100|00011111111000|00001111110000|00000011100000|00000000000000
FILE:tursto.prop W=8 H=5 ok :: 00000100|00001110|00000111|00000010|00000000
FILE:turswa.prop W=2 H=2 ok :: 11|11
FILE:turswa_01.prop W=2 H=2 ok :: 11|11
FILE:turswa_02.prop W=2 H=2 ok :: 11|11
FILE:turswa_03.prop W=4 H=4 ok :: 0010|0111|1110|0100
FILE:turswa_04.prop W=4 H=4 ok :: 0100|1110|0111|0010
FILE:turswa_05.prop W=2 H=2 ok :: 11|11
FILE:turswa_06.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:turswa_07.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:turswa_08.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:turswa_09.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:turswa_10.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:turswa_11.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:turswa_12.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:turswa_13.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:turswa_45gate.prop W=2 H=2 ok :: 11|11
FILE:turswa_45v1.prop W=2 H=2 ok :: 11|11
FILE:turswa_45v2.prop W=2 H=2 ok :: 11|11
FILE:turswa_gate.prop W=2 H=2 ok :: 11|11
FILE:turswa_tower.prop W=2 H=2 ok :: 11|11
FILE:turswa_turn.prop W=2 H=2 ok :: 11|11
FILE:turswa_turnmirror.prop W=2 H=2 ok :: 11|11
FILE:turswa_v1.prop W=2 H=2 ok :: 11|11
FILE:turswa_v2.prop W=2 H=2 ok :: 11|11
FILE:turtem.prop W=12 H=11 ok :: 000011000000|000111100000|001111110000|011111111000|011111111100|001111111110|001111111111|000111111111|000011111110|000001111100|000000011000
FILE:turtow.prop W=8 H=7 ok :: 00011100|00111110|01111111|01111111|01111111|00111110|00011100
FILE:ukraca.prop W=18 H=17 ok :: 000011000000000000|000111100000000000|001111110000000000|011111111000000000|011111111100000000|001111111110000000|000111111111000000|000011111111100000|000001111111110000|000000111111111000|000000011111111100|000000001111111110|000000000111111111|000000000011111111|000000000001111110|000000000000111100|000000000000011000
FILE:ukrart.prop W=18 H=17 ok :: 000000000000000000|000000000000000000|000000000000000000|000000001111110000|000001111111111000|000011111111111100|000111111111111110|001111111111111111|011111111111111111|011111111111111110|001111111111111100|000111111111111000|000011111111110000|000000111111000000|000000011110000000|000000001110000000|000000000100000000
FILE:ukrbar.prop W=14 H=13 ok :: 00000000000000|00000011110000|00000111111000|00001111111100|00011111111110|00111111111111|01111111111110|00111111111000|00011111111000|00001111110000|00000011100000|00000000000000|00000000000000
FILE:ukrbla.prop W=12 H=9 ok :: 000000110000|000001111000|000011111100|000111111110|001111111111|001111111110|000111111100|000011111000|000001110000
FILE:ukrcen.prop W=16 H=15 ok :: 0000000000000000|0000000110000000|0000001111000000|0000011111111000|0000111111111110|0001111111111111|0011111111111111|0111111111111111|0111111111111110|0011111111111110|0001111111111000|0000111111110000|0000011111100000|0000001111000000|0000000110000000
FILE:ukrdip.prop W=12 H=11 ok :: 000000001000|000000011100|000000111110|000001111111|000011111110|000111111100|001111111000|011111110000|001111100000|000111000000|000010000000
FILE:ukrhou.prop W=12 H=9 ok :: 000000011000|000001111100|000011111110|000111111110|000111111110|000111111100|000011111000|000001110000|000000000000
FILE:ukrpor.prop W=18 H=21 ok :: 000000001100000000|000000011110000000|000000111111000000|000001111111100000|000011111111110000|000111111111111000|001111111111111100|011111111111111100|011111111111111100|011111111111111100|001111111111111000|001111111111110000|000011111111110000|000001111111110000|000000111111110000|000000011111110000|000000011111110000|000000011111110000|000000011111100000|000000011111000000|000000001110000000
FILE:ukrsta.prop W=14 H=13 ok :: 00000001100000|00000011110000|00000111111000|00001111111100|00011111111110|00111111111111|01111111111111|01111111111110|00111111111100|00011111111000|00001111110000|00000111100000|00000011000000
FILE:ukrtem.prop W=22 H=19 ok :: 0000000001111000000000|0000000011111100000000|0000000111111110000000|0000001111111111000000|0000011111111111100000|0000111111111111110000|0001111111111111111000|0111111111111111111100|1111111111111111111110|0111111111111111111110|0011111111111111111000|0001100001111111110000|0000000000111111100000|0000000000011111000000|0000000000001110000000|0000000000000000000000|0000000000000000000000|0000000000000000000000|0000000000000000000000
FILE:ukrwga_14.prop W=6 H=2 ok :: 100001|100001
FILE:ukrwga_15.prop W=2 H=6 ok :: 11|00|00|00|00|11
FILE:ukrwga_16.prop W=8 H=16 ok :: 00000110|00000111|00000011|00000000|01000000|11100000|11110000|01100000|00000010|00000111|00000010|00000000|00000000|01100000|11100000|01000000
FILE:ukrwga_17.prop W=8 H=10 ok :: 00000000|01000000|11100000|01000000|00000000|00000000|00000110|00000111|00000010|00000000
FILE:ukrwwa.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_01.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_02.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_03.prop W=4 H=4 ok :: 0010|0111|1110|0100
FILE:ukrwwa_04.prop W=4 H=4 ok :: 0100|1110|0111|0010
FILE:ukrwwa_05.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_06.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:ukrwwa_07.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:ukrwwa_08.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:ukrwwa_09.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:ukrwwa_10.prop W=4 H=4 ok :: 0100|1110|0110|0000
FILE:ukrwwa_11.prop W=4 H=4 ok :: 0010|0111|0110|0000
FILE:ukrwwa_12.prop W=4 H=4 ok :: 0000|0110|1110|0100
FILE:ukrwwa_13.prop W=4 H=4 ok :: 0000|0110|0111|0010
FILE:ukrwwa_45gate.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_45v1.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_45v2.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_gate.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_tower.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_turn.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_turnmirror.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_v1.prop W=2 H=2 ok :: 11|11
FILE:ukrwwa_v2.prop W=2 H=2 ok :: 11|11
FILE:venaca.prop W=12 H=11 ok :: 000000010000|000000111000|000001111100|000011111110|000111111111|001111111110|011111111100|001111111000|000111110000|000011100000|000001000000
FILE:venart.prop W=12 H=9 ok :: 000011111100|000111111110|001111111111|011111111111|011111111111|001111111110|000111111100|000011111100|000001110000
FILE:venba2.prop W=12 H=9 ok :: 000011100000|000111110000|001111111000|001111111100|001111111110|000111111111|000111111110|000011111100|000000111000
FILE:venbar.prop W=16 H=15 ok :: 0000000001100000|0000000011110000|0000000111111000|0000001111111100|0000011111111110|0000011111111111|0000011111111111|0000001111111110|0000001111111100|0000000111111000|0000000001111000|0000000000110000|0000000000000000|0000000000000000|0000000000000000
FILE:venbla.prop W=10 H=9 ok :: 0000110000|0001111000|0011111100|0011111110|0011111111|0011111111|0001111100|0000111000|0000000000
FILE:vencen.prop W=16 H=13 ok :: 0000000111000000|0000001111100000|0000011111110000|0000111111111000|0001111111111100|0011111111111110|0111111111111111|0011111111111110|0001111111111100|0000111111111000|0000011111110000|0000001111100000|0000000111000000
FILE:vendip.prop W=10 H=9 ok :: 0000001000|0000011100|0000111110|0001111111|0011111111|0111111110|0011111000|0001111000|0000110000
FILE:venhou.prop W=6 H=7 ok :: 000000|000100|001110|011111|001110|000100|000000
FILE:vensta.prop W=12 H=11 ok :: 000000000000|000000000000|000001110000|000011111000|000111111100|001111111111|000111111111|000111111111|000011111110|000001111000|000001110000
FILE:ventem.prop W=20 H=19 ok :: 00000000000000000000|00000000110000000000|00000001111110000000|00000011111111000000|00000111111111100000|00001111111111110000|00011111111111111000|00111111111111111100|00111111111111111110|00011111111111111111|00011111111111111111|00011111111111111110|00001111111111111100|00000111111111111000|00000011111111110000|00000001111111100000|00000000111111000000|00000000011110000000|00000000001100000000
```

*End of DEC-U-COLL-CENSUS-DEEP.*
