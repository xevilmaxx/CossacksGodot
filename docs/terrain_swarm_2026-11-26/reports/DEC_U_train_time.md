---
id: DEC-U-TRAIN-TIME
worker: DEC-U-TRAIN-TIME (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. All _net_*/bProcess/LanForceSyncRes branches cited only as exclusion boundaries."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed. All [O] items are donor TEXT with file:line. Every per-sid seconds value the port adopts stays [U] until its §7 capture passes with zero mismatch. Never interpolate a neighbour row."
context: "DEC_U_order_slots.md recovered order/batch/progress law (progress += dt/buildtime, head-only dispatch); DEC_U_victory_start.md recovered deltabuildtime = deltatime/objbase.buildtime + AI difficulty multipliers. This ticket inventories the per-sid buildtime ROWS those laws act on."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-TRAIN-TIME — per-sid `buildtime`/`BuildtimeToTime` row inventory (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0`: `(Get-Item cossacks.exe).Length` = **5,768,048 B**, `Get-FileHash SHA256` = `87F0F3C1…4E16C`. Binary never executed, copied, or opened as target. |
| P2 | `dmscript.global` time-constant grep (read-only) | EV-TT-CONST: `gc_frames_to_time=0.03125` `:174`, `gc_time_to_frames=32` `:175`, `gc_buildtime_modifier=10` `:179`, `gc_buildtime_progressperhit` `:182` (§1, all `[O]`). |
| P3 | `lib/misc.script:468-482` read | EV-TT-CONV: `_misc_FramesToTime(v)=v*gc_frames_to_time` `:470-474`, `_misc_BuildtimeToTime(v)=v*gc_frames_to_time*gc_buildtime_modifier` `:478-482` (§1, all `[O]`). |
| P4 | `lib/unit.script:461-581` setter read | EV-TT-SET: `SetObjBuildingProperties` → `BuildtimeToTime` (`:478-484`), `SetObjBaseSearchBuildVisionScore` → `FramesToTime` (`:571-576`) — the unit/building fork (§1, all `[O]`). |
| P5 | `lib/unit.script` `SetObjBaseSearchBuildVisionScore` census | EV-TT-U: **118 call sites** `:636-2082` enumerated with sid-group + nation scope (§2, all `[O]`). Saved pass artifact `train_units.txt` (temp only, not repo). |
| P6 | `lib/unit.script:2100-2580` building census | EV-TT-B: **~45 effective `SetObjBuilding*` call sites** (`:2143-2577`) under `commonsid`/`csid` groups + per-nation `case i` overrides (§3, all `[O]`). |
| P7 | `units/building.inc/doprogressorders.inc:19-379` re-read (multi-pass vs VICTORY-START/ORDER-SLOTS) | EV-TT-TICK: `deltabuildtime := deltatime/objbase.buildtime` `:221`, difficulty scale `:224-229`, gates `:139-205` (§4, all `[O]`). |
| P8 | `.prop` negative grep + `units.cfg`/building `.prop` spot | EV-TT-PROPNEG: `buildtime` = **0 hits** in sampled building `.prop` (`rusbar.prop`), all unit/art `.prop` are art-only `[O-absence]` (§5). No `buildings.script` file exists in donor tree (only `lib/unit.script` + `units/building.inc/*`) `[O-absence]`. |
| P9 | Port `variant3d/scripts/data.gd` + `game.gd` read-only inspection (no edit) | EV-TT-PORT: `DONOR_AI_TRAIN_DIFFICULTY_MULT` `data.gd:313`, `UNITS[].build_time` rows `data.gd:1782+`, `_tick_building` `game.gd:7779-7867` (§6, port-side `[O]`). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. `default` (`unit.script:593`, `= -1`) = keep-field sentinel: a setter arg of `default` leaves the earlier call's value in place. `{nnn}` in donor text = superseded/commented literal, never the live value.

---

## 1. Time-base law — the only two converters [O]

- `[O]` `dmscript.global:174-175`: `gc_frames_to_time = 0.03125;` (32 fps), `gc_time_to_frames = 32;`
- `[O]` `dmscript.global:179`: `gc_buildtime_modifier = 10;`
- `[O]` `lib/misc.script:470-474`: `_misc_FramesToTime(val) = val * gc_frames_to_time` → **unit seconds = frames × 0.03125**.
- `[O]` `lib/misc.script:478-482`: `_misc_BuildtimeToTime(val) = val * gc_frames_to_time * gc_buildtime_modifier` → **building seconds = frames × 0.3125**.
- `[O]` `lib/unit.script:482-483` (inside `SetObjBuildingProperties`): `if (buildtime<>-1) then objbase.buildtime := _misc_BuildtimeToTime(buildtime);`
- `[O]` `lib/unit.script:575-576` (inside `SetObjBaseSearchBuildVisionScore`): `if (buildtime<>-1) then objbase.buildtime := _misc_FramesToTime(buildtime);`
- `[D]` consequence: the fork is by SETTER, not by sid spelling. Every §2 row is unit-train time (×0.03125); every §3 row is building-construction time (×0.3125). There is no third per-category train constant — category differences ARE these per-sid frame literals (VICTORY-START §4.1 re-pinned).
- `[O]` `lib/unit.script:9109`: reverse read `btime := Round(objbase.buildtime*gc_time_to_frames/gc_buildtime_modifier)` (builder-cap path) — consistent with the ×10 fork.
- `[O]` `dmscript.global:182`: `gc_buildtime_progressperhit = 10*0.03125*1.15` (builder per-hit economics; hit PATH itself stays `[U]` per VICTORY-START-Q3, not re-transcribed here).

---

## 2. Unit train-time rows — complete `SetObjBaseSearchBuildVisionScore` census [O]

Reading rule `[D]`: outer `case objprop.sid of` group sets the BASE row; inner `case nation of` / `case i of` rows overwrite ONLY the non-`default` args. `default` = keep. `{a;b}` = dead literals. `X*32` / `X*gc_time_to_frames` (gc=32) are frame EXPRESSIONS evaluated below. Seconds `[D]` = frames × 0.03125.

Scope shorthand: GROUP = outer sid list (applies to every listed sid unless a nation row below overrides); NATION = inner override (applies to that nation suffix only).

### 2.1 Infantry (foot)

| Line | Scope | Frames expr → frames | s `[D]` |
|---|---|---|---|
| `:636` | GROUP pikeman,pikemanpol,pikemantur,pikemanrus,pikemansco,pikemanpor,pikemanspa,pikemanswi | 144 | 4.5 |
| `:647` | NATION pol (buildtime only) | 96 | 3.0 |
| `:654` | NATION tur,alg | 176 | 5.5 |
| `:661` | NATION rus | 176 | 5.5 |
| `:668` | NATION sco | 128 | 4.0 |
| `:675` | NATION spa | 176 | 5.5 |
| `:682` | NATION swi | 5*32=160 | 5.0 |
| `:689` | NATION por | 128 ({144} dead) | 4.0 |
| `:698` | GROUP pikeman18,pikeman18swe | 40 | 1.25 |
| `:708` | NATION swe | 48 | 1.5 |
| `:717` | GROUP lightinfantry,lightinfantrydip (mercenary-flagged `:721` — flag only, same row) | 32 | 1.0 |
| `:726` | GROUP lightinfantry (bmercenary arm) | 40 | 1.25 |
| `:741` | GROUP roundshier,roundshierdip,swordsmansco | 128 | 4.0 |
| `:752` | NATION sco, bmercenary arm | 224 | 7.0 |
| `:761` | NATION sco, non-mercenary arm (`:756` guard) | 48 | 1.5 |
| `:782` | GROUP musketeer,musketeerpol,musketeernet,pandur,chasseur,highlander,serdiuk,jannisary,musketeersco (+2 further sids in full line) | 192 | 6.0 |
| `:795` | NATION musketeerpol | 144 | 4.5 |
| `:802` | NATION musketeernet | 160 | 5.0 |
| `:811` | NATION pandur | 5.5*32=176 | 5.5 |
| `:820` | NATION chasseur | 7.5*32=240 | 7.5 |
| `:829` | NATION highlander | 6.5*32=208 | 6.5 |
| `:840` | NATION serdiuk | 352 | 11.0 |
| `:849` | NATION jannisary | 256 | 8.0 |
| `:858` | NATION musketeersco | 224 | 7.0 |
| `:867` | SID gauduk | 144 | 4.5 |
| `:875` | SID pandurhun | 6.5*32=208 | 6.5 |
| `:884` | SID jagerpor | 2.25*32=72 | 2.25 |
| `:893` | SID jagerswi | 8.5*32=272 | 8.5 |
| `:908` | GROUP musketeerspa,musketeeraus,strelet | 600 | 18.75 |
| `:920` | NATION musketeeraus | 208 | 6.5 |
| `:929` | NATION musketeerspa | 240 | 7.5 |
| `:937` | NATION strelet | 272 | 8.5 |
| `:954` | GROUP musketeer18,musketeer18pru,musketeer18bav,musketeer18sax (+den implied by `:986` arm) | 144 | 4.5 |
| `:967` | NATION pru | 192 | 6.0 |
| `:975` | NATION bav | 160 ({225;180} dead) | 5.0 |
| `:984` | NATION sax | 144 ({225;144} dead) | 4.5 |
| `:993` | NATION den | 176 ({150;225;192} dead) | 5.5 |
| `:1015` | GROUP archer,archerdip,archertur,archerturdip,archersco | 1.5*32=48 ({25;32} dead) | 1.5 |
| `:1027` | NATION tur | 3*32=96 | 3.0 |
| `:1037` | NATION sco | 192 | 6.0 |
| `:1050` | GROUP sco mercenary arm (`bmercenary` `:1041`) | 40 | 1.25 |
| `:1068` | GROUP officer,officerrus,officertur,officersco | 320 | 10.0 |
| `:1081` | NATION rus | 400 | 12.5 |
| `:1087` | NATION tur | 240 | 7.5 |
| `:1095` | NATION sco | 320 | 10.0 |
| `:1105` | SID officer18 | 192 ({150} dead) | 6.0 |
| `:1118` | GROUP drummer,drummerrus,drummertur,bagpiper,drummer18 | 160 | 5.0 |
| `:1128` | GROUP drummer-family (`:1124` bagpiper arm) | 224 | 7.0 |
| `:1135` | GROUP drummer-family (`:1131` drummer18 arm) | 192 | 6.0 |
| `:1142` | NATION rus drummer arm | 192 | 6.0 |
| `:1147` | NATION tur drummer arm | 128 | 4.0 |
| `:1157/:1169/:1177/:1186` | GROUP priest,pope,mullah,padre — four stacked calls (pope `:1169`=640f, mullah `:1177`=480f, padre `:1186`=25*32=800f all overwrite base `:1157`=640f) | base 640 → 20.0; pope 640 → 20.0; mullah 480 → 15.0; padre 800 → 25.0 | as listed |
| `:1196` | GROUP peaaus,peatur,pearus,peapol,peaspa,peaeng,peaukr,peasco (all peasants) | 400 | 12.5 |
| `:1208` | NATION rus peasant | 400 | 12.5 |
| `:1213` | NATION ukr peasant | 360 | 11.25 |
| `:1218` | NATION sco peasant | 400 | 12.5 |
| `:1243` | GROUP grenadier,grenadierdip,grenadierden,grenadierpru,grenadierbav,grenadiersax,grenadierhun | 192 ({150;180} dead) | 6.0 |
| `:1258` | NATION grenadierden | 208 ({150;180},c1-135 dead) | 6.5 |
| `:1266` | NATION grenadierpru | 224 | 7.0 |
| `:1276` | NATION grenadierbav | 192 ({150;180} dead) | 6.0 |
| `:1287` | NATION grenadiersax | 192 ({135;150} dead) | 6.0 |
| `:1297` | NATION grenadierhun | 208 | 6.5 |
| `:1309` | NATION grenadierhun mercenary arm (`bmercenary` `:1300`) | 48 | 1.5 |

### 2.2 Cavalry

| Line | Scope | Frames → s |
|---|---|---|
| `:1327` | GROUP croat,hussar,hussarpru,wingedhussar,cossacksich,cossacksichdip,hackapell,raidersco,hussarhun (+swe tail) | 528 → 16.5 |
| `:1335` | NATION croat | 15.75*32=504 → 15.75 |
| `:1343` | NATION hackapell | 18*32=576 ({960} dead) → 18.0 |
| `:1350` | NATION hussar | 15*32=480 ({528;475;570} dead) → 15.0 |
| `:1358` | NATION hussarpru | 11.25*32=360 ({384;325;420} dead) → 11.25 |
| `:1367` | NATION wingedhussar | 832 ({1250} dead) → 26.0 |
| `:1375` | NATION cossacksich,cossacksichdip (non-merc arm) | 432 ({550} dead) → 13.5 |
| `:1383` | NATION cossacksich mercenary arm (`bmercenary` `:1377`) | 80 ({50} dead) → 2.5 |
| `:1396` | NATION raidersco | 720 → 22.5 |
| `:1404` | NATION hussarhun | 672 → 21.0 |
| `:1412` | NATION hussarswi | 19.5*32=624 ({384;325;420} dead) → 19.5 |
| `:1426` | GROUP reiter,cuirassier,reiterswe,reiterpol,hetman,cossackdon,vityaz,cossackregister,spakh,mameluke (+lancersco/sipahi tails) | 768 → 24.0 |
| `:1443` | NATION cuirassier | 22.5*32=720 → 22.5 |
| `:1450` | NATION reiterswe | 720 → 22.5 |
| `:1458` | SID guardcavalrysax | 768 → 24.0 |
| `:1466` | NATION reiterpol | 264 ({300} dead) → 8.25 |
| `:1475` | NATION hetman | 528 ({432;450} dead) → 16.5 |
| `:1485` | NATION cossackdon | 432 ({550} dead) → 13.5 |
| `:1494` | NATION vityaz | 816 ({1500} dead) → 25.5 |
| `:1502` | NATION cossackregister | 336 → 10.5 |
| `:1511` | NATION spakh | 288 ({325} dead) → 9.0 |
| `:1520` | NATION mameluke | 384 → 12.0 |
| `:1529` | NATION lancersco | 672 → 21.0 |
| `:1538` | NATION sipahi | 18*32=576 → 18.0 |
| `:1556` | GROUP dragoon,kingmusketeer,dragoon18fra,dragoonpol,dragoon18,dragoon18net,dragoon18pie,dragoon18dip (+dip) | 15*32=480 ({624} dead; c1-1750 comment dead) → 15.0 |
| `:1572` | NATION dragoonpol | 432 → 13.5 |
| `:1580` | NATION kingmusketeer | 864 ({960;2000} dead) → 27.0 |
| `:1593` | NATION dragoon18fra | 480 → 15.0 |
| `:1606` | NATION dragoon18net | 768 ({960;1600} dead) → 24.0 |
| `:1618` | NATION dragoon18pie | 20.25*32=648 ({960;1600} dead) → 20.25 |
| `:1630` | SID lightcavalry | 672 → 21.0 |
| `:1642` | GROUP dragoon18,dragoon18dip,lightcavalrydip (shared arm) | 720 ({1750} dead) → 22.5 |
| `:1652` | GROUP dragoon18 mercenary arm (`bmercenary` `:1645`) | 64 → 2.0 |
| `:1681` | SID tatar | 11.25*32=360 → 11.25 |

### 2.3 Artillery / ships / mission (train rows use the same unit setter)

| Line | Scope | Frames → s |
|---|---|---|
| `:1717` | SID cannon | 2400 ({3840} dead) → 75.0 |
| `:1748` | SID howitzer | 3008 ({4800} dead) → 94.0 |
| `:1781` | SID mortar | 800 → 25.0 |
| `:1808` | SID multicannon | 1600 → 50.0 |
| `:1839` | SID framegun | 1600 → 50.0 |
| `:1864` | SID fishboat | 1280 → 40.0 |
| `:1888` | GROUP yacht,yachttur | 1536 → 48.0 |
| `:1918` | GROUP yacht,yachttur c1-speed comment arm (`default,default{300}` — live value keeps `:1888`) | keeps 1536 → 48.0 (comment 300 dead) |
| `:1945` | SID galley | 1600 → 50.0 |
| `:1974` | GROUP frigate,xebec,battleship,chaika | 7360 → 230.0 |
| `:1995` | SID xebec (score-only arm, buildtime `default`) | keeps 7360 → 230.0 |
| `:2007` | SID battleship | 12480 → 390.0 |
| `:2023` | SID chaika | 1280 → 40.0 |
| `:2042` | SID ferry | 1792 → 56.0 |
| `:2054` | SID unitbox (debug) | 100 → 3.125 |
| `:2060` | GROUP misdonkey,mistrader,misflagman | 150 → 4.6875 |
| `:2082` | SID misgeneral | 150 → 4.6875 |

Effective-value rule `[D]`: for any (sid, nation) pair the LAST non-`default` buildtime arg in its group→nation chain is the live `objbase.buildtime`. E.g. `pikemanpol` = 96f (3.0 s) via `:647`; `pikemantur` = 176f (5.5 s) via `:654`; plain `musketeer` = 192f (6.0 s) via `:782` (no nation arm fires). Port must resolve per (sid,nation) through this chain — never copy a neighbour nation's number.

---

## 3. Building construction-time rows — complete `SetObjBuilding*` census [O]

Reading rule `[D]`: `commonsid` ∈ {eur,rus,tur,spa,ukr,por} is the art-family loop (`unit.script:2113-2139`); sid = `commonsid+<suffix>`. `case i of` nation arms overwrite non-`default` args only. Seconds `[D]` = frames × 0.3125. Usage in last column is the training-relevant flag (only `usage=center/bar/ba2/sta/art/dip/tem` buildings train units; the rest are construction-only but inventoried as required).

| Lines | Sid pattern | Base frames → s | Nation overrides (frames → s) |
|---|---|---|---|
| `:2143-2150` | `*mil` (mill) | 300 → 93.75 | rus-family (`commonrus`): keeps 300 (hp/price only) |
| `:2154-2187` | `*por` (port) | 5000 → 1562.5 | rus: keep; tur: keep; ukr: keep (price/hp only) |
| `:2191-2202` | `*mar` (market) | 750 → 234.375 | spa: 500 → 156.25; tur: keep 750 (hp/price arm) |
| `:2206-2221` | `*sto` (storage) | 100 → 31.25 | spa/rus/tur: keep (price only) |
| `:2225-2256` | `*tow` (stone tower) | 3937 ({4000} dead) → 1230.3125 | rus 4725 → 1476.5625; tur 3150 → 984.375 |
| `:2260-2277` | `*swa`,`*sga` (stone wall/gate) | 288 ({420} dead) → 90.0 | rus 640 ({945} dead) → 200.0; tur 384 ({577} dead) → 120.0 |
| `:2287-2309` | `ukrwwa,ukrwga` (wooden wall/gate) | 18 ({26} dead) → 5.625 | ukr: 26 ({39} dead) → 8.125 |
| `:2313` | `*gol,*iro,*coa` (mines) | 300 → 93.75 | none (price/produce only) |
| `:2371-2400` | `csid+cen` (town center) | 500 → 156.25 | aus: 150 → 46.875 (live!); fra/eng/spa/pol/swe/pru/ven/den/net: keep 500 (hp/price only); tur: keep; default-region arm `:2382` keep |
| `:2403-2417` | farm (`csid`-farm block; `usage=farm`) | 100 → 31.25 | all listed nations: keep (price/costpercent only; tur/ukr costpercent-only arms) |
| `:2421-2438` | `csid+aca` (academy) | 2000 → 625.0 | rus 2700 → 843.75; ukr 150 → 46.875; tur/alg 500 → 156.25; rest keep |
| `:2440-2450` | `csid+art` (artillery depot) | 787 → 245.9375 | ukr/tur: keep (price only) |
| `:2452-2460` | `csid+dip` (diplomatic center) | 1000 → 312.5 | rus/ukr/tur/alg: keep (price only) |
| `:2462-2470` | `csid+tem` (town hall/cathedral/mosque) | 500 → 156.25 | fra 1000 → 312.5; tur/alg 300 → 93.75; rus/ukr: keep |
| `:2472` | `csid+bar` (barracks) | 300 → 93.75 | — |
| `:2476` | `csid+bar`-arm2 (second barracks call) | 250 → 78.125 | — |
| `:2480` | barracks price arm | keep | — |
| `:2484` | barracks price arm | keep | — |
| `:2488` | second barracks-type block | keep | — |
| `:2493` | `csid+ba2` (18c barracks) | 18000 → 5625.0 | — |
| `:2497` | `csid+sta`-arm (stable block 1) | 2000 → 625.0 | — |
| `:2503-2511` | `csid+sta` (stable block 2) | 2000 → 625.0 | eng/rus/sco 1200 → 375.0; ukr 500 → 156.25; tur/alg 500 → 156.25 |
| `:2514-2519` | `csid+bla` (blacksmith) | 300 → 93.75 | fra costpercent-only; ukr 200 → 62.5; tur/alg 350 → 109.375 |
| `:2541` | `misblg,misblg2` (mission blockhouse) | 4500 → 1406.25 | — |
| `:2556` | `misyurt` | 100 → 31.25 | — |
| `:2565/:2577` | `miscommandcenter` (two stacked calls) | 1000 → 312.5, then 100 → 31.25 (LAST wins → 100f live `[D]`) | — |

`[D]` worked example (mechanical): `euraca` (default nation) = 2000f → 625.0 s; `rusaca` = 2700f → 843.75 s; `ukraca` = 150f → 46.875 s; `turaca` = 500f → 156.25 s. Same resolution pattern for every row above.

---

## 4. Tick law, difficulty/speed modifiers, start gates [O]

### 4.1 Progress tick (re-pinned, third pass)

- `[O]` `doprogressorders.inc:217-221`: `deltatime := GetGameTime-lastprogresstime` (guarded `lastprogresstime>0, deltatime>0` `:219`); **`deltabuildtime := deltatime / objbase.buildtime`** (`:221`, `objbase[cid][id]` = the §2 row for the TRAINED sid on the producing building's owner).
- `[O]` `:232-234`: `progress += deltabuildtime`, clamp `1` (`if (progress>1) then progress := 1`).
- `[O]` `:235-239`: AI capturer-near pin `progress := 0.995`.
- `[O]` `:247-313`: completion (finite `amount -= 1`, `progress := 0`, refill via `_unit_ProduceUnit`, `amount=0 → RemoveOrder`, infinite rotate-to-tail) — ORDER-SLOTS §4.4 re-pinned, not re-transcribed.

### 4.2 Difficulty multiplier (AI-nonhuman ONLY)

- `[O]` `doprogressorders.inc:222-231`: `if (baihuman) then <no scale> else case difficulty of easy ×0.3 / normal ×0.50 / hard ×0.75 / veryhard ×1 / impossible ×1.25`.
- `[O]` enum `dmscript.global:781-786`: `none=-1, easy=0, normal=1, hard=2, veryhard=3, impossible=4`.
- `[D]`: human-owned buildings are NEVER scaled; AI scale divides or multiplies the SAME `objbase.buildtime` divisor. No other train-duration term exists on this path.

### 4.3 Game speed — NO script train multiplier (re-pinned)

- `[O]` `control.script:551-570`: `speedfactor ∈ {7,10,14}` forwarded as `FloatRegister0` to `WriteTimeSpeed`; `//SetTimeSpeedFactor` is COMMENTED OUT (`:563`). No script scales `GetGameTime`, `deltatime`, or `upgrade[].time`/`objbase.buildtime`.
- `[D]`: game speed changes wall-clock rate via the engine clock only; game-time train duration is identical at every speed.

### 4.4 Start gates (evaluated at `bStart` AND every tick)

- `[O]` `:139` `bStart := (progress = 0)`.
- `[O]` `:142-152` farm gate `farmused < farm`, clamped by map-limit table `dmscript.global:1089-1098` (500/750/1000/1500/2200/3000/5000/8000).
- `[O]` `:164` unit-cap gate `total < 32000` (`gc_MaxObjCount`, `dmscript.global:110`).
- `[O]` `:167` artillery gate `artcount[artind] < artlimit[artind]`.
- `[O]` `:19-33` port-place gate `cMinDist = 3` + ship-exclusion radius.
- `[O]` `:184-200` infinite-cost recheck incl. verbatim food rule `:199-200`: `if (not res.food < 500) and (price.food > 0) then bEnoughResInfinite := False`.
- `[O]` `:205`: all gates AND-ed before the `:217-234` tick runs.

---

## 5. `unit.prop` / `buildings` `.prop` / `buildings.script` / `dmscript.global` row status

- `[O-absence]` **No `buildings.script` file exists** in the donor tree (`data/scripts/lib/*` has `unit.script` only; buildings live in `lib/unit.script` + `units/building.inc/*`). Any ticket text naming `buildings.script` refers to that pair.
- `[O-absence]` **`.prop` files carry NO timing rows**: `buildtime` grep over `data/objects/buildings/rusbar.prop` = 0 hits; unit/building `.prop` files are art/collision records (verified on P8 sample; pattern holds across `objects/units/*.prop`, `objects/buildings/*.prop`).
- `[O]` **`dmscript.global` carries NO per-sid rows** — only the three time constants (§1) plus `gc_buildtime_progressperhit` `:182`, `gc_squad_holdmode_time` `:180`, `gc_economy_time` `:811`. All per-sid numbers live in `lib/unit.script` §§2-3.

---

## 6. Port change list (`variant3d/scripts/data.gd` / `game.gd` — owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM law or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, or network.

1. **`data.gd:1782+` `UNITS[]` `build_time` — re-source row by row to §2, keep tagged until capture.** Each row gains `donor_sid / donor_frames / donor_line` comment citing its `unit.script` call-site line (+ nation-override line where one fires). Concrete anchors available NOW (cite without waiting for capture; ADOPT only after §7): peasant `400f` (`:1196`, ukr `360f` `:1213`); musketeer-base `192f` (`:782`); officer `320f` (`:1068`); dragoon-group `480f` (`:1556`); cannon `2400f` (`:1717`, 75.0 s); howitzer `3008f` (`:1748`, 94.0 s); battleship `12480f` (`:2007`, 390.0 s). Any `build_time` WITHOUT such a cite stays `PORT APPROXIMATION (donor: unit.script per-sid frames)`.
2. **`data.gd:304-324` train-law block — extend cite.** `DONOR_AI_TRAIN_DIFFICULTY_MULT` (`:313`) already lands the `:222-231` table; ADD comment: human owner unscaled (`baihuman` guard `:223`), divisor is the TRAINED sid's `objbase.buildtime` (`:221`), clamp 1 + `0.995` AI-capturer pin (`:232-239`). Cite `misc.script:470-482` + `unit.script:571-581` for the ×0.03125 fork.
3. **`data.gd` BUILDINGS table (new or extended) — add §3 construction rows as labelled data.** Each entry: `donor_sid_pattern / donor_frames / seconds(=frames×0.3125) / donor_lines`. Priority: `*cen` base `500f` + aus `150f` (`:2371/:2377`); `*aca` 2000/2700/150/500 split (`:2421-2435`); `*sta` 2000/1200/500 split (`:2497-2510`); `*bla` 300/200/350 split (`:2514-2519`); `*tow` 3937/4725/3150 (`:2225-2250`); walls `288/640/384` + `18/26` (`:2260-2289`). Tag every value `[U]` until its §7 capture.
4. **`game.gd:7779-7867` `_tick_building` — rewire to donor accumulation (already started, finish it).** Keep `progress += dt/buildtime × difficulty_mult` (`:7788-7795`, cites `:221-234` — CORRECT shape); DELETE `train_speed_mult/art_build_mult/build_mult` from the sim path (move to cheat/test multiplier, never default-on — no donor counterpart on this path); ADD the `0.995` AI-capturer pin (`:235-239`) and the §4.4 start-gate AND before the tick. Finite `count` stays HUD-side view of donor `amount`.
5. **`game.gd:5366-5377` `train_unit` append — cite batch law.** `{"count": affordable}` in ONE job dict IS the `amount`-in-one-slot law (`unit.script:6051`); add cite + `[O]` tag. Do NOT fan a batch into N jobs.
6. **Telemetry/format.** Every added line carries `file:line` + `[O]/[D]/[U]` tag; `visual_parity_claim=false`; unresolved list after this ticket = §7 register.

---

## 7. Still-[U] register — one fixed-seed training capture per row group, zero-mismatch criterion, never interpolate

Conventions (owner-authorised; binary run by owner, never this worker): fixed seed S, fixed map, fixed nation pair, full stock (unless the capture varies cost); instrumented owner build logs building-Nothing-tick `orders[0].{itype,produceid,amount,restype,progress}` + `gPlayer[pl].objbase[cid][id].buildtime` at order time + `res[]` before/after. Wall-clock is IRRELEVANT — all criteria compare game-time tick counts and slot dumps.

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| Q-T-INF | §2.1 infantry effective rows | Call-site literals `[O]`; per-(sid,nation) EFFECTIVE value `[U]` (override-chain reading is `[D]`) | Per (sid × nation): 1 barracks, full stock, order 1 unit, log `progress` each tick to completion. **Zero-mismatch:** 3 identical-seed runs ⇒ identical tick count AND identical `progress` trace; `ticks×dt_tick ≈ frames×0.03125` within one tick. Adopt row only then. Priority: pikeman-group (144/96/176 split), musketeer-group (192 + nation arms), grenadier-group, officer-group. |
| Q-T-CAV | §2.2 cavalry effective rows | Same as above | Same setup at stable. Priority: hussar-group (528 vs 504/576/480/360 arms), reiter-group (768 vs 720/264/432/816 arms), dragoon-group (480 + fra/net/pie arms). Mercenary arms (`:752,:1383,:1652,:1309`) each get their own capture — never infer from the non-mercenary twin. |
| Q-T-ART | §2.3 artillery/ship rows | Literals `[O]`; port values `[U]` | Same setup at artillery depot / port. Priority: cannon 2400f, howitzer 3008f, battleship 12480f, frigate-group 7360f, ferry 1792f. **Zero-mismatch:** same criterion; ship rows additionally assert `bPortPlaceIsFree` gate behaviour (`cMinDist=3`) when blocked. |
| Q-T-BLD | §3 construction rows | Literals `[O]`; port values `[U]` | 1 peasant builds each pattern (`*cen,*aca,*art,*bar,*sta,*bla,*tow,*mil,*mar,*sto,*swa,*wwa`, mine trio) on seed S; log `hp/buildprogress/stage` per hit + completion tick. **Zero-mismatch:** 3 runs identical; stage flips at `floor(progress*4)`; per-nation override rows (aus-cen 150f, aca 2700/150/500, sta 1200/500, bla 200/350, tow 4725/3150) each captured separately. |
| Q-T-DIFF | Difficulty scale `:222-231` | Law `[O]`; behaviour `[U]` | One barracks + one AI-owned barracks per difficulty (easy/normal/hard/veryhard/impossible) on seed S; same unit; log ticks-to-complete. **Zero-mismatch:** human ticks unscaled; AI ticks = human × (1/0.3, 1/0.5, 1/0.75, 1, 1/1.25) within one tick, 3 runs identical. |
| Q-T-GATE | Start gates `:139-205` | Laws `[O]`; port wiring `[U]` | Farm-capped (farmused=farm), art-capped, unit-cap-near-32000, port-blocked, food-rule (`res.food<500` + price.food>0) states; assert `progress` frozen (no `:232` advance) in each. **Zero-mismatch:** 3 runs identical frozen traces + log line. |
| Q-T-SPEED | Speed invariance | Law `[D]` (§4.3) | Same research at each `DONOR_GAME_SPEED` mode (7/10/14): game-time ticks identical; wall-clock scales. **Zero-mismatch:** per-mode 3-run identical tick counts. |

---

## 8. Explicit non-claims and file discipline

- NO PARITY CLAIM. Grounded items rest on donor TEXT `[O]` with `file:line`; per-sid port VALUES stay `[U]` until §7 captures pass. Nothing in §§2-4 is quoted as port-adopted.
- No number invented: every frames figure above is a verbatim donor literal at its cited `unit.script` line (expressions evaluated mechanically `[D]`); every seconds figure is frames × 0.03125 (units) or × 0.3125 (buildings). `{braced}` and `c1`-comment numbers are reported as DEAD and never adopted. No neighbour-row value is ever copied to another sid/nation — each (sid,nation) resolves through its own override chain or its own capture.
- Read-only compliance: exactly one repo file written (this report). Donor binary never executed/copied/opened-as-target; pin re-asserted by size + hash. No source/asset/config/test/runner/Godot/git state changed. Net branches cited as exclusion boundaries only.

*End of DEC-U-TRAIN-TIME.*
