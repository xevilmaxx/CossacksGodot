---
id: DONAVAL-01
owner: DONAVAL-01 (subagent)
date: 2026-11-25
area: donor naval/ship assets + skirmish-relevant behaviour truth
mode: "TWO PASS: (1) read prior naval docs + DEC_02/DEC_03 decomp; (2) fresh read-only donor bytes/latin-1 Python (3.14) of ship definitions, hull/crew/sail/flag/paddle meshes, skins, AAF/ACL, movement/collision/spawn constants"
scope: "singleplayer skirmish naval parity only — missions/campaign/network stay deferred (D-12)"
donor: "C:\\Games\\Cossacks 3 (private use; bytes + latin-1 only; never run, copied or modified)"
compliance: "no donor binary copied or executed; no code edit; no Godot/Blender job; no runner job; only this report written"
status: COMPLETE — truth captured, 7 corrections logged, port gaps ranked; NO parity claim
labels: observed / derived / inferred / UNVERIFIED used per claim; engine-side semantics marked UNVERIFIED
---

# DONAVAL-01 — Donor naval/ship assets and skirmish behaviour truth

## 0. Verdict up front

- **Donor naval truth is fully readable** and now re-read fresh: 7 core ship hulls + `chaika`/`ferry`, 6 animated crew `.oss`, a large previously-unlisted attached-parts set (sails/flags/paddles/ladder), all `.dds` skins including the **shared `xebeca.dds` ship-atlas material**, exact stat/speed/radius constants, and shore/water spawn rules with `path:line`.
- **7 corrections** to prior claims are logged in §3 — the material-presence question is closed, crew counts are scope-dependent (5 core / 6 incl. ferry), the gold-stop rule has a locale/script contradiction, the `not … < 4` precedence is **UNVERIFIED**, ship radii are larger than the port estimates, and a `convert_models.py` comment asserting "no shipyard/dock .osm anywhere" is factually false.
- **The 3D variant ships static hull meshes but no naval entity simulation.** `variant3d/scripts/world3d_entities.gd` has no water-media branch, no ship spawn, no ship movement/collision, and only the mill gets a sail child (`world3d_entities.gd:1412-1415`). `water3d.gd` ports the surface shader but its waveheight is 0 under shipped constants (`water3d.gd:24-45`). Gap ranking in §5.2. **No parity claim.**

---

## 1. Sources (all read this task, read-only)

### 1.1 Prior docs (pass 1)
| # | File | Use |
|---|---|---|
| P1 | `docs/NAVAL_EVIDENCE.md` | mesh inventory/verdict; 54 core meshes, 24 `.aaf`/9 `.acl`; corrected here on crew count scope |
| P2 | `docs/NAVAL_PORT_PLAN.md` | bake feasibility, two-layer hull+crew model, seven families, open questions (Q5 material presence — now closed) |
| P3 | `docs/coord_swarm_2026-11-24/reports/W210_naval_assets.md` | live index `naval_units/index.json`, 7 keys/12 PNG, data.gd hand-off, donor stat table from `unit.script` |
| P4 | `docs/coord_swarm_2026-11-24/reports/R09_naval.md` | gap table G-N1, top-5 ranked gaps, gold-stop (R09 #7), upkeep (R09 #9) |
| P5 | `docs/coord_swarm_2026-11-24/reports/V778_ship_skins.md` | 7 ships skipped as IDP2 static hulls; 55 shipped skins; labels `PORT APPROXIMATION — NOT DONOR PARITY`, visual UNVERIFIED |
| P6 | `docs/research/RD_DLC.md` | DLC scope guard; naval = P-10 lane, Portuguese Shipyard (G10), missions/campaign deferred |
| P7 | `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` | 222 scripts catalogued; ship selection `:78-100`, port spawn `:202-203,247-270`, shore collision, water height, AI water battle link; gold precedence **UNVERIFIED** (§9 Q1) |
| P8 | `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` | `formations.cfg` ship formations `SHIPS12/SHIPS5/SHIPSN5/SHIPS8/SHIPS3` at `:595-599`; `hotkeys.cfg:165-167` `Ctrl+Q` = `select|allships`; `Key=P` = `build|%com%por` at `:68-69` |

### 1.2 Fresh donor reads (pass 2)
All paths below are relative to `C:\Games\Cossacks 3\`. Binary reads used `open(p,'rb')`, headers via `struct.unpack_from('<16i'/'<6i')`; text files decoded `latin-1`. Temporary probe scripts lived in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donaval_*.py`, **not in the repo**. Files read:

- `data\actors\units\<ship>.{osm,oss,actor,tlf}`, `data\actors\units\attach\*` (sail/flag/paddle/ladder parts)
- `data\materials\units\*.dds` (ship skins)
- `data\animations\aaf\*.aaf`, `data\animations\acl\*.acl`, `data\animations\ref\refspeed.acl`
- `data\scripts\lib\unit.script:1854-2049, 8170-8215`, `lib\country.script:3100-3111`, `dmscript.global:285-340,608-680`, `lib\misc.script:4504-4560,5157-5220`, `units\building.inc\doprogressorders.inc:14-115,195-275`, `units\global.inc\progresswarai.inc:2705-2765`
- `data\locale\en\units.txt:775-842,968-982`, `data\objects\buildings\eurpor.prop`
- Port read-only: `variant3d\scripts\world3d_entities.gd`, `variant3d\scripts\water3d.gd`, `variant3d\tools\convert_models.py`, `variant3d\tools\unit_bakers\naval.py`, `variant3d\assets\models\manifest.json`

---

## 2. Fresh donor asset tables (observed)

### 2.1 Core hull meshes — `data\actors\units\<name>.osm` (IDP2, binary)

Header longs (0-based, little-endian): `[0]=0x32445049 "IDP2"`, `[6]=verts`, `[7]=uv`, `[8]=faces`, `[12]=vertex offset`, `[13]=UV offset`, `[14]=face offset`, `[15]=file size`. The offsets `[12/13/14]` match the two bake readers (P2 §1, DC fnd_7 retracted defect).

| Ship | .osm B | verts | uv | faces | offs 12/13/14 | 1–4 + death1/2 present? | `.tlf` B |
|---|---:|---:|---:|---:|---|---|---:|
| yacht | 427,436 | 9,364 | 11,490 | 7,731 | 132 / 92,052 / 277,596 | yes | 16,511 |
| yachttur | 188,444 | 2,649 | 6,545 | 3,898 | 132 / 52,492 / 146,044 | yes | 16,511 |
| fishboat | 71,868 | 1,577 | 2,406 | 1,135 | 132 / 19,380 / 46,620 | yes | 16,511 |
| frigate | 866,140 | 19,008 | 24,618 | 15,205 | 132 / 197,076 / 561,996 | yes | 16,511 |
| galley | 323,300 | 7,522 | 9,468 | 5,294 | 132 / 75,876 / 202,932 | yes | 16,511 |
| battleship | 822,604 | 17,072 | 21,650 | 15,671 | 132 / 173,332 / 549,436 | yes | 16,511 |
| xebec | 407,012 | 9,188 | 9,832 | 7,550 | 132 / 78,788 / 259,988 | yes | 16,511 |
| chaika *(extended)* | 167,612 | 2,619 | 4,163 | 3,844 | 132 / 33,436 / 125,692 | yes | 16,511 |
| ferry *(extended)* | 305,620 | 6,912 | 11,553 | 4,269 | 132 / 92,556 / 195,012 | yes | 16,511 |

Citation: `data\actors\units\<ship>.osm` header bytes 0–63; direction files `<ship>1.osm`…`<ship>4.osm` and `<ship>_death1.osm`/`_death2.osm` all present (88 ship-named files in `data\actors\units` incl. `.actor`/`.tlf`). `ferry.actor:10-16` uniquely uses `ferry_collider.osm` (724 B) as LOD0 (dist 0–0) and `ferry.osm` as LOD1 (dist 0–150).

Each `<ship>.actor` (1,935–2,267 B) is a **text** descriptor: `AnimationMode = aamLoop`, `FrameInterpolation = afpNone`, `Reference = aarTransform`, `Animations.LoadFromFile = .\data\animations\aaf\<ship>.aaf`, `TransformationFrameList.LoadFromFile = .\data\actors\units\<ship>.tlf`, then mesh items `<ship>.mesh` + `<ship>1..4` + `_death1/_death2` (observed, e.g. `data\actors\units\yacht.actor:1-40`).

### 2.2 Animated crew `.oss` (observed)

All six files are **byte-identical 217,344 B** with header `(k,fps,bones,verts,faces,uvs) = (311,30,20,584,947,793)` — i.e. the same humanoid crew figure, not a hull:

| Ship | `.oss` | B | Verdict |
|---|---|---:|---|
| yacht / yachttur / fishboat / frigate / galley | present | 217,344 each | 5 core animated crews |
| ferry *(extended)* | present | 217,344 | **6th animated `.oss`** — missed if only the 7 core families are counted |
| battleship / xebec / chaika | **absent** | — | hull-only, donor-faithful |

Citation: `data\actors\units\<ship>.oss:off0..23`; P2 §1 confirmed the same for yacht (`(311,30,20,584,947,793)`).

### 2.3 Attached parts — `data\actors\units\attach\*` (observed; previously unlisted)

Donor composes a ship from separate actors: hull (§2.1) + crew (§2.2) + **sail + flag + paddle/ladder**. Exact sizes:

| Part class | Files (bytes) |
|---|---|
| Sail `.osm` (huge cloth/rigging meshes) | `yacht_sail` 3,042,980 · `yachttur_sail` 3,386,932 · `fishboat_sail` 2,887,804 · `frigate_sail` 9,910,372 · `galley_sail` 6,728,220 · `battleship_sail` 3,381,948 · `xebec_sail` 4,915,148 · `chaika_sail` 1,939,580 · `ferry_sail` **15,304,676** |
| Flag `.oss` (animated) | `battleship_flag1..4` 38,940/37,932/22,824/37,932 · `frigate_flag1..4` 19,144/31,956/31,956/31,956 · `galley_flag1..4` 61,500/61,452/61,500/45,860 · `xebec_flag1..3` 31,524/23,580/24,684 · `yacht_flag1..2` 31,524/19,608 · `chaika_flag1..2` 57,580/56,988 |
| Paddle `.oss` | `fishboat_paddle_l/r` 10,332/10,700 · `chaika_paddle_l/r` 84,532/84,532 · `ferry_paddle_l/r` 61,224/104,828 · `galley_paddle_l/r` 130,132/130,132 |
| Ladder `.oss` | `ferry_ladder.oss` 17,888 |
| Anchor/parent `.osm` | `<ship>a.osm` = 660 B for all nine; `galley_death1a` 16,348, `xebec_death1a` 18,044, etc. |

Each part has its own `.actor` (e.g. `yacht_sail.actor` 604 B, `yacht_flag1.actor` 361 B, `fishboat_paddle_l.actor` 378 B) and usually its own AAF (§2.5). **UNVERIFIED:** parent/attach transforms — read from text names/sizes only, no mesh geometry or runtime composition decoded.

### 2.4 Skins / textures — `data\materials\units\*.dds` (observed)

| File | Bytes | Note |
|---|---:|---|
| `battleship.dds`, `chaika.dds`, `ferry.dds`, `frigate.dds`, `galley.dds`, `xebec.dds` | 5,592,560 each | full-size ship atlases |
| `fishboat.dds` | 1,398,256 | smaller atlas |
| `yacht.dds`, `yachttur.dds` | 2,796,368 each | |
| **`xebeca.dds`** | **2,796,344** | **shared ship-atlas material — NOT an alternate xebec skin** (see below) |
| `misflagman.dds` | 349,680 | flagship-flag material |

**`xebeca.dds` resolved (observed, second-pass follow-up):** registered as `Material.Name = xebeca` with `Material.Texture.image = .\data\materials\units\xebeca.dds` and `Material.FaceCulling = fcNoCull` at `data\materials\units\units.mat:434-442`. It is the **default/useable material for every ship attach part** — `data\objects\units\attach\<ship>a.prop:23-36` (`battleshipa`, `chaikaa`, `fishboata`, `galleya`, `xebeca`, `yachta`, `yachttura`, meshes 0–6), and the `DefaultMaterialName` of `<ship>.prop:81` for battleship/chaika/fishboat/galley/xebec/yacht/yachttur; `chaika.prop:83-89`, `fishboat.prop:83-89` and `yacht.prop:83-89` bind *all* seven meshes to `xebeca`, while `battleship.prop:83-89` uses `battleship`/`battleshipa` for its own meshes. `data\objects\units\attach\xebeca.prop:4-10` even defines `xebeca` as a ship attach object (`DefaultMeshName = xebeca.mesh`). **Inference:** the per-family `<ship>.dds` textures the static hull; the shared `xebeca.dds` textures the common attach/rigging meshes. No nation/state switch was found in plaintext — the choice is prop-driven, not script-driven.

Winter shipyard variants exist in prop text: `data\objects\buildings\eurpor.prop:16-18` `UseSeasonMaterial = True`, summer `eurpor`, winter `eurporw` (also `ruspor.prop:18`; materials registered at `data\materials\buildings\buildings.mat:928-929,948-949`). **UNVERIFIED:** DDS pixel contents, mip layout, and any visual parity — only filenames, registration and prop bindings were read.

### 2.5 AAF / ACL actions (fresh full read, text)

Unit AAFs are **identical** for all ships (`AAF\r\n4\r\n"idle",1,280 / "walk",1,280 / "death",1,280 / "attack0",1,280,morph`): `data\animations\aaf\<ship>.aaf` (92 B each; `battleship` 92, `chaika` 92, `ferry` 92).

| AAF family | Exact inclusive ranges (observed) |
|---|---|
| `<ship>_sail.aaf` (106/129 B) | 4 actions, e.g. yacht `idle 1-60, idle_to_walk 61-90, walk 91-120, walk_to_idle 121-149`; frigate idle 1-60/61-89/90-120/121-150; galley 5 actions incl. `walk2 181-269`; battleship 1-60/60-90/90-150/150-180 |
| `<ship>_flag.aaf` (27/28 B) | single `idle` — battleship 1-150, chaika 1-279, frigate 1-59, galley 1-299, xebec 1-149, yacht 1-149 |
| `<ship>_paddle.aaf` (129/131 B) | 5 actions `idle/idle_to_walk/walk/walk2/walk_to_idle` (fishboat 1-305, galley 1-299); `ferry_paddle.aaf` (71 B) 3 actions 1-219; `shippaddle.acl` (750 B) gives the state mapping |
| `fishboata.aaf` / `ferrya.aaf` (28 B) | `idle 1-305` / `idle 1-219` |
| `ferry_ladder.aaf` (100 B) | `idle_open 80-81, idle_closed 83-84, close 1-39, open 40-79` |
| `chaikaa.aaf` (129 B) | 5 actions 1-279 |
| `balloon.aaf` (98 B) | `transform 1-134, idle 135-194, rope 195-229, fly 230-299` |

ACLs (12 naval, text): `battleship.acl` 1,805 B; `fishboat.acl` 1,056; `frigate.acl` 1,796; `galley.acl` 2,820; `xebec.acl` 1,790; `yacht.acl` 1,790; `yachttur.acl` 2,828; `chaika.acl` 1,790; `ferry.acl` 1,790; `shippaddle.acl` 750; `shipsail.acl` 1,002; `balloon.acl` 2,851. Ship ACLs reference `data\animations\ref\refspeed.acl` refkeys `<ship>idle`/`<ship>walk` and fire `OnAclAnimationReachedAttack` for `attack0` (observed, e.g. `yacht.acl:1-40`, `battleship.acl:1-40`). Total naval AAF count re-confirmed as **30** (P1/P4 scope caveat stands).

### 2.6 Movement / collision constants (observed, exact literals)

| Rule | Citation | Value |
|---|---|---|
| Media: land / water / fly | `data\scripts\dmscript.global:290-292` | 0 / **1** / 2 |
| Motion style | `dmscript.global:303-305` | default 0, **ship 1**, slowrotate 2 |
| Explosion media | `dmscript.global:294-301` | default 0, water 1, building 2, **ship 3**, grass 4, wood 5, rock 6 |
| Ship rotate speed | `dmscript.global:628` | `gc_obj_rotatespeed_ships = 2` (artillery 1, default 5) |
| Ship speeds | `dmscript.global:612-620` | fishboat 16, ferry 28 *(C1 was 16)*, yacht 40, yachttur 70, chaika 55, galley 40, frigate 30, xebec 28, battleship 16 |
| **Speed assignment** | `lib\unit.script:1857,1875,1906,1924,1961,1991,2001,2015,2035` | all `objbase.speed := gc_obj_speed_*` lines are **commented out** → effective speed is engine-side, **UNVERIFIED** from plaintext |
| ACL animation move-step | `data\animations\ref\refspeed.acl:69-151` | fishboat 0.015, ferry 0.028125, yacht 0.0375, yachttur 0.065625, galley 0.0375, frigate 0.028125, xebec 0.02625, battleship 0.015; turn steps 1.1125–4.45. Derived: `move_step ≈ speed × 0.0009375` for all nine — the constants **are** reflected in animation timing |
| Radii in px | `dmscript.global:668-676` | fishboat 40, ferry 70, yacht 35, yachttur 50, chaika 45, galley 80, frigate 90, xebec 80, battleship 90 |
| Radii in metres | derived via `gc_pixels_to_meter=26.6666666` (`dmscript.global:170`) | yacht 1.31, yachttur 1.88, fishboat 1.50, chaika 1.69, galley 3.00, frigate 3.38, xebec 3.00, battleship 3.38, ferry 2.63 |
| Water height | `common.inc\generatemap.inc:7` (`cWaterHeight = -1.1`); `common.inc\texturemap.inc:30-31` (`cWaterHeight = -0.25`, `cWaterShoreHeight = -0.1`); `common.inc\dogenerate.inc:1576-1580` shore `< -0.1` | two different literals by pipeline stage |
| Projectile water clamp | `misc\projectile.inc\doexplode.inc:19-28` | `py ≥ waterheight + 0.0025`; splash via `_misc_DoRoundDamage` at `:83` |
| Water surface raycast | `lib\miscext.script:1515-1517` | `RayCastWater(realx,realy,waterheight)`, `h > waterheight+0.0025` |
| Usage ids | `dmscript.global:321-336` | battleship 14, fisher 16, port 19, frigate 25, galley 26, **yacht 27, xebec 28**, transport 29 |
| Ship detection | `lib\unit.script:82-107` | `_unit_IsWaterUnit` ⇔ `media = gc_obj_media_water`; `_unit_IsBattleShip` ⇔ water **and** `transport = 0` |
| Water-unit selector | `lib\control.script:78-100` `_control_SelectAllShips()`; `hotkeys.cfg:165-167` `Ctrl+Q` = `select|allships` | selects first member of each water squad |

### 2.7 Ship stat blocks (fresh re-read, `data\scripts\lib\unit.script`)

Signature per P3 §3.1: `SetObjBasePrice(objbase, food, wood, stone, gold, iron, coal)`; `SetObjBaseWeapon(objprop, objbase, index, damage, pause, radiusmin, radiusmax, detectradiusmin, detectradiusmax, kind, bSearchMinAttackRadius)`. All price tuples are **wood/gold/iron/coal** (food and stone = 0 in these calls).

| Ship | hp / shield | price wood/gold/iron/coal | upkeep gold | weapon slot 0 = dmg / pause / min–max px / iron+coal per shot | citation |
|---|---|---|---|---|---|
| fishboat | 300 / — | 600 / 0 / 0 / 0 | none (`bnohungry`) | **no weapons**; fishingspeed `50 div 4`, fishingmax 1000 | `:1855-1871` |
| yacht | 31,000 / — | 900 / 450 / 150 / 200 | 50 | cannonball 1000 / 350 / 300–1100 / 4+9; splash `addradius` px32; dispersion px250; **flank guns** (`bshotleftflank`+`bshotrightflank`) | `:1873-1902` |
| yachttur | **35,000 / 100** | inherits yacht (no override) | **1500** | slot0 30 / 400 / default–1000 / 5+15 (`default` kind); slot1 0 / 700 / 1000–1650 / 5+15; buildtime `default{300}` w/ comment "construction speed reduced 10 times then in c1" | `:1903-1920` |
| galley | 35,000 / 80 *(C1 100)* | 9500 / 900 / 800 / 0 | 1000 | cannonball 100 / 150 / 300–1200 / 4+9 **+ mortarball** 1000 / 50 / 1100–3100 / 4+9, `attmask` building+woodwall; forward fire only | `:1922-1958` |
| frigate | 50,000 / — | 5000 / 1100 / 600 / 800 | 150 | cannonball 1800 / 75 / 400–1650 / 25+35; flank guns | `:1959-1987` |
| xebec | 65,000 / — | 7000 / 1600 / 320 / 960 | **0** | inherits 1800 (`default`), 50 / 550–1700 / 25+35 inherited | `:1989-1997` |
| battleship | 90,000 / **100** | 9000 / 3200 / 700 / 6500 | **15000**, `bmercenary` | inherits 1800, 20 / 600–1950 / 5+15 | `:1998-2012` |
| chaika *(extended)* | 25,000 / — | 1050 / 600 / 200 / 400 | 0 | cannonball 1000 / 175 / 300–1100 / 4+9; forward **+ rear** fire | `:2013-2030` |
| ferry *(extended)* | 62,000 / — | 300 / 50 / 100 / 0 | none (`bnohungry`) | no weapons; `transport := 80+40 = 120`; `exitMaxDelay = 0.375` | `:2033-2049` |

All ships set `media := gc_obj_media_water` and `motionstyle := gc_obj_motionstyle_ship`; all except fishboat set `bstandground`, `bshowdelay`, `bnohungry`. `bturnoff` is set in the yacht/yachttur block (`:1894`) and the frigate/xebec/battleship/chaika block (`:1979`) — **not** galley. See §2.8.

### 2.8 Gold-shortage firing gate (literal + contradiction)

`data\scripts\lib\unit.script:8185` (fresh re-read):

```
if (TObjProp(pobjprop).bturnoff) and (not gPlayer[pl].res[gc_resource_type_gold]<4) then
begin
   TObj(pobj).attackmaxdelay := MaxFloat(…, 100*gc_frames_to_time);
   TObj(pobj).attackdelay     := MaxFloat(…, 100*gc_frames_to_time);
   bEnoughRes := False;
   … _misc_ShowLogMessage(gc_logmessagesid_cantshootnogold, …, False);   // :8200
end
else bEnoughRes := _unit_EnoughResForShot(goHnd, weapon);                  // :8205
```

- **observed**: literal condition and the `cantshootnogold` log message at `:8200`; per-shot resource gate `_unit_EnoughResForShot` at `:8205` with 64-frame attack delay (`:8208-8209`).
- **UNVERIFIED**: DScript precedence of `not … < 4` (DEC_02 §9 Q1 lists `not res >= cost` as unprovable from plaintext). Reading `(not (gold<4))` would *disable* firing at gold ≥ 4, which contradicts the locale. The behavioural intent is inferred from `data\locale\en\units.txt:802` "When out of gold, the galley stops firing" and `:839` (cannons).
- `data\locale\en\units.txt:781-828` tiers: fishboat "Only used for fishing…", yacht "Low tier warship", yachttur "Yacht" (Turkish patrol/messenger), galley "Mid tier… two kinds of artillery", frigate "Mid tier… Requires funding", battleship "Ship of the Line… High tier", xebec "Mid tier… Requires no gold", ferry "Can ferry 120 units at once".

### 2.9 Port / shore / water spawn rules (fresh re-read)

| Rule | Citation | Literal behaviour |
|---|---|---|
| Shipyard roster tiers + gates | `lib\country.script:3100-3111` | `fishboat` tier 0 (no gate); `yacht`/`yachttur` tier 1, `ferry` 2, `galley` 4, `frigate`/`chaika`/`xebec` 5, `battleship` 6 — all but fishboat gated by `<cid>+'art'` (arsenal); `frigate`/`xebec` additionally `enablefrigate`; `battleship` `enablebattleship`. Member = `commonNamePort` = `%com%por` |
| Shipyard build/actor | `data\objects\buildings\eurpor.prop:1-139` (4,984 B); `data\actors\buildings\commoneur\eurpor.osm` 341,276 B + `1..4`/`death1/2` + `attach\eurpor*a.osm`; same family for `ruspor`, `turpor`, `ukrpor`, `porpor`, `poraca`, `porart`, `porba2`, `porbar`, `porbla`, `porcen`, `pordip`, `porhou`, `porsta`, `portem` | prop: `LODActorName=eurpor`, `CustomBoundingAABB` X −2.15..3.55 / Y −0.25..1.35 / Z −1.80..1.70 (`:68-73`), `DefaultScale 0.4623` (`:132-134`), `DefaultRollAngle = 135` (`:138`), winter material `eurporw` (`:18`), auto-children scaffold `eurpora` + fishnet `eurporb` (`:81-127`) |
| Port place free | `units\building.inc\doprogressorders.inc:16-49` | `GetPortPlaceIsFree`: get port resource point, `cMinDist = 3`, reject if a built, alive ship (`explmedia = gc_obj_explmedia_ship`) is within 3 → `Result := False`; if the blocking ship is idle, re-order it to `_unit_GetRandomWaterPosition(objHnd, 4, px, pz)` (`:40-41`) |
| Production gate | `doprogressorders.inc:202-205` | `bPortPlaceIsFree` is a hard gate alongside farm/resource/unit-limit/art gates |
| Ship dummy (build animation) | `doprogressorders.inc:51-94,96-115` | `CreateShipDummy` spawns the ship at the port resource point with `gc_obj_shipcontructrollangle`, 4 visual stages via `floor(progress*4)` → `visual_stage_0..3` + `essential_birth`; `GetShipDummy` finds an unbuilt ship within radius 2 |
| Completion spawn | `doprogressorders.inc:247-270` | spawn at last custom exit point if `exitCount > 0` (`:253-266`), else building centre; **for `usage = port` it is overridden by `_misc_GetPortResourcePoint(myHnd, px, pz, True)` at `:270`** |
| Port resource point | `lib\misc.script:4506-4560` | prefers child base `gc_basename_bui` (`bui`) if built (`:4509-4518`); fallback radial scan: `minDist 9→3` when precise, `maxDist 11`, `cPresiseCalc = 72` angles, `cCollisionRad = 1`, `GetMapCollisionTagInRadius(...) = gc_collisiontag_water`, ×1.1 bias near 90°/180°/270°/360° (`:4530-4560`) |
| Shore collision paint | `lib\misc.script:5159-5219` `_misc_SetShoresCollisionInArea` | half-cell grid (`x=(i-w)/2`), any water cell adjacent to tag 0 or bridge → radius `gc_WaterBorderSize` disc, paint `gc_collisiontag_landborder` on land and `gc_collisiontag_waterborder` on water (`:5175-5205`); called at map gen (`common.inc\dogenerate.inc:2068`) and load (`lib\serial.script:304`) |
| Naval AI | `units\global.inc\progresswarai.inc:2705-2765` | `_ai_ArmyMakeWaterBattleLink`: merge via `gc_ai_MergeWaterArmyDist`, seek `gc_ai_armyorder_makewaterbattle = 6` (`dmscript.global:436`), `_ai_FindNearestWaterEnemyZone(plInd, 30 / 0, …)`, zone path; dispatched by `_ai_IsWaterArmy` at `:2761-2764` |
| Naval formations | `data\game\var\formations.cfg` via `DEC_03_configs.md:595-599` | `SHIPS12` (42-wide, 11 rows), `SHIPS5`, `SHIPSN5`, `SHIPS8`, `SHIPS3`; all bonus tuples 0/0/0/0 |

---

## 3. Verify / correct prior claims (explicit verdicts)

| # | Prior claim | Fresh verdict | Evidence |
|---|---|---|---|
| V1 | "frigate/galley/xebec material `.dds` presence not yet confirmed" (P2 §5 Q5) | **CORRECTED — CONFIRMED PRESENT** | `data\materials\units\{frigate,galley,xebec}.dds` = 5,592,560 B each (§2.4); all 7 core ships + `xebeca.dds` variant present |
| V2 | "5 animated `.oss` / 7 families" (P1 §2.1, P4 claim 1) | **SCOPE CORRECTION** — 5 within the 7 core families is correct; **6 total** naval crew `.oss` once `ferry.oss` is counted. `battleship`/`xebec`/`chaika` have none | §2.2; `data\actors\units\ferry.oss` 217,344 B |
| V3 | "24 naval `.aaf` + 9 `.acl`" (P1 §2.4-2.5) | **CONFIRMED as scoped subset** — 30 AAF / 12 ACL exist incl. attach parts, shipyard and balloon | §2.5; P4 claim 2 |
| V4 | "Skin variants upgraded by tiers" | **DEFINED, not a tiered skin system** — tiers are locale strings + `country.script` production gates (tier 0–6, `art`/`enablefrigate`/`enablebattleship`), while skins are per-family `.dds` atlases plus one alternate `xebeca.dds`. No plaintext "upgrade tier → swap texture" rule found; any such binding is engine-side, **UNVERIFIED** | §2.4, §2.9; `country.script:3100-3111` |
| V5 | "Galley stops firing when out of gold" (locale) vs "galley has no bturnoff" (R09 #7) | **CONTRADICTION CONFIRMED** — script sets `bturnoff` on yacht/yachttur/frigate/xebec/battleship/chaika, **not** galley; `consume gold := 1000` for galley. Rule precedence `not … < 4` **UNVERIFIED** | `unit.script:1894,1979,8185`; `units.txt:802`; §2.8 |
| V6 | Port hp/price/upkeep table (P3 §3.1) | **CONFIRMED verbatim** plus corrections: `yachttur` shield 100 (`:1908`), `galley` shield 80 (`:1929`) not 100, `xebec` radius px80 (not px90), `battleship` shield 100 (`:2000`), `chaika` 25,000 hp and `ferry` 62,000 hp/transport 120 newly tabulated | §2.7 |
| V7 | Port speed estimates ~2–4 m/s, radii 1.0–2.6 m (P2 §4, P3 §3.2) | **DIVERGENCE** — donor radii in metres are 1.31–3.38 (big ships larger than port estimates); speed constants 16–70 are declared but their direct assignments are commented, so m/s conversion is **UNVERIFIED**; ACL move-step scales with those constants | §2.6 |
| V8 | "`7 ships skipped` — no naval animation" (P5 §3.5) | **CONFIRMED for skins/morphs, but static hull assets DO ship** in `variant3d`: 7 OBJ + 7 PNG with measured bboxes (`variant3d\assets\models\manifest.json` entries; `obj\yacht.obj` 794,962 B, `tex\yacht.png` 2,062,111 B, etc.). No parity claim | §5.1 |
| V9 | `convert_models.py:279-280` "no shipyard/dock .osm anywhere under data/actors; 'Shipyard' … is a name only, not an actor" | **FALSE as written** — 15 `*por*.actor`/`.osm` families exist under `data\actors\buildings\{commoneur,commonrus,commontur,ukr,por}\`; `eurpor.osm` 341,276 B. True only in the narrow sense that no sid literally named `dock` exists | §2.9; `data\actors\buildings\commoneur\eurpor.actor` 1,751 B |
| V10 | Naval map rules "shore/water spawn" absent/unknown | **PRESENT and now cited** — port resource point radial water scan, port-place-free 3 m blocking, ship-dummy 4-stage construction, shore collision disc paint, two water-height literals | §2.9 |

**Engine-side parts declared UNVERIFIED:** effective `objbase.speed` source (commented assignments), `not … < 4` precedence, sail/flag/paddle attach transforms and geometry, DDS pixel content and nation selection of `xebeca.dds`, `gc_obj_shipcontructrollangle` numeric value (constant not located in `dmscript.global` plaintext), any runtime weather/ship wake application.

---

## 4. Pass-1 decomp naval bits (what they add beyond P1–P6)

- `DEC_02_scripts.md:437` `_control_SelectAllShips()` at donor `control.script:78-100`; `:664` port-place gate at `doprogressorders.inc:202-203`; `:671` completion spawn at `:247-270`; `:779` AI `ArmyMakeWaterBattleLink` at `progresswarai.inc:2707`; `:783` transport at `:3776`; `:798-809` water heights/shore; `:881-885` projectile water clamp and splash; `:924-954` "missing 3D features" list does **not** name ships — this report fills that hole.
- `DEC_02_scripts.md:1014-1017` explicitly marks the `not res >= cost` precedence UNVERIFIED — applies to the gold-stop gate of §2.8.
- `DEC_03_configs.md:595-599` gives the five ship formations with exact mask widths; `:337` `P = build|%com%por` (shipyard hotkey), `:360` `Ctrl+Q = select|allships`, `:339` unbound water wall `%com%wwa`.
- `RD_DLC.md:98-99,119` keeps naval as P-10 / Portuguese Shipyard and defers DLC/campaign — respected here.

---

## 5. Port comparison (read-only) and gap ranking for skirmish naval parity

### 5.1 What variant3d actually has (observed)

| Asset / feature | Port state | Citation |
|---|---|---|
| Static hull geometry | **present**: 7 ship OBJs + PNGs generated from donor `<ship>.osm`/`.dds`, 8-direction metadata; e.g. `obj\yacht.obj` 794,962 B, `obj\frigate.obj` 1,669,027 B, `tex\frigate.png` 4,332,173 B | `variant3d\assets\models\manifest.json` (7 ship entries); `variant3d\tools\convert_models.py:300-325` (`ship_models`, 7 sids, `directions: 8`) |
| Skins/morphs | **absent by design**: skins converter skips all 7 as IDP2 static hulls (`convert_skins.py:196`); shipped skin index has 55 land units only | P5 §3.5; `variant3d\assets\models\skin\index.json` 33,944 B |
| Naval entity in world | **absent**: `world3d_entities.gd` has no `media_water`/ship branch; the only sail child in the whole entity layer is the mill (`world3d_entities.gd:1412-1415` `if sid == "mil": _attach_rotor(...)`) | grep of `variant3d\scripts\world3d_entities.gd` (76 keyword hits, none naval) |
| Water surface | **present shader**: `water3d.gd` ports donor fragment literals (`WATER_LEVEL -0.25`, `WATER_SHORE_HEIGHT -0.1`, `COAST_FADE 0.57`, `DEEP_FADE 1.07`, `WAVE_TEX diffusewaves0.png`) | `water3d.gd:24-45,92-97,176-208` |
| Wave height | **0 under shipped constants** — `WATER_SURFACE_Y = -0.25` is a labelled PORT APPROX placeholder for engine-supplied `gl_TexCoord[1].z` (UNVERIFIED); donor `water.lib` also has `WaveAmp=0` | `water3d.gd:26-36,54-61,264-270` |
| Shore rendering | **known defect**: terrain clamps `BLK_WATER` to grass1, while donor paints wet sand; water module cannot fix it | `water3d.gd:296-304` |
| Dock/shipyard model | **not converted**: comment claims no shipyard `.osm` in donor (false — §3 V9); 2D port has a `dock` building with only `["yacht"]` (P3) | `convert_models.py:279-280`; P3 §3 |

### 5.2 Ranked missing/wrong for skirmish naval parity (highest first)

| Rank | Gap | Donor truth (citation) | Port today | Impact |
|---:|---|---|---|---|
| **1** | **No naval entity simulation** — no water-medium class, no ship spawn/move/collision, no water-vs-land blocking, no flank firing arcs | `media_water=1`, `motionstyle_ship=1`, `rotatespeed_ships=2` (`dmscript.global:290-292,303-305,628`); `_unit_IsWaterUnit` (`unit.script:82-89`); `bshotleft/rightflank` (`unit.script:1900-1901,1985-1986`); shore collision (`misc.script:5159-5205`) | no branch in `world3d_entities.gd`; water is a visual quad only (`water3d.gd:233-237`) | **CRITICAL** — ships cannot exist as skirmish units in 3D |
| **2** | **No shipyard/dock production path** — 4-stage ship construction, port-place-free gate, water-adjacent spawn absent | `country.script:3100-3111`; `doprogressorders.inc:16-49,51-115,202-205,247-270`; 15 `*por*` actor families | 2D port `dock.trains = ["yacht"]`; 3D no dock model (`convert_models.py:279-280` false comment) | **HIGH** — even with hull art there is no build → spawn flow |
| **3** | **Composite parts missing** — sail (up to 15.3 MB mesh), flag (1–4 animated variants), paddle (L/R), ladder are separate donor actors; port renders hull only | §2.3; AAF/ACL actions §2.5 | no sail child except mill (`world3d_entities.gd:1414-1415`); skins skipped (`convert_skins.py:196`) | **HIGH visual** — static bare hull vs donor multi-layer vessel |
| **4** | **Gold-shortage firing gate + per-shot iron/coal cost** | `unit.script:8185-8210` (`bturnoff`, `cantshootnogold`, `_unit_EnoughResForShot`), `cost` at `:1882-1883,1910-1911,1932-1933,1968-1969,2004-2005` | absent in 3D; R09 #7/#8 mark absent in 2D too | **MEDIUM-HIGH** — changes combat outcomes in shortage states; precedence UNVERIFIED |
| **5** | **Stat fidelity** — donor hp/price/upkeep/radii/weapon ranges known; ship roster beyond yacht unwired | §2.7, §2.6 | 2D `data.gd` yacht-only sid (P3/P4); 3D has no stat table for ships | **MEDIUM** — data-only, but must be donor-exact and consistent with xebec 0 upkeep / battleship 15000 |
| **6** | **Naval AI + selection/hotkeys** — water battle link, `SHIPS*` formations, `_control_SelectAllShips`, `Ctrl+Q`, `P` shipyard binding | `progresswarai.inc:2705-2765`; `DEC_03_configs.md:595-599,337,360` | no naval AI in 3D; 2D hotkeys 42 vs 52 donor binds (`DEC_03_configs.md:740`) | **MEDIUM** |
| **7** | **Wrecks / FX / waterline** — donor ships have `_death1/_death2` wreck meshes + `impwater*.oss` splashes + shore sand paint | §2.1; P1 §2.3; `texturemap.inc:463-472,503-511` via `water3d.gd:300-301` | hull OBJ only; waterline reveals grass1 (`water3d.gd:296-304`) | **LOW-MEDIUM cosmetic** |
| **8** | **Water surface fidelity** — donor shader ports most literals, but surface-Y/waveheight is engine-supplied and UNVERIFIED | `water3d.gd:24-45,54-61,264-270`; donor `water.lib` | labelled PORT APPROX, waveheight 0 | **LOW** — matches donor `WaveAmp=0`; a labelled A/B is the only fix path |

**Explicitly NOT a parity claim:** this ranking describes what is missing/wrong relative to the donor; it does not assert that any gap is fixed, nor that the port's approximations are donor-equivalent.

---

## 6. Open questions

1. **UNVERIFIED — effective ship speed.** All `objbase.speed := gc_obj_speed_*` assignments are commented (`unit.script:1857…2035`). Are speeds read from compiled `objbase`/`.prop` data, or from the ACL `TrackPointMoveStep` only? Needed before any m/s conversion.
2. **UNVERIFIED — gold-stop precedence.** `not gPlayer[pl].res[gold]<4` (`unit.script:8185`); DEC_02 §9 Q1 cannot resolve DScript precedence from plaintext. A recorded game or engine parser is required.
3. **UNVERIFIED — galley contradiction.** Locale says galley stops firing on gold 0 (`units.txt:802`) but script omits `bturnoff` for galley (`unit.script:1922-1958`). Which is runtime truth?
4. **UNVERIFIED — `xebeca.dds` selection.** No plaintext script reference; alternate skin for a nation, season, or captured ship? Only filename/size known.
5. **UNVERIFIED — composite attach rig.** Sail/flag/paddle/ladder `.actor` files name meshes but parent/transform data was not decoded; cannot yet place them on the hull.
6. **UNVERIFIED — DDS pixels and visual parity.** Only file sizes/headers were read; no pixel decode or rendered A/B. `xebeca.dds` and all 7 atlases remain visually unconfirmed.
7. **UNVERIFIED — `gc_obj_shipcontructrollangle`** value (used at `doprogressorders.inc:107`), and `gc_WaterBorderSize` numeric value (`misc.script:5194`) — not found in the constants block read.
8. **Scope decision:** `chaika` and `ferry` are readable donor ships with unique behaviour (chaika free/rear-fire; ferry transport 120) but have no baked PNG/index key (P3 §4 Q3). Include in skirmish parity or keep 7-family scope?
9. **Port-read truth drift:** 2D `data.gd` state may have advanced since P3/P4 (W2-10 hand-off still open); any integration ticket must re-read before wiring sids.

---

## 7. Summary

- **Pass 1** read all six prior naval docs plus the naval bits of `DEC_02_scripts.md` (ship selection, port production, shore collision, water heights, AI water link, hotkeys) and `DEC_03_configs.md` (ship formations, shipyard/P hotkey, Ctrl+Q).
- **Pass 2** fresh-read the donor: 9 readable ship hull `.osm` with exact vert/uv/face counts and header offsets; 6 identical 217,344-B crew `.oss`; a full attach-parts inventory (sail `.osm` up to 15.3 MB, 4-variant flags, L/R paddles, ferry ladder) with exact sizes and AAF ranges; 10 ship `.dds` skins including alternate `xebeca.dds`; complete stat/speed/radius/usage constants; and shore/water spawn rules down to the 72-angle port resource scan and 3 m port-place gate.
- **7 corrections** logged: skin presence closed, crew-count scope clarified, AAF/ACL count scope confirmed, "tier" reinterpreted as production gates rather than texture swaps, galley gold-stop contradiction confirmed, radii/speed divergence flagged, and the false "no shipyard .osm" comment refuted. Engine-side semantics are explicitly **UNVERIFIED**.
- **Port comparison:** variant3d ships static hull OBJ/PNG for 7 sids and a donor-literal water shader, but has **no naval entity layer, no dock production, no composite sail/flag/paddle/crew, no naval stats or AI**. Ranked gap list §5.2 puts naval entity simulation and shipyard production at the top. **No parity claim; no code changed.**

---

*DONAVAL-01 — donor private-use read-only; only this report written. Missions/campaign/network deferred (D-12).*
