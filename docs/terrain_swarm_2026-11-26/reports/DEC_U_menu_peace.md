---
id: DEC-U-MENU-PEACE
worker: DEC-U-MENU-PEACE (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo source/asset/config/Godot/git edit: this report is the only file written."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All captures below are owner-authorised procedures, not worker runs."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT = port-side fact"
---

# DEC-U-MENU-PEACE — donor peace-time UI→index mapping, labels, selectability, `gbool_peacemode`/`gfloat_peacetime` wiring (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, Length 5,768,048 B, SHA256 `87F0F3C1…4E16C` (re-hashed read-only this session; matches `DEC-U-VICTORY-START` §0). No execution, copy, or target-open. |
| P2 | Enum read | `data/scripts/dmscript.global:1055-1066` — 12-line `gc_mapsettings_peacetime_*` enum verbatim (§1, EV-PM-01). |
| P3 | Seconds-fn read | `data/scripts/lib/misc.script:4262-4281` `_misc_GetPeaceTime` verbatim incl. `Result := Result * 60` (:4281) (§1, EV-PM-02). **Corrects** `DEC-U-VICTORY-START` §2.1 file cite (`dmscript.global:4262-4277` — that file has only 2400 lines; the function lives in `lib/misc.script`) and its unit claim (arms are MINUTES; ×60 makes seconds). |
| P4 | Label read | `data/locale/en/gui.txt:553-575` — 11 peace locale keys + verbatim display strings (§2, EV-PM-03). |
| P5 | Lobby-fill read | `data/gui/menu.inc/showcustomgame.inc:890-901` (value-case map), `:1032-1033` (count), `:1126-1150` (fill loop + 15-insert + tag-restore) (§3, EV-PM-04). |
| P6 | Selection-write read | `data/gui/menu.inc/eventcustomgame.inc:60-79` — listbox tag → `additional.peacetime` verbatim (§4, EV-PM-05). |
| P7 | Wire + init read | `data/scripts/lib/miscext2.script:2375` (serialize), `:2635` (deserialize); `data/scripts/common.inc/dogenerate.inc:2054-2064` (init verbatim) (§4, EV-PM-06/07). |
| P8 | Expiry re-pin | `data/scripts/progress/progress.inc/nothing.inc:658-695` re-read verbatim (§4, EV-PM-08). |
| P9 | `startingsettings.cfg` peace grep | `Select-String 'peacetime'` over `data/game/var/startingsettings.cfg` → **0 hits** [O-absence] (§5, EV-PM-09). Corrects the task-context phrasing (peace is NOT sourced from that cfg). |
| P10 | `gui.script` / `menu*.script` sweep | `data/scripts/lib/gui.script` peace grep → 0 hits [O-absence]; no `menu*.script` exists under `data/scripts` (lobby peace UI lives in `data/gui/menu.inc/*.inc`) (§6, EV-PM-10). |
| P11 | Port read-only inspection (no edit) | `app/scripts/{menu,data,main,game,config}.gd` + `variant3d/scripts/{menu,data,main,game,config}.gd` peace lines (§7, EV-PORT). |
| P12 | Unit audit | `misc.script:4281` ×60 vs port `main.gd`/`config.gd` direct-assign → 60× defect (§7, F-60). |

---

## 1. Enum + seconds function (exact, verbatim) [O]

### 1.1 `dmscript.global:1055-1066` (EV-PM-01) [O]

```
1055: gc_mapsettings_peacetime_default  = 0
1056: gc_mapsettings_peacetime_10       = 1
1057: gc_mapsettings_peacetime_20       = 2
1058: gc_mapsettings_peacetime_30       = 3
1059: gc_mapsettings_peacetime_45       = 4
1060: gc_mapsettings_peacetime_60       = 5
1061: gc_mapsettings_peacetime_90       = 6
1062: gc_mapsettings_peacetime_120      = 7
1063: gc_mapsettings_peacetime_180      = 8
1064: gc_mapsettings_peacetime_240      = 9
1065: gc_mapsettings_peacetime_reserved = 10
1066: gc_mapsettings_peacetime_15       = 11
```

### 1.2 `lib/misc.script:4262-4281` `_misc_GetPeaceTime(ind)` (EV-PM-02) [O]

- `:4262-4264` comment + `function _misc_GetPeaceTime(ind : Integer) : Float;`
- `:4267-4277` arms map each named constant to its MINUTE number: `default→0, _10→10, _20→20, _30→30, _45→45, _60→60, _90→90, _120→120, _180→180, _240→240, _15→15`. `_reserved` (10) has **no arm**.
- `:4278-4279` `else Result := 0;` — any unmapped index (incl. 10) yields 0.
- `:4281` **`Result := Result * 60;`** — the function returns SECONDS. `gfloat_peacetime` unit is seconds [D, forced by :4281 + the `gametime >` comparison at `nothing.inc:658`].

Corrections to `DEC-U-VICTORY-START` §2.1: (a) file is `lib/misc.script`, not `dmscript.global`; (b) arm literals are minutes, seconds come only from the ×60 at :4281; (c) the `else → 0` arm exists, so index 10 is not "falls through" but explicitly 0. Net sim effect identical (reserved ⇒ 0 s ⇒ `gbool` false by the `<> default` rule only when stored value is literally 10 — see §4; the lobby never stores 10, §3).

---

## 2. Displayed labels (verbatim donor strings — never invent, never paraphrase) [O]

`data/locale/en/gui.txt:553-575` (EV-PM-03). Key stems are `randommap.settings.peacetime.*`; lookup in the fill loop is `GetLocaleTableListItemByID('gui', textid+'.'+s2)` (`showcustomgame.inc:1119,1141,1145`).

| s2 suffix | gui.txt line | Verbatim label |
|---|---|---|
| (header) | 553-554 | `Peace Time` |
| `default` | 555-556 | `No Peace Time` |
| `10` | 557-558 | `10 min` |
| `15` | 559-560 | `15 min` |
| `20` | 561-562 | `20 min` |
| `30` | 563-564 | `30 min` |
| `45` | 565-566 | `45 min` |
| `60` | 567-568 | `60 min` |
| `90` | 569-570 | `1.5 hours` |
| `120` | 571-572 | `2 hours` |
| `180` | 573-574 | `3 hours` |
| `240` | 575-576 | `4 hours` |

Port divergences (defects, §7): port renders `No` (donor: `No Peace Time`) and `%d min` for ALL non-zero rows (donor: `1.5 hours / 2 hours / 3 hours / 4 hours` for 90+). No port label may be presented as donor-verbatim.

---

## 3. UI→index mapping: display order, tags, selectability [O]

### 3.1 Fill loop `showcustomgame.inc:1126-1150` (EV-PM-04) [O]

- `:1126` `for i:=0 to gc_mapsettings_peacetime_240 do` — i.e. `i` runs **0..9** in enum order.
- `:1128-1139` `case i of` maps `i` → s2 suffix (`default/10/20/30/45/60/90/120/180/240`); `:1140` `GUIListBoxAddItem(elmHnd, text, i)` — **item tag = enum index** `i`.
- `:1143-1148` `if (i=gc_mapsettings_peacetime_10) then // insert 15 minute after 10`: adds the `15` label with tag `gc_mapsettings_peacetime_15` (= 11) immediately after the `10` row.
- `:1150` restore: `SetGUIListBoxItemIndexSilent(elmHnd, GetGUIListBoxItemIndexOfTag(elmHnd, gMap.settings.additional.peacetime))` — selection is resolved **by tag**, so stored value IS the enum index [D].

### 3.2 Resulting lobby table (exact) [D, forced by §3.1 + §2]

| Display order | Tag (stored index) | Verbatim label | Minutes | Seconds (`gfloat_peacetime`) |
|---|---|---|---|---|
| 1 | 0 | `No Peace Time` | 0 | 0 |
| 2 | 1 | `10 min` | 10 | 600 |
| 3 | 11 | `15 min` | 15 | 900 |
| 4 | 2 | `20 min` | 20 | 1200 |
| 5 | 3 | `30 min` | 30 | 1800 |
| 6 | 4 | `45 min` | 45 | 2700 |
| 7 | 5 | `60 min` | 60 | 3600 |
| 8 | 6 | `1.5 hours` | 90 | 5400 |
| 9 | 7 | `2 hours` | 120 | 7200 |
| 10 | 8 | `3 hours` | 180 | 10800 |
| 11 | 9 | `4 hours` | 240 | 14400 |

### 3.3 Selectable set [O/D]

- Selectable indices: **{0, 1, 11, 2, 3, 4, 5, 6, 7, 8, 9}** — 11 rows. Index **10 (`_reserved`) is never added** to the listbox (loop bound is 0..9; the only extra insert is tag 11) and therefore **not selectable** through the lobby [D].
- Count slot `showcustomgame.inc:1032-1033`: `count := gc_mapsettings_peacetime_15;` (= 11) [O] — consistent with 11 selectable entries.
- Value-case map `showcustomgame.inc:890-901` covers the same 11 tags (`default,10,20,30,45,60,90,120,180,240,15`) for the read-only summary line [O].
- Legacy `40/50` minute values exist NOWHERE in donor evidence (no enum member, no `GetPeaceTime` arm, no locale key, no fill row) — port `40/50` rows are invented [O-absence, confirmed by P2-P5 greps].

---

## 4. From menu choice to `gbool_peacemode` / `gfloat_peacetime` [O]

1. **Choice write** `gui/menu.inc/eventcustomgame.inc:60-79` (EV-PM-05) [O]: `tag := GetGUIListBoxItemTag(elmHnd, GetGUIListBoxItemIndex(elmHnd))`; for `additional_options` with `activeoption = 3`: **`gMap.settings.additional.peacetime := tag`** (`:79`). The stored setting is the lobby item TAG = donor enum index (§3.2).
2. **Net/room wire** `lib/miscext2.script:2375 + :2635` (EV-PM-06) [O]: serialize `roomdata+IntToStr(gMap.settings.additional.peacetime)+…`; deserialize at struct position `gc_MaxPlayerCount+9`: `map.settings.additional.peacetime := istr`. Raw index crosses the wire, no conversion [D].
3. **Sim init** `common.inc/dogenerate.inc:2054-2064` (EV-PM-07) [O]:
   - `:2054` `gbool_editor_peacemode := False;`
   - `:2059` `gfloat_peacetime := _misc_GetPeaceTime(gMap.settings.additional.peacetime);` (seconds via §1.2)
   - `:2060` `gbool_peacemode := (gMap.settings.additional.peacetime <> gc_mapsettings_peacetime_default);` — flag is set from the INDEX (≠ 0), not from the seconds value [D].
   - `:2064` `if (gbool_peacemode) then SetupBorderObjects;`
4. **Expiry** `progress/progress.inc/nothing.inc:658-695` (EV-PM-08) [O]: `if (gbool_peacemode) and (gametime > gfloat_peacetime) and (not _net_IsReplay) and (not _net_IsClient)` → `gbool_peacemode := false` (`:660`); ptborder collect via misc-player handle → `WriteFreeList` + `WritePeaceTime` with `fbstate := gbool_peacemode` (`:684-685`); `GameObjectRequestToDestroyByHandle` per border (`:690`); `GUIMiniMapPrimitivesClear + _misc_UpdateMiniMapPrimitives(True)` (`:692-693`). Strict-`>` boundary: at `gametime == gfloat_peacetime` peace still holds [D].

Unit summary [D]: lobby tag (index) → ×60 at gen time → seconds compare at runtime. Nothing in this chain reads `startingsettings.cfg`.

---

## 5. `startingsettings.cfg`: peace is ABSENT [O-absence]

- `Select-String 'peacetime'` over `C:\Games\Cossacks 3\data\game\var\startingsettings.cfg` → **0 hits** (EV-PM-09). The file carries `startingunits` ids, unit roles, masks/legends — no peace key, no victory/score/timelimit key (consistent with `DEC-U-VICTORY-START` §1.3).
- Correction to the task-context phrasing "`game.gd` peace gate sources seconds from `startingsettings.cfg` index": statically, NO port or donor peace value is sourced from `startingsettings.cfg`. Port-side `cfg.get("peacetime")` (`app/main.gd:329`, `variant3d/main.gd:358`) reads the **menu-emitted dict** (`menu.gd:910` `"peacetime": peace_time`), i.e. the lobby value, not the cfg file. The defect is what happens next (§7 F-60), not the source file.
- Donor `donewgame.inc` peace grep → 0 hits: game start does not re-derive peace; it uses `gMap.settings.additional.peacetime` as set by the lobby event (§4.1).

---

## 6. `gui.script` / `menu*.script` disposition [O-absence + redirect]

- `data/scripts/lib/gui.script` peace grep (`eace`) → **0 hits** (EV-PM-10). `gui.script` carries no peace literal; cite nothing from it for peace.
- No file matching `menu*.script` exists anywhere under `data/scripts` (only `data/scripts/lib/gui.script` matched `gui*|menu*`). The donor "menu scripts" for peace are the GUI include files: `data/gui/menu.inc/showcustomgame.inc` (display/fill) + `data/gui/menu.inc/eventcustomgame.inc` (selection write). All §3-§4 cites use those exact paths.

---

## 7. Port change list — `menu.gd` / `game.gd` (`main.gd`, `data.gd`, `config.gd` supporting) — NO EDITS MADE

Conventions: `app/` = `app/scripts/…`; `v3d/` = `variant3d/scripts/…`. "Change" = exact file:line instruction for the owning worker. Nothing below invents a label or index; all literals come from §1-§4.

### F-NULL (crash) — `v3d/menu.gd:223-227` `_peace_items()` hits the `null` slot [D, port-side]

- `v3d/data.gd:732` table is `[0,10,20,30,45,60,90,120,180,240,null,15]`; `_peace_items()` iterates VALUES: `int(null)` on the reserved slot raises at runtime, and value-as-`id` (`str(m)`) can never represent index 11 (`15` collides with nothing but the id `15` is a minute-count, not the tag — cfg contract broken both ways).
- **Change V1** (`v3d/menu.gd:223-227`): stop iterating `DONOR_PEACE_TIMES` values. Iterate the index→label table of §3.2 (indices `0,1,11,2,3,4,5,6,7,8,9` in that display order; skip 10): `{"id": str(tag), "name": <§2 verbatim label>}`. Cite `showcustomgame.inc:1126-1150 + gui.txt:553-575` on the function.
- **Change V2** (`v3d/menu.gd:740` + `v3d/main.gd:358`, cf. `app/menu.gd:713` + `app/main.gd:329`): treat the emitted `peacetime` as a DONOR INDEX (int tag), not minutes. Validate `tag in {0,1,2,3,4,5,6,7,8,9,11}`; reject/Coerce anything else to 0 with a comment citing `misc.script:4278-4279` (`else → 0`).

### F-60 (wrong by 60×) — port stores minutes where the sim needs seconds [D]

- Donor: minutes ×60 at `misc.script:4281`. Port: `app/main.gd:329` and `v3d/main.gd:358` assign the lobby minute-number straight into `PEACE_TIME` (comment claims "seconds"); `app/config.gd:479` / `v3d/config.gd:594` do the same on load. Effect: a `10 min` pick protects ~10 s instead of 600 s; `game.gd` gates (`app:5467`, `v3d:7322`) compare game-seconds against a minute-number.
- **Change M1** (`app/main.gd:329`, `v3d/main.gd:358`): convert at apply time via the §1.2 table — `PEACE_TIME = float(INDEX_SECONDS[int(cfg.get("peacetime", 0))])` with fallback 0.0 for unknown/reserved (cite `misc.script:4267-4281`). Clamp stays `0.0 .. 14400.0` (`240*60`), already correct as written.
- **Change C1** (`app/config.gd:479`, `v3d/config.gd:594`): same conversion on the `gameplay.peace_time` load path. Load path currently has NO `peace_time` writer anywhere in `config.gd` (only these two read sites found) — if a writer is added, store the INDEX (donor-faithful, matches `miscext2.script:2375` wire habit) and convert once at apply; do NOT store pre-multiplied seconds under a minute-named key. (Save-side audit itself is [U]-S1, §8.)

### F-LABEL / F-VALUES — invented rows, wrong labels [D]

- **Change A1** (`app/data.gd:327` `DONOR_PEACE_TIMES := [0,10,20,30,40,50,60,90,120,180,240]`): values `40/50` are invented; `45/15` missing. Replace with the index-keyed surface (same shape as `v3d/data.gd:735-737` `DONOR_PEACE_TIME_INDEX_SECONDS`, whose VALUES are correct minute-numbers but whose comment mislabels them "seconds" — fix the comment to "minutes; ×60 at apply per `misc.script:4281`"). `v3d/data.gd:732-737` values need no change except that comment fix.
- **Change A2** (`app/menu.gd:209-213`): same rewrite as V1 — 11 index-addressed rows, §2 verbatim labels (`No Peace Time`, `10 min`, `15 min`, `20 min`, `30 min`, `45 min`, `60 min`, `1.5 hours`, `2 hours`, `3 hours`, `4 hours`), display order §3.2. Delete the `"%d min"` formatter for this row (it falsifies 90+). `var peace_time := 0` (`app/menu.gd:47`) then holds a TAG (default 0), consistent with `additional.peacetime` semantics.
- **Change A3** (`app/menu.gd:910` emit + `v3d` equivalent): keep key `"peacetime"` (matches `main.gd` reader) but document value = donor index tag.

### F-GATE (labelling only — behaviour keep) — `game.gd` peace gate

- `app/game.gd:5464-5468` and `v3d/game.gd:7318-7323`: the `PEACE_TIME > 0 and time_s < PEACE_TIME → return` guard is PORT POLICY (donor gates damage via `miscext2.script` territory check + expires via `nothing.inc:658`, never a victory gate — per `DEC-U-VICTORY-START` §2.3). Keep behaviour; re-point the comment: seconds sourced from the §1.2 index table via `dogenerate.inc:2059-2060`, expiry boundary strict-`>` per `nothing.inc:658`. Boundary note: port `time_s < PEACE_TIME → return` ≡ donor `gametime > gfloat → expire`, i.e. at exact equality both still protect — no change needed [D].
- No `gbool_peacemode` equivalent exists port-side (peace is a scalar timer, no flag + no ptborder/minimap handling). Adding one is out of scope for this ticket; record as [U]-G1 (§8) rather than inventing wiring.

---

## 8. Still-[U] register — fixed-seed menu captures, zero-mismatch criteria, no invention

Rules: every capture below runs on a FIXED seed / fixed lobby preset, is performed by the OWNER (donor binary never run by a worker), and passes only on ZERO mismatch across 3 identical runs. No label or index may be asserted without a §1-§4 cite.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) + zero-mismatch criterion |
|---|---|---|---|
| U-M1 | Lobby display order + labels | Table §3.2 [D] from fill code + locale text, but no rendered-lobby screenshot exists | Open skirmish lobby (any fixed seed S, offline): screenshot the Peace Time dropdown expanded; transcribe all 11 rows verbatim. **Zero-mismatch:** row-for-row equality with §3.2 (order, tags invisible — labels only) AND with `gui.txt:553-575` strings; 3 opens identical. Any extra/missing row ⇒ table §3.2 revised, never the screenshot. |
| U-M2 | Stored tag per row | Write path `eventcustomgame.inc:79` [O] says tag=index, but no live tag dump exists | Fixed seed S: click each of the 11 rows, dump `gMap.settings.additional.peacetime` (or the `roomdata` peace field per `miscext2.script:2375`). **Zero-mismatch:** sequence exactly `0,1,11,2,3,4,5,6,7,8,9`; 3 full passes byte-identical. |
| U-M3 | `gfloat_peacetime` seconds per index | Table §1.2+`×60` [O/D], no live read | Fixed seed S, indices `{1,11,4,9}` (10/15/45/240 min — covers insert + mid + max): read `gfloat_peacetime` at gen end. **Zero-mismatch:** exactly `600.0, 900.0, 2700.0, 14400.0`; identical across 3 runs per index. |
| U-M4 | `gbool_peacemode` rule | `<> default` [O], no live read | Indices 0 vs {1..9,11} on seed S: read `gbool_peacemode`. **Zero-mismatch:** `false` for 0, `true` for all others; 3 runs identical. Reserved 10 not drivable via lobby (U-M5). |
| U-M5 | Reserved-10 absence | Statically absent from listbox [D], not probed live | Enumerate lobby listbox item TAGS on seed S (3 runs). **Zero-mismatch:** tag set exactly `{0,1,2,3,4,5,6,7,8,9,11}` every run; tag 10 never present. (Forcing 10 via memory edit is EXCLUDED — outside read-only contract.) |
| U-M6 | Expiry tick boundary | Strict-`>` [D] from `:658`, no live tick log | Seed S, index 1 (600 s): log `gbool_peacemode` + `gametime` per tick across the boundary + ptborder count + minimap-primitive state. **Zero-mismatch:** last `true` tick has `gametime <= 600.0`, first `false` tick has `gametime > 600.0`; border count → 0 exactly on the `false` tick; 3 runs identical tick indices. |
| U-P1 | Port `_peace_items` output | Fix specified (§7 V1/A2), not applied by this worker | Headless: fixed seed, call port `_peace_items()`; emit `[{id,name}]`. **Zero-mismatch:** exactly the 11 §3.2 rows (ids `0,1,11,2,3,4,5,6,7,8,9`; names §2 verbatim); no `null`; 3 runs identical. |
| U-P2 | Port cfg→seconds conversion | Fix specified (§7 M1/C1), not applied | Headless: feed `{"peacetime": <tag>}` for all 11 tags (+ `10` reserved + garbage) through the apply path on fixed seed. **Zero-mismatch:** `PEACE_TIME` exactly `{0,600,900,1200,1800,2700,3600,5400,7200,10800,14400}` seconds; `10`/garbage → `0.0`; 3 runs identical. |
| U-P3 | Port gate boundary | Label fix only (§7 F-GATE) | Headless: `PEACE_TIME=600.0`, step `time_s` 599→601 across `_check_victory`. **Zero-mismatch:** guard returns (no award) at 599 and 600, passes at 601; 3 runs identical. |
| U-S1 | Config save-side audit | No `peace_time` writer found in `config.gd` (load-only) — fate of saved peace value unknown | Grep + headless save/load round-trip on fixed seed after M1/C1 land. **Zero-mismatch:** saved value equals the lobby TAG; reloaded `PEACE_TIME` equals U-P2 seconds. Until then, saved-game peace is UNVERIFIED — never claim persistence. |
| U-G1 | `gbool` flag + border/minimap port surface | No port equivalent (noted §7, not specified) | Deferred to a border-object ticket (`SetupBorderObjects`/`FillOwnerMap` per `dogenerate.inc:2064`). No capture specified here; do NOT gate any 1:1 claim on it. |

---

## 9. Explicit non-claims + file discipline

- NO PARITY CLAIM. Resolved items (enum, labels, order, tags, selectability, init/expiry chain) rest on donor TEXT with `file:line` (§1-§4); open items name exact captures in §8.
- Corrections issued to prior reports: `_misc_GetPeaceTime` file cite (`lib/misc.script`, not `dmscript.global`); arm units are minutes with ×60 at `:4281` (`DEC-U-VICTORY-START` §2.1 said seconds); task-context "`startingsettings.cfg` index" corrected (§5 — the cfg has no peace key; the lobby tag is the source).
- No number invented: no `40/50` rows, no `%d min` for 90+, no camera/focus constant, no threshold beyond cited literals. Every added port line must carry `file:line` + `[O]/[U]` tag; `visual_parity_claim=false`.
- Read-only compliance: exactly one repo file written (this report). Donor evidence is text reads + count greps; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed. Permission-denied files (`misc/ballon.inc`, `movearrow.inc`, `projectile.inc`) were skipped via `-ErrorAction SilentlyContinue`, not force-read.
- Network out of scope: `WritePeaceTime/WriteFreeList` net effects, `_net_IsReplay/_net_IsClient` branches, and room-wire transport (`miscext2.script:2375/:2635`) are cited only as the index-carrier boundary, never as sim law.

*End of DEC-U-MENU-PEACE.*
