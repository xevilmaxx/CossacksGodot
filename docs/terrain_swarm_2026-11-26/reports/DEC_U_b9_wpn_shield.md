---
id: DEC-U-B9-WPN-SHIELD
worker: DEC-U-B9 (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "PORT1TO1_b_angle_index.md lists class-B candidate B9 (E-WPN/SHIELD) NOT EXECUTED. Prior: DEC_U_weapon_tail.md closed 77 weapon rows + 33 protection rows + 12 shield writes as script-text [O]; shields/mounts stay [U] unwired; DEC_U_damage_height.md left per-sid weapon-row application/damage matrix [U]. This worker executes the B9 remaining angle: packed CODE byte search for AddWeapon/SetObjBaseProtection/shield/protection/damagetype/weaponkind/SetWeapon with VAs, wrapper arities, native damage-matrix lookup, live CODE override check."
labels: "[O] verbatim donor bytes/lines verified by a second pass · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-B9-WPN-SHIELD — packed CODE search for weapon/shield/protection APIs: no native table, no override (2026-11-26)

> B9 exact remaining angle (`PORT1TO1_b_angle_index.md:50`, quoting `PORT1TO1_u_classify.md §4 B9` via `DEC_U_weapon_tail.md §5`):
> "STATIC mechanical read of shield/mount rows (`yachttur 100`, `battleship 100`, `tow 5`, weakwall `15+80`) and upgrade per-value rows `country.script:2050-2210`; never copy a neighbour sid. (`DEC_U_weapon_tail §5`.)"
> Task extension for this pass: packed CODE byte search for `AddWeapon`, `SetObjBaseProtection`, `shield`, `protection`, `damagetype`, `weaponkind`, `SetWeapon` API/property names with VAs (CODE-embedded tables as in blend/tick); inspect wrapper arities and any native damage-matrix/protection lookup reachable from them; check whether any live CODE value overrides the script-text rows; only byte-proven values become [D].

## 0. Pass ledger (owner rule; every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass (read-only) | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `Get-FileHash cossacks.exe` SHA256 `87F0F3C1…4E16C`, 5,768,048 B — matches pin [O]. Binary never executed/copied. PE32, ImageBase `0x400000`, 10 sections (§1). |
| P2 | Packed CODE byte search, required 7 needles + script-qualified forms (EV-CODE-W) | **0 hits** for every weapon/shield needle in stored bytes (§1): `AddWeapon`, `_weapon_AddWeapon`, `SetObjBaseProtection`, `SetObjBaseWeapon`, `shield/Shield/SHIELD`, `protection/Protection/PROTECTION`, `damagetype/DamageType/DAMAGETYPE`, `weaponkind/WeaponKind/WEAPONKIND`, `SetWeapon`, `objbase.shield`, `objbase.protection`, `gc_weapon_`, `gc_obj_weapon_kind`, `DoDamage`, `CalcShotDispertion`, `buseownerdamage`, `weaponid`, `weaponsid`, `dispertion`, `addradius`. Control positive `SetGameObjectMinFrameBlend` = 1 hit at VA `0x62f90e` (CODE) — scanner works, absence is real for stored bytes (packed-region reserve stated). |
| P3 | Stem + UTF-16LE + sid-literal census, false-positive triage (EV-CODE-X) | `Weapon/weapon/WEAPON` 0/0/0; `damage/Damage/DAMAGE` 0; `shield/SHIELD` 0; `PUSSTRELA/NUCL/SHOTMUSKET/SHOTCANNON/KAPEZ/POINTOTVZRIV/yachttur/battleship/multicannon/framegun/cannonball/cannister/mortarball/TWeapon/DoRound/RoundDamage/ThrowBy/ProjSimulate` all 0; UTF-16LE 0 for all 7 key names; prototype sids 0. `Protect` 4 / `protect` 5 / `prot` 8 / `Kind` 43+6 / `SHOT` 1 / `Armor` 2 all triaged as **false positives** with VAs (§1.2). Method controls `GetGameObject` 426 / `FrameBlend` 19 / `ExecuteState` 37 / `ProgressPlayers` 9 / `TXAnimation` 14 — same CODE-embedded-table class as blend/tick workers. |
| P4 | Wrapper-arity inspection around every hit (EV-AR) | No weapon/shield CODE prototype exists to inspect — arity section reports **no native arity byte-proven**. Script-text signatures re-cited read-only (§2): `_weapon_AddWeapon` 10 params, `SetObjBaseProtection` 7 params, `SetObjBaseWeapon` 11 params. Names are script-spelled; native spellings unrecoverable from stored bytes. |
| P5 | Native damage-matrix / protection-lookup reachability (EV-MAT) | **No native damage matrix or protection lookup localized.** No `DoDamage`/`DoRoundDamage`/throw/simulate/`TWeapon`/sid byte run; single `Protect`/`Kind`/`SHOT` hits are unrelated (§1.2); xrefs not attempted beyond the 0-hit result (nothing to anchor; computed-pointer limit inherited from blend/tick workers, not re-probed on packed `.bind`). |
| P6 | Live CODE value-override check (EV-OVR) | **No live CODE value overrides any script-text row.** No shield literal table (75/25/50/80/100/95/5/10), no mount tuple, no upgrade per-value row, no per-kind coefficient found in stored bytes. Script-text rows (`unit.script:617,1696-2310`; `weapon.script:314-391`; `country.script:2050-2210+`; `miscext2.script:339-342,380,434`; `player.script:1798,1805`) remain the sole source — all still [U]-in-sim until §4 captures. |
| P7 | Donor-text re-read, read-only (EV-TXT) | Shield H0–H11, mount tuples, `country.script:2050-2210` damage/protection upgrade shape, `_misc_DoDamage` shield-then-protection order re-verified verbatim (§3). No value copied from a neighbour sid. No repo/port file inspected or edited this pass. |

Strange-read log: raw byte search covers stored file bytes including CODE `0x401000-0x8F0DA8` and `.bind` file bytes as stored; `.bind` entropy 7.96 exec (per `DEC_U_blend_deep §0.1 P1` / `DEC_U_tick_deep §0.1 P9`, reused, not re-measured here) means "no match is not proof of absence" for packed/encrypted regions — 0-hit is `[O]`-absence-in-stored-bytes with that stated reserve, never "proven nowhere". No donor binary executed; no donor bytes copied into the repo; no disassembly of packed regions attempted.

---

## 1. Packed CODE byte search — what was searched, where, and what came back [O]

### 1.1 Section map (parsed from PE headers this pass, read-only) [O]

```
ImageBase 0x400000, e_lfanew 0x100, 10 sections:
CODE   VA 0x401000-0x4F0DA8  raw 0x400-0x4F1200
DATA   VA 0x4F2000          raw 0x4F1200
.idata VA 0x507000          raw 0x4FC200
.rsrc  VA 0x54C000          raw 0x53D200
.bind  VA 0x56C000          raw 0x55C600  (packed/exec region per prior entropy reads)
```

VA rule used below: `VA = 0x400000 + RVA`, `RVA = section.VA + (fileoff - section.rawptr)`.

### 1.2 Required needles: all zero in stored bytes [O]

Exact case-sensitive raw search over all 5,768,048 file bytes (ASCII/UTF-8):

| Needle | Count | VA |
|---|---|---|
| `AddWeapon` | 0 | — |
| `_weapon_AddWeapon` | 0 | — |
| `SetObjBaseProtection` | 0 | — |
| `SetObjBaseWeapon` | 0 | — |
| `shield` / `Shield` / `SHIELD` | 0 / 0 / 0 | — |
| `protection` / `Protection` / `PROTECTION` | 0 / 0 / 0 | — |
| `damagetype` / `DamageType` / `DAMAGETYPE` | 0 / 0 / 0 | — |
| `weaponkind` / `WeaponKind` / `WEAPONKIND` | 0 / 0 / 0 | — |
| `SetWeapon` | 0 | — |
| `objbase.shield` / `objbase.protection` | 0 / 0 | — |
| `gc_weapon_` / `gc_obj_weapon_kind` | 0 / 0 | — |
| `DoDamage` / `CalcShotDispertion` / `buseownerdamage` | 0 / 0 / 0 | — |
| `weaponid` / `weaponsid` / `dispertion` / `addradius` | 0 / 0 / 0 / 0 | — |

Extended census (same method): `Weapon/weapon/WEAPON` 0; `damage` (any case) 0; `TWeapon`/`TObjWeapon` 0; `DoRound`/`RoundDamage`/`ThrowBy`/`ProjSimulate` 0; `cannonball/cannister/mortarball` (any case) 0; `PUSSTRELA/NUCL/KAPEZ/SHOTMUSKET/SHOTCANNON/POINTOTVZRIV` 0; `yachttur/battleship/multicannon/framegun` 0; UTF-16LE for all 7 key names 0.

**Control positives (same scanner, same bytes) [O]:** `GetGameObject` 426 hits; `FrameBlend` 19 hits; `ExecuteState` 37 hits; `ProgressPlayers` 9 hits; `TXAnimation` 14 hits; `SetGameObjectMinFrameBlend` 1 hit at file-off `0x22ED0E` → VA **`0x62F90E`** (CODE), context `...function GetGameObjectMinFrameBlendByHandle(const gohandle: Integer): Integer...procedure SetGameObjectMinFrameBlendByHandle(const gohandle, minframeblend: Integer)...` — inside the blend-worker's `0x62F300–0x630700` API-table run. The scanner demonstrably finds CODE-embedded API tables when they exist in stored bytes.

### 1.3 Apparent hits triaged as false positives (VAs exact, reasons stated) [D]

- `Protect` ×4: `0x60D148` (`GetVirtualProtectFails` + `GetSystemDEPPolicy` Win32/accounting API run); `0x6F23F3` (`SteamServer_SetPasswordProtected` Steam server API); `0x8BEB80` (Delphi `Protected` visibility keyword in RTTI keyword run); `0x9083AB` (`.idata` `VirtualProtect` import). None is a game protection row.
- `protect`/`prot` ×5/×8: `0x51900C`, `0x7088DC`, `0x708E70`, `0x709FC1`, `0x8C6898` — Delphi `protected/private/serialized` keyword runs + `files....protected...private...serialized...serialproc...` framework runs; `prot` ×2 extra are `getprotobyname/getprotobynumber` Winsock imports (`0x5AE583/0x5AE597`); `prot` ×1 is `ExprotSnapShotFromCurrentMap` typo-token (`0x6A0A34`).
- `Kind` ×43 / `kind` ×6: all VCL `DragKind/BevelKind/TScrollBarKind` property runs (e.g. `0x4412F5…0x470AF8`) + 6 lowercase API-fragment hits (`GetCameraTrackNameByIndex` cluster `0x5FC804`, `DoProcessFriendsStateLogic` cluster `0x62D88A/0x62D9A8/0x62DB26`, `GetPlayerArmyStackKeyValueByHandle` `0x6934D0`, `MUST NOT occur any kind of exception` `0x8A4D0A`). No weapon-kind table.
- `SHOT` ×1 (`0x5A2F28`): keyboard `SNAPSHOT` virtual-key name run (`...LSHIFT...RSHIFT...LCONTROL...SNAPSHOT...`), not a `SHOT*` prototype sid.
- `Armor` ×2: substring hits inside longer non-weapon tokens (case-insensitive `armor` 0 standalone); not a protection table.
- `PROT` uppercase 0; `DMG/dmg` (any case) 0; `armour` 0.

[D] consequence: there is **no CODE-embedded weapon/shield/protection/damagetype/weaponkind table in stored bytes** of the pinned exe. Script API names of this family are script-side only (consistent with `DEC_U_weapon_tail`/`DEC_U_damage_height` text findings). The packed-`.bind` reserve applies (absence in stored bytes ≠ proof of absence at runtime), so this is a bounded negative, not a value.

---

## 2. Wrapper arities — no native arity byte-proven [U]

Because §1 returns zero CODE prototypes, **no native wrapper arity is observable**. The only arities citable are script-text declarations (re-read this pass, [O] donor text):

- `_weapon_AddWeapon(var ind: Integer; const weaponsid, fx, projbasename: String; damage: Integer; radius, gravity: Float; propagation: Integer; physvalue, time: Float)` — **10 formal params** (`weapon.script:39`) [O].
- `SetObjBaseProtection(var objbase: TObjBase; pike, sword, bullet, cannister, arrow, cannonball: Integer)` — **7 formals** (`unit.script:510-518`) [O]. Writes slots `protection[1,2,3,4,5,7]` (`dmscript.global:280-286` kind ids [O]); kinds 6/8/9 never written.
- `SetObjBaseWeapon(var objprop: TObjProp; var objbase: TObjBase; index, damage, pause, radiusmin, radiusmax, detectradiusmin, detectradiusmax, kind: Integer; bSearchMinAttackRadius: Boolean)` — **11 formals** (`unit.script:520-546`) [O]; `-1`/`default` = keep-prior (`unit.script:593,523-539`).

[D] No native `function ...AddWeapon... / ...SetObjBaseProtection... / ...SetWeapon...` signature string exists in stored bytes to label, count, or type-check these against. Whether the engine exposes per-weapon/per-protection native setters at all is **not byte-proven** — the script procedures above are the only callable surface in evidence. Shield has **no setter procedure at all**: direct field writes `objbase.shield := N` (`unit.script:617,1702,1738,1768,1799,1829,1908,1929,2000,2083,2245,2299`) [O].

---

## 3. Script-text ground re-pinned (read-only; no values promoted) [O]

Donor-text facts carried (verified by re-read, never re-typed from memory):

- **77/77 weapon prototype rows CLOSED as text** (`weapon.script:314,316-391`; def `:39` is not a row) — `DEC_U_weapon_tail §1` recount reused, not re-enumerated here [O].
- **33/33 protection rows CLOSED as text** (32 `SetObjBaseProtection` calls + `unit.script:1821` slot write) — `DEC_U_weapon_tail §2.1` carried [O]. Kind ids `dmscript.global:280-288` (`pike=1,sword=2,bullet=3,cannister=4,arrow=5,firearrow=6,cannonball=7,mortarball=8,heal=9`) [O]; upgrade type ids `dmscript.global:739-742` (`damage=2,damageperc=3,protection=4,shield=5`) [O].
- **12 shield writes transcribed [O]** (default `unit.script:617` = 0; overrides H1–H11 per `DEC_U_weapon_tail §2.2`): cannon 75 (`:1702`), howitzer 75 (`:1738`), mortar 25 (`:1768`), multicannon 50 (`:1799`), framegun 50 (`:1829`), yachttur-only 100 (`:1908`), galley 80 (`:1929`), battleship-only 100 (`:2000`), misgeneral 10 (`:2083`), commonrus-tower-only 5 (`:2241-2246`), weakwall 95 = `15+80` (`:2299`); stone `swa/sga`, ferry, fishboat, yacht-base, frigate/xebec/chaika bases, non-rus towers write nothing → donor-absent zero [D, never back-filled].
- **Mount tuples [O]** per `DEC_U_weapon_tail §3` (`unit.script:1696-2310`) — live heads with `{...}` comments; `default` = `-1` keep-prior.
- **Damage application order [O]** (`miscext2.script:339-342,380,434`): `damage -= shield` (built) else `damage -= shield div 3` (unbuilt); squad hold bonus; then `damage -= protection[weapkind]` (both `bProcessLogic` paths `:380`/`:434`); floor at 1; headshot `random<0.05` arrow/bullet (`:420`); priest branch heals instead (`:371-377,388-398`). Upgrades add `+= round(value)` per kind (`player.script:1798`) and per shield (`player.script:1802-1806`) [O].
- **Upgrade per-value rows open [O-shape/U-values]**: `country.script:2050-2210` damage/protection pairs per nation (e.g. rus pikeman dmg +2 / prot +2 `:2057-2059`) + shield rows (e.g. `:3518` shield 85, `:3538` shield 80, `:3702/:3982` shield 2, `:3715` shield 50, `:3738/:3986` shield 2) [O cited, values not enumerated here — mechanical read still open per B9 angle].

**Live CODE override verdict [D]:** §1 finds no CODE table, no numeric row, and no damage-matrix/protection-lookup reachable from any weapon/shield hit (there are no hits to reach from). Therefore **no live CODE value overrides, confirms, or renames any script-text row**. Every literal above stays script-text `[O]` with sim-application `[U]` until §4.

**Zero promotions this pass.** Only byte-proven values become [D]; this pass byte-proves names/VAs of *unrelated* tables (controls) and the *absence* class above. No shield number, mount number, kind id semantic, upgrade value, or damage coefficient is promoted.

---

## 4. Still-[U] register — fixed-seed weapon-damage/protection captures, zero-mismatch termination

General harness (all items): pinned donor texts; fixed `randkey0/1`; flat map; fixed `GetTimeSpeedFactor`; headless fixed-dt; single attacker A + single defender D per cell (no squads/aura/priest/AI unless the cell states it); sim-stream vs general-`random` routing per `DEC_U_damage_height §7`. Sim assertions read `entities[].hp` / dealt damage, never pixels. **Termination criterion (all): run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item `[U]` and forbids wiring; zero mismatches across the full series closes only the named application question — never a neighbouring sid, never a curve.** Never copy a neighbour sid's number; never invent a row/coefficient; never claim parity.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) |
|---|---|---|---|
| W1 | Shield built vs unbuilt ÷3 (`miscext2.script:339-342`) | Donor law [O] §3; per-sid shield literals [O] text, application [U] | Per shield sid (cannon 75, howitzer 75, mortar 25, multicannon 50, framegun 50, galley 80, yachttur-only 100, battleship-only 100, tower-rus-only 5, weakwall 95, misgeneral excluded): attacker fixed-damage mount vs defender built=True then built=False, 20 shots each (40/sid). Expect `dealt = max(1, indamage − (built ? shield : shield div 3) − prot[kind] − squadbonus(0))`. Zero mismatches per sid closes that sid only; any sid mismatch → that sid stays [U], no neighbour value substituted. |
| W2 | Protection per kind (`:380`/`:434`, 33 rows) | 33 rows [O] text; per-kind application [U] | Per protection row sid × per kind (pike/sword/bullet/cannister/arrow/cannonball): fixed `indamage` vs row's `protection[kind]`, 10 shots/cell. Expect `dealt = max(1, indamage − shieldterm − protection[kind])`. Firearrow/mortarball/heal kinds expect 0 protection (never written). Zero mismatches per cell; any → [U]. |
| W3 | Mount damage/pause/range application (ship/arty/tower/wall tuples, `unit.script:1696-2310`) | Tuples [O] text; live use [U] | Per mount sid/index: volley at mid `radiusmax` with recorded `damage/pause/rmin/rmax/detmin/detmax/kind/bSearchMin` from the tuple; verify dealt-damage equals mount `damage` (not prototype `TWeapon.damage`) except `buseownerdamage` mounts per `doexplode.inc:59-62`; verify range gate `dist ≤ radiusmax+rbonus` with `rbonus` from W5. Stone `swa/sga`, weakwall, ferry expect NO fire (donor-absent zero). 20 shots/mount. Zero mismatches or [U]. |
| W4 | Upgrade per-value rows (`country.script:2050-2210`, `player.script:1798,1805`) | Shape [O]; every per-value number [U]-T1 | Mechanical read first (cite-or-tag every `damage/protection/shield` value + kind/member/nation scope; `{...}`-commented heads stay live-head). Then per upgraded sid/kind: L0 vs L1 battery, 20 shots/level. Expect `prot/shield += round(value)` exact. Zero mismatches per row; any → row stays [U]; never borrow a sibling nation's value. |
| W5 | `addradius` + weakwall kicker + `uniqrnd` shortening (range path, `unit.script:8017-8035,7547-7568`) | Laws [O] (`DEC_U_damage_height §3-§4`); wiring [U] | Stationary (`bIdle`) shooter +32 px mounts: max-range edge series ±0.6 tiles; weakwall target +0.36 tiles; moving (`standtime<0.25`) `−3×uniqrnd` (arty ×0.5, cannister excluded). Fixed-seed sweep per mount. Zero mismatches or [U]. |
| W6 | Double-dip + owner-splash + melee/immediate bypass (`doexplode.inc:78-89`, `miscext2.script:562-604`) | Chain [O]; counts [U] | Timed/area mounts: locked target takes round + direct damage; owner excluded only as `dmgHnd=owner` in round loop; melee/`weaponid=0`/`immediate` apply direct `_misc_DoDamage` with no projectile. 20 shots/geometry. Zero mismatches or [U]. |

B9 angle closure rule: the B9 residual closes only when W1 (all 12 shield writes applied per-sid), W3 (all mount tuples applied), and W4 (every `country.script:2050-2210` + shield-row value cited-or-tagged with zero-mismatch batteries) are green. Until then `DONOR_SHIELD_ROWS`/`DONOR_MOUNT_ROWS` stay proposal-only and every port `shield/weapons[]` estimate stays `PORT APPROXIMATION`.

---

## 5. Concrete port change list (owner/COORD applies; this worker wrote no code)

1. Add `DONOR_SHIELD_ROWS` const keyed exactly per §3 (H0 default 0 + H1–H11 with `unit.script:<line>` cites; `15+80` kept as expression with precomputed 95 in comment; `80{100}` stored as 80 with comment). Wire `donor_do_damage` shield input to it; keep estimated `"shield"` fields tagged until W1 green.
2. Add `DONOR_MOUNT_ROWS` per `DEC_U_weapon_tail §3` tuples with `unit.script:<line>` cites; `default`/`-1` = keep-prior/0; stone/weakwall/ferry stay EMPTY (donor-absent zero [D]). Wire range/damage/pause/radii/kind from it when W3 green; never back-fill.
3. Correct `howitzer` 60 → **75**, `mortar` 40 → **25** (`unit.script:1738,1768`); verify multicannon/framegun/galley/yachttur/battleship/tower/wall entries against §3 before touching any other number.
4. Cite-or-tag every `country.script:2050-2210` damage/protection value and every shield-row value (`:3518,:3538,:3702,:3715,:3738,:3982,:3986`, full sweep per B9 angle) before W4; keep `round()` half-to-even with `[U]`-G1 tag until the X21 20-vector fixture proves Delphi parity.
5. Correct the stale 78-count comment to 77-of-77 CLOSED (procedure def `:39` is not a row) if not already done.
6. Telemetry/format: every added value carries its `weapon.script:<line>` / `unit.script:<line>` / `miscext2.script:<line>` / `country.script:<line>` / `dmscript.global:<line>` cite; every estimate keeps PORT APPROXIMATION + `[U]` tag with its §4 series. No save-version bump, no key rename, no demo/mill/builder/I11 change.

---

## 6. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | Pinned exe `t_87f0f3c130b0` re-verified (5,768,048 B, SHA256 `87F0F3C1…4E16C`); ImageBase `0x400000`, 10 sections; binary never executed/copied. | [O] §0 P1 / §1.1 |
| 2 | All 7 required needle families + 22 extensions: **0 hits in stored bytes**, ASCII and UTF-16LE; section-scoped VAs N/A; control positives prove the method (426/19/37/9/14 + `0x62F90E` table hit). | [O] §0 P2–P3 / §1.2 |
| 3 | Apparent `Protect/protect/prot/Kind/kind/SHOT/Armor` hits triaged with exact VAs to Win32/Steam/Delphi/VCL/WinSock/keyboard sources — none is a weapon/shield/protection table. | [D] §1.3 |
| 4 | No native wrapper arity, no native damage-matrix/protection lookup, no live CODE value override byte-proven; arities citable only from script text (`weapon.script:39` ×10, `unit.script:510` ×7, `unit.script:520` ×11); shield has no setter (direct field writes). | [D] §2 / §3 |
| 5 | 77 weapon + 33 protection rows carried as script-text [O]; 12 shield writes + mount tuples + damage-order + upgrade shapes re-pinned [O]; applications and all upgrade per-values stay [U] with §4 fixed-seed zero-mismatch captures. | [D] §3–§4 |
| 6 | Zero promotions this pass; no row/coefficient invented; no neighbour-sid copy; no parity claim. | [O] scope guard |
| 7 | Exactly one repository file written (this report); no source/shader/asset/config/test/runner/Godot/git/donor-execution edit. | [O] scope guard |

> Verdict: `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`. B9 CODE-angle executed as a bounded negative (no native table/override in stored bytes, packed-region reserve stated); value/application items W1–W6 stay `[U]` until their zero-mismatch batteries terminate. No approximation is authorised; no parity is claimed.

*End of DEC-U-B9-WPN-SHIELD.*
