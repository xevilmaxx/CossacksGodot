---
id: DEC-U-WEAPON-TAIL
worker: DEC-U-WEAPON-TAIL (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_skirmish_tables.md enumerated 77 of 78 `_weapon_AddWeapon` call rows into data.gd DONOR_WEAPON_PROTOS; the remaining row plus ships/buildings/walls/shields rows stay [U]-T1-tail. IMPL-SKIRMISH-ROWS transcribed all 77 with exact file:line cites and flagged the remainder rather than inventing one."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-WEAPON-TAIL — the missing 78th weapon row + ship/building/wall/shield rows (2026-11-26)

## 0. Pass ledger (owner rule; every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` re-verified this pass: `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c1…4e16c` (matches DEC-U-SKIRMISH §0). No binary executed, copied, or debugged. Text scripts read as text only. |
| P2 | `weapon.script` full-range recount (EV-WT-W) | Whole-file `Select-String _weapon_AddWeapon\s*\(` over `lib`+`units`+`misc`+`progress`+`env`+`user` trees: **78 unique hits = 1 procedure def (`:39`) + 77 registration calls (`:314` + `:316–:391`)**. Zero hits anywhere else. Prior "78 call rows" count included the def line; **there is no 78th registration row**. |
| P3 | `weapon.script:39-69,250-391` re-read (EV-WT-SHAPE) | Procedure shape + physvalue/propagation law + all 77 rows re-verified verbatim against DEC_U_skirmish_tables §1.1 and `data.gd:978-1056`. All 77 sids present in port. |
| P4 | `unit.script` protection sweep (EV-WT-P) | `SetObjBaseProtection` = 33 hits = 1 def (`:510`) + **32 calls**; plus 1 direct slot write (`:1821`). Total **33 donor protection rows** = exactly `DONOR_PROT_ROWS` 33 keys. No ship/building/wall protection row exists beyond the multicannon slot. |
| P5 | `unit.script` shield sweep (EV-WT-H) | `objbase.shield` = **12 hits**: 1 default (`:617` := 0) + 11 sid-scoped writes (§2). No `DONOR_SHIELD_ROWS` const exists in `data.gd` — this is the real T1-tail. |
| P6 | Ship/artillery/tower/wall mount sweep (EV-WT-M) | All `SetObjBaseWeapon` + `weaponsid`/`dispertion`/`addradius`/`fxshot`/cost rows for cannon/howitzer/mortar/multicannon/framegun/yacht/yachttur/galley/frigate-family/ferry/tower/walls transcribed §3. Stone `swa/sga` and weakwall `ukrwwa/ukrwga` mount **no weapon** (donor-absent zero). |
| P7 | `dmscript.global` + `misc.script` constants re-pin (EV-WT-C) | Weapon-kind ids `:278-288`, gravity/propagation/time enums `:688-705`, `_misc_PixelsToTiles :462-466`, `_misc_FramesToTime :470-474` re-cited. `default = -1` keep-prior (`unit.script:593`), `SetObjBaseWeapon` keep-prior law (`:520-546`). |
| P8 | `data.gd` read-only inspection (EV-WT-PORT) | `DONOR_WEAPON_PROTOS` 77 keys verified present; `DONOR_PROT_ROWS` 33 keys verified present; port `UNITS_BASE` artillery `shield` values differ from donor on 2+ rows (§4, flagged not edited). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. Donor `{...}` is comment syntax: live value is the uncommented head (e.g. `500{250}` = 500, `80{100}` = 80).

---

## 1. VERDICT — there is no missing 78th `_weapon_AddWeapon` row [O]

**Finding: the donor registers exactly 77 weapon prototype rows, and the port already holds all 77. The "78th row" of DEC_U_skirmish_tables P2 / `data.gd:971-974` is a miscount: the 78th `Select-String` hit is the procedure definition itself.**

Evidence (EV-WT-W), all `[O]` verbatim:

- `data/scripts/lib/weapon.script:39` — `procedure _weapon_AddWeapon(var ind : Integer; const weaponsid, fx, projbasename : String; damage : Integer; radius, gravity : Float; propagation : Integer; physvalue, time : Float);` — **definition, not a row**.
- `data/scripts/lib/weapon.script:314` — `_weapon_AddWeapon(ind, '', '', '', 0, 0, gc_weapon_gravity_0, gc_weapon_propagation_stand, 0, gc_weapon_time_cPlayOnce);` — registration row #1 (`(none)`).
- `data/scripts/lib/weapon.script:316–391` — 76 further registration calls, one per line, no gaps (every line in `316..391` inclusive is a call; verified by whole-file dump this pass).
- `314` + `316..391` = **1 + 76 = 77 registration rows**.
- Recursive tree sweep (`lib`, `units`, `misc`, `progress`, `env`, `user`, `-Recurse -File`) for `_weapon_AddWeapon\s*\(` returns **only** the 77 + def hits above — **no call site outside `weapon.script:314-391`**.
- Cross-check: `data.gd:978-1056 DONOR_WEAPON_PROTOS` holds 77 keys; every sid below resolves to one.

### 1.1 Complete 77-row recount with 6-field shape `[damage, radius_px, gravity, propagation, physvalue, time_expr]` [O]

`radius_px` is the DONOR pixel literal (pre-`_misc_PixelsToTiles`); tiles = px/53.3333333 (`dmscript.global:172`), metres = px/26.6666666. `gravity` ints via `dmscript.global:690-695`; `propagation` names via `:697-704`; `time` via `:688-689` (`cInfinite=-1`, `cPlayOnce=0`) or `_misc_FramesToTime(...)` (`misc.script:470-474`). `physvalue` meaning per `weapon.script:58-62` (`random/random1/fly/randomsimulate → speed`; `angle → angle`; `slightup → gravity := -physvalue`; `stand/immediate → unused`). Donor `round()` expressions kept verbatim — never pre-rounded (bankers caveat stays `[U]`-G1).

| # | weapon.script line | sid | damage | radius_px | grav | propagation | phys | time_expr | in port? |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 314 | `(none)` | 0 | 0 | 0 | stand | 0 | PlayOnce | data.gd:979 yes |
| 2 | 316 | SHOTMUSKET | 0 | 0 | 0 | immediate (`{stand}` comment) | 1 | PlayOnce | :980 yes |
| 3 | 317 | SHOTCANNON | 0 | 20 | 0 | slightup | 0 | PlayOnce | :981 yes |
| 4 | 318 | SHOTSHIP | 0 | 20 | 0 | slightup | 0 | PlayOnce | :982 yes |
| 5 | 319 | SHOTCANNISTER | 0 | 20 | 0 | slightup | 0 | PlayOnce | :983 yes |
| 6 | 320 | SHOTMORTAR | 0 | 0 | 0 | slightup | 0 | PlayOnce | :984 yes |
| 7 | 321 | SHOTHOWITZER | 0 | 0 | 0 | slightup | 0 | PlayOnce | :985 yes |
| 8 | 322 | SHOTMULTICANNON | 0 | 0 | 0 | slightup | 0 | PlayOnce | :986 yes |
| 9 | 323 | SHOTTOWER | 0 | 20 | 0 | slightup | 0 | PlayOnce | :987 yes |
| 10 | 324 | NUCL2P | 340 | 35 | 2 | angle | 10 | Infinite | :988 yes |
| 11 | 325 | NUCL2PTOW | 340 | 35 | 2 | fly | 38 | Infinite | :989 yes |
| 12 | 326 | NUCL2PKOR | 400 | 35 | 2 | fly | 38 | Infinite | :990 yes |
| 13 | 327 | NUCL3M | 800 | 60 | 5 | angle | 55 | Infinite | :991 yes |
| 14 | 328 | NUCL3MONO | 250 | 2 | 5 | angle | 70 | Infinite | :992 yes |
| 15 | 329 | NUCL3MONONEW | 0 | 2 | 5 | angle | 70 | Infinite | :993 yes |
| 16 | 330 | NUCL3MONONEWDMG | 500 (`{250}` comment) | 2 | 5 | random | 1 | Infinite | :994 yes |
| 17 | 331 | NUCL3MONOEXPL | 0 | 0 | 0→(grav arg 0, slightup) | slightup | 0 | PlayOnce | :995 yes |
| 18 | 332 | NUCLGRE | 110 | 50 | 5 | angle | 55 | Infinite | :996 yes |
| 19 | 333 | NUCLM | 100 | 50 | 5 | slightup | 0 | FramesToTime(2) | :997 yes |
| 20 | 334 | NUCLMOSKOL | 800 | 30 | 5 | random | 4 | Infinite | :998 yes |
| 21 | 335 | STRELA | 25 | 20 | 2 | fly | 25 | Infinite | :999 yes |
| 22 | 336 | OSTRELA | 50 | 15 | 2 | fly | 15 | Infinite | :1000 yes |
| 23 | 337 | STRELDEZ | 0 | 0 | 0 | stand | 0 | FramesToTime(950) | :1001 yes |
| 24 | 338 | POINT | 0 | 1 | 3 | random | 3 | Infinite | :1002 yes |
| 25 | 339 | POINTOTVZRIV | 100 | 15 | 3 | randomsimulate | 3 | Infinite | :1003 yes |
| 26 | 340 | POINTSTONE4 | 0 | 1 | 3 | slightup | 0 | PlayOnce | :1004 yes |
| 27 | 341 | PPOINTT | 0 | 0 | 0 | slightup | 0 | PlayOnce | :1005 yes |
| 28 | 342 | PPOINTTTOW | 0 | 0 | 0 | slightup | 0 | PlayOnce | :1006 yes |
| 29 | 343 | PPOINTTKOR | 0 | 0 | 0 | slightup | 0 | PlayOnce | :1007 yes |
| 30 | 344 | PSMPOINTT | 0 | 0 | 0 | slightup | 0 | PlayOnce | :1008 yes |
| 31 | 345 | PSMPOINTTPUS | 0 | 0 | 0 | slightup | 0 | PlayOnce | :1009 yes |
| 32 | 346 | DIMMORT1 | 0 | 0 | 5 | slightup | 0 | PlayOnce | :1010 yes |
| 33 | 347 | DIMMORT2 | 0 | 0 | 5 | slightup | 0 | PlayOnce | :1011 yes |
| 34 | 348 | DIMMORT2NEW | 0 | 0 | 5 | slightup | 0 | PlayOnce | :1012 yes |
| 35 | 349 | PUSSTRELA | 512 | 25 | 0 | fly | 20 | FramesToTime(round(2*1.625)) | :1013 yes |
| 36 | 350 | PUSSTRELA1 | 256 | 50 | 0 | fly | 20 | FramesToTime(round(4*1.625)) | :1014 yes |
| 37 | 351 | PUSSTRELA2 | 128 | 75 | 0 | fly | 20 | FramesToTime(round(8*1.625)) | :1015 yes |
| 38 | 352 | PUSSTRELA3 | 112 | 100 | 0 | fly | 20 | FramesToTime(round(2*1.625)) | :1016 yes |
| 39 | 353 | PUSSTRELA4 | 30 | 125 | 0 | fly | 20 | FramesToTime(round(5*1.625)) | :1017 yes |
| 40 | 354 | PUSSTRELA5 | 30 | 150 | 0 | fly | 20 | FramesToTime(round(10*1.625)) | :1018 yes |
| 41 | 355 | PUSSTRELA6 | 30 | 175 | 0 | fly | 20 | FramesToTime(round(15*1.625)) | :1019 yes |
| 42 | 356 | PUSSTRELAPUS | 600 | 25+10=35 | 0 | fly | 20 | FramesToTime(round(2*2.75)) | :1020 yes |
| 43 | 357 | PUSSTRELA1PUS | 480 | 50+15=65 | 0 | fly | 20 | FramesToTime(round(4*2.75)) | :1021 yes |
| 44 | 358 | PUSSTRELA2PUS | 350 | 75+20=95 | 0 | fly | 20 | FramesToTime(round(8*2)) | :1022 yes |
| 45 | 359 | PUSSTRELA3PUS | 210 | 100-100=0 | 0 | fly | 20 | FramesToTime(round(2*0.5)) | :1023 yes |
| 46 | 360 | PUSSTRELA4PUS | 150 | 125-100=25 | 0 | fly | 20 | FramesToTime(round(5*0.5)) | :1024 yes |
| 47 | 361 | PUSSTRELA5PUS | 150 | 150-100=50 | 0 | fly | 20 | FramesToTime(round(10*0.5)) | :1025 yes |
| 48 | 362 | PUSSTRELA6PUS | 96 | 175-100=75 | 0 | fly | 20 | FramesToTime(round(15*0.5)) | :1026 yes |
| 49 | 363 | KAPEZ | 3000 | 25 | 2 | random1 | 9 | PlayOnce | :1027 yes (+brotate/bcollisiondetection per :54-55) |
| 50 | 364 | STRELDEZPRO | 0 | 0 | 0 | stand | 0 | PlayOnce | :1028 yes |
| 51 | 365 | PUEXP | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1029 yes |
| 52 | 366 | PUNOEXP | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1030 yes |
| 53 | 367 | PUEXPBUILDINGDEATH | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1031 yes |
| 54 | 368 | PUEXPBLD | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1032 yes |
| 55 | 369 | PUNOEXPBLD | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1033 yes |
| 56 | 370 | PUEXPHOWITZER | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1034 yes |
| 57 | 371 | PUEXPHOWITZERBLD | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1035 yes |
| 58 | 372 | PUEXPKOR | 900 | 50 | 0 | slightup | 0 | PlayOnce | :1036 yes |
| 59 | 373 | PUNOEXPKOR | 900 | 50 | 0 | slightup | 0 | PlayOnce | :1037 yes |
| 60 | 374 | PUEXPKORDEATH | 200 (`{900}` comment) | 50 | 0 | slightup | 0 | PlayOnce | :1038 yes |
| 61 | 375 | PU4GRE | 50 | 10 | 0 | slightup | 0 | PlayOnce | :1039 yes |
| 62 | 376 | SMALL | 10 | 10 | 0 | slightup | 0 | PlayOnce | :1040 yes |
| 63 | 377 | SMALL2 | 10 | 10 | 0 | slightup | 0 | PlayOnce | :1041 yes |
| 64 | 378 | SMALL2BLD | 10 | 10 | 0 | slightup | 0 | PlayOnce | :1042 yes |
| 65 | 379 | VODABUL | 10 | 10 | 0 | slightup | 0 | PlayOnce | :1043 yes |
| 66 | 380 | VODABUL2 | 10 | 10 | 0 | slightup | 0 | PlayOnce | :1044 yes |
| 67 | 381 | debrisstone | 300 | 15 | 3 | random1 | 9 | Infinite | :1045 yes |
| 68 | 382 | debriswood | 300 | 15 | 3 | random1 | 9 | Infinite | :1046 yes |
| 69 | 383 | SHOTBLOCKHOUSE | 0 | 0 | 0 | immediate (`{stand}` comment) | 1 | PlayOnce | :1047 yes |
| 70 | 384 | PUEXPKORVSKOR | 900 | 50 | 0 | slightup | 0 | PlayOnce | :1048 yes |
| 71 | 385 | PUNOEXPKORVSKOR | 900 | 50 | 0 | slightup | 0 | PlayOnce | :1049 yes |
| 72 | 386 | DIMMORT2KOR | 0 | 0 | 0→(grav arg `gc_weapon_gravity_0`; comment says ex-angle-60) | slightup | 0 | PlayOnce | :1050 yes |
| 73 | 387 | PUEXPONSHIP | 900 | 10 | 0 | slightup | 0 | PlayOnce | :1051 yes |
| 74 | 388 | PPOINTTFRAME | 500 | 20 | 5 | angle | 15 | Infinite | :1052 yes |
| 75 | 389 | PPOINTTFRAME5 | 0 | 0 | 0 | slightup | 0 | PlayOnce | :1053 yes |
| 76 | 390 | PU4FRAMEGRE | 10 | 1 | 0 | slightup | 0 | PlayOnce | :1054 yes |
| 77 | 391 | POINTOTVZRIVFRAME | 110 | 32 | 5 | random1 | 4 | Infinite | :1055 yes |

**Consequence: no `[U]` weapon-prototype row remains. `data.gd:971-974` comment ("78th is NOT enumerated") is stale and should be corrected to state 77-of-77 CLOSED (patch §4 item 1). No new `DONOR_WEAPON_PROTOS` entry is recommended — adding one would invent donor data.**

---

## 2. Protection rows: the 33 are COMPLETE; the real tail is SHIELD [O]

### 2.1 `protection[6]` — nothing missing (EV-WT-P)

- `unit.script:510-517` — `SetObjBaseProtection` writes slots `pike=1, sword=2, bullet=3, cannister=4, arrow=5, cannonball=7` (`dmscript.global:280-286` ids `[O]`). Kinds `firearrow=6, mortarball=8, heal=9` are never written → always 0 at base.
- 32 `SetObjBaseProtection(...)` calls at lines `:634,646,653,660,667,674,681,688,739,750,762,919,928,1066,1080,1086,1094,1366,1424,1436,1442,1449,1457,1465,1474,1484,1493,1501,1510,1519,1528,1537` — all transcribed in DEC_U_skirmish_tables §1.2 and all present in `data.gd:1063-1097 DONOR_PROT_ROWS` (verified key-for-key this pass).
- Plus `unit.script:1821` — `objbase.protection[gc_obj_weapon_kind_cannister] := 500;` inside the `multicannon` branch — ported as `"wall": [0,0,0,500,0,0]` (`data.gd:1096`).
- Full-`protection` grep this pass returns exactly those lines — **no ship, building, tower, or wall branch writes any other protection slot**. Sids with no row (all ships, all artillery incl. cannon/howitzer/mortar/framegun, towers, stone/weak walls, 18c families, archers, peasants, priests, dragoons, buildings) are donor-absent zero `[D]`: do not back-fill.

### 2.2 `objbase.shield` — the actual unported tail (EV-WT-H) [O]

Donor `_misc_DoDamage` consumes shield (`miscext2.script:339-342`: built target `damage -= shield`, else `damage -= shield div 3`). Donor base default is **0 for every sid** (`unit.script:617` `objbase.shield := 0;`), then these sid-scoped overrides. **No `DONOR_SHIELD_ROWS` const exists in the port** — `data.gd` carries only per-unit estimated `"shield"` fields (§4). Exact rows:

| # | unit.script line | enclosing sid branch | donor literal | live value | note |
|---|---|---|---|---|---|
| H0 | 617 | `_unit_InitBase` default (all sids) | `objbase.shield := 0` | 0 | base law `[O]` |
| H1 | 1702 | `cannon` (artillery) | `objbase.shield := 75; // C1 was 90` | **75** | port `UNITS_BASE cannon shield 75` matches |
| H2 | 1738 | `howitzer` | `objbase.shield := 75;` | **75** | port has **60** → PORT APPROXIMATION, fix §4 |
| H3 | 1768 | `mortar` | `objbase.shield := 25;` | **25** | port has **40** → PORT APPROXIMATION, fix §4 |
| H4 | 1799 | `multicannon` | `objbase.shield := 50;` | **50** | port value to verify vs `UNITS_BASE` entry |
| H5 | 1829 | `framegun` | `objbase.shield := 50; // C1 was 90` | **50** | port has 50 (`data.gd:1963`) — matches |
| H6 | 1908 | `yachttur` (override inside `yacht,yachttur` branch `:1873`) | `objbase.shield := 100;` | **100, yachttur only**; base `yacht` keeps H0 = 0 | port has no yacht/shield donor table — `[U]` until wired |
| H7 | 1929 | `galley` | `objbase.shield := 80{100}; // C1 was 100` | **80** (live head) | port value to verify |
| H8 | 2000 | `battleship` (override inside `frigate,xebec,battleship,chaika` branch `:1959`) | `objbase.shield := 100;` | **100, battleship only**; frigate/xebec/chaika base keep 0 | port has no donor row — `[U]` |
| H9 | 2083 | `misgeneral` | `objbase.shield := 10;` | **10** | scenario marker unit; port label-only |
| H10 | 2245 | `commonsid+'tow'` tower, `commonrus` override only (`:2241-2246`) | `objbase.shield := 5;` | **5, commonrus tower only**; all other nations' towers keep 0 | port has no tower shield row — `[U]` |
| H11 | 2299 | `ukrwwa,ukrwga` weakwall | `objbase.shield := 15+80;` | **95** (literal expression, keep verbatim) | port has no wall shield row — `[U]` |

Negative results `[O]` (absence is donor law, do not invent): stone wall branch `commonsid+'swa',commonsid+'sga'` (`:2258-2284`) writes **no** shield and **no** protection → both 0; `ferry` (`:2033-2049`) writes neither → 0; `fishboat` (`:1855-1872`) writes neither → 0; `yacht` base, `frigate`/`xebec`/`chaika` bases write no shield → 0; non-`commonrus` towers write no shield → 0. `classes.script` has no shield default (only the `shield : Integer` field decl `:3576` and scenario-marker ids) — `unit.script:617` is the sole default.

Upgrade interaction `[O]`: protection upgrades add `+= round(value)` per kind (`player.script:1798`); shield upgrades are type `gc_upg_type_shield = 5` (`dmscript.global:742`) — per-upgrade values remain `[U]`-T1 (mechanical read of `country.script:2050-2210` still open, same experiment as DEC_U_skirmish_tables §9-T1-tail).

---

## 3. Ship / artillery / tower / wall MOUNT rows (`SetObjBaseWeapon`) — exact donor tuples [O]

These are per-unit weapon *mounts* (index damage/pause/ranges/kind + projectile sid), distinct from the §1 prototype registry. Signature law (EV-WT-C): `SetObjBaseWeapon(objprop, objbase, index, damage, pause_frames, radiusmin_px, radiusmax_px, detectradiusmin_px, detectradiusmax_px, kind, bSearchMinAttackRadius)` (`unit.script:520-546`); `-1` (`default`, `:593`) = keep prior; ranges convert px→tiles at set time (`:528-535`), pause frames→s (`:539`). Mount tuple shape: `[index, damage, pause_frames, rmin_px, rmax_px, detmin_px, detmax_px, kind, bSearchMin]` + attachments (`weaponsid`, iron/coal cost, `addradius`/`dispertion` px, `fxshot`).

- **cannon** (`unit.script:1696-1731`): `[0, 1800, 350, 550, 2160, 550, 100000, cannonball, False]` + `weaponsid PPOINTT` (`:1704`), iron 20 / coal 40 (`:1705-1706`), `addradius PixelsToTiles(32)` (`:1707`), `dispertion PixelsToTiles(225)` (`:1708`), `fxshot shotcannon` (`:1709`); `[1, 0, 350{1200}{c1 1400}, 0, 450, 0, 550, cannister, True]` + `weaponsid PSMPOINTTPUS` (`:1711`), iron 24 / coal 21 (`:1712-1713`), `fxshot shotcannon` (`:1714`). Price `(0,250,0,400,400,0)` (`:1715`); maxhp 9000 `{12500}` (`:1697`).
- **howitzer** (`:1732-1763`): `[0, 4000, 600{1250}, 700, 1400{950}, 0, 70000, cannonball, True]` (was mortarball, min-radius was 500 — comment `:1739`) + `weaponsid DIMMORT1` (`:1740`), iron 20 / coal 100 (`:1741-1742`), `addradius (32)` (`:1743`), `dispertion (300){250}` (`:1744`), `fxshot shothowitzer` (`:1745`). maxhp `3000{150}` (`:1733`).
- **mortar** (`:1764-1793`): `[0, 200, 250, 1250, 2600, 0, 70000, mortarball, True]` + `weaponsid DIMMORT2NEW` (`:1772`; `DIMMORT2` commented `:1773`), iron 20 / coal 30 (`:1774-1775`), `addradius (32)` (`:1776`), `dispertion (200){100}` (`:1777`), `fxshot shotmortar` (`:1778`). maxhp `400{100}` (`:1765`).
- **multicannon** (`:1794-1822`): `[0, 500, 60, 10, 700, 0, 50000, cannister, True]` (c1 max range 950 — comment `:1800`) + `weaponsid PSMPOINTT` (`:1801`), iron 40 / coal 30 (`:1802-1803`), `addradius (32)` (`:1804`), `fxshot shotmcannon` (`:1805`); + protection slot cannister := 500 (`:1821`). maxhp `2000{1000}` (`:1795`).
- **framegun** (`:1823-1853`): `[0, 500, 90, 200, 1800, 250, 100000, cannonball, False]` + `weaponsid PPOINTTFRAME` (`:1831`), iron 30 / coal 40 (`:1832-1833`), `addradius (32)` (`:1834`), `dispertion (250)` (`:1835`), `fxshot shotcannon` (`:1836`). maxhp 3000 (`:1824`).
- **yacht / yachttur** (`:1873-1921`): base `[0, 1000, 350, 300, 1100, 0, 50000, cannonball, True]` + `weaponsid PPOINTTKOR` (`:1881`), iron 4 / coal 9 (`:1882-1883`), `addradius (32)` (`:1884`), `dispertion (250)` (`:1885`); maxhp 31000 (`:1874`). `yachttur` override (`:1903-1920`): maxhp 35000 + shield H6 + `[0, 30, 400, default, 1000, 300, 1000, default(keep cannonball), True]` (`:1909`), iron 5 / coal 15 (`:1910-1911`), `dispertion (25)` (`:1912`); `[1, 0, 700, 1000, 1650, 1000, 100000, default, False]` (`:1913`) + `weaponsid PPOINTTKOR` (`:1914`), iron 5 / coal 15 (`:1915-1916`), `dispertion (25)` (`:1917`).
- **galley** (`:1922-1958`): `[0, 100, 150, 300, 1200, 300, 100000, cannonball, True]` + `PPOINTTKOR`, iron 4 / coal 9, `dispertion (25)` (`:1930-1934`); `[1, 1000, 50, 1100, 3100, 1100, 100000, mortarball, False]` + `DIMMORT2KOR`, iron 4 / coal 9, `addradius (32)`, `dispertion (200)` (`:1935-1940`). maxhp 35000 (`:1923`).
- **frigate family base** (`:1959-1988`): `[0, 1800, 75, 400, 1650, 0, 50000, cannonball, True]` + `PPOINTTKOR`, iron 25 / coal 35, `addradius (32)`, `dispertion (250)` (`:1966-1971`); maxhp 50000 (`:1960`). Overrides: `xebec` (`:1989-1997`): maxhp 65000 + `[0, default, 50, 550, 1700, default, 70000, cannonball, True]` (`:1993`); `battleship` (`:1998-2012`): maxhp 90000 + shield H8 + `[0, default, 20, 600, 1950, 600, default, cannonball, True]` (`:2003`), iron 5 / coal 15 (`:2004-2005`); `chaika` (`:2013-2030`): maxhp 25000 + `[0, 1000, 350 div 2, 300, 1100, 0, 50000, cannonball, True]` (`:2019` — integer `div` kept verbatim), iron 4 / coal 9 (`:2020-2021`).
- **ferry** (`:2033-2049`): NO `SetObjBaseWeapon` — unarmed transport (donor-absent zero) `[D]`. maxhp 62000 (`:2034`).
- **tower** `commonsid+'tow'` (`:2223-2257`): `[0, 1000, 400, 550, 1500, 550, 50000, cannonball, True]` + `PPOINTTTOW`, iron 10 / coal 30, `fxshot shottower`, `dispertion (100)` (`:2227-2232`). `commonrus` override (`:2241-2246`): `dispertion (125)` + shield H10 + `[0, default, 300, default, default, default, default, cannonball, True]` (`:2246`). `commontur` override (`:2248-2256`): `[0, 1200, 500, default, 1600, default, default, cannonball, True]` (`:2252`), coal 40 / iron 15 (`:2253-2254`).
- **stone wall** `commonsid+'swa/sga'` (`:2258-2284`): NO weapon, NO shield, NO protection (donor-absent zero) `[D]`.
- **weakwall** `ukrwwa/ukrwga` (`:2285-2310`): NO weapon, NO protection; shield H11 = 95 `[O]`.

All live values above are the uncommented heads; `{...}` alternates are donor comments (`80{100}` → 80, `600{1250}` → 600, `1400{950}` → 1400, `350{1200}` → 350, `3000{150}` → 3000, `400{100}` → 400, `200{100}` → 200, `2000{1000}` → 2000, `9000{12500}` → 9000). `default` = `-1` keep-prior (`unit.script:593,523-539`).

---

## 4. Patch recommendation for `data.gd` (COORD/owner applies; this worker edited nothing)

1. **Correct the stale 78-count comment** (`data.gd:971-974`): replace "the 78th is NOT enumerated … stays [U]-T1-tail" with "77-of-77 registration rows CLOSED per DEC_U_weapon_tail §1 (the 78th hit is the `weapon.script:39` procedure definition, not a row). `DONOR_WEAPON_PROTOS` is complete; no row is added." No `DONOR_WEAPON_PROTOS` key is added or changed. NO PARITY CLAIM.
2. **Add a donor-verbatim shield table** (new const, e.g. `DONOR_SHIELD_ROWS`) keyed exactly as §2.2 H0–H11, values literal ints (`15+80` stored as expression or precomputed 95 **with the donor expression kept in the comment**; `80{100}` stored as 80 with comment). Sid scoping: `yachttur`-only 100 (base `yacht` 0), `battleship`-only 100 (frigate/xebec/chaika 0), `commonrus`-tower-only 5 (other towers 0), `ukrwwa/ukrwga` 95, `cannon` 75, `howitzer` 75, `mortar` 25, `multicannon` 50, `framegun` 50, `misgeneral` 10; every other sid defaults 0 per `unit.script:617`. Wire `donor_do_damage` (`data.gd:1185-…`) shield input to this table instead of the estimated `"shield"` fields; keep estimated fields until wired, tagged PORT APPROXIMATION.
3. **Correct two estimated port shields**: `howitzer` 60 → donor **75** (`unit.script:1738`); `mortar` 40 → donor **25** (`unit.script:1768`). Verify `multicannon`/`framegun`/`galley`/`yachttur`/`battleship`/tower/wall entries against §2.2 before touching any other number. Never invent a value for a sid with donor-absent zero.
4. **Add ship/artillery/tower mount rows** (§3) as a donor-cited table (e.g. `DONOR_MOUNT_ROWS`) with the exact `[index, damage, pause, rmin_px, rmax_px, detmin_px, detmax_px, kind, bSearchMin]` + attachments shape — or, minimum, cite-or-tag every `UNITS_BASE` ship/artillery/tower `weapons[]` entry against its §3 line (several port entries currently carry estimated dmg/cd/price that differ from donor, e.g. `howitzer`/`mortar` blocks `data.gd:1551-1576`). Stone `swa/sga`, weakwall, and `ferry` mounts stay **empty** (donor-absent zero `[D]`).
5. **Keep `round()` semantics**: `DONOR_WEAPON_PROTOS` time_expr strings stay verbatim; `donor_round` (`data.gd:1138-1146`, half-to-even) stays as the single `round()` implementation with its `[U]`-G1 tag until the X21 20-vector fixture proves Delphi parity.
6. **Telemetry/format**: every added value carries a `weapon.script:<line>` / `unit.script:<line>` cite comment; every remaining estimate keeps its PORT APPROXIMATION + `[U]` tag with the §5 experiment. No save-version bump, no existing-key rename, no demo/mill/builder/I11 change.

---

## 5. Still-`[U]` register (each with exact settling experiment; never interpolate from a neighbour row)

| # | Item | Static state after this ticket | Exact experiment (owner-authorised) |
|---|---|---|---|
| T1-shield | Shield + mount values in live sim | Donor literals §2.2–§3 `[O]`; port `UNITS_BASE` shields/weapons partly estimated | Apply §4 items 2–4, then runtime weapon-damage probe: fixed-attacker/fixed-defender pairs per sid (built vs unbuilt for ÷3 path), assert `dealt = max(1, indamage − (built ? shield : shield÷3) − prot − …)` per `miscext2.script:339-342`; ship-vs-ship volley for mount dmg/ranges. Mismatch → keep `[U]`, never copy a neighbour sid's number. |
| G1 | `round()` bankers behaviour in PUSSTRELA time rows | Literals kept verbatim §1.1 | X21 20-vector fixture + per-site draw-count test; assert `round(6.5/5.5/7.5/2.5)` Delphi semantics for `PUSSTRELA1/PUSSTRELAPUS/PUSSTRELA4PUS/PUSSTRELA6PUS` time rows. |
| T1-upg | Shield/protection upgrade per-value rows | Shape `[O]` (`player.script:1798`); values still cite-or-tag | Mechanical read `country.script:2050-2210`; every upgrade value cite-or-tag vs `data.gd`; probe ±kind armoury levels in skirmish. |
| R1/O1/A1/D1/Q1/V1/V2/F1/E1 | Unchanged from DEC_U_skirmish_tables §9 | — | Per DEC_U_skirmish_tables §9 experiments. |

---

## 6. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (§1 weapon registry 77/77, §2.1 protection 33/33) rest on donor TEXT `[O]` with file:line; open items (§2.2 shields, §3 mounts in the live sim) list exact next reads/probes in §5.
- The prior "78 rows" statement (DEC_U_skirmish_tables P2/§1.1 header, IMPL-SKIRMISH-ROWS context, `data.gd:971-974`) is corrected, not smoothed over: recount evidence EV-WT-W is reproduced in §1.
- No approximation substituted for a resolved law. The two `{...}`-comment readings (`80{100}` → 80; `200{900}`-class heads) follow the stated donor-comment rule and keep the alternate in the tuple note.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0`; no target opened/selected/closed by this worker.

*End of DEC-U-WEAPON-TAIL.*
